const { toWei } = require('web3-utils')

module.exports = {
  sacred: {
    address: 'sacred.contract.sacredcash.eth',
    cap: toWei('10000000'),
    pausePeriod: 45 * 24 * 3600, // 45 days
    distribution: {
      miningV2: { to: 'rewardSwap', amount: toWei('1000000') },
      governance: { to: 'vesting.governance', amount: toWei('5500000') },
      team1: { to: 'vesting.team1', amount: toWei('822407') },
      team2: { to: 'vesting.team2', amount: toWei('822407') },
      team3: { to: 'vesting.team3', amount: toWei('822407') },
      team4: { to: 'vesting.team4', amount: toWei('500000') },
      team5: { to: 'vesting.team5', amount: toWei('32779') },
    },
  },
  governance: { address: 'governance.contract.sacredcash.eth' },
  governanceImpl: { address: 'governance-impl.contract.sacredcash.eth' },
  voucher: { address: 'voucher.contract.sacredcash.eth', duration: 12 },
  miningV2: {
    address: 'mining-v2.contract.sacredcash.eth',
    initialBalance: toWei('25000'),
    rates: [
      { instance: 'eth-01.sacredcash.eth', value: '10' },
      { instance: 'eth-1.sacredcash.eth', value: '20' },
      { instance: 'eth-10.sacredcash.eth', value: '50' },
      { instance: 'eth-100.sacredcash.eth', value: '400' },
    ],
  },
  rewardSwap: { address: 'reward-swap.contract.sacredcash.eth', poolWeight: 1e11 },
  sacredTrees: { address: 'sacred-trees.contract.sacredcash.eth'},
  sacredTreesImpl: { address: 'sacred-trees-impl.contract.sacredcash.eth'},
  sacredProxy: { address: 'sacred-proxy.contract.sacredcash.eth' },
  aaveInterestsProxy: { address: 'aave-interests-proxy.contract.sacredcash.eth'},
  rewardVerifier: { address: 'reward-verifier.contract.sacredcash.eth' },
  treeUpdateVerifier: { address: 'tree-update-verifier.contract.sacredcash.eth' },
  withdrawVerifier: { address: 'withdraw-verifier.contract.sacredcash.eth' },
  poseidonHasher1: { address: 'poseidon1.contract.sacredcash.eth' },
  poseidonHasher2: { address: 'poseidon2.contract.sacredcash.eth' },
  poseidonHasher3: { address: 'poseidon3.contract.sacredcash.eth' },
  deployer: { address: 'deployer.contract.sacredcash.eth' },
  vesting: {
    team1: {
      address: 'team1.vesting.contract.sacredcash.eth',
      beneficiary: '0x5A7a51bFb49F190e5A6060a5bc6052Ac14a3b59f',
      cliff: 12,
      duration: 36,
    },
    team2: {
      address: 'team2.vesting.contract.sacredcash.eth',
      beneficiary: '0xF50D442e48E11F16e105431a2664141f44F9feD8',
      cliff: 12,
      duration: 36,
    },
    team3: {
      address: 'team3.vesting.contract.sacredcash.eth',
      beneficiary: '0x6D2C515Ff6A40554869C3Da05494b8D6910D075E',
      cliff: 12,
      duration: 36,
    },
    team4: {
      address: 'team4.vesting.contract.sacredcash.eth',
      beneficiary: '0x504a9c37794a2341F4861bF0A44E8d4016DF8cF2',
      cliff: 12,
      duration: 36,
    },
    team5: {
      address: 'team5.vesting.contract.sacredcash.eth',
      beneficiary: '0x2D81713c58452c92C19b2917e1C770eEcF53Fe41',
      cliff: 12,
      duration: 36,
    },
    governance: {
      address: 'governance.vesting.contract.sacredcash.eth',
      cliff: 3,
      duration: 60,
    },
  }
}

