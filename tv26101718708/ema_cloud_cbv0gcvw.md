# EMA Cloud

- url: https://www.tradingview.com/script/cbv0gCvW-EMA-Cloud/
- type: indicator
- pine_id: PUB;697989f6d92c43d4a881c3f352da7bd8
- version: 2.0

## Description

OBJECTTIVE: Create a EMA Cloud from a Pair of EMA Length

EMA Pairs is one of the oldest and most durable form of technical indicator which serves various purposes. In this strategy, a pair of EMA length is used where one is a "fast" exponential moving (which determines the current rhythm of the security) and the other is the "slow" exponential moving average (which determines the underlying drift in the security).

Example/Usage(s) of EMA Pairs

EMA Pairs serves different purposes. Here are an example of typical pairs that are used in institutions, market research and other published strategies:

Scalping/Intraday Momentum [5, 13] - Linda Raschke"s Classic Fast Pair; Very Reactive. Recommended Timeframe: 5-15 mins. Chart

Short-Term Swing/Intraday Trend [7, 21] - Popular on Crypto and NSE (Indian Securities); Catches Multi-Day Momentum.

Short-Term Swing [9, 21] - Slight Variation, Popular on FOREX and Futures Desks.

Institutional Gold Standard [50, 200] - The most watched global standard. The crossover strategy are (I) "Golden Crossover" when the 50 EMA crosses above 200 EMA and (II) "Death Crossover" occurs when the 50 EMA falls below the 200 EMA line.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Copywright © 2026 ZenithClown (Debmalya Pramanik) | https://zenithclown.github.io/ | https://www.linkedin.com/in/dpramanik/

//@version=6

// ==================================================================
// OBJECTTIVE: Create a EMA Cloud from a Pair of EMA Length
//
// EMA Pairs is one of the oldest and most durable form of technical
// indicator which serves various purposes. In this strategy, a pair
// of EMA length is used where one is a "fast" exponential moving
// (which determines the current rhythm of the security) and the other
// is the "slow" exponential moving average (which determines the
// underlying drift in the security).
//
// Example/Usage(s) of EMA Pairs
//
// EMA Pairs serves different purposes. Here are an example of typical
// pairs that are used in institutions, market research and other
// published strategies:
//
// Scalping/Intraday Momentum [5, 13] - Linda Raschke"s Classic Fast
// Pair; Very Reactive. Recommended Timeframe: 5-15 mins. Chart
//
// Short-Term Swing/Intraday Trend [7, 21] - Popular on Crypto and NSE
// (Indian Securities); Catches Multi-Day Momentum.
//
// Short-Term Swing [9, 21] - Slight Variation, Popular on FOREX and
// Futures Desks.
//
// Institutional Gold Standard [50, 200] - The most watched global
// standard. The crossover strategy are (I) "Golden Crossover" when
// the 50 EMA crosses above 200 EMA and (II) "Death Crossover" occurs
// when the 50 EMA falls below the 200 EMA line.
//
// Check https://github.com/growthio/tradingview for details.
// Check https://in.tradingview.com/u/ZenithClown/ for TV Profile.
// ==================================================================

indicator("EMA Cloud", overlay = true)
import ZenithClown/cloudTheory/4 as cloudTheory

// ------------------------------------------------------------------
// INPUT(s) for EMA Cloud Pair(s) to Determine Underlying Movement
//
// Give the option to chose user-required source settings which is
// passed as a series value to the library function.
// ------------------------------------------------------------------

src = input.source(
    close, 'Candle Source'
)

// ------------------------------------------------------------------
// INPUT(s) for Settings for the Short Cloud - Determines Short Trend
//
// This controls the "short cloud" which is a pair of EMA length of
// shorter length. The cloud determines the current rhythm of the
// market within a range of two smaller lengths.
// ------------------------------------------------------------------

shortFast = input.int(
    7, "Fast Length", group = "Short Cloud", inline = "SCL"
)

shortSlow = input.int(
    21, "Slow Length", group = "Short Cloud", inline = "SCL"
)

// ------------------------------------------------------------------
// INPUT(s) for Settings for the Long Cloud - Determines Long Trend
//
// This controls the "long cloud" which determines the securities'
// underlying drift for a two longer EMA pairs.
// ------------------------------------------------------------------

longFast = input.int(
    30, "Fast Length", group = "Long Cloud", inline = "LCL"
)

longSlow = input.int(
    74, "Slow Length", group = "Long Cloud", inline = "LCL"
)

// ------------------------------------------------------------------
// INPUT(s) for Settings for the Cloud Color based on the Sentiment
// ------------------------------------------------------------------

sBullColor = input.color(
    color.new(color.green, 85), "BULL (short)"
    , group = "Color Settings", inline = "CLS"
)

sBearColor = input.color(
    color.new(color.red, 85), "BEAR (short)"
    , group = "Color Settings", inline = "CLS"
)

sNeutralColor = input.color(
    color.new(color.yellow, 85), "NEUTRAL (short)"
    , group = "Color Settings", inline = "CLS"
)

lBullColor = input.color(
    color.new(color.green, 70), "BULL (long)"
    , group = "Color Settings", inline = "CLL"
)

lBearColor = input.color(
    color.new(color.red, 70), "BEAR (long)"
    , group = "Color Settings", inline = "CLL"
)

lNeutralColor = input.color(
    color.new(color.yellow, 70), "NEUTRAL (long)"
    , group = "Color Settings", inline = "CLL"
)

// ------------------------------------------------------------------
// INPUT(s) for Settings for Displaying the EMA Cross
//
// EMA Cross is the "pivotal" point which may indicate that there is
// a changeover in the underlying security. It is recommended that the
// "short cloud" EMA cross is ignored (default false) as they might
// introduce too many noise - however, these signals can be useful for
// an intraday setup when the overall drift ("longer cloud") has the
// opposite signal.
//
// EMA Cross is an indicator integrated into "Cloud Theory" which is
// inspired from the "EMA Cross Indicator" by d.mark165 user. The
// indicator is same, with additional controls.
// ------------------------------------------------------------------

markShortCross = input.bool(
    false, "Mark Short Cloud Crossings"
    , group = "Indicate EMA Cross"
)

markLongCross = input.bool(
    true, "Mark Long Cloud Crossings"
    , group = "Indicate EMA Cross"
)

// ------------------------------------------------------------------
// Import Trading View Library & Get Values:: drawCloud()
// ------------------------------------------------------------------

[sEMAFast, sEMASlow, sMktSentiment, sUpCross, sDnCross] = cloudTheory.drawCloud(
    shortFast, shortSlow, src
)

[lEMAFast, lEMASlow, lMktSentiment, lUpCross, lDnCross] = cloudTheory.drawCloud(
    longFast, longSlow, src
)

// ------------------------------------------------------------------
// EMA Cloud - Get the Color Settings & Draw over the Instrument
// ------------------------------------------------------------------

shFillColor = sMktSentiment == 1 ? sBullColor : sMktSentiment == -1 ? sBearColor : sNeutralColor
lnFillColor = lMktSentiment == 1 ? lBullColor : lMktSentiment == -1 ? lBearColor : lNeutralColor

// ? 2026-04-26:: Short Cloud Drawing(s); Optional Show EMA Cross
spFast = plot(sEMAFast, "Fast EMA (short)", color = color.new(color.black, 20), display = display.none)
spSlow = plot(sEMASlow, "Slow EMA (short)", color = color.new(color.black, 20), display = display.none)
fill(spFast, spSlow, color = shFillColor, title = "EMA Short Cloud")


plotshape(
    sUpCross and markShortCross, style = shape.triangleup, location = location.belowbar
    , color = color.black, size = size.tiny, title = "Short BULL Crossover", text = "S"
)

plotshape(
    sDnCross and markShortCross, style = shape.triangledown, location = location.abovebar
    , color = color.black, size = size.tiny, title = "Short BEAR Crossover", text = "S"
)

// ? 2026-04-26:: Long Clowd Drawings; Optional Show EMA Cross
lpFast = plot(lEMAFast, "Fast EMA (long)", color = color.new(color.black, 20), display = display.none)
lpSlow = plot(lEMASlow, "Slow EMA (long)", color = color.new(color.black, 20), display = display.none)
fill(lpFast, lpSlow, color = lnFillColor, title = "EMA Long Cloud")

plotshape(
    lUpCross and markLongCross, style = shape.triangleup, location = location.belowbar
    , color = color.black, size = size.tiny, title = "Long BULL Crossover", text = "L"
)

plotshape(
    lDnCross and markLongCross, style = shape.triangledown, location = location.abovebar
    , color = color.black, size = size.tiny, title = "Long BEAR Crossover", text = "L"
)

// ------------------------------------------------------------------
// Import Trading View Library & Get Values:: priceAction() [WIP]
// ------------------------------------------------------------------
[_, _, _, _, _, _, shortPriceActionScore] = cloudTheory.priceAction(
    shortFast, shortSlow, src, 14
)

[_, _, _, _, _, _, longPriceActionScore] = cloudTheory.priceAction(
    longFast, longSlow, src, 14
)

var label ssLabel = na
var label lsLabel = na

shLabelColor = (
    shortPriceActionScore < -0.25 ? sBearColor :
    shortPriceActionScore < 0.25 ? sNeutralColor : sBullColor
)

lnLabelColor = (
    longPriceActionScore < -0.25 ? lBearColor : 
    longPriceActionScore < 0.25 ? lNeutralColor : lBullColor
)

if barstate.islast
    label.delete(ssLabel)
    ssLabel := label.new(
        bar_index, sEMAFast, "PA1: " + str.tostring(shortPriceActionScore, "#.##")
        , style = label.style_label_left, color = shLabelColor
        , textcolor = color.black, size = size.small
    )

if barstate.islast
    label.delete(lsLabel)
    lsLabel := label.new(
        bar_index, lEMAFast, "PA2: " + str.tostring(longPriceActionScore, "#.##")
        , style = label.style_label_left, color = lnLabelColor
        , textcolor = color.black, size = size.small
    )
````
