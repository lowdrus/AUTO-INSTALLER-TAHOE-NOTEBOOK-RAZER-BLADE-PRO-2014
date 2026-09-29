# LOWDRUS INSTALLER — HANDOFF / ESTADO ATUAL

> **Fonte de continuidade entre chats.** Antes de executar qualquer novo teste, ler este arquivo e `docs/DEVELOPMENT-HISTORY.md`. Não repetir checkpoints marcados como concluídos, salvo se houver mudança concreta de artefato/hardware ou evidência de corrupção.
>
> Atualizado: 2026-09-29 — checkpoint **#34B concluído**.

## 1. Regra de retomada em novo chat

Se a conversa atual ficar longa, for encerrada ou perder contexto, o próximo chat deve começar pelo repositório `lowdrus/AUTO-INSTALLER-TAHOE-NOTEBOOK-RAZER-BLADE-PRO-2014` e ler, nesta ordem:

1. `docs/HANDOFF-CURRENT-STATE.md` (este arquivo);
2. `docs/DEVELOPMENT-HISTORY.md`;
3. `docs/STORAGE-MEDIA-NAMING.md`;
4. documentos especializados apontados pelo histórico.

**Não reiniciar a investigação do zero. Não repetir hashes, cópias de 18 GB, formatações, testes de Recovery ou identificação de mídia já registrados abaixo.**

## 2. Hardware/mídias — nomenclatura autoritativa

- Notebook alvo: Razer Blade Pro RZ09-0117 (2014).
- SSD interno do Razer: Samsung SATA ~512 GB.
- Mídia LOWDRUS Installer: **SSD Lexar 120 GB**.
- O Windows reporta o bridge/adaptador SATA→USB usado com a Lexar como `TOSHIBA External USB 3.0`, serial `20140922020378`, ~119.24 GiB. **TOSHIBA É O ADAPTADOR/BRIDGE, NÃO O SSD.**
- Volume principal da Lexar: `LOWDRUS`, exFAT, normalmente `G:` no Desktop.
- EFI da Lexar: `LOWDRUS_EFI`, FAT32, ~0.50 GiB.

Qualquer documentação antiga que chame essa mídia física de “Toshiba” deve ser interpretada/corrigida para **SSD Lexar 120 GB LOWDRUS conectado pelo bridge TOSHIBA External USB 3.0**.

## 3. WSL / workspace de construção

A distro original `Ubuntu` sofreu filesystem read-only após o C: ficar praticamente sem espaço. O `ext4.vhdx` original foi preservado em backup antes de reparos. Depois da liberação de espaço o Ubuntu voltou a iniciar/escrever.

Para não depender do C:, foi criada uma distro dedicada:

- WSL distro: `LOWDRUS-BUILDER`
- Ubuntu 24.04 / WSL2
- armazenamento: `F:\PROJETO\TRIBOOT\LOWDRUS-LINUX-WORKSPACE\ext4.vhdx`
- VHD virtual: 64 GB; filesystem Linux ~63 GB
- uso validado como gravável.

O Builder V2 foi materializado no EXT4 e chegou a ocupar ~18 GB.

## 4. Builder V2 transportado e validado

Artefato que foi levado ao Razer:

- arquivo: `Tahoe-Builder-V2.tar`
- tamanho: **18,437,816,320 bytes**
- SHA-256: **79AC879B30E1C2A85AB38EFD8655BEBB3F48F6AEA15FD27B99C70C680F602C27**
- 26 symlinks foram preservados no TAR.

Cópia validada na Lexar em:

`G:\LOWDRUS-TRANSPORT\V2\Tahoe-Builder-V2.tar`

O hash no Lexar coincidiu com o TAR produzido no Linux.

Dentro desse TAR, o `Info.plist` de `Install macOS Tahoe.app` contém **25G227**.

## 5. SharedSupport.dmg

No Builder V2:

- `SharedSupport.dmg`: **18,381,960,622 bytes**
- SHA-256: **23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE**
- permissões corrigidas no EXT4 para `0644`;
- diretório `SharedSupport` corrigido para `0755`.

`createinstallmedia` e `startosinstall` estão presentes. Os executáveis ainda herdaram permissões amplas do transporte anterior, mas existem e foram executáveis no teste do Razer.

## 6. Teste real no Razer / Recovery

Fluxo já realizado; **não repetir apenas para “confirmar”**:

- Lexar conectado ao Razer desligado;
- boot via OpenCore DEBUG;
- Recovery 26.7 acessado;
- Builder V2 extraído/materializado nativamente;
- `startosinstall` alcançado/executado;
- data do Recovery validada em **Tue Sep 29 15:45:49 UTC 2026**;
- SSD Samsung interno identificado como o disco da instalação antiga;
- usuário autorizou apagar a instalação antiga;
- operações APFS executadas e concluídas com `Finished APFS operation on disk4`;
- bloqueio observado durante preflight do instalador: **`com.apple.BuildInfo.preflight.error` error 9**.

A investigação atual existe para corrigir esse bloqueio antes de outra ida ao Razer.

## 7. Investigação 25G227 × 25G229

Fonte offline no Desktop:

`F:\PROJETO\TRIBOOT\TAHOE-OFFLINE\142-16670 - 26.7 macOS Tahoe (25G229)\`

Contém:

- `InstallAssistant.pkg`: **18,381,960,622 bytes**
- `InstallInfo.plist`: plist válido, mas `<dict/>` vazio.

Estrutura do PKG original listada com sucesso:

- `Bom`
- `Payload`
- `Scripts`
- `PackageInfo`
- `SharedSupport.dmg`

`PackageInfo` original informa:

- identifier: `com.apple.pkg.InstallAssistant.macOSTahoe`
- version: **25.6.229**
- app: `./Applications/Install macOS Tahoe.app`
- CFBundleShortVersionString: `21.7.02`
- CFBundleVersion: `21702`
- SourceVersion: `1882120003000000`
- payload: 950 arquivos / installKBytes 53610.

O `Payload` foi extraído separadamente para:

`F:\PROJETO\TRIBOOT\TAHOE-REBUILD\PKG-PAYLOAD-CHECK\Payload`

Tamanho observado: **17,885,792 bytes**.

Assinatura inicial do Payload:

`70 62 7a 78 ...`

Isto identifica **PBZX**. Também foi observada assinatura XZ no início do stream. `file` retornou apenas `data`; 7-Zip não estava instalado. Não repetir esses testes.

Ainda NÃO foi provado se o `25G227` interno é legítimo no Payload Apple 25.6.229 ou se o Builder anterior misturou componentes. Em vez de editar plists manualmente, decidiu-se reconstruir a partir do PKG Apple original.

## 8. Linha canônica nova — #34A/#34B

### #34A — CONCLUÍDO

O PKG original foi copiado para o filesystem EXT4 da distro dedicada:

`/InstallAssistant-25G229.pkg`

`ls -lh` mostrou ~18G em 2026-09-29 16:08.

### #34B — CONCLUÍDO

Dentro de `LOWDRUS-BUILDER` foram instaladas e confirmadas:

- `/usr/bin/xz`
- `/usr/bin/cpio`
- `/usr/bin/python3`
- `/usr/bin/git`
- `build-essential`

A saída terminou em `=== #34B OK ===`.

**PORTANTO, EM UM NOVO CHAT NÃO EXECUTAR #34A NEM #34B NOVAMENTE.**

## 9. PRÓXIMO PASSO EXATO

Continuar a partir do **#34C**.

Objetivo do #34C: **desempacotar corretamente o Payload PBZX do `/InstallAssistant-25G229.pkg` original dentro do EXT4, reconstruir/materializar o `Install macOS Tahoe.app` diretamente da fonte Apple e comparar sua identidade interna com 25G227/25G229.**

Não voltar ao Razer ainda. Não formatar discos. Não copiar novamente o TAR V2 antigo. Não editar `Info.plist` manualmente. Não repetir identificação PBZX. Não reinstalar xz/cpio/python/git/build-essential.

Depois da reconstrução canônica:

1. validar bundle e symlinks;
2. incorporar/usar o `SharedSupport.dmg` original do mesmo PKG;
3. gerar novo artefato V2 somente se consistente;
4. calcular tamanho/hash e registrar;
5. transportar uma única vez para Lexar;
6. só então retornar ao Razer e testar a instalação.

## 10. Política de documentação daqui em diante

Após cada checkpoint relevante, atualizar este HANDOFF com:

- checkpoint e resultado;
- caminhos usados;
- hashes/tamanhos relevantes;
- erro encontrado/resolvido;
- decisões irreversíveis/destrutivas autorizadas;
- itens **NÃO REPETIR**;
- próximo passo exato.

O objetivo é permitir que qualquer novo chat retome o projeto sem depender da memória da conversa anterior.