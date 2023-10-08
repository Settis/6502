#define RESULT ((unsigned char*)0x900)

void main() {
    //#pragma register-vars()
    unsigned char i;
    for (i=0x20;i<0x30;++i) {
        RESULT[i] = 3;
    }
}
