# SOL v1.0  Swing Trader

- url: https://www.tradingview.com/script/cpRqhk4B-SOL-v1-0-Swing-Trader/
- type: indicator
- pine_id: PUB;bb81e06dc328428aab390f21be5ee1c6
- version: 2.0

## Description

SOL v1.0 · Swing Trader 1-4hr Time Frame
A systematic mean-reversion signal cockpit for SOL perpetual futures. Identifies capitulation washout lows in low-momentum, ranging market conditions and targets multi-day recoveries. Built and validated on Jupiter Perps.

The thesis:
SOL spends extended periods chopping in tight ranges. Inside those ranges, sharp downward volatility spikes — capitulation wicks that flush weak longs — tend to resolve upward over the following 2–3 days. This indicator identifies those setups systematically and tells you exactly where to enter, where to take profit, and where to cut the loss.

Three hard gates — all three must be true to fire a signal
WVF (Williams VIX Fix) — detects the capitulation wick structure. Price made a sharp low, volatility spiked, and has since reset. This is the core setup identifier.
ADX < 25 — confirms the market is ranging, not trending. Mean reversion has no edge in a trending market. This gate ensures you're only trading the conditions where the thesis applies.
ER < 0.35 (Efficiency Ratio) — confirms the price action is genuinely choppy, not directional. A low efficiency ratio means price is oscillating rather than making sustained moves. Paired with ADX, this is the tightest ranging filter available without adding lag.
All three gates are toggleable and threshold-adjustable in the inputs. Defaults are the validated settings — change them only if you know what you're doing.

Stop framework:
Framework B fixed exits, validated as optimal against every alternative tested:
2h signals: TP +8.5% / SL −5.0%
3h signals: TP +10.0% / SL −6.0%
4h signals: TP +13.0% / SL −8.0%
Timeout: 144 bars (trade closes at market if neither target nor stop is hit)
Do not move the stop to breakeven. Do not take partial profit early. Do not trail. Every mechanism that touches a winning trade early was tested head-to-head against these fixed exits and underperformed. The stop is wide by design — the capitulation retest requires room.

Tiered alerts:
T4 ★★ — 3h and 4h aligned simultaneously. Strongest setup.
T3 ★ — 2h and 3h aligned. Primary signal.
T2 — 3h gate live only.
T1 — 2h gate live only.
T3 and T4 are the setups to prioritize. T1 and T2 are informational — treat them as early warnings that a T3 may be forming.

The panel:
NOW — live multi-timeframe decision cockpit across 1h, 2h, 3h, and 4h. Shows gate status, tier (BASE / SCALE / FULL based on trend-alignment score), regime (GREEN / YELLOW), and live Jupiter-ready entry, TP, and SL prices the moment a signal fires. Prices are anchored to the signal bar close — what you would have entered at.

CONFLUENCE — chart-timeframe observable stack. MBI, CVI, BBAWE, BP, VWAP, OBV, DELTA, EMA 9/21, HTF 240 bias, BTC regime, BB state. These do not gate signals. They are context — use them to read the quality of the setup before executing.

GREEN vs YELLOW regime — the NOW panel shows a regime color for each timeframe. GREEN means both ADX and ER confirm a tight ranging condition. YELLOW means ADX is below threshold but ER is elevated — a looser, less favorable setup. The system still signals in YELLOW with the default settings, but GREEN entries carry materially stronger historical performance. When the regime row is YELLOW, size accordingly or wait.

Chart overlays:
Bollinger Bands · EMA 9/21 · EMA 50 · SMA 50 · WVF capitulation markers · FVG (Fair Value Gap) boxes · Pivot swing high/low levels · Liquidation level lines (manual Coinglass inputs) · Adaptive Trend Finder channel. All individually toggleable.

Liquidation levels:
Enter your session liquidation heatmap values manually from Coinglass (SOL, 24h, All Exchanges, threshold 0.85). Four inputs: two above price, two below. These plot as horizontal reference lines — not signals, not gates. They show where forced liquidations are clustered, which can act as magnet levels for the capitulation move and for the recovery target.

What this is not:
Not a bot. Not an automated execution system. You receive an alert, you review the panel, you execute on Jupiter manually.
Not suitable for trending markets. When SOL is in a sustained directional move, the ADX gate will suppress most signals by design. If you're fighting the gate, the market is telling you this is not a mean-reversion environment.

Not a scalping tool. The 2h and 3h timeframes mean signals fire infrequently — sometimes once a week, sometimes less. The edge lives in patience and selectivity, not volume of trades.
Not optimized for other assets. Every parameter — WVF calibration, ADX threshold, ER threshold, stop percentages — was derived and validated specifically on SOL perpetuals. Applying it to BTC, ETH, or altcoins without independent validation is untested.

Inputs worth knowing:
Panel size and position are adjustable. If you're on mobile, Tiny or Small with Top Right works well.

The stop framework selector (A / B / C) is visible in inputs. Framework B is the validated default. A uses tighter stops and smaller targets — lower R:R. C uses wider stops with the same targets as A. Don't change the framework without understanding that the performance data was collected on B.

The conditions group exposes every parameter (WVF period, BB length, ADX length, ER length, EMA lengths, VIDYA settings, etc.) for advanced users. Leave them at defaults unless you have a specific reason to change them.

SOL v1.0 · Swing Trader is an analysis tool, not financial advice. Past signal performance does not guarantee future results. Perpetual futures carry significant risk including total loss of margin. Trade only what you can afford to lose.

## Source Code

````pine
// SOL Swing Trader — capitulation mean-reversion LONG engine for SOL perps
// Hard gates: WVF capitulation + ADX<25 (ranging) + ER<0.35 (low efficiency).
// Engine: 2h / 3h primary, 4h context. Framework B fixed stops + 144-bar timeout.
// Tiered phone alerts (T1–T4). NOW cockpit + CONFLUENCE observables + chart plots.
// ════════════════════════════════════════════════════════════════
//@version=6
indicator("SOL Swing Trader", overlay=true, max_bars_back=5000, max_lines_count=20, max_boxes_count=60)

// ─────────────────────────────────────────────────────────────
// DISPLAY / ZONE TOGGLES
// ─────────────────────────────────────────────────────────────
grpDisp   = "═══ Display ═══"
panelSize = input.string("Small", "Panel size", options=["Tiny","Small","Normal","Large"], group=grpDisp)
panelPos  = input.string("Top Right", "Panel position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=grpDisp)
zoneNow   = input.bool(true,  "Zone: NOW (cockpit, multi-TF)", group=grpDisp)
zoneConf  = input.bool(true,  "Zone: CONFLUENCE (observables)", group=grpDisp)
obsTFsel  = input.string("Chart", "CONFLUENCE observable TF", options=["Chart","1h","2h","3h"], group=grpDisp)
useAlerts = input.bool(true,  "Phone alerts (WVF+ADX tiers)", group=grpDisp)

grpPlot   = "═══ Chart Plots ═══"
showBB    = input.bool(true,  "Show BB bands on chart", group=grpPlot)
showEMA   = input.bool(true,  "EMAs (9/21)", group=grpPlot)
showEma50 = input.bool(true,  "Show EMA 50 (pale blue)", group=grpPlot)
ema50Len  = input.int(50, "EMA 50 length", minval=2, maxval=400, group=grpPlot)
showSma50 = input.bool(true,  "Show SMA 50 (bright yellow)", group=grpPlot)
sma50Len  = input.int(50, "SMA 50 length", minval=2, maxval=400, group=grpPlot)
showWVFm  = input.bool(true,  "Show WVF triangle markers", group=grpPlot)
showBbBreakMark = input.bool(true, "Show BB Break ▼ markers", group=grpPlot)
showCviTopMark  = input.bool(true, "Show CVI Top star markers", group=grpPlot)
showBbReject    = input.bool(true, "Show BB Reject markers", group=grpPlot)
showBgTint = input.bool(true, "Entry tier background tint", group=grpPlot)
showFVGb  = input.bool(true,  "FVG boxes (chart)", group=grpPlot)
showLIQ   = input.bool(true,  "Liquidation levels", group=grpPlot)

// ─────────────────────────────────────────────────────────────
// GATES / FRAMEWORK
// ─────────────────────────────────────────────────────────────
grpHard    = "═══ Hard Gates ═══"
useWVF     = input.bool(true,  "WVF armed (hard)", group=grpHard)
useAdxGate = input.bool(true,  "ADX < threshold (hard)", group=grpHard)
adxMax     = input.float(25.0, "ADX gate: below", minval=10.0, maxval=50.0, step=1.0, group=grpHard)
useErGate  = input.bool(true,  "ER < threshold (hard)", group=grpHard)
erMax      = input.float(0.35, "ER gate: below", minval=0.10, maxval=0.90, step=0.05, group=grpHard)

grpStop = "═══ Stop Framework ═══"
stopMode = input.string("B (wider)", "Framework", options=["A (tight)","B (wider)","C (wide stop, same tgt)"], group=grpStop)
a_tp2=input.float(5.0,"A 2h TP%",step=0.1,group=grpStop), a_sl2=input.float(2.75,"A 2h SL%",step=0.1,group=grpStop)
a_tp3=input.float(6.0,"A 3h TP%",step=0.1,group=grpStop), a_sl3=input.float(3.25,"A 3h SL%",step=0.1,group=grpStop)
b_tp2=input.float(8.5,"B 2h TP%",step=0.1,group=grpStop), b_sl2=input.float(5.0,"B 2h SL%",step=0.1,group=grpStop)
b_tp3=input.float(10.0,"B 3h TP%",step=0.1,group=grpStop), b_sl3=input.float(6.0,"B 3h SL%",step=0.1,group=grpStop)
c_tp2=input.float(5.0,"C 2h TP%",step=0.1,group=grpStop), c_sl2=input.float(4.0,"C 2h SL%",step=0.1,group=grpStop)
c_tp3=input.float(6.0,"C 3h TP%",step=0.1,group=grpStop), c_sl3=input.float(5.0,"C 3h SL%",step=0.1,group=grpStop)
a_tp4=input.float(7.0,"A 4h TP%",step=0.1,group=grpStop), a_sl4=input.float(4.0,"A 4h SL%",step=0.1,group=grpStop)
b_tp4=input.float(13.0,"B 4h TP%",step=0.1,group=grpStop), b_sl4=input.float(8.0,"B 4h SL%",step=0.1,group=grpStop)
c_tp4=input.float(7.0,"C 4h TP%",step=0.1,group=grpStop), c_sl4=input.float(6.0,"C 4h SL%",step=0.1,group=grpStop)
toBars = input.int(144,"Timeout (bars)",minval=4,maxval=1000,group=grpStop)

// ─────────────────────────────────────────────────────────────
// CONDITION PARAMS (v26 verbatim)
// ─────────────────────────────────────────────────────────────
grpC = "═══ Conditions (v26 verbatim) ═══"
wvf_pd=input.int(18,"WVF Period",group=grpC), wvf_bbl=input.int(16,"WVF BB Length",group=grpC)
wvf_mult=input.float(2.0,"WVF BB Mult",step=0.1,group=grpC), wvf_lb=input.int(40,"WVF Range LB",group=grpC)
wvf_ph=input.float(0.85,"WVF Range %",step=0.05,group=grpC), wvf_ltLB=input.int(30,"WVF LT LB",group=grpC)
wvf_mtLB=input.int(12,"WVF MT LB",group=grpC), wvf_str=input.int(2,"WVF Strength LB",group=grpC)
wvf_window=input.int(3,"WVF Arm Window",group=grpC), fvg_minPct=input.float(0.1,"FVG min gap %",step=0.05,group=grpC)
adxLen=input.int(14,"ADX length",group=grpC), erLen=input.int(14,"ER length",group=grpC)
emaFast=input.int(9,"EMA Fast",group=grpC), emaSlow=input.int(21,"EMA Slow",group=grpC)
vidya_length=input.int(10,"VIDYA Length",group=grpC), vidya_momentum=input.int(20,"VIDYA Momentum",group=grpC)
obv_len=input.int(8,"OBV Slope LB",group=grpC), deltaLen=input.int(14,"DELTA EMA len",group=grpC)
deltaArmWin=input.int(2,"DELTA arm win",group=grpC), coreWindow=input.int(2,"Core arm win",group=grpC)
bb_length=input.int(20,"BB Length",group=grpC), bb_mult=input.float(2.0,"BB Mult",step=0.1,group=grpC)
htfBiasTF=input.timeframe("240","HTF bias TF",group=grpC)
htfFastLen=input.int(50,"HTF EMA fast",group=grpC), htfSlowLen=input.int(200,"HTF EMA slow",group=grpC)
btcSym=input.symbol("BINANCE:BTCUSDT","BTC symbol",group=grpC)
trendDev=input.float(2.0,"ATF channel dev multiplier",step=0.1,group=grpC)
use_atf=input.bool(true,"ATF: enable engine",group=grpC)
showTrend=input.bool(true,"ATF: draw channel",group=grpC)
atf_long_term=input.bool(false,"ATF: long-term mode",group=grpC)
atf_strength_min=input.float(0.6,"ATF: min Pearson R to classify",step=0.05,group=grpC)

grpLIQ = "═══ Liquidation Levels (manual, Coinglass) ═══"
liq_above_1=input.float(0.0,"Liq above 1",group=grpLIQ), liq_above_2=input.float(0.0,"Liq above 2",group=grpLIQ)
liq_below_1=input.float(0.0,"Liq below 1",group=grpLIQ), liq_below_2=input.float(0.0,"Liq below 2",group=grpLIQ)

grpSR = "═══ Pivot S/R ═══"
showPivLevels = input.bool(true, "Show pivot S/R levels", group=grpSR)
pivLeft  = input.int(10, "Pivot left bars", minval=1, maxval=100, group=grpSR)
pivRight = input.int(5,  "Pivot right bars (confirmation lag)", minval=1, maxval=100, group=grpSR)

// resolve framework per TF
f_tp(_tf) =>
    _a = _tf == "4h" ? a_tp4 : _tf == "3h" ? a_tp3 : a_tp2
    _b = _tf == "4h" ? b_tp4 : _tf == "3h" ? b_tp3 : b_tp2
    _c = _tf == "4h" ? c_tp4 : _tf == "3h" ? c_tp3 : c_tp2
    stopMode == "A (tight)" ? _a : stopMode == "C (wide stop, same tgt)" ? _c : _b
f_sl(_tf) =>
    _a = _tf == "4h" ? a_sl4 : _tf == "3h" ? a_sl3 : a_sl2
    _b = _tf == "4h" ? b_sl4 : _tf == "3h" ? b_sl3 : b_sl2
    _c = _tf == "4h" ? c_sl4 : _tf == "3h" ? c_sl3 : c_sl2
    stopMode == "A (tight)" ? _a : stopMode == "C (wide stop, same tgt)" ? _c : _b

// ═══════════════════════════════════════════════════════════
// CHART-TF CONDITIONS (verbatim v26) — for cockpit live state + plots
// ═══════════════════════════════════════════════════════════
// WVF filtered
c_val = ((ta.highest(close, wvf_pd) - low) / ta.highest(close, wvf_pd)) * 100
c_sd  = wvf_mult * ta.stdev(c_val, wvf_bbl)
c_mid = ta.sma(c_val, wvf_bbl)
c_upper = c_mid + c_sd
c_rangeHigh = ta.highest(c_val, wvf_lb) * wvf_ph
c_wasHigh = c_val[1] >= c_upper[1] or c_val[1] >= c_rangeHigh[1]
c_nowLow  = c_val < c_upper and c_val < c_rangeHigh
c_filtRaw = c_wasHigh and c_nowLow
c_upRange = low > low[1] and close > high[1]
c_downtrend = close < close[wvf_ltLB] or close < close[wvf_mtLB]
c_strength = close > close[wvf_str]
c_wvfNow = c_upRange and c_strength and c_downtrend and c_filtRaw
c_wvfAge = -1
for _i = 0 to wvf_window
    if c_wvfAge == -1 and c_wvfNow[_i]
        c_wvfAge := _i
c_wvfArmed = c_wvfAge >= 0

// FVG
c_gap = low - high[2]
c_fvgRaw = c_gap > 0 and (c_gap / close * 100.0) >= fvg_minPct
bool c_fvgArmed = false
for _i = 0 to wvf_window
    if c_fvgRaw[_i]
        c_fvgArmed := true

// ADX / ER
[c_dp, c_dm, c_adx] = ta.dmi(adxLen, adxLen)
c_erChg = math.abs(close - close[erLen])
c_erVol = math.sum(math.abs(close - close[1]), erLen)
c_er = c_erVol != 0 ? c_erChg / c_erVol : 0.0

// BB (verbatim)
bb_basis = ta.sma(close, bb_length)
bb_dev   = ta.stdev(close, bb_length)
bb_upper = bb_basis + bb_mult * bb_dev
bb_lower = bb_basis - bb_mult * bb_dev
bb_break = close <= bb_lower
bb_reject = (low <= bb_lower) and close > bb_lower

// EMAs
emaF = ta.ema(close, emaFast)
emaS = ta.ema(close, emaSlow)
c_emaBull = emaF > emaS

// VIDYA value
v_momm = ta.change(close)
v_m1 = v_momm >= 0.0 ? v_momm : 0.0
v_m2 = v_momm >= 0.0 ? 0.0 : -v_momm
v_sm1 = math.sum(v_m1, vidya_momentum)
v_sm2 = math.sum(v_m2, vidya_momentum)
v_den = v_sm1 + v_sm2
v_cmo = v_den != 0 ? (100*(v_sm1-v_sm2)/v_den) : 0.0
v_k = math.abs(v_cmo)/100.0
v_alpha = 2.0/(vidya_length+1)
var float c_vid = na
c_vid := na(c_vid[1]) ? close : (v_alpha*v_k*close + (1.0 - v_alpha*v_k)*c_vid[1])
c_vidBull = close > c_vid

// OBV
c_obv = ta.cum(close >= open ? volume : -volume)
c_obvSlope = c_obv > c_obv[obv_len] ? 1 : (c_obv < c_obv[obv_len] ? -1 : 0)
c_obvBull = c_obvSlope == 1

// DELTA
c_signed = (close >= open ? volume : -volume)
c_deltaBull = ta.ema(c_signed, deltaLen) > 0

// MBI (verbatim)
mbi_mom_raw = close - close[10]
mbi_hl_ema = ta.ema(high - low, 10)
mbi_norm = mbi_hl_ema > 0 ? mbi_mom_raw / mbi_hl_ema * 100 : 0.0
mbi_up_raw = math.max(mbi_norm, 0.0)
mbi_dn_raw = math.min(mbi_norm, 0.0)
mbi_up_bias = math.max(ta.hma(math.sum(mbi_up_raw, 5), 10), 0.0)
mbi_dn_bias = math.max(ta.hma(-math.sum(mbi_dn_raw, 5), 10), 0.0)
mbi_bull_state = mbi_up_bias > mbi_dn_bias

// CVI (verbatim)
cvi_len = 3
cvi_hh = ta.highest(high, cvi_len)
cvi_ll = ta.lowest(low, cvi_len)
cvi_range = cvi_hh - cvi_ll
cvi_val = cvi_range > 0 ? (close - cvi_ll)/cvi_range : 0.5
cvi_bull_state = cvi_val < 0.5   // lower half = not overbought (mean-rev favorable)
cvi_bear_thresh = input.float(0.43, "CVI overbought threshold", minval=0.1, maxval=2.0, step=0.01, group=grpC)
cvi_top_signal = cvi_val[1] >= cvi_bear_thresh and cvi_val < cvi_bear_thresh

// BBAWE (verbatim)
bbawe_fast_ma = ta.ema(close, 3)
bbawe_ao = ta.sma(hl2, 5) - ta.sma(hl2, 34)
bbawe_bull = bbawe_fast_ma > bb_basis and close > bb_basis and bbawe_ao >= 0

// BP (verbatim)
bp_green = math.sum(close >= open ? 1.0 : 0.0, 20)
bp_pct = (bp_green/20)*100.0
bp_bull = bp_pct > 55.0
bp_bear = bp_pct < 45.0

// VWAP (session, simplified vs v26 swing-anchored — chart TF)
c_vwap = ta.vwap(hlc3)
c_vwapAbove = close > c_vwap

// HTF bias (240 EMA fast vs slow)
htf_f = request.security(syminfo.tickerid, htfBiasTF, ta.ema(close, htfFastLen), lookahead=barmerge.lookahead_off)
htf_s = request.security(syminfo.tickerid, htfBiasTF, ta.ema(close, htfSlowLen), lookahead=barmerge.lookahead_off)
htf_bull = htf_f > htf_s

// BTC regime (chart TF)
btc_close = request.security(btcSym, timeframe.period, close, lookahead=barmerge.lookahead_off)
btc_ema = request.security(btcSym, timeframe.period, ta.ema(close, 50), lookahead=barmerge.lookahead_off)
btc_bull = btc_close > btc_ema

// regime color (ER/ADX)
c_regime = c_adx < adxMax and c_er < 0.35 ? "GREEN" : c_adx < adxMax ? "YELLOW" : "RED"

// ─── Native pivot S/R (self-contained; no external dependency) ───
pivHi = ta.pivothigh(high, pivLeft, pivRight)
pivLo = ta.pivotlow(low, pivLeft, pivRight)
var float swingHigh = na
var float swingLow = na
if not na(pivHi)
    swingHigh := pivHi
if not na(pivLo)
    swingLow := pivLo
pivTagNow = not na(swingLow) and low <= swingLow

// ═══ v27.5: OBSERVABLE TF SELECTOR ═══
// SOL chart-native observables, fetchable at a chosen TF. Chart = follows
// the chart exactly as before. One bundled security call. f_obs contains
// NO nested security (pure series math). HTF240 & BTC are cross-context
// (their own security) and intentionally stay fixed regardless of selector.
f_obs() =>
    _vwapAbove = close > ta.vwap(hlc3)
    _obv = ta.cum(close >= open ? volume : -volume)
    _obvBull = _obv > _obv[obv_len]
    _deltaBull = ta.ema(close >= open ? volume : -volume, deltaLen) > 0
    _emaBull = ta.ema(close, emaFast) > ta.ema(close, emaSlow)
    _mraw = close - close[10]
    _hl = ta.ema(high - low, 10)
    _mn = _hl > 0 ? _mraw / _hl * 100 : 0.0
    _ub = math.max(ta.hma(math.sum(math.max(_mn, 0.0), 5), 10), 0.0)
    _db = math.max(ta.hma(-math.sum(math.min(_mn, 0.0), 5), 10), 0.0)
    _mbiBull = _ub > _db
    _hh = ta.highest(high, 3)
    _ll = ta.lowest(low, 3)
    _rg = _hh - _ll
    _cviBull = (_rg > 0 ? (close - _ll) / _rg : 0.5) < 0.5
    _bbBasis = ta.sma(close, bb_length)
    _bbDev = ta.stdev(close, bb_length)
    _bbLo = _bbBasis - bb_mult * _bbDev
    _ao = ta.sma(hl2, 5) - ta.sma(hl2, 34)
    _bbaweBull = ta.ema(close, 3) > _bbBasis and close > _bbBasis and _ao >= 0
    _bpPct = (math.sum(close >= open ? 1.0 : 0.0, 20) / 20) * 100.0
    _bbBreak = close <= _bbLo
    _bbReject = (low <= _bbLo) and close > _bbLo
    [_vwapAbove, _obvBull, _deltaBull, _emaBull, _mbiBull, _cviBull, _bbaweBull, _bpPct, _bbBreak, _bbReject]

obsRes = obsTFsel == "1h" ? "60" : obsTFsel == "2h" ? "120" : obsTFsel == "3h" ? "180" : timeframe.period
[o_vwapAbove, o_obvBull, o_deltaBull, o_emaBull, o_mbiBull, o_cviBull, o_bbaweBull, o_bpPct, o_bbBreak, o_bbReject] = request.security(syminfo.tickerid, obsRes, f_obs(), lookahead=barmerge.lookahead_off)
o_bpBull = o_bpPct > 55.0
o_bpBear = o_bpPct < 45.0
obsHdrTF = obsTFsel == "Chart" ? timeframe.period : obsRes + " lock"

// ═══════════════════════════════════════════════════════════
// ATF (Adaptive Trend Finder) — verbatim from v26.0.1
// ═══════════════════════════════════════════════════════════
var float atf_pearson  = 0.0
var float atf_slope    = 0.0
var float atf_intrcpt  = 0.0
var float atf_stddev   = 0.0
var int   atf_period   = 0
var float atf_upper_now = na
var float atf_lower_now = na
var line  atf_upperLine = na
var line  atf_lowerLine = na

f_calcDev(int length) =>
    float sumX = 0.0
    float sumXX = 0.0
    float sumYX = 0.0
    float sumY = 0.0
    for i = 1 to length
        float lSrc = math.log(nz(close[i - 1]))
        sumX  += i
        sumXX += i * i
        sumYX += i * lSrc
        sumY  += lSrc
    float slope_v = nz((length * sumYX - sumX * sumY) / (length * sumXX - sumX * sumX))
    float average = sumY / length
    float intercept_v = average - slope_v * sumX / length + slope_v
    float sumDev = 0.0
    float sumDxx = 0.0
    float sumDyy = 0.0
    float sumDyx = 0.0
    float regres = intercept_v + slope_v * (length - 1) * 0.5
    float sumSlp = intercept_v
    for i = 0 to length - 1
        float lSrc = math.log(nz(close[i]))
        float dxt  = lSrc - average
        float dyt  = sumSlp - regres
        lSrc := lSrc - sumSlp
        sumSlp += slope_v
        sumDxx += dxt * dxt
        sumDyy += dyt * dyt
        sumDyx += dxt * dyt
        sumDev += lSrc * lSrc
    float unStdDev = math.sqrt(sumDev / (length - 1))
    float divisor = sumDxx * sumDyy
    float pearsonR_v = divisor > 0 ? nz(sumDyx / math.sqrt(divisor)) : 0.0
    [unStdDev, pearsonR_v, slope_v, intercept_v]

if use_atf and barstate.islast
    int p1 = atf_long_term ? 300 : 20
    int p2 = atf_long_term ? 350 : 30
    int p3 = atf_long_term ? 400 : 40
    int p4 = atf_long_term ? 450 : 50
    int p5 = atf_long_term ? 500 : 60
    int p6 = atf_long_term ? 550 : 70
    int p7 = atf_long_term ? 600 : 80
    int p8 = atf_long_term ? 650 : 90
    int p9 = atf_long_term ? 700 : 100
    int p10 = atf_long_term ? 750 : 110
    int p11 = atf_long_term ? 800 : 120
    int p12 = atf_long_term ? 850 : 130
    int p13 = atf_long_term ? 900 : 140
    int p14 = atf_long_term ? 950 : 150
    int p15 = atf_long_term ? 1000 : 160
    int p16 = atf_long_term ? 1050 : 170
    int p17 = atf_long_term ? 1100 : 180
    int p18 = atf_long_term ? 1150 : 190
    int p19 = atf_long_term ? 1200 : 200
    [sd1, pr1, sl1, ic1] = f_calcDev(p1)
    [sd2, pr2, sl2, ic2] = f_calcDev(p2)
    [sd3, pr3, sl3, ic3] = f_calcDev(p3)
    [sd4, pr4, sl4, ic4] = f_calcDev(p4)
    [sd5, pr5, sl5, ic5] = f_calcDev(p5)
    [sd6, pr6, sl6, ic6] = f_calcDev(p6)
    [sd7, pr7, sl7, ic7] = f_calcDev(p7)
    [sd8, pr8, sl8, ic8] = f_calcDev(p8)
    [sd9, pr9, sl9, ic9] = f_calcDev(p9)
    [sd10, pr10, sl10, ic10] = f_calcDev(p10)
    [sd11, pr11, sl11, ic11] = f_calcDev(p11)
    [sd12, pr12, sl12, ic12] = f_calcDev(p12)
    [sd13, pr13, sl13, ic13] = f_calcDev(p13)
    [sd14, pr14, sl14, ic14] = f_calcDev(p14)
    [sd15, pr15, sl15, ic15] = f_calcDev(p15)
    [sd16, pr16, sl16, ic16] = f_calcDev(p16)
    [sd17, pr17, sl17, ic17] = f_calcDev(p17)
    [sd18, pr18, sl18, ic18] = f_calcDev(p18)
    [sd19, pr19, sl19, ic19] = f_calcDev(p19)
    float highest = math.max(pr1, pr2, pr3, pr4, pr5, pr6, pr7, pr8, pr9, pr10, pr11, pr12, pr13, pr14, pr15, pr16, pr17, pr18, pr19)
    atf_pearson := highest
    if highest == pr1
        atf_period := p1, atf_slope := sl1, atf_intrcpt := ic1, atf_stddev := sd1
    else if highest == pr2
        atf_period := p2, atf_slope := sl2, atf_intrcpt := ic2, atf_stddev := sd2
    else if highest == pr3
        atf_period := p3, atf_slope := sl3, atf_intrcpt := ic3, atf_stddev := sd3
    else if highest == pr4
        atf_period := p4, atf_slope := sl4, atf_intrcpt := ic4, atf_stddev := sd4
    else if highest == pr5
        atf_period := p5, atf_slope := sl5, atf_intrcpt := ic5, atf_stddev := sd5
    else if highest == pr6
        atf_period := p6, atf_slope := sl6, atf_intrcpt := ic6, atf_stddev := sd6
    else if highest == pr7
        atf_period := p7, atf_slope := sl7, atf_intrcpt := ic7, atf_stddev := sd7
    else if highest == pr8
        atf_period := p8, atf_slope := sl8, atf_intrcpt := ic8, atf_stddev := sd8
    else if highest == pr9
        atf_period := p9, atf_slope := sl9, atf_intrcpt := ic9, atf_stddev := sd9
    else if highest == pr10
        atf_period := p10, atf_slope := sl10, atf_intrcpt := ic10, atf_stddev := sd10
    else if highest == pr11
        atf_period := p11, atf_slope := sl11, atf_intrcpt := ic11, atf_stddev := sd11
    else if highest == pr12
        atf_period := p12, atf_slope := sl12, atf_intrcpt := ic12, atf_stddev := sd12
    else if highest == pr13
        atf_period := p13, atf_slope := sl13, atf_intrcpt := ic13, atf_stddev := sd13
    else if highest == pr14
        atf_period := p14, atf_slope := sl14, atf_intrcpt := ic14, atf_stddev := sd14
    else if highest == pr15
        atf_period := p15, atf_slope := sl15, atf_intrcpt := ic15, atf_stddev := sd15
    else if highest == pr16
        atf_period := p16, atf_slope := sl16, atf_intrcpt := ic16, atf_stddev := sd16
    else if highest == pr17
        atf_period := p17, atf_slope := sl17, atf_intrcpt := ic17, atf_stddev := sd17
    else if highest == pr18
        atf_period := p18, atf_slope := sl18, atf_intrcpt := ic18, atf_stddev := sd18
    else
        atf_period := p19, atf_slope := sl19, atf_intrcpt := ic19, atf_stddev := sd19
    if atf_period > 0
        float endPrice_now = math.exp(atf_intrcpt)
        atf_upper_now := endPrice_now * math.exp(trendDev * atf_stddev)
        atf_lower_now := endPrice_now / math.exp(trendDev * atf_stddev)

if showTrend and atf_period > 0
    float startPrice = math.exp(atf_intrcpt + atf_slope * (atf_period - 1))
    float endPrice   = math.exp(atf_intrcpt)
    int   startBar   = bar_index - atf_period + 1
    float upStart    = startPrice * math.exp(trendDev * atf_stddev)
    float upEnd      = endPrice   * math.exp(trendDev * atf_stddev)
    float loStart    = startPrice / math.exp(trendDev * atf_stddev)
    float loEnd      = endPrice   / math.exp(trendDev * atf_stddev)
    line.delete(atf_upperLine)
    line.delete(atf_lowerLine)
    atf_line_col = not use_atf or atf_pearson < atf_strength_min ? color.new(color.gray, 40) : atf_slope < 0 ? color.new(#00ff9d, 20) : color.new(#ff4560, 20)
    atf_upperLine := line.new(startBar, upStart, bar_index, upEnd, color=atf_line_col, width=2, extend=extend.right)
    atf_lowerLine := line.new(startBar, loStart, bar_index, loEnd, color=atf_line_col, width=2, extend=extend.right)

// ─── Pivot S/R: draw dashed rays + labels ───
var line lnSwHi = na
var line lnSwLo = na
var label lbSwHi = na
var label lbSwLo = na
if showPivLevels and barstate.islast
    line.delete(lnSwHi)
    line.delete(lnSwLo)
    label.delete(lbSwHi)
    label.delete(lbSwLo)
    if not na(swingHigh) and swingHigh > close
        lnSwHi := line.new(bar_index-150, swingHigh, bar_index, swingHigh, color=color.new(#ff8c00,0), width=1, extend=extend.right, style=line.style_dashed)
        lbSwHi := label.new(bar_index, swingHigh, "Swing-Hi "+str.tostring(swingHigh,"#.##"), style=label.style_label_left, color=color.new(#ff8c00,85), textcolor=color.new(#ff8c00,0), size=size.small)
    if not na(swingLow)
        lnSwLo := line.new(bar_index-150, swingLow, bar_index, swingLow, color=color.new(#00e0c0,0), width=1, extend=extend.right, style=line.style_dashed)
        lbSwLo := label.new(bar_index, swingLow, "Swing-Lo "+str.tostring(swingLow,"#.##"), style=label.style_label_left, color=color.new(#00e0c0,85), textcolor=color.new(#00e0c0,0), size=size.small)

atf_direction = (not use_atf or atf_pearson < atf_strength_min) ? "FLAT" : (atf_slope < 0 ? "UP" : "DOWN")
atf_strength_label = atf_pearson < 0.5 ? "WEAK" : atf_pearson < 0.7 ? "MOD" : atf_pearson < 0.85 ? "STRONG" : "VSTRONG"

// ═══════════════════════════════════════════════════════════
// MULTI-TF CORE (security) — gate/tier/regime per TF
// returns [wvfArmed, adx, score, tier(0/1/2/3), regimeCode(0G/1Y/2R), signalLive]
// tier: 0 none, 1 BASE, 2 SCALE, 3 FULL
// ═══════════════════════════════════════════════════════════
f_core(_tf) =>
    _val = ((ta.highest(close, wvf_pd) - low) / ta.highest(close, wvf_pd)) * 100
    _sd = wvf_mult * ta.stdev(_val, wvf_bbl)
    _mid = ta.sma(_val, wvf_bbl)
    _up = _mid + _sd
    _rh = ta.highest(_val, wvf_lb) * wvf_ph
    _wh = _val[1] >= _up[1] or _val[1] >= _rh[1]
    _nl = _val < _up and _val < _rh
    _raw = _wh and _nl
    _ur = low > low[1] and close > high[1]
    _dn = close < close[wvf_ltLB] or close < close[wvf_mtLB]
    _st = close > close[wvf_str]
    _wvf = _ur and _st and _dn and _raw
    _age = -1
    for _i = 0 to wvf_window
        if _age == -1 and _wvf[_i]
            _age := _i
    _armed = _age >= 0
    [_dp,_dm,_adx] = ta.dmi(adxLen, adxLen)
    _erc = math.abs(close - close[erLen])
    _erv = math.sum(math.abs(close - close[1]), erLen)
    _er = _erv != 0 ? _erc/_erv : 0.0
    // score (ema+vidya+obv arms)
    _emb = ta.ema(close, emaFast) > ta.ema(close, emaSlow)
    _mm = ta.change(close)
    _a1 = _mm >= 0 ? _mm : 0.0
    _a2 = _mm >= 0 ? 0.0 : -_mm
    _s1 = math.sum(_a1, vidya_momentum)
    _s2 = math.sum(_a2, vidya_momentum)
    _dn2 = _s1+_s2
    _cm = _dn2 != 0 ? 100*(_s1-_s2)/_dn2 : 0.0
    _kk = math.abs(_cm)/100.0
    _al = 2.0/(vidya_length+1)
    var float _vv = na
    _vv := na(_vv[1]) ? close : (_al*_kk*close + (1.0-_al*_kk)*_vv[1])
    _vb = close > _vv
    _ob = ta.cum(close>=open?volume:-volume)
    _obb = _ob > _ob[obv_len]
    float _score = (_emb?1.0:0.0)+(_vb?1.0:0.0)+(_obb?1.0:0.0)
    _adxOk = not useAdxGate or _adx < adxMax
    _gWvf  = not useWVF or _armed
    _gEr   = not useErGate or _er < erMax
    _pass = _gWvf and _adxOk and _gEr
    int _tier = 0
    if _pass
        _tier := _score >= 2 ? (_adx < adxMax ? 3 : 2) : 1
    int _reg = _adx < adxMax and _er < 0.35 ? 0 : _adx < adxMax ? 1 : 2
    [_armed, _adx, _score, _tier, _reg, _pass]

[w1,a1v,s1v,t1,r1,p1] = request.security(syminfo.tickerid, "60",  f_core("1h"), lookahead=barmerge.lookahead_off)
[w2,a2v,s2v,t2,r2,p2] = request.security(syminfo.tickerid, "120", f_core("2h"), lookahead=barmerge.lookahead_off)
[w3,a3v,s3v,t3,r3,p3] = request.security(syminfo.tickerid, "180", f_core("3h"), lookahead=barmerge.lookahead_off)
[w4,a4v,s4v,t4,r4,p4] = request.security(syminfo.tickerid, "240", f_core("4h"), lookahead=barmerge.lookahead_off)


// ═══ v27.5: chart-TF tier (bg tint #5) · column flags (#1) · alerts (#3) ═══
// chart-TF OWN tier (no security — chart data) mirroring f_core score/tier.
c_score3 = (c_emaBull ? 1.0 : 0.0) + (c_vidBull ? 1.0 : 0.0) + (c_obvBull ? 1.0 : 0.0)
c_adxOk = not useAdxGate or c_adx < adxMax
// v27.8: useWVF fix + FVG/Score gates mirrored on chart-TF pass (bg tint).
// 3h-favored gates intentionally NOT applied here — they are TF-specific.
c_passChart = (not useWVF or c_wvfArmed) and c_adxOk and (not useErGate or c_er < erMax)
c_tierChart = c_passChart ? (c_score3 >= 2 ? (c_adx < adxMax ? 3 : 2) : 1) : 0
// which NOW column equals the chart TF
isChart1h = timeframe.period == "60"
isChart2h = timeframe.period == "120"
isChart3h = timeframe.period == "180"
isChart4h = timeframe.period == "240"
onLadder = isChart1h or isChart2h or isChart3h or isChart4h
// tiered alerts: T4=3h+4h (new top) > T3=2h+3h (unchanged) > T2=3h only > T1=2h only
// T4 checked first so it supersedes T3 when 4h is also live.
bc_t4 = p3 and p4
bc_t3 = p2 and p3
bc_t2 = p3 and not p2
bc_t1 = p2 and not p3
if useAlerts and barstate.isconfirmed
    if bc_t4 and not bc_t4[1]
        alert("★ T4 ★ SOL Bottom — 3h+4h gate aligned (WVF+ADX<" + str.tostring(adxMax, "#") + ") @ " + str.tostring(close, "#.##"), alert.freq_once_per_bar_close)
    else if bc_t3 and not bc_t3[1]
        alert("★ T3 ★ SOL Bottom — 2h+3h gate aligned (WVF+ADX<" + str.tostring(adxMax, "#") + ") @ " + str.tostring(close, "#.##"), alert.freq_once_per_bar_close)
    else if bc_t2 and not bc_t2[1]
        alert("T2 SOL Bottom — 3h gate live (WVF+ADX) @ " + str.tostring(close, "#.##"), alert.freq_once_per_bar_close)
    else if bc_t1 and not bc_t1[1]
        alert("T1 SOL Bottom — 2h gate live (WVF+ADX) @ " + str.tostring(close, "#.##"), alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════════════════════
// CHART PLOTS
// ═══════════════════════════════════════════════════════════
// ═══════════════════════════════════════════════════════════
// CHART PLOTS — colors verbatim from v26.0.1
// ═══════════════════════════════════════════════════════════
plot(showBB ? bb_lower : na, "BB Lower", color=color.new(#4488ff, 0), linewidth=2)
plot(showBB ? bb_basis : na, "BB Basis", color=color.new(#4488ff, 0), linewidth=2)
plot(showBB ? bb_upper : na, "BB Upper", color=color.new(#4488ff, 0), linewidth=2)
plot(showEMA ? emaF : na, "EMA Fast (9)", color=color.new(color.aqua,0), linewidth=1)
plot(showEMA ? emaS : na, "EMA Slow (21)", color=color.new(color.orange,0), linewidth=1)
plot(showEma50 ? ta.ema(close, ema50Len) : na, "EMA 50", color=color.new(#7FBFFF, 0), linewidth=2)
plot(showSma50 ? ta.sma(close, sma50Len) : na, "SMA 50", color=color.new(color.yellow, 0), linewidth=2)

plotshape(showWVFm and c_wvfNow, title="WVF Filtered", style=shape.triangleup, location=location.belowbar, color=color.new(#DA70D6, 0), size=size.small)
plotshape(showBbBreakMark and bb_break, title="BB Break", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny)
plotshape(showCviTopMark and cvi_top_signal, title="CVI Top", style=shape.diamond, location=location.abovebar, color=color.new(color.red, 0), size=size.tiny, text="*", textcolor=color.new(color.red, 0))
plotshape(showBbReject and bb_reject, title="BB Reject", style=shape.circle, location=location.belowbar, color=color.new(color.aqua, 0), size=size.tiny)

// FVG box on fresh gap
if showFVGb and c_fvgRaw
    box.new(bar_index-2, low, bar_index, high[2], border_color=color.new(#00ddff,40), bgcolor=color.new(#00ddff,90))

// liquidation levels (manual Coinglass inputs)
plot(showLIQ and liq_above_1 > 0 ? liq_above_1 : na, "Liq+1", color=color.new(color.red,30), style=plot.style_linebr, linewidth=1)
plot(showLIQ and liq_above_2 > 0 ? liq_above_2 : na, "Liq+2", color=color.new(color.red,50), style=plot.style_linebr, linewidth=1)
plot(showLIQ and liq_below_1 > 0 ? liq_below_1 : na, "Liq-1", color=color.new(color.lime,30), style=plot.style_linebr, linewidth=1)
plot(showLIQ and liq_below_2 > 0 ? liq_below_2 : na, "Liq-2", color=color.new(color.lime,50), style=plot.style_linebr, linewidth=1)

// v27.5: entry-tier bg tint uses the CHART's OWN tier (c_tierChart), not max(2h,3h)
bgColor = showBgTint and c_passChart ? (c_tierChart == 3 ? color.new(color.aqua, 85) : c_tierChart == 2 ? color.new(color.lime, 85) : color.new(color.yellow, 88)) : na
bgcolor(bgColor, title="Entry Tier Tint")

// ═══════════════════════════════════════════════════════════
// PANEL HELPERS
// ═══════════════════════════════════════════════════════════
f_pos() => panelPos=="Top Right"?position.top_right:panelPos=="Top Left"?position.top_left:panelPos=="Bottom Left"?position.bottom_left:panelPos=="Middle Right"?position.middle_right:position.bottom_right
f_sz() => panelSize=="Tiny"?size.tiny:panelSize=="Small"?size.small:panelSize=="Large"?size.large:size.normal
f_pct(_p) => (_p >= 0 ? "+" : "") + str.tostring(_p, "#.#")  // v27.5: sign-correct % (Pine + is a literal, not a sign-forcer)
f_onoff(_b) => _b ? color.lime : color.new(color.red,0)
f_tierTxt(_t) => _t==3?"FULL":_t==2?"SCALE":_t==1?"BASE":"—"
f_tierCol(_t) => _t==3?color.lime:_t==2?color.aqua:_t==1?color.yellow:color.new(color.gray,40)
f_regTxt(_r) => _r==0?"GREEN":_r==1?"YELLOW":"RED"
f_regCol(_r) => _r==0?color.lime:_r==1?color.yellow:color.new(color.red,0)
f_wr(_h,_n) => _n<=0?"—":str.tostring(math.round(_h/_n*100))+"%"
f_expR(_s,_n) => _n<=0?"—":str.tostring(_s/_n,"#.00")+"R"
f_ec(_s,_n) => _n<10?color.new(color.gray,30):(_s/_n>=0.10?color.lime:(_s/_n>=0.0?color.yellow:color.new(color.red,0)))

// state→color for observables (bull/favorable = lime, bear/unfavorable = red)
f_sc(_bull) => _bull ? color.lime : color.new(color.red,0)
f_scTxt(_bull, _bullTxt, _bearTxt) => _bull ? _bullTxt : _bearTxt

// top-level observable-row helper (table passed in; Pine forbids defining this inside if)
f_obsRow(_tbl, _row, _label, _bull, _bullTxt, _bearTxt) =>
    table.cell(_tbl, 0, _row, _label, text_color=color.new(color.white,10), text_size=f_sz(), text_halign=text.align_left)
    table.cell(_tbl, 1, _row, _bull?_bullTxt:_bearTxt, text_color=f_sc(_bull), text_size=f_sz(), text_halign=text.align_center)
    table.merge_cells(_tbl, 1, _row, 4, _row)

// validation TF-row helper: label | Exp(R) | WR | n
f_valRow(_tbl, _row, _lbl, _e, _t, _n) =>
    table.cell(_tbl, 0, _row, _lbl, text_color=color.new(color.white,10), text_size=f_sz(), text_halign=text.align_left)
    table.cell(_tbl, 1, _row, f_expR(_e,_n), text_color=f_ec(_e,_n), text_size=f_sz(), text_halign=text.align_center)
    table.cell(_tbl, 2, _row, f_wr(_t,_n), text_color=color.new(color.white,0), text_size=f_sz(), text_halign=text.align_center)
    table.cell(_tbl, 3, _row, str.tostring(_n), text_color=color.new(color.gray,0), text_size=f_sz(), text_halign=text.align_center)
    table.merge_cells(_tbl, 3, _row, 4, _row)

// active framework R:R display (per TF)
curTP2 = f_tp("2h")
curSL2 = f_sl("2h")
curTP3 = f_tp("3h")
curSL3 = f_sl("3h")
curTP4 = f_tp("4h")
curSL4 = f_sl("4h")

// v27.15.1: per-TF entry latches — capture close on the FIRST bar of each
// live signal, hold while it persists, clear when it ends. On the forming
// signal bar the latch tracks live price (var rollback per tick), then
// commits at bar close = the tracker's recorded entry. Display-only state.
var float sigE2 = na
var float sigE3 = na
var float sigE4 = na
sigE2 := p2 ? (na(sigE2) ? close : sigE2) : na
sigE3 := p3 ? (na(sigE3) ? close : sigE3) : na
sigE4 := p4 ? (na(sigE4) ? close : sigE4) : na

var table p = na
if barstate.islast
    int rows = 2  // ACTION banner + title/TF header
    rows := rows + (zoneNow ? 10 : 0) + (zoneConf ? 12 : 0)
    p := table.new(f_pos(), 5, rows, bgcolor=color.new(#0a0e14,0), border_width=1, border_color=color.new(color.gray,70), frame_width=2, frame_color=color.new(#00ff9d,0))
    int rr = 0

    // ACTION banner (merged, large) — at-a-glance decision verb (now 4h-aware)
    string _actTxt = p4 ? "● SIGNAL LIVE 4h" : p3 ? "● SIGNAL LIVE 3h" : p2 ? "● SIGNAL LIVE 2h" : (w2 or w3 or w4) ? "WATCH · WVF armed" : "WAIT"
    color  _actCol = (p2 or p3 or p4) ? color.lime : (w2 or w3 or w4) ? color.yellow : color.new(color.gray,25)
    string _actFull = _actTxt + (onLadder ? "" : "   · chart " + timeframe.period)
    table.cell(p, 0, rr, _actFull, text_color=_actCol, text_size=size.large, text_halign=text.align_center, bgcolor=color.new(#0a1428,0))
    table.merge_cells(p, 0, rr, 4, rr)
    rr += 1
    // title + TF header (chart-TF column highlighted)
    table.cell(p, 0, rr, "v27.16 · "+stopMode, text_color=color.new(#00ff9d,0), text_size=f_sz(), text_halign=text.align_left, bgcolor=color.new(#0a2818,0))
    table.cell(p, 1, rr, "1h"+(isChart1h?" ●":""), text_color=isChart1h?color.new(color.white,0):color.aqua, text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart1h?color.new(#00ddff,30):color.new(#0a2818,0))
    table.cell(p, 2, rr, "2h"+(isChart2h?" ●":""), text_color=isChart2h?color.new(color.white,0):color.aqua, text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart2h?color.new(#00ddff,30):color.new(#0a2818,0))
    table.cell(p, 3, rr, "3h"+(isChart3h?" ●":""), text_color=isChart3h?color.new(color.white,0):color.aqua, text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart3h?color.new(#00ddff,30):color.new(#0a2818,0))
    table.cell(p, 4, rr, "4h"+(isChart4h?" ●":""), text_color=isChart4h?color.new(color.white,0):color.aqua, text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart4h?color.new(#00ddff,30):color.new(#0a2818,0))
    rr += 1

    // ── ZONE 1: NOW (multi-TF) ──
    if zoneNow
        table.cell(p, 0, rr, "— NOW —", text_color=color.new(#00ff9d,0), text_size=f_sz(), text_halign=text.align_left, bgcolor=color.new(#0a2818,20))
        table.merge_cells(p, 0, rr, 4, rr)
        rr += 1
        table.cell(p, 0, rr, "TIER", text_color=color.new(color.white,10), text_size=f_sz(), text_halign=text.align_left)
        table.cell(p, 1, rr, f_tierTxt(t1), text_color=f_tierCol(t1), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart1h?color.new(#00ddff,82):na)
        table.cell(p, 2, rr, f_tierTxt(t2), text_color=f_tierCol(t2), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart2h?color.new(#00ddff,82):na)
        table.cell(p, 3, rr, f_tierTxt(t3), text_color=f_tierCol(t3), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart3h?color.new(#00ddff,82):na)
        table.cell(p, 4, rr, f_tierTxt(t4), text_color=f_tierCol(t4), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart4h?color.new(#00ddff,82):na)
        rr += 1
        table.cell(p, 0, rr, "WVF armed", text_color=color.new(color.white,10), text_size=f_sz(), text_halign=text.align_left)
        table.cell(p, 1, rr, w1?"✓":"—", text_color=f_onoff(w1), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart1h?color.new(#00ddff,82):na)
        table.cell(p, 2, rr, w2?"✓":"—", text_color=f_onoff(w2), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart2h?color.new(#00ddff,82):na)
        table.cell(p, 3, rr, w3?"✓":"—", text_color=f_onoff(w3), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart3h?color.new(#00ddff,82):na)
        table.cell(p, 4, rr, w4?"✓":"—", text_color=f_onoff(w4), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart4h?color.new(#00ddff,82):na)
        rr += 1
        table.cell(p, 0, rr, "ADX", text_color=color.new(color.white,10), text_size=f_sz(), text_halign=text.align_left)
        table.cell(p, 1, rr, str.tostring(a1v,"#")+(a1v<adxMax?"✓":""), text_color=a1v<adxMax?color.lime:color.yellow, text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart1h?color.new(#00ddff,82):na)
        table.cell(p, 2, rr, str.tostring(a2v,"#")+(a2v<adxMax?"✓":""), text_color=a2v<adxMax?color.lime:color.yellow, text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart2h?color.new(#00ddff,82):na)
        table.cell(p, 3, rr, str.tostring(a3v,"#")+(a3v<adxMax?"✓":""), text_color=a3v<adxMax?color.lime:color.yellow, text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart3h?color.new(#00ddff,82):na)
        table.cell(p, 4, rr, str.tostring(a4v,"#")+(a4v<adxMax?"✓":""), text_color=a4v<adxMax?color.lime:color.yellow, text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart4h?color.new(#00ddff,82):na)
        rr += 1
        table.cell(p, 0, rr, "Score", text_color=color.new(color.white,10), text_size=f_sz(), text_halign=text.align_left)
        table.cell(p, 1, rr, str.tostring(s1v,"#"), text_color=color.new(color.white,0), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart1h?color.new(#00ddff,82):na)
        table.cell(p, 2, rr, str.tostring(s2v,"#"), text_color=color.new(color.white,0), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart2h?color.new(#00ddff,82):na)
        table.cell(p, 3, rr, str.tostring(s3v,"#"), text_color=color.new(color.white,0), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart3h?color.new(#00ddff,82):na)
        table.cell(p, 4, rr, str.tostring(s4v,"#"), text_color=color.new(color.white,0), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart4h?color.new(#00ddff,82):na)
        rr += 1
        table.cell(p, 0, rr, "Regime", text_color=color.new(color.white,10), text_size=f_sz(), text_halign=text.align_left)
        table.cell(p, 1, rr, f_regTxt(r1), text_color=f_regCol(r1), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart1h?color.new(#00ddff,82):na)
        table.cell(p, 2, rr, f_regTxt(r2), text_color=f_regCol(r2), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart2h?color.new(#00ddff,82):na)
        table.cell(p, 3, rr, f_regTxt(r3), text_color=f_regCol(r3), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart3h?color.new(#00ddff,82):na)
        table.cell(p, 4, rr, f_regTxt(r4), text_color=f_regCol(r4), text_size=f_sz(), text_halign=text.align_center, bgcolor=isChart4h?color.new(#00ddff,82):na)
        rr += 1
        // signal-now line (4h-aware; level reflects highest live TF)
        string _sig = p4 ? "4h SIGNAL LIVE" : p3 ? "3h SIGNAL LIVE" : p2 ? "2h SIGNAL LIVE" : "— no signal —"
        color _sigc = (p2 or p3 or p4) ? color.lime : color.new(color.gray,20)
        table.cell(p, 0, rr, _sig, text_color=_sigc, text_size=f_sz(), text_halign=text.align_left, bgcolor=color.new(#0a1428,30))
        float _lvTP = p4 ? curTP4 : p3 ? curTP3 : p2 ? curTP2 : curTP3
        float _lvSL = p4 ? curSL4 : p3 ? curSL3 : p2 ? curSL2 : curSL3
        // v27.15.1: Jupiter-ready prices while live (anchored to signal-bar close); % reference when idle
        float _lvE = p4 ? sigE4 : p3 ? sigE3 : p2 ? sigE2 : na
        bool _lvLive = (p2 or p3 or p4) and not na(_lvE)
        string _lvl = _lvLive ? "E "+str.tostring(_lvE,"#.##")+" · TP "+str.tostring(_lvE*(1.0+_lvTP/100.0),"#.##")+" · SL "+str.tostring(_lvE*(1.0-_lvSL/100.0),"#.##") : "tgt "+str.tostring(_lvTP,"#.#")+"% / stp "+str.tostring(_lvSL,"#.#")+"%"
        table.cell(p, 1, rr, _lvl, text_color=_lvLive ? color.lime : color.new(color.white,0), text_size=f_sz(), text_halign=text.align_center, bgcolor=color.new(#0a1428,30))
        table.merge_cells(p, 1, rr, 4, rr)
        rr += 1
        // Pivot S/R rows (chart-TF)
        bool _hiActive = not na(swingHigh) and swingHigh > close
        string _hiLbl = na(swingHigh) ? "—" : _hiActive ? str.tostring(swingHigh,"#.##")+"  ("+f_pct((swingHigh-close)/close*100)+"%)" : "Prior Hi "+str.tostring(swingHigh,"#.##")
        color  _hiCol = _hiActive ? color.new(#ff8c00,0) : color.new(color.gray,30)
        table.cell(p, 0, rr, "Swing-Hi (R)", text_color=color.new(color.white,10), text_size=f_sz(), text_halign=text.align_left)
        table.cell(p, 1, rr, _hiLbl, text_color=_hiCol, text_size=f_sz(), text_halign=text.align_center)
        table.merge_cells(p, 1, rr, 4, rr)
        rr += 1
        table.cell(p, 0, rr, "Swing-Lo (S)", text_color=color.new(color.white,10), text_size=f_sz(), text_halign=text.align_left)
        string _swloTxt = na(swingLow)?"—":str.tostring(swingLow,"#.##")+"  ("+f_pct((swingLow-close)/close*100)+"%)"+(pivTagNow?"  ★TAG":"")
        table.cell(p, 1, rr, _swloTxt, text_color=pivTagNow?color.new(color.lime,0):color.new(#00e0c0,0), text_size=f_sz(), text_halign=text.align_center)
        table.merge_cells(p, 1, rr, 4, rr)
        rr += 1

    // ── ZONE 2: CONFLUENCE (chart-TF observables, color-coded) ──
    if zoneConf
        table.cell(p, 0, rr, "— CONFLUENCE ("+obsHdrTF+") —", text_color=color.new(#00ddff,0), text_size=f_sz(), text_halign=text.align_left, bgcolor=color.new(#0a1428,20))
        table.merge_cells(p, 0, rr, 4, rr)
        rr += 1
        f_obsRow(p, rr, "HTF 240/EMA", htf_bull, "BULL", "BEAR")
        rr += 1
        f_obsRow(p, rr, "BTC", btc_bull, "BULL", "BEAR")
        rr += 1
        f_obsRow(p, rr, "VWAP", o_vwapAbove, "ABOVE", "BELOW")
        rr += 1
        f_obsRow(p, rr, "OBV", o_obvBull, "BULL", "BEAR")
        rr += 1
        f_obsRow(p, rr, "DELTA", o_deltaBull, "ARM", "OFF")
        rr += 1
        f_obsRow(p, rr, "EMA 9/21", o_emaBull, "BULL", "BEAR")
        rr += 1
        f_obsRow(p, rr, "MBI", o_mbiBull, "BULL", "BEAR")
        rr += 1
        f_obsRow(p, rr, "CVI", o_cviBull, "LOW", "HIGH")
        rr += 1
        f_obsRow(p, rr, "BBAWE", o_bbaweBull, "BULL", "BEAR")
        rr += 1
        // BP three-state
        table.cell(p, 0, rr, "BP "+str.tostring(o_bpPct,"#")+"%", text_color=color.new(color.white,10), text_size=f_sz(), text_halign=text.align_left)
        table.cell(p, 1, rr, o_bpBull?"BULL":o_bpBear?"BEAR":"FLAT", text_color=o_bpBull?color.lime:o_bpBear?color.new(color.red,0):color.new(color.gray,20), text_size=f_sz(), text_halign=text.align_center)
        table.merge_cells(p, 1, rr, 4, rr)
        rr += 1
        // BB state
        table.cell(p, 0, rr, "BB", text_color=color.new(color.white,10), text_size=f_sz(), text_halign=text.align_left)
        table.cell(p, 1, rr, o_bbBreak?"BREAK":o_bbReject?"REJECT":"—", text_color=o_bbBreak?color.new(color.red,0):o_bbReject?color.lime:color.new(color.gray,30), text_size=f_sz(), text_halign=text.align_center)
        table.merge_cells(p, 1, rr, 4, rr)
        rr += 1
````
