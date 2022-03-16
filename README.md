##  How to setup and run cli-tool  

### Copy `address.json` into specific folder per network  
`address.json` is generated when deploy SacredFinance through `sacred-deploy`.  
And the network is `kovan`, you should copy `address.json` file into "kovan" folder in this repository.  

### Setup .env file, please refer .env.example  
### Execute setup.sh  
It'll download and extract snarks data for sacred tree to `sacred-trees-snarks` folder.  
And it'll also install node modules.  

## How to create cli-tool from sacred-deploy  
Please execute `./create-cli.sh` after deployed contracts.  
It'll create cli-tool folder and copy abi, circuit data, and js files which are requried to access contracts into cli-tool folder.  
Then you can update sacred-cli-tools repository with the created cli-tool.  

## How to use cli-tool  
### options  
`-r, --rpc <URL>`

The RPC, CLI should interact with, default: http://localhost:8545

`-R, --relayer <URL>`

Withdraw via relayer

`-k, --privatekey <privateKey>`

Private Key


### Available commands  
`deposit <currency> <amount>`

Submit a deposit of specified currency and amount from default eth account and return the resulting note. 
The currency is one of (ETH|). The amount depends on currency, see config.js file.

`withdraw <note> <recipient>`

Withdraw a note to a recipient account using relayer or specified private key. You can exchange some of your deposit\`s tokens to ETH during the withdrawal by specifing ETH_purchase (e.g. 0.1) to pay for gas in future transactions. Also see the --relayer option.

`sacredtest <currency> <amount> <recipient>`

Perform an automated test. It deposits and withdraws amount ETH. Uses Kovan Testnet.

`updatetree <operation>`
  
It performs batchUpdateRoot for deposits/withdrawal roots of SacredTrees
operation can be diposit/withdraw

`showpendings <operation>`

It shows how many number of deposit/withdraw event are pending in SacredTrees
operation can be diposit/withdraw

`calcap <note>`

It shows calculated AP amount based on deposit / withdrawal block number

`reward <note>`

It claim your reward.  
With executing this, you can get your encoded account that contains your AP and Aave interests amount.  

`rewardswap <account> <recipient>`

It swaps your APs in your account to ETH with SacredToken and send it to the recipipent address.  
And it also send your Aave interests to the recipipent address





