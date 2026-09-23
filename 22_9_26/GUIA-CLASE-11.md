# Clase 11 — Transparencia y Diagnóstico: Verificación y Debugging

Deploy en Sepolia, verificación en Etherscan y debugging con Tenderly.

Probado con `forge` / `cast` **1.5.1-stable**.

---

# Paso 0 — El proyecto

Ya está armado en `clase-11-debugging/`. Esto es lo que contiene.

`src/Counter.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    uint256 public count;

    error CounterIsZero();

    event Incremented(address indexed caller, uint256 newCount);
    event Decremented(address indexed caller, uint256 newCount);

    function increment() external {
        count += 1;
        emit Incremented(msg.sender, count);
    }

    function decrement() external {
        if (count == 0) {
            revert CounterIsZero();
        }
        count -= 1;
        emit Decremented(msg.sender, count);
    }
}
```

`script/DeployCounter.s.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract DeployCounter is Script {
    function run() external returns (Counter counter) {
        uint256 deployerPk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPk);
        counter = new Counter();
        vm.stopBroadcast();

        console.log("Counter deployed at:", address(counter));
    }
}
```

`foundry.toml` — estos valores son los que después tienen que coincidir en Etherscan:

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]

solc_version = "0.8.28"
optimizer = true
optimizer_runs = 200
evm_version = "cancun"
```

`.env` — ya trae la wallet de laboratorio generada con `cast wallet new`:

```env
PRIVATE_KEY=0x...
WALLET_ADDRESS=0x...

SEPOLIA_RPC_URL=
ETHERSCAN_API_KEY=

SEPOLIA_COUNTER_ADDRESS=
TENDERLY_VNET_RPC_URL=
VNET_COUNTER_ADDRESS=
```

> Esta clave es descartable para laboratorio/Sepolia. Nunca la reutilices con fondos reales.

`.env` ya está en `.gitignore`.

---

# Paso 1 — Pre-flight

```bash
cd clase-11-debugging
forge build
forge test
```

Resultado esperado:

```text
Compiler run successful!
...
Suite result: ok. 5 passed; 0 failed; 0 skipped
```

---

# Paso 2 — Configurar Sepolia

Completá en `.env`:

```env
SEPOLIA_RPC_URL=...
ETHERSCAN_API_KEY=...
```

Después:

```bash
source .env
cast chain-id --rpc-url $SEPOLIA_RPC_URL
```

Resultado esperado:

```text
11155111
```

---

# Paso 3 — Comprobar que la key corresponde a la address

```bash
[ "$(cast wallet address --private-key $PRIVATE_KEY)" = "$WALLET_ADDRESS" ] \
  && echo "OK: la private key corresponde a WALLET_ADDRESS" \
  || echo "ERROR: no coinciden"
```

```text
OK: la private key corresponde a WALLET_ADDRESS
```

---

# Paso 4 — Mostrar la wallet a fondear

```bash
echo $WALLET_ADDRESS
```

> Enviá Sepolia ETH a esta address antes de continuar.

---

# Paso 5 — Comprobar balance

```bash
cast balance $WALLET_ADDRESS --rpc-url $SEPOLIA_RPC_URL
cast balance $WALLET_ADDRESS --ether --rpc-url $SEPOLIA_RPC_URL
```

Si da `0`:

```text
No continúes hasta fondear la wallet.
```

---

# Paso 6 — Deploy en Sepolia

```bash
forge script script/DeployCounter.s.sol:DeployCounter \
  --rpc-url $SEPOLIA_RPC_URL \
  --broadcast
```

Resultado esperado:

```text
  Counter deployed at: 0x....

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
```

Guardar la address en `.env`:

```bash
ADDR=$(grep -m1 '"contractAddress"' broadcast/DeployCounter.s.sol/11155111/run-latest.json \
  | grep -oE '0x[0-9a-fA-F]{40}')

sed -i "s|^SEPOLIA_COUNTER_ADDRESS=.*|SEPOLIA_COUNTER_ADDRESS=$ADDR|" .env

source .env
echo $SEPOLIA_COUNTER_ADDRESS
```

Guardar el bloque de deploy (lo usa `cast logs` al final):

```bash
DEPLOY_TX=$(grep -m1 '"hash"' broadcast/DeployCounter.s.sol/11155111/run-latest.json \
  | grep -oE '0x[0-9a-fA-F]{64}')

DEPLOY_BLOCK=$(cast receipt $DEPLOY_TX blockNumber --rpc-url $SEPOLIA_RPC_URL)
echo $DEPLOY_BLOCK
```

Confirmar que hay bytecode en la address:

```bash
cast code $SEPOLIA_COUNTER_ADDRESS --rpc-url $SEPOLIA_RPC_URL | head -c 60
```

Si devuelve algo distinto de `0x`, el contrato existe.

---

# Paso 7 — Ver el contrato en Etherscan

```bash
echo "https://sepolia.etherscan.io/address/$SEPOLIA_COUNTER_ADDRESS"
```

1. Abrí la URL.
2. Entrá en la pestaña `Contract`.
3. Todavía aparece sin verificar (solo bytecode).

---

# Paso 8 — Verificar en Etherscan

Para que coincida el bytecode deben ser iguales:

* versión de Solidity (`0.8.28`)
* optimizer (`true`)
* optimizer runs (`200`)
* EVM version (`cancun`)
* constructor arguments (acá: ninguno)

Todo eso está fijado en `foundry.toml` y Forge lo toma de ahí.

```bash
forge verify-contract $SEPOLIA_COUNTER_ADDRESS src/Counter.sol:Counter \
  --chain sepolia \
  --verifier etherscan \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --watch
```

`--verifier etherscan` es obligatorio: en Foundry 1.5 el verificador por defecto es Sourcify.

Resultado esperado:

```text
Submitting verification for [src/Counter.sol:Counter] 0x....
Submitted contract for verification:
	Response: `OK`
	GUID: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
	URL: https://sepolia.etherscan.io/address/0x....
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
```

Consultar el estado con el GUID:

```bash
forge verify-check <GUID> --chain sepolia --etherscan-api-key $ETHERSCAN_API_KEY
```

Recargá Etherscan → pestaña `Contract`:

```text
Contract Source Code Verified
```

---

# Paso 9 — Read Contract

1. `Contract`
2. `Read Contract`
3. Buscá `count`
4. Ejecutá `count`

Resultado esperado:

```text
0
```

---

# Paso 10 — Write Contract

Primero importá la wallet de laboratorio en el navegador:

1. MetaMask → menú de cuentas → `Add account or hardware wallet`
2. `Import account` → `Private Key`
3. Pegá el valor de `PRIVATE_KEY` del `.env`
4. Cambiá la red a `Sepolia`

> Importá solamente la wallet descartable de Sepolia creada para esta clase.

Después:

1. `Contract`
2. `Write Contract`
3. `Connect to Web3`
4. Conectá la wallet importada
5. Ejecutá `increment`
6. Confirmá en MetaMask

Volvé a `Read Contract` → `count`:

```text
1
```

---

# Paso 11 — Transaction details en Etherscan

Abrí la transacción y buscá:

```text
Transaction Hash  → 0x...
Status            → Success
Block             → ...
From              → tu WALLET_ADDRESS
To                → SEPOLIA_COUNTER_ADDRESS
Gas Used          → ...
Input Data        → 0xd09de08a   (click "Decode Input Data" → increment())
Logs              → pestaña "Logs"
```

Guardá el hash:

```bash
SEPOLIA_TX_OK=<pegá_el_hash_acá>
```

Los mismos datos desde Cast:

```bash
cast receipt $SEPOLIA_TX_OK status      --rpc-url $SEPOLIA_RPC_URL
cast receipt $SEPOLIA_TX_OK blockNumber --rpc-url $SEPOLIA_RPC_URL
cast receipt $SEPOLIA_TX_OK gasUsed     --rpc-url $SEPOLIA_RPC_URL
cast tx      $SEPOLIA_TX_OK from        --rpc-url $SEPOLIA_RPC_URL
cast tx      $SEPOLIA_TX_OK to          --rpc-url $SEPOLIA_RPC_URL
cast tx      $SEPOLIA_TX_OK input       --rpc-url $SEPOLIA_RPC_URL
```

`from` y `to` salen de `cast tx`, no de `cast receipt`.

---

# Paso 12 — Evento en Etherscan

En la transacción → pestaña `Logs`.

Buscá:

```text
Incremented
```

Comprobá:

```text
caller   → tu WALLET_ADDRESS
newCount → 1
```

Usá el toggle `Hex` / `Dec` para ver `newCount` en decimal.

El topic del evento:

```bash
cast sig-event "Incremented(address,uint256)"
```

```text
0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420
```

Tiene que ser el mismo `topic0` que muestra Etherscan.

---

# Paso 13 — Crear un revert real en Sepolia

Llevar `count` a 0:

```bash
cast send $SEPOLIA_COUNTER_ADDRESS "decrement()" \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL --async

cast call $SEPOLIA_COUNTER_ADDRESS "count()(uint256)" --rpc-url $SEPOLIA_RPC_URL
```

```text
0
```

Ahora intentá `decrement()` otra vez **sin** opciones extra:

```bash
cast send $SEPOLIA_COUNTER_ADDRESS "decrement()" \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL
```

Resultado esperado — **no hay transacción**:

```text
Error: Failed to estimate gas: server returned an error response: error code 3:
execution reverted: custom error 0x233ae9b9, data: "0x233ae9b9": CounterIsZero
```

Cast estima gas primero y aborta. Para que la transacción se mine igual, pasá el gas a mano con `--gas-limit` (eso saltea la estimación):

```bash
cast send $SEPOLIA_COUNTER_ADDRESS "decrement()" \
  --private-key $PRIVATE_KEY \
  --rpc-url $SEPOLIA_RPC_URL \
  --gas-limit 100000
```

Resultado esperado:

```text
gasUsed              23369
logs                 []
status               0 (failed)
transactionHash      0x...
revertReason         custom error 0x233ae9b9, data: "0x233ae9b9"
```

Guardalo:

```bash
SEPOLIA_TX_FAIL=<pegá_el_hash_acá>
```

Si tu proveedor de RPC rechaza transacciones que simula como fallidas, repetí el comando contra un RPC público de Sepolia.

---

# Paso 14 — Revert en Etherscan

```bash
echo "https://sepolia.etherscan.io/tx/$SEPOLIA_TX_FAIL"
```

Buscá:

```text
Status       → Fail
Gas Used     → ~23.000
Input Data   → 0x2baeceb7   (decode → decrement())
Logs         → vacío
```

El motivo aparece junto al `Status`. Como es un custom error, Etherscan muestra el selector; comparalo con:

```bash
cast sig "CounterIsZero()"
```

```text
0x233ae9b9
```

---

# Paso 15 — Abrir la transacción exitosa en Tenderly

1. Entrá a `https://dashboard.tenderly.co` y logueate.
2. Copiá `SEPOLIA_TX_OK`.
3. Pegá el hash en la barra de búsqueda superior (Explorer).
4. Seleccioná la red `Sepolia`.
5. Abrí la transacción.

---

# Paso 16 — Execution Trace

Panel `Execution Trace`.

Identificá:

```text
caller     → tu WALLET_ADDRESS
contract   → Counter (SEPOLIA_COUNTER_ADDRESS)
función    → increment()
parámetros → (ninguno)
resultado  → success
```

---

# Paso 17 — Events

Pestaña `Events`.

Encontrá:

```text
Incremented
```

Ver:

```text
caller   → tu WALLET_ADDRESS
newCount → 1
```

---

# Paso 18 — State Changes

Pestaña `State Changes`.

Buscá:

```text
count: 0 → 1
```

---

# Paso 19 — Gas Profiler

Pestaña `Gas Profiler`.

Identificá en el flame chart el consumo de:

```text
increment()
```

Solo observalo.

---

# Paso 20 — Transacción fallida en Tenderly

1. Pegá `SEPOLIA_TX_FAIL` en la barra de búsqueda.
2. Red: `Sepolia`.
3. Abrí la transacción.

Ver:

```text
Status: Reverted
```

---

# Paso 21 — Debugger

1. Click en `Debugger` (arriba a la derecha de la transacción).
2. En `Execution Trace` (panel superior izquierdo) buscá `Counter.decrement`.
3. Avanzá con `Next` hasta el punto marcado como revert.
4. En el panel de código (arriba a la derecha) queda resaltada la línea `revert CounterIsZero();`.
5. En `Call Information` (abajo a la derecha) mirá el valor de `count`.
6. Confirmá que vale `0`.
7. Identificá el error: `CounterIsZero()` (selector `0x233ae9b9`).

---

# Paso 22 — Simulation

Desde la transacción fallida:

1. Click en `Re-Simulate`.
2. En el `Bundle rail` (izquierda) agregá un paso **antes** del actual: contrato `Counter`, función `increment` — así `count > 0`.
3. Dejá el segundo paso como `decrement`.
4. Click en `Simulate`.
5. Confirmá que el paso `decrement` termina en success.

| Elemento | Original   | Simulación      |
| -------- | ---------- | --------------- |
| Status   | Reverted   | Success         |
| State    | Sin cambio | count disminuye |
| Event    | No         | Sí              |
| Gas      | X          | Y               |

---

# Paso 23 — Crear una Virtual TestNet

1. Tenderly Dashboard.
2. Menú lateral → `Virtual TestNets` (en algunos proyectos aparece como `Virtual Environments`).
3. Click en `Create Virtual TestNet` / `Create Virtual Environment`.
4. `Parent network`: `Sepolia`.
5. Ponele un nombre; dejá el `Chain ID` por defecto.
6. Click en `Create`.
7. Copiá la `RPC URL`.

---

# Paso 24 — Conectar Foundry a la Virtual TestNet

Completá en `.env`:

```env
TENDERLY_VNET_RPC_URL=<pegá_la_RPC_URL>
```

```bash
source .env
```

Probar:

```bash
cast chain-id     --rpc-url $TENDERLY_VNET_RPC_URL
cast block-number --rpc-url $TENDERLY_VNET_RPC_URL
cast balance $WALLET_ADDRESS --ether --rpc-url $TENDERLY_VNET_RPC_URL
```

---

# Paso 25 — Fondear la wallet en la Virtual TestNet

Desde la UI: en el Virtual TestNet → `Faucet` → pegá `$WALLET_ADDRESS` → monto en ETH → `Fund`.

O por RPC:

```bash
cast rpc tenderly_setBalance $WALLET_ADDRESS $(cast to-hex $(cast to-wei 100 ether)) \
  --rpc-url $TENDERLY_VNET_RPC_URL
```

Comprobar:

```bash
cast balance $WALLET_ADDRESS --ether --rpc-url $TENDERLY_VNET_RPC_URL
```

```text
100.000000000000000000
```

---

# Paso 26 — Deploy en la Virtual TestNet

Mismo script:

```bash
forge script script/DeployCounter.s.sol:DeployCounter \
  --rpc-url $TENDERLY_VNET_RPC_URL \
  --broadcast
```

Guardar la address (el directorio de broadcast es el chain ID de tu TestNet):

```bash
VNET_CHAIN_ID=$(cast chain-id --rpc-url $TENDERLY_VNET_RPC_URL)

ADDR=$(grep -m1 '"contractAddress"' \
  broadcast/DeployCounter.s.sol/$VNET_CHAIN_ID/run-latest.json \
  | grep -oE '0x[0-9a-fA-F]{40}')

sed -i "s|^VNET_COUNTER_ADDRESS=.*|VNET_COUNTER_ADDRESS=$ADDR|" .env

source .env
echo $VNET_COUNTER_ADDRESS
```

---

# Paso 27 — Interactuar con la Virtual TestNet

```bash
cast call $VNET_COUNTER_ADDRESS "count()(uint256)" --rpc-url $TENDERLY_VNET_RPC_URL
```

```text
0
```

```bash
cast send $VNET_COUNTER_ADDRESS "increment()" \
  --private-key $PRIVATE_KEY \
  --rpc-url $TENDERLY_VNET_RPC_URL
```

```bash
cast call $VNET_COUNTER_ADDRESS "count()(uint256)" --rpc-url $TENDERLY_VNET_RPC_URL
```

```text
1
```

En Tenderly, abrí tu Virtual TestNet → pestaña `Transactions` → click en esa transacción para ver trace, eventos y state changes.

---

# Paso 28 — Consultar eventos con Cast

Contra Sepolia (`caller` es indexed, así que va declarado en la firma):

```bash
cast logs "Incremented(address indexed caller, uint256 newCount)" \
  --address $SEPOLIA_COUNTER_ADDRESS \
  --from-block $DEPLOY_BLOCK \
  --to-block latest \
  --rpc-url $SEPOLIA_RPC_URL
```

Resultado esperado:

```text
- address: 0x...
  blockNumber: ...
  data: 0x0000000000000000000000000000000000000000000000000000000000000001
  topics: [
  	0x38ac789ed44572701765277c4d0970f2db1c1a571ed39e84358095ae4eaa5420
  	0x000000000000000000000000<tu_wallet_sin_0x>
  ]
```

Filtrando por tu wallet:

```bash
cast logs "Incremented(address indexed caller, uint256 newCount)" $WALLET_ADDRESS \
  --address $SEPOLIA_COUNTER_ADDRESS \
  --from-block $DEPLOY_BLOCK \
  --rpc-url $SEPOLIA_RPC_URL
```

Decodificar a mano:

```bash
# newCount (campo data)
cast to-dec 0x0000000000000000000000000000000000000000000000000000000000000001
# caller (topic 1, indexed)
cast parse-bytes32-address 0x000000000000000000000000<tu_wallet_sin_0x>
```

Y el mismo evento en la Virtual TestNet:

```bash
cast logs "Incremented(address indexed caller, uint256 newCount)" \
  --address $VNET_COUNTER_ADDRESS \
  --from-block 0 \
  --rpc-url $TENDERLY_VNET_RPC_URL
```

---

# Flujo Detective Web3

```text
1. Explorer
2. Receipt
3. Trace
4. Tenderly
5. Debugger
6. Simulation
7. Fix
8. forge test
```

---

# Checklist final

```text
[ ] Proyecto compilado y tests pasando
[ ] SEPOLIA_RPC_URL y ETHERSCAN_API_KEY cargados
[ ] Wallet fondeada con Sepolia ETH
[ ] Counter deployado en Sepolia
[ ] Bytecode confirmado con cast code
[ ] Contrato verificado en Etherscan
[ ] count() consultado en Read Contract
[ ] increment() ejecutado en Write Contract
[ ] Transaction Hash identificado
[ ] Block identificado
[ ] Gas Used identificado
[ ] Input Data identificado
[ ] Logs identificados
[ ] Evento Incremented identificado
[ ] Revert real generado en Sepolia
[ ] Revert encontrado en Etherscan
[ ] Transacción abierta en Tenderly
[ ] Execution Trace revisado
[ ] Events revisados
[ ] State Changes revisados
[ ] Gas Profiler revisado
[ ] Revert localizado con Debugger
[ ] Transacción corregida mediante Simulation
[ ] Virtual TestNet creada
[ ] Wallet fondeada en Virtual TestNet
[ ] Counter deployado en Virtual TestNet
[ ] Counter probado en Virtual TestNet
[ ] Eventos consultados usando Cast
```
