const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Macgyver", "Spenser", "Sheldon"], // names
    [
      "https://res.cloudinary.com/khariokitony/image/upload/v1638752603/mac.png", // images
      "https://res.cloudinary.com/khariokitony/image/upload/v1638752616/spens.png",
      "https://res.cloudinary.com/khariokitony/image/upload/v1638752625/shelly.png"
    ],
    [250, 300, 375], // hp values
    [75, 100, 125], // attack damage values
    "Musk",
    "https://res.cloudinary.com/khariokitony/image/upload/v1638778533/musk.jpg",
    10000,
    50
  );
  await gameContract.deployed();
  console.log("Contract deployed to: ", gameContract.address);

  let txn;

  // an NFT W/ THE CHARACTER AT INDEX 2
  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  // get the value of the NFT's URI
  let returnedTokenUri = await gameContract.tokenURI(1);
  console.log("Token URI: ", returnedTokenUri);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();
