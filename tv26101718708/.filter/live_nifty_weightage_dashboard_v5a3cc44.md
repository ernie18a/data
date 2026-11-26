# LIVE NIFTY WEIGHTAGE DASHBOARD

- url: https://www.tradingview.com/script/v5A3cC44-LIVE-NIFTY-WEIGHTAGE-DASHBOARD/
- type: indicator
- pine_id: PUB;b449da7cddd34073be7f1b3e1e680b1f
- version: 2.0

## Description

Script Description: LIVE NIFTY WEIGHTAGE DASHBOARD
This script creates an interactive, real-time on-chart dashboard designed to monitor the NIFTY 50 Index alongside its high-weightage constituent stocks. It provides a consolidated view of market performance without the need to switch between multiple tabs.

Key Features:

Live Index Tracking: Displays the current price and percentage change of the NIFTY 50 at the top of the table.

Multi-Stock Monitoring: Automatically iterates through an array of heavy-weight stocks (including RELIANCE, TCS, HDFC BANK, and L&T) to show their live price and intraday performance.

Weightage Analysis: Includes a dedicated column for stock weights, helping traders understand which names are currently driving the index movement.

Visual Heatmap: Features dynamic color-coding (Green for positive, Red for negative) for both cell backgrounds and text, allowing for instant trend recognition.

## Source Code

````pine
//@version=5
indicator("LIVE NIFTY WEIGHTAGE DASHBOARD", overlay=true)

// ======================================
// TABLE SETTINGS
// ======================================
tablePos = input.string(
     "top_right",
     "Table Position",
     options = ["top_right", "top_left", "bottom_right", "bottom_left"])

textSizeInput = input.string(
     "normal",
     "Table Text Size",
     options = ["tiny", "small", "normal", "large", "huge"])

// ======================================
// TABLE POSITION
// ======================================
pos =
     tablePos == "top_left" ? position.top_left :
     tablePos == "bottom_left" ? position.bottom_left :
     tablePos == "bottom_right" ? position.bottom_right :
     position.top_right

// ======================================
// TEXT SIZE
// ======================================
txtSize =
     textSizeInput == "tiny" ? size.tiny :
     textSizeInput == "small" ? size.small :
     textSizeInput == "large" ? size.large :
     textSizeInput == "huge" ? size.huge :
     size.normal

// ======================================
// COLORS
// ======================================
headerBg   = color.rgb(60, 0, 90)
headerTxt  = color.orange

positiveBg = color.rgb(0, 120, 0)
negativeBg = color.rgb(180, 0, 0)

positiveTxt = color.white
negativeTxt = color.white

weightBg  = color.rgb(0, 70, 180)
weightTxt = color.white

niftyPosBg = color.green
niftyNegBg = color.red

emptyBg = color.gray

// ======================================
// STOCK INPUTS
// ======================================
stock1 = input.symbol("NSE:RELIANCE", "Stock 1")
stock2 = input.symbol("NSE:HDFCBANK", "Stock 2")
stock3 = input.symbol("NSE:ICICIBANK", "Stock 3")
stock4 = input.symbol("NSE:INFY", "Stock 4")
stock5 = input.symbol("NSE:TCS", "Stock 5")
stock6 = input.symbol("NSE:LT", "Stock 6")
stock7 = input.symbol("NSE:BHARTIARTL", "Stock 7")

// ======================================
// AUTO WEIGHT FUNCTION
// ======================================
getWeight(sym) =>
    switch sym
        "NSE:HDFCBANK"   => 13.20
        "NSE:RELIANCE"   => 9.50
        "NSE:ICICIBANK"  => 8.10
        "NSE:INFY"       => 6.20
        "NSE:TCS"        => 4.10
        "NSE:LT"         => 3.80
        "NSE:BHARTIARTL" => 5.10
        "NSE:ITC"        => 4.30
        "NSE:AXISBANK"   => 3.00
        "NSE:KOTAKBANK"  => 3.50
        "NSE:BAJFINANCE" => 2.70
        "NSE:MARUTI"     => 2.10
        "NSE:TATAMOTORS" => 1.90
        "NSE:ASIANPAINT" => 1.60
        => 1.00

// ======================================
// DAILY CHANGE FUNCTION
// ======================================
getData(sym) =>

    // LIVE PRICE
    livePrice = request.security(sym, timeframe.period, close)

    // DAILY CLOSE
    dayClose = request.security(sym, "D", close)

    // PREVIOUS DAY CLOSE
    prevDayClose = request.security(sym, "D", close[1])

    // DAILY % CHANGE
    ch = prevDayClose != 0 ?
         ((dayClose - prevDayClose) / prevDayClose) * 100 : 0

    [livePrice, ch]

// ======================================
// NIFTY DATA
// ======================================
[niftyClose, niftyChg] = getData("NSE:NIFTY")

// ======================================
// STOCK DATA
// ======================================
[c1, ch1] = getData(stock1)
[c2, ch2] = getData(stock2)
[c3, ch3] = getData(stock3)
[c4, ch4] = getData(stock4)
[c5, ch5] = getData(stock5)
[c6, ch6] = getData(stock6)
[c7, ch7] = getData(stock7)

// ======================================
// ARRAYS
// ======================================
var string[] names   = array.new_string()
var float[] changes  = array.new_float()
var float[] prices   = array.new_float()
var float[] weights  = array.new_float()

array.clear(names)
array.clear(changes)
array.clear(prices)
array.clear(weights)

// ======================================
// PUSH FUNCTION
// ======================================
pushData(sym, ch, pr, wt) =>
    array.push(names, str.replace(sym, "NSE:", ""))
    array.push(changes, ch)
    array.push(prices, pr)
    array.push(weights, wt)

// ======================================
// PUSH DATA
// ======================================
pushData(stock1, ch1, c1, getWeight(stock1))
pushData(stock2, ch2, c2, getWeight(stock2))
pushData(stock3, ch3, c3, getWeight(stock3))
pushData(stock4, ch4, c4, getWeight(stock4))
pushData(stock5, ch5, c5, getWeight(stock5))
pushData(stock6, ch6, c6, getWeight(stock6))
pushData(stock7, ch7, c7, getWeight(stock7))

// ======================================
// SORT BY DAILY % CHANGE
// ======================================
for i = 0 to array.size(changes) - 2

    for j = 0 to array.size(changes) - i - 2

        if array.get(changes, j) < array.get(changes, j + 1)

            tempCh = array.get(changes, j)
            tempNm = array.get(names, j)
            tempPr = array.get(prices, j)
            tempWt = array.get(weights, j)

            array.set(changes, j, array.get(changes, j + 1))
            array.set(names, j, array.get(names, j + 1))
            array.set(prices, j, array.get(prices, j + 1))
            array.set(weights, j, array.get(weights, j + 1))

            array.set(changes, j + 1, tempCh)
            array.set(names, j + 1, tempNm)
            array.set(prices, j + 1, tempPr)
            array.set(weights, j + 1, tempWt)

// ======================================
// TABLE
// ======================================
var table tbl = table.new(
     pos,
     4,
     10,
     border_width = 1,
     border_color = color.white)

// ======================================
// HEADER
// ======================================
table.cell(tbl, 0, 0,
     "STOCK",
     bgcolor = headerBg,
     text_color = headerTxt,
     text_size = txtSize)

table.cell(tbl, 1, 0,
     "DAILY %",
     bgcolor = headerBg,
     text_color = headerTxt,
     text_size = txtSize)

table.cell(tbl, 2, 0,
     "LIVE PRICE",
     bgcolor = headerBg,
     text_color = headerTxt,
     text_size = txtSize)

table.cell(tbl, 3, 0,
     "WT%",
     bgcolor = headerBg,
     text_color = headerTxt,
     text_size = txtSize)

// ======================================
// NIFTY ROW
// ======================================
niftyBg = niftyChg >= 0 ? niftyPosBg : niftyNegBg

table.cell(tbl, 0, 1,
     "NIFTY 50",
     bgcolor = niftyBg,
     text_color = color.white,
     text_size = txtSize)

table.cell(tbl, 1, 1,
     str.tostring(niftyChg, "#.##") + "%",
     bgcolor = niftyBg,
     text_color = color.white,
     text_size = txtSize)

table.cell(tbl, 2, 1,
     str.tostring(niftyClose, "#.##"),
     bgcolor = niftyBg,
     text_color = color.white,
     text_size = txtSize)

table.cell(tbl, 3, 1,
     "-",
     bgcolor = emptyBg,
     text_color = color.white,
     text_size = txtSize)

// ======================================
// DISPLAY STOCKS
// ======================================
for i = 0 to array.size(names) - 1

    nm = array.get(names, i)
    ch = array.get(changes, i)
    pr = array.get(prices, i)
    wt = array.get(weights, i)

    rowBg = ch >= 0 ? positiveBg : negativeBg

    table.cell(tbl, 0, i + 2,
         nm,
         bgcolor = rowBg,
         text_color = color.white,
         text_size = txtSize)

    table.cell(tbl, 1, i + 2,
         str.tostring(ch, "#.##") + "%",
         bgcolor = rowBg,
         text_color = color.white,
         text_size = txtSize)

    table.cell(tbl, 2, i + 2,
         "₹ " + str.tostring(pr, "#.##"),
         bgcolor = rowBg,
         text_color = color.white,
         text_size = txtSize)

    table.cell(tbl, 3, i + 2,
         str.tostring(wt, "#.##") + "%",
         bgcolor = weightBg,
         text_color = weightTxt,
         text_size = txtSize)
````
