
When reviewing a traffic-light, cyber-dojo uses a
function to select one of the files.

Your task is to write this selection function.

The function has two parameters:
  o) previous-filename; a string
     the filename of the previously viewed traffic-light
  o) diffs; an array
     diff data, one per file.

The function returns the index of the selected diff
(in diffs) according to the following cascading rules:

Rule 1:
If any diff is for a changed, previous-filename,
select it.

Rule 2:
If any diff is for a changed, non .txt file,
select one with the (possibly equal) largest change-count.

Rule 3:
If any diff is for an identically renamed, non .txt file,
select one with the (possibly equal) largest same-count.

Rule 4:
If any diff is for an empty, created, non .txt file,
select one.

Rule 5:
If any diff is for an empty, deleted, non .txt file,
select one.

Rule 6:
If any diff is for a changed, .txt file,
select one with the (possibly equal) largest change-count.

Rule 7:
If any diff is for an identically renamed, .txt file,
select one with the (possibly equal) largest same-count.

Rule 8:
If any diff is for the (unchanged) previous-filename,
select it.

Rule 9:
Select the diff whose filename is 'cyber-dojo.sh'


Note:
o) 'changed' means 'change-count' is greater than zero.

o) 'change-count' means the sum of the
   added line-count and the deleted line-count.

o) a diff for 'cyber-dojo.sh' will always exist.


The diff data for each file is in JSON format.
For example:
  {
    "type": "changed",
    "old_filename": "hiker.h",
    "new_filename": "hiker.h",
    "line_counts: {
      "added":4, "deleted":3, "same":27
    }
  }

o) "type" is a string

   One of ["deleted","created","renamed","unchanged","changed"]

o) "old_filename" is a string
o) "new_filename" is a string

   if "type" is "deleted"
     "old_filename" will be the filename
     "new_filename" will be null
   if type is "created"
     "old_filename" will be null
     "new_filename" will be the filename
   if type is "renamed"
      "old_filename" will be the old filename
      "new_filename" will be the new (different) filename
   if "type" is "unchanged"
      "old_filename" will be the filename
      "new_filename" will be the (same) filename
       (neither the file's content nor its name has changed)
   if "type" is "changed"
      "old_filename" will be the filename
      "new_filename" will be the (same) filename
      (the file's content has changed, but not its name)

o) "line_counts"

   if "type" is "deleted"
     "added" is zero
     "same" is zero
     "deleted" was the number of lines in the deleted file
       (zero if the deleted file was empty)

   if "type" is "created"
     "deleted" is zero
     "same" is zero
     "added" is the number of lines in the created file
       (zero if the created file was empty)

   if "type" is "renamed"
     "added" is the number of added lines
     "deleted" is the number of deleted lines
     "same" is the number of unchanged lines
       (for an identical rename, "added" and "deleted"
        will both be zero)

   if "type" is "unchanged"
     "added" is zero
     "deleted" is zero
     "same" is the number of lines in the unchanged file

   if "type" is "changed"
     "added" is the number of added lines
     "deleted" is the number of deleted lines
     "same" is the number of unchanged lines.
       ("added" or "deleted" or both will be non-zero)
