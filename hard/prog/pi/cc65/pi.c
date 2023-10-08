// Results
// || ==Digits== || ==Time==   
// |  $10        |    0,330s
// |  $20        |    1,220s
// |  $30        |    2,736s
// |  $40        |    5,018s
// |  $50        |    8,107s
// |  $60        |   11,786s
// |  $70        |   16,250s
// |  $80        |   21,428s
// |  $90        |   27,381s
// |  $a0        |   33,987s
// |  $b0        |   41,326s
// |  $c0        |   49,452s
// |  $d0        |   58,499s
// |  $e0        | 1m07,703s 
// |  $f0        | 1m18,005s
// |  $ff        | 1m28,259s

#define TO_PRINT ((unsigned char) 0xff)

#define ARRAY_SIZE ((unsigned short) (10*TO_PRINT)/3+1)
#define RESULT ((unsigned char*)0x900)
#define ARRAY ((unsigned short*)0x1000)


void main() {
    unsigned char previousDigit = 2;
    unsigned char nineCount = 0;
    unsigned char printed = 0;
    unsigned short carry = 0;
    unsigned short numerator;
    unsigned short x;
    unsigned char digitFromCarry;
    unsigned char nextDigit;
    unsigned char currentDigit;
    unsigned short i;
    for (i=0; i<ARRAY_SIZE;++i) {
        ARRAY[i] = 2;
    }

    while (printed < TO_PRINT) {
        carry = 0;
        for (i=ARRAY_SIZE-1, numerator = 2*ARRAY_SIZE-1; 
                    i > 0; 
                    i--, numerator -= 2) {
            x = ARRAY[i]*10+carry;
            ARRAY[i] = x % numerator;
            carry = x/numerator*i;
        }

        digitFromCarry = carry / 10;
        nextDigit = carry % 10;

        if (nextDigit == 9) {
            ++nineCount;
            continue;
        }

        currentDigit = previousDigit + digitFromCarry;
        RESULT[printed] = currentDigit;
        ++printed;

        for (; nineCount > 0; nineCount--) {
            RESULT[printed] = digitFromCarry == 0 ? 9 : 0;
            ++printed;
        }
        previousDigit = nextDigit;
    }    
}
