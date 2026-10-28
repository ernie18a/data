# Nifty 50 Stock Candle Breadth

- url: https://www.tradingview.com/script/KOugvnCe-Nifty-50-Stock-Candle-Breadth/
- type: indicator
- pine_id: PUB;45274a8eaf154879a9e2c29d1bc0301e
- version: 1.0

## Description

[b]Nifty 50 Stock Candle Breadth[/b]
This indicator tracks the candle color (green or red) of 40 Nifty 50 component stocks on the current timeframe and uses that breadth data to recolor the chart's bars.

[b]How it works[/b]
On each bar, the indicator fetches the open and close price of each of the 40 tracked NSE stocks using request.security. It counts how many stocks closed green (close > open) and how many closed red (close < open). The current chart's bar is then recolored based on two factors: the chart's own candle direction, and whether the green or red stock count meets or exceeds the configured threshold.
If the threshold is met in the same direction as the chart candle, a darker shade is applied. If the threshold is not met, a lighter shade is used. Neutral (doji) candles display in gray.

[b]Bar color logic[/b]
[list]
[*]Dark green — chart candle is green and green stock count is at or above threshold
[*]Light green — chart candle is green but green stock count is below threshold
[*]Dark red — chart candle is red and red stock count is at or above threshold
[*]Light red — chart candle is red but red stock count is below threshold
[*]Gray — chart candle is neutral (open equals close)
[/list]

[b]Stock table[/b]
An optional table displays all 40 tracked stocks in two columns with a color indicator for each. A summary row at the bottom shows the total green and red counts with their percentage of the 40 stocks. The table can be toggled off via the input settings.

[b]Settings[/b]
[list]
[*]Table Position — corner of the chart where the table appears
[*]Stock Count Threshold — number of stocks required in one direction to trigger the darker bar color (default: 30)
[*]Show Stock Table — toggle the stock detail table on or off
[/list]

[b]Applicable to NSE charts on any timeframe.[/b]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © lazyhacker

//@version=6
indicator(title="Nifty 50 Stock Candle Breadth", shorttitle="N50 Breadth", overlay=true, dynamic_requests=true)

// --- Inputs ---
inpPosition  = input.string(title="Table Position",      defval=position.top_right, options=[position.top_right, position.top_left, position.bottom_right, position.bottom_left])
inpThreshold = input.int(title="Stock Count Threshold",  defval=30, minval=1, maxval=40)
inpShowTable = input.bool(title="Show Stock Table",      defval=true)

// --- Stock list (40 Nifty 50 components) ---
string[] nifty50 = array.from(
  "RELIANCE",   "HDFCBANK",   "BHARTIARTL", "SBIN",       "ICICIBANK",
  "TCS",        "BAJFINANCE", "LT",         "HINDUNILVR", "INFY",
  "MARUTI",     "AXISBANK",   "M&M",        "SUNPHARMA",  "KOTAKBANK",
  "ITC",        "TITAN",      "HCLTECH",    "ULTRACEMCO", "NTPC",
  "ONGC",       "ADANIPORTS", "BEL",        "TVSMOTOR",   "BAJAJFINSV",
  "TATASTEEL",  "TATACONSUM", "POWERGRID",  "CIPLA",      "DRREDDY",
  "COALINDIA",  "HINDALCO",   "GRASIM",     "NESTLEIND",  "JSWSTEEL",
  "SHRIRAMFIN", "WIPRO",      "BAJAJ_AUTO", "TECHM",      "HDFCLIFE")

int numStocks  = array.size(nifty50)
int rowsPerCol = math.ceil(numStocks / 2.0)

// --- Colors ---
color GREEN      = color.new(color.green, 20)
color RED        = color.new(color.red,   20)
color DARK_GREEN = color.new(#003300,      0)
color DARK_RED   = color.new(#330000,      0)
color NEUTRAL    = color.new(color.gray,  60)
color TEXT       = color.white
color HEADER     = color.new(color.black,  0)
color TRANSP     = color.new(color.black, 100)

// --- Fetch open/close for each stock and count green/red candles ---
int     greenCount  = 0
int     redCount    = 0
color[] stockColors = array.new<color>(numStocks, NEUTRAL)

for i = 0 to numStocks - 1
    string ticker = "NSE:" + array.get(nifty50, i)
    [o, c] = request.security(ticker, timeframe.period, [open, close], lookahead=barmerge.lookahead_off)

    color cColor = NEUTRAL
    if not na(o) and not na(c)
        if c > o
            greenCount += 1
            cColor      := GREEN
        else if c < o
            redCount   += 1
            cColor      := RED

    array.set(stockColors, i, cColor)

// --- Apply bar color based on breadth threshold ---
bool chartGreen = close > open
bool chartRed   = close < open

color candleColor =
  chartGreen and greenCount >= inpThreshold ? DARK_GREEN :
  chartRed   and redCount   >= inpThreshold ? DARK_RED   :
  chartGreen                                ? GREEN      :
  chartRed                                  ? RED        :
  NEUTRAL

barcolor(candleColor)

// --- Table display ---
var table tbl = table.new(position=inpPosition, columns=4, rows=rowsPerCol + 2, border_width=1)

if barstate.islast
    if inpShowTable
        table.cell(tbl, 0, 0, "Stock", text_color=TEXT, bgcolor=HEADER, text_size=size.tiny)
        table.cell(tbl, 1, 0, "C",     text_color=TEXT, bgcolor=HEADER, text_size=size.tiny)
        table.cell(tbl, 2, 0, "Stock", text_color=TEXT, bgcolor=HEADER, text_size=size.tiny)
        table.cell(tbl, 3, 0, "C",     text_color=TEXT, bgcolor=HEADER, text_size=size.tiny)

        for i = 0 to numStocks - 1
            string stock  = array.get(nifty50, i)
            color  cColor = array.get(stockColors, i)
            int colOffset = i < rowsPerCol ? 0 : 2
            int row       = i % rowsPerCol + 1

            table.cell(tbl, colOffset,     row, stock, text_color=TEXT,   bgcolor=HEADER, text_size=size.tiny)
            table.cell(tbl, colOffset + 1, row, " ",   text_color=cColor, bgcolor=cColor, text_size=size.tiny)

        float pctGreen   = greenCount * 100.0 / numStocks
        float pctRed     = redCount   * 100.0 / numStocks
        int   summaryRow = rowsPerCol + 1

        table.cell(tbl, 0, summaryRow, "Up "   + str.tostring(greenCount),   text_color=color.green, bgcolor=HEADER, text_size=size.tiny)
        table.cell(tbl, 1, summaryRow, str.tostring(pctGreen, "00.0") + "%", text_color=color.green, bgcolor=HEADER, text_size=size.tiny)
        table.cell(tbl, 2, summaryRow, "Down " + str.tostring(redCount),     text_color=color.red,   bgcolor=HEADER, text_size=size.tiny)
        table.cell(tbl, 3, summaryRow, str.tostring(pctRed,   "00.0") + "%", text_color=color.red,   bgcolor=HEADER, text_size=size.tiny)
    else
        for r = 0 to rowsPerCol + 1
            for col = 0 to 3
                table.cell(tbl, col, r, " ", text_color=TRANSP, bgcolor=TRANSP)
````
