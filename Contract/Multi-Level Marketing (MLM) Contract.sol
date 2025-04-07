// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MLM {
    address public owner;
    uint public registrationFee = 0.01 ether;

    struct User {
        address referrer;
        uint256 referralsCount;
        uint256 totalEarned;
    }

    mapping(address => User) public users;
    mapping(address => bool) public registered;

    event Registered(address user, address referrer);
    event ReferralReward(address from, address to, uint256 amount);

    constructor() {
        owner = msg.sender;
        registered[owner] = true;
    }

    function register(address _referrer) external payable {
        require(!registered[msg.sender], "Already registered");
        require(registered[_referrer], "Referrer not registered");
        require(msg.value == registrationFee, "Incorrect registration fee");

        users[msg.sender] = User({
            referrer: _referrer,
            referralsCount: 0,
            totalEarned: 0
        });

        users[_referrer].referralsCount++;
        registered[msg.sender] = true;

        uint256 reward = (msg.value * 50) / 100;
        payable(_referrer).transfer(reward);
        users[_referrer].totalEarned += reward;

        emit Registered(msg.sender, _referrer);
        emit ReferralReward(msg.sender, _referrer, reward);
    }

    function getUserInfo(address _user) external view returns (address, uint256, uint256) {
        User memory user = users[_user];
        return (user.referrer, user.referralsCount, user.totalEarned);
    }

    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}

