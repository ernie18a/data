# XAUUSD ADX + EMA 9/21 + EMA 200 Signal

- url: https://www.tradingview.com/script/vPWOBMT9-XAUUSD-ADX-EMA-9-21-EMA-200-Signal/
- type: indicator
- pine_id: PUB;008e746f3bb14de995098bf56c1c5e88
- version: 1.0

## Description

This is cross over signal but when market on trending

## Source Code

````pine
//@version=5
indicator(title="XAUUSD ADX + EMA 9/21 + EMA 200 Signal", shorttitle="ADX+EMA Signal", overlay=true)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
ema9_len    = input.int(9,   title="EMA Fast",       group="EMA Settings")
ema21_len   = input.int(21,  title="EMA Slow",       group="EMA Settings")
ema200_len  = input.int(200, title="EMA 200 Filter", group="EMA Settings")

adx_len     = input.int(14,  title="ADX Length",     group="ADX Settings")
adx_smooth  = input.int(14,  title="ADX Smoothing",  group="ADX Settings")
adx_thresh  = input.int(25,  title="ADX Threshold",  group="ADX Settings")

show_ema9   = input.bool(true,  title="Show EMA 9",   group="Display")
show_ema21  = input.bool(true,  title="Show EMA 21",  group="Display")
show_ema200 = input.bool(true,  title="Show EMA 200", group="Display")
show_adx    = input.bool(true,  title="Show ADX Panel (separate pane)", group="Display")

// ─────────────────────────────────────────────
//  EMA CALCULATIONS
// ─────────────────────────────────────────────
ema9   = ta.ema(close, ema9_len)
ema21  = ta.ema(close, ema21_len)
ema200 = ta.ema(close, ema200_len)

// ─────────────────────────────────────────────
//  ADX CALCULATION (manual DMI)
// ─────────────────────────────────────────────
[diplus, diminus, adx] = ta.dmi(adx_len, adx_smooth)

// ─────────────────────────────────────────────
//  SIGNAL CONDITIONS
// ─────────────────────────────────────────────

// EMA crossover
bullCross = ta.crossover(ema9, ema21)
bearCross = ta.crossunder(ema9, ema21)

// ADX trend strength filter
adxStrong = adx >= adx_thresh

// EMA 200 bias filter
aboveEma200 = close > ema200
belowEma200 = close < ema200

// DI direction filter
bullDI = diplus > diminus
bearDI = diminus > diplus

// ─────────────────────────────────────────────
//  FINAL BUY / SELL SIGNALS
// ─────────────────────────────────────────────

// BUY  → price above EMA200 + EMA9 crosses above EMA21 + ADX>25 + +DI > -DI
buySignal  = bullCross and aboveEma200 and adxStrong and bullDI

// SELL → price below EMA200 + EMA9 crosses below EMA21 + ADX>25 + -DI > +DI
sellSignal = bearCross and belowEma200 and adxStrong and bearDI

// ─────────────────────────────────────────────
//  PLOT EMAs
// ─────────────────────────────────────────────
plot(show_ema9   ? ema9   : na, title="EMA 9",   color=color.new(#378ADD, 0), linewidth=1)
plot(show_ema21  ? ema21  : na, title="EMA 21",  color=color.new(#EF9F27, 0), linewidth=1)
plot(show_ema200 ? ema200 : na, title="EMA 200", color=color.new(#E24B4A, 0), linewidth=2)

// EMA 200 background zone (subtle fill)
ema200_bull_bg = aboveEma200 ? color.new(color.green, 96) : na
ema200_bear_bg = belowEma200 ? color.new(color.red,   96) : na
bgcolor(ema200_bull_bg, title="Above EMA 200 bg")
bgcolor(ema200_bear_bg, title="Below EMA 200 bg")

// ─────────────────────────────────────────────
//  BUY / SELL SIGNAL ARROWS
// ─────────────────────────────────────────────
plotshape(
     buySignal,
     title="BUY Signal",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(#1D9E75, 0),
     textcolor=color.white,
     text="BUY",
     size=size.normal
     )

plotshape(
     sellSignal,
     title="SELL Signal",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(#E24B4A, 0),
     textcolor=color.white,
     text="SELL",
     size=size.normal
     )

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
alertcondition(buySignal,  title="BUY Alert",  message="XAUUSD 5M — BUY Signal: EMA9 crossed above EMA21, price above EMA200, ADX strong (+DI dominant)")
alertcondition(sellSignal, title="SELL Alert", message="XAUUSD 5M — SELL Signal: EMA9 crossed below EMA21, price below EMA200, ADX strong (-DI dominant)")

// ─────────────────────────────────────────────
//  ADX PANEL  (separate pane)
// ─────────────────────────────────────────────
// NOTE: These plots appear in a NEW pane only when
//       you add this indicator twice, OR use
//       "Add indicator to new pane" in TradingView.
//       Toggle them off in Display settings if you
//       prefer a clean overlay-only view.

adx_line   = show_adx ? adx     : na
diplus_ln  = show_adx ? diplus  : na
diminus_ln = show_adx ? diminus : na

plot(adx_line,   title="ADX",  color=color.new(#7F77DD, 0), linewidth=2, display=display.pane)
plot(diplus_ln,  title="+DI",  color=color.new(#1D9E75, 0), linewidth=1, display=display.pane)
plot(diminus_ln, title="-DI",  color=color.new(#E24B4A, 0), linewidth=1, display=display.pane)
hline(adx_thresh, title="ADX Threshold", color=color.gray, linestyle=hline.style_dashed, linewidth=1)

// ADX strength label (on chart, top right)
var label adxLabel = na
label.delete(adxLabel)
adxState = adx >= adx_thresh ? "TRENDING ✓" : "RANGING ✗"
adxColor = adx >= adx_thresh ? color.new(#1D9E75, 10) : color.new(#888780, 20)
adxLabel := label.new(
     bar_index, high,
     text="ADX " + str.tostring(math.round(adx, 1)) + " — " + adxState,
     style=label.style_label_lower_right,
     color=adxColor,
     textcolor=color.white,
     size=size.small
     )

// ─────────────────────────────────────────────
//  TABLE — live signal dashboard (top right)
// ─────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 6,
     border_width=1,
     border_color=color.new(color.gray, 60),
     bgcolor=color.new(color.black, 70)
     )

// Headers
table.cell(dash, 0, 0, "Indicator",  text_color=color.gray,  text_size=size.small, bgcolor=color.new(color.black, 60))
table.cell(dash, 1, 0, "Status",     text_color=color.gray,  text_size=size.small, bgcolor=color.new(color.black, 60))

// EMA 9 vs 21
ema_cross_txt   = ema9 > ema21 ? "9 > 21 ▲" : "9 < 21 ▼"
ema_cross_col   = ema9 > ema21 ? color.new(#1D9E75, 0) : color.new(#E24B4A, 0)
table.cell(dash, 0, 1, "EMA 9/21",   text_color=color.white, text_size=size.small)
table.cell(dash, 1, 1, ema_cross_txt, text_color=ema_cross_col, text_size=size.small)

// EMA 200 position
ema200_txt = aboveEma200 ? "Above ▲" : "Below ▼"
ema200_col = aboveEma200 ? color.new(#1D9E75, 0) : color.new(#E24B4A, 0)
table.cell(dash, 0, 2, "EMA 200",    text_color=color.white, text_size=size.small)
table.cell(dash, 1, 2, ema200_txt,   text_color=ema200_col,  text_size=size.small)

// ADX value
adx_col = adxStrong ? color.new(#1D9E75, 0) : color.new(#EF9F27, 0)
table.cell(dash, 0, 3, "ADX",        text_color=color.white, text_size=size.small)
table.cell(dash, 1, 3, str.tostring(math.round(adx, 1)), text_color=adx_col, text_size=size.small)

// DI direction
di_txt = bullDI ? "+DI > -DI ▲" : "-DI > +DI ▼"
di_col = bullDI ? color.new(#1D9E75, 0) : color.new(#E24B4A, 0)
table.cell(dash, 0, 4, "DI",         text_color=color.white, text_size=size.small)
table.cell(dash, 1, 4, di_txt,       text_color=di_col,      text_size=size.small)

// Overall signal
sig_txt = buySignal ? "◆ BUY" : sellSignal ? "◆ SELL" : "— WAIT"
sig_col = buySignal ? color.new(#1D9E75, 0) : sellSignal ? color.new(#E24B4A, 0) : color.new(#888780, 0)
table.cell(dash, 0, 5, "Signal",     text_color=color.white, text_size=size.small)
table.cell(dash, 1, 5, sig_txt,      text_color=sig_col,     text_size=size.small)
````
