# DAX Heavyweights Heatmap

- url: https://www.tradingview.com/script/iq5zWZE1/
- type: indicator
- pine_id: PUB;558d51eadd2941eda3abd34e31f29436
- version: 1.0

## Description

This indicator displays a compact heatmap of seven major DAX / German market heavyweights directly on the chart: SAP, Siemens, Allianz, Deutsche Telekom, Airbus, Munich Re, and Mercedes-Benz.

It is designed as a market context tool for DAX, FDAX, GER40, and European index traders. The indicator shows each stock’s percentage change, colors the tiles green or red, and counts how many of the seven names are positive or negative.

## Source Code

````pine
//@version=6
indicator("DAX Heavyweights Heatmap", overlay = true)
// Compact DAX heavyweight heatmap for FDAX/DAX context.
// Default basket: SAP, Siemens, Allianz, Deutsche Telekom, Airbus, Munich Re, Mercedes-Benz.
// Rule of thumb: 5+ green supports DAX upside pressure, 5+ red supports downside pressure.
symSap  = input.symbol("XETR:SAP",  "SAP")
symSie  = input.symbol("XETR:SIE",  "SIE")
symAlv  = input.symbol("XETR:ALV",  "ALV")
symDte  = input.symbol("XETR:DTE",  "DTE")
symAir  = input.symbol("XETR:AIR",  "AIR")
symMuv2 = input.symbol("XETR:MUV2", "MUV2")
symMbg  = input.symbol("XETR:MBG",  "MBG")
changeTf = input.timeframe("D", "Change timeframe")
strongMovePct = input.float(1.00, "Strong color from +/- %", minval = 0.10, step = 0.05)
showPrice = input.bool(false, "Show price in tile")
panelPos = input.string("Top right", "Panel position", options = ["Top right", "Top left", "Bottom right", "Bottom left"])
panelPosition(string pos) =>
    switch pos
        "Top left" => position.top_left
        "Bottom right" => position.bottom_right
        "Bottom left" => position.bottom_left
        => position.top_right
stockData(string symbol) =>
    [lastPrice, prevClose] = request.security(symbol, changeTf, [close, close[1]], ignore_invalid_symbol = true)
    pct = na(lastPrice) or na(prevClose) or prevClose == 0.0 ? na : (lastPrice / prevClose - 1.0) * 100.0
    [lastPrice, pct]
bgColor(float pct) =>
    if na(pct)
        color.new(color.gray, 70)
    else if pct >= strongMovePct
        color.rgb(0, 145, 84)
    else if pct > 0
        color.rgb(46, 179, 116)
    else if pct <= -strongMovePct
        color.rgb(188, 38, 54)
    else if pct < 0
        color.rgb(222, 91, 91)
    else
        color.new(color.gray, 55)
pctText(float pct) =>
    na(pct) ? "n/a" : (pct > 0 ? "+" : "") + str.tostring(pct, "#.##") + "%"
tileText(string ticker, float price, float pct) =>
    showPrice ? ticker + "\n" + pctText(pct) + "\n" + str.tostring(price, "#.##") : ticker + "\n" + pctText(pct)
directionScore(float pct) =>
    na(pct) ? 0 : pct > 0 ? 1 : pct < 0 ? -1 : 0
[priceSap, pctSap]   = stockData(symSap)
[priceSie, pctSie]   = stockData(symSie)
[priceAlv, pctAlv]   = stockData(symAlv)
[priceDte, pctDte]   = stockData(symDte)
[priceAir, pctAir]   = stockData(symAir)
[priceMuv2, pctMuv2] = stockData(symMuv2)
[priceMbg, pctMbg]   = stockData(symMbg)
greenCount = (directionScore(pctSap) == 1 ? 1 : 0) + (directionScore(pctSie) == 1 ? 1 : 0) + (directionScore(pctAlv) == 1 ? 1 : 0) + (directionScore(pctDte) == 1 ? 1 : 0) + (directionScore(pctAir) == 1 ? 1 : 0) + (directionScore(pctMuv2) == 1 ? 1 : 0) + (directionScore(pctMbg) == 1 ? 1 : 0)
redCount = (directionScore(pctSap) == -1 ? 1 : 0) + (directionScore(pctSie) == -1 ? 1 : 0) + (directionScore(pctAlv) == -1 ? 1 : 0) + (directionScore(pctDte) == -1 ? 1 : 0) + (directionScore(pctAir) == -1 ? 1 : 0) + (directionScore(pctMuv2) == -1 ? 1 : 0) + (directionScore(pctMbg) == -1 ? 1 : 0)
biasText = greenCount >= 5 ? "5+ green: DAX heavyweights support upside" : redCount >= 5 ? "5+ red: DAX heavyweights pressure downside" : "Mixed: wait for DAX/FDAX confirmation"
biasBg = greenCount >= 5 ? color.rgb(0, 145, 84) : redCount >= 5 ? color.rgb(188, 38, 54) : color.rgb(73, 83, 98)
var table heatmap = table.new(panelPosition(panelPos), 7, 3, border_width = 1, border_color = color.new(color.white, 70))
if barstate.isfirst
    table.merge_cells(heatmap, 0, 1, 6, 1)
    table.merge_cells(heatmap, 0, 2, 6, 2)
if barstate.islast
    table.cell(heatmap, 0, 0, tileText("SAP", priceSap, pctSap),     bgcolor = bgColor(pctSap),  text_color = color.white, text_size = size.small)
    table.cell(heatmap, 1, 0, tileText("SIE", priceSie, pctSie),     bgcolor = bgColor(pctSie),  text_color = color.white, text_size = size.small)
    table.cell(heatmap, 2, 0, tileText("ALV", priceAlv, pctAlv),     bgcolor = bgColor(pctAlv),  text_color = color.white, text_size = size.small)
    table.cell(heatmap, 3, 0, tileText("DTE", priceDte, pctDte),     bgcolor = bgColor(pctDte),  text_color = color.white, text_size = size.small)
    table.cell(heatmap, 4, 0, tileText("AIR", priceAir, pctAir),     bgcolor = bgColor(pctAir),  text_color = color.white, text_size = size.small)
    table.cell(heatmap, 5, 0, tileText("MUV2", priceMuv2, pctMuv2),  bgcolor = bgColor(pctMuv2), text_color = color.white, text_size = size.small)
    table.cell(heatmap, 6, 0, tileText("MBG", priceMbg, pctMbg),     bgcolor = bgColor(pctMbg),  text_color = color.white, text_size = size.small)
    table.cell(heatmap, 0, 1, "Green: " + str.tostring(greenCount) + "/7    Red: " + str.tostring(redCount) + "/7", bgcolor = color.rgb(23, 32, 42), text_color = color.white, text_size = size.small)
    table.cell(heatmap, 0, 2, biasText, bgcolor = biasBg, text_color = color.white, text_size = size.small)
alertcondition(greenCount >= 5, "DAX Heavyweights: 5+ green", "DAX heavyweight heatmap: 5 or more names are green. DAX/FDAX upside support.")
alertcondition(redCount >= 5, "DAX Heavyweights: 5+ red", "DAX heavyweight heatmap: 5 or more names are red. DAX/FDAX downside pressure.")
````
