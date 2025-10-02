 {
  -------------------------------------------------------------------------------------------
  |  author: Gabriel Mororó                                                                 |
  |  page:   https://github.com/Gabrielmororo180                                            |
  -------------------------------------------------------------------------------------------
}


unit Cielo.Deeplink;

interface

uses
  System.Classes, System.SysUtils,
  Cielo.Deeplink.Payment, Cielo.Deeplink.Cancel,FMX.Dialogs, Cielo.Deeplink.Print,
    {$IFDEF ANDROID}
  FMX.Platform.Android,
  System.Messaging,
  System.NetEncoding,
  Androidapi.JNI.JavaTypes, Androidapi.JNIBridge,
  Androidapi.JNI.Net,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Os,
  Androidapi.Helpers,Json,
  {$ENDIF}
  Cielo.Deeplink.Android;

type
  TCieloDeeplinkSuccessEvent = procedure(Sender: TObject; const PaymentID: string) of object;
  TCieloDeeplinkErrorEvent = procedure(Sender: TObject; const ErrorMessage: string) of object;
  TCieloDeeplinkCancelEvent = procedure(Sender: TObject) of object;

  TCieloDeeplink = class(TComponent)
  private
    FScheme: string;
    FHost: string;
    FAccessToken: string;
    FClientID: string;
    FAbout: string;
    FOnPaymentSuccess: TCieloDeeplinkSuccessEvent;
    FOnPaymentError: TCieloDeeplinkErrorEvent;
    FOnPaymentCancel: TCieloDeeplinkCancelEvent;
    FOnCancelSuccess: TCieloDeeplinkCancelEvent;

    {$IFDEF ANDROID}
    procedure HandleIntentMessage(const Sender: TObject; const M: System.Messaging.TMessage);
    {$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExecutePaymentTransaction(Payment: TCieloDeeplinkPayment);
    procedure ExecuteCancelTransaction(Cancel: TCieloDeeplinkCancel);
    procedure ExecutePrint(Print: TCieloDeeplinkPrint);
  published
    property Scheme: string read FScheme write FScheme;
    property Host: string read FHost write FHost;
    property AccessToken: string read FAccessToken write FAccessToken;
    property ClientID: string read FClientID write FClientID;
    property About: string read FAbout stored False;
    property OnPaymentSuccess: TCieloDeeplinkSuccessEvent read FOnPaymentSuccess write FOnPaymentSuccess;
    property OnPaymentError: TCieloDeeplinkErrorEvent read FOnPaymentError write FOnPaymentError;
    property OnPaymentCancel: TCieloDeeplinkCancelEvent read FOnPaymentCancel write FOnPaymentCancel;
    property OnCancelSuccess: TCieloDeeplinkCancelEvent read FOnCancelSuccess write FOnCancelSuccess;
 end;

procedure Register;

implementation




procedure Register;
begin
  RegisterComponents('CieloDeeplink', [TCieloDeeplink]);
end;

{ TCieloDeeplink }

constructor TCieloDeeplink.Create(AOwner: TComponent);
begin
  inherited;
  FScheme := 'order';
  FHost := 'response';
  FAbout:='Cielo Deeplink Component v1.0 - Desenvolvido por Gabriel Mororó';
  {$IFDEF ANDROID}
  // Registrar para receber intents
  MainActivity.registerIntentAction(TJIntent.JavaClass.ACTION_VIEW);
  System.Messaging.TMessageManager.DefaultManager.SubscribeToMessage(
    System.Messaging.TMessageReceivedNotification,
    HandleIntentMessage
  );
  {$ENDIF}
end;

destructor TCieloDeeplink.Destroy;
begin
  inherited;
end;

procedure TCieloDeeplink.ExecuteCancelTransaction(
  Cancel: TCieloDeeplinkCancel);
begin

  Cancel.AccessToken := FAccessToken;
  Cancel.ClientID := FClientID;
  Cancel.CallbackScheme := FScheme;
  Cancel.CallbackHost := FHost;
  ExecuteCieloDeeplinkCancel(Cancel);

end;

procedure TCieloDeeplink.ExecutePaymentTransaction(Payment: TCieloDeeplinkPayment);
begin
  Payment.AccessToken := FAccessToken;
  Payment.ClientID := FClientID;
  Payment.CallbackScheme := FScheme;
  Payment.CallbackHost := FHost;

  ExecuteCieloDeeplinkPayment(Payment);

end;

procedure TCieloDeeplink.ExecutePrint(Print: TCieloDeeplinkPrint);
begin

  Print.CallbackScheme := FScheme;
  Print.CallbackHost := FHost;

  ExecuteCieloDeeplinkPrint(Print);

end;

{$IFDEF ANDROID}
procedure TCieloDeeplink.HandleIntentMessage(const Sender: TObject; const M: System.Messaging.TMessage);
var
  Msg: System.Messaging.TMessageReceivedNotification;
  Intent: JIntent;
  Uri: Jnet_Uri;
  RespParam: string;
  Bytes: TBytes;
  JsonStr: string;
  Json: TJSONObject;
  Status, PaymentID, Reason: string;
  Code, PaidAmount: Integer;
begin
  if not (M is System.Messaging.TMessageReceivedNotification) then
    Exit;

  Msg := System.Messaging.TMessageReceivedNotification(M);
  Intent := TJIntent.Wrap((Msg.Value as ILocalObject).GetObjectID);

  if (Intent = nil) or (not Intent.getAction.equals(TJIntent.JavaClass.ACTION_VIEW)) then
    Exit;

  Uri := Intent.getData;
  if (Uri = nil) or
     (JStringToString(Uri.getScheme) <> FScheme) or
     (JStringToString(Uri.getHost) <> FHost) then
    Exit;

  RespParam := JStringToString(Uri.getQueryParameter(StringToJString('response')));

  if RespParam = '' then
    Exit;


  Bytes := TNetEncoding.Base64.DecodeStringToBytes(RespParam);
  JsonStr := TEncoding.UTF8.GetString(Bytes);

  Json := TJSONObject.ParseJSONValue(JsonStr) as TJSONObject;
  try
    if not Assigned(Json) then
      Exit;


    if Json.TryGetValue<Integer>('code', Code) then
    begin
      Reason := Json.GetValue<string>('reason', 'Motivo não informado');

      case Code of
        1:
          if Assigned(FOnPaymentCancel) then
            FOnPaymentCancel(Self);
        2:
          if Assigned(FOnPaymentError) then
            FOnPaymentError(Self, Reason);
      end;

      Exit;
    end;


    Status := Json.GetValue<string>('status', '');
    PaymentID := Json.GetValue<string>('id', '');
    PaidAmount := Json.GetValue<Integer>('paidAmount', 0);

    if SameText(Status, 'PAID') or (PaidAmount > 0) then
    begin
      if Assigned(FOnPaymentSuccess) then
        FOnPaymentSuccess(Self, PaymentID);
    end
    else if SameText(Status, 'CANCELLED') then
    begin
      if Assigned(FOnPaymentCancel) then
        FOnPaymentCancel(Self);
    end
    else if SameText(Status, 'ERROR') or SameText(Status, 'FAILED') then
    begin
      Reason := Json.GetValue<string>('notes', 'Erro desconhecido');
      if Assigned(FOnPaymentError) then
        FOnPaymentError(Self, Reason);
    end
    else if SameText(Status, 'CANCEL_SUCCESS') then
    begin
      if Assigned(FOnCancelSuccess) then
        FOnCancelSuccess(Self);
    end
    else
    begin

      if Assigned(FOnPaymentCancel) then
        FOnPaymentCancel(Self);
    end;

  finally
    Json.Free;
  end;
end;



{$ENDIF}

end.

