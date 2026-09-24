# Variante: usar el contrato que ya existe en Sepolia

Para una clase de 1 hora, la práctica principal con Scaffold-ETH 2 conviene hacerla contra la red local porque muestra mejor la idea de Scaffold: contrato + deploy + ABI + frontend sincronizados.

El contrato existente indicado por el docente es:

```text
0x58F7BBab762130f983C7A7e0C84fC094bb6a7C84
```

Si querés conectarte directamente a ese contrato en Sepolia, tenés dos alternativas:

1. Configurar Sepolia como `targetNetwork` y registrar/importar el contrato externo en la configuración de contratos desplegados de Scaffold.
2. Usar wagmi/viem directamente con `address + abi` en vez de `useScaffoldReadContract`.

Para esta clase recomiendo **no gastar tiempo en esta variante**. En vanilla mostrás explícitamente address + ABI + RPC usando Sepolia; en Scaffold mostrás justamente la abstracción automática usando la red local.
