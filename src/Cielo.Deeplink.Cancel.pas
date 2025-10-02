unit Cielo.Deeplink.Cancel;

interface

uses
  System.SysUtils, System.JSON, System.NetEncoding;

type
  TCieloDeeplinkCancel = class
  private
    FID: string;
    FClientID: string;
    FAccessToken: string;
    FCieloCode: string;
    FAuthCode: string;
    FValue: Currency;
    FCallbackScheme: string;
    FCallbackHost: string;
    procedure Validate;
  public
    constructor Create;
    destructor Destroy; override;
    function ToJson: string;


    property ID: string read FID write FID;
    property ClientID: string read FClientID write FClientID;
    property AccessToken: string read FAccessToken write FAccessToken;
    property CieloCode: string read FCieloCode write FCieloCode;
    property AuthCode: string read FAuthCode write FAuthCode;
    property Value: Currency read FValue write FValue;

    property CallbackScheme: string read FCallbackScheme write FCallbackScheme;
    property CallbackHost: string read FCallbackHost write FCallbackHost;
  end;

implementation

{ TCieloDeeplinkCancel }

constructor TCieloDeeplinkCancel.Create;
begin

end;

destructor TCieloDeeplinkCancel.Destroy;
begin
  inherited;
end;

procedure TCieloDeeplinkCancel.Validate;
begin
  if Trim(FID) = '' then
    raise Exception.Create('O campo "ID" da ordem é obrigatório.');

  if Trim(FClientID) = '' then
    raise Exception.Create('O campo "ClientID" é obrigatório.');

  if Trim(FAccessToken) = '' then
    raise Exception.Create('O campo "AccessToken" é obrigatório.');

  if Trim(FCieloCode) = '' then
    raise Exception.Create('O campo "CieloCode" é obrigatório.');

  if Trim(FAuthCode) = '' then
    raise Exception.Create('O campo "AuthCode" é obrigatório.');

  if FValue <= 0 then
    raise Exception.Create('O valor do cancelamento deve ser maior que zero.');
end;

function TCieloDeeplinkCancel.ToJson: string;
var
  JSON: TJSONObject;
begin
  Validate;

  JSON := TJSONObject.Create;
  try
    JSON.AddPair('id', FID);
    JSON.AddPair('clientID', FClientID);
    JSON.AddPair('accessToken', FAccessToken);
    JSON.AddPair('cieloCode', FCieloCode);
    JSON.AddPair('authCode', FAuthCode);
    JSON.AddPair('value', TJSONNumber.Create(Round(FValue * 100))); // centavos
    Result := JSON.ToJSON;
  finally
    JSON.Free;
  end;
end;


end.

