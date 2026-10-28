# NYSI 8EMA - NYSE McClellan Summation Index

- url: https://www.tradingview.com/script/tjghuUy8/
- type: indicator
- pine_id: PUB;73addb5c3f4b473686de7d5b2ea4dfa4
- version: 2.0

## Description

This indicator plots the NYSE McClellan Summation Index (NYSI), a market breadth indicator based on NYSE advancing and declining issues. It first calculates the ratio-adjusted net advances, then derives the McClellan Oscillator using the difference between the 19-day and 39-day EMAs, and finally accumulates the oscillator to form the NYSI. An 8-day EMA is also included as a short-term trend reference, helping users evaluate market breadth strength, trend shifts, and the relationship between the NYSI and its moving average. A rising NYSI generally suggests improving internal market participation, while a falling NYSI may indicate weakening breadth. Since the NYSI is a cumulative indicator, its absolute value may vary across data vendors, historical starting points, and initialization methods. For this reason, the script includes a Calibration Offset so users can align the indicator with their preferred reference source. This indicator is intended for market breadth analysis and research only and should not be considered investment advice.

本指标用于绘制 NYSE McClellan Summation Index（NYSI，麦克莱伦累加指数），通过 NYSE 上涨家数与下跌家数计算 ratio-adjusted net advances，并进一步使用 19 日 EMA 与 39 日 EMA 的差值得到 McClellan Oscillator，再将其累加形成 NYSI。指标同时提供 8 日 EMA 作为短期趋势参考，帮助观察市场广度的中期强弱、趋势拐点以及 NYSI 与均线之间的关系。NYSI 上升通常代表市场内部参与度改善，下降则可能表示市场广度走弱。由于 NYSI 是累计型指标，其绝对数值可能会因数据源、历史起点和初始化方式不同而与其他平台存在差异，因此本脚本加入了 Calibration Offset，方便用户根据自己的参考数据进行校准。本指标仅用于市场广度分析和研究，不构成投资建议。

## Source Code

````pine
//@version=6
indicator("NYSI Dashboard - NYSE McClellan Summation Index", shorttitle="NYSI", overlay=false, max_bars_back=5000, precision=2)

// === Data source ===
advSym = input.symbol("USI:ADV",  "NYSE Advancing Issues")
decSym = input.symbol("USI:DECL", "NYSE Declining Issues")

emaLen = input.int(8, "EMA length", minval=1)
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

// === Ratio-adjusted net advances ===
valid = not na(adv) and not na(dec) and (adv + dec) != 0
ratioAdjNetAdv = valid ? 1000.0 * (adv - dec) / (adv + dec) : na

// === McClellan Oscillator ===
mcclellanOsc = ta.ema(ratioAdjNetAdv, 19) - ta.ema(ratioAdjNetAdv, 39)

// === NYSI / Summation Index ===
nysi = ta.cum(nz(mcclellanOsc, 0)) + offset

// === EMA(8) ===
nysiEma = ta.ema(nysi, emaLen)

// === Colors ===
// NYSI: rising = green, falling = red
nysiColor = nysi >= nysi[1] ? color.white : color.red

// EMA: yellow
emaColor = color.yellow

// === Plots ===
plot(nysi, "NYSI", color=nysiColor, linewidth=2)
plot(nysiEma, "EMA(8)", color=emaColor, linewidth=1)

//hline(0, "Zero", color=color.gray, linestyle=hline.style_dotted)
//hline(500, "+500", color=color.new(color.gray, 75))
//hline(-500, "-500", color=color.new(color.gray, 75))
````
