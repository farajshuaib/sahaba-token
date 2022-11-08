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

async function deploySwapContract(SahabaToken_address: string) {
  const rate = parseEther("0.01");
  const Swap_Contract = await ethers.getContractFactory("SahabaSwap");
  const Swap = await Swap_Contract.deploy(SahabaToken_address, rate);
  await Swap.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);
  await Swap.deployed();

  await run("verify:verify", {
    address: Swap.address,
    constructorArguments: [SahabaToken_address, rate],
    contract: "contracts/SahabaSwap.sol:SahabaSwap",
  });

  return Swap;
}

async function main() {
  const SahabaToken = await deploySahabaCoin();

  console.log("SahabaToken deployed to:", SahabaToken.address);

  const Swap = await deploySwapContract(SahabaToken.address);

  console.log("Swap deployed to:", Swap.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
