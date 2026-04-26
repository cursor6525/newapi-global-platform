# 🔄 数据流向图 (业务数据不出境证明)

本文档用于向审计机构证明：用户业务数据永久存储在本地，绝不跨国传输。

## 1. 架构数据流向总览

```text
[中国用户] ---> [中国边缘 Nginx] ---> [中国 K8s NewAPI] ---> [中国 MySQL (100.64.1.10)]
   (Data stays in CN)      (No data leaves CN)      (Data stays in CN)

[美国用户] ---> [美国边缘 Nginx] ---> [美国 K8s NewAPI] ---> [美国 MySQL (100.64.2.10)]
   (Data stays in US)      (No data leaves US)      (Data stays in US)
