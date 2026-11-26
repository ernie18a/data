# Combined Signal Indicator

- url: https://www.tradingview.com/script/yE1OBaFX-Combined-Signal-Indicator/
- type: indicator
- pine_id: PUB;88f5738e6acb499698c92104d5af0c9b
- version: 1.0

## Description

Combined Signal Indicator (CSI) 
What it is:
A multi-confirmation signal indicator that requires 6 independent indicators to align simultaneously before printing a Buy or Sell label on the chart. It's designed to filter out low-quality setups by demanding agreement across momentum, trend, correlation, and volume-weighted effort before triggering.

What each component is watching:

PSMA — Measures what percentage of a range of moving averages price is currently trading above. Both the raw reading and its smoothed version must be in extreme territory (below 20 for buys, above 80 for sells), confirming broad MA-based oversold/overbought conditions.

SupOsc — A SuperTrend-based oscillator that tracks whether price is positioned bullishly or bearishly relative to its ATR bands. A buy fires when the oscillator crosses up through -0.50, a sell when it crosses down through +0.50.

Willy (Williams %R) — A classic overbought/oversold oscillator. The CSI checks the previous candle — meaning %R had to have already been in oversold (<-80) for buys or overbought (>-20) for sells. This acts as a lookback confirmation rather than a same-bar trigger.

LCO — Measures the linear correlation of price over a rolling window. A green background means price is in a strongly negative correlation regime (potential reversal zone for buys), red means strongly positive (potential exhaustion for sells).

EvR — A volume-weighted effort vs. results oscillator. A rising RROF_s line (green background) signals bulls are in control; falling (red background) signals bears. This adds a volume-effort dimension most indicators miss.

StochSup — A SuperTrend applied directly to the Stochastic RSI. Buy signals only trigger when the trend flips bullish while StochRSI is still below 50 (room to run). Sell signals only trigger when the trend flips bearish while above 50.


Does it repaint?
Partially — and this is important. Because real-time tracking is enabled, signals can appear and disappear mid-candle as price moves. This is intentional by design — the indicator is always reflecting live conditions. However:

A signal that is visible when a candle closes is confirmed and will not move or disappear retroactively.
A signal that appears mid-candle but conditions break before close will vanish — it was never a confirmed signal.
The StochSup has a "Wait for Timeframe Close" toggle — when enabled it uses confirmed bars only (no repaint on that component). When disabled it updates live but may repaint on higher timeframe modes.

Best practice: Treat any signal as a live alert during the candle, and a confirmed signal only at candle close.

The Alert:
There is one unified alert condition — it fires on either a buy or a sell. When setting it up in TradingView, choose "Once Per Bar" if you only want confirmed close signals, or "Once Per Bar Close" to strictly avoid any mid-candle noise. The alert message will display the ticker and timeframe automatically.

Things to keep in mind:

Because all 6 conditions must align, signals will be relatively rare — this is a feature, not a bug. It prioritizes quality over quantity.

The indicator works on any timeframe and any market that has volume data. On assets without volume (some forex pairs), the EvR component defaults to neutral behavior.
All settings for all 6 indicators are adjustable directly from the inputs panel, organized by group, so you can tune each component independently without touching the code.

Not enough signals? For more signals...
Highest Impact

PSMA — Buy Level → Raise from 20 up to 30 or 35. Both lines just need to be below this number, so widening it catches more setups.
PSMA — Sell Level → Lower from 80 down to 70 or 65. Same logic, opposite direction.
LCO — Upper Level → Lower from 0.8 toward 0.5 or 0.6. Less extreme correlation required for a red background.
LCO — Lower Level → Raise from -0.8 toward -0.5 or -0.6. Less extreme correlation required for a green background.


Medium Impact

Willy — Oversold Level → Raise from -80 to -70 or -65. Wider oversold zone means the previous candle qualifies more often for buys.
Willy — Overbought Level → Lower from -20 to -30 or -35. Same idea for sells.
SupOsc — ATR Multiplier → Lower from 2.0 toward 1.5. Tighter bands mean the oscillator crosses ±0.50 more frequently.


Lower Impact

StochSup — Multiplier → Lower from 10 toward 6 or 7. The SuperTrend on the Stoch RSI flips direction more often with tighter bands.
StochSup — RSI Length / K Period → Shorter values make the Stoch RSI more reactive, flipping the trend signal more frequently.


The Priority Order
Start with PSMA thresholds first, then LCO levels, then Willy levels. Those three alone will have the most noticeable effect on signal frequency without compromising the structural logic of the system.

## Source Code

````pine
//@version=6
indicator("Combined Signal Indicator", shorttitle="CSI", overlay=true)

// ═══════════════════════════════════════════════════════════════════
// GROUP 1 — PSMA (Percentage Price Over SMA)
// ═══════════════════════════════════════════════════════════════════
psma_min    = input.int(14,    "PSMA — Min MA Length",     minval=1,   group="PSMA")
psma_max    = input.int(28,    "PSMA — Max MA Length",     minval=1,   group="PSMA")
psma_smooth = input.int(14,    "PSMA — Smooth Length",     minval=1,   group="PSMA")
psma_src    = input.source(close, "PSMA — Source",                     group="PSMA")
psma_buy_lvl  = input.float(20, "PSMA — Buy Level (both lines below)",  minval=0, maxval=100, group="PSMA")
psma_sell_lvl = input.float(80, "PSMA — Sell Level (both lines above)", minval=0, maxval=100, group="PSMA")

// PSMA Calculation
var float psma_csum = 0.0
psma_csum := nz(psma_csum[1]) + psma_src
psma_p = 0
for i = psma_min to psma_max
    psma_ma = (psma_csum - nz(psma_csum[i])) / i
    psma_p := psma_src > psma_ma ? psma_p + 1 : psma_p
psma_per      = psma_p / (psma_max - psma_min + 1) * 100
psma_smoothed = ta.ema(psma_per, psma_smooth)

// PSMA Conditions
psma_buy  = psma_per < psma_buy_lvl and psma_smoothed < psma_buy_lvl
psma_sell = psma_per > psma_sell_lvl and psma_smoothed > psma_sell_lvl

// ═══════════════════════════════════════════════════════════════════
// GROUP 2 — SupOsc (SuperTrend Oscillator)
// ═══════════════════════════════════════════════════════════════════
suposc_length = input.int(10,   "SupOsc — ATR Length",    minval=1,   group="SupOsc")
suposc_mult   = input.float(2.0,"SupOsc — ATR Multiplier",minval=0.1, group="SupOsc")
suposc_smooth = input.int(72,   "SupOsc — Histogram Smooth",minval=1, group="SupOsc")

// SupOsc Calculation
suposc_src = close
float suposc_lower = 0.0
float suposc_upper = 0.0
var int suposc_trend = 0

suposc_atr   = ta.atr(suposc_length) * suposc_mult
suposc_up    = hl2 + suposc_atr
suposc_dn    = hl2 - suposc_atr
suposc_upper := suposc_src[1] < nz(suposc_upper[1]) ? math.min(suposc_up, nz(suposc_upper[1])) : suposc_up
suposc_lower := suposc_src[1] > nz(suposc_lower[1]) ? math.max(suposc_dn, nz(suposc_lower[1])) : suposc_dn
suposc_trend := suposc_src > nz(suposc_upper[1]) ? 1 : suposc_src < nz(suposc_lower[1]) ? 0 : nz(suposc_trend[1])
suposc_Spt   = suposc_trend * suposc_lower + (1 - suposc_trend) * suposc_upper

var float suposc_ama = 0.0
suposc_osc   = math.max(math.min((suposc_src - suposc_Spt) / (suposc_upper - suposc_lower), 1.0), -1.0)
suposc_alpha = math.pow(suposc_osc, 2) / suposc_length
suposc_ama  := nz(suposc_ama[1]) + suposc_alpha * (suposc_osc - nz(suposc_ama[1]))

// SupOsc Buy/Sell: osc crosses ±0.50 threshold
suposc_buy  = suposc_osc > -0.50 and suposc_osc[1] <= -0.50
suposc_sell = suposc_osc <  0.50 and suposc_osc[1] >=  0.50

// ═══════════════════════════════════════════════════════════════════
// GROUP 3 — Willy (Williams %R)
// ═══════════════════════════════════════════════════════════════════
willy_length   = input.int(21,  "Willy — Length",      minval=1, group="Willy")
willy_ema_len  = input.int(13,  "Willy — EMA Length",  minval=1, group="Willy")
willy_buy_ref  = input.float(-80.0, "Willy — Oversold Level",  group="Willy")
willy_sell_ref = input.float(-20.0, "Willy — Overbought Level",group="Willy")

// Willy Calculation
willy_upper = ta.highest(willy_length)
willy_lower = ta.lowest(willy_length)
willy_r     = 100 * (close - willy_upper) / (willy_upper - willy_lower)

// Willy Conditions — previous candle
willy_buy  = willy_r[1] < willy_buy_ref
willy_sell = willy_r[1] > willy_sell_ref

// ═══════════════════════════════════════════════════════════════════
// GROUP 4 — LCO (Linear Correlation Oscillator)
// ═══════════════════════════════════════════════════════════════════
lco_length     = input.int(14,   "LCO — Length",      minval=1, group="LCO")
lco_src        = input.source(close, "LCO — Source",             group="LCO")
lco_upperLevel = input.float(0.8,  "LCO — Upper Level", minval=0.0,  maxval=1.0,  step=0.05, group="LCO")
lco_lowerLevel = input.float(-0.8, "LCO — Lower Level", minval=-1.0, maxval=0.0,  step=0.05, group="LCO")

// LCO Calculation
var float lco_cmla = 0.0
var float lco_cmlb = 0.0
var float lco_cmlc = 0.0
lco_cmla := nz(lco_cmla[1]) + lco_src
lco_cmlb := nz(lco_cmlb[1]) + lco_cmla
lco_cmlc := nz(lco_cmlc[1]) + lco_src * lco_src

lco_sum  = lco_cmlb - nz(lco_cmlb[lco_length])
lco_a    = lco_length * lco_cmla - nz(lco_sum[1])
lco_b    = lco_cmla - nz(lco_cmla[lco_length])
lco_c    = lco_cmlc - nz(lco_cmlc[lco_length])

lco_num  = (lco_a - lco_b * (lco_length + 1) / 2) / lco_length
lco_vary = lco_c / lco_length - math.pow(lco_b / lco_length, 2)
lco_varx = float(lco_length * lco_length - 1) / 12.0
lco_cor  = lco_num / math.sqrt(lco_vary * lco_varx)

// LCO Background Conditions
lco_osc_color   = lco_cor >= lco_cor[1] ? 1 : -1   // 1=green, -1=red
lco_green_bg    = lco_cor < lco_lowerLevel           // green background = cor below lower level
lco_red_bg      = lco_cor > lco_upperLevel           // red background   = cor above upper level

// ═══════════════════════════════════════════════════════════════════
// GROUP 5 — StochSup (Stochastic SuperTrend)
// ═══════════════════════════════════════════════════════════════════
stochsup_tf         = input.timeframe("", "StochSup — Timeframe", group="StochSup")
stochsup_wait_close = input.bool(true,    "StochSup — Wait for TF Close", group="StochSup")
stochsup_rsi_len    = input.int(10,       "StochSup — RSI Length",   minval=1, group="StochSup")
stochsup_periodK    = input.int(7,        "StochSup — K Period",     minval=1, group="StochSup")
stochsup_smoothK    = input.int(3,        "StochSup — Smooth K",     minval=1, group="StochSup")
stochsup_factor     = input.int(10,       "StochSup — ST Multiplier",minval=1, group="StochSup")

// StochSup Calculation
stochsup_close = stochsup_wait_close
     ? request.security(syminfo.tickerid, stochsup_tf, close, lookahead=barmerge.lookahead_off)
     : request.security(syminfo.tickerid, stochsup_tf, close, lookahead=barmerge.lookahead_on)

stochsup_rsi = ta.rsi(stochsup_close, stochsup_rsi_len)
stochsup_k   = ta.sma(ta.stoch(stochsup_rsi, stochsup_rsi, stochsup_rsi, stochsup_periodK), stochsup_smoothK)

stochsup_upperBand = stochsup_k + stochsup_factor
stochsup_lowerBand = stochsup_k - stochsup_factor

stochsup_prevUpper = nz(stochsup_upperBand[1])
stochsup_prevLower = nz(stochsup_lowerBand[1])

stochsup_upperBand := stochsup_upperBand < stochsup_prevUpper or stochsup_k[1] > stochsup_prevUpper ? stochsup_upperBand : stochsup_prevUpper
stochsup_lowerBand := stochsup_lowerBand > stochsup_prevLower or stochsup_k[1] < stochsup_prevLower ? stochsup_lowerBand : stochsup_prevLower

var float stochsup_trend_val = na
var int   stochsup_dir       = na

if bar_index == 1
    stochsup_dir := 1
else if nz(stochsup_trend_val[1]) == stochsup_prevUpper
    stochsup_dir := stochsup_k > stochsup_upperBand ? -1 : 1
else
    stochsup_dir := stochsup_k < stochsup_lowerBand ? 1 : -1

stochsup_trend_val := stochsup_dir == -1 ? stochsup_lowerBand : stochsup_upperBand

// StochSup Signal Conditions
stochsup_buy  = stochsup_dir != stochsup_dir[1] and stochsup_dir == -1 and stochsup_k < 50
stochsup_sell = stochsup_dir != stochsup_dir[1] and stochsup_dir == 1  and stochsup_k > 50

// ═══════════════════════════════════════════════════════════════════
// GROUP 6 — EvR (Effort vs Results Explorer)
// ═══════════════════════════════════════════════════════════════════
evr_length   = input.int(10,    "EvR — RoF Length",     minval=1,  group="EvR")
evr_MA_Type  = input.string("WMA","EvR — MA Type",      options=["WMA","EMA","SMA","HMA","RMA"], group="EvR")
evr_smooth   = input.int(2,     "EvR — Smooth",         minval=1,  group="EvR")
evr_sig_len  = input.int(3,     "EvR — Signal Length",  minval=1,  group="EvR")
evr_S_Type   = input.string("EMA","EvR — Signal Type",  options=["WMA","EMA","SMA","HMA","RMA"], group="EvR")
evr_lookback = input.int(20,    "EvR — Lookback Length",minval=1,  group="EvR")
evr_lkbk_Calc= input.string("Simple","EvR — Lookback Avg",options=["Simple","Same as RRoF"], group="EvR")

evr_GetAverage(data, len, matype) =>
    switch matype
        "SMA" => ta.sma(data, len)
        "EMA" => ta.ema(data, len)
        "HMA" => ta.hma(data, len)
        "RMA" => ta.rma(data, len)
        =>       ta.wma(data, len)

evr_Normalize(val, avg) =>
    x = val / avg
    x > 1.50 ? 1.00 :
      x > 1.20 ? 0.90 :
      x > 1.00 ? 0.80 :
      x > 0.80 ? 0.70 :
      x > 0.60 ? 0.60 :
      x > 0.40 ? 0.50 :
      x > 0.20 ? 0.25 : 0.1

evr_lkbk_MA = evr_lkbk_Calc == "Simple" ? "SMA" : evr_MA_Type
evr_v        = na(volume) ? 1.0 : volume
evr_NoVol    = na(volume)
evr_Vola     = evr_GetAverage(evr_v, evr_lookback, evr_lkbk_MA)
evr_Vola_n   = evr_NoVol ? 100.0 : evr_Normalize(evr_v, evr_Vola) * 100

evr_BarSpread     = close - open
evr_BarRange      = high - low
evr_R2            = ta.highest(2) - ta.lowest(2)
evr_SrcShift      = ta.change(close)
evr_sign_shift    = math.sign(evr_SrcShift)
evr_sign_spread   = math.sign(evr_BarSpread)
evr_barclosing    = 2 * (close - low) / evr_BarRange * 100 - 100
evr_s2r           = evr_BarSpread / evr_BarRange * 100
evr_BarSpread_abs = math.abs(evr_BarSpread)
evr_BarSpread_avg = evr_GetAverage(evr_BarSpread_abs, evr_lookback, evr_lkbk_MA)
evr_BarSpread_n   = evr_Normalize(evr_BarSpread_abs, evr_BarSpread_avg) * 100 * evr_sign_spread
evr_barclosing_2  = 2 * (close - ta.lowest(2)) / evr_R2 * 100 - 100
evr_Shift2Bar     = evr_SrcShift / evr_R2 * 100
evr_SrcShift_abs  = math.abs(evr_SrcShift)
evr_srcshift_avg  = evr_GetAverage(evr_SrcShift_abs, evr_lookback, evr_lkbk_MA)
evr_srcshift_n    = evr_Normalize(evr_SrcShift_abs, evr_srcshift_avg) * 100 * evr_sign_shift
evr_Pricea_n      = (evr_barclosing + evr_s2r + evr_BarSpread_n + evr_barclosing_2 + evr_Shift2Bar + evr_srcshift_n) / 6
evr_bar_flow      = evr_Pricea_n * evr_Vola_n / 100
evr_bulls         = math.max(evr_bar_flow, 0)
evr_bears         = -1 * math.min(evr_bar_flow, 0)
evr_bulls_avg     = evr_GetAverage(evr_bulls, evr_length, evr_MA_Type)
evr_bears_avg     = evr_GetAverage(evr_bears, evr_length, evr_MA_Type)
evr_dx            = evr_bulls_avg / evr_bears_avg
evr_RROF          = 2 * (100 - 100 / (1 + evr_dx)) - 100
evr_RROF_s        = evr_GetAverage(evr_RROF, evr_smooth, evr_MA_Type)

// EvR Background Condition
evr_rrof_rising = evr_RROF_s > evr_RROF_s[1]

// ═══════════════════════════════════════════════════════════════════
// COMBINED BUY / SELL CONDITIONS
// ═══════════════════════════════════════════════════════════════════
buy_signal  = stochsup_buy  and suposc_buy  and lco_green_bg and evr_rrof_rising    and willy_buy  and psma_buy
sell_signal = stochsup_sell and suposc_sell and lco_red_bg   and not evr_rrof_rising and willy_sell and psma_sell

// ═══════════════════════════════════════════════════════════════════
// PLOTS — Buy/Sell signals only
// ═══════════════════════════════════════════════════════════════════
plotshape(buy_signal,  title="Buy Signal",  style=shape.labelup,   location=location.belowbar, color=color.new(color.green, 0), textcolor=color.white, text="BUY",  size=size.normal)
plotshape(sell_signal, title="Sell Signal", style=shape.labeldown, location=location.abovebar, color=color.new(color.red,   0), textcolor=color.white, text="SELL", size=size.normal)

// ═══════════════════════════════════════════════════════════════════
// SINGLE ALERT
// ═══════════════════════════════════════════════════════════════════
alertcondition(buy_signal or sell_signal, title="CSI Buy/Sell Signal", message="CSI Alert — {{ticker}} {{interval}}: Buy or Sell signal triggered")
````
