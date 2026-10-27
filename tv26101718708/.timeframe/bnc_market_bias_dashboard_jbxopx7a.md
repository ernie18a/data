# BNC Market Bias Dashboard

- url: https://www.tradingview.com/script/JBxoPx7a-BNC-Market-Bias-Dashboard/
- type: indicator
- pine_id: PUB;30945cffcff0426d96587d7688b421c0
- version: 2.0

## Description

A multi-timeframe sentiment gauge built on the BullNaked Crypto strategy framework. No signals, no entries — just a clear read of where the market stands right now across 7 timeframes simultaneously.
Scores each timeframe (3min, 9min, 27min, 81min, 3H, Daily, Weekly) across 5 indicators — EMA stack, Naked RSI zones, Stochastic RSI, Ichimoku Cloud, and Keltner Channel — and combines them into a weighted overall bias rating. Higher timeframes carry more weight because the higher the timeframe, the stronger the signal.
Rating scale: Strong Bull → Bull → Lean Bull → Neutral → Lean Bear → Bear → Strong Bear
What each column shows:

EMA stack alignment (9/30/50/100/200)
Naked RSI health zone (36 / 46 / 56 / 65 system)
Stochastic RSI position
Ichimoku Cloud position
Keltner Channel position
Per-timeframe signal suggestion

The overall score is weighted so Daily and Weekly carry 3× the influence of the 3-minute, reflecting the core principle that trend is truth on the higher timeframe. Use this to build your story before placing any trade — if the higher timeframes disagree with your entry timeframe, the story isn't complete yet.
Overlays directly on your chart. Table anchors to the bottom-left corner. All timeframes and indicator settings are fully adjustable in the settings panel.
Not financial advice. For educational and informational purposes only.

## Source Code

````pine
// ============================================================
// BNC MARKET BIAS DASHBOARD  v2.3
// Multi-timeframe bias score + LuxAlgo trendline confirmation
//
// BUY  fires when: bias score recovers from bear extreme (MR long)
//                  AND price breaks above a downtrend line
// SELL fires when: bias score rolls over from bull extreme (MR short)
//                  AND price breaks below an uptrendline
//
// Trendline logic adapted from LuxAlgo Trend Lines
// © LuxAlgo — CC BY-NC-SA 4.0
// ============================================================

//@version=6
indicator(
     title             = "BNC Market Bias Dashboard",
     shorttitle        = "BNC Bias",
     overlay           = true,
     max_lines_count   = 500,
     max_labels_count  = 500)

// ============================================================
// ── INPUTS
// ============================================================

g1 = "RSI Settings"
rsi_len       = input.int(14, "RSI length",       group = g1)
rsi_bull_gate = input.int(56, "Bullish gate",      group = g1)
rsi_flip      = input.int(46, "Coin flip zone",    group = g1)
rsi_last_bull = input.int(36, "Last bull support", group = g1)

g2 = "Stoch RSI Settings"
srsi_k_len    = input.int(3,  "K smooth",   group = g2)
srsi_d_len    = input.int(3,  "D smooth",   group = g2)
srsi_rsi_len  = input.int(14, "RSI length", group = g2)
srsi_stch_len = input.int(14, "Stoch len",  group = g2)

g3 = "Keltner Settings"
kelt_len  = input.int(20,    "Length",     group = g3)
kelt_mult = input.float(1.5, "Multiplier", group = g3, step = 0.1)

g4 = "Timeframes to show"
show_3m  = input.bool(true, "3 min",  group = g4)
show_9m  = input.bool(true, "9 min",  group = g4)
show_27m = input.bool(true, "27 min", group = g4)
show_81m = input.bool(true, "81 min", group = g4)
show_3h  = input.bool(true, "3 hour", group = g4)
show_d   = input.bool(true, "Daily",  group = g4)
show_w   = input.bool(true, "Weekly", group = g4)

g5 = "BUY / SELL Signal Settings"
show_signals  = input.bool(true, "Show BUY / SELL signals", group = g5)
mr_strong_lvl = input.int(4, "Bias score threshold (default 4)", group = g5, minval = 1, maxval = 9)
mr_soft_lvl   = 2  // kept for alerts only

g6 = "Trendline Settings"
tl_length  = input.int(50,   "Swing length",       group = g6, minval = 2)
tl_toggle  = input.string("Disabled", "Check breaks between:",
     options = ["Point A - Point B", "Point A - Current bar", "Disabled"], group = g6)
tl_source  = input.string("close", "Source (breaks)",
     options = ["close", "H/L"], group = g6)
tl_count   = input.int(3,  "Min unbroken bars before signal",  group = g6, minval = 0,
     tooltip = "Trendline must be unbroken for at least this many bars")
tl_window  = input.int(20, "Confirmation window (bars)",        group = g6, minval = 1,
     tooltip = "How many bars after a trendline break the BUY/SELL window stays open")
tl_showA   = input.bool(true,  "Show angles",         group = g6)
tl_ratio   = input.float(3.0,  "Ratio X-Y axis",      group = g6, step = 0.1)
tl_anglA   = input.float(0.1,  "Angle range — from:", group = g6, minval = 0.1, inline = "angle")
tl_anglB   = input.float(90.0, "to:",                 group = g6, minval = 0.1, inline = "angle")
tl_upCss   = input.color(#2962ff, "Up trendline colour",   group = g6)
tl_dnCss   = input.color(#f23645, "Down trendline colour", group = g6)

// ============================================================
// ── SCORE FUNCTION  (returns -10 to +10)
// ============================================================

calc_score() =>
    e9   = ta.ema(close, 9)
    e30  = ta.ema(close, 30)
    e50  = ta.ema(close, 50)
    e100 = ta.ema(close, 100)
    e200 = ta.ema(close, 200)

    ema_bull = e9 > e30 and e30 > e50 and e50 > e100 and e100 > e200
    ema_bear = e9 < e30 and e30 < e50 and e50 < e100
    abv_key  = close > e100 and close > e200
    blw_key  = close < e100 and close < e200

    ema_pts = 0
    if ema_bull
        ema_pts := 2
    else if ema_bear
        ema_pts := -2
    else if abv_key
        ema_pts := 1
    else if blw_key
        ema_pts := -1

    rsi_v = ta.rsi(close, rsi_len)
    rsi_pts = 0
    if rsi_v >= rsi_bull_gate
        rsi_pts := 2
    else if rsi_v >= rsi_flip
        rsi_pts := 1
    else if rsi_v >= rsi_last_bull
        rsi_pts := -1
    else
        rsi_pts := -2

    rsi_s    = ta.rsi(close, srsi_rsi_len)
    stch_raw = ta.stoch(rsi_s, rsi_s, rsi_s, srsi_stch_len)
    sk       = ta.sma(stch_raw, srsi_k_len)

    srsi_pts = 0
    if sk >= 80
        srsi_pts := -1
    else if sk >= 50
        srsi_pts := 1
    else if sk >= 20
        srsi_pts := -1
    else
        srsi_pts := -2

    i_conv = math.avg(ta.highest(high, 9),  ta.lowest(low, 9))
    i_base = math.avg(ta.highest(high, 26), ta.lowest(low, 26))
    i_la   = math.avg(i_conv, i_base)
    i_lb   = math.avg(ta.highest(high, 52), ta.lowest(low, 52))
    c_top  = math.max(i_la[26], i_lb[26])
    c_bot  = math.min(i_la[26], i_lb[26])

    ichi_pts = 0
    if close > c_top
        ichi_pts := 2
    else if close < c_bot
        ichi_pts := -2
    else if close > i_base
        ichi_pts := 1
    else
        ichi_pts := -1

    kb       = ta.ema(close, kelt_len)
    ka       = ta.atr(kelt_len)
    kl_up    = kb + kelt_mult * ka
    kl_dn    = kb - kelt_mult * ka

    kelt_pts = 0
    if close > kl_up
        kelt_pts := -1
    else if close < kl_dn
        kelt_pts := 1
    else if close > kb
        kelt_pts := 1
    else
        kelt_pts := -1

    total = ema_pts + rsi_pts + srsi_pts + ichi_pts + kelt_pts
    [total, rsi_v, sk, ema_bull, ema_bear, close > c_top, close < c_bot, close > i_base]

// ============================================================
// ── PULL EACH TIMEFRAME
// ============================================================

[s3m,  r3m,  k3m,  eb3m,  br3m,  ac3m,  bc3m,  ab3m]  = request.security(syminfo.tickerid, "3",   calc_score(), lookahead = barmerge.lookahead_off)
[s9m,  r9m,  k9m,  eb9m,  br9m,  ac9m,  bc9m,  ab9m]  = request.security(syminfo.tickerid, "9",   calc_score(), lookahead = barmerge.lookahead_off)
[s27m, r27m, k27m, eb27m, br27m, ac27m, bc27m, ab27m] = request.security(syminfo.tickerid, "27",  calc_score(), lookahead = barmerge.lookahead_off)
[s81m, r81m, k81m, eb81m, br81m, ac81m, bc81m, ab81m] = request.security(syminfo.tickerid, "81",  calc_score(), lookahead = barmerge.lookahead_off)
[s3h,  r3h,  k3h,  eb3h,  br3h,  ac3h,  bc3h,  ab3h]  = request.security(syminfo.tickerid, "180", calc_score(), lookahead = barmerge.lookahead_off)
[sd,   rd,   kd,   ebd,   brd,   acd,   bcd,   abd]   = request.security(syminfo.tickerid, "D",   calc_score(), lookahead = barmerge.lookahead_off)
[sw,   rw,   kw,   ebw,   brw,   acw,   bcw,   abw]   = request.security(syminfo.tickerid, "W",   calc_score(), lookahead = barmerge.lookahead_off)

// ============================================================
// ── WEIGHTED OVERALL SCORE
// ============================================================

w3m  = show_3m  ? 1.0 : 0.0
w9m  = show_9m  ? 1.0 : 0.0
w27m = show_27m ? 1.5 : 0.0
w81m = show_81m ? 2.0 : 0.0
w3h  = show_3h  ? 2.5 : 0.0
wd   = show_d   ? 3.0 : 0.0
ww   = show_w   ? 3.0 : 0.0

w_total = w3m + w9m + w27m + w81m + w3h + wd + ww
w_sum   = s3m*w3m + s9m*w9m + s27m*w27m + s81m*w81m + s3h*w3h + sd*wd + sw*ww
overall = w_total > 0 ? w_sum / w_total : 0.0

// ============================================================
// ── MEAN REVERSION CROSSOVER LOGIC
// ============================================================

neg_strong = -float(mr_strong_lvl)
pos_strong =  float(mr_strong_lvl)
neg_soft   = -float(mr_soft_lvl)
pos_soft   =  float(mr_soft_lvl)

_cross_long_strong  = ta.crossover(overall,  neg_strong)
_cross_short_strong = ta.crossunder(overall, pos_strong)
_cross_long_soft    = ta.crossover(overall,  neg_soft)
_cross_short_soft   = ta.crossunder(overall, pos_soft)

mr_long_strong  = show_signals and _cross_long_strong
mr_short_strong = show_signals and _cross_short_strong
mr_long_soft    = _cross_long_soft
mr_short_soft   = _cross_short_soft

// ============================================================
// ── TRENDLINE ENGINE  (LuxAlgo logic, adapted)
// ── Tracks whether price is currently sitting on an active
//    up or down trendline, and detects clean breaks of each.
// ============================================================

var int   phx1    = na
var float phslope = na
var float phy1    = na
var float upper   = na
var float plotH   = na
var bool  isOnH   = false

var int   plx1    = na
var float plslope = na
var float ply1    = na
var float lower   = na
var float plotL   = na
var bool  isOnL   = false

var line testLine = line.new(na, na, na, na, color = color.new(color.blue, 100))

n      = bar_index
bg     = chart.bg_color
ph     = ta.pivothigh(tl_length, tl_length)
pl     = ta.pivotlow (tl_length, tl_length)
bars   = 500
height = bars / tl_ratio
Xaxis  = math.min(math.max(1, n), bars)
Yaxis  = ta.highest(Xaxis) - ta.lowest(Xaxis)
srcBl  = tl_source == "close" ? close : high
srcBr  = tl_source == "close" ? close : low

tl_slope(x1, x2, y1, y2) =>
    diffX             = x2 - x1
    diffY             = y2 - y1
    diffY_to_Yaxis    = Yaxis / diffY
    normalised_slope  = (height / diffY_to_Yaxis) / diffX
    slope             = diffY / diffX
    angle             = math.round(math.atan(normalised_slope) * 180 / math.pi, 2)
    [normalised_slope, slope, angle]

// ── Down trendline (connects descending pivot highs)
if not na(ph)
    if ph < phy1
        [_ns, slope, angle] = tl_slope(phx1, n - tl_length, phy1, ph)
        testLine.set_xy1(phx1, phy1)
        testLine.set_xy2(n, ph + slope * tl_length)
        src = tl_source == "close" ? close : high
        max_bars_back(src, 2000)
        isOnH := false
        broken = false
        if math.abs(angle) > tl_anglA and math.abs(angle) < tl_anglB
            if tl_toggle != "Disabled"
                for i = (tl_toggle == "Point A - Point B" ? tl_length : 0) to n - phx1
                    if src[i] > testLine.get_price(n - i)
                        broken := true
                        break
            if not broken
                phslope := slope
                isOnH   := true
                upper   := ph + slope * tl_length
                line.new(phx1, phy1, n, ph + slope * tl_length,
                     color = tl_dnCss, style = line.style_dotted)
                if tl_showA
                    label.new(phx1, phy1,
                         text      = str.tostring(angle),
                         style     = label.style_label_down,
                         color     = color.new(bg, 100),
                         textcolor = tl_dnCss)
    phy1 := ph
    phx1 := n - tl_length

upper += phslope
// ta.change and ta.barssince must be unconditional globals (Pine v6 CW10002)
_phslope_changed = ta.change(phslope) != 0
plotH  := not na(ph) and _phslope_changed ? na : srcBl[1] > upper[1] ? na : upper
bs_H   = ta.barssince(na(plotH))

// ── Up trendline (connects ascending pivot lows)
if not na(pl)
    if pl > ply1
        [_ns, slope, angle] = tl_slope(plx1, n - tl_length, ply1, pl)
        testLine.set_xy1(plx1, ply1)
        testLine.set_xy2(n, pl + slope * tl_length)
        src = tl_source == "close" ? close : low
        max_bars_back(src, 2000)
        isOnL := false
        broken = false
        if angle > tl_anglA and angle < tl_anglB
            if tl_toggle != "Disabled"
                for i = (tl_toggle == "Point A - Point B" ? tl_length : 0) to n - plx1
                    if src[i] < testLine.get_price(n - i)
                        broken := true
                        break
            if not broken
                plslope := slope
                isOnL   := true
                lower   := pl + slope * tl_length
                line.new(plx1, ply1, n, pl + slope * tl_length,
                     color = tl_upCss, style = line.style_dotted)
                if tl_showA
                    label.new(plx1, ply1,
                         text      = str.tostring(angle),
                         style     = label.style_label_up,
                         color     = color.new(bg, 100),
                         textcolor = tl_upCss)
    ply1 := pl
    plx1 := n - tl_length

lower += plslope
_plslope_changed = ta.change(plslope) != 0
plotL  := not na(pl) and _plslope_changed ? na : srcBr[1] < lower[1] ? na : lower
bs_L   = ta.barssince(na(plotL))

// ── Trendline break conditions (same logic as LuxAlgo original)
// Bull break: price closes above a downtrend line that held for ≥ tl_count bars
tl_bull_break = bs_H > tl_count and srcBl > upper  and srcBl[1] <= upper[1]
// Bear break: price closes below an uptrendline that held for ≥ tl_count bars
tl_bear_break = bs_L > tl_count and srcBr < lower  and srcBr[1] >= lower[1]

// ============================================================
// ── TRENDLINE PLOTS  (preserved from LuxAlgo)
// ============================================================

plot(plotH, "Down Trendline", tl_dnCss, 1, plot.style_linebr)
plot(plotL, "Up Trendline",   tl_upCss, 1, plot.style_linebr)

// ============================================================
// ── CONFIRMED SIGNALS
//
// Logic: trendline break establishes a directional "window".
// A BUY prints when the bias score crosses up from bear extreme
// while a bull trendline break has occurred in the last N bars.
// A SELL prints when score crosses down from bull extreme
// while a bear trendline break has occurred in the last N bars.
//
// window_bars: how many bars after a trendline break the window
// stays open. Default 20 — adjust in the input group below.
// ============================================================

// All ta.barssince calls unconditional (Pine v6 CW10002)
_bss_mr_long  = ta.barssince(_cross_long_strong)
_bss_mr_short = ta.barssince(_cross_short_strong)
_bss_tl_bull  = ta.barssince(tl_bull_break)
_bss_tl_bear  = ta.barssince(tl_bear_break)

// A trendline break is "active" for window_bars bars after it fires
window_bars = tl_window
tl_bull_active = _bss_tl_bull  <= window_bars
tl_bear_active = _bss_tl_bear  <= window_bars

// BUY:  bias score just recovered from bear extreme, and a bull trendline
//       break happened recently (or is happening now)
// SELL: bias score just rolled over from bull extreme, and a bear trendline
//       break happened recently (or is happening now)
confirmed_buy  = show_signals and _cross_long_strong  and tl_bull_active
confirmed_sell = show_signals and _cross_short_strong and tl_bear_active

// Windowed variant: trendline break fires while score is already in recovery
// (score crossover happened up to window_bars ago)
windowed_buy  = show_signals and tl_bull_break and (_bss_mr_long  <= window_bars) and not confirmed_buy
windowed_sell = show_signals and tl_bear_break and (_bss_mr_short <= window_bars) and not confirmed_sell

// ============================================================
// ── PLOT CONFIRMED SIGNALS
// ============================================================

// Perfect same-bar confirmation — full brightness
plotshape(
     confirmed_buy,
     title     = "BUY (confirmed)",
     style     = shape.circle,
     location  = location.belowbar,
     color     = color.new(#00e676, 0),
     size      = size.small,
     text      = "BUY",
     textcolor = color.new(#00e676, 0))

plotshape(
     confirmed_sell,
     title     = "SELL (confirmed)",
     style     = shape.circle,
     location  = location.abovebar,
     color     = color.new(#ff5252, 0),
     size      = size.small,
     text      = "SELL",
     textcolor = color.new(#ff5252, 0))

// Windowed confirmation — slightly faded, same shape
plotshape(
     windowed_buy,
     title     = "BUY (windowed)",
     style     = shape.circle,
     location  = location.belowbar,
     color     = color.new(#00e676, 45),
     size      = size.small,
     text      = "BUY",
     textcolor = color.new(#00e676, 45))

plotshape(
     windowed_sell,
     title     = "SELL (windowed)",
     style     = shape.circle,
     location  = location.abovebar,
     color     = color.new(#ff5252, 45),
     size      = size.small,
     text      = "SELL",
     textcolor = color.new(#ff5252, 45))

// ============================================================
// ── ALERTS
// ============================================================

alertcondition(confirmed_buy,  "BUY confirmed",  "BNC: BUY — bias recovery confirmed by trendline break above downtrend")
alertcondition(confirmed_sell, "SELL confirmed", "BNC: SELL — bias rollover confirmed by trendline break below uptrend")
alertcondition(windowed_buy,   "BUY windowed",   "BNC: BUY (windowed) — bias and trendline break within 3 bars")
alertcondition(windowed_sell,  "SELL windowed",  "BNC: SELL (windowed) — bias and trendline break within 3 bars")
alertcondition(mr_long_soft,   "MR Soft Long",   "BNC: Soft mean-reversion LONG — score recovering from bearish zone")
alertcondition(mr_short_soft,  "MR Soft Short",  "BNC: Soft mean-reversion SHORT — score fading from bullish zone")

// ============================================================
// ── COLOUR HELPERS
// ============================================================

score_col(s) =>
    result = color.new(color.gray, 40)
    if s >= 6
        result := color.new(#00c853, 0)
    else if s >= 3
        result := color.new(#69f0ae, 10)
    else if s >= 1
        result := color.new(#b9f6ca, 10)
    else if s <= -6
        result := color.new(#d32f2f, 0)
    else if s <= -3
        result := color.new(#ff5252, 10)
    else if s <= -1
        result := color.new(#ff8a80, 10)
    result

score_bg(s) =>
    result = color.new(color.gray, 80)
    if s >= 4
        result := color.new(#00c853, 78)
    else if s >= 1
        result := color.new(#1b5e20, 73)
    else if s <= -4
        result := color.new(#b71c1c, 78)
    else if s <= -1
        result := color.new(#4a1010, 73)
    result

score_lbl(s) =>
    result = "NEUTRAL"
    if s >= 6
        result := "STR BULL"
    else if s >= 3
        result := "BULL"
    else if s >= 1
        result := "LN BULL"
    else if s <= -6
        result := "STR BEAR"
    else if s <= -3
        result := "BEAR"
    else if s <= -1
        result := "LN BEAR"
    result

score_sig(s) =>
    result = "WAIT"
    if s >= 3
        result := "LONG"
    else if s <= -3
        result := "SHORT"
    result

sig_col(s) =>
    result = color.new(color.gray, 35)
    if s >= 3
        result := color.new(#00e676, 0)
    else if s <= -3
        result := color.new(#ff5252, 0)
    result

rsi_zone_lbl(r) =>
    result = "< 36 !!"
    if r >= 56
        result := "> 56 bull"
    else if r >= 46
        result := "46-56 flip"
    else if r >= 36
        result := "36-46 bear"
    result

rsi_zone_col(r) =>
    result = color.new(#ff5252, 0)
    if r >= 56
        result := color.new(#69f0ae, 0)
    else if r >= 46
        result := color.orange
    else if r >= 36
        result := color.new(#ff8a80, 10)
    result

sk_lbl(k) =>
    result = "OS"
    if k >= 80
        result := "OB"
    else if k >= 50
        result := ">50"
    else if k >= 20
        result := "<50"
    result

sk_col(k) =>
    result = color.new(#69f0ae, 0)
    if k >= 80
        result := color.orange
    else if k >= 50
        result := color.new(#b9f6ca, 10)
    else if k >= 20
        result := color.new(#ff8a80, 10)
    result

ichi_lbl(ac, bc) =>
    result = "In cloud"
    if ac
        result := "Above"
    else if bc
        result := "Below"
    result

ichi_col(ac, bc) =>
    result = color.orange
    if ac
        result := color.new(#69f0ae, 0)
    else if bc
        result := color.new(#ff5252, 0)
    result

ema_lbl(eb, br, sc) =>
    result = "< 100/200"
    if eb
        result := "Bull stack"
    else if br
        result := "Bear stack"
    else if sc > 0
        result := "> 100/200"
    result

ema_col(eb, br, sc) =>
    result = color.new(#ff8a80, 15)
    if eb
        result := color.new(#00e676, 0)
    else if br
        result := color.new(#ff5252, 0)
    else if sc > 0
        result := color.new(#69f0ae, 15)
    result

overall_lbl(v) =>
    result = "Neutral"
    if v >= 5
        result := "Strong Bull"
    else if v >= 2
        result := "Bull"
    else if v >= 0.5
        result := "Lean Bull"
    else if v <= -5
        result := "Strong Bear"
    else if v <= -2
        result := "Bear"
    else if v <= -0.5
        result := "Lean Bear"
    result

// ============================================================
// ── TABLE
// ============================================================

if barstate.islast
    c_hdr = color.new(#0d1b2a, 5)
    c_row = color.new(#0a0a0a, 25)
    c_r2  = color.new(#111111, 20)
    c_sep = color.new(color.gray, 72)
    c_lbl = color.new(color.silver, 10)
    c_wht = color.white

    t = table.new(
         position     = position.bottom_left,
         columns      = 9,
         rows         = 10,
         border_width = 1,
         border_color = color.new(color.gray, 55),
         bgcolor      = color.new(#080808, 10),
         frame_width  = 2,
         frame_color  = overall >= 2 ? color.new(#00c853, 25) : overall <= -2 ? color.new(#d32f2f, 25) : color.new(color.gray, 55))

    table.cell(t, 0, 0, "Timeframe",  text_color = c_lbl, bgcolor = c_hdr, text_size = size.small)
    table.cell(t, 1, 0, "Score",      text_color = c_lbl, bgcolor = c_hdr, text_size = size.small, text_halign = text.align_center)
    table.cell(t, 2, 0, "Bias",       text_color = c_lbl, bgcolor = c_hdr, text_size = size.small, text_halign = text.align_center)
    table.cell(t, 3, 0, "EMA stack",  text_color = c_lbl, bgcolor = c_hdr, text_size = size.small, text_halign = text.align_center)
    table.cell(t, 4, 0, "Naked RSI",  text_color = c_lbl, bgcolor = c_hdr, text_size = size.small, text_halign = text.align_center)
    table.cell(t, 5, 0, "Stoch RSI",  text_color = c_lbl, bgcolor = c_hdr, text_size = size.small, text_halign = text.align_center)
    table.cell(t, 6, 0, "Ichimoku",   text_color = c_lbl, bgcolor = c_hdr, text_size = size.small, text_halign = text.align_center)
    table.cell(t, 7, 0, "Keltner",    text_color = c_lbl, bgcolor = c_hdr, text_size = size.small, text_halign = text.align_center)
    table.cell(t, 8, 0, "Signal",     text_color = c_lbl, bgcolor = c_hdr, text_size = size.small, text_halign = text.align_center)

    if show_3m
        rbg = c_row
        table.cell(t, 0, 1, "3 min",  text_color = c_wht, bgcolor = rbg, text_size = size.small)
        table.cell(t, 1, 1, str.tostring(s3m), text_color = score_col(s3m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 2, 1, score_lbl(s3m), text_color = score_col(s3m), bgcolor = score_bg(s3m), text_size = size.small, text_halign = text.align_center)
        table.cell(t, 3, 1, ema_lbl(eb3m, br3m, s3m), text_color = ema_col(eb3m, br3m, s3m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 4, 1, rsi_zone_lbl(r3m) + "  " + str.tostring(math.round(r3m, 0)), text_color = rsi_zone_col(r3m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 5, 1, sk_lbl(k3m) + "  " + str.tostring(math.round(k3m, 0)), text_color = sk_col(k3m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 6, 1, ichi_lbl(ac3m, bc3m), text_color = ichi_col(ac3m, bc3m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 7, 1, s3m > 0 ? "Bullish" : s3m < 0 ? "Bearish" : "Neutral", text_color = score_col(s3m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 8, 1, score_sig(s3m), text_color = sig_col(s3m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)

    if show_9m
        rbg = c_r2
        table.cell(t, 0, 2, "9 min",  text_color = c_wht, bgcolor = rbg, text_size = size.small)
        table.cell(t, 1, 2, str.tostring(s9m), text_color = score_col(s9m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 2, 2, score_lbl(s9m), text_color = score_col(s9m), bgcolor = score_bg(s9m), text_size = size.small, text_halign = text.align_center)
        table.cell(t, 3, 2, ema_lbl(eb9m, br9m, s9m), text_color = ema_col(eb9m, br9m, s9m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 4, 2, rsi_zone_lbl(r9m) + "  " + str.tostring(math.round(r9m, 0)), text_color = rsi_zone_col(r9m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 5, 2, sk_lbl(k9m) + "  " + str.tostring(math.round(k9m, 0)), text_color = sk_col(k9m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 6, 2, ichi_lbl(ac9m, bc9m), text_color = ichi_col(ac9m, bc9m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 7, 2, s9m > 0 ? "Bullish" : s9m < 0 ? "Bearish" : "Neutral", text_color = score_col(s9m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 8, 2, score_sig(s9m), text_color = sig_col(s9m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)

    if show_27m
        rbg = c_row
        table.cell(t, 0, 3, "27 min", text_color = c_wht, bgcolor = rbg, text_size = size.small)
        table.cell(t, 1, 3, str.tostring(s27m), text_color = score_col(s27m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 2, 3, score_lbl(s27m), text_color = score_col(s27m), bgcolor = score_bg(s27m), text_size = size.small, text_halign = text.align_center)
        table.cell(t, 3, 3, ema_lbl(eb27m, br27m, s27m), text_color = ema_col(eb27m, br27m, s27m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 4, 3, rsi_zone_lbl(r27m) + "  " + str.tostring(math.round(r27m, 0)), text_color = rsi_zone_col(r27m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 5, 3, sk_lbl(k27m) + "  " + str.tostring(math.round(k27m, 0)), text_color = sk_col(k27m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 6, 3, ichi_lbl(ac27m, bc27m), text_color = ichi_col(ac27m, bc27m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 7, 3, s27m > 0 ? "Bullish" : s27m < 0 ? "Bearish" : "Neutral", text_color = score_col(s27m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 8, 3, score_sig(s27m), text_color = sig_col(s27m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)

    if show_81m
        rbg = c_r2
        table.cell(t, 0, 4, "81 min", text_color = c_wht, bgcolor = rbg, text_size = size.small)
        table.cell(t, 1, 4, str.tostring(s81m), text_color = score_col(s81m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 2, 4, score_lbl(s81m), text_color = score_col(s81m), bgcolor = score_bg(s81m), text_size = size.small, text_halign = text.align_center)
        table.cell(t, 3, 4, ema_lbl(eb81m, br81m, s81m), text_color = ema_col(eb81m, br81m, s81m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 4, 4, rsi_zone_lbl(r81m) + "  " + str.tostring(math.round(r81m, 0)), text_color = rsi_zone_col(r81m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 5, 4, sk_lbl(k81m) + "  " + str.tostring(math.round(k81m, 0)), text_color = sk_col(k81m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 6, 4, ichi_lbl(ac81m, bc81m), text_color = ichi_col(ac81m, bc81m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 7, 4, s81m > 0 ? "Bullish" : s81m < 0 ? "Bearish" : "Neutral", text_color = score_col(s81m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 8, 4, score_sig(s81m), text_color = sig_col(s81m), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)

    if show_3h
        rbg = c_row
        table.cell(t, 0, 5, "3 hour", text_color = c_wht, bgcolor = rbg, text_size = size.small)
        table.cell(t, 1, 5, str.tostring(s3h), text_color = score_col(s3h), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 2, 5, score_lbl(s3h), text_color = score_col(s3h), bgcolor = score_bg(s3h), text_size = size.small, text_halign = text.align_center)
        table.cell(t, 3, 5, ema_lbl(eb3h, br3h, s3h), text_color = ema_col(eb3h, br3h, s3h), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 4, 5, rsi_zone_lbl(r3h) + "  " + str.tostring(math.round(r3h, 0)), text_color = rsi_zone_col(r3h), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 5, 5, sk_lbl(k3h) + "  " + str.tostring(math.round(k3h, 0)), text_color = sk_col(k3h), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 6, 5, ichi_lbl(ac3h, bc3h), text_color = ichi_col(ac3h, bc3h), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 7, 5, s3h > 0 ? "Bullish" : s3h < 0 ? "Bearish" : "Neutral", text_color = score_col(s3h), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 8, 5, score_sig(s3h), text_color = sig_col(s3h), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)

    if show_d
        rbg = c_r2
        table.cell(t, 0, 6, "Daily",  text_color = c_wht, bgcolor = rbg, text_size = size.small)
        table.cell(t, 1, 6, str.tostring(sd), text_color = score_col(sd), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 2, 6, score_lbl(sd), text_color = score_col(sd), bgcolor = score_bg(sd), text_size = size.small, text_halign = text.align_center)
        table.cell(t, 3, 6, ema_lbl(ebd, brd, sd), text_color = ema_col(ebd, brd, sd), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 4, 6, rsi_zone_lbl(rd) + "  " + str.tostring(math.round(rd, 0)), text_color = rsi_zone_col(rd), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 5, 6, sk_lbl(kd) + "  " + str.tostring(math.round(kd, 0)), text_color = sk_col(kd), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 6, 6, ichi_lbl(acd, bcd), text_color = ichi_col(acd, bcd), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 7, 6, sd > 0 ? "Bullish" : sd < 0 ? "Bearish" : "Neutral", text_color = score_col(sd), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 8, 6, score_sig(sd), text_color = sig_col(sd), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)

    if show_w
        rbg = c_row
        table.cell(t, 0, 7, "Weekly", text_color = c_wht, bgcolor = rbg, text_size = size.small)
        table.cell(t, 1, 7, str.tostring(sw), text_color = score_col(sw), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 2, 7, score_lbl(sw), text_color = score_col(sw), bgcolor = score_bg(sw), text_size = size.small, text_halign = text.align_center)
        table.cell(t, 3, 7, ema_lbl(ebw, brw, sw), text_color = ema_col(ebw, brw, sw), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 4, 7, rsi_zone_lbl(rw) + "  " + str.tostring(math.round(rw, 0)), text_color = rsi_zone_col(rw), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 5, 7, sk_lbl(kw) + "  " + str.tostring(math.round(kw, 0)), text_color = sk_col(kw), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 6, 7, ichi_lbl(acw, bcw), text_color = ichi_col(acw, bcw), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 7, 7, sw > 0 ? "Bullish" : sw < 0 ? "Bearish" : "Neutral", text_color = score_col(sw), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)
        table.cell(t, 8, 7, score_sig(sw), text_color = sig_col(sw), bgcolor = rbg, text_size = size.small, text_halign = text.align_center)

    for col = 0 to 8
        table.cell(t, col, 8, "", bgcolor = c_sep, text_size = size.tiny)

    ov_str = str.tostring(math.round(overall, 1))
    ov_lbl = overall_lbl(overall)
    ov_col = score_col(int(math.round(overall, 0)))
    ov_bg  = score_bg(int(math.round(overall, 0)))
    ov_sig = score_sig(int(math.round(overall, 0)))
    ov_sc  = sig_col(int(math.round(overall, 0)))

    table.cell(t, 0, 9, "OVERALL",      text_color = c_wht,  bgcolor = c_hdr, text_size = size.small)
    table.cell(t, 1, 9, ov_str,         text_color = ov_col, bgcolor = c_hdr, text_size = size.small,  text_halign = text.align_center)
    table.cell(t, 2, 9, ov_lbl,         text_color = ov_col, bgcolor = ov_bg,  text_size = size.normal, text_halign = text.align_center)
    table.cell(t, 3, 9, "EMA + RSI",    text_color = c_lbl,  bgcolor = c_hdr, text_size = size.tiny,   text_halign = text.align_center)
    table.cell(t, 4, 9, "Stoch + Ichi", text_color = c_lbl,  bgcolor = c_hdr, text_size = size.tiny,   text_halign = text.align_center)
    table.cell(t, 5, 9, "Keltner",      text_color = c_lbl,  bgcolor = c_hdr, text_size = size.tiny,   text_halign = text.align_center)
    table.cell(t, 6, 9, "HTF weighted", text_color = c_lbl,  bgcolor = c_hdr, text_size = size.tiny,   text_halign = text.align_center)
    table.cell(t, 7, 9, "D+W = 3x",     text_color = c_lbl,  bgcolor = c_hdr, text_size = size.tiny,   text_halign = text.align_center)
    table.cell(t, 8, 9, ov_sig,         text_color = ov_sc,  bgcolor = c_hdr, text_size = size.normal, text_halign = text.align_center)

// ── END ──────────────────────────────────────────────────────
````
