# ICT AMD Session Map [EmpArchitect]

- url: https://www.tradingview.com/script/Knjy9vpI-ICT-AMD-Session-Map-EmpArchitect/
- type: indicator
- pine_id: PUB;42b1b25f7ae84fb091b2652fc32a1906
- version: 1.0

## Description

█ OVERVIEW

ICT AMD Session Map [EmpArchitect] maps the observed Accumulation–Manipulation–Distribution sequence inside configurable London or New York session cycles.

The script first builds and locks an accumulation range. After the range is complete, it watches for a confirmed sweep beyond one boundary and a close back inside. Distribution is shown only when price later moves away with displacement and closes through a frozen internal structure reference.

It maps confirmed session structure. It does not provide entries, exits, targets, stop losses, or trade signals.

█ WHAT IT MAPS

Accumulation:

A range is built during the configured accumulation window. The range updates on confirmed chart bars and becomes fixed when the window closes.

Sweep:

After the range is locked, price must penetrate beyond one boundary by the selected ATR threshold and close back inside the full range.

The script distinguishes:

• Buy-side sweep
• Sell-side sweep
• Dual sweep — ambiguous

Distribution:

Distribution is marked only after a valid one-sided sweep, directional displacement, and the first confirmed close through an internal structure level frozen at the time of the sweep.

A buy-side sweep can lead to bearish distribution.

A sell-side sweep can lead to bullish distribution.

These labels describe observed session structure. They are not forecasts or trade instructions.

█ FORWARD-ONLY STATE MODEL

Each cycle moves through a forward-only state sequence:

Idle
→ Accumulation building
→ Range locked
→ Sweep observed
→ Distribution observed

A cycle can also finish as ambiguous when both sides are swept.

Not every cycle produces all three AMD phases. A session may finish with only a locked range or a sweep without confirmed distribution. The script does not force a Distribution label when confirmation is absent.

█ SESSION PRESETS

New York preset:

• Accumulation: 07:00–08:30 America/New_York
• Sweep / distribution window: 08:30–11:00 America/New_York

London preset:

• Accumulation: 05:00–07:00 Europe/London
• Sweep / distribution window: 07:00–10:00 Europe/London

Custom mode allows both windows and the session timezone to be configured manually.

IANA timezones are used so New York and London presets adjust for daylight-saving changes.

█ CONFIRMATION FILTERS

• Minimum sweep penetration measured against ATR
• Full-range close-back-inside requirement
• Directional displacement body threshold
• Minimum body-to-range ratio
• Confirmed internal pivot structure reference
• Frozen break level at sweep time
• Distribution confirmation only after the sweep bar
• Dual-side sweep detection

█ DASHBOARD

The top-right dashboard shows the current cycle:

• Cycle preset
• Current state
• Sweep direction
• Distribution state
• Session timezone

The dashboard describes the active cycle only.

Historical boxes and labels remain visible after the active cycle finishes, while the dashboard returns to Idle / outside cycle.

█ ALERTS

Included context alerts:

• Accumulation range locked
• Buy-side sweep observed
• Sell-side sweep observed
• Bullish distribution observed
• Bearish distribution observed
• Dual sweep — ambiguous
• Cycle ended without confirmed distribution

Alerts describe confirmed session structure only. They are not trade signals.

█ IMPORTANT LIMITATIONS

• Designed for liquid intraday markets
• Best reviewed on 1M–15M charts
• Session boundaries become less precise on higher chart timeframes
• Results depend on the selected session windows, timezone, ATR filters, and pivot sensitivity
• A detected phase does not predict continuation or reversal
• “Distribution” describes a confirmed structural phase, not a recommendation to trade in that direction

█ NOTES

• Pine Script v6
• Open-source
• Works with London, New York, and custom session cycles
• Historical retention is configurable
• Built by EmpArchitect
• Educational structure-context tool only
• Not financial advice
• Not a signal service

## Source Code

````pine
//@version=6
// ============================================================================
//  ICT AMD Session Map [EmpArchitect]
//  Open-source. Builds and locks an accumulation range during a configured
//  window, then watches for a confirmed sweep beyond one boundary and a close
//  back inside. Distribution is marked only after displacement and a break of
//  an internal structure level that is frozen at the time of the sweep.
//
//  Observed session structure only. Detects and labels phases. Does NOT
//  produce signals, entries, exits, targets, or stop losses. Not every cycle
//  produces all three phases — incomplete cycles remain incomplete.
//  Built by @EmpArchitect — Free SMC tools.
// ============================================================================
indicator("ICT AMD Session Map [EmpArchitect]", shorttitle="AMD Map [EmpArch]", overlay=true, max_boxes_count=500, max_labels_count=500)

// ─────────────────────────────────────────────────────────────────────────
// STATE CONSTANTS (forward-only)
// ─────────────────────────────────────────────────────────────────────────
int ST_IDLE        = 0
int ST_ACC_BUILD   = 1
int ST_ACC_LOCKED  = 2
int ST_SWEEP       = 3
int ST_DIST        = 4
int ST_EXPIRED     = 5

// ─────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────
gCycle = "Cycle"
preset = input.string("New York", "Cycle preset", options=["London", "New York", "Custom"], group=gCycle, tooltip="Choose a killzone preset or set custom windows below. Times are read in the selected timezone.")
sessionTZ = input.string("America/New_York", "Session timezone", options=["America/New_York", "Europe/London", "Etc/UTC"], group=gCycle, tooltip="IANA timezone. Custom windows below are read in this zone and adjust for DST.")

gWin = "Windows (used when preset = Custom)"
accWinCustom  = input.session("0700-0830", "Accumulation window", group=gWin, tooltip="Range builds and locks during this window.")
distWinCustom = input.session("0830-1100", "Sweep / distribution window", group=gWin, tooltip="After the range locks, sweeps and distribution are watched in this window.")
weekdaysOnly  = input.bool(true, "Weekdays only (Mon–Fri)", group=gWin)

gLogic = "Confirmation"
minSweepATR = input.float(0.05, "Min sweep penetration (ATR)", minval=0.0, step=0.05, group=gLogic, tooltip="Minimum penetration beyond the locked boundary, in ATR, for a sweep to count.")
minDispATR  = input.float(0.5, "Min displacement body (ATR)", minval=0.0, step=0.1, group=gLogic, tooltip="Minimum candle body, in ATR, to qualify as displacement.")
minBodyRatio = input.float(0.5, "Min displacement body ratio", minval=0.0, maxval=1.0, step=0.05, group=gLogic, tooltip="Body / total range minimum for displacement.")
pivotLen = input.int(3, "Internal pivot lookback", minval=1, maxval=10, group=gLogic, tooltip="Bars each side for the internal swing used in the structure-break check.")

gRetention = "Retention & style"
historyCount = input.int(3, "Approx. historical cycles", minval=1, maxval=20, group=gRetention)
colAcc  = input.color(color.new(color.gray,   80), "Accumulation range", group=gRetention)
colSweepUp = input.color(color.new(color.red, 0),   "Buy-side sweep mark",  group=gRetention)
colSweepDn = input.color(color.new(color.green, 0), "Sell-side sweep mark", group=gRetention)
colDistBull = input.color(color.new(color.teal, 10), "Bullish distribution", group=gRetention)
colDistBear = input.color(color.new(color.maroon, 10), "Bearish distribution", group=gRetention)
colText = input.color(color.white, "Label text", group=gRetention)
showDash = input.bool(true, "Show dashboard", group=gRetention)

// ─────────────────────────────────────────────────────────────────────────
// RESOLVE PRESET WINDOWS + TIMEZONE
// ─────────────────────────────────────────────────────────────────────────
accWinBase  = preset == "London" ? "0500-0700" : preset == "New York" ? "0700-0830" : accWinCustom
distWinBase = preset == "London" ? "0700-1000" : preset == "New York" ? "0830-1100" : distWinCustom
tz          = preset == "London" ? "Europe/London" : preset == "New York" ? "America/New_York" : sessionTZ

// weekday filter baked into the session string (uses session TZ, not chart TZ)
f_days(string sess) =>
    sess + (weekdaysOnly ? ":23456" : ":1234567")

accWin  = f_days(accWinBase)
distWin = f_days(distWinBase)

// ─────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────
f_in(string sess) =>
    not na(time(timeframe.period, sess, tz))

f_start(string sess) =>
    f_in(sess) and not f_in(sess)[1]

f_end(string sess) =>
    not f_in(sess) and f_in(sess)[1]

bool supportedTF = timeframe.isintraday and timeframe.in_seconds() >= timeframe.in_seconds("1") and timeframe.in_seconds() <= timeframe.in_seconds("15")
bool confirmed = barstate.isconfirmed and supportedTF
float atr = ta.atr(14)

// internal pivots, with the bar where each pivot actually occurred
float pivHi = ta.pivothigh(pivotLen, pivotLen)
float pivLo = ta.pivotlow(pivotLen, pivotLen)
var float lastPivHi = na
var float lastPivLo = na
var int   lastPivHiBar = na
var int   lastPivLoBar = na
if confirmed and not na(pivHi)
    lastPivHi := pivHi
    lastPivHiBar := bar_index - pivotLen
if confirmed and not na(pivLo)
    lastPivLo := pivLo
    lastPivLoBar := bar_index - pivotLen

// ─────────────────────────────────────────────────────────────────────────
// CYCLE STATE (single active cycle)
// ─────────────────────────────────────────────────────────────────────────
var int   state       = ST_IDLE
var float accHigh      = na
var float accLow       = na
var int   accStartBar  = na
var bool  sweepBuy      = false
var bool  haveSweep     = false
var int   sweepBar      = na
var int   distDir       = 0
var float distBreakLevel = na   // FROZEN at sweep time
var int   distBreakBar   = na
var box   accBox        = na

// retention arrays
var array<box>   boxes  = array.new<box>()
var array<label> labels = array.new<label>()

f_track_box(box b) =>
    array.push(boxes, b)
    if array.size(boxes) > historyCount
        box.delete(array.shift(boxes))

f_track_label(label l) =>
    array.push(labels, l)
    if array.size(labels) > historyCount * 3
        label.delete(array.shift(labels))

// per-bar transition events (for safe alerts)
bool evtAccLocked = false
bool evtBuySweep  = false
bool evtSellSweep = false
bool evtBullDist  = false
bool evtBearDist  = false
bool evtDualSweep = false
bool evtNoDist    = false

// ─────────────────────────────────────────────────────────────────────────
// PHASE 1 — ACCUMULATION (build live on confirmed bars, then lock)
// ─────────────────────────────────────────────────────────────────────────
if confirmed and f_start(accWin)
    state := ST_ACC_BUILD
    accHigh := high
    accLow := low
    accStartBar := bar_index
    haveSweep := false
    sweepBuy := false
    sweepBar := na
    distDir := 0
    distBreakLevel := na
    distBreakBar := na
    accBox := box.new(bar_index, high, bar_index, low, border_color=color.new(color.gray, 40), bgcolor=colAcc)
    f_track_box(accBox)

if confirmed and state == ST_ACC_BUILD and f_in(accWin)
    accHigh := math.max(accHigh, high)
    accLow := math.min(accLow, low)
    if not na(accBox)
        box.set_top(accBox, accHigh)
        box.set_bottom(accBox, accLow)
        box.set_right(accBox, bar_index)

if confirmed and state == ST_ACC_BUILD and f_end(accWin)
    state := ST_ACC_LOCKED
    evtAccLocked := true
    if not na(accBox)
        box.set_right(accBox, bar_index - 1)
        f_track_label(label.new(accStartBar, accHigh, "ACC locked", style=label.style_label_down, color=color.new(color.gray, 50), textcolor=colText, size=size.small))

// ─────────────────────────────────────────────────────────────────────────
// PHASE 2 — MANIPULATION SWEEP (real penetration + close back inside)
// ─────────────────────────────────────────────────────────────────────────
bool inDist = f_in(distWin)
float pen = minSweepATR * atr
bool closeInsideRange = close >= accLow and close <= accHigh

// independent sweep-bar detection (state-agnostic)
bool buySweepBar  = inDist and confirmed and not na(atr) and atr > 0 and high > accHigh + pen and closeInsideRange
bool sellSweepBar = inDist and confirmed and not na(atr) and atr > 0 and low  < accLow  - pen and closeInsideRange

bool buyCand  = state == ST_ACC_LOCKED and buySweepBar
bool sellCand = state == ST_ACC_LOCKED and sellSweepBar
bool dualSweep = buyCand and sellCand

if dualSweep
    state := ST_EXPIRED
    evtDualSweep := true
    f_track_label(label.new(bar_index, close, "Dual sweep", style=label.style_label_left, color=color.new(color.gray, 30), textcolor=colText, size=size.small))
else if buyCand
    state := ST_SWEEP
    haveSweep := true
    sweepBuy := true
    sweepBar := bar_index
    evtBuySweep := true
    // freeze the bearish break reference: last confirmed pivot low, inside the range AND still unbroken at sweep time
    bool validBearRef = not na(lastPivLo) and not na(lastPivLoBar) and lastPivLoBar >= accStartBar and lastPivLoBar < bar_index and lastPivLo >= accLow and lastPivLo <= accHigh and close >= lastPivLo
    distBreakLevel := validBearRef ? lastPivLo : na
    distBreakBar := validBearRef ? lastPivLoBar : na
    f_track_label(label.new(bar_index, high, "Buy-side sweep", style=label.style_label_down, color=colSweepUp, textcolor=color.white, size=size.small))
else if sellCand
    state := ST_SWEEP
    haveSweep := true
    sweepBuy := false
    sweepBar := bar_index
    evtSellSweep := true
    // freeze the bullish break reference: last confirmed pivot high, inside the range AND still unbroken at sweep time
    bool validBullRef = not na(lastPivHi) and not na(lastPivHiBar) and lastPivHiBar >= accStartBar and lastPivHiBar < bar_index and lastPivHi >= accLow and lastPivHi <= accHigh and close <= lastPivHi
    distBreakLevel := validBullRef ? lastPivHi : na
    distBreakBar := validBullRef ? lastPivHiBar : na
    f_track_label(label.new(bar_index, low, "Sell-side sweep", style=label.style_label_up, color=colSweepDn, textcolor=color.white, size=size.small))

// opposite-side sweep on a LATER bar makes the cycle ambiguous before distribution can classify
bool oppositeSweepAfterFirst = state == ST_SWEEP and ((sweepBuy and sellSweepBar) or (not sweepBuy and buySweepBar))
if oppositeSweepAfterFirst
    state := ST_EXPIRED
    evtDualSweep := true
    f_track_label(label.new(bar_index, close, "Dual sweep", style=label.style_label_left, color=color.new(color.gray, 30), textcolor=colText, size=size.small))

// ─────────────────────────────────────────────────────────────────────────
// PHASE 3 — DISTRIBUTION (in-window, after sweep bar, against FROZEN level)
// ─────────────────────────────────────────────────────────────────────────
float body = math.abs(close - open)
float rng  = math.max(high - low, syminfo.mintick)
bool dispBull = confirmed and (close > open) and (body / atr >= minDispATR) and (body / rng >= minBodyRatio)
bool dispBear = confirmed and (close < open) and (body / atr >= minDispATR) and (body / rng >= minBodyRatio)

bool bearBreakNow = not na(distBreakLevel) and close < distBreakLevel and close[1] >= distBreakLevel
bool bullBreakNow = not na(distBreakLevel) and close > distBreakLevel and close[1] <= distBreakLevel

bool bearDist = state == ST_SWEEP and inDist and confirmed and bar_index > sweepBar and sweepBuy and dispBear and bearBreakNow
bool bullDist = state == ST_SWEEP and inDist and confirmed and bar_index > sweepBar and not sweepBuy and dispBull and bullBreakNow

if bearDist
    state := ST_DIST
    distDir := -1
    evtBearDist := true
    f_track_label(label.new(bar_index, low, "Bear distribution", style=label.style_label_up, color=colDistBear, textcolor=color.white, size=size.small))
else if bullDist
    state := ST_DIST
    distDir := 1
    evtBullDist := true
    f_track_label(label.new(bar_index, high, "Bull distribution", style=label.style_label_down, color=colDistBull, textcolor=color.white, size=size.small))

// ─────────────────────────────────────────────────────────────────────────
// PHASE 4 — RESET / EXPIRY (clears stale fields; cycle never forced complete)
// ─────────────────────────────────────────────────────────────────────────
bool cycleEnd = confirmed and f_end(distWin) and (state == ST_ACC_LOCKED or state == ST_SWEEP or state == ST_DIST or state == ST_EXPIRED)
if cycleEnd
    evtNoDist := state == ST_SWEEP
    state := ST_IDLE
    haveSweep := false
    sweepBuy := false
    sweepBar := na
    distDir := 0
    distBreakLevel := na
    distBreakBar := na

// ─────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
f_stateName() =>
    state == ST_IDLE ? "Idle / outside cycle" : state == ST_ACC_BUILD ? "Accumulation building" : state == ST_ACC_LOCKED ? "Range locked" : state == ST_SWEEP ? "Sweep observed" : state == ST_DIST ? "Distribution observed" : "Expired (ambiguous)"
f_sweepName() =>
    not haveSweep ? "—" : sweepBuy ? "Buy-side" : "Sell-side"
f_distName() =>
    distDir == 0 ? (haveSweep ? "Unconfirmed" : "—") : distDir > 0 ? "Bullish" : "Bearish"

var table dash = table.new(position.top_right, 2, 6, border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)
if barstate.islast and showDash
    table.cell(dash, 0, 0, "AMD SESSION MAP", text_color=colText, bgcolor=color.new(color.black, 10), text_size=size.small)
    table.cell(dash, 1, 0, "v1.0", text_color=colText, bgcolor=color.new(color.black, 10), text_size=size.small)
    table.cell(dash, 0, 1, "Cycle", text_color=colText, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(dash, 1, 1, preset, text_color=colText, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(dash, 0, 2, "State", text_color=colText, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(dash, 1, 2, supportedTF ? f_stateName() : "Use 1m–15m", text_color=colText, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(dash, 0, 3, "Sweep", text_color=colText, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(dash, 1, 3, f_sweepName(), text_color=colText, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(dash, 0, 4, "Distribution", text_color=colText, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(dash, 1, 4, f_distName(), text_color=colText, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(dash, 0, 5, "Session TZ", text_color=colText, bgcolor=color.new(color.black, 40), text_size=size.small)
    table.cell(dash, 1, 5, tz, text_color=colText, bgcolor=color.new(color.black, 40), text_size=size.small)
else if barstate.islast
    table.clear(dash, 0, 0, 1, 5)

// ─────────────────────────────────────────────────────────────────────────
// ALERTS (event-driven; observed structure context only — never a signal)
// ─────────────────────────────────────────────────────────────────────────
alertcondition(evtAccLocked, "Accumulation range locked", "Accumulation range locked. Session structure context only. Not a trade signal.")
alertcondition(evtBuySweep,  "Buy-side sweep observed",  "Buy-side sweep observed. Session structure context only. Not a trade signal.")
alertcondition(evtSellSweep, "Sell-side sweep observed", "Sell-side sweep observed. Session structure context only. Not a trade signal.")
alertcondition(evtBullDist,  "Bullish distribution observed", "Bullish distribution observed. Session structure context only. Not a trade signal.")
alertcondition(evtBearDist,  "Bearish distribution observed", "Bearish distribution observed. Session structure context only. Not a trade signal.")
alertcondition(evtDualSweep, "Both-side sweep (ambiguous)", "Both-side sweep — cycle ambiguous. Session structure context only. Not a trade signal.")
alertcondition(evtNoDist,    "Cycle ended without distribution", "Cycle ended with a sweep but no confirmed distribution. Session structure context only. Not a trade signal.")
````
