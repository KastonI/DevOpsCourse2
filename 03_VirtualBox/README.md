### 2. Creating a New Virtual Machine:
At this stage, I chose the name of the virtual machine, its location, and the ISO image I used.

![Pasted image 20240903224430](https://github.com/user-attachments/assets/500c0c80-8c4e-4553-8b8a-6d67c53796e3)

### 3. Configuring the Virtual Machine:
Here, I selected the amount of RAM and the number of processor cores.

![Hardware](https://github.com/user-attachments/assets/673038bc-51da-4a89-bd4c-0c9e54c01cba)

For this virtual machine, 20GB of disk space was enough. I also checked the option to make the virtual disk **static** (this was a mistake).

![VirtualHardDisk](https://github.com/user-attachments/assets/ba4c7e2e-5bbc-4dda-a25e-7ec8a51c3039)

Additionally, I set up a **bridge** network adapter.

![Bridge](https://github.com/user-attachments/assets/25f10ebc-a59d-431f-8158-047079661203)

### 4. Installing the Operating System:
The ISO image was added as an optical disk.

![Iso](https://github.com/user-attachments/assets/82604b71-aded-4caa-ab7b-bb1e701031e1)

#### Install Ubuntu on Your Virtual Machine
During installation, I answered some basic questions like selecting a language, choosing a username, setting a password, and more.

![UbuntuInstall](https://github.com/user-attachments/assets/3823ac0f-21ff-4036-b016-d663b6da8085)

### 5. Saving and Restoring the VM State:
#### Create a Snapshot of Your VM After Setup
Right after installation, I created a system snapshot to save its working state.

![Snapshot](https://github.com/user-attachments/assets/9319d989-e6fc-40cb-9fbf-f950c672b5e5)

#### Run Basic Commands (For Example, Creating a File, `rm -rf /`)
I ran the command `rm -rf /`, which **completely destroyed my system**. After running it, the system wouldn’t start. The only thing that helped me recover was the snapshot.

![RMrf](https://github.com/user-attachments/assets/b60bfa2b-5bfc-4795-8e95-e1d9ab66c118)

#### Restore the VM to the Previous Snapshot
The snapshot worked, and the system was restored to the exact state it was in before the experiment.

![SnappshotFix](https://github.com/user-attachments/assets/f3bce851-4497-42e7-8354-23a667176fbb)

### 6. Changing VM Settings via the GUI:
#### Increasing the Disk Size:
At this stage, I encountered an issue: when creating a **fixed-size** disk, **its size cannot be changed later**. This applies to both `.vdi` and `.vhd` formats. 

On the VirtualBox forum, the recommended solution was to create a **copy** and change the disk type to **dynamic**.

I did this using the `clonemedium` and `modifymedium` commands.

![VDIfix](https://github.com/user-attachments/assets/05742bc1-b983-43ef-a088-378b23fa954c)

#### After Increasing the Disk Size, Expand the Filesystem in Ubuntu:
Using the commands suggested by ChatGPT, I successfully expanded the filesystem. 😆

![Resize](https://github.com/user-attachments/assets/60b3ad57-22fa-4cf3-a3c1-b5fecf2064b3)

#### Final Result:

![ResultResize](https://github.com/user-attachments/assets/803e2f0b-f905-49d7-a720-6043f3312cd0)

#### Changing CPU Cores and RAM:

![ChangeHardware](https://github.com/user-attachments/assets/531b8a93-30ab-49f2-983e-f56415b0d44b)

#### Shutting Down and Deleting the VM:
To shut down the machine, I used the command:

```sh
shutdown -P now
```

To delete it, I used the **GUI** option **"Remove with all files"**.

---

### Shared Folder on Ubuntu Server:
To create a shared folder, first go to the **Devices** menu and select **"Insert Guest Additions CD image"**.

![Folder](https://github.com/user-attachments/assets/ad36dbc1-87d4-42f4-956c-38d7ffcbf197)

This creates a **virtual CD-ROM**, which needs to be mounted to a folder.

![MountCdrom](https://github.com/user-attachments/assets/e067020a-eaa9-40cd-b3fb-457dde035d7c)

Inside, there is a file called `VBoxLinuxAdditions.run`. Before running it, install the necessary dependencies using:

```sh
sudo apt-get install build-essential
```

Then, execute the script:

```sh
./VBoxLinuxAdditions.run
```

This installs the required additions.

Next, create a folder for shared files and shut down the virtual machine.

```sh
mkdir ubuntu_files
```

Then, go to the **VM settings** and configure the shared folder.

![FolderInVM](https://github.com/user-attachments/assets/46008907-0cec-4f68-8cb9-745e8d517eb4)

For the **"Path to the folder"**, select a location on your local machine.  
For **"Mount point"**, enter the path to the folder you just created on the VM.

That’s it! Now, files from your local machine are accessible inside the virtual machine. 🎉

![Finish](https://github.com/user-attachments/assets/ff4befc7-4f69-4380-8604-55be072ad59c)