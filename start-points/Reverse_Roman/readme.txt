Given a Roman number as a string (eg "XX") determine its integer value (eg 20).

You cannot write numerals like IM for 999. Wikipedia states "Modern Roman numerals are written by expressing each digit separately starting with the leftmost digit and skipping any digit with a value of zero."

Examples:

"I" -> 1
"II" -> 2
"III" -> 3
"IV" -> 4
"V" -> 5
"VI" -> 6
"VII" -> 7
"VIII" -> 8
"IX" -> 9

"X" -> 10
"XX" -> 20
"XXX" -> 30
"XL" -> 40
"L" -> 50
"LX" -> 60
"LXX" -> 70
"LXXX" -> 80
"XC" -> 90

"C" -> 100
"CC" -> 200
"CCC" -> 300
"CD" -> 400
"D" -> 500
"DC" -> 600
"DCC" -> 700
"DCCC" -> 800
"CM" -> 900

"M" -> 1000
"MM" -> 2000
"MMM" -> 3000
"MMMM" -> 4000

"MCMXC" -> 1990 ("M" -> 1000 + "CM" -> 900 + "XC" -> 90)
"MMVIII" -> 2008 ("MM" -> 2000 + "VIII" -> 8)
"XCIX" -> 99 ("XC" -> 90 + "IX" -> 9)
"XLVII" -> 47 ("XL" -> 40 + "VII" -> 7)
