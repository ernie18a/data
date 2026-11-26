# TFC(M/W/D) Inside/Outside

- url: https://www.tradingview.com/script/VJOZO9oc-TFC-M-W-D-Inside-Outside/
- type: indicator
- pine_id: PUB;88939f42c00540029505a144d159c0a4
- version: 1.0

## Description

Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.
Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.

## Source Code

````pine
// © Gemini Refactor
// @version=6
indicator("TFC(M/W/D) Inside/Outside", "TFC", overlay = true)

//--------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------
groupTFC    = "Timeframe Continuity (TFC)"
groupPat    = "Pattern Settings (OB/IB)"

// TFC Table Settings
showTFC      = input.bool(true, "Show TFC Table", group=groupTFC)
bullColor    = input.color(color.new(#008000, 0), "Bullish Color", group=groupTFC)
bearColor    = input.color(color.new(#FF0000, 0), "Bearish Color", group=groupTFC)
tfcTextColor = input.color(color.white, "Text Color", group=groupTFC)
tfcSize      = input.string(size.normal, "Text Size", options=[size.tiny, size.small, size.normal, size.large], group=groupTFC)
tfcWidth     = input.int(4, "Cell Width", minval=1, group=groupTFC)
tfcHeight    = input.int(3, "Cell Height", minval=1, group=groupTFC)

// Pattern Settings
showOB       = input.bool(true, "Show Outside Bars", group=groupPat, inline="ob")
obColor      = input.color(color.yellow, "", group=groupPat, inline="ob")
showIB       = input.bool(true, "Show Inside Bars", group=groupPat, inline="ib")
ibColor      = input.color(#FF00FF, "", group=groupPat, inline="ib") 
symbolSize   = input.string("Tiny", "Symbol Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupPat)

//--------------------------------------------------------------------
// Data Fetching (Removed 1H/60m)
//--------------------------------------------------------------------
// Using [1] offset with lookahead to get the closed state of the HTF candle relative to the current bar
[mBull] = request.security(syminfo.tickerid, "1M", [close > open], lookahead=barmerge.lookahead_on)
[wBull] = request.security(syminfo.tickerid, "1W", [close > open], lookahead=barmerge.lookahead_on)
[dBull] = request.security(syminfo.tickerid, "1D", [close > open], lookahead=barmerge.lookahead_on)

//--------------------------------------------------------------------
// Pattern Logic
//--------------------------------------------------------------------
isOB = high > high[1] and low < low[1]
isIB = high < high[1] and low > low[1]

// Plotting Shapes
plotshape(showOB and isOB, style=shape.diamond, location=location.abovebar, color=obColor, size=size.tiny, title="Outside Bar")
plotshape(showIB and isIB, style=shape.circle,  location=location.abovebar, color=ibColor, size=size.tiny, title="Inside Bar")

//--------------------------------------------------------------------
// TFC Table (Refactored for 3 Columns)
//--------------------------------------------------------------------
var table tfTable = table.new(position.bottom_right, 3, 1, border_width=1)

if barstate.islast and showTFC
    table.cell(tfTable, 0, 0, "M", bgcolor=mBull ? bullColor : bearColor, text_color=tfcTextColor, text_size=tfcSize, width=tfcWidth, height=tfcHeight)
    table.cell(tfTable, 1, 0, "W", bgcolor=wBull ? bullColor : bearColor, text_color=tfcTextColor, text_size=tfcSize, width=tfcWidth, height=tfcHeight)
    table.cell(tfTable, 2, 0, "D", bgcolor=dBull ? bullColor : bearColor, text_color=tfcTextColor, text_size=tfcSize, width=tfcWidth, height=tfcHeight)
````
