
* It uses the Proxy Design Pattern for upgradability:
      * There is a main contract for the logic and another one to be invoked by the dApp frontend.
      * The ProofOfLifeProxy contract stores the address of the last deployed instance of ProofOfLife.
      * The proxy uses delegateCall to execute the logic from the other contract while updating its internal stored status.
      
* As specified in the "avoiding_common_attacks.md" file, a Circuit Breaker (to pause contract functionality) has been included in the Solidity implementation.

* All the contract's functions include modifiers as security constraints. Inheritance and the use of different contracts allows the dApp to have clear and structured code, with proper documentation and easy-to-read functions. Rather than using external libraries I haved considered more appropiated to use different contracts to implement different functionalities.

* There are not payable functions so the Withdrawal pattern has not been used. However, there is a differenciation between the functions used to update the status of the contract and the ones to access it. 