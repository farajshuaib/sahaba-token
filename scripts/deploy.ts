import { ethers, run } from "hardhat";

const WAIT_BLOCK_CONFIRMATIONS = 6

async function main() {
  const SahabaTokenContract = await ethers.getContractFactory("SahabaToken");
  const SahabaToken = await SahabaTokenContract.deploy();

  await SahabaToken.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);
  await SahabaToken.deployed();

  await run("verify:verify", {
    address: SahabaToken.address,
    contract: "contracts/SahabaToken.sol:SahabaToken",
  });

  const SahabaTokenVendorContract = await ethers.getContractFactory(
    "SahabaTokenVendor"
  );
  const SahabaTokenVendor = await SahabaTokenVendorContract.deploy(
   SahabaToken.address
  );
  await SahabaTokenVendor.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);
  await SahabaTokenVendor.deployed();

  await run("verify:verify", {
    address: SahabaTokenVendor.address,
    constructorArguments: [SahabaToken.address],
    contract: "contracts/SahabaTokenVendor.sol:SahabaTokenVendor",
  });


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
