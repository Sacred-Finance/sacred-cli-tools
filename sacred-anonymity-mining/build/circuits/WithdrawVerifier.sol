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
        Pairing.G1Point[8] IC;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(uint256(14618796564680130261836295624860366217261897626004042032553243181409336039575), uint256(11038581352762506661385170067540269112502552171184251248662926045330878624922));
        vk.beta2 = Pairing.G2Point([uint256(8439982659878523660787790033668831588130564722699016693972815579808250200386), uint256(19589672993643301898775811222031519199799678094639851620208454597618268823193)], [uint256(6671813998174412031244246433850656767816250484369139422591551885097214880665), uint256(11146106770469034414808754058667063429495713787600943259981215814216872994931)]);
        vk.gamma2 = Pairing.G2Point([uint256(14785382445051018439236062507360364986324474772389209014820106510773093966072), uint256(2008287070150887186713137133834310044789031054168199964100368717893811997079)], [uint256(10192295842928978458447062330245449436498983615701642883005010947700718712890), uint256(9328497901727989250060740026540848380437388122230972689255458142154920233845)]);
        vk.delta2 = Pairing.G2Point([uint256(8439353468614992117300243401359147535813005749757726095385716855427081480551), uint256(18103291564221482147213205539562501483721940467792207148625570986209441010229)], [uint256(14540098889712590623711577629266461236149428677421356422310789621205095753120), uint256(7529137465657373118667785637413792604083326016768764157577022470656468840446)]);
        vk.IC[0] = Pairing.G1Point(uint256(9224915711605126361253927171135417869754941158356018882739306099278148615737), uint256(20782399322770263502176342647700919545351154312580733397802432211406095362988));
        vk.IC[1] = Pairing.G1Point(uint256(14600682429540290258150563679012692876795855647963481484534519316947339784224), uint256(16536382719145866294935973737291473259453751989595499724991850729500896365976));
        vk.IC[2] = Pairing.G1Point(uint256(20153102987799253677449187651377413972986876356234173351114420842347904194005), uint256(1428934225678173819445421173688619545012609010076778446510698762403947353098));
        vk.IC[3] = Pairing.G1Point(uint256(13009911678417119392960150986606463739278827615381265721870687411386693640209), uint256(122649438995481584753421477543871204587737365399799246842427778920896183311));
        vk.IC[4] = Pairing.G1Point(uint256(2146396460675866132920676587750733660030363377036385709406759587323674699690), uint256(16756565917621701437123413565451238448022671688782068954977441246334986595999));
        vk.IC[5] = Pairing.G1Point(uint256(18628687285519327676765515522066872414745954732491921617943368358096874647678), uint256(19920255379521314077104597678946900384435551158725816812260714116987166295111));
        vk.IC[6] = Pairing.G1Point(uint256(19514836002182077715860585906806161260036953558719505559375416235624447538194), uint256(9196518399978869261599249559729971280789754359431664855199642611633860613407));
        vk.IC[7] = Pairing.G1Point(uint256(1676198788948626041060183795515658655087764197892779171097568273122289176555), uint256(17747402644987071643955873225467838966729372587078158421201314056613985438884));

    }

    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyProof(
        bytes memory proof,
        uint256[7] memory input
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
