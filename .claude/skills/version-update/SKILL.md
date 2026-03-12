Run `make version-check` and update any outdated versions in `.mk` files.

Steps:

1. Run `make version-check` and capture the output.

2. Find all lines containing `->` in the output.
   These lines have the format:
   `<file>  <old-version>  ->  <new-version>  <url>`

3. For each such line, open the corresponding `.mk` file and update
   line 1, replacing the old version string with the new version string.
   Line 1 always contains the version variable assignment, e.g.:
   `GO-VERSION ?= 1.2.3`

4. Run `make version-check` again and confirm that no lines containing
   `->` appear in the output.
   If any remain, repeat steps 2-3 for those files.

5. Commit the changes with `git commit`.
   The commit message should list the updated packages and versions.
   Do not add a "Co-authored-by" line.
