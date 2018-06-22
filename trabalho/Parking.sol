pragma solidity ^0.4.24;

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
