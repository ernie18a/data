# PRO Investing - Nasdaq Silver Bullet (%) Strategy (1hr)

- url: https://www.tradingview.com/script/gRKaz4L6-PRO-Investing-Nasdaq-Silver-Bullet-Strategy-1hr/
- type: strategy
- pine_id: PUB;926710622da5455b82834abab73ecc7a
- version: 1.0

## Description

[b]Nasdaq Silver Bullet H1 Macro-Trend Strategy[/b]
[b]Overview[/b]
The Nasdaq Silver Bullet H1 Strategy is a high-timeframe adaptation of the classic "Silver Bullet" concept. While most institutional time-window strategies are used for scalping, applying this logic to the 1-Hour (H1) chart transforms it into a Session Momentum Strategy.
Instead of chasing small price fluctuations, this script identifies the "Power Hour" (10:00 AM EST) candle as the directional anchor for the rest of the New York session. It filters out market noise by requiring the higher-timeframe trend to align with the mid-morning institutional expansion.
Key Features (H1 Optimization)
[b]1. The "Power Hour" Anchor (10:00 AM EST)[/b]
On the 1-Hour chart, the 10:00 AM candle represents the most critical hour of Nasdaq trading—the crossover between the London Close and the New York Morning. This script uses that specific H1 candle to determine if the "Smart Money" is positioning for a trend continuation or a reversal.
[b]2. Multi-Hour Momentum Confirmation (Candle Counting)[/b]
On the H1 timeframe, the Candle Count logic becomes a powerful trend-validation tool.
If set to 2, the strategy waits for the 10:00 AM and 11:00 AM candles to both close in the same direction.
This ensures you aren't entering on a "fake" spike, but rather on a sustained multi-hour move that has a high probability of carrying through to the New York afternoon.
[b]3. Macro-Trend Filter (200 EMA)[/b]
Using the 200 EMA on the 1-Hour chart provides a "Bird's Eye View" of the market. This filter ensures that the strategy only takes long trades during established bull markets and short trades during bear markets, preventing "counter-trend" traps that often occur during volatile session opens.
[b]4. Volatility-Agnostic Risk Management (%)[/b]
Because Nasdaq’s 1-Hour candles can range from 50 to 300 points depending on the day's volatility, fixed point targets are ineffective. This script uses Percentage-Based Stop Losses and Take Profits.
On the H1 chart, this allows the strategy to capture large "trend days" while maintaining a mathematically consistent risk-to-reward ratio regardless of the Nasdaq’s current price level.
[b]Strategy Logic for H1 Usage[/b]
Observation: The script identifies the 10:00 AM H1 candle (highlighted by the blue window).
Confirmation: It checks if the current 1-Hour trend matches the 200 EMA baseline.
The Trigger: Once the required number of H1 candles (e.g., 2) have closed in a consistent direction starting from the Silver Bullet window, a trade is executed.
The Exit: The trade is managed by percentage targets or is automatically flattened at the end of the window to avoid "Overnight Risk" or "After-Hours" chop.
[b]Best Use Case[/b]
Asset: NQ1! (Futures), MNQ1! (Micro Futures), or US100.
Timeframe: 1-Hour (H1).
Market Context: Best suited for traders who want to capture the NY Session Continuation move. This strategy is excellent for avoiding "choppy" mornings and only entering once the true daily trend has been established by the 12:00 PM (EST) mark.
[b]Summary for Traders[/b]
By moving the Silver Bullet to the 1H chart, you are trading the institutional flow of the day rather than the volatility of the minute. This leads to fewer trades, higher quality setups, and a significant reduction in "stop-hunts" that often plague lower-timeframe traders.

## Source Code

````pine
// © PRO Investing
//@version=5
strategy("PRO Investing - Nasdaq Silver Bullet (%) Strategy (1hr)", overlay=true, initial_capital=100000, currency=currency.USD)

// --- INPUTS ---
sb_time = input.session("1000-1100", "Silver Bullet Window (EST/New York)", tooltip="The 10:00-11:00 AM window often sees high institutional delivery.")
count_needed = input.int(2, "Candle Count Confirmation", minval=1, tooltip="Number of candles in direction before entry.")
use_ema = input.bool(true, "Use 200 EMA Filter?", tooltip="Only longs above EMA, only shorts below.")

// --- RISK MANAGEMENT INPUTS (%) ---
sl_percent = input.float(0.3, "Stop Loss (%)", minval=0.01, step=0.1, tooltip="Stop loss as a percentage of entry price (e.g., 0.3%)")
tp_percent = input.float(0.6, "Take Profit (%)", minval=0.01, step=0.1, tooltip="Take profit as a percentage of entry price (e.g., 0.6% for a 1:2 RR)")

// --- TIME LOGIC ---
// Nasdaq is best traded on NYC time
is_sb_window = not na(time(timeframe.period, sb_time, "America/New_York"))

// --- INDICATORS ---
ema200 = ta.ema(close, 200)
plot(use_ema ? ema200 : na, color=color.new(color.yellow, 0), title="Trend Filter (200 EMA)")

// --- CANDLE COUNTING ---
var int up_count = 0
var int dn_count = 0

if close > open
    up_count += 1
    dn_count := 0
else if close < open
    dn_count += 1
    up_count := 0
else
    up_count := 0
    dn_count := 0

// --- SITUATIONAL ENTRY LOGIC ---
long_cond = is_sb_window and up_count >= count_needed and (not use_ema or close > ema200)
short_cond = is_sb_window and dn_count >= count_needed and (not use_ema or close < ema200)

// --- EXECUTION & % CALCULATION ---
if long_cond and strategy.position_size == 0
    strategy.entry("SB-Long", strategy.long, comment="SB Long")

if short_cond and strategy.position_size == 0
    strategy.entry("SB-Short", strategy.short, comment="SB Short")

// Define Exit Prices based on Entry Price
if strategy.position_size > 0 // We are Long
    float long_sl = strategy.position_avg_price * (1 - sl_percent / 100)
    float long_tp = strategy.position_avg_price * (1 + tp_percent / 100)
    strategy.exit("Exit Long", "SB-Long", stop=long_sl, limit=long_tp, comment_loss="SL %", comment_profit="TP %")

if strategy.position_size < 0 // We are Short
    float short_sl = strategy.position_avg_price * (1 + sl_percent / 100)
    float short_tp = strategy.position_avg_price * (1 - tp_percent / 100)
    strategy.exit("Exit Short", "SB-Short", stop=short_sl, limit=short_tp, comment_loss="SL %", comment_profit="TP %")

// Time-based exit: If trade is still open at 11:00 AM, close it
if not is_sb_window and strategy.position_size != 0
    strategy.close_all(comment="End of Window")

// --- VISUALS ---
bgcolor(is_sb_window ? color.new(color.blue, 92) : na)
plotshape(long_cond, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(short_cond, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// ==========================================
// EDUCATIONAL NOTES & RESEARCH DIRECTIONS
// ==========================================
//
//    STRATEGY THEORY:
//    This script is based on the "ICT Silver Bullet" concept. The 10:00 AM - 11:00 AM EST 
//    window is known as a high-probability "Algorithm Delivery" hour. During this time, 
//    the market often seeks internal range liquidity or high/low of the session.

//    KEY RESEARCH QUESTIONS FOR TRADERS:
//    1. SENSITIVITY: How does changing 'Candle Count Confirmation' from 2 to 3 affect 
//       the Win Rate vs. total number of trades? (Higher count = Lower frequency but 
//       potentially higher quality).
//       
//    2. TIME SENSITIVITY: Try changing 'sb_time' to "0300-0400" (London Silver Bullet). 
//       Does the Nasdaq react differently to the London Open than the NY Open?
//       
//    3. TREND FILTERING: Compare results with 'use_ema' turned ON vs OFF. Does the 
//       Silver Bullet work better as a trend-continuation tool or a mean-reversion tool?
//
//    ADVANCED MODIFICATIONS FOR FURTHER STUDY:
//    - VOLUMETRIC FILTER: Add a condition where 'volume > ta.sma(volume, 20)' to 
//      ensure the candle count is backed by high participation.
//    - ATR SCALING: Instead of a fixed 0.3% Stop Loss, research using 'ta.atr(14) * 2' 
//      to make the stop loss dynamic based on daily volatility.
//    - CONFLUENCE: Research "Fair Value Gaps" (FVG) that form within the 10:00 AM 
//      window. Entering when a 2-candle count happens inside an FVG is a common 
//      advanced institutional tactic.
//
//    DISCLAIMER:
//    This script is for educational purposes only. Past performance does not 
//    guarantee future results. Always backtest and trade on a demo account 
//    before risking live capital.

// © PRO Investing
````
