## How to install mkbranch, mkcommit and install-git-hooks

``` Bash
git clone https://github.com/T-vK/git-tools.git
cd git-tools
echo "export PATH=\"$PATH:$(pwd)\"" >> ~/.bashrc
```

## mkbranch
Guides you through the creation of a branch using a certain commit convention

## mkcommit
Guides you through the creation of creating a commit with a commit message using a certain convention

## install-git-hooks
Installs a commit hook in the repository you run it. This hook prevents you from accidentally making commits with messages that don't follow the convention.  
(The hook can't be pushed and only works on your machine where you installed it.)

To uninstall it again, delete the .git/hooks/commit-msg file from the repository again.
