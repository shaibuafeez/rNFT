import Chat from "./pages/Chat";
import CreateArt from "./pages/CreateArt";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { WalletProvider } from "@suiet/wallet-kit";
import { NETWORK } from "./config/constants";

function App() {

  return (
    <BrowserRouter>
      <WalletProvider defaultNetwork={NETWORK}>
        <Routes>
          <Route path="/chat" element={<Chat />} />
          <Route path="/" element={<CreateArt />} />
        </Routes>
      </WalletProvider>
    </BrowserRouter>
  )
}

export default App;
