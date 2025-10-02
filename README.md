# CieloDeeplink
Component CieloDeeplink for the Delphi

**Integração via Deeplink**

- Garantir a compatibilidade com o Android 10 (permissões, notificações, criação de intents, etc)
- Ter o minSdkVersion 24 e o targetSdkVersion 29
- Se estiver utilizando a integração via DeepLink [confira a documentação aqui](https://developercielo.github.io/manual/cielo-lio#credenciais), ter o metadado declarado no arquivo AndroidManifest.xml

## Manifest

É necessário definir um contrato de resposta com a LIO para que a mesma possa responder após o fluxo de pagamento/cancelamento/impressão. Esse contrato deve ser definido no manifest.xml da aplicação conforme o exemplo abaixo:

```html
<activity android:name=".ResponseActivity">
  <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:host="response" android:scheme="order" />
  </intent-filter>
</activity>
```

Os nomes “response” e “order” podem ser substituídos pelo que fizer sentido no seu aplicativo. Lembrando que na hora de fazer a chamada de pagamento, você deve informar os mesmos nomes para receber o callback da LIO. Para realizar o pedido de pagamento é preciso criar um json seguindo o formato definido abaixo e converte-lo para BASE64:

- Incluir nova tag no arquivo AndroidManifest.xml para que o App possa ser distribuído corretamente para os terminais no processo de publicação

```html
<meta-data
    android:name="cs_integration_type"
    android:value="uri" />
```
