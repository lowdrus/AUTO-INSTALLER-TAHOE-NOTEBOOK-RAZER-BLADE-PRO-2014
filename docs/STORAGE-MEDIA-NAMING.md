# Convenção de nomenclatura das mídias — LOWDRUS INSTALLER

## Objetivo

Este documento fixa a nomenclatura usada no projeto para evitar confusão entre SSDs externos, pendrives, bridges/adaptadores SATA→USB e mídias de boot durante procedimentos de instalação, recuperação, clonagem, backup e testes de EFI/OpenCore.

## SSD externo LOWDRUS (Lexar 120 GB)

A mídia física usada como **LOWDRUS Installer é um SSD Lexar 120 GB** e deve ser tratada e documentada como SSD externo no contexto deste projeto.

Forma preferencial:
- `SSD Lexar 120 GB LOWDRUS`
- `SSD externo LOWDRUS (Lexar 120 GB)`
- ou `SSD externo Lexar`, quando não houver ambiguidade.

**Não chamar a Lexar de pendrive. Não chamar a Lexar de Toshiba.**

O fato de o dispositivo estar conectado por USB não muda seu tipo físico. Essa distinção precisa ser preservada em:
- README e documentação técnica;
- LOWDRUS GUI;
- mensagens de confirmação;
- scripts de preparação/diagnóstico;
- logs;
- rotinas de backup, clonagem e recuperação;
- instruções de procedimentos destrutivos.

### Bridge/adaptador reportado como `TOSHIBA External USB 3.0`

Durante os testes no PC Desktop, o Windows reporta o **adaptador/leitor/bridge SATA→USB** conectado à Lexar como:

- FriendlyName: `TOSHIBA External USB 3.0`
- Serial reportado pelo bridge: `20140922020378`
- capacidade exposta: aproximadamente `119.24 GiB`
- GPT
- `LOWDRUS_EFI` FAT32 ~0.50 GiB
- `LOWDRUS` exFAT ~118.72 GiB

**Regra autoritativa:** `TOSHIBA External USB 3.0` é a identificação do bridge/adaptador USB. A mídia física do LOWDRUS Installer é o **SSD Lexar 120 GB**.

Documentação histórica que use “Toshiba” para descrever a mídia deve ser entendida como referência à combinação antiga `Lexar + bridge TOSHIBA`, e deve ser corrigida progressivamente para eliminar a ambiguidade.

## Kingston DT 101 G2 / LWIFI_TEST

O **Kingston DT 101 G2**, atualmente identificado pelo label `LWIFI_TEST`, é um **pendrive USB** usado como mídia experimental de OpenCore para testes isolados.

Ele não deve ser confundido com o SSD externo LOWDRUS (Lexar).

## Netac

A mídia **Netac** contém a configuração OpenCore conhecida como funcional e deve permanecer preservada como contingência durante o desenvolvimento.

Ela não deve ser confundida com:
- o SSD externo LOWDRUS (Lexar);
- o pendrive Kingston `LWIFI_TEST`;
- o SSD Samsung interno do Razer.

## SSD Samsung interno

O **Samsung SATA SSD ~512 GB** é o armazenamento interno do Razer Blade Pro RZ09-0117 (2014). Durante a validação de 2026-09-29, a instalação antiga foi explicitamente autorizada pelo usuário para apagamento e o container APFS correspondente foi trabalhado no Recovery. Não assumir que o estado lógico/volumes atuais continua igual sem consultar o HANDOFF mais recente.

## Regra de segurança

Antes de qualquer operação destrutiva, o LOWDRUS deve identificar o dispositivo por múltiplos atributos, como modelo/identidade conhecida, serial reportado, tamanho, barramento e/ou label, e nunca decidir o alvo apenas pela letra de unidade ou por `diskN`.

A interface e a documentação devem mostrar explicitamente o tipo físico do dispositivo e, quando aplicável, separar **mídia física** de **bridge/adaptador reportado pelo sistema operacional**, reduzindo o risco de apagar, formatar ou sobrescrever a mídia errada.
