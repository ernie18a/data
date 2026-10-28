# Liquidity Volume Matrix

- url: https://www.tradingview.com/script/iSwvDhaw-Liquidity-Volume-Matrix/
- type: indicator
- pine_id: PUB;81e2b28fcd854727b4eb4630bb89b710
- version: 1.0

## Description

Liquidity Volume Matrix (LVM)

Liquidity Volume Matrix is a volume-validated liquidity analysis indicator designed to help traders study where resting liquidity may exist, how price reacts around those levels, and whether a sweep is supported by volume and directional pressure.

This is an indicator, not a trading strategy. It does not place orders, does not provide backtest results, and does not claim that any signal will produce a profitable trade. Its purpose is to organize liquidity, volume profile, and net-volume information directly on the chart so traders can make their own analysis.

What the indicator does

Liquidity Volume Matrix combines four main components:

1. Liquidity Levels
   The script detects confirmed swing highs and swing lows using pivot logic. Swing highs are treated as potential Buy-Side Liquidity (BSL) above price, while swing lows are treated as potential Sell-Side Liquidity (SSL) below price.

BSL represents areas where buy stops or breakout liquidity may exist above price.
SSL represents areas where sell stops or downside liquidity may exist below price.

The indicator extends these levels forward until they are swept, broken, removed, or recolored depending on the user settings.

2. Volume-Validated Liquidity Pools
   Each liquidity level can be evaluated using resting volume around that price zone. The script scans a configurable lookback window and measures volume around each liquidity level using a percentage-based price band.

The level can be classified as:

HIGH — stronger relative volume around the level
MED — moderate relative volume around the level
LOW — weaker relative volume around the level

This grading is not a trade signal. It is only a contextual reading of how much historical volume has interacted with that price area.

3. Liquidity Sweeps
   The script marks two types of liquidity sweeps:

SSL Sweep
A sell-side liquidity sweep occurs when price trades below a sell-side liquidity level and then closes back above that level. This means price took liquidity below a prior swing low and rejected lower prices.

BSL Sweep
A buy-side liquidity sweep occurs when price trades above a buy-side liquidity level and then closes back below that level. This means price took liquidity above a prior swing high and rejected higher prices.

The script can optionally require:

Volume confirmation
Delta / net-volume agreement
Next-bar confirmation

When next-bar confirmation is enabled, the label appears only after the following candle confirms the sweep direction. For example, an SSL Sweep is confirmed when the next candle closes above the sweep candle’s high. A BSL Sweep is confirmed when the next candle closes below the sweep candle’s low.

Sweep labels are not automatic buy or sell signals. They identify liquidity events that traders may choose to study with their own trend, risk, and confirmation methods.

4. Internal Volume Profile
   The indicator builds an internal rolling volume profile using the selected lookback period. It divides the recent price range into bins and distributes volume across those bins based on candle overlap.

The profile displays:

POC — Point of Control
The price area with the highest estimated volume within the selected profile range.

VAH — Value Area High
The upper boundary of the value area.

VAL — Value Area Low
The lower boundary of the value area.

Value Area
The price range containing the selected percentage of total profile volume, commonly set to 70%.

Liquidity Voids / LVN
Low-volume areas where the profile volume is below the selected threshold relative to the POC bin.

The profile is an internal approximation built from available chart volume and candle ranges. It is not intended to exactly replicate exchange-native volume profile tools.

Net Volume / Delta Logic

The script includes a pressure reading based on net volume.

When possible, it uses lower-timeframe volume delta through TradingView’s volume delta function. If lower-timeframe delta is not available, the script falls back to a candle-based proxy using the candle close location inside the high-low range.

The dashboard shows:

Smoothed Pressure
An EMA-smoothed reading of net volume.

Current Bar Net Vol
The current bar’s estimated net volume.

Delta Source
Shows whether the reading comes from intrabar data or from the candle proxy.

Because not all symbols provide the same quality of volume or intrabar data, users should treat delta and net-volume readings as contextual information, not as exact order-flow data.

Dashboard

The dashboard summarizes the most important live information:

Smoothed Pressure
Current Bar Net Vol
Nearest BSL Above
Nearest SSL Below
POC
Value Area
Current Zone
Last Sweep
Main Focus

The Main Focus field is not a trading recommendation. It is a contextual guide showing where the next important liquidity or value-area reaction may occur.

Settings explained

Liquidity Levels

Pivot Lookback
Controls how many bars are used on each side to confirm a swing high or swing low. Higher values produce fewer but stronger levels. Lower values produce more levels but may increase noise.

Level Source
Allows levels to be created from candle wicks or closing prices. Wicks are more sensitive to liquidity grabs. Close-based levels are more conservative.

Max Levels Kept
Controls how many liquidity levels remain on the chart.

Keep Swept Levels
When enabled, swept levels remain on the chart in a different color. When disabled, swept levels are removed.

Tag Resting Volume on Levels
Displays estimated volume around each liquidity level together with a HIGH / MED / LOW grade.

Resting-Volume Lookback
Controls how far back the script scans when measuring volume around a liquidity level.

Level Volume Band
Controls the price band around each level used for volume accumulation.

HIGH grade / MED grade
Controls how the script classifies the relative volume around each liquidity level.

Liquidity Sweeps

Show Sweep Signals
Turns sweep labels on or off.

Confirm Sweep Next Bar
Requires confirmation from the candle after the sweep before printing the sweep label.

Require Volume Confirmation
Requires the sweep candle to have a volume spike.

Sweep Volume Spike
Defines how large the sweep candle volume must be compared with its recent average.

Sweep Volume Average Length
Defines the volume average used for sweep confirmation.

Require Delta Agreement
Requires net-volume direction to agree with the sweep type.

Remove Levels on Break
Removes a level when price closes through it instead of only sweeping it.

Volume Profile

Show Volume Profile
Turns the internal rolling profile on or off.

Profile Lookback
Controls how many recent bars are included in the profile.

Profile Bins
Controls the resolution of the profile. Higher values create more detailed bins but can make the chart busier.

Value Area %
Defines how much of total volume is included in the value area.

Profile Width
Controls the horizontal width of the profile bars.

Profile Offset
Controls how far the profile is placed from the most recent candle.

Draw POC / VAH / VAL Lines
Displays the Point of Control and value area boundaries.

Highlight Liquidity Voids
Highlights low-volume areas.

Void Threshold
Defines how low volume must be relative to the POC bin for a zone to be treated as a liquidity void.

Net Volume / Delta

Delta Source
Auto mode uses intrabar volume delta when available. Candle proxy mode estimates net volume from candle structure.

Use Custom Lower Timeframe
Allows the user to manually select the lower timeframe used for intrabar delta.

Pressure Smoothing Length
Controls the EMA smoothing length applied to net volume.

Dashboard

Show Dashboard
Shows or hides the dashboard.

Position
Controls dashboard location.

Text Size
Controls dashboard text size.

Colors & Style

Buy-Side Liquidity
Color for BSL levels above price.

Sell-Side Liquidity
Color for SSL levels below price.

Swept / Broken Level
Color for levels after they are swept or broken.

SSL Sweep Confirmation
Color for confirmed sell-side sweeps.

BSL Sweep Confirmation
Color for confirmed buy-side sweeps.

POC Line / POC Text
Color for the Point of Control.

Value Area / Profile
Color for the profile and value-area components.

Liquidity Void
Color for LVN / liquidity void areas.

Visual Clarity

Highlight Nearest BSL / SSL
Emphasizes the nearest active liquidity level above and below price.

Nearest Level Width
Controls the thickness of the nearest active levels.

Dim Far Levels
Makes non-nearest levels lighter to reduce clutter.

Level Label Mode
Controls whether labels appear on all levels, nearest levels only, short labels only, or not at all.

Show Volume Text Only On Nearest
Keeps volume text only on the nearest active BSL and SSL to avoid label overlap.

Profile Visual Strength

POC Line Width
Controls how visible the POC line is.

POC Box Transparency
Controls the strength of the profile bar at the POC.

Value Area Transparency
Controls the opacity of the value area profile bars.

Other Profile Transparency
Controls the opacity of profile bars outside the value area.

Void Zone Transparency
Controls the opacity of liquidity void zones.

How to use this indicator

One practical workflow is:

1. Identify the nearest BSL above price and SSL below price.
2. Check whether price is trading inside, above, or below the value area.
3. Watch how price reacts when it reaches BSL, SSL, POC, VAH, or VAL.
4. Treat confirmed sweeps as liquidity events, not as standalone entries.
5. Use your own market structure, trend, risk management, and confirmation process before making any trading decision.

For example:

If price sweeps SSL and closes back above the level, this may show that downside liquidity was taken and rejected. The user can then study whether market structure, volume, and risk location support a bullish idea.

If price sweeps BSL and closes back below the level, this may show that upside liquidity was taken and rejected. The user can then study whether market structure, volume, and risk location support a bearish idea.

Important limitations

This indicator does not predict future price movement.

Liquidity levels are based on confirmed pivots, which means they appear only after the required number of bars has passed.

Volume profile calculations are internal approximations based on available chart data.

Delta may come from intrabar data or from a candle-based proxy depending on symbol and timeframe availability.

Sweep labels are not buy or sell signals.

The indicator should not be used alone for trade execution.

Different symbols, timeframes, and data providers may produce different volume and delta behavior.

Recommended use

Liquidity Volume Matrix is best used as a decision-support tool for discretionary market analysis. It may be useful for traders who study liquidity, stop runs, sweep reactions, volume profile context, POC reactions, value area behavior, and low-volume zones.

It is designed for visual market context, not automated trading, not guaranteed signal generation, and not financial advice.

Alerts

The script includes alerts for:

Confirmed SSL Sweep
Confirmed BSL Sweep
Any confirmed liquidity sweep
New Buy-Side Liquidity
New Sell-Side Liquidity

These alerts notify the user that a liquidity event or new liquidity level has appeared. They do not instruct the user to buy or sell.

Originality and purpose

Liquidity Volume Matrix combines liquidity-level mapping, volume validation, sweep confirmation, internal volume profile, value-area context, liquidity void detection, and net-volume pressure into one chart-based tool.

The purpose of combining these components is to reduce the need to read liquidity, profile, and volume pressure separately. The script attempts to show where liquidity may rest, whether that liquidity was swept, whether volume supported the event, and where price is trading relative to POC and value area.

This makes the script a contextual liquidity and volume map rather than a simple signal marker.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ADXAE

//@version=6
//
// =============================================================================
//  LIQUIDITY VOLUME MATRIX  (LVM)
// =============================================================================
//
//  A volume-validated liquidity tool.
//
//  Key ideas:
//    1. Liquidity Pools: BSL above price and SSL below price.
//    2. Volume-confirmed sweeps.
//    3. Internal Volume Profile: POC, Value Area, and LVN voids.
//
//  Improvements in this version:
//    - Bull Sweep label renamed to SSL Sweep.
//    - Bear Sweep label renamed to BSL Sweep.
//    - Optional next-bar sweep confirmation added.
//    - Default level labels are Nearest Only to prevent text overlap.
//    - Far levels can remain as clean lines without long text.
//    - POC line and Value Area colors are clearer.
//    - Dashboard terminology is clearer:
//          * Smoothed Pressure
//          * Current Bar Net Vol
//
//  Pure indicator - no strategy logic.
// =============================================================================

indicator("Liquidity Volume Matrix", "LVM", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500,
     max_bars_back = 2000)

import TradingView/ta/12 as tvta


// =============================================================================
//  GROUPS
// =============================================================================

var string g_liq       = "1. Liquidity Levels"
var string g_sweep     = "2. Liquidity Sweeps"
var string g_prof      = "3. Volume Profile"
var string g_delta     = "4. Net Volume / Delta"
var string g_dash      = "5. Dashboard"
var string g_style     = "6. Colors & Style"
var string g_vis       = "7. Visual Clarity"
var string g_profStyle = "8. Profile Visual Strength"


// =============================================================================
//  INPUTS - LIQUIDITY LEVELS
// =============================================================================

i_pivLen = input.int(8, "Pivot Lookback", minval = 2, maxval = 50, group = g_liq,
     tooltip = "Bars on each side of a swing point. Higher = fewer but stronger liquidity levels. Lower = more sensitive.")

i_pivotSrc = input.string("Wicks", "Level Source", options = ["Wicks", "Close"], group = g_liq,
     tooltip = "Wicks: levels are drawn at candle highs/lows. Close: levels are drawn at closing prices.")

i_maxLevels = input.int(10, "Max Levels Kept", minval = 2, maxval = 80, group = g_liq,
     tooltip = "Maximum liquidity levels kept on the chart. Lower values reduce clutter.")

i_keepSwept = input.bool(true, "Keep Swept Levels (recolored)", group = g_liq,
     tooltip = "ON: swept levels stay on chart as a record. OFF: swept levels are deleted.")

i_showLevelVol = input.bool(true, "Tag Resting Volume on Levels", group = g_liq,
     tooltip = "Show estimated volume around each liquidity level plus HIGH / MED / LOW grade.")

i_volLookback = input.int(300, "Resting-Volume Lookback (bars)", minval = 20, maxval = 2000, group = g_liq, active = i_showLevelVol,
     tooltip = "How many bars back to scan when measuring volume around a level.")

i_bandPct = input.float(0.25, "Level Volume Band (+/- % of price)", minval = 0.01, maxval = 5.0, step = 0.05, group = g_liq, active = i_showLevelVol,
     tooltip = "Half-width of the price band used to accumulate volume around a level.")

i_strongMult = input.float(1.5, "HIGH grade (x average bar volume)", minval = 1.0, step = 0.1, group = g_liq, active = i_showLevelVol,
     tooltip = "A pool is graded HIGH when the average volume of bars touching it is at least this multiple of normal volume.")

i_medMult = input.float(1.0, "MED grade (x average bar volume)", minval = 0.3, step = 0.1, group = g_liq, active = i_showLevelVol,
     tooltip = "A pool is graded MED at this multiple. Below this is LOW.")


// =============================================================================
//  INPUTS - LIQUIDITY SWEEPS
// =============================================================================

i_showSweeps = input.bool(true, "Show Sweep Signals", group = g_sweep,
     tooltip = "Mark liquidity grabs. SSL Sweep means sell-side liquidity was taken. BSL Sweep means buy-side liquidity was taken.")

i_confirmSweeps = input.bool(true, "Confirm Sweep Next Bar", group = g_sweep, active = i_showSweeps,
     tooltip = "ON: a sweep label appears only if the next candle confirms direction. SSL Sweep confirms when next close is above sweep high. BSL Sweep confirms when next close is below sweep low.")

i_requireVol = input.bool(true, "Require Volume Confirmation", group = g_sweep, active = i_showSweeps,
     tooltip = "ON: sweep must happen with a volume spike.")

i_sweepVolMult = input.float(1.5, "Sweep Volume Spike (x average)", minval = 1.0, step = 0.1, group = g_sweep, active = i_showSweeps,
     tooltip = "Volume must be at least this multiple of its recent average.")

i_sweepVolLen = input.int(20, "Sweep Volume Average Length", minval = 2, maxval = 200, group = g_sweep, active = i_showSweeps,
     tooltip = "Lookback for sweep volume average.")

i_requireDelta = input.bool(true, "Require Delta Agreement", group = g_sweep, active = i_showSweeps,
     tooltip = "ON: SSL Sweep needs net buying; BSL Sweep needs net selling.")

i_removeBroken = input.bool(true, "Remove Levels on Break (close through)", group = g_sweep,
     tooltip = "ON: if price closes through a level, the level is removed.")


// =============================================================================
//  INPUTS - VOLUME PROFILE
// =============================================================================

i_showProfile = input.bool(true, "Show Volume Profile", group = g_prof,
     tooltip = "Draw internal volume profile with POC, Value Area and Liquidity Voids.")

i_profLookback = input.int(250, "Profile Lookback (bars)", minval = 20, maxval = 2000, group = g_prof, active = i_showProfile,
     tooltip = "Number of recent bars included in the volume profile.")

i_profBins = input.int(40, "Profile Bins (resolution)", minval = 10, maxval = 150, group = g_prof, active = i_showProfile,
     tooltip = "Number of price buckets. Higher = more detailed but busier.")

i_vaPct = input.float(70.0, "Value Area %", minval = 50.0, maxval = 95.0, step = 1.0, group = g_prof, active = i_showProfile,
     tooltip = "Percent of total volume that defines the Value Area.")

i_profMaxLen = input.int(60, "Profile Width (bars)", minval = 10, maxval = 300, group = g_prof, active = i_showProfile,
     tooltip = "Width of the longest profile bar.")

i_profGap = input.int(8, "Profile Offset From Last Bar (bars)", minval = 0, maxval = 100, group = g_prof, active = i_showProfile,
     tooltip = "Gap between last candle and where the profile starts.")

i_showPOC = input.bool(true, "Draw POC / VAH / VAL Lines", group = g_prof, active = i_showProfile,
     tooltip = "Draw Point of Control and Value Area lines.")

i_showVoids = input.bool(true, "Highlight Liquidity Voids (LVN)", group = g_prof, active = i_showProfile,
     tooltip = "Shade Low Volume Node zones.")

i_lvnPct = input.float(15.0, "Void Threshold (% of POC volume)", minval = 1.0, maxval = 50.0, step = 1.0, group = g_prof, active = i_showProfile,
     tooltip = "A bin is treated as a void when its volume is below this percent of the POC bin.")


// =============================================================================
//  INPUTS - NET VOLUME / DELTA
// =============================================================================

i_deltaSrc = input.string("Auto (intrabar)", "Delta Source", options = ["Auto (intrabar)", "Candle proxy"], group = g_delta,
     tooltip = "Auto: uses lower-timeframe volume delta when available. Candle proxy: estimates delta from candle close location.")

i_customTF = input.bool(false, "Use Custom Lower Timeframe", group = g_delta,
     tooltip = "Override automatically selected lower timeframe for intrabar delta.")

i_ltf = input.timeframe("1", "Lower Timeframe", group = g_delta, active = i_customTF,
     tooltip = "Lower timeframe used for intrabar delta.")

i_deltaLen = input.int(14, "Pressure Smoothing Length", minval = 1, maxval = 200, group = g_delta,
     tooltip = "EMA length applied to net volume to create the smoothed pressure reading.")


// =============================================================================
//  INPUTS - DASHBOARD
// =============================================================================

i_showDash = input.bool(true, "Show Dashboard", group = g_dash,
     tooltip = "Show live panel summarizing pressure, nearest liquidity, POC and Value Area.")

i_dashPos = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = g_dash, active = i_showDash,
     tooltip = "Dashboard position.")

i_dashSize = input.string("Normal", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = g_dash, active = i_showDash,
     tooltip = "Dashboard text size.")


// =============================================================================
//  INPUTS - COLORS & STYLE
// =============================================================================

i_colBSL = input.color(#2962ff, "Buy-Side Liquidity (BSL, above)", group = g_style,
     tooltip = "Color of liquidity above price.")

i_colSSL = input.color(#ff9800, "Sell-Side Liquidity (SSL, below)", group = g_style,
     tooltip = "Color of liquidity below price.")

i_colSwept = input.color(#787b86, "Swept / Broken Level", group = g_style,
     tooltip = "Color of swept or broken levels.")

i_colBull = input.color(#26a69a, "SSL Sweep Confirmation", group = g_style,
     tooltip = "Color used when sell-side liquidity is swept and confirmed.")

i_colBear = input.color(#ef5350, "BSL Sweep Confirmation", group = g_style,
     tooltip = "Color used when buy-side liquidity is swept and confirmed.")

i_colPOC = input.color(#ffb300, "POC Line / POC Text", group = g_style,
     tooltip = "Main POC color. Strong amber is used so the POC stays clear on light and dark charts.")

i_colVA = input.color(#42a5f5, "Value Area / Profile", group = g_style,
     tooltip = "Soft blue used for Value Area and profile bars.")

i_colVoid = input.color(#ab47bc, "Liquidity Void (LVN)", group = g_style,
     tooltip = "Liquidity void color.")

i_lineWidth = input.int(1, "Normal Level Line Width", minval = 1, maxval = 4, group = g_style,
     tooltip = "Thickness of normal liquidity level lines.")

i_lineStyle = input.string("Solid", "Level Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_style,
     tooltip = "Style for active liquidity level lines.")


// =============================================================================
//  INPUTS - VISUAL CLARITY
// =============================================================================

i_highlightNearest = input.bool(true, "Highlight Nearest BSL / SSL", group = g_vis,
     tooltip = "ON: the nearest active liquidity above and below price are emphasized.")

i_nearestWidth = input.int(3, "Nearest Level Width", minval = 1, maxval = 5, group = g_vis, active = i_highlightNearest,
     tooltip = "Line thickness for the nearest active BSL and SSL.")

i_dimFarLevels = input.bool(true, "Dim Far Levels", group = g_vis,
     tooltip = "ON: non-nearest levels are shown with lighter transparency to reduce chart clutter.")

i_farTransp = input.int(55, "Far Level Transparency", minval = 0, maxval = 90, group = g_vis, active = i_dimFarLevels,
     tooltip = "Higher value makes non-nearest levels lighter.")

i_showNearestTag = input.bool(true, "Add NEAREST Tag", group = g_vis,
     tooltip = "ON: nearest BSL / SSL labels include a NEAREST tag.")

i_levelLabelMode = input.string("Nearest Only", "Level Label Mode",
     options = ["Nearest Only", "All", "Short", "None"], group = g_vis,
     tooltip = "Nearest Only: text appears only on nearest BSL and nearest SSL. All: all labels show full text. Short: all labels show short text. None: hide all level label text.")

i_levelLabelSize = input.string("Small", "Level Label Size",
     options = ["Tiny", "Small", "Normal"], group = g_vis,
     tooltip = "Controls size of level labels.")

i_showOnlyNearestVolText = input.bool(true, "Show Volume Text Only On Nearest", group = g_vis,
     tooltip = "ON: volume text appears only on the nearest active BSL / SSL. This makes the chart cleaner.")


// =============================================================================
//  INPUTS - PROFILE VISUAL STRENGTH
// =============================================================================

i_pocLineWidth = input.int(2, "POC Line Width", minval = 1, maxval = 5, group = g_profStyle,
     tooltip = "Thickness of the POC line. Increase if the POC is not visible enough.")

i_pocBoxTransp = input.int(72, "POC Box Transparency", minval = 40, maxval = 95, group = g_profStyle,
     tooltip = "Lower value = stronger POC profile bar. Higher value = softer.")

i_vaBoxTransp = input.int(88, "Value Area Transparency", minval = 60, maxval = 98, group = g_profStyle,
     tooltip = "Lower value = stronger Value Area profile. Higher value = softer.")

i_otherBoxTransp = input.int(94, "Other Profile Transparency", minval = 70, maxval = 99, group = g_profStyle,
     tooltip = "Transparency for profile bars outside the Value Area.")

i_voidBoxTransp = input.int(94, "Void Zone Transparency", minval = 70, maxval = 99, group = g_profStyle,
     tooltip = "Transparency for liquidity void zones.")


// =============================================================================
//  TYPES
// =============================================================================

type Liq
    float  price
    int    bar
    bool   isHigh
    bool   swept
    float  vol
    string grade
    line   ln
    label  lb


// =============================================================================
//  HELPERS
// =============================================================================

f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Large"  => size.large
        "Normal" => size.normal
        => size.normal

f_labelSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        "Small"  => size.small
        => size.small

f_pos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Right" => position.middle_right
        => position.top_right

f_lstyle() =>
    i_lineStyle == "Dashed" ? line.style_dashed : i_lineStyle == "Dotted" ? line.style_dotted : line.style_solid

f_fmt(float v) =>
    float a = math.abs(v)
    string s = v < 0 ? "-" : ""
    a >= 1000000000 ? s + str.tostring(a / 1000000000, "#.##") + "B" :
     a >= 1000000   ? s + str.tostring(a / 1000000, "#.##") + "M" :
     a >= 1000      ? s + str.tostring(a / 1000, "#.#") + "K" :
     s + str.tostring(a, "#")

f_levelText(bool isHigh, float price, float lvlVol, string grade, bool isNearest) =>
    string sideTxt = isHigh ? "BSL" : "SSL"

    string result = ""

    if i_levelLabelMode == "None"
        result := ""
    else if i_levelLabelMode == "Nearest Only"
        if isNearest
            string nearTxt = i_showNearestTag ? " NEAREST" : ""
            string volTxt = i_showLevelVol ? ("  " + f_fmt(lvlVol) + " [" + grade + "]") : ""
            result := sideTxt + nearTxt + "  " + str.tostring(price, format.mintick) + volTxt
        else
            result := ""
    else if i_levelLabelMode == "Short"
        result := sideTxt + "  " + str.tostring(price, format.mintick)
    else
        string nearTxt = isNearest and i_showNearestTag ? " NEAREST" : ""
        string volTxt = i_showLevelVol and (not i_showOnlyNearestVolText or isNearest) ? ("  " + f_fmt(lvlVol) + " [" + grade + "]") : ""
        result := sideTxt + nearTxt + "  " + str.tostring(price, format.mintick) + volTxt

    result

f_volAtLevel(float price, float bandHalf, int lookback) =>
    float tot = 0.0
    int   cnt = 0
    for i = 0 to lookback - 1
        if high[i] >= price - bandHalf and low[i] <= price + bandHalf
            tot += nz(volume[i])
            cnt += 1
    [tot, cnt]


// =============================================================================
//  NET VOLUME / DELTA
// =============================================================================

string lowerTF = switch
    i_customTF           => i_ltf
    timeframe.isseconds  => "1S"
    timeframe.isintraday => "1"
    timeframe.isdaily    => "5"
    => "60"

[_, _, _, ltfDelta] = tvta.requestVolumeDelta(lowerTF)

bool  deltaAvail = i_deltaSrc == "Auto (intrabar)" and not na(ltfDelta)
float clv        = (high - low) > 0 ? (2.0 * close - high - low) / (high - low) : 0.0
float netVol     = deltaAvail ? ltfDelta : clv * nz(volume)
float pressure   = ta.ema(netVol, i_deltaLen)


// =============================================================================
//  CORE SERIES
// =============================================================================

float avgBarVol   = ta.sma(volume, i_volLookback)
float avgSweepVol = ta.sma(volume, i_sweepVolLen)
bool  volSpike    = nz(volume) >= avgSweepVol * i_sweepVolMult

float hiSrc = i_pivotSrc == "Wicks" ? high : close
float loSrc = i_pivotSrc == "Wicks" ? low  : close
float ph = ta.pivothigh(hiSrc, i_pivLen, i_pivLen)
float pl = ta.pivotlow(loSrc,  i_pivLen, i_pivLen)

var array<Liq> liqs = array.new<Liq>()

bool bullSweepEvent = false
bool bearSweepEvent = false

var string lastSweepTxt = "-"
var int    lastSweepBar = na

var bool   pendingSSL = false
var int    pendingSSLBar = na
var float  pendingSSLHigh = na
var float  pendingSSLLow = na
var string pendingSSLMark = ""

var bool   pendingBSL = false
var int    pendingBSLBar = na
var float  pendingBSLHigh = na
var float  pendingBSLLow = na
var string pendingBSLMark = ""


// =============================================================================
//  CONFIRM PENDING SWEEPS ON NEXT BAR
// =============================================================================

if i_confirmSweeps and pendingSSL and not na(pendingSSLBar)
    if bar_index == pendingSSLBar + 1
        bool confirmedSSL = close > pendingSSLHigh
        if confirmedSSL
            bullSweepEvent := true
            lastSweepTxt := "SSL Sweep Confirmed" + pendingSSLMark
            lastSweepBar := pendingSSLBar
            label.new(pendingSSLBar, pendingSSLLow, "SSL Sweep\nConfirmed" + pendingSSLMark,
                 style = label.style_label_up, color = i_colBull,
                 textcolor = color.white, size = size.small, yloc = yloc.belowbar)
        pendingSSL := false
    else if bar_index > pendingSSLBar + 1
        pendingSSL := false

if i_confirmSweeps and pendingBSL and not na(pendingBSLBar)
    if bar_index == pendingBSLBar + 1
        bool confirmedBSL = close < pendingBSLLow
        if confirmedBSL
            bearSweepEvent := true
            lastSweepTxt := "BSL Sweep Confirmed" + pendingBSLMark
            lastSweepBar := pendingBSLBar
            label.new(pendingBSLBar, pendingBSLHigh, "BSL Sweep\nConfirmed" + pendingBSLMark,
                 style = label.style_label_down, color = i_colBear,
                 textcolor = color.white, size = size.small, yloc = yloc.abovebar)
        pendingBSL := false
    else if bar_index > pendingBSLBar + 1
        pendingBSL := false


// =============================================================================
//  MANAGE EXISTING LEVELS - SWEEPS, BREAKS, EXTENSION
// =============================================================================

if array.size(liqs) > 0
    for idx = array.size(liqs) - 1 to 0
        Liq L = array.get(liqs, idx)

        if not L.swept
            bool brokeUp   = L.isHigh and close > L.price
            bool brokeDn   = (not L.isHigh) and close < L.price

            bool sweepBSL = L.isHigh and high > L.price and close <= L.price
            bool sweepSSL = (not L.isHigh) and low < L.price and close >= L.price

            if brokeUp or brokeDn
                if i_removeBroken
                    line.delete(L.ln)
                    label.delete(L.lb)
                    array.remove(liqs, idx)
                else
                    L.swept := true
                    line.set_x2(L.ln, bar_index)
                    line.set_color(L.ln, i_colSwept)
                    line.set_style(L.ln, line.style_dotted)
                    line.set_width(L.ln, 1)
                    label.set_textcolor(L.lb, i_colSwept)
                    label.set_text(L.lb, "")
                    array.set(liqs, idx, L)

            else if sweepBSL or sweepSSL
                bool deltaOk = sweepSSL ? netVol > 0 : netVol < 0
                bool pass    = i_showSweeps and (not i_requireVol or volSpike) and (not i_requireDelta or deltaOk)
                string mark  = volSpike ? "*" : ""

                if pass
                    if sweepSSL
                        if i_confirmSweeps
                            pendingSSL := true
                            pendingSSLBar := bar_index
                            pendingSSLHigh := high
                            pendingSSLLow := low
                            pendingSSLMark := mark
                        else
                            bullSweepEvent := true
                            lastSweepTxt := "SSL Sweep" + mark
                            lastSweepBar := bar_index
                            label.new(bar_index, low, "SSL Sweep" + mark,
                                 style = label.style_label_up, color = i_colBull,
                                 textcolor = color.white, size = size.small, yloc = yloc.belowbar)
                    else
                        if i_confirmSweeps
                            pendingBSL := true
                            pendingBSLBar := bar_index
                            pendingBSLHigh := high
                            pendingBSLLow := low
                            pendingBSLMark := mark
                        else
                            bearSweepEvent := true
                            lastSweepTxt := "BSL Sweep" + mark
                            lastSweepBar := bar_index
                            label.new(bar_index, high, "BSL Sweep" + mark,
                                 style = label.style_label_down, color = i_colBear,
                                 textcolor = color.white, size = size.small, yloc = yloc.abovebar)

                if i_keepSwept
                    L.swept := true
                    line.set_x2(L.ln, bar_index)
                    line.set_color(L.ln, i_colSwept)
                    line.set_style(L.ln, line.style_dotted)
                    line.set_width(L.ln, 1)
                    label.set_textcolor(L.lb, i_colSwept)
                    label.set_text(L.lb, "")
                    array.set(liqs, idx, L)
                else
                    line.delete(L.ln)
                    label.delete(L.lb)
                    array.remove(liqs, idx)

            else
                line.set_x2(L.ln, bar_index)
                label.set_x(L.lb, bar_index)
                array.set(liqs, idx, L)


// =============================================================================
//  CREATE NEW LEVELS FROM PIVOTS
// =============================================================================

f_addLevel(float price, int pivotBar, bool isHigh) =>
    float bandHalf = price * i_bandPct / 100.0
    float lvlVol = 0.0
    int   lvlCnt = 0

    if i_showLevelVol
        [tv, tc] = f_volAtLevel(price, bandHalf, i_volLookback)
        lvlVol := tv
        lvlCnt := tc

    float perBar = lvlCnt > 0 ? lvlVol / lvlCnt : 0.0
    string grade = perBar >= avgBarVol * i_strongMult ? "HIGH" : perBar >= avgBarVol * i_medMult ? "MED" : "LOW"

    color  col = isHigh ? i_colBSL : i_colSSL
    string txt = f_levelText(isHigh, price, lvlVol, grade, false)

    line ln = line.new(pivotBar, price, bar_index, price, color = col, width = i_lineWidth, style = f_lstyle())
    label lb = label.new(bar_index, price, txt, style = label.style_label_left,
         color = color.new(color.black, 100), textcolor = col, size = f_labelSize(i_levelLabelSize))

    array.push(liqs, Liq.new(price, pivotBar, isHigh, false, lvlVol, grade, ln, lb))

if not na(ph)
    f_addLevel(ph, bar_index - i_pivLen, true)

if not na(pl)
    f_addLevel(pl, bar_index - i_pivLen, false)

while array.size(liqs) > i_maxLevels
    Liq old = array.shift(liqs)
    line.delete(old.ln)
    label.delete(old.lb)


// =============================================================================
//  NEAREST LIQUIDITY DETECTION + VISUAL UPDATE
// =============================================================================

float nearestBSL = na
float nearestSSL = na
int nearestBSLIndex = na
int nearestSSLIndex = na
float nearestBSLVol = na
float nearestSSLVol = na

if array.size(liqs) > 0
    for i = 0 to array.size(liqs) - 1
        Liq L = array.get(liqs, i)

        if not L.swept
            if L.isHigh and L.price > close
                if na(nearestBSL) or L.price < nearestBSL
                    nearestBSL := L.price
                    nearestBSLIndex := i
                    nearestBSLVol := L.vol

            if (not L.isHigh) and L.price < close
                if na(nearestSSL) or L.price > nearestSSL
                    nearestSSL := L.price
                    nearestSSLIndex := i
                    nearestSSLVol := L.vol

if array.size(liqs) > 0
    for i = 0 to array.size(liqs) - 1
        Liq L = array.get(liqs, i)

        bool isNearest = i_highlightNearest and (i == nearestBSLIndex or i == nearestSSLIndex)
        color baseCol = L.isHigh ? i_colBSL : i_colSSL
        color activeCol = isNearest ? baseCol : i_dimFarLevels ? color.new(baseCol, i_farTransp) : baseCol

        if not L.swept
            line.set_color(L.ln, activeCol)
            line.set_width(L.ln, isNearest ? i_nearestWidth : i_lineWidth)
            line.set_style(L.ln, isNearest ? line.style_solid : f_lstyle())
            label.set_textcolor(L.lb, activeCol)
            label.set_text(L.lb, f_levelText(L.isHigh, L.price, L.vol, L.grade, isNearest))
            label.set_x(L.lb, bar_index)


// =============================================================================
//  VOLUME PROFILE  POC / VAH / VAL + LIQUIDITY VOIDS
// =============================================================================

var array<box> profBoxes = array.new<box>()
var array<box> voidBoxes = array.new<box>()

var line  pocLn = na
var line  vahLn = na
var line  valLn = na

var label pocLb = na
var label vahLb = na
var label valLb = na

var float pocPrice = na
var float vahPrice = na
var float valPrice = na

if barstate.islast and i_showProfile
    for b in profBoxes
        box.delete(b)

    for b in voidBoxes
        box.delete(b)

    array.clear(profBoxes)
    array.clear(voidBoxes)

    line.delete(pocLn)
    line.delete(vahLn)
    line.delete(valLn)

    label.delete(pocLb)
    label.delete(vahLb)
    label.delete(valLb)

    int   bins     = i_profBins
    float rHi      = ta.highest(high, i_profLookback)
    float rLo      = ta.lowest(low,   i_profLookback)
    float rRange   = rHi - rLo
    int   startBar = math.max(0, bar_index - i_profLookback + 1)
    int   baseX    = bar_index + i_profGap

    if rRange > 0
        float binSize = rRange / bins
        float[] binVol = array.new_float(bins, 0.0)

        for i = 0 to i_profLookback - 1
            float bHi = high[i]
            float bLo = low[i]
            float bV  = nz(volume[i])

            if not (bHi < rLo or bLo > rHi)
                float cHi = math.min(bHi, rHi)
                float cLo = math.max(bLo, rLo)
                float span = cHi - cLo

                if span > 0
                    int b0 = int(math.max(0,        math.floor((cLo - rLo) / binSize)))
                    int b1 = int(math.min(bins - 1, math.floor((cHi - rLo) / binSize)))

                    for b = b0 to b1
                        float binLo  = rLo + b * binSize
                        float binHi  = binLo + binSize
                        float overlap = math.min(cHi, binHi) - math.max(cLo, binLo)
                        float portion = overlap / span
                        array.set(binVol, b, array.get(binVol, b) + bV * portion)

        float pocVol  = 0.0
        int   pocBin  = 0
        float totalV  = 0.0

        for b = 0 to bins - 1
            float v = array.get(binVol, b)
            totalV += v

            if v > pocVol
                pocVol := v
                pocBin := b

        float vaTarget = totalV * (i_vaPct / 100.0)
        float vaVol    = array.get(binVol, pocBin)
        int   vaLow    = pocBin
        int   vaHigh   = pocBin

        while vaVol < vaTarget
            float upV = vaHigh < bins - 1 ? array.get(binVol, vaHigh + 1) : -1.0
            float dnV = vaLow  > 0        ? array.get(binVol, vaLow  - 1) : -1.0

            if upV < 0 and dnV < 0
                break

            if upV >= dnV
                vaHigh += 1
                vaVol  += upV
            else
                vaLow  -= 1
                vaVol  += dnV

        pocPrice := rLo + (pocBin + 0.5) * binSize
        vahPrice := rLo + (vaHigh + 1)  * binSize
        valPrice := rLo + vaLow         * binSize

        float voidThresh = pocVol * i_lvnPct / 100.0

        color pocBoxColor   = color.new(i_colPOC, i_pocBoxTransp)
        color vaBoxColor    = color.new(i_colVA, i_vaBoxTransp)
        color otherBoxColor = color.new(i_colVA, i_otherBoxTransp)
        color voidBoxColor  = color.new(i_colVoid, i_voidBoxTransp)

        for b = 0 to bins - 1
            float v     = array.get(binVol, b)
            float binLo = rLo + b * binSize
            float binHi = binLo + binSize
            int   len   = pocVol > 0 ? int(math.round(v / pocVol * i_profMaxLen)) : 0
            bool  isVoid = v <= voidThresh and b != pocBin
            bool  inVA   = b >= vaLow and b <= vaHigh

            color barCol = b == pocBin ? pocBoxColor :
                 isVoid ? voidBoxColor :
                 inVA ? vaBoxColor :
                 otherBoxColor

            if len > 0
                array.push(profBoxes, box.new(baseX, binHi, baseX + len, binLo, border_color = na, bgcolor = barCol))

        if i_showPOC
            pocLn := line.new(startBar, pocPrice, baseX, pocPrice, color = i_colPOC, width = i_pocLineWidth)
            vahLn := line.new(startBar, vahPrice, baseX, vahPrice, color = color.new(i_colVA, 10), width = 1, style = line.style_dotted)
            valLn := line.new(startBar, valPrice, baseX, valPrice, color = color.new(i_colVA, 10), width = 1, style = line.style_dotted)

            pocLb := label.new(baseX, pocPrice, "POC " + str.tostring(pocPrice, format.mintick),
                 style = label.style_label_left, color = color.new(color.black, 100), textcolor = i_colPOC, size = size.small)

            vahLb := label.new(baseX, vahPrice, "VAH " + str.tostring(vahPrice, format.mintick),
                 style = label.style_label_left, color = color.new(color.black, 100), textcolor = i_colVA, size = size.tiny)

            valLb := label.new(baseX, valPrice, "VAL " + str.tostring(valPrice, format.mintick),
                 style = label.style_label_left, color = color.new(color.black, 100), textcolor = i_colVA, size = size.tiny)

        if i_showVoids
            int runStart = -1

            for b = 0 to bins - 1
                bool isVoid = array.get(binVol, b) <= voidThresh and b != pocBin

                if isVoid and runStart == -1
                    runStart := b

                if (not isVoid or b == bins - 1) and runStart != -1
                    int runEnd = isVoid ? b : b - 1
                    float zLo = rLo + runStart * binSize
                    float zHi = rLo + (runEnd + 1) * binSize

                    array.push(voidBoxes, box.new(startBar, zHi, baseX, zLo, border_color = na, bgcolor = color.new(i_colVoid, i_voidBoxTransp)))
                    runStart := -1


// =============================================================================
//  SMART DASHBOARD TEXT LOGIC
// =============================================================================

bool profileReady = not na(vahPrice) and not na(valPrice) and not na(pocPrice)
bool inVa = profileReady and close <= vahPrice and close >= valPrice
bool aboveVa = profileReady and close > vahPrice
bool belowVa = profileReady and close < valPrice

string locationText = not profileReady ? "Profile loading" :
     inVa ? "Inside Value Area" :
     aboveVa ? "Above Value Area" :
     belowVa ? "Below Value Area" :
     "Outside Value Area"

color locationColor = not profileReady ? color.gray :
     inVa ? i_colBull :
     aboveVa ? i_colBSL :
     belowVa ? i_colSSL :
     i_colVoid

string nearestUpText = na(nearestBSL) ? "-" : str.tostring(nearestBSL, format.mintick) + "  " + f_fmt(nearestBSLVol)
string nearestDnText = na(nearestSSL) ? "-" : str.tostring(nearestSSL, format.mintick) + "  " + f_fmt(nearestSSLVol)

bool hasBSL = not na(nearestBSL)
bool hasSSL = not na(nearestSSL)

string focusText =
     not profileReady ? "Wait for profile" :
     inVa ? "Watch POC / VA reaction" :
     aboveVa and hasBSL ? "Watch BSL reaction" :
     aboveVa and not hasBSL ? "No BSL above - watch VAH" :
     belowVa and hasSSL ? "Watch SSL reaction" :
     belowVa and not hasSSL ? "No SSL below - watch VAL" :
     pressure > 0 and hasBSL ? "Watch BSL reaction" :
     pressure < 0 and hasSSL ? "Watch SSL reaction" :
     "Wait for clear liquidity"

color focusColor =
     inVa ? i_colPOC :
     str.contains(focusText, "BSL") ? i_colBSL :
     str.contains(focusText, "SSL") ? i_colSSL :
     str.contains(focusText, "VAH") or str.contains(focusText, "VAL") ? i_colVA :
     color.gray


// =============================================================================
//  DASHBOARD
// =============================================================================

var table dash = na

if i_showDash and barstate.islast
    if na(dash)
        dash := table.new(f_pos(i_dashPos), 2, 10, border_width = 1, border_color = color.new(color.gray, 50))

    bool   smoothedBull = pressure > 0
    color  biasC  = smoothedBull ? i_colBull : i_colBear
    string biasT  = smoothedBull ? "BULLISH" : "BEARISH"
    string srcT   = deltaAvail ? "Intrabar" : "Proxy"
    string sweepAgo = na(lastSweepBar) ? "-" : lastSweepTxt + "  (" + str.tostring(bar_index - lastSweepBar) + " bars ago)"
    string sz = i_dashSize

    table.cell(dash, 0, 0, "LIQUIDITY VOLUME MATRIX", text_color = color.white, bgcolor = color.new(#1e1e2e, 0), text_size = f_size(sz), text_halign = text.align_left)
    table.cell(dash, 1, 0, "LVM", text_color = color.new(color.white, 30), bgcolor = color.new(#1e1e2e, 0), text_size = f_size(sz))

    table.cell(dash, 0, 1, "Smoothed Pressure", text_color = color.gray, text_size = f_size(sz), text_halign = text.align_left)
    table.cell(dash, 1, 1, biasT, text_color = color.white, bgcolor = color.new(biasC, 30), text_size = f_size(sz))

    table.cell(dash, 0, 2, "Current Bar Net Vol", text_color = color.gray, text_size = f_size(sz), text_halign = text.align_left)
    table.cell(dash, 1, 2, f_fmt(netVol) + "  (" + srcT + ")", text_color = netVol >= 0 ? i_colBull : i_colBear, text_size = f_size(sz))

    table.cell(dash, 0, 3, "Nearest BSL Above", text_color = color.gray, text_size = f_size(sz), text_halign = text.align_left)
    table.cell(dash, 1, 3, nearestUpText, text_color = hasBSL ? i_colBSL : color.gray, text_size = f_size(sz))

    table.cell(dash, 0, 4, "Nearest SSL Below", text_color = color.gray, text_size = f_size(sz), text_halign = text.align_left)
    table.cell(dash, 1, 4, nearestDnText, text_color = hasSSL ? i_colSSL : color.gray, text_size = f_size(sz))

    table.cell(dash, 0, 5, "POC", text_color = color.gray, text_size = f_size(sz), text_halign = text.align_left)
    table.cell(dash, 1, 5, na(pocPrice) ? "-" : str.tostring(pocPrice, format.mintick), text_color = i_colPOC, text_size = f_size(sz))

    table.cell(dash, 0, 6, "Value Area", text_color = color.gray, text_size = f_size(sz), text_halign = text.align_left)
    table.cell(dash, 1, 6, profileReady ? str.tostring(valPrice, format.mintick) + " - " + str.tostring(vahPrice, format.mintick) : "-", text_color = i_colVA, text_size = f_size(sz))

    table.cell(dash, 0, 7, "Current Zone", text_color = color.gray, text_size = f_size(sz), text_halign = text.align_left)
    table.cell(dash, 1, 7, locationText, text_color = locationColor, text_size = f_size(sz))

    table.cell(dash, 0, 8, "Last Sweep", text_color = color.gray, text_size = f_size(sz), text_halign = text.align_left)
    table.cell(dash, 1, 8, sweepAgo, text_color = color.gray, text_size = f_size(sz))

    table.cell(dash, 0, 9, "Main Focus", text_color = color.gray, text_size = f_size(sz), text_halign = text.align_left)
    table.cell(dash, 1, 9, focusText, text_color = focusColor, text_size = f_size(sz))


// =============================================================================
//  NO-VOLUME WARNING
// =============================================================================

var float cumVol = 0.0
cumVol += nz(volume)

var table warn = na

if barstate.islast and cumVol == 0
    if na(warn)
        warn := table.new(position.middle_center, 1, 1, bgcolor = #ff0000)

    table.cell(warn, 0, 0, "  NO VOLUME DATA  \n  Liquidity Volume Matrix needs a symbol that reports volume.  ",
         text_color = color.white, text_size = size.large, bgcolor = #ff0000)
else
    if not na(warn)
        table.delete(warn)
        warn := na


// =============================================================================
//  ALERTS
// =============================================================================

alertcondition(bullSweepEvent, "Confirmed SSL Sweep", "LVM: Confirmed SSL sweep - Sell-Side Liquidity swept and next bar confirmed")
alertcondition(bearSweepEvent, "Confirmed BSL Sweep", "LVM: Confirmed BSL sweep - Buy-Side Liquidity swept and next bar confirmed")
alertcondition(bullSweepEvent or bearSweepEvent, "Any Confirmed Liquidity Sweep", "LVM: Confirmed liquidity sweep detected")
alertcondition(not na(ph), "New Buy-Side Liquidity", "LVM: New Buy-Side Liquidity pool formed")
alertcondition(not na(pl), "New Sell-Side Liquidity", "LVM: New Sell-Side Liquidity pool formed")

// end of Liquidity Volume Matrix
````
