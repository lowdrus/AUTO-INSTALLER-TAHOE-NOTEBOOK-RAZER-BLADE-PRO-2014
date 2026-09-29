# LOWDRUS INSTALLER — Development History consolidado

> Documento mestre de histórico, estado, decisões, checkpoints, hipóteses, regressões, pendências e próximos passos do **LOWDRUS INSTALLER para macOS Tahoe no Razer Blade Pro RZ09-0117 (2014)**.
>
> Este arquivo foi criado para complementar — não duplicar — os documentos temáticos existentes. Ele funciona como índice cronológico/consolidado do desenvolvimento e registra também o que ainda falta validar.

---

## 1. Escopo e regra de organização

Este repositório é dedicado ao **LOWDRUS INSTALLER TAHOE para o Razer Blade Pro RZ09-0117 (2014)**. O projeto maior de multiboot/tri-boot, Windows 11, SteamOS e um eventual menu principal com IA/voz são projetos separados e não devem ser misturados aqui enquanto o perfil Tahoe/Razer não estiver estabilizado.

A documentação já existente permanece authoritative por domínio:

- `README.md` — visão geral, objetivo, escopo e estado de alto nível;
- `docs/ARCHITECTURE.md` — arquitetura do Engine, GUI, profiles, Recovery e Update Engine;
- `docs/ROADMAP.md` — fases, tarefas concluídas, em teste e pendentes;
- `docs/DEVELOPMENT-STATE-2026-09-28.md` — estado consolidado da fase Toshiba/Builder e checkpoints de Recovery;
- `docs/NETWORK-RTL8821CU-TAHOE.md` — investigação do adaptador Realtek RTL8821CU no Tahoe;
- `docs/CHECKPOINTS-29G-29O-TOSHIBA.md` — checkpoints iniciais da mídia Toshiba;
- `docs/CHECKPOINT-30U-30V.md` — auditoria do produto Apple e receita local do Builder;
- `docs/STORAGE-MEDIA-NAMING.md` — nomenclatura correta das mídias;
- `docs/WINDOWS-LIKE-INPUT.md` — perfil de teclado/mouse estilo Windows.

Este `DEVELOPMENT-HISTORY.md` deve ser mantido como **registro mestre de evolução** e deve apontar para documentos especializados em vez de reproduzir indefinidamente o mesmo conteúdo.

---

## 2. Objetivo final do LOWDRUS INSTALLER

Transformar o processo manual de Hackintosh/macOS Tahoe no Razer Blade Pro 2014 em um fluxo:

- offline quando possível;
- repetível;
- auditável;
- seguro;
- com identificação forte de hardware e discos;
- com backup/rollback;
- com logs persistentes;
- com recuperação;
- com atualização versionada;
- com pós-instalação automatizada;
- sem Terminal no fluxo normal do usuário;
- com GUI como camada principal;
- com console técnico somente em Ferramentas Avançadas.

O instalador final não deve ser apresentado como universal. O Core pode evoluir para multi-hardware, mas cada máquina deve ter Hardware Profile próprio, validado e versionado.

---

## 3. Hardware-alvo e baseline conhecido

Hardware principal em validação:

- Notebook: Razer Blade Pro RZ09-0117 (2014)
- CPU: Intel Core i7-4700HQ / Haswell
- RAM: 16 GB
- iGPU: Intel HD Graphics 4600
- dGPU: NVIDIA GTX 860M, atualmente desabilitada no macOS
- SSD interno: Samsung SATA 512 GB
- Wi-Fi/Bluetooth interno: Intel AC7260
- Ethernet: Realtek RTL8168
- Wi-Fi/Bluetooth USB prioritário: Realtek RTL8821CU combo

Baseline OpenCore conhecido:

- OpenCore 1.0.7 DEBUG durante o desenvolvimento
- SMBIOS: MacBookPro11,2
- boot-args efetivamente observados na EFI funcional: `-v debug=0x100 keepsyms=1 -wegnoegpu -no_compat_check`
- Intel HD 4600 platform-id baseline: `05 00 26 0A`
- Intel HD 4600 device-id: `12 04 00 00`
- SecureBootModel: Disabled
- Vault: Optional
- SIP: habilitado durante a maior parte dos testes

### Divergência documental a corrigir

O arquivo `src/profiles/razer-blade-pro-rz09-0117-2014/profile.json` ainda contém `revpatch=sbvmm` na lista `bootArgs`, enquanto a EFI funcional auditada não possuía esse argumento. O perfil deve ser atualizado para refletir a fonte autoritativa real antes de ser promovido.

---

## 4. Filosofia de segurança consolidada

As seguintes regras foram adotadas durante o desenvolvimento e devem ser preservadas no produto final:

1. **Netac conhecida como funcional não deve ser alterada durante experimentos.** Ela é contingência de recuperação.
2. O SSD Samsung interno não deve ser apagado durante experimentos de EFI, rede, Builder ou root patch.
3. Alterações críticas devem ocorrer em mídias/testes separados e numerados.
4. Um experimento por vez, com rollback preservado antes de qualquer modificação.
5. Operações destrutivas devem identificar disco por múltiplos atributos: modelo, serial, tamanho, barramento, label/estrutura; nunca apenas por letra de unidade ou `diskN`.
6. Nenhum `[OK]` deve ser reportado após falha crítica.
7. Nenhum root patch, kext antigo, alteração de SIP/AMFI ou edição de dependência deve ser aplicada por tentativa cega.
8. O fluxo final do usuário deve abstrair Terminal/PowerShell; comandos manuais pertencem apenas à engenharia, auditoria e contingência.
9. Qualquer bundle parcial, extração incompleta, cópia truncada ou payload com hash divergente deve ser tratado como inválido.
10. O Engine deve ser fail-safe: se o alvo não estiver fortemente identificado ou a validação falhar, a operação destrutiva permanece bloqueada.

---

## 5. Nomenclatura das mídias e papéis

### Netac
Mídia de boot/OpenCore conhecida como funcional. Preservar. Não usar como laboratório.

### Kingston DT 101 G2 — `LWIFI_TEST`
Pendrive USB experimental usado para testes isolados de OpenCore/rede/root patch.

Identidade observada:

- serial: `001CC0C61232EC3113120095`
- tamanho do disco: aproximadamente `15,606,349,824` bytes
- volume FAT32: aproximadamente `15,588,130,816` bytes

### SSD externo LOWDRUS (Lexar)
Dispositivo externo do projeto. Deve ser chamado de **SSD externo**, nunca de pendrive.

### Toshiba External USB 3.0
Mídia de ~128 GB usada intensamente nos checkpoints de Builder/Recovery.

Identidade observada:

- serial: `20140922020378`
- capacidade: `128035674112` bytes
- GPT
- `LOWDRUS_EFI` FAT32
- `LOWDRUS` exFAT

### Samsung SATA SSD interno
Disco interno do Razer com Tahoe instalado durante a validação atual.

---

## 6. Evolução do projeto e arquitetura

O projeto evoluiu de uma ideia de preparador/auto-installer para uma arquitetura explicitamente dividida em:

- **LOWDRUS Engine**
- **LOWDRUS GUI**
- **Hardware Profile**
- **Tahoe OS Profile / Builder**
- **Recovery**
- **Update Engine**

A arquitetura atual prevê:

- detector seguro de hardware/discos;
- diagnóstico automático;
- auto-repair de condições conhecidas;
- revalidação pós-reparo;
- logs persistentes;
- exportação de relatórios;
- backup/rollback;
- hardware profiles versionados;
- manifests de compatibilidade;
- atualização transacional pelo GitHub;
- recuperação externa e, no futuro, interna.

O perfil atual de Tahoe ainda mantém `functionalInstallValidated:false`, corretamente, porque a instalação offline completa a partir da mídia LOWDRUS ainda não foi validada do início ao fim.

---

## 7. LOWDRUS Engine — estado real implementado

Já existe um Engine Windows em `src/engine/windows/Lowdrus.Engine.ps1`.

Capacidades atuais observadas:

- ações `status`, `diagnose`, `repair-check`, `recovery-check`, `logs`, `export-report`;
- hashes esperados do `Tahoe-Builder.tar` e `InstallAssistant.pkg` embutidos;
- busca por volume LOWDRUS;
- busca por Builder e InstallAssistant;
- inventário de hardware via CIM/WMI;
- inventário de CPU, GPU, memória, discos, rede, áudio, BIOS, placa-mãe, bateria;
- detecção básica do Razer alvo;
- exportação de relatórios JSON;
- preflight de repair/recovery não destrutivo;
- `installReady=false` por segurança;
- falha segura com retorno JSON em caso de exceção.

### O que ainda falta no Engine

- identificação física realmente forte de mídia/disco por serial/modelo/tamanho/partições;
- bloqueio ativo do SSD interno em operações destrutivas;
- seleção segura de destino;
- validação completa da EFI e de todos os arquivos por hash;
- state machine persistente entre reboot/recovery;
- retries transacionais;
- cleanup seguro de materialização incompleta;
- suporte ao ambiente macOS/Recovery;
- diagnóstico de bridge/adaptador USB incompatível;
- detecção de `Input/output error` e `Device not configured`;
- automação do Builder/createinstallmedia;
- automação de root patch com rollback;
- integração dos perfis de hardware/OS;
- update engine GitHub Releases;
- rollback real de atualização;
- recuperação interna;
- suporte remoto opcional somente quando houver rede válida.

---

## 8. LOWDRUS GUI / Manager — estado real

Já existe Manager WPF em `src/manager/Lowdrus.Manager.ps1`.

Já implementado:

- janela LOWDRUS INSTALLER;
- vídeo/asset visual oficial em background;
- vídeo mudo por regra;
- status visual de checks;
- botões de diagnóstico, preflight de reparo, preflight de recuperação, logs, atualizar estado e exportar relatório;
- botão de instalação presente, porém deliberadamente desabilitado;
- mensagens de proteção contra instalação destrutiva antes da validação final.

### Histórico de problema de GUI

Durante o desenvolvimento houve falhas anteriores com abordagens XAML. A direção prática adotada foi evitar depender de XAML frágil e preferir construção programática WPF/WinForms quando necessário.

### O que falta na GUI

- fluxo real de Instalar macOS Tahoe;
- reinstalar/reparar instalação existente;
- seleção segura de mídia e destino;
- progresso real do Builder/createinstallmedia/instalação;
- diagnósticos guiados de hardware;
- auto-repair com validação posterior;
- recovery/rollback de verdade;
- gerenciamento de root patches;
- tela de logs e histórico navegável;
- update/rollback pelo GitHub;
- ferramentas avançadas;
- console técnico opcional e escondido do fluxo normal;
- mensagens específicas para mídia ausente, bridge USB incompatível, payload inválido, falta de espaço e ambiente offline.

---

## 9. Perfil estilo Windows para teclado/mouse

Foi criada estratégia de pós-instalação para aproximar o comportamento do macOS do Windows:

- Ctrl físico -> Command
- Windows físico -> Control
- Alt -> Option
- Natural Scrolling desabilitado
- LaunchAgent para reaplicar mapeamento
- rollback disponível

Scripts existentes:

- `scripts/macos/apply-windows-input-profile.sh`
- `scripts/macos/restore-macos-input-profile.sh`

Ainda pendente:

- validar Home/End/Delete;
- validar atalhos específicos por aplicativo;
- integrar isso formalmente à GUI/pós-instalação;
- garantir idempotência/rollback em cenário real no Razer.

---

## 10. Payload Tahoe 26.7 e Builder

Produto alvo:

- macOS Tahoe 26.7
- build `25G229`
- `InstallAssistant.pkg`
- tamanho validado: `18,381,960,622` bytes
- SHA-256: `23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE`

Tahoe Builder transportado:

- `Tahoe-Builder.tar`
- tamanho: `18,437,734,400` bytes
- SHA-256: `7EA862E4FB009E5E7AEBCA7F9A43B0AA8471149084841CBEF95F19BEA8EE53B4`

### Evolução da estratégia

A tentativa inicial de copiar diretamente o `.app` por filesystem Windows/exFAT foi abandonada após problemas de preservação/compatibilidade. A estratégia evoluiu para:

1. reconstruir/obter o `Install macOS Tahoe.app`;
2. encapsular o bundle em TAR;
3. transportar o TAR em exFAT;
4. materializar o `.app` em filesystem macOS adequado;
5. executar `createinstallmedia`;
6. validar boot offline pelo Recovery/Installer.

### Itens confirmados dentro do Builder/TAR

- `Install macOS Tahoe.app`
- `Contents/Resources/createinstallmedia`
- `Contents/Resources/createinstallmedia.dylib`
- `Contents/SharedSupport/SharedSupport.dmg`

---

## 11. Checkpoints Toshiba / Builder / Recovery

### #29G–#29O

A Toshiba foi identificada, preservada e auditada. Confirmados:

- GPT;
- EFI LOWDRUS/OpenCore presente;
- `InstallAssistant.pkg` presente;
- `Tahoe-Builder.tar` presente;
- volume LOWDRUS montável no Recovery;
- estrutura do TAR válida;
- `createinstallmedia`, `.dylib` e `SharedSupport.dmg` presentes.

Descoberta crítica: **o adaptador/leitor SATA→USB influencia a visibilidade da mídia no Recovery**. Um adaptador anterior falhou; outro passou a enumerar a Toshiba corretamente.

### Falha de I/O durante materialização

Durante uma primeira materialização real houve:

- `Error reading fd 3: Device not configured`
- `Input/output error`
- `fts_read: Device not configured`

A mídia chegou a desaparecer de `diskutil list` em uma sessão e, em outra, permaneceu enumerada porém com falha de leitura.

### Troca de porta e revalidação

Após mudança de porta USB, foram aprovados:

- leitura curta de 256 MiB;
- leitura integral do `InstallAssistant.pkg`;
- leitura integral do `Tahoe-Builder.tar`.

Leituras completas observadas:

- InstallAssistant: `18,381,960,622` bytes em ~74,22 s;
- Tahoe-Builder.tar: `18,437,734,400` bytes em ~74,94 s.

Esses testes provaram estabilidade de leitura sustentada na combinação Toshiba + bridge/adaptador + porta USB usada naquele momento.

### Requisito de produto derivado

O Engine/GUI deve detectar automaticamente erros de I/O, abortar, nunca promover bundle parcial, registrar etapa/mídia, permitir retry e fazer cleanup seguro antes de nova tentativa.

---

## 12. createinstallmedia e boot offline

Posteriormente foi alcançado:

- materialização real do `Install macOS Tahoe.app`;
- `createinstallmedia` executado até 100%;
- mídia criada e apresentada como `Install macOS Tahoe`;
- boot via OpenCore/Netac;
- seleção de `Install macOS Tahoe (external)`;
- carregamento do Tahoe Recovery/Installer a partir da mídia externa;
- reconhecimento do destino `Macintosh HD`;
- início real da instalação.

Isto prova que a cadeia Builder -> createinstallmedia -> boot Recovery funciona até o início da instalação.

---

## 13. Bloqueio atual da instalação offline

A instalação falhou com mensagem gráfica equivalente a “instalador está danificado”. Os logs situaram o bloqueio em:

- `Verifying SharedSupport.dmg`
- `OSISVerifyBaseSystemOperation`

Também houve tentativa de verificação de relógio/Apple em ambiente sem rede.

### Auditoria #30R–#30V

Foi auditado o workspace em `F:\PROJETO\TRIBOOT`.

Descobertas:

- `C:` estava criticamente sem espaço e não deve receber payloads grandes;
- `F:` possui espaço adequado para workspace pesado;
- `SharedSupport.dmg` completo já existia no Builder local;
- `SharedSupport.dmg` e `InstallAssistant.pkg` possuem exatamente o mesmo tamanho e mesmo SHA-256;
- portanto, são idênticos bit a bit;
- esse fato isolado não prova erro, pois o fluxo Apple/local observado usa o InstallAssistant como SharedSupport;
- produto Apple original preservado contém também:
  - `com_apple_MobileAsset_MacSoftwareUpdate.plist`
  - `InstallInfo.plist`
  - `MajorOSInfo.pkg`
  - `UpdateBrain.zip`
- não foi encontrado `.integrityDataV1` no diretório do produto e isso não deve ser usado isoladamente como prova de corrupção.

### Receita local auditada

Scripts existentes em `TAHOE-REBUILD` mostram:

- extração de `Payload.cpio`;
- inspeção de `OSInstallerSetup.framework`;
- extração de `Scripts`;
- execução do `postinstall.sh`;
- existência de `postinstall_actions`;
- intenção de auditar `link_shared_support.bash`.

### O que ainda falta na investigação do Builder

- localizar/ler o conteúdo real de `link_shared_support.bash`;
- listar todos os `postinstall_actions` com tamanhos/permissões;
- reproduzir precisamente a ação Apple original;
- determinar o papel real de `MajorOSInfo.pkg`, `UpdateBrain.zip`, `InstallInfo.plist` e MobileAsset plist;
- auditar metadados do bundle final;
- comparar produto Apple original, Builder e mídia criada pelo createinstallmedia;
- identificar por que `OSISVerifyBaseSystemOperation` rejeita o SharedSupport/BaseSystem;
- validar se relógio/data em ambiente offline participa do bloqueio;
- somente depois gerar nova variante de Builder e retornar ao Razer.

---

## 14. Gráficos Intel HD 4600

Estado atual observado no Tahoe:

- Intel HD Graphics 4600
- 7 MB VRAM
- Device ID `0x0412`
- `No Kext Loaded`
- 1920x1080 @ 60 Hz
- sem aceleração gráfica validada

Baseline:

- platform-id `05 00 26 0A`
- device-id `12 04 00 00`

### TESTE-03

Foi criada variante de laboratório:

- `EFI-HD4600-TESTE-03`
- alteração de platform-id para `06 00 26 0A`
- device-id mantido
- `ocvalidate`: sem problemas

Não foi promovido como solução final.

### Direção técnica

Tahoe não oferece suporte nativo simples ao Haswell/HD4600. A aceleração provavelmente exige estratégia de legacy graphics/root patch e deve ser pesquisada/testada de forma isolada. Não assumir que trocar platform-id resolve aceleração.

### Pendente

- identificar estratégia correta de patch Haswell para Tahoe 26.7 build 25G229;
- auditar necessidade de OCLP/OCLP-Mod/MetallibSupportPkg ou alternativa atual;
- validar boot e aceleração real;
- validar estabilidade, vídeo, brilho, sleep/wake e updates;
- criar rollback antes de qualquer root patch gráfico;
- somente depois integrar ao perfil final.

---

## 15. Rede — ordem de prioridade fixada

Ordem prática definida pelo projeto:

1. USB Wi-Fi + Bluetooth Realtek RTL8821CU
2. Ethernet Realtek RTL8168
3. Bluetooth interno Intel AC7260
4. Wi-Fi interno Intel AC7260

A investigação Ethernet foi estacionada para priorizar o adaptador USB Wi-Fi.

---

## 16. RTL8821CU — identificação de hardware

Adaptador combo confirmado no Windows e Tahoe:

- chipset: Realtek RTL8821CU
- VID: `0x0BDA`
- PID: `0xC820`
- Wi-Fi: interface `MI_02`
- Bluetooth: interface `MI_00`
- produto Tahoe: `802.11ac NIC`
- fabricante: Realtek
- USB link: 480 Mb/s

O hardware enumera corretamente no barramento USB do Tahoe.

---

## 17. Auditoria do Wireless USB OC Big Sur Adapter V17

Projeto upstream auditado:

- `chris1111/Wireless-USB-OC-Big-Sur-Adapter`
- release V17

Asset:

- `Wireless.USB.OC.Big.Sur.Adapter-V17.zip`
- tamanho: `10,652,799` bytes
- SHA-256: `F71AB9E6E85767E2A711A919FF10BCEB28DE612D9DF40E7A3D5BEFC72967BBBA`

PKG interno:

- `Wireless USB OC Big Sur Adapter.pkg`
- tamanho: `10,604,772` bytes
- SHA-256: `94FE4FDB93112BC12FB698FC2870B965BBA4F4149284B1467650A4578DD3A288`

Kexts principais:

- `RtWlanU.kext` — `com.realtek.driver.RtWlanU`, versão `1830.32.b27`
- `RtWlanU1827.kext` — `com.realtek.driver.RtWlanU1827`, versão `1827.4.b36`

O `Info.plist` de `RtWlanU.kext` contém personalidade explícita `RTL8821CU_C820_Combo` com:

- `bInterfaceNumber = 2`
- `idVendor = 3034` = `0x0BDA`
- `idProduct = 51232` = `0xC820`

Portanto, o hardware é contemplado pelo driver.

---

## 18. TESTE-07 — injeção direta Realtek

EFI experimental:

- `EFI-RTL8821CU-TESTE-07`

Adicionados:

- `RtWlanU.kext`
- `RtWlanU1827.kext`
- duas entradas correspondentes em `Kernel -> Add`

Validações:

- `ocvalidate` 1.0.7: `No issues found`
- comparação semântica confirmou apenas duas entradas novas
- cópia ao Kingston comparada por SHA-256
- boot do Tahoe permaneceu funcional

Resultado:

- kexts não permaneceram carregados;
- kernel tentou carregar `com.realtek.driver.RtWlanU`;
- falha por dependência não resolvida:
  - `com.apple.iokit.IOUSBFamily not found`
  - erro associado `0xdc00800e`

Conclusão:

- OpenCore estava injetando;
- VID/PID estava contemplado;
- o bloqueio real é compatibilidade de dependência do driver legado com Tahoe.

---

## 19. Dependências dos kexts Realtek

Ambos `RtWlanU` e `RtWlanU1827` declaram:

- `com.apple.iokit.IONetworkingFamily = 1.1`
- `com.apple.iokit.IOUSBFamily = 1.8`
- `com.apple.kpi.bsd = 8.0.0b2`
- `com.apple.kpi.iokit = 8.0.0b2`
- `com.apple.kpi.libkern = 8.0.0b2`
- `com.apple.kpi.mach = 8.0.0b2`

A dependência `IOUSBFamily` é o bloqueio observado no Tahoe 26.7.

---

## 20. TESTE-08 — laboratório Tahoe / compatibilidade USB

Criado como cópia separada do TESTE-07:

- `EFI-RTL8821CU-TAHOE-TESTE-08`

Uma execução duplicada de `Copy-Item` criou acidentalmente uma pasta `EFI-RTL8821CU-TESTE-07` aninhada dentro do TESTE-08. A duplicação foi identificada e removida. O TESTE-08 voltou a conter apenas `BOOT` e `OC` na raiz.

Regra: TESTE-07 permanece congelado como evidência; novos experimentos pertencem ao TESTE-08 ou variante posterior.

---

## 21. OCLP-Mod / compatibilidade Tahoe USB

Foi iniciada auditoria do OCLP-Mod 3.1.9 porque o método Tahoe documentado para essa família de drivers envolve compatibilidade adicional/root patch.

Workspace de auditoria no Windows:

- `F:\PROJETO\TRIBOOT\LOWDRUS-HD4600-LAB\DOWNLOADS-WIFI\OCLP-MOD-TAHOE-AUDIT`

O source 3.1.9 foi extraído e buscas foram iniciadas por:

- `IOKitUSBFamily`
- `IOUSBFamily`
- `USBFamily`
- `Legacy USB`
- `USB patch`
- `old version USB`

A investigação ainda precisa abrir as ocorrências completas e reconstruir exatamente:

- qual patch USB legado é aplicado;
- qual arquivo/kext/shim fornece a compatibilidade esperada;
- se o componente vai ao root volume, SLE/L/E ou EFI;
- quais versões do Tahoe são condicionadas;
- dependências de KDK;
- pré-requisitos de SIP/AMFI/SecureBootModel;
- rollback exato.

Não inserir aleatoriamente um `IOUSBFamily.kext` antigo na EFI e não remover a dependência dos Realtek sem evidência binária.

---

## 22. AMFIPass — checkpoint atual

Foi preparada uma EFI candidata contendo `AMFIPass.kext`, validada no Windows e copiada ao Kingston experimental.

Checkpoint registrado:

- candidata em `C:\OCLP-AUDIT\EFI-CANDIDATA-AMFIPASS`
- `AMFIPass.kext` presente
- `ocvalidate` 1.0.7: aprovado
- backup do Kingston anterior: `EFI-BACKUP-PRE-AMFIPASS-PC`
- candidata copiada para `G:\EFI`
- `BOOTx64.efi`, `OpenCore.efi`, `Lilu.kext`, `AMFIPass.kext` verificados
- `config.plist` revalidado
- SHA-256 do config candidato/instalado: `E31743DF2BBC6973204B19996C211EEE84743B317E45426CC8EB647C15C3C770`

Ainda não provado:

- boot real do Razer com essa candidata;
- carregamento efetivo do AMFIPass;
- efeito sobre AMFI;
- efeito sobre root patch USB;
- efeito sobre `RtWlanU`;
- necessidade mínima final de SIP/AMFI exceptions.

---

## 23. Ethernet Realtek RTL8168 — investigação estacionada

Testes realizados:

- `RealtekRTL8111.kext` 2.4.2 carregou;
- `en0` existiu;
- estado permaneceu `inactive`;
- `networksetup -getmedia en0` indicou autoselect sem mídia ativa;
- sem LEDs no RJ45 do Razer/porta do roteador;
- TESTE-06 com RealtekRTL8111 3.0.0 também bootou, mas continuou sem link.

Conclusão operacional atual: estacionado, pois a prioridade é Wi-Fi USB.

Pendente quando retomado:

- testar cabo/porta física conhecidos como bons;
- validar PHY/link;
- comparar kext 2.4.2 vs 3.0.0;
- auditar ACPI/PCI path se necessário;
- validar DHCP e tráfego real.

---

## 24. Intel AC7260 Wi-Fi interno

Foi criado:

- `EFI-WIFI-AC7260-TESTE-04`

Com `itlwm 2.3.0`.

Resultado:

- Tahoe bootou;
- Wi-Fi interno não ficou funcional.

`itlwm 2.3.0` é anterior ao Tahoe e não deve ser tratado como solução atual.

Pendente:

- pesquisar estado atual do itlwm/AirportItlwm para Tahoe 26.7;
- validar HeliPort/alternativas se aplicável;
- testar somente depois do USB Wi-Fi e Bluetooth interno, conforme prioridade definida.

---

## 25. Bluetooth interno Intel AC7260

Estratégia esperada, ainda não validada:

- IntelBluetoothFirmware
- IntelBTPatcher
- BlueToolFixup

Pendente:

- confirmar versões atuais compatíveis com Tahoe 26.7;
- validar enumeração e firmware;
- pareamento real;
- reboot/cold boot;
- coexistência com combo USB quando presente.

---

## 26. Bluetooth do combo RTL8821CU

O mesmo dispositivo USB expõe Bluetooth em `MI_00`.

Ainda não validado no Tahoe.

Pendente:

- identificar stack/kext/firmware correto para a função Bluetooth do combo;
- verificar coexistência com driver Wi-Fi Realtek;
- testar pareamento real;
- verificar sleep/wake e reconexão.

---

## 27. Pós-instalação e hardware restante

Ainda precisam de validação formal e automação:

- áudio;
- bateria/SMC;
- teclado;
- trackpad;
- brilho;
- display identification;
- portas USB/mapeamento;
- sleep;
- wake;
- shutdown;
- reboot;
- cold boot;
- sensores;
- câmera;
- leitores/dispositivos adicionais do notebook;
- estabilidade térmica/energia;
- atualização de macOS preservando boot e perfil.

Nenhum item deve ser marcado como final apenas por o sistema iniciar.

---

## 28. Recuperação interna planejada

Objetivo futuro: manter componentes de recuperação no SSD interno Samsung para reduzir a dependência da mídia externa.

Requisitos:

- não ser apagada numa reinstalação normal;
- poder reparar/restaurar EFI;
- poder iniciar recovery/reinstall;
- coexistir com backup externo;
- não substituir a necessidade de uma mídia de emergência em falha física do SSD.

Ainda não implementado.

---

## 29. Atualização segura pelo GitHub

Arquitetura desejada:

- GitHub Releases;
- manifesto de versão;
- hashes;
- matriz de compatibilidade;
- backup pré-update;
- atualização transacional;
- validação pós-update;
- rollback automático;
- bloqueio de update incompatível.

Ainda não existe Release estável e não deve haver atualização cega de EFI conhecida como funcional.

---

## 30. Suporte remoto opcional

Desejado no futuro, quando houver rede funcional:

- SSH/autenticação;
- coleta de logs;
- acompanhamento de instalação;
- diagnóstico;
- execução assistida de correções;
- exportação de relatórios.

Limitações:

- não existe rede em todas as fases de boot/recovery;
- reboot interrompe sessão;
- suporte remoto nunca deve ser requisito para instalar ou recuperar;
- o sistema deve continuar registrando logs localmente quando offline.

Ainda não validado como recurso funcional.

---

## 31. Estado de maturidade atual

### Validado ou fortemente comprovado

- Tahoe 26.7 build 25G229 inicia no Razer;
- OpenCore 1.0.7 utilizado no desenvolvimento;
- EFI funcional preservada;
- payload `InstallAssistant.pkg` validado por tamanho/hash;
- Builder TAR validado por tamanho/hash;
- transporte via TAR é tecnicamente utilizável;
- materialização do Builder foi concluída em tentativa posterior;
- `createinstallmedia` executou até 100%;
- mídia externa boota Tahoe Recovery/Installer;
- instalação real começa e reconhece `Macintosh HD`;
- bloqueio atual do installer foi localizado em verificação do SharedSupport/BaseSystem;
- Toshiba/bridge/porta USB foram objeto de teste de estabilidade real;
- RTL8821CU enumera no Tahoe;
- V17 contempla explicitamente `0BDA:C820`;
- OpenCore tentou carregar `RtWlanU`;
- causa atual do driver foi localizada em `IOUSBFamily`;
- TESTE-07 preservado;
- TESTE-08 criado;
- AMFIPass candidata foi montada e validada no Windows;
- GUI/Engine base existem;
- perfil estilo Windows possui scripts de apply/rollback.

### Em andamento

- auditoria do OCLP-Mod/legacy USB patch;
- AMFIPass/root patch USB;
- diagnóstico do bloqueio `OSISVerifyBaseSystemOperation`;
- reconstrução fiel da receita Apple do Builder;
- refinamento da Engine/GUI.

### Não validado / faltante

- instalação offline completa do Tahoe do zero até Desktop via LOWDRUS;
- aceleração da HD4600;
- Wi-Fi USB funcional;
- Bluetooth USB funcional;
- Ethernet funcional;
- Bluetooth AC7260;
- Wi-Fi AC7260;
- áudio;
- mapa USB;
- sleep/wake;
- bateria/SMC final;
- teclado/trackpad/brilho completos;
- root patch com rollback comprovado;
- update engine;
- recovery interno;
- suporte remoto;
- instalação one-click real;
- reinstalação/reparo com preservação de dados;
- instalação limpa repetida para provar reprodutibilidade.

---

## 32. Próximos passos técnicos — ordem recomendada

### Trilha A — Builder / instalação offline

1. auditar completamente `postinstall_actions` do produto Apple;
2. localizar e ler `link_shared_support.bash`;
3. comparar bundle Apple, Builder local e mídia createinstallmedia;
4. identificar causa de `OSISVerifyBaseSystemOperation`;
5. validar relógio/data/assinaturas/metadados;
6. produzir Builder corrigido somente se houver diferença concreta;
7. repetir createinstallmedia;
8. retestar instalação completa no Razer;
9. promover `functionalInstallValidated=true` somente após sucesso end-to-end.

### Trilha B — USB Wi-Fi Tahoe

1. continuar auditoria do OCLP-Mod 3.1.9 e ocorrências `IOKitUSBFamily`/`IOUSBFamily`;
2. identificar exatamente o legacy USB patch;
3. documentar arquivos, destinos e pré-requisitos;
4. criar rollback antes de aplicar qualquer root patch;
5. bootar candidata AMFIPass e observar efeito real;
6. confirmar estado de SIP/AMFI/SecureBootModel necessário;
7. aplicar o mínimo patch possível;
8. verificar carga de `RtWlanU`/`RtWlanU1827`;
9. obter associação Wi-Fi real;
10. testar reboot e cold boot;
11. integrar somente após estabilidade.

### Trilha C — gráficos HD4600

1. manter independente da trilha de rede;
2. pesquisar patch Haswell/Tahoe atual;
3. construir variante de teste isolada;
4. validar aceleração real;
5. verificar estabilidade e updates;
6. integrar somente com rollback.

### Trilha D — produto LOWDRUS

1. corrigir divergências dos profiles JSON;
2. transformar checkpoints manuais em funções do Engine;
3. adicionar state machine persistente;
4. concluir identificação forte de discos;
5. implementar logs de cada etapa;
6. implementar retry/cleanup seguro;
7. ligar Manager/GUI ao fluxo de instalação real;
8. manter instalação bloqueada até os profiles finais estarem aprovados.

---

## 33. Pontos que não podem ser esquecidos

- O projeto deve ser chamado **LOWDRUS INSTALLER**, não “AUTO-INSTALLER” em documentação de produto, apesar do nome histórico do repositório.
- O fluxo final deve minimizar completamente Terminal/PowerShell para o usuário.
- A Lexar é SSD externo, não pendrive.
- Netac é recuperação conhecida como funcional e não deve ser usada como laboratório.
- Kingston `LWIFI_TEST` é laboratório experimental.
- Nunca assumir letra `G:`, `T:` ou `disk2`; esses identificadores são dinâmicos.
- `C:` do Desktop já ficou criticamente cheio; payloads grandes devem usar workspace em `F:`.
- Hash de arquivo truncado não pode ser reutilizado como hash válido do payload completo.
- O fato de `SharedSupport.dmg` ser bit-a-bit igual ao `InstallAssistant.pkg` foi comprovado e não deve ser reinterpretado como corrupção sem outra evidência.
- O driver V17 realmente conhece o VID/PID `0BDA:C820`; o bloqueio atual é compatibilidade de dependência do kernel.
- TESTE-07 é evidência e deve ficar congelado.
- TESTE-08 é laboratório para Tahoe USB/root patch.
- Ethernet está estacionada, não descartada.
- Wi-Fi interno AC7260 é última prioridade na ordem atual.
- Root patches exigem backup e rollback antes de qualquer aplicação.
- O `functionalInstallValidated` deve continuar `false` até uma instalação completa e reproduzível ser aprovada.

---

## 34. Critério para primeira versão realmente estável

A primeira versão estável do LOWDRUS INSTALLER somente deve ser declarada quando houver, no mínimo:

- mídia preparada de forma segura;
- instalação completa do Tahoe do zero;
- boot sem depender de procedimentos improvisados;
- EFI final versionada;
- gráficos utilizáveis/estratégia final definida;
- pelo menos uma forma de rede validada ou fluxo offline totalmente suficiente;
- áudio/USB/energia/teclado/trackpad/bateria essenciais validados;
- reinstalação/recovery testados;
- rollback de EFI/root patch comprovado;
- logs adequados;
- Engine e GUI executando o fluxo normal sem Terminal;
- segunda instalação completa repetida para provar reprodutibilidade.

Até lá, o projeto deve continuar explicitamente marcado como **em desenvolvimento e validação**.

---

## 35. Política de manutenção deste arquivo

Ao avançar o projeto:

- checkpoints muito detalhados devem continuar em arquivos temáticos próprios;
- este arquivo deve receber o resumo histórico e o novo estado;
- `ROADMAP.md` deve refletir checkboxes e prioridades;
- `README.md` deve permanecer enxuto e não virar changelog;
- profiles JSON devem refletir somente configurações realmente validadas;
- nunca promover hipótese experimental como fato concluído.

Este arquivo é o ponto de continuidade entre sessões para evitar perda de decisões, descobertas, falhas já diagnosticadas e próximos passos.
