# Malloy Labs: Apex Matrix 

- url: https://www.tradingview.com/script/ZBm5aFQQ-Malloy-Labs-Apex-Matrix/
- type: indicator
- pine_id: PUB;63bb7ea1a87f4a219b60b5d949ff8411
- version: 1.0

## Description

Four-component confluence engine displayed as a single dashboard. EMA momentum, Ichimoku cloud structure, MACD divergence, and RSI momentum each score independently (0–25), aggregate into a net bias reading, and output one signal: LONG, SHORT, or WAIT.

Each component pulls from its own configurable timeframe so you're reading structure at the right resolution, not forcing everything through the same lens. Power scores update in real time so that you can see what's building before the signal fires.

No subplots. No noise. Just the table.

## Source Code

````pine
//@version=5
indicator("APEX MATRIX DISPLAY™", overlay=false, precision=2)

// ═══════════════════════════════════════════════════════════════
// APEX SIGNAL MATRIX - 
// Multi-Timeframe Confluence Engine with Adaptive Signal Processing
// ═══════════════════════════════════════════════════════════════

// === CONFIGURATION PANEL ===
var string GP1 = "⚙️ CORE SETTINGS"
useEMA = input.bool(true, "EMA Momentum Filter", group=GP1)
useIchimoku = input.bool(true, "Ichimoku Cloud System", group=GP1)
useMACD = input.bool(true, "MACD Divergence Filter", group=GP1)
useRSI = input.bool(true, "RSI Momentum Filter", group=GP1)
signalThreshold = input.float(65, "Signal Threshold", minval=0, maxval=100, step=5, group=GP1)

var string GP2 = "📊 TIMEFRAME ANALYSIS"
htfIchimoku = input.timeframe("15", "Ichimoku Timeframe", group=GP2)
htfMACD = input.timeframe("15", "MACD Timeframe", group=GP2)
htfRSI = input.timeframe("60", "RSI Timeframe", group=GP2)

var string GP3 = "🎯 SIGNAL PROCESSING"
adaptiveSmoothing = input.bool(true, "Adaptive Smoothing", group=GP3)
smoothPeriod = input.int(5, "Smooth Period", minval=1, maxval=20, group=GP3)
momentum = input.int(3, "Momentum Sensitivity", minval=1, maxval=10, group=GP3)

var string GP4 = "🎨 VISUAL SETTINGS"
showMatrix = input.bool(true, "Show Signal Matrix", group=GP4)

var string GP5 = "⚡ ADVANCED PARAMETERS"
emaFast = input.int(8, "EMA Fast", minval=2, group=GP5)
emaSlow = input.int(21, "EMA Slow", minval=5, group=GP5)
ichimokuConv = input.int(9, "Ichimoku Conversion", group=GP5)
ichimokuBase = input.int(26, "Ichimoku Base", group=GP5)
ichimokuSpan = input.int(52, "Ichimoku Span", group=GP5)
macdFast = input.int(12, "MACD Fast", group=GP5)
macdSlow = input.int(26, "MACD Slow", group=GP5)
macdSig = input.int(9, "MACD Signal", group=GP5)

// === PROFESSIONAL COLOR SCHEME ===
color bull_primary = #9333EA      // Deep purple
color bull_glow = #C084FC         // Light purple
color bear_primary = #1A1A1A      // Rich black
color bear_glow = #404040         // Charcoal
color neutral = #6B7280           // Gray
color grid = #2D2D2D              // Dark grid
color accent_buy = #10B981        // Emerald accent
color accent_sell = #EF4444       // Red accent

// === MARKET STRUCTURE ANALYSIS ===
donchian(len) => math.avg(ta.lowest(low, len), ta.highest(high, len))

// EMA System - Trend & Momentum
ema_fast = ta.ema(close, emaFast)
ema_slow = ta.ema(close, emaSlow)
ema_trend = ema_fast > ema_slow
ema_strength = math.abs((ema_fast - ema_slow) / ema_slow) * 100
ema_momentum = ta.change(ema_strength, momentum)
ema_signal = ema_trend and ema_momentum > 0 and close > ema_fast

// Ichimoku Cloud - HTF Structure
htf_close = request.security(syminfo.tickerid, htfIchimoku, close, barmerge.gaps_off, barmerge.lookahead_off)
htf_conv = request.security(syminfo.tickerid, htfIchimoku, donchian(ichimokuConv), barmerge.gaps_off, barmerge.lookahead_off)
htf_base = request.security(syminfo.tickerid, htfIchimoku, donchian(ichimokuBase), barmerge.gaps_off, barmerge.lookahead_off)
htf_lead1 = math.avg(htf_conv, htf_base)
htf_lead2 = request.security(syminfo.tickerid, htfIchimoku, donchian(ichimokuSpan), barmerge.gaps_off, barmerge.lookahead_off)
cloud_bull = htf_close > htf_lead1 and htf_close > htf_lead2 and htf_conv > htf_base
cloud_strength = math.abs((htf_close - math.avg(htf_lead1, htf_lead2)) / htf_close) * 100

// MACD System - HTF Divergence
macd_line = request.security(syminfo.tickerid, htfMACD, ta.ema(close, macdFast) - ta.ema(close, macdSlow), barmerge.gaps_off, barmerge.lookahead_off)
macd_signal = request.security(syminfo.tickerid, htfMACD, ta.ema(macd_line, macdSig), barmerge.gaps_off, barmerge.lookahead_off)
macd_hist = macd_line - macd_signal
macd_bull = macd_hist > 0
macd_strength = math.abs(macd_hist) * 10
macd_accel = ta.change(macd_hist, momentum)

// RSI System - HTF Momentum
rsi_htf = request.security(syminfo.tickerid, htfRSI, ta.rsi(close, 14), barmerge.gaps_off, barmerge.lookahead_off)
rsi_bull = rsi_htf > 45 and rsi_htf < 75
rsi_strength = math.abs(rsi_htf - 50) / 50 * 100
rsi_momentum = ta.change(rsi_htf, momentum)

// === APEX CONFLUENCE ENGINE ===
// Component Scores (0-25 each, total 100)
score_ema = useEMA and ema_signal ? math.min(ema_strength * 5, 25) : 0
score_cloud = useIchimoku and cloud_bull ? math.min(cloud_strength * 2.5, 25) : 0
score_macd = useMACD and macd_bull and macd_accel > 0 ? math.min(macd_strength * 2, 25) : 0
score_rsi = useRSI and rsi_bull and rsi_momentum > 0 ? math.min(rsi_strength * 0.25, 25) : 0

// Inverse calculations for bearish
score_ema_bear = useEMA and not ema_trend and ema_momentum < 0 and close < ema_fast ? math.min(ema_strength * 5, 25) : 0
score_cloud_bear = useIchimoku and not cloud_bull and htf_close < htf_lead1 and htf_close < htf_lead2 ? math.min(cloud_strength * 2.5, 25) : 0
score_macd_bear = useMACD and not macd_bull and macd_accel < 0 ? math.min(macd_strength * 2, 25) : 0
score_rsi_bear = useRSI and rsi_htf > 25 and rsi_htf < 55 and rsi_momentum < 0 ? math.min(rsi_strength * 0.25, 25) : 0

// Aggregate Signal Strength
bull_power = score_ema + score_cloud + score_macd + score_rsi
bear_power = score_ema_bear + score_cloud_bear + score_macd_bear + score_rsi_bear

// Net Market Bias (-100 to +100)
net_bias = bull_power - bear_power

// Adaptive Smoothing with Volatility Adjustment
atr = ta.atr(14)
atr_normalized = atr / close * 100
// Use simple smoothing since ta.ema requires a simple int, not a series
signal_line = ta.ema(net_bias, smoothPeriod)

// Momentum Derivative (Rate of Change)
momentum_wave = ta.change(signal_line, 3) * 2

// Signal Classification
apex_signal = math.abs(signal_line) > signalThreshold ? (signal_line > 0 ? 1 : -1) : 0
signal_strength = math.abs(signal_line)

// === ADVANCED VISUALIZATION ===

// All plots removed - Matrix display only

// === SIGNAL MATRIX DASHBOARD ===
if showMatrix and barstate.islast
    var table matrix = table.new(position.top_right, 3, 7, 
                                  bgcolor=color.new(#000000, 5), 
                                  border_color=color.new(neutral, 70), 
                                  border_width=1)
    
    // Header
    table.cell(matrix, 0, 0, "APEX MATRIX", text_color=color.white, bgcolor=color.new(bull_primary, 20), text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(matrix, 0, 0, 2, 0)
    
    table.cell(matrix, 0, 1, "COMPONENT", text_color=neutral, text_size=size.small)
    table.cell(matrix, 1, 1, "STATUS", text_color=neutral, text_size=size.small, text_halign=text.align_center)
    table.cell(matrix, 2, 1, "POWER", text_color=neutral, text_size=size.small, text_halign=text.align_right)
    
    // EMA
    ema_status = ema_signal ? "🟢 BULL" : not ema_trend ? "🔴 BEAR" : "⚪ NEUTRAL"
    ema_color_display = ema_signal ? bull_glow : not ema_trend ? bear_glow : neutral
    table.cell(matrix, 0, 2, "EMA System", text_color=color.white, text_size=size.small)
    table.cell(matrix, 1, 2, ema_status, text_color=ema_color_display, text_size=size.small, text_halign=text.align_center)
    table.cell(matrix, 2, 2, str.tostring(math.round(ema_strength, 1)), text_color=color.white, text_size=size.small, text_halign=text.align_right)
    
    // Ichimoku
    cloud_status = cloud_bull ? "🟢 BULL" : "🔴 BEAR"
    cloud_color_display = cloud_bull ? bull_glow : bear_glow
    table.cell(matrix, 0, 3, "Ichimoku", text_color=color.white, text_size=size.small)
    table.cell(matrix, 1, 3, cloud_status, text_color=cloud_color_display, text_size=size.small, text_halign=text.align_center)
    table.cell(matrix, 2, 3, str.tostring(math.round(cloud_strength, 1)), text_color=color.white, text_size=size.small, text_halign=text.align_right)
    
    // MACD
    macd_status = macd_bull and macd_accel > 0 ? "🟢 BULL" : not macd_bull and macd_accel < 0 ? "🔴 BEAR" : "⚪ NEUTRAL"
    macd_color_display = macd_bull and macd_accel > 0 ? bull_glow : not macd_bull and macd_accel < 0 ? bear_glow : neutral
    table.cell(matrix, 0, 4, "MACD", text_color=color.white, text_size=size.small)
    table.cell(matrix, 1, 4, macd_status, text_color=macd_color_display, text_size=size.small, text_halign=text.align_center)
    table.cell(matrix, 2, 4, str.tostring(math.round(macd_strength, 1)), text_color=color.white, text_size=size.small, text_halign=text.align_right)
    
    // RSI
    rsi_status = rsi_bull and rsi_momentum > 0 ? "🟢 BULL" : rsi_htf < 45 and rsi_momentum < 0 ? "🔴 BEAR" : "⚪ NEUTRAL"
    rsi_color_display = rsi_bull and rsi_momentum > 0 ? bull_glow : rsi_htf < 45 ? bear_glow : neutral
    table.cell(matrix, 0, 5, "RSI", text_color=color.white, text_size=size.small)
    table.cell(matrix, 1, 5, rsi_status, text_color=rsi_color_display, text_size=size.small, text_halign=text.align_center)
    table.cell(matrix, 2, 5, str.tostring(math.round(rsi_strength, 1)), text_color=color.white, text_size=size.small, text_halign=text.align_right)
    
    // Overall Signal
    signal_display = apex_signal == 1 ? "🚀 LONG" : apex_signal == -1 ? "🔻 SHORT" : "⏸️ WAIT"
    signal_color_final = apex_signal == 1 ? accent_buy : apex_signal == -1 ? accent_sell : neutral
    table.cell(matrix, 0, 6, "APEX SIGNAL", text_color=color.white, text_size=size.small, bgcolor=color.new(#000000, 50))
    table.cell(matrix, 1, 6, signal_display, text_color=signal_color_final, text_size=size.normal, text_halign=text.align_center, bgcolor=color.new(#000000, 50))
    table.cell(matrix, 2, 6, str.tostring(math.round(signal_strength)) + "%", text_color=color.white, text_size=size.small, text_halign=text.align_right, bgcolor=color.new(#000000, 50))
````
