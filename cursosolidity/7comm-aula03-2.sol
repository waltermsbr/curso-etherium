// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Ownable {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function changeOwner(address _owner) public onlyOwner returns (bool) {
        owner = _owner;
        return true;
    }
}

contract Identificador is Ownable {
    function criarIdentificador(
        string memory _nomeLocador,
        string memory _nomeLocatario
    ) public view onlyOwner returns (bytes32) {
        return keccak256(bytes(string.concat(_nomeLocador, _nomeLocatario)));
    }
}

contract ContratoDeAluguel is Ownable, Identificador {
    Aluguel public aluguel;

    event TrocaDeNomes(string _nomeAnterior, uint8 _tipoPessoa);

    event ReajustarAluguel();

    constructor(
        string memory _nomeLocador,
        string memory _nomeLocatario,
        uint16 _valorAluguel
    ) {
        aluguel.endereco = msg.sender;
        aluguel.identificador = criarIdentificador(
            _nomeLocador,
            _nomeLocatario
        );
        aluguel.nomeLocador = _nomeLocador;
        aluguel.nomeLocatario = _nomeLocatario;
        for (uint8 x = 0; x < 36; x++) {
            aluguel.listaAluguel[x] = _valorAluguel;
        }
        aluguel.status = true;
    }

    struct Aluguel {
        address endereco;
        bytes32 identificador;
        string nomeLocador;
        string nomeLocatario;
        uint16[36] listaAluguel;
        bool status;
    }

    modifier validarMesSolicitado(uint8 _mesAluguel) {
        require(
            _mesAluguel >= 1 && _mesAluguel <= 36,
            "Mes de aluguel nao existe."
        );
        _;
    }

    function recuperarValorAluguel(uint8 _mesAluguel)
        external
        view
        validarMesSolicitado(_mesAluguel)
        returns (uint16 retornaValorAluguel)
    {
        return aluguel.listaAluguel[_mesAluguel - 1];
    }

    function recuperarNomeLocadorNomeLocatario(bytes32 _identificador)
        external
        view
        returns (string memory _nomeLocador, string memory _nomeLocatario)
    {
        if (aluguel.identificador == _identificador) {
            _nomeLocador = aluguel.nomeLocador;
            _nomeLocatario = aluguel.nomeLocatario;
        }
        return (_nomeLocador, _nomeLocatario);
    }

    /**
     * @dev Metodo que altera o nome do locatario (_tipoPessoa = 1) ou o nome do locador (_tipoPessoa = 2)
     * @param _nome Novo nome
     * @param _tipoPessoa Tipo de pessoa conforme acima
     */
    function alterarNome(string memory _nome, uint8 _tipoPessoa)
        external
        returns (bool retorno)
    {
        retorno = false;
        require(bytes(_nome).length != 0, "Informe o novo nome.");
        require(
            _tipoPessoa == 1 || _tipoPessoa == 2,
            "Tipo de pessoa incorreto."
        );
        if (_tipoPessoa == 1) {
            aluguel.nomeLocador = _nome;
            retorno = true;
        } else if (_tipoPessoa == 2) {
            aluguel.nomeLocatario = _nome;
            retorno = true;
        }
        if (retorno) {
            aluguel.identificador = criarIdentificador(
                aluguel.nomeLocador,
                aluguel.nomeLocatario
            );
        }
        emit TrocaDeNomes(_nome, _tipoPessoa);
        return retorno;
    }

    function reajustarAluguel(uint8 _mesInicialReajuste, uint16 _valorReajuste)
        external
        validarMesSolicitado(_mesInicialReajuste)
        returns (uint8 qtdeRegistrosAlterados)
    {
        require(_valorReajuste > 0, "Valor de reajuste maior que 0");
        for (
            uint8 x = _mesInicialReajuste - 1;
            x < aluguel.listaAluguel.length;
            x++
        ) {
            aluguel.listaAluguel[x] += _valorReajuste;
            qtdeRegistrosAlterados++;
        }
        emit ReajustarAluguel();
        return qtdeRegistrosAlterados;
    }

    function listarMesesAluguel() external view returns (uint16[36] memory) {
        return aluguel.listaAluguel;
    }
}

// 0x5BD84bcea822f253954F01b68CCECE05861b1f5b
