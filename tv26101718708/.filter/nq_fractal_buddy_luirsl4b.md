# NQ Fractal Buddy

- url: https://www.tradingview.com/script/LuIrSL4b-NQ-Fractal-Buddy/
- type: indicator
- pine_id: PUB;e5ec83e927634a83ab1571a622b3fc8e
- version: 2.0

## Description

[b]NQ Fractal Buddy[/b]

[b]NQ Fractal Buddy is a research-driven toolkit designed specifically for NQ/MNQ traders using the Fractal Model.[/b]

The project started from my own interest in trading the Fractal Model and wanting to investigate its behaviour quantitatively using historical Nasdaq futures data.

After reconstructing the model programmatically across a large historical sample, I wanted to take the research further.

Rather than only looking at whether a Fractal Model sequence continued to develop, I wanted to answer two practical questions:

[b]Once a qualifying C2 has completed, how far has NQ historically tended to expand during the developing C3/C4 sequence?[/b]

And:

[b]How often has the C2 protected extreme survived through C3 to reach C4, and how often has it remained intact throughout C4?[/b]

Those questions eventually developed into the two main statistical features of NQ Fractal Buddy:

[b]Expected Expansion[/b] and [b]Structural Expectancy[/b].

The rest of the indicator is built around those features to provide the higher-timeframe structure, points of interest and lower-timeframe tools I use when analysing the Fractal Model.


[b]The Fractal Model[/b]

The Fractal Model brings together ideas used in ICT-style price-action analysis and Candle Range Theory (CRT) to study how liquidity and candle structure can develop across multiple timeframes.

A major part of the model is understanding the relationship between a sequence of higher-timeframe candles, commonly referred to as C1, C2, C3 and C4.

NQ Fractal Buddy is designed around this workflow.

The different components of the indicator are therefore [b]not intended to be a collection of unrelated indicators[/b]. Each has a specific role within the same analysis process.

HTF candles provide the higher-timeframe map. C2/C3 identification helps visualise the developing fractal sequence. CISD can provide lower-timeframe structural confirmation for execution. FVGs, Volume Imbalances, swings and equilibrium provide additional areas of interest within that structure.

Expected Expansion and Structural Expectancy then add a statistical layer derived from historical NQ behaviour.

The idea is to bring the structure, execution tools and historical context together in one workspace.


[b]Expected Expansion[/b]

[b]Expected Expansion is the main research-driven component of NQ Fractal Buddy.[/b]

I reconstructed a large historical sample of NQ fractal events and investigated what happened [b]after a qualifying C2 completed[/b].

Rather than simply asking whether the structure succeeded or failed, the research measured the favorable price expansion that occurred during the subsequent developing C3/C4 sequence before the model's defined structural failure or observation endpoint.

From those historical observations, Fractal Buddy derives an expansion distribution represented by:

[b]P25 · P50 · P75 · P90[/b]

These are historical [b]favorable-expansion quantiles[/b].


[b]Understanding P25, P50, P75 and P90[/b]

One intuitive way to understand these levels is to ask what proportion of the corresponding historical observations expanded [b]at least that far[/b].

[b]P25[/b] — approximately [b]75%[/b] of the historical observations reached or exceeded this amount of favorable expansion.

[b]P50[/b] — approximately [b]50%[/b] reached or exceeded this amount. This represents the median historical favorable expansion.

[b]P75[/b] — approximately [b]25%[/b] reached or exceeded this amount.

[b]P90[/b] — approximately [b]10%[/b] reached or exceeded this amount.

For example, if Fractal Buddy displays a P50 Expected Expansion of [b]73 points[/b], that means approximately half of the corresponding historical observations produced at least 73 points of favorable expansion under the defined measurement rules, while approximately half produced less.

Likewise, P25 represents a more commonly observed amount of expansion, while P75 and P90 represent progressively larger and historically less common expansions.

This can be particularly useful when comparing the projected distribution with levels already identified through your own technical analysis.

For example, a liquidity objective sitting around P25 occupies a very different location within the historical expansion distribution than an objective sitting around P75 or beyond P90.


[b]What the levels do NOT mean[/b]

There is an important distinction between a [b]historical quantile[/b] and a [b]forward-looking probability[/b].

P25 does [b]not[/b] mean that the current setup has a guaranteed or independently estimated 75% probability of reaching P25.

Likewise, P50 does not mean the current trade has a 50% probability of reaching P50, and P90 does not mean the current setup has a 10% probability of reaching P90.

Instead, those percentages describe the [b]historical distribution used to construct the model[/b]: approximately 75%, 50%, 25% and 10% of the corresponding historical observations reached or exceeded P25, P50, P75 and P90 respectively.

The levels therefore provide statistical context for the developing structure rather than a guarantee or precise forecast of what the current C3/C4 sequence will do.


[b]How I Use Expected Expansion[/b]

The expansion levels become particularly interesting when they overlap with something already present in the trader's analysis.

That could include:

[list]
[*] External liquidity
[*] Previous highs or lows
[*] A Fair Value Gap
[*] Another PD Array
[*] A higher-timeframe level
[*] Another independently identified point of interest
[/list]

For example, if the historical median expansion sits near a liquidity objective already identified through your own analysis, the statistical model provides another piece of context around that area.

Expected Expansion can therefore be used as a framework for potential objectives or simply as an additional layer of information alongside an existing strategy.

It is [b]not an automatic target generator or trade signal[/b].


[b]Structural Expectancy[/b]

Expected Expansion answers the question:

[b]"How far did comparable structures historically expand?"[/b]

Structural Expectancy addresses a different question:

[b]"How often did the C2 protected extreme survive as the fractal continued to develop?"[/b]

Fractal Buddy displays two measurements:

[b]Reach C4[/b]
The historical probability that the C2 protected extreme survives through C3 and remains intact at the [b]open of C4[/b].

[b]C4 Intact[/b]
The historical probability that the C2 protected extreme remains intact through the [b]entire C4 candle and its close[/b].

The displayed probabilities are conditioned on characteristics of the completed C2 using models developed from historical NQ observations.


[b]Structural probability is not trade probability[/b]

This distinction is important.

If Fractal Buddy displays:

[b]Reach C4 ~70%[/b]

that does [b]not[/b] mean a trade has a 70% probability of winning.

It means that historical structures with the corresponding characteristics preserved the C2 protected extreme through C3 to the opening of C4 at approximately that rate under the model definition.

Likewise, C4 Intact measures structural survival through C4. It is not a win rate, expected profitability figure or guarantee about future price action.

This information can be considered alongside Expected Expansion and the trader's own directional bias, execution criteria and risk management.


[b]Higher-Timeframe Candles[/b]

The HTF candle display provides the visual framework for the indicator.

Multiple higher timeframes can be displayed alongside the execution chart, allowing the developing candle structure to be observed without constantly switching chart timeframes.

This is particularly useful with the Fractal Model because the trader may be analysing a higher-timeframe C2/C3/C4 sequence while simultaneously looking for execution on a much lower timeframe.

The HTF display makes it easier to see where the current lower-timeframe price action sits inside the larger developing candle.

The displayed timeframes are configurable so traders can build the hierarchy appropriate to their own analysis.


[b]C2 / C3 Identification[/b]

Fractal Buddy includes tools for identifying and visualising the C2/C3 structure directly within the HTF candle framework.

These are intended to make the developing Fractal Model sequence easier to follow and provide the structural context used by Expected Expansion and Structural Expectancy.

They are not automatic trade signals.


[b]CISD[/b]

[b]Change in State of Delivery (CISD)[/b] is commonly used as a lower-timeframe confirmation or execution mechanism by traders using this style of analysis.

Fractal Buddy includes CISD functionality so that lower-timeframe structural changes can be analysed alongside the higher-timeframe fractal rather than requiring a separate indicator.

This creates a workflow such as:

[b]HTF structure → C2 completes → developing C3/C4 context → LTF confirmation/execution[/b]

The trader remains responsible for deciding whether a setup is valid and whether a trade should be taken.


[b]Fair Value Gaps & Volume Imbalances[/b]

Fractal Buddy can display Fair Value Gaps (FVGs) and Volume Imbalances (VIs), including within the higher-timeframe candle framework.

These help visualise areas of imbalance within the developing structure that a trader may consider potential areas of interest, reaction or draw on price.

Their inclusion is particularly useful when an imbalance overlaps with an Expected Expansion level or another independently identified liquidity objective.


[b]Swings & Equilibrium[/b]

Swing structure and equilibrium tools provide additional context for understanding where price is trading within the developing range.

They can help identify relevant structural extremes and the relationship between current price and the range being analysed.

Again, these features are included because they support the same Fractal Model workflow rather than functioning as separate trading systems.


[b]ICT Time Anchors[/b]

The indicator also includes commonly referenced ICT time anchors, including configurable New York reference times.

Time is an important part of this style of analysis, particularly when observing how a developing higher-timeframe candle behaves through different sessions.

Displaying these references directly on the execution chart allows the trader to consider [b]time and price together[/b] while monitoring the developing fractal structure.


[b]Bringing It All Together[/b]

The intended workflow is not:

[b]"The indicator says buy or sell."[/b]

Instead, a trader might:

[b]Identify a higher-timeframe fractal structure → evaluate the completed C2 → establish their own directional thesis → identify liquidity and other points of interest → use their preferred lower-timeframe confirmation such as CISD → consult Expected Expansion for historical expansion context → consult Structural Expectancy for historical information about survival of the C2 protected extreme.[/b]

This is why the different components have been combined into one indicator.

The HTF candles provide the map. The structural tools help identify what is occurring within that map. CISD provides an execution framework for traders who use it. Expected Expansion and Structural Expectancy provide the historical statistical context.

A trader using another methodology can also use the statistical components independently as an additional layer of context.

The goal of Fractal Buddy is to provide [b]more information about the structure already developing in front of the trader[/b], not to replace the trader's analysis.


[b]Research & Validation[/b]

The statistical components of NQ Fractal Buddy were developed from historical [b]Nasdaq futures (NQ)[/b] data.

The underlying research database contains NQ 1-minute data extending from [b]2010 through 2026[/b]. The core Fractal Model reconstruction used a [b]2019–2025[/b] research period and produced large samples across the timeframes studied — including [b]52,164 reconstructed 15-minute events[/b] and [b]12,611 1-hour events[/b].

The research involved programmatically reconstructing historical Fractal Model events, measuring their subsequent structural behaviour and favorable expansion, and investigating which characteristics of the completed C2 contained useful information about what followed.

Multiple timeframes and model variations were investigated, but a timeframe was not included in the production statistical tools simply because an in-sample result looked interesting.

The models were not simply fitted to all available observations and then reported on the same data. Development and validation were separated during the research process.

For Expected Expansion, the final production models for [b]15-minute, 1-hour and 4-hour[/b] structures were subsequently tested against unseen forward data before being frozen for production use.

Structural Expectancy likewise uses production-supported models for [b]15-minute, 1-hour and 4-hour[/b] structures.

Other timeframes were researched during development but were not automatically promoted into the production indicator where the evidence did not meet the project's production requirements.

The purpose of this process was to reduce the risk of treating an interesting historical relationship as useful simply because it happened to fit the data used to discover it.

The final indicator deliberately uses frozen models rather than continuously changing the statistical rules to fit recent observations.

Where the tool uses fallback behaviour because of data or contract-roll conditions, that state is identified in the interface rather than silently presented as equivalent to the normal model.


[b]Designed Specifically for NQ / MNQ[/b]

The statistical research behind Expected Expansion and Structural Expectancy was developed using [b]NQ futures data[/b].

The resulting statistical outputs should therefore be treated as [b]NQ/MNQ-specific[/b].

The fact that a similar visual candle pattern occurs in another market does not establish that the same statistical relationships apply there.


[b]Important Limitations[/b]

NQ Fractal Buddy is an analytical and research tool, not a complete trading system.

Historical relationships can change, and historical behaviour does not guarantee future behaviour.

Expected Expansion does not predict where price must trade.

P25/P50/P75/P90 are historical favorable-expansion quantiles, [b]not calibrated target-hit probabilities for the current setup[/b].

The historical sample used to construct those quantiles means that approximately 75%, 50%, 25% and 10% of the corresponding observations reached or exceeded P25, P50, P75 and P90 respectively. That historical relationship should not be interpreted as a guarantee that a new observation will behave identically.

Reach C4 and C4 Intact are historical structural-survival probabilities, [b]not trade win probabilities[/b].

CISD, FVGs, imbalances, swings, liquidity concepts and other structural tools require interpretation and should not be treated as automatic entry signals.

No statistical reading from the indicator removes the need for independent analysis and risk management.


[b]Code Lineage & Attribution[/b]

NQ Fractal Buddy was developed from my earlier open-source TradingView project, [b]HTF Structure Lens[/b], published by SuvoConquers.

HTF Structure Lens historically incorporated portions of the higher-timeframe candle visualization framework from [b]"ICT HTF Candles (fadi)" by fadizeidan[/b]. The referenced original work by fadizeidan was licensed under the [b]Mozilla Public License 2.0[/b]. Credit and thanks to fadizeidan for that original open-source work.

The higher-timeframe rendering architecture used in the current NQ Fractal Buddy implementation was subsequently independently rewritten. NQ Fractal Buddy nevertheless retains and extends functionality developed through HTF Structure Lens, so that historical project lineage is acknowledged here.

NQ Fractal Buddy substantially extends that earlier project with original NQ Fractal Model research and implementation, including the historical reconstruction and analysis behind [b]Expected Expansion[/b] and [b]Structural Expectancy[/b], the resulting production models, and their integration into the broader Fractal Model workflow described above.

Fractal Model, ICT/CRT, CISD, Fair Value Gap, Volume Imbalance and related market-analysis concepts predate this project. Their names are used descriptively and no ownership of those underlying concepts is claimed.

fadizeidan is not affiliated with and does not endorse NQ Fractal Buddy.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/
//
// NQ Fractal Buddy
// © 2026 SuvoConquers
//
// An NQ/MNQ-focused Fractal Model research and analysis tool.
//
// NQ Fractal Buddy was developed from SuvoConquers' earlier open-source project,
// "HTF Structure Lens". That project historically incorporated portions of the
// higher-timeframe candle visualization framework from "ICT HTF Candles (fadi)"
// by fadizeidan. The referenced original work by fadizeidan was licensed under
// the Mozilla Public License 2.0.
//
// The current NQ Fractal Buddy higher-timeframe rendering architecture was
// subsequently independently rewritten. The project nevertheless retains and
// extends functionality developed through HTF Structure Lens. This historical
// lineage acknowledgement does not imply that fadizeidan contributed to,
// endorses, or is affiliated with NQ Fractal Buddy.
//
// Original work by SuvoConquers in this project includes historical NQ Fractal
// Model reconstruction and research, Expected Expansion research and production
// models, Structural Expectancy research and production models, and integration
// of that research into NQ Fractal Buddy.
//
// Inspired by ProfGreens' Fractal Model research. ProfGreens is not affiliated
// with this project, and no endorsement is implied.
//
// Fractal Model, ICT/CRT, CISD, Fair Value Gap, Volume Imbalance, and related
// market-analysis concepts predate this project. Their names are used
// descriptively and no ownership of those concepts is claimed.
//
// NQ Fractal Buddy is an analytical research tool and is not intended to be a
// complete trading system.

//@version=6
indicator('NQ Fractal Buddy', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// Neutral market-data records contain no drawing handles.
type HtfBarState
    float o
    float h
    float l
    float c
    int period_id
    int open_time
    int open_index
    int close_index
    int high_index
    int low_index
    string caption
    bool completed

type HtfSlotState
    array<HtfBarState> bars
    int close_serial

// Drawing ownership is deliberately separate from market state.
type HtfCandleView
    box body
    line upper_wick
    line lower_wick
    label time_label
    line swing_high
    line swing_low
    line equilibrium
    label offset_signal
    label chart_signal
    line chart_high_sweep
    line chart_low_sweep

type HtfSlotView
    array<HtfCandleView> candles
    array<box> imbalances
    label name_top
    label name_bottom
    label timer_top
    label timer_bottom
    line trace_o
    line trace_h
    line trace_l
    line trace_c
    label trace_o_label
    label trace_h_label
    label trace_l_label
    label trace_c_label
    int rendered_serial

type HtfSlotConfig
    bool show
    string timeframe
    int max_bars

var array<HtfSlotState> htf_states = array.new<HtfSlotState>()
var array<HtfSlotView> htf_views = array.new<HtfSlotView>()

if barstate.isfirst
    for slot = 0 to 5
        array.push(htf_states, HtfSlotState.new(array.new<HtfBarState>(), 0))
        array.push(htf_views, HtfSlotView.new(array.new<HtfCandleView>(), array.new<box>(), na, na, na, na, na, na, na, na, na, na, na, na, 0))

string group_htf_timeframes = 'HTF Candles — Timeframes'
slot1_show = input.bool(true, 'HTF 1      ', inline='htf1', group=group_htf_timeframes)
slot1_tf = input.timeframe('15', '', inline='htf1', group=group_htf_timeframes)
slot1_max = input.int(4, '', inline='htf1', group=group_htf_timeframes)
slot2_show = input.bool(true, 'HTF 2      ', inline='htf2', group=group_htf_timeframes)
slot2_tf = input.timeframe('60', '', inline='htf2', group=group_htf_timeframes)
slot2_max = input.int(4, '', inline='htf2', group=group_htf_timeframes)
slot3_show = input.bool(true, 'HTF 3      ', inline='htf3', group=group_htf_timeframes)
slot3_tf = input.timeframe('240', '', inline='htf3', group=group_htf_timeframes)
slot3_max = input.int(4, '', inline='htf3', group=group_htf_timeframes)
slot4_show = input.bool(false, 'HTF 4      ', inline='htf4', group=group_htf_timeframes)
slot4_tf = input.timeframe('420', '', inline='htf4', group=group_htf_timeframes)
slot4_max = input.int(4, '', inline='htf4', group=group_htf_timeframes)
slot5_show = input.bool(false, 'HTF 5      ', inline='htf5', group=group_htf_timeframes)
slot5_tf = input.timeframe('1D', '', inline='htf5', group=group_htf_timeframes)
slot5_max = input.int(4, '', inline='htf5', group=group_htf_timeframes)
slot6_show = input.bool(false, 'HTF 6      ', inline='htf6', group=group_htf_timeframes)
slot6_tf = input.timeframe('1W', '', inline='htf6', group=group_htf_timeframes)
slot6_max = input.int(4, '', inline='htf6', group=group_htf_timeframes)

string group_daily_open = 'HTF Candles — Daily Open'
htf_use_custom_daily = input.bool(false, 'Use Custom Daily Open', inline='customdaily', tooltip="Uses the selected New York daily open for custom Daily HTF candles. Other HTF timeframes are unaffected.", group=group_daily_open)
htf_custom_daily = input.string('Midnight', '', options=['Midnight', '8:30', '9:30'], inline='customdaily', group=group_daily_open)

string group_imbalance = 'HTF Structure — FVG & VI'
htf_fvg_show = input.bool(true, 'Fair Value Gap   ', group=group_imbalance, inline='fvg')
htf_fvg_color = input.color(color.new(#800080, 80), '', inline='fvg', group=group_imbalance)
htf_vi_show = input.bool(false, 'Volume Imbalance', group=group_imbalance, inline='vi')
htf_vi_color = input.color(color.new(color.red, 50), '', inline='vi', group=group_imbalance)

string group_swing = 'HTF Structure — Swings & EQ'
show_swing_lines = input.bool(true, title='Show Swing Lines', group=group_swing, tooltip='Draws horizontal lines at swing highs and lows. Confirmed swings show when price swept a level and closed with rejection. Potential swings show when price is currently forming a sweep')
swing_line_width = input.int(1, title='Line Width', minval=1, maxval=5, group=group_swing)
confirmed_swing_style = input.string('Solid', title='Confirmed Swing Style', options=['Solid', 'Dashed', 'Dotted'], group=group_swing, tooltip='Style for confirmed swings (swept with rejection)')
potential_swing_style = input.string('Dashed', title='Potential Swing Style', options=['Solid', 'Dashed', 'Dotted'], group=group_swing, tooltip='Style for potential swings (currently forming)')
swing_high_color = input.color(color.new(#F23645, 0), title='High Line Color', group=group_swing, inline='swing_col')
swing_low_color = input.color(color.new(#F23645, 0), title='Low Line Color', group=group_swing, inline='swing_col')
swing_overshoot = input.int(1, title='Swing Line Extension (Bars)', minval=0, maxval=50, group=group_swing)
show_eq_line = input.bool(true, title='Show EQ Line', group=group_swing)
eq_previous_only = input.bool(true, title='Previous Closed Candle Only', group=group_swing, tooltip='When on, only the most recently closed candle draws an EQ line. When off, every closed candle draws its own EQ line.')
eq_line_color = input.color(color.new(color.white, 0), title='EQ Line Color', group=group_swing, inline='eq')
eq_line_width = input.int(1, title='Width', minval=1, maxval=5, group=group_swing, inline='eq')
eq_line_style_input = input.string('Dotted', title='Style', options=['Solid', 'Dashed', 'Dotted'], group=group_swing, inline='eq')

string group_alerts = 'C2 / C3 — Alerts & Chart Marks'
alert_c2_closure_enable = input.bool(true, title='C2 Closure Alerts', group=group_alerts, tooltip="Fires once, immediately when a HTF candle closes, if that candle (C2) swept the previous HTF candle's (C1) high or low and closed back inside its range. Uses only fully-closed candle data — cannot repaint.")
alert_c3_reversal_enable = input.bool(true, title='C3 Reversal Alerts', group=group_alerts, tooltip="Fires once, immediately when a HTF candle closes, if that candle did NOT sweep the previous candle's high/low, but its close pushed beyond the entire body of the previous candle (an engulfing reversal close). Uses only fully-closed candle data — cannot repaint.")
alert_cisd_enable = input.bool(false, title='CISD Confirmation Alerts', group=group_alerts, tooltip='Fires once when a CISD confirms on the selected CISD timeframe (see the CISD section below). Requires "Show CISD" to be on.')
alert_htf1_enable = input.bool(true, 'HTF 1', group=group_alerts, inline='alerthtfs1', tooltip='Which HTF slots should fire C2 Closure / C3 Reversal alerts')
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
sweep_line_type = input.string('Confirmed (C2 Closures)', 'Sweep Type', options=['Confirmed (C2 Closures)', 'All Sweeps'], group=group_alerts, tooltip='Confirmed only draws a sweep line when the level was swept AND the candle closed back inside it (a C2 Closure). All Sweeps draws every wick that takes out a prior high/low, regardless of where it closed.')
sweep_line_color = input.color(color.white, '', group=group_alerts, inline='sweepline')
sweep_line_style = input.string('Dashed', '', options=['Solid', 'Dashed', 'Dotted'], group=group_alerts, inline='sweepline')
sweep_line_width = input.int(1, '', minval=1, maxval=5, group=group_alerts, inline='sweepline')
string EE_GROUP = 'Expected Expansion — 15m / 1H / 4H'
bool ee_enabled = input.bool(true, "Enable Expected Expansion", group=EE_GROUP, tooltip="Shows historical NQ expansion levels for the selected timeframe. Levels describe observed excursions before C2 failure, not guaranteed targets or trade probabilities.")
string ee_selected_tf = input.string("1h", 'Model Timeframe', options=["15m", "1h", "4H"], group=EE_GROUP, tooltip="Choose the Expected Expansion model timeframe. 4H uses the validated NQ-native implementation with automatic rollover handling.")
string ee_projection_detail = input.string("Compact", "Projection Detail", options=["Compact", "Expanded"], group=EE_GROUP)
bool ee_show_projection = input.bool(true, "Show Projection", group=EE_GROUP)
bool ee_show_level_labels = input.bool(true, "Show Level Labels", group=EE_GROUP, tooltip="Labels identify the displayed percentile levels. P25, P50, P75, and P90 are historical excursion quantiles, not probabilities of reaching a target.")
bool ee_show_price_in_labels = input.bool(false, "Show Price in Labels", group=EE_GROUP)
string ee_label_size_input = input.string("Tiny", "Level Label Size", options=["Tiny", "Small", "Normal", "Large"], group=EE_GROUP)
color ee_15m_base_color = input.color(color.aqua, "15m Projection Color", group=EE_GROUP)
color ee_1h_base_color = input.color(color.aqua, "1H Projection Color", group=EE_GROUP)
color ee_4h_base_color = input.color(color.aqua, "4H Projection Color", group=EE_GROUP)
bool ee_show_panel = input.bool(true, "Show Information Panel", group=EE_GROUP)
int ee_projection_length = input.int(12, "Projection Length (Chart Bars)", minval=1, maxval=100, group=EE_GROUP)
bool ee_show_fill = input.bool(true, "Show P25–P75 Fill", group=EE_GROUP)
bool ee_show_manual_target = input.bool(true, "Show Manual Target Analysis", group=EE_GROUP)
float ee_manual_target = input.price(0.0, "Manual Target Price (0 = off)", group=EE_GROUP)
color ee_p50_color = input.color(color.new(color.aqua,20), "P50 Line Color", group=EE_GROUP)
color ee_range_color = input.color(color.new(color.aqua,65), "P25 / P75 Line Color", group=EE_GROUP)
color ee_p90_color = input.color(color.new(color.orange,40), "P90 Line Color", group=EE_GROUP)
int ee_fill_transparency = input.int(92, "Fill Transparency", minval=0, maxval=100, group=EE_GROUP)
string ee_panel_detail = input.string("Compact", "Panel Detail", options=["Compact", "Expanded"], group=EE_GROUP)
bool ee_show_4h_detail = input.bool(false, 'Show 4H Data Integrity Details', group=EE_GROUP)
string ee_4h_rollover_fallback_setting = input.string("On", "4H Rollover ATR Fallback", options=["On", "Off"], group=EE_GROUP, tooltip="On allows an ATR-based display during 4H contract rollover when ordinary historical expansion is unavailable. The information panel discloses fallback mode; it is not historically validated rollover expansion data.")

string DEE_GROUP = 'Expected Expansion — Daily'
bool dee_enabled = input.bool(false, "Show Daily Expected Expansion", group=DEE_GROUP, tooltip="Shows Daily historical expansion levels derived from the Daily research model; these are excursion quantiles, not guaranteed targets.")
string dee_display_mode = input.string("P25 / P50 / P75", "Daily Levels", options=["P25 / P50 / P75", "P50 only"], group=DEE_GROUP)
bool dee_show_status = input.bool(false, 'Show Daily Model Status', group=DEE_GROUP)
string dee_label_size_input = input.string("Tiny", "Daily Label Size", options=["Tiny", "Small", "Normal", "Large"], group=DEE_GROUP)
color dee_base_color = input.color(color.aqua, "Daily Projection Color", group=DEE_GROUP)

string group_cisd = 'CISD — Levels & Appearance'
cisd_show = input.bool(false, 'Show CISD 1', group=group_cisd, inline='cisd1', tooltip="Change in State of Delivery: tracks the active delivery bias on a chosen timeframe and marks the level where price closes back through it (a CISD confirmation), plus the protected swing that invalidates it.")
cisd_tf_mode = input.string('Current Timeframe', '', options=['Current Timeframe', 'Custom'], group=group_cisd, inline='cisd1')
cisd_custom_tf = input.timeframe('60', '', group=group_cisd, inline='cisd1')
cisd2_show = input.bool(false, 'Show CISD 2', group=group_cisd, inline='cisd2', tooltip="A second, independent CISD tracked on its own timeframe.")
cisd2_tf = input.timeframe('15', '', group=group_cisd, inline='cisd2')
cisd3_show = input.bool(false, 'Show CISD 3', group=group_cisd, inline='cisd3', tooltip="A third, independent CISD tracked on its own timeframe.")
cisd3_tf = input.timeframe('60', '', group=group_cisd, inline='cisd3')
cisd_bull_color = input.color(color.lime, 'Bullish', group=group_cisd, inline='cisdcolor')
cisd_bear_color = input.color(color.red, 'Bearish', group=group_cisd, inline='cisdcolor')
cisd_show_developing = input.bool(false, 'Show Developing CISD Level', group=group_cisd, tooltip="A short projected line at the current live delivery level, updating in real time until it either confirms or the bias resets. Applies to every enabled CISD.")
cisd_show_confirmed = input.bool(true, 'Show Confirmed CISD Level', group=group_cisd, tooltip="A line marking the most recent confirmed CISD, from where the level originated to the candle that confirmed it. Applies to every enabled CISD.")
cisd_show_protected = input.bool(false, 'Show Protected Swing (PSL/PSH)', group=group_cisd, tooltip="Marks the swing that must hold for the most recent confirmed CISD to remain valid. Applies to every enabled CISD.")
cisd_line_width = input.int(2, 'Line Width', minval=1, maxval=5, group=group_cisd)

string group_ict = 'ICT — Time Anchors'
bool ict_show_midnight_boundary = input.bool(false, "Show 12AM NY Boundary", group=group_ict, tooltip="Draws an independent vertical boundary at 12AM New York time; the 12AM open line can remain off.")
color ict_midnight_boundary_color = input.color(color.new(color.silver, 65), "12AM NY Boundary Color", group=group_ict, inline="ict_mb")
string ict_midnight_boundary_style_input = input.string("Dotted", "Style", options=["Solid", "Dashed", "Dotted"], group=group_ict, inline="ict_mb")
int ict_midnight_boundary_width = input.int(1, "Width", minval=1, maxval=5, group=group_ict, inline="ict_mb")
bool ict_show_midnight_open = input.bool(false, "Show 12AM NY Open", group=group_ict, tooltip="Draws the exact 12AM America/New_York open price, captured from 1-minute data. New York daylight saving time is handled automatically.")
color ict_midnight_open_color = input.color(color.new(color.aqua, 25), "12AM NY Open Color", group=group_ict, inline="ict_mo")
string ict_midnight_open_style_input = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=group_ict, inline="ict_mo")
int ict_midnight_open_width = input.int(1, "Width", minval=1, maxval=5, group=group_ict, inline="ict_mo")
bool ict_show_midnight_open_label = input.bool(true, "Show 12AM NY Open Label", group=group_ict, inline="ict_mol")
string ict_midnight_open_label_size_input = input.string("Tiny", "12AM NY Open Label Size", options=["Tiny", "Small", "Normal", "Large"], group=group_ict, inline="ict_mol")
bool ict_show_0830_open = input.bool(false, "Show 8:30 NY Open", group=group_ict, tooltip="Draws the exact 8:30 America/New_York open price, captured from 1-minute data. New York daylight saving time is handled automatically.")
color ict_0830_open_color = input.color(color.new(color.orange, 20), "8:30 NY Open Color", group=group_ict, inline="ict_830o")
string ict_0830_open_style_input = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=group_ict, inline="ict_830o")
int ict_0830_open_width = input.int(1, "Width", minval=1, maxval=5, group=group_ict, inline="ict_830o")
bool ict_show_0830_open_label = input.bool(true, "Show 8:30 NY Open Label", group=group_ict, inline="ict_830ol")
string ict_0830_open_label_size_input = input.string("Tiny", "8:30 NY Open Label Size", options=["Tiny", "Small", "Normal", "Large"], group=group_ict, inline="ict_830ol")
bool ict_show_0830_boundary = input.bool(false, "Show 8:30 NY Boundary", group=group_ict, tooltip="Draws an independent vertical boundary at 8:30 New York time; the 8:30 open line can remain off.")
color ict_0830_boundary_color = input.color(color.new(color.orange, 65), '8:30 NY Boundary Color', group=group_ict, inline="ict_830b")
string ict_0830_boundary_style_input = input.string("Dotted", "Style", options=["Solid", "Dashed", "Dotted"], group=group_ict, inline="ict_830b")
int ict_0830_boundary_width = input.int(1, "Width", minval=1, maxval=5, group=group_ict, inline="ict_830b")
int ict_days_to_show = input.int(5, "Days to Show", minval=1, maxval=20, group=group_ict)

string group_style = 'HTF Candles — Appearance'
htf_bull_body = input.color(color.new(#e6e6e6, 10), 'Body  ', inline='body', group=group_style)
htf_bear_body = input.color(color.new(#636363, 10), '', inline='body', group=group_style)
htf_bull_border = input.color(color.new(#e6e6e6, 10), 'Borders', inline='borders', group=group_style)
htf_bear_border = input.color(color.new(#636363, 10), '', inline='borders', group=group_style)
htf_bull_wick = input.color(color.new(#e6e6e6, 10), 'Wick  ', inline='wick', group=group_style)
htf_bear_wick = input.color(color.new(#636363, 10), '', inline='wick', group=group_style)
htf_offset = input.int(30, 'Horizontal Offset', minval=1, group=group_style)
htf_candle_gap = input.int(1, 'Candle Spacing', minval=1, maxval=4, group=group_style)
htf_group_gap = input.int(10, 'HTF Spacing', minval=1, maxval=10, group=group_style)
htf_candle_width = input.int(1, 'Candle Width', minval=1, maxval=4, group=group_style) * 2

string group_label = 'HTF Candles — Labels & Timer'
htf_label_show = input.bool(true, 'HTF Label           ', group=group_label, inline='HTFlabel')
htf_label_color = input.color(color.new(#e6e6e6, 10), '', group=group_label, inline='HTFlabel')
htf_label_size = input.string(size.normal, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline='HTFlabel')
htf_label_bold = input.bool(false, title='Bold', group=group_label, inline='HTFlabel')
htf_label_position = input.string('Top', 'HTF Label Position', options=['Both', 'Top', 'Bottom'], group=group_label)
htf_label_alignment = input.string('Follow Candles', 'Label Alignment', options=['Align', 'Follow Candles'], group=group_label)
htf_timer_show = input.bool(true, 'Remaining Time      ', inline='timer', group=group_label)
htf_timer_color = input.color(color.new(#e6e6e6, 10), '', inline='timer', group=group_label)
htf_timer_size = input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline='timer')
htf_candle_time_show = input.bool(false, 'Candle Time        ', group=group_label, inline='dow')
htf_candle_time_color = input.color(#0f0f0f, '', group=group_label, inline='dow')
htf_candle_time_size = input.string(size.tiny, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline='dow')

string group_autoladder = 'HTF Candles — Auto Timeframes (Advanced)'
htf_max_sets = input.int(6, 'Maximum HTFs Displayed', minval=1, maxval=6, group=group_autoladder)
auto_rung1 = input.timeframe('1', 'Rung 1 (Smallest)', group=group_autoladder, inline='rung1', tooltip="These 8 rungs are just a menu of timeframe sizes, smallest to largest — they don't do anything by themselves. Below, check any HTF slot's Auto box and it will automatically pick from this list based on your current chart timeframe: HTF1 gets the first rung bigger than your chart, HTF2 gets the rung after that, HTF3 the one after that, and so on. Off by default — unchecked slots keep using their fixed timeframe as normal.")
auto_rung2 = input.timeframe('5', 'Rung 2', group=group_autoladder, inline='rung1')
auto_rung3 = input.timeframe('15', 'Rung 3', group=group_autoladder, inline='rung1')
auto_rung4 = input.timeframe('60', 'Rung 4', group=group_autoladder, inline='rung1')
auto_rung5 = input.timeframe('240', 'Rung 5', group=group_autoladder, inline='rung2')
auto_rung6 = input.timeframe('D', 'Rung 6', group=group_autoladder, inline='rung2')
auto_rung7 = input.timeframe('W', 'Rung 7', group=group_autoladder, inline='rung2')
auto_rung8 = input.timeframe('M', 'Rung 8 (Largest)', group=group_autoladder, inline='rung2')
htf1_auto = input.bool(false, 'HTF 1 Auto', group=group_autoladder, inline='autotoggle1', tooltip="Check to make this HTF slot auto-pick from the rungs above instead of using its own fixed timeframe setting.")
htf2_auto = input.bool(false, 'HTF 2 Auto', group=group_autoladder, inline='autotoggle1')
htf3_auto = input.bool(false, 'HTF 3 Auto', group=group_autoladder, inline='autotoggle1')
htf4_auto = input.bool(false, 'HTF 4 Auto', group=group_autoladder, inline='autotoggle2')
htf5_auto = input.bool(false, 'HTF 5 Auto', group=group_autoladder, inline='autotoggle2')
htf6_auto = input.bool(false, 'HTF 6 Auto', group=group_autoladder, inline='autotoggle2')

string group_tf_visibility = 'HTF Candles — Chart Visibility (Advanced)'
tf1_enabled = input.bool(false, 'TF 1', group=group_tf_visibility, inline='tf1', tooltip='Enable visibility control for this chart timeframe')
tf_slot_1 = input.timeframe('30S', '', group=group_tf_visibility, inline='tf1')
tf1_htf1 = input.bool(true, '1', group=group_tf_visibility, inline='tf1')
tf1_htf2 = input.bool(true, '2', group=group_tf_visibility, inline='tf1')
tf1_htf3 = input.bool(true, '3', group=group_tf_visibility, inline='tf1')
tf1_htf4 = input.bool(false, '4', group=group_tf_visibility, inline='tf1')
tf1_htf5 = input.bool(false, '5', group=group_tf_visibility, inline='tf1')
tf1_htf6 = input.bool(false, '6', group=group_tf_visibility, inline='tf1')
tf2_enabled = input.bool(false, 'TF 2', group=group_tf_visibility, inline='tf2')
tf_slot_2 = input.timeframe('1', '', group=group_tf_visibility, inline='tf2')
tf2_htf1 = input.bool(false, '1', group=group_tf_visibility, inline='tf2')
tf2_htf2 = input.bool(true, '2', group=group_tf_visibility, inline='tf2')
tf2_htf3 = input.bool(true, '3', group=group_tf_visibility, inline='tf2')
tf2_htf4 = input.bool(false, '4', group=group_tf_visibility, inline='tf2')
tf2_htf5 = input.bool(false, '5', group=group_tf_visibility, inline='tf2')
tf2_htf6 = input.bool(false, '6', group=group_tf_visibility, inline='tf2')
tf3_enabled = input.bool(false, 'TF 3', group=group_tf_visibility, inline='tf3')
tf_slot_3 = input.timeframe('3', '', group=group_tf_visibility, inline='tf3')
tf3_htf1 = input.bool(false, '1', group=group_tf_visibility, inline='tf3')
tf3_htf2 = input.bool(true, '2', group=group_tf_visibility, inline='tf3')
tf3_htf3 = input.bool(false, '3', group=group_tf_visibility, inline='tf3')
tf3_htf4 = input.bool(false, '4', group=group_tf_visibility, inline='tf3')
tf3_htf5 = input.bool(false, '5', group=group_tf_visibility, inline='tf3')
tf3_htf6 = input.bool(false, '6', group=group_tf_visibility, inline='tf3')
tf4_enabled = input.bool(false, 'TF 4', group=group_tf_visibility, inline='tf4')
tf_slot_4 = input.timeframe('5', '', group=group_tf_visibility, inline='tf4')
tf4_htf1 = input.bool(false, '1', group=group_tf_visibility, inline='tf4')
tf4_htf2 = input.bool(false, '2', group=group_tf_visibility, inline='tf4')
tf4_htf3 = input.bool(false, '3', group=group_tf_visibility, inline='tf4')
tf4_htf4 = input.bool(true, '4', group=group_tf_visibility, inline='tf4')
tf4_htf5 = input.bool(false, '5', group=group_tf_visibility, inline='tf4')
tf4_htf6 = input.bool(false, '6', group=group_tf_visibility, inline='tf4')
tf5_enabled = input.bool(false, 'TF 5', group=group_tf_visibility, inline='tf5')
tf_slot_5 = input.timeframe('15', '', group=group_tf_visibility, inline='tf5')
tf5_htf1 = input.bool(false, '1', group=group_tf_visibility, inline='tf5')
tf5_htf2 = input.bool(false, '2', group=group_tf_visibility, inline='tf5')
tf5_htf3 = input.bool(false, '3', group=group_tf_visibility, inline='tf5')
tf5_htf4 = input.bool(false, '4', group=group_tf_visibility, inline='tf5')
tf5_htf5 = input.bool(true, '5', group=group_tf_visibility, inline='tf5')
tf5_htf6 = input.bool(false, '6', group=group_tf_visibility, inline='tf5')
tf6_enabled = input.bool(false, 'TF 6', group=group_tf_visibility, inline='tf6')
tf_slot_6 = input.timeframe('60', '', group=group_tf_visibility, inline='tf6')
tf6_htf1 = input.bool(false, '1', group=group_tf_visibility, inline='tf6')
tf6_htf2 = input.bool(false, '2', group=group_tf_visibility, inline='tf6')
tf6_htf3 = input.bool(false, '3', group=group_tf_visibility, inline='tf6')
tf6_htf4 = input.bool(false, '4', group=group_tf_visibility, inline='tf6')
tf6_htf5 = input.bool(true, '5', group=group_tf_visibility, inline='tf6')
tf6_htf6 = input.bool(true, '6', group=group_tf_visibility, inline='tf6')

string group_trace = 'HTF Candles — Traces & Price Labels (Advanced)'
htf_trace_show = input.bool(false, 'Show Trace Lines', group=group_trace)
htf_trace_o_color = input.color(color.new(color.gray, 50), 'Open    ', inline='1', group=group_trace)
htf_trace_o_style = input.string('····', '', options=['⎯⎯⎯', '----', '····'], inline='1', group=group_trace)
htf_trace_o_size = input.int(1, '', options=[1,2,3,4], inline='1', group=group_trace)
htf_trace_c_color = input.color(color.new(color.gray, 50), 'Close    ', inline='2', group=group_trace)
htf_trace_c_style = input.string('····', '', options=['⎯⎯⎯', '----', '····'], inline='2', group=group_trace)
htf_trace_c_size = input.int(1, '', options=[1,2,3,4], inline='2', group=group_trace)
htf_trace_h_color = input.color(color.new(color.gray, 50), 'High     ', inline='3', group=group_trace)
htf_trace_h_style = input.string('····', '', options=['⎯⎯⎯', '----', '····'], inline='3', group=group_trace)
htf_trace_h_size = input.int(1, '', options=[1,2,3,4], inline='3', group=group_trace)
htf_trace_l_color = input.color(color.new(color.gray, 50), 'Low     ', inline='4', group=group_trace)
htf_trace_l_style = input.string('····', '', options=['⎯⎯⎯', '----', '····'], inline='4', group=group_trace)
htf_trace_l_size = input.int(1, '', options=[1,2,3,4], inline='4', group=group_trace)
htf_trace_anchor = input.string('First Timeframe', 'Anchor To', options=['First Timeframe', 'Last Timeframe'], group=group_trace)
htf_price_labels_show = input.bool(false, 'Show Price Labels', inline='label', group=group_trace)
htf_price_label_color = input.color(color.new(#0f0f0f, 10), '', inline='label', group=group_trace)
htf_price_label_size = input.string(size.small, '', [size.tiny, size.small, size.normal, size.large, size.huge], inline='label', group=group_trace)

string group_boundary = 'HTF Candles — Period Boundaries (Advanced)'
show_htf_boundary = input.bool(false, 'Show HTF Period Boundary on Chart', group=group_boundary, tooltip="Draws a vertical line on the underlying price chart at the start of every period of the chosen timeframe — e.g. set to Daily to mark each day's open, works regardless of what chart timeframe you're viewing.")
htf_boundary_tf = input.timeframe('D', 'Boundary Timeframe', group=group_boundary)
htf_boundary_color = input.color(color.new(color.gray, 50), '', group=group_boundary, inline='boundarystyle')
htf_boundary_style = input.string('Dashed', '', options=['Solid', 'Dashed', 'Dotted'], group=group_boundary, inline='boundarystyle')
htf_boundary_width = input.int(1, '', minval=1, maxval=5, group=group_boundary, inline='boundarystyle')
htf_boundary_max_lines = input.int(50, 'Maximum Boundary Lines to Keep', minval=1, maxval=200, group=group_boundary)

// Frozen CISD 1 timeframe resolution. This is shared product state, not HTF renderer state.
cisd_resolved_tf = cisd_tf_mode == 'Current Timeframe' ? timeframe.period : cisd_custom_tf

htf_line_style(string value) => value == 'Dashed' or value == '----' ? line.style_dashed : value == 'Dotted' or value == '····' ? line.style_dotted : line.style_solid
confirmed_swing_style_value = htf_line_style(confirmed_swing_style)
potential_swing_style_value = htf_line_style(potential_swing_style)
eq_line_style_value = htf_line_style(eq_line_style_input)
sweep_line_style_value = htf_line_style(sweep_line_style)
htf_boundary_style_value = htf_line_style(htf_boundary_style)

htf_name(string tf) =>
    float seconds = timeframe.in_seconds(tf)
    seconds < 60 ? str.tostring(seconds) + 's' : seconds < 3600 ? str.tostring(seconds / 60) + 'm' : seconds < 86400 ? str.tostring(seconds / 3600) + 'H' : tf

htf_remaining(string tf) =>
    if barstate.isrealtime
        bool wallClockBelongsToBar = timenow >= time and timenow <= time_close
        int executionClock = wallClockBelongsToBar ? timenow : time_close
        int total = math.max(0, int(math.floor((time_close(tf) - executionClock) / 1000)))
        int dayRemainder = total % 86400
        int wholeDays = int((total - dayRemainder) / 86400)
        int clockHours = int(dayRemainder / 3600)
        int clockMinutes = int((dayRemainder % 3600) / 60)
        int clockSeconds = dayRemainder % 60
        string ss = str.tostring(clockSeconds, '00')
        string mmss = str.tostring(clockMinutes, '00') + ':' + ss
        string hhmmss = str.tostring(clockHours, '00') + ':' + mmss
        total < 60 ? ss : total < 3600 ? mmss : wholeDays == 0 ? hhmmss : str.tostring(wholeDays) + 'D ' + hhmmss
    else
        'n/a'

htf_auto_timeframe(int slot) =>
    array<string> ladder = array.from(auto_rung1, auto_rung2, auto_rung3, auto_rung4, auto_rung5, auto_rung6, auto_rung7, auto_rung8)
    float hostDuration = timeframe.in_seconds()
    int passedRungs = 0
    for rung in ladder
        passedRungs += timeframe.in_seconds(rung) <= hostDuration ? 1 : 0
    int destinationRank = math.min(passedRungs + slot, array.size(ladder) - 1)
    array.get(ladder, destinationRank)

htf_slot_config(int slot) =>
    bool show = switch slot
        0 => slot1_show
        1 => slot2_show
        2 => slot3_show
        3 => slot4_show
        4 => slot5_show
        => slot6_show
    string manual = switch slot
        0 => slot1_tf
        1 => slot2_tf
        2 => slot3_tf
        3 => slot4_tf
        4 => slot5_tf
        => slot6_tf
    bool automatic = switch slot
        0 => htf1_auto
        1 => htf2_auto
        2 => htf3_auto
        3 => htf4_auto
        4 => htf5_auto
        => htf6_auto
    int maximum = switch slot
        0 => slot1_max
        1 => slot2_max
        2 => slot3_max
        3 => slot4_max
        4 => slot5_max
        => slot6_max
    HtfSlotConfig.new(show, automatic ? htf_auto_timeframe(slot) : manual, maximum)

htf_slot_alerts(int slot) => switch slot
    0 => alert_htf1_enable
    1 => alert_htf2_enable
    2 => alert_htf3_enable
    3 => alert_htf4_enable
    4 => alert_htf5_enable
    => alert_htf6_enable

htf_valid_timeframe(string tf) =>
    float hostDuration = timeframe.in_seconds()
    float htfDuration = timeframe.in_seconds(tf)
    bool ascends = htfDuration > hostDuration
    bool calendarScale = htfDuration >= timeframe.in_seconds('D')
    bool wholeHostBars = htfDuration % hostDuration == 0
    ascends and (calendarScale or wholeHostBars)

var array<bool> htf_visibility_row_enabled = array.from(tf1_enabled, tf2_enabled, tf3_enabled, tf4_enabled, tf5_enabled, tf6_enabled)
var array<string> htf_visibility_row_timeframe = array.from(tf_slot_1, tf_slot_2, tf_slot_3, tf_slot_4, tf_slot_5, tf_slot_6)
var array<bool> htf_visibility_cells = array.from(tf1_htf1, tf1_htf2, tf1_htf3, tf1_htf4, tf1_htf5, tf1_htf6, tf2_htf1, tf2_htf2, tf2_htf3, tf2_htf4, tf2_htf5, tf2_htf6, tf3_htf1, tf3_htf2, tf3_htf3, tf3_htf4, tf3_htf5, tf3_htf6, tf4_htf1, tf4_htf2, tf4_htf3, tf4_htf4, tf4_htf5, tf4_htf6, tf5_htf1, tf5_htf2, tf5_htf3, tf5_htf4, tf5_htf5, tf5_htf6, tf6_htf1, tf6_htf2, tf6_htf3, tf6_htf4, tf6_htf5, tf6_htf6)

htf_visibility(int slot, bool fallback) =>
    bool matched = false
    bool visible = false
    for row = 0 to array.size(htf_visibility_row_enabled) - 1
        if array.get(htf_visibility_row_enabled, row) and array.get(htf_visibility_row_timeframe, row) == timeframe.period
            matched := true
            visible := visible or array.get(htf_visibility_cells, row * 6 + slot)
    matched ? visible : fallback

htf_custom_daily_key() =>
    int boundaryMinute = htf_custom_daily == 'Midnight' ? 0 : htf_custom_daily == '8:30' ? 510 : 570
    int localMinute = hour(time, 'America/New_York') * 60 + minute(time, 'America/New_York')
    int calendarStamp = localMinute >= boundaryMinute ? time : time - 12 * 60 * 60 * 1000
    year(calendarStamp, 'America/New_York') * 10000 + month(calendarStamp, 'America/New_York') * 100 + dayofmonth(calendarStamp, 'America/New_York')

htf_caption(string tf, int stamp) =>
    string result = ''
    if tf == '1D'
        result := switch dayofweek(time_tradingday, 'America/New_York')
            dayofweek.monday => 'M'
            dayofweek.tuesday => 'T'
            dayofweek.wednesday => 'W'
            dayofweek.thursday => 'T'
            dayofweek.friday => 'F'
            dayofweek.saturday => 'S'
            dayofweek.sunday => 'S'
            => ''
    else if timeframe.in_seconds(tf) < timeframe.in_seconds('D')
        result := str.format_time(stamp, 'HH:mm', 'America/New_York')
    else if tf == '1M'
        result := str.format_time(stamp, 'M', 'America/New_York')
    result

htf_new_bar(int periodId, string tf) => HtfBarState.new(open, high, low, close, periodId, time, bar_index, bar_index, bar_index, bar_index, htf_caption(tf, time), false)

htf_classify(HtfBarState current, HtfBarState previous, HtfBarState beforePrevious) =>
    bool outside = current.l < previous.l and current.h > previous.h
    bool bullC2 = current.l < previous.l and current.c > previous.l and not outside
    bool bearC2 = current.h > previous.h and current.c < previous.h and not outside
    bool previousBullC2 = not na(beforePrevious) and previous.l < beforePrevious.l and previous.c > beforePrevious.l
    bool previousBearC2 = not na(beforePrevious) and previous.h > beforePrevious.h and previous.c < beforePrevious.h
    float previousTop = math.max(previous.o, previous.c)
    float previousBottom = math.min(previous.o, previous.c)
    bool bullC3 = previous.c < previous.o and current.l >= previous.l and current.o <= previousBottom and current.c > previousTop and not previousBullC2 and not bullC2 and not bearC2
    bool bearC3 = previous.c > previous.o and current.h <= previous.h and current.o >= previousTop and current.c < previousBottom and not previousBearC2 and not bullC2 and not bearC2
    [bullC2, bearC2, bullC3, bearC3]

htf_emit_close_alerts(HtfSlotState state, string tf, bool enabled) =>
    if enabled and array.size(state.bars) >= 3
        HtfBarState current = array.get(state.bars, 1)
        HtfBarState previous = array.get(state.bars, 2)
        HtfBarState earlier = array.size(state.bars) >= 4 ? array.get(state.bars, 3) : na
        [bullC2, bearC2, bullC3, bearC3] = htf_classify(current, previous, earlier)
        string name = htf_name(tf)
        if alert_c2_closure_enable and bullC2
            alert(syminfo.ticker + ' ' + name + ' C2 Closure (Bullish) — swept prior low, closed back inside range', alert.freq_once_per_bar_close)
        if alert_c2_closure_enable and bearC2
            alert(syminfo.ticker + ' ' + name + ' C2 Closure (Bearish) — swept prior high, closed back inside range', alert.freq_once_per_bar_close)
        if alert_c3_reversal_enable and bullC3
            alert(syminfo.ticker + ' ' + name + ' C3 Reversal (Bullish) — engulfing close over prior body, no sweep', alert.freq_once_per_bar_close)
        if alert_c3_reversal_enable and bearC3
            alert(syminfo.ticker + ' ' + name + ' C3 Reversal (Bearish) — engulfing close below prior body, no sweep', alert.freq_once_per_bar_close)

// Causal period engine. It owns only market state and emits a close serial.
htf_ingest(HtfSlotState state, HtfSlotConfig config, bool alertEnabled) =>
    int standardId = time(config.timeframe, 'America/New_York')
    bool custom = htf_use_custom_daily and config.timeframe == '1D'
    int periodKey = custom ? htf_custom_daily_key() : standardId
    bool empty = array.size(state.bars) == 0
    bool changed = not empty and periodKey != array.get(state.bars, 0).period_id
    if empty
        array.unshift(state.bars, htf_new_bar(periodKey, config.timeframe))
    else if changed
        HtfBarState finished = array.get(state.bars, 0)
        finished.completed := true
        array.set(state.bars, 0, finished)
        array.unshift(state.bars, htf_new_bar(periodKey, config.timeframe))
        state.close_serial += 1
        htf_emit_close_alerts(state, config.timeframe, alertEnabled)
    else
        HtfBarState live = array.get(state.bars, 0)
        if high > live.h
            live.h := high
            live.high_index := bar_index
        if low < live.l
            live.l := low
            live.low_index := bar_index
        live.c := close
        live.close_index := bar_index
        array.set(state.bars, 0, live)
    while array.size(state.bars) > config.max_bars
        array.pop(state.bars)

htf_delete_candle_view(HtfCandleView view) =>
    box.delete(view.body)
    line.delete(view.upper_wick)
    line.delete(view.lower_wick)
    label.delete(view.time_label)
    line.delete(view.swing_high)
    line.delete(view.swing_low)
    line.delete(view.equilibrium)
    label.delete(view.offset_signal)
    label.delete(view.chart_signal)
    line.delete(view.chart_high_sweep)
    line.delete(view.chart_low_sweep)

htf_clear_trace(HtfSlotView view) =>
    line.delete(view.trace_o)
    line.delete(view.trace_h)
    line.delete(view.trace_l)
    line.delete(view.trace_c)
    label.delete(view.trace_o_label)
    label.delete(view.trace_h_label)
    label.delete(view.trace_l_label)
    label.delete(view.trace_c_label)
    view.trace_o := na
    view.trace_h := na
    view.trace_l := na
    view.trace_c := na
    view.trace_o_label := na
    view.trace_h_label := na
    view.trace_l_label := na
    view.trace_c_label := na
    view

htf_clear_slot(HtfSlotView view) =>
    while array.size(view.candles) > 0
        htf_delete_candle_view(array.pop(view.candles))
    while array.size(view.imbalances) > 0
        box.delete(array.pop(view.imbalances))
    label.delete(view.name_top)
    label.delete(view.name_bottom)
    label.delete(view.timer_top)
    label.delete(view.timer_bottom)
    view.name_top := na
    view.name_bottom := na
    view.timer_top := na
    view.timer_bottom := na
    htf_clear_trace(view)
    view

htf_sync_view_count(HtfSlotState state, HtfSlotView view) =>
    if view.rendered_serial != state.close_serial
        array.unshift(view.candles, HtfCandleView.new())
        view.rendered_serial := state.close_serial
    while array.size(view.candles) < array.size(state.bars)
        array.push(view.candles, HtfCandleView.new())
    while array.size(view.candles) > array.size(state.bars)
        htf_delete_candle_view(array.pop(view.candles))

htf_slot_high(HtfSlotState state) =>
    float result = 0.0
    for bar in state.bars
        result := math.max(result, bar.h)
    result

htf_slot_low(HtfSlotState state, float initial) =>
    float result = initial
    for bar in state.bars
        result := math.min(result, bar.l)
    result

htf_group_origin(int offset) => bar_index + offset

htf_chronological_ordinal(int count, int newestFirstIndex) => count - newestFirstIndex - 1

htf_candle_left(int groupOrigin, int ordinal) => groupOrigin + ordinal * (htf_candle_width + htf_candle_gap)

htf_render_candles(HtfSlotState state, HtfSlotView view, int offset) =>
    htf_sync_view_count(state, view)
    int count = array.size(state.bars)
    if count > 0
        for i = 0 to count - 1
            HtfBarState bar = array.get(state.bars, i)
            HtfCandleView glyph = array.get(view.candles, i)
            int left = htf_candle_left(htf_group_origin(offset), htf_chronological_ordinal(count, i))
            int right = left + htf_candle_width
            int center = left + htf_candle_width / 2
            bool bull = bar.c > bar.o
            float bodyTop = math.max(bar.o, bar.c)
            float bodyBottom = math.min(bar.o, bar.c)
            if na(glyph.body)
                glyph.body := box.new(left, bodyTop, right, bodyBottom, border_color=bull ? htf_bull_border : htf_bear_border, border_width=1, bgcolor=bull ? htf_bull_body : htf_bear_body)
                glyph.upper_wick := line.new(center, bar.h, center, bodyTop, color=bull ? htf_bull_wick : htf_bear_wick)
                glyph.lower_wick := line.new(center, bodyBottom, center, bar.l, color=bull ? htf_bull_wick : htf_bear_wick)
                line.set_color(glyph.lower_wick, bull ? htf_bull_wick : htf_bear_wick)
            else
                box.set_lefttop(glyph.body, left, bodyTop)
                box.set_rightbottom(glyph.body, right, bodyBottom)
                box.set_bgcolor(glyph.body, bull ? htf_bull_body : htf_bear_body)
                box.set_border_color(glyph.body, bull ? htf_bull_border : htf_bear_border)
                line.set_xy1(glyph.upper_wick, center, bar.h)
                line.set_xy2(glyph.upper_wick, center, bodyTop)
                line.set_color(glyph.upper_wick, bull ? htf_bull_wick : htf_bear_wick)
                line.set_xy1(glyph.lower_wick, center, bodyBottom)
                line.set_xy2(glyph.lower_wick, center, bar.l)
                line.set_color(glyph.lower_wick, bull ? htf_bull_wick : htf_bear_wick)
            if htf_candle_time_show
                if na(glyph.time_label)
                    glyph.time_label := label.new(center, bar.l, bar.caption, color=color.new(color.white, 100), textcolor=htf_candle_time_color, style=label.style_label_up, size=htf_candle_time_size, text_font_family=font.family_monospace)
                    label.set_text(glyph.time_label, bar.caption)
                else
                    label.set_xy(glyph.time_label, center, bar.l)
                    label.set_text(glyph.time_label, bar.caption)
            else
                label.delete(glyph.time_label)
                glyph.time_label := na
                label.delete(glyph.time_label)
            array.set(view.candles, i, glyph)
    view

htf_render_structure(HtfSlotState state, HtfSlotView view, int offset) =>
    int count = array.size(state.bars)
    if count >= 2
        for i = 1 to count - 1
            HtfBarState base = array.get(state.bars, i)
            HtfBarState next = array.get(state.bars, i - 1)
            HtfCandleView glyph = array.get(view.candles, i)
            int baseCenter = htf_candle_left(htf_group_origin(offset), htf_chronological_ordinal(count, i)) + htf_candle_width / 2
            int nextRight = htf_candle_left(htf_group_origin(offset), htf_chronological_ordinal(count, i - 1)) + htf_candle_width + swing_overshoot
            bool highPotential = i == 1 and next.h > base.h
            bool highConfirmed = i > 1 and next.h > base.h and next.c < base.h
            bool lowPotential = i == 1 and next.l < base.l
            bool lowConfirmed = i > 1 and next.l < base.l and next.c > base.l
            if show_swing_lines and (highPotential or highConfirmed)
                if na(glyph.swing_high)
                    glyph.swing_high := line.new(baseCenter, base.h, nextRight, base.h, color=swing_high_color, width=swing_line_width)
                line.set_xy1(glyph.swing_high, baseCenter, base.h)
                line.set_xy2(glyph.swing_high, nextRight, base.h)
                line.set_style(glyph.swing_high, highConfirmed ? confirmed_swing_style_value : potential_swing_style_value)
            else if i > 1 or not show_swing_lines
                line.delete(glyph.swing_high)
                glyph.swing_high := na
                line.delete(glyph.swing_high)
            if show_swing_lines and (lowPotential or lowConfirmed)
                if na(glyph.swing_low)
                    glyph.swing_low := line.new(baseCenter, base.l, nextRight, base.l, color=swing_low_color, width=swing_line_width)
                line.set_xy1(glyph.swing_low, baseCenter, base.l)
                line.set_xy2(glyph.swing_low, nextRight, base.l)
                line.set_style(glyph.swing_low, lowConfirmed ? confirmed_swing_style_value : potential_swing_style_value)
            else if i > 1 or not show_swing_lines
                line.delete(glyph.swing_low)
                glyph.swing_low := na
                line.delete(glyph.swing_low)
            bool drawEq = show_eq_line and (not eq_previous_only or i == 1)
            if drawEq
                float equilibrium = (base.h + base.l) / 2
                int x1 = htf_candle_left(htf_group_origin(offset), htf_chronological_ordinal(count, i)) + htf_candle_width
                int x2 = htf_candle_left(htf_group_origin(offset), htf_chronological_ordinal(count, i - 1)) + htf_candle_width
                if na(glyph.equilibrium)
                    glyph.equilibrium := line.new(x1, equilibrium, x2, equilibrium, color=eq_line_color, width=eq_line_width, style=eq_line_style_value)
                    line.set_y2(glyph.equilibrium, equilibrium)
                else
                    line.set_xy1(glyph.equilibrium, x1, equilibrium)
                    line.set_xy2(glyph.equilibrium, x2, equilibrium)
            else
                line.delete(glyph.equilibrium)
                glyph.equilibrium := na
                line.delete(glyph.equilibrium)
            if i + 1 < count
                HtfBarState previous = array.get(state.bars, i + 1)
                HtfBarState earlier = i + 2 < count ? array.get(state.bars, i + 2) : na
                [bullC2, bearC2, bullC3, bearC3] = htf_classify(base, previous, earlier)
                string signal = bullC2 or bearC2 ? 'C2' : bullC3 or bearC3 ? 'C3' : na
                bool bearish = bearC2 or bearC3
                color signalColor = bearish ? c2c3_bear_color : c2c3_bull_color
                int signalX = htf_candle_left(htf_group_origin(offset), htf_chronological_ordinal(count, i)) + htf_candle_width / 2
                if show_c2c3_offset_labels and not na(signal)
                    float signalY = base.l - (base.h - base.l) * 0.15
                    if na(glyph.offset_signal)
                        glyph.offset_signal := label.new(signalX, signalY, signal, color=color.new(color.white, 100), textcolor=signalColor, style=label.style_label_up, size=size.tiny, text_font_family=font.family_monospace)
                        label.set_text(glyph.offset_signal, signal)
                    else
                        label.set_xy(glyph.offset_signal, signalX, signalY)
                        label.set_text(glyph.offset_signal, signal)
                        label.set_textcolor(glyph.offset_signal, signalColor)
                else
                    label.delete(glyph.offset_signal)
                    glyph.offset_signal := na
                    label.delete(glyph.offset_signal)
                if show_c2c3_chart_labels and not na(signal)
                    float signalY = bearish ? base.h : base.l
                    if na(glyph.chart_signal)
                        glyph.chart_signal := label.new(base.close_index, signalY, signal, xloc=xloc.bar_index, color=color.new(color.white, 100), textcolor=signalColor, style=bearish ? label.style_label_down : label.style_label_up, size=size.tiny, text_font_family=font.family_monospace)
                        label.set_text(glyph.chart_signal, signal)
                    else
                        label.set_xy(glyph.chart_signal, base.close_index, signalY)
                        label.set_text(glyph.chart_signal, signal)
                        label.set_textcolor(glyph.chart_signal, signalColor)
                else
                    label.delete(glyph.chart_signal)
                    glyph.chart_signal := na
                    label.delete(glyph.chart_signal)
                bool confirmedOnly = sweep_line_type == 'Confirmed (C2 Closures)'
                bool lowSweep = confirmedOnly ? bullC2 : base.l < previous.l
                bool highSweep = confirmedOnly ? bearC2 : base.h > previous.h
                if show_sweep_lines_on_chart and lowSweep
                    if na(glyph.chart_low_sweep)
                        glyph.chart_low_sweep := line.new(previous.low_index, previous.l, base.low_index, previous.l, xloc=xloc.bar_index, color=sweep_line_color, width=sweep_line_width, style=sweep_line_style_value)
                        line.set_y2(glyph.chart_low_sweep, previous.l)
                    else
                        line.set_xy1(glyph.chart_low_sweep, previous.low_index, previous.l)
                        line.set_xy2(glyph.chart_low_sweep, base.low_index, previous.l)
                else
                    line.delete(glyph.chart_low_sweep)
                    glyph.chart_low_sweep := na
                    line.delete(glyph.chart_low_sweep)
                if show_sweep_lines_on_chart and highSweep
                    if na(glyph.chart_high_sweep)
                        glyph.chart_high_sweep := line.new(previous.high_index, previous.h, base.high_index, previous.h, xloc=xloc.bar_index, color=sweep_line_color, width=sweep_line_width, style=sweep_line_style_value)
                        line.set_y2(glyph.chart_high_sweep, previous.h)
                    else
                        line.set_xy1(glyph.chart_high_sweep, previous.high_index, previous.h)
                        line.set_xy2(glyph.chart_high_sweep, base.high_index, previous.h)
                else
                    line.delete(glyph.chart_high_sweep)
                    glyph.chart_high_sweep := na
                    line.delete(glyph.chart_high_sweep)
            array.set(view.candles, i, glyph)
    view

htf_render_imbalances(HtfSlotState state, HtfSlotView view, int offset) =>
    while array.size(view.imbalances) > 0
        box.delete(array.pop(view.imbalances))
    int count = array.size(state.bars)
    if barstate.islast and htf_fvg_show and count > 3
        for i = 0 to count - 3
            HtfBarState recent = array.get(state.bars, i)
            HtfBarState old = array.get(state.bars, i + 2)
            int recentRight = htf_candle_left(htf_group_origin(offset), htf_chronological_ordinal(count, i)) + htf_candle_width
            int oldLeft = htf_candle_left(htf_group_origin(offset), htf_chronological_ordinal(count, i + 2))
            if recent.l > old.h and math.min(recent.o, recent.c) > math.max(old.o, old.c)
                array.push(view.imbalances, box.new(oldLeft, old.h, recentRight, recent.l, bgcolor=htf_fvg_color, border_color=color.new(color.white, 100)))
            if recent.h < old.l and math.max(recent.o, recent.c) < math.min(old.o, old.c)
                array.push(view.imbalances, box.new(recentRight, recent.h, oldLeft, old.l, bgcolor=htf_fvg_color, border_color=color.new(color.white, 100)))
    if barstate.islast and htf_vi_show and count > 2
        for i = 0 to count - 2
            HtfBarState recent = array.get(state.bars, i)
            HtfBarState old = array.get(state.bars, i + 1)
            int recentRight = htf_candle_left(htf_group_origin(offset), htf_chronological_ordinal(count, i)) + htf_candle_width
            int oldLeft = htf_candle_left(htf_group_origin(offset), htf_chronological_ordinal(count, i + 1))
            if recent.l < old.h and math.min(recent.o, recent.c) > math.max(old.o, old.c)
                array.push(view.imbalances, box.new(oldLeft, math.min(recent.o, recent.c), recentRight, math.max(old.o, old.c), bgcolor=htf_vi_color, border_color=color.new(color.white, 100)))
            if recent.h > old.l and math.max(recent.o, recent.c) < math.min(old.o, old.c)
                array.push(view.imbalances, box.new(recentRight, math.min(old.o, old.c), oldLeft, math.max(recent.o, recent.c), bgcolor=htf_vi_color, border_color=color.new(color.white, 100)))
    view

htf_render_group_labels(HtfSlotState state, HtfSlotView view, string tf, int offset, float top, float bottom) =>
    int count = array.size(state.bars)
    if count > 0 and barstate.islast and htf_label_show
        int center = bar_index + offset + (htf_candle_width + htf_candle_gap) * (count - 1) / 2
        string groupText = htf_name(tf)
        if count >= 2
            HtfBarState live = array.get(state.bars, 0)
            HtfBarState prior = array.get(state.bars, 1)
            if live.h > prior.h
                groupText += ' ▽'
            if live.l < prior.l
                groupText += ' △'
        string topText = groupText + (htf_timer_show ? '\n' : '') + (htf_candle_time_show ? '\n' : '')
        string bottomText = (htf_timer_show ? '\n' : '') + groupText
        string timerText = '[' + htf_remaining(tf) + ']' + (htf_candle_time_show ? '\n' : '')
        if htf_label_position == 'Both' or htf_label_position == 'Top'
            if na(view.name_top)
                if htf_label_bold
                    view.name_top := label.new(center, top, topText, color=color.new(color.white, 100), textcolor=htf_label_color, style=label.style_label_down, size=htf_label_size, text_font_family=font.family_monospace, text_formatting=text.format_bold)
                else
                    view.name_top := label.new(center, top, topText, color=color.new(color.white, 100), textcolor=htf_label_color, style=label.style_label_down, size=htf_label_size, text_font_family=font.family_monospace)
                label.set_text(view.name_top, topText)
            else
                label.set_xy(view.name_top, center, top)
                label.set_text(view.name_top, topText)
            if htf_timer_show
                if na(view.timer_top)
                    view.timer_top := label.new(center, top, timerText, color=color.new(color.white, 100), textcolor=htf_timer_color, style=label.style_label_down, size=htf_timer_size, text_font_family=font.family_monospace)
                    label.set_text(view.timer_top, timerText)
                else
                    label.set_xy(view.timer_top, center, top)
                    label.set_text(view.timer_top, timerText)
        else
            label.delete(view.name_top)
            label.delete(view.timer_top)
            view.name_top := na
            view.timer_top := na
            label.delete(view.timer_top)
        if htf_label_position == 'Both' or htf_label_position == 'Bottom'
            if na(view.name_bottom)
                if htf_label_bold
                    view.name_bottom := label.new(center, bottom, bottomText, color=color.new(color.white, 100), textcolor=htf_label_color, style=label.style_label_up, size=htf_label_size, text_font_family=font.family_monospace, text_formatting=text.format_bold)
                else
                    view.name_bottom := label.new(center, bottom, bottomText, color=color.new(color.white, 100), textcolor=htf_label_color, style=label.style_label_up, size=htf_label_size, text_font_family=font.family_monospace)
                label.set_text(view.name_bottom, bottomText)
            else
                label.set_xy(view.name_bottom, center, bottom)
                label.set_text(view.name_bottom, bottomText)
            if htf_timer_show
                if na(view.timer_bottom)
                    view.timer_bottom := label.new(center, bottom, timerText, color=color.new(color.white, 100), textcolor=htf_timer_color, style=label.style_label_up, size=htf_timer_size, text_font_family=font.family_monospace)
                    label.set_text(view.timer_bottom, timerText)
                else
                    label.set_xy(view.timer_bottom, center, bottom)
                    label.set_text(view.timer_bottom, timerText)
        else
            label.delete(view.name_bottom)
            label.delete(view.timer_bottom)
            view.name_bottom := na
            view.timer_bottom := na
            label.delete(view.timer_bottom)
    else if not htf_label_show
        label.delete(view.name_top)
        label.delete(view.name_bottom)
        label.delete(view.timer_top)
        label.delete(view.timer_bottom)
        view.name_top := na
        view.name_bottom := na
        view.timer_top := na
        view.timer_bottom := na
        label.delete(view.timer_bottom)
    view

htf_render_trace(HtfSlotState state, HtfSlotView view, int offset, bool selected) =>
    if not selected or not htf_trace_show or array.size(state.bars) == 0
        htf_clear_trace(view)
    else if barstate.isrealtime or barstate.islast
        HtfBarState live = array.get(state.bars, 0)
        int left = htf_candle_left(htf_group_origin(offset), htf_chronological_ordinal(array.size(state.bars), 0))
        int right = left + htf_candle_width
        if na(view.trace_o)
            view.trace_o := line.new(live.open_index, live.o, left, live.o, xloc=xloc.bar_index, color=htf_trace_o_color, style=htf_line_style(htf_trace_o_style), width=htf_trace_o_size)
            view.trace_h := line.new(live.high_index, live.h, left + htf_candle_width / 2, live.h, xloc=xloc.bar_index, color=htf_trace_h_color, style=htf_line_style(htf_trace_h_style), width=htf_trace_h_size)
            view.trace_l := line.new(live.low_index, live.l, left + htf_candle_width / 2, live.l, xloc=xloc.bar_index, color=htf_trace_l_color, style=htf_line_style(htf_trace_l_style), width=htf_trace_l_size)
            view.trace_c := line.new(live.close_index, live.c, left, live.c, xloc=xloc.bar_index, color=htf_trace_c_color, style=htf_line_style(htf_trace_c_style), width=htf_trace_c_size)
            line.set_y2(view.trace_c, live.c)
        else
            line.set_xy1(view.trace_o, live.open_index, live.o)
            line.set_xy2(view.trace_o, left, live.o)
            line.set_xy1(view.trace_h, live.high_index, live.h)
            line.set_xy2(view.trace_h, left + htf_candle_width / 2, live.h)
            line.set_xy1(view.trace_l, live.low_index, live.l)
            line.set_xy2(view.trace_l, left + htf_candle_width / 2, live.l)
            line.set_xy1(view.trace_c, live.close_index, live.c)
            line.set_xy2(view.trace_c, left, live.c)
        if htf_price_labels_show
            if na(view.trace_o_label)
                view.trace_o_label := label.new(right, live.o, str.tostring(live.o), style=label.style_label_left, size=htf_price_label_size, color=color.new(color.white, 100), textcolor=htf_price_label_color)
                view.trace_h_label := label.new(right, live.h, str.tostring(live.h), style=label.style_label_left, size=htf_price_label_size, color=color.new(color.white, 100), textcolor=htf_price_label_color)
                view.trace_l_label := label.new(right, live.l, str.tostring(live.l), style=label.style_label_left, size=htf_price_label_size, color=color.new(color.white, 100), textcolor=htf_price_label_color)
                view.trace_c_label := label.new(right, live.c, str.tostring(live.c), style=label.style_label_left, size=htf_price_label_size, color=color.new(color.white, 100), textcolor=htf_price_label_color)
                label.set_text(view.trace_c_label, str.tostring(live.c))
            else
                label.set_xy(view.trace_o_label, right, live.o)
                label.set_text(view.trace_o_label, str.tostring(live.o))
                label.set_xy(view.trace_h_label, right, live.h)
                label.set_text(view.trace_h_label, str.tostring(live.h))
                label.set_xy(view.trace_l_label, right, live.l)
                label.set_text(view.trace_l_label, str.tostring(live.l))
                label.set_xy(view.trace_c_label, right, live.c)
                label.set_text(view.trace_c_label, str.tostring(live.c))
        else
            label.delete(view.trace_o_label)
            label.delete(view.trace_h_label)
            label.delete(view.trace_l_label)
            label.delete(view.trace_c_label)
            view.trace_o_label := na
            view.trace_h_label := na
            view.trace_l_label := na
            view.trace_c_label := na
            label.delete(view.trace_c_label)
    view

// Pass 1: resolve slot configuration and the frozen visibility/limit semantics.
array<HtfSlotConfig> htf_configs = array.new<HtfSlotConfig>()
array<bool> htf_active = array.new<bool>(6, false)
int enabledCount = 0
for slot = 0 to 5
    HtfSlotConfig config = htf_slot_config(slot)
    array.push(htf_configs, config)
    enabledCount += config.show ? 1 : 0

int permitted = math.min(enabledCount, htf_max_sets)
int activeCount = 0
for slot = 0 to 5
    HtfSlotConfig config = array.get(htf_configs, slot)
    bool active = htf_visibility(slot, config.show) and htf_valid_timeframe(config.timeframe) and (slot == 0 or activeCount < permitted)
    array.set(htf_active, slot, active)
    activeCount += active ? 1 : 0

// Only visible/valid slots consume chart bars, matching the released lifecycle.
for slot = 0 to 5
    if array.get(htf_active, slot)
        htf_ingest(array.get(htf_states, slot), array.get(htf_configs, slot), htf_slot_alerts(slot))

// Layout planner pass: calculate global alignment and the trace owner.
float alignedTop = 0.0
for slot = 0 to 5
    if array.get(htf_active, slot)
        alignedTop := math.max(alignedTop, htf_slot_high(array.get(htf_states, slot)))
float alignedBottom = alignedTop
for slot = 0 to 5
    if array.get(htf_active, slot)
        alignedBottom := htf_slot_low(array.get(htf_states, slot), alignedBottom)
int traceSlot = -1
for slot = 0 to 5
    if array.get(htf_active, slot)
        if htf_trace_anchor == 'First Timeframe' and traceSlot == -1
            traceSlot := slot
        if htf_trace_anchor == 'Last Timeframe'
            traceSlot := slot

// Pass 2: reconcile owned graphics from planned geometry.
int nextOffset = htf_offset
for slot = 0 to 5
    HtfSlotState state = array.get(htf_states, slot)
    HtfSlotView view = array.get(htf_views, slot)
    HtfSlotConfig config = array.get(htf_configs, slot)
    if array.get(htf_active, slot)
        float localTop = htf_slot_high(state)
        float localBottom = htf_slot_low(state, localTop)
        float labelTop = htf_label_alignment == 'Align' ? alignedTop : localTop
        float labelBottom = htf_label_alignment == 'Align' ? alignedBottom : localBottom
        htf_render_candles(state, view, nextOffset)
        htf_render_structure(state, view, nextOffset)
        htf_render_imbalances(state, view, nextOffset)
        htf_render_group_labels(state, view, config.timeframe, nextOffset, labelTop, labelBottom)
        htf_render_trace(state, view, nextOffset, slot == traceSlot)
        int count = array.size(state.bars)
        nextOffset += count * htf_candle_width + (count > 0 ? (count - 1) * htf_candle_gap : 0) + htf_group_gap
    else
        htf_clear_slot(view)

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


//+--- HTF Period Boundary (on chart)                                                                       ---+//
//+------------------------------------------------------------------------------------------------------------+//
// Marks the start of every period of the chosen boundary timeframe directly on
// the live price chart, using Pine's built-in time() HTF-boundary detection —
// Closed HTF events remain gated to confirmed source periods.

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
        cisd_confirmed_label := label.new(cisd_midpoint, cisd_event_level, htf_name(cisd_resolved_tf) + " " + dir_text, xloc=xloc.bar_time, style=this_bull ? label.style_label_down : label.style_label_up, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if cisd_show_protected and not na(cisd_protected_price) and not na(cisd_protected_time)
        line.delete(cisd_protected_line)
        label.delete(cisd_protected_label)
        string swing_text = this_bull ? "PSL" : "PSH"
        cisd_protected_label := label.new(cisd_protected_time, cisd_protected_price, swing_text + "\n" + htf_name(cisd_resolved_tf), xloc=xloc.bar_time, style=this_bull ? label.style_label_up : label.style_label_down, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if alert_cisd_enable
        alert(syminfo.ticker + ' ' + htf_name(cisd_resolved_tf) + ' CISD Confirmed (' + (this_bull ? 'Bullish' : 'Bearish') + ')', alert.freq_once_per_bar_close)

if cisd2_bull_event or cisd2_bear_event
    bool this_bull = cisd2_bull_event
    color event_color = color.new(this_bull ? cisd_bull_color : cisd_bear_color, 20)
    string dir_text = this_bull ? "CISD+" : "CISD-"

    if cisd_show_confirmed
        line.delete(cisd2_confirmed_line)
        label.delete(cisd2_confirmed_label)
        int cisd2_midpoint = int(math.round((cisd2_event_origin + cisd2_event_close) / 2.0))
        cisd2_confirmed_line := line.new(cisd2_event_origin, cisd2_event_level, cisd2_event_close, cisd2_event_level, xloc=xloc.bar_time, color=event_color, width=cisd_line_width, style=line.style_solid)
        cisd2_confirmed_label := label.new(cisd2_midpoint, cisd2_event_level, htf_name(cisd2_tf) + " " + dir_text, xloc=xloc.bar_time, style=this_bull ? label.style_label_down : label.style_label_up, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if cisd_show_protected and not na(cisd2_protected_price) and not na(cisd2_protected_time)
        line.delete(cisd2_protected_line)
        label.delete(cisd2_protected_label)
        string swing_text = this_bull ? "PSL" : "PSH"
        cisd2_protected_label := label.new(cisd2_protected_time, cisd2_protected_price, swing_text + "\n" + htf_name(cisd2_tf), xloc=xloc.bar_time, style=this_bull ? label.style_label_up : label.style_label_down, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if alert_cisd_enable
        alert(syminfo.ticker + ' ' + htf_name(cisd2_tf) + ' CISD Confirmed (' + (this_bull ? 'Bullish' : 'Bearish') + ')', alert.freq_once_per_bar_close)

if cisd3_bull_event or cisd3_bear_event
    bool this_bull = cisd3_bull_event
    color event_color = color.new(this_bull ? cisd_bull_color : cisd_bear_color, 40)
    string dir_text = this_bull ? "CISD+" : "CISD-"

    if cisd_show_confirmed
        line.delete(cisd3_confirmed_line)
        label.delete(cisd3_confirmed_label)
        int cisd3_midpoint = int(math.round((cisd3_event_origin + cisd3_event_close) / 2.0))
        cisd3_confirmed_line := line.new(cisd3_event_origin, cisd3_event_level, cisd3_event_close, cisd3_event_level, xloc=xloc.bar_time, color=event_color, width=cisd_line_width, style=line.style_solid)
        cisd3_confirmed_label := label.new(cisd3_midpoint, cisd3_event_level, htf_name(cisd3_tf) + " " + dir_text, xloc=xloc.bar_time, style=this_bull ? label.style_label_down : label.style_label_up, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if cisd_show_protected and not na(cisd3_protected_price) and not na(cisd3_protected_time)
        line.delete(cisd3_protected_line)
        label.delete(cisd3_protected_label)
        string swing_text = this_bull ? "PSL" : "PSH"
        cisd3_protected_label := label.new(cisd3_protected_time, cisd3_protected_price, swing_text + "\n" + htf_name(cisd3_tf), xloc=xloc.bar_time, style=this_bull ? label.style_label_up : label.style_label_down, color=color.new(event_color, 100), textcolor=event_color, size=size.small, textalign=text.align_center)

    if alert_cisd_enable
        alert(syminfo.ticker + ' ' + htf_name(cisd3_tf) + ' CISD Confirmed (' + (this_bull ? 'Bullish' : 'Bearish') + ')', alert.freq_once_per_bar_close)

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
        cisd_dev_label := label.new(dev_end, cisd_live_level, htf_name(cisd_resolved_tf) + " " + dev_dir_text, style=label.style_label_left, color=color.new(dev_color, 100), textcolor=dev_color, size=size.small)

    line.delete(cisd2_dev_line)
    label.delete(cisd2_dev_label)
    if cisd2_show and cisd_show_developing and not na(cisd2_live_level)
        color dev_color = color.new(cisd2_live_bias == -1 ? cisd_bull_color : cisd_bear_color, 20)
        int dev_start = bar_index + 1
        int dev_end = dev_start + 20
        string dev_dir_text = cisd2_live_bias == -1 ? "CISD+" : "CISD-"
        cisd2_dev_line := line.new(dev_start, cisd2_live_level, dev_end, cisd2_live_level, color=dev_color, width=cisd_line_width, style=line.style_dotted)
        cisd2_dev_label := label.new(dev_end, cisd2_live_level, htf_name(cisd2_tf) + " " + dev_dir_text, style=label.style_label_left, color=color.new(dev_color, 100), textcolor=dev_color, size=size.small)

    line.delete(cisd3_dev_line)
    label.delete(cisd3_dev_label)
    if cisd3_show and cisd_show_developing and not na(cisd3_live_level)
        color dev_color = color.new(cisd3_live_bias == -1 ? cisd_bull_color : cisd_bear_color, 40)
        int dev_start = bar_index + 1
        int dev_end = dev_start + 20
        string dev_dir_text = cisd3_live_bias == -1 ? "CISD+" : "CISD-"
        cisd3_dev_line := line.new(dev_start, cisd3_live_level, dev_end, cisd3_live_level, color=dev_color, width=cisd_line_width, style=line.style_dotted)
        cisd3_dev_label := label.new(dev_end, cisd3_live_level, htf_name(cisd3_tf) + " " + dev_dir_text, style=label.style_label_left, color=color.new(dev_color, 100), textcolor=dev_color, size=size.small)

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

// =============================================================================
// EXPECTED EXPANSION — PHASE 1 RESEARCH ENGINE
// Phase 2 presentation consumes the validated Phase 1 research engine unchanged.
// 15m/1h frozen source JSON SHA-256: f4fb9856a02e9785fc81e8329907a52b74f3d78503a0ad8fcfab667f3fba4ffa
// Native 4H frozen estimator SHA-256: 638185fe3b4fa3fbac564f793adfb6bf513cbfe07b7e7cd637b5a44bec19668e
// Endpoint: MFE_BEFORE_C2_FAILURE. Historical expansion research, not trade expectancy.


ee_text_size(string selected) =>
    selected == "Small" ? size.small : selected == "Normal" ? size.normal : selected == "Large" ? size.large : size.tiny

// --- STRUCTURAL EXPECTANCY V1: FROZEN MODEL TRANSCRIPTION START ---
// Source: NQ C2 Structural Expectancy V1 final freeze. These are historical
// conditional structural-survival estimates, not trade-win probabilities.
float SE_15M_REACH_B0 = -0.6415580350294217
float SE_15M_REACH_BR = 2.499606923580652
float SE_15M_REACH_BW = 1.5378145204143516
float SE_15M_INTACT_B0 = -0.6934157496179317
float SE_15M_INTACT_BR = 1.4864433437011635
float SE_15M_INTACT_BW = 0.553567579472756
float SE_1H_REACH_B0 = -0.22091922563015812
float SE_1H_REACH_BR = 1.667177179889614
float SE_1H_REACH_BW = 0.7484705291949069
float SE_1H_INTACT_B0 = -0.43843287452238916
float SE_1H_INTACT_BR = 1.0484878607360661
float SE_4H_REACH_B0 = 0.16677874746575502
float SE_4H_REACH_BR = 0.7096457682269152
float SE_4H_INTACT_B0 = -0.5305090950506661
float SE_4H_INTACT_BR = 0.6891926124007084

se_logistic(float z) => 1.0 / (1.0 + math.exp(-z))
se_m4_gate(float reclaimPct) => math.max(0.0, math.min(1.0, 1.0 - reclaimPct / 50.0))
se_15m_reach(float reclaimPct, float wickPct) => se_logistic(SE_15M_REACH_B0 + SE_15M_REACH_BR * reclaimPct / 100.0 + SE_15M_REACH_BW * wickPct / 100.0 * se_m4_gate(reclaimPct))
se_15m_intact(float reclaimPct, float wickPct) => se_logistic(SE_15M_INTACT_B0 + SE_15M_INTACT_BR * reclaimPct / 100.0 + SE_15M_INTACT_BW * wickPct / 100.0 * se_m4_gate(reclaimPct))
se_1h_reach(float reclaimPct, float wickPct) => se_logistic(SE_1H_REACH_B0 + SE_1H_REACH_BR * reclaimPct / 100.0 + SE_1H_REACH_BW * wickPct / 100.0 * se_m4_gate(reclaimPct))
se_1h_intact(float reclaimPct) => se_logistic(SE_1H_INTACT_B0 + SE_1H_INTACT_BR * reclaimPct / 100.0)
se_4h_reach(float reclaimPct) => se_logistic(SE_4H_REACH_B0 + SE_4H_REACH_BR * reclaimPct / 100.0)
se_4h_intact(float reclaimPct) => se_logistic(SE_4H_INTACT_B0 + SE_4H_INTACT_BR * reclaimPct / 100.0)
se_probability_valid(float probability) => not na(probability) and probability >= 0.0 and probability <= 1.0
// Inputs outside the frozen public interpretation grid are unavailable rather
// than silently replaced by an unconditional population rate.
se_reclaim_supported(float reclaimPct) => not na(reclaimPct) and reclaimPct >= 0.0 and reclaimPct <= 200.0
se_wick_supported(float wickPct) => not na(wickPct) and wickPct >= 0.0 and wickPct <= 80.0
// Probabilities are positive. floor(x + 0.5) gives deterministic half-up ties.
se_display(float probability, float stepPct, bool asterisk) =>
    float roundedPct = math.floor((probability * 100.0) / stepPct + 0.5) * stepPct
    "~" + str.tostring(roundedPct, "#") + "%" + (asterisk ? "*" : "")
// --- STRUCTURAL EXPECTANCY V1: FROZEN MODEL TRANSCRIPTION END ---

int NORMAL_4H_EE = 0
int ROLLOVER_ATR_FALLBACK = 1
int INACTIVE_INVALID = 2

int EE_MINUTE_MS = 60000
int EE_MAX_INTRABARS = 200000
int EE_SCALAR_ATR_REQUEST_MINUTES = 50000
string EE_TZ = "America/Chicago"
var array<float> ee_knots = array.from(0.0,10.0,25.0,50.0,75.0,100.0,150.0,200.0)
var array<float> ee_thresholds = array.from(0.10,0.20,0.30,0.40,0.50,0.60,0.75,1.00,1.25,1.50,2.00)
var array<float> ee_q15 = array.from(0.09471332465564161,0.30612864111733196,0.7309007785803239,1.328647070148412,0.10179816850137184,0.32611818763124467,0.7521973538767952,1.3462582037535762,0.1236122095828801,0.3737238767098481,0.8048926891643088,1.3960013762967065,0.17230836028938828,0.4625625276224261,0.9160873074182013,1.4905318467670874,0.19303063897431752,0.5047286153237148,0.9581721670383673,1.5350636163815436,0.22169299600915432,0.5117601311379754,1.0022179560308813,1.667220709618465,0.23586300961418863,0.5487463162457413,1.0224649497320177,1.7964812085603001,0.2581721567303147,0.618336103122393,1.3108575665845703,2.3982809760682113)
var array<float> ee_p15 = array.from(0.7408020427163501,0.6055155240693499,0.505289279669949,0.42838392164643,0.36662273429399533,0.3137262592148601,0.24236883211889648,0.1642483060199201,0.11171280623363118,0.07684927441495122,0.03680796197870793,0.7526619660527645,0.6216728411053021,0.5219327404299386,0.4429251854644652,0.3782250123874322,0.32384318399352224,0.2510582126193827,0.16886352318481104,0.11515941338798014,0.0788152202067971,0.03908584273169099,0.7824917176423203,0.6597644922020144,0.5619633912519159,0.47878387947122397,0.40897754699711736,0.3503136667506234,0.274550397944105,0.1828203334554882,0.12453493394683304,0.08382230889007804,0.04356428263594566,0.8340235087295648,0.7205508731090783,0.6251460543740864,0.543649783169658,0.47369112230701177,0.4074808162125271,0.3245796996852982,0.21946139204771622,0.14632350032101119,0.0984183732916924,0.050261851614195156,0.8469237386730769,0.7428107754929054,0.6538434196477801,0.5760337476275417,0.5030499452282605,0.4344965770799699,0.3464720884695449,0.23407766799304752,0.1562486328279396,0.10458455359636341,0.05133555744049215,0.8691743205505268,0.7706597275747328,0.66883122666747,0.5756419595603675,0.5066939322561271,0.43935300112963915,0.35503019268109337,0.2508555453741143,0.17657236262848014,0.12193817839736358,0.07058762658671848,0.8817011317360882,0.7797371828245425,0.6864004286102353,0.6031330361630782,0.5292683941609716,0.4667381798725099,0.3728676322045358,0.2547251604009823,0.1845291876944658,0.14037911835172318,0.08158690899181731,0.8945288006109461,0.799718498947277,0.7160956217010102,0.634199179817442,0.5678009094614751,0.5104927760129965,0.43695304897373277,0.3378065314804,0.2660455647641545,0.20582751090396476,0.13539712982147964)
var array<float> ee_q1h = array.from(0.0864251748223701,0.2798997975889003,0.6907058290208612,1.3243393768283824,0.09525704147300999,0.3003186566361157,0.7261021945777308,1.3533951277470517,0.1222735072522131,0.3455014546259142,0.7789356168637129,1.4428555133898586,0.16533076259742874,0.424031896310743,0.8806172327852472,1.624528282085667,0.1919635496021376,0.4921124384030916,0.9284600798597482,1.545180910459362,0.2350033701835735,0.5435181460940844,1.0394851154426163,1.8141789871623533,0.2047562096327546,0.5186075715205402,1.108829235225508,1.9573754626239204,0.24219917299926266,0.6557656314534107,1.3639955437464941,2.421406321826902)
var array<float> ee_p1h = array.from(0.7221658412842203,0.5816494907821839,0.4821917436826485,0.4038278296501442,0.33829150961998505,0.2867921314533187,0.22782909364822895,0.15620161651686296,0.1113694288157469,0.08098885207664641,0.0420205396392356,0.7405321136685924,0.6032470675922254,0.5008179058232564,0.4203858685946805,0.3570649238753171,0.3037883309353655,0.24018104370742693,0.1636900845454022,0.11593955226821914,0.08358861425803098,0.04458896978122637,0.7807349324133976,0.6485092117960826,0.5412599237589515,0.45520842219144286,0.3932438838983017,0.3331130853975819,0.2655392090897627,0.17970339678650504,0.1282576975184145,0.09261527362983016,0.05173227545923577,0.8378515919711772,0.7095614673706309,0.600491012639607,0.5191895102800927,0.4534894655857793,0.3819333990417473,0.3070142843208244,0.21502611372103883,0.1586264884110267,0.11776580660011163,0.06432386879506602,0.8472132325343146,0.7403972310025659,0.6528247944440349,0.5689613090183295,0.4974959702136314,0.4259239494703506,0.3407315707291186,0.22574683977665297,0.15408235386132962,0.1082651921302953,0.06343787322775353,0.87397162499549,0.7771992885675366,0.706086434713662,0.6028629099016423,0.5264657304184981,0.462804866541715,0.3693243398759443,0.26213388252646763,0.18177038570372894,0.14763188371574706,0.08533905667993218,0.880145631943548,0.7564963029326122,0.6802659260481224,0.5879223961485456,0.5075091728371416,0.46714858028696726,0.37454222832335143,0.2882253828010314,0.21655545802384646,0.16045659061100226,0.09727832290002515,0.8868268615520968,0.782331472603495,0.7026654626914672,0.6356484543852151,0.5782314187303476,0.5290559037878834,0.44328172608353966,0.3481862691592868,0.2811509308550016,0.2248423781411582,0.14481162561235142)
var array<float> ee_q4m1 = array.from(0.09459049046344976,0.26316549873892164,0.5655454969769027,1.1290272754333244,0.10710852116683214,0.2944818283908941,0.6147540983606558,1.1573945544570472,0.13926856849213728,0.34431611612519725,0.710538984891641,1.3517437065096913,0.16463461709665153,0.45357524012806827,0.8911564173849562,1.3528276192328987,0.16391235330926238,0.34250029803651943,0.7811475404332844,1.181058630994778,0.22611641104424807,0.5667577251873948,1.1203152073295197,1.656401306202664,0.37692897392742225,0.8138762436593184,1.3876683643670802,2.1405960338269514,0.25785880732818267,0.5949949488316414,1.3617593980456437,2.1405960338269514)
var array<float> ee_p4m1 = array.from(0.7333962904349772,0.5833878419955558,0.46739430600802706,0.3904602204467821,0.28710458154698754,0.23634663762872202,0.18568867916206674,0.12354419161720682,0.09211267102447045,0.07660528855808629,0.0326758044679158,0.7575454421272697,0.6084929519205425,0.49350663520725585,0.4123880550065351,0.31076292360738383,0.25755711151759586,0.19907085566868962,0.1322711818708044,0.09555400221627527,0.07894029819175787,0.03453092577815583,0.8044370368930942,0.6734015250452899,0.5539742280834216,0.4805151437385304,0.3834257763114516,0.32696926458935727,0.23378047573375688,0.1574406253784242,0.11212133843867615,0.08420795686267657,0.03157027051063182,0.8237180752564152,0.7258283629132344,0.6492173178426413,0.5696611321035779,0.4880664359960623,0.43777283709299336,0.32183078423103534,0.19495277690493407,0.13752152351119354,0.07329635827472933,0.03792940319927369,0.8100845941360335,0.7163635152522807,0.5624812204129886,0.48506398249373345,0.37186461502591556,0.3261186847443011,0.26068675528728125,0.15922692505607308,0.08013372863459454,0.038304004158210614,0.030124863993620816,0.8827582323436813,0.8166351213474712,0.6830993539947179,0.5848556290978091,0.5189493404811858,0.457839470737568,0.39658600848856096,0.32816674887403124,0.22853250945701487,0.14734282776595317,0.04683010984984799,0.9098819478390805,0.8812114876741151,0.8082630026229917,0.7233803447631758,0.6856032764738093,0.5914939643209152,0.5364873332030846,0.40075203453047514,0.2986756872774567,0.20927426145090053,0.14295088374649692,0.932575754491294,0.8744895496430738,0.7083994809602748,0.6665865996444978,0.6544216439959034,0.48111691663709916,0.4171663889853888,0.39016828689244776,0.2909541046260096,0.21560239982552387,0.13112115594687407)
var array<float> ee_q4bucket = array.from(0.09779703568007085,0.2742758312895736,0.5655454969769027,1.377985704520297,0.11255057681213843,0.2993783142740456,0.616153111529011,1.0892211437429475,0.22700702780679047,0.501451832385563,0.8961596093482385,1.496593416740094,0.1403493132241335,0.4086909294970266,0.799789529071297,1.2449585648909667,0.18209549325556096,0.3138796136825523,0.6573590850393871,1.2359321020217002,0.3253003932720587,0.6643750891045346,1.3254778489160275,2.021669221981547)
var array<float> ee_p4bucket = array.from(0.7355371900826446,0.5950413223140496,0.4793388429752066,0.39669421487603307,0.2892561983471074,0.2396694214876033,0.19008264462809918,0.1322314049586777,0.10743801652892562,0.09090909090909091,0.03305785123966942,0.7668711656441718,0.6073619631901841,0.49693251533742333,0.4171779141104294,0.3128834355828221,0.25766871165644173,0.1901840490797546,0.1165644171779141,0.07975460122699386,0.06134969325153374,0.03067484662576687,0.8686131386861314,0.7591240875912408,0.6496350364963503,0.5912408759124088,0.5109489051094891,0.45255474452554745,0.31386861313868614,0.2116788321167883,0.145985401459854,0.10218978102189781,0.0364963503649635,0.7692307692307693,0.6923076923076923,0.6,0.5076923076923077,0.4153846153846154,0.38461538461538464,0.3076923076923077,0.16923076923076924,0.1076923076923077,0.03076923076923077,0.03076923076923077,0.7692307692307693,0.7307692307692307,0.5,0.4230769230769231,0.34615384615384615,0.2692307692307692,0.23076923076923078,0.19230769230769232,0.11538461538461539,0.07692307692307693,0.038461538461538464,0.9242424242424242,0.8686868686868687,0.7575757575757576,0.6767676767676768,0.6363636363636364,0.5202020202020202,0.45454545454545453,0.37373737373737376,0.2727272727272727,0.1919191919191919,0.10606060606060606)

ee_locate(float x, array<float> axis) =>
    float xc = math.max(array.get(axis,0), math.min(array.get(axis,array.size(axis)-1),x))
    int lo = 0
    for i = 0 to array.size(axis)-2
        if xc >= array.get(axis,i)
            lo := i
    lo := math.min(lo,array.size(axis)-2)
    float a = array.get(axis,lo)
    float b = array.get(axis,lo+1)
    [lo,b==a?0.0:(xc-a)/(b-a)]

ee_interp(float reclaim, int col, int width, array<float> grid) =>
    [lo,w] = ee_locate(reclaim,ee_knots)
    array.get(grid,lo*width+col)+w*(array.get(grid,(lo+1)*width+col)-array.get(grid,lo*width+col))

ee_standard_quantiles(float reclaim, bool oneHour) =>
    array<float> grid = oneHour ? ee_q1h : ee_q15
    [ee_interp(reclaim,0,4,grid),ee_interp(reclaim,1,4,grid),ee_interp(reclaim,2,4,grid),ee_interp(reclaim,3,4,grid)]

ee_standard_probability(float reclaim, float distance, bool oneHour) =>
    float answer = na
    if distance >= 0.10 and distance <= 2.00
        [lo,w] = ee_locate(distance,ee_thresholds)
        array<float> grid = oneHour ? ee_p1h : ee_p15
        float a = ee_interp(reclaim,lo,11,grid)
        float b = ee_interp(reclaim,lo+1,11,grid)
        answer := a+w*(b-a)
    answer

ee_bucket(float reclaim) => reclaim < 10?0:reclaim < 25?1:reclaim < 50?2:reclaim < 75?3:reclaim <= 100?4:5

ee_native_quantiles(float reclaim) =>
    // Frozen NQ 4H Expected Expansion V3 development quantiles.
    // Historically promoted with caution: P25 early/late drift was 40.68%.
    [0.16559501935562232,0.43408749493991194,0.903293342216576,1.553957114001137]

ee_quantiles(float reclaim, bool native4h, bool oneHour) =>
    if native4h
        ee_native_quantiles(reclaim)
    else
        ee_standard_quantiles(reclaim,oneHour)

ee_native_probability(float reclaim, float distance) =>
    float answer = na
    if distance >= 0.10 and distance <= 2.00
        [lo,w] = ee_locate(distance,ee_thresholds)
        int bucket = ee_bucket(reclaim)
        float ba = array.get(ee_p4bucket,bucket*11+lo)
        float bb = array.get(ee_p4bucket,bucket*11+lo+1)
        float ma = ee_interp(reclaim,lo,11,ee_p4m1)
        float mb = ee_interp(reclaim,lo+1,11,ee_p4m1)
        answer := 0.75*(ba+w*(bb-ba))+0.25*(ma+w*(mb-ma))
    answer

ee_atr20() =>
    float tr = na(close[1]) ? high-low : math.max(high-low,math.max(math.abs(high-close[1]),math.abs(low-close[1])))
    ta.rma(tr,20)

ee_date_key(int y,int m,int d) => y*10000+m*100+d
ee_days_in_month(int y,int m) => m==2?((y%400==0 or (y%4==0 and y%100!=0))?29:28):(m==4 or m==6 or m==9 or m==11?30:31)
ee_shift_date(int y,int m,int d,int delta) =>
    int yy=y
    int mm=m
    int dd=d
    int n=delta
    while n>0
        dd+=1
        if dd>ee_days_in_month(yy,mm)
            dd:=1
            mm+=1
            if mm>12
                mm:=1
                yy+=1
        n-=1
    while n<0
        dd-=1
        if dd<1
            mm-=1
            if mm<1
                mm:=12
                yy-=1
            dd:=ee_days_in_month(yy,mm)
        n+=1
    [yy,mm,dd]
ee_third_friday(int y,int m) =>
    int firstDow=dayofweek(timestamp(EE_TZ,y,m,1,0,0))
    int fridayOffset=(dayofweek.friday-firstDow+7)%7
    1+fridayOffset+14
ee_roll_blackout(int ts) =>
    int y=year(ts,EE_TZ)
    int m=month(ts,EE_TZ)
    int d=dayofmonth(ts,EE_TZ)
    bool quarter=m==3 or m==6 or m==9 or m==12
    bool answer=false
    if quarter
        int friday=ee_third_friday(y,m)
        [sy,sm,sd]=ee_shift_date(y,m,friday,-10)
        [ey,em,ed]=ee_shift_date(y,m,friday,4)
        int key=ee_date_key(y,m,d)
        answer:=key>=ee_date_key(sy,sm,sd) and key<=ee_date_key(ey,em,ed)
    answer
// NQ1! does not expose a historical contract identifier to this script. During
// blackout, conservatively start a fresh structure epoch at every 17:00 CT
// futures session. C1/C2 may form within an epoch but never across a session
// boundary where the continuous source could have changed contracts.
ee_roll_contract_boundary(int ts) =>
    ee_roll_blackout(ts) and hour(ts,EE_TZ)==17 and minute(ts,EE_TZ)==0
ee_expected_minutes(int ts) => hour(ts,EE_TZ)==13?180:240
ee_ordinary_open(int ts) =>
    int h=hour(ts,EE_TZ)
    int minuteValue=minute(ts,EE_TZ)
    minuteValue==0 and (h==17 or h==21 or h==1 or h==5 or h==9 or h==13)
ee_expected_next(int ts) =>
    int y=year(ts,EE_TZ)
    int m=month(ts,EE_TZ)
    int d=dayofmonth(ts,EE_TZ)
    int h=hour(ts,EE_TZ)
    int answer=na
    if h==17
        answer:=timestamp(EE_TZ,y,m,d,21,0)
    else if h==21
        answer:=timestamp(EE_TZ,y,m,d+1,1,0)
    else if h==1
        answer:=timestamp(EE_TZ,y,m,d,5,0)
    else if h==5
        answer:=timestamp(EE_TZ,y,m,d,9,0)
    else if h==9
        answer:=timestamp(EE_TZ,y,m,d,13,0)
    else if h==13
        int addDays=dayofweek(ts,EE_TZ)==dayofweek.friday?2:0
        answer:=timestamp(EE_TZ,y,m,d+addDays,17,0)
    answer

// --- PHASE 1E: SOURCE-OWNED PRESERVED ATR SCALAR START ---
// Exact standalone-validated native 4H ATR semantics. Only a float and a bool
// cross the request boundary; C1/C2 and every other 4H state remain host-owned.
ee_scalar_preserved_atr_packet() =>
    var int parentOpen=na
    var int parentClose=na
    var int firstMinute=na
    var int lastMinute=na
    var int minuteCount=0
    var bool parentContiguous=true
    var bool parentTruncated=false
    var float parentHigh=na
    var float parentLow=na
    var float parentClosePrice=na
    var int lastConsumedMinute=na
    var int previousNativeOpen=na
    var int warmup=0
    var float trSum=0.0
    var float segmentAtr=na
    var float preservedAtr=na
    var float previousEligibleClose=na
    var int packetOpen=na
    var bool packetIntegrity=false
    var bool packetContinuity=false
    var bool packetBlackout=false
    var int packetDuration=na
    int minuteParent=time("240")
    int minuteParentClose=time_close("240")
    bool consume=time_close<=timenow and (na(lastConsumedMinute) or time>lastConsumedMinute) and not na(minuteParent)
    if consume
        bool newParent=na(parentOpen) or minuteParent!=parentOpen
        if newParent
            if not na(parentOpen)
                packetOpen:=parentOpen
                int required=ee_expected_minutes(packetOpen)
                packetDuration:=int((parentClose-parentOpen)/EE_MINUTE_MS)
                packetIntegrity:=not parentTruncated
                packetContinuity:=packetIntegrity and parentContiguous and minuteCount==required and firstMinute==packetOpen and lastMinute==packetOpen+(required-1)*EE_MINUTE_MS and packetDuration==required
                packetBlackout:=ee_roll_blackout(packetOpen)
                int expectedNext=na(previousNativeOpen)?na:ee_expected_next(previousNativeOpen)
                bool barrier=not na(expectedNext) and packetOpen!=expectedNext
                bool boundary=ee_ordinary_open(packetOpen)
                bool eligible=boundary and packetContinuity and not packetBlackout
                if packetBlackout
                    previousEligibleClose:=na
                else if barrier or not packetIntegrity or not eligible
                    warmup:=0
                    trSum:=0.0
                    segmentAtr:=na
                    previousEligibleClose:=na
                else
                    float tr=na(previousEligibleClose)?parentHigh-parentLow:math.max(parentHigh-parentLow,math.max(math.abs(parentHigh-previousEligibleClose),math.abs(parentLow-previousEligibleClose)))
                    warmup+=1
                    if warmup<=20
                        trSum+=tr
                        if warmup==20
                            segmentAtr:=trSum/20.0
                    else
                        segmentAtr:=(19.0*segmentAtr+tr)/20.0
                    if not na(segmentAtr) and segmentAtr>0
                        preservedAtr:=segmentAtr
                    previousEligibleClose:=parentClosePrice
                if boundary and (packetBlackout or packetIntegrity)
                    previousNativeOpen:=packetOpen
            parentOpen:=minuteParent
            parentClose:=minuteParentClose
            firstMinute:=time
            lastMinute:=time
            minuteCount:=1
            parentContiguous:=time==minuteParent
            parentTruncated:=na(lastConsumedMinute) and time!=minuteParent
            parentHigh:=high
            parentLow:=low
            parentClosePrice:=close
        else
            parentContiguous:=parentContiguous and time==lastMinute+EE_MINUTE_MS
            lastMinute:=time
            minuteCount+=1
            parentHigh:=math.max(parentHigh,high)
            parentLow:=math.min(parentLow,low)
            parentClosePrice:=close
        lastConsumedMinute:=time
    [preservedAtr,not na(preservedAtr) and preservedAtr>0]
// --- PHASE 1E: SOURCE-OWNED PRESERVED ATR SCALAR END ---

bool ee_is4h = ee_selected_tf=="4H"
bool ee_is1h = ee_selected_tf=="1h"
int ee_host_seconds=timeframe.in_seconds()
bool ee_host_supported=timeframe.isintraday and ee_host_seconds<=(ee_selected_tf=="15m"?900:3600)
string ee_std_tf=ee_is1h?"60":"15"

// Validated 4H host-independent architecture. The frozen model is always
// sourced from explicit NQ1! ETH / unadjusted data. The host contributes only
// a matched completed-bar close and minimum tick for display translation.
string ee_nq_4h_source=ticker.new("CME_MINI","NQ1!",session=session.extended,adjustment=adjustment.none,settlement_as_close=settlement_as_close.off,backadjustment=backadjustment.off)
[ee_scalar_preserved_atr,ee_scalar_atr_ready]=request.security(ee_nq_4h_source,"1",ee_scalar_preserved_atr_packet(),gaps=barmerge.gaps_off,lookahead=barmerge.lookahead_off,calc_bars_count=EE_SCALAR_ATR_REQUEST_MINUTES)
string ee_host_4h_source=ticker.modify(ticker.standard(syminfo.tickerid),session=session.extended,adjustment=adjustment.none,settlement_as_close=settlement_as_close.off,backadjustment=backadjustment.off)
bool ee_host_is_futures=syminfo.type=="futures"
bool ee_host_is_nq=ee_host_is_futures and syminfo.root=="NQ"
bool ee_host_is_mnq=ee_host_is_futures and syminfo.root=="MNQ"
bool ee_host_is_continuous=str.contains(syminfo.ticker,"!")
string ee_4h_host_class=ee_host_is_nq?(ee_host_is_continuous?"NQ_CONTINUOUS":"NQ_DATED"):ee_host_is_mnq?(ee_host_is_continuous?"MNQ_CONTINUOUS":"MNQ_DATED"):"UNSUPPORTED"
bool ee_4h_host_class_supported=ee_4h_host_class!="UNSUPPORTED"

[ee_std_c1o,ee_std_c1h,ee_std_c1l,ee_std_c1c,ee_std_c2o,ee_std_c2h,ee_std_c2l,ee_std_c2c,ee_std_atr,ee_std_open_time,ee_std_close_time]=request.security(syminfo.tickerid,ee_std_tf,[open[2],high[2],low[2],close[2],open[1],high[1],low[1],close[1],ee_atr20()[1],time[1],time_close[1]],gaps=barmerge.gaps_off,lookahead=barmerge.lookahead_on)
[ee_n_open_time,ee_n_close_time,ee_n_open,ee_n_high,ee_n_low,ee_n_close]=request.security(ee_nq_4h_source,"240",[time[1],time_close[1],open[1],high[1],low[1],close[1]],gaps=barmerge.gaps_off,lookahead=barmerge.lookahead_on)
[ee_host_4h_open_time,ee_host_4h_close_time,ee_host_4h_anchor,ee_host_4h_tick]=request.security(ee_host_4h_source,"240",[time[1],time_close[1],close[1],syminfo.mintick],gaps=barmerge.gaps_off,lookahead=barmerge.lookahead_on,ignore_invalid_symbol=true)
[ee_n_live_low,ee_n_live_high]=request.security(ee_nq_4h_source,"240",[low,high],gaps=barmerge.gaps_off,lookahead=barmerge.lookahead_off)
bool ee_host_4h_timestamp_match=ee_4h_host_class_supported and ee_host_4h_open_time==ee_n_open_time and ee_host_4h_close_time==ee_n_close_time and not na(ee_host_4h_anchor) and not na(ee_host_4h_tick)
array<int> ee_minute_times=array.new_int(0)
array<int> ee_minute_closes=array.new_int(0)
array<int> ee_minute_parents=array.new_int(0)
if ee_enabled and ee_is4h
    if timeframe.in_seconds()==60
        [ee_n_minute_time,ee_n_minute_close,ee_n_minute_parent]=request.security(ee_nq_4h_source,"1",[time,time_close,time("240")],gaps=barmerge.gaps_off,lookahead=barmerge.lookahead_off)
        ee_minute_times:=array.from(ee_n_minute_time)
        ee_minute_closes:=array.from(ee_n_minute_close)
        ee_minute_parents:=array.from(ee_n_minute_parent)
    else
        [ee_requested_times,ee_requested_closes,ee_requested_parents]=request.security_lower_tf(ee_nq_4h_source,"1",[time,time_close,time("240")],ignore_invalid_timeframe=true,calc_bars_count=EE_MAX_INTRABARS)
        ee_minute_times:=ee_requested_times
        ee_minute_closes:=ee_requested_closes
        ee_minute_parents:=ee_requested_parents

var int ee_active_parent=na
var int ee_active_first=na
var int ee_active_last=na
var int ee_active_count=0
var int ee_last_minute=na
var int ee_total_minutes=0
var bool ee_active_contiguous=true
var bool ee_active_truncated=false
var int ee_final_parent=na
var int ee_final_first=na
var int ee_final_last=na
var int ee_final_count=0
var bool ee_final_contiguous=false
var bool ee_final_truncated=false
if ee_enabled and ee_is4h and ee_host_supported and array.size(ee_minute_times)>0
    for i=0 to array.size(ee_minute_times)-1
        int mt=array.get(ee_minute_times,i)
        int mc=array.get(ee_minute_closes,i)
        int mp=array.get(ee_minute_parents,i)
        if mc<=timenow and (na(ee_last_minute) or mt>ee_last_minute) and not na(mp)
            if na(ee_active_parent) or mp!=ee_active_parent
                if not na(ee_active_parent)
                    ee_final_parent:=ee_active_parent
                    ee_final_first:=ee_active_first
                    ee_final_last:=ee_active_last
                    ee_final_count:=ee_active_count
                    ee_final_contiguous:=ee_active_contiguous
                    ee_final_truncated:=ee_active_truncated
                ee_active_parent:=mp
                ee_active_first:=mt
                ee_active_last:=mt
                ee_active_count:=1
                ee_active_contiguous:=mt==mp
                ee_active_truncated:=ee_total_minutes==0 and mt!=mp
            else
                ee_active_contiguous:=ee_active_contiguous and mt==ee_active_last+EE_MINUTE_MS
                ee_active_last:=mt
                ee_active_count+=1
            ee_last_minute:=mt
            ee_total_minutes+=1

var string ee_research_state="WAITING FOR COMPLETED DATA"
var string ee_lifecycle="NO ACTIVE C2"
var int ee_previous_packet_time=na
var int ee_previous_native_open=na
var float ee_retained_o=na
var float ee_retained_h=na
var float ee_retained_l=na
var float ee_retained_c=na
var bool ee_have_c1=false
var int ee_segment=0
var int ee_warmup=0
var float ee_tr_sum=0.0
var float ee_segment_atr=na
// Last completed trustworthy Wilder ATR. This fallback-only snapshot survives
// a neighboring holiday/special-bar reset; normal V3 state remains unchanged.
var float ee_preserved_roll_atr=na
// Compatibility variable: source-owned scalar is authoritative only for the
// preserved rollover ATR. If unavailable, fallback fails closed.
if ee_is4h
    ee_preserved_roll_atr:=ee_scalar_atr_ready?ee_scalar_preserved_atr:na
var float ee_previous_eligible_close=na
var bool ee_integrity_available=false
var bool ee_continuity=false
var bool ee_blackout=false
var bool ee_previous_blackout=false
var bool ee_barrier_before=false
var int ee_expected=na
var int ee_retrieved=0
var int ee_native_duration=na
var bool ee_active=false
var bool ee_active_bull=false
var int ee_active_c2_time=na
var int ee_active_c2_close_time=na
var int ee_after_c2=0
var int ee_active_segment=na
var float ee_active_close=na
var float ee_active_display_close=na
var float ee_active_display_tick=na
var bool ee_active_host_match=false
var float ee_active_extreme=na
var float ee_active_reclaim=na
var float ee_active_atr=na
// --- STRUCTURAL EXPECTANCY V1: ACTIVE-C2 STATE START ---
var float ee_se_active_wick=na
var float ee_se_reach_probability=na
var float ee_se_intact_probability=na
var bool ee_se_available=false
// --- STRUCTURAL EXPECTANCY V1: ACTIVE-C2 STATE END ---
var float ee_p25=na
var float ee_p50=na
var float ee_p75=na
var float ee_p90=na
var float ee_roll_retained_o=na
var float ee_roll_retained_h=na
var float ee_roll_retained_l=na
var float ee_roll_retained_c=na
var bool ee_roll_have_c1=false
var int ee_4h_mode=INACTIVE_INVALID

bool ee_new_std=ee_enabled and not ee_is4h and ee_host_supported and not na(ee_std_close_time) and (na(ee_previous_packet_time) or ee_std_close_time!=ee_previous_packet_time)
bool ee_symbol_ok=not ee_is4h or ee_4h_host_class_supported
bool ee_new_native=ee_enabled and ee_is4h and ee_symbol_ok and ee_host_supported and not na(ee_n_open_time) and (na(ee_previous_packet_time) or ee_n_open_time!=ee_previous_packet_time)
bool ee_new_packet=ee_new_std or ee_new_native

if not ee_enabled or not ee_host_supported or not ee_symbol_ok
    ee_active:=false
    ee_lifecycle:=not ee_enabled?"DISABLED":not ee_symbol_ok?"4H REQUIRES NQ/MNQ FUTURES HOST":"UNSUPPORTED HOST TIMEFRAME"
    ee_research_state:=ee_lifecycle
else if ee_new_packet
    float c1o=ee_std_c1o
    float c1h=ee_std_c1h
    float c1l=ee_std_c1l
    float c1c=ee_std_c1c
    float c2o=ee_std_c2o
    float c2h=ee_std_c2h
    float c2l=ee_std_c2l
    float c2c=ee_std_c2c
    float c2atr=ee_std_atr
    int c2open=ee_std_open_time
    int c2close=ee_std_close_time
    bool candidateEligible=true
    bool rolloverStructureEligible=false
    bool rolloverCandidateEligible=false
    if ee_is4h
        ee_expected:=ee_expected_minutes(ee_n_open_time)
        ee_native_duration:=int((ee_n_close_time-ee_n_open_time)/EE_MINUTE_MS)
        ee_blackout:=ee_roll_blackout(ee_n_open_time)
        ee_integrity_available:=ee_final_parent==ee_n_open_time and not ee_final_truncated
        ee_retrieved:=ee_integrity_available?ee_final_count:0
        ee_continuity:=ee_integrity_available and ee_final_contiguous and ee_final_count==ee_expected and ee_final_first==ee_n_open_time and ee_final_last==ee_n_open_time+(ee_expected-1)*EE_MINUTE_MS and ee_native_duration==ee_expected
        int expectedNext=na(ee_previous_native_open)?na:ee_expected_next(ee_previous_native_open)
        ee_barrier_before:=not na(expectedNext) and ee_n_open_time!=expectedNext
        bool boundary=ee_ordinary_open(ee_n_open_time)
        bool enteringBlackout=ee_blackout and not ee_previous_blackout
        bool leavingBlackout=not ee_blackout and ee_previous_blackout
        bool rollContractBoundary=ee_roll_contract_boundary(ee_n_open_time)
        bool rolloverFallbackEnabled=ee_4h_rollover_fallback_setting=="On"
        candidateEligible:=boundary and ee_continuity and not ee_blackout
        rolloverStructureEligible:=boundary and ee_continuity and ee_blackout and rolloverFallbackEnabled
        rolloverCandidateEligible:=rolloverStructureEligible and not na(ee_preserved_roll_atr) and ee_preserved_roll_atr>0
        // Roll blackout resets structure but preserves causal Wilder state.
        if ee_blackout
            if enteringBlackout or rollContractBoundary
                ee_segment+=1
                ee_previous_eligible_close:=na
                ee_have_c1:=false
                ee_roll_have_c1:=false
                ee_active:=false
            if not rolloverFallbackEnabled or not boundary or not ee_continuity
                ee_roll_have_c1:=false
                ee_active:=false
                ee_4h_mode:=INACTIVE_INVALID
                ee_lifecycle:=rolloverFallbackEnabled?"ROLL BLACKOUT — NO SAFE CURRENT C2":"ROLL BLACKOUT — V3 STATE PRESERVED"
            else
                c1o:=ee_roll_retained_o
                c1h:=ee_roll_retained_h
                c1l:=ee_roll_retained_l
                c1c:=ee_roll_retained_c
                c2o:=ee_n_open
                c2h:=ee_n_high
                c2l:=ee_n_low
                c2c:=ee_n_close
                c2atr:=ee_preserved_roll_atr
                c2open:=ee_n_open_time
                c2close:=ee_n_close_time
                ee_lifecycle:=na(ee_preserved_roll_atr) or ee_preserved_roll_atr<=0?"ROLL BLACKOUT — ATR STATE UNAVAILABLE":ee_roll_have_c1?"ROLLOVER ATR FALLBACK — C2 CHECK":"ROLLOVER ATR FALLBACK — WAITING FOR CURRENT C1"
        else if ee_barrier_before or not ee_integrity_available or not candidateEligible
            ee_segment+=1
            ee_warmup:=0
            ee_tr_sum:=0.0
            ee_segment_atr:=na
            ee_previous_eligible_close:=na
            ee_have_c1:=false
            ee_roll_have_c1:=false
            ee_active:=false
            ee_4h_mode:=INACTIVE_INVALID
            ee_lifecycle:=ee_blackout?"ROLL BLACKOUT":not ee_integrity_available?"INTEGRITY HISTORY UNAVAILABLE":"SPECIAL/INCOMPLETE 4H BAR"
        if ee_blackout
            ee_research_state:="ROLL_BLACKOUT"
        else if not ee_integrity_available
            ee_research_state:="INTEGRITY_HISTORY_UNAVAILABLE"
        else if not candidateEligible
            ee_research_state:="SPECIAL_OR_INCOMPLETE"
        else
            if leavingBlackout
                ee_roll_have_c1:=false
                ee_active:=false
            float tr=na(ee_previous_eligible_close)?ee_n_high-ee_n_low:math.max(ee_n_high-ee_n_low,math.max(math.abs(ee_n_high-ee_previous_eligible_close),math.abs(ee_n_low-ee_previous_eligible_close)))
            ee_warmup+=1
            if ee_warmup<=20
                ee_tr_sum+=tr
                if ee_warmup==20
                    ee_segment_atr:=ee_tr_sum/20.0
            else
                ee_segment_atr:=(19.0*ee_segment_atr+tr)/20.0
            ee_previous_eligible_close:=ee_n_close
            c1o:=ee_retained_o
            c1h:=ee_retained_h
            c1l:=ee_retained_l
            c1c:=ee_retained_c
            c2o:=ee_n_open
            c2h:=ee_n_high
            c2l:=ee_n_low
            c2c:=ee_n_close
            c2atr:=ee_segment_atr
            c2open:=ee_n_open_time
            c2close:=ee_n_close_time
            ee_research_state:=ee_warmup>=20?"ELIGIBLE_ORDINARY / ATR_READY":"ATR_WARMUP "+str.tostring(ee_warmup)+"/20"
    bool canQualify=not ee_is4h or candidateEligible or rolloverStructureEligible
    bool c1Ready=ee_is4h?(ee_blackout?ee_roll_have_c1:ee_have_c1):not na(c1h) and not na(c1l)
    bool lowSweep=canQualify and c1Ready and c2l<c1l
    bool highSweep=canQualify and c1Ready and c2h>c1h
    bool bull=(lowSweep and c2c>c1h) or (lowSweep and not highSweep and c2c>c1l and c2c<=c1h)
    bool bear=(highSweep and c2c<c1l) or (highSweep and not lowSweep and c2c>=c1l and c2c<c1h)
    bool valid=bull!=bear and c1h!=c1l and not na(c2atr) and c2atr>0
    if not ee_is4h
        ee_research_state:=not na(c2atr)?"ATR_READY":"ATR_WARMUP"
    if valid
        if ee_active
            ee_lifecycle:="SUPERSEDED"
        float eventReclaim=bull?100*(c2c-c1l)/(c1h-c1l):100*(c1h-c2c)/(c1h-c1l)
        [q25,q50,q75,q90]=ee_quantiles(eventReclaim,ee_is4h,ee_is1h)
        // --- STRUCTURAL EXPECTANCY V1: COMPLETED-C2 SNAPSHOT START ---
        // Exact frozen directional rejection wick: body-side rejection divided
        // by completed C2 range. It is captured once and never reads C3/C4.
        float eventC2Range=c2h-c2l
        float eventDirectionalWick=eventC2Range>0.0?(bull?100.0*(math.min(c2o,c2c)-c2l)/eventC2Range:100.0*(c2h-math.max(c2o,c2c))/eventC2Range):na
        bool seInputSupported=se_reclaim_supported(eventReclaim) and (ee_is4h or se_wick_supported(eventDirectionalWick))
        float seReach=na
        float seIntact=na
        if seInputSupported
            seReach:=ee_is4h?se_4h_reach(eventReclaim):ee_is1h?se_1h_reach(eventReclaim,eventDirectionalWick):se_15m_reach(eventReclaim,eventDirectionalWick)
            seIntact:=ee_is4h?se_4h_intact(eventReclaim):ee_is1h?se_1h_intact(eventReclaim):se_15m_intact(eventReclaim,eventDirectionalWick)
        ee_se_active_wick:=eventDirectionalWick
        ee_se_reach_probability:=seReach
        ee_se_intact_probability:=seIntact
        ee_se_available:=seInputSupported and se_probability_valid(seReach) and se_probability_valid(seIntact)
        // --- STRUCTURAL EXPECTANCY V1: COMPLETED-C2 SNAPSHOT END ---
        ee_active:=true
        ee_active_bull:=bull
        ee_active_c2_time:=c2open
        ee_active_c2_close_time:=c2close
        ee_active_close:=c2c
        ee_active_display_close:=ee_is4h?(ee_host_4h_timestamp_match?ee_host_4h_anchor:na):c2c
        ee_active_display_tick:=ee_is4h?ee_host_4h_tick:syminfo.mintick
        ee_active_host_match:=not ee_is4h or ee_host_4h_timestamp_match
        ee_active_extreme:=bull?c2l:c2h
        ee_active_reclaim:=eventReclaim
        ee_active_atr:=c2atr
        ee_p25:=q25
        ee_p50:=q50
        ee_p75:=q75
        ee_p90:=q90
        ee_after_c2:=0
        ee_active_segment:=ee_segment
        ee_4h_mode:=ee_is4h?(ee_blackout?ROLLOVER_ATR_FALLBACK:NORMAL_4H_EE):NORMAL_4H_EE
        ee_lifecycle:=ee_active_host_match?"ACTIVE C2":"HOST TIMESTAMP UNMATCHED"
    else if ee_active and canQualify
        ee_after_c2+=1
        if ee_after_c2>=2
            ee_active:=false
            ee_4h_mode:=INACTIVE_INVALID
            ee_lifecycle:="C4_COMPLETE"
    if ee_is4h and candidateEligible
        ee_retained_o:=ee_n_open
        ee_retained_h:=ee_n_high
        ee_retained_l:=ee_n_low
        ee_retained_c:=ee_n_close
        ee_have_c1:=true
    if ee_is4h and rolloverStructureEligible
        ee_roll_retained_o:=ee_n_open
        ee_roll_retained_h:=ee_n_high
        ee_roll_retained_l:=ee_n_low
        ee_roll_retained_c:=ee_n_close
        ee_roll_have_c1:=true
    // Track trustworthy native boundaries through blackout. This prevents the
    // first post-roll packet from becoming a false non-roll gap barrier.
    if ee_is4h and ee_ordinary_open(ee_n_open_time) and (ee_blackout or ee_integrity_available)
        ee_previous_native_open:=ee_n_open_time
    ee_previous_packet_time:=ee_is4h?ee_n_open_time:ee_std_close_time
    if ee_is4h
        ee_previous_blackout:=ee_blackout

float ee_failure_low=ee_is4h?ee_n_live_low:low
float ee_failure_high=ee_is4h?ee_n_live_high:high
bool ee_strict_failure=ee_active and time>=ee_active_c2_close_time and ((ee_active_bull and ee_failure_low<ee_active_extreme) or (not ee_active_bull and ee_failure_high>ee_active_extreme))
if ee_strict_failure
    ee_active:=false
    ee_4h_mode:=INACTIVE_INVALID
    ee_lifecycle:="C2_FAILED"

float ee_target_anchor=ee_is4h?ee_active_display_close:ee_active_close
float ee_target_points=ee_active and (not ee_is4h or ee_active_host_match)?(ee_active_bull?ee_manual_target-ee_target_anchor:ee_target_anchor-ee_manual_target):na
float ee_target_atr=ee_active and not na(ee_active_atr)?ee_target_points/ee_active_atr:na
bool ee_rollover_fallback_active=ee_is4h and ee_active and ee_active_host_match and ee_4h_mode==ROLLOVER_ATR_FALLBACK
string ee_target_state=ee_rollover_fallback_active?"UNAVAILABLE IN ATR FALLBACK":ee_manual_target==0?"OFF":not ee_active?"NO ACTIVE C2":ee_is4h and not ee_active_host_match?"HOST TIMESTAMP UNMATCHED":ee_target_points<=0?"TARGET INVALID DIRECTION":ee_target_atr<0.10?"BELOW VALIDATED RANGE (<0.10 ATR)":ee_target_atr>2.00?"ABOVE VALIDATED RANGE (>2.00 ATR)":"VALID"
float ee_target_probability=not ee_rollover_fallback_active and ee_target_state=="VALID"?(ee_is4h?ee_native_probability(ee_active_reclaim,ee_target_atr):ee_standard_probability(ee_active_reclaim,ee_target_atr,ee_is1h)):na

// Phase 2 renderer: current active event only. Prices always originate at the
// frozen completed C2 close; these are historical conditional percentiles.
var line ee_projection_p25=na
var line ee_projection_p50=na
var line ee_projection_p75=na
var line ee_projection_p90=na
var label ee_projection_label25=na
var label ee_projection_label50=na
var label ee_projection_label75=na
var label ee_projection_label90=na
var linefill ee_projection_fill=na
var string ee_projection_tf=ee_selected_tf

bool ee_projection_tf_changed=ee_projection_tf!=ee_selected_tf
color ee_selected_base_color=ee_is4h?ee_4h_base_color:ee_is1h?ee_1h_base_color:ee_15m_base_color
bool ee_use_legacy_palette=ee_selected_base_color==color.aqua
color ee_projection_range_color=ee_use_legacy_palette?ee_range_color:color.new(ee_selected_base_color,65)
color ee_projection_p50_color=ee_use_legacy_palette?ee_p50_color:color.new(ee_selected_base_color,20)
color ee_projection_p90_color=ee_use_legacy_palette?ee_p90_color:color.new(ee_selected_base_color,40)
string ee_projection_label_size=ee_text_size(ee_label_size_input)
bool ee_projection_active=ee_enabled and ee_show_projection and ee_active and ee_host_supported and ee_symbol_ok and (not ee_is4h or ee_active_host_match) and not ee_projection_tf_changed
if not ee_projection_active
    if not na(ee_projection_fill)
        linefill.delete(ee_projection_fill)
        ee_projection_fill:=na
    if not na(ee_projection_p25)
        line.delete(ee_projection_p25)
        ee_projection_p25:=na
    if not na(ee_projection_p50)
        line.delete(ee_projection_p50)
        ee_projection_p50:=na
    if not na(ee_projection_p75)
        line.delete(ee_projection_p75)
        ee_projection_p75:=na
    if not na(ee_projection_p90)
        line.delete(ee_projection_p90)
        ee_projection_p90:=na
    if not na(ee_projection_label25)
        label.delete(ee_projection_label25)
        ee_projection_label25:=na
    if not na(ee_projection_label50)
        label.delete(ee_projection_label50)
        ee_projection_label50:=na
    if not na(ee_projection_label75)
        label.delete(ee_projection_label75)
        ee_projection_label75:=na
    if not na(ee_projection_label90)
        label.delete(ee_projection_label90)
        ee_projection_label90:=na
    ee_projection_tf:=ee_selected_tf
else
    float ee_projection_sign=ee_active_bull?1.0:-1.0
    float ee_projection_anchor=ee_is4h?ee_active_display_close:ee_active_close
    float ee_projection_raw25=ee_projection_anchor+ee_projection_sign*ee_p25*ee_active_atr
    float ee_projection_raw50=ee_projection_anchor+ee_projection_sign*ee_p50*ee_active_atr
    float ee_projection_raw75=ee_projection_anchor+ee_projection_sign*ee_p75*ee_active_atr
    float ee_projection_raw90=ee_projection_anchor+ee_projection_sign*ee_p90*ee_active_atr
    float ee_projection_price25=ee_is4h?math.round(ee_projection_raw25/ee_active_display_tick)*ee_active_display_tick:ee_projection_raw25
    float ee_projection_price50=ee_is4h?math.round(ee_projection_raw50/ee_active_display_tick)*ee_active_display_tick:ee_projection_raw50
    float ee_projection_price75=ee_is4h?math.round(ee_projection_raw75/ee_active_display_tick)*ee_active_display_tick:ee_projection_raw75
    float ee_projection_price90=ee_is4h?math.round(ee_projection_raw90/ee_active_display_tick)*ee_active_display_tick:ee_projection_raw90
    int ee_projection_x1=ee_active_c2_close_time
    int ee_projection_x2=time+ee_projection_length*ee_host_seconds*1000
    string ee_projection_tf_label=ee_is4h?"4H":ee_is1h?"1H":"15m"
    string ee_projection_text25=ee_projection_tf_label+" P25 · "+str.tostring(ee_p25*ee_active_atr,"#.00")+" NQ pts"+(ee_show_price_in_labels?" · "+str.tostring(ee_projection_price25,format.mintick):"")
    string ee_projection_text50=ee_projection_tf_label+" P50 · "+str.tostring(ee_p50*ee_active_atr,"#.00")+" NQ pts"+(ee_show_price_in_labels?" · "+str.tostring(ee_projection_price50,format.mintick):"")
    string ee_projection_text75=ee_projection_tf_label+" P75 · "+str.tostring(ee_p75*ee_active_atr,"#.00")+" NQ pts"+(ee_show_price_in_labels?" · "+str.tostring(ee_projection_price75,format.mintick):"")
    string ee_projection_text90=ee_projection_tf_label+" P90 · "+str.tostring(ee_p90*ee_active_atr,"#.00")+" NQ pts"+(ee_show_price_in_labels?" · "+str.tostring(ee_projection_price90,format.mintick):"")
    if na(ee_projection_p25)
        ee_projection_p25:=line.new(ee_projection_x1,ee_projection_price25,ee_projection_x2,ee_projection_price25,xloc=xloc.bar_time,color=ee_projection_range_color,width=1)
    else
        line.set_xy1(ee_projection_p25,ee_projection_x1,ee_projection_price25)
        line.set_xy2(ee_projection_p25,ee_projection_x2,ee_projection_price25)
        line.set_color(ee_projection_p25,ee_projection_range_color)
    if ee_show_level_labels
        if na(ee_projection_label25)
            ee_projection_label25:=label.new(ee_projection_x2,ee_projection_price25,ee_projection_text25,xloc=xloc.bar_time,style=label.style_label_left,textcolor=ee_projection_range_color,color=color.new(color.black,80),size=ee_projection_label_size)
        else
            label.set_xy(ee_projection_label25,ee_projection_x2,ee_projection_price25)
            label.set_text(ee_projection_label25,ee_projection_text25)
            label.set_textcolor(ee_projection_label25,ee_projection_range_color)
            label.set_size(ee_projection_label25,ee_projection_label_size)
    else if not na(ee_projection_label25)
        label.delete(ee_projection_label25)
        ee_projection_label25:=na
    if na(ee_projection_p50)
        ee_projection_p50:=line.new(ee_projection_x1,ee_projection_price50,ee_projection_x2,ee_projection_price50,xloc=xloc.bar_time,color=ee_projection_p50_color,width=2)
    else
        line.set_xy1(ee_projection_p50,ee_projection_x1,ee_projection_price50)
        line.set_xy2(ee_projection_p50,ee_projection_x2,ee_projection_price50)
        line.set_color(ee_projection_p50,ee_projection_p50_color)
    if ee_show_level_labels
        if na(ee_projection_label50)
            ee_projection_label50:=label.new(ee_projection_x2,ee_projection_price50,ee_projection_text50,xloc=xloc.bar_time,style=label.style_label_left,textcolor=ee_projection_p50_color,color=color.new(color.black,80),size=ee_projection_label_size)
        else
            label.set_xy(ee_projection_label50,ee_projection_x2,ee_projection_price50)
            label.set_text(ee_projection_label50,ee_projection_text50)
            label.set_textcolor(ee_projection_label50,ee_projection_p50_color)
            label.set_size(ee_projection_label50,ee_projection_label_size)
    else if not na(ee_projection_label50)
        label.delete(ee_projection_label50)
        ee_projection_label50:=na
    if na(ee_projection_p75)
        ee_projection_p75:=line.new(ee_projection_x1,ee_projection_price75,ee_projection_x2,ee_projection_price75,xloc=xloc.bar_time,color=ee_projection_range_color,width=1)
    else
        line.set_xy1(ee_projection_p75,ee_projection_x1,ee_projection_price75)
        line.set_xy2(ee_projection_p75,ee_projection_x2,ee_projection_price75)
        line.set_color(ee_projection_p75,ee_projection_range_color)
    if ee_show_level_labels
        if na(ee_projection_label75)
            ee_projection_label75:=label.new(ee_projection_x2,ee_projection_price75,ee_projection_text75,xloc=xloc.bar_time,style=label.style_label_left,textcolor=ee_projection_range_color,color=color.new(color.black,80),size=ee_projection_label_size)
        else
            label.set_xy(ee_projection_label75,ee_projection_x2,ee_projection_price75)
            label.set_text(ee_projection_label75,ee_projection_text75)
            label.set_textcolor(ee_projection_label75,ee_projection_range_color)
            label.set_size(ee_projection_label75,ee_projection_label_size)
    else if not na(ee_projection_label75)
        label.delete(ee_projection_label75)
        ee_projection_label75:=na
    if ee_projection_detail=="Expanded"
        if na(ee_projection_p90)
            ee_projection_p90:=line.new(ee_projection_x1,ee_projection_price90,ee_projection_x2,ee_projection_price90,xloc=xloc.bar_time,color=ee_projection_p90_color,width=1,style=line.style_dashed)
        else
            line.set_xy1(ee_projection_p90,ee_projection_x1,ee_projection_price90)
            line.set_xy2(ee_projection_p90,ee_projection_x2,ee_projection_price90)
            line.set_color(ee_projection_p90,ee_projection_p90_color)
        if ee_show_level_labels
            if na(ee_projection_label90)
                ee_projection_label90:=label.new(ee_projection_x2,ee_projection_price90,ee_projection_text90,xloc=xloc.bar_time,style=label.style_label_left,textcolor=ee_projection_p90_color,color=color.new(color.black,80),size=ee_projection_label_size)
            else
                label.set_xy(ee_projection_label90,ee_projection_x2,ee_projection_price90)
                label.set_text(ee_projection_label90,ee_projection_text90)
                label.set_textcolor(ee_projection_label90,ee_projection_p90_color)
                label.set_size(ee_projection_label90,ee_projection_label_size)
        else if not na(ee_projection_label90)
            label.delete(ee_projection_label90)
            ee_projection_label90:=na
    else if not na(ee_projection_p90)
        line.delete(ee_projection_p90)
        ee_projection_p90:=na
    if ee_projection_detail!="Expanded" and not na(ee_projection_label90)
        label.delete(ee_projection_label90)
        ee_projection_label90:=na
    if ee_show_fill
        if na(ee_projection_fill)
            ee_projection_fill:=linefill.new(ee_projection_p25,ee_projection_p75,color.new(ee_projection_range_color,ee_fill_transparency))
        else
            linefill.set_color(ee_projection_fill,color.new(ee_projection_range_color,ee_fill_transparency))
    else if not na(ee_projection_fill)
        linefill.delete(ee_projection_fill)
        ee_projection_fill:=na

// --- STRUCTURAL EXPECTANCY V1: PANEL INTEGRATION START ---
var table ee_panel=table.new(position.bottom_left,2,27,bgcolor=color.rgb(8,8,8),frame_color=color.gray,frame_width=1)
if barstate.islast
    table.clear(ee_panel,0,0,1,26)
    if ee_enabled and ee_show_panel
        table.cell(ee_panel,0,0,ee_rollover_fallback_active?"4H EE — ROLLOVER":"EXPECTED EXPANSION · HISTORICAL",text_color=color.white)
        table.merge_cells(ee_panel,0,0,1,0)
        if ee_rollover_fallback_active
            table.cell(ee_panel,0,1,"ATR fallback active",text_color=color.orange)
            table.merge_cells(ee_panel,0,1,1,1)
        else
            table.cell(ee_panel,0,1,"TF",text_color=color.silver)
            table.cell(ee_panel,1,1,ee_is4h?"4h ordinary non-roll":ee_selected_tf,text_color=color.white)
        table.cell(ee_panel,0,2,"State",text_color=color.silver)
        string ee_panel_state=ee_active and ee_is4h and not ee_active_host_match?"HOST TIMESTAMP UNMATCHED":ee_active?"ACTIVE C2 · "+(ee_active_bull?"BULL":"BEAR"):ee_lifecycle
        table.cell(ee_panel,1,2,ee_panel_state,text_color=ee_active and (not ee_is4h or ee_active_host_match)?color.aqua:color.silver)
        bool seRolloverReference=ee_is4h and ee_rollover_fallback_active
        float seDisplayStep=ee_is4h?10.0:5.0
        string seReachText=ee_active and ee_se_available?se_display(ee_se_reach_probability,seDisplayStep,seRolloverReference):"n/a"
        string seIntactText=ee_active and ee_se_available?se_display(ee_se_intact_probability,seDisplayStep,seRolloverReference):"n/a"
        table.cell(ee_panel,0,3,"Reclaim",text_color=color.silver)
        table.cell(ee_panel,1,3,ee_active?str.tostring(ee_active_reclaim,"#.0")+"%":"n/a",text_color=ee_active?color.white:color.silver)
        table.cell(ee_panel,0,4,"Reach C4",text_color=color.silver,tooltip="Approximate historical conditional probability that the completed C2 protected extreme remains intact through C3 to the opening of C4.")
        table.cell(ee_panel,1,4,seReachText,text_color=ee_active and ee_se_available?color.white:color.silver)
        table.cell(ee_panel,0,5,"C4 Intact",text_color=color.silver,tooltip="Approximate historical conditional probability that the completed C2 protected extreme remains intact through C3 and the complete C4 candle through its close. Structural Expectancy is a frozen historical model estimate, not a trade-win, profitability, target-hit, or Expected Expansion probability.")
        table.cell(ee_panel,1,5,seIntactText,text_color=ee_active and ee_se_available?color.white:color.silver)
        int sePanelOffset=seRolloverReference?1:0
        if seRolloverReference
            table.cell(ee_panel,0,6,"Structural",text_color=color.silver,tooltip="During 4H rollover fallback, the displayed Structural Expectancy is a reference calculation from the frozen ordinary non-roll model. Rollover events were excluded from model development and validation; these values are not rollover-calibrated probabilities.")
            table.cell(ee_panel,1,6,"NON-ROLL MODEL*",text_color=color.orange)
        if ee_active
            table.cell(ee_panel,0,6+sePanelOffset,"Median expansion",text_color=color.silver)
            table.cell(ee_panel,1,6+sePanelOffset,"P50 · "+str.tostring(ee_p50*ee_active_atr,"#.0")+" pts",text_color=ee_p50_color)
            table.cell(ee_panel,0,7+sePanelOffset,"Central range",text_color=color.silver)
            table.cell(ee_panel,1,7+sePanelOffset,"P25–P75 · "+str.tostring(ee_p25*ee_active_atr,"#.0")+"–"+str.tostring(ee_p75*ee_active_atr,"#.0")+" pts",text_color=ee_range_color)
            table.cell(ee_panel,0,8+sePanelOffset,"Tail expansion",text_color=color.silver)
            table.cell(ee_panel,1,8+sePanelOffset,"P90 · "+str.tostring(ee_p90*ee_active_atr,"#.0")+" pts",text_color=ee_p90_color)
            if ee_show_manual_target
                table.cell(ee_panel,0,9+sePanelOffset,"Target",text_color=color.silver)
                table.cell(ee_panel,1,9+sePanelOffset,ee_manual_target==0?"OFF":str.tostring(ee_manual_target,format.mintick),text_color=color.white)
                table.cell(ee_panel,0,10+sePanelOffset,"Distance",text_color=color.silver)
                table.cell(ee_panel,1,10+sePanelOffset,ee_manual_target==0?"-":str.tostring(ee_target_points,"#.0")+" pts / "+str.tostring(ee_target_atr,"#.00")+" ATR",text_color=color.white)
                table.cell(ee_panel,0,11+sePanelOffset,"Historical reach",text_color=color.silver)
                table.cell(ee_panel,1,11+sePanelOffset,na(ee_target_probability)?ee_target_state:"~"+str.tostring(100*ee_target_probability,"#.1")+"%",text_color=color.white)
        int seExpandedOffset=ee_rollover_fallback_active?1:0
        if ee_panel_detail=="Expanded"
            table.cell(ee_panel,0,12+seExpandedOffset,"Eligibility",text_color=color.silver)
            table.cell(ee_panel,1,12+seExpandedOffset,ee_research_state,text_color=color.white)
            table.cell(ee_panel,0,13+seExpandedOffset,"Lifecycle",text_color=color.silver)
            table.cell(ee_panel,1,13+seExpandedOffset,ee_lifecycle,text_color=color.white)
            table.cell(ee_panel,0,14+seExpandedOffset,"Active C2 time",text_color=color.silver)
            table.cell(ee_panel,1,14+seExpandedOffset,ee_active?str.format_time(ee_active_c2_time,"yyyy-MM-dd HH:mm",ee_is4h?EE_TZ:"Etc/UTC"):"-",text_color=color.white)
            table.cell(ee_panel,0,15+seExpandedOffset,"C2 close / protected",text_color=color.silver)
            table.cell(ee_panel,1,15+seExpandedOffset,ee_active?str.tostring(ee_active_close,format.mintick)+" / "+str.tostring(ee_active_extreme,format.mintick):"-",text_color=color.white)
            table.cell(ee_panel,0,16+seExpandedOffset,"Reclaim / ATR20",text_color=color.silver)
            table.cell(ee_panel,1,16+seExpandedOffset,ee_active?str.tostring(ee_active_reclaim,"#.00")+"% / "+str.tostring(ee_active_atr,"#.0000"):"-",text_color=color.white)
            table.cell(ee_panel,0,17+seExpandedOffset,"P25 / P50",text_color=color.silver)
            table.cell(ee_panel,1,17+seExpandedOffset,ee_active?str.tostring(ee_p25,"#.0000")+" / "+str.tostring(ee_p50,"#.0000"):"-",text_color=color.white)
            table.cell(ee_panel,0,18+seExpandedOffset,"P75 / P90",text_color=color.silver)
            table.cell(ee_panel,1,18+seExpandedOffset,ee_active?str.tostring(ee_p75,"#.0000")+" / "+str.tostring(ee_p90,"#.0000"):"-",text_color=color.white)
        if ee_panel_detail=="Expanded" and ee_is4h and ee_show_4h_detail
            table.cell(ee_panel,0,19+seExpandedOffset,"Native open / close CT",text_color=color.white)
            table.cell(ee_panel,1,19+seExpandedOffset,str.format_time(ee_n_open_time,"MM-dd HH:mm",EE_TZ)+" / "+str.format_time(ee_n_close_time,"MM-dd HH:mm",EE_TZ),text_color=color.white)
            table.cell(ee_panel,0,20+seExpandedOffset,"Duration",text_color=color.white)
            table.cell(ee_panel,1,20+seExpandedOffset,str.tostring(ee_native_duration)+"m",text_color=color.white)
            table.cell(ee_panel,0,21+seExpandedOffset,"Expected / retrieved",text_color=color.white)
            table.cell(ee_panel,1,21+seExpandedOffset,str.tostring(ee_expected)+" / "+str.tostring(ee_retrieved),text_color=color.white)
            table.cell(ee_panel,0,22+seExpandedOffset,"Continuity",text_color=color.white)
            table.cell(ee_panel,1,22+seExpandedOffset,str.tostring(ee_continuity),text_color=color.white)
            table.cell(ee_panel,0,23+seExpandedOffset,"Roll blackout",text_color=color.white)
            table.cell(ee_panel,1,23+seExpandedOffset,str.tostring(ee_blackout),text_color=color.white)
            table.cell(ee_panel,0,24+seExpandedOffset,"Barrier before bar",text_color=color.white)
            table.cell(ee_panel,1,24+seExpandedOffset,str.tostring(ee_barrier_before),text_color=color.white)
            table.cell(ee_panel,0,25+seExpandedOffset,"ATR warm-up / segment",text_color=color.white)
            table.cell(ee_panel,1,25+seExpandedOffset,str.tostring(ee_warmup)+"/20 · "+str.tostring(ee_segment),text_color=color.white)
// --- STRUCTURAL EXPECTANCY V1: PANEL INTEGRATION END ---

//+------------------------------------------------------------------------------------------------------------+//
//+--- NQ Daily Expected Expansion V3 — checkpoint continuation candidate                                   ---+//
//+------------------------------------------------------------------------------------------------------------+//
// Research status: PRE-2026 FROZEN · SUPPORTED WITH CAUTION · NOT FORWARD VALIDATED.
// Endpoint: empirical quantiles of MFE_BEFORE_C2_FAILURE. These are neither
// trade probabilities nor guaranteed targets. All model state is NQ-derived.

bool dee_show_p25 = dee_display_mode == "P25 / P50 / P75"
bool dee_show_p50 = true
bool dee_show_p75 = dee_display_mode == "P25 / P50 / P75"
bool dee_use_legacy_palette = dee_base_color == color.aqua
color dee_range_color = dee_use_legacy_palette ? ee_range_color : color.new(dee_base_color, 65)
color dee_p50_color = dee_use_legacy_palette ? ee_p50_color : color.new(dee_base_color, 20)
string dee_label_size = ee_text_size(dee_label_size_input)

float DEE_Q25 = 0.14584735977903024
float DEE_Q50 = 0.3659379051380365
float DEE_Q75 = 0.8948402206564403
int DEE_CHECKPOINT_DATE = timestamp("America/Chicago", 2025, 12, 31, 16, 0)
int DEE_DAY_MS = 86400000

int DEE_PRECHECKPOINT = 0
int DEE_WARMING = 1
int DEE_NO_C2 = 2
int DEE_ACTIVE = 3
int DEE_ROLL = 4
int DEE_STATE_INVALID = 6

string deeNqSource = ticker.new(prefix="CME_MINI", ticker="NQ1!", session=session.extended, adjustment=adjustment.none, backadjustment=backadjustment.off, settlement_as_close=settlement_as_close.off)
string deeMnqSource = ticker.new(prefix="CME_MINI", ticker="MNQ1!", session=session.extended, adjustment=adjustment.none, backadjustment=backadjustment.off, settlement_as_close=settlement_as_close.off)

dee_third_friday(int stamp) =>
    int y = year(stamp, "America/Chicago")
    int m = month(stamp, "America/Chicago")
    int firstDow = dayofweek(timestamp("America/Chicago", y, m, 1, 0, 0))
    int firstFriday = 1 + (dayofweek.friday - firstDow + 7) % 7
    firstFriday + 14

dee_roll_blackout(int stamp) =>
    int m = month(stamp, "America/Chicago")
    int d = dayofmonth(stamp, "America/Chicago")
    int anchor = dee_third_friday(stamp)
    (m == 3 or m == 6 or m == 9 or m == 12) and d >= anchor - 10 and d <= anchor + 4

dee_expected_next(int stamp) =>
    int y = year(stamp, "America/Chicago")
    int m = month(stamp, "America/Chicago")
    int d = dayofmonth(stamp, "America/Chicago")
    int dow = dayofweek(stamp, "America/Chicago")
    int addDays = dow == dayofweek.friday ? 3 : dow == dayofweek.saturday ? 2 : 1
    timestamp("America/Chicago", y, m, d + addDays, 16, 0)

// The current frozen prospective calendar has no post-checkpoint immutable
// early-close table. Known holiday-adjacent dates therefore fail closed rather
// than being generalized from historical examples.
dee_unsupported_special(int stamp) =>
    int m = month(stamp, "America/Chicago")
    int d = dayofmonth(stamp, "America/Chicago")
    int dow = dayofweek(stamp, "America/Chicago")
    bool thanksgivingAdjacent = m == 11 and (dow == dayofweek.thursday or dow == dayofweek.friday) and d >= 22 and d <= 29
    bool christmasAdjacent = m == 12 and d >= 23 and d <= 26
    bool independenceAdjacent = m == 7 and d >= 2 and d <= 5
    thanksgivingAdjacent or christmasAdjacent or independenceAdjacent

// Executes inside the authoritative NQ Daily request context. Every input uses
// [1], so only the prior completed Daily bar is processed. lookahead_on below
// merely publishes that already-completed packet at the next Daily open.
dee_daily_packet() =>
    var bool initialized = false
    var bool validState = true
    var int lastProcessed = na
    var float atr20 = na
    var float seedSum = 0.0
    var int seedCount = 0
    var float previousClose = na
    var bool afterRoll = false
    var int admittedLifetime = 0
    var float c1o = na
    var float c1h = na
    var float c1l = na
    var float c1c = na
    var bool haveC1 = false
    var bool active = false
    var bool activeBull = false
    var int activeC2Date = na
    var float activeC2Close = na
    var float activeExtreme = na
    var float activeAtr = na
    var int afterC2 = 0
    var int eventSerial = 0
    var int status = DEE_PRECHECKPOINT
    int td = time_close[1]
    float o = open[1]
    float h = high[1]
    float l = low[1]
    float c = close[1]
    bool newCompleted = not na(td) and (na(lastProcessed) or td != lastProcessed)
    if newCompleted
        if td <= DEE_CHECKPOINT_DATE
            status := DEE_PRECHECKPOINT
            lastProcessed := td
        else
            if not initialized
                // Exact state after 2025-12-31. ATR is deliberately not ready.
                atr20 := na
                seedSum := 245.75 + 125.5 + 287.75
                seedCount := 3
                previousClose := 25434.75
                afterRoll := false
                admittedLifetime := 2567
                haveC1 := true
                // C1 OHLC is required for the first prospective C2 comparison.
                c1o := 25683.25
                c1h := 25716.75
                c1l := 25429.00
                c1c := 25434.75
                lastProcessed := DEE_CHECKPOINT_DATE
                initialized := true
                validState := true
            bool finiteBar = not na(o) and not na(h) and not na(l) and not na(c) and h >= math.max(math.max(o, c), l) and l <= math.min(math.min(o, c), h)
            bool rollToday = dee_roll_blackout(td)
            bool special = dee_unsupported_special(td)
            bool chronologyGap = not na(lastProcessed) and td != dee_expected_next(lastProcessed)
            if not finiteBar
                atr20 := na
                seedSum := 0.0
                seedCount := 0
                previousClose := na
                afterRoll := false
                haveC1 := false
                active := false
                validState := false
                status := DEE_STATE_INVALID
            else if rollToday
                afterRoll := true
                previousClose := na
                haveC1 := false
                active := false
                validState := true
                status := DEE_ROLL
            else if special
                atr20 := na
                seedSum := 0.0
                seedCount := 0
                previousClose := na
                afterRoll := false
                haveC1 := false
                active := false
                validState := false
                status := DEE_STATE_INVALID
            else
                if chronologyGap
                    // An absent expected weekday is never assumed to be a holiday.
                    atr20 := na
                    seedSum := 0.0
                    seedCount := 0
                    previousClose := na
                    afterRoll := false
                    haveC1 := false
                    active := false
                    validState := false
                float tr = na(previousClose) or afterRoll ? h - l : math.max(h - l, math.max(math.abs(h - previousClose), math.abs(l - previousClose)))
                if na(atr20)
                    seedSum += tr
                    seedCount += 1
                    if seedCount == 20
                        atr20 := seedSum / 20.0
                else
                    atr20 := (19.0 * atr20 + tr) / 20.0
                // Existing event expires on strict NQ protected-extreme breach
                // or after the second completed post-C2 bar (completed C4).
                if active and td > activeC2Date
                    bool failed = activeBull ? l < activeExtreme : h > activeExtreme
                    afterC2 += 1
                    if failed or afterC2 >= 2
                        active := false
                bool lowSweep = haveC1 and l < c1l
                bool highSweep = haveC1 and h > c1h
                bool bull = (lowSweep and c > c1h) or (lowSweep and not highSweep and c > c1l and c <= c1h)
                bool bear = (highSweep and c < c1l) or (highSweep and not lowSweep and c >= c1l and c < c1h)
                bool validC2 = bull != bear and c1h != c1l and not na(atr20) and atr20 > 0
                if validC2
                    active := true
                    activeBull := bull
                    activeC2Date := td
                    activeC2Close := c
                    activeExtreme := bull ? l : h
                    activeAtr := atr20
                    afterC2 := 0
                    eventSerial += 1
                previousClose := c
                afterRoll := false
                admittedLifetime += 1
                c1o := o
                c1h := h
                c1l := l
                c1c := c
                haveC1 := true
                validState := true
                status := active ? DEE_ACTIVE : na(atr20) ? DEE_WARMING : DEE_NO_C2
            lastProcessed := td
    [td, status, atr20, seedCount, previousClose, afterRoll, admittedLifetime, active, activeBull, activeC2Date, activeC2Close, activeExtreme, activeAtr, afterC2, eventSerial, validState]

[deeTradeDate, deeModelStatus, deeAtr20, deeSeedCount, deePreviousClose, deeAfterRoll, deeAdmittedLifetime, deeActive, deeActiveBull, deeC2Date, deeC2Close, deeC2Extreme, deeC2Atr, deeAfterC2, deeEventSerial, deeValidState] = request.security(deeNqSource, "1D", dee_daily_packet(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[deeMnqDate, deeMnqClose, deeMnqTick] = request.security(deeMnqSource, "1D", [time_close[1], close[1], syminfo.mintick], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[deeNqLiveLow, deeNqLiveHigh] = request.security(deeNqSource, "1D", [low, high], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

bool deeHostNq = syminfo.root == "NQ"
bool deeHostMnq = syminfo.root == "MNQ"
bool deeHostSupported = deeHostNq or deeHostMnq
bool deeNqAvailable = not na(deeTradeDate) and not na(deeModelStatus)
bool deeMnqMatched = not deeHostMnq or deeMnqDate == deeC2Date
bool deeLiveFailure = deeActive and not na(deeNqLiveLow) and not na(deeNqLiveHigh) and (deeActiveBull ? deeNqLiveLow < deeC2Extreme : deeNqLiveHigh > deeC2Extreme)

var int deeSeenEventSerial = na
var float deeMnqAnchor = na
if deeActive and (na(deeSeenEventSerial) or deeEventSerial != deeSeenEventSerial)
    deeMnqAnchor := deeMnqDate == deeC2Date ? deeMnqClose : na
    deeSeenEventSerial := deeEventSerial
else if not deeActive
    deeMnqAnchor := na

string deeStatusText = not dee_enabled ? "DISABLED" : not deeHostSupported ? "UNSUPPORTED HOST SYMBOL" : not deeNqAvailable ? "NQ SOURCE UNAVAILABLE" : deeModelStatus == DEE_PRECHECKPOINT ? "PRE-CHECKPOINT — UNAVAILABLE" : deeModelStatus == DEE_WARMING ? "WARMING " + str.tostring(deeSeedCount) + "/20" : deeModelStatus == DEE_ROLL ? "ROLL BLACKOUT" : deeModelStatus == DEE_STATE_INVALID or not deeValidState ? "DAILY EE STATE INVALID" : deeLiveFailure ? "NO VALID DAILY C2" : deeActive and deeHostMnq and na(deeMnqAnchor) ? "MNQ TIMESTAMP UNMATCHED" : deeActive ? "ACTIVE DAILY C2 · " + (deeActiveBull ? "BULL" : "BEAR") : "NO VALID DAILY C2"

bool deeProjectionActive = dee_enabled and deeHostSupported and deeNqAvailable and deeModelStatus == DEE_ACTIVE and deeActive and not deeLiveFailure and (deeHostNq or not na(deeMnqAnchor))
float deeSign = deeActiveBull ? 1.0 : -1.0
float deeDistance25 = deeC2Atr * DEE_Q25
float deeDistance50 = deeC2Atr * DEE_Q50
float deeDistance75 = deeC2Atr * DEE_Q75
float deeAnchor = deeHostMnq ? deeMnqAnchor : deeC2Close
float deeRawLevel25 = deeAnchor + deeSign * deeDistance25
float deeRawLevel50 = deeAnchor + deeSign * deeDistance50
float deeRawLevel75 = deeAnchor + deeSign * deeDistance75
float deeLevel25 = deeHostMnq ? math.round(deeRawLevel25 / deeMnqTick) * deeMnqTick : deeRawLevel25
float deeLevel50 = deeHostMnq ? math.round(deeRawLevel50 / deeMnqTick) * deeMnqTick : deeRawLevel50
float deeLevel75 = deeHostMnq ? math.round(deeRawLevel75 / deeMnqTick) * deeMnqTick : deeRawLevel75

var line deeLine25 = na
var line deeLine50 = na
var line deeLine75 = na
var label deeLabel25 = na
var label deeLabel50 = na
var label deeLabel75 = na
int deeX1 = deeC2Date
int deeX2 = time + ee_projection_length * timeframe.in_seconds() * 1000

if not deeProjectionActive
    if not na(deeLine25)
        line.delete(deeLine25)
        deeLine25 := na
    if not na(deeLine50)
        line.delete(deeLine50)
        deeLine50 := na
    if not na(deeLine75)
        line.delete(deeLine75)
        deeLine75 := na
    if not na(deeLabel25)
        label.delete(deeLabel25)
        deeLabel25 := na
    if not na(deeLabel50)
        label.delete(deeLabel50)
        deeLabel50 := na
    if not na(deeLabel75)
        label.delete(deeLabel75)
        deeLabel75 := na
else
    if dee_show_p25
        if na(deeLine25)
            deeLine25 := line.new(deeX1, deeLevel25, deeX2, deeLevel25, xloc=xloc.bar_time, color=dee_range_color, width=1)
            deeLabel25 := label.new(deeX2, deeLevel25, "1D P25 · " + str.tostring(deeDistance25, "#.00") + " NQ pts · " + str.tostring(deeLevel25, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, textcolor=dee_range_color, color=color.new(color.black, 80), size=dee_label_size)
        else
            line.set_xy1(deeLine25, deeX1, deeLevel25)
            line.set_xy2(deeLine25, deeX2, deeLevel25)
            line.set_color(deeLine25, dee_range_color)
            label.set_xy(deeLabel25, deeX2, deeLevel25)
            label.set_text(deeLabel25, "1D P25 · " + str.tostring(deeDistance25, "#.00") + " NQ pts · " + str.tostring(deeLevel25, format.mintick))
            label.set_textcolor(deeLabel25, dee_range_color)
            label.set_size(deeLabel25, dee_label_size)
    else
        if not na(deeLine25)
            line.delete(deeLine25)
            deeLine25 := na
        if not na(deeLabel25)
            label.delete(deeLabel25)
            deeLabel25 := na
    if dee_show_p50
        if na(deeLine50)
            deeLine50 := line.new(deeX1, deeLevel50, deeX2, deeLevel50, xloc=xloc.bar_time, color=dee_p50_color, width=2)
            deeLabel50 := label.new(deeX2, deeLevel50, "1D P50 · " + str.tostring(deeDistance50, "#.00") + " NQ pts · " + str.tostring(deeLevel50, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, textcolor=dee_p50_color, color=color.new(color.black, 80), size=dee_label_size)
        else
            line.set_xy1(deeLine50, deeX1, deeLevel50)
            line.set_xy2(deeLine50, deeX2, deeLevel50)
            line.set_color(deeLine50, dee_p50_color)
            label.set_xy(deeLabel50, deeX2, deeLevel50)
            label.set_text(deeLabel50, "1D P50 · " + str.tostring(deeDistance50, "#.00") + " NQ pts · " + str.tostring(deeLevel50, format.mintick))
            label.set_textcolor(deeLabel50, dee_p50_color)
            label.set_size(deeLabel50, dee_label_size)
    else
        if not na(deeLine50)
            line.delete(deeLine50)
            deeLine50 := na
        if not na(deeLabel50)
            label.delete(deeLabel50)
            deeLabel50 := na
    if dee_show_p75
        if na(deeLine75)
            deeLine75 := line.new(deeX1, deeLevel75, deeX2, deeLevel75, xloc=xloc.bar_time, color=dee_range_color, width=1)
            deeLabel75 := label.new(deeX2, deeLevel75, "1D P75 · " + str.tostring(deeDistance75, "#.00") + " NQ pts · " + str.tostring(deeLevel75, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, textcolor=dee_range_color, color=color.new(color.black, 80), size=dee_label_size)
        else
            line.set_xy1(deeLine75, deeX1, deeLevel75)
            line.set_xy2(deeLine75, deeX2, deeLevel75)
            line.set_color(deeLine75, dee_range_color)
            label.set_xy(deeLabel75, deeX2, deeLevel75)
            label.set_text(deeLabel75, "1D P75 · " + str.tostring(deeDistance75, "#.00") + " NQ pts · " + str.tostring(deeLevel75, format.mintick))
            label.set_textcolor(deeLabel75, dee_range_color)
            label.set_size(deeLabel75, dee_label_size)
    else
        if not na(deeLine75)
            line.delete(deeLine75)
            deeLine75 := na
        if not na(deeLabel75)
            label.delete(deeLabel75)
            deeLabel75 := na

var table deePanel = table.new(position.bottom_right, 2, 10, bgcolor=color.rgb(8,8,8), frame_color=color.gray, frame_width=1)
if barstate.islast
    table.clear(deePanel, 0, 0, 1, 9)
    if dee_enabled and dee_show_status
        table.cell(deePanel, 0, 0, "1D EE — RESEARCH", text_color=color.white)
        table.merge_cells(deePanel, 0, 0, 1, 0)
        table.cell(deePanel, 0, 1, "State", text_color=color.silver)
        table.cell(deePanel, 1, 1, deeStatusText, text_color=deeProjectionActive?color.aqua:color.silver)
        table.cell(deePanel, 0, 2, "Source", text_color=color.silver)
        table.cell(deePanel, 1, 2, "CME_MINI:NQ1! · SET OFF", text_color=color.white)
        table.cell(deePanel, 0, 3, "Trade date", text_color=color.silver)
        table.cell(deePanel, 1, 3, na(deeTradeDate)?"-":str.format_time(deeTradeDate, "yyyy-MM-dd", "America/Chicago"), text_color=color.white)
        table.cell(deePanel, 0, 4, "ATR state", text_color=color.silver)
        table.cell(deePanel, 1, 4, na(deeAtr20)?str.tostring(deeSeedCount)+"/20":str.tostring(deeAtr20,"#.000000"), text_color=color.white)
        table.cell(deePanel, 0, 5, "C2", text_color=color.silver)
        table.cell(deePanel, 1, 5, deeActive?(deeActiveBull?"BULL":"BEAR")+" · "+str.tostring(deeC2Close,format.mintick):"-", text_color=color.white)
        if dee_display_mode == "P25 / P50 / P75"
            table.cell(deePanel, 0, 6, "P25", text_color=color.silver)
            table.cell(deePanel, 1, 6, deeProjectionActive?str.tostring(deeDistance25,"#.00")+" pts · "+str.tostring(deeLevel25,format.mintick):"-", text_color=ee_range_color)
            table.cell(deePanel, 0, 7, "P50", text_color=color.silver)
            table.cell(deePanel, 1, 7, deeProjectionActive?str.tostring(deeDistance50,"#.00")+" pts · "+str.tostring(deeLevel50,format.mintick):"-", text_color=ee_p50_color)
            table.cell(deePanel, 0, 8, "P75", text_color=color.silver)
            table.cell(deePanel, 1, 8, deeProjectionActive?str.tostring(deeDistance75,"#.00")+" pts · "+str.tostring(deeLevel75,format.mintick):"-", text_color=ee_range_color)
        else
            table.cell(deePanel, 0, 6, "P50", text_color=color.silver)
            table.cell(deePanel, 1, 6, deeProjectionActive?str.tostring(deeDistance50,"#.00")+" pts · "+str.tostring(deeLevel50,format.mintick):"-", text_color=ee_p50_color)
        table.cell(deePanel, 0, 9, "Research status", text_color=color.silver)
        table.cell(deePanel, 1, 9, "Historically frozen with caution · Not forward validated", text_color=color.orange)

//+------------------------------------------------------------------------------------------------------------+//
//+--- ICT — New York Time Anchors                                                                          ---+//
//+------------------------------------------------------------------------------------------------------------+//
// Chart-price tools only. The explicit IANA timezone keeps calendar anchors
// independent of chart/exchange/local timezones and lets Pine apply New York DST.
string ICT_TZ = "America/New_York"





ict_line_style(string value) =>
    value == "Solid" ? line.style_solid : value == "Dashed" ? line.style_dashed : line.style_dotted

ict_label_size(string value) =>
    value == "Tiny" ? size.tiny : value == "Small" ? size.small : value == "Normal" ? size.normal : size.large

ict_delete_lines(array<line> objects) =>
    while array.size(objects) > 0
        line.delete(array.pop(objects))

ict_delete_labels(array<label> objects) =>
    while array.size(objects) > 0
        label.delete(array.pop(objects))

ict_trim_lines(array<line> objects, int keep) =>
    while array.size(objects) > keep
        line.delete(array.shift(objects))

ict_trim_labels(array<label> objects, int keep) =>
    while array.size(objects) > keep
        label.delete(array.shift(objects))

ict_delete_open_levels(array<line> lines, array<label> labels, array<int> anchor_times, array<float> anchor_prices) =>
    while array.size(lines) > 0
        line.delete(array.pop(lines))
    while array.size(labels) > 0
        label level_label = array.pop(labels)
        if not na(level_label)
            label.delete(level_label)
    array.clear(anchor_times)
    array.clear(anchor_prices)

ict_trim_open_levels(array<line> lines, array<label> labels, array<int> anchor_times, array<float> anchor_prices, int keep) =>
    while array.size(lines) > keep
        line.delete(array.shift(lines))
        label level_label = array.shift(labels)
        if not na(level_label)
            label.delete(level_label)
        array.shift(anchor_times)
        array.shift(anchor_prices)

// Rebuild every retained endpoint from stored anchor state on every execution.
// This makes the lifecycle invariant durable across replay/realtime recalculation:
// historical i spans anchor[i] -> anchor[i+1], and only the newest extends right.
ict_reconcile_open_levels(array<line> lines, array<label> labels, array<int> anchor_times, array<float> anchor_prices, color level_color, string level_style, int level_width, bool show_labels, string label_text, string label_size) =>
    int level_count = array.size(lines)
    if level_count > 0
        for level_i = 0 to level_count - 1
            line level_line = array.get(lines, level_i)
            int level_x1 = array.get(anchor_times, level_i)
            float level_price = array.get(anchor_prices, level_i)
            bool is_newest = level_i == level_count - 1
            // A right-extending ray needs two distinct points to define its
            // horizontal direction. Keep both prices equal; only X differs.
            int level_x2 = is_newest ? level_x1 + 60000 : array.get(anchor_times, level_i + 1)
            line.set_extend(level_line, is_newest ? extend.right : extend.none)
            line.set_xy1(level_line, level_x1, level_price)
            line.set_xy2(level_line, level_x2, level_price)
            // Read back the actual drawing object, not just the stored state.
            // A corrupted/crossed horizontal handle is deleted fail-closed.
            if line.get_y1(level_line) != level_price or line.get_y2(level_line) != level_price
                line.delete(level_line)
                level_line := line.new(level_x1, level_price, level_x2, level_price, xloc=xloc.bar_time, extend=is_newest ? extend.right : extend.none, color=level_color, style=ict_line_style(level_style), width=level_width)
                array.set(lines, level_i, level_line)
            line.set_color(level_line, level_color)
            line.set_style(level_line, ict_line_style(level_style))
            line.set_width(level_line, level_width)
            label level_label = array.get(labels, level_i)
            if show_labels
                int label_x = is_newest ? time_close : level_x2
                if na(level_label)
                    level_label := label.new(label_x, level_price, label_text, xloc=xloc.bar_time, style=label.style_label_left, textcolor=level_color, color=color.new(color.black, 85), size=ict_label_size(label_size))
                    array.set(labels, level_i, level_label)
                else
                    label.set_xy(level_label, label_x, level_price)
                    label.set_text(level_label, label_text)
                    label.set_textcolor(level_label, level_color)
                    label.set_size(level_label, ict_label_size(label_size))
            else if not na(level_label)
                label.delete(level_label)
                array.set(labels, level_i, na)

// Exact one-minute source for chart timeframes above one minute. An anchor is
// accepted only when the source bar START timestamp equals the New York anchor.
// Missing/shortened sessions therefore produce no price level (fail closed).
bool ict_intraday_supported = timeframe.isintraday and timeframe.in_seconds() >= 60
bool ict_chart_is_1m = timeframe.isminutes and timeframe.multiplier == 1
[ict_1m_times, ict_1m_opens] = request.security_lower_tf(syminfo.tickerid, "1", [time, open], ignore_invalid_timeframe=true)

int ict_midnight_time = na
float ict_midnight_price = na
int ict_0830_time = na
float ict_0830_price = na

if ict_intraday_supported
    if ict_chart_is_1m
        if hour(time, ICT_TZ) == 0 and minute(time, ICT_TZ) == 0
            ict_midnight_time := time
            ict_midnight_price := open
        if hour(time, ICT_TZ) == 8 and minute(time, ICT_TZ) == 30
            ict_0830_time := time
            ict_0830_price := open
    else
        int ict_intrabar_count = array.size(ict_1m_times)
        if ict_intrabar_count > 0
            for ict_i = 0 to ict_intrabar_count - 1
                int ict_source_time = array.get(ict_1m_times, ict_i)
                if hour(ict_source_time, ICT_TZ) == 0 and minute(ict_source_time, ICT_TZ) == 0
                    ict_midnight_time := ict_source_time
                    ict_midnight_price := array.get(ict_1m_opens, ict_i)
                if hour(ict_source_time, ICT_TZ) == 8 and minute(ict_source_time, ICT_TZ) == 30
                    ict_0830_time := ict_source_time
                    ict_0830_price := array.get(ict_1m_opens, ict_i)

var array<line> ict_midnight_boundaries = array.new<line>()
var array<line> ict_0830_boundaries = array.new<line>()
var array<line> ict_midnight_open_lines = array.new<line>()
var array<label> ict_midnight_open_labels = array.new<label>()
var array<int> ict_midnight_open_times = array.new<int>()
var array<float> ict_midnight_open_prices = array.new<float>()
var array<line> ict_0830_open_lines = array.new<line>()
var array<label> ict_0830_open_labels = array.new<label>()
var array<int> ict_0830_open_times = array.new<int>()
var array<float> ict_0830_open_prices = array.new<float>()
var int ict_last_midnight_boundary = na
var int ict_last_0830_boundary = na
var int ict_last_midnight_open = na
var int ict_last_0830_open = na

bool ict_midnight_exact = ict_intraday_supported and not na(ict_midnight_time) and not na(ict_midnight_price)
bool ict_0830_exact = ict_intraday_supported and not na(ict_0830_time) and not na(ict_0830_price)

if not ict_intraday_supported or not ict_show_midnight_boundary
    ict_delete_lines(ict_midnight_boundaries)
    ict_last_midnight_boundary := na
else if ict_midnight_exact and (na(ict_last_midnight_boundary) or ict_midnight_time != ict_last_midnight_boundary)
    line ict_boundary = line.new(ict_midnight_time, low, ict_midnight_time, high, xloc=xloc.bar_time, extend=extend.both, color=ict_midnight_boundary_color, style=ict_line_style(ict_midnight_boundary_style_input), width=ict_midnight_boundary_width)
    array.push(ict_midnight_boundaries, ict_boundary)
    ict_trim_lines(ict_midnight_boundaries, ict_days_to_show)
    ict_last_midnight_boundary := ict_midnight_time

if not ict_intraday_supported or not ict_show_0830_boundary
    ict_delete_lines(ict_0830_boundaries)
    ict_last_0830_boundary := na
else if ict_0830_exact and (na(ict_last_0830_boundary) or ict_0830_time != ict_last_0830_boundary)
    line ict_boundary = line.new(ict_0830_time, low, ict_0830_time, high, xloc=xloc.bar_time, extend=extend.both, color=ict_0830_boundary_color, style=ict_line_style(ict_0830_boundary_style_input), width=ict_0830_boundary_width)
    array.push(ict_0830_boundaries, ict_boundary)
    ict_trim_lines(ict_0830_boundaries, ict_days_to_show)
    ict_last_0830_boundary := ict_0830_time

if not ict_intraday_supported or not ict_show_midnight_open
    ict_delete_open_levels(ict_midnight_open_lines, ict_midnight_open_labels, ict_midnight_open_times, ict_midnight_open_prices)
    ict_last_midnight_open := na
else
    if ict_midnight_exact and (na(ict_last_midnight_open) or ict_midnight_time != ict_last_midnight_open)
        line ict_level = line.new(ict_midnight_time, ict_midnight_price, ict_midnight_time + 60000, ict_midnight_price, xloc=xloc.bar_time, extend=extend.right, color=ict_midnight_open_color, style=ict_line_style(ict_midnight_open_style_input), width=ict_midnight_open_width)
        array.push(ict_midnight_open_lines, ict_level)
        array.push(ict_midnight_open_labels, na)
        array.push(ict_midnight_open_times, ict_midnight_time)
        array.push(ict_midnight_open_prices, ict_midnight_price)
        ict_trim_open_levels(ict_midnight_open_lines, ict_midnight_open_labels, ict_midnight_open_times, ict_midnight_open_prices, ict_days_to_show)
        ict_last_midnight_open := ict_midnight_time
    ict_reconcile_open_levels(ict_midnight_open_lines, ict_midnight_open_labels, ict_midnight_open_times, ict_midnight_open_prices, ict_midnight_open_color, ict_midnight_open_style_input, ict_midnight_open_width, ict_show_midnight_open_label, "12AM NY Open", ict_midnight_open_label_size_input)

if not ict_intraday_supported or not ict_show_0830_open
    ict_delete_open_levels(ict_0830_open_lines, ict_0830_open_labels, ict_0830_open_times, ict_0830_open_prices)
    ict_last_0830_open := na
else
    if ict_0830_exact and (na(ict_last_0830_open) or ict_0830_time != ict_last_0830_open)
        line ict_level = line.new(ict_0830_time, ict_0830_price, ict_0830_time + 60000, ict_0830_price, xloc=xloc.bar_time, extend=extend.right, color=ict_0830_open_color, style=ict_line_style(ict_0830_open_style_input), width=ict_0830_open_width)
        array.push(ict_0830_open_lines, ict_level)
        array.push(ict_0830_open_labels, na)
        array.push(ict_0830_open_times, ict_0830_time)
        array.push(ict_0830_open_prices, ict_0830_price)
        ict_trim_open_levels(ict_0830_open_lines, ict_0830_open_labels, ict_0830_open_times, ict_0830_open_prices, ict_days_to_show)
        ict_last_0830_open := ict_0830_time
    ict_reconcile_open_levels(ict_0830_open_lines, ict_0830_open_labels, ict_0830_open_times, ict_0830_open_prices, ict_0830_open_color, ict_0830_open_style_input, ict_0830_open_width, ict_show_0830_open_label, "8:30 NY Open", ict_0830_open_label_size_input)
````
