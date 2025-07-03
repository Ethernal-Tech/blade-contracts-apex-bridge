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

    uint256 private constant DEFAULT_STAKE_AMOUNT = 1;
    address public constant BRIDGE_CONTRACT = 0xaBef000000000000000000000000000000000000;

    IBLS private _bls;
    IERC20 private _stakingToken;
    IEpochManager private _epochManager;
    NetworkParams private _networkParams;

    bytes32 public domain;

    mapping(address => Validator) public validators;

    // TODO: Figure out the unstake and stake withdrawal workflow (unlock period etc.)
    mapping(address => WithdrawalQueue) private _withdrawals;

    modifier onlyValidator(address validator) {
        if (!validators[validator].isActive) revert Unauthorized("VALIDATOR");
        _;
    }

    modifier onlyBridgeCall() {
        if (msg.sender != BRIDGE_CONTRACT) revert Unauthorized("BRIDGE_CONTRACT");
        _;
    }

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
    function stake(uint256 amount) external onlyValidator(msg.sender) {
        // do not allow additional staking! _stake(msg.sender, amount);

        revert("STAKING_IS_NOT_POSSIBLE");
    }

    /**
     * @inheritdoc IStakeManager
     */
    function unstake(uint256 amount) external onlyValidator(msg.sender) {
        // do not allow additional unstaking!_unstake(msg.sender, amount);

        revert("UNSTAKING_IS_NOT_POSSIBLE");
    }

    /**
     * @inheritdoc IStakeManager
     */
    function totalStake() external view returns (uint256 amount) {
        amount = totalSupply();
    }

    /**
     * @inheritdoc IStakeManager
     */
    function stakeOf(address validator) external view returns (uint256 amount) {
        amount = _stakeOf(validator);
    }

    /**
     * @inheritdoc IStakeManager
     */
    function whitelistValidators(address[] calldata validators_) external onlyOwner {
        revert("WHITELIST_IS_NOT_POSSIBLE");
    }

    /**
     * @inheritdoc IStakeManager
     */
    function register(uint256[2] calldata signature, uint256[4] calldata pubkey) external pure {
        revert("REGISTER_CURRENTLY_NOT_AVAILABLE");
    }

    /**
     * @inheritdoc IStakeManager
     */
    function getValidator(address validator_) external view returns (Validator memory) {
        return validators[validator_];
    }

    /**
     * @inheritdoc IStakeManager
     */
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
    // slither-disable-next-line unused-return
    function withdrawable(address account) external view returns (uint256 amount) {
        uint256 currentEpochId = _epochManager.currentEpochId();
        (amount, ) = _withdrawals[account].withdrawable(currentEpochId);
    }

    /**
     * @inheritdoc IStakeManager
     */
    function pendingWithdrawals(address account) external view returns (uint256) {
        return _withdrawals[account].pending(_epochManager.currentEpochId());
    }

    function totalSupplyAt(uint256 epochNumber) external view returns (uint256) {
        return super.getPastTotalSupply(_epochManager.epochEndingBlocks(epochNumber));
    }

    function balanceOfAt(address account, uint256 epochNumber) external view returns (uint256) {
        return super.getPastVotes(account, _epochManager.epochEndingBlocks(epochNumber));
    }

    function _stake(address validator, uint256 amount) internal {
        _mint(validator, amount);
        // slither-disable-start arbitrary-from-in-transferfrom
        // slither-disable-next-line reentrancy-benign,reentrancy-events
        _stakingToken.safeTransferFrom(validator, address(this), amount);
        // slither-disable-end arbitrary-from-in-transferfrom
        _delegate(validator, validator);
        // slither-disable-next-line reentrancy-events
        emit StakeAdded(validator, amount);
    }

    function _unstake(address validator, uint256 amount) internal {
        _burn(validator, amount);
        emit StakeRemoved(validator, amount);

        _registerWithdrawal(validator, amount);
        _removeIfValidatorUnstaked(validator);
    }

    function _registerWithdrawal(address account, uint256 amount) internal {
        // slither-disable-next-line calls-loop
        _withdrawals[account].append(amount, _epochManager.currentEpochId() + _networkParams.withdrawalWaitPeriod());
    }

    function _removeIfValidatorUnstaked(address validator) internal {
        if (_stakeOf(validator) == 0) {
            validators[validator].isActive = false;
            emit ValidatorDeactivated(validator);
        }
    }

    function _stakeOf(address validator) internal view returns (uint256 amount) {
        amount = balanceOf(validator);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(from == address(0) || to == address(0), "TRANSFER_FORBIDDEN");
        super._beforeTokenTransfer(from, to, amount);
    }

    function _delegate(address delegator, address delegatee) internal override {
        if (delegator != delegatee) revert("DELEGATION_FORBIDDEN");
        super._delegate(delegator, delegatee);
    }

    function updateValidatorSet(ValidatorSetDelta calldata validatorSetDelta) external onlyBridgeCall {
        for (uint256 i = 0; i < validatorSetDelta.addedValidators.length; i++) {
            if (validatorSetDelta.addedValidators[i].chainID == 0xFF) {
                BridgeValidatorsData memory tempValidator = validatorSetDelta.addedValidators[i];

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

        for (uint256 i = 0; i < validatorSetDelta.removedValidators.length; i++) {
            _unstake(validatorSetDelta.removedValidators[i], DEFAULT_STAKE_AMOUNT);
        }
    }

    // slither-disable-next-line unused-state,naming-convention
    uint256[48] private __gap;
}
