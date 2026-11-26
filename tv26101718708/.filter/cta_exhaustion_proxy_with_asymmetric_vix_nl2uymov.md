# CTA Exhaustion Proxy with Asymmetric VIX

- url: https://www.tradingview.com/script/NL2UYMOv-CTA-Exhaustion-Proxy-with-Asymmetric-VIX/
- type: indicator
- pine_id: PUB;a3fea97f34ff4d84b26686a1e47a0fe4
- version: 1.0

## Description

A positioning-based reversal system that tracks trend-following fund crowding and exhaustion.
This indicator estimates when systematic trend-following funds (CTAs) are trapped at maximum positioning and likely to be forced into rapid covering or liquidation. It combines three timeframes of moving-average positioning with asymmetric volatility filters to identify high-probability reversal setups.

WHAT IT TRACKS
CTAs are mechanical trend-followers. When they all align on one side of the market (max long or max short), the risk of a violent reversal increases. This proxy scores their estimated positioning on a -3 to +3 scale:
-3 = Max short — all three trend signals bearish. Forced-cover risk is highest.
+3 = Max long — all three trend signals bullish. Forced-liquidation risk is highest.
The score is derived from price relative to 10, 60, and 120-period moving averages.

THE THREE SIGNALS
VEL (Label box) — Score velocity >= 2 points in 2 days + 10 MA break. Early warning. Reduce exposure or prepare to trade.
SHARP (Diamond) — 3 to 7 days at extreme + high velocity + 10 MA reclaim/break. Primary entry. Catches V-shaped reversals.
EXH (Triangle) — 8+ days at extreme + 10 MA reclaim/break. Higher-confidence entry. Slower, but more reliable.

ASYMMETRIC VIX REGIME
The indicator uses different volatility thresholds for longs and shorts:
Long signals require VIX > 20. You need fear to create a vacuum for short-covering to explode.
Short signals require VIX < 18. You need complacency for maximum position sizing and no hedges underneath.
VIX is pulled from daily data regardless of chart timeframe.

BACKGROUND COLORS
Orange = 3+ days at +/-3 (early crowding alert)
Gold = 8+ days at +/-3 (maximum exhaustion)

HOW TO TRADE IT
For Longs (Bullish Reversal):
Wait for score to hit -3 (background turns orange).
Confirm VIX > 20 (table shows PASS).
Enter on SHARP diamond (aggressive) or EXH triangle (conservative).
Stop below the 10-period MA.
For Shorts (Bearish Reversal):
Wait for score to hit +3 (background turns orange).
Confirm VIX < 18 (table shows PASS).
Enter on SHARP diamond (aggressive) or EXH triangle (conservative).
Stop above the 10-period MA.

RECOMMENDED SETTINGS & CHARTS
Apply this to ES1! (E-mini S&P 500) for equity positioning, ZN1! (10Y Treasury futures) for bond flows, or GC1! (Gold) for commodity positioning. Use daily or 4h timeframes for cleanest signals.

Default inputs:
Fast MA: 10
Medium MA: 60
Slow MA: 120
Sharp threshold: 3 days
Slow threshold: 8 days
VIX long min: 20
VIX short max: 18

DISCLAIMER
This is a proxy model based on estimated systematic positioning, not actual CTA order flow. Signals are probabilistic, not predictive. Always use risk management and confirm with price action before trading.

## Source Code

````pine
//@version=6
indicator("CTA Exhaustion Proxy — Asymmetric VIX", shorttitle="CTA AsymVIX", overlay=false)

// ═════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════════════════════════════════

fastLength    = input.int(10,  "Fast MA",   minval=5,  maxval=50,  group="Trend Inputs")
mediumLength  = input.int(60,  "Medium MA", minval=20, maxval=100, group="Trend Inputs")
slowLength    = input.int(120, "Slow MA",   minval=50, maxval=250, group="Trend Inputs")

maType        = input.string("SMA", "MA Type", options=["SMA", "EMA", "HMA"], group="Calculation")
src           = input.source(close, "Source", group="Calculation")

extremeDays       = input.int(8,  "Slow Threshold (Days)",    minval=3, maxval=30, group="Signal Filters")
sharpExtremeDays  = input.int(3,  "Sharp V Threshold (Days)", minval=2, maxval=10, group="Signal Filters")

vixLongMin   = input.int(20, "VIX Min for LONG Signals",  minval=10, maxval=40, group="VIX Filters")
vixShortMax  = input.int(18, "VIX Max for SHORT Signals", minval=10, maxval=40, group="VIX Filters")
useVixFilter = input.bool(true, "Use VIX Filters?", group="VIX Filters")

requireStrongCandle = input.bool(true, "Require Strong Reversal Candle?", group="Sharp V Filters")
minBodyPct          = input.float(0.55, "Min Bullish Body %", minval=0.3, maxval=0.9, step=0.05, group="Sharp V Filters")

// ═════════════════════════════════════════════════════════════════════════════
// CORE CTA SCORE
// ═════════════════════════════════════════════════════════════════════════════

ma(type, source, length) =>
    switch type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "HMA" => ta.hma(source, length)
        => ta.sma(source, length)

fastMA   = ma(maType, src, fastLength)
mediumMA = ma(maType, src, mediumLength)
slowMA   = ma(maType, src, slowLength)

fastScore   = src > fastMA ? 1 : -1
mediumScore = src > mediumMA ? 1 : -1
slowScore   = src > slowMA ? 1 : -1

score = fastScore + mediumScore + slowScore
scorePct = (score / 3) * 100

// ═════════════════════════════════════════════════════════════════════════════
// CROWDING & VELOCITY
// ═════════════════════════════════════════════════════════════════════════════

var int daysAtExtreme = 0
if score == 3 or score == -3
    daysAtExtreme += 1
else
    daysAtExtreme := 0

velocity = score - score[2]

// ═════════════════════════════════════════════════════════════════════════════
// CANDLE STRENGTH
// ═════════════════════════════════════════════════════════════════════════════

barRange = high - low
body = math.abs(close - open)
bullishBody = close > open ? body / barRange : 0
bearishBody = close < open ? body / barRange : 0

strongBull = bullishBody >= minBodyPct and barRange > 0
strongBear = bearishBody >= minBodyPct and barRange > 0

// ═════════════════════════════════════════════════════════════════════════════
// ASYMMETRIC VIX REGIME — FORCED DAILY RESOLUTION
// ═════════════════════════════════════════════════════════════════════════════

// CRITICAL FIX: Request VIX on daily timeframe only. Intraday bars cause stale reads.
vixDaily = request.security("TVC:VIX", "D", close, lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)

// Fallback: if TVC:VIX fails, try VIX futures front month
vixFuture = request.security("VX1!", "D", close, lookahead=barmerge.lookahead_on, gaps=barmerge.gaps_off)
vix = na(vixDaily) and not na(vixFuture) ? vixFuture : vixDaily

// Asymmetric filters
vixLongOk  = useVixFilter ? vix > vixLongMin : true
vixShortOk = useVixFilter ? vix < vixShortMax : true

// ═════════════════════════════════════════════════════════════════════════════
// ACTIONABLE SIGNALS
// ═════════════════════════════════════════════════════════════════════════════

wasMaxShort    = score[1] == -3
wasMaxLong     = score[1] == 3
wasRecentShort = score[1] == -3 or score[2] == -3
wasRecentLong  = score[1] == 3 or score[2] == 3
slowCrowded    = daysAtExtreme[1] >= extremeDays
sharpCrowded   = daysAtExtreme[1] >= sharpExtremeDays and daysAtExtreme[1] < extremeDays
reclaimUp      = close > fastMA and close[1] <= fastMA[1]
reclaimDown    = close < fastMA and close[1] >= fastMA[1]
fastCover      = velocity >= 2
fastSell       = velocity <= -2

// LONG signals: need elevated VIX
slowLong  = wasMaxShort and slowCrowded and reclaimUp and vixLongOk
sharpLong = wasRecentShort and sharpCrowded and fastCover and reclaimUp and (not requireStrongCandle or strongBull) and vixLongOk
velLong   = score[1] <= -2 and fastCover and reclaimUp and vixLongOk

// SHORT signals: need low VIX
slowShort  = wasMaxLong and slowCrowded and reclaimDown and vixShortOk
sharpShort = wasRecentLong and sharpCrowded and fastSell and reclaimDown and (not requireStrongCandle or strongBear) and vixShortOk
velShort   = score[1] >= 2 and fastSell and reclaimDown and vixShortOk

// ═════════════════════════════════════════════════════════════════════════════
// PLOTTING
// ═════════════════════════════════════════════════════════════════════════════

plotColor = switch score
    3  => color.new(#26a69a, 0)
    2  => color.new(#66bb6a, 0)
    1  => color.new(#a5d6a7, 0)
    0  => color.new(#bdbdbd, 0)
    -1 => color.new(#ef9a9a, 0)
    -2 => color.new(#ef5350, 0)
    -3  => color.new(#c62828, 0)
    => color.new(#9e9e9e, 0)

plot(scorePct, "CTA Score", color=plotColor, linewidth=2, style=plot.style_line)

hline(0,   "Neutral",    color=color.new(#757575, 50), linestyle=hline.style_dashed)
hline(100, "Max Long",   color=color.new(#26a69a, 70), linestyle=hline.style_dotted)
hline(-100,"Max Short",  color=color.new(#c62828, 70), linestyle=hline.style_dotted)

crowdingEarly = daysAtExtreme >= sharpExtremeDays and daysAtExtreme < extremeDays and math.abs(score) == 3
crowdingMax   = daysAtExtreme >= extremeDays and math.abs(score) == 3

bgcolor(crowdingEarly ? color.new(#ff9800, 85) : na, title="Sharp Crowding (3+ Days)")
bgcolor(crowdingMax ? color.new(#ffd700, 80) : na, title="Max Crowding (8+ Days)")

// ═════════════════════════════════════════════════════════════════════════════
// SIGNAL MARKERS
// ═════════════════════════════════════════════════════════════════════════════

plotshape(slowLong,  title="Slow Exhaustion Long",  style=shape.triangleup,   location=location.bottom, color=color.new(#00ff00, 0), size=size.normal, text="EXH", textcolor=color.black)
plotshape(slowShort, title="Slow Exhaustion Short", style=shape.triangledown, location=location.top,    color=color.new(#ff0000, 0), size=size.normal, text="EXH", textcolor=color.white)

plotshape(sharpLong,  title="Sharp V Long",  style=shape.diamond, location=location.bottom, color=color.new(#00bcd4, 0), size=size.normal, text="SHARP", textcolor=color.black)
plotshape(sharpShort, title="Sharp V Short", style=shape.diamond, location=location.top,    color=color.new(#ff5722, 0), size=size.normal, text="SHARP", textcolor=color.white)

plotshape(velLong,  title="Velocity Cover",  style=shape.labelup,   location=location.bottom, color=color.new(#26a69a, 0), size=size.small, text="VEL", textcolor=color.white)
plotshape(velShort, title="Velocity Sell",   style=shape.labeldown, location=location.top,    color=color.new(#c62828, 0), size=size.small, text="VEL", textcolor=color.white)

// ═════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════════════════════════════════

alertcondition(slowLong,   title="CTA Slow Long",    message="CTA: Slow exhaustion LONG. Elevated VIX bounce.")
alertcondition(slowShort,  title="CTA Slow Short",   message="CTA: Slow exhaustion SHORT. Low VIX breakdown.")
alertcondition(sharpLong,  title="CTA Sharp V Long", message="CTA: SHARP V LONG. Rapid covering in fear.")
alertcondition(sharpShort, title="CTA Sharp V Short",message="CTA: SHARP V SHORT. Rapid selling in complacency.")

// ═════════════════════════════════════════════════════════════════════════════
// INFO PANEL
// ═════════════════════════════════════════════════════════════════════════════

var infoPanel = table.new(position.top_left, 2, 9, bgcolor=color.new(#1a1d29, 10), frame_color=color.new(#616161, 0), frame_width=1)
if barstate.islast
    table.cell(infoPanel, 0, 0, "CTA Signal",     text_color=color.new(#ffffff, 0), text_size=size.small)
    table.cell(infoPanel, 1, 0, str.tostring(score) + "/3", text_color=plotColor, text_size=size.small)
    
    table.cell(infoPanel, 0, 1, "Days Extreme",   text_color=color.new(#bdbdbd, 0), text_size=size.tiny)
    table.cell(infoPanel, 1, 1, str.tostring(daysAtExtreme), text_color=daysAtExtreme >= sharpExtremeDays ? color.new(#ffd700, 0) : color.new(#bdbdbd, 0), text_size=size.tiny)
    
    table.cell(infoPanel, 0, 2, "2D Velocity",    text_color=color.new(#bdbdbd, 0), text_size=size.tiny)
    table.cell(infoPanel, 1, 2, str.tostring(velocity), text_color=math.abs(velocity) >= 2 ? color.new(#00bcd4, 0) : color.new(#bdbdbd, 0), text_size=size.tiny)
    
    table.cell(infoPanel, 0, 3, "VIX (Daily)",    text_color=color.new(#bdbdbd, 0), text_size=size.tiny)
    table.cell(infoPanel, 1, 3, str.tostring(vix, "#.#"), text_color=color.new(#ffffff, 0), text_size=size.tiny)
    
    table.cell(infoPanel, 0, 4, "VIX Long OK",    text_color=color.new(#bdbdbd, 0), text_size=size.tiny)
    table.cell(infoPanel, 1, 4, vixLongOk ? "PASS (>20)" : "FAIL", text_color=vixLongOk ? color.new(#66bb6a, 0) : color.new(#ef5350, 0), text_size=size.tiny)
    
    table.cell(infoPanel, 0, 5, "VIX Short OK",   text_color=color.new(#bdbdbd, 0), text_size=size.tiny)
    table.cell(infoPanel, 1, 5, vixShortOk ? "PASS (<18)" : "FAIL", text_color=vixShortOk ? color.new(#ef5350, 0) : color.new(#66bb6a, 0), text_size=size.tiny)
    
    statusText = switch score
        3  => "MAX LONG"
        2  => "STRONG LONG"
        1  => "WEAK LONG"
        0  => "NEUTRAL"
        -1 => "WEAK SHORT"
        -2 => "STRONG SHORT"
        -3 => "MAX SHORT"
        => "N/A"
    
    table.cell(infoPanel, 0, 6, "Positioning",    text_color=color.new(#bdbdbd, 0), text_size=size.tiny)
    table.cell(infoPanel, 1, 6, statusText,       text_color=plotColor, text_size=size.tiny)
    
    sharpReady = daysAtExtreme >= sharpExtremeDays and daysAtExtreme < extremeDays and math.abs(score) == 3
    slowReady  = daysAtExtreme >= extremeDays and math.abs(score) == 3
    nextSignal = sharpReady ? "SHARP: Watch 10 MA" : slowReady ? "SLOW: Watch 10 MA" : "None"
    
    table.cell(infoPanel, 0, 7, "Setup",          text_color=color.new(#bdbdbd, 0), text_size=size.tiny)
    table.cell(infoPanel, 1, 7, nextSignal,       text_color=sharpReady ? color.new(#00bcd4, 0) : slowReady ? color.new(#ffd700, 0) : color.new(#bdbdbd, 0), text_size=size.tiny)
    
    table.cell(infoPanel, 0, 8, "Body %",         text_color=color.new(#bdbdbd, 0), text_size=size.tiny)
    table.cell(infoPanel, 1, 8, str.tostring(bullishBody, "#.#%"), text_color=strongBull ? color.new(#66bb6a, 0) : color.new(#bdbdbd, 0), text_size=size.tiny)
````
