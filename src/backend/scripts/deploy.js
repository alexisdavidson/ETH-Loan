// Before deploy:
// -Fill whitelist addresses with correct data!
// -Team Wallet mainnet: 0x61603b8A09C2Aa8f663B43c22C9ceBeC00FC6FeC
// -Team Wallet goerli: 0xf20fF4c449AA023B72bAAc9EF89a6DE2BBfc22e6

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Fill with correct data and uncomment the correct network before deploy!
  // const teamWallet = "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc"; // localhost
  // const teamWallets = ["0xD71E736a7eF7a9564528D41c5c656c46c18a2AEd", "0xf20fF4c449AA023B72bAAc9EF89a6DE2BBfc22e6"]; // goerli
  const teamWallets = ["0xf20fF4c449AA023B72bAAc9EF89a6DE2BBfc22e6"]; // mainnet
  // const subscriptionId = 4072; // goerli
  const subscriptionId = 473; // mainnet
  
  // const Token = await ethers.getContractFactory("Token");
  // const token = await Token.deploy(teamWallets);
  // console.log("Token contract address", token.address)
  // saveFrontendFiles(token, "Token");
  
  const tokenAddress = "0x8D7893e2D0A4765346A5DEb55497a8015da900b7" // mainnet
  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(tokenAddress, subscriptionId);
  console.log("NFT contract address", nft.address)
  
  saveFrontendFiles(nft, "NFT");

  console.log("Frontend files saved")
}

function saveFrontendFiles(contract, name) {
  const fs = require("fs");
  const contractsDir = __dirname + "/../../frontend/contractsData";

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    contractsDir + `/${name}-address.json`,
    JSON.stringify({ address: contract.address }, undefined, 2)
  );

  const contractArtifact = artifacts.readArtifactSync(name);

  fs.writeFileSync(
    contractsDir + `/${name}.json`,
    JSON.stringify(contractArtifact, null, 2)
  );
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
