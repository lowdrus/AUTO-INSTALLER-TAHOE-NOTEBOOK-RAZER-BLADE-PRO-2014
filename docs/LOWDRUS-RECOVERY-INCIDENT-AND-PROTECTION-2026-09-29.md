# LOWDRUS — Incidente Recovery, proteção da mídia e checkpoints #34–#35

Data: 29/09/2026

## Objetivo

Registrar de forma permanente o incidente ocorrido durante a evolução do instalador LOWDRUS, os artefatos validados, a regressão do Recovery e as regras obrigatórias para impedir novas alterações experimentais na mídia principal.

## Regra crítica a partir deste ponto

**O Lexar/LOWDRUS é a mídia principal do instalador offline e deve ser tratado como artefato protegido.**

Nenhuma alteração experimental deve ser feita nele sem:

1. identificação física inequívoca do dispositivo;
2. preflight somente leitura;
3. backup da área que será modificada;
4. validação do backup;
5. alteração mínima e isolada;
6. validação pós-escrita;
7. rollback definido antes do teste físico.

Não formatar, reparticionar, substituir EFI, Recovery ou payload canônico por tentativa/erro.

## Identidade física conhecida

### Lexar / LOWDRUS

No Windows o dispositivo aparece através da bridge como:

- FriendlyName: `TOSHIBA External USB 3.0`
- Serial: `20140922020378`
- Bus: USB
- GPT
- capacidade observada em #35Q: 119,24 GiB
- em #35Q: Disco 5 (número de disco é circunstancial e deve ser revalidado a cada sessão)

Mapa observado em #35Q:

- P1 Reserved ~0,02 GiB
- P2 System / EFI ~0,50 GiB
- P3 Basic ~2,00 GiB
- P4 Basic ~116,73 GiB

### SSD Netac / ARATE_REC

O SSD Netac está conectado por adaptador/leitor que o Windows identifica como `KNUP`.

Observado em #35Q:

- FriendlyName: `KNUP`
- Serial reportado pelo adaptador: `0123456789ABCDEF`
- Bus: USB
- GPT
- capacidade: 111,79 GiB
- em #35Q: Disco 4 (circunstancial)

Mapa observado:

- P1 Reserved ~0,02 GiB
- P2 System / EFI ~0,50 GiB
- P3 Basic ~2,00 GiB

O Netac possui a entrada `ARATE_REC (external) (dmg)` já testada fisicamente no Razer. Ao selecioná-la, o macOS Recovery apresenta **Reinstalar macOS Tahoe**, além de Time Machine, navegador/Safari e Utilitário de Disco. Portanto esta mídia é a referência funcional conhecida para o Recovery Tahoe.

## Installer Tahoe canônico reconstruído

### #34D-2R — PBZX

O Payload do InstallAssistant foi decodificado com uma variante `pbzx-noxar` compilada sem dependência XAR. Resultado:

- `payload.cpio`: ~53 MiB
- operação concluída com sucesso.

### #34D-3 — aplicativo Apple original

O CPIO materializou:

`Applications/Install macOS Tahoe.app`

O `Info.plist` interno reportou build `25G227` em dois campos observados. Esse fato deve permanecer documentado separadamente do nome/artefato externo 25G229 para investigação de versionamento; não alterar metadados Apple apenas para fazê-los coincidir.

### #34E — SharedSupport original

`SharedSupport.dmg` foi extraído diretamente do pacote e colocado em:

`Install macOS Tahoe.app/Contents/SharedSupport/SharedSupport.dmg`

Validação:

- tamanho: `18,364,018,047` bytes
- SHA-256: `72d8b6820595dc36ac27f43511c3b881dccb10b38ab60095085f3df9ce37d969`
- `startosinstall`: presente/executável
- `createinstallmedia`: presente/executável

### #34F — estrutura

Confirmados:

- `Info.plist`
- `createinstallmedia`
- `startosinstall`
- `SharedSupport.dmg`
- 26 symlinks
- aplicativo total ~18 GiB

### #34G — transporte canônico

Foi criado:

`/LOWDRUS-TAHOE-CANONICAL.tar`

Validação:

- tamanho Windows posterior: `18,419,875,840` bytes
- SHA-256: `776466f38564a3e698a329930ce0a5c464c3363f4048d0022f106cf26a5f4c01`
- 26 symlinks preservados
- `SharedSupport.dmg` presente no TAR.

### #34H — cópia íntegra para LOWDRUS

Destino:

`LOWDRUS-TRANSPORT/CANONICAL/LOWDRUS-TAHOE-CANONICAL.tar`

Hash no destino coincidiu exatamente com a origem:

`776466F38564A3E698A329930CE0A5C464C3363F4048D0022F106CF26A5F4C01`

Este TAR é artefato canônico e não deve ser apagado durante correções de Recovery/EFI.

## Falha de boot OpenCore

Após testes físicos pelo F12, o OpenCore inicialmente apresentava:

```text
OCB: System has no boot entries
OC: Failed to show boot menu!
Halting on critical error
```

A auditoria confirmou EFI/OpenCore presentes, incluindo:

- `EFI/BOOT/BOOTx64.efi`
- `EFI/OC/OpenCore.efi`
- `EFI/OC/config.plist`
- `OpenRuntime.efi`
- `HfsPlus.efi`
- ACPI e kexts do perfil atual.

Configuração observada:

- ShowPicker = true
- HideAuxiliary = true
- PickerMode = Builtin
- ScanPolicy = 0
- RequestBootVarRouting = true
- DmgLoading = Signed
- SecureBootModel = Disabled

## Recovery baixado por macrecovery — incidente

No #34P foi usado `macrecovery.py` com os parâmetros então escolhidos. Foram obtidos e verificados:

- `BaseSystem.dmg`: `884,317,790` bytes
- `BaseSystem.chunklist`: `3,352` bytes
- SHA-256 DMG: `7314EB401F5E84087F621B3599F0AD21CA3CDCC2685EA2DA7F76806792328E20`
- SHA-256 chunklist: `DBF262B83A16D55F1B2D8CE8CE95986561F8E889719524EA4B7AA22A2417CA27`

Esses artefatos foram posteriormente colocados na estrutura de Recovery do LOWDRUS.

**Resultado físico:** essa Recovery abriu a interface de **macOS Sequoia**, não Tahoe.

Portanto esses hashes identificam, no contexto deste projeto, o conjunto de Recovery que **não deve ser promovido como Recovery Tahoe do LOWDRUS**.

## Evolução #35

Foram criadas/testadas estruturas de Recovery FAT32 e ajustes do OpenCore até o picker finalmente reconhecer uma entrada DMG. O picker passou de `System has no boot entries` para mostrar uma entrada `NO NAME (external) (dmg)`.

Ao inicializar essa entrada, entretanto, apareceu **Reinstalar macOS Sequoia**. Isso revelou que a descoberta/boot do DMG estava funcionando, mas o conteúdo da Recovery era a versão errada para o objetivo do projeto.

Foi também observado que o SSD Netac já possuía `ARATE_REC (external) (dmg)` e, ao inicializá-lo, aparecia corretamente **Reinstalar macOS Tahoe**.

## #35N — cuidado com falso positivo

O `ocvalidate` 1.0.7 encontrou um problema real:

```text
Booter->Quirks->EnableSafeModeSlide is enabled, but ProvideCustomSlide is not enabled altogether!
CheckBooter returns 1 error!
```

Logo, apesar de uma mensagem posterior do script ter impresso `#35N APROVADO`, o checkpoint **não deve ser interpretado como aprovação integral do config**. O erro do `ocvalidate` deve permanecer registrado e corrigido/validado separadamente antes de promover o config como final.

## #35P — safe eject

O LOWDRUS foi colocado Offline com segurança antes do teste físico. O teste posterior confirmou que o OpenCore carregava e enxergava o DMG, mas esse DMG era Sequoia.

## #35Q — identificação simultânea Netac x LOWDRUS

Com os dois dispositivos conectados:

- Disco 4: KNUP, 111,79 GiB — SSD Netac através do adaptador KNUP
- Disco 5: TOSHIBA External USB 3.0, serial 20140922020378, 119,24 GiB — Lexar/LOWDRUS

Ambos estavam Offline no início da auditoria.

A descoberta importante foi que ambos possuem uma P3 Basic de ~2 GiB.

## #35R — tentativa de comparação das P3

Após colocar os discos Online:

- Netac P3 apareceu como `G:`
- LOWDRUS P3 apareceu como `H:`
- ambas ~2,00 GiB

O script #35R havia sido escrito supondo que P3 ainda não tivesse letra e tentou usar letras temporárias `R:` e `T:`. Como as P3 já receberam automaticamente `G:` e `H:`, os blocos de `Add-PartitionAccessPath` não executaram e `Get-Volume R/T` falhou.

Erros observados:

```text
Get-Volume: Nenhum MSFT_Volume encontrado com a propriedade 'DriveLetter' igual a 'R'.
Get-Volume: Nenhum MSFT_Volume encontrado com a propriedade 'DriveLetter' igual a 'T'.
```

**Conclusão:** #35R não comparou o conteúdo das Recoveries. Também não apagou nem copiou arquivos. A próxima auditoria deve usar as letras reais retornadas dinamicamente pelo Windows, e nunca presumir R:/T:.

## Regra para scripts futuros

Scripts de mídia devem:

- identificar dispositivos por FriendlyName + serial + tamanho/mapa quando possível;
- nunca confiar apenas em `DiskNumber`;
- descobrir `DriveLetter` após colocar a mídia Online;
- não presumir que uma partição sem letra continuará sem letra;
- abortar se identidade/mapa divergir;
- separar claramente comandos somente leitura de comandos destrutivos;
- proteger explicitamente o LOWDRUS antes de qualquer escrita;
- preservar o instalador canônico offline e sua EFI;
- usar o Netac/ARATE_REC apenas como referência conhecida do Recovery Tahoe até que sua estrutura seja auditada.

## Próxima etapa correta

1. Auditar dinamicamente a P3 do Netac/ARATE_REC (atualmente observada como G: em #35R).
2. Auditar dinamicamente a P3 do LOWDRUS (H: em #35R).
3. Comparar estrutura, arquivos, tamanhos e hashes sem escrita.
4. Identificar precisamente o conjunto Tahoe funcional do Netac.
5. Antes de qualquer correção no LOWDRUS, criar e validar backup da P3 atual.
6. Alterar somente a Recovery, se e somente se a comparação provar o procedimento.
7. Não tocar na EFI P2 nem no payload/instalador offline durante essa correção.
8. Após restaurar um Recovery Tahoe funcional no LOWDRUS e validar por F12, retornar ao trabalho do adaptador Wi-Fi do Razer no ponto anterior.

## Estado resumido

- Installer offline Tahoe canônico: **preservar**.
- EFI LOWDRUS: **preservar; nenhuma substituição experimental**.
- Recovery atual LOWDRUS: bootável pelo OpenCore, mas identificada visualmente como **Sequoia**.
- Netac `ARATE_REC`: referência física comprovada que abre **Reinstalar macOS Tahoe**.
- #35R: comparação ainda **não executada**, devido às letras automáticas G:/H:.
- Próximo passo: auditoria somente leitura das duas P3 usando letras detectadas dinamicamente.
