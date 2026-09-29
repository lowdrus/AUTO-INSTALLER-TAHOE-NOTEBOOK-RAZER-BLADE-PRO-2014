# LOWDRUS INSTALLER — Arquitetura

## Escopo

O **LOWDRUS INSTALLER** deste repositório é o instalador, diagnóstico e recuperação do **macOS Tahoe** para o **Razer Blade Pro RZ09-0117 (2014)**.

Ele é apenas um componente do projeto maior de multiboot do notebook. Os outros sistemas operacionais e o futuro menu principal com IA para seleção dos três sistemas **não pertencem a este repositório** e devem permanecer desacoplados.

## Princípio de interface

O fluxo normal não deve depender de Terminal.

A interface gráfica é a camada padrão para instalar Tahoe, executar diagnóstico automático, aplicar correções conhecidas, validar novamente após correções, recuperar/realizar rollback, acompanhar progresso e consultar/exportar logs.

Um console técnico pode existir em **Ferramentas avançadas** como recurso opcional de emergência e desenvolvimento. Ele não deve ser requisito para instalação normal.

## Modos de instalação e seleção segura do destino

A GUI final deve oferecer, no mínimo:

1. **Atualizar/reinstalar preservando dados** — quando tecnicamente suportado pelo estado do sistema.
2. **Instalação limpa** — apaga somente o destino explicitamente selecionado após identificação forte e confirmação inequívoca.
3. **Instalação avançada/outro volume** — seleção explícita de volume APFS para cenários de multiboot e manutenção.

O Engine deve mostrar disco físico, capacidade, container APFS, volume e sistema detectado antes de qualquer operação destrutiva. Volumes da própria mídia LOWDRUS, EFI LOWDRUS, Recovery, Preboot e volumes técnicos protegidos não devem ser oferecidos como destinos destrutivos comuns. O fluxo final deve automatizar preparação, eventual formatação, instalação, reinicializações, OpenCore e pós-instalação sem exigir comandos de Terminal do usuário.

## Camadas

### 1. LOWDRUS Engine
Responsável por identificação forte de discos e hardware, proteção contra seleção do disco errado, diagnóstico, auto-repair, validação pós-reparo, logs persistentes, backup/rollback e detecção de capacidades do ambiente.

### 2. LOWDRUS GUI
Interface padrão sobre o Engine. Operações técnicas podem usar comandos internamente, mas o usuário não deve precisar digitá-los no fluxo normal.

### 3. Hardware Profile
Perfil inicial específico do Razer Blade Pro RZ09-0117 (2014).

### 4. Tahoe OS Profile / Builder
Responsável pela preparação e validação do instalador Tahoe. O payload proprietário da Apple permanece separado do código publicado.

### 5. Recovery
Mídia externa validada e, futuramente, recuperação interna no SSD. A mídia conhecida como funcional deve permanecer preservada como contingência durante o desenvolvimento.

**Identificação correta da mídia de desenvolvimento:** a unidade LOWDRUS é um **SSD Lexar 120 GB**. Quando o Windows apresenta `TOSHIBA External USB 3.0`, esse nome identifica o **adaptador/bridge USB usado para conectar o SSD**, não a marca/modelo da mídia LOWDRUS. A documentação e a lógica de identificação não devem chamar o SSD de Toshiba.

### 6. Update Engine
GitHub Releases + manifesto + hash + compatibilidade + backup + validação + rollback.

## Estado técnico validado até 29/09/2026

- EFI LOWDRUS preparada e preservada;
- 42 arquivos da EFI/OpenCore validados por SHA-256;
- InstallAssistant.pkg Tahoe 26.7 (25G229) validado;
- forense confirmou que o postinstall da Apple coloca o InstallAssistant.pkg completo como `Contents/SharedSupport/SharedSupport.dmg`;
- cópia direta do bundle para exFAT foi rejeitada; transporte passou a usar TAR;
- Builder V2 foi reconstruído em filesystem Linux/ext4 preservando 26 symlinks;
- `SharedSupport/SharedSupport.dmg` possui 18.381.960.622 bytes, modo POSIX corrigido para 0644 e SHA-256 `23261873087FCCA0432E6CCC293C858ED9CE5D22C528FFF801BB1653786FA9AE`;
- diretório `SharedSupport` corrigido para modo 0755;
- `Tahoe-Builder-V2.tar` possui 18.437.816.320 bytes e SHA-256 `79AC879B30E1C2A85AB38EFD8655BEBB3F48F6AEA15FD27B99C70C680F602C27`;
- TAR V2 foi copiado para o SSD Lexar LOWDRUS e validado pelo mesmo SHA-256;
- no Razer, o Lexar foi identificado pelo Windows através do bridge `TOSHIBA External USB 3.0`; isso não altera a identidade da mídia, que é Lexar 120 GB;
- OpenCore DBG-107-2026-03-20 inicializou o Recovery 26.7 (DMG);
- Recovery identificou o SSD interno físico de ~511,9 GB e o container APFS interno;
- volume técnico `LOWDRUS_TAHOE_INSTALLER` possui quota APFS de 40 GB e foi validado como gravável;
- Builder V2 foi extraído nativamente para APFS no Razer;
- `SharedSupport.dmg` extraído foi observado no bundle com aproximadamente 17 GiB;
- `startosinstall --usage` executou com sucesso diretamente do Builder V2 no Tahoe Recovery, comprovando que o executável Apple carrega nativamente no Razer;
- próxima fase: definir/proteger o volume de destino e executar a primeira instalação real controlada do Tahoe.

## Regra de segurança

Nenhum perfil de hardware é universal. Alterações críticas na EFI devem ser versionadas, validadas e possuir rollback antes de substituir uma configuração conhecida como funcional. Operações destrutivas exigem identificação forte do alvo e confirmação apropriada.
