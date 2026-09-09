// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface Suma {
    function suma(uint256 a, uint256 b) external pure returns(uint256 rta);
}

contract Proxy {
    address public owner; // slot0
    address public callee; // slot1
    bytes public resultB;
    uint256 result;

    constructor(address _callee){
        setCalee(_callee);
    }

    function setCalee(address _callee) public {
        callee = _callee;
    }

    // Si quieren que esto funcione para suma() también deben eliminar la función suma, porque sino no entrará alfallback al llamarla
    // Para crear calldatas con el formato ABI facilmente: https://abi.hashex.org/
    fallback() external payable {
        // msg.data => selector + paramentros
        // address.call(caldata) => delegateCall
        bool ok;
        (ok, ) = callee.delegatecall(msg.data);
        if (!ok) revert();
    }
    // Verlo llamado con un call y gráfico de como funciona pueden verlo acá: https://github.com/DigiCris/EducationIT/tree/main/clase3/calls

    receive() external payable { }


    // Tener en cuenta que si tengo una funcion suma() cuando llame a suma esto no entrará en el fallback así que irá por este camino. todo el resto irá por fallback ya que no hayotras funciones
    function suma(uint256 a, uint256 b) external returns(uint256 rta) {
        rta = Suma(callee).suma(a,b);
        result = rta;
    }

    /*
    // No puedo tener dos funciones con el mismo nombre y parametros, así que usamos esta o la anterior pero no las dos juntas
    function suma(uint256 a, uint256 b) external returns(bytes memory rta) {
        bool ok;
        (ok, rta) = callee.call(msg.data);
        if (!ok) revert();
        resultB = rta;
    }
    */

}