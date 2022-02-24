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

contract TreeUpdateVerifier {
    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    using Pairing for *;

    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[5] IC;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(uint256(8469624742244773619158921804840650475844140153745482612985724787874290723819), uint256(18708894088674688118963672298591976972967893206938550423175087678841052392215));
        vk.beta2 = Pairing.G2Point([uint256(6900505673601078252736582102228657841594412909467581088246691566829727991596), uint256(7505587557370208713493063036071653702953747772078162463547968818734664114741)], [uint256(5723139990566224746813442779760872342614281106179839842039594478318875362621), uint256(517494112368334178680432494287179123218906576907206499498606946753161401256)]);
        vk.gamma2 = Pairing.G2Point([uint256(21723836626383018778833538551332724567577263802483880790060031103709711946358), uint256(16113699407555711430405083681725498248713369667880215672898623285137347900829)], [uint256(13924221705082171422408208858742481741564598205994298898058689195064960580532), uint256(18377089356189999795916190222497916310361680246411062724678422340702976900462)]);
        vk.delta2 = Pairing.G2Point([uint256(10203981429163558433457514224983198817881809789891160898842944488645871412417), uint256(20014956243807260793449133775777705315466675582158256187066661160478047919099)], [uint256(17975550724779370966622990464986597769719206114926934440754114466281968202620), uint256(12473524723065833792166770022838295292042423167174171481906974366008023168575)]);
        vk.IC[0] = Pairing.G1Point(uint256(2460966659162507604387676387565866757780859908841058689228282581365476265602), uint256(7887318536920348679252385244885100529360365366611711666312009466105474001546));
        vk.IC[1] = Pairing.G1Point(uint256(15706929892690095087775551521294641132445306743418654528369075647664703535051), uint256(6159566889201328330143713053346354886658223724175641543526709948033924162157));
        vk.IC[2] = Pairing.G1Point(uint256(16735202569753207137457594343485655397528995154392854621355400851649467732832), uint256(5465497453003685510016271827801171362394129295539964458380594627514461230787));
        vk.IC[3] = Pairing.G1Point(uint256(18874540432536111873512288287834705224581132177682476408122582011259986174426), uint256(18897491094906573279232513742417685427424842267507226439409256697315424354781));
        vk.IC[4] = Pairing.G1Point(uint256(6615606236244392766013978389355947860800028975339795895869556912766503177335), uint256(14598123396191105946796493308679929735194473024158852802175294552803338665268));

    }

    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyProof(
        bytes memory proof,
        uint256[4] memory input
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
