# VWAP + Key Levels Signals

- url: https://www.tradingview.com/script/qSbs3eoW-VWAP-Key-Levels-Signals/
- type: indicator
- pine_id: PUB;f35717c50fe14dd9b679b9cdcbc38179
- version: 1.0

## Description

VWAP + Key Levels Signals

A multi-timeframe price-action signal tool for futures traders. It marks
BUY and SELL signals when price reacts at an institutional reference level
in agreement with VWAP bias and candle conviction.

WHAT IT PLOTS
The indicator auto-calculates and tracks the key levels that price tends to
react to:
- Daily, 4H and 1H 50/200 SMAs
- Prior Day High/Low (PDH/PDL)
- Prior Globex Session High/Low (PSH/PSL — default 18:00–08:00)
- 1H Fibonacci retracements (.382 / .50 / .618 / .786)
- Unmitigated 1H swing highs/lows formed on above-average volume
- Session VWAP — used as the directional bias filter, not as a tradeable level

HOW A SIGNAL IS FORMED
A signal only prints when ALL of the basic conditions line up on the same
1-minute candle:
1. Price is AT a key level (within the touch buffer).
2. The move is IN CONFORMITY WITH VWAP bias (price on the correct side of
   VWAP and/or VWAP sloping the right way — selectable).
3. The candle reacts in the direction of the bias — a green candle closing
   above the level for longs, a red candle closing below it for shorts.
4. The candle is decisive (optional strong-body / volume filters).

When that 1-minute candle CLOSES in the bias direction, the signal fires:
green triangle = BUY, red triangle = SELL. Signals are confirmed on bar
close — they do not repaint.

SUGGESTED RULES OF ENGAGEMENT
- Entry: on the close of the signal candle, in the direction of the signal.
- Stop loss: at the key level that triggered the signal (place it just
  beyond — e.g. a few ticks past the level).
- Target: the next key level in the direction of the trade. Manage the
  runner manually or trail behind structure.

A NOTE ON SIGNAL FREQUENCY
Because the tool watches many levels across several timeframes, it can
produce a high number of signals — this is by design. Each one simply marks
that the basic conditions were met at that moment. Use the VWAP bias mode,
the touch buffer, and the strong-candle/volume filters to tighten the feed
to only the highest-conviction reactions. Start loose to see everything,
then filter down to your taste.

PAIRS WITH "HTF Levels + Volume-Filtered Unmitigated Swings"
This signal tool is designed to be used alongside the companion indicator
"HTF Levels + Volume-Filtered Unmitigated Swings." Both calculate the same
reference levels with the same logic, so the lines on your chart will match
the levels the signals fire from. Run the HTF Levels indicator for the
visual map and this tool for the reactions — or hide this tool's lines
(Display → Plot KPL levels OFF) and let the HTF Levels indicator draw them.

SETTINGS TO START WITH
- KPL touch buffer: 0.5 points (loosen to 1.0 on volatile days)
- VWAP Bias Mode: "Price vs VWAP" to start; "Price + Slope" for the
  strictest, cleanest setups
- Require strong candle: ON (min body 50%)
- Apply to a liquid futures contract on a 1m or 5m chart with enough
  history loaded for the higher-timeframe SMAs to populate

ALERTS
Built-in BUY and SELL alert conditions — set them from the alert menu for
push/email notification on a fresh signal.

──────────────────────────────────────────
DISCLAIMER
This is a free, open-source educational tool. It is NOT financial, investment
or trading advice and makes no promise or guarantee of profit. Signals are
informational only and may produce losing trades. Trading futures involves
substantial risk of loss and is not suitable for every investor. Past
performance and historical signals are not indicative of future results.
Always backtest and forward-test on a demo account, and trade your own plan
with your own risk management. You are solely responsible for your trading
decisions.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────
//  VWAP + Key Levels Signals
//  A multi-timeframe price-action signal tool for futures traders.
//  Fires BUY/SELL signals when price reacts at an institutional
//  reference level (SMAs, prior day/session H-L, 1H fibs, unmitigated
//  swings) in agreement with VWAP bias and candle conviction.
//
//  HOW TO USE:
//  • Apply to a liquid futures contract on a 1m or 5m chart.
//  • Green triangle = BUY reaction at a level (VWAP bias bullish).
//  • Red triangle = SELL reaction at a level (VWAP bias bearish).
//  • Stop: place beyond the level that triggered the signal
//    (e.g. 5 ticks below for longs, 5 ticks above for shorts).
//  • Target: next opposing key level, or trail manually.
//
//  Free educational tool. Not financial advice. Backtest and
//  forward-test before risking capital.
//  For the full methodology: YouTube @TradeKeyLevels
// ─────────────────────────────────────────────────────────────────
indicator("VWAP + Key Levels Signals", overlay=true, max_bars_back=5000)

// ─── INPUTS ──────────────────────────────────────────────────────
gSMA = "SMA Levels"
useD50   = input.bool(true, "Daily 50 SMA",  group=gSMA)
useD200  = input.bool(true, "Daily 200 SMA", group=gSMA)
use4H50  = input.bool(true, "4H 50 SMA",     group=gSMA)
use4H200 = input.bool(true, "4H 200 SMA",    group=gSMA)
use1H50  = input.bool(true, "1H 50 SMA",     group=gSMA)
use1H200 = input.bool(true, "1H 200 SMA",    group=gSMA)

gSess = "Session Levels"
usePDHL   = input.bool(true, "Prev Day H/L",     group=gSess)
usePSHL   = input.bool(true, "Prev Session H/L", group=gSess)
psSession = input.session("1800-0800", "Globex Session (PSH/PSL)", group=gSess)

gFib = "1H Fib Levels"
useFib      = input.bool(true, "Use 1H Fibs", group=gFib)
fibLookback = input.int(5, "Pivot Lookback (1H bars)", group=gFib)

gSwing = "Unmitigated 1H Swings"
useSwings = input.bool(true, "Use Unmitigated Swings", group=gSwing)
swingLB   = input.int(3,  "Swing Lookback (1H bars)", group=gSwing)
volMaLen  = input.int(20, "Volume MA Length (swings)", group=gSwing)
swingDays = input.int(10, "Max Age (days)", group=gSwing)

gSig = "Signal Settings"
prox_t       = input.float(0.5, "KPL touch buffer (points, 1pt=10t)", group=gSig, step=0.1)
useStrength  = input.bool(true,  "Require strong candle", group=gSig,
     tooltip="Only fire on candles with a decisive body — filters out indecision/dojis.")
minBodyPct   = input.float(50.0, "Min body % of range", group=gSig, minval=0, maxval=100, step=5)
useVolFilter = input.bool(false, "Require volume > average", group=gSig)
volFilterLen = input.int(20, "Signal volume avg length", group=gSig, minval=1)

gBias = "VWAP Bias Filter"
biasMode  = input.string("Price vs VWAP", "VWAP Bias Mode",
     options=["Off", "Price vs VWAP", "VWAP Slope", "Price + Slope"], group=gBias,
     tooltip="Off=no filter. Price=close on correct side. Slope=VWAP direction. Both=strict.")
slopeBars = input.int(5, "VWAP slope lookback (bars)", group=gBias, minval=1)

gPlot = "Display"
plotLvls   = input.bool(true, "Plot KPL levels", group=gPlot,
     tooltip="Turn off if you already plot levels with another indicator.")
plotSwings = input.bool(true, "Plot swing levels", group=gPlot)
showVWAP   = input.bool(true, "Plot VWAP line", group=gPlot)

// ─── VWAP (BIAS ONLY — NOT A TRADEABLE LEVEL) ───────────────────
vwap_val     = ta.vwap(hlc3)
vwap_slope   = vwap_val - vwap_val[slopeBars]
vwap_rising  = vwap_slope > 0
vwap_falling = vwap_slope < 0

// ─── SMAs ────────────────────────────────────────────────────────
smaD50   = request.security(syminfo.tickerid, "D",   ta.sma(close, 50),  lookahead=barmerge.lookahead_off)
smaD200  = request.security(syminfo.tickerid, "D",   ta.sma(close, 200), lookahead=barmerge.lookahead_off)
sma4H50  = request.security(syminfo.tickerid, "240", ta.sma(close, 50),  lookahead=barmerge.lookahead_off)
sma4H200 = request.security(syminfo.tickerid, "240", ta.sma(close, 200), lookahead=barmerge.lookahead_off)
sma1H50  = request.security(syminfo.tickerid, "60",  ta.sma(close, 50),  lookahead=barmerge.lookahead_off)
sma1H200 = request.security(syminfo.tickerid, "60",  ta.sma(close, 200), lookahead=barmerge.lookahead_off)

// ─── PDH / PDL ───────────────────────────────────────────────────
var float pdHigh = na
var float pdLow  = na
var float todH   = na
var float todL   = na
newDay = ta.change(time("D")) != 0
if newDay
    pdHigh := todH
    pdLow  := todL
    todH   := high
    todL   := low
else
    todH := math.max(nz(todH, high), high)
    todL := math.min(nz(todL, low),  low)

// ─── PSH / PSL ───────────────────────────────────────────────────
inPS = not na(time("1", psSession))
var float psHigh   = na
var float psLow    = na
var float pshFinal = na
var float pslFinal = na
var bool  prevInPS = false
if newDay
    if not na(psHigh)
        pshFinal := psHigh
        pslFinal := psLow
    psHigh := na
    psLow  := na
if inPS and not prevInPS
    psHigh := high
    psLow  := low
if inPS
    psHigh := math.max(psHigh, high)
    psLow  := math.min(psLow,  low)
if prevInPS and not inPS and not newDay
    pshFinal := psHigh
    pslFinal := psLow
prevInPS := inPS

// ─── 1H FIB ──────────────────────────────────────────────────────
ph1H_fib = request.security(syminfo.tickerid, "60", ta.pivothigh(high, fibLookback, fibLookback), lookahead=barmerge.lookahead_off)
pl1H_fib = request.security(syminfo.tickerid, "60", ta.pivotlow(low,   fibLookback, fibLookback), lookahead=barmerge.lookahead_off)
var float swH = na
var float swL = na
if not na(ph1H_fib)
    swH := ph1H_fib
if not na(pl1H_fib)
    swL := pl1H_fib
fibRng = not na(swH) and not na(swL) ? swH - swL : na
f382   = not na(fibRng) ? swL + fibRng * 0.382 : na
f50    = not na(fibRng) ? swL + fibRng * 0.500 : na
f618   = not na(fibRng) ? swL + fibRng * 0.618 : na
f786   = not na(fibRng) ? swL + fibRng * 0.786 : na

// ─── UNMITIGATED 1H SWINGS ───────────────────────────────────────
h1_ph    = request.security(syminfo.tickerid, "60", ta.pivothigh(high, swingLB, swingLB), lookahead=barmerge.lookahead_off)
h1_pl    = request.security(syminfo.tickerid, "60", ta.pivotlow(low,   swingLB, swingLB), lookahead=barmerge.lookahead_off)
h1_vol   = request.security(syminfo.tickerid, "60", volume,                               lookahead=barmerge.lookahead_off)
h1_volMA = request.security(syminfo.tickerid, "60", ta.sma(volume, volMaLen),             lookahead=barmerge.lookahead_off)
h1_volPv = request.security(syminfo.tickerid, "60", volume[1],                            lookahead=barmerge.lookahead_off)
highVol = not na(h1_vol) and not na(h1_volMA) and not na(h1_volPv) and h1_vol > h1_volMA and h1_vol > h1_volPv
cutoffTime = time - swingDays * 86400000

var swingHLvls  = array.new_float(0)
var swingLLvls  = array.new_float(0)
var swingHLines = array.new<line>(0)
var swingLLines = array.new<line>(0)

if useSwings and not na(h1_ph) and highVol
    isDupe = false
    if array.size(swingHLvls) > 0
        for i = 0 to array.size(swingHLvls) - 1
            if math.abs(array.get(swingHLvls, i) - h1_ph) < syminfo.mintick * 10
                isDupe := true
    if not isDupe
        array.push(swingHLvls, h1_ph)
        if plotSwings
            array.push(swingHLines, line.new(bar_index - 1, h1_ph, bar_index, h1_ph, color=color.new(color.blue, 30), width=1, style=line.style_dashed, extend=extend.right))

if useSwings and not na(h1_pl) and highVol
    isDupe = false
    if array.size(swingLLvls) > 0
        for i = 0 to array.size(swingLLvls) - 1
            if math.abs(array.get(swingLLvls, i) - h1_pl) < syminfo.mintick * 10
                isDupe := true
    if not isDupe
        array.push(swingLLvls, h1_pl)
        if plotSwings
            array.push(swingLLines, line.new(bar_index - 1, h1_pl, bar_index, h1_pl, color=color.new(color.blue, 30), width=1, style=line.style_dashed, extend=extend.right))

if useSwings and array.size(swingHLvls) > 0
    i = array.size(swingHLvls) - 1
    while i >= 0
        lvl = array.get(swingHLvls, i)
        if close > lvl or time < cutoffTime
            if plotSwings and i < array.size(swingHLines)
                line.delete(array.get(swingHLines, i))
                array.remove(swingHLines, i)
            array.remove(swingHLvls, i)
        i -= 1
if useSwings and array.size(swingLLvls) > 0
    i = array.size(swingLLvls) - 1
    while i >= 0
        lvl = array.get(swingLLvls, i)
        if close < lvl or time < cutoffTime
            if plotSwings and i < array.size(swingLLines)
                line.delete(array.get(swingLLines, i))
                array.remove(swingLLines, i)
            array.remove(swingLLvls, i)
        i -= 1

// ─── CANDLE & STRENGTH ───────────────────────────────────────────
is_green    = close > open
is_red      = close < open
candleRange = high - low
bodySize    = math.abs(close - open)
bodyPct     = candleRange > 0 ? (bodySize / candleRange) * 100 : 0
strongBody  = bodyPct >= minBodyPct
volAvg      = ta.sma(volume, volFilterLen)
volOK       = volume > volAvg
strengthOK  = (not useStrength or strongBody) and (not useVolFilter or volOK)

// ─── REACTION HELPERS ────────────────────────────────────────────
f_ok(lvl)         => not na(lvl) and lvl > 0.0
f_rej_long(lvl)   => f_ok(lvl) and low  <= lvl + prox_t and close > lvl and is_green and strengthOK
f_thru_long(lvl)  => f_ok(lvl) and close[1] < lvl       and close > lvl and is_green and strengthOK
f_rej_short(lvl)  => f_ok(lvl) and high >= lvl - prox_t and close < lvl and is_red   and strengthOK
f_thru_short(lvl) => f_ok(lvl) and close[1] > lvl       and close < lvl and is_red   and strengthOK

// ─── BUILD LEVEL LIST (VWAP NOT INCLUDED) ───────────────────────
levels = array.new_float(0)
if useD50
    array.push(levels, smaD50)
if useD200
    array.push(levels, smaD200)
if use4H50
    array.push(levels, sma4H50)
if use4H200
    array.push(levels, sma4H200)
if use1H50
    array.push(levels, sma1H50)
if use1H200
    array.push(levels, sma1H200)
if usePDHL
    array.push(levels, pdHigh)
    array.push(levels, pdLow)
if usePSHL
    array.push(levels, pshFinal)
    array.push(levels, pslFinal)
if useFib
    array.push(levels, f382)
    array.push(levels, f50)
    array.push(levels, f618)
    array.push(levels, f786)
if useSwings
    if array.size(swingHLvls) > 0
        for i = 0 to array.size(swingHLvls) - 1
            array.push(levels, array.get(swingHLvls, i))
    if array.size(swingLLvls) > 0
        for i = 0 to array.size(swingLLvls) - 1
            array.push(levels, array.get(swingLLvls, i))

// ─── SCAN FOR REACTIONS ──────────────────────────────────────────
raw_long  = false
raw_short = false
if array.size(levels) > 0
    for lvl in levels
        if f_rej_long(lvl) or f_thru_long(lvl)
            raw_long := true
        if f_rej_short(lvl) or f_thru_short(lvl)
            raw_short := true

// ─── VWAP BIAS FILTER ────────────────────────────────────────────
biasOK_long  = switch biasMode
    "Off"           => true
    "Price vs VWAP" => close > vwap_val
    "VWAP Slope"    => vwap_rising
    "Price + Slope" => close > vwap_val and vwap_rising
    => true
biasOK_short = switch biasMode
    "Off"           => true
    "Price vs VWAP" => close < vwap_val
    "VWAP Slope"    => vwap_falling
    "Price + Slope" => close < vwap_val and vwap_falling
    => true

long_sig_raw  = raw_long  and biasOK_long
short_sig_raw = raw_short and biasOK_short
buy_signal  = long_sig_raw  and not short_sig_raw
sell_signal = short_sig_raw and not long_sig_raw

// ─── PLOTS ───────────────────────────────────────────────────────
plot(showVWAP ? vwap_val : na, "VWAP", color.new(color.blue, 0), 3)

plot(plotLvls and useD50   ? smaD50   : na, "D50",   color.new(color.orange, 10), 2)
plot(plotLvls and useD200  ? smaD200  : na, "D200",  color.new(color.red,     5), 2)
plot(plotLvls and use4H50  ? sma4H50  : na, "4H50",  color.new(color.orange, 40), 1)
plot(plotLvls and use4H200 ? sma4H200 : na, "4H200", color.new(color.red,    35), 1)
plot(plotLvls and use1H50  ? sma1H50  : na, "1H50",  color.new(color.orange, 60), 1)
plot(plotLvls and use1H200 ? sma1H200 : na, "1H200", color.new(color.red,    55), 1)
plot(plotLvls and usePDHL  ? pdHigh   : na, "PDH",   color.new(color.red,    10), 2, plot.style_linebr)
plot(plotLvls and usePDHL  ? pdLow    : na, "PDL",   color.new(color.lime,   10), 2, plot.style_linebr)
plot(plotLvls and usePSHL  ? pshFinal : na, "PSH",   color.new(color.purple, 10), 2, plot.style_linebr)
plot(plotLvls and usePSHL  ? pslFinal : na, "PSL",   color.new(color.purple, 10), 2, plot.style_linebr)
plot(plotLvls and useFib   ? f382 : na, ".382", color.new(color.gray, 20), 1)
plot(plotLvls and useFib   ? f50  : na, ".50",  color.new(color.gray,  0), 2)
plot(plotLvls and useFib   ? f618 : na, ".618", color.new(color.gray,  0), 2)
plot(plotLvls and useFib   ? f786 : na, ".786", color.new(color.gray, 20), 1)

// ─── SIGNALS (clean buy/sell triangles, no fill markers) ─────────
plotshape(buy_signal,  title="BUY",  style=shape.triangleup,
     location=location.belowbar, color=color.new(color.lime, 0), size=size.small)
plotshape(sell_signal, title="SELL", style=shape.triangledown,
     location=location.abovebar, color=color.new(color.red,  0), size=size.small)

// ─── ALERTS ──────────────────────────────────────────────────────
alertcondition(buy_signal,  title="BUY signal",  message="Key Levels: BUY reaction at level")
alertcondition(sell_signal, title="SELL signal", message="Key Levels: SELL reaction at level")
````
