# OBV + Confluence

- url: https://www.tradingview.com/script/75Q8deXE-OBV-Confluence/
- type: indicator
- pine_id: PUB;969c6cd1bad8482982e77218ca39e9e3
- version: 1.0

## Description

Multiple Conflunces over the OBV
🏆 Accuracy Ranking by Scenario
Scenario                             Winner
Intraday trend accuracy   VWAP
Catching breakouts early   WMA
Minimizing false signals  EMA
Long-term trend clarity   SMA
Overall versatility         EMA

## Source Code

````pine
//@version=5
indicator("OBV + Confluence", shorttitle="OBV+CF", overlay=false)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
smoothingType   = input.string("WMA", title="Primary Smoothing Line", options=["SMA", "EMA", "WMA", "VWMA", "DEMA", "None"])
smoothingLength = input.int(20, title="Primary Smoothing Length", minval=1)

// ─── CONFLUENCE INPUTS ────────────────────────────────────────────────────────
showConfluence  = input.bool(true,  title="Show Confluence Lines")
emaLen          = input.int(21,  title="EMA Length  (Trend)",     minval=1, group="Confluence Settings")
wmaLen          = input.int(9,   title="WMA Length  (Momentum)",  minval=1, group="Confluence Settings")
vwmaLen         = input.int(14,  title="VWMA Length (Volume Wt)", minval=1, group="Confluence Settings")
showSignal      = input.bool(true, title="Show Confluence Signal Bar", group="Confluence Settings")

// ─── OBV ──────────────────────────────────────────────────────────────────────
obv = ta.obv

// ─── PRIMARY SMOOTHING FUNCTION ───────────────────────────────────────────────
f_smooth(src, len, stype) =>
    float result = na
    if stype == "SMA"
        result := ta.sma(src, len)
    else if stype == "EMA"
        result := ta.ema(src, len)
    else if stype == "WMA"
        result := ta.wma(src, len)
    else if stype == "VWMA"
        result := ta.vwma(src, len)
    else if stype == "DEMA"
        float e1 = ta.ema(src, len)
        result := 2 * e1 - ta.ema(e1, len)
    else
        result := src
    result

smoothedOBV = f_smooth(obv, smoothingLength, smoothingType)

// ─── CONFLUENCE LINES ─────────────────────────────────────────────────────────
obvEMA  = ta.ema(obv,  emaLen)
obvWMA  = ta.wma(obv,  wmaLen)
obvVWMA = ta.vwma(obv, vwmaLen)

// ─── CONFLUENCE LOGIC ─────────────────────────────────────────────────────────
bullConfluence = obv > obvEMA and obv > obvWMA and obv > obvVWMA
bearConfluence = obv < obvEMA and obv < obvWMA and obv < obvVWMA

// ─── PLOTS ────────────────────────────────────────────────────────────────────
plot(obv,         title="OBV",             color=color.blue,                  linewidth=1)
plot(smoothedOBV, title="Primary MA",      color=color.teal,                  linewidth=2)

plot(showConfluence ? obvEMA  : na, title="EMA  (Trend)",      color=color.orange,               linewidth=1)
plot(showConfluence ? obvWMA  : na, title="WMA  (Momentum)",   color=color.purple,               linewidth=1)
plot(showConfluence ? obvVWMA : na, title="VWMA (Vol Anchor)",  color=color.new(color.yellow, 20), linewidth=1)

// ─── FIX: resolve color before passing into bgcolor ───────────────────────────
bgColor = bullConfluence ? color.new(color.green, 85) : bearConfluence ? color.new(color.red, 85) : na
bgcolor(showSignal ? bgColor : na, title="Confluence Signal BG")

// ─── CONFLUENCE SIGNAL DOTS ───────────────────────────────────────────────────
plotshape(showSignal and bullConfluence, title="Bull Signal", location=location.bottom, style=shape.triangleup,   color=color.new(color.green, 0), size=size.tiny)
plotshape(showSignal and bearConfluence, title="Bear Signal", location=location.top,    style=shape.triangledown, color=color.new(color.red,   0), size=size.tiny)
````
