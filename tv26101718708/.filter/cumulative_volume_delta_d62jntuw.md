# Cumulative Volume Delta

- url: https://www.tradingview.com/script/d62jNtUW-Cumulative-Volume-Delta/
- type: indicator
- pine_id: PUB;490b6a3525f2410f89ee3fa0b4a4f540
- version: 4.0

## Description

CumDelta — Cumulative Volume Delta with Session Reset
A clean cumulative volume delta (CVD) indicator that visualizes the running balance of buying vs. selling aggression using lower-timeframe up/down volume. Designed for intraday traders who want to read order flow alongside price.
What it does
Each bar's delta is calculated by pulling lower-timeframe volume data and classifying it as buying or selling pressure based on whether each sub-bar closed up or down. These per-bar deltas are then cumulated into a running total that resets on your chosen schedule (day, session, week, month, year, or N bars back).
The cumulative delta is rendered as candles — each candle's open chains from the previous close, and the body shows whether net flow on that bar was positive or negative. A histogram below shows the raw per-bar delta for quick reference.
How to read it

Rising green candles — sustained buying pressure
Falling red candles — sustained selling pressure
Divergence vs. price — price makes a new high but CVD doesn't (or vice versa) often precedes reversals
Reset bars (optional yellow highlight) — fresh session start, useful for marking where the cumulation restarts

Settings

Reset Period — Day, Session (RTH-aware), Week, Month, Year, or Bars Back
Lower Timeframe — auto-selects based on chart TF, or set manually for finer/coarser resolution
Doji Handling — choose how to attribute volume when a bar closes flat (Split 50/50, Up, Down, or Skip)
Display toggles — bar delta histogram, cumulative candles, reset markers

## Source Code

````pine
//@version=6
indicator("CumDelta.v05", format=format.volume)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
var string GRP_RESET = "Reset Settings"
var string GRP_TF    = "Lower Timeframe"
var string GRP_DISP  = "Display"
var string GRP_ADV   = "Advanced"

lowerTFTooltip  = "Uses lower-timeframe Up/Down volume to calculate buyer/seller aggression.\nMust be <= chart timeframe AND divide it evenly (otherwise auto TF is used).\nHigher TFs = more history but less precision."
barsBackTooltip = "Number of bars back to start cumulating delta when reset is set to 'Bars Back'. Fixed when the script loads."
dojiTooltip     = "How to classify volume when close == open AND close == previous close.\nSplit = 50/50 (nets to 0). Up = buying. Down = selling. Skip = ignore."
secTooltip      = "Use 1-second data on 1-minute charts. Requires a TradingView plan with seconds data."
resetTooltip    = "A reset period equal to or larger than one chart bar (e.g. 'Day' on a Daily chart) is disabled automatically."

resetPeriod = input.string("Day", "Reset Period", options=["None","Day","Session","Week","Month","Year","Bars Back"], tooltip=resetTooltip, group=GRP_RESET)
barsBack    = input.int(300, "Bars Back (when 'Bars Back' selected)", minval=1, tooltip=barsBackTooltip, group=GRP_RESET)

useCustomTF = input.bool(false,    "Use Custom Lower Timeframe", tooltip=lowerTFTooltip, group=GRP_TF)
customTF    = input.timeframe("1", "Lower Timeframe",            group=GRP_TF)
allowSecTF  = input.bool(false,    "Allow Seconds TF on 1m chart", tooltip=secTooltip, group=GRP_TF)

showDelta      = input.bool(true, "Show Bar Delta (histogram)",      group=GRP_DISP)
showCumCandles = input.bool(true, "Show Cumulative Delta (candles)", group=GRP_DISP)
showStatus     = input.bool(true, "Show Data Status",                group=GRP_DISP)

dojiHandling = input.string("Split", "Doji Volume Handling", options=["Split","Up","Down","Skip"], tooltip=dojiTooltip, group=GRP_ADV)

// ─────────────────────────────────────────────
// CHART TYPE GUARD
// ─────────────────────────────────────────────
if timeframe.isticks
    runtime.error("CumDelta: tick charts are not supported. Use a time-based chart (e.g. 1m, 5m, 15m).")

// ─────────────────────────────────────────────
// LOWER-TF UP/DOWN VOLUME
// ─────────────────────────────────────────────
upAndDownVolume() =>
    float v      = nz(volume)
    float posVol = 0.0
    float negVol = 0.0
    if close > open
        posVol := v
    else if close < open
        negVol := -v
    else if close > close[1]
        posVol := v
    else if close < close[1]
        negVol := -v
    else
        if dojiHandling == "Split"
            posVol :=  v / 2
            negVol := -v / 2
        else if dojiHandling == "Up"
            posVol := v
        else if dojiHandling == "Down"
            negVol := -v
    [posVol, negVol]

barLevelDelta() =>
    float v = nz(volume)
    float d = 0.0
    if close > open
        d := v
    else if close < open
        d := -v
    else if close > close[1]
        d := v
    else if close < close[1]
        d := -v
    else
        d := dojiHandling == "Up" ? v : dojiHandling == "Down" ? -v : 0.0
    d

addMsg(string m, string s) =>
    m == "" ? s : m + "\n" + s

// ── Timeframe selection (guarded) ──
int chartSec = timeframe.in_seconds()

// 2m–15m charts now use 1m data (15m gets 15 intrabars instead of 3)
string autoLowerTF = chartSec < 60      ? "1S" :
                     chartSec == 60     ? (allowSecTF ? "1S" : "1") :
                     chartSec <= 900    ? "1"  :
                     chartSec <= 3600   ? "5"  :
                     chartSec <= 14400  ? "15" : "60"

// Custom TF must be <= chart TF and divide it evenly (no intrabar straddling chart bars)
int    customSec      = timeframe.in_seconds(customTF)
bool   customRejected = useCustomTF and (customSec > chartSec or chartSec % customSec != 0)
string lowerTF        = useCustomTF and not customRejected ? customTF : autoLowerTF
bool   ltfIsChartTF   = timeframe.in_seconds(lowerTF) >= chartSec
string lowerTFLabel   = lowerTF == "" ? timeframe.period : lowerTF

[upVolArr, downVolArr] = request.security_lower_tf(syminfo.tickerid, lowerTF, upAndDownVolume())

// Computed on every bar (history-consistent)
float fallbackDelta = barLevelDelta()

int  n            = upVolArr.size()
bool hasLowerData = n > 0

// ── Walk intrabars: net delta + true intrabar high/low of the cum path ──
float ltfDelta = 0.0
float runMax   = 0.0
float runMin   = 0.0
if hasLowerData
    float run = 0.0
    for i = 0 to n - 1
        run    += nz(upVolArr.get(i)) + nz(downVolArr.get(i))
        runMax := math.max(runMax, run)
        runMin := math.min(runMin, run)
    ltfDelta := run

float delta = hasLowerData ? ltfDelta : fallbackDelta

// ─────────────────────────────────────────────
// RESET TRIGGER
// ─────────────────────────────────────────────
// Fixed at load so the 'Bars Back' window doesn't drift as live bars print
var int startBar = math.max(0, last_bar_index - barsBack)

// A reset period >= one chart bar would fire every bar → disable it
int resetSec = switch resetPeriod
    "Day"     => timeframe.in_seconds("D")
    "Session" => timeframe.in_seconds("D")
    "Week"    => timeframe.in_seconds("W")
    "Month"   => timeframe.in_seconds("M")
    "Year"    => timeframe.in_seconds("12M")
    =>           0
bool resetIgnored = resetSec > 0 and chartSec >= resetSec

bool rawReset = switch resetPeriod
    "None"      => false
    "Day"       => timeframe.change("D")
    "Session"   => session.isfirstbar_regular
    "Week"      => timeframe.change("W")
    "Month"     => timeframe.change("M")
    "Year"      => timeframe.change("12M")
    "Bars Back" => bar_index == startBar
    =>             false

bool shouldReset = rawReset and not resetIgnored
bool active      = resetPeriod != "Bars Back" or bar_index >= startBar

// Short resets (Day/Session/Week) self-heal; long ones restart at the first bar with real LTF data
bool shortReset = not resetIgnored and (resetPeriod == "Day" or resetPeriod == "Session" or resetPeriod == "Week")

var bool ltfStarted  = false
bool     firstLtfBar = hasLowerData and not ltfStarted
if hasLowerData
    ltfStarted := true

bool restartAtLtf = firstLtfBar and not shortReset

// ─────────────────────────────────────────────
// CUMULATIVE DELTA
// ─────────────────────────────────────────────
var float cumdelta = 0.0
float prevCum = (shouldReset or restartAtLtf) ? 0.0 : cumdelta
cumdelta := prevCum + delta

// ─────────────────────────────────────────────
// PER-BAR OHLC FOR CANDLES (real intrabar wicks when LTF data exists)
// ─────────────────────────────────────────────
float o = prevCum
float c = cumdelta
float h = hasLowerData ? prevCum + runMax : math.max(o, c)
float l = hasLowerData ? prevCum + runMin : math.min(o, c)

bool isBull = c >= o

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────
bool drawDelta   = showDelta and active
bool drawCandles = showCumCandles and active

deltaColor = delta >= 0 ? color.new(color.teal, 55) : color.new(color.red, 55)
plot(drawDelta ? delta : na, "Bar Delta", color=deltaColor, style=plot.style_columns)

candleColor = isBull ? color.lime : color.red
plotcandle(
     drawCandles ? o : na,
     drawCandles ? h : na,
     drawCandles ? l : na,
     drawCandles ? c : na,
     title       = "Cum Delta",
     color       = candleColor,
     wickcolor   = candleColor,
     bordercolor = candleColor)

hline(0, "Zero", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// ─────────────────────────────────────────────
// DATA QUALITY STATUS
// ─────────────────────────────────────────────
var bool hasVolume    = false
var int  fallbackBars = 0

if nz(volume) > 0
    hasVolume := true
    // Only count fallback bars that actually feed the current cumulative line
    if active and not hasLowerData and (shortReset or ltfStarted)
        fallbackBars += 1

var table status = table.new(position.top_right, 1, 1)

if barstate.islast and showStatus
    string msg = ""
    color  bg  = color.new(color.orange, 20)
    if not hasVolume
        msg := "No volume data — use futures (e.g. NIFTY1!)"
        bg  := color.new(color.red, 10)
    else
        if resetIgnored
            msg := addMsg(msg, resetPeriod + " reset ≥ chart TF — reset disabled")
        if customRejected
            msg := addMsg(msg, "Custom TF must be ≤ chart TF and divide it — using auto (" + autoLowerTF + ")")
        if not ltfStarted
            msg := addMsg(msg, "Lower-TF data unavailable — using bar-level fallback")
        else
            if ltfIsChartTF
                msg := addMsg(msg, "Lower TF = chart TF (" + lowerTFLabel + ") — no intrabar precision")
            if fallbackBars > 0
                msg := addMsg(msg, str.format("{0} older bars used bar-level fallback", fallbackBars))
    if msg != ""
        table.cell(status, 0, 0, msg, bgcolor=bg, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    else
        table.clear(status, 0, 0)
````
