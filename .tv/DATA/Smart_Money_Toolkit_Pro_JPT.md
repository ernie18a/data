<!-- tradingview-pine-id: PUB;bd10604b26364db58808b9155a29c611 -->
<!-- tradingviewscripts-format: 1 -->
# Smart Money Toolkit Pro [JPT]

Source: https://www.tradingview.com/script/9DQV8v4R-Smart-Money-Toolkit-Pro-JPT/

## Description

🔷 OVERVIEW

Smart Money Toolkit Pro [JPT] is an original Pine Script® v6 indicator that combines multiple Smart Money Concepts (SMC) into one clean and powerful trading tool. It automatically detects market structure, Break of Structure (BOS), Change of Character (CHoCH), liquidity levels, liquidity sweeps, and dynamic support/resistance to help traders analyze price action with confidence.

Designed for Forex, Gold (XAUUSD), Crypto, Stocks, Indices, and Futures, the indicator provides a clear visual representation of institutional market behavior without requiring manual chart drawing.

🔷 HOW IT WORKS

The indicator continuously scans price using confirmed pivot highs and lows.

Market Structure

The script automatically identifies:

• Higher High (HH)

• Higher Low (HL)

• Lower High (LH)

• Lower Low (LL)

These labels help traders understand whether the market is trending, ranging, or reversing.

Break of Structure (BOS)

A BOS is generated when price closes beyond a previous confirmed swing in the direction of the current trend.

Bullish BOS

Price breaks above a previous Swing High.

Bearish BOS

Price breaks below a previous Swing Low.
Change of Character (CHoCH)

A CHoCH signals a potential shift in market direction.

Bullish CHoCH

Price breaks above the previous Lower High.

Bearish CHoCH

Price breaks below the previous Higher Low.

This helps traders recognize possible trend reversals early.

Liquidity Engine

The built-in liquidity engine automatically plots:

• Buy-Side Liquidity (BSL)

• Sell-Side Liquidity (SSL)

• Equal Highs (EQH)

• Equal Lows (EQL)

The indicator monitors these areas for liquidity grabs and sweep events commonly associated with institutional trading activity.

Liquidity Sweeps

The script detects:

• Buy-Side Liquidity Sweeps

• Sell-Side Liquidity Sweeps

When a sweep occurs, the indicator marks the event directly on the chart, allowing traders to identify potential reversal opportunities.

🔷 VISUAL FEATURES

• Automatic Market Structure Labels (HH, HL, LH, LL)

• Break of Structure (BOS)

• Change of Character (CHoCH)

• Buy-Side Liquidity (BSL)

• Sell-Side Liquidity (SSL)

• Equal High Detection

• Equal Low Detection

• Liquidity Sweep Detection

• Dynamic Swing High & Low Levels

• Trend Background Coloring

• Liquidity Dashboard

• Trend Dashboard

• Professional Chart Layout

• Customizable Colors

🔷 DASHBOARD

The built-in dashboard displays:

• Current Trend

• Last Confirmed High

• Last Confirmed Low

• Active Buy-Side Liquidity

• Active Sell-Side Liquidity

• Latest Liquidity Event

This provides a quick overview of current market conditions.

🔷 INPUTS

Available settings include:

• Pivot Strength

• Show Structure Labels

• Show Swing Levels

• Extend Swing Levels

• Show BOS

• Show CHoCH

• Show Liquidity

• Show Liquidity Sweeps

• Show Equal High / Low

• ATR Tolerance

• Maximum Historical Liquidity Levels

• Bullish Color

• Bearish Color

• Liquidity Colors

🔷 ALERTS

Built-in alerts are available for:

• Bullish BOS

• Bearish BOS

• Bullish CHoCH

• Bearish CHoCH

• Buy-Side Liquidity Sweep

• Sell-Side Liquidity Sweep

Alerts can be connected directly to TradingView's notification system.

🔷 COMMON WORKFLOW

A typical workflow is:

Wait for confirmed market structure (HH, HL, LH, LL).
Observe BOS or CHoCH confirmation.
Monitor Buy-Side and Sell-Side Liquidity levels.
Watch for liquidity sweeps around key swing points.
Combine confirmations with your preferred entry strategy and risk management.
🔷 MARKETS

Smart Money Toolkit Pro [JPT] can be used on:

• Forex

• Gold (XAUUSD)

• Silver (XAGUSD)

• Cryptocurrency

• Stocks

• Indices

• Futures

• Commodities

Compatible with all TradingView-supported timeframes.

🔷 BEST PRACTICES

For additional confirmation, many traders combine this indicator with:

• Support & Resistance

• Supply & Demand Zones

• Order Blocks

• Fair Value Gaps (FVG)

• Fibonacci Retracement

• EMA 50 / EMA 200 Trend Filter

• Volume Analysis

• Higher Timeframe Confirmation

These concepts are optional but can enhance decision-making when used alongside market structure.

🔷 UPCOMING FEATURES

Future updates may include:

• Institutional Order Blocks

• Fair Value Gap (FVG) Detection

• Premium & Discount Zones

• Auto Fibonacci Retracement

• Multi-Timeframe Market Structure

• Entry & Exit Signals

• TP1, TP2, TP3 Auto Targets

• Stop Loss Calculation

• Risk/Reward Visualization

• Advanced Smart Money Dashboard

• Session Analysis

• Volume Confirmation

🔷 DISCLAIMER

This indicator is provided for educational and informational purposes only. It highlights market structure and liquidity concepts based on historical price action and does not predict future market movements or guarantee trading performance. Always conduct your own analysis, use proper risk management, and consider additional market factors before making trading decisions.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Smart Money Toolkit Pro [JPT]", shorttitle="SMT Pro", overlay=true, max_lines_count=500, max_labels_count=500)

//══════════════════════════════════════════════
// INPUTS
//══════════════════════════════════════════════
pivotLen      = input.int(8, "Pivot Strength", minval=2)
showLabels    = input.bool(true, "Show Structure Labels")
showSwings    = input.bool(true, "Show Swing Levels")
extendLevels  = input.bool(true, "Extend Swing Levels")
showTrendBG   = input.bool(true, "Trend Background")

bullColor = input.color(color.lime, "Bullish Color")
bearColor = input.color(color.red, "Bearish Color")

//══════════════════════════════════════════════
// PIVOT DETECTION
//══════════════════════════════════════════════
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float lastLow = na

var int lastHighBar = na
var int lastLowBar = na

if not na(ph)
    lastHigh := ph
    lastHighBar := bar_index - pivotLen

if not na(pl)
    lastLow := pl
    lastLowBar := bar_index - pivotLen

//══════════════════════════════════════════════
// MARKET STRUCTURE
//══════════════════════════════════════════════
var float prevHigh = na
var float prevLow = na

string highType = ""
string lowType = ""

if not na(ph)

    highType := na(prevHigh) ? "H" : ph > prevHigh ? "HH" : "LH"
    prevHigh := ph

if not na(pl)

    lowType := na(prevLow) ? "L" : pl > prevLow ? "HL" : "LL"
    prevLow := pl

//══════════════════════════════════════════════
// STRUCTURE LABELS
//══════════════════════════════════════════════
if showLabels

    if not na(ph)

        label.new(
             lastHighBar,
             lastHigh,
             highType,
             style=label.style_label_down,
             color=highType=="HH"?bullColor:bearColor,
             textcolor=color.white)

    if not na(pl)

        label.new(
             lastLowBar,
             lastLow,
             lowType,
             style=label.style_label_up,
             color=lowType=="HL"?bullColor:bearColor,
             textcolor=color.white)

//══════════════════════════════════════════════
// SWING LEVELS
//══════════════════════════════════════════════
var line highLine = na
var line lowLine = na

if showSwings

    if not na(ph)

        line.delete(highLine)

        highLine := line.new(
             lastHighBar,
             lastHigh,
             bar_index,
             lastHigh,
             extend=extendLevels?extend.right:extend.none,
             color=bearColor,
             width=2)

    if not na(pl)

        line.delete(lowLine)

        lowLine := line.new(
             lastLowBar,
             lastLow,
             bar_index,
             lastLow,
             extend=extendLevels?extend.right:extend.none,
             color=bullColor,
             width=2)

//══════════════════════════════════════════════
// TREND STATE
//══════════════════════════════════════════════
bool bullish = false

if not na(lastHighBar) and not na(lastLowBar)
    bullish := lastLowBar > lastHighBar

bgcolor(showTrendBG ? (bullish ? color.new(bullColor,92) : color.new(bearColor,92)) : na)

//══════════════════════════════════════════════
// INFO TABLE
//══════════════════════════════════════════════
var table dash = table.new(position.top_right,2,3)

if barstate.islast

    table.cell(dash,0,0,"Trend")
    table.cell(dash,1,0,bullish?"Bullish":"Bearish")

    table.cell(dash,0,1,"Last High")
    table.cell(dash,1,1,str.tostring(lastHigh,format.mintick))

    table.cell(dash,0,2,"Last Low")
    table.cell(dash,1,2,str.tostring(lastLow,format.mintick))

//══════════════════════════════════════════════
// PART 2 : BOS & CHoCH ENGINE
//══════════════════════════════════════════════

// User Inputs
showBOS = input.bool(true, "Show BOS")
showCHoCH = input.bool(true, "Show CHoCH")

// Structure State
var bool trendBull = bullish

bosBull = false
bosBear = false
chochBull = false
chochBear = false

// Bullish BOS
if not na(lastHigh)
    bosBull := ta.crossover(close, lastHigh) and trendBull

// Bearish BOS
if not na(lastLow)
    bosBear := ta.crossunder(close, lastLow) and not trendBull

// CHoCH
if not na(lastHigh)
    chochBull := ta.crossover(close, lastHigh) and not trendBull

if not na(lastLow)
    chochBear := ta.crossunder(close, lastLow) and trendBull

// Update Trend
if chochBull
    trendBull := true

if chochBear
    trendBull := false

//══════════════════════════════════════════════
// BOS / CHoCH LINES
//══════════════════════════════════════════════

var line bosLine = na

if bosBull and showBOS
    line.delete(bosLine)
    bosLine := line.new(
         lastHighBar,
         lastHigh,
         bar_index,
         lastHigh,
         color=color.lime,
         width=2)

if bosBear and showBOS
    line.delete(bosLine)
    bosLine := line.new(
         lastLowBar,
         lastLow,
         bar_index,
         lastLow,
         color=color.red,
         width=2)

if chochBull and showCHoCH
    line.new(
         lastHighBar,
         lastHigh,
         bar_index,
         lastHigh,
         color=color.aqua,
         style=line.style_dashed,
         width=2)

if chochBear and showCHoCH
    line.new(
         lastLowBar,
         lastLow,
         bar_index,
         lastLow,
         color=color.orange,
         style=line.style_dashed,
         width=2)

//══════════════════════════════════════════════
// LABELS
//══════════════════════════════════════════════

if bosBull and showBOS
    label.new(
         bar_index,
         high,
         "BOS",
         style=label.style_label_down,
         color=color.lime,
         textcolor=color.black)

if bosBear and showBOS
    label.new(
         bar_index,
         low,
         "BOS",
         style=label.style_label_up,
         color=color.red,
         textcolor=color.white)

if chochBull and showCHoCH
    label.new(
         bar_index,
         high,
         "CHoCH",
         style=label.style_label_down,
         color=color.aqua,
         textcolor=color.black)

if chochBear and showCHoCH
    label.new(
         bar_index,
         low,
         "CHoCH",
         style=label.style_label_up,
         color=color.orange,
         textcolor=color.black)

//══════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════

alertcondition(bosBull, "Bullish BOS", "Bullish Break of Structure")

alertcondition(bosBear, "Bearish BOS", "Bearish Break of Structure")

alertcondition(chochBull, "Bullish CHoCH", "Bullish Change of Character")

alertcondition(chochBear, "Bearish CHoCH", "Bearish Change of Character")

//══════════════════════════════════════════════
// PART 3 : LIQUIDITY ENGINE
// BSL / SSL + EQH / EQL + LIQUIDITY SWEEPS
//══════════════════════════════════════════════

//──────────────────────────────────────────────
// LIQUIDITY INPUTS
//──────────────────────────────────────────────

groupLiquidity = "Liquidity Engine"

showLiquidity = input.bool(true, "Show Liquidity Levels", group=groupLiquidity)
showSweeps    = input.bool(true, "Show Liquidity Sweeps", group=groupLiquidity)
showEqualHL   = input.bool(true, "Show Equal High / Low", group=groupLiquidity)

liquidityExtend = input.bool(true, "Extend Liquidity Levels", group=groupLiquidity)

eqToleranceATR = input.float(
     0.10,
     "Equal High/Low ATR Tolerance",
     minval=0.01,
     maxval=1.00,
     step=0.01,
     group=groupLiquidity)

liqLineWidth = input.int(
     1,
     "Liquidity Line Width",
     minval=1,
     maxval=4,
     group=groupLiquidity)

maxLiquidityHistory = input.int(
     20,
     "Maximum Historical Liquidity Levels",
     minval=2,
     maxval=100,
     group=groupLiquidity)

//──────────────────────────────────────────────
// LIQUIDITY COLORS
//──────────────────────────────────────────────

bslColor = input.color(
     color.fuchsia,
     "Buy-Side Liquidity Color",
     group=groupLiquidity)

sslColor = input.color(
     color.aqua,
     "Sell-Side Liquidity Color",
     group=groupLiquidity)

sweepBullColor = input.color(
     color.lime,
     "Bullish Sweep Color",
     group=groupLiquidity)

sweepBearColor = input.color(
     color.red,
     "Bearish Sweep Color",
     group=groupLiquidity)

//──────────────────────────────────────────────
// ATR TOLERANCE
//──────────────────────────────────────────────

liqATR = ta.atr(14)

equalTolerance = liqATR * eqToleranceATR

//──────────────────────────────────────────────
// PREVIOUS CONFIRMED SWINGS
//──────────────────────────────────────────────

var float liquidityPreviousHigh = na
var float liquidityPreviousLow = na

var int liquidityPreviousHighBar = na
var int liquidityPreviousLowBar = na

//──────────────────────────────────────────────
// ACTIVE LIQUIDITY LEVELS
//──────────────────────────────────────────────

var float activeBSL = na
var float activeSSL = na

var int activeBSLBar = na
var int activeSSLBar = na

var bool bslAvailable = false
var bool sslAvailable = false

//──────────────────────────────────────────────
// ACTIVE LINES
//──────────────────────────────────────────────

var line activeBSLLine = na
var line activeSSLLine = na

//──────────────────────────────────────────────
// HISTORICAL LINE STORAGE
//──────────────────────────────────────────────

var array<line> liquidityLines = array.new<line>()

//──────────────────────────────────────────────
// STORE LIQUIDITY LINE FUNCTION
//──────────────────────────────────────────────

storeLiquidityLine(line newLine) =>

    array.push(liquidityLines, newLine)

    if array.size(liquidityLines) > maxLiquidityHistory

        line oldestLine = array.shift(liquidityLines)

        if not na(oldestLine)
            line.delete(oldestLine)

//══════════════════════════════════════════════
// BUY-SIDE LIQUIDITY
//══════════════════════════════════════════════

if not na(ph)

    float currentHigh = ph
    int currentHighBar = bar_index - pivotLen

    //──────────────────────────────────────────
    // EQUAL HIGH DETECTION
    //──────────────────────────────────────────

    bool equalHigh = false

    if not na(liquidityPreviousHigh)

        equalHigh :=
             math.abs(
                  currentHigh -
                  liquidityPreviousHigh
             ) <= equalTolerance

    //──────────────────────────────────────────
    // CREATE BSL LEVEL
    //──────────────────────────────────────────

    if showLiquidity

        activeBSL := currentHigh
        activeBSLBar := currentHighBar

        bslAvailable := true

        if not na(activeBSLLine)
            line.delete(activeBSLLine)

        activeBSLLine := line.new(
             x1=activeBSLBar,
             y1=activeBSL,
             x2=bar_index,
             y2=activeBSL,
             extend=liquidityExtend ? extend.right : extend.none,
             color=bslColor,
             style=line.style_dotted,
             width=liqLineWidth)

    //──────────────────────────────────────────
    // EQUAL HIGH VISUAL
    //──────────────────────────────────────────

    if equalHigh and showEqualHL

        float eqHighPrice =
             (
                  currentHigh +
                  liquidityPreviousHigh
             ) / 2.0

        line eqHighLine = line.new(
             x1=liquidityPreviousHighBar,
             y1=eqHighPrice,
             x2=currentHighBar,
             y2=eqHighPrice,
             color=bslColor,
             width=2,
             style=line.style_dashed)

        storeLiquidityLine(eqHighLine)

        label.new(
             x=currentHighBar,
             y=currentHigh,
             text="EQH\nBSL",
             style=label.style_label_down,
             color=color.new(bslColor, 10),
             textcolor=color.white,
             size=size.tiny)

    liquidityPreviousHigh := currentHigh
    liquidityPreviousHighBar := currentHighBar

//══════════════════════════════════════════════
// SELL-SIDE LIQUIDITY
//══════════════════════════════════════════════

if not na(pl)

    float currentLow = pl
    int currentLowBar = bar_index - pivotLen

    //──────────────────────────────────────────
    // EQUAL LOW DETECTION
    //──────────────────────────────────────────

    bool equalLow = false

    if not na(liquidityPreviousLow)

        equalLow :=
             math.abs(
                  currentLow -
                  liquidityPreviousLow
             ) <= equalTolerance

    //──────────────────────────────────────────
    // CREATE SSL LEVEL
    //──────────────────────────────────────────

    if showLiquidity

        activeSSL := currentLow
        activeSSLBar := currentLowBar

        sslAvailable := true

        if not na(activeSSLLine)
            line.delete(activeSSLLine)

        activeSSLLine := line.new(
             x1=activeSSLBar,
             y1=activeSSL,
             x2=bar_index,
             y2=activeSSL,
             extend=liquidityExtend ? extend.right : extend.none,
             color=sslColor,
             style=line.style_dotted,
             width=liqLineWidth)

    //──────────────────────────────────────────
    // EQUAL LOW VISUAL
    //──────────────────────────────────────────

    if equalLow and showEqualHL

        float eqLowPrice =
             (
                  currentLow +
                  liquidityPreviousLow
             ) / 2.0

        line eqLowLine = line.new(
             x1=liquidityPreviousLowBar,
             y1=eqLowPrice,
             x2=currentLowBar,
             y2=eqLowPrice,
             color=sslColor,
             width=2,
             style=line.style_dashed)

        storeLiquidityLine(eqLowLine)

        label.new(
             x=currentLowBar,
             y=currentLow,
             text="EQL\nSSL",
             style=label.style_label_up,
             color=color.new(sslColor, 10),
             textcolor=color.black,
             size=size.tiny)

    liquidityPreviousLow := currentLow
    liquidityPreviousLowBar := currentLowBar

//══════════════════════════════════════════════
// LIQUIDITY SWEEP DETECTION
//══════════════════════════════════════════════

// Buy-Side Sweep:
//
// Wick trades ABOVE previous swing high,
// but candle CLOSES back below liquidity.
//
bool buySideSweep = false

if (
     showSweeps and
     bslAvailable and
     not na(activeBSL) and
     bar_index > activeBSLBar
)

    buySideSweep :=
         high > activeBSL and
         close < activeBSL

//──────────────────────────────────────────────
// Sell-Side Sweep
//
// Wick trades BELOW previous swing low,
// but candle CLOSES back above liquidity.
//──────────────────────────────────────────────

bool sellSideSweep = false

if (
     showSweeps and
     sslAvailable and
     not na(activeSSL) and
     bar_index > activeSSLBar
)

    sellSideSweep :=
         low < activeSSL and
         close > activeSSL

//══════════════════════════════════════════════
// BUY-SIDE LIQUIDITY GRAB
//══════════════════════════════════════════════

if buySideSweep

    label.new(
         x=bar_index,
         y=high,
         text="BSL SWEEP\n▼",
         style=label.style_label_down,
         color=sweepBearColor,
         textcolor=color.white,
         size=size.small)

    if not na(activeBSLLine)

        line.set_x2(
             activeBSLLine,
             bar_index)

        line.set_extend(
             activeBSLLine,
             extend.none)

        line.set_style(
             activeBSLLine,
             line.style_dashed)

        line.set_color(
             activeBSLLine,
             sweepBearColor)

        storeLiquidityLine(activeBSLLine)

        activeBSLLine := na

    bslAvailable := false

//══════════════════════════════════════════════
// SELL-SIDE LIQUIDITY GRAB
//══════════════════════════════════════════════

if sellSideSweep

    label.new(
         x=bar_index,
         y=low,
         text="SSL SWEEP\n▲",
         style=label.style_label_up,
         color=sweepBullColor,
         textcolor=color.black,
         size=size.small)

    if not na(activeSSLLine)

        line.set_x2(
             activeSSLLine,
             bar_index)

        line.set_extend(
             activeSSLLine,
             extend.none)

        line.set_style(
             activeSSLLine,
             line.style_dashed)

        line.set_color(
             activeSSLLine,
             sweepBullColor)

        storeLiquidityLine(activeSSLLine)

        activeSSLLine := na

    sslAvailable := false

//══════════════════════════════════════════════
// SWEEP MARKERS
//══════════════════════════════════════════════

plotshape(
     buySideSweep,
     title="Buy-Side Liquidity Sweep",
     style=shape.triangledown,
     location=location.abovebar,
     color=sweepBearColor,
     size=size.tiny)

plotshape(
     sellSideSweep,
     title="Sell-Side Liquidity Sweep",
     style=shape.triangleup,
     location=location.belowbar,
     color=sweepBullColor,
     size=size.tiny)

//══════════════════════════════════════════════
// LIQUIDITY ALERTS
//══════════════════════════════════════════════

alertcondition(
     buySideSweep,
     title="Buy-Side Liquidity Sweep",
     message="Smart Money Toolkit Pro [JPT]: Buy-Side Liquidity Sweep detected.")

alertcondition(
     sellSideSweep,
     title="Sell-Side Liquidity Sweep",
     message="Smart Money Toolkit Pro [JPT]: Sell-Side Liquidity Sweep detected.")

//══════════════════════════════════════════════
// LIQUIDITY DASHBOARD UPDATE
//══════════════════════════════════════════════

// Optional additional dashboard.
//
// Separate table is used so Part 1 dashboard
// does not need to be modified.

var table liquidityDashboard =
     table.new(
          position.bottom_right,
          2,
          4,
          border_width=1)

if barstate.islast

    table.cell(
         liquidityDashboard,
         0,
         0,
         "LIQUIDITY")

    table.cell(
         liquidityDashboard,
         1,
         0,
         "STATUS")

    table.cell(
         liquidityDashboard,
         0,
         1,
         "BSL")

    table.cell(
         liquidityDashboard,
         1,
         1,
         bslAvailable
             ? str.tostring(activeBSL, format.mintick)
             : "Swept / Waiting")

    table.cell(
         liquidityDashboard,
         0,
         2,
         "SSL")

    table.cell(
         liquidityDashboard,
         1,
         2,
         sslAvailable
             ? str.tostring(activeSSL, format.mintick)
             : "Swept / Waiting")

    table.cell(
         liquidityDashboard,
         0,
         3,
         "Last Event")

    table.cell(
         liquidityDashboard,
         1,
         3,
         buySideSweep
             ? "BSL Sweep"
             : sellSideSweep
                 ? "SSL Sweep"
                 : "Monitoring")
````
