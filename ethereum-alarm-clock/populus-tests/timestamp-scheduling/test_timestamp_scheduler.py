import pytest


@pytest.fixture()
def scheduler(chain, web3, request_factory):
    timestamp_scheduler = chain.get_contract('TimestampScheduler', deploy_args=[
        request_factory.address,
    ])
    chain_code = web3.eth.getCode(timestamp_scheduler.address)
    assert len(chain_code) > 10

    assert request_factory.address == timestamp_scheduler.call().factoryAddress()

    return timestamp_scheduler


MINUTE = 60


def test_timestamp_scheduling_with_full_args(chain,
                                             web3,
                                             denoms,
                                             txn_recorder,
                                             scheduler,
                                             request_factory,
                                             request_tracker,
                                             RequestData,
                                             evm,
                                             set_timestamp,
                                             get_txn_request):
    print("Now Factory", request_factory.address)
    window_start = web3.eth.getBlock('latest')['timestamp'] + 10 * MINUTE
    schedule_txn_hash = scheduler.transact({
        'value': 10 * denoms.ether,
    }).scheduleTransaction(
        txn_recorder.address,
        'this-is-the-call-data',
        [
            1212121,  # callGas
            123454321,  # callValue
            98765,  # donation
            80008,  # payment
            123,  # requiredStackDepth
            55 * MINUTE,  # windowSize
            window_start,  # windowStart
        ],
    )
    schedule_txn_receipt = web3.eth.getTransactionReceipt(schedule_txn_hash)

    assert schedule_txn_receipt['gasUsed'] < 1300000

    txn_request = get_txn_request(schedule_txn_hash)
    request_data = RequestData.from_contract(txn_request)

    assert request_data.txnData.toAddress == txn_recorder.address
    assert request_data.txnData.callData == 'this-is-the-call-data'
    assert request_data.schedule.windowSize == 55 * MINUTE
    assert request_data.txnData.callGas == 1212121
    assert request_data.paymentData.donation == 98765
    assert request_data.paymentData.payment == 80008
    assert request_data.txnData.requiredStackDepth == 123
    assert request_data.schedule.windowStart == window_start


def test_timestamp_scheduling_with_simplified_args(chain,
                                                   web3,
                                                   denoms,
                                                   txn_recorder,
                                                   scheduler,
                                                   RequestData,
                                                   get_txn_request):
    window_start = web3.eth.getBlock('latest')['timestamp'] + 6 * MINUTE
    schedule_txn_hash = scheduler.transact({
        'value': 10 * denoms.ether,
    }).scheduleTransaction(
        txn_recorder.address,
        'this-is-the-call-data',
        [
            1212121,  # callGas
            123454321,  # callValue
            55 * MINUTE,  # windowSize
            window_start,  # windowStart
        ],
    )
    web3.eth.getTransactionReceipt(schedule_txn_hash)

    txn_request = get_txn_request(schedule_txn_hash)
    request_data = RequestData.from_contract(txn_request)

    assert request_data.txnData.toAddress == txn_recorder.address
    assert request_data.txnData.callData == 'this-is-the-call-data'
    assert request_data.schedule.windowSize == 55 * MINUTE
    assert request_data.txnData.callGas == 1212121
    assert request_data.schedule.windowStart == window_start


def test_invalid_schedule_returns_ether(chain,
                                        web3,
                                        denoms,
                                        txn_recorder,
                                        scheduler,
                                        RequestData,
                                        get_txn_request):
    latest_block = web3.eth.getBlock('latest')
    window_start = latest_block['timestamp'] + 6 * MINUTE

    before_balance = web3.eth.getBalance(web3.eth.accounts[1])

    schedule_txn_hash = scheduler.transact({
        'value': 10 * denoms.ether,
        'from': web3.eth.accounts[1],
    }).scheduleTransaction(
        txn_recorder.address,
        'this-is-the-call-data',
        [
            latest_block['gasLimit'],  # callGas - too high a value.
            123454321,  # callValue
            55 * MINUTE,  # windowSize
            window_start,  # windowStart
        ],
    )
    schedule_txn_receipt = web3.eth.getTransactionReceipt(schedule_txn_hash)

    after_balance = web3.eth.getBalance(web3.eth.accounts[1])
    assert before_balance - after_balance <= denoms.ether
    assert before_balance - after_balance == schedule_txn_receipt['gasUsed'] * web3.eth.gasPrice

    with pytest.raises(AssertionError):
        get_txn_request(schedule_txn_hash)
