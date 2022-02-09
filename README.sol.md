# Solidity Ethereum

## Installing Summary

1. [Intalling Solidity Compiler](https://docs.soliditylang.org/en/v0.8.11/installing-solidity.html)
1. Solidity Compiler in JS (simple compiler): ``` solcjs --version ```
1. Solidity Compiler in C (**complete compiler, use it!**): ``` solc --version ```
1. Remix local installing: ``` npm i -g @remix-project/remixd ```
1. Remix server provider to open on browser: ``` remixd -s . ```
1. --> go to remix.ethereum.org --> change workspace to localhost --> click connect
1. REMIX WARNING: using JS VM we can do any interaction with the smart contract without paying, but once we connect MetaMask on "Web3 Provider"

## Concepts

1. Smart Contracts doens't interate out side the blockchain (http, soap...), so to get any outside value into the smart contract we need an [Oracle application](https://ethereum.stackexchange.com/questions/85178/what-is-a-blockchain-oracle/85181#85181)
1. **Abstract Contracts vs Interface**:
    1. Abstract Contracts =  Contracts are identified as abstract contracts when at least one of their functions lacks an implementation (defined a function, but implemented);
    1. Interface = same as abtract contract, but limited to ABI representation.
    1. What interface differ to abstract:
        1. Interfaces cannot have any functions implemented
        1. Interfaces cannot inherit other contracts or interfaces (contracts can however inherit interfaces just as they would inherit other contracts)
        1. Interfaces cannot define a constructor
        1. Interfaces cannot define variables
        1. Interfaces cannot define structs
        1. Interfaces cannot define enums

## Solidity Essentials

1. Accounts:
    1. **External accounts** that are controlled by public-private key pairs (i.e. **humans**)
    1. **Contract accounts** which are *controlled by the code stored* together with the account. The smart contract address derived from creator (launcher) address)
1. Transactions:
    1. A transaction is a **message** that is sent from one account to another account. Can be empty message or even binary (called "payload") and Ether
    1. IF the target has code (is a **smart contract**) the **code is executed** and the **payload** is provided **as input data**.
1. Gas: limit the amount of work that is needed to execute the transaction and to pay for this execution at the same time. *If some gas is left after the execution, it is refunded to the creator in the same way.*
1. Data Store:
    1. Storage: persistent data. It is exepensive because consume disk space. **Store data like derived calculations, caching, and aggregates outside of the contract.**
    1. Memory: contract obtains a freshly cleared instance for each message call (**each message call the contract is instantiate**). Memory is linear and can be addressed at byte level, but reads are limited to a width of 256 bits, while writes can be either 8 bits or 256 bits wide. Memory is expanded by a word (256-bit), when accessing (either reading or writing) a previously untouched memory word (i.e. any offset within a word). At the time of expansion, the cost in gas must be paid. **Memory is more costly the larger it grows** (it scales quadratically).
    1. Stack: EVM is not a register machine but a stack machine, so all computations are performed on a data area called the stack. Works as a pile, so the accessable data is the topmost two, but is possible to add up to 1024 elements, iterating from the top up to the end.
1. Instruction SET:
    1. The instruction set of the EVM is kept minimal in order to avoid incorrect or inconsistent implementations.
        1. Operations: **arithmetic**, **bit**, **logical** and **comparison operations**
        1. Conditional and unconditional jumps are possible. Furthermore, *contracts can access relevant properties* of the **current block** like **its number** and **timestamp**. [**Complete List of possible operations**](https://docs.soliditylang.org/en/v0.8.11/yul.html#opcodes)
1. Message Calls:
    1. **Contracts can call other contracts or send Ether to non-contract accounts by the means of message calls.**
    1. **Contract gas consumption**: contract can decide how much of its remaining gas should be sent with the inner message call and how much it wants to retain. If an out-of-gas exception happens in the inner call (or any other exception), this will be signaled by an error value put onto the stack. In this case, only the gas sent together with the call is used up. In Solidity, the calling contract causes a manual exception by default in such situations, so that exceptions “bubble up” the call stack.
    1. Data workflow: the called contract (which can be the same as the caller) will receive a freshly cleared instance of memory and has access to the call payload - which will be provided in a separate area called the calldata. After it has finished execution, it can return data which will be stored at a location in the caller’s memory preallocated by the caller. All such calls are fully synchronous.
    1. **Recursive must be avoided**: Calls are limited to a depth of 1024, which means that for more complex operations, loops should be preferred over recursive calls. Furthermore, only 63/64th of the gas can be forwarded in a message call, which causes a depth limit of a little less than 1000 in practice.
1. Delegatecall / Callcode and Libraries:
    1. **Delegatecall**: is a *message call* which the code at the target address is executed in the context of the calling contract. In normal *message call* the context of the execution is the target's context and ```msg.sender``` and ```msg.value``` do not change their values. **IT IMPORT A CODE AS A LIB**: This means that a contract can dynamically load code from a different address at runtime. Storage, current address and balance still refer to the calling contract, only the code is taken from the called address. 
1. Logs:
    1. Store data outside the contract for "debug" accessable and it implements events. Since some part of the log data is stored in bloom filters, it is possible to search for this data in an efficient and cryptographically secure way, so network peers that do not download the whole blockchain (so-called “light clients”) can still find these logs.
1. Create (contract creating contracts):
    1. **Contracts can even create other contracts using a special opcode (i.e. they do not simply call the zero address as a transaction would)**. The only **difference** between these create calls and normal message calls is that the **payload data is executed and the result stored as code** and the **caller / creator receives the address of the new contract on the stack**.
1. Deactivate and Self-destruct (**do not use it**)
    1. The only way to remove code from the blockchain is when a contract at that address performs the selfdestruct operation. The remaining Ether stored at that address is sent to a designated target and then the storage and code is removed from the state.
    1. **best way to shutdown**: If you want to deactivate your contracts, you should instead disable them by changing some internal state which causes all functions to revert. This makes it impossible to use the contract, as it returns Ether immediately.



