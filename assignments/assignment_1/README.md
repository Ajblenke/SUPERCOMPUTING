
# Assignment 1

For this assignment we had to create a new subdirectory with our GitHub repository names ./assignments/assignment_1>

## Commands Used

# Navigate to repo and create assignment folder:
 ```
  cd ~/SUPERCOMPUTING
  mkdir -p assignments/assignment_1
  cd assignments/assignment_1
```

Using -p allows the creation of nested firectories without errors if a parent doesn't exist. Without it, the comman>
would fail if assignments/ didn't already exist. This lets us create nested directories in one command.

# Create subdirectories
``` mkdir -p data/{raw,clean} scripts results docs config logs  ```                                                >

The {} expression allows for the creation of multiple files/directories in one command. Without it, the command
would fail if assignments/ didn't already exist. This lets us create nested directories in one command.

# Create required markdown files
  ```touch README.md assignment_1_essay.md```

Touch creates an empty file which is needed since we are creating files not directories.

# Create placeholder files
```
touch data/{raw,clean}/example.txt scripts/script.sh results/example.txt docs/example.txt config/example.txt logs/l>
```                                                                                                                >
Placeholder files ensure our folder structure is preserved when we commit to GitHub. We used brace expansion again >
create files in both data/raw/ and data/clean/ with one command.

# Write in the README.md and assignment_1.md

```
  nano README.md
  nano assignment_1.md
```

After writing in the files using nano press Ctrl + O, then enter to confirm and Ctrl + X to exit.


# Stage the files
  ```
cd ~/SUPERCOMPUTING
  git add assignments/
```
git add stage files for commit. By assignments assignments/, we add the entire directory and all its contents.

# Commit the changes
 ``` git commit -m "Add Assignement 1: Project structure and rationale" ```

The -m flag lets you add the message to describe what this commit does.

# Push to GitHub
 ``` git push ```
