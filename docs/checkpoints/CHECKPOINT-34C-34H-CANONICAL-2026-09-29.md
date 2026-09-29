# LOWDRUS — Checkpoint canônico #34C → #34H

Data: 2026-09-29
Status: CONCLUÍDO até #34H

Este documento é autoritativo para evitar repetição dos testes desta fase.

## Resultado consolidado

### #34C / #34C-R — tentativas inválidas / NÃO REPETIR
- A primeira tentativa falhou porque `bsdtar` não estava instalado.
- `libarchive-tools` e `liblzma-dev` foram instalados.
- A tentativa #34C-R sofreu expansão indevida de variáveis pelo PowerShell antes do Bash: `WORK`/`PKG` chegaram vazios; foram criados `/pkg`, `/payload`, `/app` na raiz e `bsdtar -xf` ficou sem argumento.
- O processo travado foi cancelado. Não repetir esse padrão de quoting PowerShell→bash.

### #34C-V2 — falha por espaço / NÃO REPETIR
- Ao extrair o PKG inteiro, `SharedSupport.dmg: Write failed: No space left on device`.
- Causa: duplicatas gigantes no VHD EXT4 (~63 GiB).
- Estratégia abandonada: nunca extrair o PKG inteiro quando apenas Payload/metadados forem necessários.

### #34C-V3 — OK
- Duplicatas/resíduos temporários removidos.
- `/InstallAssistant-25G229.pkg` preservado.
- Extraídos somente `Payload`, `PackageInfo`, `Scripts`, `Bom`.
- Payload: `/LOWDRUS-PKG-25G229/pkg/Payload`, ~18 MB.
- EXT4 após limpeza: ~40 GiB livres / 33% usado.

### #34D — PBZX / NÃO REPETIR rotas falhas
- Heredoc Python através de PowerShell→WSL→bash falhou por quoting; Payload não foi alterado.
- Repositório `NiklasRosenstein/pbzx` foi obtido.
- Compilação original falhou por `xar/xar.h` ausente.
- `libxar-dev` não está disponível nos repositórios configurados; rota XAR abandonada.
- O fonte confirmou opção `-n` (`noxar`) para processar diretamente um Payload PBZX.

### #34D-2R — OK
- Criada variante local `pbzx-noxar.c` sem dependência XAR.
- Compilada com `-llzma`.
- Payload PBZX decodificado com sucesso.
- `/LOWDRUS-PKG-25G229/payload.cpio`: ~53 MB.

### #34D-3 — OK / descoberta decisiva
- CPIO extraído em `/LOWDRUS-PKG-25G229/app`.
- `106981 blocks` extraídos.
- Installer original encontrado em `./Applications/Install macOS Tahoe.app`.
- `Info.plist` extraído DIRETAMENTE do Payload Apple contém `25G227` duas vezes.
- CONCLUSÃO: `25G227` é legítimo no app entregue pelo PKG Apple cuja versão de pacote é `25.6.229`. Não investigar novamente 25G227 × 25G229 sem nova evidência.

### #34E — OK / installer canônico
- `SharedSupport.dmg` foi extraído DIRETAMENTE do mesmo `/InstallAssistant-25G229.pkg` para o app reconstruído.
- Caminho: `/LOWDRUS-PKG-25G229/app/Applications/Install macOS Tahoe.app/Contents/SharedSupport/SharedSupport.dmg`.
- Tamanho: `18,364,018,047` bytes.
- SHA-256: `72d8b6820595dc36ac27f43511c3b881dccb10b38ab60095085f3df9ce37d969`.
- Permissões: SharedSupport `0755`; DMG `0644`.
- `createinstallmedia` e `startosinstall` presentes e executáveis.

IMPORTANTE: o Builder V2 antigo tinha `SharedSupport.dmg` de `18,381,960,622` bytes e SHA-256 `23261873087fcca0432e6ccc293c858ed9ce5d22c528fff801bb1653786fa9ae`. É um artefato diferente. Não reutilizá-lo como SharedSupport canônico.

### #34F — OK
- `file` no SharedSupport canônico reconheceu início como DOS/MBR boot sector / BSD 4.4 / FAT32 EFI; isso isoladamente não indica corrupção.
- `Info.plist`: ~2.4K.
- `createinstallmedia`: ~134K, executável.
- `startosinstall`: ~220K, executável.
- `SharedSupport.dmg`: ~18G.
- Symlinks no app: `26`.
- Tamanho aparente do app: ~18G.

### #34G — OK / transporte canônico
- TAR criado: `/LOWDRUS-TAHOE-CANONICAL.tar`.
- SHA-256: `776466f38564a3e698a329930ce0a5c464c3363f4048d0022f106cf26a5f4c01`.
- Symlinks preservados no TAR: `26`.
- SharedSupport dentro do TAR: `18,364,018,047` bytes.

### #34H — OK / cópia íntegra na Lexar
- Mídia física: SSD Lexar 120 GB LOWDRUS. `TOSHIBA External USB 3.0` é somente o bridge/adaptador SATA→USB.
- Destino: `G:\LOWDRUS-TRANSPORT\CANONICAL\LOWDRUS-TAHOE-CANONICAL.tar`.
- Tamanho no Windows: `18,419,875,840` bytes (`17.155 GiB`).
- SHA-256 no Lexar: `776466F38564A3E698A329930CE0A5C464C3363F4048D0022F106CF26A5F4C01`.
- Hash coincide com a origem. Transporte íntegro.

## NÃO REPETIR
1. Não repetir #34A/#34B.
2. Não repetir identificação PBZX.
3. Não tentar `libxar-dev` novamente nesse Ubuntu.
4. Não repetir investigação 25G227 × 25G229: 25G227 foi provado diretamente no Payload Apple.
5. Não usar o SharedSupport antigo do Builder V2 como canônico.
6. Não copiar novamente o PKG de 18 GB para EXT4.
7. Não recriar o TAR canônico enquanto hash/origem permanecerem válidos.
8. Não transportar novamente para a Lexar: #34H já validou hash no destino.
9. Evitar comandos complexos PowerShell→bash com `$variáveis` Bash ou heredocs; usar Bash interativo quando necessário.

## Próximo passo exato

#34I: remover com segurança o SSD Lexar 120 GB LOWDRUS do PC Desktop, conectar ao Razer desligado, bootar pelo OpenCore/Recovery já validado, localizar o TAR canônico na Lexar, extrair o installer nativamente no macOS preservando metadados/symlinks e testar o installer canônico contra o bloqueio anterior `com.apple.BuildInfo.preflight.error error 9`.

O SSD Samsung interno do Razer já teve a instalação antiga autorizada para apagamento e operações APFS concluídas em fase anterior. Ainda assim, antes de qualquer nova ação destrutiva, identificar o destino por múltiplos atributos e não confiar apenas em `diskN`.
