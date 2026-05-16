// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol";
import "../contracts/1_CertificateIssuer.sol";

contract NonOwnerCaller {
    function issueCertificate(
        CertificateIssuer issuer,
        address recipient,
        string memory recipientName,
        string memory courseName,
        string memory grade
    ) public {
        issuer.issueCertificate(recipient, recipientName, courseName, grade);
    }

    function revokeCertificate(CertificateIssuer issuer, address recipient) public {
        issuer.revokeCertificate(recipient);
    }

    function getAllRecipients(CertificateIssuer issuer) public view returns (address[] memory) {
        return issuer.getAllRecipients();
    }
}

contract CertificateIssuerTest {
    address private constant RECIPIENT_ONE = address(uint160(0x1001));
    address private constant RECIPIENT_TWO = address(uint160(0x1002));

    function testOwnerIsContractDeployer() public {
        CertificateIssuer issuer = new CertificateIssuer();

        Assert.equal(
            uint256(uint160(issuer.owner())),
            uint256(uint160(address(this))),
            "deployer should be recorded as owner"
        );
        Assert.equal(issuer.getTotalCertificates(), uint256(0), "initial certificate count should be zero");
    }

    function testOwnerCanIssueAndVerifyCertificate() public {
        CertificateIssuer issuer = new CertificateIssuer();

        issuer.issueCertificate(RECIPIENT_ONE, "Alice Johnson", "Blockchain Fundamentals", "A");

        (
            string memory recipientName,
            string memory courseName,
            string memory grade,
            uint256 issuedAt,
            bool valid
        ) = issuer.verifyCertificate(RECIPIENT_ONE);

        Assert.equal(valid, true, "certificate should be valid after issue");
        Assert.equal(issuer.hasCertificate(RECIPIENT_ONE), true, "recipient should have a certificate");
        Assert.equal(issuer.getTotalCertificates(), uint256(1), "active certificate count should be one");
        Assert.equal(
            keccak256(bytes(recipientName)),
            keccak256(bytes("Alice Johnson")),
            "recipient name should match"
        );
        Assert.equal(
            keccak256(bytes(courseName)),
            keccak256(bytes("Blockchain Fundamentals")),
            "course name should match"
        );
        Assert.equal(keccak256(bytes(grade)), keccak256(bytes("A")), "grade should match");
        Assert.ok(issuedAt > 0, "issue timestamp should be set");

        address[] memory recipients = issuer.getAllRecipients();
        Assert.equal(recipients.length, uint256(1), "recipient list should contain one address");
        Assert.equal(
            uint256(uint160(recipients[0])),
            uint256(uint160(RECIPIENT_ONE)),
            "recipient list should include issued recipient"
        );
    }

    function testIssueRejectsZeroAddress() public {
        CertificateIssuer issuer = new CertificateIssuer();

        try issuer.issueCertificate(address(0), "Invalid User", "Blockchain Fundamentals", "A") {
            Assert.ok(false, "zero-address issuance should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Invalid address", "unexpected zero-address revert reason");
        } catch {
            Assert.ok(false, "zero-address issuance should revert with a reason");
        }
    }

    function testIssueRejectsDuplicateRecipient() public {
        CertificateIssuer issuer = new CertificateIssuer();

        issuer.issueCertificate(RECIPIENT_ONE, "Alice Johnson", "Blockchain Fundamentals", "A");

        try issuer.issueCertificate(RECIPIENT_ONE, "Alice Johnson", "Advanced Solidity", "A+") {
            Assert.ok(false, "duplicate issuance should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Already issued", "unexpected duplicate revert reason");
        } catch {
            Assert.ok(false, "duplicate issuance should revert with a reason");
        }
    }

    function testOwnerCanRevokeCertificate() public {
        CertificateIssuer issuer = new CertificateIssuer();

        issuer.issueCertificate(RECIPIENT_ONE, "Alice Johnson", "Blockchain Fundamentals", "A");
        issuer.revokeCertificate(RECIPIENT_ONE);

        (
            string memory recipientName,
            string memory courseName,
            string memory grade,
            uint256 issuedAt,
            bool valid
        ) = issuer.verifyCertificate(RECIPIENT_ONE);

        Assert.equal(valid, false, "certificate should be invalid after revocation");
        Assert.equal(issuer.hasCertificate(RECIPIENT_ONE), false, "recipient should not have certificate");
        Assert.equal(issuer.getTotalCertificates(), uint256(0), "active certificate count should be zero");
        Assert.equal(keccak256(bytes(recipientName)), keccak256(bytes("")), "recipient name should be cleared");
        Assert.equal(keccak256(bytes(courseName)), keccak256(bytes("")), "course name should be cleared");
        Assert.equal(keccak256(bytes(grade)), keccak256(bytes("")), "grade should be cleared");
        Assert.equal(issuedAt, uint256(0), "issue timestamp should be cleared");
    }

    function testRevokeRejectsMissingCertificate() public {
        CertificateIssuer issuer = new CertificateIssuer();

        try issuer.revokeCertificate(RECIPIENT_ONE) {
            Assert.ok(false, "revoking a missing certificate should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "No certificate found", "unexpected missing certificate revert reason");
        } catch {
            Assert.ok(false, "revoking a missing certificate should revert with a reason");
        }
    }

    function testRecipientListUpdatesAfterRevocation() public {
        CertificateIssuer issuer = new CertificateIssuer();

        issuer.issueCertificate(RECIPIENT_ONE, "Alice Johnson", "Blockchain Fundamentals", "A");
        issuer.issueCertificate(RECIPIENT_TWO, "Bob Smith", "Smart Contract Security", "B+");
        issuer.revokeCertificate(RECIPIENT_ONE);

        address[] memory recipients = issuer.getAllRecipients();

        Assert.equal(recipients.length, uint256(1), "recipient list should contain one active recipient");
        Assert.equal(
            uint256(uint160(recipients[0])),
            uint256(uint160(RECIPIENT_TWO)),
            "recipient list should keep the remaining active recipient"
        );
        Assert.equal(issuer.getTotalCertificates(), uint256(1), "active certificate count should be one");
    }

    function testCanReissueAfterRevocation() public {
        CertificateIssuer issuer = new CertificateIssuer();

        issuer.issueCertificate(RECIPIENT_ONE, "Alice Johnson", "Blockchain Fundamentals", "A");
        issuer.revokeCertificate(RECIPIENT_ONE);
        issuer.issueCertificate(RECIPIENT_ONE, "Alice Johnson", "Advanced Solidity", "A+");

        (, string memory courseName, string memory grade, , bool valid) = issuer.verifyCertificate(RECIPIENT_ONE);

        Assert.equal(valid, true, "certificate should be valid after reissue");
        Assert.equal(issuer.getTotalCertificates(), uint256(1), "active certificate count should be one");
        Assert.equal(keccak256(bytes(courseName)), keccak256(bytes("Advanced Solidity")), "course should be updated");
        Assert.equal(keccak256(bytes(grade)), keccak256(bytes("A+")), "grade should be updated");
    }

    function testNonOwnerCannotIssueRevokeOrListRecipients() public {
        CertificateIssuer issuer = new CertificateIssuer();
        NonOwnerCaller nonOwner = new NonOwnerCaller();

        try nonOwner.issueCertificate(issuer, RECIPIENT_ONE, "Alice Johnson", "Blockchain Fundamentals", "A") {
            Assert.ok(false, "non-owner issue should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Not authorized", "unexpected non-owner issue revert reason");
        } catch {
            Assert.ok(false, "non-owner issue should revert with a reason");
        }

        issuer.issueCertificate(RECIPIENT_ONE, "Alice Johnson", "Blockchain Fundamentals", "A");

        try nonOwner.revokeCertificate(issuer, RECIPIENT_ONE) {
            Assert.ok(false, "non-owner revoke should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Not authorized", "unexpected non-owner revoke revert reason");
        } catch {
            Assert.ok(false, "non-owner revoke should revert with a reason");
        }

        try nonOwner.getAllRecipients(issuer) returns (address[] memory recipients) {
            recipients;
            Assert.ok(false, "non-owner recipient list should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "Not authorized", "unexpected non-owner list revert reason");
        } catch {
            Assert.ok(false, "non-owner recipient list should revert with a reason");
        }
    }
}
