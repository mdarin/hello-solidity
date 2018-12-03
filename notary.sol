pragma solidity ^0.4.24;

/*

Реализовать смарт контракт нотариуса : Смарт контракт должен иметь 2 функци 
* notarize, принимающую на вход произвольную строку и создающую на основании этого хэш данной строки,
    который впоследствие будет храниться на блокчейне(за хэш функцию можно брать как sha256, так и keccak) 
* proofFor, принимающую на вход строку, и возвращающая хэш данной строки, 
    данная функция должна только быть read-only и ничего не записывать на блокчейн

*/

contract Notary {
    
    mapping (address => bytes32) notarialRegister;
    
    function notarize(string _document) public {
        // внести запись в реестр хэш первичного документа
        notarialRegister[msg.sender] = keccak256(bytes(_document));
    }
    
    function proofFor(string _document) public view returns(bytes32) {
        // получить данные из реестра и запроса
        bytes32 registred = notarialRegister[msg.sender];
        bytes32 tested = keccak256(bytes(_document));
        // произвести проверку подлинности
        require(registred == tested, "FAIL: Not equivalent documents");
        // елси подлинность установленана, вернуть хэш документа
        return tested; 
    }
}
