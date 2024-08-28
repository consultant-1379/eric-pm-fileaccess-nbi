echo "
Listen 8082
ExtendedStatus On
<Location /server-status>
    SetHandler server-status
    Require local
</Location>
" >> /etc/httpd/conf.d/metrics.conf

echo "com.sun.identity.agents.config.notenforced.url[26] = http://localhost:8082/server-status\?auto" >> /opt/ericsson/sso/web_agents/apache24_agent/Agent_001/config/agent.conf

nohup ./metrics/apache_exporter --insecure --scrape_uri=http://localhost:8082/server-status?auto  --web.listen-address=:9600 --telemetry.endpoint=/metrics &
