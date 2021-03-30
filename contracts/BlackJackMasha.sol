// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.7.0;

contract BlackJack {
    struct Player {
        address payable name; //имя игрока
        uint256 cashAmmount; //колличество денег
        address delegate; // дилер, с которым он играет
        bool hasCards;
        Card[] cards;
    }
    struct Card {
        bytes32 name; //название карты
        uint256 rate; //насколько карта сильна
    }
    struct Dealer {
        address payable name; //имя дилера
        uint256 cashAmmount; //колличество денег
        Card[] cards;
    }
    Player player;
    Dealer  dealer;
    Card[] public deck; //колода карт
    event Deposit(address indexed  _from,  uint _value);
    event Get_Cards(address indexed  _from,  uint last_card, uint sum);
    event Compare(address indexed  d, uint sumd, address indexed  p,  uint sump);
    enum State {Start, Bet, Stop , Result}
    State state;
    modifier inState(State _state) {
        require(
            state == _state,
            "Invalid state."
        );
        _;
    }
    modifier points_player() {
        check_cards();
        require(
            sum_p<=21,
            "You've lost.Total points over 21"
        );
        _;
    }// проверка суммы баллов игрока 

    modifier points_dealer() {
        check_cards();
        require(
            sum_p<=17,
            "Total points over 17"
        );
        _;
    }//? провера суммы баллов дилера

    modifier only_dealer() {
        require(
            msg.sender == dealer.name,
            "Only dealer can call this."
        );
        _;
    }
    
    modifier only_player() {
        require(
            msg.sender == player.name,
            "Only player can call this."
        );
        _;
    }   
    function not_enough_cash()      
     public
    {
        player.name.transfer(player.cashAmmount);
        dealer.name.transfer(dealer.cashAmmount);
    }

    function choose_dealer()         
       public
       payable
       {
          //state=State.Start;
          dealer.name = msg.sender;
          dealer.cashAmmount = msg.value;
       }// получение адреса дилера

    function choose_player()     
      public 
      //inState(State.Start)
      payable
      {
        player.cashAmmount = msg.value;
        player.name = msg.sender;
        emit Deposit(msg.sender,msg.value );
       } // получение адреса игрока

    function add_money_player()     
      public 
      //points_player
      only_player
     //inState(State.Bet)
      payable
    {
     player.cashAmmount += msg.value;  
    } // увеличение ставки

    function add_money_dealer()     
      public 
      //points_dealer
      only_dealer
     //inState(State.Bet)
      payable
    {
     dealer.cashAmmount += msg.value;  
    } // увеличение ставки


    uint256 public sum_p=5;
    uint256 public sum_d=5;

    function check_cards()
    public
    {
        for(uint256 i=0; i<player.cards.length; i++){
            sum_p=0;
            sum_p+=player.cards[i].rate;
        }
        for(uint256 i=0; i<dealer.cards.length; i++){
            sum_d=0;
            sum_d+=dealer.cards[i].rate;
        }
    }// подсчет суммы баллов
    
    function result()
    //inState(State.Result)
   // only_dealer
    public
      {
        check_cards();
        if((sum_d<=21)&&(sum_d<=21)){
            if(sum_d<sum_p){
                 player.name.transfer(dealer.cashAmmount+player.cashAmmount);
            }
           if(sum_d>sum_p){

                 dealer.name.transfer(dealer.cashAmmount+player.cashAmmount);
            }
            if(sum_d==sum_p){
                   dealer.name.transfer(dealer.cashAmmount);
                   player.name.transfer(player.cashAmmount);
            }
        } 
      } // оценивание баллов 

    // function giveCards(address player) public {
    //     //Раздать карты
    //     require(msg.sender == dealer.name, "Only dealer can give cards.");
    //     require(!players[player].hasCards, "The player already has cards.");
    //     //Здесь реализуем раздачу карт

    //     uint card1 = random();
    //     uint card2 = random();
    //     while(card1 == card2){
    //         card2 = random();
    //     }

    //     players[player].cards.push(deck[card1]);
    //     players[player].cards.push(deck[card2]);

    // }
    

    // function checkScore(Player memory player) public {
    //     require(
    //         player.hasCards,
    //         "Player doesn't have cards" // у игрока нет карт
    //     );
    //     uint256 sumPlayer = 0;
    //     for (uint256 i = 0; i < player.cards.length; i++) {
    //         sumPlayer += player.cards[i].rate;
    //     }
    // }

    // function random() private view returns (uint) {
    // //uint randomHash = uint(keccak256(block.difficulty));
    // //return randomHash % 12;
    // }


    // constructor(uint256 amountOfDecks) public {
    //     require(
    //         amountOfDecks < 9,
    //         "You can't create more than 8 decks" // нельзя использовать больше 8 колод (по правилам)
    //     );
    //     //в колоде 52 карты, заполняем их
    //     for (uint256 k = 0; k < amountOfDecks; k++) {
    //         for (uint256 i = 0; i < 4; i++) {
    //             //заполняем карты от 2 до 10
    //             for (uint256 j = 2; j <= 10; j++) {
    //                 deck.push(Card({name: bytes32(j), rate: j}));
    //             }
    //             deck.push(
    //                 Card({
    //                     name: "Jack", //валет
    //                     rate: 10
    //                 })
    //             );
    //             deck.push(
    //                 Card({
    //                     name: "Lady", //дама
    //                     rate: 10
    //                 })
    //             );
    //             deck.push(
    //                 Card({
    //                     name: "King", //король
    //                     rate: 10
    //                 })
    //             );
    //             deck.push(
    //                 Card({
    //                     name: "Ace", //туз
    //                     rate: 11
    //                 })
    //             );
    //         }
    //     }
    // }
}
