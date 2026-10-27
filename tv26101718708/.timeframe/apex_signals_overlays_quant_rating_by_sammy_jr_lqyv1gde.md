# Apex Signals & Overlays + Quant Rating( by Sammy JR)

- url: https://www.tradingview.com/script/LQyV1Gde-Apex-Signals-Overlays-Quant-Rating-by-Sammy-JR/
- type: indicator
- pine_id: PUB;33e26eb8318647aeb219a2d47349c998
- version: 1.0

## Description

## 🚀 Institutional Signal Suite [FREE]

**Institutional Signal Suite** is a powerful all-in-one trading indicator designed to help traders identify high-probability buying and selling opportunities across stocks, ETFs, indices, cryptocurrencies, forex, and commodities.

Built using a combination of trend analysis, momentum filtering, market structure, dynamic support/resistance zones, volume profiling, and smart-money-inspired logic, this indicator aims to simplify market analysis into clear, actionable signals.

### 🔥 Key Features

✅ **Buy & Sell Signals**

* Automatically identifies potential trend reversals and continuation opportunities.
* Signals are filtered to reduce noise and avoid low-quality setups.

✅ **AI-Style Market Rating Engine**

* Continuously evaluates market conditions and assigns a bullish or bearish bias.
* Provides an easy-to-read overall market verdict.

✅ **Dynamic Support & Resistance Zones**

* Automatically plots important supply and demand areas.
* Highlights potential reversal and breakout levels.

✅ **Trend Detection System**

* Identifies the dominant market trend.
* Helps traders stay aligned with higher-probability directional moves.

✅ **Risk Management Levels**

* Optional stop-loss and trade management levels.
* Helps improve discipline and consistency.

✅ **Volume Profile Integration**

* Displays key high-volume areas where institutional activity may be concentrated.
* Useful for identifying support, resistance, and value zones.

✅ **Multi-Asset Compatible**

* Works on:

  * Stocks
  * ETFs
  * Crypto
  * Forex
  * Commodities
  * Indices

### 📈 How to Use

**Buy Signals**

* Look for BUY labels appearing near demand/support zones.
* Stronger setups occur when the overall rating turns bullish and price trades above the trend filter.

**Sell Signals**

* Look for SELL labels appearing near supply/resistance zones.
* Higher-quality setups occur when the rating turns bearish and price trades below the trend filter.

**Trend Following**

* Focus on signals that align with the prevailing trend for better probability.

### ⚠️ Important Notes

* This indicator is designed as a decision-support tool and should not be used as financial advice.
* No indicator can predict markets with 100% accuracy.
* Always combine signals with proper risk management and your own market analysis.

### 🎯 Best Timeframes

Works across multiple timeframes, but generally performs best on:

* 4H
* Daily
* Weekly

### 💡 Ideal For

* Swing Traders
* Position Traders
* Day Traders
* Long-Term Investors
* Portfolio Managers

---

**Institutional Signal Suite helps transform complex market data into clear trading decisions by combining trend, momentum, volume, and market structure into one easy-to-use framework.** 📊🚀

## Source Code

````pine
//@version=6
indicator("Apex Signals & Overlays + Quant Rating", "APEX S&O", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// =====================================================================
//  APEX SIGNALS & OVERLAYS + QUANT RATING  (v1.1)
//  Original, open multi-factor signal + overlay toolkit (educational).
//  Inspired by the *category* of premium signal suites and quant
//  scorecards -- NOT a copy of, or affiliated with, any proprietary
//  product. A charting tool, not financial advice. Use your own risk rules.
//  v1.1: repaint-safe mode, TP/SL projections, higher-timeframe bias row.
// =====================================================================

// ----------------------------------------------------------- Inputs
gA = "① Signal Engine"
sens        = input.float(4.0, "Signal Sensitivity (ATR mult)", minval=0.5, maxval=10.0, step=0.1, group=gA, tooltip="Higher = fewer, stronger trend signals")
atrLen      = input.int(10, "ATR Length", minval=1, group=gA)
useConf     = input.bool(true, "Confirmation signals (BUY / SELL)", group=gA)
useContra   = input.bool(true, "Contrarian reversals (▲ / ▼)", group=gA)
confirmOnly = input.bool(false, "Repaint-safe: confirmed bar only", group=gA, tooltip="Only print signals after the bar closes — no live-bar flicker")

gT = "② Trend Overlay"
showCloud = input.bool(true, "Trend cloud + bar tint", group=gT)
fastLen   = input.int(21, "Fast EMA", minval=1, group=gT)
slowLen   = input.int(55, "Slow EMA", minval=1, group=gT)
showTrail = input.bool(true, "Smart trailing stop", group=gT)

gTgt = "③ Targets (TP / SL)"
showTargets = input.bool(true, "Project TP / SL on signals", group=gTgt)
slAtrMult   = input.float(1.5, "Stop distance (ATR mult)", minval=0.1, step=0.1, group=gTgt)
tp1R        = input.float(1.0, "TP1 (R multiple)", minval=0.1, step=0.1, group=gTgt)
tp2R        = input.float(2.0, "TP2 (R multiple)", minval=0.1, step=0.1, group=gTgt)

gS = "④ Support / Resistance"
showSR   = input.bool(true, "Dynamic S/R zones", group=gS)
pivLen   = input.int(15, "Pivot lookback", minval=2, group=gS)
maxZones = input.int(4, "Max zones per side", minval=1, maxval=10, group=gS)

gQ = "⑤ Quant Rating"
showPanel = input.bool(true, "Show quant rating panel", group=gQ)
panelPos  = input.string("Top Right", "Panel position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=gQ)
rsiLen    = input.int(14, "RSI length", minval=1, group=gQ)
rocLen    = input.int(20, "Momentum (ROC) length", minval=1, group=gQ)
htfTf     = input.timeframe("D", "HTF bias timeframe", group=gQ, tooltip="Higher timeframe used for the 'HTF Bias' row")

gC = "⑥ Colors"
bull = input.color(#00bcd4, "Bull", group=gC)
bear = input.color(#ff5252, "Bear", group=gC)
neu  = input.color(#9e9e9e, "Neutral", group=gC)

// ----------------------------------------------------------- Core
atr     = ta.atr(atrLen)
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
rsi     = ta.rsi(close, rsiLen)

[stLine, stDir] = ta.supertrend(sens, atrLen)
trendUp = stDir < 0
flipUp  = trendUp and not trendUp[1]
flipDn  = not trendUp and trendUp[1]

f_clamp(x) => math.max(-1.0, math.min(1.0, x))

// ----------------------------------------------------------- Signals (repaint-safe gate)
conf     = not confirmOnly or barstate.isconfirmed
buySig   = useConf and flipUp and conf
sellSig  = useConf and flipDn and conf
ll5 = ta.lowest(low, 5)
hh5 = ta.highest(high, 5)
contraUp = useContra and rsi < 30 and low  <= ll5 and close > open and conf
contraDn = useContra and rsi > 70 and high >= hh5 and close < open and conf

plotshape(buySig,  "Buy",  shape.labelup,   location.belowbar, bull, text="BUY",  textcolor=color.white, size=size.small)
plotshape(sellSig, "Sell", shape.labeldown, location.abovebar, bear, text="SELL", textcolor=color.white, size=size.small)
plotshape(contraUp, "Bull reversal", shape.triangleup,   location.belowbar, color.new(bull,20), size=size.tiny)
plotshape(contraDn, "Bear reversal", shape.triangledown, location.abovebar, color.new(bear,20), size=size.tiny)

// ----------------------------------------------------------- Trend overlay
pF = plot(showCloud ? emaFast : na, "Fast EMA", color=color.new(trendUp?bull:bear, 35), linewidth=1)
pS = plot(showCloud ? emaSlow : na, "Slow EMA", color=color.new(neu, 55), linewidth=1)
fill(pF, pS, color = trendUp ? color.new(bull, 88) : color.new(bear, 88), title="Trend Cloud")
plot(showTrail ? stLine : na, "Smart Trail", color = trendUp ? bull : bear, linewidth=2, style=plot.style_linebr)
barcolor(showCloud ? color.new(trendUp?bull:bear, 55) : na)

// ----------------------------------------------------------- TP / SL projection
var line  slL = na
var line  t1L = na
var line  t2L = na
var label slLab = na
var label t1Lab = na
var label t2Lab = na

if showTargets and (buySig or sellSig)
    line.delete(slL)
    line.delete(t1L)
    line.delete(t2L)
    label.delete(slLab)
    label.delete(t1Lab)
    label.delete(t2Lab)
    entry  = close
    dir    = buySig ? 1.0 : -1.0
    slDist = atr * slAtrMult
    slP    = entry - dir * slDist
    tp1P   = entry + dir * slDist * tp1R
    tp2P   = entry + dir * slDist * tp2R
    rgt    = bar_index + 24
    slL   := line.new(bar_index, slP,  rgt, slP,  color=color.new(bear,0), style=line.style_dashed, width=1)
    t1L   := line.new(bar_index, tp1P, rgt, tp1P, color=color.new(bull,0), style=line.style_dotted, width=1)
    t2L   := line.new(bar_index, tp2P, rgt, tp2P, color=color.new(bull,0), style=line.style_solid,  width=1)
    slLab := label.new(rgt, slP,  "SL "  + str.tostring(slP,  format.mintick), style=label.style_label_left, color=color.new(bear,82), textcolor=bear, size=size.small)
    t1Lab := label.new(rgt, tp1P, "TP1 " + str.tostring(tp1P, format.mintick), style=label.style_label_left, color=color.new(bull,82), textcolor=bull, size=size.small)
    t2Lab := label.new(rgt, tp2P, "TP2 " + str.tostring(tp2P, format.mintick), style=label.style_label_left, color=color.new(bull,82), textcolor=bull, size=size.small)

// ----------------------------------------------------------- S/R zones
var box[] resB = array.new<box>()
var box[] supB = array.new<box>()
ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)
zh = atr * 0.5

if showSR and not na(ph)
    bx = box.new(bar_index - pivLen, ph + zh*0.5, bar_index, ph - zh*0.5, border_color=color.new(bear,40), bgcolor=color.new(bear,84))
    array.push(resB, bx)
    if array.size(resB) > maxZones
        box.delete(array.shift(resB))
if showSR and not na(pl)
    bx = box.new(bar_index - pivLen, pl + zh*0.5, bar_index, pl - zh*0.5, border_color=color.new(bull,40), bgcolor=color.new(bull,84))
    array.push(supB, bx)
    if array.size(supB) > maxZones
        box.delete(array.shift(supB))
if barstate.islast
    for b in resB
        box.set_right(b, bar_index + 12)
    for b in supB
        box.set_right(b, bar_index + 12)

// ----------------------------------------------------------- Quant factors  (-1 bear .. +1 bull)
trendScore = f_clamp((close>emaSlow?0.5:-0.5) + (emaFast>emaSlow?0.5:-0.5))
momScore   = f_clamp((rsi - 50)/30)
[macdL, macdS, macdH] = ta.macd(close, 12, 26, 9)
macdScore  = atr>0 ? f_clamp((macdL - macdS)/(atr*0.5)) : 0.0
roc        = ta.roc(close, rocLen)
rocScore   = f_clamp(roc/5)
basis = ta.sma(close, 20)
dev   = ta.stdev(close, 20)
pctB  = dev>0 ? (close - (basis - 2*dev))/(4*dev) : 0.5
bandScore  = f_clamp((pctB - 0.5)*2)
volAbs = math.abs(nz(volume))
volAvg = ta.sma(volAbs, 20)
hasVol = volAvg > 0
volScore = hasVol ? f_clamp(((close>open?1:-1)*nz(volume))/(volAvg*1.5)) : 0.0

scoreSum  = trendScore + momScore + macdScore + rocScore + bandScore + (hasVol?volScore:0.0)
scoreCnt  = 5 + (hasVol?1:0)
composite = scoreSum / scoreCnt
rating5   = math.max(1.0, math.min(5.0, 3 + composite*2))

// Higher-timeframe bias (repaint-safe: previous confirmed HTF bar)
f_htf() =>
    e1 = ta.ema(close, fastLen)
    e2 = ta.ema(close, slowLen)
    r  = ta.rsi(close, rsiLen)
    ts = (close>e2?0.5:-0.5) + (e1>e2?0.5:-0.5)
    ms = math.max(-1.0, math.min(1.0, (r-50)/30))
    math.max(-1.0, math.min(1.0, (ts + ms)/2))
htfScore = request.security(syminfo.tickerid, htfTf, f_htf()[1], lookahead=barmerge.lookahead_off)

f_grade(s) => s>=0.5?"STRONG BUY" : s>=0.2?"BUY" : s>-0.2?"HOLD" : s>-0.5?"SELL" : "STRONG SELL"
f_gcol(s)  => s>=0.5?#1b7a3d : s>=0.2?#2e9e57 : s>-0.2?#5c6b73 : s>-0.5?#d14b4b : #a32525

// ----------------------------------------------------------- Quant panel
pPos = panelPos=="Top Right"?position.top_right : panelPos=="Top Left"?position.top_left : panelPos=="Bottom Right"?position.bottom_right : position.bottom_left
var table pnl = table.new(pPos, 2, 10, border_width=1, frame_width=1, frame_color=color.new(color.gray,30))

f_row(int row, string lbl, float s, string txt) =>
    table.cell(pnl, 0, row, lbl, text_color=color.white, text_size=size.small, bgcolor=color.new(#2b343a,0), text_halign=text.align_left)
    table.cell(pnl, 1, row, txt, text_color=color.white, text_size=size.small, bgcolor=f_gcol(s), text_halign=text.align_center)

if showPanel and barstate.islast
    table.cell(pnl, 0, 0, "APEX QUANT", text_color=color.white, text_size=size.normal, bgcolor=color.new(#1b2429,0), text_halign=text.align_left)
    table.cell(pnl, 1, 0, str.tostring(rating5, "#.0")+"/5", text_color=color.white, text_size=size.normal, bgcolor=f_gcol(composite), text_halign=text.align_center)
    f_row(1, "VERDICT",      composite,  f_grade(composite))
    f_row(2, "HTF Bias ("+htfTf+")", htfScore, f_grade(htfScore))
    f_row(3, "Trend",        trendScore, f_grade(trendScore))
    f_row(4, "Momentum RSI", momScore,   f_grade(momScore))
    f_row(5, "MACD",         macdScore,  f_grade(macdScore))
    f_row(6, "ROC",          rocScore,   f_grade(rocScore))
    f_row(7, "Bands %B",     bandScore,  f_grade(bandScore))
    table.cell(pnl, 0, 8, "Volume", text_color=color.white, text_size=size.small, bgcolor=color.new(#2b343a,0), text_halign=text.align_left)
    table.cell(pnl, 1, 8, hasVol?f_grade(volScore):"n/a", text_color=color.white, text_size=size.small, bgcolor=hasVol?f_gcol(volScore):color.new(color.gray,0), text_halign=text.align_center)
    table.cell(pnl, 0, 9, syminfo.ticker, text_color=color.new(color.white,25), text_size=size.small, bgcolor=color.new(#1b2429,0), text_halign=text.align_left)
    table.cell(pnl, 1, 9, timeframe.period, text_color=color.new(color.white,25), text_size=size.small, bgcolor=color.new(#1b2429,0), text_halign=text.align_center)

// ----------------------------------------------------------- Alerts
alertcondition(buySig,   "APEX Buy",  "APEX BUY {{ticker}} {{interval}}")
alertcondition(sellSig,  "APEX Sell", "APEX SELL {{ticker}} {{interval}}")
alertcondition(contraUp, "APEX Bull Reversal", "APEX bullish reversal {{ticker}}")
alertcondition(contraDn, "APEX Bear Reversal", "APEX bearish reversal {{ticker}}")
if buySig
    alert("APEX BUY "  + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
if sellSig
    alert("APEX SELL " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
````
