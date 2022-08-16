#!/bin/bash
### matmar shell install and config
read -p '[?] Run init script (zsh config and plugins, aliases and scripts) (Y/n) ' -n 1 -r; echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit
fi

apt update -y && apt upgrade -y
# install packages i use
apt install zsh git curl vim bat -y

# installing ohmyzsh	
chsh -s $(which zsh)
sh -c "$(curl -fsSL 	https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

## config zsh
all_themes=$(ls ~/.oh-my-zsh/themes | cut -d"." -f1)
new_random_theme=$(echo $all_themes | xargs shuf -n1 -e)
zsh_default_theme=$(/bin/cat ~/.zshrc | grep -oE "^ZSH_THEME=.*$" | cut -d'"' -f2) 
sed -i "s/$zsh_default_theme/$new_random_theme/g" ~/.zshrc

## add aliases
echo "alias zshrc='vim ~/.zshrc; source ~/.zshrc'" >> ~/.zshrc
echo "alias hosts='sudo vim /etc/hosts'" >> ~/.zshrc
echo "alias grep='grep --color=auto'" >> ~/.zshrc
echo "alias grep-ip='grep -oE '\''(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'\'" >> ~/.zshrc
echo "alias config=\"grep -v '#' | grep -v '^$'\"" >> ~/.zshrc
echo "alias cat='batcat --color=always --paging=never -p'" >> ~/.zshrc

## scripts
echo -e '#!/bin/bash\ncurl -s cheat.sh/$1' > /usr/local/sbin/cheat && chmod +x /usr/local/sbin/cheat
echo -e '#!/bin/bash\nwhile [ : ]; do $@; sleep 1; clear;sleep 0.02; done' > /usr/local/sbin/loop && chmod +x /usr/local/sbin/loop

## plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
zsh_plugins=$(cat ~/.zshrc | grep -oE "^plugins=.*$" | cut -d'(' -f2) 
sed -i "s/$zsh_plugins/zsh-autosuggestions zsh-syntax-highlighting)/g" ~/.zshrc

# config vim
echo "set number relativenumber" > ~/.vimrc
echo "syntax on" >> ~/.vimrc

# motd
rm /etc/update-motd.d/*
echo "welcome back" > /etc/motd
echo -e '#!/bin/bash\nlast -f /var/log/wtmp | head -n2' > /etc/update-motd.d/11-lastlogin && chmod +x /etc/update-motd.d/11-lastlogin 
# source configs
zsh && source ~/.zshrc
