<!-- tradingview-pine-id: PUB;8b2ab8f80d2d425b98fb1dc43bbe4cde -->
<!-- tradingviewscripts-format: 1 -->
# ZENKO Session FVG

Source: https://www.tradingview.com/script/14RqBrYF-ZENKO-Session-FVG/

## Description

# ZENKO FVG — Session-Based Fair Value Gap

ZENKO FVG is a clean Fair Value Gap (FVG) indicator designed to help traders identify price imbalances within selected trading sessions while keeping the chart simple and easy to read.

The indicator was developed around the ZENKO trading approach, where Fair Value Gaps are used as potential areas of interest rather than standalone entry signals.

## Core Concept

A Fair Value Gap represents an imbalance created during strong price displacement. These areas may become relevant when price later revisits them as the market searches for liquidity or rebalances inefficient price delivery.

ZENKO FVG automatically detects these imbalances and displays them directly on the chart.

## Key Features
  
• Automatic Bullish & Bearish FVG Detection  
Identifies three-candle Fair Value Gap structures automatically.

• Session-Based Filtering  
Allows traders to focus on FVGs formed during selected trading sessions such as Asia and London, reducing unnecessary zones from outside the intended trading period.

• Clean FVG Zones  
Bullish and bearish FVGs are displayed as clear zones without overcrowding the chart.

• FVG Midpoint  
Each FVG can display its 50% equilibrium level, providing an additional reference point when price returns to the imbalance.

• Customizable Display  
Users can adjust FVG colors, zone appearance, session settings and other visual parameters according to their chart preference.

• Multiple Timeframe Application  
The indicator can be applied across different chart timeframes depending on the trader's execution model.

## ZENKO Trading Approach

ZENKO FVG is primarily designed to help locate higher-quality areas of interest.

A typical ZENKO workflow may involve:

Higher-Timeframe FVG → Price returns into the area → Liquidity reaction or sweep → Lower-timeframe imbalance / IFVG confirmation → Execution.

For example, a trader may identify an important FVG on M15 and then move to lower timeframes such as M1–M4 to look for additional confirmation.

The indicator itself does not determine whether a trade should be taken. Market structure, liquidity, displacement, session context and risk management should still be considered.

## Purpose

The main objective of ZENKO FVG is simple:

**Reduce chart noise and make relevant Fair Value Gaps easier to identify.**

Instead of manually marking every imbalance, traders can use the indicator to quickly visualize FVG locations and focus their attention on price action around those areas.

## Important

ZENKO FVG is an analytical tool and should not be treated as an automated buy or sell system.

Fair Value Gaps do not guarantee that price will react, reverse or continue from a specific level. Traders should combine the indicator with their own market analysis, confirmation criteria and risk-management rules.

Past market behavior does not guarantee future results.

**ZENKO — Find the imbalance. Wait for confirmation. Execute with discipline.**

---

## Source Code

````pine
//@version=6
indicator(
     "ZENKO Session FVG",
     overlay = true,
     max_boxes_count = 200,
     max_labels_count = 200,
     max_lines_count = 200
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. SESSION SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupSession = "1. Session Settings"

// Asia & London ikut waktu Malaysia
timezoneInput = input.string(
     "Asia/Kuala_Lumpur",
     "Asia/London Timezone",
     group = groupSession
)

// New York ikut timezone sebenar NY.
// Auto adjust Daylight Saving Time.
nyTimezoneInput = input.string(
     "America/New_York",
     "New York Timezone",
     group = groupSession
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ASIA SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
enableAsia = input.bool(
     true,
     "Enable Asia Session",
     group = groupSession
)

asiaSession = input.session(
     "0800-1400",
     "Asia Session",
     group = groupSession
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LONDON SESSION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
enableLondon = input.bool(
     true,
     "Enable London Session",
     group = groupSession
)

londonSession = input.session(
     "1400-2000",
     "London Session",
     group = groupSession
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW YORK AM SESSION
// NY local time: 9:30 AM – 12:00 PM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
enableNyAm = input.bool(
     true,
     "Enable NY AM Session",
     group = groupSession
)

nyAmSession = input.session(
     "0930-1200",
     "NY AM Session",
     group = groupSession
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW YORK LUNCH SESSION
// NY local time: 12:00 PM – 1:30 PM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
enableNyLunch = input.bool(
     true,
     "Enable NY Lunch Session",
     group = groupSession
)

nyLunchSession = input.session(
     "1200-1330",
     "NY Lunch Session",
     group = groupSession
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW YORK PM SESSION
// NY local time: 1:30 PM – 4:00 PM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
enableNyPm = input.bool(
     true,
     "Enable NY PM Session",
     group = groupSession
)

nyPmSession = input.session(
     "1330-1600",
     "NY PM Session",
     group = groupSession
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SESSION DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
inAsia = enableAsia and not na(
     time(
         timeframe.period,
         asiaSession,
         timezoneInput
     )
)

inLondon = enableLondon and not na(
     time(
         timeframe.period,
         londonSession,
         timezoneInput
     )
)

inNyAm = enableNyAm and not na(
     time(
         timeframe.period,
         nyAmSession,
         nyTimezoneInput
     )
)

inNyLunch = enableNyLunch and not na(
     time(
         timeframe.period,
         nyLunchSession,
         nyTimezoneInput
     )
)

inNyPm = enableNyPm and not na(
     time(
         timeframe.period,
         nyPmSession,
         nyTimezoneInput
     )
)

validSession =
     inAsia or
     inLondon or
     inNyAm or
     inNyLunch or
     inNyPm

sessionName = inAsia
     ? "ASIA"
     : inLondon
     ? "LONDON"
     : inNyAm
     ? "NY AM"
     : inNyLunch
     ? "NY LUNCH"
     : inNyPm
     ? "NY PM"
     : ""

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. FVG SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupFVG = "2. FVG Settings"

maximumFvg = input.int(
     4,
     "Number of FVG to Display",
     minval = 1,
     maxval = 10,
     group = groupFVG
)

minimumFvgTicks = input.int(
     1,
     "Minimum FVG Size (Ticks)",
     minval = 1,
     group = groupFVG
)

boxLength = input.int(
     100,
     "FVG Length (Bars)",
     minval = 1,
     maxval = 1000,
     group = groupFVG
)

extendUntilBreak = input.bool(
     true,
     "Extend FVG Until Broken",
     group = groupFVG
)

breakMethod = input.string(
     "Candle Close",
     "FVG Break Method",
     options = [
         "Candle Close",
         "Wick"
     ],
     group = groupFVG
)

deleteWhenBroken = input.bool(
     true,
     "Delete Only When FVG Is Broken",
     group = groupFVG
)

showBullishFvg = input.bool(
     true,
     "Show Bullish FVG",
     group = groupFVG
)

showBearishFvg = input.bool(
     true,
     "Show Bearish FVG",
     group = groupFVG
)

showLabels = input.bool(
     false,
     "Show FVG Labels",
     group = groupFVG
)

showMidLine = input.bool(
     true,
     "Show FVG Middle Line",
     group = groupFVG
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. COLOUR SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupColour = "3. Colour Settings"

bullishColour = input.color(
     color.new(color.lime, 82),
     "Bullish FVG Colour",
     group = groupColour
)

bullishBorder = input.color(
     color.lime,
     "Bullish Border Colour",
     group = groupColour
)

bearishColour = input.color(
     color.new(color.red, 82),
     "Bearish FVG Colour",
     group = groupColour
)

bearishBorder = input.color(
     color.red,
     "Bearish Border Colour",
     group = groupColour
)

midLineColour = input.color(
     color.gray,
     "Middle Line Colour",
     group = groupColour
)

midLineWidth = input.int(
     1,
     "Middle Line Width",
     minval = 1,
     maxval = 4,
     group = groupColour
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. ARRAYS
// One combined list for all bullish and bearish FVG.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[] fvgBoxes = array.new_box()
var label[] fvgLabels = array.new_label()
var line[] fvgMidLines = array.new_line()
var bool[] fvgBullish = array.new_bool()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. FVG DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
minimumFvgSize = minimumFvgTicks * syminfo.mintick

bullishGapSize = low - high[2]
bearishGapSize = low[2] - high

bullishFvg =
     bar_index >= 2 and
     validSession and
     showBullishFvg and
     low > high[2] and
     bullishGapSize >= minimumFvgSize

bearishFvg =
     bar_index >= 2 and
     validSession and
     showBearishFvg and
     high < low[2] and
     bearishGapSize >= minimumFvgSize

boxRight = bar_index + boxLength

boxExtension = extendUntilBreak
     ? extend.right
     : extend.none

lineExtension = extendUntilBreak
     ? extend.right
     : extend.none

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. CREATE BULLISH FVG
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if bullishFvg
    newBox = box.new(
         left = bar_index - 2,
         top = low,
         right = boxRight,
         bottom = high[2],
         xloc = xloc.bar_index,
         extend = boxExtension,
         bgcolor = bullishColour,
         border_color = bullishBorder,
         border_width = 1
    )

    line newMidLine = na

    if showMidLine
        bullishMidPrice = (low + high[2]) / 2.0

        newMidLine := line.new(
             x1 = bar_index - 2,
             y1 = bullishMidPrice,
             x2 = boxRight,
             y2 = bullishMidPrice,
             xloc = xloc.bar_index,
             extend = lineExtension,
             color = midLineColour,
             style = line.style_dashed,
             width = midLineWidth
        )

    label newLabel = na

    if showLabels
        newLabel := label.new(
             x = bar_index,
             y = low,
             text = sessionName + " BULL FVG",
             xloc = xloc.bar_index,
             style = label.style_label_down,
             color = bullishBorder,
             textcolor = color.black,
             size = size.tiny
        )

    array.push(fvgBoxes, newBox)
    array.push(fvgLabels, newLabel)
    array.push(fvgMidLines, newMidLine)
    array.push(fvgBullish, true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. CREATE BEARISH FVG
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if bearishFvg
    newBox = box.new(
         left = bar_index - 2,
         top = low[2],
         right = boxRight,
         bottom = high,
         xloc = xloc.bar_index,
         extend = boxExtension,
         bgcolor = bearishColour,
         border_color = bearishBorder,
         border_width = 1
    )

    line newMidLine = na

    if showMidLine
        bearishMidPrice = (low[2] + high) / 2.0

        newMidLine := line.new(
             x1 = bar_index - 2,
             y1 = bearishMidPrice,
             x2 = boxRight,
             y2 = bearishMidPrice,
             xloc = xloc.bar_index,
             extend = lineExtension,
             color = midLineColour,
             style = line.style_dashed,
             width = midLineWidth
        )

    label newLabel = na

    if showLabels
        newLabel := label.new(
             x = bar_index,
             y = high,
             text = sessionName + " BEAR FVG",
             xloc = xloc.bar_index,
             style = label.style_label_up,
             color = bearishBorder,
             textcolor = color.white,
             size = size.tiny
        )

    array.push(fvgBoxes, newBox)
    array.push(fvgLabels, newLabel)
    array.push(fvgMidLines, newMidLine)
    array.push(fvgBullish, false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 8. LIMIT NUMBER OF DISPLAYED FVG
// Delete oldest FVG when limit is exceeded.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
while array.size(fvgBoxes) > maximumFvg
    oldestBox = array.shift(fvgBoxes)
    oldestLabel = array.shift(fvgLabels)
    oldestMidLine = array.shift(fvgMidLines)
    array.shift(fvgBullish)

    box.delete(oldestBox)

    if not na(oldestLabel)
        label.delete(oldestLabel)

    if not na(oldestMidLine)
        line.delete(oldestMidLine)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 9. MANAGE BROKEN FVG
// Touched FVG remains.
// Deleted only after full invalidation.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        currentBox = array.get(fvgBoxes, i)
        currentLabel = array.get(fvgLabels, i)
        currentMidLine = array.get(fvgMidLines, i)
        isBullish = array.get(fvgBullish, i)

        fvgTop = box.get_top(currentBox)
        fvgBottom = box.get_bottom(currentBox)

        bullishBroken = breakMethod == "Candle Close"
             ? close < fvgBottom
             : low < fvgBottom

        bearishBroken = breakMethod == "Candle Close"
             ? close > fvgTop
             : high > fvgTop

        fvgBroken = isBullish
             ? bullishBroken
             : bearishBroken

        if fvgBroken
            if deleteWhenBroken
                box.delete(currentBox)

                if not na(currentLabel)
                    label.delete(currentLabel)

                if not na(currentMidLine)
                    line.delete(currentMidLine)

                array.remove(fvgBoxes, i)
                array.remove(fvgLabels, i)
                array.remove(fvgMidLines, i)
                array.remove(fvgBullish, i)

            else
                box.set_extend(currentBox, extend.none)
                box.set_right(currentBox, bar_index)

                if not na(currentMidLine)
                    line.set_extend(currentMidLine, extend.none)
                    line.set_x2(currentMidLine, bar_index)

                array.remove(fvgBoxes, i)
                array.remove(fvgLabels, i)
                array.remove(fvgMidLines, i)
                array.remove(fvgBullish, i)
````
