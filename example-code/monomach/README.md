![Alt text](monomach-diagram.png?raw=true "Title")

TODO

1. OpenResty+Redis backend for statistics.
2. K8s Helm template.
3. Prometheus health checks & grafana dashboard.
4. Service mesh suppport.
5. Service discovery support.
6. Jaeger | Zipkin support.
7. Stress tests based on the following scenarios:
   1. requests storm
   2. very high CPU load on 1 microservice node
   3. microservice node down for 15 sec || https://github.com/linki/chaoskube
   4. node upgrade
   5. incorrect node upgrade & rollback
   6. network link down between nodes
