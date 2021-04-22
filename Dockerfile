FROM mcr.microsoft.com/dotnet/sdk:5.0-focal
RUN apt update
RUN apt install -yy tmux software-properties-common \
                    xclip jq curl sqlite make silversearcher-ag
RUN add-apt-repository -yy ppa:neovim-ppa/stable
RUN apt install -yy neovim

# create dev users
RUN useradd -ms /bin/bash dev

USER dev
ENV HOME /home/dev
ENV TERM=screen-256color
ENV LANG="C.UTF-8"
ENV LC_COLLATE="C.UTF-8"
ENV LC_CTYPE="C.UTF-8"
ENV LC_MONETARY="C.UTF-8"
ENV LC_NUMERIC="C.UTF-8"
ENV LC_TIME="C.UTF-8"

RUN mkdir -p /home/dev/.config/nvim/
RUN mkdir -p /home/dev/.nuget/
COPY config/tmux.conf /home/dev/.tmux.conf
COPY config/bash_aliases /home/dev/.bash_aliases
COPY config/init.vim /home/dev/.config/nvim/

RUN nvim +PlugInstall +qall
RUN nvim +OmniSharpInstall +qall

RUN dotnet tool install -g dotnet-aspnet-codegenerator
