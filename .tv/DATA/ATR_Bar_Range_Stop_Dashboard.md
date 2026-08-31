<!-- tradingview-pine-id: PUB;7fed7917f250452ca16ced593d100659 -->
<!-- tradingviewscripts-format: 1 -->
# ATR & Bar Range Stop Dashboard

Source: https://www.tradingview.com/script/k4sNzcvv-ATR-Bar-Range-Stop-Dashboard/

## Description

# Title

**ATR & Bar Range Stop Dashboard**

## About this script

**ATR & Bar Range Stop Dashboard** is a volatility-based trade-planning tool designed to provide a quick estimate of reasonable stop-loss distance based on the current market's recent price movement.

Rather than using an arbitrary fixed stop distance, the indicator measures recent volatility using either:

* **Average True Range (ATR)**, or
* **Average Bar Range (High − Low)**

and calculates hypothetical long and short stop prices around the current market price or an optional manually entered reference price.

The purpose of the indicator is not to generate entries or trading signals. It is intended to provide a **volatility reference for stop placement and trade planning**.

A structural stop should still be based on the price level at which the trade thesis becomes invalid. This tool can then be used to evaluate whether that structural stop is unusually tight or wide relative to recent market volatility.

---

## How it works

The script calculates two measures of recent price movement:

**Average Bar Range**

This is the simple average of each candle's:

`High - Low`

over the selected lookback period.

The default lookback is **20 completed bars**.

**Average True Range**

ATR measures True Range over the selected ATR lookback period.

The default is:

`ATR(14)`

The script uses **completed bars for the volatility calculations** so the baseline is not continually distorted by the currently developing candle.

The user can select either **ATR** or **Bar Range** as the basis for the calculated Average Stop.

The basic stop distance is:

`Average Stop = Selected Volatility Measure × Stop Multiplier`

The default multiplier is **1.0x**.

---

## Stop calculations

The dashboard calculates hypothetical stops on both sides of the reference price.

**Long Stop**

`Reference Price - Average Stop - Buffer`

**Short Stop**

`Reference Price + Average Stop + Buffer`

Final stop prices are rounded to the symbol's valid minimum tick increment.

The calculated stops are intended as **volatility-based reference levels**, not automatic recommendations to place an order at those exact prices.

---

## Adaptive buffer

An additional buffer places the calculated stop slightly outside the raw volatility boundary.

### Futures

In Auto mode, the futures buffer is:

`max(2 ticks, 10% of Average Stop)`

with an adjustable maximum buffer percentage.

The default maximum is **25% of Average Stop**.

This provides a small minimum buffer in lower-volatility conditions while allowing the buffer to expand as volatility increases.

### Stocks and ETFs

The default Auto buffer is:

`10% of Average Stop`

subject to the same adjustable maximum buffer percentage.

### Manual buffer

Users can disable Auto mode and specify the buffer directly in **number of ticks**.

---

## Timeframe behavior

By default, all volatility calculations use the **current chart timeframe**.

For example:

* 2-minute chart → 2-minute volatility
* 5-minute chart → 5-minute volatility
* 15-minute chart → 15-minute volatility
* Daily chart → daily volatility

A **Manual Timeframe Override** is also available when the trader wants the dashboard to reference volatility from a different timeframe.

For example, a trader executing on a 2-minute chart may choose to calculate the stop using 5-minute volatility.

---

## Reference price

By default, the script calculates the hypothetical stop levels from the **current market price**.

An optional **Manual Entry Price** can be enabled.

This is useful after entering a trade or when planning an entry at a specific price because the stop calculations remain anchored to that reference price rather than moving continuously with the market.

The dashboard still displays the live Current Price separately.

---

## Dashboard modes

### Minimal

Designed for active trading and displays only:

* Current Price
* Average Stop and its basis
* Long Stop
* Short Stop

The **Long Stop is displayed in green** and the **Short Stop in red** for quick identification.

### Full

Displays additional volatility information:

* Average Bar Range
* ATR
* Current Bar Range
* Current Bar / Average Bar ratio
* Current Price
* Average Stop and calculation basis
* Buffer
* Long Stop
* Short Stop

---

## Display options

The dashboard can be customized using:

**Table Size**

* Tiny
* Small
* Normal
* Large
* Huge

**Horizontal Placement**

* Left
* Center
* Right

**Vertical Placement**

* Top
* Middle
* Bottom

These controls provide all nine standard TradingView table-placement combinations.

---

## Suggested interpretation

The indicator is most useful as a **context tool rather than a mechanical stop system**.

For example, if a proposed structural stop is only 0.3 ATR away from the entry while normal bars are already considerably larger than that distance, the stop may be vulnerable to ordinary market noise.

Conversely, a structural stop several ATRs away may indicate that the trade requires unusually large risk relative to current volatility.

The indicator does not determine whether the underlying trade setup is valid.

A practical workflow is:

1. Identify the trade setup.
2. Determine the price level that structurally invalidates the setup.
3. Compare that distance with the dashboard's volatility-based Average Stop.
4. Determine whether the structural stop allows acceptable risk.
5. Adjust position size rather than artificially tightening a structurally necessary stop.

---

## Default settings

**Volatility**

* Average Bar Range Length: `20`
* ATR Length: `14`

**Stop**

* Stop Basis: `ATR`
* Stop Multiplier: `1.0x`

**Buffer**

* Mode: `Auto`
* Auto Buffer: `10%`
* Futures Minimum Buffer: `2 ticks`
* Maximum Auto Buffer: `25%`

**Timeframe**

* Current chart timeframe

**Display**

* Minimal
* Small
* Top Right

All parameters are configurable.

---

## Important notes

This indicator:

* Does **not** generate buy or sell signals.
* Does **not** determine market direction.
* Does **not** automatically identify structural invalidation.
* Does **not** determine position size.
* Does **not** guarantee that a calculated stop will avoid being triggered.
* Is intended as a volatility and trade-planning tool.

ATR and average bar range describe **recent historical volatility**. Future volatility can change rapidly, particularly around economic releases, earnings, market opens, news events, or periods of reduced liquidity.

Traders should use the calculated levels together with market structure, risk management, and their own trading methodology.

---

# Release notes — Version 1.0

**Initial release**

* Added ATR-based stop-distance calculation.
* Added Average Bar Range alternative to ATR.
* Added configurable stop multiplier.
* Uses completed bars for baseline volatility calculations.
* Added automatic chart-timeframe detection.
* Added optional manual timeframe override.
* Added live Current Price display.
* Added optional Manual Entry Price for fixed stop calculations.
* Added automatic futures and equity buffer logic.
* Futures Auto Buffer defaults to the greater of 2 ticks or 10% of Average Stop.
* Stocks and ETFs default to a 10% Average Stop buffer.
* Added adjustable maximum Auto Buffer.
* Added manual tick-based buffer override.
* Added Long and Short stop price calculations rounded to valid minimum tick increments.
* Added Minimal and Full dashboard modes.
* Average Stop clearly identifies whether ATR or Bar Range is being used.
* Added configurable table size.
* Added Left / Center / Right and Top / Middle / Bottom table positioning.
* Added green Long Stop and red Short Stop highlighting.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CBeamsGlitter

//@version=6
indicator("ATR & Bar Range Stop Dashboard", overlay=true)

// ═══════════════════════════════════════════════════════════════
// TIMEFRAME INPUTS
// ═══════════════════════════════════════════════════════════════

useManualTF = input.bool(
     false,
     "Use Manual Timeframe Override",
     group="Timeframe")

manualTF = input.timeframe(
     "5",
     "Manual Timeframe",
     group="Timeframe")

calcTF = useManualTF ? manualTF : timeframe.period


// ═══════════════════════════════════════════════════════════════
// VOLATILITY INPUTS
// ═══════════════════════════════════════════════════════════════

avgLen = input.int(
     20,
     "Average Bar Range Length",
     minval=1,
     group="Volatility")

atrLen = input.int(
     14,
     "ATR Length",
     minval=1,
     group="Volatility")


// ═══════════════════════════════════════════════════════════════
// STOP INPUTS
// ═══════════════════════════════════════════════════════════════

stopBasis = input.string(
     "ATR",
     "Stop Basis",
     options=["ATR", "Average Bar Range"],
     group="Stop Settings")

stopMult = input.float(
     1.0,
     "Stop Multiplier",
     minval=0.1,
     step=0.1,
     group="Stop Settings")

useManualPrice = input.bool(
     false,
     "Use Manual Entry Price",
     group="Stop Settings")

manualPrice = input.float(
     0.0,
     "Manual Entry Price",
     minval=0.0,
     step=0.01,
     group="Stop Settings")


// ═══════════════════════════════════════════════════════════════
// BUFFER INPUTS
// ═══════════════════════════════════════════════════════════════

bufferMode = input.string(
     "Auto",
     "Buffer Mode",
     options=["Auto", "Manual Ticks"],
     group="Buffer")

manualBufferTicks = input.int(
     2,
     "Manual Buffer (Ticks)",
     minval=0,
     group="Buffer")

autoBufferPercent = input.float(
     10.0,
     "Auto Buffer (% of Average Stop)",
     minval=0.0,
     step=1.0,
     group="Buffer")

maxAutoBufferPercent = input.float(
     25.0,
     "Maximum Auto Buffer (%)",
     minval=0.0,
     step=1.0,
     group="Buffer")

futureMinTicks = input.int(
     2,
     "Futures Minimum Buffer (Ticks)",
     minval=0,
     group="Buffer")


// ═══════════════════════════════════════════════════════════════
// DISPLAY INPUTS
// ═══════════════════════════════════════════════════════════════

displayMode = input.string(
     "Minimal",
     "Table Display",
     options=["Minimal", "Full"],
     group="Display")

tableSizeChoice = input.string(
     "Small",
     "Table Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"],
     group="Display")

horizontalPlacement = input.string(
     "Right",
     "Horizontal Placement",
     options=["Left", "Center", "Right"],
     group="Display")

verticalPlacement = input.string(
     "Top",
     "Vertical Placement",
     options=["Top", "Middle", "Bottom"],
     group="Display")


// ═══════════════════════════════════════════════════════════════
// TABLE TEXT SIZE
// ═══════════════════════════════════════════════════════════════

tableTextSize = switch tableSizeChoice
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.small


// ═══════════════════════════════════════════════════════════════
// TABLE POSITION
// ═══════════════════════════════════════════════════════════════

tablePosition = switch
    verticalPlacement == "Top" and horizontalPlacement == "Left" =>
        position.top_left
    verticalPlacement == "Top" and horizontalPlacement == "Center" =>
        position.top_center
    verticalPlacement == "Top" and horizontalPlacement == "Right" =>
        position.top_right
    verticalPlacement == "Middle" and horizontalPlacement == "Left" =>
        position.middle_left
    verticalPlacement == "Middle" and horizontalPlacement == "Center" =>
        position.middle_center
    verticalPlacement == "Middle" and horizontalPlacement == "Right" =>
        position.middle_right
    verticalPlacement == "Bottom" and horizontalPlacement == "Left" =>
        position.bottom_left
    verticalPlacement == "Bottom" and horizontalPlacement == "Center" =>
        position.bottom_center
    verticalPlacement == "Bottom" and horizontalPlacement == "Right" =>
        position.bottom_right
    =>
        position.top_right


// ═══════════════════════════════════════════════════════════════
// VOLATILITY CALCULATIONS
// ═══════════════════════════════════════════════════════════════

avgRange = request.security(
     syminfo.tickerid,
     calcTF,
     ta.sma(high - low, avgLen)[1],
     lookahead=barmerge.lookahead_on)

atrValue = request.security(
     syminfo.tickerid,
     calcTF,
     ta.atr(atrLen)[1],
     lookahead=barmerge.lookahead_on)

currentRange = request.security(
     syminfo.tickerid,
     calcTF,
     high - low,
     lookahead=barmerge.lookahead_off)

rangeRatio =
     avgRange > 0
     ? currentRange / avgRange
     : na


// ═══════════════════════════════════════════════════════════════
// PRICE / STOP CALCULATIONS
// ═══════════════════════════════════════════════════════════════

currentPrice = close

referencePriceRaw =
     useManualPrice and manualPrice > 0
     ? manualPrice
     : currentPrice

referencePrice =
     math.round_to_mintick(referencePriceRaw)

stopBase =
     stopBasis == "ATR"
     ? atrValue
     : avgRange

stopDistance =
     stopBase * stopMult

stopBasisLabel =
     stopBasis == "ATR"
     ? "ATR"
     : "Bar Range"


// ═══════════════════════════════════════════════════════════════
// INSTRUMENT CLASSIFICATION
// ═══════════════════════════════════════════════════════════════

isFuture =
     syminfo.type == "futures"

isEquityLike =
     syminfo.type == "stock" or
     syminfo.type == "fund" or
     syminfo.type == "dr"


// ═══════════════════════════════════════════════════════════════
// AUTO BUFFER CALCULATIONS
// ═══════════════════════════════════════════════════════════════

percentBuffer =
     stopDistance *
     (autoBufferPercent / 100.0)

maxAutoBuffer =
     stopDistance *
     (maxAutoBufferPercent / 100.0)

futureMinBuffer =
     futureMinTicks *
     syminfo.mintick

futureAutoBuffer =
     math.min(
         math.max(
             futureMinBuffer,
             percentBuffer),
         maxAutoBuffer)

stockAutoBuffer =
     math.min(
         percentBuffer,
         maxAutoBuffer)

otherAutoBuffer =
     math.min(
         percentBuffer,
         maxAutoBuffer)

autoBufferDistance =
     isFuture
     ? futureAutoBuffer
     : isEquityLike
     ? stockAutoBuffer
     : otherAutoBuffer

manualBufferDistance =
     manualBufferTicks *
     syminfo.mintick

bufferDistance =
     bufferMode == "Auto"
     ? autoBufferDistance
     : manualBufferDistance

bufferDistanceRounded =
     math.round_to_mintick(
         bufferDistance)


// ═══════════════════════════════════════════════════════════════
// FINAL STOP PRICES
// ═══════════════════════════════════════════════════════════════

longStop =
     math.round_to_mintick(
         referencePrice
         - stopDistance
         - bufferDistanceRounded)

shortStop =
     math.round_to_mintick(
         referencePrice
         + stopDistance
         + bufferDistanceRounded)


// ═══════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════

// General table colors for dark charts
headerBgColor = color.rgb(32, 95, 220)
headerTextColor = color.white

labelBgColor = color.rgb(42, 46, 57)
valueBgColor = color.rgb(28, 32, 40)
normalTextColor = color.white

longColor = color.rgb(35, 170, 95)
shortColor = color.rgb(210, 65, 65)

longTextColor = color.white
shortTextColor = color.white

frameColor = color.rgb(90, 96, 110)
borderColor = color.rgb(75, 80, 92)


// ═══════════════════════════════════════════════════════════════
// TABLE
// ═══════════════════════════════════════════════════════════════

var table dashboard = table.new(
     position.top_right,
     2,
     10,
     border_width=1,
     frame_color=frameColor,
     border_color=borderColor)


// ═══════════════════════════════════════════════════════════════
// TABLE DISPLAY
// ═══════════════════════════════════════════════════════════════

if barstate.islast

    table.set_position(dashboard, tablePosition)

    table.clear(dashboard, 0, 0, 1, 9)

    if displayMode == "Minimal"

        table.cell(
             dashboard, 0, 0,
             "Current Price",
             text_color=normalTextColor,
             bgcolor=labelBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 0,
             str.tostring(currentPrice, format.mintick),
             text_color=normalTextColor,
             bgcolor=valueBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 1,
             "Average Stop (" + stopBasisLabel + ")",
             text_color=normalTextColor,
             bgcolor=labelBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 1,
             str.tostring(stopDistance, "#.##") + " pts",
             text_color=normalTextColor,
             bgcolor=valueBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 2,
             "LONG Stop",
             text_color=longTextColor,
             bgcolor=longColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 2,
             str.tostring(longStop, format.mintick),
             text_color=longTextColor,
             bgcolor=longColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 3,
             "SHORT Stop",
             text_color=shortTextColor,
             bgcolor=shortColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 3,
             str.tostring(shortStop, format.mintick),
             text_color=shortTextColor,
             bgcolor=shortColor,
             text_size=tableTextSize)

    else

        table.cell(
             dashboard, 0, 0,
             calcTF + " Volatility",
             text_color=headerTextColor,
             bgcolor=headerBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 0,
             "Value",
             text_color=headerTextColor,
             bgcolor=headerBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 1,
             "Avg Bar Range (" + str.tostring(avgLen) + ")",
             text_color=normalTextColor,
             bgcolor=labelBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 1,
             str.tostring(avgRange, "#.##") + " pts",
             text_color=normalTextColor,
             bgcolor=valueBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 2,
             "ATR (" + str.tostring(atrLen) + ")",
             text_color=normalTextColor,
             bgcolor=labelBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 2,
             str.tostring(atrValue, "#.##") + " pts",
             text_color=normalTextColor,
             bgcolor=valueBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 3,
             "Current Bar",
             text_color=normalTextColor,
             bgcolor=labelBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 3,
             str.tostring(currentRange, "#.##") + " pts",
             text_color=normalTextColor,
             bgcolor=valueBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 4,
             "Current / Avg",
             text_color=normalTextColor,
             bgcolor=labelBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 4,
             str.tostring(rangeRatio, "#.##") + "x",
             text_color=normalTextColor,
             bgcolor=valueBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 5,
             "Current Price",
             text_color=normalTextColor,
             bgcolor=labelBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 5,
             str.tostring(currentPrice, format.mintick),
             text_color=normalTextColor,
             bgcolor=valueBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 6,
             "Average Stop (" + stopBasisLabel + " " + str.tostring(stopMult, "#.##") + "x)",
             text_color=normalTextColor,
             bgcolor=labelBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 6,
             str.tostring(stopDistance, "#.##") + " pts",
             text_color=normalTextColor,
             bgcolor=valueBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 7,
             "Buffer",
             text_color=normalTextColor,
             bgcolor=labelBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 7,
             str.tostring(bufferDistanceRounded, format.mintick) + " pts",
             text_color=normalTextColor,
             bgcolor=valueBgColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 8,
             "LONG Stop",
             text_color=longTextColor,
             bgcolor=longColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 8,
             str.tostring(longStop, format.mintick),
             text_color=longTextColor,
             bgcolor=longColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 0, 9,
             "SHORT Stop",
             text_color=shortTextColor,
             bgcolor=shortColor,
             text_size=tableTextSize)

        table.cell(
             dashboard, 1, 9,
             str.tostring(shortStop, format.mintick),
             text_color=shortTextColor,
             bgcolor=shortColor,
             text_size=tableTextSize)
````
