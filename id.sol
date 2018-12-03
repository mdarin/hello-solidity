pragma solidity ^0.4.24;

import "./ownable.sol";

//
// Реализовать смарт контракт визитки: Данный смарт контракт должен содержать mapping, 
// где ключом будет являться номер телефона, а значением имя и фамилия, а также функцию, 
// с помощью которой можно добавлять записи в этот маппинг, или изменять уже существующие данные. 
// Данную функцию должен иметь возможность вызывать только владелец контракта
//

contract ID is Ownable {
    
    string name = "";
    mapping (string => mapping(string => string)) info; // insted of struct, because hash of hashes is more flexible
    
    // for all
    function set(string _name) public {
        name = _name;
    }
    // for all
    function get() public view returns(string) {
        return name; 
    }
    
    // only owner
    function setField(string _key, string _field, string _value) public onlyOwner {
        info[_key][_field] = _value;
    }
    // for all
    function getField(string _key, string _field) public view returns(string) {
        return info[_key][_field];
    }
}
