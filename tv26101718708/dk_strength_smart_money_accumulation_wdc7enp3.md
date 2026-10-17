# D/K Strength + Smart Money Accumulation

- url: https://www.tradingview.com/script/WDC7ENp3-D-K-Strength-Smart-Money-Accumulation/
- type: indicator
- pine_id: PUB;6447f799398341f29f8ffad293d0c163
- version: 1.0

## Description

A multi-component momentum and accumulation oscillator adapted from the Wenhua/TDX (Chinese trading platforms) community formula "多空力度 + 主力吸筹 文华专用 稳定版".

— LINES PLOTTED —

• Long Strength (green)
  A double-smoothed stochastic momentum on a 27-bar window, using the formula 3*SMA(stoch,5,1) - 2*SMA(SMA(stoch,5,1),3,1). Rising from low levels signals strengthening demand. Readings above 90 indicate extended bullish momentum.

• Short Strength (red)
  Distance of close from the 55-bar high, normalized to 0–100. Persistent readings above the 44 midline reflect bearish pressure; values near 100 mean price is at a 55-bar low.

• Smart Money Accumulation (yellow)
  A volume-free proxy detecting potential accumulation at the 30-bar low. Spikes above zero — especially appearing after a downtrend — are interpreted as buying pressure from larger participants.

— REFERENCE LEVELS —

  0   = zero axis
  44  = mid-line (long/short pressure boundary)
  90  = overbought / overextended threshold

— HIDDEN DEBUG OUTPUTS (toggle in Settings → Style) —

  J         — classic KDJ J line (3K - 2D)
  A65       — KD crossover marker (60 on bullish cross, 0 otherwise)
  A151/A152 — deep oversold / overbought flags
  Anquan    — safety zone value

— TECHNICAL NOTE —

The original formula uses a recursive weighted average:
   SMA(X, N, M) = (M*X + (N-M)*prev) / N
which is NOT equivalent to Pine's ta.sma. This implementation faithfully replicates the recursive form via inline state variables, preserving the original signal shape. All divisions are guarded against zero denominators.

— SUGGESTED USE —

• Long bias: Long Strength crossing above Short Strength while Accumulation spikes above zero.
• Short bias: Long Strength rolling over from 90 with Short Strength rising through the midline.
• Works on equities, futures and crypto. Best results on daily and 4-hour timeframes; usable on intraday with parameter awareness.
• Pair with the companion "Protection Price" overlay indicator for entry and stop reference.

A faithful Pine v6 port of the original community formula. Author of the original formula unknown.

## Source Code

````pine
//@version=6
// 来源：文华财经/通达信指标「多空力度+主力吸筹 文华专用 稳定版」复刻 — 副图部分。
// SMA(X,N,M) 用 var float + 递推变量内联实现：Y = (M*X + (N-M)*Y[1]) / N。
// 0-100 范围指标专用副图，保护价请加另一个主图指标。
indicator(title = "多空力度+主力吸筹 副图", overlay = false, max_bars_back = 500)

hhv55 = ta.highest(high, 55)
llv55 = ta.lowest(low, 55)
den55 = hhv55 - llv55
kongFang = na(den55) or den55 == 0.0 ? 0.0 : 100.0 * (hhv55 - close) / den55

hhv27 = ta.highest(high, 27)
llv27 = ta.lowest(low, 27)
den27 = hhv27 - llv27
duoBase = na(den27) or den27 == 0.0 ? 0.0 : (close - llv27) / den27 * 100.0
var float duoSma1 = na
duoSma1 := na(duoSma1[1]) ? duoBase : (duoBase + 4.0 * duoSma1[1]) / 5.0
var float duoSma2 = na
duoSma2 := na(duoSma2[1]) ? duoSma1 : (duoSma1 + 2.0 * duoSma2[1]) / 3.0
duoFang = 3.0 * duoSma1 - 2.0 * duoSma2

hhv30 = ta.highest(high, 30)
llv30 = ta.lowest(low, 30)
den30 = hhv30 - llv30
rsv = na(den30) or den30 == 0.0 ? 0.0 : (close - llv30) / den30 * 100.0
var float k = na
k := na(k[1]) ? rsv : (rsv + 2.0 * k[1]) / 3.0
var float d = na
d := na(d[1]) ? k : (k + 2.0 * d[1]) / 3.0
j = 3.0 * k - 2.0 * d

lc = close[1]
rsiUpSrc = math.max(close - lc, 0.0)
rsiDenSrc = math.abs(close - lc)
var float rsiUp = na
rsiUp := na(rsiUp[1]) ? rsiUpSrc : (rsiUpSrc + 2.0 * rsiUp[1]) / 3.0
var float rsiDen = na
rsiDen := na(rsiDen[1]) ? rsiDenSrc : (rsiDenSrc + 2.0 * rsiDen[1]) / 3.0
rsi = na(rsiDen) or rsiDen == 0.0 ? 0.0 : rsiUp / rsiDen * 100.0

var1 = duoFang
var2 = ta.ema(var1, 8)

var3Base = na(den55) or den55 == 0.0 ? 0.0 : (close - llv55) / den55 * 100.0
var float var3Sma1 = na
var3Sma1 := na(var3Sma1[1]) ? var3Base : (var3Base + 4.0 * var3Sma1[1]) / 5.0
var float var3Sma2 = na
var3Sma2 := na(var3Sma2[1]) ? var3Sma1 : (var3Sma1 + 2.0 * var3Sma2[1]) / 3.0
var3 = 3.0 * var3Sma1 - 2.0 * var3Sma2
qushi = ta.ema(var3, 3) - 10.0
var4Den = qushi[1]
var4 = na(var4Den) or var4Den == 0.0 ? 0.0 : (qushi - qushi[1]) / var4Den * 100.0

lowDiff = low - low[1]
lowAbsSrc = math.abs(lowDiff)
lowUpSrc = math.max(lowDiff, 0.0)
var float lowAbsSma = na
lowAbsSma := na(lowAbsSma[1]) ? lowAbsSrc : (lowAbsSrc + 2.0 * lowAbsSma[1]) / 3.0
var float lowUpSma = na
lowUpSma := na(lowUpSma[1]) ? lowUpSrc : (lowUpSrc + 2.0 * lowUpSma[1]) / 3.0

var3333 = na(lowUpSma) or lowUpSma == 0.0 ? 0.0 : lowAbsSma / lowUpSma * 100.0
var4444Input = close > 0.0 ? var3333 * 10.0 : var3333 / 10.0
var4444 = ta.ema(var4444Input, 3)
var5555 = ta.lowest(low, 30)
var6666 = ta.highest(var4444, 30)
var7777 = ta.sma(close, 58) > 0.0 ? 1.0 : 0.0
xichouRaw = low <= var5555 ? (var4444 + var6666 * 2.0) / 2.0 : 0.0
zhuliXichou = ta.ema(xichouRaw, 3) / 618.0 * var7777

a5Low = ta.lowest(low, 9)
a5High = ta.highest(high, 9)
a5Den = a5High - a5Low
a5 = na(a5Den) or a5Den == 0.0 ? 0.0 : (close - a5Low) / a5Den * 100.0

rsv2Low = ta.lowest(low, 9)
rsv2High = ta.highest(high, 9)
rsv2Den = rsv2High - rsv2Low
rsv2 = na(rsv2Den) or rsv2Den == 0.0 ? 0.0 : (close - rsv2Low) / rsv2Den * 100.0
var float k2 = na
k2 := na(k2[1]) ? rsv2 : (rsv2 + 2.0 * k2[1]) / 3.0
var float d2 = na
d2 := na(d2[1]) ? k2 : (k2 + 2.0 * d2[1]) / 3.0
a65 = ta.crossover(k2, d2) ? 60.0 : 0.0

a105 = ta.sma(close, 27)
a106 = na(a105) or a105 == 0.0 ? 0.0 : (close - a105) / a105 * 100.0
a107 = ta.sma(a106, 3)
crossNeg10 = ta.crossunder(a107, -10.0)
crossPos10 = ta.crossover(a107, 10.0)
a149 = ta.barssince(crossNeg10)
a150 = ta.barssince(crossPos10)
a151 = a107 < -10.0 and nz(a149, 0) > 3
a152 = a107 > 10.0 and nz(a150, 0) > 3
anquan = a151 ? a107 : 0.0

plot(duoFang, title = "多方线", color = color.green, linewidth = 2)
plot(kongFang, title = "空方线", color = color.red, linewidth = 2)
plot(zhuliXichou, title = "主力吸筹", color = color.yellow, linewidth = 3)

plot(j, title = "J", color = color.purple, display = display.none)
plot(a65, title = "A65", color = color.orange, display = display.none)
plot(a151 ? 1.0 : 0.0, title = "A151", color = color.green, display = display.none)
plot(a152 ? 1.0 : 0.0, title = "A152", color = color.red, display = display.none)
plot(anquan, title = "安全", color = color.teal, display = display.none)

hline(0.0, title = "零轴", color = color.gray, linestyle = hline.style_solid)
hline(44.0, title = "中线", color = color.gray, linestyle = hline.style_dashed)
hline(90.0, title = "高位线", color = color.red, linestyle = hline.style_dashed)
````
