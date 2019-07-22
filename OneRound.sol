pragma solidity ^0.5.10;

contract OneRound{

    //make mappings of each num of tix
    mapping(address => uint256) tix_0;
    mapping(address => uint256) tix_1;
    mapping(address => uint256) tix_2;
    mapping(address => uint256) tix_3;
    
    //make ticket totals for each available pool
    uint256 totalTix_0 = 0;
    uint256 totalTix_1 = 0;
    uint256 totalTix_2 = 0;
    uint256 totalTix_3 = 0;
        
    //total number of tickets bought, determined once when roll happens
    uint256 totalTix_all = 0;
    
    //loser tix, determined on roll
    uint256 loserTix = 0;
    
    //define ticket price
    uint ticketPrice = 0.01 ether;
    uint ticketWinShare = 0.003 ether;
    uint ownerWinShare = 0.001 ether;
    
    //bool roundFinished
    bool roundFinished = false;
    
    //bool hasBeenInitiated
    bool hasBeenInitiated = false;
    
    //bool ownerPayed
    bool ownerPayed = false;
    
    //owner address
    address payable owner;

    //define events
    event LogBet(address better, uint amount, uint betGroup);
    event LogSeed(uint blockNum, uint seedNum);
    event BettingFinished(uint blockNum);
    event seedReveal(uint revealedSeed, uint blockNum);
    event payment(uint paymentVal, address reciever);
    event rollDone(uint256 roll);
    event rollError(uint256 roll);
    
    //round seed 
    uint roundSeed = 0;
    
    //roll declaration - equals 69 is roll hasn't happened yet
    uint256 constant ROLL_NOT_HAPPENED = 69;
    uint256 roll = ROLL_NOT_HAPPENED;
    
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //allow purchasing of tix
    function buyTickets(uint8 betChoice) external payable returns(bool success) {
        //ensure that round has not finished
        require(!roundFinished);
        
        //ensure that the transaction has value above the min ticket price
        require(msg.value > ticketPrice);
        
        //ensure that bet choice is in range 0 - 3
        require(betChoice == 0 || betChoice == 1 || betChoice == 2 || betChoice == 3);
     
        //divide amount payed by ticket price to get num tickets
        uint256 ticketsBought = uint256(msg.value / ticketPrice);
        
        //use logic to determine which pot to place bet in
        //add that amount of tickets to the user's mapping
        //add to ticket total for that pool
        if(betChoice < 2)
        {
            if(betChoice == 0)
            {
                tix_0[msg.sender] += ticketsBought;
                totalTix_0 += ticketsBought;
                emit LogBet(msg.sender, ticketsBought, 0);
                return true;
            }
            else    //betChoice == 1
            {
                tix_1[msg.sender] += ticketsBought;
                totalTix_1 += ticketsBought;
                emit LogBet(msg.sender, ticketsBought, 1);
                return true;
            }
        }
        else
        {
            if(betChoice == 2)
            {
                tix_2[msg.sender] += ticketsBought;
                totalTix_2 += ticketsBought;
                emit LogBet(msg.sender, ticketsBought, 2);
                return true;
            }
            else
            {
                tix_3[msg.sender] += ticketsBought;
                totalTix_3 += ticketsBought;
                emit LogBet(msg.sender, ticketsBought, 3);
                return true;
            }
        }
        
        return false;
    }
    
    //initiate function
    function setSeed(uint256 seed) public onlyOwner returns(bool success){
        
        //take hash and save as round seed
        roundSeed = seed;
        
        //log the event
        emit LogSeed(block.number, seed);
        
        //set contract to having been initiated
        hasBeenInitiated = true;
        
        //success
        return true;
    }
    
    function deriveSeed(uint input) public view returns(bytes32 newSeedInput)
    {
        return(keccak256(abi.encodePacked(input)));
    }
    
    //check what the output of seed-input is and see whether is matches seedVal after its been encrypted
    function checkSeed(uint seedInput) public view returns(bool seedInputHashMatchesRoundSeed)
    {
        require(hasBeenInitiated);
        
        return(keccak256(abi.encodePacked(seedInput)) == bytes32(roundSeed));
        
    }
        
    //roll function (input)
    function rollTheDice(uint input) public returns(uint256 rollOutcome)
    {
        //require that sha256(input) == round seed 
        require(keccak256(abi.encodePacked(input)) == bytes32(roundSeed));
        
        //require owner
        require(msg.sender == owner);
        
        //XOR input with "random" number from specified block hash
        uint rollResult = input ^ uint256(blockhash(block.number));
        
        //bitwise AND with 0b0....011. Should give a number 0-3
        //save this answer as roll
        roll = rollResult & uint256(0x03);
        
        //set bool roundFinished to true
        roundFinished = true;
        
        //calculate the number of total tickets
        totalTix_all = totalTix_0 + totalTix_1 + totalTix_2 + totalTix_3;
        
        //determine number of tickets in loser pot
        if(roll > 2)
        {   if(roll == 0)       {   loserTix = totalTix_0;  }
            else if(roll == 1)  {   loserTix = totalTix_1;  }   }
        else
        {   if(roll == 2)       {   loserTix = totalTix_2;  }
            else if (roll == 3) {   loserTix = totalTix_3;  }   
            else                {   emit rollError(roll);   
                                    return ROLL_NOT_HAPPENED;   }
        }
        
        emit seedReveal(input, block.number);       
        emit rollDone(roll);

        return roll;
    }
    
    //payout function
//TODO: check that this function is not vulnerable to re-entrancy
    function payout() public returns(bool success){
        
        //require roundFinished
        require(roundFinished);
        
        uint payoutAmount = 0;
        
        if(roll != 0)   //if roll wasnt 0, then calculate payout for any 0-tickets
        {   
            if((tix_0[msg.sender] > 0) && (totalTix_0 > 0))   
            {   
                payoutAmount += loserTix*ticketWinShare*tix_0[msg.sender]/totalTix_0;
            }
        }
        if(roll != 1)   //same as above but for roll of 1
        {
            if(tix_1[msg.sender] > 1 && totalTix_1 > 0)
            {
                payoutAmount += loserTix*ticketWinShare*tix_1[msg.sender]/totalTix_1;
            }
        }
        if(roll != 2)
        {
            if(tix_2[msg.sender] > 2 && totalTix_2 > 0)
            {
                payoutAmount += loserTix*ticketWinShare*tix_2[msg.sender]/totalTix_2;
            }
        }
        if(roll != 3)
        {
            if(tix_3[msg.sender] > 3 && totalTix_3 > 0)
            {
                payoutAmount += loserTix*ticketWinShare*tix_3[msg.sender]/totalTix_3;
            }
        }
        
        tix_0[msg.sender] = 0;
        tix_1[msg.sender] = 0;
        tix_2[msg.sender] = 0;
        tix_3[msg.sender] = 0;

        msg.sender.transfer(payoutAmount);
        emit payment(payoutAmount, msg.sender);
        
        return true;
    }         
        
    function payOwner() public onlyOwner {

        require(roundFinished);
        
        //require owner not payed yet
        require(!ownerPayed);

        //calculate payment
        uint ownerPayment = ownerWinShare * loserTix;

        // change payed variable to true
        ownerPayed = true;

        //transfer? send?
        owner.transfer(ownerPayment);
    }
    
    function getNumTix(uint256 pool) public view returns(uint256 numTix){
        require(pool == 0 || pool == 1 || pool == 2 || pool == 3);
    
        if(pool == 0)   {   return totalTix_0;  }
        else if(pool == 1)  {   return totalTix_1;  }
        else if(pool == 2)  {   return totalTix_2;  }
        else    {   return totalTix_3;  }
    }
    
    //function emergency refund
        //gotta figure this out before final release
        //only owner
        //emergency refund set to true
            //other payout type functions dont work if E-refund == true
        //log the event

    //function sendEmergencyRefund()
        //require emergencyRefund
        //decrements num of tix of msg.sender
        //sends ticketprice * numtix to msg.sender
        //log the event
}
