
When doing a cyber-dojo group exercise, you can review
the files from any active avatar in the group!

The [<] button moves you to the previous avatar.
The [>] button moves you to the next avatar.

The previous/next ordering is based on the
avatar's indexes, which have a range of [0..64)
 0==alligator
 1==antelope
 ...
62==wolf
63==zebra

Your task is to implement a function called groupNeighbours()
which is passed two arguments:
  o) the current avatar's id (String)
  o) data for all the avatars (Hash)

For example:
  groupNeighbours("Q55b8b", {
    "15": { id:"EEJSkR", events:[0,1,2]     }, // 15==fox
     "3": { id:"w34rd5", events:[0]         }, //  2==bear
    "23": { id:"Q55b8b", events:[0,1,2,3]   }, // 23==jellyfish
    "44": { id:"REf1t7", events:[0,1,2,3,4] }, // 44==rhino
  })

The function must return three pieces of data:
  o) the id of the previous avatar
  o) the avatar-index matching the id (1st arg)
  o) the id of the next avatar

0) The keys of the Hash are Strings not Integers.

1) The Hash always contains an entry whose id matches the 1st arg.

2) If there is no previous avatar, return an empty string.
   For example
     groupNeighbours("2z4449", {
       "36": { id:"2z4449", events:[0,1,2,3]     }, // 36==parrot
       "49": { id:"s86eR4", events:[0,1,2,3,4,5] }, // 49==snake
     })
   returns
       [ "", 36, "s86eR4" ]

3) If there is no next avatar, return an empty string.
   For example
     groupNeighbours("s86eR4", {
       "36": { id:"2z4449", events:[0,1,2,3]     }, // 36==parrot
       "49": { id:"s86eR4", events:[0,1,2,3,4,5] }, // 49==snake
     })
   returns
     [ "2z4449", 49, "" ]

4) Ignore inactive avatars - whose events array has less than 2 entries.
   For example:
     groupNeighbours("Q55b8b", {
       "15": { id:"EEJSkR", events:[0,1,2]     }, // 15==fox
        "3": { id:"w34rd5", events:[0]         }, //  3==bear (inactive)
       "23": { id:"Q55b8b", events:[0,1,2,3]   }, // 23==jellyfish
       "44": { id:"REf1t7", events:[0,1,2,3,4] }, // 44==rhino
     })
   returns
     [ "EEJSkR", 23, "REf1t7" ]
   not
     [ "w34rd5", 23, "REf1t7" ]

5) Return the avatar-index as an integer.
   For example
     [ "EEJSkR", 23, "REf1t7" ]
   not
     [ "EEJSkR", "23", "REf1t7" ]
