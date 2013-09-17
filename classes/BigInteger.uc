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

function BigInteger clone() {
    local BigInteger objClone;
    local int i;
    
    objClone= new class'BigInteger';
    objClone.sign= sign;
    for(i= 0; i < bits.Length; i++) {
        objClone.bits[i]= bits[i];
    }
    return objClone;
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
    if (sign == 1) {
        stringBytes= "-" $ stringBytes;
    }

    return stringBytes;
}

static function final array<byte> twosComplement(array<byte> input) {
    local int i;
    local array<byte> one, flippedBytes, copy;
    local bool isZero;

    one[0]= 0x1;
    isZero= true;
    for(i= 0; i < input.Length; i++) {
        isZero= isZero && input[i] == 0;
        flippedBytes[i]= input[i] ^ 0xff;
        copy[i]= input[i];
    }
    if (isZero) {
        return copy;
    }
    return addBytes(flippedBytes, one);
}

static function final byte addByte(byte carry, byte left, byte right, out byte sum) {
    local byte i, mask, temp1, temp2;

    sum= 0;
    mask= 1;
    for(i= 0; i < 8; i++) {
        temp1= (left & mask) >> i;
        temp2= (right & mask) >> i;
        sum= sum | ((carry ^ temp1 ^ temp2) << i);
        carry= carry & (temp1 | temp2) | (temp1 & temp2);
        mask= mask << 1;
    }
    return carry;
}

static function final array<byte> addBytes(array<byte> left, array<byte> right) {
    local int i, maxLen, offset;
    local array<byte> sum;
    local byte carry, mask;

    maxLen= Max(left.Length, right.Length);
    for(i= 0; i < maxLen; i++) {
        sum.Length= sum.Length + 1;
        if (i >= left.Length) {
            carry= addByte(carry, 0, right[i], sum[i]);
        } else if (i >= right.Length) {
            carry= addByte(carry, left[i], 0, sum[i]);
        } else {
            carry= addByte(carry, left[i], right[i], sum[i]);
        }
    }
    
    if (carry == 1) {
        mask= 0x80;
        for(i= 7; i >= 0 && (mask & sum[sum.Length - 1]) != 1; i--) {
            mask= mask >> 1;
        }
        offset= i % 8 + 1;
        if (offset == 0) {
            sum[sum.Length]= 0x1;
        } else {
            sum[sum.Length - 1]= sum[sum.Length - 1] | (1 << offset);
        }
    }
    return sum;
}

static function int compareBytes(array<byte> left, array<byte> right) {
    local int i, maxLen, compare;
    local byte tempL, tempR;

    maxLen= Max(left.Length, right.Length);
    for(i= maxLen - 1; i >= 0 && compare == 0; i--) {
        if (i >= left.Length) {
            tempL= 0;
        } else {
            tempL= left[i];
        }
        if (i >= right.Length) {
            tempR= 0;
        } else {
            tempR= right[i];
        }
        
        if (tempL < tempR) {
            compare= -1;
        } else if (tempL > tempR) {
            compare= 1;
        }
    }
    return compare;
}

static final operator(24) bool <(BigInteger left, BigInteger right) {
    if (left.sign < right.sign) {
        return false;
    } else if (left.sign > right.sign) {
        return true;
    }

    return (left.sign == right.sign && compareBytes(left.bits, right.bits) == -1);
}

static final operator(16) BigInteger * (BigInteger left, BigInteger right);
static final operator(34) BigInteger *= (out BigInteger left, BigInteger right);
static final operator(34) BigInteger += (out BigInteger left, BigInteger right);

static final function BigInteger add(BigInteger left, BigInteger right) {
    local array<byte> opLeft, opRight;
    local BigInteger sum;
    local int magCompare;

    sum= new class'BigInteger';
    magCompare= compareBytes(left.bits, right.bits);
    if (left.sign == 1) {
        opLeft= twosComplement(left.bits);
    } else {
        opLeft= left.bits;
    }
    if (right.sign == 1) {
        opRight= twosComplement(right.bits);
    } else {
        opRight= right.bits;
    }
    sum.bits= addBytes(opLeft, opRight);
    sum.sign= byte(left.sign == 1 && right.sign == 1 || left.sign == 1 && right.sign == 0 && magCompare == 1 || 
            left.sign == 0 && right.sign == 1 && magCompare == -1);
    if (sum.sign == 1) {
        sum.bits= twosComplement(sum.bits);
    }
    return sum;
}

static final preoperator BigInteger -(BigInteger right) {
    local BigInteger negated;

    negated= right.clone();
    negated.sign= negated.sign ^ 1;
    return negated;
}

static final function BigInteger subtract(BigInteger left, BigInteger right) {
    return add(left, -right);
}
