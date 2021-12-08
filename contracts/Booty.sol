pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IBooty.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Booty is  ERC20, Ownable {
    using SafeMath for uint256;

    uint256 private immutable _cap = 1e27;

    // Allowlist of addresses to mint or burn
    mapping(address => bool) public controllers;

    constructor() ERC20("Booty", "$BOOTY") {}

    /**
     * @dev Returns the cap on the token's total supply.
    */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * Mint $BOOTY to a recipient.
     * @param to the recipient of the $BOOTY
    * @param amount the amount of $BOOTY to mint
    */
    function mint(address to, uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can mint");

        if (ERC20.totalSupply().add(amount) > cap()) {
            uint256 lastMintableAmount = ERC20.totalSupply().add(amount) - cap();
            super._mint(to, lastMintableAmount);
        }

        if (ERC20.totalSupply().add(amount) <= cap()) {
            super._mint(to, amount);
        }
    }

    /**
     * Burn $BOOTY from a holder.
     * @param from the holder of the $BOOTY
     * @param amount the amount of $BOOTY to burn
     */
    function burn(address from, uint256 amount) external {
        require(controllers[msg.sender], "Only controllers can burn");
        _burn(from, amount);
    }

    /**
     * Enables an address to mint / burn.
     * @param controller the address to enable
    */
    function addController(address controller) external onlyOwner {
        controllers[controller] = true;
    }

    /**
     * Disables an address from minting / burning.
     * @param controller the address to disbale
    */
    function removeController(address controller) external onlyOwner {
        controllers[controller] = false;
    }
}
