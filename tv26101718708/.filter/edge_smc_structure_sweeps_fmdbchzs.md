# EDGE SMC Structure & Sweeps 

- url: https://www.tradingview.com/script/fMDbchzS-EDGE-SMC-Structure-Sweeps/
- type: indicator
- pine_id: PUB;a39bf4bfa07b4a4e8a34ccd19f72dedf
- version: 3.0

## Description

EDGE Structure & Sweeps maps market structure and liquidity for Smart Money / ICT traders. It marks structure breaks, order blocks, equal highs and lows, higher timeframe bias, and two-candle liquidity sweeps, then prints an entry signal only when structure, a supply or demand zone, and higher timeframe bias all line up.

What it does

Structure: Confirmed swing pivots drive BOS (break of structure, trend continuation) and CHoCH (change of character, the first break against trend and the reversal warning).

Order blocks: The last opposite candle before a break is drawn as a demand or supply zone. Zones are mitigate-and-delete, so they clear from the chart the moment price trades back through them and never blanket your view.

Liquidity: EQH and EQL mark equal highs and lows where stops tend to rest.

HTF bias: A higher timeframe EMA relationship, read from closed bars, sets a single directional bias.

Chop filter: Signals are suppressed when the swing range is small relative to ATR.

Entries: Buy or Sell prints only when price taps a zone in the trend direction, higher timeframe bias agrees, and the market is not chopping. Fewer signals, higher agreement.

Fakeouts: A two-candle liquidity sweep. The setup candle takes liquidity past a swing level, the next candle closes back across it, and the setup candle is marked in light purple with a Fake Out sign. The same check runs on two higher timeframes and labels sweeps there.

How to use it

Works on any symbol and timeframe. Every threshold scales in ATR, so no retuning between instruments.

For full multi-timeframe fakeout coverage, run it on your lowest timeframe and set the two higher timeframe scans above it (for example chart on 1m, scans at 5m and 15m).

Set the HTF bias source to roughly 10 to 15 times your chart timeframe (15m bias for a 1m chart, 1h for a 5m chart).

Control fakeout sensitivity with swept swing length and min trap size (ATR). Raise both for fewer, cleaner marks.

Originality and repainting

This script is original. Structure uses confirmed pivots, entries, and fakeouts evaluate on bar close, and every higher timeframe value is pulled from closed bars. Historical marks reflect what would have printed live. It does not repaint.

This is a structure and context tool. It is not a signal service and not financial advice. No indicator predicts price. Test on replay and forward test before trading live.

## Source Code

````pine
//@version=6
// =============================================================================
// EDGE STRUCTURE  v1.5
// Standalone SMC structure map. No dashboard, no panel, nothing that blanks
// your chart. Draws what the promo screenshots draw (BOS / CHoCH / EQH / EQL,
// order blocks, Buy/Sell) but adds the three things those versions leave out:
//   1. HTF BIAS GATE    Buy fires only when the higher timeframe is bullish,
//                       Sell only when it is bearish. No counter-trend signals.
//   2. CHOP FILTER      When swing range is too small vs ATR, signals are
//                       suppressed instead of firing into noise.
//   3. NON-REPAINT      Structure uses confirmed pivots. Signals fire on bar
//                       close only. HTF bias is read from closed HTF bars.
// Order blocks are MITIGATE-AND-DELETE: the box vanishes the moment price
// trades back through it, so the chart never stays covered.
// FAKEOUT DETECTION marks high-probability liquidity sweeps in light purple on
// the SETUP candle (the one before the confirmation candle), on the chart
// timeframe and on two higher timeframes.
// Everything scales in ATR units, so it runs on MNQ, NQ, XAUUSD, ES, QQQ,
// any symbol, any timeframe, with no settings changes.
//
// This is decision support, not prediction. No indicator forecasts price.
// Replay-test and forward-test before trading live.
// =============================================================================
indicator("EDGE STRUCTURE v1.3", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ============================ INPUTS =========================================
gStr   = "Structure"
gOB    = "Order Blocks"
gBias  = "HTF Bias Gate"
gFilt  = "Filters"
gSig   = "Signals"
gColor = "Colors"

swingLen   = input.int(8,  "Swing strength (pivot length)", minval=2, maxval=50, group=gStr, tooltip="Higher = fewer, stronger swings. 5 for 1m scalps, 8-10 for 5m.")
showBOS    = input.bool(true, "Show BOS / CHoCH labels", group=gStr)
showEQ     = input.bool(true, "Show EQH / EQL (liquidity) labels", group=gStr)
eqAtrMult  = input.float(0.15, "EQH/EQL tolerance (ATR)", minval=0.02, step=0.01, group=gStr, tooltip="How close two swings must be to count as equal liquidity.")

showOB     = input.bool(true, "Show order blocks", group=gOB)
obLookback = input.int(20, "OB search lookback (bars)", minval=3, maxval=60, group=gOB, tooltip="How far back to find the last opposite candle before a break.")
bullOBcol  = input.color(color.new(#089981, 78), "Bullish OB (demand)", group=gOB)
bearOBcol  = input.color(color.new(#f23645, 78), "Bearish OB (supply)", group=gOB)

useHTF     = input.bool(true, "Gate signals by HTF bias", group=gBias)
htfTF      = input.timeframe("60", "Higher timeframe", group=gBias, tooltip="Bias source. Use 15m for a 1m chart, 1h for a 5m chart.")
htfFast    = input.int(20, "HTF fast EMA", minval=2, group=gBias)
htfSlow    = input.int(50, "HTF slow EMA", minval=2, group=gBias)

useChop    = input.bool(true, "Suppress signals in chop", group=gFilt)
chopMult   = input.float(2.0, "Min swing range (ATR)", minval=0.5, step=0.1, group=gFilt, tooltip="If the current swing high-low range is smaller than this many ATR, it is chop and signals are blocked.")
atrLen     = input.int(14, "ATR length", minval=2, group=gFilt)

showSig    = input.bool(true, "Show Buy / Sell labels", group=gSig)
oneShot    = input.bool(true, "One signal per order block", group=gSig, tooltip="Stops the same zone from firing repeatedly.")

buyCol     = input.color(#089981, "Buy", group=gColor)
sellCol    = input.color(#f23645, "Sell", group=gColor)
bosCol     = input.color(color.gray, "BOS", group=gColor)
chochCol   = input.color(#ff9800, "CHoCH", group=gColor)

gFake = "Fakeout Detection"
enableFake  = input.bool(true, "Enable fakeout detection", group=gFake)
foFLen      = input.int(5, "Swept swing length", minval=2, maxval=30, group=gFake, tooltip="Pivot length of the level that gets swept. Lower = more sensitive.")
foWickAtr   = input.float(0.5, "Min trap size (ATR)", minval=0.1, step=0.1, group=gFake, tooltip="Round trip from the sweep extreme back to the confirmation close must be at least this many ATR. Filters micro-pokes.")
foUseVol    = input.bool(false, "Require volume above average", group=gFake)
foBox       = input.bool(true, "Light purple outline on setup candle", group=gFake)
foLabel     = input.bool(true, "Fake Out label", group=gFake)
foMTF       = input.bool(true, "Also scan higher timeframes", group=gFake)
foTFa       = input.timeframe("5", "Higher TF A", group=gFake)
foTFb       = input.timeframe("15", "Higher TF B", group=gFake)
purpleCol   = input.color(#ce93d8, "Fakeout color (light purple)", group=gFake)

// ============================ CORE SERIES ====================================
atr = ta.atr(atrLen)

// ---- Fakeout / liquidity-sweep detector ------------------------------------
// Two-candle sweep. The SETUP candle [1] takes liquidity by poking past a
// confirmed swing level. The CURRENT candle confirms the reversal by closing
// back across the level against the sweep. The setup candle (the one before the
// confirmation candle) is what gets marked. Non-repaint: fires on the close of
// the confirmation candle. Self-contained so it also runs via request.security.
detectFake() =>
    fph = ta.pivothigh(high, foFLen, foFLen)
    fpl = ta.pivotlow(low, foFLen, foFLen)
    var float lvlHigh = na
    var float lvlLow  = na
    if not na(fph)
        lvlHigh := fph
    if not na(fpl)
        lvlLow := fpl
    a2    = ta.atr(atrLen)
    volOk = not foUseVol or volume > ta.sma(volume, 20)
    // bearish: setup swept highs, red confirmation closes back below
    bearF = not na(lvlHigh) and high[1] > lvlHigh and close < lvlHigh and close < open and close < close[1] and (high[1] - close) > a2 * foWickAtr and volOk
    // bullish: setup swept lows, green confirmation closes back above
    bullF = not na(lvlLow) and low[1] < lvlLow and close > lvlLow and close > open and close > close[1] and (close - low[1]) > a2 * foWickAtr and volOk
    [bullF, bearF]

// encode direction so it can be pulled cleanly through request.security
detectFakeCode() =>
    [b, s] = detectFake()
    b ? 1 : s ? -1 : 0

// ---- Confirmed pivots (non-repaint: confirm swingLen bars after the fact) ----
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

// ---- Structure state ----
var float swingHigh    = na
var float swingLow     = na
var int   swingHighBar = na
var int   swingLowBar  = na
var float prevSwingHigh = na
var float prevSwingLow  = na
var int   trend        = 0      // 1 bull, -1 bear, 0 none

// Record confirmed swings. Pivot printed swingLen bars back.
if not na(ph)
    prevSwingHigh := swingHigh
    swingHigh     := ph
    swingHighBar  := bar_index - swingLen
if not na(pl)
    prevSwingLow := swingLow
    swingLow     := pl
    swingLowBar  := bar_index - swingLen

// ---- EQH / EQL liquidity (two swings at the same level) ----
if showEQ and not na(ph) and not na(prevSwingHigh)
    if math.abs(swingHigh - prevSwingHigh) <= atr * eqAtrMult
        label.new(bar_index - swingLen, swingHigh, "EQH", style=label.style_label_down, color=color.new(color.gray, 30), textcolor=color.white, size=size.tiny)
if showEQ and not na(pl) and not na(prevSwingLow)
    if math.abs(swingLow - prevSwingLow) <= atr * eqAtrMult
        label.new(bar_index - swingLen, swingLow, "EQL", style=label.style_label_up, color=color.new(color.gray, 30), textcolor=color.white, size=size.tiny)

// ============================ BREAK DETECTION ================================
// A break is confirmed on the close of the breaking bar (non-repaint).
bullBreak = false
bearBreak = false
isChoCh   = false

if not na(swingHigh) and ta.crossover(close, swingHigh) and barstate.isconfirmed
    bullBreak := true
    isChoCh   := trend == -1     // breaking up while bearish = change of character
    trend     := 1

if not na(swingLow) and ta.crossunder(close, swingLow) and barstate.isconfirmed
    bearBreak := true
    isChoCh   := trend == 1      // breaking down while bullish = change of character
    trend     := -1

// ---- Label the break ----
if showBOS and bullBreak
    label.new(bar_index, high, isChoCh ? "CHoCH" : "BOS", style=label.style_label_down, color=isChoCh ? chochCol : bosCol, textcolor=color.white, size=size.small)
if showBOS and bearBreak
    label.new(bar_index, low, isChoCh ? "CHoCH" : "BOS", style=label.style_label_up, color=isChoCh ? chochCol : bosCol, textcolor=color.white, size=size.small)

// ============================ ORDER BLOCKS ===================================
// On a bullish break, the demand OB is the last down-close candle before the
// move. On a bearish break, the supply OB is the last up-close candle.
// Stored with their top/bottom so we can mitigate-and-delete on touch.
var array<box>   obBoxes = array.new<box>()
var array<float> obTop   = array.new<float>()
var array<float> obBot   = array.new<float>()
var array<int>   obDir   = array.new<int>()    // 1 bull demand, -1 bear supply
var array<bool>  obUsed  = array.new<bool>()   // signalled already

// helper: build an OB from the last opposite candle
makeOB(int dir) =>
    float t = na
    float b = na
    int idx = na
    found = false
    i = 1
    while i <= obLookback and not found
        opp = dir == 1 ? (close[i] < open[i]) : (close[i] > open[i])
        if opp
            t   := high[i]
            b   := low[i]
            idx := bar_index - i
            found := true
        i += 1
    [t, b, idx, found]

if showOB and (bullBreak or bearBreak)
    dir = bullBreak ? 1 : -1
    [t, b, idx, found] = makeOB(dir)
    if found
        bx = box.new(idx, t, bar_index + 5, b, border_color=dir == 1 ? bullOBcol : bearOBcol, bgcolor=dir == 1 ? bullOBcol : bearOBcol, border_width=1, extend=extend.right)
        array.push(obBoxes, bx)
        array.push(obTop, t)
        array.push(obBot, b)
        array.push(obDir, dir)
        array.push(obUsed, false)

// ============================ HTF BIAS (non-repaint) =========================
// [1] + lookahead_on is the accepted idiom for confirmed HTF values that do
// not repaint: it reads the last fully closed HTF bar, never the future.
htfF = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfFast)[1], lookahead=barmerge.lookahead_on)
htfS = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfSlow)[1], lookahead=barmerge.lookahead_on)
htfBias = htfF > htfS ? 1 : htfF < htfS ? -1 : 0
biasOkBull = not useHTF or htfBias == 1
biasOkBear = not useHTF or htfBias == -1

// ============================ CHOP FILTER ====================================
swingRange = (not na(swingHigh) and not na(swingLow)) ? math.abs(swingHigh - swingLow) : 0.0
notChop    = not useChop or (swingRange > atr * chopMult)

// ============================ SIGNALS ========================================
// Entry trigger = price taps an active order block in the direction of trend,
// HTF bias agrees, and it is not chop. Fires on bar close only.
buySig  = false
sellSig = false

if array.size(obBoxes) > 0
    n = array.size(obBoxes)
    i = n - 1
    while i >= 0
        bx  = array.get(obBoxes, i)
        t   = array.get(obTop, i)
        b   = array.get(obBot, i)
        dir = array.get(obDir, i)
        used = array.get(obUsed, i)

        touched = low <= t and high >= b   // price intersects the zone this bar

        // Only act on a CONFIRMED close. An intrabar wick must not delete the
        // zone before the close-bar signal can evaluate, or live signals drop.
        if touched and barstate.isconfirmed
            if showSig and notChop and (not used or not oneShot)
                if dir == 1 and trend == 1 and biasOkBull and close > open
                    buySig := true
                    array.set(obUsed, i, true)
                if dir == -1 and trend == -1 and biasOkBear and close < open
                    sellSig := true
                    array.set(obUsed, i, true)
            // mitigate-and-delete: zone is consumed, remove it
            box.delete(bx)
            array.remove(obBoxes, i)
            array.remove(obTop, i)
            array.remove(obBot, i)
            array.remove(obDir, i)
            array.remove(obUsed, i)
        i -= 1

if buySig
    label.new(bar_index, low - atr * 0.5, "Buy", style=label.style_label_up, color=buyCol, textcolor=color.white, size=size.normal)
if sellSig
    label.new(bar_index, high + atr * 0.5, "Sell", style=label.style_label_down, color=sellCol, textcolor=color.white, size=size.normal)

// ============================ FAKEOUT RENDER =================================
// The confirmation candle is the current bar. The SETUP candle is the bar
// before it, and that is the one we mark (light purple) as the sweep / trap.
[locBull, locBear] = detectFake()
locFake = enableFake and barstate.isconfirmed and (locBull or locBear)

// light purple outline around the setup candle (the one before the confirmation)
if locFake and foBox
    msFake = timeframe.in_seconds(timeframe.period) * 1000
    box.new(time[1], high[1], time[1] + msFake, low[1], xloc=xloc.bar_time, border_color=purpleCol, border_width=2, bgcolor=color.new(purpleCol, 82))

// Fake Out sign on the setup candle: above a bearish sweep, below a bullish one
if locFake and foLabel
    label.new(bar_index - 1, locBear ? high[1] : low[1], "Fake Out", style=locBear ? label.style_label_down : label.style_label_up, color=purpleCol, textcolor=#4a148c, size=size.small)

// Higher timeframes: pull the confirmed (closed-bar) fakeout code, non-repaint.
codeA = request.security(syminfo.tickerid, foTFa, detectFakeCode()[1], lookahead=barmerge.lookahead_on)
codeB = request.security(syminfo.tickerid, foTFb, detectFakeCode()[1], lookahead=barmerge.lookahead_on)
fireA = enableFake and foMTF and codeA != 0 and (na(codeA[1]) or codeA != codeA[1])
fireB = enableFake and foMTF and codeB != 0 and (na(codeB[1]) or codeB != codeB[1])

if fireA
    label.new(bar_index, codeA == -1 ? high : low, "Fake Out " + foTFa, style=codeA == -1 ? label.style_label_down : label.style_label_up, color=purpleCol, textcolor=#4a148c, size=size.small)
if fireB
    label.new(bar_index, codeB == -1 ? high : low, "Fake Out " + foTFb, style=codeB == -1 ? label.style_label_down : label.style_label_up, color=purpleCol, textcolor=#4a148c, size=size.small)

// ============================ ALERTS =========================================
alertcondition(buySig,  title="EDGE Buy",  message="EDGE STRUCTURE Buy on {{ticker}} {{interval}}")
alertcondition(sellSig, title="EDGE Sell", message="EDGE STRUCTURE Sell on {{ticker}} {{interval}}")
alertcondition(bullBreak, title="Bullish BOS/CHoCH", message="Bullish structure break on {{ticker}} {{interval}}")
alertcondition(bearBreak, title="Bearish BOS/CHoCH", message="Bearish structure break on {{ticker}} {{interval}}")
alertcondition(locFake, title="Fakeout (chart TF)", message="Fakeout candle on {{ticker}} {{interval}}")
alertcondition(fireA, title="Fakeout HTF A", message="Fakeout on higher timeframe A for {{ticker}}")
alertcondition(fireB, title="Fakeout HTF B", message="Fakeout on higher timeframe B for {{ticker}}")
````
