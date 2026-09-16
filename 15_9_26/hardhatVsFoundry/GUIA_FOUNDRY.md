# Foundry desde cero

| Herramienta | Versión |
| --- | --- |
| forge | 1.5.1-stable |
| cast | 1.5.1-stable |
| anvil | 1.5.1-stable |
| openzeppelin-contracts (lib) | 5.7.0 |

---

## 1. Requisitos

```bash
forge --version
cast --version
anvil --version
```

Si no está instalado:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

---

## 2. Crear proyecto

```bash
forge init foundry-demo
cd foundry-demo
rm -f src/Counter.sol test/Counter.t.sol script/Counter.s.sol
```

```text
foundry-demo/
├── foundry.toml
├── src/
├── test/
├── script/
└── lib/forge-std/
```

`foundry.toml`:

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
```

---

## 3. Instalar OpenZeppelin

```bash
forge install OpenZeppelin/openzeppelin-contracts
```

`remappings.txt`:

```text
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
forge-std/=lib/forge-std/src/
```

```solidity
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
```

---

## 4. Crear contrato

`src/LearningToken.sol`:

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
forge build
```

```text
Compiling 6 files with Solc 0.8.30
Solc 0.8.30 finished in 112.24ms
Compiler run successful!
```

---

## 6. Tests unitarios

`test/LearningToken.t.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {LearningToken} from "../src/LearningToken.sol";

contract LearningTokenTest is Test {
    LearningToken public token;

    address public deployer = address(this);
    address public alice = address(0xA11CE);
    address public bob = address(0xB0B);

    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;

    function setUp() public {
        token = new LearningToken(INITIAL_SUPPLY);
    }

    function test_Name() public view {
        assertEq(token.name(), "Learning Token");
    }

    function test_Symbol() public view {
        assertEq(token.symbol(), "LRN");
    }

    function test_InitialSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_DeployerBalance() public view {
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY);
    }

    function test_Transfer() public {
        uint256 amount = 100 ether;

        vm.prank(deployer);
        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY - amount);
    }

    function test_Mint() public {
        uint256 amount = 50 ether;

        vm.startPrank(bob);
        token.mint(bob, amount);
        vm.stopPrank();

        assertEq(token.balanceOf(bob), amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + amount);
    }

    function testFuzz_Mint(uint96 amount) public {
        token.mint(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + amount);
    }
}
```

```bash
forge test
```

```text
Ran 7 tests for test/LearningToken.t.sol:LearningTokenTest
[PASS] testFuzz_Mint(uint96) (runs: 256, μ: 41085, ~: 41618)
[PASS] test_DeployerBalance() (gas: 10608)
[PASS] test_InitialSupply() (gas: 7945)
[PASS] test_Mint() (gas: 44627)
[PASS] test_Name() (gas: 13009)
[PASS] test_Symbol() (gas: 12965)
[PASS] test_Transfer() (gas: 47594)
Suite result: ok. 7 passed; 0 failed; 0 skipped; finished in 11.37ms (11.68ms CPU time)
```

```bash
forge test        # resultado por test
forge test -vv     # + logs
forge test -vvvv   # + trazas completas
```

---

## 7. Fuzz testing

```text
[PASS] testFuzz_Mint(uint96) (runs: 256, μ: 41085, ~: 41618)
```

---

## 8. Coverage

```bash
forge coverage
```

```text
╭-----------------------+---------------+---------------+---------------+---------------╮
| File                  | % Lines       | % Statements  | % Branches    | % Funcs       |
+=======================================================================================+
| src/LearningToken.sol | 100.00% (4/4) | 100.00% (2/2) | 100.00% (0/0) | 100.00% (2/2) |
| Total                 | 100.00% (4/4) | 100.00% (2/2) | 100.00% (0/0) | 100.00% (2/2) |
╰-----------------------+---------------+---------------+---------------+---------------╯
```

---

## 9. Gas

```bash
forge test --gas-report
```

```text
| Function Name | Min   | Avg   | Median | Max   | # Calls |
| balanceOf     | 2850  | 2850  | 2850   | 2850  | 260     |
| mint          | 28847 | 51341 | 51583  | 51691 | 257     |
| transfer      | 51985 | 51985 | 51985  | 51985 | 1       |
```

```bash
forge snapshot
```

---

## 10. Formato

```bash
forge fmt
```

---

## 11. Anvil

```bash
anvil
```

```text
Available Accounts
==================
(0) 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000.000000000000000000 ETH)
(1) 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000.000000000000000000 ETH)
...

Private Keys
==================
(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
...

Chain ID
==================
31337

Listening on 127.0.0.1:8545
```

> Las private keys de Anvil son públicas: solo para desarrollo local.

---

## 12. Deploy

`script/DeployLearningToken.s.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {LearningToken} from "../src/LearningToken.sol";

contract DeployLearningToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;

    function run() external returns (LearningToken token) {
        vm.startBroadcast();
        token = new LearningToken(INITIAL_SUPPLY);
        vm.stopBroadcast();

        console.log("Deployer address:", msg.sender);
        console.log("Contract address:", address(token));
        console.log("Total supply:", token.totalSupply());
    }
}
```

```bash
export ANVIL_PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

forge script script/DeployLearningToken.s.sol --rpc-url http://127.0.0.1:8545 --private-key $ANVIL_PRIVATE_KEY --broadcast
```

```text
== Logs ==
  Deployer address: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
  Contract address: 0x5FbDB2315678afecb367f032d93F642f64180aa3
  Total supply: 1000000000000000000000000

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
```

```bash
export TOKEN_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
```

> Solo contra Anvil (chain ID 31337). Nunca contra Sepolia/mainnet ni con keys reales.

---

## 13. Cast

```bash
cast block-number --rpc-url http://127.0.0.1:8545
```

```bash
cast balance $DEPLOYER --rpc-url http://127.0.0.1:8545
```

```bash
cast call $TOKEN_ADDRESS "name()(string)" --rpc-url http://127.0.0.1:8545
cast call $TOKEN_ADDRESS "totalSupply()(uint256)" --rpc-url http://127.0.0.1:8545
cast call $TOKEN_ADDRESS "balanceOf(address)(uint256)" $DEPLOYER --rpc-url http://127.0.0.1:8545
```

```bash
export ALICE=0x70997970C51812dc3A010C7d01b50e0d17dc79C8
export ALICE_PRIVATE_KEY=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

cast send $TOKEN_ADDRESS "mint(address,uint256)" $ALICE 50000000000000000000 --rpc-url http://127.0.0.1:8545 --private-key $ALICE_PRIVATE_KEY
```

```bash
cast call $TOKEN_ADDRESS "balanceOf(address)(uint256)" $ALICE --rpc-url http://127.0.0.1:8545
# 50000000000000000000 [5e19]
```

```bash
cast to-wei 1 ether        # 1000000000000000000
cast from-wei 1000000000000000000   # 1.000000000000000000
cast keccak "hello"         # 0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8
```

---

## 14. Forge inspect

```bash
forge inspect LearningToken abi
forge inspect LearningToken bytecode
```

---

## 15. Comandos útiles

```bash
forge build
forge test
forge test -vvvv
forge coverage
forge test --gas-report
forge snapshot
forge fmt
forge inspect <Contrato> abi
forge inspect <Contrato> bytecode
anvil
forge script <script> --rpc-url <url> --private-key <key> --broadcast
cast call <dir> "<firma>" [args] --rpc-url <url>
cast send <dir> "<firma>" [args] --rpc-url <url> --private-key <key>
```

---

## Equivalencias rápidas

| Acción | Hardhat | Foundry |
| --- | --- | --- |
| Compilar | `npx hardhat build` | `forge build` |
| Tests | `npx hardhat test` | `forge test` |
| Fuzz testing | — | incluido en `forge test` |
| Coverage | `npx hardhat test --coverage` | `forge coverage` |
| Gas report | — | `forge test --gas-report` |
| Nodo local | `npx hardhat node` | `anvil` |
| Deploy | `npx hardhat run scripts/deploy.ts --network localhost` | `forge script script/DeployLearningToken.s.sol --rpc-url <url> --private-key <key> --broadcast` |
| Interacción CLI | `npx hardhat console --network localhost` | `cast call` / `cast send` |
| Formatear código | — | `forge fmt` |
