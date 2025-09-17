pragma solidity ^0.8.20;

contract Voting {
    mapping(address => bool) members;

    constructor(address[] memory _members) {
        for(uint i = 0; i < _members.length; i++) {
            members[_members[i]] = true;
        }
        members[msg.sender] = true;
    }
    
    enum VoteStates {Absent, Yes, No}

    struct Proposal {
        address target;
        bytes data;
        uint yesCount;
        uint noCount;
        bool executed;
        mapping (address => VoteStates) voteStates;
    }
    
    Proposal[] public proposals;
    event ProposalCreated(uint _proposalId);
    event VoteCast(uint _proposalId, address voter);
    
    function newProposal(address _target, bytes calldata _data) external {
        require(members[msg.sender]);
        Proposal storage proposal = proposals.push();
        proposal.target = _target;
        proposal.data = _data;
        emit ProposalCreated(proposals.length - 1);
    }

    function castVote(uint _proposalId, bool _supports) external {
        require(members[msg.sender]);
        Proposal storage proposal = proposals[_proposalId];

        
        if(proposal.voteStates[msg.sender] == VoteStates.Yes) {
            proposal.yesCount--;
        }
        if(proposal.voteStates[msg.sender] == VoteStates.No) {
            proposal.noCount--;
        }

       
        if(_supports) {
            proposal.yesCount++;
        }
        else {
            proposal.noCount++;
        }

        
        proposal.voteStates[msg.sender] = _supports ? VoteStates.Yes : VoteStates.No;
        emit VoteCast(_proposalId, msg.sender);

        if(proposal.yesCount == 10 && !proposal.executed) {
            (bool s, ) = proposal.target.call(proposal.data);
            require(s);
        }
    }
}