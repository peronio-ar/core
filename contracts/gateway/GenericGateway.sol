// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IGenericGateway.sol";

import {Context} from "@openzeppelin/contracts_latest/utils/Context.sol";
import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {EIP712} from "@openzeppelin/contracts_latest/utils/cryptography/draft-EIP712.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IERC20Permit} from "@openzeppelin/contracts_latest/token/ERC20/extensions/draft-IERC20Permit.sol";
import {SignatureChecker} from "@openzeppelin/contracts_latest/utils/cryptography/SignatureChecker.sol";

string constant NAME = "GenericGateway";
string constant VERSION = "1";

/**
 * Feeless payment generic gateway
 *
 */
contract GenericGateway is Context, EIP712, ERC165, IGenericGateway {
    /**
     * Typehash to use for signing permit executions
     *
     */
    bytes32 private constant _EXECUTE_PERMIT_TYPEHASH =
        keccak256(bytes("execute(PermitVoucher{address,address,uint256,uint256,uint256,uint256,uint256,uint256,uint256})"));

    /**
     * Typehash to use for signing transfer executions
     *
     */
    bytes32 private constant _EXECUTE_TRANSFER_TYPEHASH = keccak256(bytes("execute(TransferVoucher{address,address,address,uint256,uint256,uint256,uint256})"));

    /**
     * Typehash to use for signing permit-and-transfer executions
     *
     */
    bytes32 private constant _EXECUTE_PERMIT_AND_TRANSFER_TYPEHASH =
        keccak256(bytes("execute(PermitAndTransferVoucher{address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,uint256})"));

    /**
     * Mapping, from transaction hash to true/false, set upon a transaction being executed
     *
     */
    mapping(bytes32 => bool) public transactionDone;

    /**
     * Construct the EIP712 component
     *
     */
    constructor() EIP712(NAME, VERSION) {}

    /**
     * Implementation of the IERC165 interface
     *
     * @param interfaceId  Interface ID to check against
     * @return  Whether the provided interface ID is supported
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IGenericGateway).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * Return the hash of the permit voucher used by execute()
     *
     * @param permitVoucher  The permit voucher with the transaction details
     * @return transactionHash  The hash of the permit voucher used by execute()
     */
    function getTransactionHash(PermitVoucher memory permitVoucher) external view returns (bytes32 transactionHash) {
        transactionHash = _getTransactionHash(permitVoucher);
    }

    /**
     * Return the hash of the transfer voucher used by execute()
     *
     * @param transferVoucher  The transfer voucher with the transaction details
     * @return transactionHash  The hash of the transfer voucher used by execute()
     */
    function getTransactionHash(TransferVoucher memory transferVoucher) external view returns (bytes32 transactionHash) {
        transactionHash = _getTransactionHash(transferVoucher);
    }

    /**
     * Return the hash of the permit-and-transfer voucher used by execute()
     *
     * @param permitAndTransferVoucher  The permit-and-transfer voucher with the transaction details
     * @return transactionHash  The hash of the permit-and-transfer voucher used by execute()
     */
    function getTransactionHash(PermitAndTransferVoucher memory permitAndTransferVoucher) external view returns (bytes32 transactionHash) {
        transactionHash = _getTransactionHash(permitAndTransferVoucher);
    }

    /**
     * Execute a pre-signed permit transaction
     *
     * The fee will be given to sender --- if it's a smart contract make sure it can accept funds.
     *
     * @param permitVoucher  The permit voucher with the transaction details
     * @param signature  The signature, issued by the funds' owner
     * @custom:emit  TransactionExecuted
     */
    function execute(PermitVoucher memory permitVoucher, bytes memory signature) external {
        _validateTransaction(permitVoucher.owner, _getTransactionHash(permitVoucher), signature);

        IERC20Permit(permitVoucher.token).permit(
            permitVoucher.owner,
            address(this),
            permitVoucher.amount,
            permitVoucher.deadline,
            permitVoucher.v,
            permitVoucher.r,
            permitVoucher.s
        );

        if (0 != permitVoucher.fee) {
            IERC20(permitVoucher.token).transferFrom(permitVoucher.owner, _msgSender(), permitVoucher.fee);
        }

        _emit(permitVoucher.token, permitVoucher.nonce);
    }

    /**
     * Execute a pre-signed transfer transaction
     *
     * The fee will be given to sender --- if it's a smart contract make sure it can accept funds.
     *
     * @param transferVoucher  The transfer voucher with the transaction details
     * @param signature  The signature, issued by the funds' owner
     * @custom:emit  TransactionExecuted
     */
    function execute(TransferVoucher memory transferVoucher, bytes memory signature) external {
        require(block.timestamp <= transferVoucher.deadline, "Gateway: expired deadline");

        _validateTransaction(transferVoucher.from, _getTransactionHash(transferVoucher), signature);

        IERC20(transferVoucher.token).transferFrom(transferVoucher.from, transferVoucher.to, transferVoucher.amount);

        if (0 != transferVoucher.fee) {
            IERC20(transferVoucher.token).transferFrom(transferVoucher.from, _msgSender(), transferVoucher.fee);
        }

        _emit(transferVoucher.token, transferVoucher.nonce);
    }

    /**
     * Execute a pre-signed permit-and-transfer transaction
     *
     * The fee will be given to sender --- if it's a smart contract make sure it can accept funds.
     *
     * @param permitAndTransferVoucher  The permit-and-transfer voucher with the transaction details
     * @param signature  The signature, issued by the funds' owner
     * @custom:emit  TransactionExecuted
     */
    function execute(PermitAndTransferVoucher memory permitAndTransferVoucher, bytes memory signature) external {
        _validateTransaction(permitAndTransferVoucher.from, _getTransactionHash(permitAndTransferVoucher), signature);

        IERC20Permit(permitAndTransferVoucher.token).permit(
            permitAndTransferVoucher.from,
            address(this),
            permitAndTransferVoucher.amount,
            permitAndTransferVoucher.deadline,
            permitAndTransferVoucher.v,
            permitAndTransferVoucher.r,
            permitAndTransferVoucher.s
        );
        IERC20(permitAndTransferVoucher.token).transferFrom(permitAndTransferVoucher.from, permitAndTransferVoucher.to, permitAndTransferVoucher.amount);

        if (0 != permitAndTransferVoucher.fee) {
            IERC20(permitAndTransferVoucher.token).transferFrom(permitAndTransferVoucher.from, _msgSender(), permitAndTransferVoucher.fee);
        }

        _emit(permitAndTransferVoucher.token, permitAndTransferVoucher.nonce);
    }

    /**
     * Validate the given transaction and mark it as served
     *
     * @param signer  The funds' owner address, signing the transaction voucher
     * @param transactionHash  The transaction voucher's hash
     * @param signature  The signature of the transaction hash by the signer
     */
    function _validateTransaction(
        address signer,
        bytes32 transactionHash,
        bytes memory signature
    ) internal {
        require(SignatureChecker.isValidSignatureNow(signer, transactionHash, signature), "GenericGateway: invalid signature");
        require(transactionDone[transactionHash] == false, "GenericGateway: transaction already executed");

        transactionDone[transactionHash] = true;
    }

    /**
     * Emit a `TransactionExecuted` event, setting the correct delegate
     *
     * @param token  The token this transaction applies to
     * @param nonce  The transaction's nonce used
     */
    function _emit(address token, uint256 nonce) internal {
        emit TransactionExecuted(token, nonce, _msgSender());
    }

    /**
     * Calculate the transaction hash for the given permit voucher
     *
     * @param permitVoucher  The permit voucher with the transaction details
     * @return transactionHash  The calculated transaction hash
     */
    function _getTransactionHash(PermitVoucher memory permitVoucher) internal view returns (bytes32 transactionHash) {
        transactionHash = _hashTypedDataV4(keccak256(abi.encode(_EXECUTE_PERMIT_TYPEHASH, permitVoucher)));
    }

    /**
     * Calculate the transaction hash for the given transfer voucher
     *
     * @param transferVoucher  The transfer voucher with the transaction details
     * @return transactionHash  The calculated transaction hash
     */
    function _getTransactionHash(TransferVoucher memory transferVoucher) internal view returns (bytes32 transactionHash) {
        transactionHash = _hashTypedDataV4(keccak256(abi.encode(_EXECUTE_TRANSFER_TYPEHASH, transferVoucher)));
    }

    /**
     * Calculate the transaction hash for the given permit-and-transfer voucher
     *
     * @param permitAndTransferVoucher  The permit-and-transfer voucher with the transaction details
     * @return transactionHash  The calculated transaction hash
     */
    function _getTransactionHash(PermitAndTransferVoucher memory permitAndTransferVoucher) internal view returns (bytes32 transactionHash) {
        transactionHash = _hashTypedDataV4(keccak256(abi.encode(_EXECUTE_PERMIT_AND_TRANSFER_TYPEHASH, permitAndTransferVoucher)));
    }
}
