# LOWDRUS GUI

Base visual oficial do **LOWDRUS INSTALLER**.

## Assets oficiais

A GUI usa os assets versionados em:

- `lowdrus_gui/assets/lowdrus_razer_plush.mp4`
- `lowdrus_gui/assets/preview.jpg`

O vídeo é o fundo visual animado oficial e o JPG funciona como poster/fallback durante o carregamento.

## Regra de áudio

A GUI é estritamente visual. O vídeo de fundo roda **sempre mudo**:

- `muted=true`;
- `defaultMuted=true`;
- volume forçado a `0`;
- nenhum controle de volume/mute é exposto pela API.

## Integração

A camada `.lowdrus-gui__content` recebe as telas funcionais do LOWDRUS INSTALLER. O componente mantém a aparência desacoplada do LOWDRUS Engine.

O app em `src/app/index.html` carrega o componente de `src/gui` e aponta explicitamente para os assets oficiais em `lowdrus_gui/assets`.

## Estrutura

```
lowdrus_gui/
  assets/
    lowdrus_razer_plush.mp4
    preview.jpg

src/
  gui/
    lowdrus-gui.css
    lowdrus-gui.js
  app/
    index.html
    installer.css
    installer.js
```
