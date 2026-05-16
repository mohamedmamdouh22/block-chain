// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificateIssuer {

    address public owner;

    struct Certificate {
        string recipientName;
        string courseName;
        string grade;
        uint256 issuedAt;
        bool exists;
    }

    mapping(address => Certificate) private certificates;
    
    // NEW — tracks all recipient addresses
    address[] private recipientList;

    event CertificateIssued(
        address indexed recipient,
        string recipientName,
        string courseName,
        uint256 issuedAt
    );

    event CertificateRevoked(address indexed recipient);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function issueCertificate(
        address recipient,
        string memory recipientName,
        string memory courseName,
        string memory grade
    ) public onlyOwner {
        require(recipient != address(0), "Invalid address");
        require(!certificates[recipient].exists, "Already issued");

        certificates[recipient] = Certificate({
            recipientName: recipientName,
            courseName:    courseName,
            grade:         grade,
            issuedAt:      block.timestamp,
            exists:        true
        });

        // NEW — add address to the list
        recipientList.push(recipient);

        emit CertificateIssued(recipient, recipientName, courseName, block.timestamp);
    }

    function verifyCertificate(address recipient)
        public view
        returns (
            string memory recipientName,
            string memory courseName,
            string memory grade,
            uint256 issuedAt,
            bool valid
        )
    {
        Certificate memory cert = certificates[recipient];
        return (
            cert.recipientName,
            cert.courseName,
            cert.grade,
            cert.issuedAt,
            cert.exists
        );
    }

    function revokeCertificate(address recipient) public onlyOwner {
        require(certificates[recipient].exists, "No certificate found");
        delete certificates[recipient];

        // NEW — remove from the list
        _removeFromList(recipient);

        emit CertificateRevoked(recipient);
    }

    function hasCertificate(address recipient) public view returns (bool) {
        return certificates[recipient].exists;
    }

    // NEW — returns all addresses that currently have a certificate
    function getAllRecipients() public view onlyOwner returns (address[] memory) {
        return recipientList;
    }

    // NEW — returns total number of active certificates
    function getTotalCertificates() public view returns (uint256) {
        return recipientList.length;
    }

    // NEW — internal helper to remove address from array on revoke
    function _removeFromList(address recipient) internal {
        uint256 length = recipientList.length;
        for (uint256 i = 0; i < length; i++) {
            if (recipientList[i] == recipient) {
                // swap with last element and pop
                recipientList[i] = recipientList[length - 1];
                recipientList.pop();
                break;
            }
        }
    }
}