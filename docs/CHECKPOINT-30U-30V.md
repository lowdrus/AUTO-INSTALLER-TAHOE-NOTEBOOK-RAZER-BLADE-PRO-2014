# Checkpoints #30U–#30V — Tahoe Builder / produto Apple

Data de registro: 29/09/2026

## Objetivo

Registrar a auditoria do produto Apple original usado no LOWDRUS e comparar o que foi encontrado com a receita local de reconstrução do `Install macOS Tahoe.app`, sem repetir testes já concluídos no Razer.

## #30U — Produto Apple original

Diretório auditado:

`F:\PROJETO\TRIBOOT\TAHOE-OFFLINE\142-16670 - 26.7 macOS Tahoe (25G229)`

Arquivos encontrados:

| Arquivo | Tamanho |
|---|---:|
| `com_apple_MobileAsset_MacSoftwareUpdate.plist` | 1.522.180 bytes |
| `InstallAssistant.pkg` | 18.381.960.622 bytes |
| `InstallInfo.plist` | 181 bytes |
| `MajorOSInfo.pkg` | 1.365.786 bytes |
| `UpdateBrain.zip` | 4.393.946 bytes |

### Resultado #30U

- PASS: os cinco componentes acima estão preservados no produto Apple baixado.
- Não foi encontrado arquivo `.integrityDataV1` nesse diretório; portanto, sua ausência não deve ser tratada isoladamente como prova de corrupção.
- O `InstallAssistant.pkg` continua sendo o payload mestre já revalidado anteriormente por SHA-256.

## #30V — Receita real existente no workspace

Diretório auditado:

`F:\PROJETO\TRIBOOT\TAHOE-REBUILD`

Scripts/textos encontrados e lidos:

### `extrair-tahoe.sh`

O script:

1. usa `Payload.cpio` como origem;
2. extrai o payload com `cpio -idm --no-absolute-filenames`;
3. espera obter `Applications/Install macOS Tahoe.app`;
4. inspeciona `OSInstallerSetup.framework/Versions`.

### `inspecionar-tahoe.sh`

O script:

1. extrai o arquivo `Scripts` com `cpio`;
2. lê `postinstall.sh`;
3. tenta ler `postinstall_actions/link_shared_support.bash`;
4. inspeciona no app original:
   - `Contents/SharedSupport`;
   - `Contents/Resources/createinstallmedia`;
   - `Contents/Resources/startosinstall`.

### `postinstall.sh`

Foram encontradas cópias em:

- `CHECKPOINT-13\Scripts-decoded\extracted\postinstall.sh`
- `SCRIPTS-APPLE\postinstall.sh`

O conteúdo mostrado executa, em ordem, os arquivos executáveis existentes em `postinstall_actions`.

## Comparativo acumulado #30R–#30V

| Checkpoint | Evidência | Estado |
|---|---|---|
| #30R | Workspace `F:\PROJETO\TRIBOOT` auditado; `TAHOE-REBUILD` já existente | PASS |
| #30S | `SharedSupport.dmg` completo já existia no Builder local | PASS |
| #30T | `SharedSupport.dmg` e `InstallAssistant.pkg` têm 18.381.960.622 bytes e SHA-256 `23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE` | PASS / fato comprovado |
| #30U | Produto Apple contém `InstallAssistant.pkg`, MobileAsset plist, `InstallInfo.plist`, `MajorOSInfo.pkg` e `UpdateBrain.zip` | PASS |
| #30V | Scripts locais mostram extração do payload e inspeção do mecanismo Apple de `postinstall_actions`/`link_shared_support.bash` | PASS parcial: receita ainda precisa ser reconstruída por completo |

## O que #30V NÃO prova ainda

A saída de #30V não exibiu o conteúdo de `postinstall_actions/link_shared_support.bash`. Portanto, ainda não está documentado, a partir dessa saída, o comando Apple exato que cria/vincula `SharedSupport` durante a instalação do pacote.

Também não foi demonstrado ainda, apenas pelos scripts exibidos, se `MajorOSInfo.pkg`, `UpdateBrain.zip`, `InstallInfo.plist` ou o MobileAsset plist participam da construção final do `.app` ou somente da distribuição/atualização.

Não concluir que esses arquivos estão faltando do Builder até auditar o conteúdo real de `postinstall_actions` e os metadados do bundle.

## Bloqueio funcional atual

O fluxo real no Razer continua bloqueado durante a instalação em:

`Verifying SharedSupport.dmg` → `OSISVerifyBaseSystemOperation`

A mídia criada por `createinstallmedia` boota e chega ao Tahoe Recovery/Installer, mas a instalação offline completa ainda não foi validada.

## Próxima investigação

1. localizar e ler `link_shared_support.bash` no workspace já existente;
2. listar todos os arquivos de `postinstall_actions` e seus tamanhos/permissões;
3. comparar a ação Apple original com a reconstrução `LOWDRUS-TAHOE-BUILDER`;
4. só depois decidir se o Builder precisa ser alterado;
5. não retornar ao Razer até existir uma mudança concreta e auditada para testar.
