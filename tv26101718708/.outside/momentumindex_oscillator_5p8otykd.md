# MomentumIndex (Oscillator)

- url: https://www.tradingview.com/script/5P8OTYkd/
- type: indicator
- pine_id: PUB;c5b6fde38508497a9c58b2c6991cce30
- version: 1.0

## Description

The "MomentumIndex" is an oscillator designed to measure the market's internal energy (supply-demand imbalance) and visually capture the moment when the consensus among market participants reaches a state of "extreme fear."

By combining it with the "MarketGoingIndex"—which forecasts the broader market phase—it helps identify high-precision entry points. The logic behind the indicator and specific methods for its use are explained below.

**Core Logic of MomentumIndex**
Rather than tracking individual stock prices, this indicator measures the "pace of the overall market," helping you grasp the true market environment while filtering out false signals (whipsaws).

**Base Data: A/D Difference (Advance-Decline Difference)**

It calculates the difference between the number of advancing stocks and declining stocks across the entire NYSE market (USI:ADD). This allows you to detect "illusory bull markets"—where the index is propped up by only a handful of large-cap stocks—and instead capture the actual underlying flow of capital into and out of the market.

**Calculation Method: 3-Week Simple Moving Average (SMA)**

To smooth out daily noise (such as volatility caused by sudden news events), a 3-period moving average based on weekly data is used. This clarifies the direction of the medium-term trend and indicates whether the market is overheating.

**Anti-Repaint Processing**

Strict "look-ahead prevention" (lookahead_off) is applied to ensure that signals are not retroactively rewritten during historical data analysis (backtesting).

**Signal Interpretation and Visual Alerts**

When the indicator crosses one of the two preset threshold lines, the chart background changes color to signal that it is time to prepare for a potential entry.

・**Light Green Illumination (Threshold: -1000 or lower)**

**Meaning:** Indicates that the entire market is under broad selling pressure and has entered a "caution zone" suggesting it is "Oversold."

**Action:** This does not constitute an immediate buy signal. Rather than jumping in right away, treat this as a preparation phase to look for buy signals in stocks identified as potential candidates. Light Pink Indicator (Threshold: -1500 or lower)

Meaning: This indicator is set to signal a state of "extreme pessimism" (selling climax)—a point where market participants are in a panic and panic selling has reached its peak.

Action: This light pink signal is designed to help you identify the "Buying Juncture"—the optimal moment offering the lowest risk and the greatest potential for a subsequent rebound.

Practical Application (In conjunction with the MarketGoingIndex)
While it functions as an oscillator on its own, its true power is realized when used alongside macro indicators.

Waiting for Timing Alignment
Look for a period where the "MarketGoingIndex" (orange line) overlaid on the main chart forms a trough and begins to turn upward (signaling an improvement in the macro environment).

Alert for Finding Entry Points
The moment the market plunges and the MomentumIndex lights up in light pink (-1500 or lower)—while the aforementioned macro turnaround signal is active—marks the time when the system's high-probability entry conditions are met. Once you identify this point where "macro tailwinds" converge with "micro-level oversold conditions," you can look for a buy signal (such as Vstop) and consider entering a long position.

## Source Code

````pine
//@version=6
indicator("MomentumIndex (Oscillator)", overlay=false)

// ==========================================
// 1. 入力設定
// ==========================================
grp_mom = "MomentumIndex (ミクロ過熱感)"
sym_ad = input.symbol("USI:ADD", "A/Dディファレンス", group=grp_mom)
ad_sma = input.int(3, "移動平均期間 (週)", group=grp_mom)

// ==========================================
// 2. データの取得 (リペイント防止)
// ==========================================
ad_val = request.security(sym_ad, "1W", ta.sma(close, ad_sma), lookahead=barmerge.lookahead_off)

// ==========================================
// 3. 背景色の判定
// ==========================================
bg_color = ad_val <= -1500 ? color.new(color.fuchsia, 85) : ad_val <= -1000 ? color.new(color.green, 85) : na
bgcolor(bg_color, title="MomentumIndex 背景色")

// ==========================================
// 4. 描画
// ==========================================
plot(ad_val, "MomentumIndex", color=color.blue, linewidth=2)

// ゼロラインと固定閾値
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_solid)
hline(-1000, "Threshold Green", color=color.green, linestyle=hline.style_dashed)
hline(-1500, "Threshold Pink", color=color.fuchsia, linestyle=hline.style_dashed)
````
