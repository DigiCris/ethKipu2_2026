# Hardhat desde cero

| Herramienta | Versión |
| --- | --- |
| Node.js | v22.22.1 |
| npm | 10.9.4 |
| Hardhat | 3.16.0 |
| @nomicfoundation/hardhat-toolbox-viem | 5.0.7 |
| viem | 2.56.5 |
| @openzeppelin/contracts | 5.6.1 |
| TypeScript | 6.0.3 |

---

## 1. Requisitos

```bash
node --version
npm --version
```

---

## 2. Crear proyecto

```bash
mkdir hardhat-demo
cd hardhat-demo
npm init -y
npm install --save-dev hardhat@3.16.0
npx hardhat --init --template node-test-runner-viem
rm -f contracts/Counter.sol contracts/Counter.t.sol test/Counter.ts
```

`hardhat.config.ts` generado:

```typescript
import hardhatToolboxViemPlugin from "@nomicfoundation/hardhat-toolbox-viem";
import { configVariable, defineConfig } from "hardhat/config";

export default defineConfig({
  plugins: [hardhatToolboxViemPlugin],
  solidity: {
    profiles: {
      default: {
        version: "0.8.34",
      },
      production: {
        version: "0.8.34",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      url: configVariable("SEPOLIA_RPC_URL"),
      accounts: [configVariable("SEPOLIA_PRIVATE_KEY")],
    },
  },
});
```

---

## 3. Instalar OpenZeppelin

```bash
npm install @openzeppelin/contracts
```

```solidity
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

---

## 4. Crear contrato

`contracts/LearningToken.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LearningToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("Learning Token", "LRN") {
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
```

> Contrato educativo: `mint` no tiene control de acceso.

---

## 5. Compilar

```bash
npx hardhat build
```

```text
Compiled 1 Solidity file with solc 0.8.34 (evm target: osaka)
```

Artifacts: `artifacts/contracts/LearningToken.sol/LearningToken.json`

---

## 6. Crear tests

`test/LearningToken.ts`:

```typescript
import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { parseUnits } from "viem";

import { network } from "hardhat";

describe("LearningToken", async function () {
  const { viem } = await network.create();

  const INITIAL_SUPPLY = parseUnits("1000000", 18);

  async function deployToken() {
    const [deployer, alice, bob] = await viem.getWalletClients();
    const token = await viem.deployContract("LearningToken", [
      INITIAL_SUPPLY,
    ]);
    return { token, deployer, alice, bob };
  }

  it("has the expected name", async function () {
    const { token } = await deployToken();
    assert.equal(await token.read.name(), "Learning Token");
  });

  it("has the expected symbol", async function () {
    const { token } = await deployToken();
    assert.equal(await token.read.symbol(), "LRN");
  });

  it("mints the initial supply on deployment", async function () {
    const { token } = await deployToken();
    assert.equal(await token.read.totalSupply(), INITIAL_SUPPLY);
  });

  it("assigns the initial supply to the deployer", async function () {
    const { token, deployer } = await deployToken();
    const balance = await token.read.balanceOf([deployer.account.address]);
    assert.equal(balance, INITIAL_SUPPLY);
  });

  it("transfers tokens between two accounts", async function () {
    const { token, deployer, alice } = await deployToken();
    const amount = parseUnits("100", 18);

    await token.write.transfer([alice.account.address, amount], {
      account: deployer.account,
    });

    assert.equal(
      await token.read.balanceOf([alice.account.address]),
      amount,
    );
    assert.equal(
      await token.read.balanceOf([deployer.account.address]),
      INITIAL_SUPPLY - amount,
    );
  });

  it("allows minting new tokens to any address", async function () {
    const { token, bob } = await deployToken();
    const amount = parseUnits("50", 18);

    await token.write.mint([bob.account.address, amount]);

    assert.equal(await token.read.balanceOf([bob.account.address]), amount);
    assert.equal(await token.read.totalSupply(), INITIAL_SUPPLY + amount);
  });
});
```

---

## 7. Ejecutar tests

```bash
npx hardhat test
```

```text
Running node:test tests

  LearningToken
    ✔ has the expected name
    ✔ has the expected symbol
    ✔ mints the initial supply on deployment
    ✔ assigns the initial supply to the deployer
    ✔ transfers tokens between two accounts
    ✔ allows minting new tokens to any address

6 passing (6 nodejs)
```

---

## 8. Coverage

```bash
npx hardhat test --coverage
```

```text
╔══════════════════════════════════════════════════════════════════════╗
║ File Coverage                                                        ║
╟─────────────────────────────┬────────┬─────────────┬─────────────────╢
║ File Path                   │ Line % │ Statement % │ Uncovered Lines ║
╟─────────────────────────────┼────────┼─────────────┼─────────────────╢
║ contracts/LearningToken.sol │ 100.00 │ 100.00      │ -               ║
╚═════════════════════════════╧════════╧═════════════╧═════════════════╝
```

Reporte HTML: `coverage/html/index.html` (Statements, Branches, Functions, Lines).

---

## 9. Levantar blockchain local

```bash
npx hardhat node
```

```text
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/

Account #0:  0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
...
```

---

## 10. Deploy local

`scripts/deploy.ts`:

```typescript
import { network } from "hardhat";
import { formatUnits, parseUnits } from "viem";

const { viem } = await network.create("localhost");

const [deployer] = await viem.getWalletClients();

const INITIAL_SUPPLY = parseUnits("1000000", 18);

console.log("Deploying LearningToken...");
console.log("Deployer address:", deployer.account.address);

const token = await viem.deployContract("LearningToken", [INITIAL_SUPPLY]);

const totalSupply = await token.read.totalSupply();

console.log("Contract address:", token.address);
console.log("Total supply:", formatUnits(totalSupply, 18), "LRN");
```

```bash
npx hardhat run scripts/deploy.ts --network localhost
```

```text
Deploying LearningToken...
Deployer address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
Contract address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
Total supply: 1000000 LRN
```

```bash
export TOKEN_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
```

---

## 11. Interactuar con el contrato

`scripts/interact.ts`:

```typescript
import { network } from "hardhat";
import { formatUnits, parseUnits } from "viem";

const tokenAddress = process.env.TOKEN_ADDRESS;
if (!tokenAddress) {
  throw new Error("Set TOKEN_ADDRESS to the deployed contract address");
}

const { viem } = await network.create("localhost");

const [deployer, alice] = await viem.getWalletClients();
const token = await viem.getContractAt("LearningToken", tokenAddress as `0x${string}`);

console.log("name:", await token.read.name());
console.log("symbol:", await token.read.symbol());
console.log("totalSupply:", formatUnits(await token.read.totalSupply(), 18));

console.log(
  "deployer balance (before):",
  formatUnits(await token.read.balanceOf([deployer.account.address]), 18),
);

const amount = parseUnits("100", 18);
console.log(`Transferring 100 LRN from deployer to ${alice.account.address}...`);
await token.write.transfer([alice.account.address, amount], {
  account: deployer.account,
});

console.log(
  "deployer balance (after):",
  formatUnits(await token.read.balanceOf([deployer.account.address]), 18),
);
console.log(
  "alice balance (after):",
  formatUnits(await token.read.balanceOf([alice.account.address]), 18),
);
```

```bash
npx hardhat run scripts/interact.ts --network localhost
```

```text
name: Learning Token
symbol: LRN
totalSupply: 1000000
deployer balance (before): 1000000
Transferring 100 LRN from deployer to 0x70997970C51812dc3A010C7d01b50e0d17dc79C8...
deployer balance (after): 999900
alice balance (after): 100
```

### Consola (opcional)

```bash
npx hardhat console --network localhost
```

```typescript
const { viem } = await network.create("localhost");
const token = await viem.getContractAt("LearningToken", "0x5FbDB2315678afecb367f032d93F642f64180aa3");
await token.read.name();
```

---

## 12. Comandos útiles

```bash
npx hardhat build
npx hardhat test
npx hardhat test --coverage
npx hardhat node
npx hardhat run <script> --network localhost
npx hardhat clean
npx hardhat console --network localhost
npx hardhat --help
```
