<!-- tradingview-pine-id: PUB;f241544d8069402794c777de0307223d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Taught to Trade - Backtest Integrity Scanner

Source: https://www.tradingview.com/script/8ffRco5z-Taught-to-Trade-Backtest-Integrity-Scanner/

## Description

🔵 OVERVIEW

This does not read your strategy. It measures the chart your strategy is being tested on, and reports which standard backtest assumptions are unsafe here.

Most backtest failures are not logic errors. They are assumptions about the instrument: that costs are negligible, that the sample is large enough, that the data is clean, that the test window contains more than one market regime. Those are properties of the chart rather than of your code, and they can be measured directly.

The table reports ten of them and flags the ones that need attention.

🔵 HOW TO READ THE TABLE

Header shows bars available and years of history on this chart and timeframe.

Approx trades available. Bars divided by your assumed holding period. Flags CHECK below the minimum you set. Expectancy measured on a handful of trades is not measurable.

Median bar range. The middle bar's high to low as a percentage of price. This is what one bar is worth here.

Round-trip cost. Your commission plus slippage, both sides.

Cost / median bar. The number that matters most. It is the fraction of a typical bar's entire range consumed by entering and exiting once. On a 15-minute crypto chart with ordinary retail costs this routinely exceeds 50 percent. A strategy whose average win is smaller than a median bar cannot survive that, and no amount of parameter tuning changes it.

One-bar head start. The average absolute distance from one bar's close to the next bar's open, as a percentage. This is what a same-bar lookahead error is worth on this instrument.

Head start / cost. The head start expressed in round trips. Above 1.0x, a one-bar lookahead bug hands a backtest more than a full round trip of free edge per trade, which is enough to invent an edge out of nothing.

Zero-volume bars. Bars where nothing traded. A backtest will happily fill you on them.

Gaps above the ATR multiple. Bars that opened far from the previous close. Stops and limits behave very differently across these than a backtest assumes.

Volatility regime now. Current ATR percentile band, plus the share of the sample sitting in the high and low thirds. Flags CHECK when one regime dominates, because an edge measured inside a single regime is a regime bet.

🔵 SETTINGS

Cost assumptions: commission and slippage per side. Use your broker's real numbers. Zero slippage is the most common dishonest backtest setting.

Sample: window length, assumed bars held per trade, and the minimum trade count you would accept.

Data checks: ATR length, the gap threshold, and the cost share at which the warning fires.

Table: position and text size.

🔵 ALERTS

Four alert conditions are provided and none fire on their own. You configure them yourself in the alerts dialog. This script does not send buy or sell signals and never will.

🔵 WHERE IT FAILS

This tool is about limits, so it should be honest about its own.

It cannot see your strategy. It has no access to your entry logic, your fills, or your equity curve. It measures the environment, which means a table full of OK does not mean your backtest is honest. It means these particular environmental assumptions are not the thing breaking it.

The cost inputs are yours. Enter a fantasy number and you get a fantasy verdict. The script cannot verify what you actually pay.

Median bar range is a poor summary of a fat-tailed distribution. It deliberately ignores the tails, and the tails are where a lot of real outcomes live.

The one-bar head start figure is an average across the sample. On the individual bars that matter most, the violent ones, it is far larger than the average suggests.

The regime split uses ATR terciles computed inside the same window it is judging. On a short window that is close to circular, and it will call a quiet sample balanced when the market simply has not moved yet.

The trade count is an estimate from a holding period you typed in, not from a real trade list.

Data checks are limited to what TradingView provides for the symbol. Survivorship bias in your symbol universe is invisible here, and it is one of the largest backtest errors there is.

Open source, so you can read every calculation rather than take any of this on trust.

Educational tool only, not investment advice. It does not predict anything and does not generate signals. Trading involves substantial risk of loss.

---

## Source Code

````pine
//@version=6
// Taught to Trade - Backtest Integrity Scanner
// Measures the properties of THIS chart that quietly break backtests.
// It does not read your strategy. It measures the instrument and timeframe
// your strategy is being tested on, and tells you which assumptions are unsafe here.
// No buy/sell signals. Alerts are yours to configure.
indicator("Taught to Trade - Backtest Integrity Scanner", shorttitle = "TT BIS", overlay = true, max_bars_back = 1000)

grpC = "Cost assumptions"
commPct = input.float(0.04, "Commission per side (%)", minval = 0.0, step = 0.01, group = grpC, tooltip = "What one side of a round trip actually costs you, as a percentage of notional. Use your broker real number, not zero.")
slipPct = input.float(0.02, "Slippage per side (%)", minval = 0.0, step = 0.01, group = grpC, tooltip = "Expected slippage per side. Zero is the single most common dishonest backtest setting.")

grpS = "Sample"
lookback = input.int(500, "Sample window (bars)", minval = 50, maxval = 1000, group = grpS)
holdBars = input.int(20, "Assumed bars held per trade", minval = 1, group = grpS, tooltip = "Used only to estimate how many trades your history could produce. Change it to match your strategy.")
minTrades = input.int(30, "Minimum trades you would accept", minval = 5, group = grpS)

grpD = "Data checks"
atrLen  = input.int(14, "ATR length", minval = 2, group = grpD)
gapMult = input.float(2.0, "Flag gaps larger than (x ATR)", minval = 0.5, step = 0.5, group = grpD)
costWarn = input.float(25.0, "Warn when cost exceeds this % of a median bar", minval = 1.0, step = 5.0, group = grpD)
showGaps = input.bool(true, "Mark flagged gap bars on the chart", group = grpD)

grpT = "Table"
posIn  = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = grpT)
szIn   = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpT)

atr = ta.atr(atrLen)

barsAvail = bar_index + 1
var int tFirst = na
if na(tFirst)
    tFirst := time
yearsData = (time - tFirst) / 31557600000.0
approxTrades = math.floor(barsAvail / math.max(holdBars, 1))

barRangePct = close > 0 ? (high - low) / close * 100.0 : na
medRangePct = ta.percentile_linear_interpolation(barRangePct, lookback, 50)
roundTripPct = (commPct + slipPct) * 2.0
costShare = medRangePct > 0 ? roundTripPct / medRangePct * 100.0 : na

gapPct = close[1] > 0 ? math.abs(open - close[1]) / close[1] * 100.0 : na
avgGapPct = ta.sma(gapPct, lookback)
headVsCost = roundTripPct > 0 ? avgGapPct / roundTripPct : na

zeroVolBars = math.sum(nz(volume, 0) == 0 ? 1 : 0, lookback)
bigGapBars  = math.sum(math.abs(open - close[1]) > atr * gapMult ? 1 : 0, lookback)

atrPct = close > 0 ? atr / close * 100.0 : na
p33 = ta.percentile_linear_interpolation(atrPct, lookback, 33)
p67 = ta.percentile_linear_interpolation(atrPct, lookback, 67)
regimeNow = na(atrPct) ? "n/a" : atrPct <= p33 ? "Low" : atrPct <= p67 ? "Mid" : "High"
shareHigh = math.sum(atrPct > p67 ? 1 : 0, lookback) / lookback * 100.0
shareLow  = math.sum(atrPct <= p33 ? 1 : 0, lookback) / lookback * 100.0

okCol   = color.new(#2E7D32, 0)
warnCol = color.new(#B26A00, 0)
badCol  = color.new(#B3261E, 0)
bgCol   = color.new(#0E1526, 10)
txtCol  = color.new(#E6EAF2, 0)
hdrCol  = color.new(#2F6FED, 0)

f_flagCol(bool bad, bool warn) => bad ? badCol : warn ? warnCol : okCol
f_flagTxt(bool bad, bool warn) => bad ? "CHECK" : warn ? "WATCH" : "OK"

tradesBad  = approxTrades < minTrades
costBad    = not na(costShare) and costShare > costWarn
costWarnF  = not na(costShare) and costShare > costWarn / 2.0
headBad    = not na(headVsCost) and headVsCost > 1.0
volBad     = zeroVolBars > 0
gapWarnF   = bigGapBars > 0
regimeBad  = shareHigh > 60.0 or shareLow > 60.0

tblPos = posIn == "Top left" ? position.top_left : posIn == "Bottom right" ? position.bottom_right : posIn == "Bottom left" ? position.bottom_left : position.top_right
tblSz  = szIn == "Tiny" ? size.tiny : szIn == "Normal" ? size.normal : size.small

var table t = table.new(tblPos, 3, 10, border_width = 1, border_color = color.new(#2F6FED, 70))

f_row(int r, string label, string val, color c, string flag) =>
    table.cell(t, 0, r, label, text_color = txtCol, text_size = tblSz, text_halign = text.align_left, bgcolor = bgCol)
    table.cell(t, 1, r, val, text_color = txtCol, text_size = tblSz, text_halign = text.align_right, bgcolor = bgCol)
    table.cell(t, 2, r, flag, text_color = color.white, text_size = tblSz, text_halign = text.align_center, bgcolor = c)

if barstate.islast
    table.cell(t, 0, 0, "BACKTEST INTEGRITY", text_color = color.white, text_size = tblSz, text_halign = text.align_left, bgcolor = hdrCol)
    table.cell(t, 1, 0, str.tostring(barsAvail) + " bars", text_color = color.white, text_size = tblSz, text_halign = text.align_right, bgcolor = hdrCol)
    table.cell(t, 2, 0, str.tostring(yearsData, "#.0") + "y", text_color = color.white, text_size = tblSz, text_halign = text.align_center, bgcolor = hdrCol)
    f_row(1, "Approx trades available", str.tostring(approxTrades), f_flagCol(tradesBad, approxTrades < minTrades * 2), f_flagTxt(tradesBad, approxTrades < minTrades * 2))
    f_row(2, "Median bar range", str.tostring(medRangePct, "#.###") + "%", bgCol, "")
    f_row(3, "Round-trip cost", str.tostring(roundTripPct, "#.###") + "%", bgCol, "")
    f_row(4, "Cost / median bar", na(costShare) ? "n/a" : str.tostring(costShare, "#.#") + "%", f_flagCol(costBad, costWarnF), f_flagTxt(costBad, costWarnF))
    f_row(5, "One-bar head start", na(avgGapPct) ? "n/a" : str.tostring(avgGapPct, "#.###") + "%", bgCol, "")
    f_row(6, "Head start / cost", na(headVsCost) ? "n/a" : str.tostring(headVsCost, "#.##") + "x", f_flagCol(headBad, false), f_flagTxt(headBad, false))
    f_row(7, "Zero-volume bars", str.tostring(zeroVolBars), f_flagCol(volBad, false), f_flagTxt(volBad, false))
    f_row(8, "Gaps > " + str.tostring(gapMult, "#.#") + "x ATR", str.tostring(bigGapBars), f_flagCol(false, gapWarnF), f_flagTxt(false, gapWarnF))
    f_row(9, "Volatility regime now", regimeNow + "  (hi " + str.tostring(shareHigh, "#") + "% / lo " + str.tostring(shareLow, "#") + "%)", f_flagCol(regimeBad, false), f_flagTxt(regimeBad, false))

plotshape(showGaps and math.abs(open - close[1]) > atr * gapMult, title = "Gap bar", style = shape.triangleup, location = location.belowbar, size = size.tiny, color = color.new(#B26A00, 20))

alertcondition(costBad, title = "Cost exceeds threshold share of a median bar", message = "Backtest Integrity Scanner: round-trip cost now exceeds the configured share of a median bar range on this chart.")
alertcondition(headBad, title = "One-bar head start worth more than costs", message = "Backtest Integrity Scanner: the average one-bar gap on this chart is larger than a full round-trip cost.")
alertcondition(volBad, title = "Zero-volume bars present in sample", message = "Backtest Integrity Scanner: zero-volume bars are present in the sample window on this chart.")
alertcondition(regimeBad, title = "Sample dominated by one volatility regime", message = "Backtest Integrity Scanner: the sample window is dominated by a single volatility regime on this chart.")
````
