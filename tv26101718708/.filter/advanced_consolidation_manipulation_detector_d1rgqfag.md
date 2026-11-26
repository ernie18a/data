# Advanced Consolidation & Manipulation Detector

- url: https://www.tradingview.com/script/D1rgQFaG-Advanced-Consolidation-Manipulation-Detector/
- type: indicator
- pine_id: PUB;8e29782903014f5e926b294ddaffa9ad
- version: 2.0

## Description

[b]Relational Decay MACD[/b]
[i]A smart market analysis tool that goes beyond normal MACD by asking a deeper question: "Given what the MACD is showing right now, what price should we expect based on historical patterns?" When the actual price is very different from the expected price, the indicator flags that something unusual is happening — the relationship between MACD and price has "decayed" from its normal state. These decay moments often signal turning points, exhaustion, or regime changes.[/i]
[b]What This Actually Does (In Plain English)[/b]
Most traders use MACD to spot momentum shifts. This indicator uses MACD as a [b]search key[/b] to look through hundreds of past bars and find times when MACD looked similar. Then it asks: "What did price do back then?" If price back then was very different from price now, that's a [b]relational decay[/b] — the normal MACD-price relationship has broken down.
Think of it like a doctor checking your pulse. A pulse of 80 BPM normally means you're calm. But if your pulse is 80 and you're running a marathon, something is wrong — the relationship between pulse and activity has decayed. This indicator does the same for MACD and price.
[b]How It Works Step by Step[/b]
[list]
[*][b]Step 1 — Record History:[/b] Every bar, the indicator saves the current MACD value and price into a rolling memory (default 200 bars).
[*][b]Step 2 — Find Similar MACD Moments:[/b] Right now, the indicator looks at today's MACD and searches through history for bars where MACD was very similar (within a threshold).
[*][b]Step 3 — Weight the Matches:[/b] Not all matches are equal. Recent matches count more than old ones (temporal decay). Closer MACD matches count more than distant ones. Matches from stable, low-volatility periods count more than chaotic ones.
[*][b]Step 4 — Calculate Expected Price:[/b] From all the weighted historical matches, the indicator computes an "expected price" — what price normally was when MACD looked like this.
[*][b]Step 5 — Compare to Reality:[/b] The indicator subtracts expected price from actual price and normalizes the result. Positive = price is higher than history suggests (bullish decay). Negative = price is lower than history suggests (bearish decay).
[/list]
[b]The Core Output: Relational Decay Score[/b]
The main oscillator ranges from roughly -3 to +3 (can exceed these in extreme cases):
[list]
[*][b]Strongly Positive (+1 to +2):[/b] Price is significantly [b]higher[/b] than what historical MACD relationships would predict. The market has gotten "ahead of itself" on the upside. Often precedes pullbacks or tops.
[*][b]Extremely Positive (+2+):[/b] Price is [b]extremely[/b] elevated relative to MACD history. This is rare and powerful — often marks blow-off tops or euphoric extremes.
[*][b]Near Zero (-0.5 to +0.5):[/b] Price is behaving normally for the current MACD level. The relationship is stable. No special signal.
[*][b]Strongly Negative (-1 to -2):[/b] Price is significantly [b]lower[/b] than what historical MACD relationships would predict. The market is "behind" where it should be. Often precedes bounces or bottoms.
[*][b]Extremely Negative (-2+):[/b] Price is [b]extremely[/b] depressed relative to MACD history. Rare and powerful — often marks panic bottoms or capitulation.
[/list]
[b]All The Settings Explained[/b]
[i]MACD Settings[/i]
[list]
[*][b]MACD Fast Length:[/b] The fast EMA period for standard MACD calculation. Default 12. Lower = more responsive MACD, more noise. Higher = slower MACD, smoother.
[*][b]MACD Slow Length:[/b] The slow EMA period. Default 26. Must be higher than fast length. The gap between fast and slow determines MACD sensitivity.
[*][b]MACD Signal Smoothing:[/b] The EMA period for the MACD signal line. Default 9. Not directly used in the decay calculation but part of standard MACD.
[/list]
[i]Historical Analysis[/i]
[list]
[*][b]Historical Lookback:[/b] How many past bars to store and search through. Default 200. This is the indicator's "memory." More bars = more matches possible but slower and potentially including outdated market regimes. Fewer bars = faster, more recent-context-sensitive.
[*][b]MACD Similarity Threshold:[/b] How close a historical MACD must be to today's MACD to count as a "match." Default 0.5. Lower (0.3) = stricter matching, fewer but more precise historical comparisons. Higher (1.0) = looser matching, more matches but noisier.
[*][b]Temporal Decay Rate:[/b] How quickly old matches lose importance. Default 0.01. This is an exponential decay — a match from 50 bars ago gets weighted by e^(-0.01 × 50) = e^(-0.5) ≈ 0.61. A match from 100 bars ago gets e^(-1.0) ≈ 0.37. Higher rate (0.05) = very strong recency bias. Lower rate (0.001) = history matters almost equally.
[*][b]Minimum Historical Matches:[/b] How many similar MACD moments must be found before calculating an expected price. Default 5. Below this, the indicator returns zero (no signal). Prevents unreliable calculations from tiny sample sizes.
[/list]
[i]Normalization Method[/i]
[list]
[*][b]Z-Score:[/b] (Recommended) Expresses the decay as "standard deviations from the historical mean." A score of +2 means price is 2 standard deviations above what history predicts. Familiar and comparable across all instruments.
[*][b]Percentile:[/b] Expresses decay as a percentile rank among historical matches, then scales to -1 to +1. A score of +0.8 means today's price is higher than 90% of historical prices at this MACD level. More intuitive but less sensitive to outliers.
[*][b]Raw:[/b] Expresses decay as a simple percentage difference from expected price. A score of +5 means price is 5% above expected. Direct but not comparable across different-priced instruments.
[/list]
[b]How To Read The Chart[/b]
[list]
[*][b]Main Oscillator Line (Green/Red):[/b] The relational decay score. Green = price above expected (potentially overextended). Red = price below expected (potentially undervalued). The color intensity increases with extremity.
[*][b]Zero Line (White):[/b] Equilibrium — price is exactly where history says it should be for this MACD level.
[*][b]Dashed Lines at ±1 and ±2:[/b] Warning thresholds. Crossing ±1 is notable. Crossing ±2 is extreme.
[*][b]Background Tint (Blue/Orange):[/b] Shows relationship strength. Blue = the historical MACD-price relationship is strong and reliable (many good matches, low variance). Orange = the relationship is weak or noisy (few matches, high variance). [b]Only trust strong signals when the background is blue.[/b]
[*][b]Diamond Markers:[/b]
[list]
[*][b]Aqua Diamond (Bottom):[/b] Extreme Bullish Reversal — price was extremely low vs expected (deep bearish decay) and is now starting to improve. Potential bottom.
[*][b]Fuchsia Diamond (Top):[/b] Extreme Bearish Reversal — price was extremely high vs expected (deep bullish decay) and is now starting to deteriorate. Potential top.
[/list]
[*][b]Purple Histogram (Bottom):[/b] Expected future move based on what happened after similar historical MACD levels. Scaled down by 10× for visibility. Positive = historical precedent suggests upward drift. Negative = historical precedent suggests downward drift.
[/list]
[b]Top-Right Dashboard Explained[/b]
The information table shows:
[list]
[*][b]Current MACD:[/b] Today's MACD value — the "search key" being used.
[*][b]Current Price:[/b] Today's actual price.
[*][b]Expected Price:[/b] What price "should" be based on weighted historical matches at similar MACD levels. Yellow highlight.
[*][b]Relational Decay:[/b] The main score. Background color matches the oscillator (green for positive, red for negative).
[*][b]State:[/b] Text description — "Stable Relationship," "Moderate Bullish Decay," "Extreme Bearish Decay," etc.
[*][b]Matches Found:[/b] How many historical bars had MACD similar to today. Below minimum = no signal.
[*][b]Strength:[/b] Relationship strength as a percentage. Blue background if >50% (strong relationship). Orange if <50% (weak relationship).
[/list]
[b]Practical Trading Strategies[/b]
[i]The "Fade the Extreme" Play (Beginner-Friendly)[/i]
[list]
[*]Wait for the oscillator to reach [b]+2 or higher[/b] (extreme bullish decay) or [b]-2 or lower[/b] (extreme bearish decay)
[*]Look for the first sign of reversal — a diamond marker, or the oscillator curling back toward zero
[*]Enter counter-trend with stop-loss beyond the recent extreme
[*]Target: The zero line or the opposite ±1 threshold
[*]Only attempt when [b]relationship strength is above 50%[/b] (blue background) — this ensures the historical pattern is reliable
[/list]
[i]The "Divergence Hunter" Play[/i]
[list]
[*]Watch for [b]bullish divergence[/b]: Price making lower lows but relational decay making higher lows (less negative)
[*]Watch for [b]bearish divergence[/b]: Price making higher highs but relational decay making lower highs (less positive)
[*]These divergences indicate the MACD-price relationship is healing even while price continues its trend — often an early warning of reversal
[*]Confirm with a diamond marker or threshold cross for entry
[/list]
[i]The "Equilibrium Return" Play[/i]
[list]
[*]When the oscillator is at an extreme (say +1.5) and starts crossing back [b]toward zero[/b]
[*]This indicates price is returning to its "normal" relationship with MACD
[*]Enter in the direction of the return (short if coming down from +1.5, long if coming up from -1.5)
[*]Target: Zero line
[*]Stop: Recent extreme
[*]This is a mean-reversion play — works best in ranging markets
[/list]
[i]The "Relationship Strength Filter"[/i]
[list]
[*]Use the blue/orange background as a [b]trade filter[/b]
[*]Only take decay signals when background is blue (strength > 50%)
[*]When background is orange, the historical pattern is unreliable — either too few matches or too much variance
[*]This single filter can eliminate many false signals
[/list]
[b]Important Things To Know[/b]
[list]
[*][b]This Is Not MACD:[/b] Do not confuse this with standard MACD signals (crossovers, histogram divergence). This indicator uses MACD as an input but produces completely different output. A "bullish MACD crossover" might coincide with extreme bullish decay (overbought) — which is actually a caution signal, not a buy signal.
[*][b]Memory Is Limited:[/b] The lookback window (default 200 bars) means the indicator "forgets" what happened before that. If market structure changed significantly 300 bars ago (e.g., a regime shift from bull to bear), the indicator won't know. For very long-term analysis, increase lookback to 500 or 1000.
[*][b]Similarity Threshold Is Critical:[/b] If set too tight (0.1), you may get zero matches on many bars — no signal. If set too loose (2.0), everything matches and the expected price becomes meaningless. The default 0.5 works for most markets. Adjust based on your MACD's typical range.
[*][b]Temporal Decay Prevents Stale Data:[/b] The exponential decay means old market conditions naturally fade from relevance. This is good — it adapts to new regimes. But it also means the indicator can be slow to recognize when a genuine structural shift has occurred (it keeps waiting for recent confirmation).
[*][b]Normalization Matters:[/b] Z-Score is best for comparing across instruments. Percentile is best for intuitive "ranking." Raw is best if you want to know the actual percentage deviation. Most users should stick with Z-Score.
[*][b]Low Match Count = No Signal:[/b] If the dashboard shows "Matches Found: 2" and the oscillator is near zero, that's correct behavior — the indicator is saying "I don't have enough evidence to form an opinion." Don't force trades in these moments.
[*][b]Expected Future Move Is Historical, Not Predictive:[/b] The purple histogram shows what happened after similar MACD levels in the past. It is NOT a forecast. It's a statistical tendency — "last 10 times we were here, price drifted up 2% on average." Past performance is not future results.
[*][b]No Repainting:[/b] Once a bar closes, its decay score is fixed. The historical database only includes closed bars. The current bar updates in real-time but does not alter past calculations.
[/list]
[b]Common Mistakes To Avoid[/b]
[list]
[*][b]Trading Against the Trend Using Decay Alone:[/b] Extreme bullish decay (+2.5) in a strong uptrend might just mean the trend is accelerating, not ending. Use decay as a [b]caution flag[/b], not an automatic reversal signal. Wait for price confirmation (break of a key level, reversal pattern).
[*][b]Ignoring Relationship Strength:[/b] A decay score of +2.0 with orange background (strength 25%) is almost meaningless — the historical sample is tiny or noisy. Always check the background color before acting.
[*][b]Over-Optimizing the Threshold:[/b] Setting similarity threshold to perfectly fit recent history will cause the indicator to fail when market conditions change. The defaults are robust. Only adjust if you consistently see too few or too many matches.
[*][b]Forgetting About MACD Lag:[/b] MACD itself is a lagging indicator. The relational decay adds another layer of analysis on top of that lag. This means the indicator is not for scalping or catching exact tops/bottoms. It's for identifying regime extremes and likely turning zones.
[*][b]Using It In Isolation:[/b] Relational Decay works best combined with other tools — support/resistance levels, volume analysis, or fundamental context. It's a "second opinion" on whether MACD signals are trustworthy.
[/list]
[b]Quick Setup Checklist[/b]
[list]
[*]Load the indicator on your chart
[*]Verify the dashboard shows matches (not zero) on most bars
[*]If matches are often below 5: Increase similarity threshold or decrease minimum matches
[*]If matches are always high (50+) with weak strength: Decrease similarity threshold
[*]Choose normalization method: Z-Score for most users, Percentile if you prefer rankings
[*]Watch for 50+ bars to see how extremes form and resolve
[*]Note the background color during your best and worst trades — learn which strength levels you trust
[*]Start by only trading extreme reversals (±2 with blue background and diamond marker)
[*]Gradually add equilibrium return plays as you learn the indicator's rhythm
[*]Always use stop-losses — decay can persist longer than your account can survive
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cmo22

//@version=5
indicator("Advanced Consolidation and Manipulation Detector", shorttitle="ACMD", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// =========================
// INPUTS — EXACT ORIGINAL VALUES
// =========================
len_adx                 = input.int(14,  "ADX Length")
thresh_adx              = input.float(25, "ADX Thresh")
len_atr_f               = input.int(5,   "Fast ATR Len")
len_atr_s               = input.int(20,  "Slow ATR Len")
thresh_atr_r            = input.float(0.8, "ATR Ratio Thresh")
len_chop                = input.int(14,  "Choppiness Len")
thresh_chop             = input.float(61.8, "Choppiness Thresh")
thresh_bb_w             = input.float(0.1, "BB Width Thresh")
len_bb                  = input.int(20,  "BB Len")
mult_bb                 = input.float(2.0, "BB Mult")
thresh_body             = input.float(0.5, "Body/Range Thresh for Flat")
len_vwap                = input.int(20,  "VWAP Len (rolling)")
thresh_vwap_dev         = input.float(1.5, "VWAP Dev %")
thresh_wick             = input.float(0.7, "Wick Ratio Thresh")
mult_vol                = input.float(1.5, "Vol Mult Thresh")
len_pivot               = input.int(5,   "Pivot Len for Sweeps")
len_entropy             = input.int(10,  "Entropy Len")
thresh_consol_score     = input.float(2.0, "Consol Score Thresh")
thresh_manip_score      = input.float(2.0, "Manip Score Thresh")
htf                     = input.timeframe("60", "Higher TF")

// =========================
// CORE SERIES — IDENTICAL LOGIC
// =========================
[diPlus, diMinus, adx] = ta.dmi(len_adx, 1)
htf_adx = request.security(syminfo.tickerid, htf, adx)

ci = 100 * math.log10( math.sum(ta.atr(1), len_chop) / math.max(ta.highest(high, len_chop) - ta.lowest(low, len_chop), syminfo.mintick) ) / math.log10(len_chop)
htf_ci = request.security(syminfo.tickerid, htf, 100 * math.log10( math.sum(ta.atr(1), len_chop) / math.max(ta.highest(high, len_chop) - ta.lowest(low, len_chop), syminfo.mintick) ) / math.log10(len_chop))

// Consolidation Metrics
atr_f = ta.atr(len_atr_f)
atr_s = ta.atr(len_atr_s)
atr_r = atr_f / atr_s

[bb_basis, bb_u, bb_l] = ta.bb(close, len_bb, mult_bb)
bb_w = (bb_u - bb_l) / math.max(bb_basis, syminfo.mintick)

body_r = (math.abs(close - open) / atr_s < thresh_body) ? 1 : 0
hl_r   = ((high - low) / atr_s < thresh_body) ? 1 : 0

ret_bar = math.log(close / close[1])
entropy = ta.stdev(ret_bar, len_entropy)

consol_feats = (adx < thresh_adx ? 1 : 0) +
               (atr_r < thresh_atr_r ? 1 : 0) +
               (ci > thresh_chop ? 1 : 0) +
               (bb_w < thresh_bb_w ? 1 : 0) +
               ((body_r + hl_r == 2) ? 1 : 0) +
               ((entropy < 0.01) ? 1 : 0) +
               (htf_adx < thresh_adx ? 1 : 0) +
               (htf_ci > thresh_chop ? 1 : 0)

is_consol = consol_feats >= thresh_consol_score

// Manipulation Metrics
vol_avg   = ta.sma(volume, len_atr_s)
high_vol  = volume > vol_avg * mult_vol

spread    = high - low
wick_l    = spread > 0 ? (close - low)  / spread : 0.0
wick_u    = spread > 0 ? (high  - close)/ spread : 0.0

vsa_churn   = (high_vol and spread < atr_s) ? 1 : 0
wick_manip  = ((wick_l > thresh_wick or wick_u > thresh_wick) and high_vol) ? 1 : 0

low_sweep  = (low  < ta.lowest(low,  len_pivot)[1])  and high_vol and (close > open) ? 1 : 0
high_sweep = (high > ta.highest(high, len_pivot)[1]) and high_vol and (close < open) ? 1 : 0

ret       = math.log(close / open)
ret_mean  = ta.sma(ret, 20)
ret_sd    = ta.stdev(ret, 20)
ret_z     = (ret_sd != 0) ? (ret - ret_mean) / ret_sd : 0

vol_sd    = ta.stdev(volume, 20)
vol_z     = (vol_sd != 0) ? (volume - vol_avg) / vol_sd : 0

price     = hlc3
num       = math.sum(price * volume, len_vwap)
den       = math.sum(volume, len_vwap)
vwap_val  = den != 0 ? (num / den) : na

vwap_dev  = na(vwap_val) ? 0 : ((math.abs(close - vwap_val) / vwap_val) * 100 > thresh_vwap_dev ? 1 : 0)

sq_ret      = math.pow(ret, 2)
garch_proxy = (ta.ema(sq_ret, 5) > ta.ema(sq_ret, 20) * 1.5) ? 1 : 0

manip_feats = vsa_churn + wick_manip + low_sweep + high_sweep +
              ((math.abs(ret_z) > 3) ? 1 : 0) +
              ((vol_z > 2) ? 1 : 0) +
              vwap_dev + garch_proxy

is_manip = manip_feats >= thresh_manip_score

// =========================
// VIRAL VISUAL ENGINE
// =========================

// Intensity ratios
float c_intensity = math.min(consol_feats / 8.0, 1.0)
float m_intensity = math.min(manip_feats / 8.0, 1.0)

// --- Dynamic Backgrounds ---
color bg_consol = color.new(#00F0FF, int(95 - c_intensity * 25))
color bg_manip  = color.new(#FF0055, int(95 - m_intensity * 40))

bgcolor(is_consol and not is_manip ? bg_consol : na, title="Consolidation BG")
bgcolor(is_manip ? bg_manip : na, title="Manipulation BG")

// --- Bar Coloring ---
color bc_manip  = color.new(#FF0055, int(90 - m_intensity * 50))
color bc_consol = color.new(#00F0FF, int(92 - c_intensity * 35))

barcolor(is_manip ? bc_manip : is_consol ? bc_consol : na, title="Bar Tint")

// --- Consolidation Zone System (Box + Lines) ---
var box   zone_box = na
var line  zone_hi  = na
var line  zone_lo  = na
var float z_h      = na
var float z_l      = na

if is_consol
    float cur_h = ta.highest(high, 10)
    float cur_l = ta.lowest(low, 10)
    color fill_col   = is_manip ? color.new(#FF0055, 88) : color.new(#00FFFF, 90)
    color border_col = is_manip ? color.new(#FF0055, 50) : color.new(#00CED1, 55)

    if not is_consol[1]
        z_h := cur_h
        z_l := cur_l
        zone_box := box.new(left=bar_index, top=z_h, right=bar_index, bottom=z_l,
             bgcolor=fill_col, border_color=border_col, border_width=2,
             border_style=line.style_dashed)
        zone_hi := line.new(x1=bar_index, y1=z_h, x2=bar_index, y2=z_h,
             color=border_col, style=line.style_dashed, width=2, extend=extend.right)
        zone_lo := line.new(x1=bar_index, y1=z_l, x2=bar_index, y2=z_l,
             color=border_col, style=line.style_dashed, width=2, extend=extend.right)
    else
        z_h := math.max(nz(z_h, cur_h), cur_h)
        z_l := math.min(nz(z_l, cur_l), cur_l)
        if not na(zone_box)
            box.set_right(zone_box, bar_index)
            box.set_top(zone_box, z_h)
            box.set_bottom(zone_box, z_l)
            box.set_bgcolor(zone_box, fill_col)
            box.set_border_color(zone_box, border_col)
        if not na(zone_hi)
            line.set_x2(zone_hi, bar_index)
            line.set_y1(zone_hi, z_h)
            line.set_y2(zone_hi, z_h)
            line.set_color(zone_hi, border_col)
        if not na(zone_lo)
            line.set_x2(zone_lo, bar_index)
            line.set_y1(zone_lo, z_l)
            line.set_y2(zone_lo, z_l)
            line.set_color(zone_lo, border_col)
else
    if not na(zone_hi)
        line.set_extend(zone_hi, extend.none)
    if not na(zone_lo)
        line.set_extend(zone_lo, extend.none)

// --- Event Labels ---
if low_sweep == 1
    label.new(bar_index, low, "▼ SWEEP", yloc=yloc.belowbar, style=label.style_label_up,
         color=color.new(color.green, 0), textcolor=color.white, size=size.small)

if high_sweep == 1
    label.new(bar_index, high, "▲ SWEEP", yloc=yloc.abovebar, style=label.style_label_down,
         color=color.new(color.red, 0), textcolor=color.white, size=size.small)




// --- Live Score HUD (replaces table) ---
var label hud = na
if barstate.islast
    string txt = "CONSOL  " + str.tostring(consol_feats, "#") + "/8\nMANIP   " + str.tostring(manip_feats, "#") + "/8"
    if na(hud)
        hud := label.new(bar_index, close, txt, xloc=xloc.bar_index, style=label.style_label_left,
             color=color.new(#0F0F23, 10), textcolor=color.white, size=size.small, textalign=text.align_left)
    else
        label.set_xy(hud, bar_index, close)
        label.set_text(hud, txt)
        label.set_color(hud, is_manip ? color.new(#FF0055, 20) : is_consol ? color.new(#00F0FF, 20) : color.new(#0F0F23, 10))
````
