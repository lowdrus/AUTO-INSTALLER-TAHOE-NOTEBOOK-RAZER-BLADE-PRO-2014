# LOWDRUS INSTALLER — RTL8821CU no macOS Tahoe 26.7

> Estado documentado em 28/09/2026. Este arquivo registra somente o que foi observado e validado durante os testes do projeto no Razer Blade Pro RZ09-0117 (2014). Itens ainda não validados continuam marcados como experimentais.

## Prioridade de rede definida durante os testes

A ordem prática adotada durante a validação de hardware foi:

1. USB Wi-Fi + Bluetooth Realtek RTL8821CU
2. Ethernet Realtek RTL8168
3. Bluetooth interno Intel AC7260
4. Wi-Fi interno Intel AC7260

A investigação de Ethernet foi estacionada durante este checkpoint para concentrar os testes no adaptador USB Wi-Fi.

## Adaptador USB em teste

Identificação confirmada no Windows e no macOS:

- chipset: Realtek RTL8821CU
- VID: `0x0BDA`
- PID: `0xC820`
- interface Wi-Fi: `MI_02`
- interface Bluetooth: `MI_00`
- produto USB observado no Tahoe: `802.11ac NIC`
- fabricante USB observado no Tahoe: `Realtek`
- link USB observado: 480 Mb/s

O dispositivo enumera corretamente no barramento USB do Tahoe.

## Driver V17 auditado

Projeto pesquisado durante os testes:

- `chris1111/Wireless-USB-OC-Big-Sur-Adapter`
- release usada na auditoria: `V17`
- asset: `Wireless.USB.OC.Big.Sur.Adapter-V17.zip`
- tamanho validado: `10,652,799` bytes
- SHA-256 validado: `F71AB9E6E85767E2A711A919FF10BCEB28DE612D9DF40E7A3D5BEFC72967BBBA`

Pacote interno auditado:

- `Wireless USB OC Big Sur Adapter.pkg`
- tamanho: `10,604,772` bytes
- SHA-256: `94FE4FDB93112BC12FB698FC2870B965BBA4F4149284B1467650A4578DD3A288`

O pacote contém os kexts:

- `RtWlanU.kext` — bundle id `com.realtek.driver.RtWlanU`, versão `1830.32.b27`
- `RtWlanU1827.kext` — bundle id `com.realtek.driver.RtWlanU1827`, versão `1827.4.b36`

## Compatibilidade explícita com 0BDA:C820

O `Info.plist` de `RtWlanU.kext` contém uma personalidade específica para o adaptador:

- chave: `RTL8821CU_C820_Combo`
- `IOProviderClass = IOUSBInterface`
- `bConfigurationValue = 1`
- `bInterfaceNumber = 2`
- `idVendor = 3034` (`0x0BDA`)
- `idProduct = 51232` (`0xC820`)

Isso confirma que o VID/PID do adaptador está contemplado pelo driver.

## TESTE-07 — injeção direta dos kexts

EFI experimental preservada como checkpoint:

- `EFI-RTL8821CU-TESTE-07`

Foram adicionados ao `OC/Kexts`:

- `RtWlanU.kext`
- `RtWlanU1827.kext`

E foram adicionadas duas entradas em `Kernel -> Add` no `config.plist`, ambas habilitadas e sem `MinKernel`/`MaxKernel`.

Validações antes do boot:

- `ocvalidate` 1.0.7: `No issues found`
- comparação semântica confirmou somente duas novas entradas em `Kernel -> Add`
- cópia para o Kingston experimental comparada por SHA-256 com a EFI de laboratório

Resultado do boot:

- Tahoe iniciou normalmente
- os kexts Realtek não apareceram como carregados
- o kernel registrou tentativa de carga de `com.realtek.driver.RtWlanU`
- a carga falhou por dependência não resolvida

Erro principal observado:

```text
Kext com.realtek.driver.RtWlanU - library kext com.apple.iokit.IOUSBFamily not found.
Can't load kext com.realtek.driver.RtWlanU - failed to resolve library dependencies.
```

Erro associado observado: `0xdc00800e`.

Conclusão do TESTE-07: a injeção pelo OpenCore foi tentada; o problema não era ausência de VID/PID no driver, e sim compatibilidade/dependência de kernel no Tahoe.

## Dependências declaradas pelos dois kexts

Auditoria do `OSBundleLibraries` de `RtWlanU.kext`:

```text
com.apple.iokit.IONetworkingFamily = 1.1
com.apple.iokit.IOUSBFamily = 1.8
com.apple.kpi.bsd = 8.0.0b2
com.apple.kpi.iokit = 8.0.0b2
com.apple.kpi.libkern = 8.0.0b2
com.apple.kpi.mach = 8.0.0b2
```

Auditoria do `RtWlanU1827.kext` mostrou a mesma lista.

Portanto, os dois kexts dependem de `com.apple.iokit.IOUSBFamily`.

## TESTE-08 — laboratório Tahoe

O `TESTE-08` foi criado como cópia separada do TESTE-07 para não modificar o checkpoint anterior.

Nome de laboratório:

- `EFI-RTL8821CU-TAHOE-TESTE-08`

Regra adotada:

- não modificar TESTE-07
- um experimento por vez
- validar com `ocvalidate`
- preservar rollback antes de qualquer alteração
- não copiar kexts antigos de sistema aleatoriamente
- não remover dependências do `Info.plist` sem evidência

## OCLP-Mod / compatibilidade USB

A investigação do OCLP-Mod 3.1.9 foi iniciada porque a solução Tahoe documentada para essa família de drivers envolve compatibilidade adicional de USB/root patch, e não apenas a presença dos dois kexts Realtek no OpenCore.

O código-fonte do OCLP-Mod 3.1.9 foi baixado apenas para auditoria no Windows. A investigação procurou referências como:

- `IOKitUSBFamily`
- `IOUSBFamily`
- `USBFamily`
- `Legacy USB`
- `USB patch`
- `old version USB`

Nenhum componente do OCLP-Mod deve ser tratado como validado no Razer apenas por existir no projeto upstream. Root patches precisam de backup, rollback e teste isolado.

## AMFIPass — estado atual

Em 28/09/2026 foi preparada uma EFI candidata contendo `AMFIPass.kext` e instalada no Kingston de testes `LWIFI_TEST` após validação com `ocvalidate` 1.0.7.

Validações registradas no Windows:

- candidata continha `OC/config.plist`
- candidata continha `OC/Kexts/AMFIPass.kext/Contents/MacOS/AMFIPass`
- `ocvalidate`: `No issues found`
- EFI anterior do Kingston foi preservada como `EFI-BACKUP-PRE-AMFIPASS-PC`
- nova EFI foi copiada para `G:\EFI`
- estrutura `BOOTx64.efi`, `OpenCore.efi`, `Lilu.kext` e `AMFIPass.kext` foi verificada
- `config.plist` instalado no Kingston foi validado novamente

SHA-256 do `config.plist` da candidata e da cópia instalada:

`E31743DF2BBC6973204B19996C211EEE84743B317E45426CC8EB647C15C3C770`

Isso prova somente a integridade da EFI candidata no Windows. Ainda não deve ser confundido com prova de funcionamento de AMFIPass, root patch ou Wi-Fi no Tahoe.

## Dispositivo experimental de boot

Durante estes testes foi usado:

- Kingston DT 101 G2
- label: `LWIFI_TEST`
- serial conhecido no laboratório: `001CC0C61232EC3113120095`
- tamanho observado: `15,606,349,824` bytes de disco
- volume FAT32 observado: `15,588,130,816` bytes

A letra de unidade não deve ser considerada identificação permanente. Antes de operações destrutivas ou substituição de EFI, reidentificar por label/modelo/serial/tamanho.

## Dispositivo de recuperação conhecido como funcional

A mídia Netac conhecida como funcional é contingência de recuperação e não deve ser alterada durante experimentos de rede/root patch.

## Estado atual

Validado:

- adaptador 0BDA:C820 enumera no Tahoe
- driver V17 contém personalidade específica para 0BDA:C820
- OpenCore tentou carregar o driver no TESTE-07
- falha foi localizada na dependência `com.apple.iokit.IOUSBFamily`
- TESTE-07 permanece como checkpoint reproduzível
- TESTE-08 foi criado para experimentos posteriores
- EFI candidata com AMFIPass foi validada e copiada ao Kingston preservando backup da EFI anterior

Ainda não validado:

- carregamento funcional dos kexts Realtek no Tahoe 26.7
- conexão Wi-Fi real
- root patch USB funcional no Razer
- necessidade final de AMFIPass e configuração mínima de AMFI/SIP
- Bluetooth do combo USB
- automação segura desse fluxo dentro do LOWDRUS INSTALLER

## Regra para integração futura no LOWDRUS

Nenhuma combinação experimental deve entrar no perfil final do Razer até passar por:

1. boot estável
2. rollback comprovado
3. carregamento dos componentes esperado
4. associação Wi-Fi real
5. teste de reboot/cold boot
6. documentação das versões e hashes
7. validação de impacto em SIP/AMFI/SecureBootModel
8. integração à Engine/GUI sem exigir Terminal no fluxo normal
