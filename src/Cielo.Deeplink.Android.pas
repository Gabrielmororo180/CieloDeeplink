unit Cielo.Deeplink.Android;

interface

uses
 {$IFDEF ANDROID}
  Androidapi.Helpers,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Net,
  FMX.Helpers.Android,
  FMX.Platform.Android,
  {$ENDIF}
  System.NetEncoding, System.SysUtils, FMX.Dialogs,
  Cielo.Deeplink.Payment, Cielo.Deeplink.Print,
  Cielo.Deeplink.Cancel,JSON;


procedure ExecuteCieloDeeplinkPayment(Payment: TCieloDeeplinkPayment);
procedure ExecuteCieloDeeplinkCancel(Cancel: TCieloDeeplinkCancel);
procedure ExecuteCieloDeeplinkPrint(Print: TCieloDeeplinkPrint);
procedure ExecuteIntent(UriStr:string);
implementation






procedure ExecuteCieloDeeplinkPayment(Payment: TCieloDeeplinkPayment);
var
  JsonStr, Base64Str, UriStr, CallbackUri: string;
  Utf8Bytes: TBytes;
begin
  JsonStr := Payment.ToJson;
  Utf8Bytes := TEncoding.UTF8.GetBytes(JsonStr);
  Base64Str := TNetEncoding.Base64.EncodeBytesToString(Utf8Bytes);

  if (Payment.CallbackScheme <> '') and (Payment.CallbackHost <> '') then
    CallbackUri := Format('%s://%s', [Payment.CallbackScheme, Payment.CallbackHost])
  else
    CallbackUri := '';

  if CallbackUri <> '' then
    UriStr := Format('lio://payment?request=%s&urlCallback=%s', [Base64Str, CallbackUri])
  else
    UriStr := Format('lio://payment?request=%s', []);

  ExecuteIntent(UriStr) ;

end;


procedure ExecuteCieloDeeplinkCancel(Cancel: TCieloDeeplinkCancel);
var
  JsonStr, Base64Str, UriStr, CallbackUri: string;
  Utf8Bytes: TBytes;
begin
  JsonStr := Cancel.TojSON;

  Utf8Bytes := TEncoding.UTF8.GetBytes(JsonStr);
  Base64Str := TNetEncoding.Base64.EncodeBytesToString(Utf8Bytes);

  if (Cancel.CallbackScheme <> '') and (Cancel.CallbackHost <> '') then
    CallbackUri := Format('%s://%s', [Cancel.CallbackScheme, Cancel.CallbackHost])
  else
    CallbackUri := '';

  UriStr := Format('lio://payment-reversal?request=%s&urlCallback=%s',
                   [Base64Str, CallbackUri]);

  ExecuteIntent(UriStr) ;
end;


procedure ExecuteCieloDeeplinkPrint(Print: TCieloDeeplinkPrint);
var
  JsonStr, Base64Str, UriStr, CallbackUri: string;
  Utf8Bytes: TBytes;
  Bytes: TBytes;
  Json: TJSONObject;
begin
  JsonStr := Print.ToJson;
  Utf8Bytes := TEncoding.UTF8.GetBytes(JsonStr);
  Base64Str := TNetEncoding.Base64.EncodeBytesToString(Utf8Bytes);

  if (Print.CallbackScheme <> '') and (Print.CallbackHost <> '') then
    CallbackUri := Format('%s://%s', [Print.CallbackScheme, Print.CallbackHost])
  else
    CallbackUri := '';

  if CallbackUri <> '' then
    UriStr := Format('lio://print?request=%s&urlCallback=%s', [Base64Str, CallbackUri])
  else
    UriStr := Format('lio://print?request=%s', [Base64Str]);





    ExecuteIntent(UriStr)

end;

procedure ExecuteIntent(UriStr:string);
{$IFDEF ANDROID}
var
Intent: JIntent;
{$ENDIF}
begin

  {$IFDEF ANDROID}
  Intent := TJIntent.JavaClass.init(
    TJIntent.JavaClass.ACTION_VIEW,
    TJnet_Uri.JavaClass.parse(StringToJString(UriStr))
  );
  Intent.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  MainActivity.startActivity(Intent);
  {$ELSE}
  ShowMessage(UriStr);
  {$ENDIF}

end;



end.

