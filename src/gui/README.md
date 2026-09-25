# LOWDRUS GUI

Base visual oficial fornecida para o LOWDRUS INSTALLER.

## Regra de áudio

A GUI é estritamente visual. O vídeo de fundo roda **sempre mudo**:
- `muted=true`;
- `defaultMuted=true`;
- volume forçado a `0`;
- nenhum controle de volume/mute é exposto pela API ou pelo fluxo normal.

## Integração

A camada `.lowdrus-gui__content` recebe as telas funcionais do LOWDRUS INSTALLER. A aparência permanece desacoplada do LOWDRUS Engine, que será responsável por operações privilegiadas e diagnóstico.

## Assets oficiais

O código espera o asset em `assets/lowdrus_razer_plush.mp4`. Nesta revisão o asset binário original foi reenviado pelo usuário, porém o conector GitHub desta sessão não expõe upload binário direto para o repositório; por isso não afirmamos que o MP4/preview já estejam versionados no GitHub.

A identidade visual oficial a preservar é: fundo escuro, marca Razer ao centro e mascote/teclado no canto inferior direito.
