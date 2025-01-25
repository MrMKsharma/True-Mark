import { AptosClient, AptosAccount, FaucetClient, HexString } from "aptos";

const NODE_URL = "https://fullnode.devnet.aptoslabs.com";
const FAUCET_URL = "https://faucet.devnet.aptoslabs.com";

async function main() {
    const client = new AptosClient(NODE_URL);
    const faucetClient = new FaucetClient(NODE_URL, FAUCET_URL);

    // Create a new account
    const account = new AptosAccount();
    
    // Fund the account
    await faucetClient.fundAccount(account.address(), 100_000_000);

    console.log("Account address:", account.address().hex());
    
    // Deploy the module
    // Note: You'll need to compile the Move module first using the Aptos CLI
    // aptos move compile --package-dir ./blockchain/contracts

    // Initialize the module
    const payload = {
        function: `${account.address().hex()}::product::initialize`,
        type_arguments: [],
        arguments: []
    };

    try {
        const txnRequest = await client.generateTransaction(account.address(), payload);
        const signedTxn = await client.signTransaction(account, txnRequest);
        const transactionRes = await client.submitTransaction(signedTxn);
        await client.waitForTransaction(transactionRes.hash);
        
        console.log("Module initialized successfully!");
        console.log("Transaction hash:", transactionRes.hash);
    } catch (error) {
        console.error("Error deploying contract:", error);
    }
}

main().catch(console.error);
