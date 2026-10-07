# Vibe Habits — preparação de publicação

Avaliação: 6 de outubro de 2026. **A resposta à Guideline 2.1 foi enviada com vídeo de aparelho físico e a versão 1.1.0 (6.1) foi reenviada. Estado confirmado: Waiting for Review.**

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
| Publicação remota | Versão 1.1.0 (6.1) reenviada em 06/10/2026; Waiting for Review; liberação manual |

O manifesto anterior declarava CA92.1, embora o código use UserDefaults(suiteName:) para compartilhar o snapshot com o widget. Foi corrigido para 1C8F.1 em ambos os bundles, de acordo com a [definição oficial Apple](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype). O manifesto corrigido foi conferido dentro do IPA exportado. Não foram alteradas telas ou funcionalidades do app.

## Fluxo de publicação

1. `publication_status`: consulta a Apple e gera relatório de versões, builds, screenshots e submissões. Não exporta credenciais nem contatos.
2. `release`: testes, assinatura Match e envio ao TestFlight. Sem distribuição externa automática.
3. `store_listing`: atualiza ficha e screenshots, sem submeter à revisão.
4. `app_store_review`: usa o build VALID selecionado, sem reenviar binários ou screenshots; mantém liberação manual. Exige IPA assinado e evidência física com hashes correspondentes. Submissões em andamento/aprovadas não são duplicadas. Rejeições e pendências exigem correção prévia.

No GitHub Actions, o acionamento manual usa audit_only=true por padrão. Tags criam o build, enviam ao TestFlight, sincronizam a ficha e preservam o IPA validado por 30 dias. A submissão à análise ocorre localmente pelo Fastlane somente depois do teste físico; a publicação pública permanece manual.

Referências: [Fastlane](https://docs.fastlane.tools/actions/upload_to_app_store/), [submissão Apple](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/submit-an-app), [dimensões de screenshots](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).

## Histórico e estado atual

A primeira consulta autenticada retornou **FORBIDDEN.REQUIRED_AGREEMENTS_MISSING_OR_EXPIRED**. Depois que o titular aceitou o contrato, o acesso pela mesma Team API Key foi liberado, sem revogar ou recriar credenciais. A [consulta completa de 05/10/2026](https://github.com/raphaelcangucu/vibe-habits/actions/runs/37343268970) confirmou a versão 1.1.0, lançamento manual, build 6.1 processado e os materiais dos dois idiomas.

Em 06/10/2026, a mensagem da Apple foi lida: a rejeição pela Guideline 2.1 solicitava informações completas e uma gravação em aparelho físico. As App Review Notes foram preenchidas, a gravação do iPhone 17 Pro com iOS 26.6.2 foi anexada à versão e à resposta, e a submissão foi atualizada e reenviada. O navegador e a consulta Fastlane posterior confirmaram **WAITING_FOR_REVIEW** para 1.1.0 (6.1). A lane `app_store_review` também reconheceu o estado e encerrou sem criar submissão duplicada.

O build 6.1 continua sendo o binário sob análise. O IPA local com build 202610051340 e manifesto de privacidade corrigido é uma evidência separada e não deve ser confundido com o binário selecionado pela Apple. Se uma futura resposta exigir mudança de código ou manifesto, será necessário gerar e selecionar um build novo. O próximo passo agora é aguardar a decisão da Apple; a liberação pública permanecerá manual.

## Evidências locais

Em artifacts/publication/ (ignorado pelo Git): ipa-validation.json, local-assets-and-signing.json, archive.log, export.log, unit-tests.log, review-policy-tests.log e audit-final.log. O SHA-256 do IPA está em ipa-validation.json. Código e documentação estão na branch codex/publication-readiness. As mudanças precisam ser integradas à main para que o fluxo seja o padrão definitivo do projeto.

O acionamento manual de build usa a versão solicitada como `RELEASE_TAG`, e a concorrência é serializada por aplicativo entre branches. A numeração de builds usa o mesmo relógio UTC (`YYYYMMDDHHmm`) localmente e no CI. O próximo upload deve ter número maior que qualquer candidato previamente enviado na mesma versão.
