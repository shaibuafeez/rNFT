import Chat from "./pages/Chat";
import CreateArt from "./pages/CreateArt";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { WalletProvider } from "@suiet/wallet-kit";

function App() {

  return (
    <BrowserRouter>
      <WalletProvider defaultNetwork="devnet">
        <Routes>
          <Route path="/chat" element={<Chat />} />
          <Route path="/" element={<CreateArt />} />
        </Routes>
      </WalletProvider>
    </BrowserRouter>
  )
}

export default App;
