unit Cielo.Deeplink.Types;

interface


type
  TCieloPaymentCode = (
    pcDebitoAVista,
    pcDebitoPagtoFaturaDebito,
    pcCreditoAVista,
    pcCreditoParceladoLoja,
    pcCreditoParceladoBnco,
    pcCreditoParceladoAdm,
    pcCreditoParceladoCliente,
    pcPreAutorizacao,
    pcCreditoCrediarioCredito,
    pcCrediarioVenda,
    pcCrediarioSimulacao,
    pcCartaoLojaAVista,
    pcCartaoLojaParcelado,
    pcCartaoLojaParceladoLoja,
    pcCartaoLojaParceladoBanco,
    pcCartaoLojaPagtoFaturaDinheiro,
    pcCartaoLojaPagtoFaturaCheque,
    pcVoucherAlimentacao,
    pcVoucherRefeicao,
    pcVoucherAutomotivo,
    pcVoucherCultura,
    pcVoucherBeneficios,
    pcVoucherPedagio,
    pcVoucherConsultaSaldo,
    pcVoucherValePedagio,
    pcVoucherAuto,
    pcFrotas,
    pcPix
  );

  TCieloPrintCode= (pcPrintText,pcPrintMultiText,pcPrintImage);
  TCieloAlign = (caCenter, caLeft, caRight);
  TCieloTypeface = 0..8;
type
  TCieloPrintKey = (
    key_attributes_align,
    key_attributes_textsize,
    key_attributes_typeface,
    key_attributes_marginleft,
    key_attributes_marginright,
    key_attributes_margintop,
    key_attributes_marginbottom,
    key_attributes_linespace,
    key_attributes_weight,
    form_feed
  );



function PaymentCodeToString(Code: TCieloPaymentCode): string;
function PrintCode(Code: TCieloPrintCode): string;
function PrintKey(Key: TCieloPrintKey): string;

implementation

function PaymentCodeToString(Code: TCieloPaymentCode): string;
begin
  case Code of
    pcDebitoAVista:                  Result := 'DEBITO_AVISTA';
    pcDebitoPagtoFaturaDebito:      Result := 'DEBITO_PAGTO_FATURA_DEBITO';
    pcCreditoAVista:                Result := 'CREDITO_AVISTA';
    pcCreditoParceladoLoja:         Result := 'CREDITO_PARCELADO_LOJA';
    pcCreditoParceladoBnco:         Result := 'CREDITO_PARCELADO_BNCO';
    pcCreditoParceladoAdm:          Result := 'CREDITO_PARCELADO_ADM';
    pcCreditoParceladoCliente:      Result := 'CREDITO_PARCELADO_CLIENTE';
    pcPreAutorizacao:               Result := 'PRE_AUTORIZACAO';
    pcCreditoCrediarioCredito:      Result := 'CREDITO_CREDIARIO_CREDITO';
    pcCrediarioVenda:               Result := 'CREDIARIO_VENDA';
    pcCrediarioSimulacao:           Result := 'CREDIARIO_SIMULACAO';
    pcCartaoLojaAVista:             Result := 'CARTAO_LOJA_AVISTA';
    pcCartaoLojaParcelado:          Result := 'CARTAO_LOJA_PARCELADO';
    pcCartaoLojaParceladoLoja:      Result := 'CARTAO_LOJA_PARCELADO_LOJA';
    pcCartaoLojaParceladoBanco:     Result := 'CARTAO_LOJA_PARCELADO_BANCO';
    pcCartaoLojaPagtoFaturaDinheiro:Result := 'CARTAO_LOJA_PAGTO_FATURA_DINHEIRO';
    pcCartaoLojaPagtoFaturaCheque:  Result := 'CARTAO_LOJA_PAGTO_FATURA_CHEQUE';
    pcVoucherAlimentacao:           Result := 'VOUCHER_ALIMENTACAO';
    pcVoucherRefeicao:              Result := 'VOUCHER_REFEICAO';
    pcVoucherAutomotivo:            Result := 'VOUCHER_AUTOMOTIVO';
    pcVoucherCultura:               Result := 'VOUCHER_CULTURA';
    pcVoucherBeneficios:            Result := 'VOUCHER_BENEFICIOS';
    pcVoucherPedagio:               Result := 'VOUCHER_PEDAGIO';
    pcVoucherConsultaSaldo:         Result := 'VOUCHER_CONSULTA_SALDO';
    pcVoucherValePedagio:           Result := 'VOUCHER_VALE_PEDAGIO';
    pcVoucherAuto:                  Result := 'VOUCHER_AUTO';
    pcFrotas:                       Result := 'FROTAS';
    pcPix:                          Result := 'PIX';
  else
    Result := '';
  end;
end;

function PrintCode(Code: TCieloPrintCode): string;
begin
    case Code of
    pcPrintText:                 Result := 'PRINT_TEXT';
    pcPrintMultiText:            Result := 'PRINT_MULTI_COLUMN_TEXT';
    pcPrintImage:                Result := 'PRINT_IMAGE';

  else
    Result := '';
  end;
end;

function PrintKey(Key: TCieloPrintKey): string;
begin
  case Key of
    key_attributes_align:       Result := 'key_attributes_align';
    key_attributes_textsize:    Result := 'key_attributes_textsize';
    key_attributes_typeface:    Result := 'key_attributes_typeface';
    key_attributes_marginleft:  Result := 'key_attributes_marginleft';
    key_attributes_marginright: Result := 'key_attributes_marginright';
    key_attributes_margintop:   Result := 'key_attributes_margintop';
    key_attributes_marginbottom:Result := 'key_attributes_marginbottom';
    key_attributes_linespace:   Result := 'key_attributes_linespace';
    key_attributes_weight:      Result := 'key_attributes_weight';
    form_feed:                  Result := 'form_feed';
  else
    Result := '';
  end;
end;
end.

