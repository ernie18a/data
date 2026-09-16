<!-- tradingview-pine-id: PUB;1b4d952d6e1048339887b07a5b844050 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# HTF Structure Lens

Source: https://www.tradingview.com/script/6f7Kw2ms-HTF-Structure-Lens/

## Description

HTF Structure Lens

HTF Structure Lens is a multi-timeframe market-structure workspace designed to bring higher-timeframe price action and structural events directly onto the active chart.

Rather than switching repeatedly between timeframes, the indicator displays up to six higher-timeframe candle sets alongside the structural information derived from those candles. Its purpose is to provide a single visual framework for following higher-timeframe liquidity, candle structure and changes in delivery while executing on a lower timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHY THESE FEATURES ARE COMBINED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The features in HTF Structure Lens are designed around the same higher-timeframe price structure rather than functioning as unrelated indicators.

The HTF candles provide the underlying price representation. Swing levels and liquidity sweeps identify where those candles interact with previous extremes. C2/C3 classification identifies specific sweep, closure and reversal behaviour within that structure. CISD provides a separate delivery-confirmation layer that can then be compared with those higher-timeframe events.

This allows a trader, for example, to observe a higher-timeframe liquidity sweep and C2 closure while simultaneously monitoring lower-timeframe CISD confirmation without changing charts.

The indicator is intended as a discretionary analysis tool. It does not automatically determine directional bias, entries, exits or trade recommendations.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MULTI-TIMEFRAME HTF CANDLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Display up to six independent higher-timeframe candle sets simultaneously.

Each set includes configurable:
• Timeframe
• Number of displayed candles
• Candle spacing and positioning
• Body, border and wick styling

The currently forming HTF candle updates as new price data becomes available. Completed HTF candles retain their completed OHLC structure.

Per-chart-timeframe visibility controls allow different HTF sets to be displayed depending on the timeframe currently being viewed.

An optional Automatic HTF Ladder can dynamically adjust selected HTFs as the chart timeframe changes.

Daily candles can also use selectable session-based boundaries, including Midnight, 08:30 and 09:30 New York time.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STRUCTURE AND SWINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HTF Structure Lens identifies structural information directly from the displayed higher-timeframe candles.

Swing highs and lows can be displayed with separate styling for potential and confirmed levels.

An optional equilibrium (EQ) line marks the midpoint of a candle's range.

Fair Value Gaps and Volume Imbalances can also be displayed within the HTF candle representation to provide additional context around price delivery.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
C2 CLOSURE AND C3 REVERSAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The indicator includes a three-candle fractal framework for classifying specific higher-timeframe candle behaviour.

C2 Closure
A bullish C2 occurs when price trades below the previous candle's low and subsequently closes back above that level. A bearish C2 occurs when price trades above the previous candle's high and subsequently closes back below that level. Outside candles that sweep both sides are excluded from C2 classification.

C3 Reversal
C3 logic identifies a separate body-engulfing reversal condition where the previous candle's body is engulfed without the corresponding liquidity sweep required for a C2. Continuation cases following an existing C2 are filtered so that standalone C3 reversals can be distinguished from continuation behaviour.

C2 and C3 labels can be displayed on the HTF candle representation and, optionally, on the underlying chart bar where the completed HTF event occurred.

Confirmed C2/C3 classifications use completed candle information.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
LIQUIDITY SWEEP VISUALIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HTF liquidity levels can be projected back onto the underlying chart so that the origin and eventual sweep of a higher-timeframe level can be seen directly within lower-timeframe price action.

Two modes are available:

Confirmed Sweeps — displays sweeps that subsequently close back through the relevant level, corresponding with C2 closure behaviour.

All Sweeps — displays any wick that trades through the relevant previous level regardless of the eventual candle close.

Sweep-line appearance is configurable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CISD — CHANGE IN STATE OF DELIVERY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HTF Structure Lens includes an independent CISD framework that can monitor up to three timeframes simultaneously.

Each CISD instance can use the current chart timeframe or a separately selected timeframe.

The display can include:
• Developing CISD level
• Confirmed CISD level
• Protected swing associated with the current delivery state

This allows lower-timeframe delivery changes to be viewed in the context of higher-timeframe structural events displayed by the rest of the indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HTF PERIOD BOUNDARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

An optional HTF Period Boundary marks the beginning of a selected higher-timeframe period directly on the underlying chart.

This can be used to visually align lower-timeframe price action with the opening of Daily, 4H or other selected HTF periods.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Independent alerts are available for:
• Bullish and bearish C2 Closures
• Bullish and bearish C3 Reversals
• CISD confirmations

C2/C3 alerts can be selected independently for the displayed higher timeframes.

Confirmed structural alerts are designed to trigger from completed candle information rather than developing HTF conditions.

Alert messages include relevant ticker, timeframe and directional information.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
REPAINTING / LIVE DATA BEHAVIOUR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

The currently forming HTF candles and developing structural levels update as new price information becomes available. This is intentional because they represent live, incomplete market structure.

Confirmed C2/C3 events and other completed-candle structural classifications use completed candle data and are not subsequently recalculated from changes to the live candle.

Users should therefore distinguish between developing visual information and confirmed structural events.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ORIGINALITY AND OPEN-SOURCE ATTRIBUTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HTF Structure Lens builds upon the open-source ICT HTF Candles (fadi) script by fadizeidan, which provided part of the original higher-timeframe candle visualization foundation. The original work is licensed under the Mozilla Public License 2.0.

This project substantially extends that foundation into a broader multi-timeframe structure-analysis environment. Additions and modifications include functionality such as C2/C3 structural classification, liquidity sweep tracking and chart projection, swing-state visualization, equilibrium levels, multi-timeframe CISD analysis, structural alerts, timeframe-dependent visibility, Automatic HTF Ladder behaviour, HTF period boundaries, and additional integration between higher-timeframe structure and the underlying chart.

The source code is published openly in accordance with TradingView's open-source reuse requirements and to preserve attribution to the original work.

Credit to fadizeidan for the open-source HTF candle foundation that contributed to the development of this project.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
USAGE AND LIMITATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HTF Structure Lens is designed for discretionary multi-timeframe analysis. Structural classifications such as C2, C3, sweeps and CISD represent defined price-action conditions; they should not be interpreted as automatic buy or sell signals.

Live HTF candles and developing levels can change until their respective periods close.

Users should test the indicator on the markets, sessions and timeframes relevant to their own analysis.

This indicator is provided for educational and informational purposes only and does not constitute financial advice. Historical price behaviour does not guarantee future results.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// HTF Structure Lens
//
// Portions of the higher-timeframe candle visualization framework are derived from:
// "ICT HTF Candles (fadi)" by fadizeidan.
//
// Original work by fadizeidan is licensed under the Mozilla Public License 2.0.
//
// HTF Structure Lens substantially extends that foundation with additional
// multi-timeframe structure analysis, including C2/C3 classification,
// liquidity sweep visualization, swing and equilibrium tools, CISD,
// alerts, timeframe visibility controls, Automatic HTF Ladder functionality,
// HTF period boundaries, and related integration features.
//
// Full attribution and project details are provided in the TradingView
// publication description.
//
// This script is published open-source in accordance with the applicable
// license and TradingView's open-source reuse requirements.


// This is a free and open-source Pine Script for TradingView.
// It is designed to help you analyze and trade multiple timeframes.
// It is not designed to be a complete trading system, but rather a tool to help you analyze and trade multiple timeframes.
//@version=6
indicator('HTF Structure Lens', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

type Candle
	float o
	float c
	float h
	float l
    int o_time
	int o_idx
	int c_idx
	int h_idx
	int l_idx
    string dow
	box body
	line wick_up
	line wick_down
    label dow_label
    line swing_high_line
    line swing_low_line
    line eq_line
    label c2c3_label
    label c2c3_chart_label
    line sweep_high_chart_line
    line sweep_low_chart_line

type Trace
	line o
	line c
	line h
	line l
	label o_l
	label c_l
	label h_l
	label l_l

type Imbalance
	box b
	int idx

type CandleSettings
	bool show
	string htf
	int max_display

type Settings
	int max_sets
	color bull_body
	color bull_border
	color bull_wick
	color bear_body
	color bear_border
	color bear_wick
	int offset
	int buffer
	int htf_buffer
	int width
	bool use_custom_daily
    string custom_daily
    bool daily_name
	bool trace_show
	color trace_o_color
	string trace_o_style
	int trace_o_size
	color trace_c_color
	string trace_c_style
	int trace_c_size
	color trace_h_color
	string trace_h_style
	int trace_h_size
	color trace_l_color
	string trace_l_style
	int trace_l_size
	string trace_anchor
	bool label_show
	color label_color
	string label_size
    string label_position
    string label_alignment
	bool fvg_show
	color fvg_color
	bool vi_show
	color vi_color
	bool htf_label_show
	color htf_label_color
	string htf_label_size
	bool htf_timer_show
	color htf_timer_color
	string htf_timer_size
    color dow_color
    string dow_size

type CandleSet
	array<Candle> candles
	array<Imbalance> imbalances
	CandleSettings settings
	label tfNameTop
    label tfNameBottom
	label tfTimerTop
    label tfTimerBottom

type Helper
	string name = 'Helper'

Settings settings = Settings.new()

var CandleSettings SettingsHTF1 = CandleSettings.new()
var CandleSettings SettingsHTF2 = CandleSettings.new()
var CandleSettings SettingsHTF3 = CandleSettings.new()
var CandleSettings SettingsHTF4 = CandleSettings.new()
var CandleSettings SettingsHTF5 = CandleSettings.new()
var CandleSettings SettingsHTF6 = CandleSettings.new()

var array<Candle> candles_1 = array.new<Candle>(0)
var array<Candle> candles_2 = array.new<Candle>(0)
var array<Candle> candles_3 = array.new<Candle>(0)
var array<Candle> candles_4 = array.new<Candle>(0)
var array<Candle> candles_5 = array.new<Candle>(0)
var array<Candle> candles_6 = array.new<Candle>(0)

var array<Imbalance> imbalances_1 = array.new<Imbalance>()
var array<Imbalance> imbalances_2 = array.new<Imbalance>()
var array<Imbalance> imbalances_3 = array.new<Imbalance>()
var array<Imbalance> imbalances_4 = array.new<Imbalance>()
var array<Imbalance> imbalances_5 = array.new<Imbalance>()
var array<Imbalance> imbalances_6 = array.new<Imbalance>()

var CandleSet htf1 = CandleSet.new()
htf1.settings := SettingsHTF1
htf1.candles := candles_1
htf1.imbalances := imbalances_1

var CandleSet htf2 = CandleSet.new()
htf2.settings := SettingsHTF2
htf2.candles := candles_2
htf2.imbalances := imbalances_2

var CandleSet htf3 = CandleSet.new()
htf3.settings := SettingsHTF3
htf3.candles := candles_3
htf3.imbalances := imbalances_3

var CandleSet htf4 = CandleSet.new()
htf4.settings := SettingsHTF4
htf4.candles := candles_4
htf4.imbalances := imbalances_4

var CandleSet htf5 = CandleSet.new()
htf5.settings := SettingsHTF5
htf5.candles := candles_5
htf5.imbalances := imbalances_5

var CandleSet htf6 = CandleSet.new()
htf6.settings := SettingsHTF6
htf6.candles := candles_6
htf6.imbalances := imbalances_6

//+------------------------------------------------------------------------------------------------------------+//
//+--- Settings                                                                                             ---+//
//+------------------------------------------------------------------------------------------------------------+//

string group_style              = "Styling  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_label              = "Label Settings  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_imbalance          = "Imbalance  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_trace              = "Trace  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

htf1.settings.show              := input.bool(true, 'HTF 1      ', inline = 'htf1')
htf_1                           = input.timeframe('15', '', inline = 'htf1')
htf1.settings.max_display       := input.int(4, '', inline = 'htf1')

htf2.settings.show              := input.bool(true, 'HTF 2      ', inline = 'htf2')
htf_2                           = input.timeframe('60', '', inline = 'htf2')
htf2.settings.max_display       := input.int(4, '', inline = 'htf2')

htf3.settings.show              := input.bool(true, 'HTF 3      ', inline = 'htf3')
htf_3                           = input.timeframe('240', '', inline = 'htf3')
htf3.settings.max_display       := input.int(4, '', inline = 'htf3')

htf4.settings.show              := input.bool(false, 'HTF 4      ', inline = 'htf4')
htf_4                           = input.timeframe('420', '', inline = 'htf4')
htf4.settings.max_display       := input.int(4, '', inline = 'htf4')

htf5.settings.show              := input.bool(false, 'HTF 5      ', inline = 'htf5')
htf_5                           = input.timeframe('1D', '', inline = 'htf5')
htf5.settings.max_display       := input.int(4, '', inline = 'htf5')

htf6.settings.show              := input.bool(false, 'HTF 6      ', inline = 'htf6')
htf_6                           = input.timeframe('1W', '', inline = 'htf6')
htf6.settings.max_display       := input.int(4, '', inline = 'htf6')

settings.max_sets               := input.int(6, 'Limit to next HTFs only', minval = 1, maxval = 6)

//+--- Automatic HTF Ladder ---+//
string group_autoladder = "Automatic HTF Ladder  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

auto_rung1 = input.timeframe('1', 'Rung 1 (smallest)', group=group_autoladder, inline='rung1', tooltip="These 8 rungs are just a menu of timeframe sizes, smallest to largest — they don't do anything by themselves. Below, check any HTF slot's Auto box and it will automatically pick from this list based on your current chart timeframe: HTF1 gets the first rung bigger than your chart, HTF2 gets the rung after that, HTF3 the one after that, and so on. Off by default — unchecked slots keep using their fixed timeframe as normal.")
auto_rung2 = input.timeframe('5', 'Rung 2', group=group_autoladder, inline='rung1')
auto_rung3 = input.timeframe('15', 'Rung 3', group=group_autoladder, inline='rung1')
auto_rung4 = input.timeframe('60', 'Rung 4', group=group_autoladder, inline='rung1')
auto_rung5 = input.timeframe('240', 'Rung 5', group=group_autoladder, inline='rung2')
auto_rung6 = input.timeframe('D', 'Rung 6', group=group_autoladder, inline='rung2')
auto_rung7 = input.timeframe('W', 'Rung 7', group=group_autoladder, inline='rung2')
auto_rung8 = input.timeframe('M', 'Rung 8 (largest)', group=group_autoladder, inline='rung2')

htf1_auto = input.bool(false, 'Auto: HTF 1', group=group_autoladder, inline='autotoggle1', tooltip="Check to make this HTF slot auto-pick from the rungs above instead of using its own fixed timeframe setting.")
htf2_auto = input.bool(false, 'Auto: HTF 2', group=group_autoladder, inline='autotoggle1')
htf3_auto = input.bool(false, 'Auto: HTF 3', group=group_autoladder, inline='autotoggle1')
htf4_auto = input.bool(false, 'Auto: HTF 4', group=group_autoladder, inline='autotoggle2')
htf5_auto = input.bool(false, 'Auto: HTF 5', group=group_autoladder, inline='autotoggle2')
htf6_auto = input.bool(false, 'Auto: HTF 6', group=group_autoladder, inline='autotoggle2')

f_auto_resolve_htf(int slotNum) =>
    array<float> rung_secs = array.new<float>()
    array.push(rung_secs, timeframe.in_seconds(auto_rung1))
    array.push(rung_secs, timeframe.in_seconds(auto_rung2))
    array.push(rung_secs, timeframe.in_seconds(auto_rung3))
    array.push(rung_secs, timeframe.in_seconds(auto_rung4))
    array.push(rung_secs, timeframe.in_seconds(auto_rung5))
    array.push(rung_secs, timeframe.in_seconds(auto_rung6))
    array.push(rung_secs, timeframe.in_seconds(auto_rung7))
    array.push(rung_secs, timeframe.in_seconds(auto_rung8))

    array<string> rung_tfs = array.new<string>()
    array.push(rung_tfs, auto_rung1)
    array.push(rung_tfs, auto_rung2)
    array.push(rung_tfs, auto_rung3)
    array.push(rung_tfs, auto_rung4)
    array.push(rung_tfs, auto_rung5)
    array.push(rung_tfs, auto_rung6)
    array.push(rung_tfs, auto_rung7)
    array.push(rung_tfs, auto_rung8)

    float cur_secs = timeframe.in_seconds()
    // Default to the top rung if the chart timeframe is already at or above
    // every customized rung (e.g. viewing a Monthly chart on default rungs).
    int base_idx = array.size(rung_secs) - 1
    for i = 0 to array.size(rung_secs) - 1
        if array.get(rung_secs, i) > cur_secs
            base_idx := i
            break

    int target_idx = math.min(base_idx + slotNum - 1, array.size(rung_tfs) - 1)
    array.get(rung_tfs, target_idx)

// Each slot's actual timeframe: the manual choice, or the ladder-resolved value
// when that slot's Auto toggle is on.
htf1.settings.htf := htf1_auto ? f_auto_resolve_htf(1) : htf_1
htf2.settings.htf := htf2_auto ? f_auto_resolve_htf(2) : htf_2
htf3.settings.htf := htf3_auto ? f_auto_resolve_htf(3) : htf_3
htf4.settings.htf := htf4_auto ? f_auto_resolve_htf(4) : htf_4
htf5.settings.htf := htf5_auto ? f_auto_resolve_htf(5) : htf_5
htf6.settings.htf := htf6_auto ? f_auto_resolve_htf(6) : htf_6

//+--- Per-Timeframe Visibility Settings ---+//
string group_tf_visibility = "Timeframe Visibility  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

// Chart TF 1: Enable, Timeframe, then which HTFs show on this TF
tf1_enabled = input.bool(false, 'TF 1', group=group_tf_visibility, inline='tf1', tooltip="Enable visibility control for this chart timeframe")
tf_slot_1 = input.timeframe('30S', '', group=group_tf_visibility, inline='tf1')
tf1_htf1 = input.bool(true, '1', group=group_tf_visibility, inline='tf1')
tf1_htf2 = input.bool(true, '2', group=group_tf_visibility, inline='tf1')
tf1_htf3 = input.bool(true, '3', group=group_tf_visibility, inline='tf1')
tf1_htf4 = input.bool(false, '4', group=group_tf_visibility, inline='tf1')
tf1_htf5 = input.bool(false, '5', group=group_tf_visibility, inline='tf1')
tf1_htf6 = input.bool(false, '6', group=group_tf_visibility, inline='tf1')

// Chart TF 2
tf2_enabled = input.bool(false, 'TF 2', group=group_tf_visibility, inline='tf2')
tf_slot_2 = input.timeframe('1', '', group=group_tf_visibility, inline='tf2')
tf2_htf1 = input.bool(false, '1', group=group_tf_visibility, inline='tf2')
tf2_htf2 = input.bool(true, '2', group=group_tf_visibility, inline='tf2')
tf2_htf3 = input.bool(true, '3', group=group_tf_visibility, inline='tf2')
tf2_htf4 = input.bool(false, '4', group=group_tf_visibility, inline='tf2')
tf2_htf5 = input.bool(false, '5', group=group_tf_visibility, inline='tf2')
tf2_htf6 = input.bool(false, '6', group=group_tf_visibility, inline='tf2')

// Chart TF 3
tf3_enabled = input.bool(false, 'TF 3', group=group_tf_visibility, inline='tf3')
tf_slot_3 = input.timeframe('3', '', group=group_tf_visibility, inline='tf3')
tf3_htf1 = input.bool(false, '1', group=group_tf_visibility, inline='tf3')
tf3_htf2 = input.bool(true, '2', group=group_tf_visibility, inline='tf3')
tf3_htf3 = input.bool(false, '3', group=group_tf_visibility, inline='tf3')
tf3_htf4 = input.bool(false, '4', group=group_tf_visibility, inline='tf3')
tf3_htf5 = input.bool(false, '5', group=group_tf_visibility, inline='tf3')
tf3_htf6 = input.bool(false, '6', group=group_tf_visibility, inline='tf3')

// Chart TF 4
tf4_enabled = input.bool(false, 'TF 4', group=group_tf_visibility, inline='tf4')
tf_slot_4 = input.timeframe('5', '', group=group_tf_visibility, inline='tf4')
tf4_htf1 = input.bool(false, '1', group=group_tf_visibility, inline='tf4')
tf4_htf2 = input.bool(false, '2', group=group_tf_visibility, inline='tf4')
tf4_htf3 = input.bool(false, '3', group=group_tf_visibility, inline='tf4')
tf4_htf4 = input.bool(true, '4', group=group_tf_visibility, inline='tf4')
tf4_htf5 = input.bool(false, '5', group=group_tf_visibility, inline='tf4')
tf4_htf6 = input.bool(false, '6', group=group_tf_visibility, inline='tf4')

// Chart TF 5
tf5_enabled = input.bool(false, 'TF 5', group=group_tf_visibility, inline='tf5')
tf_slot_5 = input.timeframe('15', '', group=group_tf_visibility, inline='tf5')
tf5_htf1 = input.bool(false, '1', group=group_tf_visibility, inline='tf5')
tf5_htf2 = input.bool(false, '2', group=group_tf_visibility, inline='tf5')
tf5_htf3 = input.bool(false, '3', group=group_tf_visibility, inline='tf5')
tf5_htf4 = input.bool(false, '4', group=group_tf_visibility, inline='tf5')
tf5_htf5 = input.bool(true, '5', group=group_tf_visibility, inline='tf5')
tf5_htf6 = input.bool(false, '6', group=group_tf_visibility, inline='tf5')

// Chart TF 6
tf6_enabled = input.bool(false, 'TF 6', group=group_tf_visibility, inline='tf6')
tf_slot_6 = input.timeframe('60', '', group=group_tf_visibility, inline='tf6')
tf6_htf1 = input.bool(false, '1', group=group_tf_visibility, inline='tf6')
tf6_htf2 = input.bool(false, '2', group=group_tf_visibility, inline='tf6')
tf6_htf3 = input.bool(false, '3', group=group_tf_visibility, inline='tf6')
tf6_htf4 = input.bool(false, '4', group=group_tf_visibility, inline='tf6')
tf6_htf5 = input.bool(true, '5', group=group_tf_visibility, inline='tf6')
tf6_htf6 = input.bool(true, '6', group=group_tf_visibility, inline='tf6')

// Helper function to check if HTF should be visible on current chart timeframe
// When on a configured TF, this OVERRIDES the main HTF enable setting
// defaultShow = the main htf.settings.show value (used when not on a configured TF)
isHTFVisibleOnCurrentTF(int htfNum, bool defaultShow) =>
    string currentTF = timeframe.period
    
    // Check if current TF matches any enabled visibility slot
    bool on_tf1 = tf1_enabled and currentTF == tf_slot_1
    bool on_tf2 = tf2_enabled and currentTF == tf_slot_2
    bool on_tf3 = tf3_enabled and currentTF == tf_slot_3
    bool on_tf4 = tf4_enabled and currentTF == tf_slot_4
    bool on_tf5 = tf5_enabled and currentTF == tf_slot_5
    bool on_tf6 = tf6_enabled and currentTF == tf_slot_6
    
    bool visible = defaultShow  // Default to main HTF setting
    
    // If we're on any of the configured TFs, OVERRIDE with that config (ignores main HTF enable)
    if on_tf1 or on_tf2 or on_tf3 or on_tf4 or on_tf5 or on_tf6
        if htfNum == 1
            visible := (on_tf1 and tf1_htf1) or (on_tf2 and tf2_htf1) or (on_tf3 and tf3_htf1) or (on_tf4 and tf4_htf1) or (on_tf5 and tf5_htf1) or (on_tf6 and tf6_htf1)
        else if htfNum == 2
            visible := (on_tf1 and tf1_htf2) or (on_tf2 and tf2_htf2) or (on_tf3 and tf3_htf2) or (on_tf4 and tf4_htf2) or (on_tf5 and tf5_htf2) or (on_tf6 and tf6_htf2)
        else if htfNum == 3
            visible := (on_tf1 and tf1_htf3) or (on_tf2 and tf2_htf3) or (on_tf3 and tf3_htf3) or (on_tf4 and tf4_htf3) or (on_tf5 and tf5_htf3) or (on_tf6 and tf6_htf3)
        else if htfNum == 4
            visible := (on_tf1 and tf1_htf4) or (on_tf2 and tf2_htf4) or (on_tf3 and tf3_htf4) or (on_tf4 and tf4_htf4) or (on_tf5 and tf5_htf4) or (on_tf6 and tf6_htf4)
        else if htfNum == 5
            visible := (on_tf1 and tf1_htf5) or (on_tf2 and tf2_htf5) or (on_tf3 and tf3_htf5) or (on_tf4 and tf4_htf5) or (on_tf5 and tf5_htf5) or (on_tf6 and tf6_htf5)
        else if htfNum == 6
            visible := (on_tf1 and tf1_htf6) or (on_tf2 and tf2_htf6) or (on_tf3 and tf3_htf6) or (on_tf4 and tf4_htf6) or (on_tf5 and tf5_htf6) or (on_tf6 and tf6_htf6)
    
    visible

settings.use_custom_daily       := input.bool(false, 'Custom daily candle open     ', inline='customdaily')
settings.custom_daily           := input.string('Midnight', '', options=['Midnight', '8:30', '9:30'], inline='customdaily')
settings.bull_body              := input.color(color.new(#e6e6e6, 10), 'Body  ', inline = 'body', group=group_style)
settings.bear_body              := input.color(color.new(#636363, 10), '', inline = 'body', group=group_style)
settings.bull_border            := input.color(color.new(#e6e6e6, 10), 'Borders', inline = 'borders', group=group_style)
settings.bear_border            := input.color(color.new(#636363, 10), '', inline = 'borders', group=group_style)
settings.bull_wick              := input.color(color.new(#e6e6e6, 10), 'Wick  ', inline = 'wick', group=group_style)
settings.bear_wick              := input.color(color.new(#636363, 10), '', inline = 'wick', group=group_style)

settings.offset                 := input.int(30, 'padding from current candles', minval = 1, group=group_style)
settings.buffer                 := input.int(1, 'space between candles', minval = 1, maxval = 4, group=group_style)
settings.htf_buffer             := input.int(10, 'space between Higher Timeframes', minval = 1, maxval = 10, group=group_style)
settings.width                  := input.int(1, 'Candle Width', minval = 1, maxval = 4, group=group_style) * 2

settings.htf_label_show         := input.bool(true, 'HTF Label           ', group=group_label, inline = 'HTFlabel')
settings.htf_label_color        := input.color(color.new(#e6e6e6, 10), '', group=group_label, inline = 'HTFlabel')
settings.htf_label_size         := input.string(size.normal, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'HTFlabel')
htf_label_bold                  = input.bool(false, title="Bold", group=group_label, inline="HTFlabel")

settings.label_position         := input.string("Top", 'Label Positions', options=['Both', 'Top', 'Bottom'], group=group_label)
settings.label_alignment        := input.string("Follow Candles", "Label Alignment", options=['Align', 'Follow Candles'], group=group_label)

settings.htf_timer_show         := input.bool(true, 'Remaining Time      ', inline = 'timer', group=group_label)
settings.htf_timer_color        := input.color(color.new(#e6e6e6, 10), '', inline = 'timer', group=group_label)
settings.htf_timer_size         := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'timer')

settings.daily_name             := input.bool(false, 'Candle Time        ', group=group_label, inline = 'dow')
settings.dow_color              := input.color(#0f0f0f , '', group=group_label, inline = 'dow')
settings.dow_size               := input.string(size.tiny, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'dow')

settings.fvg_show               := input.bool(true, 'Fair Value Gap   ', group = group_imbalance, inline = 'fvg')
settings.fvg_color              := input.color(color.new(#800080, 80), '', inline = 'fvg', group = group_imbalance)

settings.vi_show                := input.bool(false, 'Volume Imbalance', group = group_imbalance, inline = 'vi')
settings.vi_color               := input.color(color.new(color.red, 50), '', inline = 'vi', group = group_imbalance)

settings.trace_show             := input.bool(false, 'Trace lines', group = group_trace)
settings.trace_o_color          := input.color(color.new(color.gray, 50), 'Open    ', inline = '1', group = group_trace)
settings.trace_o_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '1', group = group_trace)
settings.trace_o_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '1', group = group_trace)
settings.trace_c_color          := input.color(color.new(color.gray, 50), 'Close    ', inline = '2', group = group_trace)
settings.trace_c_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '2', group = group_trace)
settings.trace_c_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '2', group = group_trace)
settings.trace_h_color          := input.color(color.new(color.gray, 50), 'High     ', inline = '3', group = group_trace)
settings.trace_h_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '3', group = group_trace)
settings.trace_h_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '3', group = group_trace)
settings.trace_l_color          := input.color(color.new(color.gray, 50), 'Low     ', inline = '4', group = group_trace)
settings.trace_l_style          := input.string('····', '', options = ['⎯⎯⎯', '----', '····'], inline = '4', group = group_trace)
settings.trace_l_size           := input.int(1, '', options = [1, 2, 3, 4], inline = '4', group = group_trace)
settings.trace_anchor           := input.string('First Timeframe', 'Anchor to', options = ['First Timeframe', 'Last Timeframe'], group = group_trace)

settings.label_show             := input.bool(false, 'Price Label           ', inline = 'label')
settings.label_color            := input.color(color.new(#0f0f0f, 10), '', inline = 'label')
settings.label_size             := input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], inline = 'label')

//+--- HTF Period Boundary Settings ---+//
string group_boundary = "HTF Period Boundary  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

show_htf_boundary = input.bool(false, 'Show HTF Period Boundary on Chart', group=group_boundary, tooltip="Draws a vertical line on the underlying price chart at the start of every period of the chosen timeframe — e.g. set to Daily to mark each day's open, works regardless of what chart timeframe you're viewing.")
htf_boundary_tf = input.timeframe('D', 'Boundary Timeframe', group=group_boundary)
htf_boundary_color = input.color(color.new(color.gray, 50), '', group=group_boundary, inline='boundarystyle')
htf_boundary_style = input.string('Dashed', '', options=['Solid', 'Dashed', 'Dotted'], group=group_boundary, inline='boundarystyle')
htf_boundary_width = input.int(1, '', minval=1, maxval=5, group=group_boundary, inline='boundarystyle')
htf_boundary_max_lines = input.int(50, 'Maximum boundary lines to keep', minval=1, maxval=200, group=group_boundary)

//+--- Swing Line Settings ---+//
string group_swing = "HTF Swings  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

show_swing_lines = input.bool(true, title="Show Swing Lines", group=group_swing, tooltip="Draws horizontal lines at swing highs and lows. Confirmed swings show when price swept a level and closed with rejection. Potential swings show when price is currently forming a sweep")
swing_line_width = input.int(1, title="Line Width", minval=1, maxval=5, group=group_swing)
confirmed_swing_style = input.string("Solid", title="Confirmed Swing Style", options=["Solid", "Dashed", "Dotted"], group=group_swing, tooltip="Style for confirmed swings (swept with rejection)")
potential_swing_style = input.string("Dashed", title="Potential Swing Style", options=["Solid", "Dashed", "Dotted"], group=group_swing, tooltip="Style for potential swings (currently forming)")
swing_high_color = input.color(color.new(#F23645, 0), title="High Line Color", group=group_swing, inline="swing_col")
swing_low_color = input.color(color.new(#F23645, 0), title="Low Line Color", group=group_swing, inline="swing_col")
swing_overshoot = input.int(1, title="Overshoot (bars)", minval=0, maxval=50, group=group_swing)

show_eq_line = input.bool(true, title="Show Equilibrium Line", group=group_swing)
eq_previous_only = input.bool(true, title="Only Show Previous Candle's EQ", group=group_swing, tooltip="When on, only the most recently closed candle draws an EQ line. When off, every closed candle draws its own EQ line.")
eq_line_color = input.color(color.new(color.white, 0), title="EQ Line Color", group=group_swing, inline="eq")
eq_line_width = input.int(1, title="Width", minval=1, maxval=5, group=group_swing, inline="eq")
eq_line_style_input = input.string("Dotted", title="Style", options=["Solid", "Dashed", "Dotted"], group=group_swing, inline="eq")

//+--- Divergence Settings ---+//
//+--- Alert Settings ---+//
string group_alerts = "Alerts  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

alert_c2_closure_enable = input.bool(true, title="C2 Closure Alerts (TTrades Fractal Model)", group=group_alerts, tooltip="Fires once, immediately when a HTF candle closes, if that candle (C2) swept the previous HTF candle's (C1) high or low and closed back inside its range. Uses only fully-closed candle data — cannot repaint.")
alert_c3_reversal_enable = input.bool(true, title="C3 Reversal Alerts (TTrades Fractal Model)", group=group_alerts, tooltip="Fires once, immediately when a HTF candle closes, if that candle did NOT sweep the previous candle's high/low, but its close pushed beyond the entire body of the previous candle (an engulfing reversal close). Uses only fully-closed candle data — cannot repaint.")
alert_cisd_enable = input.bool(false, title="CISD Confirmation Alerts", group=group_alerts, tooltip="Fires once when a CISD confirms on the selected CISD timeframe (see the CISD section below). Requires \"Show CISD\" to be on.")
alert_htf1_enable = input.bool(true, 'HTF 1', group=group_alerts, inline='alerthtfs1', tooltip="Which HTF slots should fire C2 Closure / C3 Reversal alerts")
alert_htf2_enable = input.bool(true, 'HTF 2', group=group_alerts, inline='alerthtfs1')
alert_htf3_enable = input.bool(true, 'HTF 3', group=group_alerts, inline='alerthtfs1')
alert_htf4_enable = input.bool(false, 'HTF 4', group=group_alerts, inline='alerthtfs2')
alert_htf5_enable = input.bool(false, 'HTF 5', group=group_alerts, inline='alerthtfs2')
alert_htf6_enable = input.bool(false, 'HTF 6', group=group_alerts, inline='alerthtfs2')
show_c2c3_offset_labels = input.bool(false, 'Show C2/C3 Labels on HTF Candles', group=group_alerts, inline='c2c3label')
c2c3_bull_color = input.color(#07db82, '', group=group_alerts, inline='c2c3label')
c2c3_bear_color = input.color(#F23645, '', group=group_alerts, inline='c2c3label')
show_c2c3_chart_labels = input.bool(false, 'Show C2/C3 Labels on Chart', group=group_alerts, tooltip="Places the same C2/C3 tags directly on the underlying price chart, anchored to the actual bar where each HTF candle closed — works regardless of what chart timeframe you're viewing.")
show_sweep_lines_on_chart = input.bool(false, 'Show HTF Sweeps on Chart', group=group_alerts, tooltip="Draws a line on the underlying price chart from where a HTF level (prior candle's high/low) was set to where it got swept — works regardless of what chart timeframe you're viewing.")
sweep_line_type = input.string('Confirmed (C2 Closures)', 'Sweep Type', options=['Confirmed (C2 Closures)', 'All Sweeps'], group=group_alerts, tooltip="Confirmed only draws a sweep line when the level was swept AND the candle closed back inside it (a C2 Closure). All Sweeps draws every wick that takes out a prior high/low, regardless of where it closed.")
sweep_line_color = input.color(color.white, '', group=group_alerts, inline='sweepline')
sweep_line_style = input.string('Dashed', '', options=['Solid', 'Dashed', 'Dotted'], group=group_alerts, inline='sweepline')
sweep_line_width = input.int(1, '', minval=1, maxval=5, group=group_alerts, inline='sweepline')

//+--- CISD Settings ---+//
string group_cisd = "CISD  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cisd_show = input.bool(false, 'Show CISD 1', group=group_cisd, inline='cisd1', tooltip="Change in State of Delivery: tracks the active delivery bias on a chosen timeframe and marks the level where price closes back through it (a CISD confirmation), plus the protected swing that invalidates it.")
cisd_tf_mode = input.string('Current Timeframe', '', options=['Current Timeframe', 'Custom'], group=group_cisd, inline='cisd1')
cisd_custom_tf = input.timeframe('60', '', group=group_cisd, inline='cisd1')
cisd2_show = input.bool(false, 'Show CISD 2', group=group_cisd, inline='cisd2', tooltip="A second, independent CISD tracked on its own timeframe.")
cisd2_tf = input.timeframe('15', '', group=group_cisd, inline='cisd2')
cisd3_show = input.bool(false, 'Show CISD 3', group=group_cisd, inline='cisd3', tooltip="A third, independent CISD tracked on its own timeframe.")
cisd3_tf = input.timeframe('60', '', group=group_cisd, inline='cisd3')
cisd_bull_color = input.color(color.lime, 'Bullish', group=group_cisd, inline='cisdcolor')
cisd_bear_color = input.color(color.red, 'Bearish', group=group_cisd, inline='cisdcolor')
cisd_show_developing = input.bool(false, 'Show developing level', group=group_cisd, tooltip="A short projected line at the current live delivery level, updating in real time until it either confirms or the bias resets. Applies to every enabled CISD.")
cisd_show_confirmed = input.bool(true, 'Show confirmed level', group=group_cisd, tooltip="A line marking the most recent confirmed CISD, from where the level originated to the candle that confirmed it. Applies to every enabled CISD.")
cisd_show_protected = input.bool(false, 'Show protected swing (PSL/PSH)', group=group_cisd, tooltip="Marks the swing that must hold for the most recent confirmed CISD to remain valid. Applies to every enabled CISD.")
cisd_line_width = input.int(2, 'Line width', minval=1, maxval=5, group=group_cisd)

cisd_resolved_tf = cisd_tf_mode == 'Current Timeframe' ? timeframe.period : cisd_custom_tf

// Convert swing settings
confirmed_swing_style_value = confirmed_swing_style == "Solid" ? line.style_solid : confirmed_swing_style == "Dashed" ? line.style_dashed : line.style_dotted
potential_swing_style_value = potential_swing_style == "Solid" ? line.style_solid : potential_swing_style == "Dashed" ? line.style_dashed : line.style_dotted
eq_line_style_value = eq_line_style_input == "Solid" ? line.style_solid : eq_line_style_input == "Dashed" ? line.style_dashed : line.style_dotted
sweep_line_style_value = sweep_line_style == "Solid" ? line.style_solid : sweep_line_style == "Dashed" ? line.style_dashed : line.style_dotted
htf_boundary_style_value = htf_boundary_style == "Solid" ? line.style_solid : htf_boundary_style == "Dashed" ? line.style_dashed : line.style_dotted

//+------------------------------------------------------------------------------------------------------------+//
//+--- Variables                                                                                            ---+//
//+------------------------------------------------------------------------------------------------------------+//

Helper helper = Helper.new()
var Trace trace = Trace.new()
color color_transparent = #ffffff00

//+------------------------------------------------------------------------------------------------------------+//
//+--- Internal Functions                                                                                   ---+//
//+------------------------------------------------------------------------------------------------------------+//

method LineStyle(Helper helper, string style) =>
    helper.name := style
    out = switch style
        '----' => line.style_dashed
        '····' => line.style_dotted
        => line.style_solid
    out

method DayofWeek(Helper helper, int index) =>
    helper.name := 'DOW'
    switch
        index == 1 => 'M'
        index == 2 => 'T'
        index == 3 => 'W'
        index == 4 => 'T'
        index == 5 => 'F'
        index == 6 => 'S'
        index == 7 => 'S'
        na(index) => ''

method ValidTimeframe(Helper helper, string HTF) =>
    helper.name := HTF
    if timeframe.in_seconds(HTF) >= timeframe.in_seconds('D') and timeframe.in_seconds(HTF) > timeframe.in_seconds()
        true
    else
        n1 = timeframe.in_seconds()
        n2 = timeframe.in_seconds(HTF)
        n1 < n2 and math.round(n2 / n1) == n2 / n1


method RemainingTime(Helper helper, string HTF) =>
    helper.name := HTF
    if barstate.isrealtime
        timeRemaining = (time_close(HTF) - timenow) / 1000
        days = math.floor(timeRemaining / 86400)
        hours = math.floor((timeRemaining - days * 86400) / 3600)
        minutes = math.floor((timeRemaining - days * 86400 - hours * 3600) / 60)
        seconds = math.floor(timeRemaining - days * 86400 - hours * 3600 - minutes * 60)

        r = str.tostring(seconds, '00')
        if minutes > 0 or hours > 0 or days > 0
            r := str.tostring(minutes, '00') + ':' + r
            r
        if hours > 0 or days > 0
            r := str.tostring(hours, '00') + ':' + r
            r
        if days > 0
            r := str.tostring(days) + 'D ' + r
            r
        r
    else
        'n/a'

method HTFName(Helper helper, string HTF) =>
    helper.name := 'HTFName'
    formatted = HTF

    seconds = timeframe.in_seconds(HTF)
    if seconds < 60
        formatted := str.tostring(seconds) + 's'
        formatted
    else if seconds / 60 < 60
        formatted := str.tostring(seconds / 60) + 'm'
        formatted
    else if seconds / 60 / 60 < 24
        formatted := str.tostring(seconds / 60 / 60) + 'H'
        formatted
    formatted

method HTFEnabled(Helper helper) =>
    helper.name := 'HTFEnabled'
    int enabled = 0
    enabled := enabled + (htf1.settings.show ? 1 : 0)
    enabled := enabled + (htf2.settings.show ? 1 : 0)
    enabled := enabled + (htf3.settings.show ? 1 : 0)
    enabled := enabled + (htf4.settings.show ? 1 : 0)
    enabled := enabled + (htf5.settings.show ? 1 : 0)
    enabled := enabled + (htf6.settings.show ? 1 : 0)
    int last = math.min(enabled, settings.max_sets)

    last

method CandleSetHigh(Helper helper, array<Candle> candles, float h) =>
    helper.name := 'CandlesSetHigh'
    float _h = h
    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.h > _h
                _h := c.h
                _h
    _h

method CandleSetLow(Helper helper, array<Candle> candles, float l) =>
    helper.name := 'CandlesSetLow'
    float _l = l
    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.l < _l
                _l := c.l
                _l
    _l

method CandlesHigh(Helper helper, array<Candle> candles) =>
    helper.name := 'CandlesHigh'
    h = 0.0
    int cnt = 0
    int last = helper.HTFEnabled()

    if isHTFVisibleOnCurrentTF(1, htf1.settings.show) and helper.ValidTimeframe(htf1.settings.htf)
        h := helper.CandleSetHigh(htf1.candles, h)
        cnt := cnt + 1
    if isHTFVisibleOnCurrentTF(2, htf2.settings.show) and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf2.candles, h)
        cnt := cnt + 1
    if isHTFVisibleOnCurrentTF(3, htf3.settings.show) and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf3.candles, h)
        cnt := cnt + 1
    if isHTFVisibleOnCurrentTF(4, htf4.settings.show) and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf4.candles, h)
        cnt := cnt + 1
    if isHTFVisibleOnCurrentTF(5, htf5.settings.show) and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf5.candles, h)
        cnt := cnt + 1
    if isHTFVisibleOnCurrentTF(6, htf6.settings.show) and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf6.candles, h)

    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.h > h
                h := c.h
    h

method CandlesLow(Helper helper, array<Candle> candles, float h) =>
    helper.name := 'CandlesLow'
    l = h
    int cnt = 0
    int last = helper.HTFEnabled()

    if isHTFVisibleOnCurrentTF(1, htf1.settings.show) and helper.ValidTimeframe(htf1.settings.htf)
        l := helper.CandleSetLow(htf1.candles, l)
        cnt := cnt + 1
    if isHTFVisibleOnCurrentTF(2, htf2.settings.show) and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf2.candles, l)
        cnt := cnt + 1
    if isHTFVisibleOnCurrentTF(3, htf3.settings.show) and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf3.candles, l)
        cnt := cnt + 1
    if isHTFVisibleOnCurrentTF(4, htf4.settings.show) and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf4.candles, l)
        cnt := cnt + 1
    if isHTFVisibleOnCurrentTF(5, htf5.settings.show) and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf5.candles, l)
        cnt := cnt + 1
    if isHTFVisibleOnCurrentTF(6, htf6.settings.show) and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf6.candles, l)

    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.l < l
                l := c.l
    l

method UpdateTime(CandleSet candleSet, int offset) =>
    // Always update timer on last bar for visibility after resume
    if settings.htf_timer_show and barstate.islast
        string tmr = '[' + helper.RemainingTime(candleSet.settings.htf) + ']'

        if not na(candleSet.tfTimerTop)
            candleSet.tfTimerTop.set_text(tmr)

        if not na(candleSet.tfTimerBottom)
            candleSet.tfTimerBottom.set_text(tmr)
    candleSet

method Reorder(CandleSet candleSet, int offset) =>
    size = candleSet.candles.size()

    if size > 0
        for i = size - 1 to 0 by 1
            Candle candle = candleSet.candles.get(i)
            t_buffer = offset + (settings.width + settings.buffer) * (size - i - 1)
            box.set_left(candle.body, bar_index + t_buffer)
            box.set_right(candle.body, bar_index + settings.width + t_buffer)
            line.set_x1(candle.wick_up, bar_index + settings.width / 2 + t_buffer)
            line.set_x2(candle.wick_up, bar_index + settings.width / 2 + t_buffer)
            line.set_x1(candle.wick_down, bar_index + settings.width / 2 + t_buffer)
            line.set_x2(candle.wick_down, bar_index + settings.width / 2 + t_buffer)

            if settings.daily_name //and candleSet.settings.htf == '1D'
                if not na(candle.dow_label)
                    candle.dow_label.set_y(candle.l)
                    candle.dow_label.set_x(bar_index + settings.width / 2 + t_buffer)
                    candle.dow_label.set_text(candle.dow)
                else
                    candle.dow_label := label.new(bar_index + settings.width / 2 + t_buffer, candle.l, candle.dow, color = color_transparent, textcolor = settings.dow_color, style = label.style_label_up, size = settings.dow_size, text_font_family = font.family_monospace)
            
            
            // Check if NEXT candle creates a swing on THIS candle (for drawing swing lines)
            // Include all candles except index 0 (most recent)
            if show_swing_lines and i >= 1
                Candle next_candle = candleSet.candles.get(i - 1)
                
                // Potential swing: next candle (forming) swept high, regardless of close position
                bool is_potential_high = i == 1 and next_candle.h > candle.h
                // Confirmed swing: next candle is closed and swept with rejection
                bool is_confirmed_high = i > 1 and next_candle.h > candle.h and next_candle.c < candle.h
                
                bool is_potential_low = i == 1 and next_candle.l < candle.l
                bool is_confirmed_low = i > 1 and next_candle.l < candle.l and next_candle.c > candle.l
                
                // Swing high line (show both potential and confirmed)
                if is_potential_high or is_confirmed_high
                    int next_buffer = offset + (settings.width + settings.buffer) * (size - (i - 1) - 1)
                    int line_start = bar_index + settings.width / 2 + t_buffer
                    int line_end = bar_index + next_buffer + settings.width + swing_overshoot
                    string line_style = is_confirmed_high ? confirmed_swing_style_value : potential_swing_style_value
                    
                    if na(candle.swing_high_line)
                        candle.swing_high_line := line.new(line_start, candle.h, line_end, candle.h, color=swing_high_color, width=swing_line_width, style=line_style)
                    else
                        line.set_x1(candle.swing_high_line, line_start)
                        line.set_y1(candle.swing_high_line, candle.h)
                        line.set_x2(candle.swing_high_line, line_end)
                        line.set_y2(candle.swing_high_line, candle.h)
                        line.set_style(candle.swing_high_line, line_style)
                else
                    // Delete only if confirmed closed candle invalidated the swing
                    if i > 1 and not na(candle.swing_high_line)
                        line.delete(candle.swing_high_line)
                        candle.swing_high_line := na
                
                // Swing low line (show both potential and confirmed)
                if is_potential_low or is_confirmed_low
                    int next_buffer = offset + (settings.width + settings.buffer) * (size - (i - 1) - 1)
                    int line_start = bar_index + settings.width / 2 + t_buffer
                    int line_end = bar_index + next_buffer + settings.width + swing_overshoot
                    string line_style = is_confirmed_low ? confirmed_swing_style_value : potential_swing_style_value
                    
                    if na(candle.swing_low_line)
                        candle.swing_low_line := line.new(line_start, candle.l, line_end, candle.l, color=swing_low_color, width=swing_line_width, style=line_style)
                    else
                        line.set_x1(candle.swing_low_line, line_start)
                        line.set_y1(candle.swing_low_line, candle.l)
                        line.set_x2(candle.swing_low_line, line_end)
                        line.set_y2(candle.swing_low_line, candle.l)
                        line.set_style(candle.swing_low_line, line_style)
                else
                    // Delete only if confirmed closed candle invalidated the swing
                    if i > 1 and not na(candle.swing_low_line)
                        line.delete(candle.swing_low_line)
                        candle.swing_low_line := na
            
            // Draw EQ line from each closed candle to the next candle
            // When eq_previous_only is on, only the most recently closed candle (i == 1) draws one
            bool draw_this_eq = show_eq_line and i >= 1 and size >= 2 and (not eq_previous_only or i == 1)
            if draw_this_eq
                // This candle's equilibrium (midpoint of high and low)
                float eq_price = (candle.h + candle.l) / 2
                
                // Line from right edge of this candle to left edge of next candle (toward index 0)
                int next_buffer = offset + (settings.width + settings.buffer) * (size - (i - 1) - 1)
                int line_start_x = bar_index + settings.width + t_buffer
                int line_end_x = bar_index + next_buffer + settings.width
                
                if na(candle.eq_line)
                    candle.eq_line := line.new(line_start_x, eq_price, line_end_x, eq_price, color=eq_line_color, width=eq_line_width, style=eq_line_style_value)
                else
                    line.set_x1(candle.eq_line, line_start_x)
                    line.set_y1(candle.eq_line, eq_price)
                    line.set_x2(candle.eq_line, line_end_x)
                    line.set_y2(candle.eq_line, eq_price)
            else
                // Clean up EQ lines on candles that shouldn't have one right now
                // (e.g. a candle that used to be index 1 but has since shifted back)
                if not na(candle.eq_line)
                    line.delete(candle.eq_line)
                    candle.eq_line := na

            // --- TTrades Fractal Model: C2 / C3 tag on already-closed candles ---
            // Only ever evaluated on fully closed candles (i >= 1) against the closed
            // candle right before them (i + 1) — the exact same pair the live alerts
            // use. The still-forming candle (i == 0) is never tagged, since its close
            // can still change and a tag would have to repaint.
            if i >= 1 and i + 1 <= size - 1
                Candle refc = candleSet.candles.get(i + 1)
                // If a candle sweeps BOTH the prior high and low (an outside bar), neither
                // direction is a clean signal — suppress both rather than firing a
                // contradictory bull + bear tag on the same candle.
                bool swept_both_c2 = candle.l < refc.l and candle.h > refc.h
                bool bull_c2_tag = candle.l < refc.l and candle.c > refc.l and not swept_both_c2
                bool bear_c2_tag = candle.h > refc.h and candle.c < refc.h and not swept_both_c2

                // On-chart sweep visualization: a raw fact ("this level got taken out
                // here"), independent of whether it went on to become a C2/C3 or not —
                // drawn from the real bar where the level was set to the real bar where
                // it was swept, using xloc=bar_index so it works on any chart timeframe.
                bool low_swept_raw = candle.l < refc.l
                bool high_swept_raw = candle.h > refc.h
                bool confirmed_sweeps_only = sweep_line_type == 'Confirmed (C2 Closures)'
                // bull_c2_tag / bear_c2_tag (computed above) already ARE "swept and
                // closed back inside" per side — reuse them directly as the confirmed case.
                bool low_swept = confirmed_sweeps_only ? bull_c2_tag : low_swept_raw
                bool high_swept = confirmed_sweeps_only ? bear_c2_tag : high_swept_raw

                if show_sweep_lines_on_chart and low_swept
                    if na(candle.sweep_low_chart_line)
                        candle.sweep_low_chart_line := line.new(refc.l_idx, refc.l, candle.l_idx, refc.l, xloc=xloc.bar_index, color=sweep_line_color, width=sweep_line_width, style=sweep_line_style_value)
                    else
                        line.set_xy1(candle.sweep_low_chart_line, refc.l_idx, refc.l)
                        line.set_xy2(candle.sweep_low_chart_line, candle.l_idx, refc.l)
                        line.set_color(candle.sweep_low_chart_line, sweep_line_color)
                        line.set_width(candle.sweep_low_chart_line, sweep_line_width)
                        line.set_style(candle.sweep_low_chart_line, sweep_line_style_value)
                else
                    if not na(candle.sweep_low_chart_line)
                        line.delete(candle.sweep_low_chart_line)
                        candle.sweep_low_chart_line := na

                if show_sweep_lines_on_chart and high_swept
                    if na(candle.sweep_high_chart_line)
                        candle.sweep_high_chart_line := line.new(refc.h_idx, refc.h, candle.h_idx, refc.h, xloc=xloc.bar_index, color=sweep_line_color, width=sweep_line_width, style=sweep_line_style_value)
                    else
                        line.set_xy1(candle.sweep_high_chart_line, refc.h_idx, refc.h)
                        line.set_xy2(candle.sweep_high_chart_line, candle.h_idx, refc.h)
                        line.set_color(candle.sweep_high_chart_line, sweep_line_color)
                        line.set_width(candle.sweep_high_chart_line, sweep_line_width)
                        line.set_style(candle.sweep_high_chart_line, sweep_line_style_value)
                else
                    if not na(candle.sweep_high_chart_line)
                        line.delete(candle.sweep_high_chart_line)
                        candle.sweep_high_chart_line := na

                // A candle only counts as a standalone C3 Reversal in a given direction if
                // the candle right before it (refc) did NOT itself confirm a C2 Closure in
                // that SAME direction — that would just be the tail end of the C2 move (a
                // "Continuation C3"), not an independent signal. An opposite-direction
                // engulf right after a C2 (i.e. the C2 immediately failing) is a different,
                // still-valid signal and must not be suppressed by this exclusion.
                bool refc_bull_c2 = false
                bool refc_bear_c2 = false
                if i + 2 <= size - 1
                    Candle refc2 = candleSet.candles.get(i + 2)
                    refc_bull_c2 := refc.l < refc2.l and refc.c > refc2.l
                    refc_bear_c2 := refc.h > refc2.h and refc.c < refc2.h

                float refc_body_top = math.max(refc.o, refc.c)
                float refc_body_bottom = math.min(refc.o, refc.c)
                // True engulfing requires the whole body to span across and beyond refc's
                // body — open on one side, close on the other — not just the close poking
                // through, which would also fire on a small candle sitting entirely below/
                // above the range.
                bool bull_c3_tag = refc.c < refc.o and candle.l >= refc.l and candle.o <= refc_body_bottom and candle.c > refc_body_top and not refc_bull_c2
                bool bear_c3_tag = refc.c > refc.o and candle.h <= refc.h and candle.o >= refc_body_top and candle.c < refc_body_bottom and not refc_bear_c2

                string tag_text = na
                color tag_color = na
                bool tag_is_bear = false
                if bull_c2_tag or bear_c2_tag
                    tag_text := "C2"
                    tag_is_bear := bear_c2_tag
                    tag_color := bear_c2_tag ? c2c3_bear_color : c2c3_bull_color
                else if bull_c3_tag or bear_c3_tag
                    tag_text := "C3"
                    tag_is_bear := bear_c3_tag
                    tag_color := bear_c3_tag ? c2c3_bear_color : c2c3_bull_color

                // Label under the offset HTF candle
                if show_c2c3_offset_labels and not na(tag_text)
                    float off_label_y = candle.l - (candle.h - candle.l) * 0.15
                    int off_label_x = bar_index + settings.width / 2 + t_buffer
                    if na(candle.c2c3_label)
                        candle.c2c3_label := label.new(off_label_x, off_label_y, tag_text, color=color_transparent, textcolor=tag_color, style=label.style_label_up, size=size.tiny, text_font_family=font.family_monospace)
                    else
                        candle.c2c3_label.set_xy(off_label_x, off_label_y)
                        candle.c2c3_label.set_text(tag_text)
                        candle.c2c3_label.set_textcolor(tag_color)
                else
                    if not na(candle.c2c3_label)
                        label.delete(candle.c2c3_label)
                        candle.c2c3_label := na

                // Label on the actual chart, at the real bar where this HTF candle closed
                if show_c2c3_chart_labels and not na(tag_text)
                    float chart_label_y = tag_is_bear ? candle.h : candle.l
                    string chart_label_style = tag_is_bear ? label.style_label_down : label.style_label_up
                    if na(candle.c2c3_chart_label)
                        candle.c2c3_chart_label := label.new(candle.c_idx, chart_label_y, tag_text, xloc=xloc.bar_index, color=color_transparent, textcolor=tag_color, style=chart_label_style, size=size.tiny, text_font_family=font.family_monospace)
                    else
                        candle.c2c3_chart_label.set_xy(candle.c_idx, chart_label_y)
                        candle.c2c3_chart_label.set_text(tag_text)
                        candle.c2c3_chart_label.set_textcolor(tag_color)
                else
                    if not na(candle.c2c3_chart_label)
                        label.delete(candle.c2c3_chart_label)
                        candle.c2c3_chart_label := na
    
    top = 0.0
    bottom = 0.0

    if settings.label_alignment == 'Align'
        top := helper.CandlesHigh(candleSet.candles)
        bottom := helper.CandlesLow(candleSet.candles, top)
    if settings.label_alignment == 'Follow Candles'
        top := helper.CandleSetHigh(candleSet.candles, 0)
        bottom := helper.CandleSetLow(candleSet.candles, top)

    left = bar_index + offset + (settings.width + settings.buffer) * (size - 1) / 2

    // Always update labels on last bar for visibility after resume
    if settings.htf_label_show and barstate.islast
        string lblt = helper.HTFName(candleSet.settings.htf)
        
        // Add swing icons if applicable.
        // NOTE: candle at index 0 is the currently forming candle, so any swing it
        // creates against candle 1 (the last closed candle) is inherently POTENTIAL,
        // never confirmed, until candle 0 itself closes. Using outlined icons here
        // keeps this consistent with the swing-line logic above.
        if candleSet.candles.size() >= 2
            Candle last_candle = candleSet.candles.get(1)
            Candle current_candle = candleSet.candles.get(0)
            
            // Check for swing high (potential only - current_candle hasn't closed)
            bool high_broken = current_candle.h > last_candle.h
            bool close_rejected_high = current_candle.c < last_candle.h
            bool potential_swing_high = high_broken
            
            // Check for swing low (potential only - current_candle hasn't closed)
            bool low_broken = current_candle.l < last_candle.l
            bool close_rejected_low = current_candle.c > last_candle.l
            bool potential_swing_low = low_broken
            
            // Add appropriate icons (outlined = potential, since candle 0 is still forming)
            if potential_swing_high
                lblt := lblt + " ▽"
            
            if potential_swing_low
                lblt := lblt + " △"
        
        string lbll = lblt
        if settings.htf_timer_show
            lblt := lblt + '\n'
            lbll := '\n' + lbll
        if settings.daily_name
            lblt := lblt + '\n'

        string tmr = '[' + helper.RemainingTime(candleSet.settings.htf) + ']' + (settings.daily_name ? '\n' : '')
        if settings.label_position == 'Both' or settings.label_position == 'Top'
            
            if not na(candleSet.tfNameTop)
                candleSet.tfNameTop.set_xy(left, top)
                candleSet.tfNameTop.set_text(lblt)  // Update text to include swing icons
            else
                if htf_label_bold
                    candleSet.tfNameTop := label.new(left, top, lblt, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_down, size = settings.htf_label_size, text_font_family = font.family_monospace, text_formatting = text.format_bold)
                else
                    candleSet.tfNameTop := label.new(left, top, lblt, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_down, size = settings.htf_label_size, text_font_family = font.family_monospace)
            if settings.htf_timer_show
                if not na(candleSet.tfTimerTop)
                    candleSet.tfTimerTop.set_xy(left, top)
                else
                    candleSet.tfTimerTop := label.new(left, top, tmr, color = color_transparent, textcolor = settings.htf_timer_color, style = label.style_label_down, size = settings.htf_timer_size, text_font_family = font.family_monospace)

        if settings.label_position == 'Both' or settings.label_position == 'Bottom'
            if not na(candleSet.tfNameBottom)
                candleSet.tfNameBottom.set_xy(left, bottom)
                candleSet.tfNameBottom.set_text(lbll)  // Update text to include swing icons
            else
                if htf_label_bold
                    candleSet.tfNameBottom := label.new(left, bottom, lbll, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_up, size = settings.htf_label_size, text_font_family = font.family_monospace, text_formatting = text.format_bold)
                else
                    candleSet.tfNameBottom := label.new(left, bottom, lbll, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_up, size = settings.htf_label_size, text_font_family = font.family_monospace)
            if settings.htf_timer_show
                if settings.htf_timer_show
                    if not na(candleSet.tfTimerBottom)
                        candleSet.tfTimerBottom.set_xy(left, bottom)
                    else
                        candleSet.tfTimerBottom := label.new(left, bottom, tmr, color = color_transparent, textcolor = settings.htf_timer_color, style = label.style_label_up, size = settings.htf_timer_size)

    candleSet

method FindImbalance(CandleSet candleSet) =>
    // Always run on last bar to ensure visibility after resume
    if barstate.islast
        if candleSet.imbalances.size() > 0
            for i = candleSet.imbalances.size() - 1 to 0 by 1
                Imbalance del = candleSet.imbalances.get(i)
                box.delete(del.b)
                candleSet.imbalances.pop()

        if candleSet.candles.size() > 3 and settings.fvg_show
            for i = 0 to candleSet.candles.size() - 3 by 1
                candle1 = candleSet.candles.get(i)
                candle2 = candleSet.candles.get(i + 2)
                candle3 = candleSet.candles.get(i + 1)

                if candle1.l > candle2.h and math.min(candle1.o, candle1.c) > math.max(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_left(candle2.body), candle2.h, box.get_right(candle1.body), candle1.l, bgcolor = settings.fvg_color, border_color = color_transparent, xloc = xloc.bar_index)
                    candleSet.imbalances.push(imb)
                if candle1.h < candle2.l and math.max(candle1.o, candle1.c) < math.min(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_right(candle1.body), candle1.h, box.get_left(candle2.body), candle2.l, bgcolor = settings.fvg_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
                box temp = box.copy(candle3.body)
                box.delete(candle3.body)
                candle3.body := temp
                candle3.body

        if candleSet.candles.size() > 2 and settings.vi_show
            for i = 0 to candleSet.candles.size() - 2 by 1
                candle1 = candleSet.candles.get(i)
                candle2 = candleSet.candles.get(i + 1)
                if candle1.l < candle2.h and math.min(candle1.o, candle1.c) > math.max(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_left(candle2.body), math.min(candle1.o, candle1.c), box.get_right(candle1.body), math.max(candle2.o, candle2.c), bgcolor = settings.vi_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
                if candle1.h > candle2.l and math.max(candle1.o, candle1.c) < math.min(candle2.o, candle2.c)
                    Imbalance imb = Imbalance.new()
                    imb.b := box.new(box.get_right(candle1.body), math.min(candle2.o, candle2.c), box.get_left(candle2.body), math.max(candle1.o, candle1.c), bgcolor = settings.vi_color, border_color = color_transparent)
                    candleSet.imbalances.push(imb)
    candleSet

method Monitor(CandleSet candleSet, bool alertEnabled) =>
    HTFBarTime = time(candleSet.settings.htf, 'america/New_York')
    isNewHTFCandle = ta.change(HTFBarTime) > 0

    if settings.use_custom_daily
        if candleSet.settings.htf == '1D'
            if settings.custom_daily == 'Midnight'
                isNewHTFCandle := dayofweek(time, 'America/New_York') != dayofweek(time - (time - time[1]), 'America/New_York')
            if settings.custom_daily == '8:30'    
                // Get 8:30 AM New York time for today 
                isNewHTFCandle := not na(time(timeframe.period, "0830-0831:123456", 'America/New_York')) and na(time(timeframe.period, "0830-0831:123456", 'America/New_York')[1])
            if settings.custom_daily == '9:30'    
                // Get 9:30 AM New York time for today 
                isNewHTFCandle := not na(time(timeframe.period, "0930-0931:123456", 'America/New_York')) and na(time(timeframe.period, "0930-0931:123456", 'America/New_York')[1])
    if isNewHTFCandle
        Candle candle = Candle.new()
        candle.o := open
        candle.c := close
        candle.h := high
        candle.l := low
        candle.o_time := time
        candle.o_idx := bar_index
        candle.c_idx := bar_index
        candle.h_idx := bar_index
        candle.l_idx := bar_index
        candle.dow := switch
            candleSet.settings.htf == '1D' =>
                helper.DayofWeek(dayofweek(time_tradingday, "America/New_York"))
            str.tonumber(candleSet.settings.htf) < 60 =>
                str.format_time(candle.o_time, 'HH:mm', 'America/New_York')
            str.tonumber(candleSet.settings.htf) >= 60 =>
                str.format_time(candle.o_time, 'HH:mm', 'America/New_York')
            candleSet.settings.htf == '1M' =>
                str.format_time(candle.o_time, 'M', 'America/New_York')
            =>
                ''
        log.info('dow: {1} |{0}|', candle.dow, candleSet.settings.htf)
        bull = candle.c > candle.o

        candle.body := box.new(bar_index, math.max(candle.o, candle.c), bar_index + 2, math.min(candle.o, candle.c), bull ? settings.bull_border : settings.bear_border, 1, bgcolor = bull ? settings.bull_body : settings.bear_body)
        candle.wick_up := line.new(bar_index + 1, candle.h, bar_index, math.max(candle.o, candle.c), color = bull ? settings.bull_wick : settings.bear_wick)
        candle.wick_down := line.new(bar_index + 1, math.min(candle.o, candle.c), bar_index, candle.l, color = bull ? settings.bull_wick : settings.bear_wick)

        candleSet.candles.unshift(candle)

        // --- TTrades Fractal Model: C2 Closure / C3 Reversal Alerts ---
        // At this exact instant, the candle that just finished (now at index 1) is
        // permanently locked in — Update() only ever mutates index 0 going forward.
        // So these checks can never repaint: once fired, the values behind them are final.
        if (alert_c2_closure_enable or alert_c3_reversal_enable) and alertEnabled and candleSet.candles.size() >= 3
            Candle cur = candleSet.candles.get(1)   // the candle that just closed
            Candle prev = candleSet.candles.get(2)  // the candle immediately before it

            string htf_name = helper.HTFName(candleSet.settings.htf)

            // Computed once, unconditionally, so C3 can defer to C2's precedence below
            // even if the C2 alert toggle itself happens to be off.
            // If cur swept BOTH the prior high and low (an outside bar), neither direction
            // is a clean signal — suppress both rather than firing contradictory alerts.
            bool swept_both_c2 = cur.l < prev.l and cur.h > prev.h
            bool bull_c2_closure = cur.l < prev.l and cur.c > prev.l and not swept_both_c2
            bool bear_c2_closure = cur.h > prev.h and cur.c < prev.h and not swept_both_c2

            if alert_c2_closure_enable
                // C2 Closure: swept prev's low/high, closed back inside its range
                if bull_c2_closure
                    alert(syminfo.ticker + ' ' + htf_name + ' C2 Closure (Bullish) — swept prior low, closed back inside range', alert.freq_once_per_bar_close)
                if bear_c2_closure
                    alert(syminfo.ticker + ' ' + htf_name + ' C2 Closure (Bearish) — swept prior high, closed back inside range', alert.freq_once_per_bar_close)

            if alert_c3_reversal_enable
                // C3 Reversal: did NOT sweep prev's low/high, but closed beyond prev's entire body.
                // Excludes only the SAME-direction case where prev was itself a confirmed C2
                // Closure — that's the tail end of a C2 move (a "Continuation C3"), not a
                // standalone reversal. An opposite-direction engulf right after a C2 (the C2
                // failing) is a different, still-valid signal and is not suppressed.
                //
                // Also excludes the rare case where THIS SAME candle also qualifies as a C2
                // Closure in the opposite direction — a candle cannot be both at once, and
                // C2 takes precedence (matching the same priority the on-chart labels use).
                bool prev_bull_c2 = false
                bool prev_bear_c2 = false
                if candleSet.candles.size() >= 4
                    Candle prev2 = candleSet.candles.get(3)
                    prev_bull_c2 := prev.l < prev2.l and prev.c > prev2.l
                    prev_bear_c2 := prev.h > prev2.h and prev.c < prev2.h

                float prev_body_top = math.max(prev.o, prev.c)
                float prev_body_bottom = math.min(prev.o, prev.c)
                // True engulfing: cur's whole body spans across and beyond prev's body
                bool bull_c3_reversal = prev.c < prev.o and cur.l >= prev.l and cur.o <= prev_body_bottom and cur.c > prev_body_top and not prev_bull_c2 and not bull_c2_closure and not bear_c2_closure
                bool bear_c3_reversal = prev.c > prev.o and cur.h <= prev.h and cur.o >= prev_body_top and cur.c < prev_body_bottom and not prev_bear_c2 and not bull_c2_closure and not bear_c2_closure
                if bull_c3_reversal
                    alert(syminfo.ticker + ' ' + htf_name + ' C3 Reversal (Bullish) — engulfing close over prior body, no sweep', alert.freq_once_per_bar_close)
                if bear_c3_reversal
                    alert(syminfo.ticker + ' ' + htf_name + ' C3 Reversal (Bearish) — engulfing close below prior body, no sweep', alert.freq_once_per_bar_close)

        if candleSet.candles.size() > candleSet.settings.max_display
            Candle delCandle = array.pop(candleSet.candles)
            box.delete(delCandle.body)
            line.delete(delCandle.wick_up)
            line.delete(delCandle.wick_down)
            if not na(delCandle.dow_label)
                label.delete(delCandle.dow_label)
            if not na(delCandle.swing_high_line)
                line.delete(delCandle.swing_high_line)
            if not na(delCandle.swing_low_line)
                line.delete(delCandle.swing_low_line)
            if not na(delCandle.eq_line)
                line.delete(delCandle.eq_line)
            if not na(delCandle.c2c3_label)
                label.delete(delCandle.c2c3_label)
            if not na(delCandle.c2c3_chart_label)
                label.delete(delCandle.c2c3_chart_label)
            if not na(delCandle.sweep_high_chart_line)
                line.delete(delCandle.sweep_high_chart_line)
            if not na(delCandle.sweep_low_chart_line)
                line.delete(delCandle.sweep_low_chart_line)

    candleSet

method Update(CandleSet candleSet, int offset, bool showTrace) =>
    if candleSet.candles.size() > 0
        Candle candle = candleSet.candles.first()
        candle.h_idx := high > candle.h ? bar_index : candle.h_idx
        candle.h := high > candle.h ? high : candle.h
        candle.l_idx := low < candle.l ? bar_index : candle.l_idx
        candle.l := low < candle.l ? low : candle.l
        candle.c := close
        candle.c_idx := bar_index

        bull = candle.c > candle.o

        box.set_top(candle.body, candle.o)
        box.set_bottom(candle.body, candle.c)
        box.set_bgcolor(candle.body, bull ? settings.bull_body : settings.bear_body)
        box.set_border_color(candle.body, bull ? settings.bull_border : settings.bear_border)
        line.set_color(candle.wick_up, bull ? settings.bull_wick : settings.bear_wick)
        line.set_color(candle.wick_down, bull ? settings.bull_wick : settings.bear_wick)
        line.set_y1(candle.wick_up, candle.h)
        line.set_y2(candle.wick_up, math.max(candle.o, candle.c))
        line.set_y1(candle.wick_down, candle.l)
        line.set_y2(candle.wick_down, math.min(candle.o, candle.c))

        // Always reorder candles to ensure visibility even after resume/refresh
        candleSet.Reorder(offset)
        
        if barstate.isrealtime or barstate.islast
            if settings.trace_show and showTrace
                if bar_index - candle.o_idx < 5000
                    if na(trace.o)
                        trace.o := line.new(candle.o_idx, candle.o, box.get_left(candle.body), candle.o, xloc = xloc.bar_index, color = settings.trace_o_color, style = helper.LineStyle(settings.trace_o_style), width = settings.trace_o_size)
                        trace.o
                    else
                        line.set_xy1(trace.o, candle.o_idx, candle.o)
                        line.set_xy2(trace.o, box.get_left(candle.body), candle.o)

                    if settings.label_show
                        if na(trace.o_l)
                            trace.o_l := label.new(box.get_right(candle.body), candle.o, str.tostring(candle.o), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.o_l
                        else
                            label.set_xy(trace.o_l, box.get_right(candle.body), candle.o)
                            label.set_text(trace.o_l, str.tostring(candle.o))

                if bar_index - candle.c_idx < 5000
                    if na(trace.c)
                        trace.c := line.new(candle.c_idx, candle.c, box.get_left(candle.body), candle.c, xloc = xloc.bar_index, color = settings.trace_c_color, style = helper.LineStyle(settings.trace_c_style), width = settings.trace_c_size)
                        trace.c
                    else
                        line.set_xy1(trace.c, candle.c_idx, candle.c)
                        line.set_xy2(trace.c, box.get_left(candle.body), candle.c)

                    if settings.label_show
                        if na(trace.c_l)
                            trace.c_l := label.new(box.get_right(candle.body), candle.c, str.tostring(candle.c), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.c_l
                        else
                            label.set_xy(trace.c_l, box.get_right(candle.body), candle.c)
                            label.set_text(trace.c_l, str.tostring(candle.c))

                if bar_index - candle.h_idx < 5000
                    if na(trace.h)
                        trace.h := line.new(candle.h_idx, candle.h, line.get_x1(candle.wick_up), candle.h, xloc = xloc.bar_index, color = settings.trace_h_color, style = helper.LineStyle(settings.trace_h_style), width = settings.trace_h_size)
                        trace.h
                    else
                        line.set_xy1(trace.h, candle.h_idx, candle.h)
                        line.set_xy2(trace.h, line.get_x1(candle.wick_up), candle.h)

                    if settings.label_show
                        if na(trace.h_l)
                            trace.h_l := label.new(box.get_right(candle.body), candle.h, str.tostring(candle.h), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.h_l
                        else
                            label.set_xy(trace.h_l, box.get_right(candle.body), candle.h)
                            label.set_text(trace.h_l, str.tostring(candle.h))

                if bar_index - candle.l_idx < 5000
                    if na(trace.l)
                        trace.l := line.new(candle.l_idx, candle.l, line.get_x1(candle.wick_down), candle.l, xloc = xloc.bar_index, color = settings.trace_l_color, style = helper.LineStyle(settings.trace_l_style), width = settings.trace_l_size)
                        trace.l
                    else
                        line.set_xy1(trace.l, candle.l_idx, candle.l)
                        line.set_xy2(trace.l, line.get_x1(candle.wick_down), candle.l)

                    if settings.label_show
                        if na(trace.l_l)
                            trace.l_l := label.new(box.get_right(candle.body), candle.l, str.tostring(candle.l), textalign = text.align_center, style = label.style_label_left, size = settings.label_size, color = color_transparent, textcolor = settings.label_color)
                            trace.l_l
                        else
                            label.set_xy(trace.l_l, box.get_right(candle.body), candle.l)
                            label.set_text(trace.l_l, str.tostring(candle.l))
    candleSet

method DetectSwings(CandleSet candleSet) =>
    // Check candles (excluding the most recent at index 0) and create/delete swing lines
    if candleSet.candles.size() >= 2
        // Start from index 1 (skip index 0 which is the most recent/forming candle)
        for i = 1 to candleSet.candles.size() - 1
            Candle this_candle = candleSet.candles.get(i)
            Candle next_candle = candleSet.candles.get(i - 1)  // Next candle (toward index 0 = more recent)
            
            // For deletion logic, check if swing is invalidated
            // For index 1: Don't delete (next candle is forming - potential swing)
            // For index > 1: Delete only if closed candle invalidated (didn't reject)
            
            if i > 1
                // Confirmed swing high: swept with rejection
                bool is_swing_high = next_candle.h > this_candle.h and next_candle.c < this_candle.h
                // Confirmed swing low: swept with rejection
                bool is_swing_low = next_candle.l < this_candle.l and next_candle.c > this_candle.l
                
                // Delete if closed candle failed to reject
                if not is_swing_high and not na(this_candle.swing_high_line)
                    line.delete(this_candle.swing_high_line)
                    this_candle.swing_high_line := na
                
                if not is_swing_low and not na(this_candle.swing_low_line)
                    line.delete(this_candle.swing_low_line)
                    this_candle.swing_low_line := na
            // For i == 1: Don't delete lines (potential swings from forming candle)
            
            // Update the candle in the array
            candleSet.candles.set(i, this_candle)
    
    candleSet

//+------------------------------------------------------------------------------------------------------------+//
//+--- CISD Engine (Change in State of Delivery)                                                            ---+//
//+------------------------------------------------------------------------------------------------------------+//
// Tracks an active delivery bias (a run of same-colored candles) on the CISD
// timeframe, and fires when price closes back through the level that started
// that run — a "CISD confirmation." Stateful per request.security() context.

f_cisd_direction() =>
    close > open ? 1 : close < open ? -1 : 0

// Finds the most extreme OPEN in the current uninterrupted run of candles
// matching wantedDirection. Returns [price, candle opening time].
f_cisd_current_run_extreme(int wantedDirection) =>
    float extremePrice = open
    int extremeTime = time
    int currentDirection = f_cisd_direction()

    if currentDirection == wantedDirection
        for i = 1 to 500
            int pastDirection = close[i] > open[i] ? 1 : close[i] < open[i] ? -1 : 0
            if pastDirection == 0
                continue
            if pastDirection != wantedDirection
                break
            if wantedDirection == 1 and open[i] < extremePrice
                extremePrice := open[i]
                extremeTime := time[i]
            else if wantedDirection == -1 and open[i] > extremePrice
                extremePrice := open[i]
                extremeTime := time[i]

    [extremePrice, extremeTime]

// Finds the previous uninterrupted run of candles matching wantedDirection.
// Used when a new price extreme is created by an opposite-colour candle.
f_cisd_previous_run_extreme(int wantedDirection) =>
    bool foundRun = false
    float extremePrice = na
    int extremeTime = na

    for i = 1 to 500
        int pastDirection = close[i] > open[i] ? 1 : close[i] < open[i] ? -1 : 0
        if pastDirection == 0
            continue
        if not foundRun
            if pastDirection == wantedDirection
                foundRun := true
                extremePrice := open[i]
                extremeTime := time[i]
        else
            if pastDirection != wantedDirection
                break
            if wantedDirection == 1 and open[i] < extremePrice
                extremePrice := open[i]
                extremeTime := time[i]
            else if wantedDirection == -1 and open[i] > extremePrice
                extremePrice := open[i]
                extremeTime := time[i]

    [extremePrice, extremeTime]

// bias =  1: bullish delivery active; a close below the level confirms bearish CISD.
// bias = -1: bearish delivery active; a close above the level confirms bullish CISD.
// Returns [activeLevel, bias, bullishEvent, bearishEvent, eventLevel, eventOriginTime, protectedSwingPrice, protectedSwingTime]
f_cisd_engine() =>
    var int bias = 0
    var float activeLevel = na
    var int activeOriginTime = na
    var float trackedExtreme = na
    var int trackedExtremeTime = na

    bool bullishEvent = false
    bool bearishEvent = false
    float eventLevel = na
    int eventOriginTime = na
    float protectedSwingPrice = na
    int protectedSwingTime = na

    if bias == 0 and bar_index > 10
        int initialDirection = f_cisd_direction()
        if initialDirection == 0
            for i = 1 to 50
                initialDirection := close[i] > open[i] ? 1 : close[i] < open[i] ? -1 : 0
                if initialDirection != 0
                    break
        if initialDirection != 0
            bias := initialDirection
            [initialLevel, initialTime] = f_cisd_current_run_extreme(initialDirection)
            activeLevel := initialLevel
            activeOriginTime := initialTime
            trackedExtreme := initialDirection == 1 ? high : low
            trackedExtremeTime := time

    int candleDirection = f_cisd_direction()

    if bias == 1 and not na(trackedExtreme)
        if high > trackedExtreme
            trackedExtreme := high
            trackedExtremeTime := time
            float newLevel = na
            int newOrigin = na
            if candleDirection == 1
                [price, origin] = f_cisd_current_run_extreme(1)
                newLevel := price
                newOrigin := origin
            else
                [price, origin] = f_cisd_previous_run_extreme(1)
                newLevel := price
                newOrigin := origin
            if not na(newLevel)
                activeLevel := newLevel
                activeOriginTime := newOrigin
    else if bias == -1 and not na(trackedExtreme)
        if low < trackedExtreme
            trackedExtreme := low
            trackedExtremeTime := time
            float newLevel = na
            int newOrigin = na
            if candleDirection == -1
                [price, origin] = f_cisd_current_run_extreme(-1)
                newLevel := price
                newOrigin := origin
            else
                [price, origin] = f_cisd_previous_run_extreme(-1)
                newLevel := price
                newOrigin := origin
            if not na(newLevel)
                activeLevel := newLevel
                activeOriginTime := newOrigin

    bullishEvent := bias == -1 and not na(activeLevel) and close > activeLevel
    bearishEvent := bias == 1 and not na(activeLevel) and close < activeLevel

    if bullishEvent or bearishEvent
        eventLevel := activeLevel
        eventOriginTime := activeOriginTime
        protectedSwingPrice := trackedExtreme
        protectedSwingTime := trackedExtremeTime
        int newBias = bullishEvent ? 1 : -1
        bias := newBias
        [resetLevel, resetTime] = f_cisd_current_run_extreme(newBias)
        activeLevel := resetLevel
        activeOriginTime := resetTime
        trackedExtreme := newBias == 1 ? high : low
        trackedExtremeTime := time

    [activeLevel, bias, bullishEvent, bearishEvent, eventLevel, eventOriginTime, protectedSwingPrice, protectedSwingTime]

// Live packet: the developing level, intentionally still able to move until the
// CISD-timeframe candle closes.
f_cisd_live_packet() =>
    [level, bias, bullEvent, bearEvent, eventLevel, eventOrigin, protectedPrice, protectedTime] = f_cisd_engine()
    [level, bias]

// Confirmed packet: offset by one CISD-timeframe bar, using lookahead_on, so this
// always reflects the last fully closed result — never repaints.
f_cisd_confirmed_packet() =>
    [level, bias, bullEvent, bearEvent, eventLevel, eventOrigin, protectedPrice, protectedTime] = f_cisd_engine()
    [bullEvent[1], bearEvent[1], eventLevel[1], eventOrigin[1], time_close[1], protectedPrice[1], protectedTime[1]]

int cnt = 0
int last = helper.HTFEnabled()

int offset = settings.offset
if isHTFVisibleOnCurrentTF(1, htf1.settings.show) and helper.ValidTimeframe(htf1.settings.htf)
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe'
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and settings.max_sets == 1
        showTrace := true
        showTrace
    htf1.UpdateTime(offset)
    htf1.Monitor(alert_htf1_enable).Update(offset, showTrace).FindImbalance().DetectSwings()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf1.candles.size() * settings.width + (htf1.candles.size() > 0 ? (htf1.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if isHTFVisibleOnCurrentTF(2, htf2.settings.show) and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf2.UpdateTime(offset)
    htf2.Monitor(alert_htf2_enable).Update(offset, showTrace).FindImbalance().DetectSwings()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf2.candles.size() * settings.width + (htf2.candles.size() > 0 ? (htf2.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if isHTFVisibleOnCurrentTF(3, htf3.settings.show) and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf3.UpdateTime(offset)
    htf3.Monitor(alert_htf3_enable).Update(offset, showTrace).FindImbalance().DetectSwings()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf3.candles.size() * settings.width + (htf3.candles.size() > 0 ? (htf3.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if isHTFVisibleOnCurrentTF(4, htf4.settings.show) and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf4.UpdateTime(offset)
    htf4.Monitor(alert_htf4_enable).Update(offset, showTrace).FindImbalance().DetectSwings()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf4.candles.size() * settings.width + (htf4.candles.size() > 0 ? (htf4.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if isHTFVisibleOnCurrentTF(5, htf5.settings.show) and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe' and cnt == last - 1
        showTrace := true
        showTrace
    htf5.UpdateTime(offset)
    htf5.Monitor(alert_htf5_enable).Update(offset, showTrace).FindImbalance().DetectSwings()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf5.candles.size() * settings.width + (htf5.candles.size() > 0 ? (htf5.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if isHTFVisibleOnCurrentTF(6, htf6.settings.show) and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
    bool showTrace = false
    if settings.trace_anchor == 'First Timeframe' and cnt == 0
        showTrace := true
        showTrace
    if settings.trace_anchor == 'Last Timeframe'
        showTrace := true
        showTrace
    htf6.UpdateTime(offset)
    htf6.Monitor(alert_htf6_enable).Update(offset, showTrace).FindImbalance().DetectSwings()

//+------------------------------------------------------------------------------------------------------------+//
//+--- HTF Period Boundary (on chart)                                                                       ---+//
//+------------------------------------------------------------------------------------------------------------+//
// Marks the start of every period of the chosen boundary timeframe directly on
// the live price chart, using Pine's built-in time() HTF-boundary detection —
// the same non-repainting mechanism the candle-set Monitor() methods use.

var array<line> htf_boundary_lines = array.new<line>()

if show_htf_boundary
    bool htf_boundary_new_period = ta.change(time(htf_boundary_tf, 'America/New_York')) > 0
    if htf_boundary_new_period and bar_index > 0
        line new_boundary_line = line.new(bar_index, low, bar_index, high, xloc=xloc.bar_index, extend=extend.both, color=htf_boundary_color, width=htf_boundary_width, style=htf_boundary_style_value)
        array.push(htf_boundary_lines, new_boundary_line)
        if array.size(htf_boundary_lines) > htf_boundary_max_lines
            line.delete(array.shift(htf_boundary_lines))
else
    while array.size(htf_boundary_lines) > 0
        line.delete(array.shift(htf_boundary_lines))

//+------------------------------------------------------------------------------------------------------------+//
//+--- CISD (Change in State of Delivery)                                                                   ---+//
//+------------------------------------------------------------------------------------------------------------+//

[cisd_live_level, cisd_live_bias] = request.security(syminfo.tickerid, cisd_resolved_tf, f_cisd_live_packet(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[cisd_closed_bull, cisd_closed_bear, cisd_event_level, cisd_event_origin, cisd_event_close, cisd_protected_price, cisd_protected_time] = request.security(syminfo.tickerid, cisd_resolved_tf, f_cisd_confirmed_packet(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[cisd2_live_level, cisd2_live_bias] = request.security(syminfo.tickerid, cisd2_tf, f_cisd_live_packet(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[cisd2_closed_bull, cisd2_closed_bear, cisd2_event_level, cisd2_event_origin, cisd2_event_close, cisd2_protected_price, cisd2_protected_time] = request.security(syminfo.tickerid, cisd2_tf, f_cisd_confirmed_packet(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

[cisd3_live_level, cisd3_live_bias] = request.security(syminfo.tickerid, cisd3_tf, f_cisd_live_packet(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[cisd3_closed_bull, cisd3_closed_bear, cisd3_event_level, cisd3_event_origin, cisd3_event_close, cisd3_protected_price, cisd3_protected_time] = request.security(syminfo.tickerid, cisd3_tf, f_cisd_confirmed_packet(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

cisd_event_close_change = ta.change(cisd_event_close)
cisd_new_closed = not na(cisd_event_close) and cisd_event_close_change != 0
cisd_bull_event = cisd_show and cisd_new_closed and cisd_closed_bull
cisd_bear_event = cisd_show and cisd_new_closed and cisd_closed_bear

cisd2_event_close_change = ta.change(cisd2_event_close)
cisd2_new_closed = not na(cisd2_event_close) and cisd2_event_close_change != 0
cisd2_bull_event = cisd2_show and cisd2_new_closed and cisd2_closed_bull
cisd2_bear_event = cisd2_show and cisd2_new_closed and cisd2_closed_bear

cisd3_event_close_change = ta.change(cisd3_event_close)
cisd3_new_closed = not na(cisd3_event_close) and cisd3_event_close_change != 0
cisd3_bull_event = cisd3_show and cisd3_new_closed and cisd3_closed_bull
cisd3_bear_event = cisd3_show and cisd3_new_closed and cisd3_closed_bear

var line cisd_dev_line = na
var label cisd_dev_label = na
var line cisd_confirmed_line = na
var label cisd_confirmed_label = na
var line cisd_protected_line = na
var label cisd_protected_label = na

var line cisd2_dev_line = na
var label cisd2_dev_label = na
var line cisd2_confirmed_line = na
var label cisd2_confirmed_label = na
var line cisd2_protected_line = na
var label cisd2_protected_label = na

var line cisd3_dev_line = na
var label cisd3_dev_label = na
var line cisd3_confirmed_line = na
var label cisd3_confirmed_label = na
var line cisd3_protected_line = na
var label cisd3_protected_label = na

// Confirmed / protected drawings only ever get (re)created at the exact instant
// of a new CISD confirmation, using fully closed data — never repainted.
if cisd_bull_event or cisd_bear_event
    bool this_bull = cisd_bull_event
    color event_color = this_bull ? cisd_bull_color : cisd_bear_color
    string dir_text = this_bull ? "CISD+" : "CISD-"

    if cisd_show_confirmed
        line.delete(cisd_confirmed_line)
        label.delete(cisd_confirmed_label)
        int cisd_midpoint = int(math.round((cisd_event_origin + cisd_event_close) / 2.0))
        cisd_confirmed_line := line.new(cisd_event_origin, cisd_event_level, cisd_event_close, cisd_event_level, xloc=xloc.bar_time, color=event_color, width=cisd_line_width, style=line.style_solid)
        cisd_confirmed_label := label.new(cisd_midpoint, cisd_event_level, helper.HTFName(cisd_resolved_tf) + " " + dir_text, xloc=xloc.bar_time, style=this_bull ? label.style_label_down : label.style_label_up, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if cisd_show_protected and not na(cisd_protected_price) and not na(cisd_protected_time)
        line.delete(cisd_protected_line)
        label.delete(cisd_protected_label)
        string swing_text = this_bull ? "PSL" : "PSH"
        cisd_protected_label := label.new(cisd_protected_time, cisd_protected_price, swing_text + "\n" + helper.HTFName(cisd_resolved_tf), xloc=xloc.bar_time, style=this_bull ? label.style_label_up : label.style_label_down, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if alert_cisd_enable
        alert(syminfo.ticker + ' ' + helper.HTFName(cisd_resolved_tf) + ' CISD Confirmed (' + (this_bull ? 'Bullish' : 'Bearish') + ')', alert.freq_once_per_bar_close)

if cisd2_bull_event or cisd2_bear_event
    bool this_bull = cisd2_bull_event
    color event_color = color.new(this_bull ? cisd_bull_color : cisd_bear_color, 20)
    string dir_text = this_bull ? "CISD+" : "CISD-"

    if cisd_show_confirmed
        line.delete(cisd2_confirmed_line)
        label.delete(cisd2_confirmed_label)
        int cisd2_midpoint = int(math.round((cisd2_event_origin + cisd2_event_close) / 2.0))
        cisd2_confirmed_line := line.new(cisd2_event_origin, cisd2_event_level, cisd2_event_close, cisd2_event_level, xloc=xloc.bar_time, color=event_color, width=cisd_line_width, style=line.style_solid)
        cisd2_confirmed_label := label.new(cisd2_midpoint, cisd2_event_level, helper.HTFName(cisd2_tf) + " " + dir_text, xloc=xloc.bar_time, style=this_bull ? label.style_label_down : label.style_label_up, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if cisd_show_protected and not na(cisd2_protected_price) and not na(cisd2_protected_time)
        line.delete(cisd2_protected_line)
        label.delete(cisd2_protected_label)
        string swing_text = this_bull ? "PSL" : "PSH"
        cisd2_protected_label := label.new(cisd2_protected_time, cisd2_protected_price, swing_text + "\n" + helper.HTFName(cisd2_tf), xloc=xloc.bar_time, style=this_bull ? label.style_label_up : label.style_label_down, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if alert_cisd_enable
        alert(syminfo.ticker + ' ' + helper.HTFName(cisd2_tf) + ' CISD Confirmed (' + (this_bull ? 'Bullish' : 'Bearish') + ')', alert.freq_once_per_bar_close)

if cisd3_bull_event or cisd3_bear_event
    bool this_bull = cisd3_bull_event
    color event_color = color.new(this_bull ? cisd_bull_color : cisd_bear_color, 40)
    string dir_text = this_bull ? "CISD+" : "CISD-"

    if cisd_show_confirmed
        line.delete(cisd3_confirmed_line)
        label.delete(cisd3_confirmed_label)
        int cisd3_midpoint = int(math.round((cisd3_event_origin + cisd3_event_close) / 2.0))
        cisd3_confirmed_line := line.new(cisd3_event_origin, cisd3_event_level, cisd3_event_close, cisd3_event_level, xloc=xloc.bar_time, color=event_color, width=cisd_line_width, style=line.style_solid)
        cisd3_confirmed_label := label.new(cisd3_midpoint, cisd3_event_level, helper.HTFName(cisd3_tf) + " " + dir_text, xloc=xloc.bar_time, style=this_bull ? label.style_label_down : label.style_label_up, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if cisd_show_protected and not na(cisd3_protected_price) and not na(cisd3_protected_time)
        line.delete(cisd3_protected_line)
        label.delete(cisd3_protected_label)
        string swing_text = this_bull ? "PSL" : "PSH"
        cisd3_protected_label := label.new(cisd3_protected_time, cisd3_protected_price, swing_text + "\n" + helper.HTFName(cisd3_tf), xloc=xloc.bar_time, style=this_bull ? label.style_label_up : label.style_label_down, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if alert_cisd_enable
        alert(syminfo.ticker + ' ' + helper.HTFName(cisd3_tf) + ' CISD Confirmed (' + (this_bull ? 'Bullish' : 'Bearish') + ')', alert.freq_once_per_bar_close)

// Developing (live) level: redrawn every tick on the last bar so it tracks price,
// same pattern as everything else in this script that shows the currently-forming state.
if barstate.islast
    line.delete(cisd_dev_line)
    label.delete(cisd_dev_label)
    if cisd_show and cisd_show_developing and not na(cisd_live_level)
        color dev_color = cisd_live_bias == -1 ? cisd_bull_color : cisd_bear_color
        int dev_start = bar_index + 1
        int dev_end = dev_start + 20
        string dev_dir_text = cisd_live_bias == -1 ? "CISD+" : "CISD-"
        cisd_dev_line := line.new(dev_start, cisd_live_level, dev_end, cisd_live_level, color=dev_color, width=cisd_line_width, style=line.style_dotted)
        cisd_dev_label := label.new(dev_end, cisd_live_level, helper.HTFName(cisd_resolved_tf) + " " + dev_dir_text, style=label.style_label_left, color=color.new(dev_color, 100), textcolor=dev_color, size=size.small)

    line.delete(cisd2_dev_line)
    label.delete(cisd2_dev_label)
    if cisd2_show and cisd_show_developing and not na(cisd2_live_level)
        color dev_color = color.new(cisd2_live_bias == -1 ? cisd_bull_color : cisd_bear_color, 20)
        int dev_start = bar_index + 1
        int dev_end = dev_start + 20
        string dev_dir_text = cisd2_live_bias == -1 ? "CISD+" : "CISD-"
        cisd2_dev_line := line.new(dev_start, cisd2_live_level, dev_end, cisd2_live_level, color=dev_color, width=cisd_line_width, style=line.style_dotted)
        cisd2_dev_label := label.new(dev_end, cisd2_live_level, helper.HTFName(cisd2_tf) + " " + dev_dir_text, style=label.style_label_left, color=color.new(dev_color, 100), textcolor=dev_color, size=size.small)

    line.delete(cisd3_dev_line)
    label.delete(cisd3_dev_label)
    if cisd3_show and cisd_show_developing and not na(cisd3_live_level)
        color dev_color = color.new(cisd3_live_bias == -1 ? cisd_bull_color : cisd_bear_color, 40)
        int dev_start = bar_index + 1
        int dev_end = dev_start + 20
        string dev_dir_text = cisd3_live_bias == -1 ? "CISD+" : "CISD-"
        cisd3_dev_line := line.new(dev_start, cisd3_live_level, dev_end, cisd3_live_level, color=dev_color, width=cisd_line_width, style=line.style_dotted)
        cisd3_dev_label := label.new(dev_end, cisd3_live_level, helper.HTFName(cisd3_tf) + " " + dev_dir_text, style=label.style_label_left, color=color.new(dev_color, 100), textcolor=dev_color, size=size.small)

if not cisd_show
    if not na(cisd_dev_line)
        line.delete(cisd_dev_line)
        cisd_dev_line := na
    if not na(cisd_dev_label)
        label.delete(cisd_dev_label)
        cisd_dev_label := na
    if not na(cisd_confirmed_line)
        line.delete(cisd_confirmed_line)
        cisd_confirmed_line := na
    if not na(cisd_confirmed_label)
        label.delete(cisd_confirmed_label)
        cisd_confirmed_label := na
    if not na(cisd_protected_line)
        line.delete(cisd_protected_line)
        cisd_protected_line := na
    if not na(cisd_protected_label)
        label.delete(cisd_protected_label)
        cisd_protected_label := na

if not cisd2_show
    if not na(cisd2_dev_line)
        line.delete(cisd2_dev_line)
        cisd2_dev_line := na
    if not na(cisd2_dev_label)
        label.delete(cisd2_dev_label)
        cisd2_dev_label := na
    if not na(cisd2_confirmed_line)
        line.delete(cisd2_confirmed_line)
        cisd2_confirmed_line := na
    if not na(cisd2_confirmed_label)
        label.delete(cisd2_confirmed_label)
        cisd2_confirmed_label := na
    if not na(cisd2_protected_line)
        line.delete(cisd2_protected_line)
        cisd2_protected_line := na
    if not na(cisd2_protected_label)
        label.delete(cisd2_protected_label)
        cisd2_protected_label := na

if not cisd3_show
    if not na(cisd3_dev_line)
        line.delete(cisd3_dev_line)
        cisd3_dev_line := na
    if not na(cisd3_dev_label)
        label.delete(cisd3_dev_label)
        cisd3_dev_label := na
    if not na(cisd3_confirmed_line)
        line.delete(cisd3_confirmed_line)
        cisd3_confirmed_line := na
    if not na(cisd3_confirmed_label)
        label.delete(cisd3_confirmed_label)
        cisd3_confirmed_label := na
    if not na(cisd3_protected_line)
        line.delete(cisd3_protected_line)
        cisd3_protected_line := na
    if not na(cisd3_protected_label)
        label.delete(cisd3_protected_label)
        cisd3_protected_label := na
````
