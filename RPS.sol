// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RPSContract{

    //modifier onlyOwner
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    //Owner's address
    address owner; 

    //event to track result of Coin Flip
    event RPSGame(address player, uint256 amount, uint8 option, uint256 result, uint randomnumber); 

    //payable = user может заплатить в BNB (главная монета в блокчейне)
    //in Constructor we assign owner's address;
    constructor() payable {
        owner = msg.sender;
    }

    //function that asks for 0 or 1 and returns if you win or lose
    function RPS(uint8 _option) public payable returns (uint result){ //view, pure = gassless 
        require(_option == 0||_option == 1||_option == 2, "Please select Rock, Paper or Scissors"); // requiere to choose readable options
        require(msg.value>0, "Please add your bet"); //WEI smallest unit ETH 
        //1,000,000,000,000,000,000 WEI = 1 ETH 
        require(msg.value*2 <= address(this).balance, "Contract balance is insuffieient ")
        ;
        
        //generate encoded PseudoRandom
        uint randomnumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))))
        ;
        while (randomnumber%10 == 0) {
        randomnumber = randomnumber/10 // we have to be sure that the last digit is not a zero
        ;
        }
        randomnumber = randomnumber%10; // get a natural number 
       
        //Emiting event of Coin Flip
        emit RPSGame(msg.sender, msg.value, _option, randomnumber, result);

        // Set checking win/lose conditions
        if (_option == randomnumber){
        //If same choise - draw and refund
            payable(msg.sender).transfer(msg.value);
            result = 0;
        } else if (_option ==2 && randomnumber == 1 || _option ==1 && randomnumber == 0 || _option ==0 && randomnumber == 2)
        // if user wins he get a double bet
        {
            payable(msg.sender).transfer(msg.value*2);
            result = 1;
        }
        // if user lose he lose
        else if (_option ==2 && randomnumber == 1 || _option ==1 && randomnumber == 0 || _option ==0 && randomnumber == 2)
        {
            result = 2;
        //If something went wrong
        } else {
            result = 3;
        }
    }
    
    //Owner can withdraw BNB amount
    function withdraw () public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

}

