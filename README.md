# LOWDRUS INSTALLER TAHOE — Razer Blade Pro 2014

Projeto em desenvolvimento para criar um **instalador offline de Hackintosh/macOS Tahoe**, voltado inicialmente ao **Razer Blade Pro RZ09-0117 (2014)**.

> **Status atual:** em construção e validação. A mídia externa de testes já possui EFI/OpenCore validada e o pacote original do macOS Tahoe copiado com SHA-256 conferido, mas o fluxo completo de instalação automatizada ainda não está finalizado.

## Objetivo

O LOWDRUS INSTALLER pretende transformar um processo manual de Hackintosh em um fluxo repetível, auditável e progressivamente automatizado.

A meta é permitir:
- instalação offline do macOS Tahoe;
- boot por OpenCore;
- aplicação automática do perfil de hardware validado;
- instalação/configuração dos componentes necessários ao notebook;
- pós-instalação automatizada;
- registro de logs e auditoria;
- recuperação do sistema;
- restauração de uma configuração funcional;
- atualização futura do próprio LOWDRUS via GitHub;
- possibilidade futura de manter uma cópia de recuperação no SSD interno, reduzindo a dependência de mídia externa.

## Hardware-alvo original

Este projeto foi criado e está sendo validado no seguinte equipamento:
- **Notebook:** Razer Blade Pro
- **Modelo:** RZ09-0117
- **Geração:** 2014
- **CPU:** Intel Core i7-4700HQ
- **Arquitetura/plataforma:** Intel Haswell
- **Memória:** 16 GB
- **GPU integrada:** Intel HD Graphics 4600
- **GPU dedicada:** NVIDIA GeForce GTX 860M
- **Estratégia atual no macOS:** GPU NVIDIA desabilitada; uso da Intel HD 4600
- **Armazenamento interno:** Samsung SATA SSD 512 GB
- **Wi-Fi:** Intel AC7260
- **Ethernet:** Realtek RTL8168
- **Bootloader:** OpenCore
- **Versão de OpenCore validada no desenvolvimento atual:** 1.0.7
- **SMBIOS utilizado no perfil atual:** MacBookPro11,2

### Parâmetros atuais do perfil em teste

- boot-args:
  - `-v`
  - `debug=0x100`
  - `keepsyms=1`
  - `-wegnoegpu`
  - `-no_compat_check`
- Intel HD 4600 platform-id: `05 00 26 0A`
- Intel HD 4600 device-id: `12 04 00 00`

Esses valores pertencem ao perfil de desenvolvimento atual e podem mudar conforme os testes avançarem. O arquivo efetivamente usado no boot é sempre a fonte autoritativa para promoção de um checkpoint; transcrições antigas não devem substituir a leitura do `config.plist` real.

## Este projeto serve para qualquer PC ou notebook?

**Não, a versão atual não deve ser tratada como um instalador universal.**

O LOWDRUS está sendo construído primeiro como um **instalador específico e validado para o Razer Blade Pro RZ09-0117**.

A arquitetura, porém, está sendo pensada para no futuro suportar **perfis de hardware**. Isso poderá permitir variantes para outros computadores, desde que cada modelo tenha:
- identificação de hardware;
- EFI/OpenCore própria;
- ACPI apropriado;
- kexts compatíveis;
- propriedades de dispositivos;
- ajustes de GPU, áudio, rede, USB e energia;
- SMBIOS adequado;
- testes de instalação e recuperação.

Um perfil de outro computador **não deve reutilizar cegamente** o perfil deste Razer.

## Filosofia do LOWDRUS

O projeto deve separar claramente:
1. **Core do LOWDRUS** — interface, lógica de atualização, logs, auditoria e mecanismos de instalação/recuperação.
2. **Perfil de hardware** — EFI, OpenCore, ACPI, kexts, configurações, pós-instalação e testes específicos.
3. **Payload do macOS** — tratado separadamente do código do projeto.

## Modo offline

A meta é que, após a mídia estar preparada, a instalação possa ocorrer **sem depender de internet**.

Pacote original usado durante o desenvolvimento atual:
- **macOS Tahoe 26.7**
- **Build:** 25G229
- **InstallAssistant.pkg**
- **SHA-256 validado:** `23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE`

O pacote da Apple **não será tratado como código do projeto** e não deve ser simplesmente publicado neste repositório.

## Perfil completo após instalação funcional

Depois que o Tahoe estiver plenamente funcional no Razer, o LOWDRUS deverá capturar e versionar o perfil comprovadamente estável do notebook.

Pretendemos preservar:
- EFI final;
- versão de OpenCore;
- config.plist;
- ACPI;
- kexts;
- drivers UEFI;
- boot-args;
- propriedades de dispositivos;
- ajustes de vídeo;
- áudio;
- Ethernet;
- Wi-Fi/Bluetooth quando houver solução validada;
- USB;
- energia;
- scripts de pós-instalação;
- configurações de recuperação;
- versões exatas dos componentes;
- inventário de hardware;
- logs de instalação;
- testes de integridade;
- pontos de rollback.

A finalidade é evitar refazer manualmente todo o processo em futuras reinstalações.

## Instalação limpa x restauração completa

### Instalação limpa automatizada
Instala o macOS Tahoe e aplica o perfil de hardware compatível com o equipamento.

### Restauração completa
Recupera uma instalação previamente funcional, podendo incluir configurações, aplicativos e dados conforme a estratégia de backup escolhida.

Esses dois modos não são a mesma coisa e serão mantidos separadamente.

## LOWDRUS no SSD interno

Também está planejado um **modo de recuperação interno**.

A ideia é reservar uma área apropriada no SSD Samsung do Razer para manter componentes de recuperação do LOWDRUS, permitindo iniciar processos de reparo ou reinstalação mesmo sem a mídia externa LOWDRUS.

Cuidados:
- a área de recuperação não pode ser apagada durante uma reinstalação comum;
- deve existir uma cópia externa de emergência;
- corrupção física ou substituição do SSD interno ainda exigirá mídia externa;
- a recuperação interna somente será adotada depois que o fluxo externo estiver validado.

Portanto, o objetivo é **reduzir**, e não eliminar totalmente, a necessidade de uma mídia externa de emergência.

## Suporte remoto durante instalação e recuperação

O LOWDRUS foi projetado para futuramente oferecer **suporte remoto de diagnóstico durante instalação, recuperação e pós-instalação**, sempre que o ambiente em execução possuir uma interface de rede funcional.

### Prioridade arquitetural de conexão

A arquitetura geral considera Ethernet, Wi-Fi e operação offline. Porém, durante a validação prática de hardware atual, a ordem de trabalho foi redefinida para:
1. **USB Wi-Fi/Bluetooth RTL8821CU** — prioridade atual de laboratório;
2. **Ethernet Realtek RTL8168**;
3. **Bluetooth interno Intel AC7260**;
4. **Wi-Fi interno Intel AC7260**.

A investigação de Ethernet foi estacionada enquanto o RTL8821CU é validado.

### Arquitetura planejada

Quando a rede estiver funcional, o LOWDRUS poderá iniciar um serviço remoto controlado para:
- diagnóstico;
- coleta de logs;
- inspeção do hardware;
- acompanhamento do instalador;
- execução assistida de correções;
- exportação de relatórios.

O projeto deverá preferir protocolos autenticados, como SSH, e nunca expor acesso remoto sem consentimento/configuração explícita.

### Limitação importante

**Acesso remoto não é garantido em todas as fases do boot ou instalação.** Antes do carregamento de um sistema/recovery com drivers de rede compatíveis, não existe conectividade para o LOWDRUS usar. Reinicializações também interrompem a sessão e exigem reconexão.

No hardware-alvo atual:
- Ethernet: Realtek RTL8168 (driver carregado, porém sem link físico validado no teste atual);
- Wi-Fi interno: Intel AC7260 (alternativa futura);
- Wi-Fi/Bluetooth USB em teste prioritário: Realtek RTL8821CU combo, VID 0BDA / PID C820.

A conectividade desses dispositivos no ambiente Tahoe/Recovery ainda precisa ser validada. Portanto, o suporte remoto está no roadmap e **ainda não deve ser apresentado como funcional**.

O LOWDRUS deverá manter logs localmente mesmo quando estiver offline, permitindo recuperar o diagnóstico após uma reinicialização ou falha.

## Atualizações pelo GitHub

O repositório será a fonte versionada do LOWDRUS.

A arquitetura planejada para atualização inclui:
- releases versionadas;
- manifesto de versão;
- hashes de integridade;
- compatibilidade por perfil de hardware;
- backup da versão anterior;
- atualização transacional;
- rollback;
- validação antes de substituir uma EFI conhecida como funcional.

Componentes críticos não deverão ser atualizados cegamente.

### Futuro fluxo de atualização

```
GitHub Release
      │
      ▼
Manifesto + versão + hashes
      │
      ▼
LOWDRUS verifica compatibilidade
      │
      ├── incompatível -> não instala
      │
      └── compatível
            │
            ▼
      backup da versão atual
            │
            ▼
      instalação da atualização
            │
            ▼
      validação
            │
            ├── falhou -> rollback
            │
            └── aprovado
```

## Ideias e evoluções futuras

Estas possibilidades fazem parte da arquitetura e do roadmap, mas **não devem ser confundidas com recursos já implementados**.

### Múltiplas versões do macOS

O LOWDRUS poderá evoluir de um instalador Tahoe para um sistema com **perfis de versão do macOS**, mantendo Tahoe como primeiro alvo validado.

Exemplos de famílias que poderão ser estudadas:
- macOS Big Sur;
- macOS Monterey;
- Ventura, Sonoma e Sequoia;
- Tahoe;
- versões futuras, somente depois que existirem e forem validadas.

Cada versão deverá possuir uma matriz de compatibilidade própria. O LOWDRUS não deve presumir que a mesma combinação de OpenCore, EFI, ACPI, kexts, patches, SMBIOS e pós-instalação funciona em todas as versões.

Fluxo planejado:

```
Hardware detectado
       |
       v
Hardware Profile
       |
       v
Matriz de compatibilidade
       |
       +--> macOS não validado -> bloquear/alertar
       |
       +--> macOS validado
                 |
                 v
           OS Profile específico
```

### Arquitetura multi-hardware

O Core poderá ser reutilizável, enquanto cada computador recebe seu próprio Hardware Profile. O perfil atual continua específico ao Razer Blade Pro RZ09-0117 (2014).

### Atualização automática e segura

O update engine planejado poderá consultar GitHub Releases, validar versão, hashes e compatibilidade, criar backup da configuração atual, aplicar a atualização e executar rollback em caso de falha. EFI conhecida como funcional não deverá ser substituída cegamente.

### Captura automática do perfil funcional

Depois que uma instalação estiver plenamente funcional, o LOWDRUS poderá gerar um snapshot/versionamento do perfil comprovado: EFI, OpenCore, ACPI, kexts, propriedades de dispositivos, rede, áudio, USB, energia, pós-instalação, inventário, hashes e testes.

### Recuperação interna

Está planejada uma cópia de recuperação no SSD interno para reduzir a dependência da mídia externa em reinstalações e reparos comuns. Uma mídia externa continuará necessária como contingência para falha/substituição do SSD ou corrupção grave.

### Suporte remoto e continuidade de diagnóstico

Quando Ethernet ou Wi-Fi estiver funcional no ambiente em execução, o LOWDRUS poderá oferecer diagnóstico remoto autenticado, coleta de logs e assistência. Durante fases sem rede ou reinicializações, deverá persistir logs localmente e permitir retomada posterior.

## Como instalar / executar

### Estado atual do projeto

**O instalador one-click ainda não está pronto.**

No estágio atual, o projeto está sendo construído e validado em uma mídia externa.

A mídia de desenvolvimento contém:
- GPT;
- partição EFI FAT32;
- OpenCore validado;
- partição de dados/instalação;
- pacote original do macOS Tahoe validado por SHA-256.

### Fluxo pretendido para a versão final

Quando a primeira versão estável estiver pronta:
1. baixar uma Release oficial deste repositório;
2. executar o preparador do LOWDRUS em um computador suportado;
3. selecionar o perfil de hardware correto;
4. fornecer o instalador original do macOS Tahoe quando necessário;
5. deixar o LOWDRUS preparar a mídia;
6. iniciar o notebook pela mídia LOWDRUS/OpenCore;
7. escolher **Instalar macOS Tahoe** na interface;
8. o instalador executar a instalação e o pós-install do perfil do Razer;
9. reiniciar;
10. validar hardware e registrar o relatório final.

Até a publicação de uma versão estável, **não siga esse fluxo como se estivesse concluído**.

## Interface planejada

Funções planejadas:
- Instalar macOS Tahoe;
- Reinstalar;
- Reparar boot;
- Restaurar EFI;
- Recuperar instalação;
- Diagnóstico;
- Ver logs;
- Exportar relatório;
- Atualizar LOWDRUS;
- Restaurar versão anterior;
- iniciar recuperação interna.

O fluxo normal deve ser gráfico. PowerShell/Terminal continuam aceitáveis para desenvolvimento e auditoria, mas o usuário final não deve depender deles. Um console técnico poderá existir apenas em **Ferramentas avançadas**.

## Auditoria

A meta é registrar:
- disco físico selecionado;
- serial/tamanho;
- partições;
- hashes;
- versões;
- resultado de cada etapa;
- erros;
- rollback.

Operações destrutivas devem exigir confirmação explícita e identificação forte do disco-alvo.

## Estado de desenvolvimento — 28/09/2026

Já validado:
- migração do projeto para `LOWDRUS-INSTALLER`;
- backup da EFI funcional;
- SSD externo LOWDRUS (Lexar) identificado por serial e tamanho;
- GPT criado no SSD externo LOWDRUS (Lexar);
- EFI FAT32 criada;
- **42 arquivos da EFI/OpenCore copiados e comparados por SHA-256**;
- partição de dados exFAT criada;
- `InstallAssistant.pkg` copiado para o SSD externo LOWDRUS (Lexar);
- SHA-256 do pacote copiado conferido com o original;
- Tahoe 26.7 build `25G229` instalado e inicializando no Razer;
- Tahoe Builder transportado por TAR e inspecionado no Tahoe Recovery;
- `createinstallmedia`, `createinstallmedia.dylib` e `SharedSupport.dmg` confirmados no bundle;
- RTL8821CU `0BDA:C820` confirmado no Windows e no USB do Tahoe;
- V17 auditado e compatibilidade explícita do VID/PID localizada no `RtWlanU.kext`;
- TESTE-07 inicializa Tahoe e confirmou tentativa real de carga do `RtWlanU`;
- causa do TESTE-07 localizada na dependência `com.apple.iokit.IOUSBFamily`;
- TESTE-08 criado para investigação isolada;
- EFI candidata com `AMFIPass.kext` validada por `ocvalidate` e copiada ao Kingston `LWIFI_TEST`, preservando backup da EFI anterior.

Ainda pendente:
- gerar/validar a estrutura completa de mídia de instalação do macOS;
- validar execução real de `createinstallmedia`/instalador offline;
- eliminar o fluxo manual de Terminal;
- validar todos os dispositivos do notebook;
- validar aceleração final da Intel HD 4600;
- validar solução funcional para RTL8821CU no Tahoe;
- registrar exatamente qualquer root patch, mudança de SIP/AMFI/SecureBootModel e respectivo rollback;
- capturar o perfil final estável;
- implementar mecanismo de atualização;
- implementar recuperação interna;
- testes de reinstalação e rollback.

### Documentação técnica complementar

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — arquitetura do LOWDRUS INSTALLER.
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — fases, itens validados, em teste e pendentes.
- [`docs/NETWORK-RTL8821CU-TAHOE.md`](docs/NETWORK-RTL8821CU-TAHOE.md) — auditoria V17, TESTE-07/08, `IOUSBFamily` e checkpoint AMFIPass.
- [`docs/DEVELOPMENT-STATE-2026-09-28.md`](docs/DEVELOPMENT-STATE-2026-09-28.md) — consolidação de hardware, mídias, segurança, experimentos e decisões do projeto.
- [`docs/CHECKPOINTS-29G-29O-TOSHIBA.md`](docs/CHECKPOINTS-29G-29O-TOSHIBA.md) — checkpoints do SSD externo LOWDRUS/Toshiba e Tahoe Recovery.

## Avisos

- Faça backup de dados importantes.
- Nunca reutilize uma EFI de outro computador sem revisão.
- Não presuma compatibilidade entre modelos semelhantes.
- Atualizações do macOS, OpenCore e kexts podem alterar compatibilidade.
- Tenha sempre uma mídia externa de recuperação durante a fase de desenvolvimento.
- A Netac conhecida como funcional é contingência e não deve ser usada como laboratório de mudanças.
- O Kingston `LWIFI_TEST` é mídia experimental; a letra de unidade pode mudar e não deve ser usada como única identidade do dispositivo.
