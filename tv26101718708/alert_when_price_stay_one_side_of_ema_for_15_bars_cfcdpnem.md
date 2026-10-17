# Alert when price stay one side of EMA for 15 bars

- url: https://www.tradingview.com/script/cfcDpnem/
- type: indicator
- pine_id: PUB;82fcd54ffcd4491aaa6bc8a26a44bf41
- version: 1.0

## Description

行情运行超过EMA一侧15根以上变色加警告

## Source Code

````pine
//@version=6
indicator("行情运行超过EMA一侧15根以上变色", overlay=true)

// 设置EMA参数
ema_length = input.int(20, title="EMA 周期")
ema20 = ta.ema(close, ema_length)

// 判断收盘价位置
is_above = close > ema20
is_below = close < ema20

// 计数器
var int count_above = 0
var int count_below = 0

count_above := is_above ? nz(count_above[1]) + 1 : 0
count_below := is_below ? nz(count_below[1]) + 1 : 0

// 定义颜色逻辑
bool is_red = count_above > 15 or count_below > 15
line_color = is_red ? color.red : color.blue

// --- 新增：报警逻辑 ---
// 仅在计数刚好等于 16 的那一根 K 线触发（即刚变色时）
alert_trigger = (count_above == 16) or (count_below == 16)

if alert_trigger
    // 构建动态消息：包含品种名 (syminfo.ticker) 和 时间周期 (timeframe.period)
    alert_msg = "🚨 变色提醒！\n品种: " + syminfo.ticker + "\n周期: " + timeframe.period + "\n状态: EMA 20 已连续单侧运行 16 根 K 线。"
    alert(alert_msg, alert.freq_once_per_bar)
// --------------------

// 绘制均线
plot(ema20, color=line_color, linewidth=2, title="EMA 20")
````
