# byquan RSI-MA & SRSI Direction Sync

- url: https://www.tradingview.com/script/0la4dvK1/
- type: indicator
- pine_id: PUB;8b64a560e4224bb8b8b52c03d9cd235f
- version: 1.0

## Description

// RSI-MA & SRSI Direction Sync

This indicator is designed to detect **momentum direction synchronization** between two different smoothed momentum oscillators across multiple timeframes. 

Instead of simply plotting multiple oscillators, the core idea is to identify when two independent momentum calculations are moving **in the same direction at the same time** — providing a clearer view of underlying strength or weakness in price momentum.

### How It Works

**Line 1 – RSI-MA (30-minute base):**
- Calculates a 14-period RSI and then smooths it with a 14-period Simple Moving Average (SMA).
- This line is requested from the 30-minute timeframe to filter out some noise while remaining responsive.

**Line 2 – Multi-Timeframe SRSI "oranclose" (Smoothed):**
- Computes a Stochastic RSI (Stoch of RSI) using user-defined K & D smoothing.
- Aggregates this value from **four higher timeframes** (default: 3H, 6H, 12H, and Daily) to capture broader momentum context.
- The combined value is then smoothed with an EMA to reduce whipsaws.

**Direction Sync Detection:**
- The script checks whether both lines are rising simultaneously (**Both Up** — strong bullish momentum agreement) or falling simultaneously (**Both Down** — strong bearish momentum agreement).
- When directions align:
  - Green color + background tint = bullish synchronization
  - Red color + background tint = bearish synchronization
  - Gray = no clear synchronization (momentum is mixed or weak)

### Why This Combination?

Many traders struggle with conflicting signals between fast and slow momentum tools. This script addresses that by:
- Using a shorter, smoothed RSI-MA as a more responsive "local" momentum reference.
- Using a multi-timeframe averaged Stochastic RSI as a "higher-timeframe bias" filter.
- Focusing purely on **directional agreement** rather than absolute levels. 

This creates a simple yet effective way to visualize when short-term and broader momentum are aligned, which can help confirm trend strength or highlight potential exhaustion when they diverge.

### How to Use

- **Bullish Setup**: Look for consistent green lines and background. This suggests momentum is strengthening across different scales — favorable for long positions or holding longs.
- **Bearish Setup**: Look for consistent red lines and background. This indicates weakening momentum — potential short opportunities or caution for longs.
- The area fill between the two lines helps visualize the "spread" or convergence between the two momentum measures.
- Reference lines at 80 / 50 / 20 provide additional context for overbought/neutral/oversold zones.

**Recommended Timeframes:**
- Best used on 5m, 15m, or 30m charts for intraday/swing trading.
- The higher timeframes in Line 2 provide the necessary context without requiring you to switch charts.

**Settings Tips:**
- Adjust the "EMA Smooth Length" on Line 2 to make it more or less responsive.
- You can enable/disable the background color for a cleaner view.
- Experiment with different timeframe combinations in the "Line 2 · SRSI oranclose" group to match your trading style.

This tool does **not** generate buy/sell arrows on purpose — it is a **momentum alignment visualizer** meant to support your own price action and structure analysis. Always combine with proper risk management.

The script is open-source for transparency and educational purposes.

Feel free to experiment and share your feedback!

## Source Code

````pine
//@version=5
indicator("RSI-MA & SRSI Direction Sync", overlay=false)

// ─── Inputs: Line 1 - RSI baseMA ──────────────────────────
rsi_len    = input.int(14, "RSI Length",          minval=1, group="Line 1 · RSI baseMA (30m)")
ma_len     = input.int(14, "SMA Length",           minval=1, group="Line 1 · RSI baseMA (30m)")

// ─── Inputs: Line 2 - SRSI oranclose ─────────────────────
smoothK    = input.int(3,  "K",                   minval=1, group="Line 2 · SRSI oranclose")
smoothD    = input.int(3,  "D",                   minval=1, group="Line 2 · SRSI oranclose")
lengthRSI  = input.int(14, "RSI Length",          minval=1, group="Line 2 · SRSI oranclose")
lengthS    = input.int(14, "Stoch Length",         minval=1, group="Line 2 · SRSI oranclose")
smooth_len = input.int(5,  "EMA Smooth Length",   minval=1, group="Line 2 · SRSI oranclose")
time1      = input.timeframe("180", "Time 1",              group="Line 2 · SRSI oranclose")
time2      = input.timeframe("360", "Time 2",              group="Line 2 · SRSI oranclose")
time3      = input.timeframe("720", "Time 3",              group="Line 2 · SRSI oranclose")
time4      = input.timeframe("D",   "Time 4",              group="Line 2 · SRSI oranclose")

// ─── Inputs: Display ──────────────────────────────────────
show_bg    = input.bool(true, "Hiện nền (bgcolor)", group="Display")

// ─── Line 1: SMA(RSI) lấy từ khung 30m ───────────────────
f_rsi_ma() =>
    ta.sma(ta.rsi(close, rsi_len), ma_len)

line1 = request.security(syminfo.tickerid, "30", f_rsi_ma())

// ─── Line 2: oranclose từ SRSI, làm mượt bằng EMA ────────
f_srsi_ds() =>
    r = ta.rsi(close, lengthRSI)
    k = ta.sma(ta.stoch(r, r, r, lengthS), smoothK)
    d = ta.sma(k, smoothD)
    k + d

c1 = request.security(syminfo.tickerid, str.tostring(time1), f_srsi_ds())
c2 = request.security(syminfo.tickerid, str.tostring(time2), f_srsi_ds())
c3 = request.security(syminfo.tickerid, str.tostring(time3), f_srsi_ds())
c4 = request.security(syminfo.tickerid, str.tostring(time4), f_srsi_ds())

oranclose_raw = (100 * (c1 + c2 + c3 + c4)) / 800
line2         = ta.ema(oranclose_raw, smooth_len)   // làm mượt ở đây

// ─── Xác định chiều đồng thuận ────────────────────────────
both_up   = line1 > line1[1] and line2 > line2[1]
both_down = line1 < line1[1] and line2 < line2[1]

// ─── Màu ──────────────────────────────────────────────────
col_line = both_up ? color.new(#00e676, 0)  : both_down ? color.new(#ff1744, 0)  : color.new(#90a4ae, 0)
col_fill = both_up ? color.new(#00e676, 80) : both_down ? color.new(#ff1744, 80) : color.new(#90a4ae, 90)
col_bg   = both_up ? color.new(#00e676, 93) : both_down ? color.new(#ff1744, 93) : na

// ─── Plot ─────────────────────────────────────────────────
p1 = plot(line1, "RSI SMA · 30m",        color=col_line, linewidth=2)
p2 = plot(line2, "SRSI oranclose · EMA", color=col_line, linewidth=2)

fill(p1, p2, color=col_fill)
bgcolor(show_bg ? col_bg : na, title="Background sync")

// ─── Reference lines ──────────────────────────────────────
hline(80, color=color.rgb(255, 255, 153, 60), linestyle=hline.style_dotted)
hline(50, color=color.rgb(255, 255, 153, 80), linestyle=hline.style_dotted)
hline(20, color=color.rgb(255, 255, 153, 60), linestyle=hline.style_dotted)
````
