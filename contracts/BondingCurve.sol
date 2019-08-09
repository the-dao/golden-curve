pragma solidity 0.4.24;

import './interfaces/IBondingCurve.sol';
import "@aragon/os/contracts/lib/math/SafeMath.sol";

contract BondingCurve is IBondingCurve {
    using SafeMath for uint256;

    function calculatePrice(uint256 _supply, uint256 _coefficient, uint256 _n) public view returns (uint256) {
        if (_supply == 0) {
            return _coefficient;
        }

        uint256 exp = _supply.div(_n);
        uint256 phi_exp = phiExp(exp);
        return _coefficient.mul(phi_exp).div(10**5);          
    }

    // calculates the price of purchasing _tokenAmount of DAO token starting at total supply
    // using the curve r(theta) = a*e^((2*ln(phi)/pi)*(theta - pi)
    // where theta is proportional to the token supply and radius is equivalent to the token price
    function calculatePurchaseReturn(uint256 _supply, uint256 _coefficient, uint256 _n, uint256 _tokenAmount) public view returns (uint256) {
        if (_supply == 0 && _tokenAmount == 1) {
            return _coefficient;
        }

        uint256 totalPrice;

        for (uint256 i = 0; i < _tokenAmount; i++) {
            uint256 price = calculatePrice(_supply + i, _coefficient, _n);
            totalPrice = totalPrice.add(price);
        }

        return totalPrice;
    }

    // liquidityRatio is a percent, divide by 100 for math
    function calculateSaleReturn(uint256 _supply, uint256 _coefficient, uint256 _n, uint256 _liquidityRatio, uint256 _sellAmount) public view returns (uint256) {
        if (_supply == 0 && _sellAmount == 1) {
            return _coefficient.mul(_liquidityRatio).div(100);
        }

        uint256 returnPrice;

        for (uint256 i = 0; i < _sellAmount; i++) {
            uint256 price = calculatePrice(_supply + i, _coefficient, _n);
            returnPrice = returnPrice.add(price).mul(_liquidityRatio).div(100);
        }
        return returnPrice;
    }

    // performs phi^x where phi = 1.618034 with precision 10^5
    function phiExp(uint256 x) public view returns (uint256) {
        if (x == 0) {
            return 100000;
        }

        uint256 top = uint256(161803) ** x;
        uint256 bottom = uint256(100000) ** (x-1);
        return top.div(bottom);
    }

    // performs e ^ x where e = 2.718281828 ~= 163/60
    function exp(uint256 x) public view returns (uint256) {
        uint256 top = 163 ** x;
        uint256 bottom = 60 ** x;
        return top.div(bottom);
    }
}