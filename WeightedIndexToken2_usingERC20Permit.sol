// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract WeightedIndex is ERC20, ERC20Permit {
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
    ) ERC20("WeightedIndexToken", "WIT") ERC20Permit("WeightedIndex") {
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
All functions are similar to previous implemenation.
For security ERC20Permit contract is added.

The permit function in the ERC-20 standard is an addition that comes from the EIP-2612 proposal, which extends the ERC-20 token standard to include permissionless token approvals using signatures. This feature allows users to approve a spender to transfer tokens on their behalf without requiring an on-chain transaction from the token holder themselves. Instead, the token holder signs a message containing the approval information, and the spender or a third party submits this signature to the blockchain.

function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
) external;

Parameters
owner: The address of the token holder giving the approval.
spender: The address which is being authorized to spend the tokens.
value: The number of tokens the spender is allowed to spend.
deadline: A timestamp until which the permit is valid. This helps in preventing replay attacks.
v, r, s: Components of the ECDSA signature. These values are generated when the token holder signs a set of data that includes the spender, the value, and a nonce.


-Signing the Data: The token owner signs a message that includes the spender’s address, the amount of tokens to be approved, a nonce (to prevent replay attacks), and the deadline. This signature is made according to EIP-712, which allows for readable signing messages.
-Submitting the Signature: A user (can be the spender or another party) calls the permit function with the owner's address, spender's address, value, deadline, and the signature (v, r, s).
-Validation: The contract then validates the signature, checks that the nonce is correct, and that the current time is before the deadline.
-Approval: If all checks pass, the contract updates the allowance mapping as if a regular approve call was made, enabling the spender to use the transferFrom method up to the allowed amount.

This method enhances user experience by reducing the need for multiple transactions and potentially lowering transaction fees, making interactions smoother in decentralized environments.
*//////