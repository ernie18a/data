# Katana Signal AUDCAD Entry Indicator2

- url: https://www.tradingview.com/script/R7GGpV8G/
- type: indicator
- pine_id: PUB;0b0eb20a132141f38ea92244ed44ab3b
- version: 1.0

## Description

AUDCAD Mean-Reversion Signals — Automated with Katana EA (MT4)

This indicator plots entry signals for a mean-reversion 
strategy on AUDCAD 30min.

HOW IT WORKS:
- RSI oversold/overbought extreme
- Parabolic SAR confirms on prior closed bar (no repainting)
- Both conditions must align simultaneously

WHY AUDCAD:
AUD and CAD are commodity currencies that move together.
When they temporarily diverge, mean-reversion has structural
reasons to work.

AUTOMATED VERSION (Katana EA v1.4) on MT4:
- Dynamic lot sizing
- 51-month backtest: +6,717% / 96.5% win rate
- Every Tick mode, 90% modelling quality

See profile for EA details and free trial link.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © KaTa4649
//@version=6
// @recommended_timeframes=30,60,240
indicator("Katana Signal — AUDCAD Entry Indicator", shorttitle="Katana Signal", overlay=true)

// ── Display options only
show_bg   = input.bool(false, "Show signal background")
show_info = input.bool(true, "Show info table")

// ── Internal fixed values (not exposed)
int   _rp  = 14
float _sb  = 37.0
float _ss  = 64.0
float _ss2 = 0.009
float _sm  = 0.2

// ── Calculations
float _rsi      = ta.rsi(close, _rp)
float _rsi_prev = _rsi[1]
float _sar      = ta.sar(_ss2, _ss2, _sm)
float _sar_prev = _sar[1]

// ── Signal conditions (prior closed bar — no repainting)
bool buy_signal  = _rsi_prev <= _sb and _sar_prev < low[1]
bool sell_signal = _rsi_prev >= _ss and _sar_prev > high[1]

// ── SAR plot
plot(_sar, "SAR", color=color.new(color.gray, 50), style=plot.style_circles, linewidth=1)

// ── Signal shapes
plotshape(buy_signal,  "Buy",  shape.triangleup,   location.belowbar, color=color.new(#4ADE80, 0), size=size.normal)
plotshape(sell_signal, "Sell", shape.triangledown,  location.abovebar, color=color.new(#F87171, 0), size=size.normal)

// ── Labels
if buy_signal
    label.new(bar_index, low - ta.atr(14) * 0.5, "BUY", color=color.new(#4ADE80, 15), textcolor=color.new(#052e16, 0), style=label.style_label_up, size=size.small)

if sell_signal
    label.new(bar_index, high + ta.atr(14) * 0.5, "SELL", color=color.new(#F87171, 15), textcolor=color.new(#450a0a, 0), style=label.style_label_down, size=size.small)

// ── Background
bgcolor(buy_signal  and show_bg ? color.new(#4ADE80, 88) : na)
bgcolor(sell_signal and show_bg ? color.new(#F87171, 88) : na)

// ── Info table
if show_info and barstate.islast
    var table t = table.new(position.top_right, 2, 5, bgcolor=color.new(#0A0C0F, 10), border_color=color.new(#1E2128, 0), border_width=1, frame_color=color.new(#1E2128, 0), frame_width=1)

    table.cell(t, 0, 0, "Katana Signal", text_color=color.new(#4ADE80, 0), text_size=size.small, bgcolor=color.new(#0A0C0F, 0))
    table.cell(t, 1, 0, "AUDCAD",        text_color=color.new(#6B7280, 0), text_size=size.small, bgcolor=color.new(#0A0C0F, 0))

    string sar_pos = _sar < close ? "Bullish" : "Bearish"
    color  sar_col = _sar < close ? color.new(#4ADE80, 0) : color.new(#F87171, 0)
    table.cell(t, 0, 1, "SAR",    text_color=color.new(#6B7280, 0), text_size=size.small, bgcolor=color.new(#111318, 0))
    table.cell(t, 1, 1, sar_pos,  text_color=sar_col,               text_size=size.small, bgcolor=color.new(#111318, 0))

    string sig_text  = buy_signal ? "BUY" : sell_signal ? "SELL" : "Waiting"
    color  sig_color = buy_signal ? color.new(#4ADE80, 0) : sell_signal ? color.new(#F87171, 0) : color.new(#6B7280, 0)
    table.cell(t, 0, 2, "Signal",  text_color=color.new(#6B7280, 0), text_size=size.small, bgcolor=color.new(#0D0F13, 0))
    table.cell(t, 1, 2, sig_text,  text_color=sig_color,             text_size=size.small, bgcolor=color.new(#0D0F13, 0))

    table.cell(t, 0, 3, "Strategy",                  text_color=color.new(#6B7280, 0), text_size=size.small, bgcolor=color.new(#111318, 0))
    table.cell(t, 1, 3, "Optimised — built into EA", text_color=color.new(#E8EAF0, 0), text_size=size.small, bgcolor=color.new(#111318, 0))

    table.cell(t, 0, 4, "MT4 EA",             text_color=color.new(#6B7280, 0), text_size=size.small, bgcolor=color.new(#0D0F13, 0))
    table.cell(t, 1, 4, "payhip.com/b/j4d6F", text_color=color.new(#60A5FA, 0), text_size=size.small, bgcolor=color.new(#0D0F13, 0))

// ── Alerts
alertcondition(buy_signal,  "Katana BUY Signal",  "Katana Signal: BUY — AUDCAD")
alertcondition(sell_signal, "Katana SELL Signal", "Katana Signal: SELL — AUDCAD")
````
