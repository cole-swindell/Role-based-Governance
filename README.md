🏛️ Role-Based Governance Smart Contract

Overview

This Clarity smart contract implements a role-based governance system where participants have different voting powers depending on their assigned roles — Builders, Designers, and Marketers. It allows decentralized decision-making through proposal creation, voting, and execution, while ensuring transparent governance logic on-chain.

🔧 Key Features

🧩 Role Management

Roles Defined:

Builder (u3) → 3 voting power

Designer (u2) → 2 voting power

Marketer (u1) → 1 voting power

Only the contract owner can assign roles to users.

Roles determine how much influence a user’s vote carries.

🗳️ Proposals

Any user with a role can create a proposal by providing:

A title (up to 100 characters)

A description (up to 500 characters)

A voting period (up to 1440 blocks)

The proposal stores:

Title, description, proposer, yes/no votes, voting end block, and execution status.

✅ Voting

Only users with assigned roles can vote.

Voting power is proportional to their role weight.

Each user can vote once per proposal.

Votes are only accepted before the proposal’s end block.

Votes are tracked via a (proposal-id, voter) key pair to prevent duplicates.

🧮 Proposal Results

Anyone can view the proposal’s:

Title, description, votes, and proposer.

Current result: "PASSED" or "FAILED" (based on vote counts).

⚙️ Execution

Only the contract owner can execute a proposal.

Execution is allowed after voting has ended, if the proposal passed, and if not already executed.

The current version includes a placeholder for execution logic (custom actions can be added later).

📚 Data Structures
Type	Name	Description
data-var	proposal-counter	Tracks the total number of proposals
map	user-roles	Maps user principal → role power
map	proposals	Stores proposal metadata
map	votes	Tracks users who have voted per proposal

📤 Public Functions

Function	Description
(assign-role (user principal) (role uint))	Assign a role (Builder/Designer/Marketer) to a user. Owner-only.
(create-proposal (title ...) (description ...) (voting-period uint))	Create a new proposal with a defined voting duration.
(vote (proposal-id uint) (vote-yes bool))	Cast a vote on a proposal (true for yes, false for no`).
(execute-proposal (proposal-id uint))	Execute a passed proposal (owner-only).

👁️ Read-Only Functions

Function	Description
(get-user-role (user principal))	Returns the user’s assigned role.
(get-voting-power (user principal))	Returns the user’s voting weight.
(get-proposal (proposal-id uint))	Retrieves proposal details.
(has-voted (proposal-id uint) (voter principal))	Checks if a user has voted.
(get-proposal-result (proposal-id uint))	Returns "PASSED" or "FAILED" if voting is complete.
(get-total-proposals)	Returns the total number of created proposals.

🚨 Error Codes

Error	Code	Description
err-owner-only	u100	Action restricted to contract owner
err-unauthorized	u101	User not allowed to perform this action
err-invalid-role	u102	Invalid or missing role input
err-proposal-not-found	u103	Proposal ID does not exist
err-already-voted	u104	User has already voted
err-voting-ended	u105	Voting period has ended
🧠 Example Workflow

Owner assigns roles:

(contract-call? .governance assign-role 'ST123... u3) ;; Assign Builder


Builder creates a proposal:

(contract-call? .governance create-proposal "New Feature" "Add community chat" u120)


Users vote:

(contract-call? .governance vote u1 true)


Owner executes a passed proposal:

(contract-call? .governance execute-proposal u1)

🗂️ License
This contract is released under the MIT License.