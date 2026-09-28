# LOWDRUS INSTALLER — Estado consolidado de desenvolvimento — 28/09/2026

Este documento consolida decisões, checkpoints e restrições que surgiram durante o desenvolvimento real e que não devem se perder entre sessões de teste.

## Escopo deste repositório

Este repositório é dedicado ao **LOWDRUS INSTALLER para macOS Tahoe no Razer Blade Pro RZ09-0117 (2014)**.

O projeto maior de multiboot/tri-boot do notebook é separado. O futuro menu principal, Windows 11, SteamOS e recursos de seleção por IA/voz não devem ser misturados com este repositório enquanto o escopo Tahoe/Razer estiver sendo estabilizado.

## Arquitetura do produto

O LOWDRUS deve evoluir como ecossistema com as seguintes camadas:

- **LOWDRUS Engine** — detecção, validação, diagnóstico, automação, logs, backup, rollback, reparo e atualização.
- **LOWDRUS GUI** — interface principal para o usuário; Terminal não deve fazer parte do fluxo normal.
- **Razer Hardware Profile** — EFI/OpenCore, ACPI, kexts, propriedades, testes e pós-instalação específicos do RZ09-0117.
- **Tahoe OS Profile / Builder** — preparação e validação do instalador offline.
- **Recovery** — mídia externa e futura recuperação interna.
- **Update Engine** — GitHub Releases, manifesto, hashes, compatibilidade, backup, validação e rollback.

## Hardware-alvo conhecido

- Razer Blade Pro RZ09-0117 (2014)
- Intel Core i7-4700HQ / Haswell
- 16 GB RAM
- Intel HD Graphics 4600
- NVIDIA GTX 860M — desabilitada no macOS durante os testes atuais
- Samsung SATA SSD 512 GB interno
- Intel AC7260 Wi-Fi/Bluetooth interno
- Realtek RTL8168 Ethernet
- adaptador USB Realtek RTL8821CU Wi-Fi/Bluetooth, VID `0BDA`, PID `C820`
- teclado externo Razer BlackWidow Tournament Edition V2 durante parte da configuração

## Sistema validado até aqui

- macOS Tahoe 26.7
- build `25G229`
- OpenCore 1.0.7
- SMBIOS MacBookPro11,2
- SecureBootModel Disabled
- Vault Optional
- SIP observado como habilitado antes da linha de investigação de root patches

### Atenção a boot-args

A documentação do perfil deve sempre refletir o `config.plist` efetivamente validado, e não transcrições antigas ou anotações de memória. Qualquer divergência entre backup funcional, EFI de teste e notas deve ser resolvida pela leitura do arquivo efetivamente usado no boot correspondente.

No baseline funcional auditado durante a investigação foram observados:

```text
-v debug=0x100 keepsyms=1 -wegnoegpu -no_compat_check
```

Não adicionar `revpatch=sbvmm` ao perfil final sem confirmar que ele está realmente presente no `config.plist` do checkpoint que será promovido a funcional.

## Estado gráfico atual

No Tahoe instalado, a Intel HD Graphics 4600 foi observada com:

- VRAM total: 7 MB
- Device ID: `0x0412`
- Revision ID: `0x0006`
- resolução 1920×1080 @ 60 Hz
- sem kext gráfico carregado segundo System Information naquele checkpoint

O baseline conhecido usava:

- `AAPL,ig-platform-id`: bytes `05 00 26 0A`
- `device-id`: bytes `12 04 00 00`

Foi criado um experimento separado `EFI-HD4600-TESTE-03` alterando somente o platform-id para `06 00 26 0A`, mantendo o device-id. Esse experimento não deve ser confundido com correção final e não foi promovido a perfil funcional.

Aceleração Haswell no Tahoe permanece pendente e deverá ser tratada separadamente da rede.

## Ordem de trabalho de rede adotada

Durante a fase atual foi definida esta ordem:

1. USB Wi-Fi + Bluetooth RTL8821CU
2. Ethernet RTL8168
3. Bluetooth interno AC7260
4. Wi-Fi interno AC7260

A Ethernet foi investigada e depois estacionada para concentrar os testes no Wi-Fi USB.

## Checkpoint Ethernet

- `RealtekRTL8111.kext` 2.4.2 carregou no Tahoe
- interface `en0` apareceu
- estado físico permaneceu `inactive`
- sem LEDs no RJ45 do notebook/roteador no teste registrado
- TESTE-06 com RealtekRTL8111 3.0.0 também iniciou, mas permaneceu sem link

Não promover nenhuma das duas versões como solução final de Ethernet com base apenas nesses testes.

## Checkpoint Intel AC7260 Wi-Fi

Foi criado `EFI-WIFI-AC7260-TESTE-04` usando `itlwm.kext` 2.3.0. Tahoe iniciou, mas a interface Wi-Fi não se tornou funcional. Como essa versão do itlwm não representa suporte Tahoe validado, o teste permanece arquivado e a AC7260 está atrás do USB Realtek na prioridade atual.

## Checkpoint RTL8821CU

A investigação completa do adaptador USB está registrada em `docs/NETWORK-RTL8821CU-TAHOE.md`.

Pontos principais:

- VID/PID 0BDA:C820 confirmados
- interface Wi-Fi MI_02 e Bluetooth MI_00 no Windows
- produto USB enumera no Tahoe
- V17 auditado
- TESTE-07 confirmou tentativa de carga do `RtWlanU`
- falha: dependência `com.apple.iokit.IOUSBFamily` ausente/não resolvida
- TESTE-08 criado como laboratório separado
- AMFIPass passou a ser investigado como parte da compatibilidade/root patch, sem ser considerado solução validada ainda

## Mídias e regras de segurança

### Netac

A mídia Netac/OpenCore conhecida como funcional é contingência de recuperação. Regra operacional: **não modificar casualmente a Netac** durante experimentos.

### Kingston `LWIFI_TEST`

Usado como mídia experimental de EFI.

Identificação conhecida:

- Kingston DT 101 G2
- label `LWIFI_TEST`
- serial `001CC0C61232EC3113120095`
- volume FAT32 observado com 15,588,130,816 bytes

A letra de unidade é transitória. Reidentificar por múltiplos atributos antes de alterar EFI ou executar operação destrutiva.

### SSD externo LOWDRUS (Lexar)

O dispositivo Lexar usado no fluxo do instalador deve ser referido como **SSD externo LOWDRUS (Lexar)**, não como pendrive.

### Samsung interno

O SSD Samsung interno com Tahoe instalado não deve ser apagado durante experimentos de EFI/rede. Operações destrutivas devem exigir identificação forte e confirmação apropriada.

## Tahoe Builder / modo offline

Payload original validado:

- Tahoe 26.7 build 25G229
- `InstallAssistant.pkg`
- tamanho observado: 18,381,960,622 bytes
- SHA-256: `23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE`

Tahoe Builder transportado em TAR:

- `Tahoe-Builder.tar`
- tamanho: 18,437,734,400 bytes
- SHA-256: `7EA862E4FB009E5E7AEBCA7F9A43B0AA8471149084841CBEF95F19BEA8EE53B4`

No Tahoe Recovery foram observados dentro do bundle:

- `Install macOS Tahoe.app/Contents/Resources/createinstallmedia`
- `Install macOS Tahoe.app/Contents/Resources/createinstallmedia.dylib`
- `Install macOS Tahoe.app/Contents/SharedSupport/SharedSupport.dmg`

A execução final do Builder e a instalação/reinstalação offline integral ainda precisam ser validadas de ponta a ponta.

## GUI e experiência de uso

Decisão de produto: **o usuário final não deve viver no Terminal**.

O desenvolvimento pode usar PowerShell/Terminal para auditoria, mas o produto final deve oferecer GUI para:

- instalar Tahoe
- reinstalar/reparar
- diagnosticar
- aplicar correções conhecidas
- validar novamente
- mostrar progresso
- consultar/exportar logs
- recuperar/rollback
- atualizar o LOWDRUS

Um console técnico pode existir em Ferramentas avançadas, mas não como requisito para o fluxo comum.

### Windows Manager

Durante o desenvolvimento, a tentativa de interface PowerShell/WPF apresentou falhas de XAML. Para evolução do Manager, preferir uma implementação mais robusta, como WinForms ou WPF programático, em vez de depender de pequenos remendos em XAML frágil.

### Áudio/visual

A regra registrada para os vídeos/animações da GUI é mantê-los sem áudio/volume. O LOWDRUS não deve tocar música ou efeitos sonoros automaticamente.

## Logs, auditoria e rollback

O Engine final deve registrar, quando aplicável:

- máquina/perfil detectado
- disco e mídia selecionados
- modelo, serial e tamanho
- estrutura de partições
- hashes
- versões de OpenCore/kexts/componentes
- alterações aplicadas
- resultado de validações
- erros
- backups criados
- rollback disponível

Cada experimento crítico deve preservar uma linha de retorno conhecida antes de substituir a anterior.

## Convenção de experimentos

Durante o desenvolvimento foi adotada a ideia de criar EFIs/testes separados (`TESTE-03`, `TESTE-04`, `TESTE-06`, `TESTE-07`, `TESTE-08`) e mudar uma variável de cada vez sempre que possível.

Regra para o produto/engenharia:

- não alterar silenciosamente um checkpoint que já produziu evidência útil
- criar nova variante para experimento incompatível
- validar estrutura/configuração antes do boot
- manter backup da configuração anterior
- promover ao perfil final somente depois de boot + hardware + reboot/cold boot + rollback comprovados

## Estado da candidata AMFIPass em 28/09/2026

No Windows foi preparada uma EFI candidata com `AMFIPass.kext`.

Fluxo executado:

- `ocvalidate` 1.0.7 aprovou a candidata
- EFI anterior do Kingston foi renomeada/preservada como `EFI-BACKUP-PRE-AMFIPASS-PC`
- candidata copiada para `G:\EFI`
- estrutura mínima verificada
- `config.plist` da cópia instalada validado novamente
- SHA-256 da candidata e da cópia instalada: `E31743DF2BBC6973204B19996C211EEE84743B317E45426CC8EB647C15C3C770`

Isso é checkpoint de integridade no Windows, não validação funcional no Tahoe.

## Critérios para marcar perfil como funcional

O perfil Tahoe/Razer não deve ser classificado como final apenas porque inicia o sistema. Antes de promoção devem ser considerados, conforme o componente:

- boot estável
- cold boot/reboot/shutdown
- aceleração gráfica adequada
- rede validada
- áudio
- Bluetooth
- USB
- energia/sleep/wake
- bateria/SMC
- teclado/trackpad
- brilho/tela
- pós-instalação
- hashes/versões registrados
- recuperação/rollback comprovados

## Itens ainda pendentes de documentação/implementação viva

- documentar a aplicação real e o rollback de qualquer root patch aprovado
- registrar resultado do primeiro boot da EFI com AMFIPass
- registrar exatamente quais mudanças em SIP/AMFI/SecureBootModel forem realmente necessárias
- documentar solução final da HD4600 quando houver
- documentar solução final de USB Wi-Fi/Bluetooth quando houver
- consolidar no Hardware Profile somente componentes comprovados
- atualizar README/ROADMAP sempre que um checkpoint experimental virar funcional
- criar Releases e manifesto de compatibilidade quando a primeira versão distribuível existir

## Regra de manutenção do repositório

Mudanças importantes descobertas durante testes reais do LOWDRUS INSTALLER devem ser refletidas no repositório. A documentação deve distinguir claramente:

- **validado**
- **em teste**
- **não validado / roadmap**

Isso evita que um experimento bem-sucedido apenas no Windows, uma hipótese de compatibilidade ou uma EFI que apenas conseguiu boot seja apresentada como solução final.
