* Restricting Access with modifiers
    * It includes a CredentialsConstrained contract (inherited by all the contracts) to add constraints to ownerOnly or authorizedUsers
    * It incorporates the functions isOpenToEveryUser and isClosedToAuthorized users for specific cases
    * It includes the possibility of removing credentials of existing users (only allowed to the contract owner).
    * All modifiers include the _; at the end


* Circuit Breaker:
    * It includes a Lockable contract (inherited by all the contracts) to freeze the instance in case of a bug or a security alert.
    * It allows the dApp owner to stop the execution of future state updates while keeping the read-only functions still available.
    * The use of modifiers allows to customize which functions are "frozen" and which ones are not if the contract has been locked.
    * Only the contract owner can lock/unlock it.
