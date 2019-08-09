pragma solidity ^0.4.24;

import "./StandardToken.sol";
import "./interfaces/IBondingCurve.sol";
import "@aragon/os/contracts/lib/math/SafeMath.sol";

contract DAOToken is StandardToken {
    using SafeMath for uint256;

	address owner;

	// the supply at which the curve begins
	uint256 curveStart;

    // tokens per 90 degree turn
    uint256 n = 31250;

    // block heights for adjustment factor
    uint32 d1 = 89000;
    uint32 d2 = 178000;
    uint32 d3 = 267000;
    uint32 d4 = 534000;

    uint256 deploymentBlock;
    uint256 coefficient = 50;

    uint256 currentEtherPrice;

    bool reachedThreshold;

    IBondingCurve curve;

	event Mint(address _to, uint256 _amount);

	constructor() {
		owner = msg.sender;
        deploymentBlock = block.number;
	}

	function initialize(IBondingCurve _curve) public {
		require(msg.sender == owner);
		curve = _curve;
	}

    function updateCoefficient() public returns (uint256) {
        if (block.number > deploymentBlock + d4) {
            coefficient = 89;
            reachedThreshold = true;
            curveStart = totalSupply_;
            n = curveStart.mul(4).div(90);
            return coefficient;
        }

        if (block.number > deploymentBlock + d3) {
            coefficient = 85;
            return coefficient;
        }

        if (block.number > deploymentBlock + d2) {
            coefficient = 77;
            return coefficient;
        }

        if (block.number > deploymentBlock + d1) {
            coefficient = 65;
            return coefficient;
        }

        return coefficient;
    }

	// requestMint requests a certain amount of tokens to be minted
	// if the msg.value is enough to cover the price of the tokens, then the tokens are minted and 
	// added to the msg.sender's balance. any leftover ether is returned.
	// return the cost of the token purchase
	function requestMint(uint256 _amount) public payable returns (uint256) {
		if (!reachedThreshold) {
			return _amount * coefficient;
		}

		uint256 usdCost = curve.calculatePurchaseReturn(totalSupply_.sub(curveStart), coefficient, n, _amount);
		uint256 weiCost = usdCost.mul(10**18).div(currentEtherPrice);

		if (msg.value >= weiCost) {
			mint(msg.sender, _amount);
			msg.sender.transfer(msg.value.sub(weiCost));
		} else {
			revert("not enough value sent to purchase requested token amount");
		}

		return weiCost;
	}

	modifier hasMintPermission() {
		require(msg.sender == owner);
		_;
	}

	/**
	* @dev Function to mint tokens
	* @param _to The address that will receive the minted tokens.
	* @param _amount The amount of tokens to mint.
	* @return A boolean that indicates if the operation was successful.
	*/
	function mint(
		address _to,
		uint256 _amount
	) public hasMintPermission returns (bool) {
		totalSupply_ = totalSupply_.add(_amount);
		balances[_to] = balances[_to].add(_amount);
		emit Mint(_to, _amount);
		emit Transfer(address(0), _to, _amount);
		return true;
	}

}
