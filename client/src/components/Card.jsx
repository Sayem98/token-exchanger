import { useState } from "react";
import { useWeb3Modal } from "@web3modal/ethers/react";
import {
  CONTRACT_ADDRESS,
  CONTRACT_ABI,
  TOKEN_A,
  TOKEN_A_ABI,
} from "../contacts";
import {
  useWeb3ModalProvider,
  useWeb3ModalAccount,
} from "@web3modal/ethers/react";
import { BrowserProvider, Contract, formatUnits, parseUnits } from "ethers";
import { toast } from "react-toastify";
import ClipLoader from "react-spinners/ClipLoader";

function Card() {
  const [amount, setAmount] = useState("");
  let [loading, setLoading] = useState(false);
  let [color, setColor] = useState("#ffffff");

  const { open } = useWeb3Modal();
  const { address, chainId, isConnected } = useWeb3ModalAccount();
  const { walletProvider } = useWeb3ModalProvider();

  const getOwner = async () => {
    if (!isConnected) throw new Error("Not connected");
    const etherProvider = new BrowserProvider(walletProvider);
    const signer = await etherProvider.getSigner();
    const contract = new Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
    const owner = await contract.owner();
    console.log(owner);
  };

  const exchange = async () => {
    try {
      setLoading(true);
      if (!isConnected) throw new Error("Not connected");
      const etherProvider = new BrowserProvider(walletProvider);
      const signer = await etherProvider.getSigner();
      const contract = new Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
      const owner = await contract.owner();
      console.log(owner);
      const token = new Contract(TOKEN_A, TOKEN_A_ABI, signer);
      // conver amount to 18 decimal
      console.log(amount);
      const _amount = parseUnits(amount, "ether");
      const approve = await token.approve(CONTRACT_ADDRESS, _amount);
      toast.info("Approving Token A");
      await approve.wait();
      toast.success("Token A approved");
      // console.log(approve);

      const exchange = await contract.claimToken(_amount);
      toast.info("Claiming Token B");
      await exchange.wait();
      toast.success("Token B claimed");
      // console.log(exchange);
      setLoading(false);
    } catch (e) {
      console.log(e);
      toast.error(e.message);
      setLoading(false);
    }
  };

  return (
    <div className="flex justify-center pt-[12rem] ">
      <div className="w-[30rem] h-[20rem] bg-[#3b3b3b] shadow-xl p-6 rounded-xl space-y-12">
        <div className="flex gap-2 justify-center">
          <button
            onClick={() => open({ view: "Networks" })}
            className="focus:outline-none bg-gray-900 hover:bg-gray-800 px-4 py-2 text-sm rounded-md shadow-2xl"
          >
            Networks
          </button>
          <w3m-button />
        </div>

        <div className="flex flex-col md:flex-row items-center gap-4 md:gap-2">
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="Enter amount"
            className="w-full bg-transparent placeholder-gray-400 text-sm text-slate-200 border focus:border-black border-gray-900 focus:outline-none px-4 py-2 rounded-md"
          />
          <button
            onClick={exchange}
            disabled={!amount}
            className={`self-stretch focus:outline-none bg-gray-900 hover:bg-gray-800 px-4 py-2 text-sm rounded-md shadow-2xl ${
              !amount && "cursor-not-allowed"
            }`}
          >
            {loading ? (
              <ClipLoader
                color={color}
                loading={loading}
                size={20}
                aria-label="Loading Spinner"
                data-testid="loader"
              />
            ) : (
              "Exchange"
            )}
          </button>
        </div>
        <p>
          First click approve to approve the Token A and then click claim to
          claim Token B
        </p>
      </div>
    </div>
  );
}

export default Card;
