# wysiblocks-production

## Backup dev data / assets if you wish to transfer them to production

Make sure full dev container stack is up and running. To make sure it does and double check by running

```
$ doccker ps
```

### DB

Attach to mongodb container, dump the entire datapase into a folder inside the container and copy it to the host

```
$ docker exec -it wysiblocks_mongodb bash

# mongodump --out /mongo_dump --username user_stories --password user_stories_root

$ docker cp wysiblocks_mongodb:/mongo_dump .

```

### DB strapi public data

Copy public assets strapi folder to the host

```
$ docker cp wysiblocks_strapi_cms:/app/public .\strapi
```

### Keycloak

Export Keycloak Realm

```
$ docker exec -it wysiblocks_keycloak /opt/jboss/keycloak/bin/standalone.sh -Djboss.socket.binding.port-offset=100 -Dkeycloak.migration.action=export -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.realmName=wysiblocks -Dkeycloak.migration.usersExportStrategy=REALM_FILE -Dkeycloak.migration.file=/tmp/wysiblocks_realm.json

$ Ctrl+C

$ docker cp wysiblocks_keycloak:/tmp/wysiblocks_realm.json ./keycloak_exports/wysiblocks_realm.json
```

## Run production stack and import backed-up data and assets into production

Make sure the dev stack is stopped, if your are in your local environment (doesn't apply to remote server). To ensure run

```
$ docker-compose -f docker-compose.dev.yml down
```

### Mongo DB

Start db-only production stack, copy mongodb dump into the production container, attach to it and run mongorestore and stop the stack

```
$ docker-compose -f docker-compose.db-only.yml up -d

$ docker cp mongo_dump wysiblocks_mongodb:/

$ docker exec -it wysiblocks_mongodb bash

# mongorestore mongo_dump/ --username user_stories --password user_stories_root

$ docker-compose -f docker-compose.db-only.yml down
```

### Run production stack

```
$ docker-compose -f docker-compose.full-stack.yml up -d
```

### Import Strapi public folder

```

$ docker cp .\strapi\public wysiblocks_strapi_cms:/app/
```

## SSH

1. Generate private and public key pair

   ```
   $ ssh-keygen -t rsa
   ```

2. Add private key to ssh-agent

   **Update 2019 - A better solution if you're using Windows 10:** OpenSSH is available as part of Windows 10 which makes using SSH from cmd/powershell much easier in my opinion. It also doesn't rely on having git installed, unlike my previous solution.

   Open Manage optional features from the start menu and make sure you have Open SSH Client in the list. If not, you should be able to add it.

   Open Services from the start Menu

   Scroll down to OpenSSH Authentication Agent > right click > properties

   Change the Startup type from Disabled to any of the other 3 options. I have mine set to Automatic (Delayed Start)

   Open cmd and type where ssh to confirm that the top listed path is in System32. Mine is installed at C:\Windows\System32\OpenSSH\ssh.exe. If it's not in the list you may need to close and reopen cmd.

   Once you've followed these steps, ssh-agent, ssh-add and all other ssh commands should now work from cmd. To start the agent you can simply type ssh-agent.

   Optional step/troubleshooting: If you use git, you should set the GIT_SSH environment variable to the output of where ssh which you ran before (e.g C:\Windows\System32\OpenSSH\ssh.exe). This is to stop inconsistencies between the version of ssh you're using (and your keys are added/generated with) and the version that git uses internally. This should prevent issues that are similar to this

   Add Digital Ocean key to SHH agent

   ```
   $ ssh-add C:\Unsynced\software_dev/.ssh/id_rsa_do

   ```

   Some nice things about this solution:

   - You won't need to start the ssh-agent every time you restart your computer
   - Identities that you've added (using ssh-add) will get automatically added after restarts. (It works for me, but you might possibly need a config file in your c:\Users\User\.ssh folder)
   - You don't need git!
   - You can register any rsa private key to the agent. The other solution will only pick up a key named id_rsa

3. Copy public key to Digital Ocean
   ```
   $ cat C:\Unsynced\software_dev/.ssh/id_rsa_do.pub
   ```

## Prep the Ubuntu server on DO

1. SSH into the server
   ```
   $ shh root@178.62.16.248
   ```
2. Update / Upgrade all the packages
   ```
   $ sudo apt update
   $ sudo apt upgrade
   ```
3. Create a new user with root prveliges

   ```
   $ adduser user_stories

   $ usermod -aG sudo user_stories

   $ cd /home/user_stories/

   $ mkdir .ssh

   $ cd .ssh

   $ touch authorized_keys

   $ sudo nano authorized_keys
   // paste the public part of ssh key you created for DO

   $ sudo nano /etc/ssh/sshd_config

   // change value
   PermitRootLogin no

   $ sudo systemctl reload sshd

   // change owner of .ssh folder

   $ sudo chown -R user_stories:user_stories /home/user_storie s
   ```

4. Add your user to docker user group
   ```
   $ sudo usermod -aG docker ${USER}
   ```
