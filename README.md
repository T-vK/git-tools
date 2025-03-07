## How to install mkbranch, mkcommit and install-git-hooks

### Linux/macOS

```bash
git clone https://github.com/T-vK/git-tools.git
cd git-tools
./install.sh
```

### Windows

```powershell
git clone https://github.com/T-vK/git-tools.git
cd git-tools
.\install.ps1
```

## mkbranch

Guides you through the creation of a branch using a certain commit convention

## mkcommit

Guides you through the creation of creating a commit with a commit message using a certain convention

## install-git-hooks

Installs a commit hook in the repository you run it. This hook prevents you from accidentally making commits with messages that don't follow the convention.
(The hook itself can't be committed or pushed and only works on the machine you installed it on.)

### Uninstalling

#### Linux/macOS
Delete the .git/hooks/commit-msg file from the repositories in which you ran `install-git-hooks` and delete the `export PATH="$PATH:/xxxxxxxxxxx/git-tools/bin"` line from your `~.bashrc` and/or `~/.zshrc` file.

#### Windows
Delete the .git/hooks/commit-msg file from the repositories in which you ran `install-git-hooks` and remove the git-tools path from your PATH environment variable.
