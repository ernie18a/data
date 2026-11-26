# TraxisLab - Confluence Engine

- url: https://www.tradingview.com/script/gPoOGKVh/
- type: indicator
- pine_id: PUB;c1a722c0c0a04d709506ca9d0abd0eba
- version: 1.0

## Description

TraxisLab — Confluence Engine

TraxisLab Confluence Engine is an advanced smart money / order flow style indicator designed to combine multiple high-value market signals into one clear confluence framework.

Instead of relying on a single trigger, this tool evaluates market structure, CVD-based pressure, delta divergence, VSA absorption/climax, liquidity sweeps, premium/discount zones, and Fair Value Gaps, then merges them into a dynamic bullish vs bearish confluence score.

The goal is simple: help traders identify areas where several independent factors align and filter out weaker, low-quality setups.

Key Features

1. Market Structure (BOS / CHoCH)
Detects Break of Structure (BOS) and Change of Character (CHoCH) using pivot-based logic.
Confirmed breaks can be filtered with CVD and volume validation to reduce false breakouts.

2. CVD / Delta Pressure Engine
Builds an internal Cumulative Volume Delta (CVD) model from candle structure and volume distribution.
This helps estimate whether aggressive buying or selling pressure is actually supporting price movement.

3. Delta Divergence Detection
Highlights bullish and bearish divergences between price slope and CVD slope.
Signals require confirmation across multiple bars and above-average volume, making them more selective.

4. VSA Absorption & Climax Detection
Uses effort vs result logic to identify:

Absorption: high effort, limited result
Climax bars: high effort with expanded spread

This helps spot potential exhaustion, hidden accumulation, or distribution.

5. Liquidity Sweep Recognition
Detects sweep behavior around pivot highs and lows:

Bullish sweep = downside liquidity taken, then reclaimed
Bearish sweep = upside liquidity taken, then rejected

Volume-enhanced sweeps are treated as higher quality signals.

6. Premium / Discount Zones
After confirmed structural movement, the script projects premium, equilibrium, and discount zones based on the recent range.
This adds context for whether price is trading in a favorable area for longs or shorts.

7. Fair Value Gap (FVG) Detection with Scoring
Finds bullish and bearish Fair Value Gaps and assigns a score based on:

Gap size
Relative volume
Location vs premium/discount
Proximity to recent structure shift

Only higher-quality FVGs above a user-defined threshold are displayed.

8. Confluence Scoring System
The core of the indicator is a bullish and bearish confluence score (0–100).
The score is built from multiple active components, including:

Delta divergence
BOS / CHoCH
Absorption / climax
Sweeps
FVG proximity
Premium / discount context
Directional pressure

This creates a more structured way to evaluate trade conditions instead of reacting to isolated signals.

9. Smart Labels and Tooltips
When the confluence score reaches the selected threshold, the script prints a signal label directly on the chart.
Tooltips explain why the setup triggered by listing the active reasons behind the score.

10. Dashboard + Alerts
Includes a compact dashboard showing the current state of:

Bullish / bearish confluence
Market structure
Pressure
Divergence
VSA status
Zone location
Active FVGs
Sweeps

Built-in alert conditions are available for:

Long / Short confluence
Strong Long / Strong Short
Divergences
Sweeps
CHoCH events
Absorption
Best Use Cases

This indicator is especially useful for traders who focus on:

Smart Money Concepts (SMC)
Market structure trading
Liquidity-based entries
Volume / delta confirmation
Intraday and swing confluence analysis

It works best as a decision-support tool, helping confirm context and setup quality rather than acting as a standalone “buy/sell button.”

Notes
The script uses an estimated internal delta model, not true bid/ask footprint data.
Signals are based on confluence logic and should always be used together with your own market reading and risk management.
Lower timeframes may produce more signals, while higher timeframes may provide cleaner structure.
Summary

TraxisLab Confluence Engine is built for traders who want more than single-condition indicators.
It combines structure, pressure, liquidity, imbalance, and effort/result concepts into one actionable framework to highlight areas where multiple market factors align.

## Source Code

````pine
//@version=5
indicator("TraxisLab — Confluence Engine", "TraxisLab CE", true,
     max_labels_count=500, max_lines_count=500, max_boxes_count=500,
     max_bars_back=5000)

// ═══════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════

grp_ms = "── Marktstruktur ──"
i_ms_lb = input.int(3, "Pivot Lookback", group=grp_ms, minval=2, maxval=15)
i_ms_show = input.bool(true, "BOS/CHoCH anzeigen", group=grp_ms)
i_ms_fake = input.bool(true, "Fake-Breakout Filter (CVD)", group=grp_ms)

grp_cvd = "── CVD / Delta ──"
i_cvd_show = input.bool(true, "Delta-Divergenz anzeigen", group=grp_cvd)
i_cvd_s = input.int(10, "Divergenz kurz (Bars)", group=grp_cvd, minval=3, maxval=30)
i_cvd_l = input.int(20, "Divergenz lang (Bars)", group=grp_cvd, minval=10, maxval=50)
i_cvd_conf = input.int(3, "Bestätigung (Bars)", group=grp_cvd, minval=2, maxval=8)

grp_vsa = "── Absorption / VSA ──"
i_vsa_on = input.bool(true, "Absorption/Climax anzeigen", group=grp_vsa)
i_vsa_len = input.int(20, "VSA MA Länge", group=grp_vsa, minval=5, maxval=50)
i_vsa_eff = input.float(1.5, "Effort-Schwelle (x MA)", group=grp_vsa, minval=1.1, maxval=3.0, step=0.1)
i_vsa_abs = input.float(0.7, "Absorption-Schwelle", group=grp_vsa, minval=0.3, maxval=1.0, step=0.05)
i_vsa_clx = input.float(1.5, "Climax-Spread (x MA)", group=grp_vsa, minval=1.1, maxval=3.0, step=0.1)
i_vsa_bars = input.bool(true, "VSA Kerzenfarben", group=grp_vsa)

grp_sw = "── Liquidity Sweeps ──"
i_sw_on = input.bool(true, "Sweeps anzeigen", group=grp_sw)
i_sw_lb = input.int(5, "Sweep Pivot Lookback", group=grp_sw, minval=3, maxval=15)

grp_pd = "── Premium / Discount ──"
i_pd_on = input.bool(true, "P/D Zonen anzeigen", group=grp_pd)
i_pd_opac = input.int(93, "Zonen-Transparenz", group=grp_pd, minval=80, maxval=97)

grp_fvg = "── Fair Value Gaps ──"
i_fvg_on = input.bool(true, "FVG anzeigen", group=grp_fvg)
i_fvg_score = input.int(30, "Min. FVG-Score", group=grp_fvg, minval=10, maxval=80)
i_fvg_max = input.int(10, "Max. FVG Zonen", group=grp_fvg, minval=3, maxval=20)

grp_cf = "── Confluence ──"
i_cf_on = input.bool(true, "Confluence-Scoring aktiv", group=grp_cf)
i_cf_min = input.int(40, "Min. Confluence-Score", group=grp_cf, minval=10, maxval=80, step=5)

grp_al = "── Smart Alerts ──"
i_al_min = input.int(50, "Min. Alert-Score", group=grp_al, minval=20, maxval=90, step=5)

grp_ui = "── Darstellung ──"
i_show_dash = input.bool(true, "Dashboard", group=grp_ui)
i_show_dbg = input.bool(false, "Debug", group=grp_ui)

grp_cl = "── Farben ──"
c_bull = input.color(#00e676, "Bullish", group=grp_cl)
c_bear = input.color(#ff1744, "Bearish", group=grp_cl)
c_bos = input.color(#2962FF, "BOS", group=grp_cl)
c_choch = input.color(#e040fb, "CHoCH", group=grp_cl)
c_absorb = input.color(#7B1FA2, "Absorption", group=grp_cl)
c_sweep = input.color(#FFD600, "Sweep", group=grp_cl)
c_fvg_b = input.color(#089981, "FVG Bull", group=grp_cl)
c_fvg_s = input.color(#f23645, "FVG Bear", group=grp_cl)

// Farb-Konstanten
c_gray = color.rgb(120, 123, 134)
c_dark = color.rgb(85, 85, 85)
c_yel = color.rgb(255, 214, 0)
c_bg = color.rgb(13, 13, 26)

// ═══════════════════════════════════════════
// CORE
// ═══════════════════════════════════════════

atr = ta.atr(14)
sa = nz(atr, close * 0.01)
ema20 = ta.ema(close, 20)
vol_ma = ta.sma(volume, i_vsa_len)

// ═══════════════════════════════════════════
// MODUL 1: CVD
// ═══════════════════════════════════════════

rng = high - low
buy_vol = rng > 0 ? volume * (close - low) / rng : volume * 0.5
sell_vol = volume - buy_vol
delta = buy_vol - sell_vol
var float cvd = 0.0
cvd := cvd + delta
pressure = ta.ema(delta, 14)

// ═══════════════════════════════════════════
// MODUL 2: DELTA-DIVERGENZ
// ═══════════════════════════════════════════

cvd_slope_s = i_cvd_s > 0 ? (cvd - cvd[i_cvd_s]) / i_cvd_s : 0.0
prc_slope_s = i_cvd_s > 0 ? (close - close[i_cvd_s]) / i_cvd_s : 0.0
cvd_slope_l = i_cvd_l > 0 ? (cvd - cvd[i_cvd_l]) / i_cvd_l : 0.0
prc_slope_l = i_cvd_l > 0 ? (close - close[i_cvd_l]) / i_cvd_l : 0.0

div_bear_raw = prc_slope_s > 0 and cvd_slope_s < 0
div_bull_raw = prc_slope_s < 0 and cvd_slope_s > 0

var int div_bear_count = 0
var int div_bull_count = 0
div_bear_count := div_bear_raw ? div_bear_count + 1 : 0
div_bull_count := div_bull_raw ? div_bull_count + 1 : 0

vol_above = volume > vol_ma

div_bear_conf = div_bear_count >= i_cvd_conf and vol_above
div_bull_conf = div_bull_count >= i_cvd_conf and vol_above
div_bear_trigger = div_bear_conf and div_bear_count == i_cvd_conf
div_bull_trigger = div_bull_conf and div_bull_count == i_cvd_conf

plotshape(i_cvd_show and div_bear_trigger, "Div Bear", shape.triangledown, location.abovebar, color.new(c_bear, 20), size=size.small)
plotshape(i_cvd_show and div_bull_trigger, "Div Bull", shape.triangleup, location.belowbar, color.new(c_bull, 20), size=size.small)

// ═══════════════════════════════════════════
// MODUL 3: BOS / CHoCH
// ═══════════════════════════════════════════

var float ms_hi = na
var float ms_lo = na
var int ms_hi_bar = 0
var int ms_lo_bar = 0
var int ms_trend = 0

ms_pvh = ta.pivothigh(high, i_ms_lb, 1)
ms_pvl = ta.pivotlow(low, i_ms_lb, 1)

if not na(ms_pvh)
    ms_hi := ms_pvh
    ms_hi_bar := bar_index - 1

if not na(ms_pvl)
    ms_lo := ms_pvl
    ms_lo_bar := bar_index - 1

bos_bull = not na(ms_hi) and close > ms_hi and close[1] <= nz(ms_hi)
bos_bear = not na(ms_lo) and close < ms_lo and close[1] >= nz(ms_lo)

choch_bull = ms_trend == -1 and bos_bull
choch_bear = ms_trend == 1 and bos_bear

if bos_bull
    ms_trend := 1
if bos_bear
    ms_trend := -1

cvd_3bar = cvd - cvd[3]
cvd_confirms_bull = cvd_3bar > 0
cvd_confirms_bear = cvd_3bar < 0
vol_confirms = volume > vol_ma * 1.3

real_bos_bull = bos_bull and cvd_confirms_bull and vol_confirms
real_bos_bear = bos_bear and cvd_confirms_bear and vol_confirms
fake_bos_bull = bos_bull and not cvd_confirms_bull and i_ms_fake
fake_bos_bear = bos_bear and not cvd_confirms_bear and i_ms_fake

if bos_bull
    ms_hi := na
if bos_bear
    ms_lo := na

// BOS/CHoCH Labels
color ms_col_bull = choch_bull ? c_choch : c_bos
color ms_col_bear = choch_bear ? c_choch : c_bos
string ms_txt_bull = choch_bull ? "CHoCH ▲" : "BOS ▲"
string ms_txt_bear = choch_bear ? "CHoCH ▼" : "BOS ▼"

if i_ms_show and real_bos_bull
    label.new(bar_index, low - sa * 0.4, ms_txt_bull, xloc.bar_index, yloc.price, ms_col_bull, label.style_label_up, color.white, size.tiny, text.align_center, tooltip="Bestätigter Bruch · CVD ✓ Vol ✓")

if i_ms_show and real_bos_bear
    label.new(bar_index, high + sa * 0.4, ms_txt_bear, xloc.bar_index, yloc.price, ms_col_bear, label.style_label_down, color.white, size.tiny, text.align_center, tooltip="Bestätigter Bruch · CVD ✓ Vol ✓")

if i_ms_show and fake_bos_bull
    label.new(bar_index, low - sa * 0.3, "FAKE?", xloc.bar_index, yloc.price, color.new(c_gray, 30), label.style_label_up, c_gray, size.tiny, text.align_center, tooltip="Fake-Breakout · CVD ✗")

if i_ms_show and fake_bos_bear
    label.new(bar_index, high + sa * 0.3, "FAKE?", xloc.bar_index, yloc.price, color.new(c_gray, 30), label.style_label_down, c_gray, size.tiny, text.align_center, tooltip="Fake-Breakout · CVD ✗")

// ═══════════════════════════════════════════
// MODUL 4: ABSORPTION / CLIMAX
// ═══════════════════════════════════════════

sprd = high - low
sprd_ma = ta.sma(sprd, i_vsa_len)
effort = vol_ma > 0 ? volume / vol_ma : 1.0
result_vsa = sprd_ma > 0 ? sprd / sprd_ma : 1.0

is_absorption = effort >= i_vsa_eff and result_vsa <= i_vsa_abs
is_climax = effort >= i_vsa_eff and result_vsa >= i_vsa_clx

abs_bull = is_absorption and close < ema20
abs_bear = is_absorption and close > ema20
clx_top = is_climax and close > open and close > ema20
clx_bot = is_climax and close < open and close < ema20

// Kerzenfarbe
color vsa_col = na
if i_vsa_bars
    if is_absorption
        vsa_col := c_absorb
    else if clx_top
        vsa_col := color.new(c_bull, 20)
    else if clx_bot
        vsa_col := color.new(c_bear, 20)

barcolor(vsa_col)

plotshape(i_vsa_on and abs_bull, "Abs Bull", shape.square, location.belowbar, color.new(c_absorb, 30), size=size.tiny)
plotshape(i_vsa_on and abs_bear, "Abs Bear", shape.square, location.abovebar, color.new(c_absorb, 30), size=size.tiny)
plotshape(i_vsa_on and clx_top, "Climax Top", shape.xcross, location.abovebar, color.new(c_bear, 20), size=size.tiny)
plotshape(i_vsa_on and clx_bot, "Climax Bot", shape.xcross, location.belowbar, color.new(c_bull, 20), size=size.tiny)

// ═══════════════════════════════════════════
// MODUL 5: LIQUIDITY SWEEP
// ═══════════════════════════════════════════

var float sw_hi = na
var float sw_lo = na

sw_pvh = ta.pivothigh(high, i_sw_lb, 1)
sw_pvl = ta.pivotlow(low, i_sw_lb, 1)

if not na(sw_pvh)
    sw_hi := sw_pvh
if not na(sw_pvl)
    sw_lo := sw_pvl

sweep_bull = not na(sw_lo) and low < sw_lo and close > sw_lo
sweep_bear = not na(sw_hi) and high > sw_hi and close < sw_hi

sweep_bull_vol = sweep_bull and volume > vol_ma * 1.2
sweep_bear_vol = sweep_bear and volume > vol_ma * 1.2

if sweep_bull
    sw_lo := na
if sweep_bear
    sw_hi := na

plotshape(i_sw_on and sweep_bull_vol, "Sweep ▲", shape.diamond, location.belowbar, c_sweep, size=size.small)
plotshape(i_sw_on and sweep_bear_vol, "Sweep ▼", shape.diamond, location.abovebar, c_sweep, size=size.small)
plotshape(i_sw_on and sweep_bull and not sweep_bull_vol, "Sweep ▲ w", shape.diamond, location.belowbar, color.new(c_sweep, 60), size=size.tiny)
plotshape(i_sw_on and sweep_bear and not sweep_bear_vol, "Sweep ▼ w", shape.diamond, location.abovebar, color.new(c_sweep, 60), size=size.tiny)

// ═══════════════════════════════════════════
// MODUL 6: PREMIUM / DISCOUNT
// ═══════════════════════════════════════════

var float pd_hi = na
var float pd_lo = na
var box pd_prem_box = na
var box pd_disc_box = na
var line pd_eq_line = na

if real_bos_bull or real_bos_bear
    pd_hi := ta.highest(high, 20)
    pd_lo := ta.lowest(low, 20)

float pd_eq = na
if not na(pd_hi) and not na(pd_lo)
    pd_eq := (pd_hi + pd_lo) / 2

in_premium = not na(pd_eq) and close > pd_eq
in_discount = not na(pd_eq) and close < pd_eq

if i_pd_on and barstate.islast and not na(pd_hi) and not na(pd_lo) and not na(pd_eq)
    if not na(pd_prem_box)
        box.delete(pd_prem_box)
    if not na(pd_disc_box)
        box.delete(pd_disc_box)
    if not na(pd_eq_line)
        line.delete(pd_eq_line)
    int lb = math.min(50, bar_index)
    pd_prem_box := box.new(bar_index - lb, pd_hi, bar_index + 5, pd_eq, border_color=color.new(c_bear, 80), bgcolor=color.new(c_bear, i_pd_opac))
    pd_disc_box := box.new(bar_index - lb, pd_eq, bar_index + 5, pd_lo, border_color=color.new(c_bull, 80), bgcolor=color.new(c_bull, i_pd_opac))
    pd_eq_line := line.new(bar_index - lb, pd_eq, bar_index + 5, pd_eq, color=color.new(c_gray, 50), width=1, style=line.style_dashed)

// ═══════════════════════════════════════════
// MODUL 7: FVG MIT SCORING
// ═══════════════════════════════════════════

var array<box> fvg_boxes = array.new_box(0)
var array<float> fvg_top_a = array.new_float(0)
var array<float> fvg_bot_a = array.new_float(0)
var array<bool> fvg_bull_a = array.new_bool(0)
var array<int> fvg_score_a = array.new_int(0)
var array<int> fvg_bar_a = array.new_int(0)

if i_fvg_on
    bool bull_fvg = low > high[2]
    bool bear_fvg = high < low[2]

    if bull_fvg
        float ftop = low
        float fbot = high[2]
        float gap_sz = ftop - fbot
        int sc = 10
        if gap_sz > sa * 0.3
            sc += 15
        else if gap_sz > sa * 0.15
            sc += 8
        if volume[1] > vol_ma * 1.5
            sc += 20
        if not na(pd_eq) and fbot < pd_eq
            sc += 15
        bool bos_near = real_bos_bull or (bar_index - ms_hi_bar < 5 and ms_trend == 1)
        if bos_near
            sc += 25
        if sc >= i_fvg_score
            int opac2 = 85 - math.min(20, sc / 5)
            color bc2 = color.new(c_fvg_b, opac2)
            box bx2 = box.new(bar_index - 1, ftop, bar_index + 30, fbot, border_color=color.new(c_fvg_b, 70), bgcolor=bc2, border_width=0)
            array.push(fvg_boxes, bx2)
            array.push(fvg_top_a, ftop)
            array.push(fvg_bot_a, fbot)
            array.push(fvg_bull_a, true)
            array.push(fvg_score_a, sc)
            array.push(fvg_bar_a, bar_index)

    if bear_fvg
        float ftop2 = low[2]
        float fbot2 = high
        float gap_sz2 = ftop2 - fbot2
        int sc2 = 10
        if gap_sz2 > sa * 0.3
            sc2 += 15
        else if gap_sz2 > sa * 0.15
            sc2 += 8
        if volume[1] > vol_ma * 1.5
            sc2 += 20
        if not na(pd_eq) and ftop2 > pd_eq
            sc2 += 15
        bool bos_near3 = real_bos_bear or (bar_index - ms_lo_bar < 5 and ms_trend == -1)
        if bos_near3
            sc2 += 25
        if sc2 >= i_fvg_score
            int opac3 = 85 - math.min(20, sc2 / 5)
            color bc3 = color.new(c_fvg_s, opac3)
            box bx3 = box.new(bar_index - 1, ftop2, bar_index + 30, fbot2, border_color=color.new(c_fvg_s, 70), bgcolor=bc3, border_width=0)
            array.push(fvg_boxes, bx3)
            array.push(fvg_top_a, ftop2)
            array.push(fvg_bot_a, fbot2)
            array.push(fvg_bull_a, false)
            array.push(fvg_score_a, sc2)
            array.push(fvg_bar_a, bar_index)

// FVG Hit + Cleanup
if array.size(fvg_boxes) > 0
    for i = array.size(fvg_boxes) - 1 to 0
        if i >= array.size(fvg_boxes)
            break
        float ft = array.get(fvg_top_a, i)
        float fb = array.get(fvg_bot_a, i)
        bool ib = array.get(fvg_bull_a, i)
        int age = bar_index - array.get(fvg_bar_a, i)
        bool filled = (ib and low <= fb) or (not ib and high >= ft)
        bool old = age > 100
        if filled or old
            box.delete(array.get(fvg_boxes, i))
            array.remove(fvg_boxes, i)
            array.remove(fvg_top_a, i)
            array.remove(fvg_bot_a, i)
            array.remove(fvg_bull_a, i)
            array.remove(fvg_score_a, i)
            array.remove(fvg_bar_a, i)
        else
            box.set_right(array.get(fvg_boxes, i), bar_index + 5)

while array.size(fvg_boxes) > i_fvg_max
    if array.size(fvg_boxes) == 0
        break
    box.delete(array.shift(fvg_boxes))
    array.shift(fvg_top_a)
    array.shift(fvg_bot_a)
    array.shift(fvg_bull_a)
    array.shift(fvg_score_a)
    array.shift(fvg_bar_a)

// Preis nahe FVG?
near_fvg_bull = false
near_fvg_bear = false
best_fvg_score = 0

if array.size(fvg_boxes) > 0
    for i = 0 to array.size(fvg_boxes) - 1
        float ft2 = array.get(fvg_top_a, i)
        float fb2 = array.get(fvg_bot_a, i)
        bool ib2 = array.get(fvg_bull_a, i)
        int sc3 = array.get(fvg_score_a, i)
        if math.abs(close - (ft2 + fb2) / 2) < sa * 0.5
            if ib2
                near_fvg_bull := true
            else
                near_fvg_bear := true
            best_fvg_score := math.max(best_fvg_score, sc3)

// ═══════════════════════════════════════════
// MODUL 8: CONFLUENCE SCORING
// ═══════════════════════════════════════════

cf_bull = 0
cf_bear = 0
string cf_reasons_b = ""
string cf_reasons_s = ""

if div_bull_conf
    cf_bull += 20
    cf_reasons_b := cf_reasons_b + "DIV "
if div_bear_conf
    cf_bear += 20
    cf_reasons_s := cf_reasons_s + "DIV "
if real_bos_bull
    cf_bull += 20
    cf_reasons_b := cf_reasons_b + "BOS "
if choch_bull
    cf_bull += 25
    cf_reasons_b := cf_reasons_b + "CHoCH "
if real_bos_bear
    cf_bear += 20
    cf_reasons_s := cf_reasons_s + "BOS "
if choch_bear
    cf_bear += 25
    cf_reasons_s := cf_reasons_s + "CHoCH "
if abs_bull
    cf_bull += 15
    cf_reasons_b := cf_reasons_b + "ABS "
if abs_bear
    cf_bear += 15
    cf_reasons_s := cf_reasons_s + "ABS "
if sweep_bull_vol
    cf_bull += 20
    cf_reasons_b := cf_reasons_b + "SWEEP "
if sweep_bear_vol
    cf_bear += 20
    cf_reasons_s := cf_reasons_s + "SWEEP "
if near_fvg_bull
    cf_bull += 15
    cf_reasons_b := cf_reasons_b + "FVG "
if near_fvg_bear
    cf_bear += 15
    cf_reasons_s := cf_reasons_s + "FVG "
if in_discount
    cf_bull += 10
    cf_reasons_b := cf_reasons_b + "DISC "
if in_premium
    cf_bear += 10
    cf_reasons_s := cf_reasons_s + "PREM "
if clx_bot
    cf_bull += 10
    cf_reasons_b := cf_reasons_b + "CLX "
if clx_top
    cf_bear += 10
    cf_reasons_s := cf_reasons_s + "CLX "
if pressure > 0
    cf_bull += 5
if pressure < 0
    cf_bear += 5

cf_bull := math.min(100, cf_bull)
cf_bear := math.min(100, cf_bear)

// ═══════════════════════════════════════════
// CONFLUENCE LABELS
// ═══════════════════════════════════════════

var int last_cf_b = -9999
var int last_cf_s = -9999

cf_cd_b = bar_index - last_cf_b > 5
cf_cd_s = bar_index - last_cf_s > 5
in_recent = bar_index >= last_bar_index - 200

cf_sig_b = i_cf_on and cf_bull >= i_cf_min and cf_cd_b and in_recent
cf_sig_s = i_cf_on and cf_bear >= i_cf_min and cf_cd_s and in_recent

// Tooltip-Texte vorab
string cf_pr_b = pressure > 0 ? "Kaufdruck ✓" : "Kein Druck ✗"
string cf_pr_s = pressure < 0 ? "Verkaufsdruck ✓" : "Kein Druck ✗"
string cf_zn_b = in_discount ? "Discount ✓" : in_premium ? "Premium ✗" : "Neutral"
string cf_zn_s = in_premium ? "Premium ✓" : in_discount ? "Discount ✗" : "Neutral"
string cf_fvg_b = near_fvg_bull ? "Score " + str.tostring(best_fvg_score) : "—"
string cf_fvg_s = near_fvg_bear ? "Score " + str.tostring(best_fvg_score) : "—"
string cf_tr_b = ms_trend == 1 ? "Bullish ✓" : ms_trend == -1 ? "Bearish ✗" : "Neutral"
string cf_tr_s = ms_trend == -1 ? "Bearish ✓" : ms_trend == 1 ? "Bullish ✗" : "Neutral"

if cf_sig_b
    last_cf_b := bar_index
    bool is_str_b = cf_bull >= 60
    string pf_b = is_str_b ? "⭐ STRONG " : ""
    string tt_b = "═══════════════════\n"
    tt_b := tt_b + "  " + pf_b + "LONG\n"
    tt_b := tt_b + "  Score: " + str.tostring(cf_bull) + "/100\n"
    tt_b := tt_b + "═══════════════════\n"
    tt_b := tt_b + "  " + cf_reasons_b + "\n"
    tt_b := tt_b + "───────────────────\n"
    tt_b := tt_b + "  CVD: " + cf_pr_b + "\n"
    tt_b := tt_b + "  Zone: " + cf_zn_b + "\n"
    tt_b := tt_b + "  FVG: " + cf_fvg_b + "\n"
    tt_b := tt_b + "  Trend: " + cf_tr_b + "\n"
    tt_b := tt_b + "═══════════════════"
    color col_b = is_str_b ? c_bull : color.new(c_bull, 30)
    string sz_b = is_str_b ? size.normal : size.small
    label.new(bar_index, low - sa * 0.5, "▲ " + str.tostring(cf_bull), xloc.bar_index, yloc.price, col_b, label.style_label_up, color.white, sz_b, text.align_center, tt_b)

if cf_sig_s
    last_cf_s := bar_index
    bool is_str_s = cf_bear >= 60
    string pf_s = is_str_s ? "⭐ STRONG " : ""
    string tt_s = "═══════════════════\n"
    tt_s := tt_s + "  " + pf_s + "SHORT\n"
    tt_s := tt_s + "  Score: " + str.tostring(cf_bear) + "/100\n"
    tt_s := tt_s + "═══════════════════\n"
    tt_s := tt_s + "  " + cf_reasons_s + "\n"
    tt_s := tt_s + "───────────────────\n"
    tt_s := tt_s + "  CVD: " + cf_pr_s + "\n"
    tt_s := tt_s + "  Zone: " + cf_zn_s + "\n"
    tt_s := tt_s + "  FVG: " + cf_fvg_s + "\n"
    tt_s := tt_s + "  Trend: " + cf_tr_s + "\n"
    tt_s := tt_s + "═══════════════════"
    color col_s = is_str_s ? c_bear : color.new(c_bear, 30)
    string sz_s = is_str_s ? size.normal : size.small
    label.new(bar_index, high + sa * 0.5, "▼ " + str.tostring(cf_bear), xloc.bar_index, yloc.price, col_s, label.style_label_down, color.white, sz_s, text.align_center, tt_s)

// Divergenz BG
bgcolor(div_bear_conf ? color.new(c_bear, 94) : na, title="Bear Div BG")
bgcolor(div_bull_conf ? color.new(c_bull, 94) : na, title="Bull Div BG")

// ═══════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════

color cf_bull_col = cf_bull >= 60 ? c_bull : cf_bull >= 40 ? c_yel : c_dark
color cf_bear_col = cf_bear >= 60 ? c_bear : cf_bear >= 40 ? c_yel : c_dark
string tr_txt = ms_trend == 1 ? "BULL" : ms_trend == -1 ? "BEAR" : "—"
color tr_col = ms_trend == 1 ? c_bull : ms_trend == -1 ? c_bear : c_gray
string p_txt = pressure > 0 ? "KAUF" : pressure < 0 ? "VERKAUF" : "NEUTRAL"
color p_col = pressure > 0 ? c_bull : pressure < 0 ? c_bear : c_gray
string dv_txt = div_bear_conf ? "BEAR ⚠" : div_bull_conf ? "BULL ⚠" : "—"
color dv_col = div_bear_conf ? c_bear : div_bull_conf ? c_bull : c_dark
string vsa_txt = is_absorption ? "ABSORB" : is_climax ? "CLIMAX" : "—"
color vsa_d_col = is_absorption ? c_absorb : is_climax ? c_yel : c_dark
string z_txt = in_premium ? "PREMIUM" : in_discount ? "DISCOUNT" : "NEUTRAL"
color z_col = in_premium ? c_bear : in_discount ? c_bull : c_gray
int fvg_n = array.size(fvg_boxes)
color fvg_c_col = fvg_n > 0 ? c_yel : c_dark
string fvg_nr_txt = near_fvg_bull ? "NAHE ▲" : near_fvg_bear ? "NAHE ▼" : ""
color fvg_nr_col = near_fvg_bull ? c_bull : near_fvg_bear ? c_bear : c_dark
color eff_col = effort > 1.5 ? c_yel : c_dark
color res_col = result_vsa < 0.7 ? c_absorb : c_dark
string sw_txt = sweep_bull_vol ? "BULL ✓" : sweep_bear_vol ? "BEAR ✓" : sweep_bull ? "bull" : sweep_bear ? "bear" : "—"
color sw_col = sweep_bull_vol ? c_bull : sweep_bear_vol ? c_bear : c_dark

var table tb = table.new(position.bottom_right, 3, 10, bgcolor=color.new(c_bg, 5), border_color=color.new(c_gray, 80), border_width=1)

if i_show_dash and barstate.islast
    table.cell(tb, 0, 0, "TraxisLab CE", text_color=color.white, text_size=size.tiny)
    table.merge_cells(tb, 0, 0, 2, 0)

    table.cell(tb, 0, 1, "Confluence", text_color=c_gray, text_size=size.tiny)
    table.cell(tb, 1, 1, "▲" + str.tostring(cf_bull), text_color=cf_bull_col, text_size=size.tiny)
    table.cell(tb, 2, 1, "▼" + str.tostring(cf_bear), text_color=cf_bear_col, text_size=size.tiny)

    table.cell(tb, 0, 2, "Struktur", text_color=c_gray, text_size=size.tiny)
    table.cell(tb, 1, 2, tr_txt, text_color=tr_col, text_size=size.tiny)
    table.cell(tb, 2, 2, "", text_color=c_gray, text_size=size.tiny)

    table.cell(tb, 0, 3, "Pressure", text_color=c_gray, text_size=size.tiny)
    table.cell(tb, 1, 3, p_txt, text_color=p_col, text_size=size.tiny)
    table.cell(tb, 2, 3, "", text_color=c_gray, text_size=size.tiny)

    table.cell(tb, 0, 4, "Divergenz", text_color=c_gray, text_size=size.tiny)
    table.cell(tb, 1, 4, dv_txt, text_color=dv_col, text_size=size.tiny)
    table.cell(tb, 2, 4, "", text_color=c_gray, text_size=size.tiny)

    table.cell(tb, 0, 5, "VSA", text_color=c_gray, text_size=size.tiny)
    table.cell(tb, 1, 5, vsa_txt, text_color=vsa_d_col, text_size=size.tiny)
    table.cell(tb, 2, 5, "", text_color=c_gray, text_size=size.tiny)

    table.cell(tb, 0, 6, "Zone", text_color=c_gray, text_size=size.tiny)
    table.cell(tb, 1, 6, z_txt, text_color=z_col, text_size=size.tiny)
    table.cell(tb, 2, 6, "", text_color=c_gray, text_size=size.tiny)

    table.cell(tb, 0, 7, "FVG", text_color=c_gray, text_size=size.tiny)
    table.cell(tb, 1, 7, str.tostring(fvg_n) + " aktiv", text_color=fvg_c_col, text_size=size.tiny)
    table.cell(tb, 2, 7, fvg_nr_txt, text_color=fvg_nr_col, text_size=size.tiny)

    table.cell(tb, 0, 8, "Effort", text_color=c_gray, text_size=size.tiny)
    table.cell(tb, 1, 8, str.tostring(effort, "#.0") + "×", text_color=eff_col, text_size=size.tiny)
    table.cell(tb, 2, 8, "Res:" + str.tostring(result_vsa, "#.0") + "×", text_color=res_col, text_size=size.tiny)

    table.cell(tb, 0, 9, "Sweep", text_color=c_gray, text_size=size.tiny)
    table.cell(tb, 1, 9, sw_txt, text_color=sw_col, text_size=size.tiny)
    table.cell(tb, 2, 9, "", text_color=c_gray, text_size=size.tiny)

// Debug
plot(i_show_dbg ? pressure : na, "Pressure", c_yel, display=display.pane)
plot(i_show_dbg ? float(cf_bull) : na, "CF Bull", c_bull, display=display.pane)
plot(i_show_dbg ? float(cf_bear) : na, "CF Bear", c_bear, display=display.pane)
plot(i_show_dbg ? cvd : na, "CVD", c_bos, display=display.pane)

// ═══════════════════════════════════════════
// SMART ALERTS
// ═══════════════════════════════════════════

alert_bull = cf_bull >= i_al_min and cf_cd_b
alert_bear = cf_bear >= i_al_min and cf_cd_s

alertcondition(alert_bull and cf_bull >= 60, "Strong Long", "TraxisLab: STRONG LONG")
alertcondition(alert_bear and cf_bear >= 60, "Strong Short", "TraxisLab: STRONG SHORT")
alertcondition(alert_bull, "Long", "TraxisLab: LONG Confluence")
alertcondition(alert_bear, "Short", "TraxisLab: SHORT Confluence")
alertcondition(div_bear_trigger, "Bear Divergenz", "TraxisLab: CVD Bear Divergenz")
alertcondition(div_bull_trigger, "Bull Divergenz", "TraxisLab: CVD Bull Divergenz")
alertcondition(sweep_bull_vol, "Bull Sweep", "TraxisLab: Bull Sweep")
alertcondition(sweep_bear_vol, "Bear Sweep", "TraxisLab: Bear Sweep")
alertcondition(choch_bull, "CHoCH Bull", "TraxisLab: CHoCH Bull")
alertcondition(choch_bear, "CHoCH Bear", "TraxisLab: CHoCH Bear")
alertcondition(is_absorption, "Absorption", "TraxisLab: Absorption")
````
