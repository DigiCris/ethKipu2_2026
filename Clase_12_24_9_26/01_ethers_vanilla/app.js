// ============================================================
// CLASE 12 — STARTER
// El HTML y el CSS ya están hechos.
// En clase vamos completando SOLO las partes Web3 marcadas PASO.
// ============================================================

const CONTRACT_ADDRESS = "0x58F7BBab762130f983C7A7e0C84fC094bb6a7C84";
const SEPOLIA_CHAIN_ID = 11155111;
const RPC_URL = "https://ethereum-sepolia-rpc.publicnode.com";

// PASO 2: pegar acá el ABI mínimo.
const COUNTER_ABI = [];

// PASO 3: crear el provider de solo lectura.
let readProvider;
let readContract;

// PASO 5: acá guardaremos el provider de la wallet, signer y contrato de escritura.
let walletProvider;
let signer;
let writeContract;
let connectedAddress;

const $ = id => document.getElementById(id);

function setStatus(message) {
  $("status").textContent = message;
}

function shortAddress(address) {
  return address ? `${address.slice(0, 6)}...${address.slice(-4)}` : "No conectada";
}

// PASO 4: completar esta función para leer number() desde blockchain.
async function refreshCounter() {
  setStatus("TODO: leer counter desde blockchain");
}

// PASO 6: completar esta función para leer el balance ETH de la wallet.
async function refreshBalance() {
  setStatus("TODO: leer balance");
}

// PASO 5: completar esta función para conectar MetaMask y obtener el signer.
async function connectWallet() {
  alert("TODO: en clase reemplazamos este alert por la conexión Web3");
}

// PASO 7: completar escritura increment().
async function increment() {
  alert("TODO: enviar transacción increment()");
}

// PASO 8: completar escritura decrement().
async function decrement() {
  alert("TODO: enviar transacción decrement()");
}

// PASO 9 opcional: escuchar cambios de cuenta/red o el evento CounterChanged.

$("connectButton").addEventListener("click", connectWallet);
$("refreshButton").addEventListener("click", refreshCounter);
$("incrementButton").addEventListener("click", increment);
$("decrementButton").addEventListener("click", decrement);

setStatus("Starter cargado. Seguí INSTRUCTIVO.md");
