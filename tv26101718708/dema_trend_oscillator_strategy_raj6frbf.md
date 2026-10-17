# DEMA Trend Oscillator Strategy

- url: https://www.tradingview.com/script/raj6frBf-DEMA-Trend-Oscillator-Strategy/
- type: strategy
- pine_id: PUB;c33e6176b7a04087a5c2d747db6590b3
- version: 1.0

## Description

[b]📌 Overview[/b]
The DEMA Trend Oscillator Strategy is a dynamic trend-following approach based on the Normalized DEMA Oscillator SD.
It adapts in real-time to market volatility with the goal of improving entry accuracy and optimizing risk management.

⚠️ This strategy is provided for educational and research purposes only.
Past performance does not guarantee future results.

[b]🎯 Strategy Objectives[/b]
The main goal of this strategy is to respond quickly to sudden price movements and trend reversals,
by combining momentum-based signals with volatility filters.
It is designed to be user-friendly for traders of all experience levels.

[b]✨ Key Features[/b]
[list] [*]Normalized DEMA Oscillator: A momentum indicator that normalizes DEMA values on a 0–100 scale, allowing intuitive identification of trend strength
[*]Two-Bar Confirmation Filter: Requires two consecutive bullish or bearish candles to reduce noise and enhance entry reliability
[*]ATR x2 Trailing Stop: In addition to fixed stop-loss levels, a trailing stop based on 2× ATR is used to maximize profits during strong trends
[/list]

[b]📊 Trading Rules[/b]
[b]Long Entry:[/b]
[list] [*]Normalized DEMA > 55 (strong upward momentum)
[*]Candle low is above the upper SD band
[*]Two consecutive bullish candles appear
[/list]

[b]Short Entry:[/b]
[list][*]Normalized DEMA < 45 (downward momentum)
[*]Candle high is below the lower SD band
[*]Two consecutive bearish candles appear
[/list]

[b]Exit Conditions:[/b]
[list][*]Take-profit at a risk-reward ratio of 1.5
[*]Stop-loss triggered if price breaks below (long) or above (short) the SD band
[*]Trailing stop activated based on 2× ATR to secure and extend profits
[/list]

[b]💰 Risk Management Parameters[/b]
[list][*]Symbol & Timeframe: Any (AUDUSD 5M example)
[*]Account size (virtual): $3000
[*]Commission: 0.4PIPS(0.0004)
[*]Slippage: 2 pips
[*]Risk per trade: 5%
[*]Number of trades (backtest):534
[/list]
All parameters can be adjusted based on broker specifications and individual trading profiles.

[b]⚙️ Trading Parameters & Considerations[/b]
Indicator: Normalized DEMA Oscillator SD
Parameter settings:
[list] [*]DEMA Period (len_dema): 40
[*]Base Length: 20
[*]Long Threshold: 55
[*]Short Threshold: 45
[*]Risk-Reward Ratio: 1.5
[*]ATR Multiplier for Trailing Stop: 2.0
[/list]

[b]🖼 Visual Support[/b]
The chart displays the following visual elements:
[list] 
[*]Upper and lower SD bands (±2 standard deviations)
[*]Entry signals shown as directional arrows

[/list]

[b]🔧 Strategy Improvements & Uniqueness[/b]
This strategy is inspired by “Normalized DEMA Oscillator SD” by QuantEdgeB,
but introduces enhancements such as a two-bar confirmation filter and an ATR-based trailing stop.
Compared to conventional trend-following strategies, it offers superior noise filtering and profit optimization.

[b]✅ Summary[/b]
The DEMA Trend Oscillator Strategy is a responsive and practical trend-following method
that combines momentum detection with adaptive risk management.
Its visual clarity and logical structure make it a powerful and repeatable tool
for traders seeking consistent performance in trending markets.

⚠️ Always apply appropriate risk management. This strategy is based on historical data and does not guarantee future results.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PakunFX

//@version=6
strategy("DEMA Trend Oscillator Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// === INPUTS ===
src_dema = input.source(close, "Calculation src_dema (Dema)")
len_dema = input.int(40, "Dema Period")
base_len = input.int(20, 'Base length')
Lu       = input.float(55, 'Long Threshold')
Su       = input.float(45, 'Short Threshold')
RR       = input.float(1.5, "Risk Reward Ratio", step=0.1)
trailATRmult = input.float(2.0, "ATR Multiplier for Trailing Stop", step=0.1)

// === FUNCTION ===
F_DEMA(SRC, LEN) =>
    E1 = ta.ema(SRC, LEN)
    E2 = ta.ema(E1, LEN)
    2 * E1 - E2

// === DEMA & NORMALIZATION ===
DEMA     = F_DEMA(src_dema, len_dema)
BASE     = ta.sma(DEMA, base_len)
SD       = ta.stdev(DEMA, base_len) * 2
upperSD  = BASE + SD
lowerSD  = BASE - SD
NormBase = 100 * (DEMA - lowerSD)/(upperSD - lowerSD)

// === ENTRY CONDITIONS ===
long_cond  = NormBase > Lu and low > upperSD
short_cond = NormBase < Su and high < lowerSD

// === DELAYED ENTRY TRIGGERS ===
long_trigger  = long_cond[1]
short_trigger = short_cond[1]

// === ATR-BASED TRAILING STOP ===
atr = ta.atr(14)
trail_offset = atr * trailATRmult
trail_points = trail_offset / syminfo.mintick

// === TRADE DIRECTION CONTROL ===
var string lastDirection = "none"

// === ENTRY LOGIC ===
if long_trigger and lastDirection != "long"
    strategy.entry("Long", strategy.long)
    strategy.exit("TP/SL/Trail Long", from_entry="Long", stop=upperSD, limit=close + (close - upperSD) * RR, trail_points=trail_points, trail_offset=trail_points)
    lastDirection := "long"

if short_trigger and lastDirection != "short"
    strategy.entry("Short", strategy.short)
    strategy.exit("TP/SL/Trail Short", from_entry="Short", stop=lowerSD, limit=close - (lowerSD - close) * RR, trail_points=trail_points, trail_offset=trail_points)
    lastDirection := "short"
````
