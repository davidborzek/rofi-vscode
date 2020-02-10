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

edit () {
	newName=$(rofi -dmenu -p "(ESC to go back) Rename the workspace '$chosen': ");
	if [ ${?} = "1" ]; then
		main
	fi;

	if [ ${?} = "0" ]; then
		mv "$pathToWorkspaces/$chosen/" "$pathToWorkspaces/$newName/"
		main
	fi;
}

remove () {
	shouldDelete=$(echo -e "Yes\nNo" | rofi -dmenu -no-custom -p "(ESC to go back) Do you want to delete the workspace '$chosen'?");
	if [ ${?} = "1" ]; then
		main
	fi;

	if [ ${?} = "0" ]; then
		if [ ${shouldDelete} = "Yes" ]; then
			rm -rf "$pathToWorkspaces/$chosen/"
			main
		fi;
		main
	fi;
}

check_if_https () {
	if [[ ${1} == https* ]]; then
		return 0;
	fi;
	return 1;
}

check_if_git_repo_is_public () {
	url_to_check=${1//.git/}
	check_if_https "$1"
	if [ ${?} = "0" ]; then
		statusCode=$(curl -I -q $url_to_check | head -n 1 | cut -d$' ' -f2)
		if [ "$statusCode" = "200" ]; then
			return 0;
		else
			if [[ $url_to_check =~ "@" ]] && [[ $url_to_check =~ ":" ]]
			then
				return 0;
			fi
			return 1;
		fi;
	else
		return 0;
	fi;
}

check_if_git_repo_exists () {
	git ls-remote $1 > /dev/null 2>&1
	if [ "$?" -ne 0 ]; then
		rofi -e "[ERROR] No git repository found at '$git_url' or invalid username/password!"
		echo "[ERROR] No git repository found at '$git_url' or invalid username/password!"
		exit 1;
	fi
}

check_if_successfully_cloned () {
	if [ "$1" = 0 ]; then
		openClonedWorkspace=$(echo -e "Yes\nNo" | rofi -dmenu -no-custom -p "Successfully cloned! Do you want to open '$2'?");

		if [ ${?} = "1" ]; then
			main
		fi;

		if [ ${?} = "0" ]; then
			if [ ${openClonedWorkspace} = "Yes" ]; then
				code "$pathToWorkspaces/$2"
			fi;
			main
		fi;
	else
		rofi -e "Error! Please try it again!"
	fi;
}

clone_private_https_repo () {
	username=$(rofi -dmenu -p "(ESC to abort) Github Username: ")
	if [ ${?} = "1" ]; then
			main
	fi;
	password=$(rofi -dmenu -password -p "(ESC to abort) Github Password: ")
	if [ ${?} = "1" ]; then
			main
	fi;

	repoPath=${1//"https://"/}
	repoName=$(basename $git_url | cut -d '.' -f 1)

	authorized_git_url="https://$username:$password@$repoPath"

	check_if_git_repo_exists "$authorized_git_url"

	git clone $authorized_git_url "$pathToWorkspaces/$repoName"
}

clone_from_git () {
	git_url=$(rofi -dmenu -p "(HTTPS or SSH) Git repository url: ")
	if [ ${?} = "1" ]; then
		main
	fi;

	if [ ${?} = "0" ]; then
		command -v git >/dev/null 2>&1 || { echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }

		check_if_git_repo_is_public "$git_url"

		if [ ${?} = "1" ]; then
			clone_private_https_repo "$git_url"
		else

			check_if_git_repo_exists "$git_url"

			repoName=$(basename $git_url | cut -d '.' -f 1)

			git clone $git_url "$pathToWorkspaces/$repoName"

			check_if_successfully_cloned "$?" "$repoName"

		fi;
	fi;
}

open_in_terminal () {
	cd $1 && rofi-sensible-terminal
}

main () {

	### Options ###
	newWorkspace="Create new workspace"
	existingWorkspaceFromGit="Add existing project from git"

	args=( -dmenu
		-i
		-no-custom
		-kb-custom-1 'Alt+r'
		-kb-custom-2 'Alt+e'
		-kb-custom-3 'Alt+Return'
		-kb-custom-4 'Alt+t'
		-p 'VSCode Workspace Selector > '
	)

	chosen=$(echo -e "$(ls  $pathToWorkspaces)\n\n$newWorkspace\n$existingWorkspaceFromGit" | rofi "${args[@]}")

	rofi_status=$?

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
		git_remote_url=$(git -C $pathToWorkspaces/$chosen config --get remote.origin.url)
		operation=$(echo -e "Name: $chosen\nPath: $pathToWorkspaces/$chosen\nGit remote url: $git_remote_url\n\nOpen\nTerminal\nEdit\nDelete" | rofi -dmenu -i -no-custom -p "(ESC to go back) Workspace information: ");
		if [ ${?} = "1" ]; then
			main 
		fi;

		if [ ${?} = "0" ]; then

			if [ ${operation} = "Open" ]; then
				code "$pathToWorkspaces/$chosen/"
				exit
			fi;

			if [ ${operation} = "Terminal" ]; then
				open_in_terminal "$pathToWorkspaces/$chosen/"
			fi;

			if [ ${operation} = "Edit" ]; then
				edit
			fi;

			if [ ${operation} = "Delete" ]; then
				remove
			fi;

		fi;
	fi;

	if [ ${rofi_status} = "13" ]; then
		open_in_terminal "$pathToWorkspaces/$chosen/"
	fi;

	if [ ${rofi_status} = "0" ]; then
		if [ "$chosen" = "$newWorkspace" ];
		then
			newWorkspaceName=$(rofi -dmenu -p "Workspace Name: ")
			mkdir "$pathToWorkspaces/$newWorkspaceName/" && code "$pathToWorkspaces/$newWorkspaceName/"
		elif [ "$chosen" = "$existingWorkspaceFromGit" ]; then
			clone_from_git
		else
			if [ ! "$chosen" = "" ]; then
				code "$pathToWorkspaces/$chosen/"
			fi;
		fi;
	fi;

}

main