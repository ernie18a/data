<!-- tradingview-pine-id: PUB;e17d3c97df0a445fbfdc22cbbbb5892c -->
<!-- tradingviewscripts-format: 1 -->
# CVD Candles + EMA Channel + Cloud

Source: https://www.tradingview.com/script/SkH2rgnt-CVD-Candles-EMA-Channel-Cloud/

## Description

CVD with EMA Channel analysis and Trend Cloud. AI wrote the code. I use the indicator.

---

## Source Code

````pine
//@version=6
indicator("CVD Candles + EMA Channel + Cloud", shorttitle="CVD Ch+Cloud", overlay=false)

// ============================================================
//  CVD CALCULATION SETTINGS
// ============================================================
grp_cvd    = "CVD Settings"
ltfInput   = input.timeframe("1", "Lower Timeframe (intrabar)", group=grp_cvd,
             tooltip="Timeframe used to estimate buy/sell volume inside each chart bar. Use a small TF (e.g. 1min or 1sec) on ES for best accuracy.")
resetInput = input.string("None", "Reset CVD", options=["None", "Daily", "Weekly"], group=grp_cvd)

// ============================================================
//  CHANNEL SETTINGS  (basis = EMA of close, top = EMA of highs, bottom = EMA of lows)
// ============================================================
grp_chan      = "Channel (EMA + High/Low)"
showChannel   = input.bool(true, "Show Channel", group=grp_chan)
chanEmaLen    = input.int(20, "Channel EMA Length", minval=1, group=grp_chan)
chanHLLen     = input.int(20, "Channel High/Low EMA Length", minval=1, group=grp_chan)
chanEmaColor  = input.color(color.yellow, "EMA Basis Color", group=grp_chan)
chanTopColor  = input.color(color.new(color.lime, 20), "Channel Top Color", group=grp_chan)
chanBotColor  = input.color(color.new(color.red, 20), "Channel Bottom Color", group=grp_chan)
chanFillColor = input.color(color.new(color.gray, 90), "Channel Fill Color", group=grp_chan)
chanLineWidth = input.int(1, "Channel Line Width", minval=1, maxval=4, group=grp_chan)

// ============================================================
//  CLOUD SETTINGS  (20 / 50 EMA)
// ============================================================
grp_cloud       = "Cloud (Fast/Slow EMA)"
showCloud       = input.bool(true, "Show Cloud", group=grp_cloud)
cloudFastLen    = input.int(20, "Fast EMA Length", minval=1, group=grp_cloud)
cloudSlowLen    = input.int(50, "Slow EMA Length", minval=1, group=grp_cloud)
cloudFastColor  = input.color(color.aqua, "Fast EMA Color", group=grp_cloud)
cloudSlowColor  = input.color(color.orange, "Slow EMA Color", group=grp_cloud)
cloudBullColor  = input.color(color.new(color.green, 75), "Cloud Fill (Fast > Slow)", group=grp_cloud)
cloudBearColor  = input.color(color.new(color.red, 75), "Cloud Fill (Fast < Slow)", group=grp_cloud)
cloudLineWidth  = input.int(1, "Cloud Line Width", minval=1, maxval=4, group=grp_cloud)

// ============================================================
//  CANDLE APPEARANCE
// ============================================================
grp_candle  = "CVD Candle Appearance"
showCandles = input.bool(true, "Show CVD Candles", group=grp_candle)
cvdUpColor  = input.color(color.lime, "Up Color", group=grp_candle)
cvdDnColor  = input.color(color.red, "Down Color", group=grp_candle)
showZero    = input.bool(true, "Show Zero Line", group=grp_candle)

// ============================================================
//  BUILD THE CVD CANDLE (open/high/low/close) FOR THIS BAR
// ============================================================
newPeriod = switch resetInput
    "Daily"  => timeframe.change("D")
    "Weekly" => timeframe.change("W")
    => false

var float cvdCum = 0.0
if newPeriod
    cvdCum := 0.0

openVal = cvdCum

opensArr  = request.security_lower_tf(syminfo.tickerid, ltfInput, open)
closesArr = request.security_lower_tf(syminfo.tickerid, ltfInput, close)
volsArr   = request.security_lower_tf(syminfo.tickerid, ltfInput, volume)

float highVal  = openVal
float lowVal   = openVal
float closeVal = openVal

n = array.size(closesArr)
if n > 0
    for i = 0 to n - 1
        o = array.get(opensArr, i)
        c = array.get(closesArr, i)
        v = array.get(volsArr, i)
        d = c > o ? v : c < o ? -v : 0.0
        cvdCum := cvdCum + d
        highVal := math.max(highVal, cvdCum)
        lowVal  := math.min(lowVal, cvdCum)
    closeVal := cvdCum
else
    // Fallback if no intrabar data is available (LTF >= chart TF)
    d = close > open ? volume : close < open ? -volume : 0.0
    cvdCum := cvdCum + d
    closeVal := cvdCum
    highVal  := math.max(openVal, closeVal)
    lowVal   := math.min(openVal, closeVal)

// ============================================================
//  PLOT: CVD CANDLES
// ============================================================
candleColor = closeVal >= openVal ? cvdUpColor : cvdDnColor
plotcandle(showCandles ? openVal : na, showCandles ? highVal : na,
     showCandles ? lowVal : na, showCandles ? closeVal : na,
     title="CVD", color=candleColor, wickcolor=candleColor, bordercolor=candleColor)

// ============================================================
//  CHANNEL: basis = EMA of CVD close, top = EMA of CVD highs, bottom = EMA of CVD lows
// ============================================================
chanBasis = ta.ema(closeVal, chanEmaLen)
chanTop   = ta.ema(highVal, chanHLLen)
chanBot   = ta.ema(lowVal, chanHLLen)

pChanBasis = plot(showChannel ? chanBasis : na, title="Channel EMA", color=chanEmaColor, linewidth=chanLineWidth)
pChanTop   = plot(showChannel ? chanTop : na, title="Channel Top", color=chanTopColor, linewidth=chanLineWidth)
pChanBot   = plot(showChannel ? chanBot : na, title="Channel Bottom", color=chanBotColor, linewidth=chanLineWidth)
fill(pChanTop, pChanBot, color=showChannel ? chanFillColor : na, title="Channel Fill")

// ============================================================
//  CLOUD: Fast/Slow EMA
// ============================================================
cloudFast = ta.ema(closeVal, cloudFastLen)
cloudSlow = ta.ema(closeVal, cloudSlowLen)

pCloudFast = plot(showCloud ? cloudFast : na, title="Cloud Fast EMA", color=cloudFastColor, linewidth=cloudLineWidth)
pCloudSlow = plot(showCloud ? cloudSlow : na, title="Cloud Slow EMA", color=cloudSlowColor, linewidth=cloudLineWidth)
cloudColor = cloudFast >= cloudSlow ? cloudBullColor : cloudBearColor
fill(pCloudFast, pCloudSlow, color=showCloud ? cloudColor : na, title="Cloud Fill")

// ============================================================
//  ZERO LINE
// ============================================================
plot(showZero ? 0.0 : na, title="Zero Line", color=color.new(color.gray, 50), style=plot.style_line, linewidth=1)
````
