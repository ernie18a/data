# Mag 7 Heatmap

- url: https://www.tradingview.com/script/5rSwOWgM/
- type: indicator
- pine_id: PUB;0cb1db88340f4e2c8050e75a262d6f86
- version: 1.0

## Description

Mag 7 Heatmap

This indicator displays a compact heatmap of the Magnificent 7 stocks directly on the chart: NVDA, MSFT, AAPL, AMZN, META, GOOGL, and TSLA.

## Source Code

````pine
//@version=6
indicator("MES Mag 7 Heatmap", overlay = true)
// Shows a compact Mag 7 heatmap for MES/NQ context.
// Default change basis: current daily price vs previous daily close.
symNvda  = input.symbol("NASDAQ:NVDA",  "NVDA")
symMsft  = input.symbol("NASDAQ:MSFT",  "MSFT")
symAapl  = input.symbol("NASDAQ:AAPL",  "AAPL")
symAmzn  = input.symbol("NASDAQ:AMZN",  "AMZN")
symMeta  = input.symbol("NASDAQ:META",  "META")
symGoogl = input.symbol("NASDAQ:GOOGL", "GOOGL")
symTsla  = input.symbol("NASDAQ:TSLA",  "TSLA")
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
mag7Data(string symbol) =>
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
txtColor(float pct) =>
    na(pct) ? color.white : color.white
pctText(float pct) =>
    na(pct) ? "n/a" : (pct > 0 ? "+" : "") + str.tostring(pct, "#.##") + "%"
tileText(string ticker, float price, float pct) =>
    showPrice ? ticker + "\n" + pctText(pct) + "\n" + str.tostring(price, "#.##") : ticker + "\n" + pctText(pct)
directionScore(float pct) =>
    na(pct) ? 0 : pct > 0 ? 1 : pct < 0 ? -1 : 0
[priceNvda, pctNvda]   = mag7Data(symNvda)
[priceMsft, pctMsft]   = mag7Data(symMsft)
[priceAapl, pctAapl]   = mag7Data(symAapl)
[priceAmzn, pctAmzn]   = mag7Data(symAmzn)
[priceMeta, pctMeta]   = mag7Data(symMeta)
[priceGoogl, pctGoogl] = mag7Data(symGoogl)
[priceTsla, pctTsla]   = mag7Data(symTsla)
greenCount = (directionScore(pctNvda) == 1 ? 1 : 0) + (directionScore(pctMsft) == 1 ? 1 : 0) + (directionScore(pctAapl) == 1 ? 1 : 0) + (directionScore(pctAmzn) == 1 ? 1 : 0) + (directionScore(pctMeta) == 1 ? 1 : 0) + (directionScore(pctGoogl) == 1 ? 1 : 0) + (directionScore(pctTsla) == 1 ? 1 : 0)
redCount = (directionScore(pctNvda) == -1 ? 1 : 0) + (directionScore(pctMsft) == -1 ? 1 : 0) + (directionScore(pctAapl) == -1 ? 1 : 0) + (directionScore(pctAmzn) == -1 ? 1 : 0) + (directionScore(pctMeta) == -1 ? 1 : 0) + (directionScore(pctGoogl) == -1 ? 1 : 0) + (directionScore(pctTsla) == -1 ? 1 : 0)
biasText = greenCount >= 5 ? "5+ green: Mag 7 supports NQ/ES upside" : redCount >= 5 ? "5+ red: Mag 7 pressures NQ/ES downside" : "Mixed: wait for ES/NQ confirmation"
biasBg = greenCount >= 5 ? color.rgb(0, 145, 84) : redCount >= 5 ? color.rgb(188, 38, 54) : color.rgb(73, 83, 98)
var table heatmap = table.new(panelPosition(panelPos), 7, 3, border_width = 1, border_color = color.new(color.white, 70))
if barstate.isfirst
    table.merge_cells(heatmap, 0, 1, 6, 1)
    table.merge_cells(heatmap, 0, 2, 6, 2)
if barstate.islast
    table.cell(heatmap, 0, 0, tileText("NVDA", priceNvda, pctNvda),   bgcolor = bgColor(pctNvda),   text_color = txtColor(pctNvda),   text_size = size.small)
    table.cell(heatmap, 1, 0, tileText("MSFT", priceMsft, pctMsft),   bgcolor = bgColor(pctMsft),   text_color = txtColor(pctMsft),   text_size = size.small)
    table.cell(heatmap, 2, 0, tileText("AAPL", priceAapl, pctAapl),   bgcolor = bgColor(pctAapl),   text_color = txtColor(pctAapl),   text_size = size.small)
    table.cell(heatmap, 3, 0, tileText("AMZN", priceAmzn, pctAmzn),   bgcolor = bgColor(pctAmzn),   text_color = txtColor(pctAmzn),   text_size = size.small)
    table.cell(heatmap, 4, 0, tileText("META", priceMeta, pctMeta),   bgcolor = bgColor(pctMeta),   text_color = txtColor(pctMeta),   text_size = size.small)
    table.cell(heatmap, 5, 0, tileText("GOOGL", priceGoogl, pctGoogl), bgcolor = bgColor(pctGoogl), text_color = txtColor(pctGoogl), text_size = size.small)
    table.cell(heatmap, 6, 0, tileText("TSLA", priceTsla, pctTsla),   bgcolor = bgColor(pctTsla),   text_color = txtColor(pctTsla),   text_size = size.small)
    table.cell(heatmap, 0, 1, "Green: " + str.tostring(greenCount) + "/7    Red: " + str.tostring(redCount) + "/7", bgcolor = color.rgb(23, 32, 42), text_color = color.white, text_size = size.small)
    table.cell(heatmap, 0, 2, biasText, bgcolor = biasBg, text_color = color.white, text_size = size.small)
alertcondition(greenCount >= 5, "Mag 7: 5+ green", "Mag 7 heatmap: 5 or more names are green. NQ/ES upside support.")
alertcondition(redCount >= 5, "Mag 7: 5+ red", "Mag 7 heatmap: 5 or more names are red. NQ/ES downside pressure.")
````
