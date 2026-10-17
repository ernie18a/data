# 9 & 15 EMA Strategy [Trade Room]

- url: https://www.tradingview.com/script/ESTlGabj-9-15-EMA-Strategy-Trade-Room/
- type: indicator
- pine_id: PUB;60f083efc6284a0c9e374d6c63c11cf0
- version: 1.0

## Description

OVERVIEW

This indicator combines a fast/slow EMA crossover (default 9 and 15) with a 
trend-slope filter and price-action candle confirmation to generate long and 
short signals, along with automatically calculated take-profit and stop-loss 
levels based on a user-defined risk:reward ratio.

The EMA 9/15 crossover is a long-standing, widely taught trend-following 
concept in retail trading education. This script is my own original 
implementation of that concept, built with additional filters to reduce 
false signals in choppy conditions.

HOW IT WORKS

1. Trend filter: the script checks whether the fast EMA is above or below 
   the slow EMA to establish bullish or bearish bias.
2. Slope filter (optional): both EMAs must be sloping steeply enough, 
   measured as percentage change over a short lookback, to confirm the 
   move has real momentum rather than chopping sideways. This is adjustable 
   so it can be tuned per instrument and timeframe.
3. Price action filter (optional): a signal only fires when price pulls 
   back to the fast EMA and the resulting candle matches one of three 
   patterns — pin bar, engulfing, or an above-average range "big bar" — 
   in the direction of the trend.
4. TP/SL: stop-loss is placed at the signal candle's high/low, and take-
   profit is calculated as a multiple of that risk distance, set by the 
   Risk:Reward input (default 1:2).

WHY IT'S USEFUL

Most EMA crossover scripts only plot crossovers, leaving the trader to 
manually judge trend strength and risk levels. This script adds an 
objective slope threshold and candle-pattern confirmation layer on top of 
the crossover, and automatically plots calculated TP/SL levels so risk 
is defined before entry, not after.

SETTINGS

- Fast/Slow EMA length — fully adjustable, not fixed to 9/15
- Slope filter toggle and threshold — tune sensitivity per asset/timeframe
- Candle pattern filter toggle
- Risk:Reward ratio for TP calculation
- Independent show/hide toggles for EMAs, labels, TP, and SL
- Alert conditions for both signal types

LIMITATIONS

Like any trend-following tool, this indicator will produce false signals 
in ranging or low-volatility conditions. The slope filter is designed to 
reduce — not eliminate — this. No indicator predicts price; this is a 
decision-support tool, not financial advice, and past signal behavior is 
not indicative of future results. Always backtest on your specific 
instrument and timeframe and use proper risk management.

## Source Code

````pine
// ============================================================
// 9 & 15 EMA Strategy Indicator — The Trade Room Style
// Pine Script v6
// Includes: Buy/Sell signals, TP & SL labels, adjustable settings
// ============================================================

//@version=6
indicator(title="9 & 15 EMA Strategy [Trade Room]", shorttitle="9/15 EMA Strategy", overlay=true)

// ============================================================
// ── INPUTS ──────────────────────────────────────────────────
// ============================================================

// EMA Settings
emaFastLen   = input.int(9,   title="Fast EMA Length",   group="EMA Settings", minval=1)
emaSlowLen   = input.int(15,  title="Slow EMA Length",   group="EMA Settings", minval=1)

// Angle / Slope Filter
useAngle     = input.bool(true,  title="Enable Slope Filter (30° Rule)", group="Slope Filter")
minSlope     = input.float(0.3,  title="Min Slope Threshold (adjust per asset)", group="Slope Filter", step=0.05, tooltip="Higher = steeper trend required. For crypto, try 0.2–0.5. For indices, try 0.1–0.3.")

// Risk/Reward
rrRatio      = input.float(2.0, title="Risk:Reward Ratio (TP multiplier)", group="Risk & Reward", minval=0.5, step=0.5)

// Candle Filter
useCandleFilter = input.bool(true, title="Enable Candle Type Filter", group="Candle Filter", tooltip="Only signals with Pin Bar, Engulfing or Big Bar candles at the EMA")

// Signal Display
showLabels   = input.bool(true,  title="Show BUY / SELL Labels",    group="Display")
showTP       = input.bool(true,  title="Show Take Profit Labels",    group="Display")
showSL       = input.bool(true,  title="Show Stop Loss Labels",      group="Display")
showEMAs     = input.bool(true,  title="Show EMA Lines",             group="Display")

// Alert
alertOn      = input.bool(true, title="Enable Alerts", group="Alerts")

// ============================================================
// ── EMA CALCULATIONS ────────────────────────────────────────
// ============================================================

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// ── Slope Calculation ──
// Slope = difference between current EMA and EMA N bars ago, normalised
slopeLen = 3
fastSlope = math.abs(emaFast - emaFast[slopeLen]) / emaFast[slopeLen] * 100
slowSlope = math.abs(emaSlow - emaSlow[slopeLen]) / emaSlow[slopeLen] * 100

slopeOK = useAngle ? (fastSlope >= minSlope and slowSlope >= minSlope) : true

// ── Trend Direction ──
bullTrend = emaFast > emaSlow
bearTrend = emaFast < emaSlow

// ============================================================
// ── CANDLE TYPE DETECTION ───────────────────────────────────
// ============================================================

candleBody   = math.abs(close - open)
candleRange  = high - low
upperWick    = high - math.max(close, open)
lowerWick    = math.min(close, open) - low

// Pin Bar (bullish) — long lower wick, small body at top
bullPinBar = lowerWick > (candleBody * 2.0) and lowerWick > (upperWick * 1.5)

// Pin Bar (bearish) — long upper wick, small body at bottom
bearPinBar = upperWick > (candleBody * 2.0) and upperWick > (lowerWick * 1.5)

// Engulfing (bullish) — current green candle body > prev red candle body
bullEngulf = close > open and open < close[1] and close > open[1] and (close[1] < open[1])

// Engulfing (bearish)
bearEngulf = close < open and open > close[1] and close < open[1] and (close[1] > open[1])

// Big Bar — large candle range relative to recent average
avgRange    = ta.sma(candleRange, 10)
bigBar      = candleRange > avgRange * 1.5

bullCandle  = useCandleFilter ? (bullPinBar or bullEngulf or (bigBar and close > open)) : (close > open)
bearCandle  = useCandleFilter ? (bearPinBar or bearEngulf or (bigBar and close < open)) : (close < open)

// ============================================================
// ── SIGNAL CONDITIONS ───────────────────────────────────────
// ============================================================

// Price pulled back to touch EMA 9, now reclaiming
touchedFastBull = low <= emaFast and close > emaFast
touchedFastBear = high >= emaFast and close < emaFast

// Full Buy Condition:
// 1) Bull trend (EMA9 > EMA15)
// 2) Slope steep enough
// 3) Price touched / bounced off EMA9
// 4) Valid candle pattern
buySignal  = bullTrend and slopeOK and touchedFastBull and bullCandle

// Full Sell Condition:
sellSignal = bearTrend and slopeOK and touchedFastBear and bearCandle

// ============================================================
// ── TP & SL CALCULATION ─────────────────────────────────────
// ============================================================

// SL = candle low/high (as per Trade Room rules)
buySL  = low
buySLDist = close - buySL
buyTP  = close + (buySLDist * rrRatio)

sellSL    = high
sellSLDist = sellSL - close
sellTP    = close - (sellSLDist * rrRatio)

// ============================================================
// ── PLOTS ───────────────────────────────────────────────────
// ============================================================

// EMA Lines
plot(showEMAs ? emaFast : na, title="EMA 9",  color=color.new(color.yellow, 0), linewidth=2)
plot(showEMAs ? emaSlow : na, title="EMA 15", color=color.new(color.orange, 0), linewidth=2)

// EMA fill (trend shading)
emaFastPlot = plot(showEMAs ? emaFast : na, editable=false, display=display.none)
emaSlowPlot = plot(showEMAs ? emaSlow : na, editable=false, display=display.none)
fill(emaFastPlot, emaSlowPlot,
     color = bullTrend ? color.new(color.green, 88) : color.new(color.red, 88),
     title = "EMA Cloud")

// ── Buy Signal ──
plotshape(buySignal and showLabels,
     title="BUY Signal",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(color.green, 0),
     textcolor=color.white,
     text="BUY",
     size=size.normal)

// ── Sell Signal ──
plotshape(sellSignal and showLabels,
     title="SELL Signal",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(color.red, 0),
     textcolor=color.white,
     text="SELL",
     size=size.normal)

// ── TP Labels ──
if buySignal and showTP
    label.new(bar_index, buyTP,
         text="TP: " + str.tostring(math.round(buyTP, 4)),
         color=color.new(color.green, 20),
         textcolor=color.white,
         style=label.style_label_left,
         size=size.small)

if sellSignal and showTP
    label.new(bar_index, sellTP,
         text="TP: " + str.tostring(math.round(sellTP, 4)),
         color=color.new(color.green, 20),
         textcolor=color.white,
         style=label.style_label_left,
         size=size.small)

// ── SL Labels ──
if buySignal and showSL
    label.new(bar_index, buySL,
         text="SL: " + str.tostring(math.round(buySL, 4)),
         color=color.new(color.red, 20),
         textcolor=color.white,
         style=label.style_label_left,
         size=size.small)

if sellSignal and showSL
    label.new(bar_index, sellSL,
         text="SL: " + str.tostring(math.round(sellSL, 4)),
         color=color.new(color.red, 20),
         textcolor=color.white,
         style=label.style_label_left,
         size=size.small)

// ============================================================
// ── ALERTS ──────────────────────────────────────────────────
// ============================================================

if alertOn
    if buySignal
        alert("9/15 EMA BUY Signal on " + syminfo.ticker + " | TF: " + timeframe.period, alert.freq_once_per_bar)
    if sellSignal
        alert("9/15 EMA SELL Signal on " + syminfo.ticker + " | TF: " + timeframe.period, alert.freq_once_per_bar)

// ============================================================
// ── INFO TABLE ──────────────────────────────────────────────
// ============================================================

var table infoTable = table.new(position.top_right, 2, 5,
     bgcolor=color.new(color.black, 70),
     border_color=color.new(color.gray, 50),
     border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "Indicator",   text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 1, 0, "9/15 EMA",    text_color=color.white, text_size=size.small)
    table.cell(infoTable, 0, 1, "Trend",        text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 1, 1, bullTrend ? "BULLISH ▲" : "BEARISH ▼",
         text_color = bullTrend ? color.green : color.red,
         text_size=size.small)
    table.cell(infoTable, 0, 2, "Slope OK",     text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 1, 2, slopeOK ? "✓ YES" : "✗ NO",
         text_color = slopeOK ? color.green : color.red,
         text_size=size.small)
    table.cell(infoTable, 0, 3, "EMA Fast",     text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(math.round(emaFast, 4)),
         text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 0, 4, "EMA Slow",     text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 1, 4, str.tostring(math.round(emaSlow, 4)),
         text_color=color.orange, text_size=size.small)
````
