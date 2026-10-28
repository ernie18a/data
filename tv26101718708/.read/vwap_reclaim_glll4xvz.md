# VWAP Reclaim

- url: https://www.tradingview.com/script/glll4xvz-VWAP-Reclaim/
- type: indicator
- pine_id: PUB;cc9ba81e0d8844838db917eab9d8f450
- version: 1.0

## Description

VWAP Reclaim–Retest [Longs & Shorts] Created by Claude — User Guide
A mechanical TradingView indicator (Pine Script v6) for trading VWAP reclaims and rejections. It is built for a 5-minute chart but will run on any timeframe. It does not place trades — it identifies setups, marks entry/stop/target levels, and can fire alerts.
---
What it does
The indicator watches price relative to a daily-anchored VWAP and only signals when a specific three-step sequence completes. The point of the sequence is to stop you entering on the raw cross (which gets chopped to pieces) and instead wait for price to prove it can hold the level.
Long sequence
Reclaim — price closes above VWAP (a crossover).
Retest — within a set number of bars, price pulls back to VWAP but closes back above it. This is the "does it hold?" test. The candle that does this becomes the retest candle, and its high is recorded.
Trigger — a later candle breaks above the retest candle's high. That break is the entry.
Short sequence is the mirror image: price closes below VWAP, pops back up to VWAP but closes back below, then a later candle breaks below the retest candle's low.
A setup is abandoned (reset to idle) if price closes back through VWAP before the trigger, or if too many bars pass without a retest or trigger. This is what keeps stale setups from firing late.
---
The regime filter (why this matters most)
Reclaims only pay on directional days. On a chop/range day, price ping-pongs across VWAP and every reclaim fails. The regime filter ties each direction to VWAP's slope:
Longs only fire when VWAP is flat-to-rising.
Shorts only fire when VWAP is flat-to-falling.
Slope is measured by comparing the current VWAP to its value N bars ago (the slope lookback). This single filter removes most of the counter-trend losers. You can turn it off to see every raw setup, but leaving it on is the recommended default.
---
Reading the chart
Element	Meaning
VWAP line	Daily-anchored VWAP. Green = rising, red = falling, gray = flat. The color is the regime.
Shaded bands	Optional ±standard-deviation bands around VWAP. Useful as context: price stretched to the outer band is extended.
LONG / SHORT triangle	A confirmed trigger. Appears on the close of the trigger bar.
Entry / Stop / Target lines	Drawn at each signal. Entry = the break level. Stop = beyond the retest swing plus an ATR buffer. Target = entry ± (R multiple × risk).
Background tint	Faint green or red while a setup is building (reclaimed or armed) but not yet triggered — your early warning.
Status panel (top-right)	Live state of each side and the current VWAP direction. States: Idle → Reclaimed → await retest → Retest → ARMED. "ARMED" means a valid retest is in place and the next break will trigger.
---
Settings, group by group
 Direction
Trade long reclaims / Trade short reclaims — turn each side on or off independently. Disable one to focus, e.g. longs only on a strong up day.
 VWAP
VWAP source — the price the VWAP is built from. Default `hlc3` (the standard). Change to `close` if you prefer a close-based VWAP.
Show ±SD bands — toggle the standard-deviation bands.
Band multiplier — how many standard deviations the bands sit at (1.0 default). Raise for wider context bands.
Regime filter (VWAP slope)
Only trade with VWAP slope — the regime filter described above. On by default. The single biggest filter against chop.
Slope lookback (bars) — how far back to measure slope. Lower = more sensitive (reacts fast, more flips); higher = smoother (only strong trends qualify). 10 is a reasonable 5-minute default.
 Reclaim / Retest mechanics
Retest proximity (ticks to VWAP) — how close the pullback must get to VWAP to count as a retest. `0` = price must actually touch VWAP. Increase to allow near-misses where price pulls back toward VWAP but doesn't quite tag it. This is tick-based, so the right value differs by instrument (ES ticks are 0.25; a stock might be 0.01) — calibrate per symbol.
Max bars: reclaim → retest — how long after a reclaim the indicator will wait for a retest before giving up. Too low misses slow pullbacks; too high lets stale setups linger.
Max bars: retest → trigger — same idea for the window between a valid retest and the breakout trigger.
 Stop / Target
ATR length — lookback for the ATR used to pad the stop.
ATR buffer beyond level — how far past the retest swing the stop sits, in ATR multiples. 0.5 = half an ATR of breathing room. Raise it if you're getting wicked out, lower it for tighter risk.
Target (R multiple) — where the target line is drawn, as a multiple of risk. 1.5 means the target is 1.5× the distance from entry to stop. This sets the displayed reward, not a hard rule — you can still manage the trade manually.
Session filter
Restrict signals to a session — off by default. Turn on to ignore signals outside a chosen window.
Session — the time window, e.g. `0945-1130` to skip the open spike and lunch chop, or `0930-1600` for the full regular session.
Timezone — the timezone the session string is read in. Default `America/New_York`.
 Visuals
VWAP rising / falling / flat colors — the three slope colors.
Entry / Stop / Target colors — the three level-line colors.
Level line length (bars) — how far to the right the entry/stop/target lines extend.
Level line width — thickness of those lines.
Label size — tiny / small / normal / large for the price labels.
Show status panel — toggle the top-right state table.
Tint background while a setup is forming — toggle the faint background shading during the reclaim/armed phase.
Alerts
Three `alertcondition`s are exposed when you create an alert in TradingView: Long, Short, and Any. Pick one, set it to "Once per bar close" so it matches how signals confirm.
---
A suggested workflow
Put it on a 5-minute chart of a symbol that has volume (VWAP needs volume to compute).
Leave the regime filter on. Watch the VWAP color — that tells you which direction the indicator will even consider.
When the background tints and the status panel shows ARMED, a break is imminent; that's your prep signal.
On the triangle, the entry/stop/target lines show you the trade's geometry. Check that the target isn't sitting right on top of an obvious level (prior day high/low, round number) that would cap the move.
Forward-test on paper for 30–50 signals before sizing up. Tune one setting at a time — retest proximity and slope lookback have the biggest effect on how many signals you get and how clean they are.
---
Honest caveats
Signals confirm on the close of the trigger bar. This is the non-repainting behavior, but it means the marker appears slightly after the intrabar break where a live stop order would actually fill. The entry line shows the real break level.
The retest proximity is tick-based and must be calibrated per instrument.
It's an analysis tool, not advice. A clean ruleset still has losing streaks; the value of mechanizing is consistent, small losses so a real edge can show over a sample — not the elimination of losers. Backtest and forward-test before risking size.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════
//  VWAP Reclaim–Retest  [Longs & Shorts]
//  Mechanical entries built on the reclaim → retest → go logic:
//    LONG : close crosses ABOVE VWAP  → pulls back & HOLDS VWAP (closes above)
//           → enters on break of that retest candle's HIGH
//    SHORT: close crosses BELOW VWAP → pops back & HOLDS VWAP (closes below)
//           → enters on break of that retest candle's LOW
//  Regime filter only allows longs when VWAP is flat-to-rising, shorts when
//  flat-to-falling, so you stop fighting the day's direction.
//  Stop = beyond the retest swing + ATR buffer.  Target = R multiple.
//
//  NOTE: built for a 5-minute chart. VWAP needs volume data on the symbol.
//        Signals confirm on bar close; the level lines mark where a stop /
//        target / entry order would sit. This is an analysis tool, not advice.
// ════════════════════════════════════════════════════════════════════════
indicator("VWAP Reclaim–Retest  [Longs & Shorts]", shorttitle="VWAP RR", overlay=true, max_lines_count=500, max_labels_count=500)

// ───────────────────────── INPUTS ──────────────────────────────────────
// ① Direction
grpDir     = "① Direction"
takeLongs  = input.bool(true,  "Trade long reclaims",  group=grpDir)
takeShorts = input.bool(true,  "Trade short reclaims", group=grpDir)

// ② VWAP
grpV       = "② VWAP"
srcV       = input.source(hlc3, "VWAP source",   group=grpV)
showBands  = input.bool(true,   "Show ±SD bands", group=grpV)
bandMult   = input.float(1.0,   "Band multiplier", step=0.5, minval=0, group=grpV)

// ③ Regime filter
grpR       = "③ Regime filter (VWAP slope)"
useRegime  = input.bool(true, "Only trade with VWAP slope", group=grpR, tooltip="Longs only when VWAP is flat-to-rising; shorts only when flat-to-falling. This is the single biggest filter against chop.")
slopeLen   = input.int(10,    "Slope lookback (bars)", minval=1, group=grpR)

// ④ Reclaim / Retest mechanics
grpRT            = "④ Reclaim / Retest"
retestTicks      = input.float(0.0, "Retest proximity (ticks to VWAP)", minval=0, step=1, group=grpRT, tooltip="How close the pullback must come to VWAP to count as a retest. 0 = price must actually touch VWAP. Increase to allow near-misses (tune per instrument — ticks differ by symbol).")
maxBarsToRetest  = input.int(20, "Max bars: reclaim → retest", minval=1, group=grpRT)
maxBarsToTrigger = input.int(20, "Max bars: retest → trigger", minval=1, group=grpRT)

// ⑤ Stop / Target
grpRisk = "⑤ Stop / Target"
atrLen  = input.int(14,    "ATR length",              minval=1, group=grpRisk)
atrMult = input.float(0.5, "ATR buffer beyond level", step=0.1, minval=0, group=grpRisk)
rMult   = input.float(1.5, "Target (R multiple)",     step=0.5, minval=0, group=grpRisk)

// ⑥ Session filter
grpS       = "⑥ Session filter"
useSession = input.bool(false, "Restrict signals to a session", group=grpS, tooltip="Turn on and set e.g. 0945-1130 to avoid the open spike and lunch chop.")
sessStr    = input.session("0930-1600", "Session", group=grpS)
sessTz     = input.string("America/New_York", "Timezone", group=grpS)

// ⑦ Visuals
grpViz    = "⑦ Visuals"
colUp     = input.color(#26a69a,        "VWAP rising", group=grpViz, inline="c1")
colDown   = input.color(#ef5350,        "falling",     group=grpViz, inline="c1")
colFlat   = input.color(color.gray,     "flat",        group=grpViz, inline="c1")
colEntry  = input.color(color.new(#2962ff,0), "Entry",  group=grpViz, inline="c2")
colStop   = input.color(color.new(#ef5350,0), "Stop",   group=grpViz, inline="c2")
colTgt    = input.color(color.new(#26a69a,0), "Target", group=grpViz, inline="c2")
lineLen   = input.int(14, "Level line length (bars)", minval=1, group=grpViz)
lineWidth = input.int(2,  "Level line width",         minval=1, group=grpViz)
lblSize   = input.string("normal", "Label size", options=["tiny","small","normal","large"], group=grpViz)
showTable = input.bool(true, "Show status panel", group=grpViz)
tintBg    = input.bool(true, "Tint background while a setup is forming", group=grpViz)

// ───────────────────────── CALCS ───────────────────────────────────────
anchorReset = timeframe.change("1D")
[vwap, vUpper, vLower] = ta.vwap(srcV, anchorReset, bandMult)
atr    = ta.atr(atrLen)
buffer = retestTicks * syminfo.mintick

vwapRising    = vwap > vwap[slopeLen]
vwapFalling   = vwap < vwap[slopeLen]
regimeLongOk  = not useRegime or vwap >= vwap[slopeLen]   // flat-to-rising
regimeShortOk = not useRegime or vwap <= vwap[slopeLen]   // flat-to-falling
vwapCol       = vwapRising ? colUp : vwapFalling ? colDown : colFlat

inSession = not useSession or not na(time(timeframe.period, sessStr, sessTz))

lblSizeV = lblSize == "tiny" ? size.tiny : lblSize == "small" ? size.small : lblSize == "large" ? size.large : size.normal

// ───────────────────────── STATE MACHINES ──────────────────────────────
//  state 0 = idle | 1 = reclaimed, awaiting retest | 2 = retest found, armed
var int   lState  = 0
var float lRtHigh = na
var float lRtLow  = na
var int   lBar    = na

var int   sState  = 0
var float sRtHigh = na
var float sRtLow  = na
var int   sBar    = na

longSignal  = false
shortSignal = false

// LONG
if takeLongs
    if lState == 0
        if inSession and regimeLongOk and ta.crossover(close, vwap)
            lState := 1
            lBar   := bar_index
    else if lState == 1
        if close < vwap or (bar_index - lBar) > maxBarsToRetest
            lState := 0
        else if low <= vwap + buffer and close > vwap
            lState  := 2
            lRtHigh := high
            lRtLow  := low
            lBar    := bar_index
    else if lState == 2
        if close < vwap or (bar_index - lBar) > maxBarsToTrigger
            lState := 0
        else if high > lRtHigh
            longSignal := true
            lState     := 0
else
    lState := 0

// SHORT
if takeShorts
    if sState == 0
        if inSession and regimeShortOk and ta.crossunder(close, vwap)
            sState := 1
            sBar   := bar_index
    else if sState == 1
        if close > vwap or (bar_index - sBar) > maxBarsToRetest
            sState := 0
        else if high >= vwap - buffer and close < vwap
            sState  := 2
            sRtHigh := high
            sRtLow  := low
            sBar    := bar_index
    else if sState == 2
        if close > vwap or (bar_index - sBar) > maxBarsToTrigger
            sState := 0
        else if low < sRtLow
            shortSignal := true
            sState      := 0
else
    sState := 0

// ───────────────────────── DRAW LEVELS ─────────────────────────────────
f_levels(float entry, float stop, float target) =>
    line.new(bar_index, entry,  bar_index + lineLen, entry,  xloc=xloc.bar_index, color=colEntry, width=lineWidth)
    line.new(bar_index, stop,   bar_index + lineLen, stop,   xloc=xloc.bar_index, color=colStop,  width=lineWidth, style=line.style_dashed)
    line.new(bar_index, target, bar_index + lineLen, target, xloc=xloc.bar_index, color=colTgt,   width=lineWidth, style=line.style_dashed)
    label.new(bar_index + lineLen, entry,  "ENTRY " + str.tostring(entry,  format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=colEntry, textcolor=color.white, size=lblSizeV)
    label.new(bar_index + lineLen, stop,   "STOP "  + str.tostring(stop,   format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=colStop,  textcolor=color.white, size=lblSizeV)
    label.new(bar_index + lineLen, target, "TGT "   + str.tostring(target, format.mintick) + "  (" + str.tostring(rMult, "#.#") + "R)", xloc=xloc.bar_index, style=label.style_label_left, color=colTgt, textcolor=color.white, size=lblSizeV)

if longSignal
    entry  = lRtHigh
    stop   = lRtLow - atr * atrMult
    risk   = entry - stop
    target = entry + rMult * risk
    f_levels(entry, stop, target)

if shortSignal
    entry  = sRtLow
    stop   = sRtHigh + atr * atrMult
    risk   = stop - entry
    target = entry - rMult * risk
    f_levels(entry, stop, target)

// ───────────────────────── PLOTS ───────────────────────────────────────
pV = plot(vwap, "VWAP", color=vwapCol, linewidth=2)
pU = plot(showBands ? vUpper : na, "Upper band", color=color.new(vwapCol, 55))
pL = plot(showBands ? vLower : na, "Lower band", color=color.new(vwapCol, 55))
fill(pU, pL, color = showBands ? color.new(vwapCol, 92) : na, title="Band fill")

plotshape(longSignal,  title="Long entry",  style=shape.triangleup,   location=location.belowbar, color=colUp,   size=size.small, text="LONG")
plotshape(shortSignal, title="Short entry", style=shape.triangledown, location=location.abovebar, color=colDown, size=size.small, text="SHORT")

bgcolor(tintBg and lState > 0 ? color.new(colUp,   92) : na, title="Long forming")
bgcolor(tintBg and sState > 0 ? color.new(colDown, 92) : na, title="Short forming")

// ───────────────────────── STATUS PANEL ────────────────────────────────
f_st(int s) => s == 0 ? "Idle" : s == 1 ? "Reclaimed → await retest" : "Retest → ARMED"

var table t = table.new(position.top_right, 2, 4, border_width=1)
if showTable and barstate.islast
    table.cell(t, 0, 0, "VWAP RR", text_color=color.white, bgcolor=color.new(color.gray, 0))
    table.cell(t, 1, 0, vwapRising ? "Rising" : vwapFalling ? "Falling" : "Flat", text_color=color.white, bgcolor=color.new(vwapCol, 0))
    table.cell(t, 0, 1, "Long",  text_color=color.white, bgcolor=color.new(colUp, 25))
    table.cell(t, 1, 1, takeLongs  ? f_st(lState) : "off", text_color=color.white, bgcolor=color.new(colUp, 25))
    table.cell(t, 0, 2, "Short", text_color=color.white, bgcolor=color.new(colDown, 25))
    table.cell(t, 1, 2, takeShorts ? f_st(sState) : "off", text_color=color.white, bgcolor=color.new(colDown, 25))
    table.cell(t, 0, 3, "TF",    text_color=color.white, bgcolor=color.new(color.gray, 0))
    table.cell(t, 1, 3, timeframe.period, text_color=color.white, bgcolor=color.new(color.gray, 0))

// ───────────────────────── ALERTS ──────────────────────────────────────
alertcondition(longSignal,                 "VWAP RR Long",  "VWAP reclaim-retest LONG trigger")
alertcondition(shortSignal,                "VWAP RR Short", "VWAP reclaim-retest SHORT trigger")
alertcondition(longSignal or shortSignal,  "VWAP RR Any",   "VWAP reclaim-retest trigger")
````
