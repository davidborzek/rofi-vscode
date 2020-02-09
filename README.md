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

The script will open a rofi dmenu where it will list all the directories in the given workspaces directory. If you select a directory (or project) it will open it in vscode.

The ``Create new workspace`` functionality asks your for new directory name and creates a new directory in the workspaces folder. 

### Keybindings

- ``Alt+r``: Remove the selected workspace
- ``Alt+e`` : Edit (rename) the selected workspace
- ``Alt+Return``: Open a information view about the selected workspace

## Screenshots

soon...

