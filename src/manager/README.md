# LOWDRUS INSTALLER — Desktop Manager

Primeira aplicação executável do LOWDRUS no Windows.

## Estado atual

A interface WPF chama o LOWDRUS Engine real em modo somente leitura. Ela exibe o estado da mídia e oferece diagnóstico completo. O botão de instalação existe, mas permanece bloqueado no Desktop por projeto: instalar Tahoe será responsabilidade do ambiente Razer validado.

## Segurança

Esta versão não formata, particiona, apaga ou escreve na EFI. O diagnóstico SHA-256 pode demorar porque os artefatos Tahoe têm aproximadamente 18 GB cada.

## Execução de desenvolvimento

`Start-LOWDRUS-INSTALLER.cmd` inicia o Manager sem exigir que o usuário opere um Terminal interativo.
