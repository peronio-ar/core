const hre = require('hardhat');

async function main() {
  console.info('Network', hre.network.name);
  if (hre.network.name === 'localhost') {
    console.info('Skipped Polygonscan submission.');
    return;
  }
  await hre.run('polygonscan');
  console.log(
    '✅  Every contract has been successfully submitted to PolygonScan.'
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
