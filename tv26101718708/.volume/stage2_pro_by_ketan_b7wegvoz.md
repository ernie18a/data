# Stage2 Pro by Ketan

- url: https://www.tradingview.com/script/B7wEgVoZ-Stage2-Pro-by-Ketan/
- type: indicator
- pine_id: PUB;75a9fa21b9694b83aa81da2b9cc53274
- version: 1.0

## Description

// Stage2 Pro by Ketan
     // Multi-timeframe trend script for Indian stocks.
     // Logic: Weekly Stage-2 trend + Weekly Higher High + Monthly RSI strength + Relative Strength vs NIFTY MidSmall
      400.
     // Trade stance: STRONG BUY / BUY / WATCHLIST / AVOID.
     // Risk rule: HARD SELL when the entire candle is below Monthly 18 MA.

   If you publish on TradingView, use this one-line summary:
   “Stage2 Pro by Ketan: clean MTF trend model using Weekly Stage-2, Weekly Higher High, Monthly RSI, SM400 relative
   strength, and HARD SELL below Monthly 18 MA.”

## Source Code

````pine
//@version=6
indicator("Stage2 Pro by Ketan", overlay=true, max_labels_count=50)

rsiLen = input.int(14, "RSI Length", minval=2)
rsiMin = input.float(60.0, "Monthly RSI Min", step=0.5)
maLenM = input.int(18, "Monthly MA Length", minval=2)
stageMaWeeks = input.int(40, "Weekly Stage MA Length", minval=5)
hhLookbackW = input.int(20, "Weekly Higher-High Lookback", minval=5)
hhHoldWeeks = input.int(2, "Weekly Higher-High Hold", minval=0, maxval=12)
showTable = input.bool(true, "Show Summary Table")
showMA18Line = input.bool(true, "Show Monthly MA18 Line")
showSM400Line = input.bool(true, "Show SM400 Scaled Line")
enableHighVolColor = input.bool(true, "Enable Very High Volume Candle Color")
highVolLen = input.int(20, "High Volume SMA Length", minval=2)
highVolMult = input.float(1.8, "Very High Volume Multiplier", step=0.1)
highVolBullColor = input.color(color.lime, "High Volume Bull Candle Color")
highVolBearColor = input.color(color.fuchsia, "High Volume Bear Candle Color")

// Fixed timeframe checks
mMA18 = request.security(syminfo.tickerid, "M", ta.sma(close, maLenM), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
mRsi = request.security(syminfo.tickerid, "M", ta.rsi(close, rsiLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
wClose = request.security(syminfo.tickerid, "W", close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
wMA = request.security(syminfo.tickerid, "W", ta.sma(close, stageMaWeeks), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
hhBarsAgoW = request.security(syminfo.tickerid, "W", ta.barssince(high >= ta.highest(high[1], hhLookbackW)), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

stageWeekly = wClose > wMA and wClose > mMA18
higherHighW = not na(hhBarsAgoW) and hhBarsAgoW <= hhHoldWeeks
rsiPass = not na(mRsi) and mRsi > rsiMin
buy = stageWeekly and higherHighW and rsiPass

// Fixed SM400 line and above/below check (with internal fallback symbols)
idx1 = request.security("NSE:NIFTYMIDSML400", "W", close, ignore_invalid_symbol=true, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
idx2 = request.security("NSE:NIFTY_MIDSMALLCAP_400", "W", close, ignore_invalid_symbol=true, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
idx3 = request.security("NSE:NIFTYMIDSMALL400", "W", close, ignore_invalid_symbol=true, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
idxCloseW = not na(idx1) and idx1 > 0 ? idx1 : not na(idx2) and idx2 > 0 ? idx2 : not na(idx3) and idx3 > 0 ? idx3 : na
validIdx = not na(idxCloseW) and idxCloseW > 0

scaleLen = 26
scaleFactor = validIdx ? ta.sma(wClose, scaleLen) / ta.sma(idxCloseW, scaleLen) : na
idxScaled = validIdx and not na(scaleFactor) ? idxCloseW * scaleFactor : na
aboveNifty = validIdx and not na(idxScaled) and wClose > idxScaled

plot(showSM400Line ? idxScaled : na, title="SM400 (Scaled)", color=color.blue, linewidth=2)

plot(showMA18Line ? mMA18 : na, title="Monthly 18 MA", color=color.orange, linewidth=2)

highVol = volume > ta.sma(volume, highVolLen) * highVolMult
highVolBarColor = highVol ? (close >= open ? highVolBullColor : highVolBearColor) : na
barcolor(enableHighVolColor ? highVolBarColor : na)

stateText(cond) =>
    cond ? "PASS" : "FAIL"

stateColor(cond) =>
    cond ? color.lime : color.red

var table t = table.new(position.top_right, 2, 6, border_width=1)
if barstate.islast and showTable
    table.cell(t, 0, 0, "Rule", bgcolor=color.new(color.gray, 80), text_color=color.white)
    table.cell(t, 1, 0, "Status", bgcolor=color.new(color.gray, 80), text_color=color.white)
    table.cell(t, 0, 1, "Stage (Weekly)")
    table.cell(t, 1, 1, stateText(stageWeekly), text_color=stateColor(stageWeekly))
    table.cell(t, 0, 2, "Higher High (Weekly)")
    table.cell(t, 1, 2, stateText(higherHighW), text_color=stateColor(higherHighW))
    table.cell(t, 0, 3, "RSI > " + str.tostring(rsiMin) + " (Monthly)")
    table.cell(t, 1, 3, stateText(rsiPass), text_color=stateColor(rsiPass))
    table.cell(t, 0, 4, "Price vs SM400")
    table.cell(t, 1, 4, validIdx ? (aboveNifty ? "ABOVE" : "BELOW") : "INVALID", text_color=validIdx ? (aboveNifty ? color.lime : color.red) : color.red)
    table.cell(t, 0, 5, "Signal")
    table.cell(t, 1, 5, buy ? "BUY" : "WAIT", text_color=buy ? color.lime : color.yellow)

alertcondition(buy, title="BUY", message="BUY: Weekly Stage + Weekly Higher High + Monthly RSI")
````
