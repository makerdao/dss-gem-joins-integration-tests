// SPDX-FileCopyrightText: © 2020 Dai Foundation <www.daifoundation.org>
// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.6.12;

import {DSTest}   from "ds-test/test.sol";

import {GemJoin} from "dss/join.sol";
import {GemJoin2} from "dss-gem-joins/join-2.sol";
import {GemJoin3} from "dss-gem-joins/join-3.sol";
import {GemJoin4} from "dss-gem-joins/join-4.sol";
import {GemJoin5} from "dss-gem-joins/join-5.sol";
import {GemJoin6} from "dss-gem-joins/join-6.sol";
import {GemJoin7} from "dss-gem-joins/join-7.sol";
import {GemJoin8} from "dss-gem-joins/join-8.sol";
import {GemJoin9} from "dss-gem-joins/join-9.sol";
import {AuthGemJoin} from "dss-gem-joins/join-auth.sol";
import {ManagedGemJoin} from "dss-gem-joins/join-managed.sol";

interface HEVM {
    function warp(uint256) external;
    function store(address, bytes32, bytes32) external;
    function load(address, bytes32) external returns (bytes32);
}

interface WardsLike {
    function wards(address) external view returns (uint256);
}

interface GemLike {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

interface VatLike {
    function wards(address) external view returns (uint256);
    function urns(bytes32, address) external view returns (uint256, uint256);
    function gem(bytes32, address) external view returns (uint256);
}

interface AAVE  is GemLike {}
interface BAL   is GemLike {}
interface BAT   is GemLike {}
interface COMP  is GemLike {}
interface DGD   is GemLike {}
interface GNT   is GemLike {}
interface GUSD  is GemLike {
    function getImplementation() external returns (address);
    function setImplementation(address) external;
}
interface KNC   is GemLike {}
interface LINK  is GemLike {}
interface LRC   is GemLike {}
interface MANA  is GemLike {}
interface MATIC is GemLike {}
interface OMG {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external; // no erc20 compliant
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

}

interface PAXG is GemLike {
    function feeRecipient() external view returns (address);
    function feeParts() external view returns (uint256);
    function feeRate() external view returns (uint256);
}

interface PAXUSD is GemLike {}
interface RENBTC is GemLike {}
interface REP    is GemLike {}
interface TUSD   is GemLike {
    function setImplementation(address) external;
}
interface UNI    is GemLike {}
interface USDC   is GemLike {}
interface USDT {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external; // no erc20 compliant
    function transfer(address, uint256) external;
    function transferFrom(address, address, uint256) external;
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function deprecate(address) external;
}
interface WBTC   is GemLike {}
interface YFI    is GemLike {}
interface ZRX    is GemLike {}
interface WSTETH is GemLike {}

interface SAI    is GemLike {}

contract GemJoinTest is DSTest {

    // --- HEVM ---
    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    HEVM hevm = HEVM(address(CHEAT_CODE));

    // --- DSS ---
    VatLike vat     = VatLike(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);

    // --- Tokens ---
    AAVE   aave     = AAVE(  0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);
    BAL    bal      = BAL(   0xba100000625a3754423978a60c9317c58a424e3D);
    BAT    bat      = BAT(   0x0D8775F648430679A709E98d2b0Cb6250d2887EF);
    COMP   comp     = COMP(  0xc00e94Cb662C3520282E6f5717214004A7f26888);
    DGD    dgd      = DGD(   0xE0B7927c4aF23765Cb51314A0E0521A9645F0E2A);
    GNT    gnt      = GNT(   0xa74476443119A942dE498590Fe1f2454d7D4aC0d);
    GUSD   gusd     = GUSD(  0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd);
    KNC    knc      = KNC(   0xdd974D5C2e2928deA5F71b9825b8b646686BD200);
    LINK   link     = LINK(  0x514910771AF9Ca656af840dff83E8264EcF986CA);
    LRC    lrc      = LRC(   0xBBbbCA6A901c926F240b89EacB641d8Aec7AEafD);
    MANA   mana     = MANA(  0x0F5D2fB29fb7d3CFeE444a200298f468908cC942);
    MATIC  matic    = MATIC( 0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0);
    OMG    omg      = OMG(   0xd26114cd6EE289AccF82350c8d8487fedB8A0C07);
    PAXG   paxg     = PAXG(  0x45804880De22913dAFE09f4980848ECE6EcbAf78);
    PAXUSD paxusd   = PAXUSD(0x8E870D67F660D95d5be530380D0eC0bd388289E1);
    RENBTC renbtc   = RENBTC(0xEB4C2781e4ebA804CE9a9803C67d0893436bB27D);
    REP    rep      = REP(   0x221657776846890989a759BA2973e427DfF5C9bB);
    TUSD   tusd     = TUSD(  0x0000000000085d4780B73119b644AE5ecd22b376);
    UNI    uni      = UNI(   0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
    USDC   usdc     = USDC(  0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    USDT   usdt     = USDT(  0xdAC17F958D2ee523a2206206994597C13D831ec7);
    WBTC   wbtc     = WBTC(  0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    YFI    yfi      = YFI(   0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e);
    ZRX    zrx      = ZRX(   0xE41d2489571d322189246DaFA5ebDe1F4699F498);
    WSTETH wsteth   = WSTETH(0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0);

    SAI    sai      = SAI(   0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);

    GUSD gusd_store = GUSD( 0xc42B14e49744538e3C239f8ae48A1Eaaf35e68a0);

    function getFeeFor(uint256 _value) internal view returns (uint256) {
        uint256 feeParts = paxg.feeParts();
        uint256 feeRate = paxg.feeRate();
        if (feeRate == 0) {
            return 0;
        }

        return _div(_mul(_value, feeRate), feeParts);
    }

    // --- Math ---
    uint256 internal constant  WAD      = 10 ** 18;
    function _mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y;
        assert(y == 0 || z / y == x);
    }
    function _div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function bytesToBytes32(bytes memory source) internal pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function giveAuth(address _base, address target) internal {
        WardsLike base = WardsLike(_base);

        // Edge case - ward is already set
        if (base.wards(target) == 1) return;

        for (int i = 0; i < 100; i++) {
            // Scan the storage for the ward storage slot
            bytes32 prevValue = hevm.load(
                address(base),
                keccak256(abi.encode(target, uint256(i)))
            );
            hevm.store(
                address(base),
                keccak256(abi.encode(target, uint256(i))),
                bytes32(uint256(1))
            );
            if (base.wards(target) == 1) {
                // Found it
                return;
            } else {
                // Keep going after restoring the original value
                hevm.store(
                    address(base),
                    keccak256(abi.encode(target, uint256(i))),
                    prevValue
                );
            }
        }

        // We have failed if we reach here
        assertTrue(false);
    }

    function giveTokens(address token, uint256 amount) internal {
        // Edge case - balance is already set for some reason
        if (GemLike(token).balanceOf(address(this)) == amount) return;

        // Scan the storage for the balance storage slot
        for (uint256 i = 0; i < 200; i++) {
            // Solidity-style storage layout for maps
            {
                bytes32 prevValue = hevm.load(
                    address(token),
                    keccak256(abi.encode(address(this), uint256(i)))
                );

                hevm.store(
                    address(token),
                    keccak256(abi.encode(address(this), uint256(i))),
                    bytes32(amount)
                );
                if (GemLike(token).balanceOf(address(this)) == amount) {
                    // Found it
                    return;
                } else {
                    // Keep going after restoring the original value
                    hevm.store(
                        address(token),
                        keccak256(abi.encode(address(this), uint256(i))),
                        prevValue
                    );
                }
            }

            // Vyper-style storage layout for maps
            {
                bytes32 prevValue = hevm.load(
                    address(token),
                    keccak256(abi.encode(uint256(i), address(this)))
                );

                hevm.store(
                    address(token),
                    keccak256(abi.encode(uint256(i), address(this))),
                    bytes32(amount)
                );
                if (GemLike(token).balanceOf(address(this)) == amount) {
                    // Found it
                    return;
                } else {
                    // Keep going after restoring the original value
                    hevm.store(
                        address(token),
                        keccak256(abi.encode(uint256(i), address(this))),
                        prevValue
                    );
                }
            }
        }

        // We have failed if we reach here
        assertTrue(false, "TestError/GiveTokens-slot-not-found");
    }

    function testGemJoin_REP() public {
        giveTokens(address(rep), 100 * WAD);
        GemJoin repJoin = new GemJoin(address(vat), "REP", address(rep));
        assertEq(repJoin.dec(), 18);
        giveAuth(address(vat), address(repJoin));

        rep.approve(address(repJoin), uint256(-1));
        assertEq(rep.balanceOf(address(this)), 100 * WAD);
        assertEq(rep.balanceOf(address(repJoin)), 0);
        assertEq(vat.gem("REP", address(this)), 0);
        repJoin.join(address(this), 10 * WAD);
        assertEq(rep.balanceOf(address(repJoin)), 10 * WAD);
        assertEq(vat.gem("REP", address(this)), 10 * WAD);
        repJoin.exit(address(this), 4 * WAD);
        assertEq(rep.balanceOf(address(this)), 94 * WAD);
        assertEq(rep.balanceOf(address(repJoin)), 6 * WAD);
        assertEq(vat.gem("REP", address(this)), 6 * WAD);
    }

    function testGemJoin_ZRX() public {
        giveTokens(address(zrx), 100 * WAD);
        GemJoin zrxJoin = new GemJoin(address(vat), "ZRX", address(zrx));
        assertEq(zrxJoin.dec(), 18);
        giveAuth(address(vat), address(zrxJoin));

        zrx.approve(address(zrxJoin), uint256(-1));
        assertEq(zrx.balanceOf(address(this)), 100 * WAD);
        assertEq(zrx.balanceOf(address(zrxJoin)), 0);
        assertEq(vat.gem("ZRX", address(this)), 0);
        zrxJoin.join(address(this), 10 * WAD);
        assertEq(zrx.balanceOf(address(zrxJoin)), 10 * WAD);
        assertEq(vat.gem("ZRX", address(this)), 10 * WAD);
        zrxJoin.exit(address(this), 4 * WAD);
        assertEq(zrx.balanceOf(address(this)), 94 * WAD);
        assertEq(zrx.balanceOf(address(zrxJoin)), 6 * WAD);
        assertEq(vat.gem("ZRX", address(this)), 6 * WAD);
    }

    function testGemJoin2_OMG() public {
        giveTokens(address(omg), 100 * WAD);
        GemJoin2 omgJoin = new GemJoin2(address(vat), "OMG", address(omg));
        assertEq(omgJoin.dec(), 18);
        giveAuth(address(vat), address(omgJoin));

        omg.approve(address(omgJoin), uint256(-1));
        assertEq(omg.balanceOf(address(this)), 100 * WAD);
        assertEq(omg.balanceOf(address(omgJoin)), 0);
        assertEq(vat.gem("OMG", address(this)), 0);
        omgJoin.join(address(this), 10 * WAD);
        assertEq(omg.balanceOf(address(omgJoin)), 10 * WAD);
        assertEq(vat.gem("OMG", address(this)), 10 * WAD);
        omgJoin.exit(address(this), 4 * WAD);
        assertEq(omg.balanceOf(address(this)), 94 * WAD);
        assertEq(omg.balanceOf(address(omgJoin)), 6 * WAD);
        assertEq(vat.gem("OMG", address(this)), 6 * WAD);
    }

    function testGemJoin_BAT() public {
        giveTokens(address(bat), 100 * WAD);
        GemJoin batJoin = new GemJoin(address(vat), "BAT", address(bat));
        assertEq(batJoin.dec(), 18);
        giveAuth(address(vat), address(batJoin));

        bat.approve(address(batJoin), uint256(-1));
        assertEq(bat.balanceOf(address(this)), 100 * WAD);
        assertEq(bat.balanceOf(address(batJoin)), 0);
        assertEq(vat.gem("BAT", address(this)), 0);
        batJoin.join(address(this), 10 * WAD);
        assertEq(bat.balanceOf(address(batJoin)), 10 * WAD);
        assertEq(vat.gem("BAT", address(this)), 10 * WAD);
        batJoin.exit(address(this), 4 * WAD);
        assertEq(bat.balanceOf(address(this)), 94 * WAD);
        assertEq(bat.balanceOf(address(batJoin)), 6 * WAD);
        assertEq(vat.gem("BAT", address(this)), 6 * WAD);
    }

    function testGemJoin3_DGD() public {
        giveTokens(address(dgd), 100 * 10**9);
        GemJoin3 dgdJoin = new GemJoin3(address(vat), "DGD", address(dgd), 9);
        assertEq(dgdJoin.dec(), 9);
        giveAuth(address(vat), address(dgdJoin));

        dgd.approve(address(dgdJoin), uint256(-1));
        assertEq(dgd.balanceOf(address(this)), 100 * 10 ** 9);
        assertEq(dgd.balanceOf(address(dgdJoin)), 0);
        assertEq(vat.gem("DGD", address(this)), 0);
        dgdJoin.join(address(this), 10 * 10 ** 9);
        assertEq(dgd.balanceOf(address(dgdJoin)), 10 * 10 ** 9);
        assertEq(vat.gem("DGD", address(this)), 10 * WAD);
        dgdJoin.exit(address(this), 4 * 10 ** 9);
        assertEq(dgd.balanceOf(address(this)), 94 * 10 ** 9);
        assertEq(dgd.balanceOf(address(dgdJoin)), 6 * 10 ** 9);
        assertEq(vat.gem("DGD", address(this)), 6 * WAD);
    }

    function testGemJoin4_GNT() public {
        giveTokens(address(gnt), 100 * WAD);
        GemJoin4 gntJoin = new GemJoin4(address(vat), "GNT", address(gnt));
        assertEq(gntJoin.dec(), 18);
        giveAuth(address(vat), address(gntJoin));

        assertEq(gnt.balanceOf(address(this)), 100 * WAD);
        assertEq(gnt.balanceOf(address(gntJoin)), 0);
        assertEq(vat.gem("GNT", address(this)), 0);
        address bag = gntJoin.make();
        gnt.transfer(bag, 10 * WAD);
        gntJoin.join(address(this), 10 * WAD);
        assertEq(gnt.balanceOf(address(gntJoin)), 10 * WAD);
        assertEq(vat.gem("GNT", address(this)), 10 * WAD);
        gntJoin.exit(address(this), 4 * WAD);
        assertEq(gnt.balanceOf(address(this)), 94 * WAD);
        assertEq(gnt.balanceOf(address(gntJoin)), 6 * WAD);
        assertEq(vat.gem("GNT", address(this)), 6 * WAD);
    }

    function testGemJoin5_USDC() public {
        giveTokens(address(usdc), 100 * 10**6);
        GemJoin5 usdcJoin = new GemJoin5(address(vat), "USDC", address(usdc));
        assertEq(usdcJoin.dec(), 6);
        giveAuth(address(vat), address(usdcJoin));

        usdc.approve(address(usdcJoin), uint256(-1));
        assertEq(usdc.balanceOf(address(this)), 100 * 10 ** 6);
        assertEq(usdc.balanceOf(address(usdcJoin)), 0);
        assertEq(vat.gem("USDC", address(this)), 0);
        usdcJoin.join(address(this), 10 * 10 ** 6);
        assertEq(usdc.balanceOf(address(usdcJoin)), 10 * 10 ** 6);
        assertEq(vat.gem("USDC", address(this)), 10 * WAD);
        usdcJoin.exit(address(this), 4 * 10 ** 6);
        assertEq(usdc.balanceOf(address(this)), 94 * 10 ** 6);
        assertEq(usdc.balanceOf(address(usdcJoin)), 6 * 10 ** 6);
        assertEq(vat.gem("USDC", address(this)), 6 * WAD);
    }

    function testGemJoin5_WBTC() public {
        giveTokens(address(wbtc), 100 * 10**8);
        GemJoin5 wbtcJoin = new GemJoin5(address(vat), "WBTC", address(wbtc));
        assertEq(wbtcJoin.dec(), 8);
        giveAuth(address(vat), address(wbtcJoin));

        wbtc.approve(address(wbtcJoin), uint256(-1));
        assertEq(wbtc.balanceOf(address(this)), 100 * 10 ** 8);
        assertEq(wbtc.balanceOf(address(wbtcJoin)), 0);
        assertEq(vat.gem("WBTC", address(this)), 0);
        wbtcJoin.join(address(this), 10 * 10 ** 8);
        assertEq(wbtc.balanceOf(address(wbtcJoin)), 10 * 10 ** 8);
        assertEq(vat.gem("WBTC", address(this)), 10 * WAD);
        wbtcJoin.exit(address(this), 4 * 10 ** 8);
        assertEq(wbtc.balanceOf(address(this)), 94 * 10 ** 8);
        assertEq(wbtc.balanceOf(address(wbtcJoin)), 6 * 10 ** 8);
        assertEq(vat.gem("WBTC", address(this)), 6 * WAD);
    }

    function testGemJoin6_TUSD() public {
        giveTokens(address(tusd), 100 * WAD);
        GemJoin6 tusdJoin = new GemJoin6(address(vat), "TUSD", address(tusd));
        assertEq(tusdJoin.dec(), 18);
        giveAuth(address(vat), address(tusdJoin));

        tusd.approve(address(tusdJoin), uint256(-1));
        assertEq(tusd.balanceOf(address(this)), 100 * WAD);
        assertEq(tusd.balanceOf(address(tusdJoin)), 0);
        assertEq(vat.gem("TUSD", address(this)), 0);
        tusdJoin.join(address(this), 10 * WAD);
        assertEq(tusd.balanceOf(address(tusdJoin)), 10 * WAD);
        assertEq(vat.gem("TUSD", address(this)), 10 * WAD);
        tusdJoin.exit(address(this), 4 * WAD);
        assertEq(tusd.balanceOf(address(this)), 94 * WAD);
        assertEq(tusd.balanceOf(address(tusdJoin)), 6 * WAD);
        assertEq(vat.gem("TUSD", address(this)), 6 * WAD);
    }

    function testGemJoin_KNC() public {
        giveTokens(address(knc), 100 * WAD);
        GemJoin kncJoin = new GemJoin(address(vat), "KNC", address(knc));
        assertEq(kncJoin.dec(), 18);
        giveAuth(address(vat), address(kncJoin));

        knc.approve(address(kncJoin), uint256(-1));
        assertEq(knc.balanceOf(address(this)), 100 * WAD);
        assertEq(knc.balanceOf(address(kncJoin)), 0);
        assertEq(vat.gem("KNC", address(this)), 0);
        kncJoin.join(address(this), 10 * WAD);
        assertEq(knc.balanceOf(address(kncJoin)), 10 * WAD);
        assertEq(vat.gem("KNC", address(this)), 10 * WAD);
        kncJoin.exit(address(this), 4 * WAD);
        assertEq(knc.balanceOf(address(this)), 94 * WAD);
        assertEq(knc.balanceOf(address(kncJoin)), 6 * WAD);
        assertEq(vat.gem("KNC", address(this)), 6 * WAD);
    }

    function testGemJoin_MANA() public {
        giveTokens(address(mana), 100 * WAD);
        GemJoin manaJoin = new GemJoin(address(vat), "MANA", address(mana));
        assertEq(manaJoin.dec(), 18);
        giveAuth(address(vat), address(manaJoin));

        mana.approve(address(manaJoin), uint256(-1));
        assertEq(mana.balanceOf(address(this)), 100 * WAD);
        assertEq(mana.balanceOf(address(manaJoin)), 0);
        assertEq(vat.gem("MANA", address(this)), 0);
        manaJoin.join(address(this), 10 * WAD);
        assertEq(mana.balanceOf(address(manaJoin)), 10 * WAD);
        assertEq(vat.gem("MANA", address(this)), 10 * WAD);
        manaJoin.exit(address(this), 4 * WAD);
        assertEq(mana.balanceOf(address(this)), 94 * WAD);
        assertEq(mana.balanceOf(address(manaJoin)), 6 * WAD);
        assertEq(vat.gem("MANA", address(this)), 6 * WAD);
    }

    function testGemJoin7_USDT() public {
        giveTokens(address(usdt), 100 * 10**6);
        GemJoin7 usdtJoin = new GemJoin7(address(vat), "USDT", address(usdt));
        assertEq(usdtJoin.dec(), 6);
        giveAuth(address(vat), address(usdtJoin));

        usdt.approve(address(usdtJoin), uint256(-1));
        assertEq(usdt.balanceOf(address(this)), 100 * 10 ** 6);
        assertEq(usdt.balanceOf(address(usdtJoin)), 0);
        assertEq(vat.gem("USDT", address(this)), 0);
        usdtJoin.join(address(this), 10 * 10 ** 6);
        assertEq(usdt.balanceOf(address(usdtJoin)), 10 * 10 ** 6);
        assertEq(vat.gem("USDT", address(this)), 10 * WAD);
        usdtJoin.exit(address(this), 4 * 10 ** 6);
        assertEq(usdt.balanceOf(address(this)), 94 * 10 ** 6);
        assertEq(usdt.balanceOf(address(usdtJoin)), 6 * 10 ** 6);
        assertEq(vat.gem("USDT", address(this)), 6 * WAD);
    }

    function testGemJoin_PAXUSD() public {
        giveTokens(address(paxusd), 100 * WAD);
        GemJoin paxusdJoin = new GemJoin(address(vat), "PAXUSD", address(paxusd));
        assertEq(paxusdJoin.dec(), 18);
        giveAuth(address(vat), address(paxusdJoin));

        paxusd.approve(address(paxusdJoin), uint256(-1));
        assertEq(paxusd.balanceOf(address(this)), 100 * WAD);
        assertEq(paxusd.balanceOf(address(paxusdJoin)), 0);
        assertEq(vat.gem("PAXUSD", address(this)), 0);
        paxusdJoin.join(address(this), 10 * WAD);
        assertEq(paxusd.balanceOf(address(paxusdJoin)), 10 * WAD);
        assertEq(vat.gem("PAXUSD", address(this)), 10 * WAD);
        paxusdJoin.exit(address(this), 4 * WAD);
        assertEq(paxusd.balanceOf(address(this)), 94 * WAD);
        assertEq(paxusd.balanceOf(address(paxusdJoin)), 6 * WAD);
        assertEq(vat.gem("PAXUSD", address(this)), 6 * WAD);
    }

    function testGemJoin_COMP() public {
        giveTokens(address(comp), 100 * WAD);
        GemJoin compJoin = new GemJoin(address(vat), "COMP", address(comp));
        assertEq(compJoin.dec(), 18);
        giveAuth(address(vat), address(compJoin));

        comp.approve(address(compJoin), uint256(-1));
        assertEq(comp.balanceOf(address(this)), 100 * WAD);
        assertEq(comp.balanceOf(address(compJoin)), 0);
        assertEq(vat.gem("COMP", address(this)), 0);
        compJoin.join(address(this), 10 * WAD);
        assertEq(comp.balanceOf(address(compJoin)), 10 * WAD);
        assertEq(vat.gem("COMP", address(this)), 10 * WAD);
        compJoin.exit(address(this), 4 * WAD);
        assertEq(comp.balanceOf(address(this)), 94 * WAD);
        assertEq(comp.balanceOf(address(compJoin)), 6 * WAD);
        assertEq(vat.gem("COMP", address(this)), 6 * WAD);
    }

    function testGemJoin_UNI() public {
        giveTokens(address(uni), 100 * WAD);
        GemJoin uniJoin = new GemJoin(address(vat), "UNI", address(uni));
        assertEq(uniJoin.dec(), 18);
        giveAuth(address(vat), address(uniJoin));

        uni.approve(address(uniJoin), uint256(-1));
        assertEq(uni.balanceOf(address(this)), 100 * WAD);
        assertEq(uni.balanceOf(address(uniJoin)), 0);
        assertEq(vat.gem("UNI", address(this)), 0);
        uniJoin.join(address(this), 10 * WAD);
        assertEq(uni.balanceOf(address(uniJoin)), 10 * WAD);
        assertEq(vat.gem("UNI", address(this)), 10 * WAD);
        uniJoin.exit(address(this), 4 * WAD);
        assertEq(uni.balanceOf(address(this)), 94 * WAD);
        assertEq(uni.balanceOf(address(uniJoin)), 6 * WAD);
        assertEq(vat.gem("UNI", address(this)), 6 * WAD);
    }

    function testGemJoin_AAVE() public {
        giveTokens(address(aave), 100 * WAD);
        GemJoin aaveJoin = new GemJoin(address(vat), "AAVE", address(aave));
        assertEq(aaveJoin.dec(), 18);
        giveAuth(address(vat), address(aaveJoin));

        aave.approve(address(aaveJoin), uint256(-1));
        assertEq(aave.balanceOf(address(this)), 100 * WAD);
        assertEq(aave.balanceOf(address(aaveJoin)), 0);
        assertEq(vat.gem("AAVE", address(this)), 0);
        aaveJoin.join(address(this), 10 * WAD);
        assertEq(aave.balanceOf(address(aaveJoin)), 10 * WAD);
        assertEq(vat.gem("AAVE", address(this)), 10 * WAD);
        aaveJoin.exit(address(this), 4 * WAD);
        assertEq(aave.balanceOf(address(this)), 94 * WAD);
        assertEq(aave.balanceOf(address(aaveJoin)), 6 * WAD);
        assertEq(vat.gem("AAVE", address(this)), 6 * WAD);
    }

    function testGemJoin_MATIC() public {
        giveTokens(address(matic), 100 * WAD);
        GemJoin maticJoin = new GemJoin(address(vat), "MATIC", address(matic));
        assertEq(maticJoin.dec(), 18);
        giveAuth(address(vat), address(maticJoin));

        matic.approve(address(maticJoin), uint256(-1));
        assertEq(matic.balanceOf(address(this)), 100 * WAD);
        assertEq(matic.balanceOf(address(maticJoin)), 0);
        assertEq(vat.gem("MATIC", address(this)), 0);
        maticJoin.join(address(this), 10 * WAD);
        assertEq(matic.balanceOf(address(maticJoin)), 10 * WAD);
        assertEq(vat.gem("MATIC", address(this)), 10 * WAD);
        maticJoin.exit(address(this), 4 * WAD);
        assertEq(matic.balanceOf(address(this)), 94 * WAD);
        assertEq(matic.balanceOf(address(maticJoin)), 6 * WAD);
        assertEq(vat.gem("MATIC", address(this)), 6 * WAD);
    }

    function testGemJoin_LRC() public {
        giveTokens(address(lrc), 100 * WAD);
        GemJoin lrcJoin = new GemJoin(address(vat), "LRC", address(lrc));
        assertEq(lrcJoin.dec(), 18);
        giveAuth(address(vat), address(lrcJoin));

        lrc.approve(address(lrcJoin), uint256(-1));
        assertEq(lrc.balanceOf(address(this)), 100 * WAD);
        assertEq(lrc.balanceOf(address(lrcJoin)), 0);
        assertEq(vat.gem("LRC", address(this)), 0);
        lrcJoin.join(address(this), 10 * WAD);
        assertEq(lrc.balanceOf(address(lrcJoin)), 10 * WAD);
        assertEq(vat.gem("LRC", address(this)), 10 * WAD);
        lrcJoin.exit(address(this), 4 * WAD);
        assertEq(lrc.balanceOf(address(this)), 94 * WAD);
        assertEq(lrc.balanceOf(address(lrcJoin)), 6 * WAD);
        assertEq(vat.gem("LRC", address(this)), 6 * WAD);
    }

    function testGemJoin_LINK() public {
        giveTokens(address(link), 100 * WAD);
        GemJoin linkJoin = new GemJoin(address(vat), "LINK", address(link));
        assertEq(linkJoin.dec(), 18);
        giveAuth(address(vat), address(linkJoin));

        link.approve(address(linkJoin), uint256(-1));
        assertEq(link.balanceOf(address(this)), 100 * WAD);
        assertEq(link.balanceOf(address(linkJoin)), 0);
        assertEq(vat.gem("LINK", address(this)), 0);
        linkJoin.join(address(this), 10 * WAD);
        assertEq(link.balanceOf(address(linkJoin)), 10 * WAD);
        assertEq(vat.gem("LINK", address(this)), 10 * WAD);
        linkJoin.exit(address(this), 4 * WAD);
        assertEq(link.balanceOf(address(this)), 94 * WAD);
        assertEq(link.balanceOf(address(linkJoin)), 6 * WAD);
        assertEq(vat.gem("LINK", address(this)), 6 * WAD);
    }

    function testGemJoin_BAL() public {
        giveTokens(address(bal), 100 * WAD);
        GemJoin balJoin = new GemJoin(address(vat), "BAL", address(bal));
        assertEq(balJoin.dec(), 18);
        giveAuth(address(vat), address(balJoin));

        bal.approve(address(balJoin), uint256(-1));
        assertEq(bal.balanceOf(address(this)), 100 * WAD);
        assertEq(bal.balanceOf(address(balJoin)), 0);
        assertEq(vat.gem("BAL", address(this)), 0);
        balJoin.join(address(this), 10 * WAD);
        assertEq(bal.balanceOf(address(balJoin)), 10 * WAD);
        assertEq(vat.gem("BAL", address(this)), 10 * WAD);
        balJoin.exit(address(this), 4 * WAD);
        assertEq(bal.balanceOf(address(this)), 94 * WAD);
        assertEq(bal.balanceOf(address(balJoin)), 6 * WAD);
        assertEq(vat.gem("BAL", address(this)), 6 * WAD);
    }

    function testGemJoin_YFI() public {
        giveTokens(address(yfi), 100 * WAD);
        GemJoin yfiJoin = new GemJoin(address(vat), "YFI", address(yfi));
        assertEq(yfiJoin.dec(), 18);
        giveAuth(address(vat), address(yfiJoin));

        yfi.approve(address(yfiJoin), uint256(-1));
        assertEq(yfi.balanceOf(address(this)), 100 * WAD);
        assertEq(yfi.balanceOf(address(yfiJoin)), 0);
        assertEq(vat.gem("YFI", address(this)), 0);
        yfiJoin.join(address(this), 10 * WAD);
        assertEq(yfi.balanceOf(address(yfiJoin)), 10 * WAD);
        assertEq(vat.gem("YFI", address(this)), 10 * WAD);
        yfiJoin.exit(address(this), 4 * WAD);
        assertEq(yfi.balanceOf(address(this)), 94 * WAD);
        assertEq(yfi.balanceOf(address(yfiJoin)), 6 * WAD);
        assertEq(vat.gem("YFI", address(this)), 6 * WAD);
    }

    function testGemJoin8_GUSD() public {
        uint256 ilkAmt = 100 * 100; // GUSD has 2 decimals
        hevm.store(
            address(gusd_store),
            keccak256(abi.encode(address(this), uint256(6))),
            bytes32(ilkAmt)
        );
        GemJoin8 gusdJoin = new GemJoin8(address(vat), "GUSD", address(gusd));
        assertEq(gusdJoin.dec(), 2);
        giveAuth(address(vat), address(gusdJoin));

        gusd.approve(address(gusdJoin), uint256(-1));
        assertEq(gusd.balanceOf(address(this)), 100 * 10 ** 2);
        assertEq(gusd.balanceOf(address(gusdJoin)), 0);
        assertEq(vat.gem("GUSD", address(this)), 0);
        gusdJoin.join(address(this), 10 * 10 ** 2);
        assertEq(gusd.balanceOf(address(gusdJoin)), 10 * 10 ** 2);
        assertEq(vat.gem("GUSD", address(this)), 10 * WAD);
        gusdJoin.exit(address(this), 4 * 10 ** 2);
        assertEq(gusd.balanceOf(address(this)), 94 * 10 ** 2);
        assertEq(gusd.balanceOf(address(gusdJoin)), 6 * 10 ** 2);
        assertEq(vat.gem("GUSD", address(this)), 6 * WAD);
    }

    function testGemJoin_PAXG() public {
        giveTokens(address(paxg), 100 * WAD);
        GemJoin9 paxgJoin = new GemJoin9(address(vat), "PAXG", address(paxg));
        giveAuth(address(vat), address(paxgJoin));

        paxg.approve(address(paxgJoin), uint256(-1));
        assertEq(paxg.balanceOf(address(this)), 100 * WAD);
        assertEq(paxg.balanceOf(address(paxgJoin)), 0);
        assertEq(vat.gem("PAXG", address(this)), 0);
        paxgJoin.join(address(this), 10 * WAD);
        uint256 prevBalanceThis = paxg.balanceOf(address(this));
        uint256 netAmt = 10 * WAD - getFeeFor(10 * WAD);
        uint256 netAmt2 = netAmt - getFeeFor(netAmt);
        assertEq(paxg.balanceOf(address(paxgJoin)), netAmt);
        assertEq(vat.gem("PAXG", address(this)), netAmt);
        paxgJoin.exit(address(this), netAmt);
        assertEq(paxg.balanceOf(address(this)), prevBalanceThis + netAmt2);
        assertEq(paxg.balanceOf(address(paxgJoin)), 0);
        assertEq(vat.gem("PAXG", address(this)), 0);
    }

    function testGemJoin5_RENBTC() public {
        giveTokens(address(renbtc), 100 * 10**8);
        GemJoin5 renbtcJoin = new GemJoin5(address(vat), "RENBTC", address(renbtc));
        assertEq(renbtcJoin.dec(), 8);
        giveAuth(address(vat), address(renbtcJoin));

        renbtc.approve(address(renbtcJoin), uint256(-1));
        assertEq(renbtc.balanceOf(address(this)), 100 * 10 ** 8);
        assertEq(renbtc.balanceOf(address(renbtcJoin)), 0);
        assertEq(vat.gem("RENBTC", address(this)), 0);
        renbtcJoin.join(address(this), 10 * 10 ** 8);
        assertEq(renbtc.balanceOf(address(renbtcJoin)), 10 * 10 ** 8);
        assertEq(vat.gem("RENBTC", address(this)), 10 * WAD);
        renbtcJoin.exit(address(this), 4 * 10 ** 8);
        assertEq(renbtc.balanceOf(address(this)), 94 * 10 ** 8);
        assertEq(renbtc.balanceOf(address(renbtcJoin)), 6 * 10 ** 8);
        assertEq(vat.gem("RENBTC", address(this)), 6 * WAD);
    }

    function testFailGemJoin6Join() public {
        giveTokens(address(tusd), 100 * WAD);
        GemJoin6 tusdJoin = new GemJoin6(address(vat), "TUSD", address(tusd));
        giveAuth(address(vat), address(tusdJoin));

        tusd.approve(address(tusdJoin), uint256(-1));
        assertEq(tusd.balanceOf(address(this)), 100 * WAD);
        assertEq(tusd.balanceOf(address(tusdJoin)), 0);
        assertEq(vat.gem("TUSD", address(this)), 0);
        tusd.setImplementation(0xCB9a11afDC6bDb92E4A6235959455F28758b34bA);
        // Fail here
        tusdJoin.join(address(this), 10 * WAD);
    }

    function testFailGemJoin6Exit() public {
        giveTokens(address(tusd), 100 * WAD);
        GemJoin6 tusdJoin = new GemJoin6(address(vat), "TUSD", address(tusd));
        giveAuth(address(vat), address(tusdJoin));

        tusd.approve(address(tusdJoin), uint256(-1));
        tusdJoin.join(address(this), 10 * WAD);
        tusd.setImplementation(0xCB9a11afDC6bDb92E4A6235959455F28758b34bA);
        // Fail here
        tusdJoin.exit(address(this), 10 * WAD);
    }

    function testFailGemJoin7JoinWad() public {
        giveTokens(address(usdt), 100 * 10**6);
        GemJoin7 usdtJoin = new GemJoin7(address(vat), "USDT", address(usdt));
        usdt.approve(address(usdtJoin), uint256(-1));
        giveAuth(address(vat), address(usdtJoin));

        // Fail here
        usdtJoin.join(address(this), 10 * WAD);
    }

    function testFailGemJoin7ExitWad() public {
        giveTokens(address(gnt), 100 * 10**6);
        GemJoin7 usdtJoin = new GemJoin7(address(vat), "USDT", address(usdt));
        usdt.approve(address(usdtJoin), uint256(-1));
        giveAuth(address(vat), address(usdtJoin));

        usdtJoin.join(address(this), 10 * 10 ** 6);
        // Fail here
        usdtJoin.exit(address(this), 10 * WAD);
    }

    function testFailGemJoin7Join() public {
        giveTokens(address(usdt), 100 * 10**6);
        GemJoin7 usdtJoin = new GemJoin7(address(vat), "USDT", address(usdt));
        usdt.approve(address(usdtJoin), uint256(-1));
        giveAuth(address(vat), address(usdtJoin));

        assertEq(usdt.balanceOf(address(this)), 100 * 10 ** 6);
        assertEq(usdt.balanceOf(address(usdtJoin)), 0);
        assertEq(vat.gem("USDT", address(this)), 0);
        // Set owner to address(this)
        hevm.store(
            address(usdt),
            bytes32(uint256(0)),
            bytesToBytes32(abi.encode(address(this)))
        );
        usdt.deprecate(address(1));
        // Fail here
        usdtJoin.join(address(this), 10 * 10 ** 6);
    }

    function testFailGemJoin7Exit() public {
        giveTokens(address(usdt), 100 * 10**6);
        GemJoin7 usdtJoin = new GemJoin7(address(vat), "USDT", address(usdt));
        usdt.approve(address(usdtJoin), uint256(-1));
        giveAuth(address(vat), address(usdtJoin));

        usdtJoin.join(address(this), 10 * 10 ** 6);
        // Set owner to address(this)
        hevm.store(
            address(usdt),
            bytes32(uint256(0)),
            bytesToBytes32(abi.encode(address(this)))
        );
        usdt.deprecate(address(1));
        // Fail here
        usdtJoin.exit(address(this), 10 * 10 ** 6);
    }

    function testGemJoin7FeeChange() public {
        giveTokens(address(usdt), 100 * 10**6);
        GemJoin7 usdtJoin = new GemJoin7(address(vat), "USDT", address(usdt));
        giveAuth(address(vat), address(usdtJoin));

        // auxiliary function added, not in tether source code
        // basisPointsRate = 1, maximumFee = 1
        uint256 basisPointsRate = 100;
        uint256 maximumFee = 100;
        hevm.store(
            address(usdt),
            bytes32(uint256(3)),
            bytes32(basisPointsRate)
        );
        hevm.store(
            address(usdt),
            bytes32(uint256(4)),
            bytes32(maximumFee)
        );

        usdt.approve(address(usdtJoin), uint256(-1));
        usdtJoin.join(address(this), 1 * 10 ** 6);
        uint256 joinbal = vat.gem("USDT", address(this));

        assertEq(usdt.balanceOf(address(usdtJoin)), 999900);
        assertEq(joinbal, 999900 * 10 ** 12);
        usdtJoin.exit(address(this), 999900); // exit in 10 ** 6
        uint256 exitbal = usdt.balanceOf(address(this));
        assertEq(exitbal, 99999800);
    }

    function testFailGemJoin8JoinWad() public {
        uint256 ilkAmt = 100 * 100; // GUSD has 2 decimals
        hevm.store(
            address(gusd_store),
            keccak256(abi.encode(address(this), uint256(6))),
            bytes32(ilkAmt)
        );
        GemJoin8 gusdJoin = new GemJoin8(address(vat), "GUSD", address(gusd));
        gusd.approve(address(gusdJoin), uint256(-1));
        giveAuth(address(vat), address(gusdJoin));

        // Fail here
        gusdJoin.join(address(this), 10 * WAD);
    }

    function testFailGemJoin8ExitWad() public {
        uint256 ilkAmt = 100 * 100; // GUSD has 2 decimals
        hevm.store(
            address(gusd_store),
            keccak256(abi.encode(address(this), uint256(6))),
            bytes32(ilkAmt)
        );
        GemJoin8 gusdJoin = new GemJoin8(address(vat), "GUSD", address(gusd));
        gusd.approve(address(gusdJoin), uint256(-1));
        giveAuth(address(vat), address(gusdJoin));

        gusdJoin.join(address(this), 10 * 10 ** 2);
        // Fail here
        gusdJoin.exit(address(this), 10 * WAD);
    }

    function testFailGemJoin8Join() public {
        uint256 ilkAmt = 100 * 100; // GUSD has 2 decimals
        hevm.store(
            address(gusd_store),
            keccak256(abi.encode(address(this), uint256(6))),
            bytes32(ilkAmt)
        );
        GemJoin8 gusdJoin = new GemJoin8(address(vat), "GUSD", address(gusd));
        giveAuth(address(vat), address(gusdJoin));

        gusd.approve(address(gusdJoin), uint256(-1));
        assertEq(gusd.balanceOf(address(this)), 100 * 10 ** 2);
        assertEq(gusd.balanceOf(address(gusdJoin)), 0);
        assertEq(vat.gem("GUSD", address(this)), 0);
        gusd.setImplementation(address(1));
        // Fail here
        gusdJoin.join(address(this), 10 * 10 ** 2);
    }

    function testFailGemJoin8Exit() public {
        uint256 ilkAmt = 100 * 100; // GUSD has 2 decimals
        hevm.store(
            address(gusd_store),
            keccak256(abi.encode(address(this), uint256(6))),
            bytes32(ilkAmt)
        );
        GemJoin8 gusdJoin = new GemJoin8(address(vat), "GUSD", address(gusd));
        giveAuth(address(vat), address(gusdJoin));

        gusd.approve(address(gusdJoin), uint256(-1));
        gusdJoin.join(address(this), 10 * 10 ** 2);
        gusd.setImplementation(address(1));
        // Fail here
        gusdJoin.exit(address(this), 10 * 10 ** 2);
    }

    function testFailGemJoin9JoinWad() public {
        giveTokens(address(paxg), 100 * WAD);
        GemJoin9 paxgJoin = new GemJoin9(address(vat), "PAXG", address(paxg));
        giveAuth(address(vat), address(paxgJoin));

        paxg.approve(address(paxgJoin), uint256(-1));
        // Fail here
        paxgJoin.join(address(this), 1000 * WAD);
    }

    function testFailGemJoin9ExitWad() public {
        giveTokens(address(paxg), 100 * WAD);
        GemJoin9 paxgJoin = new GemJoin9(address(vat), "PAXG", address(paxg));
        giveAuth(address(vat), address(paxgJoin));

        paxg.approve(address(paxgJoin), uint256(-1));
        paxgJoin.join(address(this), 10 * WAD);
        // Fail here
        paxgJoin.exit(address(this), 100 * WAD);
    }

    function testGemJoin9JoinFee() public {
        giveTokens(address(paxg), 100 * WAD);
        GemJoin9 paxgJoin = new GemJoin9(address(vat), "PAXG", address(paxg));
        giveAuth(address(vat), address(paxgJoin));

        paxg.approve(address(paxgJoin), uint256(-1));
        assertEq(paxg.balanceOf(address(this)), 100 * WAD);
        assertEq(paxg.balanceOf(address(paxgJoin)), 0);
        assertEq(vat.gem("PAXG", address(this)), 0);
        uint256 prevRecipientBalance = paxg.balanceOf(paxg.feeRecipient());
        uint256 netAmt = 100 * WAD - getFeeFor(100 * WAD);
        uint256 netAmt2 = netAmt - getFeeFor(netAmt);
        paxgJoin.join(address(this), 100 * WAD);
        assertEq(paxg.balanceOf(address(this)), 0);
        assertEq(paxg.balanceOf(address(paxgJoin)), netAmt);
        assertEq(paxgJoin.total(), paxg.balanceOf(address(paxgJoin)));
        assertEq(vat.gem("PAXG", address(this)), netAmt);
        assertEq(paxg.balanceOf(paxg.feeRecipient()), prevRecipientBalance + getFeeFor(100 * WAD));
        prevRecipientBalance = paxg.balanceOf(paxg.feeRecipient());
        paxgJoin.exit(address(this), netAmt);
        assertEq(paxg.balanceOf(address(this)), netAmt2);
        assertEq(paxg.balanceOf(address(paxgJoin)), 0);
        assertEq(vat.gem("PAXG", address(this)), 0);
        assertEq(paxg.balanceOf(paxg.feeRecipient()), prevRecipientBalance + getFeeFor(netAmt));
        assertEq(paxgJoin.total(), paxg.balanceOf(address(paxgJoin)));
    }

    function testFailGemJoin9JoinFee() public {
        giveTokens(address(paxg), 100 * WAD);
        GemJoin9 paxgJoin = new GemJoin9(address(vat), "PAXG", address(paxg));
        giveAuth(address(vat), address(paxgJoin));

        paxg.approve(address(paxgJoin), uint256(-1));
        assertEq(paxg.balanceOf(address(this)), 100 * WAD);
        assertEq(paxg.balanceOf(address(paxgJoin)), 0);
        assertEq(vat.gem("PAXG", address(this)), 0);
        paxgJoin.join(address(this), 100 * WAD);
        // Fail here
        paxgJoin.exit(address(this), 100 * WAD);
    }

    function testGemJoin9JoinDirectFee() public {
        giveTokens(address(paxg), 100 * WAD);
        GemJoin9 paxgJoin = new GemJoin9(address(vat), "PAXG", address(paxg));
        giveAuth(address(vat), address(paxgJoin));

        assertEq(paxg.balanceOf(address(this)), 100 * WAD);
        assertEq(paxg.balanceOf(address(paxgJoin)), 0);
        assertEq(vat.gem("PAXG", address(this)), 0);
        uint256 prevRecipientBalance = paxg.balanceOf(paxg.feeRecipient());
        uint256 netAmt = 100 * WAD - getFeeFor(100 * WAD);
        uint256 netAmt2 = netAmt - getFeeFor(netAmt);
        paxg.transfer(address(paxgJoin), 100 * WAD);
        paxgJoin.join(address(this));
        assertEq(paxg.balanceOf(address(this)), 0);
        assertEq(paxg.balanceOf(address(paxgJoin)), netAmt);
        assertEq(vat.gem("PAXG", address(this)), netAmt);
        assertEq(paxg.balanceOf(paxg.feeRecipient()), prevRecipientBalance + getFeeFor(100 * WAD));
        assertEq(paxgJoin.total(), paxg.balanceOf(address(paxgJoin)));
        prevRecipientBalance = paxg.balanceOf(paxg.feeRecipient());
        paxgJoin.exit(address(this), netAmt);
        assertEq(paxg.balanceOf(address(this)), netAmt2);
        assertEq(paxg.balanceOf(address(paxgJoin)), 0);
        assertEq(vat.gem("PAXG", address(this)), 0);
        assertEq(paxg.balanceOf(paxg.feeRecipient()), prevRecipientBalance + getFeeFor(netAmt));
        assertEq(paxgJoin.total(), paxg.balanceOf(address(paxgJoin)));
    }
 
    function testFailManagedGemJoinJoinWad() public {
        giveTokens(address(wbtc), 100 * 10**8);
        ManagedGemJoin wbtcJoin = new ManagedGemJoin(address(vat), "WBTC", address(wbtc));
        giveAuth(address(vat), address(wbtcJoin));

        wbtc.approve(address(wbtcJoin), uint256(-1));

        // Fail here
        wbtcJoin.join(address(this), 10 * WAD);
    }

    function testFailManagedGemJoinExitWad() public {
        giveTokens(address(wbtc), 100 * 10**8);
        ManagedGemJoin wbtcJoin = new ManagedGemJoin(address(vat), "WBTC", address(wbtc));
        giveAuth(address(vat), address(wbtcJoin));

        wbtc.approve(address(wbtcJoin), uint256(-1));
        wbtcJoin.join(address(this), 10 * 10 ** 8);
        // Fail here
        wbtcJoin.exit(address(this), address(this), 10 * WAD);
    }

    function testFailManagedGemJoinJoin() public {
        giveTokens(address(wbtc), 100 * 10**8);
        ManagedGemJoin wbtcJoin = new ManagedGemJoin(address(vat), "WBTC", address(wbtc));
        giveAuth(address(vat), address(wbtcJoin));

        wbtc.approve(address(wbtcJoin), uint256(-1));
        wbtcJoin.deny(address(this));
        wbtcJoin.join(address(this), 10);
    }

    function testFailManagedGemJoinExit() public {
        giveTokens(address(wbtc), 100 * 10**8);
        ManagedGemJoin wbtcJoin = new ManagedGemJoin(address(vat), "WBTC", address(wbtc));
        giveAuth(address(vat), address(wbtcJoin));

        wbtc.approve(address(wbtcJoin), uint256(-1));
        wbtcJoin.join(address(this), 10);
        wbtcJoin.deny(address(this));
        wbtcJoin.exit(address(this), address(this), 10);
    }

    function testFailJoinAfterCageGemJoin2() public {
        giveTokens(address(omg), 100 * WAD);
        GemJoin2 omgJoin = new GemJoin2(address(vat), "OMG", address(omg));
        giveAuth(address(vat), address(omgJoin));

        omg.approve(address(omgJoin), uint256(-1));
        omgJoin.join(address(this), 10);
        omgJoin.cage();
        omgJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageGemJoin3() public {
        giveTokens(address(dgd), 100 * WAD);
        GemJoin3 dgdJoin = new GemJoin3(address(vat), "DGD", address(dgd), 9);
        giveAuth(address(vat), address(dgdJoin));

        dgd.approve(address(dgdJoin), uint256(-1));
        dgdJoin.join(address(this), 10);
        dgdJoin.cage();
        dgdJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageGemJoin4() public {
        giveTokens(address(gnt), 100 * WAD);
        GemJoin4 gntJoin = new GemJoin4(address(vat), "GNT", address(gnt));
        giveAuth(address(vat), address(gntJoin));

        address bag = gntJoin.make();
        gnt.transfer(bag, 10);
        gntJoin.join(address(this), 10);
        gntJoin.cage();
        gnt.transfer(bag, 10);
        gntJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageGemJoin5() public {
        giveTokens(address(usdc), 100 * WAD);
        GemJoin5 usdcJoin = new GemJoin5(address(vat), "USDC", address(usdc));
        giveAuth(address(vat), address(usdcJoin));

        usdc.approve(address(usdcJoin), uint256(-1));
        usdcJoin.join(address(this), 10);
        usdcJoin.cage();
        usdcJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageGemJoin6() public {
        giveTokens(address(tusd), 100 * WAD);
        GemJoin6 tusdJoin = new GemJoin6(address(vat), "TUSD", address(tusd));
        giveAuth(address(vat), address(tusdJoin));

        tusd.approve(address(tusdJoin), uint256(-1));
        tusdJoin.join(address(this), 10);
        tusdJoin.cage();
        tusdJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageGemJoin7() public {
        giveTokens(address(usdt), 100 * 10**6);
        GemJoin7 usdtJoin = new GemJoin7(address(vat), "USDT", address(usdt));
        giveAuth(address(vat), address(usdtJoin));

        usdt.approve(address(usdtJoin), uint256(-1));
        usdtJoin.join(address(this), 10);
        usdtJoin.cage();
        usdtJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageGemJoin8() public {
        uint256 ilkAmt = 100 * 100; // GUSD has 2 decimals
        hevm.store(
            address(gusd_store),
            keccak256(abi.encode(address(this), uint256(6))),
            bytes32(ilkAmt)
        );
        GemJoin8 gusdJoin = new GemJoin8(address(vat), "GUSD", address(gusd));
        giveAuth(address(vat), address(gusdJoin));

        gusd.approve(address(gusdJoin), uint256(-1));
        gusdJoin.join(address(this), 10);
        gusdJoin.cage();
        gusdJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageGemJoin9() public {
        giveTokens(address(paxg), 100 * WAD);
        GemJoin9 paxgJoin = new GemJoin9(address(vat), "PAXG", address(paxg));
        giveAuth(address(vat), address(paxgJoin));

        paxg.approve(address(paxgJoin), uint256(-1));
        paxgJoin.join(address(this), 100 * WAD);
        paxgJoin.cage();
        // Fail here
        paxgJoin.join(address(this), 100 * WAD);
    }

    function testFailJoinAfterCageAuthGemJoin() public {
        giveTokens(address(sai), 100 * WAD);
        AuthGemJoin saiJoin = new AuthGemJoin(address(vat), "SAI", address(sai));
        giveAuth(address(vat), address(saiJoin));

        sai.approve(address(saiJoin), uint256(-1));
        saiJoin.join(address(this), 10);
        saiJoin.cage();
        saiJoin.join(address(this), 10);
    }

    function testFailJoinAfterCageManagedGemJoin() public {
        giveTokens(address(wbtc), 100 * 10**8);
        ManagedGemJoin wbtcJoin = new ManagedGemJoin(address(vat), "WBTC", address(wbtc));
        giveAuth(address(vat), address(wbtcJoin));

        wbtc.approve(address(wbtcJoin), uint256(-1));
        wbtcJoin.join(address(this), 10);
        wbtcJoin.cage();
        wbtcJoin.join(address(this), 10);
    }

    function testTokenSai() public {
        giveTokens(address(sai), 100 * WAD);
        AuthGemJoin saiJoin = new AuthGemJoin(address(vat), "SAI", address(sai));
        assertEq(saiJoin.dec(), 18);
        giveAuth(address(vat), address(saiJoin));

        sai.approve(address(saiJoin), uint256(-1));
        assertEq(sai.balanceOf(address(saiJoin)), 0);
        assertEq(vat.gem("SAI", address(this)), 0);
        saiJoin.join(address(this), 10);
        assertEq(sai.balanceOf(address(saiJoin)), 10);
        assertEq(vat.gem("SAI", address(this)), 10);
        saiJoin.deny(address(this)); // Check there is no need of authorization to exit
        saiJoin.exit(address(this), 4);
        assertEq(sai.balanceOf(address(saiJoin)), 6);
        assertEq(vat.gem("SAI", address(this)), 6);
    }

    function testFailTokenSai() public {
        giveTokens(address(sai), 100 * WAD);
        AuthGemJoin saiJoin = new AuthGemJoin(address(vat), "SAI", address(sai));
        giveAuth(address(vat), address(saiJoin));

        sai.approve(address(saiJoin), uint256(-1));
        saiJoin.deny(address(this));
        saiJoin.join(address(this), 10);
    }

    function testManagedGemJoin_WBTC() public {
        giveTokens(address(wbtc), 100 * 10**8);
        ManagedGemJoin wbtcJoin = new ManagedGemJoin(address(vat), "WBTC", address(wbtc));
        assertEq(wbtcJoin.dec(), 8);
        giveAuth(address(vat), address(wbtcJoin));

        wbtc.approve(address(wbtcJoin), uint256(-1));
        assertEq(wbtc.balanceOf(address(wbtcJoin)), 0);
        assertEq(vat.gem("WBTC", address(this)), 0);
        wbtcJoin.join(address(this), 10 * 10 ** 8);
        assertEq(wbtc.balanceOf(address(wbtcJoin)), 10 * 10 ** 8);
        assertEq(vat.gem("WBTC", address(this)), 10 * WAD);
        wbtcJoin.exit(address(this), address(this), 4 * 10 ** 8);
        assertEq(wbtc.balanceOf(address(wbtcJoin)), 6 * 10 ** 8);
        assertEq(vat.gem("WBTC", address(this)), 6 * WAD);
        assertEq(wbtc.balanceOf(address(this)), 94 * 10 ** 8);
    }

    function testGemJoin_WSTETH() public {
        giveTokens(address(wsteth), 100 * WAD);
        GemJoin wstethJoin = new GemJoin(address(vat), "WSTETH", address(wsteth));
        assertEq(wstethJoin.dec(), 18);
        giveAuth(address(vat), address(wstethJoin));

        wsteth.approve(address(wstethJoin), uint256(-1));
        assertEq(wsteth.balanceOf(address(this)), 100 * WAD);
        assertEq(wsteth.balanceOf(address(wstethJoin)), 0);
        assertEq(vat.gem("WSTETH", address(this)), 0);
        wstethJoin.join(address(this), 10 * WAD);
        assertEq(wsteth.balanceOf(address(wstethJoin)), 10 * WAD);
        assertEq(vat.gem("WSTETH", address(this)), 10 * WAD);
        wstethJoin.exit(address(this), 4 * WAD);
        assertEq(wsteth.balanceOf(address(this)), 94 * WAD);
        assertEq(wsteth.balanceOf(address(wstethJoin)), 6 * WAD);
        assertEq(vat.gem("WSTETH", address(this)), 6 * WAD);
    }
}
