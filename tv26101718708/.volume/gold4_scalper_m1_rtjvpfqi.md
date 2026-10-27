# GOLD-4 Scalper M1

- url: https://www.tradingview.com/script/RtJvpfQi/
- type: indicator
- pine_id: PUB;a9760da82e954308b0d3d64c74d1ab98
- version: 1.0

## Description

w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???w indicator???

## Source Code

````pine
//@version=5
// ═══════════════════════════════════════════════════════════════════════════
// GOLD-4 Scalper M1  —  XAU/USD 1-Minute Scalping Indicator
// ───────────────────────────────────────────────────────────────────────────
// Concept : Trade WITH the EMA-200 trend, momentum aligned (EMA9 vs EMA21),
//           price on the correct side of VWAP, entering on a pullback that
//           taps EMA21 and is confirmed by a reversal candle, while RSI is
//           not stretched. Longs and shorts are exact mirrors.
// Prepare : A pre-signal "setup armed" state fires when every contextual
//           filter aligns and price is approaching EMA21 — before the
//           trigger candle prints. It is an early heads-up, not an entry.
// Repaint : Every signal AND prepare state is gated by `barstate.isconfirmed`,
//           so they are evaluated ONLY on closed bars and never repaint.
//           Alerts may be left on the "Once Per Bar Close" trigger.
// Notes   : request.security() uses lookahead_off. 1 point = 0.01 price units.
//           Designed for the M1 (1-minute) chart on XAU/USD.
// ═══════════════════════════════════════════════════════════════════════════
indicator(title="GOLD-4 Scalper M1", shorttitle="GOLD-4", overlay=true, max_lines_count=500, max_labels_count=500)

// ═══ INPUTS ════════════════════════════════════════════════════════════════
// --- Trend Filter ---
emaTrendLen = input.int(200, "Trend EMA Length", minval=50, group="Trend Filter")
useM5Trend  = input.bool(false, "Use M5 Trend EMA", group="Trend Filter", tooltip="Request the trend EMA from the 5-minute timeframe instead of the chart timeframe.")

// --- Momentum ---
emaFastLen = input.int(9,  "Fast EMA Length", minval=2, group="Momentum")
emaSlowLen = input.int(21, "Slow EMA Length", minval=3, group="Momentum")

// --- RSI Filter ---
rsiLen   = input.int(7, "RSI Length", minval=2, group="RSI Filter")
rsiUpper = input.float(70.0, "RSI Upper  (block longs above)",  group="RSI Filter")
rsiLower = input.float(30.0, "RSI Lower  (block shorts below)", group="RSI Filter")

// --- VWAP ---
useVWAP    = input.bool(true, "Use VWAP Filter", group="VWAP")
vwapAnchor = input.string("Session", "VWAP Anchor", options=["Session", "Day", "Week"], group="VWAP")

// --- Session Filter ---
useSession = input.bool(true, "Use Session Filter", group="Session Filter")
sessionStr = input.string("1300-1700", "Session  HHMM-HHMM", group="Session Filter", tooltip="Times are read in the timezone below. 1300-1700 GMT = London/NY overlap.")
tz         = input.string("GMT", "Session Timezone", group="Session Filter")

// --- Risk ---
slPoints = input.int(50,  "Stop Loss (points)",   minval=1, group="Risk", tooltip="1 point = 0.01 price units.")
tpPoints = input.int(100, "Take Profit (points)", minval=1, group="Risk", tooltip="1 point = 0.01 price units.")
showSLTP = input.bool(true, "Show SL/TP Lines", group="Risk")

// --- Prepare (Pre-Signal) ---
showPrepare    = input.bool(true, "Show Prepare (Pre-Signal) Markers", group="Prepare (Pre-Signal)")
prepareZonePct = input.float(0.4, "Approach Zone to EMA21 (%)", minval=0.1, maxval=3.0, step=0.1, group="Prepare (Pre-Signal)", tooltip="How close price must come to EMA21 to 'arm' a setup. Wider = earlier but vaguer warnings.")

// --- Visuals ---
showLabels = input.bool(true, "Show Signal Labels & Info Table", group="Visuals")
showAlerts = input.bool(true, "Fire alert() Calls on Signals",   group="Visuals")

// ═══ CONSTANTS & HELPERS ═══════════════════════════════════════════════════
float POINT = 0.01  // 1 point = 0.01 price units for XAU/USD

f_yn(bool c) => c ? "Y" : "N"

// ═══ CORE CALCULATIONS ═════════════════════════════════════════════════════
// --- Momentum EMAs ---
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

// --- Trend EMA: chart timeframe, or requested from M5 ---
// request.security() is always called (never inside a conditional) and uses
// lookahead_off so historical higher-timeframe values do not look ahead.
emaTrendLocal = ta.ema(close, emaTrendLen)
emaTrendM5    = request.security(syminfo.tickerid, "5", ta.ema(close, emaTrendLen), lookahead=barmerge.lookahead_off)
emaTrend      = useM5Trend ? emaTrendM5 : emaTrendLocal

// --- RSI & ATR ---
rsiVal = ta.rsi(close, rsiLen)
atrVal = ta.atr(14)

// --- VWAP (manually anchored) ---
// Computed manually so the Session / Day / Week anchor behaves predictably
// and the result is always a single float (avoids ta.vwap overload quirks).
// Session and Day reset on the daily boundary; Week resets on the weekly one.
chgDay    = timeframe.change("D")
chgWeek   = timeframe.change("W")
vwapReset = vwapAnchor == "Week" ? chgWeek : chgDay
var float cumPV  = na
var float cumVol = na
if vwapReset or na(cumPV)
    cumPV  := nz(hlc3 * volume)
    cumVol := nz(volume)
else
    cumPV  := cumPV  + nz(hlc3 * volume)
    cumVol := cumVol + nz(volume)
vwapVal = cumVol > 0 ? cumPV / cumVol : na

// ═══ SESSION FILTER ════════════════════════════════════════════════════════
// time() returns the bar time when inside the session, otherwise na.
sessionTime = time(timeframe.period, sessionStr + ":1234567", tz)
inSession   = useSession ? not na(sessionTime) : true

// ═══ REVERSAL CANDLE PATTERNS ══════════════════════════════════════════════
body      = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

// --- Bullish reversal: engulfing OR hammer OR long-tailed pin bar ---
bullEngulf = close > open and close[1] < open[1] and close > open[1] and open < close[1]
bullHammer = close > open and lowerWick > 2 * body and upperWick < body
// NOTE: the spec's "(low - min(open,close))" is always <= 0; the intended
//       quantity is the lower-wick length, used here for the pin bar.
bullPin      = close > open and lowerWick > 2 * body
bullReversal = bullEngulf or bullHammer or bullPin

// --- Bearish reversal: exact mirror (engulfing / shooting star / pin bar) ---
bearEngulf = close < open and close[1] > open[1] and close < open[1] and open > close[1]
bearStar   = close < open and upperWick > 2 * body and lowerWick < body
bearPin    = close < open and upperWick > 2 * body
bearReversal = bearEngulf or bearStar or bearPin

// ═══ PULLBACK TO EMA21 ═════════════════════════════════════════════════════
// Long  : bar low dips into the EMA21 touch zone (-0.2% .. +0.1%).
// Short : bar high pokes into the EMA21 touch zone (-0.1% .. +0.2%).
pullbackLong  = low  <= emaSlow * 1.001 and low  >= emaSlow * 0.998
pullbackShort = high >= emaSlow * 0.999 and high <= emaSlow * 1.002

// ═══ ENTRY SIGNALS ═════════════════════════════════════════════════════════
// Shared context: the filters that must hold for EITHER a prepare state or a
// full entry. A full entry then additionally needs the EMA21 pullback and a
// reversal candle; the prepare state only needs price approaching EMA21.
buyContext  = close > emaTrend and (not useVWAP or close > vwapVal) and emaFast > emaSlow and emaFast > emaFast[1] and rsiVal < rsiUpper and inSession
sellContext = close < emaTrend and (not useVWAP or close < vwapVal) and emaFast < emaSlow and emaFast < emaFast[1] and rsiVal > rsiLower and inSession

buyRaw  = buyContext  and pullbackLong  and bullReversal
sellRaw = sellContext and pullbackShort and bearReversal

// Non-repaint gate: a signal is final only on a confirmed (closed) bar.
buySignal  = buyRaw  and barstate.isconfirmed
sellSignal = sellRaw and barstate.isconfirmed

// ═══ PREPARE / PRE-SIGNAL STATE ════════════════════════════════════════════
// "Prepare" = every contextual filter is aligned and price is approaching the
// EMA21 zone, but the trigger candle has not printed yet. It is an early
// heads-up only — NOT an entry. Like the signals it is confirmed-bar gated,
// so the prepare markers and alerts never repaint.
prepZone      = prepareZonePct / 100.0
approachLong  = low  <= emaSlow * (1 + prepZone) and low  >= emaSlow * 0.998
approachShort = high >= emaSlow * (1 - prepZone) and high <= emaSlow * 1.002

prepBuyRaw  = buyContext  and approachLong  and not buyRaw
prepSellRaw = sellContext and approachShort and not sellRaw

prepareBuy  = prepBuyRaw  and barstate.isconfirmed
prepareSell = prepSellRaw and barstate.isconfirmed

// Rising-edge events so a prepare alert fires once when the setup first arms.
prepBuyEvent  = prepareBuy  and not prepareBuy[1]
prepSellEvent = prepareSell and not prepareSell[1]

// ═══ PLOTS ═════════════════════════════════════════════════════════════════
plot(emaFast,  "EMA Fast (9)",    color=color.lime,     linewidth=1)
plot(emaSlow,  "EMA Slow (21)",   color=color.orange,   linewidth=1)
plot(emaTrend, "EMA Trend (200)", color=chart.fg_color, linewidth=2)
plot(useVWAP ? vwapVal : na, "VWAP", color=color.blue,  linewidth=1)

// Session tint (guarded by useSession so the chart is not flooded when off).
bgcolor(useSession and inSession ? color.new(color.yellow, 95) : na, title="Session Tint")

plotshape(showLabels and buySignal,  title="BUY",  style=shape.triangleup,   location=location.belowbar, color=color.lime, textcolor=color.lime, size=size.small, text="BUY")
plotshape(showLabels and sellSignal, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.red,  textcolor=color.red,  size=size.small, text="SELL")

// Prepare markers: small circles — an early heads-up that a setup is arming.
plotshape(showPrepare and prepareBuy,  title="Prepare BUY",  style=shape.circle, location=location.belowbar, color=color.new(color.aqua, 20),    size=size.tiny)
plotshape(showPrepare and prepareSell, title="Prepare SELL", style=shape.circle, location=location.abovebar, color=color.new(color.fuchsia, 20), size=size.tiny)

// ═══ STOP-LOSS / TAKE-PROFIT LINES ═════════════════════════════════════════
// Persistent line arrays, capped at 20 entries each, oldest deleted first.
var line[] slLines = array.new_line()
var line[] tpLines = array.new_line()

if showSLTP and (buySignal or sellSignal)
    bool  isLong  = buySignal
    float entry   = close
    float slPrice = isLong ? entry - slPoints * POINT : entry + slPoints * POINT
    float tpPrice = isLong ? entry + tpPoints * POINT : entry - tpPoints * POINT
    line slL = line.new(bar_index, slPrice, bar_index + 20, slPrice, color=color.red,   width=1, style=line.style_dashed)
    line tpL = line.new(bar_index, tpPrice, bar_index + 20, tpPrice, color=color.green, width=1, style=line.style_dashed)
    array.push(slLines, slL)
    array.push(tpLines, tpL)
    if array.size(slLines) > 20
        line.delete(array.shift(slLines))
    if array.size(tpLines) > 20
        line.delete(array.shift(tpLines))

// ═══ ALERTS ════════════════════════════════════════════════════════════════
// alertcondition() is always compiled; create the alert from the dialog.
alertcondition(buySignal,  title="GOLD-4 BUY",  message="GOLD-4 BUY {{ticker}} @ {{close}}")
alertcondition(sellSignal, title="GOLD-4 SELL", message="GOLD-4 SELL {{ticker}} @ {{close}}")
alertcondition(prepBuyEvent,  title="GOLD-4 PREPARE BUY",  message="GOLD-4 prepare BUY {{ticker}} — setup arming near EMA21, watch for a bullish candle")
alertcondition(prepSellEvent, title="GOLD-4 PREPARE SELL", message="GOLD-4 prepare SELL {{ticker}} — setup arming near EMA21, watch for a bearish candle")

// alert() fires automatically on bar close when enabled.
if showAlerts and buySignal
    alert("GOLD-4 BUY "  + syminfo.ticker + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if showAlerts and sellSignal
    alert("GOLD-4 SELL " + syminfo.ticker + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if showAlerts and prepBuyEvent
    alert("GOLD-4 PREPARE BUY "  + syminfo.ticker + " — watch for a bullish reversal candle near EMA21", alert.freq_once_per_bar_close)
if showAlerts and prepSellEvent
    alert("GOLD-4 PREPARE SELL " + syminfo.ticker + " — watch for a bearish reversal candle near EMA21", alert.freq_once_per_bar_close)

// ═══ INFO TABLE ════════════════════════════════════════════════════════════
// Unlike the markers/alerts, this dashboard is a LIVE readout — it uses the
// raw (un-gated) conditions, so the Status row updates on the forming bar.
var table infoTable = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 10), frame_color=color.gray, frame_width=1, border_color=color.gray, border_width=1)

if showLabels and barstate.islast
    float  slope     = emaTrend - emaTrend[1]
    string trendTxt  = na(slope) ? "n/a" : slope > 0 ? "UP" : slope < 0 ? "DOWN" : "FLAT"
    color  trendCol  = na(slope) ? color.gray : slope > 0 ? color.green : slope < 0 ? color.red : color.gray
    bool   aboveVwap = not na(vwapVal) and close > vwapVal
    bool   emaBull   = emaFast > emaSlow

    string statusTxt = buyRaw ? "BUY SIGNAL" : sellRaw ? "SELL SIGNAL" : prepBuyRaw ? "BUY SETUP - arming" : prepSellRaw ? "SELL SETUP - arming" : "scanning..."
    color  statusCol = buyRaw ? color.lime : sellRaw ? color.red : prepBuyRaw ? color.aqua : prepSellRaw ? color.fuchsia : color.gray

    table.cell(infoTable, 0, 0, "GOLD-4 SCALPER", text_color=color.white, bgcolor=color.new(color.blue, 0), text_size=size.small)
    table.cell(infoTable, 1, 0, "M1",             text_color=color.white, bgcolor=color.new(color.blue, 0), text_size=size.small)

    table.cell(infoTable, 0, 1, "Status", text_color=color.silver, text_size=size.small)
    table.cell(infoTable, 1, 1, statusTxt, text_color=statusCol, text_size=size.small)

    table.cell(infoTable, 0, 2, "Trend", text_color=color.silver, text_size=size.small)
    table.cell(infoTable, 1, 2, trendTxt, text_color=trendCol, text_size=size.small)

    table.cell(infoTable, 0, 3, "Above VWAP", text_color=color.silver, text_size=size.small)
    table.cell(infoTable, 1, 3, f_yn(aboveVwap), text_color=aboveVwap ? color.green : color.red, text_size=size.small)

    table.cell(infoTable, 0, 4, "EMA9 > 21", text_color=color.silver, text_size=size.small)
    table.cell(infoTable, 1, 4, f_yn(emaBull), text_color=emaBull ? color.green : color.red, text_size=size.small)

    table.cell(infoTable, 0, 5, "RSI(" + str.tostring(rsiLen) + ")", text_color=color.silver, text_size=size.small)
    table.cell(infoTable, 1, 5, na(rsiVal) ? "n/a" : str.tostring(rsiVal, "#.0"), text_color=color.white, text_size=size.small)

    table.cell(infoTable, 0, 6, "In Session", text_color=color.silver, text_size=size.small)
    table.cell(infoTable, 1, 6, f_yn(inSession), text_color=inSession ? color.green : color.red, text_size=size.small)

    table.cell(infoTable, 0, 7, "ATR(14)", text_color=color.silver, text_size=size.small)
    table.cell(infoTable, 1, 7, na(atrVal) ? "n/a" : str.tostring(atrVal, format.mintick), text_color=color.white, text_size=size.small)
// ═══ END OF GOLD-4 SCALPER M1 ══════════════════════════════════════════════
````
