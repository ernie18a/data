<!-- tradingview-pine-id: PUB;01cf855f36e34f5ebf795b8c4733673a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ATR Dashboard

Source: https://www.tradingview.com/script/PEXbNyVW-ATR-Dashboard-Volatility-Quantifier/

## Description

ATR Dashboard

A simple volatility dashboard that displays current ATR values in a compact table in the top-right corner of the chart.

The indicator is designed to make ATR easier to quantify at a glance, especially when developing rules around changing volatility conditions. It displays three independently configurable ATR periods so you can compare short-term, standard, and longer-term volatility.

Features

[*]Short ATR – Default length: 5
[*]Standard ATR – Default length: 14
[*]Long ATR – Default length: 50
[*]Displays ATR in both points and ticks
[*]Automatically uses the instrument's minimum tick size
[*]Configurable table text size
[*]Designed to work with TradingView Bar Replay

Short / Long Ratio

The Short / Long row compares the short-term ATR to the long-term ATR:

Short ATR ÷ Long ATR × 100

This provides a quick indication of whether recent volatility is expanding or contracting relative to the longer-term baseline.

For example:

[*]70% – Recent volatility is significantly lower than the longer-term baseline
[*]100% – Recent volatility is approximately equal to the baseline
[*]150% – Recent volatility is about 50% higher than the baseline
[*]200% – Recent volatility is roughly double the baseline

This ratio can be useful for identifying volatility expansion or contraction even before a slower ATR measurement fully reacts.

The dashboard is intended primarily as an observation and rule-development tool. For example, it can help identify conditions such as:

ATR above X → reduce position size
ATR below X → avoid low-volatility conditions
Short / Long above X% → volatility expansion

The default 5 / 14 / 50 settings are simply a starting point and can be adjusted for different instruments, timeframes, or trading styles.

Here's an example of the data table with large text:
[image]https://www.tradingview.com/x/S1Oj9gv9/[/image]

---

## Source Code

````pine
//@version=6
indicator("ATR Dashboard", overlay=true)

//----------------------------------------------------
// Inputs
//----------------------------------------------------
groupATR = "ATR Settings"

shortLen = input.int(
     5,
     "Short ATR Length",
     minval=1,
     group=groupATR,
     tooltip="Short-term ATR. Reacts quickly to changes in volatility."
)

standardLen = input.int(
     14,
     "Standard ATR Length",
     minval=1,
     group=groupATR,
     tooltip="Standard ATR lookback. 14 is the traditional default."
)

longLen = input.int(
     50,
     "Long ATR Length",
     minval=1,
     group=groupATR,
     tooltip="Longer-term ATR. Useful as a baseline for current volatility."
)

groupDisplay = "Display"

showTicks = input.bool(
     true,
     "Show ATR in Ticks",
     group=groupDisplay
)

showRatio = input.bool(
     true,
     "Show Short vs Long Ratio",
     group=groupDisplay,
     tooltip="Compares the short ATR to the long ATR. Above 100% means short-term volatility is elevated relative to the longer-term baseline."
)

textSizeInput = input.string(
     "Small",
     "Table Text Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=groupDisplay
)

//----------------------------------------------------
// Text Size
//----------------------------------------------------
tableTextSize = switch textSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large

//----------------------------------------------------
// ATR Calculations
//----------------------------------------------------
atrShort = ta.atr(shortLen)
atrStandard = ta.atr(standardLen)
atrLong = ta.atr(longLen)

// Convert ATR to ticks.
// Uses the instrument's native minimum tick size,
// so this works automatically for NQ, MNQ, ES, stocks, etc.
shortTicks = atrShort / syminfo.mintick
standardTicks = atrStandard / syminfo.mintick
longTicks = atrLong / syminfo.mintick

// Short-term ATR relative to long-term ATR.
atrRatio = atrLong != 0 ? (atrShort / atrLong) * 100.0 : na

//----------------------------------------------------
// Colors
//----------------------------------------------------
headerBg = color.rgb(45, 45, 45)
labelBg  = color.rgb(30, 30, 30)
valueBg  = color.rgb(20, 20, 20)

headerText = color.white
labelText  = color.silver
valueText  = color.white

//----------------------------------------------------
// Table
//----------------------------------------------------
var table atrTable = table.new(
     position.top_right,
     3,
     5,
     frame_color=color.rgb(80, 80, 80),
     frame_width=1,
     border_color=color.rgb(60, 60, 60),
     border_width=1
)

//----------------------------------------------------
// Update Table
//----------------------------------------------------
if barstate.islast

    // Header
    table.cell(
         atrTable, 0, 0,
         "ATR",
         bgcolor=headerBg,
         text_color=headerText,
         text_size=tableTextSize
    )

    table.cell(
         atrTable, 1, 0,
         "Points",
         bgcolor=headerBg,
         text_color=headerText,
         text_size=tableTextSize
    )

    table.cell(
         atrTable, 2, 0,
         "Ticks",
         bgcolor=headerBg,
         text_color=headerText,
         text_size=tableTextSize
    )

    // Short ATR
    table.cell(
         atrTable, 0, 1,
         "Short (" + str.tostring(shortLen) + ")",
         bgcolor=labelBg,
         text_color=labelText,
         text_size=tableTextSize
    )

    table.cell(
         atrTable, 1, 1,
         str.tostring(atrShort, format.mintick),
         bgcolor=valueBg,
         text_color=valueText,
         text_size=tableTextSize
    )

    table.cell(
         atrTable, 2, 1,
         showTicks ? str.tostring(shortTicks, "#.0") : "—",
         bgcolor=valueBg,
         text_color=valueText,
         text_size=tableTextSize
    )

    // Standard ATR
    table.cell(
         atrTable, 0, 2,
         "Standard (" + str.tostring(standardLen) + ")",
         bgcolor=labelBg,
         text_color=color.white,
         text_size=tableTextSize
    )

    table.cell(
         atrTable, 1, 2,
         str.tostring(atrStandard, format.mintick),
         bgcolor=valueBg,
         text_color=color.white,
         text_size=tableTextSize
    )

    table.cell(
         atrTable, 2, 2,
         showTicks ? str.tostring(standardTicks, "#.0") : "—",
         bgcolor=valueBg,
         text_color=color.white,
         text_size=tableTextSize
    )

    // Long ATR
    table.cell(
         atrTable, 0, 3,
         "Long (" + str.tostring(longLen) + ")",
         bgcolor=labelBg,
         text_color=labelText,
         text_size=tableTextSize
    )

    table.cell(
         atrTable, 1, 3,
         str.tostring(atrLong, format.mintick),
         bgcolor=valueBg,
         text_color=valueText,
         text_size=tableTextSize
    )

    table.cell(
         atrTable, 2, 3,
         showTicks ? str.tostring(longTicks, "#.0") : "—",
         bgcolor=valueBg,
         text_color=valueText,
         text_size=tableTextSize
    )

    // Short / Long Ratio
    table.cell(
         atrTable, 0, 4,
         "Short / Long",
         bgcolor=labelBg,
         text_color=labelText,
         text_size=tableTextSize
    )

    table.cell(
         atrTable, 1, 4,
         showRatio ? str.tostring(atrRatio, "#.0") + "%" : "—",
         bgcolor=valueBg,
         text_color=valueText,
         text_size=tableTextSize
    )

    table.cell(
         atrTable, 2, 4,
         "",
         bgcolor=valueBg,
         text_color=valueText,
         text_size=tableTextSize
    )
````
