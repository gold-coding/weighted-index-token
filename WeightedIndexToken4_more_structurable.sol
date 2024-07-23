// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title PriceFeed
 * @dev This contract manages the mock price feeds for tokens.
 */
contract PriceFeed is AccessControl {
    bytes32 public constant FEEDER_ROLE = keccak256("FEEDER_ROLE");
    mapping(address => uint256) public prices;
    
    event PriceUpdated(address indexed token, uint256 newPrice);

    constructor() {
        grantRole(FEEDER_ROLE, msg.sender);
    }

    function updatePrice(address token, uint256 newPrice) public onlyRole(FEEDER_ROLE) {
        prices[token] = newPrice;
        emit PriceUpdated(token, newPrice);
    }
}

/**
 * @title TokenWeightManager
 * @dev Manages weights of tokens in the index.
 */
contract TokenWeightManager is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    struct Token {
        address tokenAddress;
        uint256 weight;
    }
    Token[2] public tokens;

    event WeightsRebalanced(uint256 newWeightToken1, uint256 newWeightToken2);

    constructor(address _token1, uint256 _weight1, address _token2, uint256 _weight2) {
        require(_weight1 + _weight2 == 100, "Total weight must be 100%");
        tokens[0] = Token(_token1, _weight1);
        tokens[1] = Token(_token2, _weight2);
        grantRole(ADMIN_ROLE, msg.sender);
    }

    function rebalance(uint256 newWeight1, uint256 newWeight2) public onlyRole(ADMIN_ROLE) {
        require(newWeight1 + newWeight2 == 100, "Total weight must be 100%");
        tokens[0].weight = newWeight1;
        tokens[1].weight = newWeight2;
        emit WeightsRebalanced(newWeight1, newWeight2);
    }
}

/**
 * @title WeightedIndex
 * @dev ERC20 token that represents a weighted index of 2 cryptocurrencies.
 */
contract WeightedIndex is ERC20, TokenWeightManager, PriceFeed {
    constructor(
        address _token1,
        uint256 _weight1,
        address _token2,
        uint256 _weight2
    ) ERC20("WeightedIndexToken", "WIT") TokenWeightManager(_token1, _weight1, _token2, _weight2) {}

    function calculateIndexValue() public view returns (uint256) {
        uint256 totalValue = 0;
        for (uint i = 0; i < tokens.length; i++) {
            totalValue += prices[tokens[i].tokenAddress] * tokens[i].weight / 100;
        }
        return totalValue;
    }

    function mint(address to, uint256 amount) public onlyRole(ADMIN_ROLE) {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyRole(ADMIN_ROLE) {
        _burn(from, amount);
    }
}


///////*

Explanation

/////Key Structural Improvements

-Separation into Modules: The functionalities related to price feeds and token weights are split into separate contracts (PriceFeed and TokenWeightManager). This modular approach allows for clearer management of different aspects of the index and could aid in future expansions or modifications.

-Role-Based Access Control: Both price updates and token weight rebalancing are protected by role-based permissions, ensuring that only authorized parties can perform these actions.

-Event Enhancements: Events are improved to include indexed parameters where appropriate, enhancing the ability to filter and search for specific events.

-Inheritance: The main contract (WeightedIndex) inherits from both TokenWeightManager and PriceFeed, consolidating the management of tokens and prices into a single token that also acts as an ERC20 token.

-Centralized Management: Having a single entry point (WeightedIndex) that inherits functionalities ensures that the state and control are centralized, reducing the complexity of interactions between separate contracts.

These enhancements focus on clean separation of concerns, which not only helps in maintaining and auditing the code but also makes the system more robust and secure.


*///////