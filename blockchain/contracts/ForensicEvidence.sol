// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ForensicEvidence {
    struct Evidence {
        uint256 timestamp;
        string evidenceId;
        string evidenceType;
        string description;
        string hash;
        string collector;
        bool verified;
    }

    Evidence[] private evidence;
    address public owner;

    event EvidenceAdded(string evidenceId, string evidenceType, uint256 timestamp);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // REMOVED onlyOwner - Now anyone can add evidence!
    function addEvidence(
        string memory _evidenceId,
        string memory _evidenceType,
        string memory _description,
        string memory _hash,
        string memory _collector
    ) public returns (uint256) {
        Evidence memory newEvidence = Evidence({
            timestamp: block.timestamp,
            evidenceId: _evidenceId,
            evidenceType: _evidenceType,
            description: _description,
            hash: _hash,
            collector: _collector,
            verified: false
        });

        evidence.push(newEvidence);
        uint256 index = evidence.length - 1;

        emit EvidenceAdded(_evidenceId, _evidenceType, block.timestamp);
        return index;
    }

    function getEvidence(uint256 _index) public view returns (
        uint256 timestamp,
        string memory evidenceId,
        string memory evidenceType,
        string memory description,
        string memory hash,
        string memory collector,
        bool verified
    ) {
        require(_index < evidence.length, "Evidence does not exist");
        Evidence memory ev = evidence[_index];
        return (
            ev.timestamp,
            ev.evidenceId,
            ev.evidenceType,
            ev.description,
            ev.hash,
            ev.collector,
            ev.verified
        );
    }

    function verifyEvidence(uint256 _index) public onlyOwner {
        require(_index < evidence.length, "Evidence does not exist");
        evidence[_index].verified = true;
    }

    function getEvidenceCount() public view returns (uint256) {
        return evidence.length;
    }
}
