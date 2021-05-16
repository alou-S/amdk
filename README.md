# amdk (Android Memory Daemon Kryo)
Script made to prevent and freeze Android Memory Daemons from killing apps.

The script gives an app immunity against oomd and disables lmkd.
Only works with root.

## How to use
Just give the script executable permission and run it as root.
You can edit the script and add or remove apps from the array in the 4th line.
**Be aware** that your system can get unstable if you commit too much RAM.



## What this won't do.
This script ONLY prevents the Android Low Memory Killer and Out Of Memory daemons from killing your app.

This **WONT** prevent a vendor implemented memory daemon from killing the app.
This **WONT** prevent a vernder implemented battery optimization services from killing the app.
Check https://dontkillmyapp.com/ for vendor related solutions.



## How it Works
The script does 2 things
Firstly it sets the apps oom_adj value to -17 which makes oomd (out of memory daemon) ignore the process.

Secondly it sends lmkd to suspend state and resumes it for a 200ms wait every 5 seconds and then immediately suspends it again.

### Why suspend rather than kill?
Kill lmkd will make Android start it again after a few seconds. Killing it multiple times will cause a kernel panic.

### Why resume every 5 seconds?
Suspending lmkd for too long will cause ART to panic and freeze itself.
_________________


This script was mainly created by me so my phone can run a Minecraft server on Termux (via chroot) 24/7 without Android killing it whenever it likes.
