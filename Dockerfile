FROM phusion/baseimage:latest

RUN DEBIAN_FRONTEND=noninteractive
RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

#add repo with newest PHP versions
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php

#add nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs 
RUN apt-get install -y build-essential

#add yarn repo
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv D101F7899D41F3C3 
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list 
# 
RUN apt-get update 

# Install PHP 7.1, some PHP extentions and some useful Tools with APT
RUN apt-get install -y \
        acl \
        mysql-client \
        nginx \
        php7.1-bcmath \
        php7.1-cli \
        php7.1-common \
        php7.1-curl \
        php7.1-fpm \
        php7.1-gd \
        php7.1-intl \
        php7.1-json \
        php7.1-mbstring \
        php7.1-mcrypt \
        php7.1-mysql \
        php7.1-xml \
        php7.1-zip \
        php7.1-soap \
        php-imagick \
        php-memcached \
        php-mongodb \
        php-redis \
        php-zip

# Install additional tools
RUN apt-get install -y \
        ant \
        git \
        curl \
        python-pip \
        zip \
        joe
        
RUN apt-get install -y \
        wget unzip libmcrypt-dev libpng-dev libjpeg-dev \
        ghostscript zbar-tools dmtx-utils poppler-utils \
        tesseract-ocr qpdf build-essential gcj-4.9-jdk g++-4.9  gcj-jdk


RUN mkdir -p /install && cd /install && wget http://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk-2.02-src.zip && \
    unzip pdftk-2.02-src.zip && \
    sed -i 's/VERSUFF=-4.6/VERSUFF=-4.9/g' pdftk-2.02-dist/pdftk/Makefile.Debian && \
    cd pdftk-2.02-dist/pdftk && \
    make -f Makefile.Debian && \
    sudo make -f Makefile.Debian install


RUN pip install awscli        

#Set up PHP7-FPM folder
RUN mkdir /run/php
RUN chmod 777 /run/php/

#Install yarn 
RUN apt-get install -y yarn 

# Add a symbolic link for Node
#RUN ln -s /usr/bin/nodejs /usr/bin/node

# Add convenience aliaseses
RUN echo "alias phpunit='./bin/phpunit'" >> ~/.bashrc
RUN echo "alias phpspec='./bin/phpspec'" >> ~/.bashrc
RUN echo "alias behat='./bin/behat'" >> ~/.bashrc
RUN echo 'alias sf="bin/console"' >> ~/.bashrc
RUN echo 'alias cc="bin/console cache:clear"' >> ~/.bashrc

# Install Composer
RUN curl -s http://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer 

# Source the bash
RUN . ~/.bashrc

#Delete enabled Nginx sites
RUN rm -rf /etc/nginx/sites-enabled/*

#Delete everything from /var/www/ folder
RUN rm -rf /var/www/*

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /install 

WORKDIR /var/www
