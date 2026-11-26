# Session VWAP + StdDev Bands [ChartPrime]

- url: https://www.tradingview.com/script/dHMkXOME-Session-VWAP-StdDev-Bands-ChartPrime/
- type: indicator
- pine_id: PUB;69783b7908a148a39d7b4717d60d0ed2
- version: 1.0

## Description

[b]🔶 OVERVIEW[/b]
[b]Session VWAP + StdDev Bands [ChartPrime][/b] is a professional-grade anchored VWAP system that resets on a user-defined higher timeframe and builds a full standard deviation band structure around it. Unlike a rolling VWAP, this indicator recalculates from the first bar of each new session, giving you a clean, unbiased volume-weighted price reference that reflects exactly where the market has traded relative to volume since the session opened.

The tool goes beyond a simple VWAP line by tracking how many times price has retested each individual band, using that retest count to dynamically intensify the color of each line — the more a level is tested, the more significant it becomes visually. Cumulative volume at each retest is also tracked and displayed, giving traders institutional-grade context directly on the chart.

• Anchored VWAP with configurable higher timeframe reset (Daily, Weekly, Monthly, etc.)
• Three independent standard deviation band pairs (1σ, 2σ, 3σ)
• Per-line retest counter with dynamic color intensity — more retests = brighter line
• Cumulative volume tracking per band displayed in live edge labels
• High/Low wick-based band touch signals with cooldown control
• Clean session break with automatic label and state reset


[b]🔶 CORE CONCEPT — ANCHORED VWAP WITH VOLUME-WEIGHTED STANDARD DEVIATION[/b]
Standard VWAP indicators use session time as the anchor. This indicator uses a higher timeframe bar close as the reset trigger, giving you full control over the session definition:

• [b]Anchored Reset:[/b] When the selected higher timeframe (e.g. Weekly) closes a new bar, the VWAP and all standard deviation calculations reset from zero. This ensures the VWAP always reflects the current session's volume distribution.
• [b]True StdDev Bands:[/b] Bands are calculated using a volume-weighted variance formula — not ATR, not simple standard deviation. This means the bands expand and contract based on how dispersed price has been relative to volume, not just raw price movement.
• [b]Dynamic Color Intensity:[/b] Each of the seven lines (VWAP + 6 band lines) tracks its own retest count independently. As price crosses a line more times, its transparency decreases and the line becomes fully saturated — a visual heatmap of the most contested price levels in the session.


[b]🔶 RETEST COUNTING & VOLUME TRACKING[/b]
The intelligence of this indicator lives in its per-line memory system:
[list]
[*] [b]Independent Counters:[/b] Every line — VWAP, 1σ Upper, 1σ Lower, 2σ Upper, 2σ Lower, 3σ Upper, 3σ Lower — has its own retest counter that increments on every close-based cross.
[*] [b]Color Intensity Mapping:[/b] Each retest reduces the line's transparency by 10 points. A line with 0 retests starts at 100% transparent (invisible). After 10 retests it reaches full opacity. This creates a natural visual hierarchy where the most-tested levels stand out.
[*] [b]Cumulative Volume:[/b] Every time a line is crossed, the bar's volume is added to that line's running total. The edge label displays both the retest count and the total volume that flowed through that level — e.g. "1σ↑  4  (vol. 2.3M)".
[*] [b]Session Reset:[/b] All counters, volumes, and labels reset cleanly at the start of each new session.
[/list]


[b]🔶 BAND TOUCH SIGNALS[/b]
Signal shapes fire when price wicks into a band rather than waiting for a close-based cross, making them more responsive to intrabar reactions at key levels:
[list]
[*] [b]Bull Signal (Blue Diamond):[/b] The bar's low drops to or below a band line while the previous bar's low was above it — a wick touch from above, indicating potential support reaction.
[*] [b]Bear Signal (Orange Diamond):[/b] The bar's high reaches or exceeds a band line while the previous bar's high was below it — a wick touch from below, indicating potential resistance reaction.
[*] [b]Cooldown Filter:[/b] A configurable cooldown (default 20 bars) prevents signal clusters at the same level. Once a signal fires, the same direction cannot fire again until the cooldown expires.
[/list]


[b]🔶 LIVE EDGE LABELS[/b]
Each band line carries a floating label anchored to the right edge of the chart that updates every bar:
[list]
[*] Labels display the band name, retest count, and cumulative volume in a compact single-line format.
[*] Label text color matches the line's current dynamic color — as the line intensifies, the label text intensifies with it.
[*] Labels reset and reposition automatically on each new session, always staying aligned with the current band price level.
[*] Label size is fully configurable from Tiny to Huge to suit any screen or timeframe.
[/list]


[b]🔶 HOW TO USE[/b]
[list]
[*] [b]Identifying Key Levels:[/b] Watch which bands accumulate the most retests during a session. A 1σ band with 6+ retests and high cumulative volume is a high-conviction support or resistance zone — treat it like a volume node.
[*] [b]Trend Bias:[/b] Price consistently closing above VWAP signals bullish session bias. Price consistently closing below signals bearish bias. Use the VWAP retest count to gauge how contested the mean is.
[*] [b]Breakout Confirmation:[/b] When price breaks through a 2σ or 3σ band with a strong close, the band color will begin to intensify on subsequent retests. A bright outer band that holds as support after a breakout is a high-probability continuation signal.
[*] [b]Fading Extremes:[/b] Bear signals at 2σ or 3σ upper bands and bull signals at 2σ or 3σ lower bands are mean-reversion opportunities, especially when cumulative volume at those levels is low (few retests, thin volume).
[*] [b]Timeframe Selection:[/b] Use Weekly reset on daily charts for swing trading context. Use Daily reset on intraday charts for intraday VWAP analysis. Use Monthly reset on daily or weekly charts for macro-level value area mapping.
[/list]


[b]🔶 CONCLUSION[/b]
[b]Session VWAP + StdDev Bands [ChartPrime][/b] turns a standard VWAP into a living, session-aware price map. By combining anchored volume-weighted calculations with per-line retest memory and cumulative volume tracking, it gives traders a clear picture of where the market has spent the most energy — and which levels are likely to matter most as the session develops.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartPrime
//@version=6

indicator("Session VWAP + StdDev Bands [ChartPrime]", overlay = true, max_labels_count = 500)

// ─── TOOLTIPS ─────────────────────────────────────────────────────────────────
string TT_HTF      = "Higher timeframe to monitor. When this timeframe closes a new bar, VWAP resets and starts recalculating from that point."
string TT_SRC      = "Price source used for VWAP calculation. Default is HLC3 (typical price)."
string TT_MULT1    = "Standard deviation multiplier for Band 1. Controls how wide the inner band is from VWAP."
string TT_MULT2    = "Standard deviation multiplier for Band 2. Controls how wide the middle band is from VWAP."
string TT_MULT3    = "Standard deviation multiplier for Band 3. Controls how wide the outer band is from VWAP."
string TT_SBAND1   = "Toggle visibility of Band 1 (inner standard deviation band)."
string TT_SBAND2   = "Toggle visibility of Band 2 (middle standard deviation band)."
string TT_SBAND3   = "Toggle visibility of Band 3 (outer standard deviation band)."
string TT_BSIGNALS = "Show signals when price high or low touches any of the standard deviation bands."
string TT_COOLDOWN = "Minimum number of bars that must pass before the same retest signal can fire again. Prevents signal clusters on the same band."
string TT_LBLSIZE  = "Size of the retest count labels displayed at the right edge of each band line."

// ─── INPUTS ───────────────────────────────────────────────────────────────────
htfInput        = input.timeframe("W", "Higher Timeframe",               tooltip = TT_HTF,     group = "Session")
srcInput        = input.source(hlc3,   "Source",                         tooltip = TT_SRC,     group = "Session")

mult1           = input.float(1.0, "Band Multiplier 1", step = 0.5,      tooltip = TT_MULT1,   group = "Bands")
mult2           = input.float(2.0, "Band Multiplier 2", step = 0.5,      tooltip = TT_MULT2,   group = "Bands")
mult3           = input.float(3.0, "Band Multiplier 3", step = 0.5,      tooltip = TT_MULT3,   group = "Bands")

showBand1       = input.bool(true,  "Band 1", inline = "b1",  tooltip = TT_SBAND1,  group = "Visibility")
band1Color      = input.color(color.aqua,   "",               inline = "b1",        tooltip = TT_SBAND1,  group = "Visibility")
showBand2       = input.bool(true,  "Band 2", inline = "b2",  tooltip = TT_SBAND2,  group = "Visibility")
band2Color      = input.color(color.blue,   "",               inline = "b2",        tooltip = TT_SBAND2,  group = "Visibility")
showBand3       = input.bool(true,  "Band 3", inline = "b3",  tooltip = TT_SBAND3,  group = "Visibility")
band3Color      = input.color(color.purple, "",               inline = "b3",        tooltip = TT_SBAND3,  group = "Visibility")
showBandSignals = input.bool(true,  "Show Band Retest Signals", tooltip = TT_BSIGNALS, group = "Visibility")
cooldownBars    = input.int(20,     "Retest Signal Cooldown (Bars)", minval = 1, maxval = 50, tooltip = TT_COOLDOWN, group = "Visibility")
lblSizeInput    = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], tooltip = TT_LBLSIZE, group = "Visibility")

vwapColor       = input.color(color.new(#e2e8f0, 0), "VWAP", group = "Colors")

// ─── LABEL SIZE MAPPING ───────────────────────────────────────────────────────
lblSize = switch lblSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.normal

// ─── HTF CHANGE DETECTION ─────────────────────────────────────────────────────
htfTime           = request.security(syminfo.tickerid, htfInput, time, lookahead = barmerge.lookahead_off)
bool sessionStart = ta.change(htfTime) != 0

// ─── VWAP CALCULATION ─────────────────────────────────────────────────────────
var float cumPV  = 0.0
var float cumV   = 0.0
var float cumPPV = 0.0
var bool  active = false

if sessionStart
    cumPV  := srcInput * volume
    cumV   := volume
    cumPPV := srcInput * srcInput * volume
    active := true
else if active
    cumPV  += srcInput * volume
    cumV   += volume
    cumPPV += srcInput * srcInput * volume

float vwap  = na
float stdev = na

if active and cumV > 0
    vwap          := cumPV / cumV
    float variance = math.max(cumPPV / cumV - math.pow(vwap, 2), 0.0)
    stdev         := math.sqrt(variance)

// ─── BAND LEVELS ──────────────────────────────────────────────────────────────
float upper1 = na(vwap) ? na : vwap + stdev * mult1
float lower1 = na(vwap) ? na : vwap - stdev * mult1
float upper2 = na(vwap) ? na : vwap + stdev * mult2
float lower2 = na(vwap) ? na : vwap - stdev * mult2
float upper3 = na(vwap) ? na : vwap + stdev * mult3
float lower3 = na(vwap) ? na : vwap - stdev * mult3

// ─── CROSSES — close-based for retest counts and line intensity ───────────────
bool crossOverVwap  = ta.crossover(close, vwap)
bool crossUnderVwap = ta.crossunder(close, vwap)

bool crossOverU1    = ta.crossover(close, upper1)
bool crossUnderU1   = ta.crossunder(close, upper1)
bool crossOverL1    = ta.crossover(close, lower1)
bool crossUnderL1   = ta.crossunder(close, lower1)

bool crossOverU2    = ta.crossover(close, upper2)
bool crossUnderU2   = ta.crossunder(close, upper2)
bool crossOverL2    = ta.crossover(close, lower2)
bool crossUnderL2   = ta.crossunder(close, lower2)

bool crossOverU3    = ta.crossover(close, upper3)
bool crossUnderU3   = ta.crossunder(close, upper3)
bool crossOverL3    = ta.crossover(close, lower3)
bool crossUnderL3   = ta.crossunder(close, lower3)

// ─── HIGH/LOW TOUCHES — used for signal shapes only ──────────────────────────
bool hlTouchBullU1 = not na(upper1) and low <= upper1 and low[1] > upper1[1]
bool hlTouchBullL1 = not na(lower1) and low <= lower1 and low[1] > lower1[1]
bool hlTouchBullU2 = not na(upper2) and low <= upper2 and low[1] > upper2[1]
bool hlTouchBullL2 = not na(lower2) and low <= lower2 and low[1] > lower2[1]
bool hlTouchBullU3 = not na(upper3) and low <= upper3 and low[1] > upper3[1]
bool hlTouchBullL3 = not na(lower3) and low <= lower3 and low[1] > lower3[1]

bool hlTouchBearU1 = not na(upper1) and high >= upper1 and high[1] < upper1[1]
bool hlTouchBearL1 = not na(lower1) and high >= lower1 and high[1] < lower1[1]
bool hlTouchBearU2 = not na(upper2) and high >= upper2 and high[1] < upper2[1]
bool hlTouchBearL2 = not na(lower2) and high >= lower2 and high[1] < lower2[1]
bool hlTouchBearU3 = not na(upper3) and high >= upper3 and high[1] < upper3[1]
bool hlTouchBearL3 = not na(lower3) and high >= lower3 and high[1] < lower3[1]

// ─── INDIVIDUAL RETEST COUNTS + CUMULATIVE VOLUME — reset each session ────────
var int   retestVwap = 0
var int   retestU1   = 0
var int   retestL1   = 0
var int   retestU2   = 0
var int   retestL2   = 0
var int   retestU3   = 0
var int   retestL3   = 0

var float volVwap    = 0.0
var float volU1      = 0.0
var float volL1      = 0.0
var float volU2      = 0.0
var float volL2      = 0.0
var float volU3      = 0.0
var float volL3      = 0.0

if sessionStart
    retestVwap := 0
    retestU1   := 0
    retestL1   := 0
    retestU2   := 0
    retestL2   := 0
    retestU3   := 0
    retestL3   := 0
    volVwap    := 0.0
    volU1      := 0.0
    volL1      := 0.0
    volU2      := 0.0
    volL2      := 0.0
    volU3      := 0.0
    volL3      := 0.0

if active and not na(vwap)
    if crossOverVwap or crossUnderVwap
        retestVwap += 1
        volVwap    += volume
    if crossOverU1 or crossUnderU1
        retestU1   += 1
        volU1      += volume
    if crossOverL1 or crossUnderL1
        retestL1   += 1
        volL1      += volume
    if crossOverU2 or crossUnderU2
        retestU2   += 1
        volU2      += volume
    if crossOverL2 or crossUnderL2
        retestL2   += 1
        volL2      += volume
    if crossOverU3 or crossUnderU3
        retestU3   += 1
        volU3      += volume
    if crossOverL3 or crossUnderL3
        retestL3   += 1
        volL3      += volume

// ─── MAP RETEST COUNT → TRANSPARENCY ──────────────────────────────────────────
transpFromCount(int n) =>
    math.max(100 - n * 10, 0)

// ─── DERIVED LINE COLORS — each line independently driven ─────────────────────
color lineVwap = color.new(vwapColor,  int(transpFromCount(retestVwap)))
color lineU1   = color.new(band1Color, int(transpFromCount(retestU1)))
color lineL1   = color.new(band1Color, int(transpFromCount(retestL1)))
color lineU2   = color.new(band2Color, int(transpFromCount(retestU2)))
color lineL2   = color.new(band2Color, int(transpFromCount(retestL2)))
color lineU3   = color.new(band3Color, int(transpFromCount(retestU3)))
color lineL3   = color.new(band3Color, int(transpFromCount(retestL3)))

// ─── LABEL TEXT BUILDER ───────────────────────────────────────────────────────
buildLabel(string name, int count, float vol) =>
    name + "  " + str.tostring(count) + "  (vol. " + str.tostring(vol, format.volume) + ")"

// ─── PLOT VALUES — na break on session start ──────────────────────────────────
float plotVwap = sessionStart ? na : vwap
float plotU1   = sessionStart ? na : upper1
float plotL1   = sessionStart ? na : lower1
float plotU2   = sessionStart ? na : upper2
float plotL2   = sessionStart ? na : lower2
float plotU3   = sessionStart ? na : upper3
float plotL3   = sessionStart ? na : lower3

// ─── COOLDOWN TRACKING ────────────────────────────────────────────────────────
var int lastBullRetestBar = -999
var int lastBearRetestBar = -999

bool bullCooldownOk = (bar_index - lastBullRetestBar) >= cooldownBars
bool bearCooldownOk = (bar_index - lastBearRetestBar) >= cooldownBars

// ─── BAND RETEST SIGNALS — driven by high/low touching bands ─────────────────
bool rawBullRetest = showBandSignals and active and not na(vwap) and
     (hlTouchBullU1 or hlTouchBullL1 or hlTouchBullU2 or hlTouchBullL2 or hlTouchBullU3 or hlTouchBullL3)

bool rawBearRetest = showBandSignals and active and not na(vwap) and
     (hlTouchBearU1 or hlTouchBearL1 or hlTouchBearU2 or hlTouchBearL2 or hlTouchBearU3 or hlTouchBearL3)

bool anyBullRetest = rawBullRetest and bullCooldownOk
bool anyBearRetest = rawBearRetest and bearCooldownOk

if anyBullRetest
    lastBullRetestBar := bar_index
if anyBearRetest
    lastBearRetestBar := bar_index

// ─── PLOTS ────────────────────────────────────────────────────────────────────
plot(plotVwap,                "VWAP",    color = lineVwap, linewidth = 2, style = plot.style_linebr)
plot(showBand1 ? plotU1 : na, "Upper 1", color = lineU1,   linewidth = 2, style = plot.style_linebr)
plot(showBand1 ? plotL1 : na, "Lower 1", color = lineL1,   linewidth = 2, style = plot.style_linebr)
plot(showBand2 ? plotU2 : na, "Upper 2", color = lineU2,   linewidth = 2, style = plot.style_linebr)
plot(showBand2 ? plotL2 : na, "Lower 2", color = lineL2,   linewidth = 2, style = plot.style_linebr)
plot(showBand3 ? plotU3 : na, "Upper 3", color = lineU3,   linewidth = 2, style = plot.style_linebr)
plot(showBand3 ? plotL3 : na, "Lower 3", color = lineL3,   linewidth = 2, style = plot.style_linebr)

// ─── RETEST COUNT LABELS ──────────────────────────────────────────────────────
var label lblVwap = na
var label lblU1   = na
var label lblL1   = na
var label lblU2   = na
var label lblL2   = na
var label lblU3   = na
var label lblL3   = na

if sessionStart
    label.delete(lblVwap)
    label.delete(lblU1)
    label.delete(lblL1)
    label.delete(lblU2)
    label.delete(lblL2)
    label.delete(lblU3)
    label.delete(lblL3)
    lblVwap := na
    lblU1   := na
    lblL1   := na
    lblU2   := na
    lblL2   := na
    lblU3   := na
    lblL3   := na

    lblVwap := label.new(bar_index, nz(vwap[1]),   "", style = label.style_label_left, color = #00000000, textcolor = vwapColor,  size = lblSize)
    lblU1   := label.new(bar_index, nz(upper1[1]), "", style = label.style_label_left, color = #00000000, textcolor = band1Color, size = lblSize)
    lblL1   := label.new(bar_index, nz(lower1[1]), "", style = label.style_label_left, color = #00000000, textcolor = band1Color, size = lblSize)
    lblU2   := label.new(bar_index, nz(upper2[1]), "", style = label.style_label_left, color = #00000000, textcolor = band2Color, size = lblSize)
    lblL2   := label.new(bar_index, nz(lower2[1]), "", style = label.style_label_left, color = #00000000, textcolor = band2Color, size = lblSize)
    lblU3   := label.new(bar_index, nz(upper3[1]), "", style = label.style_label_left, color = #00000000, textcolor = band3Color, size = lblSize)
    lblL3   := label.new(bar_index, nz(lower3[1]), "", style = label.style_label_left, color = #00000000, textcolor = band3Color, size = lblSize)

if not na(lblVwap) and not na(vwap)
    label.set_xy(lblVwap, bar_index + 2, vwap)
    label.set_text(lblVwap, buildLabel("VWAP", retestVwap, volVwap))
    label.set_textcolor(lblVwap, lineVwap)
    label.set_size(lblVwap, lblSize)

if not na(lblU1) and not na(upper1)
    label.set_xy(lblU1, bar_index + 2, upper1)
    label.set_text(lblU1, buildLabel("1σ↑", retestU1, volU1))
    label.set_textcolor(lblU1, lineU1)
    label.set_size(lblU1, lblSize)

if not na(lblL1) and not na(lower1)
    label.set_xy(lblL1, bar_index + 2, lower1)
    label.set_text(lblL1, buildLabel("1σ↓", retestL1, volL1))
    label.set_textcolor(lblL1, lineL1)
    label.set_size(lblL1, lblSize)

if not na(lblU2) and not na(upper2)
    label.set_xy(lblU2, bar_index + 2, upper2)
    label.set_text(lblU2, buildLabel("2σ↑", retestU2, volU2))
    label.set_textcolor(lblU2, lineU2)
    label.set_size(lblU2, lblSize)

if not na(lblL2) and not na(lower2)
    label.set_xy(lblL2, bar_index + 2, lower2)
    label.set_text(lblL2, buildLabel("2σ↓", retestL2, volL2))
    label.set_textcolor(lblL2, lineL2)
    label.set_size(lblL2, lblSize)

if not na(lblU3) and not na(upper3)
    label.set_xy(lblU3, bar_index + 2, upper3)
    label.set_text(lblU3, buildLabel("3σ↑", retestU3, volU3))
    label.set_textcolor(lblU3, lineU3)
    label.set_size(lblU3, lblSize)

if not na(lblL3) and not na(lower3)
    label.set_xy(lblL3, bar_index + 2, lower3)
    label.set_text(lblL3, buildLabel("3σ↓", retestL3, volL3))
    label.set_textcolor(lblL3, lineL3)
    label.set_size(lblL3, lblSize)

// ─── SIGNAL SHAPES ────────────────────────────────────────────────────────────
plotshape(anyBullRetest, "Bull Band Retest", shape.diamond, location.belowbar, color.new(#2289c5, 15), size = size.tiny)
plotshape(anyBearRetest, "Bear Band Retest", shape.diamond, location.abovebar, color.new(#ef6c44, 15), size = size.tiny)
````
