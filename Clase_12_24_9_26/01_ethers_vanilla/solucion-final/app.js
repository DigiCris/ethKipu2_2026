const CONTRACT_ADDRESS = "0x58F7BBab762130f983C7A7e0C84fC094bb6a7C84";
const SEPOLIA_CHAIN_ID = 11155111;
const RPC_URL = "https://ethereum-sepolia-rpc.publicnode.com";

const COUNTER_ABI = [
  "function number() view returns (uint256)",
  "function increment()",
  "function decrement()",
  "event CounterChanged(address indexed user, uint256 newNumber)"
];

const readProvider = new ethers.JsonRpcProvider(RPC_URL);
const readContract = new ethers.Contract(CONTRACT_ADDRESS, COUNTER_ABI, readProvider);

let walletProvider;
let signer;
let writeContract;
let connectedAddress;

const $ = id => document.getElementById(id);
const setStatus = message => $("status").textContent = message;
const shortAddress = address => address ? `${address.slice(0, 6)}...${address.slice(-4)}` : "No conectada";

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

async function refreshBalance() {
  if (!connectedAddress) return;
  const balance = await readProvider.getBalance(connectedAddress);
  $("walletBalance").textContent = `${Number(ethers.formatEther(balance)).toFixed(4)} ETH`;
}

async function ensureSepolia() {
  const network = await walletProvider.getNetwork();
  if (Number(network.chainId) === SEPOLIA_CHAIN_ID) return;

  await window.ethereum.request({
    method: "wallet_switchEthereumChain",
    params: [{ chainId: "0xaa36a7" }]
  });
}

async function connectWallet() {
  try {
    if (!window.ethereum) {
      setStatus("No se encontró una wallet inyectada");
      return;
    }

    setStatus("Esperando autorización de la wallet...");
    walletProvider = new ethers.BrowserProvider(window.ethereum);
    await walletProvider.send("eth_requestAccounts", []);
    await ensureSepolia();

    signer = await walletProvider.getSigner();
    connectedAddress = await signer.getAddress();
    writeContract = new ethers.Contract(CONTRACT_ADDRESS, COUNTER_ABI, signer);

    $("walletAddress").textContent = shortAddress(connectedAddress);
    await refreshBalance();
    await refreshCounter();
    setStatus("Wallet conectada");
  } catch (error) {
    console.error(error);
    setStatus("Conexión cancelada o fallida");
  }
}

async function sendCounterTransaction(methodName) {
  if (!writeContract) {
    setStatus("Primero conectá la wallet");
    return;
  }

  try {
    setStatus("Esperando firma...");
    const tx = await writeContract[methodName]();
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

async function increment() {
  await sendCounterTransaction("increment");
}

async function decrement() {
  await sendCounterTransaction("decrement");
}

$("connectButton").addEventListener("click", connectWallet);
$("refreshButton").addEventListener("click", refreshCounter);
$("incrementButton").addEventListener("click", increment);
$("decrementButton").addEventListener("click", decrement);

readContract.on("CounterChanged", (_user, newNumber) => {
  $("counterValue").textContent = newNumber.toString();
  setStatus("Evento CounterChanged recibido");
});

refreshCounter();
