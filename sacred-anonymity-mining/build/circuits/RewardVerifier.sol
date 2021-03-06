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

contract RewardVerifier {
    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    using Pairing for *;

    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[15] IC;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(uint256(15565286332708901869389704619304851436631623082102265174313585849654895472797), uint256(9407248116495053513206736118663844203901628841270564791149583247285785090329));
        vk.beta2 = Pairing.G2Point([uint256(7913641251690016921375021883911292008674519097242017729022382974266979248231), uint256(16286912309274531416438983539700274037869925335328560064437016080168012489324)], [uint256(3788833476232720855183094985854083529676696707108831379730544689203688060849), uint256(1213092138015161395031661683428198587152242908132941751951399318937329273176)]);
        vk.gamma2 = Pairing.G2Point([uint256(9202080763702498598260893480981138827436551169589958867317279636383974963185), uint256(4858925185093206064635796131170799207775904606625508697310585170331950425040)], [uint256(3619773312153159605057629054836587334863288636694149709476179713275844338787), uint256(9734795730826594337982379974014295966072527752342526016954628319529597069152)]);
        vk.delta2 = Pairing.G2Point([uint256(19301289852910559272581228061675727098117491857623695502769572678754205945538), uint256(21576712785694412265232634022371138947006839488429380305660745607646272448241)], [uint256(8605328216034888418688297211184027303214523498810775776722435946022768482712), uint256(12564775340103115231816316335959893767863634647362240074454572740627098077985)]);
        vk.IC[0] = Pairing.G1Point(uint256(20091766697246856912330643428273398473626234756284654432318862347642257495963), uint256(15551443315610674167203767200915478865659041313822904637761867389541407335549));
        vk.IC[1] = Pairing.G1Point(uint256(14937601909112072249013071659524032992655287790136135000672014752043200580674), uint256(14559486781451315101477512023042556386039867416511911367175813602238839204108));
        vk.IC[2] = Pairing.G1Point(uint256(7939069021661782502300046241365688851093476670262293139737853055590473459069), uint256(18779661525232254048528160094085639570901251350858117657515938084028518307131));
        vk.IC[3] = Pairing.G1Point(uint256(7330192659661692704798967817224803643705703551209663616308529986532990405237), uint256(2392657820147922672993504959195438880047309851913059164223781121457262244661));
        vk.IC[4] = Pairing.G1Point(uint256(6843778990172134099031968662607455607068457877470795891726809584348243944149), uint256(3926558906240044550549040512413905347528972630319694934529131328440133326630));
        vk.IC[5] = Pairing.G1Point(uint256(12930291253651630194504411312646284297970669483418479246006260934867454090), uint256(11392999526905750683089038225966520752761777814490623307957197656901793108506));
        vk.IC[6] = Pairing.G1Point(uint256(15738748590935724880663358539935878747939013847039740601871270331342691580987), uint256(595981867491460063261064777307951809041251647418193462039406759739077001136));
        vk.IC[7] = Pairing.G1Point(uint256(9935201035259122313194846111187501377743729203469686398537375094633355656897), uint256(3562413668856365624215324614374431124165134122129982381024264868786375320655));
        vk.IC[8] = Pairing.G1Point(uint256(12931391620557850848859569467886004390441290504597190294064689436437449543557), uint256(21136800585812994472826149111358600152515440357701123906224301690356653345147));
        vk.IC[9] = Pairing.G1Point(uint256(9987432401839711268435736971278232697959422864221937238916403283113146570193), uint256(20470902464783114594393561737161795581159819334725323494905950379598126334633));
        vk.IC[10] = Pairing.G1Point(uint256(4018445114279176323803264256633571177668615270414238126061047737427999820429), uint256(9686594211624731356437873994293163309658439980948858481609717227845829500529));
        vk.IC[11] = Pairing.G1Point(uint256(6431799255316952461664661638501862816935410807237238655404672406050830501310), uint256(4146804862192338979956949754921264121273530843667862201308874655928170555160));
        vk.IC[12] = Pairing.G1Point(uint256(161345713374201899107710538841841857716494868552683179162015713802609433331), uint256(7761261139430150091894983835607180391165751642136904318619571376899068048343));
        vk.IC[13] = Pairing.G1Point(uint256(1136185147328563991774529889600337349148684166582315794170167205424465261458), uint256(8646864117389621522430025751165111761508348444514965565236660475083207423391));
        vk.IC[14] = Pairing.G1Point(uint256(3693363495941094655855398584805712895663915583530238860958886525234045394166), uint256(13212258536632770642837914194663444759145828369617384061470727473466218936893));

    }

    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyProof(
        bytes memory proof,
        uint256[14] memory input
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

