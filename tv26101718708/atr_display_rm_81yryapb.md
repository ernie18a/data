# ATR Display RM

- url: https://www.tradingview.com/script/81yryAPB-ATR-Display-RM/
- type: indicator
- pine_id: PUB;2b45daa1dd0545ae92b91cf90c4bfd43
- version: 2.0

## Description

Display of ATR on a numerical value on the current time frame

## Source Code

````pine
//@version=6
indicator(title="ATR Display", shorttitle="ATR Box", overlay=true)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
atrLength = input.int(14,       title="ATR Length",    minval=1)
atrSmooth = input.string("RMA", title="ATR Smoothing",
            options=["RMA","SMA","EMA","WMA"])
decimals  = input.int(2,        title="Decimal Places", minval=0, maxval=8)
labelSize = input.string(size.normal, title="Label Size",
            options=[size.tiny, size.small, size.normal, size.large, size.huge])

// ─────────────────────────────────────────────────────────────────────────────
// ATR CALCULATION — value read from the PREVIOUS fully closed candle [1]
// ─────────────────────────────────────────────────────────────────────────────
trueRange = ta.tr(true)

rawAtr = switch atrSmooth
    "RMA" => ta.rma(trueRange, atrLength)
    "SMA" => ta.sma(trueRange, atrLength)
    "EMA" => ta.ema(trueRange, atrLength)
    "WMA" => ta.wma(trueRange, atrLength)

atrPrev = rawAtr[1]

// ─────────────────────────────────────────────────────────────────────────────
// DISPLAY — single table anchored to the upper right of the viewport
// position.top_right pins the box to the top-right corner of the chart pane,
// fixed regardless of scrolling or zooming.
// Green frame only (transparent fill), green text.
// ─────────────────────────────────────────────────────────────────────────────

TRANSPARENT = color.new(color.black, 100)
FRAME_COLOR = color.green
TEXT_COLOR  = color.green

decFmt  = "#." + str.repeat("0", decimals)
atrText = "ATR RM: " + str.tostring(atrPrev, decFmt)

var table atrBox = table.new(
     position     = position.top_right,
     columns      = 1,
     rows         = 1,
     frame_color  = FRAME_COLOR,
     frame_width  = 1,
     border_color = FRAME_COLOR,
     border_width = 1)

table.cell(
     table_id   = atrBox,
     column     = 0,
     row        = 0,
     text       = atrText,
     text_color = TEXT_COLOR,
     text_size  = labelSize,
     bgcolor    = TRANSPARENT,
     tooltip    = "Average True Range — previous candle\nPeriod    : " +
                  str.tostring(atrLength) + " bars\nSmoothing : " +
                  atrSmooth + "\nValue     : " + str.tostring(atrPrev))
````
