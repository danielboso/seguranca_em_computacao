pragma solidity ^0.4.24;

contract DelayedPayment {

    address schedulera = 0xE54d323F9Ef17C1F0dEdE47eCC86A9718fE5ea34;
    address scheduler = 0x6C8f2A135f6ed072DE4503Bd7C4999a1a17F824B;

    uint constant TAX_30_DAYS = 10 wei;

    /*  Tempo médio de cada bloco é de 14 segundos
     *  1 dia tem 3600 segundos / 14 segundos
     *  Então temos que são gerados aproximadamente 258 blocos por dia
     */
    uint constant blocksADay = 258;

    uint blockTarget;
    address toAddress;
    address public scheduledTransaction;

    function delayedPayment(
        uint _blockTarget,
        address _toAddress) public payable {

        blockTarget = _blockTarget;
        toAddress = _toAddress;
        scheduledTransaction = scheduler.schedule.value(1 wei)(
            this,
            "",
            [   200000,             // The amount of gas to be sent with the transaction.
                0,                  // The amount of wei to be sent.
                255,                // The size of the execution window.
                blockTarget,        // The start of the execution window.
                20000000000 wei,    // The gasprice for the transaction (aka 20 gwei)
                20000000000 wei,    // The fee included in the transaction.
                20000000000 wei,         // The bounty that awards the executor of the transaction.
                30000000000 wei]);     // The required amount of wei the claimer must send as deposit.
    }

    function () public payable {
        if (msg.value > 0) { //this handles recieving remaining funds sent while scheduling (0.1 ether)
            return;
        } else if (address(this).balance > 0) {
            payout();
        } else {
            revert();
        }
    }

    function payout() public returns (bool) {
        require(block.number >= blockTarget);
        toAddress.transfer(address(this).balance);
        return true;
    }

}
