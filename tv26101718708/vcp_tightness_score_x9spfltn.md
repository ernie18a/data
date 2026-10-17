# VCP Tightness Score

- url: https://www.tradingview.com/script/x9SpfLtN-VCP-Tightness-Score/
- type: indicator
- pine_id: PUB;c6b5182e1e554e11886b4865de3a809a
- version: 1.0

## Description

VCP Tightness Score

[i][b]Original concept and script by joshdm_94 (@ETFbreakouts on X). Modified and extended with a 3-zone color system and single dot display.[/b][/i]

Spotting a true Volatility Contraction Pattern requires more than just looking for small candles. A 5% price swing might be tight for a high-beta growth stock but extremely loose for a slower mover. This indicator solves that by measuring how tight a stock's recent price action is relative to its own historical volatility — not against a fixed number.

How It Works

The script calculates two metrics over your chosen lookback period (default 5 bars):

- Closing Spread: the percentage difference between the highest and lowest close

- Total Swing Spread: the percentage difference between the absolute high and low

Both are divided by the stock's Average Daily Range % and normalized on a 0–100 scale based on a historical baseline window (default 50 bars). A score near 0 means the stock is compressing tighter than at any point in the baseline period. A score near 100 means price action is wide and volatile.

How to Read It

A single colored dot in the top right corner of your chart updates in real time:

- 🟢 Green (0–15): Entry zone. Price is compressed and ready. Look for a pivot with volume dry-up confirmation.

- 🟠 Orange (16–40): Still contracting. Keep it on your watchlist and check back daily.

- 🔴 Red (41–100): Too loose. Stay away until volatility contracts further.

Inputs

- Tightness Lookback: bars to measure current compression (default 5)

- ADR Lookback: bars to calculate the stock's normal volatility (default 20)

- Historical Baseline: normalization window for the 0–100 score (default 50)

Best Use Cases

Designed for daily and weekly charts. Most effective when used alongside volume dry-ups to confirm VCPs, high tight flags, and cup and handle bases before the breakout.

## Source Code

````pine
//@version=6
indicator("VCP Tightness Score", shorttitle="VCP", overlay=true)

// --- Inputs ---
len      = input.int(5,  title="Tightness Lookback (Bars)", minval=2)
adr_len  = input.int(20, title="ADR Lookback (Bars)",        minval=1)
baseline = input.int(50, title="Historical Baseline (Bars)", minval=10)

// --- Calculation ---
bar_range_pct    = ((high - low) / low) * 100
adr_pct          = ta.sma(bar_range_pct, adr_len)
safe_adr         = adr_pct == 0 ? 0.0001 : adr_pct

hi_c             = ta.highest(close, len)
lo_c             = ta.lowest(close, len)
close_spread_pct = ((hi_c - lo_c) / lo_c) * 100

hi_p             = ta.highest(high, len)
lo_p             = ta.lowest(low, len)
price_spread_pct = ((hi_p - lo_p) / lo_p) * 100

close_ratio      = close_spread_pct / safe_adr
price_ratio      = price_spread_pct / safe_adr
combined_ratio   = (close_ratio + price_ratio) / 2

highest_ratio    = ta.highest(combined_ratio, baseline)
lowest_ratio     = ta.lowest(combined_ratio, baseline)
range_ratio      = highest_ratio - lowest_ratio
score            = range_ratio == 0 ? 0 : ((combined_ratio - lowest_ratio) / range_ratio) * 100

// --- Color Logic ---
col = score <= 15 ? color.lime :
      score <= 40 ? color.orange :
      color.new(#8B0000, 0)

// --- Single dot in top right via table ---
var table dot = table.new(position.top_right, 1, 1)
if barstate.islast
    table.cell(dot, 0, 0, text="⬤", text_color=col, text_size=size.large)
````
