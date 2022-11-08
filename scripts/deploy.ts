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

async function deploySwapContract() {
  const rate = parseEther("100");
  const Swap_Contract = await ethers.getContractFactory("SahabaSwap");
  const Swap = await Swap_Contract.deploy(
    "0x54460CC6574442b1ac12dd71C509Ac421E3Ab031",
    rate
  );
  await Swap.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);
  await Swap.deployed();

  await run("verify:verify", {
    address: Swap.address,
    constructorArguments: ["0x54460CC6574442b1ac12dd71C509Ac421E3Ab031", rate],
    contract: "contracts/SahabaSwap.sol:SahabaSwap",
  });

  return Swap;
}

async function main() {
  // const SahabaToken = await deploySahabaCoin();

  // console.log("SahabaToken deployed to:", SahabaToken.address);

  const Swap = await deploySwapContract();

  console.log("Swap deployed to:", Swap.address); // "0xb4FAb02c1b41fA4C762CB35B50799bD440Ec07eF"
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
