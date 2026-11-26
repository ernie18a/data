# SQB- India Momentum Dashboard - MVP

- url: https://www.tradingview.com/script/3I0WML84-SQB-India-Momentum-Dashboard-MVP/
- type: indicator
- pine_id: PUB;90d65bc0891c4e1f8c6ecec4c5ea9574
- version: 1.0

## Description

Its a dashboard with Mark Minervini style stage 2 filter and RSI value, RS strength etc,
it tell the latest pattern and help in taking the entry in the stock.

## Source Code

````pine
//@version=6
indicator("India Momentum Dashboard - MVP", shorttitle="SQB-Momentum Dashboard MVP", overlay=true)

//====================================================
// Inputs
//====================================================
groupMarket = "Market Filter"
groupTrend  = "Trend Template"
groupRS     = "Relative Strength"
groupRisk   = "Risk / Breakout"
groupView   = "Display"

useMarketFilter   = input.bool(true, "Use Nifty Market Filter", group=groupMarket)
niftySymbol       = input.string("NSE:NIFTY", "Nifty Symbol", group=groupMarket)
useWeeklyConfirm  = input.bool(true, "Use Weekly Confirmation", group=groupMarket)

sma20Len   = input.int(20, "SMA 20", minval=1, group=groupTrend)
sma50Len   = input.int(50, "SMA 50", minval=1, group=groupTrend)
sma150Len  = input.int(150, "SMA 150", minval=1, group=groupTrend)
sma200Len  = input.int(200, "SMA 200", minval=1, group=groupTrend)
sma200RiseBars = input.int(20, "SMA200 Rising Lookback", minval=5, maxval=50, group=groupTrend)

minAbove52wLowPct  = input.float(30.0, "Min % Above 52W Low", minval=1, step=1, group=groupTrend)
maxBelow52wHighPct = input.float(25.0, "Max % Below 52W High", minval=1, step=1, group=groupTrend)

rsLookback = input.int(63, "RS Lookback Bars", minval=20, maxval=252, group=groupRS)
minRsSpread = input.float(0.0, "Min RS Spread vs Nifty %", step=0.1, group=groupRS)

atrLen = input.int(14, "ATR Length", minval=1, group=groupRisk)
maxRiskPct = input.float(8.0, "Max Suggested Risk %", minval=1.0, step=0.5, group=groupRisk)

showMA = input.bool(true, "Show Moving Averages", group=groupView)
showBackground = input.bool(true, "Highlight Strong Candidates", group=groupView)
tablePosition = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupView)

//====================================================
// Core calculations
//====================================================
sma20  = ta.sma(close, sma20Len)
sma50  = ta.sma(close, sma50Len)
sma150 = ta.sma(close, sma150Len)
sma200 = ta.sma(close, sma200Len)

rsi14 = ta.rsi(close, 14)
atrVal = ta.atr(atrLen)
avgVol20 = ta.sma(volume, 20)
volRatio = avgVol20 > 0 ? volume / avgVol20 : na

hh20  = ta.highest(high[1], 20)
hh50  = ta.highest(high[1], 50)
hh252 = ta.highest(high, 252)
ll252 = ta.lowest(low, 252)

pctAbove52wLow = ll252 > 0 ? ((close / ll252) - 1.0) * 100.0 : na
pctBelow52wHigh = hh252 > 0 ? ((hh252 / close) - 1.0) * 100.0 : na

priceRet = close[rsLookback] > 0 ? ((close / close[rsLookback]) - 1.0) * 100.0 : na
sma200Rising = sma200 > sma200[sma200RiseBars]

//====================================================
// External / HTF requests
//====================================================
niftyClose = request.security(niftySymbol, "1D", close[1], lookahead=barmerge.lookahead_on)
niftySma50 = request.security(niftySymbol, "1D", ta.sma(close, 50)[1], lookahead=barmerge.lookahead_on)
niftySma200 = request.security(niftySymbol, "1D", ta.sma(close, 200)[1], lookahead=barmerge.lookahead_on)
niftyRet = request.security(niftySymbol, "1D", close[rsLookback] > 0 ? ((close / close[rsLookback]) - 1.0) * 100.0 : na, lookahead=barmerge.lookahead_on)

[weeklyClose, weeklySma10, weeklySma30] = request.security(syminfo.tickerid, "1W", [close[1], ta.sma(close, 10)[1], ta.sma(close, 30)[1]], lookahead=barmerge.lookahead_on)

//====================================================
// Filters
//====================================================
niftyBull = niftyClose > niftySma50 and niftySma50 > niftySma200
marketPass = useMarketFilter ? niftyBull : true

weeklyPass = useWeeklyConfirm ? (weeklyClose > weeklySma10 and weeklySma10 > weeklySma30) : true

cond1 = close > sma150 and close > sma200
cond2 = sma150 > sma200
cond3 = sma200Rising
cond4 = sma50 > sma150 and sma50 > sma200
cond5 = close > sma50
cond6 = pctAbove52wLow >= minAbove52wLowPct
cond7 = pctBelow52wHigh <= maxBelow52wHighPct

stage2Pass = cond1 and cond2 and cond3 and cond4 and cond5 and cond6 and cond7

rsSpread = na(priceRet) or na(niftyRet) ? na : priceRet - niftyRet
rsPass = not na(rsSpread) and rsSpread >= minRsSpread

rsiPass = rsi14 >= 55
strongRsi = rsi14 >= 65
volPass = not na(volRatio) and volRatio >= 1.2
strongVol = not na(volRatio) and volRatio >= 1.5

breakout20 = close > hh20
breakout50 = close > hh50
nearSma20 = math.abs(close - sma20) <= atrVal * 0.8
pullbackContinuation = close > sma20 and sma20 > sma50 and nearSma20 and rsi14 >= 55

suggestedStop = sma20
riskPct = suggestedStop > 0 ? ((close - suggestedStop) / close) * 100.0 : na
riskPass = not na(riskPct) and riskPct > 0 and riskPct <= maxRiskPct

avoidWeakTrend = close < sma50 or sma50 < sma150
avoidWeakRS = not na(rsSpread) and rsSpread < 0
avoidFarFromHigh = not na(pctBelow52wHigh) and pctBelow52wHigh > maxBelow52wHighPct
avoidReasonCount = (avoidWeakTrend ? 1 : 0) + (avoidWeakRS ? 1 : 0) + (avoidFarFromHigh ? 1 : 0)

//====================================================
// Score
//====================================================
score = 0.0
score += marketPass ? 15 : 0
score += weeklyPass ? 10 : 0
score += cond1 ? 10 : 0
score += cond2 ? 10 : 0
score += cond3 ? 10 : 0
score += cond4 ? 10 : 0
score += cond5 ? 10 : 0
score += cond6 ? 5 : 0
score += cond7 ? 5 : 0
score += rsPass ? 10 : 0
score += rsiPass ? 5 : 0
score += strongRsi ? 5 : 0
score += volPass ? 5 : 0
score += strongVol ? 5 : 0
score += breakout20 ? 5 : 0
score += breakout50 ? 5 : 0
score += pullbackContinuation ? 5 : 0
score += riskPass ? 5 : 0

finalScore = math.min(score, 100)

stage2Count =
     (cond1 ? 1 : 0) +
     (cond2 ? 1 : 0) +
     (cond3 ? 1 : 0) +
     (cond4 ? 1 : 0) +
     (cond5 ? 1 : 0) +
     (cond6 ? 1 : 0) +
     (cond7 ? 1 : 0)

verdict =
     finalScore >= 90 and stage2Pass and rsPass and (breakout20 or breakout50) ? "STRONG CANDIDATE" :
     finalScore >= 75 and stage2Pass ? "CANDIDATE" :
     finalScore >= 60 ? "WATCH" : "AVOID"

verdictColor =
     verdict == "STRONG CANDIDATE" ? color.new(color.lime, 0) :
     verdict == "CANDIDATE" ? color.new(color.green, 0) :
     verdict == "WATCH" ? color.new(color.yellow, 0) :
     color.new(color.red, 0)

patternStatus =
     breakout50 ? "50D Breakout" :
     breakout20 ? "20D Breakout" :
     pullbackContinuation ? "Pullback Continuation" :
     "No active setup"

momentumGrade =
     finalScore >= 90 ? "A+" :
     finalScore >= 80 ? "A" :
     finalScore >= 70 ? "B" :
     finalScore >= 60 ? "C" : "D"

//====================================================
// Visuals
//====================================================
plot(showMA ? sma20 : na, "SMA 20", color=color.new(color.teal, 0), linewidth=2)
plot(showMA ? sma50 : na, "SMA 50", color=color.new(color.orange, 0), linewidth=2)
plot(showMA ? sma150 : na, "SMA 150", color=color.new(color.blue, 0), linewidth=2)
plot(showMA ? sma200 : na, "SMA 200", color=color.new(color.gray, 10), linewidth=2)

bgcolor(showBackground and verdict == "STRONG CANDIDATE" ? color.new(color.green, 88) : na)

plotshape(verdict == "STRONG CANDIDATE", title="Strong Candidate", style=shape.triangleup, location=location.belowbar, size=size.small, color=color.new(color.lime, 0), text="STRONG")
plotshape(verdict == "CANDIDATE", title="Candidate", style=shape.circle, location=location.belowbar, size=size.tiny, color=color.new(color.yellow, 0), text="WATCH")

//====================================================
// Dashboard table
//====================================================
tblPos =
     tablePosition == "Top Left" ? position.top_left :
     tablePosition == "Bottom Right" ? position.bottom_right :
     tablePosition == "Bottom Left" ? position.bottom_left :
     position.top_right

var table dash = table.new(tblPos, 2, 16, border_width=1)

f_statusText(cond) =>
    cond ? "PASS" : "FAIL"

f_statusColor(cond) =>
    cond ? color.lime : color.red

if barstate.islast
    table.cell(dash, 0, 0, "Metric", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0, "Value", bgcolor=color.black, text_color=color.white)

    table.cell(dash, 0, 1, "Verdict")
    table.cell(dash, 1, 1, verdict, bgcolor=color.new(verdictColor, 75), text_color=color.black)

    table.cell(dash, 0, 2, "Score / Grade")
    table.cell(dash, 1, 2, str.tostring(math.round(finalScore)) + " / " + momentumGrade)

    table.cell(dash, 0, 3, "Pattern")
    table.cell(dash, 1, 3, patternStatus)

    table.cell(dash, 0, 4, "Market Filter")
    table.cell(dash, 1, 4, f_statusText(marketPass), text_color=f_statusColor(marketPass))

    table.cell(dash, 0, 5, "Weekly Confirm")
    table.cell(dash, 1, 5, f_statusText(weeklyPass), text_color=f_statusColor(weeklyPass))

    table.cell(dash, 0, 6, "Stage 2")
    table.cell(dash, 1, 6, f_statusText(stage2Pass) + " (" + str.tostring(stage2Count) + "/7)", text_color=f_statusColor(stage2Pass))

    table.cell(dash, 0, 7, "RS vs Nifty")
    table.cell(dash, 1, 7, na(rsSpread) ? "NA" : str.tostring(rsSpread, "#.0") + "%", text_color=rsPass ? color.lime : color.red)

    table.cell(dash, 0, 8, "RSI 14")
    table.cell(dash, 1, 8, str.tostring(rsi14, "#.0"), text_color=strongRsi ? color.lime : rsiPass ? color.yellow : color.red)

    table.cell(dash, 0, 9, "Volume Ratio")
    table.cell(dash, 1, 9, na(volRatio) ? "NA" : str.tostring(volRatio, "#.2") + "x", text_color=strongVol ? color.lime : volPass ? color.yellow : color.red)

    table.cell(dash, 0, 10, "52W Position")
    table.cell(dash, 1, 10, "Low +" + str.tostring(pctAbove52wLow, "#.0") + "% | High -" + str.tostring(pctBelow52wHigh, "#.0") + "%")

    table.cell(dash, 0, 11, "Breakout")
    table.cell(dash, 1, 11, breakout50 ? "50D" : breakout20 ? "20D" : pullbackContinuation ? "Pullback" : "None", text_color=(breakout20 or breakout50 or pullbackContinuation) ? color.lime : color.gray)

    table.cell(dash, 0, 12, "Risk to SMA20")
    table.cell(dash, 1, 12, na(riskPct) ? "NA" : str.tostring(riskPct, "#.1") + "%", text_color=riskPass ? color.lime : color.orange)

    table.cell(dash, 0, 13, "Avoid Flags")
    table.cell(dash, 1, 13, str.tostring(avoidReasonCount), text_color=avoidReasonCount == 0 ? color.lime : avoidReasonCount == 1 ? color.yellow : color.red)

    table.cell(dash, 0, 14, "Trend Stack")
    table.cell(dash, 1, 14, close > sma20 and sma20 > sma50 and sma50 > sma150 ? "Strong" : close > sma50 ? "Healthy" : "Weak", text_color=close > sma20 and sma20 > sma50 and sma50 > sma150 ? color.lime : close > sma50 ? color.yellow : color.red)

    table.cell(dash, 0, 15, "Action")
    table.cell(dash, 1, 15, verdict == "STRONG CANDIDATE" ? "Plan entry / alert" : verdict == "CANDIDATE" ? "Shortlist" : verdict == "WATCH" ? "Monitor only" : "Avoid now", text_color=verdictColor)

//====================================================
// Alerts
//====================================================
alertcondition(verdict == "CANDIDATE", title="Momentum Candidate", message="Momentum candidate on {{ticker}}")
alertcondition(verdict == "STRONG CANDIDATE", title="Strong Momentum Candidate", message="Strong momentum candidate on {{ticker}}")
alertcondition(stage2Pass, title="Stage 2 Pass", message="Stage 2 pass on {{ticker}}")
````
