# Triple-Stack Crossover

- url: https://www.tradingview.com/script/KLt0jTlA-Triple-Stack-Crossover/
- type: indicator
- pine_id: PUB;7e7182cfa3c44289b4674693f24a453e
- version: 1.0

## Description

Four references on one chart (21 SMA, 200 EMA, 200 VWMA, and session VWAP with its bands) and the only thing it cares about is the 21 crossing all three at once. Clear the EMA, VWMA, and VWAP together going up and it's a long; break all three going down and it's a short. Making one fast average get past a price-based, a volume-weighted, and a session-anchored line at the same time throws out most of the single-MA head-fakes. Take a signal as a regime flip and ride it until the stack breaks back apart. Confirms on close, no repaint.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  MG Triple-Stack Crossover
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  Four references on one chart (21 SMA, 200 EMA, 200 VWMA, and session VWAP
//  with its bands) and the only thing it cares about is the 21 crossing all
//  three at once. Clear the EMA, VWMA, and VWAP together going up and it's a
//  long; break all three going down and it's a short. Making one fast average
//  get past a price-based, a volume-weighted, and a session-anchored line at
//  the same time throws out most of the single-MA head-fakes. Take a signal
//  as a regime flip and ride it until the stack breaks back apart. Confirms
//  on close, no repaint.
// ============================================================================
//
//@version=6
indicator('MG Triple-Stack Crossover', 'Triple-Stack', overlay = true, max_labels_count = 200)

// ═══════════════════════════════════════════════════════════════
//  LOGIC
//  • Lines: 200 EMA, 200 VWMA, Session VWAP (+ std-dev bands), 21 SMA
//  • LONG  when 21 SMA crosses ABOVE all three (EMA, VWMA, VWAP)
//  • SHORT when 21 SMA crosses BELOW all three
//  Signals confirm on bar close by default (no repaint).
// ═══════════════════════════════════════════════════════════════

// ─── Moving Averages ───
grpMA = 'Moving Averages'
ema_len = input.int(200, '200 EMA Length', minval = 1, group = grpMA)
vwma_len = input.int(200, '200 VWMA Length', minval = 1, group = grpMA)
sma_len = input.int(21, 'Signal SMA Length', minval = 1, group = grpMA)

// ─── VWAP + Std Dev Bands (matches NQ_Chart_Overlay) ───
grpV = 'VWAP + Std Dev Bands'
show_vwap = input.bool(true, 'Show VWAP', group = grpV)
vwap_src = input.source(hlc3, 'VWAP Source', group = grpV)
show_band1 = input.bool(true, 'Show Band 1', group = grpV, inline = 'b1')
band1_mult = input.float(1.0, 'Mult', group = grpV, inline = 'b1', step = 0.5, minval = 0)
show_band2 = input.bool(true, 'Show Band 2', group = grpV, inline = 'b2')
band2_mult = input.float(2.0, 'Mult', group = grpV, inline = 'b2', step = 0.5, minval = 0)

// ─── Signals / Display ───
grpS = 'Signals & Display'
confirm = input.bool(true, 'Confirm on bar close (no repaint)', group = grpS)
show_sig = input.bool(true, 'Show Long / Short markers', group = grpS)
show_glow = input.bool(true, 'Glow on 21 SMA', group = grpS)
show_bg = input.bool(true, 'Tint background by state', group = grpS)
show_panel = input.bool(true, 'Show status panel', group = grpS)

// ─── Colors ───
grpC = 'Colors'
col_ema = input.color(#2962FF, '200 EMA', group = grpC)
col_vwma = input.color(#EC407A, '200 VWMA', group = grpC)
col_vwap = input.color(#FF9800, 'VWAP', group = grpC)
col_up = input.color(#26A69A, 'Bull', group = grpC)
col_dn = input.color(#EF5350, 'Bear', group = grpC)
col_neu = input.color(#B0BEC5, 'Neutral', group = grpC)

// ═══════════════════════════════════════════════════════════════
//  CALCULATIONS
// ═══════════════════════════════════════════════════════════════
ema200 = ta.ema(close, ema_len)
vwma200 = ta.vwma(close, vwma_len)
sma21 = ta.sma(close, sma_len)

is_new_session = timeframe.change('D')
[vwap_val, vwap_upper, _vl] = ta.vwap(vwap_src, is_new_session, 1)
sd = vwap_upper - vwap_val
u1 = vwap_val + sd * band1_mult
l1 = vwap_val - sd * band1_mult
u2 = vwap_val + sd * band2_mult
l2 = vwap_val - sd * band2_mult

// Highest / lowest of the three reference lines
maxLine = math.max(ema200, math.max(vwma200, vwap_val))
minLine = math.min(ema200, math.min(vwma200, vwap_val))

// State
bull = sma21 > maxLine // 21 SMA above ALL three
bear = sma21 < minLine // 21 SMA below ALL three

// Cross events
longRaw = ta.crossover(sma21, maxLine)
shortRaw = ta.crossunder(sma21, minLine)
gate = confirm ? barstate.isconfirmed : true
longSig = longRaw and gate
shortSig = shortRaw and gate

smaColor = bull ? col_up : bear ? col_dn : col_neu

// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════
// VWAP + bands
disp_v = show_vwap ? display.all : display.none
disp_b1 = show_vwap and show_band1 ? display.all : display.none
disp_b2 = show_vwap and show_band2 ? display.all : display.none

plot(vwap_val, 'VWAP', color = col_vwap, linewidth = 2, display = disp_v)
pu1 = plot(u1, 'Upper 1', color = color.new(#5C6BC0, 40), display = disp_b1)
pl1 = plot(l1, 'Lower 1', color = color.new(#5C6BC0, 40), display = disp_b1)
fill(pu1, pl1, color.new(#5C6BC0, 92), title = 'Band 1 Fill', display = disp_b1)
pu2 = plot(u2, 'Upper 2', color = color.new(#7E57C2, 40), display = disp_b2)
pl2 = plot(l2, 'Lower 2', color = color.new(#7E57C2, 40), display = disp_b2)
fill(pu2, pl2, color.new(#7E57C2, 94), title = 'Band 2 Fill', display = disp_b2)

// 200 EMA + 200 VWMA
plot(ema200, '200 EMA', color = col_ema, linewidth = 2)
plot(vwma200, '200 VWMA', color = col_vwma, linewidth = 2)

// 21 SMA — glow underlay + dynamic-color core
plot(show_glow ? sma21 : na, '21 SMA Glow', color = color.new(smaColor, 78), linewidth = 7)
plot(sma21, '21 SMA', color = smaColor, linewidth = 3)

// State background
bgcolor(show_bg ? bull ? color.new(col_up, 92) : bear ? color.new(col_dn, 92) : na : na, title = 'State Tint')

// Signal markers
plotshape(show_sig and longSig, 'Long', shape.triangleup, location.belowbar, color = col_up, size = size.small, text = 'LONG', textcolor = color.white)
plotshape(show_sig and shortSig, 'Short', shape.triangledown, location.abovebar, color = col_dn, size = size.small, text = 'SHORT', textcolor = color.white)

// ═══════════════════════════════════════════════════════════════
//  STATUS PANEL
// ═══════════════════════════════════════════════════════════════
f_state(cond) =>
    cond ? 'Above' : 'Below'
f_clr(cond) =>
    cond ? col_up : col_dn

var table t = table.new(position.top_right, 2, 5, bgcolor = color.new(#131722, 12), border_color = color.new(#000000, 50), border_width = 1, frame_color = color.new(#000000, 40), frame_width = 1)

if show_panel and barstate.islast
    state_txt = bull ? 'LONG STACK' : bear ? 'SHORT STACK' : 'MIXED'
    state_clr = bull ? col_up : bear ? col_dn : col_neu
    table.cell(t, 0, 0, ' TRIPLE-STACK ', bgcolor = color.new(state_clr, 20), text_color = color.white, text_size = size.small)
    table.cell(t, 1, 0, ' ' + state_txt + ' ', bgcolor = color.new(state_clr, 20), text_color = color.white, text_size = size.small)

    table.cell(t, 0, 1, '21 vs 200 EMA', text_color = color.new(color.white, 20), text_size = size.small)
    table.cell(t, 1, 1, f_state(sma21 > ema200), text_color = f_clr(sma21 > ema200), text_size = size.small)

    table.cell(t, 0, 2, '21 vs 200 VWMA', text_color = color.new(color.white, 20), text_size = size.small)
    table.cell(t, 1, 2, f_state(sma21 > vwma200), text_color = f_clr(sma21 > vwma200), text_size = size.small)

    table.cell(t, 0, 3, '21 vs VWAP', text_color = color.new(color.white, 20), text_size = size.small)
    table.cell(t, 1, 3, f_state(sma21 > vwap_val), text_color = f_clr(sma21 > vwap_val), text_size = size.small)

    sig_now = bull ? 'LONG' : bear ? 'SHORT' : '—'
    table.cell(t, 0, 4, 'Signal', text_color = color.new(color.white, 20), text_size = size.small)
    table.cell(t, 1, 4, sig_now, text_color = state_clr, text_size = size.small)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(longSig, 'Triple-Stack LONG', 'Triple-Stack: 21 SMA crossed ABOVE all three')
alertcondition(shortSig, 'Triple-Stack SHORT', 'Triple-Stack: 21 SMA crossed BELOW all three')
````
