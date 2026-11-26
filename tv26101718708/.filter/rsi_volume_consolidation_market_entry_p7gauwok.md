# RSI + Volume + Consolidation + Market Entry

- url: https://www.tradingview.com/script/P7gauWoK-RSI-Volume-Consolidation-Market-Entry/
- type: indicator
- pine_id: PUB;76f9a3ea6d7c4f18b98c9ffb2302c979
- version: 1.0

## Description

The script scores each bar across 6 conditions — RSI quality, RSI momentum (rising), volume confirmation, consolidation pattern, stock trend, and market direction. A "Strong Buy" signal only fires when all 6 align.
The three signal tiers:

🟢 Strong Buy — lime arrow below the bar — all conditions fully met, including market tailwind. This is your actionable entry.
🟡 Early Setup — yellow triangle — most conditions aligned, good to have on your watchlist. May be missing volume or market alignment.
🔵 Watch — small aqua dot — consolidating with good RSI but not quite ready.

The live dashboard (top-right of chart) shows each condition's status in real time with green/yellow/red so you can see exactly which factor is missing.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("RSI + Volume + Consolidation + Market Entry", overlay = true, max_lines_count = 200, max_labels_count = 200)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────

rsiLen        = input.int(14,    "RSI Length",                       group = "RSI Settings")
rsiOversold   = input.float(40,  "RSI Oversold Level",               group = "RSI Settings", minval = 20, maxval = 50)
rsiGoodMin    = input.float(40,  "RSI Good Zone Min",                group = "RSI Settings", minval = 30, maxval = 60)
rsiGoodMax    = input.float(60,  "RSI Good Zone Max",                group = "RSI Settings", minval = 50, maxval = 80)

volLen        = input.int(20,    "Volume MA Length",                 group = "Volume Settings")
volMult       = input.float(1.2, "Volume Spike Multiplier (x Avg)",  group = "Volume Settings", minval = 1.0, step = 0.1)
volLookback   = input.int(3,     "Volume Confirmation Bars Back",    group = "Volume Settings", minval = 1, maxval = 10)

consLen       = input.int(10,    "Consolidation Lookback",           group = "Consolidation")
consRangePct  = input.float(3.0, "Max Range % for Consolidation",    group = "Consolidation", minval = 0.5, step = 0.5)
consBarsMin   = input.int(5,     "Min Bars in Consolidation",        group = "Consolidation", minval = 3, maxval = 20)

emaFastLen    = input.int(20,    "EMA Fast",                         group = "Trend & Market")
emaSlowLen    = input.int(50,    "EMA Slow",                         group = "Trend & Market")
ema200Len     = input.int(200,   "EMA Long-Term",                    group = "Trend & Market")
mktSymbol     = input.symbol("SPY", "Market Reference Symbol",       group = "Trend & Market")
useMktFilter  = input.bool(true, "Filter Entries by Market Direction",group = "Trend & Market")

showEmas      = input.bool(true,  "Show EMA Lines",                  group = "Display")
showConsBands = input.bool(true,  "Show Consolidation Bands",        group = "Display")
showRsiBg     = input.bool(true,  "Highlight Setup Zone Bars",       group = "Display")

// ─────────────────────────────────────────────
//  RSI
// ─────────────────────────────────────────────

rsiVal      = ta.rsi(close, rsiLen)
rsiGood     = rsiVal >= rsiGoodMin and rsiVal <= rsiGoodMax
rsiBullish  = rsiVal > 50 and rsiVal <= rsiGoodMax
rsiRecovery = rsiVal >= rsiOversold and rsiVal < 55
rsiRising   = rsiVal > rsiVal[1] and rsiVal[1] > rsiVal[2]

// ─────────────────────────────────────────────
//  VOLUME
// ─────────────────────────────────────────────

volAvg = ta.sma(volume, volLen)

recentSpike = false
for i = 0 to volLookback - 1
    if volume[i] > volAvg[i] * volMult
        recentSpike := true

volIncreasing = ta.sma(volume, 3) > ta.sma(volume, 8)
goodVolume    = recentSpike or (volume > volAvg and volIncreasing)

// ─────────────────────────────────────────────
//  CONSOLIDATION
// ─────────────────────────────────────────────

highestHigh = ta.highest(high, consLen)
lowestLow   = ta.lowest(low,  consLen)
rangeSize   = highestHigh - lowestLow
rangePct    = rangeSize / lowestLow * 100
tightRange  = rangePct <= consRangePct

var int consBars = 0
consBars := tightRange ? consBars + 1 : 0

inConsolidation = consBars >= consBarsMin
consTop         = highestHigh
consBottom      = lowestLow
consMid         = (consTop + consBottom) / 2
nearBreakout    = close > consMid and close <= consTop * 1.005

// ─────────────────────────────────────────────
//  MARKET DIRECTION
// ─────────────────────────────────────────────

mktClose    = request.security(mktSymbol, timeframe.period, close)
mktEmaFast  = ta.ema(mktClose, emaFastLen)
mktEmaSlow  = ta.ema(mktClose, emaSlowLen)
mktEma200   = ta.ema(mktClose, ema200Len)
mktBullish  = mktEmaFast > mktEmaSlow and mktClose > mktEma200
mktNeutral  = mktEmaFast > mktEmaSlow
mktFilter   = useMktFilter ? mktBullish : true

// ─────────────────────────────────────────────
//  STOCK TREND EMAs
// ─────────────────────────────────────────────

emaFast  = ta.ema(close, emaFastLen)
emaSlow  = ta.ema(close, emaSlowLen)
ema200   = ta.ema(close, ema200Len)

stockBullish   = emaFast > emaSlow and close > ema200
stockShortBull = close > emaFast and emaFast > emaSlow

plot(showEmas ? emaFast : na, "EMA 20",  color = color.new(color.orange, 0), linewidth = 1)
plot(showEmas ? emaSlow : na, "EMA 50",  color = color.new(color.blue,   0), linewidth = 1)
plot(showEmas ? ema200  : na, "EMA 200", color = color.new(color.red,   20), linewidth = 2)

// ─────────────────────────────────────────────
//  SIGNALS
// ─────────────────────────────────────────────

strongBuy  = (rsiGood or rsiBullish) and rsiRising and goodVolume and inConsolidation and nearBreakout and stockShortBull and mktFilter
earlySetup = (rsiGood or rsiRecovery) and goodVolume and inConsolidation and (stockBullish or stockShortBull) and not strongBuy
watchSetup = inConsolidation and (rsiGood or rsiBullish) and rsiRising and stockShortBull and not strongBuy and not earlySetup

// ─────────────────────────────────────────────
//  SCORE
// ─────────────────────────────────────────────

score = 0
score := score + ((rsiGood or rsiBullish) ? 1 : 0)
score := score + (rsiRising               ? 1 : 0)
score := score + (goodVolume              ? 1 : 0)
score := score + (inConsolidation         ? 1 : 0)
score := score + (stockShortBull          ? 1 : 0)
score := score + (mktBullish              ? 1 : 0)

// ─────────────────────────────────────────────
//  SHAPES
// ─────────────────────────────────────────────

plotshape(strongBuy,  title = "Strong Buy",   style = shape.labelup,    location = location.belowbar, color = color.new(color.lime,   0),  textcolor = color.black, text = "BUY",   size = size.normal)
plotshape(earlySetup, title = "Early Setup",  style = shape.triangleup, location = location.belowbar, color = color.new(color.yellow, 20), textcolor = color.black, text = "SETUP", size = size.small)
plotshape(watchSetup, title = "Watch",        style = shape.circle,     location = location.belowbar, color = color.new(color.aqua,   40),                          size = size.tiny)

// ─────────────────────────────────────────────
//  CONSOLIDATION BANDS
// ─────────────────────────────────────────────

upperBand = plot(showConsBands and inConsolidation ? consTop    : na, "Cons High", color = color.new(color.yellow, 60), linewidth = 1, style = plot.style_stepline)
lowerBand = plot(showConsBands and inConsolidation ? consBottom : na, "Cons Low",  color = color.new(color.yellow, 60), linewidth = 1, style = plot.style_stepline)
fill(upperBand, lowerBand, color = color.new(color.yellow, 90), title = "Consolidation Fill")

// ─────────────────────────────────────────────
//  BUY LABEL WITH SCORE
// ─────────────────────────────────────────────

if strongBuy
    labelTxt = "Score: " + str.tostring(score) + "/6\nRSI: " + str.tostring(math.round(rsiVal, 1)) + "\nVol: " + (goodVolume ? "✓" : "✗") + "\nCons: " + (inConsolidation ? "✓" : "✗") + "\nMkt: " + (mktBullish ? "✓" : "✗")
    label.new(bar_index, low * 0.985, labelTxt, style = label.style_label_up, color = color.new(color.lime, 20), textcolor = color.black, size = size.small)

// ─────────────────────────────────────────────
//  DASHBOARD TABLE
// ─────────────────────────────────────────────

var table dash = table.new(position.top_right, 2, 8, border_width = 1, border_color = color.new(color.gray, 50), bgcolor = color.new(color.black, 20))

colorGreen  = color.new(color.lime,   20)
colorRed    = color.new(color.red,    20)
colorYellow = color.new(color.yellow, 20)
colorGray   = color.new(color.gray,   20)
colorNavy   = color.new(color.navy,    0)

if barstate.islast
    table.cell(dash, 0, 0, "Condition",   bgcolor = colorNavy,  text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 0, "Status",      bgcolor = colorNavy,  text_color = color.white, text_size = size.small)

    rsiClr = (rsiGood or rsiBullish) ? colorGreen : rsiRecovery ? colorYellow : colorRed
    table.cell(dash, 0, 1, "RSI (" + str.tostring(math.round(rsiVal, 1)) + ")", bgcolor = colorGray, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, (rsiGood or rsiBullish) ? "✓ Good" : rsiRecovery ? "~ OK" : "✗ Weak", bgcolor = rsiClr, text_color = color.black, text_size = size.small)

    table.cell(dash, 0, 2, "RSI Rising",    bgcolor = colorGray, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, rsiRising ? "✓ Yes" : "✗ No", bgcolor = rsiRising ? colorGreen : colorRed, text_color = color.black, text_size = size.small)

    table.cell(dash, 0, 3, "Volume",        bgcolor = colorGray, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, goodVolume ? "✓ Good" : "✗ Low", bgcolor = goodVolume ? colorGreen : colorRed, text_color = color.black, text_size = size.small)

    table.cell(dash, 0, 4, "Consolidating", bgcolor = colorGray, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, inConsolidation ? "✓ " + str.tostring(consBars) + " bars" : "✗ No", bgcolor = inConsolidation ? colorGreen : colorRed, text_color = color.black, text_size = size.small)

    table.cell(dash, 0, 5, "Stock Trend",   bgcolor = colorGray, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, stockShortBull ? "✓ Bullish" : "✗ Weak", bgcolor = stockShortBull ? colorGreen : colorRed, text_color = color.black, text_size = size.small)

    mktClr = mktBullish ? colorGreen : mktNeutral ? colorYellow : colorRed
    table.cell(dash, 0, 6, "Market (" + mktSymbol + ")", bgcolor = colorGray, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, mktBullish ? "✓ Bull" : mktNeutral ? "~ Neutral" : "✗ Bear", bgcolor = mktClr, text_color = color.black, text_size = size.small)

    sigTxt = strongBuy ? "BUY SIGNAL" : earlySetup ? "EARLY SETUP" : watchSetup ? "WATCH" : "NO SIGNAL"
    sigClr = strongBuy ? colorGreen  : earlySetup  ? colorYellow  : watchSetup  ? color.new(color.aqua, 20) : colorGray
    table.cell(dash, 0, 7, "Signal (" + str.tostring(score) + "/6)", bgcolor = colorGray, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 7, sigTxt, bgcolor = sigClr, text_color = color.black, text_size = size.small)

// ─────────────────────────────────────────────
//  BAR BACKGROUND
// ─────────────────────────────────────────────

bgcolor(showRsiBg and (rsiGood or rsiBullish) and inConsolidation ? color.new(color.lime, 95) : na, title = "Setup Zone Background")

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────

alertcondition(strongBuy,  "Strong Buy Signal",  "{{ticker}} — Strong Buy: All conditions aligned!")
alertcondition(earlySetup, "Early Setup Signal", "{{ticker}} — Early Setup: Most conditions met, watch for entry")
alertcondition(watchSetup, "Watch Setup",        "{{ticker}} — Watch: Consolidating with good RSI")
````
