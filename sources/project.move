module MyModule::SimpleVoting {
    use aptos_framework::signer;
    
    /// Struct representing a voting poll
    struct Poll has store, key {
        yes_votes: u64,    // Number of yes votes
        no_votes: u64,     // Number of no votes
        topic: vector<u8>, // Poll topic/question
    }
    
    /// Struct to track if user has already voted
    struct VoterRecord has store, key {
        has_voted: bool,
    }
    
    /// Function to create a new poll
    public fun create_poll(creator: &signer, topic: vector<u8>) {
        let poll = Poll {
            yes_votes: 0,
            no_votes: 0,
            topic,
        };
        move_to(creator, poll);
    }
    
    /// Function to cast a vote on a poll
    public fun cast_vote(
        voter: &signer, 
        poll_owner: address, 
        vote_yes: bool
    ) acquires Poll, VoterRecord {
        let voter_addr = signer::address_of(voter);
        
        // Check if voter has already voted
        if (exists<VoterRecord>(voter_addr)) {
            let voter_record = borrow_global<VoterRecord>(voter_addr);
            assert!(!voter_record.has_voted, 1); // Error if already voted
        } else {
            // Create voter record if doesn't exist
            let voter_record = VoterRecord { has_voted: false };
            move_to(voter, voter_record);
        };
        
        // Update poll with the vote
        let poll = borrow_global_mut<Poll>(poll_owner);
        if (vote_yes) {
            poll.yes_votes = poll.yes_votes + 1;
        } else {
            poll.no_votes = poll.no_votes + 1;
        };
        
        // Mark voter as having voted
        let voter_record = borrow_global_mut<VoterRecord>(voter_addr);
        voter_record.has_voted = true;
    }
}