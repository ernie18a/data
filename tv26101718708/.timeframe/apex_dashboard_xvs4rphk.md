# Apex Dashboard 

- url: https://www.tradingview.com/script/xVs4rpHK-Apex-Dashboard/
- type: indicator
- pine_id: PUB;3f548aef979244dcad1cd20b2f41b1ec
- version: 1.0

## Description

Title: Apex Institutional Dashboard [HUD Only]
The Problem with SMC Indicators
Most Smart Money Concepts (SMC) and institutional trading scripts suffer from the exact same fatal flaw: Chart Clutter. By the time your indicator finishes drawing Fair Value Gaps, Order Blocks, Liquidity Lines, session backgrounds, and text labels, your candlesticks are completely buried. You lose the ability to actually read pure price action.

The Solution: The Apex Dashboard
The Apex Institutional Dashboard is a "Stealth Engine." It calculates thousands of data points, tracks institutional liquidity sweeps, monitors volume delta, and analyzes multi-timeframe trends—all entirely in the background.

Instead of painting 100 different boxes on your screen, it distills all of that institutional math into two ultra-clean, compact HUD (Heads-Up Display) tables anchored to the corners of your chart. You get elite-level confluence data, and your candlesticks remain 100% naked and readable.

📊 Feature 1: The MTF Bias Dashboard
Anchored by default to the Top Right, this panel gives you an instant macro-to-micro view of the market.

MTF Alignment: Calculates the real-time EMA-based trend bias across the Daily, 4H, 1H, 15m, and 5m timeframes.

Regime Detection: Uses a customized Choppiness Index (CHOP) to definitively tell you if the market is trending (✦ TRENDING) or trapped in a sideways range (⚡ CHOPPY).

CVD Flow (Cumulative Volume Delta): Measures the delta between buying and selling volume to warn you of hidden institutional inflow or outflow before the price breaks.

A-M-D Session Tracking: Tracks the Asia, London, and New York sessions, automatically identifying the current phase of the ICT Accumulation, Manipulation, and Distribution (AMD) cycle.

🎯 Feature 2: The Action Status Panel
Anchored by default to the Bottom Left, this is the brain of the operation. The Apex Engine constantly scans for high-probability setups and feeds you live status updates based on deep confluence.

💎 STRONG BUY / SELL: Fires only when the market sweeps Tier-1 Liquidity (PDH/PDL or Major Swings), aligns with Linear Regression momentum, clears Chandelier Volatility Exits, and shows confirming CVD volume.

📈 SWING LONG / SHORT: A dedicated macro engine that hunts for major higher-timeframe reversals, keeping you in massive trends.

🟢 REGULAR / WEAK SIGNALS: Identifies minor structural breaks and continuation setups during runaway parabolic trends.

⏸️ CHOP WAIT: The ultimate account saver. If the engine detects a liquidity sweep but the Choppiness Index confirms the market is in a dead range, it explicitly warns you to wait, filtering out fake breakouts.

⚙️ Under The Hood (The Invisible Engine)
Even though you can't see the drawings, this script is running heavy institutional logic:

Adaptive Sweep Memory: The script remembers recent liquidity sweeps (PDH, PDL, Major/Minor BSL and SSL) and holds them in an elastic memory buffer to catch delayed "V-shaped" reversals.

Parabolic Runaway Support: In a raging trend, the script adapts. It lowers its sweep requirements, allowing you to catch aggressive 1-to-2 candle pullbacks into unmitigated zones without waiting for a deep structural flush.

Displacement Override: Detects massive ATR volume anomalies. If institutions violently inject capital, the script overrides lagging indicators to get you in instantly.

Ghost Anchor Technology: Custom built to bypass TradingView's UI rendering bugs. The tables will never detach from your candles, and the script prevents auto-generating annoying secondary price scales.

Best Used For: Built specifically for XAU/USD (Gold) on the 5-minute timeframe, but robust enough to trade Forex, Indices, and Crypto across any timeframe.

Trade the data, not the noise.

## Source Code

````pine
//@version=6
indicator("Apex Dashboard Only | Institutional Edge", shorttitle="Apex_Dash", overlay=true)

// ════════════════════════════════════════════════════════════════════════════
// ■ INPUTS
// ════════════════════════════════════════════════════════════════════════════
const string GT = "🔷 Trend Engine"
lr_len    = input.int   (21,  "LinReg Length",        group=GT, minval=5,   maxval=100)
ce_period = input.int   (22,  "Chandelier Period",    group=GT, minval=5,   maxval=50)
ce_mult   = input.float (1.8, "Chandelier ATR Mult",  group=GT, minval=0.5, maxval=5.0, step=0.1)

const string GV = "📊 Volume Delta Engine"
cvd_len     = input.int(20, "CVD Lookback",                group=GV, minval=5, maxval=100)
cvd_slp_len = input.int(3,  "CVD Slope Sensitivity (Bars)", group=GV, minval=1, maxval=10)

const string GS = "🏛️ Structure Engine"
maj_piv_len = input.int   (40,  "Major Pivot Lookback", group=GS, minval=10, maxval=100)
min_piv_len = input.int   (10,  "Minor Pivot Lookback", group=GS, minval=3,  maxval=30)
sweep_wick  = input.float (0.3, "Min Sweep Wick Ratio", group=GS, minval=0.1, maxval=0.8, step=0.05)

const string GF = "⚙️ Filters"
chop_thresh = input.float(61.8, "Chop Index Threshold",    group=GF, minval=40.0, maxval=70.0, step=0.1)
disp_mult   = input.float(0.75, "Displacement ATR Mult",   group=GF, minval=0.3, maxval=3.0, step=0.05)
sig_gap     = input.int  (5,    "Min Bars Between Signals", group=GF, minval=1, maxval=50)
sess_gate   = input.bool (true, "London / NY Session Gate", group=GF)

const string GE = "⏰ Sessions (GST — Dubai, UTC+4)"
asia_s = input.session("0400-1000", "Asia (Accumulation)",   group=GE)
lon_s  = input.session("1100-1600", "London (Manipulation)", group=GE)
ny_s   = input.session("1630-2300", "New York (Distribution)", group=GE)

const string GD = "🎨 Dashboard Settings"
show_mtf   = input.bool(true, "Show MTF Bias Dashboard",    group=GD)
show_stat  = input.bool(true, "Show Action Status Panel",   group=GD)
dash_pos   = input.string("Top Right", "MTF Dashboard Position", options=["Top Right", "Bottom Right", "Top Left"], group=GD)
stat_pos   = input.string("Bottom Right", "Status Panel Position", options=["Bottom Left", "Top Left", "Bottom Right"], group=GD) // <-- UPDATED DEFAULT

posDash = dash_pos == "Top Right" ? position.top_right : dash_pos == "Bottom Right" ? position.bottom_right : position.top_left
posStat = stat_pos == "Bottom Left" ? position.bottom_left : stat_pos == "Bottom Right" ? position.bottom_right : position.top_left

// ════════════════════════════════════════════════════════════════════════════
// ■ CORE MATH & FUNCTIONS (No Visuals)
// ════════════════════════════════════════════════════════════════════════════
f_bull_sw(level) =>
    w = level - low
    r = math.max(high - low, 1e-10)
    low < level and close > level and close > open and (w / r) >= sweep_wick

f_bear_sw(level) =>
    w = high - level
    r = math.max(high - low, 1e-10)
    high > level and close < level and close < open and (w / r) >= sweep_wick

f_bias(tfInput) =>
    cClose = request.security(syminfo.tickerid, tfInput, close,             lookahead=barmerge.lookahead_off)
    cE20   = request.security(syminfo.tickerid, tfInput, ta.ema(close, 20), lookahead=barmerge.lookahead_off)
    cE50   = request.security(syminfo.tickerid, tfInput, ta.ema(close, 50), lookahead=barmerge.lookahead_off)
    (cClose > cE20 and cE20 > cE50) ? 1 : (cClose < cE20 and cE20 < cE50) ? -1 : 0

f_biasStr(v) => v ==  1 ? "▲ BULL" : v == -1 ? "▼ BEAR" : "— NEUT"
f_biasCol(v) => v ==  1 ? color.lime : v == -1 ? color.red : color.gray

atr_14 = ta.atr(14)
atr_1  = ta.atr(1)

chopRange = math.max(ta.highest(14) - ta.lowest(14), 1e-10)
chop      = 100.0 * math.log10(math.sum(atr_1, 14) / chopRange) / math.log10(14)
is_chop   = chop > chop_thresh
is_trnd   = not is_chop

lr_now   = ta.linreg(close, lr_len, 0)
lr_p1    = ta.linreg(close, lr_len, 1)
lr_slope = lr_now - lr_p1
lr_bull  = lr_slope > 0
lr_bear  = lr_slope < 0

ceAtr = ta.atr(ce_period)
var float ce_ls = na
var float ce_ss = na
var int   ce_d  = 1
lsCalc = ta.highest(ce_period) - ce_mult * ceAtr
ssCalc = ta.lowest(ce_period)  + ce_mult * ceAtr
ce_ls := close[1] < nz(ce_ls[1], low)  ? lsCalc : math.max(lsCalc, nz(ce_ls[1], low))
ce_ss := close[1] > nz(ce_ss[1], high) ? ssCalc : math.min(ssCalc, nz(ce_ss[1], high))
ce_d  := close > nz(ce_ss[1]) ? 1 : close < nz(ce_ls[1]) ? -1 : nz(ce_d[1], 1)
ce_bull = ce_d ==  1
ce_bear = ce_d == -1

delta    = close >= open ? volume : -volume
cvd      = math.sum(delta, cvd_len)
cvd_slp  = cvd - cvd[cvd_slp_len]
cvd_bull = cvd_slp > 0
cvd_bear = cvd_slp < 0

bull_disp = close > open and (close - open) > atr_14 * disp_mult
bear_disp = close < open and (open - close) > atr_14 * disp_mult

pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)

maj_ph = ta.pivothigh(high, maj_piv_len, maj_piv_len)
maj_pl = ta.pivotlow (low,  maj_piv_len, maj_piv_len)
min_ph = ta.pivothigh(high, min_piv_len, min_piv_len)
min_pl = ta.pivotlow (low,  min_piv_len, min_piv_len)

var float lmaj_ph = na
var float lmaj_pl = na
var float lmin_ph = na
var float lmin_pl = na

if not na(maj_ph)
    lmaj_ph := maj_ph
if not na(maj_pl)
    lmaj_pl := maj_pl
if not na(min_ph)
    lmin_ph := min_ph
if not na(min_pl)
    lmin_pl := min_pl

sw_pdl_b  = f_bull_sw(pdl)
sw_pdh_s  = f_bear_sw(pdh)
sw_mjpl_b = f_bull_sw(lmaj_pl)
sw_mjph_s = f_bear_sw(lmaj_ph)
sw_mipl_b = f_bull_sw(lmin_pl)
sw_miph_s = f_bear_sw(lmin_ph)

t1_bull  = sw_pdl_b  or sw_mjpl_b
t1_bear  = sw_pdh_s  or sw_mjph_s
any_bull = t1_bull   or sw_mipl_b
any_bear = t1_bear   or sw_miph_s

bias_D   = f_bias("D")
bias_4h  = f_bias("240")
bias_1h  = f_bias("60")
bias_15m = f_bias("15")
bias_5m  = f_bias("5")

bscore = (bias_D == 1 ? 1 : 0) + (bias_4h == 1 ? 1 : 0) + (bias_1h == 1 ? 1 : 0) + (bias_15m == 1 ? 1 : 0) + (bias_5m == 1 ? 1 : 0)
sscore = (bias_D == -1 ? 1 : 0) + (bias_4h == -1 ? 1 : 0) + (bias_1h == -1 ? 1 : 0) + (bias_15m == -1 ? 1 : 0) + (bias_5m == -1 ? 1 : 0)

f_inSess(s)  => not na(time(timeframe.period, s, "Asia/Dubai"))
in_asia = f_inSess(asia_s)
in_lon  = f_inSess(lon_s)
in_ny   = f_inSess(ny_s)
in_act  = in_lon or in_ny

amdPhase = in_asia ? "ACCUMULATION" : in_lon ? "MANIPULATION" : in_ny ? "DISTRIBUTION" : "OFF-HOURS"
amdCol   = in_asia ? color.gray : in_lon ? color.blue : in_ny ? color.orange : color.silver

var int lbull = -100
var int lbear = -100
var int lswingb = -100
var int lswings = -100

ok_b    = (bar_index - lbull) > sig_gap
ok_s    = (bar_index - lbear) > sig_gap
sess_ok = not sess_gate or in_act

bull_sweep_len = (bscore >= 4 and is_trnd) ? 2 : 4
bear_sweep_len = (sscore >= 4 and is_trnd) ? 2 : 4
is_scalp_bull = low <= ta.lowest(low[1], bull_sweep_len)
is_scalp_bear = high >= ta.highest(high[1], bear_sweep_len)
recent_scalp_bull = ta.barssince(is_scalp_bull) <= 6
recent_scalp_bear = ta.barssince(is_scalp_bear) <= 6

runaway_bull = (bscore >= 4) and ce_bull and is_trnd and bull_disp and (close[1] < open[1] or low <= low[1])
runaway_bear = (sscore >= 4) and ce_bear and is_trnd and bear_disp and (close[1] > open[1] or high >= high[1])

strongBuy  = t1_bull and lr_bull and ce_bull and cvd_bull and sess_ok and ok_b and (is_trnd or bull_disp)
strongSell = t1_bear and lr_bear and ce_bear and cvd_bear and sess_ok and ok_s and (is_trnd or bear_disp)

regBuy  = (any_bull or runaway_bull) and lr_bull and ce_bull and sess_ok and ok_b and (is_trnd or bull_disp) and not strongBuy
regSell = (any_bear or runaway_bear) and lr_bear and ce_bear and sess_ok and ok_s and (is_trnd or bear_disp) and not strongSell

weakBuy  = any_bull and (lr_bull or ce_bull) and is_trnd and ok_b and not strongBuy and not regBuy
weakSell = any_bear and (lr_bear or ce_bear) and is_trnd and ok_s and not strongSell and not regSell

chopBuy  = any_bull and is_chop and not bull_disp and ok_b
chopSell = any_bear and is_chop and not bear_disp and ok_s

is_macro_bull = (not na(pdl) and low <= pdl) or (not na(lmaj_pl) and low <= lmaj_pl)
is_macro_bear = (not na(pdh) and high >= pdh) or (not na(lmaj_ph) and high >= lmaj_ph)
recent_macro_bull = ta.barssince(is_macro_bull) <= 8
recent_macro_bear = ta.barssince(is_macro_bear) <= 8

raw_swing_bull = recent_macro_bull and close > open and lr_bull and (ce_bull or bull_disp)
raw_swing_bear = recent_macro_bear and close < open and lr_bear and (ce_bear or bear_disp)

swingBuy  = raw_swing_bull and (bar_index - lswingb > 20)
swingSell = raw_swing_bear and (bar_index - lswings > 20)

if swingBuy
    lswingb := bar_index
if swingSell
    lswings := bar_index
if strongBuy or regBuy or weakBuy or chopBuy
    lbull := bar_index
    lbear := -100
if strongSell or regSell or weakSell or chopSell
    lbear := bar_index
    lbull := -100

// ════════════════════════════════════════════════════════════════════════════
// ■ ACTION STATUS PANEL (Table Only)
// ════════════════════════════════════════════════════════════════════════════
var table stat = table.new(posStat, 1, 4,
     bgcolor      = color.new(color.black, 15),
     frame_color  = color.new(color.white, 20), frame_width  = 2,
     border_color = color.new(color.gray, 40),  border_width = 1)

if show_stat and barstate.islast
    string statusTxt = na
    color  statusCol = na

    if swingBuy
        statusTxt := "📈 SWING LONG"
        statusCol := color.blue
    else if swingSell
        statusTxt := "📉 SWING SHORT"
        statusCol := color.maroon
    else if strongBuy
        statusTxt := "💎 STRONG BUY NOW"
        statusCol := color.lime
    else if strongSell
        statusTxt := "💎 STRONG SELL NOW"
        statusCol := color.red
    else if regBuy
        statusTxt := "🟢 BUY"
        statusCol := color.lime
    else if regSell
        statusTxt := "🔴 SELL"
        statusCol := color.red
    else if weakBuy
        statusTxt := "⚠️ WEAK BUY"
        statusCol := color.new(color.lime, 30)
    else if weakSell
        statusTxt := "⚠️ WEAK SELL"
        statusCol := color.new(color.red, 30)
    else if chopBuy or chopSell or is_chop
        statusTxt := "⏸️ CHOP — WAIT"
        statusCol := color.gray
    else if in_act
        statusTxt := "🔍 SCANNING"
        statusCol := color.aqua
    else
        statusTxt := "💤 OFF HOURS"
        statusCol := color.gray

    ctxTxt  = is_chop ? "Regime: CHOPPY" : "Bias: " + str.tostring(bscore) + "↑ " + str.tostring(sscore) + "↓"
    sessTxt = (in_asia ? "ASIA" : in_lon ? "LONDON" : in_ny ? "NEW YORK" : "CLOSED") + "  •  " + amdPhase

    table.cell(stat, 0, 0, "APEX ALGO", text_color=color.yellow, text_size=size.small,  bgcolor=color.new(color.navy, 15))
    table.cell(stat, 0, 1, statusTxt,   text_color=statusCol,    text_size=size.normal, bgcolor=color.new(color.black, 5))
    table.cell(stat, 0, 2, sessTxt,     text_color=amdCol,       text_size=size.small,  bgcolor=color.new(color.black, 15))
    table.cell(stat, 0, 3, "Px " + str.tostring(close, format.mintick) + "  |  " + ctxTxt, text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 25))

// ════════════════════════════════════════════════════════════════════════════
// ■ MTF DASHBOARD (Table Only)
// ════════════════════════════════════════════════════════════════════════════
bgCell = color.new(color.black, 70)
bgHdr  = color.new(color.navy,  25)

var table dash = table.new(posDash, 2, 12,
     bgcolor      = color.new(color.black, 65),
     frame_color  = color.new(color.white, 40), frame_width  = 2,
     border_color = color.new(color.gray,  55), border_width = 1)

if show_mtf and barstate.islast
    table.cell(dash, 0, 0,  "APEX ALGO",    text_color=color.yellow, text_size=size.small, bgcolor=bgHdr)
    table.cell(dash, 1, 0,  "XAU/USD | 5m", text_color=color.white,  text_size=size.small, bgcolor=bgHdr)
    table.cell(dash, 0, 1,  "Daily",        text_color=color.silver, text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 1, 1,  f_biasStr(bias_D),    text_color=f_biasCol(bias_D),   text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 0, 2,  "4H",           text_color=color.silver, text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 1, 2,  f_biasStr(bias_4h),   text_color=f_biasCol(bias_4h),  text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 0, 3,  "1H",           text_color=color.silver, text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 1, 3,  f_biasStr(bias_1h),   text_color=f_biasCol(bias_1h),  text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 0, 4,  "15m",          text_color=color.silver, text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 1, 4,  f_biasStr(bias_15m),  text_color=f_biasCol(bias_15m), text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 0, 5,  "5m",           text_color=color.silver, text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 1, 5,  f_biasStr(bias_5m),   text_color=f_biasCol(bias_5m),  text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 0, 6,  "Align",        text_color=color.white,  text_size=size.small, bgcolor=bgHdr)
    table.cell(dash, 1, 6,  str.tostring(bscore) + "↑  " + str.tostring(sscore) + "↓", text_color=color.yellow, text_size=size.small, bgcolor=bgHdr)
    table.cell(dash, 0, 7,  "Regime",       text_color=color.white,  text_size=size.small, bgcolor=bgHdr)
    table.cell(dash, 1, 7,  is_chop ? "⚡ CHOPPY" : "✦ TRENDING", text_color=is_chop ? color.orange : color.lime, text_size=size.small, bgcolor=bgHdr)
    table.cell(dash, 0, 8,  "Chop %",       text_color=color.silver, text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 1, 8,  str.tostring(math.round(chop, 1)) + " / " + str.tostring(chop_thresh), text_color=is_chop ? color.orange : color.lime, text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 0, 9,  "CVD",          text_color=color.silver, text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 1, 9,  cvd_bull ? "▲ Inflow" : "▼ Outflow", text_color=cvd_bull ? color.lime : color.red, text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 0, 10, "Session",      text_color=color.silver, text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 1, 10, in_asia ? "Asia" : in_lon ? "London" : in_ny ? "New York" : "Closed", text_color=in_act ? color.lime : color.gray, text_size=size.small, bgcolor=bgCell)
    table.cell(dash, 0, 11, "AMD Phase",    text_color=color.white,  text_size=size.small, bgcolor=bgHdr)
    table.cell(dash, 1, 11, amdPhase,       text_color=amdCol,       text_size=size.small, bgcolor=bgHdr)

// ════════════════════════════════════════════════════════════════════════════
// ■ THE SCALE ANCHOR (Forces the indicator to stick to the main chart)
// ════════════════════════════════════════════════════════════════════════════
plot(close, color=color.new(color.black, 100), title="Scale Anchor", editable=false, display=display.none)

// ════════════════════════════════════════════════════════════════════════════
// ■ ALERTS (Invisible Background Logic)
// ════════════════════════════════════════════════════════════════════════════
alertcondition(strongBuy,  title="💎 STRONG BUY",  message="APEX V4.0 | XAU/USD 5m | 💎 STRONG BUY\n✅ Tier-1 Liq. Sweep  ✅ LinReg Bullish  ✅ CE Bullish  ✅ CVD Inflow  ✅ Session Active")
alertcondition(strongSell, title="💎 STRONG SELL", message="APEX V4.0 | XAU/USD 5m | 💎 STRONG SELL\n✅ Tier-1 Liq. Sweep  ✅ LinReg Bearish  ✅ CE Bearish  ✅ CVD Outflow  ✅ Session Active")
alertcondition(regBuy,  title="🟢 BUY",  message="APEX V4.0 | XAU/USD 5m | BUY\n✅ Liq. Sweep  ✅ LinReg Bullish  ✅ CE Bullish")
alertcondition(regSell, title="🔴 SELL", message="APEX V4.0 | XAU/USD 5m | SELL\n✅ Liq. Sweep  ✅ LinReg Bearish  ✅ CE Bearish")
````
