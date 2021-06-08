
# Summary
This is a simple PowerShell script that helps you to sign in to multiple Microsoft Teams accounts on your desktop and start it automatically when you log in. It creates additional MS Teams apps beside your default one that you can use to log in with your other accounts. You can add many MS Teams apps, list and remove them.
doc/ms-teams-tray.JPG

![screenshot](doc/ms-teams-tray.JPG)

# Usage
- Copy the `ms-teams-multi-account.ps1` to your local machine.
- Open a **PowerShell window in administrator mode**.
- Change your current directory in PowerShell where you downloaded the `ms-teams-multi-account.ps1` file.
- Type the following command to be able to run the script: `Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser`
- Run the script with the name of your new Teams app. Example: 
	`./ms-teams-multi-account.ps1 -p personal -a`
# Examples
- Create and run a Teams app called 'personal' and automatically start when you log in: 
	`./ms-teams-multi-account.ps1 -p personal -a`
- Show the list of your created Teams apps:
	`./ms-teams-multi-account.ps1 -l`
- Remove a Teams apps called 'personal':
	`./ms-teams-multi-account.ps1 -r personal`
- Display help information about this script:
`./ms-teams-multi-account.ps1 -h`
# Notes
- The script uses the Windows Task Scheduler to automatically start the created Teams app when logging in. This feature requires PowerShell in administrator mode.
- The tool copies the `ms-teams-multi-account.ps1` file to your user folder (C:\Users\\&#60;username&#62;) when you want to start your new Teams app automatically. This file is run by Windows Task Scheduler when logging in.
- After you created your new Teams app you can restore your execution policy to restricted: `Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser`
