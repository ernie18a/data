# Volume Breakout

- url: https://www.tradingview.com/script/LrW6COj6-Volume-Breakout/
- type: indicator
- pine_id: PUB;4c125df01231438c9a011613fae995a8
- version: 3.0

## Description

Volume Breakout

Volume Breakout is an educational chart indicator designed to identify strong bullish volume candles, classify them by market context, and display structured setup reference levels with optional entry, stop-loss, and target lines.

This script is an indicator, not a strategy. It does not place trades, does not simulate orders, and does not provide backtested performance results. The signals and levels shown by the script are analytical references only and should not be interpreted as financial advice or automatic trade instructions.

What the indicator does

The indicator classifies bullish volume events into three main signal types:

1. REV — Reversal Volume Signal

REV is designed to identify an early bullish volume candle near a lower part of the recent price range, before full trend confirmation is present.

A REV signal requires:

* A bullish candle.
* Volume to be the highest within the selected volume lookback.
* Volume to be above the selected volume moving-average multiple.
* Candle body size to meet the selected minimum body percentage.
* RSI to be within the selected acceptable range.
* Price to be near the lower zone of the recent lookback range.
* The market not to be in the defined bullish EMA trend condition.

REV is intended to mark possible early reversal pressure. It is not a confirmed entry signal by itself.

2. VOL — Trend Volume Signal

VOL is designed to identify strong bullish volume candles when the market is already in a bullish trend condition.

A VOL signal uses the same raw volume-spike logic as REV, but it requires the trend condition to be bullish.

The trend condition is based on:

* Price above the fast EMA.
* Price above the slow EMA.
* Fast EMA above the slow EMA.

VOL is intended to show bullish volume participation inside an existing trend. It is not automatically a confirmed entry.

3. BUY — Confirmed Setup Signal

BUY is the most selective signal in the script.

A BUY signal requires:

* A valid VOL signal.
* Breakout confirmation, if enabled.
* Risk percentage to be within the selected maximum risk limit, if enabled.
* Candle range not to be overextended relative to ATR, if enabled.
* Cooldown period since the previous BUY signal to be satisfied.

The BUY label marks a confirmed setup according to the script’s rules. It does not guarantee continuation or profitability.

Core logic

The script starts by identifying a raw bullish volume spike. A raw volume spike requires a bullish candle with strong volume, strong body size, and RSI inside the selected range.

After that, the script classifies the candle based on context:

* If the candle appears near the lower part of the recent range and the EMA trend is not yet bullish, it can become a REV signal.
* If the candle appears while the EMA trend is already bullish, it can become a VOL signal.
* If a VOL signal also satisfies breakout, risk, ATR, and cooldown filters, it can become a BUY signal.

This layered structure is intended to separate early reversal pressure, trend-volume participation, and confirmed breakout-style setups.

Entry, stop, and target reference levels

When a BUY signal appears, the script stores and displays the latest setup levels:

* Entry reference: the high of the BUY candle.
* Stop-loss reference: the low of the BUY candle.
* Target reference: entry plus the selected risk-reward multiple.

These levels are visual references only. They are not orders and are not strategy backtest calculations.

Risk and reward display

The script calculates the risk percentage from the BUY candle high to the BUY candle low.

If the risk filter is enabled, BUY signals are allowed only when this risk percentage is below the selected maximum risk percentage.

The dashboard also displays the last recorded risk and reward percentages for the most recent BUY setup.

Breakout confirmation

When enabled, the breakout filter requires price to close above the highest high of the selected breakout lookback period.

This is intended to reduce signals that occur before price has cleared nearby resistance, but it can also reduce the number of signals.

ATR extension filter

When enabled, the ATR filter blocks BUY signals if the candle range is too large compared with ATR.

This is intended to avoid overextended candles where the distance between the entry reference and stop reference may be too wide.

Cooldown filter

The cooldown setting requires a minimum number of bars between BUY signals.

This is intended to reduce repeated BUY labels during clustered volume activity.

Dashboard

The dashboard summarizes the current setup context, including:

* Trend status.
* RSI value.
* Whether REV is active.
* Whether VOL is active.
* Whether breakout confirmation is satisfied.
* Whether risk is acceptable.
* Last BUY entry reference.
* Last BUY stop-loss and target references.
* Last risk and reward percentages.
* Last BUY age in bars.

The Last BUY Age row helps identify whether the most recent BUY setup is still fresh according to the selected Fresh BUY Max Age Bars setting.

Visual elements

The indicator can display:

* REV labels.
* VOL labels.
* BUY labels.
* Optional fast and slow EMA lines.
* Latest BUY entry, stop-loss, and target reference lines.
* Optional volume label on the last BUY candle.
* Optional box around the latest BUY candle.
* Dashboard panel.

Alerts

The script includes alert conditions for:

* REV Signal.
* VOL Signal.
* BUY Confirmed.

Alerts are informational only. They should not be treated as automatic trade instructions.

Inputs

Volume Settings

* Volume Lookback: number of bars used to check whether volume is the highest in the recent window.
* Volume MA Length: moving average length for volume comparison.
* Min Volume x Average: required volume multiple above average volume.

Candle Strength

* Min Body Size %: minimum candle body size relative to the full candle range.

Trend Settings

* Fast EMA: fast EMA used for bullish trend confirmation.
* Slow EMA: slow EMA used for bullish trend confirmation.

RSI Settings

* RSI Length: RSI calculation length.
* Min RSI For REV / VOL: minimum RSI value allowed for volume signals.
* Max RSI For REV / VOL: maximum RSI value allowed for volume signals.

Signal Control

* Cooldown Bars For BUY: minimum number of bars required between BUY signals.
* Risk Reward: multiplier used for the target reference level.
* Fresh BUY Max Age Bars: number of bars used to classify the latest BUY as fresh.

REV Reversal Volume Settings

* Use REV Reversal Volume Signal: enables or disables REV signals.
* REV Low Lookback: lookback range used to define the lower price zone.
* REV Near Low Zone %: controls how close price must be to the lower part of the recent range.

Breakout Confirmation

* Use Breakout Confirmation For BUY: requires price to break above the selected lookback high.
* Breakout Lookback: number of bars used for breakout confirmation.

Risk Filter

* Use Max Risk % Filter For BUY: enables or disables the maximum risk filter.
* Max Risk %: maximum allowed risk between the BUY candle high and low.

ATR Filter

* Avoid Over-Extended Candles For BUY: enables or disables the ATR extension filter.
* ATR Length: ATR calculation length.
* Max Candle Range x ATR: maximum allowed candle range relative to ATR.

Display Settings

* Show REV Signals.
* Show VOL Signals.
* Show BUY Confirmed Signals.
* Show Last BUY Entry / SL / TP.
* Show Dashboard.
* Show Box On Last BUY Candle.
* Show EMAs.
* Show Last BUY Volume Label.

How to use it

A practical workflow is:

1. Use REV to identify early bullish volume activity near the lower part of a recent range.
2. Use VOL to identify strong bullish volume participation inside an established bullish EMA trend.
3. Use BUY as the most selective setup marker after breakout, risk, ATR, and cooldown filters are satisfied.
4. Review the displayed entry, stop, and target reference levels.
5. Check the dashboard to confirm whether the setup is fresh and whether risk conditions are acceptable.
6. Confirm any setup with your own market structure, liquidity levels, higher-timeframe trend, and risk management.

Important limitations

This indicator does not predict future price movement.

A REV, VOL, or BUY signal does not guarantee continuation, reversal, or profitability.

The entry, stop-loss, and target lines are reference levels only.

Volume signals can be less reliable on illiquid symbols, abnormal news candles, pre-market data, or instruments with inconsistent volume data.

Breakout filters can still produce false breakouts.

ATR filters can block some valid moves and allow some weak moves depending on volatility conditions.

EMA trend filters are lagging by nature.

Users should test the indicator across multiple symbols, timeframes, and market conditions before using it in any decision-making process.

Recommended use

Volume Breakout is used as a structured volume-and-breakout analysis tool. It is designed to help traders organize volume spikes, trend context, breakout confirmation, and risk-reference levels in one chart view.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © ADXAE

//@version=6
indicator("Volume Breakout", shorttitle="Vol Breakout", overlay=true, max_labels_count=300, max_lines_count=50, max_boxes_count=20)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────

// Groups
grp_volume   = "① Volume Breakout Engine"
grp_body     = "② Candle Body Filter"
grp_trend    = "③ Trend Filter"
grp_rsi      = "④ RSI Filter"
grp_buy      = "⑤ BUY Confirmation"
grp_risk     = "⑥ Risk / Targets"
grp_rev      = "⑦ REV Reversal Volume"
grp_atr      = "⑧ ATR Extension Filter"
grp_display  = "⑨ Display / Dashboard"
grp_alerts   = "⑩ Alerts"
grp_colors   = "⑪ Colors"

// Volume
vol_lookback = input.int(
     5,
     "Volume Lookback",
     minval=3,
     maxval=50,
     group=grp_volume,
     tooltip="Checks whether the current candle volume is the highest volume within this number of previous bars. Lower values create more signals. Higher values require stronger volume spikes."
)

vol_ma_len = input.int(
     20,
     "Volume MA Length",
     minval=5,
     maxval=100,
     group=grp_volume,
     tooltip="The moving average length used to calculate the normal / average volume. The current volume must be compared against this average."
)

vol_mult = input.float(
     1.5,
     "Min Volume x Average",
     minval=1.0,
     maxval=10.0,
     step=0.1,
     group=grp_volume,
     tooltip="Minimum volume multiplier required versus the average volume. Example: 1.5 means the current volume must be at least 150% of the average volume."
)

// Candle body
body_pct = input.float(
     65,
     "Min Body Size %",
     minval=20,
     maxval=95,
     step=5,
     group=grp_body,
     tooltip="Minimum candle body percentage compared to the full candle range. Higher values require a stronger body candle and reduce weak wick-heavy candles."
)

// EMA trend
ema_fast = input.int(
     21,
     "Fast EMA",
     minval=5,
     group=grp_trend,
     tooltip="Fast EMA used for trend confirmation. A bullish trend requires price to be above this EMA and the fast EMA to be above the slow EMA."
)

ema_slow = input.int(
     50,
     "Slow EMA",
     minval=20,
     group=grp_trend,
     tooltip="Slow EMA used as the main trend filter. A BUY confirmation requires price above both EMAs with fast EMA above slow EMA."
)

// RSI
rsi_len = input.int(
     14,
     "RSI Length",
     minval=5,
     group=grp_rsi,
     tooltip="RSI calculation length. Used to avoid weak momentum and to filter REV / VOL signals."
)

rsi_min = input.float(
     45,
     "Min RSI For REV / VOL",
     minval=30,
     maxval=80,
     step=5,
     group=grp_rsi,
     tooltip="Minimum RSI allowed for REV and VOL signals. If RSI is below this level, the candle may lack enough momentum."
)

rsi_max = input.float(
     85,
     "Max RSI For REV / VOL",
     minval=55,
     maxval=95,
     step=1,
     group=grp_rsi,
     tooltip="Maximum RSI allowed for REV and VOL signals. Helps avoid very overbought entries after excessive momentum."
)

// BUY confirmation
cooldown_bars = input.int(
     5,
     "Cooldown Bars For BUY",
     minval=1,
     maxval=30,
     group=grp_buy,
     tooltip="Minimum number of bars required between confirmed BUY signals. This reduces repeated BUY signals in the same move."
)

fresh_buy_bars = input.int(
     5,
     "Fresh BUY Max Age Bars",
     minval=1,
     maxval=50,
     group=grp_buy,
     tooltip="Defines how many bars the last BUY signal is considered fresh in the dashboard."
)

use_breakout_filter = input.bool(
     true,
     "Use Breakout Confirmation For BUY",
     group=grp_buy,
     tooltip="When enabled, a BUY signal requires price to close above the previous breakout high. This helps confirm strength instead of buying only a volume spike."
)

breakout_lookback = input.int(
     10,
     "Breakout Lookback",
     minval=3,
     maxval=50,
     group=grp_buy,
     tooltip="Number of previous bars used to define the breakout level. BUY requires closing above the highest high of this lookback when the breakout filter is enabled."
)

// Risk / targets
rr_mult = input.float(
     2.0,
     "TP1 Risk Reward",
     minval=1.0,
     maxval=5.0,
     step=0.5,
     group=grp_risk,
     tooltip="Risk-to-reward multiplier for TP1. Example: 2.0 means TP1 is two times the candle risk from entry."
)

rr_mult_tp2 = input.float(
     3.0,
     "TP2 Risk Reward",
     minval=1.0,
     maxval=10.0,
     step=0.5,
     group=grp_risk,
     tooltip="Risk-to-reward multiplier for TP2. Example: 3.0 means TP2 is three times the candle risk from entry."
)

use_risk_filter = input.bool(
     true,
     "Use Max Risk % Filter For BUY",
     group=grp_risk,
     tooltip="When enabled, BUY signals are blocked if the candle risk from entry to stop loss is higher than the allowed maximum risk percentage."
)

max_risk_pct = input.float(
     12.0,
     "Max Risk %",
     minval=2.0,
     maxval=40.0,
     step=0.5,
     group=grp_risk,
     tooltip="Maximum allowed risk percentage between entry and stop loss. Lower values create safer but fewer BUY signals."
)

// Reversal volume
use_reversal_signal = input.bool(
     true,
     "Use REV Reversal Volume Signal",
     group=grp_rev,
     tooltip="Enables REV signals. REV marks strong bullish volume candles appearing near a low zone before full trend confirmation."
)

reversal_lookback = input.int(
     30,
     "REV Low Lookback",
     minval=10,
     maxval=150,
     group=grp_rev,
     tooltip="Number of bars used to calculate the recent range low and high for the REV reversal zone."
)

near_low_pct = input.float(
     35.0,
     "REV Near Low Zone %",
     minval=5.0,
     maxval=80.0,
     step=5.0,
     group=grp_rev,
     tooltip="Defines how close price must be to the low part of the recent range to qualify as a REV setup. Lower values require price to be closer to the range low."
)

// ATR extension
use_atr_filter = input.bool(
     true,
     "Avoid Over-Extended Candles For BUY",
     group=grp_atr,
     tooltip="When enabled, BUY signals are blocked if the candle range is too large compared to ATR. This helps avoid chasing over-extended candles."
)

atr_len = input.int(
     14,
     "ATR Length",
     minval=5,
     group=grp_atr,
     tooltip="ATR length used to measure normal candle range. The ATR filter compares the current candle range against this value."
)

max_atr_range = input.float(
     2.5,
     "Max Candle Range x ATR",
     minval=1.0,
     maxval=8.0,
     step=0.25,
     group=grp_atr,
     tooltip="Maximum allowed candle range compared to ATR. Example: 2.5 means the candle range must not exceed 2.5x ATR for a BUY signal."
)

// Display
show_rev_signals = input.bool(
     true,
     "Show REV Signals",
     group=grp_display,
     tooltip="Shows REV reversal volume markers on the chart."
)

show_vol_signals = input.bool(
     true,
     "Show VOL Signals",
     group=grp_display,
     tooltip="Shows VOL trend-volume markers when volume conditions are met in an uptrend but BUY confirmation is not fully triggered."
)

show_buy_signals = input.bool(
     true,
     "Show BUY Confirmed Signals",
     group=grp_display,
     tooltip="Shows confirmed BUY signals on the chart when all required filters pass."
)

show_last_setup = input.bool(
     true,
     "Show Last BUY Entry / SL / TP",
     group=grp_display,
     tooltip="Shows only the latest confirmed BUY setup with Entry, Stop Loss, TP1, and TP2 lines."
)

show_dashboard = input.bool(
     true,
     "Show Dashboard",
     group=grp_display,
     tooltip="Shows the dashboard table with trend, RSI, REV, VOL, breakout, risk, and last BUY information."
)

dashboard_position = input.string(
     "Top Right",
     "Dashboard Position",
     options=[
         "Top Right",
         "Top Center",
         "Top Left",
         "Middle Right",
         "Middle Center",
         "Middle Left",
         "Bottom Right",
         "Bottom Center",
         "Bottom Left"
     ],
     group=grp_display,
     tooltip="Selects where the dashboard table appears on the chart."
)

dashboard_size = input.string(
     "Normal",
     "Dashboard Size",
     options=["Small", "Normal", "Large"],
     group=grp_display,
     tooltip="Controls the dashboard text size."
)

show_signal_box = input.bool(
     false,
     "Show Box On Last BUY Candle",
     group=grp_display,
     tooltip="Draws a small box around the last confirmed BUY candle."
)

show_emas = input.bool(
     false,
     "Show EMAs",
     group=grp_display,
     tooltip="Shows the fast and slow EMA lines used by the trend filter."
)

show_volume_label = input.bool(
     true,
     "Show Last BUY Volume Label",
     group=grp_display,
     tooltip="Shows a volume label under the latest confirmed BUY candle."
)

// Alert Settings
enable_entry_alert = input.bool(
     true,
     "Alert: Entry Line Break",
     group=grp_alerts,
     tooltip="Enables alert logic when price touches or breaks the latest BUY entry line."
)

enable_sl_alert = input.bool(
     true,
     "Alert: Stop Loss Line Break",
     group=grp_alerts,
     tooltip="Enables alert logic when price touches or breaks the latest stop loss line."
)

enable_tp1_alert = input.bool(
     true,
     "Alert: TP1 Reached",
     group=grp_alerts,
     tooltip="Enables alert logic when price reaches TP1."
)

enable_tp2_alert = input.bool(
     true,
     "Alert: TP2 Reached",
     group=grp_alerts,
     tooltip="Enables alert logic when price reaches TP2."
)

// Colors
rev_col = input.color(
     color.new(color.purple, 0),
     "REV Color",
     group=grp_colors,
     tooltip="Color used for REV reversal volume signals."
)

vol_col = input.color(
     color.new(color.orange, 0),
     "VOL Color",
     group=grp_colors,
     tooltip="Color used for VOL trend-volume signals."
)

buy_col = input.color(
     color.new(color.teal, 0),
     "BUY Color",
     group=grp_colors,
     tooltip="Color used for confirmed BUY signals."
)

entry_col = input.color(
     color.new(color.teal, 0),
     "Entry Color",
     group=grp_colors,
     tooltip="Color used for the entry line and entry label."
)

sl_col = input.color(
     color.new(color.red, 0),
     "Stop Color",
     group=grp_colors,
     tooltip="Color used for the stop loss line and stop loss label."
)

tp_col = input.color(
     color.new(color.green, 0),
     "Target Color",
     group=grp_colors,
     tooltip="Color used for TP1 and TP2 target lines."
)

box_col = input.color(
     color.new(color.orange, 80),
     "Box Color",
     group=grp_colors,
     tooltip="Background color used for the optional BUY candle box."
)

// ─────────────────────────────────────────────────────────────────────────────
// Calculations
// ─────────────────────────────────────────────────────────────────────────────
fast_ema = ta.ema(close, ema_fast)
slow_ema = ta.ema(close, ema_slow)
rsi_val  = ta.rsi(close, rsi_len)
atr_val  = ta.atr(atr_len)
vol_ma   = ta.sma(volume, vol_ma_len)

is_bull = close > open

candle_range = high - low
candle_body  = math.abs(close - open)

is_strong_body = candle_range > 0 and (candle_body / candle_range * 100) >= body_pct

is_vol_highest  = volume == ta.highest(volume, vol_lookback)
is_vol_above_ma = volume >= vol_ma * vol_mult

is_uptrend = close > fast_ema and close > slow_ema and fast_ema > slow_ema

is_rsi_ok = rsi_val >= rsi_min and rsi_val <= rsi_max

// Reversal zone logic
range_low  = ta.lowest(low, reversal_lookback)
range_high = ta.highest(high, reversal_lookback)
range_size = range_high - range_low

near_low_zone = range_size > 0 ? close <= range_low + range_size * (near_low_pct / 100.0) : false

// Breakout logic
breakout_level = ta.highest(high[1], breakout_lookback)
is_breakout = not use_breakout_filter or close > breakout_level

// ATR extension logic
is_not_extended = not use_atr_filter or candle_range <= atr_val * max_atr_range

// Levels
entry_price = high
sl_price    = low
risk        = entry_price - sl_price

tp_price  = entry_price + risk * rr_mult
tp2_price = entry_price + risk * rr_mult_tp2

risk_pct    = entry_price > 0 ? (risk / entry_price) * 100 : na
reward_pct  = entry_price > 0 ? ((tp_price - entry_price) / entry_price) * 100 : na
reward2_pct = entry_price > 0 ? ((tp2_price - entry_price) / entry_price) * 100 : na

is_risk_ok = not use_risk_filter or risk_pct <= max_risk_pct

// ─────────────────────────────────────────────────────────────────────────────
// Signal Logic
// ─────────────────────────────────────────────────────────────────────────────
raw_vol_spike = is_bull and
     is_vol_highest and
     is_vol_above_ma and
     is_strong_body and
     is_rsi_ok

rev_signal = use_reversal_signal and
     raw_vol_spike and
     not is_uptrend and
     near_low_zone

vol_signal = raw_vol_spike and
     is_uptrend

var int bars_since_buy = 999
bars_since_buy := bars_since_buy + 1

is_cooldown_ok = bars_since_buy >= cooldown_bars

buy_signal = vol_signal and
     is_breakout and
     is_not_extended and
     is_risk_ok and
     is_cooldown_ok

if buy_signal
    bars_since_buy := 0

vol_only = vol_signal and not buy_signal

// ─────────────────────────────────────────────────────────────────────────────
// Store Last BUY Setup
// ─────────────────────────────────────────────────────────────────────────────
var float last_entry       = na
var float last_sl          = na
var float last_tp          = na
var float last_tp2         = na
var float last_vol         = na
var float last_risk_pct    = na
var float last_reward_pct  = na
var float last_reward2_pct = na
var int   last_buy_bar     = na

if buy_signal
    last_entry       := entry_price
    last_sl          := sl_price
    last_tp          := tp_price
    last_tp2         := tp2_price
    last_vol         := volume
    last_risk_pct    := risk_pct
    last_reward_pct  := reward_pct
    last_reward2_pct := reward2_pct
    last_buy_bar     := bar_index

last_buy_age = na(last_buy_bar) ? na : bar_index - last_buy_bar
is_fresh_buy = not na(last_buy_age) and last_buy_age <= fresh_buy_bars

// ─────────────────────────────────────────────────────────────────────────────
// Alert State
// ─────────────────────────────────────────────────────────────────────────────
var bool entry_alert_done = false
var bool sl_alert_done    = false
var bool tp1_alert_done   = false
var bool tp2_alert_done   = false

if buy_signal
    entry_alert_done := false
    sl_alert_done    := false
    tp1_alert_done   := false
    tp2_alert_done   := false

entry_line_break = enable_entry_alert and
     not na(last_entry) and
     not na(last_buy_bar) and
     bar_index > last_buy_bar and
     high >= last_entry and
     not entry_alert_done

sl_line_break = enable_sl_alert and
     not na(last_sl) and
     not na(last_buy_bar) and
     bar_index > last_buy_bar and
     low <= last_sl and
     not sl_alert_done

tp1_reached = enable_tp1_alert and
     not na(last_tp) and
     not na(last_buy_bar) and
     bar_index > last_buy_bar and
     high >= last_tp and
     not tp1_alert_done

tp2_reached = enable_tp2_alert and
     not na(last_tp2) and
     not na(last_buy_bar) and
     bar_index > last_buy_bar and
     high >= last_tp2 and
     not tp2_alert_done

if entry_line_break
    entry_alert_done := true

if sl_line_break
    sl_alert_done := true

if tp1_reached
    tp1_alert_done := true

if tp2_reached
    tp2_alert_done := true

// ─────────────────────────────────────────────────────────────────────────────
// Plot Signals
// ─────────────────────────────────────────────────────────────────────────────
plotshape(
     show_rev_signals and rev_signal,
     title="REV Reversal Volume Signal",
     style=shape.diamond,
     location=location.belowbar,
     color=rev_col,
     size=size.small,
     text="REV",
     textcolor=rev_col
)

plotshape(
     show_vol_signals and vol_only,
     title="VOL Trend Volume Signal",
     style=shape.circle,
     location=location.belowbar,
     color=vol_col,
     size=size.tiny,
     text="VOL",
     textcolor=vol_col
)

plotshape(
     show_buy_signals and buy_signal,
     title="BUY Confirmed Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=buy_col,
     size=size.small,
     text="BUY",
     textcolor=buy_col
)

plot(show_emas ? fast_ema : na, "Fast EMA", color=color.new(color.teal, 0), linewidth=1)
plot(show_emas ? slow_ema : na, "Slow EMA", color=color.new(color.orange, 0), linewidth=1)

barcolor(
     buy_signal ? color.new(color.teal, 0) :
     rev_signal ? color.new(color.purple, 0) :
     vol_only   ? color.new(color.orange, 0) :
     na
)

// ─────────────────────────────────────────────────────────────────────────────
// Last BUY Setup Only Lines / Labels / Box
// ─────────────────────────────────────────────────────────────────────────────
var line entry_line = na
var line sl_line    = na
var line tp_line    = na
var line tp2_line   = na

var label entry_label = na
var label sl_label    = na
var label tp_label    = na
var label tp2_label   = na
var label vol_label   = na

var box signal_box = na

if buy_signal and show_last_setup
    if not na(entry_line)
        line.delete(entry_line)
    if not na(sl_line)
        line.delete(sl_line)
    if not na(tp_line)
        line.delete(tp_line)
    if not na(tp2_line)
        line.delete(tp2_line)

    if not na(entry_label)
        label.delete(entry_label)
    if not na(sl_label)
        label.delete(sl_label)
    if not na(tp_label)
        label.delete(tp_label)
    if not na(tp2_label)
        label.delete(tp2_label)
    if not na(vol_label)
        label.delete(vol_label)

    if not na(signal_box)
        box.delete(signal_box)

    entry_line := line.new(
         bar_index,
         entry_price,
         bar_index + 20,
         entry_price,
         color=entry_col,
         width=2,
         style=line.style_dashed
    )

    sl_line := line.new(
         bar_index,
         sl_price,
         bar_index + 20,
         sl_price,
         color=sl_col,
         width=2,
         style=line.style_dashed
    )

    tp_line := line.new(
         bar_index,
         tp_price,
         bar_index + 20,
         tp_price,
         color=tp_col,
         width=2,
         style=line.style_dashed
    )

    tp2_line := line.new(
         bar_index,
         tp2_price,
         bar_index + 20,
         tp2_price,
         color=color.new(tp_col, 35),
         width=2,
         style=line.style_dashed
    )

    entry_label := label.new(
         bar_index + 20,
         entry_price,
         "Entry " + str.tostring(entry_price, format.mintick),
         color=entry_col,
         textcolor=color.white,
         style=label.style_label_left,
         size=size.tiny
    )

    sl_label := label.new(
         bar_index + 20,
         sl_price,
         "SL " + str.tostring(sl_price, format.mintick),
         color=sl_col,
         textcolor=color.white,
         style=label.style_label_left,
         size=size.tiny
    )

    tp_label := label.new(
         bar_index + 20,
         tp_price,
         "TP1 " + str.tostring(tp_price, format.mintick),
         color=tp_col,
         textcolor=color.white,
         style=label.style_label_left,
         size=size.tiny
    )

    tp2_label := label.new(
         bar_index + 20,
         tp2_price,
         "TP2 " + str.tostring(tp2_price, format.mintick),
         color=color.new(tp_col, 35),
         textcolor=color.white,
         style=label.style_label_left,
         size=size.tiny
    )

    if show_volume_label
        vol_label := label.new(
             bar_index,
             low,
             "Vol " + str.tostring(volume / 1e6, "#.##") + "M",
             color=color.new(color.orange, 0),
             textcolor=color.white,
             style=label.style_label_up,
             size=size.tiny,
             yloc=yloc.belowbar
        )

    if show_signal_box
        signal_box := box.new(
             bar_index,
             high,
             bar_index + 1,
             low,
             border_color=color.orange,
             border_width=1,
             bgcolor=box_col
        )

// Extend last setup lines forward
if show_last_setup
    if not na(entry_line)
        line.set_x2(entry_line, bar_index + 10)
    if not na(sl_line)
        line.set_x2(sl_line, bar_index + 10)
    if not na(tp_line)
        line.set_x2(tp_line, bar_index + 10)
    if not na(tp2_line)
        line.set_x2(tp2_line, bar_index + 10)

    if not na(entry_label)
        label.set_x(entry_label, bar_index + 10)
    if not na(sl_label)
        label.set_x(sl_label, bar_index + 10)
    if not na(tp_label)
        label.set_x(tp_label, bar_index + 10)
    if not na(tp2_label)
        label.set_x(tp2_label, bar_index + 10)

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard
// ─────────────────────────────────────────────────────────────────────────────

// Dashboard position
dash_pos = switch dashboard_position
    "Top Right"     => position.top_right
    "Top Center"    => position.top_center
    "Top Left"      => position.top_left
    "Middle Right"  => position.middle_right
    "Middle Center" => position.middle_center
    "Middle Left"   => position.middle_left
    "Bottom Right"  => position.bottom_right
    "Bottom Center" => position.bottom_center
    "Bottom Left"   => position.bottom_left
    => position.top_right

// Dashboard text size
dash_size = switch dashboard_size
    "Small"  => size.small
    "Large"  => size.large
    => size.normal

// High-contrast dashboard colors
dash_header_bg = color.rgb(18, 22, 33)
dash_left_bg   = color.rgb(31, 36, 48)
dash_right_bg  = color.rgb(10, 14, 22)
dash_border    = color.rgb(85, 95, 115)

dash_text      = color.white
dash_muted     = color.rgb(175, 182, 195)
dash_green     = color.rgb(0, 230, 118)
dash_orange    = color.rgb(255, 160, 0)
dash_red       = color.rgb(255, 82, 82)
dash_purple    = color.rgb(190, 120, 255)

var table dash = table.new(
     dash_pos,
     2,
     11,
     border_width=1,
     border_color=dash_border,
     frame_color=dash_border,
     frame_width=1
)

trend_text    = is_uptrend ? "Bullish" : "Weak / Neutral"
rev_text      = rev_signal ? "Yes" : "No"
vol_text      = vol_signal ? "Yes" : "No"
breakout_text = is_breakout ? "Yes" : "No"
risk_ok_text  = is_risk_ok ? "Yes" : "No"

age_text = na(last_buy_age) ? "N/A" : str.tostring(last_buy_age) + " bars ago"
age_col  = na(last_buy_age) ? dash_muted : is_fresh_buy ? dash_green : dash_orange

risk_text    = na(last_risk_pct) ? "N/A" : str.tostring(last_risk_pct, "#.##") + "%"
reward_text  = na(last_reward_pct) ? "N/A" : str.tostring(last_reward_pct, "#.##") + "%"
reward2_text = na(last_reward2_pct) ? "N/A" : str.tostring(last_reward2_pct, "#.##") + "%"

if barstate.islast and show_dashboard
    table.cell(dash, 0, 0, "Volume Breakout", bgcolor=dash_header_bg, text_color=dash_text, text_size=dash_size)
    table.cell(dash, 1, 0, "Status", bgcolor=dash_header_bg, text_color=dash_text, text_size=dash_size)

    table.cell(dash, 0, 1, "Trend", text_color=dash_text, bgcolor=dash_left_bg, text_size=dash_size)
    table.cell(dash, 1, 1, trend_text, text_color=is_uptrend ? dash_green : dash_orange, bgcolor=dash_right_bg, text_size=dash_size)

    table.cell(dash, 0, 2, "RSI", text_color=dash_text, bgcolor=dash_left_bg, text_size=dash_size)
    table.cell(dash, 1, 2, str.tostring(rsi_val, "#.##"), text_color=is_rsi_ok ? dash_green : dash_orange, bgcolor=dash_right_bg, text_size=dash_size)

    table.cell(dash, 0, 3, "REV", text_color=dash_text, bgcolor=dash_left_bg, text_size=dash_size)
    table.cell(dash, 1, 3, rev_text, text_color=rev_signal ? dash_purple : dash_muted, bgcolor=dash_right_bg, text_size=dash_size)

    table.cell(dash, 0, 4, "VOL", text_color=dash_text, bgcolor=dash_left_bg, text_size=dash_size)
    table.cell(dash, 1, 4, vol_text, text_color=vol_signal ? dash_orange : dash_muted, bgcolor=dash_right_bg, text_size=dash_size)

    table.cell(dash, 0, 5, "Breakout", text_color=dash_text, bgcolor=dash_left_bg, text_size=dash_size)
    table.cell(dash, 1, 5, breakout_text, text_color=is_breakout ? dash_green : dash_orange, bgcolor=dash_right_bg, text_size=dash_size)

    table.cell(dash, 0, 6, "Risk OK", text_color=dash_text, bgcolor=dash_left_bg, text_size=dash_size)
    table.cell(dash, 1, 6, risk_ok_text, text_color=is_risk_ok ? dash_green : dash_red, bgcolor=dash_right_bg, text_size=dash_size)

    table.cell(dash, 0, 7, "Last Entry", text_color=dash_text, bgcolor=dash_left_bg, text_size=dash_size)
    table.cell(dash, 1, 7, na(last_entry) ? "N/A" : str.tostring(last_entry, format.mintick), text_color=dash_text, bgcolor=dash_right_bg, text_size=dash_size)

    table.cell(dash, 0, 8, "Last SL / TP1 / TP2", text_color=dash_text, bgcolor=dash_left_bg, text_size=dash_size)
    table.cell(
         dash,
         1,
         8,
         na(last_sl) or na(last_tp) or na(last_tp2) ? "N/A" : str.tostring(last_sl, format.mintick) + " / " + str.tostring(last_tp, format.mintick) + " / " + str.tostring(last_tp2, format.mintick),
         text_color=dash_text,
         bgcolor=dash_right_bg,
         text_size=dash_size
    )

    table.cell(dash, 0, 9, "Risk / TP1 / TP2", text_color=dash_text, bgcolor=dash_left_bg, text_size=dash_size)
    table.cell(dash, 1, 9, risk_text + " / " + reward_text + " / " + reward2_text, text_color=dash_text, bgcolor=dash_right_bg, text_size=dash_size)

    table.cell(dash, 0, 10, "Last BUY Age", text_color=dash_text, bgcolor=dash_left_bg, text_size=dash_size)
    table.cell(dash, 1, 10, age_text, text_color=age_col, bgcolor=dash_right_bg, text_size=dash_size)

if barstate.islast and not show_dashboard
    table.clear(dash, 0, 0, 1, 10)

// ─────────────────────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(
     rev_signal,
     title="Volume Breakout REV Signal",
     message="Volume Breakout REV Signal on {{ticker}} | Early reversal volume candle detected"
)

alertcondition(
     vol_only,
     title="Volume Breakout VOL Signal",
     message="Volume Breakout VOL Signal on {{ticker}} | Strong trend volume candle detected"
)

alertcondition(
     buy_signal,
     title="Volume Breakout BUY Confirmed",
     message="Volume Breakout BUY Confirmed on {{ticker}} | Entry above {{high}} | Stop below {{low}}"
)

alertcondition(
     entry_line_break,
     title="Entry Line Break",
     message="Entry line was touched or broken on {{ticker}} | Price reached the last BUY entry line"
)

alertcondition(
     sl_line_break,
     title="Stop Loss Line Break",
     message="Stop loss line was touched or broken on {{ticker}} | Price reached the last BUY stop loss line"
)

alertcondition(
     tp1_reached,
     title="TP1 Reached",
     message="TP1 reached on {{ticker}}"
)

alertcondition(
     tp2_reached,
     title="TP2 Reached",
     message="TP2 reached on {{ticker}}"
)
````
