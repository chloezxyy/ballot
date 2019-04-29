/**
 * @file ballot.sol
 * @author Jackson Ng <jacksonn@tp.edu.sg>
 * @date 22nd Apr 2019
 */

pragma solidity ^0.5.0;

contract Ballot {

    struct vote{
        address voterAddress;
        bool choice;
    }
    
    struct voter{
        string voterName;
        bool voted;
    }

    uint public countResult = 0;
    uint public totalVoter = 0;
    uint public totalVote = 0;
    address public ballotOfficialAddress;      
    string public ballotOfficialName;
    string public proposal;
    
    mapping(uint => vote) votes;
    mapping(address => voter) voterRegister;
    
    enum State { Created, Voting, Ended }
	State public state;
	
	//creates a new ballot contract
	constructor(
        string memory _ballotOfficialName,
        string memory _proposal) public {
        ballotOfficialAddress = msg.sender;
        ballotOfficialName = _ballotOfficialName;
        proposal = _proposal;
        
        state = State.Created;
    }
    
    
	modifier condition(bool _condition) {
		require(_condition);
		_;
	}

	modifier onlyOfficial() {
		require(msg.sender ==ballotOfficialAddress);
		_;
	}

	modifier inState(State _state) {
		require(state == _state);
		_;
	}

    event voterAdded();
    event voteStarted();
    event voteCounted();
    event voteDone();

    //add voter
    function addVoter(address _voterAddress, string memory _voterName)
        public
        inState(State.Created)
        onlyOfficial
    {
        voter memory v;
        v.voterName = _voterName;
        v.voted = false;
        voterRegister[_voterAddress] = v;
        totalVoter++;
        emit voterAdded();
    }

    //declare voting starts now
    function startVote()
        public
        inState(State.Created)
        onlyOfficial
    {
        state = State.Voting;     
        emit voteStarted();
    }

    //voters vote by indicating their choice (true/false)
    function doVote(bool _choice)
        public
        inState(State.Voting)
        returns (bool voted)
    {
        bool found = false;
        
        //TODO Check if the name is found in vote register
        if (!voterRegister[msg.sender].voted){
            voterRegister[msg.sender].voted = true;
            vote memory v;
            v.voterAddress = msg.sender;
            v.choice = _choice;
            votes[totalVote] = v;
            totalVote++;
            found = true;
        }
        emit voteDone();
        return found;
    }
    
    //end and count votes
    function countVote()
        public
        inState(State.Voting)
        onlyOfficial
        returns (uint totalVotes)
    {
        uint myCount=0;
        
        state = State.Ended;
        for (uint i=0; i<totalVote; i++){
            if (votes[i].choice){
                myCount++;
            }
        }
        
        countResult = myCount;
        emit voteCounted();
        return myCount;
    }
}
