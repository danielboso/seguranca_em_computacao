pragma solidity ^0.4.24;

// Estacionamento. Um estacionamento usando SmartContract
contract Parking {

  struct Car {
    bool parked;
    uint256 timeIn;
    uint256 timeOut;
    uint256 timeOfParking;
    uint priceToPay;
  }

  // Limite o tempo em que um veículo pode permanecer no estacionamento
  uint constant MAX = 6;
  // Endereço do estacionamento
  address public parking;

  mapping(address => Car) public clients;
  mapping(address => address) public extras;

  event Parked(address car);
  event Leave(address car);
  event ExtraPayed(address car);

  // Preço cobrado por hora pelo uso do estacionamento
  uint priceForHour = 10;

  constructor() public {
    parking = msg.sender;
  }

  // Método para mudar o preço por hora pelo uso do estacionamento
  function changePrice(uint newPrice) public {
    if (msg.sender != parking) return;
    priceForHour = newPrice;
  }

  // Método para consulta do preço por hora pelo uso do estacionamento
  function returnPrice() public view returns (uint) {
    return priceForHour;
  }

  // Registra a entrada do veículo no estacionamento
  function parkCar() public {
      if ( msg.sender == parking || clients[msg.sender].parked == true) return;
      clients[msg.sender].parked = true;
      clients[msg.sender].timeIn = now;
      emit Parked(msg.sender);
  }
  // Converte segundos para horas. Pois o tempo é medido em segundos
  function secondsToHours(uint256 secondsParked) private pure returns (uint256) {
    return secondsParked / 3600;
  }
  // Converte segundos restantes da hora por minutos
  function remainingMinutes(uint256 secondsParked) private pure returns (uint256)  {
    return (secondsParked % 3600) / 60;
  }

  /*    Registra a saída do veículo. Caso o veículo ultrapasse o tempo máximo
   *    permitido, o cliente irá pagar uma multa por isso.
   */
  function leaveParking() public {
      if ( msg.sender == parking || clients[msg.sender].parked == false) return;

      uint leavingTime = now;

      // 3600 seconds = 1
      // Limit of MAX Hour
      clients[msg.sender].timeOut = leavingTime;
      ///   Medição do tempo de estadia do veículo no estacionamento
      uint256 timeOfParking = leavingTime - clients[msg.sender].timeIn;
      if(leavingTime < clients[msg.sender].timeIn + (MAX * 3600)){
          clients[msg.sender].parked = false;
          clients[msg.sender].timeOfParking = timeOfParking;
          uint totalToPay = secondsToHours(timeOfParking)*priceForHour +
          remainingMinutes(timeOfParking)*(priceForHour/60);
          msg.sender.call.gas(2500000).value(totalToPay);
          emit Leave(msg.sender);
      }else{
          ///   Cobrança extra por exeder o horário limite
          uint256 extraTime = timeOfParking - (MAX * 3600);
          totalToPay = (MAX * priceForHour) +
          secondsToHours(extraTime)*priceForHour +
          remainingMinutes(extraTime)*(priceForHour/60);
          msg.sender.call.gas(2500000).value(totalToPay);
          emit Leave(msg.sender);
      }
  }
}
