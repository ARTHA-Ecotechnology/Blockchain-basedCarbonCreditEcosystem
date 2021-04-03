pragma solidity >0.5.0;

import "./token/ERC20/ERC20.sol";

contract CarbonCredit is ERC20 {

    address public contractOwner;

    function getContractOwner() public returns (address) {
        return contractOwner;
    }

    struct Generator {
        uint id;
        uint tokenBalance;
        string generatorName;
        address generatorAddress;
    }

    struct Consumer {
        uint id;
        uint tokenBalance;
        uint emissions; //current emissions so far
        string consumerName;
        address consumerAddress;
    }

    mapping(uint => Generator) public allGenerators;
    mapping(uint => Consumer) allConsumers;
    mapping(address => bool) allValidators;

    mapping(uint => bool) generatorExists;
    mapping(uint => bool) consumerExists;

    uint[] consumerList;
    uint[] generatorList;
    uint[] violatorsList;

    // constructor() public ERC20("Carbon Token", "c") {
    //     contractOwner = msg.sender;
    // }

    constructor() public ERC20() {
        contractOwner = msg.sender;
    }

    modifier isValidator() {
        require(allValidators[msg.sender] == true);
        _;
    }

    modifier isRegulator() {
        require(contractOwner == msg.sender);
        _;
    }

    // TEST VARIABLES AND FUNCTIONS - TO REMOVE
    uint public carbondata = 987654321;

    function changecarbondata() public {
        carbondata = 12345;
    }

    function changechange(uint generatorId, address thisAdd) public {
        changecarbondata();
    }

    function getGenerator(uint generatorId) public returns (bool) {
        return generatorExists[generatorId];
    }

    function getGeneratorList() public returns (uint[] memory) {
        return generatorList;
    }

    function getViolators() public returns (uint[] memory){ // for consumers
        return violatorsList;
    }

    //Create new generator and store in mapping, assign values (balance = 0)
    function createGenerator(uint generatorId, string memory name, address thisAdd) public isRegulator {
        require(generatorExists[generatorId] == false);

        Generator memory newGenerator = Generator(
            generatorId,
            0,
            name,
            thisAdd
        );

        allGenerators[generatorId] = newGenerator;
        generatorExists[generatorId] = true;

        generatorList.push(generatorId);

    }
    //Create new consumer and store in mapping, assign values (balance = limit)
    function createConsumer(uint consumerId, string memory name, address thisAdd) public isRegulator {
        require(consumerExists[consumerId] == false);

        Consumer memory newConsumer = Consumer(
            consumerId,
            100,
            0,
            name,
            thisAdd
        );

        allConsumers[consumerId] = newConsumer;
        consumerExists[consumerId] = true;
        consumerList.push(consumerId);
    }


    //Award tokens to generators when carbon saving projects are approved
    function allocateCredit(uint generatorId, uint credit) public isValidator {
        require(generatorExists[generatorId] == true);
        require(credit > 0);

        //_mint(contractOwner, allGenerators[generatorId].generatorAddress, credit, "receive", "fromRegulator");
        _mint(allGenerators[generatorId].generatorAddress, credit);
        allGenerators[generatorId].tokenBalance += credit;

    }

    //Validators input a emissions amt (frontend), add it to consumer's emissions value
    function reportEmission(uint consumerId, uint emission) public isValidator{
        require(emission > 0);
        require(consumerExists[consumerId] == true);

        allConsumers[consumerId].emissions = emission;

        // Add consumerId to violatorsList if emissions exceed tokenBalance.
        if (emission > allConsumers[consumerId].tokenBalance) {
            violatorsList.push(consumerId);
        }
    }

    // Cant put int, must put uint, if not it screws up the entire contract
    function updateConsumerBalance(uint consumerId, uint delta, bool subtract) public {
        require(consumerExists[consumerId] == true);

        if (subtract) {
            allConsumers[consumerId].tokenBalance -= delta;
        } else {
            allConsumers[consumerId].tokenBalance += delta;
        }

    }

    // Cant put int, must put uint, if not it screws up the entire contract
    function updateGeneratorBalance(uint generatorId, uint delta, bool subtract) public {
        require(generatorExists[generatorId] == true);


        if (subtract) {
            allGenerators[generatorId].tokenBalance -= delta;
        } else {
            allGenerators[generatorId].tokenBalance += delta;
        }
    }

    // GETTERS
    function getConsumerCredits(uint consumerId) public returns (uint credit) {
        require(consumerExists[consumerId] == true);
        return (allConsumers[consumerId].tokenBalance);
    }

    function getGeneratorCredits(uint generatorId) public returns (uint credit) {
        require(generatorExists[generatorId] == true);
        return (allGenerators[generatorId].tokenBalance);
    }

    function isGenerator(uint ID) public returns (bool doesExist) {
        return (generatorExists[ID]);
    }

    function isConsumer(uint ID) public returns (bool doesExist) {
        return (consumerExists[ID]);
    }

    function getConsumerName(uint consumerId) public returns (string memory) {
        require(consumerExists[consumerId] == true);
        return (allConsumers[consumerId].consumerName);
    }
    function getConsumerEmission(uint consumerId) public returns (uint emission) {
        require(consumerExists[consumerId] == true);
        return (allConsumers[consumerId].emissions);
    }


    // //For each consumer in mapping, check if emissions > tokenBalance. If yes, add to result list and return list.
    // function checkEmission() isRegulator public returns (mapping(uint => uint[])) {
    //     // the returned array contains [tokenBalance, emissions, amountExceededBy]
    //     mapping(uint => uint[]) res;

    //     for (uint i=0; i<consumerList.length; i++) {
    //         uint thisID = consumerList[i];
    //         uint thisBalance = allConsumers[thisID].tokenBalance;
    //         uint thisEmission = allConsumers[thisID].emissions;

    //         if (thisEmission > thisBalance) {
    //             uint[] storage thisRes;
    //             thisRes.push(thisBalance);
    //             thisRes.push(thisEmission);
    //             thisRes.push(thisEmission - thisBalance);

    //             res[thisID] = thisRes;
    //         }
    //     }

    //     return (res);
    // }


}