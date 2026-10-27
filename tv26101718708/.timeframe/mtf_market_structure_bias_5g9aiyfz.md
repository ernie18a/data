# MTF Market Structure Bias

- url: https://www.tradingview.com/script/5g9aiYFZ-MTF-Market-Structure-Bias/
- type: indicator
- pine_id: PUB;62bdc4fd27354e4daf26b17c91514eb9
- version: 1.0

## Description

[b]Multi-TimeFrame Market Structure Bias[/b]

A customizable multi-timeframe trend and market structure indicator designed to help traders align higher timeframe directional bias with lower timeframe trend structure using EMA-based regime analysis.

This indicator uses the relationship between the EMA 20 and EMA 50 across two user-defined timeframes to identify:

directional bias,
market structure alignment,
and overall trend condition.

It is built to simplify multi-timeframe analysis into a clean and intuitive dashboard suitable for intraday, swing, futures/fx/crypto trading.

[b]
How It Works[/b]

The indicator compares:

EMA 20
EMA 50

on two independently customizable timeframes:

[b]1. Directional Bias Timeframe
[/b]
Defines the broader market direction.

Example:

1H
4H
Daily


[b]2. Trend Structure Timeframe[/b]

Defines the lower timeframe trend condition and execution environment.

[b]Regime Logic[/b]

[i]Bullish Condition[/i]

EMA 20 > EMA 50

[i]Bearish Condition[/i]

EMA 20 < EMA 50

The indicator then evaluates whether both timeframes are aligned.

Alignment States: FULL BULLISH / FULL BEARISH / MIXED
FULL BULLISH : Both timeframes bullish
FULL BEARISH : Both timeframes bearish
MIXED: Not Aligned


[b]Example Configurations[/b]
Intraday Trading
Directional Bias TF = 1H
Structure TF = 15M
Swing Trading
Directional Bias TF = Daily
Structure TF = 4H
Scalping
Directional Bias TF = 15M
Structure TF = 5M


[b]This indicator helps traders:[/b]

stay aligned with dominant trend flow,
avoid counter-trend trades,
improve trade selection,
filter low-quality setups,
and better understand overall market structure.

When higher and lower timeframe trends align, probability and momentum continuation often improve significantly.

## Source Code

````pine
//@version=6
indicator("MTF Market Structure Bias", overlay = true)

// =====================================================
// INPUTS
// =====================================================
fastLen = input.int(20, title = "Fast EMA")
slowLen = input.int(50, title = "Slow EMA")

// User-selectable timeframes
biasTF      = input.timeframe("30", title = "Directional Bias TF")
structureTF = input.timeframe("15", title = "Trend Structure TF")

// =====================================================
// DIRECTIONAL BIAS
// =====================================================
biasEMA20 = request.security(
     syminfo.tickerid,
     biasTF,
     ta.ema(close, fastLen)
)

biasEMA50 = request.security(
     syminfo.tickerid,
     biasTF,
     ta.ema(close, slowLen)
)

biasBullish = biasEMA20 > biasEMA50

biasText = biasBullish
     ? "BULLISH"
     : "BEARISH"

biasColor = biasBullish
     ? color.green
     : color.red

// =====================================================
// TREND STRUCTURE
// =====================================================
structureEMA20 = request.security(
     syminfo.tickerid,
     structureTF,
     ta.ema(close, fastLen)
)

structureEMA50 = request.security(
     syminfo.tickerid,
     structureTF,
     ta.ema(close, slowLen)
)

structureBullish = structureEMA20 > structureEMA50

structureText = structureBullish
     ? "BULLISH"
     : "BEARISH"

structureColor = structureBullish
     ? color.rgb(5, 75, 41)
     : color.rgb(199, 77, 58)

// =====================================================
// OVERALL ALIGNMENT
// =====================================================
alignedBullish = biasBullish and structureBullish
alignedBearish = not biasBullish and not structureBullish

alignmentText =
     alignedBullish ? "FULL BULLISH" :
     alignedBearish ? "FULL BEARISH" :
     "MIXED"

alignmentColor =
     alignedBullish ? color.rgb(115, 221, 118) :
     alignedBearish ? color.red :
     color.yellow

// =====================================================
// PLOTS
// =====================================================
plot(
     structureEMA20,
     title = "Structure EMA 20",
     color = color.lime,
     linewidth = 2
)

plot(
     structureEMA50,
     title = "Structure EMA 50",
     color = color.orange,
     linewidth = 2
)

// =====================================================
// TABLE
// =====================================================
var table biasTable = table.new(
     position.top_right,
     columns = 2,
     rows = 4,
     border_width = 1
)

// =====================================================
// UPDATE TABLE
// =====================================================
if barstate.islast

    // Header
    table.cell(
         biasTable, 0, 0,
         "Timeframe",
         bgcolor = color.gray,
         text_color = color.white
    )

    table.cell(
         biasTable, 1, 0,
         "Bias",
         bgcolor = color.gray,
         text_color = color.white
    )

    // Directional Bias
    table.cell(
         biasTable, 0, 1,
         biasTF + " Direction",
         text_color = color.white
    )

    table.cell(
         biasTable, 1, 1,
         biasText,
         bgcolor = biasColor,
         text_color = color.white
    )

    // Trend Structure
    table.cell(
         biasTable, 0, 2,
         structureTF + " Structure",
         text_color = color.white
    )

    table.cell(
         biasTable, 1, 2,
         structureText,
         bgcolor = structureColor,
         text_color = color.white
    )

    // Alignment
    table.cell(
         biasTable, 0, 3,
         "Alignment",
         text_color = color.white
    )

    table.cell(
         biasTable, 1, 3,
         alignmentText,
         bgcolor = alignmentColor,
         text_color = color.black
    )

// =====================================================
// BACKGROUND
// =====================================================
bgcolor(
     alignedBullish
     ? color.new(#078e0c, 92)
     : alignedBearish
     ? color.new(#d63d3d, 92)
     : color.new(color.gray, 92)
)
````
