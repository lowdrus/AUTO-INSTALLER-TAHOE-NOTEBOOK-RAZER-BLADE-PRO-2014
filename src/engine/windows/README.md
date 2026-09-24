# LOWDRUS Engine — Windows Manager

Primeiro backend real da GUI no Desktop.

- somente leitura sobre discos/mídias nesta fase;
- procura a mídia LOWDRUS sem depender de letra fixa;
- valida tamanhos conhecidos rapidamente;
- em Diagnóstico, calcula SHA-256 do TAR e do InstallAssistant quando encontrados;
- nunca habilita a instalação Tahoe no Desktop;
- não formata, particiona, apaga ou altera EFI;
- gera JSON para a GUI.

A identificação física forte da Lexar e inspeção da partição EFI serão adicionadas antes de qualquer ação de escrita.
