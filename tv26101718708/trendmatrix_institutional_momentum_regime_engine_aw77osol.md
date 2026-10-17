# TrendMatrix: Institutional Momentum & Regime Engine

- url: https://www.tradingview.com/script/Aw77oSol-TrendMatrix-Institutional-Momentum-Regime-Engine/
- type: indicator
- pine_id: PUB;8ff51489dd1b412095110bdc31e3c776
- version: 2.0

## Description

[TM] Institutional Momentum Engine.

The market is driven by vast amounts of data—volatility regimes, relative volume, and macro trend alignment. The [TM] Institutional Momentum Engine is designed to capture this institutional-grade data and bring it to your fingertips in one clean, actionable dashboard.

This engine is the precision counterpart to the TrendMatrix Screener suite. While our screeners scan the market to identify opportunities, this engine is the tactical tool you use to manage them—providing the structural clarity needed to execute with confidence, whether you are analyzing a 5-minute chart or planning a 4-hour swing trade.

Key Technical Advantages:

    • Macro Regime Alignment: The MTF (Multi-Timeframe) engine automatically scans higher-timeframe volatility to ensure your trades are synchronized with the broader market pulse.

    • Momentum Clarity: By blending Z-Score extensions with trend slope analysis, the engine isolates high-conviction momentum, helping you identify opportunities where volume and price are in harmony.

    • Volume-Weighted Confidence: Every signal is cross-referenced with Relative Volume (RVOL), ensuring you only focus on moves supported by significant market participation, effectively helping you filter out noise.

    • Adaptive Risk Management: The "Risk-to-Invalidation" feature maps out the structural boundaries of your trade automatically, providing a clear visual for your risk management strategy.

    • Clean, Professional UI: A powerful HUD dashboard that organizes your critical data into a clean, distraction-free interface.
The Dashboard as a Confluence Engine Most single stock indicators display technical metrics in isolation. The [TM] Momentum Engine synthesizes these distinct streams—Momentum (Z-Score), Volume (RVOL), and Volatility (MTF Regime)—into a single, cohesive "Risk" state.

    • Risk-On (Momentum Runway): When the engine detects High Confidence + Expanding Volatility + Rising RVOL, the HUD highlights "Momentum Runway." This indicates that price, volume, and volatility are moving in structural alignment, signaling an institutional breakout.

    • Risk-Off (Neutral/Compression): When confidence dips or volatility regresses (or volume dries up), the HUD dynamically updates to reflect a "Standard" or "High-Risk" zone. This signals that the institutional fuel has subsided and the market has entered a phase where mean-reversion is more likely than trend continuation.

Precision, not Prediction. The Institutional Momentum Engine doesn't guess where the price is going. It uses advanced mathematical modeling to show you exactly where the "institutional runway" is forming. It is the perfect tool for traders who want to transition from reacting to noise to following structural logic.

The TrendMatrix Workflow: From Screening to Execution This indicator is designed to complement our Matrix Screener suite. Use the TrendMatrix Screeners to identify high-potential assets, and apply the [TM] Institutional Momentum Engine to your chart to map your entries, manage your risk, and ride the institutional wave with precision.

TrendMatrix Labs: Advanced Analytics. Accessible Flow.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendMatrix_Labs

//@version=6
indicator('TrendMatrix: Institutional Momentum & Regime Engine', shorttitle = '[TM] IME', overlay = true)

// ══════════════════════════════════════════════════════════════════
// 01 │ COLOUR SYSTEM & TYPOGRAPHY
// ══════════════════════════════════════════════════════════════════
color C_SIG     = #6366F1                       // Indigo signature (Trend Lines)
color C_UP      = #34D399                       // Emerald-400 (Up — general bands/fills)
color C_DN      = #FB7185                       // Rose-400 (Down — general bands/fills)
color C_UP_BOLD = #4ADE80                       // Green-400 (Up — hard signals)
color C_DN_BOLD = #F87171                       // Red-400 (Down — hard signals)
color C_TXT     = #E6EDF3                       // Warm white text (HUD primary)
color C_DIM     = #7D8590                       // Cool gray (HUD labels, Fibs)
color C_ACT     = #22D3EE                       // Cyan-400 (Numeric accents)
color C_BG      = color.new(#0D1117, 10)        // Deep cool dark base (HUD Base)
color C_HD      = color.new(#161B22, 0)         // Raised header surface (HUD Headers)
color C_RA      = color.new(#0D1117, 0)         // Row alt A (matches bg)
color C_RB      = color.new(#161B22, 0)         // Row alt B (subtle stripe)

// =========================================================================
// INPUTS & TOOLTIPS
// =========================================================================
// 1. Core Engines
lookback    = input.int(20, title = 'Trend Anchor Lookback', group = 'Core Engines', tooltip = 'Determines the baseline sample size for structural price ranges.\n\nUsage Ranges:\n• 10-20: Fast reaction (Day Trading/Scalping)\n• 50-100: Macro liquidity pools (Swing Trading)')
z_len       = input.int(50, title = 'Extension Z-Score Period', group = 'Core Engines', tooltip = 'Calculates statistical deviations from the mean to identify overextended price.\n\nUsage Ranges:\n• 20: Hyper-sensitive (lots of signals)\n• 50: Standard institutional balance\n• 100: Slow, focused on macro extremes')

// 2. MTF Regime Engine
regime_tf   = input.timeframe('D', title = 'Macro Regime Timeframe', group = 'MTF Regime Engine', tooltip = 'Anchors the lower timeframe to a higher timeframe’s macro weather pattern.\n\nUsage Ranges:\n• "D" (Daily): Standard context for intraday charts (1m-1H).\n• "W" (Weekly): Standard context for swing charts (4H-1D).')
vol_len     = input.int(200, title = 'Volatility Regime Period', group = 'MTF Regime Engine', tooltip = 'The sample size for the macro volatility baseline.\n\nUsage Ranges:\n• 100: Faster baseline (better for highly volatile crypto)\n• 200-252: Traditional 1-year equity baseline')

// 3. Multipliers & Asymmetry
base_mu     = input.float(2.0, title = 'Base Upper Multiplier', group = 'Multipliers & Asymmetry', tooltip = 'The foundational width of the volatility bands.\n\nUsage Ranges:\n• 1.5: Tight bands, frequent touches\n• 2.0: Standard (captures ~95% of normal price action)\n• 3.0: Extreme boundary (rare touches)')
base_ml     = input.float(2.0, title = 'Base Lower Multiplier', group = 'Multipliers & Asymmetry')
scale_up    = input.float(0.4, title = 'Upper Logistic Compression', group = 'Multipliers & Asymmetry', tooltip = 'Limits how wide the bands expand during extreme momentum, forcing price to break out.\n\nUsage Ranges:\n• 0.1-0.2: Minimal compression (bands curve with price)\n• 0.4: Standard curve\n• 0.8: Heavy compression (forces early invalidation)')
scale_down  = input.float(0.4, title = 'Lower Logistic Compression', group = 'Multipliers & Asymmetry')

// 4. Execution & Smoothing
exec_mode   = input.string('Fast Centerline Break', title = 'Signal Trigger Method', options = ['Conservative (Original)', 'Fast Centerline Break', 'Band Reversal (Anticipatory)'], group = 'Execution & Smoothing', tooltip = 'Defines your execution philosophy.\n• Conservative: Waits for trend slope confirmation (safer, slower).\n• Fast Break: Reacts to momentum shifts instantly.\n• Anticipatory: Plays mean-reversion at mathematical extremes.')
smooth      = input.bool(false, title = 'Smooth Price Source', group = 'Execution & Smoothing', tooltip = 'Filters out raw price noise (wicks) so the engine reacts to the "true" trend rather than momentary stop-hunts.\n\nOutcomes:\n• Checked: Cleaner signals and fewer fakeouts, but introduces entry lag.\n• Unchecked: Highly responsive, but vulnerable to intraday chop.')
len_smooth  = input.int(10,   title = 'Smooth Period', group = 'Execution & Smoothing', tooltip = 'The mathematical period used to smooth the price line.\n\nUsage Ranges:\n• 1-5: Minimal lag, tracks very close to real candles (Scalping).\n• 10-20: Standard institutional noise filtering (Day Trading).\n• 50+: Heavy macro smoothing. Trades major structural swings only (Swing Trading).')

strict_exec = input.bool(true,  title = 'Require Bar Close', group = 'Execution & Smoothing', tooltip = 'Institutions wait for the close to confirm intent. Intra-bar wicks trap retail.\n\nUsage:\n• Checked: Safe, confirmed signals (1 bar lag).\n• Unchecked: Instant reactions (Warning: high risk of intra-bar fakeouts).')

// 5. Auto Fibonacci Settings
show_fib    = input.bool(false, title = 'Enable Auto Fibonacci Levels', group = 'Auto Fibonacci Settings')
fib_len = input.int(100, title = 'Fibonacci Lookback Length', minval = 5, group = 'Auto Fibonacci Settings', 
     tooltip="Determines the number of historical chart bars used to find the highest high and lowest low.\n\n" +
             "• Short-Term (Scalping/Day Trading): 5-20 bars.\n" +
             "  Best for 1m to 15m charts. Tracks micro-pivots; changes frequently.\n\n" +
             "• Medium-Term (Swing Trading): 50-100 bars (Default: 100).\n" +
             "  Best for 1h, 4h, or Daily charts. Filters out daily noise for broader trends.\n\n" +
             "• Long-Term (Position Trading): 150-300+ bars.\n" +
             "  Best for Daily, Weekly, or Monthly charts. Identifies macro market cycles.")

// 6. UI Dashboard Customization
table_pos   = input.string('Top Right', title='Dashboard Position', options=['Top Right', 'Bottom Right', 'Top Left', 'Bottom Left'], group = 'UI Dashboard Customization')

// =========================================================================
// LAYER 1: LOCAL TREND ANCHOR
// =========================================================================
src = smooth ? ta.ema(close, len_smooth) : close

upper_anchor = ta.highest(src, lookback)
lower_anchor = ta.lowest(src, lookback)
trend_mid    = ta.linreg(src, lookback, 0)

bull_slope = trend_mid > nz(trend_mid[1], trend_mid)
bear_slope = trend_mid < nz(trend_mid[1], trend_mid)

// =========================================================================
// LAYER 2: MTF VOLATILITY REGIME ENGINE
// =========================================================================
get_htf_vol() =>
    htf_raw_vol   = ta.stdev(close, vol_len)
    htf_vol       = ta.ema(htf_raw_vol, 20)
    htf_vol_rank  = ta.percentrank(htf_vol, 252)
    htf_sma_vol   = ta.sma(htf_vol, 50)
    htf_expanding = htf_vol > htf_sma_vol ? 1.0 : 0.0
    [htf_vol_rank, htf_expanding]

[htf_vol_rank, htf_expanding_raw] = request.security(syminfo.tickerid, regime_tf, get_htf_vol(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

vol_rank      = nz(htf_vol_rank, 50.0)
vol_expanding = nz(htf_expanding_raw, 0.0) == 1.0

// =========================================================================
// LAYER 3: LOCAL EXTENSION ENGINE & LIQUIDITY
// =========================================================================
mean_z = ta.ema(src, z_len)
std_z  = ta.stdev(src, z_len)
z      = std_z > 0 ? (src - mean_z) / std_z : 0

vol_sma = ta.sma(volume, 50)
rvol    = volume / (vol_sma == 0 or na(vol_sma) ? math.max(volume, 1) : vol_sma)

// =========================================================================
// LAYER 4: DYNAMIC MULTIPLIERS & COMPRESSION
// =========================================================================
compression_up   = 1 / (1 + math.exp(-z)) 
compression_down = 1 / (1 + math.exp(z))  

dynamic_mu = base_mu * (1 - (compression_up * scale_up))
dynamic_ml = base_ml * (1 - (compression_down * scale_down))

local_vol = ta.atr(lookback) 

vol_adjustment = 1 + ((vol_rank / 100.0) * 0.5)

width_upper = dynamic_mu * local_vol * vol_adjustment
width_lower = dynamic_ml * local_vol * vol_adjustment

// =========================================================================
// LAYER 5: SMARTER ANCHORS
// =========================================================================
raw_upper  = (0.7 * upper_anchor) + (0.3 * trend_mid) - width_upper
raw_lower  = (0.7 * lower_anchor) + (0.3 * trend_mid) + width_lower

upper      = math.max(raw_upper, raw_lower)
lower      = math.min(raw_upper, raw_lower)
centerline = ta.ema((upper + lower) / 2, 10)

// =========================================================================
// LAYER 6: INSTITUTIONAL CONFIDENCE SCORE
// =========================================================================
extension_score = math.min(math.abs(z) / 3.0, 1.0)
vol_denom       = math.max(local_vol * 5, 0.000001) 
trend_score     = math.min(math.abs(trend_mid - nz(trend_mid[20], trend_mid)) / vol_denom, 1.0)

vol_multiplier  = math.min(math.max(rvol, 0.5), 1.2)
confidence      = math.min(((extension_score + trend_score) / 2.0) * vol_multiplier, 1.0)

// =========================================================================
// LAYER 7: MODULAR EXECUTION LOGIC & STATE MACHINE
// =========================================================================
buy_raw  = ta.crossover(src, centerline)
sell_raw = ta.crossunder(src, centerline)

valid_bar = strict_exec ? barstate.isconfirmed : true

buy_cond  = false
sell_cond = false

if exec_mode == 'Conservative (Original)'
    buy_cond  := nz(ta.barssince(buy_raw), 999) <= 2 and src > centerline and bull_slope and valid_bar
    sell_cond := nz(ta.barssince(sell_raw), 999) <= 2 and src < centerline and bear_slope and valid_bar
else if exec_mode == 'Fast Centerline Break'
    buy_cond  := buy_raw and valid_bar
    sell_cond := sell_raw and valid_bar
else if exec_mode == 'Band Reversal (Anticipatory)'
    buy_cond  := ta.crossover(src, lower) and valid_bar
    sell_cond := ta.crossunder(src, upper) and valid_bar

var bool is_bullish = false
is_bullish := buy_cond ? true : sell_cond ? false : is_bullish

buy  = buy_cond and not is_bullish[1]
sell = sell_cond and is_bullish[1]

// =========================================================================
// LAYER 8: AUTO FIBONACCI CALCULATIONS
// =========================================================================
maxr = ta.highest(high, fib_len)
minr = ta.lowest(low, fib_len)
ranr = maxr - minr

fib_100 = show_fib ? maxr : na
fib_764 = show_fib ? maxr - 0.236 * ranr : na
fib_618 = show_fib ? maxr - 0.382 * ranr : na
fib_500 = show_fib ? maxr - 0.500 * ranr : na
fib_382 = show_fib ? minr + 0.382 * ranr : na
fib_236 = show_fib ? minr + 0.236 * ranr : na
fib_000 = show_fib ? minr : na

// =========================================================================
// PLOTTING & VISUALS
// =========================================================================
bgcolor(is_bullish ? color.new(C_UP_BOLD, 89) : color.new(C_DN_BOLD, 95), title="Regime Background")

plot(smooth ? src : na, color = C_SIG, title = 'Smoothed Price Line', linewidth = 2)
p_u = plot(upper, color = color.new(C_DN, 60), title = 'Upper Band', linewidth = 1)
p_l = plot(lower, color = color.new(C_UP, 60), title = 'Lower Band', linewidth = 1)
p_m = plot(centerline, color = color.new(C_DIM, 40), title = 'Adaptive Centerline', linewidth = 1, style = plot.style_linebr)

upper_fill = src > upper ? color.new(C_UP, 60) : src > centerline ? color.new(C_UP, 85) : na
lower_fill = src < lower ? color.new(C_DN, 60) : src < centerline ? color.new(C_DN, 85) : na

fill(p_u, p_m, color = upper_fill, title = 'Upper Zone Fill')
fill(p_m, p_l, color = lower_fill, title = 'Lower Zone Fill')

// Optimized plotshapes reacting instantly to the chosen trigger mode
plotshape(buy, title = 'Buy Signal', style = shape.triangleup, location = location.belowbar, color = C_UP_BOLD, size = size.small)
plotshape(sell, title = 'Sell Signal', style = shape.triangledown, location = location.abovebar, color = C_DN_BOLD, size = size.small)

// Plot Fibonacci Lines
plot(fib_100, title = 'Fib 1.000', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_764, title = 'Fib 0.764', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_618, title = 'Fib 0.618', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_500, title = 'Fib 0.500', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_382, title = 'Fib 0.382', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_236, title = 'Fib 0.236', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)
plot(fib_000, title = 'Fib 0.000', color = color.new(C_DIM, 60), linewidth = 1, style = plot.style_line)

// Persistent Fib Labels Management
var label lbl_100 = na
var label lbl_764 = na
var label lbl_618 = na
var label lbl_500 = na
var label lbl_382 = na
var label lbl_236 = na
var label lbl_000 = na

if barstate.islast
    if show_fib
        if na(lbl_100)
            lbl_100 := label.new(bar_index + 3, maxr, '1.000', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_764 := label.new(bar_index + 3, maxr - 0.236 * ranr, '0.764', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_618 := label.new(bar_index + 3, maxr - 0.382 * ranr, '0.618', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_500 := label.new(bar_index + 3, maxr - 0.50 * ranr, '0.500', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_382 := label.new(bar_index + 3, minr + 0.382 * ranr, '0.382', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_236 := label.new(bar_index + 3, minr + 0.236 * ranr, '0.236', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
            lbl_000 := label.new(bar_index + 3, minr, '0.000', xloc = xloc.bar_index, style = label.style_label_left, color = C_BG, textcolor = C_DIM, size = size.small)
        else
            label.set_xy(lbl_100, bar_index + 3, maxr)
            label.set_xy(lbl_764, bar_index + 3, maxr - 0.236 * ranr)
            label.set_xy(lbl_618, bar_index + 3, maxr - 0.382 * ranr)
            label.set_xy(lbl_500, bar_index + 3, maxr - 0.50 * ranr)
            label.set_xy(lbl_382, bar_index + 3, minr + 0.382 * ranr)
            label.set_xy(lbl_236, bar_index + 3, minr + 0.236 * ranr)
            label.set_xy(lbl_000, bar_index + 3, minr)
    else
        label.delete(lbl_100), lbl_100 := na
        label.delete(lbl_764), lbl_764 := na
        label.delete(lbl_618), lbl_618 := na
        label.delete(lbl_500), lbl_500 := na
        label.delete(lbl_382), lbl_382 := na
        label.delete(lbl_236), lbl_236 := na
        label.delete(lbl_000), lbl_000 := na

// =========================================================================
// ON-CHART HUD DASHBOARD (TABLE UI - FULLY RESTORED & UPGRADED)
// =========================================================================
risk_pct = is_bullish ? (math.abs(src - lower) / src) * 100 : (math.abs(src - upper) / src) * 100

// Determine Risk/Runway color: 
// High Conf + High Risk = Cyan (Momentum Runway)
// Low Conf + High Risk = Red (Danger/Overextended)
risk_color = (confidence > 0.6 and risk_pct > 5.0) ? C_ACT : (confidence < 0.4 and risk_pct > 4.0) ? C_DN_BOLD : C_TXT

pos_mapped = switch table_pos
    'Top Right'    => position.top_right
    'Bottom Right' => position.bottom_right
    'Top Left'     => position.top_left
    => position.bottom_left

var table hud = table.new(position = pos_mapped, columns = 2, rows = 6, bgcolor = na, border_width = 0)

if barstate.islast
    text_sz = size.normal
    f_mono  = font.family_monospace
    
    // Dynamic Tooltips for all rows
    tt_conf_val = confidence > 0.75 ? "High Conviction (>75%): Strong institutional backing." : confidence > 0.45 ? "Moderate Conviction (45-75%): Proceed with standard sizing." : "Low Conviction (<45%): Choppy/weak momentum. Avoid or scale down."
    
    tt_risk_val = confidence > 0.70 ? (risk_pct > 5.0 ? "Momentum Runway (>5%): Institutional momentum breakout. The band is trailing far behind, allowing for aggressive trend-following." : "Stable Trend: Asset is maintaining controlled, steady momentum.") : (risk_pct > 4.0 ? "High Risk (>4.0%): Price is extended without institutional backing. High probability of mean-reversion." : "Standard Zone: Neutral risk/reward environment.")
        
    tt_rvol_val = rvol > 1.5 ? "High (>1.5x): Abnormal volume detected. Strong participation." : rvol < 0.6 ? "Low (<0.6x): Retail chop. Vulnerable to fakeouts." : "Average: Normal market conditions."
    
    tt_vrnk_val = vol_rank > 80 ? "Extreme (>80%): Highly energetic market. Watch for explosive moves or sharp mean reversion." : vol_rank < 20 ? "Low (<20%): Deep compression. A major directional breakout is building." : "Mid-range: Standard volatility environment."
    
    tt_vreg_val = vol_expanding ? "Expanding: Increasing volatility. Favorable for momentum and trend continuation." : "Compressed: Decreasing volatility. Favorable for mean reversion and ranging strategies."

    // Row 0: Invisible Spacer
    table.cell(hud, 0, 0, bgcolor = na)
    table.cell(hud, 1, 0, bgcolor = na)

    // Row 1: Signal Confidence
    table.cell(hud, 0, 1, "Signal Confidence", text_color = C_DIM, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Blended metric: Z-Score, Trend Slope, and RVOL.")
    conf_color = confidence > 0.75 ? C_UP_BOLD : confidence > 0.45 ? C_ACT : C_DN_BOLD
    table.cell(hud, 1, 1, str.tostring(confidence * 100, "#.0") + "%", text_color = conf_color, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_conf_val)
    
    // Row 2: Risk to Invalidation
    table.cell(hud, 0, 2, "Risk to Invalidation", text_color = C_DIM, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Distance to structural invalidation (the opposite volatility band).")
    table.cell(hud, 1, 2, str.tostring(risk_pct, "#.00") + "%", text_color = risk_color, text_size = text_sz, bgcolor = C_RB, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_risk_val)
    
    // Row 3: RVOL
    table.cell(hud, 0, 3, "Relative Volume (RVOL)", text_color = C_DIM, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Current volume vs 50-period average.")
    rvol_color = rvol > 1.5 ? C_UP_BOLD : rvol < 0.6 ? C_DN_BOLD : C_ACT
    table.cell(hud, 1, 3, str.tostring(rvol, "#.00") + "x", text_color = rvol_color, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_rvol_val)
    
    // Row 4: Volatility Percentile
    table.cell(hud, 0, 4, "Vol Percentile (" + regime_tf + ")", text_color = C_DIM, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Where current volatility ranks in the yearly distribution.")
    table.cell(hud, 1, 4, str.tostring(vol_rank, "#.0") + "%", text_color = C_ACT, text_size = text_sz, bgcolor = C_RB, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_vrnk_val)
    
    // Row 5: Volatility Regime
    table.cell(hud, 0, 5, "Vol Regime (" + regime_tf + ")", text_color = C_DIM, text_size = text_sz, bgcolor = C_HD, text_halign = text.align_left, text_font_family = f_mono, tooltip = "Expanding = Momentum; Compressed = Mean Reversion.")
    reg_text  = vol_expanding ? "EXPANDING" : "COMPRESSED"
    reg_color = vol_expanding ? C_ACT : C_DIM
    table.cell(hud, 1, 5, reg_text, text_color = reg_color, text_size = text_sz, bgcolor = C_RA, text_halign = text.align_right, text_font_family = f_mono, tooltip = tt_vreg_val)
````
