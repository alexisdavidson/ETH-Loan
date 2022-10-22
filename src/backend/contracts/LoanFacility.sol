// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";

contract LoanFacility is Ownable {
    
    string public bearerToken = "";

    constructor() {
    }

    function apiAuthenticate(string calldata _clientId, string calldata _clientSecret, string calldata _grantType) public onlyOwner {
// curl --request POST \
//      --url 'https://dev-auth.atisbank.com.br/oauth2/token?client_id=aaa&client_secret=bbb&grant_type=ccc' \
//      --header 'accept: application/json' \
//      --header 'content-type: application/x-www-form-urlencoded'
        string memory _url = string(abi.encodePacked("https://dev-auth.atisbank.com.br/oauth2/token?client_id=", _clientId,
            "&client_secret=", _clientSecret,
            "&grant_type=", _grantType));

        apiAuthenticateResult();
    }

    function apiAuthenticateResult() private onlyOwner {
        bearerToken = "x";
    }

    function apiGetContractData(string calldata _contractId) public onlyOwner {
// curl --request GET \
//      --url https://dev.api.atisbank.com.br/api/v1/external/contract/aaa \
//      --header 'accept: application/json' \
//      --header 'authorization: Bearer bbb'
        string memory _url = string(abi.encodePacked("https://dev.api.atisbank.com.br/api/v1/external/contract/", _contractId));

        apiGetContractDataResult();
    }

    function apiGetContractDataResult() private onlyOwner {
        //Value we need: contract.ourValue / 100
    }
}