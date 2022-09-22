// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * Feeless payment generic gateway
 *
 */
interface IGenericGateway {
    /**
     * Emitted upon realization of a pre-signed transaction (ANONYMOUS)
     *
     * @param token  The token being acted upon (INDEXED)
     * @param nonce  The pre-signed transaction nonce (INDEXED)
     * @param delegate  The address executing the transaction
     */
    event TransactionExecuted(address indexed token, uint256 indexed nonce, address delegate) anonymous;

    /**
     * Permit details
     *
     * @custom:member token  The token being acted upon
     * @custom:member owner  The address granting allowance
     * @custom:member amount  The number of tokens being allowed
     * @custom:member deadline  The maximum block timestamp this transaction is valid until
     * @custom:member v  The "v" part of an ERC20Permit signature
     * @custom:member r  The "r" part of an ERC20Permit signature
     * @custom:member s  The "s" part of an ERC20Permit signature
     * @custom:member fee  The number of tokens awarded to the delegate for executing the transaction
     * @custom:member nonce  The transaction nonce to use
     */
    struct PermitVoucher {
        address token;
        //
        address owner;
        uint256 amount;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
        //
        uint256 fee;
        uint256 nonce;
    }

    /**
     * Transfer details
     *
     * @custom:member token  The token being acted upon
     * @custom:member from  The address from whence to transfer funds
     * @custom:member to  The address where to transfer funds to
     * @custom:member amount  The number of tokens being transferred
     * @custom:member deadline  The maximum block timestamp this transaction is valid until
     * @custom:member fee  The number of tokens awarded to the delegate for executing the transaction
     * @custom:member nonce  The transaction nonce to use
     */
    struct TransferVoucher {
        address token;
        //
        address from;
        address to;
        uint256 amount;
        uint256 deadline;
        //
        uint256 fee;
        uint256 nonce;
    }

    /**
     * Permit-and-Transfer details
     *
     * @custom:member token  The token being acted upon
     * @custom:member from  The address from whence to transfer funds / granting allowance
     * @custom:member to  The address where to transfer funds to
     * @custom:member amount  The number of tokens being transferred / allowed
     * @custom:member deadline  The maximum block timestamp this transaction is valid until
     * @custom:member v  The "v" part of an ERC20Permit signature
     * @custom:member r  The "r" part of an ERC20Permit signature
     * @custom:member s  The "s" part of an ERC20Permit signature
     * @custom:member fee  The number of tokens awarded to the delegate for executing the transaction
     * @custom:member nonce  The transaction nonce to use
     */
    struct PermitAndTransferVoucher {
        address token;
        //
        address from;
        address to;
        uint256 amount;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
        //
        uint256 fee;
        uint256 nonce;
    }

    /**
     * Determine whether the given transaction hash has already been executed or not
     *
     * @param transactionHash  The hash of the payload used by transfer()
     * @return  Whether the given transfer has has already been processed or not
     */
    function transactionDone(bytes32 transactionHash) external view returns (bool);

    /**
     * Return the hash of the permit voucher used by execute()
     *
     * @param permitVoucher  The permit voucher with the transaction details
     * @return transactionHash  The hash of the permit voucher used by execute()
     */
    function getTransactionHash(PermitVoucher memory permitVoucher) external view returns (bytes32 transactionHash);

    /**
     * Return the hash of the transfer voucher used by execute()
     *
     * @param transferVoucher  The transfer voucher with the transaction details
     * @return transactionHash  The hash of the transfer voucher used by execute()
     */
    function getTransactionHash(TransferVoucher memory transferVoucher) external view returns (bytes32 transactionHash);

    /**
     * Return the hash of the permit-and-transfer voucher used by execute()
     *
     * @param permitAndTransferVoucher  The permit-and-transfer voucher with the transaction details
     * @return transactionHash  The hash of the permit-and-transfer voucher used by execute()
     */
    function getTransactionHash(PermitAndTransferVoucher memory permitAndTransferVoucher) external view returns (bytes32 transactionHash);

    /**
     * Execute a pre-signed permit transaction
     *
     * The fee will be given to sender --- if it's a smart contract make sure it can accept funds.
     *
     * @param permitVoucher  The permit voucher with the transaction details
     * @param signature  The signature, issued by the funds' owner
     * @custom:emit  TransactionExecuted
     */
    function execute(PermitVoucher memory permitVoucher, bytes memory signature) external;

    /**
     * Execute a pre-signed transfer transaction
     *
     * The fee will be given to sender --- if it's a smart contract make sure it can accept funds.
     *
     * @param transferVoucher  The transfer voucher with the transaction details
     * @param signature  The signature, issued by the funds' owner
     * @custom:emit  TransactionExecuted
     */
    function execute(TransferVoucher memory transferVoucher, bytes memory signature) external;

    /**
     * Execute a pre-signed permit-and-transfer transaction
     *
     * The fee will be given to sender --- if it's a smart contract make sure it can accept funds.
     *
     * @param permitAndTransferVoucher  The permit-and-transfer voucher with the transaction details
     * @param signature  The signature, issued by the funds' owner
     * @custom:emit  TransactionExecuted
     */
    function execute(PermitAndTransferVoucher memory permitAndTransferVoucher, bytes memory signature) external;
}
