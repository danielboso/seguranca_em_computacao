pragma solidity ^0.4.0;

/// ------------------------------------------------------
/// Progresso                                            -
/// ------------------------------------------------------
/// -> Ancoramento Temporal                              -
///     N -> Medição do tempo decorrido                  -
///     S -> Tempo Atual (último bloco)                  -
///     N -> Medição do tempo decorrido desde uma dada   -
///          transação                                   -
///                                                      -
/// -> Controle de Estacionamento                        -
///     N -> Registro da entrada e saída de veículos     -
///     N -> Medição do tempo de estadia do veículo no   -
///          estacionamento                              -
///     N -> Cobrança extra por exceder o horário limite -
/// ------------------------------------------------------

/// ------------------------------------------------------
///   Ancoramento Temporal                               -
/// ------------------------------------------------------
contract AnchoringTemp {
    // Retorna o tempo
    function timeLastBlock() public returns (uint) {
        return block.timestamp;
    }
}

/// Medição do tempo decorrido entre duas transações
contract ElapsedTimeTwoTransactions {

}

/// Tempo Atual
contract TimeNow {

}

/// Medição do tempo decorrido desde uma dada transação
contract ElapsedTimeBetweenTransactions {

}

/// ------------------------------------------------------
///   Controle de estacionamento
/// ------------------------------------------------------
contract Estacionamento {
  struct Cliente {
    uint256 beginTimeParked;
    uint256 finalTimeParked;
    uint256 timeOfParking;
    uint priceToPay;
  }

  address public parking;
  mapping(address => Cliente) public clients;
  uint priceForMinute;

  // Constructor for the parking
  constructor(uint price) public {
    parking = msg.sender;
    priceForMinute = price;
  }

  // Register of the time that vehicle entry
  function registerClient(address client) public {
    if (msg.sender != parking) return;
    clients[client].beginTimeParked = now;
  }

  // Register of the time that vehicle exited
  function registerExitClient(address client) public {
    if (msg.sender != parking) return;
    clients[client].finalTimeParked = now;
  }

  function timeOfParking(address client) public returns (uint){
    if (msg.sender != parking) return;
    clients[client].timeOfParking = clients[client].finalTimeParked - clients[client].beginTimeParked;
  }
}
///   Registro da entrada e saída de veículos

contract Registro {

    struct car {
        bool parked;
        uint time_in;
        uint time_out;
    }

    uint constant MAX = 6;
    address public controller;

    mapping(address => car) public parking;
    mapping(address => address) public extras;

    event Parked(address car);
    event Leave(address car);
    event ExtraPayed(address car);

    constructor() public {
        controller = msg.sender;
    }

    function parkCar() public {
        if ( msg.sender == controller || parking[msg.sender].parked == true) return;
        parking[msg.sender].parked = true;
        parking[msg.sender].time_in = now;
        emit Parked(msg.sender);
    }

    function leaveParking() public {
        if ( msg.sender == controller || parking[msg.sender].parked == false) return;

        uint leavingTime = now;

        if(leavingTime < parking[msg.sender].time_in + MAX){
            parking[msg.sender].parked = false;
            parking[msg.sender].time_out = leavingTime;
            emit Leave(msg.sender);
        }else{
            extras[msg.sender] = new Extra(msg.sender);
        }
    }

    function payExtra(uint amount)public {

        if (parking[msg.sender].parked == false) return;

        Extra extra = Extra(extras[msg.sender]);
        bool statu = extra.send(controller,amount);
        uint leavingTime = now;

        if(statu){
            parking[msg.sender].parked = false;
            parking[msg.sender].time_out = leavingTime;
            emit ExtraPayed(msg.sender);
        }
    }
}

///   Medição do tempo de estadia do veículo no estacionamento

///   Cobrança extra por exeder o horário limite

contract Extra {

    uint256 constant AMOUNT = 6 * now;

    address public _owner;
    mapping (address => uint) public balances;

    event Sent(address from, address to, uint amount);

    constructor(address owner) public {
        _owner = owner;
    }

    function send(address receiver, uint amount) public returns (bool){
        if(msg.sender != _owner || amount < AMOUNT || balances[msg.sender] < amount) return false;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
        return true;
    }
}
