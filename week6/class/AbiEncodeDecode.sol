// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IAbiEncodeDecode {
    function submitEncodeData(bytes calldata data) external;
    function submitDecodeData(bytes32 data) external;
}

contract Attack {
    address addr = address(this);
    string encodepassword = "appworks.school.4/10.encode";
    struct Payment {
        address receiver;
        uint256 amount;
    }

    // idea
    // 從 require 著手，需要 sender, _password, payment.amount)
    // 以上 3 個 data 在 submitEncodeData() 以 decode 取得，故此函數要先將 data encode 後做為參數傳入 submitEncodeData()
    function submitEncodeData(address _addr) external {
        // payment 需要傳入接受者跟數量
        Payment memory payment = Payment(msg.sender, 0.25 ether);
        // _password 有給 string encodepassword，但因為 decode 輸出為 bytes32，故要先將其轉為 bytes32
        bytes memory result = abi.encode(addr, payment, bytes32(bytes(encodepassword)));
        IAbiEncodeDecode(_addr).submitEncodeData(result);
    }

    // function revealDecodePassword(bytes memory _decodePassword) external returns(bytes memory) {
    //     return _decodePassword;
    // }
    // // function submitDecodeData(bytes32 data) extern al {
    // //     rawPassword = abi.encode(data);
    // //     // (, bytes memory rawPassword) = password.call(abi.encodeWithSignature("getDecodePassword()"));
    // //     // bytes32 decodePassword = abi.decode(rawPassword, (bytes32));
    // //     // require(data == decodePassword, "wrong decode password");
    // //     // (bool success, ) = msg.sender.call{ value: REWARD }("");
    // //     // require(success);
    // // }
}