const { splitSignature } = require('ethers/lib/utils');
const { getDeployedContract } = require('../utils');

task('check_rewards', 'Check current balance').setAction(
  async ({ address }, { getNamedAccounts, network }) => {
    const { deployer } = await getNamedAccounts();

    // Get addresses
    const peronioAddress = getDeployedContract('Peronio', network.name).address;
    const amUSDTAddress = getDeployedContract('amUSDT', network.name).address;
    const incentivesAddress = process.env.AAVE_INCENTIVE_ADDRESS;

    // Get contracts
    const incentivesContract = await ethers.getContractAt(
      'IAaveIncentivesController',
      incentivesAddress
    );

    const rewards = {
      deployer: ethers.utils.formatUnits(
        await incentivesContract.getRewardsBalance([amUSDTAddress], deployer),
        18
      ),
      peContract: ethers.utils.formatUnits(
        await incentivesContract.getRewardsBalance(
          [amUSDTAddress],
          peronioAddress
        ),
        18
      ),
    };

    console.info('Rewards', rewards);
  }
);

task('claim', 'Claim Rewards').setAction(
  async ({}, { getNamedAccounts, network }) => {
    const { deployer } = await getNamedAccounts();

    // Get addresses
    const peronioAddress = getDeployedContract('Peronio', network.name).address;

    // Get contracts
    const peronioContract = await ethers.getContractAt(
      'Peronio',
      peronioAddress
    );

    console.dir(await peronioContract.claimAaveRewards());
  }
);

task('swap', 'Swap USDT for WMATIC in QuickSwap')
  .addOptionalParam('usdt', 'USDT to spend')
  .addOptionalParam('router', 'Router Address (Quickswap as default)')
  .setAction(
    async ({ usdt, router: _routerAddress }, { getNamedAccounts, network }) => {
      const { deployer } = await getNamedAccounts();

      const routerAddress =
        _routerAddress ?? '0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff'; //Quickswap

      const routerArtifact = await deployments.get('UniswapV2Router02');
      const quickswapContract = await ethers.getContractAt(
        routerArtifact.abi,
        routerAddress
      );

      const usdtContract = await ethers.getContractAt(
        'ERC20',
        process.env.USDT_ADDRESS
      );

      const usdtAmount = ethers.utils.parseUnits(usdt ?? '5000', 6);

      const path = [process.env.USDT_ADDRESS, process.env.WMATIC_ADDRESS];

      await usdtContract.approve(routerAddress, usdtAmount);

      console.dir(
        await quickswapContract.swapExactTokensForTokens(
          usdtAmount,
          '0',
          path,
          deployer,
          '999999999999'
        )
      );
    }
  );

task('check_liquidity', 'Check Liquidity WMATIC/USDT')
  .addOptionalParam('router', 'Router address (Default: Peronio Router)')
  .addOptionalParam('tokena', 'Token A (Default: USDT)')
  .addOptionalParam('tokenb', 'Token B (Default: WMATIC)')
  .addOptionalParam('address', 'Address to scan')
  .setAction(
    async (
      {
        address: _address,
        router: _routerAddress,
        tokena: _tokenA,
        tokenb: _tokenB,
      },
      { getNamedAccounts }
    ) => {
      const { deployer } = await getNamedAccounts();

      const tokenA = await ethers.getContractAt(
        'ERC20',
        _tokenA ?? process.env.USDT_ADDRESS
      );

      const tokenB = await ethers.getContractAt(
        'ERC20',
        _tokenB ?? process.env.WMATIC_ADDRESS
      );

      let tokens = [
        {
          name: await tokenA.symbol(),
          address: _tokenA ?? process.env.USDT_ADDRESS,
          decimals: await tokenA.decimals(),
        },
        {
          name: await tokenB.symbol(),
          address: _tokenB ?? process.env.WMATIC_ADDRESS,
          decimals: await tokenB.decimals(),
        },
      ];

      console.info('tokens:');
      console.dir(tokens);

      tokens = tokens.sort((a, b) => {
        return a.address - b.address;
      });

      const routerArtifact = await deployments.get('UniswapV2Router02');
      const routerContract = await ethers.getContractAt(
        routerArtifact.abi,
        _routerAddress ?? routerArtifact.address
      );

      const factoryAddress = await routerContract.factory();
      console.info('routerAddress', _routerAddress ?? routerArtifact.address);
      console.info('factoryAddress', factoryAddress);
      const address = _address ?? deployer;

      const factoryContract = await ethers.getContractAt(
        'UniswapV2Factory',
        factoryAddress
      );

      console.info('Check if pair exists...');
      const currentPair = await factoryContract.getPair(
        tokens[0].address,
        tokens[1].address
      );

      if (currentPair === '0x0000000000000000000000000000000000000000') {
        console.error(`Pair doesn't exits`);
        return;
      }

      const pairContract = await ethers.getContractAt(
        'UniswapV2Pair',
        currentPair
      );

      const totalSupply = await pairContract.totalSupply();
      const pairDecimals = await pairContract.decimals();
      const reserves = await pairContract.getReserves();

      console.info(
        'Total Supply',
        ethers.utils.formatUnits(totalSupply, pairDecimals)
      );

      console.info('Total Reserves');
      console.info(
        tokens[0].name,
        ethers.utils.formatUnits(reserves['_reserve0'], tokens[0].decimals)
      );
      console.info(
        tokens[1].name,
        ethers.utils.formatUnits(reserves['_reserve1'], tokens[1].decimals)
      );

      const lpBalance = await pairContract.balanceOf(address);

      console.info(
        'Current balance',
        ethers.utils.formatUnits(lpBalance, pairDecimals)
      );

      console.info(
        'Current proportion',
        ethers.utils.formatUnits(lpBalance.mul('10000').div(totalSupply), 4) +
          '%'
      );

      return {
        lpBalance,
        reserves,
        pairDecimals,
        totalSupply,
        pairAddress: currentPair,
      };
    }
  );

task('add_liquidity', 'Add Liquidity WMATIC/USDT')
  .addOptionalParam('router', 'Router Address (Default: Peronio Router)')
  .addOptionalParam('tokena', 'Address for token A (Default USDT)')
  .addOptionalParam('tokenb', 'Address for token B (Default WMATIC)')
  .addOptionalParam('amounta', 'USDT to use (Default: 1600)')
  .addOptionalParam('amountb', 'WMATIC to use (Default: 1000)')
  .setAction(
    async (
      {
        tokena: _tokenA,
        tokenb: _tokenB,
        amounta: _amountA,
        amountb: _amountB,
        router: _routerAddress,
      },
      { getNamedAccounts }
    ) => {
      const { deployer } = await getNamedAccounts();

      const routerArtifact = await deployments.get('UniswapV2Router02');
      const routerAddress = _routerAddress ?? routerArtifact.address;

      const tokenA = _tokenA ?? process.env.USDT_ADDRESS;
      const tokenB = _tokenB ?? process.env.WMATIC_ADDRESS;

      const routerContract = await ethers.getContractAt(
        routerArtifact.abi,
        routerAddress
      );

      const factoryContract = await ethers.getContractAt(
        'UniswapV2Factory',
        await routerContract.factory()
      );

      const tokenAContract = await ethers.getContractAt('ERC20', tokenA);
      const tokenBContract = await ethers.getContractAt('ERC20', tokenB);

      const tokenAName = await tokenAContract.symbol();
      const tokenBName = await tokenBContract.symbol();

      const amountA = ethers.utils.parseUnits(
        _amountA ?? '1600',
        await tokenAContract.decimals()
      );
      const amountB = ethers.utils.parseUnits(
        _amountB ?? '1000',
        await tokenBContract.decimals()
      );

      console.info('Check if pair exists...');
      let currentPair = await factoryContract.getPair(tokenA, tokenB);

      if (currentPair !== '0x0000000000000000000000000000000000000000') {
        console.info('Pair already exists', currentPair);
      } else {
        console.info('Creating pair...');
        currentPair = await factoryContract.createPair(tokenA, tokenB);
      }

      console.info(`Approving ${tokenAName} and ${tokenBName}...`);

      await tokenAContract.approve(routerAddress, amountA);
      await tokenBContract.approve(routerAddress, amountB);

      console.info(`Adding liquidity to ${tokenAName}/${tokenBName}...`);
      console.info(
        `Adding ${tokenAName}`,
        ethers.utils.formatUnits(amountA, await tokenAContract.decimals())
      );
      console.info(
        `Adding ${tokenBName}`,
        ethers.utils.formatUnits(amountB, await tokenBContract.decimals())
      );

      try {
        await routerContract.addLiquidity(
          tokenA,
          tokenB,
          amountA,
          amountB,
          '1',
          '1',
          deployer,
          99999999999
        );
      } catch (e) {
        console.error(e);
      }

      console.info('Successfully added');
    }
  );

task('remove_liquidity', 'Remove Liquidity WMATIC/USDT')
  .addOptionalParam('router', 'Router address (Default: Peronio Router)')
  .addOptionalParam('address', 'Address to be used')
  .addOptionalParam('tokena', 'Token A (Default: USDT)')
  .addOptionalParam('tokenb', 'Token B (Default: WMATIC)')
  .addOptionalParam('amount', 'Amount of LP to remove from liquidity pool')
  .setAction(
    async (
      {
        address: _address,
        amount: _lpAmount,
        router: _routerAddress,
        tokena,
        tokenb,
      },
      { getNamedAccounts }
    ) => {
      const { deployer } = await getNamedAccounts();
      const address = _address ?? deployer;

      const routerArtifact = await deployments.get('UniswapV2Router02');
      const routerAddress = _routerAddress ?? routerArtifact.address;

      console.info('Running check_liquidity...');

      const tokenA = tokena ?? process.env.USDT_ADDRESS;
      const tokenB = tokena ?? process.env.WMATIC_ADDRESS;

      const liquidity = await hre.run('check_liquidity', {
        address,
        router: routerAddress,
        tokena: tokenA,
        tokenb: tokenB,
      });

      console.dir(liquidity);

      const lpAmount = _lpAmount
        ? ethers.utils.parseUnits(_lpAmount, liquidity.pairDecimals)
        : liquidity.lpBalance;

      const permit = await hre.run('sign_permit', {
        address,
        router: routerAddress,
        pairaddress: liquidity.pairAddress,
        amount: ethers.utils.formatUnits(lpAmount, liquidity.pairDecimals),
      });

      console.info('Permit: ');
      console.dir(permit);

      const signatureData = permit.splitted;

      const routerContract = await ethers.getContractAt(
        routerArtifact.abi,
        routerAddress
      );

      console.info('Removing liquidity');

      console.dir(
        await routerContract.removeLiquidityWithPermit(
          tokenA,
          tokenB,
          lpAmount.toString(),
          '1',
          '1',
          address,
          permit.message.deadline,
          false,
          signatureData.v,
          signatureData.r,
          signatureData.s
        )
      );
    }
  );

task('sign_permit', 'Signs a Message')
  .addOptionalParam('router', 'Router address')
  .addOptionalParam('tokena', 'Token A of the pair (Default USDT)')
  .addOptionalParam('tokenb', 'Token B of the pair (Default WMATIC)')
  .addOptionalParam('pairaddress', 'Pair address (overrides tokena and tokenb)')
  .addOptionalParam('amount', 'Amount of LP') // String
  .setAction(
    async (
      {
        router: _routerAddress,
        tokena,
        tokenb,
        amount: _lpAmount,
        pairaddress: _pairAddress,
      },
      { getNamedAccounts, network }
    ) => {
      console.info('Signing message...');
      const { deployer } = await getNamedAccounts();

      // Setup
      const routerArtifact = await deployments.get('UniswapV2Router02');
      const routerAddress = _routerAddress ?? routerArtifact.address;

      let pairAddress = _pairAddress;

      // If pair is set, find it using the tokens provided as parameters
      if (!pairAddress) {
        const routerContract = await ethers.getContractAt(
          routerArtifact.abi,
          routerAddress
        );
        const factoryContract = await ethers.getContractAt(
          'UniswapV2Factory',
          await routerContract.factory()
        );

        const tokenA = tokena ?? process.env.USDT_ADDRESS;
        const tokenB = tokenb ?? process.env.WMATIC_ADDRESS;

        pairAddress = await factoryContract.getPair(tokenA, tokenB);
      }

      const pairContract = await ethers.getContractAt(
        'UniswapV2Pair',
        pairAddress
      );

      const liquidity = await hre.run('check_liquidity', {
        deployer,
        router: routerAddress,
      });

      const lpAmount =
        ethers.utils.parseUnits(_lpAmount, liquidity.pairDecimals) ??
        liquidity.lpBalance;

      // ******
      const chainId = network.config.chainId; // Check this
      const nonce = await pairContract.nonces(deployer);
      const deadline = 999999999999;

      const EIP712Domain = [
        { name: 'name', type: 'string' },
        { name: 'version', type: 'string' },
        { name: 'chainId', type: 'uint256' },
        { name: 'verifyingContract', type: 'address' },
      ];
      const domain = {
        name: 'Peronio LP Token',
        version: '1',
        chainId,
        verifyingContract: pairAddress,
      };
      const Permit = [
        { name: 'owner', type: 'address' },
        { name: 'spender', type: 'address' },
        { name: 'value', type: 'uint256' },
        { name: 'nonce', type: 'uint256' },
        { name: 'deadline', type: 'uint256' },
      ];

      const message = {
        owner: deployer,
        spender: routerAddress,
        value: lpAmount.toString(),
        nonce: nonce.toHexString(),
        deadline,
      };
      const data = JSON.stringify({
        types: {
          EIP712Domain,
          Permit,
        },
        domain,
        primaryType: 'Permit',
        message,
      });
      const signed = await network.provider.send('eth_signTypedData_v4', [
        deployer,
        data,
      ]);
      const splitted = splitSignature(signed);

      return {
        data,
        message,
        signed,
        splitted,
      };
    }
  );
