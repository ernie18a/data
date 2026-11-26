# Sector/Industry + Market Cap (INR Cr) by OddVue.com

- url: https://www.tradingview.com/script/eVmk2jhN-Sector-Industry-Market-Cap-INR-Cr-by-OddVue-com/
- type: indicator
- pine_id: PUB;27f777e808d94c20aff659d209ac7982
- version: 2.0

## Description

Sector/Industry + Market Cap (INR Cr) is a compact overlay indicator that displays key company fundamentals directly on the chart:

Industry
Sector
Market Capitalization in INR Crores

This helps you quickly identify what business the stock belongs to and its size category without leaving the chart.

## Source Code

````pine
// Script by OddVue.com
//@version=5
indicator("Sector/Industry + Market Cap (INR Cr)", overlay=true, format=format.volume, scale=scale.none)

//====================
// Data
//====================
sector   = syminfo.sector
industry = syminfo.industry

nselbi = request.security(syminfo.tickerid, "D", last_bar_index)
bselbi = request.security("BSE:" + syminfo.ticker, "D", last_bar_index, ignore_invalid_symbol=true)

bool bsecond = false
if nselbi < 750 and bselbi > nselbi + 100
    bsecond := true

sharesOutstanding = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ")
marketCap = sharesOutstanding * close

//====================
// Helpers
//====================
formatInCrores(val) =>
    if na(val)
        "N/A"
    else
        str.tostring(val / 10000000.0, "#,##0.00") + " Cr"

mcapText = "MCap (INR): " + formatInCrores(marketCap)

//====================
// Inputs
//====================
groupPos = "Table Position"

i_tableYpos = input.string("top", "X", inline="01", group=groupPos, options=["top", "middle", "bottom"])
i_tableXpos = input.string("right", "Y", inline="01", group=groupPos, options=["left", "center", "right"], tooltip="Position on the chart.")

i_textSize = input.string("Small", "Panel Text Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], inline="02", group=groupPos)
textSize = i_textSize == "Auto" ? size.auto :
     i_textSize == "Tiny" ? size.tiny :
     i_textSize == "Small" ? size.small :
     i_textSize == "Normal" ? size.normal :
     i_textSize == "Large" ? size.large : size.huge

tableLayout = input.string("Horizontal", "Table Layout", options=["Vertical", "Horizontal"], inline="03", group=groupPos)
isVertical = tableLayout == "Vertical"

bgColor   = input.color(color.new(color.black, 0), "BG Color", inline="04", group=groupPos)
textColor = input.color(color.new(color.white, 0), "Text Color", inline="04", group=groupPos)
bseBg     = input.color(color.new(color.red, 0), "BSE BG Color", group=groupPos)

//====================
// Table Position
//====================
tblPos = i_tableYpos == "top" ?
     (i_tableXpos == "left" ? position.top_left : i_tableXpos == "center" ? position.top_center : position.top_right) :
     i_tableYpos == "middle" ?
     (i_tableXpos == "left" ? position.middle_left : i_tableXpos == "center" ? position.middle_center : position.middle_right) :
     (i_tableXpos == "left" ? position.bottom_left : i_tableXpos == "center" ? position.bottom_center : position.bottom_right)

var table t = table.new(tblPos, columns=4, rows=4, border_width=1)

//====================
// Draw Table
//====================
if barstate.islast
    table.clear(t, 0, 0, 3, 3)

    if isVertical
        int r = 0
        if bsecond
            table.cell(t, 0, r, "BSE", text_color=textColor, bgcolor=bseBg, text_size=textSize)
            r += 1
        table.cell(t, 0, r, industry, text_color=textColor, bgcolor=bgColor, text_size=textSize)
        r += 1
        table.cell(t, 0, r, sector, text_color=textColor, bgcolor=bgColor, text_size=textSize)
        r += 1
        table.cell(t, 0, r, mcapText, text_color=textColor, bgcolor=bgColor, text_size=textSize)
    else
        int c = 0
        if bsecond
            table.cell(t, c, 0, "BSE", text_color=textColor, bgcolor=bseBg, text_size=textSize)
            c += 1
        table.cell(t, c, 0, industry, text_color=textColor, bgcolor=bgColor, text_size=textSize)
        c += 1
        table.cell(t, c, 0, sector, text_color=textColor, bgcolor=bgColor, text_size=textSize)
        c += 1
        table.cell(t, c, 0, mcapText, text_color=textColor, bgcolor=bgColor, text_size=textSize)
````
