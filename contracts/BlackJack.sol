// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.7.0;

contract BlackJack {
    struct Player {
        address payable name; //имя игрока
        uint256 cashAmmount; //колличество денег
        bool hasCards;
        bool authorized;
        uint32 sumPlayer;
        Card[] cards;
    }
    struct Card {
        string name; //название карты
        uint8 rate; //насколько карта сильна
    }

    struct Dealer {
        address payable name; //имя дилера
        uint256 cashAmmount; //колличество денег
        uint32 sumDealer; //сумма очков дилера
        Card[] cards;
    }

    Player player;
    Dealer dealer;
    uint32 public lastValue;
    Card[] public deck; //колода карт

    //address public dealer; //адрес дилера
    bool public standP; // сделал ли стэнд игрок
    bool public standD; // сделал ли стэнд дилер
    bool public push;
    address public winner; //адрес победителя
    uint256 public value;

    uint32 public ammountOfCards;
    mapping(address => Player) public players; // все адреса являются игроками

    event Deposit(address indexed _from, uint256 _value);
    event Get_Cards(address indexed _from, uint256 last_card, uint256 sum);
    event Compare(
        address indexed d,
        uint256 sumd,
        address indexed p,
        uint256 sump
    );
    enum State {Start, Bet, Stop, Result}
    State state;
    modifier inState(State _state) {
        require(state == _state, "Invalid state.");
        _;
    }
    modifier points_player() {
        check_cards();
        require(sum_p <= 21, "You've lost.Total points over 21");
        _;
    } // проверка суммы баллов игрока

    modifier points_dealer() {
        check_cards();
        require(sum_p <= 17, "Total points over 17");
        _;
    } //? провера суммы баллов дилера
    modifier only_dealer() {
        require(msg.sender == dealer.name, "Only dealer can call this.");
        _;
    }

    modifier only_player() {
        require(msg.sender == player.name, "Only player can call this.");
        _;
    }

    function choose_dealer() public payable {
        //state=State.Start;
        dealer.name = msg.sender;
        dealer.cashAmmount = msg.value;
    } // получение адреса дилера

    function choose_player() public payable //inState(State.Start)
    {
        player.cashAmmount = msg.value;
        player.name = msg.sender;
        emit Deposit(msg.sender, msg.value);
    } // получение адреса игрока

    function add_money_player()
        public
        payable
        //points_player
        only_player
    //inState(State.Bet)
    {
        player.cashAmmount += msg.value;
    } // увеличение ставки

    function add_money_dealer()
        public
        payable
        //points_dealer
        only_dealer
    //inState(State.Bet)
    {
        dealer.cashAmmount += msg.value;
        require(
            (player.cashAmmount) == dealer.cashAmmount,
            "Rates must be the same."
        );
    } // увеличение ставки

    // function authorize(address player, uint32 chips) public dealerOnly {
    //     //авторизуем
    //     players[player].playerAddress = player;
    //     players[player].authorized = true;
    //     players[player].hasCards = false;
    //     players[player].sumPlayer = 0;
    //     players[player].chipsAmmount = chips;
    // }

    function proccessCard(address player, uint256 card) private {
        players[player].cards.push(deck[card]);
        players[player].sumPlayer += deck[card].rate;
        deck[card] = deck[ammountOfCards - 1];
        delete deck[ammountOfCards - 1];
        ammountOfCards--;
    }

    function giveCards() public dealerOnly {
        //Раздать карты
        require(!player.hasCards, "The player already has cards.");
        require(deck.length != 0, "No more cards in the deck!");
        //Здесь реализуем раздачу карт

        //если дилер выдает сам себе карту
        uint256 card = rand();
        dealer.cards.push(deck[card]);
        dealer.sumDealer += deck[card].rate;
        deck[card] = deck[ammountOfCards - 1];
        delete deck[ammountOfCards - 1];
        ammountOfCards--;

        // если он выдает карту игроку
        uint256 card1 = rand();
        uint256 card2 = rand();
        giveToPlayer(player, card1);
        giveToPlayer(player, card2);

        player.hasCards = true;
    }

    function hit() public {
        //взять еще одну карту
        if (msg.sender == dealer) {
            require(
                dealer.sumDealer < 17,
                "Dealer can't hit if he has more than 16 points"
            );
            uint256 cardDealer = rand();
            dealer.cards.push(deck[cardDealer]);
            dealer.sumDealer += deck[cardDealer].rate;
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

    function checkScore() public {
        require(
            player.hasCards,
            "Player doesn't have cards" // у игрока нет карт
        );
        require(
            dealer.hasCards,
            "Dealer doesn't have cards" // у игрока нет карт
        );
        player.sumPlayer = 0;

        for (uint32 i = 0; i < player.cards.length; i++) {
            player.sumPlayer += player.cards[i].rate;
        }
        for (uint32 i = 0; i < dealer.cards.length; i++) {
            dealer.sumPlayer += dealer.cards[i].rate;
        }
    } // подсчет суммы баллов

    function checkWinner() public {
        require(standP == true && standD == true, "Not all made 'stand");
        if ((player.sumPlayer > dealer.sumDealer) && (player.sumPlayer <= 21)) {
            player.name.transfer(dealer.cashAmmount + player.cashAmmount);
            winner = player.name;
        } else if (player.sumPlayer == dealer.sumDealer) {
            push = true;
            winner = address(0);
            dealer.name.transfer(dealer.cashAmmount);
            player.name.transfer(player.cashAmmount);
        } else {
            dealer.name.transfer(dealer.cashAmmount + player.cashAmmount);
            winner = dealer;
        }
    }

    function fillDeck() private {
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

    constructor() public {
        dealer = msg.sender;
        fillDeck();
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
