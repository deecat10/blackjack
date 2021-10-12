// SPDX-License-Identifier: GPL-3.0


pragma solidity >=0.7.0 <0.9.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC20/ERC20.sol';


interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Game {

    
    address[] public players;
    
    uint public minimumBet;
    
    struct Card {
        address holder;
        string suit;
        string index;
    }
    
    mapping(address => Card[]) deck;
    mapping(address => uint) bets;

    
    function addPlayer(address _addr) public {
        players.push(_addr);
    }
    
    function size() public view returns(uint) {
        return players.length;
    }
    
    function totalBets() public view returns(uint) {
        uint total = 0;
        for(uint i=0; i<players.length; i++) {
            address player = players[i];
            total += bets[player];
        }
        return total;
    }
    
    function getBet(address _addr) public view returns(uint) {
        return bets[_addr];
    }
    
    function setBet(address _addr, uint _bet) public {
        bets[_addr] = _bet;
    }
    
    function setMinimumBet(uint _amount) public {
        minimumBet = _amount;
    }
    
    function addCard(address player, string memory suit, string memory index) public {
        Card memory card = Card(player, suit, index);
        require(deck[player].length < 2, 'hand is full');
        deck[player].push(card);
    }
    
    function getPlayer(uint _idx) public view returns(address) {
        return players[_idx];
    }


}

/**
 * @title Blackjack
 */
contract Blackjack is Game {
    
    
    
    
    string[] suits = ['clubs','diamonds','spades','hearts'];
    string[] ids = ['ace','2','3','4','5','6','7','8','9','10','jack','queen','king'];
   
    
    mapping(uint => Game) games;
    mapping(uint => Card) allCards;
    uint totalGames = 0;
    
    address internal setupAddress;
    
    constructor() {
    
        
        uint deckSize = 0;
        
        for(uint suit=0; suit<suits.length; suit++) {
            for(uint id=0; id<ids.length; id++) {
                allCards[deckSize] = Card(
                    msg.sender,
                    suits[suit],
                    ids[id]
                );
                deckSize++;
            }
        }
    
    }
    
    function getGameInfo(uint _gameIdx) public view returns(uint[3] memory){
        uint total = games[_gameIdx].totalBets();
        uint size = games[_gameIdx].size();
        uint min = games[_gameIdx].minimumBet();
        
        return [total, size, min];
        
    }
    function getTotalGames() public view returns (uint) {
        return totalGames;
    }
    
    
    function create() public {
        
        games[totalGames] = new Game();
        totalGames++;
    }
    
    function getBet(uint gameIdx, address player) public view returns(uint) {
        return games[gameIdx].getBet(player);
    }
    
    function getBuyIn(uint gameIdx) public view returns(uint) {
        return games[gameIdx].minimumBet();
    }
    
    function join(uint gameIdx) public payable {

        if(games[gameIdx].size() == 0) {
            games[gameIdx].setMinimumBet(msg.value);
        }
        
        require(msg.value >= games[gameIdx].minimumBet(), "bet not enough");
        
        games[gameIdx].addPlayer(msg.sender);
        games[gameIdx].setBet(msg.sender, msg.value);
        
    }
    
    function start(uint gameIdx, uint more_randomness) public {
        

        require(games[gameIdx].size() > 0, 'not enough players');
        
        for (uint player=0; player < games[gameIdx].size(); player++) {
            uint cardIdx = uint(keccak256(abi.encodePacked(more_randomness, block.timestamp, block.difficulty, msg.sender))) % 52;
            
            Card memory card = allCards[cardIdx];
            address addr = games[gameIdx].getPlayer(player);
            games[gameIdx].addCard(addr, card.suit, card.index);
        }
        

    }
    
    
    
}
