# Market Phase Detector v2.3 [Wyckoff MTF]

- url: https://www.tradingview.com/script/fzIXqCHN/
- type: indicator
- pine_id: PUB;f155e0e9f0314c72a6c34262bac3d8ec
- version: 1.0

## Description

[b]MARKET PHASE DETECTOR v2.3 [WYCKOFF MTF]
[/b]
[b]OVERVIEW[/b]

Market Phase Detector v2.3 is a multi-timeframe market structure and Wyckoff-style phase detection indicator designed to help identify:

• Accumulation
• Re-Accumulation
• Markup
• Distribution
• Re-Distribution
• Markdown
• Neutral market conditions

The indicator combines trend structure, EMA relationships, ATR-normalized momentum, money flow, relative volume, range behavior, liquidity sweeps, and multi-timeframe context.

Its main purpose is to help answer a simple question:

What phase is the market currently in, and is the higher-timeframe trend aligned with the local structure?

This indicator is designed as a market context and confirmation tool, not as a standalone buy/sell system.


[b]━━━━━━━━━━━━━━━━━━
MARKET PHASES
━━━━━━━━━━━━━━━━━━[/b]

[b]ACCUMULATION[/b]

A range-like environment where buying pressure begins to dominate after a weaker or bearish period.

Typical characteristics may include:

• Sideways market structure
• Improving money flow
• Rising OBV / A-D behavior
• Buying volume dominance
• Possible Spring event
• Improving local structure

Accumulation may represent a base-building phase before a potential bullish transition.


[b]RE-ACCUMULATION
[/b]
A consolidation phase that occurs while the broader trend remains bullish.

Unlike classical Accumulation, Re-Accumulation appears inside an already positive market structure.

Typical interpretation:

The market is pausing or consolidating while the broader bullish trend remains intact.

This phase may help identify continuation conditions after an earlier Markup phase.


[b]MARKUP[/b]

A directional bullish trend.

Typical characteristics:

• Positive Trend Score
• Price above trend averages
• Rising EMA structure
• Positive momentum
• Improving market structure

Markup represents an established bullish environment rather than a base-building phase.


[b]DISTRIBUTION[/b]

A sideways or topping environment where selling pressure becomes dominant.

Typical characteristics may include:

• Negative CMF
• Weakening OBV / A-D
• Selling volume dominance
• Structural deterioration
• Possible UTAD
• Weakening support

Distribution should be treated as a warning condition rather than an automatic sell signal.


[b]RE-DISTRIBUTION
[/b]
A consolidation phase inside a broader bearish trend.

Typical interpretation:

The market is pausing, but the broader structure remains bearish and may later continue lower.


[b]MARKDOWN
[/b]
A directional bearish trend.

Typical characteristics:

• Negative Trend Score
• Bearish EMA structure
• Negative momentum
• Falling market structure
• Sustained selling pressure


[b]NEUTRAL[/b]

No sufficiently strong phase or directional advantage is detected.

Neutral conditions may appear during transitions, mixed environments, or when accumulation and distribution pressure remain relatively balanced.


[b]━━━━━━━━━━━━━━━━━━
TREND SCORE
━━━━━━━━━━━━━━━━━━[/b]

The indicator calculates a Trend Score from -100 to +100.

The score combines:

• Price distance from the fast EMA
• Fast EMA vs slow EMA relationship
• EMA slope
• Momentum
• Market structure
• ATR-normalized movement

General interpretation:

+60 to +100  = Strong Bull
+25 to +59   = Bull
-24 to +24   = Neutral
-25 to -59   = Bear
-60 to -100  = Strong Bear

The Trend Score is also used internally to distinguish:

• Accumulation from Re-Accumulation
• Distribution from Re-Distribution
• Consolidation from directional trend phases


[b]━━━━━━━━━━━━━━━━━━
ACCUMULATION PRESSURE
━━━━━━━━━━━━━━━━━━[/b]

Accumulation Pressure is measured on a 0–100 scale.

It considers factors such as:

• Sideways market behavior
• Positive CMF
• Rising OBV
• Rising A-D
• Buying volume dominance
• Recent downside liquidity sweep
• Confirmed Spring
• Bullish structural recovery

General interpretation:

0–49    = Low
50–64   = Medium
65–79   = High
80–100  = Very High

A high Accumulation Pressure score does not automatically mean that the market is in Accumulation.

The final market phase also depends on trend context and competing Distribution Pressure.


[b]━━━━━━━━━━━━━━━━━━
DISTRIBUTION PRESSURE
━━━━━━━━━━━━━━━━━━[/b]

Distribution Pressure is also measured on a 0–100 scale.

It considers:

• Sideways market behavior
• Negative CMF
• Falling OBV
• Falling A-D
• Selling volume dominance
• Recent upside liquidity sweep
• Confirmed UTAD
• Bearish structural damage

General interpretation:

0–49    = Low
50–64   = Medium
65–79   = High
80–100  = Very High

A high Distribution Pressure score warns that selling pressure is increasing.

However, the indicator also checks the broader trend before classifying the market as full Distribution.

This helps reduce false Distribution signals during ordinary pullbacks inside strong bullish trends.


[b]━━━━━━━━━━━━━━━━━━
MONEY FLOW
━━━━━━━━━━━━━━━━━━[/b]

The indicator uses Chaikin Money Flow (CMF) as one of its flow measurements.

General interpretation:

CMF > 0  = Positive / Buy Flow
CMF < 0  = Negative / Sell Flow

The indicator also uses:

• OBV slope
• Accumulation / Distribution slope
• Directional volume dominance

This allows the script to evaluate more than price direction alone.


[b]━━━━━━━━━━━━━━━━━━
RELATIVE VOLUME
━━━━━━━━━━━━━━━━━━[/b]

RVOL shows Relative Volume compared with its average.

Examples:

0.50x = 50% of average volume
1.00x = average volume
1.50x = 50% above average
2.00x = twice the average volume

RVOL is especially important for confirming:

• SOS
• SOW
• Breakout quality

When confirmed-bar mode is enabled, the indicator uses confirmed data rather than incomplete realtime volume.


[b]━━━━━━━━━━━━━━━━━━
TRADING RANGE DETECTION
━━━━━━━━━━━━━━━━━━[/b]

The script uses market efficiency to determine whether price is operating inside a trading range.

When:

Trading Range = YES

the script focuses more heavily on identifying:

• Accumulation
• Re-Accumulation
• Distribution
• Re-Distribution
• Spring
• UTAD

When:

Trading Range = NO

the market is more likely to be treated as directional:

• Markup
• Markdown
• Neutral transition


[b]━━━━━━━━━━━━━━━━━━
WYCKOFF-STYLE EVENTS
━━━━━━━━━━━━━━━━━━[/b]

[b]SPRING[/b]

A Spring occurs when price moves below a previous range low and then recovers back into the range.

The indicator requires additional confirmation before labeling a Spring.

A confirmed Spring typically requires:

• Recent downside sweep
• Range conditions
• Recovery above the range midpoint
• Positive CMF
• Rising OBV

A Spring may indicate that downside liquidity was taken before a potential bullish recovery.


[b]UTAD[/b]

UTAD stands for Upthrust After Distribution.

It is the bearish counterpart to a Spring.

The indicator looks for:

• Upside liquidity sweep
• Return below the range structure
• Negative CMF
• Falling OBV
• Bearish structural damage

UTAD may indicate that an upside breakout failed and selling pressure is increasing.


[b]SOS — SIGN OF STRENGTH
[/b]
SOS identifies a bullish breakout from the range with stronger relative volume and positive flow.

Typical interpretation:

Buyers are taking control and the market may be transitioning from Accumulation or Re-Accumulation into Markup.


[b]SOW — SIGN OF WEAKNESS
[/b]
SOW identifies a bearish break below the range with elevated relative volume and negative flow.

Typical interpretation:

Sellers are taking control and the market may be transitioning from Distribution or Re-Distribution into Markdown.


[b]━━━━━━━━━━━━━━━━━━
MULTI-TIMEFRAME ANALYSIS
━━━━━━━━━━━━━━━━━━[/b]

One of the main features of v2.3 is its multi-timeframe framework.

Default settings:

Primary Timeframe = 1D
Local Timeframe   = 4H

The Primary timeframe defines the broader market context.

The Local timeframe is used to identify shorter-term structure and confirmation.

Example:

1D = Re-Accumulation
4H = Distribution

This does not automatically mean that the entire market is bearish.

It may instead indicate:

Bullish higher-timeframe structure with local weakness, profit-taking, or corrective price action.


[b]━━━━━━━━━━━━━━━━━━
COMBINED BIAS
━━━━━━━━━━━━━━━━━━[/b]

The indicator combines the Primary and Local timeframe conditions into a Combined Bias.

Possible outputs:

[b]BULLISH[/b]

Higher and lower timeframes are broadly aligned to the upside.


[b]BULLISH / CAUTION
[/b]
The Primary structure remains bullish, but the Local timeframe is showing weakness or Distribution.


[b]NEUTRAL[/b]

No strong directional alignment.


[b]BEARISH / CAUTION
[/b]
The Primary structure remains bearish while the Local timeframe shows temporary bullish recovery.


[b]BEARISH[/b]

Both timeframes are broadly aligned to the downside.


[b]━━━━━━━━━━━━━━━━━━
SMART MTF ALERTS
━━━━━━━━━━━━━━━━━━[/b]

Version 2.3 includes context-aware alerts based on the interaction between the Primary and Local timeframe.


[b]MTF STRONG BULLISH SETUP
[/b]
Triggered when:

• Higher-timeframe context remains strongly bullish
• Local timeframe confirms strength
• Distribution Pressure remains controlled

This may include:

• Primary Markup
• Primary Re-Accumulation
• Local Markup
• Local Re-Accumulation
• Local SOS

This alert is designed to identify bullish continuation conditions.


[b]MTF BULLISH RECOVERY
[/b]
Triggered when:

• Higher-timeframe structure remains bullish
• Local timeframe previously showed weakness
• Local strength returns through an SOS condition

This may help identify recovery after a local correction.


[b]MTF RISK WARNING
[/b]
Triggered when:

• Higher-timeframe structure remains bullish
• Local timeframe enters Distribution
• Distribution Pressure reaches a meaningful level

This is an early caution signal.

It does not necessarily mean that the entire trend has reversed.


[b]MTF BEARISH REVERSAL WARNING
[/b]
A stronger bearish warning.

It requires:

• Weakening higher-timeframe structure
• Strong local Distribution
• Local SOW confirmation

This is designed to identify conditions where local weakness may be developing into a broader bearish transition.


[b]━━━━━━━━━━━━━━━━━━
ALERT CONDITIONS
━━━━━━━━━━━━━━━━━━[/b]

The script includes alert conditions for:

• Accumulation
• Re-Accumulation
• Markup
• Distribution
• Re-Distribution
• Markdown
• Confirmed Spring
• Confirmed UTAD
• SOS
• SOW
• MTF Strong Bullish Setup
• MTF Bullish Recovery
• MTF Risk Warning
• MTF Bearish Reversal Warning

For confirmed signals, using:

Once Per Bar Close

is recommended.


[b]━━━━━━━━━━━━━━━━━━
SUGGESTED WORKFLOW
━━━━━━━━━━━━━━━━━━[/b]

A practical way to read the indicator is:

1. Combined Bias
2. Primary market phase
3. Local market phase
4. Trend Score
5. Accumulation / Distribution Pressure
6. CMF and RVOL
7. Spring / UTAD / SOS / SOW

The indicator is designed around context.

A single label or signal should generally not be used in isolation.


Example of a stronger bullish condition:

Primary: Re-Accumulation
Local: Markup
Trend Score: Positive
Accumulation Pressure: High
CMF: Positive
Combined Bias: Bullish
Smart Alert: Strong Bullish


[b]━━━━━━━━━━━━━━━━━━
RECOMMENDED TIMEFRAMES
━━━━━━━━━━━━━━━━━━[/b]

The indicator was designed primarily for:

1D  = broader market phase
4H  = local structure and confirmation

Lower timeframes can also be used, but market noise increases significantly.

The default MTF combination is:

Primary = 1D
Local   = 4H


[b]━━━━━━━━━━━━━━━━━━
IMPORTANT NOTES
━━━━━━━━━━━━━━━━━━[/b]

This indicator does not attempt to predict exact market tops or bottoms.

It is designed to:

• Classify market regime
• Identify market phase
• Measure Accumulation and Distribution Pressure
• Provide trend context
• Detect Wyckoff-style events
• Combine multiple timeframes
• Generate contextual alerts

It should be treated as an analytical and confirmation tool rather than a mechanical trading system.

Market conditions can change rapidly, and no indicator can reliably identify every reversal or continuation.


[b]━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━[/b]

This script is intended for educational and analytical purposes only.

It does not constitute financial advice, investment advice, trading advice, or a recommendation to buy or sell any asset.

Signals generated by the indicator should be used together with independent analysis, risk management, and appropriate position sizing.

Past market behavior does not guarantee future results.

## Source Code

````pine
//@version=6
indicator(
     "Market Phase Detector v2.3 [Wyckoff MTF]",
     shorttitle="MPD v2.3",
     overlay=true,
     max_labels_count=500
)

// ============================================================================
// 01 — CORE ENGINE
// ============================================================================

groupCore = "01 — Core Engine"

rangeLen = input.int(
     40,
     "Trading Range Length",
     minval=15,
     maxval=200,
     group=groupCore
)

effThreshold = input.float(
     0.32,
     "Sideways Efficiency Max",
     minval=0.05,
     maxval=0.80,
     step=0.01,
     group=groupCore
)

phaseThreshold = input.int(
     65,
     "Phase Pressure Threshold",
     minval=40,
     maxval=90,
     group=groupCore
)

scoreMargin = input.int(
     10,
     "Pressure Advantage Required",
     minval=0,
     maxval=40,
     group=groupCore
)

phaseConfirmBars = input.int(
     2,
     "Bars Required To Confirm Phase",
     minval=1,
     maxval=6,
     group=groupCore
)

useConfirmedBars = input.bool(
     true,
     "Use Last Confirmed Bar In Realtime",
     group=groupCore
)


// ============================================================================
// 02 — TREND ENGINE
// ============================================================================

groupTrend = "02 — Trend Engine"

fastLen = input.int(
     20,
     "Fast EMA",
     minval=2,
     group=groupTrend
)

slowLen = input.int(
     50,
     "Slow EMA",
     minval=5,
     group=groupTrend
)

structureLen = input.int(
     20,
     "Structure Lookback",
     minval=5,
     group=groupTrend
)

momentumLen = input.int(
     14,
     "Momentum Length",
     minval=3,
     group=groupTrend
)

strongTrendScore = input.int(
     55,
     "Strong Trend Threshold",
     minval=30,
     maxval=90,
     group=groupTrend
)

trendGateScore = input.int(
     50,
     "Trend Context Gate",
     minval=20,
     maxval=90,
     group=groupTrend
)

reAccumTrendMin = input.int(
     30,
     "Re-Accumulation Trend Minimum",
     minval=0,
     maxval=80,
     group=groupTrend
)

reDistribTrendMax = input.int(
     -30,
     "Re-Distribution Trend Maximum",
     minval=-80,
     maxval=0,
     group=groupTrend
)


// ============================================================================
// 03 — MONEY FLOW
// ============================================================================

groupFlow = "03 — Money Flow"

cmfLen = input.int(
     21,
     "CMF Length",
     minval=5,
     group=groupFlow
)

cmfBull = input.float(
     0.05,
     "Bullish CMF Threshold",
     step=0.01,
     group=groupFlow
)

cmfBear = input.float(
     -0.05,
     "Bearish CMF Threshold",
     step=0.01,
     group=groupFlow
)

flowSlopeLen = input.int(
     20,
     "OBV / A-D Slope Length",
     minval=5,
     group=groupFlow
)

volumeLen = input.int(
     20,
     "Volume Average Length",
     minval=5,
     group=groupFlow
)


// ============================================================================
// 04 — WYCKOFF EVENTS
// ============================================================================

groupWyckoff = "04 — Wyckoff Events"

sweepMemory = input.int(
     8,
     "Sweep Confirmation Window",
     minval=1,
     maxval=30,
     group=groupWyckoff
)

eventCooldown = input.int(
     10,
     "Event Label Cooldown",
     minval=1,
     maxval=50,
     group=groupWyckoff
)

breakoutVol = input.float(
     1.35,
     "SOS / SOW Minimum RVOL",
     minval=0.5,
     maxval=5,
     step=0.05,
     group=groupWyckoff
)

showSweeps = input.bool(
     false,
     "Show Liquidity Sweeps",
     group=groupWyckoff
)

showSpring = input.bool(
     true,
     "Show Confirmed Spring",
     group=groupWyckoff
)

showUTAD = input.bool(
     true,
     "Show Confirmed UTAD",
     group=groupWyckoff
)

showSOS = input.bool(
     true,
     "Show SOS",
     group=groupWyckoff
)

showSOW = input.bool(
     true,
     "Show SOW",
     group=groupWyckoff
)


// ============================================================================
// 05 — MULTI TIMEFRAME
// ============================================================================

groupMTF = "05 — Multi Timeframe"

higherTF = input.timeframe(
     "D",
     "Primary Timeframe",
     group=groupMTF
)

localTF = input.timeframe(
     "240",
     "Local Timeframe",
     group=groupMTF
)

showMTF = input.bool(
     true,
     "Show MTF Data",
     group=groupMTF
)


// ============================================================================
// 06 — DISPLAY
// ============================================================================

groupDisplay = "06 — Display"

backgroundMode = input.string(
     "Regime",
     "Background Mode",
     options=["Off", "Regime", "Phase"],
     group=groupDisplay
)

showEMA = input.bool(
     true,
     "Show EMA",
     group=groupDisplay
)

showRange = input.bool(
     true,
     "Show Trading Range",
     group=groupDisplay
)

showPhaseLabels = input.bool(
     true,
     "Show Phase Change Labels",
     group=groupDisplay
)

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group=groupDisplay
)


// ============================================================================
// 07 — PHASE COLORS
// ============================================================================

groupColors = "07 — Phase Colors"

colorAccumulation = input.color(
     color.rgb(41, 98, 255),
     "Accumulation",
     group=groupColors
)

colorReAccumulation = input.color(
     color.rgb(0, 188, 212),
     "Re-Accumulation",
     group=groupColors
)

colorMarkup = input.color(
     color.rgb(76, 175, 80),
     "Markup",
     group=groupColors
)

colorDistribution = input.color(
     color.rgb(255, 152, 0),
     "Distribution",
     group=groupColors
)

colorReDistribution = input.color(
     color.rgb(255, 87, 34),
     "Re-Distribution",
     group=groupColors
)

colorMarkdown = input.color(
     color.rgb(244, 67, 54),
     "Markdown",
     group=groupColors
)

colorNeutral = input.color(
     color.gray,
     "Neutral",
     group=groupColors
)

phaseBackgroundTransparency = input.int(
     91,
     "Phase Background Transparency",
     minval=0,
     maxval=100,
     group=groupColors
)

regimeBackgroundTransparency = input.int(
     94,
     "Regime Background Transparency",
     minval=0,
     maxval=100,
     group=groupColors
)


// ============================================================================
// 08 — LINE COLORS
// ============================================================================

groupLines = "08 — Lines"

fastEMAColor = input.color(
     color.white,
     "Fast EMA Color",
     group=groupLines
)

slowEMAColor = input.color(
     color.rgb(255, 193, 7),
     "Slow EMA Color",
     group=groupLines
)

fastEMAWidth = input.int(
     1,
     "Fast EMA Width",
     minval=1,
     maxval=5,
     group=groupLines
)

slowEMAWidth = input.int(
     2,
     "Slow EMA Width",
     minval=1,
     maxval=5,
     group=groupLines
)

rangeHighColor = input.color(
     color.red,
     "Range High",
     group=groupLines
)

rangeLowColor = input.color(
     color.green,
     "Range Low",
     group=groupLines
)

rangeTransparency = input.int(
     45,
     "Range Transparency",
     minval=0,
     maxval=100,
     group=groupLines
)


// ============================================================================
// 09 — EVENT COLORS
// ============================================================================

groupEvents = "09 — Event Colors"

springColor = input.color(
     color.rgb(41, 98, 255),
     "Spring",
     group=groupEvents
)

utadColor = input.color(
     color.rgb(255, 152, 0),
     "UTAD",
     group=groupEvents
)

sosColor = input.color(
     color.rgb(76, 175, 80),
     "SOS",
     group=groupEvents
)

sowColor = input.color(
     color.rgb(244, 67, 54),
     "SOW",
     group=groupEvents
)

sweepHighColor = input.color(
     color.orange,
     "Sweep High",
     group=groupEvents
)

sweepLowColor = input.color(
     color.aqua,
     "Sweep Low",
     group=groupEvents
)

eventTextColor = input.color(
     color.white,
     "Event Text",
     group=groupEvents
)


// ============================================================================
// 10 — SMART ALERT SETTINGS
// ============================================================================

groupSmartAlerts = "10 — Smart MTF Alerts"

enableStrongBullAlert = input.bool(
     true,
     "Enable Strong Bullish Setup",
     group=groupSmartAlerts
)

enableRiskAlert = input.bool(
     true,
     "Enable Risk Warning",
     group=groupSmartAlerts
)

enableBearReversalAlert = input.bool(
     true,
     "Enable Bearish Reversal Warning",
     group=groupSmartAlerts
)

enableBullRecoveryAlert = input.bool(
     true,
     "Enable Bullish Recovery",
     group=groupSmartAlerts
)

strongDistributionAlertLevel = input.int(
     75,
     "Strong Distribution Level",
     minval=65,
     maxval=100,
     group=groupSmartAlerts
)


// ============================================================================
// 11 — DASHBOARD
// ============================================================================

groupDashboard = "11 — Dashboard"

dashboardPositionInput = input.string(
     "Bottom Right",
     "Dashboard Position",
     options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"],
     group=groupDashboard
)

dashboardBackground = input.color(
     color.rgb(25, 25, 60),
     "Background",
     group=groupDashboard
)

dashboardTransparency = input.int(
     5,
     "Background Transparency",
     minval=0,
     maxval=100,
     group=groupDashboard
)

dashboardLabelColor = input.color(
     color.white,
     "Label Text",
     group=groupDashboard
)

dashboardValueColor = input.color(
     color.white,
     "Value Text",
     group=groupDashboard
)

dashboardHeaderColor = input.color(
     color.white,
     "Header Text",
     group=groupDashboard
)

dashboardBorderColor = input.color(
     color.gray,
     "Border",
     group=groupDashboard
)

dashboardTextSizeInput = input.string(
     "Small",
     "Text Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=groupDashboard
)


// ============================================================================
// DASHBOARD HELPERS
// ============================================================================

dashboardPosition = position.bottom_right

if dashboardPositionInput == "Top Left"
    dashboardPosition := position.top_left
else if dashboardPositionInput == "Top Right"
    dashboardPosition := position.top_right
else if dashboardPositionInput == "Bottom Left"
    dashboardPosition := position.bottom_left
else
    dashboardPosition := position.bottom_right


dashboardTextSize = size.small

if dashboardTextSizeInput == "Tiny"
    dashboardTextSize := size.tiny
else if dashboardTextSizeInput == "Normal"
    dashboardTextSize := size.normal
else if dashboardTextSizeInput == "Large"
    dashboardTextSize := size.large
else
    dashboardTextSize := size.small


// ============================================================================
// GENERIC HELPERS
// ============================================================================

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))


f_phaseName(int p) =>
    switch p
        1 => "ACCUMULATION"
        2 => "MARKUP"
        3 => "RE-ACCUMULATION"
        4 => "DISTRIBUTION"
        5 => "MARKDOWN"
        6 => "RE-DISTRIBUTION"
        => "NEUTRAL"


f_phaseColor(int p) =>
    switch p
        1 => colorAccumulation
        2 => colorMarkup
        3 => colorReAccumulation
        4 => colorDistribution
        5 => colorMarkdown
        6 => colorReDistribution
        => colorNeutral


f_trendName(float t) =>
    string result = "NEUTRAL"

    if t >= 60
        result := "STRONG BULL"
    else if t >= 25
        result := "BULL"
    else if t <= -60
        result := "STRONG BEAR"
    else if t <= -25
        result := "BEAR"

    result


f_pressureName(float score) =>
    string result = "LOW"

    if score >= 80
        result := "VERY HIGH"
    else if score >= 65
        result := "HIGH"
    else if score >= 50
        result := "MEDIUM"

    result


// ============================================================================
// MARKET ENGINE
// ============================================================================

f_engine() =>

    // ------------------------------------------------------------------------
    // EMA / ATR
    // ------------------------------------------------------------------------

    emaFastLocal = ta.ema(close, fastLen)
    emaSlowLocal = ta.ema(close, slowLen)

    atrLocal = ta.atr(14)

    safeATR = atrLocal

    if safeATR == 0 or na(safeATR)
        safeATR := 1.0


    // ------------------------------------------------------------------------
    // STRUCTURE
    // ------------------------------------------------------------------------

    highSlope =
         ta.linreg(high, structureLen, 0) -
         ta.linreg(high, structureLen, 1)

    lowSlope =
         ta.linreg(low, structureLen, 0) -
         ta.linreg(low, structureLen, 1)

    emaFastSlope =
         emaFastLocal - emaFastLocal[5]

    emaSlowSlope =
         emaSlowLocal - emaSlowLocal[5]


    // ------------------------------------------------------------------------
    // SMOOTH TREND SCORE
    // ------------------------------------------------------------------------

    priceFastATR =
         (close - emaFastLocal) / safeATR

    emaGapATR =
         (emaFastLocal - emaSlowLocal) / safeATR

    fastSlopeATR =
         emaFastSlope / safeATR

    slowSlopeATR =
         emaSlowSlope / safeATR

    momentumATR =
         (close - close[momentumLen]) / safeATR

    structureATR =
         ((highSlope + lowSlope) / 2.0) / safeATR


    trendComponent1 =
         f_clamp(priceFastATR * 10.0, -18.0, 18.0)

    trendComponent2 =
         f_clamp(emaGapATR * 12.0, -22.0, 22.0)

    trendComponent3 =
         f_clamp(fastSlopeATR * 15.0, -18.0, 18.0)

    trendComponent4 =
         f_clamp(slowSlopeATR * 18.0, -16.0, 16.0)

    trendComponent5 =
         f_clamp(momentumATR * 2.0, -14.0, 14.0)

    trendComponent6 =
         f_clamp(structureATR * 30.0, -12.0, 12.0)


    trendFloat =
         trendComponent1 +
         trendComponent2 +
         trendComponent3 +
         trendComponent4 +
         trendComponent5 +
         trendComponent6

    trendScore =
         int(math.round(f_clamp(trendFloat, -100.0, 100.0)))


    // ------------------------------------------------------------------------
    // RANGE ENGINE
    // ------------------------------------------------------------------------

    rangeHighPrev =
         ta.highest(high[1], rangeLen)

    rangeLowPrev =
         ta.lowest(low[1], rangeLen)

    rangeMid =
         (rangeHighPrev + rangeLowPrev) / 2.0

    priceTravel =
         math.sum(
             math.abs(ta.change(close)),
             rangeLen
         )

    efficiency = 0.0

    if priceTravel != 0
        efficiency :=
             math.abs(close - close[rangeLen]) / priceTravel

    sideways =
         efficiency < effThreshold


    // ------------------------------------------------------------------------
    // VOLUME
    // ------------------------------------------------------------------------

    avgVolume =
         ta.sma(volume, volumeLen)

    relativeVolume = 0.0

    if avgVolume > 0
        relativeVolume :=
             volume / avgVolume


    upVolume =
         ta.sma(
             close > close[1] ? volume : 0,
             volumeLen
         )

    downVolume =
         ta.sma(
             close < close[1] ? volume : 0,
             volumeLen
         )

    buyVolumeDominant =
         upVolume > downVolume

    sellVolumeDominant =
         downVolume > upVolume


    // ------------------------------------------------------------------------
    // CMF
    // ------------------------------------------------------------------------

    candleRange =
         high - low

    mfMultiplier = 0.0

    if candleRange != 0
        mfMultiplier :=
             ((close - low) - (high - close)) / candleRange

    mfVolume =
         mfMultiplier * volume

    totalVolume =
         math.sum(volume, cmfLen)

    cmf = 0.0

    if totalVolume != 0
        cmf :=
             math.sum(mfVolume, cmfLen) / totalVolume


    // ------------------------------------------------------------------------
    // OBV
    // ------------------------------------------------------------------------

    signedVolume = 0.0

    if close > close[1]
        signedVolume := volume
    else if close < close[1]
        signedVolume := -volume

    obv =
         ta.cum(signedVolume)

    obvSlope =
         ta.linreg(obv, flowSlopeLen, 0) -
         ta.linreg(obv, flowSlopeLen, 1)


    // ------------------------------------------------------------------------
    // A/D
    // ------------------------------------------------------------------------

    ad =
         ta.cum(mfVolume)

    adSlope =
         ta.linreg(ad, flowSlopeLen, 0) -
         ta.linreg(ad, flowSlopeLen, 1)


    // ------------------------------------------------------------------------
    // LIQUIDITY SWEEPS
    // ------------------------------------------------------------------------

    sweepLow =
         low < rangeLowPrev and
         close > rangeLowPrev

    sweepHigh =
         high > rangeHighPrev and
         close < rangeHighPrev

    barsSinceSweepLow =
         ta.barssince(sweepLow)

    barsSinceSweepHigh =
         ta.barssince(sweepHigh)

    recentSweepLow =
         not na(barsSinceSweepLow) and
         barsSinceSweepLow <= sweepMemory

    recentSweepHigh =
         not na(barsSinceSweepHigh) and
         barsSinceSweepHigh <= sweepMemory


    // ------------------------------------------------------------------------
    // STRUCTURAL DAMAGE / RECOVERY
    // ------------------------------------------------------------------------

    bearishStructureDamage =
         close < rangeMid and
         close < emaFastLocal and
         highSlope < 0

    bullishStructureRecovery =
         close > rangeMid and
         close > emaFastLocal and
         lowSlope > 0


    // ------------------------------------------------------------------------
    // WYCKOFF CONFIRMATION
    // ------------------------------------------------------------------------

    springConfirmed =
         recentSweepLow and
         sideways and
         bullishStructureRecovery and
         cmf > 0 and
         obvSlope > 0

    utadConfirmed =
         recentSweepHigh and
         sideways and
         bearishStructureDamage and
         cmf < 0 and
         obvSlope < 0


    // ------------------------------------------------------------------------
    // SOS / SOW
    // ------------------------------------------------------------------------

    sos =
         close > rangeHighPrev and
         relativeVolume >= breakoutVol and
         cmf > 0

    sow =
         close < rangeLowPrev and
         relativeVolume >= breakoutVol and
         cmf < 0


    // ------------------------------------------------------------------------
    // ACCUMULATION PRESSURE
    // ------------------------------------------------------------------------

    int accumulationScore = 0

    if sideways
        accumulationScore += 20

    if cmf >= cmfBull
        accumulationScore += 20
    else if cmf > 0
        accumulationScore += 10

    if obvSlope > 0
        accumulationScore += 15

    if adSlope > 0
        accumulationScore += 10

    if buyVolumeDominant
        accumulationScore += 10

    if recentSweepLow
        accumulationScore += 5

    if springConfirmed
        accumulationScore += 10

    if bullishStructureRecovery
        accumulationScore += 10

    accumulationScore :=
         int(f_clamp(accumulationScore, 0, 100))


    // ------------------------------------------------------------------------
    // DISTRIBUTION PRESSURE
    // ------------------------------------------------------------------------

    int distributionScore = 0

    if sideways
        distributionScore += 20

    if cmf <= cmfBear
        distributionScore += 20
    else if cmf < 0
        distributionScore += 10

    if obvSlope < 0
        distributionScore += 15

    if adSlope < 0
        distributionScore += 10

    if sellVolumeDominant
        distributionScore += 10

    if recentSweepHigh
        distributionScore += 5

    if utadConfirmed
        distributionScore += 10

    if bearishStructureDamage
        distributionScore += 10

    distributionScore :=
         int(f_clamp(distributionScore, 0, 100))


    // ------------------------------------------------------------------------
    // PRESSURE DOMINANCE
    // ------------------------------------------------------------------------

    accumulationDominant =
         accumulationScore >= phaseThreshold and
         accumulationScore >= distributionScore + scoreMargin

    distributionDominant =
         distributionScore >= phaseThreshold and
         distributionScore >= accumulationScore + scoreMargin


    // ------------------------------------------------------------------------
    // CONTEXT STATES
    // ------------------------------------------------------------------------

    strongBull =
         trendScore >= trendGateScore

    strongBear =
         trendScore <= -trendGateScore

    reAccumContext =
         trendScore >= reAccumTrendMin

    reDistribContext =
         trendScore <= reDistribTrendMax


    // ------------------------------------------------------------------------
    // RAW PHASE
    // ------------------------------------------------------------------------

    int rawPhase = 0

    if sideways

        if accumulationDominant

            if reAccumContext
                rawPhase := 3

            else if reDistribContext and not bullishStructureRecovery
                rawPhase := 6

            else
                rawPhase := 1


        else if distributionDominant

            if strongBull and not bearishStructureDamage and not sow
                rawPhase := 3

            else if reDistribContext
                rawPhase := 6

            else
                rawPhase := 4


        else

            if strongBull
                rawPhase := 3

            else if strongBear
                rawPhase := 6

            else
                rawPhase := 0


    else

        if trendScore >= strongTrendScore
            rawPhase := 2

        else if trendScore <= -strongTrendScore
            rawPhase := 5

        else
            rawPhase := 0


    // ------------------------------------------------------------------------
    // PHASE CONFIRMATION
    // ------------------------------------------------------------------------

    phaseStable = true

    if phaseConfirmBars > 1

        for i = 1 to phaseConfirmBars - 1
            phaseStable :=
                 phaseStable and
                 rawPhase == rawPhase[i]


    stablePhase = 0

    if phaseStable
        stablePhase := rawPhase


    // ------------------------------------------------------------------------
    // CONFIRMED REALTIME OUTPUT
    // ------------------------------------------------------------------------

    usePrevious =
         useConfirmedBars and
         barstate.isrealtime


    outPhase = stablePhase
    outTrend = trendScore
    outAcc = accumulationScore
    outDist = distributionScore
    outCMF = cmf
    outRVOL = relativeVolume
    outSideways = sideways
    outSweepLow = sweepLow
    outSweepHigh = sweepHigh
    outSpring = springConfirmed
    outUTAD = utadConfirmed
    outSOS = sos
    outSOW = sow
    outFast = emaFastLocal
    outSlow = emaSlowLocal
    outRangeHigh = rangeHighPrev
    outRangeLow = rangeLowPrev


    if usePrevious

        outPhase := stablePhase[1]
        outTrend := trendScore[1]
        outAcc := accumulationScore[1]
        outDist := distributionScore[1]
        outCMF := cmf[1]
        outRVOL := relativeVolume[1]
        outSideways := sideways[1]
        outSweepLow := sweepLow[1]
        outSweepHigh := sweepHigh[1]
        outSpring := springConfirmed[1]
        outUTAD := utadConfirmed[1]
        outSOS := sos[1]
        outSOW := sow[1]
        outFast := emaFastLocal[1]
        outSlow := emaSlowLocal[1]
        outRangeHigh := rangeHighPrev[1]
        outRangeLow := rangeLowPrev[1]


    [
         outPhase,
         outTrend,
         outAcc,
         outDist,
         outCMF,
         outRVOL,
         outSideways ? 1 : 0,
         outSweepLow ? 1 : 0,
         outSweepHigh ? 1 : 0,
         outSpring ? 1 : 0,
         outUTAD ? 1 : 0,
         outSOS ? 1 : 0,
         outSOW ? 1 : 0,
         outFast,
         outSlow,
         outRangeHigh,
         outRangeLow
    ]


// ============================================================================
// CURRENT TIMEFRAME
// ============================================================================

[
     phase,
     trendScore,
     accumulationScore,
     distributionScore,
     cmf,
     relativeVolume,
     sidewaysInt,
     sweepLowInt,
     sweepHighInt,
     springInt,
     utadInt,
     sosInt,
     sowInt,
     emaFast,
     emaSlow,
     rangeHigh,
     rangeLow
] = f_engine()


sideways = sidewaysInt == 1
sweepLow = sweepLowInt == 1
sweepHigh = sweepHighInt == 1
spring = springInt == 1
utad = utadInt == 1
sos = sosInt == 1
sow = sowInt == 1


// ============================================================================
// EVENT STATE CHANGES
// ============================================================================

springEvent =
     spring and
     not spring[1]

utadEvent =
     utad and
     not utad[1]

sosEvent =
     sos and
     not sos[1]

sowEvent =
     sow and
     not sow[1]

sweepLowEvent =
     sweepLow and
     not sweepLow[1]

sweepHighEvent =
     sweepHigh and
     not sweepHigh[1]


// ============================================================================
// EVENT COOLDOWN
// ============================================================================

var int lastSpringBar = na
var int lastUTADBar = na
var int lastSOSBar = na
var int lastSOWBar = na
var int lastSweepLowBar = na
var int lastSweepHighBar = na


plotSpring =
     springEvent and
     (
         na(lastSpringBar) or
         bar_index - lastSpringBar > eventCooldown
     )

plotUTAD =
     utadEvent and
     (
         na(lastUTADBar) or
         bar_index - lastUTADBar > eventCooldown
     )

plotSOS =
     sosEvent and
     (
         na(lastSOSBar) or
         bar_index - lastSOSBar > eventCooldown
     )

plotSOW =
     sowEvent and
     (
         na(lastSOWBar) or
         bar_index - lastSOWBar > eventCooldown
     )

plotSweepLow =
     sweepLowEvent and
     (
         na(lastSweepLowBar) or
         bar_index - lastSweepLowBar > eventCooldown
     )

plotSweepHigh =
     sweepHighEvent and
     (
         na(lastSweepHighBar) or
         bar_index - lastSweepHighBar > eventCooldown
     )


if plotSpring
    lastSpringBar := bar_index

if plotUTAD
    lastUTADBar := bar_index

if plotSOS
    lastSOSBar := bar_index

if plotSOW
    lastSOWBar := bar_index

if plotSweepLow
    lastSweepLowBar := bar_index

if plotSweepHigh
    lastSweepHighBar := bar_index


phaseChanged =
     phase != phase[1]


// ============================================================================
// BACKGROUND
// ============================================================================

phaseColor =
     f_phaseColor(phase)


regimeColor =
     color.new(
         colorNeutral,
         100
     )


if trendScore >= 30

    regimeColor :=
         color.new(
             colorMarkup,
             regimeBackgroundTransparency
         )

else if trendScore <= -30

    regimeColor :=
         color.new(
             colorMarkdown,
             regimeBackgroundTransparency
         )

else

    regimeColor :=
         color.new(
             colorNeutral,
             97
         )


backgroundColor =
     color.new(
         colorNeutral,
         100
     )


if backgroundMode == "Phase"

    backgroundColor :=
         color.new(
             phaseColor,
             phaseBackgroundTransparency
         )

else if backgroundMode == "Regime"

    backgroundColor := regimeColor


bgcolor(
     backgroundMode == "Off" ?
     na :
     backgroundColor
)


// ============================================================================
// EMA
// ============================================================================

plot(
     showEMA ? emaFast : na,
     "Fast EMA",
     color=fastEMAColor,
     linewidth=fastEMAWidth
)

plot(
     showEMA ? emaSlow : na,
     "Slow EMA",
     color=slowEMAColor,
     linewidth=slowEMAWidth
)


// ============================================================================
// RANGE
// ============================================================================

plot(
     showRange and sideways ?
     rangeHigh :
     na,
     "Range High",
     color=color.new(
         rangeHighColor,
         rangeTransparency
     ),
     style=plot.style_linebr
)

plot(
     showRange and sideways ?
     rangeLow :
     na,
     "Range Low",
     color=color.new(
         rangeLowColor,
         rangeTransparency
     ),
     style=plot.style_linebr
)


// ============================================================================
// WYCKOFF EVENTS
// ============================================================================

plotshape(
     showSpring and plotSpring,
     title="Confirmed Spring",
     text="SPRING",
     style=shape.labelup,
     location=location.belowbar,
     color=springColor,
     textcolor=eventTextColor,
     size=size.tiny
)

plotshape(
     showUTAD and plotUTAD,
     title="Confirmed UTAD",
     text="UTAD",
     style=shape.labeldown,
     location=location.abovebar,
     color=utadColor,
     textcolor=eventTextColor,
     size=size.tiny
)

plotshape(
     showSOS and plotSOS,
     title="SOS",
     text="SOS",
     style=shape.labelup,
     location=location.belowbar,
     color=sosColor,
     textcolor=eventTextColor,
     size=size.tiny
)

plotshape(
     showSOW and plotSOW,
     title="SOW",
     text="SOW",
     style=shape.labeldown,
     location=location.abovebar,
     color=sowColor,
     textcolor=eventTextColor,
     size=size.tiny
)

plotshape(
     showSweeps and plotSweepLow,
     title="Sweep Low",
     text="SWEEP ↓",
     style=shape.labelup,
     location=location.belowbar,
     color=sweepLowColor,
     textcolor=eventTextColor,
     size=size.tiny
)

plotshape(
     showSweeps and plotSweepHigh,
     title="Sweep High",
     text="SWEEP ↑",
     style=shape.labeldown,
     location=location.abovebar,
     color=sweepHighColor,
     textcolor=eventTextColor,
     size=size.tiny
)


// ============================================================================
// PHASE LABELS
// ============================================================================

plotshape(
     showPhaseLabels and phaseChanged and phase == 1,
     title="Accumulation",
     text="ACC",
     style=shape.labelup,
     location=location.belowbar,
     color=colorAccumulation,
     textcolor=color.white
)

plotshape(
     showPhaseLabels and phaseChanged and phase == 2,
     title="Markup",
     text="MARKUP",
     style=shape.labelup,
     location=location.belowbar,
     color=colorMarkup,
     textcolor=color.white
)

plotshape(
     showPhaseLabels and phaseChanged and phase == 3,
     title="Re-Accumulation",
     text="RE-ACC",
     style=shape.labelup,
     location=location.belowbar,
     color=colorReAccumulation,
     textcolor=color.white
)

plotshape(
     showPhaseLabels and phaseChanged and phase == 4,
     title="Distribution",
     text="DIST",
     style=shape.labeldown,
     location=location.abovebar,
     color=colorDistribution,
     textcolor=color.white
)

plotshape(
     showPhaseLabels and phaseChanged and phase == 5,
     title="Markdown",
     text="MARKDOWN",
     style=shape.labeldown,
     location=location.abovebar,
     color=colorMarkdown,
     textcolor=color.white
)

plotshape(
     showPhaseLabels and phaseChanged and phase == 6,
     title="Re-Distribution",
     text="RE-DIST",
     style=shape.labeldown,
     location=location.abovebar,
     color=colorReDistribution,
     textcolor=color.white
)


// ============================================================================
// MTF PRIMARY
// ============================================================================

[
     primaryPhase,
     primaryTrend,
     primaryAcc,
     primaryDist,
     primaryCMF,
     primaryRVOL,
     primaryRange,
     primarySweepLow,
     primarySweepHigh,
     primarySpring,
     primaryUTAD,
     primarySOS,
     primarySOW,
     primaryFast,
     primarySlow,
     primaryRangeHigh,
     primaryRangeLow
] = request.security(
     syminfo.tickerid,
     higherTF,
     f_engine(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)


// ============================================================================
// MTF LOCAL
// ============================================================================

[
     localPhase,
     localTrend,
     localAcc,
     localDist,
     localCMF,
     localRVOL,
     localRange,
     localSweepLow,
     localSweepHigh,
     localSpring,
     localUTAD,
     localSOS,
     localSOW,
     localFast,
     localSlow,
     localRangeHigh,
     localRangeLow
] = request.security(
     syminfo.tickerid,
     localTF,
     f_engine(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)


// ============================================================================
// COMBINED BIAS
// ============================================================================

primaryBull =
     primaryTrend >= 25 or
     primaryPhase == 2 or
     primaryPhase == 3

primaryBear =
     primaryTrend <= -25 or
     primaryPhase == 5 or
     primaryPhase == 6

localBull =
     localTrend >= 25 or
     localPhase == 2 or
     localPhase == 3

localBear =
     localTrend <= -25 or
     localPhase == 4 or
     localPhase == 5 or
     localPhase == 6


string biasName = "NEUTRAL"
int biasScore = 0
color biasColor = colorNeutral


if primaryBull

    if localBull and localDist < 65

        biasName := "BULLISH"
        biasScore := 4
        biasColor := colorMarkup

    else if localBear or localDist >= 65

        biasName := "BULLISH / CAUTION"
        biasScore := 2
        biasColor := colorReAccumulation

    else

        biasName := "BULLISH / CAUTION"
        biasScore := 1
        biasColor := colorReAccumulation


else if primaryBear

    if localBear and localAcc < 65

        biasName := "BEARISH"
        biasScore := -4
        biasColor := colorMarkdown

    else if localBull or localAcc >= 65

        biasName := "BEARISH / CAUTION"
        biasScore := -2
        biasColor := colorDistribution

    else

        biasName := "BEARISH / CAUTION"
        biasScore := -1
        biasColor := colorDistribution


else

    if localBull

        biasName := "NEUTRAL / BULLISH"
        biasScore := 1
        biasColor := colorReAccumulation

    else if localBear

        biasName := "NEUTRAL / BEARISH"
        biasScore := -1
        biasColor := colorDistribution


// ============================================================================
// SMART MTF ALERT ENGINE v2.3
// ============================================================================

// ---------------------------------------------------------------------------
// PRIMARY CONTEXT
// ---------------------------------------------------------------------------

primaryBullishContext =
     primaryPhase == 2 or
     primaryPhase == 3 or
     primaryTrend >= 25

primaryStrongBullishContext =
     primaryPhase == 2 or
     primaryPhase == 3 or
     primaryTrend >= 40

primaryWeakening =
     primaryTrend < 25 or
     primaryDist >= 65 or
     primaryPhase == 4 or
     primaryPhase == 5 or
     primaryPhase == 6


// ---------------------------------------------------------------------------
// LOCAL CONTEXT
// ---------------------------------------------------------------------------

localSOSActive =
     localSOS == 1

localSOWActive =
     localSOW == 1

localBullishStructure =
     localPhase == 2 or
     localPhase == 3 or
     localTrend >= 25

localDistribution =
     localPhase == 4 and
     localDist >= 65

localStrongDistribution =
     localPhase == 4 and
     localDist >= strongDistributionAlertLevel


// ---------------------------------------------------------------------------
// STRONG BULLISH SETUP
// ---------------------------------------------------------------------------

strongBullishSetupRaw =
     enableStrongBullAlert and
     primaryStrongBullishContext and
     (
         localPhase == 2 or
         (
             localPhase == 3 and
             localAcc >= 65
         ) or
         localSOSActive
     ) and
     localDist < 65


strongBullishSetup =
     strongBullishSetupRaw and
     not strongBullishSetupRaw[1]


// ---------------------------------------------------------------------------
// RISK WARNING
// ---------------------------------------------------------------------------

riskWarningRaw =
     enableRiskAlert and
     primaryBullishContext and
     localDistribution


riskWarning =
     riskWarningRaw and
     not riskWarningRaw[1]


// ---------------------------------------------------------------------------
// BEARISH REVERSAL WARNING
// ---------------------------------------------------------------------------

bearishReversalRaw =
     enableBearReversalAlert and
     primaryWeakening and
     localStrongDistribution and
     localSOWActive


bearishReversalWarning =
     bearishReversalRaw and
     not bearishReversalRaw[1]


// ---------------------------------------------------------------------------
// BULLISH RECOVERY
//
// Requires a fresh local SOS after previous local weakness.
// This avoids duplicating ordinary Strong Bullish alerts.
// ---------------------------------------------------------------------------

previousLocalWeakness =
     localDist[1] >= 65 or
     localPhase[1] == 4 or
     localPhase[1] == 6 or
     localTrend[1] <= 0


bullishRecoveryRaw =
     enableBullRecoveryAlert and
     primaryBullishContext and
     localSOSActive and
     localDist < 65 and
     previousLocalWeakness


bullishRecovery =
     bullishRecoveryRaw and
     not bullishRecoveryRaw[1]


// ============================================================================
// SMART ALERT STATUS
// ============================================================================

string smartAlertName = "NONE"
color smartAlertColor = colorNeutral


if bearishReversalWarning

    smartAlertName := "BEARISH REVERSAL"
    smartAlertColor := colorMarkdown

else if riskWarning

    smartAlertName := "RISK WARNING"
    smartAlertColor := colorDistribution

else if bullishRecovery

    smartAlertName := "BULLISH RECOVERY"
    smartAlertColor := colorReAccumulation

else if strongBullishSetup

    smartAlertName := "STRONG BULLISH"
    smartAlertColor := colorMarkup


// ============================================================================
// DASHBOARD
// ============================================================================

var table dashboard =
     table.new(
         dashboardPosition,
         3,
         14,
         frame_color=dashboardBorderColor,
         frame_width=1,
         border_color=dashboardBorderColor,
         border_width=1
     )


dashboardBG =
     color.new(
         dashboardBackground,
         dashboardTransparency
     )


if barstate.islast and showDashboard

    // ------------------------------------------------------------------------
    // HEADER
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         0,
         "MARKET PHASE v2.3",
         bgcolor=dashboardBG,
         text_color=dashboardHeaderColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         0,
         timeframe.period,
         bgcolor=color.new(phaseColor, 10),
         text_color=color.white,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         0,
         f_phaseName(phase),
         bgcolor=color.new(phaseColor, 10),
         text_color=color.white,
         text_size=dashboardTextSize
    )


    // ------------------------------------------------------------------------
    // TREND
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         1,
         "Trend Score",
         bgcolor=dashboardBG,
         text_color=dashboardLabelColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         1,
         str.tostring(trendScore),
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         1,
         f_trendName(trendScore),
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )


    // ------------------------------------------------------------------------
    // ACCUMULATION PRESSURE
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         2,
         "Accum. Pressure",
         bgcolor=dashboardBG,
         text_color=dashboardLabelColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         2,
         str.tostring(accumulationScore) + "/100",
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         2,
         f_pressureName(accumulationScore),
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )


    // ------------------------------------------------------------------------
    // DISTRIBUTION PRESSURE
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         3,
         "Distrib. Pressure",
         bgcolor=dashboardBG,
         text_color=dashboardLabelColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         3,
         str.tostring(distributionScore) + "/100",
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         3,
         f_pressureName(distributionScore),
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )


    // ------------------------------------------------------------------------
    // CMF
    // ------------------------------------------------------------------------

    string flowText = "FLAT"

    if cmf > 0
        flowText := "BUY FLOW"
    else if cmf < 0
        flowText := "SELL FLOW"


    table.cell(
         dashboard,
         0,
         4,
         "CMF",
         bgcolor=dashboardBG,
         text_color=dashboardLabelColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         4,
         str.tostring(cmf, "#.###"),
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         4,
         flowText,
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )


    // ------------------------------------------------------------------------
    // RANGE / RVOL
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         5,
         "Trading Range",
         bgcolor=dashboardBG,
         text_color=dashboardLabelColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         5,
         sideways ? "YES" : "NO",
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         5,
         "RVOL " + str.tostring(relativeVolume, "#.##") + "x",
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )


    // ------------------------------------------------------------------------
    // PRIMARY
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         6,
         higherTF + " PRIMARY",
         bgcolor=dashboardBG,
         text_color=dashboardLabelColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         6,
         f_phaseName(primaryPhase),
         bgcolor=color.new(f_phaseColor(primaryPhase), 10),
         text_color=color.white,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         6,
         "T " + str.tostring(primaryTrend),
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )


    // ------------------------------------------------------------------------
    // PRIMARY PRESSURE
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         7,
         "Primary Acc / Dist",
         bgcolor=dashboardBG,
         text_color=dashboardLabelColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         7,
         str.tostring(primaryAcc),
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         7,
         str.tostring(primaryDist),
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )


    // ------------------------------------------------------------------------
    // LOCAL
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         8,
         localTF + " LOCAL",
         bgcolor=dashboardBG,
         text_color=dashboardLabelColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         8,
         f_phaseName(localPhase),
         bgcolor=color.new(f_phaseColor(localPhase), 10),
         text_color=color.white,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         8,
         "T " + str.tostring(localTrend),
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )


    // ------------------------------------------------------------------------
    // LOCAL PRESSURE
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         9,
         "Local Acc / Dist",
         bgcolor=dashboardBG,
         text_color=dashboardLabelColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         9,
         str.tostring(localAcc),
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         9,
         str.tostring(localDist),
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )


    // ------------------------------------------------------------------------
    // COMBINED BIAS
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         10,
         "COMBINED BIAS",
         bgcolor=dashboardBG,
         text_color=dashboardHeaderColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         10,
         biasName,
         bgcolor=color.new(biasColor, 5),
         text_color=color.white,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         10,
         str.tostring(biasScore),
         bgcolor=color.new(biasColor, 5),
         text_color=color.white,
         text_size=dashboardTextSize
    )


    // ------------------------------------------------------------------------
    // EVENTS
    // ------------------------------------------------------------------------

    string eventsText = ""

    if spring
        eventsText += "SPRING "

    if utad
        eventsText += "UTAD "

    if sos
        eventsText += "SOS "

    if sow
        eventsText += "SOW "

    if eventsText == ""
        eventsText := "—"


    table.cell(
         dashboard,
         0,
         11,
         "EVENTS",
         bgcolor=dashboardBG,
         text_color=dashboardLabelColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         11,
         eventsText,
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         11,
         "",
         bgcolor=dashboardBG
    )


    // ------------------------------------------------------------------------
    // REALTIME MODE
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         12,
         "Realtime Data",
         bgcolor=dashboardBG,
         text_color=dashboardLabelColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         12,
         useConfirmedBars ? "CONFIRMED" : "LIVE",
         bgcolor=dashboardBG,
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         12,
         "",
         bgcolor=dashboardBG
    )


    // ------------------------------------------------------------------------
    // SMART ALERT
    // ------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         13,
         "SMART ALERT",
         bgcolor=dashboardBG,
         text_color=dashboardHeaderColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         1,
         13,
         smartAlertName,
         bgcolor=smartAlertName == "NONE" ?
             dashboardBG :
             color.new(smartAlertColor, 5),
         text_color=dashboardValueColor,
         text_size=dashboardTextSize
    )

    table.cell(
         dashboard,
         2,
         13,
         "",
         bgcolor=dashboardBG
    )


// ============================================================================
// STANDARD ALERTS
// ============================================================================

alertcondition(
     plotSpring,
     "Confirmed Spring",
     "Market Phase Detector v2.3: Confirmed SPRING"
)

alertcondition(
     plotUTAD,
     "Confirmed UTAD",
     "Market Phase Detector v2.3: Confirmed UTAD"
)

alertcondition(
     plotSOS,
     "Sign of Strength",
     "Market Phase Detector v2.3: SOS"
)

alertcondition(
     plotSOW,
     "Sign of Weakness",
     "Market Phase Detector v2.3: SOW"
)

alertcondition(
     phaseChanged and phase == 1,
     "Accumulation",
     "Market Phase Detector v2.3: ACCUMULATION"
)

alertcondition(
     phaseChanged and phase == 2,
     "Markup",
     "Market Phase Detector v2.3: MARKUP"
)

alertcondition(
     phaseChanged and phase == 3,
     "Re-Accumulation",
     "Market Phase Detector v2.3: RE-ACCUMULATION"
)

alertcondition(
     phaseChanged and phase == 4,
     "Distribution",
     "Market Phase Detector v2.3: DISTRIBUTION"
)

alertcondition(
     phaseChanged and phase == 5,
     "Markdown",
     "Market Phase Detector v2.3: MARKDOWN"
)

alertcondition(
     phaseChanged and phase == 6,
     "Re-Distribution",
     "Market Phase Detector v2.3: RE-DISTRIBUTION"
)


// ============================================================================
// SMART MTF ALERTS
// ============================================================================

alertcondition(
     strongBullishSetup,
     "MTF Strong Bullish Setup",
     "MPD v2.3: STRONG BULLISH SETUP — Primary market is bullish and local timeframe confirms strength."
)

alertcondition(
     riskWarning,
     "MTF Risk Warning",
     "MPD v2.3: RISK WARNING — Primary market remains bullish but local timeframe entered Distribution."
)

alertcondition(
     bearishReversalWarning,
     "MTF Bearish Reversal Warning",
     "MPD v2.3: BEARISH REVERSAL WARNING — Strong local Distribution plus SOW and weakening Primary structure."
)

alertcondition(
     bullishRecovery,
     "MTF Bullish Recovery",
     "MPD v2.3: BULLISH RECOVERY — Primary context remains bullish and local timeframe produced SOS after previous weakness."
)
````
