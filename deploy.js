const hre = require("hardhat");

async function main() {
    const SupplyChain = await hre.ethers.getContractFactory("SupplyChain");
    const supplyChain = await SupplyChain.deploy();

    await supplyChain.deployed();

    console.log(`Supply chain contract deployed to ${supplyChain.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
