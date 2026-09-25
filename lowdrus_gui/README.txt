LOWDRUS GUI COMPONENT

O pacote transforma a animação do wallpaper em um componente visual reutilizável para uma GUI.

ARQUIVOS
- assets/lowdrus_razer_plush.mp4 : vídeo 1920x1080, 29.97 fps, com a pelúcia animada no canto inferior direito.
- lowdrus-gui.js                  : componente sem dependências externas.
- lowdrus-gui.css                 : estilos do componente.
- demo.html                       : demonstração local.

COMO USAR
1. Copie a pasta lowdrus_gui para dentro do seu projeto.
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
- gui.mute(true/false)
- gui.setVolume(0..1)
- gui.setDim(true/false)
- gui.setOpacity(0..1)
- gui.destroy()

OBSERVAÇÃO
O vídeo já contém a composição solicitada: cenário original + pelúcia animada no canto inferior direito. O vídeo original também foi preservado no pacote anterior do Wallpaper Engine; este componente é uma cópia de uso na GUI.
