# Fade The Crowd Protocol >_

- url: https://www.tradingview.com/script/AjvYpg19-Fade-The-Crowd-Protocol/
- type: strategy
- pine_id: PUB;15bad14c80124af28f6629c75bfffc5b
- version: 1.0

## Description

A structured contrarian system that deliberately inverts conventional MACD + VWMA momentum signals — entering short when the crowd goes long, and long when the crowd goes short. Filtered by ADX, Choppiness Index, and a configurable cooldown timer, the strategy ensures fades execute only at statistically credible exhaustion points, not into directionless noise. Exits are managed through ATR%-normalized take profit and stop loss levels anchored to fill price, with a hard-cap Plug stop bounding maximum loss on every trade.

═══════════════════════════════════════
THE CONTRARIAN PREMISE
═══════════════════════════════════════

When a conventional momentum setup reaches full confirmation — MACD crossover, positive histogram, price at or above VWMA — the crowd is already positioned. Late-stage consensus entries carry elevated mean-reversion risk. The Fade The Crowd Protocol identifies that exact moment of crowd consensus and enters against it.

This is not arbitrary signal flipping. The inversion is applied to a well-defined, multi-condition setup. ADX and Choppiness filters ensure the fade occurs within a trending, structured market environment. A cooldown timer enforces separation between trades, preventing rapid re-entry after stop-outs.

═══════════════════════════════════════
THE INVERSION LOGIC
═══════════════════════════════════════

Conventional long setup → Fade The Crowd goes SHORT
Condition: MACD crossover + histogram above zero + price touches or exceeds VWMA
Crowd interpretation: Bullish momentum confirmed, late buyers entering
Fade interpretation: Crowd is fully long — exhaustion and reversion risk is elevated

Conventional short setup → Fade The Crowd goes LONG
Condition: MACD crossover + histogram below zero + price touches or falls to VWMA
Crowd interpretation: Bearish momentum confirmed, late sellers entering
Fade interpretation: Crowd is fully short — bounce and reversion risk is elevated

Both directions additionally require: CHOP below threshold, ADX above threshold, cooldown timer cleared, and no existing open position.

═══════════════════════════════════════
KEY FEATURES
═══════════════════════════════════════

Signal Inversion Engine
— MACD crossover (either direction) as the base crowd-consensus event
— Histogram sign identifies which direction the crowd is leaning
— VWMA touch confirms price has aligned with the dominant crowd position
— Entry is taken against all three simultaneously satisfied conditions

Cooldown Timer
— Tracks bar index at every trade exit via last_exit_bar variable
— All new entries blocked for a configurable number of bars post-exit
— Prevents rapid re-entry sequences following volatile stop-out events
— Configurable independently of all other filters

ADX + Choppiness Index Filters
— CHOP below threshold confirms the market exhibits directional structure
— ADX above threshold confirms sufficient trend force at signal bar
— Both filters must pass simultaneously with the inversion signal
— Prevents fading in low-conviction, oscillating environments where mean reversion is unreliable

Two-Step ATR% Exit Architecture
— ATR% captured and stored at trigger bar before entry executes
— TP and SL calculated from strategy.position_avg_price on first position bar
— Exit levels locked — no recalculation on subsequent bars
— TP HIT and SL HIT comments displayed on chart for post-hoc analysis

The Plug — Hard Stop Architecture
— Independent hard percentage stop applied to every trade
— For longs: fill_price × (1 − Plug%). For shorts: fill_price × (1 + Plug%)
— Compared against ATR SL using math.max() / math.min() — tighter stop always applied
— Ensures maximum loss is bounded regardless of ATR expansion at entry

═══════════════════════════════════════
HOW IT WORKS
═══════════════════════════════════════

Step 1 — Crowd Consensus Detection
The strategy evaluates three conditions that define a fully-formed conventional momentum signal: MACD has crossed its signal line (ta.cross), the MACD histogram confirms directional bias (above zero for bullish, below for bearish), and price has touched or breached the VWMA in the same direction (high >= VWMA for bullish, low <= VWMA for bearish). When all three align, the crowd is fully positioned.

Step 2 — Environment Filtering
Choppiness Index below threshold confirms the market is not ranging — a prerequisite for meaningful momentum exhaustion. ADX above threshold confirms trend force exists. Cooldown timer confirms sufficient bar-distance from the prior trade exit. All three environmental conditions must pass simultaneously with the crowd signal.

Step 3 — Contrarian Entry
The strategy enters in the opposite direction to the crowd consensus: short against the bullish setup, long against the bearish setup. ATR% at the trigger bar is captured into stored_atr_pct before the entry order executes.

Step 4 — Exit Level Calculation
On the first bar where position size is non-zero (position just opened), TP and SL prices are calculated using strategy.position_avg_price and the stored ATR%. The Plug stop is calculated independently. math.max() (longs) or math.min() (shorts) selects whichever stop is tighter. All levels are stored in fixed variables and passed to strategy.exit() — no dynamic recalculation occurs mid-trade.

═══════════════════════════════════════
WHY MACD + VWMA AS THE CROWD PROXY
═══════════════════════════════════════

MACD is one of the most widely used momentum indicators in retail trading. VWMA incorporates volume-weighted price — a common institutional reference level. Together, they define a setup that is broadly taught, widely traded, and reliably over-populated at the moment of full confirmation. The Fade The Crowd Protocol uses this familiarity as a structural edge: the more crowded the conventional signal, the more statistical force the fade carries when those positions unwind.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BVL-Crypto

//@version=6
strategy('Fade The Crowd Protocol', overlay = true, pyramiding = 0, initial_capital = 10000, default_qty_type = strategy.percent_of_equity, default_qty_value = 50, calc_on_every_tick = false)

// =========================================================================
// 1. INPUT SETTINGS
// =========================================================================

// Trade Direction
grp_dir = 'Trade Direction'
trade_dir = input.string('Both', title = 'Allowed Directions', options = ['Both', 'Long Only', 'Short Only'], group = grp_dir)

// Entry Filters
grp_filters = 'Entry Filters'
chop_len = input.int(7, title = 'Choppiness Length', group = grp_filters)
chop_thresh = input.float(100.0, title = 'Choppiness Threshold (<)', group = grp_filters)
adx_len = input.int(7, title = 'ADX Length', group = grp_filters)
adx_thresh = input.float(20.0, title = 'ADX Threshold (>)', group = grp_filters)
cooldown_bars = input.int(7, title = 'Cooldown Timer (Bars)', group = grp_filters)

// Indicator Settings
grp_inds = 'Indicator Settings'
vwma_len = input.int(20, title = 'VWMA Length', group = grp_inds)
macd_fast = input.int(8, title = 'MACD Fast', group = grp_inds)
macd_slow = input.int(17, title = 'MACD Slow', group = grp_inds)
macd_sig = input.int(9, title = 'MACD Signal', group = grp_inds)
atr_len = input.int(7, title = 'Fast ATR Length', group = grp_inds)

// Exit Settings
grp_exits = 'Exit Logic'
tp_mult = input.float(3.0, title = 'Take Profit Multiplier (1x ATR %)', group = grp_exits)
sl_mult = input.float(2.0, title = 'Stop Loss Multiplier (2x ATR %)', group = grp_exits)
the_plug = input.float(1.3, title = 'The Plug (Max Hard SL %)', group = grp_exits)

// =========================================================================
// 2. INDICATOR & LOGIC CALCULATIONS
// =========================================================================

// Choppiness Index Calculation
tr_sum = math.sum(ta.tr, chop_len)
high_range = ta.highest(high, chop_len)
low_range = ta.lowest(low, chop_len)
chop_val = 100 * math.log10(tr_sum / (high_range - low_range)) / math.log10(chop_len)

// ADX Calculation
[diplus, diminus, adx_val] = ta.dmi(adx_len, adx_len)

// MACD Calculation
[macd_line, sig_line, hist_line] = ta.macd(close, macd_fast, macd_slow, macd_sig)

// VWMA Calculation
vwma_val = ta.vwma(close, vwma_len)

// Fast ATR to % Calculation
atr_val = ta.atr(atr_len)
atr_pct = atr_val / close * 100

// =========================================================================
// 3. ENTRY CONDITIONS (CONTRARIAN LOGIC)
// =========================================================================

// Directional Booleans
allow_long = trade_dir == 'Both' or trade_dir == 'Long Only'
allow_short = trade_dir == 'Both' or trade_dir == 'Short Only'

// Cooldown Timer tracking
var int last_exit_bar = na
if strategy.position_size == 0 and strategy.position_size[1] != 0
    last_exit_bar := bar_index
    last_exit_bar

cooldown_ok = na(last_exit_bar) or bar_index - last_exit_bar >= cooldown_bars

// Shared Filters
is_macd_cross = ta.cross(macd_line, sig_line)
is_chop_valid = chop_val < chop_thresh
is_adx_valid = adx_val > adx_thresh

// Short-Specific Triggers (From Original Strategy)
is_hist_below = hist_line < 0
is_price_vwma_short = low <= vwma_val // Touches or below VWMA (includes wicks)

// Long-Specific Triggers (From Original Strategy)
is_hist_above = hist_line > 0
is_price_vwma_long = high >= vwma_val // Touches or above VWMA (includes wicks)

// Combined Trigger Signals - INVERTED FOR CONTRARIAN ENTRIES
// Short triggers when the ORIGINAL long conditions are met
trigger_short = allow_short and is_macd_cross and is_hist_above and is_price_vwma_long and is_chop_valid and is_adx_valid and cooldown_ok and strategy.position_size == 0

// Long triggers when the ORIGINAL short conditions are met
trigger_long = allow_long and is_macd_cross and is_hist_below and is_price_vwma_short and is_chop_valid and is_adx_valid and cooldown_ok and strategy.position_size == 0


// =========================================================================
// 4. EXECUTION & EXITS
// =========================================================================

// Variables to lock in TP and SL prices at exact entry
var float sl_price = na
var float tp_price = na
var float stored_atr_pct = na

// Step 1: Execute Entry (Locks in the ATR from the trigger bar)
if trigger_short
    stored_atr_pct := atr_pct
    strategy.entry('Short Entry', strategy.short)

if trigger_long
    stored_atr_pct := atr_pct
    strategy.entry('Long Entry', strategy.long)

// Step 2: Establish Fixed SL & TP based on exact fill price
if strategy.position_size != 0
    if strategy.position_size[1] == 0
        // Lock the exact average fill price
        fill_price = strategy.position_avg_price

        // Calculate dynamic distances
        tp_dist_pct = stored_atr_pct * tp_mult / 100
        sl_dist_pct = stored_atr_pct * sl_mult / 100
        plug_dist_pct = the_plug / 100

        // Set fixed price levels based on trade direction
        if strategy.position_size > 0 // We are Long
            tp_price := fill_price * (1 + tp_dist_pct)

            // Calculate both stops and take the higher one (tighter stop)
            atr_sl_price = fill_price * (1 - sl_dist_pct)
            plug_sl_price = fill_price * (1 - plug_dist_pct)
            sl_price := math.max(atr_sl_price, plug_sl_price)
            sl_price

        else // We are Short
            tp_price := fill_price * (1 - tp_dist_pct)

            // Calculate both stops and take the lower one (tighter stop)
            atr_sl_price = fill_price * (1 + sl_dist_pct)
            plug_sl_price = fill_price * (1 + plug_dist_pct)
            sl_price := math.min(atr_sl_price, plug_sl_price)
            sl_price

    // Differentiate exits on the chart
    if strategy.position_size > 0
        strategy.exit('Exit Order', 'Long Entry', limit = tp_price, stop = sl_price, comment_profit = 'TP HIT', comment_loss = 'SL HIT')
    else if strategy.position_size < 0
        strategy.exit('Exit Order', 'Short Entry', limit = tp_price, stop = sl_price, comment_profit = 'TP HIT', comment_loss = 'SL HIT')

// =========================================================================
// 5. VISUALIZATION
// =========================================================================
plot(vwma_val, color = color.new(color.blue, 0), title = 'VWMA 20')
````
