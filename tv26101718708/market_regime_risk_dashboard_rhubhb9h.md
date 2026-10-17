# Market Regime & Risk Dashboard

- url: https://www.tradingview.com/script/rhUBHb9h/
- type: indicator
- pine_id: PUB;05ef3c79d6014cae88933fd573a32777
- version: 1.0

## Description

An analytics and risk dashboard. It tells you what state the market is in and how much to risk. It does NOT generate buy or sell signals and makes no claim of edge.

What it shows
- Volatility regime: realized volatility bucketed by its own percentile history (Low / Normal / High / Extreme)
- Realized volatility and its percentile rank
- Trend regime: Kaufman Efficiency Ratio bucketed into Trending / Mixed / Choppy
- ATR % of price, an ATR-based stop distance, and a fixed-fractional position size for your chosen risk percent
- Drawdown from the recent high

How to read it
Volatility regime drives position sizing: in Extreme regimes the same percent risk implies a far smaller position, and the dashboard does that maths for you. The trend regime is descriptive, not predictive.

Honest by design
- No buy/sell signals, no alpha claim. This is a measurement tool, not a prediction.
- Non-repainting: every value is a function of confirmed closes, no request.security, no future data. The current forming bar updates in real time, which is normal, not historical repaint.
- Every number is defined, with its limitations stated.

Open-source and MIT licensed.

Disclaimer: impersonal educational and analytics tool. This is not investment advice, not a personalised recommendation, and carries no performance guarantee. Past results do not predict future results. You are solely responsible for your own trading decisions.

## Source Code

````pine
//@version=6
// Market Regime & Risk Dashboard
// An analytics and risk tool. It does NOT generate buy or sell signals and
// makes no claim of edge. It describes the current market state and sizes risk.
// Non-repainting by design: every value is a function of confirmed closes, it
// uses no request.security and no future data. The current forming bar updates
// until it closes, which is normal for any real-time indicator and is not
// repainting of historical bars.
indicator("Market Regime & Risk Dashboard", overlay = true)
// Disclaimer: impersonal educational/analytics tool, not investment advice, no
// performance guarantees, no buy/sell signals, no auto-execution.

volLen  = input.int(20, "Realized Vol Window", minval = 2, group = "Regime")
rankLen = input.int(100, "Vol Percentile Lookback", minval = 10, group = "Regime")
erLen   = input.int(20, "Efficiency Ratio Window", minval = 2, group = "Regime")
annMode = input.string("Raw rolling", "Annualization",
     options = ["Raw rolling", "Daily stocks", "Daily crypto", "Hourly crypto"],
     tooltip = "Pick your timeframe to display annualised volatility. Use Raw rolling for percentile regime only.",
     group = "Regime")
annFac = annMode == "Daily stocks" ? math.sqrt(252) : annMode == "Daily crypto" ? math.sqrt(365) : annMode == "Hourly crypto" ? math.sqrt(365 * 24) : 1.0

atrLen  = input.int(14, "ATR Length", minval = 1, group = "Risk")
atrMult = input.float(2.0, "Stop = ATR x", minval = 0.1, step = 0.1, group = "Risk")
acct    = input.float(10000, "Account Size", minval = 0, group = "Risk")
riskPct = input.float(1.0, "Risk per Trade %", minval = 0.0, step = 0.1, group = "Risk")
hiLen   = input.int(50, "High Lookback (drawdown)", minval = 2, group = "Risk")

showBg  = input.bool(true, "Colour background by vol regime", group = "Display")

logRet = math.log(close / close[1])
rv     = ta.stdev(logRet, volLen)
rvRank = ta.percentrank(rv, rankLen)
rvShow = rv * annFac * 100.0

volRegime = rvRank >= 85 ? "Extreme" : rvRank >= 65 ? "High" : rvRank >= 35 ? "Normal" : "Low"
volColor  = rvRank >= 85 ? color.red : rvRank >= 65 ? color.orange : rvRank >= 35 ? color.green : color.gray

direction = math.abs(close - close[erLen])
noise     = math.sum(math.abs(ta.change(close)), erLen)
er        = noise != 0 ? direction / noise : 0.0
trendRegime = er >= 0.5 ? "Trending" : er >= 0.3 ? "Mixed" : "Choppy"
trendColor  = er >= 0.5 ? color.teal : er >= 0.3 ? color.gray : color.maroon

atr      = ta.atr(atrLen)
atrPct   = close != 0 ? atr / close * 100.0 : na
stopDist = atr * atrMult
riskAmt  = acct * riskPct / 100.0
posSize  = stopDist > 0 ? riskAmt / stopDist : na

recentHigh = ta.highest(high, hiLen)
ddHigh     = recentHigh != 0 ? (close - recentHigh) / recentHigh * 100.0 : na

bgcolor(showBg ? color.new(volColor, 90) : na)

var table t = table.new(position.top_right, 2, 9, border_width = 1)
if barstate.islast
    table.cell(t, 0, 0, "Regime & Risk", text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor = color.new(color.black, 0))
    table.cell(t, 0, 1, "Vol Regime")
    table.cell(t, 1, 1, volRegime, text_color = color.white, bgcolor = color.new(volColor, 30))
    table.cell(t, 0, 2, "Realized Vol")
    table.cell(t, 1, 2, str.tostring(rvShow, "#.##") + "%")
    table.cell(t, 0, 3, "Vol Percentile")
    table.cell(t, 1, 3, str.tostring(rvRank, "#.#") + "%")
    table.cell(t, 0, 4, "Trend Regime")
    table.cell(t, 1, 4, trendRegime + " " + str.tostring(er, "#.##"), text_color = color.white, bgcolor = color.new(trendColor, 30))
    table.cell(t, 0, 5, "ATR %")
    table.cell(t, 1, 5, str.tostring(atrPct, "#.##") + "%")
    table.cell(t, 0, 6, "Suggested Stop")
    table.cell(t, 1, 6, str.tostring(stopDist, format.mintick))
    table.cell(t, 0, 7, "Risk Units")
    table.cell(t, 1, 7, na(posSize) ? "set risk" : str.tostring(posSize, "#.######"))
    table.cell(t, 0, 8, "Dist from High")
    table.cell(t, 1, 8, str.tostring(ddHigh, "#.##") + "%")
````
