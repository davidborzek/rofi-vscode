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
existingWorkspaceFromGit="Add existing project from git"

args=( -dmenu
	-kb-custom-1 'Alt+r'
	-kb-custom-2 'Alt+e'
	-kb-custom-3 'Alt+Return'
	-p 'VSCode Workspace Selector > '
)

chosen=$(echo -e "$(ls  $pathToWorkspaces)\n\n$newWorkspace\n$existingWorkspaceFromGit" | rofi "${args[@]}")

rofi_status=$?

edit () {
	newName=$(rofi -dmenu -p "(ESC to abort) Rename the workspace '$chosen': ");
	if [ ${?} = "1" ]; then
		exit
	fi;

	if [ ${?} = "0" ]; then
		mv "$pathToWorkspaces/$chosen/" "$pathToWorkspaces/$newName/"
	fi;
}

remove () {
	shouldDelete=$(echo -e "Yes\nNo" | rofi -dmenu -p "Do you want to delete the workspace '$chosen'?");
	if [ ${?} = "1" ]; then
		exit
	fi;

	if [ ${?} = "0" ]; then
		if [ ${shouldDelete} = "Yes" ]; then
			rm -r "$pathToWorkspaces/$chosen/"
		fi;
	fi;
}

clone_from_git () {
	git_url=$(rofi -dmenu -p "Git URL (SSH / HTTPS): ")
	if [ ${?} = "1" ]; then
		exit
	fi;

	if [ ${?} = "0" ]; then
		command -v git >/dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }
		git ls-remote $git_url > /dev/null 2>&1
		if [ "$?" -ne 0 ]; then
			echo "[ERROR] No git repository found at '$git_url'"
			exit 1;
		fi
		repoName=$(basename $git_url | cut -d '.' -f 1)

		editName=$(echo -e "Yes\nNo" | rofi -dmenu -p "Do you want to rename the repository '$repoName'?");

		if [ ${?} = "1" ]; then
			exit
		fi;

		if [ ${?} = "0" ]; then
			if [ ${shouldDelete} = "Yes" ]; then
				newName=$(rofi -dmenu -p "(ESC to abort) Rename the repository '$chosen': ");
				if [ ${?} = "1" ]; then
					exit
				fi;

				if [ ${?} = "0" ]; then
					repoName=$newName
				fi;
			fi;
		fi;

		git clone $git_url "$pathToWorkspaces/$repoName"

	fi;
}

if [ ${rofi_status} = "1" ]; then
	exit
fi;

if [ ${rofi_status} = "10" ]; then
	remove
fi;

if [ ${rofi_status} = "11" ]; then
	edit
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
			edit
		fi;

		if [ ${operation} = "Delete" ]; then
			remove
		fi;

	fi;
fi;

if [ ${rofi_status} = "0" ]; then
	if [ "$chosen" = "$newWorkspace" ];
	then
		newWorkspaceName=$(rofi -dmenu -p "Workspace Name: ")
		mkdir "$pathToWorkspaces/$newWorkspaceName/" && code "$pathToWorkspaces/$newWorkspaceName/"
	elif [ "$chosen" = "$existingWorkspaceFromGit" ]; then
		clone_from_git
	else
		code "$pathToWorkspaces/$chosen/"
	fi;
fi;