# Liquidity Sweep & Stop-Hunt Signals [ForexCracked]

- url: https://www.tradingview.com/script/A87bidB1-Liquidity-Sweep-Stop-Hunt-Signals-ForexCracked/
- type: indicator
- pine_id: PUB;6c5ac1fca37c498a969bce4c65054bc9
- version: 1.0

## Description

🔵 OVERVIEW

Liquidity Sweep & Stop-Hunt Signals marks the price levels where stop orders pile up, detects the moment price runs those stops and reverses, and prints a BUY or SELL with a ready-made entry, stop and target. It is a focused reversal tool built around one of the most reliable behaviours in the market: the failed breakout.

Every signal confirms on candle close, so nothing repaints after the bar is done. A live dashboard shows the higher-timeframe bias, the last signal, and the current trade plan.

🔵 WHAT A LIQUIDITY SWEEP ACTUALLY IS

Stops cluster in obvious places: just above a recent swing high (buy-side liquidity) and just below a recent swing low (sell-side liquidity). Price is often drawn to those pools because that is where resting orders sit.

A sweep, or stop hunt, happens when price spikes through one of those swings, triggers the stops, and then closes back inside the range on the same candle. Breakout traders get trapped, and the reversal that follows is the trade this tool is built to catch.

🔵 HOW IT FINDS SIGNALS

• It tracks recent swing highs and lows as liquidity lines and keeps them on the chart until they are taken

• A SELL fires when a candle's high runs above a tracked swing high but its close falls back below it (buy-side liquidity swept, then rejected)

• A BUY fires when a candle's low runs below a tracked swing low but its close climbs back above it (sell-side liquidity swept, then rejected)

• An optional rejection-body filter ignores weak wicks and only accepts sweeps that close with a real body back inside the level

• An optional higher-timeframe EMA bias lets you take only trend-aligned sweeps, only counter-trend sweeps, or all of them

🔵 THE TRADE PLAN IT DRAWS

On every signal the tool draws three lines and labels them:

• Entry at the close of the sweep candle

• Stop just beyond the swept wick, with an ATR buffer so normal noise does not clip it

• Target at your chosen reward-to-risk multiple of that stop distance

You get a complete plan on the chart the moment a signal prints, with the exact prices in the label.

🔵 SETTINGS

• Swing Strength: how major a swing must be to count as liquidity (higher = fewer, cleaner levels)

• Levels Tracked: how many liquidity lines to keep per side

• Trend Filter: All sweeps, HTF trend only, or Counter-HTF only

• HTF Bias Timeframe and EMA Length: the higher-timeframe trend reference

• Require Rejection Body and Min Rejection Body (x ATR): quality filter for the sweep candle

• Stop Buffer (x ATR) and Reward : Risk: the trade-plan geometry

🔵 HOW TO USE

• Start on H1 or H4 for forex, gold and indices, with the HTF bias set one or two steps higher

• Treat a swept level plus a strong rejection close as the signal, not the wick alone

• Use Counter-HTF only when you want pure reversal setups at range extremes, and HTF trend only when you want continuation entries after a stop-run against the trend

• Size every trade off the drawn stop distance at a fixed account risk

• Raise Swing Strength on noisy pairs so only the meaningful liquidity gets tracked

🔵 BEST AND WEAKEST CONDITIONS

✅ Strongest at range extremes, session highs and lows, and around prior day or week highs and lows, where liquidity genuinely rests

⚠️ Weakest in fast one-way trends with no pullbacks, and on very low timeframes where every wick looks like a sweep

⚠️ DISCLAIMER

This tool identifies liquidity sweeps and marks reversal setups. It does not predict price. A swept level is a probability, not a certainty, and sweeps can extend further before reversing. Results depend on market conditions, settings, and your own execution and risk management. Shared for educational and research purposes; not financial advice.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ForexCracked

//@version=6
indicator("Liquidity Sweep & Stop-Hunt Signals [ForexCracked]", shorttitle="Liq [FXC]", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================================================================
// Liquidity Sweep & Stop-Hunt Signals
// ---------------------------------------------------------------------
// Concept: stop orders cluster just beyond obvious swing highs (buy-side
// liquidity) and swing lows (sell-side liquidity). A "sweep" or stop hunt
// happens when price spikes through one of those swings to trigger the
// stops, then closes back inside the range on the same candle, trapping
// breakout traders. That failed breakout is a classic reversal trigger.
//
// This tool marks swing highs/lows as liquidity lines, detects when one
// is swept AND rejected on the same closed candle, and prints a BUY or
// SELL with a drawn entry, stop and target. Signals confirm on candle
// close, so they do not repaint. Swing pivots confirm after the chosen
// lookback, which is standard for structure tools.
// =====================================================================

// ---------------- INPUTS ----------------
grpS = "Liquidity Detection"
pivotLen  = input.int(15, "Swing Strength", minval = 3, maxval = 50, group = grpS, tooltip = "Higher values keep only major swing highs/lows as liquidity. Each pivot confirms this many bars after it forms.")
maxLevels = input.int(8, "Levels Tracked (per side)", minval = 1, maxval = 20, group = grpS)
showLiq   = input.bool(true, "Show Liquidity Lines", group = grpS)

grpF = "Signal Filters"
mode    = input.string("All sweeps", "Trend Filter", options = ["All sweeps", "HTF trend only", "Counter-HTF only"], group = grpF, tooltip = "Filter signals by the higher-timeframe EMA bias.")
htfTf   = input.timeframe("240", "HTF Bias Timeframe", group = grpF)
htfLen  = input.int(50, "HTF EMA Length", minval = 5, group = grpF)
useBody = input.bool(true, "Require Rejection Body", group = grpF, tooltip = "Only signal when the sweep candle closes with a real body back inside the level.")
minBody = input.float(0.25, "Min Rejection Body (x ATR)", minval = 0.0, step = 0.05, group = grpF)

grpR = "Trade Plan"
slBuf    = input.float(0.5, "Stop Buffer (x ATR)", minval = 0.0, step = 0.1, group = grpR)
rr       = input.float(2.0, "Reward : Risk", minval = 0.5, step = 0.5, group = grpR)
showPlan = input.bool(true, "Show Entry / Stop / Target", group = grpR)

grpV = "Visuals"
showSignals = input.bool(true, "Show BUY / SELL Labels", group = grpV)
showDash    = input.bool(true, "Show Dashboard", group = grpV)
bullCol     = input.color(#26a69a, "Bullish", group = grpV)
bearCol     = input.color(#ef5350, "Bearish", group = grpV)
liqCol      = input.color(#787b86, "Liquidity Line", group = grpV)

alertsInfo = input.bool(true, "Enable Alerts", group = "Alerts")

// ---------------- CORE CALCS ----------------
atr      = ta.atr(14)
htfEma   = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfLen))
biasBull = close > htfEma
biasBear = close < htfEma

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var array<float> bslPrice = array.new<float>()
var array<line>  bslLine  = array.new<line>()
var array<float> sslPrice = array.new<float>()
var array<line>  sslLine  = array.new<line>()

// register a new swing high as buy-side liquidity
if not na(ph)
    ln = showLiq ? line.new(bar_index - pivotLen, ph, bar_index, ph, color = color.new(liqCol, 0), width = 1, style = line.style_dotted) : na
    array.push(bslPrice, ph)
    array.push(bslLine, ln)
    if array.size(bslPrice) > maxLevels
        array.shift(bslPrice)
        old = array.shift(bslLine)
        if not na(old)
            line.delete(old)

// register a new swing low as sell-side liquidity
if not na(pl)
    ln = showLiq ? line.new(bar_index - pivotLen, pl, bar_index, pl, color = color.new(liqCol, 0), width = 1, style = line.style_dotted) : na
    array.push(sslPrice, pl)
    array.push(sslLine, ln)
    if array.size(sslPrice) > maxLevels
        array.shift(sslPrice)
        old = array.shift(sslLine)
        if not na(old)
            line.delete(old)

// keep active liquidity lines extended to the current bar
// Pine's `for a to b` counts DOWN when b < a, so `0 to -1` still runs once with
// i = 0. The size guards are required or an empty array throws on bar 0.
if showLiq
    if array.size(bslLine) > 0
        for i = 0 to array.size(bslLine) - 1
            l = array.get(bslLine, i)
            if not na(l)
                line.set_x2(l, bar_index)
    if array.size(sslLine) > 0
        for i = 0 to array.size(sslLine) - 1
            l = array.get(sslLine, i)
            if not na(l)
                line.set_x2(l, bar_index)

// ---------------- SWEEP DETECTION (closed bars only, non-repaint) ----------------
bearSweep = false
bullSweep = false
float sweptHigh = na
float sweptLow  = na

if barstate.isconfirmed
    // buy-side: high runs a swing high, then close falls back below it
    j = 0
    while j < array.size(bslPrice)
        lvl = array.get(bslPrice, j)
        if high > lvl and close < lvl
            bearSweep := true
            sweptHigh := na(sweptHigh) ? lvl : math.max(sweptHigh, lvl)
            l = array.get(bslLine, j)
            if not na(l)
                line.delete(l)
            array.remove(bslPrice, j)
            array.remove(bslLine, j)
        else
            j += 1
    // sell-side: low runs a swing low, then close climbs back above it
    k = 0
    while k < array.size(sslPrice)
        lvl = array.get(sslPrice, k)
        if low < lvl and close > lvl
            bullSweep := true
            sweptLow := na(sweptLow) ? lvl : math.min(sweptLow, lvl)
            l = array.get(sslLine, k)
            if not na(l)
                line.delete(l)
            array.remove(sslPrice, k)
            array.remove(sslLine, k)
        else
            k += 1

// ---------------- FILTERS ----------------
body   = math.abs(close - open)
bodyOk = not useBody or body >= minBody * atr

sellOk = mode == "All sweeps" or (mode == "HTF trend only" and biasBear) or (mode == "Counter-HTF only" and biasBull)
buyOk  = mode == "All sweeps" or (mode == "HTF trend only" and biasBull) or (mode == "Counter-HTF only" and biasBear)

sell = bearSweep and bodyOk and sellOk
buy  = bullSweep and bodyOk and buyOk

// ---------------- TRADE PLAN + SIGNAL STATE ----------------
var line   eLine   = na
var line   sLine   = na
var line   tLine   = na
var label  planLb  = na
var string lastSig = "None"
var float  pEntry  = na

if buy or sell
    lastSig := buy ? "BUY" : "SELL"
    if showPlan
        if not na(eLine)
            line.delete(eLine)
        if not na(sLine)
            line.delete(sLine)
        if not na(tLine)
            line.delete(tLine)
        if not na(planLb)
            label.delete(planLb)
        entry = close
        stop  = buy ? (na(sweptLow) ? low : math.min(sweptLow, low)) - slBuf * atr : (na(sweptHigh) ? high : math.max(sweptHigh, high)) + slBuf * atr
        risk  = math.abs(entry - stop)
        tgt   = buy ? entry + risk * rr : entry - risk * rr
        col   = buy ? bullCol : bearCol
        x2    = bar_index + 20
        eLine  := line.new(bar_index, entry, x2, entry, color = color.gray, width = 1, style = line.style_dashed)
        sLine  := line.new(bar_index, stop,  x2, stop,  color = bearCol, width = 1)
        tLine  := line.new(bar_index, tgt,   x2, tgt,   color = bullCol, width = 1)
        planLb := label.new(x2, entry, (buy ? "BUY" : "SELL") + "  E " + str.tostring(entry, format.mintick) + "  SL " + str.tostring(stop, format.mintick) + "  TP " + str.tostring(tgt, format.mintick), style = label.style_label_left, color = color.new(col, 20), textcolor = color.white, size = size.small)
        pEntry := entry

// ---------------- SIGNAL LABELS ----------------
if buy and showSignals
    label.new(bar_index, low, "BUY", yloc = yloc.belowbar, style = label.style_label_up, color = bullCol, textcolor = color.white, size = size.small)
if sell and showSignals
    label.new(bar_index, high, "SELL", yloc = yloc.abovebar, style = label.style_label_down, color = bearCol, textcolor = color.white, size = size.small)

// ---------------- DASHBOARD ----------------
var table dash = table.new(position.top_right, 2, 5, bgcolor = color.new(#1a1a2e, 10), border_width = 1, border_color = color.new(color.gray, 60))
if barstate.islast and showDash
    table.cell(dash, 0, 0, "Liquidity Sweep", text_color = color.white, text_size = size.small, bgcolor = color.new(#0d47a1, 20))
    table.cell(dash, 1, 0, syminfo.ticker + " " + timeframe.period, text_color = color.new(#64b5f6, 0), text_size = size.small, bgcolor = color.new(#0d47a1, 20))
    table.cell(dash, 0, 1, "HTF Bias", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 1, biasBull ? "Bullish" : "Bearish", text_color = biasBull ? bullCol : bearCol, text_size = size.tiny)
    table.cell(dash, 0, 2, "Last Signal", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 2, lastSig, text_color = lastSig == "BUY" ? bullCol : lastSig == "SELL" ? bearCol : color.white, text_size = size.tiny)
    table.cell(dash, 0, 3, "Liquidity (BSL/SSL)", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 3, str.tostring(array.size(bslPrice)) + " / " + str.tostring(array.size(sslPrice)), text_color = color.white, text_size = size.tiny)
    table.cell(dash, 0, 4, "Last Entry", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 4, na(pEntry) ? "-" : str.tostring(pEntry, format.mintick), text_color = color.white, text_size = size.tiny)

// ---------------- ALERTS ----------------
alertcondition(buy,  title = "Liquidity Sweep BUY",  message = "Bullish liquidity sweep (stop-hunt) BUY on {{ticker}} {{interval}}")
alertcondition(sell, title = "Liquidity Sweep SELL", message = "Bearish liquidity sweep (stop-hunt) SELL on {{ticker}} {{interval}}")
alertcondition(buy or sell, title = "Liquidity Sweep Any", message = "Liquidity sweep signal on {{ticker}} {{interval}}")
````
