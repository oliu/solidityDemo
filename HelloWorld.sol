// comment: this is my first smart contract

// uint256 a = 1 + 1;
// uint256 a = 1.add(1);
// uint256 a = add(1,1);

// compiler -> compile(unit256 a = 1 + 1;)-> 0100011010101 bytecode;
// Evm 1.0
// EVM(Ethreum virtual machine) -> execute(0100011010101 bytecode)-> result

// SPDX-License-Identifier: MIT
// 高于这个版本都支持
pragma solidity  ^0.8.20;

contract HelloWorld {
    bool boolVar_1 = true;
    bool boolVar_2 = false;
    // u是无符号 uint8 0-(2的8次方-1）及0-255
    uint8 uintVar = 255;
    // uint = uint256 这二者是相同的
    uint256 uintVar2 = 1;
    int256 intVar = -1;

    // bytes byte = 8bit;
    // bytes8表示可以存储8个字节 最大是bytes32
    bytes32 bytesVar = "Hello World";
    string strVar = "Hello World 2025";
    /*
    1. struct 结构体
    2. array 数组
    3. mapping 映射 key->value
    */
    struct Info {
        string phrase;
        uint256 id;
        address addr;
    }
    Info[] infos;
    mapping(uint256 id=> Info info) infoMapping;
    /*
    1. storage 永久性存储
    2. memory 暂时性存储
    3. calldata 暂时性存储 结构体
    4. stack 栈存储
    5. codes
    6. logs
    */

    // view 是没有任何的状态更改，只是对变量进行读取
    // function sayHello() public view  returns(string memory){
    //     return addinfo(strVar);
    // }
    /*function sayHello(uint256 _id) public view  returns(string memory){
       for(uint256 i=0; i <infos.length; i++) {
            if(infos[i].id == _id) {
                return addinfo(infos[i].phrase);
            }
        }
        return addinfo(strVar);
    }*/
    function sayHello(uint256 _id) public view  returns(string memory){
       if(infoMapping[_id].addr == address(0x0)) {
         return addinfo(strVar);
       } else {
         return addinfo(infoMapping[_id].phrase);
       }
    }
    //uint256是基础类型，所以不用声明是memory
    function setHello(string memory newString, uint256 _id) public {
        // strVar = newString;
        Info memory info = Info(newString, _id, msg.sender);
        // infos.push(info);
        infoMapping[_id] = info;
    }
    // pure 不去修改任何值，只是去纯运算
    function addinfo(string memory helloWorldStr) internal pure returns(string memory){
        return string.concat(helloWorldStr, " from oliu.");
    }

}
