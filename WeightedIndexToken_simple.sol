// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WeightedIndex is ERC20 {
    struct Token {
        address tokenAddress;
        uint256 weight; // Weight is a percentage represented as an integer (e.g., 50 for 50%)
    }

    Token[2] public tokens;
    mapping(address => uint256) public prices; // Mock price feeds

    event Rebalanced(uint256 newWeightToken1, uint256 newWeightToken2);
    event PriceUpdated(address token, uint256 newPrice);

    constructor(
        address _token1,
        uint256 _weight1,
        address _token2,
        uint256 _weight2
    ) ERC20("WeightedIndexToken", "WIT"){
        require(_weight1 + _weight2 == 100, "Total weight must be 100%");
        tokens[0] = Token(_token1, _weight1);
        tokens[1] = Token(_token2, _weight2);
    }

    // Function to update token prices (mock function)
    function updatePrice(address token, uint256 newPrice) public {
        prices[token] = newPrice;
        emit PriceUpdated(token, newPrice);
    }

    // Calculate the current index value based on token prices and weights
    function calculateIndexValue() public view returns (uint256) {
        uint256 totalValue = 0;
        for (uint i = 0; i < tokens.length; i++) {
            totalValue += prices[tokens[i].tokenAddress] * tokens[i].weight / 100;
        }
        return totalValue;
    }

    // Rebalancing the weights of the tokens
    function rebalance(uint256 newWeight1, uint256 newWeight2) public {
        require(newWeight1 + newWeight2 == 100, "Total weight must be 100%");
        tokens[0].weight = newWeight1;
        tokens[1].weight = newWeight2;
        emit Rebalanced(newWeight1, newWeight2);
    }

    // Mint index tokens
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    // Burn index tokens
    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}


///* 

Explanation
-ERC20 Implementation: The contract inherits from OpenZeppelin's ERC20 contract to manage the ERC20 functionality easily.
-Token Struct: Each token in the index is represented by a struct containing the token's address and its weight.
-Price Feeds: Prices are stored in a mapping and can be updated through the updatePrice function. This simplifies the mock-up aspect for demonstration purposes.
-Index Calculation: The calculateIndexValue function computes the weighted value of the index based on current prices.
-Rebalancing: The rebalance function allows adjustment of token weights, ensuring they sum to 100%.
-Minting/Burning: Functions to mint or burn tokens allow control over the supply of the index token, mimicking the issuance or redemption process in real index funds.
-Events: Events such as Rebalanced and PriceUpdated help in logging and tracking changes in the contract states.

Suggestions for this code
-Integration with Real Price Feeds: In a production environment, integrate with real price feeds using oracles (e.g., Chainlink).
-Access Control: Implement roles for functions like rebalancing or minting to restrict who can perform these actions.
-Advanced Error Handling: More sophisticated error handling can be added to manage edge cases and unexpected inputs.

*/////