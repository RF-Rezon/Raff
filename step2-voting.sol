// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    // ভোটারদের ট্র্যাক করার জন্য ম্যাপিং
    mapping(address => bool) public hasVoted;
    // প্রার্থীদের ভোট কাউন্ট করার জন্য ম্যাপিং
    mapping(string => uint) public voteCount;
    // প্রার্থীদের লিস্ট
    string[] public candidates;

    constructor(string[] memory _candidates) {
        candidates = _candidates;
    }

    // ভোট দেওয়ার ফাংশন
    function vote(string memory _candidate) public {
        // চেক করো ভোটার আগে ভোট দিয়েছে কি না
        require(!hasVoted[msg.sender], "তুমি আগেই ভোট দিয়েছো!");
        // চেক করো প্রার্থী বৈধ কি না
        require(isValidCandidate(_candidate), "এই প্রার্থী লিস্টে নেই!");
        
        hasVoted[msg.sender] = true;
        voteCount[_candidate] += 1;
    }

    // প্রার্থী বৈধ কি না চেক করার ফাংশন
    function isValidCandidate(string memory _candidate) private view returns (bool) {
        for (uint i = 0; i < candidates.length; i++) {
            if (keccak256(abi.encodePacked(candidates[i])) == keccak256(abi.encodePacked(_candidate))) {
                return true;
            }
        }
        return false;
    }

    // কোন প্রার্থীর কত ভোট আছে দেখার ফাংশন
    function getVoteCount(string memory _candidate) public view returns (uint) {
        require(isValidCandidate(_candidate), "এই প্রার্থী লিস্টে নেই!");
        return voteCount[_candidate];
    }

    // সব প্রার্থীর লিস্ট দেখার ফাংশন
    function getCandidates() public view returns (string[] memory) {
        return candidates;
    }
}
