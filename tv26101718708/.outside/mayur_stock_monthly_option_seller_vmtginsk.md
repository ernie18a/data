# Mayur - Stock Monthly Option Seller

- url: https://www.tradingview.com/script/VmtginSK-Mayur-Stock-Monthly-Option-Seller/
- type: indicator
- pine_id: PUB;fb9cebc1089142deb508441202d72a8a
- version: 1.0

## Description

A monthly option seller profits from time decay (Theta) by selling options that lose value as expiration approaches. The goal is usually to generate regular income rather than speculate on large price movements.

What They Typically Do
Sell Cash-Secured Puts (CSPs) to earn premium while being willing to buy stocks at lower prices.
Sell Covered Calls (CCs) on stocks they already own.
Sell Credit Spreads to define risk while collecting premium.
Focus on monthly expirations (typically 20–45 days to expiry).

## Source Code

````pine
//@version=6
// Stock Monthly Option Seller (conservative)
//
// For selling MONTHLY options on individual stocks with a modest, safety-first
// target (e.g. 2-4% premium). Run on a DAILY chart. It reuses the four-vote
// composite on Daily + Weekly + Monthly for the trend, but adds option-seller
// economics so you can see whether a SAFE strike actually pays your target:
//
//   * realized volatility (the stock's own, no VIX needed) -> expected monthly move
//   * a short strike placed a configurable number of expected-moves out
//   * a Black-Scholes estimate of the premium YIELD and the probability the
//     strike finishes in-the-money (your risk)
//   * a single verdict that only says SELL OK when the safe strike meets target
//
// uptrend -> sell PUT,  downtrend -> sell CALL,  range -> sell STRANGLE.
//
// IMPORTANT: Realized vol is a proxy for option IV; the yield is an ESTIMATE,
// confirm against your broker's real option chain. Selling options has undefined
// gap risk. Not a forecast. Not advice.

indicator("Stock Monthly Option Seller", overlay = true, max_labels_count = 200)

// ===================== Inputs =====================
emaFastLen = input.int(9, "EMA fast", minval = 1, group = "Indicators")
emaSlowLen = input.int(21, "EMA slow", minval = 1, group = "Indicators")
rsiLen     = input.int(14, "RSI length", minval = 1, group = "Indicators")
atrLen     = input.int(14, "ATR length", minval = 1, group = "Indicators")
stAtrLen   = input.int(10, "Supertrend ATR", minval = 1, group = "Indicators")
stFactor   = input.float(3.0, "Supertrend factor", minval = 0.1, step = 0.1, group = "Indicators")

wEma  = input.float(1.0, "Weight: EMA trend", minval = 0, group = "Weights")
wRsi  = input.float(1.0, "Weight: RSI momentum", minval = 0, group = "Weights")
wVwap = input.float(1.0, "Weight: VWAP bias", minval = 0, group = "Weights")
wSt   = input.float(1.0, "Weight: Supertrend", minval = 0, group = "Weights")

band = input.float(0.20, "Range band (|score| below = sell strangle)", minval = 0.0, maxval = 1.0, step = 0.01, group = "Signal")
tfW  = input.timeframe("W", "Horizon 1 (1 week)", group = "Horizons")
tfM  = input.timeframe("M", "Horizon 2 (1 month)", group = "Horizons")
nonRepaint = input.bool(true, "Non-repainting HTF (use last closed bar)", group = "Signal")

hvLen     = input.int(20, "Realized-vol lookback (days)", minval = 5, group = "Premium")
dteDays   = input.int(30, "Days to expiry", minval = 1, group = "Premium")
safetyEM  = input.float(1.5, "Short-strike distance (x expected move)", minval = 0.1, step = 0.1, group = "Premium", tooltip = "Higher = safer (further OTM) but less premium.")
targetMin = input.float(2.0, "Target yield min %", minval = 0.0, step = 0.5, group = "Premium")
targetMax = input.float(4.0, "Target yield max %", minval = 0.0, step = 0.5, group = "Premium")
maxProbITM = input.float(20.0, "Max acceptable risk (prob ITM %)", minval = 0.0, maxval = 100.0, step = 1.0, group = "Premium", tooltip = "Above this probability of the short strike finishing in-the-money, the trade is flagged RISKY.")

defLen     = input.int(20, "Trend-break swing lookback", minval = 2, group = "Management")
mgmtBuffer = input.float(0.4, "Exit when within (x expected move) of short strike", minval = 0.0, step = 0.1, group = "Management")

tableMode   = input.string("Compact", "Table", options = ["Compact", "Full", "Off"], group = "Display")
showStrikes = input.bool(true, "Plot strikes, exit line + range band", group = "Display")

// ===================== Composite score =====================
clampUnit(float x) =>
    math.max(-1.0, math.min(1.0, x))

compositeScore() =>
    emaFast = ta.ema(close, emaFastLen)
    emaSlow = ta.ema(close, emaSlowLen)
    rsiVal  = ta.rsi(close, rsiLen)
    atrVal  = ta.atr(atrLen)
    vwapVal = timeframe.isintraday ? ta.vwap(hlc3) : na
    [stLine, stDir] = ta.supertrend(stFactor, stAtrLen)
    atrSafe = atrVal == 0 ? na : atrVal
    vEma  = clampUnit((emaFast - emaSlow) / atrSafe)
    vRsi  = clampUnit((rsiVal - 50.0) / 20.0)
    vVwap = clampUnit((close - vwapVal) / atrSafe)
    vSt   = stDir < 0 ? 1.0 : -1.0
    totalW = wEma + wRsi + wVwap + wSt
    denom  = totalW == 0 ? 1.0 : totalW
    raw = (nz(vEma) * wEma + nz(vRsi) * wRsi + nz(vVwap) * wVwap + vSt * wSt) / denom
    clampUnit(raw)

htfScore(simple string tf) =>
    request.security(syminfo.tickerid, tf, compositeScore()[nonRepaint ? 1 : 0], lookahead = barmerge.lookahead_off)

scoreChart = compositeScore()
scoreW = htfScore(tfW)
scoreM = htfScore(tfM)
overall = (scoreChart + scoreW + scoreM) / 3.0
bullCount = (scoreChart > 0 ? 1 : 0) + (scoreW > 0 ? 1 : 0) + (scoreM > 0 ? 1 : 0)
bearCount = (scoreChart < 0 ? 1 : 0) + (scoreW < 0 ? 1 : 0) + (scoreM < 0 ? 1 : 0)
aligned = overall > 0 ? bullCount : bearCount

// ===================== Volatility, expected move, strikes =====================
// Realized (historical) volatility, annualized, as an IV proxy.
logRet = math.log(close / close[1])
hv = ta.stdev(logRet, hvLen) * math.sqrt(252.0)
T = dteDays / 365.0
emMonthly = na(hv) ? na : close * hv * math.sqrt(T)
emHigh = na(emMonthly) ? na : close + emMonthly
emLow  = na(emMonthly) ? na : close - emMonthly
putStrike  = na(emMonthly) ? na : close - safetyEM * emMonthly
callStrike = na(emMonthly) ? na : close + safetyEM * emMonthly

// ===================== Black-Scholes (r = 0) =====================
// Standard normal CDF (Zelen & Severo approximation).
ncdf(float x) =>
    t = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    d = 0.3989422804014327 * math.exp(-x * x / 2.0)
    p = d * t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    x >= 0 ? 1.0 - p : p

// Returns [premium, probability the option finishes in-the-money].
bsPut(float S, float K, float Tt, float vol) =>
    sigT = vol * math.sqrt(Tt)
    d1 = (math.log(S / K) + 0.5 * vol * vol * Tt) / sigT
    d2 = d1 - sigT
    [K * ncdf(-d2) - S * ncdf(-d1), ncdf(-d2)]

bsCall(float S, float K, float Tt, float vol) =>
    sigT = vol * math.sqrt(Tt)
    d1 = (math.log(S / K) + 0.5 * vol * vol * Tt) / sigT
    d2 = d1 - sigT
    [S * ncdf(d1) - K * ncdf(d2), ncdf(d2)]

validVol = not na(hv) and hv > 0 and T > 0
float putPrem = na
float putITM = na
float callPrem = na
float callITM = na
if validVol and not na(putStrike) and putStrike > 0
    [pp, pi] = bsPut(close, putStrike, T, hv)
    putPrem := pp
    putITM := pi
if validVol and not na(callStrike) and callStrike > 0
    [cp, ci] = bsCall(close, callStrike, T, hv)
    callPrem := cp
    callITM := ci

yieldPut  = na(putPrem) ? na : putPrem / close * 100.0
yieldCall = na(callPrem) ? na : callPrem / close * 100.0

// ===================== Recommendation & safety verdict =====================
recText = overall > band ? "SELL PUT ▲" : overall < -band ? "SELL CALL ▼" : "SELL STRANGLE ◆"
recColor = overall > band ? color.new(color.green, 0) : overall < -band ? color.new(color.red, 0) : color.new(color.orange, 0)
sellPut  = overall >= -band
sellCall = overall <= band

// The active side's economics drive the verdict (strangle uses the put leg).
activeYield = overall < -band ? yieldCall : yieldPut
activeITM   = (overall < -band ? callITM : putITM) * 100.0

// Verdict: only "SELL OK" when the safe strike clears the risk cap and pays target.
verdict = na(activeYield) ? "WAIT (warmup)" : aligned < 2 and math.abs(overall) > band ? "WEAK TREND" : activeITM > maxProbITM ? "RISKY (too close)" : activeYield < targetMin ? "THIN (low yield)" : "SELL OK"
verdictColor = verdict == "SELL OK" ? color.new(color.green, 0) : str.contains(verdict, "RISKY") ? color.new(color.red, 0) : color.new(color.orange, 0)

// ===================== Management: exit-near-strike + trend break =====================
managePut  = na(putStrike) ? na : putStrike + mgmtBuffer * emMonthly
manageCall = na(callStrike) ? na : callStrike - mgmtBuffer * emMonthly
approachPut  = sellPut and not na(managePut) and close <= managePut
approachCall = sellCall and not na(manageCall) and close >= manageCall
approaching  = approachPut or approachCall
defLow  = ta.lowest(low, defLen)[1]
defHigh = ta.highest(high, defLen)[1]
trendBreak = overall > band ? close < defLow : overall < -band ? close > defHigh : false

// ===================== Plots =====================
pHigh = plot(showStrikes ? emHigh : na, "Exp. high", color = color.new(color.gray, 70))
pLow  = plot(showStrikes ? emLow : na, "Exp. low", color = color.new(color.gray, 70))
fill(pHigh, pLow, color = color.new(color.blue, 92), title = "Expected monthly range")
plot(showStrikes and sellPut ? putStrike : na, "SELL PE", color = color.new(color.green, 0), style = plot.style_linebr, linewidth = 2)
plot(showStrikes and sellCall ? callStrike : na, "SELL CE", color = color.new(color.red, 0), style = plot.style_linebr, linewidth = 2)
plot(showStrikes and sellPut ? managePut : na, "Exit (PE)", color = color.new(color.orange, 0), style = plot.style_linebr, linewidth = 1)
plot(showStrikes and sellCall ? manageCall : na, "Exit (CE)", color = color.new(color.orange, 0), style = plot.style_linebr, linewidth = 1)

var label sellLbl = label.new(na, na, "", textcolor = color.white, style = label.style_label_left, size = size.small)
if barstate.islast and showStrikes
    sellTxt = overall > band ? "SELL PE @ " + str.tostring(putStrike, "#.##") : overall < -band ? "SELL CE @ " + str.tostring(callStrike, "#.##") : "STRANGLE  PE " + str.tostring(putStrike, "#.##") + " / CE " + str.tostring(callStrike, "#.##")
    sellLvl = overall > band ? putStrike : overall < -band ? callStrike : close
    label.set_xy(sellLbl, bar_index, sellLvl)
    label.set_text(sellLbl, sellTxt)
    label.set_color(sellLbl, recColor)

// ===================== Table =====================
yieldColor = na(activeYield) ? color.new(color.gray, 40) : (activeYield >= targetMin and activeYield <= targetMax) ? color.new(color.green, 25) : activeYield < targetMin ? color.new(color.gray, 30) : color.new(color.orange, 30)
riskColor  = na(activeITM) ? color.new(color.gray, 40) : activeITM > maxProbITM ? color.new(color.red, 0) : color.new(color.teal, 30)

dirText(float s) =>
    s > band ? "Up" : s < -band ? "Down" : "Flat"
dirColor(float s) =>
    s > band ? color.new(color.green, 20) : s < -band ? color.new(color.red, 20) : color.new(color.gray, 40)
trendRow(table tbl, int row, string lbl, float s) =>
    table.cell(tbl, 0, row, lbl, text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(tbl, 1, row, dirText(s), text_color = color.white, bgcolor = dirColor(s))
    table.cell(tbl, 2, row, str.tostring(math.round(math.abs(s) * 100)) + "%", text_color = color.white, bgcolor = color.new(color.black, 0))

tblRows = tableMode == "Full" ? 10 : tableMode == "Compact" ? 7 : 1
var table t = table.new(position.top_right, 3, tblRows, border_width = 1, frame_color = color.new(color.gray, 50))

if barstate.islast and tableMode != "Off"
    table.cell(t, 0, 0, "Horizon", text_color = color.white, bgcolor = color.new(color.blue, 0))
    table.cell(t, 1, 0, "Trend", text_color = color.white, bgcolor = color.new(color.blue, 0))
    table.cell(t, 2, 0, "Strength", text_color = color.white, bgcolor = color.new(color.blue, 0))
    rowIdx = 1
    if tableMode == "Full"
        trendRow(t, 1, "Daily", scoreChart)
        trendRow(t, 2, "Weekly", scoreW)
        trendRow(t, 3, "Monthly", scoreM)
        rowIdx := 4
    table.cell(t, 0, rowIdx, "TREND " + str.tostring(aligned) + "/3", text_color = color.white, bgcolor = color.new(color.purple, 0))
    table.cell(t, 1, rowIdx, recText, text_color = color.white, bgcolor = recColor)
    table.cell(t, 2, rowIdx, str.tostring(math.round(math.abs(overall) * 100)) + "%", text_color = color.white, bgcolor = color.new(color.purple, 0))
    rowIdx += 1
    table.cell(t, 0, rowIdx, "Verdict", text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, rowIdx, verdict, text_color = color.white, bgcolor = verdictColor)
    table.cell(t, 2, rowIdx, na(hv) ? "n/a" : "HV " + str.tostring(hv * 100.0, "#") + "%", text_color = color.white, bgcolor = color.new(color.black, 0))
    rowIdx += 1
    table.cell(t, 0, rowIdx, "Sell @", text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, rowIdx, na(putStrike) ? "—" : "P " + str.tostring(putStrike, "#.##"), text_color = color.white, bgcolor = color.new(color.green, 30))
    table.cell(t, 2, rowIdx, na(callStrike) ? "—" : "C " + str.tostring(callStrike, "#.##"), text_color = color.white, bgcolor = color.new(color.red, 30))
    rowIdx += 1
    table.cell(t, 0, rowIdx, "Est. yield", text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, rowIdx, na(activeYield) ? "—" : str.tostring(activeYield, "#.##") + "%", text_color = color.white, bgcolor = yieldColor)
    table.cell(t, 2, rowIdx, "tgt " + str.tostring(targetMin, "#") + "-" + str.tostring(targetMax, "#") + "%", text_color = color.white, bgcolor = color.new(color.black, 0))
    rowIdx += 1
    table.cell(t, 0, rowIdx, "Risk (ITM)", text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, rowIdx, na(activeITM) ? "—" : str.tostring(activeITM, "#.#") + "%", text_color = color.white, bgcolor = riskColor)
    table.cell(t, 2, rowIdx, "max " + str.tostring(maxProbITM, "#") + "%", text_color = color.white, bgcolor = color.new(color.black, 0))
    rowIdx += 1
    exitLevel = overall > band ? managePut : overall < -band ? manageCall : na
    exitFlag = approaching ? "EXIT" : trendBreak ? "BREAK" : "ok"
    exitColor = (approaching or trendBreak) ? color.new(color.red, 0) : color.new(color.black, 0)
    table.cell(t, 0, rowIdx, "Exit near", text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, rowIdx, na(exitLevel) ? "both legs" : str.tostring(exitLevel, "#.##"), text_color = color.white, bgcolor = color.new(color.orange, 40))
    table.cell(t, 2, rowIdx, exitFlag, text_color = color.white, bgcolor = exitColor)

// ===================== Alerts =====================
recChanged = recText != recText[1] and barstate.isconfirmed
if recChanged
    alert(recText + " | " + verdict + " | yield " + str.tostring(activeYield, "#.##") + "% risk " + str.tostring(activeITM, "#.#") + "%", alert.freq_once_per_bar_close)
if approaching and not approaching[1] and barstate.isconfirmed
    alert("Monthly seller: price APPROACHING short strike — exit / roll", alert.freq_once_per_bar_close)
if trendBreak and not trendBreak[1] and barstate.isconfirmed
    alert("Monthly seller: TREND BREAK — exit / roll", alert.freq_once_per_bar_close)

alertcondition(recChanged, title = "New sell recommendation", message = "Stock monthly seller: trend regime changed")
alertcondition(approaching and not approaching[1], title = "Approaching short strike", message = "Stock monthly seller: price near short strike — exit/roll")
alertcondition(trendBreak and not trendBreak[1], title = "Trend break", message = "Stock monthly seller: trend read failed — exit/roll")
````
