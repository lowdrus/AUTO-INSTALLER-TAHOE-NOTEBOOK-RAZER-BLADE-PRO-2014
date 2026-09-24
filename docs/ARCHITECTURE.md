# LOWDRUS INSTALLER — Arquitetura

## Escopo

O **LOWDRUS INSTALLER** deste repositório é o instalador, diagnóstico e recuperação do **macOS Tahoe** para o **Razer Blade Pro RZ09-0117 (2014)**.

Ele é apenas um componente do projeto maior de multiboot do notebook. Os outros sistemas operacionais e o futuro menu principal com IA para seleção dos três sistemas **não pertencem a este repositório** e devem permanecer desacoplados.

## Princípio de interface

O fluxo normal não deve depender de Terminal.

A interface gráfica é a camada padrão para:
- instalar Tahoe;
- executar diagnóstico automático;
- aplicar correções conhecidas;
- validar novamente após correções;
- recuperar/realizar rollback;
- acompanhar progresso;
- consultar/exportar logs.

Um console técnico pode existir em **Ferramentas avançadas** como recurso opcional de emergência e desenvolvimento. Ele não deve ser requisito para instalação normal.

## Camadas

### 1. LOWDRUS Engine
Responsável por:
- identificação forte de discos e hardware;
- proteção contra seleção do disco errado;
- diagnóstico;
- auto-repair de condições conhecidas;
- validação pós-reparo;
- logs persistentes;
- backup e rollback;
- detecção de capacidades do ambiente em vez de presumir utilitários específicos.

### 2. LOWDRUS GUI
Interface padrão sobre o Engine. Operações técnicas podem usar comandos internamente, mas o usuário não deve precisar digitá-los no fluxo normal.

### 3. Hardware Profile
Perfil inicial específico do Razer Blade Pro RZ09-0117 (2014).

Estrutura pretendida:

```
profiles/
└── razer-blade-pro-rz09-0117-2014/
    ├── EFI/
    ├── ACPI/
    ├── Kexts/
    ├── Drivers/
    ├── config/
    ├── postinstall/
    ├── manifests/
    └── tests/
```

### 4. Tahoe OS Profile / Builder
Responsável pela preparação e validação do instalador Tahoe. O payload proprietário da Apple permanece separado do código publicado.

### 5. Recovery
Mídia externa validada e, futuramente, recuperação interna no SSD. A mídia Netac conhecida como funcional deve permanecer preservada como contingência durante o desenvolvimento.

### 6. Update Engine
GitHub Releases + manifesto + hash + compatibilidade + backup + validação + rollback.

## Estado técnico validado em 23/09/2026

- EFI LOWDRUS preparada e preservada;
- 42 arquivos da EFI/OpenCore validados por SHA-256;
- InstallAssistant.pkg Tahoe 26.7 (25G229) validado;
- forense do pacote confirmou que o postinstall da Apple coloca o InstallAssistant.pkg completo como `Contents/SharedSupport/SharedSupport.dmg`;
- Tahoe Builder v0.1 passou validação estrutural estática no Desktop;
- cópia direta do bundle para exFAT via Windows foi rejeitada como estratégia após falha de filesystem;
- transporte alterado para TAR;
- `Tahoe-Builder.tar` criado na Lexar com 18.437.734.400 bytes;
- SHA-256 do TAR: `7EA862E4FB009E5E7AEBCA7F9A43B0AA8471149084841CBEF95F19BEA8EE53B4`;
- TAR foi lido pelo Tahoe Recovery no Razer e a estrutura do app/SharedSupport foi observada;
- o Tahoe Recovery testado não possui `shasum` nem `openssl` no PATH; o Engine deve detectar ferramentas/capacidades disponíveis e não depender desses comandos;
- execução funcional do Builder em filesystem macOS e instalação completa do Tahoe continuam pendentes.

## Regra de segurança

Nenhum perfil de hardware é universal. Alterações críticas na EFI devem ser versionadas, validadas e possuir rollback antes de substituir uma configuração conhecida como funcional. Operações destrutivas exigem identificação forte do alvo e confirmação apropriada.
