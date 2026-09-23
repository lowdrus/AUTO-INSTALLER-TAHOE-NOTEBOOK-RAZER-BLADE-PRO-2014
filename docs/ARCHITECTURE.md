# Arquitetura do LOWDRUS AUTO-INSTALLER

## Escopo inicial

O perfil inicial é específico para o **Razer Blade Pro RZ09-0117 (2014)**.

## Camadas

### 1. Core
Interface, logs, atualização, auditoria, rollback e mecanismos de instalação/recuperação.

### 2. Hardware Profiles
Cada computador suportado terá um perfil independente.

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

### 3. Payload
O instalador do macOS é tratado separadamente do código do LOWDRUS.

### 4. Recovery
Mídia externa e, futuramente, recuperação interna no SSD.

### 5. Update Engine
GitHub Releases + manifesto + hash + compatibilidade + backup + rollback.

## Regra principal

Nenhum perfil de hardware será considerado universal. Alterações críticas na EFI devem ser versionadas e testadas antes de substituir uma configuração conhecida como funcional.
