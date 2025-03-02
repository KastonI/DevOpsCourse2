# **Homework on the Topic "Introduction to Linux"**  

## **1. Choose a Distribution**  
For this homework, I chose **Debian 12.7**. I completed the tasks on my **mini server**, which has a **32-bit architecture**, so this distribution was the best option.  

---

## **2. Configure a User and Install Packages**  
To add and configure a new user, I used the following commands:  

```sh
useradd -m illia        # Create new user
passwd illia            # Set password
usermod -aG sudo illia  # Add the user to the sudo group
usermod -c "New account" illia  # Add a comment to the user
chsh -s /bin/bash illia # Change shell to bash
su illia                # Switch to the new user
```

To install the necessary packages:  

```sh
sudo apt install htop vim git
```

![apt_install](https://github.com/user-attachments/assets/0e1fd174-0c99-44ad-b788-3985daa227b0)

---

## **3. Clone a Git Repository, Create a Command History File, and Commit It**  
I configured **Git** and set up an **SSH key** for authentication with GitHub (details in `bash_history.txt`).  

Then, I cloned the repository into the home directory:  

```sh
sudo git clone git@github.com:KastonI/DevOpsCourse2.git
```

After that, I created a new branch named **`Lecture5`**.  

To save the command history, I used:  

```sh
history > bash_history.txt
```

Finally, I committed the `bash_history.txt` file to the **`Lecture5`** branch.  

---

## **4. Check System Status Using `htop`, Analyze the Output, and Add Observations**  
The **`htop`** command displays various system details and running processes.  

### **Observations:**  
- **`htop` provides an overview of CPU and memory usage.** This helps identify performance bottlenecks.  
- The **`Load average`** value is important—it shows system load over time, which helps detect past overloads.  
- **The interface is user-friendly**, with sorting and filtering options that make it easier to analyze processes.  
- The tool allows **changing the priority (nice value) of processes** to optimize performance.  
- In my case, since the system is mostly idle, CPU and memory usage are minimal.  
- I noticed the **SSH process** running, which I used to connect remotely, along with **`htop`** itself and other system processes.  

![htop](https://github.com/user-attachments/assets/d945e003-7e8d-42d4-96b1-50e06a4bbec1)  