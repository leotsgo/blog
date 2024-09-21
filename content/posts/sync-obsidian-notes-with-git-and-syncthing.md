+++
authors = "Leonardo Bermejo"
categories = ["Tech"]
tags = ["zettelkasten", "homelab"]
date = "2024-09-21"
title = "Sync Obsidian Notes With Git And Syncthing"
+++

Taking notes and building my Zettelkasten is becoming an increasingly crucial part of my life. I'm able to reflect on how I'm feeling and what I'm learning, making connections I wouldn't otherwise.

One important aspect of notetaking is being able to take notes on multiple devices wherever I am. In this article, I'll explain how I set up the integration between my devices using Git and Syncthing.

# The Problem

As of 2024 the Obsidian Git Plugin support git integration on Android, but [only via https](https://www.reddit.com/r/ObsidianMD/comments/17odzjb/obsidian_android_syncing_via_github_in_2023/). As I'm using a private Github repository to store my notes, I did not feel comfortable storing a access key on my smartphone. So how could I sync my notes then ?

# The Solution

I had a small RaspberryPi clone at home, an OrangePi Zero 3. What if I could have a directory in my phone in sync with a directory on my OrangePi ? Then I would just have to automate the commit and push process and all my notes would ever be in sync!

# How To

To set this up, I'll assume you already have git configured on your machine and [Syncthing](https://syncthing.net/) installed. After installation, we have to make sure Syncthing is going to run as a [system service](https://docs.syncthing.net/users/autostart.html#how-to-set-up-a-system-service), not a user service under systemd:
```bash
systemctl enable syncthing@myuser.service
systemctl start syncthing@myuser.service
```

Where **myuser** is the name of a user on your machine. After this you just have to use Syncthing's GUI to enable the synchronization. I won't go into the details of this step because there are [millions of tutorials](https://medium.com/linuxforeveryone/how-to-sync-all-your-stuff-with-syncthing-linux-android-guide-536fe61d68df) out there teaching how to use the WebGUI to set the sync up.

With the sync up and running, we need a script that will be used by our systemd service. This little script pulls from github and commits and push any modifications I made on the repository using my phone:
```bash
#!/bin/bash

cd /home/youruser/sb
git pull
git add --all
git commit -m "manual backup: $(date '+%Y-%m-%d %H:%M:%S')"
git push
```

I placed this script in my user's home under the name **sync.sh**. Give it permission to be executed by running the following command:
`chmod +x sync.sh`

Now we just have to set the systemd service and the systemd timer. In my case, I run this script every minute, but you may want to use a different frequency.

Go to `/etc/systemd/system` and create two files - `syncsb.service` and `syncsb.timer`. The names don't matter as long as you are consistent with the names in the files. The service will be responsible for running the script, and it will be triggered by the timer:

syncsb.service:
```bash
[Unit]
Description=Sync my notes

[Service]
Type=simple
User=myuser
Environment=HOME=/home/myuser
WorkingDirectory=/home/myuser/notes-repository
ExecStart=/home/myuser/sync.sh
Restart=on-failure

[Install]
WantedBy=default.target
```

It's important to set the user correctly or the script might not have the privileges to run git commands.

syncsb.timer:
```bash
[Unit]
Description=Sync notes every minute

[Timer]
OnUnitActiveSec=1min
Unit=syncsb.service

[Install]
WantedBy=timers.target
```

The **Unit** here must have the same name of your service.

With the files in place you just have to run the following commands:

```bash
# Reload the daemon so the new files are read
sudo systemctl daemon-reload

# enable and start the services:
sudo systemctl enable syncsb.timer
sudo systemctl enable syncsb.service
sudo systemctl start syncsb.timer
```

And done! Now every modification you make on the notes on a device will be synced with your phone and vice-versa. Just be careful to not edit a file in multiple devices before the sync runs.