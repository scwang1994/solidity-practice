// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import {Slots} from "../SlotManipulate.sol";

contract Proxiable is Slots {
    bytes32 constant IMPL_ADDRESS = keccak256("PROXIABLE");

    function proxiableUUID() public pure returns (bytes32) {
        return
            0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }

    function updateCodeAddress(address newAddress) internal {
        // TODO: check if target address has proxiableUUID
        // require(Proxiable(newAddress).proxiableUUID() == proxiableUUID());
        // // update code address
        // assembly {
        //     sstore(
        //         0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7,
        //         newAddress
        //     )
        // }

        (bool success, bytes memory result) = address(newAddress).call(
            abi.encodeCall(Proxiable(newAddress).proxiableUUID, ())
        );

        require(
            success && abi.decode(result, (bytes32)) == proxiableUUID(),
            "Not compatible with UUPS proxy"
        );

        _setSlotToAddress(IMPL_ADDRESS, newAddress);
    }
}
