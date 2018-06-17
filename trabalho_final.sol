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
contract AnchoringTemp {

    function timeLastBlock() {
        return block.timestamp;
    }
}

/// Medição do tempo decorrido entre duas transações
contract ElapsedTimeTwoTransactions {

}

/// Tempo Atual
contract TimeNow {

}

/// Medição do tempo decorrido desde uma dada transação
contract ElapsedTimeBetweenTransactions {

}

/// ------------------------------------------------------
///   Controle de estacionamento
/// ------------------------------------------------------

///   Registro da entrada e saída de veículos


///   Medição do tempo de estadia do veículo no estacionamento


///   Cobrança extra por exeder o horário limite
