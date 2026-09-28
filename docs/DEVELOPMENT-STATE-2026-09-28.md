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
- FileVault observado como Off durante a investigação de root patch
- SIP/Authenticated Root foram alterados durante a investigação posterior de root patch; qualquer documentação do baseline final deve usar o estado efetivamente validado no checkpoint correspondente

### Atenção a boot-args

A documentação do perfil deve sempre refletir o `config.plist`/NVRAM efetivamente usados no boot correspondente, e não transcrições antigas ou anotações de memória.

Durante a investigação posterior foram confirmados boot-args contendo:

```text
-v debug=0x100 keepsyms=1 -wegnoegpu -no_compat_check revpatch=sbvmm amfi=0x80
```

Isso **não significa** que todos esses argumentos devam entrar no perfil final. `amfi=0x80` foi usado como requisito experimental para root patch e possui impacto de segurança/compatibilidade; só pode ser promovido se existir necessidade comprovada, boot estável e rollback.

## Estado gráfico atual

No Tahoe instalado, a Intel HD Graphics 4600 foi observada em checkpoint anterior com:

- VRAM total: 7 MB
- Device ID: `0x0412`
- Revision ID: `0x0006`
- resolução 1920×1080 @ 60 Hz
- sem aceleração gráfica validada

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
- `system_profiler SPEthernetDataType` identificou Realtek RTL8168G/8111G, vendor `0x10ec`, device `0x8168`
- estado físico permaneceu `inactive`
- forçar `100baseTX full-duplex` não estabeleceu link

Não promover Ethernet como solução final com base nesses testes.

## Checkpoint Intel AC7260 Wi-Fi

Foi criado `EFI-WIFI-AC7260-TESTE-04` usando `itlwm.kext` 2.3.0. Tahoe iniciou, mas a interface Wi-Fi não se tornou funcional. Como essa versão do itlwm não representa suporte Tahoe validado, o teste permanece arquivado e a AC7260 está atrás do USB Realtek na prioridade atual.

## Checkpoint RTL8821CU

A investigação completa do adaptador USB está registrada em `docs/NETWORK-RTL8821CU-TAHOE.md`.

Pontos confirmados:

- VID/PID `0BDA:C820`
- interface Wi-Fi MI_02 e Bluetooth MI_00 no Windows
- produto USB enumera no Tahoe
- projeto `chris1111/Wireless-USB-OC-Big-Sur-Adapter` auditado
- `RtWlanU.kext` contém personalidade `RTL8821CU_C820_Combo`
- `RtWlanU.kext` versão `1830.32.b27`
- dependência declarada `com.apple.iokit.IOUSBFamily = 1.8`
- TESTE-07 confirmou tentativa de carga do `RtWlanU`
- falha principal: `com.apple.iokit.IOUSBFamily not found`
- erro associado observado: `0xdc00800e`
- Netac/KNUP também recebeu `RtWlanU.kext` isoladamente e `ocvalidate` 1.0.7 aprovou o `config.plist`; no boot pela ARATE_EFI o mesmo erro de dependência foi reproduzido

Conclusão: enumeração USB, VID/PID e injeção OpenCore foram comprovadas; o bloqueio é a compatibilidade/dependência legada do driver no Tahoe.

## OCLP-Mod / root patch — estado real atual

Esta seção substitui qualquer nota antiga dizendo que nenhum root patch havia sido aplicado.

Foi instalado/auditado **OCLP-Mod 3.1.9**. O código do patch `LegacyUSBHOST` foi revisado e usa componentes USB legados/compatibilidade de sistema, incluindo famílias relacionadas a IOUSBFamily/IOUSBHost.

Durante os testes no Razer:

- SIP e authenticated-root foram desabilitados para investigação de root patch
- `amfi=0x80` foi adicionado aos boot-args e confirmado em NVRAM
- a interface do OCLP-Mod deixou de bloquear a aplicação por AMFI
- o root patch foi executado pela interface do OCLP-Mod
- após reiniciar, o Tahoe deixou de concluir o boot normal
- o travamento permaneceu mesmo com o adaptador C820 fisicamente desconectado
- Safe Mode pelo OpenCore resultou em símbolo de proibido
- macOS Recovery continuou funcional
- grupo APFS System/Data foi confirmado íntegro no Recovery
- snapshots APFS foram listados e preservados; nenhum snapshot foi apagado
- tentativas de rollback via `bless` não concluíram com sucesso
- o OCLP-Mod instalado no volume System não pôde ser executado diretamente no Recovery por ausência de `libffi.dylib` no ambiente reduzido

Importante: a tela imediatamente anterior à aplicação do patch mostrou `Intel Wireless`; em checkpoint anterior o OCLP-Mod havia mostrado `Intel Wireless` e `Legacy USB`. Portanto, ainda não é seguro afirmar que somente o Legacy USB foi aplicado. O conjunto exato de alterações precisa ser auditado antes de qualquer promoção.

**Regra:** nenhum root patch dessa linha pode entrar no LOWDRUS final até existir aplicação isolada, boot estável, inventário das mudanças e rollback reproduzível.

## Mídias e regras de segurança

### Netac/KNUP

Mídia de contingência OpenCore/ARATE_EFI usada em testes. Durante a investigação C820 ela foi modificada de forma controlada para incluir `RtWlanU.kext`, com backup anterior e validação `ocvalidate`. Não deve receber novas alterações casuais enquanto o Tahoe está em recuperação.

### Kingston `LWIFI_TEST`

Pendrive experimental de EFI, aproximadamente 15,6 GB. Foi usado em checkpoints de rede e AMFIPass. Continua sendo mídia de laboratório, não mídia-mestre do instalador.

### Toshiba — mídia física atual do LOWDRUS Installer

A mídia física atualmente confirmada para o projeto LOWDRUS Installer é:

- `TOSHIBA External USB 3.0`
- capacidade nominal ~128 GB
- serial observado no Windows: `20140922020378`
- GPT
- partição `LOWDRUS_EFI` FAT32 ~536,9 MB
- partição `LOWDRUS` exFAT ~127,5 GB no Recovery / ~118,7 GiB utilizáveis no Windows

No Windows, a EFI contém `BOOTx64.efi`, `OpenCore.efi` e `config.plist`.

A partição `LOWDRUS` contém:

- `InstallAssistant.pkg`
- `LOWDRUS-TRANSPORT/Tahoe-Builder.tar`

Descoberta de hardware: o primeiro adaptador/leitor SATA→USB usado com o Toshiba não foi enumerado corretamente pelo macOS Recovery. Após trocar o adaptador/leitor, o Toshiba apareceu imediatamente em `diskutil list`. Isso deve entrar no diagnóstico futuro do LOWDRUS como possível falha de bridge/adaptador USB.

### Nota sobre nomenclatura Lexar x Toshiba

Documentos mais antigos do repositório se referem ao **SSD externo LOWDRUS (Lexar)**. O estado de hardware observado nesta sessão usa **Toshiba** como mídia física conectada ao LOWDRUS. Isso deve ser tratado como evolução/troca de mídia ou discrepância histórica a ser resolvida explicitamente, nunca como se Lexar e Toshiba fossem automaticamente o mesmo dispositivo.

Enquanto a origem dessa mudança não estiver documentada de forma definitiva, usar:

- `mídia LOWDRUS atual (Toshiba)` para o dispositivo da sessão atual;
- `SSD externo LOWDRUS (Lexar)` apenas ao descrever checkpoints históricos em que a Lexar foi realmente usada.

### Samsung interno

O SSD Samsung interno com Tahoe instalado não deve ser apagado durante experimentos de EFI/rede. Operações destrutivas exigem identificação forte e confirmação apropriada.

## Tahoe Builder / modo offline

Payload original validado:

- Tahoe 26.7 build 25G229
- `InstallAssistant.pkg`
- tamanho observado: `18,381,960,622` bytes
- SHA-256: `23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE`

Tahoe Builder transportado em TAR:

- `Tahoe-Builder.tar`
- tamanho: `18,437,734,400` bytes
- SHA-256: `7EA862E4FB009E5E7AEBCA7F9A43B0AA8471149084841CBEF95F19BEA8EE53B4`

No Tahoe Recovery foram confirmados dentro do TAR:

- `Install macOS Tahoe.app`
- `Install macOS Tahoe.app/Contents/Resources/createinstallmedia`
- `Install macOS Tahoe.app/Contents/Resources/createinstallmedia.dylib`
- `Install macOS Tahoe.app/Contents/SharedSupport/SharedSupport.dmg`

Portanto, o payload offline necessário para materializar o instalador existe e está legível no Recovery.

## Checkpoint de materialização no Recovery — estado atual

O `df -h` do Recovery confirmou:

- volume `LOWDRUS` montado, com aproximadamente 84 GiB livres
- volume APFS `LOWDRUS_TAHOE_INSTALLER` disponível, com aproximadamente 37 GiB livres
- volumes System/Data do Samsung com amplo espaço livre, mas eles não devem ser usados como destino de desenvolvimento enquanto houver volume dedicado

Foi executado teste de escrita no volume APFS dedicado:

```text
touch /Volumes/LOWDRUS_TAHOE_INSTALLER/LOWDRUS-WRITE-TEST
```

seguido de `ls -l`, e o arquivo foi criado com sucesso.

**VALIDADO:** `/Volumes/LOWDRUS_TAHOE_INSTALLER` é gravável no Recovery atual.

**PENDENTE:** extrair/materializar `Install macOS Tahoe.app` nesse filesystem macOS adequado e validar sua integridade antes de executar qualquer ferramenta do instalador.

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

### Perfil de entrada estilo Windows — atualização recente

A atualização recente do repositório adicionou automação de pós-instalação para aproximar teclado/mouse do comportamento do Windows:

- Ctrl físico -> Command do macOS
- tecla Windows -> Control do macOS
- Alt permanece Option
- Natural scrolling desativado para roda no sentido esperado do Windows
- LaunchAgent de usuário para persistência
- script de rollback que remove somente as alterações LOWDRUS

Arquivos:

- `scripts/macos/apply-windows-input-profile.sh`
- `scripts/macos/restore-macos-input-profile.sh`
- `docs/WINDOWS-LIKE-INPUT.md`

**Estado correto:** código/documentação existem no repositório, mas ainda devem ser tratados como componente implementado do projeto, não como comportamento funcional comprovado no Razer até serem executados e validados no Tahoe real.

### Windows Manager / Engine

O repositório já contém Engine Windows e GUI/protótipo. O Engine valida tamanho/hash do Tahoe Builder e InstallAssistant e mantém `installReady=false`, portanto ainda não libera instalação destrutiva. Isso é coerente com o estado atual de segurança.

Há, porém, nomenclatura legada `lexar` em checks/GUI/Engine. Como a mídia atual comprovada é Toshiba, essa nomenclatura deve ser refatorada futuramente para algo neutro como `lowdrusMedia`, preservando compatibilidade dos contratos enquanto necessário.

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

## Estado da candidata AMFIPass

No Windows foi preparada uma EFI candidata com `AMFIPass.kext`.

Fluxo registrado:

- `ocvalidate` 1.0.7 aprovou a candidata
- EFI anterior do Kingston foi preservada como `EFI-BACKUP-PRE-AMFIPASS-PC`
- candidata copiada para o Kingston
- estrutura mínima verificada
- `config.plist` da cópia instalada validado novamente
- SHA-256 da candidata e da cópia instalada: `E31743DF2BBC6973204B19996C211EEE84743B317E45426CC8EB647C15C3C770`

Isso é checkpoint de integridade no Windows, não validação funcional no Tahoe.

Além disso, na investigação de root patch real foi utilizado `amfi=0x80` em NVRAM. A relação final entre AMFIPass, `amfi=0x80`, SIP e o conjunto mínimo necessário continua pendente e deve ser testada sem confundir preparação de EFI com resultado funcional.

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

- recuperar o Tahoe atual do estado pós-root-patch
- auditar exatamente qual patchset OCLP-Mod foi aplicado no boot quebrado
- materializar `Install macOS Tahoe.app` em `LOWDRUS_TAHOE_INSTALLER`
- validar bundle extraído antes de executar `createinstallmedia`/`startosinstall`
- validar reinstalação offline preservando dados, se suportada pela rota escolhida
- resolver/refatorar nomenclatura Lexar x Toshiba no Engine/GUI/documentação
- testar de verdade o perfil Windows-like no Tahoe após recuperação
- documentar solução final da HD4600 quando houver
- documentar solução final de USB Wi-Fi/Bluetooth quando houver
- consolidar no Hardware Profile somente componentes comprovados
- criar Releases e manifesto de compatibilidade quando a primeira versão distribuível existir

## Regra de manutenção do repositório

Mudanças importantes descobertas durante testes reais do LOWDRUS INSTALLER devem ser refletidas no repositório. A documentação deve distinguir claramente:

- **validado**
- **implementado mas ainda não validado no Razer**
- **em teste**
- **não validado / roadmap**

Isso evita que um experimento bem-sucedido apenas no Windows, uma hipótese de compatibilidade ou uma EFI que apenas conseguiu boot seja apresentada como solução final.
