# Elite Ultimate SMC PRO - Probability Engine

- url: https://www.tradingview.com/script/hnhyPWGn-Elite-Ultimate-SMC-PRO-Probability-Engine/
- type: indicator
- pine_id: PUB;5df1d88c4115494cba8ef0ac45b9064b
- version: 1.0

## Description

Description:

Overview:
This indicator is a comprehensive Smart Money Concepts (SMC) engine designed to filter noise and identify high-probability trade setups. By combining market structure analysis with momentum and trend filters, the engine generates a dynamic "Probability Score" (0-100).

How it works:
The script evaluates four core market conditions before triggering an entry signal:

1-Market Structure: Identifies swing highs and lows using custom lookback periods.

2-Momentum (Stochastic): Monitors overbought/oversold conditions to avoid entering late.

3-Money Flow (MFI): Confirms if the market volume supports the price move.

4-Trend Filter: Uses SMAs to ensure the trade is aligned with the broader trend.


Features:

1-Probability Score: Only shows signals that meet your customized threshold.

2-Automated Risk Management: Automatically calculates and plots SL (Stop Loss) and TP (Take Profit) levels based on ATR (Average True Range).

3-FVG Detection: Visualizes Fair Value Gaps on the chart to identify areas of price inefficiency.


Settings:

1-Score Threshold: Adjust the sensitivity of the signals (Default 70).

2-Swing Lookback: Change to suit your preferred timeframe (Intraday vs. Swing).

3-ATR Multipliers: Customize your Risk/Reward ratio for TP1 and TP2.


Usage Tips:

1-Works best on 1H/4H timeframes.

2-Use the "Score" on the label to gauge the strength of the setup.

3-Always combine with your own market analysis.

Disclaimer: This indicator is for educational purposes only and does not constitute financial advice. Always perform your own due diligence.

BY ANDREHAN

## Source Code

````pine
//@version=6
indicator("Elite Ultimate SMC PRO - Probability Engine", overlay=true, max_labels_count=200, max_lines_count=200)

// 1. הגדרות (Inputs)
gp_config = "⚙️ הגדרות מנוע הדירוג"
score_threshold = input.int(70, "סף ציון מינימלי להצגת אות (0-100)", minval=50, maxval=100, group=gp_config)
swing_lookback  = input.int(10, "טווח זיהוי SMC")
atr_len         = input.int(14, "תקופת ATR")
sl_mult         = input.float(1.5, "סטופ לוס (ATR x)")
tp1_mult        = input.float(1.5, "יעד 1 (ATR x)")
tp2_mult        = input.float(3.0, "יעד 2 (ATR x)")

// 2. חישובים ומנוע ניקוד (Scoring Engine)
atr = ta.atr(atr_len)
mfi = ta.mfi(close, 14)
rsi_val = ta.rsi(close, 14)
stoch_k = ta.sma(ta.stoch(rsi_val, rsi_val, rsi_val, 14), 3)

is_high = ta.pivothigh(high, swing_lookback, swing_lookback)
is_low = ta.pivotlow(low, swing_lookback, swing_lookback)

var float swing_high = na
var float swing_low = na

if not na(is_high)
    swing_high := is_high
if not na(is_low)
    swing_low := is_low

// חישוב ניקוד (0-100)
int score_bull = 0
int score_bear = 0

if ta.crossover(close, swing_high)
    score_bull += 40
if mfi > 45
    score_bull += 20
if stoch_k < 30
    score_bull += 20
if (ta.sma(close, 20) > ta.sma(close, 50))
    score_bull += 20 

if ta.crossunder(close, swing_low)
    score_bear += 40
if mfi < 55
    score_bear += 20
if stoch_k > 70
    score_bear += 20
if (ta.sma(close, 20) < ta.sma(close, 50))
    score_bear += 20

// 3. סיגנלים מאומתים
bool buy_signal  = barstate.isconfirmed and (score_bull >= score_threshold)
bool sell_signal = barstate.isconfirmed and (score_bear >= score_threshold)

// 4. ניהול קווים ולייבלים (יציב)
var line sl_line = na
var line tp1_line = na
var line tp2_line = na

if buy_signal
    line.delete(sl_line)
    line.delete(tp1_line)
    line.delete(tp2_line)
    sl_line  := line.new(bar_index, close - (atr * sl_mult), bar_index + 20, close - (atr * sl_mult), color=color.red, width=2)
    tp1_line := line.new(bar_index, close + (atr * tp1_mult), bar_index + 20, close + (atr * tp1_mult), color=color.green, width=1)
    tp2_line := line.new(bar_index, close + (atr * tp2_mult), bar_index + 20, close + (atr * tp2_mult), color=color.blue, width=1)
    label.new(bar_index, low, text="🏛️ BUY\nProbability: " + str.tostring(score_bull) + "%", color=color.green, textcolor=color.white, style=label.style_label_up)

if sell_signal
    line.delete(sl_line)
    line.delete(tp1_line)
    line.delete(tp2_line)
    sl_line  := line.new(bar_index, close + (atr * sl_mult), bar_index + 20, close + (atr * sl_mult), color=color.red, width=2)
    tp1_line := line.new(bar_index, close - (atr * tp1_mult), bar_index + 20, close - (atr * tp1_mult), color=color.green, width=1)
    tp2_line := line.new(bar_index, close - (atr * tp2_mult), bar_index + 20, close - (atr * tp2_mult), color=color.blue, width=1)
    label.new(bar_index, high, text="🏛️ SELL\nProbability: " + str.tostring(score_bear) + "%", color=color.red, textcolor=color.white, style=label.style_label_down)

plotshape(buy_signal, "Buy", shape.triangleup, location.belowbar, color=color.green, size=size.normal)
plotshape(sell_signal, "Sell", shape.triangledown, location.abovebar, color=color.red, size=size.normal)

// 5. FVG
if high[2] < low[0] and close[1] > high[2]
    box.new(bar_index - 2, low[0], bar_index, high[2], bgcolor=color.new(color.green, 85), border_color=color.new(color.green, 100))
if low[2] > high[0] and close[1] < low[2]
    box.new(bar_index - 2, high[0], bar_index, low[2], bgcolor=color.new(color.red, 85), border_color=color.new(color.red, 100))
````
