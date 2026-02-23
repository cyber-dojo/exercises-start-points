James Bach, [describes](http://www.satisfice.com/blog/archives/22) counter strings as follows:

"A counterstring is a graduated string of arbitrary length. No matter where you are in the string, you always know the character position. This comes in handy when you are pasting huge strings into fields and they get truncated at a certain point. You want to know how many characters that is."

The string always ends in an asterisk and any number in a string denotes the position of the succeeding asterisk.

Length 5: *3*5*
Length 10: *3*5*7*10*
Length 35: 2*4*6*8*11*14*17*20*23*26*29*32*35*

Your task is to write a program that takes a non-negative integer number and creates a counterstring of that length.
