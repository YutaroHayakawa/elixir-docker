FROM ubuntu:16.04

# Install required packages
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y git python python3 python3-dev ctags perl wget build-essential vim
RUN apt-get -y install apache2=2.4.18-2ubuntu3 apache2-bin=2.4.18-2ubuntu3 apache2-data=2.4.18-2ubuntu3
RUN apt-get -y install python3-pip
RUN python3 -m pip install jinja2 pygments

RUN mkdir build
WORKDIR build

# Install berkeley-db
RUN wget http://download.oracle.com/berkeley-db/db-4.8.30.tar.gz
RUN tar zxvf db-4.8.30.tar.gz
WORKDIR db-4.8.30/build_unix
RUN ../dist/configure --prefix=/usr/local && make && make install
RUN echo "/usr/local/lib/" >> /etc/ld.so.conf
RUN ldconfig

# Install bsddb
WORKDIR /build
RUN wget https://pypi.python.org/packages/source/b/bsddb3/bsddb3-5.3.0.tar.gz#md5=d5aa4f293c4ea755e84383537f74be82
RUN tar zxvf bsddb3-5.3.0.tar.gz
WORKDIR bsddb3-5.3.0
RUN python3 setup.py --berkeley-db=/db-4.8.30 install

WORKDIR /usr/local

# Install elixir
RUN git clone https://github.com/free-electrons/elixir.git
WORKDIR /usr/local/elixir

# Add script for adding new projects
ADD ./add_project /usr/local/elixir/add_project

# Setup Apache2
RUN a2enmod rewrite
RUN a2enmod cgi
ADD ./000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN chown -R www-data:www-data /usr/local/elixir

ENTRYPOINT service apache2 start; tail -f /var/log/apache2/error.log
