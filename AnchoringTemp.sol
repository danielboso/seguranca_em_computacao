pragma solidity ^0.4.24;

/// Ancoramento temporal
contract AnchoringTemp {

    address scheduler = 0xE54d323F9Ef17C1F0dEdE47eCC86A9718fE5ea34;

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

    function blockTarget(uint rangeBlock) public returns (uint) {
        return block.number + rangeBlock;
    }

    function paymentWait30Days(
        address toAddress,
        bytes callData,
        uint8 windowSize,
        uint callGas,
        uint callValue) {
            uint[3] memory uintArgs = [
                callGas,   // quantidade de gás que será enviada com a transação
                callValue, // quantidade de ether em wei que será enviada para o
                           // destinatário
                blockTarget(30*blocksADay)]; // O primeiro bloco onde a transação
                                              // poderá ser executada.
            /*scheduler.scheduleCall(
                toAddress,
                bytes4(keccak256("payAfter30Days(toAddress, callValue)")),
                windowSize,
                uintArgs); */
            scheduler.schedule(
                toAddress,
                callData,
                uintArgs);
    }

    function payAfter30Days(address toAddress, uint callValue) {

        toAddress.call.gas(2500000).value(callValue);
    }
}
