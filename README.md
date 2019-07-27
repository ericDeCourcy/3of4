# 3of4
Ethereum Contract where 3 of 4 betting pools win a share of the losing betting pool's ether

This contract will allow users to bet on different pools, named pool 0, 1, 2, and 3. The users will need to buy "tickets" at a price of 0.01 ether per ticket.
A random number will be selected in the range of 0 to 3. The pool indicated by this number is the loser, and each pool will proportionally split 30% of that pool's funds. The remaining funds will be payed to the contract owner (this is still in progress)

------------------------------------------------------------
## HOW TO USE THIS CONTRACT:
1)  owner picks a random value. This will be referred to as the `input` 
2)  owner writes this value down because it's very important to remember it. This value should also be kept secret.
3)  owner feeds this value into `deriveSeed` function and gets another value, the `seed`.
4)  owner uses the `setSeed` function, passing it the `seed` value (not the `input`!!!)
5)  players can place bets using the `buyTickets` function. The value `0`, `1`, `2`, or `3` should be passed into this function to indicate which pool the player wants to bet on. The number of tickets will be automatically determined based on the amount payed to the contract (price of 0.01 ETH per ticket)
6)  When betting is over, owner calls `rollTheDice` function, passing in the `input` (not the `seed`!!!) to it.
7)  The contract will generate a "random" number from 0 to 3 and perform some calculations
8)  players can now claim thier winnings by calling the `payout` function 
9)  owner can claim their share of the winnings by calling the `payOwner` function.
10) owner kills the contract after everyone has claimed thier winning because they are nice and responsible [STILL IN PROGRESS]
-----------------------------------------------------------

## Notes on `seed` versus `input`:
The owner of the contract will need to pick an `input`, and then hash this (keccak256) to get a `seed` for the contract.
The `input` to `seed` conversion should be done in-contract via the viewable function `deriveSeed`. Since this function has the view modifier, it will not result in a change to the blockchain, keeping your original input secret.
The contract owner will give this function an `input`, and it will be hashed into a `seed`. Be sure to remember the `input`.
The contract owner should then pass this `seed` value into the `setSeed` function.
When "rolling the dice" occurs, the owner of the contract will pass the original `input` in and it will be hashed and compared to the seed to verify that the seed value is unchanged, and afterwards input will be used in combination with blockhash to determine a "random" value.

The reasoning for the seed creation mechanism used here is that using the blockhash alone to create a random number allows the miners the possibility of manipulating the result to thier advantage. By using the seed-input to seed mechanism, the miner has no idea what the input is, which affects the "random" value, yet users can be assured that the value of seed-input isn't changing to suit the owner's preferences. Essentially, the contract becomes un-predicatable and un-abusable UNLESS the owner of the contract is also the one who mines the block used in the blockhash. At time of writing abuse is possible if the owner has control over the block in which `rollTheDice` is called.

------------------------------------------------------------
Donation ETH address: 0xF1f328a013da8cf8061E420DF109ce1Ab5c7C2f1      
<3

