pragma solidity ^0.4.24;

import "../ethereum-alarm-clock/contracts/Scheduler/BaseScheduler.sol";

contract DelayedPayment {

    /*  Inclusão de taxa caso o cliente queira atrasar seu pagamento em 30 dias.
     *  A constante abaixo informa o valor da taxa a ser cobrada a mais.
     */
    address baseScheduler;

    function delayedPayment(address toAddress, uint[7] args) {
        baseScheduler = BaseScheduler.schedule(toAddress,"",
      [ args[0],  // quantidade de gas que será enviada junto com a transação
        args[1],  // quantidade de wei a ser enviado
        args[2],  // o tamanho da janela de execução. Indica quantos blocos,
                  // depois do bloco alvo que permitirá a execução da transação,
                  // que a transação ainda poderá ser executada.
        args[3],  // indica o primeiro bloco onde a transação já poderá
                  // ser executada
        args[4],  // o preço do gas para a transação
        args[5],  // taxa inclusa na transação
        args[6],  // a recompensa para o quem irá executar a transação
        args[7] ]); // a quantidade necerrária de wei para o reinvindicador
                    // enviar como depósito
    }

    function () public payable {
        if (msg.value > 0) {
            return;
        } else if (address(this).balance > 0) {
            payout();
        } else {
            revert();
        }
    }

    /*      Efetua o pagamento quando o número do bloco for maior ou igual ao
     *  número de bloco alvo.
     */
    function payout() public returns (bool) {
        require(block.number >= blockTarget);
        toAddress.transfer(address(this).balance);
        return true;
    }
}
