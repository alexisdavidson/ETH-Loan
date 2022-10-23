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

    event RequestVolume(bytes32 indexed requestId, uint256 volume);
    
    string public bearerToken = "";

    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB); // goerli - change this depending on your network
        setChainlinkOracle(0xCC79157eb46F5624204f47AB42b3906cAA40eaB7); // goerli - change this depending on your network
        jobId = 'ca98366cc7314957b8c012c72f05aeeb';
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }

    function apiAuthenticate(string calldata _clientId, string calldata _clientSecret, string calldata _grantType) public onlyOwner returns (bytes32 requestId) {
        // curl --request POST \
        //      --url 'https://dev-auth.atisbank.com.br/oauth2/token?client_id=aaa&client_secret=bbb&grant_type=ccc' \
        //      --header 'accept: application/json' \
        //      --header 'content-type: application/x-www-form-urlencoded'
        string memory _url = string(abi.encodePacked("https://dev-auth.atisbank.com.br/oauth2/token?client_id=", _clientId,
            "&client_secret=", _clientSecret,
            "&grant_type=", _grantType));
            
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfillBearer.selector);
        req.add('post', _url);

        // Set the path to find the desired data in the API response, where the response format is:
        // {
        // "access_token": "xxxx"
        // "expires_in": 3600,
        // "token_type": "Bearer"
        // }
        req.add('path', 'access_token'); // Chainlink nodes 1.0.0 and later support this format

        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of string
     */
    function fulfillBearer(bytes32 _requestId, string memory _bearerToken) public recordChainlinkFulfillment(_requestId) {
        bearerToken = _bearerToken;
    }

    function apiGetContractData(string calldata _contractId) public onlyOwner returns (bytes32 requestId) {
        // curl --request GET \
        //      --url https://dev.api.atisbank.com.br/api/v1/external/contract/aaa \
        //      --header 'accept: application/json' \
        //      --header 'authorization: Bearer bbb'
        string memory _url = string(abi.encodePacked("https://dev.api.atisbank.com.br/api/v1/external/contract/", _contractId));

        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        req.add('get', _url);

        // Set the path to find the desired data in the API response, where the response format is:
        // {
            // "contract": {
                // "id": "0a0bc10a-2733-4998-8566-989cd3666a81",
                // "clientId": "21ad579a-f7c7-4ba8-aca5-2ce4f7c582c2",
                // "type": "Warranty",
                // "status": "Contracted",
                // "signatureDate": "2022-10-20T12:00:00.000Z",
                // "dueDate": "2027-10-20T12:00:00.000Z",
                // "creationDate": "2022-10-20T22:51:41.721Z",
                // "company": {
                    // "brIdentifier": "75031733000192",
                    // "creationDate": "2022-09-27T20:45:13.364Z"
                // },
                // "smoke": null,
                // "anticipationList": [
                    // {
                        // "id": 1,
                        // "status": "Contracted",
                        // "debtor": "31688539000109",
                        // "paymentScheme": "ECC",
                        // "expectedDate": "2022-10-25T12:00:00.000Z",
                        // "ourValue": 500000,
                        // "yourValue": 500000
                    // }
                // ]
            // }
        // }
        req.add('path', 'contract,anticipationList,ourValue'); // Chainlink nodes 1.0.0 and later support this format

        // Multiply the result by 100 to remove decimals
        int256 timesAmount = 10**2;
        req.addInt('times', timesAmount);

        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(bytes32 _requestId, uint256 _ourValue) public recordChainlinkFulfillment(_requestId) {
        ourValue = _ourValue;
    }
}