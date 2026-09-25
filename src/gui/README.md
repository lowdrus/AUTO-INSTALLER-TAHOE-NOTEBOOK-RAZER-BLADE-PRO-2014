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

- `assets/lowdrus_razer_plush.mp4` — animação oficial fornecida pelo usuário;
- `assets/preview.jpg` — preview estático da composição;
- `lowdrus-gui.js` e `lowdrus-gui.css` — componente reutilizável.

A GUI oficial deve preservar a identidade visual enviada: fundo escuro com marca Razer ao centro e mascote/teclado no canto inferior direito.
