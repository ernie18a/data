# TraxisLab - Alpha Engine

- url: https://www.tradingview.com/script/iuusGCLG/
- type: indicator
- pine_id: PUB;ace94ac8ffd043cf9015340bdbb76af9
- version: 1.0

## Description

TraxisLab Alpha Engine is a confluence-based trading overlay designed to combine trend quality, volatility compression, and liquidity-driven momentum into one clean decision framework.

The script uses two core components:

Trend-Quality & Volatility Squeeze Engine
VWMO — Volume-Weighted Momentum Oscillator

A confluence signal is only generated when both components confirm the same market direction.

Core Concept

Alpha Engine is built to help traders identify moments where trend direction, volatility expansion, and momentum alignment come together.

Instead of relying on a single indicator, the script waits for confirmation between:

HMA-based trend direction
ATR-based volatility squeeze conditions
Volume-weighted momentum behavior
Price position relative to the HMA

This makes the indicator useful for filtering potential trend continuation, squeeze breakout, and momentum confirmation setups.

Trend-Quality & Squeeze Engine

The trend engine is based on a Hull Moving Average with ATR-normalized slope measurement.

It classifies the market into three main states:

Bullish trend
Bearish trend
Flat / squeeze condition

The HMA slope is measured as a percentage of ATR, which helps normalize trend strength across different assets and timeframes.

When volatility contracts, the indicator highlights a squeeze condition. Once the squeeze releases with directional slope confirmation, the script marks a potential bullish or bearish squeeze breakout.

VWMO — Volume-Weighted Momentum Oscillator

The second component is the VWMO, a custom volume-weighted momentum oscillator displayed in a separate pane.

VWMO measures price momentum while weighting it by relative volume. The result is normalized on a 0–100 scale, similar to an RSI-style oscillator:

Above 50 = bullish momentum bias
Below 50 = bearish momentum bias
Above overbought zone = extended upside momentum
Below oversold zone = extended downside momentum

The oscillator includes smoothing to reduce noise while still reacting to momentum shifts.

Fixed & Dynamic OB/OS Zones

VWMO supports three zone modes:

Fixed
Uses standard overbought and oversold levels, such as 70 / 30.

Dynamic
Uses adaptive zones based on the oscillator’s mean and standard deviation.

Fixed + Dynamic
Combines both fixed and adaptive levels for broader momentum-zone detection.

Optional arrows can be displayed when VWMO enters overbought or oversold areas.

Confluence Signal Logic

The indicator can display confluence labels directly on the chart:

▲ Confluence Buy
▼ Confluence Sell

A buy signal requires bullish confirmation from both the trend engine and VWMO, with price trading above the HMA.

A sell signal requires bearish confirmation from both the trend engine and VWMO, with price trading below the HMA.

A cooldown filter helps reduce repeated signals during the same move.

Visual Features

The script includes several clean visual elements:

Colored HMA based on trend state
ATR-based upper and lower bands
Squeeze background highlighting
Bullish and bearish squeeze breakout markers
VWMO oscillator pane
Fixed and dynamic overbought / oversold levels
OB/OS entry arrows
Confluence buy and sell labels
Compact information panel
Information Panel

The built-in panel provides a quick overview of the current market state:

Trend direction
Volatility state
HMA slope
VWMO value
Momentum zone
Active OB/OS levels
Current confluence signal

This makes it easier to read the indicator at a glance without overloading the chart.

Alerts

The script includes alert conditions for:

Confluence Buy
Confluence Sell
Bullish Squeeze Breakout
Bearish Squeeze Breakout
VWMO enters Overbought
VWMO enters Oversold
VWMO exits Oversold
VWMO exits Overbought

These alerts can be used to monitor trend and momentum shifts without constantly watching the chart.

How to Use

Use Alpha Engine as a confluence and confirmation tool.

Typical use cases include:

Confirming trend continuation setups
Detecting volatility squeeze breakouts
Monitoring momentum shifts with VWMO
Filtering trades using both trend and oscillator alignment
Avoiding weak setups where only one component confirms

The strongest signals usually occur when price exits a squeeze, HMA slope turns directional, VWMO confirms momentum, and price remains on the correct side of the HMA.

Notes

This indicator does not include take-profit, stop-loss, or position management logic.
It is designed as an analytical overlay and confirmation engine.

VWMO is a custom oscillator and may behave differently from standard RSI or stochastic indicators. The dynamic zones are adaptive and may vary depending on market conditions and lookback settings.

Disclaimer

This indicator is for educational and analytical purposes only.
It does not provide financial advice, trading recommendations, or guaranteed results. Always use proper risk management and perform your own analysis before making any trading decision.

## Source Code

````pine
//@version=5
// ╔═══════════════════════════════════════════════════════════════════════════╗
// ║  TRAXISLAB — ALPHA ENGINE v1.2 (VWMO FIX)                                ║
// ║  Ind.1: Trend-Quality & Volatility Squeeze (HMA + ATR)                   ║
// ║  Ind.2: Liquidity-Driven Momentum Oscillator (VWMO) — FIXED              ║
// ║  Confluence: Signal nur wenn BEIDE bestätigen                            ║
// ╚═══════════════════════════════════════════════════════════════════════════╝
indicator("TraxisLab — Alpha Engine", "TraxisLab AE", true, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════
// │ 1  INPUTS                                                                │
// ═══════════════════════════════════════════════════════════════════════════

grp_tq = "⟐  Trend-Quality & Squeeze"
i_hma_len    = input.int(20, "HMA Length", group=grp_tq, minval=5, maxval=100)
i_atr_len_sq = input.int(14, "ATR Length", group=grp_tq, minval=5, maxval=50)
i_sq_mult    = input.float(1.5, "Squeeze Band (ATR×)", group=grp_tq, minval=0.5, maxval=4.0, step=0.1)
i_sq_narrow  = input.float(0.75, "Squeeze Threshold", group=grp_tq, minval=0.3, maxval=1.5, step=0.05)
i_slope_min  = input.float(0.3, "Min Slope (ATR%)", group=grp_tq, minval=0.05, maxval=2.0, step=0.05)
i_tq_bg      = input.bool(true, "Trend Background", group=grp_tq)
i_tq_bands   = input.bool(true, "Show Bands", group=grp_tq)
c_tq_bull    = input.color(#00e5ff, "Bull Trend", group=grp_tq, inline="tc")
c_tq_bear    = input.color(#ff1744, "Bear Trend", group=grp_tq, inline="tc")
c_tq_squeeze = input.color(#ffc107, "Squeeze", group=grp_tq)
c_tq_band    = input.color(#455a64, "Bands", group=grp_tq)

grp_mo = "⟐  Momentum Oscillator (VWMO)"
i_mo_len     = input.int(14, "Momentum Length", group=grp_mo, minval=3, maxval=50)
i_mo_smooth  = input.int(3, "Smoothing", group=grp_mo, minval=2, maxval=20, tooltip="Lower = more responsive, shows OB/OS better")
i_mo_norm    = input.int(500, "Normalization Window", group=grp_mo, minval=100, maxval=2000, tooltip="Longer = oscillator can reach extremes. 500 recommended")
i_mo_ob      = input.float(70, "Overbought Level", group=grp_mo, minval=55, maxval=90)
i_mo_os      = input.float(30, "Oversold Level", group=grp_mo, minval=10, maxval=45)
i_mo_dynmode = input.string("Fixed + Dynamic", "Zone Mode", options=["Fixed", "Dynamic", "Fixed + Dynamic"], group=grp_mo, tooltip="Fixed = like RSI 70/30\nDynamic = adaptive StdDev\nBoth = fixed lines + dynamic bands")
i_mo_dynlen  = input.int(50, "Dynamic Zone Lookback", group=grp_mo, minval=20, maxval=200)
i_mo_dynmult = input.float(1.8, "Dynamic Zone Width (σ)", group=grp_mo, minval=0.5, maxval=3.0, step=0.1)
c_mo_bull    = input.color(#00e676, "VWMO Bull", group=grp_mo, inline="mc")
c_mo_bear    = input.color(#ff5252, "VWMO Bear", group=grp_mo, inline="mc")
c_mo_ob      = input.color(#ff1744, "Overbought", group=grp_mo, inline="mz")
c_mo_os      = input.color(#00e5ff, "Oversold", group=grp_mo, inline="mz")
i_mo_arrows  = input.bool(true, "OB/OS Arrows", group=grp_mo, tooltip="Show arrows when entering OB/OS zone")

grp_cf = "⟐  Confluence Signals"
i_cf_on       = input.bool(true, "Confluence Active", group=grp_cf)
i_cf_cooldown = input.int(5, "Cooldown (Bars)", group=grp_cf, minval=1, maxval=30)
i_cf_labels   = input.bool(true, "Signal Labels", group=grp_cf)
c_cf_buy      = input.color(#00e5ff, "Buy", group=grp_cf, inline="cf")
c_cf_sell     = input.color(#ff1744, "Sell", group=grp_cf, inline="cf")
i_cf_size     = input.string("Small", "Size", options=["Tiny", "Small", "Normal"], group=grp_cf)

grp_pan = "⟐  Panel"
i_show_panel = input.bool(true, "Show Panel", group=grp_pan)

// ═══════════════════════════════════════════════════════════════════════════
// │ 2  IND.1: HMA + VOLATILITY SQUEEZE                                      │
// ═══════════════════════════════════════════════════════════════════════════

half_len = math.max(2, math.round(i_hma_len / 2))
sqrt_len = math.max(2, math.round(math.sqrt(i_hma_len)))

wma_half = ta.wma(close, half_len)
wma_full = ta.wma(close, i_hma_len)
hma_raw  = 2 * wma_half - wma_full
hma      = ta.wma(hma_raw, sqrt_len)

atr_sq    = ta.atr(i_atr_len_sq)
sa_sq     = nz(atr_sq, close * 0.01)
hma_slope = (hma - hma[1]) / sa_sq * 100

slope_bull = hma_slope > i_slope_min
slope_bear = hma_slope < -i_slope_min
slope_flat = not slope_bull and not slope_bear

atr_long  = ta.sma(atr_sq, 50)
atr_ratio = atr_long > 0 ? atr_sq / atr_long : 1.0
in_squeeze = atr_ratio < i_sq_narrow

was_squeeze = in_squeeze[1] and not in_squeeze
squeeze_break_bull = was_squeeze and slope_bull
squeeze_break_bear = was_squeeze and slope_bear

var int tq_state = 0
if in_squeeze
    tq_state := 0
else if slope_bull and (tq_state != -1 or squeeze_break_bull)
    tq_state := 1
else if slope_bear and (tq_state != 1 or squeeze_break_bear)
    tq_state := -1
else if slope_flat
    tq_state := 0

upper_band = hma + sa_sq * i_sq_mult
lower_band = hma - sa_sq * i_sq_mult

color hma_col = tq_state == 1 ? c_tq_bull : tq_state == -1 ? c_tq_bear : c_tq_squeeze
plot(hma, "HMA", hma_col, 2)
p_ub = plot(i_tq_bands ? upper_band : na, "Upper Band", color.new(c_tq_band, 50), 1)
p_lb = plot(i_tq_bands ? lower_band : na, "Lower Band", color.new(c_tq_band, 50), 1)
fill(p_ub, p_lb, in_squeeze ? color.new(c_tq_squeeze, 90) : color.new(c_tq_band, 95), title="Squeeze Fill")

color bg_trend = na
if i_tq_bg
    if tq_state == 1
        bg_trend := color.new(c_tq_bull, 94)
    else if tq_state == -1
        bg_trend := color.new(c_tq_bear, 94)
    else if in_squeeze
        bg_trend := color.new(c_tq_squeeze, 96)
bgcolor(bg_trend, title="Trend BG")

plotshape(squeeze_break_bull, "SqBreak▲", shape.diamond, location.belowbar, c_tq_bull, size=size.tiny)
plotshape(squeeze_break_bear, "SqBreak▼", shape.diamond, location.abovebar, c_tq_bear, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// │ 3  IND.2: VWMO — FIXED NORMALIZATION                                    │
// │                                                                          │
// │  VORHER (Bug):                                                           │
// │  mom_max = ta.highest(abs(cum_mom), 42)  ← zu kurzes Fenster            │
// │  → Oszillator normalisiert gegen sich selbst                             │
// │  → kann mathematisch nie in OB/OS ausbrechen                             │
// │                                                                          │
// │  JETZT (Fix):                                                            │
// │  1. Normalisierung über 500 Bars (einstellbar) statt 42                  │
// │  2. Percentil-basierte Skalierung auf 0-100 Skala (wie RSI)             │
// │  3. Glättung reduziert (3 statt 5) für schnellere Reaktion              │
// │  4. Feste OB/OS-Linien (70/30) als Standard, dynamisch optional         │
// │  5. Arrows bei OB/OS-Eintritt                                           │
// ═══════════════════════════════════════════════════════════════════════════

vol_ma_mo = ta.sma(volume, i_mo_len)
vol_ratio = vol_ma_mo > 0 ? volume / vol_ma_mo : 1.0

// Volume-gewichtetes Momentum
raw_mom = (close - close[1]) * vol_ratio

// Kumulatives Momentum über Lookback
cum_mom = math.sum(raw_mom, i_mo_len)

// FIX: Normalisierung über LANGES Fenster (500 bars default)
// So kann der Oszillator echte Extreme erreichen (wie RSI)
mom_hi = ta.highest(cum_mom, i_mo_norm)
mom_lo = ta.lowest(cum_mom, i_mo_norm)
mom_range = mom_hi - mom_lo

// Skalierung auf 0-100 (wie RSI) statt -100 bis +100
// 50 = neutral, >70 = overbought, <30 = oversold
float norm_mom = 50.0
if mom_range > 0
    norm_mom := (cum_mom - mom_lo) / mom_range * 100

// Ehlers Super Smoother (reduzierte Glättung)
f_supersmoother(float src, int period) =>
    float a1 = math.exp(-math.sqrt(2) * math.pi / period)
    float b1 = 2 * a1 * math.cos(math.sqrt(2) * math.pi / period)
    float c3 = -a1 * a1
    float c2 = b1
    float c1 = 1 - c2 - c3
    var float ss = 0.0
    ss := c1 * (src + nz(src[1])) / 2 + c2 * nz(ss[1]) + c3 * nz(ss[2])
    ss

vwmo = f_supersmoother(norm_mom, i_mo_smooth)

// ─── OB/OS Zonen ────────────────────────────────────────────────────────
// Feste Zonen (wie RSI): 70 / 30
// Dynamische Zonen: Mean ± N × StdDev

// Dynamisch
vwmo_mean = ta.sma(vwmo, i_mo_dynlen)
vwmo_std  = ta.stdev(vwmo, i_mo_dynlen)
dyn_ob    = vwmo_mean + vwmo_std * i_mo_dynmult
dyn_os    = vwmo_mean - vwmo_std * i_mo_dynmult

// Effektive Zonen je nach Modus
float eff_ob = i_mo_ob
float eff_os = i_mo_os
bool use_dyn = i_mo_dynmode == "Dynamic" or i_mo_dynmode == "Fixed + Dynamic"
bool use_fix = i_mo_dynmode == "Fixed" or i_mo_dynmode == "Fixed + Dynamic"

if i_mo_dynmode == "Dynamic"
    eff_ob := dyn_ob
    eff_os := dyn_os

// Bei "Fixed + Dynamic": Signal wenn EINE der beiden Zonen getroffen
is_overbought = use_fix ? vwmo > i_mo_ob : false
is_oversold   = use_fix ? vwmo < i_mo_os : false
if use_dyn
    is_overbought := is_overbought or vwmo > dyn_ob
    is_oversold   := is_oversold or vwmo < dyn_os

// Momentum-Richtung
vwmo_bull = vwmo > 50 and vwmo > vwmo[1]
vwmo_bear = vwmo < 50 and vwmo < vwmo[1]

// Crosses
vwmo_bull_cross = (use_fix and ta.crossover(vwmo, i_mo_os)) or (use_dyn and ta.crossover(vwmo, dyn_os))
vwmo_bear_cross = (use_fix and ta.crossunder(vwmo, i_mo_ob)) or (use_dyn and ta.crossunder(vwmo, dyn_ob))

// OB/OS Entry (für Arrows)
ob_entry = is_overbought and not is_overbought[1]
os_entry = is_oversold and not is_oversold[1]

// ─── VWMO Pane Plots ────────────────────────────────────────────────────
color mo_col = vwmo > 50 ? c_mo_bull : c_mo_bear
plot(vwmo, "VWMO", mo_col, 2, display=display.pane)

// Feste Zonen
plot(use_fix ? i_mo_ob : na, "OB Fixed", color.new(c_mo_ob, 40), 1, plot.style_line, display=display.pane)
plot(use_fix ? i_mo_os : na, "OS Fixed", color.new(c_mo_os, 40), 1, plot.style_line, display=display.pane)

// Dynamische Zonen
plot(use_dyn ? dyn_ob : na, "OB Dynamic", color.new(c_mo_ob, 60), 1, plot.style_steplinebr, display=display.pane)
plot(use_dyn ? dyn_os : na, "OS Dynamic", color.new(c_mo_os, 60), 1, plot.style_steplinebr, display=display.pane)

// Mittellinien
plot(50, "Center", color.new(#787b86, 70), 1, display=display.pane)
plot(use_dyn ? vwmo_mean : na, "Mean", color.new(#787b86, 50), 1, display=display.pane)

// OB/OS Arrows im Pane
plotshape(i_mo_arrows and ob_entry, "OB▼", shape.triangledown, location.top, c_mo_ob, size=size.tiny, display=display.pane)
plotshape(i_mo_arrows and os_entry, "OS▲", shape.triangleup, location.bottom, c_mo_os, size=size.tiny, display=display.pane)

// ═══════════════════════════════════════════════════════════════════════════
// │ 4  CONFLUENCE                                                            │
// ═══════════════════════════════════════════════════════════════════════════

var int last_cf_bar = -9999
cf_cd = bar_index - last_cf_bar > i_cf_cooldown

tq_bull = tq_state == 1 or squeeze_break_bull
tq_bear = tq_state == -1 or squeeze_break_bear
mo_bull = vwmo_bull_cross or (vwmo_bull and not is_overbought)
mo_bear = vwmo_bear_cross or (vwmo_bear and not is_oversold)
price_bull = close > hma
price_bear = close < hma

cf_buy  = i_cf_on and tq_bull and mo_bull and price_bull and cf_cd
cf_sell = i_cf_on and tq_bear and mo_bear and price_bear and cf_cd

if cf_buy or cf_sell
    last_cf_bar := bar_index

cf_sz = i_cf_size == "Tiny" ? size.tiny : i_cf_size == "Small" ? size.small : size.normal

if i_cf_labels and cf_buy
    string tt_b = "────────────────────\n   CONFLUENCE BUY\n────────────────────\n   Trend: " + (tq_state == 1 ? "BULL ✓" : "Squeeze Break ✓") + "\n   VWMO: " + str.tostring(vwmo, "#.0") + " / 100\n   Slope: " + str.tostring(hma_slope, "#.0") + "% ATR\n────────────────────\n   Both indicators confirm"
    label.new(bar_index, low - sa_sq * 0.5, "▲", xloc.bar_index, yloc.price, color.new(c_cf_buy, 10), label.style_label_up, color.white, cf_sz, text.align_center, tt_b)

if i_cf_labels and cf_sell
    string tt_s = "────────────────────\n   CONFLUENCE SELL\n────────────────────\n   Trend: " + (tq_state == -1 ? "BEAR ✓" : "Squeeze Break ✓") + "\n   VWMO: " + str.tostring(vwmo, "#.0") + " / 100\n   Slope: " + str.tostring(hma_slope, "#.0") + "% ATR\n────────────────────\n   Both indicators confirm"
    label.new(bar_index, high + sa_sq * 0.5, "▼", xloc.bar_index, yloc.price, color.new(c_cf_sell, 10), label.style_label_down, color.white, cf_sz, text.align_center, tt_s)

// ═══════════════════════════════════════════════════════════════════════════
// │ 5  PANEL                                                                 │
// ═══════════════════════════════════════════════════════════════════════════

var table panel = table.new(position.bottom_right, 2, 8, bgcolor=color.new(#0f1119, 10), border_color=color.new(#2a2d3a, 60), border_width=1)

if i_show_panel and barstate.islast
    table.cell(panel, 0, 0, "TraxisLab", text_color=color.white, text_size=size.tiny, bgcolor=color.new(#1a1d28, 30))
    table.cell(panel, 1, 0, "ALPHA", text_color=#787b86, text_size=size.tiny, bgcolor=color.new(#1a1d28, 30))

    string ts_txt = tq_state == 1 ? "BULL" : tq_state == -1 ? "BEAR" : "FLAT"
    color ts_col = tq_state == 1 ? c_tq_bull : tq_state == -1 ? c_tq_bear : c_tq_squeeze
    table.cell(panel, 0, 1, "Trend", text_color=#5a5e70, text_size=size.tiny)
    table.cell(panel, 1, 1, ts_txt, text_color=ts_col, text_size=size.tiny)

    string sq_txt = in_squeeze ? "SQUEEZE" : "OPEN"
    color sq_col = in_squeeze ? c_tq_squeeze : #787b86
    table.cell(panel, 0, 2, "Volat.", text_color=#5a5e70, text_size=size.tiny)
    table.cell(panel, 1, 2, sq_txt + " " + str.tostring(atr_ratio, "#.00"), text_color=sq_col, text_size=size.tiny)

    table.cell(panel, 0, 3, "Slope", text_color=#5a5e70, text_size=size.tiny)
    table.cell(panel, 1, 3, str.tostring(hma_slope, "#.0") + "%", text_color=slope_bull ? c_tq_bull : slope_bear ? c_tq_bear : #787b86, text_size=size.tiny)

    table.cell(panel, 0, 4, "VWMO", text_color=#5a5e70, text_size=size.tiny)
    table.cell(panel, 1, 4, str.tostring(vwmo, "#.0") + " / 100", text_color=mo_col, text_size=size.tiny)

    string dz_txt = is_overbought ? "OB ⚠" : is_oversold ? "OS ⚠" : "Neutral"
    color dz_col = is_overbought ? c_mo_ob : is_oversold ? c_mo_os : #787b86
    table.cell(panel, 0, 5, "Zone", text_color=#5a5e70, text_size=size.tiny)
    table.cell(panel, 1, 5, dz_txt, text_color=dz_col, text_size=size.tiny)

    string zn_txt = str.tostring(i_mo_ob, "#") + " / " + str.tostring(i_mo_os, "#")
    if use_dyn
        zn_txt := zn_txt + " | " + str.tostring(dyn_ob, "#") + " / " + str.tostring(dyn_os, "#")
    table.cell(panel, 0, 6, "Levels", text_color=#5a5e70, text_size=size.tiny)
    table.cell(panel, 1, 6, zn_txt, text_color=#787b86, text_size=size.tiny)

    string cf_txt = cf_buy ? "BUY ▲" : cf_sell ? "SELL ▼" : "—"
    color cf_col = cf_buy ? c_cf_buy : cf_sell ? c_cf_sell : #787b86
    table.cell(panel, 0, 7, "Signal", text_color=#5a5e70, text_size=size.tiny)
    table.cell(panel, 1, 7, cf_txt, text_color=cf_col, text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// │ 6  ALERTS                                                                │
// ═══════════════════════════════════════════════════════════════════════════

alertcondition(cf_buy,             "Confluence Buy",  "⭐ TraxisLab: CONFLUENCE BUY")
alertcondition(cf_sell,            "Confluence Sell", "⭐ TraxisLab: CONFLUENCE SELL")
alertcondition(squeeze_break_bull, "SqBreak Bull",   "TraxisLab: Bullish Squeeze Breakout")
alertcondition(squeeze_break_bear, "SqBreak Bear",   "TraxisLab: Bearish Squeeze Breakout")
alertcondition(ob_entry,           "Overbought",     "TraxisLab: VWMO enters Overbought")
alertcondition(os_entry,           "Oversold",        "TraxisLab: VWMO enters Oversold")
alertcondition(vwmo_bull_cross,    "VWMO Bull",      "TraxisLab: VWMO exits oversold")
alertcondition(vwmo_bear_cross,    "VWMO Bear",      "TraxisLab: VWMO exits overbought")
````
