// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecurityLog {
    struct LogEntry {
        uint256 timestamp;
        string eventType;
        string description;
        string userAddress;
        string metadata;
        bytes32 hash;
        bool verified;
    }

    LogEntry[] private logs;
    address public owner;

    event LogAdded(uint256 index, string eventType, string userAddress, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // REMOVED onlyOwner - Now anyone can add logs!
    function addLog(
        string memory _eventType,
        string memory _description,
        string memory _userAddress,
        string memory _metadata
    ) public returns (uint256) {
        bytes32 logHash = keccak256(
            abi.encodePacked(
                block.timestamp,
                _eventType,
                _description,
                _userAddress,
                _metadata
            )
        );

        LogEntry memory newLog = LogEntry({
            timestamp: block.timestamp,
            eventType: _eventType,
            description: _description,
            userAddress: _userAddress,
            metadata: _metadata,
            hash: logHash,
            verified: false
        });

        logs.push(newLog);
        uint256 index = logs.length - 1;

        emit LogAdded(index, _eventType, _userAddress, block.timestamp);
        return index;
    }

    function getLog(uint256 _index) public view returns (
        uint256 timestamp,
        string memory eventType,
        string memory description,
        string memory userAddress,
        string memory metadata,
        bytes32 hash,
        bool verified
    ) {
        require(_index < logs.length, "Log does not exist");
        LogEntry memory log = logs[_index];
        return (
            log.timestamp,
            log.eventType,
            log.description,
            log.userAddress,
            log.metadata,
            log.hash,
            log.verified
        );
    }

    function getLogHistory() public view returns (LogEntry[] memory) {
        return logs;
    }

    function verifyLog(uint256 _index) public onlyOwner {
        require(_index < logs.length, "Log does not exist");
        logs[_index].verified = true;
    }

    function verifyLogIntegrity(uint256 _index) public view returns (bool) {
        require(_index < logs.length, "Log does not exist");
        LogEntry memory log = logs[_index];
        bytes32 computedHash = keccak256(
            abi.encodePacked(
                log.timestamp,
                log.eventType,
                log.description,
                log.userAddress,
                log.metadata
            )
        );
        return computedHash == log.hash && logs[_index].verified;
    }

    function getTotalLogs() public view returns (uint256) {
        return logs.length;
    }
}
