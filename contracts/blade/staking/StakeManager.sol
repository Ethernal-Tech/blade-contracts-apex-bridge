// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "../../interfaces/blade/staking/IStakeManager.sol";
import "../../interfaces/IStateSender.sol";
import "../../interfaces/common/IBLS.sol";
import "../../interfaces/blade/validator/IEpochManager.sol";
import "../../lib/WithdrawalQueue.sol";
import "../../blade/NetworkParams.sol";

contract StakeManager is IStakeManager, Initializable, Ownable2StepUpgradeable, ERC20VotesUpgradeable {
    using SafeERC20 for IERC20;
    using WithdrawalQueueLib for WithdrawalQueue;

    /// @notice Every validator has same stake, so stake amount only can be 1.
    uint256 private constant DEFAULT_STAKE_AMOUNT = 1;
    /// @notice Bridge contract address is predefined, so it is always the same.
    address public constant BRIDGE_CONTRACT = 0xaBef000000000000000000000000000000000000;

    IBLS private _bls;
    IERC20 private _stakingToken;
    IEpochManager private _epochManager;
    NetworkParams private _networkParams;

    bytes32 public domain;

    /// @notice Mapping of all validators.
    /// @dev Maps a validators address to its corresponding Validator struct.
    mapping(address => Validator) public validators;

    // TODO: Figure out the unstake and stake withdrawal workflow (unlock period etc.)
    /// @notice Mapping of withdrawal for each validator.
    /// @dev Tracks the withdrawal queue for each account.
    mapping(address => WithdrawalQueue) private _withdrawals;

    modifier onlyValidator(address validator) {
        if (!validators[validator].isActive) revert Unauthorized("VALIDATOR");
        _;
    }

    modifier onlyBridgeCall() {
        if (msg.sender != BRIDGE_CONTRACT) revert Unauthorized("BRIDGE_CONTRACT");
        _;
    }

    /// @notice Initializes the StakeManager contract.
    /// @param newStakingToken Address of Staking token contract, must be compatible with IERC20 interface.
    /// @param newBls Address of Bls contract.
    /// @param epochManager Address of EpochManager contract.
    /// @param networkParams Address of networkParams contract.
    /// @param owner Owner of the contract.
    /// @param newDomain Domain
    /// @param genesisValidators genesis validator set.
    function initialize(
        address newStakingToken,
        address newBls,
        address epochManager,
        address networkParams,
        address owner,
        string memory newDomain,
        GenesisValidator[] memory genesisValidators
    ) public initializer {
        require(
            newStakingToken != address(0) &&
                newBls != address(0) &&
                epochManager != address(0) &&
                networkParams != address(0),
            "INVALID_INPUT"
        );

        __ERC20Permit_init("StakeManager");
        __ERC20_init("StakeManager", "STAKE");
        _stakingToken = IERC20(newStakingToken);
        _bls = IBLS(newBls);
        _epochManager = IEpochManager(epochManager);
        _networkParams = NetworkParams(networkParams);
        domain = keccak256(abi.encodePacked(newDomain));

        for (uint i = 0; i < genesisValidators.length; i++) {
            GenesisValidator memory validator = genesisValidators[i];
            validators[validator.addr] = Validator(validator.addr, validator.blsKey, true, true);
            _stake(validator.addr, DEFAULT_STAKE_AMOUNT); // validator stake must be set to default amount
        }
        _transferOwnership(owner);
    }

    /**
     * @inheritdoc IStakeManager
     */
    /// @notice Always reverts.
    /// @dev Cannot stake additional tokens, this function remains only for backward compatibility.
    function stake(uint256 amount) external onlyValidator(msg.sender) {
        revert("STAKING_IS_NOT_POSSIBLE");
    }

    /**
     * @inheritdoc IStakeManager
     */
    /// @notice Always reverts.
    /// @dev Cannot unstake tokens directly, this function remains only for backward compatibility.
    function unstake(uint256 amount) external onlyValidator(msg.sender) {
        revert("UNSTAKING_IS_NOT_POSSIBLE");
    }

    /**
     * @inheritdoc IStakeManager
     */
    /// @notice Returns the total amount of stake in the contract.
    /// @return amount The total staked amount (equivalent to total token supply, which is equal the number of active validators).
    function totalStake() external view returns (uint256 amount) {
        amount = totalSupply();
    }

    /**
     * @inheritdoc IStakeManager
     */
    /// @notice Returns the stake amount of a specific validator.
    /// @param validator The address of the validator.
    /// @return amount The amount of tokens staked by the validator(the amount is always 1).
    function stakeOf(address validator) external view returns (uint256 amount) {
        amount = _stakeOf(validator);
    }

    /**
     * @inheritdoc IStakeManager
     */
    /// @notice Always reverts.
    /// @dev Whitelisting validators is no longer necessary, this function remains only for backward compatibility.
    function whitelistValidators(address[] calldata validators_) external onlyOwner {
        revert("WHITELIST_IS_NOT_POSSIBLE");
    }

    /**
     * @inheritdoc IStakeManager
     */
    /// @notice Always reverts.
    /// @dev Register validator is no longer possible, this function remains only for backward compatibility.
    function register(uint256[2] calldata signature, uint256[4] calldata pubkey) external pure {
        revert("REGISTER_CURRENTLY_NOT_AVAILABLE");
    }

    /**
     * @inheritdoc IStakeManager
     */
    /// @notice Returns the validator details for a given address.
    /// @param validator_ The address of the validator to query.
    /// @return The Validator struct associated with the given address.
    function getValidator(address validator_) external view returns (Validator memory) {
        return validators[validator_];
    }

    /**
     * @inheritdoc IStakeManager
     */
    /// @notice Withdraws the caller's unlocked stake from the withdrawal queue.
    /// @dev Updates the queue head after withdrawal and transfers the unlocked amount.
    function withdraw() external {
        WithdrawalQueue storage queue = _withdrawals[msg.sender];
        (uint256 amount, uint256 newHead) = queue.withdrawable(_epochManager.currentEpochId());
        queue.head = newHead;

        emit StakeWithdrawn(msg.sender, amount);
        _stakingToken.safeTransfer(msg.sender, amount);
    }

    /**
     * @inheritdoc IStakeManager
     */
    /// @notice Returns the total amount of stake currently withdrawable by the given account.
    /// @param account The address of the account to check.
    /// @return amount The total withdrawable stake for the account at the current epoch.
    // slither-disable-next-line unused-return
    function withdrawable(address account) external view returns (uint256 amount) {
        uint256 currentEpochId = _epochManager.currentEpochId();
        (amount, ) = _withdrawals[account].withdrawable(currentEpochId);
    }

    /**
     * @inheritdoc IStakeManager
     */
    /// @notice Returns the total amount of pending (not yet withdrawable) withdrawals for an account.
    /// @param account The address of the account to query.
    /// @return The total amount of pending withdrawals.
    function pendingWithdrawals(address account) external view returns (uint256) {
        return _withdrawals[account].pending(_epochManager.currentEpochId());
    }

    /// @notice Returns the total token supply at the end of a given epoch.
    /// @param epochNumber The epoch number to query.
    /// @return The total token supply at the end of the specified epoch.
    function totalSupplyAt(uint256 epochNumber) external view returns (uint256) {
        return super.getPastTotalSupply(_epochManager.epochEndingBlocks(epochNumber));
    }

    /// @notice Returns the staked balance of an account at the end of a given epoch.
    /// @param account The address of the account to query.
    /// @param epochNumber The epoch number to query.
    /// @return The staked balance of the account at the end of the specified epoch.
    function balanceOfAt(address account, uint256 epochNumber) external view returns (uint256) {
        return super.getPastVotes(account, _epochManager.epochEndingBlocks(epochNumber));
    }

    /// @dev Stakes a fixed amount of tokens for the given validator.
    /// Mints staking power, transfers tokens from the validator.
    /// delegates the voting power, and emits a {StakeAdded} event.
    /// Slither warnings are disabled due to controlled internal use.
    /// @param validator The address of the validator to stake for.
    /// @param amount The amount of tokens to stake.
    function _stake(address validator, uint256 amount) internal {
        _mint(validator, amount);
        // slither-disable-start all
        _stakingToken.safeTransferFrom(validator, address(this), amount);
        // slither-disable-end all
        _delegate(validator, validator);
        // slither-disable-next-line reentrancy-events
        emit StakeAdded(validator, amount);
    }

    /// @dev Unstakes a specified amount of tokens from the given validator.
    /// Burns staking power, emits a {StakeRemoved} event, registers the withdrawal request,
    /// and removes the validator if their stake drops to zero.
    /// @param validator The address of the validator to unstake from.
    /// @param amount The amount of tokens to unstake.
    function _unstake(address validator, uint256 amount) internal {
        _burn(validator, amount);
        emit StakeRemoved(validator, amount);

        _removeIfValidatorUnstaked(validator);
    }

    /// @dev Deactivates the validator if their stake has dropped to zero.
    /// @param validator The address of the validator to check and potentially deactivate.
    function _removeIfValidatorUnstaked(address validator) internal {
        if (_stakeOf(validator) == 0) {
            validators[validator].isActive = false;
            emit ValidatorDeactivated(validator);
        }
    }

    /// @dev Returns the current stake amount of the specified validator(amount is always 1).
    /// @param validator The address of the validator.
    /// @return amount The amount of tokens staked by the validator.
    function _stakeOf(address validator) internal view returns (uint256 amount) {
        amount = balanceOf(validator);
    }

    /// @dev Restricts token transfers to only minting or burning.
    /// Reverts with "TRANSFER_FORBIDDEN" if tokens are transferred between non-zero addresses.
    /// @param from The address tokens are transferred from.
    /// @param to The address tokens are transferred to.
    /// @param amount The amount of tokens being transferred.
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(from == address(0) || to == address(0), "TRANSFER_FORBIDDEN");
        super._beforeTokenTransfer(from, to, amount);
    }

    /// @dev Overrides delegation to forbid delegating to any address other than oneself.
    /// Reverts with "DELEGATION_FORBIDDEN" if `delegator` and `delegatee` differ.
    /// @param delegator The address delegating their stake.
    /// @param delegatee The address receiving the delegation (must be the delegator).
    function _delegate(address delegator, address delegatee) internal override {
        if (delegator != delegatee) revert("DELEGATION_FORBIDDEN");
        super._delegate(delegator, delegatee);
    }

    /// @notice Updates the validator set by adding and removing validators based on the provided delta.
    /// @dev Only callable via the bridge using the `onlyBridgeCall` modifier.
    /// Adds new validators if their `chainID` equals 0xFF and activates them if not already active.
    /// Automatically stakes `DEFAULT_STAKE_AMOUNT` for new validators and emits a {ValidatorRegistered} event.
    /// Removes validators listed in `removedValidators` by calling `_unstake`.
    /// @param validatorDelta The struct containing lists of added and removed validators.
    function updateValidatorSet(ValidatorDelta calldata validatorDelta) external onlyBridgeCall {
        for (uint256 i = 0; i < validatorDelta.addedValidators.length; i++) {
            if (validatorDelta.addedValidators[i].chainID == 0xFF) {
                BridgeValidatorsData memory tempValidator = validatorDelta.addedValidators[i];

                for (uint256 j = 0; j < tempValidator.validatorData.length; j++) {
                    ValidatorData memory validatorData = tempValidator.validatorData[j];

                    Validator storage validator = validators[validatorData.addr];
                    if (!validator.isActive) {
                        validator.isActive = true;
                        validator.blsKey = validatorData.key;
                        validator.addr = validatorData.addr;

                        _stake(validator.addr, DEFAULT_STAKE_AMOUNT);
                        emit ValidatorRegistered(validatorData.addr, validatorData.key, DEFAULT_STAKE_AMOUNT);
                    }
                }
            }
        }

        for (uint256 i = 0; i < validatorDelta.removedValidators.length; i++) {
            _unstake(validatorDelta.removedValidators[i], DEFAULT_STAKE_AMOUNT);
        }
    }

    // slither-disable-next-line unused-state,naming-convention
    uint256[48] private __gap;
}
