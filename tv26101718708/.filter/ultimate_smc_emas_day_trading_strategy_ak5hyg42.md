# Ultimate SMC + EMAs Day Trading Strategy

- url: https://www.tradingview.com/script/Ak5HYG42-Ultimate-SMC-EMAs-Day-Trading-Strategy/
- type: strategy
- pine_id: PUB;e473ea73ceaf48be84294fe72adc3a7a
- version: 1.0

## Description

Strategy Overview & Core Mechanics
The strategy relies on a multi-timeframe approach, filtering out market noise by aligning executive intraday triggers with macroeconomic higher-timeframe boundaries.

1. Trend Direction & Momentum Filters
The script establishes a structural bias using a hybrid moving average cloud.

SMA 200 (200-period Simple Moving Average): Acts as the macro trend filter. Long positions are only considered when price acts above the SMA 200, and shorts are only executed below it.

EMA 9 & EMA 21 (Exponential Moving Averages): Serve as dynamic momentum and immediate entry triggers. A crossover/crossunder sequence provides the baseline micro-trend confirmation.

2. Higher Timeframe (4H) Key Liquidity Pools
Instead of looking at localized intraday highs and lows, the strategy automatically streams data from the 4-Hour Timeframe to mark out:

Strong Highs: Points of institutional supply where major bearish structural shifts occurred. These act as ultimate profit-taking targets for longs or stop-loss points for shorts.

Weak Lows: Structural liquidity pools targeted by algorithms. These serve as dynamic stop-losses for longs or profit targets for shorts.

3. Market Structure Fractals & Automated Trendlines
Using algorithmic fractal pivot points, the script charts sharp, non-repainting trendlines. These act as visual cues for narrowing market ranges (wedges and flags), helping you visualize where retail liquidity is building up before a breakout or sweep.

4. Order Blocks & Dynamic Fibonacci Retracements
The script isolates true institutional Order Blocks (OB) by locating the final counter-trend candle before an aggressive structural expansion. Once a valid high/low fractal range settles, an automated Fibonacci Retracement engine projects across your screen to find:

The 0.5 Equilibrium: The strict boundary separating premium pricing from discount pricing.

The 0.618 Golden Pocket: The prime value zone where institutional orders are typically stacked.

5. Fair Value Gaps (FVG) & Inverted FVGs (IFVG)
To confirm genuine institutional presence, the script continuously maps 3-candle price inefficiencies (Fair Value Gaps).

FVG: Imbalances where price moved so violently that orders were left unfilled, acting as a magnet for price to retrace into.

IFVG (Inverted FVG): If price aggressively breaches completely through a past bullish FVG, the script automatically transforms its color state to an Inverted FVG, signaling that old support has flipped into powerful institutional resistance.

The Execution Blueprint (How It Trades)
Long Setup (Buy)
Trend Filter: Price must be hovering above the SMA 200, and the EMA 9 must be above the EMA 21.

Value Sourcing: Price must retrace down into "discount" territory—either sinking below the 0.618 Fibonacci level or tapping the top boundary of a demand Order Block.

Trigger: An entry executes when a Bullish FVG forms within that discount array or when the price closes back over the EMA 9.

Trade Management: The stop loss is immediately locked onto the static 4H Weak Low, while the take profit is set to capture the 4H Strong High.

Short Setup (Sell)
Trend Filter: Price must be trading below the SMA 200, and the EMA 9 must be below the EMA 21.

Value Sourcing: Price must rally upward into "premium" territory—breaking above the 0.618 Fibonacci level or testing a supply Order Block.

Trigger: An entry executes when a Bearish FVG prints in that premium zone or when the price crosses back under the EMA 9.

Trade Management: The stop loss is instantly mapped to the static 4H Strong High, while the take profit targets the 4H Weak Low.

## Source Code

````pine
// © AI Collaborator
//@version=5
strategy("Ultimate SMC + EMAs Day Trading Strategy", overlay=true, max_bars_back=5000, max_lines_count=500, max_boxes_count=500)

// ==========================================
// INPUTS
// ==========================================
var string grp_ema  = "Moving Averages"
use_emas   = input.bool(true, "Enable EMAs/SMA", group=grp_ema)
ema9_len   = input.int(9, "EMA 9 Length", group=grp_ema)
ema21_len  = input.int(21, "EMA 21 Length", group=grp_ema)
sma200_len = input.int(200, "SMA 200 Length", group=grp_ema)

var string grp_htf  = "4-Hour Market Structure (HTF)"
show_htf   = input.bool(true, "Show 4H Strong High / Weak Low", group=grp_htf)

var string grp_tl   = "Trendlines & Fractals"
tl_length  = input.int(10, "Trendline Pivot Length", minval=2, group=grp_tl)

var string grp_fvg  = "FVG / IFVG Settings"
show_fvg   = input.bool(true, "Plot Fair Value Gaps", group=grp_fvg)
fvg_color  = input.color(#2196F3, "Bullish FVG Color", group=grp_fvg)
ifvg_color = input.color(#FF9800, "Inverted FVG Color", group=grp_fvg)

var string grp_ob   = "Order Blocks & Fibs"
ob_length  = input.int(5, "Order Block Pivot Length", group=grp_ob)

// ==========================================
// 1. MOVING AVERAGES
// ==========================================
ema9   = ta.ema(close, ema9_len)
ema21  = ta.ema(close, ema21_len)
sma200 = ta.sma(close, sma200_len)

// Fixed: Changed 'width' to 'linewidth' for the plot functions
plot(use_emas ? ema9 : na, title="EMA 9", color=#00FFFF, linewidth=1)
plot(use_emas ? ema21 : na, title="EMA 21", color=#FF00FF, linewidth=1)
plot(use_emas ? sma200 : na, title="SMA 200", color=#FFFFFF, linewidth=2)

// ==========================================
// 2. 4-HOUR STRONG HIGH / WEAK LOW (HTF)
// ==========================================
htf_high = request.security(syminfo.tickerid, "240", high, barmerge.gaps_off, barmerge.lookahead_off)
htf_low  = request.security(syminfo.tickerid, "240", low, barmerge.gaps_off, barmerge.lookahead_off)

var line htf_high_line = na
var line htf_low_line  = na

if show_htf and ta.change(htf_high)
    line.delete(htf_high_line)
    htf_high_line := line.new(bar_index - 1, htf_high, bar_index, htf_high, extend=extend.right, color=#FF0000, width=2, style=line.style_dashed)
    label.new(bar_index, htf_high, "4H Strong High", color=#FF0000, textcolor=#FFFFFF, style=label.style_label_down, size=size.small)

if show_htf and ta.change(htf_low)
    line.delete(htf_low_line)
    htf_low_line := line.new(bar_index - 1, htf_low, bar_index, htf_low, extend=extend.right, color=#00FF00, width=2, style=line.style_dashed)
    label.new(bar_index, htf_low, "4H Weak Low", color=#00FF00, textcolor=#FFFFFF, style=label.style_label_up, size=size.small)

// ==========================================
// 3. TRENDLINES & FRACTALS
// ==========================================
up_piv = ta.pivothigh(high, tl_length, tl_length)
dn_piv = ta.pivotlow(low, tl_length, tl_length)

a1_idx = ta.valuewhen(not na(up_piv), bar_index, 1)
a1_val = ta.valuewhen(not na(up_piv), high[tl_length], 1)
b1_idx = ta.valuewhen(not na(dn_piv), bar_index, 1)
b1_val = ta.valuewhen(not na(dn_piv), low[tl_length], 1)

var line upper_line = na
var line lower_line = na

if not na(up_piv)
    line.delete(upper_line)
    upper_line := line.new(a1_idx - tl_length, a1_val, bar_index - tl_length, up_piv, extend=extend.right, color=#FF0000, width=1)

if not na(dn_piv)
    line.delete(lower_line)
    lower_line := line.new(b1_idx - tl_length, b1_val, bar_index - tl_length, dn_piv, extend=extend.right, color=#00FF00, width=1)

// ==========================================
// 4. FAIR VALUE GAPS (FVG) & INVERTED FVG (IFVG)
// ==========================================
var box[] bull_fvgs = array.new<box>()
var box[] bear_fvgs = array.new<box>()

bull_fvg_detected = low[0] > high[2] and close[1] > high[2]
if bull_fvg_detected and show_fvg
    array.push(bull_fvgs, box.new(left=bar_index[2], top=low[0], right=bar_index, bottom=high[2], bgcolor=fvg_color, border_color=#2196F3))

bear_fvg_detected = high[0] < low[2] and close[1] < low[2]
if bear_fvg_detected and show_fvg
    array.push(bear_fvgs, box.new(left=bar_index[2], top=low[2], right=bar_index, bottom=high[0], bgcolor=ifvg_color, border_color=#FF0000))

if array.size(bull_fvgs) > 0
    for i = array.size(bull_fvgs) - 1 to 0
        b = array.get(bull_fvgs, i)
        bottom = box.get_bottom(b)
        if close < bottom 
            box.set_bgcolor(b, ifvg_color)
            box.set_border_color(b, #FF9800)

// ==========================================
// 5. ORDER BLOCKS (OB) & FIB RETRACEMENT
// ==========================================
ob_top = ta.valuewhen(not na(up_piv), high[ob_length], 0)
ob_bot = ta.valuewhen(not na(dn_piv), low[ob_length], 0)

var float fib_0 = na
var float fib_05 = na
var float fib_0618 = na
var float fib_1 = na

if not na(up_piv) or not na(dn_piv)
    fib_1    := ob_top
    fib_0    := ob_bot
    fib_05   := fib_0 + (fib_1 - fib_0) * 0.5
    fib_0618 := fib_0 + (fib_1 - fib_0) * 0.618

plot(fib_05, title="Fib 0.5 (Equilibrium)", color=#808080, style=plot.style_line)
plot(fib_0618, title="Fib 0.618 (Golden Pocket)", color=#FFFF00, style=plot.style_line)

// ==========================================
// 6. BACKTESTING / DAY TRADING STRATEGY LOGIC
// ==========================================
bullish_trend = close > sma200 and ema9 > ema21
bearish_trend = close < sma200 and ema9 < ema21

long_condition  = bullish_trend and (close <= fib_0618 or low <= ob_bot) and (bull_fvg_detected or ta.crossover(close, ema9))
short_condition = bearish_trend and (close >= fib_0618 or high >= ob_top) and (bear_fvg_detected or ta.crossunder(close, ema9))

var float trade_sl = na
var float trade_tp = na

if long_condition and strategy.position_size == 0
    trade_sl := htf_low
    trade_tp := htf_high
    strategy.entry("Long", strategy.long)

if short_condition and strategy.position_size == 0
    trade_sl := htf_high
    trade_tp := htf_low
    strategy.entry("Short", strategy.short)

if strategy.position_size > 0
    strategy.exit("Exit Long", "Long", stop=trade_sl, limit=trade_tp)

if strategy.position_size < 0
    strategy.exit("Exit Short", "Short", stop=trade_sl, limit=trade_tp)
````
