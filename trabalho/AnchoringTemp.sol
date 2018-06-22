pragma solidity ^0.4.24;

import "DelayedPayment.sol";

/// Ancoramento temporal
contract AnchoringTemp {

    /*  Tempo médio de cada bloco é de 14 segundos
     *  1 dia tem 3600 segundos / 14 segundos
     *  Então temos que são gerados aproximadamente 258 blocos por dia
     */
    uint constant blocksADay = 258;

    /*      Método responsável por calcular o intervalo de tempo baseado no bloco
     *  atual. O parãmetro startTime é o tempo do bloco que será calculado o
     *  o intervalo de tempo.
     */
    function intervalTime(uint256 startTime) public view returns(uint256) {
        return block.timestamp - startTime;
    }

    /*
    *  Medição do tempo decorrido desde uma dada transação
    *       Procuramos o block quem contém a transação que estamos procurando saber
    *   e verificamos o timestamp do bloco. Subtraímos o now pelo timestamp do
    *   bloco e temos o tempo em segundos desde esta transação.
    */

    /*      Função que recebe como argumento a distância em blocos em relação ao
     *  bloco atual. A função retorna o número do bloco acrescido do deslocamento
     *  de bloco.
     */
    function blockTarget(uint rangeBlock) public returns (uint) {
        return block.number + rangeBlock;
    }


    function shcedulePaymentNDays(
        address toAddress,   // endereço destino
        uint callGas,        // quantidade de gas que será enviada junto com a transação
        uint value,          // quantidade de wei a ser enviado
        uint windowSize,     // o tamanho da janela de execução. Indica quantos blocos,
                             // depois do bloco alvo que permitirá a execução da transação,
                             // que a transação ainda poderá ser executada.
        uint delayedDays,    // indica o primeiro bloco onde a transação já poderá
                             // ser executada
        uint gasPrice,       // o preço do gas para a transação
        uint fee,            // taxa inclusa na transação
        uint award,          // a recompensa para o quem irá executar a transação
        uint requiredDeposit // a quantidade necerrária de wei para o reinvindicador
                             // enviar como depósito
        ) {
            uint targetBlock = block.number + (delayedDays * blocksADay);
            uint[7] memory args = [
                callGas,
                value,
                255,
                targetBlock,
                gasPrice,
                fee,
                award,
                requiredDeposit
            ];
            DelayedPayment().delayedPayment(toAddress, args);
    }
}
