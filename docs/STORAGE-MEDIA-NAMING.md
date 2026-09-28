# Convenção de nomenclatura das mídias — LOWDRUS INSTALLER

## Objetivo

Este documento fixa a nomenclatura usada no projeto para evitar confusão entre SSDs externos, pendrives e mídias de boot durante procedimentos de instalação, recuperação, clonagem, backup e testes de EFI/OpenCore.

## SSD externo LOWDRUS (Lexar)

A **Lexar deve ser tratada e documentada como SSD externo** no contexto deste projeto.

Forma preferencial:
- `SSD externo LOWDRUS (Lexar)`
- ou `SSD externo Lexar`, quando não houver ambiguidade.

**Não chamar a Lexar de pendrive.**

O fato de o dispositivo estar conectado por USB não muda seu tipo físico. Essa distinção precisa ser preservada em:
- README e documentação técnica;
- LOWDRUS GUI;
- mensagens de confirmação;
- scripts de preparação/diagnóstico;
- logs;
- rotinas de backup, clonagem e recuperação;
- instruções de procedimentos destrutivos.

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

O **Samsung SATA SSD 512 GB** é o armazenamento interno do Razer Blade Pro RZ09-0117 (2014), onde o macOS Tahoe está instalado durante a validação atual.

## Regra de segurança

Antes de qualquer operação destrutiva, o LOWDRUS deve identificar o dispositivo por múltiplos atributos, como modelo, serial, tamanho, barramento e/ou label, e nunca decidir o alvo apenas pela letra de unidade.

A interface e a documentação devem mostrar explicitamente o tipo físico do dispositivo para reduzir o risco de apagar, formatar ou sobrescrever a mídia errada.
