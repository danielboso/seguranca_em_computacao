pragma solidity ^0.4.11;

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
contract TemporalAnchorage {

    uint private lastIndex;                 /* Índice do último bloco.              */
    uint private averageTransactionTime;    /* Tempo médio de cada transação (s).   */

    constructor() public {
        lastIndex = 0;
        averageTransactionTime = 30;
    }

    function currentTime() public view returns (uint) {
        uint ct = lastIndex * averageTransactionTime;
        return ct;
    }
}

/// Medição do tempo decorrido entre duas transações


/// Medição do tempo decorrido desde uma dada transação

/// ------------------------------------------------------
///   Controle de estacionamento
/// ------------------------------------------------------

///   Registro da entrada e saída de veículos


///   Medição do tempo de estadia do veículo no estacionamento


///   Cobrança extra por exeder o horário limite