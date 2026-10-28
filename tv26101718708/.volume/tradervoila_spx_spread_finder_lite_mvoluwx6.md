# TraderVoila - SPX Spread Finder LITE

- url: https://www.tradingview.com/script/MvOluWX6-TraderVoila-SPX-Spread-Finder-LITE/
- type: indicator
- pine_id: PUB;fe495d8693034a4b8d5b4bf32a80de53
- version: 1.0

## Description

[b]TraderVoila — SPX Spread Finder LITE[/b]
Finds intraday credit spread setups on SPX using support/resistance zones, VWAP, and trend filters — with suggested strikes for each signal.
[b]What it does[/b]
Credit spread sellers want to sell premium behind a level the market is defending. This indicator identifies those moments on 1–5 minute charts:

[b]PCS[/b] — price is holding a support zone (pivot level or Prior Day Low) with bullish conditions aligned — a put credit spread below the level puts that support between you and the market.
[b]CCS[/b] — price is rejecting a resistance zone (pivot level or Prior Day High) with bearish conditions aligned — a call credit spread above the level does the same on the other side.

A [b]Trade Ticket[/b] panel displays the suggested short and long strikes based on your OTM cushion and spread width, rounded to the strike increment (SPX = 5).
[b]How it works[/b]
Every signal requires full alignment:
[list]
[*]Price inside a pivot-based S/R zone, or at the Prior Day High/Low — classic intraday reaction levels
[*]VWAP alignment in the trade direction (optional slope confirmation available)
[*]Daily moving-average regime agrees (fast MA vs mid MA)
[*]RSI is not extended against the trade
[*]Inside regular trading hours, past the opening minutes, and before your entry cutoff (default 2:00 PM ET)
[/list]

A signal cooldown prevents clustering. All parameters are adjustable: zone thickness, pivot length, RSI thresholds, MA lengths, cushion, spread width, and session timing.

[b]How to use it[/b]
[list]
[*]Apply to a 1m–5m chart of SPX, SPY, or ES
[*]When a PCS or CCS label prints, check the Trade Ticket for the suggested strikes
[*]Verify the actual premium, spread width, and liquidity on your broker — the ticket suggests structure, your broker shows the real prices
[*]Set alerts on both signal conditions to monitor hands-free
[/list]

[b]Honest limitations[/b]
TradingView cannot see options prices, IV, or Greeks - strike suggestions are derived from the underlying's price and your cushion settings, not from live option chains. Always confirm the contract on your broker. Signals identify favorable conditions; they are not trade recommendations or financial advice. Credit spreads carry defined but significant risk — size positions accordingly.  Built by TraderVoila for options sellers.

## Source Code

````pine
//@version=6
// ============================================================
// TraderVoila — SPX Spread Finder LITE (1-5m)
// ============================================================
// A free tool for intraday credit spread traders: finds
// support/resistance zones on SPX and signals when conditions
// favor selling a Put Credit Spread (PCS, bullish) or a Call
// Credit Spread (CCS, bearish), with suggested strikes.
//
// HOW TO USE:
//   1. Apply to a 5m-15m chart of SPX / SPY / ES
//   2. PCS label = price holding support in bullish conditions
//      — consider a put credit spread below the level
//      (I always go at least 40-50 points under on SPX
//      depending on time-of-day, conditions, etc.)
//   3. CCS label = price rejecting resistance in bearish
//      conditions — consider a call credit spread above
//   4. The Trade Ticket shows suggested short/long strikes
//      based on your cushion and spread width settings
//
// SIGNAL LOGIC (all must align):
//   • Price in a pivot-based S/R zone OR at the Prior Day
//     High/Low (classic intraday reaction levels)
//   • VWAP alignment + VWAP slope in trade direction
//   • Daily moving-average regime agrees with direction
//   • RSI not extended against the trade
//   • Inside regular hours, past the opening chaos,
//     before your entry cutoff
//
// Settings were designed for SPX, but you can edit to suit your
// favorite index or ticker.  TraderVoila is happy to offer 
// excellent free to help make you a more effective trader.
// ============================================================

indicator("TraderVoila — SPX Spread Finder LITE", overlay=true, max_labels_count=200)

//──────────────────────────────────────────────
// Session / Timing
//──────────────────────────────────────────────
grpSess  = "Session / Timing"
useRTH   = input.bool(true, "Use RTH Only (US Equities)", group=grpSess)
rthSess  = input.session("0930-1600", "RTH Session (exchange time)", group=grpSess)
skipMins = input.int(15, "Skip first X minutes of RTH", minval=0, group=grpSess)
enableEntryCutoff = input.bool(true, "Block new signals after cutoff", group=grpSess)
cutoffHourET   = input.int(14, "No new signals after hour (ET)", minval=0, maxval=23, group=grpSess)
cutoffMinuteET = input.int(0,  "No new signals after minute (ET)", minval=0, maxval=59, group=grpSess)

inSess  = not useRTH ? true : not na(time(timeframe.period, rthSess))
newSess = inSess and not inSess[1]

var int rthStartTs = na
if newSess
    rthStartTs := time

minsSinceStart = (inSess and not na(rthStartTs)) ? int(math.floor((time - rthStartTs) / 60000.0)) : na
okAfterOpen    = not useRTH ? true : (inSess and not na(minsSinceStart) and minsSinceStart >= skipMins)

cutoffTs     = useRTH ? timestamp("America/New_York", year, month, dayofmonth, cutoffHourET, cutoffMinuteET) : na
beforeCutoff = not useRTH ? true : (not enableEntryCutoff or time < cutoffTs)

//──────────────────────────────────────────────
// Support / Resistance — Pivot Zones
//──────────────────────────────────────────────
grpSR = "Support / Resistance Zones"
pivotLen = input.int(8,    "Pivot length (bars)", minval=2, group=grpSR)
zonePts  = input.float(15.0, "Zone thickness (points)", minval=0.25, step=0.25, group=grpSR)
minLevelSep = input.float(5.0, "Ignore new pivots within X pts of current level", minval=0.0, step=0.25, group=grpSR)

pL = ta.pivotlow(low,   pivotLen, pivotLen)
pH = ta.pivothigh(high, pivotLen, pivotLen)

var float lastSupport = na
var float lastResist  = na

if not na(pL) and (na(lastSupport) or math.abs(pL - lastSupport) >= minLevelSep)
    lastSupport := pL
if not na(pH) and (na(lastResist) or math.abs(pH - lastResist) >= minLevelSep)
    lastResist := pH

inSupportZone = not na(lastSupport) and math.abs(close - lastSupport) <= zonePts and close > lastSupport
inResistZone  = not na(lastResist)  and math.abs(close - lastResist)  <= zonePts and close < lastResist

plot(lastSupport, "Support",    color=color.new(color.lime, 0), linewidth=2, style=plot.style_linebr)
plot(lastResist,  "Resistance", color=color.new(color.red,  0), linewidth=2, style=plot.style_linebr)
plot(not na(lastSupport) ? lastSupport + zonePts : na, "Sup zone top", color=color.new(color.lime, 85))
plot(not na(lastSupport) ? lastSupport - zonePts : na, "Sup zone bot", color=color.new(color.lime, 85))
plot(not na(lastResist)  ? lastResist  + zonePts : na, "Res zone top", color=color.new(color.red,  85))
plot(not na(lastResist)  ? lastResist  - zonePts : na, "Res zone bot", color=color.new(color.red,  85))

//──────────────────────────────────────────────
// Prior Day High / Low — second level source
//──────────────────────────────────────────────
grpPD = "Prior Day High / Low"
usePDHL   = input.bool(true, "Enable Prior Day High/Low levels", group=grpPD)
pdZonePts = input.float(8.0, "PDH/PDL zone thickness (points)", minval=0.5, step=0.25, group=grpPD)

pdHigh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

plot(usePDHL ? pdHigh : na, "Prior Day High", color=color.new(color.purple, 0), linewidth=1, style=plot.style_linebr)
plot(usePDHL ? pdLow  : na, "Prior Day Low",  color=color.new(color.purple, 0), linewidth=1, style=plot.style_linebr)

inPDLowZone  = usePDHL and not na(pdLow)  and math.abs(close - pdLow)  <= pdZonePts and close > pdLow
inPDHighZone = usePDHL and not na(pdHigh) and math.abs(close - pdHigh) <= pdZonePts and close < pdHigh

//──────────────────────────────────────────────
// VWAP Filter
//──────────────────────────────────────────────
grpVWAP = "VWAP Filter"
useVWAP      = input.bool(true, "Require VWAP Alignment", group=grpVWAP)
useVWAPSlope = input.bool(false, "Require VWAP Slope in Direction", group=grpVWAP)
vwapSlopeLen = input.int(3, "VWAP slope lookback (bars)", minval=1, group=grpVWAP)

vwapValue = ta.vwap(close)
plot(vwapValue, "VWAP", color=color.new(color.yellow, 0), linewidth=2)

vwapSlope    = vwapValue - vwapValue[vwapSlopeLen]
vwapBullGate = (not useVWAP or close > vwapValue) and (not useVWAPSlope or vwapSlope > 0)
vwapBearGate = (not useVWAP or close < vwapValue) and (not useVWAPSlope or vwapSlope < 0)

//──────────────────────────────────────────────
// Daily MA Regime
//──────────────────────────────────────────────
grpReg = "Daily MA Regime"
useMAFilter = input.bool(true, "Enable daily MA regime filter", group=grpReg)
maFastLen   = input.int(3, "Daily MA Fast", minval=1, group=grpReg)
maMidLen    = input.int(5, "Daily MA Mid",  minval=1, group=grpReg)

dFast = request.security(syminfo.tickerid, "D", ta.sma(close, maFastLen))
dMid  = request.security(syminfo.tickerid, "D", ta.sma(close, maMidLen))

regimeBull = not useMAFilter or dFast > dMid
regimeBear = not useMAFilter or dFast < dMid

//──────────────────────────────────────────────
// RSI Filter
//──────────────────────────────────────────────
grpRSI = "RSI Filter"
useRSIFilter  = input.bool(true, "Enable RSI filter", group=grpRSI)
rsiLen        = input.int(14, "RSI length", minval=2, group=grpRSI)
rsiOversold   = input.int(45, "RSI max for PCS entry", minval=10, maxval=60, group=grpRSI)
rsiOverbought = input.int(55, "RSI min for CCS entry", minval=40, maxval=90, group=grpRSI)

rsiVal    = ta.rsi(close, rsiLen)
rsiBullOk = not useRSIFilter or rsiVal <= rsiOversold
rsiBearOk = not useRSIFilter or rsiVal >= rsiOverbought

//──────────────────────────────────────────────
// Signals
//──────────────────────────────────────────────
grpFreq = "Signal Spacing"
cooldownBars = input.int(10, "Bars between signals", minval=0, group=grpFreq)

canSignal = inSess and okAfterOpen and beforeCutoff

bullLevelOk = inSupportZone or inPDLowZone
bearLevelOk = inResistZone  or inPDHighZone

pcsRaw = canSignal and bullLevelOk and regimeBull and vwapBullGate and rsiBullOk
ccsRaw = canSignal and bearLevelOk and regimeBear and vwapBearGate and rsiBearOk

var int lastSigBar = -9999
pcsSignal = pcsRaw and not pcsRaw[1] and (bar_index - lastSigBar) > cooldownBars
ccsSignal = ccsRaw and not ccsRaw[1] and (bar_index - lastSigBar) > cooldownBars
if pcsSignal or ccsSignal
    lastSigBar := bar_index

if pcsSignal
    src = inSupportZone ? "PCS" : "PCS PDL"
    label.new(bar_index, low, src, color=color.new(color.lime, 20), textcolor=color.black, style=label.style_label_up, size=size.normal)
if ccsSignal
    src = inResistZone ? "CCS" : "CCS PDH"
    label.new(bar_index, high, src, color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_down, size=size.normal)

//──────────────────────────────────────────────
// Trade Ticket — suggested strikes
//──────────────────────────────────────────────
grpTicket = "Trade Ticket"
showTicket     = input.bool(true, "Show trade ticket", group=grpTicket)
cushionPts     = input.float(40.0, "OTM cushion (points)", minval=1.0, step=0.25, group=grpTicket)
spreadWidthPts = input.float(10.0, "Spread width (points)", minval=1.0, step=1.0, group=grpTicket)
strikeStep     = input.float(5.0,  "Strike increment (SPX=5)", minval=0.25, step=0.25, group=grpTicket)

roundToStep(x, step) =>
    step <= 0 ? x : math.round(x / step) * step

pcsShort = roundToStep(close - cushionPts, strikeStep)
pcsLong  = roundToStep(pcsShort - spreadWidthPts, strikeStep)
ccsShort = roundToStep(close + cushionPts, strikeStep)
ccsLong  = roundToStep(ccsShort + spreadWidthPts, strikeStep)

var string lastSuggest = "—"
var float  lastShort   = na
var float  lastLong    = na

if pcsSignal
    lastSuggest := "PCS (Bullish)"
    lastShort   := pcsShort
    lastLong    := pcsLong
if ccsSignal
    lastSuggest := "CCS (Bearish)"
    lastShort   := ccsShort
    lastLong    := ccsLong

var table tk = table.new(position.bottom_left, 2, 6, border_width=1)
fmtStrike(x) => na(x) ? "—" : str.tostring(x, "#.0")

if barstate.islast and showTicket
    bgT = color.new(color.black, 25)
    bg1 = color.new(color.black, 40)
    bg2 = color.new(color.black, 55)
    table.cell(tk, 0, 0, "TRADE TICKET — LITE", text_color=color.white, bgcolor=bgT, text_size=size.small)
    table.cell(tk, 1, 0, "", bgcolor=bgT)
    table.cell(tk, 0, 1, "Suggestion", text_color=color.white, bgcolor=bg1, text_size=size.small)
    table.cell(tk, 1, 1, lastSuggest, text_color=color.yellow, bgcolor=bg1, text_size=size.small)
    table.cell(tk, 0, 2, "Short Strike", text_color=color.white, bgcolor=bg2, text_size=size.small)
    table.cell(tk, 1, 2, fmtStrike(lastShort), text_color=color.white, bgcolor=bg2, text_size=size.small)
    table.cell(tk, 0, 3, "Long Strike", text_color=color.white, bgcolor=bg1, text_size=size.small)
    table.cell(tk, 1, 3, fmtStrike(lastLong), text_color=color.white, bgcolor=bg1, text_size=size.small)
    table.cell(tk, 0, 4, "Cushion / Width", text_color=color.white, bgcolor=bg2, text_size=size.small)
    table.cell(tk, 1, 4, str.tostring(cushionPts,"#.0") + " / " + str.tostring(spreadWidthPts,"#.0") + " pts", text_color=color.white, bgcolor=bg2, text_size=size.small)
    table.cell(tk, 0, 5, "RSI / VWAP", text_color=color.white, bgcolor=bg1, text_size=size.small)
    table.cell(tk, 1, 5, str.tostring(rsiVal,"#.0") + " / " + (close > vwapValue ? "Above" : "Below"), text_color=color.white, bgcolor=bg1, text_size=size.small)

//──────────────────────────────────────────────
// Alerts
//──────────────────────────────────────────────
alertcondition(pcsSignal, "PCS Signal", "TraderVoila Lite: {{ticker}} holding support in bullish conditions — put credit spread setup. Verify strikes & premium on your broker.")
alertcondition(ccsSignal, "CCS Signal", "TraderVoila Lite: {{ticker}} rejecting resistance in bearish conditions — call credit spread setup. Verify strikes & premium on your broker.")
````
