# paper-docker

A custom docker image for the paper build of minecraft

## Features
- Easily switchable multiple world support
- Simple and customizable automatic compressed backups for running world mounted directly in a separate volume
- Optional automatic updates for Paper
- Instant setup for fast deployment and testing
- Graceful container shutdown to allow the server to save and close
- Run with a sandboxed unprivileged user
- External script to run commands in the server console
- Optional RCON support

## Setup
1. Build the image or use (coming soon) from dockerhub
2. Run the command `docker run -p 25565:25565 -v /path/to/main:/paper -v /path/to/backups:/backups paper-docker`
    - `/paper` is the base directory for all of the minecraft files inside the container
    - `/backups` is the base directory for all backups inside the container
    - `25565` is the port that the container is listening on, but you can specify `<port>:25565` to use a different host facing port
    - Use the `-p` argument with port `25575` for RCON
    - In order for the unprivileged user to be able to run minecraft, you will need to `chown -R :1000 /host/paper`, `chmod -R 764 /host/paper/` (group read/write perms in the directory), and `sudo find /host/paper/ -type d -exec chmod +x {} +` (group exec perms for directories only) on the host so that the user's filegroup (gid 1000) can modify these files. If you are running this image via Kubernetes, you should be able to run the pod as group id 1000 and it will handle this process for you.
4. In order to make sure the server saves when the container is closed, make sure to specify the `--time` parameter when running `docker stop` to give the server enough time to save and shut down (30 seconds is a good failsafe) before the container is forcefully killed
5. Run `docker exec -it <mycontainer> /bin/bash` to open a terminal inside the container
6. From there, you can modify files if necessary and also use the `/scripts/issue-command.sh` script to run commands in the minecraft console (syntax: `/scripts/issue-command.sh "<command>"`)
7. You can also run this command `docker exec <mycontainer> /bin/bash /scripts/issue-command.sh "say hi"` to run commands in the server console
 
## Kubernetes setup
- (Docs coming soon)

## Configuration
- Besides the default minecraft configuration which you can find online, paper-docker provides some additional configuration. Create a file in minecraft's root directory named `paper-docker.conf` and only specify the settings you want to change:
    - `world_name`: The name of the world to run the server with. It will look for the directory with the corresponding name in the `/paper/Worlds` folder and create a new world if it does not exist. Backups will also run for the world with this name
    - `max_backups`: The maximum amount of backups that can exist at one time per world. The oldest of the backups will be deleted to meet this threshold. There will be one more backup in the folder 
    - `backup_time_min`: The time in minutes between each backup. Set this value to zero to disable the backup task completely
    - `backup_logging`: Enable status logging for backups to stdout which can be read using `docker logs <mycontainer>`
    - `minecraft_version`: When installing the Paper server, use a specific version of minecraft (i.e. `1.17.1`). This can also be set to `latest` to use the most recent version
    - `paper_build`: When installing the Paper server, use a specific build of Paper (i.e. `54`). This can also be set to `latest` to use the most recent version
    - `java_opts`: The options to pass to java when running the server
- You will need to restart the container for these changes to take effect
- Make sure the config file has UNIX line endings, otherwise the config will not be parsed correctly

## Defaults
This is an example of a `paper-docker.conf` filled with the default values
```
world_name=world
max_backups=5
backup_time_min=30
backup_logging=true
minecraft_version=latest
paper_build=latest
java_opts=-Xms4G -Xmx4G
```
