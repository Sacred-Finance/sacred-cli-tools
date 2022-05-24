require('dotenv').config()

module.exports = {
  deployments: {
    netId1: {
      eth: {
        instanceAddress: {
          '0.1': '0x9567Ca1cf1B2bcdc88086d4a40De2C7399419DD3',
          '1': '0x0e77E2720871438979052Aa39684F007A13754A0',
          '10': '0x17B21990Cf231aD2Ce277497ba22809008dbFe34',
          '100': '0x1303358E141102f26f424988e4ab5e232b339CF8'
        },
        symbol: 'ETH',
        decimals: 18
      },
      dai: {
        instanceAddress: {
          '100': undefined,
          '1000': undefined,
          '10000': undefined,
          '100000': undefined
        },
        tokenAddress: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
        symbol: 'DAI',
        decimals: 18
      },
    },
    netId42: {
      eth: {
        instanceAddress: {
          '0.1': '0x0dF4ec95D65ADa8e65D7567be3Db94A9fFE7c222',
          '1': '0xf76352786843484603CDa4d7E70b38f254aE2991',
          '10': '0xDD83997eb09B0F1B4e3adbAeb5C477B1cAEbaeFC',
          '100': '0x1303358E141102f26f424988e4ab5e232b339CF8'
        },
        symbol: 'ETH',
        decimals: 18
      },
      dai: {
        instanceAddress: {
          '100': undefined,
          '1000': undefined,
          '10000': undefined,
          '100000': undefined
        },
        tokenAddress: '0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa',
        symbol: 'DAI',
        decimals: 18
      },
    },
    netId80001: {
      eth: {
        instanceAddress: {
          '0.1': '0x19A00D7ed42e80f3fD6AA70F98ca5D967efeBDB4',
          '1': '0x79fF36Ca369b77c4bEd720145957C21b562A737f',
          '10': '0x4e0AD597BC5ee2751c317A5581325AcBD0675683',
          '100': '0x786c3d908B3F009B3336e9228E85E1D052aBa49C'
        },
        symbol: 'ETH',
        decimals: 18
      }
    },
    netId4: {
      eth: {
        instanceAddress: {
          '0.1': '0xd1C047765610da65E28D12acF354D11bE3233845',
          '1': '0x95c58b3ae4AE6A32A04f800f7BEC1dC9A9D4d798',
          '10': '0x533F4775C17aFBA952fd4eF8Db9F292D0e5b20aB',
          '100': '0xD752a914dDE2B1646D8f8ebE40f73ec746D553A5'
        },
        symbol: 'ETH',
        decimals: 18
      }
    }
  }
}
