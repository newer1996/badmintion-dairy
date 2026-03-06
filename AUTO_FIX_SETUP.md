# 自动修复和通知配置指南

## 功能说明

配置完成后，系统将实现：

1. **自动监控** - 每次构建失败时自动触发
2. **智能分析** - 分析构建日志，识别常见问题
3. **自动修复** - 尝试自动修复已知问题
4. **邮件通知** - 发送构建状态到 QQ 邮箱
5. **自动重建** - 修复后自动触发新构建

---

## 配置步骤

### 1. 配置 QQ 邮箱 SMTP

#### 获取 QQ 邮箱授权码

1. 登录 QQ 邮箱 (https://mail.qq.com)
2. 点击「设置」→「账户」
3. 找到「POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务」
4. 开启「SMTP服务」
5. 点击「生成授权码」，按提示操作
6. **保存授权码**（只显示一次）

#### 添加到 GitHub Secrets

1. 访问 https://github.com/newer1996/badmintion-dairy/settings/secrets/actions
2. 点击 "New repository secret"
3. 添加以下 secrets：

| Secret Name | Value | 说明 |
|------------|-------|------|
| `QQ_EMAIL` | 318768183@qq.com | 你的 QQ 邮箱 |
| `QQ_EMAIL_PASSWORD` | 你的授权码 | SMTP 授权码（不是邮箱密码）|

---

### 2. 配置 GitHub Token（已自动配置）

GitHub Actions 自动提供 `GITHUB_TOKEN`，无需额外配置。

---

### 3. 测试配置

#### 手动触发测试

1. 访问 https://github.com/newer1996/badmintion-dairy/actions
2. 选择 "Smart Auto Fix & Notify" 工作流
3. 点击 "Run workflow"
4. 检查是否收到邮件通知

#### 自动触发测试

1. 推送一个故意会导致构建失败的更改
2. 等待构建失败
3. 检查是否：
   - 收到邮件通知
   - 系统自动尝试修复
   - 自动触发新构建

---

## 自动修复能力

当前系统可以自动修复以下问题：

| 问题类型 | 修复方式 |
|---------|---------|
| 缺少 debug.keystore | 自动生成签名文件 |
| 缺少应用图标 | 生成默认图标 |
| 未使用的导入 | 移除或添加必要导入 |
| 缺少 AndroidX 配置 | 创建 gradle.properties |
| 缺少 local.properties | 创建配置文件 |
| 引用了不存在的字体 | 移除字体配置 |

---

## 邮件通知模板

### 构建失败 + 自动修复成功

```
主题: ✅ 构建已自动修复 - 羽球日记

内容:
- 仓库: newer1996/badmintion-dairy
- 工作流: Build APK
- 运行编号: #X
- 状态: failure → fixed
- 自动修复: 已应用 X 个修复
- 新构建: 已触发
```

### 构建失败 + 自动修复失败

```
主题: ❌ 构建失败 - 需要手动修复 - 羽球日记

内容:
- 仓库: newer1996/badmintion-dairy
- 工作流: Build APK
- 运行编号: #X
- 状态: failure
- 自动修复: 失败
- 建议: 手动检查代码
```

---

## 故障排除

### 问题1: 没有收到邮件

**检查:**
1. QQ 邮箱 SMTP 服务是否开启
2. Secrets 是否正确配置（注意是授权码不是密码）
3. 垃圾邮件文件夹

### 问题2: 自动修复不工作

**检查:**
1. 工作流是否有执行权限
2. 查看 Actions 日志了解具体错误
3. 检查 auto_fix.py 脚本是否有权限

### 问题3: 无限循环构建

**解决:**
如果自动修复导致无限循环，可以：
1. 临时禁用 smart-autofix.yml
2. 手动修复问题
3. 重新启用工作流

---

## 自定义配置

### 修改通知邮箱

编辑 `.github/workflows/smart-autofix.yml`：

```yaml
- name: Send email notification
  with:
    to: 你的邮箱@example.com  # 修改这里
```

### 添加更多自动修复规则

编辑 `scripts/auto_fix.py`，在 `analyze_and_fix` 方法中添加新的修复逻辑。

### 修改邮件模板

编辑 `.github/workflows/smart-autofix.yml` 中的 `html_body` 部分。

---

## 安全注意事项

1. **不要**将邮箱密码直接写在代码中
2. **使用** GitHub Secrets 存储敏感信息
3. **定期**更换 QQ 邮箱授权码
4. **不要**分享包含授权码的日志

---

## 相关文件

- `.github/workflows/smart-autofix.yml` - 自动修复工作流
- `.github/workflows/auto-fix.yml` - 备用自动修复工作流
- `scripts/auto_fix.py` - 自动修复脚本
- `AUTO_FIX_SETUP.md` - 本配置文档

---

## 技术支持

如有问题，请：
1. 查看 GitHub Actions 日志
2. 检查邮箱垃圾邮件文件夹
3. 验证 Secrets 配置
