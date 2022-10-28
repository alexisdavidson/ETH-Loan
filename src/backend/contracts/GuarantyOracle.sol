// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

// Communicates with API via Oracle
contract GuarantyOracle is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public ourValue;
    bytes32 private jobId;
    uint256 private fee;

    event RequestContractData(string url);
    event ResultContractData(bytes32 indexed requestId, uint256 value);

    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); // goerli - change this depending on your network
        setChainlinkOracle(0xCC79157eb46F5624204f47AB42b3906cAA40eaB7); // goerli - change this depending on your network
        jobId = 'ca98366cc7314957b8c012c72f05aeeb';
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    // Allow withdraw of Link tokens from the contract
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }

    function linkBalance() public view returns(uint256) {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        return link.balanceOf(address(this));
    }

    // use "http://localhost:3001/" for _apiUrl
    function apiGetContractData(string calldata _contractId, string calldata _apiUrl) public onlyOwner returns (bytes32 requestId) {
        // curl --request GET \
        //      --url http://localhost:3001/api/get_contract_data?contract_id=0a0bc10a-2733-4998-8566-989cd3666a81 \
        //      --header 'accept: application/json' \
        string memory _url = string(abi.encodePacked(_apiUrl, "/api/get_contract_data?contract_id=", _contractId));

        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        req.add('get', _url);
        req.add('path', 'ourValue'); // Chainlink nodes 1.0.0 and later support this format

        emit RequestContractData(_url);

        return sendChainlinkRequest(req, fee);
    }

    // Receive the response in the form of uint256
    function fulfill(bytes32 _requestId, uint256 _ourValue) public recordChainlinkFulfillment(_requestId) {
        ourValue = _ourValue;

        emit ResultContractData(_requestId, _ourValue);
    }

    function getOurValue() public view returns (uint256) {
        return ourValue;
    }
}