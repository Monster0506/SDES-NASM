#set page(margin: 1.2in)
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)

#align(center)[
  #text(size: 16pt, weight: "bold")[Brute-Force Key Attack on S-DES]
  #v(0.3em)
  #text(size: 11pt)[TJ Raklovits]
]

#v(1em)

== Overview

The cipher implemented here is *Simplified DES (S-DES)*, a pedagogical variant
of the Data Encryption Standard. It operates on 8-bit plaintext blocks using a
*10-bit key*, from which two 8-bit subkeys $K_1$ and $K_2$ are derived via P10,
two left-circular shifts, and a P8 permutation. Each byte is encrypted by
applying an initial permutation (IP), two rounds of the Feistel function $f_K$
(with an S-box substitution, expansion permutation EP, and P4), and a final
inverse permutation $"IP"^(-1)$.

== The Key Space

Because the key is only 10 bits, the total number of possible keys is:

$ |K| = 2^10 = 1024 $

This is an extremely small key space. An attacker who possesses a known
plaintext–ciphertext pair can recover the key with certainty by testing every
candidate in at most 1024 attempts.

== Brute-Force Attack Procedure

Given a known plaintext $P$ and its corresponding ciphertext $C$, the attack
proceeds as follows:

+ *Enumerate* all 1024 10-bit strings $k \in \{0,1\}^{10}$.
+ For each candidate key $k$:
  + Derive subkeys $K_1, K_2$ using the S-DES key schedule (P10 #sym.arrow LS-1 #sym.arrow P8 for $K_1$; LS-2 #sym.arrow P8 for $K_2$).
  + Encrypt $P$ under $k$ to obtain $C'$.
  + If $C' = C$, output $k$ as the recovered key and halt.
+ If no match is found after all 1024 trials, the pair $(P, C)$ is invalid.

The worst-case cost is 1024 encrypt operations; the expected cost is 512. On
contemporary hardware this completes in microseconds.

== Worked Example

Suppose the plaintext is the ASCII string `"hello"` (5 bytes). The attacker
observes the ciphertext bytes output by the program. A simple C or Python loop
re-implements the S-DES round function and iterates $k$ from `0000000000` to
`1111111111`. The first $k$ for which *all five* ciphertext bytes match the
observed output is the correct key. No cryptanalytic insight is required.

== Conclusion

A brute-force attack on this S-DES implementation requires at most *1024
decryption trials* and recovers the key in constant, negligible time. The
attack requires only one known plaintext–ciphertext pair (readily available
since the program prints both) and no knowledge of the key schedule beyond
what is already in the source code.
