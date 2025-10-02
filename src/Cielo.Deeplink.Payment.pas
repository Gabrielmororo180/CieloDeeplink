unit Cielo.Deeplink.Payment;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.JSON,
  Cielo.Deeplink.Types;

type
  TCieloDeeplinkItem = class
  public
    Name: string;
    Quantity: Double;
    SKU: string;
    UnitOfMeasure: string;
    UnitPrice: Currency;
    procedure Validate;
    function ToJson: TJSONObject;
  end;

  TCieloDeeplinkPayment = class
  private
    FAccessToken: string;
    FClientID: string;
    FReference: string;
    FMerchantCode: string;
    FEmail: string;
    FInstallments: Integer;
    FItems: TObjectList<TCieloDeeplinkItem>;
    FPaymentCode: TCieloPaymentCode;
    FValue: Currency;
    FCallbackScheme: string;
    FCallbackHost: string;
    procedure Validate;

  public
    constructor Create;
    destructor Destroy; override;

    function ToJson: string;
    function Tobase64: string;
    // Propriedades principais
    property AccessToken: string read FAccessToken write FAccessToken;
    property ClientID: string read FClientID write FClientID;
    property Reference: string read FReference write FReference;
    property MerchantCode: string read FMerchantCode write FMerchantCode;
    property Email: string read FEmail write FEmail;
    property Installments: Integer read FInstallments write FInstallments;
    property Items: TObjectList<TCieloDeeplinkItem> read FItems;
    property PaymentCode: TCieloPaymentCode read FPaymentCode write FPaymentCode;
    property Value: Currency read FValue write FValue;

    // Propriedades do callback
    property CallbackScheme: string read FCallbackScheme write FCallbackScheme;
    property CallbackHost: string read FCallbackHost write FCallbackHost;
  end;

implementation

uses
  System.JSON.Types, System.SysConst, System.NetEncoding;

{ TCieloDeeplinkItem }

function TCieloDeeplinkItem.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('name', Name);
  Result.AddPair('quantity', TJSONNumber.Create(Quantity));
  Result.AddPair('sku', SKU);
  Result.AddPair('unitOfMeasure', UnitOfMeasure);

end;

procedure TCieloDeeplinkItem.Validate;
begin
  if Trim(Name) = '' then
    raise Exception.Create('O campo "name" do item é obrigatório.');

  if Quantity <= 0 then
    raise Exception.Create('O campo "quantity" do item deve ser maior que zero.');

  if Trim(SKU) = '' then
    raise Exception.Create('O campo "sku" do item é obrigatório.');

  if Trim(UnitOfMeasure) = '' then
    raise Exception.Create('O campo "unitOfMeasure" do item é obrigatório.');

  if UnitPrice <= 0 then
    raise Exception.Create('O campo "unitPrice" do item deve ser maior que zero.');
end;


{ TCieloDeeplinkPayment }

constructor TCieloDeeplinkPayment.Create;
begin
  FItems := TObjectList<TCieloDeeplinkItem>.Create(True);
end;

destructor TCieloDeeplinkPayment.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TCieloDeeplinkPayment.Tobase64: string;
var
  JsonStr, Base64Str: string;
  Utf8Bytes: TBytes;
begin
  JsonStr := ToJson;
  Utf8Bytes := TEncoding.UTF8.GetBytes(JsonStr);
  result := TNetEncoding.Base64.EncodeBytesToString(Utf8Bytes);

end;

function TCieloDeeplinkPayment.ToJson: string;
var
  JSON: TJSONObject;
  ItemsArray: TJSONArray;
  Item: TCieloDeeplinkItem;
begin
  JSON := TJSONObject.Create;
  try

    Validate;

    JSON.AddPair('accessToken', FAccessToken);
    JSON.AddPair('clientID', FClientID);

    if FReference <> '' then
      JSON.AddPair('reference', FReference);

    if FMerchantCode <> '' then
      JSON.AddPair('merchantCode', FMerchantCode);

    JSON.AddPair('email', FEmail);
    JSON.AddPair('installments', TJSONNumber.Create(FInstallments));


    // Adiciona array de itens
    ItemsArray := TJSONArray.Create;
    for Item in FItems do
      ItemsArray.AddElement(Item.ToJson);
    JSON.AddPair('items', ItemsArray);

    JSON.AddPair('paymentCode', PaymentCodeToString(FPaymentCode));
    JSON.AddPair('value', TJSONNumber.Create(FValue));
    Result := JSON.ToJSON;
  finally
    JSON.Free;
  end;
end;

procedure TCieloDeeplinkPayment.Validate;
begin
  if Trim(FAccessToken) = '' then
    raise Exception.Create('AccessToken é obrigatório.');

  if Trim(FClientID) = '' then
    raise Exception.Create('ClientID é obrigatório.');

  if Trim(FEmail) = '' then
    raise Exception.Create('Email é obrigatório.');

  if FInstallments < 0 then
    raise Exception.Create('Número de parcelas inválido.');

  if not Assigned(FItems) or (FItems.Count = 0) then
    raise Exception.Create('Pelo menos um item é obrigatório.');

  if FValue <= 0 then
    raise Exception.Create('Valor da transação deve ser maior que zero.');
end;

end.

