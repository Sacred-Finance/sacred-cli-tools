// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

library Pairing {
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    /*
     * @return The negation of p, i.e. p.plus(p.negate()) should be zero
     */
    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        if (p.X == 0 && p.Y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.X, PRIME_Q - (p.Y % PRIME_Q));
        }
    }

    /*
     * @return r the sum of two points of G1
     */
    function plus(
        G1Point memory p1,
        G1Point memory p2
    ) internal view returns (G1Point memory r) {
        uint256[4] memory input = [
            p1.X, p1.Y,
            p2.X, p2.Y
        ];
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success, "pairing-add-failed");
    }

    /*
     * @return r the product of a point on G1 and a scalar, i.e.
     *         p == p.scalarMul(1) and p.plus(p) == p.scalarMul(2) for all
     *         points p.
     */
    function scalarMul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {
        uint256[3] memory input = [p.X, p.Y, s];
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success, "pairing-mul-failed");
    }

    /* @return The result of computing the pairing check
     *         e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
     *         For example,
     *         pairing([P1(), P1().negate()], [P2(), P2()]) should return true.
     */
    function pairing(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {
        uint256[24] memory input = [
            a1.X, a1.Y, a2.X[0], a2.X[1], a2.Y[0], a2.Y[1],
            b1.X, b1.Y, b2.X[0], b2.X[1], b2.Y[0], b2.Y[1],
            c1.X, c1.Y, c2.X[0], c2.X[1], c2.Y[0], c2.Y[1],
            d1.X, d1.Y, d2.X[0], d2.X[1], d2.Y[0], d2.Y[1]
        ];
        uint256[1] memory out;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, input, mul(24, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success, "pairing-opcode-failed");
        return out[0] != 0;
    }
}

contract WithdrawVerifier {
    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    using Pairing for *;

    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[9] IC;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(uint256(13100607767439275170499060683530638873978892043370494526916396847939009794100), uint256(1280953200275107423949710938256091663195613124090924193539379253626072443323));
        vk.beta2 = Pairing.G2Point([uint256(9076550244283873692027876302107773973816839656908837031225773086184065886731), uint256(6299266400123266070378047993130291883368523625219975865203168154056584374093)], [uint256(14601711834115175461265270057608722770017711521899350327803763087846971184634), uint256(8326088168461731617826839893653040809159481366145544281555285796438475890613)]);
        vk.gamma2 = Pairing.G2Point([uint256(1337108907487019506356704737944266525796412624786566711770727872801328471257), uint256(13823320535093848467869776773666290873751658596444924968284924774568560732979)], [uint256(6542154159577984036403779727499003112186489584387342374881678193577311312695), uint256(10959468319037330919306630241896703803830063543290778439768632571084492271582)]);
        vk.delta2 = Pairing.G2Point([uint256(14609653095893247180968175573612147050826941246540888853762084478517136605819), uint256(2512262146937508794751681274539432657375024344434943990271256570176784518613)], [uint256(14064997470025163553583355411409707512280269917860522689119678795023724398106), uint256(18215734638647548864850375533213654577346965069005140936765328337592660514475)]);
        vk.IC[0] = Pairing.G1Point(uint256(21642484563205446622400692960996207171987440122550372312809455429746847907929), uint256(9588406878651814666970425053728477139068221909944078000584710210149787203873));
        vk.IC[1] = Pairing.G1Point(uint256(15922629278226820752038826819634039674647056938955692945398550229723277015347), uint256(18023971042519207857300083872225898675687172238345410706385674873541436653306));
        vk.IC[2] = Pairing.G1Point(uint256(15529144302602905027606850448094009948453522333479357585662101265168890788817), uint256(14433271733442538605556716123302852786662231603926058243332937496527495862998));
        vk.IC[3] = Pairing.G1Point(uint256(14926893744499643565770287141689385621801529335285641925752976514301066644815), uint256(18515888074324380786548921218527459758957494489053775410878561683443757896557));
        vk.IC[4] = Pairing.G1Point(uint256(1658850018513313550621513100133145499606363045605656781121404993799115769268), uint256(9845113240664636464322244532258558755292384066114235687926861145979071444761));
        vk.IC[5] = Pairing.G1Point(uint256(14482878343946280888592305780773439563614294318923604792142837586865413087484), uint256(18449001597526654747892265022509160899507636930993599176735969359281971760520));
        vk.IC[6] = Pairing.G1Point(uint256(14850799161712108277474558807267666059716753670265628775790655536717569760034), uint256(13672629095740121281922477803282971105189736734805411136921055978909126548092));
        vk.IC[7] = Pairing.G1Point(uint256(17853032595278526616845332425756051602971078586425418748473069388711115046134), uint256(18570942957285353445490562116036069217111064147889911712207854171357812749192));
        vk.IC[8] = Pairing.G1Point(uint256(18808276772957755304687305192180503349856305559503997682155932699333883310441), uint256(12019752739200992191446856972621028146027144220215365387926821912724566756606));

    }

    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyProof(
        bytes memory proof,
        uint256[8] memory input
    ) public view returns (bool) {
        uint256[8] memory p = abi.decode(proof, (uint256[8]));
        for (uint8 i = 0; i < p.length; i++) {
            // Make sure that each element in the proof is less than the prime q
            require(p[i] < PRIME_Q, "verifier-proof-element-gte-prime-q");
        }
        Pairing.G1Point memory proofA = Pairing.G1Point(p[0], p[1]);
        Pairing.G2Point memory proofB = Pairing.G2Point([p[2], p[3]], [p[4], p[5]]);
        Pairing.G1Point memory proofC = Pairing.G1Point(p[6], p[7]);

        VerifyingKey memory vk = verifyingKey();
        // Compute the linear combination vkX
        Pairing.G1Point memory vkX = vk.IC[0];
        for (uint256 i = 0; i < input.length; i++) {
            // Make sure that every input is less than the snark scalar field
            require(input[i] < SNARK_SCALAR_FIELD, "verifier-input-gte-snark-scalar-field");
            vkX = Pairing.plus(vkX, Pairing.scalarMul(vk.IC[i + 1], input[i]));
        }

        return Pairing.pairing(
            Pairing.negate(proofA),
            proofB,
            vk.alfa1,
            vk.beta2,
            vkX,
            vk.gamma2,
            proofC,
            vk.delta2
        );
    }
}

