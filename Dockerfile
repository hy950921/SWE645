# A Dockerfile is a text document that contains all the commands a user could call on the command line to assemble an image. 
# Using docker build users can create an automated build that executes several command-line instructions in succession. 
FROM tomcat:8.0
LABEL maintainer="yhan27@gmu.edu"
ADD swe645hw2.war /usr/local/tomcat/webapps/
EXPOSE 8080/tcp
