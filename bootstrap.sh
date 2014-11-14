#!/usr/bin/env bash
#
# bootstrap script, assumed to be run as root
#
# to used it as vagrant provision shell script, invoke with parameter 'vagrant'
#

source /etc/os-release

if [[ "$NAME" = "Ubuntu" && "$VERSION_ID" = "14.04" ]]; then
  # update package list
  sed -i 's/archive\.ubuntu\.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list
  sed -i 's/security\.ubuntu\.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list
  apt-get update

  apt-get -y install python-software-properties

  # setup proper locale
  locale-gen zh_TW.UTF-8
  update-locale LC_ALL=zh_TW.UTF-8 LANG=zh_TW.UTF-8
  export LANG=zh_TW.UTF-8

  # install required packages
  apt-get -y install build-essential git-core wget curl \
    rake zsh
  apt-get -y install nginx postgresql-9.3 postgresql-contrib-9.3 redis-server
  apt-get -y install bison openssl libssl-dev libxslt1.1 libxslt1-dev \
    libxml2 libxml2-dev libffi-dev libyaml-dev autoconf \
    libc6-dev libreadline6-dev zlib1g zlib1g-dev \
    ruby-dev libruby2.0 libsqlite3-dev libpq-dev

elif [[ "$NAME" = "Ubuntu" && "$VERSION_ID" = "12.04" ]]; then
  # update package list
  sed -i 's/archive\.ubuntu\.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list
  sed -i 's/security\.ubuntu\.com/tw.archive.ubuntu.com/g' /etc/apt/sources.list
  apt-get update

  apt-get -y install python-software-properties

  # setup proper locale
  locale-gen zh_TW.UTF-8
  update-locale LC_ALL=zh_TW.UTF-8 LANG=zh_TW.UTF-8
  export LANG=zh_TW.UTF-8

  # get latest repository
  add-apt-repository -y ppa:git-core/ppa
  add-apt-repository -y ppa:fcwu-tw/ppa
  # add-apt-repository -y ppa:kalakris/tmux

  # get latest postgres repository
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
  echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/postgresql.list

  apt-get update

  # install required packages
  apt-get -y install build-essential git-core wget curl \
    rake zsh
  apt-get -y install nginx postgresql-9.3 postgresql-contrib-9.3 redis-server
  apt-get -y install bison openssl libssl-dev libxslt1.1 libxslt1-dev \
    libxml2 libxml2-dev libffi-dev libyaml-dev libxslt-dev autoconf \
    libc6-dev libreadline6-dev zlib1g zlib1g-dev \
    ruby-dev libopenssl-ruby libsqlite3-dev libpq-dev

elif [[ "$NAME" = "ArchLinux" ]]; then
  # update package list
  pacman -Sy
  pacman --noconfirm --needed -S base-devel git wget curl \
    ruby zsh
  pacman --noconfirm --needed -S bison openssl libxslt libxml2 libyaml libffi \
    autoconf readline zlib

fi

#
# install chruby
#
# if [ ! -d /usr/local/share/chruby ]; then
#   wget -O /tmp/chruby-0.3.7.tar.gz https://github.com/postmodern/chruby/archive/v0.3.7.tar.gz
#   tar -C /tmp -xvzf /tmp/chruby-0.3.7.tar.gz
#   cd /tmp/chruby-0.3.7
#   make install
# fi
git clone git://github.com/postmodern/chruby.git ~/src/chruby
cd ~/src/chruby
make install

#
# install ruby-install
#
# if [ ! -x /usr/local/bin/ruby-install ]; then
#   wget -O /tmp/ruby-install-0.3.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.3.0.tar.gz
#   tar -C /tmp -xzvf /tmp/ruby-install-0.3.0.tar.gz
#   cd /tmp/ruby-install-0.3.0/
#   make install
# fi
git clone git://github.com/postmodern/ruby-install.git ~/src/ruby-install
cd ~/src/ruby-install
make install


if [[ $1 == "vagrant" ]]; then
  # set local timezone
  echo 'Asia/Taipei' | tee /etc/timezone
  dpkg-reconfigure --frontend noninteractive tzdata

  # install personalize development environment
  su -l -c '[ ! -d ~/.dotfiles ] && git clone git://github.com/szetobo/dotfiles.git ~/.dotfiles; ~/.dotfiles/run.sh install' vagrant
  chsh -s /bin/zsh vagrant

  # install phantomjs, dependency of rails integration test
  cd /tmp
  wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2
  tar xvjf phantomjs-1.9.7-linux-x86_64.tar.bz2
  mv phantomjs-1.9.7-linux-x86_64 /usr/local/share/phantomjs
  ln -s /usr/local/share/phantomjs/bin/phantomjs /usr/local/bin/phantomjs

  # install nodejs
  cd /tmp
  wget http://nodejs.org/dist/v0.10.28/node-v0.10.28-linux-x64.tar.gz
  cd /usr/local && tar --strip-components 1 -xzf /tmp/node-v0.10.28-linux-x64.tar.gz
fi

exit 0

