# Roadmap — LOWDRUS INSTALLER

## Fase 1 — Bootstrap
- [x] Projeto de trabalho migrado para LOWDRUS-INSTALLER
- [x] EFI funcional preservada
- [x] Lexar preparada em GPT
- [x] EFI validada por SHA-256
- [x] InstallAssistant.pkg copiado e validado

## Fase 2 — Tahoe Builder e transporte
- [x] Investigar estrutura real do InstallAssistant.pkg
- [x] Confirmar comportamento Apple para SharedSupport.dmg
- [x] Reconstruir Tahoe Builder v0.1
- [x] Validar estrutura estática do Builder
- [x] Abandonar cópia direta do bundle para exFAT após falha
- [x] Encapsular Builder em TAR para transporte
- [x] Validar tamanho e SHA-256 do TAR na Lexar
- [x] Confirmar leitura do TAR no Tahoe Recovery
- [ ] Extrair Builder em filesystem macOS adequado
- [ ] Validar execução real de createinstallmedia/startosinstall
- [ ] Criar mídia Tahoe totalmente inicializável
- [ ] Validar instalação no Samsung

## Fase 3 — Engine sem Terminal
- [ ] implementar detector seguro de hardware/discos
- [ ] implementar preflight automático
- [ ] implementar validação de EFI/Builder/payload
- [ ] implementar diagnóstico por regras
- [ ] implementar auto-repair para erros conhecidos
- [ ] implementar revalidação pós-reparo
- [ ] implementar logs persistentes e exportação
- [ ] implementar backup/rollback
- [ ] detectar capacidades do Recovery/ambiente automaticamente
- [ ] eliminar Terminal do fluxo normal

## Fase 4 — GUI LOWDRUS INSTALLER
- [ ] tela inicial/status
- [ ] Instalar macOS Tahoe
- [ ] Diagnóstico automático
- [ ] Reparar automaticamente
- [ ] Recuperação/rollback
- [ ] progresso e detalhes
- [ ] logs/relatórios
- [ ] Ferramentas avançadas
- [ ] console técnico opcional e escondido do fluxo normal
- [ ] bloquear operações destrutivas inseguras

## Fase 5 — Perfil final do Razer
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

## Fase 6 — Recuperação interna
- [ ] projetar partição/volume interno
- [ ] preservar recuperação em reinstalações
- [ ] testar boot sem Lexar
- [ ] manter Netac/mídia externa de emergência enquanto necessário

## Fase 7 — Atualização segura
- [ ] capturar configuração conhecida como funcional
- [ ] versionar EFI/OpenCore/ACPI/kexts/configurações e hashes
- [ ] GitHub Releases + manifesto de compatibilidade
- [ ] backup transacional
- [ ] validação pós-update
- [ ] rollback automático

## Fase 8 — Evolução futura do LOWDRUS INSTALLER
- [ ] formato de Hardware Profile reutilizável
- [ ] matriz de compatibilidade
- [ ] estudar perfis adicionais somente após o Razer/Tahoe estar estável
- [ ] estudar outros macOS como perfis separados, sem presumir compatibilidade

## Fase 9 — Suporte remoto opcional
- [ ] validar Realtek RTL8168 no ambiente necessário
- [ ] validar Intel AC7260 ou alternativa
- [ ] serviço remoto autenticado quando houver rede
- [ ] continuidade de logs entre reinicializações
- [ ] modo totalmente offline

## Fora do escopo deste repositório

O LOWDRUS INSTALLER aqui documentado pertence ao fluxo **Razer + macOS Tahoe**. O projeto maior terá outros dois sistemas operacionais e um futuro menu principal com IA para os três sistemas. Esses componentes não devem ser misturados neste repositório.
