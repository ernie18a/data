# 4H SMA20/SMA50 Cross Proximity

- url: https://www.tradingview.com/script/b9xOZ1Fx-4H-SMA20-SMA50-Cross-Proximity/
- type: indicator
- pine_id: PUB;028494d2f31744f4b884d62978c7372f
- version: 2.0

## Description

The script “4H Bullish SMA20/50 Proximity” is designed to find stocks where the 20-period Simple Moving Average (SMA20) is approaching the 50-period Simple Moving Average (SMA50) from below, potentially signaling an upcoming bullish crossover.
Here is what each part does.
1. Script settings
maxGap = input.float(1.0, "Maximum gap (%)", minval=0.01, step=0.05)
minGap = input.float(0.0, "Minimum gap (%)", minval=0.0, step=0.05)


These settings let you control how close the two moving averages must be.
- Maximum gap = 1.0%: The averages must be no more than 1% apart.
- Minimum gap = 0.0%: Allows all gaps from zero upward.
For example, if SMA50 is 100 and SMA20 is 99.80, the gap is 0.20%, so it meets the default distance thresholds.
2. Calculate the moving averages
sma20 = ta.sma(close, 20)
sma50 = ta.sma(close, 50)


- ta.sma(close, 20) calculates the average closing price of the last 20 candles.
- ta.sma(close, 50) calculates the average closing price of the last 50 candles.
Important: The script uses the timeframe selected in Pine Screener. To scan using 4-hour candles, set the screener interval to 4 hours.
3. Calculate the distance between the SMAs
gap = sma50 != 0 ? math.abs(sma20 - sma50) / math.abs(sma50) * 100 : na


This calculates the percentage distance between SMA20 and SMA50 relative to SMA50.
SMA20	SMA50	Gap
99.00	100.00	1.00%
99.50	100.00	0.50%
99.80	100.00	0.20%
99.95	100.00	0.05%
The smaller the gap, the closer the averages are to crossing.
4. Identify an approaching bullish crossover
approaching = sma20 < sma50 and gap >= minGap and gap <= maxGap and gap < gap[1]


This is the main condition. All four requirements must be true:
1. sma20 < sma50 — SMA20 is below SMA50, so the bullish crossover has not happened yet.
2. gap >= minGap — The distance meets your minimum threshold.
3. gap <= maxGap — The distance is within your maximum threshold.
4. gap < gap[1] — The distance is smaller than it was on the previous candle.
For example, if the gap decreases from 0.70% to 0.45% to 0.20%, the stock meets the narrowing-gap condition, provided the other requirements are satisfied.
If the gap starts increasing again, the approaching signal becomes false.
5. Make the results available to Pine Screener
plot(gap, "SMA Gap %", display=display.data_window)
plot(approaching ? 1 : 0, "Bullish Setup (1 = Yes)")
plot(sma20 < sma50 ? 1 : 0, "SMA20 Below SMA50")


These three plots expose values that you can use when filtering stocks.
Plot name	Output	Purpose
SMA Gap %	Percentage	Shows how close the SMAs are
Bullish Setup (1 = Yes)	1 or 0	Identifies stocks meeting all conditions
SMA20 Below SMA50	1 or 0	Confirms that SMA20 remains below SMA50
In Pine Screener, filter Bullish Setup (1 = Yes) to equal 1. That leaves stocks satisfying the approach conditions.
Note that SMA Gap % uses display.data_window, so it is available in the Data Window rather than being drawn as a visible chart line.
Recommended settings for your strategy
Maximum gap
0.50%

0.1%
1%
2%




Minimum gap
0.00%

0%
0.25%
0.5%




This configuration looks for a narrowing gap between 0.00% and 0.50% on the 4-hour timeframe.
Copy these settings
My starting recommendation is a maximum gap of 0.50% and a minimum of 0.00%. This is a tighter starting filter than 1%, but it may miss some early setups.
Limitation to remember: A narrowing gap does not guarantee a crossover. The averages may separate again, and this script does not estimate how many candles remain until the crossover.

## Source Code

````pine

 //@version=6
indicator("US Stocks 4H SMA20/50 Scanner Table",
     overlay=true, dynamic_requests=true)

// ───── SETTINGS ─────
symbolsInput = input.string(
     "NASDAQ:AAPL,NASDAQ:MSFT,NASDAQ:NVDA,NASDAQ:AMZN,NASDAQ:GOOGL,NASDAQ:META,NASDAQ:TSLA,NASDAQ:AVGO,NASDAQ:AMD,NASDAQ:PLTR,NYSE:ORCL,NYSE:CRM,NYSE:LLY,NYSE:JPM,NYSE:V,NYSE:WMT,NASDAQ:COST,NASDAQ:MU,NASDAQ:QCOM,NYSE:UBER",
     "Stock symbols (comma separated)")

maxGap = input.float(1.0, "Maximum gap (%)", minval=0.01, step=0.05)
minGap = input.float(0.0, "Minimum gap (%)", minval=0.0, step=0.05)
maxSymbols = input.int(20, "Maximum symbols", minval=1, maxval=20)

// ───── 4H CALCULATIONS ─────
getData() =>
    float fast = ta.sma(close, 20)
    float slow = ta.sma(close, 50)
    float gap = slow != 0 ? math.abs(fast - slow) / math.abs(slow) * 100 : na
    [fast[1], slow[1], gap[1], gap[2]]

var table results = table.new(
     position.top_right, 6, 22,
     border_width=1, frame_width=1)

var array<string> tickers = array.new_string()
var array<float> fasts = array.new_float()
var array<float> slows = array.new_float()
var array<float> gaps = array.new_float()
var array<float> previousGaps = array.new_float()
var array<string> statuses = array.new_string()

// Run requests on every bar so symbol data is initialized.
string[] symbols = str.split(symbolsInput, ",")
int count = math.min(array.size(symbols), maxSymbols)

if barstate.islast
    array.clear(tickers)
    array.clear(fasts)
    array.clear(slows)
    array.clear(gaps)
    array.clear(previousGaps)
    array.clear(statuses)

for i = 0 to count - 1
    string sym = str.trim(array.get(symbols, i))

    [fast, slow, gap, oldGap] = request.security(
         sym, "240", getData(),
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_on,
         ignore_invalid_symbol=true)

    if barstate.islast and not na(fast) and not na(slow) and not na(gap)
        bool approaching = fast < slow and
             gap >= minGap and gap <= maxGap and
             not na(oldGap) and gap < oldGap

        string status = fast >= slow ? "ABOVE SMA50" :
             approaching ? "APPROACHING" : "WAIT"

        array.push(tickers, sym)
        array.push(fasts, fast)
        array.push(slows, slow)
        array.push(gaps, gap)
        array.push(previousGaps, oldGap)
        array.push(statuses, status)

// ───── DISPLAY TABLE ─────
if barstate.islast
    table.clear(results, 0, 0, 5, 21)

    table.cell(results, 0, 0, "STOCK",
         bgcolor=color.navy, text_color=color.white)
    table.cell(results, 1, 0, "SMA20",
         bgcolor=color.navy, text_color=color.white)
    table.cell(results, 2, 0, "SMA50",
         bgcolor=color.navy, text_color=color.white)
    table.cell(results, 3, 0, "GAP %",
         bgcolor=color.navy, text_color=color.white)
    table.cell(results, 4, 0, "PREV GAP",
         bgcolor=color.navy, text_color=color.white)
    table.cell(results, 5, 0, "STATUS",
         bgcolor=color.navy, text_color=color.white)

    int total = array.size(tickers)

    if total > 0
        array<int> order = array.sort_indices(gaps, order.ascending)

        for j = 0 to total - 1
            int idx = array.get(order, j)
            float g = array.get(gaps, idx)
            float pg = array.get(previousGaps, idx)
            string status = array.get(statuses, idx)

            color rowColor = status == "APPROACHING" ?
                 color.new(color.green, 75) :
                 status == "ABOVE SMA50" ?
                 color.new(color.blue, 80) :
                 color.new(color.gray, 88)

            int r = j + 1

            table.cell(results, 0, r, array.get(tickers, idx),
                 bgcolor=rowColor, text_color=color.white)
            table.cell(results, 1, r,
                 str.tostring(array.get(fasts, idx), "#.##"),
                 bgcolor=rowColor, text_color=color.white)
            table.cell(results, 2, r,
                 str.tostring(array.get(slows, idx), "#.##"),
                 bgcolor=rowColor, text_color=color.white)
            table.cell(results, 3, r,
                 str.tostring(g, "#.###") + "%",
                 bgcolor=rowColor, text_color=color.white)
            table.cell(results, 4, r,
                 na(pg) ? "N/A" : str.tostring(pg, "#.###") + "%",
                 bgcolor=rowColor, text_color=color.white)
            table.cell(results, 5, r, status,
                 bgcolor=rowColor, text_color=color.white)

    if total == 0
        table.cell(results, 0, 1, "No valid data",
             text_color=color.white)
        table.cell(results, 1, 1, "Check symbols",
             text_color=color.white)
````
