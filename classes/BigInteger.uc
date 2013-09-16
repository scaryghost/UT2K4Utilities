class BigInteger extends Object;

var byte sign;
var array<byte> bits;

function setStrValue(string strVal) {
    local BigInteger mag, scale, current, sum;
    local int i, endIndex, value;

    sum.bits[0]= 0;
    mag.bits[0]= 0x1;
    scale.bits[0]= 0xa;

    endIndex= len(strVal) - 1;
    if (Mid(strVal, endIndex, 1) == "-") {
        endIndex--;
        sign= 1;
    }
    for(i= 0; i < endIndex; i++) {
        value= int(Mid(strVal, i, 1));
        current.bits[0]= value & 0xff;
        sum+= (mag * current);
        mag*= scale;
    }
    bits= sum.bits;
}

static function final byte add(byte carry, byte left, byte right, out byte sum) {
    local byte i, mask, temp1, temp2;

    sum= 0;
    mask= 1;
    for(i= 0; i < 8; i++) {
        temp1= left & mask;
        temp2= right & mask;
        sum= (carry ^ temp1 ^ temp2) << i;
        carry= carry & (temp1 | temp2) | temp1 & temp2;
    }
    return carry;
}

static final operator(16) BigInteger * (BigInteger left, BigInteger right);
static final operator(34) BigInteger *= (out BigInteger left, BigInteger right);
static final operator(34) BigInteger += (out BigInteger left, BigInteger right);
static final operator(20) BigInteger + (BigInteger left, BigInteger right) {
    local int i;
    local BigInteger sum;
    local byte carry;

    for(i= 0; i < left.bits.Length && i < right.bits.Length; i++) {
        carry= add(carry, left.bits[i], right.bits[i], sum.bits[i]);
    }
    return sum;
}

