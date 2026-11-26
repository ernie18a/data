# NYAD 89EMA - NYSE Advance/Decline Line

- url: https://www.tradingview.com/script/A5EDX9vA/
- type: indicator
- pine_id: PUB;c12651a1397b458b8bd86a9291702bcd
- version: 2.0

## Description

This script plots the NYSE Advance-Decline Line (NYAD), a market breadth indicator based on NYSE advancing and declining issues. It calculates daily net advances by subtracting declining issues from advancing issues, then accumulates the result over time to form the NYAD line. An 89-day EMA is included as a trend reference to help users observe the broader direction of market participation and the relationship between NYAD and its moving average.

A rising NYAD generally suggests that more stocks are participating in the advance, which may indicate healthier market breadth. A falling NYAD may suggest weakening internal participation, even if major indexes remain elevated. The indicator can also be useful for identifying potential divergences between market breadth and price indexes.

Because NYAD is a cumulative indicator, its absolute value may vary across data vendors, historical starting points, and available breadth history. This script includes a Calibration Offset input so users can align the indicator with their preferred reference source if needed.

This indicator is intended for market breadth analysis and research only. It does not generate buy or sell signals and should not be considered investment advice.


本脚本用于绘制 NYSE Advance-Decline Line（NYAD，纽约证券交易所上涨/下跌累积线）。它基于 NYSE 上涨家数和下跌家数计算每日净上涨家数，即上涨家数减去下跌家数，并将该数值随时间累加，形成 NYAD 线。脚本同时加入 89 日 EMA 作为趋势参考，用于观察市场广度的整体方向，以及 NYAD 与其均线之间的关系。

NYAD 上升通常表示更多股票参与上涨，说明市场内部广度较为健康；NYAD 下降则可能表示市场内部参与度走弱，即使主要指数仍处于较高位置。该指标也可用于观察市场广度与价格指数之间是否出现背离。

由于 NYAD 是累计型指标，其绝对数值可能会因为数据源、历史起点和可用历史数据长度不同而与其他平台存在差异。因此，本脚本提供 Calibration Offset 输入，方便用户根据自己的参考数据进行校准。

本指标仅用于市场广度分析和研究，不产生买卖信号，也不构成投资建议。

## Source Code

````pine
//@version=6
indicator("NYAD - NYSE Advance/Decline Line", shorttitle="NYAD", overlay=false, max_bars_back=5000, precision=2)

// === Data source ===
advSym = input.symbol("USI:ADV",  "NYSE Advancing Issues")
decSym = input.symbol("USI:DECL", "NYSE Declining Issues")

emaLen = input.int(89, "EMA length", minval=1)
offset = input.float(0.0, "Calibration offset")

// === Daily NYSE breadth data ===
adv = request.security(
     advSym, "D", close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

dec = request.security(
     decSym, "D", close,
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off,
     ignore_invalid_symbol=true
)

// === Net Advances ===
valid = not na(adv) and not na(dec)
netAdvances = valid ? adv - dec : na

// === NYAD cumulative line ===
nyad = ta.cum(nz(netAdvances, 0)) + offset

// === EMA(89) ===
nyadEma = ta.ema(nyad, emaLen)

// === Colors ===
// 深色背景：上涨白色，下跌红色
nyadColor = nyad >= nyad[1] ? color.white : color.red

// 白色背景的话，把上面一行改成：
// nyadColor = nyad >= nyad[1] ? color.black : color.red

emaColor = color.green

// === Plots ===
plot(nyad, "NYAD", color=nyadColor, linewidth=2)
plot(nyadEma, "EMA", color=emaColor, linewidth=1)

//hline(0, "Zero", color=color.gray, linestyle=hline.style_dotted)
````
