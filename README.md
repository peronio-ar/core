<!-- markdownlint-disable MD001 MD041 -->

![Peronio](assets/header.png)

# Peronio Core Contracts

This repository contains the Core contracts used by Peronio.
Make sure to read the prerequisites carefully in order to set Peronio up locally.

## Prerequisites

Although not technically required, having [`direnv`](https://direnv.net/) installed will greatly simplify the set up process.
Please check the provided link for installation in \*nix and Mac OSs.

## Installation

We'll assume you're working within the `/some/path/to` directory.

### Clone & Checkout

Clone the repository normally and `cd` into it:

```shell
$ git clone https://github.com/peronio-ar/core
Cloning into 'core'...
remote: Enumerating objects: 123, done.
remote: Counting objects: 100% (123/123), done.
remote: Compressing objects: 100% (456/456), done.
remote: Total 123 (delta 789), reused 789 (delta 10), pack-reused 2
Receiving objects: 100% (123/123), 456.78 KiB | 9.01 MiB/s, done.
Resolving deltas: 100% (789/789), done.
$ cd core
```

If `direnv` is installed, you'll see:

```shell
direnv: error /some/path/to/core/.envrc is blocked. Run $(direnv allow) to approve its content
```

Simply do:

```shell
direnv allow
```

to make it go away and enable the `nvm` and environmental variables automation mechanism.

### NodeJS

Now, ensure you have the correct version of NodeJS installed by doing:

```shell
$ nvm install
Found '/some/path/to/core/.nvmrc' with version <v16.14.0>
Downloading and installing node v16.14.0...
Downloading https://nodejs.org/dist/v16.14.0/node-v16.14.0-linux-x64.tar.xz...
Computing checksum with sha256sum
Checksums matched!
Now using node v16.14.0 (npm v8.3.1)
```

Alternatively, if you already had the correct NodeJS version installed, you'll get:

```shell
$ nvm install
Found '/some/path/to/core/.nvmrc' with version <v16.14.0>
v16.14.0 is already installed.
Now using node v16.14.0 (npm v8.3.1)
```

> **In case you do NOT have `direnv` installed, you'll need to issue `nvm use` from within the working directory each time you `cd` into it so as to let `nvm` pick up the correct version from the `.nvmrc` file; `direnv` will do this _automagically_ for you if installed.**

### Yarn

Now, make sure you have `yarn` installed:

```shell
$ npm install -g yarn

added 1 package, and audited 2 packages in 756ms

found 0 vulnerabilities
```

If `yarn` was already installed you'll see something like:

```shell
$ npm install -g yarn

changed 1 package, and audited 2 packages in 635ms

found 0 vulnerabilities
```

### Environmental Variables

Lastly, copy the environmental variables sample file and edit to taste:

```shell
cp .env.example .env
```

It's important that you overwrite the `ETHERSCAN_API_KEY` environment variable with a suitable [Etherscan](https://etherscan.io/) API Key.

If you want the variables declared therein to be immediately available to you, you'll need to `export` them manually.

> **In case you do NOT have `direnv` installed, you'll need to re-`export` the environmental variables in `.env` each time you want them to become available; `direnv` will do this _automagically_ for you if installed.**

If you have `direnv`, simply do `cd ..; cd -` and that should re-load all `export`s and `nvm` configuration in one fell swoop.

### Dependencies

We're now ready to install all dependencies, simply do:

```shell
$ yarn
yarn install v1.22.19
[1/4] Resolving packages...
[2/4] Fetching packages...
[3/4] Linking dependencies...
[4/4] Building fresh packages...
Done in 12.65s.
```

### Typechain Declarations

The last step is to generate the needed typechain declarations, you can do so simply by:

```shell
$ yarn typechain
yarn run v1.22.19
$ hardhat typechain
Generating typings for: 52 artifacts in dir: typechain for target: ethers-v5
Successfully generated 68 typings!
Compiled 48 Solidity files successfully
Done in 9.12s.
```

## Usage

If everything installed correctly, you should now have a working environment with the correct NodeJS version installed, all dependencies up-to-date, typechain declarations freshly generated, and the relevant environmental variables `export`ed.

It is important to have the local fork running for all the examples and tests to work (this will simply clone the blockchain from a given point in time and stay there, running forever).
You can do this by simply:

```shell
$ yarn chain &
[1] 55830
yarn run v1.22.19
$ hardhat node --network hardhat --no-deploy
Started HTTP and WebSocket JSON-RPC server at http://127.0.0.1:8545/

Accounts
========

WARNING: These accounts, and their private keys, are publicly known.
Any funds sent to them on Mainnet or any other live network WILL BE LOST.

Account #0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 (10000 ETH)
Private Key: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

Account #1: 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 (10000 ETH)
Private Key: 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

Account #2: 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC (10000 ETH)
Private Key: 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

Account #3: 0x90F79bf6EB2c4f870365E785982E1f101E93b906 (10000 ETH)
Private Key: 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6

Account #4: 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65 (10000 ETH)
Private Key: 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a

Account #5: 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc (10000 ETH)
Private Key: 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba

Account #6: 0x976EA74026E726554dB657fA54763abd0C3a0aa9 (10000 ETH)
Private Key: 0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e

Account #7: 0x14dC79964da2C08b23698B3D3cc7Ca32193d9955 (10000 ETH)
Private Key: 0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356

Account #8: 0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f (10000 ETH)
Private Key: 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97

Account #9: 0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 (10000 ETH)
Private Key: 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

Account #10: 0xBcd4042DE499D14e55001CcbB24a551F3b954096 (10000 ETH)
Private Key: 0xf214f2b2cd398c806f84e317254e0f0b801d0643303237d97a22a48e01628897

Account #11: 0x71bE63f3384f5fb98995898A86B02Fb2426c5788 (10000 ETH)
Private Key: 0x701b615bbdfb9de65240bc28bd21bbc0d996645a3dd57e7b12bc2bdf6f192c82

Account #12: 0xFABB0ac9d68B0B445fB7357272Ff202C5651694a (10000 ETH)
Private Key: 0xa267530f49f8280200edf313ee7af6b827f2a8bce2897751d06a843f644967b1

Account #13: 0x1CBd3b2770909D4e10f157cABC84C7264073C9Ec (10000 ETH)
Private Key: 0x47c99abed3324a2707c28affff1267e45918ec8c3f20b8aa892e8b065d2942dd

Account #14: 0xdF3e18d64BC6A983f673Ab319CCaE4f1a57C7097 (10000 ETH)
Private Key: 0xc526ee95bf44d8fc405a158bb884d9d1238d99f0612e9f33d006bb0789009aaa

Account #15: 0xcd3B766CCDd6AE721141F452C550Ca635964ce71 (10000 ETH)
Private Key: 0x8166f546bab6da521a8369cab06c5d2b9e46670292d85c875ee9ec20e84ffb61

Account #16: 0x2546BcD3c84621e976D8185a91A922aE77ECEc30 (10000 ETH)
Private Key: 0xea6c44ac03bff858b476bba40716402b03e41b8e97e276d1baec7c37d42484a0

Account #17: 0xbDA5747bFD65F08deb54cb465eB87D40e51B197E (10000 ETH)
Private Key: 0x689af8efa8c651a91ad287602527f3af2fe9f6501a7ac4b061667b5a93e037fd

Account #18: 0xdD2FD4581271e230360230F9337D5c0430Bf44C0 (10000 ETH)
Private Key: 0xde9be858da4a475276426320d5e9262ecfc3ba460bfac56360bfa6c4c28b4ee0

Account #19: 0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199 (10000 ETH)
Private Key: 0xdf57089febbacf7ba0bc227dafbffa9fc08a93fdc68e1e42411a14efcf23656e

WARNING: These accounts, and their private keys, are publicly known.
Any funds sent to them on Mainnet or any other live network WILL BE LOST.
```

> Note that you can **only have ONE instance of the chain fork running at any given time** (without fiddling around with the configurations, that is).

Pay attention to the `&` character at the command line's end: this will run the `yarn chain` command in the background.
If you want to see what background jobs your shell is maintaining, you can do:

```shell
$ jobs
[1] + running yarn chain
```

And if you want to end the chain fork, you can simply do:

```shell
$ kill %N
[N] + 55830 exit 1 yarn chain
```

Where `N` is the number in brackets (ie. `[N]`) the `jobs` command reported.

### Running the Tests

Running the provided tests is as simple as:

```shell
$ yarn test
yarn run v1.22.19
$ hardhat test
No need to generate any newer typings.

Peronio
...
```

> **Remember:** you _must_ have the chain fork running for this to work!

### Deploying

Deploying Peronio is as simple as:

```shell
$ yarn deploy
yarn run v1.22.19
$ hardhat deploy
Nothing to compile
No need to generate any newer typings.
eth_chainId (2)
eth_chainId (4)
eth_estimateGas
eth_chainId
eth_getTransactionCount
deploying "Peronio"
    ...
```

> **Remember:** you _must_ have the chain fork running for this to work!
