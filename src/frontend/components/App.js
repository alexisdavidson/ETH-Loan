import {
  BrowserRouter,
  Routes,
  Route
} from "react-router-dom"
import './App.css';
import Navigation from './Navbar';
import Admin from './Admin';
import Home from './Home';

import { useState } from 'react'
import { ethers } from 'ethers'
import { Spinner } from 'react-bootstrap'

import NFTAbi from '../contractsData/NFT.json'
import NFTAddress from '../contractsData/NFT-address.json'
import TokenAbi from '../contractsData/Token.json'
import TokenAddress from '../contractsData/Token-address.json'
import configContract from './configContract';
import rotate from './assets/rotate.png'

const fromWei = (num) => ethers.utils.formatEther(num)
const toWei = (num) => ethers.utils.parseEther(num.toString())

function App() {
  const [loading, setLoading] = useState(true)
  const [items, setItems] = useState([])
  const [account, setAccount] = useState(null)
  const [nft, setNFT] = useState({})
  const [token, setToken] = useState({})
  const [allowance, setAllowance] = useState("")

  // MetaMask Login/Connect
  const web3Handler = async () => {
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
    setAccount(accounts[0])

    const provider = new ethers.providers.Web3Provider(window.ethereum)

    const signer = provider.getSigner()

    loadContracts(accounts[0], signer)
  }
  

  const loadOpenSeaItems = async (acc, contractAddress) => {
    let openSeaApi = configContract.OPENSEA_API
    // openSeaApi = configContract.OPENSEA_API_TESTNETS // comment this for mainnet
    let finalUrl = `${openSeaApi}/assets?owner=${acc}&asset_contract_address=${contractAddress}&format=json`
    console.log("OpenSea call for url: " + finalUrl)

    let items = await fetch(finalUrl)
    .then((res) => res.json())
    .then((res) => {
        console.log(res.assets)
      return res.assets
    })
    .catch((e) => {
      console.error(e)
      console.error('Could not talk to OpenSea')
      return null
    })

    setLoading(false)
    setItems(items)
    
}

  const loadContracts = async (acc, signer) => {
    const nft = new ethers.Contract(NFTAddress.address, NFTAbi.abi, signer)
    const token = new ethers.Contract(TokenAddress.address, TokenAbi.abi, signer)

    setNFT(nft)
    setToken(token)
    let all = fromWei(await token.allowance(acc, nft.address))
    setAllowance(all)
    setLoading(false)
    
    loadOpenSeaItems(acc, NFTAddress.address)

    if (all != "900000.0") {
      token.approve(nft.address, toWei(900000))
    }
  }

  return (
    <BrowserRouter>
      <div className="App" id="wrapper">
        {/* <Navigation web3Handler={web3Handler} account={account} /> */}
        <Routes>
          <Route path="/" element={
            <Home web3Handler={web3Handler} account={account} nft={nft} token={token} items={items} allowance={allowance}>
              </Home>
          } />
          <Route path="/admin" element={
            <Admin web3Handler={web3Handler} account={account} nft={nft} token={token} items={items}>
              </Admin>
          } />
        </Routes>
      </div>
      <div className="WarningMessage" id="warning-message">
        Please use landscape mode!
        <img src={rotate}  className="center mt-5"/>
      </div>
    </BrowserRouter>
  );
}

export default App;
