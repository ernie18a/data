# SPY ATR Bands

- url: https://www.tradingview.com/script/J8R4qT0N-SPY-ATR-Bands/
- type: indicator
- pine_id: PUB;ede2e16b4d71423891ba56d438fbb102
- version: 1.0

## Description

An all-in-one overlay that combines ATR-based deviation bands, all-time-high levels, and a weekly-EMA trend filter into a single clean tool. Built for swing dip-buying on SPY, but works on any symbol.

Features

• Multi-timeframe ATR bands (D / 4H / 1H) — Keltner-family bands built from an RMA centerline ± ATR × multiplier, with three depths each (narrow ×0.6 / main / wide ×1.5). Because they scale with ATR, a touch of the wide band means a statistically significant move relative to current volatility, not a fixed %. Lines are smoothed between higher-TF updates. Color-coded by TF (D / 4H / 1H), with optional narrow/wide layers.

• Intersection markers — A bubble is dropped at the deepest band touched within each incursion (narrow > main > wide), per timeframe. Instantly shows where price is interacting with each TF's volatility envelope.

• ATH line + pullback levels — Running all-time-high line plus −3 / −4 / −5 / −10 / −15 / −20 / −25% pullback levels (labels only). The ATH label shows price, days since the last ATH, and current trend-leg %. A live "Now" label shows price and exact % distance from the ATH (candle-colored).

• W EMA20 proxy (trend filter) — Approximates the weekly EMA20 on any timeframe (1H/Daily proxies, down to intraday) so you always see the higher-TF trend line. The line turns green when the last daily candle closes above it and red when it closes below — a clean bull/bear read. Includes a tolerance zone, an intersection marker, and an optional interpolation mode for a smooth line down to 5-minute charts.

• Built-in alerts — "Any intersection marker", "Lower-band touch (dip)", and "W EMA20 touch".

How to use

Watch for price tapping a lower band (oversold) while well below the ATH and above the W EMA20 line (trend intact). The deeper the band and the further from the ATH, the higher-conviction the pullback. The W EMA20 color tells you whether the broader regime is bullish or bearish.

Most colors, widths, tolerances and toggles are fully configurable in settings.

Not financial advice — for educational / technical-analysis use.

## Source Code

````pine
//@version=6
// SPY ATR Bands — ATR bands + intersection markers + W EMA20 proxy + ATH line/levels
indicator("SPY ATR Bands", shorttitle="Bands", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── TF toggles ─────────────────────────────────────────────────────────────
grpToggles = "TF Toggles"
showD   = input.bool(true,  "Show D bands",  group=grpToggles)
showH4  = input.bool(true,  "Show 4H bands", group=grpToggles)
showH1  = input.bool(true,  "Show 1H bands", group=grpToggles)
showNarrow = input.bool(false, "Show Narrow bands (x0.60)", group=grpToggles)
showWide   = input.bool(false, "Show Wide bands (x1.50)",   group=grpToggles)

// ─── D Bands ────────────────────────────────────────────────────────────────
grpD = "D Bands"
d_maLen  = input.int(9,    "D: MA Len",   minval=3,  maxval=30,  group=grpD)
d_atrLn  = input.int(14,   "D: ATR Len",  minval=5,  maxval=20,  group=grpD)
d_upMlt  = input.float(0.2,"D: Up Mult",  minval=0.1,maxval=2.0, step=0.1, group=grpD)
d_loMlt  = input.float(1.2,"D: Lo Mult",  minval=0.3,maxval=3.0, step=0.1, group=grpD)

// ─── 4H Bands ───────────────────────────────────────────────────────────────
grpH4 = "4H Bands"
h4_maLen = input.int(9,    "4H: MA Len",  minval=3,  maxval=30,  group=grpH4)
h4_atrLn = input.int(14,   "4H: ATR Len", minval=5,  maxval=20,  group=grpH4)
h4_upMlt = input.float(0.2,"4H: Up Mult", minval=0.1,maxval=2.0, step=0.1, group=grpH4)
h4_loMlt = input.float(1.2,"4H: Lo Mult", minval=0.3,maxval=3.0, step=0.1, group=grpH4)

// ─── 1H Bands ───────────────────────────────────────────────────────────────
grpH1 = "1H Bands"
h1_maLen = input.int(9,    "1H: MA Len",  minval=3,  maxval=30,  group=grpH1)
h1_atrLn = input.int(20,   "1H: ATR Len", minval=5,  maxval=30,  group=grpH1)
h1_upMlt = input.float(0.4,"1H: Up Mult", minval=0.1,maxval=2.0, step=0.1, group=grpH1)
h1_loMlt = input.float(1.2,"1H: Lo Mult", minval=0.3,maxval=3.0, step=0.1, group=grpH1)

// ─── Intersection markers ─────────────────────────────────────────────────────
grpInt = "Intersection markers"
s1  = input.bool(true,  "1H markers", group=grpInt)
s4  = input.bool(true,  "4H markers", group=grpInt)
sD  = input.bool(true,  "D markers",  group=grpInt)
c1h = input.color(#ff7f00,       "1H color", group=grpInt)
c4h = input.color(#DC00FF,       "4H color", group=grpInt)
cD  = input.color(color.blue,    "D color",  group=grpInt)
sATH  = input.bool(true,  "ATH levels markers", group=grpInt)
cATHl = input.color(#1748CE, "ATH color",       group=grpInt)
cPB   = input.color(#4DD0E1, "Pullback color",  group=grpInt)

// ─── W EMA20 proxy (trend filter) ──────────────────────────────────────────────
grpW = "W EMA20 (trend filter)"
showEMA20     = input.bool(true,  "Show W EMA20 proxy", group=grpW)
colEMA20      = input.color(color.new(color.green, 0), "W EMA20 bull color", group=grpW)
colEMA20bear  = input.color(color.new(color.red, 0),   "W EMA20 bear color", group=grpW)
widthEMA20    = input.int(2, "W EMA20 width", minval=1, maxval=5, group=grpW)
showLblEMA20  = input.bool(true,  "W EMA20 label", group=grpW)
showTolEMA20  = input.bool(true,  "W EMA20 tolerance zone", group=grpW)
tolEMA20Pct   = input.float(0.30, "W EMA20 tolerance %", minval=0.05, maxval=1.0, step=0.05, group=grpW)
showEMA20mark = input.bool(true,  "W EMA20 intersection marker", group=grpW)
interpEMA20   = input.bool(false, "Interpolate (smooth, suitable down to 5min)", group=grpW)

// ─── ATH line + levels ─────────────────────────────────────────────────────────
grpATH = "ATH line + levels"
showATH      = input.bool(true,  "ATH line", group=grpATH)
athColor     = input.color(color.new(#1748CE, 40), "ATH line color", group=grpATH)
athWidth     = input.int(2, "ATH width", minval=1, maxval=5, group=grpATH)
athLblSizeIn = input.string("Small", "Label size", options=["Tiny","Small","Normal","Large","Huge"], group=grpATH)
showATHLabel = input.bool(true,  "ATH label (price + days + leg)", group=grpATH)
showNowLabel = input.bool(true,  "Now label (price + % from ATH)", group=grpATH)
nowBullCol   = input.color(color.new(#b2b2b2, 30), "Now bullish color", group=grpATH)
nowBearCol   = input.color(color.new(#e65100, 20), "Now bearish color", group=grpATH)
showTrendLeg = input.bool(true,  "Trend leg % on ATH label", group=grpATH)
trendLegLR   = input.int(3, "Weekly pivot L/R", minval=1, maxval=10, group=grpATH)
showPBlabels = input.bool(true,  "Pullback level labels (-3..-25%)", group=grpATH)
pbColor      = input.color(color.new(#2e2e2e, 40), "Pullback label color", group=grpATH)

athLblSize = switch athLblSizeIn
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    =>          size.huge

// ─── Band function ────────────────────────────────────────────────────────────
f_bands(int maLen, int atrLn, float upMlt, float loMlt) =>
    ma  = ta.rma(high, maLen)
    atr = ta.atr(atrLn)
    [ma + atr * upMlt, ma - atr * loMlt]

// ─── Security: main bands ─────────────────────────────────────────────────────
[d_up,  d_lo]  = request.security(syminfo.tickerid, "D",   f_bands(d_maLen,  d_atrLn,  d_upMlt,  d_loMlt),  barmerge.gaps_off, barmerge.lookahead_off)
[h4_up, h4_lo] = request.security(syminfo.tickerid, "240", f_bands(h4_maLen, h4_atrLn, h4_upMlt, h4_loMlt), barmerge.gaps_off, barmerge.lookahead_off)
[h1_up, h1_lo] = request.security(syminfo.tickerid, "60",  f_bands(h1_maLen, h1_atrLn, h1_upMlt, h1_loMlt), barmerge.gaps_off, barmerge.lookahead_off)

// ─── Security: narrow / wide ──────────────────────────────────────────────────
d_up_n  = request.security(syminfo.tickerid, "D",   ta.rma(high, d_maLen) + ta.atr(d_atrLn) * d_upMlt * 0.60, barmerge.gaps_off, barmerge.lookahead_off)
d_lo_n  = request.security(syminfo.tickerid, "D",   ta.rma(high, d_maLen) - ta.atr(d_atrLn) * d_loMlt * 0.60, barmerge.gaps_off, barmerge.lookahead_off)
d_up_w  = request.security(syminfo.tickerid, "D",   ta.rma(high, d_maLen) + ta.atr(d_atrLn) * d_upMlt * 1.50, barmerge.gaps_off, barmerge.lookahead_off)
d_lo_w  = request.security(syminfo.tickerid, "D",   ta.rma(high, d_maLen) - ta.atr(d_atrLn) * d_loMlt * 1.50, barmerge.gaps_off, barmerge.lookahead_off)
h4_up_n = request.security(syminfo.tickerid, "240", ta.rma(high, h4_maLen) + ta.atr(h4_atrLn) * h4_upMlt * 0.60, barmerge.gaps_off, barmerge.lookahead_off)
h4_lo_n = request.security(syminfo.tickerid, "240", ta.rma(high, h4_maLen) - ta.atr(h4_atrLn) * h4_loMlt * 0.60, barmerge.gaps_off, barmerge.lookahead_off)
h4_up_w = request.security(syminfo.tickerid, "240", ta.rma(high, h4_maLen) + ta.atr(h4_atrLn) * h4_upMlt * 1.50, barmerge.gaps_off, barmerge.lookahead_off)
h4_lo_w = request.security(syminfo.tickerid, "240", ta.rma(high, h4_maLen) - ta.atr(h4_atrLn) * h4_loMlt * 1.50, barmerge.gaps_off, barmerge.lookahead_off)
h1_up_n = request.security(syminfo.tickerid, "60",  ta.rma(high, h1_maLen) + ta.atr(h1_atrLn) * h1_upMlt * 0.60, barmerge.gaps_off, barmerge.lookahead_off)
h1_lo_n = request.security(syminfo.tickerid, "60",  ta.rma(high, h1_maLen) - ta.atr(h1_atrLn) * h1_loMlt * 0.60, barmerge.gaps_off, barmerge.lookahead_off)
h1_up_w = request.security(syminfo.tickerid, "60",  ta.rma(high, h1_maLen) + ta.atr(h1_atrLn) * h1_upMlt * 1.50, barmerge.gaps_off, barmerge.lookahead_off)
h1_lo_w = request.security(syminfo.tickerid, "60",  ta.rma(high, h1_maLen) - ta.atr(h1_atrLn) * h1_loMlt * 1.50, barmerge.gaps_off, barmerge.lookahead_off)

// ─── W EMA20 proxy + ATH-tracking + daily trend (extended session) ─────────────
bool isDailyOrHigher = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
ethTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.extended)
proxy20_1h = request.security(ethTicker, "60", ta.ema(close, 1600), barmerge.gaps_off, barmerge.lookahead_off)
proxy20_d  = request.security(ethTicker, "D",  ta.ema(close, 100),  barmerge.gaps_off, barmerge.lookahead_off)
float ema20_proxy = isDailyOrHigher ? proxy20_d : proxy20_1h

float d_high_raw = request.security(syminfo.tickerid, "D", high, barmerge.gaps_off, barmerge.lookahead_off)
float w_piv_low  = request.security(ethTicker, "W", ta.pivotlow(low,  trendLegLR, trendLegLR), barmerge.gaps_off, barmerge.lookahead_off)
float w_piv_high = request.security(ethTicker, "W", ta.pivothigh(high, trendLegLR, trendLegLR), barmerge.gaps_off, barmerge.lookahead_off)

// Daily trend: last CONFIRMED daily close vs the W EMA20 proxy (D EMA100). No repaint; flips on daily close.
[d_t_close, d_t_ema] = request.security(ethTicker, "D", [close[1], ta.ema(close, 100)[1]], barmerge.gaps_off, barmerge.lookahead_off)
bool trendBull = na(d_t_close) or na(d_t_ema) ? true : d_t_close >= d_t_ema

// ─── Smoothstep (cosmetic line easing between MTF updates) ─────────────────────
f_smooth(float val) =>
    var float _prev    = val
    var float _curr    = val
    var int   _lastBar = bar_index
    var int   _period  = 1
    bool changed = ta.change(val) != 0
    if changed
        _period  := math.max(bar_index - _lastBar, 1)
        _lastBar := bar_index
        _prev    := _curr
        _curr    := val
    int   pos  = bar_index - _lastBar
    float t    = math.min(float(pos) / float(_period), 1.0)
    float ease = t * t * (3.0 - 2.0 * t)
    _prev + (_curr - _prev) * ease

float sd_up_m  = f_smooth(d_up)
float sd_lo_m  = f_smooth(d_lo)
float sd_up_n  = f_smooth(d_up_n)
float sd_lo_n  = f_smooth(d_lo_n)
float sd_up_w  = f_smooth(d_up_w)
float sd_lo_w  = f_smooth(d_lo_w)
float sh4_up_m = f_smooth(h4_up)
float sh4_lo_m = f_smooth(h4_lo)
float sh4_up_n = f_smooth(h4_up_n)
float sh4_lo_n = f_smooth(h4_lo_n)
float sh4_up_w = f_smooth(h4_up_w)
float sh4_lo_w = f_smooth(h4_lo_w)
float sh1_up_m = f_smooth(h1_up)
float sh1_lo_m = f_smooth(h1_lo)
float sh1_up_n = f_smooth(h1_up_n)
float sh1_lo_n = f_smooth(h1_lo_n)
float sh1_up_w = f_smooth(h1_up_w)
float sh1_lo_w = f_smooth(h1_lo_w)
float wema20_smooth = f_smooth(ema20_proxy)
float wema20_plot   = interpEMA20 ? wema20_smooth : ema20_proxy
color emaLineCol    = trendBull ? colEMA20 : colEMA20bear

// ─── Colors ────────────────────────────────────────────────────────────────────
col_d_m  = color.new(color.blue,   30)
col_d_n  = color.new(color.blue,   55)
col_d_w  = color.new(color.blue,   55)
col_h4_m = color.new(color.purple, 30)
col_h4_n = color.new(color.purple, 55)
col_h4_w = color.new(color.purple, 55)
col_h1_m = color.new(#ff7f00, 40)
col_h1_n = color.new(#ff7f00, 65)
col_h1_w = color.new(#ff7f00, 65)

// ─── Band plots ───────────────────────────────────────────────────────────────
p_d_up  = plot(showD ? sd_up_m : na, "D Upper", color=col_d_m, linewidth=2)
p_d_lo  = plot(showD ? sd_lo_m : na, "D Lower", color=col_d_m, linewidth=2)
p_d_mid = plot(showD ? (sd_up_m + sd_lo_m) / 2 : na, display=display.none)
fill(p_d_up, p_d_mid, color=color.new(color.blue, 95))
fill(p_d_mid, p_d_lo, color=color.new(color.blue, 95))
p_d_up_n = plot(showD and showNarrow ? sd_up_n : na, "D Upper Narrow", color=col_d_n, linewidth=1)
p_d_lo_n = plot(showD and showNarrow ? sd_lo_n : na, "D Lower Narrow", color=col_d_n, linewidth=1)
p_d_up_w = plot(showD and showWide   ? sd_up_w : na, "D Upper Wide",   color=col_d_w, linewidth=1)
p_d_lo_w = plot(showD and showWide   ? sd_lo_w : na, "D Lower Wide",   color=col_d_w, linewidth=1)

p_h4_up  = plot(showH4 ? sh4_up_m : na, "4H Upper", color=col_h4_m, linewidth=2)
p_h4_lo  = plot(showH4 ? sh4_lo_m : na, "4H Lower", color=col_h4_m, linewidth=2)
p_h4_mid = plot(showH4 ? (sh4_up_m + sh4_lo_m) / 2 : na, display=display.none)
fill(p_h4_up, p_h4_mid, color=color.new(color.purple, 95))
fill(p_h4_mid, p_h4_lo, color=color.new(color.purple, 95))
p_h4_up_n = plot(showH4 and showNarrow ? sh4_up_n : na, "4H Upper Narrow", color=col_h4_n, linewidth=1)
p_h4_lo_n = plot(showH4 and showNarrow ? sh4_lo_n : na, "4H Lower Narrow", color=col_h4_n, linewidth=1)
p_h4_up_w = plot(showH4 and showWide   ? sh4_up_w : na, "4H Upper Wide",   color=col_h4_w, linewidth=1)
p_h4_lo_w = plot(showH4 and showWide   ? sh4_lo_w : na, "4H Lower Wide",   color=col_h4_w, linewidth=1)

p_h1_up  = plot(showH1 ? sh1_up_m : na, "1H Upper", color=col_h1_m, linewidth=2)
p_h1_lo  = plot(showH1 ? sh1_lo_m : na, "1H Lower", color=col_h1_m, linewidth=3)
p_h1_mid = plot(showH1 ? (sh1_up_m + sh1_lo_m) / 2 : na, display=display.none)
fill(p_h1_up, p_h1_mid, color=color.new(#ff7f00, 95))
fill(p_h1_mid, p_h1_lo, color=color.new(#ff7f00, 95))
p_h1_up_n = plot(showH1 and showNarrow ? sh1_up_n : na, "1H Upper Narrow", color=col_h1_n, linewidth=1)
p_h1_lo_n = plot(showH1 and showNarrow ? sh1_lo_n : na, "1H Lower Narrow", color=col_h1_n, linewidth=1)
p_h1_up_w = plot(showH1 and showWide   ? sh1_up_w : na, "1H Upper Wide",   color=col_h1_w, linewidth=1)
p_h1_lo_w = plot(showH1 and showWide   ? sh1_lo_w : na, "1H Lower Wide",   color=col_h1_w, linewidth=1)

// ─── W EMA20 proxy line + tolerance zone (color = daily trend) ─────────────────
plot(showEMA20 ? wema20_plot : na, "W EMA20", color=emaLineCol, linewidth=widthEMA20)
p_w20_up = plot(showEMA20 and showTolEMA20 and not na(wema20_plot) ? wema20_plot * (1.0 + tolEMA20Pct/100.0) : na, "W EMA20 tol+", color=color.new(emaLineCol, 70), linewidth=1)
p_w20_dn = plot(showEMA20 and showTolEMA20 and not na(wema20_plot) ? wema20_plot * (1.0 - tolEMA20Pct/100.0) : na, "W EMA20 tol-", color=color.new(emaLineCol, 70), linewidth=1)
fill(p_w20_up, p_w20_dn, color=color.new(emaLineCol, 85))

var label lbl_w20 = na
if barstate.islast
    if showEMA20 and showLblEMA20 and not na(wema20_plot)
        if na(lbl_w20)
            lbl_w20 := label.new(bar_index, wema20_plot, "W EMA20", style=label.style_label_left, color=emaLineCol, textcolor=color.white, size=size.small)
        else
            label.set_xy(lbl_w20, bar_index, wema20_plot)
            label.set_text(lbl_w20, "W EMA20")
            label.set_color(lbl_w20, emaLineCol)
    else
        if not na(lbl_w20)
            label.delete(lbl_w20)
            lbl_w20 := na

// ─── Intersection markers (deepest band touch; placed at the TRUE band level) ──
f_up(bool show, float inner, float mid, float outer, color col) =>
    var int depth = 0
    var label lb = na
    if show and not na(inner) and not na(outer)
        if low <= outer and high >= inner
            int cur = low <= inner ? 3 : low <= mid ? 2 : 1
            if cur > depth
                depth := cur
                if not na(lb)
                    label.delete(lb)
                float lvl = cur == 3 ? inner : cur == 2 ? mid : outer
                lb := label.new(bar_index, lvl, "⬤", style=label.style_none, textcolor=col, size=size.large)
        else
            depth := 0
            lb := na
    depth

f_lo(bool show, float inner, float mid, float outer, color col) =>
    var int depth = 0
    var label lb = na
    if show and not na(inner) and not na(outer)
        if high >= outer and low <= inner
            int cur = high >= inner ? 3 : high >= mid ? 2 : 1
            if cur > depth
                depth := cur
                if not na(lb)
                    label.delete(lb)
                float lvl = cur == 3 ? inner : cur == 2 ? mid : outer
                lb := label.new(bar_index, lvl, "⬤", style=label.style_none, textcolor=col, size=size.large)
        else
            depth := 0
            lb := na
    depth

_d1 = f_up(sD, d_up_n,  d_up,  d_up_w,  cD)
_d2 = f_lo(sD, d_lo_n,  d_lo,  d_lo_w,  cD)
_d3 = f_up(s4, h4_up_n, h4_up, h4_up_w, c4h)
_d4 = f_lo(s4, h4_lo_n, h4_lo, h4_lo_w, c4h)
_d5 = f_up(s1, h1_up_n, h1_up, h1_up_w, c1h)
_d6 = f_lo(s1, h1_lo_n, h1_lo, h1_lo_w, c1h)

// ─── ATH value + ATH/pullback/MA level markers (bubbles) ───────────────────────
var float athVal = na
athVal := na(athVal[1]) ? high : math.max(athVal[1], high)

f_level(bool show, float lv, float tol, color col) =>
    var bool inz = false
    bool near = not na(lv) and high >= lv * (1.0 - tol/100.0) and low <= lv * (1.0 + tol/100.0)
    if show and near and not inz
        label.new(bar_index, lv, "⬤", style=label.style_none, textcolor=col, size=size.large)
    inz := near
    inz

_a0  = f_level(sATH, athVal,        0.20, cATHl)
_a3  = f_level(sATH, athVal * 0.97, 0.20, cPB)
_a4  = f_level(sATH, athVal * 0.96, 0.20, cPB)
_a5  = f_level(sATH, athVal * 0.95, 0.30, cPB)
_a10 = f_level(sATH, athVal * 0.90, 0.30, cPB)
_a15 = f_level(sATH, athVal * 0.85, 0.30, cPB)
_a20 = f_level(sATH, athVal * 0.80, 0.30, cPB)
_a25 = f_level(sATH, athVal * 0.75, 0.30, cPB)
// W EMA20 intersection marker — same color as the line (daily trend), 100% opaque
_wma = f_level(showEMA20 and showEMA20mark, wema20_plot, tolEMA20Pct, color.new(emaLineCol, 0))

// ─── ATH line + ATH/Now/pullback labels ────────────────────────────────────────
var float d_ath_track = na
var int   athBars = 0
bool d_isNewDay = ta.change(time("D")) != 0
if na(d_ath_track)
    d_ath_track := d_high_raw
    athBars := 0
else if d_high_raw > d_ath_track
    d_ath_track := d_high_raw
    athBars := 0
else if d_isNewDay
    athBars += 1

float pctFromAth = not na(athVal) and athVal != 0 ? (close / athVal - 1.0) * 100.0 : na

var float last_w_piv_low  = na
var float last_w_piv_high = na
if not na(w_piv_low)
    last_w_piv_low  := w_piv_low
if not na(w_piv_high)
    last_w_piv_high := w_piv_high
float trendLegPct = na
if not na(pctFromAth)
    if pctFromAth > -5.0
        if not na(last_w_piv_low) and last_w_piv_low > 0
            trendLegPct := (close / last_w_piv_low - 1.0) * 100.0
    else
        if not na(last_w_piv_high) and last_w_piv_high > 0
            trendLegPct := (close / last_w_piv_high - 1.0) * 100.0

plot(showATH ? athVal : na, "ATH", color=athColor, linewidth=athWidth)

fmt_pct(_p) => (_p >= 0 ? "+" : "") + str.tostring(math.round(_p, 2)) + "%"

f_pblbl(label _lbl, bool _show, float _y, string _txt, color _col) =>
    label _r = _lbl
    if _show and not na(_y) and barstate.islast
        if na(_r)
            _r := label.new(bar_index, _y, _txt, style=label.style_label_left, color=_col, textcolor=color.white, size=athLblSize)
        else
            label.set_xy(_r, bar_index, _y)
            label.set_text(_r, _txt)
            label.set_color(_r, _col)
    else
        if not na(_r)
            label.delete(_r)
            _r := na
    _r

var label lbl_ath = na
var label lbl_now = na
var label lbl_p3  = na
var label lbl_p4  = na
var label lbl_p5  = na
var label lbl_p10 = na
var label lbl_p15 = na
var label lbl_p20 = na
var label lbl_p25 = na

if barstate.islast
    if showATH and showATHLabel and not na(athVal)
        string _t = "ATH " + str.tostring(math.round(athVal, 2)) + "  " + str.tostring(athBars) + "d"
        if showTrendLeg and not na(trendLegPct)
            _t := _t + "  | Leg " + fmt_pct(trendLegPct)
        if na(lbl_ath)
            lbl_ath := label.new(bar_index, athVal, _t, style=label.style_label_left, color=athColor, textcolor=color.white, size=athLblSize)
        else
            label.set_xy(lbl_ath, bar_index, athVal)
            label.set_text(lbl_ath, _t)
            label.set_color(lbl_ath, athColor)
    else
        if not na(lbl_ath)
            label.delete(lbl_ath)
            lbl_ath := na

    if showNowLabel and not na(pctFromAth)
        color _nc = close >= open ? nowBullCol : nowBearCol
        string _nt = "Now " + str.tostring(math.round(close, 2)) + "  " + fmt_pct(pctFromAth)
        if na(lbl_now)
            lbl_now := label.new(bar_index, close, _nt, style=label.style_label_left, color=_nc, textcolor=color.white, size=athLblSize)
        else
            label.set_xy(lbl_now, bar_index, close)
            label.set_text(lbl_now, _nt)
            label.set_color(lbl_now, _nc)
    else
        if not na(lbl_now)
            label.delete(lbl_now)
            lbl_now := na

    lbl_p3  := f_pblbl(lbl_p3,  showPBlabels, athVal*0.97, "-3%  "  + str.tostring(math.round(athVal*0.97, 2)), pbColor)
    lbl_p4  := f_pblbl(lbl_p4,  showPBlabels, athVal*0.96, "-4%  "  + str.tostring(math.round(athVal*0.96, 2)), pbColor)
    lbl_p5  := f_pblbl(lbl_p5,  showPBlabels, athVal*0.95, "-5%  "  + str.tostring(math.round(athVal*0.95, 2)), pbColor)
    lbl_p10 := f_pblbl(lbl_p10, showPBlabels, athVal*0.90, "-10% "  + str.tostring(math.round(athVal*0.90, 2)), pbColor)
    lbl_p15 := f_pblbl(lbl_p15, showPBlabels, athVal*0.85, "-15% "  + str.tostring(math.round(athVal*0.85, 2)), pbColor)
    lbl_p20 := f_pblbl(lbl_p20, showPBlabels, athVal*0.80, "-20% "  + str.tostring(math.round(athVal*0.80, 2)), pbColor)
    lbl_p25 := f_pblbl(lbl_p25, showPBlabels, athVal*0.75, "-25% "  + str.tostring(math.round(athVal*0.75, 2)), pbColor)

// ─── Alerts ────────────────────────────────────────────────────────────────────
bool band_fired  = (_d1 > nz(_d1[1])) or (_d2 > nz(_d2[1])) or (_d3 > nz(_d3[1])) or (_d4 > nz(_d4[1])) or (_d5 > nz(_d5[1])) or (_d6 > nz(_d6[1]))
bool lower_fired = (_d2 > nz(_d2[1])) or (_d4 > nz(_d4[1])) or (_d6 > nz(_d6[1]))
bool ath_fired   = (_a0 and not _a0[1]) or (_a3 and not _a3[1]) or (_a4 and not _a4[1]) or (_a5 and not _a5[1]) or (_a10 and not _a10[1]) or (_a15 and not _a15[1]) or (_a20 and not _a20[1]) or (_a25 and not _a25[1])
bool ma_fired    = _wma and not _wma[1]
bool anyIntersection = band_fired or ath_fired or ma_fired

alertcondition(anyIntersection, "Any intersection marker", "SPY ATR Bands: intersection marker @ {{close}}")
alertcondition(lower_fired,     "Lower-band touch (dip)",  "SPY ATR Bands: lower-band oversold touch @ {{close}}")
alertcondition(ma_fired,        "W EMA20 touch",           "SPY ATR Bands: W EMA20 touch @ {{close}}")
````
