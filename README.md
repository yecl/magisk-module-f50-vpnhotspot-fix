# ZTE F50 VPN Tun0 Rule Fix

用于中兴 F50 + [VPN Hotspot](https://github.com/mygod/vpnhotspot) 的 Magisk 模块。

仅在中兴 F50 上测试。

## 问题

观察到的策略路由顺序：

```sh
9999:  from all lookup main
17800: from all iif br0 lookup tun0
```

`main` 中存在：

```sh
<蜂窝侧私网网段> dev sipa_eth0
```

部分 VPN 目标会先命中 `main`，从 `sipa_eth0` 出去。

## 修复

`tun0` 存在且 `table tun0` 有路由时：

```sh
ip rule add pref 9000 lookup tun0
ip route flush cache
```

`tun0` 消失时：

```sh
ip rule del pref 9000 lookup tun0
ip route flush cache
```

假设 `table tun0` 只有分流路由，没有默认路由。

## 构建

```sh
./build.sh
```

产物：

```sh
dist/vpn-tun0-rule-fix.zip
```

## 验证

```sh
su -c 'ip rule'
su -c 'ip route get <VPN内网地址>'
su -c 'ip route get <VPN内网地址> from <下游设备地址> iif br0'
su -c 'ip route get <公网地址>'
```

预期：

```text
<VPN内网地址> -> dev tun0
<VPN内网地址> from <下游设备地址> iif br0 -> dev tun0
<公网地址> -> dev sipa_eth0
```
