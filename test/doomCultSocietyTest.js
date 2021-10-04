const { phraseList1, phraseList2, phraseList3, phraseList4 } = require('../src/phrases');

const { expect } = require('chai');
const { ethers } = require('hardhat');
const fs = require('fs');

describe('DoomCultSociety', function () {
  async function getDoomCultSociety(doomCultDAO) {
    const DoomCultSociety = await ethers.getContractFactory('DoomCultSociety');
    const doomCultSocietyAddr = await doomCultDAO.doomCultSociety();
    const doomCultSociety = await DoomCultSociety.attach(doomCultSocietyAddr);
    return doomCultSociety;
  }

  it('testAttractCultists', async function () {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory('DoomCultSocietyDAOTest');
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });

    const res = await doomCultDAO.deployed();
    const receipt = await res.deployTransaction.wait();
    console.log('deploy cost: ', receipt.gasUsed.toNumber());
    const [owner, addr1, addr2] = await ethers.getSigners();
    const oldBalance = (await doomCultDAO.balanceOf(owner.address)).toNumber();
    await expect(oldBalance).to.equal(0);
    await doomCultDAO.attractCultists();
    const newBalance = await doomCultDAO.balanceOf(owner.address);
    await expect(newBalance).to.equal('3000000000000000000');

    await doomCultDAO.forceAwake();
    await expect(doomCultDAO.attractCultists()).to.be.reverted;

    await doomCultDAO.transfer(addr1.address, BigInt('1000000000000000000'));
    expect(await doomCultDAO.balanceOf(addr1.address)).to.equal(BigInt('1000000000000000000'));
    expect(await doomCultDAO.balanceOf(owner.address)).to.equal(BigInt('2000000000000000000'));

    await expect(doomCultDAO.transfer(addr1.address, BigInt('10000000000000000000'))).to.be.reverted;

    await doomCultDAO.approve(addr1.address, 2);

    await expect(doomCultDAO.connect(addr2).transferFrom(owner.address, addr1.address, 1)).to.be.reverted;
    await expect(doomCultDAO.connect(addr1).transferFrom(addr1.address, addr1.address, 1)).to.be.reverted;
    await expect(doomCultDAO.connect(addr1).transferFrom(owner.address, addr1.address, 3)).to.be.reverted;

    await doomCultDAO.connect(addr1).transferFrom(owner.address, addr1.address, 2);

    expect(await doomCultDAO.balanceOf(addr1.address)).to.equal(BigInt('1000000000000000002'));
    expect(await doomCultDAO.balanceOf(owner.address)).to.equal(BigInt('1999999999999999998'));
    expect(await doomCultDAO.totalSupply()).to.equal(BigInt('2001000000000000000000'));
  });

  it('test awake', async function () {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory('DoomCultSocietyDAOTest');
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await expect(await doomCultDAO.isAwake()).to.equal(false);

    await doomCultDAO.forceMaximumCultists();

    await expect(doomCultDAO.attractCultists()).to.be.reverted;

    await doomCultDAO.wakeUp();

    await expect(await doomCultDAO.isAwake()).to.equal(true);
    expect(await doomCultDAO.doomCounter()).to.equal(BigInt(1));
    await expect(doomCultDAO.worship()).to.be.reverted;
  });

  it('test awake methods cannot be called when sleeping', async function () {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory('DoomCultSocietyDAOTest');
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await expect(doomCultDAO.worship()).to.be.reverted;
    await expect(doomCultDAO.sacrifice('')).to.be.reverted;
  });

  it('test insufficient sacrifices', async function () {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory('DoomCultSocietyDAOTest');
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await doomCultDAO.forceMaximumCultists();
    await doomCultDAO.wakeUp();

    await expect(doomCultDAO.worship()).to.be.reverted;

    await expect(doomCultDAO.placate()).to.be.reverted;

    await expect(doomCultDAO.placate({ value: ethers.utils.parseEther('0.1') }));
    expect(await doomCultDAO.placateThreshold()).to.equal(BigInt('200000000000000000'));

    expect((await doomCultDAO.placationCount()).toNumber()).to.equal(1);

    await expect(doomCultDAO.placate({ value: ethers.utils.parseEther('0.4') }));
    expect((await doomCultDAO.placationCount()).toNumber()).to.equal(3);
    expect(await doomCultDAO.placateThreshold()).to.equal(BigInt('400000000000000000'));

    await doomCultDAO.forceAdvanceEpoch();

    await doomCultDAO.worship();

    expect((await doomCultDAO.placationCount()).toNumber()).to.equal(0);
    expect(await doomCultDAO.placateThreshold()).to.equal(BigInt('400000000000000000'));
    await doomCultDAO.forceAdvanceEpoch();

    await doomCultDAO.worship();

    await expect(doomCultDAO.doomCounter()).to.be.reverted;
  });

  it('test worship', async function () {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory('DoomCultSocietyDAOTest');
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await doomCultDAO.forceMaximumCultists();
    await doomCultDAO.wakeUp();

    await expect(doomCultDAO.worship()).to.be.reverted;

    await doomCultDAO.sacrifice('');

    expect(await doomCultDAO.totalSupply()).to.equal(BigInt('29999000000000000000000'));
    const [owner, addr1] = await ethers.getSigners();

    await doomCultDAO.transfer(addr1.address, BigInt('2000000000000000000'));

    expect(await doomCultDAO.balanceOf(addr1.address)).to.equal(BigInt('2000000000000000000'));
    await expect(doomCultDAO.connect(addr1).sacrificeManyButOnlyMintOneNFT(0, '')).to.be.reverted;
    await expect(doomCultDAO.connect(addr1).sacrificeManyButOnlyMintOneNFT(3, '')).to.be.reverted;
    await doomCultDAO.connect(addr1).sacrificeManyButOnlyMintOneNFT(2, '');

    expect((await doomCultDAO.balanceOf(addr1.address)).toNumber()).to.equal(0);

    await doomCultDAO.forceAdvanceEpoch();

    await doomCultDAO.worship();

    expect(await doomCultDAO.doomCounter()).to.equal(BigInt(2));
  });

  it('test obliterate', async function () {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory('DoomCultSocietyDAOTest');
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await doomCultDAO.forceMaximumCultists();
    await doomCultDAO.wakeUp();

    for (let i = 0; i < 51; ++i) {
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

  it('test sacrifice/mint', async function () {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory('DoomCultSocietyDAOTest');
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await doomCultDAO.forceMaximumCultists();
    await doomCultDAO.wakeUp();

    expect(await doomCultDAO.doomCounter()).to.equal(1);
    expect(await doomCultDAO.totalSupply()).to.equal(BigInt('30000000000000000000000'));

    await expect(doomCultDAO.worship()).to.be.reverted;

    const tx = await (await doomCultDAO.sacrifice('')).wait();
    console.log('sacrifice cost: ', tx.gasUsed.toNumber());
    const nftId = tx.logs[0].data;
    const doomCultSociety = await getDoomCultSociety(doomCultDAO);
    const ownerOf = await doomCultSociety.ownerOf(nftId);
    const [owner, addr1, addr2] = await ethers.getSigners();

    expect(ownerOf).to.equal(owner.address);

    await doomCultSociety.approve(addr1.address, nftId);

    expect(await doomCultSociety.getApproved(nftId)).to.equal(addr1.address);

    await expect(doomCultSociety.connect(addr1).transferFrom(addr1.address, addr2.address, nftId)).to.be.reverted;

    await doomCultSociety.connect(addr1).transferFrom(owner.address, addr2.address, nftId);

    expect(await doomCultSociety.ownerOf(nftId)).to.equal(addr2.address);

    await expect(doomCultSociety.connect(addr1).transferFrom(addr1.address, owner.address, nftId)).to.be.reverted;

    await doomCultSociety.connect(addr2).transferFrom(addr2.address, owner.address, nftId);

    expect(await doomCultSociety.ownerOf(nftId)).to.equal(owner.address);

    const daoAddr = await doomCultSociety.doomCultSocietyDAO();
    expect(daoAddr).to.equal(doomCultDAO.address);
  });

  it('test cannot directly mint', async function () {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory('DoomCultSocietyDAOTest');
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await doomCultDAO.forceMaximumCultists();
    await doomCultDAO.wakeUp();

    await expect(doomCultDAO.worship()).to.be.reverted;

    const tx = await (await doomCultDAO.sacrifice('')).wait();
    const nftId = tx.logs[0].data;

    const doomCultSociety = await getDoomCultSociety(doomCultDAO);

    await expect(doomCultSociety.mint(1)).to.be.reverted;
  });

  it('test gonzo phrases', async function () {
    const DoomCultSociety = await ethers.getContractFactory('DoomCultSocietyTest');
    const doomCult = await DoomCultSociety.deploy({ gasLimit: 10000000 });
    await doomCult.deployed();

    let test = true;
    let count = 0;

    let strings = phraseList1.concat(phraseList2, phraseList3, phraseList4, [
      'The Communist Manifesto',
      '0',
      '1',
      '52',
      '0',
      '1',
      '2',
      '#1',
      '#2',
      '#3',
      '#4',
      '#5',
      '#6',
      '#7',
      '#8',
      '#0',
      '#o',
      '#p',
    ]);

    let seed = 34051000858;
    while (strings.length > 0 && count < 500) {
      const uri = await doomCult.getImgString(seed);
      // if (count == 0) {
      //   await fs.writeFile('./src/test.xml', uri, () => {});
      //   break;
      //   //   console.log(uri);
      // }
      strings = strings.filter(x => !uri.includes(x));
      count += 1;
      seed += 101000001;
    }
    if (strings.length > 0) {
      console.log(strings);
    }
    expect(strings.length).to.equal(0);
  });
});
