LOWDRUS GUI COMPONENT

Componente visual oficial do LOWDRUS INSTALLER.

ARQUIVOS
- assets/lowdrus_razer_plush.mp4 : vídeo oficial 1920x1080 com a composição LOWDRUS/Razer.
- assets/preview.jpg              : preview estático da GUI.
- lowdrus-gui.js                  : componente sem dependências externas.
- lowdrus-gui.css                 : estilos do componente.
- demo.html                       : demonstração local.

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
