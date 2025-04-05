// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public creator; // যে ক্যাম্পেইন শুরু করেছে
    uint public goal; // টার্গেট পরিমাণ (wei তে)
    uint public deadline; // শেষ তারিখ (সেকেন্ডে)
    uint public totalRaised; // মোট জমা হওয়া টাকা
    mapping(address => uint) public contributions; // কে কত দিয়েছে
    bool public isFunded; // টাকা তোলা হয়েছে কি না

    // ইভেন্ট ডিফাইন করা
    event ContributionMade(address contributor, uint amount);
    event GoalReached(uint totalRaised);
    event FundsWithdrawn(address creator, uint amount);

    constructor(uint _goal, uint _durationInMinutes) {
        creator = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInMinutes * 60);
        totalRaised = 0;
        isFunded = false;
    }

    // ইথার দিয়ে ফান্ড করার ফাংশন
    function contribute() public payable {
        require(block.timestamp < deadline, "ক্যাম্পেইন শেষ হয়ে গেছে!");
        require(msg.value > 0, "কিছু ইথার পাঠাতে হবে!");
        require(totalRaised < goal, "টার্গেট ইতিমধ্যে পূরণ হয়েছে!");

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        emit ContributionMade(msg.sender, msg.value); // ইভেন্ট ট্রিগার

        if (totalRaised >= goal) {
            emit GoalReached(totalRaised);
        }
    }

    // ক্রিয়েটর টাকা তুলে নেওয়ার ফাংশন
    function withdrawFunds() public {
        require(msg.sender == creator, "শুধু ক্রিয়েটর টাকা তুলতে পারবে!");
        require(totalRaised >= goal, "টার্গেট পূরণ হয়নি!");
        require(block.timestamp >= deadline, "ডেডলাইনের আগে টাকা তোলা যাবে না!");
        require(!isFunded, "টাকা ইতিমধ্যে তোলা হয়েছে!");

        isFunded = true;
        uint amount = address(this).balance;
        (bool sent, ) = creator.call{value: amount}("");
        require(sent, "ইথার পাঠাতে ব্যর্থ হয়েছে!");

        emit FundsWithdrawn(creator, amount);
    }

    // বর্তমান ব্যালেন্স চেক করার ফাংশন
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
