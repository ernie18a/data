# Katana Signal  AUDCAD Entry Indicator

- url: https://www.tradingview.com/script/g0iOb23O/
- type: indicator
- pine_id: PUB;5010b4c1b6704b03b5f09c4ccd807310
- version: 1.0

## Description

This indicator visualises the entry logic behind Katana EA v1.4 
— an MT4 Expert Advisor I developed privately in 2022 and have 
been running on a live account ever since.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW THE SIGNAL WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
Entry is triggered only when TWO conditions align on the prior 
closed bar (shift=1, no repainting):
 
BUY signal:
• RSI reaches oversold extreme
• Parabolic SAR is below the prior bar's low
 
SELL signal:
• RSI reaches overbought extreme  
• Parabolic SAR is above the prior bar's high
 
Both conditions must be true simultaneously. 
Single-indicator entries are filtered out.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHY AUDCAD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
AUD and CAD are both commodity-linked currencies that move 
together the majority of the time. When they temporarily 
diverge — due to oil price moves, RBA/BOC policy divergence, 
or risk sentiment shifts — mean-reversion setups have strong 
structural reasons to work.
 
This makes AUDCAD one of the cleanest pairs for this type 
of strategy. The correlation rarely breaks permanently, 
which limits the risk of runaway adverse moves.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISPLAY SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
• BUY signal  → green triangle below bar
• SELL signal → red triangle above bar
• Parabolic SAR → grey dots (standard display)
• Background highlight on signal bars (can be disabled)
• Info table top-right: SAR direction, current signal status
 
Strategy parameters are optimised internally and not exposed 
— this prevents unintended parameter changes that could 
degrade performance.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MT4 AUTOMATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
This indicator shows the entry signals visually. 
The automated version (Katana EA v1.4) executes these 
entries on MT4 with:
 
• Dynamic lot sizing — auto-scales with account balance
• Martingale position scaling (max 8 positions)
• Hard stop-loss + 8-hour cooldown after each SL event
• Active hours filter (London + New York session only)
 
51-month backtest results (Mar 2022 – May 2026):
✓ Net profit: +6,717% on ¥150,000 starting capital
✓ Win rate: 96.5% per trade cycle
✓ Profit factor: 1.54
✓ Stop-losses: 33 in 51 months
✓ Modelling quality: 90% (Every Tick, 60M+ real tick data)
 
Includes: 2022 Ukraine war oil spike, Trump tariffs, 
Middle East conflict periods.
 
Free 14-day trial + full licence: payhip.com/b/j4d6F
Licence delivery & support: Telegram @KaTa4649
 
⚠ Requires broker with 500:1 leverage (XM Global recommended)
⚠ Not compatible with US / Canada / UK retail accounts
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RECOMMENDED SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
For visual analysis: use on AUDCAD 1H or 4H
For the automated EA: runs on AUDCAD M5
 
Broker: XM Global Standard Account (JPY or USD)
Min capital: ¥150,000 or $1,000 USD

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
