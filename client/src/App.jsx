import "./App.css";
import Card from "./components/Card";
import { createWeb3Modal, defaultConfig } from "@web3modal/ethers/react";
import { ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

// 1. Get projectId at https://cloud.walletconnect.com
const projectId = "bd5fea35206a4b67c15ac7f6afb26c78";

// 2. Set chains
const mainnet = {
  chainId: 1,
  name: "Ethereum",
  currency: "ETH",
  explorerUrl: "https://etherscan.io",
  rpcUrl: "https://cloudflare-eth.com",
};

const sepolia = {
  chainId: 11155111,
  name: "Sepolia",
  currency: "ETH",
  explorerUrl: "https://rpc.sepolia.org",
  rpcUrl: "https://rpc.sepolia.org",
};

// 3. Create modal
const metadata = {
  name: "My Website",
  description: "My Website description",
  url: "https://mywebsite.com", // origin must match your domain & subdomain
  icons: ["https://avatars.mywebsite.com/"],
};

createWeb3Modal({
  ethersConfig: defaultConfig({ metadata }),
  chains: [mainnet, sepolia],
  projectId,
  enableAnalytics: true, // Optional - defaults to your Cloud configuration
});

function App() {
  return (
    <div className="w-full h-full">
      <Card />
      <ToastContainer />
    </div>
  );
}

export default App;
