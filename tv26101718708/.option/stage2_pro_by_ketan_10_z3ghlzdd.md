# Stage2 Pro by Ketan 1.0

- url: https://www.tradingview.com/script/Z3GHlZdd-Stage2-Pro-by-Ketan-1-0/
- type: indicator
- pine_id: PUB;9a6df7d72b4a4d4aa18b50d9fe1aaf36
- version: 1.0

## Description

Stage2 Pro by Ketan is a clean multi-timeframe trend script for Indian stocks.
   It evaluates 5 core factors: 
Stage-2 trend (Weekly), 
Higher High (Daily), 
Price above Daily EMA50, 
Monthly RSI  strength, and 
Price vs NIFTY MidSmall 400 (Weekly).
   
The table outputs each factor as BULLISH/WEAK for fast decision-making, while optional candle coloring highlights
   exceptional volume events (highest-ever volume in blue, recent high-volume candles in custom bull/bear colors).
   Best used for trend-following and watchlist filtering, not as standalone financial advice.

## Source Code

````pine
//@version=6
indicator("Stage2 Pro by Ketan 1.0", overlay=true, max_labels_count=50)

rsiLen = input.int(14, "RSI Length", minval=2)
rsiMin = input.float(60.0, "Monthly RSI Min", step=0.5)
maLenM = input.int(18, "Monthly MA Length", minval=2)
stageMaWeeks = input.int(40, "Weekly Stage MA Length", minval=5)
hhLookbackD = input.int(55, "Daily Higher-High Lookback", minval=10)
hhHoldDays = input.int(5, "Daily Higher-High Hold", minval=0, maxval=30)
emaLenD = input.int(50, "Daily EMA Length (Structure)", minval=5)
showTable = input.bool(true, "Show Summary Table")
showMA18Line = input.bool(true, "Show Monthly MA18 Line")
showSM400Line = input.bool(true, "Show SM400 Scaled Line")
enableHighVolColor = input.bool(true, "Enable Very High Volume Candle Color")
highVolLen = input.int(20, "High Volume SMA Length", minval=2)
highVolMult = input.float(1.3, "Very High Volume Multiplier", step=0.1)
volHighLookbackDays = input.int(60, "Recent High Volume Lookback (Days)", minval=20)
highestEverVolColor = input.color(color.blue, "Highest Ever Volume Candle Color")
highVolBullColor = input.color(color.lime, "High Volume Bull Candle Color")
highVolBearColor = input.color(color.fuchsia, "High Volume Bear Candle Color")

// Fixed timeframe checks
mClose = request.security(syminfo.tickerid, "M", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mMA18 = request.security(syminfo.tickerid, "M", ta.sma(close, maLenM), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mRsi = request.security(syminfo.tickerid, "M", ta.rsi(close, rsiLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
wClose = request.security(syminfo.tickerid, "W", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
wMA = request.security(syminfo.tickerid, "W", ta.sma(close, stageMaWeeks), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
hhBarsAgoD = request.security(syminfo.tickerid, "D", ta.barssince(high >= ta.highest(high[1], hhLookbackD)), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
dClose = request.security(syminfo.tickerid, "D", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
dOpen = request.security(syminfo.tickerid, "D", open, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
dEma50 = request.security(syminfo.tickerid, "D", ta.ema(close, emaLenD), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
dVol = request.security(syminfo.tickerid, "D", volume, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
dVolSma = request.security(syminfo.tickerid, "D", ta.sma(volume, highVolLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
dVolHighestEver = request.security(syminfo.tickerid, "D", ta.highest(volume, 5000), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
dVolHighestRecent = request.security(syminfo.tickerid, "D", ta.highest(volume, volHighLookbackDays), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

stageWeekly = wClose > wMA and wClose > mMA18
higherHighD = not na(hhBarsAgoD) and hhBarsAgoD <= hhHoldDays
aboveEmaD = dClose > dEma50
structurePass = higherHighD and aboveEmaD
rsiPass = not na(mRsi) and mRsi > rsiMin
monthlyAboveMA18 = mClose > mMA18
trendUp = stageWeekly and monthlyAboveMA18
buy = trendUp and rsiPass

// Fixed SM400 line and above/below check (with internal fallback symbols)
idx1 = request.security("NSE:NIFTYMIDSML400", "W", close, ignore_invalid_symbol=true, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
idx2 = request.security("NSE:NIFTY_MIDSMALLCAP_400", "W", close, ignore_invalid_symbol=true, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
idx3 = request.security("NSE:NIFTYMIDSMALL400", "W", close, ignore_invalid_symbol=true, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
idxCloseW = not na(idx1) and idx1 > 0 ? idx1 : not na(idx2) and idx2 > 0 ? idx2 : not na(idx3) and idx3 > 0 ? idx3 : na
validIdx = not na(idxCloseW) and idxCloseW > 0

scaleLen = 26
scaleFactor = validIdx ? ta.sma(wClose, scaleLen) / ta.sma(idxCloseW, scaleLen) : na
idxScaled = validIdx and not na(scaleFactor) ? idxCloseW * scaleFactor : na
aboveSM400 = validIdx and not na(idxScaled) and wClose > idxScaled

plot(showSM400Line ? idxScaled : na, title="SM400 (Scaled)", color=color.blue, linewidth=2)

plot(showMA18Line ? mMA18 : na, title="Monthly 18 MA", color=color.orange, linewidth=2)

highVol = not na(dVolSma) and dVol > dVolSma * highVolMult
highestEverVol = not na(dVolHighestEver) and dVol >= dVolHighestEver
highestRecentVol = not na(dVolHighestRecent) and dVol >= dVolHighestRecent
highVolBarColor = highestEverVol ? highestEverVolColor : (highestRecentVol or highVol) ? (dClose >= dOpen ? highVolBullColor : highVolBearColor) : na
barcolor(enableHighVolColor ? highVolBarColor : na)

stateText(cond) =>
    cond ? "BULLISH" : "WEAK"

stateColor(cond) =>
    cond ? color.lime : color.red

var table t = table.new(position.top_right, 2, 6, border_width=1)
if barstate.islast and showTable
    rsBullish = validIdx and aboveSM400
    rsText = validIdx ? stateText(rsBullish) : "WEAK"
    rsColor = validIdx ? stateColor(rsBullish) : color.red

    table.cell(t, 0, 0, "Market Factor", bgcolor=color.new(color.gray, 80), text_color=color.white)
    table.cell(t, 1, 0, "Reading", bgcolor=color.new(color.gray, 80), text_color=color.white)
    table.cell(t, 0, 1, "Trend Regime (Stage-2 W)")
    table.cell(t, 1, 1, stateText(stageWeekly), text_color=stateColor(stageWeekly))
    table.cell(t, 0, 2, "Higher High (Daily)")
    table.cell(t, 1, 2, stateText(higherHighD), text_color=stateColor(higherHighD))
    table.cell(t, 0, 3, "Above EMA50 (Daily)")
    table.cell(t, 1, 3, stateText(aboveEmaD), text_color=stateColor(aboveEmaD))
    table.cell(t, 0, 4, "Momentum RSI > " + str.tostring(rsiMin) + " (M)")
    table.cell(t, 1, 4, stateText(rsiPass), text_color=stateColor(rsiPass))
    table.cell(t, 0, 5, "Price vs SM400 (W)")
    table.cell(t, 1, 5, rsText, text_color=rsColor)

alertcondition(buy, title="BUY", message="BUY: Uptrend above Monthly 18 MA + Monthly RSI")
````
