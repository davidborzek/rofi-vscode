#!/usr/bin/env bash

### Workspaces ###
pathToWorkspaces=$(echo "$1"  | sed 's:/*$::')

help="rofi-vscode usage:\n 	[directory or args]\n\nDirectory:\n	Folder of your vscode workspaces (./ for current dir) \n\nArgs:\n	-h / -H / --help	Help page"

if [[ ${pathToWorkspaces} == -* ]]; then
	if [ ${pathToWorkspaces} = "-h" ] || [ ${pathToWorkspaces} = "-H" ] || [ ${pathToWorkspaces} = "--help" ]; then
		echo -e $help
	else
		echo -e $help
		exit
	fi;
fi;

if [[ ! -d "$pathToWorkspaces" ]]; then
	echo "Error: the directory does not exist."
	exit
fi;

### Options ###
newWorkspace="Create new workspace"

args=( -dmenu
	-kb-custom-1 'Alt+r'
	-kb-custom-2 'Alt+e'
	-kb-custom-3 'Alt+Return'
	-p 'VSCode Workspace Selector > '
)

chosen=$(echo -e "$(ls  $pathToWorkspaces)\n\n$newWorkspace" | rofi "${args[@]}")

rofi_status=$?

if [ ${rofi_status} = "1" ]; then
		exit
fi;

if [ ${rofi_status} = "10" ]; then
	shouldDelete=$(echo -e "Yes\nNo" | rofi -dmenu -p "Do you want to delete the workspace '$chosen'?");
	if [ ${?} = "1" ]; then
		exit
	fi;

	if [ ${?} = "0" ]; then
		if [ ${shouldDelete} = "Yes" ]; then
			rm -r "$pathToWorkspaces/$chosen/"
		fi;
	fi;
fi;

if [ ${rofi_status} = "11" ]; then
	newName=$(rofi -dmenu -p "(ESC to abort) Rename the workspace '$chosen': ");
	if [ ${?} = "1" ]; then
		exit
	fi;

	if [ ${?} = "0" ]; then
		mv "$pathToWorkspaces/$chosen/" "$pathToWorkspaces/$newName/"
	fi;
fi;

if [ ${rofi_status} = "12" ]; then
	operation=$(echo -e "Name: $chosen\nPath: $pathToWorkspaces/$chosen\n\nOpen\nEdit\nDelete" | rofi -dmenu -p "(ESC to abort) Workspace information: ");
	if [ ${?} = "1" ]; then
		exit 
	fi;

	if [ ${?} = "0" ]; then
		echo "Yo"
		if [ ${operation} = "Open" ]; then
			code "$pathToWorkspaces/$chosen/"
			exit
		fi;

		if [ ${operation} = "Edit" ]; then
			newName=$(rofi -dmenu -p "(ESC to abort) Rename the workspace '$chosen': ");
			if [ ${?} = "1" ]; then
				exit 
			fi;

			if [ ${?} = "0" ]; then
				mv "$pathToWorkspaces/$chosen/" "$pathToWorkspaces/$newName/"
			fi;
		fi;

		if [ ${operation} = "Delete" ]; then
			shouldDelete=$(echo -e "Yes\nNo" | rofi -dmenu -p "Do you want to delete the workspace '$chosen'?");
			if [ ${?} = "1" ]; then
				exit
			fi;

			if [ ${?} = "0" ]; then
				if [ ${shouldDelete} = "Yes" ]; then
					rm -r "$pathToWorkspaces/$chosen/"
				fi;
			fi;
		fi;

	fi;
fi;

if [ ${rofi_status} = "0" ]; then
	if [ "$chosen" = "$newWorkspace" ];
	then
		newWorkspaceName=$(rofi -dmenu -p "Workspace Name: ")
		mkdir "$pathToWorkspaces/$newWorkspaceName/" && code "$pathToWorkspaces/$newWorkspaceName/"
	else
		code "$pathToWorkspaces/$chosen/"
	fi;
fi;