# LOWDRUS Engine

O Engine é separado da GUI. A GUI nunca decide qual disco apagar ou modificar.

## Gate de instalação

O botão **INSTALAR macOS TAHOE** só pode ser habilitado quando o Engine retornar `installReady=true` após identificação forte do hardware, mídia, EFI, Builder/payload e alvo interno.

## Segurança inicial

- Netac conhecida como EFI de emergência: somente leitura durante o desenvolvimento.
- Samsung: nenhuma operação destrutiva sem gate/consentimento apropriado.
- Lexar: identificada por múltiplos atributos; não confiar apenas em número de disco.
- Ferramentas do Recovery são detectadas por capacidade; não presumir `shasum` ou `openssl`.
- Console técnico é opcional e fica fora do fluxo normal.

## Contrato

`contracts/status.schema.json` define o snapshot consumido pela GUI.
