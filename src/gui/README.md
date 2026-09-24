# LOWDRUS GUI

Base visual oficial fornecida para o LOWDRUS INSTALLER.

## Regra de áudio

A GUI é visual. O vídeo de fundo é sempre iniciado com `muted=true`, `defaultMuted=true` e volume zero. O componente não expõe controles de volume/mute no fluxo normal.

## Integração

A camada `.lowdrus-gui__content` recebe as telas funcionais do LOWDRUS INSTALLER. A aparência permanece desacoplada do LOWDRUS Engine, que será responsável por operações privilegiadas e diagnóstico.

> O arquivo de vídeo/preview é um asset binário fornecido separadamente e não deve ser confundido com código-fonte.
