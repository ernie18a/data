# ORB Continuation v1.0 - Signals + Levels

- url: https://www.tradingview.com/script/BxBgkalw-ORB-Continuation-v1-0-Signals-Levels/
- type: indicator
- pine_id: PUB;e814b3c4840241819249458945012b96
- version: 1.0

## Description

# ORB Continuation — Signals + Levels

An opening-range breakout (ORB) tool for intraday futures and index trading. It
marks the opening range, signals a confirmed breakout, and draws the full trade
map — entry, stop, target, a trailing "stop in profit," the time-based exit, and
a per-trade risk readout — so you can see and manage a breakout setup at a glance.

The design is built around a simple, well-documented intraday tendency: the order
imbalance set in the first part of the session often persists through the day, so
a range that breaks with conviction tends to keep going in the breakout direction.

## What it does

- Builds the **opening range** from the first N minutes of the session (default
  30 minutes of the New York session) and marks the high and low as white dotted
  lines, with the range period shaded.
- Signals a **breakout** only when a candle *closes* beyond the range (use it on
  a 5-minute chart), optionally requiring the close to clear the level by a
  minimum distance to filter weak pokes.
- Draws the **entry** (dotted), the **stop loss** (red, on the opposite side of
  the range), and the **take-profit / target** (green).
- Switches the stop to a pink **"Stop in Profit"** line once the trade has run a
  full 1R and the trailing logic engages, ratcheting under the most recent bars.
- Marks the **session-exit time** (a vertical line) and the **realized exit**
  price when the simulated trade closes.
- Shows a **per-trade risk label** — the dollar risk of one contract for that
  day's setup, plus a suggested contract count — to support consistent,
  risk-based position sizing.
- One setup per day, long or short (shorts are an optional toggle).

## How the logic works

- **Entry:** a confirmed close beyond the opening range, in the breakout direction.
- **Stop:** the opposite side of the opening range (if price round-trips the whole
  range, the breakout is invalidated).
- **Exit — two modes:**
  - *Hold to close / trailing:* no fixed target; the stop trails after +1R and
    the position is flat at the session-exit time. The green line acts as a 1R
    reference.
  - *Fixed R:R + time-stop:* a fixed take-profit at a chosen R multiple; flat at
    the time-stop if neither level is hit.
- **Risk readout:** based on the stop distance and your chosen risk-per-trade and
  point value, so you can keep every trade to the same intended risk.

## Settings

- **Session:** opening-range length, session open time, session-exit time, timezone.
- **Trade:** longs on/off, shorts on/off.
- **Exit:** mode (trailing or fixed R:R), R-multiple, trailing length.
- **Sizing (for the risk label):** risk per trade, USD per point, max contracts.
- **Filters (optional):** minimum breakout penetration, minimum/maximum range
  width, EMA trend filter, entry time window, lunch skip.
- **Display:** toggles for every drawing element (ORB lines, shading, labels,
  risk label, session-exit line, realized-exit marker).

## How to use

1. Apply it to a **5-minute chart** of your instrument (e.g., index futures).
2. Set the session times for your market and pick your exit mode.
3. Set the sizing inputs so the risk label reflects your account and instrument.
4. When a LONG/SHORT marker prints, the entry, stop and target are drawn and the
   risk label shows what the trade risks. Set alerts (long, short, or either) to
   be notified of breakouts.

## Notes

This is an indicator for study and discretionary use — it visualizes and signals
a setup; it does not place orders, and the levels shown (stop, target, trailing)
are a faithful simulation of the rules for guidance. In live trading your actual
fills, spread and slippage will differ.

Nothing here is financial advice or a recommendation to buy or sell. Markets carry
risk, including loss of capital; trading leveraged instruments such as futures can
result in losses exceeding deposits. Always test any approach on your own data and
manage your own risk. Past behavior of any setup does not guarantee future results.

## Source Code

````pine
//@version=6
// =============================================================================
//  ORB Continuation — INDICATOR (signals + levels)   v1.0  (matches strategy)
// -----------------------------------------------------------------------------
//  Live / manual companion to the v1.0 strategy. Same core logic and the same
//  filters (defaults: 5% min breakout + 100-pt min range). It draws levels and
//  fires alerts; it does not place orders.
//
//  Apply on a 5-MINUTE chart.
//
//  Drawing:
//   - ORB high & low ....... WHITE DOTTED lines (+ blue shading over first 30 min)
//   - ENTRY ................ gray DOTTED line
//   - STOP LOSS ............ RED line; turns PINK "Stop in Profit" while trailing
//   - TAKE PROFIT .......... GREEN line (actual exit in Fixed R:R; 1R reference in Hold)
//   - Per-trade risk label . "$ for 1 contract" + sized count
//   - Session-exit time .... faint vertical dashed line (hold-to-close deadline)
//   - Realized exit ........ gray dotted line + "EXIT" label at the real exit price
// =============================================================================

indicator("ORB Continuation v1.1 — Signals + Levels", overlay=true,
     max_lines_count=500, max_labels_count=500)

// ----------------------------- Inputs ---------------------------------------
orMins    = input.int(30,  "Opening range length (minutes)", minval=5,  group="Session")
tz        = input.string("America/New_York", "Session timezone", group="Session")
openH     = input.int(9,   "Session open hour (ET)",  minval=0, maxval=23, group="Session")
openM     = input.int(30,  "Session open minute (ET)",minval=0, maxval=59, group="Session")
sessExitH = input.int(15,  "Session-exit / time-stop hour (ET)",  minval=0, maxval=23, group="Session")
sessExitM = input.int(55,  "Session-exit / time-stop minute (ET)",minval=0, maxval=59, group="Session")

tradeLong = input.bool(true,  "Trade longs (close above OR high)",  group="Trade")
tradeShort= input.bool(false, "Trade shorts (close below OR low)",  group="Trade")

MODE_HOLD = "Hold to close / trailing"
MODE_RR   = "Fixed R:R + time-stop"
exitMode  = input.string(MODE_HOLD, "Exit mode", options=[MODE_HOLD, MODE_RR], group="Exit")
rrTarget  = input.float(1.0, "  Fixed R:R / TP reference (R multiple)", minval=0.25, step=0.25, group="Exit")
useTrail  = input.bool(true, "  Hold mode: trailing stop (engages after +1R)", group="Exit")
trailLen  = input.int(3, "  Trail under prior N bars' low/high", minval=1, group="Exit")

// Sizing inputs (for the per-trade risk label)
riskUSD   = input.float(500.0, "Risk per trade (USD)", minval=1, group="Sizing")
pointVal  = input.float(2.0,   "USD per point (MNQ=2, NQ=20, MES=5, ES=50)", minval=0.01, group="Sizing")
maxCon    = input.int(50, "Max contracts cap", minval=1, group="Sizing")

// Filters (match the strategy)
minBreakPc = input.float(5.0,  "Min breakout beyond range (% of range)", minval=0, step=1, group="Filters")
useMinRng  = input.bool(true,  "Min opening-range width filter", group="Filters")
minRngPts  = input.float(100.0,"  Minimum range width (points)", minval=0, group="Filters")
useMaxRng  = input.bool(false, "Max opening-range width filter", group="Filters")
maxRngPts  = input.float(300.0,"  Maximum range width (points)", minval=0, group="Filters")
useTrend   = input.bool(false, "Trend filter: trade only with EMA", group="Filters")
emaLen     = input.int(200,    "Trend EMA length (bars)", minval=1, group="Filters")
useWindow  = input.bool(false, "Limit entry to a time window", group="Filters")
winStartH  = input.int(10, "Entry window start hour (ET)", minval=0, maxval=23, group="Filters")
winStartM  = input.int(0,  "Entry window start minute (ET)", minval=0, maxval=59, group="Filters")
winEndH    = input.int(14, "Entry window end hour (ET)", minval=0, maxval=23, group="Filters")
winEndM    = input.int(0,  "Entry window end minute (ET)", minval=0, maxval=59, group="Filters")
useLunch   = input.bool(false, "Skip the lunch lull", group="Filters")
lunchStartH= input.int(12, "Lunch start hour (ET)", minval=0, maxval=23, group="Filters")
lunchEndH  = input.int(13, "Lunch end hour (ET)", minval=0, maxval=23, group="Filters")

showORB   = input.bool(true,"Draw ORB high/low (white dotted)", group="Display")
shadeOR   = input.bool(true,"Shade the opening range (first 30 min)", group="Display")
showLbl   = input.bool(true,"Show entry/TP/SL labels", group="Display")
showRisk  = input.bool(true,"Show per-trade risk label", group="Display")
showExitTime = input.bool(true,"Mark session-exit time (vertical dashed line)", group="Display")
showExit     = input.bool(true,"Mark realized exit (dotted line at exit price)", group="Display")

colPink = color.rgb(255, 102, 178)

// ------------------------- Session time math --------------------------------
m        = hour(time, tz) * 60 + minute(time, tz)
oOpen    = openH * 60 + openM
oEnd     = oOpen + orMins
sessExit = sessExitH * 60 + sessExitM

inOR    = m >= oOpen and m <  oEnd
afterOR = m >= oEnd  and m <  sessExit

// ----------------------------- State ----------------------------------------
var float orH      = na
var float orL      = na
var int   orStart  = na
var bool  armed    = false
var bool  inTrade  = false
var int   dir      = 0
var float enPx     = na
var float slPx     = na
var float tpPx     = na
var float curStop  = na
var bool  trailOn  = false

// New trading day reset
dayId  = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)
newDay = dayId != dayId[1]
if newDay
    orH     := na
    orL     := na
    orStart := na
    armed   := false
    inTrade := false
    dir     := 0
    curStop := na
    trailOn := false

// Build the opening range during the OR window
if inOR
    orStart := na(orStart) ? bar_index : orStart
    orH     := na(orH) ? high : math.max(orH, high)
    orL     := na(orL) ? low  : math.min(orL, low)

// ---- ORB level lines (white dotted), created when the OR completes ----------
var line orHL = na
var line orLL = na
firstAfter = afterOR and not afterOR[1]
if showORB and firstAfter and not na(orH)
    orHL := line.new(orStart, orH, bar_index + 1, orH, color=color.white, style=line.style_dotted, width=1)
    orLL := line.new(orStart, orL, bar_index + 1, orL, color=color.white, style=line.style_dotted, width=1)
if afterOR and not na(orHL)
    line.set_x2(orHL, bar_index + 1)
    line.set_x2(orLL, bar_index + 1)

// Vertical dashed line at the session-exit time (hold-to-close deadline)
exitTimeBar = (m >= sessExit) and not (m >= sessExit)[1]
if showExitTime and exitTimeBar
    line.new(bar_index, low, bar_index, high, extend=extend.both,
         color=color.new(color.gray, 40), style=line.style_dashed, width=1)

// ---- Filter calculations ----
emaVal       = ta.ema(close, emaLen)
trendLongOK  = (not useTrend) or close > emaVal
trendShortOK = (not useTrend) or close < emaVal

winStart = winStartH * 60 + winStartM
winEnd   = winEndH   * 60 + winEndM
inWindow = (not useWindow) or (m >= winStart and m < winEnd)
inLunch  = useLunch and (m >= lunchStartH * 60 and m < lunchEndH * 60)
timeOK   = inWindow and not inLunch

rng   = orH - orL
buf   = (minBreakPc / 100.0) * rng
rngOK = ((not useMinRng) or rng >= minRngPts) and ((not useMaxRng) or rng <= maxRngPts)

llv   = ta.lowest(low,  trailLen)
hhv   = ta.highest(high, trailLen)

canArm   = afterOR and not armed and not inTrade and not na(orH) and timeOK and rngOK
longArm  = canArm and tradeLong  and trendLongOK  and close > orH + buf
shortArm = canArm and tradeShort and trendShortOK and close < orL - buf

// --------------------------- Drawing objects --------------------------------
var line  enLine = na
var line  tpLine = na
var line  slLine = na
var label enLab  = na
var label tpLab  = na
var label slLab  = na
var label riskLab= na
var line  exLine = na
var label exLab  = na

// ----------------------------- Enter ----------------------------------------
if longArm or shortArm
    dir     := longArm ? 1 : -1
    enPx    := close
    slPx    := dir == 1 ? orL : orH
    curStop := slPx
    trailOn := false
    armed   := true
    inTrade := true
    tpPx    := dir == 1 ? enPx + rrTarget * (enPx - slPx) : enPx - rrTarget * (slPx - enPx)

    stopPts  = math.abs(enPx - slPx)
    riskPer1 = stopPts * pointVal
    qtyF     = riskUSD / riskPer1
    qty      = math.max(1, math.min(maxCon, int(math.floor(qtyF))))

    enLine := line.new(bar_index, enPx, bar_index + 1, enPx, color=color.new(color.gray, 0), width=1, style=line.style_dotted)
    slLine := line.new(bar_index, slPx, bar_index + 1, slPx, color=color.new(color.red,  0), width=2)
    if showLbl
        enLab := label.new(bar_index, enPx, "ENTRY", style=label.style_label_left,
             color=color.new(color.gray, 0), textcolor=color.white, size=size.small)
        slLab := label.new(bar_index, slPx, "STOP LOSS", style=label.style_label_left,
             color=color.new(color.red,  0), textcolor=color.white, size=size.small)
    // Take Profit (green): actual exit in Fixed R:R; 1R reference in Hold mode
    tpLine := line.new(bar_index, tpPx, bar_index + 1, tpPx, color=color.new(color.green, 0), width=2)
    if showLbl
        tpLab := label.new(bar_index, tpPx, "TAKE PROFIT", style=label.style_label_left,
             color=color.new(color.green, 0), textcolor=color.white, size=size.small)
    if showRisk
        string rtxt = "1 contract ≈ $" + str.tostring(riskPer1, "#.##") + " risk"
             + "\nstop " + str.tostring(stopPts, "#.#") + " pts"
             + "\nsized: " + str.tostring(qty) + " contract(s)"
        riskLab := label.new(bar_index, dir == 1 ? high : low, rtxt,
             style = dir == 1 ? label.style_label_down : label.style_label_up,
             color=color.new(color.blue, 0), textcolor=color.white, size=size.small)

// --------------------- Manage the (simulated) open trade --------------------
oneR = math.abs(enPx - slPx)
if inTrade
    if exitMode == MODE_HOLD and useTrail
        if dir == 1
            if not trailOn and high >= enPx + oneR
                trailOn := true
            if trailOn
                curStop := math.max(curStop, llv)
        else
            if not trailOn and low <= enPx - oneR
                trailOn := true
            if trailOn
                curStop := math.min(curStop, hhv)

    bool hitStop = dir == 1 ? low <= curStop : high >= curStop
    bool hitTP   = exitMode == MODE_RR and (dir == 1 ? high >= tpPx : low <= tpPx)
    bool timeOut = m >= sessExit

    if not na(slLine)
        line.set_x2(slLine, bar_index + 1)
        line.set_y1(slLine, curStop)
        line.set_y2(slLine, curStop)
        line.set_color(slLine, trailOn ? colPink : color.new(color.red, 0))
        if showLbl and not na(slLab)
            label.set_x(slLab, bar_index + 1)
            label.set_y(slLab, curStop)
            label.set_text(slLab, trailOn ? "Stop in Profit" : "STOP LOSS")
            label.set_color(slLab, trailOn ? colPink : color.new(color.red, 0))
    if not na(enLine)
        line.set_x2(enLine, bar_index + 1)
        if showLbl and not na(enLab)
            label.set_x(enLab, bar_index + 1)
    if not na(tpLine)
        line.set_x2(tpLine, bar_index + 1)
        if showLbl and not na(tpLab)
            label.set_x(tpLab, bar_index + 1)

    if hitStop or hitTP or timeOut
        float exPx = hitStop ? curStop : (hitTP ? tpPx : close)
        if showExit
            exLine := line.new(bar_index, exPx, bar_index + 3, exPx,
                 color=color.new(color.gray, 0), width=1, style=line.style_dotted)
            exLab  := label.new(bar_index + 3, exPx, "EXIT", style=label.style_label_left,
                 color=color.new(color.gray, 0), textcolor=color.white, size=size.small)
        inTrade := false

// Opening-range shading + breakout markers
bgcolor(shadeOR and inOR ? color.new(color.blue, 90) : na, title="Opening range")
plotshape(longArm,  title="Long breakout",  style=shape.triangleup,   location=location.belowbar,
     color=color.new(color.green, 0), size=size.tiny, text="LONG",  textcolor=color.white)
plotshape(shortArm, title="Short breakout", style=shape.triangledown, location=location.abovebar,
     color=color.new(color.red, 0),   size=size.tiny, text="SHORT", textcolor=color.white)

// Alerts
alertcondition(longArm,  title="ORB Long breakout",  message="ORB LONG breakout (5m close above range) on {{ticker}}. Stop = OR low.")
alertcondition(shortArm, title="ORB Short breakout", message="ORB SHORT breakout (5m close below range) on {{ticker}}. Stop = OR high.")
alertcondition(longArm or shortArm, title="ORB Any breakout", message="ORB breakout on {{ticker}} ({{interval}}).")
````
