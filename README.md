# Peronio Core Contracts

Before you start

## Install

```shell
nvm use
```

```shell
yarn
```

## Copy .env sample

```shell
cp .env.example .env
```

## Edit .env with the correct variable data (Don't forget a temp PRIVATE KEY)

The current private key has USDC 1000 and MATIC 10 on on local hardhat.

```shell
nano .env
```

## Generate typechain declarations

```shell
yarn typechain
```

## Run a local fork on a parallel terminal

```shell
yarn chain
```

## Deploy on local hardhat

```shell
yarn deploy
```
