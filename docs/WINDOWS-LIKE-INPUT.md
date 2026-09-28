# Perfil de entrada estilo Windows — LOWDRUS INSTALLER

## Objetivo

No perfil final do Razer + macOS Tahoe, o LOWDRUS INSTALLER deve oferecer uma configuração automática para reduzir a diferença muscular entre Windows e macOS, sem exigir comandos do usuário.

## Teclado

O perfil LOWDRUS usa `hidutil` nativo do macOS e aplica o seguinte mapeamento no teclado PC/Razer:

| Tecla física | Função no Tahoe com perfil LOWDRUS |
|---|---|
| Ctrl esquerdo/direito | Command esquerdo/direito |
| Windows esquerdo/direito | Control esquerdo/direito |
| Alt | Option (mantido) |

Resultado prático: atalhos usuais podem ser acionados fisicamente como no Windows, por exemplo `Ctrl+C`, `Ctrl+V`, `Ctrl+X`, `Ctrl+Z`, `Ctrl+A`, `Ctrl+S`, `Ctrl+F`, `Ctrl+T` e `Ctrl+W`, porque a tecla física Ctrl envia Command ao macOS.

A automação cria um LaunchAgent de usuário para reaplicar o mapeamento em novos logins/reboots. O fluxo final será acionado pela Engine/GUI, e não pelo Terminal.

> Escopo atual: modificadores. Home/End/Delete e atalhos específicos de aplicativos precisam ser validados separadamente antes de serem incluídos como comportamento global, para não quebrar atalhos nativos ou aplicações.

## Mouse / scroll

O LOWDRUS desativa o `Natural scrolling` do macOS (`com.apple.swipescrolldirection = false`). Assim, a roda física segue a convenção esperada do Windows: rolar a roda para baixo move o conteúdo/página para baixo.

A preferência é aplicada automaticamente ao perfil do usuário e persiste no macOS.

## Automação

- Aplicar: `scripts/macos/apply-windows-input-profile.sh`
- Rollback: `scripts/macos/restore-macos-input-profile.sh`
- O instalador final deve expor isso na GUI/pós-instalação, sem exigir Terminal.
- A operação deve ser idempotente e possuir rollback.

## Segurança / rollback

O perfil não altera EFI, SIP, root patches nem arquivos do sistema. O rollback remove o LaunchAgent LOWDRUS, limpa o `UserKeyMapping` aplicado por `hidutil` e restaura a preferência padrão do macOS para o scroll.
