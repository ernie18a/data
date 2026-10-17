# Multiple EMA + SMA (8-in-1, or 4 of each)

- url: https://www.tradingview.com/script/iVLyQ4Kf-Multiple-EMA-SMA-8-in-1-or-4-of-each/
- type: indicator
- pine_id: PUB;9e44d2c78da44dc9ae2c6675aee76107
- version: 1.0

## Description

This combo indicator takes Tradingview's default SMA and EMA Pinescript code and basically duplicates it 8 times. There are 4 EMAs and 4 SMAs, each configurable to their own timeframe, line, color, etc. I did this so I could see several combinations of moving averages on various chart timeframes, such as:

- Daily chart: 200 SMA, 50 SMA, 20 EMA
- 4 hour chart: 200 SMA, 50 EMA, 20 EMA
- 1 hour chart: 50 EMA, 20 EMA, 9 EMA
- 30 minute chart: 50 EMA, 20 EMA, 9 EMA

Moving Averages Are Filters, Not Triggers: The moving average smooths price action to reveal the dominant market current, not to provide buy or sell signals alone. It filters market noise but requires price action confirmation for entry decisions.Therefore it's important to note the **slope** direction of the MA too.

Matching Time Frame and Holding Period: Using a moving average setting built on a timeframe inconsistent with your trade duration (e.g., a short moving average on a multi-month trade) causes frequent whipsaws. The setting must reflect your trade horizon.

Three Roles of Moving Averages on Any Time Frame:

1. **Tide (Slowest Line)** — Indicates the overall market direction and which side to trade.
2. **Trend (Middle Line)** — Represents the active trend you trade around.
3. **Timing (Fastest Line)** — Identifies pullback zones and potential entry points.

Consistency and Discipline are Crucial: The hardest part of trading is not knowing the settings but patiently waiting for alignment of the tide, trend, and timing lines, and resisting impulsive trades.

When to use EMA or SMA: Shorter time frames use EMAs for faster reaction to price changes, whereas longer time frames use SMAs to smooth out noise and emphasize broader trends. The 200-day SMA is particularly important as it is the most widely followed moving average, creating real support/resistance due to collective market attention.

Examples and Practical Application:

- A trader looking for a long trade on the daily chart might identify:
- Price above a rising slope 200 SMA (tide) = only look for long trades
- Price above a rising slope 50 SMA (trend) = confirms a healthy trend
- Price pulls back to 20 EMA (timing zone) = start watching for price action confirming the entry
- Crossovers like the "golden cross" (50 SMA crossing 200 SMA) are only contextual signals indicating trend shifts, don't use them as entry triggers.
- On faster charts (1-hour and 30-minute), multiple touches of moving averages happen frequently due to noise; thus, confirmation from price action, volume, or other indicators is essential.

The core takeaway here is that knowing precise moving average numbers is easy. Mastering the **patience, discipline, and risk management** to trade only when the tide, trend, and timing all align is what really separates successful traders from losing ones.

## Source Code

````pine
//@version=6
//This indicator takes Tradingview's default SMA and EMA Pinescript code and basically duplicates it 8 times.
//There are 4 EMAs and 4 SMAs, each configurable to their own timeframe, line, color, etc.
//I did this so I could see various combinations of moving averages on various chart timeframes, such as:
//Daily chart: 200 SMA, 50 SMA, 20 EMA
//4 hour chart: 200 SMA, 50 EMA, 20 EMA
//1 hour chart: 50 EMA, 20 EMA, 9 EMA
//30 minute chart: 50 EMA, 20 EMA, 9 EMA

indicator(title="Multi EMA + SMA (8-in-1)", shorttitle="Multi MA", overlay=true, timeframe="", timeframe_gaps=true)

// ─────────────────────────────────────────
// EMA INPUTS
// ─────────────────────────────────────────
GRP_EMA1 = "EMA 1"
ema1_on  = input.bool(true,   "Show EMA 1",  group=GRP_EMA1)
ema1_len = input.int(9,       "Length",       group=GRP_EMA1, minval=1)
ema1_src = input(close,       "Source",       group=GRP_EMA1)
ema1_tf  = input.timeframe("", "Timeframe",  group=GRP_EMA1)
ema1_col = input.color(color.new(#FF5252, 0), "Color", group=GRP_EMA1)

GRP_EMA2 = "EMA 2"
ema2_on  = input.bool(true,   "Show EMA 2",  group=GRP_EMA2)
ema2_len = input.int(21,      "Length",       group=GRP_EMA2, minval=1)
ema2_src = input(close,       "Source",       group=GRP_EMA2)
ema2_tf  = input.timeframe("", "Timeframe",  group=GRP_EMA2)
ema2_col = input.color(color.new(#FF9800, 0), "Color", group=GRP_EMA2)

GRP_EMA3 = "EMA 3"
ema3_on  = input.bool(true,   "Show EMA 3",  group=GRP_EMA3)
ema3_len = input.int(50,      "Length",       group=GRP_EMA3, minval=1)
ema3_src = input(close,       "Source",       group=GRP_EMA3)
ema3_tf  = input.timeframe("", "Timeframe",  group=GRP_EMA3)
ema3_col = input.color(color.new(#FFEB3B, 0), "Color", group=GRP_EMA3)

GRP_EMA4 = "EMA 4"
ema4_on  = input.bool(true,   "Show EMA 4",  group=GRP_EMA4)
ema4_len = input.int(200,     "Length",       group=GRP_EMA4, minval=1)
ema4_src = input(close,       "Source",       group=GRP_EMA4)
ema4_tf  = input.timeframe("", "Timeframe",  group=GRP_EMA4)
ema4_col = input.color(color.new(#E040FB, 0), "Color", group=GRP_EMA4)

// ─────────────────────────────────────────
// SMA INPUTS
// ─────────────────────────────────────────
GRP_SMA1 = "SMA 1"
sma1_on  = input.bool(true,   "Show SMA 1",  group=GRP_SMA1)
sma1_len = input.int(9,       "Length",       group=GRP_SMA1, minval=1)
sma1_src = input(close,       "Source",       group=GRP_SMA1)
sma1_tf  = input.timeframe("", "Timeframe",  group=GRP_SMA1)
sma1_col = input.color(color.new(#40C4FF, 0), "Color", group=GRP_SMA1)

GRP_SMA2 = "SMA 2"
sma2_on  = input.bool(true,   "Show SMA 2",  group=GRP_SMA2)
sma2_len = input.int(21,      "Length",       group=GRP_SMA2, minval=1)
sma2_src = input(close,       "Source",       group=GRP_SMA2)
sma2_tf  = input.timeframe("", "Timeframe",  group=GRP_SMA2)
sma2_col = input.color(color.new(#69F0AE, 0), "Color", group=GRP_SMA2)

GRP_SMA3 = "SMA 3"
sma3_on  = input.bool(true,   "Show SMA 3",  group=GRP_SMA3)
sma3_len = input.int(50,      "Length",       group=GRP_SMA3, minval=1)
sma3_src = input(close,       "Source",       group=GRP_SMA3)
sma3_tf  = input.timeframe("", "Timeframe",  group=GRP_SMA3)
sma3_col = input.color(color.new(#18FFFF, 0), "Color", group=GRP_SMA3)

GRP_SMA4 = "SMA 4"
sma4_on  = input.bool(true,   "Show SMA 4",  group=GRP_SMA4)
sma4_len = input.int(200,     "Length",       group=GRP_SMA4, minval=1)
sma4_src = input(close,       "Source",       group=GRP_SMA4)
sma4_tf  = input.timeframe("", "Timeframe",  group=GRP_SMA4)
sma4_col = input.color(color.new(#CCFF90, 0), "Color", group=GRP_SMA4)

// ─────────────────────────────────────────
// CALCULATIONS (with request.security for HTF)
// ─────────────────────────────────────────
ema1_raw = ta.ema(ema1_src, ema1_len)
ema2_raw = ta.ema(ema2_src, ema2_len)
ema3_raw = ta.ema(ema3_src, ema3_len)
ema4_raw = ta.ema(ema4_src, ema4_len)

sma1_raw = ta.sma(sma1_src, sma1_len)
sma2_raw = ta.sma(sma2_src, sma2_len)
sma3_raw = ta.sma(sma3_src, sma3_len)
sma4_raw = ta.sma(sma4_src, sma4_len)

ema1_val = request.security(syminfo.tickerid, ema1_tf, ema1_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ema2_val = request.security(syminfo.tickerid, ema2_tf, ema2_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ema3_val = request.security(syminfo.tickerid, ema3_tf, ema3_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ema4_val = request.security(syminfo.tickerid, ema4_tf, ema4_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

sma1_val = request.security(syminfo.tickerid, sma1_tf, sma1_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
sma2_val = request.security(syminfo.tickerid, sma2_tf, sma2_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
sma3_val = request.security(syminfo.tickerid, sma3_tf, sma3_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
sma4_val = request.security(syminfo.tickerid, sma4_tf, sma4_raw, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────
plot(ema1_on ? ema1_val : na, title="EMA 1", color=ema1_col, linewidth=2)
plot(ema2_on ? ema2_val : na, title="EMA 2", color=ema2_col, linewidth=2)
plot(ema3_on ? ema3_val : na, title="EMA 3", color=ema3_col, linewidth=2)
plot(ema4_on ? ema4_val : na, title="EMA 4", color=ema4_col, linewidth=2)

plot(sma1_on ? sma1_val : na, title="SMA 1", color=sma1_col, linewidth=2, style=plot.style_line)
plot(sma2_on ? sma2_val : na, title="SMA 2", color=sma2_col, linewidth=2, style=plot.style_line)
plot(sma3_on ? sma3_val : na, title="SMA 3", color=sma3_col, linewidth=2, style=plot.style_line)
plot(sma4_on ? sma4_val : na, title="SMA 4", color=sma4_col, linewidth=2, style=plot.style_line)
````
