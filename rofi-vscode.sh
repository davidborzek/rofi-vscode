#!/bin/sh

### Workspaces ###
pathToWorkspaces=$(echo "$1")
workspaces="$(ls -1 $pathToWorkspaces)"

numberOfWorkspaces=$(ls -1 $pathToWorkspaces | wc -l)

### Options ###
newWorkspace="Add new workspace"
options=""

for i in $(seq 1 $numberOfWorkspaces);
do
	options="$options$(echo $workspaces | cut -d " " -f $i )\n"
done


chosen="$(echo -e "$options$newWorkspace" | rofi -dmenu -p "VSCode Workspace Selector > ")"

### New Entry ###
newWorkspaceName=""

if [ "$chosen" = "$newWorkspace" ]
then
	newWorkspaceName=$(rofi -dmenu -p "Workspace Name: ")
	mkdir "$pathToWorkspaces$newWorkspaceName/"
else
	if [ "$chosen" = "" ]
	then
		exit 0
	else
		code "$pathToWorkspaces/$chosen/"
	fi
fi
