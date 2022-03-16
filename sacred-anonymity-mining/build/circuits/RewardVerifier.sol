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
        vk.alfa1 = Pairing.G1Point(uint256(11719062703138174098229318620751685617596517947229589949996141171059251517367), uint256(2697099061981249190280999135777203785770693535162230612511822079306737035008));
        vk.beta2 = Pairing.G2Point([uint256(4901051281799555464026532034920051584644880078778503825172207944946963176635), uint256(9375848413779388518479598513555237819689817267155501266867907433571547555776)], [uint256(7414127860284926340853282131445482982797732246905881847870075567011248660761), uint256(3973658655625059701137921960541465460817665238686118128714315126412049667948)]);
        vk.gamma2 = Pairing.G2Point([uint256(10086429795418647231886515742264150866575246160939108979863300789322906294828), uint256(21578484523656718201131125890994840898685213151929706275145712799616978551728)], [uint256(15500539726581154845328187480191377539825858930355620760611526588959627499994), uint256(3709552191442394855250257706188737281431617079295787326704097134405757178482)]);
        vk.delta2 = Pairing.G2Point([uint256(12188170271728193363965702985204565028363380877944479504373516844608855371322), uint256(11024705949046651036394638228746369006973045879203097407235640165086121924393)], [uint256(2675800082378245314962209836449835930669603712812468981991791865297769701177), uint256(9898596266859920031250634486967047889162304904515058651704265354653122656069)]);
        vk.IC[0] = Pairing.G1Point(uint256(19274267424079643149082065421528604806679056389744076072568827146599645164876), uint256(13963633387156113402591306450431755234780001810635408913246368112431118951980));
        vk.IC[1] = Pairing.G1Point(uint256(20360260961495431729939459086847448311235683357929322748162552007608060014556), uint256(11285540011603215063717798609153939563058347482760853255786454244869955626013));
        vk.IC[2] = Pairing.G1Point(uint256(3573192477293380611791724461668421705512832014465780471528041580495569827948), uint256(14456271453806454365777364902876650207390115803491363763770555443394178444360));
        vk.IC[3] = Pairing.G1Point(uint256(2677803915199535467320190417414132991786103994741392344497228521135045606844), uint256(16811480108236107203960595041703669769204183157107776916393434166084836050885));
        vk.IC[4] = Pairing.G1Point(uint256(17921455196283410497794845438501630184121982419407501313980659086582651890346), uint256(2863784479663375613681267722151127312360950536047010731128240954835281005788));
        vk.IC[5] = Pairing.G1Point(uint256(2891358670818122814208778067823057878824087265465620640519972934386692807335), uint256(8653602652332757909292175749988027945322775913444297305305016259193820497791));
        vk.IC[6] = Pairing.G1Point(uint256(17009757767802025716581313137096535065781946981480703767639419674099669906888), uint256(16271476504512832776923211206692714842020438337069688230644135849538491222463));
        vk.IC[7] = Pairing.G1Point(uint256(8579734465337320775785753162349817613790667673117614567976315815414779499987), uint256(5941016784055038138717847749173791393042026098927312125539613422460088065443));
        vk.IC[8] = Pairing.G1Point(uint256(1225024032521627718765825027833162034362552646516341423071958280715271391654), uint256(14363746803050885611476127523255556633681721123367732158801435603020386027390));
        vk.IC[9] = Pairing.G1Point(uint256(11988952753967259409299063517128926463851721770170037421044163481828279106859), uint256(19888974738351840875345360414198171559204367460743412350242424646083753071271));
        vk.IC[10] = Pairing.G1Point(uint256(4576852111603025526513628915119716337950958500959767555066123463324942835043), uint256(953805889708477041853588470790194618903672782173465282512907950400522241577));
        vk.IC[11] = Pairing.G1Point(uint256(6968713799141336326516801155248762836876866617666552991414164310789792315194), uint256(2677844497390488574472851136887241130635371342706204012093872365070532338841));
        vk.IC[12] = Pairing.G1Point(uint256(18408041709445394686327549333710425100019832564773603750747868786755647569855), uint256(15622881119766372829472363444503306058249416139046164996712852492408284140239));
        vk.IC[13] = Pairing.G1Point(uint256(6525427863202507740806475543297964198765498867506753821033695477088886687834), uint256(7200490916937451886565138183678641224582794594045720668454334817962715692602));
        vk.IC[14] = Pairing.G1Point(uint256(20129751804959545671164214087675291704363746408659918740149692408047700898350), uint256(18450090455347086388083435025257949451702892795469908003476439907233583054110));

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

