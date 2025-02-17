# Welcome to Pathfinder

A StarkNet full node giving you a safe view into StarkNet.

Pathfinder is currently in alpha so expect some rough edges but it is already usable today!

## Features

- access the full StarkNet state history
  - includes contract code and storage, and transactions
- verifies state using L1
  - calculates the StarkNet state's Patricia-Merkle Trie root on a block-by-block basis and confirms it against L1
  - this means the contract code and storage are now locally verified
- Ethereum-like RPC API
- run StarkNet functions without requiring a StarkNet transaction
  - executed against the local state

## Feedback

We appreciate any feedback, especially during this alpha period. This includes any documentation issues, feature requests and bugs that you may encounter.

For help or to submit bug reports or feature requests, please open an issue or alternatively visit the StarkNet [discord channel](https://discord.com/invite/uJ9HZTUk2Y).

## Installation

### Prerequisites

Currently only supports Linux. Windows and MacOS support is planned.
We need access to a full archive Ethereum node operating on the network matching the StarkNet network you wish to run. Currently this is either Goerli or Mainnet.

Before you start, make sure your system is up to date with Curl and Git available

```bash
sudo apt update
sudo apt upgrade
sudo apt install curl
sudo apt install git
```

### Install Rust

`pathfinder` requires Rust version `1.58` or later. The easiest way to install Rust is by following the [official instructions](https://www.rust-lang.org/tools/install).


If you already have Rust installed, verify the version:
```bash
cargo --version # must be 1.58 or higher
```
To update your Rust version, use the `rustup` tool that came with the official instructions:
```bash
rustup update
```

### Install Python

`pathfinder` requires Python version `3.7` or `3.8`. (In particular, `cairo-lang` 0.7.1 seems incompatible with Python 3.10.)

```bash
sudo apt install python3
sudo apt install python3-venv
sudo apt install python3-dev
```
Verify the python version. Some Linux distributions only supply an outdated python version, in which case you will need to lookup a guide for your distribution.
```bash
python3 --version # must be 3.7 or 3.8
```

### Install build dependencies
`pathfinder` compilation need additional libraries to be installed (C compiler, linker, other deps)

```bash
sudo apt install build-essential
sudo apt install libgmp-dev
sudo apt install pkg-config
sudo apt install libssl-dev
```

### Clone `pathfinder`

Checkout the latest `pathfinder` release by cloning this repo and checking out the latest version tag. Take care not to be on our `main` branch as we do actively develop in it.

### Python setup

Create a python virtual environment in the `py` folder.

```bash
# Enter the `<repo>/py` directory
cd py
# Create the virtual environment and activate it
python3 -m venv .venv
source .venv/bin/activate
```
Next install the python tooling and dependencies
```bash
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt
```
Finally, run our python tests to make sure you were succesful.
```bash
# This should run the tests (and they should pass).
pytest
```

### Compiling `pathfinder`

You should now be able to compile `pathfinder` by running (from within the `pathfinder` repo):
```bash
cargo build --release --bin pathfinder
```

## Running the node

Ensure you have activated the python virtual environment you created in the [python setup step](#python-setup). For the `pathfinder` environment this is done by running:
```bash
source <path-to-pathfinder-repo>/py/.venv/bin/activate
```
If you are already in another virtual environment, you can exit it by running `deactivate` and then activating the `pathfinder` one.

This step is always required when running `pathfinder`.

Finally, you can start the node:
```bash
cargo run --release <path-to-pathfinder-repo> --bin pathfinder -- <pathfinder options>
```
Note the extra "`--`" which separate the Rust `cargo` command options from the options for our node. For more information on these options see the [Configuration](#configuration) section.

It may take a while to first compile the node on the first invocation if you didn't do the [compilation step](#compiling-pathfinder).

`pathfinder` runs relative to the current directory. This means things like the database will be created and searched for within the current directory.

### Configuration

The `pathfinder` node options can be configured via the command line as well as a configuration file. The command line configuration overrides the options from the file.

The command line options are passed in after the after the `cargo run` options, as follows:
```bash
cargo run --release <path-to-pathfinder-repo> --bin pathfinder -- <pathfinder options>
```

Using `--help` will display the `pathfinder` options:
```bash
cargo run --release <path-to-pathfinder-repo> --bin pathfinder -- --help
```

The configuration file uses the `toml` format:
```toml
# The address we will host the RPC API at. Defaults to "127.0.0.1:9545"
http-rpc = "127.0.0.1:1235"

[ethereum]
# This is required and must be an HTTP(s) URL pointing to your Ethereum node's endpoint.
url      = "https://goerli.infura.io/v3/..." #
# The optional password for your Ethereum endpoint.
password = "..."
# The optional user-agent for your Ethereum endpoint.
user     = "..."
```

### Logging

Logging can be configured using the `RUST_LOG` environment variable. We recommend setting it when you invoke the run command:

```bash
RUST_LOG=<log level> cargo run --release <path-to-pathfinder-repo> --bin pathfinder ...
```
The following log levels are supported, from most to least verbose:
```bash
trace
debug
info  # default
warn
error
```
At the more verbose log levels (`trace`, `debug`), you may find the logs a bit noisy as our dependencies also add their own logging to the mix. You can restrict the logs to only `pathfinder` specific ones using `RUST_LOG=pathfinder=<level>` instead. For example:
```bash
RUST_LOG=pathfinder=<log level> cargo run --release <path-to-pathfinder-repo> --bin pathfinder ...
```

### Network Selection

The StarkNet network is based on the provided Ethereum endpoint. If the Ethereum endpoint is on the Goerli network, then the it will be the StarkNet testnet on Goerli. If the Ethereum endpoint is on mainnet, then it will be StarkNet Mainnet.

## Running with Docker

The `pathfinder` node can be run in the provided Docker image.

```bash
docker run \
  -e RUST_LOG=info \
  -p 9545:9545 \
  eqlabs/pathfinder \
    --http-rpc="0.0.0.0:9545" \
    --ethereum.url="https://goerli.infura.io/v3/<project-id>" \
    --ethereum.password="<password>"
```

### Building the container image yourself

You can build the image by running:

```bash
docker build -t pathfinder .
```

You can then start the node with:

```bash
docker run --rm -it -e RUST_LOG=info -p 9545:9545 pathfinder --http-rpc "0.0.0.0:9545" --ethereum.url  https://goerli.infura.io/v3/<project-id> --ethereum.password <password>
```

To persist state between restarts you can mount a volume in the Docker container. To run the container and persist data to `/tmp/data` run:

```bash
docker run --rm -it -e RUST_LOG=info -p 9545:9545 -v /tmp/data:/usr/share/pathfinder/data pathfinder --http-rpc "0.0.0.0:9545" --ethereum.url  https://goerli.infura.io/v3/<project-id> --ethereum.password <password>
```


## API

The full specification is available [here](https://github.com/starkware-libs/starknet-specs). Note that we currently only support a subset of these. Here is an overview of the JSON-RPC calls which we support.

```bash
# Block information
starknet_getBlockByHash
starknet_getBlockByNumber
# Value of a storage at a given address and key
starknet_getStorageAt
# Transaction information
starknet_getTransactionByHash
starknet_getTransactionByBlockHashAndIndex
starknet_getTransactionByBlockNumberAndIndex
starknet_getTransactionReceipt
# Block transaction counts
starknet_getBlockTransactionCountByHash
starknet_getBlockTransactionCountByNumber
# The code of a specific contract
starknet_getCode
# Call a StarkNet function without creating a transaction
starknet_call
# The latest StarkNet block height
starknet_blockNumber
# The StarkNet chain this node is on
starknet_chainId
# The node's sync status
starknet_syncing
```

## License

Licensed under either of

 * Apache License, Version 2.0
   ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license
   ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
