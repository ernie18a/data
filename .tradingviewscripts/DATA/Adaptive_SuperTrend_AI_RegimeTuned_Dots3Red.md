<!-- tradingview-pine-id: PUB;99bd1b2f635742afbb3c74521a5c3ea7 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive SuperTrend AI — Regime-Tuned [Dots3Red]

Source: https://www.tradingview.com/script/ZKzpGyvs-Adaptive-SuperTrend-AI-Regime-Tuned-Dots3Red/

## Description

📈 ADAPTIVE SUPERTREND AI — REGIME-TUNED [Dots3Red]
Classic SuperTrend uses one fixed ATR multiplier forever. That single number is a compromise: tight enough to track trends closely, it whipsaws during ranges; wide enough to survive ranges, it lags badly once a real trend starts. This script replaces the fixed multiplier with one that changes based on what kind of market is actually happening, using the same regime-detection engine shared across the Dots3Red catalog.

🧠 THE REGIME ENGINE
Every bar is classified into one of four states using ADX and the Choppiness Index together:

• 📈 TRENDING — ADX confirms directional strength and Choppiness confirms low chop
• 🔁 RANGING — the opposite: weak directional strength, high chop
• ⚡ VOLATILE — current ATR has expanded well beyond its baseline, regardless of direction or chop
• ❔ UNCERTAIN — none of the above conditions are clearly met

The raw regime reading is smoothed by taking the most frequent classification over a short lookback window, so a single noisy bar can't flip the regime label back and forth.

🤔 WHY RANGING GETS THE WIDEST BAND, NOT TRENDING
This is the part that looks backwards at first glance, so it's worth explaining directly. A ranging market chops back and forth around a mean — if the band were narrow here, ordinary noise would cross it constantly, causing false flips. So RANGING gets the widest multiplier (default 3.5×), letting normal chop stay inside the band. A TRENDING market is moving with genuine conviction, so a moderate multiplier (default 2.5×) tracks the move closely without giving back excessive profit before flipping on an actual reversal. VOLATILE conditions get the widest multiplier of all (default 4.5×) as a purely defensive setting, since sudden expansion is unpredictable by nature.

When the regime changes, the active multiplier doesn't jump to its new value instantly — it glides toward it over a configurable number of bars. This prevents the band from visibly teleporting on a regime transition, which would otherwise look jarring and could itself trigger a false flip right at the transition point.

The underlying band mechanics — the ratcheting upper/lower band logic, and a flip only when price closes beyond the active band — are the same as classic SuperTrend. Only the multiplier driving the band width is dynamic.

✅ THE CONFIDENCE LAYER
A SuperTrend flip is a single binary event: price crossed the band, direction changed. This script adds a secondary read on how convincing that flip actually is, using 8 independent checks against the new direction:

1. Close vs. a trend moving average
2. MACD histogram sign
3. Recent higher-high / lower-low structure
4. Close vs. the SuperTrend's own midline (hl2)
5. RSI side of 50
6. +DI vs. -DI dominance
7. Volume above its moving average on a trend-direction bar
8. Whether the regime is currently TRENDING

Every confirmed flip shows this count directly on its label — "▲ 6/8" means 6 of the 8 checks currently agree with the new uptrend. A flip with 7/8 agreement and one with 3/8 are treated identically by the raw band mechanics, but this layer gives a way to distinguish a well-supported flip from a marginal one at a glance.

🎯 FLIP WIN-RATE TRACKING
Each flip is graded once the following flip occurs: did price actually finish above the flip price (for an up-flip) or below it (for a down-flip) by the time direction changed again? This produces a running win rate — for example "58% (n=34)" — shown in the dashboard. It is a simple, honest measure of how the flips on this specific chart have actually played out, not a backtest or a promise about future flips.

🔒 NON-REPAINTING
Flips, confidence readings, and labels are all evaluated only on confirmed (closed) bars. A flip that appears on the chart will not later disappear or move to a different bar as new price data arrives.

🎨 VISUALS AND CUSTOMIZATION
The SuperTrend line and gradient fill are colored by current direction. Flip labels appear directly on confirmed flip bars with their confidence count. An optional background tint can shade the chart by current regime. All four core colors (bullish, bearish, volatile/warning, and uncertain/neutral) are fully customizable in settings, independent of the script's default palette.

The dashboard (position configurable) shows: current direction, current regime, the active ATR multiplier, the confidence count with a progress bar, the running flip win rate, and the raw ADX, Choppiness, and ATR ratio readings behind the regime classification.

🧭 HOW TO USE
👀 Reading the line and fill — the colored line and gradient fill show current direction at a glance. This is the same information classic SuperTrend gives you; the difference here is in how the band width behind that line was chosen.

🧠 Check the regime before trusting the band width — the dashboard's Regime row tells you why the band is currently as wide (or narrow) as it is. A band that looks unusually wide isn't a bug — it likely means the engine has classified the market as RANGING or VOLATILE and widened defensively. Knowing the current regime helps set expectations for how the band will behave if conditions stay the same.

✅ Use the confidence count to gauge flip quality, not to filter flips — every flip is real and non-repainting regardless of its confidence count. The count is a lens for judging how broadly supported a given flip is, not a gate that decides whether one occurs. A "▲ 7/8" flip and a "▲ 3/8" flip both mean the band was crossed; the number tells you how much independent agreement existed at that moment, which is useful context when deciding how much weight to put on that particular signal versus your own analysis.

🎯 Watch the flip win rate as a running self-check on this chart — because it only starts once flips have accumulated and been graded, treat an early or low-sample win rate as inconclusive rather than a verdict. It becomes more informative the longer the script runs on a given symbol and timeframe.

🔔 Regime changes are themselves informative — the alert for a regime change fires independently of any flip. A shift from RANGING to TRENDING, for example, can be useful context on its own, since it signals the band is about to glide toward a different multiplier even before any flip occurs.

🚫 This script describes band behavior, not entries or exits — it does not tell you when to open or close a position. Use it as one input alongside price action, structure, and whatever other analysis you already rely on.

⚙️ SETTINGS
📈 SuperTrend Core
• ATR Length
• Factor — Trending / Ranging / Volatile / Uncertain — the four regime-driven multipliers
• Factor Transition (bars) — how gradually the multiplier glides between regimes

🧠 Regime Engine
• ADX Length, Choppiness Length, ATR Baseline Period
• Trending / Ranging Thresholds — where the combined ADX+Choppiness score is classified
• Volatile ATR Multiple — how far above baseline ATR counts as volatility expansion
• Regime Smoothing — lookback window for the majority-vote smoothing

✅ Confidence Layer
• Trend MA Length, RSI Length, Structure Lookback — parameters for the 8 confidence checks

🎨 Visualization
• Gradient Fill, Flip Labels, Regime Background Tint — each toggleable independently
• Full color customization for all four regime/direction colors

🖥️ Dashboard
• Show/hide, position

📝 NOTES
The regime engine needs a short warm-up period before its smoothing window is fully populated; early bars on a fresh chart may show less stable regime labels than bars further along. The flip win rate starts empty and only becomes meaningful after several flips have occurred and been graded.

⚠️ DISCLAIMER
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical flip win rate does not guarantee future performance.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Adaptive SuperTrend AI — Regime-Tuned [Dots3Red]",
          shorttitle = "SuperTrend AI [D3R]",
          overlay    = true,
          max_labels_count = 500)
          

// COLORS
GRP_COL = "🎨 Colors"
C_CYBER_GREEN = color.new(#00FF9D, 0)  
C_CYBER_RED   = color.new(#FF0055, 0)  

C_BULL    = input.color(#00FF9D, "Bull / Uptrend",  group=GRP_COL)
C_BEAR    = input.color(#FF0055, "Bear / Downtrend", group=GRP_COL)
C_AMBER   = input.color(#FFB700, "Volatile / Warning", group=GRP_COL)
C_NEUTRAL = input.color(#475569, "Uncertain / Neutral", group=GRP_COL)

C_GREEN = C_BULL
C_RED   = C_BEAR

C_BG          = color.new(#0A0E17, 10) // Deep Cyber Void
C_TXT         = color.new(#F8FAFC, 0)  // Crisp Neon White
C_DIM         = color.new(#64748B, 0)  // Dim Gray
C_BORD        = color.new(#1E293B, 0)  // Dark Circuit Border


// INPUTS
GRP_ST  = "📈 SuperTrend Core"
GRP_REG = "🧠 Regime Engine"
GRP_CNF = "✅ Confidence Layer"
GRP_VIS = "🎨 Visualization"
GRP_HUD = "🖥️ Dashboard"

atr_len        = input.int  (10,  "ATR Length", minval=1, group=GRP_ST)
factor_trend   = input.float(2.5, "Factor — Trending", minval=0.5, maxval=10.0, step=0.25, group=GRP_ST,
                 tooltip="ATR multiplier used while the regime is TRENDING. Moderate: tracks the move without giving back too much on reversal.")
factor_range   = input.float(3.5, "Factor — Ranging", minval=0.5, maxval=10.0, step=0.25, group=GRP_ST,
                 tooltip="ATR multiplier while RANGING. Wider than trending so ordinary chop stays inside the band instead of causing false flips.")
factor_vol     = input.float(4.5, "Factor — Volatile", minval=0.5, maxval=10.0, step=0.25, group=GRP_ST,
                 tooltip="Widest multiplier, used during volatility expansion as a defensive setting.")
factor_uncert  = input.float(3.0, "Factor — Uncertain", minval=0.5, maxval=10.0, step=0.25, group=GRP_ST)
factor_smooth  = input.int  (5,   "Factor Transition (bars)", minval=1, maxval=30, group=GRP_ST,
                 tooltip="Bars over which the active factor glides from the old regime's value to the new one, preventing band jumps on regime changes.")

adx_len      = input.int  (14,   "ADX Length",          minval=5,  group=GRP_REG)
chop_len     = input.int  (14,   "Choppiness Length",   minval=5,  group=GRP_REG)
atr_base_len = input.int  (50,   "ATR Baseline Period", minval=10, group=GRP_REG)
trend_thresh = input.float(0.55, "Trending Threshold",  minval=0.3, maxval=0.9, step=0.05, group=GRP_REG)
range_thresh = input.float(0.45, "Ranging Threshold",   minval=0.2, maxval=0.8, step=0.05, group=GRP_REG)
vol_thresh   = input.float(1.6,  "Volatile ATR Mult",   minval=1.0, maxval=4.0, step=0.1,  group=GRP_REG)
smooth_len   = input.int  (5,    "Regime Smoothing",    minval=1,  maxval=15, group=GRP_REG)

conf_ma_len  = input.int(50, "Confidence: Trend MA Length", group=GRP_CNF)
conf_rsi_len = input.int(14, "Confidence: RSI Length", group=GRP_CNF)
conf_struct  = input.int(10, "Confidence: Structure Lookback", minval=3, maxval=50, group=GRP_CNF,
               tooltip="Bars for the higher-high / lower-low structure check.")

show_fill      = input.bool(true, "Gradient Fill", group=GRP_VIS)
show_flips     = input.bool(true, "Flip Labels with Confidence", group=GRP_VIS)
show_regime_bg = input.bool(false, "Regime Background Tint", group=GRP_VIS)

show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)


// REGIME ENGINE — ADX + Choppiness 
atr14       = ta.atr(14)
atr_base_ma = ta.sma(atr14, atr_base_len)
atr_ratio   = atr14 / math.max(atr_base_ma, 1e-9)

[_dp, _dm, adx_val] = ta.dmi(adx_len, adx_len)
tr_sum   = math.sum(ta.tr(true), chop_len)
hi_max   = ta.highest(high, chop_len)
lo_min   = ta.lowest(low, chop_len)
chop_raw = 100.0 * math.log10(tr_sum / math.max(hi_max - lo_min, 1e-9)) / math.log10(chop_len)

adx_norm    = math.min(adx_val / 60.0, 1.0)
chop_norm   = 1.0 - math.min((chop_raw - 38.0) / 62.0, 1.0)
trend_score = (adx_norm + chop_norm) / 2.0

f_mode(src, len) =>
    int c0 = 0
    int c1 = 0
    int c2 = 0
    int c3 = 0
    for k = 0 to len - 1
        v = src[k]
        if v == 0
            c0 += 1
        else if v == 1
            c1 += 1
        else if v == 2
            c2 += 1
        else
            c3 += 1
    mx = math.max(c0, c1, c2, c3)
    mx == c3 ? 3 : mx == c1 ? 1 : mx == c2 ? 2 : 0

raw_regime = atr_ratio > vol_thresh    ? 3 :
             trend_score > trend_thresh ? 1 :
             trend_score < range_thresh ? 2 : 0
regime     = f_mode(raw_regime, smooth_len)

is_trending  = regime == 1
is_ranging   = regime == 2
is_volatile  = regime == 3

reg_col   = is_trending ? C_BULL : is_ranging ? C_BEAR : is_volatile ? C_AMBER : C_NEUTRAL
reg_label = is_trending ? "TRENDING" : is_ranging ? "RANGING" : is_volatile ? "VOLATILE" : "UNCERTAIN"


// REGIME-DRIVEN FACTOR with smooth transition
float target_factor = is_trending ? factor_trend :
                      is_ranging  ? factor_range :
                      is_volatile ? factor_vol   : factor_uncert

var float active_factor = na
if na(active_factor)
    active_factor := target_factor
else
    active_factor := active_factor + (target_factor - active_factor) / float(factor_smooth)


// SUPERTREND CORE 
st_atr = ta.atr(atr_len)
float src_mid = hl2

float upper_basic = src_mid + active_factor * st_atr
float lower_basic = src_mid - active_factor * st_atr

var float upper_band = na
var float lower_band = na
var int   direction  = 1   // 1 = uptrend (price above lower band), -1 = downtrend

upper_band := na(upper_band[1]) ? upper_basic :
              (upper_basic < upper_band[1] or close[1] > upper_band[1]) ? upper_basic : upper_band[1]
lower_band := na(lower_band[1]) ? lower_basic :
              (lower_basic > lower_band[1] or close[1] < lower_band[1]) ? lower_basic : lower_band[1]

var int prev_direction = 1
prev_direction := direction

if direction == 1
    if close < lower_band
        direction := -1
else
    if close > upper_band
        direction := 1

float st_line = direction == 1 ? lower_band : upper_band
bool  flipped_up   = direction == 1  and prev_direction == -1
bool  flipped_down = direction == -1 and prev_direction == 1


// CONFIDENCE LAYER — 8 independent checks vs current direction
conf_ma   = ta.sma(close, conf_ma_len)
conf_rsi  = ta.rsi(close, conf_rsi_len)
[macd_l, macd_s, macd_h] = ta.macd(close, 12, 26, 9)

bool chk1 = direction == 1 ? close > conf_ma  : close < conf_ma
bool chk2 = direction == 1 ? macd_h > 0        : macd_h < 0
bool chk3 = direction == 1
             ? high > ta.highest(high, conf_struct)[1]
             : low  < ta.lowest(low,  conf_struct)[1]
bool chk4 = direction == 1 ? close > src_mid   : close < src_mid
bool chk5 = direction == 1 ? conf_rsi > 50     : conf_rsi < 50
bool chk6 = direction == 1 ? _dp > _dm         : _dm > _dp
float vol_ma20 = ta.sma(volume, 20)
bool chk7 = volume > vol_ma20 and (direction == 1 ? close > open : close < open)
bool chk8 = is_trending

int confidence = (chk1 ? 1 : 0) + (chk2 ? 1 : 0) + (chk3 ? 1 : 0) + (chk4 ? 1 : 0) +
                 (chk5 ? 1 : 0) + (chk6 ? 1 : 0) + (chk7 ? 1 : 0) + (chk8 ? 1 : 0)

color conf_col = confidence >= 6 ? C_GREEN : confidence >= 4 ? C_AMBER : C_RED


// FLIP TRACKING — historical accuracy of flips
var int flips_total   = 0
var int flips_correct = 0
var float last_flip_price = na
var int   last_flip_dir   = 0

if barstate.isconfirmed and (flipped_up or flipped_down)
    // Grade the PREVIOUS flip before recording this one
    if not na(last_flip_price) and last_flip_dir != 0
        flips_total += 1
        bool was_correct = last_flip_dir == 1
                           ? close > last_flip_price
                           : close < last_flip_price
        if was_correct
            flips_correct += 1
    last_flip_price := close
    last_flip_dir   := direction

float flip_winrate = flips_total > 0 ? float(flips_correct) / float(flips_total) * 100.0 : na


// VISUALS
color line_c = direction == 1 ? C_BULL : C_BEAR

p_st    = plot(st_line, "SuperTrend", color=color.new(line_c,35), linewidth=2)
p_price = plot(hl2, display=display.none)

fill(p_price, p_st,
     color = show_fill ? color.new(line_c, 79) : na,
     title = "Trend Fill")

bgcolor(show_regime_bg ? color.new(reg_col, 85) : na)

if show_flips and barstate.isconfirmed
    if flipped_up
        label.new(bar_index, st_line,
                   "▲ " + str.tostring(confidence) + "/8",
                   style=label.style_label_up,
                   color=color.new(C_BULL,30), textcolor=color.new(color.black,0),
                   size=11)
    if flipped_down
        label.new(bar_index, st_line,
                  "▼ " + str.tostring(confidence) + "/8",
                  style=label.style_label_down,
                  color=color.new(C_BEAR, 40), textcolor=color.white,
                  size=11)


// DASHBOARD
f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

var table hud = table.new(f_hud_pos(hud_pos), 2, 10,
                           bgcolor=C_BG, border_color=C_BORD,
                           border_width=1, frame_color=C_BORD, frame_width=2)

if show_hud and barstate.islast
    table.cell(hud, 0, 0, "ADAPTIVE ST [D3R]", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 0), text_size=10, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "Direction", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 1, direction == 1 ? "▲ UP" : "▼ DOWN",
               text_color=line_c, bgcolor=color.new(#1e293b, 40),
               text_size=11, text_halign=text.align_center, text_formatting=text.format_bold)

    table.cell(hud, 0, 2, "Regime", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 2, reg_label, text_color=reg_col, bgcolor=color.new(#0f172a, 40),
               text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 3, "Active Factor", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 3, str.tostring(active_factor, "#.##") + "× ATR",
               text_color=C_TXT, bgcolor=color.new(#1e293b, 40),
               text_size=11, text_halign=text.align_center)

    string conf_pb = ""
    for _i = 1 to 8
        conf_pb += _i <= confidence ? "■" : "□"
    table.cell(hud, 0, 4, "Confidence", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 4, conf_pb + " " + str.tostring(confidence) + "/8",
               text_color=conf_col, bgcolor=color.new(#0f172a, 40),
               text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 5, "Flip Win Rate", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 5, na(flip_winrate) ? "—" : str.tostring(math.round(flip_winrate)) + "%  (n=" + str.tostring(flips_total) + ")",
               text_color=na(flip_winrate) ? C_DIM : flip_winrate >= 50 ? C_GREEN : C_RED,
               bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 6, "ADX", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 6, str.tostring(math.round(adx_val, 1)),
               text_color=adx_val > 25 ? C_BULL : C_DIM, bgcolor=color.new(#0f172a, 40),
               text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 7, "Choppiness", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 7, str.tostring(math.round(chop_raw, 1)),
               text_color=chop_raw > 61.8 ? C_BEAR : C_DIM, bgcolor=color.new(#1e293b, 40),
               text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 8, "ATR Ratio", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 8, str.tostring(math.round(atr_ratio, 2)) + "×",
               text_color=atr_ratio > vol_thresh ? C_AMBER : C_DIM, bgcolor=color.new(#0f172a, 40),
               text_size=11, text_halign=text.align_center)


// ALERTS
bool flip_up_confirmed   = barstate.isconfirmed and flipped_up
bool flip_down_confirmed = barstate.isconfirmed and flipped_down

alertcondition(flip_up_confirmed,   "Flip Up",   "D3R Adaptive ST: trend flipped UP (confirmed bar)")
alertcondition(flip_down_confirmed, "Flip Down", "D3R Adaptive ST: trend flipped DOWN (confirmed bar)")
alertcondition(ta.change(regime) != 0, "Regime Changed", "D3R Adaptive ST: market regime shifted — band factor adapting")
````
