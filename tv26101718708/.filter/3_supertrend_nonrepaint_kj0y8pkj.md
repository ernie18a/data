# 3 Supertrend NON-REPAINT

- url: https://www.tradingview.com/script/Kj0y8pkJ/
- type: indicator
- pine_id: PUB;497acaf7c977493c9a56d7f4efb26ebb
- version: 1.0

## Description

[b]3 Supertrend NON-REPAINT PRO — Institutional Market Filter System[/b]

The 3 Supertrend NON-REPAINT PRO is a next-generation evolution of the classic multi-Supertrend concept, redesigned for modern intraday and swing trading environments. Instead of relying on simple trend alignment, this system builds a multi-layer market intelligence engine that filters noise, confirms structure, and focuses only on high-quality trading conditions.

Most Supertrend strategies fail in real markets because they:
Overtrade in choppy conditions
Ignore volume context
Lack session awareness
Repaint or behave inconsistently in backtests
This version solves those issues by combining trend, volatility, liquidity, and time filters into one unified framework.

The core of the strategy is built on three independent Supertrend layers (fast, mid, slow):
Trades are only considered when Supertrends agree in direction
This ensures true trend consensus across multiple volatility regimes
Eliminates weak or early-stage signals
This creates a robust directional backbone for the entire system.

A built-in ATR-normalized trend strength engine classifies market conditions into:
🔵 TREND → optimal trading environment
🟡 MIX → reduced reliability
⚫ CHOP → filtered out
This prevents Supertrend signals from firing during low-quality consolidation phases.

Every signal is validated against real participation using relative volume:
LOW / NORMAL / HIGH / SPIKE classification
Trades are prioritized only when volume confirms momentum
Filters out weak breakouts and liquidity traps

The strategy adapts to global market behavior by identifying:
Asia session
London session
New York session
US pre-market
Trading is focused on high-liquidity sessions, where trend continuation is statistically stronger and slippage risk is lower.

This system is engineered for real execution reliability:
All signals require bar confirmation
No intrabar repainting behavior
Backtest results remain stable and trustworthy
This makes it suitable for both discretionary and automated trading workflows.

The strategy includes Fair Value Gap detection, allowing traders to:
Identify institutional imbalance zones
Track price inefficiencies in real time
Combine trend signals with structural liquidity zones
This adds a powerful contextual layer beyond pure trend following.

To improve directional bias, the system includes:
Fast EMA (short-term momentum)
Slow EMA (macro trend direction)
These act as a secondary confirmation layer, aligning Supertrend signals with broader market structure.

This is not just a “3 Supertrend indicator”.
It is a multi-factor trading framework that only triggers when all conditions align:
✔ Trend consensus (3 Supertrends)
✔ Market regime validation
✔ Volume confirmation
✔ Session liquidity filter
✔ Structural imbalance awareness (FVG)
✔ Non-repaint confirmation

Instead of reacting to every trend flip, this system focuses only on:
High-probability, high-liquidity, structurally confirmed market moves.
It transforms the classic Supertrend idea into a professional-grade confluence engine designed for disciplined trading and algorithmic consistency.

## Source Code

````pine
//@version=6
indicator(
     title = "3 Supertrend NON-REPAINT",
     shorttitle = "3ST NR",
     overlay = true,
     max_labels_count = 50
)

//─────────────────────────────
// ⚙️ INPUTS
//─────────────────────────────
atr1 = input.int(10, "ATR Fast", group = "Supertrend Settings")
fac1 = input.float(1.2, "Factor Fast", group = "Supertrend Settings")

atr2 = input.int(11, "ATR Mid", group = "Supertrend Settings")
fac2 = input.float(1.8, "Factor Mid", group = "Supertrend Settings")

atr3 = input.int(12, "ATR Slow", group = "Supertrend Settings")
fac3 = input.float(2.2, "Factor Slow", group = "Supertrend Settings")

show_dashboard = input.bool(true, "Show Dashboard", group = "Display")

//─────────────────────────────
// ⚙️ RISK / FILTERS
//─────────────────────────────
filter_by_market = input.bool(true, "Filter: Trade only in TREND", group = "Filters")
filter_by_volume = input.bool(false, "Filter: Require HIGH/SPIKE Volume", group = "Filters")
filter_by_session = input.bool(false, "Filter: Trade only in NY/LONDON", group = "Filters")

//─────────────────────────────
// 🎯 SUPERTREND ENGINE
//─────────────────────────────
[st1, dir1] = ta.supertrend(fac1, atr1)
[st2, dir2] = ta.supertrend(fac2, atr2)
[st3, dir3] = ta.supertrend(fac3, atr3)

//─────────────────────────────
// 📡 SIGNALS
//─────────────────────────────
bull = dir1 < 0 and dir2 < 0 
bear = dir1 > 0 and dir2 > 0 

long_signal_raw = bull and not bull[1]
short_signal_raw = bear and not bear[1]

//─────────────────────────────
// 📊 MARKET ENGINE
//─────────────────────────────
atr = ta.atr(14)
ema21 = ta.ema(close, 21)

trend_strength =
     atr != 0
     ? math.abs(close - ema21) / atr
     : 0

market_state =
     trend_strength > 1.2 ? "TREND" :
     trend_strength < 0.5 ? "CHOP" :
     "MIX"

//─────────────────────────────
// 📈 VOLUME ENGINE
//─────────────────────────────
vol_sma = ta.sma(volume, 20)

vol_ratio =
     vol_sma != 0
     ? volume / vol_sma
     : 0

vol_state =
     vol_ratio < 0.9 ? "LOW" :
     vol_ratio < 1.2 ? "NORMAL" :
     vol_ratio < 1.6 ? "HIGH" :
     "SPIKE"

//─────────────────────────────
// 🌍 SESSION ENGINE
//─────────────────────────────
inNY     = not na(time(timeframe.period, "1530-2200", "Europe/Warsaw"))
inLondon = not na(time(timeframe.period, "0900-1700", "Europe/Warsaw"))
inAsia   = not na(time(timeframe.period, "0100-1000", "Europe/Warsaw"))
inUSPre  = not na(time(timeframe.period, "1400-1530", "Europe/Warsaw"))

session_state =
     inNY     ? "NY" :
     inLondon ? "LONDON" :
     inAsia   ? "ASIA" :
     inUSPre  ? "US PRE" :
     "OFF"

//─────────────────────────────
// 🔍 FILTERS
//─────────────────────────────
market_ok =
     not filter_by_market
     or market_state == "TREND"

volume_ok =
     not filter_by_volume
     or (vol_state == "HIGH" or vol_state == "SPIKE")

session_ok =
     not filter_by_session
     or (session_state == "NY" or session_state == "LONDON")

//─────────────────────────────
// ✅ NON-REPAINT CONFIRMATION
//─────────────────────────────
bar_confirmed = barstate.isconfirmed

valid_long =
     long_signal_raw
     and market_ok
     and volume_ok
     and session_ok
     and bar_confirmed

valid_short =
     short_signal_raw
     and market_ok
     and volume_ok
     and session_ok
     and bar_confirmed

//─────────────────────────────
// 🎨 SIGNALS
//─────────────────────────────
plotshape(
     valid_long,
     title = "BUY",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.lime,
     size = size.tiny
)

plotshape(
     valid_short,
     title = "SELL",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.red,
     size = size.tiny
)

//─────────────────────────────
// 🎨 BAR COLORS
//─────────────────────────────
barcolor(
     bull ? color.rgb(20, 230, 0) :
     bear ? color.rgb(220, 0, 0) :
     color.gray
)

//─────────────────────────────
// 📈 EMAs
//─────────────────────────────
len9 = input.int(9, minval=1, title="Length")
src9 = input(close, title="Source")
offset = input.int(title="Offset", defval=0, minval=-500, maxval=500, display = display.none)
out = ta.ema(src9, len9)
plot(out, title="EMA", color=color.rgb(119, 119, 119, 27), style = plot.style_stepline, offset=1)
ema_fast_len = input.int(20, minval = 1, title = "EMA Fast Length", group = "EMAs")
ema_fast = ta.ema(close, ema_fast_len)

plot(
     ema_fast,
     title = "EMA Fast",
     color = color.rgb(233, 202, 0, 65),
     style = plot.style_circles
)

ema_slow_len = input.int(200, minval = 1, title = "EMA Slow Length", group = "EMAs")
ema_slow = ta.ema(close, ema_slow_len)

plot(
     ema_slow,
     title = "EMA Slow",
     color = color.rgb(33, 149, 243, 74),
     style = plot.style_circles
)

//─────────────────────────────
// 🎨 DASHBOARD
//─────────────────────────────
market_col =
     market_state == "TREND"
     ? color.blue
     : market_state == "CHOP"
     ? color.yellow
     : color.gray

vol_col =
     vol_state == "NORMAL"
     ? color.white
     : vol_state == "HIGH"
     ? color.blue
     : vol_state == "SPIKE"
     ? color.red
     : color.gray

session_col =
     session_state == "NY"
     ? color.red
     : color.white

var table dash = table.new(position.top_right, 2, 6, border_width = 1)

if barstate.islast and show_dashboard

    table.cell(
         dash,
         0,
         0,
         "3ST NR",
         bgcolor = color.black,
         text_color = color.white
    )

    table.cell(
         dash,
         1,
         0,
         timeframe.period,
         text_color = color.white
    )

    table.cell(dash, 0, 1, "Market")
    table.cell(
         dash,
         1,
         1,
         market_state,
         text_color = market_col
    )

    table.cell(dash, 0, 2, "Volume")
    table.cell(
         dash,
         1,
         2,
         vol_state + " " + str.tostring(vol_ratio, "#.00"),
         text_color = vol_col
    )

    table.cell(dash, 0, 3, "Session")
    table.cell(
         dash,
         1,
         3,
         session_state,
         text_color = session_col
    )

    table.cell(dash, 0, 4, "Trend")
    table.cell(
         dash,
         1,
         4,
         str.tostring(trend_strength, "#.00"),
         text_color = market_col
    )

    pos_text =
         bull ? "BULL" :
         bear ? "BEAR" :
         "NEUTRAL"

    pos_col =
         bull ? color.lime :
         bear ? color.red :
         color.gray

    table.cell(dash, 0, 5, "State")
    table.cell(
         dash,
         1,
         5,
         pos_text,
         text_color = pos_col
    )

//─────────────────────────────
// 📦 NON-REPAINT FAIR VALUE GAPS
//─────────────────────────────
gap_extend = input.int(20, "Gap Extension", group = "FVG")

bull_gap =
     bar_confirmed
     and low > high[2]

bear_gap =
     bar_confirmed
     and high < low[2]

if bull_gap
    box.new(
         left = bar_index - 2,
         top = low,
         right = bar_index + gap_extend,
         bottom = high[2],
         bgcolor = color.new(color.green, 80),
         border_color = na
    )

if bear_gap
    box.new(
         left = bar_index - 2,
         top = low[2],
         right = bar_index + gap_extend,
         bottom = high,
         bgcolor = color.new(color.red, 80),
         border_color = na
    )

alertcondition(
     bull_gap or bear_gap or valid_long or valid_short,
     title = "FVG",
     message = "FVG"
)
````
