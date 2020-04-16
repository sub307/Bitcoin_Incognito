![XBI-Logo](https://cdn.discordapp.com/attachments/480401303197974528/524758926097645568/sticker_xbi_smaller_var1.png)
# Bitcoin Incognito (XBI) Masternode Setup Guide (Ubuntu 16.04)
This guide will assist you in setting up a Bitcoin Incognito Masternode on a Linux Server running Ubuntu 16.04. (Use at your own risk)

If you require further assistance contact the support team [Discord](https://discord.gg/q5Gsuxz)
***
## Requirements
1) **3,000 XBI coins.**
2) **A Vultr VPS running Linux Ubuntu 16.04.**
3) **A Windows local wallet.**
4) **An SSH client such as [Bitvise](https://dl.bitvise.com/BvSshClient-Inst.exe)**
***
## Contents
* **[Section A](https://github.com/sub307/Bitcoin_Incognito/blob/master/README.md#section-a-creating-the-vps-within-vultr)**: Creating the VPS within [Vultr](https://www.vultr.com/?ref=7781034-4F).
* **[Section B](https://github.com/sub307/Bitcoin_Incognito#section-b-downloading-and-installing-bitvise)**: Downloading and installing Bitvise.
* **[Section C](https://github.com/sub307/Bitcoin_Incognito#section-c-connecting-to-the-vps--installing-the-mn-script-via-bitvise)**: Connecting to the VPS and installing the MN script via Bitvise.
* **[Section D](https://github.com/sub307/Bitcoin_Incognito#section-d-preparing-the-local-wallet)**: Preparing the local wallet.
* **[Section E](https://github.com/sub307/Bitcoin_Incognito#section-e-connecting--starting-the-masternode)**: Connecting & Starting the masternode.
* **[FAQ](https://github.com/sub307/Bitcoin_Incognito#faq)**: Frequently asked questions
***

Follow the next steps or follow the [video tutorial](https://youtu.be/UGGWZ4k9jIk).


## Section A: Creating the VPS within [Vultr](https://www.vultr.com/?ref=7781034-4F) 
***Step 1***
* Register at [Vultr](https://www.vultr.com/?ref=7781034-4F)
***

***Step 2***
* After you have added funds to your account go [here](https://my.vultr.com/deploy/) to create your Server
***

***Step 3*** 
* Choose a server location (preferably somewhere close to you)
![Example-Location](https://i.imgur.com/ozi7Bkr.png)
***

***Step 4***
* Choose a server type: Ubuntu 16.04
![Example-OS](https://i.imgur.com/8gh2GDX.png)
***

***Step 5***
* Choose a server size: $5/mo will be fine 
![Example-OS](https://i.imgur.com/UoGoHcM.png)
***

***Step 6*** 
* Set a Server Hostname & Label (name it whatever you want)
![Example-hostname](https://i.imgur.com/uu0rvOr.png)
***

***Step 7***
* Click "Deploy now"

![Example-Deploy](https://i.imgur.com/4qpYuH0.png)
***


## Section B: Downloading and installing BitVise. 

***Step 1***
* Download Bitvise [here](https://dl.bitvise.com/BvSshClient-Inst.exe)
***

***Step 2***
* Select the correct installer depending upon your operating system. Then follow the install instructions. 

![Example-PuttyInstaller](https://i.imgur.com/yF3694G.png)
***


## Section C: Connecting to the VPS & Installing the MN script via Bitvise.

***Step 1***
* Copy your VPS IP (you can find this by going to the server tab within Vultr and clicking on your server. 
![Example-Vultr](https://i.imgur.com/o9WsmCh.png)
***

***Step 2***
* Open the bitvise application and fill in the "Host" box with the IP of your VPS, the "Port" box with _22_ and the "Username" box with _root_ then click "Log in"

![Example-PuttyInstaller](https://i.imgur.com/2eTjcRS.png)
***

***Step 3*** 
* Once you have clicked log in it will open a security alert (click "Accept and Save").  
***


***Step 4***
* Copy the root password from the VULTR server page.
![Example-RootPass](https://i.imgur.com/JnXQXav.png)

***


***Step 5*** 
* Paste the password into the "Password" box and press "OK"
***

***Step 6***
* Paste the code below into the Bitvise terminal then press enter (it will show you the download and go the a new line)

`wget -N https://raw.githubusercontent.com/sub307/Bitcoin_Incognito/master/xbi_install.sh`
***

***Step 7***
* Paste the code below into the Bitvise terminal then press enter

`bash xbi_install.sh`
***

***Step 8***
* Sit back and wait for the install (this will take 10-20 mins)
***

***Step 9***
* When prompted to enter your Gen key - press enter (or paste your local generated key and press enter)

![Example-installing](https://i.imgur.com/EpQHK3y.png)
***

***Step 10***
* You will now see all of the relavant information for your server.
* Keep this terminal open as we will need the info for the wallet setup.
![Example-installing](https://i.imgur.com/XzZs6Ym.png)
***

## Section D: Preparing the Local wallet

***Step 1***
* Download and install the XBI wallet [here](https://github.com/XBIncognito/xbi-4.3.2.1/releases)
***

***Step 2***
* Send EXACTLY 3,000 XBI to a receive address within your wallet. (You can do this from your wallet to a new address in your wallet or from the exchange)
***

***Step 3***
* Create a text document to temporarily store information that you will need. 
***

***step 4***
* Go to the debug console within the wallet 

![Example-console](https://i.imgur.com/A7greWe.png)
***

***Step 5***
* Type the command below and press enter 

`masternode outputs` 

![Example-outputs](https://i.imgur.com/50dn7k5.png)
***

***Step 6***
* Copy the long key (this is your transaction ID) and the 1 or 2 at the end (this is your output index)
* Paste these into the text document you created earlier as you will need them in the next step.
***

# Section E: Connecting & Starting the masternode 

***Step 1***
* Go to the tools tab within the wallet and click open "masternode configuration file" 
![Example-create](https://i.imgur.com/A7greWe.png)
***

***Step 2***

* Fill in the form. 
* For `Alias` type something like "MN01" **don't use spaces**
* The `Address` is the IP and port (7339) of your server (this will be in the Bitvise terminal that you still have open).
* The `Genkey` is your masternode Gen key (This is also in the Bitvise terminal that you have open).
* The `TxHash` is the transaction ID/long key that you copied to the text file.
* The `Output Index` is the 0 or 1 that you copied to your text file.
![Example-create](https://i.imgur.com/By8wC9T.png)

Click "File Save"
***

***Step 3***
* Close out of the wallet and reopen Wallet
* Open debug console and enter `startmasternode all false` if you don't have any other masternodes running, otherwise use `startmasternode alias false 'Alias'`
* 'Alias' should be replaced with the alias you gave your new masternode, like MN01 in our example


***

***step 4***
* Check the status of your masternode within the VPS by using the command below:

`xbi-cli getmasternodestatus`

`xbi-cli getinfo`

*You should see ***status 4***

If you do, congratulations! You have now setup a masternode. If you do not, please contact support and they will assist you.  
***
## FAQ

I'm getting the error with code -28 and the message "Loading block index..." or "Calculating missing accumulators...", what do I do?
It is normal to get these errors when you just installed your masternode. The wallet needs some time to synchronize with the downloaded blockchain.
Wait a few minutes and check the status again with `xbi-cli getinfo`.

If you don't see ***status 4***

Check if your wallet is syncing with `xbi-cli getinfo`. 
If your wallet is stuck, use the commands `wget https://raw.githubusercontent.com/nashscly/XBI/master/xbi_stuck_fix.sh`, and `bash xbi_stuck_fix.sh` to use a bootstrap.
Wait a few minutes and check the status again with `xbi-cli getinfo`
If your wallet is on the correct block, use `xbi-cli stop` and `systemctl start XBI.service` to restart the service.
Wait until `xbi-cli mnsync status` returns true on everything but the "isFailed"
Retry starting the masternode from you local wallet.

