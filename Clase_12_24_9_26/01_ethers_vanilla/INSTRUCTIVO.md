# Práctica 1 — dApp vanilla con ethers.js

Objetivo: NO programar frontend. El HTML y CSS ya están listos. Durante la clase completamos únicamente la comunicación con Ethereum.

Tiempo sugerido: 25–30 minutos.

## 0. Abrir el proyecto

Parate en esta carpeta y levantá un servidor estático:

```bash
python -m http.server 8080
```

Abrí:

```text
http://localhost:8080
```

Vas a ver el frontend terminado visualmente, pero los botones todavía no hacen nada Web3.

---

## 1. Mostrar las tres piezas de configuración

En `app.js` ya existen:

```js
const CONTRACT_ADDRESS = "0x58F7BBab762130f983C7A7e0C84fC094bb6a7C84";
const SEPOLIA_CHAIN_ID = 11155111;
const RPC_URL = "https://ethereum-sepolia-rpc.publicnode.com";
```

Explicá solamente:

- `CONTRACT_ADDRESS`: dónde vive el contrato.
- `SEPOLIA_CHAIN_ID`: qué red esperamos.
- `RPC_URL`: nodo al que hacemos lecturas JSON-RPC.

Si el RPC falla, buscá otro Sepolia RPC en https://chainlist.org/ y reemplazá `RPC_URL`.

---

## 2. Agregar el ABI

Buscá:

```js
const COUNTER_ABI = [];
```

Reemplazalo por:

```js
const COUNTER_ABI = [
  "function number() view returns (uint256)",
  "function increment()",
  "function decrement()",
  "event CounterChanged(address indexed user, uint256 newNumber)"
];
```

Idea para explicar: el ABI es el diccionario que le dice a JavaScript qué puede llamar y cómo codificar cada llamada.

---

## 3. Crear un Provider de solo lectura

Reemplazá:

```js
let readProvider;
let readContract;
```

por:

```js
const readProvider = new ethers.JsonRpcProvider(RPC_URL);
const readContract = new ethers.Contract(
  CONTRACT_ADDRESS,
  COUNTER_ABI,
  readProvider
);
```

Idea para explicar: todavía NO conectamos MetaMask. Ya podemos leer blockchain porque leer no requiere firma.

---

## 4. Leer el contador

Reemplazá `refreshCounter()` por:

```js
async function refreshCounter() {
  try {
    const value = await readContract.number();
    $("counterValue").textContent = value.toString();
    setStatus("Lectura actualizada");
  } catch (error) {
    console.error(error);
    setStatus("Error leyendo el contrato");
  }
}
```

Y al final del archivo agregá:

```js
refreshCounter();
```

Recargá la página.

Resultado esperado: el contador aparece SIN haber conectado la wallet.

Concepto: `eth_call` → lectura → sin firma → sin gas pagado por el usuario.

---

## 5. Conectar la wallet y obtener el Signer

Reemplazá `connectWallet()` por:

```js
async function connectWallet() {
  try {
    if (!window.ethereum) {
      setStatus("No se encontró una wallet inyectada");
      return;
    }

    setStatus("Esperando autorización de la wallet...");

    walletProvider = new ethers.BrowserProvider(window.ethereum);
    await walletProvider.send("eth_requestAccounts", []);

    signer = await walletProvider.getSigner();
    connectedAddress = await signer.getAddress();

    writeContract = new ethers.Contract(
      CONTRACT_ADDRESS,
      COUNTER_ABI,
      signer
    );

    $("walletAddress").textContent = shortAddress(connectedAddress);
    setStatus("Wallet conectada");
  } catch (error) {
    console.error(error);
    setStatus("Conexión cancelada o fallida");
  }
}
```

Presioná **Connect Wallet**.

Conceptos:

- `window.ethereum`: provider inyectado por la wallet.
- `BrowserProvider`: ethers envuelve ese provider.
- `Signer`: representa la capacidad del usuario de firmar.
- El frontend nunca recibe la private key.

---

## 6. Leer el balance ETH de la wallet

Reemplazá `refreshBalance()` por:

```js
async function refreshBalance() {
  if (!connectedAddress) return;

  const balance = await readProvider.getBalance(connectedAddress);
  $("walletBalance").textContent =
    `${Number(ethers.formatEther(balance)).toFixed(4)} ETH`;
}
```

Dentro de `connectWallet()`, justo antes de `setStatus("Wallet conectada")`, agregá:

```js
await refreshBalance();
```

Concepto: seguimos usando el `readProvider`. Para consultar balance tampoco hace falta el signer.

---

## 7. Escribir: increment()

Reemplazá `increment()` por:

```js
async function increment() {
  if (!writeContract) {
    setStatus("Primero conectá la wallet");
    return;
  }

  try {
    setStatus("Esperando firma...");

    const tx = await writeContract.increment();

    setStatus(`Pendiente: ${tx.hash.slice(0, 10)}...`);

    await tx.wait();

    setStatus("Confirmada. Refrescando estado...");
    await refreshCounter();
    await refreshBalance();
  } catch (error) {
    console.error(error);
    setStatus("Transacción cancelada o revertida");
  }
}
```

Mostrá el ciclo:

1. intención en frontend;
2. popup de MetaMask;
3. firma;
4. broadcast;
5. `tx.hash`;
6. pending;
7. `tx.wait()`;
8. confirmación;
9. refetch.

---

## 8. Escribir: decrement()

Reemplazá `decrement()` por:

```js
async function decrement() {
  if (!writeContract) {
    setStatus("Primero conectá la wallet");
    return;
  }

  try {
    setStatus("Esperando firma...");
    const tx = await writeContract.decrement();
    setStatus(`Pendiente: ${tx.hash.slice(0, 10)}...`);
    await tx.wait();
    await refreshCounter();
    await refreshBalance();
    setStatus("Decrement confirmado");
  } catch (error) {
    console.error(error);
    setStatus("Transacción cancelada o revertida");
  }
}
```

---

## 9. Verificar que la wallet está en Sepolia

Después de crear `walletProvider`, podés agregar:

```js
const network = await walletProvider.getNetwork();
console.log("Chain ID:", Number(network.chainId));
```

Para pedir cambio automático a Sepolia:

```js
await window.ethereum.request({
  method: "wallet_switchEthereumChain",
  params: [{ chainId: "0xaa36a7" }]
});
```

No es necesario profundizar más. El punto es mostrar que **RPC de lectura** y **red seleccionada en la wallet** son conceptos relacionados pero distintos.

---

## 10. Opcional: Events en lugar de esperar solamente al refetch

Al final de `app.js`:

```js
readContract.on("CounterChanged", (_user, newNumber) => {
  $("counterValue").textContent = newNumber.toString();
  setStatus("Evento CounterChanged recibido");
});
```

Concepto: el contrato emite un evento y el frontend puede reaccionar.

> Si un RPC público no soporta bien suscripciones/event listeners, dejá este paso como demostración conceptual y usá `refreshCounter()` después de `tx.wait()`.

---

# Qué deberían haberse llevado de esta práctica

1. ABI + address identifican cómo hablar con un contrato.
2. Un RPC Provider permite lecturas.
3. La wallet inyecta un provider para pedir autorización al usuario.
4. El signer se usa para escrituras.
5. Read no requiere firma; write sí.
6. Una transacción pasa por firma → hash → pending → confirmación.
7. Después de confirmar, el frontend actualiza estado por refetch o eventos.

## Solución final

La implementación completa está en:

```text
solucion-final/app.js
```

Si necesitás destrabarte durante la clase, copiá ese archivo sobre `app.js`.
