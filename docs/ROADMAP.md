# Roadmap

## Fase 1 — Bootstrap
- [x] Projeto renomeado para LOWDRUS-INSTALLER
- [x] EFI funcional preservada
- [x] Lexar preparada em GPT
- [x] EFI validada por SHA-256
- [x] InstallAssistant.pkg copiado e validado

## Fase 2 — Instalador Tahoe
- [ ] Criar mídia de instalação completa
- [ ] Validar boot
- [ ] Validar instalação no Samsung
- [ ] Remover dependência de procedimentos manuais

## Fase 3 — Perfil final do Razer
- [ ] GPU Intel HD 4600
- [ ] áudio
- [ ] Ethernet
- [ ] Wi-Fi
- [ ] Bluetooth
- [ ] USB
- [ ] energia/sleep
- [ ] teclado/trackpad
- [ ] pós-instalação
- [ ] inventário completo
- [ ] perfil versionado

## Fase 4 — Produto LOWDRUS
- [ ] interface gráfica
- [ ] one-click
- [ ] diagnósticos
- [ ] logs persistentes
- [ ] restauração
- [ ] rollback
- [ ] update engine

## Fase 5 — Recuperação interna
- [ ] projetar partição/volume interno
- [ ] preservar recuperação em reinstalações
- [ ] testar boot sem Lexar
- [ ] manter mídia externa de emergência

## Fase 6 — Multi-hardware
- [ ] formato de Hardware Profile
- [ ] detector de hardware
- [ ] matriz de compatibilidade
- [ ] perfil adicional de teste

## Fase 7 — Multi-macOS
- [ ] definir formato de OS Profile
- [ ] criar matriz Hardware Profile x versão do macOS
- [ ] manter Tahoe como primeiro perfil de SO validado
- [ ] estudar Big Sur e Monterey no hardware suportado
- [ ] estudar outras versões existentes individualmente
- [ ] permitir versões futuras somente após validação real
- [ ] impedir seleção automática de combinações não validadas

## Fase 8 — Suporte remoto e continuidade
- [ ] validar Realtek RTL8168 no ambiente de instalação/Recovery
- [ ] validar Intel AC7260 ou alternativa compatível no ambiente necessário
- [ ] serviço remoto autenticado quando houver rede
- [ ] logs persistentes entre fases/reinicializações
- [ ] exportação e retomada de diagnóstico
- [ ] modo totalmente offline quando a rede estiver indisponível

## Fase 9 — Perfil funcional e atualização segura
- [ ] capturar automaticamente configuração conhecida como funcional
- [ ] versionar EFI/OpenCore/ACPI/kexts/configurações e hashes
- [ ] GitHub Releases + manifesto de compatibilidade
- [ ] backup transacional antes de atualização
- [ ] validação pós-update
- [ ] rollback automático em caso de falha
