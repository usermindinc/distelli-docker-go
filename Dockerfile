FROM golang:1.6

# Run as root
USER root

# Create Distelli user
RUN useradd -ms /bin/bash distelli 

# Set /home/distelli as the working directory
WORKDIR /home/distelli

#Add github stuff
RUN mkdir /home/distelli/.ssh
ADD id_rsa /home/distelli/.ssh/id_rsa
ADD id_rsa.pub /home/distelli/.ssh/id_rsa.pub
RUN chown -R distelli:distelli /home/distelli/.ssh
RUN chmod 400 /home/distelli/.ssh/id_rsa
ADD gitconfig /home/distelli/.gitconfig

#Make sudo available
RUN apt-get update && apt-get -y install sudo

# Update the .ssh/known_hosts file:
RUN ssh-keyscan -H github.com bitbucket.org >> /etc/ssh/ssh_known_hosts

# Install Distelli CLI to coordinate the build in the container
RUN curl -sSL https://www.distelli.com/download/client | sh 

# Setup a volume for writing docker layers/images
VOLUME /var/lib/docker

# Install gosu
ENV GOSU_VERSION 1.9
RUN curl -o /bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.9/gosu-$(dpkg --print-architecture)" \
     && chmod +x /bin/gosu

# An informative file I like to put on my shared images
RUN echo 'Distelli Go Build Image created by Brian McGehee bmcgehee@distelli.com' >> /distelli_build_image.info

USER distelli