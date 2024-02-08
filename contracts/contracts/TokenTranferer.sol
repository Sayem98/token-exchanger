//SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/TOkenClaimer.sol




pragma solidity ^0.8.0;

/*
    @des This contract is token replaces for token A to tokenB
        you can send token A to this contract and get token B.
    @auther: Sayem Abedin
    @date: 2021-09-30

 */


interface ERC20{
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract TokenClaimer is Ownable{

    ERC20 tokenA; // token A
    ERC20 tokenB; // token B


    event Claimed(address claimer, uint256 amount);

    constructor(address _tokenA, address _tokenB) Ownable(msg.sender){
        tokenA = ERC20(_tokenA);
        tokenB = ERC20(_tokenB);
    }

    /*
    @des
        This function is used to claim token B by sending token A
    @params
        amount: amount of token A to send

    @req
        1. Claimer balance should be greater than the amount
        2. token A allowance should be greater than the amount
        3. token B allowance should be greater than the amount
    
     */

    function claimToken(uint256 amount) public {

        require(tokenA.balanceOf(msg.sender) >= amount, "You don't have enough token");
        // check allowance
        require(tokenA.allowance(msg.sender, address(this)) >= amount, "You don't have enough allowance");
        // transfer token A to this contract
        tokenA.transferFrom(msg.sender, address(this), amount);
        
        // transfer token B to claimer
        tokenB.transfer(msg.sender, amount);

        emit Claimed(msg.sender, amount);
    }

    function withdrawA(uint256 amount) public onlyOwner{
        require(tokenB.balanceOf(address(this)) >= amount, "Contract does not have enough token");
        tokenB.transfer(msg.sender, amount);
    }

    function withdrawB(uint256 amount) public onlyOwner{
        require(tokenA.balanceOf(address(this)) >= amount, "Contract does not have enough token");
        tokenA.transfer(msg.sender, amount);
    }

    function withdrawNative(address payable to, uint256 amount) public onlyOwner{
        require(address(this).balance >= amount, "Contract does not have enough token");
        to.transfer(amount);
    }


}