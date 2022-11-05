import { ethers, run } from "hardhat";
import { BigNumber } from "ethers";
import { parseEther } from "ethers/lib/utils";

const WAIT_BLOCK_CONFIRMATIONS = 6;

async function deploySahabaToken() {
  const SahabaTokenContract = await ethers.getContractFactory("SahabaToken");
  const SahabaToken = await SahabaTokenContract.deploy();

  await SahabaToken.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);
  await SahabaToken.deployed();

  await run("verify:verify", {
    address: SahabaToken.address,
    contract: "contracts/SahabaToken.sol:SahabaToken",
  });

  return SahabaToken;
}

async function deployKycContract() {
  const KycContract = await ethers.getContractFactory("KycContract");
  const Kyc = await KycContract.deploy();

  await Kyc.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);
  await Kyc.deployed();

  await run("verify:verify", {
    address: Kyc.address,
    contract: "contracts/KycContract.sol:KycContract",
  });

  return Kyc;
}

async function deployICOContract(
  wallet_address: string,
  SahabaTokenAddress: string,
  KycAddress: string
) {
  const rate = parseEther("100");
  const ICO_Contract = await ethers.getContractFactory("ICO");
  const ICO = await ICO_Contract.deploy(
    rate,
    wallet_address,
    SahabaTokenAddress,
    KycAddress
  );
  await ICO.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);
  await ICO.deployed();

  await run("verify:verify", {
    address: ICO.address,
    constructorArguments: [
      rate,
      wallet_address,
      SahabaTokenAddress,
      KycAddress,
    ],
    contract: "contracts/ICO.sol:ICO",
  });

  return ICO;
}

async function main() {
  const [deployer] = await ethers.getSigners();

  const SahabaToken = "0xc18C64d0d70771C1Dc757daF0D98003BfEB9A5B9"// await deploySahabaToken();

  // console.log("SahabaToken deployed to:", SahabaToken.address);

  const Kyc = "0x88A99d5fe8c8A69DAB5A73C22a5997Fc29B8F0fb" // await deployKycContract();

  // console.log("Kyc deployed to:", Kyc.address);

  const ICO = await deployICOContract(
    deployer.address,
    SahabaToken,
    Kyc
  );

  console.log("ICO deployed to:", ICO.address); // "0xb4FAb02c1b41fA4C762CB35B50799bD440Ec07eF"
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
