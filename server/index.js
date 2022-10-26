import express from 'express'
import dotenv from 'dotenv'
import cors from 'cors'
import bodyParser from 'body-parser'
import fetch from 'node-fetch';
const app = express()

dotenv.config()

app.use(cors())
app.use(express.json())
app.use(bodyParser.urlencoded({ extended: true }))

app.get('/api/get_contract_data', async (req, res) => {
    const baseUrl = "https://dev-auth.atisbank.com.br/oauth2/token"
    const clientId = "2pa4gulqqjpa0uftmep0f92t1n"
    const clientSecret = "d9kv1ir3odqqt6m6r351b210cvjonc5ej3icfumnh0v52e65do5"
    const grantType = "client_credentials"
    
    let finalUrl = baseUrl + "?client_id=" + clientId + "&client_secret=" + clientSecret + "&grant_type=" + grantType
    
    console.log("Calling post request to " + finalUrl)

    const options = {
        method: 'POST',
        headers: {
          accept: 'application/json',
          'content-type': 'application/x-www-form-urlencoded'
        }
      };
      
    const response = await fetch(finalUrl, options)
    const responseJson = await response.json()
    console.log(responseJson)
    const accessToken = responseJson.access_token
    callContractData(accessToken)
})

const callContractData = async (bearerToken) => {
    console.log("Calling contract data with bearer token " + bearerToken)
    const contractId = "0a0bc10a-2733-4998-8566-989cd3666a81"
    const authorizationHeader = 'Bearer ' + bearerToken
    const options = {
        method: 'GET',
        headers: {
          accept: 'application/json',
          authorization: authorizationHeader
        }
      };
      
      const finalUrl = 'https://dev.api.atisbank.com.br/api/v1/external/contract/' + contractId
      console.log("Calling get request on " + finalUrl)
      const response = await fetch(finalUrl, options)
      const responseJson = await response.json()
      console.log(responseJson)
      const ourValue = responseJson.contract.anticipationList[0].ourValue / 100
      console.log("OurValue: " + ourValue)
}

app.listen(process.env.PORT, () => {
    console.log('Running on port ' + process.env.PORT)
})