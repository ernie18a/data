# HTF Key Level Breakout BY *RAVI

- url: https://www.tradingview.com/script/Qi405w9w-HTF-Key-Level-Breakout-BY-RAVI/
- type: indicator
- pine_id: PUB;9d03b2f4cb5c4a26b2ba1ac91ae91e8e
- version: 1.0

## Description

OVERVIEW
This indicator automates a multi-timeframe liquidity model built around three events that must occur in strict sequence: a sweep of higher-timeframe liquidity, the inversion of a Fair Value Gap, and a lower-timeframe double Break of Structure. It is designed and tested primarily on Gold (XAUUSD), but works on any liquid instrument.

The goal is not to signal every sweep or every FVG. It waits for the full chain to complete and only then marks a potential entry, filtering out the many sweeps that simply continue in the original direction.

HOW IT WORKS

1. 1H Liquidity Anchor
The high and low of the PREVIOUS CLOSED 1-hour candle are plotted as liquidity levels. Only a closed candle is used, so the levels never repaint.

2. 5m Sweep Detection
On the 5-minute timeframe, the script waits for price to trade beyond the 1H high or low. A sweep of the high sets up a potential bearish model; a sweep of the low sets up a potential bullish model.

3. Fair Value Gap (Old Direction)
After the sweep, the script marks the FVG formed in the direction of the sweep — the gap created by the move INTO the liquidity. This is the gap that must fail.

4. Inversion (IFVG)
When price closes back through that FVG in the opposite direction, the gap is considered inverted. This is the first evidence that the sweep was a liquidity grab rather than a genuine breakout.

5. 1m Double BOS Confirmation
On the 1-minute timeframe the script requires:
- a BOS in the new bias direction,
- a counter-BOS against the bias,
- a second BOS back in the bias direction.
The entry signal prints only after the second BOS.

VISUALS
- 1H high/low liquidity lines
- Sweep markers
- FVG boxes (changing colour once inverted)
- BOS labels on the confirmation sequence
- Entry label with direction

ALERTS
Alerts are available for sweep, FVG inversion and final entry, so the model can be monitored without watching the chart.

HOW TO USE
- Apply to a 1-minute chart for full confirmation detail; the script requests 5m and 1H data internally.
- Treat the entry label as a setup that has met every condition, not as a guaranteed trade.
- Place stops according to your own risk rules, typically beyond the sweep extreme.
- Best suited to active sessions (London and New York for Gold).

LIMITATIONS
- Requires sufficient intraday history; results on low-liquidity symbols may be unreliable.
- Lower-timeframe data availability depends on your TradingView plan.
- Every stage must complete in order; if the sequence breaks, the setup is reset.

DISCLAIMER
This script is for educational and analytical purposes only. It does not constitute financial advice. Past behaviour of any pattern does not guarantee future results. Always test on your own data and manage risk appropriately.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
// HTF Key Level Breakout — fee-aware
//
// Time-frame alignment: pick a Higher TimeFrame for the key level,
// trade the break of it on whatever LTF chart you have this open on.
//   1D key level  -> trade on a 1h chart
//   4h key level  -> trade on a 15m chart
//   1h key level  -> trade on a 5m chart
// (chart timeframe = your LTF; the "Higher timeframe" input = HTF)
//
// Key levels = previous COMPLETED HTF candle's high/low (non-repainting).
// Same fee-survivability guard as the other breakout scripts: a stop
// too tight to survive its own round-trip fee cost is refused.
// ─────────────────────────────────────────────────────────────
indicator("HTF Key Level Breakout", "HTF-KLB", overlay = true, max_lines_count = 50, max_boxes_count = 50, max_labels_count = 50)

// ═══ Inputs ══════════════════════════════════════════════════
gL = "Levels"
htf        = input.timeframe("D", "Higher timeframe (key level source)", group = gL, tooltip = "Must be higher than your chart's own timeframe. E.g. chart=1h -> htf=D, chart=15m -> htf=240, chart=5m -> htf=60.")
useLong    = input.bool(true, "Trade breaks above HTF high (long)", group = gL)
useShort   = input.bool(true, "Trade breaks below HTF low (short)", group = gL)

gB = "Break"
bufATR     = input.float(0.1, "Break buffer (x ATR)", minval = 0.0, step = 0.05, group = gB)
dispMult   = input.float(0.8, "Breakout body (x ATR)", minval = 0.0, step = 0.1, group = gB)
useRetest  = input.bool(false, "Wait for a retest", group = gB)
retestBars = input.int(10, "Bars to wait for retest", minval = 1, group = gB)

gE = "Exit"
stopATR    = input.float(1.5, "Stop (x ATR)", minval = 0.1, step = 0.25, group = gE)
minStopATR = input.float(1.0, "Refuse stops tighter than (x ATR)", minval = 0.0, step = 0.25, group = gE, tooltip = "A tight stop makes fees enormous in R terms. 0 disables the check.")
tgtATRMult = input.float(1.0, "Target = HTF ATR x this", minval = 0.1, step = 0.1, group = gE, tooltip = "Target distance is sourced from the HIGHER timeframe's ATR, independent of your LTF stop — this is what makes R:R vary per trade instead of being a fixed multiple.")
rrMin      = input.float(7.0, "Only take setups with R:R >= this", minval = 0.5, step = 0.5, group = gE)
rrMax      = input.float(9.0, "...and R:R <= this (0 = no upper cap)", minval = 0.0, step = 0.5, group = gE)
trailR     = input.float(0.0, "Trail behind peak (R, 0 = off)", minval = 0.0, step = 0.5, group = gE)
maxHold    = input.int(60, "Max bars in trade", minval = 5, group = gE)
cooldown   = input.int(3, "Cooldown after exit (bars)", minval = 0, group = gE)

gF = "Costs"
feePct = input.float(0.0472, "Fee per side (% of notional)", minval = 0.0, step = 0.001, group = gF, tooltip = "Taker fee per side. Charged on entry AND exit.")

gD = "Chart"
zoneBars  = input.int(20, "Zone width (bars)", minval = 4, group = gD)
showTable = input.bool(true, "Status readout", group = gD)

gP = "Position"
posQty = input.float(50.0, "Position size (quantity/contracts)", minval = 0.0001, step = 1.0, group = gP, tooltip = "Used only to compute the Amount/PnL numbers shown on the Stop/Target/PnL labels — matches TradingView's native Long/Short Position tool style.")

atr = ta.atr(14)

// ═══ HTF key levels (previous completed HTF bar, non-repainting) ════
[htfHigh, htfLow, htfAtr] = request.security(syminfo.tickerid, htf, [high[1], low[1], ta.atr(14)[1]], lookahead = barmerge.lookahead_on)

htfOK = timeframe.in_seconds(htf) > timeframe.in_seconds(timeframe.period)

plot(useLong  ? htfHigh : na, "HTF High (long trigger)",  color = color.new(color.lime, 20), style = plot.style_stepline, linewidth = 1)
plot(useShort ? htfLow  : na, "HTF Low (short trigger)",  color = color.new(color.red, 20),  style = plot.style_stepline, linewidth = 1)

if not htfOK and barstate.islast
    label.new(bar_index, high, "⚠ HTF must be higher than chart timeframe", style = label.style_label_down, color = color.new(color.orange, 0), textcolor = color.white, size = size.small)

// reset "fired" flags whenever the HTF level itself rolls to a new value
var float lastHigh = na
var float lastLow  = na
var bool  longDone  = false
var bool  shortDone = false
if htfHigh != lastHigh
    longDone := false
    lastHigh := htfHigh
if htfLow != lastLow
    shortDone := false
    lastLow := htfLow

// ═══ Trade state ═════════════════════════════════════════════
var int    tDir       = 0
var float  entryP     = na
var float  curStop    = na
var float  tgtP       = na
var float  riskP      = na
var float  peakP      = na
var int    entryBar   = na
var int    cooldownTo = 0
var string tStatus    = "—"
var float  lastR      = na
var int    wins       = 0
var int    losses     = 0
var float  sumR       = 0.0
var float  sumRR      = 0.0
var float  sumFeeR    = 0.0
var int    skipCount  = 0

var int   pendDir = 0
var int   pendBar = na

var box   zTgt = na
var box   zStp = na
var line  lEnt = na
var label lStop = na
var label lMid  = na
var label lTgt  = na

inTrade = tDir != 0
bool fireLong = false
bool fireShort = false
bool exited = false

body = math.abs(close - open)
decisive = dispMult == 0 or body > atr * dispMult
buf = atr * bufATR

// ═══ Break detection ═════════════════════════════════════════
int hitDir = 0

if htfOK and not inTrade and bar_index >= cooldownTo and decisive
    if useLong and not na(htfHigh) and not longDone
        crossedUp = close > htfHigh + buf and open <= htfHigh + buf
        if crossedUp
            hitDir := 1
    if useShort and not na(htfLow) and not shortDone and hitDir == 0
        crossedDn = close < htfLow - buf and open >= htfLow - buf
        if crossedDn
            hitDir := -1

if hitDir != 0 and useRetest and not inTrade
    pendDir := hitDir
    pendBar := bar_index
    hitDir := 0

if useRetest and pendDir != 0 and not inTrade
    lvl  = pendDir == 1 ? htfHigh : htfLow
    back = pendDir == 1 ? low <= lvl : high >= lvl
    if back
        hitDir := pendDir
        pendDir := 0
    else if bar_index - pendBar > retestBars
        pendDir := 0

// ═══ Entry ═══════════════════════════════════════════════════
if hitDir != 0 and not inTrade
    pEntry = close
    pStop  = pEntry - hitDir * atr * stopATR
    pRisk  = math.abs(pEntry - pStop)
    pTgt   = pEntry + hitDir * (htfAtr * tgtATRMult)
    pRR    = pRisk > 0 ? math.abs(pTgt - pEntry) / pRisk : 0.0
    pFeeR  = pRisk > 0 ? (2 * feePct / 100 * pEntry) / pRisk : 999.0

    stopTooTight = minStopATR > 0 and atr > 0 and pRisk < atr * minStopATR
    rrOutOfBand  = pRR < rrMin or (rrMax > 0 and pRR > rrMax)

    if pRisk <= 0 or stopTooTight or rrOutOfBand
        skipCount += 1
    else
        tDir     := hitDir
        entryP   := pEntry
        curStop  := pStop
        tgtP     := pTgt
        riskP    := pRisk
        peakP    := pEntry
        entryBar := bar_index
        tStatus  := "OPEN"
        sumRR    += pRR
        if hitDir == 1
            fireLong := true
            longDone := true
        else
            fireShort := true
            shortDone := true

        r = bar_index + zoneBars
        zTgt := box.new(bar_index, math.max(entryP, tgtP), r, math.min(entryP, tgtP),
                        border_color = color.new(#26a69a, 20), border_width = 2, bgcolor = color.new(#26a69a, 85))
        zStp := box.new(bar_index, math.max(entryP, curStop), r, math.min(entryP, curStop),
                        border_color = color.new(#ef5350, 20), border_width = 2, bgcolor = color.new(#ef5350, 85))
        lEnt := line.new(bar_index, entryP, r, entryP, color = color.new(#b2b5be, 0), width = 2, style = line.style_dashed)

        stopPct = pRisk / pEntry * 100
        tgtDist = math.abs(pTgt - pEntry)
        tgtPct  = tgtDist / pEntry * 100

        lStop := label.new(bar_index, curStop,
                    "Stop: " + str.tostring(pRisk, format.mintick) + " (" + str.tostring(stopPct, "#.##") + "%)\nQty " + str.tostring(posQty, "#.####"),
                    style = tDir == 1 ? label.style_label_up : label.style_label_down,
                    color = color.new(#ef5350, 15), textcolor = color.white, size = size.small)
        lTgt := label.new(bar_index, tgtP,
                    "Target: " + str.tostring(tgtDist, format.mintick) + " (" + str.tostring(tgtPct, "#.##") + "%)\nQty " + str.tostring(posQty, "#.####"),
                    style = tDir == 1 ? label.style_label_down : label.style_label_up,
                    color = color.new(#26a69a, 15), textcolor = color.white, size = size.small)
        lMid := label.new(bar_index, entryP,
                    (tDir == 1 ? "LONG POSITION\n" : "SHORT POSITION\n") +
                    "Open PnL: $0.00\nRisk/Reward ratio 1:" + str.tostring(pRR, "#.##"),
                    style = label.style_label_left,
                    color = color.new(#2962ff, 60), textcolor = color.white, size = size.small)

// ═══ Management ══════════════════════════════════════════════
if inTrade and not (fireLong or fireShort)
    peakP := tDir == 1 ? math.max(peakP, high) : math.min(peakP, low)
    achieved = riskP > 0 ? (tDir == 1 ? peakP - entryP : entryP - peakP) / riskP : 0.0

    if trailR > 0 and achieved >= trailR
        want = peakP - tDir * trailR * riskP
        better = tDir == 1 ? want > curStop : want < curStop
        if better
            curStop := want

    if not na(zTgt)
        r = math.max(bar_index + 1, entryBar + zoneBars)
        box.set_right(zTgt, r)
        box.set_right(zStp, r)
        box.set_top(zStp, math.max(entryP, curStop))
        box.set_bottom(zStp, math.min(entryP, curStop))
        line.set_x2(lEnt, r)
        label.set_x(lStop, bar_index)
        label.set_y(lStop, curStop)
        label.set_x(lMid, bar_index)

    livePnL = tDir == 1 ? (close - entryP) * posQty : (entryP - close) * posQty
    if not na(lMid)
        label.set_text(lMid, (tDir == 1 ? "LONG POSITION\n" : "SHORT POSITION\n") +
             "Open PnL: $" + str.tostring(livePnL, "#.##") + "\nRisk/Reward ratio 1:" + str.tostring(riskP > 0 ? math.abs(tgtP - entryP) / riskP : 0.0, "#.##"))

    hitStop = tDir == 1 ? low <= curStop : high >= curStop
    hitTgt  = tDir == 1 ? high >= tgtP : low <= tgtP
    stale   = bar_index - entryBar > maxHold

    if hitStop or hitTgt or stale
        exitP = hitStop ? curStop : hitTgt ? tgtP : close
        rawR  = riskP > 0 ? (tDir == 1 ? exitP - entryP : entryP - exitP) / riskP : 0.0
        feeR  = riskP > 0 ? (2 * feePct / 100 * entryP) / riskP : 0.0
        lastR := rawR - feeR
        sumR   += lastR
        sumFeeR += feeR
        tStatus := hitStop ? (rawR > 0 ? "TRAILED" : "STOPPED") : hitTgt ? "TARGET" : "TIMED OUT"
        if lastR > 0
            wins += 1
        else
            losses += 1
        finalPnL = (tDir == 1 ? (exitP - entryP) : (entryP - exitP)) * posQty
        if not na(zTgt)
            box.set_right(zTgt, bar_index)
            box.set_right(zStp, bar_index)
            line.set_x2(lEnt, bar_index)
            label.set_text(lMid, (tDir == 1 ? "LONG " : "SHORT ") + tStatus + "\nPnL: $" + str.tostring(finalPnL, "#.##") + "  (" + str.tostring(lastR, "#.##") + "R net)")
            label.set_color(lMid, color.new(lastR > 0 ? #26a69a : #ef5350, 15))
        zTgt := na
        zStp := na
        lEnt := na
        lStop := na
        lMid := na
        lTgt := na
        tDir := 0
        cooldownTo := bar_index + cooldown
        exited := true
        entryP := na
        curStop := na
        tgtP := na
        riskP := na

// ═══ Status table (simple: Position / Entry / SL / TP) ════════
tablePos = input.string("Bottom Right", "Table position", options = ["Top Right", "Bottom Right", "Bottom Left"], group = gD)
tablePosVal = tablePos == "Top Right" ? position.top_right : tablePos == "Bottom Left" ? position.bottom_left : position.bottom_right

positionLabel = inTrade ? (tDir == 1 ? "LONG" : "SHORT") : "—"
posColor      = inTrade ? (tDir == 1 ? color.lime : color.red) : color.gray

var table st = table.new(tablePosVal, 2, 4, bgcolor = color.new(#1e222d, 15), border_width = 1)
if showTable and barstate.islast
    table.cell(st, 0, 0, "Position", text_color = color.silver, text_size = size.small)
    table.cell(st, 1, 0, positionLabel, text_color = posColor, text_size = size.small)
    table.cell(st, 0, 1, "Entry", text_color = color.silver, text_size = size.small)
    table.cell(st, 1, 1, not inTrade ? "—" : str.tostring(entryP, format.mintick), text_color = color.white, text_size = size.small)
    table.cell(st, 0, 2, "SL", text_color = color.silver, text_size = size.small)
    table.cell(st, 1, 2, not inTrade ? "—" : str.tostring(curStop, format.mintick), text_color = color.new(#ef5350, 0), text_size = size.small)
    table.cell(st, 0, 3, "TP", text_color = color.silver, text_size = size.small)
    table.cell(st, 1, 3, not inTrade ? "—" : str.tostring(tgtP, format.mintick), text_color = color.new(#26a69a, 0), text_size = size.small)

// ═══ Alerts ══════════════════════════════════════════════════
entryMsg = syminfo.ticker + " " + (tDir == 1 ? "LONG" : "SHORT") + " (" + htf + " key level) entry " + str.tostring(entryP, format.mintick) + " | SL " + str.tostring(curStop, format.mintick) + " | TP " + str.tostring(tgtP, format.mintick)
exitMsg  = syminfo.ticker + " " + tStatus + " " + str.tostring(lastR, "#.##") + "R net @ " + str.tostring(close, format.mintick)

alertcondition(fireLong,  "HTF-KLB Long",  "HTF key level break up")
alertcondition(fireShort, "HTF-KLB Short", "HTF key level break down")

if fireLong or fireShort
    alert(entryMsg, alert.freq_once_per_bar_close)
if exited
    alert(exitMsg, alert.freq_once_per_bar_close)
````
