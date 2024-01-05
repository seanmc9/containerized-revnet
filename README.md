## Containerized Revnet

A containerized version of https://github.com/rev-net/revnet-contracts.

Left TODOs:
- [ ] implement buyback mechanism
- [ ] implement dynamic intra-stage price ceiling

### Development

To build, use this [Foundry](https://book.getfoundry.sh/) `forge` command:
```shell
$ forge build
```

If you don't have [Foundry](https://book.getfoundry.sh/), you can get it by following the [instructions here](https://book.getfoundry.sh/getting-started/installation) under the "Use Foundryup" section. Namely:
1. Run `curl -L https://foundry.paradigm.xyz | bash` in your terminal.
2. Run `foundryup` in your terminal.
