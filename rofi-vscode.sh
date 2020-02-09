#!/bin/sh

### Workspaces ###
pathToWorkspaces=$(echo "$1")

### Options ###
newWorkspace="Create new workspace"

chosen=$(echo "$(ls  $pathToWorkspaces)\n\n$newWorkspace" | rofi -dmenu -kb-custom-1 "Alt+r" -kb-custom-2 "Alt+e" -p "VSCode Workspace Selector > ")

rofi_status=$?

if [ ${rofi_status} = "1" ]; then
		exit
fi;

if [ ${rofi_status} = "10" ]; then
	shouldDelete=$(echo "Yes\nNo" | rofi -dmenu -p "Do you want to delete the workspace '$chosen'?");
	echo $?
	if [ ${?} = "1" ]; then
		exit
	fi;

	if [ ${?} = "0" ]; then
		if [ ${shouldDelete} = "Yes" ]; then
			rm -r "$pathToWorkspaces$chosen/"
		fi;
	fi;
fi;

if [ ${rofi_status} = "11" ]; then
	newName=$(rofi -dmenu -p "(ESC to abort) Rename the workspace '$chosen': ");
	if [ ${?} = "1" ]; then
		exit 
	fi;

	if [ ${?} = "0" ]; then
		mv "$pathToWorkspaces$chosen/" "$pathToWorkspaces$newName/"
	fi;
fi;

if [ ${rofi_status} = "0" ]; then
	if [ "$chosen" = "$newWorkspace" ];
	then
		newWorkspaceName=$(rofi -dmenu -p "Workspace Name: ")
		mkdir "$pathToWorkspaces$newWorkspaceName/" && code "$pathToWorkspaces$newWorkspaceName/"
	else
		code "$pathToWorkspaces/$chosen/"
	fi;
fi;