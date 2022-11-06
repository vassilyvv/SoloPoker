// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract SoloPoker {
    uint8 DEAL_SIZE = 5;
    enum Suit{ DIAMONDS, CLUBS, HEARTS, SPADES }
    enum Rank { 
        TWO, 
        THREE,
        FOUR,
        FIVE,
        SIX,
        SEVEN,
        EIGHT,
        NINE,
        TEN,
        JACK,
        QUEEN,
        KING,
        ACE
    }
    enum Hand {
        HIGH,
        PAIR,
        TWO_PAIRS,
        THREE_OF_A_KIND,
        STRAIGHT,
        FLUSH,
        FULL_HOUSE,
        FOUR_OF_A_KIND,
        STRAIGHT_FLUSH,
        ROYAL_FLUSH
    }


    struct Card { 
       Rank rank;
       Suit suit;
    }

    uint public unlockTime;
    address payable public owner;

    event Withdrawal(uint amount, uint when);

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }


    function getHandRepresentation(Hand hand) private returns(string memory) {
        if (hand == Hand.HIGH) {
            return "HIGH";
        }
        if (hand == Hand.PAIR) {
            return "PAIR";
        }
        if (hand == Hand.TWO_PAIRS) {
            return "TWO PAIRS";
        }
        if (hand == Hand.THREE_OF_A_KIND) {
            return "THREE OF A KIND";
        }
        if (hand == Hand.STRAIGHT) {
            return "STRAIGHT";
        }
        if (hand == Hand.FLUSH) {
            return "FLUSH";
        }
        if (hand == Hand.FULL_HOUSE) {
            return "FULL HOUSE";
        }
        if (hand == Hand.FOUR_OF_A_KIND) {
            return "FOUR OF A KIND";
        }
        if (hand == Hand.STRAIGHT_FLUSH) {
            return "STRAIGHT FLUSH";
        }
        if (hand == Hand.ROYAL_FLUSH) {
            return "ROYAL FLUSH";
        }
    }
    function getCardRepresentation(Card memory card) private returns(string memory) {
        string memory suit;
        if (card.suit == Suit.DIAMONDS) {
            suit = unicode"♦";
        }
        if (card.suit == Suit.CLUBS) {
            suit = unicode"♣";
        }
        if (card.suit == Suit.HEARTS) {
            suit = unicode"♥";
        }
        if (card.suit == Suit.SPADES) {
            suit = unicode"♠";
        }
        if (card.rank == Rank.ACE) {
            return string.concat("A", suit);
        }
        if (card.rank == Rank.TWO) {
            return string.concat("2", suit);
        }
        if (card.rank == Rank.THREE) {
            return string.concat("3", suit)  ;
        }
        if (card.rank == Rank.FOUR) {
            return string.concat("4", suit);
        }
        if (card.rank == Rank.FIVE) {
            return string.concat("5", suit);
        }
        if (card.rank == Rank.SIX) {
            return string.concat("6", suit);
        }
        if (card.rank == Rank.SEVEN) {
            return string.concat("7", suit)  ;
        }
        if (card.rank == Rank.EIGHT) {
            return string.concat("8", suit)  ;
        }
        if (card.rank == Rank.NINE) {
            return string.concat("9", suit);
        }
        if (card.rank == Rank.TEN) {
            return string.concat("10", suit);
        }
        if (card.rank == Rank.JACK) {
            return string.concat("J", suit);
        }
        if (card.rank == Rank.QUEEN) {
            return string.concat("Q", suit)  ;
        }
        if (card.rank == Rank.KING) {
            return string.concat("K", suit);
        }
    }

    function shuffle(Card[] memory pack) internal view {
        for (uint256 i = 0; i < pack.length; i++) {
            uint256 n = i + uint256(keccak256(abi.encodePacked(block.timestamp))) % (pack.length - i);
            Card memory temp = pack[n];
            pack[n] = pack[i];
            pack[i] = temp;
        }
    }

    function sort(Card[] memory deal) private view {
        for (uint i = 1; i < deal.length; i++){
            for (uint j = 0; j < i; j++) {
                if (uint8(deal[i].rank) > uint8(deal[j].rank)) {
                    Card memory x = deal[i];
                    deal[i] = deal[j];
                    deal[j] = x;
                }
            }
        }
    }

    function getHand(Card[] memory deal) public returns (Hand) {
        sort(deal);
        uint8[] memory rankStats = new uint8[](13);
        uint8[] memory suitStats = new uint8[](4);
        for (uint8 i; i < deal.length; ++i) {
            rankStats[uint8(deal[i].rank)] += 1;
            suitStats[uint8(deal[i].suit)] += 1;
        }
        
        
        string memory rankStatsRepresentation = uint2str(rankStats[0]);
        for (uint8 i = 1; i < rankStats.length; ++i) {
            rankStatsRepresentation = string.concat(rankStatsRepresentation, " ", uint2str(rankStats[i]));
        }
        console.log(rankStatsRepresentation);


        for(uint8 i = uint8(Rank.KING) - 1; i > 0; --i) {
            if (rankStats[i] == 4) {
                return Hand.FOUR_OF_A_KIND;
            }
        }

        for(uint8 i; i < deal.length - 3; ++i) {
            bool plusOne;
            bool plusTwo;
            bool plusThree;
            bool plusFour;
            for (uint8 j = i; j < deal.length; ++j) {
                if (deal[j].suit == deal[i].suit) {
                    if (uint8(deal[j].rank) == uint8(deal[i].rank) + 1) {
                        plusOne = true;
                    }
                    if (uint8(deal[j].rank) == uint8(deal[i].rank) + 2) {
                        plusTwo = true;
                    }
                    if (uint8(deal[j].rank) == uint8(deal[i].rank) + 3) {
                        plusThree = true;
                    }
                    if ((uint8(deal[j].rank) == uint8(deal[i].rank) + 4) || (deal[j].rank == Rank.ACE && deal[i].rank == Rank.TWO)) {
                        plusFour = true;
                    }
                }
            }
            if(plusFour&&plusThree&&plusTwo&&plusOne) {
                return Hand.STRAIGHT_FLUSH;
            }
        }

        for(uint8 i = uint8(Rank.ACE); i > 0; --i) {
            if (rankStats[i - 1] == 3) {
                for(uint8 j = uint8(Rank.ACE); j > 0; --j) {
                    if(i == j) {
                        continue;
                    }
                    if (rankStats[j - 1] == 2) {
                        return Hand.FULL_HOUSE;
                    }
                }
            }
        }


        for(uint8 i = 0; i < uint8(Suit.SPADES); ++i) {
            if (suitStats[i] >= 5) {
                return Hand.FLUSH;
            }
        }

        for(uint8 i; i < rankStats.length - 4; ++i) {
            if(rankStats[i] > 0 && rankStats[i+1] > 0 && rankStats[i+2]>0&&rankStats[i+3]> 0) {
                if (rankStats[i+4]>0 || (i==0 && rankStats[rankStats.length - 1] > 0)) {
                    return Hand.STRAIGHT;
                }
            }
        }
        
        for(uint8 i = uint8(Rank.ACE); i > 0; --i) {
            if (rankStats[i - 1] == 3) {
                return Hand.THREE_OF_A_KIND;
            }
        }
        for(uint8 i = uint8(Rank.ACE); i > 0; --i) {
            if(rankStats[i] == 2) {
                for(uint8 j = uint8(Rank.ACE); j > 0; --j) {
                    if(i == j) {
                        continue;
                    }
                    if (rankStats[j] == 2) {
                        return Hand.TWO_PAIRS;
                    }
                }
            }
        }
        for(uint8 i = uint8(Rank.ACE); i > 0; --i) {
            if (rankStats[i - 1] == 2) {
                return Hand.PAIR;
            }
        }
        return Hand.HIGH;
    }

    function dealCards() public {
        Card[] memory pack = new Card[](52);
        for (uint8 i; i <= uint8(Rank.ACE); ++i) {
            for (uint8 j; j <= uint8(Suit.SPADES); ++j) {
                pack[j * 13 + i] = Card(Rank(i), Suit(j));
            }
        }
        shuffle(pack);
        Card[] memory deal = new Card[](DEAL_SIZE);
        for (uint8 i; i < DEAL_SIZE; ++i) {
            deal[i] = pack[i];
        }
        string memory dealRepresentation = getCardRepresentation(deal[0]);
        for (uint8 i = 1; i < deal.length; ++i) {
            dealRepresentation = string.concat(dealRepresentation, " ", getCardRepresentation(deal[i]));
        }
        console.log(dealRepresentation);
        console.log(getHandRepresentation(getHand(deal)));
    }
}
