# rofi-vscode
##### Table of Contents  
- [Installation](#installation)  
- [Usage](#usage)  
- [Screenshots](#screenshots) 


## Installation

1. Clone or download the repository.
2. Install [rofi](https://github.com/davatorium/rofi/blob/next/INSTALL.md#install-distribution).
3. Run ``make install``. (maybe you need ``sudo`` permissons to do this)

## Usage

### Example

If the script is in a binary directory:
``rofi-vscode [directory]``

Replace ``[directory]`` with the directory of your vscode workspaces. (e.g. ``/home/user/git``)

### Functions

The script will open a rofi dmenu where it will list all the directories in the given workspaces directory. If you select a directory (or project) it will open it in vscode.

- ``Create new workspace``: It asks you for new directory name and creates a new directory in the workspaces folder. Finally it will open it in VSCode.
- ``Add existing project from git`` : It allows you to clone a git repository from the scirpt either from a SSH or a HTTPS source.

### Keybindings

- ``Alt+r``: Remove the selected workspace
- ``Alt+e`` : Edit (rename) the selected workspace
- ``Alt+Return``: Open a information view about the selected workspace
- ``Alt+t``: Opens the selected workspace in a terminal

## Requirements

- rofi
- git
- curl
- Visual Studio Code (code)

## Screenshots

soon...
