# Smart Zones v5 

- url: https://www.tradingview.com/script/tWG2eMGZ-Smart-Zones-v5/
- type: indicator
- pine_id: PUB;a91d082fbac846948881b726f44fb2c0
- version: 2.0

## Description

S/R Liqvidity OB and propability of taking short or long

## Source Code

````pine
//@version=5
indicator("Smart Zones v10 — Dark Mode", overlay=true, max_lines_count=100, max_boxes_count=100, max_labels_count=100)

// ─── INPUTS — BARVY ───────────────────────────────────────────────────────────
grp_col     = "🎨 Barvy"
col_res     = input.color(color.new(#FF4444, 60), "Resistance barva",    group=grp_col)
col_sup     = input.color(color.new(#00FF88, 60), "Support barva",       group=grp_col)
col_ob_bull = input.color(color.new(#00BFFF, 70), "Bull OB barva",       group=grp_col)
col_ob_bear = input.color(color.new(#FF8C00, 70), "Bear OB barva",       group=grp_col)
col_fvg     = input.color(color.new(#FFFFFF, 65), "FVG barva",           group=grp_col)
col_bsl     = input.color(color.new(#FFD700, 40), "BSL liquidity barva", group=grp_col)
col_ssl     = input.color(color.new(#00FFFF, 40), "SSL liquidity barva", group=grp_col)
col_ichi_bull = input.color(color.new(#00FF88, 88), "Ichimoku Bull cloud", group=grp_col)
col_ichi_bear = input.color(color.new(#FF4444, 88), "Ichimoku Bear cloud", group=grp_col)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
grp_sr      = "Support & Resistance"
sr_left     = input.int(10,    "Pivot lookback left",      group=grp_sr, minval=3)
sr_right    = input.int(5,     "Pivot potvrzení (bars)",   group=grp_sr, minval=2)
sr_max      = input.int(3,     "Max počet S/R zón",        group=grp_sr, minval=1, maxval=6)
sr_show     = input.bool(true, "Zobrazit S/R",             group=grp_sr)
sr_hide_hit = input.bool(true, "Skrýt proražené",          group=grp_sr)

grp_ob      = "Order Blocks"
ob_show     = input.bool(true, "Zobrazit Order Blocky",    group=grp_ob)
ob_min_move = input.float(1.2, "Min. impuls po OB (ATR)",  group=grp_ob, step=0.1)
ob_max      = input.int(2,     "Max počet OB (bull+bear)", group=grp_ob, minval=1, maxval=4)
ob_hide_hit = input.bool(true, "Skrýt trefené OB",         group=grp_ob)

grp_fvg     = "Fair Value Gaps"
fvg_show     = input.bool(true,  "Zobrazit FVG",           group=grp_fvg)
fvg_min      = input.float(0.1,  "Min. velikost FVG (ATR)",group=grp_fvg, step=0.05)
fvg_max      = input.int(3,      "Max počet FVG",          group=grp_fvg, minval=1, maxval=6)
fvg_hide_hit = input.bool(true,  "Skrýt trefené FVG",      group=grp_fvg)

grp_liq     = "Liquidity"
liq_show    = input.bool(true, "Zobrazit liquidity body",  group=grp_liq)
liq_left    = input.int(8,     "Swing lookback",           group=grp_liq, minval=3)
liq_swept   = input.bool(true, "Skrýt sweepnuté",          group=grp_liq)

grp_ichi    = "Ichimoku"
ichi_show   = input.bool(true, "Zobrazit Ichimoku cloud",  group=grp_ichi)
tenkan_len  = input.int(9,     "Tenkan-sen",               group=grp_ichi, minval=1)
kijun_len   = input.int(26,    "Kijun-sen",                group=grp_ichi, minval=1)
senkou_len  = input.int(52,    "Senkou Span B",            group=grp_ichi, minval=1)

grp_rsi     = "RSI"
rsi_len     = input.int(14,       "RSI Length",            group=grp_rsi, minval=2)
rsi_src     = input.source(close, "RSI Source",            group=grp_rsi)
rsi_bull    = input.int(55,       "Bullish threshold",     group=grp_rsi, minval=50, maxval=80)
rsi_bear    = input.int(45,       "Bearish threshold",     group=grp_rsi, minval=20, maxval=50)

grp_prob    = "Probability Zones"
prob_show   = input.bool(true,  "Zobrazit zóny",           group=grp_prob)
atr_len     = input.int(14,     "ATR Length",              group=grp_prob, minval=1)
zone1_mult  = input.float(1.0,  "Zóna 1 (ATR násobek)",   group=grp_prob, step=0.1)
zone2_mult  = input.float(2.0,  "Zóna 2 (ATR násobek)",   group=grp_prob, step=0.1)
zone3_mult  = input.float(3.0,  "Zóna 3 (ATR násobek)",   group=grp_prob, step=0.1)

// ─── CORE ─────────────────────────────────────────────────────────────────────
atr           = ta.atr(atr_len)
rsi           = ta.rsi(rsi_src, rsi_len)
vol_ma        = ta.sma(volume, 20)
rsi_bull_cond = rsi >= rsi_bull
rsi_bear_cond = rsi <= rsi_bear
trend_color   = rsi_bull_cond ? color.new(#00FF88, 0) : rsi_bear_cond ? color.new(#FF4444, 0) : color.gray
trend_txt     = rsi_bull_cond ? "▲ BULL" : rsi_bear_cond ? "▼ BEAR" : "● NEUTRAL"

// ─── ICHIMOKU ─────────────────────────────────────────────────────────────────
tenkan   = (ta.highest(high, tenkan_len) + ta.lowest(low, tenkan_len)) / 2
kijun    = (ta.highest(high, kijun_len)  + ta.lowest(low, kijun_len))  / 2
senkou_a = (tenkan + kijun) / 2
senkou_b = (ta.highest(high, senkou_len) + ta.lowest(low, senkou_len)) / 2

ichi_bull_cloud    = close > math.max(senkou_a[kijun_len], senkou_b[kijun_len])
ichi_bear_cloud    = close < math.min(senkou_a[kijun_len], senkou_b[kijun_len])
ichi_tk_cross_bull = tenkan > kijun and tenkan[1] <= kijun[1]
ichi_tk_cross_bear = tenkan < kijun and tenkan[1] >= kijun[1]
ichi_chikou_bull   = close > high[kijun_len]
ichi_chikou_bear   = close < low[kijun_len]
ichi_bull_score    = (ichi_bull_cloud ? 1 : 0) + (ichi_tk_cross_bull ? 1 : 0) + (ichi_chikou_bull ? 1 : 0)
ichi_bear_score    = (ichi_bear_cloud ? 1 : 0) + (ichi_tk_cross_bear ? 1 : 0) + (ichi_chikou_bear ? 1 : 0)

p1 = plot(ichi_show ? senkou_a[kijun_len] : na, "Senkou A", color.new(#00FF88, 80), display=display.all)
p2 = plot(ichi_show ? senkou_b[kijun_len] : na, "Senkou B", color.new(#FF4444, 80), display=display.all)
fill(p1, p2, color = senkou_a[kijun_len] > senkou_b[kijun_len] ? col_ichi_bull : col_ichi_bear)
plot(ichi_show ? tenkan : na, "Tenkan", color.new(#00BFFF, 50), linewidth=1)
plot(ichi_show ? kijun  : na, "Kijun",  color.new(#FF8C00, 50), linewidth=1)

// ─── S/R — BOX ────────────────────────────────────────────────────────────────
ph = ta.pivothigh(high, sr_left, sr_right)
pl = ta.pivotlow(low,   sr_left, sr_right)

var int    sr_res_count = 0
var int    sr_sup_count = 0
var box[]   sr_boxes  = array.new_box()
var float[] sr_levels = array.new_float()
var bool[]  sr_is_res = array.new_bool()

sr_box_h = atr * 0.3

if sr_show and not na(ph) and sr_res_count < sr_max
    b = box.new(bar_index - sr_right, ph + sr_box_h, bar_index + 50, ph - sr_box_h, bgcolor=col_res, border_color=color.new(#FF4444, 20), border_width=1)
    label.new(bar_index - sr_right, ph + sr_box_h, "R", color=color.new(#FF4444, 60), textcolor=color.new(#FF4444, 0), style=label.style_label_right, size=size.small)
    array.push(sr_boxes, b)
    array.push(sr_levels, ph)
    array.push(sr_is_res, true)
    sr_res_count += 1

if sr_show and not na(pl) and sr_sup_count < sr_max
    b = box.new(bar_index - sr_right, pl + sr_box_h, bar_index + 50, pl - sr_box_h, bgcolor=col_sup, border_color=color.new(#00FF88, 20), border_width=1)
    label.new(bar_index - sr_right, pl - sr_box_h, "S", color=color.new(#00FF88, 60), textcolor=color.new(#00FF88, 0), style=label.style_label_right, size=size.small)
    array.push(sr_boxes, b)
    array.push(sr_levels, pl)
    array.push(sr_is_res, false)
    sr_sup_count += 1

if sr_hide_hit and array.size(sr_boxes) > 0
    for i = 0 to array.size(sr_boxes) - 1
        b      = array.get(sr_boxes, i)
        level  = array.get(sr_levels, i)
        is_res = array.get(sr_is_res, i)
        hit    = is_res ? close > level + atr * 0.4 : close < level - atr * 0.4
        if hit
            box.set_bgcolor(b,      color.new(color.gray, 100))
            box.set_border_color(b, color.new(color.gray, 100))
        else
            box.set_right(b, bar_index + 50)

// ─── ORDER BLOCKS ─────────────────────────────────────────────────────────────
bull_move = close > close[1] and (close - close[1]) / atr >= ob_min_move
bear_move = close < close[1] and (close[1] - close) / atr >= ob_min_move

var int    ob_bull_cnt = 0
var int    ob_bear_cnt = 0
var box[]   ob_boxes   = array.new_box()
var float[] ob_top     = array.new_float()
var float[] ob_bot     = array.new_float()
var bool[]  ob_is_bull = array.new_bool()

if ob_show and bull_move and ob_bull_cnt < ob_max
    ob_h = math.max(open[1], close[1])
    ob_l = math.min(open[1], close[1])
    if ob_h > ob_l
        b = box.new(bar_index - 1, ob_l, bar_index + 40, ob_h, bgcolor=col_ob_bull, border_color=color.new(#00BFFF, 20), border_width=1)
        label.new(bar_index - 1, ob_l, "BULL OB", color=color.new(#00BFFF, 50), textcolor=color.new(#00BFFF, 0), style=label.style_label_upper_right, size=size.small)
        array.push(ob_boxes, b)
        array.push(ob_top, ob_h)
        array.push(ob_bot, ob_l)
        array.push(ob_is_bull, true)
        ob_bull_cnt += 1

if ob_show and bear_move and ob_bear_cnt < ob_max
    ob_h = math.max(open[1], close[1])
    ob_l = math.min(open[1], close[1])
    if ob_h > ob_l
        b = box.new(bar_index - 1, ob_l, bar_index + 40, ob_h, bgcolor=col_ob_bear, border_color=color.new(#FF8C00, 20), border_width=1)
        label.new(bar_index - 1, ob_h, "BEAR OB", color=color.new(#FF8C00, 50), textcolor=color.new(#FF8C00, 0), style=label.style_label_lower_right, size=size.small)
        array.push(ob_boxes, b)
        array.push(ob_top, ob_h)
        array.push(ob_bot, ob_l)
        array.push(ob_is_bull, false)
        ob_bear_cnt += 1

if ob_hide_hit and array.size(ob_boxes) > 0
    for i = 0 to array.size(ob_boxes) - 1
        b   = array.get(ob_boxes, i)
        top = array.get(ob_top, i)
        bot = array.get(ob_bot, i)
        hit = close <= top and close >= bot
        if hit
            box.set_bgcolor(b, color.new(color.gray, 100))
            box.set_border_color(b, color.new(color.gray, 100))
        else
            box.set_right(b, bar_index + 40)

// ─── FVG ──────────────────────────────────────────────────────────────────────
bull_fvg_sz = low - high[2]
bear_fvg_sz = low[2] - high
bull_fvg    = fvg_show and bull_fvg_sz > fvg_min * atr
bear_fvg    = fvg_show and bear_fvg_sz > fvg_min * atr

var int    fvg_bull_cnt = 0
var int    fvg_bear_cnt = 0
var box[]   fvg_boxes = array.new_box()
var float[] fvg_top   = array.new_float()
var float[] fvg_bot   = array.new_float()

if bull_fvg and fvg_bull_cnt < fvg_max
    b = box.new(bar_index - 2, high[2], bar_index + 20, low, bgcolor=col_fvg, border_color=color.new(#FFFFFF, 20), border_width=1)
    label.new(bar_index - 2, high[2], "FVG", color=color.new(#FFFFFF, 50), textcolor=color.white, style=label.style_label_upper_right, size=size.tiny)
    array.push(fvg_boxes, b)
    array.push(fvg_top, low)
    array.push(fvg_bot, high[2])
    fvg_bull_cnt += 1

if bear_fvg and fvg_bear_cnt < fvg_max
    b = box.new(bar_index - 2, low[2], bar_index + 20, high, bgcolor=col_fvg, border_color=color.new(#FFFFFF, 20), border_width=1)
    label.new(bar_index - 2, high, "FVG", color=color.new(#FFFFFF, 50), textcolor=color.white, style=label.style_label_lower_right, size=size.tiny)
    array.push(fvg_boxes, b)
    array.push(fvg_top, high)
    array.push(fvg_bot, low[2])
    fvg_bear_cnt += 1

if array.size(fvg_boxes) > 0
    for i = 0 to array.size(fvg_boxes) - 1
        b   = array.get(fvg_boxes, i)
        top = array.get(fvg_top, i)
        bot = array.get(fvg_bot, i)
        hit = close <= top and close >= bot
        if fvg_hide_hit and hit
            box.set_bgcolor(b, color.new(color.gray, 100))
            box.set_border_color(b, color.new(color.gray, 100))
        else
            box.set_right(b, bar_index + 20)

// ─── LIQUIDITY ────────────────────────────────────────────────────────────────
liq_ph = ta.pivothigh(high, liq_left, liq_left)
liq_pl = ta.pivotlow(low,   liq_left, liq_left)

var line[]  liq_lines  = array.new_line()
var float[] liq_levels = array.new_float()
var bool[]  liq_is_bsl = array.new_bool()

if liq_show and not na(liq_ph)
    l = line.new(bar_index - liq_left, liq_ph, bar_index + 30, liq_ph, color=col_bsl, width=1, style=line.style_dotted)
    label.new(bar_index - liq_left, liq_ph, "BSL 💧", color=color.new(#FFD700, 70), textcolor=color.new(#FFD700, 0), style=label.style_label_left, size=size.tiny)
    array.push(liq_lines, l)
    array.push(liq_levels, liq_ph)
    array.push(liq_is_bsl, true)

if liq_show and not na(liq_pl)
    l = line.new(bar_index - liq_left, liq_pl, bar_index + 30, liq_pl, color=col_ssl, width=1, style=line.style_dotted)
    label.new(bar_index - liq_left, liq_pl, "SSL 💧", color=color.new(#00FFFF, 70), textcolor=color.new(#00FFFF, 0), style=label.style_label_left, size=size.tiny)
    array.push(liq_lines, l)
    array.push(liq_levels, liq_pl)
    array.push(liq_is_bsl, false)

if liq_swept and array.size(liq_lines) > 0
    for i = 0 to array.size(liq_lines) - 1
        l      = array.get(liq_lines, i)
        level  = array.get(liq_levels, i)
        is_bsl = array.get(liq_is_bsl, i)
        swept  = is_bsl ? high > level : low < level
        if swept
            line.set_color(l, color.new(color.gray, 100))
        else
            line.set_x2(l, bar_index + 30)

// ─── KOMBINOVANÁ PREDIKCE ─────────────────────────────────────────────────────
zone_proximity = atr * 2.0
long_score  = 0.0
short_score = 0.0

if array.size(sr_levels) > 0
    for i = 0 to array.size(sr_levels) - 1
        lvl    = array.get(sr_levels, i)
        is_res = array.get(sr_is_res, i)
        dist   = math.abs(close - lvl)
        if dist < zone_proximity
            pw = 1.0 - dist / zone_proximity
            if is_res
                short_score += 20.0 * pw
            else
                long_score  += 20.0 * pw

if array.size(ob_top) > 0
    for i = 0 to array.size(ob_top) - 1
        top    = array.get(ob_top, i)
        bot    = array.get(ob_bot, i)
        is_bul = array.get(ob_is_bull, i)
        dist   = math.min(math.abs(close - top), math.abs(close - bot))
        if dist < zone_proximity
            pw = 1.0 - dist / zone_proximity
            if is_bul
                long_score  += 20.0 * pw
            else
                short_score += 20.0 * pw

if array.size(fvg_top) > 0
    for i = 0 to array.size(fvg_top) - 1
        top  = array.get(fvg_top, i)
        bot  = array.get(fvg_bot, i)
        mid  = (top + bot) / 2.0
        dist = math.abs(close - mid)
        if dist < zone_proximity
            pw = 1.0 - dist / zone_proximity
            if mid > close
                long_score  += 10.0 * pw
            else
                short_score += 10.0 * pw

if array.size(liq_levels) > 0
    for i = 0 to array.size(liq_levels) - 1
        lvl    = array.get(liq_levels, i)
        is_bsl = array.get(liq_is_bsl, i)
        dist   = math.abs(close - lvl)
        if dist < zone_proximity
            pw = 1.0 - dist / zone_proximity
            if is_bsl
                short_score += 15.0 * pw
            else
                long_score  += 15.0 * pw

rsi_long_pts  = rsi_bull_cond ? math.min((rsi - 50.0) * 0.6, 15.0) : 0.0
rsi_short_pts = rsi_bear_cond ? math.min((50.0 - rsi) * 0.6, 15.0) : 0.0
long_score  += rsi_long_pts
short_score += rsi_short_pts

long_score  += float(ichi_bull_score) * 6.67
short_score += float(ichi_bear_score) * 6.67

max_possible = 100.0
prob_long  = math.min(math.round(35.0 + math.min(long_score,  max_possible) / max_possible * 55.0), 90)
prob_short = math.min(math.round(35.0 + math.min(short_score, max_possible) / max_possible * 55.0), 90)

pcolor(p) =>
    p >= 75 ? color.new(#00FF88, 0) : p >= 58 ? color.new(#FFD700, 0) : color.new(#FF8C00, 0)

// ─── PROBABILITY ZONES ────────────────────────────────────────────────────────
z1_up = close + atr * zone1_mult
z2_up = close + atr * zone2_mult
z3_up = close + atr * zone3_mult
z1_dn = close - atr * zone1_mult
z2_dn = close - atr * zone2_mult
z3_dn = close - atr * zone3_mult

p_u1 = math.min(math.round(prob_long  * 0.95), 90)
p_u2 = math.min(math.round(prob_long  * 0.75), 90)
p_u3 = math.min(math.round(prob_long  * 0.50), 90)
p_d1 = math.min(math.round(prob_short * 0.95), 90)
p_d2 = math.min(math.round(prob_short * 0.75), 90)
p_d3 = math.min(math.round(prob_short * 0.50), 90)

if prob_show and barstate.islast
    line.new(bar_index, z1_up, bar_index + 12, z1_up, color=color.new(#00FF88, 40), width=1)
    line.new(bar_index, z2_up, bar_index + 12, z2_up, color=color.new(#00FF88, 55), width=1)
    line.new(bar_index, z3_up, bar_index + 12, z3_up, color=color.new(#00FF88, 70), width=1)
    label.new(bar_index + 13, z1_up, "↑ long " + str.tostring(p_u1) + "%", color=color.new(#00FF88, 80), textcolor=pcolor(p_u1), style=label.style_label_left, size=size.small)
    label.new(bar_index + 13, z2_up, "↑ long " + str.tostring(p_u2) + "%", color=color.new(#00FF88, 85), textcolor=pcolor(p_u2), style=label.style_label_left, size=size.small)
    label.new(bar_index + 13, z3_up, "↑ long " + str.tostring(p_u3) + "%", color=color.new(#00FF88, 90), textcolor=pcolor(p_u3), style=label.style_label_left, size=size.small)
    line.new(bar_index, z1_dn, bar_index + 12, z1_dn, color=color.new(#FF4444, 40), width=1)
    line.new(bar_index, z2_dn, bar_index + 12, z2_dn, color=color.new(#FF4444, 55), width=1)
    line.new(bar_index, z3_dn, bar_index + 12, z3_dn, color=color.new(#FF4444, 70), width=1)
    label.new(bar_index + 13, z1_dn, "↓ short " + str.tostring(p_d1) + "%", color=color.new(#FF4444, 80), textcolor=pcolor(p_d1), style=label.style_label_left, size=size.small)
    label.new(bar_index + 13, z2_dn, "↓ short " + str.tostring(p_d2) + "%", color=color.new(#FF4444, 85), textcolor=pcolor(p_d2), style=label.style_label_left, size=size.small)
    label.new(bar_index + 13, z3_dn, "↓ short " + str.tostring(p_d3) + "%", color=color.new(#FF4444, 90), textcolor=pcolor(p_d3), style=label.style_label_left, size=size.small)

// ─── RSI + ICHIMOKU LABEL ─────────────────────────────────────────────────────
ichi_txt = ichi_bull_score >= 2 ? " ☁️BULL" : ichi_bear_score >= 2 ? " ☁️BEAR" : " ☁️NEUT"
if barstate.islast
    label.new(bar_index, high * 1.001, trend_txt + "  RSI:" + str.tostring(math.round(rsi, 1)) + ichi_txt + "  L:" + str.tostring(prob_long) + "%  S:" + str.tostring(prob_short) + "%", color=color.new(#1A1A2E, 10), textcolor=trend_color, style=label.style_label_lower_left, size=size.normal)

// ─── BGCOLOR ──────────────────────────────────────────────────────────────────
bgcolor(rsi_bull_cond ? color.new(#00FF88, 95) : color.new(color.black, 100))
bgcolor(rsi_bear_cond ? color.new(#FF4444, 95) : color.new(color.black, 100))

// ─── PLOTCHAR ─────────────────────────────────────────────────────────────────
plotchar(bull_fvg, "Bull FVG", "▲", location.belowbar, color.new(#00FF88, 0), size=size.tiny)
plotchar(bear_fvg, "Bear FVG", "▼", location.abovebar, color.new(#FF4444, 0), size=size.tiny)
````
