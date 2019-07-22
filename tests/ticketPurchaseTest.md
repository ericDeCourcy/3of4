Ticket Purchasing Ability Test

1)	Perform all steps of setSeedTest. Ensure that the test passes

2)	create 4 accounts that are not the owner. We'll call them USER_0, USER_1, USER_2, & USER_3

3)	as USER_0, call the buyTickets function with an argument of 11 and with 1 test ether.
	This call should revert and the gas cost should be consumed

4)	as USER_0, call buyTickets with an argument of 1 and .001 Ether
	This call should revert and only the gas cost should be consumed

5)	as USER_0, call buyTickets with an argument of 0 and 1 Ether
	This call should pass and the Ether should be removed from USER_0's account

6)	as any user, call getNumTix with an argument of 0 and check that the returned value is 100

7)	as USER_1, call buyTickets with an argument of 1 and 1 Ether
	This call should pass and the Ether should be removed from USER_1's account

8)	as any user, call getNumTix with an argument of 1 and check that the returned value is 100

9)	as USER_2, call buyTickets with an argument of 2 and 1 Ether
	This call should pass and the Ether should be removed from USER_2's account

10)	as any user, call getNumTix with an argument of 2 and check that the returned value is 100

11)	as USER_3, call buyTickets with an argument of 3 and 1 Ether
	This call should pass and the Ether should be removed from USER_3's account

12)	as any user, call getNumTix with an argument of 3 and check that the returned value is 100
