# Momentum Trader V2

- url: https://www.tradingview.com/script/u5y8DZrf-Momentum-Trader-V2/
- type: indicator
- pine_id: PUB;fb185d480b2a4a61a72d26b156f16089
- version: 1.0

## Description

Added dual-window Relative Strength vs NIFTY 500 with trend arrows and an RS-new-high 'leading' flag + alert; stop loss now anchored to SR levels but capped at a configurable max % (default 2%), displayed in the table, on-chart, and in alerts."

## Source Code

````pine
//@version=6
indicator("Momentum Trader", shorttitle="MomTrader", overlay=true, max_lines_count=80, max_labels_count=80)

// ── SETTINGS ─────────────────────────────────────────────────────────────────
var string G_MA = "📈 Moving Averages"
emaFastLen = input.int(10,  "EMA 10",  group=G_MA, minval=1)
emaMidLen  = input.int(21,  "EMA 21",  group=G_MA, minval=1)
smaLen     = input.int(50,  "SMA 50",  group=G_MA, minval=1)
show_emas  = input.bool(true, "Show EMAs / Ribbon", group=G_MA)

var string G_VOL = "📊 Volume"
rvLen              = input.int(21,   "Relative Volume Lookback", group=G_VOL, minval=5)
rvolAlertThreshold = input.float(1.5, "RVol Surge Threshold",   group=G_VOL, step=0.1)

var string G_SR = "⚡ Support / Resistance"
srLookback   = input.int(400,   "SR Scan Lookback Bars",   group=G_SR)
srLeft       = input.int(3,     "Pivot Left Bars",          group=G_SR, minval=1)
srRight      = input.int(3,     "Pivot Right Bars",         group=G_SR, minval=1)
minTouches   = input.int(4,     "Min Touches for SR Level", group=G_SR, minval=2)
srTolAtrMult = input.float(0.5, "SR Tolerance (ATR ×)",    group=G_SR, step=0.1)
srUseATR     = input.bool(true, "Use ATR for Tolerance",   group=G_SR)
srTolPct     = input.float(0.5, "SR Tolerance (%)",         group=G_SR, step=0.1)

var string G_MOM = "🚀 Momentum"
adxLen       = input.int(14, "ADX Length",    group=G_MOM, minval=1)
adxThreshold = input.int(20, "ADX Threshold", group=G_MOM, minval=1)

var string G_RS = "💪 Relative Strength"
rsSymbol = input.symbol("NSE:CNX500", "RS Benchmark (NIFTY 500)", group=G_RS)
rsLen    = input.int(55,  "RS Lookback Bars (short)", group=G_RS, minval=5)
rsLenLT  = input.int(123, "RS Lookback Bars (long)",  group=G_RS, minval=10)
rsMaLen  = input.int(20,  "RS Ratio MA Length",       group=G_RS, minval=2, tooltip="Ratio line (stock/index) above this MA = RS rising")
rsHiLen  = input.int(252, "RS New-High Lookback",     group=G_RS, minval=20, tooltip="Flags when the RS ratio makes a new high over this window while price has not — stock is leading the market")

var string G_RISK = "🛡 Risk Management"
maxSlPct = input.float(2.0, "Max Stop Loss %", group=G_RISK, minval=0.1, step=0.1, tooltip="SL is placed at the nearest SR level, but never more than this % away from price")
showSlLine = input.bool(true, "Show SL Line on Signal", group=G_RISK)

var string G_ALERTS = "🔔 Alerts"
alertEnabled  = input.bool(true,  "Enable Alerts",      group=G_ALERTS)
alertOnBreak  = input.bool(true,  "Alert on SR Break",  group=G_ALERTS)
alertOnBounce = input.bool(false, "Alert on SR Bounce", group=G_ALERTS)

var string G_DISP = "🎨 Display"
showTable = input.bool(true, "Show Info Table",        group=G_DISP)
show_sigs = input.bool(true, "Show Buy / Sell Labels", group=G_DISP)

// ── MOVING AVERAGES ───────────────────────────────────────────────────────────
ema10 = ta.ema(close, emaFastLen)
ema21 = ta.ema(close, emaMidLen)
sma50 = ta.sma(close, smaLen)

ema_bull_strong = close > ema10 and ema10 > ema21 and ema21 > sma50
ema_bull_basic  = ema10 > ema21
ema_bear        = ema10 < ema21

plot(show_emas ? ema10 : na, "EMA 10", color=color.new(color.yellow, 20), linewidth=1)
plot(show_emas ? ema21 : na, "EMA 21", color=color.new(color.orange, 20), linewidth=1)
plot(show_emas ? sma50 : na, "SMA 50", color=color.new(color.red,    40), linewidth=1)

p10 = plot(show_emas ? ema10 : na, display=display.none)
p21 = plot(show_emas ? ema21 : na, display=display.none)
fill(p10, p21, color=ema10 > ema21 ? color.new(color.teal, 92) : color.new(color.red, 92), title="EMA Ribbon")

// ── VOLUME ────────────────────────────────────────────────────────────────────
volAvg  = ta.sma(volume, rvLen)
rVol    = volAvg == 0 ? 0.0 : volume / volAvg
vol_exp = rVol >= rvolAlertThreshold
vol_dry = rVol < 0.7

// ── INDICATORS ────────────────────────────────────────────────────────────────
rsi     = ta.rsi(close, 14)
atr     = ta.atr(14)
atr_pct = atr / close * 100

// ADX (manual — no external dependency)
upMove   = high - high[1]
downMove = low[1] - low
plusDM   = upMove > downMove and upMove > 0 ? upMove : 0.0
minusDM  = downMove > upMove and downMove > 0 ? downMove : 0.0
trur     = math.max(high - low, math.max(math.abs(high - nz(close[1])), math.abs(low - nz(close[1]))))
atr_rma  = ta.rma(trur, adxLen)
smPlus   = ta.rma(plusDM, adxLen)
smMinus  = ta.rma(minusDM, adxLen)
plusDI   = atr_rma == 0 ? 0.0 : 100 * smPlus  / atr_rma
minusDI  = atr_rma == 0 ? 0.0 : 100 * smMinus / atr_rma
dx       = (plusDI + minusDI) == 0 ? 0.0 : 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adx      = ta.rma(dx, adxLen)
adxOk    = adx >= adxThreshold

// ── RELATIVE STRENGTH vs NIFTY 500 ───────────────────────────────────────────
// request.security must be called at global scope, every bar
idxClose = request.security(rsSymbol, timeframe.period, close, lookahead=barmerge.lookahead_off)

// Excess return helper: stock % return minus index % return over `len` bars
f_rsExcess(int len) =>
    sRet = na(close[len]) or close[len] == 0 ? na : (close / close[len] - 1) * 100
    iRet = na(idxClose) or na(idxClose[len]) or idxClose[len] == 0 ? na : (idxClose / idxClose[len] - 1) * 100
    na(sRet) or na(iRet) ? na : sRet - iRet

rsExcess   = f_rsExcess(rsLen)     // short window (default 55 bars ≈ 3 months daily)
rsExcessLT = f_rsExcess(rsLenLT)   // long window  (default 123 bars ≈ 6 months daily)
rsStrong   = not na(rsExcess) and rsExcess > 0

// Ratio line (Mansfield-style): stock / index. Rising = RS improving.
ratio    = na(idxClose) or idxClose == 0 ? na : close / idxClose
ratioMA  = ta.sma(ratio, rsMaLen)
rsRising = not na(ratio) and not na(ratioMA) and ratio > ratioMA and ratio > nz(ratio[10], ratio)

// RS new high before price = stock leading the market
ratioHi     = ta.highest(ratio, rsHiLen)
priceHi     = ta.highest(close, rsHiLen)
rsNewHigh   = not na(ratio) and not na(ratioHi) and ratio >= ratioHi
priceAtHigh = close >= priceHi
rsLeading   = rsNewHigh and not priceAtHigh

// ── SUPPORT / RESISTANCE ──────────────────────────────────────────────────────
var float[] pivots = array.new_float()

ph = ta.pivothigh(high, srLeft, srRight)
pl = ta.pivotlow(low,  srLeft, srRight)
if not na(ph)
    array.push(pivots, ph)
if not na(pl)
    array.push(pivots, pl)

f_tol(float level) =>
    base = srUseATR ? atr * srTolAtrMult : level * (srTolPct / 100.0)
    math.max(base, syminfo.mintick * 2)

var float[] uniq = array.new_float()
if barstate.islastconfirmedhistory or barstate.isrealtime
    array.clear(uniq)
    if array.size(pivots) > 0
        for i = 0 to array.size(pivots) - 1
            val   = array.get(pivots, i)
            found = false
            if array.size(uniq) > 0
                for j = 0 to array.size(uniq) - 1
                    u = array.get(uniq, j)
                    if math.abs(u - val) <= f_tol(val)
                        array.set(uniq, j, (u + val) / 2)
                        found := true
                        break
            if not found
                array.push(uniq, val)

// Reset each bar so levels are fresh
var float bestSupport    = na
var float bestResistance = na
var int   supportTouches = 0
var int   resistTouches  = 0
bestSupport    := na
bestResistance := na
supportTouches := 0
resistTouches  := 0

if array.size(uniq) > 0
    for i = 0 to array.size(uniq) - 1
        lvl     = array.get(uniq, i)
        touches = 0
        tol     = f_tol(lvl)
        for k = 0 to math.min(srLookback - 1, bar_index)
            if math.abs(close[k] - lvl) <= tol
                touches += 1
        if touches >= minTouches
            if lvl < close and (na(bestSupport) or lvl > bestSupport)
                bestSupport    := lvl
                supportTouches := touches
            if lvl > close and (na(bestResistance) or lvl < bestResistance)
                bestResistance := lvl
                resistTouches  := touches

// ── SR SIGNALS ────────────────────────────────────────────────────────────────
// ta.crossover/crossunder must be called every bar at the top level.
// Use manual crossover: price crossed level when it's above now but wasn't last bar.
_res_tol = not na(bestResistance) ? f_tol(bestResistance) : 0.0
_sup_tol = not na(bestSupport)    ? f_tol(bestSupport)    : 0.0
_res_line = not na(bestResistance) ? bestResistance + _res_tol : na
_sup_line = not na(bestSupport)    ? bestSupport    - _sup_tol : na

resBreak  = not na(_res_line) and close > _res_line and nz(close[1], close) <= nz(_res_line[1], _res_line)
supBreak  = not na(_sup_line) and close < _sup_line and nz(close[1], close) >= nz(_sup_line[1], _sup_line)
resTest   = not na(bestResistance) and low <= bestResistance + _res_tol
supBounce = not na(bestSupport) and low <= bestSupport + _sup_tol and close > bestSupport + _sup_tol and close > open

// ── BUY / SELL SIGNALS ────────────────────────────────────────────────────────
// Buy  = resistance break confirmed by ADX + volume surge + bullish EMAs
// Sell = support break with volume surge
buy_sig  = resBreak and adxOk and vol_exp and ema_bull_basic
sell_sig = supBreak and vol_exp

// ── STOP LOSS (capped at Max SL %) ────────────────────────────────────────────
// Long SL: at support if it's within maxSlPct of price, otherwise hard-capped at maxSlPct below close
slFloor    = close * (1 - maxSlPct / 100)
slBuy      = not na(bestSupport) and bestSupport >= slFloor ? bestSupport : slFloor
buyRiskPct = (close - slBuy) / close * 100

// Short SL: at resistance if within maxSlPct, otherwise capped at maxSlPct above close
slCeil      = close * (1 + maxSlPct / 100)
slSell      = not na(bestResistance) and bestResistance <= slCeil ? bestResistance : slCeil
sellRiskPct = (slSell - close) / close * 100

// Draw the SL level when a signal fires
var line slLine = na
if showSlLine and (buy_sig or sell_sig)
    line.delete(slLine)
    _slPrice = buy_sig ? slBuy : slSell
    slLine := line.new(bar_index, _slPrice, bar_index + 15, _slPrice, color=color.new(color.red, 0), width=1, style=line.style_dotted)
    label.new(bar_index + 15, _slPrice, "SL " + str.tostring(_slPrice, format.mintick), style=label.style_label_left, color=color.new(color.red, 70), textcolor=color.white, size=size.small)

// ── ALERTS ────────────────────────────────────────────────────────────────────
if alertEnabled and alertOnBreak and buy_sig
    alert("BUY | " + syminfo.ticker + " @ " + str.tostring(close, "#.##") + " | SL " + str.tostring(slBuy, "#.##") + " (-" + str.tostring(buyRiskPct, "#.##") + "%) | RVol " + str.tostring(rVol, "#.##") + "x | ADX " + str.tostring(adx, "#.#") + (not na(rsExcess) ? " | RS " + (rsExcess >= 0 ? "+" : "") + str.tostring(rsExcess, "#.#") + "%" : ""), alert.freq_once_per_bar)
if alertEnabled and alertOnBreak and sell_sig
    alert("SELL | " + syminfo.ticker + " @ " + str.tostring(close, "#.##") + " | SL " + str.tostring(slSell, "#.##") + " (+" + str.tostring(sellRiskPct, "#.##") + "%) | RVol " + str.tostring(rVol, "#.##") + "x", alert.freq_once_per_bar)
if alertEnabled and alertOnBounce and supBounce and not buy_sig
    alert("BOUNCE | " + syminfo.ticker + " @ " + str.tostring(close, "#.##"), alert.freq_once_per_bar)

alertcondition(buy_sig,   "Resistance Breakout", "Breakout BUY | {{ticker}} @ {{close}}")
alertcondition(sell_sig,  "Support Breakdown",   "Breakdown SELL | {{ticker}} @ {{close}}")
alertcondition(supBounce, "Support Bounce",       "Support Bounce | {{ticker}} @ {{close}}")
alertcondition(rsLeading and not rsLeading[1], "RS New High (Leading)", "RS ratio new high before price | {{ticker}} @ {{close}}")

// ── SR LINES ──────────────────────────────────────────────────────────────────
var line supLine = na
var line resLine = na

if not na(bestSupport)
    if na(supLine)
        supLine := line.new(bar_index - 1, bestSupport, bar_index + 10, bestSupport, extend=extend.right, color=color.new(color.teal, 15), width=2, style=line.style_dashed)
    else
        line.set_y1(supLine, bestSupport)
        line.set_y2(supLine, bestSupport)
        line.set_color(supLine, color.new(color.teal, 15))
else
    line.delete(supLine)
    supLine := na

if not na(bestResistance)
    if na(resLine)
        resLine := line.new(bar_index - 1, bestResistance, bar_index + 10, bestResistance, extend=extend.right, color=color.new(color.orange, 15), width=2, style=line.style_dashed)
    else
        line.set_y1(resLine, bestResistance)
        line.set_y2(resLine, bestResistance)
        line.set_color(resLine, color.new(color.orange, 15))
else
    line.delete(resLine)
    resLine := na

// ── SIGNAL SHAPES ─────────────────────────────────────────────────────────────
plotshape(show_sigs and buy_sig,  title="BUY",    style=shape.triangleup,   location=location.belowbar, color=color.new(color.lime, 0), size=size.normal, text="BUY",  textcolor=color.white)
plotshape(show_sigs and sell_sig, title="SELL",   style=shape.triangledown, location=location.abovebar, color=color.new(color.red,  0), size=size.normal, text="SELL", textcolor=color.white)
plotshape(show_sigs and supBounce and not buy_sig, title="BOUNCE", style=shape.labelup, location=location.belowbar, color=color.new(color.teal, 20), size=size.small, text="↑", textcolor=color.white)

// ── INFO TABLE ────────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 13, bgcolor=color.new(#0a0a12, 50), border_color=color.new(color.gray, 55), border_width=1, frame_color=color.new(color.gray, 35), frame_width=1)

if showTable and barstate.islast
    S  = size.tiny
    G  = color.new(color.gray, 10)
    W  = color.white
    DK = color.new(#1a1a2e, 0)

    // Row 0 — header
    table.cell(tbl, 0, 0, "MOMENTUM TRADER", bgcolor=DK, text_color=color.new(color.orange, 0), text_size=S)
    table.cell(tbl, 1, 0, "STATUS",          bgcolor=DK, text_color=color.new(color.orange, 0), text_size=S)

    // Row 1 — EMA trend
    _trend     = ema_bull_strong ? "STRONG (10>21>50)" : ema_bull_basic ? "BULL (10>21)" : ema_bear ? "BEAR (10<21)" : "NEUTRAL"
    _trend_col = ema_bull_strong ? color.lime : ema_bull_basic ? color.new(color.lime, 40) : ema_bear ? color.red : color.yellow
    table.cell(tbl, 0, 1, "EMA Trend", text_color=G, text_size=S)
    table.cell(tbl, 1, 1, _trend,      text_color=_trend_col, text_size=S)

    // Row 2 — RVol
    _rvol_txt = str.tostring(rVol, "#.##") + "x" + (vol_exp ? " SURGE" : vol_dry ? " DRY" : "")
    _rvol_col = vol_exp ? color.lime : vol_dry ? color.orange : W
    table.cell(tbl, 0, 2, "RVol",    text_color=G, text_size=S)
    table.cell(tbl, 1, 2, _rvol_txt, text_color=_rvol_col, text_size=S)

    // Row 3 — RSI
    _rsi_col = rsi > 70 ? color.red : rsi < 30 ? color.lime : W
    table.cell(tbl, 0, 3, "RSI (14)",               text_color=G,        text_size=S)
    table.cell(tbl, 1, 3, str.tostring(rsi, "#.#"),  text_color=_rsi_col, text_size=S)

    // Row 4 — ADX
    _adx_txt = str.tostring(adx, "#.#") + (adxOk ? " TRENDING" : " WEAK")
    _adx_col = adxOk ? color.lime : color.orange
    table.cell(tbl, 0, 4, "ADX",    text_color=G,        text_size=S)
    table.cell(tbl, 1, 4, _adx_txt, text_color=_adx_col, text_size=S)

    // Row 5 — RS vs NIFTY 500 (short window) with trend arrow + leading flag
    _rs_arrow = na(rsExcess) ? "" : rsRising ? " ▲ RISING" : " ▼ FADING"
    _rs_txt   = na(rsExcess) ? "—" : (rsExcess >= 0 ? "+" : "") + str.tostring(rsExcess, "#.#") + "%" + _rs_arrow + (rsLeading ? " ★" : "")
    _rs_col   = na(rsExcess) ? color.gray : rsExcess > 0 and rsRising ? color.lime : rsExcess > 0 ? color.new(color.lime, 45) : rsRising ? color.orange : color.red
    _rs_bg    = rsLeading ? color.new(color.lime, 82) : na
    table.cell(tbl, 0, 5, "RS " + str.tostring(rsLen) + "b" + (rsLeading ? " ★LEAD" : ""), bgcolor=_rs_bg, text_color=rsLeading ? color.lime : G, text_size=S)
    table.cell(tbl, 1, 5, _rs_txt, bgcolor=_rs_bg, text_color=_rs_col, text_size=S)

    // Row 6 — RS long window
    _rsl_txt = na(rsExcessLT) ? "—" : (rsExcessLT >= 0 ? "+" : "") + str.tostring(rsExcessLT, "#.#") + "% " + (rsExcessLT > 0 ? "OUTPERF" : "UNDERPERF")
    _rsl_col = na(rsExcessLT) ? color.gray : rsExcessLT > 0 ? color.new(color.lime, 35) : color.new(color.red, 15)
    table.cell(tbl, 0, 6, "RS " + str.tostring(rsLenLT) + "b", text_color=G,        text_size=S)
    table.cell(tbl, 1, 6, _rsl_txt,                            text_color=_rsl_col, text_size=S)

    // Row 7 — ATR
    _atr_col = atr_pct > 5 ? color.red : atr_pct > 3 ? color.orange : W
    table.cell(tbl, 0, 7, "ATR %",                          text_color=G,        text_size=S)
    table.cell(tbl, 1, 7, str.tostring(atr_pct, "#.##") + "%", text_color=_atr_col, text_size=S)

    // Row 8 — Support
    _sup_txt = not na(bestSupport) ? str.tostring(bestSupport, "#.##") + "  (" + str.tostring(supportTouches) + " touches)" : "—"
    _sup_col = not na(bestSupport) ? color.new(color.teal, 0) : color.gray
    table.cell(tbl, 0, 8, "Support", text_color=G,        text_size=S)
    table.cell(tbl, 1, 8, _sup_txt,  text_color=_sup_col, text_size=S)

    // Row 9 — Resistance
    _res_txt = not na(bestResistance) ? str.tostring(bestResistance, "#.##") + "  (" + str.tostring(resistTouches) + " touches)" : "—"
    _res_col = not na(bestResistance) ? color.new(color.orange, 0) : color.gray
    table.cell(tbl, 0, 9, "Resistance", text_color=G,        text_size=S)
    table.cell(tbl, 1, 9, _res_txt,     text_color=_res_col, text_size=S)

    // Row 10 — Signal
    _sig_lbl = buy_sig  ? "▲ BREAKOUT BUY"   : supBounce ? "↑ BOUNCE BUY" : sell_sig ? "▼ BREAKDOWN SELL" : resTest ? "TESTING RESIST" : "NO SIGNAL"
    _sig_col = buy_sig  ? color.lime          : supBounce ? color.new(color.teal, 0) : sell_sig ? color.red : resTest ? color.orange : color.gray
    _sig_bg  = buy_sig  ? color.new(color.lime, 78) : sell_sig ? color.new(color.red, 78) : color.new(#1a1a2e, 0)
    table.cell(tbl, 0, 10, "SIGNAL",  bgcolor=_sig_bg, text_color=G,        text_size=S)
    table.cell(tbl, 1, 10, _sig_lbl,  bgcolor=_sig_bg, text_color=_sig_col, text_size=S)

    // Row 11 — Stop Loss (capped at Max SL %)
    _sl_hint = buy_sig ? "SL " + str.tostring(slBuy, "#.##") + "  (-" + str.tostring(buyRiskPct, "#.##") + "%)" : sell_sig ? "SL " + str.tostring(slSell, "#.##") + "  (+" + str.tostring(sellRiskPct, "#.##") + "%)" : "Long SL ≈ " + str.tostring(slBuy, "#.##") + " (max -" + str.tostring(maxSlPct, "#.#") + "%)"
    _sl_bg   = (buy_sig or sell_sig) ? color.new(color.red, 88) : DK
    _sl_tc   = (buy_sig or sell_sig) ? color.new(color.red, 0)  : color.gray
    table.cell(tbl, 0, 11, "Stop Loss", bgcolor=_sl_bg, text_color=color.new(color.red, 20), text_size=S)
    table.cell(tbl, 1, 11, _sl_hint,    bgcolor=_sl_bg, text_color=_sl_tc, text_size=S)

    // Row 12 — Alerts
    table.cell(tbl, 0, 12, "Alerts",                           bgcolor=DK, text_color=G, text_size=S)
    table.cell(tbl, 1, 12, alertEnabled ? "ACTIVE" : "PAUSED", bgcolor=DK, text_color=alertEnabled ? color.lime : color.red, text_size=S)
````
