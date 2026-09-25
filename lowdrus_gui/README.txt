LOWDRUS GUI COMPONENT

Componente visual oficial do LOWDRUS INSTALLER.

ARQUIVOS
- assets/lowdrus_razer_plush.mp4 : caminho esperado para o vídeo oficial 1920x1080.
- assets/preview.jpg              : caminho esperado para o preview estático.
- lowdrus-gui.js                  : componente sem dependências externas.
- lowdrus-gui.css                 : estilos do componente.
- demo.html                       : demonstração local.

NOTA DE VERSIONAMENTO
O MP4 e o preview foram fornecidos pelo usuário, mas o conector GitHub desta sessão não oferece upload binário direto. Portanto, os arquivos acima são caminhos esperados e não devem ser considerados publicados até conferência no repositório.

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
