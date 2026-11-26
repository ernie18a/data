# Multi-Timeframe RSI Display

- url: https://www.tradingview.com/script/mKw2JjGg-Multi-Timeframe-RSI-Display/
- type: indicator
- pine_id: PUB;934c9bad599447ebb0225b234ac5056c
- version: 1.0

## Description

instantaneous 5m , 15 min, 30 min, 1h, 4h, 12h, 1D, 1W RSI displays to help identify stacked oversold / overbought conditions for entries / exits

## Source Code

````pine
//@version=5
indicator("Multi-Timeframe RSI Display", shorttitle="MTF RSI", overlay=false)

// ── Inputs ─────────────────────────────────────
rsiLength      = input.int(14, "RSI Length", minval=1, group="RSI Settings")
textSize       = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group="Display")
bgTransparency = input.int(85, "Background Transparency", minval=0, maxval=100, group="Display")

tablePositionInput = input.string("Top Right", "Table Position", 
     options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Top Center", "Bottom Center"], 
     group="Position")

// ── Timeframes ─────────────────────────────────
var string[] labelList = array.from("5m", "15m", "30m", "1h", "4h", "12h", "1D", "1W", "1M")

// ── Calculate RSI for each timeframe ───────────
rsi5m  = request.security(syminfo.tickerid, "5",   ta.rsi(close, rsiLength))
rsi15m = request.security(syminfo.tickerid, "15",  ta.rsi(close, rsiLength))
rsi30m = request.security(syminfo.tickerid, "30",  ta.rsi(close, rsiLength))
rsi1h  = request.security(syminfo.tickerid, "60",  ta.rsi(close, rsiLength))
rsi4h  = request.security(syminfo.tickerid, "240", ta.rsi(close, rsiLength))
rsi12h = request.security(syminfo.tickerid, "720", ta.rsi(close, rsiLength))
rsi1d  = request.security(syminfo.tickerid, "D",   ta.rsi(close, rsiLength))
rsi1w  = request.security(syminfo.tickerid, "W",   ta.rsi(close, rsiLength))
rsi1M  = request.security(syminfo.tickerid, "M",   ta.rsi(close, rsiLength))

rsiValues = array.from(rsi5m, rsi15m, rsi30m, rsi1h, rsi4h, rsi12h, rsi1d, rsi1w)

// ── Determine Table Position ───────────────────
var pos = position.top_right

if tablePositionInput == "Top Left"
    pos := position.top_left
else if tablePositionInput == "Top Right"
    pos := position.top_right
else if tablePositionInput == "Bottom Left"
    pos := position.bottom_left
else if tablePositionInput == "Bottom Right"
    pos := position.bottom_right
else if tablePositionInput == "Top Center"
    pos := position.top_center
else if tablePositionInput == "Bottom Center"
    pos := position.bottom_center

// ── Create Table ───────────────────────────────
var table mtfTable = table.new(position=pos, columns=8, rows=2,
     bgcolor=color.new(color.black, bgTransparency),
     border_width=1,
     border_color=color.gray)

// Update table on the last bar
if barstate.islast
    table.clear(mtfTable, 0, 0, 7, 1)
    
    // Header row
    for i = 0 to 7
        table.cell(mtfTable, i, 0,
             text       = array.get(labelList, i),
             text_color = color.white,
             text_size  = textSize == "Tiny" ? size.tiny :
                          textSize == "Small" ? size.small :
                          textSize == "Large" ? size.large : size.normal,
             bgcolor    = color.new(color.navy, 70))
    
    // RSI Values row
    for i = 0 to 7
        val = array.get(rsiValues, i)
        col = val >= 70 ? color.red :
              val <= 30 ? color.lime : color.white
        
        table.cell(mtfTable, i, 1,
             text       = str.tostring(val, "#.##"),
             text_color = col,
             text_size  = textSize == "Tiny" ? size.tiny :
                          textSize == "Small" ? size.small :
                          textSize == "Large" ? size.large : size.normal,
             bgcolor    = color.new(color.black, 60))
````
