FROM tomcat:8.0
LABEL maintainer="yhan27@gmu.edu"
ADD swe645hw2.war /usr/local/tomcat/webapps/
EXPOSE 8080/tcp
