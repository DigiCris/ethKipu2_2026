# Guía docente — 1 hora

## 0–5 min — dibujar arquitectura

```text
Frontend
  ├─ RPC Provider ──────> nodo Ethereum ──────> lecturas
  └─ Wallet Provider ──> Signer ─> transacción firmada ─> nodo

ABI + address = cómo y dónde llamar al contrato
```

## 5–30 min — ethers.js vanilla

Hacer solo estos pasos:

1. address + chainId + RPC;
2. ABI;
3. `JsonRpcProvider`;
4. `readContract.number()`;
5. `BrowserProvider(window.ethereum)` + `getSigner()`;
6. `getBalance()`;
7. `writeContract.increment()`;
8. `tx.wait()` + refetch;
9. decrement si queda tiempo.

## 30–55 min — Scaffold-ETH 2

1. `yarn chain`;
2. `yarn deploy`;
3. `yarn start`;
4. mostrar Debug Contracts;
5. `useAccount`;
6. `useScaffoldReadContract`;
7. `useScaffoldWriteContract`;
8. `isPending` + `refetch`.

## 55–60 min — cierre

Preguntas rápidas:

- ¿Qué diferencia hay entre Provider y Signer?
- ¿Para qué sirve el ABI?
- ¿Una lectura necesita firma?
- ¿Qué hace `tx.wait()`?
- ¿Qué abstrae Scaffold que hicimos a mano con ethers?
