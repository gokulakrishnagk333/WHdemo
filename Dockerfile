FROM maven:3-jdk-8-alpine

WORKDIR /usr/src/app

COPY . /usr/src/app
RUN mvn package

ENV PORT 8080
EXPOSE $PORT
CMD [ "sh", "-c", "mvn -Dserver.port=${PORT} spring-boot:run" ]



#From tomcat:8.0.51-jre8-alpine
#RUN rm -rf /usr/local/tomcat/webapps/*
#COPY ./target/usermgmt-webapp.war /usr/local/tomcat/webapps/ROOT.war
#CMD ["catalina.sh","run"]
