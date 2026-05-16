# Project Overview

## Purpose

This project provides a simple on-chain certificate issuer for educational or training workflows. An authorized issuer can assign a certificate to a wallet address, and third parties can verify the certificate by querying the smart contract.

The system is useful when certificate validity should be independently checkable without relying on a private database or manually maintained spreadsheet.

## Core Contract

The project is centered on `CertificateIssuer` in `contracts/1_CertificateIssuer.sol`.

The contract stores one active certificate per recipient address. Each certificate contains:

- `recipientName`: the human-readable name of the certificate recipient.
- `courseName`: the course, program, or achievement name.
- `grade`: the grade or result attached to the certificate.
- `issuedAt`: the block timestamp when the certificate was issued.
- `exists`: an internal validity flag.

## Architecture

```text
Issuer wallet
  |
  | owner-only transaction
  v
CertificateIssuer contract
  |
  | stores certificate by recipient wallet address
  v
On-chain certificate registry
  |
  | public read calls
  v
Students, employers, verifiers, and integrations
```

## Roles

### Owner

The owner is the wallet that deploys the contract. The owner can issue and revoke certificates and list all active recipients.

### Recipient

The recipient is the wallet address that receives the certificate record. The recipient does not need to call the contract to accept the certificate.

### Verifier

Any address or off-chain system can call the public verification functions to confirm whether a recipient has an active certificate and read its details.

## Certificate Lifecycle

### Issue

The owner calls `issueCertificate` with:

- recipient wallet address
- recipient name
- course name
- grade

The contract rejects zero-address recipients and duplicate active certificates for the same address.

### Verify

Anyone can call `verifyCertificate(recipient)` to retrieve the stored certificate details and validity flag.

For simpler checks, callers can use `hasCertificate(recipient)`, which returns only a boolean.

### Revoke

The owner calls `revokeCertificate(recipient)` to remove a certificate. The contract deletes the certificate data and removes the recipient from the active recipient list.

After revocation:

- `hasCertificate(recipient)` returns `false`.
- `verifyCertificate(recipient)` returns empty/default values and `valid = false`.
- `getTotalCertificates()` decreases by one.

## Data Model

Certificates are stored in a mapping:

```solidity
mapping(address => Certificate) private certificates;
```

The contract also keeps an array of active recipients:

```solidity
address[] private recipientList;
```

The array allows the owner to list all active certificate recipients and lets anyone read the total active certificate count.

## Important Behavior

- Only one active certificate can exist per recipient address.
- Reissuing to the same address is possible only after revocation.
- Recipient order in `getAllRecipients()` is not stable because revocation uses swap-and-pop removal.
- The contract stores certificate text directly on-chain, so gas cost increases with longer strings.
- Revoked certificate details are deleted from current contract state.

## Current Limitations

- No ownership transfer function.
- No support for multiple certificates per recipient address.
- No certificate ID separate from recipient address.
- No update/edit function for an issued certificate.
- No off-chain metadata hash or document URI field.
- No dedicated `CertificateIssuer` tests are currently included.

## Recommended Improvements

For production use, consider adding:

- `transferOwnership` or a standard ownership module.
- Support for multiple certificates per recipient.
- Certificate IDs for easier indexing.
- A metadata hash or URI for linking to off-chain certificate files.
- Dedicated test coverage for all contract functions and revert paths.
- Deployment scripts configured directly for `CertificateIssuer`.
