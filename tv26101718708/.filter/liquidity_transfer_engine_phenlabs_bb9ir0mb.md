# Liquidity Transfer Engine [Phenlabs]

- url: https://www.tradingview.com/script/BB9iR0mb-Liquidity-Transfer-Engine-Phenlabs/
- type: indicator
- pine_id: PUB;743485a269b542aea44d71776c3dea71
- version: 1.0

## Description

[b]📊 Liquidity Transfer Engine [PhenLabs][/b]

Version: PineScript™ v6

https://www.tradingview.com/x/r9EF9qbK/

[b]📌 Description[/b]

Liquidity Transfer Engine [PhenLabs] is a post-sweep auction acceptance model designed for traders who already use liquidity, market structure, SMC, order block, or FVG-based workflows.

Instead of only marking where liquidity was taken, this indicator focuses on what happens after the sweep. It detects a liquidity sweep, identifies a reclaim boundary, then observes the next confirmation window to determine whether price truly accepts the reclaimed side of value.

The goal is to help traders avoid entering purely on the dramatic sweep candle. By scoring the market’s ability to hold the reclaimed auction, the indicator provides a structured Transfer Score from 0–100 and classifies the event as a Failed Sweep, Temporary Reclaim, Accepted Transfer, or High-Confidence Transfer.

[b]🚀 Points of Innovation[/b]

• Post-sweep acceptance scoring: Measures what happens after a liquidity sweep rather than only detecting the sweep itself.

• Structural transfer model: Converts sweep behavior into a 0–100 Transfer Score based on auction acceptance, rejection, and defense.

• Replay-safe score locking: Finalizes the score only after the observation window closes, preventing unfinished events from being treated as confirmed.

• Multi-factor auction logic: Uses time spent beyond the reclaim boundary, close quality, wick behavior, volume participation, and extreme defense.

• Decision-filter framework: Designed to help traders decide whether to size up, wait, or skip a sweep instead of generating simplistic buy/sell signals.

• Clean dashboard output: Displays the latest sweep type, direction, boundary, window progress, defense status, score, and state in one structured panel.

[b]🔧 Core Components[/b]

• Sweep Detector: Identifies potential liquidity sweeps from swing highs/lows, equal highs/lows, and session highs/lows.

• Reclaim Boundary Engine: Selects the structural level that price must reclaim, such as the sweep origin body midpoint, prior range midpoint, or last internal swing.

• Acceptance Engine: Observes the next user-defined number of bars after a sweep and measures whether price can hold the reclaimed side.

• Transfer Score: Combines multiple auction factors into one 0–100 score that represents the quality of the post-sweep transfer.

• State Classifier: Converts the final score into readable market states including Failed Sweep, Temporary Reclaim, Accepted Transfer, and High-Confidence Transfer.

• Dashboard System: Provides a compact real-time readout of the most recent liquidity transfer event.

[b]🔥 Key Features[/b]

• Swing high/low sweep detection: Captures classic liquidity runs above prior highs and below prior lows.

• Equal high/low sweep detection: Identifies engineered liquidity pools where price raids clustered highs or lows.

• Session high/low sweep detection: Tracks session liquidity sweeps for intraday traders.

• Configurable observation window: Lets users score the next 3–8 bars after a reclaim.

• Weighted scoring system: Allows traders to adjust the importance of time acceptance, close quality, wick asymmetry, volume persistence, and extreme defense.

• Boundary selection modes: Includes Auto, Sweep Origin Body Mid, Prior Range Mid, and Last Internal Swing.

• Finalized event labels: Marks completed sweep events with their final state and Transfer Score.

• Alert-ready logic: Sends alerts only after the score is finalized and meets the user-defined threshold.

• Object management: Retains recent events while limiting historical clutter.

[b]🎨 Visualization[/b]

• Reclaim Boundary Line: A dashed line marks the level that price must accept beyond after the sweep.

• Finalized Event Labels: Completed events are labeled with the sweep type, final state, and Transfer Score.

• Color-Coded States: Higher-quality transfers use stronger colors, while failed or temporary reclaims are displayed more cautiously.

• Dashboard Panel: Shows the latest sweep, direction, selected boundary, observation progress, acceptance reading, defense status, locked score, and final state.

[b]📖 Usage Guidelines[/b]

[b]Sweep Detection Settings[/b]

• Pivot Lookback
Default: 5
Range: 2–50
Description: Controls how many bars are used to confirm swing highs and lows. Lower values detect more sweeps but may be noisier. Higher values detect more meaningful structure but produce fewer events.

• Detect Equal H/L Sweeps
Default: Enabled
Range: On/Off
Description: Enables detection of equal high and equal low liquidity pools. Useful for SMC traders who monitor engineered liquidity clusters.

• Equal H/L ATR Tolerance
Default: 0.10
Range: 0.00+
Description: Defines how close two pivot levels must be to qualify as equal highs or equal lows. Increase this on volatile markets and lower it for cleaner structure.

• Detect Session H/L Sweeps
Default: Enabled
Range: On/Off
Description: Enables detection of session high and session low sweeps. Useful for intraday trading around major session liquidity.

• Session
Default: 0930–1600
Range: User-defined
Description: Defines the session used for session high/low tracking.

• Min Sweep Penetration
Default: 0.05 ATR
Range: 0.00+
Description: Defines how far price must move beyond a liquidity level to count as a sweep. Higher values require stronger stop-run behavior.

[b]Reclaim Boundary Settings[/b]

• Boundary Mode
Default: Auto
Options: Auto, Sweep Origin Body Mid, Prior Range Mid, Last Internal Swing
Description: Selects the boundary used to judge whether price has reclaimed value. Auto mode attempts to choose a structurally relevant boundary based on the available market context.

[b]Acceptance Engine Settings[/b]

• Observation Window
Default: 5 bars
Range: 3–8 bars
Description: Controls how many bars after the reclaim are scored. Shorter windows are faster and more reactive. Longer windows require more proof of acceptance.

• Extreme Defense Tolerance
Default: 0.25 ATR
Range: 0.00+
Description: Defines how much price can violate the original sweep extreme before the event is penalized. Lower values are stricter.

• Weight: Time Acceptance
Default: 0.30
Range: 0–1
Description: Controls how much the score rewards repeated closes on the reclaimed side of the boundary.

• Weight: Close Quality
Default: 0.25
Range: 0–1
Description: Controls how much the score rewards deeper closes beyond the reclaim boundary.

• Weight: Extreme Defense
Default: 0.20
Range: 0–1
Description: Controls how much the score depends on defending the original sweep extreme.

• Weight: Wick Asymmetry
Default: 0.15
Range: 0–1
Description: Measures whether wick behavior supports acceptance or shows aggressive re-offering back into the swept side.

• Weight: Volume Persistence
Default: 0.10
Range: 0–1
Description: Rewards relative participation on accepted-side closes. This can be useful on markets with reliable volume data.

[b]Visual Settings[/b]

• Draw Reclaim Boundary
Default: Enabled
Range: On/Off
Description: Draws a dashed reclaim boundary line for each active event.

• Show Finalized Labels
Default: Enabled
Range: On/Off
Description: Displays labels after each event completes its observation window.

• Show Dashboard
Default: Enabled
Range: On/Off
Description: Displays the latest sweep event, score, and classification in a compact dashboard.

• Dashboard Position
Default: Top Right
Range: Multiple chart positions
Description: Controls where the dashboard appears on the chart.

[b]Alert Settings[/b]

• Alert Min Score
Default: 60
Range: 0–100
Description: Sets the minimum finalized Transfer Score required to trigger an alert.

[b]✅ Best Use Cases[/b]

• Filtering SMC liquidity sweeps before entry.

• Confirming whether a sweep produced real post-event acceptance.

• Avoiding emotional entries on large displacement candles.

• Identifying when price reclaims and holds a key internal value boundary.

• Ranking the quality of sweep events across intraday markets.

• Adding a decision layer to existing order block, FVG, market structure, or session liquidity workflows.

• Monitoring futures, crypto, forex, and index markets where liquidity sweeps are frequent.

[b]⚠️ Limitations[/b]

• This indicator does not predict future price movement with certainty.

• The Transfer Score is a structural acceptance score, not a guaranteed probability of profit.

• Volume-based scoring may be less useful on symbols with unreliable or synthetic volume data.

• Very low timeframes may produce more noise and require stricter sweep and boundary settings.

• Session high/low logic depends on the user-defined session and may need adjustment for non-US markets.

• The indicator should be used as a confirmation and filtering tool, not as a standalone trading system.

[b]💡 What Makes This Unique[/b]

• It focuses on post-sweep acceptance rather than simple sweep detection.

• It helps answer the execution question traders actually face: did the market accept the new side of value after taking liquidity?

• It turns a subjective SMC concept into a structured scoring framework.

• It works after the trader’s existing strategy, making it useful as a sizing, waiting, or skip filter.

• It avoids chart clutter by prioritizing a single actionable score and clear state classification.

[b]🔬 How It Works[/b]

[b]1. Liquidity Sweep Detection[/b]

• The indicator first looks for sweeps of swing highs, swing lows, equal highs, equal lows, or session highs/lows.

• A valid sweep occurs when price pushes beyond a liquidity level and then closes back through the reclaim condition.

[b]2. Reclaim Boundary Selection[/b]

• After a sweep is detected, the script marks a structural boundary that price must accept beyond.

• Depending on the selected mode, this boundary can be based on the sweep candle body, the prior dealing range midpoint, or an internal swing reference.

[b]3. Observation Window[/b]

• The indicator then observes the next 3–8 bars.

• During this window, it evaluates how consistently price closes beyond the reclaim boundary and whether the original sweep extreme remains defended.

[b]4. Transfer Score Calculation[/b]

• The final score combines time acceptance, close location quality, wick asymmetry, volume persistence, and extreme defense.

• The result is normalized into a 0–100 Transfer Score.

[b]5. Final State Classification[/b]

• After the observation window closes, the score is locked.

• Low scores are classified as Failed Sweep or Temporary Reclaim.

• Higher scores are classified as Accepted Transfer or High-Confidence Transfer.

[quote][b]💡 Note[/b]

Liquidity Transfer Engine [PhenLabs] is designed as a post-sweep decision filter. It is not intended to replace market structure analysis, risk management, or a complete trading plan. For best results, use it alongside your existing SMC, FVG, order block, session liquidity, or higher-timeframe bias framework.[/quote]

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Liquidity Transfer Engine [phenlabs]
// Post-sweep auction acceptance scoring for SMC traders
// Pine Script v6
// ─────────────────────────────────────────────────────────────────────────────
indicator("Liquidity Transfer Engine [phenlabs]", "LTE", overlay = true,
     max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ── INPUTS ───────────────────────────────────────────────────────────────────
grpDet  = "Sweep Detection"
pivLen  = input.int(5, "Pivot Lookback", minval = 2, maxval = 50, group = grpDet)
useEQ   = input.bool(true,  "Detect Equal H/L Sweeps", group = grpDet)
eqTolX  = input.float(0.10, "Equal H/L ATR Tolerance", minval = 0.0, step = 0.05, group = grpDet)
useSess = input.bool(true,  "Detect Session H/L Sweeps", group = grpDet)
sessRef = input.session("0930-1600", "Session", group = grpDet)
sweepX  = input.float(0.05, "Min Sweep Penetration (ATR)", minval = 0.0, step = 0.05, group = grpDet)

grpBnd  = "Reclaim Boundary"
bndMode = input.string("Auto", "Boundary Mode",
     options = ["Auto", "Sweep Origin Body Mid", "Prior Range Mid", "Last Internal Swing"],
     group = grpBnd)

grpObs  = "Acceptance Engine"
winN    = input.int(5, "Observation Window (bars)", minval = 3, maxval = 8, group = grpObs)
tolExt  = input.float(0.25, "Extreme Defense Tolerance (ATR)", minval = 0.0, step = 0.05, group = grpObs)
wT      = input.float(0.30, "Weight: Time Acceptance",     minval = 0, maxval = 1, step = 0.05, group = grpObs)
wC      = input.float(0.25, "Weight: Close Quality",       minval = 0, maxval = 1, step = 0.05, group = grpObs)
wD      = input.float(0.20, "Weight: Extreme Defense",     minval = 0, maxval = 1, step = 0.05, group = grpObs)
wW      = input.float(0.15, "Weight: Wick Asymmetry",      minval = 0, maxval = 1, step = 0.05, group = grpObs)
wV      = input.float(0.10, "Weight: Volume Persistence",  minval = 0, maxval = 1, step = 0.05, group = grpObs)

grpVis  = "Visuals"
showBnd = input.bool(true,  "Draw Reclaim Boundary",  group = grpVis)
showLbl = input.bool(true,  "Show Finalized Labels",  group = grpVis)
showDash= input.bool(true,  "Show Dashboard",         group = grpVis)
dashPos = input.string("top_right", "Dashboard Position",
     options = ["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"],
     group = grpVis)

grpAlr  = "Alerts"
alertMin= input.int(60, "Alert Min Score", minval = 0, maxval = 100, group = grpAlr)

// ── ATR / SESSION ────────────────────────────────────────────────────────────
atr        = ta.atr(14)
inSession  = not na(time(timeframe.period, sessRef))
sessNew    = inSession and not inSession[1]
sessEnd    = not inSession and inSession[1]

// session H/L tracking
var float sHi = na, var float sLo = na
if sessNew
    sHi := high
    sLo := low
else if inSession
    sHi := math.max(nz(sHi, high), high)
    sLo := math.min(nz(sLo, low),  low)

// pivot detection (confirmed)
phP = ta.pivothigh(pivLen, pivLen)
plP = ta.pivotlow (pivLen, pivLen)
var float lastPH = na, var float lastPL = na
var int   lastPHb = na, var int   lastPLb = na
if not na(phP)
    lastPH  := phP
    lastPHb := bar_index - pivLen
if not na(plP)
    lastPL  := plP
    lastPLb := bar_index - pivLen

// equal H/L pool: tag prior pivot if a near-equal pivot precedes it
isEqHi = not na(phP) and not na(lastPH[1]) and math.abs(phP - lastPH[1]) <= eqTolX * atr
isEqLo = not na(plP) and not na(lastPL[1]) and math.abs(plP - lastPL[1]) <= eqTolX * atr

// ── EVENT TYPE ───────────────────────────────────────────────────────────────
type SweepEvent
    int    startBar
    int    dir            // +1 bullish reclaim, -1 bearish reclaim
    string poolType       // "SwingHigh", "SwingLow", "EqualHighs", "EqualLows", "SessionHigh", "SessionLow"
    float  extremeLvl     // sweep extreme E
    float  boundary       // reclaim boundary B
    string boundaryName
    float  refRange       // normalization R (ATR-based)
    int    obsLeft
    int    obsTotal
    float  accTime
    float  accClose
    float  accDef
    float  accWick
    float  accVol
    float  score
    string state
    bool   finalized
    label  lbl
    line   bndLine

var array<SweepEvent> events = array.new<SweepEvent>()

// ── BOUNDARY SELECTOR ────────────────────────────────────────────────────────
selectBoundary(int dir, float extremeLvl) =>
    bodyMid  = (open + close) / 2.0
    rangeMid = (nz(lastPH, high) + nz(lastPL, low)) / 2.0
    swingMid = dir > 0 ? nz(lastPL, low) : nz(lastPH, high)

    float outBoundary = bodyMid
    string outName = "Origin Body Mid"

    if bndMode == "Sweep Origin Body Mid"
        outBoundary := bodyMid
        outName := "Origin Body Mid"
    else if bndMode == "Prior Range Mid"
        outBoundary := rangeMid
        outName := "Range Mid"
    else if bndMode == "Last Internal Swing"
        outBoundary := swingMid
        outName := "Last Internal Swing"
    else
        ok = not na(lastPH) and not na(lastPL) and (dir > 0 ? rangeMid > extremeLvl : rangeMid < extremeLvl)
        if ok
            outBoundary := rangeMid
            outName := "Range Mid (Auto)"
        else
            outBoundary := bodyMid
            outName := "Origin Body Mid (Auto)"

    [outBoundary, outName]
// ── SWEEP DETECTION ──────────────────────────────────────────────────────────
registerSweep(int dir, float extremeLvl, string poolType) =>
    [bnd, bname] = selectBoundary(dir, extremeLvl)
    valid = dir > 0 ? close > bnd and low < extremeLvl : close < bnd and high > extremeLvl

    if valid
        ev = SweepEvent.new(
             startBar     = bar_index,
             dir          = dir,
             poolType     = poolType,
             extremeLvl   = extremeLvl,
             boundary     = bnd,
             boundaryName = bname,
             refRange     = math.max(atr, syminfo.mintick),
             obsLeft      = winN,
             obsTotal     = winN,
             accTime = 0.0, accClose = 0.0, accDef = 1.0, accWick = 0.0, accVol = 0.0,
             score   = 0.0, state = "Observing", finalized = false,
             lbl     = na, bndLine = na)
        if showBnd
            ev.bndLine := line.new(bar_index, bnd, bar_index + winN, bnd,
                 color = color.new(dir > 0 ? color.lime : color.red, 30),
                 style = line.style_dashed, width = 1)
        array.push(events, ev)

if barstate.isconfirmed
    // bullish reclaim after downside sweep of swing low
    if not na(lastPL) and low < lastPL - sweepX * atr and close > lastPL
        registerSweep(1, lastPL, "SwingLow")
    // bearish reclaim after upside sweep of swing high
    if not na(lastPH) and high > lastPH + sweepX * atr and close < lastPH
        registerSweep(-1, lastPH, "SwingHigh")
    // equal lows / highs (use prior pivot level)
    if useEQ and isEqLo and low < lastPL - sweepX * atr and close > lastPL
        registerSweep(1, lastPL, "EqualLows")
    if useEQ and isEqHi and high > lastPH + sweepX * atr and close < lastPH
        registerSweep(-1, lastPH, "EqualHighs")
    // session high/low
    if useSess and sessEnd
        if not na(sHi) and high > sHi + sweepX * atr and close < sHi
            registerSweep(-1, sHi, "SessionHigh")
        if not na(sLo) and low  < sLo - sweepX * atr and close > sLo
            registerSweep(1,  sLo, "SessionLow")

// ── ACCEPTANCE SCORING (per confirmed bar) ───────────────────────────────────
volMA = ta.sma(volume, 20)

method updateAcceptance(SweepEvent ev) =>
    d = ev.dir
    B = ev.boundary
    E = ev.extremeLvl
    R = ev.refRange
    // time-in-value
    accept = d * (close - B) > 0 ? 1.0 : 0.0
    ev.accTime := ev.accTime + accept
    // close depth
    depth = math.max(0.0, math.min(1.0, d * (close - B) / R))
    ev.accClose := ev.accClose + depth
    // wick asymmetry: penalize re-offer wicks toward swept side
    body = math.abs(close - open)
    rng  = math.max(high - low, syminfo.mintick)
    reofWick = d > 0 ? (math.min(open, close) - low) / rng : (high - math.max(open, close)) / rng
    holdWick = d > 0 ? (high - math.max(open, close)) / rng : (math.min(open, close) - low) / rng
    ev.accWick := ev.accWick + math.max(0.0, holdWick - reofWick)
    // volume persistence (only on accepted-side closes)
    vRel = na(volMA) or volMA == 0 ? 0.0 : math.min(2.0, volume / volMA) / 2.0
    ev.accVol := ev.accVol + (accept > 0 ? vRel : 0.0)
    // extreme defense: penalize if E violated
    violated = d > 0 ? low  < E - tolExt * R : high > E + tolExt * R
    if violated
        ev.accDef := 0.0
    ev.obsLeft := ev.obsLeft - 1
    ev

method finalize(SweepEvent ev) =>
    n = float(ev.obsTotal)
    aT = ev.accTime  / n
    aC = ev.accClose / n
    aW = math.min(1.0, ev.accWick / n)
    aV = math.min(1.0, ev.accVol  / n)
    aD = ev.accDef
    wSum = math.max(0.001, wT + wC + wD + wW + wV)
    raw  = (wT*aT + wC*aC + wD*aD + wW*aW + wV*aV) / wSum
    ev.score := 100.0 * raw
    ev.state := ev.score >= 80 ? "High-Confidence Transfer"
              : ev.score >= 60 ? "Accepted Transfer"
              : ev.score >= 35 ? "Temporary Reclaim"
              : "Failed Sweep"
    ev.finalized := true
    ev

if barstate.isconfirmed and array.size(events) > 0
    i = 0
    while i < array.size(events)
        ev = array.get(events, i)
        if not ev.finalized and ev.startBar < bar_index
            ev := ev.updateAcceptance()
            if ev.obsLeft <= 0
                ev := ev.finalize()
                if showLbl
                    col = ev.score >= 80 ? color.purple
                         : ev.score >= 60 ? (ev.dir > 0 ? color.green : color.red)
                         : ev.score >= 35 ? color.orange
                         : color.gray
                    yloc = ev.dir > 0 ? label.style_label_up : label.style_label_down
                    txt  = str.format("{0}\n{1}\nScore {2,number,#}", ev.poolType, ev.state, ev.score)
                    ev.lbl := label.new(bar_index, ev.dir > 0 ? low - atr*0.5 : high + atr*0.5,
                         txt, style = yloc, color = col, textcolor = color.white, size = size.small)
                if ev.score >= alertMin
                    alert(str.format("LTE Finalized: {0} {1} Score={2,number,#}",
                         ev.poolType, ev.state, ev.score), alert.freq_once_per_bar_close)
            array.set(events, i, ev)
        i := i + 1

// ── DASHBOARD ────────────────────────────────────────────────────────────────
posOf(string p) =>
    switch p
        "top_left"      => position.top_left
        "top_right"     => position.top_right
        "bottom_left"   => position.bottom_left
        "bottom_right"  => position.bottom_right
        "middle_left"   => position.middle_left
        =>                 position.middle_right

var table dash = table.new(posOf(dashPos), 2, 9, border_width = 1,
     bgcolor = color.new(color.black, 80), frame_color = color.gray, frame_width = 1)

scoreColor(float s) =>
    s >= 80 ? color.purple : s >= 60 ? color.new(color.green, 0)
     : s >= 35 ? color.new(color.orange, 0) : color.new(color.red, 0)

if showDash and barstate.islast and array.size(events) > 0
    ev = array.get(events, array.size(events) - 1)
    txtCol = color.white
    table.cell(dash, 0, 0, "LIQUIDITY TRANSFER ENGINE", text_color = txtCol,
         bgcolor = color.new(color.blue, 50), text_size = size.small)
    table.merge_cells(dash, 0, 0, 1, 0)
    table.cell(dash, 0, 1, "Sweep",      text_color = txtCol, text_size = size.small)
    table.cell(dash, 1, 1, ev.poolType,  text_color = txtCol, text_size = size.small)
    table.cell(dash, 0, 2, "Direction",  text_color = txtCol, text_size = size.small)
    table.cell(dash, 1, 2, ev.dir > 0 ? "Bullish Reclaim" : "Bearish Reclaim",
         text_color = ev.dir > 0 ? color.lime : color.red, text_size = size.small)
    table.cell(dash, 0, 3, "Boundary",   text_color = txtCol, text_size = size.small)
    table.cell(dash, 1, 3, ev.boundaryName, text_color = txtCol, text_size = size.small)
    table.cell(dash, 0, 4, "Window",     text_color = txtCol, text_size = size.small)
    table.cell(dash, 1, 4, str.format("{0}/{1}", ev.obsTotal - ev.obsLeft, ev.obsTotal),
         text_color = txtCol, text_size = size.small)
    table.cell(dash, 0, 5, "Acceptance", text_color = txtCol, text_size = size.small)
    table.cell(dash, 1, 5, str.format("{0,number,#.#}%",
         ev.finalized ? ev.score : 100*(ev.accTime + ev.accClose)/(2*math.max(1, ev.obsTotal-ev.obsLeft))),
         text_color = txtCol, text_size = size.small)
    table.cell(dash, 0, 6, "Defense",    text_color = txtCol, text_size = size.small)
    table.cell(dash, 1, 6, ev.accDef >= 1.0 ? "Intact" : "Broken",
         text_color = ev.accDef >= 1.0 ? color.lime : color.red, text_size = size.small)
    table.cell(dash, 0, 7, "Score",      text_color = txtCol, text_size = size.small)
    table.cell(dash, 1, 7, ev.finalized ? str.format("{0,number,#}", ev.score) : "—",
         bgcolor = ev.finalized ? scoreColor(ev.score) : color.new(color.gray, 50),
         text_color = color.white, text_size = size.normal)
    table.cell(dash, 0, 8, "State",      text_color = txtCol, text_size = size.small)
    table.cell(dash, 1, 8, ev.finalized ? ev.state : "Observing",
         text_color = txtCol, text_size = size.small)

// ── HOUSEKEEPING: cap retained events ────────────────────────────────────────
var int maxEvents = 50
if array.size(events) > maxEvents
    old = array.shift(events)
    if not na(old.bndLine)
        line.delete(old.bndLine)
````
