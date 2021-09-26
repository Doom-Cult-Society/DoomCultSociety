const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DoomCultSociety", function () {

  it("testAttractCultists", async function () {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory("DoomCultSocietyDAOTest");
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    const [owner] = await ethers.getSigners();
    const oldBalance = (await doomCultDAO.balanceOf(owner.address)).toNumber();
    await expect(oldBalance).to.equal(0);
    await doomCultDAO.attractCultists();
    const newBalance = (await doomCultDAO.balanceOf(owner.address)).toNumber();
    await expect(newBalance).to.equal(3);

    await doomCultDAO.forceAwake();
    await expect(doomCultDAO.attractCultists()).to.be.reverted;
  });

  it("test awake", async function() {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory("DoomCultSocietyDAOTest");
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await expect(await (doomCultDAO.isAwake())).to.equal(false);

    await doomCultDAO.forceMaximumCultists();

    await expect(doomCultDAO.attractCultists()).to.be.reverted;

    await doomCultDAO.wakeUp();

    await expect(await (doomCultDAO.isAwake())).to.equal(true);    
    expect(await (doomCultDAO.doomCounter())).to.equal(BigInt(1));   
    await expect(doomCultDAO.worship()).to.be.reverted;   
  });

  it("test awake methods cannot be called when sleeping", async function() {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory("DoomCultSocietyDAOTest");
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await expect(doomCultDAO.worship()).to.be.reverted;
    await expect(doomCultDAO.sacrifice()).to.be.reverted;
  });

  it("test insufficient sacrifices", async function() {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory("DoomCultSocietyDAOTest");
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await doomCultDAO.forceMaximumCultists();
    await doomCultDAO.wakeUp();

    await expect(doomCultDAO.worship()).to.be.reverted;

    await doomCultDAO.forceAdvanceEpoch();

    await doomCultDAO.worship();

    await expect(doomCultDAO.doomCounter()).to.be.reverted;
  });

  
  it("test worship", async function() {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory("DoomCultSocietyDAOTest");
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await doomCultDAO.forceMaximumCultists();
    await doomCultDAO.wakeUp();

    await expect(doomCultDAO.worship()).to.be.reverted;

    await doomCultDAO.sacrifice();
    await doomCultDAO.forceAdvanceEpoch();

    await doomCultDAO.worship();

    expect(await doomCultDAO.doomCounter()).to.equal(BigInt(2));
  });

  it('test obliterate', async function() {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory("DoomCultSocietyDAOTest");
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await doomCultDAO.forceMaximumCultists();
    await doomCultDAO.wakeUp();

    for (let i = 0; i < 51; ++i)
    {
      await doomCultDAO.forceLargeSacrifice(i + 1);
      await doomCultDAO.forceAdvanceEpoch();
      await doomCultDAO.worship();
    }

    await doomCultDAO.forceLargeSacrifice(52);
    await doomCultDAO.forceAdvanceEpoch();
    await doomCultDAO.worship();
  
    // Test contract is destroyed by calling getter fn
    await expect(doomCultDAO.doomCounter()).to.be.reverted;
  });
});
