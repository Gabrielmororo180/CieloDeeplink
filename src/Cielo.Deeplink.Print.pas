unit Cielo.Deeplink.Print;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.JSON,
  Cielo.Deeplink.Types;

type
  TCieloDeeplinkStyle = class
  public
    FValue: Integer;
    FKey: TCieloPrintKey;
    function ToJson: TJSONObject;
  end;

  TCieloDeeplinkStyleValue = class
  private
    FText: string;
    FStyles: TObjectList<TCieloDeeplinkStyle>;
  public
    constructor Create;
    destructor Destroy; override;
    property Text: string read FText write FText;
    property Styles: TObjectList<TCieloDeeplinkStyle> read FStyles;
  end;

  TCieloDeeplinkPrint = class
  private
    FItems: TObjectList<TCieloDeeplinkStyleValue>;
    FPrintCode: TCieloPrintCode;
    FCallbackScheme: string;
    FCallbackHost: string;
    procedure Validate;
  public
    constructor Create;
    destructor Destroy; override;
    function ToJson: string;
    property Items: TObjectList<TCieloDeeplinkStyleValue> read FItems;
    property PrintType: TCieloPrintCode read FPrintCode write FPrintCode;
    property CallbackScheme: string read FCallbackScheme write FCallbackScheme;
    property CallbackHost: string read FCallbackHost write FCallbackHost;
  end;

implementation

uses
  System.JSON.Types;

{ TCieloDeeplinkStyle }

function TCieloDeeplinkStyle.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair(PrintKey(FKey), TJSONNumber.Create(FValue));
end;

{ TCieloDeeplinkStyleValue }

constructor TCieloDeeplinkStyleValue.Create;
begin
  FStyles := TObjectList<TCieloDeeplinkStyle>.Create(True);
end;

destructor TCieloDeeplinkStyleValue.Destroy;
begin
  FStyles.Free;
  inherited;
end;

{ TCieloDeeplinkPrint }

constructor TCieloDeeplinkPrint.Create;
begin
  FItems := TObjectList<TCieloDeeplinkStyleValue>.Create(True);
end;

destructor TCieloDeeplinkPrint.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TCieloDeeplinkPrint.Validate;
begin



  if FItems.Count = 0 then
    raise Exception.Create('Pelo menos um item deve ser adicionado.');

 if FPrintCode=pcPrintImage then
  if not FileExists(FItems[0].Text) then
     raise Exception.Create('Imagem não encontrada.');


    if FPrintCode=pcPrintMultiText then
  for var Item in FItems do
  begin
    if Item.Styles.Count = 0 then
      raise Exception.Create('Cada item deve conter pelo menos um estilo.');
    if Trim(Item.Text) = '' then
      raise Exception.Create('Texto não pode estar vazio.');
  end;
end;

function TCieloDeeplinkPrint.ToJson: string;
var
  JSON: TJSONObject;
  StyleArray, ValueArray: TJSONArray;
  Item: TCieloDeeplinkStyleValue;
  Style: TCieloDeeplinkStyle;
  StyleObj: TJSONObject;
begin
  JSON := TJSONObject.Create;
  try
    Validate;

    JSON.AddPair('operation', PrintCode(FPrintCode));

    StyleArray := TJSONArray.Create;
    ValueArray := TJSONArray.Create;

    for Item in FItems do
    begin
      case FPrintCode of
        pcPrintMultiText:
        begin

          StyleObj := TJSONObject.Create;
          for Style in Item.Styles do
            StyleObj.AddPair(PrintKey(Style.FKey), TJSONNumber.Create(Style.FValue));
          StyleArray.AddElement(StyleObj);

          ValueArray.Add(Item.Text);
        end;

        pcPrintImage:
        begin

          if StyleArray.Count = 0 then
            StyleArray.AddElement(TJSONObject.Create);

          ValueArray.Add(Item.Text);
        end;


      end;
    end;

    JSON.AddPair('styles', StyleArray);
    JSON.AddPair('value', ValueArray);

    Result := JSON.ToJSON;
  finally
    JSON.Free;
  end;
end;

end.

