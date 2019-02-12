pragma solidity ^0.5.2;

contract threeOuttaFour{



    //define owner address
    //THIS IS VERY IMPORTANT  ----  IMPORTANT   ----    IMPORTANT
    address owner = 0xF1f328a013da8cf8061E420DF109ce1Ab5c7C2f1;
    //THIS IS VERY IMPORTANT  ----  IMPORTANT   ----    IMPORTANT







    //make mappings of each num of tix
    //uint 24 is used because this corresponds to 16777216 tickets. Thats alot of money if you're trying to somehow break this
    mapping(address => uint24) tix_0;
    mapping(address => uint24) tix_1;
    mapping(address => uint24) tix_2;
    mapping(address => uint24) tix_3;
    
    //make ticket totals for each available pool
    uint32 totalTix_0 = 0;
    uint32 totalTix_1 = 0;
    uint32 totalTix_2 = 0;
    uint32 totalTix_3 = 0;
        
    //total number of tickets bought, determined once when roll happens
    uint32 totalTix_all = 0;
    
    //loser tix, determined on roll
    uint32 loserTix = 0;
    
    //define ticket price
    uint ticketPrice = 0.01 ether;
    uint ticketWinShare = 0.003 ether;
    
    //bool roundFinished
    bool roundFinished = false;
    
    //bool hasBeenInitiated
    bool hasBeenInitiated = false;
    
    //define events
    event LogBet(address better, uint amount, uint betGroup);
    event LogSeed(uint blockNum, uint seedNum);
    event BettingFinished(uint blockNum);
    event seedReveal(uint revealedSeed, uint blockNum);
    event payment(uint paymentVal, address reciever);
    
    //round seed 
    uint roundSeed = 0;
    
    //roll declaration - equals 69 is roll hasn't happened yet
    uint8 roll = 69;
    
    //allow purchasing of tix
    function buyTickets(uint8 betChoice) public payable returns(bool success) {
        //ensure that round has not finished
        require(!roundFinished);
        
        //ensure that the transaction has value above the min ticket price
        require(msg.value > ticketPrice);
        
        //ensure that bet choice is in range 0 - 3
        require(betChoice == 0 || betChoice == 1 || betChoice == 2 || betChoice == 3);
        
        //divide amount payed by ticket price to get num tickets
        uint24 ticketsBought = uint24(msg.value / ticketPrice);
        
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
    function initiate(uint seed) public returns(bool success){
        //require owner
        require(msg.sender == owner);
        
        //take input hash and save as round seed
        roundSeed = seed;
        
        //log the event
        emit LogSeed(block.number, seed);
        
        //set contract to having been initiated
        hasBeenInitiated = true;
        
        //success
        return true;
    }
    
    function makeSeed(uint input) public view returns(bytes32 newSeedInput)
    {
        return(keccak256(abi.encodePacked(input)));
    }
    
    //check what the output of seed-input is and see whether is matches seedVal after its been encrypted
    function checkSeed(uint seedInput) public view returns(bytes32 result, bytes32 seedVal)
    {
        require(hasBeenInitiated);
        
        return(keccak256(abi.encodePacked(seedInput)), bytes32(roundSeed));
        
    }
        
    //roll function (input)
    function rollTheDice(uint input) public returns(uint8 rollOutcome)
    {
        //require that sha256(input) == round seed 
        require(keccak256(abi.encodePacked(input)) == bytes32(roundSeed));
        
        //require owner
        require(msg.sender == owner);
        
        //XOR input with "random" from specified block
        uint rollResult = input ^ uint256(blockhash(block.number));
        
        //modulo with 4
        //save this answer as roll
        roll = uint8(rollResult & uint256(0x03));
        
        //set bool roundFinished to true
        roundFinished = true;
        
        //calculate the number of total tickets
        totalTix_all = totalTix_0 + totalTix_1 + totalTix_2 + totalTix_3;
        
        //determine tickets of loser
        if(roll > 2)
        {   if(roll == 0)   {   loserTix = totalTix_0;  }
            else            {   loserTix = totalTix_1;  }   }
        else
        {   if(roll == 2)   {   loserTix = totalTix_2;  }
            else            {   loserTix = totalTix_3;  }   }
            
        emit seedReveal(input, block.number);
        
        return roll;
    }
    
    //payout function
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
        
        msg.sender.transfer(payoutAmount);
        emit payment(payoutAmount, msg.sender);
        
        tix_0[msg.sender] = 0;
        tix_1[msg.sender] = 1;
        tix_2[msg.sender] = 2;
        tix_3[msg.sender] = 3;
        
        return true;
    }
    
    function payout_0() public returns (bool success){
        
        //require round finished and roll != 0
        require(roundFinished && roll != 0);
        
        //find payout for this pot
        uint payoutAmount = 0; //loserTix*ticketWinShare*tix_0[msg.sender]/totalTix_0;
        
        //send payment and log this payment
        msg.sender.transfer(payoutAmount);
        emit payment(payoutAmount, msg.sender);
        
        //clear thier payment so you can't pay them again
        tix_0[msg.sender] = 0;
        
        return true;
    }
        
         
        
    //function payOwner
        //require owner
        //payment = ticketPrice*(tix_1 + tix_2 + tix_3 + tix_4)/10
        //pay owner this payment
    
    //function emergency refund
        //gotta figure this out before final release

    //function random() private view returns (uint8) {
    //    return uint8(uint256(keccak256(block.timestamp, block.difficulty))%251);
    //}
}
