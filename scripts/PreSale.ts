import { ethers, run } from "hardhat";
import { BigNumber } from "ethers";
import { parseEther } from "ethers/lib/utils";

const WAIT_BLOCK_CONFIRMATIONS = 6;

async function deploySahabaCoin() {
  const SahabaCoinContract = await ethers.getContractFactory("SahabaCoin");
  const SahabaCoin = await SahabaCoinContract.deploy();

  await SahabaCoin.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);
  await SahabaCoin.deployed();

  await run("verify:verify", {
    address: SahabaCoin.address,
    contract: "contracts/SahabaCoin.sol:SahabaCoin",
  });

  return SahabaCoin;
}

async function deployPreSaleContract(SahabaToken_address: string) {
  const rate = parseEther("0.01");
  const PreSale_Contract = await ethers.getContractFactory("PreSale");
  const PreSale = await PreSale_Contract.deploy(SahabaToken_address, rate);
  await PreSale.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);
  await PreSale.deployed();

  await run("verify:verify", {
    address: PreSale.address,
    constructorArguments: [SahabaToken_address, rate],
    contract: "contracts/PreSale.sol:PreSale",
  });

  return PreSale;
}

async function main() {
  const SahabaToken = await deploySahabaCoin();

  console.log("SahabaCoin deployed to:", SahabaToken.address);

  const PreSale = await deployPreSaleContract(SahabaToken.address);

  console.log("PreSale deployed to:", PreSale.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
