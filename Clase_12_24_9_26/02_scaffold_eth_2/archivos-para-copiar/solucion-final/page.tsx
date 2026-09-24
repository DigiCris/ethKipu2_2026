"use client";

import { useAccount } from "wagmi";
import { useScaffoldReadContract, useScaffoldWriteContract } from "~~/hooks/scaffold-eth";

export default function Home() {
  const { address, isConnected } = useAccount();

  const { data: number, refetch } = useScaffoldReadContract({
    contractName: "Counter",
    functionName: "number",
  });

  const { writeContractAsync: writeCounterAsync, isPending } = useScaffoldWriteContract({
    contractName: "Counter",
  });

  const send = async (functionName: "increment" | "decrement") => {
    try {
      await writeCounterAsync({ functionName });
      await refetch();
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <main className="min-h-screen flex items-center justify-center bg-base-200 px-4">
      <div className="card w-full max-w-xl bg-base-100 shadow-xl">
        <div className="card-body gap-5">
          <div>
            <div className="text-xs uppercase tracking-widest opacity-60">Clase 12 · Scaffold-ETH 2</div>
            <h1 className="card-title text-4xl mt-2">Counter dApp</h1>
            <p className="opacity-70">Los hooks abstraen provider, ABI, address y estados de transacción.</p>
          </div>

          <div className="rounded-box border border-base-300 p-4">
            <div className="flex justify-between gap-4">
              <span>Wallet</span>
              <span className="font-mono text-sm break-all">
                {isConnected ? address : "Usá Connect Wallet del header"}
              </span>
            </div>
          </div>

          <div className="rounded-box border border-base-300 p-8 text-center">
            <div className="text-sm opacity-60">Valor guardado en el contrato</div>
            <div className="text-7xl font-bold my-5">{number?.toString() ?? "..."}</div>

            <div className="grid grid-cols-2 gap-3">
              <button className="btn" disabled={!isConnected || isPending} onClick={() => send("decrement")}>
                − Decrement
              </button>
              <button className="btn btn-primary" disabled={!isConnected || isPending} onClick={() => send("increment")}>
                {isPending ? "Pendiente..." : "+ Increment"}
              </button>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
}
