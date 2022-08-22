# Dss GemJoin Integration Tests
![Tests](https://github.com/makerdao/dss-gem-joins-integration-tests/actions/workflows/.github/workflows/tests.yml/badge.svg?branch=master)

This repository contains mainnet integration tests for GemJoin adapters against mainnet target tokens.

### Requirements

- [Foundry](https://getfoundry.sh/)

### Getting Started

```bash
$ git clone https://github.com/makerdao/dss-gem-joins-integration-tests.git
$ cd dss-gem-joins-integration-tests
$ forge update
```

### Test

Set `ETH_RPC_URL` to a Mainnet node.

```bash
$ export ETH_RPC_URL=<Mainnet RPC URL>
$ make test
```
