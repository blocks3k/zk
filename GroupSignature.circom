pragma circom 2.1.4;

include "circomlib/poseidon.circom";
// include "https://github.com/0xPARC/circom-secp256k1/blob/master/circuits/bigint.circom";


template SecretToPublic() {
    signal input sk;
    signal output pk;
    
    component poseidon = Poseidon(1);
    poseidon.inputs[0] <== sk;
    pk <== poseidon.out;
}

template GroupSign(n) {
    signal input sk;
    signal input pk[n];
    
    // even though m is not involved in the circuit, 
    // it is still constrained and cannot be 
    // changed after it is set.
    signal input m; 

    // get the public key
    component computePk = SecretToPublic();
    computePk.sk <== sk;

    // make sure computedPk is in the inputted group
    signal zeroChecker[n+1];
    zeroChecker[0] <== 1;
    for (var i = 0; i < n; i++) {
        zeroChecker[i+1] <== zeroChecker[i] * (pk[i] - computePk.pk);
    }
    zeroChecker[n] === 0;
}

component main { public [ pk, m ] } = GroupSign(5);

/* INPUT = {
    "sk" :5,
    "pk": ["19065150524771031435284970883882288895168425523179566388456001105768498065277", "1", "2", "3", "4"],
    "m": "1"
} */
