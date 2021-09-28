const { expect } = require('chai');
const { ethers } = require('hardhat');

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
    const newBalance = (await doomCultDAO.balanceOf(owner.address)).toNumber();
    await expect(newBalance).to.equal(3);

    await doomCultDAO.forceAwake();
    await expect(doomCultDAO.attractCultists()).to.be.reverted;

    await doomCultDAO.transfer(addr1.address, 1);
    expect((await doomCultDAO.balanceOf(addr1.address)).toNumber()).to.equal(1);
    expect((await doomCultDAO.balanceOf(owner.address)).toNumber()).to.equal(2);

    await expect(doomCultDAO.transfer(addr1.address, 10)).to.be.reverted;

    await doomCultDAO.approve(addr1.address, 1);

    await expect(doomCultDAO.connect(addr1).transferFrom(addr2.address, addr1.address, 1)).to.be.reverted;
    await expect(doomCultDAO.connect(addr1).transferFrom(addr1.address, addr1.address, 1)).to.be.reverted;
    await expect(doomCultDAO.connect(addr1).transferFrom(owner.address, addr1.address, 2)).to.be.reverted;

    await doomCultDAO.connect(addr1).transferFrom(owner.address, addr1.address, 1);

    expect((await doomCultDAO.balanceOf(addr1.address)).toNumber()).to.equal(2);
    expect((await doomCultDAO.balanceOf(owner.address)).toNumber()).to.equal(1);
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
    await expect(doomCultDAO.sacrifice()).to.be.reverted;
  });

  it('test insufficient sacrifices', async function () {
    const DoomCultSocietyDAOTest = await ethers.getContractFactory('DoomCultSocietyDAOTest');
    const doomCultDAO = await DoomCultSocietyDAOTest.deploy({ gasLimit: 10000000 });
    await doomCultDAO.deployed();

    await doomCultDAO.forceMaximumCultists();
    await doomCultDAO.wakeUp();

    await expect(doomCultDAO.worship()).to.be.reverted;

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

    await doomCultDAO.sacrifice();
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
    expect((await doomCultDAO.totalSupply()).toNumber()).to.equal(30000);

    await expect(doomCultDAO.worship()).to.be.reverted;

    const tx = await (await doomCultDAO.sacrifice()).wait();
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

    const tx = await (await doomCultDAO.sacrifice()).wait();
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
    let strings = [
      'Willingly ',
      'Enthusiastically ',
      'Cravenly ',
      'Gratefully ',
      'Vicariously ',
      'Shockingly ',
      'Gruesomly ',
      'Confusingly ',
      'Angrily ',
      'Curiously ',
      'Mysteriously ',
      'Shamefully ',
      'Banished To The Void Using',
      'Crushed Under The Weight Of',
      'Devoured By',
      'Erased From Existence By',
      'Extinguished By',
      'Hugged To Death By',
      'Obliterated By',
      'Ripped Apart By',
      'Sacrificed In The Service Of',
      'Slaughtered Defending',
      'Succumbed To Burns From',
      'Torn To Shreds By',
      'Vanished At A Party Hosted By',
      'Vivisected Via',
      'Anarcho-Capitalist ',
      'Artificial ',
      'Energetic ',
      'Extreme ',
      'Ferocious ',
      'French ',
      'Funkadelic ',
      'Grossly Incompetent ',
      'Hysterical ',
      'Irrepressible ',
      'Morally Bankrupt ',
      'Overcollateralized ',
      'Politically Indiscreet ',
      'Punch-Drunk ',
      'Punk ',
      'Time-Travelling ',
      'Unsophisticated ',
      'Volcanic ',
      'Voracious ',
      "Grandmother's Leftover ",
      '4D Buckaroo',
      'Ballroom Dancing Fever',
      'Bees',
      'Canadians',
      'Electric Jazz',
      'Explosions',
      'FOMO',
      'Giant Gummy Bears',
      'Gigawatt Lasers',
      'Heavy Metal',
      'Lifestyle Vloggers',
      'Memes',
      'Physics',
      'Rum Runners',
      'Swine Flu',
      'Theatre Critics',
      'Trainee Lawyers',
      'Twitterati',
      'Velociraptors',
      'Witches',
      'Wizards',
      'Z-List Celebrities',
      'High-Stakes Knitting',
      'Hardtack And Whiskey',
      'The Communist Manifesto',
      'Week: 0',
      'Week: 1',
      'Week: 52',
      '0 Cultists Remaining',
      '1 Cultist Remaining', // grammar yo
      '2 Cultists Remaining',
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
    ];

    let seed = 0;
    while (strings.length > 0 && count < 500) {
      const uri = await doomCult.getImgString(seed);
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
