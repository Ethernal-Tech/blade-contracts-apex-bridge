// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@utils/Test.sol";
import {StakeManager} from "contracts/blade/staking/StakeManager.sol";
import {EpochManager} from "contracts/blade/validator/EpochManager.sol";
import {GenesisValidator} from "contracts/interfaces/blade/staking/IStakeManager.sol";
import {BridgeValidatorsData} from "contracts/interfaces/blade/staking/IStakeManager.sol";
import {ValidatorData} from "contracts/interfaces/blade/staking/IStakeManager.sol";
import {ValidatorSetDelta} from "contracts/interfaces/blade/staking/IStakeManager.sol";
import {Epoch} from "contracts/interfaces/blade/validator/IEpochManager.sol";
import {MockERC20} from "contracts/mocks/MockERC20.sol";
import {NetworkParams} from "contracts/blade/NetworkParams.sol";
import {BLS} from "contracts/common/BLS.sol";
import "contracts/interfaces/Errors.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

abstract contract Uninitialized is Test {
    address public constant SYSTEM = 0xffffFFFfFFffffffffffffffFfFFFfffFFFfFFfE;

    MockERC20 token;
    StakeManager stakeManager;
    BLS bls;

    EpochManager epochManager;
    NetworkParams networkParams;
    string testDomain = "STAKE_MANAGER";

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address jim = makeAddr("jim");
    address rewardWallet = makeAddr("rewardWallet");
    address bridge = 0xaBef000000000000000000000000000000000000;

    uint256 stakeAmount = 1;
    uint256[2][] public aggMessagePoints;

    function setUp() public virtual {
        token = new MockERC20();
        token.mint(alice, 1000 ether);
        token.mint(bob, 1000 ether);
        token.mint(jim, 1000 ether);
        token.mint(bridge, 1000 ether);

        bls = new BLS();
        stakeManager = new StakeManager();
        epochManager = new EpochManager();
        networkParams = new NetworkParams();

        vm.prank(alice);
        token.approve(address(stakeManager), type(uint256).max);
        vm.prank(bob);
        token.approve(address(stakeManager), type(uint256).max);
        vm.prank(jim);
        token.approve(address(stakeManager), type(uint256).max);
        vm.prank(bridge);
        token.approve(address(stakeManager), type(uint256).max);

        epochManager.initialize(address(stakeManager), address(token), rewardWallet, address(networkParams));
    }
}

abstract contract Initialized is Uninitialized {
    function setUp() public virtual override {
        super.setUp();
        GenesisValidator[] memory validators = new GenesisValidator[](3);
        validators[0] = GenesisValidator({
            addr: bob,
            blsKey: [type(uint256).max, type(uint256).max, type(uint256).max, type(uint256).max]
        });
        validators[1] = GenesisValidator({
            addr: alice,
            blsKey: [type(uint256).max, type(uint256).max, type(uint256).max, type(uint256).max]
        });
        validators[2] = GenesisValidator({
            addr: jim,
            blsKey: [type(uint256).max, type(uint256).max, type(uint256).max, type(uint256).max]
        });

        stakeManager.initialize(
            address(token),
            address(bls),
            address(epochManager),
            address(networkParams),
            bob,
            testDomain,
            validators
        );
    }
}

contract StakeManager_Initialize is Uninitialized {
    function testInititialize() public {
        GenesisValidator[] memory validators = new GenesisValidator[](3);
        validators[0] = GenesisValidator({
            addr: bob,
            blsKey: [type(uint256).max, type(uint256).max, type(uint256).max, type(uint256).max]
        });
        validators[1] = GenesisValidator({
            addr: alice,
            blsKey: [type(uint256).max, type(uint256).max, type(uint256).max, type(uint256).max]
        });
        validators[2] = GenesisValidator({
            addr: jim,
            blsKey: [type(uint256).max, type(uint256).max, type(uint256).max, type(uint256).max]
        });

        stakeManager.initialize(
            address(token),
            address(bls),
            address(epochManager),
            address(networkParams),
            bob,
            testDomain,
            validators
        );
    }
}

contract StakeManager_Stake is Initialized, StakeManager {
    function test_Stake() public {
        vm.expectRevert("STAKING_IS_NOT_POSSIBLE");
        vm.prank(bob);
        stakeManager.stake(1);
    }
}

contract StakeManager_WithdrawStake is Initialized, StakeManager {
    function test_Unstake() public {
        vm.expectRevert("UNSTAKING_IS_NOT_POSSIBLE");
        vm.prank(alice);
        stakeManager.unstake(1);
    }
}

abstract contract Whitelist is Initialized {
    address kevin = makeAddr("kevin");

    function test_WhiteList() public{
        vm.expectRevert("WHITELIST_IS_NOT_POSSIBLE");
        address[] memory validators = new address[](1);
        validators[0] = bob;
        vm.prank(bob);
        stakeManager.whitelistValidators(validators);
    }
}

contract StakeManager_Register is Initialized {
    address mike = makeAddr("mike");

    function test_RegisterRevert() public {
        vm.expectRevert("REGISTER_CURRENTLY_NOT_AVAILABLE");
        vm.prank(mike);
        uint256[2] memory signature;
        uint256[4] memory pubkey;
        stakeManager.register(signature, pubkey);
    }
}

contract StakeManager_UpdateValidatorSet is Initialized {
    event ValidatorRegistered(address indexed validator, uint256[4] blsKey);
    event RemovedFromWhitelist(address indexed validator);

    address mike = makeAddr("mike");

    function setUp() public virtual override {
        super.setUp();
        token.mint(mike, 1000 ether);
    }
    

    function test_RevertUnathorized() public {
        BridgeValidatorsData[] memory validatorsData = new BridgeValidatorsData[](0);
        address[] memory removedValidators = new address[](0);
        ValidatorSetDelta memory validatorSetDelta = ValidatorSetDelta(validatorsData, removedValidators);
        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector, "BRIDGE_CONTRACT"));
        vm.prank(mike);
        stakeManager.updateValidatorSet(validatorSetDelta);
    }

    function test_SuccessfulRegistration() public {
        (uint256[2] memory signature, uint256[4] memory pubKey) = getSignatureAndPubKey(mike);
        
        vm.prank(mike);
        token.approve(address(stakeManager), type(uint256).max);

        BridgeValidatorsData[] memory bridgeValidatorsData = new BridgeValidatorsData[](1);
        ValidatorData[] memory validatorsData = new ValidatorData[](1);
        address[] memory removedValidators = new address[](0);
        validatorsData[0] = ValidatorData(mike, pubKey, "", "");
        bridgeValidatorsData[0] = BridgeValidatorsData(0xff, validatorsData);
        ValidatorSetDelta memory validatorSetDelta = ValidatorSetDelta(bridgeValidatorsData, removedValidators);
        vm.startPrank(bridge);
        stakeManager.updateValidatorSet(validatorSetDelta);
        uint256 stake = stakeManager.stakeOf(mike);
        assertEq(stake, stakeAmount, "expected same stake");
    }

    function test_RemoveValidator() public {
        (uint256[2] memory signature, uint256[4] memory pubKey) = getSignatureAndPubKey(mike);

        BridgeValidatorsData[] memory bridgeValidatorsData = new BridgeValidatorsData[](0);
        address[] memory removedValidators = new address[](1);
        ValidatorSetDelta memory validatorSetDelta = ValidatorSetDelta(bridgeValidatorsData, removedValidators);
        removedValidators[0] = alice;
        vm.startPrank(bridge);
        stakeManager.updateValidatorSet(validatorSetDelta);
        uint256 stake = stakeManager.stakeOf(alice);
        assertEq(stake, 0, "expected same stake");
    }


    function getSignatureAndPubKey(address addr) public returns (uint256[2] memory, uint256[4] memory) {
        string[] memory cmd = new string[](5);
        cmd[0] = "npx";
        cmd[1] = "ts-node";
        cmd[2] = "test/forge/bridge/generateMsgStakeManager.ts";
        cmd[3] = toHexString(addr);
        cmd[4] = toHexString(address(stakeManager));
        bytes memory out = vm.ffi(cmd);

        (uint256[2] memory signature, uint256[4] memory pubkey) = abi.decode(out, (uint256[2], uint256[4]));

        return (signature, pubkey);
    }

    function toHexString(address addr) public pure returns (string memory) {
        bytes memory buffer = abi.encodePacked(addr);

        // Fixed buffer size for hexadecimal conversion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return string(abi.encodePacked("0x", converted));
    }
}
