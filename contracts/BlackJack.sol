// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract BlackJack {
    struct Player {
        address playerAddress; //имя игрока
        uint32 chipsAmmount; //количество фишек
        bool hasCards;
        bool authorized;
        uint32 sumPlayer;
        Card[] cards;
    }
    struct Card {
        string name; //название карты
        uint8 rate; //насколько карта сильна
    }
    uint32 public lastValue;
    Card[] public deck; //колода карт
    Card[] public dealerCards; //карты дилера
    address public dealer; //адрес дилера
    bool public standP; // сделал ли стэнд игрок
    bool public standD; // сделал ли стэнд дилер
    bool public push;
    address public winner;

    uint256 public value;

    uint32 public ammountOfCards;
    uint256 public sumDealer; // сумма очков
    mapping(address => Player) public players; // все адреса являются игроками

    // function init() public payable {
    //     dealer = payable(msg.sender);
    //     value = msg.value;
    // }

    function authorize(address player, uint32 chips) public dealerOnly {
        //авторизуем
        players[player].playerAddress = player;
        players[player].authorized = true;
        players[player].hasCards = false;
        players[player].sumPlayer = 0;
        players[player].chipsAmmount = chips;
    }

    function proccessCard(address player, uint256 card) private {
        players[player].cards.push(deck[card]);
        players[player].sumPlayer += deck[card].rate;
        deck[card] = deck[ammountOfCards - 1];
        delete deck[ammountOfCards - 1];
        ammountOfCards--;
    }

    function giveCards(address player) public dealerOnly {
        //Раздать карты
        require(!players[player].hasCards, "The player already has cards.");
        require(deck.length != 0, "No more cards in the deck!");
        //Здесь реализуем раздачу карт
        if (player == dealer) {
            //если дилер выдает сам себе карту
            uint256 card = rand();
            dealerCards.push(deck[card]);
            sumDealer += deck[card].rate;

            deck[card] = deck[ammountOfCards - 1];
            delete deck[ammountOfCards - 1];
            ammountOfCards--;
        } else {
            // если он выдает карту игроку
            uint256 card1 = rand();
            uint256 card2 = rand();
            proccessCard(player, card1);
            proccessCard(player, card2);
        }

        players[player].hasCards = true;
    }

    function hit() public {
        //взять еще одну карту
        if (msg.sender == dealer) {
            require(
                sumDealer < 17,
                "Dealer can't hit if he has more than 16 points"
            );
            uint256 cardDealer = rand();
            dealerCards.push(deck[cardDealer]);
            sumDealer += deck[cardDealer].rate;
            deck[cardDealer] = deck[ammountOfCards - 1];
            delete deck[ammountOfCards - 1];
            ammountOfCards--;
        } else {
            require(
                players[msg.sender].sumPlayer < 22,
                "Player can't hit if he has more than 21 points"
            );
            uint256 cardPlayer = rand();
            proccessCard(msg.sender, cardPlayer);
        }
    }

    function stand() public {
        // завершить набор карт

        if (msg.sender == dealer) {
            standD = true;
        } else {
            standP = true;
        }
    }

    function checkScore(address player) public returns (uint32) {
        require(
            players[player].hasCards,
            "Player doesn't have cards" // у игрока нет карт
        );
        // for (uint8 i = 0; i < players[player].cards.length; i++) {
        //     lastValue += players[player].cards[i].rate;
        // }
        lastValue = players[player].sumPlayer;
        return lastValue;
    }

    function checkWinner() public {
        require(standP == true && standD == true, "Not all made 'stand");
        if (
            (players[msg.sender].sumPlayer > sumDealer) &&
            (players[msg.sender].sumPlayer <= 21)
        ) {
            winner = msg.sender;
        } else if (players[msg.sender].sumPlayer == sumDealer) {
            push = true;
            winner = address(0);
        } else {
            winner = dealer;
        }
    }

    constructor() public {
        dealer = msg.sender;
        ammountOfCards = 52;
        //в колоде 52 карты, заполняем их
        for (uint8 i = 0; i < 4; i++) {
            //заполняем карты от 2 до 10
            for (uint8 j = 2; j <= 10; j++) {
                deck.push(Card({name: uint2str(j), rate: j}));
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

    //Вспомогательные функции

    modifier dealerOnly() {
        require(msg.sender == dealer, "Only dealer can do this.");
        _;
    }

    // Intializing the state variable
    uint256 randNonce = 0;

    // Defining a function to generate
    // a random number
    function rand() internal returns (uint256) {
        // increase nonce
        randNonce++;
        return
            uint256(keccak256(abi.encodePacked(msg.sender, randNonce))) %
            ammountOfCards;
    }

    function uint2str(uint8 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
