# Alpha Supertrend Vector >_

- url: https://www.tradingview.com/script/AR2MUnwH-Alpha-Supertrend-Vector/
- type: strategy
- pine_id: PUB;b5c2a9bd5b2947569473fc7172df734e
- version: 2.0

## Description

A triple-validated trend-flip system that enters exclusively at the moment a Supertrend indicator changes direction — the earliest confirmation of a regime change — then requires two independent filters (ADX strength and Choppiness Index) to confirm that the flip is occurring within a genuine trending environment. Exits are managed through ATR%-normalized take profit and stop loss levels, with a secondary hard-cap Plug stop that enforces an absolute maximum loss boundary on every trade regardless of volatility conditions.

═══════════════════════════════════════
KEY FEATURES
═══════════════════════════════════════

Supertrend Flip Signal
— Enters on the exact bar where Supertrend direction changes polarity
— Long trigger: bearish-to-bullish flip (st_dir changes from 1 to -1)
— Short trigger: bullish-to-bearish flip (st_dir changes from -1 to 1)
— Configurable ATR multiplier and fast ATR length
— Supertrend line plotted on chart: green (bullish), red (bearish)

Choppiness Index Regime Filter
— CHOP Index must be below the configured threshold at signal bar
— Measures ATR range relative to total high-low range, log-normalized
— Blocks flip entries during sideways, range-bound market conditions
— Protects against the most common source of false Supertrend flip signals

ADX Directional Strength Filter
— ADX must exceed configurable minimum threshold at signal bar
— Full DMI calculation using DI+ and DI− via ta.dmi()
— Confirms sufficient trend force behind the directional flip
— Guards against low-energy drifts that trigger flips without follow-through

ATR% Normalized Exits
— TP and SL expressed as multiples of ATR% — volatility-proportional by design
— ATR% value locked at signal bar via entry_atr_pct variable
— Exit levels anchored to strategy.position_avg_price for live execution accuracy
— No mid-trade recalculation of the base ATR% — risk profile stays fixed

The Plug — Hard Stop Architecture
— Independent hard percentage stop applied to every trade
— For longs: avg_price × (1 − Plug%). For shorts: avg_price × (1 + Plug%)
— Compared to ATR SL using math.max() / math.min() — tighter stop always wins
— Prevents a single volatility spike from breaching a user-defined loss ceiling

═══════════════════════════════════════
HOW IT WORKS
═══════════════════════════════════════

Step 1 — Supertrend Flip Detection
ta.change(st_dir) evaluates to negative when Supertrend flips from bearish (1) to bullish (-1), and positive when it flips from bullish to bearish. These direction changes represent the earliest available structural confirmation of a trend reversal — before momentum indicators, before moving average crossovers.

Step 2 — Choppiness Gate
The Choppiness Index (CHOP) measures the ratio of summed 1-bar ATR to total high-low range over the lookback window, log-normalized to a 0–100 scale. Values below the threshold indicate the market is trending. Values above indicate choppiness. Flip signals that occur during high-CHOP environments — where Supertrend is most likely to whipsaw — are filtered entirely.

Step 3 — ADX Gate
ADX above the minimum confirms the trend has directional force. Even in trending markets, low ADX can indicate the trend is weak and unlikely to sustain a move through the TP level. Both CHOP and ADX must pass simultaneously with the Supertrend flip for entry to execute.

Step 4 — Entry
Entry is placed on the signal bar. The ATR% value at that exact moment is captured and stored for use in exit calculations throughout the life of the trade.

Step 5 — Exit Calculation
TP and SL are calculated dynamically off strategy.position_avg_price using the stored entry_atr_pct. The Plug stop is calculated independently as a fixed percentage from average price. Whichever stop is closer to entry price is applied via math.max() (longs) or math.min() (shorts). The strategy.exit() call runs on every bar while the position is open, ensuring levels remain accurate if average price shifts due to execution variance.

═══════════════════════════════════════
WHY SUPERTREND FLIPS — NOT SUSTAINED DIRECTION
═══════════════════════════════════════

Most Supertrend-based strategies enter whenever price is on the bullish or bearish side of the indicator. The Alpha Supertrend Vector enters only at the flip — the single bar where direction changes. This produces a lower-frequency, higher-conviction signal profile. The strategy is not trying to stay in a trend; it is trying to capture the initial thrust at the moment of regime change, before the move becomes consensus and crowded.

═══════════════════════════════════════
ATR% vs. ATR — THE DISTINCTION
═══════════════════════════════════════

Raw ATR is price-level dependent — a $5 ATR on a $50 stock is extreme; on a $500 stock, it is mild. By converting to ATR% (ATR / close × 100), exit distances become proportional to the instrument's current price level and volatility regime. A 1.0× ATR% TP means the same thing across different assets, different price levels, and different volatility environments — making the strategy's settings genuinely portable across instruments.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BVL-Crypto

//@version=6
strategy('Alpha Supertrend Vector >_', overlay = true, initial_capital = 1000, default_qty_type = strategy.cash, default_qty_value = 10000, 
commission_type = strategy.commission.percent, commission_value = 0, pyramiding = 0, margin_long = 0, margin_short = 0, slippage = 2)

// =========================================================================
// 1. INPUT SETTINGS & TOGGLES
// =========================================================================
grp_main = 'Trade Direction'
trade_dir = input.string('Both', options = ['Long Only', 'Short Only', 'Both'], title = 'Allowed Directions', group = grp_main)

grp_filters = 'Entry Filters'
chop_thresh = input.float(61.8, title = 'Choppiness Threshold (<)', group = grp_filters)
chop_len = input.int(14, title = 'Choppiness Length', group = grp_filters)

grp_indicators = 'Indicator Settings'
st_mult = input.float(3.0, title = 'Supertrend Multiplier', group = grp_indicators)
atr_len = input.int(7, title = 'Fast ATR Length', group = grp_indicators)
adx_len = input.int(7, title = 'ADX Length', group = grp_indicators)
adx_min = input.float(25.0, title = 'ADX Minimum Threshold', group = grp_indicators)

grp_exit = 'Exit Settings'
tp_mult = input.float(3.0, title = 'Take Profit (x Fast ATR %)', group = grp_exit)
sl_mult = input.float(1.0, title = 'Stop Loss (x Fast ATR %)', group = grp_exit)
plug_pct = input.float(1.0, title = 'The Plug (Hard SL %)', group = grp_exit) // ADDED: The Plug

// =========================================================================
// 2. INDICATOR CALCULATIONS
// =========================================================================
// Choppiness Index (CHOP)
chop = 100 * math.log10(math.sum(ta.atr(1), chop_len) / (ta.highest(high, chop_len) - ta.lowest(low, chop_len))) / math.log10(chop_len)

// Supertrend
[st_value, st_dir] = ta.supertrend(st_mult, atr_len)
st_flip_long = ta.change(st_dir) < 0 // Direction changed from 1 (bearish) to -1 (bullish)
st_flip_short = ta.change(st_dir) > 0 // Direction changed from -1 (bullish) to 1 (bearish)

// ADX
[di_plus, di_minus, adx] = ta.dmi(adx_len, adx_len)

// Fast ATR & Percentage Conversion
fast_atr = ta.atr(atr_len)
fast_atr_pct = fast_atr / close * 100

// =========================================================================
// 3. LOGIC & TRIGGER CONDITIONS
// =========================================================================
// Filter checks
allow_long = trade_dir == 'Both' or trade_dir == 'Long Only'
allow_short = trade_dir == 'Both' or trade_dir == 'Short Only'

// Master Entry Triggers
trigger_long = st_flip_long and adx > adx_min and chop < chop_thresh
trigger_short = st_flip_short and adx > adx_min and chop < chop_thresh

// =========================================================================
// 4. EXECUTION & EXITS
// =========================================================================
// Variable to store the exact ATR % at the moment of the signal
var float entry_atr_pct = na

// Entry Execution
if trigger_long and allow_long
    strategy.entry('Long', strategy.long, comment = 'Long')
    entry_atr_pct := fast_atr_pct
    entry_atr_pct

if trigger_short and allow_short
    strategy.entry('Short', strategy.short, comment = 'Short')
    entry_atr_pct := fast_atr_pct
    entry_atr_pct

// Exit Execution (Calculated dynamically off position average price)
if strategy.position_size > 0
    long_tp_price = strategy.position_avg_price * (1 + entry_atr_pct * tp_mult / 100)
    atr_sl_price = strategy.position_avg_price * (1 - entry_atr_pct * sl_mult / 100)
    plug_sl_price = strategy.position_avg_price * (1 - plug_pct / 100)

    // Use whichever stop is closer to the entry price (the higher price for a long stop)
    long_sl_price = math.max(atr_sl_price, plug_sl_price)

    strategy.exit('Close Long', 'Long', limit = long_tp_price, stop = long_sl_price, comment = 'Exit')

if strategy.position_size < 0
    short_tp_price = strategy.position_avg_price * (1 - entry_atr_pct * tp_mult / 100)
    atr_sl_price = strategy.position_avg_price * (1 + entry_atr_pct * sl_mult / 100)
    plug_sl_price = strategy.position_avg_price * (1 + plug_pct / 100)

    // Use whichever stop is closer to the entry price (the lower price for a short stop)
    short_sl_price = math.min(atr_sl_price, plug_sl_price)

    strategy.exit('Close Short', 'Short', limit = short_tp_price, stop = short_sl_price, comment = 'Exit')

// =========================================================================
// 5. CHART VISUALS (Optional clarity)
// =========================================================================
plot(st_value, color = st_dir == 1 ? color.red : color.green, title = 'Supertrend', linewidth = 2)
````
