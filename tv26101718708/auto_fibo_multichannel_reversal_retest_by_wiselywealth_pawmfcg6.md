# Auto Fibo Multi-Channel Reversal Retest by WiselyWealth

- url: https://www.tradingview.com/script/PaWMFCg6-Auto-Fibo-Multi-Channel-Reversal-Retest-by-WiselyWealth/
- type: indicator
- pine_id: PUB;07ea6bd283a44331ad2ab4dc062ad407
- version: 1.0

## Description

Comprehensive Guide: Auto Fibo Multi-Channel Reversal Retest Indicator

Introduction: What is this script and its purpose?

The "Auto Fibo Multi-Channel Reversal Retest" script, developed by WiselyWealth, is a highly advanced, multi-layered technical analysis tool built using Pine Script v6. Its primary purpose is to identify high-probability market reversal zones by aggressively filtering out market noise and false breakouts.

Unlike traditional indicators that rely on a single mathematical concept, this system is engineered to demand confluence from four distinct technical dimensions before confirming a trade setup: volatility boundaries, momentum exhaustion, dynamic structural support/resistance, and an execution retest protocol. This script is specifically designed for analytical traders who prioritize setup quality over sheer quantity, aiming to catch precise pivot points in the market while optimizing the risk-to-reward ratio through delayed, confirmed entries.

Working Mechanism: How the Script Detects Signals

The core strength of this script lies in its rigorous, four-step filtering engine. A final "Buy" or "Sell" signal is only painted on the chart when price action satisfies all of the following technical criteria consecutively:

1. Multi-Channel Volatility Extremes (The Boundary Check):
The script features a dual-channel trigger system, allowing users to select a primary and secondary volatility band or price channel. The available options include Bollinger Bands, Keltner Channels, Donchian Channels, Envelopes, and Linear Regression. The algorithm calculates the mathematical upper and lower bounds of these selected systems. For a setup to even begin formulating, the asset's price must simultaneously pierce or touch the extreme outer boundaries of *both* selected channels (for example, the low of the candle must be equal to or lower than both the primary lower band and the secondary lower band). This ensures the market is severely overextended and deviating heavily from its historical mean.

2. Reversal Signatures and Momentum Exhaustion (The Trigger):
Once price reaches the extreme boundaries, the script scans for a reversal catalyst. It detects foundational candlestick patterns, specifically Bullish and Bearish Engulfing candles, as well as Pinbars like Hammers and Shooting Stars. Furthermore, it incorporates momentum oscillators by scanning for Relative Strength Index (RSI) crossovers from overbought or oversold territories, alongside Stochastic oscillator crosses (below 20 for buys, above 80 for sells). This ensures the structural overextension is accompanied by a genuine, measurable shift in buying or selling pressure.

3. Dynamic Auto-Fibonacci Proximity (The Structural Filter):
To prevent taking reversals in the middle of a chart with no structural backing, the script automatically calculates a macro range by identifying the highest high and lowest low over a user-defined lookback period (defaulting to 100 bars). It dynamically plots key Fibonacci retracement levels (0.000, 0.236, 0.382, 0.500, 0.618, 0.786, and 1.000). A raw reversal signal is only validated if the price action occurs within a strict, customizable percentage tolerance (defaulting to 0.5% of the range) of these specific Fibonacci levels. This mathematical check guarantees that trades are only considered at major, historically proven support or resistance zones.

4. The ATR-Based Retest Engine (The Execution Delay):
This is the script's most robust feature. Even if all prior conditions are perfectly met, the script does not immediately issue a final order. Instead, it enters a "pending trend" state and calculates a required "Retest Price" using the Average True Range (ATR).

For a Buy setup, it subtracts a user-defined ATR multiplier (default 1.0) from the close price.

The system then waits for up to a maximum number of candles (default 4 bars) for the price to pull back and touch this specific delayed level.

If the price successfully drops to the retest level within the time limit, the final Buy order is fired and painted on the chart. This engine prevents traders from buying the absolute top of a fake-out and secures a significantly safer entry price.

How to Use: Settings and Optimal Market Conditions
Recommended Configuration & Settings:

Channel Confluence: Pairing Bollinger Bands as System 1 and Keltner Channels as System 2 is highly recommended. Because Bollinger Bands measure standard deviation and Keltner Channels measure ATR, requiring price to break both ensures you are capturing true volatility anomalies (often referred to as a "Volatility Squeeze" reversal).

Retest Engine Tuning: The default ATR multiplier of 1.0 with a 4-bar max wait limit provides a balanced, conservative approach. If you find that valid signals are expiring before execution because the market runs away too quickly, you should either increase the "Max Candles to wait" to 6-8 bars or lower the "Retest Value" to 0.5 for shallower pullbacks.

Fibonacci Tolerance: Keep the "Fibo Level Tolerance" relatively tight (between 0.3% and 0.8%). Expanding it too much defeats the purpose of precision support and resistance filtering.

Suitable Markets and Timeframes:
This indicator thrives in mean-reverting and broadly ranging market conditions, making it exceptionally well-suited for high-liquidity Forex pairs (such as EUR/USD or GBP/JPY), major Cryptocurrencies, and Equity Indices.

Optimal Timeframes: It performs best on medium to higher timeframes, such as the 15-minute, 1-hour, or 4-hour charts. Lower timeframes (like 1-minute or 3-minute charts) contain too much micro-volatility, which may cause erratic Fibonacci plotting and premature retest triggers.

Trend Context: By default, the script takes both Buy and Sell signals ("Trade Direction: Both"). However, in a strong macro-trending market, users should actively utilize the Trade Direction setting to take only pullbacks in the direction of the dominant trend. For example, selecting "Buy Only" during a structural bull market will filter out dangerous counter-trend short positions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TaninWiselyWealth

//@version=6
indicator("Auto Fibo Multi-Channel Reversal Retest by WiselyWealth", overlay=true, max_lines_count=100, max_labels_count=500)

// ==============================================================================
// ⚙️ SECTION 1: SYSTEM & DIRECTION / RETEST SETTINGS
// ==============================================================================
grp_gen = "1. General & Retest Settings"
trade_direction = input.string("Both", title="Trade Direction", options=["Both", "Buy Only", "Sell Only"], group=grp_gen, tooltip="Select allowed trade direction: Both, Buy Only, or Sell Only.")
use_retest      = input.bool(true, 'Enable Retest Mode', group=grp_gen, tooltip='Delay entry signals until price retests the calculated ATR distance level.')
retest_mult     = input.float(1.0, 'Retest Value (ATR Multiplier)', group=grp_gen, tooltip='Required pullback distance in ATR units for retest confirmation.')
max_wait_bars   = input.int(4, 'Max Candles to wait for Retest', minval=1, group=grp_gen, tooltip='Maximum number of candles to wait for retest price before executing or canceling.')
sim_atr_len     = input.int(14, 'ATR Length for Retest', minval=1, group=grp_gen, tooltip='Lookback period for ATR calculation used in retest price calculation.')
show_range_bg   = input.bool(true, 'Highlight Range Market Background', group=grp_gen, tooltip='Show background highlight when market is classified as Range/Sideways.')

// ==============================================================================
// 📊 SECTION 2: BANDS & CHANNELS SETTINGS
// ==============================================================================
grp_strat = '2. Bands & Channels Trigger Settings'
bc_sys1 = input.string('Bollinger Bands', title = 'Trigger System 1', options = ['Bollinger Bands', 'Keltner Channels', 'Donchian Channels', 'Envelopes', 'Linear Regression'], group = grp_strat, tooltip = 'Select the primary band or channel system for entry trigger confluence.')
bc_sys2 = input.string('Keltner Channels', title = 'Trigger System 2', options = ['Bollinger Bands', 'Keltner Channels', 'Donchian Channels', 'Envelopes', 'Linear Regression'], group = grp_strat, tooltip = 'Select the secondary band or channel system for entry trigger confluence.')

grp_toggles = '3. Bands & Channels Visibility'
bc_showBB = input.bool(true, title = 'Show Bollinger Bands (Blue)', group = grp_toggles, tooltip = 'Toggle visibility of Bollinger Bands on the chart.')
bc_showKC = input.bool(true, title = 'Show Keltner Channels (Orange)', group = grp_toggles, tooltip = 'Toggle visibility of Keltner Channels on the chart.')
bc_showDC = input.bool(false, title = 'Show Donchian Channels (Purple)', group = grp_toggles, tooltip = 'Toggle visibility of Donchian Channels on the chart.')
bc_showENV = input.bool(false, title = 'Show Envelopes (Green)', group = grp_toggles, tooltip = 'Toggle visibility of Envelopes on the chart.')
bc_showLR = input.bool(false, title = 'Show Linear Regression (Red)', group = grp_toggles, tooltip = 'Toggle visibility of Linear Regression Channel on the chart.')

grp_bb = '4. Bollinger Bands Parameters'
bc_lengthBB = input.int(20, title = 'BB Length', group = grp_bb, tooltip = 'Lookback period for calculating Bollinger Bands SMA basis.')
bc_multBB = input.float(2.0, title = 'BB StdDev', group = grp_bb, tooltip = 'Standard deviation multiplier for upper and lower Bollinger Bands.')

grp_kc = '5. Keltner Channels Parameters'
bc_lengthKC = input.int(20, title = 'KC Length', group = grp_kc, tooltip = 'Lookback period for Keltner Channels EMA basis and ATR calculation.')
bc_multKC = input.float(1.5, title = 'KC ATR Multiplier', group = grp_kc, tooltip = 'ATR multiplier for upper and lower Keltner Channels boundaries.')

grp_dc = '6. Donchian Channels Parameters'
bc_lengthDC = input.int(20, title = 'DC Length', group = grp_dc, tooltip = 'Lookback period for Donchian Channels highest high and lowest low.')

grp_env = '7. Envelopes Parameters'
bc_lengthENV = input.int(20, title = 'ENV Length', group = grp_env, tooltip = 'Lookback period for Envelopes moving average basis.')
bc_percentENV = input.float(5.0, title = 'ENV Percent (%)', group = grp_env, tooltip = 'Percentage deviation from moving average for Envelope bands.')

grp_lr = '8. Linear Regression Parameters'
bc_lengthLR = input.int(100, title = 'LinReg Length', group = grp_lr, tooltip = 'Lookback period for Linear Regression channel calculation.')
bc_multLR = input.float(2.0, title = 'LinReg StdDev', group = grp_lr, tooltip = 'Standard deviation multiplier for Linear Regression outer bands.')

// ==============================================================================
// 🔄 SECTION 3: REVERSAL & FIBONACCI SETTINGS
// ==============================================================================
grp_rev = "9. Reversal Signal Settings"
rev_showEngulfing = input.bool(true, title="Show Engulfing Pattern", group=grp_rev, tooltip="Enable Bullish and Bearish Engulfing candlestick patterns for reversal signals.")
rev_showPinbar    = input.bool(true, title="Show Pinbar (Hammer/Shooting Star)", group=grp_rev, tooltip="Enable Hammer and Shooting Star Pinbar candlestick patterns for reversal signals.")
rev_showRSI       = input.bool(true, title="Show RSI Reversal", group=grp_rev, tooltip="Enable Relative Strength Index (RSI) overbought/oversold reversal signals.")
rev_rsiPeriod     = input.int(14, title="RSI Period", group=grp_rev, tooltip="Calculation period for Relative Strength Index (RSI).")
rev_rsiOB         = input.int(70, title="RSI Overbought", group=grp_rev, tooltip="RSI level above which the market is considered overbought.")
rev_rsiOS         = input.int(30, title="RSI Oversold", group=grp_rev, tooltip="RSI level below which the market is considered oversold.")
rev_showStoch     = input.bool(true, title="Show Stochastic Reversal", group=grp_rev, tooltip="Enable Stochastic Oscillator crossover reversal signals.")
rev_showBB        = input.bool(true, title="Show Bollinger Bands Reversal", group=grp_rev, tooltip="Enable Bollinger Bands breakout and reversal signals.")

grp_fib = "10. Fibonacci Level Settings"
rev_lookback = input.int(100, title="Lookback Period (High/Low)", minval=10, group=grp_fib, tooltip="Number of bars back to search for highest high and lowest low for Fibonacci levels.")
rev_tolerancePct = input.float(0.5, title="Fibo Level Tolerance (% of Range)", minval=0.0, maxval=50.0, step=0.5, group=grp_fib, tooltip="Proximity tolerance percentage around Fibonacci levels to validate signals.") / 100.0
rev_useL000 = input.bool(true, title="Use 0.000 level for Filter", group=grp_fib, tooltip="Include the 0.000 Fibonacci level for signal validation.")
rev_useL236 = input.bool(true, title="Use 0.236 level for Filter", group=grp_fib, tooltip="Include the 0.236 Fibonacci level for signal validation.")
rev_useL382 = input.bool(true, title="Use 0.382 level for Filter", group=grp_fib, tooltip="Include the 0.382 Fibonacci level for signal validation.")
rev_useL500 = input.bool(true, title="Use 0.500 level for Filter", group=grp_fib, tooltip="Include the 0.500 Fibonacci level for signal validation.")
rev_useL618 = input.bool(true, title="Use 0.618 level for Filter", group=grp_fib, tooltip="Include the 0.618 Fibonacci level for signal validation.")
rev_useL786 = input.bool(true, title="Use 0.786 level for Filter", group=grp_fib, tooltip="Include the 0.786 Fibonacci level for signal validation.")
rev_useL1000 = input.bool(true, title="Use 1.000 level for Filter", group=grp_fib, tooltip="Include the 1.000 Fibonacci level for signal validation.")
rev_priceSource = input.string("Low/High", title="Price Level to Test", options=["Low/High", "Close", "Open"], group=grp_fib, tooltip="Price source (Low/High, Close, Open) used to check proximity to Fibonacci levels.")

grp_fib_vis = "11. Fibonacci Lines Visibility"
rev_showL000  = input.bool(true, title="Show Fibo 0.000 Line", group=grp_fib_vis, tooltip="Toggle visibility of the 0.000 Fibonacci line on the chart.")
rev_showL236  = input.bool(true, title="Show Fibo 0.236 Line", group=grp_fib_vis, tooltip="Toggle visibility of the 0.236 Fibonacci line on the chart.")
rev_showL382  = input.bool(true, title="Show Fibo 0.382 Line", group=grp_fib_vis, tooltip="Toggle visibility of the 0.382 Fibonacci line on the chart.")
rev_showL500  = input.bool(true, title="Show Fibo 0.500 Line", group=grp_fib_vis, tooltip="Toggle visibility of the 0.500 Fibonacci line on the chart.")
rev_showL618  = input.bool(true, title="Show Fibo 0.618 Line", group=grp_fib_vis, tooltip="Toggle visibility of the 0.618 Fibonacci line on the chart.")
rev_showL786  = input.bool(true, title="Show Fibo 0.786 Line", group=grp_fib_vis, tooltip="Toggle visibility of the 0.786 Fibonacci line on the chart.")
rev_showL1000 = input.bool(true, title="Show Fibo 1.000 Line", group=grp_fib_vis, tooltip="Toggle visibility of the 1.000 Fibonacci line on the chart.")


// ==============================================================================
// 📐 SECTION 4: BANDS & CHANNELS CALCULATIONS
// ==============================================================================
// -- Bollinger Bands --
bc_basisBB = ta.sma(close, bc_lengthBB)
bc_devBB = bc_multBB * ta.stdev(close, bc_lengthBB)
bc_upperBB = bc_basisBB + bc_devBB
bc_lowerBB = bc_basisBB - bc_devBB

// -- Keltner Channels --
bc_basisKC = ta.ema(close, bc_lengthKC)
bc_atrKC = ta.atr(bc_lengthKC)
bc_upperKC = bc_basisKC + bc_multKC * bc_atrKC
bc_lowerKC = bc_basisKC - bc_multKC * bc_atrKC

// -- Donchian Channels --
bc_upperDC = ta.highest(high, bc_lengthDC)
bc_lowerDC = ta.lowest(low, bc_lengthDC)
bc_basisDC = math.avg(bc_upperDC, bc_lowerDC)

// -- Envelopes --
bc_basisENV = ta.sma(close, bc_lengthENV)
bc_upperENV = bc_basisENV + bc_basisENV * bc_percentENV / 100
bc_lowerENV = bc_basisENV - bc_basisENV * bc_percentENV / 100

// -- Linear Regression Channel --
bc_basisLR = ta.linreg(close, bc_lengthLR, 0)
bc_devLR = bc_multLR * ta.stdev(close, bc_lengthLR)
bc_upperLR = bc_basisLR + bc_devLR
bc_lowerLR = bc_basisLR - bc_devLR

// Helper functions to retrieve upper and lower bounds based on chosen system
bc_f_get_upper(sys) =>
    sys == 'Bollinger Bands' ? bc_upperBB : sys == 'Keltner Channels' ? bc_upperKC : sys == 'Donchian Channels' ? bc_upperDC : sys == 'Envelopes' ? bc_upperENV : bc_upperLR

bc_f_get_lower(sys) =>
    sys == 'Bollinger Bands' ? bc_lowerBB : sys == 'Keltner Channels' ? bc_lowerKC : sys == 'Donchian Channels' ? bc_lowerDC : sys == 'Envelopes' ? bc_lowerENV : bc_lowerLR

bc_upper1 = bc_f_get_upper(bc_sys1)
bc_lower1 = bc_f_get_lower(bc_sys1)
bc_upper2 = bc_f_get_upper(bc_sys2)
bc_lower2 = bc_f_get_lower(bc_sys2)

// Bands & Channels Trigger Conditions
buyCondition  = low <= bc_lower1 and low <= bc_lower2
sellCondition = high >= bc_upper1 and high >= bc_upper2


// ==============================================================================
// 🔍 SECTION 5: REVERSAL & FIBONACCI CALCULATIONS
// ==============================================================================
// Function for Fibonacci proximity check
rev_isNearLevel(price, levelPrice, rangeDiff, tolerance) =>
    math.abs(price - levelPrice) <= (rangeDiff * tolerance)

// Candlestick Patterns
rev_bodySize    = math.abs(close - open)
rev_shadowUpper = high - math.max(close, open)
rev_shadowLower = math.min(close, open) - low
rev_candleRange = high - low

rev_bullEngulf = rev_showEngulfing and close > open and close[1] < open[1] and close >= open[1] and open <= close[1] and (close - open) > (open[1] - close[1])
rev_bearEngulf = rev_showEngulfing and close < open and close[1] > open[1] and close <= open[1] and open >= close[1] and (open - close) > (close[1] - open[1])

rev_bullPinbar = rev_showPinbar and rev_shadowLower > (rev_bodySize * 2) and rev_shadowUpper < rev_bodySize
rev_bearPinbar = rev_showPinbar and rev_shadowUpper > (rev_bodySize * 2) and rev_shadowLower < rev_bodySize

// Oscillators
rev_rsi      = ta.rsi(close, rev_rsiPeriod)
rev_bullRSI  = rev_showRSI and ta.crossover(rev_rsi, rev_rsiOS)
rev_bearRSI  = rev_showRSI and ta.crossunder(rev_rsi, rev_rsiOB)

rev_stochK   = ta.sma(ta.stoch(close, high, low, 14), 3)
rev_stochD   = ta.sma(rev_stochK, 3)
rev_bullStoch = rev_showStoch and ta.crossover(rev_stochK, rev_stochD) and rev_stochK < 20
rev_bearStoch = rev_showStoch and ta.crossunder(rev_stochK, rev_stochD) and rev_stochK > 80

// Bollinger Bands Reversal
[rev_bbMiddle, rev_bbUpper, rev_bbLower] = ta.bb(close, 20, 2.0)
rev_bullBB   = rev_showBB and ta.crossover(close, rev_bbLower)
rev_bearBB   = rev_showBB and ta.crossunder(close, rev_bbUpper)

// Combine Reversal signals
rev_bullSignal = rev_bullEngulf or rev_bullPinbar or rev_bullRSI or rev_bullStoch or rev_bullBB
rev_bearSignal = rev_bearEngulf or rev_bearPinbar or rev_bearRSI or rev_bearStoch or rev_bearBB

// Auto Fibonacci Calculations
rev_highPrice = ta.highest(high, rev_lookback)
rev_lowPrice  = ta.lowest(low, rev_lookback)
rev_highBar   = bar_index + ta.highestbars(high, rev_lookback)
rev_lowBar    = bar_index + ta.lowestbars(low, rev_lookback)

rev_isUptrend = rev_highBar > rev_lowBar
rev_diff      = rev_highPrice - rev_lowPrice

rev_f_0_000 = rev_isUptrend ? rev_highPrice : rev_lowPrice
rev_f_0_236 = rev_isUptrend ? rev_highPrice - (rev_diff * 0.236) : rev_lowPrice + (rev_diff * 0.236)
rev_f_0_382 = rev_isUptrend ? rev_highPrice - (rev_diff * 0.382) : rev_lowPrice + (rev_diff * 0.382)
rev_f_0_500 = rev_isUptrend ? rev_highPrice - (rev_diff * 0.500) : rev_lowPrice + (rev_diff * 0.500)
rev_f_0_618 = rev_isUptrend ? rev_highPrice - (rev_diff * 0.618) : rev_lowPrice + (rev_diff * 0.618)
rev_f_0_786 = rev_isUptrend ? rev_highPrice - (rev_diff * 0.786) : rev_lowPrice + (rev_diff * 0.786)
rev_f_1_000 = rev_isUptrend ? rev_lowPrice : rev_highPrice

// Fibo Level Proximity Filtering
rev_priceForBull = rev_priceSource == "Low/High" ? low : (rev_priceSource == "Close" ? close : open)
rev_priceForBear = rev_priceSource == "Low/High" ? high : (rev_priceSource == "Close" ? close : open)

rev_nearFiboBull = (rev_useL000 and rev_isNearLevel(rev_priceForBull, rev_f_0_000, rev_diff, rev_tolerancePct)) or
                   (rev_useL236 and rev_isNearLevel(rev_priceForBull, rev_f_0_236, rev_diff, rev_tolerancePct)) or
                   (rev_useL382 and rev_isNearLevel(rev_priceForBull, rev_f_0_382, rev_diff, rev_tolerancePct)) or
                   (rev_useL500 and rev_isNearLevel(rev_priceForBull, rev_f_0_500, rev_diff, rev_tolerancePct)) or
                   (rev_useL618 and rev_isNearLevel(rev_priceForBull, rev_f_0_618, rev_diff, rev_tolerancePct)) or
                   (rev_useL786 and rev_isNearLevel(rev_priceForBull, rev_f_0_786, rev_diff, rev_tolerancePct)) or
                   (rev_useL1000 and rev_isNearLevel(rev_priceForBull, rev_f_1_000, rev_diff, rev_tolerancePct))

rev_nearFiboBear = (rev_useL000 and rev_isNearLevel(rev_priceForBear, rev_f_0_000, rev_diff, rev_tolerancePct)) or
                   (rev_useL236 and rev_isNearLevel(rev_priceForBear, rev_f_0_236, rev_diff, rev_tolerancePct)) or
                   (rev_useL382 and rev_isNearLevel(rev_priceForBear, rev_f_0_382, rev_diff, rev_tolerancePct)) or
                   (rev_useL500 and rev_isNearLevel(rev_priceForBear, rev_f_0_500, rev_diff, rev_tolerancePct)) or
                   (rev_useL618 and rev_isNearLevel(rev_priceForBear, rev_f_0_618, rev_diff, rev_tolerancePct)) or
                   (rev_useL786 and rev_isNearLevel(rev_priceForBear, rev_f_0_786, rev_diff, rev_tolerancePct)) or
                   (rev_useL1000 and rev_isNearLevel(rev_priceForBear, rev_f_1_000, rev_diff, rev_tolerancePct))

// Direction Filtering for Raw Reversal Signals
long_allowed  = (trade_direction == "Both" or trade_direction == "Buy Only")
short_allowed = (trade_direction == "Both" or trade_direction == "Sell Only")

raw_Buy  = long_allowed and rev_bullSignal and rev_nearFiboBull
raw_Sell = short_allowed and rev_bearSignal and rev_nearFiboBear


// ==============================================================================
// ⏱️ SECTION 6: RETEST ENGINE CALCULATIONS
// ==============================================================================
atrVal = ta.atr(sim_atr_len)
atrVal_non_na = nz(atrVal, close * 0.01)

var int pending_trend = 0 // 1 = Buy Pending, -1 = Sell Pending, 0 = None
var float retest_price = na
var int bars_waited = 0

bool final_Buy = false
bool final_Sell = false

// Detect initial signal and set target retest price
if raw_Buy
    if use_retest
        pending_trend := 1
        bars_waited := 0
        retest_price := close - retest_mult * atrVal_non_na
    else
        final_Buy := true

if raw_Sell
    if use_retest
        pending_trend := -1
        bars_waited := 0
        retest_price := close + retest_mult * atrVal_non_na
    else
        final_Sell := true

// Track price in subsequent bars for retest confirmation
if pending_trend != 0 and not raw_Buy and not raw_Sell
    bars_waited := bars_waited + 1

    if pending_trend == 1
        if low <= retest_price
            final_Buy := true
            pending_trend := 0
        else if bars_waited >= max_wait_bars
            final_Buy := true
            pending_trend := 0

    else if pending_trend == -1
        if high >= retest_price
            final_Sell := true
            pending_trend := 0
        else if bars_waited >= max_wait_bars
            final_Sell := true
            pending_trend := 0


// ==============================================================================
// 🎯 SECTION 7: FINAL CONFLUENCE ORDER LOGIC
// ==============================================================================
// Requirement 3: Buy order when final_Buy AND (buyCondition or buyCondition[1] or buyCondition[2] or buyCondition[3])
final_Buy_Order = final_Buy and (buyCondition or buyCondition[1] or buyCondition[2] or buyCondition[3])

// Requirement 4: Sell order when final_Sell AND (sellCondition or sellCondition[1] or sellCondition[2] or sellCondition[3])
final_Sell_Order = final_Sell and (sellCondition or sellCondition[1] or sellCondition[2] or sellCondition[3])


// ==============================================================================
// 🎨 SECTION 8: PLOTTING & VISUALS
// ==============================================================================
// Plot Bands & Channels
plot(bc_showBB ? bc_upperBB : na, color = color.new(color.blue, 50), linewidth = 1, title = 'BB Upper')
plot(bc_showBB ? bc_lowerBB : na, color = color.new(color.blue, 50), linewidth = 1, title = 'BB Lower')

plot(bc_showKC ? bc_upperKC : na, color = color.new(color.orange, 50), linewidth = 1, title = 'KC Upper')
plot(bc_showKC ? bc_lowerKC : na, color = color.new(color.orange, 50), linewidth = 1, title = 'KC Lower')

plot(bc_showDC ? bc_upperDC : na, color = color.new(color.purple, 50), linewidth = 1, style = plot.style_stepline, title = 'DC Upper')
plot(bc_showDC ? bc_lowerDC : na, color = color.new(color.purple, 50), linewidth = 1, style = plot.style_stepline, title = 'DC Lower')

plot(bc_showENV ? bc_upperENV : na, color = color.new(color.green, 50), linewidth = 1, title = 'ENV Upper')
plot(bc_showENV ? bc_lowerENV : na, color = color.new(color.green, 50), linewidth = 1, title = 'ENV Lower')

plot(bc_showLR ? bc_upperLR : na, color = color.new(color.red, 50), linewidth = 1, title = 'LR Upper')
plot(bc_showLR ? bc_lowerLR : na, color = color.new(color.red, 50), linewidth = 1, title = 'LR Lower')

// Plot Auto Fibonacci Levels
plot(rev_showL000  ? rev_f_0_000  : na, title="Fibo 0.000",  color=color.new(color.gray, 30),   style=plot.style_linebr)
plot(rev_showL236  ? rev_f_0_236  : na, title="Fibo 0.236",  color=color.new(color.teal, 30),   style=plot.style_linebr)
plot(rev_showL382  ? rev_f_0_382  : na, title="Fibo 0.382",  color=color.new(color.yellow, 30), style=plot.style_linebr)
plot(rev_showL500  ? rev_f_0_500  : na, title="Fibo 0.500",  color=color.new(color.orange, 20), style=plot.style_linebr, linewidth=2)
plot(rev_showL618  ? rev_f_0_618  : na, title="Fibo 0.618",  color=color.new(color.fuchsia, 20),style=plot.style_linebr, linewidth=2)
plot(rev_showL786  ? rev_f_0_786  : na, title="Fibo 0.786",  color=color.new(color.purple, 30), style=plot.style_linebr)
plot(rev_showL1000 ? rev_f_1_000  : na, title="Fibo 1.000",  color=color.new(color.gray, 30),   style=plot.style_linebr)

// Plot Retest Target Level
plot(use_retest and pending_trend != 0 ? retest_price : na, title="Retest Target Price Level", color=color.yellow, style=plot.style_circles, linewidth=2)

// Plot Final Signal Shapes
plotshape(final_Buy_Order, 'Final Buy Order', shape.triangleup, location.belowbar, color = color.lime, size = size.small, text = 'BUY')
plotshape(final_Sell_Order, 'Final Sell Order', shape.triangledown, location.abovebar, color = color.red, size = size.small, text = 'SELL')


// ==============================================================================
// 🔔 SECTION 9: ALERT CONDITIONS
// ==============================================================================
alertcondition(final_Buy_Order, title = 'Final Buy Order Alert')
alertcondition(final_Sell_Order, title = 'Final Sell Order Alert')
````
