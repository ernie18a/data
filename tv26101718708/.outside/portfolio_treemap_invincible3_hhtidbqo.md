# Portfolio Treemap [invincible3]

- url: https://www.tradingview.com/script/hHTiDbqO-Portfolio-Treemap-invincible3/
- type: indicator
- pine_id: PUB;63a58c5aed144ab6af896ef04b81390d
- version: 1.0

## Description

[b]Portfolio Treemap [invincible3][/b]

Portfolio Treemap [invincible3] is a visual portfolio monitoring dashboard designed to help traders and investors track multiple holdings directly on the TradingView chart.

The indicator allows users to enter up to 20 instruments, including stocks, ETFs, crypto pairs, forex symbols, or other TradingView-supported assets. For each instrument, the user can define the buy price and number of shares or units held. The script then calculates the live market value, cost basis, unrealized profit/loss, and percentage return using real-time chart data.

The dashboard uses a treemap-style layout where larger boxes represent larger portfolio weight based on the selected ranking mode. Box colors show unrealized performance: green for profitable positions and red for losing positions. The stronger the profit or loss percentage, the stronger the color intensity. Empty cells are blended with the chart background for a cleaner and more professional visual appearance.

[b]Key Features:[/b]

• Track up to 20 portfolio instruments
• User-defined portfolio name
• Input symbol, buy price, and shares/units for each holding
• Real-time portfolio value, cost, and unrealized P/L
• Treemap-style visual dashboard
• Profit and loss color gradient
• Green boxes for winning positions
• Red boxes for losing positions
• Dynamic text color for light and dark themes
• Empty cells blend with chart background
• Supports stocks, ETFs, crypto, forex, commodities, and indices
• Adjustable dashboard position and size
• Optional portfolio header
• Multiple box-ranking modes: shares, position value, absolute P/L, and absolute P/L %

[b]How to Use:[/b]

1. Add the indicator to your chart.
2. Open the indicator settings.
3. Enter your portfolio name.
4. Select each portfolio symbol.
5. Add your average buy price.
6. Add your number of shares or units.
7. Choose how boxes should be ranked: by shares, position value, absolute P/L, or absolute P/L percentage.
8. Use the dashboard to monitor portfolio performance visually.

[b]Color Logic:[/b]

• Green = position is in profit
• Red = position is in loss
• Stronger color = larger percentage move
• Neutral color = near breakeven
• Empty spaces blend with the chart background

[b]Important Notes:[/b]

For best results, use instruments quoted in the same currency. Mixing assets quoted in different currencies may make the total portfolio value and P/L less accurate unless the user manually adjusts values.

This indicator is intended for portfolio visualization and monitoring only. It does not provide buy or sell signals and should not be treated as financial advice. Always confirm portfolio values with your broker or exchange.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © invincible3

//@version=6
indicator("Portfolio Treemap [invincible3]", "Portfolio", overlay = true, dynamic_requests = true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
disp = display.all - display.status_line

grpDash = "Dashboard Settings"

posInput = input.string(
     "Top Right",
     "Dashboard Position",
     options = [
         "Top Left", "Top Center", "Top Right",
         "Middle Left", "Middle Center", "Middle Right",
         "Bottom Left", "Bottom Center", "Bottom Right"
     ],
     group = grpDash,
     display = disp
     )

sizeInput = input.string("Large", "Dashboard Size", options = ["Large", "Small"], group = grpDash, display = disp)
bigSize   = sizeInput == "Large"

sizeBy = input.string(
     "Shares",
     "Box Size Ranking",
     options = ["Shares", "Position Value", "Absolute P/L", "Absolute P/L %"],
     group = grpDash,
     display = disp
     )

currencySymbol = input.string("$", "Currency Symbol", group = grpDash, display = disp)

maxColorPct = input.float(
     25.0,
     "Full Color At +/- P/L %",
     minval = 1.0,
     step = 1.0,
     group = grpDash,
     display = disp
     )

showHeader   = input.bool(true, "Show Portfolio Header", group = grpDash, display = disp)
portfolioName = input.string("Portfolio 1", "Portfolio Name", group = grpDash, display = disp)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Portfolio Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tipSameCurrency = "Use symbols quoted in the same currency for meaningful portfolio totals."

grp1 = "Asset 01"
sym01 = input.symbol("NASDAQ:AAPL", "Symbol", group = grp1, tooltip = tipSameCurrency, display = disp)
avg01 = input.float(150.0, "Buy Price", group = grp1, minval = 0, display = disp)
qty01 = input.float(10.0, "Shares / Units", group = grp1, minval = 0, display = disp)

grp2 = "Asset 02"
sym02 = input.symbol("NASDAQ:MSFT", "Symbol", group = grp2, tooltip = tipSameCurrency, display = disp)
avg02 = input.float(300.0, "Buy Price", group = grp2, minval = 0, display = disp)
qty02 = input.float(5.0, "Shares / Units", group = grp2, minval = 0, display = disp)

grp3 = "Asset 03"
sym03 = input.symbol("NASDAQ:NVDA", "Symbol", group = grp3, tooltip = tipSameCurrency, display = disp)
avg03 = input.float(100.0, "Buy Price", group = grp3, minval = 0, display = disp)
qty03 = input.float(8.0, "Shares / Units", group = grp3, minval = 0, display = disp)

grp4 = "Asset 04"
sym04 = input.symbol("NASDAQ:TSLA", "Symbol", group = grp4, tooltip = tipSameCurrency, display = disp)
avg04 = input.float(200.0, "Buy Price", group = grp4, minval = 0, display = disp)
qty04 = input.float(4.0, "Shares / Units", group = grp4, minval = 0, display = disp)

grp5 = "Asset 05"
sym05 = input.symbol("BINANCE:BTCUSDT", "Symbol", group = grp5, tooltip = tipSameCurrency, display = disp)
avg05 = input.float(65000.0, "Buy Price", group = grp5, minval = 0, display = disp)
qty05 = input.float(0.1, "Shares / Units", group = grp5, minval = 0, display = disp)

grp6 = "Asset 06"
sym06 = input.symbol("BINANCE:ETHUSDT", "Symbol", group = grp6, tooltip = tipSameCurrency, display = disp)
avg06 = input.float(3000.0, "Buy Price", group = grp6, minval = 0, display = disp)
qty06 = input.float(1.0, "Shares / Units", group = grp6, minval = 0, display = disp)

grp7 = "Asset 07"
sym07 = input.symbol("NASDAQ:META", "Symbol", group = grp7, tooltip = tipSameCurrency, display = disp)
avg07 = input.float(400.0, "Buy Price", group = grp7, minval = 0, display = disp)
qty07 = input.float(2.0, "Shares / Units", group = grp7, minval = 0, display = disp)

grp8 = "Asset 08"
sym08 = input.symbol("NASDAQ:GOOGL", "Symbol", group = grp8, tooltip = tipSameCurrency, display = disp)
avg08 = input.float(130.0, "Buy Price", group = grp8, minval = 0, display = disp)
qty08 = input.float(6.0, "Shares / Units", group = grp8, minval = 0, display = disp)

grp9 = "Asset 09"
sym09 = input.symbol("AMEX:SPY", "Symbol", group = grp9, tooltip = tipSameCurrency, display = disp)
avg09 = input.float(500.0, "Buy Price", group = grp9, minval = 0, display = disp)
qty09 = input.float(3.0, "Shares / Units", group = grp9, minval = 0, display = disp)

grp10 = "Asset 10"
sym10 = input.symbol("NASDAQ:QQQ", "Symbol", group = grp10, tooltip = tipSameCurrency, display = disp)
avg10 = input.float(430.0, "Buy Price", group = grp10, minval = 0, display = disp)
qty10 = input.float(3.0, "Shares / Units", group = grp10, minval = 0, display = disp)

grp11 = "Asset 11"
sym11 = input.symbol("NYSE:JPM", "Symbol", group = grp11, tooltip = tipSameCurrency, display = disp)
avg11 = input.float(180.0, "Buy Price", group = grp11, minval = 0, display = disp)
qty11 = input.float(0.0, "Shares / Units", group = grp11, minval = 0, display = disp)

grp12 = "Asset 12"
sym12 = input.symbol("NYSE:XOM", "Symbol", group = grp12, tooltip = tipSameCurrency, display = disp)
avg12 = input.float(110.0, "Buy Price", group = grp12, minval = 0, display = disp)
qty12 = input.float(0.0, "Shares / Units", group = grp12, minval = 0, display = disp)

grp13 = "Asset 13"
sym13 = input.symbol("NYSE:KO", "Symbol", group = grp13, tooltip = tipSameCurrency, display = disp)
avg13 = input.float(60.0, "Buy Price", group = grp13, minval = 0, display = disp)
qty13 = input.float(0.0, "Shares / Units", group = grp13, minval = 0, display = disp)

grp14 = "Asset 14"
sym14 = input.symbol("NASDAQ:WMT", "Symbol", group = grp14, tooltip = tipSameCurrency, display = disp)
avg14 = input.float(65.0, "Buy Price", group = grp14, minval = 0, display = disp)
qty14 = input.float(0.0, "Shares / Units", group = grp14, minval = 0, display = disp)

grp15 = "Asset 15"
sym15 = input.symbol("NYSE:V", "Symbol", group = grp15, tooltip = tipSameCurrency, display = disp)
avg15 = input.float(250.0, "Buy Price", group = grp15, minval = 0, display = disp)
qty15 = input.float(0.0, "Shares / Units", group = grp15, minval = 0, display = disp)

grp16 = "Asset 16"
sym16 = input.symbol("NASDAQ:AMD", "Symbol", group = grp16, tooltip = tipSameCurrency, display = disp)
avg16 = input.float(150.0, "Buy Price", group = grp16, minval = 0, display = disp)
qty16 = input.float(0.0, "Shares / Units", group = grp16, minval = 0, display = disp)

grp17 = "Asset 17"
sym17 = input.symbol("NASDAQ:AVGO", "Symbol", group = grp17, tooltip = tipSameCurrency, display = disp)
avg17 = input.float(1500.0, "Buy Price", group = grp17, minval = 0, display = disp)
qty17 = input.float(0.0, "Shares / Units", group = grp17, minval = 0, display = disp)

grp18 = "Asset 18"
sym18 = input.symbol("BINANCE:SOLUSDT", "Symbol", group = grp18, tooltip = tipSameCurrency, display = disp)
avg18 = input.float(150.0, "Buy Price", group = grp18, minval = 0, display = disp)
qty18 = input.float(0.0, "Shares / Units", group = grp18, minval = 0, display = disp)

grp19 = "Asset 19"
sym19 = input.symbol("BINANCE:BNBUSDT", "Symbol", group = grp19, tooltip = tipSameCurrency, display = disp)
avg19 = input.float(600.0, "Buy Price", group = grp19, minval = 0, display = disp)
qty19 = input.float(0.0, "Shares / Units", group = grp19, minval = 0, display = disp)

grp20 = "Asset 20"
sym20 = input.symbol("BINANCE:XRPUSDT", "Symbol", group = grp20, tooltip = tipSameCurrency, display = disp)
avg20 = input.float(0.50, "Buy Price", group = grp20, minval = 0, display = disp)
qty20 = input.float(0.0, "Shares / Units", group = grp20, minval = 0, display = disp)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Types and Arrays
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
type pData
    string cell
    string tooltip
    color  bg
    float  sortValue

var pData[] portfolioData = array.new<pData>()
var float[] sortValues    = array.new_float()
var float[] costValues    = array.new_float()
var float[] marketValues  = array.new_float()
var float[] pnlValues     = array.new_float()

var int[] slotCols = array.new_int()
var int[] slotRows = array.new_int()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Position
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dashPos = switch posInput
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helper Functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bgLuma(c) =>
    color.r(c) * 0.299 + color.g(c) * 0.587 + color.b(c) * 0.114

isLightTheme() =>
    bgLuma(chart.bg_color) > 160

neutralColor() =>
    isLightTheme() ? color.rgb(236, 240, 244) : color.rgb(42, 46, 57)

bullWeakColor() =>
    color.rgb(34, 111, 96)

bullStrongColor() =>
    color.rgb(8, 153, 129)

bearWeakColor() =>
    color.rgb(125, 55, 65)

bearStrongColor() =>
    color.rgb(242, 54, 69)

textColorForBg(bg) =>
    bgLuma(bg) > 150 ? color.black : color.white

emptyBg() =>
    chart.bg_color

tickerName(symbol) =>
    p = str.pos(symbol, ":")
    na(p) ? symbol : str.substring(symbol, p + 1)

money(v) =>
    sign = v < 0 ? "-" : ""
    sign + currencySymbol + str.tostring(math.abs(v), format.volume)

pct(v) =>
    sign = v > 0 ? "+" : ""
    sign + str.tostring(v, "#.##") + "%"

qtyText(v) =>
    v >= 100 ? str.tostring(v, "#") :
     v >= 1  ? str.tostring(v, "#.##") :
               str.tostring(v, "#.####")

pnlColor(pnlPct) =>
    clipped = math.max(-maxColorPct, math.min(maxColorPct, pnlPct))
    mag = math.abs(clipped)

    if clipped > 0
        color.from_gradient(mag, 0, maxColorPct, bullWeakColor(), bullStrongColor())
    else if clipped < 0
        color.from_gradient(mag, 0, maxColorPct, bearWeakColor(), bearStrongColor())
    else
        neutralColor()

sortMetric(qty, marketValue, pnl, pnlPct) =>
    switch sizeBy
        "Shares"         => qty
        "Position Value" => marketValue
        "Absolute P/L"   => math.abs(pnl)
        "Absolute P/L %" => math.abs(pnlPct)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Table
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table tb = table.new(
     dashPos,
     20,
     13,
     border_width = 2,
     border_color = chart.bg_color,
     frame_color  = chart.bg_color,
     frame_width  = 1
     )

addBox(c1, r1, c2, r2, txtSize) =>
    table.cell(
         tb,
         c1,
         r1,
         "",
         text_color = textColorForBg(emptyBg()),
         text_halign = text.align_left,
         text_valign = text.align_center,
         text_size = txtSize,
         bgcolor = emptyBg()
         )
    table.merge_cells(tb, c1, r1, c2, r2)
    array.push(slotCols, c1)
    array.push(slotRows, r1)

clearBoxes() =>
    for i = 0 to array.size(slotCols) - 1
        c = array.get(slotCols, i)
        r = array.get(slotRows, i)
        table.cell_set_text(tb, c, r, "")
        table.cell_set_bgcolor(tb, c, r, emptyBg())
        table.cell_set_text_color(tb, c, r, textColorForBg(emptyBg()))
        table.cell_set_tooltip(tb, c, r, "")

setBox(rank, dataIndex) =>
    if rank < array.size(slotCols)
        c = array.get(slotCols, rank)
        r = array.get(slotRows, rank)
        d = array.get(portfolioData, dataIndex)

        table.cell_set_text(tb, c, r, d.cell)
        table.cell_set_bgcolor(tb, c, r, d.bg)
        table.cell_set_tooltip(tb, c, r, d.tooltip)
        table.cell_set_text_color(tb, c, r, textColorForBg(d.bg))

collectAsset(symbol, buyPrice, qty) =>
    [lastPrice, symType] = request.security(
         symbol,
         timeframe.period,
         [close, syminfo.type],
         ignore_invalid_symbol = true
         )

    valid = qty > 0 and buyPrice > 0 and not na(lastPrice)

    if valid
        cost        = buyPrice * qty
        marketValue = lastPrice * qty
        pnl         = marketValue - cost
        pnlPct      = cost != 0 ? pnl / cost * 100 : 0
        sValue      = sortMetric(qty, marketValue, pnl, pnlPct)
        name        = tickerName(symbol)

        txt =
             name + "\n" +
             "Qty " + qtyText(qty) + "\n" +
             money(marketValue) + "\n" +
             pct(pnlPct)

        tip =
             name + "\n\n" +
             "Current Price: " + money(lastPrice) + "\n" +
             "Buy Price: " + money(buyPrice) + "\n" +
             "Shares / Units: " + qtyText(qty) + "\n\n" +
             "Cost: " + money(cost) + "\n" +
             "Market Value: " + money(marketValue) + "\n" +
             "Unrealized P/L: " + money(pnl) + "\n" +
             "Unrealized P/L %: " + pct(pnlPct)

        array.push(portfolioData, pData.new(txt, tip, pnlColor(pnlPct), sValue))
        array.push(sortValues, sValue)
        array.push(costValues, cost)
        array.push(marketValues, marketValue)
        array.push(pnlValues, pnl)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Layout — Fixed Merged Treemap Slots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.isfirst
    table.cell(
         tb,
         0,
         0,
         "",
         text_color = textColorForBg(emptyBg()),
         text_halign = text.align_center,
         text_valign = text.align_center,
         text_size = bigSize ? size.normal : size.small,
         bgcolor = emptyBg()
         )
    table.merge_cells(tb, 0, 0, 19, 0)

    addBox(0, 1, 5, 8,      bigSize ? size.huge   : size.normal)
    addBox(0, 9, 5, 12,     bigSize ? size.huge   : size.normal)

    addBox(6, 1, 9, 4,      bigSize ? size.large  : size.small)
    addBox(6, 5, 9, 9,      bigSize ? size.large  : size.small)
    addBox(6, 10, 9, 12,    bigSize ? size.large  : size.small)

    addBox(10, 1, 14, 3,    bigSize ? size.normal : size.tiny)
    addBox(10, 4, 13, 6,    bigSize ? size.normal : size.tiny)
    addBox(10, 7, 13, 9,    bigSize ? size.normal : size.tiny)
    addBox(10, 10, 13, 12,  bigSize ? size.normal : size.tiny)

    addBox(15, 1, 17, 3,    bigSize ? size.normal : size.tiny)
    addBox(18, 1, 19, 3,    bigSize ? size.normal : size.tiny)

    addBox(14, 4, 16, 6,    bigSize ? size.small  : size.tiny)
    addBox(17, 4, 19, 6,    bigSize ? size.small  : size.tiny)

    addBox(14, 7, 17, 8,    bigSize ? size.small  : size.tiny)
    addBox(14, 9, 17, 10,   bigSize ? size.small  : size.tiny)
    addBox(14, 11, 17, 12,  bigSize ? size.small  : size.tiny)

    addBox(18, 7, 19, 7,    size.tiny)
    addBox(18, 8, 19, 8,    size.tiny)
    addBox(18, 9, 19, 9,    size.tiny)
    addBox(18, 10, 19, 12,  size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Calculations and Table Update
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if barstate.islast
    array.clear(portfolioData)
    array.clear(sortValues)
    array.clear(costValues)
    array.clear(marketValues)
    array.clear(pnlValues)

    collectAsset(sym01, avg01, qty01)
    collectAsset(sym02, avg02, qty02)
    collectAsset(sym03, avg03, qty03)
    collectAsset(sym04, avg04, qty04)
    collectAsset(sym05, avg05, qty05)
    collectAsset(sym06, avg06, qty06)
    collectAsset(sym07, avg07, qty07)
    collectAsset(sym08, avg08, qty08)
    collectAsset(sym09, avg09, qty09)
    collectAsset(sym10, avg10, qty10)
    collectAsset(sym11, avg11, qty11)
    collectAsset(sym12, avg12, qty12)
    collectAsset(sym13, avg13, qty13)
    collectAsset(sym14, avg14, qty14)
    collectAsset(sym15, avg15, qty15)
    collectAsset(sym16, avg16, qty16)
    collectAsset(sym17, avg17, qty17)
    collectAsset(sym18, avg18, qty18)
    collectAsset(sym19, avg19, qty19)
    collectAsset(sym20, avg20, qty20)

    totalCost   = array.sum(costValues)
    totalValue  = array.sum(marketValues)
    totalPnl    = array.sum(pnlValues)
    totalPnlPct = totalCost != 0 ? totalPnl / totalCost * 100 : 0

    cleanPortfolioName = str.trim(portfolioName) == "" ? "PORTFOLIO HEATMAP" : str.upper(portfolioName)

    headerText =
         array.size(portfolioData) > 0 ?
         cleanPortfolioName +
         "  |  Value: " + money(totalValue) +
         "  |  Cost: " + money(totalCost) +
         "  |  P/L: " + money(totalPnl) +
         " (" + pct(totalPnlPct) + ")" :
         cleanPortfolioName + "  |  Add symbols, buy price, and shares/units"

    headerBg = showHeader ? pnlColor(totalPnlPct) : emptyBg()

    table.cell_set_text(tb, 0, 0, showHeader ? headerText : "")
    table.cell_set_bgcolor(tb, 0, 0, headerBg)
    table.cell_set_text_color(tb, 0, 0, textColorForBg(headerBg))

    clearBoxes()

    if array.size(sortValues) > 0
        sortedIndices = array.sort_indices(sortValues, order.descending)

        for [rank, dataIndex] in sortedIndices
            if rank < 20
                setBox(rank, dataIndex)
````
