# LOWDRUS INSTALLER — Estado consolidado de desenvolvimento — 28/09/2026

Este documento consolida decisões, checkpoints e restrições que surgiram durante o desenvolvimento real e que não devem se perder entre sessões de teste.

## Escopo deste repositório

Este repositório é dedicado ao **LOWDRUS INSTALLER para macOS Tahoe no Razer Blade Pro RZ09-0117 (2014)**.

O projeto maior de multiboot/tri-boot do notebook é separado. O futuro menu principal, Windows 11, SteamOS e recursos de seleção por IA/voz não devem ser misturados com este repositório enquanto o escopo Tahoe/Razer estiver sendo estabilizado.

## Hardware-alvo conhecido

- Razer Blade Pro RZ09-0117 (2014)
- Intel Core i7-4700HQ / Haswell
- 16 GB RAM
- Intel HD Graphics 4600
- NVIDIA GTX 860M — desabilitada no macOS durante os testes atuais
- Samsung SATA SSD 512 GB interno
- Intel AC7260 Wi-Fi/Bluetooth interno
- Realtek RTL8168 Ethernet
- adaptador USB Realtek RTL8821CU Wi-Fi/Bluetooth

## Mídia LOWDRUS atual

Mídia física confirmada nesta sessão:

- TOSHIBA External USB 3.0, ~128 GB
- serial observado no Windows: `20140922020378`
- GPT
- `LOWDRUS_EFI` FAT32 ~536,9 MB
- `LOWDRUS` exFAT ~127,5 GB
- `InstallAssistant.pkg`
- `LOWDRUS-TRANSPORT/Tahoe-Builder.tar`

## Tahoe Builder / payload offline

Payload validado:

- Tahoe 26.7 build 25G229
- `InstallAssistant.pkg`
- tamanho: `18,381,960,622` bytes
- SHA-256 previamente auditado: `23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE`

Tahoe Builder:

- `Tahoe-Builder.tar`
- tamanho: `18,437,734,400` bytes
- SHA-256 previamente auditado: `7EA862E4FB009E5E7AEBCA7F9A43B0AA8471149084841CBEF95F19BEA8EE53B4`

No Recovery foram confirmados no TAR:

- `Install macOS Tahoe.app`
- `Contents/Resources/createinstallmedia`
- `Contents/Resources/createinstallmedia.dylib`
- `Contents/SharedSupport/SharedSupport.dmg`

## Checkpoints de materialização e estabilidade USB — 29P a 29Z

### #29P — preflight

Confirmados:

- fonte LOWDRUS acessível;
- `Tahoe-Builder.tar` ~17 GB;
- destino APFS `LOWDRUS_TAHOE_INSTALLER` com ~37 GiB livres;
- teste de escrita `LOWDRUS-WRITE-TEST` criado com sucesso.

### #29Q — primeira materialização

A extração do TAR para `LOWDRUS_TAHOE_INSTALLER` iniciou, mas abortou com:

```text
Error reading fd 3: Device not configured
tar: Error exit delayed from previous errors.
```

A materialização ficou parcial (~1,8 MB no volume de destino). Não deve ser tratada como instalador válido.

### Diagnóstico USB após #29Q

O Toshiba chegou a desaparecer de `diskutil list`. Após reboot do Recovery voltou a enumerar. Em outra tentativa, a partição `LOWDRUS` montou, mas a leitura da raiz produziu erros reais de I/O:

```text
Input/output error
fts_read: Device not configured
```

O disco físico continuava enumerado, mostrando que em parte dos testes a falha era de acesso/montagem/leitura do volume, não necessariamente desaparecimento permanente do hardware.

Foi trocada a porta USB física usada pelo adaptador/leitor do Toshiba.

### #29W — leitura curta após troca de porta

Com o Toshiba enumerado como `disk2` e `LOWDRUS` como `disk2s3`, foi executada leitura de 256 MiB do `InstallAssistant.pkg` para `/dev/null`:

```text
256+0 records in
256+0 records out
268435456 bytes transferred in 1.114433 secs (240871776 bytes/sec)
```

Resultado: aprovado, sem `Input/output error` ou `Device not configured`.

### #29X — leitura sustentada completa do InstallAssistant.pkg

Leitura integral para `/dev/null` aprovada após mudança de porta USB:

```text
2191+1 records in
2191+1 records out
18381960622 bytes transferred in 74.224232 secs (247654440 bytes/sec)
```

Resultado: **18,381,960,622 bytes lidos integralmente em 74,224232 s**, ~247,65 MB/s, sem erro de I/O.

Este checkpoint comprova leitura sustentada completa do payload principal na combinação atual Toshiba + adaptador/leitor + porta USB.

### #29Y — Tahoe-Builder.tar novamente acessível

Confirmado:

```text
/Volumes/LOWDRUS/LOWDRUS-TRANSPORT/Tahoe-Builder.tar
```

com tamanho apresentado pelo Recovery como ~17G.

### #29Z — leitura sustentada completa do Tahoe-Builder.tar

Leitura integral do próprio TAR para `/dev/null` aprovada:

```text
2197+1 records in
2197+1 records out
18437734400 bytes transferred in 74.9362290 secs (246045466 bytes/sec)
```

Resultado: **18,437,734,400 bytes lidos integralmente em 74,936229 s**, ~246,05 MB/s, sem erro de I/O.

Isso coincide exatamente com o tamanho previamente auditado do `Tahoe-Builder.tar`.

### Estado após #29Z

- Toshiba detectado: OK
- LOWDRUS montável: OK na porta USB atual
- leitura curta 256 MiB: OK
- leitura integral `InstallAssistant.pkg`: OK
- leitura integral `Tahoe-Builder.tar`: OK
- `LOWDRUS_TAHOE_INSTALLER`: gravável
- materialização anterior: INCOMPLETA e deve ser limpa de forma controlada antes da tentativa #2
- próxima etapa: remover somente os artefatos parciais da materialização anterior, preservar o volume dedicado e repetir a extração do Builder na porta USB agora validada

## Requisito derivado para o LOWDRUS Engine

O incidente real de I/O deve virar requisito de produto. O Engine/GUI final deve:

- detectar `Input/output error` e `Device not configured`;
- interromper imediatamente a materialização;
- nunca marcar bundle parcial como válido;
- registrar mídia, porta/bridge quando identificável e etapa da falha;
- permitir retry seguro;
- validar tamanho/hash antes de promover o payload;
- preservar rollback/limpeza controlada de materializações incompletas.

## Regra operacional atual

Para a continuação desta sessão, manter o Toshiba na **porta USB que passou os checkpoints #29W, #29X e #29Z**. Não retornar à porta que apresentou as falhas de I/O durante a materialização anterior.

O SSD Samsung interno não deve ser apagado durante experimentos de EFI/rede/Builder. Operações destrutivas exigem identificação forte do alvo.
