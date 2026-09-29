# Roadmap — LOWDRUS INSTALLER

> Atualizado em 29/09/2026 após validações reais no Razer/Tahoe Recovery e auditoria pós-teste no Desktop. O roadmap separa itens **validados**, **em teste** e **pendentes**. Os comandos manuais usados durante desenvolvimento/auditoria não fazem parte do fluxo final para o usuário.

## Fase 1 — Bootstrap
- [x] Projeto de trabalho migrado para LOWDRUS-INSTALLER
- [x] EFI funcional preservada
- [x] mídia LOWDRUS preparada em GPT
- [x] EFI validada por SHA-256
- [x] InstallAssistant.pkg copiado e validado
- [x] identificar fortemente a mídia por tamanho/estrutura antes de operações destrutivas

## Fase 2 — Tahoe Builder, transporte e mídia offline
- [x] Investigar estrutura real do InstallAssistant.pkg
- [x] Confirmar comportamento Apple para SharedSupport.dmg
- [x] Reconstruir Tahoe Builder v0.1
- [x] Validar estrutura estática do Builder
- [x] Abandonar cópia direta do bundle para exFAT após falha
- [x] Encapsular Builder em TAR para transporte
- [x] Validar tamanho/hash do TAR na mídia de desenvolvimento
- [x] Confirmar leitura do TAR no Tahoe Recovery
- [x] Confirmar no Recovery que o TAR contém `Install macOS Tahoe.app`
- [x] Confirmar `Contents/Resources/createinstallmedia`
- [x] Confirmar `Contents/Resources/createinstallmedia.dylib`
- [x] Confirmar `Contents/SharedSupport/SharedSupport.dmg`
- [x] Confirmar acesso offline ao `InstallAssistant.pkg` (~17 GB) no Recovery
- [x] Confirmar acesso offline ao `Tahoe-Builder.tar` (~17 GB) no Recovery
- [x] Confirmar montagem/leitura do volume LOWDRUS no Tahoe Recovery
- [x] documentar incompatibilidade observada de adaptador/leitor USB e validação após troca do adaptador
- [x] Extrair/materializar Builder em filesystem macOS adequado sem destruir a mídia-mestre
- [x] Validar execução real de `createinstallmedia`
- [x] Criar mídia Tahoe inicializável com `createinstallmedia` (100%)
- [x] Validar boot offline da mídia até o Tahoe Recovery/Installer
- [ ] Validar instalação/reinstalação offline completa no Samsung — BLOQUEADA em verificação de SharedSupport/BaseSystem
- [ ] Validar preservação de dados no modo reinstalação/reparo quando aplicável

## Fase 3 — Engine sem Terminal
- [ ] implementar detector seguro de hardware/discos
- [ ] implementar identificação forte por modelo/serial/tamanho/partições
- [ ] impedir seleção acidental do SSD interno ou de outra mídia
- [ ] implementar preflight automático
- [ ] implementar validação de EFI/Builder/payload e hashes
- [ ] implementar diagnóstico por regras
- [ ] implementar auto-repair para erros conhecidos
- [ ] implementar revalidação pós-reparo
- [ ] implementar logs persistentes e exportação
- [ ] implementar backup/rollback
- [ ] detectar capacidades do Recovery/ambiente automaticamente
- [ ] detectar ausência/incompatibilidade de adaptador USB/storage
- [ ] suportar operação offline sem depender de Recovery pela internet
- [ ] eliminar Terminal do fluxo normal
- [ ] tornar reinicializações/retomada de estado automáticas

## Fase 4 — GUI LOWDRUS INSTALLER
- [x] base visual oficial / componente LOWDRUS GUI
- [x] regra de áudio: vídeo sempre mudo, sem volume
- [x] tela-base inicial/status
- [ ] Instalar macOS Tahoe
- [ ] Reinstalar/Reparar instalação existente
- [ ] Diagnóstico automático
- [ ] Reparar automaticamente
- [ ] Recuperação/rollback
- [ ] progresso e detalhes
- [ ] logs/relatórios
- [ ] Ferramentas avançadas
- [ ] console técnico opcional e escondido do fluxo normal
- [ ] bloquear operações destrutivas inseguras
- [ ] confirmações amigáveis sem exigir comandos do usuário
- [ ] mensagens claras para modo offline, mídia ausente e hardware incompatível

## Fase 5 — Perfil final do Razer
- [x] instalação/boot do Tahoe 26.7 (25G229)
- [ ] GPU Intel HD 4600 — validar aceleração/estabilidade final
- [x] NVIDIA GTX 860M — estratégia atual: desabilitada no macOS
- [ ] áudio
- [ ] Ethernet Realtek RTL8168
- [ ] Wi-Fi USB RTL8821CU (VID 0BDA / PID C820) — prioridade atual
- [ ] Bluetooth USB do combo RTL8821CU
- [ ] Bluetooth interno Intel AC7260
- [ ] Wi-Fi interno Intel AC7260
- [ ] USB — mapa/portas e estabilidade
- [ ] energia/sleep/wake
- [ ] bateria/SMC
- [ ] teclado/trackpad
- [ ] brilho/tela
- [ ] pós-instalação
- [ ] inventário completo
- [ ] perfil versionado com versões exatas, hashes e rollback
- [ ] teste de cold boot/reboot/shutdown
- [ ] teste de atualização do macOS sem perder boot/perfil

## Fase 6 — Root patches e compatibilidade Tahoe
- [x] preparar EFI candidata com `AMFIPass.kext` em laboratório Windows
- [x] validar candidata com `ocvalidate` 1.0.7
- [x] preservar EFI anterior do Kingston como `EFI-BACKUP-PRE-AMFIPASS-PC`
- [x] copiar candidata ao Kingston `LWIFI_TEST`
- [x] validar `config.plist` instalado no Kingston e conferir SHA-256 idêntico à candidata
- [ ] inicializar o Razer pela EFI candidata com AMFIPass e registrar o resultado
- [ ] confirmar se AMFIPass realmente carrega/atua no Tahoe 26.7
- [ ] recuperar/validar boot estável após qualquer root patch aplicado
- [ ] identificar exatamente todas as alterações feitas pelo OCLP-Mod/root patch
- [ ] criar procedimento de rollback reproduzível antes de aplicar patches
- [ ] validar AMFI/SIP/boot-args necessários e reduzir exceções ao mínimo
- [ ] validar root patches isoladamente antes de incorporá-los ao LOWDRUS final
- [ ] impedir aplicação automática de patch incompatível
- [ ] registrar snapshot/backup antes e resultado depois de cada patch

## Fase 7 — Recuperação interna
- [ ] projetar partição/volume interno
- [ ] preservar recuperação em reinstalações
- [ ] testar boot sem mídia LOWDRUS externa
- [ ] manter Netac/mídia externa de emergência enquanto necessário
- [ ] validar recuperação de EFI quebrada
- [ ] validar recuperação de sistema que não inicia

## Fase 8 — Atualização segura
- [ ] capturar configuração conhecida como funcional
- [ ] versionar EFI/OpenCore/ACPI/kexts/configurações e hashes
- [ ] GitHub Releases + manifesto de compatibilidade
- [ ] backup transacional
- [ ] validação pós-update
- [ ] rollback automático
- [ ] bloquear atualização incompatível com hardware/macOS

## Fase 9 — Testes de instalação e desastre
- [ ] instalação limpa completa sem Terminal
- [ ] reinstalação preservando dados quando suportada
- [ ] instalação totalmente offline — boot/Recovery PASS; instalação completa ainda FAIL
- [ ] recuperação após EFI inválida
- [ ] recuperação após root patch incompatível
- [ ] recuperação após interrupção/reboot inesperado
- [ ] validar mídia em portas/adaptadores USB compatíveis
- [ ] validar logs suficientes para diagnóstico por outro usuário
- [ ] repetir instalação do zero para provar reprodutibilidade

## Fase 10 — Evolução futura do LOWDRUS INSTALLER
- [ ] formato de Hardware Profile reutilizável
- [ ] matriz de compatibilidade
- [ ] estudar perfis adicionais somente após o Razer/Tahoe estar estável
- [ ] estudar outros macOS como perfis separados, sem presumir compatibilidade

## Fase 11 — Suporte remoto opcional
- [ ] validar Realtek RTL8168 no ambiente necessário
- [ ] validar Intel AC7260 ou alternativa
- [ ] serviço remoto autenticado quando houver rede
- [ ] continuidade de logs entre reinicializações
- [ ] modo totalmente offline
- [ ] garantir que suporte remoto nunca seja requisito para instalar/recuperar

## Checkpoint de rede — 25/09/2026
- [x] RTL8821CU confirmado no Windows e no USB do Tahoe
- [x] V17 auditado; o dispositivo `0BDA:C820` está presente no `RtWlanU.kext`
- [x] TESTE-07 inicializa Tahoe sem quebrar o boot
- [x] kernel confirmou tentativa de carga do `RtWlanU`
- [x] causa atual identificada: dependência `com.apple.iokit.IOUSBFamily` não resolvida no Tahoe
- [x] TESTE-08 criado para investigação isolada
- [x] dependências de `RtWlanU.kext` e `RtWlanU1827.kext` auditadas; ambos declaram `com.apple.iokit.IOUSBFamily = 1.8`
- [ ] isolar solução de compatibilidade USB/Tahoe antes de qualquer novo root patch

## Checkpoint AMFIPass — 28/09/2026
- [x] EFI candidata criada em `C:\OCLP-AUDIT\EFI-CANDIDATA-AMFIPASS`
- [x] `AMFIPass.kext` presente na candidata
- [x] `ocvalidate` 1.0.7 aprovou a candidata
- [x] EFI anterior do Kingston preservada como `G:\EFI-BACKUP-PRE-AMFIPASS-PC`
- [x] candidata copiada para `G:\EFI`
- [x] `BOOTx64.efi`, `OpenCore.efi`, `Lilu.kext` e `AMFIPass.kext` verificados na nova EFI
- [x] `G:\EFI\OC\config.plist` validado novamente por `ocvalidate`
- [x] SHA-256 da candidata e da cópia instalada coincidem: `E31743DF2BBC6973204B19996C211EEE84743B317E45426CC8EB647C15C3C770`
- [ ] bootar o Razer com esta EFI e registrar resultado real
- [ ] confirmar efeito sobre AMFI e compatibilidade do root patch
- [ ] confirmar se a solução permite carregar os kexts Realtek no Tahoe 26.7

## Checkpoint LOWDRUS/Toshiba — 28–29/09/2026
- [x] Toshiba/LOWDRUS enumerado no Tahoe Recovery após troca do adaptador/leitor USB
- [x] GPT e partições LOWDRUS_EFI + LOWDRUS preservadas
- [x] volume LOWDRUS montado e legível no Recovery
- [x] InstallAssistant.pkg acessível offline
- [x] Tahoe-Builder.tar acessível offline
- [x] bundle `Install macOS Tahoe.app` confirmado dentro do TAR
- [x] `createinstallmedia`, `.dylib` e `SharedSupport.dmg` confirmados
- [x] materialização real do `Install macOS Tahoe.app` concluída
- [x] `createinstallmedia` executado até 100%; mídia reportada como `Install macOS Tahoe`
- [x] boot pelo OpenCore/NETAC e seleção de `Install macOS Tahoe (external)` aprovados
- [x] Tahoe Recovery/Installer carregado a partir da mídia externa
- [x] destino `Macintosh HD` reconhecido e instalação iniciada
- [x] falha reproduzida durante instalação: mensagem gráfica `instalador está danificado`
- [x] logs localizaram a etapa crítica em `Verifying SharedSupport.dmg` / `OSISVerifyBaseSystemOperation`
- [x] log também registrou falha de verificação de relógio com `apple.com` no ambiente sem rede
- [x] HD SATA/KP-HD843 permaneceu enumerado após a falha; comportamento RGB não é tratado como evidência de defeito
- [x] leitura sustentada completa registrada no ciclo #29X: 18.381.960.622 bytes em 74,22 s após mudança de porta USB
- [x] nova leitura sustentada registrada: 18.437.734.400 bytes em ~74,94 s
- [x] pós-teste no Desktop: Toshiba identificado por modelo/serial/tamanho e preservado sem formatação
- [x] `Tahoe-Builder.tar` revalidado: 18.437.734.400 bytes; SHA-256 `7EA862E4FB009E5E7AEBCA7F9A43B0AA8471149084841CBEF95F19BEA8EE53B4`
- [x] `InstallAssistant.pkg` revalidado: 18.381.960.622 bytes; SHA-256 `23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE`
- [x] `bsdtar 3.8.8` confirmado no Desktop
- [x] `SharedSupport.dmg` localizado dentro do TAR em `Install macOS Tahoe.app/Contents/SharedSupport/SharedSupport.dmg`
- [x] tentativa #30Q.1 de extração para `C:\LOWDRUS-AUDIT` diagnosticada como incompleta por `No space left on device`
- [x] hash `BA567583DC0CD4D86EE2D077BC0E5AA431FC7D5FAE0FA9C450B138D2E6C3BA80` INVALIDADO: pertence à cópia truncada de 6.564.912.640 bytes, não ao DMG completo
- [x] regra de armazenamento: `C:` está criticamente cheio e não deve receber payloads/DMGs/TARs grandes; usar `F:\PROJETO\TRIBOOT`/NVMe para workspace pesado após auditoria do conteúdo existente
- [x] #30R: `F:\PROJETO\TRIBOOT` auditado; `TAHOE-OFFLINE` = 17,126 GB, `TAHOE-REBUILD` = 17,289 GB, `LOWDRUS-INSTALLER` = 0,004 GB; F: tinha ~915,80 GB livres
- [x] #30S: `SharedSupport.dmg` completo já localizado no workspace existente, sem nova extração: `F:\PROJETO\TRIBOOT\TAHOE-REBUILD\LOWDRUS-TAHOE-BUILDER\Applications\Install macOS Tahoe.app\Contents\SharedSupport\SharedSupport.dmg`
- [x] #30T: `SharedSupport.dmg` = 18.381.960.622 bytes; SHA-256 `23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE`
- [x] #30T: `G:\InstallAssistant.pkg` = 18.381.960.622 bytes; SHA-256 `23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE`
- [x] #30T: comprovado que o `SharedSupport.dmg` do Builder e o `InstallAssistant.pkg` são IDENTICOS BIT-A-BIT. Este fato, isoladamente, não prova erro de reconstrução: fluxos conhecidos de construção de InstallAssistant usam `InstallAssistant.pkg` como `Contents/SharedSupport/SharedSupport.dmg`; a investigação deve agora validar se o PKG original é íntegro/esperado e se os metadados auxiliares necessários ao Tahoe 26.7 estão presentes.
- [ ] validar integridade/origem Apple do `InstallAssistant.pkg` usando metadados de integridade disponíveis para o produto, se presentes
- [ ] auditar arquivos auxiliares/metadados esperados ao lado de `SharedSupport.dmg` no Builder
- [ ] comparar a origem do SharedSupport com a mídia criada pelo `createinstallmedia`
- [ ] resolver `OSISVerifyBaseSystemOperation` e provar instalação offline completa
- [ ] integrar o procedimento à Engine/GUI sem Terminal

## Fora do escopo deste repositório

O LOWDRUS INSTALLER aqui documentado pertence ao fluxo **Razer + macOS Tahoe**. O projeto maior terá outros dois sistemas operacionais e um futuro menu principal com IA para os três sistemas. Esses componentes não devem ser misturados neste repositório.
