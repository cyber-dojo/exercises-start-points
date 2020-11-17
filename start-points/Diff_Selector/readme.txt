
When showing the diff for a traffic-light, cyber-dojo
has a function to select one of the files.

The function has two parameters:
  o) the string filename selected from the previous traffic-light
  o) an array of diff data, one diff per file.

The function returns the index of the selected diff in the array.

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

The meaning of the four data fields is as follows:

1) "type" is a string
   One of ["deleted","created","renamed","unchanged","changed"]

2) "old_filename" is a string
3) "new_filename" is a string
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

4) "line_counts"
   if "type" is "deleted"
     "deleted" was the number of lines in the deleted file
     "added" is zero
     "same" is zero

   if "type" is "created"
     "added" is the number of lines in the created file
     "deleted" is zero
     "same" is zero

   if "type" is "renamed"
     "added" is the number of added lines
     "deleted" is the number of deleted lines
     "same" is the number of unchanged lines
      ("added" and "deleted" will both be zero
       for an *identical* rename)

   if "type" is "unchanged"
     "added" is zero
     "deleted" is zero
     "same" is the number of lines in the unchanged file

   if "type" is "changed"
     "added" is the number of added lines
     "deleted" is the number of deleted lines
     "same" is the number of unchanged lines.
      
The function implements these five cascading rules:

Rule 1:
If the previous-filename exists in the array
and has changed content, select it. Note this
rule can select both deleted and created files.

Rule 2:
If any of the diffs in the array has changed
content, select the one with the largest change,
where largest means the total of the added line-count
and the deleted line-count.

Rule 3:
If any of the diffs in the array is for an identical
rename, select the one with the largest content,
where largest means the same line-count.

Rule 4:
If the previous-filename exists in the array
(but has not changed its name nor its content)
select it.

Rule 5:
Select the diff whose filename is 'cyber-dojo.sh'
This will always be present in the array.

Note: 'changed content' means the added line-count
is greater than zero or the deleted line-count is
greater than zero (or both).

Your task is to implement this selection function.
