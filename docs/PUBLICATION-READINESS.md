# Vibe Habits — preparação de publicação

Avaliação: 5 de outubro de 2026. **Preparação local concluída; publicação bloqueada por contrato Apple obrigatório pendente ou expirado.**

## Aplicativo localizado

Projeto `raphaelcangucu/vibe-habits`, app nativo SwiftUI/SwiftData. Nome existente: Vibe Habits: Habit Tracker. App Store Connect ID 6800547603. Conta pessoal Raphael Cangucu, time SB6QYUH97U. Bundle app.vibehabits.ios; widget app.vibehabits.ios.widget; App Group group.app.vibehabits.ios. Esta é a conta configurada no Mautic Inbox. O Civitas pertence ao time corporativo 7B8YANV6C8; a referência usada foi seu fluxo Fastlane, sem copiar suas credenciais.

## Entrega preparada

| Item | Evidência / estado |
| --- | --- |
| Certificado Apple Distribution | Identidade válida no keychain; assinatura final verificada |
| Profiles de app e widget | Time e App Group corretos; expiração 12/08/2027 |
| Archive e exportação | Release assinado, ambos concluídos com sucesso |
| IPA atualizado | artifacts/publication/Vibe-Habits-1.1.0-AppStore.ipa, versão 1.1.0, build 202610051340 |
| Manifestos de privacidade | App e widget declaram 1C8F.1 para UserDefaults no mesmo App Group |
| Teste nativo | Backup/restauração SwiftData em memória passou em iOS 26; nenhum banco Mautic acessado |
| Política de publicação | 6 testes, 9 asserções, zero falhas; também passou no GitHub Actions |
| Screenshots | 20 arquivos opacos: 5 iPhone 6,9″ e 5 iPad 13″ por idioma; 1320×2868 e 2064×2752 |
| Ficha | Português e inglês; campos de texto conferidos nos limites Apple |
| Suporte e privacidade | URLs públicas retornam HTTP 200 e são acessíveis pelo app |
| Fastlane / CI | Consulta somente leitura, atualização da ficha e submissão separadas; lançamento manual |
| Publicação remota | Não realizada nesta rodada; bloqueada pelo contrato Apple |

O manifesto anterior declarava CA92.1, embora o código use UserDefaults(suiteName:) para compartilhar o snapshot com o widget. Foi corrigido para 1C8F.1 em ambos os bundles, de acordo com a [definição oficial Apple](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype). O manifesto corrigido foi conferido dentro do IPA exportado. Não foram alteradas telas ou funcionalidades do app.

## Fluxo de publicação

1. `publication_status`: consulta a Apple e gera relatório de versões, builds, screenshots e submissões. Não exporta credenciais nem contatos.
2. `release`: testes, assinatura Match e envio ao TestFlight. Sem distribuição externa automática.
3. `store_listing`: atualiza ficha e screenshots, sem submeter à revisão.
4. `app_store_review`: usa o build VALID selecionado, sem reenviar binários ou screenshots; mantém liberação manual. Submissões em andamento/aprovadas não são duplicadas. Rejeições e pendências exigem correção prévia.

No GitHub Actions, o acionamento manual usa audit_only=true por padrão. Para atualizar materiais ou submeter, escolha explicitamente audit_only=false e o modo correspondente. Não foi criada nova tag nem disparado upload de release nesta rodada.

Referências: [Fastlane](https://docs.fastlane.tools/actions/upload_to_app_store/), [submissão Apple](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app), [dimensões de screenshots](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).

## Bloqueio comprovado e próximo passo

A consulta autenticada com os secrets já existentes retornou HTTP 403 e o código **FORBIDDEN.REQUIRED_AGREEMENTS_MISSING_OR_EXPIRED**. A mensagem Apple informa que a operação exige um contrato vigente, ainda não assinado ou expirado. Evidência: [execução de auditoria](https://github.com/raphaelcangucu/vibe-habits/actions/runs/37341753616). O mesmo run passou na validação da política e não executou os passos de upload ou submissão.

O titular precisa revisar e, se concordar, aceitar o contrato pendente em [App Store Connect — Agreements](https://appstoreconnect.apple.com/agreements) ou no [Apple Developer Account](https://developer.apple.com/account/). A aceitação é ação do titular; nenhuma chave foi revogada ou recriada.

Depois do aceite, repetir `publication_status` para conferir a situação atual. O último estado remoto conhecido, de agosto, indicava uma submissão em andamento; ele não prova o estado atual. Não retirar ou duplicar essa submissão sem inspecioná-la. Conferir também App Privacy, disponibilidade/preço e status de comerciante para a União Europeia. Definir a versão final com base na situação atual antes de enviar o novo build. O IPA local 1.1.0 é candidato preparado, não um build já selecionado/processado na Apple.

## Evidências locais

Em artifacts/publication/ (ignorado pelo Git): ipa-validation.json, local-assets-and-signing.json, archive.log, export.log, unit-tests.log, review-policy-tests.log e audit-final.log. O SHA-256 do IPA está em ipa-validation.json. Código e documentação estão na branch codex/publication-readiness. As mudanças precisam ser integradas à main para que o fluxo seja o padrão definitivo do projeto.
