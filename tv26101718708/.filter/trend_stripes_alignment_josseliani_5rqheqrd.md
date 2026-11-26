# Trend Stripes Alignment [josseliani]

- url: https://www.tradingview.com/script/5rQHeQrD-Trend-Stripes-Alignment-josseliani/
- type: indicator
- pine_id: PUB;d9abc3e47b964b35a716d63c489c6877
- version: 1.0

## Description

[b]Trend is your friend.[/b]

Trading with the trend gives you a starting point. But which trend? The direction can change with the timeframe. Which chart should you trade, which timeframe should provide context, and when is a trend still worth following?

Trend Stripes Alignment was built to make those questions easier to answer.

[b]How it works[/b]

[b]The two stripes[/b]

Two stripes in the indicator pane show the direction of the working timeframe and a higher timeframe. When they agree, there is a potential window to look for trades in that direction. When they disagree, the indicator waits.

Each stripe holds its last confirmed direction until the opposite direction meets that stripe's confirmation rules. A brief narrowing or flattening of the moving averages does not immediately reverse the stripe. This reduces rapid color changes during sideways movement. The stripes therefore show the last confirmed direction, rather than every temporary change in moving-average position.

[b]Trade filters[/b]

Agreement alone is not enough. Three filters check current volatility, price extension from the Reference MA, and trend separation.

The volatility filter helps avoid a quiet market. The price-extension filter limits signals when price has already moved unusually far from the Reference MA, so a buy or sell may come near the extreme of that move.

The strength filter normally measures the separation of the moving averages used by the higher-timeframe stripe, relative to ATR on that timeframe. Auto 15m is the exception: it measures the separation of 15m EMA 20/50, while the higher stripe gets its direction from 4H price relative to EMA 200.

The Context Table shows which conditions pass and which block signals.

→ The triangles mark moments when the indicator's conditions allowed a search for trend-following trades. They are not buy or sell instructions or ready-made entry prices. A trader still needs a personal entry setup, risk plan, and exit rules.

A first triangle can appear after alignment when the candle qualifies relative to the Entry EMA and the filters pass. A later triangle can appear on a fresh Entry EMA touch after price has moved far enough away. Both types contribute to Target Performance. Signals are confirmed at candle close.

[b]How I use it[/b]

I start with the two stripes: do the working and higher timeframes point in the same direction? Then I check the Context Table. If volatility is too low, price is already extended, or trend separation is too weak, I wait. If conditions allow it, I look for my own setup on the chart.

I use Target Performance to compare instruments and assess what movement may be reasonable to investigate. If an instrument usually traveled less after these signals than I expect to capture, that is a reason to reassess my expectations instead of holding out for a rare large move.

The statistics inform an exit plan; they do not set a take-profit.

[b]Target Performance[/b]

The table analyzes the indicator's triangles, including retests. Each observation starts at the signal candle's close.

In the settings, Target Move specifies the favorable price move to check, and Signal Window sets the number of minutes allowed to reach it. A target is reached when price touches that level after the signal.

→ Both values appear as separate rows in the same Target Performance table.

An observation ends when the selected window expires or the higher-timeframe stripe changes its confirmed direction, whichever happens first. A change of the working-timeframe stripe alone does not end an existing observation.

The table counts how many completed signals reached the specified move and how many did not. It also records each signal's maximum favorable move during its observation window, which is used for the median and average below.

Currency-pair moves are shown in pips. On XAUUSD, Target Move 3 means a $3 change in the gold quote, not $3 profit on a position. Index moves are shown in index points. Other symbols use their chart-price units when no unambiguous unit label is available.

Signals shows the total number of recorded triangles and how many are still active.

Signals Reaching Move shows hits divided by completed signals that had price data in their evaluation window. Active signals and signals without usable price data are not included in that percentage.

Median Max Move is the middle value of the maximum favorable moves across completed, analyzed signals.

Avg Max Move is the mean of those same moves; unusual impulses can pull it higher. Together they help assess an instrument's usual movement and avoid waiting for a move it has rarely offered under the measured conditions. Neither number predicts the next signal.

Avg Time is the average time to the selected move only among signals that reached it. Touch time is estimated at the close of the candle used to check the move.

→ These are signal statistics, not a backtest of actual trades. The table does not include a stop loss, position size, transaction costs, slippage, or a personal exit method. The available chart and lower-timeframe candle history affect sample size, especially on higher chart timeframes. Check the number of completed, analyzed signals before drawing conclusions.

[b]Settings[/b]

[b]Auto presets[/b]

Mode: Auto selects the current and higher trend combinations for supported chart timeframes:

→ 1m EMA 7/13 with 15m EMA 20/50  
→ 5m EMA 50/100 with 1H EMA 135/365  
→ 15m EMA 20/50 with 4H Price/EMA 200  
→ 1H EMA 135/365 with 1D EMA 5/22  
→ 4H Price/EMA 200 with 1D EMA 5/22

The Custom MA fields are ignored in Auto. Choose Custom to set your own stripe timeframes, MA methods, sources, and lengths.

[b]Signals and filters[/b]

Signal Sensitivity sets how much of a candle's body must be beyond the Entry EMA for a triangle:

→ Early: 25%  
→ Balanced: 50%  
→ Confirmed: 100%

Entry EMA Length sets that EMA. Retest Cooldown Distance In ATR controls how far price must move away before another qualifying EMA touch can create a retest triangle. Signal Size changes the triangle display.

Reference MA is used for the price-extension calculation and is shown on the chart by default. Its length, method, and source are adjustable; it does not set stripe direction.

Max Price Stretch compares the price-to-reference-MA distance, scaled by ATR, with its recent history. Its default ceiling of 80 blocks signals at roughly the 20% most extended readings in the trade direction. This does not mean a 20% price move or that exactly 20% of signals are removed; the filter cannot identify a high or low in advance.

Min Market Activity compares current ATR with its recent history. Here, “activity” means volatility, not volume. The default minimum is 30.

Min Trend Strength measures separation on a 1–10 scale. Normally it compares the higher-timeframe MA pair with ATR on that timeframe. In Auto 15m it instead compares 15m EMA 20/50 with 15m ATR. Being close to 4H EMA 200 therefore does not, by itself, block a signal through this filter. The strength score is not a probability of success.

Market History Lookback sets the history length for the extension and volatility comparisons.

[b]Table display[/b]

Show Target Performance and Show Context Table control the two tables. Table Size applies to both; Small is the default so the tables cover less of the screen on mobile devices.

Target Move and Signal Window are configured separately in the Target Performance section, and their current values appear as rows in that table. Each table's screen position can also be set separately.

[b]Alerts[/b]

Bullish Trend Stripes Alignment and Bearish Trend Stripes Alignment fire when the two stripes first agree at a candle close. These alerts report trend agreement even if a trade filter still blocks the Trade Window.

Allowed Buy Signal and Allowed Sell Signal correspond to confirmed triangles after the trade filters pass. Alert messages include the symbol and chart timeframe.

None of these alerts represents an executed trade.

[b]What makes it different[/b]

The indicator connects two-timeframe trend alignment, conditions for considering a trade, and historical movement after its own permission triangles.

The Context Table explains why signals are currently allowed or blocked. Target Performance shows how often a chosen movement followed a signal and how far price typically traveled, without presenting those observations as trades or promised results.

→ What is the trend?  
→ Is this instrument worth watching?  
→ When do conditions allow trading with the trend?  
→ How much movement is reasonable to expect without holding out for a rare move?

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © 2026 josseliani
//
// Trend Stripes Alignment [josseliani]
//
// A two-timeframe trend-context indicator that combines confirmed trend alignment,
// volatility, price-extension and trend-strength filters, Entry EMA signal logic,
// retest handling, a live Context Table and Target Performance statistics.
//
// The triangles mark conditions in which the script allows a search for a
// trend-following trade. They are not automatic trade instructions. Target
// Performance measures favorable movement after confirmed signals; it is not
// a strategy backtest and does not model stops, position sizing, costs or slippage.
//
// Signals and alerts are confirmed at candle close. Use the indicator together
// with your own entry criteria, risk management and exit rules.

//@version=6

indicator("Trend Stripes Alignment [josseliani]", shorttitle="Trend Stripes", overlay=false, max_bars_back=5000)

//====================================================

// HELPERS

//====================================================

f_source(string sourceType) =>

    switch sourceType

        "Open" => open

        "High" => high

        "Low" => low

        "Median Price (HL2)" => hl2

        "Typical Price (HLC3)" => hlc3

        "Weighted Close (HLCC4)" => hlcc4

        => close

f_ma(float source, int length, string maType) =>

    switch maType

        "Simple (SMA)" => ta.sma(source, length)

        "Linear Weighted (WMA)" => ta.wma(source, length)

        "Smoothed (SMMA/RMA)" => ta.rma(source, length)

        => ta.ema(source, length)

f_ma_short_name(string maType) =>

    switch maType

        "Simple (SMA)" => "SMA"

        "Linear Weighted (WMA)" => "WMA"

        "Smoothed (SMMA/RMA)" => "SMMA"

        => "EMA"

//====================================================

// PRESETS

// Auto uses the agreed top-down models.
// Custom keeps the original manual stripe controls.

//====================================================

groupPreset = "PRESETS"

presetMode = input.string(

     "Auto",

     "Mode",

     options=["Auto", "Custom"],

     group=groupPreset,

     tooltip="Auto selects the trend model from the chart timeframe. Custom uses the manual stripe settings below."

)

useAutoPreset = presetMode == "Auto"

// Read-only guide displayed in Inputs above the Custom fields.
autoPresetGuide = input.text_area(
     """AUTO (current + higher):
1m EMA 7/13 + 15m EMA 20/50
5m EMA 50/100 + 1H EMA 135/365
15m EMA 20/50 + 4H Price/EMA200
1H EMA 135/365 + 1D EMA 5/22
4H Price/EMA200 + 1D EMA 5/22
Select Custom to set your own MA combinations below.""",
     "Auto combinations (read-only)",
     group=groupPreset,
     active=false
)

//====================================================

// UPPER STRIPE — EXECUTION TF

//====================================================

groupUpper = "CUSTOM ONLY — CURRENT STRIPE (ignored in Auto)"

showUpper = true

upperTfInput = input.timeframe("", "Timeframe (Empty = Chart)", group=groupUpper, active=not useAutoPreset)

upperMaMethod = input.string(

     "Exponential (EMA)",

     "MA Method",

     options=["Exponential (EMA)", "Simple (SMA)", "Linear Weighted (WMA)", "Smoothed (SMMA/RMA)"],

     group=groupUpper,
     active=not useAutoPreset

)

upperSourceInput = input.string(

     "Close",

     "Source",

     options=["Close", "Open", "High", "Low", "Median Price (HL2)", "Typical Price (HLC3)", "Weighted Close (HLCC4)"],

     group=groupUpper,
     active=not useAutoPreset

)

upperFastLen = input.int(

     7,

     "Fast MA",

     minval=1,

     group=groupUpper,
     active=not useAutoPreset,

     tooltip="Fast MA should normally be lower than Slow MA. Example: Fast 7 / Slow 13."

)

upperSlowLen = input.int(13, "Slow MA", minval=2, group=groupUpper, active=not useAutoPreset)

upperUseSlope = true

upperSlopeLen = 3

upperUseAtr = true

upperAtrLen = 14

upperAtrMult = 0.20

//====================================================

// LOWER STRIPE — HIGHER TF

//====================================================

groupLower = "CUSTOM ONLY — HIGHER STRIPE (ignored in Auto)"

showLower = true

lowerTf = input.timeframe("15", "Timeframe", group=groupLower, active=not useAutoPreset)

lowerMaMethod = input.string(

     "Exponential (EMA)",

     "MA Method",

     options=["Exponential (EMA)", "Simple (SMA)", "Linear Weighted (WMA)", "Smoothed (SMMA/RMA)"],

     group=groupLower,
     active=not useAutoPreset

)

lowerSourceInput = input.string(

     "Close",

     "Source",

     options=["Close", "Open", "High", "Low", "Median Price (HL2)", "Typical Price (HLC3)", "Weighted Close (HLCC4)"],

     group=groupLower,
     active=not useAutoPreset

)

lowerFastLen = input.int(

     20,

     "Fast MA",

     minval=1,

     group=groupLower,
     active=not useAutoPreset,

     tooltip="Fast MA should normally be lower than Slow MA. Example: Fast 20 / Slow 50."

)

lowerSlowLen = input.int(50, "Slow MA", minval=2, group=groupLower, active=not useAutoPreset)

lowerUseSlope = true

lowerSlopeLen = 3

lowerUseAtr = true

lowerAtrLen = 14

lowerAtrMult = 0.20

//====================================================

// COLORS

//====================================================

groupColors = "COLORS"

bullColor = input.color(color.aqua, "Bullish", group=groupColors)

bearColor = input.color(color.orange, "Bearish", group=groupColors)

neutralColor = input.color(color.new(color.gray, 70), "Neutral", group=groupColors)

//====================================================

// ENTRY EMA & SIGNALS

//====================================================

groupEntry = "ENTRY EMA & SIGNALS"

showEntryEMA = input.bool(true, "Show Entry EMA", group=groupEntry)

entryEmaLen = input.int(20, "Entry EMA Length", minval=1, group=groupEntry)

signalSensitivity = input.string(

     "Balanced 50%",

     "Signal Sensitivity",

     options=["Early 25%", "Balanced 50%", "Confirmed 100%"],

     group=groupEntry,

     tooltip="How much of the candle body must be beyond the Entry EMA for first and retest signals. Wicks are ignored."

)

showSignals = input.bool(true, "Show Signal Triangles", group=groupEntry)

signalSizeInput = input.string(

     "Large",

     "Signal Size",

     options=["Large", "Small"],

     group=groupEntry

)

signalOffsetATR = 0.15

retestCooldownATR = input.float(

     0.50,

     "Retest Cooldown Distance In ATR",

     minval=0.0,

     maxval=5.0,

     step=0.05,

     group=groupEntry,

     tooltip="After a signal, price must move at least this far away from the Entry EMA in the trend direction before another EMA-touch signal is allowed."

)

//====================================================

// REFERENCE MA — basis for price extension, separate from Entry EMA

//====================================================

groupReference = "REFERENCE MA / PRICE EXTENSION"

showReferenceMA = input.bool(true, "Show Reference MA", group=groupReference)

referenceMaLen = input.int(
     200,
     "Reference MA Length",
     minval=20,
     group=groupReference,
     tooltip="Reference MA used to measure statistical price extension. It does not define trend direction."
)

referenceMaMethod = input.string(
     "Linear Weighted (WMA)",
     "Reference MA Method",
     options=["Exponential (EMA)", "Simple (SMA)", "Linear Weighted (WMA)", "Smoothed (SMMA/RMA)"],
     group=groupReference
)

referenceSourceInput = input.string(
     "Weighted Close (HLCC4)",
     "Reference MA Source",
     options=["Close", "Open", "High", "Low", "Median Price (HL2)", "Typical Price (HLC3)", "Weighted Close (HLCC4)"],
     group=groupReference
)

//====================================================

// TABLE DISPLAY — shared by both tables

//====================================================

groupTables = "TABLE DISPLAY"

tableSizeInput = input.string(
     "Small",
     "Table Size",
     options=["Small", "Large"],
     group=groupTables,
     tooltip="Applies to both tables. Small is the mobile-friendly default."
)

tableTextSize = tableSizeInput == "Large" ? size.normal : size.small

//====================================================

// TARGET PERFORMANCE

// Measures what the market gives after every existing triangle.
// No stop-loss model and no R-multiple assumptions are used.

//====================================================

groupPerf = "TARGET PERFORMANCE"

showPerformanceTable = input.bool(

     true,

     "Show Target Performance",

     group=groupPerf,

     tooltip="Tracks BUY/SELL triangles, including retests. Uses chart candles when they fit exactly within the selected window; otherwise uses available lower-timeframe candles. Signals without price data in the window are excluded."

)

targetMoveInput = input.float(

     3.0,

     "Target Move",

     minval=0.1,

     step=0.1,

     group=groupPerf,

     tooltip="Move after a signal. Currency pairs use pips; metals and other symbols use price units. XAUUSD 3 = $3, NASDAQ 20 = 20 points, EURUSD 10 = 10 pips."

)

signalWindowMinutes = input.int(

     60,

     "Signal Window (Minutes)",

     minval=1,

     maxval=10080,

     group=groupPerf,

     tooltip="Maximum life of each signal. Tracking ends earlier if the Higher-TF stripe changes direction."

)

perfTablePositionInput = input.string(

     "Bottom Right",

     "Target Table Position",

     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],

     group=groupPerf

)

//====================================================

// TRADE FILTERS

// The calculations stay statistical internally, but the user sees
// simple market-relative controls.

//====================================================

groupFilters = "TRADE FILTERS"

maxPriceStretch = input.float(

     80.0,

     "Max Price Stretch",

     minval=1.0,

     maxval=100.0,

     step=1.0,

     group=groupFilters,

     tooltip="Distance from the Reference MA compared with recent history. At 80, blocks signals when price is among the 20% most stretched in the trade direction."

)

minMarketActivity = input.float(

     30.0,

     "Min Market Activity",

     minval=0.0,

     maxval=100.0,

     step=1.0,

     group=groupFilters,

     tooltip="Volatility on a 0-100 scale: low values = quiet market, high values = active market. Set the minimum allowed level; 0 allows all levels."

)

minTrendStrength = input.int(

     3,

     "Min Trend Strength",

     minval=1,

     maxval=10,

     group=groupFilters,

     tooltip="How far the trend EMAs have opened relative to ATR. Higher values require wider separation. In Auto 15m, uses 15m EMA 20/50. Level 3 = 0.15 ATR."

)

f_strength_threshold(int level) =>

    switch level

        1 => 0.00

        2 => 0.10

        3 => 0.15

        4 => 0.20

        5 => 0.25

        6 => 0.35

        7 => 0.45

        8 => 0.60

        9 => 0.80

        => 1.00

minTrendStrengthATR = f_strength_threshold(minTrendStrength)

//====================================================

// CHART VISUAL

//====================================================

groupVisual = "CHART VISUAL"

showAlignmentHighlight = input.bool(true, "Highlight When Stripes Align", group=groupVisual)

highlightTransparency = input.int(93, "Highlight Transparency", minval=80, maxval=100, group=groupVisual)

//====================================================

// MARKET CONTEXT

//====================================================

groupContext = "MARKET CONTEXT"

showContextTable = input.bool(true, "Show Context Table", group=groupContext)

tablePositionInput = input.string(

     "Top Right",

     "Table Position",

     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],

     group=groupContext

)


contextAtrLen = 14

percentileLookback = input.int(

     500,

     "Market History Lookback",

     minval=100,

     maxval=5000,

     group=groupContext,

     tooltip="Historical window used for price extension and market activity percentile ranks. On Auto charts, Activity uses the chart timeframe."

)

compressedLevel = 10.0

extendedLevel = 70.0

extremeLevel = 90.0

veryExtremeLevel = 95.0

lowVolLevel = 25.0

highVolLevel = 75.0

extremeVolLevel = 90.0

//====================================================

// RESOLVED PRESETS + TREND STRIPES

// Auto map:
// 1m  -> chart EMA 7/13      + 15m EMA 20/50
// 5m  -> chart EMA 50/100    + 1H  EMA 135/365
// 15m -> chart EMA 20/50     + 4H  Price vs EMA200
// 1H  -> chart EMA 135/365   + 1D  EMA 5/22
// 4H  -> chart Price/EMA200  + 1D  EMA 5/22
//
// IMPORTANT: Trade filters do not define stripe color.
// Stripes are calculated first; Price Stretch, Market Activity and
// Trend Strength are applied later only to signal permission.

//====================================================

chartTfSeconds = timeframe.in_seconds(timeframe.period)

autoIs1m = timeframe.period == "1"
autoIs5m = timeframe.period == "5"
autoIs15m = timeframe.period == "15"
autoIs1h = timeframe.period == "60"
autoIs4h = timeframe.period == "240"
autoPresetSupported = autoIs1m or autoIs5m or autoIs15m or autoIs1h or autoIs4h

if useAutoPreset and not autoPresetSupported

    runtime.error("Auto presets are available on 1m, 5m, 15m, 1H and 4H charts. Use Custom on other timeframes.")

//------------------------------
// CUSTOM PATH — original v1.1 logic
//------------------------------

customUpperTf = upperTfInput == "" ? timeframe.period : upperTfInput
customUpperTfSeconds = timeframe.in_seconds(customUpperTf)
customLowerTfSeconds = timeframe.in_seconds(lowerTf)
// request.security() is evaluated even when its result is not selected later.
// In Auto mode keep dormant Custom requests on the chart timeframe so H1/H4
// never make an invalid lower-timeframe request to the default 15m Custom stripe.
customUpperRequestTf = useAutoPreset ? timeframe.period : customUpperTf
customLowerRequestTf = useAutoPreset ? timeframe.period : lowerTf
customUpperIsHigher = customUpperTfSeconds > chartTfSeconds
customLowerIsHigher = customLowerTfSeconds > chartTfSeconds
customUpperIsLower = customUpperTfSeconds < chartTfSeconds
customLowerIsLower = customLowerTfSeconds < chartTfSeconds

if not useAutoPreset and (customUpperIsLower or customLowerIsLower)

    runtime.error("Custom stripe timeframes must be equal to or higher than the chart timeframe.")

[customUpperFastHTF, customUpperSlowHTF, customUpperAtrHTF, customUpperSlowPastHTF] = request.security(

     syminfo.tickerid,

     customUpperRequestTf,

     [

         f_ma(f_source(upperSourceInput), upperFastLen, upperMaMethod)[1],

         f_ma(f_source(upperSourceInput), upperSlowLen, upperMaMethod)[1],

         ta.atr(upperAtrLen)[1],

         f_ma(f_source(upperSourceInput), upperSlowLen, upperMaMethod)[upperSlopeLen + 1]

     ],

     gaps=barmerge.gaps_off,

     lookahead=barmerge.lookahead_on

)

customUpperFastChart = f_ma(f_source(upperSourceInput), upperFastLen, upperMaMethod)
customUpperSlowChart = f_ma(f_source(upperSourceInput), upperSlowLen, upperMaMethod)
customUpperAtrChart = ta.atr(upperAtrLen)
customUpperSlowPastChart = customUpperSlowChart[upperSlopeLen]

customUpperFast = customUpperIsHigher ? customUpperFastHTF : customUpperFastChart
customUpperSlow = customUpperIsHigher ? customUpperSlowHTF : customUpperSlowChart
customUpperAtr = customUpperIsHigher ? customUpperAtrHTF : customUpperAtrChart
customUpperSlowPast = customUpperIsHigher ? customUpperSlowPastHTF : customUpperSlowPastChart

customUpperSlopeUp = customUpperSlow > customUpperSlowPast
customUpperSlopeDn = customUpperSlow < customUpperSlowPast
customUpperDistanceOK = not upperUseAtr or math.abs(customUpperFast - customUpperSlow) >= customUpperAtr * upperAtrMult
customUpperBull = customUpperFast > customUpperSlow and customUpperDistanceOK and (not upperUseSlope or customUpperSlopeUp)
customUpperBear = customUpperFast < customUpperSlow and customUpperDistanceOK and (not upperUseSlope or customUpperSlopeDn)

[customLowerFastHTF, customLowerSlowHTF, customLowerAtrHTF, customLowerSlowPastHTF] = request.security(

     syminfo.tickerid,

     customLowerRequestTf,

     [

         f_ma(f_source(lowerSourceInput), lowerFastLen, lowerMaMethod)[1],

         f_ma(f_source(lowerSourceInput), lowerSlowLen, lowerMaMethod)[1],

         ta.atr(lowerAtrLen)[1],

         f_ma(f_source(lowerSourceInput), lowerSlowLen, lowerMaMethod)[lowerSlopeLen + 1]

     ],

     gaps=barmerge.gaps_off,

     lookahead=barmerge.lookahead_on

)

customLowerFastChart = f_ma(f_source(lowerSourceInput), lowerFastLen, lowerMaMethod)
customLowerSlowChart = f_ma(f_source(lowerSourceInput), lowerSlowLen, lowerMaMethod)
customLowerAtrChart = ta.atr(lowerAtrLen)
customLowerSlowPastChart = customLowerSlowChart[lowerSlopeLen]

customLowerFast = customLowerIsHigher ? customLowerFastHTF : customLowerFastChart
customLowerSlow = customLowerIsHigher ? customLowerSlowHTF : customLowerSlowChart
customLowerAtr = customLowerIsHigher ? customLowerAtrHTF : customLowerAtrChart
customLowerSlowPast = customLowerIsHigher ? customLowerSlowPastHTF : customLowerSlowPastChart

customLowerSlopeUp = customLowerSlow > customLowerSlowPast
customLowerSlopeDn = customLowerSlow < customLowerSlowPast
customLowerDistanceOK = not lowerUseAtr or math.abs(customLowerFast - customLowerSlow) >= customLowerAtr * lowerAtrMult
customLowerBull = customLowerFast > customLowerSlow and customLowerDistanceOK and (not lowerUseSlope or customLowerSlopeUp)
customLowerBear = customLowerFast < customLowerSlow and customLowerDistanceOK and (not lowerUseSlope or customLowerSlopeDn)

//------------------------------
// AUTO CURRENT STRIPE — chart timeframe only
// Pair presets deliberately preserve the original slope + 0.20 ATR
// stripe logic from the working v1.1 branch.
//------------------------------

autoUpperFastLen = autoIs1m ? 7 : autoIs5m ? 50 : autoIs15m ? 20 : autoIs1h ? 135 : 200
autoUpperSlowLen = autoIs1m ? 13 : autoIs5m ? 100 : autoIs15m ? 50 : autoIs1h ? 365 : 200

autoUpperFastMA = ta.ema(close, autoUpperFastLen)
autoUpperSlowMA = ta.ema(close, autoUpperSlowLen)
autoUpperAtr = ta.atr(14)
autoUpperSlowPast = autoUpperSlowMA[3]
autoUpperSingleMA = autoIs4h

autoUpperDistanceOK = autoUpperSingleMA or math.abs(autoUpperFastMA - autoUpperSlowMA) >= autoUpperAtr * 0.20
autoUpperSlopeUp = autoUpperSlowMA > autoUpperSlowPast
autoUpperSlopeDn = autoUpperSlowMA < autoUpperSlowPast
autoUpperBull = autoUpperSingleMA ? close > autoUpperSlowMA : autoUpperFastMA > autoUpperSlowMA and autoUpperDistanceOK and autoUpperSlopeUp
autoUpperBear = autoUpperSingleMA ? close < autoUpperSlowMA : autoUpperFastMA < autoUpperSlowMA and autoUpperDistanceOK and autoUpperSlopeDn

//------------------------------
// AUTO HIGHER STRIPE — fixed literal requests
// Using fixed requests keeps each preset independent and prevents one
// preset's single-MA model from changing another preset's MTF series.
//------------------------------

// Every request is kept at or above the chart timeframe. Dormant preset requests
// fall back to the chart timeframe; only the active preset requests its real HTF.
a1RequestTf = autoIs1m ? "15" : timeframe.period
a5RequestTf = autoIs5m ? "60" : timeframe.period
a15RequestTf = autoIs15m ? "240" : timeframe.period
aDRequestTf = (autoIs1h or autoIs4h) ? "1D" : timeframe.period

[a1LowerFast, a1LowerSlow, a1LowerAtr, a1LowerSlowPast] = request.security(
     syminfo.tickerid, a1RequestTf,
     [ta.ema(close, 20)[1], ta.ema(close, 50)[1], ta.atr(14)[1], ta.ema(close, 50)[4]],
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[a5LowerFast, a5LowerSlow, a5LowerAtr, a5LowerSlowPast] = request.security(
     syminfo.tickerid, a5RequestTf,
     [ta.ema(close, 135)[1], ta.ema(close, 365)[1], ta.atr(14)[1], ta.ema(close, 365)[4]],
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[a15LowerPrice, a15LowerEMA200, a15LowerAtr] = request.security(
     syminfo.tickerid, a15RequestTf,
     [close[1], ta.ema(close, 200)[1], ta.atr(14)[1]],
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[aDLowerFast, aDLowerSlow, aDLowerAtr, aDLowerSlowPast] = request.security(
     syminfo.tickerid, aDRequestTf,
     [ta.ema(close, 5)[1], ta.ema(close, 22)[1], ta.atr(14)[1], ta.ema(close, 22)[4]],
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

autoLowerSingleMA = autoIs15m
autoLowerPrice = autoIs15m ? a15LowerPrice : na
autoLowerFast = autoIs1m ? a1LowerFast : autoIs5m ? a5LowerFast : autoIs15m ? a15LowerPrice : aDLowerFast
autoLowerSlow = autoIs1m ? a1LowerSlow : autoIs5m ? a5LowerSlow : autoIs15m ? a15LowerEMA200 : aDLowerSlow
autoLowerAtr = autoIs1m ? a1LowerAtr : autoIs5m ? a5LowerAtr : autoIs15m ? a15LowerAtr : aDLowerAtr
autoLowerSlowPast = autoIs1m ? a1LowerSlowPast : autoIs5m ? a5LowerSlowPast : autoIs15m ? na : aDLowerSlowPast

autoLowerDistanceOK = autoLowerSingleMA or math.abs(autoLowerFast - autoLowerSlow) >= autoLowerAtr * 0.20
autoLowerSlopeUp = autoLowerSingleMA ? true : autoLowerSlow > autoLowerSlowPast
autoLowerSlopeDn = autoLowerSingleMA ? true : autoLowerSlow < autoLowerSlowPast
autoLowerBull = autoLowerSingleMA ? autoLowerPrice > autoLowerSlow : autoLowerFast > autoLowerSlow and autoLowerDistanceOK and autoLowerSlopeUp
autoLowerBear = autoLowerSingleMA ? autoLowerPrice < autoLowerSlow : autoLowerFast < autoLowerSlow and autoLowerDistanceOK and autoLowerSlopeDn

//------------------------------
// RESOLVED SERIES
//------------------------------

upperFast = useAutoPreset ? (autoUpperSingleMA ? close : autoUpperFastMA) : customUpperFast
upperSlow = useAutoPreset ? autoUpperSlowMA : customUpperSlow
upperAtr = useAutoPreset ? autoUpperAtr : customUpperAtr
upperBull = useAutoPreset ? autoUpperBull : customUpperBull
upperBear = useAutoPreset ? autoUpperBear : customUpperBear

lowerFast = useAutoPreset ? autoLowerFast : customLowerFast
lowerSlow = useAutoPreset ? autoLowerSlow : customLowerSlow
lowerAtr = useAutoPreset ? autoLowerAtr : customLowerAtr
lowerBull = useAutoPreset ? autoLowerBull : customLowerBull
lowerBear = useAutoPreset ? autoLowerBear : customLowerBear

var int upperState = 0

if barstate.isconfirmed

    if upperBull

        upperState := 1

    else if upperBear

        upperState := -1

    else

        upperState := nz(upperState[1], 0)

var int lowerState = 0

if barstate.isconfirmed

    if lowerBull

        lowerState := 1

    else if lowerBear

        lowerState := -1

    else

        lowerState := nz(lowerState[1], 0)

//====================================================

// STRIPES

//====================================================

upperColor =

     upperState == 1 ? bullColor :

     upperState == -1 ? bearColor :

     neutralColor

lowerColor =

     lowerState == 1 ? bullColor :

     lowerState == -1 ? bearColor :

     neutralColor

plot(

     showUpper ? 1.65 : na,

     title="Execution Trend Stripe",

     style=plot.style_columns,

     histbase=1.10,

     color=upperColor,

     linewidth=4

)

plot(

     showLower ? 1.0 : na,

     title="Higher-TF Trend Stripe",

     style=plot.style_columns,

     histbase=0.45,

     color=lowerColor,

     linewidth=4

)

//====================================================

// ALIGNMENT

//====================================================

bullAlignment = upperState == 1 and lowerState == 1

bearAlignment = upperState == -1 and lowerState == -1

alignmentState =

     bullAlignment ? 1 :

     bearAlignment ? -1 :

     0

//====================================================

// STRIPE TURN EVENTS

//====================================================

upperTurnedBull =

     upperState == 1 and

     upperState[1] != 1

upperTurnedBear =

     upperState == -1 and

     upperState[1] != -1

lowerTurnedBull =

     lowerState == 1 and

     lowerState[1] == -1

lowerTurnedBear =

     lowerState == -1 and

     lowerState[1] == 1

//====================================================

// HIGHER-TF TREND CHANGE COOLDOWN

//====================================================

var int htfCooldownDir = 0

var int htfCooldownStage = 0

bullCooldownReleased = false

bearCooldownReleased = false

if lowerTurnedBull

    htfCooldownDir := 1

    htfCooldownStage := upperState == 1 ? 2 : 1

else if lowerTurnedBear

    htfCooldownDir := -1

    htfCooldownStage := upperState == -1 ? 2 : 1

else if htfCooldownDir != 0

    if lowerState != htfCooldownDir

        htfCooldownDir := 0

        htfCooldownStage := 0

    else

        if htfCooldownStage == 1 and upperState == htfCooldownDir

            htfCooldownStage := 2

        else if htfCooldownStage == 2 and upperState == -htfCooldownDir

            htfCooldownStage := 3

        else if htfCooldownStage == 3 and upperState == htfCooldownDir

            bullCooldownReleased := htfCooldownDir == 1

            bearCooldownReleased := htfCooldownDir == -1

            htfCooldownDir := 0

            htfCooldownStage := 0

//====================================================

// NEW SETUP

//====================================================

bullSetupAllowed = htfCooldownDir != 1 or bullCooldownReleased

bearSetupAllowed = htfCooldownDir != -1 or bearCooldownReleased

newBullSetup =

     lowerState == 1 and

     upperTurnedBull and

     bullSetupAllowed

newBearSetup =

     lowerState == -1 and

     upperTurnedBear and

     bearSetupAllowed

//====================================================

// ALIGNMENT HIGHLIGHT

//====================================================

alignmentBg =

     bullAlignment ? color.new(bullColor, highlightTransparency) :

     bearAlignment ? color.new(bearColor, highlightTransparency) :

     na

bgcolor(

     showAlignmentHighlight ? alignmentBg : na,

     force_overlay=true

)

//====================================================

// ENTRY EMA

//====================================================

entryEMA = ta.ema(close, entryEmaLen)

entryColor =

     bullAlignment ? bullColor :

     bearAlignment ? bearColor :

     color.new(color.gray, 45)

plot(

     showEntryEMA ? entryEMA : na,

     title="Entry EMA",

     color=entryColor,

     linewidth=2,

     force_overlay=true,

     display=display.all - display.status_line - display.price_scale

)

//====================================================

// BODY CONFIRMATION (first + retest)

//====================================================

bodyHigh = math.max(open, close)

bodyLow = math.min(open, close)

bodySize = bodyHigh - bodyLow

bullBodyBeyond =

     bodySize <= 0.0 ? 0.0 :

     entryEMA <= bodyLow ? 1.0 :

     entryEMA >= bodyHigh ? 0.0 :

     (bodyHigh - entryEMA) / bodySize

bearBodyBeyond =

     bodySize <= 0.0 ? 0.0 :

     entryEMA >= bodyHigh ? 1.0 :

     entryEMA <= bodyLow ? 0.0 :

     (entryEMA - bodyLow) / bodySize

signalThreshold =

     signalSensitivity == "Early 25%" ? 0.25 :

     signalSensitivity == "Balanced 50%" ? 0.50 :

     1.00

bullCandleOK =

     close > open and

     bullBodyBeyond >= signalThreshold

bearCandleOK =

     close < open and

     bearBodyBeyond >= signalThreshold

//====================================================

// MARKET CONTEXT

//====================================================

referenceSource = f_source(referenceSourceInput)

referenceMA = f_ma(referenceSource, referenceMaLen, referenceMaMethod)

contextATR = ta.atr(contextAtrLen)

signedDistanceATR =

     contextATR > 0 ?

     (close - referenceMA) / contextATR :

     0.0

absoluteDistanceATR = math.abs(signedDistanceATR)

distancePercentile =

     ta.percentrank(

         absoluteDistanceATR,

         percentileLookback

     )

// Activity resolution: M1 on 1m; M5 on 5m; M15 on 15m;
// on H1/H4 (and other higher charts) use the chart timeframe itself.
// This keeps request.security() at or above the chart timeframe.
activityTf = chartTfSeconds <= 60 ? "1" : chartTfSeconds == 300 ? "5" : chartTfSeconds <= 900 ? "15" : timeframe.period
atrPercentile = request.security(syminfo.tickerid, activityTf, ta.percentrank(ta.atr(contextAtrLen), percentileLookback), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//====================================================

// TREND MA SEPARATION (AUTO 15m: CURRENT EMA 20/50)

//====================================================

trendStrengthATR =

     useAutoPreset and autoIs15m ?

     (upperAtr > 0 ? math.abs(upperFast - upperSlow) / upperAtr : 0.0) :

     (lowerAtr > 0 ? math.abs(lowerFast - lowerSlow) / lowerAtr : 0.0)

//====================================================

// DIRECTIONAL EXTENSION FILTER

//====================================================

longExtensionOK =

     signedDistanceATR <= 0 or

     na(distancePercentile) or

     distancePercentile < maxPriceStretch

shortExtensionOK =

     signedDistanceATR >= 0 or

     na(distancePercentile) or

     distancePercentile < maxPriceStretch

//====================================================

// VOLATILITY FILTER (na = pass until lookback is ready)

//====================================================

volatilityFilterOK =

     na(atrPercentile) or

     atrPercentile >= minMarketActivity

//====================================================

// TREND SEPARATION FILTER

//====================================================

trendSeparationFilterOK =

     trendStrengthATR >= minTrendStrengthATR

longFiltersOK =

     longExtensionOK and

     volatilityFilterOK and

     trendSeparationFilterOK

shortFiltersOK =

     shortExtensionOK and

     volatilityFilterOK and

     trendSeparationFilterOK

//====================================================

// SIGNAL STATE

//====================================================

var bool bullFirstArmed = false

var bool bearFirstArmed = false

var bool bullRetestReady = false

var bool bearRetestReady = false

//====================================================

// NEW SETUP ARMING

//====================================================

if newBullSetup

    bullFirstArmed := true

    bearFirstArmed := false

    bullRetestReady := false

    bearRetestReady := false

if newBearSetup

    bearFirstArmed := true

    bullFirstArmed := false

    bearRetestReady := false

    bullRetestReady := false

if not bullAlignment

    bullFirstArmed := false

    bullRetestReady := false

if not bearAlignment

    bearFirstArmed := false

    bearRetestReady := false

//====================================================

// FIRST SIGNAL

//====================================================

firstBuySignal =

     barstate.isconfirmed and

     bullAlignment and

     bullFirstArmed and

     bullCandleOK and

     longFiltersOK

firstSellSignal =

     barstate.isconfirmed and

     bearAlignment and

     bearFirstArmed and

     bearCandleOK and

     shortFiltersOK

if firstBuySignal

    bullFirstArmed := false

    bullRetestReady := false

if firstSellSignal

    bearFirstArmed := false

    bearRetestReady := false

//====================================================

// RETEST COOLDOWN

//====================================================

signalATR = ta.atr(14)

bullMovedAway =

     bullAlignment and

     not bullFirstArmed and

     high >= entryEMA + signalATR * retestCooldownATR

bearMovedAway =

     bearAlignment and

     not bearFirstArmed and

     low <= entryEMA - signalATR * retestCooldownATR

//====================================================

// FRESH EMA TOUCH + BODY (same rules as first signal)

//====================================================

bullTouch =

     bullAlignment and

     bullRetestReady and

     low <= entryEMA

bearTouch =

     bearAlignment and

     bearRetestReady and

     high >= entryEMA

retestBuySignal =

     barstate.isconfirmed and

     bullTouch and

     bullCandleOK and

     longFiltersOK

retestSellSignal =

     barstate.isconfirmed and

     bearTouch and

     bearCandleOK and

     shortFiltersOK

if (bullTouch and bullCandleOK and longFiltersOK) or firstBuySignal

    bullRetestReady := false

else if bullMovedAway

    bullRetestReady := true

if (bearTouch and bearCandleOK and shortFiltersOK) or firstSellSignal

    bearRetestReady := false

else if bearMovedAway

    bearRetestReady := true

//====================================================

// FINAL SIGNALS

//====================================================

buySignal =

     firstBuySignal or

     retestBuySignal

sellSignal =

     firstSellSignal or

     retestSellSignal

//====================================================

// TARGET PERFORMANCE ENGINE

// Every existing triangle is tracked, including retests.
// Entry = signal close. Evaluation starts after the entry close.
// Target execution is by TOUCH, never by chart-bar close.
// Chart candles are used whenever the selected window contains whole
// chart candles. Otherwise lower-timeframe candles supply touch timing.
// Signal expires at the earlier of:
// 1) Signal Window expiry, or
// 2) Higher-TF stripe direction change.
// No stop is assumed. We measure maximum favorable excursion (MFE),
// the share reaching the selected move, time to move, and signal life.

//====================================================

// Identify currency pairs by their fiat base/quote codes, including CFDs
// that TradingView does not classify as forex. Metals, indices and crypto
// keep their native chart-price units.
f_isFiatCurrency(string code) =>
    str.contains("|USD|EUR|GBP|JPY|CHF|AUD|NZD|CAD|CNY|CNH|RUB|HKD|SGD|NOK|SEK|DKK|PLN|TRY|ZAR|MXN|BRL|INR|KRW|AED|SAR|ILS|CZK|HUF|THB|TWD|IDR|MYR|PHP|", "|" + code + "|")

isForexCurrencyPair = syminfo.basecurrency != syminfo.currency and f_isFiatCurrency(syminfo.basecurrency) and f_isFiatCurrency(syminfo.currency)

// Use a unit label only when the symbol's price unit is unambiguous.
// On some metal/crypto feeds basecurrency is absent. Their explicit USD
// ticker still identifies the chart-price unit without guessing a contract P&L.
isUsdPriceSymbol = (syminfo.currency == "USD" and (syminfo.basecurrency == "XAU" or syminfo.basecurrency == "BTC")) or syminfo.ticker == "XAUUSD" or syminfo.ticker == "BTCUSD"
isIndexPriceSymbol = syminfo.type == "index" or str.startswith(syminfo.ticker, "NAS100") or str.startswith(syminfo.ticker, "US100") or str.startswith(syminfo.ticker, "US500") or str.startswith(syminfo.ticker, "SPX500") or str.startswith(syminfo.ticker, "GER40") or str.startswith(syminfo.ticker, "DE40") or str.startswith(syminfo.ticker, "US30")

pipSize = syminfo.currency == "JPY" ? 0.01 : syminfo.basecurrency == "JPY" ? 0.00001 : 0.0001

targetDistance = isForexCurrencyPair ? targetMoveInput * pipSize : targetMoveInput

targetWindowMs = signalWindowMinutes * 60 * 1000

f_move_value(float priceMove) =>

    isForexCurrencyPair ? priceMove / pipSize : priceMove

f_move_text(float priceMove) =>

    string moveText = "N/A"

    if not na(priceMove)

        moveText := isForexCurrencyPair ? str.tostring(f_move_value(priceMove), "0.0") + " pips" : isIndexPriceSymbol ? str.tostring(priceMove, "0.00") + " pts" : isUsdPriceSymbol ? "$" + str.tostring(priceMove, "0.00") : str.tostring(priceMove, "0.00")

    moveText

f_minutes_text(float minutesValue) =>

    na(minutesValue) ? "N/A" : str.tostring(minutesValue, "0.0") + " min"

// Prefer chart bars for a consistent sample across the chart's full history.
// Their duration must divide the time window, so the last candle cannot
// include price movement after the deadline. H4 with a 60m window uses LTF.
usePerfChartBars = chartTfSeconds > 0 and chartTfSeconds <= signalWindowMinutes * 60 and (signalWindowMinutes * 60) % chartTfSeconds == 0
// When chart bars are too coarse, use the widest lower timeframe that fits
// entirely within each signal window; 1m handles arbitrary minute windows.
perfResolution = usePerfChartBars ? timeframe.period : chartTfSeconds >= 14400 and signalWindowMinutes % 15 == 0 ? "15" : chartTfSeconds >= 3600 and signalWindowMinutes % 5 == 0 ? "5" : "1"
[m1Time, m1TimeClose, m1High, m1Low] = request.security_lower_tf(

     syminfo.tickerid,

     perfResolution,

     [time, time_close, high, low],

     ignore_invalid_timeframe=true

)

m1Count = array.size(m1Time)

var array<int> perfDir = array.new_int()

var array<float> perfEntry = array.new_float()

var array<int> perfEntryTime = array.new_int()

var array<int> perfEntryBar = array.new_int()

var array<float> perfMaxMove = array.new_float()

var array<bool> perfTargetHit = array.new_bool()

var array<int> perfTargetHitTime = array.new_int()

var array<bool> perfDataSeen = array.new_bool()

var array<float> perfClosedMoves = array.new_float()

var int perfSignals = 0

var int perfClosed = 0

var int perfHits = 0

var float perfTargetMinutesSum = 0.0

var float perfLifeMinutesSum = 0.0

if showPerformanceTable

    // Every triangle starts a statistical sample. Chart or LTF bars provide
    // the execution path, depending on which fit the selected time window.
    if buySignal

        array.push(perfDir, 1)

        array.push(perfEntry, close)

        array.push(perfEntryTime, time_close)

        array.push(perfEntryBar, bar_index)

        array.push(perfMaxMove, 0.0)

        array.push(perfTargetHit, false)

        array.push(perfTargetHitTime, na)

        array.push(perfDataSeen, false)

        perfSignals += 1

    if sellSignal

        array.push(perfDir, -1)

        array.push(perfEntry, close)

        array.push(perfEntryTime, time_close)

        array.push(perfEntryBar, bar_index)

        array.push(perfMaxMove, 0.0)

        array.push(perfTargetHit, false)

        array.push(perfTargetHitTime, na)

        array.push(perfDataSeen, false)

        perfSignals += 1

    int perfN = array.size(perfDir)

    if perfN > 0

        for i = perfN - 1 to 0

            int dir = array.get(perfDir, i)

            float en = array.get(perfEntry, i)

            int etime = array.get(perfEntryTime, i)

            int ebar = array.get(perfEntryBar, i)

            float maxMove = array.get(perfMaxMove, i)

            bool targetHit = array.get(perfTargetHit, i)

            int hitTime = array.get(perfTargetHitTime, i)

            bool dataSeen = array.get(perfDataSeen, i)

            int deadline = etime + targetWindowMs

            if bar_index > ebar

                // Evaluate by touch on chart bars or the selected LTF bars.
                if usePerfChartBars

                    bool afterEntry = time >= etime
                    bool insideWindow = time < deadline

                    if afterEntry and insideWindow

                        dataSeen := true

                        float minuteMove = dir == 1 ? math.max(0.0, high - en) : math.max(0.0, en - low)

                        maxMove := math.max(maxMove, minuteMove)

                        if not targetHit and minuteMove >= targetDistance

                            targetHit := true

                            hitTime := math.min(time_close, deadline)

                else if m1Count > 0

                    for j = 0 to m1Count - 1

                        int mt = array.get(m1Time, j)

                        int mtClose = array.get(m1TimeClose, j)

                        float mh = array.get(m1High, j)

                        float ml = array.get(m1Low, j)

                        bool afterEntry = mt >= etime

                        bool insideWindow = mt < deadline

                        if afterEntry and insideWindow

                            dataSeen := true

                            float minuteMove = dir == 1 ? math.max(0.0, mh - en) : math.max(0.0, en - ml)

                            maxMove := math.max(maxMove, minuteMove)

                            if not targetHit and minuteMove >= targetDistance

                                targetHit := true

                                hitTime := math.min(mtClose, deadline)

                bool trendExpired = lowerState != dir

                bool timeExpired = time_close >= deadline

                array.set(perfMaxMove, i, maxMove)

                array.set(perfTargetHit, i, targetHit)

                array.set(perfTargetHitTime, i, hitTime)

                array.set(perfDataSeen, i, dataSeen)

                if trendExpired or timeExpired

                    int endTime = timeExpired ? math.min(time_close, deadline) : time_close

                    float lifeMinutes = math.max(0.0, (endTime - etime) / 60000.0)

                    // Exclude samples with no price bars in their evaluation window.
                    if dataSeen

                        perfClosed += 1

                        perfLifeMinutesSum += lifeMinutes

                        array.push(perfClosedMoves, maxMove)

                        if targetHit

                            perfHits += 1

                            perfTargetMinutesSum += math.max(0.0, (hitTime - etime) / 60000.0)

                    array.remove(perfDir, i)

                    array.remove(perfEntry, i)

                    array.remove(perfEntryTime, i)

                    array.remove(perfEntryBar, i)

                    array.remove(perfMaxMove, i)

                    array.remove(perfTargetHit, i)

                    array.remove(perfTargetHitTime, i)

                    array.remove(perfDataSeen, i)

perfActive = array.size(perfDir)

perfHitRate = perfClosed > 0 ? perfHits * 100.0 / perfClosed : na

perfAvgMaxMove = perfClosed > 0 ? array.avg(perfClosedMoves) : na

perfMedianMaxMove = perfClosed > 0 ? array.median(perfClosedMoves) : na

perfAvgTimeToTarget = perfHits > 0 ? perfTargetMinutesSum / perfHits : na

perfAvgSignalLife = perfClosed > 0 ? perfLifeMinutesSum / perfClosed : na

//====================================================

// SIGNAL POSITION

//====================================================

buySignalY =

     low - signalATR * signalOffsetATR

sellSignalY =

     high + signalATR * signalOffsetATR

//====================================================

// NORMAL TRIANGLES

//====================================================

plotshape(

     showSignals and signalSizeInput == "Large" and buySignal ? buySignalY : na,

     title="Buy Signal Normal",

     style=shape.triangleup,

     location=location.absolute,

     color=bullColor,

     size=size.small,

     force_overlay=true,

     display=display.all - display.status_line - display.price_scale

)

plotshape(

     showSignals and signalSizeInput == "Large" and sellSignal ? sellSignalY : na,

     title="Sell Signal Normal",

     style=shape.triangledown,

     location=location.absolute,

     color=bearColor,

     size=size.small,

     force_overlay=true,

     display=display.all - display.status_line - display.price_scale

)

//====================================================

// SMALL TRIANGLES

//====================================================

plotshape(

     showSignals and signalSizeInput == "Small" and buySignal ? buySignalY : na,

     title="Buy Signal Small",

     style=shape.triangleup,

     location=location.absolute,

     color=bullColor,

     size=size.tiny,

     force_overlay=true,

     display=display.all - display.status_line - display.price_scale

)

plotshape(

     showSignals and signalSizeInput == "Small" and sellSignal ? sellSignalY : na,

     title="Sell Signal Small",

     style=shape.triangledown,

     location=location.absolute,

     color=bearColor,

     size=size.tiny,

     force_overlay=true,

     display=display.all - display.status_line - display.price_scale

)

//====================================================

// HUMAN-READABLE MARKET CONTEXT

//====================================================

plot(

     showReferenceMA ? referenceMA : na,

     title="Reference MA",

     color=color.new(color.gray, 40),

     linewidth=1,

     force_overlay=true,

     display=display.all - display.status_line - display.price_scale

)

priceStretchScore = distancePercentile
marketActivityScore = atrPercentile

f_strength_score(float value) =>
    value >= 1.00 ? 10 : value >= 0.80 ? 9 : value >= 0.60 ? 8 : value >= 0.45 ? 7 : value >= 0.35 ? 6 : value >= 0.25 ? 5 : value >= 0.20 ? 4 : value >= 0.15 ? 3 : value >= 0.10 ? 2 : 1

trendStrengthScore = f_strength_score(trendStrengthATR)

priceStretchBlocked =

     bullAlignment ? not longExtensionOK :

     bearAlignment ? not shortExtensionOK :

     false

marketActivityBlocked = not volatilityFilterOK
trendStrengthBlocked = not trendSeparationFilterOK

tradeWindowReady =

     (bullAlignment or bearAlignment) and

     not priceStretchBlocked and

     not marketActivityBlocked and

     not trendStrengthBlocked

tradeWindowText =

     not (bullAlignment or bearAlignment) ? "WAIT - MIXED TREND" :

     priceStretchBlocked and marketActivityBlocked and trendStrengthBlocked ? "WAIT - 3 FILTERS" :

     priceStretchBlocked and marketActivityBlocked ? "WAIT - EXTENDED + LOW ACTIVITY" :

     priceStretchBlocked and trendStrengthBlocked ? "WAIT - EXTENDED + WEAK TREND" :

     marketActivityBlocked and trendStrengthBlocked ? "WAIT - LOW ACTIVITY + WEAK TREND" :

     priceStretchBlocked ? "WAIT - PRICE EXTENDED" :

     marketActivityBlocked ? "WAIT - LOW ACTIVITY" :

     trendStrengthBlocked ? "WAIT - WEAK TREND" :

     "WINDOW OPEN"

tradeWindowColor = tradeWindowReady ? color.white : color.orange
tradeWindowBg = tradeWindowReady ? color.new(color.aqua, 80) : color.new(color.black, 10)

currentPresetText =

     useAutoPreset ?

         autoIs1m ? "1m EMA 7/13" :

         autoIs5m ? "5m EMA 50/100" :

         autoIs15m ? "15m EMA 20/50" :

         autoIs1h ? "1H EMA 135/365" :

         "4H Price/EMA200" :

     (upperTfInput == "" ? timeframe.period : upperTfInput) + " " + f_ma_short_name(upperMaMethod) + " " + str.tostring(upperFastLen) + "/" + str.tostring(upperSlowLen)

higherPresetText =

     useAutoPreset ?

         autoIs1m ? "15m EMA 20/50" :

         autoIs5m ? "1H EMA 135/365" :

         autoIs15m ? "4H Price/EMA200" :

         "1D EMA 5/22" :

     lowerTf + " " + f_ma_short_name(lowerMaMethod) + " " + str.tostring(lowerFastLen) + "/" + str.tostring(lowerSlowLen)

//====================================================

// TABLE POSITION

//====================================================

tablePosition =

     tablePositionInput == "Top Left" ? position.top_left :

     tablePositionInput == "Bottom Right" ? position.bottom_right :

     tablePositionInput == "Bottom Left" ? position.bottom_left :

     position.top_right

//====================================================

// CONTEXT TABLE — MAIN CHART

// NOW = current value. RULE = the condition required for entries.

//====================================================

var table contextTable = table.new(tablePosition, 3, 7, border_width=1, force_overlay=true)

if barstate.islast

    if showContextTable

        trendText = bullAlignment ? "LONG" : bearAlignment ? "SHORT" : "MIXED"
        trendColor = bullAlignment ? bullColor : bearAlignment ? bearColor : color.gray

        stretchNow = na(priceStretchScore) ? "N/A" : str.tostring(priceStretchScore, "0.0") + "/100"
        activityNow = na(marketActivityScore) ? "N/A" : str.tostring(marketActivityScore, "0.0") + "/100"
        strengthNow = str.tostring(trendStrengthScore) + "/10"

        stretchRule = "< " + str.tostring(int(maxPriceStretch)) + (priceStretchBlocked ? "  WAIT" : "  OK")
        activityRule = ">= " + str.tostring(int(minMarketActivity)) + (marketActivityBlocked ? "  WAIT" : "  OK")
        strengthRule = ">= " + str.tostring(minTrendStrength) + (trendStrengthBlocked ? "  WAIT" : "  OK")

        table.cell(contextTable, 0, 0, "Trend", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 1, 0, trendText, text_color=trendColor, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 2, 0, useAutoPreset ? "AUTO" : "CUSTOM", text_color=color.silver, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(contextTable, 0, 1, "Current", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 1, 1, currentPresetText, text_color=color.silver, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 2, 1, "", bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(contextTable, 0, 2, "Higher", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 1, 2, higherPresetText, text_color=color.silver, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 2, 2, "", bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(contextTable, 0, 3, "Stretch", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 1, 3, stretchNow, text_color=priceStretchBlocked ? color.orange : color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 2, 3, stretchRule, text_color=priceStretchBlocked ? color.orange : color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(contextTable, 0, 4, "Activity", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 1, 4, activityNow, text_color=marketActivityBlocked ? color.orange : color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 2, 4, activityRule, text_color=marketActivityBlocked ? color.orange : color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(contextTable, 0, 5, "Strength", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 1, 5, strengthNow, text_color=trendStrengthBlocked ? color.orange : color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 2, 5, strengthRule, text_color=trendStrengthBlocked ? color.orange : color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(contextTable, 0, 6, "Trade Window", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(contextTable, 1, 6, tradeWindowText, text_color=tradeWindowColor, bgcolor=tradeWindowBg, text_size=tableTextSize)
        table.cell(contextTable, 2, 6, "", bgcolor=color.new(color.black, 10), text_size=tableTextSize)

    else

        table.clear(contextTable, 0, 0, 2, 6)

//====================================================

// TARGET PERFORMANCE TABLE

// This is not a P&L backtest. It measures whether a signal reached
// the selected favorable move within the selected time window.
// Signals without price bars in their window are omitted from the denominator.

//====================================================

perfTablePosition =

     perfTablePositionInput == "Top Left" ? position.top_left :

     perfTablePositionInput == "Top Right" ? position.top_right :

     perfTablePositionInput == "Bottom Left" ? position.bottom_left :

     position.bottom_right

var table perfTable = table.new(perfTablePosition, 2, 8, border_width=1, force_overlay=true)

if barstate.islast

    if showPerformanceTable

        hitRateText = na(perfHitRate) ? "N/A" : str.tostring(perfHitRate, "0.0") + "%"

        table.cell(perfTable, 0, 0, "Target Performance", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(perfTable, 1, 0, "", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(perfTable, 0, 1, "Target Move", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(perfTable, 1, 1, f_move_text(targetDistance), text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(perfTable, 0, 2, "Signal Window", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(perfTable, 1, 2, str.tostring(signalWindowMinutes) + " min", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(perfTable, 0, 3, "Signals", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(perfTable, 1, 3, str.tostring(perfSignals) + "  (" + str.tostring(perfActive) + " active)", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(perfTable, 0, 4, "Signals Reaching Move", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(perfTable, 1, 4, na(perfHitRate) ? "N/A" : str.tostring(perfHits) + "/" + str.tostring(perfClosed) + " (" + hitRateText + ")", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(perfTable, 0, 5, "Median Max Move", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(perfTable, 1, 5, f_move_text(perfMedianMaxMove), text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(perfTable, 0, 6, "Avg Max Move", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(perfTable, 1, 6, f_move_text(perfAvgMaxMove), text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

        table.cell(perfTable, 0, 7, "Avg Time", text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)
        table.cell(perfTable, 1, 7, f_minutes_text(perfAvgTimeToTarget), text_color=color.white, bgcolor=color.new(color.black, 10), text_size=tableTextSize)

    else

        table.clear(perfTable, 0, 0, 1, 7)

//====================================================

// ALERTS

//====================================================

alertcondition(

     barstate.isconfirmed and alignmentState == 1 and alignmentState[1] != 1,

     title="Bullish Trend Stripes Alignment",

     message="Trend Stripes Alignment: {{ticker}} {{interval}} - both trend stripes are bullish. Trade filters may still block signals."

)

alertcondition(

     barstate.isconfirmed and alignmentState == -1 and alignmentState[1] != -1,

     title="Bearish Trend Stripes Alignment",

     message="Trend Stripes Alignment: {{ticker}} {{interval}} - both trend stripes are bearish. Trade filters may still block signals."

)

alertcondition(

     buySignal,

     title="Allowed Buy Signal",

     message="Trend Stripes Alignment: {{ticker}} {{interval}} - BUY signal after trade filters."

)

alertcondition(

     sellSignal,

     title="Allowed Sell Signal",

     message="Trend Stripes Alignment: {{ticker}} {{interval}} - SELL signal after trade filters."

)
````
