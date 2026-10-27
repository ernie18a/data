# Trend Tracker Trade Planner [Nick789]

- url: https://www.tradingview.com/script/RkvygYjb-Trend-Tracker-Trade-Planner-Nick789/
- type: indicator
- pine_id: PUB;a59e39837c154d9abca8618426ecf04c
- version: 11.0

## Description

Trend Tracker Trade Planner [Nick789]

Overview
The Trend Tracker Trade Planner is a complete trend-following and trade-planning tool designed to deliver clear trend flips, automatic TP/SL mapping, multi-timeframe confirmation, and live performance tracking in one clean workflow.

It is built for traders who want more than just a trend line. The script not only identifies directional changes, but also helps structure each trade with entry, stop loss, take-profit targets, higher-timeframe context, and ongoing setup statistics.

Whether you prefer fast reaction entries or smoother trend continuation, the tracker can adapt to both styles through its dual operating modes.

Core Engine: Adaptive Trend Tracker
At the center of the script is a custom EMA + ATR-based Trend Tracker that follows price from below in bullish conditions and from above in bearish conditions.

The tracker uses ATR-based upper and lower bands to determine when direction shifts, then maintains a dynamic tracker line that updates with price behavior. This creates a clean trend bias while filtering more noise than a simple moving-average crossover.

Two Operating Modes

Scalp Mode
Scalp Mode is designed for faster reaction.
It uses quicker EMA behavior to respond more aggressively to short-term price movement, making it more suitable for lower timeframes and active intraday trading.

Trend Mode
Trend Mode is designed for smoother tracking.
It blends slower EMA values to reduce market noise and stay aligned with broader directional movement.

This gives the script flexibility across different trading conditions, from fast execution charts to cleaner swing-style trend following.

MTF Confluence Filter
The script includes an optional Multi-Timeframe Confluence Filter.

When enabled, LONG and SHORT flip signals will only appear if the trend on the selected higher timeframe agrees with the flip direction on the current chart. This helps reduce counter-trend entries and improves top-down alignment.

Filter timeframe options:
1 minute
5 minute
15 minute
1 hour
4 hour
Daily

This makes it easier to focus only on signals that are working with broader market direction.

Automated Trade Planner
When a valid bull or bear flip appears, the indicator automatically builds a live setup box for the latest signal.

Each setup includes:
Entry level at the close of the flip candle
Stop loss level
Three take-profit targets
Reward and risk zones
Dynamic target and stop labels
Optional TP/SL hit markers

This turns each new trend flip into an immediate on-chart trade plan without needing manual calculation.

Flexible Risk Management
The setup planner supports multiple stop-loss styles.

1. Fixed ATR Stop
Use a standard ATR-based stop with a custom ATR multiplier.

2. Tracker-Based Stop
Use the Trend Tracker itself as the risk base, so stop distance is anchored to the tracker line rather than a fixed ATR amount.

3. Optional Trailing Stop with Tracker Line
The script also supports trailing the stop loss with the Tracker Line.

When enabled, the SL level in the setup box will actively follow the tracker as it moves in your favor. This gives the setup a more dynamic structure-based management style.

Three Take-Profit Targets
The indicator automatically calculates three custom take-profit levels from the setup’s initial risk.

Default values are:
TP1 = 0.5R
TP2 = 1.0R
TP3 = 1.5R

These can be customized in settings to match different execution styles.

As price reaches each level, the script updates the labels and can print on-chart hit markers such as TP1✓, TP2✓, TP3✓, and SLX.

Clean Trend Visuals
A key visual feature of this version is the split bull/bear tracker display.

Instead of using a single line that visually bridges through flip points, the script draws the bullish and bearish tracker states separately. This helps avoid the unwanted connected look on lower timeframes and keeps the flip diamonds visually independent from the tracker line.

Visual Features
The script includes several optional chart elements so you can keep the layout minimal or more data-rich.

Included visual tools:
Trend Tracker Line
Trend Star (✪) on the latest bar
Flip Diamonds
Optional LONG / SHORT labels
Optional Basis line
Optional ATR bands
Optional bar coloring
Optional background trend tint
Optional TP/SL hit labels

These controls let you shape the chart around your own workflow while keeping the core logic intact.

Intelligence Dashboards

MTF Trend Table
The built-in MTF Trend Table displays the current Bull/Bear tracker state across 6 fixed timeframes:

1m
5m
15m
1H
4H
D

This allows you to check higher-timeframe alignment quickly without changing charts.

Performance Stats Table
The script also includes an internal stats dashboard that tracks how setups perform directly on the chart.

It displays:
Total number of setups
TP1 hit rate
TP2 hit rate
TP3 hit rate
SL hit rate

This gives a quick performance snapshot of how the current configuration is behaving.

Stats Calculation Modes
The stats engine supports two calculation styles.

Cumulative Mode
Tracks all qualifying setups over the full loaded chart history.

Last X Bars Mode
Restricts stats to a recent lookback window so you can evaluate how the script has been performing under more current market conditions.

This is useful when older market data may no longer reflect present volatility or trend behavior.

Alerts
The script includes a full suite of built-in alerts for both signal events and trade-management events.

Available alerts:
Bull Trend Flip
Bear Trend Flip
TP1 Hit
TP2 Hit
TP3 Hit
SL Hit
Bull Trend Active
Bear Trend Active

This makes the tool suitable for both visual chart reading and alert-based workflows.

How to Use

1. Check higher-timeframe context
Start by reading the MTF Trend Table and identify whether the current chart is aligned with the broader trend.

2. Enable the MTF filter if desired
Turn on the MTF Confluence Filter if you want LONG and SHORT signals to appear only when higher-timeframe direction agrees.

3. Wait for a trend flip
A new flip marks the beginning of a fresh setup.
When a signal appears, the script automatically draws the latest trade-planning box.

4. Use the setup box
Monitor the trade visually with:
entry
stop loss
TP1
TP2
TP3

5. Choose the stop style
Use either:
fixed ATR stop
tracker-based stop
trailing tracker stop

6. Review current performance
Use the stats dashboard in either Cumulative or Last X Bars mode to evaluate how the current settings are performing.

Best Use Case
This script is best suited for traders who want:
a clean trend-following framework
automatic trade planning on trend flips
optional higher-timeframe filtering
dynamic TP/SL visualization
on-chart performance feedback
cleaner tracker visuals on lower timeframes
flexible stop management with optional trailing behavior

It can be used for scalping, intraday chart work, or broader directional tracking depending on the selected settings.

Disclaimer
This indicator is provided for educational and informational purposes only and does not constitute financial advice, investment advice, trading advice, or a recommendation to buy or sell any instrument.

Trading and investing involve risk, and past performance does not guarantee future results. No indicator can predict market direction with certainty. Users are responsible for their own decisions, risk management, and trade execution.

The built-in statistics and on-chart setup planning tools are intended as visual aids only and should not be treated as a guarantee of profitability or as a substitute for proper testing, personal judgment, and independent analysis.

Always test on historical data and in a simulated environment before using any script in live market conditions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NICK789

//@version=6
indicator("Adaptive Trend Tracker Trade Planner [NICK789]", shorttitle="Adaptive Trend Tracker", overlay=true,
     max_boxes_count=100, max_lines_count=200, max_labels_count=500, dynamic_requests=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRACKER ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore    = "Tracker Engine"
groupDisplay = "Visual Display"

src = input.source(ohlc4, "Source", group=groupCore)

trackerMode = input.string(
     "Scalp",
     "Tracker Mode",
     options=["Scalp", "Trend"],
     group=groupCore,
     tooltip="Scalp mode reacts faster by using the fast EMA as the main driver.\n\nTrend mode uses smoother EMA logic for slower directional tracking."
)

trackerFastLen = input.int(9, "Fast Length", minval=1, group=groupCore)
trackerSlowLen = input.int(21, "Slow Length", minval=1, group=groupCore)
trackerATRLen  = input.int(14, "ATR Length", minval=1, group=groupCore)
trackerATRMult = input.float(1.6, "ATR Multiplier", minval=0.1, step=0.1, group=groupCore)
useTrueATR     = input.bool(true, "Use True ATR?", group=groupCore)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE OPTIMIZER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpAdaptive = "Adaptive Optimizer"

adaptiveWarning = input.string(
     "OFF = fast. ON = scans 125 settings and can load slower.",
     "⚠️ Adaptive Warning",
     options=["OFF = fast. ON = scans 125 settings and can load slower."],
     group=grpAdaptive,
     tooltip="Adaptive mode is intentionally heavier because it runs an internal TP/SL scan across 5 Fast lengths × 5 ATR lengths × 5 ATR multipliers. Leave it OFF for the fastest chart loading."
)

useAdaptive = input.bool(
     false,
     "Use Adaptive Best Settings?",
     group=grpAdaptive,
     tooltip="Heavy mode. When enabled, the tracker scans 125 setting combinations and applies the best setting found after warmup and minimum setup requirements are met. Leave OFF for faster loading."
)

adaptivePick = input.string(
     "Stable Zone",
     "Adaptive Pick Mode",
     options=["Stable Zone", "Best Score"],
     group=grpAdaptive,
     tooltip="Best Score selects the highest score. Stable Zone favours smoother nearby performance to reduce curve-fit risk."
)

adaptiveMetric = input.string(
     "Balanced TP Score",
     "Adaptive Metric",
     options=["Balanced TP Score", "TP3 Rate", "TP2 Rate", "TP1 Rate", "Lowest SL Rate", "Net Hit Score"],
     group=grpAdaptive
)

adaptiveWarmupBars = input.int(
     100,
     "Warmup Bars Before Scoring",
     minval=20,
     group=grpAdaptive,
     tooltip="Bars to ignore before the optimizer starts counting TP/SL results."
)

adaptiveMinSetups = input.int(
     8,
     "Minimum Setups Before Auto Apply",
     minval=1,
     group=grpAdaptive,
     tooltip="Minimum completed setups required before adaptive settings can be applied."
)

adaptiveSlPenalty = input.float(
     0.85,
     "SL Penalty",
     minval=0.1,
     step=0.05,
     group=grpAdaptive,
     tooltip="Used by Balanced TP Score and Net Hit Score. Higher values apply a stronger penalty to SL hits."
)

adaptiveStabilityPenalty = input.float(
     1.2,
     "Stability Penalty",
     minval=0.0,
     step=0.1,
     group=grpAdaptive,
     tooltip="Only used in Stable Zone mode. Higher values favour smoother parameter zones over isolated score spikes."
)

adaptiveFastStart = input.int(5, "Fast Start", minval=1, group=grpAdaptive)
adaptiveFastStep  = input.int(2, "Fast Step", minval=1, group=grpAdaptive)
adaptiveAtrStart  = input.int(8, "ATR Start", minval=1, group=grpAdaptive)
adaptiveAtrStep   = input.int(2, "ATR Step", minval=1, group=grpAdaptive)
adaptiveMultStart = input.float(1.0, "ATR Mult Start", minval=0.1, step=0.1, group=grpAdaptive)
adaptiveMultStep  = input.float(0.2, "ATR Mult Step", minval=0.1, step=0.1, group=grpAdaptive)
showAdaptiveInStats = input.bool(true, "Show Adaptive Rows When Enabled", group=grpAdaptive, tooltip="Only shows adaptive optimizer rows in the TP stats table when Adaptive Best Settings is enabled.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MTF CONFIRMATION FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpFilter = "MTF Confirmation Filter"

useMtfFilter = input.bool(
     false,
     "Use MTF Confirmation Filter?",
     group=grpFilter,
     tooltip="If enabled, flip signals only appear when the selected higher timeframe agrees with the current tracker direction."
)

mtfFilterTf = input.string(
     "60",
     "Confirmation Timeframe",
     options=["1", "5", "15", "60", "240", "D"],
     group=grpFilter
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DELAYED RE-ENTRY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpReentry = "Delayed Re-Entry"

enableHtfReentry = input.bool(
     true,
     "Enable Delayed Re-Entry",
     group=grpReentry,
     tooltip="If a local flip is blocked because the higher timeframe disagrees, this allows a delayed re-entry when the higher timeframe later aligns while the local trend is still active."
)

reentryMaxBars    = input.int(20, "Max Re-Entry Wait Bars", minval=1, group=grpReentry)
showReentryLabels = input.bool(true, "Show Re-Entry Labels", group=grpReentry)
showPendingDebug  = input.bool(false, "Show Pending Debug Marker", group=grpReentry)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE PLANNER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpSetup = "Trade Planner"

tradeMode = input.string(
     "Normal Trend Flip",
     "Trade Mode",
     options=["Normal Trend Flip", "Delta Confirm"],
     group=grpSetup,
     tooltip="Normal Trend Flip creates the setup box as soon as the tracker flips.\n\nDelta Confirm waits until trend-volume delta supports the active trend before creating the setup box."
)

deltaWaitBars = input.int(
     20,
     "Max Delta Wait Bars",
     minval=1,
     group=grpSetup,
     tooltip="Only used when Trade Mode is set to Delta Confirm.\n\nIf delta does not support the trend within this many bars, the waiting setup expires."
)

showDeltaStatusLabels = input.bool(
     true,
     "Show Delta Status Labels",
     group=grpSetup,
     tooltip="Only used with Delta Confirm mode.\n\nShows WAIT FLOW, CONFIRMED, or EXPIRED so users can understand why the setup box did or did not appear."
)

rr1 = input.float(0.5, "TP1 Ratio", minval=0.1, step=0.1, group=grpSetup, tooltip="0.5 = 0.5R")
rr2 = input.float(1.0, "TP2 Ratio", minval=0.1, step=0.1, group=grpSetup, tooltip="1.0 = 1R")
rr3 = input.float(1.5, "TP3 Ratio", minval=0.1, step=0.1, group=grpSetup, tooltip="1.5 = 1.5R")

slAtrMult     = input.float(1.5, "Fixed Stop ATR Multiplier", step=0.1, group=grpSetup)
useTrendSL    = input.bool(true, "Use Tracker Line as Risk Base", group=grpSetup, tooltip="If true, risk is measured from entry to the tracker line. If false, risk uses a fixed ATR distance.")
useTrailingSL = input.bool(false, "Trail SL with Tracker Line", group=grpSetup, tooltip="If true, the SL level in the setup box actively follows the tracker line as it moves.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showBasis       = input.bool(false, "Show Basis", group=groupDisplay)
showBands       = input.bool(false, "Show ATR Bands", group=groupDisplay)
showFlipLabels  = input.bool(true, "Show Entry Labels", group=groupDisplay)
colorBars       = input.bool(false, "Color Bars", group=groupDisplay)
showBg          = input.bool(false, "Background Tint", group=groupDisplay)
showTrendStar   = input.bool(true, "Show Trend Star", group=groupDisplay)
showTrailStats  = input.bool(true, "Show Delta HUD Beside Trend Star", group=groupDisplay)

hudMode = input.string(
     "Compact", 
     "HUD Mode", 
     options=["Compact", "Detailed"], 
     group=groupDisplay, 
     tooltip="Compact: Shows Delta % and Ratio on one line.\nDetailed: Shows Buy/Sell volumes, Delta %, and Ratio on four lines."
)

showDeltaStatsAnyMode = input.bool(
     true,
     "Show Delta Stats In Any Trade Mode",
     group=groupDisplay,
     tooltip="If enabled, B/S/Delta stats beside the trend star will show even when Trade Mode is set to Normal Trend Flip."
)

trailStarSizeInput = input.string(
     "Small",
     "Trend Star Stats Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"],
     group=groupDisplay
)

showFlipDiamond = input.bool(true, "Show Flip Diamond", group=groupDisplay)

bullColor  = input.color(color.rgb(8, 153, 129), "Bull Color", group=groupDisplay)
bearColor  = input.color(color.rgb(242, 54, 69), "Bear Color", group=groupDisplay)
basisColor = input.color(color.rgb(120, 120, 120), "Basis Color", group=groupDisplay)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DELTA PROXY ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpDelta = "Delta Proxy Engine"

useLtfDelta = input.bool(
     true,
     "Use Lower-TF Delta Proxy?",
     group=grpDelta,
     tooltip="Optional heavier mode. Uses lower-timeframe candles to estimate buy/sell pressure inside the current chart candle. Leave OFF for faster loading, especially on mobile."
)

ltfDeltaTf = input.timeframe(
     "1",
     "Lower-TF Delta Source",
     options=["1", "3", "5"],
     group=grpDelta,
     tooltip="For 5m and 15m trading, 1m gives the cleanest intrabar pressure story. If the selected timeframe is not lower than the chart timeframe, the script falls back to chart-candle delta."
)

showDeltaSource = input.bool(
     false,
     "Show Delta Source In HUD",
     group=grpDelta,
     tooltip="Adds LTF or Chart to the compact HUD so you can see which delta source is active."
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXHAUSTION (ABSORPTION) DOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpRev = "Exhaustion Dots"

showAbsDots = input.bool(
     false,
     "Show Exhaustion Dots",
     group=grpRev,
     tooltip="Shows markers where the trend is likely over-extended (stretched) and high volume is being absorbed by the other side. These are NOT trend-flip signals, but 'take profit' or 'caution' markers."
)

absVolMult = input.float(
     1.5, 
     "Volume Climax Mult", 
     minval=1.0, 
     step=0.1, 
     group=grpRev,
     tooltip="Volume must be this many times higher than the 20-period average."
)

absStrictStretch = input.bool(
     true, 
     "Require Band Breach?", 
     group=grpRev,
     tooltip="Only show dots when price is actually breaking the outer ATR tracker bands. This eliminates noisy dots in the middle of a trend."
)

absWickSens = input.float(
     0.35, 
     "Rejection Wick Sensitivity", 
     minval=0.1, 
     maxval=0.5, 
     step=0.05, 
     group=grpRev,
     tooltip="How much of the candle wick must be rejected to confirm absorption."
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETUP BOX STYLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpBox = "Setup Box Style"

showSetupBox      = input.bool(true, "Show Latest Setup Levels", group=grpBox)
showSetupBoxFill  = input.bool(false, "Show Reward / Risk Boxes", group=grpBox, tooltip="Turn this off for a cleaner chart. ENTRY, TP, and SL level lines will still show.")
liveAheadBars     = input.int(5, "Keep Levels This Many Bars Ahead", minval=1, maxval=50, group=grpBox)
showHitLabels     = input.bool(true, "Show TP/SL Hit Labels", group=grpBox)
showSetupPrices   = input.bool(true, "Show Entry / TP / SL Prices", group=grpBox, tooltip="Shows exact ENTRY, TP1, TP2, TP3, and SL prices on the latest active setup levels only.")

rewardBg       = input.color(color.new(color.teal, 88), "Reward Box Fill", group=grpBox)
riskBg         = input.color(color.new(color.red, 88), "Risk Box Fill", group=grpBox)
rewardBorder   = input.color(color.new(color.teal, 0), "Reward Box Border", group=grpBox)
riskBorder     = input.color(color.new(color.red, 0), "Risk Box Border", group=grpBox)
levelColor     = input.color(color.new(color.aqua, 0), "Target Line Color", group=grpBox)
entryLineColor = input.color(color.new(color.white, 65), "Entry Line Color", group=grpBox)
slLineColor    = input.color(color.new(color.orange, 0), "SL Line Color", group=grpBox)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD & STATS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpDash = "Dashboard & Stats"

showMTFtbl    = input.bool(true, "Show MTF Table?", group=grpDash, tooltip="Optional speed toggle. MTF table uses manual tracker settings only and does NOT use adaptive optimizer settings. Leave OFF for fastest loading.")
showStatsTbl  = input.bool(true, "Show TP Stats Table", group=grpDash)
statsMode     = input.string("Cumulative", "Stats Calculation", options=["Cumulative", "Last X Bars"], group=grpDash)
statsLookback = input.int(200, "Stats Lookback Bars", minval=10, group=grpDash, tooltip="Only effective when Last X Bars is selected.")
showSLRate    = input.bool(true, "Show SL Rate", group=grpDash)
mtfPosOpt     = input.string("Top Right", "MTF Table Position", options=["Top Left","Top Right","Bottom Left","Bottom Right","Top Center","Bottom Center"], group=grpDash)
statsPosOpt   = input.string("Bottom Right", "Stats Table Position", options=["Top Left","Top Right","Bottom Left","Bottom Right","Top Center","Bottom Center"], group=grpDash)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MASTER ALERT SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
grpAlerts = "Master Alert"

alertBullFlip      = input.bool(true,  "Bull Trend Flip", group=grpAlerts)
alertBearFlip      = input.bool(true,  "Bear Trend Flip", group=grpAlerts)
alertBullReentry   = input.bool(true,  "Bull Re-Entry", group=grpAlerts)
alertBearReentry   = input.bool(true,  "Bear Re-Entry", group=grpAlerts)
alertBullConfirmed = input.bool(true,  "Confirmed Bull Entry", group=grpAlerts)
alertBearConfirmed = input.bool(true,  "Confirmed Bear Entry", group=grpAlerts)
alertBullRevDot    = input.bool(false, "Bull Exhaustion Dot", group=grpAlerts)
alertBearRevDot    = input.bool(false, "Bear Exhaustion Dot", group=grpAlerts)
alertTP1           = input.bool(false, "TP1 Hit", group=grpAlerts)
alertTP2           = input.bool(false, "TP2 Hit", group=grpAlerts)
alertTP3           = input.bool(false, "TP3 Hit", group=grpAlerts)
alertSL            = input.bool(false, "SL Hit", group=grpAlerts)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPER FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_tblPos(string opt) =>
    switch opt
        "Top Left"      => position.top_left
        "Top Right"     => position.top_right
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        "Top Center"    => position.top_center
        "Bottom Center" => position.bottom_center
        => position.top_right

f_pct(_num, _den) =>
    _den > 0 ? (_num * 100.0) / _den : na

f_pct_txt(_num, _den) =>
    _den > 0 ? str.tostring(f_pct(_num, _den), "#.0") + "%" : "n/a"

f_mtfTxt(_state) =>
    _state ? "BULL ✅" : "BEAR ❌"

f_lbl(_name, _hit) =>
    _hit ? "✓ " + _name : _name

f_price_txt(_price) =>
    str.tostring(_price, format.mintick)

f_level_lbl(_name, _price, _hit, _showPrice) =>
    _base = f_lbl(_name, _hit)
    _showPrice ? _base + "\n" + f_price_txt(_price) : _base

f_entry_lbl(_price, _showPrice) =>
    _showPrice ? "ENTRY\n" + f_price_txt(_price) : "ENTRY"

f_volTxt(float v) =>
    str.tostring(v, format.volume)

f_k(float v) =>
    absV = math.abs(v)
    absV >= 1000000 ? str.format("{0,number,#.##}M", v / 1000000.0) :
     absV >= 1000 ? str.format("{0,number,#.##}K", v / 1000.0) :
     str.format("{0,number,#}", v)

f_sum_float_array(array<float> arr) =>
    float total = 0.0
    int sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            total += array.get(arr, i)
    total

f_size(string s) =>
    s == "Tiny"   ? size.tiny :
     s == "Small"  ? size.small :
     s == "Normal" ? size.normal :
     s == "Large"  ? size.large :
     size.huge

trailStarSize = f_size(trailStarSizeInput)

f_deltaTxt(int side, bool confirmed, float pct) =>
    string dirTxt = side == 1 ? "LONG" : "SHORT"
    string stateTxt = confirmed ? "CONFIRMED" : "WAIT FLOW"
    dirTxt + "\n" + stateTxt + "\nΔ " + str.tostring(pct, "#.0") + "%"

f_tracker_state_manual(
     float _src,
     simple int _fastLen,
     simple int _slowLen,
     simple int _atrLen,
     simple float _atrMult,
     simple bool _useTrueATR,
     simple string _mode
 ) =>
    float _basisFast = ta.ema(_src, _fastLen)
    float _basisSlow = ta.ema(_src, _slowLen)
    float _basisCore = _mode == "Scalp" ? _basisFast : (_basisFast + _basisSlow) / 2.0
    float _atrValue  = _useTrueATR ? ta.atr(_atrLen) : ta.sma(ta.tr(true), _atrLen)
    float _upperBand = _basisCore + _atrValue * _atrMult
    float _lowerBand = _basisCore - _atrValue * _atrMult

    var float _tracker = na
    var int   _dir     = 1

    if na(_tracker[1])
        _dir := _src >= _basisCore ? 1 : -1
        _tracker := _dir == 1 ? _lowerBand : _upperBand
    else
        float _prevTracker = _tracker[1]
        int _prevDir = nz(_dir[1], 1)

        if _src > _upperBand[1]
            _dir := 1
        else if _src < _lowerBand[1]
            _dir := -1
        else
            _dir := _prevDir

        float _bullTrack = math.max(_lowerBand, _prevDir == 1 ? _prevTracker : _lowerBand)
        float _bearTrack = math.min(_upperBand, _prevDir == -1 ? _prevTracker : _upperBand)

        _tracker := _dir == 1 ? _bullTrack : _bearTrack

    _dir

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE OPTIMIZER STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type TT_OptState
    float tracker = na
    int   dir     = 1
    int   side    = 0
    float entry   = na
    float risk    = na
    float tp1     = na
    float tp2     = na
    float tp3     = na
    float sl      = na
    bool  hit1    = false
    bool  hit2    = false
    bool  hit3    = false
    bool  hitSL   = false
    int   setups  = 0
    int   tp1Hits = 0
    int   tp2Hits = 0
    int   tp3Hits = 0
    int   slHits  = 0

method get_adaptive_score(TT_OptState s, string metric, float slPenalty) =>
    float out = na
    if s.setups > 0
        float tp1Rate = s.tp1Hits / s.setups * 100.0
        float tp2Rate = s.tp2Hits / s.setups * 100.0
        float tp3Rate = s.tp3Hits / s.setups * 100.0
        float slRate  = s.slHits  / s.setups * 100.0

        if metric == "TP3 Rate"
            out := tp3Rate
        else if metric == "TP2 Rate"
            out := tp2Rate
        else if metric == "TP1 Rate"
            out := tp1Rate
        else if metric == "Lowest SL Rate"
            out := 100.0 - slRate
        else if metric == "Net Hit Score"
            out := ((s.tp1Hits + s.tp2Hits + s.tp3Hits) - s.slHits * slPenalty) / s.setups * 100.0
        else
            out := ((s.tp1Hits * 0.25) + (s.tp2Hits * 0.50) + (s.tp3Hits * 1.00) - (s.slHits * slPenalty)) / s.setups * 100.0
    out

f_opt_index(int fi, int ai, int mi) =>
    fi * 25 + ai * 5 + mi

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRACKER CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fastLen = trackerMode == "Scalp" ? trackerFastLen : trackerSlowLen
slowLen = trackerMode == "Scalp" ? math.max(trackerSlowLen, trackerFastLen + 3) : math.max(trackerSlowLen * 2, trackerFastLen + 5)

manualBasisFast = ta.ema(src, fastLen)
manualBasisSlow = ta.ema(src, slowLen)
manualBasisCore = trackerMode == "Scalp" ? manualBasisFast : (manualBasisFast + manualBasisSlow) / 2.0

manualAtrValue  = useTrueATR ? ta.atr(trackerATRLen) : ta.sma(ta.tr(true), trackerATRLen)
manualUpperBand = manualBasisCore + manualAtrValue * trackerATRMult
manualLowerBand = manualBasisCore - manualAtrValue * trackerATRMult

var float manualTrendTracker = na
var int   manualTrendDir     = 1

if na(manualTrendTracker[1])
    manualTrendTracker := manualLowerBand
    manualTrendDir := 1
else
    float prevManualTracker = manualTrendTracker[1]
    int prevManualDir = nz(manualTrendDir[1], 1)

    if src > manualUpperBand[1]
        manualTrendDir := 1
    else if src < manualLowerBand[1]
        manualTrendDir := -1
    else
        manualTrendDir := prevManualDir

    float manualBullTrack = math.max(manualLowerBand, prevManualDir == 1 ? prevManualTracker : manualLowerBand)
    float manualBearTrack = math.min(manualUpperBand, prevManualDir == -1 ? prevManualTracker : manualUpperBand)

    manualTrendTracker := manualTrendDir == 1 ? manualBullTrack : manualBearTrack

int optFastLen0 = adaptiveFastStart + 0 * adaptiveFastStep
int optFastLen1 = adaptiveFastStart + 1 * adaptiveFastStep
int optFastLen2 = adaptiveFastStart + 2 * adaptiveFastStep
int optFastLen3 = adaptiveFastStart + 3 * adaptiveFastStep
int optFastLen4 = adaptiveFastStart + 4 * adaptiveFastStep

int optAtrLen0 = adaptiveAtrStart + 0 * adaptiveAtrStep
int optAtrLen1 = adaptiveAtrStart + 1 * adaptiveAtrStep
int optAtrLen2 = adaptiveAtrStart + 2 * adaptiveAtrStep
int optAtrLen3 = adaptiveAtrStart + 3 * adaptiveAtrStep
int optAtrLen4 = adaptiveAtrStart + 4 * adaptiveAtrStep

float optEma0 = manualBasisFast
float optEma1 = manualBasisFast
float optEma2 = manualBasisFast
float optEma3 = manualBasisFast
float optEma4 = manualBasisFast

float optAtr0 = manualAtrValue
float optAtr1 = manualAtrValue
float optAtr2 = manualAtrValue
float optAtr3 = manualAtrValue
float optAtr4 = manualAtrValue

if useAdaptive
    optEma0 := ta.ema(src, optFastLen0)
    optEma1 := ta.ema(src, optFastLen1)
    optEma2 := ta.ema(src, optFastLen2)
    optEma3 := ta.ema(src, optFastLen3)
    optEma4 := ta.ema(src, optFastLen4)

    optAtr0 := useTrueATR ? ta.atr(optAtrLen0) : ta.sma(ta.tr(true), optAtrLen0)
    optAtr1 := useTrueATR ? ta.atr(optAtrLen1) : ta.sma(ta.tr(true), optAtrLen1)
    optAtr2 := useTrueATR ? ta.atr(optAtrLen2) : ta.sma(ta.tr(true), optAtrLen2)
    optAtr3 := useTrueATR ? ta.atr(optAtrLen3) : ta.sma(ta.tr(true), optAtrLen3)
    optAtr4 := useTrueATR ? ta.atr(optAtrLen4) : ta.sma(ta.tr(true), optAtrLen4)

float[] optEmaArr = array.from(optEma0, optEma1, optEma2, optEma3, optEma4)
float[] optAtrArr = array.from(optAtr0, optAtr1, optAtr2, optAtr3, optAtr4)

var array<TT_OptState> adaptiveStates = array.new<TT_OptState>(125)
if barstate.isfirst
    for n = 0 to 124
        adaptiveStates.set(n, TT_OptState.new())

bool adaptiveScoreReady = bar_index >= adaptiveWarmupBars

if useAdaptive
    for fi = 0 to 4
        float optBasisFast = optEmaArr.get(fi)
        float optBasisCore = trackerMode == "Scalp" ? optBasisFast : (optBasisFast + manualBasisSlow) / 2.0

        for ai = 0 to 4
            float optAtr = optAtrArr.get(ai)

            for mi = 0 to 4
                int optIdx = f_opt_index(fi, ai, mi)
                TT_OptState optState = adaptiveStates.get(optIdx)

                float optMult = adaptiveMultStart + mi * adaptiveMultStep
                float optUpperBand = optBasisCore + optAtr * optMult
                float optLowerBand = optBasisCore - optAtr * optMult

                int optPrevDir = nz(optState.dir, 1)
                float optPrevTracker = optState.tracker

                int optDir = optPrevDir
                float optTracker = na

                if na(optPrevTracker)
                    optDir := 1
                    optTracker := optLowerBand
                else
                    if src > optUpperBand[1]
                        optDir := 1
                    else if src < optLowerBand[1]
                        optDir := -1
                    else
                        optDir := optPrevDir

                    float optBullTrack = math.max(optLowerBand, optPrevDir == 1 ? optPrevTracker : optLowerBand)
                    float optBearTrack = math.min(optUpperBand, optPrevDir == -1 ? optPrevTracker : optUpperBand)
                    optTracker := optDir == 1 ? optBullTrack : optBearTrack

                bool optFlip = optDir != optPrevDir and not na(optPrevTracker)

                if optFlip
                    if adaptiveScoreReady and optState.side != 0 and not na(optState.entry)
                        optState.setups  += 1
                        optState.tp1Hits += optState.hit1 ? 1 : 0
                        optState.tp2Hits += optState.hit2 ? 1 : 0
                        optState.tp3Hits += optState.hit3 ? 1 : 0
                        optState.slHits  += optState.hitSL ? 1 : 0

                    if adaptiveScoreReady
                        optState.side  := optDir
                        optState.entry := close

                        float optRawRisk = optDir == 1 ? (useTrendSL ? close - optTracker : slAtrMult * optAtr) : (useTrendSL ? optTracker - close : slAtrMult * optAtr)
                        optState.risk := math.max(optRawRisk, syminfo.mintick * 10)
                        optState.sl   := optDir == 1 ? optState.entry - optState.risk       : optState.entry + optState.risk
                        optState.tp1  := optDir == 1 ? optState.entry + optState.risk * rr1 : optState.entry - optState.risk * rr1
                        optState.tp2  := optDir == 1 ? optState.entry + optState.risk * rr2 : optState.entry - optState.risk * rr2
                        optState.tp3  := optDir == 1 ? optState.entry + optState.risk * rr3 : optState.entry - optState.risk * rr3
                        optState.hit1  := false
                        optState.hit2  := false
                        optState.hit3  := false
                        optState.hitSL := false
                    else
                        optState.side  := 0
                        optState.entry := na

                if adaptiveScoreReady and optState.side != 0 and not na(optState.entry)
                    if optState.side == 1
                        optState.hit1  := optState.hit1  or high >= optState.tp1
                        optState.hit2  := optState.hit2  or high >= optState.tp2
                        optState.hit3  := optState.hit3  or high >= optState.tp3
                        optState.hitSL := optState.hitSL or low  <= optState.sl
                    else
                        optState.hit1  := optState.hit1  or low  <= optState.tp1
                        optState.hit2  := optState.hit2  or low  <= optState.tp2
                        optState.hit3  := optState.hit3  or low  <= optState.tp3
                        optState.hitSL := optState.hitSL or high >= optState.sl

                optState.tracker := optTracker
                optState.dir     := optDir

int adaptiveBestFi = 0
int adaptiveBestAi = 0
int adaptiveBestMi = 0
float adaptiveBestScore = na
float adaptiveRawBestScore = na
int adaptiveRawBestFi = 0
int adaptiveRawBestAi = 0
int adaptiveRawBestMi = 0

if useAdaptive
    for fi = 0 to 4
        for ai = 0 to 4
            for mi = 0 to 4
                int idx = f_opt_index(fi, ai, mi)
                TT_OptState st = adaptiveStates.get(idx)
                float sc = st.get_adaptive_score(adaptiveMetric, adaptiveSlPenalty)
                bool enough = st.setups >= adaptiveMinSetups and not na(sc)
                if enough and (na(adaptiveRawBestScore) or sc > adaptiveRawBestScore)
                    adaptiveRawBestScore := sc
                    adaptiveRawBestFi := fi
                    adaptiveRawBestAi := ai
                    adaptiveRawBestMi := mi

    if adaptivePick == "Stable Zone"
        for fi = 1 to 3
            for ai = 1 to 3
                for mi = 1 to 3
                    TT_OptState centerState = adaptiveStates.get(f_opt_index(fi, ai, mi))
                    float centerScore = centerState.get_adaptive_score(adaptiveMetric, adaptiveSlPenalty)
                    bool centerEnough = centerState.setups >= adaptiveMinSetups and not na(centerScore)
                    float sumSc = 0.0
                    int cntSc = 0

                    if centerEnough
                        for dfi = -1 to 1
                            for dai = -1 to 1
                                for dmi = -1 to 1
                                    TT_OptState stN = adaptiveStates.get(f_opt_index(fi + dfi, ai + dai, mi + dmi))
                                    float scN = stN.get_adaptive_score(adaptiveMetric, adaptiveSlPenalty)
                                    if stN.setups >= adaptiveMinSetups and not na(scN)
                                        sumSc += scN
                                        cntSc += 1

                    if cntSc > 0
                        float avgSc = sumSc / cntSc
                        float devSum = 0.0

                        for dfi = -1 to 1
                            for dai = -1 to 1
                                for dmi = -1 to 1
                                    TT_OptState stD = adaptiveStates.get(f_opt_index(fi + dfi, ai + dai, mi + dmi))
                                    float scD = stD.get_adaptive_score(adaptiveMetric, adaptiveSlPenalty)
                                    if stD.setups >= adaptiveMinSetups and not na(scD)
                                        float diff = scD - avgSc
                                        devSum += diff * diff

                        float stdSc = math.sqrt(devSum / cntSc)
                        float stableScore = avgSc - stdSc * adaptiveStabilityPenalty

                        if na(adaptiveBestScore) or stableScore > adaptiveBestScore
                            adaptiveBestScore := stableScore
                            adaptiveBestFi := fi
                            adaptiveBestAi := ai
                            adaptiveBestMi := mi
    else
        adaptiveBestScore := adaptiveRawBestScore
        adaptiveBestFi := adaptiveRawBestFi
        adaptiveBestAi := adaptiveRawBestAi
        adaptiveBestMi := adaptiveRawBestMi


bool adaptiveReady = useAdaptive and not na(adaptiveBestScore)
int adaptiveSelectedIdx = f_opt_index(adaptiveBestFi, adaptiveBestAi, adaptiveBestMi)
TT_OptState adaptiveSelectedState = adaptiveStates.get(adaptiveSelectedIdx)

int adaptiveFastLen = adaptiveFastStart + adaptiveBestFi * adaptiveFastStep
int adaptiveAtrLen  = adaptiveAtrStart  + adaptiveBestAi * adaptiveAtrStep
float adaptiveAtrMult = adaptiveMultStart + adaptiveBestMi * adaptiveMultStep
int adaptiveSetups = adaptiveSelectedState.setups
float adaptiveShownScore = adaptiveSelectedState.get_adaptive_score(adaptiveMetric, adaptiveSlPenalty)

basisFast = adaptiveReady ? optEmaArr.get(adaptiveBestFi) : manualBasisFast
basisSlow = manualBasisSlow
basisCore = adaptiveReady ? (trackerMode == "Scalp" ? basisFast : (basisFast + basisSlow) / 2.0) : manualBasisCore
atrValue  = adaptiveReady ? optAtrArr.get(adaptiveBestAi) : manualAtrValue
upperBand = basisCore + atrValue * (adaptiveReady ? adaptiveAtrMult : trackerATRMult)
lowerBand = basisCore - atrValue * (adaptiveReady ? adaptiveAtrMult : trackerATRMult)

trendTracker = adaptiveReady ? adaptiveSelectedState.tracker : manualTrendTracker
trendDir     = adaptiveReady ? adaptiveSelectedState.dir     : manualTrendDir

trackerBull  = trendDir == 1
trackerBear  = trendDir == -1
trendChanged = trendDir != nz(trendDir[1], trendDir)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND DELTA ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
chartBuyRaw  = close > open ? volume : 0.0
chartSellRaw = close < open ? volume : 0.0
chartDeltaRaw = chartBuyRaw - chartSellRaw

float ltfBuyRaw  = 0.0
float ltfSellRaw = 0.0
bool ltfHasData  = false

if useLtfDelta
    ltfBuyArr = request.security_lower_tf(
         syminfo.tickerid,
         ltfDeltaTf,
         close > open ? volume : 0.0,
         ignore_invalid_timeframe=true
     )

    ltfSellArr = request.security_lower_tf(
         syminfo.tickerid,
         ltfDeltaTf,
         close < open ? volume : 0.0,
         ignore_invalid_timeframe=true
     )

    ltfBuyRaw  := f_sum_float_array(ltfBuyArr)
    ltfSellRaw := f_sum_float_array(ltfSellArr)
    ltfHasData := array.size(ltfBuyArr) > 0 or array.size(ltfSellArr) > 0

useLtfNow = useLtfDelta and ltfHasData

deltaBuyRaw  = useLtfNow ? ltfBuyRaw  : chartBuyRaw
deltaSellRaw = useLtfNow ? ltfSellRaw : chartSellRaw
deltaRaw     = useLtfNow ? ltfBuyRaw - ltfSellRaw : chartDeltaRaw
deltaSourceTxt = useLtfNow ? "LTF " + ltfDeltaTf : "Chart"

var float trendBuyVol   = 0.0
var float trendSellVol  = 0.0
var float trendDeltaVol = 0.0

if trendChanged
    trendBuyVol   := 0.0
    trendSellVol  := 0.0
    trendDeltaVol := 0.0

trendBuyVol   += deltaBuyRaw
trendSellVol  += deltaSellRaw
trendDeltaVol += deltaRaw

trendTotalVol = trendBuyVol + trendSellVol
trendDeltaPct = trendTotalVol > 0 ? trendDeltaVol / trendTotalVol * 100.0 : 0.0

trendRatio = trackerBull ? 
     (trendSellVol > 0 ? trendBuyVol / trendSellVol : trendBuyVol) : 
     (trendBuyVol > 0 ? trendSellVol / trendBuyVol : trendSellVol)

deltaSupportsBull  = trackerBull and trendDeltaVol >= 0
deltaSupportsBear  = trackerBear and trendDeltaVol <= 0
deltaSupportsTrend = deltaSupportsBull or deltaSupportsBear

deltaWeakColor = color.rgb(160, 160, 160)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MULTI-TIMEFRAME STATES — MANUAL SETTINGS ONLY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int mtfDir1 = na
int mtfDir2 = na
int mtfDir3 = na
int mtfDir4 = na
int mtfDir5 = na
int mtfDir6 = na

if showMTFtbl
    mtfDir1 := request.security(syminfo.tickerid, "1",   f_tracker_state_manual(src, fastLen, slowLen, trackerATRLen, trackerATRMult, useTrueATR, trackerMode), barmerge.gaps_off, barmerge.lookahead_off)
    mtfDir2 := request.security(syminfo.tickerid, "5",   f_tracker_state_manual(src, fastLen, slowLen, trackerATRLen, trackerATRMult, useTrueATR, trackerMode), barmerge.gaps_off, barmerge.lookahead_off)
    mtfDir3 := request.security(syminfo.tickerid, "15",  f_tracker_state_manual(src, fastLen, slowLen, trackerATRLen, trackerATRMult, useTrueATR, trackerMode), barmerge.gaps_off, barmerge.lookahead_off)
    mtfDir4 := request.security(syminfo.tickerid, "60",  f_tracker_state_manual(src, fastLen, slowLen, trackerATRLen, trackerATRMult, useTrueATR, trackerMode), barmerge.gaps_off, barmerge.lookahead_off)
    mtfDir5 := request.security(syminfo.tickerid, "240", f_tracker_state_manual(src, fastLen, slowLen, trackerATRLen, trackerATRMult, useTrueATR, trackerMode), barmerge.gaps_off, barmerge.lookahead_off)
    mtfDir6 := request.security(syminfo.tickerid, "D",   f_tracker_state_manual(src, fastLen, slowLen, trackerATRLen, trackerATRMult, useTrueATR, trackerMode), barmerge.gaps_off, barmerge.lookahead_off)

st1 = mtfDir1 == 1
st2 = mtfDir2 == 1
st3 = mtfDir3 == 1
st4 = mtfDir4 == 1
st5 = mtfDir5 == 1
st6 = mtfDir6 == 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int filterDir = trendDir

if useMtfFilter
    filterDir := request.security(
         syminfo.tickerid,
         mtfFilterTf,
         f_tracker_state_manual(src, fastLen, slowLen, trackerATRLen, trackerATRMult, useTrueATR, trackerMode),
         barmerge.gaps_off,
         barmerge.lookahead_off
     )

rawBullFlip = trackerBull and nz(trendDir[1], 1) == -1
rawBearFlip = trackerBear and nz(trendDir[1], 1) == 1

mtfBull = filterDir == 1
mtfBear = filterDir == -1

mtfFilterPass = not useMtfFilter or trendDir == filterDir
prevMtfFilterPass = mtfFilterPass[1] == true
mtfFilterJustOpened = mtfFilterPass and not prevMtfFilterPass

var int pendingSide = 0
var int pendingBar  = na

if useMtfFilter
    if rawBullFlip and not mtfBull
        pendingSide := 1
        pendingBar  := bar_index
    else if rawBearFlip and not mtfBear
        pendingSide := -1
        pendingBar  := bar_index

pendingExpired = pendingSide != 0 and not na(pendingBar) and bar_index - pendingBar > reentryMaxBars

if pendingSide == 1 and (not trackerBull or rawBearFlip or pendingExpired)
    pendingSide := 0
    pendingBar  := na

if pendingSide == -1 and (not trackerBear or rawBullFlip or pendingExpired)
    pendingSide := 0
    pendingBar  := na

bullFlip = rawBullFlip and mtfFilterPass
bearFlip = rawBearFlip and mtfFilterPass

bullReentry = useMtfFilter and enableHtfReentry and pendingSide == 1 and trackerBull and mtfFilterJustOpened
bearReentry = useMtfFilter and enableHtfReentry and pendingSide == -1 and trackerBear and mtfFilterJustOpened

if bullReentry or bearReentry
    pendingSide := 0
    pendingBar  := na

bullSignal = bullFlip or bullReentry
bearSignal = bearFlip or bearReentry

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETUP STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box   setupRewardBox = na
var box   setupRiskBox   = na
var line  setupEntryLine = na
var line  setupTp1Line   = na
var line  setupTp2Line   = na
var line  setupTp3Line   = na
var line  setupSlLine    = na
var label setupTp1Label  = na
var label setupTp2Label  = na
var label setupTp3Label  = na
var label setupSlLabel   = na
var label setupEntryLabel = na
var label deltaStatusLabel = na

var int   setupSide      = 0
var int   setupStartBar  = na
var float setupEntry     = na
var float setupRisk      = na
var float setupTP1       = na
var float setupTP2       = na
var float setupTP3       = na
var float setupSL        = na
var bool  setupTP1Hit    = false
var bool  setupTP2Hit    = false
var bool  setupTP3Hit    = false
var bool  setupSLHit     = false

var bool  tp1JustHit     = false
var bool  tp2JustHit     = false
var bool  tp3JustHit     = false
var bool  slJustHit      = false

var int pendingEntrySide = 0
var int pendingEntryBar  = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATS ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int statsTotalSetups = 0
var int statsTP1Hits     = 0
var int statsTP2Hits     = 0
var int statsTP3Hits     = 0
var int statsSLHits      = 0

isWithinLookback = statsMode == "Cumulative" or bar_index >= last_bar_index - statsLookback

if statsMode == "Last X Bars" and bar_index == last_bar_index - statsLookback
    statsTotalSetups := 0
    statsTP1Hits     := 0
    statsTP2Hits     := 0
    statsTP3Hits     := 0
    statsSLHits      := 0

f_delete_setup_visuals() =>
    box.delete(setupRewardBox)
    box.delete(setupRiskBox)
    line.delete(setupEntryLine)
    line.delete(setupTp1Line)
    line.delete(setupTp2Line)
    line.delete(setupTp3Line)
    line.delete(setupSlLine)
    label.delete(setupTp1Label)
    label.delete(setupTp2Label)
    label.delete(setupTp3Label)
    label.delete(setupSlLabel)
    label.delete(setupEntryLabel)
    label.delete(deltaStatusLabel)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE MODE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
normalTradeMode = tradeMode == "Normal Trend Flip"
deltaTradeMode  = tradeMode == "Delta Confirm"

rawEntrySide = bullSignal ? 1 : bearSignal ? -1 : 0
int entrySideToCreate = 0

if rawEntrySide != 0
    if setupSide != 0 and not na(setupEntry) and isWithinLookback
        statsTotalSetups += 1
        statsTP1Hits     += setupTP1Hit ? 1 : 0
        statsTP2Hits     += setupTP2Hit ? 1 : 0
        statsTP3Hits     += setupTP3Hit ? 1 : 0
        statsSLHits      += setupSLHit  ? 1 : 0

    f_delete_setup_visuals()

    setupSide  := 0
    setupEntry := na

    if normalTradeMode
        entrySideToCreate := rawEntrySide
        pendingEntrySide  := 0
        pendingEntryBar   := na
    else
        pendingEntrySide := rawEntrySide
        pendingEntryBar  := bar_index

        bool confirmedNow = pendingEntrySide == 1 ? trendDeltaVol >= 0 : trendDeltaVol <= 0
        color statusCol = confirmedNow ? pendingEntrySide == 1 ? bullColor : bearColor : deltaWeakColor
        float labelY = trendTracker - atrValue * 0.18

        if showDeltaStatusLabels
            deltaStatusLabel := label.new(
                 bar_index,
                 labelY,
                 f_deltaTxt(pendingEntrySide, confirmedNow, trendDeltaPct),
                 xloc=xloc.bar_index,
                 yloc=yloc.price,
                 style=label.style_label_up,
                 color=color.new(statusCol, confirmedNow ? 5 : 45),
                 textcolor=confirmedNow ? color.white : color.new(color.white, 15),
                 size=size.tiny
             )

pendingDeltaExpired = pendingEntrySide != 0 and not na(pendingEntryBar) and bar_index - pendingEntryBar > deltaWaitBars
pendingTrendInvalid = pendingEntrySide == 1 and not trackerBull or pendingEntrySide == -1 and not trackerBear

flowConfirmed = pendingEntrySide == 1 ? trendDeltaVol >= 0 : pendingEntrySide == -1 ? trendDeltaVol <= 0 : false

if deltaTradeMode and pendingEntrySide != 0
    if pendingDeltaExpired or pendingTrendInvalid
        if not na(deltaStatusLabel)
            label.set_text(deltaStatusLabel, "EXPIRED")
            label.set_color(deltaStatusLabel, color.new(deltaWeakColor, 65))
            label.set_textcolor(deltaStatusLabel, color.new(color.white, 30))

        pendingEntrySide := 0
        pendingEntryBar  := na
    else
        bool liveConfirmed = pendingEntrySide == 1 ? trendDeltaVol >= 0 : trendDeltaVol <= 0
        color liveCol = liveConfirmed ? pendingEntrySide == 1 ? bullColor : bearColor : deltaWeakColor
        float liveLabelY = trendTracker - atrValue * 0.18

        if showDeltaStatusLabels and not na(deltaStatusLabel)
            label.set_xy(deltaStatusLabel, bar_index, liveLabelY)
            label.set_text(deltaStatusLabel, f_deltaTxt(pendingEntrySide, liveConfirmed, trendDeltaPct))
            label.set_color(deltaStatusLabel, color.new(liveCol, liveConfirmed ? 5 : 45))
            label.set_textcolor(deltaStatusLabel, liveConfirmed ? color.white : color.new(color.white, 15))

        if flowConfirmed
            entrySideToCreate := pendingEntrySide

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETUP BOX CREATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
confirmedBullEntry = entrySideToCreate == 1
confirmedBearEntry = entrySideToCreate == -1

if showSetupBox and entrySideToCreate != 0
    setupSide     := entrySideToCreate
    setupStartBar := bar_index
    setupEntry    := close

    float rawRisk = setupSide == 1 ? useTrendSL ? close - trendTracker : slAtrMult * atrValue : useTrendSL ? trendTracker - close : slAtrMult * atrValue
    setupRisk := math.max(rawRisk, syminfo.mintick * 10)

    setupSL  := setupSide == 1 ? setupEntry - setupRisk       : setupEntry + setupRisk
    setupTP1 := setupSide == 1 ? setupEntry + setupRisk * rr1 : setupEntry - setupRisk * rr1
    setupTP2 := setupSide == 1 ? setupEntry + setupRisk * rr2 : setupEntry - setupRisk * rr2
    setupTP3 := setupSide == 1 ? setupEntry + setupRisk * rr3 : setupEntry - setupRisk * rr3

    setupTP1Hit := false
    setupTP2Hit := false
    setupTP3Hit := false
    setupSLHit  := false

    tp1JustHit := false
    tp2JustHit := false
    tp3JustHit := false
    slJustHit  := false

    int rightX = bar_index + liveAheadBars

    float rewardTop = setupSide == 1 ? setupTP3 : setupEntry
    float rewardBot = setupSide == 1 ? setupEntry : setupTP3
    float riskTop   = setupSide == 1 ? setupEntry : setupSL
    float riskBot   = setupSide == 1 ? setupSL    : setupEntry

    if showSetupBoxFill
        setupRewardBox := box.new(setupStartBar, rewardTop, rightX, rewardBot, xloc=xloc.bar_index, border_color=rewardBorder, bgcolor=rewardBg)
        setupRiskBox   := box.new(setupStartBar, riskTop,   rightX, riskBot,   xloc=xloc.bar_index, border_color=riskBorder,   bgcolor=riskBg)
    else
        setupRewardBox := na
        setupRiskBox   := na

    setupEntryLine := line.new(setupStartBar, setupEntry, rightX, setupEntry, xloc=xloc.bar_index, color=entryLineColor, style=line.style_dashed, width=1)
    setupTp1Line   := line.new(setupStartBar, setupTP1,  rightX, setupTP1,  xloc=xloc.bar_index, color=levelColor, style=line.style_dotted, width=1)
    setupTp2Line   := line.new(setupStartBar, setupTP2,  rightX, setupTP2,  xloc=xloc.bar_index, color=levelColor, style=line.style_dotted, width=1)
    setupTp3Line   := line.new(setupStartBar, setupTP3,  rightX, setupTP3,  xloc=xloc.bar_index, color=levelColor, style=line.style_solid,  width=1)
    setupSlLine    := line.new(setupStartBar, setupSL,   rightX, setupSL,   xloc=xloc.bar_index, color=slLineColor, style=line.style_solid,  width=1)

    setupEntryLabel := label.new(rightX, setupEntry, f_entry_lbl(setupEntry, showSetupPrices), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=entryLineColor, size=size.small)
    setupTp1Label   := label.new(rightX, setupTP1, f_level_lbl("T1", setupTP1, false, showSetupPrices), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=levelColor, size=size.small)
    setupTp2Label   := label.new(rightX, setupTP2, f_level_lbl("T2", setupTP2, false, showSetupPrices), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=levelColor, size=size.small)
    setupTp3Label   := label.new(rightX, setupTP3, f_level_lbl("T3", setupTP3, false, showSetupPrices), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=levelColor, size=size.small)
    setupSlLabel    := label.new(rightX, setupSL,  f_level_lbl("SL", setupSL, false, showSetupPrices), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=slLineColor, size=size.small)

    if deltaTradeMode and not na(deltaStatusLabel)
        float confirmedLabelY = trendTracker - atrValue * 0.18
        label.set_xy(deltaStatusLabel, bar_index, confirmedLabelY)
        label.set_text(deltaStatusLabel, f_deltaTxt(setupSide, true, trendDeltaPct))
        label.set_color(deltaStatusLabel, color.new(setupSide == 1 ? bullColor : bearColor, 5))
        label.set_textcolor(deltaStatusLabel, color.white)

    pendingEntrySide := 0
    pendingEntryBar  := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SETUP BOX UPDATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tp1JustHit := false
tp2JustHit := false
tp3JustHit := false
slJustHit  := false

if showSetupBox and setupSide != 0 and not na(setupEntry)
    int rightX = bar_index + liveAheadBars

    if useTrailingSL
        if setupSide == 1
            setupSL := math.max(setupSL, trendTracker)
        else
            setupSL := math.min(setupSL, trendTracker)

    bool prevTP1 = setupTP1Hit
    bool prevTP2 = setupTP2Hit
    bool prevTP3 = setupTP3Hit
    bool prevSL  = setupSLHit

    if setupSide == 1
        setupTP1Hit := setupTP1Hit or high >= setupTP1
        setupTP2Hit := setupTP2Hit or high >= setupTP2
        setupTP3Hit := setupTP3Hit or high >= setupTP3
        setupSLHit  := setupSLHit  or low  <= setupSL
    else
        setupTP1Hit := setupTP1Hit or low  <= setupTP1
        setupTP2Hit := setupTP2Hit or low  <= setupTP2
        setupTP3Hit := setupTP3Hit or low  <= setupTP3
        setupSLHit  := setupSLHit  or high >= setupSL

    tp1JustHit := setupTP1Hit and not prevTP1
    tp2JustHit := setupTP2Hit and not prevTP2
    tp3JustHit := setupTP3Hit and not prevTP3
    slJustHit  := setupSLHit  and not prevSL

    float rewardTop = setupSide == 1 ? setupTP3 : setupEntry
    float rewardBot = setupSide == 1 ? setupEntry : setupTP3
    float riskTop   = setupSide == 1 ? setupEntry : setupSL
    float riskBot   = setupSide == 1 ? setupSL    : setupEntry

    if showSetupBoxFill and not na(setupRewardBox) and not na(setupRiskBox)
        box.set_left(setupRewardBox, setupStartBar)
        box.set_right(setupRewardBox, rightX)
        box.set_top(setupRewardBox, rewardTop)
        box.set_bottom(setupRewardBox, rewardBot)

        box.set_left(setupRiskBox, setupStartBar)
        box.set_right(setupRiskBox, rightX)
        box.set_top(setupRiskBox, riskTop)
        box.set_bottom(setupRiskBox, riskBot)

    line.set_xy1(setupEntryLine, setupStartBar, setupEntry)
    line.set_xy2(setupEntryLine, rightX, setupEntry)
    line.set_xy1(setupTp1Line, setupStartBar, setupTP1)
    line.set_xy2(setupTp1Line, rightX, setupTP1)
    line.set_xy1(setupTp2Line, setupStartBar, setupTP2)
    line.set_xy2(setupTp2Line, rightX, setupTP2)
    line.set_xy1(setupTp3Line, setupStartBar, setupTP3)
    line.set_xy2(setupTp3Line, rightX, setupTP3)
    line.set_xy1(setupSlLine, setupStartBar, setupSL)
    line.set_xy2(setupSlLine, rightX, setupSL)

    label.set_x(setupEntryLabel, rightX)
    label.set_y(setupEntryLabel, setupEntry)
    label.set_text(setupEntryLabel, f_entry_lbl(setupEntry, showSetupPrices))

    label.set_x(setupTp1Label, rightX)
    label.set_y(setupTp1Label, setupTP1)
    label.set_text(setupTp1Label, f_level_lbl("T1", setupTP1, setupTP1Hit, showSetupPrices))

    label.set_x(setupTp2Label, rightX)
    label.set_y(setupTp2Label, setupTP2)
    label.set_text(setupTp2Label, f_level_lbl("T2", setupTP2, setupTP2Hit, showSetupPrices))

    label.set_x(setupTp3Label, rightX)
    label.set_y(setupTp3Label, setupTP3)
    label.set_text(setupTp3Label, f_level_lbl("T3", setupTP3, setupTP3Hit, showSetupPrices))

    label.set_x(setupSlLabel, rightX)
    label.set_y(setupSlLabel, setupSL)
    label.set_text(setupSlLabel, f_level_lbl("SL", setupSL, setupSLHit, showSetupPrices))

if not showSetupBox
    f_delete_setup_visuals()
    setupSide        := 0
    setupEntry       := na
    pendingEntrySide := 0
    pendingEntryBar  := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TP / SL HIT MARKERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
hitBgTP = color.new(color.gray, 25)
hitBgSL = color.new(color.gray, 25)

if showHitLabels and tp1JustHit
    label.new(bar_index, setupTP1, "TP1✓", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=hitBgTP, textcolor=color.new(levelColor, 0), size=size.tiny)

if showHitLabels and tp2JustHit
    label.new(bar_index, setupTP2, "TP2✓", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=hitBgTP, textcolor=color.new(levelColor, 0), size=size.tiny)

if showHitLabels and tp3JustHit
    label.new(bar_index, setupTP3, "TP3✓", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=hitBgTP, textcolor=color.new(levelColor, 0), size=size.tiny)

if showHitLabels and slJustHit
    label.new(bar_index, setupSL, "SLX", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=hitBgSL, textcolor=color.new(slLineColor, 0), size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHART VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showBasis ? basisCore : na, "Basis", color=basisColor, linewidth=1)
plot(showBands ? upperBand : na, "Upper Band", color=color.new(bearColor, 65), linewidth=1)
plot(showBands ? lowerBand : na, "Lower Band", color=color.new(bullColor, 65), linewidth=1)

bullTrackerPlot = trackerBull and not rawBullFlip ? trendTracker : na
bearTrackerPlot = trackerBear and not rawBearFlip ? trendTracker : na

plot(bullTrackerPlot, "Bull Trend Tracker", color=bullColor, linewidth=2, style=plot.style_linebr)
plot(bearTrackerPlot, "Bear Trend Tracker", color=bearColor, linewidth=2, style=plot.style_linebr)

barcolor(colorBars ? trackerBull ? bullColor : bearColor : na)
bgcolor(showBg ? trackerBull ? color.new(bullColor, 92) : color.new(bearColor, 92) : na)

plotchar(showFlipDiamond and bullFlip ? trendTracker : na, title="Bull Flip Marker", char="⬢", location=location.absolute, color=bullColor, size=size.tiny)
plotchar(showFlipDiamond and bearFlip ? trendTracker : na, title="Bear Flip Marker", char="⬢", location=location.absolute, color=bearColor, size=size.tiny)

plotchar(showPendingDebug and pendingSide == 1 ? trendTracker : na, title="Pending Bull", char="•", location=location.absolute, color=color.new(bullColor, 0), size=size.tiny)
plotchar(showPendingDebug and pendingSide == -1 ? trendTracker : na, title="Pending Bear", char="•", location=location.absolute, color=color.new(bearColor, 0), size=size.tiny)

isLatestBar = bar_index == last_bar_index

showClassicEntryLabels =
     showFlipLabels and (
         normalTradeMode or
         not showDeltaStatusLabels or
         not isLatestBar
     )

showClassicReentryLabels =
     showReentryLabels and (
         normalTradeMode or
         not showDeltaStatusLabels or
         not isLatestBar
     )

plotshape(
     showClassicEntryLabels and bullFlip,
     title="Bull Flip",
     text="LONG",
     style=shape.labelup,
     location=location.belowbar,
     color=bullColor,
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     showClassicEntryLabels and bearFlip,
     title="Bear Flip",
     text="SHORT",
     style=shape.labeldown,
     location=location.abovebar,
     color=bearColor,
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     showClassicReentryLabels and bullReentry,
     title="Bull Re-Entry",
     text="RE-LONG",
     style=shape.labelup,
     location=location.belowbar,
     color=bullColor,
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     showClassicReentryLabels and bearReentry,
     title="Bear Re-Entry",
     text="RE-SHORT",
     style=shape.labeldown,
     location=location.abovebar,
     color=bearColor,
     textcolor=color.white,
     size=size.tiny
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXHAUSTION (ABSORPTION) DOTS 
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
avgVol = ta.sma(volume, 20)
isVolClimax = volume > avgVol * absVolMult

bullAbs = 
     showAbsDots and 
     (not absStrictStretch or low < lowerBand) and 
     isVolClimax and 
     close > (low + (high - low) * absWickSens) and 
     trendDeltaPct > trendDeltaPct[1] and 
     trackerBear

bearAbs = 
     showAbsDots and 
     (not absStrictStretch or high > upperBand) and 
     isVolClimax and 
     close < (high - (high - low) * absWickSens) and 
     trendDeltaPct < trendDeltaPct[1] and 
     trackerBull

plotshape(
     bullAbs,
     title="Bull Exhaustion Dot",
     style=shape.circle,
     location=location.belowbar,
     color=bullColor,
     size=size.tiny
)

plotshape(
     bearAbs,
     title="Bear Exhaustion Dot",
     style=shape.circle,
     location=location.abovebar,
     color=bearColor,
     size=size.tiny
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND STAR HUD (SMART DELTA DISPLAY)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var label trendStar = label.new(
     na,
     na,
     "",
     color=color.new(color.black, 100),
     textcolor=color.white,
     style=label.style_label_center,
     size=size.normal
)

var label liveTrendStatsLabel = label.new(
     na,
     na,
     "",
     color=color.new(color.black, 100),
     textcolor=color.white,
     style=label.style_label_left,
     size=size.small
)

useDeltaHud = deltaTradeMode or showDeltaStatsAnyMode

starIcon = deltaSupportsTrend ? "✪" : "⭗"
starCol  = deltaSupportsTrend ? (trackerBull ? bullColor : bearColor) : deltaWeakColor

if barstate.islast and showTrendStar and not na(trendTracker)
    label.set_xy(trendStar, bar_index, trendTracker)
    label.set_text(trendStar, starIcon)
    label.set_textcolor(trendStar, starCol)
    label.set_color(trendStar, color.new(color.black, 100))

    trendStatsText = showTrailStats and useDeltaHud ? 
         (hudMode == "Compact" ? 
             "Δ " + str.tostring(trendDeltaPct, "#.0") + "% • " + str.tostring(trendRatio, "#.#") + "x" + (showDeltaSource ? " • " + deltaSourceTxt : "") : 
             "B " + f_k(trendBuyVol) + "\nS " + f_k(trendSellVol) + "\nΔ " + str.tostring(trendDeltaPct, "#.0") + "%" + "\nRatio " + str.tostring(trendRatio, "#.##") + "x" + (showDeltaSource ? "\n" + deltaSourceTxt : "")) : 
         ""

    label.set_xy(liveTrendStatsLabel, bar_index + 1, trendTracker)
    label.set_text(liveTrendStatsLabel, trendStatsText)
    label.set_textcolor(liveTrendStatsLabel, starCol)
    label.set_color(liveTrendStatsLabel, color.new(color.black, 100))
    label.set_size(liveTrendStatsLabel, trailStarSize)

else if barstate.islast
    label.set_xy(trendStar, na, na)
    label.set_xy(liveTrendStatsLabel, na, na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD TABLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table mtfTbl   = table.new(position.top_right, 6, 2, border_width=1, frame_width=1)
var table statsTbl = table.new(position.bottom_right, 2, 11, border_width=1, frame_width=1)

if barstate.islast
    table.set_position(mtfTbl, f_tblPos(mtfPosOpt))
    if showMTFtbl
        color bgHdr  = color.new(color.black, 20)
        color bgRow  = color.new(color.black, 70)
        color txtCol = color.white

        table.cell(mtfTbl, 0, 0, "1m",  text_color=txtCol, bgcolor=bgHdr)
        table.cell(mtfTbl, 1, 0, "5m",  text_color=txtCol, bgcolor=bgHdr)
        table.cell(mtfTbl, 2, 0, "15m", text_color=txtCol, bgcolor=bgHdr)
        table.cell(mtfTbl, 3, 0, "1H",  text_color=txtCol, bgcolor=bgHdr)
        table.cell(mtfTbl, 4, 0, "4H",  text_color=txtCol, bgcolor=bgHdr)
        table.cell(mtfTbl, 5, 0, "D",   text_color=txtCol, bgcolor=bgHdr)

        table.cell(mtfTbl, 0, 1, f_mtfTxt(st1), text_color=st1 ? bullColor : bearColor, bgcolor=bgRow)
        table.cell(mtfTbl, 1, 1, f_mtfTxt(st2), text_color=st2 ? bullColor : bearColor, bgcolor=bgRow)
        table.cell(mtfTbl, 2, 1, f_mtfTxt(st3), text_color=st3 ? bullColor : bearColor, bgcolor=bgRow)
        table.cell(mtfTbl, 3, 1, f_mtfTxt(st4), text_color=st4 ? bullColor : bearColor, bgcolor=bgRow)
        table.cell(mtfTbl, 4, 1, f_mtfTxt(st5), text_color=st5 ? bullColor : bearColor, bgcolor=bgRow)
        table.cell(mtfTbl, 5, 1, f_mtfTxt(st6), text_color=st6 ? bullColor : bearColor, bgcolor=bgRow)
    else
        table.clear(mtfTbl, 0, 0, 5, 1)

    table.set_position(statsTbl, f_tblPos(statsPosOpt))
    if showStatsTbl
        color bgHdr2  = color.new(color.black, 20)
        color bgRow2  = color.new(color.black, 70)
        color txtCol2 = color.white

        table.cell(statsTbl, 0, 0, "Metric", text_color=txtCol2, bgcolor=bgHdr2)
        table.cell(statsTbl, 1, 0, "Value",  text_color=txtCol2, bgcolor=bgHdr2)

        table.cell(statsTbl, 0, 1, "Setups", text_color=txtCol2, bgcolor=bgRow2)
        table.cell(statsTbl, 1, 1, str.tostring(statsTotalSetups), text_color=txtCol2, bgcolor=bgRow2)

        table.cell(statsTbl, 0, 2, "TP1 Rate", text_color=txtCol2, bgcolor=bgRow2)
        table.cell(statsTbl, 1, 2, f_pct_txt(statsTP1Hits, statsTotalSetups), text_color=bullColor, bgcolor=bgRow2)

        table.cell(statsTbl, 0, 3, "TP2 Rate", text_color=txtCol2, bgcolor=bgRow2)
        table.cell(statsTbl, 1, 3, f_pct_txt(statsTP2Hits, statsTotalSetups), text_color=bullColor, bgcolor=bgRow2)

        table.cell(statsTbl, 0, 4, "TP3 Rate", text_color=txtCol2, bgcolor=bgRow2)
        table.cell(statsTbl, 1, 4, f_pct_txt(statsTP3Hits, statsTotalSetups), text_color=bullColor, bgcolor=bgRow2)

        table.cell(statsTbl, 0, 5, "SL Rate", text_color=txtCol2, bgcolor=bgRow2)
        table.cell(statsTbl, 1, 5, showSLRate ? f_pct_txt(statsSLHits, statsTotalSetups) : "Off", text_color=bearColor, bgcolor=bgRow2)

        if showAdaptiveInStats and useAdaptive
            string adaptStatus = adaptiveReady ? adaptivePick : "Warming"
            table.cell(statsTbl, 0, 6, "Adaptive", text_color=txtCol2, bgcolor=bgHdr2)
            table.cell(statsTbl, 1, 6, adaptStatus, text_color=adaptiveReady ? bullColor : color.new(color.white, 25), bgcolor=bgHdr2)

            table.cell(statsTbl, 0, 7, "Best Fast", text_color=txtCol2, bgcolor=bgRow2)
            table.cell(statsTbl, 1, 7, adaptiveReady ? str.tostring(adaptiveFastLen) : "Waiting", text_color=txtCol2, bgcolor=bgRow2)

            table.cell(statsTbl, 0, 8, "Best ATR", text_color=txtCol2, bgcolor=bgRow2)
            table.cell(statsTbl, 1, 8, adaptiveReady ? str.tostring(adaptiveAtrLen) : "Waiting", text_color=txtCol2, bgcolor=bgRow2)

            table.cell(statsTbl, 0, 9, "Best Mult", text_color=txtCol2, bgcolor=bgRow2)
            table.cell(statsTbl, 1, 9, adaptiveReady ? str.tostring(adaptiveAtrMult, "#.##") : "Waiting", text_color=txtCol2, bgcolor=bgRow2)

            table.cell(statsTbl, 0, 10, "Opt Score", text_color=txtCol2, bgcolor=bgRow2)
            table.cell(statsTbl, 1, 10, adaptiveReady ? str.tostring(adaptiveShownScore, "#.##") + " / " + str.tostring(adaptiveSetups) : "n/a", text_color=adaptiveReady ? bullColor : color.new(color.white, 25), bgcolor=bgRow2)
        else
            table.clear(statsTbl, 0, 6, 1, 10)
    else
        table.clear(statsTbl, 0, 0, 1, 10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MASTER ALERT CONDITION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
masterBullFlip      = alertBullFlip and bullFlip
masterBearFlip      = alertBearFlip and bearFlip
masterBullReentry   = alertBullReentry and bullReentry
masterBearReentry   = alertBearReentry and bearReentry
masterBullConfirmed = alertBullConfirmed and confirmedBullEntry
masterBearConfirmed = alertBearConfirmed and confirmedBearEntry
masterBullRevDot    = alertBullRevDot and bullAbs
masterBearRevDot    = alertBearRevDot and bearAbs
masterTP1           = alertTP1 and tp1JustHit
masterTP2           = alertTP2 and tp2JustHit
masterTP3           = alertTP3 and tp3JustHit
masterSL            = alertSL and slJustHit

anyMasterAlert =
     masterBullFlip or
     masterBearFlip or
     masterBullReentry or
     masterBearReentry or
     masterBullConfirmed or
     masterBearConfirmed or
     masterBullRevDot or
     masterBearRevDot or
     masterTP1 or
     masterTP2 or
     masterTP3 or
     masterSL

alertcondition(
     anyMasterAlert,
     "Any Master Alert",
     "Trend Tracker: Any enabled master alert condition triggered."
)
````
