FROM tomcat:8-jre8

# Agent JMX Exporter : expose les metriques JVM/Tomcat pour Prometheus sur :9404
ADD https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.20.0/jmx_prometheus_javaagent-0.20.0.jar /opt/jmx/jmx_prometheus_javaagent.jar
COPY jmx-config.yaml /opt/jmx/config.yaml
ENV CATALINA_OPTS="-javaagent:/opt/jmx/jmx_prometheus_javaagent.jar=9404:/opt/jmx/config.yaml"

COPY ./webapp.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080 9404
