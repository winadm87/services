#!/bin/bash
###################################
# Docker how-to
# Author Ivanov Artyom
# Date 10.2022
# Version 1.0
###################################
# create python basic script
printf "print('Hello world from python script')" >pythonfile.py
# create basic Dockerfile for python script
printf 'FROM python\nWORKDIR /app\nCOPY . .\nCMD ["python", "pythonfile.py"]' >Dockerfile
# run docker build
docker build .
# list docker images
docker images
# run container
docker run ****
# remove container
docker rm contanter_name
# remove image, it will fail if containrs on this image still exitsts
docker rmi image_name
# remove all stopped containers
docker container prune


# create Docker file
##############################
#FROM node      #from which image to run docker
#
#WORKDIR /app   #cd to working dirctory
#
#COPY package.json /app  #copy frm localhost to docker image
#
#RUN npm install #install an application
#
#COPY . /app  #copy all contens of folder with Dockerfile to image
#
#EXPOSE 3000   #what port to forward to localhost
#
#CMD [ "node" , "app.js" ]  #run an application
###############################
# lets build this image
docker build .
#lets run a container from generated image
docker run -d               -p 3000:3000       --name app1           --rm                     *******
#         ^at background    ^forward port     ^name of container     ^remove when stopped     ^container id


# create imge with name
docker build -t          image1:ver1 .
              ^set name         ^set tag

			  
# login to dockerhub
docker login -u winadm87
# rename an image to push it to dockerhub
docker tag image1 winadm87/image1
# push it
docker push winadm87/image1:latest


# create ignore file to not put them in image
nano .dockerignore
####
node_module
.git
Dockerfile
####


# get docker image full info
docker image inspect image2


# use variables in Dockerfile
###################

FROM node

WORKDIR /app

COPY package.json /app

RUN npm install

COPY . /app

ENV PORT 4200  #anounce and set variable

EXPOSE $PORT   #call variable

CMD [ "node" , "app.js" ]
######################


# set variable in docker run
docker run -d -p 4100:4100 -e PORT=4100 --rm image3
                            ^set variable PORT
# create env file
mkdir config
nano config/.env
#####
PORT=4300
#####
docker run -d -p 4300:4300 --rm --env-file ./config/env image3


# lets use Makefile
nano Makefile
#################
run:
        docker run -d -p 4300:4300 --env-file ./config/.env --rm --name app1 image3

stop:
        docker stop app1
#################
make run
----
make stop


# lets play with volumes
# Dockerfile
######################
FROM node

WORKDIR /app

COPY package.json /app

RUN npm install

COPY . /app

ENV PORT 3000

EXPOSE $PORT

VOLUME [ "/app/data" ] #here we go

CMD [ "node" , "app.js" ]
######################
# aaaand docker run command looks like
docker run -d -p 3000:3000 -v         logs:/app/data --rm --name app1 image5
                           ^volume    ^name ^path
# we can list volumes
docker volume ls
# and inspect or rm them. inspect show mount point in host system
docker volume inspect logs
docker volume rm logs
# also we can create volume by command
docker volume create logs
# and then use it as we wish
