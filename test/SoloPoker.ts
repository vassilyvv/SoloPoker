import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("SoloPoker", function () {
    it("new hand", async function () {const [owner, otherAccount] = await ethers.getSigners();

        const soloPokerFactory = await ethers.getContractFactory("SoloPoker");
        const soloPoker = await soloPokerFactory.deploy();
        for (var i = 0; i<200; ++i){
        await soloPoker.dealCards();}
    });
});
