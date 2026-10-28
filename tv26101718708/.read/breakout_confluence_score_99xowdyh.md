# Breakout Confluence Score

- url: https://www.tradingview.com/script/99Xowdyh-Breakout-Confluence-Score/
- type: indicator
- pine_id: PUB;9c5ef354a9de4292b2dc43441996c1d9
- version: 2.0

## Description

█ OVERVIEW
Breakout Confluence Score is an indicator designed to filter breakouts from consolidation by evaluating the overall market context before generating a signal.

The core assumption of the indicator is that not every breakout from consolidation has the same value. In practice, the success rate of a breakout depends on many independent factors such as market direction, trend strength, momentum, participant activity, and the quality of the consolidation itself.

Instead of treating every breakout equally, the indicator analyzes a series of independent market elements and assigns each of them a specific number of points. The final result creates the so-called Confluence Score — an assessment of how well multiple factors support a given breakout.

Only after reaching the minimum required score is a LONG or SHORT signal generated.

This approach significantly reduces the number of weak breakouts that appear during choppy price action, while still offering full configuration flexibility. Every scoring element can be individually enabled, disabled, or assigned its own point weight.

In addition to generating signals, the indicator also serves as a tool for ongoing market evaluation. The built-in scoring table shows the current status of all conditions even before a breakout occurs, allowing the trader to observe whether market conditions are gradually improving or deteriorating.

An integral part of the indicator is also the Signal Tester, which enables quick evaluation of the historical performance of the signals without the need to create a separate TradingView strategy. The tester was designed as a tool for assessing signal quality rather than as a full backtesting engine. This allows it to offer several capabilities that are difficult or impossible to achieve in classic strategies.

All modules of the indicator can operate independently, which means Breakout Confluence Score can be used as a simple breakout detector, a consolidation analysis tool, a market condition evaluation system, or a complete trade signal filter.

█ CONCEPTS
Most breakout indicators assume that every breakout from consolidation has similar chances of success.
In reality, the market does not work that way.

Price constantly moves through phases of trend, accumulation, distribution, and choppy movements without a clear direction. Two almost identical-looking breakouts can lead to completely different outcomes solely because of different market conditions.

That is why Breakout Confluence Score separates the signal generation process into two independent stages:
• detection of the breakout,
• evaluation of the quality of market conditions supporting that breakout.

A signal appears only when both conditions are met.


Building Consolidation and Boxes
The foundation of the indicator is automatic consolidation detection.
Consolidation begins when a defined number of consecutive candles remain inside the High-Low range of the base candle. The first candle that meets this condition defines the boundaries of the entire consolidation zone.

Its high becomes the upper boundary of the box, while its low defines the lower boundary. As long as every subsequent candle stays inside this range, the consolidation continues and the box is gradually extended to the right with each new candle.

As a result, a visual equilibrium zone appears on the chart, showing the area where neither buyers nor sellers have yet gained a clear advantage.

Consolidation ends in one of three cases:
• price breaks above the upper boundary of the box,
• price breaks below the lower boundary of the box,
• consolidation lasts too long and exceeds the maximum allowed number of candles.

Optionally, the indicator can also prevent a new consolidation from starting after a candle with an exceptionally large range. For this purpose, it uses ATR calculated before the analyzed candle, so a single large impulse cannot artificially inflate the volatility threshold and facilitate the creation of a new consolidation zone.


Why the Breakout Alone Is Not Enough
A breakout from consolidation does not automatically mean a good trading opportunity.
Very often breakouts occur:
• without clear momentum,
• against the dominant trend,
• on low volume,
• during a weak trend,
• without real buying or selling pressure.

Technically these are valid breakouts, but statistically their success rate tends to be much lower.

For this reason, the indicator does not evaluate only the fact of the breakout itself, but also the entire market environment in which it occurs. In practice, this means that two identical breakouts can receive completely different point scores. It is the scoring system that determines the quality of the signal.


Scoring and Market Context Evaluation
The purpose of scoring is to determine the current market situation as accurately as possible.
The breakout itself only informs that price has left the consolidation zone.
Scoring answers a much more important question:

“Does the market have sufficient conditions to continue the move after the breakout?”

Each scoring element analyzes a different aspect of market behavior.
Thanks to this, the final score is not based on a single indicator, but represents a combination of multiple independent sources of information.

EMA – Trend Direction
The Price vs EMA condition determines the dominant market direction.
If price is above the EMA, the LONG side receives an advantage.
If price is below the EMA, the SHORT side receives an advantage.
EMA is therefore responsible for identifying the dominant trend.

EMA Slope – Trend Development
The mere location of price relative to the EMA does not yet tell us whether the trend is developing actively.
That is why the slope of the average is also analyzed.
A rising EMA indicates a developing uptrend.
A falling EMA indicates a developing downtrend.
EMA Slope is responsible for assessing the quality and direction of trend development.

RSI – Momentum
RSI is used as a momentum indicator.
It is not used here to find overbought or oversold zones.
Its task is to assess which side of the market currently has greater strength.
RSI above 50 supports LONG signals.
RSI below 50 supports SHORT signals.
RSI is responsible for evaluating current market momentum.

ADX – Trend Strength
ADX measures the strength of the move regardless of its direction.
A high ADX value means the market is moving in a decisive and orderly manner.
A low ADX value indicates the lack of a clear advantage for either side.
ADX is responsible for assessing trend strength.

Volume – Market Participant Activity
Volume allows evaluation of whether increased participant activity stands behind the breakout.
Breakouts that occur on above-average volume are generally more reliable than breakouts that occur during low activity.
Volume is responsible for assessing market interest.

Body Size – Strength of the Breakout Candle
A large body of the breakout candle indicates a decisive advantage of one side of the market.
If the candle body is clearly larger than the average of recent candles, the breakout receives additional points.
Body Size is responsible for evaluating the strength of the breakout impulse itself.

Zone Tightness – Market Compression
Not all consolidations have the same value.
The narrower the box relative to the current ATR, the higher the probability that the market is in a compression phase preceding a stronger move.
Zone Tightness is responsible for assessing the quality and compression of the consolidation.

Duration Premium – Maturity of Consolidation
Longer consolidations often lead to more decisive breakouts.
Therefore, the indicator additionally rewards zones that have lasted for a sufficient amount of time.
Duration Premium is responsible for assessing the maturity of the consolidation.


Live Market Analysis
Scoring does not work only at the moment of breakout.
The scoring table analyzes all conditions in real time, even before a signal appears.
This allows the trader to observe how the market situation is changing and which side of the market is gradually gaining an advantage.
In practice, the indicator becomes not only a signal system, but also a tool for continuous evaluation of the current market environment.


Signal Tester
The Signal Tester was designed as a quick tool for evaluating the quality of generated signals.
It is not a full backtesting engine like TradingView Strategy and its results should not be treated as an accurate simulation of real trading.

A simplified operating model was deliberately used because it enables functionalities that are difficult or impossible to achieve in classic strategies.
The tester can simultaneously maintain multiple positions, manage LONG and SHORT trades independently, and — depending on the settings — allow simultaneous opening of positions in both directions. It can also block new entries until the previous position is closed or reject signals that appear too close to already open trades.

Each position receives its own Entry, Take Profit, and Stop Loss levels calculated based on ATR, which makes it possible to quickly compare different scoring configurations without building a full strategy.

The tester’s results are calculated conservatively.
If both the Take Profit and Stop Loss levels could have been reached during a single candle, the tester always assumes that the Stop Loss was hit.
Because the real sequence of price movements inside a single candle is unknown, this approach deliberately underestimates rather than overestimates the results. This effect becomes especially visible with small TP and SL distances, for example 0.5 ATR, where both levels can very often be reached within one candle. The smaller the TP and SL values relative to ATR, the more conservative the tester’s statistics will be.

The tester also does not account for commissions, spreads, or slippage. Therefore its results should be treated as a tool for comparing signal quality and optimizing indicator settings, not as an accurate simulation of real trading results.

█ FEATURES
Consolidation
* Minimum number of candles in consolidation – Minimum number of consecutive candles required to recognize a consolidation zone
* Show consolidation zones – Enables/disables drawing of consolidation boxes on the chart
* Show breakout signals – Enables/disables display of breakout signals (triangles and/or score labels)
* Remove box if breakout did NOT produce a signal (score < threshold) – Automatically removes the box if the breakout did not reach the minimum scoring threshold
* Display signals as – Choose signal display style: triangles only, labels only, or both
* Maximum number of candles in consolidation (0 = no limit) – Maximum duration of consolidation — after exceeding it the box is closed without generating a signal

Candle Size Filter
* Block consolidation start on oversized candle – Prevents starting consolidation after a candle with a very large range
* Max candle range (high-low) × ATR – Threshold for candle size (multiple of ATR calculated before the candle)

Scoring - General
* Minimum score for a signal (weighted sum) – Minimum required Confluence Score to generate a signal

Scoring - Candle Body
* Average body period – Period used to calculate average candle body size
* Signal body multiplier (body > avg × mult) – Multiplier for required body size of the breakout candle
* Condition weight: large body – Point weight of the large body condition

Scoring - ADX
* ADX — period (DMI) – Period of the ADX indicator
* ADX — minimum value – Minimum ADX value required to award a point
* Condition weight: ADX – Point weight of the ADX condition

Scoring - EMA
* EMA — period (trend) – Period of the EMA used for trend evaluation
* Condition weight: price vs EMA – Point weight of the price vs EMA condition
* Condition weight: EMA direction (slope) – Point weight of the EMA slope condition

Scoring - RSI
* RSI — period – Period of the RSI indicator
* Condition weight: RSI – Point weight of the RSI above/below 50 condition

Scoring - Volume
* Volume — average period – Period used to calculate average volume
* Volume — multiplier (vol > avg × mult) – Multiplier for required volume on breakout
* Condition weight: high volume – Point weight of the high volume condition

Scoring - Consolidation Structure
* Zone tightness: max (top-bottom)/ATR – Threshold for zone width relative to ATR (compression)
* Condition weight: zone tightness – Point weight of the zone tightness condition
* Premium: extra candles above minimum – Additional number of candles above minimum required for duration premium
* Condition weight: duration (premium) – Point weight of the duration premium condition

Table
* Table position – Position of the scoring table on the chart
* Table text size – Text size in the scoring table

Colors
* Bullish Color (Long) – Color used for LONG elements
* Bearish Color (Short) – Color used for SHORT elements
* Neutral Color – Color used for neutral elements / no signal

Signal Tester (TP/SL)
* Enable signal tester – Enable/disable the signal tester
* Tester — ATR period – ATR period used by the tester
* Tester — Take Profit × ATR – Take Profit distance in ATR multiples
* Tester — Stop Loss × ATR – Stop Loss distance in ATR multiples
* Block new signals while a position is open – Block new signals until the previous position is closed
* Block signals too close to an existing position – Filter for minimum distance between signals
* Min. distance between signals × ATR – Minimum distance (in ATR) between signals in the same direction

Signal Tester - Table
* Tester table position – Position of the tester statistics table
* Tester table text size – Text size in the tester statistics table

Signal Tester - TP/SL Visualization
* Show TP/SL levels on chart – Display Entry / TP / SL levels on the chart
* Level line width – Width of TP/SL level lines
* Show risk/reward zone fill – Fill color for risk and reward zones

█ APPLICATIONS
The main task of the indicator is to evaluate the quality of the breakout by analyzing the confluence of multiple independent market factors (trend direction and strength, momentum, volume, impulse strength, zone compression, and consolidation maturity). A LONG or SHORT signal is generated only when the total score exceeds the set threshold.

Thanks to this approach, the indicator effectively eliminates a large portion of weak and false breakouts that occur in low-confluence conditions.

The scoring table operates in real time — even before a signal is generated — and allows the trader to observe how a potential opportunity is gradually building up (or falling apart). This is especially useful for early detection of moments when the market begins to meet more and more conditions favorable for a breakout.

The built-in Signal Tester enables quick and convenient comparison of different scoring configurations without the need to write a separate strategy. It allows checking in just a few seconds how changing weights or thresholds affects the historical performance of the signals.

The indicator achieves the best results when used together with support and resistance zone analysis. For example, opening a long position directly under strong resistance is generally not advisable, while a long signal aligned with a support zone usually produces significantly better results. Similarly, short signals appearing near resistance tend to be more effective than those generated without reference to key levels.

The indicator works best when combined with support and resistance analysis.

█ NOTES
* Each of the eight scoring conditions can be independently enabled or disabled by setting its weight to 0.
* The scoring table shows the current market state in real time — it can be used even when signal generation is disabled.
* The Signal Tester operates in conservative mode: if both TP and SL could have been reached on the same candle, it always counts it as a loss. This approach deliberately underestimates results to provide a more realistic picture.
* The tester does not account for commissions, spreads, or slippage — it serves only for comparing signal quality and optimizing settings.
* All modules of the indicator (consolidation detection, scoring, table, tester, TP/SL visualization) can operate completely independently.
* Very long consolidations exceeding the “Maximum number of candles” limit are automatically closed without generating a signal to avoid outdated zones.
* The best results are achieved when the indicator is used together with support and resistance zone analysis. Long signals near support and short signals near resistance are generally significantly more effective.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("Breakout Confluence Score", overlay=true, max_boxes_count=500, max_labels_count=300, max_lines_count=100)

// Consolidation
length = input.int(7, "Minimum number of candles in consolidation", minval=2, group="Consolidation", tooltip="Minimum number of consecutive candles with a similar range (open/close) that must occur before an area is recognized as consolidation.")
show_zones = input.bool(true, "Show consolidation zones", group="Consolidation", tooltip="Draws a box on the chart showing the detected consolidation zone.")
show_breakouts = input.bool(true, "Show breakout signals", group="Consolidation", tooltip="Enables display of breakout signals (triangles and/or score labels, according to the 'Display signals as' setting). When disabled, no breakout signals are drawn.")
hide_no_signal_boxes = input.bool(true, "Remove box if breakout did NOT produce a signal (score < threshold)", group="Consolidation", tooltip="When enabled, the consolidation box disappears completely after a breakout if the scoring did not reach the minimum threshold. Only boxes followed by an actual LONG/SHORT signal remain visible.")
signal_display_mode = input.string("Labels only", "Display signals as", options=["Triangles only", "Labels only", "Both"], group="Consolidation", tooltip="Triangles (plotshape) and score labels overlap on the same candle. Choose what should be shown.")
max_length = input.int(200, "Maximum number of candles in consolidation (0 = no limit)", minval=0, group="Consolidation", tooltip="If consolidation lasts longer than the given number of candles, the box is closed without generating a breakout signal. Prevents very long boxes (e.g. several hundred candles) on lower timeframes.")

// Candle Size Filter
groupSizeFilter = "Candle Size Filter"
use_candle_size_filter = input.bool(true, "Block consolidation start on oversized candle", group=groupSizeFilter, tooltip="When enabled, candles with too large a range (see threshold below) prevent a candle window from being recognized as consolidation.")
candle_size_atr_mult = input.float(2.0, "Max candle range (high-low) × ATR", minval=0.1, step=0.1, group=groupSizeFilter, tooltip="The reference ATR is calculated WITHOUT the candle being checked (the ATR before it is used), so that a single large candle does not inflate the reference threshold. If the range (high-low) of any candle within the consolidation window exceeds this threshold, the box will NOT be created.")

// Scoring: General
groupScoreGeneral = "Scoring - General"
min_confluence = input.int(5, "Minimum score for a signal (weighted sum)", minval=0, maxval=80, group=groupScoreGeneral, tooltip="The maximum possible score depends on the weights set in the individual scoring sections below (by default each condition gives 1 point, so max = 8).")

// Scoring: Candle Body
groupScoreBody = "Scoring - Candle Body"
body_avg_length = input.int(20, "Average body period", minval=5, group=groupScoreBody, tooltip="Number of candles used to calculate the average body (|close-open|), which is the reference point for the 'large body' condition.")
body_mult = input.float(1.2, "Signal body multiplier (body > avg × mult)", minval=0.5, step=0.1, group=groupScoreBody, tooltip="The body of the breakout candle must exceed the average body multiplied by this value for the scoring condition to be met.")
body_weight = input.int(1, "Condition weight: large body", minval=0, maxval=10, group=groupScoreBody, tooltip="Number of scoring points awarded when the signal candle's body exceeds the average × multiplier.")

// Scoring: ADX
groupScoreADX = "Scoring - ADX"
adx_length = input.int(14, "ADX — period (DMI)", minval=2, group=groupScoreADX, tooltip="Period used to calculate the ADX (Average Directional Index) indicator based on DMI.")
adx_min = input.float(20, "ADX — minimum value", minval=0, step=1, group=groupScoreADX, tooltip="Minimum ADX value above which the market is considered trending strongly enough to award a scoring point.")
adx_weight = input.int(1, "Condition weight: ADX", minval=0, maxval=10, group=groupScoreADX, tooltip="Number of scoring points awarded when ADX exceeds the minimum value.")

// Scoring: EMA
groupScoreEMA = "Scoring - EMA"
ema_length = input.int(100, "EMA — period (trend)", minval=5, group=groupScoreEMA, tooltip="Period of the exponential moving average (EMA) used as a trend filter in scoring (price position relative to EMA).")
ema_slope_length = input.int(50, "EMA — period (slope)", minval=5, group=groupScoreEMA, tooltip="Period of a separate exponential moving average (EMA) used only to evaluate slope direction, independent of the EMA used for price position. Using a different length prevents the two conditions from always being identical.")
ema_price_weight = input.int(1, "Condition weight: price vs EMA", minval=0, maxval=10, group=groupScoreEMA, tooltip="Number of scoring points awarded when the closing price is on the correct side of the EMA.")
ema_slope_weight = input.int(1, "Condition weight: EMA direction (slope)", minval=0, maxval=10, group=groupScoreEMA, tooltip="Number of scoring points awarded when the EMA is rising (for LONG) or falling (for SHORT).")

// Scoring: RSI
groupScoreRSI = "Scoring - RSI"
rsi_length = input.int(14, "RSI — period", minval=2, group=groupScoreRSI, tooltip="Period used to calculate the RSI (Relative Strength Index) indicator.")
rsi_weight = input.int(1, "Condition weight: RSI", minval=0, maxval=10, group=groupScoreRSI, tooltip="Number of scoring points awarded when RSI is above/below the neutral level of 50, according to the breakout direction.")
rsi_mid = 50.0  // neutral RSI level (fixed default value, no input)

// Scoring: Volume
groupScoreVol = "Scoring - Volume"
vol_length = input.int(20, "Volume — average period", minval=5, group=groupScoreVol, tooltip="Number of candles used to calculate the average volume, which is the reference point for the 'high volume' condition.")
vol_mult = input.float(1.5, "Volume — multiplier (vol > avg × mult)", minval=1.0, step=0.1, group=groupScoreVol, tooltip="The volume of the breakout candle must exceed the average volume multiplied by this value for the scoring condition to be met.")
vol_weight = input.int(1, "Condition weight: high volume", minval=0, maxval=10, group=groupScoreVol, tooltip="Number of scoring points awarded when volume exceeds the average × multiplier.")

// Scoring: Consolidation Structure
groupScoreStruct = "Scoring - Consolidation Structure"
zone_atr_mult   = input.float(1.5, "Zone tightness: max (top-bottom)/ATR", minval=0.1, step=0.1, group=groupScoreStruct, tooltip="If the width of the consolidation zone divided by ATR is less than this value, the zone is considered 'tight' (compressed) — an additional scoring point.")
zone_weight = input.int(1, "Condition weight: zone tightness", minval=0, maxval=10, group=groupScoreStruct, tooltip="Number of scoring points awarded when the consolidation zone is tight (compressed) relative to ATR.")
length_premium  = input.int(3, "Premium: extra candles above minimum", minval=0, group=groupScoreStruct, tooltip="An additional scoring point is awarded when the consolidation lasted at least the 'Minimum number of candles in consolidation' + this value. Example: minimum candles = 10, premium = 3 → the point is awarded from 13 candles onward.")
duration_weight = input.int(1, "Condition weight: duration (premium)", minval=0, maxval=10, group=groupScoreStruct, tooltip="Number of scoring points awarded when the consolidation lasted at least the minimum number of candles + the premium value.")

// Table
groupTable = "Table"
tablePosition = input.string("Top Right", "Table position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Top Center", "Bottom Center", "Middle Left", "Middle Right"],
     group = groupTable, tooltip="Location on the chart where the scoring table is displayed.")
tableTextSize = input.string("small", "Table text size", options = ["tiny","small","normal"], group = groupTable, tooltip="Font size of the text in the scoring table.")

// Colors (used for boxes, signals, and table)
groupColors = "Colors"
colBull    = input.color(color.rgb(6, 162, 47),  "Bullish Color (Long)",  group=groupColors, tooltip="Color used for boxes, signals, and table elements on the LONG (bullish) side.")
colBear    = input.color(color.rgb(207, 23, 23), "Bearish Color (Short)", group=groupColors, tooltip="Color used for boxes, signals, and table elements on the SHORT (bearish) side.")
colNeutral = input.color(color.gray,             "Neutral Color",         group=groupColors, tooltip="Color used for boxes without a generated signal and table elements with no clear direction.")

// Signal Tester (TP/SL)
groupBT = "Signal Tester (TP/SL)"
bt_enable = input.bool(true, "Enable signal tester", group=groupBT, tooltip="Simplified backtest of LONG/SHORT signals generated by the scoring system. Take Profit and Stop Loss only — no SL adjustment and no trailing stop.")
bt_atr_length = input.int(100, "Tester — ATR period", minval=1, group=groupBT, tooltip="ATR used to calculate the tester's TP/SL levels (independent of the ATR settings in the Scoring section).")
bt_tp_mult = input.float(5.0, "Tester — Take Profit × ATR", minval=0.1, step=0.1, group=groupBT, tooltip="Distance of the Take Profit level from the entry price, expressed as a multiple of the tester's ATR.")
bt_sl_mult = input.float(5.0, "Tester — Stop Loss × ATR", minval=0.1, step=0.1, group=groupBT, tooltip="Distance of the Stop Loss level from the entry price, expressed as a multiple of the tester's ATR.")
bt_block_in_trade = input.bool(true, "Block new signals while a position is open", group=groupBT, tooltip="When enabled, new signals are ignored until the previous tester position closes.")
bt_use_dist_filter = input.bool(false, "Block signals too close to an existing position", group=groupBT, tooltip="A new signal in a given direction is ignored if its entry price is closer than the specified distance (in ATR) to the entry price of any already open tester position in the same direction.")
bt_min_dist_atr = input.float(1.0, "Min. distance between signals × ATR", minval=0.0, step=0.1, group=groupBT, tooltip="Minimum distance (in ATR) of a new signal's entry price from the entry price of an already open tester position in the same direction, below which the new signal is ignored. Only works when the filter above is enabled.")

groupBTTable = "Signal Tester - Table"
bt_table_position = input.string("Bottom Right", "Tester table position",
     options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Top Center", "Bottom Center", "Middle Left", "Middle Right"],
     group = groupBTTable, tooltip="Location on the chart where the signal tester statistics table is displayed.")
bt_table_text_size = input.string("small", "Tester table text size", options = ["tiny","small","normal"], group = groupBTTable, tooltip="Font size of the text in the signal tester statistics table.")

// TP/SL Level Visualization on Chart
groupTPSLVis = "Signal Tester - TP/SL Visualization"
show_tpsl_levels = input.bool(true, "Show TP/SL levels on chart", group=groupTPSLVis, tooltip="Draws Entry/TP/SL lines and labels for each position opened by the signal tester. Levels are calculated from the tester's ATR and the 'Tester — Take Profit × ATR' and 'Tester — Stop Loss × ATR' multipliers from the section above — there are no separate settings here.")
tpsl_line_width = input.int(1, "Level line width", minval=1, maxval=5, group=groupTPSLVis, tooltip="Width of the Entry/TP/SL lines drawn on the chart.")
tpsl_show_fill = input.bool(true, "Show risk/reward zone fill", group=groupTPSLVis, tooltip="Fills the area between the entry price and the SL level (risk zone) and between the entry price and the TP level (profit zone) with color.")

// INDICATOR CALCULATIONS

avg_body = ta.sma(math.abs(close - open), body_avg_length)
[_, _, adx] = ta.dmi(adx_length, adx_length)     
ema = ta.ema(close, ema_length)
ema_slope = ta.ema(close, ema_slope_length)
rsi = ta.rsi(close, rsi_length)
avg_vol = ta.sma(volume, vol_length)
atr = ta.atr(14)                                  

// Maximum possible scoring value (sum of all weights) — used for the table and histogram
max_possible_score = body_weight + adx_weight + ema_price_weight + ema_slope_weight + rsi_weight + vol_weight + zone_weight + duration_weight

// Candle threshold from which the duration premium counts (minimum length + premium)
duration_threshold = length + length_premium

// PERSISTENT VARIABLES

var float base_high = na
var float base_low = na
var int base_bar = na
var bool in_consolidation = false
var box active_box = na

long_breakout = false
short_breakout = false
long_score = 0
short_score = 0

// CONSOLIDATION DETECTION (no expansion)

if not in_consolidation
    base_offset = length - 1
    if bar_index >= base_offset
        base_high_candidate = high[base_offset]
        base_low_candidate = low[base_offset]
        is_cons = true
        margin = atr * 0.01

        for i = 0 to base_offset
            bh = math.max(open[i], close[i])
            bl = math.min(open[i], close[i])
            if bh > base_high_candidate + margin or bl < base_low_candidate - margin
                is_cons := false

            // Candle size filter: reference ATR does NOT include this candle
            if use_candle_size_filter
                candle_range_i = high[i] - low[i]
                ref_atr_i = atr[i + 1]
                if not na(ref_atr_i) and ref_atr_i > 0 and candle_range_i > candle_size_atr_mult * ref_atr_i
                    is_cons := false

        if is_cons
            base_high := base_high_candidate
            base_low := base_low_candidate
            base_bar := bar_index - base_offset
            in_consolidation := true

            if show_zones and not na(base_high) and not na(base_low) and not na(base_bar)
                active_box := box.new(
                     left=base_bar, 
                     right=bar_index, 
                     top=base_high, 
                     bottom=base_low, 
                     bgcolor=color.new(color.yellow, 80), 
                     border_color=color.new(color.orange, 0), 
                     border_width=1)
else
    // Update box 
    if show_zones and not na(active_box)
        box.set_right(active_box, bar_index)

    // Check maximum consolidation length 
    cons_bars_check = bar_index - base_bar
    bool max_len_exceeded = max_length > 0 and cons_bars_check >= max_length

    // Breakout detection 
    breakout_up = close > base_high
    breakout_down = close < base_low

    if max_len_exceeded and not (breakout_up or breakout_down)
        // Consolidation lasted too long — closing box WITHOUT a signal 
        in_consolidation := false

        if show_zones and not na(active_box)
            if hide_no_signal_boxes
                box.delete(active_box)
            else
                box.set_bgcolor(active_box, color.new(colNeutral, 75))
                box.set_border_color(active_box, color.new(colNeutral, 0))
            active_box := na

        long_breakout := false
        short_breakout := false
        long_score := 0
        short_score := 0

    else if breakout_up or breakout_down
        in_consolidation := false

        // SCORING CALCULATION
        body_size = math.abs(close - open)
        body_ok = body_size > avg_body * body_mult
        adx_ok = adx > adx_min
        vol_ok = volume > avg_vol * vol_mult

        // Consolidation structure: zone tightness and duration
        zone_width = base_high - base_low
        zone_tight_ok = atr > 0 and (zone_width / atr) < zone_atr_mult
        consolidation_bars = bar_index - base_bar
        // Premium is counted from ADDITIONAL candles beyond the minimum consolidation length
        duration_ok = consolidation_bars >= duration_threshold

        if breakout_up
            price_above_ema = close > ema
            ema_rising = ema_slope > ema_slope[1]
            rsi_ok = rsi > rsi_mid

            long_score := (body_ok ? body_weight : 0) + 
                          (adx_ok ? adx_weight : 0) + 
                          (price_above_ema ? ema_price_weight : 0) + 
                          (ema_rising ? ema_slope_weight : 0) + 
                          (rsi_ok ? rsi_weight : 0) + 
                          (vol_ok ? vol_weight : 0) +
                          (zone_tight_ok ? zone_weight : 0) +
                          (duration_ok ? duration_weight : 0)

            short_score := 0
            long_breakout := true
            short_breakout := false
        else
            price_below_ema = close < ema
            ema_falling = ema_slope < ema_slope[1]
            rsi_ok = rsi < rsi_mid

            short_score := (body_ok ? body_weight : 0) + 
                           (adx_ok ? adx_weight : 0) + 
                           (price_below_ema ? ema_price_weight : 0) + 
                           (ema_falling ? ema_slope_weight : 0) + 
                           (rsi_ok ? rsi_weight : 0) + 
                           (vol_ok ? vol_weight : 0) +
                           (zone_tight_ok ? zone_weight : 0) +
                           (duration_ok ? duration_weight : 0)

            long_score := 0
            long_breakout := false
            short_breakout := true

        // BOX DECISION: color it or delete it
        bool signal_qualifies = breakout_up ? long_score >= min_confluence : short_score >= min_confluence

        if show_zones and not na(active_box)
            box.set_right(active_box, bar_index)

            if hide_no_signal_boxes and not signal_qualifies
                box.delete(active_box)
            else
                if breakout_up
                    box.set_bgcolor(active_box, color.new(colBull, 75))
                    box.set_border_color(active_box, color.new(colBull, 0))
                else
                    box.set_bgcolor(active_box, color.new(colBear, 75))
                    box.set_border_color(active_box, color.new(colBear, 0))

            active_box := na
    else
        long_breakout := false
        short_breakout := false
        long_score := 0
        short_score := 0

// CHART SIGNALS

bool show_triangles = show_breakouts and (signal_display_mode == "Triangles only" or signal_display_mode == "Both")
bool show_labels    = show_breakouts and (signal_display_mode == "Labels only" or signal_display_mode == "Both")

// Breakout triangles — only when score ≥ min_confluence
plotshape(show_triangles and long_breakout and long_score >= min_confluence,
     title="LONG",
     style=shape.triangleup, location=location.belowbar,
     size=size.normal, color=colBull)

plotshape(show_triangles and short_breakout and short_score >= min_confluence,
     title="SHORT",
     style=shape.triangledown, location=location.abovebar,
     size=size.normal, color=colBear)

// Labels with score value
if show_labels and long_breakout and long_score >= min_confluence
    label.new(bar_index, low,
         text=str.tostring(long_score),
         color=color.new(colBull, 15),
         textcolor=color.white,
         style=label.style_label_up,
         size=size.small,
         yloc=yloc.belowbar)

if show_labels and short_breakout and short_score >= min_confluence
    label.new(bar_index, high,
         text=str.tostring(short_score),
         color=color.new(colBear, 15),
         textcolor=color.white,
         style=label.style_label_down,
         size=size.small,
         yloc=yloc.abovebar)

// LIVE SCORING CONDITION CALCULATIONS

body_size_live       = math.abs(close - open)
body_ok_live         = body_size_live > avg_body * body_mult
adx_ok_live          = adx > adx_min
vol_ok_live          = volume > avg_vol * vol_mult

price_above_ema_live = close > ema
ema_rising_live      = ema_slope > ema_slope[1]
rsi_ok_long_live     = rsi > rsi_mid

price_below_ema_live = close < ema
ema_falling_live     = ema_slope < ema_slope[1]
rsi_ok_short_live    = rsi < rsi_mid

// Consolidation structure: calculated only while we are IN consolidation,
zone_width_live    = (in_consolidation and not na(base_high) and not na(base_low)) ? base_high - base_low : na
zone_tight_ok_live = (not na(zone_width_live) and atr > 0) ? (zone_width_live / atr) < zone_atr_mult : false

duration_live      = (in_consolidation and not na(base_bar)) ? bar_index - base_bar : na
duration_ok_live   = not na(duration_live) ? duration_live >= duration_threshold : false

// DIRECTIONAL conditions (EMA + RSI) — by themselves indicate L or S,
directional_long_score  = (price_above_ema_live ? ema_price_weight : 0) + (ema_rising_live ? ema_slope_weight : 0) + (rsi_ok_long_live ? rsi_weight : 0)
directional_short_score = (price_below_ema_live ? ema_price_weight : 0) + (ema_falling_live ? ema_slope_weight : 0) + (rsi_ok_short_live ? rsi_weight : 0)

// NON-DIRECTIONAL conditions (move strength: body, ADX, volume, tightness,
non_directional_score_live = (body_ok_live ? body_weight : 0) + (adx_ok_live ? adx_weight : 0) + (vol_ok_live ? vol_weight : 0) + (zone_tight_ok_live ? zone_weight : 0) + (duration_ok_live ? duration_weight : 0)

// Dominant side — determined EXCLUSIVELY based on directional conditions
int   dominant_side = directional_long_score > directional_short_score ? 1 : directional_short_score > directional_long_score ? -1 : 0
color dominant_col  = dominant_side == 1 ? colBull : dominant_side == -1 ? colBear : colNeutral

live_long_score  = directional_long_score  + (dominant_side == 1  ? non_directional_score_live : 0)
live_short_score = directional_short_score + (dominant_side == -1 ? non_directional_score_live : 0)


// histogram bar
f_hist_conf(score, maxScore) =>
    pct = maxScore > 0 ? math.max(0.0, math.min(100.0, score / maxScore * 100.0)) : 0.0
    blocks = math.max(0, math.min(10, int(math.round(pct / 10))))
    histStr = ''
    for i = 1 to 10
        histStr += i <= blocks ? '█' : '░'
    [histStr + '  ' + str.tostring(score, '#') + '/' + str.tostring(maxScore, '#') + '  (' + str.tostring(pct, '#.#') + '%)']

col_check(cond) => cond ? "✔" : "✘"
col_color_common(cond) => cond ? dominant_col : color.new(colNeutral, 40)
col_color_dir(isBull, isBear) => isBull ? colBull : isBear ? colBear : colNeutral

finalTablePos = tablePosition == "Top Left" ? position.top_left : tablePosition == "Top Right" ? position.top_right : tablePosition == "Bottom Left" ? position.bottom_left : tablePosition == "Bottom Right" ? position.bottom_right : tablePosition == "Top Center" ? position.top_center : tablePosition == "Bottom Center" ? position.bottom_center : tablePosition == "Middle Left" ? position.middle_left : tablePosition == "Middle Right" ? position.middle_right : position.top_right

tableSize = tableTextSize == "tiny" ? size.tiny : tableTextSize == "small" ? size.small : size.normal

// SCORING TABLE

var table info_table = table.new(finalTablePos, 2, 12, bgcolor=color.new(#1e1e1e, 85), border_color=color.new(color.gray, 50), border_width=1, frame_width=1, frame_color=color.new(color.gray, 85))

if barstate.islast
    table.cell(info_table, 0, 0, "Scoring condition", text_color=color.white, text_halign=text.align_center, bgcolor=#2d2d2d, text_size=tableSize)
    table.cell(info_table, 1, 0, "Long / Short",     text_color=color.white, text_halign=text.align_center, bgcolor=#2d2d2d, text_size=tableSize)

    table.cell(info_table, 0, 1, "Large body (> avg × " + str.tostring(body_mult, "#.0") + ") [w:" + str.tostring(body_weight) + "]", text_color=color.gray, text_halign=text.align_left, text_size=tableSize)
    table.cell(info_table, 1, 1, col_check(body_ok_live), text_color=col_color_common(body_ok_live), text_halign=text.align_center, text_size=tableSize)

    table.cell(info_table, 0, 2, "ADX > " + str.tostring(adx_min, "#.#") + " [w:" + str.tostring(adx_weight) + "]", text_color=color.gray, text_halign=text.align_left, text_size=tableSize)
    table.cell(info_table, 1, 2, col_check(adx_ok_live), text_color=col_color_common(adx_ok_live), text_halign=text.align_center, text_size=tableSize)

    table.cell(info_table, 0, 3, "Price vs EMA(" + str.tostring(ema_length) + ") [w:" + str.tostring(ema_price_weight) + "]", text_color=color.gray, text_halign=text.align_left, text_size=tableSize)
    table.cell(info_table, 1, 3, price_above_ema_live ? "▲ L" : price_below_ema_live ? "▼ S" : "—",
         text_color = col_color_dir(price_above_ema_live, price_below_ema_live),
         text_halign=text.align_center, text_size=tableSize)

    table.cell(info_table, 0, 4, "EMA Direction (slope, " + str.tostring(ema_slope_length) + ") [w:" + str.tostring(ema_slope_weight) + "]", text_color=color.gray, text_halign=text.align_left, text_size=tableSize)
    table.cell(info_table, 1, 4, ema_rising_live ? "↑ L" : ema_falling_live ? "↓ S" : "→",
         text_color = col_color_dir(ema_rising_live, ema_falling_live),
         text_halign=text.align_center, text_size=tableSize)

    table.cell(info_table, 0, 5, "RSI above/below 50 [w:" + str.tostring(rsi_weight) + "]", text_color=color.gray, text_halign=text.align_left, text_size=tableSize)
    table.cell(info_table, 1, 5, rsi_ok_long_live ? "▲ L" : rsi_ok_short_live ? "▼ S" : "—",
         text_color = col_color_dir(rsi_ok_long_live, rsi_ok_short_live),
         text_halign=text.align_center, text_size=tableSize)

    table.cell(info_table, 0, 6, "High volume (> avg × " + str.tostring(vol_mult, "#.0") + ") [w:" + str.tostring(vol_weight) + "]", text_color=color.gray, text_halign=text.align_left, text_size=tableSize)
    table.cell(info_table, 1, 6, col_check(vol_ok_live), text_color=col_color_common(vol_ok_live), text_halign=text.align_center, text_size=tableSize)

    string zoneTxt = na(zone_width_live) ? "—" : str.tostring(math.round(zone_width_live / atr, 2)) + "× ATR"
    table.cell(info_table, 0, 7, "Zone tightness (< " + str.tostring(zone_atr_mult, "#.#") + "× ATR) [w:" + str.tostring(zone_weight) + "]", text_color=color.gray, text_halign=text.align_left, text_size=tableSize)
    table.cell(info_table, 1, 7, zoneTxt, text_color=col_color_common(zone_tight_ok_live), text_halign=text.align_center, text_size=tableSize)

    string durTxt = na(duration_live) ? "—" : str.tostring(duration_live) + " candles"
    table.cell(info_table, 0, 8, "Consolidation duration (≥ " + str.tostring(duration_threshold) + " candles) [w:" + str.tostring(duration_weight) + "]", text_color=color.gray, text_halign=text.align_left, text_size=tableSize)
    table.cell(info_table, 1, 8, durTxt, text_color=col_color_common(duration_ok_live), text_halign=text.align_center, text_size=tableSize)

    [longHistStr] = f_hist_conf(float(live_long_score), float(max_possible_score))
    table.cell(info_table, 0, 9, "LONG Score", text_color=colBull, text_halign=text.align_left, bgcolor=#2d2d2d, text_size=tableSize)
    table.cell(info_table, 1, 9, longHistStr, text_color=colBull, text_halign=text.align_left, text_size=tableSize)

    [shortHistStr] = f_hist_conf(float(live_short_score), float(max_possible_score))
    table.cell(info_table, 0, 10, "SHORT Score", text_color=colBear, text_halign=text.align_left, bgcolor=#2d2d2d, text_size=tableSize)
    table.cell(info_table, 1, 10, shortHistStr, text_color=colBear, text_halign=text.align_left, text_size=tableSize)

    table.cell(info_table, 0, 11, "MIN. SIGNAL SCORE", text_color=color.gray, text_halign=text.align_left, bgcolor=#2d2d2d, text_size=tableSize)
    table.cell(info_table, 1, 11, str.tostring(min_confluence) + " / " + str.tostring(max_possible_score), text_color=color.gray, text_halign=text.align_center, text_size=tableSize)

// BACKTESTING HELPER PLOTS (hidden)

// LONG and SHORT signals with score ≥ min_confluence (for backtests / strategy)
plot(long_breakout and long_score >= min_confluence ? 1 : na, 
     "bt_score_long", display = display.none)

plot(short_breakout and short_score >= min_confluence ? 1 : na, 
     "bt_score_short", display = display.none)

// SIGNAL TESTER

bt_raw_buy  = long_breakout and long_score >= min_confluence
bt_raw_sell = short_breakout and short_score >= min_confluence

bt_open_buy_now  = bt_raw_buy[1]
bt_open_sell_now = bt_raw_sell[1]

bt_atr = ta.atr(bt_atr_length)[1]

var array<float>  bt_ep   = array.new<float>()
var array<int>    bt_dir  = array.new<int>()
var array<float>  bt_tp   = array.new<float>()
var array<float>  bt_sl   = array.new<float>()
var array<float>  bt_atrE = array.new<float>()
var array<int>    bt_ebar = array.new<int>()

var array<string> bt_closeType    = array.new<string>()
var array<float>  bt_closeRetATR  = array.new<float>()

var int bt_total_trades = 0

// TP/SL visualization
var array<line>  tpsl_entryLn = array.new<line>()
var array<line>  tpsl_tpLn    = array.new<line>()
var array<line>  tpsl_slLn    = array.new<line>()
var array<label> tpsl_entryLb = array.new<label>()
var array<label> tpsl_tpLb    = array.new<label>()
var array<label> tpsl_slLb    = array.new<label>()
var array<linefill> tpsl_riskFill   = array.new<linefill>()
var array<linefill> tpsl_rewardFill = array.new<linefill>()

// Distance filter: checks whether an open position already exists in a given direction
f_bt_too_close(int dir, float refPrice, float av) =>
    bool tooClose = false
    if bt_use_dist_filter and not na(av)
        int k = 0
        while k < array.size(bt_ep)
            if array.get(bt_dir, k) == dir
                if math.abs(refPrice - array.get(bt_ep, k)) < bt_min_dist_atr * av
                    tooClose := true
            k += 1
    tooClose

// Exit check (TP/SL)
// Pessimistically: if both could have been hit on the same candle
if bt_enable
    int bt_i = 0
    while bt_i < array.size(bt_ep)
        float bt_e  = array.get(bt_ep,   bt_i)
        int   bt_d  = array.get(bt_dir,  bt_i)
        float bt_t  = array.get(bt_tp,   bt_i)
        float bt_s  = array.get(bt_sl,   bt_i)
        float bt_av = array.get(bt_atrE, bt_i)
        int   bt_eb = array.get(bt_ebar, bt_i)

        if bar_index <= bt_eb
            bt_i += 1
            continue

        bool bt_hitSL = bt_d == 1 ? low  <= bt_s : high >= bt_s
        bool bt_hitTP = bt_d == 1 ? high >= bt_t : low  <= bt_t

        bool   bt_done = false
        string bt_xType = na
        float  bt_exitPrice = na

        if bt_hitSL
            bt_xType := "Loss"
            bt_exitPrice := bt_s
            bt_done := true
        else if bt_hitTP
            bt_xType := "Win"
            bt_exitPrice := bt_t
            bt_done := true
        else if bar_index - bt_eb > 1000
            bt_xType := "Loss"
            bt_exitPrice := close
            bt_done := true

        if bt_done
            float bt_retATR = bt_d == 1 ? (bt_exitPrice - bt_e) / bt_av : (bt_e - bt_exitPrice) / bt_av
            array.push(bt_closeType, bt_xType)
            array.push(bt_closeRetATR, bt_retATR)

            // Close visual TP/SL levels for this position
            if show_tpsl_levels and bt_i < array.size(tpsl_entryLn)
                line.set_extend(array.get(tpsl_entryLn, bt_i), extend.none)
                line.set_x2(array.get(tpsl_entryLn, bt_i), bar_index)
                line.set_extend(array.get(tpsl_tpLn, bt_i), extend.none)
                line.set_x2(array.get(tpsl_tpLn, bt_i), bar_index)
                line.set_extend(array.get(tpsl_slLn, bt_i), extend.none)
                line.set_x2(array.get(tpsl_slLn, bt_i), bar_index)
                array.remove(tpsl_entryLn, bt_i)
                array.remove(tpsl_tpLn,    bt_i)
                array.remove(tpsl_slLn,    bt_i)
                array.remove(tpsl_entryLb, bt_i)
                array.remove(tpsl_tpLb,    bt_i)
                array.remove(tpsl_slLb,    bt_i)
                array.remove(tpsl_riskFill,   bt_i)
                array.remove(tpsl_rewardFill, bt_i)

            array.remove(bt_ep,   bt_i)
            array.remove(bt_dir,  bt_i)
            array.remove(bt_tp,   bt_i)
            array.remove(bt_sl,   bt_i)
            array.remove(bt_atrE, bt_i)
            array.remove(bt_ebar, bt_i)
        else
            bt_i += 1

// Entry
bt_can_open = not bt_block_in_trade or array.size(bt_ep) == 0
bt_buy_too_close  = f_bt_too_close(1,  open, bt_atr)
bt_sell_too_close = f_bt_too_close(-1, open, bt_atr)

if bt_enable and bt_open_buy_now and bt_can_open and not bt_buy_too_close and not na(bt_atr)
    bt_total_trades += 1
    float bt_entryPrice = open
    float bt_tpPrice = bt_entryPrice + bt_atr * bt_tp_mult
    float bt_slPrice = bt_entryPrice - bt_atr * bt_sl_mult
    array.push(bt_ep,   bt_entryPrice)
    array.push(bt_dir,  1)
    array.push(bt_tp,   bt_tpPrice)
    array.push(bt_sl,   bt_slPrice)
    array.push(bt_atrE, bt_atr)
    array.push(bt_ebar, bar_index)

    if show_tpsl_levels
        line en_ln = line.new(bar_index, bt_entryPrice, bar_index + 1, bt_entryPrice, color=color.new(colNeutral, 0), width=tpsl_line_width, extend=extend.right)
        line tp_ln = line.new(bar_index, bt_tpPrice, bar_index + 1, bt_tpPrice, color=colBull, width=tpsl_line_width, style=line.style_dashed, extend=extend.right)
        line sl_ln = line.new(bar_index, bt_slPrice, bar_index + 1, bt_slPrice, color=colBear, width=tpsl_line_width, style=line.style_dashed, extend=extend.right)
        label en_lb = label.new(bar_index, bt_entryPrice, "Entry " + str.tostring(bt_entryPrice, format.mintick), style=label.style_label_left, color=color.new(colNeutral, 20), textcolor=color.white, size=size.small)
        label tp_lb = label.new(bar_index, bt_tpPrice, "TP " + str.tostring(bt_tp_mult, "#.#") + "×ATR", style=label.style_label_left, color=color.new(colBull, 20), textcolor=color.white, size=size.small)
        label sl_lb = label.new(bar_index, bt_slPrice, "SL " + str.tostring(bt_sl_mult, "#.#") + "×ATR", style=label.style_label_left, color=color.new(colBear, 20), textcolor=color.white, size=size.small)
        linefill riskFl = tpsl_show_fill ? linefill.new(en_ln, sl_ln, color.new(colBear, 85)) : na
        linefill rewFl  = tpsl_show_fill ? linefill.new(en_ln, tp_ln, color.new(colBull, 85)) : na
        array.push(tpsl_entryLn, en_ln)
        array.push(tpsl_tpLn,    tp_ln)
        array.push(tpsl_slLn,    sl_ln)
        array.push(tpsl_entryLb, en_lb)
        array.push(tpsl_tpLb,    tp_lb)
        array.push(tpsl_slLb,    sl_lb)
        array.push(tpsl_riskFill,   riskFl)
        array.push(tpsl_rewardFill, rewFl)

if bt_enable and bt_open_sell_now and bt_can_open and not bt_sell_too_close and not na(bt_atr)
    bt_total_trades += 1
    float bt_entryPrice = open
    float bt_tpPrice = bt_entryPrice - bt_atr * bt_tp_mult
    float bt_slPrice = bt_entryPrice + bt_atr * bt_sl_mult
    array.push(bt_ep,   bt_entryPrice)
    array.push(bt_dir,  -1)
    array.push(bt_tp,   bt_tpPrice)
    array.push(bt_sl,   bt_slPrice)
    array.push(bt_atrE, bt_atr)
    array.push(bt_ebar, bar_index)

    if show_tpsl_levels
        line en_ln = line.new(bar_index, bt_entryPrice, bar_index + 1, bt_entryPrice, color=color.new(colNeutral, 0), width=tpsl_line_width, extend=extend.right)
        line tp_ln = line.new(bar_index, bt_tpPrice, bar_index + 1, bt_tpPrice, color=colBull, width=tpsl_line_width, style=line.style_dashed, extend=extend.right)
        line sl_ln = line.new(bar_index, bt_slPrice, bar_index + 1, bt_slPrice, color=colBear, width=tpsl_line_width, style=line.style_dashed, extend=extend.right)
        label en_lb = label.new(bar_index, bt_entryPrice, "Entry " + str.tostring(bt_entryPrice, format.mintick), style=label.style_label_left, color=color.new(colNeutral, 20), textcolor=color.white, size=size.small)
        label tp_lb = label.new(bar_index, bt_tpPrice, "TP " + str.tostring(bt_tp_mult, "#.#") + "×ATR", style=label.style_label_left, color=color.new(colBull, 20), textcolor=color.white, size=size.small)
        label sl_lb = label.new(bar_index, bt_slPrice, "SL " + str.tostring(bt_sl_mult, "#.#") + "×ATR", style=label.style_label_left, color=color.new(colBear, 20), textcolor=color.white, size=size.small)
        linefill riskFl = tpsl_show_fill ? linefill.new(en_ln, sl_ln, color.new(colBear, 85)) : na
        linefill rewFl  = tpsl_show_fill ? linefill.new(en_ln, tp_ln, color.new(colBull, 85)) : na
        array.push(tpsl_entryLn, en_ln)
        array.push(tpsl_tpLn,    tp_ln)
        array.push(tpsl_slLn,    sl_ln)
        array.push(tpsl_entryLb, en_lb)
        array.push(tpsl_tpLb,    tp_lb)
        array.push(tpsl_slLb,    sl_lb)
        array.push(tpsl_riskFill,   riskFl)
        array.push(tpsl_rewardFill, rewFl)

// Statistics
int   bt_cTrades    = 0
int   bt_cWin       = 0
int   bt_cLoss      = 0
float bt_totalATR   = 0.0
float bt_sumWinATR  = 0.0
float bt_sumLossATR = 0.0

if bt_enable and barstate.islast and array.size(bt_closeType) > 0
    bt_cTrades := array.size(bt_closeType)
    for bt_j = 0 to bt_cTrades - 1
        string bt_t2  = array.get(bt_closeType, bt_j)
        float  bt_rt2 = array.get(bt_closeRetATR, bt_j)
        bt_totalATR += bt_rt2
        if bt_t2 == "Win"
            bt_cWin += 1
            bt_sumWinATR += bt_rt2
        else
            bt_cLoss += 1
            bt_sumLossATR += math.abs(bt_rt2)

float bt_wr   = bt_cTrades > 0 ? bt_cWin * 100.0 / bt_cTrades : 0.0
float bt_edge = bt_cTrades > 0 ? bt_totalATR / bt_cTrades : 0.0
float bt_pf   = bt_sumLossATR > 0 ? bt_sumWinATR / bt_sumLossATR : (bt_sumWinATR > 0 ? 999.0 : 0.0)

finalBtTablePos = bt_table_position == "Top Left" ? position.top_left : bt_table_position == "Top Right" ? position.top_right : bt_table_position == "Bottom Left" ? position.bottom_left : bt_table_position == "Bottom Right" ? position.bottom_right : bt_table_position == "Top Center" ? position.top_center : bt_table_position == "Bottom Center" ? position.bottom_center : bt_table_position == "Middle Left" ? position.middle_left : bt_table_position == "Middle Right" ? position.middle_right : position.bottom_right

btTableSize = bt_table_text_size == "tiny" ? size.tiny : bt_table_text_size == "small" ? size.small : size.normal

var table bt_table = table.new(finalBtTablePos, 2, 10, bgcolor=color.new(#1e1e1e, 85), border_color=color.new(color.gray, 50), border_width=1, frame_width=1, frame_color=color.new(color.gray, 85))

if bt_enable and barstate.islast
    table.cell(bt_table, 0, 0, "Signal Tester", text_color=color.white, text_halign=text.align_left, bgcolor=#2d2d2d, text_size=btTableSize)
    table.cell(bt_table, 1, 0, "TP×" + str.tostring(bt_tp_mult) + " / SL×" + str.tostring(bt_sl_mult), text_color=color.silver, text_halign=text.align_center, bgcolor=#2d2d2d, text_size=btTableSize)

    table.cell(bt_table, 0, 1, "Closed", text_color=color.gray, text_halign=text.align_left, text_size=btTableSize)
    table.cell(bt_table, 1, 1, str.tostring(bt_cTrades), text_color=color.rgb(168, 168, 168), text_halign=text.align_center, text_size=btTableSize)

    table.cell(bt_table, 0, 2, "Win (TP)", text_color=color.gray, text_halign=text.align_left, text_size=btTableSize)
    table.cell(bt_table, 1, 2, str.tostring(bt_cWin), text_color=color.green, text_halign=text.align_center, text_size=btTableSize)

    table.cell(bt_table, 0, 3, "Loss (SL)", text_color=color.gray, text_halign=text.align_left, text_size=btTableSize)
    table.cell(bt_table, 1, 3, str.tostring(bt_cLoss), text_color=color.red, text_halign=text.align_center, text_size=btTableSize)

    table.cell(bt_table, 0, 4, "Win Rate", text_color=color.gray, text_halign=text.align_left, text_size=btTableSize)
    table.cell(bt_table, 1, 4, str.tostring(math.round(bt_wr, 1)) + "%", text_color=bt_wr >= 50 ? color.green : color.red, text_halign=text.align_center, text_size=btTableSize)

    table.cell(bt_table, 0, 5, "Open", text_color=color.gray, text_halign=text.align_left, text_size=btTableSize)
    table.cell(bt_table, 1, 5, str.tostring(array.size(bt_ep)), text_color=color.gray, text_halign=text.align_center, text_size=btTableSize)

    table.cell(bt_table, 0, 6, "Mode", text_color=color.gray, text_halign=text.align_left, text_size=btTableSize)
    table.cell(bt_table, 1, 6, "Open+1" + (bt_block_in_trade ? " +Block" : "") + (bt_use_dist_filter ? " +Dist" : ""), text_color=color.gray, text_halign=text.align_center, text_size=btTableSize)

    table.cell(bt_table, 0, 7, "Total ATR", text_color=color.gray, text_halign=text.align_left, text_size=btTableSize)
    table.cell(bt_table, 1, 7, (bt_totalATR >= 0 ? "+" : "") + str.tostring(math.round(bt_totalATR, 2)) + " ATR", text_color=bt_totalATR >= 0 ? color.green : color.red, text_halign=text.align_center, text_size=btTableSize)

    table.cell(bt_table, 0, 8, "Edge/trade", text_color=color.gray, text_halign=text.align_left, text_size=btTableSize)
    table.cell(bt_table, 1, 8, (bt_edge >= 0 ? "+" : "") + str.tostring(math.round(bt_edge, 3)) + " ATR", text_color=bt_edge >= 0 ? color.green : color.red, text_halign=text.align_center, text_size=btTableSize)

    table.cell(bt_table, 0, 9, "Profit Factor", text_color=color.gray, text_halign=text.align_left, text_size=btTableSize)
    table.cell(bt_table, 1, 9, bt_sumLossATR > 0 ? str.tostring(math.round(bt_pf, 2)) : (bt_sumWinATR > 0 ? "∞" : "—"), text_color=bt_pf >= 1 ? color.green : color.red, text_halign=text.align_center, text_size=btTableSize)

// ALERTS

alertcondition(long_breakout and long_score >= min_confluence, title="LONG Breakout Signal", message="LONG breakout signal — score reached the minimum threshold.")
alertcondition(short_breakout and short_score >= min_confluence, title="SHORT Breakout Signal", message="SHORT breakout signal — score reached the minimum threshold.")
alertcondition((long_breakout and long_score >= min_confluence) or (short_breakout and short_score >= min_confluence), title="LONG or SHORT Breakout Signal", message="Breakout signal — score reached the minimum threshold ({{ticker}}, {{interval}}).")
````
