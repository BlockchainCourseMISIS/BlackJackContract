// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract BlackJack {
    struct Player {
        bytes32 name; //имя игрока
        uint256 cashAmmount; //колличество денег
        uint256 chipsAmmount; //количество фишек
        address delegate; // дилер, с которым он играет
        bool hasCards;
        Card[] cards;
    }
    struct Card {
        bytes32 name; //название карты
        uint256 rate; //насколько карта сильна
    }
    struct Dealer {
        bytes32 name; //имя дилера
        Card[] cards;
    }
    Card[] public deck; //колода карт
    address public dealer;
    mapping(address => Player) public players; // все адреса являются игроками

    function giveCards(address player) public {
        //Раздать карты
        require(msg.sender == dealer, "Only dealer can give cards.");
        require(!players[player].hasCards, "The player already has cards.");
        //Здесь реализуем раздачу карт

        uint card1 = random();
        uint card2 = random();
        while(card1 == card2){
            card2 = random();
        }

        players[player].cards.push(deck[card1]);
        players[player].cards.push(deck[card2]);

    }

    function random() private view returns (uint) {
    uint randomHash = uint(keccak256(block.difficulty));
    return randomHash % 12;
}  

    constructor(uint256 amountOfDecks) public {
        require(
            amountOfDecks < 9,
            "You can't create more than 8 decks" // нельзя использовать больше 8 колод (по правилам)
        );
        //в колоде 52 карты, заполняем их
        for (uint256 k = 0; k < amountOfDecks; k++) {
            for (uint256 i = 0; i < 4; i++) {
                //заполняем карты от 2 до 10
                for (uint256 j = 2; j <= 10; j++) {
                    deck.push(Card({name: bytes32(j), rate: j}));
                }
                deck.push(
                    Card({
                        name: "Jack", //валет
                        rate: 10
                    })
                );
                deck.push(
                    Card({
                        name: "Lady", //дама
                        rate: 10
                    })
                );
                deck.push(
                    Card({
                        name: "King", //король
                        rate: 10
                    })
                );
                deck.push(
                    Card({
                        name: "Ace", //туз
                        rate: 11
                    })
                );
            }
        }
    }
}
