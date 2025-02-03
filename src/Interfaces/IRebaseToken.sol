//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IRebaseToken {
    function mint(address _to, uint256 _amount) external;
    function burn(address _from, uint256 _amount) external;
    function balanceOf(address _account) external view returns (uint256);
    // function setInterestRate(uint256 _newInterestRate) external;
    // function grantMintAndBurnRole(address _account) external;
    // function getRebaseTokenAddress() external view returns (address);
}
