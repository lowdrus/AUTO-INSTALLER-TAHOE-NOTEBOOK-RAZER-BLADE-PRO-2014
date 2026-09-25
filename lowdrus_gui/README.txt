LOWDRUS GUI COMPONENT

Componente visual oficial do LOWDRUS INSTALLER.

ARQUIVOS
- assets/lowdrus_razer_plush.mp4 : caminho padrão para o vídeo oficial 1920x1080.
- assets/preview.jpg              : poster/fallback visual padrão, exibido durante o carregamento ou antes da reprodução do vídeo.
- lowdrus-gui.js                  : componente sem dependências externas.
- lowdrus-gui.css                 : estilos do componente.
- demo.html                       : demonstração local.

NOTA DE VERSIONAMENTO
O código está preparado para usar automaticamente os dois assets acima. Os binários MP4/JPG só devem ser considerados publicados quando os arquivos existirem de fato em lowdrus_gui/assets/ no repositório.

ÁUDIO
- O componente não possui controle de volume.
- O vídeo é sempre mudo (muted/defaultMuted + volume 0).
- A API não expõe mute() nem setVolume().

COMO USAR
1. Copie a pasta lowdrus_gui para dentro do projeto.
2. Inclua:
   <link rel="stylesheet" href="lowdrus_gui/lowdrus-gui.css">
   <script src="lowdrus_gui/lowdrus-gui.js"></script>
3. Crie um elemento para a GUI:
   <div id="meu-background" style="width:100%;height:600px"></div>
4. Monte o componente:
   const gui = LowdrusGUI.mount('#meu-background');

ASSETS PADRÃO
Sem opções adicionais, o componente usa:
- src: assets/lowdrus_razer_plush.mp4
- poster: assets/preview.jpg

Você também pode sobrescrever os caminhos:
   const gui = LowdrusGUI.mount('#meu-background', {
     src: 'assets/lowdrus_razer_plush.mp4',
     poster: 'assets/preview.jpg'
   });

PARA COLOCAR SUA GUI POR CIMA
Use a opção content:
   const gui = LowdrusGUI.mount('#meu-background', {
     content: '<div>Minha interface</div>'
   });

API
- gui.play()
- gui.pause()
- gui.setDim(true/false)
- gui.setOpacity(0..1)
- gui.destroy()

OBSERVAÇÃO
O vídeo contém a composição visual oficial enviada para o LOWDRUS INSTALLER. O componente é a base visual; os controles funcionais ficam na camada de aplicação/Engine.
