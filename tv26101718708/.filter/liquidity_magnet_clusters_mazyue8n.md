# Liquidity Magnet Clusters

- url: https://www.tradingview.com/script/MAzyue8N-Liquidity-Magnet-Clusters/
- type: indicator
- pine_id: PUB;c36c80aa25fb4230a97d11c74f69720a
- version: 1.0

## Description

[b]Liquidity Magnet Clusters[/b]

Liquidity Magnet Pro is an educational liquidity-mapping indicator designed to help traders study where price may interact with prior volume concentration, untested Point of Control levels, value-area boundaries, and sweep-based liquidity events.

This script is not a trading strategy and does not place or simulate orders. It does not provide backtested performance results, win-rate claims, profitability claims, or financial advice. Its purpose is to organize liquidity-related information directly on the chart so traders can use it as a research and decision-support tool alongside their own market structure, risk management, and testing process.

What the script does

[b]The indicator combines five main analytical components:[/b]

1. [b]Rolling Volume Profile[/b]

The script builds an internal rolling volume profile from recent bars. It divides the selected lookback range into price bins and distributes each bar’s volume across the bins touched by that bar. From this profile, it identifies:

- POC: the price bin with the highest accumulated volume.
- VAH: the upper boundary of the selected value area.
- VAL: the lower boundary of the selected value area.
- HVN zones: high-volume areas that may represent prior acceptance or liquidity concentration.
- LVN zones: low-volume areas that may represent thinner auction areas or faster price traversal zones.

This profile is calculated inside Pine Script and does not rely on an external volume-profile feed.

2. [b]Naked POC Tracker[/b]

The script snapshots the rolling POC from a selected anchor timeframe, such as 4H, Daily, Weekly, or Monthly. These historical POC levels remain active until price tests them or until they expire based on the selected maximum age.

The purpose of the Naked POC tracker is to highlight untested prior POC levels that may act as reference levels for future market interaction. To reduce chart clutter, the script can merge nearby Naked POCs into visible cluster zones instead of drawing every individual level.

3. [b]Liquidity Sweep Detection[/b]

The script detects potential liquidity sweeps using recent swing highs and swing lows. A bearish sweep is detected when price moves above a prior swing high and then closes back below it. A bullish sweep is detected when price moves below a prior swing low and then closes back above it.

An optional above-median volume filter can be used to reduce low-conviction sweep signals.

4. [b]A-Grade Confluence Engine[/b]

The A-Grade label is a confluence marker, not a buy or sell command. It appears only when a detected sweep also aligns with nearby liquidity geography.

[b]The confluence score can include:[/b]

- Sweep near VAH or VAL.
- Sweep near an HVN zone.
- Sweep near an active Naked POC.
- Movement through an LVN zone.

The script uses a 0–5 scoring model. When the score reaches the selected A-Grade threshold, the script displays an A marker on the chart. A higher threshold generally produces fewer but more selective signals, while a lower threshold produces more frequent signals.

[b]5. Liquidity Dashboard[/b]

The dashboard summarizes the current liquidity context, including:

- Current anchor timeframe.
- Current POC, VAH, and VAL.
- Distance from price to profile levels.
- Value-area bias.
- Number of active Naked POCs above and below price.
- Last sweep direction and age.
- Current HVN and LVN zone count.

How to use it

This indicator is intended to be used as a chart-reading and setup-discovery tool.

[b]A practical workflow is:[/b]

1. Identify the current value-area context using POC, VAH, and VAL.
2. Observe whether price is trading inside value, above value, or below value.
3. Watch for untested Naked POC levels or clusters above and below current price.
4. Use sweep markers to identify possible stop-run or liquidity-grab events around recent swing highs or lows.
5. Treat A-Grade labels as areas requiring further analysis, not automatic entries.
6. Confirm any setup with your own market structure, execution rules, invalidation level, risk model, and out-of-sample testing.

[b]Originality and usefulness[/b]

This script is designed as a liquidity-confluence framework rather than a simple signal overlay. Its purpose is to combine rolling volume-profile context, untested POC tracking, sweep detection, and a transparent scoring model into one chart-based workflow.

[b]The components are intended to work together as follows:[/b]

- The rolling profile defines the current auction structure.
- Naked POCs identify prior untested high-volume reference levels.
- HVN and LVN zones provide context for acceptance and thin-volume areas.
- Sweep detection identifies possible liquidity events around recent swing points.
- The A-Grade score only appears when a sweep occurs near meaningful liquidity context.

This combination is intended to help traders evaluate where liquidity events occur in relation to volume-profile structure, rather than viewing sweeps or POC levels in isolation.

[b]Important limitations[/b]

This indicator does not predict future price movement.

A Naked POC, HVN, LVN, VAH, VAL, sweep marker, or A-Grade label does not guarantee continuation, reversal, support, resistance, or profitability.

Volume-profile calculations in Pine Script are approximations based on available chart bars and the script’s selected binning method. Results may differ from exchange-native or platform-native volume-profile tools.

[b]Signals and levels can vary depending on:[/b]

- Symbol.
- Timeframe.
- Market session.
- Available historical bars.
- Volume quality.
- Profile lookback length.
- Number of bins.
- Anchor timeframe.
- Sweep pivot length.
- Confluence threshold.

Traders should test the indicator across multiple symbols, timeframes, and market conditions before using it in any decision-making process.

[b]Main settings[/b]

[b]Volume Profile Engine[/b]

- Rolling Profile Lookback: controls how many bars are used to build the rolling volume profile.
- Profile Bins: controls the profile resolution.
- Value Area %: defines how much volume is included in the value area.
- HVN Percentile Threshold: controls which volume bins are classified as high-volume nodes.
- LVN Percentile Threshold: controls which volume bins are classified as low-volume nodes.

[b]Naked POC Tracker[/b]

- Anchor Timeframe: defines the higher timeframe used to snapshot prior POC levels.
- Max Naked POC Age: controls how long untested Naked POCs remain active.
- Max Tracked Naked POCs: limits stored levels to protect object limits.
- Consumption Rule: determines whether a Naked POC is considered tested by a wick touch or by a close through the level.
- Cluster Mode: merges nearby Naked POCs into cleaner zones.

[b]Liquidity Sweeps[/b]

- Swing Pivot Length: controls the swing-high and swing-low structure used for sweep detection.
- Liquidity Pool Lookback: limits how old a swing level can be and still qualify as sweepable liquidity.
- Require Above-Median Volume: filters sweep signals using a volume condition.

[b]Confluence Engine[/b]

- Level Proximity: defines how close a sweep must be to a liquidity level to count as confluence.
- A-Grade Threshold: sets the minimum score required to display an A-Grade label.

[b]Dashboard[/b]

- Dashboard Position: controls panel location.
- Dashboard Text Size: controls panel readability.
- Dashboard Theme: provides light or dark panel options.
- Dashboard Accent: controls dashboard accent color.

[b]Alerts[/b]

The script includes alert conditions for:

- Bearish Sweep.
- Bullish Sweep.
- A-Grade Short.
- A-Grade Long.
- Value Area Break Up.
- Value Area Break Down.
- Naked POC Tested.

These alerts are informational and should not be interpreted as automatic trade instructions.

[b]Recommended use
[/b]
This indicator is best used by traders who understand auction-market concepts, volume-profile reference levels, swing liquidity, and discretionary confirmation. It is designed to support analysis, not replace a complete trading plan.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ADXAE

//@version=6
// =============================================================================
//  LIQUIDITY MAGNET Cluster
// =============================================================================
//
//  A liquidity-first indicator that fuses Volume Profile mechanics with naked-
//  POC tracking and stop-hunt detection into a single, scoreable confluence
//  engine. Built entirely in Pine v6 — no external Volume Profile feed needed.
//
//  ① ROLLING VOLUME PROFILE  → POC / VAH / VAL / HVN / LVN
//  ② NAKED POC TRACKER       → snapshots prior-period POCs until tested
//  ③ LIQUIDITY SWEEP         → fractal stop-hunt detection + volume filter
//  ④ CONFLUENCE SCORE (0–5)  → sweep + (VA edge / HVN / nPOC / LVN traversal)
//  ⑤ LIQUIDITY DASHBOARD     → live POC distances, naked counts, VA bias
//
//  SETUP-DISCOVERY tool — combine with structure, risk, out-of-sample testing.
// =============================================================================

indicator("Liquidity Magnet Clusters",
     shorttitle       = "LMC",
     overlay          = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)


// ═══════════════════════════════════════════════════════════════════════════
//  ① PROFILE ENGINE
// ═══════════════════════════════════════════════════════════════════════════
grpProfile = "① Volume Profile Engine"

showProfile = input.bool(true, "Enable Volume Profile",
     group   = grpProfile,
     tooltip = "Master switch for the entire profile layer: POC, VAH/VAL, HVN/LVN zones. Disable to declutter the chart and keep only naked POCs + sweeps.")

profileLen = input.int(200, "Rolling Profile Lookback (bars)",
     minval  = 50, maxval = 1500,
     group   = grpProfile,
     tooltip = "How many bars to include in the rolling volume profile. 200 (default) gives a stable, slow-moving profile useful on swing timeframes. Lower values (50–100) make the profile reactive and intraday-friendly; higher values (500+) suit weekly/monthly context but cost more compute.",
     active  = showProfile)

profileBins = input.int(60, "Profile Bins (resolution)",
     minval  = 20, maxval = 150,
     group   = grpProfile,
     tooltip = "Number of price buckets used to construct the profile. Higher = finer POC localisation but slower compute. 60 is a balanced default; raise toward 100–120 only when you have tight ranges and need precision.",
     active  = showProfile)

vaPercent = input.float(70.0, "Value Area %",
     minval  = 50.0, maxval = 95.0, step = 1.0,
     group   = grpProfile,
     tooltip = "Percentage of total volume that defines the Value Area around the POC. Standard auction-theory default is 70%. Lowering to 60% gives a tighter VA (the 'thick' middle); raising to 80% widens it.",
     active  = showProfile)

hvnPctile = input.float(80.0, "HVN Percentile Threshold",
     minval  = 60.0, maxval = 99.0, step = 1.0,
     group   = grpProfile,
     tooltip = "Bins whose volume is above this percentile of all bins are flagged as High Volume Nodes — acceptance / liquidity zones that act as magnets and supports/resistances.",
     active  = showProfile)

lvnPctile = input.float(20.0, "LVN Percentile Threshold",
     minval  = 1.0, maxval = 40.0, step = 1.0,
     group   = grpProfile,
     tooltip = "Bins whose volume is below this percentile are flagged as Low Volume Nodes — rejection rails. Price tends to move FAST through LVNs because there's little prior trade to slow it down.",
     active  = showProfile)


// ═══════════════════════════════════════════════════════════════════════════
//  ② NAKED POC TRACKER
// ═══════════════════════════════════════════════════════════════════════════
grpNaked = "② Naked POC Tracker"

showNaked = input.bool(true, "Enable Naked POC Tracker",
     group   = grpNaked,
     tooltip = "Snapshots the POC of each completed anchor period and tracks it until price trades through. Untested naked POCs are statistically strong magnets — historically among the highest-probability magnetic levels in auction-theory trading.")

anchorTF = input.timeframe("D", "Anchor Timeframe",
     options = ["60", "240", "D", "W", "M"],
     group   = grpNaked,
     tooltip = "Higher timeframe that defines one 'period' for naked-POC snapshots. D = daily naked POCs (most common). W = weekly. 240 = 4-hour. Choose an anchor at least one step higher than your chart timeframe.",
     active  = showNaked)

maxNakedAge = input.int(20, "Max Naked POC Age (anchor periods)",
     minval  = 5, maxval = 500,
     group   = grpNaked,
     tooltip = "Naked POCs older than this many completed anchor periods are dropped automatically. This version counts true anchor periods, not profileLen x age, so 20 on Daily really means about 20 daily anchor periods.",
     active  = showNaked)

maxVisibleNakedSide = input.int(10, "Max Visible Naked POCs per side",
     minval  = 0, maxval = 50,
     group   = grpNaked,
     tooltip = "Used when cluster mode is OFF. Limits chart clutter by showing only the closest Naked POC levels above price and the closest levels below price. Hidden levels remain tracked internally for dashboard counts and confluence scoring.",
     active  = showNaked)

showNakedClusters = input.bool(true, "Show Naked POC Clusters",
     group   = grpNaked,
     tooltip = "When enabled, nearby Naked POCs are merged into clean price zones instead of drawing many overlapping nPOC lines. This is the recommended visual mode.",
     active  = showNaked)

nPocClusterPct = input.float(0.25, "nPOC Cluster Merge Distance (% of price)",
     minval  = 0.05, maxval = 2.0, step = 0.05,
     group   = grpNaked,
     tooltip = "Maximum distance used to merge nearby Naked POCs into one cluster zone. Example: 0.25 means levels within about 0.25% of price are grouped together.",
     active  = showNaked and showNakedClusters)

maxVisibleNakedClustersSide = input.int(3, "Max Visible nPOC Clusters per side",
     minval  = 1, maxval = 10,
     group   = grpNaked,
     tooltip = "Shows only the closest cluster zones above price and below price. Raw Naked POC levels remain tracked internally for alerts and confluence scoring.",
     active  = showNaked and showNakedClusters)

maxTrackedNaked = input.int(200, "Max Tracked Naked POCs",
     minval  = 20, maxval = 500,
     group   = grpNaked,
     tooltip = "Hard cap for active Naked POC storage. If the number of active Naked POCs exceeds this limit, the oldest levels are deleted first to protect TradingView object limits.",
     active  = showNaked)

nakedConsumeMode = input.string("Wick Test", "Consumption Rule",
     options = ["Wick Test", "Close Through"],
     group   = grpNaked,
     tooltip = "Defines when a naked POC is considered tested.\n\n• Wick Test (default, strictest) — the FIRST bar whose [low, high] envelope contains the POC consumes it. Matches Sierra Chart / CME convention.\n• Close Through — only a CLOSE on the opposite side of the POC consumes it. Keeps levels alive longer; useful if you want only decisive tests to count.",
     active  = showNaked)


// ═══════════════════════════════════════════════════════════════════════════
//  ③ LIQUIDITY SWEEPS
// ═══════════════════════════════════════════════════════════════════════════
grpSweep = "③ Liquidity Sweeps"

showSweeps = input.bool(true, "Enable Sweep Detection",
     group   = grpSweep,
     tooltip = "Detect stop-hunt sweeps: a bar that wicks beyond a recent swing high/low (where stops cluster) and CLOSES back inside. Bearish sweep above swing high → triangledown above bar; bullish sweep below swing low → triangleup below bar.")

pivotLen = input.int(10, "Swing Pivot Length",
     minval  = 3, maxval = 50,
     group   = grpSweep,
     tooltip = "Fractal pivot lookback — a pivot high requires N bars lower-high to its left AND N bars lower-high to its right. Larger = fewer but more structural swings.",
     active  = showSweeps)

sweepLookback = input.int(60, "Liquidity Pool Lookback (bars)",
     minval  = 10, maxval = 300,
     group   = grpSweep,
     tooltip = "Maximum age (in bars) of a swing high/low to still count as a valid liquidity pool. Older pools are 'forgotten'. Should be comparable to or smaller than your profile lookback.",
     active  = showSweeps)

sweepVolFilter = input.bool(true, "Require Above-Median Volume",
     group   = grpSweep,
     tooltip = "Only register sweeps when the bar's volume exceeds the median volume of the lookback window. Filters out low-conviction wicks (especially useful on crypto, pre/post-market, and thin sessions).",
     active  = showSweeps)


// ═══════════════════════════════════════════════════════════════════════════
//  ④ CONFLUENCE SCORE
// ═══════════════════════════════════════════════════════════════════════════
grpConf = "④ Confluence Engine"

showConfluence = input.bool(true, "Enable A-Grade Signals",
     group   = grpConf,
     tooltip = "Score each detected sweep against the surrounding liquidity geography. Signals are only plotted when the score meets the A-Grade threshold below.")

proximityPct = input.float(0.4, "Level Proximity (% of price)",
     minval  = 0.05, maxval = 3.0, step = 0.05,
     group   = grpConf,
     tooltip = "How close (as % of current price) a sweep must be to a level (HVN edge / VAH / VAL / naked POC) to count it as confluence. Tighter = stricter signals; looser = more signals.",
     active  = showConfluence)

aGradeThresh = input.int(3, "A-Grade Threshold (score ≥)",
     minval  = 1, maxval = 5,
     group   = grpConf,
     tooltip = "Minimum confluence score required to print an A-Grade signal. Maximum score is 5. Default 3 is balanced; raise to 4 for higher-quality / lower-frequency setups.",
     active  = showConfluence)


// ═══════════════════════════════════════════════════════════════════════════
//  ⑤ VISUAL STYLE
// ═══════════════════════════════════════════════════════════════════════════
grpStyle = "⑤ Visual Style"

colPOC      = input.color(color.new(#FFD600, 0),  "POC line color",        group = grpStyle, tooltip = "Color for the current rolling POC line.")
colVA       = input.color(color.new(#B0BEC5, 0),  "VAH / VAL line color",  group = grpStyle, tooltip = "Color for the Value Area High and Low lines.")
colVAFill   = input.color(color.new(#B0BEC5, 88), "Value Area fill",       group = grpStyle, tooltip = "Semi-transparent fill between VAH and VAL.")
colHVN      = input.color(color.new(#26A69A, 75), "HVN zone color",        group = grpStyle, tooltip = "Color for High Volume Node zones (acceptance / magnets).")
colLVN      = input.color(color.new(#EF5350, 80), "LVN zone color",        group = grpStyle, tooltip = "Color for Low Volume Node zones (rejection rails).")
colNakedUp  = input.color(color.new(#FF6F00, 0),  "Naked POC (above)",     group = grpStyle, tooltip = "Color for naked POCs currently above price.")
colNakedDn  = input.color(color.new(#9C27B0, 0),  "Naked POC (below)",     group = grpStyle, tooltip = "Color for naked POCs currently below price.")
colSweepDn  = input.color(color.new(#F44336, 0),  "Bearish sweep color",   group = grpStyle, tooltip = "Color for sell-side liquidity sweeps (wick above swing high, close back inside).")
colSweepUp  = input.color(color.new(#4CAF50, 0),  "Bullish sweep color",   group = grpStyle, tooltip = "Color for buy-side liquidity sweeps (wick below swing low, close back inside).")
colAGrade   = input.color(color.new(#FFD600, 0),  "A-Grade signal color",  group = grpStyle, tooltip = "Color of the A-Grade confluence-signal marker (star above/below the bar).")

lineWidthMain = input.int(2, "Main line width", minval = 1, maxval = 4, group = grpStyle, tooltip = "Line width for POC, VAH, VAL.")
extendRight   = input.bool(true, "Extend levels to right edge", group = grpStyle, tooltip = "If on, POC / VAH / VAL / naked-POC lines extend to the right edge of the chart.")


// ═══════════════════════════════════════════════════════════════════════════
//  ⑥ DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
grpDash = "⑥ Liquidity Dashboard"

showDash = input.bool(true, "Show Dashboard",
     group   = grpDash,
     tooltip = "Top-right info panel: anchor TF, POC/VAH/VAL prices, % distance to each, naked-POC counts above & below price, last sweep age & side using correct buy-side/sell-side terminology, current value-area bias.")

dashPos = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"],
     group   = grpDash, active = showDash,
     tooltip = "Where to anchor the dashboard table on the chart.")

dashSize = input.string("Small", "Dashboard Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group   = grpDash, active = showDash,
     tooltip = "Text size inside the dashboard table.")

dashTheme = input.string("Universal Light Panel", "Dashboard Theme",
     options = ["Universal Light Panel", "Dark Panel"],
     group   = grpDash, active = showDash,
     tooltip = "Universal Light Panel uses its own light dashboard background, so the table remains readable on both white and black charts. Dark Panel uses a dark dashboard background with light text.")

dashAccentMode = input.string("Soft Blue", "Dashboard Accent",
     options = ["Soft Blue", "Soft Teal", "Muted Amber"],
     group   = grpDash, active = showDash,
     tooltip = "Accent color used only inside the dashboard POC row. The dashboard title now uses a neutral readable text color.")


// ═══════════════════════════════════════════════════════════════════════════
//  STATE & HELPERS
// ═══════════════════════════════════════════════════════════════════════════

var array<float> nPocLevels = array.new<float>(0)
var array<int>   nPocBars   = array.new<int>(0)
var array<int>   nPocAnchorIds = array.new<int>(0)
var array<line>  nPocLines  = array.new<line>(0)
var array<label> nPocLabels = array.new<label>(0)
var array<box>   nPocClusterBoxes  = array.new<box>(0)
var array<label> nPocClusterLabels = array.new<label>(0)
var int nPocShownAbove = 0
var int nPocShownBelow = 0

var line   pocLine   = na
var line   vahLine   = na
var line   valLine   = na
var linefill vaFill  = na

var array<box> hvnBoxes = array.new<box>(0)
var array<box> lvnBoxes = array.new<box>(0)

var float lastSwingHi    = na
var float lastSwingLo    = na
var int   lastSwingHiBar = na
var int   lastSwingLoBar = na
var int   lastSweepBar   = na
var int   lastSweepDir   = 0

var float curPOC = na
var float curVAH = na
var float curVAL = na
var array<float> curHvnLow  = array.new<float>(0)
var array<float> curHvnHigh = array.new<float>(0)
var array<float> curLvnLow  = array.new<float>(0)
var array<float> curLvnHigh = array.new<float>(0)

var int anchorCounter = 0


dashTxtSize = dashSize == "Tiny"   ? size.tiny   :
              dashSize == "Small"  ? size.small  :
              dashSize == "Normal" ? size.normal : size.large

dashPosition = dashPos == "Top Right"     ? position.top_right    :
               dashPos == "Top Left"      ? position.top_left     :
               dashPos == "Bottom Right"  ? position.bottom_right :
               dashPos == "Bottom Left"   ? position.bottom_left  : position.middle_right

// Dashboard palette: the panel has its own background, so it stays readable on both white and black charts.
bool dashDark = dashTheme == "Dark Panel"
color dashBg        = dashDark ? color.new(#07111F, 0)  : color.new(#F8FAFC, 0)
color dashHeaderBg  = dashDark ? color.new(#0F1B2D, 0)  : color.new(#DDE7F2, 0)
color dashCellBg    = dashDark ? color.new(#111C2E, 0)  : color.new(#F3F7FB, 0)
color dashAltBg     = dashDark ? color.new(#17243A, 0)  : color.new(#E7EEF6, 0)

// Text and border colors used only inside the dashboard.
// Universal Light Panel uses dark-slate text on a light panel; it remains readable even on black charts because the table background is opaque.
// Dark Panel uses light text on a dark panel.
color dashTitleTxt  = dashDark ? color.new(#E2E8F0, 0)  : color.new(#243447, 0)
color dashLabelTxt  = dashDark ? color.new(#D7DEE8, 0)  : color.new(#334155, 0)
color dashValueTxt  = dashDark ? color.new(#F8FAFC, 0)  : color.new(#0F172A, 0)
color dashMutedTxt  = dashDark ? color.new(#AAB7C8, 0)  : color.new(#5F6F85, 0)
color dashBorderCol = dashDark ? color.new(#70839E, 0)  : color.new(#9AAEC8, 0)

// Softer semantic text colors for dashboard labels/values. They are intentionally less saturated than chart colors.
color dashAccentCol = dashAccentMode == "Soft Teal" ? (dashDark ? color.new(#5EEAD4, 0) : color.new(#0F766E, 0)) :
                      dashAccentMode == "Muted Amber" ? (dashDark ? color.new(#FCD34D, 0) : color.new(#92400E, 0)) :
                      dashDark ? color.new(#93C5FD, 0) : color.new(#1D4ED8, 0)
color dashNakedUpTxt  = dashDark ? color.new(#FDBA74, 0) : color.new(#C2410C, 0)
color dashNakedDnTxt  = dashDark ? color.new(#D8B4FE, 0) : color.new(#7E22CE, 0)
color dashBullTxt     = dashDark ? color.new(#86EFAC, 0) : color.new(#047857, 0)
color dashBearTxt     = dashDark ? color.new(#FCA5A5, 0) : color.new(#B91C1C, 0)
color dashHvnTxt      = dashDark ? color.new(#5EEAD4, 0) : color.new(#0F766E, 0)
color dashLvnTxt      = dashDark ? color.new(#FCA5A5, 0) : color.new(#B91C1C, 0)
color dashBuySideCol  = dashBearTxt  // Buy-side liquidity swept above a prior high; bearish rejection context.
color dashSellSideCol = dashBullTxt  // Sell-side liquidity swept below a prior low; bullish rejection context.


distPct(float a, float b) =>
    b == 0 or na(a) or na(b) ? na : (a - b) / b * 100.0

nearLevel(float price, float level, float pct) =>
    na(level) or na(price) ? false : math.abs(price - level) / price * 100.0 <= pct


// ═══════════════════════════════════════════════════════════════════════════
//  ROLLING VOLUME PROFILE — computed each bar
// ═══════════════════════════════════════════════════════════════════════════

if showProfile and bar_index >= profileLen

    float pHi = high
    float pLo = low
    for i = 1 to profileLen - 1
        if high[i] > pHi
            pHi := high[i]
        if low[i] < pLo
            pLo := low[i]

    float binSize = (pHi - pLo) / profileBins

    if binSize > 0

        bins = array.new<float>(profileBins, 0.0)

        for i = 0 to profileLen - 1
            float bh = high[i]
            float bl = low[i]
            float bv = volume[i]
            if bh > bl and bv > 0
                int sBin = math.max(0, math.floor((bl - pLo) / binSize))
                int eBin = math.min(profileBins - 1, math.floor((bh - pLo) / binSize))
                int span = eBin - sBin + 1
                float perBin = bv / span
                for j = sBin to eBin
                    array.set(bins, j, array.get(bins, j) + perBin)

        int pocBin = 0
        float pocVol = 0.0
        for i = 0 to profileBins - 1
            v = array.get(bins, i)
            if v > pocVol
                pocVol := v
                pocBin := i

        float totalVol = 0.0
        for i = 0 to profileBins - 1
            totalVol += array.get(bins, i)

        float target = totalVol * vaPercent / 100.0
        float accum  = array.get(bins, pocBin)
        int vahBin   = pocBin
        int valBin   = pocBin

        while accum < target and (vahBin < profileBins - 1 or valBin > 0)
            float upTwo = 0.0
            float dnTwo = 0.0
            if vahBin + 1 <= profileBins - 1
                upTwo += array.get(bins, vahBin + 1)
            if vahBin + 2 <= profileBins - 1
                upTwo += array.get(bins, vahBin + 2)
            if valBin - 1 >= 0
                dnTwo += array.get(bins, valBin - 1)
            if valBin - 2 >= 0
                dnTwo += array.get(bins, valBin - 2)

            if upTwo >= dnTwo and vahBin < profileBins - 1
                vahBin += 1
                accum += array.get(bins, vahBin)
            else if valBin > 0
                valBin -= 1
                accum += array.get(bins, valBin)
            else if vahBin < profileBins - 1
                vahBin += 1
                accum += array.get(bins, vahBin)
            else
                break

        curPOC := pLo + (pocBin + 0.5) * binSize
        curVAH := pLo + (vahBin + 1) * binSize
        curVAL := pLo + valBin * binSize

        sorted = array.copy(bins)
        array.sort(sorted, order.ascending)
        float hvnT = array.get(sorted, math.min(profileBins - 1, math.floor(profileBins * hvnPctile / 100.0)))
        float lvnT = array.get(sorted, math.max(0, math.floor(profileBins * lvnPctile / 100.0)))

        array.clear(curHvnLow)
        array.clear(curHvnHigh)
        array.clear(curLvnLow)
        array.clear(curLvnHigh)

        int hvnStart = -1
        int lvnStart = -1
        for i = 0 to profileBins - 1
            float bv = array.get(bins, i)

            if bv >= hvnT
                if hvnStart == -1
                    hvnStart := i
            else
                if hvnStart != -1
                    array.push(curHvnLow,  pLo + hvnStart * binSize)
                    array.push(curHvnHigh, pLo + i * binSize)
                    hvnStart := -1

            if bv <= lvnT
                if lvnStart == -1
                    lvnStart := i
            else
                if lvnStart != -1
                    array.push(curLvnLow,  pLo + lvnStart * binSize)
                    array.push(curLvnHigh, pLo + i * binSize)
                    lvnStart := -1

        if hvnStart != -1
            array.push(curHvnLow,  pLo + hvnStart * binSize)
            array.push(curHvnHigh, pLo + profileBins * binSize)
        if lvnStart != -1
            array.push(curLvnLow,  pLo + lvnStart * binSize)
            array.push(curLvnHigh, pLo + profileBins * binSize)


// ═══════════════════════════════════════════════════════════════════════════
//  DRAW: rolling POC, VAH, VAL — updated on last bar
// ═══════════════════════════════════════════════════════════════════════════

if showProfile and barstate.islast and not na(curPOC)
    int xStart = bar_index - profileLen
    int xEnd   = extendRight ? bar_index + 50 : bar_index

    line.delete(pocLine)
    line.delete(vahLine)
    line.delete(valLine)
    linefill.delete(vaFill)

    pocLine := line.new(xStart, curPOC, xEnd, curPOC,
         color = colPOC, width = lineWidthMain, style = line.style_solid)
    vahLine := line.new(xStart, curVAH, xEnd, curVAH,
         color = colVA,  width = lineWidthMain, style = line.style_dashed)
    valLine := line.new(xStart, curVAL, xEnd, curVAL,
         color = colVA,  width = lineWidthMain, style = line.style_dashed)
    vaFill  := linefill.new(vahLine, valLine, color = colVAFill)

    var label lblPOC = na
    var label lblVAH = na
    var label lblVAL = na
    label.delete(lblPOC)
    label.delete(lblVAH)
    label.delete(lblVAL)
    lblPOC := label.new(xEnd, curPOC, "  POC  " + str.tostring(curPOC, format.mintick),
         color = color.new(color.black, 100), textcolor = colPOC,
         style = label.style_label_left, size = size.small)
    lblVAH := label.new(xEnd, curVAH, "  VAH  " + str.tostring(curVAH, format.mintick),
         color = color.new(color.black, 100), textcolor = colVA,
         style = label.style_label_left, size = size.small)
    lblVAL := label.new(xEnd, curVAL, "  VAL  " + str.tostring(curVAL, format.mintick),
         color = color.new(color.black, 100), textcolor = colVA,
         style = label.style_label_left, size = size.small)


// ═══════════════════════════════════════════════════════════════════════════
//  DRAW: HVN & LVN zone boxes (rebuilt on last bar)
// ═══════════════════════════════════════════════════════════════════════════

if showProfile and barstate.islast and array.size(curHvnLow) > 0
    if array.size(hvnBoxes) > 0
        for i = 0 to array.size(hvnBoxes) - 1
            box.delete(array.get(hvnBoxes, i))
        array.clear(hvnBoxes)
    if array.size(lvnBoxes) > 0
        for i = 0 to array.size(lvnBoxes) - 1
            box.delete(array.get(lvnBoxes, i))
        array.clear(lvnBoxes)

    int bxStart = bar_index - profileLen
    int bxEnd   = extendRight ? bar_index + 30 : bar_index

    for i = 0 to array.size(curHvnLow) - 1
        float zLo = array.get(curHvnLow, i)
        float zHi = array.get(curHvnHigh, i)
        b = box.new(bxStart, zHi, bxEnd, zLo,
             border_color = na, bgcolor = colHVN)
        array.push(hvnBoxes, b)

    for i = 0 to array.size(curLvnLow) - 1
        float zLo = array.get(curLvnLow, i)
        float zHi = array.get(curLvnHigh, i)
        b = box.new(bxStart, zHi, bxEnd, zLo,
             border_color = na, bgcolor = colLVN)
        array.push(lvnBoxes, b)


// ═══════════════════════════════════════════════════════════════════════════
//  NAKED POC TRACKING
// ═══════════════════════════════════════════════════════════════════════════

isNewAnchor = ta.change(time(anchorTF)) != 0

if isNewAnchor
    anchorCounter += 1

if showNaked and isNewAnchor and not na(curPOC) and bar_index > profileLen
    array.push(nPocLevels, curPOC)
    array.push(nPocBars,   bar_index)
    array.push(nPocAnchorIds, anchorCounter)

    color nCol = curPOC > close ? colNakedUp : colNakedDn
    line newLine = line.new(bar_index, curPOC, bar_index + 1, curPOC,
         color = nCol, width = 1, style = line.style_solid,
         extend = extendRight ? extend.right : extend.none)
    label newLbl = label.new(bar_index, curPOC, " nPOC ",
         color = color.new(color.black, 100), textcolor = nCol,
         style = label.style_label_left, size = size.tiny)
    array.push(nPocLines,  newLine)
    array.push(nPocLabels, newLbl)

    while array.size(nPocLevels) > maxTrackedNaked
        line.delete(array.get(nPocLines, 0))
        label.delete(array.get(nPocLabels, 0))
        array.remove(nPocLevels, 0)
        array.remove(nPocBars, 0)
        array.remove(nPocAnchorIds, 0)
        array.remove(nPocLines, 0)
        array.remove(nPocLabels, 0)


if showNaked and array.size(nPocLevels) > 0
    int i = array.size(nPocLevels) - 1
    while i >= 0
        float lvl = array.get(nPocLevels, i)
        int   snapBar = array.get(nPocBars, i)
        int   snapAnchor = array.get(nPocAnchorIds, i)
        bool  consumed = false

        if nakedConsumeMode == "Wick Test"
            consumed := low <= lvl and high >= lvl
        else
            consumed := bar_index > snapBar and ((close > lvl and close[1] < lvl) or (close < lvl and close[1] > lvl))

        bool aged = (anchorCounter - snapAnchor) > maxNakedAge

        if consumed or aged
            line.delete(array.get(nPocLines, i))
            label.delete(array.get(nPocLabels, i))
            array.remove(nPocLevels, i)
            array.remove(nPocBars,   i)
            array.remove(nPocAnchorIds, i)
            array.remove(nPocLines,  i)
            array.remove(nPocLabels, i)
        i -= 1


if showNaked and barstate.islast
    nPocShownAbove := 0
    nPocShownBelow := 0

    if array.size(nPocClusterBoxes) > 0
        for z = 0 to array.size(nPocClusterBoxes) - 1
            box.delete(array.get(nPocClusterBoxes, z))
        array.clear(nPocClusterBoxes)
    if array.size(nPocClusterLabels) > 0
        for z = 0 to array.size(nPocClusterLabels) - 1
            label.delete(array.get(nPocClusterLabels, z))
        array.clear(nPocClusterLabels)

    if array.size(nPocLevels) > 0
        if showNakedClusters
            // Hide raw nPOC lines and labels. They remain tracked internally.
            for k = 0 to array.size(nPocLevels) - 1
                float lvl = array.get(nPocLevels, k)
                color baseCol = lvl > close ? colNakedUp : colNakedDn
                line.set_color(array.get(nPocLines, k), color.new(baseCol, 100))
                label.set_textcolor(array.get(nPocLabels, k), color.new(baseCol, 100))

            float mergePad = close * nPocClusterPct / 100.0
            float minPad   = syminfo.mintick * 2.0
            float zonePad  = math.max(mergePad * 0.15, minPad)

            array<float> aboveLow   = array.new<float>(0)
            array<float> aboveHigh  = array.new<float>(0)
            array<int>   aboveCount = array.new<int>(0)
            array<int>   aboveStart = array.new<int>(0)

            array<float> belowLow   = array.new<float>(0)
            array<float> belowHigh  = array.new<float>(0)
            array<int>   belowCount = array.new<int>(0)
            array<int>   belowStart = array.new<int>(0)

            // Build cluster ranges. Nearby levels are merged into one zone.
            for k = 0 to array.size(nPocLevels) - 1
                float lvl = array.get(nPocLevels, k)
                int   sBar = array.get(nPocBars, k)
                bool  abovePrice = lvl > close
                bool  merged = false

                if abovePrice
                    if array.size(aboveLow) > 0
                        for c = 0 to array.size(aboveLow) - 1
                            float lo = array.get(aboveLow, c)
                            float hi = array.get(aboveHigh, c)
                            if lvl >= lo - mergePad and lvl <= hi + mergePad
                                array.set(aboveLow, c, math.min(lo, lvl))
                                array.set(aboveHigh, c, math.max(hi, lvl))
                                array.set(aboveCount, c, array.get(aboveCount, c) + 1)
                                array.set(aboveStart, c, math.min(array.get(aboveStart, c), sBar))
                                merged := true
                                break
                    if not merged
                        array.push(aboveLow, lvl)
                        array.push(aboveHigh, lvl)
                        array.push(aboveCount, 1)
                        array.push(aboveStart, sBar)
                else
                    if array.size(belowLow) > 0
                        for c = 0 to array.size(belowLow) - 1
                            float lo = array.get(belowLow, c)
                            float hi = array.get(belowHigh, c)
                            if lvl >= lo - mergePad and lvl <= hi + mergePad
                                array.set(belowLow, c, math.min(lo, lvl))
                                array.set(belowHigh, c, math.max(hi, lvl))
                                array.set(belowCount, c, array.get(belowCount, c) + 1)
                                array.set(belowStart, c, math.min(array.get(belowStart, c), sBar))
                                merged := true
                                break
                    if not merged
                        array.push(belowLow, lvl)
                        array.push(belowHigh, lvl)
                        array.push(belowCount, 1)
                        array.push(belowStart, sBar)

            int xEndCluster = extendRight ? bar_index + 60 : bar_index

            // Draw closest clusters above price.
            if array.size(aboveLow) > 0
                for c = 0 to array.size(aboveLow) - 1
                    float lo = array.get(aboveLow, c)
                    float hi = array.get(aboveHigh, c)
                    float distC = lo - close
                    int closer = 0
                    for d = 0 to array.size(aboveLow) - 1
                        if d != c
                            float otherDist = array.get(aboveLow, d) - close
                            if otherDist < distC
                                closer += 1
                    if closer < maxVisibleNakedClustersSide
                        float zLo = lo == hi ? lo - zonePad : lo - zonePad
                        float zHi = lo == hi ? hi + zonePad : hi + zonePad
                        int xStartCluster = math.max(array.get(aboveStart, c), bar_index - profileLen)
                        box b = box.new(xStartCluster, zHi, xEndCluster, zLo,
                             border_color = color.new(colNakedUp, 15), bgcolor = color.new(colNakedUp, 88))
                        label l = label.new(xEndCluster, (zHi + zLo) / 2.0,
                             " nPOC Cluster x" + str.tostring(array.get(aboveCount, c)) + " ",
                             color = color.new(color.black, 100), textcolor = colNakedUp,
                             style = label.style_label_left, size = size.tiny)
                        array.push(nPocClusterBoxes, b)
                        array.push(nPocClusterLabels, l)
                        nPocShownAbove += 1

            // Draw closest clusters below price.
            if array.size(belowLow) > 0
                for c = 0 to array.size(belowLow) - 1
                    float lo = array.get(belowLow, c)
                    float hi = array.get(belowHigh, c)
                    float distC = close - hi
                    int closer = 0
                    for d = 0 to array.size(belowLow) - 1
                        if d != c
                            float otherDist = close - array.get(belowHigh, d)
                            if otherDist < distC
                                closer += 1
                    if closer < maxVisibleNakedClustersSide
                        float zLo = lo == hi ? lo - zonePad : lo - zonePad
                        float zHi = lo == hi ? hi + zonePad : hi + zonePad
                        int xStartCluster = math.max(array.get(belowStart, c), bar_index - profileLen)
                        box b = box.new(xStartCluster, zHi, xEndCluster, zLo,
                             border_color = color.new(colNakedDn, 15), bgcolor = color.new(colNakedDn, 88))
                        label l = label.new(xEndCluster, (zHi + zLo) / 2.0,
                             " nPOC Cluster x" + str.tostring(array.get(belowCount, c)) + " ",
                             color = color.new(color.black, 100), textcolor = colNakedDn,
                             style = label.style_label_left, size = size.tiny)
                        array.push(nPocClusterBoxes, b)
                        array.push(nPocClusterLabels, l)
                        nPocShownBelow += 1
        else
            // Original clean-line mode: show only closest individual nPOC levels per side.
            for k = 0 to array.size(nPocLevels) - 1
                float lvl = array.get(nPocLevels, k)
                bool  abovePrice = lvl > close
                float distK = math.abs(lvl - close)
                int closerOnSameSide = 0

                for m = 0 to array.size(nPocLevels) - 1
                    if m != k
                        float otherLvl = array.get(nPocLevels, m)
                        bool sameSide = abovePrice ? otherLvl > close : otherLvl <= close
                        if sameSide and math.abs(otherLvl - close) < distK
                            closerOnSameSide += 1

                bool visible = closerOnSameSide < maxVisibleNakedSide
                color baseCol = abovePrice ? colNakedUp : colNakedDn
                color finalCol = visible ? baseCol : color.new(baseCol, 100)

                line.set_color(array.get(nPocLines, k), finalCol)
                label.set_textcolor(array.get(nPocLabels, k), finalCol)
                if visible and abovePrice
                    nPocShownAbove += 1
                if visible and not abovePrice
                    nPocShownBelow += 1


// ═══════════════════════════════════════════════════════════════════════════
//  LIQUIDITY SWEEP DETECTION
// ═══════════════════════════════════════════════════════════════════════════

float sH = ta.pivothigh(high, pivotLen, pivotLen)
float sL = ta.pivotlow(low,  pivotLen, pivotLen)

if not na(sH)
    lastSwingHi    := sH
    lastSwingHiBar := bar_index - pivotLen
if not na(sL)
    lastSwingLo    := sL
    lastSwingLoBar := bar_index - pivotLen

inLookback(int b) => not na(b) and (bar_index - b) <= sweepLookback
volMedian = ta.median(volume, math.min(sweepLookback, 200))
volOK     = not sweepVolFilter or volume > volMedian

bool sweepDn = showSweeps and inLookback(lastSwingHiBar) and high > lastSwingHi and close < lastSwingHi and volOK
bool sweepUp = showSweeps and inLookback(lastSwingLoBar) and low  < lastSwingLo and close > lastSwingLo and volOK


// ═══════════════════════════════════════════════════════════════════════════
//  CONFLUENCE SCORE
// ═══════════════════════════════════════════════════════════════════════════

scoreSweep(bool isUp) =>
    int score = 0
    string parts = ""

    if isUp and not na(curVAL) and nearLevel(low, curVAL, proximityPct)
        score += 1
        parts += "VAL+1 "
    if not isUp and not na(curVAH) and nearLevel(high, curVAH, proximityPct)
        score += 1
        parts += "VAH+1 "

    bool nearHvn = false
    if array.size(curHvnLow) > 0
        float p = isUp ? low : high
        for i = 0 to array.size(curHvnLow) - 1
            float lo = array.get(curHvnLow, i)
            float hi = array.get(curHvnHigh, i)
            float pad = close * proximityPct / 100.0
            if p >= lo - pad and p <= hi + pad
                nearHvn := true
                break
    if nearHvn
        score += 1
        parts += "HVN+1 "

    bool nearNpoc = false
    if array.size(nPocLevels) > 0
        float p = isUp ? low : high
        for i = 0 to array.size(nPocLevels) - 1
            if nearLevel(p, array.get(nPocLevels, i), proximityPct)
                nearNpoc := true
                break
    if nearNpoc
        score += 2
        parts += "nPOC+2 "

    bool throughLvn = false
    if array.size(curLvnLow) > 0
        float pStart = isUp ? close[pivotLen] : close[pivotLen]
        float pEnd   = isUp ? low : high
        float a = math.min(pStart, pEnd)
        float b = math.max(pStart, pEnd)
        for i = 0 to array.size(curLvnLow) - 1
            float lo = array.get(curLvnLow, i)
            float hi = array.get(curLvnHigh, i)
            if a <= hi and b >= lo
                throughLvn := true
                break
    if throughLvn
        score += 1
        parts += "LVN+1 "

    [score, parts]


plotshape(sweepDn, "Bearish Sweep",
     style = shape.triangledown, location = location.abovebar,
     color = colSweepDn, size = size.tiny)
plotshape(sweepUp, "Bullish Sweep",
     style = shape.triangleup, location = location.belowbar,
     color = colSweepUp, size = size.tiny)


int    confDnScore = 0
int    confUpScore = 0
string confDnParts = ""
string confUpParts = ""

if sweepDn and showConfluence
    [s, p] = scoreSweep(false)
    confDnScore := s
    confDnParts := p

if sweepUp and showConfluence
    [s, p] = scoreSweep(true)
    confUpScore := s
    confUpParts := p

bool aGradeDn = showConfluence and sweepDn and confDnScore >= aGradeThresh
bool aGradeUp = showConfluence and sweepUp and confUpScore >= aGradeThresh

plotshape(aGradeDn, "A-Grade Short",
     style = shape.labeldown, location = location.abovebar,
     color = colAGrade, size = size.small,
     text = "A", textcolor = color.black)
plotshape(aGradeUp, "A-Grade Long",
     style = shape.labelup, location = location.belowbar,
     color = colAGrade, size = size.small,
     text = "A", textcolor = color.black)
if sweepDn
    lastSwingHi    := na
    lastSwingHiBar := na
    lastSweepBar   := bar_index
    lastSweepDir   := -1
if sweepUp
    lastSwingLo    := na
    lastSwingLoBar := na
    lastSweepBar   := bar_index
    lastSweepDir   := 1


if aGradeDn
    label.new(bar_index, high, "A-GRADE SHORT — score " + str.tostring(confDnScore) + "/5\n" + confDnParts,
         color = color.new(colAGrade, 80), textcolor = color.white,
         style = label.style_label_down, size = size.tiny,
         yloc = yloc.abovebar)
if aGradeUp
    label.new(bar_index, low, "A-GRADE LONG — score " + str.tostring(confUpScore) + "/5\n" + confUpParts,
         color = color.new(colAGrade, 80), textcolor = color.white,
         style = label.style_label_up, size = size.tiny,
         yloc = yloc.belowbar)


// ═══════════════════════════════════════════════════════════════════════════
//  LIQUIDITY DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════

var table dash = na

if showDash and barstate.islast
    table.delete(dash)
    dash := table.new(dashPosition, 2, 11,
         bgcolor = dashBg,
         border_color = dashBorderCol,
         border_width = 1, frame_width = 2,
         frame_color = dashBorderCol)

    table.cell(dash, 0, 0, "LIQUIDITY MAGNET PRO",
         text_color = dashTitleTxt, bgcolor = dashHeaderBg,
         text_size = dashTxtSize)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period,
         text_color = dashValueTxt, bgcolor = dashHeaderBg,
         text_size = dashTxtSize)

    table.cell(dash, 0, 1, "Anchor TF", text_color = dashMutedTxt, bgcolor = dashCellBg, text_size = dashTxtSize)
    table.cell(dash, 1, 1, anchorTF,    text_color = dashValueTxt, bgcolor = dashCellBg, text_size = dashTxtSize)

    string pocStr = na(curPOC) ? "—" : str.tostring(curPOC, format.mintick) + "  (" + str.tostring(distPct(close, curPOC), "0.00") + "%)"
    table.cell(dash, 0, 2, "POC", text_color = dashAccentCol, bgcolor = dashAltBg, text_size = dashTxtSize)
    table.cell(dash, 1, 2, pocStr, text_color = dashValueTxt, bgcolor = dashAltBg, text_size = dashTxtSize)

    string vahStr = na(curVAH) ? "—" : str.tostring(curVAH, format.mintick) + "  (" + str.tostring(distPct(close, curVAH), "0.00") + "%)"
    table.cell(dash, 0, 3, "VAH", text_color = dashLabelTxt, bgcolor = dashCellBg, text_size = dashTxtSize)
    table.cell(dash, 1, 3, vahStr, text_color = dashValueTxt, bgcolor = dashCellBg, text_size = dashTxtSize)

    string valStr = na(curVAL) ? "—" : str.tostring(curVAL, format.mintick) + "  (" + str.tostring(distPct(close, curVAL), "0.00") + "%)"
    table.cell(dash, 0, 4, "VAL", text_color = dashLabelTxt, bgcolor = dashAltBg, text_size = dashTxtSize)
    table.cell(dash, 1, 4, valStr, text_color = dashValueTxt, bgcolor = dashAltBg, text_size = dashTxtSize)

    string vaBias    = "—"
    color  vaBiasCol = dashMutedTxt
    if not na(curVAH) and not na(curVAL)
        if close > curVAH
            vaBias    := "ABOVE VA  (bullish acceptance)"
            vaBiasCol := dashBullTxt
        else if close < curVAL
            vaBias    := "BELOW VA  (bearish acceptance)"
            vaBiasCol := dashBearTxt
        else
            vaBias    := "INSIDE VA  (balance)"
            vaBiasCol := dashLabelTxt
    table.cell(dash, 0, 5, "VA Bias", text_color = dashMutedTxt, bgcolor = dashCellBg, text_size = dashTxtSize)
    table.cell(dash, 1, 5, vaBias, text_color = vaBiasCol, bgcolor = dashCellBg, text_size = dashTxtSize)

    int nAbove = 0
    int nBelow = 0
    if array.size(nPocLevels) > 0
        for k = 0 to array.size(nPocLevels) - 1
            float lvl = array.get(nPocLevels, k)
            if lvl > close
                nAbove += 1
            else
                nBelow += 1

    string shownMode = showNakedClusters ? " clusters shown" : " shown"
    string nAboveStr = str.tostring(nAbove) + " active / " + str.tostring(nPocShownAbove) + shownMode
    string nBelowStr = str.tostring(nBelow) + " active / " + str.tostring(nPocShownBelow) + shownMode

    table.cell(dash, 0, 6, "Naked POCs ↑", text_color = dashNakedUpTxt, bgcolor = dashAltBg, text_size = dashTxtSize)
    table.cell(dash, 1, 6, nAboveStr, text_color = dashValueTxt, bgcolor = dashAltBg, text_size = dashTxtSize)

    table.cell(dash, 0, 7, "Naked POCs ↓", text_color = dashNakedDnTxt, bgcolor = dashCellBg, text_size = dashTxtSize)
    table.cell(dash, 1, 7, nBelowStr, text_color = dashValueTxt, bgcolor = dashCellBg, text_size = dashTxtSize)

    string sweepStr = "—"
    color  sweepCol = dashMutedTxt
    if not na(lastSweepBar)
        // lastSweepDir = -1 means price swept ABOVE a prior swing high and closed back below it.
        // This is a Buy-side Liquidity Sweep, usually a bearish rejection context.
        // lastSweepDir = 1 means price swept BELOW a prior swing low and closed back above it.
        // This is a Sell-side Liquidity Sweep, usually a bullish rejection context.
        sweepStr := (lastSweepDir < 0 ? "BSL sweep → Bearish · " : "SSL sweep → Bullish · ") + str.tostring(bar_index - lastSweepBar) + " bars ago"
        sweepCol := lastSweepDir < 0 ? dashBuySideCol : dashSellSideCol
    table.cell(dash, 0, 8, "Last Sweep Bias", text_color = dashMutedTxt, bgcolor = dashAltBg, text_size = dashTxtSize)
    table.cell(dash, 1, 8, sweepStr, text_color = sweepCol, bgcolor = dashAltBg, text_size = dashTxtSize)

    table.cell(dash, 0, 9, "HVN zones", text_color = dashHvnTxt, bgcolor = dashCellBg, text_size = dashTxtSize)
    table.cell(dash, 1, 9, str.tostring(array.size(curHvnLow)), text_color = dashValueTxt, bgcolor = dashCellBg, text_size = dashTxtSize)

    table.cell(dash, 0, 10, "LVN zones", text_color = dashLvnTxt, bgcolor = dashAltBg, text_size = dashTxtSize)
    table.cell(dash, 1, 10, str.tostring(array.size(curLvnLow)), text_color = dashValueTxt, bgcolor = dashAltBg, text_size = dashTxtSize)

// ═══════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════

alertcondition(sweepDn,  "Bearish Sweep",
     message = "Liquidity Magnet Pro — Bearish sweep (sell-side stop hunt) on {{ticker}} {{interval}}")
alertcondition(sweepUp,  "Bullish Sweep",
     message = "Liquidity Magnet Pro — Bullish sweep (buy-side stop hunt) on {{ticker}} {{interval}}")
alertcondition(aGradeDn, "A-Grade Short",
     message = "Liquidity Magnet Pro — A-GRADE SHORT setup on {{ticker}} {{interval}}: sweep + liquidity confluence")
alertcondition(aGradeUp, "A-Grade Long",
     message = "Liquidity Magnet Pro — A-GRADE LONG setup on {{ticker}} {{interval}}: sweep + liquidity confluence")

bool vaBreakUp = not na(curVAH) and close > curVAH and close[1] <= curVAH[1]
bool vaBreakDn = not na(curVAL) and close < curVAL and close[1] >= curVAL[1]
alertcondition(vaBreakUp, "Value Area Break Up",
     message = "Liquidity Magnet Pro — Price broke ABOVE Value Area on {{ticker}} {{interval}}")
alertcondition(vaBreakDn, "Value Area Break Down",
     message = "Liquidity Magnet Pro — Price broke BELOW Value Area on {{ticker}} {{interval}}")

bool nPocHit = false
if array.size(nPocLevels) > 0
    for i = 0 to array.size(nPocLevels) - 1
        float lvl = array.get(nPocLevels, i)
        if low <= lvl and high >= lvl
            nPocHit := true
            break
alertcondition(nPocHit, "Naked POC Tested",
     message = "Liquidity Magnet Pro — Price tested a Naked POC on {{ticker}} {{interval}}")
````
