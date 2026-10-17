# CMP Change ATR Trend Table

- url: https://www.tradingview.com/script/ly42GnRl-CMP-Change-ATR-Trend-Table/
- type: indicator
- pine_id: PUB;bd6af38ff31942a8a7f5a12503a7e85f
- version: 1.0

## Description

Simple indicator which prints percentage change from prvious candle close, ATR, trend and higher timeframe trend

## Source Code

````pine
//@version=6
indicator("CMP Change + ATR + Trend Table", overlay=true)

// === Inputs ===
higherTF = input.timeframe("W", "Higher Timeframe")
atrLen   = input.int(14, "ATR Length", minval=1)
fastLen  = input.int(20, "Fast EMA", minval=1)
slowLen  = input.int(50, "Slow EMA", minval=1)

tablePos = input.string("Top Right", "Table Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

// === Position Mapping ===
pos = tablePos == "Top Right" ? position.top_right :
      tablePos == "Top Left" ? position.top_left :
      tablePos == "Bottom Right" ? position.bottom_right :
      position.bottom_left

// === Yesterday Close ===
yClose = request.security(syminfo.tickerid, "D", close[1])
cmpChangePct = ((close - yClose) / yClose) * 100

// === ATR ===
atrVal = ta.atr(atrLen)

// === Current Timeframe Trend ===
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)

currTrend =
     fastEMA > slowEMA and close > fastEMA ? "UP" :
     fastEMA < slowEMA and close < fastEMA ? "DOWN" :
     "SIDEWAYS"

// === Higher Timeframe Trend ===
htfFast  = request.security(syminfo.tickerid, higherTF, ta.ema(close, fastLen))
htfSlow  = request.security(syminfo.tickerid, higherTF, ta.ema(close, slowLen))
htfClose = request.security(syminfo.tickerid, higherTF, close)

htfTrend =
     htfFast > htfSlow and htfClose > htfFast ? "UP" :
     htfFast < htfSlow and htfClose < htfFast ? "DOWN" :
     "SIDEWAYS"

// === Colors ===
headerBg  = color.rgb(220, 220, 220)
cellBg    = color.white
lineColor = color.rgb(120, 120, 120)
textCol   = color.black

chgColor =
     cmpChangePct > 0 ? color.green :
     cmpChangePct < 0 ? color.red :
     color.gray

currColor =
     currTrend == "UP" ? color.green :
     currTrend == "DOWN" ? color.red :
     color.orange

htfColor =
     htfTrend == "UP" ? color.green :
     htfTrend == "DOWN" ? color.red :
     color.orange

// === Table ===
var table t = table.new(
     pos,
     2,
     5,
     bgcolor=color.white,
     frame_color=color.black,
     frame_width=2,
     border_color=lineColor,
     border_width=1
)

if barstate.islast
    table.cell(t, 0, 0, "Metric", bgcolor=headerBg, text_color=textCol)
    table.cell(t, 1, 0, "Value", bgcolor=headerBg, text_color=textCol)

    table.cell(t, 0, 1, "CMP % vs Yesterday", bgcolor=cellBg, text_color=textCol)
    table.cell(t, 1, 1, str.tostring(cmpChangePct, "#.##") + "%", bgcolor=cellBg, text_color=chgColor)

    table.cell(t, 0, 2, "ATR (" + str.tostring(atrLen) + ")", bgcolor=cellBg, text_color=textCol)
    table.cell(t, 1, 2, str.tostring(atrVal, "#.##"), bgcolor=cellBg, text_color=textCol)

    table.cell(t, 0, 3, "Current TF Trend", bgcolor=cellBg, text_color=textCol)
    table.cell(t, 1, 3, currTrend, bgcolor=cellBg, text_color=currColor)

    table.cell(t, 0, 4, "HTF Trend (" + higherTF + ")", bgcolor=cellBg, text_color=textCol)
    table.cell(t, 1, 4, htfTrend, bgcolor=cellBg, text_color=htfColor)
````
