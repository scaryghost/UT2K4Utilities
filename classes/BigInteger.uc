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

function string asString() {
    local string stringBytes;
    local int i, j;
    local byte mask;

    for(i= bits.Length - 1; i >= 0; i--) {
        mask= 0x80;
        for(j= 7; j >= 0; j--) {
            stringBytes$= (mask & bits[i]) >> j;
            mask= mask >> 1;
        }
    }

    return stringBytes;
}

static function final byte add(byte carry, byte left, byte right, out byte sum) {
    local byte i, mask, temp1, temp2;

    sum= 0;
    mask= 1;
    for(i= 0; i < 8; i++) {
        temp1= (left & mask) >> i;
        temp2= (right & mask) >> i;
        log((carry ^ temp1 ^ temp2) @ carry @ temp1 @ temp2);
        sum= sum | ((carry ^ temp1 ^ temp2) << i);
        carry= carry & (temp1 | temp2) | (temp1 & temp2);
        mask= mask << 1;
    }
    return carry;
}

static final operator(16) BigInteger * (BigInteger left, BigInteger right);
static final operator(34) BigInteger *= (out BigInteger left, BigInteger right);
static final operator(34) BigInteger += (out BigInteger left, BigInteger right);
static final operator(20) BigInteger + (BigInteger left, BigInteger right) {
    local int i, maxLen, offset;
    local BigInteger sum;
    local byte carry, mask;

    maxLen= Max(left.bits.Length, right.bits.Length);
    for(i= 0; i < maxLen; i++) {
        sum.bits.Length= sum.bits.Length + 1;
        if (i >= left.bits.Length) {
            carry= add(carry, 0, right.bits[i], sum.bits[i]);
        } else if (i >= right.bits.Length) {
            carry= add(carry, left.bits[i], 0, sum.bits[i]);
        } else {
            carry= add(carry, left.bits[i], right.bits[i], sum.bits[i]);
        }
    }
    
    if (carry == 1) {
        mask= 0x80;
        for(i= 7; i >= 0 && (mask & sum.bits[sum.bits.Length - 1]) != 1; i--) {
            mask= mask >> 1;
        }
        offset= i % 8 + 1;
        if (offset == 0) {
            sum.bits[sum.bits.Length]= 0x1;
        } else {
            sum.bits[sum.bits.Length - 1]= sum.bits[sum.bits.Length - 1] | (1 << offset);
        }
    }
    return sum;
}

