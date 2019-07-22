TODO: change the seed setting thing such that the seed cannot be changed once it’s set
TODO: add permissions time-out functionality - round ends at block x and starts when owner commits a seed
May change setting seed to setSeed(seed, finalBlock)
Add a boolean for “roundIsGoing” and add require statements in front of every function saying whether they can be activated while round is going
TODO: add fallback function that handles erroneous payments. Maybe create a variable representing the extra amount due to erroneous sends
TODO: implement safemath in the winnings calculations
TODO: test that claiming winnings isnt vulnerable to re-entrancy
TODO: add pay owner function
TODO: add annoying thing to fix a tip-address into the pay owner function
TODO: create an emergency refund mechanism
TODO: check that Readme still applies
