# Clase 12 — Arquitectura de dApps: Frontend, Providers y Hooks Web3

Material preparado para una clase práctica de aproximadamente 1 hora.

## Orden sugerido

- 0–5 min: arquitectura dApp: RPC Provider, wallet, signer, ABI y contrato.
- 5–32 min: `01_ethers_vanilla` — completar únicamente la lógica Web3 de un frontend ya armado.
- 32–55 min: `02_scaffold_eth_2` — repetir los mismos conceptos con Scaffold-ETH 2 y hooks.
- 55–60 min: comparar ambos enfoques y repasar el ciclo read → sign → broadcast → confirm → refetch.

## Contrato de referencia

Sepolia existente indicado para la clase:

`0x58F7BBab762130f983C7A7e0C84fC094bb6a7C84`

Explorer:

https://sepolia.etherscan.io/address/0x58F7BBab762130f983C7A7e0C84fC094bb6a7C84#readContract

También se incluye un `Counter.sol` mínimo con `number`, `increment` y `decrement` para que el ejemplo sea autocontenido.

> Importante: si el contrato ya desplegado usa nombres de funciones distintos, copiá el ABI real desde Etherscan o desplegá el `Counter.sol` incluido. El frontend está pensado para el contrato incluido en este material.

## RPC

El ejemplo usa un RPC público de Sepolia. Si ese endpoint se satura o deja de responder, buscá otro RPC de Sepolia en:

https://chainlist.org/
