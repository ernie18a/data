# Momentum Setup

- url: https://www.tradingview.com/script/TqGmHk1N-Momentum-Setup/
- type: indicator
- pine_id: PUB;b0126759de6d474eb333e36257ebf750
- version: 1.0

## Description

My first attempt at my own indicator. Using the 9ema, 21 ema, VWAP, above average volume and confirmation from a higher timeframe.

## Source Code

````pine
//@version=5
indicator("Momentum Setup", overlay=true)

ema9_len = input.int(9, title="EMA 9 Length")
ema21_len = input.int(21, title="EMA 21 Length")
vol_len = input.int(10, title="Volume Average Length")
htf = input.timeframe("15", title="Higher Timeframe")

// ── CURRENT TIMEFRAME ─────────────────────────────────────────────────────────
ema9 = ta.ema(close, ema9_len)
ema21 = ta.ema(close, ema21_len)

plot(ema9, title="EMA 9", color=color.aqua, linewidth=1)
plot(ema21, title="EMA 21", color=color.orange, linewidth=1)

session_vwap = ta.vwap(hlc3)
plot(session_vwap, title="Session VWAP", color=color.yellow, linewidth=1)

var float cum_pv = 0.0
var float cum_v = 0.0

if ta.change(time("D"))
    cum_pv := hlc3 * volume
    cum_v := volume
else
    cum_pv := cum_pv + hlc3 * volume
    cum_v := cum_v + volume

daily_vwap = cum_pv / cum_v
plot(daily_vwap, title="Daily VWAP", color=color.fuchsia, linewidth=1)

avg_vol = ta.sma(volume, vol_len)
high_vol = volume > avg_vol

above9 = close > ema9
above21 = close > ema21
aboveSVwap = close > session_vwap
aboveDVwap = close > daily_vwap

below9 = close < ema9
below21 = close < ema21
belowSVwap = close < session_vwap
belowDVwap = close < daily_vwap

buy_signal = above9 and above21 and aboveSVwap and aboveDVwap and high_vol
sell_signal = below9 and below21 and belowSVwap and belowDVwap and high_vol

// ── HIGHER TIMEFRAME CONFIRMATION ─────────────────────────────────────────────
htf_ema9 = request.security(syminfo.tickerid, htf, ta.ema(close, ema9_len), lookahead=barmerge.lookahead_off)
htf_ema21 = request.security(syminfo.tickerid, htf, ta.ema(close, ema21_len), lookahead=barmerge.lookahead_off)
htf_vwap = request.security(syminfo.tickerid, htf, ta.vwap(hlc3), lookahead=barmerge.lookahead_off)
htf_close = request.security(syminfo.tickerid, htf, close, lookahead=barmerge.lookahead_off)

htf_bull = htf_close > htf_ema9 and htf_close > htf_ema21 and htf_close > htf_vwap
htf_bear = htf_close < htf_ema9 and htf_close < htf_ema21 and htf_close < htf_vwap

// ── CONFIRMED VS UNCONFIRMED SIGNALS ──────────────────────────────────────────
buy_confirmed = buy_signal and htf_bull
buy_weak = buy_signal and not htf_bull

sell_confirmed = sell_signal and htf_bear
sell_weak = sell_signal and not htf_bear

// ── PLOT ARROWS ───────────────────────────────────────────────────────────────
// Confirmed - full size bright arrows
plotshape(buy_confirmed, title="Buy Confirmed", location=location.belowbar, style=shape.triangleup, color=color.green, size=size.normal)
plotshape(sell_confirmed, title="Sell Confirmed", location=location.abovebar, style=shape.triangledown, color=color.red, size=size.normal)

// Unconfirmed - smaller dimmed arrows
plotshape(buy_weak, title="Buy Weak", location=location.belowbar, style=shape.triangleup, color=color.new(color.green, 70), size=size.tiny)
plotshape(sell_weak, title="Sell Weak", location=location.abovebar, style=shape.triangledown, color=color.new(color.red, 70), size=size.tiny)

// ── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(buy_confirmed, title="Buy Confirmed Alert", message="BUY Confirmed: All conditions met on current and 15m timeframe.")
alertcondition(sell_confirmed, title="Sell Confirmed Alert", message="SELL Confirmed: All conditions met on current and 15m timeframe.")
alertcondition(buy_weak, title="Buy Weak Alert", message="BUY Signal (unconfirmed on 15m): Proceed with caution.")
alertcondition(sell_weak, title="Sell Weak Alert", message="SELL Signal (unconfirmed on 15m): Proceed with caution.")
````
