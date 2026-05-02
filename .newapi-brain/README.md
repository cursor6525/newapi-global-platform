# .newapi-brain
NewAPI 全球集群 **全局大脑数据源仓库**

## 功能说明
- 整个 NewAPI 集群唯一数据中心
- 所有节点部署状态、服务状态统一存储
- 中文交互式控制台、运维、扩容、监控 全部从此仓库读取
- 状态标准：`✅ 部署成功` / `未部署`

## 目录说明
- `core/`：大脑核心读写逻辑
- `inventory/nodes/`：各节点服务状态库
- `config/`：集群元数据、节点角色配置
- `logs/`：大脑运行日志

## 使用方式
```bash
git clone https://github.com/你的用户名/.newapi-brain.git
cd .newapi-brain
bash init.sh
