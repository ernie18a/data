# MSTR mNAV Tracker

- url: https://www.tradingview.com/script/nf1HWvqk/
- type: indicator
- pine_id: PUB;1758939f171d44a081bbed18bfb52378
- version: 1.0

## Description

针对MSTR的mNAV指标进行追踪。
mNAV的含义（modified Net Asset Value），即公司市值相对于其比特币持有的调整净资产价值
小于1时，买MSTR，大于1时，买BTC

## Source Code

````pine
//@version=5
indicator("MSTR mNAV 追踪器", overlay=false, precision=2)

// --- 数据输入（按 2026 年 4 月最新披露） ---
btc_held = input.float(815061, "总持币量 (BTC)")
total_shares = input.float(381588000, "总股数 (Shares)")
btc_price = request.security("CRYPTO:BTCUSD", "D", close)

// --- 计算逻辑 ---
btc_per_share = btc_held / total_shares
nav = btc_price * btc_per_share
mNAV = close / nav

// --- 绘图 ---
// 1. 画出 mNAV 曲线，并赋值给变量 p1
p1 = plot(mNAV, "mNAV 溢价率", color=color.blue, linewidth=2)

// 2. 将基准线 1.0 也用 plot 画出（而不是 hline），赋值给变量 p2
p2 = plot(1.0, "基准线", color=color.gray, style=plot.style_line)

// 3. 填充 p1 和 p2 之间的颜色
// 当 mNAV > 1.0 时填充绿色（溢价），否则填充红色（折价）
fill_color = mNAV > 1.0 ? color.new(color.green, 85) : color.new(color.red, 85)
fill(p1, p2, fill_color, "溢价/折价填充")
````
