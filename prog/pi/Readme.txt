GPT предложил выводить бинарник при помощи `hexdump -v -e '/1 "%d "'`
Таким образом он выведет: 3 1 4 1 5 9 2 ...

```
const N = 1000;
const LEN = Math.floor((10 * N) / 3) + 1;

const a = Array(LEN);
let previousDigit = 2;
let nineCount = 0;

for (let i = 0; i < LEN; i++) {
  a[i] = 2;
}

let printed = 0;
while (printed < N) {
  // multiply each digit by 10
  // normalize representation
  //   each digit should be in range 0..2i, so carry extra rank to higher digit
  let carry = 0;
  for (let i = LEN - 1, numerator = (2 * LEN - 1); i > 0; i--, numerator -= 2) {
    const x = a[i] * 10 + carry;
    a[i] = x % numerator
    carry = Math.floor(x / numerator) * i;
  }

  // latest carry would be integer part of current number 
  //   and sequental digit of Pi
  const digitFromCarry = Math.floor(carry / 10);
  const nextDigit = carry % 10;

  // if current digit is 9, then we can't decide if we would have cascade carry
  if (nextDigit === 9) {
    nineCount++;
    continue;
  }

  // print previous digit, because now we knows if current digit is more than 10
  const currentDigit = previousDigit + digitFromCarry;
  process.stdout.write(currentDigit.toString());
  printed++;

  // if previous digit is followed by 9s, then print them 
  //   or 0s, if we have cascade carry
  for (let i = 0; i < nineCount; i++) {
    process.stdout.write((digitFromCarry === 0 ? 9 : 0).toString());
    printed++;
  }
  nineCount = 0;

  previousDigit = nextDigit;
}
```
