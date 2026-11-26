# Black Card Candle Trend

- url: https://www.tradingview.com/script/nmPp2Qet-Black-Card-Candle-Trend/
- type: indicator
- pine_id: PUB;726ee2b7701f4aa88b7e8695eeadcbfc
- version: 1.0

## Description

🔥 Upgrade 1: Add “early entry”

Instead of:

wait for SSL + momentum → enter

Add:

Early Long
B active
SSL fires
(don’t wait for momentum yet)

👉 label: “EARLY LONG”

Confirmed Long
momentum aligns after

👉 label: “LONG”

🔥 Upgrade 2: Add Mountains as a FILTER (critical)

Only allow:

Longs if:
Mountains rising OR above midline
Shorts if:
Mountains falling OR below midline

This alone will:

remove 30–50% bad trades
🔥 Upgrade 3: Improve momentum definition

## Source Code

````pine
//@version=5
indicator("Black Card Candle Trend", overlay=true, max_boxes_count=300, max_labels_count=500, max_lines_count=300)

import loxx/loxxjuriktools/1

//====================================================
// MTF SETTINGS
//====================================================
group_mtf = "MTF Signal Settings"
signal_tf = input.timeframe("", "Signal Timeframe (blank = chart TF)", group=group_mtf)
wait_for_tf_close = input.bool(true, "Wait for timeframe close", group=group_mtf)

use_mtf = signal_tf != ""
tf_sig = use_mtf ? signal_tf : timeframe.period

f_tf_confirm() =>
    barstate.isconfirmed ? 1 : 0

tf_confirmed = use_mtf ? request.security(syminfo.tickerid, tf_sig, f_tf_confirm(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) == 1 : barstate.isconfirmed

//====================================================
// VISUAL CONTROLS
//====================================================
group_visual = "Visual Controls"
show_hull_arrows = input.bool(true, "Show Hull Arrows", group=group_visual)
show_ssl_arrows = input.bool(true, "Show SSL Arrows", group=group_visual)
show_jma_tags = input.bool(true, "Show ATR-Adaptive JMA Buy/Sell Tags", group=group_visual)
show_fvg_midlines = input.bool(true, "Show FVG Midlines", group=group_visual)

ssl_arrow_height = input.int(118, "SSL Arrow Height", minval=20, maxval=300, group=group_visual)
rapid_arrow_height = input.int(65, "Rapid Hull Arrow Height", minval=20, maxval=300, group=group_visual)

// Hull arrow refinement
hull_arrow_atr_mult = input.float(0.32, "Hull Arrow ATR Offset", minval=0.01, step=0.01, group=group_visual)
hull_arrow_size_opt = input.string("huge", "Hull Arrow Size", options=["normal", "large", "huge"], group=group_visual)

mute_secondary_visuals = input.bool(true, "Mute Secondary Visuals", group=group_visual)

//====================================================
// SWING HIGH / LOW TAGS
//====================================================
group_swing = "Swing High / Low Tags"
show_swing_tags = input.bool(true, "Show Swing High / Low Tags", group=group_swing)
swing_pivot_depth = input.int(10, "Swing Pivot Depth", minval=2, group=group_swing)
swing_buy_color = input.color(color.new(#089981, 0), "B Tag Color", group=group_swing)
swing_sell_color = input.color(color.new(#f23645, 0), "S Tag Color", group=group_swing)
swing_tag_size = input.string("tiny", "Swing Tag Size", options=["tiny", "small", "normal"], group=group_swing)

f_swing_size(_opt) =>
    _opt == "small" ? size.small : _opt == "normal" ? size.normal : size.tiny

//====================================================
// HULL COLORS
//====================================================
group_hull_colors = "Hull Custom Colors"
hull_ma_up_color = input.color(color.blue, "Hull MA Up Color", group=group_hull_colors)
hull_ma_down_color = input.color(#cb54d6, "Hull MA Down Color", group=group_hull_colors)
hull_arrow_buy_color = input.color(color.blue, "Hull Arrow Buy Color", group=group_hull_colors)
hull_arrow_sell_color = input.color(#cb54d6, "Hull Arrow Sell Color", group=group_hull_colors)

//====================================================
// SSL COLORS
//====================================================
group_ssl_colors = "SSL Custom Colors"
ssl_arrow_buy_color = input.color(#00c3ff, "SSL Arrow Buy Color", group=group_ssl_colors)
ssl_arrow_sell_color = input.color(#f54086, "SSL Arrow Sell Color", group=group_ssl_colors)
ssl_line_up_color = input.color(#00c3ff, "SSL Line Up Color", group=group_ssl_colors)
ssl_line_down_color = input.color(#f54086, "SSL Line Down Color", group=group_ssl_colors)

//====================================================
// RAPID HULL COLORS
//====================================================
group_rapid_colors = "Rapid Hull Custom Colors"
rapid_arrow_buy_color = input.color(color.new(color.navy, 40), "Rapid Hull Buy Color", group=group_rapid_colors)
rapid_arrow_sell_color = input.color(color.new(color.red, 40), "Rapid Hull Sell Color", group=group_rapid_colors)

//====================================================
// EMA CUSTOMIZATION
//====================================================
group_ema = "EMA Customization"
show_emas = input.bool(false, "Show EMAs", group=group_ema)

show_ema_1 = input.bool(true, "Show EMA 1", group=group_ema)
ema_1_length = input.int(5, "EMA 1 Length", group=group_ema)
ema_1_color = input.color(#fbc02d, "EMA 1 Color", group=group_ema)
ema_1_width = input.int(2, "EMA 1 Thickness", minval=1, maxval=5, group=group_ema)

show_ema_2 = input.bool(true, "Show EMA 2", group=group_ema)
ema_2_length = input.int(13, "EMA 2 Length", group=group_ema)
ema_2_color = input.color(#b71c1c, "EMA 2 Color", group=group_ema)
ema_2_width = input.int(2, "EMA 2 Thickness", minval=1, maxval=5, group=group_ema)

show_ema_3 = input.bool(true, "Show EMA 3", group=group_ema)
ema_3_length = input.int(50, "EMA 3 Length", group=group_ema)
ema_3_color = input.color(#80deea, "EMA 3 Color", group=group_ema)
ema_3_width = input.int(2, "EMA 3 Thickness", minval=1, maxval=5, group=group_ema)

show_ema_4 = input.bool(true, "Show EMA 4", group=group_ema)
ema_4_length = input.int(200, "EMA 4 Length", group=group_ema)
ema_4_color = input.color(#808080, "EMA 4 Color", group=group_ema)
ema_4_width = input.int(2, "EMA 4 Thickness", minval=1, maxval=5, group=group_ema)

show_ema_5 = input.bool(true, "Show EMA 5", group=group_ema)
ema_5_length = input.int(800, "EMA 5 Length", group=group_ema)
ema_5_color = input.color(#1976d2, "EMA 5 Color", group=group_ema)
ema_5_width = input.int(2, "EMA 5 Thickness", minval=1, maxval=5, group=group_ema)

ema_1 = ta.ema(close, ema_1_length)
ema_2 = ta.ema(close, ema_2_length)
ema_3 = ta.ema(close, ema_3_length)
ema_4 = ta.ema(close, ema_4_length)
ema_5 = ta.ema(close, ema_5_length)

plot(show_emas and show_ema_1 ? ema_1 : na, title="EMA 1", color=ema_1_color, linewidth=ema_1_width)
plot(show_emas and show_ema_2 ? ema_2 : na, title="EMA 2", color=ema_2_color, linewidth=ema_2_width)
plot(show_emas and show_ema_3 ? ema_3 : na, title="EMA 3", color=ema_3_color, linewidth=ema_3_width)
plot(show_emas and show_ema_4 ? ema_4 : na, title="EMA 4", color=ema_4_color, linewidth=ema_4_width)
plot(show_emas and show_ema_5 ? ema_5 : na, title="EMA 5", color=ema_5_color, linewidth=ema_5_width)

//====================================================
// CORE INPUTS
//====================================================
group_hull = "Hull Trend"
matype = input.string("HullMA", "Fast MA Type", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA", "HullMA"], group=group_hull)
malength = input.int(21, "Moving Average Length", minval=1, group=group_hull)
src = input.source(close, "Moving Average Source", group=group_hull)

group_fractal = "Fractal Levels"
show_fractals = input.bool(true, "Show Fractal Levels", group=group_fractal)

group_ssl = "SSL Settings"
show_ssl1 = input.bool(false, "SSL1", group=group_ssl)
atrlen = input.int(11, "ATR Period", group=group_ssl)
mult = input.float(1.0, "ATR Multi", step=0.1, group=group_ssl)
smoothing = input.string("WMA", "ATR Smoothing", options=["RMA", "SMA", "EMA", "WMA"], group=group_ssl)
maType = input.string("HMA", "SSL1 / Baseline Type", options=["SMA", "EMA", "DEMA", "TEMA", "LSMA", "WMA", "MF", "VAMA", "TMA", "HMA", "JMA", "Kijun v2", "EDSMA", "McGinley"], group=group_ssl)
len = input.int(60, "SSL1 / Baseline Length", group=group_ssl)
SSL2Type = input.string("JMA", "SSL2 / Continuation Type", options=["SMA", "EMA", "DEMA", "TEMA", "WMA", "MF", "VAMA", "TMA", "HMA", "JMA", "McGinley"], group=group_ssl)
len2 = input.int(5, "SSL2 Length", group=group_ssl)
SSL3Type = input.string("HMA", "EXIT Type", options=["DEMA", "TEMA", "LSMA", "VAMA", "TMA", "HMA", "JMA", "Kijun v2", "McGinley", "MF"], group=group_ssl)
len3 = input.int(15, "EXIT Length", group=group_ssl)
src_ssl = input.source(close, "SSL Source", group=group_ssl)
multy = input.float(0.2, "Base Channel Multiplier", step=0.05, group=group_ssl)
atr_crit = input.float(0.9, "Continuation ATR Criteria", step=0.1, group=group_ssl)

group_rapid = "Rapid Hull"
show_rapid_arrows = input.bool(true, "Rapid Hull Arrows", group=group_rapid)
n_hma = input.int(8, "MA period", group=group_rapid)
el = input.bool(false, "Show 1st MA - entry line", group=group_rapid)
trl = input.bool(false, "Show 2nd MA - trendline", group=group_rapid)
pld = input.bool(false, "Show Downtrend - red line", group=group_rapid)
plu = input.bool(false, "Show Uptrend - green line", group=group_rapid)
plr = input.bool(false, "Show Reversing trend - yellow line", group=group_rapid)
plb = input.bool(false, "Show Line background - black line", group=group_rapid)

group_jma = "ATR Adaptive JMA"
show_jma_buy = input.bool(true, "ATR-Adaptive JMABuy", group=group_jma)
show_jma_sell = input.bool(true, "ATR-Adaptive JMASell", group=group_jma)
src1 = input.source(close, "Source", group=group_jma)
per = input.int(10, "Period", group=group_jma)
phs = input.float(0, "Jurik Phase", group=group_jma)

group_fvg = "Fair Value Gaps"
show_fvg = input.bool(true, "Boxes", group=group_fvg)
bull_fvg_css = input.color(#2157f3, "Bullish FVG Color", group=group_fvg)
bear_fvg_css = input.color(#ff1100, "Bearish FVG Color", group=group_fvg)
fvg_extend = input.int(0, "Extend FVG", minval=0, group=group_fvg)

group_liq = "Liquidity Box"
showliq = input.bool(false, "Show Liquidity Box", group=group_liq)

//====================================================
// HELPER FUNCTIONS
//====================================================
variant(type, source, length) =>
    switch type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)
        "HullMA" => ta.hma(source, length)
        => ta.hma(source, length)

get2PoleSSF(src_, length_) =>
    PI = 2 * math.asin(1)
    arg = math.sqrt(2) * PI / length_
    a1 = math.exp(-arg)
    b1 = 2 * a1 * math.cos(arg)
    c2 = b1
    c3 = -math.pow(a1, 2)
    c1 = 1 - c2 - c3
    ssf = 0.0
    ssf := c1 * src_ + c2 * nz(ssf[1]) + c3 * nz(ssf[2])
    ssf

get3PoleSSF(src_, length_) =>
    PI = 2 * math.asin(1)
    arg = PI / length_
    a1 = math.exp(-arg)
    b1 = 2 * a1 * math.cos(1.738 * arg)
    c1 = math.pow(a1, 2)
    coef2 = b1 + c1
    coef3 = -(c1 + b1 * c1)
    coef4 = math.pow(c1, 2)
    coef1 = 1 - coef2 - coef3 - coef4
    ssf = 0.0
    ssf := coef1 * src_ + coef2 * nz(ssf[1]) + coef3 * nz(ssf[2]) + coef4 * nz(ssf[3])
    ssf

ma_function(source, atrlen_) =>
    if smoothing == "RMA"
        ta.rma(source, atrlen_)
    else if smoothing == "SMA"
        ta.sma(source, atrlen_)
    else if smoothing == "EMA"
        ta.ema(source, atrlen_)
    else
        ta.wma(source, atrlen_)

kidiv = 1
jurik_phase = 3
jurik_power = 1
volatility_lookback = 4
betaMF = 0.8
feedbackMF = false
zMF = 0.5
ssfLength = 20
ssfPoles = 2

f_label_size(opt) =>
    opt == "huge" ? size.huge : opt == "large" ? size.large : size.normal

ma(type, src_, len_) =>
    float result = 0.0
    if type == "TMA"
        result := ta.sma(ta.sma(src_, math.ceil(len_ / 2)), math.floor(len_ / 2) + 1)
    if type == "MF"
        ts = 0.0
        b = 0.0
        c = 0.0
        os = 0.0
        alpha = 2 / (len_ + 1)
        a = feedbackMF ? zMF * src_ + (1 - zMF) * nz(ts[1], src_) : src_
        b := a > alpha * a + (1 - alpha) * nz(b[1], a) ? a : alpha * a + (1 - alpha) * nz(b[1], a)
        c := a < alpha * a + (1 - alpha) * nz(c[1], a) ? a : alpha * a + (1 - alpha) * nz(c[1], a)
        os := a == b ? 1 : a == c ? 0 : os[1]
        upper = betaMF * b + (1 - betaMF) * c
        lower = betaMF * c + (1 - betaMF) * b
        ts := os * upper + (1 - os) * lower
        result := ts
    if type == "LSMA"
        result := ta.linreg(src_, len_, 0)
    if type == "SMA"
        result := ta.sma(src_, len_)
    if type == "EMA"
        result := ta.ema(src_, len_)
    if type == "DEMA"
        e = ta.ema(src_, len_)
        result := 2 * e - ta.ema(e, len_)
    if type == "TEMA"
        e = ta.ema(src_, len_)
        result := 3 * (e - ta.ema(e, len_)) + ta.ema(ta.ema(e, len_), len_)
    if type == "WMA"
        result := ta.wma(src_, len_)
    if type == "VAMA"
        mid = ta.ema(src_, len_)
        dev = src_ - mid
        vol_up = ta.highest(dev, volatility_lookback)
        vol_down = ta.lowest(dev, volatility_lookback)
        result := mid + math.avg(vol_up, vol_down)
    if type == "HMA"
        result := ta.wma(2 * ta.wma(src_, len_ / 2) - ta.wma(src_, len_), math.round(math.sqrt(len_)))
    if type == "JMA"
        phaseRatio = jurik_phase < -100 ? 0.5 : jurik_phase > 100 ? 2.5 : jurik_phase / 100 + 1.5
        betaJ = 0.45 * (len_ - 1) / (0.45 * (len_ - 1) + 2)
        alphaJ = math.pow(betaJ, jurik_power)
        jma = 0.0
        e0 = 0.0
        e0 := (1 - alphaJ) * src_ + alphaJ * nz(e0[1])
        e1 = 0.0
        e1 := (src_ - e0) * (1 - betaJ) + betaJ * nz(e1[1])
        e2 = 0.0
        e2 := (e0 + phaseRatio * e1 - nz(jma[1])) * math.pow(1 - alphaJ, 2) + math.pow(alphaJ, 2) * nz(e2[1])
        jma := e2 + nz(jma[1])
        result := jma
    if type == "Kijun v2"
        kijun = math.avg(ta.lowest(low, len_), ta.highest(high, len_))
        conversionLine = math.avg(ta.lowest(low, math.max(1, int(len_ / kidiv))), ta.highest(high, math.max(1, int(len_ / kidiv))))
        result := (kijun + conversionLine) / 2
    if type == "McGinley"
        mg = 0.0
        mg := na(mg[1]) ? ta.ema(src_, len_) : mg[1] + (src_ - mg[1]) / (len_ * math.pow(src_ / mg[1], 4))
        result := mg
    if type == "EDSMA"
        zeros = src_ - nz(src_[2])
        avgZeros = (zeros + zeros[1]) / 2
        ssf = ssfPoles == 2 ? get2PoleSSF(avgZeros, ssfLength) : get3PoleSSF(avgZeros, ssfLength)
        stdev = ta.stdev(ssf, len_)
        scaledFilter = stdev != 0 ? ssf / stdev : 0
        alphaE = 5 * math.abs(scaledFilter) / len_
        edsma = 0.0
        edsma := alphaE * src_ + (1 - alphaE) * nz(edsma[1])
        result := edsma
    result

//====================================================
// SIGNAL FUNCTIONS FOR MTF
//====================================================
f_hull_line() =>
    variant(matype, src, malength)

f_hull_signal() =>
    zlema_ = variant(matype, src, malength)
    up_ = zlema_ > zlema_[1] ? 1 : 0
    down_ = zlema_ < zlema_[1] ? 1 : 0
    zlema_ > zlema_[1] and down_[1] == 1 ? 1 : zlema_ < zlema_[1] and up_[1] == 1 ? -1 : 0

f_ssl_line() =>
    emaHigh_ = ma(maType, high, len)
    emaLow_ = ma(maType, low, len)
    Hlv_ = int(na)
    Hlv_ := close > emaHigh_ ? 1 : close < emaLow_ ? -1 : nz(Hlv_[1], 1)
    Hlv_ < 0 ? emaHigh_ : emaLow_

f_ssl_signal() =>
    ExitHigh_ = ma(SSL3Type, high, len3)
    ExitLow_ = ma(SSL3Type, low, len3)
    Hlv3_ = int(na)
    Hlv3_ := close > ExitHigh_ ? 1 : close < ExitLow_ ? -1 : nz(Hlv3_[1], 1)
    sslExit_ = Hlv3_ < 0 ? ExitHigh_ : ExitLow_
    ta.crossover(close, sslExit_) ? 1 : ta.crossover(sslExit_, close) ? -1 : 0

f_rapid_signal() =>
    n2ma_ = 2 * ta.wma(close, math.round(n_hma / 2))
    nma_ = ta.wma(close, n_hma)
    diff_ = n2ma_ - nma_
    sqn_ = math.round(math.sqrt(n_hma))
    n2ma1_ = 2 * ta.wma(close[1], math.round(n_hma / 2))
    nma1_ = ta.wma(close[1], n_hma)
    diff1_ = n2ma1_ - nma1_
    n1_ = ta.wma(diff_, sqn_)
    n3_ = n1_ - n1_ * -1
    n4_ = n1_ + n1_
    dif_ = n1_[1] - n3_
    dif3_ = n4_ - n1_[1]
    long_ = dif_ < dif_[1] and dif_[1] >= dif_[2]
    short_ = dif3_ < dif3_[1] and dif3_[1] >= dif3_[2]
    long_ ? 1 : short_ ? -1 : 0

f_jma_signal() =>
    atr11_ = ta.atr(per)
    max_ = ta.highest(atr11_, per)
    min_ = ta.lowest(atr11_, per)
    coeff_ = (min_ != max_) ? 1 - (atr11_ - min_) / (max_ - min_) : 0.5
    perout_ = int(per * (coeff_ + 1.0) / 2.0)
    out_ = loxxjuriktools.jurik_filt(src1, perout_, phs)
    sig_ = out_[1]
    ta.crossover(out_, sig_) ? 1 : ta.crossunder(out_, sig_) ? -1 : 0

//====================================================
// MTF SERIES
//====================================================
zlema = use_mtf ? request.security(syminfo.tickerid, tf_sig, f_hull_line(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : f_hull_line()
hull_sig_raw = use_mtf ? request.security(syminfo.tickerid, tf_sig, f_hull_signal(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : f_hull_signal()

sslDown = use_mtf ? request.security(syminfo.tickerid, tf_sig, f_ssl_line(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : f_ssl_line()
ssl_sig_raw = use_mtf ? request.security(syminfo.tickerid, tf_sig, f_ssl_signal(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : f_ssl_signal()

rapid_sig_raw = use_mtf ? request.security(syminfo.tickerid, tf_sig, f_rapid_signal(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : f_rapid_signal()
jma_sig_raw = use_mtf ? request.security(syminfo.tickerid, tf_sig, f_jma_signal(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off) : f_jma_signal()

//====================================================
// HULL TREND
//====================================================
hull_col = zlema > zlema[1] ? hull_ma_up_color : hull_ma_down_color
plot(zlema, color=hull_col, linewidth=4, title="Hull MA")

hull_buy = hull_sig_raw == 1 and hull_sig_raw[1] != 1 and (not wait_for_tf_close or tf_confirmed)
hull_sell = hull_sig_raw == -1 and hull_sig_raw[1] != -1 and (not wait_for_tf_close or tf_confirmed)

hull_arrow_size = f_label_size(hull_arrow_size_opt)
hull_atr_ref = ta.atr(14)
hull_price_gap = hull_atr_ref * hull_arrow_atr_mult
hull_line_gap = math.max(hull_atr_ref * 0.55, syminfo.mintick * 120)
hull_visual_buffer = math.max(hull_atr_ref * 0.20, syminfo.mintick * 80)
hull_sell_y = math.max(high + hull_price_gap, zlema + hull_line_gap + hull_visual_buffer)
hull_buy_y = math.min(low - hull_price_gap, zlema - hull_line_gap - hull_visual_buffer)

if show_hull_arrows and hull_sell
    label.new(bar_index, hull_sell_y, style=label.style_arrowdown, size=hull_arrow_size, color=hull_arrow_sell_color, text="")

if show_hull_arrows and hull_buy
    label.new(bar_index, hull_buy_y, style=label.style_arrowup, size=hull_arrow_size, color=hull_arrow_buy_color, text="")

alertcondition(hull_buy, "Hull Buy Alert", "Hull Buy Alert")
alertcondition(hull_sell, "Hull Sell Alert", "Hull Sell Alert")

//====================================================
// FRACTAL LEVELS
//====================================================
topfractal = high[2] > high[1] and high[2] > high and high[2] > high[3] and high[2] > high[4]
botfractal = low[2] < low[1] and low[2] < low and low[2] < low[3] and low[2] < low[4]

topfractals = 0.0
botfractals = 0.0

topfractals := topfractal ? high[2] : topfractals[1]
botfractals := botfractal ? low[2] : botfractals[1]

topfcolor = topfractals != topfractals[1] ? na : color.new(color.blue, mute_secondary_visuals ? 55 : 0)
botfcolor = botfractals != botfractals[1] ? na : color.new(#cb54d6, mute_secondary_visuals ? 55 : 0)

plot(show_fractals ? topfractals : na, color=topfcolor, linewidth=2, title="Top Fractal Level")
plot(show_fractals ? botfractals : na, color=botfcolor, linewidth=2, title="Bottom Fractal Level")

//====================================================
// SSL
//====================================================
atr_slen = ma_function(ta.tr(true), atrlen)

maHigh = ma(SSL2Type, high, len2)
maLow = ma(SSL2Type, low, len2)
BBMC = ma(maType, close, len)
Keltma = ma(maType, src_ssl, len)
range_11 = ta.tr(true)
rangema = ta.ema(range_11, len)
upperk = Keltma + rangema * multy
lowerk = Keltma - rangema * multy

Hlv2 = int(na)
Hlv2 := close > maHigh ? 1 : close < maLow ? -1 : nz(Hlv2[1], 1)
sslDown2 = Hlv2 < 0 ? maHigh : maLow

upper_half = atr_slen * atr_crit + close
lower_half = close - atr_slen * atr_crit
buy_inatr = lower_half < sslDown2
sell_inatr = upper_half > sslDown2
sell_cont = close < BBMC and close < sslDown2
buy_cont = close > BBMC and close > sslDown2
sell_atr = sell_inatr and sell_cont
buy_atr = buy_inatr and buy_cont

color_ssl1 = close > sslDown ? ssl_line_up_color : close < sslDown ? ssl_line_down_color : na

plot(show_ssl1 ? sslDown : na, title="SSL1", linewidth=3, color=color_ssl1)

ssl_buy = ssl_sig_raw == 1 and ssl_sig_raw[1] != 1 and (not wait_for_tf_close or tf_confirmed)
ssl_sell = ssl_sig_raw == -1 and ssl_sig_raw[1] != -1 and (not wait_for_tf_close or tf_confirmed)

ssl_arrow = show_ssl_arrows ? (ssl_buy ? 1 : ssl_sell ? -1 : na) : na
plotarrow(ssl_arrow, colorup=color.new(ssl_arrow_buy_color, 5), colordown=color.new(ssl_arrow_sell_color, 5), title="SSL Arrows", maxheight=ssl_arrow_height, minheight=ssl_arrow_height)

alertcondition(ssl_buy, "SSL Buy Alert", "SSL Buy Alert")
alertcondition(ssl_sell, "SSL Sell Alert", "SSL Sell Alert")

//====================================================
// RAPID HULL
//====================================================
rapid_buy = show_rapid_arrows and rapid_sig_raw == 1 and rapid_sig_raw[1] != 1 and (not wait_for_tf_close or tf_confirmed)
rapid_sell = show_rapid_arrows and rapid_sig_raw == -1 and rapid_sig_raw[1] != -1 and (not wait_for_tf_close or tf_confirmed)

rapid_arrow = rapid_buy ? 1 : rapid_sell ? -1 : na
plotarrow(rapid_arrow, colorup=rapid_arrow_buy_color, colordown=rapid_arrow_sell_color, maxheight=rapid_arrow_height, minheight=rapid_arrow_height, title="Rapid Hull Arrows")

alertcondition(rapid_buy, "Rapid Hull Buy Alert", "Rapid Hull Buy Alert")
alertcondition(rapid_sell, "Rapid Hull Sell Alert", "Rapid Hull Sell Alert")

//====================================================
// ATR-ADAPTIVE JMA
//====================================================
jma_buy = show_jma_buy and jma_sig_raw == 1 and jma_sig_raw[1] != 1 and (not wait_for_tf_close or tf_confirmed)
jma_sell = show_jma_sell and jma_sig_raw == -1 and jma_sig_raw[1] != -1 and (not wait_for_tf_close or tf_confirmed)

jma_buy_col = mute_secondary_visuals ? color.new(color.blue, 10) : color.blue
jma_sell_col = mute_secondary_visuals ? color.new(color.rgb(219, 52, 141), 10) : color.rgb(219, 52, 141)

plotshape(show_jma_tags and jma_buy, title="ATR-Adaptive JMABuy", color=jma_buy_col, text="Buy", textcolor=color.white, location=location.belowbar, style=shape.labelup, size=size.tiny)
plotshape(show_jma_tags and jma_sell, title="ATR-Adaptive JMASell", color=jma_sell_col, text="Sell", textcolor=color.white, location=location.abovebar, style=shape.labeldown, size=size.tiny)

alertcondition(jma_buy, "ATR Tag Buy", "ATR Tag Buy")
alertcondition(jma_sell, "ATR Tag Sell", "ATR Tag Sell")

//====================================================
// FAIR VALUE GAPS (CHART TF ONLY)
//====================================================
bull_fvg = show_fvg and low > high[2] and close[1] > high[2]
bear_fvg = show_fvg and high < low[2] and close[1] < low[2]

bull_box_col = color.new(bull_fvg_css, mute_secondary_visuals ? 88 : 80)
bear_box_col = color.new(bear_fvg_css, mute_secondary_visuals ? 88 : 80)
bull_mid_col = mute_secondary_visuals ? color.new(bull_fvg_css, 35) : bull_fvg_css
bear_mid_col = mute_secondary_visuals ? color.new(bear_fvg_css, 35) : bear_fvg_css

if bull_fvg
    avg_bull = math.avg(low, high[2])
    box.new(bar_index - 2, low, bar_index + fvg_extend, high[2], border_color=na, bgcolor=bull_box_col)
    if show_fvg_midlines
        line.new(bar_index - 2, avg_bull, bar_index + fvg_extend, avg_bull, color=bull_mid_col)

if bear_fvg
    avg_bear = math.avg(low[2], high)
    box.new(bar_index - 2, low[2], bar_index + fvg_extend, high, border_color=na, bgcolor=bear_box_col)
    if show_fvg_midlines
        line.new(bar_index - 2, avg_bear, bar_index + fvg_extend, avg_bear, color=bear_mid_col)

//====================================================
// LIQUIDITY BOX
//====================================================
get_hl(inSess) =>
    start = dayofweek == dayofweek.sunday and hour == 19 and minute == 0
    hi = 0.0
    hi := start ? high : inSess and high > hi[1] ? high : hi[1]
    lo = 0.0
    lo := start ? low : inSess and low < lo[1] ? low : lo[1]
    [hi, lo]

[hi1, lo1] = get_hl((dayofweek == dayofweek.monday and hour <= 18) or (dayofweek == dayofweek.sunday and hour >= 19))

is_new_bar(tf_) =>
    ta.change(time(tf_)) != 0

draw_lv(h, l, sess, col) =>
    var int in1 = 0
    var int nval = 0
    midn = (h + l) / 2.0

    if is_new_bar("W")
        box.new(nval, h[1], in1, l[1], border_color=color.new(color.blue, mute_secondary_visuals ? 55 : 0), bgcolor=color.new(color.blue, mute_secondary_visuals ? 85 : 50), border_width=1, force_overlay=true)
        line.new(nval, midn[1], bar_index, midn[1], color=color.new(color.blue, mute_secondary_visuals ? 55 : 0), width=1, force_overlay=true, style=line.style_dashed)

    start = sess and not sess[1]
    stop = sess[1] and not sess
    n = ta.valuewhen(start, bar_index, 0)

    var box b11 = na
    var line l11 = na

    if stop
        box.delete(b11[1])
        b11 := box.new(n, h, bar_index, l, border_color=color.new(color.green, mute_secondary_visuals ? 55 : 0), bgcolor=color.new(color.green, mute_secondary_visuals ? 85 : 50), border_width=1, force_overlay=true)
        in1 := bar_index
        nval := n
        line.delete(l11[1])
        l11 := line.new(n, midn, bar_index, midn, color=color.new(color.green, mute_secondary_visuals ? 55 : 0), width=1, force_overlay=true, style=line.style_dashed)

    var box bx_h = box.new(na, na, na, na, border_color=color.new(col, 50), bgcolor=color.new(col, 50), force_overlay=true)

    if sess and n > 0
        box.set_border_color(bx_h, color.new(col, mute_secondary_visuals ? 70 : 50))
        box.set_bgcolor(bx_h, color.new(col, mute_secondary_visuals ? 88 : 80))
        box.set_lefttop(bx_h, n, h)
        box.set_rightbottom(bx_h, bar_index, l)

    if not sess
        box.set_border_color(bx_h, #00000000)
        box.set_bgcolor(bx_h, #00000000)

if showliq
    draw_lv(hi1, lo1, (dayofweek == dayofweek.monday and hour <= 18) or (dayofweek == dayofweek.sunday and hour >= 19), color.green)

//====================================================
// SWING HIGH / LOW TAGS
//====================================================
swing_high = ta.pivothigh(high, swing_pivot_depth, swing_pivot_depth)
swing_low = ta.pivotlow(low, swing_pivot_depth, swing_pivot_depth)
swing_size = f_swing_size(swing_tag_size)

if show_swing_tags and not na(swing_high)
    label.new(
         bar_index - swing_pivot_depth,
         swing_high,
         "S",
         style=label.style_label_down,
         color=swing_sell_color,
         textcolor=color.white,
         size=swing_size
     )

if show_swing_tags and not na(swing_low)
    label.new(
         bar_index - swing_pivot_depth,
         swing_low,
         "B",
         style=label.style_label_up,
         color=swing_buy_color,
         textcolor=color.white,
         size=swing_size
     )

//====================================================
// ALL-IN ALERTS
//====================================================
all_in_buy = hull_buy and ssl_buy and rapid_buy
all_in_sell = hull_sell and ssl_sell and rapid_sell

alertcondition(all_in_buy, "Arrows All In Buy", "Arrows All In Buy")
alertcondition(all_in_sell, "Arrows All In Sell", "Arrows All In Sell")
````
