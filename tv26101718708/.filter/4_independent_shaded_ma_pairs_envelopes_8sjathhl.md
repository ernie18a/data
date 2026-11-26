# 4 Independent Shaded MA Pairs + Envelopes

- url: https://www.tradingview.com/script/8SJathHL-4-Independent-Shaded-MA-Pairs-Envelopes/
- type: indicator
- pine_id: PUB;1e64f8580e7b4c1cb6214446eea9f5aa
- version: 2.0

## Description

This Pine Script creates a highly customizable multi-pair Moving Average indicator with shading and optional envelopes. It displays up to 4 completely independent MA pairs on the chart, where each pair consists of two moving averages (MA1 and MA2) that can have:
Different timeframes (multi-timeframe capable)
Different lengths and types (SMA, EMA, WMA, HMA, RMA, VWMA)
Different sources (close, open, hl2, etc.)
Individual colors

For each pair, you can also add envelopes (bands) around either MA1 or MA2, in either Points or Percent, with Upper, Lower, or Both lines. 

The script includes shaded fills between MA1  MA2 (the main visual feature) and optional fills between MAs and their envelopes.

Main Use Cases:
Multi-Timeframe Trend & Structure Analysis

The most powerful use. Example setup:Pair 1: Two 32-period Dailies (fast structure)
Pair 2: Two 64-period Dailies or 4H
Pair 3/4: Higher timeframes (Weekly or 200+ periods)
This gives you a clean "layered" view of trend across different scales.

Visual "Zones" or Dynamic Support/Resistance
The shaded areas between each MA pair act as visual value zones. When price is inside a fill, it's in "equilibrium"; when it breaks out, it shows conviction.

Envelope Trading Strategies
Use the envelopes like dynamic Keltner Channels or Donchian-style bands for: Mean reversion (price touching envelope)
Breakout entries
Volatility visualization

Clean Alternative to MA Ribbons
Instead of 8–10 individual MAs cluttering the chart, you get 4 controlled, color-coded, shaded pairs that are easier to read.

Confluence Tool
Look for moments when multiple pairs align (e.g., all MA1s above MA2s + price breaking upper envelopes) for high-probability directional bias.

Strengths: Very flexible and clean
Excellent for discretionary traders who use multiple moving averages
Great visual clarity thanks to the fills

Typical Trading Style:
Swing trading, position trading, and ICT/SMC-style traders who like higher-timeframe bias combined with lower-timeframe execution.

## Source Code

````pine
//@version=6
indicator("4 Independent Shaded MA Pairs + Envelopes 3.0", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ── GLOBAL SETTINGS ─────────────────────────────────────────────────────
line_width = input.int(2, "Line Width", minval=1, maxval=10, group="Global Settings")

// ── HELPER FUNCTIONS ────────────────────────────────────────────────────
f_get_ma(tf, length, type, src) =>
    switch type
        "EMA"  => request.security(syminfo.tickerid, tf, ta.ema(src, length),  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
        "WMA"  => request.security(syminfo.tickerid, tf, ta.wma(src, length),  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
        "HMA"  => request.security(syminfo.tickerid, tf, ta.hma(src, length),  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
        "RMA"  => request.security(syminfo.tickerid, tf, ta.rma(src, length),  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
        "VWMA" => request.security(syminfo.tickerid, tf, ta.vwma(src, length), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
        =>     request.security(syminfo.tickerid, tf, ta.sma(src, length),   gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_envelope(ma, value, type, direction) =>
    type == "Percent" ?
         (direction == "Upper" ? ma * (1 + value/100) : ma * (1 - value/100)) :
         (direction == "Upper" ? ma + value : ma - value)

f_get_crossover_fill_color_pair(ma_fast, ma_slow, active, dyn_enable, bull_col, bear_col) =>
    if not active or not dyn_enable
        na
    else if na(ma_fast) or na(ma_slow)
        na
    else if ta.crossover(ma_fast, ma_slow)
        bull_col
    else if ta.crossunder(ma_fast, ma_slow)
        bear_col
    else
        // Maintain state based on which MA is higher
        ma_fast > ma_slow ? bull_col : bear_col

// ==================== PAIR 1 ====================
show1 = input.bool(true, "Show Pair 1", group="Pair 1")

// MA 1
tf1a   = input.timeframe("D",  "MA1 Timeframe", group="Pair 1")
len1a  = input.int(32, "MA1 Length", minval=1, group="Pair 1")
type1a = input.string("SMA", "MA1 Type", options=["SMA","EMA","WMA","HMA","RMA","VWMA"], group="Pair 1")
src1a  = input.source(close, "MA1 Source", group="Pair 1")
col1a  = input.color(#2196F3, "MA1 Color", group="Pair 1")

// MA 2
tf1b   = input.timeframe("D",  "MA2 Timeframe", group="Pair 1")
len1b  = input.int(32, "MA2 Length", minval=1, group="Pair 1")
type1b = input.string("SMA", "MA2 Type", options=["SMA","EMA","WMA","HMA","RMA","VWMA"], group="Pair 1")
src1b  = input.source(close, "MA2 Source", group="Pair 1")
col1b  = input.color(#2196F3, "MA2 Color", group="Pair 1")

// Crossover Fill Settings for Pair 1 (INDEPENDENT!)
fill1              = input.bool(true, "Fill MA1 ↔ MA2", group="Pair 1 - Crossover Fill")
dyn_fill1          = input.bool(true, "● Enable Dynamic Fill", group="Pair 1 - Crossover Fill")
bull_color1        = input.color(#00E676, "Bullish Fill Color", group="Pair 1 - Crossover Fill")
bear_color1        = input.color(#FF1744, "Bearish Fill Color", group="Pair 1 - Crossover Fill")
fill_opacity1      = input.int(70, "Fill Opacity (%)", minval=0, maxval=100, group="Pair 1 - Crossover Fill")

// Envelope Settings
env_base1   = input.string("MA1", "Envelope Base", options=["MA1", "MA2"], group="Pair 1 - Envelope")
env_mode1   = input.string("None", "Envelope Lines", options=["None", "Upper", "Lower", "Both"], group="Pair 1 - Envelope")
env_type1   = input.string("Points", "Envelope Type", options=["Percent", "Points"], group="Pair 1 - Envelope")
env_value1  = input.float(0.2441405, "Envelope Value", minval=0.000000001, group="Pair 1 - Envelope")
env_col_up1 = input.color(#2196F3, "Upper Envelope Color", group="Pair 1 - Envelope")
env_col_dn1 = input.color(#2196F3, "Lower Envelope Color", group="Pair 1 - Envelope")

// Static Fills for Pair 1
static_fill_upper1 = input.bool(false, "Fill MA1 ↔ Upper", group="Pair 1 - Static Fills")
static_fill_lower1 = input.bool(false, "Fill MA1 ↔ Lower", group="Pair 1 - Static Fills")
static_fill_outer1 = input.bool(false, "Fill MA2 ↔ Upper", group="Pair 1 - Static Fills")
static_fill_opp1   = input.bool(false, "Fill MA2 ↔ Lower", group="Pair 1 - Static Fills")
static_fill_env1   = input.bool(false, "Fill Upper ↔ Lower", group="Pair 1 - Static Fills")

// ==================== PAIR 2 ====================
show2 = input.bool(true, "Show Pair 2", group="Pair 2")

tf2a   = input.timeframe("D",  "MA1 Timeframe", group="Pair 2")
len2a  = input.int(64, "MA1 Length", minval=1, group="Pair 2")
type2a = input.string("SMA", "MA1 Type", options=["SMA","EMA","WMA","HMA","RMA","VWMA"], group="Pair 2")
src2a  = input.source(close, "MA1 Source", group="Pair 2")
col2a  = input.color(#FF9800, "MA1 Color", group="Pair 2")

tf2b   = input.timeframe("D",  "MA2 Timeframe", group="Pair 2")
len2b  = input.int(64, "MA2 Length", minval=1, group="Pair 2")
type2b = input.string("SMA", "MA2 Type", options=["SMA","EMA","WMA","HMA","RMA","VWMA"], group="Pair 2")
src2b  = input.source(close, "MA2 Source", group="Pair 2")
col2b  = input.color(#FF9800, "MA2 Color", group="Pair 2")

// Crossover Fill Settings for Pair 2 (INDEPENDENT!)
fill2              = input.bool(true, "Fill MA1 ↔ MA2", group="Pair 2 - Crossover Fill")
dyn_fill2          = input.bool(true, "● Enable Dynamic Fill", group="Pair 2 - Crossover Fill")
bull_color2        = input.color(#00E676, "Bullish Fill Color", group="Pair 2 - Crossover Fill")
bear_color2        = input.color(#FF1744, "Bearish Fill Color", group="Pair 2 - Crossover Fill")
fill_opacity2      = input.int(70, "Fill Opacity (%)", minval=0, maxval=100, group="Pair 2 - Crossover Fill")

env_base2   = input.string("MA1", "Envelope Base", options=["MA1", "MA2"], group="Pair 2 - Envelope")
env_mode2   = input.string("None", "Envelope Lines", options=["None", "Upper", "Lower", "Both"], group="Pair 2 - Envelope")
env_type2   = input.string("Points", "Envelope Type", options=["Percent", "Points"], group="Pair 2 - Envelope")
env_value2  = input.float(0.488281, "Envelope Value", minval=0.0000000001, group="Pair 2 - Envelope")
env_col_up2 = input.color(#FF9800, "Upper Envelope Color", group="Pair 2 - Envelope")
env_col_dn2 = input.color(#FF9800, "Lower Envelope Color", group="Pair 2 - Envelope")

static_fill_upper2 = input.bool(false, "Fill MA1 ↔ Upper", group="Pair 2 - Static Fills")
static_fill_lower2 = input.bool(false, "Fill MA1 ↔ Lower", group="Pair 2 - Static Fills")
static_fill_outer2 = input.bool(false, "Fill MA2 ↔ Upper", group="Pair 2 - Static Fills")
static_fill_opp2   = input.bool(false, "Fill MA2 ↔ Lower", group="Pair 2 - Static Fills")
static_fill_env2   = input.bool(false, "Fill Upper ↔ Lower", group="Pair 2 - Static Fills")

// ==================== PAIR 3 ====================
show3 = input.bool(false, "Show Pair 3", group="Pair 3")

tf3a   = input.timeframe("D",  "MA1 Timeframe", group="Pair 3")
len3a  = input.int(128, "MA1 Length", minval=1, group="Pair 3")
type3a = input.string("SMA", "MA1 Type", options=["SMA","EMA","WMA","HMA","RMA","VWMA"], group="Pair 3")
src3a  = input.source(close, "MA1 Source", group="Pair 3")
col3a  = input.color(#fbff00, "MA1 Color", group="Pair 3")

tf3b   = input.timeframe("D",  "MA2 Timeframe", group="Pair 3")
len3b  = input.int(128, "MA2 Length", minval=1, group="Pair 3")
type3b = input.string("SMA", "MA2 Type", options=["SMA","EMA","WMA","HMA","RMA","VWMA"], group="Pair 3")
src3b  = input.source(close, "MA2 Source", group="Pair 3")
col3b  = input.color(#fbff00, "MA2 Color", group="Pair 3")

// Crossover Fill Settings for Pair 3 (INDEPENDENT!)
fill3              = input.bool(true, "Fill MA1 ↔ MA2", group="Pair 3 - Crossover Fill")
dyn_fill3          = input.bool(false, "● Enable Dynamic Fill", group="Pair 3 - Crossover Fill")
bull_color3        = input.color(#00E676, "Bullish Fill Color", group="Pair 3 - Crossover Fill")
bear_color3        = input.color(#FF1744, "Bearish Fill Color", group="Pair 3 - Crossover Fill")
fill_opacity3      = input.int(70, "Fill Opacity (%)", minval=0, maxval=100, group="Pair 3 - Crossover Fill")

env_base3   = input.string("MA1", "Envelope Base", options=["MA1", "MA2"], group="Pair 3 - Envelope")
env_mode3   = input.string("None", "Envelope Lines", options=["None", "Upper", "Lower", "Both"], group="Pair 3 - Envelope")
env_type3   = input.string("Points", "Envelope Type", options=["Percent", "Points"], group="Pair 3 - Envelope")
env_value3  = input.float(0.976562, "Envelope Value", minval=0.000000001, group="Pair 3 - Envelope")
env_col_up3 = input.color(#fbff00, "Upper Envelope Color", group="Pair 3 - Envelope")
env_col_dn3 = input.color(#fbff00, "Lower Envelope Color", group="Pair 3 - Envelope")

static_fill_upper3 = input.bool(false, "Fill MA1 ↔ Upper", group="Pair 3 - Static Fills")
static_fill_lower3 = input.bool(false, "Fill MA1 ↔ Lower", group="Pair 3 - Static Fills")
static_fill_outer3 = input.bool(false, "Fill MA2 ↔ Upper", group="Pair 3 - Static Fills")
static_fill_opp3   = input.bool(false, "Fill MA2 ↔ Lower", group="Pair 3 - Static Fills")
static_fill_env3   = input.bool(false, "Fill Upper ↔ Lower", group="Pair 3 - Static Fills")

// ==================== PAIR 4 ====================
show4 = input.bool(false, "Show Pair 4", group="Pair 4")

tf4a   = input.timeframe("D",  "MA1 Timeframe", group="Pair 4")
len4a  = input.int(120, "MA1 Length", minval=1, group="Pair 4")
type4a = input.string("SMA", "MA1 Type", options=["SMA","EMA","WMA","HMA","RMA","VWMA"], group="Pair 4")
src4a  = input.source(close, "MA1 Source", group="Pair 4")
col4a  = input.color(#4CAF50, "MA1 Color", group="Pair 4")

tf4b   = input.timeframe("D", "MA2 Timeframe", group="Pair 4")
len4b  = input.int(500, "MA2 Length", minval=1, group="Pair 4")
type4b = input.string("SMA", "MA2 Type", options=["SMA","EMA","WMA","HMA","RMA","VWMA"], group="Pair 4")
src4b  = input.source(close, "MA2 Source", group="Pair 4")
col4b  = input.color(#4CAF50, "MA2 Color", group="Pair 4")

// Crossover Fill Settings for Pair 4 (INDEPENDENT!)
fill4              = input.bool(true, "Fill MA1 ↔ MA2", group="Pair 4 - Crossover Fill")
dyn_fill4          = input.bool(false, "Enable Dynamic Fill", group="Pair 4 - Crossover Fill")
bull_color4        = input.color(#00E676, "Bullish Fill Color", group="Pair 4 - Crossover Fill")
bear_color4        = input.color(#FF1744, "Bearish Fill Color", group="Pair 4 - Crossover Fill")
fill_opacity4      = input.int(70, "Fill Opacity (%)", minval=0, maxval=100, group="Pair 4 - Crossover Fill")

env_base4   = input.string("MA1", "Envelope Base", options=["MA1", "MA2"], group="Pair 4 - Envelope")
env_mode4   = input.string("None", "Envelope Lines", options=["None", "Upper", "Lower", "Both"], group="Pair 4 - Envelope")
env_type4   = input.string("Points", "Envelope Type", options=["Percent", "Points"], group="Pair 4 - Envelope")
env_value4  = input.float(2.0, "Envelope Value", minval=0.000000001, group="Pair 4 - Envelope")
env_col_up4 = input.color(#4CAF50, "Upper Envelope Color", group="Pair 4 - Envelope")
env_col_dn4 = input.color(#4CAF50, "Lower Envelope Color", group="Pair 4 - Envelope")

static_fill_upper4 = input.bool(false, "Fill MA1 ↔ Upper", group="Pair 4 - Static Fills")
static_fill_lower4 = input.bool(false, "Fill MA1 ↔ Lower", group="Pair 4 - Static Fills")
static_fill_outer4 = input.bool(false, "Fill MA2 ↔ Upper", group="Pair 4 - Static Fills")
static_fill_opp4   = input.bool(false, "Fill MA2 ↔ Lower", group="Pair 4 - Static Fills")
static_fill_env4   = input.bool(false, "Fill Upper ↔ Lower", group="Pair 4 - Static Fills")


// ── CALCULATIONS ────────────────────────────────────────────────────────
ma1a = show1 ? f_get_ma(tf1a, len1a, type1a, src1a) : na
ma1b = show1 ? f_get_ma(tf1b, len1b, type1b, src1b) : na
ma2a = show2 ? f_get_ma(tf2a, len2a, type2a, src2a) : na
ma2b = show2 ? f_get_ma(tf2b, len2b, type2b, src2b) : na
ma3a = show3 ? f_get_ma(tf3a, len3a, type3a, src3a) : na
ma3b = show3 ? f_get_ma(tf3b, len3b, type3b, src3b) : na
ma4a = show4 ? f_get_ma(tf4a, len4a, type4a, src4a) : na
ma4b = show4 ? f_get_ma(tf4b, len4b, type4b, src4b) : na

// Envelope Calculations
base1 = env_base1 == "MA1" ? ma1a : ma1b
u1 = (env_mode1 == "Upper" or env_mode1 == "Both") and show1 ? f_envelope(base1, env_value1, env_type1, "Upper") : na
l1 = (env_mode1 == "Lower" or env_mode1 == "Both") and show1 ? f_envelope(base1, env_value1, env_type1, "Lower") : na

base2 = env_base2 == "MA1" ? ma2a : ma2b
u2 = (env_mode2 == "Upper" or env_mode2 == "Both") and show2 ? f_envelope(base2, env_value2, env_type2, "Upper") : na
l2 = (env_mode2 == "Lower" or env_mode2 == "Both") and show2 ? f_envelope(base2, env_value2, env_type2, "Lower") : na

base3 = env_base3 == "MA1" ? ma3a : ma3b
u3 = (env_mode3 == "Upper" or env_mode3 == "Both") and show3 ? f_envelope(base3, env_value3, env_type3, "Upper") : na
l3 = (env_mode3 == "Lower" or env_mode3 == "Both") and show3 ? f_envelope(base3, env_value3, env_type3, "Lower") : na

base4 = env_base4 == "MA1" ? ma4a : ma4b
u4 = (env_mode4 == "Upper" or env_mode4 == "Both") and show4 ? f_envelope(base4, env_value4, env_type4, "Upper") : na
l4 = (env_mode4 == "Lower" or env_mode4 == "Both") and show4 ? f_envelope(base4, env_value4, env_type4, "Lower") : na

// Calculate independent crossover fill colors for each pair
fill_color1 = f_get_crossover_fill_color_pair(ma1a, ma1b, fill1 and show1, dyn_fill1, bull_color1, bear_color1)
fill_color2 = f_get_crossover_fill_color_pair(ma2a, ma2b, fill2 and show2, dyn_fill2, bull_color2, bear_color2)
fill_color3 = f_get_crossover_fill_color_pair(ma3a, ma3b, fill3 and show3, dyn_fill3, bull_color3, bear_color3)
fill_color4 = f_get_crossover_fill_color_pair(ma4a, ma4b, fill4 and show4, dyn_fill4, bull_color4, bear_color4)

// ── PLOTS ───────────────────────────────────────────────────────────────
p1a = plot(ma1a, "Pair 1 MA1", col1a, linewidth=line_width)
p1b = plot(ma1b, "Pair 1 MA2", col1b, linewidth=line_width)
p1u = plot(u1,   "Pair 1 Upper Env", env_col_up1, linewidth=line_width)
p1l = plot(l1,   "Pair 1 Lower Env", env_col_dn1, linewidth=line_width)

p2a = plot(ma2a, "Pair 2 MA1", col2a, linewidth=line_width)
p2b = plot(ma2b, "Pair 2 MA2", col2b, linewidth=line_width)
p2u = plot(u2,   "Pair 2 Upper Env", env_col_up2, linewidth=line_width)
p2l = plot(l2,   "Pair 2 Lower Env", env_col_dn2, linewidth=line_width)

p3a = plot(ma3a, "Pair 3 MA1", col3a, linewidth=line_width)
p3b = plot(ma3b, "Pair 3 MA2", col3b, linewidth=line_width)
p3u = plot(u3,   "Pair 3 Upper Env", env_col_up3, linewidth=line_width)
p3l = plot(l3,   "Pair 3 Lower Env", env_col_dn3, linewidth=line_width)

p4a = plot(ma4a, "Pair 4 MA1", col4a, linewidth=line_width)
p4b = plot(ma4b, "Pair 4 MA2", col4b, linewidth=line_width)
p4u = plot(u4,   "Pair 4 Upper Env", env_col_up4, linewidth=line_width)
p4l = plot(l4,   "Pair 4 Lower Env", env_col_dn4, linewidth=line_width)

// ── FILLS ───────────────────────────────────────────────────────────────
// Independent dynamic fills for each pair
fill(p1a, p1b, color=not na(fill_color1) ? color.new(fill_color1, 100-fill_opacity1) : na, title="Pair 1 Fill")
fill(p2a, p2b, color=not na(fill_color2) ? color.new(fill_color2, 100-fill_opacity2) : na, title="Pair 2 Fill")
fill(p3a, p3b, color=not na(fill_color3) ? color.new(fill_color3, 100-fill_opacity3) : na, title="Pair 3 Fill")
fill(p4a, p4b, color=not na(fill_color4) ? color.new(fill_color4, 100-fill_opacity4) : na, title="Pair 4 Fill")

// Independent static envelope fills for each pair
fill(p1a, p1u, color = static_fill_upper1 ? color.new(env_col_up1, 75) : na)
fill(p1a, p1l, color = static_fill_lower1 ? color.new(env_col_dn1, 75) : na)
fill(p1b, p1u, color = static_fill_outer1 ? color.new(env_col_up1, 75) : na)
fill(p1b, p1l, color = static_fill_opp1 ? color.new(env_col_dn1, 75) : na)
fill(p1u, p1l, color = static_fill_env1 ? color.new(env_col_dn1, 90) : na)

fill(p2a, p2u, color = static_fill_upper2 ? color.new(env_col_up2, 75) : na)
fill(p2a, p2l, color = static_fill_lower2 ? color.new(env_col_dn2, 75) : na)
fill(p2b, p2u, color = static_fill_outer2 ? color.new(env_col_up2, 75) : na)
fill(p2b, p2l, color = static_fill_opp2 ? color.new(env_col_dn2, 75) : na)
fill(p2u, p2l, color = static_fill_env2 ? color.new(env_col_dn2, 90) : na)

fill(p3a, p3u, color = static_fill_upper3 ? color.new(env_col_up3, 75) : na)
fill(p3a, p3l, color = static_fill_lower3 ? color.new(env_col_dn3, 75) : na)
fill(p3b, p3u, color = static_fill_outer3 ? color.new(env_col_up3, 75) : na)
fill(p3b, p3l, color = static_fill_opp3 ? color.new(env_col_dn3, 75) : na)
fill(p3u, p3l, color = static_fill_env3 ? color.new(env_col_dn3, 90) : na)

fill(p4a, p4u, color = static_fill_upper4 ? color.new(env_col_up4, 75) : na)
fill(p4a, p4l, color = static_fill_lower4 ? color.new(env_col_dn4, 75) : na)
fill(p4b, p4u, color = static_fill_outer4 ? color.new(env_col_up4, 75) : na)
fill(p4b, p4l, color = static_fill_opp4 ? color.new(env_col_dn4, 75) : na)
fill(p4u, p4l, color = static_fill_env4 ? color.new(env_col_dn4, 90) : na)
````
