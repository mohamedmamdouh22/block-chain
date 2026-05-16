# Certificate Issuer Smart Contract

Certificate Issuer is a Solidity project for issuing, verifying, tracking, and revoking digital course certificates on-chain. It is built around a single owner-managed smart contract, `CertificateIssuer`, and is intended to be compiled, deployed, and interacted with from Remix IDE or compatible Ethereum development tooling.

## Main Features

- Issue a certificate to a recipient wallet address.
- Store certificate details on-chain: recipient name, course name, grade, issue timestamp, and validity state.
- Prevent duplicate active certificates for the same recipient address.
- Verify a certificate publicly by recipient address.
- Revoke an issued certificate by deleting its stored record.
- Track all currently active certificate recipient addresses.
- Count the total number of active certificates.
- Restrict issuing, revocation, and recipient listing to the contract owner.
- Emit events when certificates are issued or revoked.

## Project Structure

```text
contracts/
  1_CertificateIssuer.sol       Main smart contract.

scripts/
  deploy_with_ethers.ts         Remix ethers.js deployment helper.
  deploy_with_web3.ts           Remix web3.js deployment helper.
  ethers-lib.ts                 Shared ethers.js deploy function.
  web3-lib.ts                   Shared web3.js deploy function.

artifacts/
  CertificateIssuer.json        Compiled contract artifact.
  CertificateIssuer_metadata.json

docs/
  CONTRACT_REFERENCE.md         Contract API and behavior reference.
  DEPLOYMENT_GUIDE.md           Remix deployment and interaction guide.
  PROJECT_OVERVIEW.md           Architecture, lifecycle, and limitations.
```

## Smart Contract

The main contract is [contracts/1_CertificateIssuer.sol](contracts/1_CertificateIssuer.sol).

When deployed, the deployer address becomes `owner`. Only the owner can:

- call `issueCertificate`
- call `revokeCertificate`
- call `getAllRecipients`

Anyone can:

- call `verifyCertificate`
- call `hasCertificate`
- call `getTotalCertificates`

## Certificate Lifecycle

1. The owner deploys `CertificateIssuer`.
2. The owner issues a certificate to a recipient address.
3. Anyone can verify that recipient's certificate details.
4. The owner can revoke the certificate if needed.
5. Revoked certificates are removed from the active certificate count and recipient list.

## Quick Start in Remix

1. Open the project in Remix IDE.
2. Open `contracts/1_CertificateIssuer.sol`.
3. Compile the contract with Solidity `0.8.x`.
4. Deploy `CertificateIssuer` from the "Deploy & Run Transactions" panel.
5. Use the deployed contract panel to call:
   - `issueCertificate(recipient, recipientName, courseName, grade)`
   - `verifyCertificate(recipient)`
   - `revokeCertificate(recipient)`
   - `getTotalCertificates()`

The deployment scripts in `scripts/` are Remix helper scripts. They are generic Remix defaults and should be updated from `Storage` to `CertificateIssuer` before using them to deploy this contract.

## Documentation

Detailed documentation is available in the `docs/` directory:

- [docs/PROJECT_OVERVIEW.md](docs/PROJECT_OVERVIEW.md) explains the system purpose, architecture, data model, and operational limits.
- [docs/CONTRACT_REFERENCE.md](docs/CONTRACT_REFERENCE.md) documents the contract state, functions, events, permissions, and revert conditions.
- [docs/DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) explains how to compile, deploy, and interact with the contract in Remix.

## Testing

No automated test suite is currently included. Validate the contract by interacting with the deployed `CertificateIssuer` contract in Remix or another Ethereum client.

Recommended manual checks:

- Confirm `owner()` returns the deploying wallet.
- Issue a certificate from the owner account.
- Verify the certificate with `verifyCertificate`.
- Confirm `hasCertificate` returns `true` for the issued recipient.
- Confirm duplicate issuance to the same recipient reverts.
- Revoke the certificate from the owner account.
- Confirm `hasCertificate` returns `false` after revocation.
- Confirm `getTotalCertificates` reflects the active certificate count.

## Security Notes

- Certificate issuance and revocation are centralized under the deployer/owner address.
- There is no ownership transfer function in the current contract.
- Revocation deletes the certificate data from contract storage.
- `getAllRecipients` is owner-only, but individual certificate verification is public.
- The recipient list removal uses swap-and-pop, so returned recipient order is not guaranteed.

## License

The smart contract uses the MIT license.
