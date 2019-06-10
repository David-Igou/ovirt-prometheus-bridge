# ovirt-vm-prometheus-bridge

This is a fork and modification of `rmohr/ovirt-prometheus-bridge` - to
support VM service discovery over the ovirt hosts themselves. 

`ovirt-vm-prometheus-bridge` is a host autodiscovery service for Prometheus
targets. It can be used to query oVirt Engine for hosts. The result is stored
in a json file which Prometheus can use to find scrape targets. Prometheus will
then start collecting metrics from port you declare. In the example context Prometheus
scrapes attempts to scrape `node-exporter` listening on 9000..


In this example
```bash
docker run -e ENGINE_PASSWORD=engine -v $PWD:/targets igou/ovirt-vm-prometheus-bridge -update-interval 60 -no-verify -engine-url=https://my.rhev.engine:8443 -output /targets/targets.json
```
the service is querying the oVirt Engine API every 60 seconds and writes the
found hosts into the file `targets.json`.  The created file `targets.json`
looks like this:

```json
[
  {
    "targets": [
      "myorg.vmhost1.com:9000",
      "myorg.vmhost2.com:9000"
    ],
    "labels": {
      "cluster": "0294d770-70c0-4b99-a527-f8a4ff4de436"
    }
  }
]
```

Prometheus can monitor files like this and update its configuration whenever
this file changes.  Here is a sample configuration for prometheus:

```yaml
global:
  scrape_interval: 15s

  external_labels:
    monitor: 'ovirt'

scrape_configs:
  - job_name: 'prometheus'

    scrape_interval: 10s

    target_groups:
      - targets: ['localhost:9090']
        labels:
          group: 'prometheus'

  - job_name: 'ovirt-vm-node-exporter'

    scrape_interval: 5s
    file_sd_configs:
      - names : ['/targets/*.json']
```

# Quick start

To quickly spawn ovirt-vm-prometheus-bridge, Prometheus and Grafana you can use
the Docker compose file in this repository:

```bash
export ENGINE_HOST=https://$ENGINE_FQDN
export ENGINE_PASSWORD=$OVIRT_ENGINE_PASSWORD
docker-compose up
```

Then add the Prometheus datasource to Grafana:

```bash
curl -X POST -H "Accept: application/json" -H "Content-Type: application/json" --data '{ "name":"oVirt", "type":"prometheus", "url":"http://prometheus:9090", "access":"proxy", "basicAuth":false }' http://admin:admin@localhost:3000/api/datasources
```

Prometheus will then listen on [localhost:9090](http://localhost:9090), Grafana
on [localhost:3000](http://localhost:3000) and ovirt-vm-prometheus-bridge will
provide the scrape targets. The default credentials for Grafana are
`admin:admin`.
