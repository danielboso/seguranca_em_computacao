pragma solidity ^0.4.24;

/// Ancoramento temporal
contract AnchoringTemp {

  /// Tempo desde uma certa transação
  function intervalTime(uint256 startTime) public view returns(uint256) {
    return block.timestamp - startTime;
  }

  /*
   *  Agendar uma transação
   *    block.number retorna o número do último bloco minerado
   *    Podemos agendar uma transação usando
   */

  /*
   *  Medição do tempo decorrido desde uma dada transação
   *    Procuramos o block quem contém a transação que estamos procurando saber
   *  e verificamos o timestamp do bloco. Subtraímos o now pelo timestamp do
   *  bloco e temos o tempo em segundos desde esta transação.
   */

}
