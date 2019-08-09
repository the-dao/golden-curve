pragma solidity 0.4.24;

contract IBondingCurve {
    function calculatePurchaseReturn(uint256 _supply, uint256 _coefficient, uint256 _n, uint256 _tokenAmount) public view returns (uint256);
    function calculateSaleReturn(uint256 _supply, uint256 _coefficient,  uint256 _n, uint256 _liquidityRatio, uint256 _sellAmount) public view returns (uint256);
}