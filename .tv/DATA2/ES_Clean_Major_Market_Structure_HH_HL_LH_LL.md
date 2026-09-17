<!-- tradingview-pine-id: PUB;5ca85134f5424761a528d5358ebb40c9 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ES Clean Major Market Structure - HH HL LH LL

Source: https://www.tradingview.com/script/nkZY3j8m-ES-Clean-Major-Market-Structure-HH-HL-LH-LL/

## Description

ES Clean Major Market Structure – HH HL LH LL

This indicator is designed to provide a clean visual representation of market structure by identifying meaningful swing highs and swing lows while filtering out smaller price movements.

The script classifies confirmed swing points as:

HH – Higher High: A swing high above the previous swing high.
HL – Higher Low: A swing low above the previous swing low.
LH – Lower High: A swing high below the previous swing high.
LL – Lower Low: A swing low below the previous swing low.

The goal is to make it easier to identify developing bullish and bearish market structure without filling the chart with signals from every small price fluctuation.

Market Structure

The indicator maintains a directional structure bias:

Bullish Structure

Higher Highs (HH)
Higher Lows (HL)
Dashboard displays: BULLISH
Watch for continued HL → HH development

Bearish Structure

Lower Lows (LL)
Lower Highs (LH)
Dashboard displays: BEARISH
Watch for continued LH → LL development

The structure dashboard is intended as a quick visual reference and should not be interpreted as an automatic trade signal.

Swing Strength

Swing Strength determines how many bars on each side of a potential swing are required before that swing can be confirmed.

For example, with Swing Strength set to 2, a pivot requires two bars on the left and two bars on the right.

Because right-side bars are required, HH/HL/LH/LL labels are confirmed after the actual pivot occurs and are plotted back on the pivot bar. They should not be interpreted as signals that were available at the exact moment of the labeled candle.

Minimum Swing Move

Minimum Swing Move filters smaller changes between swing points.

Increasing this value produces fewer, more significant structure labels. Decreasing it makes the indicator more sensitive to smaller price movements.

For ES, the default settings are:

Swing Strength: 2
Minimum Swing Move: 1.50 points

These settings can be adjusted depending on timeframe and trading style.

Additional Chart References

The indicator also displays:

EMA 14 – Short-term price momentum reference
SMA 20 – Trend reference
Session Open – Daily/session opening level
50% Session Midpoint – Midpoint between the developing session high and session low

Intended Use

This indicator is designed primarily as a market-structure visualization tool, not an automated entry system.

One possible way to interpret the structure is:

Bullish: HH → HL → HH

Bearish: LL → LH → LL

Traders may use the structure labels together with their own price-action, support/resistance, liquidity, risk-management, and higher-timeframe analysis.

The indicator can be used on different intraday timeframes. Lower timeframes generally produce more structure changes, while higher timeframes naturally filter more market noise.

Disclaimer: This script is provided for educational and informational purposes only. It does not provide financial advice or guarantee future market performance. Users are responsible for their own trading decisions and risk management.

---

## Source Code

````pine
//@version=6
indicator(
     "ES Clean Major Market Structure - HH HL LH LL",
     overlay=true,
     max_labels_count=500
     )

//=====================================================================
// 1. SETTINGS
//=====================================================================

swingLen =
     input.int(
         2,
         "Swing Strength",
         minval=1,
         maxval=10
     )

minSwingMove =
     input.float(
         1.50,
         "Minimum Swing Move (ES Points)",
         minval=0.25,
         step=0.25
     )

showHH =
     input.bool(true, "Show HH")

showHL =
     input.bool(true, "Show HL")

showLH =
     input.bool(true, "Show LH")

showLL =
     input.bool(true, "Show LL")

showBias =
     input.bool(true, "Show Structure Dashboard")


//=====================================================================
// 2. SESSION LEVELS
//=====================================================================

var float globalOpen  = na
var float sessionHigh = na
var float sessionLow  = na

isNewDay =
     timeframe.change("D")

if isNewDay or na(globalOpen)

    globalOpen := open
    sessionHigh := high
    sessionLow := low

else

    sessionHigh :=
         math.max(sessionHigh, high)

    sessionLow :=
         math.min(sessionLow, low)

midpoint50 =
     (sessionHigh + sessionLow) / 2.0


//=====================================================================
// 3. MOVING AVERAGES
//=====================================================================

sma20 =
     ta.sma(close, 20)

ema14 =
     ta.ema(close, 14)


//=====================================================================
// 4. RAW PIVOTS
//=====================================================================

pivotHigh =
     ta.pivothigh(
         high,
         swingLen,
         swingLen
     )

pivotLow =
     ta.pivotlow(
         low,
         swingLen,
         swingLen
     )


//=====================================================================
// 5. STORE SWING HIGHS
//=====================================================================

var float previousSwingHigh = na
var float latestSwingHigh   = na

if not na(pivotHigh)

    previousSwingHigh :=
         latestSwingHigh

    latestSwingHigh :=
         pivotHigh


//=====================================================================
// 6. STORE SWING LOWS
//=====================================================================

var float previousSwingLow = na
var float latestSwingLow   = na

if not na(pivotLow)

    previousSwingLow :=
         latestSwingLow

    latestSwingLow :=
         pivotLow


//=====================================================================
// 7. RAW STRUCTURE
//=====================================================================

rawHH =
     not na(previousSwingHigh) and
     not na(latestSwingHigh) and
     latestSwingHigh > previousSwingHigh


rawLH =
     not na(previousSwingHigh) and
     not na(latestSwingHigh) and
     latestSwingHigh < previousSwingHigh


rawHL =
     not na(previousSwingLow) and
     not na(latestSwingLow) and
     latestSwingLow > previousSwingLow


rawLL =
     not na(previousSwingLow) and
     not na(latestSwingLow) and
     latestSwingLow < previousSwingLow


//=====================================================================
// 8. FILTER SMALL SWINGS
//=====================================================================

highMoveLargeEnough =
     not na(previousSwingHigh) and
     not na(latestSwingHigh) and
     math.abs(
         latestSwingHigh -
         previousSwingHigh
     ) >= minSwingMove


lowMoveLargeEnough =
     not na(previousSwingLow) and
     not na(latestSwingLow) and
     math.abs(
         latestSwingLow -
         previousSwingLow
     ) >= minSwingMove


majorHH =
     rawHH and
     highMoveLargeEnough


majorLH =
     rawLH and
     highMoveLargeEnough


majorHL =
     rawHL and
     lowMoveLargeEnough


majorLL =
     rawLL and
     lowMoveLargeEnough


//=====================================================================
// 9. MARKET STRUCTURE BIAS
//=====================================================================

//  1 = Bullish
// -1 = Bearish
//  0 = Neutral

var int structureBias = 0


// Bullish structure becomes established
// when meaningful HH + HL are present.

if majorHH and rawHL
    structureBias := 1

if majorHL and rawHH
    structureBias := 1


// Bearish structure becomes established
// when meaningful LL + LH are present.

if majorLL and rawLH
    structureBias := -1

if majorLH and rawLL
    structureBias := -1


// If still neutral, allow an obvious major HH or LL
// to establish an initial directional bias.

if structureBias == 0

    if majorHH
        structureBias := 1

    if majorLL
        structureBias := -1


//=====================================================================
// 10. FILTER VISIBLE LABELS BY DOMINANT STRUCTURE
//=====================================================================

// Bullish structure:
// show HH and HL.
//
// Bearish structure:
// show LH and LL.

showMajorHH =
     majorHH and
     (
         structureBias == 1 or
         structureBias == 0
     )


showMajorHL =
     majorHL and
     structureBias == 1


showMajorLH =
     majorLH and
     structureBias == -1


showMajorLL =
     majorLL and
     (
         structureBias == -1 or
         structureBias == 0
     )


//=====================================================================
// 11. HH LABEL
//=====================================================================

if not na(pivotHigh) and
   showMajorHH and
   showHH

    label.new(
         bar_index - swingLen,
         pivotHigh,
         "HH",
         style=label.style_label_down,
         color=color.green,
         textcolor=color.white,
         size=size.small
     )


//=====================================================================
// 12. LH LABEL
//=====================================================================

if not na(pivotHigh) and
   showMajorLH and
   showLH

    label.new(
         bar_index - swingLen,
         pivotHigh,
         "LH",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small
     )


//=====================================================================
// 13. HL LABEL
//=====================================================================

if not na(pivotLow) and
   showMajorHL and
   showHL

    label.new(
         bar_index - swingLen,
         pivotLow,
         "HL",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small
     )


//=====================================================================
// 14. LL LABEL
//=====================================================================

if not na(pivotLow) and
   showMajorLL and
   showLL

    label.new(
         bar_index - swingLen,
         pivotLow,
         "LL",
         style=label.style_label_up,
         color=color.red,
         textcolor=color.white,
         size=size.small
     )


//=====================================================================
// 15. CHART LEVELS
//=====================================================================

plot(
     globalOpen,
     title="Session Open",
     color=color.yellow,
     linewidth=2,
     style=plot.style_linebr
     )


plot(
     midpoint50,
     title="50% Session Midpoint",
     color=color.green,
     linewidth=2,
     style=plot.style_linebr
     )


plot(
     sma20,
     title="SMA 20",
     color=color.blue,
     linewidth=2
     )


plot(
     ema14,
     title="EMA 14",
     color=color.purple,
     linewidth=2
     )


//=====================================================================
// 16. STRUCTURE DASHBOARD
//=====================================================================

var table biasTable =
     table.new(
         position.top_right,
         2,
         2,
         border_width=1
     )


if barstate.islast and showBias

    biasText =
         structureBias == 1
         ? "BULLISH"
         : structureBias == -1
         ? "BEARISH"
         : "NEUTRAL"


    watchText =
         structureBias == 1
         ? "Look for HL → HH"
         : structureBias == -1
         ? "Look for LH → LL"
         : "Wait for structure"


    table.cell(
         biasTable,
         0,
         0,
         "STRUCTURE",
         bgcolor=color.rgb(20,20,20),
         text_color=color.white
     )


    table.cell(
         biasTable,
         1,
         0,
         biasText,
         bgcolor=color.rgb(20,20,20),
         text_color=color.white
     )


    table.cell(
         biasTable,
         0,
         1,
         "WATCH",
         text_color=color.white
     )


    table.cell(
         biasTable,
         1,
         1,
         watchText,
         text_color=color.white
     )
````
