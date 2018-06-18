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

  constructor(uint price) public {
    parking = msg.sender;
    priceForMinute = price;
  }

  // Registro do horário de entrada do veículo
  function registerClient(address client) public {
    if (msg.sender != parking) return;
    clients[client].beginTimeParked = now;
  }

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


///   Medição do tempo de estadia do veículo no estacionamento


///   Cobrança extra por exeder o horário limite
