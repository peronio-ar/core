<!-- markdownlint-disable MD001 MD041 -->

![Peronio](assets/header.png)

[![Lint](https://github.com/peronio-ar/core/actions/workflows/lint.yml/badge.svg)](https://github.com/peronio-ar/core/actions/workflows/lint.yml)
![Tests Status](https://github.com/peronio-ar/core/actions/workflows/test.yml/badge.svg)
![CodeQL Status](https://github.com/peronio-ar/core/actions/workflows/codeql-analysis.yml/badge.svg)
[![Discord](https://img.shields.io/discord/957135981847384084?color=62c060)](https://discord.peronio.ar)

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

Typechain declarations are automatically generated after installation.

## Usage

If everything installed correctly, you should now have a working environment with the correct NodeJS version installed, all dependencies up-to-date, typechain declarations freshly generated, and the relevant environmental variables `export`ed.

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
yarn run v1.22.17
$ hardhat deploy
Nothing to compile
No need to generate any newer typings.
-- Hardhat network
Increase MATIC
Swapping MATIC into USDC
Deploying Peronio
deploying "Peronio" (tx: 0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef)...: deployed at 0x78a486306D15E7111cca541F2f1307a1cFCaF5C4 with 7654321 gas
Initializing Peronio
Deploying Migrator
deploying "Migrator" (tx: 0x23456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef01)...: deployed at 0xfe672A4b063b1895b2f6531a78a69c014614B2D8 with 9876543 gas
Deploying Uniswap
Deploying AutoCompound
deploying "AutoCompounder" (tx: 0x456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123)...: deployed at 0x3210FeDcBa9876543210fEdCbA9876543210FeDc with 111098 gas
Setting REWARD Role to AutoCompounder (0x3210FeDcBa9876543210fEdCbA9876543210FeDc)
$ hardhat run scripts/publish.ts --network matic
Done in 76.54s.
```
