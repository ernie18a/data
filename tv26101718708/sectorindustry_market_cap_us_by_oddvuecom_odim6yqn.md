# Sector/Industry + Market Cap US($) by OddVue.com

- url: https://www.tradingview.com/script/odIM6YqN-Sector-Industry-Market-Cap-US-by-OddVue-com/
- type: indicator
- pine_id: PUB;9806fa7f23924ad3932484784eeb5c61
- version: 2.0

## Description

Sector/Industry + Market Cap (INR Cr) is a compact overlay indicator that displays key company fundamentals directly on the chart:

Industry
Sector
Market Capitalization in US Dollars

This helps you quickly identify what business the stock belongs to and its size category without leaving the chart.

Visit OddVue.com - Journal Your Edge, Right Next to Charts

## Source Code

````pine
//@version=6
indicator("Sector/Industry + Market Cap (USD)", overlay = true, format = format.volume, scale = scale.none, dynamic_requests = true)

//====================
// Data
//====================
string sector = syminfo.sector
string industry = syminfo.industry

int nselbi = request.security(syminfo.tickerid, "1D", last_bar_index)
int bselbi = request.security("BSE:" + syminfo.ticker, "1D", last_bar_index, ignore_invalid_symbol = true)

bool bsecond = false
if nselbi < 750 and bselbi > nselbi + 100
    bsecond := true

float sharesOutstanding = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ")
float marketCapNative = sharesOutstanding * close

//====================
// FX: quote currency -> USD
//====================
string fxTf = input.timeframe("1D", "FX timeframe (USD conversion)", group = "Market Cap (USD)")

convertNativeToUSD(float amount, string cur) =>
    float out = na
    if not na(amount) and cur == "USD"
        out := amount
    else if not na(amount)
        string id = "FX_IDC:"
        bool useMultiply = false
        if cur == "EUR" or cur == "GBP" or cur == "AUD" or cur == "NZD"
            id += cur + "USD"
            useMultiply := true
        else
            id += "USD" + cur
        float fx = request.security(id, fxTf, close, ignore_invalid_symbol = true)
        if not na(fx) and fx != 0.0
            out := useMultiply ? amount * fx : amount / fx
    out

float marketCapUSD = convertNativeToUSD(marketCapNative, syminfo.currency)

//====================
// Helpers
//====================
formatUSDCompact(float val) =>
    string txt = "N/A"
    if na(val)
        txt := "N/A"
    else if math.abs(val) >= 1e12
        txt := "$" + str.tostring(val / 1e12, "#,##0.00") + "T"
    else if math.abs(val) >= 1e9
        txt := "$" + str.tostring(val / 1e9, "#,##0.00") + "B"
    else if math.abs(val) >= 1e6
        txt := "$" + str.tostring(val / 1e6, "#,##0.00") + "M"
    else if math.abs(val) >= 1e3
        txt := "$" + str.tostring(val / 1e3, "#,##0.00") + "K"
    else
        txt := "$" + str.tostring(val, "#,##0.00")
    txt

string mcapText = "MCap (USD): " + formatUSDCompact(marketCapUSD)

//====================
// Inputs
//====================
string groupPos = "Table Position"

string i_tableYpos = input.string("top", "X", inline = "01", group = groupPos, options = ["top", "middle", "bottom"])
string i_tableXpos = input.string("right", "Y", inline = "01", group = groupPos, options = ["left", "center", "right"], tooltip = "Position on the chart.")

string i_textSize = input.string("Small", "Panel Text Size", options = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], inline = "02", group = groupPos)

userTextSize = i_textSize == "Auto" ? size.auto : i_textSize == "Tiny" ? size.tiny : i_textSize == "Small" ? size.small : i_textSize == "Normal" ? size.normal : i_textSize == "Large" ? size.large : size.huge

string tableLayout = input.string("Horizontal", "Table Layout", options = ["Vertical", "Horizontal"], inline = "03", group = groupPos)
bool isVertical = tableLayout == "Vertical"

color bgColor = input.color(color.new(color.black, 0), "BG Color", inline = "04", group = groupPos)
color textColor = input.color(color.new(color.white, 0), "Text Color", inline = "04", group = groupPos)
color bseBg = input.color(color.new(color.red, 0), "BSE BG Color", group = groupPos)

//====================
// Table position (no switch, no broken =>)
//====================
tablePos(string y, string x) =>
    p = position.top_right
    if y == "top"
        if x == "left"
            p := position.top_left
        else if x == "center"
            p := position.top_center
        else
            p := position.top_right
    else if y == "middle"
        if x == "left"
            p := position.middle_left
        else if x == "center"
            p := position.middle_center
        else
            p := position.middle_right
    else
        if x == "left"
            p := position.bottom_left
        else if x == "center"
            p := position.bottom_center
        else
            p := position.bottom_right
    p

tblPos = tablePos(i_tableYpos, i_tableXpos)

var table t = table.new(tblPos, 4, 4, border_width = 1)

//====================
// Draw Table
//====================
if barstate.islast
    table.clear(t, 0, 0, 3, 3)

    if isVertical
        int r = 0
        if bsecond
            table.cell(t, 0, r, "BSE", text_color = textColor, bgcolor = bseBg, text_size = userTextSize)
            r += 1
        table.cell(t, 0, r, industry, text_color = textColor, bgcolor = bgColor, text_size = userTextSize)
        r += 1
        table.cell(t, 0, r, sector, text_color = textColor, bgcolor = bgColor, text_size = userTextSize)
        r += 1
        table.cell(t, 0, r, mcapText, text_color = textColor, bgcolor = bgColor, text_size = userTextSize)
    else
        int c = 0
        if bsecond
            table.cell(t, c, 0, "BSE", text_color = textColor, bgcolor = bseBg, text_size = userTextSize)
            c += 1
        table.cell(t, c, 0, industry, text_color = textColor, bgcolor = bgColor, text_size = userTextSize)
        c += 1
        table.cell(t, c, 0, sector, text_color = textColor, bgcolor = bgColor, text_size = userTextSize)
        c += 1
        table.cell(t, c, 0, mcapText, text_color = textColor, bgcolor = bgColor, text_size = userTextSize)
````
