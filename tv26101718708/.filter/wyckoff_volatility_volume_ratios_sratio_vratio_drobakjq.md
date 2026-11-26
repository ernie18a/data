# Wyckoff Volatility & Volume Ratios [S-Ratio & V-Ratio]

- url: https://www.tradingview.com/script/drobakJq-Wyckoff-Volatility-Volume-Ratios-S-Ratio-V-Ratio/
- type: indicator
- pine_id: PUB;a87851392f234622a110b50568c95a60
- version: 1.0

## Description

📊 Wyckoff Volatility & Volume Ratios [S-Ratio & V-Ratio]

Overview
This indicator automates the mathematical core of Wyckoff Effort vs. Result Analysis by normalizing price range expansion against 14-period market volatility (S-Ratio) and volume against its 20-period moving average (V-Ratio).

Instead of subjectively guessing whether a candlestick represents true institutional absorption, ease of movement, or range compression, this script quantifies price spread and volume into clear, objective execution gates.

🔑 Key Metrics Explained
1. Spread Ratio (S-Ratio)
Normalizes absolute candle spread (High - Low) against the 14-period Average True Range (ATR):
S-Ratio = (High - Low) / ATR(14)

>= 1.5 (Extreme / Climax): Range expansion, typical for Selling/Buying Climaxes (SC/BC) or aggressive breakouts.

>= 1.2 (Wide Spread): Confirms clear directional price displacement.

<= 0.8 (Narrow Spread): Price compression or low-volatility consolidation.

2. Volume Ratio (V-Ratio)
Measures real-time volume relative to its 20-period Simple Moving Average (SMA):
V-Ratio = Bar Volume / SMA(20, Volume)

>= 2.0 (Climactic Volume): Heavy institutional activity / event-driven spikes.

>= 1.5 (High Volume): Strong participation; mandatory threshold for M1/M5 entry triggers.

<= 0.8 (Low Volume): Confirms low-supply/no-demand secondary tests (Phase C/D).

💡 Wyckoff Structural Applications
Institutional Absorption (Effort > Result):
V-Ratio >= 1.5 AND S-Ratio <= 0.8
High volume with narrow spread at support or resistance indicates smart money absorbing liquidity (Springs / Upthrusts).

Ease of Movement (Result > Effort):
V-Ratio <= 0.8 AND S-Ratio >= 1.2
Wide price displacement on light volume, confirming lack of opposing liquidity.

Sign of Strength / Weakness (SOS / SOW Breakouts):
V-Ratio >= 1.5 AND S-Ratio >= 1.2
True range expansion combined with high institutional volume crossing key boundaries (Creek / Ice).

⚙️ Settings & Customization
ATR Length: Default 14 (used for S-Ratio calculation).

Volume MA Length: Default 20 (used for V-Ratio calculation).

Visual Threshold Lines: Key reference levels (1.5, 1.2, 0.8) plotted on the sub-pane for fast visual scanning.

[i]Disclaimer: This indicator is designed for process design and market analysis confirmation. It does not generate automatic buy/sell financial signals.[/i]

## Source Code

````pine
//@version=6
indicator("Wyckoff Volatility & Volume Ratios [S-Ratio & V-Ratio]", overlay=false)

// Inputs
atrLength   = input.int(14, title="ATR Length", minval=1)
volMaLength = input.int(20, title="Volume MA Length", minval=1)

// Calculations
sRatio = (high - low) / ta.atr(atrLength)
vRatio = volume / ta.sma(volume, volMaLength)

// Plots
plot(sRatio, title="S-Ratio (Range/ATR)", color=color.blue, linewidth=2)
plot(vRatio, title="V-Ratio (Vol/SMA20)", color=color.orange, linewidth=2)

// Threshold Reference Lines
hline(2.0, "Climactic Level (2.0)", color=color.purple, linestyle=hline.style_dashed)
hline(1.5, "High Threshold / Climax (1.5)", color=color.red, linestyle=hline.style_dashed)
hline(1.2, "Wide Spread / High Vol (1.2)", color=color.green, linestyle=hline.style_dotted)
hline(0.8, "Narrow Spread / Low Vol (0.8)", color=color.gray, linestyle=hline.style_dotted)
````
