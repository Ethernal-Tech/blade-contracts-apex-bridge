# StakeManager









## Methods

### BRIDGE_CONTRACT

```solidity
function BRIDGE_CONTRACT() external view returns (address)
```

Bridge contract address is predefined, so it is always the same.




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### CLOCK_MODE

```solidity
function CLOCK_MODE() external view returns (string)
```



*Description of the clock*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### DOMAIN_SEPARATOR

```solidity
function DOMAIN_SEPARATOR() external view returns (bytes32)
```



*See {IERC20Permit-DOMAIN_SEPARATOR}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### acceptOwnership

```solidity
function acceptOwnership() external nonpayable
```



*The new owner accepts the ownership transfer.*


### allowance

```solidity
function allowance(address owner, address spender) external view returns (uint256)
```



*See {IERC20-allowance}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |
| spender | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### approve

```solidity
function approve(address spender, uint256 amount) external nonpayable returns (bool)
```



*See {IERC20-approve}. NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on `transferFrom`. This is semantically equivalent to an infinite approval. Requirements: - `spender` cannot be the zero address.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### balanceOf

```solidity
function balanceOf(address account) external view returns (uint256)
```



*See {IERC20-balanceOf}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### balanceOfAt

```solidity
function balanceOfAt(address account, uint256 epochNumber) external view returns (uint256)
```

Returns the staked balance of an account at the end of a given epoch.



#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | The address of the account to query. |
| epochNumber | uint256 | The epoch number to query. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The staked balance of the account at the end of the specified epoch. |

### checkpoints

```solidity
function checkpoints(address account, uint32 pos) external view returns (struct ERC20VotesUpgradeable.Checkpoint)
```



*Get the `pos`-th checkpoint for `account`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| pos | uint32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | ERC20VotesUpgradeable.Checkpoint | undefined |

### clock

```solidity
function clock() external view returns (uint48)
```



*Clock used for flagging checkpoints. Can be overridden to implement timestamp based checkpoints (and voting).*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint48 | undefined |

### decimals

```solidity
function decimals() external view returns (uint8)
```



*Returns the number of decimals used to get its user representation. For example, if `decimals` equals `2`, a balance of `505` tokens should be displayed to a user as `5.05` (`505 / 10 ** 2`). Tokens usually opt for a value of 18, imitating the relationship between Ether and Wei. This is the default value returned by this function, unless it&#39;s overridden. NOTE: This information is only used for _display_ purposes: it in no way affects any of the arithmetic of the contract, including {IERC20-balanceOf} and {IERC20-transfer}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint8 | undefined |

### decreaseAllowance

```solidity
function decreaseAllowance(address spender, uint256 subtractedValue) external nonpayable returns (bool)
```



*Atomically decreases the allowance granted to `spender` by the caller. This is an alternative to {approve} that can be used as a mitigation for problems described in {IERC20-approve}. Emits an {Approval} event indicating the updated allowance. Requirements: - `spender` cannot be the zero address. - `spender` must have allowance for the caller of at least `subtractedValue`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| subtractedValue | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### delegate

```solidity
function delegate(address delegatee) external nonpayable
```



*Delegate votes from the sender to `delegatee`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| delegatee | address | undefined |

### delegateBySig

```solidity
function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external nonpayable
```



*Delegates votes from signer to `delegatee`*

#### Parameters

| Name | Type | Description |
|---|---|---|
| delegatee | address | undefined |
| nonce | uint256 | undefined |
| expiry | uint256 | undefined |
| v | uint8 | undefined |
| r | bytes32 | undefined |
| s | bytes32 | undefined |

### delegates

```solidity
function delegates(address account) external view returns (address)
```



*Get the address `account` is currently delegating to.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### domain

```solidity
function domain() external view returns (bytes32)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### eip712Domain

```solidity
function eip712Domain() external view returns (bytes1 fields, string name, string version, uint256 chainId, address verifyingContract, bytes32 salt, uint256[] extensions)
```



*See {EIP-5267}. _Available since v4.9._*


#### Returns

| Name | Type | Description |
|---|---|---|
| fields | bytes1 | undefined |
| name | string | undefined |
| version | string | undefined |
| chainId | uint256 | undefined |
| verifyingContract | address | undefined |
| salt | bytes32 | undefined |
| extensions | uint256[] | undefined |

### getPastTotalSupply

```solidity
function getPastTotalSupply(uint256 timepoint) external view returns (uint256)
```



*Retrieve the `totalSupply` at the end of `timepoint`. Note, this value is the sum of all balances. It is NOT the sum of all the delegated votes! Requirements: - `timepoint` must be in the past*

#### Parameters

| Name | Type | Description |
|---|---|---|
| timepoint | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### getPastVotes

```solidity
function getPastVotes(address account, uint256 timepoint) external view returns (uint256)
```



*Retrieve the number of votes for `account` at the end of `timepoint`. Requirements: - `timepoint` must be in the past*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| timepoint | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### getValidator

```solidity
function getValidator(address validator_) external view returns (struct Validator)
```

Returns the validator details for a given address.



#### Parameters

| Name | Type | Description |
|---|---|---|
| validator_ | address | The address of the validator to query. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | Validator | The Validator struct associated with the given address. |

### getVotes

```solidity
function getVotes(address account) external view returns (uint256)
```



*Gets the current votes balance for `account`*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### increaseAllowance

```solidity
function increaseAllowance(address spender, uint256 addedValue) external nonpayable returns (bool)
```



*Atomically increases the allowance granted to `spender` by the caller. This is an alternative to {approve} that can be used as a mitigation for problems described in {IERC20-approve}. Emits an {Approval} event indicating the updated allowance. Requirements: - `spender` cannot be the zero address.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| addedValue | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### initialize

```solidity
function initialize(address newStakingToken, address newBls, address epochManager, address networkParams, address owner, string newDomain, GenesisValidator[] genesisValidators) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newStakingToken | address | undefined |
| newBls | address | undefined |
| epochManager | address | undefined |
| networkParams | address | undefined |
| owner | address | undefined |
| newDomain | string | undefined |
| genesisValidators | GenesisValidator[] | undefined |

### name

```solidity
function name() external view returns (string)
```



*Returns the name of the token.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### nonces

```solidity
function nonces(address owner) external view returns (uint256)
```



*See {IERC20Permit-nonces}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### numCheckpoints

```solidity
function numCheckpoints(address account) external view returns (uint32)
```



*Get number of checkpoints for `account`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint32 | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### pendingOwner

```solidity
function pendingOwner() external view returns (address)
```



*Returns the address of the pending owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### pendingWithdrawals

```solidity
function pendingWithdrawals(address account) external view returns (uint256)
```

Returns the total amount of pending (not yet withdrawable) withdrawals for an account.



#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | The address of the account to query. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The total amount of pending withdrawals. |

### permit

```solidity
function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external nonpayable
```



*See {IERC20Permit-permit}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |
| spender | address | undefined |
| value | uint256 | undefined |
| deadline | uint256 | undefined |
| v | uint8 | undefined |
| r | bytes32 | undefined |
| s | bytes32 | undefined |

### register

```solidity
function register(uint256[2] signature, uint256[4] pubkey) external pure
```

Always reverts.

*Register validator is no longer possible, this function remains only for backward compatibility.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| signature | uint256[2] | undefined |
| pubkey | uint256[4] | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.*


### stake

```solidity
function stake(uint256 amount) external nonpayable
```

Always reverts.

*Cannot stake additional tokens, this function remains only for backward compatibility.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | undefined |

### stakeOf

```solidity
function stakeOf(address validator) external view returns (uint256 amount)
```

Returns the stake amount of a specific validator.



#### Parameters

| Name | Type | Description |
|---|---|---|
| validator | address | The address of the validator. |

#### Returns

| Name | Type | Description |
|---|---|---|
| amount | uint256 | The amount of tokens staked by the validator(the amount is always 1). |

### symbol

```solidity
function symbol() external view returns (string)
```



*Returns the symbol of the token, usually a shorter version of the name.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### totalStake

```solidity
function totalStake() external view returns (uint256 amount)
```

Returns the total amount of stake in the contract.




#### Returns

| Name | Type | Description |
|---|---|---|
| amount | uint256 | The total staked amount (equivalent to total token supply, which is equal the number of active validators). |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```



*See {IERC20-totalSupply}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### totalSupplyAt

```solidity
function totalSupplyAt(uint256 epochNumber) external view returns (uint256)
```

Returns the total token supply at the end of a given epoch.



#### Parameters

| Name | Type | Description |
|---|---|---|
| epochNumber | uint256 | The epoch number to query. |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | The total token supply at the end of the specified epoch. |

### transfer

```solidity
function transfer(address to, uint256 amount) external nonpayable returns (bool)
```



*See {IERC20-transfer}. Requirements: - `to` cannot be the zero address. - the caller must have a balance of at least `amount`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 amount) external nonpayable returns (bool)
```



*See {IERC20-transferFrom}. Emits an {Approval} event indicating the updated allowance. This is not required by the EIP. See the note at the beginning of {ERC20}. NOTE: Does not update the allowance if the current allowance is the maximum `uint256`. Requirements: - `from` and `to` cannot be the zero address. - `from` must have a balance of at least `amount`. - the caller must have allowance for ``from``&#39;s tokens of at least `amount`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one. Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### unstake

```solidity
function unstake(uint256 amount) external nonpayable
```

Always reverts.

*Cannot unstake tokens directly, this function remains only for backward compatibility.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | undefined |

### updateValidatorSet

```solidity
function updateValidatorSet(ValidatorDelta validatorDelta) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| validatorDelta | ValidatorDelta | undefined |

### validators

```solidity
function validators(address) external view returns (address addr, bool isWhitelisted, bool isActive)
```

Mapping of all validators.

*Maps a validators address to its corresponding Validator struct.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| addr | address | undefined |
| isWhitelisted | bool | undefined |
| isActive | bool | undefined |

### whitelistValidators

```solidity
function whitelistValidators(address[] validators_) external nonpayable
```

Always reverts.

*Whitelisting validators is no longer necessary, this function remains only for backward compatibility.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| validators_ | address[] | undefined |

### withdraw

```solidity
function withdraw() external nonpayable
```

Withdraws the caller&#39;s unlocked stake from the withdrawal queue.

*Updates the queue head after withdrawal and transfers the unlocked amount.*


### withdrawable

```solidity
function withdrawable(address account) external view returns (uint256 amount)
```

Returns the total amount of stake currently withdrawable by the given account.



#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | The address of the account to check. |

#### Returns

| Name | Type | Description |
|---|---|---|
| amount | uint256 | The total withdrawable stake for the account at the current epoch. |



## Events

### AddedToWhitelist

```solidity
event AddedToWhitelist(address indexed validator)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| validator `indexed` | address | undefined |

### Approval

```solidity
event Approval(address indexed owner, address indexed spender, uint256 value)
```



*Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| spender `indexed` | address | undefined |
| value  | uint256 | undefined |

### DelegateChanged

```solidity
event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate)
```



*Emitted when an account changes their delegate.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| delegator `indexed` | address | undefined |
| fromDelegate `indexed` | address | undefined |
| toDelegate `indexed` | address | undefined |

### DelegateVotesChanged

```solidity
event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance)
```



*Emitted when a token transfer or delegate change results in changes to a delegate&#39;s number of votes.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| delegate `indexed` | address | undefined |
| previousBalance  | uint256 | undefined |
| newBalance  | uint256 | undefined |

### EIP712DomainChanged

```solidity
event EIP712DomainChanged()
```



*MAY be emitted to signal that the domain could have changed.*


### Initialized

```solidity
event Initialized(uint8 version)
```



*Triggered when the contract has been initialized or reinitialized.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### OwnershipTransferStarted

```solidity
event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### RemovedFromWhitelist

```solidity
event RemovedFromWhitelist(address indexed validator)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| validator `indexed` | address | undefined |

### StakeAdded

```solidity
event StakeAdded(address indexed validator, uint256 amount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| validator `indexed` | address | undefined |
| amount  | uint256 | undefined |

### StakeRemoved

```solidity
event StakeRemoved(address indexed validator, uint256 amount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| validator `indexed` | address | undefined |
| amount  | uint256 | undefined |

### StakeWithdrawn

```solidity
event StakeWithdrawn(address indexed account, uint256 amount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account `indexed` | address | undefined |
| amount  | uint256 | undefined |

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 value)
```



*Emitted when `value` tokens are moved from one account (`from`) to another (`to`). Note that `value` may be zero.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| value  | uint256 | undefined |

### ValidatorDeactivated

```solidity
event ValidatorDeactivated(address indexed validator)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| validator `indexed` | address | undefined |

### ValidatorRegistered

```solidity
event ValidatorRegistered(address indexed validator, uint256[4] blsKey, uint256 amount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| validator `indexed` | address | undefined |
| blsKey  | uint256[4] | undefined |
| amount  | uint256 | undefined |



## Errors

### InvalidSignature

```solidity
error InvalidSignature(address validator)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| validator | address | undefined |

### Unauthorized

```solidity
error Unauthorized(string message)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| message | string | undefined |


