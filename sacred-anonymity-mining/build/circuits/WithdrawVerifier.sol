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
        vk.alfa1 = Pairing.G1Point(uint256(10532676187858387201804907518653208003818826492811347161143784424222289359231), uint256(2003842916180289418399897279565809403729497814069111573746124962451964944718));
        vk.beta2 = Pairing.G2Point([uint256(20505720385114042969986108752104573893911535213743992269952751007939679684073), uint256(12713193251691058228690284811738670027417933340074941686469664156878040460965)], [uint256(15156673348914185054791521963419281910594124991419919839355668694379851851306), uint256(10478559632757739559585607715297924055346132943892582245491567875391151193449)]);
        vk.gamma2 = Pairing.G2Point([uint256(17622263151422909305254734917509624231807600414810617090762401789123440772185), uint256(21022989502632780734227608521274674006715507304223487058058713686737316979143)], [uint256(14182243368356620647143165011088778586734326871389671473153613905628449759320), uint256(11450648629462762781468893323455003201085090105285247011659166624039041223373)]);
        vk.delta2 = Pairing.G2Point([uint256(1653170050416124516528448609285096045448504340642124459867350652154222336329), uint256(7759825968059418125079513789366062849346007507542123753606262013631316639913)], [uint256(14120452424479734723502764494118677414745728007987045344059607279944724439923), uint256(21883119469611022175211381857698873211052440637798545711643785011550570062085)]);
        vk.IC[0] = Pairing.G1Point(uint256(4036784552352166380740778329147279654538701962921765438355817117737722409233), uint256(7644657505416904292278406970635763372549284121238334937440041662232542272295));
        vk.IC[1] = Pairing.G1Point(uint256(3069801428978803591434373516753932336334226476440119731000512674882081695083), uint256(6349092543868578181519796841219569823598547259892332375789840287427450080553));
        vk.IC[2] = Pairing.G1Point(uint256(15628184785643409219753624015408360133536742021449205094787062704083521316049), uint256(8217476082273804837701408902702108500887105082067519660276547530666490164202));
        vk.IC[3] = Pairing.G1Point(uint256(1087446201754474915767983225280908514248026577902383033049196018498114738773), uint256(15483739030406097281491362330935312868132310617055371509970271069243214031144));
        vk.IC[4] = Pairing.G1Point(uint256(7506336829919422747072630766507290491459470893857458599280408962751306826863), uint256(6570155303967424518482917391975743714532879767956969423667969873828564284956));
        vk.IC[5] = Pairing.G1Point(uint256(18352892596732922682009162374482381909427899409512579149966658127534633406048), uint256(9022199806267093203469154077160751367016552330260554157795513262617907984586));
        vk.IC[6] = Pairing.G1Point(uint256(19433509446863670573576916205873522323285047974475847980933511434051090355512), uint256(4940837723949241993249362292234241524825936942454680951680581130615103312140));
        vk.IC[7] = Pairing.G1Point(uint256(6506011799940779614790992699100882402096679223937557760969504881312447655985), uint256(21138050528470435662717750586516039002036125182447742552159983303441925914523));
        vk.IC[8] = Pairing.G1Point(uint256(3876084617623811409443449047248375110875689813963087648572608038000120067554), uint256(19254903690461473597565565416259538972555355022088608293631881786997058993999));

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

