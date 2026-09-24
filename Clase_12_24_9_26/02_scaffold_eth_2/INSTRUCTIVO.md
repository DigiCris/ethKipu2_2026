# Práctica 2 — El mismo Counter con Scaffold-ETH 2

Objetivo: repetir los mismos conceptos de la práctica anterior pero viendo cuánto abstrae Scaffold-ETH 2 mediante React, wagmi, viem y sus hooks.

Tiempo sugerido: 20–25 minutos.

## 0. Crear Scaffold-ETH 2

Requisitos actuales recomendados por Scaffold-ETH 2: Node.js moderno, Yarn y Git.

Creá el proyecto:

```bash
npx create-eth@latest
```

Cuando pregunte opciones, para la clase elegí una configuración simple con **Hardhat** y las opciones por defecto del frontend.

Entrá al proyecto creado.

> También se puede clonar el repositorio, pero `create-eth` es hoy el camino recomendado por el proyecto.

---

## 1. Reemplazar el contrato por Counter.sol

Copiá:

```text
archivos-para-copiar/Counter.sol
```

a la carpeta de contratos del paquete Hardhat del Scaffold.

Normalmente:

```text
packages/hardhat/contracts/Counter.sol
```

Eliminá o ignorá el contrato de ejemplo si genera conflictos con el deploy script.

---

## 2. Preparar el deploy

La idea de este ejercicio es usar primero la red local para mostrar el hot reload de contratos.

Terminal 1:

```bash
yarn chain
```

Terminal 2:

```bash
yarn deploy
```

Terminal 3:

```bash
yarn start
```

Abrí:

```text
http://localhost:3000
```

Mostrá rápidamente **Debug Contracts**. Scaffold ya conoce la dirección y ABI del contrato desplegado.

Concepto clave: acá no tuvimos que copiar manualmente `address + ABI` al frontend.

---

## 3. Pegar el frontend starter

Copiá:

```text
archivos-para-copiar/page-starter.tsx
```

sobre la homepage del frontend, normalmente:

```text
packages/nextjs/app/page.tsx
```

El diseño ya está hecho.

Scaffold trae su botón de conexión en el header. En nuestra página ya usamos:

```tsx
const { address, isConnected } = useAccount();
```

Explicá: `useAccount` viene de wagmi y refleja el estado React de la wallet conectada.

---

## 4. Leer number() con un hook

Agregá este import:

```tsx
import { useScaffoldReadContract } from "~~/hooks/scaffold-eth";
```

Debajo de `useAccount()` agregá:

```tsx
const { data: number, refetch } = useScaffoldReadContract({
  contractName: "Counter",
  functionName: "number",
});
```

Ahora reemplazá:

```tsx
<div className="text-7xl font-bold my-5">?</div>
```

por:

```tsx
<div className="text-7xl font-bold my-5">
  {number?.toString() ?? "..."}
</div>
```

Concepto:

- En vanilla armamos `RPC + ABI + address + Contract`.
- Scaffold conoce el contrato desplegado y nos entrega un hook tipado.
- Por debajo sigue existiendo una llamada de lectura a Ethereum.

---

## 5. Preparar escritura con useScaffoldWriteContract

Completá el import:

```tsx
import {
  useScaffoldReadContract,
  useScaffoldWriteContract,
} from "~~/hooks/scaffold-eth";
```

Agregá:

```tsx
const {
  writeContractAsync: writeCounterAsync,
  isPending,
} = useScaffoldWriteContract({
  contractName: "Counter",
});
```

Concepto: `isPending` ya nos da un estado React útil para UX.

---

## 6. Implementar increment

Reemplazá el botón de increment por:

```tsx
<button
  className="btn btn-primary"
  disabled={!isConnected || isPending}
  onClick={async () => {
    await writeCounterAsync({
      functionName: "increment",
    });
    await refetch();
  }}
>
  {isPending ? "Pendiente..." : "+ Increment"}
</button>
```

Probalo.

Conceptos a remarcar:

- La wallet sigue pidiendo firma.
- Sigue existiendo una transacción.
- Sigue existiendo pending y confirmación.
- Scaffold/wagmi manejan mucha infraestructura por nosotros.

---

## 7. Implementar decrement

Reemplazá el botón de decrement por:

```tsx
<button
  className="btn"
  disabled={!isConnected || isPending}
  onClick={async () => {
    await writeCounterAsync({
      functionName: "decrement",
    });
    await refetch();
  }}
>
  − Decrement
</button>
```

---

## 8. Refactor corto para mostrar una dApp real

En vez de repetir lógica, agregá:

```tsx
const send = async (functionName: "increment" | "decrement") => {
  try {
    await writeCounterAsync({ functionName });
    await refetch();
  } catch (error) {
    console.error(error);
  }
};
```

Y los botones quedan:

```tsx
<button
  className="btn"
  disabled={!isConnected || isPending}
  onClick={() => send("decrement")}
>
  − Decrement
</button>

<button
  className="btn btn-primary"
  disabled={!isConnected || isPending}
  onClick={() => send("increment")}
>
  {isPending ? "Pendiente..." : "+ Increment"}
</button>
```

---

## 9. Mostrar Hot Reload / Debug Contracts

Si te quedan 2 minutos:

1. Cambiá algo trivial en `Counter.sol`.
2. Volvé a ejecutar `yarn deploy` si corresponde.
3. Mostrá cómo Scaffold actualiza sus contratos desplegados y la Debug UI.

No profundices en Next.js. El foco es la abstracción Web3.

---

# Comparación para cerrar la clase

### Vanilla + ethers

Nosotros manejamos explícitamente:

```text
RPC → Provider → ABI + address → Contract → Signer → tx.wait() → refetch
```

### Scaffold-ETH 2

Gran parte queda abstraída:

```text
useAccount
useScaffoldReadContract
useScaffoldWriteContract
```

Pero debajo siguen existiendo los mismos conceptos: RPC, provider, wallet, ABI, calldata, firma, transacción y confirmación.

## Solución final

Está en:

```text
archivos-para-copiar/solucion-final/page.tsx
```
