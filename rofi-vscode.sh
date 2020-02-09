#!/bin/sh

### Workspaces ###
pathToWorkspaces=$(echo "$1")

### Options ###
newWorkspace="Create new workspace"

chosen=$(echo "$(ls  $pathToWorkspaces)\n\n$newWorkspace" | rofi -dmenu -p "VSCode Workspace Selector > ")

rofi_status=$?

### New Entry ###
newWorkspaceName=""

if [ ${rofi_status} = "1" ]; then
		exit
fi;

if [ "$chosen" = "$newWorkspace" ]
then
	newWorkspaceName=$(rofi -dmenu -p "Workspace Name: ")
	mkdir "$pathToWorkspaces$newWorkspaceName/" && code "$pathToWorkspaces$newWorkspaceName/"
else
	code "$pathToWorkspaces/$chosen/"
fi
