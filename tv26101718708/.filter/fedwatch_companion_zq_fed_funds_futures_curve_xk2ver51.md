# FedWatch Companion - ZQ Fed Funds Futures Curve

- url: https://www.tradingview.com/script/xk2VER51-FedWatch-Companion-ZQ-Fed-Funds-Futures-Curve/
- type: indicator
- pine_id: PUB;39588eac83a34310b2e301133c2269a1
- version: 4.0

## Description

FedWatch Companion - ZQ Fed Funds Futures Curve

This indicator plots implied rates from selected 30-Day Fed Funds Futures (ZQ) contracts using the transformation:

100 - futures price

What this script does:
- Lets the user manually select which ZQ contract months to display.
- Lets the user assign an independent year to each selected month.
- Allows mixed-year layouts such as late-year contracts together with next-year contracts.
- Draws a reference band for the current Fed target range.

Why this script is useful:
Many traders are used to thinking in FedWatch terms, but sometimes need a cleaner manual curve view across selected ZQ months and years. This script is designed for that workflow.

Key features:
- Month-by-month manual selection
- Independent year input next to each month
- Easy comparison of implied rates across calendar boundaries
- Simple visual comparison against the current target range
- Useful for manual historical backtesting by selecting specific month/year combinations

How to use it:
1. Turn months on or off in the settings.
2. Choose the year next to each enabled month.
3. Compare the selected implied-rate curves in one pane.
4. Use it to inspect how the market prices different policy horizons.
5. Use custom month/year combinations for manual historical backtesting and past curve review.

Data note:
Displayed values depend on the selected ZQ contracts and on the data access available in the user’s TradingView account.

## Source Code

````pine
//@version=6
indicator("ZQ Manual Year-by-Month", shorttitle="ZQ YM", overlay=false, scale=scale.left)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
exchangePrefix = input.string("CBOT:", "Exchange prefix")
rootSymbol     = input.string("ZQ", "Root symbol")

fedLower = input.float(3.50, "Lower bound", step=0.01)
fedUpper = input.float(3.75, "Upper bound", step=0.01)

//--------------------------------------------------
// Month selectors: checkbox + year beside it
//--------------------------------------------------
groupMonths = "Months"

showJan = input.bool(false, "Jan", group=groupMonths, inline="jan")
yearJan = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="jan")

showFeb = input.bool(false, "Feb", group=groupMonths, inline="feb")
yearFeb = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="feb")

showMar = input.bool(false, "Mar", group=groupMonths, inline="mar")
yearMar = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="mar")

showApr = input.bool(false, "Apr", group=groupMonths, inline="apr")
yearApr = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="apr")

showMay = input.bool(false, "May", group=groupMonths, inline="may")
yearMay = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="may")

showJun = input.bool(true, "Jun", group=groupMonths, inline="jun")
yearJun = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="jun")

showJul = input.bool(false, "Jul", group=groupMonths, inline="jul")
yearJul = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="jul")

showAug = input.bool(false, "Aug", group=groupMonths, inline="aug")
yearAug = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="aug")

showSep = input.bool(true, "Sep", group=groupMonths, inline="sep")
yearSep = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="sep")

showOct = input.bool(true, "Oct", group=groupMonths, inline="oct")
yearOct = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="oct")

showNov = input.bool(false, "Nov", group=groupMonths, inline="nov")
yearNov = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="nov")

showDec = input.bool(true, "Dec", group=groupMonths, inline="dec")
yearDec = input.int(2026, "Year", minval=2018, maxval=2035, group=groupMonths, inline="dec")

//--------------------------------------------------
// Colors
//--------------------------------------------------
groupColors = "Colors"
cJan = input.color(color.red, "Jan", group=groupColors)
cFeb = input.color(color.rgb(255,120,120), "Feb", group=groupColors)
cMar = input.color(color.orange, "Mar", group=groupColors)
cApr = input.color(color.rgb(255,170,0), "Apr", group=groupColors)
cMay = input.color(color.yellow, "May", group=groupColors)
cJun = input.color(color.lime, "Jun", group=groupColors)
cJul = input.color(color.green, "Jul", group=groupColors)
cAug = input.color(color.teal, "Aug", group=groupColors)
cSep = input.color(color.aqua, "Sep", group=groupColors)
cOct = input.color(color.blue, "Oct", group=groupColors)
cNov = input.color(color.fuchsia, "Nov", group=groupColors)
cDec = input.color(color.purple, "Dec", group=groupColors)

//--------------------------------------------------
// Helpers
//--------------------------------------------------
monthCode(int m) =>
    switch m
        1  => "F"
        2  => "G"
        3  => "H"
        4  => "J"
        5  => "K"
        6  => "M"
        7  => "N"
        8  => "Q"
        9  => "U"
        10 => "V"
        11 => "X"
        12 => "Z"
        => "?"

buildTicker(int m, int y) =>
    exchangePrefix + rootSymbol + monthCode(m) + str.tostring(y)

reqRate(string ticker) =>
    x = request.security(ticker, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
    na(x) ? na : 100.0 - x

//--------------------------------------------------
// Symbols
//--------------------------------------------------
sJan = buildTicker(1, yearJan)
sFeb = buildTicker(2, yearFeb)
sMar = buildTicker(3, yearMar)
sApr = buildTicker(4, yearApr)
sMay = buildTicker(5, yearMay)
sJun = buildTicker(6, yearJun)
sJul = buildTicker(7, yearJul)
sAug = buildTicker(8, yearAug)
sSep = buildTicker(9, yearSep)
sOct = buildTicker(10, yearOct)
sNov = buildTicker(11, yearNov)
sDec = buildTicker(12, yearDec)

//--------------------------------------------------
// Rates
//--------------------------------------------------
rJan = showJan ? reqRate(sJan) : na
rFeb = showFeb ? reqRate(sFeb) : na
rMar = showMar ? reqRate(sMar) : na
rApr = showApr ? reqRate(sApr) : na
rMay = showMay ? reqRate(sMay) : na
rJun = showJun ? reqRate(sJun) : na
rJul = showJul ? reqRate(sJul) : na
rAug = showAug ? reqRate(sAug) : na
rSep = showSep ? reqRate(sSep) : na
rOct = showOct ? reqRate(sOct) : na
rNov = showNov ? reqRate(sNov) : na
rDec = showDec ? reqRate(sDec) : na

//--------------------------------------------------
// Fed band
//--------------------------------------------------
pLow = plot(fedLower, "Fed Lower", color=color.white, linewidth=1, display=display.pane)
pUp  = plot(fedUpper, "Fed Upper", color=color.white, linewidth=1, display=display.pane)
fill(pLow, pUp, color=color.new(color.white, 90))

//--------------------------------------------------
// Plots
//--------------------------------------------------
plot(rJan, "Jan", color=cJan, linewidth=2, display=display.pane)
plot(rFeb, "Feb", color=cFeb, linewidth=2, display=display.pane)
plot(rMar, "Mar", color=cMar, linewidth=2, display=display.pane)
plot(rApr, "Apr", color=cApr, linewidth=2, display=display.pane)
plot(rMay, "May", color=cMay, linewidth=2, display=display.pane)
plot(rJun, "Jun", color=cJun, linewidth=2, display=display.pane)
plot(rJul, "Jul", color=cJul, linewidth=2, display=display.pane)
plot(rAug, "Aug", color=cAug, linewidth=2, display=display.pane)
plot(rSep, "Sep", color=cSep, linewidth=2, display=display.pane)
plot(rOct, "Oct", color=cOct, linewidth=2, display=display.pane)
plot(rNov, "Nov", color=cNov, linewidth=2, display=display.pane)
plot(rDec, "Dec", color=cDec, linewidth=2, display=display.pane)

//--------------------------------------------------
// Table: show only enabled months
//--------------------------------------------------
var table t = table.new(position.top_right, 4, 14, border_width=1)

if barstate.islast
    table.clear(t, 0, 0, 3, 13)

    table.cell(t, 0, 0, "Month")
    table.cell(t, 1, 0, "Ticker")
    table.cell(t, 2, 0, "Year")
    table.cell(t, 3, 0, "Rate")

    int row = 1

    if showJan
        table.cell(t, 0, row, "Jan", text_color=cJan)
        table.cell(t, 1, row, sJan, text_color=cJan)
        table.cell(t, 2, row, str.tostring(yearJan), text_color=cJan)
        table.cell(t, 3, row, na(rJan) ? "na" : str.tostring(rJan, "#.##"), text_color=cJan)
        row += 1

    if showFeb
        table.cell(t, 0, row, "Feb", text_color=cFeb)
        table.cell(t, 1, row, sFeb, text_color=cFeb)
        table.cell(t, 2, row, str.tostring(yearFeb), text_color=cFeb)
        table.cell(t, 3, row, na(rFeb) ? "na" : str.tostring(rFeb, "#.##"), text_color=cFeb)
        row += 1

    if showMar
        table.cell(t, 0, row, "Mar", text_color=cMar)
        table.cell(t, 1, row, sMar, text_color=cMar)
        table.cell(t, 2, row, str.tostring(yearMar), text_color=cMar)
        table.cell(t, 3, row, na(rMar) ? "na" : str.tostring(rMar, "#.##"), text_color=cMar)
        row += 1

    if showApr
        table.cell(t, 0, row, "Apr", text_color=cApr)
        table.cell(t, 1, row, sApr, text_color=cApr)
        table.cell(t, 2, row, str.tostring(yearApr), text_color=cApr)
        table.cell(t, 3, row, na(rApr) ? "na" : str.tostring(rApr, "#.##"), text_color=cApr)
        row += 1

    if showMay
        table.cell(t, 0, row, "May", text_color=cMay)
        table.cell(t, 1, row, sMay, text_color=cMay)
        table.cell(t, 2, row, str.tostring(yearMay), text_color=cMay)
        table.cell(t, 3, row, na(rMay) ? "na" : str.tostring(rMay, "#.##"), text_color=cMay)
        row += 1

    if showJun
        table.cell(t, 0, row, "Jun", text_color=cJun)
        table.cell(t, 1, row, sJun, text_color=cJun)
        table.cell(t, 2, row, str.tostring(yearJun), text_color=cJun)
        table.cell(t, 3, row, na(rJun) ? "na" : str.tostring(rJun, "#.##"), text_color=cJun)
        row += 1

    if showJul
        table.cell(t, 0, row, "Jul", text_color=cJul)
        table.cell(t, 1, row, sJul, text_color=cJul)
        table.cell(t, 2, row, str.tostring(yearJul), text_color=cJul)
        table.cell(t, 3, row, na(rJul) ? "na" : str.tostring(rJul, "#.##"), text_color=cJul)
        row += 1

    if showAug
        table.cell(t, 0, row, "Aug", text_color=cAug)
        table.cell(t, 1, row, sAug, text_color=cAug)
        table.cell(t, 2, row, str.tostring(yearAug), text_color=cAug)
        table.cell(t, 3, row, na(rAug) ? "na" : str.tostring(rAug, "#.##"), text_color=cAug)
        row += 1

    if showSep
        table.cell(t, 0, row, "Sep", text_color=cSep)
        table.cell(t, 1, row, sSep, text_color=cSep)
        table.cell(t, 2, row, str.tostring(yearSep), text_color=cSep)
        table.cell(t, 3, row, na(rSep) ? "na" : str.tostring(rSep, "#.##"), text_color=cSep)
        row += 1

    if showOct
        table.cell(t, 0, row, "Oct", text_color=cOct)
        table.cell(t, 1, row, sOct, text_color=cOct)
        table.cell(t, 2, row, str.tostring(yearOct), text_color=cOct)
        table.cell(t, 3, row, na(rOct) ? "na" : str.tostring(rOct, "#.##"), text_color=cOct)
        row += 1

    if showNov
        table.cell(t, 0, row, "Nov", text_color=cNov)
        table.cell(t, 1, row, sNov, text_color=cNov)
        table.cell(t, 2, row, str.tostring(yearNov), text_color=cNov)
        table.cell(t, 3, row, na(rNov) ? "na" : str.tostring(rNov, "#.##"), text_color=cNov)
        row += 1

    if showDec
        table.cell(t, 0, row, "Dec", text_color=cDec)
        table.cell(t, 1, row, sDec, text_color=cDec)
        table.cell(t, 2, row, str.tostring(yearDec), text_color=cDec)
        table.cell(t, 3, row, na(rDec) ? "na" : str.tostring(rDec, "#.##"), text_color=cDec)
        row += 1
````
