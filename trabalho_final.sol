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

}

/// ------------------------------------------------------
///   Controle de estacionamento
/// ------------------------------------------------------
contract Parking {

  struct Car {
    bool parked;
    uint256 timeIn;
    uint256 timeOut;
    uint256 timeOfParking;
    uint priceToPay;
  }

  uint constant MAX = 6;
  address public parking;

  mapping(address => Car) public clients;
  mapping(address => address) public extras;

  event Parked(address car);
  event Leave(address car);
  event ExtraPayed(address car);

  uint priceForHour = 10;

  // Constructor for the parking
  constructor() public {
    parking = msg.sender;
  }

  function changePrice(uint newPrice) public {
    if (msg.sender != parking) return;
    priceForHour = newPrice;
  }

  function returnPrice() public view returns (uint) {
    return priceForHour;
  }

  // Register of the time that vehicle entry
  function parkCar() public {
      if ( msg.sender == parking || clients[msg.sender].parked == true) return;
      clients[msg.sender].parked = true;
      clients[msg.sender].timeIn = now;
      emit Parked(msg.sender);
  }

  function secondsToHours(uint256 secondsParked) private pure returns (uint256) {
    return secondsParked / 3600;
  }

  function remainingMinutes(uint256 secondsParked) private pure returns (uint256)  {
    return (secondsParked % 3600) / 60;
  }

  function leaveParking() public {
      if ( msg.sender == parking || clients[msg.sender].parked == false) return;

      uint leavingTime = now;

      // 3600 seconds = 1
      // Limit of MAX Hour
      clients[msg.sender].timeOut = leavingTime;
      uint256 timeOfParking = leavingTime - clients[msg.sender].timeIn;
      if(leavingTime < clients[msg.sender].timeIn + (MAX * 3600)){
          clients[msg.sender].parked = false;
          clients[msg.sender].timeOfParking = timeOfParking;
          uint totalToPay = secondsToHours(timeOfParking)*priceForHour +
          remainingMinutes(timeOfParking)*(priceForHour/60);
          msg.sender.call.gas(2500000).value(totalToPay);
          emit Leave(msg.sender);
      }else{
          uint256 extraTime = timeOfParking - (MAX * 3600);
          totalToPay = (MAX * priceForHour) +
          secondsToHours(extraTime)*priceForHour +
          remainingMinutes(extraTime)*(priceForHour/60);
          msg.sender.call.gas(2500000).value(totalToPay);
          emit Leave(msg.sender);
      }
  }
}
///   Registro da entrada e saída de veículos

contract Registro {

    struct car {
        bool parked;
        uint256 time_in;
        uint256 time_out;
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

    function payExtra(uint amount) public {

        if (parking[msg.sender].parked == false) return;

        Extra extra = Extra(extras[msg.sender]);
        bool status = extra.send(controller,amount);
        uint leavingTime = now;

        if(status) {
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
