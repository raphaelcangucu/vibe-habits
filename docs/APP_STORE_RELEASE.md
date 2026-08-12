# Publicação do Vibe Habits na App Store

Este projeto envia toda nova tag semântica (`vMAJOR.MINOR.PATCH`) ao App Store Connect/TestFlight usando Fastlane e GitHub Actions. A liberação pública permanece manual no App Store Connect, o que evita publicar uma versão acidentalmente e permite revisar screenshots, metadados e respostas legais antes de cada envio à revisão.

## 1. Confirmar a identidade do app

O app foi criado na conta pessoal de Raphael Cangucu com o Bundle ID `app.vibehabits.ios` e o App Store Connect ID `6800547603`. Depois que o primeiro build for enviado, o Bundle ID do registro do App Store Connect não poderá ser alterado.

O projeto está configurado com:

- Nome na App Store: `Vibe Habits: Habit Tracker`
- Nome no dispositivo: `Vibe Habits`
- Bundle ID: `app.vibehabits.ios`
- App Store Connect ID: `6800547603`
- Apple Developer Team ID: `SB6QYUH97U`
- Categoria: Lifestyle
- Versão derivada da tag, por exemplo `v1.0.2` vira `1.0.2`
- Build derivado de `GITHUB_RUN_NUMBER.GITHUB_RUN_ATTEMPT`

## 2. Preparação única na Apple

1. Mantenha ativa a assinatura do Apple Developer Program e aceite contratos pendentes.
2. O App ID explícito `app.vibehabits.ios` já está registrado no time pessoal `SB6QYUH97U`.
3. O app `Vibe Habits: Habit Tracker` já está criado no App Store Connect com o SKU `vibe-habits-ios`.
4. A Team API Key `Vibe Habits CI` foi criada com acesso `App Manager`. O arquivo `.p8` deve permanecer fora do repositório; a Apple permite baixá-lo apenas uma vez.
5. O repositório privado `raphaelcangucu/vibe-habits-certificates` guarda o certificado e o provisioning profile criptografados pelo Fastlane Match. O GitHub Actions acessa esse repositório por uma deploy key somente leitura.

## 3. Inicializar a assinatura com Fastlane Match

Instale as dependências:

```sh
bundle install
cp .env.example .env
```

Preencha `.env` sem commitá-lo. Para converter a chave `.p8` em Base64 no macOS:

```sh
base64 -i /caminho/para/AuthKey_XXXXXXXXXX.p8 | pbcopy
```

Com `.env` preenchido, crie o certificado Apple Distribution e o provisioning profile:

```sh
bundle exec fastlane ios bootstrap_signing
```

Essa inicialização já foi concluída para o bundle atual. O Match criptografa o material de assinatura usando `MATCH_PASSWORD` antes de gravá-lo no repositório privado. A senha também foi salva no Chaves do macOS com o serviço `vibe-habits-fastlane-match` para recuperação local.

## 4. Secrets do GitHub Actions

Em Settings > Secrets and variables > Actions, adicione estes repository secrets:

| Secret | Valor |
| --- | --- |
| `APP_STORE_CONNECT_KEY_ID` | ID da API Key |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID da API Key |
| `APP_STORE_CONNECT_KEY_CONTENT_BASE64` | Conteúdo Base64 do arquivo `.p8` |
| `MATCH_GIT_URL` | URL SSH do repositório privado de certificados |
| `MATCH_GIT_PRIVATE_KEY_BASE64` | Chave SSH privada da deploy key somente leitura, em Base64 |
| `MATCH_PASSWORD` | Senha forte usada para criptografar o Match |

Esses secrets já estão configurados no repositório `raphaelcangucu/vibe-habits`. O workflow usa o Match em modo somente leitura: ele não cria nem revoga certificados durante o CI.

## 5. Criar um release

Faça o merge das mudanças desejadas e crie uma nova tag anotada:

```sh
git tag -a v1.0.2 -m 'Vibe Habits 1.0.2'
git push origin v1.0.2
```

O workflow `.github/workflows/ios-release.yml` irá:

1. validar o formato da tag;
2. executar os testes unitários obrigatórios;
3. baixar certificado e profile do Match para um keychain temporário;
4. gerar o archive Release com a versão da tag;
5. enviar o `.ipa` ao App Store Connect/TestFlight.

Tags como `release-1.0.2` ou `v1.0` falham de propósito. Em uma reexecução, o sufixo `GITHUB_RUN_ATTEMPT` produz um novo número de build.

## 6. Completar a primeira ficha da App Store

Antes de enviar à análise, complete no App Store Connect:

- descrição, subtítulo, palavras-chave, URL de suporte e copyright;
- política de privacidade: `https://github.com/raphaelcangucu/vibe-habits/blob/main/PRIVACY.md`;
- App Privacy: para o código atual, selecione que o app não coleta dados, pois hábitos e fotos permanecem no dispositivo e não há analytics, anúncios ou tracking;
- questionário atualizado de classificação etária;
- disponibilidade, preço (gratuito, se essa for a escolha) e status de comerciante para distribuição na União Europeia;
- de 1 a 10 screenshots sem transparência. Como o app suporta iPhone e iPad, envie os conjuntos obrigatórios exibidos pelo App Store Connect para ambos;
- informações de revisão: o app não exige login, funciona offline, câmera/fotos são opcionais e as notificações são locais;
- selecione o build processado pelo TestFlight e escolha liberação manual, automática ou gradual.

Depois, use **Add for Review** e **Submit for Review**. A publicação automática direta pode ser habilitada no Fastlane após a primeira versão aprovada e depois que screenshots e metadados estiverem versionados no repositório.

## 7. Validação local

Os testes podem ser executados sem credenciais da Apple:

```sh
bundle exec fastlane ios test
```

Os testes de interface ficam disponíveis separadamente, pois não bloqueiam o envio de uma tag:

```sh
bundle exec fastlane ios ui_tests
```

Um release local requer todas as variáveis de `.env` e uma tag informada por `RELEASE_TAG`.
