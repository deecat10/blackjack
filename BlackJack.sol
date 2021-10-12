// SPDX-License-Identifier: GPL-3.0


pragma solidity >=0.7.0 <0.9.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC721/ERC721.sol';
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

contract GameSetup {
    
    uint public time;
    
    address admin;
    
    address[] public players;
    
    uint public minimumBet;
    
    struct Card {
        address holder;
        string suit;
        string index;
    }
    mapping(address => Card[]) deck;
    mapping(address => uint) bets;

    constructor() {
        admin = msg.sender;
        time = block.timestamp;
    }
    
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
        deck[player].push(card);
    }
    
    function getPlayer(uint _idx) public view returns(address) {
        return players[_idx];
    }


}

/**
 * @title Blackjack
 * @dev Store & retrieve value in a variable
 */
contract Blackjack {
    
    
    
    GameSetup game;
    
    
    string[] suits = ['clubs','diamonds','spades','hearts'];
    string[] ids = ['ace','2','3','4','5','6','7','8','9','10','jack','queen','king'];
    
    struct Card {
        address holder;
        string suit;
        string index;
    }
    
    
    mapping(uint => Card) deck;
    mapping(uint => GameSetup) games;
    uint totalGames = 0;
    
    address internal setupAddress;
    
    constructor() {
    
        
        uint deckSize = 0;
        
        for(uint suit=0; suit<suits.length; suit++) {
            for(uint id=0; id<ids.length; id++) {
                deck[deckSize] = Card(
                    msg.sender,
                    suits[suit],
                    ids[id]
                );
                deckSize++;
            }
        }
    
    }
    
    function getGameInfo(uint _gameIdx) public returns(uint[3] memory){
        game = games[_gameIdx];
        uint total = game.totalBets();
        uint size = game.size();
        uint min = game.minimumBet();
        
        return [total, size, min];
        
    }
    function getTotalGames() public view returns (uint) {
        return totalGames;
    }
    
    mapping(uint => uint) timestamps; 
    mapping(uint => GameSetup) testContracts; // should return different timestamps per
    uint len = 0;
    
    
    
    
    function stamp() public returns(uint){
        GameSetup test = new GameSetup();
        
        testContracts[len] = test;
        timestamps[len] = test.time();
        
        return testContracts[len].time();
    }
    
    function getStamp(uint id) public view returns(uint, uint) {
        return(
            testContracts[id].time(),
            timestamps[id]
        );
    }
    
    function create() public {
        
        games[totalGames] = new GameSetup();
        totalGames++;
    }
    
    function getBet(uint gameIdx, address player) public view returns(uint) {
        return games[gameIdx].getBet(player);
    }
    
    function minimumBet(uint gameIdx) public view returns(uint) {
        return games[gameIdx].minimumBet();
    }
    
    function join(uint gameIdx) public payable {
        game = games[gameIdx];
        
        if(game.size() == 0) {
            games[gameIdx].setMinimumBet(msg.value);
        }
        
        require(msg.value >= game.minimumBet(), "bet not enough");
        
        games[gameIdx].addPlayer(msg.sender);
        games[gameIdx].setBet(msg.sender, msg.value);
        
    }
    
    function start(uint gameIdx) public {
        

        game = games[gameIdx];
        
        require(game.size() > 0, 'not enough players');
        
        for (uint player=0; player<game.size(); player++) {
            uint cardIdx = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % 52;
            
            Card memory card = deck[cardIdx];
            address addr = game.getPlayer(player);
            games[gameIdx].addCard(addr, card.suit, card.index);
            
        }
        

    }
    
    function bet(uint gameIdx) public {
        
        game = games[gameIdx];
        
        
        
    }
    
    
    
}
