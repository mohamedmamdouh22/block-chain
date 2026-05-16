# Contract Reference

## Contract

`CertificateIssuer`

Source file:

```text
contracts/1_CertificateIssuer.sol
```

Solidity version:

```solidity
pragma solidity ^0.8.0;
```

License:

```text
MIT
```

## State

### `owner`

```solidity
address public owner;
```

Stores the address that deployed the contract. The owner is allowed to issue and revoke certificates.

### `Certificate`

```solidity
struct Certificate {
    string recipientName;
    string courseName;
    string grade;
    uint256 issuedAt;
    bool exists;
}
```

Represents one active certificate.

### `certificates`

```solidity
mapping(address => Certificate) private certificates;
```

Maps recipient wallet addresses to their active certificate record.

### `recipientList`

```solidity
address[] private recipientList;
```

Tracks recipient addresses that currently have active certificates.

## Access Control

### `onlyOwner`

Restricts a function to the deployer address.

Revert message:

```text
Not authorized
```

Owner-only functions:

- `issueCertificate`
- `revokeCertificate`
- `getAllRecipients`

## Events

### `CertificateIssued`

```solidity
event CertificateIssued(
    address indexed recipient,
    string recipientName,
    string courseName,
    uint256 issuedAt
);
```

Emitted after a certificate is issued.

### `CertificateRevoked`

```solidity
event CertificateRevoked(address indexed recipient);
```

Emitted after a certificate is revoked.

## Functions

### `constructor`

```solidity
constructor()
```

Sets `owner` to `msg.sender`.

### `issueCertificate`

```solidity
function issueCertificate(
    address recipient,
    string memory recipientName,
    string memory courseName,
    string memory grade
) public onlyOwner
```

Issues a new certificate to `recipient`.

Inputs:

- `recipient`: wallet address that will be associated with the certificate.
- `recipientName`: display name of the certificate holder.
- `courseName`: course or program name.
- `grade`: grade or result.

Effects:

- Stores the certificate in `certificates`.
- Sets `issuedAt` to `block.timestamp`.
- Sets `exists` to `true`.
- Adds the recipient to `recipientList`.
- Emits `CertificateIssued`.

Reverts:

- `Invalid address` if `recipient` is the zero address.
- `Already issued` if the recipient already has an active certificate.
- `Not authorized` if caller is not the owner.

### `verifyCertificate`

```solidity
function verifyCertificate(address recipient)
    public
    view
    returns (
        string memory recipientName,
        string memory courseName,
        string memory grade,
        uint256 issuedAt,
        bool valid
    )
```

Returns certificate details for a recipient address.

If no active certificate exists, string fields return empty values, `issuedAt` returns `0`, and `valid` returns `false`.

### `revokeCertificate`

```solidity
function revokeCertificate(address recipient) public onlyOwner
```

Revokes an active certificate.

Effects:

- Deletes the certificate from `certificates`.
- Removes the recipient from `recipientList`.
- Emits `CertificateRevoked`.

Reverts:

- `No certificate found` if the recipient does not have an active certificate.
- `Not authorized` if caller is not the owner.

### `hasCertificate`

```solidity
function hasCertificate(address recipient) public view returns (bool)
```

Returns whether the recipient currently has an active certificate.

### `getAllRecipients`

```solidity
function getAllRecipients() public view onlyOwner returns (address[] memory)
```

Returns all recipient addresses with active certificates.

This function is owner-only.

Ordering is not guaranteed because revocation uses swap-and-pop removal.

### `getTotalCertificates`

```solidity
function getTotalCertificates() public view returns (uint256)
```

Returns the number of active certificates.

### `_removeFromList`

```solidity
function _removeFromList(address recipient) internal
```

Internal helper used during revocation. It removes a recipient address from `recipientList` by swapping it with the final array element and popping the array.

## Example Calls

### Issue a Certificate

```text
issueCertificate(
  "0x1234...",
  "Alice Johnson",
  "Blockchain Fundamentals",
  "A"
)
```

### Verify a Certificate

```text
verifyCertificate("0x1234...")
```

Expected valid result:

```text
recipientName = "Alice Johnson"
courseName = "Blockchain Fundamentals"
grade = "A"
issuedAt = 1710000000
valid = true
```

### Revoke a Certificate

```text
revokeCertificate("0x1234...")
```
