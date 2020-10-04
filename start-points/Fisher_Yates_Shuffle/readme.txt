The Fisher–Yates shuffle is an algorithm for generating a random permutation of a finite sequence. In plain terms, the algorithm shuffles the sequence. The algorithm effectively puts all the elements into a hat; it continually determines the next element by randomly drawing an element from the hat until no elements remain. The algorithm produces an unbiased permutation: every permutation is equally likely.

-- To shuffle an array a of n elements (indices 0..n-1):
for i from n−1 downto 1 do
     j ← random integer such that 0 ≤ j ≤ i
     exchange a[j] and a[i]

Task:
Implement and test this algorithm.

[Source https://en.wikipedia.org/wiki/Fisher-Yates_shuffle]
