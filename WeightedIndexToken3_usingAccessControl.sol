// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract WeightedIndex is ERC20, AccessControl {
    struct Token {
        address tokenAddress;
        uint256 weight;
    }

    Token[2] public tokens;
    mapping(address => uint256) public prices;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PRICE_FEEDER_ROLE = keccak256("PRICE_FEEDER_ROLE");

    event Rebalanced(uint256 newWeightToken1, uint256 newWeightToken2);
    event PriceUpdated(address token, uint256 newPrice);

    constructor(
        address _token1,
        uint256 _weight1,
        address _token2,
        uint256 _weight2
    ) ERC20("WeightedIndexToken", "WIT") {
        require(_weight1 + _weight2 == 100, "Total weight must be 100%");
        tokens[0] = Token(_token1, _weight1);
        tokens[1] = Token(_token2, _weight2);
        
        grantRole(ADMIN_ROLE, msg.sender);
        grantRole(PRICE_FEEDER_ROLE, msg.sender);
    }

    function updatePrice(address token, uint256 newPrice) public onlyRole(PRICE_FEEDER_ROLE) {
        prices[token] = newPrice;
        emit PriceUpdated(token, newPrice);
    }

    function calculateIndexValue() public view returns (uint256) {
        uint256 totalValue = 0;
        for (uint i = 0; i < tokens.length; i++) {
            totalValue += prices[tokens[i].tokenAddress] * tokens[i].weight / 100;
        }
        return totalValue;
    }

    function rebalance(uint256 newWeight1, uint256 newWeight2) public onlyRole(ADMIN_ROLE) {
        require(newWeight1 + newWeight2 == 100, "Total weight must be 100%");
        tokens[0].weight = newWeight1;
        tokens[1].weight = newWeight2;
        emit Rebalanced(newWeight1, newWeight2);
    }

    function mint(address to, uint256 amount) public onlyRole(ADMIN_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyRole(ADMIN_ROLE) {
        _burn(from, amount);
    }
}


//////*
Explanation

Key Changes:
-AccessControl: This contract now uses OpenZeppelin's AccessControl for role-based permissions.
-Security Roles: Defined roles for administrative actions and price updates.
-Enhanced Events: Events still log the same information, consider adding more details if required.

According to demands, Roles can be separate by several addresses for security.

*/////
