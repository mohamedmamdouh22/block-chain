# Deployment Guide

## Recommended Environment

This project is structured as a Remix IDE workspace. The simplest workflow is to compile and deploy directly from Remix.

Recommended compiler:

```text
Solidity 0.8.x
```

Main contract:

```text
contracts/1_CertificateIssuer.sol
```

## Compile in Remix

1. Open Remix IDE.
2. Open `contracts/1_CertificateIssuer.sol`.
3. Go to the "Solidity Compiler" panel.
4. Select a compiler version compatible with `^0.8.0`.
5. Compile `1_CertificateIssuer.sol`.

## Deploy in Remix

1. Go to the "Deploy & Run Transactions" panel.
2. Select the target environment.
   - Use "Remix VM" for local testing.
   - Use "Injected Provider" for a wallet such as MetaMask.
3. Select the `CertificateIssuer` contract.
4. Click "Deploy".
5. Save the deployed contract address.

The deploying address becomes the contract `owner`.

## Issue a Certificate

Call `issueCertificate` from the owner account.

Inputs:

```text
recipient:     recipient wallet address
recipientName: recipient display name
courseName:    course or program name
grade:         grade or result
```

Example:

```text
recipient:     0x0000000000000000000000000000000000000001
recipientName: Alice Johnson
courseName:    Blockchain Fundamentals
grade:         A
```

After the transaction is mined, the contract emits `CertificateIssued`.

## Verify a Certificate

Anyone can call:

```text
verifyCertificate(recipient)
```

The function returns:

```text
recipientName
courseName
grade
issuedAt
valid
```

For a quick boolean check, call:

```text
hasCertificate(recipient)
```

## Revoke a Certificate

Call `revokeCertificate(recipient)` from the owner account.

After revocation:

- the certificate record is deleted
- the recipient is removed from the active list
- `hasCertificate(recipient)` returns `false`
- `CertificateRevoked` is emitted

## Count Active Certificates

Call:

```text
getTotalCertificates()
```

This returns the number of currently active certificates.

## List Active Recipients

Call:

```text
getAllRecipients()
```

This function is restricted to the owner. The returned order is not guaranteed.

## Using the Deployment Scripts

The scripts in `scripts/` are Remix TypeScript helpers originally generated from Remix defaults. Before using either deployment script, update the contract name from `Storage` to `CertificateIssuer`.

In `scripts/deploy_with_ethers.ts`:

```ts
const result = await deploy('CertificateIssuer', [])
```

In `scripts/deploy_with_web3.ts`:

```ts
const result = await deploy('CertificateIssuer', [])
```

Then compile the contract in Remix and run the script from the Remix file explorer.

## Post-Deployment Checklist

- Confirm `owner()` returns the expected issuer wallet.
- Issue one test certificate.
- Verify the certificate from a non-owner account.
- Confirm duplicate issuance to the same recipient reverts.
- Revoke the test certificate.
- Confirm `hasCertificate` returns `false` after revocation.
- Confirm `getTotalCertificates` matches the expected active count.
