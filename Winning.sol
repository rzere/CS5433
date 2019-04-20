pragma solidity ^0.5.7;
contract EtheremonLite {
    function initMonster(string memory _monsterName) public;
    function battle() public returns(uint256);
    function getName(address _monsterAddress) public view returns(string memory);
    function getNumWins(address _monsterAddress) public view returns(uint);
    function getNumLosses(address _monsterAddress) public view returns(uint);
}

contract WinBattle {
    string name;
    uint wins;
    uint losses;
    event EmitName(string name);
    EtheremonLite etheremonlite_contract;
    address constant public etheremonlite_address = 0xF3259eEC5B4a46748a1F608eC3D74b89058bB3aD;
    event check_block(uint voter);
    event check_wins_losses(uint count);
    constructor() public {
        etheremonlite_contract = EtheremonLite(etheremonlite_address);
    }

    function get_last_block_hash() public view returns(uint) {
        return uint(blockhash(block.number - 1));
    }

    function create_monster(string memory monster_name) public returns (bool) {
        etheremonlite_contract.initMonster(monster_name);
    }

    function should_attack() public  returns(uint) {
        uint last_block_hash = get_last_block_hash();
        uint dice = last_block_hash / 85;
        emit check_block(dice % 3);
        return dice % 3;
    }
    
    function tryit() public  {
        if (should_attack() == 0) {
            attack();
        } 
    }
    
    function attack() public returns(uint256) {
        return etheremonlite_contract.battle();   
    }
}