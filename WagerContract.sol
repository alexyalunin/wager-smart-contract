//0x2D561431889b87Afeff24609Ae948B3D9cB4C47b
//0xB80aE64b77872AD5536Dbdf22704e617C4DafEc0

pragma solidity ^0.4.11;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) return;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract WagerContract is owned {
    
    uint8 public winner;
    bool public winnerSet;
    
    mapping (uint8 => uint256) public moneyFor;
    mapping (address => mapping(uint8 => uint256)) public betOf;

    /* This generates a public event on the blockchain that will notify clients */
    event Bet(address indexed from, uint8 indexed teamFor, uint256 value);
    event WinnerSet(uint8 indexed winner);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function BetTest() {
    }

    function makeBet(uint8 _teamNumber) payable {
        moneyFor[_teamNumber] += msg.value;
        betOf[msg.sender][_teamNumber] += msg.value;
        Bet(msg.sender, _teamNumber, msg.value);
    }

    function setWinner(uint8 _winner) onlyOwner {
        winner = _winner;
        winnerSet = true;
        WinnerSet(winner);
    }

    function safeWithdrawal() {
        require(winnerSet);
        require(betOf[msg.sender][winner] > 0);

        uint256 myPartForTheWinner = betOf[msg.sender][winner] / moneyFor[winner];
        uint256 moneyToSend = myPartForTheWinner * this.balance;

        if (!msg.sender.send(moneyToSend)) {
            return;                                         
        } else {
            moneyFor[winner] -= betOf[msg.sender][winner];
            betOf[msg.sender][winner] = 0;
            Transfer(this, msg.sender, moneyToSend);           
        } 
    }

}