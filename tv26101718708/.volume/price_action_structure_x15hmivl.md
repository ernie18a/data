# Price Action Structure

- url: https://www.tradingview.com/script/x15hmivl-Price-Action-Structure/
- type: indicator
- pine_id: PUB;50948234daea4f7c90ab578188985274
- version: 2.0

## Description

Price Action Structure is an open price-action toolkit designed to help traders read market structure, structural breaks, order block context, premium/discount zones, previous daily and weekly levels, qualified setup conditions, and optional Fair Value Gaps.

This is an indicator, not a strategy. It does not place trades, does not execute orders, and does not produce Strategy Tester results. The tool is designed for chart analysis, market-structure study, and visual context only.

Main modules

1. Market Structure

https://www.tradingview.com/x/92bDiEYh/

The indicator identifies both Internal Structure and Swing Structure.

Internal Structure

Internal Structure uses a shorter pivot length and is designed to show faster short-term structure changes. It can mark:

* Internal BOS
* Internal CHoCH
* Internal CHoCH+

Swing Structure

Swing Structure uses a longer pivot length and is designed to show higher-level market structure. It can mark:

* Swing BOS
* Swing CHoCH
* Swing CHoCH+

Label meaning

BOS means Break of Structure.

A bullish BOS appears when price closes above a confirmed structural high.

A bearish BOS appears when price closes below a confirmed structural low.

CHoCH means Change of Character.

A bullish CHoCH appears when price breaks upward after the previous structure was bearish.

A bearish CHoCH appears when price breaks downward after the previous structure was bullish.

CHoCH+ is a stronger change-of-character label. It appears when the change of character is supported by a stronger structural condition, such as a higher low for bullish context or a lower high for bearish context.

Internal BOS / CHoCH

These labels represent fast structure changes and are useful for short-term market reading.

Swing BOS / CHoCH

These labels represent higher-level structure and are generally more important for broader trend context.

Structure label text

The script includes two label text modes:

Full
Shows labels such as Internal BOS, Swing BOS, Internal CHoCH, and Swing CHoCH.

Short
Shows compact labels such as BOS, S-BOS, CHoCH, and S-CHoCH.

Important note about pivots

Market structure is based on confirmed pivots. Pivots require a selected number of bars to the left and right before they are confirmed. This means structure labels appear only after the pivot has been confirmed. Once a structure break is confirmed on bar close, the break label does not repaint after confirmation.

2. Volumetric Order Blocks

https://www.tradingview.com/x/M5KD4YYy/

The indicator includes optional bullish and bearish order blocks.

Order Blocks are OFF by default.

Bullish Order Block

A bullish order block can be created after an internal bullish structure break.

The script scans the impulse leg and looks for the relevant candle zone that may represent demand context.

Bearish Order Block

A bearish order block can be created after an internal bearish structure break.

The script scans the impulse leg and looks for the relevant candle zone that may represent supply context.

Order Block visual design

Each order block can include:

* Main zone box
* Split buy/sell profile inside the zone
* Optional dashed mid-line
* Optional volume metrics label

The split-profile visual design is intended to give a quick view of how the bar’s volume was distributed inside the order block area.

Important note about volume split

The buy/sell split is an approximation. Pine Script does not provide historical tick-level buy/sell volume split. The script estimates the split from each candle’s close location inside its range and weights it by volume.

This should be understood as a visual approximation, not true bid/ask delta or true order-flow data.

Order Block mitigation

The script supports two mitigation methods:

Close
The order block is removed when price closes beyond the far edge of the zone.

Wick
The order block is removed when any wick moves beyond the far edge of the zone.

Hide Overlap

When enabled, the script avoids drawing overlapping order blocks on the same side. This is useful for keeping the chart clean.

Show Last

Controls how many active bullish and bearish order blocks remain visible on the chart.

Profile Width Bars

Controls the fixed width of the internal buy/sell profile inside the order block. The profile does not stretch with the full order block extension.

OB Body Transparency

Controls the background transparency of order block zones. Higher values make the order block background lighter.

3. Premium / Discount / Equilibrium Zones

https://www.tradingview.com/x/mHTi6FXz/

The indicator includes optional Premium, Discount, and Equilibrium zones.

Premium / Discount Zones are OFF by default.

These zones are based on the active swing range.

Premium

The upper area of the current swing range.

Premium can help users identify where price is relatively high inside the selected swing range.

Discount

The lower area of the current swing range.

Discount can help users identify where price is relatively low inside the selected swing range.

Equilibrium

The middle area of the current swing range.

Equilibrium represents the middle reference area between the premium and discount zones.

Edge Zone Width

Controls the thickness of the Premium and Discount zones.

Equilibrium Half Width

Controls the width of the Equilibrium band around the midpoint.

Important note

Premium / Discount / Equilibrium zones are context tools only. They do not predict reversal or continuation by themselves.

4. Previous Day and Previous Week Levels

https://www.tradingview.com/x/Epwra7CY/

The indicator can display previous daily and weekly high/low levels.

These levels are OFF by default.

Previous Day High / Low

When enabled, the script plots:

* PDH: Previous Day High
* PDL: Previous Day Low

Previous Week High / Low

When enabled, the script plots:

* PWH: Previous Week High
* PWL: Previous Week Low

These levels are useful for identifying prior session liquidity areas, important reference levels, and possible reaction zones.

Daily levels are intended mainly for intraday charts.

Weekly levels are intended mainly for charts below the weekly timeframe.

5. Qualified Buy / Sell Setups

https://www.tradingview.com/x/BD77oOr9/

The indicator includes optional qualified BUY SETUP and SELL SETUP labels.

Buy/Sell Setups are OFF by default.

These are not automatic trade recommendations. They are conditional price-action setup labels based on the script’s structure and order block logic.

BUY SETUP logic

A BUY SETUP can appear when:

* price touches a bullish order block,
* the setup remains valid within the selected setup window,
* internal bullish BOS confirms after the touch,
* optional swing bias and premium/discount filters pass depending on selected setup quality.

SELL SETUP logic

A SELL SETUP can appear when:

* price touches a bearish order block,
* the setup remains valid within the selected setup window,
* internal bearish BOS confirms after the touch,
* optional swing bias and premium/discount filters pass depending on selected setup quality.

Setup Quality

The script includes three setup quality modes:

Strict

Strict mode requires more confirmation. It produces fewer setups but with more filtering.

Balanced

Balanced mode is the recommended middle setting. It allows setups when either the broader swing bias or premium/discount context supports the setup.

Aggressive

Aggressive mode requires less filtering. It produces more setups but can create more false or lower-quality events.

Setup Validity Bars

Controls how many bars are allowed between the order block touch and the internal BOS confirmation.

Signal Size

Controls the size of BUY SETUP and SELL SETUP labels.

Signal Distance From Candle

Uses ATR to place setup labels away from candles for better chart readability.

Important note about setup labels

BUY SETUP and SELL SETUP labels are not guaranteed buy or sell signals. They are visual setup conditions that should be confirmed with the user’s own analysis, market context, and risk management.

6. Fair Value Gap

https://www.tradingview.com/x/bTYyKRUM/

The indicator includes optional Fair Value Gaps.

FVG is OFF by default.

Fair Value Gap definition

A Fair Value Gap is a 3-candle imbalance zone.

Bullish FVG

A bullish FVG forms when the current low is above the high from two bars back.

Bearish FVG

A bearish FVG forms when the current high is below the low from two bars back.

FVG Timeframe

The script can calculate FVGs from:

* the current chart timeframe,
* tick-based timeframes,
* second-based timeframes,
* minute-based timeframes,
* hourly timeframes,
* daily timeframes,
* weekly timeframe,
* monthly and multi-month timeframes.

Availability of tick and second timeframes depends on the symbol and the TradingView plan.

FVG Mitigation Method

The script supports four mitigation methods:

Close
A bullish FVG is mitigated when price closes through its far side. A bearish FVG is mitigated when price closes through its far side.

Wick
A bullish FVG is mitigated when a wick reaches through its far side. A bearish FVG is mitigated when a wick reaches through its far side.

Average
The FVG is mitigated when price reaches the midpoint of the imbalance.

None
The FVG remains visible until removed by the Show Last FVGs limit.

Extend Imbalance

Controls how many bars the FVG box extends to the right.

Volatility Threshold

Filters FVGs by size using ATR.

A value of 0 disables the filter.

For example, 0.25 means the FVG must be at least 0.25 ATR in size.

Show Last FVGs

Controls how many bullish and bearish FVGs remain visible on the chart.

Hide Overlap

When enabled, the script skips new overlapping FVGs on the same side to reduce chart clutter.

Show FVG Label

When enabled, the script displays Bull FVG or Bear FVG text inside the gap.

FVG Transparency

Controls how light or strong the FVG background appears.

7. Quick Guide Section

The indicator includes a Quick Guide group inside settings.

This section contains tooltip explanations for:

* Structure label meaning
* Setup logic meaning
* Fair Value Gap meaning

The goal is to make the indicator easier to understand directly from the settings panel.

8. Alerts

The script includes alert conditions for important structure and setup events.

Market Structure Alerts

* Internal Bullish BOS
* Internal Bullish CHoCH
* Internal Bearish BOS
* Internal Bearish CHoCH
* Swing Bullish BOS
* Swing Bullish CHoCH
* Swing Bearish BOS
* Swing Bearish CHoCH

Order Block Alerts

* Bullish OB Touched
* Bearish OB Touched

Qualified Setup Alerts

* Qualified Buy Setup
* Qualified Sell Setup

Fair Value Gap Alerts

* New Bullish FVG
* New Bearish FVG

Alerts are notifications only. They do not execute trades and should not be treated as financial advice.

How to use the indicator

A practical workflow:

1. Start with Swing Structure to understand the higher-level market direction.
2. Use Internal Structure to monitor faster short-term shifts.
3. Enable Order Blocks if you want supply/demand context.
4. Use Premium / Discount / Equilibrium zones to understand where price is trading inside the active swing range.
5. Enable Previous Day / Week levels if you want session and higher-timeframe reference levels.
6. Enable Fair Value Gaps if you want to study imbalance zones.
7. Enable Qualified Buy/Sell Setups only if you want the script to mark conditional setup labels.
8. Use alerts to monitor selected structure, order block, setup, or FVG events.
9. Combine all signals with your own market context, risk management, and confirmation process.

Recommended visual setup for a clean chart

For a clean default chart:

* Keep Order Blocks OFF unless you need them.
* Keep Buy/Sell Setups OFF unless you are studying setup confirmation.
* Keep FVG OFF unless you are specifically analyzing imbalance zones.
* Use Swing Structure for higher-level context.
* Use Internal Structure for short-term structure.
* Enable Daily / Weekly Levels only when relevant to your timeframe.
* Enable Premium / Discount only when studying the active swing range.

Limitations

This indicator does not predict future price movement.

It does not guarantee profitable trades.

It is not a trading strategy.

It does not place orders.

It does not provide broker execution.

It does not provide true historical bid/ask delta.

The buy/sell volume split inside order blocks is an approximation based on candle close position and volume.

Pivots confirm only after the selected number of bars.

Fair Value Gaps are 3-candle imbalance zones and do not guarantee continuation or reversal.

Buy/Sell Setup labels are conditional setup markers, not automatic trading instructions.

Previous Day and Previous Week levels are reference levels only.

Different markets, symbols, timeframes, and sessions can behave differently.

Users are responsible for their own trade decisions, risk management, and position sizing.

Originality and purpose

Price Action Structure combines multiple price-action tools into one organized workflow:

* internal and swing market structure,
* BOS / CHoCH / CHoCH+ labels,
* optional volumetric order blocks,
* approximated buy/sell split profile inside order blocks,
* premium, discount, and equilibrium zones,
* previous day and previous week levels,
* qualified buy/sell setup logic,
* optional Fair Value Gaps,
* multi-timeframe FVG selection,
* FVG mitigation options,
* alert conditions for key events.

The purpose of the indicator is to provide a clean and customizable price-action map that helps traders study market structure, imbalance, order block context, and setup confirmation in one place.

Educational disclaimer

This script is for educational and chart-analysis purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Users should perform their own analysis and manage risk independently.

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) ADXAE
// Price Action Structure - open price-action toolkit (indicator, not a strategy).
//
// Modules:
//   1) Market structure: Internal and Swing BOS / CHoCH / CHoCH+, plus HH / HL / LH / LL swing points.
//   2) Optional volumetric order blocks with split-profile visual design.
//   3) Premium / Discount / Equilibrium zones.
//   4) Previous Day and Previous Week highs/lows.
//   5) Optional Qualified Buy/Sell Setup signals.
//   6) Optional Fair Value Gaps with selectable timeframe, mitigation method, extension, and volatility threshold.
//
// Honest notes:
//   - Buy/sell split is approximated from each bar's close location in its range,
//     volume weighted. True buy/sell split requires tick data that Pine does not provide historically.
//   - Fair Value Gaps are 3-candle imbalance zones.
//   - Pivots confirm after 'length' bars.
//   - Structure breaks fire on bar close and do not repaint after confirmation.
//   - This indicator provides context and setups. It is not a guaranteed trading system.

//@version=6
indicator("Price Action Structure", overlay=true,
     max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=500)

//----------------------------------------------------------------------
// Groups
//----------------------------------------------------------------------
grpGUIDE = "0) QUICK GUIDE"
grpMS    = "1) MARKET STRUCTURE"
grpOB    = "2) VOLUMETRIC ORDER BLOCKS"
grpPD    = "3) PREMIUM / DISCOUNT"
grpHL    = "4) DAILY / WEEKLY LEVELS"
grpSIG   = "5) QUALIFIED SETUPS"
grpFVG   = "6) FAIR VALUE GAP"

//----------------------------------------------------------------------
// Quick Guide
//----------------------------------------------------------------------
guideInfo = input.string("Read Tooltips", "Structure Label Meaning", options=["Read Tooltips"], group=grpGUIDE,
     tooltip="BOS = Break of Structure. CHoCH = Change of Character. I-BOS / I-CHoCH = internal structure. S-BOS / S-CHoCH = swing structure.")

swingPtInfo = input.string("Read Tooltips", "Swing Point Meaning", options=["Read Tooltips"], group=grpGUIDE,
     tooltip="HH = Higher High, LH = Lower High, HL = Higher Low, LL = Lower Low. Each label compares a confirmed pivot to the previous pivot of the same type. HH and HL use the bullish color, LH and LL use the bearish color.")

setupInfo = input.string("Read Tooltips", "Setup Logic Meaning", options=["Read Tooltips"], group=grpGUIDE,
     tooltip="BUY SETUP appears after price touches a bullish order block and then confirms with an internal bullish BOS. SELL SETUP appears after price touches a bearish order block and then confirms with an internal bearish BOS. Setup Quality controls how strict this confirmation is.")

fvgInfo = input.string("Read Tooltips", "Fair Value Gap Meaning", options=["Read Tooltips"], group=grpGUIDE,
     tooltip="Fair Value Gap is a 3-candle imbalance. Bullish FVG forms when the current low is above the high two bars back. Bearish FVG forms when the current high is below the low two bars back.")

//----------------------------------------------------------------------
// Inputs
//----------------------------------------------------------------------
labelTextMode = input.string("Compact", "Structure Label Text", options=["Full", "Compact", "Short"], group=grpMS,
     tooltip="Full: shows Internal BOS / Swing BOS. Compact: shows I-BOS / S-BOS and I-CHoCH / S-CHoCH for a cleaner chart. Short: shows BOS / S-BOS.")

structureLabelSizeInput = input.string("Small", "Structure Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grpMS,
     tooltip="Controls BOS / CHoCH label size. Small is clearer than Tiny without adding too much clutter.")

structureLineWidth = input.int(1, "Structure Line Width", minval=1, maxval=3, group=grpMS,
     tooltip="Controls the thickness of BOS / CHoCH dashed structure lines.")

showInternal = input.bool(true, "Internal Structure", group=grpMS,
     tooltip="Shows fast short-term structure.")

internalLen = input.int(5, "Internal Pivot Length", minval=2, maxval=20, group=grpMS,
     tooltip="Bars on each side needed to confirm an internal pivot.")

showSwing = input.bool(true, "Swing Structure", group=grpMS,
     tooltip="Shows higher-level structure.")

swingLen = input.int(50, "Swing Pivot Length", minval=10, maxval=200, group=grpMS,
     tooltip="Bars on each side needed to confirm a swing pivot.")

showSwingPoints = input.bool(true, "Swing Points (HH / HL / LH / LL)", group=grpMS,
     tooltip="Labels each confirmed swing pivot. HH = Higher High, LH = Lower High, HL = Higher Low, LL = Lower Low. Uses the Swing Point Length below.")

swingPointLen = input.int(20, "Swing Point Length", minval=2, maxval=100, group=grpMS,
     tooltip="Bars on each side needed to confirm a swing point used for HH / HL / LH / LL labels. Larger = fewer, more significant points.")

swingPointSizeInput = input.string("Normal", "Swing Point Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grpMS,
     tooltip="Controls HH / HL / LH / LL label size. Normal is recommended for better readability.")

bullCol = input.color(#00BCD4, "Bullish", group=grpMS, inline="msc",
     tooltip="Bullish structure and demand color.")

bearCol = input.color(#FF6D00, "Bearish", group=grpMS, inline="msc",
     tooltip="Bearish structure and supply color.")

// Order Blocks are OFF by default as requested
showOB = input.bool(false, "Show Order Blocks", group=grpOB,
     tooltip="Shows bullish and bearish order blocks created after internal structure breaks.")

obShowLast = input.int(3, "Show Last", minval=1, maxval=10, group=grpOB,
     tooltip="Maximum number of active order blocks kept per side.")

obMaxScan = input.int(50, "Max Leg Scan", minval=10, maxval=200, group=grpOB,
     tooltip="Maximum number of bars used to scan the impulse leg and find the order block candle.")

obMitigation = input.string("Close", "Mitigation Method", options=["Close", "Wick"], group=grpOB,
     tooltip="Close: the order block is removed only when price closes beyond its far edge. Wick: any wick beyond the far edge removes it.")

obHideOverlap = input.bool(true, "Hide Overlap", group=grpOB,
     tooltip="Recommended ON. Prevents crowded overlapping OB zones.")

obShowMetrics = input.bool(true, "Show Metrics", group=grpOB,
     tooltip="Shows breaking-leg volume and its share of tracked OB volume.")

obShowMid = input.bool(true, "Show Mid-Line", group=grpOB,
     tooltip="Shows a dashed middle line inside each order block.")

obProfileBars = input.int(18, "Profile Width Bars", minval=4, maxval=80, group=grpOB,
     tooltip="Fixed width of the buy/sell profile inside the order block. It does not stretch as the OB extends.")

obBodyTransparency = input.int(92, "OB Body Transparency", minval=80, maxval=98, group=grpOB,
     tooltip="Higher value = lighter OB background.")

showPD = input.bool(false, "Premium / Discount Zones", group=grpPD,
     tooltip="Shows Premium, Equilibrium, and Discount zones based on the active swing range.")

pdEdge = input.float(0.10, "Edge Zone Width", minval=0.02, maxval=0.30, step=0.01, group=grpPD,
     tooltip="Controls the thickness of Premium and Discount zones.")

pdEq = input.float(0.05, "Equilibrium Half Width", minval=0.01, maxval=0.20, step=0.01, group=grpPD,
     tooltip="Controls the half-width of the Equilibrium band.")

showDaily = input.bool(false, "Previous Day High/Low", group=grpHL,
     tooltip="Shows PDH and PDL from the previous completed day.")

showWeekly = input.bool(false, "Previous Week High/Low", group=grpHL,
     tooltip="Shows PWH and PWL from the previous completed week.")

mtfCol = input.color(#7E57C2, "Level Color", group=grpHL,
     tooltip="Color for previous day and previous week levels.")

// Buy/Sell Setups are OFF by default as requested
showSetups = input.bool(false, "Show Buy/Sell Setups", group=grpSIG,
     tooltip="Shows qualified BUY SETUP and SELL SETUP labels.")

setupQuality = input.string("Balanced", "Setup Quality", options=["Strict", "Balanced", "Aggressive"], group=grpSIG,
     tooltip="Strict: fewer setups. Balanced: recommended. Aggressive: more setups.")

setupWindow = input.int(90, "Setup Validity Bars", minval=1, maxval=200, group=grpSIG,
     tooltip="Bars allowed between OB touch and internal BOS confirmation.")

signalSizeInput = input.string("Small", "Signal Size", options=["Tiny", "Small", "Normal", "Large"], group=grpSIG,
     tooltip="Controls BUY SETUP / SELL SETUP label size.")

signalAtrOffset = input.float(1.00, "Signal Distance From Candle", minval=0.10, maxval=3.00, step=0.10, group=grpSIG,
     tooltip="ATR multiplier used to place setup labels away from candles.")

//----------------------------------------------------------------------
// FVG Inputs
//----------------------------------------------------------------------
showFVG = input.bool(false, "FVG", group=grpFVG, inline="fvgMain",
     tooltip="Shows Fair Value Gaps. A bullish FVG forms when current low is above the high two candles back. A bearish FVG forms when current high is below the low two candles back.")

fvgBullCol = input.color(#80CBC4, "", group=grpFVG, inline="fvgMain")
fvgBearCol = input.color(#E8A2AE, "", group=grpFVG, inline="fvgMain")

fvgMitigation = input.string("Close", "Mitigation Method", options=["Close", "Wick", "Average", "None"], group=grpFVG,
     tooltip="Close: mitigated when price closes through the far side. Wick: mitigated when wick fills the far side. Average: mitigated when price reaches the midpoint. None: keeps the imbalance visible until removed by Show Last limit.")

fvgTimeframeInput = input.string("Chart", "Timeframe",
     options=[
         "Chart",
         "1 tick", "10 ticks", "100 ticks", "1000 ticks",
         "1 second", "5 seconds", "10 seconds", "15 seconds", "30 seconds", "45 seconds",
         "1 minute", "2 minutes", "3 minutes", "5 minutes", "10 minutes", "15 minutes", "30 minutes", "45 minutes", "390 minutes",
         "1 hour", "2 hours", "3 hours", "4 hours", "5 hours", "8 hours", "10 hours", "12 hours", "15 hours", "16 hours",
         "1 day", "3 days", "1 week", "1 month", "3 months", "6 months", "12 months"
     ],
     group=grpFVG,
     tooltip="Chart uses the current chart timeframe. Other selections calculate FVG from the selected timeframe. Tick/second timeframes depend on TradingView symbol and plan availability.")

fvgExtend = input.int(10, "Extend Imbalance", minval=1, maxval=500, group=grpFVG,
     tooltip="Number of bars the imbalance box extends to the right after creation.")

fvgVolThreshold = input.float(0.0, "Volatility Threshold", minval=0.0, step=0.1, group=grpFVG,
     tooltip="Minimum FVG size in ATR units. 0 disables the filter. Example: 0.25 means the gap must be at least 0.25 ATR.")

fvgShowLast = input.int(4, "Show Last FVGs", minval=1, maxval=50, group=grpFVG,
     tooltip="Maximum number of active bullish and bearish FVGs kept on chart.")

fvgHideOverlap = input.bool(true, "Hide Overlap", group=grpFVG,
     tooltip="Skips a new FVG if it overlaps an existing FVG on the same side.")

fvgShowLabel = input.bool(false, "Show FVG Label", group=grpFVG,
     tooltip="Shows Bull FVG / Bear FVG text inside the gap.")

fvgTransparency = input.int(86, "FVG Transparency", minval=70, maxval=98, group=grpFVG,
     tooltip="Higher value = lighter FVG background.")

//----------------------------------------------------------------------
// Helpers
//----------------------------------------------------------------------
f_size(string s) =>
    s == "Tiny" ? size.tiny :
     s == "Small" ? size.small :
     s == "Normal" ? size.normal :
     size.large

sigSize = f_size(signalSizeInput)
structureLabelSize = f_size(structureLabelSizeInput)
swingPtSize = f_size(swingPointSizeInput)

f_delete_line(line ln) =>
    if not na(ln)
        line.delete(ln)

f_delete_label(label lb) =>
    if not na(lb)
        label.delete(lb)

f_structure_text(bool isSwing, bool isChoch, bool isPlus) =>
    string base = isChoch ? isPlus ? "CHoCH+" : "CHoCH" : "BOS"
    labelTextMode == "Full" ? (isSwing ? "Swing " : "Internal ") + base :
     labelTextMode == "Compact" ? (isSwing ? "S-" : "I-") + base :
     (isSwing ? "S-" : "") + base

f_overlaps(array<float> tops, array<float> bots, float top, float bot) =>
    bool hit = false
    if tops.size() > 0
        for i = 0 to tops.size() - 1
            if bot <= tops.get(i) and top >= bots.get(i)
                hit := true
    hit

f_tf(string s) =>
    s == "Chart" ? timeframe.period :
     s == "1 tick" ? "1T" :
     s == "10 ticks" ? "10T" :
     s == "100 ticks" ? "100T" :
     s == "1000 ticks" ? "1000T" :
     s == "1 second" ? "1S" :
     s == "5 seconds" ? "5S" :
     s == "10 seconds" ? "10S" :
     s == "15 seconds" ? "15S" :
     s == "30 seconds" ? "30S" :
     s == "45 seconds" ? "45S" :
     s == "1 minute" ? "1" :
     s == "2 minutes" ? "2" :
     s == "3 minutes" ? "3" :
     s == "5 minutes" ? "5" :
     s == "10 minutes" ? "10" :
     s == "15 minutes" ? "15" :
     s == "30 minutes" ? "30" :
     s == "45 minutes" ? "45" :
     s == "390 minutes" ? "390" :
     s == "1 hour" ? "60" :
     s == "2 hours" ? "120" :
     s == "3 hours" ? "180" :
     s == "4 hours" ? "240" :
     s == "5 hours" ? "300" :
     s == "8 hours" ? "480" :
     s == "10 hours" ? "600" :
     s == "12 hours" ? "720" :
     s == "15 hours" ? "900" :
     s == "16 hours" ? "960" :
     s == "1 day" ? "D" :
     s == "3 days" ? "3D" :
     s == "1 week" ? "W" :
     s == "1 month" ? "M" :
     s == "3 months" ? "3M" :
     s == "6 months" ? "6M" :
     s == "12 months" ? "12M" :
     timeframe.period

//----------------------------------------------------------------------
// Market structure engine
//----------------------------------------------------------------------
f_structure(int len, bool show, string labSize, bool isSwing) =>
    float ph = ta.pivothigh(high, len, len)
    float pl = ta.pivotlow(low, len, len)

    var float lastH = na
    var float prevH = na
    var int   lastHBar = na
    var bool  hBroken = true

    var float lastL = na
    var float prevL = na
    var int   lastLBar = na
    var bool  lBroken = true

    var int trend = 0

    if not na(ph)
        prevH := lastH
        lastH := ph
        lastHBar := bar_index - len
        hBroken := false

    if not na(pl)
        prevL := lastL
        lastL := pl
        lastLBar := bar_index - len
        lBroken := false

    bool bullBreak = not hBroken and not na(lastH) and close > lastH
    bool bearBreak = not lBroken and not na(lastL) and close < lastL

    bool bullChoch = bullBreak and trend == -1
    bool bearChoch = bearBreak and trend == 1

    bool bullPlus = bullChoch and not na(lastL) and not na(prevL) and lastL > prevL
    bool bearPlus = bearChoch and not na(lastH) and not na(prevH) and lastH < prevH

    if bullBreak
        hBroken := true
        trend := 1
        if show
            line.new(lastHBar, lastH, bar_index, lastH, color=bullCol, style=line.style_dashed, width=structureLineWidth)
            label.new(int(math.avg(lastHBar, bar_index)), lastH,
                 f_structure_text(isSwing, bullChoch, bullPlus),
                 style=label.style_label_down,
                 color=color.new(color.white, 100),
                 textcolor=bullCol,
                 size=labSize)

    if bearBreak
        lBroken := true
        trend := -1
        if show
            line.new(lastLBar, lastL, bar_index, lastL, color=bearCol, style=line.style_dashed, width=structureLineWidth)
            label.new(int(math.avg(lastLBar, bar_index)), lastL,
                 f_structure_text(isSwing, bearChoch, bearPlus),
                 style=label.style_label_up,
                 color=color.new(color.white, 100),
                 textcolor=bearCol,
                 size=labSize)

    [bullBreak, bearBreak, bullChoch, bearChoch, lastH, lastL, lastHBar, lastLBar, trend]

[iBull, iBear, iBullCh, iBearCh, iH, iL, iHBar, iLBar, iTrend] =
     f_structure(internalLen, showInternal, structureLabelSize, false)

[sBull, sBear, sBullCh, sBearCh, sH, sL, sHBar, sLBar, sTrend] =
     f_structure(swingLen, showSwing, structureLabelSize, true)

var int swingBias = 0
if sBull
    swingBias := 1
if sBear
    swingBias := -1

//----------------------------------------------------------------------
// Swing points: HH / HL / LH / LL
//----------------------------------------------------------------------
spPH = ta.pivothigh(high, swingPointLen, swingPointLen)
spPL = ta.pivotlow(low, swingPointLen, swingPointLen)

var float spPrevH = na
var float spPrevL = na

if not na(spPH)
    string txt = na(spPrevH) or spPH >= spPrevH ? "HH" : "LH"
    color  c   = txt == "HH" ? bullCol : bearCol
    if showSwingPoints
        label.new(bar_index - swingPointLen, spPH, txt,
             style=label.style_label_down,
             color=color.new(color.white, 100),
             textcolor=c,
             size=swingPtSize)
    spPrevH := spPH

if not na(spPL)
    string txt = na(spPrevL) or spPL <= spPrevL ? "LL" : "HL"
    color  c   = txt == "HL" ? bullCol : bearCol
    if showSwingPoints
        label.new(bar_index - swingPointLen, spPL, txt,
             style=label.style_label_up,
             color=color.new(color.white, 100),
             textcolor=c,
             size=swingPtSize)
    spPrevL := spPL

//----------------------------------------------------------------------
// Volumetric order blocks
//----------------------------------------------------------------------
buyFrac = high == low ? 0.5 : (close - low) / (high - low)

var bullBoxA  = array.new<box>()
var bullBuyA  = array.new<box>()
var bullSellA = array.new<box>()
var bullMidA  = array.new<line>()
var bullLabA  = array.new<label>()
var bullTopA  = array.new<float>()
var bullBotA  = array.new<float>()
var bullVolA  = array.new<float>()
var bullFracA = array.new<float>()

var bearBoxA  = array.new<box>()
var bearBuyA  = array.new<box>()
var bearSellA = array.new<box>()
var bearMidA  = array.new<line>()
var bearLabA  = array.new<label>()
var bearTopA  = array.new<float>()
var bearBotA  = array.new<float>()
var bearVolA  = array.new<float>()
var bearFracA = array.new<float>()

f_delBull(int i) =>
    box.delete(bullBoxA.get(i))
    box.delete(bullBuyA.get(i))
    box.delete(bullSellA.get(i))
    f_delete_line(bullMidA.get(i))
    f_delete_label(bullLabA.get(i))
    bullBoxA.remove(i)
    bullBuyA.remove(i)
    bullSellA.remove(i)
    bullMidA.remove(i)
    bullLabA.remove(i)
    bullTopA.remove(i)
    bullBotA.remove(i)
    bullVolA.remove(i)
    bullFracA.remove(i)

f_delBear(int i) =>
    box.delete(bearBoxA.get(i))
    box.delete(bearBuyA.get(i))
    box.delete(bearSellA.get(i))
    f_delete_line(bearMidA.get(i))
    f_delete_label(bearLabA.get(i))
    bearBoxA.remove(i)
    bearBuyA.remove(i)
    bearSellA.remove(i)
    bearMidA.remove(i)
    bearLabA.remove(i)
    bearTopA.remove(i)
    bearBotA.remove(i)
    bearVolA.remove(i)
    bearFracA.remove(i)

f_legLowOffset(int depth) =>
    int o = 1
    float v = low[1]
    if depth >= 2
        for j = 2 to depth
            if low[j] < v
                v := low[j]
                o := j
    o

f_legHighOffset(int depth) =>
    int o = 1
    float v = high[1]
    if depth >= 2
        for j = 2 to depth
            if high[j] > v
                v := high[j]
                o := j
    o

f_legVolume(int o) =>
    float v = 0.0
    float b = 0.0
    for j = 0 to o
        v += volume[j]
        b += volume[j] * buyFrac[j]
    [v, v > 0 ? b / v : 0.5]

// Create bullish OB
if showOB and iBull
    int depth = na(iLBar) ? internalLen : bar_index - iLBar
    depth := math.max(1, math.min(math.min(depth, obMaxScan), bar_index))
    int o = f_legLowOffset(depth)

    float obTop = math.max(open[o], close[o])
    float obBot = low[o]

    if obTop > obBot and not (obHideOverlap and f_overlaps(bullTopA, bullBotA, obTop, obBot))
        int obLeft = bar_index - o
        [vol, bFrac] = f_legVolume(o)

        box mainB = box.new(obLeft, obTop, bar_index, obBot,
             border_color=color.new(bullCol, 65),
             border_style=line.style_dotted,
             bgcolor=color.new(bullCol, obBodyTransparency))

        box buyB = box.new(obLeft, obTop, obLeft + 1, math.avg(obTop, obBot),
             border_color=color.new(bullCol, 100),
             bgcolor=color.new(bullCol, 28))

        box sellB = box.new(obLeft, math.avg(obTop, obBot), obLeft + 1, obBot,
             border_color=color.new(bearCol, 100),
             bgcolor=color.new(bearCol, 35))

        line midL = obShowMid ?
             line.new(obLeft, math.avg(obTop, obBot), bar_index, math.avg(obTop, obBot),
                  color=color.new(bullCol, 45),
                  style=line.style_dashed) : na

        label metL = obShowMetrics ?
             label.new(obLeft + obProfileBars + 2, math.avg(obTop, obBot), "",
                  style=label.style_label_left,
                  color=color.new(color.white, 100),
                  textcolor=color.new(bullCol, 0),
                  size=size.small) : na

        bullBoxA.push(mainB)
        bullBuyA.push(buyB)
        bullSellA.push(sellB)
        bullMidA.push(midL)
        bullLabA.push(metL)
        bullTopA.push(obTop)
        bullBotA.push(obBot)
        bullVolA.push(vol)
        bullFracA.push(bFrac)

        if bullBoxA.size() > obShowLast
            f_delBull(0)

// Create bearish OB
if showOB and iBear
    int depth = na(iHBar) ? internalLen : bar_index - iHBar
    depth := math.max(1, math.min(math.min(depth, obMaxScan), bar_index))
    int o = f_legHighOffset(depth)

    float obTop = high[o]
    float obBot = math.min(open[o], close[o])

    if obTop > obBot and not (obHideOverlap and f_overlaps(bearTopA, bearBotA, obTop, obBot))
        int obLeft = bar_index - o
        [vol, bFrac] = f_legVolume(o)

        box mainB = box.new(obLeft, obTop, bar_index, obBot,
             border_color=color.new(bearCol, 65),
             border_style=line.style_dotted,
             bgcolor=color.new(bearCol, obBodyTransparency))

        box buyB = box.new(obLeft, obTop, obLeft + 1, math.avg(obTop, obBot),
             border_color=color.new(bullCol, 100),
             bgcolor=color.new(bullCol, 28))

        box sellB = box.new(obLeft, math.avg(obTop, obBot), obLeft + 1, obBot,
             border_color=color.new(bearCol, 100),
             bgcolor=color.new(bearCol, 35))

        line midL = obShowMid ?
             line.new(obLeft, math.avg(obTop, obBot), bar_index, math.avg(obTop, obBot),
                  color=color.new(bearCol, 45),
                  style=line.style_dashed) : na

        label metL = obShowMetrics ?
             label.new(obLeft + obProfileBars + 2, math.avg(obTop, obBot), "",
                  style=label.style_label_left,
                  color=color.new(color.white, 100),
                  textcolor=color.new(bearCol, 0),
                  size=size.small) : na

        bearBoxA.push(mainB)
        bearBuyA.push(buyB)
        bearSellA.push(sellB)
        bearMidA.push(midL)
        bearLabA.push(metL)
        bearTopA.push(obTop)
        bearBotA.push(obBot)
        bearVolA.push(vol)
        bearFracA.push(bFrac)

        if bearBoxA.size() > obShowLast
            f_delBear(0)

// Maintain OB boxes
bool bullTouch = false
bool bearTouch = false

if bullBoxA.size() > 0
    for i = bullBoxA.size() - 1 to 0
        float top = bullTopA.get(i)
        float bot = bullBotA.get(i)
        float midOb = math.avg(top, bot)
        bool dead = obMitigation == "Close" ? close < bot : low < bot

        if dead
            f_delBull(i)
        else
            box mb = bullBoxA.get(i)
            box.set_right(mb, bar_index)

            int lx = box.get_left(mb)
            float fr = bullFracA.get(i)

            int buySpan = math.max(1, math.round(obProfileBars * fr))
            int sellSpan = math.max(1, math.round(obProfileBars * (1.0 - fr)))

            box bb = bullBuyA.get(i)
            box.set_lefttop(bb, lx, top)
            box.set_rightbottom(bb, lx + buySpan, midOb)

            box sb = bullSellA.get(i)
            box.set_lefttop(sb, lx, midOb)
            box.set_rightbottom(sb, lx + sellSpan, bot)

            line ml = bullMidA.get(i)
            if not na(ml)
                line.set_x2(ml, bar_index)

            label lb = bullLabA.get(i)
            if not na(lb)
                label.set_x(lb, lx + obProfileBars + 2)
                label.set_y(lb, midOb)

            if low <= top and low[1] > top
                bullTouch := true

if bearBoxA.size() > 0
    for i = bearBoxA.size() - 1 to 0
        float top = bearTopA.get(i)
        float bot = bearBotA.get(i)
        float midOb = math.avg(top, bot)
        bool dead = obMitigation == "Close" ? close > top : high > top

        if dead
            f_delBear(i)
        else
            box mb = bearBoxA.get(i)
            box.set_right(mb, bar_index)

            int lx = box.get_left(mb)
            float fr = bearFracA.get(i)

            int buySpan = math.max(1, math.round(obProfileBars * fr))
            int sellSpan = math.max(1, math.round(obProfileBars * (1.0 - fr)))

            box bb = bearBuyA.get(i)
            box.set_lefttop(bb, lx, top)
            box.set_rightbottom(bb, lx + buySpan, midOb)

            box sb = bearSellA.get(i)
            box.set_lefttop(sb, lx, midOb)
            box.set_rightbottom(sb, lx + sellSpan, bot)

            line ml = bearMidA.get(i)
            if not na(ml)
                line.set_x2(ml, bar_index)

            label lb = bearLabA.get(i)
            if not na(lb)
                label.set_x(lb, lx + obProfileBars + 2)
                label.set_y(lb, midOb)

            if high >= bot and high[1] < bot
                bearTouch := true

// OB metrics
if obShowMetrics
    float totVol = 0.0

    if bullVolA.size() > 0
        for i = 0 to bullVolA.size() - 1
            totVol += bullVolA.get(i)

    if bearVolA.size() > 0
        for i = 0 to bearVolA.size() - 1
            totVol += bearVolA.get(i)

    if totVol > 0
        if bullLabA.size() > 0
            for i = 0 to bullLabA.size() - 1
                label lb = bullLabA.get(i)
                if not na(lb)
                    float v = bullVolA.get(i)
                    label.set_text(lb, str.tostring(v, format.volume) + " (" + str.tostring(100 * v / totVol, "#") + "%)")

        if bearLabA.size() > 0
            for i = 0 to bearLabA.size() - 1
                label lb = bearLabA.get(i)
                if not na(lb)
                    float v = bearVolA.get(i)
                    label.set_text(lb, str.tostring(v, format.volume) + " (" + str.tostring(100 * v / totVol, "#") + "%)")

//----------------------------------------------------------------------
// Fair Value Gaps
//----------------------------------------------------------------------
fvgTF = f_tf(fvgTimeframeInput)

tfHigh = fvgTimeframeInput == "Chart" ? high : request.security(syminfo.tickerid, fvgTF, high, barmerge.gaps_off, barmerge.lookahead_off)
tfLow  = fvgTimeframeInput == "Chart" ? low  : request.security(syminfo.tickerid, fvgTF, low,  barmerge.gaps_off, barmerge.lookahead_off)
tfAtr  = fvgTimeframeInput == "Chart" ? ta.atr(14) : request.security(syminfo.tickerid, fvgTF, ta.atr(14), barmerge.gaps_off, barmerge.lookahead_off)

var bullFvgBoxA = array.new<box>()
var bullFvgLabA = array.new<label>()
var bullFvgTopA = array.new<float>()
var bullFvgBotA = array.new<float>()

var bearFvgBoxA = array.new<box>()
var bearFvgLabA = array.new<label>()
var bearFvgTopA = array.new<float>()
var bearFvgBotA = array.new<float>()

f_delBullFvg(int i) =>
    box.delete(bullFvgBoxA.get(i))
    f_delete_label(bullFvgLabA.get(i))
    bullFvgBoxA.remove(i)
    bullFvgLabA.remove(i)
    bullFvgTopA.remove(i)
    bullFvgBotA.remove(i)

f_delBearFvg(int i) =>
    box.delete(bearFvgBoxA.get(i))
    f_delete_label(bearFvgLabA.get(i))
    bearFvgBoxA.remove(i)
    bearFvgLabA.remove(i)
    bearFvgTopA.remove(i)
    bearFvgBotA.remove(i)

bool rawBullFVG = showFVG and bar_index >= 2 and tfLow > tfHigh[2]
bool rawBearFVG = showFVG and bar_index >= 2 and tfHigh < tfLow[2]

float bullFvgTop = tfLow
float bullFvgBot = tfHigh[2]
float bearFvgTop = tfLow[2]
float bearFvgBot = tfHigh

bool bullVolPass = fvgVolThreshold <= 0 or (bullFvgTop - bullFvgBot) >= tfAtr * fvgVolThreshold
bool bearVolPass = fvgVolThreshold <= 0 or (bearFvgTop - bearFvgBot) >= tfAtr * fvgVolThreshold

bool bullFVG = rawBullFVG and bullFvgTop > bullFvgBot and bullVolPass
bool bearFVG = rawBearFVG and bearFvgTop > bearFvgBot and bearVolPass

if bullFVG and not (fvgHideOverlap and f_overlaps(bullFvgTopA, bullFvgBotA, bullFvgTop, bullFvgBot))
    box b = box.new(bar_index - 2, bullFvgTop, bar_index + fvgExtend, bullFvgBot,
         border_color=color.new(fvgBullCol, 60),
         bgcolor=color.new(fvgBullCol, fvgTransparency))
    label l = fvgShowLabel ? label.new(bar_index + fvgExtend, math.avg(bullFvgTop, bullFvgBot), "Bull FVG",
         style=label.style_label_left,
         color=color.new(color.white, 100),
         textcolor=fvgBullCol,
         size=size.tiny) : na

    bullFvgBoxA.push(b)
    bullFvgLabA.push(l)
    bullFvgTopA.push(bullFvgTop)
    bullFvgBotA.push(bullFvgBot)

    if bullFvgBoxA.size() > fvgShowLast
        f_delBullFvg(0)

if bearFVG and not (fvgHideOverlap and f_overlaps(bearFvgTopA, bearFvgBotA, bearFvgTop, bearFvgBot))
    box b = box.new(bar_index - 2, bearFvgTop, bar_index + fvgExtend, bearFvgBot,
         border_color=color.new(fvgBearCol, 60),
         bgcolor=color.new(fvgBearCol, fvgTransparency))
    label l = fvgShowLabel ? label.new(bar_index + fvgExtend, math.avg(bearFvgTop, bearFvgBot), "Bear FVG",
         style=label.style_label_left,
         color=color.new(color.white, 100),
         textcolor=fvgBearCol,
         size=size.tiny) : na

    bearFvgBoxA.push(b)
    bearFvgLabA.push(l)
    bearFvgTopA.push(bearFvgTop)
    bearFvgBotA.push(bearFvgBot)

    if bearFvgBoxA.size() > fvgShowLast
        f_delBearFvg(0)

if bullFvgBoxA.size() > 0
    for i = bullFvgBoxA.size() - 1 to 0
        float top = bullFvgTopA.get(i)
        float bot = bullFvgBotA.get(i)
        float avg = math.avg(top, bot)

        bool filled =
             fvgMitigation == "None" ? false :
             fvgMitigation == "Close" ? close < bot :
             fvgMitigation == "Wick" ? low <= bot :
             low <= avg

        if filled
            f_delBullFvg(i)
        else
            box b = bullFvgBoxA.get(i)
            box.set_right(b, bar_index + fvgExtend)

            label l = bullFvgLabA.get(i)
            if not na(l)
                label.set_x(l, bar_index + fvgExtend)
                label.set_y(l, avg)

if bearFvgBoxA.size() > 0
    for i = bearFvgBoxA.size() - 1 to 0
        float top = bearFvgTopA.get(i)
        float bot = bearFvgBotA.get(i)
        float avg = math.avg(top, bot)

        bool filled =
             fvgMitigation == "None" ? false :
             fvgMitigation == "Close" ? close > top :
             fvgMitigation == "Wick" ? high >= top :
             high >= avg

        if filled
            f_delBearFvg(i)
        else
            box b = bearFvgBoxA.get(i)
            box.set_right(b, bar_index + fvgExtend)

            label l = bearFvgLabA.get(i)
            if not na(l)
                label.set_x(l, bar_index + fvgExtend)
                label.set_y(l, avg)

//----------------------------------------------------------------------
// Premium / Discount / Equilibrium
//----------------------------------------------------------------------
var float rTop = na
var float rBot = na
var int   rAnchor = na

if showSwing or showPD or showSetups
    if not na(sH)
        rTop := sH
        rAnchor := sHBar
    if not na(sL)
        rBot := sL
        rAnchor := sLBar

float rng = not na(rTop) and not na(rBot) ? rTop - rBot : na
float mid = not na(rng) ? math.avg(rTop, rBot) : na

bool buyPDPass = not na(mid) and close <= mid
bool sellPDPass = not na(mid) and close >= mid

var box pBox = na
var box eBox = na
var box dBox = na
var label pLab = na
var label eLab = na
var label dLab = na

if showPD and not na(rng) and rng > 0 and not na(rAnchor)
    if na(pBox)
        pBox := box.new(rAnchor, rTop, bar_index, rTop - rng * pdEdge,
             border_color=color.new(bearCol, 70),
             bgcolor=color.new(bearCol, 85))

        eBox := box.new(rAnchor, mid + rng * pdEq, bar_index, mid - rng * pdEq,
             border_color=color.new(color.gray, 80),
             bgcolor=color.new(color.gray, 90))

        dBox := box.new(rAnchor, rBot + rng * pdEdge, bar_index, rBot,
             border_color=color.new(bullCol, 70),
             bgcolor=color.new(bullCol, 85))

        pLab := label.new(bar_index, rTop, "Premium",
             style=label.style_label_down,
             color=color.new(color.white, 100),
             textcolor=color.new(bearCol, 0),
             size=size.small)

        eLab := label.new(bar_index, mid, "Equilibrium",
             style=label.style_label_left,
             color=color.new(color.white, 100),
             textcolor=color.new(color.gray, 0),
             size=size.small)

        dLab := label.new(bar_index, rBot, "Discount",
             style=label.style_label_up,
             color=color.new(color.white, 100),
             textcolor=color.new(bullCol, 0),
             size=size.small)

    box.set_lefttop(pBox, rAnchor, rTop)
    box.set_rightbottom(pBox, bar_index, rTop - rng * pdEdge)

    box.set_lefttop(eBox, rAnchor, mid + rng * pdEq)
    box.set_rightbottom(eBox, bar_index, mid - rng * pdEq)

    box.set_lefttop(dBox, rAnchor, rBot + rng * pdEdge)
    box.set_rightbottom(dBox, bar_index, rBot)

    label.set_xy(pLab, int(math.avg(rAnchor, bar_index)), rTop)
    label.set_xy(eLab, bar_index, mid)
    label.set_xy(dLab, int(math.avg(rAnchor, bar_index)), rBot)

//----------------------------------------------------------------------
// Qualified setup logic
//----------------------------------------------------------------------
var int bullTouchBar = na
var int bearTouchBar = na

if bullTouch
    bullTouchBar := bar_index

if bearTouch
    bearTouchBar := bar_index

bool bullTouchValid = not na(bullTouchBar) and bar_index - bullTouchBar <= setupWindow
bool bearTouchValid = not na(bearTouchBar) and bar_index - bearTouchBar <= setupWindow

bool bullSwingPass = swingBias >= 0
bool bearSwingPass = swingBias <= 0

bool bullConfirm = iBull and not iBullCh
bool bearConfirm = iBear and not iBearCh

bool buyStrict = bullTouchValid and bullConfirm and buyPDPass and bullSwingPass
bool sellStrict = bearTouchValid and bearConfirm and sellPDPass and bearSwingPass

bool buyBalanced = bullTouchValid and bullConfirm and (bullSwingPass or buyPDPass)
bool sellBalanced = bearTouchValid and bearConfirm and (bearSwingPass or sellPDPass)

bool buyAggressive = bullTouchValid and bullConfirm
bool sellAggressive = bearTouchValid and bearConfirm

bool buySetup =
     showSetups and (
         setupQuality == "Strict" ? buyStrict :
         setupQuality == "Balanced" ? buyBalanced :
         buyAggressive)

bool sellSetup =
     showSetups and (
         setupQuality == "Strict" ? sellStrict :
         setupQuality == "Balanced" ? sellBalanced :
         sellAggressive)

if buySetup
    bullTouchBar := na

if sellSetup
    bearTouchBar := na

atr = ta.atr(14)

if buySetup
    label.new(bar_index, low - atr * signalAtrOffset, "BUY\nSETUP",
         style=label.style_label_up,
         color=color.new(color.green, 0),
         textcolor=color.white,
         size=sigSize)

if sellSetup
    label.new(bar_index, high + atr * signalAtrOffset, "SELL\nSETUP",
         style=label.style_label_down,
         color=color.new(color.red, 0),
         textcolor=color.white,
         size=sigSize)

//----------------------------------------------------------------------
// Previous Day / Week levels
//----------------------------------------------------------------------
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_on)

dailyOk  = timeframe.in_seconds() < timeframe.in_seconds("1D")
weeklyOk = timeframe.in_seconds() < timeframe.in_seconds("1W")

f_level(line ln, label lb, float y, string txt) =>
    line l = ln
    label b = lb

    if na(l)
        l := line.new(bar_index - 30, y, bar_index + 8, y,
             color=mtfCol,
             width=1)

        b := label.new(bar_index + 8, y, txt,
             style=label.style_label_left,
             color=color.new(color.white, 100),
             textcolor=mtfCol,
             size=size.tiny)

    line.set_xy1(l, bar_index - 30, y)
    line.set_xy2(l, bar_index + 8, y)
    label.set_xy(b, bar_index + 8, y)

    [l, b]

var line  pdhLn = na
var label pdhLb = na
var line  pdlLn = na
var label pdlLb = na
var line  pwhLn = na
var label pwhLb = na
var line  pwlLn = na
var label pwlLb = na

if barstate.islast and showDaily and dailyOk
    [l1, b1] = f_level(pdhLn, pdhLb, pdh, "PDH")
    pdhLn := l1
    pdhLb := b1

    [l2, b2] = f_level(pdlLn, pdlLb, pdl, "PDL")
    pdlLn := l2
    pdlLb := b2

if barstate.islast and showWeekly and weeklyOk
    [l3, b3] = f_level(pwhLn, pwhLb, pwh, "PWH")
    pwhLn := l3
    pwhLb := b3

    [l4, b4] = f_level(pwlLn, pwlLb, pwl, "PWL")
    pwlLn := l4
    pwlLb := b4

//----------------------------------------------------------------------
// Alerts
//----------------------------------------------------------------------
alertcondition(iBull and not iBullCh, "Internal Bullish BOS", "Price Action Structure: internal bullish BOS")
alertcondition(iBullCh, "Internal Bullish CHoCH", "Price Action Structure: internal bullish CHoCH")
alertcondition(iBear and not iBearCh, "Internal Bearish BOS", "Price Action Structure: internal bearish BOS")
alertcondition(iBearCh, "Internal Bearish CHoCH", "Price Action Structure: internal bearish CHoCH")

alertcondition(sBull and not sBullCh, "Swing Bullish BOS", "Price Action Structure: swing bullish BOS")
alertcondition(sBullCh, "Swing Bullish CHoCH", "Price Action Structure: swing bullish CHoCH")
alertcondition(sBear and not sBearCh, "Swing Bearish BOS", "Price Action Structure: swing bearish BOS")
alertcondition(sBearCh, "Swing Bearish CHoCH", "Price Action Structure: swing bearish CHoCH")

alertcondition(bullTouch, "Bullish OB Touched", "Price Action Structure: price entered a bullish order block")
alertcondition(bearTouch, "Bearish OB Touched", "Price Action Structure: price entered a bearish order block")

alertcondition(buySetup, "Qualified Buy Setup", "Price Action Structure: qualified BUY SETUP confirmed")
alertcondition(sellSetup, "Qualified Sell Setup", "Price Action Structure: qualified SELL SETUP confirmed")

alertcondition(bullFVG, "New Bullish FVG", "Price Action Structure: new bullish Fair Value Gap")
alertcondition(bearFVG, "New Bearish FVG", "Price Action Structure: new bearish Fair Value Gap")
````
