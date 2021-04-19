.NET Core - Neovim environment in docker
========================================

A terminal based dotnet core development environment with neovim and tmux.

Configs been customize to follow my needs, feel free to clone and modify, this still is in a w.i.p for me :)

## Build

Default build as docker image `dotnet-dev`

```sh
make
```

or

```sh
docker build -t <your-prefered-tag> .
```

## Use

Included all bells and whistles, remove what you don't need

```sh
docker volume create dotnet-dev-nugets

docker run -ti --rm \
  -v /etc/localtime:/etc/localtime:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $SSH_AUTH_SOCK:/tmp/.ssh-agent \
  -e SSH_AUTH_SOCK=/tmp/.ssh-agent \
  -e DISPLAY=unix$DISPLAY \
  -v ~/.ssh/:/home/dev/.ssh \
  -v ~/.gitconfig:/home/dev/.gitconfig \
  -v dotnet-dev-nuget:/home/dev/.nuget \
  -v $PWD:/code \
  -w /code \
  --hostname dotnet \
  dotnet-dev \
  tmux
```
