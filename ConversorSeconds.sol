pragma solidity ^0.4.24;

/// Conversor de segundos para outras unidades
contract ConversorSeconds {

  uint256 _timeInSeconds;

  constructor(uint256 timeInSeconds) public {
    _timeInSeconds = timeInSeconds;
  }

  function secondsToHours(uint256 secondsParked) public pure returns (uint256) {
    return secondsParked / 3600;
  }

  function remainingMinutes(uint256 secondsParked) public pure returns (uint256)  {
    return (secondsParked % 3600) / 60;
  }
}
