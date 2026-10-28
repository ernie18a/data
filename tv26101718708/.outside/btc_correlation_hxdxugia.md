# BTC Correlation

- url: https://www.tradingview.com/script/HXDxUGiA-btc-correlation/
- type: indicator
- pine_id: PUB;74499683715f441887ddadbdb33b74d3
- version: 1.0

## Description

BTC Correlation Meter — Real-Time Bitcoin Correlation on Chart

What it does
This indicator calculates the Pearson correlation coefficient between the current asset and Bitcoin in real time, displayed directly on the main chart as a compact overlay table in the top-right corner — no separate pane needed.

The value ranges from -1.0 to +1.0:

+1.0 — the asset moves in perfect sync with BTC

0.0 — no relationship

-1.0 — the asset moves in the exact opposite direction of BTC

How to use it
High correlation (above +0.7): The asset is strongly driven by Bitcoin market sentiment. Analyze it together with BTC — entries and exits should account for BTC price action, funding rates, and macro crypto conditions.

Low correlation (below +0.4): The asset has its own independent driver — project fundamentals, sector rotation, or unique news flow. Analyze it on its own merits without relying on BTC signals.

Negative correlation: The asset tends to move against BTC. Useful for spotting hedging opportunities or diversification within a crypto portfolio.

Features
Pearson correlation calculated on bar returns (not raw price) for statistical accuracy

Fully overlay-based — sits on your main chart, no extra pane

Color-coded value: 🟢 green (strong positive) → 🟡 yellow (neutral) → 🔴 red (negative)

Direction arrow ▲ / ▼ for instant visual reading

Configurable BTC reference symbol (default: BINANCE:BTCUSDT)

Configurable correlation period (default: 50 bars)

Settings
Parameter	Default	Description
Bitcoin Symbol	BINANCE:BTCUSDT	Reference BTC feed
Correlation Period	50	Lookback window in bars
Interpretation guide
Value	          Meaning
+0.7 to +1.0	Strong positive — analyze with BTC
+0.4 to +0.7	Moderate positive
0.0 to +0.4	Weak positive
-0.4 to 0.0	Weak negative
-0.7 to -0.4	Moderate negative
-1.0 to -0.7	Strong negative — potential hedge
Tip
Use on higher timeframes (4H, Daily) with a period of 50–100 bars for stable, noise-free readings. On lower timeframes (15m, 1H) reduce the period to 20–30 bars.

## Source Code

````pine
//@version=6
indicator("BTC Correlation", overlay=true)

// ═══════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════
btc_symbol = input.symbol("BINANCE:BTCUSDT", "Bitcoin Symbol")
period     = input.int(50, "Correlation Period", minval=10, maxval=300)

// ═══════════════════════════════════════════════
//  DATA
// ═══════════════════════════════════════════════
btc_close  = request.security(btc_symbol, timeframe.period, close)
asset_ret  = (close - close[1]) / close[1]
btc_ret    = (btc_close - btc_close[1]) / btc_close[1]

correlation = ta.correlation(asset_ret, btc_ret, period)

// ═══════════════════════════════════════════════
//  COLOR по значению
// ═══════════════════════════════════════════════
corr_color = correlation >= 0.7  ? color.new(#00c87a, 0) :
             correlation >= 0.4  ? color.new(#8bc34a, 0) :
             correlation >= 0.0  ? color.new(#ffd54f, 0) :
             correlation >= -0.4 ? color.new(#ff9800, 0) :
             correlation >= -0.7 ? color.new(#f44336, 0) :
                                   color.new(#b71c1c, 0)

// ═══════════════════════════════════════════════
//  ТАБЛИЦА — overlay, верхний правый угол
// ═══════════════════════════════════════════════
var table t = table.new(
     position.top_right, 2, 2,
     bgcolor      = color.new(#0d0d0d, 30),
     border_color = color.new(color.white, 70),
     border_width = 1,
     frame_color  = color.new(color.white, 60),
     frame_width  = 1)

if barstate.islast
    table.cell(t, 0, 0, "BTC Corr",
         text_color = color.new(color.silver, 10),
         text_size  = size.small,
         bgcolor    = color.new(#1a1f2e, 20))
    table.cell(t, 1, 0, str.tostring(period) + "b",
         text_color = color.new(color.silver, 30),
         text_size  = size.small,
         bgcolor    = color.new(#1a1f2e, 20))
    table.cell(t, 0, 1, str.tostring(math.round(correlation, 2)),
         text_color = corr_color,
         text_size  = size.large,
         bgcolor    = color.new(#0d0d0d, 20))
    table.cell(t, 1, 1, correlation >= 0 ? "▲" : "▼",
         text_color = corr_color,
         text_size  = size.normal,
         bgcolor    = color.new(#0d0d0d, 20))
````
