require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
        console.log(account.address);
    }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: "0.8.8",
    networks: {
        hardhat: {
            chainId: 1337,
        },
        goerli: {
            url: "https://eth-goerli.g.alchemy.com/v2/XGi9E1cdSmjcNlnGK69i0pgZLkcbiuuW",
            accounts: [
                "0c59aff59c03e1aa5cb4d2ce8e29d01aec7f7afb3f7541add6cee433e32c420f",
            ],
            chainId: 5,
        },
    },
};
