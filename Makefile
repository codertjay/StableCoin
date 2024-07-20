include .env

DeployBitcoinPoolTest:
	forge script script/DeployBitcoinPool.s.sol --rpc-url $(POLYGON_RPC_URL)  -vvvv    --sender $(SENDER_ADDRESS)

DeployBitcoinPool:
	forge script script/DeployBitcoinPool.s.sol --rpc-url  $(POLYGON_RPC_URL)  -vvvv  --verify --broadcast   --sender 0x1B395389386F3f2a27866dAD8f7dDbb31c392e66

Test:
	forge test   -vvv --fork-url  $(POLYGON_RPC_URL)

