# LOWDRUS INSTALLER — Checkpoints #29G–#29O — mídia Toshiba

**Data:** 28/09/2026  
**Projeto:** LOWDRUS INSTALLER TAHOE — Razer Blade Pro RZ09-0117 (2014)  
**Estado:** desenvolvimento / validação experimental

> Este documento registra somente fatos observados e validados durante os testes. Itens ainda não comprovados permanecem explicitamente pendentes.

## Objetivo desta etapa

Validar a mídia física Toshiba destinada ao projeto LOWDRUS INSTALLER e confirmar que ela contém os componentes necessários para avançar da simples cópia do payload para a materialização de uma mídia de instalação offline do macOS Tahoe.

A meta final do LOWDRUS continua sendo uma instalação para o hardware-alvo sem exigir que o usuário final digite comandos no Terminal, com EFI/OpenCore, drivers, perfil de hardware e automações incorporados ao fluxo do instalador.

## #29G — Preflight da mídia Toshiba — VALIDADO

Auditoria executada no PC DESKTOP / ARATE (DESKTOP-FGV4EKS), sem necessidade de conexão remota com o Razer e sem alterar o Razer.

Identidade observada no Windows:

- disco: `Disk 4` naquele momento;
- dispositivo: `TOSHIBA External USB 3.0`;
- serial reportado: `20140922020378`;
- barramento: USB;
- capacidade: `128035674112` bytes (~128 GB decimal);
- esquema: GPT;
- estado: Online.

Mapa de partições observado:

- partição 1: Microsoft Reserved, ~0,02 GB;
- partição 2: `LOWDRUS_EFI`, FAT32, ~0,50 GB, letra temporária `T:` durante a auditoria;
- partição 3: `LOWDRUS`, exFAT, ~118,73 GB, letra `G:` no Windows.

EFI validada pela presença de:

- `EFI/BOOT/BOOTx64.efi`;
- `EFI/OC/OpenCore.efi`;
- `EFI/OC/config.plist`.

Payload offline observado:

- `InstallAssistant.pkg`: ~17,12 GiB;
- `LOWDRUS-TRANSPORT/Tahoe-Builder.tar`: ~17,17 GiB.

Espaço observado em `LOWDRUS`:

- total: ~118,72 GiB;
- usado: ~34,30 GiB;
- livre: ~84,42 GiB.

Resultado do preflight: **EFI OpenCore presente + os dois payloads offline presentes**. Nenhum arquivo foi apagado e nenhuma partição foi formatada nessa etapa.

## #29H — Remoção segura no Windows — VALIDADO

Antes de retirar a mídia, a identidade do Toshiba foi novamente conferida por nome e serial.

Procedimento validado:

1. a letra temporária `T:` da partição `LOWDRUS_EFI` foi removida;
2. o disco Toshiba foi colocado em estado `Offline` pelo Windows;
3. o resultado confirmou `OperationalStatus: Offline` e `IsOffline: True`.

Nenhuma formatação ou exclusão foi realizada.

## Detecção no macOS Recovery — VALIDADO

Na primeira tentativa, o Toshiba não apareceu de forma utilizável no Recovery com o adaptador/leitor SATA→USB anterior.

Após trocar o adaptador/leitor de SSD, o Toshiba passou a ser enumerado corretamente pelo Recovery.

O `diskutil list` mostrou a mídia LOWDRUS como disco externo físico GPT de aproximadamente 128 GB, contendo:

- Microsoft Reserved;
- EFI `LOWDRUS_EFI` (~536,9 MB conforme exibição do Recovery);
- Microsoft Basic Data `LOWDRUS` (~127,5 GB conforme exibição do Recovery).

O identificador `diskN` é dinâmico e **não deve ser codificado de forma fixa no instalador**. O LOWDRUS deverá identificar a mídia por propriedades fortes e confirmar o disco antes de qualquer operação destrutiva.

### Descoberta importante — adaptador USB

**VALIDADO:** o adaptador/leitor SATA→USB influencia a visibilidade da mídia no ambiente macOS Recovery. A troca do adaptador resolveu a detecção do Toshiba durante este teste.

Consequência para o projeto: a documentação e o diagnóstico futuro do LOWDRUS devem considerar `adaptador/bridge USB não compatível ou não enumerado no Recovery` como uma causa possível quando a mídia existe no Windows mas não aparece no Recovery.

Isso não prova incompatibilidade universal do primeiro adaptador; registra apenas o comportamento observado neste conjunto de testes.

## Montagem da partição LOWDRUS — VALIDADO

No Recovery, a partição de dados foi montada com sucesso.

Resultado observado:

`Volume LOWDRUS on disk2s3 mounted`

O identificador `disk2s3` corresponde somente àquela enumeração da sessão e não deve ser presumido em boots futuros.

Após a montagem, foram visualizados os dois arquivos grandes esperados (~17 GB cada), correspondentes ao payload transportado para a construção do instalador.

## Auditoria de `Tahoe-Builder.tar` — VALIDADO

A listagem do arquivo:

`/Volumes/LOWDRUS/LOWDRUS-TRANSPORT/Tahoe-Builder.tar`

confirmou que o TAR contém uma árvore `Install macOS Tahoe.app`.

Foram observados componentes internos do aplicativo, incluindo frameworks e recursos do instalador.

### `createinstallmedia` — VALIDADO

A auditoria confirmou explicitamente a presença de:

- `Install macOS Tahoe.app/Contents/Resources/createinstallmedia`
- `Install macOS Tahoe.app/Contents/Resources/createinstallmedia.dylib`

Isso confirma que o payload transportado contém o utilitário de criação de mídia esperado dentro do aplicativo do instalador.

### `SharedSupport.dmg` — VALIDADO

A auditoria confirmou explicitamente:

- `Install macOS Tahoe.app/Contents/SharedSupport/SharedSupport.dmg`

Esta descoberta é importante porque confirma que a árvore transportada não contém apenas a estrutura superficial do `.app`; ela inclui também o `SharedSupport.dmg` observado no payload.

## O que estes checkpoints provam

Neste ponto foi comprovado que:

- a mídia Toshiba é detectável no Recovery usando o adaptador atual;
- a mídia possui esquema GPT;
- existe uma EFI LOWDRUS/OpenCore previamente validada no Windows;
- existe uma partição de dados LOWDRUS montável no Recovery;
- `InstallAssistant.pkg` está armazenado na mídia;
- `Tahoe-Builder.tar` está armazenado na mídia;
- o TAR contém `Install macOS Tahoe.app`;
- o aplicativo contém `createinstallmedia`;
- o aplicativo contém `createinstallmedia.dylib`;
- o aplicativo contém `Contents/SharedSupport/SharedSupport.dmg`.

## O que NÃO está validado ainda

Estes resultados **não significam que o LOWDRUS já seja um instalador one-click concluído**.

Permanece pendente, entre outros pontos:

- materializar a mídia de instalação macOS a partir do payload validado;
- validar o boot completo dessa mídia no Razer;
- validar o instalador Tahoe do início ao fim;
- eliminar os comandos manuais usados durante desenvolvimento/diagnóstico;
- incorporar a automação em uma interface adequada ao usuário final;
- validar integralmente vídeo, áudio, USB, Ethernet, Wi-Fi/Bluetooth, energia e demais dispositivos;
- capturar/versionar o perfil final comprovadamente funcional;
- automatizar pós-instalação;
- validar reinstalação, recuperação e rollback;
- validar o comportamento em uma instalação offline completa.

## Regra do projeto a partir desta etapa

Os testes de engenharia podem continuar usando Terminal enquanto o LOWDRUS está sendo construído e auditado. Entretanto, **Terminal e comandos manuais não fazem parte da experiência final pretendida para o usuário**.

Cada procedimento manual validado deverá ser convertido, quando tecnicamente apropriado, em automação segura do LOWDRUS, com:

- identificação forte do hardware e da mídia;
- preflight;
- confirmação para operações destrutivas;
- logs persistentes;
- verificação de integridade;
- tratamento de erro;
- recuperação/rollback quando aplicável.

## Próximo checkpoint

O próximo passo técnico é continuar a validação do payload e preparar a **materialização controlada da mídia de instalação do macOS Tahoe**, sem confundir o SSD interno do Razer, outras mídias conectadas ou o Recovery com o destino LOWDRUS.

Antes de qualquer operação destrutiva, o disco-alvo deverá ser identificado novamente na sessão atual.
