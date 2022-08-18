const { expect } = require("chai");
const { deployments, ethers } = require("hardhat");

describe("My Nft", () => {
  let nft, accounts, owner, minter;
  beforeEach(async () => {
    await deployments.fixture(["all"]);
    nft = await ethers.getContract("MyNft");
    accounts = await ethers.getSigners();
    owner = accounts[0];
    minter = accounts[1];
  });
});
