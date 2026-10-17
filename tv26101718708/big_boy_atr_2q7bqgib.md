# Big Boy ATR

- url: https://www.tradingview.com/script/2Q7bqgib-Big-Boy-ATR/
- type: indicator
- pine_id: PUB;4572cf1efd924ecf9cd434df37ed3919
- version: 1.0

## Description

Big Boy ATR displays your Average True Range front and center — no squinting at a tiny subplot. A large, bold digital readout sits in the corner of your chart and updates in real time as each bar prints.
Features:

Oversized ATR value displayed in the chart corner — always visible at a glance
Choose your ATR timeframe independently of the chart timeframe (e.g. view a Daily ATR while trading on an 8-minute chart)
Selectable smoothing method: RMA, EMA, SMA, or WMA
Fully configurable: length, decimal places, text color, background, border, and corner position
Header label shows active length and timeframe so you always know what you're reading

Designed for traders who use ATR for stop sizing and want the number immediately accessible without hunting for it in a subplot.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheFuturesMonk

//@version=6
indicator("Big Boy ATR", overlay=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
atrLength     = input.int(14,       "ATR Length",      minval=1)
atrSmoothing  = input.string("RMA", "Smoothing",       options=["RMA", "EMA", "SMA", "WMA"])
atrTimeframe  = input.timeframe("", "ATR Timeframe",   tooltip="Leave blank to use the chart's timeframe")
decimalPlaces = input.int(2,        "Decimal Places",  minval=0, maxval=5)
textColor     = input.color(color.new(color.white, 0), "Text Color")
bgColor       = input.color(color.new(color.black, 40), "Background Color")
borderColor   = input.color(color.new(color.gray, 40),  "Border Color")
labelPos      = input.string("Top Right", "Position",  options=["Top Right", "Top Left", "Top Center", "Bottom Right", "Bottom Left"])

// ─── ATR Calculation ──────────────────────────────────────────────────────────
calcATR() =>
    switch atrSmoothing
        "RMA" => ta.atr(atrLength)
        "EMA" => ta.ema(ta.tr(true), atrLength)
        "SMA" => ta.sma(ta.tr(true), atrLength)
        "WMA" => ta.wma(ta.tr(true), atrLength)
        => ta.atr(atrLength)

atrValue = request.security(syminfo.tickerid, atrTimeframe == "" ? timeframe.period : atrTimeframe, calcATR(), lookahead=barmerge.lookahead_off)

// ─── Timeframe Label ──────────────────────────────────────────────────────────
tfLabel = atrTimeframe == "" ? timeframe.period : atrTimeframe

// ─── Table Position ───────────────────────────────────────────────────────────
tablePos = switch labelPos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Top Center"   => position.top_center
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

// ─── Table ────────────────────────────────────────────────────────────────────
var table atrTable = table.new(tablePos, 1, 2, bgcolor=bgColor, border_color=borderColor, border_width=1, frame_color=borderColor, frame_width=1)

if barstate.islast or barstate.isrealtime
    table.cell(atrTable, 0, 0,
         text       = "ATR(" + str.tostring(atrLength) + ") • " + tfLabel,
         text_color = color.new(color.gray, 20),
         text_size  = size.normal,
         bgcolor    = bgColor)
    table.cell(atrTable, 0, 1,
         text       = str.tostring(atrValue, "#." + str.repeat("0", decimalPlaces)),
         text_color = textColor,
         text_size  = size.huge,
         bgcolor    = bgColor)
````
