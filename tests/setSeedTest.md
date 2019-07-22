Setting Seed and Verification Test

1)	Compile contract and deploy to a chain with remix, ganache, or a testnet (like Rinkeby)
	Deploying address will be known as "owner"

2)	As the owner, call "deriveSeed" as the owner with 123 as the argument.
	Check that the result is 0x5569044719a1ec3b04d0afa9e7a5310c7c0473331d13dc9fafe143b2c4e8148a

3)	As the owner, call setSeed with 0x5569044719a1ec3b04d0afa9e7a5310c7c0473331d13dc9fafe143b2c4e8148a as the argument.

4)	As the owner, call "checkSeed" with 123 as the argument.
	
5)	If "checkSeed" returns true, the test has passed and you can reliably set a seed
