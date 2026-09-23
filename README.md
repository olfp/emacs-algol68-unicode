# ALGOL 68 Unicode Publishing Language Mode for Emacs

Algol68, which has recently (2026) experienced a revival, has different written representations. One is the ‚publishing language‘ which was used in the official publications to print programs:

    𝐩𝐫𝐨𝐜 𝑛𝑒𝑥𝑡 𝑢𝑛𝑖𝑐𝑜𝑑𝑒 𝑐ℎ𝑎𝑟 𝑙𝑒𝑛𝑔𝑡ℎ = (𝐬𝐭𝐫𝐢𝐧𝐠 𝑠, 𝐢𝐧𝐭 𝑝𝑜𝑠) 𝐢𝐧𝐭: 𝐛𝐞𝐠𝐢𝐧
        𝐢𝐟 𝑝𝑜𝑠 > 𝐮𝐩𝐛 𝑠 𝐭𝐡𝐞𝐧 0 𝐞𝐥𝐢𝐟 𝐚𝐛𝐬 𝑠[𝑝𝑜𝑠] < 128 𝐭𝐡𝐞𝐧 1
        𝐞𝐥𝐬𝐞
            𝐢𝐧𝐭 𝑟𝑒𝑠𝑢𝑙𝑡 := 1;
            𝐰𝐡𝐢𝐥𝐞 (𝑟𝑒𝑠𝑢𝑙𝑡+𝑝𝑜𝑠 ≤ 𝐮𝐩𝐛 𝑠 | 𝐚𝐛𝐬 𝑠[𝑟𝑒𝑠𝑢𝑙𝑡+𝑝𝑜𝑠] > 128 ∧ 𝐚𝐛𝐬 𝑠[𝑟𝑒𝑠𝑢𝑙𝑡+𝑝𝑜𝑠] < 192 | 𝐟𝐚𝐥𝐬𝐞) 𝐝𝐨
                𝑟𝑒𝑠𝑢𝑙𝑡 +:= 1
            𝐨𝐝;
            𝑟𝑒𝑠𝑢𝑙𝑡
        𝐟𝐢
    𝐞𝐧𝐝;

In Algol68, keywords and identifiers live in separate namespaces (lightly speaking) and need to be cleary separated. 

But the hardware available in the late ‘60s did not allow entering programs this way (we are talking of cards and tape). So several representations suitable for being written with 7-bit or even 6-bit characters were the norm. When bold/italic is not available, other means are needed to mark the ‚bold-words‘, this is called ‚stropping‘. There is UPPER-stropping:

    PROC next unicode char length = (STRING s, INT pos) INT: BEGIN

or, when no lower case is available, there is Dot-stropping:

    .PROC NEXT UNICODE CHAR LENGTH = (.STRING S, .INT POS) .INT: .BEGIN

or Quote-stropping, which I find especially appaling:

    ‘PROC‘ next unicode char length = (‘STRING‘ s, ‘INT‘ pos) ‘INT‘: ‘BEGIN‘

While 50+ years have passed, we still write code in plain ASCII - while sice 20+ years we have Unicode available. 

Github user lassehp published the idea using the MathBold and MathItalic glyphs available in Unicode to represent Algol68 code:
(https://gist.github.com/lassehp/00dd99f1ec8992e07a727f57d760930d)

For studying Algol68 in a pretty way, I chose to ask Gemini to write me an emacs config, so I can write Algol68 code in this notation. This can then be converted by the program written by lassehp into UPPER stropped Algol68 code suitable for the compiler.


| Emacs with pretty Algol68 code: | |
| --- | --- |
| ![Emacs with pretty Algol68](https://olfp.github.io/assets/Emacs-Algol68-Pretty.png) | |

# How to use

To include in your config add
```
(load (expand-file-name "algol68/unicode68.el" user-emacs-directory))
``` 
to your `.emacs` or `init.el` after placing the `.el` files in `.emacs.d/algol68` .

When editing a file with `.u68` extension (for Unicode-stropped-Algol68), bold and italics are auto-applied and you can also convert words to bold/italic with C-c b, C-c i and back to normal with C-c n. 

For inserting the special Symbols for boolean operators, you can type && for ∧ and || for ∨. Also typing ~ inserts ¬.

Btw. on a Mac keyboard Option-4 inserts ¢ and Option-0 inserts ≠.

Special case was taken that searching also works with the MathBold/MathItalic charactes. So when you sreach for 'proc' instances of 𝐩𝐫𝐨𝐜 are found, and when searching for "result", 𝑟𝑒𝑠𝑢𝑙𝑡 is found.

The Python script `u682a68` converts Algol68 code written in Unicode-stropping into UPPER-stropping the complier can digest:
```
$ u682a68 <demo.u68 >demo.a68
```
Have fun!


