# Meridian Session Atlas [JOAT]

- url: https://www.tradingview.com/script/mGIB1N3l-Meridian-Session-Atlas-JOAT/
- type: indicator
- pine_id: PUB;f6b1b1e9f24c47fa9eab9c19498a392f
- version: 1.0

## Description

[b]Meridian Session Atlas [JOAT][/b]

[b]Introduction[/b]

Meridian Session Atlas (MSA) is an open-source ICT-methodology session zone engine that renders all five major trading killzones — Asia, London, NY AM, NY Lunch, and NY PM — as live, price-tracking boxes on the chart. Each session gets its own high and low pivot lines that extend rightward until price sweeps them, a real-time session VWAP for fair-value reference, and a sweep detection system that fires when a wick pierces a session extreme and the bar closes back inside. Daily and weekly opening prices are overlaid as key reference levels. All five sessions are fully configurable: colors, time windows, and visibility can be customized independently.

The core problem MSA solves is the manual, time-consuming work of identifying and drawing session ranges each day. ICT traders use session high/low levels as primary liquidity pools — price regularly sweeps below Asia lows to grab sell-side liquidity before reversing, or above London highs to take buy-side liquidity before reversing. Identifying those sweeps in real time, across all sessions simultaneously, on a clean chart with VWAP context is what MSA automates completely.

[image]https://www.tradingview.com/x/NR4QSfqR/[/image]

[b]Core Concepts[/b]

[b]1. Session Detection and State Tracking[/b]

Each of the five sessions is detected using Pine Script's time() function with the user-configured session string and timezone. A session starts when the current bar's time falls inside the session window for the first time (transition from outside to inside), and ends when it transitions back out:

[pine]
bool asiaOn    = useAsia and not na(time("", asiaSess, tzInput))
bool asiaStart = asiaOn and not asiaOn[1]
bool asiaEnd   = not asiaOn and asiaOn[1]
[/pine]

On session start, the high, low, left bar index, and VWAP accumulators are reset. During the session, the high and low expand with each bar. On session end, the pivot lines are drawn and extended right.

[b]2. Killzone Boxes[/b]

Each session draws a box that expands in real time as the session progresses — the right edge and top/bottom move with each new bar's high and low. On session close, the box freezes at the final session high and low, creating a permanent visual record of that session's range. A configurable maximum history count prevents chart clutter by automatically deleting old session boxes when the count exceeds the limit.

[b]3. Session VWAP[/b]

Volume-weighted average price accumulates from the first bar of each session. The formula uses cumulative price-volume (hl2 * volume) divided by cumulative volume, resetting at each session start:

[pine]
float asiaVwap = asiaOn ? safeDiv(as_cpv, as_cv) : na
[/pine]

The VWAP is plotted as a line only during the active session, breaking between sessions. It represents the institutional fair-value level within each killzone — institutional order flow frequently uses the VWAP as an equilibrium reference.

[b]4. Liquidity Sweep Detection[/b]

A sweep is detected when price wicks through a session's pivot high or low and then closes back inside. The logic applies a minimum depth filter (default 0.1 ATR) to eliminate trivial tag-and-return moves, an optional body filter to confirm directional close bias, and a cooldown period to prevent multiple signals from the same sweep:

[pine]
if low < as_lo and close > as_lo and asWickDn >= minSweepATR * atrVal and asBodyOkB
    as_bullSweep := true
    as_sweep     := bar_index
[/pine]

A bullish sweep fires when price wicks below the session low and closes back above it — this is the ICT buy-side liquidity grab pattern. A bearish sweep fires when price wicks above the session high and closes back below — the sell-side liquidity grab. All five sessions are monitored simultaneously.

[b]5. Daily and Weekly Opens[/b]

The opening price of each new trading day and each new trading week is plotted as a horizontal line extending rightward. These levels represent the most important institutional reference prices of their respective periods — the daily open divides the day into a bullish (above) or bearish (below) context, and the weekly open does the same for the week.

[b]Features[/b]

[list]
[*][b]Five Independent Killzone Boxes:[/b] Asia, London, NY AM, NY Lunch, and NY PM each rendered as live price-tracking boxes with individual color, time, and visibility settings
[*][b]Session Pivot Lines:[/b] High and low pivot lines extend from each completed session's extreme until price sweeps through them, providing persistent liquidity pool reference
[*][b]Configurable Line Style:[/b] Pivot lines can be Solid, Dashed, or Dotted with adjustable width (1-3)
[*][b]Five Session VWAPs:[/b] Real-time volume-weighted average price plotted for each active session in its respective color
[*][b]Sweep Signal Labels:[/b] Bull and bear sweep labels fire at the bar where the wick/close confirmation occurs, sized Tiny, Small, or Normal, with the session name embedded in the label
[*][b]Sweep Depth Filter:[/b] Minimum wick depth in ATR multiples prevents noise from triggering false sweep signals
[*][b]Body Confirmation Filter:[/b] Optional close-in-upper/lower-half confirmation strengthens sweep signal quality
[*][b]Sweep Cooldown:[/b] Configurable bar count prevents multiple signals from the same sweep event
[*][b]Daily and Weekly Open Lines:[/b] Dotted (configurable) horizontal lines at the current day and week open prices
[*][b]Timeframe Gate:[/b] All indicator elements automatically hide when the chart timeframe exceeds a configurable threshold — prevents the indicator from rendering on timeframes where session boxes are too compressed to be useful
[*][b]Session History:[/b] Configurable maximum number of completed sessions to keep on chart (1-8 per killzone)
[*][b]9-Row Dashboard (Top Right):[/b] Active session name with color, session highs and lows for all five sessions, daily open price, current timeframe, and version
[*][b]Watermark:[/b] JackOfAllTrades signature at chart center-bottom
[*][b]Sweep Alerts:[/b] Separate bull and bear sweep alertconditions with plain-text or JSON webhook format
[/list]

[b]Input Parameters[/b]

[b]Main Settings:[/b]
[list]
[*]Timezone: Exchange or broker timezone for session alignment (default: America/New_York)
[*]Hide Above Timeframe: Chart TF at which indicator elements hide (default: 60-minute)
[*]Session History: Number of completed sessions to keep per killzone (default: 3)
[/list]

[b]Killzones (each session has identical controls):[/b]
[list]
[*]Enable toggle, session name, session time string, and color — fully independent per session
[*]Default sessions: Asia 20:00-00:00, London 02:00-05:00, NY AM 09:30-11:00, NY Lunch 12:00-13:00, NY PM 13:30-16:00 (all in New York time)
[/list]

[b]Session Pivots:[/b]
[list]
[*]Show Session Pivot Lines toggle
[*]Show Session VWAP toggle
[*]Pivot Line Style: Solid, Dashed, or Dotted
[*]Pivot Line Width: 1-3
[/list]

[b]Sweep Signals:[/b]
[list]
[*]Show Sweep Signals toggle
[*]Min Sweep Depth (ATR x): Minimum wick depth as a multiple of ATR (default: 0.1)
[*]Cooldown Bars: Minimum bars between sweep signals (default: 3)
[*]Body Confirmation: Close must be in directional half of the candle body (default: enabled)
[*]Signal Size: Tiny, Small, or Normal (default: Small)
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the Active Session[/b]
The dashboard shows the current active session in its color. The live session box is expanding in real time. This gives immediate context for whether you are in a high-liquidity killzone or off-session dead time.

[b]Step 2: Monitor Session Extremes for Liquidity Pools[/b]
Completed session highs and lows are the primary liquidity pools that ICT methodology targets. These are the levels where institutional order flow is placed — above previous highs (buy-side liquidity) and below previous lows (sell-side liquidity).

[b]Step 3: React to Sweep Signals[/b]
When a sweep label appears, price has hunted a session extreme and rejected it. A bull sweep (below a session low, close back above) represents a sell-side liquidity grab and potential long entry opportunity. A bear sweep (above a session high, close back below) represents a buy-side liquidity grab and potential short entry opportunity. Confirm with higher-timeframe bias and session VWAP position.

[b]Step 4: Use Session VWAP as Fair Value[/b]
Price above the active session VWAP is trading at a premium within that session. Price below is at a discount. ICT concepts suggest looking for longs from discount (below VWAP after a bullish sweep) and shorts from premium (above VWAP after a bearish sweep).

[b]Step 5: Reference Daily and Weekly Opens[/b]
The daily open is the most important intraday reference level. Price holding above the daily open is a bullish intraday context. Sweeps of the daily open low with a close recovery signal potential long opportunities.

[image]https://www.tradingview.com/x/7qp4CwSu/[/image]

[b]Indicator Limitations[/b]

[list]
[*]Session times are fixed to the timezone input. On instruments that trade across midnight or on non-standard sessions, the default session strings may need manual adjustment
[*]The timeframe gate hides the indicator above the configured threshold. On timeframes above that threshold, none of the visual elements render — intentional behavior to prevent meaningless session boxes on, for example, a daily chart
[*]VWAP calculation uses hl2 (average of high and low) multiplied by volume. On indices, synthetic instruments, or assets with unreliable volume data, the VWAP reading will not be accurate
[*]Sweep detection uses bar close as the confirmation. Intrabar wicks that would constitute sweeps but then recover within the same bar are captured; wicks that close beyond the pivot are not classified as sweeps (they become the new session extreme)
[*]Session history has a maximum of 8 completed sessions per killzone. On very long charts or after major gaps, the oldest session data is automatically removed
[/list]

[b]Originality Statement[/b]

MSA is original in its simultaneous, automated management of five independent session zones with unified sweep detection and VWAP integration. This indicator is published because:

[list]
[*]The integration of five simultaneous, independently configurable session zones — each with its own box, pivot lines, VWAP, and sweep detection — into a single, performance-efficient indicator is uncommon. Most session-zone indicators handle only one or two sessions
[*]The sweep detection algorithm applies three independent confirmation layers (ATR depth filter, body filter, cooldown) simultaneously across all five sessions, with a unified aggregated signal that names the originating session
[*]The session VWAP calculation resets correctly at each session boundary (not at day boundary), providing a genuine intra-killzone fair-value reference rather than a daily VWAP approximation
[*]The timeframe gate is a usability feature that prevents the indicator from rendering meaninglessly on timeframes where session granularity is lost
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Session high and low levels are historical reference points — price does not respect these levels in all market conditions, and sweep signals do not guarantee continuation in any direction. ICT methodology concepts described here represent one school of technical analysis and are not universally accepted. Always use proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(
    title            = "Meridian Session Atlas [JOAT]",
    shorttitle       = "MSA [JOAT]",
    overlay          = true,
    max_lines_count  = 500,
    max_labels_count = 500,
    max_boxes_count  = 500,
    max_bars_back    = 5000)

// ─── Groups ───────────────────────────────────────────────────────────────────
G_MAIN  = "Main Settings"
G_KZ    = "Killzones"
G_PIV   = "Session Pivots"
G_SWP   = "Sweep Signals"
G_DWM   = "Daily / Weekly Opens"
G_VIS   = "Visual Settings"
G_DASH  = "Dashboard"
G_ALERT = "Alerts"
G_COL   = "Colors"

INDICATOR_VERSION = "v1.1.0"

// ─── Inputs — Main ────────────────────────────────────────────────────────────
tzInput      = input.string("America/New_York", "Timezone",
    options=["America/New_York","Europe/London","Europe/Berlin","Asia/Tokyo",
             "Asia/Shanghai","Australia/Sydney","GMT+0","GMT+1","GMT+2","GMT+3",
             "GMT+4","GMT+5","GMT+6","GMT+7","GMT+8","GMT-3","GMT-4","GMT-5","GMT-6","GMT-7","GMT-8"],
    group=G_MAIN, tooltip="Set to your exchange or broker timezone for accurate session alignment")
tfLimitInput = input.timeframe("60", "Hide Above Timeframe", group=G_MAIN,
    tooltip="Indicator elements hide when chart TF >= this value")
maxSessInput = input.int(3, "Session History", minval=1, maxval=8, group=G_MAIN,
    tooltip="Number of completed sessions to keep on chart per killzone")

// ─── Inputs — Killzones ───────────────────────────────────────────────────────
showKzBoxes  = input.bool(true,  "Show Killzone Boxes",     group=G_KZ)
kzTransp     = input.int(82,     "Box Transparency",        minval=50, maxval=95, group=G_KZ)
useAsia      = input.bool(true,  "",  inline="kz1", group=G_KZ)
asiaName     = input.string("Asia",     "", inline="kz1", group=G_KZ)
asiaSess     = input.session("2000-0000","",inline="kz1", group=G_KZ)
asiaClr      = input.color(#42A5F5, "",  inline="kz1", group=G_KZ)
useLondon    = input.bool(true,  "",  inline="kz2", group=G_KZ)
londonName   = input.string("London",   "", inline="kz2", group=G_KZ)
londonSess   = input.session("0200-0500","",inline="kz2", group=G_KZ)
londonClr    = input.color(#EF5350, "",  inline="kz2", group=G_KZ)
useNyAm      = input.bool(true,  "",  inline="kz3", group=G_KZ)
nyAmName     = input.string("NY AM",    "", inline="kz3", group=G_KZ)
nyAmSess     = input.session("0930-1100","",inline="kz3", group=G_KZ)
nyAmClr      = input.color(#26A69A, "",  inline="kz3", group=G_KZ)
useNyLunch   = input.bool(true,  "",  inline="kz4", group=G_KZ)
nyLunchName  = input.string("NY Lunch", "", inline="kz4", group=G_KZ)
nyLunchSess  = input.session("1200-1300","",inline="kz4", group=G_KZ)
nyLunchClr   = input.color(#FFCA28, "",  inline="kz4", group=G_KZ)
useNyPm      = input.bool(true,  "",  inline="kz5", group=G_KZ)
nyPmName     = input.string("NY PM",    "", inline="kz5", group=G_KZ)
nyPmSess     = input.session("1330-1600","",inline="kz5", group=G_KZ)
nyPmClr      = input.color(#AB47BC, "",  inline="kz5", group=G_KZ)

// ─── Inputs — Pivots ──────────────────────────────────────────────────────────
showPivots   = input.bool(true,    "Show Session Pivot Lines",  group=G_PIV)
showVwap     = input.bool(true,    "Show Session VWAP",         group=G_PIV)
pvStyle      = input.string("Solid","Pivot Line Style", options=["Solid","Dashed","Dotted"], group=G_PIV)
pvWidth      = input.int(1,         "",  minval=1, maxval=3, inline="pvs", group=G_PIV)

// ─── Inputs — Sweeps ──────────────────────────────────────────────────────────
showSweeps   = input.bool(true,  "Show Sweep Signals",      group=G_SWP,
    tooltip="Label fires when wick pierces session pivot and close returns inside")
minSweepATR  = input.float(0.1,  "Min Sweep Depth (ATR x)", minval=0.0, maxval=1.0, step=0.05, group=G_SWP)
sweepCdn     = input.int(3,      "Cooldown Bars",           minval=0, maxval=20, group=G_SWP)
bodyFilter   = input.bool(true,  "Body Confirmation",       group=G_SWP,
    tooltip="Close must be in upper/lower half of candle body for sweep confirmation")
sweepSize    = input.string("Small","Signal Size", options=["Tiny","Small","Normal"], group=G_SWP)

// ─── Inputs — Daily/Weekly Opens ──────────────────────────────────────────────
showDOpen    = input.bool(true,   "Daily Open",   inline="dopen", group=G_DWM)
dOpenClr     = input.color(#42A5F5, "", inline="dopen", group=G_DWM)
showWOpen    = input.bool(true,   "Weekly Open",  inline="wopen", group=G_DWM)
wOpenClr     = input.color(#26A69A, "", inline="wopen", group=G_DWM)
dwmStyle     = input.string("Dotted","DWM Style", options=["Solid","Dashed","Dotted"], group=G_DWM)

// ─── Inputs — Visual ──────────────────────────────────────────────────────────
themeStr     = input.string("Auto","Theme", options=["Auto","Dark","Light"], group=G_VIS)
showDash     = input.bool(true,   "Show Dashboard", group=G_DASH)
dashPosStr   = input.string("Top Right","Position",
    options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=G_DASH)
showWM       = input.bool(true,   "Show Watermark",  group=G_VIS)
webhookFmt   = input.bool(false,  "Webhook JSON",    group=G_ALERT)
bullClr      = input.color(#00C853, "Bull Sweep",  inline="swclr", group=G_COL)
bearClr      = input.color(#D50000, "Bear Sweep",  inline="swclr", group=G_COL)

// ─── Theme ────────────────────────────────────────────────────────────────────
isDark  = switch themeStr
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128

TXT_M   = isDark ? color.new(#9E9E9E, 0) : color.new(#757575, 0)
TBL_BG  = isDark ? color.new(#0D1117, 5) : color.new(#FFFFFF, 5)
TBL_BD  = isDark ? color.new(#21262D, 0) : color.new(#D0D0D0, 0)
TBL_ALT = isDark ? color.new(#161B22, 0) : color.new(#F6F8FA, 0)
HDR_BG  = color.new(#1565C0, 0)
TXT_C   = isDark ? #E0E0E0 : #1A1A1A
WM_C    = isDark ? color.new(#FFFFFF, 85) : color.new(#000000, 85)

// ─── Utility ──────────────────────────────────────────────────────────────────
safeDiv(float n, float d, float fb = 0.0) =>
    d != 0.0 and not na(n) and not na(d) ? n / d : fb

getLStyle(string s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

getSigSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        =>          size.small

getDashPos(string s) =>
    switch s
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        =>               position.top_right

// Timeframe gate: hide on higher TFs
bool tfOk = timeframe.in_seconds() <= timeframe.in_seconds(tfLimitInput)

float atrVal  = nz(ta.atr(14), high - low)
float bodyMid = math.avg(open, close)

// ─── Session Active Checks ────────────────────────────────────────────────────
bool asiaOn    = useAsia    and not na(time("", asiaSess,    tzInput))
bool londonOn  = useLondon  and not na(time("", londonSess,  tzInput))
bool nyAmOn    = useNyAm    and not na(time("", nyAmSess,    tzInput))
bool nyLunchOn = useNyLunch and not na(time("", nyLunchSess, tzInput))
bool nyPmOn    = useNyPm    and not na(time("", nyPmSess,    tzInput))

// Session start / end transitions
bool asiaStart   = asiaOn    and not asiaOn[1]
bool asiaEnd     = not asiaOn    and asiaOn[1]
bool londonStart = londonOn  and not londonOn[1]
bool londonEnd   = not londonOn  and londonOn[1]
bool nyAmStart   = nyAmOn    and not nyAmOn[1]
bool nyAmEnd     = not nyAmOn    and nyAmOn[1]
bool nyLunchStart = nyLunchOn and not nyLunchOn[1]
bool nyLunchEnd   = not nyLunchOn and nyLunchOn[1]
bool nyPmStart   = nyPmOn    and not nyPmOn[1]
bool nyPmEnd     = not nyPmOn    and nyPmOn[1]

// ─── Per-Session State Variables ──────────────────────────────────────────────
// Asia
var float as_hi   = na
var float as_lo   = na
var int   as_left = na
var float as_cpv  = 0.0
var float as_cv   = 0.0
var int   as_sweep = 0
var box   as_box   = na
var line  as_hline = na
var line  as_lline = na
var array<box>  as_boxes  = array.new<box>()
var array<line> as_hlines = array.new<line>()
var array<line> as_llines = array.new<line>()

// London
var float lo_hi   = na
var float lo_lo   = na
var int   lo_left = na
var float lo_cpv  = 0.0
var float lo_cv   = 0.0
var int   lo_sweep = 0
var box   lo_box   = na
var line  lo_hline = na
var line  lo_lline = na
var array<box>  lo_boxes  = array.new<box>()
var array<line> lo_hlines = array.new<line>()
var array<line> lo_llines = array.new<line>()

// NY AM
var float am_hi   = na
var float am_lo   = na
var int   am_left = na
var float am_cpv  = 0.0
var float am_cv   = 0.0
var int   am_sweep = 0
var box   am_box   = na
var line  am_hline = na
var line  am_lline = na
var array<box>  am_boxes  = array.new<box>()
var array<line> am_hlines = array.new<line>()
var array<line> am_llines = array.new<line>()

// NY Lunch
var float ln_hi   = na
var float ln_lo   = na
var int   ln_left = na
var float ln_cpv  = 0.0
var float ln_cv   = 0.0
var int   ln_sweep = 0
var box   ln_box   = na
var line  ln_hline = na
var line  ln_lline = na
var array<box>  ln_boxes  = array.new<box>()
var array<line> ln_hlines = array.new<line>()
var array<line> ln_llines = array.new<line>()

// NY PM
var float pm_hi   = na
var float pm_lo   = na
var int   pm_left = na
var float pm_cpv  = 0.0
var float pm_cv   = 0.0
var int   pm_sweep = 0
var box   pm_box   = na
var line  pm_hline = na
var line  pm_lline = na
var array<box>  pm_boxes  = array.new<box>()
var array<line> pm_hlines = array.new<line>()
var array<line> pm_llines = array.new<line>()

// ─── Session Processing Helpers ───────────────────────────────────────────────
purgeOldBoxes(array<box> arr, int maxKeep) =>
    while array.size(arr) > maxKeep
        box.delete(array.shift(arr))

purgeOldLines(array<line> arr, int maxKeep) =>
    while array.size(arr) > maxKeep
        line.delete(array.shift(arr))

// ─── Asia Session ─────────────────────────────────────────────────────────────
if asiaStart
    as_hi   := high
    as_lo   := low
    as_left := bar_index
    as_cpv  := 0.0
    as_cv   := 0.0
    if showKzBoxes and tfOk
        as_box := box.new(bar_index, high, bar_index + 1, low,
            bgcolor=color.new(asiaClr, kzTransp), border_color=color.new(asiaClr, 60))
        array.push(as_boxes, as_box)
        purgeOldBoxes(as_boxes, maxSessInput)

if asiaOn
    as_hi  := math.max(as_hi, high)
    as_lo  := math.min(as_lo, low)
    as_cpv += hl2 * volume
    as_cv  += volume
    if showKzBoxes and tfOk and not na(as_box)
        box.set_right(as_box, bar_index + 1)
        box.set_top(as_box, as_hi)
        box.set_bottom(as_box, as_lo)

if asiaEnd and showPivots and tfOk and not na(as_hi)
    line.delete(as_hline)
    line.delete(as_lline)
    as_hline := line.new(as_left, as_hi, bar_index, as_hi,
        color=color.new(asiaClr, 20), width=pvWidth, style=getLStyle(pvStyle), extend=extend.right)
    as_lline := line.new(as_left, as_lo, bar_index, as_lo,
        color=color.new(asiaClr, 20), width=pvWidth, style=getLStyle(pvStyle), extend=extend.right)
    array.push(as_hlines, as_hline)
    array.push(as_llines, as_lline)
    purgeOldLines(as_hlines, maxSessInput)
    purgeOldLines(as_llines, maxSessInput)

bool as_bullSweep = false
bool as_bearSweep = false
if not asiaOn and not na(as_lo) and (bar_index - as_sweep) >= sweepCdn
    float asWickDn  = as_lo - low
    float asWickUp  = high - as_hi
    bool  asBodyOkB = not bodyFilter or close >= bodyMid
    bool  asBodyOkS = not bodyFilter or close <= bodyMid
    if low < as_lo and close > as_lo and asWickDn >= minSweepATR * atrVal and asBodyOkB
        as_bullSweep := true
        as_sweep     := bar_index
        if showPivots and not na(as_lline)
            line.set_x2(as_lline, bar_index)
            line.set_extend(as_lline, extend.none)
    if high > as_hi and close < as_hi and asWickUp >= minSweepATR * atrVal and asBodyOkS
        as_bearSweep := true
        as_sweep     := bar_index
        if showPivots and not na(as_hline)
            line.set_x2(as_hline, bar_index)
            line.set_extend(as_hline, extend.none)

// ─── London Session ───────────────────────────────────────────────────────────
if londonStart
    lo_hi   := high
    lo_lo   := low
    lo_left := bar_index
    lo_cpv  := 0.0
    lo_cv   := 0.0
    if showKzBoxes and tfOk
        lo_box := box.new(bar_index, high, bar_index + 1, low,
            bgcolor=color.new(londonClr, kzTransp), border_color=color.new(londonClr, 60))
        array.push(lo_boxes, lo_box)
        purgeOldBoxes(lo_boxes, maxSessInput)

if londonOn
    lo_hi  := math.max(lo_hi, high)
    lo_lo  := math.min(lo_lo, low)
    lo_cpv += hl2 * volume
    lo_cv  += volume
    if showKzBoxes and tfOk and not na(lo_box)
        box.set_right(lo_box, bar_index + 1)
        box.set_top(lo_box, lo_hi)
        box.set_bottom(lo_box, lo_lo)

if londonEnd and showPivots and tfOk and not na(lo_hi)
    line.delete(lo_hline)
    line.delete(lo_lline)
    lo_hline := line.new(lo_left, lo_hi, bar_index, lo_hi,
        color=color.new(londonClr, 20), width=pvWidth, style=getLStyle(pvStyle), extend=extend.right)
    lo_lline := line.new(lo_left, lo_lo, bar_index, lo_lo,
        color=color.new(londonClr, 20), width=pvWidth, style=getLStyle(pvStyle), extend=extend.right)
    array.push(lo_hlines, lo_hline)
    array.push(lo_llines, lo_lline)
    purgeOldLines(lo_hlines, maxSessInput)
    purgeOldLines(lo_llines, maxSessInput)

bool lo_bullSweep = false
bool lo_bearSweep = false
if not londonOn and not na(lo_lo) and (bar_index - lo_sweep) >= sweepCdn
    float loWickDn  = lo_lo - low
    float loWickUp  = high - lo_hi
    bool  loBodyOkB = not bodyFilter or close >= bodyMid
    bool  loBodyOkS = not bodyFilter or close <= bodyMid
    if low < lo_lo and close > lo_lo and loWickDn >= minSweepATR * atrVal and loBodyOkB
        lo_bullSweep := true
        lo_sweep     := bar_index
        if showPivots and not na(lo_lline)
            line.set_x2(lo_lline, bar_index)
            line.set_extend(lo_lline, extend.none)
    if high > lo_hi and close < lo_hi and loWickUp >= minSweepATR * atrVal and loBodyOkS
        lo_bearSweep := true
        lo_sweep     := bar_index
        if showPivots and not na(lo_hline)
            line.set_x2(lo_hline, bar_index)
            line.set_extend(lo_hline, extend.none)

// ─── NY AM Session ────────────────────────────────────────────────────────────
if nyAmStart
    am_hi   := high
    am_lo   := low
    am_left := bar_index
    am_cpv  := 0.0
    am_cv   := 0.0
    if showKzBoxes and tfOk
        am_box := box.new(bar_index, high, bar_index + 1, low,
            bgcolor=color.new(nyAmClr, kzTransp), border_color=color.new(nyAmClr, 60))
        array.push(am_boxes, am_box)
        purgeOldBoxes(am_boxes, maxSessInput)

if nyAmOn
    am_hi  := math.max(am_hi, high)
    am_lo  := math.min(am_lo, low)
    am_cpv += hl2 * volume
    am_cv  += volume
    if showKzBoxes and tfOk and not na(am_box)
        box.set_right(am_box, bar_index + 1)
        box.set_top(am_box, am_hi)
        box.set_bottom(am_box, am_lo)

if nyAmEnd and showPivots and tfOk and not na(am_hi)
    line.delete(am_hline)
    line.delete(am_lline)
    am_hline := line.new(am_left, am_hi, bar_index, am_hi,
        color=color.new(nyAmClr, 20), width=pvWidth, style=getLStyle(pvStyle), extend=extend.right)
    am_lline := line.new(am_left, am_lo, bar_index, am_lo,
        color=color.new(nyAmClr, 20), width=pvWidth, style=getLStyle(pvStyle), extend=extend.right)
    array.push(am_hlines, am_hline)
    array.push(am_llines, am_lline)
    purgeOldLines(am_hlines, maxSessInput)
    purgeOldLines(am_llines, maxSessInput)

bool am_bullSweep = false
bool am_bearSweep = false
if not nyAmOn and not na(am_lo) and (bar_index - am_sweep) >= sweepCdn
    float amWickDn  = am_lo - low
    float amWickUp  = high - am_hi
    bool  amBodyOkB = not bodyFilter or close >= bodyMid
    bool  amBodyOkS = not bodyFilter or close <= bodyMid
    if low < am_lo and close > am_lo and amWickDn >= minSweepATR * atrVal and amBodyOkB
        am_bullSweep := true
        am_sweep     := bar_index
        if showPivots and not na(am_lline)
            line.set_x2(am_lline, bar_index)
            line.set_extend(am_lline, extend.none)
    if high > am_hi and close < am_hi and amWickUp >= minSweepATR * atrVal and amBodyOkS
        am_bearSweep := true
        am_sweep     := bar_index
        if showPivots and not na(am_hline)
            line.set_x2(am_hline, bar_index)
            line.set_extend(am_hline, extend.none)

// ─── NY Lunch Session ─────────────────────────────────────────────────────────
if nyLunchStart
    ln_hi   := high
    ln_lo   := low
    ln_left := bar_index
    ln_cpv  := 0.0
    ln_cv   := 0.0
    if showKzBoxes and tfOk
        ln_box := box.new(bar_index, high, bar_index + 1, low,
            bgcolor=color.new(nyLunchClr, kzTransp), border_color=color.new(nyLunchClr, 60))
        array.push(ln_boxes, ln_box)
        purgeOldBoxes(ln_boxes, maxSessInput)

if nyLunchOn
    ln_hi  := math.max(ln_hi, high)
    ln_lo  := math.min(ln_lo, low)
    ln_cpv += hl2 * volume
    ln_cv  += volume
    if showKzBoxes and tfOk and not na(ln_box)
        box.set_right(ln_box, bar_index + 1)
        box.set_top(ln_box, ln_hi)
        box.set_bottom(ln_box, ln_lo)

if nyLunchEnd and showPivots and tfOk and not na(ln_hi)
    line.delete(ln_hline)
    line.delete(ln_lline)
    ln_hline := line.new(ln_left, ln_hi, bar_index, ln_hi,
        color=color.new(nyLunchClr, 20), width=pvWidth, style=getLStyle(pvStyle), extend=extend.right)
    ln_lline := line.new(ln_left, ln_lo, bar_index, ln_lo,
        color=color.new(nyLunchClr, 20), width=pvWidth, style=getLStyle(pvStyle), extend=extend.right)
    array.push(ln_hlines, ln_hline)
    array.push(ln_llines, ln_lline)
    purgeOldLines(ln_hlines, maxSessInput)
    purgeOldLines(ln_llines, maxSessInput)

bool ln_bullSweep = false
bool ln_bearSweep = false
if not nyLunchOn and not na(ln_lo) and (bar_index - ln_sweep) >= sweepCdn
    float lnWickDn  = ln_lo - low
    float lnWickUp  = high - ln_hi
    bool  lnBodyOkB = not bodyFilter or close >= bodyMid
    bool  lnBodyOkS = not bodyFilter or close <= bodyMid
    if low < ln_lo and close > ln_lo and lnWickDn >= minSweepATR * atrVal and lnBodyOkB
        ln_bullSweep := true
        ln_sweep     := bar_index
        if showPivots and not na(ln_lline)
            line.set_x2(ln_lline, bar_index)
            line.set_extend(ln_lline, extend.none)
    if high > ln_hi and close < ln_hi and lnWickUp >= minSweepATR * atrVal and lnBodyOkS
        ln_bearSweep := true
        ln_sweep     := bar_index
        if showPivots and not na(ln_hline)
            line.set_x2(ln_hline, bar_index)
            line.set_extend(ln_hline, extend.none)

// ─── NY PM Session ────────────────────────────────────────────────────────────
if nyPmStart
    pm_hi   := high
    pm_lo   := low
    pm_left := bar_index
    pm_cpv  := 0.0
    pm_cv   := 0.0
    if showKzBoxes and tfOk
        pm_box := box.new(bar_index, high, bar_index + 1, low,
            bgcolor=color.new(nyPmClr, kzTransp), border_color=color.new(nyPmClr, 60))
        array.push(pm_boxes, pm_box)
        purgeOldBoxes(pm_boxes, maxSessInput)

if nyPmOn
    pm_hi  := math.max(pm_hi, high)
    pm_lo  := math.min(pm_lo, low)
    pm_cpv += hl2 * volume
    pm_cv  += volume
    if showKzBoxes and tfOk and not na(pm_box)
        box.set_right(pm_box, bar_index + 1)
        box.set_top(pm_box, pm_hi)
        box.set_bottom(pm_box, pm_lo)

if nyPmEnd and showPivots and tfOk and not na(pm_hi)
    line.delete(pm_hline)
    line.delete(pm_lline)
    pm_hline := line.new(pm_left, pm_hi, bar_index, pm_hi,
        color=color.new(nyPmClr, 20), width=pvWidth, style=getLStyle(pvStyle), extend=extend.right)
    pm_lline := line.new(pm_left, pm_lo, bar_index, pm_lo,
        color=color.new(nyPmClr, 20), width=pvWidth, style=getLStyle(pvStyle), extend=extend.right)
    array.push(pm_hlines, pm_hline)
    array.push(pm_llines, pm_lline)
    purgeOldLines(pm_hlines, maxSessInput)
    purgeOldLines(pm_llines, maxSessInput)

bool pm_bullSweep = false
bool pm_bearSweep = false
if not nyPmOn and not na(pm_lo) and (bar_index - pm_sweep) >= sweepCdn
    float pmWickDn  = pm_lo - low
    float pmWickUp  = high - pm_hi
    bool  pmBodyOkB = not bodyFilter or close >= bodyMid
    bool  pmBodyOkS = not bodyFilter or close <= bodyMid
    if low < pm_lo and close > pm_lo and pmWickDn >= minSweepATR * atrVal and pmBodyOkB
        pm_bullSweep := true
        pm_sweep     := bar_index
        if showPivots and not na(pm_lline)
            line.set_x2(pm_lline, bar_index)
            line.set_extend(pm_lline, extend.none)
    if high > pm_hi and close < pm_hi and pmWickUp >= minSweepATR * atrVal and pmBodyOkS
        pm_bearSweep := true
        pm_sweep     := bar_index
        if showPivots and not na(pm_hline)
            line.set_x2(pm_hline, bar_index)
            line.set_extend(pm_hline, extend.none)

// ─── Aggregated Sweep Signals ─────────────────────────────────────────────────
bool anyBullSweep = as_bullSweep or lo_bullSweep or am_bullSweep or ln_bullSweep or pm_bullSweep
bool anyBearSweep = as_bearSweep or lo_bearSweep or am_bearSweep or ln_bearSweep or pm_bearSweep

string sweepSessName = as_bullSweep or as_bearSweep ? asiaName : lo_bullSweep or lo_bearSweep ? londonName : am_bullSweep or am_bearSweep ? nyAmName : ln_bullSweep or ln_bearSweep ? nyLunchName : pm_bullSweep or pm_bearSweep ? nyPmName : ""

// ─── Sweep Signal Labels ──────────────────────────────────────────────────────
if showSweeps and tfOk and barstate.isconfirmed
    sz = getSigSize(sweepSize)
    if anyBullSweep
        label.new(bar_index, low,  "Sweep\n" + sweepSessName,
            style=label.style_label_up, color=bullClr, textcolor=#FFFFFF, size=sz)
    if anyBearSweep
        label.new(bar_index, high, "Sweep\n" + sweepSessName,
            style=label.style_label_down, color=bearClr, textcolor=#FFFFFF, size=sz)

// ─── Session VWAP Plots ───────────────────────────────────────────────────────
float asiaVwap    = asiaOn    ? safeDiv(as_cpv, as_cv) : na
float londonVwap  = londonOn  ? safeDiv(lo_cpv, lo_cv) : na
float nyAmVwap    = nyAmOn    ? safeDiv(am_cpv, am_cv) : na
float nyLunchVwap = nyLunchOn ? safeDiv(ln_cpv, ln_cv) : na
float nyPmVwap    = nyPmOn    ? safeDiv(pm_cpv, pm_cv) : na

plot(showVwap ? asiaVwap    : na, "Asia VWAP",     color=color.new(asiaClr,    40), linewidth=1, style=plot.style_linebr)
plot(showVwap ? londonVwap  : na, "London VWAP",   color=color.new(londonClr,  40), linewidth=1, style=plot.style_linebr)
plot(showVwap ? nyAmVwap    : na, "NY AM VWAP",    color=color.new(nyAmClr,    40), linewidth=1, style=plot.style_linebr)
plot(showVwap ? nyLunchVwap : na, "NY Lunch VWAP", color=color.new(nyLunchClr, 40), linewidth=1, style=plot.style_linebr)
plot(showVwap ? nyPmVwap    : na, "NY PM VWAP",    color=color.new(nyPmClr,    40), linewidth=1, style=plot.style_linebr)

// ─── Daily / Weekly Open Lines ────────────────────────────────────────────────
var float dOpenPrice = na
var float wOpenPrice = na
var line  dOpenLine  = na
var line  wOpenLine  = na

bool newDay  = ta.change(time("D")) != 0
bool newWeek = ta.change(time("W")) != 0

if newDay and showDOpen
    dOpenPrice := open
    line.delete(dOpenLine)
    dOpenLine := line.new(bar_index, open, bar_index + 1, open,
        color=dOpenClr, width=1, style=getLStyle(dwmStyle), extend=extend.right)

if newWeek and showWOpen
    wOpenPrice := open
    line.delete(wOpenLine)
    wOpenLine := line.new(bar_index, open, bar_index + 1, open,
        color=wOpenClr, width=1, style=getLStyle(dwmStyle), extend=extend.right)

// ─── Dashboard ────────────────────────────────────────────────────────────────
string activeSess = nyPmOn ? nyPmName : nyLunchOn ? nyLunchName : nyAmOn ? nyAmName : londonOn ? londonName : asiaOn ? asiaName : "Off-Session"

if showDash and barstate.islast
    var table tbl = table.new(getDashPos(dashPosStr), 2, 9, TBL_BG, TBL_BD, 1, TBL_BD, 1)

    table.cell(tbl, 0, 0, "JOAT  |  Meridian Atlas",
        text_color=#FFFFFF, bgcolor=HDR_BG, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    table.cell(tbl, 0, 1, "Active Session", text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 1, activeSess,
        text_color= asiaOn ? asiaClr : londonOn ? londonClr : nyAmOn ? nyAmClr : nyLunchOn ? nyLunchClr : nyPmOn ? nyPmClr : TXT_M,
        text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 2, "Asia H / L",    text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 2, not na(as_hi) ? str.tostring(as_hi, format.mintick) + " / " + str.tostring(as_lo, format.mintick) : "—",
        text_color=asiaClr, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 3, "London H / L",  text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 3, not na(lo_hi) ? str.tostring(lo_hi, format.mintick) + " / " + str.tostring(lo_lo, format.mintick) : "—",
        text_color=londonClr, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 4, "NY AM H / L",   text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 4, not na(am_hi) ? str.tostring(am_hi, format.mintick) + " / " + str.tostring(am_lo, format.mintick) : "—",
        text_color=nyAmClr, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 5, "NY Lunch H / L",text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 5, not na(ln_hi) ? str.tostring(ln_hi, format.mintick) + " / " + str.tostring(ln_lo, format.mintick) : "—",
        text_color=nyLunchClr, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 6, "Daily Open",    text_color=TXT_M, text_size=size.small, bgcolor=TBL_ALT)
    table.cell(tbl, 1, 6, not na(dOpenPrice) ? str.tostring(dOpenPrice, format.mintick) : "—",
        text_color=dOpenClr, text_size=size.small, bgcolor=TBL_ALT)

    table.cell(tbl, 0, 7, "Timeframe",     text_color=TXT_M, text_size=size.small, bgcolor=TBL_BG)
    table.cell(tbl, 1, 7, timeframe.period, text_color=TXT_C, text_size=size.small, bgcolor=TBL_BG)

    table.cell(tbl, 0, 8, "Version",       text_color=TXT_M, text_size=size.tiny,  bgcolor=TBL_ALT)
    table.cell(tbl, 1, 8, INDICATOR_VERSION, text_color=TXT_M, text_size=size.tiny, bgcolor=TBL_ALT)

// ─── Watermark ────────────────────────────────────────────────────────────────
if showWM and barstate.islast
    var table wmT = table.new(position.bottom_center, 1, 1,
        bgcolor=color.new(color.black, 100), border_color=color.new(color.black, 100), border_width=0)
    table.cell(wmT, 0, 0, "JackOfAllTrades",
        text_color=WM_C, text_size=size.normal, text_halign=text.align_center,
        bgcolor=color.new(color.black, 100))

// ─── Alerts ───────────────────────────────────────────────────────────────────
string tkr = syminfo.tickerid
string tf  = timeframe.period
string pxS = str.tostring(close, format.mintick)

if barstate.isconfirmed
    if anyBullSweep
        string bTxt  = "MSA Bull Sweep | " + sweepSessName + " | " + tkr + " | TF: " + tf + " | " + pxS
        string bJson = '{"event":"bull_sweep","session":"' + sweepSessName + '","ticker":"' + tkr + '","tf":"' + tf + '","price":' + pxS + '}'
        alert(webhookFmt ? bJson : bTxt, alert.freq_once_per_bar_close)
    if anyBearSweep
        string sTxt  = "MSA Bear Sweep | " + sweepSessName + " | " + tkr + " | TF: " + tf + " | " + pxS
        string sJson = '{"event":"bear_sweep","session":"' + sweepSessName + '","ticker":"' + tkr + '","tf":"' + tf + '","price":' + pxS + '}'
        alert(webhookFmt ? sJson : sTxt, alert.freq_once_per_bar_close)

alertcondition(anyBullSweep, "Bull Liquidity Sweep", "MSA: Bullish liquidity sweep detected")
alertcondition(anyBearSweep, "Bear Liquidity Sweep", "MSA: Bearish liquidity sweep detected")
````
