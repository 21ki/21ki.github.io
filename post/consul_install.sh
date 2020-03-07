---
title: consul安装使用 做prometheus的配置中心
date: 2020-03-07
publishdate: 2020-03-07
date: 2020-03-07T09:00:23+08:00
lastmod: 2020-03-07T09:00:23+08:00
draft: false
tags: ["kubernetes", "linux", "centos"]
keywords: ["kubernetes", "prometheus2", "grafana", "升级"]
categories: ["centos"]
toc: false
---

consul 容器化

<!--more-->
```shell
#单节点 consul容器启动
docker run --name consul -d -p 8500:8500 consul
#修改prometheus配置文件
  - job_name: 'consul'
    consul_sd_configs:
      - server: '192.168.1.221:8500'
#       services: []
    relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*dev.*
        action: keep


#向consul注册服务
curl -X PUT -d '{"id": "192.168.1.191","name": "192.168.1.191","address": "192.168.1.191","port": 9100,"tags": ["dev"],"checks": [{"http": "http://192.168.1.191:9100/","interval": "5s"}]}'     http://192.168.1.221:8500/v1/agent/service/register
curl -X PUT -d '{"id": "192.168.1.192","name": "192.168.1.192","address": "192.168.1.192","port": 9100,"tags": ["dev"],"checks": [{"http": "http://192.168.1.192:9100/","interval": "5s"}]}'     http://192.168.1.221:8500/v1/agent/service/register
#取消注册
curl -X PUT http://localhost:8500/v1/agent/service/deregister/192.168.1.192
#删除无效节点
curl -X PUT http://127.0.0.1:8500/v1/agent/force-leave/{节点id}

#单机部署
consul agent -data-dir=/consul/data -config-dir=/consul/config -dev -client 0.0.0.0


#持久化
docker run -d -p 8500:8500 \
--restart=always \
--name=consul \
-v "/consul/data:/consul/data" \
consul agent \
-server \
-ui \
-client=0.0.0.0 \
-bootstrap-expect=1

```