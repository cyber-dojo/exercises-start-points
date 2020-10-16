
In information theory and computer science, the Levenshtein distance is a metric for measuring the amount of difference between two sequences (i.e. an edit distance). The Levenshtein distance between two strings is defined as the minimum number of edits needed to transform one string into the other, with the allowable edit operations being insertion, deletion, or substitution of a single character.

Examples:
The Levenshtein distance between "kitten" and "sitting" is 3, since the following three edits change one into the other, and there isn't a way to do it with fewer than three edits:

              kitten   sitten    (substitution of 'k' with 's')
              sitten   sittin    (substitution of 'e' with 'i')
              sittin   sitting   (insert 'g' at the end).

The Levenshtein distance between "rosettacode", "raisethysword" is 8.

Note:
The distance between two strings is same as that when both strings are reversed.

Task:
Implements a Levenshtein distance function, or uses a library function.
Show the Levenshtein distance between "kitten" and "sitting".

[Source https://rosettacode.org]
