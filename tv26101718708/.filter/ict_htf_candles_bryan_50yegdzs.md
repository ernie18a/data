# ICT HTF Candles (Bryan)

- url: https://www.tradingview.com/script/50YEgDzS-ICT-HTF-Candles-Bryan/
- type: indicator
- pine_id: PUB;9b2fe9c25ad242eaaaf0f5d4146a0660
- version: 3.0

## Description

Added PSP, SMT, and HTF candle Sweep on top of ICT HTF Candles (fadi)

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fadizeidan

// Original script: "ICT HTF Candles (fadi)" by fadizeidan
// https://www.tradingview.com/script/CfqnRBHd-ICT-HTF-Candles-fadi/
// This version adds a PSP (Precision Swing Point / Crack in Correlation) module by Bryan,
// built on top of fadizeidan's original HTF candle engine. Original license and copyright preserved above.

// Prev Published: 1046
// Curr Published: 1047
//@version=6
// max_bars_back REVERTED back to 5000 (was briefly reduced to 2 as a theoretical memory
// optimization, since this script's own code never uses the [] history-referencing operator).
// That reduction turned out to cause a real regression: memory-limit errors during bar replay
// specifically when the chart's own timeframe is 4H or higher, and apparently more often when
// NQ is one of the correlated symbols. The exact internal mechanism isn't something that can
// be fully confirmed without running it in TradingView, but it's most likely related to how
// request.security() backfills a higher-timeframe reference symbol's history relative to the
// chart's own timeframe and Pine's internal buffer-size auto-adjustment, which behaves
// differently in replay mode than in normal real-time/historical execution. Rather than keep
// guessing at the precise mechanism, this reverts to the one isolated change that is known to
// separate a confirmed-working version from a confirmed-failing one: max_bars_back = 5000.
indicator('ICT HTF Candles (Bryan)', overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

type Candle
	float o
	float c
	float h
	float l
    int o_time
    string dow
	box body
	line wick_up
	line wick_down
    label dow_label
    line sweep_high_line
    line sweep_low_line
    line smt_high_line
    line smt_low_line
    label smt_label
    // SMT (v2): store each correlated symbol's REAL high/low for this HTF bar, snapshotted
    // at candle creation and refreshed while the candle is live. Using real high/low (instead
    // of an open/close bull/bear-flip proxy) lets SMT divergence be tested the same way ICT
    // actually defines it: "did this leg make a new swing high/low or not", regardless of
    // whether its candle body happened to flip color. This fixes false negatives where a
    // symbol kept the same candle color across two bars while still printing a fresh
    // high/low (the flip-based proxy would otherwise miss it entirely).
    float smt_h1
    float smt_l1
    float smt_h2
    float smt_l2
    float smt_h3
    float smt_l3
    bool smt_use1
    bool smt_use2
    bool smt_use3
    // FIX: SMT previously had no equivalent of PSP's t==candleTime guard, so a reference
    // symbol's high/low could be compared even when its own HTF bar hadn't actually rolled
    // over to the same period as the candle being evaluated (or had already rolled to the
    // NEXT period while the chart's hadn't). That stale/desynced comparison is what produced
    // SMT divergence readings that didn't match what the reference symbol's own chart would
    // show for the identical pair of candles. smt_valid1/2/3 records, at snapshot time,
    // whether each reference symbol's bar time exactly matched this candle's own bar time —
    // only valid snapshots are used in the divergence comparison.
    bool smt_valid1
    bool smt_valid2
    bool smt_valid3

type Imbalance
	box b
	int idx

type CandleSettings
	bool show
	string htf
	int max_display
	float sym1_o
	float sym1_c
	float sym1_h
	float sym1_l
	int   sym1_t
	float sym2_o
	float sym2_c
	float sym2_h
	float sym2_l
	int   sym2_t
	float sym3_o
	float sym3_c
	float sym3_h
	float sym3_l
	int   sym3_t
	float sym4_o
	float sym4_c
	int   sym4_t

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
    bool show_time
    color time_color
    string time_size
    bool psp_show
    bool psp_sym1_use
    string psp_sym1
    bool psp_sym2_use
    string psp_sym2
    bool psp_sym3_use
    string psp_sym3
    bool psp_sym4_use
    string psp_sym4
    color psp_up_body
    color psp_down_body
    color psp_up_border
    color psp_down_border
    color psp_up_wick
    color psp_down_wick
    // Sweep visualization
    bool sweep_show
    color sweep_color                // FIX (issue 2): user-selectable sweep line color
    // SMT Divergence
    bool smt_show
    color smt_color                  // FIX (issue 2): user-selectable SMT line color
    bool smt_label_show              // FIX (issue 2): toggle for showing ticker text on SMT label
    bool smt_show_sym1               // FIX (issue 2): per-symbol name visibility on the label
    bool smt_show_sym2
    bool smt_show_sym3
    // Separator (ported from reference script): a full vertical line drawn on the underlying
    // chart itself (not the synthetic HTF candle group) each time a chosen HTF rolls to a new
    // bar, marking that HTF's open on the real chart.
    bool show_sep
    color sep_color
    string sep_style
    int sep_width
    string sep_tf

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
var CandleSettings SettingsHTF7 = CandleSettings.new()

var array<Candle> candles_1 = array.new<Candle>(0)
var array<Candle> candles_2 = array.new<Candle>(0)
var array<Candle> candles_3 = array.new<Candle>(0)
var array<Candle> candles_4 = array.new<Candle>(0)
var array<Candle> candles_5 = array.new<Candle>(0)
var array<Candle> candles_6 = array.new<Candle>(0)
var array<Candle> candles_7 = array.new<Candle>(0)

var array<Imbalance> imbalances_1 = array.new<Imbalance>()
var array<Imbalance> imbalances_2 = array.new<Imbalance>()
var array<Imbalance> imbalances_3 = array.new<Imbalance>()
var array<Imbalance> imbalances_4 = array.new<Imbalance>()
var array<Imbalance> imbalances_5 = array.new<Imbalance>()
var array<Imbalance> imbalances_6 = array.new<Imbalance>()
var array<Imbalance> imbalances_7 = array.new<Imbalance>()

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

var CandleSet htf7 = CandleSet.new()
htf7.settings := SettingsHTF7
htf7.candles := candles_7
htf7.imbalances := imbalances_7

//+------------------------------------------------------------------------------------------------------------+//
//+--- Settings                                                                                             ---+//
//+------------------------------------------------------------------------------------------------------------+//

string group_style              = "Styling  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_label              = "Label Settings  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_imbalance          = "Imbalance  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_psp                = "PSP - Crack in Correlation  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_sweep              = "HTF Sweep  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_smt                = "HTF SMT Divergence  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
string group_separator          = "Separator  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

htf1.settings.show              := input.bool(true, 'HTF 1      ', inline = 'htf1')
htf_1                           = input.timeframe('15', '', inline = 'htf1')
htf1.settings.htf := htf_1
htf1.settings.max_display       := input.int(10, '', inline = 'htf1')

htf2.settings.show              := input.bool(true, 'HTF 2      ', inline = 'htf2')
htf_2                           = input.timeframe('30', '', inline = 'htf2')
htf2.settings.htf := htf_2
htf2.settings.max_display       := input.int(10, '', inline = 'htf2')

htf3.settings.show              := input.bool(true, 'HTF 3      ', inline = 'htf3')
htf_3                           = input.timeframe('60', '', inline = 'htf3')
htf3.settings.htf := htf_3
htf3.settings.max_display       := input.int(10, '', inline = 'htf3')

htf4.settings.show              := input.bool(true, 'HTF 4      ', inline = 'htf4')
htf_4                           = input.timeframe('90', '', inline = 'htf4')
htf4.settings.htf               := htf_4
htf4.settings.max_display       := input.int(10, '', inline = 'htf4')

htf5.settings.show              := input.bool(true, 'HTF 5      ', inline = 'htf5')
htf_5                           = input.timeframe('240', '', inline = 'htf5')
htf5.settings.htf := htf_5
htf5.settings.max_display       := input.int(10, '', inline = 'htf5')

htf6.settings.show              := input.bool(true, 'HTF 6      ', inline = 'htf6')
htf_6                           = input.timeframe('360', '', inline = 'htf6')
htf6.settings.htf               := htf_6
htf6.settings.max_display       := input.int(10, '', inline = 'htf6')

htf7.settings.show              := input.bool(true, 'HTF 7      ', inline = 'htf7')
htf_7                           = input.timeframe('1D', '', inline = 'htf7')
htf7.settings.htf               := htf_7
htf7.settings.max_display       := input.int(10, '', inline = 'htf7')

settings.max_sets               := input.int(7, 'Limit to next HTFs only', minval = 1, maxval = 7)
settings.bull_body              := input.color(#ffffff, 'Body  ', inline = 'body', group=group_style)
settings.bear_body              := input.color(#000000, '', inline = 'body', group=group_style)
settings.bull_border            := input.color(#000000, 'Borders', inline = 'borders', group=group_style)
settings.bear_border            := input.color(#000000, '', inline = 'borders', group=group_style)
settings.bull_wick              := input.color(#000000, 'Wick  ', inline = 'wick', group=group_style)
settings.bear_wick              := input.color(#000000, '', inline = 'wick', group=group_style)

settings.offset                 := input.int(10, 'padding from current candles', minval = 1, group=group_style)
settings.buffer                 := input.int(1, 'space between candles', minval = 1, maxval = 4, group=group_style)
settings.htf_buffer             := input.int(5, 'space between Higher Timeframes', minval = 1, maxval = 10, group=group_style)
settings.width                  := input.int(1, 'Candle Width', minval = 1, maxval = 4, group=group_style) * 2

settings.htf_label_show         := input.bool(true, 'HTF Label           ', group=group_label, inline = 'HTFlabel')
settings.htf_label_color        := input.color(color.black, '', group=group_label, inline = 'HTFlabel')
settings.htf_label_size         := input.string(size.large, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'HTFlabel')

settings.label_position         := input.string("Top", 'Label Positions', options=['Both', 'Top', 'Bottom'], group=group_label)
settings.label_alignment        := input.string("Follow Candles", "Label Alignment", options=['Align', 'Follow Candles'], group=group_label)

settings.htf_timer_show         := input.bool(true, 'Remaining time      ', inline = 'timer', group=group_label)
settings.htf_timer_color        := input.color(color.black, '', inline = 'timer', group=group_label)
settings.htf_timer_size         := input.string(size.normal, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'timer')

settings.show_time              := input.bool(true, 'Candle Open Time      ', group=group_label, inline = 'dow')
settings.time_color             := input.color(color.black , '', group=group_label, inline = 'dow')
settings.time_size              := input.string(size.tiny, '', [size.tiny, size.small, size.normal, size.large, size.huge], group=group_label, inline = 'dow')

settings.fvg_show               := input.bool(true, 'Fair Value Gap   ', group = group_imbalance, inline = 'fvg')
settings.fvg_color              := input.color(color.new(color.gray, 80), '', inline = 'fvg', group = group_imbalance)

settings.vi_show                := input.bool(true, 'Volume Imbalance', group = group_imbalance, inline = 'vi')
settings.vi_color               := input.color(color.new(color.red, 50), '', inline = 'vi', group = group_imbalance)

settings.psp_show               := input.bool(true, 'Enable PSP Highlight', group = group_psp)

settings.psp_sym1_use           := input.bool(true, '', inline = 'pspsym1', group = group_psp)
settings.psp_sym1               := input.symbol('CME_MINI:NQ1!', 'Ticker 1', inline = 'pspsym1', group = group_psp)

settings.psp_sym2_use           := input.bool(true, '', inline = 'pspsym2', group = group_psp)
settings.psp_sym2               := input.symbol('CBOT:YM1!', 'Ticker 2', inline = 'pspsym2', group = group_psp)

settings.psp_sym3_use           := input.bool(true, '', inline = 'pspsym3', group = group_psp)
settings.psp_sym3               := input.symbol('CME_MINI:ES1!', 'Ticker 3', inline = 'pspsym3', group = group_psp)

settings.psp_sym4_use           := input.bool(false, '', inline = 'pspsym4', group = group_psp)
settings.psp_sym4               := input.symbol('CME_MINI:RTY1!', 'Ticker 4', inline = 'pspsym4', group = group_psp)

settings.psp_up_body            := input.color(#e2fcff, 'Body    ', inline = 'pspbody', group = group_psp)
settings.psp_down_body          := input.color(#ffe0e1, '', inline = 'pspbody', group = group_psp)
settings.psp_up_border          := input.color(#3179f5, 'Border  ', inline = 'pspborder', group = group_psp)
settings.psp_down_border        := input.color(#3179f5, '', inline = 'pspborder', group = group_psp)
settings.psp_up_wick            := input.color(#3179f5, 'Wick    ', inline = 'pspwick', group = group_psp)
settings.psp_down_wick          := input.color(#3179f5, '', inline = 'pspwick', group = group_psp)

// ── HTF Sweep Settings ──────────────────────────────────────────────────────
settings.sweep_show             := input.bool(true, 'Show HTF Sweep Marks', inline = 'sweep', group = group_sweep)
settings.sweep_color            := input.color(#9c9c9c, '', inline = 'sweep', group = group_sweep)   // FIX (issue 2)

// ── HTF SMT Divergence Settings ─────────────────────────────────────────────
// SMT auto-uses the PSP correlated symbols — no separate symbol picker needed.
settings.smt_show               := input.bool(true, 'Show SMT Divergence Lines', inline = 'smt', group = group_smt)
settings.smt_color              := input.color(#f23645, '', inline = 'smt', group = group_smt)         // FIX (issue 2)
settings.smt_label_show         := input.bool(false, 'Show Ticker Names on SMT Label', group = group_smt) // FIX (issue 2)
settings.smt_show_sym1          := input.bool(true, 'Show Ticker 1 name in label', inline = 'smtsym1', group = group_smt) // FIX (issue 2)
settings.smt_show_sym2          := input.bool(true, 'Show Ticker 2 name in label', inline = 'smtsym2', group = group_smt) // FIX (issue 2)
settings.smt_show_sym3          := input.bool(true, 'Show Ticker 3 name in label', inline = 'smtsym3', group = group_smt) // FIX (issue 2)

// ── Separator Settings (ported from reference script) ──────────────────────
settings.show_sep               := input.bool(false, "Show Separator", group=group_separator)
settings.sep_color              := input.color(color.gray, 'Separator Color', group=group_separator)
settings.sep_style              := input.string("Dotted", "Separator Style", options=["Solid", "Dashed", "Dotted"], group=group_separator)
settings.sep_width              := input.int(1, "Separator Width", minval=1, group=group_separator)
settings.sep_tf                 := input.timeframe("30", "Timeframe To Use", group = group_separator)

//+------------------------------------------------------------------------------------------------------------+//
//+--- PSP Correlated Symbol Data (per HTF)                                                                 ---+//
//+------------------------------------------------------------------------------------------------------------+//
// NOTE (fix): we now also pull each reference symbol's own HTF bar `time`. This lets us
// verify, at comparison time, that a reference symbol has actually rolled over to the SAME
// HTF period as the active candle before treating it as "diverging". Without this guard,
// a reference symbol that briefly lags its own HTF rollover (very common right at an HTF
// boundary across different futures contracts) gets compared using stale prior-period data,
// which is what was causing false PSP highlights on the most recent / forming candle.

// FIX (memory limit on 4H+ chart timeframes): request.security() is documented as expensive
// when the requested timeframe is LOWER than the chart's own timeframe -- Pine must fetch and
// buffer multiple intrabars per chart bar to reconstruct the finer series, and that cost is
// paid for every bar of the chart's dataset. With 7 HTF slots starting as low as 15m, viewing
// the indicator on a 4H+ chart put 4 of the 7 slots (15m/30m/1H/90m) below the chart's own
// timeframe, multiplying that expensive fetch across 4 symbols x 5 fields each x 4 slots --
// exactly the kind of "data for each bar is copied and stored in memory" cost the Pine docs
// warn causes "Memory limits exceeded". Those slots are already treated as invalid and never
// displayed by ValidTimeframe() further down in the script, so fetching their data at all was
// pure waste in that case. effectiveHtf1 requests htf1's own configured timeframe normally,
// but falls back to the CHART's own current timeframe (timeframe.period) whenever htf1 is
// not strictly higher than the chart -- a cheap, same-or-equal-timeframe request -- instead of
// ever requesting a genuinely lower timeframe. Since ValidTimeframe() independently discards
// this slot in that exact situation, whatever (now cheap) data gets fetched here is never used
// downstream, so this has no effect on any setting, display, or detected PSP/SMT result.
string effectiveHtf1 = timeframe.in_seconds(htf1.settings.htf) > timeframe.in_seconds() ? htf1.settings.htf : timeframe.period

[sym1_o_1, sym1_c_1, sym1_h_1, sym1_l_1, sym1_t_1] = request.security(settings.psp_sym1, effectiveHtf1, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym2_o_1, sym2_c_1, sym2_h_1, sym2_l_1, sym2_t_1] = request.security(settings.psp_sym2, effectiveHtf1, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym3_o_1, sym3_c_1, sym3_h_1, sym3_l_1, sym3_t_1] = request.security(settings.psp_sym3, effectiveHtf1, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym4_o_1, sym4_c_1, sym4_t_1] = request.security(settings.psp_sym4, effectiveHtf1, [open, close, time], lookahead = barmerge.lookahead_off)
htf1.settings.sym1_o := sym1_o_1
htf1.settings.sym1_c := sym1_c_1
htf1.settings.sym1_h := sym1_h_1
htf1.settings.sym1_l := sym1_l_1
htf1.settings.sym1_t := sym1_t_1
htf1.settings.sym2_o := sym2_o_1
htf1.settings.sym2_c := sym2_c_1
htf1.settings.sym2_h := sym2_h_1
htf1.settings.sym2_l := sym2_l_1
htf1.settings.sym2_t := sym2_t_1
htf1.settings.sym3_o := sym3_o_1
htf1.settings.sym3_c := sym3_c_1
htf1.settings.sym3_h := sym3_h_1
htf1.settings.sym3_l := sym3_l_1
htf1.settings.sym3_t := sym3_t_1
htf1.settings.sym4_o := sym4_o_1
htf1.settings.sym4_c := sym4_c_1
htf1.settings.sym4_t := sym4_t_1

// FIX (memory limit on 4H+ chart timeframes): request.security() is documented as expensive
// when the requested timeframe is LOWER than the chart's own timeframe -- Pine must fetch and
// buffer multiple intrabars per chart bar to reconstruct the finer series, and that cost is
// paid for every bar of the chart's dataset. With 7 HTF slots starting as low as 15m, viewing
// the indicator on a 4H+ chart put 4 of the 7 slots (15m/30m/1H/90m) below the chart's own
// timeframe, multiplying that expensive fetch across 4 symbols x 5 fields each x 4 slots --
// exactly the kind of "data for each bar is copied and stored in memory" cost the Pine docs
// warn causes "Memory limits exceeded". Those slots are already treated as invalid and never
// displayed by ValidTimeframe() further down in the script, so fetching their data at all was
// pure waste in that case. effectiveHtf2 requests htf2's own configured timeframe normally,
// but falls back to the CHART's own current timeframe (timeframe.period) whenever htf2 is
// not strictly higher than the chart -- a cheap, same-or-equal-timeframe request -- instead of
// ever requesting a genuinely lower timeframe. Since ValidTimeframe() independently discards
// this slot in that exact situation, whatever (now cheap) data gets fetched here is never used
// downstream, so this has no effect on any setting, display, or detected PSP/SMT result.
string effectiveHtf2 = timeframe.in_seconds(htf2.settings.htf) > timeframe.in_seconds() ? htf2.settings.htf : timeframe.period

[sym1_o_2, sym1_c_2, sym1_h_2, sym1_l_2, sym1_t_2] = request.security(settings.psp_sym1, effectiveHtf2, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym2_o_2, sym2_c_2, sym2_h_2, sym2_l_2, sym2_t_2] = request.security(settings.psp_sym2, effectiveHtf2, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym3_o_2, sym3_c_2, sym3_h_2, sym3_l_2, sym3_t_2] = request.security(settings.psp_sym3, effectiveHtf2, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym4_o_2, sym4_c_2, sym4_t_2] = request.security(settings.psp_sym4, effectiveHtf2, [open, close, time], lookahead = barmerge.lookahead_off)
htf2.settings.sym1_o := sym1_o_2
htf2.settings.sym1_c := sym1_c_2
htf2.settings.sym1_h := sym1_h_2
htf2.settings.sym1_l := sym1_l_2
htf2.settings.sym1_t := sym1_t_2
htf2.settings.sym2_o := sym2_o_2
htf2.settings.sym2_c := sym2_c_2
htf2.settings.sym2_h := sym2_h_2
htf2.settings.sym2_l := sym2_l_2
htf2.settings.sym2_t := sym2_t_2
htf2.settings.sym3_o := sym3_o_2
htf2.settings.sym3_c := sym3_c_2
htf2.settings.sym3_h := sym3_h_2
htf2.settings.sym3_l := sym3_l_2
htf2.settings.sym3_t := sym3_t_2
htf2.settings.sym4_o := sym4_o_2
htf2.settings.sym4_c := sym4_c_2
htf2.settings.sym4_t := sym4_t_2

// FIX (memory limit on 4H+ chart timeframes): request.security() is documented as expensive
// when the requested timeframe is LOWER than the chart's own timeframe -- Pine must fetch and
// buffer multiple intrabars per chart bar to reconstruct the finer series, and that cost is
// paid for every bar of the chart's dataset. With 7 HTF slots starting as low as 15m, viewing
// the indicator on a 4H+ chart put 4 of the 7 slots (15m/30m/1H/90m) below the chart's own
// timeframe, multiplying that expensive fetch across 4 symbols x 5 fields each x 4 slots --
// exactly the kind of "data for each bar is copied and stored in memory" cost the Pine docs
// warn causes "Memory limits exceeded". Those slots are already treated as invalid and never
// displayed by ValidTimeframe() further down in the script, so fetching their data at all was
// pure waste in that case. effectiveHtf3 requests htf3's own configured timeframe normally,
// but falls back to the CHART's own current timeframe (timeframe.period) whenever htf3 is
// not strictly higher than the chart -- a cheap, same-or-equal-timeframe request -- instead of
// ever requesting a genuinely lower timeframe. Since ValidTimeframe() independently discards
// this slot in that exact situation, whatever (now cheap) data gets fetched here is never used
// downstream, so this has no effect on any setting, display, or detected PSP/SMT result.
string effectiveHtf3 = timeframe.in_seconds(htf3.settings.htf) > timeframe.in_seconds() ? htf3.settings.htf : timeframe.period

[sym1_o_3, sym1_c_3, sym1_h_3, sym1_l_3, sym1_t_3] = request.security(settings.psp_sym1, effectiveHtf3, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym2_o_3, sym2_c_3, sym2_h_3, sym2_l_3, sym2_t_3] = request.security(settings.psp_sym2, effectiveHtf3, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym3_o_3, sym3_c_3, sym3_h_3, sym3_l_3, sym3_t_3] = request.security(settings.psp_sym3, effectiveHtf3, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym4_o_3, sym4_c_3, sym4_t_3] = request.security(settings.psp_sym4, effectiveHtf3, [open, close, time], lookahead = barmerge.lookahead_off)
htf3.settings.sym1_o := sym1_o_3
htf3.settings.sym1_c := sym1_c_3
htf3.settings.sym1_h := sym1_h_3
htf3.settings.sym1_l := sym1_l_3
htf3.settings.sym1_t := sym1_t_3
htf3.settings.sym2_o := sym2_o_3
htf3.settings.sym2_c := sym2_c_3
htf3.settings.sym2_h := sym2_h_3
htf3.settings.sym2_l := sym2_l_3
htf3.settings.sym2_t := sym2_t_3
htf3.settings.sym3_o := sym3_o_3
htf3.settings.sym3_c := sym3_c_3
htf3.settings.sym3_h := sym3_h_3
htf3.settings.sym3_l := sym3_l_3
htf3.settings.sym3_t := sym3_t_3
htf3.settings.sym4_o := sym4_o_3
htf3.settings.sym4_c := sym4_c_3
htf3.settings.sym4_t := sym4_t_3

// FIX (memory limit on 4H+ chart timeframes): request.security() is documented as expensive
// when the requested timeframe is LOWER than the chart's own timeframe -- Pine must fetch and
// buffer multiple intrabars per chart bar to reconstruct the finer series, and that cost is
// paid for every bar of the chart's dataset. With 7 HTF slots starting as low as 15m, viewing
// the indicator on a 4H+ chart put 4 of the 7 slots (15m/30m/1H/90m) below the chart's own
// timeframe, multiplying that expensive fetch across 4 symbols x 5 fields each x 4 slots --
// exactly the kind of "data for each bar is copied and stored in memory" cost the Pine docs
// warn causes "Memory limits exceeded". Those slots are already treated as invalid and never
// displayed by ValidTimeframe() further down in the script, so fetching their data at all was
// pure waste in that case. effectiveHtf4 requests htf4's own configured timeframe normally,
// but falls back to the CHART's own current timeframe (timeframe.period) whenever htf4 is
// not strictly higher than the chart -- a cheap, same-or-equal-timeframe request -- instead of
// ever requesting a genuinely lower timeframe. Since ValidTimeframe() independently discards
// this slot in that exact situation, whatever (now cheap) data gets fetched here is never used
// downstream, so this has no effect on any setting, display, or detected PSP/SMT result.
string effectiveHtf4 = timeframe.in_seconds(htf4.settings.htf) > timeframe.in_seconds() ? htf4.settings.htf : timeframe.period

[sym1_o_4, sym1_c_4, sym1_h_4, sym1_l_4, sym1_t_4] = request.security(settings.psp_sym1, effectiveHtf4, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym2_o_4, sym2_c_4, sym2_h_4, sym2_l_4, sym2_t_4] = request.security(settings.psp_sym2, effectiveHtf4, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym3_o_4, sym3_c_4, sym3_h_4, sym3_l_4, sym3_t_4] = request.security(settings.psp_sym3, effectiveHtf4, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym4_o_4, sym4_c_4, sym4_t_4] = request.security(settings.psp_sym4, effectiveHtf4, [open, close, time], lookahead = barmerge.lookahead_off)
htf4.settings.sym1_o := sym1_o_4
htf4.settings.sym1_c := sym1_c_4
htf4.settings.sym1_h := sym1_h_4
htf4.settings.sym1_l := sym1_l_4
htf4.settings.sym1_t := sym1_t_4
htf4.settings.sym2_o := sym2_o_4
htf4.settings.sym2_c := sym2_c_4
htf4.settings.sym2_h := sym2_h_4
htf4.settings.sym2_l := sym2_l_4
htf4.settings.sym2_t := sym2_t_4
htf4.settings.sym3_o := sym3_o_4
htf4.settings.sym3_c := sym3_c_4
htf4.settings.sym3_h := sym3_h_4
htf4.settings.sym3_l := sym3_l_4
htf4.settings.sym3_t := sym3_t_4
htf4.settings.sym4_o := sym4_o_4
htf4.settings.sym4_c := sym4_c_4
htf4.settings.sym4_t := sym4_t_4

// FIX (memory limit on 4H+ chart timeframes): request.security() is documented as expensive
// when the requested timeframe is LOWER than the chart's own timeframe -- Pine must fetch and
// buffer multiple intrabars per chart bar to reconstruct the finer series, and that cost is
// paid for every bar of the chart's dataset. With 7 HTF slots starting as low as 15m, viewing
// the indicator on a 4H+ chart put 4 of the 7 slots (15m/30m/1H/90m) below the chart's own
// timeframe, multiplying that expensive fetch across 4 symbols x 5 fields each x 4 slots --
// exactly the kind of "data for each bar is copied and stored in memory" cost the Pine docs
// warn causes "Memory limits exceeded". Those slots are already treated as invalid and never
// displayed by ValidTimeframe() further down in the script, so fetching their data at all was
// pure waste in that case. effectiveHtf5 requests htf5's own configured timeframe normally,
// but falls back to the CHART's own current timeframe (timeframe.period) whenever htf5 is
// not strictly higher than the chart -- a cheap, same-or-equal-timeframe request -- instead of
// ever requesting a genuinely lower timeframe. Since ValidTimeframe() independently discards
// this slot in that exact situation, whatever (now cheap) data gets fetched here is never used
// downstream, so this has no effect on any setting, display, or detected PSP/SMT result.
string effectiveHtf5 = timeframe.in_seconds(htf5.settings.htf) > timeframe.in_seconds() ? htf5.settings.htf : timeframe.period

[sym1_o_5, sym1_c_5, sym1_h_5, sym1_l_5, sym1_t_5] = request.security(settings.psp_sym1, effectiveHtf5, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym2_o_5, sym2_c_5, sym2_h_5, sym2_l_5, sym2_t_5] = request.security(settings.psp_sym2, effectiveHtf5, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym3_o_5, sym3_c_5, sym3_h_5, sym3_l_5, sym3_t_5] = request.security(settings.psp_sym3, effectiveHtf5, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym4_o_5, sym4_c_5, sym4_t_5] = request.security(settings.psp_sym4, effectiveHtf5, [open, close, time], lookahead = barmerge.lookahead_off)
htf5.settings.sym1_o := sym1_o_5
htf5.settings.sym1_c := sym1_c_5
htf5.settings.sym1_h := sym1_h_5
htf5.settings.sym1_l := sym1_l_5
htf5.settings.sym1_t := sym1_t_5
htf5.settings.sym2_o := sym2_o_5
htf5.settings.sym2_c := sym2_c_5
htf5.settings.sym2_h := sym2_h_5
htf5.settings.sym2_l := sym2_l_5
htf5.settings.sym2_t := sym2_t_5
htf5.settings.sym3_o := sym3_o_5
htf5.settings.sym3_c := sym3_c_5
htf5.settings.sym3_h := sym3_h_5
htf5.settings.sym3_l := sym3_l_5
htf5.settings.sym3_t := sym3_t_5
htf5.settings.sym4_o := sym4_o_5
htf5.settings.sym4_c := sym4_c_5
htf5.settings.sym4_t := sym4_t_5

// FIX (memory limit on 4H+ chart timeframes): request.security() is documented as expensive
// when the requested timeframe is LOWER than the chart's own timeframe -- Pine must fetch and
// buffer multiple intrabars per chart bar to reconstruct the finer series, and that cost is
// paid for every bar of the chart's dataset. With 7 HTF slots starting as low as 15m, viewing
// the indicator on a 4H+ chart put 4 of the 7 slots (15m/30m/1H/90m) below the chart's own
// timeframe, multiplying that expensive fetch across 4 symbols x 5 fields each x 4 slots --
// exactly the kind of "data for each bar is copied and stored in memory" cost the Pine docs
// warn causes "Memory limits exceeded". Those slots are already treated as invalid and never
// displayed by ValidTimeframe() further down in the script, so fetching their data at all was
// pure waste in that case. effectiveHtf6 requests htf6's own configured timeframe normally,
// but falls back to the CHART's own current timeframe (timeframe.period) whenever htf6 is
// not strictly higher than the chart -- a cheap, same-or-equal-timeframe request -- instead of
// ever requesting a genuinely lower timeframe. Since ValidTimeframe() independently discards
// this slot in that exact situation, whatever (now cheap) data gets fetched here is never used
// downstream, so this has no effect on any setting, display, or detected PSP/SMT result.
string effectiveHtf6 = timeframe.in_seconds(htf6.settings.htf) > timeframe.in_seconds() ? htf6.settings.htf : timeframe.period

[sym1_o_6, sym1_c_6, sym1_h_6, sym1_l_6, sym1_t_6] = request.security(settings.psp_sym1, effectiveHtf6, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym2_o_6, sym2_c_6, sym2_h_6, sym2_l_6, sym2_t_6] = request.security(settings.psp_sym2, effectiveHtf6, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym3_o_6, sym3_c_6, sym3_h_6, sym3_l_6, sym3_t_6] = request.security(settings.psp_sym3, effectiveHtf6, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym4_o_6, sym4_c_6, sym4_t_6] = request.security(settings.psp_sym4, effectiveHtf6, [open, close, time], lookahead = barmerge.lookahead_off)
htf6.settings.sym1_o := sym1_o_6
htf6.settings.sym1_c := sym1_c_6
htf6.settings.sym1_h := sym1_h_6
htf6.settings.sym1_l := sym1_l_6
htf6.settings.sym1_t := sym1_t_6
htf6.settings.sym2_o := sym2_o_6
htf6.settings.sym2_c := sym2_c_6
htf6.settings.sym2_h := sym2_h_6
htf6.settings.sym2_l := sym2_l_6
htf6.settings.sym2_t := sym2_t_6
htf6.settings.sym3_o := sym3_o_6
htf6.settings.sym3_c := sym3_c_6
htf6.settings.sym3_h := sym3_h_6
htf6.settings.sym3_l := sym3_l_6
htf6.settings.sym3_t := sym3_t_6
htf6.settings.sym4_o := sym4_o_6
htf6.settings.sym4_c := sym4_c_6
htf6.settings.sym4_t := sym4_t_6

// FIX (memory limit on 4H+ chart timeframes): request.security() is documented as expensive
// when the requested timeframe is LOWER than the chart's own timeframe -- Pine must fetch and
// buffer multiple intrabars per chart bar to reconstruct the finer series, and that cost is
// paid for every bar of the chart's dataset. With 7 HTF slots starting as low as 15m, viewing
// the indicator on a 4H+ chart put 4 of the 7 slots (15m/30m/1H/90m) below the chart's own
// timeframe, multiplying that expensive fetch across 4 symbols x 5 fields each x 4 slots --
// exactly the kind of "data for each bar is copied and stored in memory" cost the Pine docs
// warn causes "Memory limits exceeded". Those slots are already treated as invalid and never
// displayed by ValidTimeframe() further down in the script, so fetching their data at all was
// pure waste in that case. effectiveHtf7 requests htf7's own configured timeframe normally,
// but falls back to the CHART's own current timeframe (timeframe.period) whenever htf7 is
// not strictly higher than the chart -- a cheap, same-or-equal-timeframe request -- instead of
// ever requesting a genuinely lower timeframe. Since ValidTimeframe() independently discards
// this slot in that exact situation, whatever (now cheap) data gets fetched here is never used
// downstream, so this has no effect on any setting, display, or detected PSP/SMT result.
string effectiveHtf7 = timeframe.in_seconds(htf7.settings.htf) > timeframe.in_seconds() ? htf7.settings.htf : timeframe.period

[sym1_o_7, sym1_c_7, sym1_h_7, sym1_l_7, sym1_t_7] = request.security(settings.psp_sym1, effectiveHtf7, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym2_o_7, sym2_c_7, sym2_h_7, sym2_l_7, sym2_t_7] = request.security(settings.psp_sym2, effectiveHtf7, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym3_o_7, sym3_c_7, sym3_h_7, sym3_l_7, sym3_t_7] = request.security(settings.psp_sym3, effectiveHtf7, [open, close, high, low, time], lookahead = barmerge.lookahead_off)
[sym4_o_7, sym4_c_7, sym4_t_7] = request.security(settings.psp_sym4, effectiveHtf7, [open, close, time], lookahead = barmerge.lookahead_off)
htf7.settings.sym1_o := sym1_o_7
htf7.settings.sym1_c := sym1_c_7
htf7.settings.sym1_h := sym1_h_7
htf7.settings.sym1_l := sym1_l_7
htf7.settings.sym1_t := sym1_t_7
htf7.settings.sym2_o := sym2_o_7
htf7.settings.sym2_c := sym2_c_7
htf7.settings.sym2_h := sym2_h_7
htf7.settings.sym2_l := sym2_l_7
htf7.settings.sym2_t := sym2_t_7
htf7.settings.sym3_o := sym3_o_7
htf7.settings.sym3_c := sym3_c_7
htf7.settings.sym3_h := sym3_h_7
htf7.settings.sym3_l := sym3_l_7
htf7.settings.sym3_t := sym3_t_7
htf7.settings.sym4_o := sym4_o_7
htf7.settings.sym4_c := sym4_c_7
htf7.settings.sym4_t := sym4_t_7

//+------------------------------------------------------------------------------------------------------------+//
//+--- SMT uses PSP symbol data already fetched above — zero extra security calls                          ---+//
//+------------------------------------------------------------------------------------------------------------+//
// SMT divergence is detected by reusing the PSP sym1/sym2/sym3 open+close data already loaded.
// Direction per candle: bull = (close > open), bear = (close < open).
//
// FIX (issue 1 — cross-chart symmetry): previously the "did a new extreme happen" test used
// the literal high/low of whichever symbol the indicator happened to be loaded on (the chart),
// while the three reference symbols were only tested using a looser bull/bear flip. That meant
// the chart symbol was held to a stricter standard than the references, so the very same
// divergence event could show up on NQ's chart but not on YM's chart (or vice-versa) purely
// because of which one happened to be "the chart" that session. The chart is now treated as a
// 4th leg using the exact same bull/bear-flip test as sym1/2/3, so the same underlying event
// produces a matching SMT marker regardless of which of the four instruments you're charting.

//+------------------------------------------------------------------------------------------------------------+//
//+--- Variables                                                                                            ---+//
//+------------------------------------------------------------------------------------------------------------+//

Helper helper = Helper.new()
color color_transparent = #ffffff00
var array<line> separators = array.new_line(0)

//+------------------------------------------------------------------------------------------------------------+//
//+--- Internal Functions                                                                                   ---+//
//+------------------------------------------------------------------------------------------------------------+//

// Re-added solely for the separator feature (ported from reference script), which needs a
// Solid/Dashed/Dotted line-style picker. Scoped to just those three options.
method LineStyle(Helper helper, string style) =>
    helper.name := style
    out = switch style
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
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
        n3 = n1 % n2
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

// FIX (issue 3): collapse any futures ticker variant (NQ1!, MNQ1!, CME_MINI:NQ1!, NQU2026,
// etc.) down to a short root name ("NQ", "ES", "YM") for display in SMT labels. Falls back to
// syminfo.ticker(symbol) unchanged if none of the known roots are found, so unrecognized
// symbols still display something reasonable instead of being blanked out.
method ShortTicker(Helper helper, string symbol) =>
    helper.name := 'ShortTicker'
    string t = syminfo.ticker(symbol)
    string upper = str.upper(t)
    string out = t
    if str.contains(upper, 'MNQ')
        out := 'NQ'
    else if str.contains(upper, 'MES')
        out := 'ES'
    else if str.contains(upper, 'MYM')
        out := 'YM'
    else if str.contains(upper, 'NQ')
        out := 'NQ'
    else if str.contains(upper, 'ES')
        out := 'ES'
    else if str.contains(upper, 'YM')
        out := 'YM'
    out

// FIX (same-instrument self-reference): detects when a configured PSP/SMT reference symbol
// is actually the SAME underlying instrument as the chart itself, just reached through a
// different ticker alias (e.g. chart is "CBOT:YM1!" but Ticker 2 is set to "CBOT_MINI:YM1!").
// Comparing an instrument against itself can never be a real divergence — any difference that
// shows up is purely a feed/permission artifact between the two aliases (different update
// timing, different rollover instant, etc.), not a genuine SMT or PSP event. This reuses the
// same root-collapsing logic as ShortTicker so "NQ1!", "MNQ1!", and "CME_MINI:NQ1!" are all
// recognized as the same root regardless of exact exchange prefix or contract suffix.
method SameInstrument(Helper helper, string symbol) =>
    helper.name := 'SameInstrument'
    string chartRoot = helper.ShortTicker(syminfo.tickerid)
    string refRoot = helper.ShortTicker(symbol)
    bool knownRoot = chartRoot == 'NQ' or chartRoot == 'ES' or chartRoot == 'YM'
    // Only treat as a match when both sides collapsed to one of the known recognized roots —
    // if either side is an unrecognized ticker, ShortTicker falls back to returning the ticker
    // unchanged, and two different unrecognized tickers happening to be unequal strings should
    // not be misread as "different roots confirmed distinct"; it simply means this guard can't
    // make a confident determination, so it stays out of the way rather than guessing.
    knownRoot and chartRoot == refRoot

// PSP color logic — reverted to the ORIGINAL exact-match form (no tolerance window, no
// periodMs parameter). A reference symbol only counts toward divergence if its own HTF bar
// time is EXACTLY equal to the active candle's HTF bar time (candleTime). This is the precise
// "same period" test: discrete HTF periods should be compared with exact equality, not a
// numeric tolerance window, since any tolerance wide enough to forgive a one-tick lag is also
// wide enough to accept an entire stale prior period, which produces incorrect PSP coloring
// (flagging candles that actually agree, or missing candles that actually diverge).
method PSPColor(Helper helper, bool bull, int candleTime, float c1, float o1, int t1, float c2, float o2, int t2, float c3, float o3, int t3, float c4, float o4, int t4) =>
    helper.name := 'PSPColor'
    bool diverge1 = settings.psp_sym1_use and not na(c1) and not na(o1) and t1 == candleTime and (bull != (c1 > o1))
    bool diverge2 = settings.psp_sym2_use and not na(c2) and not na(o2) and t2 == candleTime and (bull != (c2 > o2))
    bool diverge3 = settings.psp_sym3_use and not na(c3) and not na(o3) and t3 == candleTime and (bull != (c3 > o3))
    bool diverge4 = settings.psp_sym4_use and not na(c4) and not na(o4) and t4 == candleTime and (bull != (c4 > o4))
    bool isPSP = settings.psp_show and (diverge1 or diverge2 or diverge3 or diverge4)
    color bodyOut = bull ? settings.psp_up_body : settings.psp_down_body
    color borderOut = bull ? settings.psp_up_border : settings.psp_down_border
    color wickOut = bull ? settings.psp_up_wick : settings.psp_down_wick
    [isPSP, bodyOut, borderOut, wickOut]

method HTFEnabled(Helper helper) =>
    helper.name := 'HTFEnabled'
    int enabled = 0
    enabled := enabled + (htf1.settings.show ? 1 : 0)
    enabled := enabled + (htf2.settings.show ? 1 : 0)
    enabled := enabled + (htf3.settings.show ? 1 : 0)
    enabled := enabled + (htf4.settings.show ? 1 : 0)
    enabled := enabled + (htf5.settings.show ? 1 : 0)
    enabled := enabled + (htf6.settings.show ? 1 : 0)
    enabled := enabled + (htf7.settings.show ? 1 : 0)
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

    if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
        h := helper.CandleSetHigh(htf1.candles, h)
        cnt := cnt + 1
    if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf2.candles, h)
        cnt := cnt + 1
    if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf3.candles, h)
        cnt := cnt + 1
    if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf4.candles, h)
        cnt := cnt + 1
    if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf5.candles, h)
        cnt := cnt + 1
    if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf6.candles, h)
        cnt := cnt + 1
    if htf7.settings.show and helper.ValidTimeframe(htf7.settings.htf) and cnt < last
        h := helper.CandleSetHigh(htf7.candles, h)

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

    if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
        l := helper.CandleSetLow(htf1.candles, l)
        cnt := cnt + 1
    if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf2.candles, l)
        cnt := cnt + 1
    if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf3.candles, l)
        cnt := cnt + 1
    if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf4.candles, l)
        cnt := cnt + 1
    if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf5.candles, l)
        cnt := cnt + 1
    if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf6.candles, l)
        cnt := cnt + 1
    if htf7.settings.show and helper.ValidTimeframe(htf7.settings.htf) and cnt < last
        l := helper.CandleSetLow(htf7.candles, l)

    if array.size(candles) > 0
        for i = 0 to array.size(candles) - 1 by 1
            Candle c = array.get(candles, i)
            if c.l < l
                l := c.l
    l

method UpdateTime(CandleSet candleSet, int offset) =>
    if settings.htf_timer_show and (barstate.isrealtime or barstate.islast)
        string tmr = '(' + helper.RemainingTime(candleSet.settings.htf) + ')'

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

            if settings.show_time and not na(candle.o_time)
                string timeText = str.format_time(candle.o_time, 'HH:mm', 'America/New_York')
                if not na(candle.dow_label)
                    candle.dow_label.set_y(candle.l)
                    candle.dow_label.set_x(bar_index + settings.width / 2 + t_buffer)
                    candle.dow_label.set_text(timeText)
                else
                    candle.dow_label := label.new(bar_index + settings.width / 2 + t_buffer, candle.l, timeText, color = color_transparent, textcolor = settings.time_color, style = label.style_label_up, size = settings.time_size, text_font_family = font.family_monospace)

            // Sweep lines and SMT lines/labels are fully deleted+redrawn each bar
            // inside DrawSweepAndSMT() which runs after Reorder(), so no repositioning needed here.

    top = 0.0
    bottom = 0.0

    if settings.label_alignment == 'Align'
        top := helper.CandlesHigh(candleSet.candles)
        bottom := helper.CandlesLow(candleSet.candles, top)
    if settings.label_alignment == 'Follow Candles'
        top := helper.CandleSetHigh(candleSet.candles, 0)
        bottom := helper.CandleSetLow(candleSet.candles, top)

    left = bar_index + offset + (settings.width + settings.buffer) * (size - 1) / 2

    if settings.htf_label_show
        string lblt = helper.HTFName(candleSet.settings.htf)
        string lbll = lblt
        if settings.htf_timer_show
            lblt := lblt + '\n'
            lbll := '\n' + lbll

        string tmr = '(' + helper.RemainingTime(candleSet.settings.htf) + ')'
        if settings.label_position == 'Both' or settings.label_position == 'Top'
            
            if not na(candleSet.tfNameTop)
                candleSet.tfNameTop.set_xy(left, top)
            else
                candleSet.tfNameTop := label.new(left, top, lblt, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_down, size = settings.htf_label_size)
            if settings.htf_timer_show
                if not na(candleSet.tfTimerTop)
                    candleSet.tfTimerTop.set_xy(left, top)
                else
                    candleSet.tfTimerTop := label.new(left, top, tmr, color = color_transparent, textcolor = settings.htf_timer_color, style = label.style_label_down, size = settings.htf_timer_size)

        if settings.label_position == 'Both' or settings.label_position == 'Bottom'
            if not na(candleSet.tfNameBottom)
                candleSet.tfNameBottom.set_xy(left, bottom)
            else
                candleSet.tfNameBottom := label.new(left, bottom, lbll, color = color_transparent, textcolor = settings.htf_label_color, style = label.style_label_up, size = settings.htf_label_size)
            if settings.htf_timer_show
                if settings.htf_timer_show
                    if not na(candleSet.tfTimerBottom)
                        candleSet.tfTimerBottom.set_xy(left, bottom)
                    else
                        candleSet.tfTimerBottom := label.new(left, bottom, tmr, color = color_transparent, textcolor = settings.htf_timer_color, style = label.style_label_up, size = settings.htf_timer_size)

    candleSet

method FindImbalance(CandleSet candleSet) =>
    if barstate.isrealtime or barstate.islast
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

// ──────────────────────────────────────────────────────────────────────────────
// DrawSweepAndSMT — scans ALL adjacent candle pairs in the set.
//
// FIX (v2): SMT divergence is now tested using REAL high/low for every leg — the
// chart and each enabled reference symbol — instead of an open/close bull/bear-flip
// proxy. The flip proxy could miss a genuine new high/low whenever a symbol's candle
// happened to keep the same color across two bars (e.g. two bearish bars in a row,
// the second one still printing a fresh lower low), which is exactly what caused the
// SMT marker to land on the wrong extreme (highs instead of lows) and drop a symbol
// (NQ) from the divergence label while only ES showed up. Comparing real high/low is
// also the technically correct ICT definition of SMT (a swing-structure comparison,
// not a candle-color comparison).
//
//   For the pair (A = older candle, B = newer candle), for EACH leg (chart, sym1,
//   sym2, sym3) we know whether that leg made a new high (leg_h(B) > leg_h(A)) and/or
//   a new low (leg_l(B) < leg_l(A)) using that leg's own real high/low.
//
//   Bearish SMT (high-side divergence): the CHART made a new high, but one or more
//   enabled reference symbols did NOT make a new high over the same step → those
//   symbols are listed in the label, line drawn at the chart's own A.h → B.h.
//   Also fires in reverse: a reference made a new high that the chart did NOT — the
//   line is still drawn on the chart's own A.h → B.h (the only geometry available on
//   this chart), labelled with the symbol(s) that diverged, so switching to view a
//   different correlated symbol's own chart still surfaces the same underlying event
//   instead of going silent.
//
//   Bullish SMT (low-side divergence): mirror of the above using new lows.
//
//   SMT line color: settings.smt_color. Ticker text can be hidden per-symbol via
//   settings.smt_show_sym1/2/3 (and a label master toggle) while the line itself is
//   always drawn regardless of label visibility.
//
// FIX (cross-chart mismatch + same-instrument false positive): two further conditions now
// gate whether a reference symbol's high/low counts toward SMT at all:
//   1. Same-period timestamp guard (smt_valid1/2/3) — mirrors the t==candleTime guard PSP
//      already had. Without it, a reference symbol's HTF bar could be momentarily desynced
//      (lagging or leading the chart's own bar), and its STALE high/low would get compared
//      against the chart's CURRENT high/low — producing a divergence reading that wouldn't
//      match what the reference symbol's own chart shows for the identical candle pair.
//   2. Same-instrument guard (helper.SameInstrument, applied when smt_use1/2/3 is captured) —
//      if a configured reference symbol resolves to the same underlying root as the chart
//      itself (e.g. charting "CBOT:YM1!" with Ticker 2 set to "CBOT_MINI:YM1!"), it's excluded
//      from SMT entirely. An instrument can't meaningfully diverge from itself; any apparent
//      difference is purely a feed/alias artifact, not a real SMT event.
//
// HTF SWEEP (only when NO SMT on this pair):
//   High sweep: B.h > A.h → horizontal line starting at A's top-wick tip, extending
//               right to B's wick center. Drawn at A.h level. Color from settings.sweep_color.
//   Low sweep:  B.l < A.l → horizontal line from A's bottom-wick tip to B's wick center.
// ──────────────────────────────────────────────────────────────────────────────
method DrawSweepAndSMT(CandleSet candleSet) =>
    if (barstate.isrealtime or barstate.islast) and candleSet.candles.size() >= 2
        color smtColor   = settings.smt_color      // FIX (issue 2): user-selectable
        color sweepColor = settings.sweep_color    // FIX (issue 2): user-selectable
        int sz = candleSet.candles.size()

        for i = 0 to sz - 2
            Candle B = candleSet.candles.get(i)      // newer (right) candle
            Candle A = candleSet.candles.get(i + 1)  // older  (left) candle

            // Candle geometry (already repositioned by Reorder)
            int A_l  = box.get_left(A.body)
            int A_cx = A_l + settings.width / 2
            int B_l  = box.get_left(B.body)
            int B_cx = B_l + settings.width / 2
            int B_r  = box.get_right(B.body)

            // ── Clear prior drawings on B ──────────────────────────────────────
            if not na(B.sweep_high_line)
                line.delete(B.sweep_high_line)
                B.sweep_high_line := na
            if not na(B.sweep_low_line)
                line.delete(B.sweep_low_line)
                B.sweep_low_line := na
            if not na(B.smt_high_line)
                line.delete(B.smt_high_line)
                B.smt_high_line := na
            if not na(B.smt_low_line)
                line.delete(B.smt_low_line)
                B.smt_low_line := na
            if not na(B.smt_label)
                label.delete(B.smt_label)
                B.smt_label := na

            // ── SMT Divergence (FIX v2: real high/low for every leg) ────────────
            bool hasSMT = false

            if settings.smt_show
                // Chart's own real swing test (always available, exact).
                bool chartHH = B.h > A.h
                bool chartLL = B.l < A.l

                string divLabelsUp   = ""  // symbols that diverge on the high side (bearish SMT)
                string divLabelsDown = ""  // symbols that diverge on the low side (bullish SMT)

                // sym1
                if A.smt_use1 and B.smt_use1 and A.smt_valid1 and B.smt_valid1 and not na(A.smt_h1) and not na(B.smt_h1) and not na(A.smt_l1) and not na(B.smt_l1)
                    bool sym1HH = B.smt_h1 > A.smt_h1
                    bool sym1LL = B.smt_l1 < A.smt_l1
                    // High side: chart and sym1 disagree on whether a new high was made.
                    if chartHH != sym1HH
                        divLabelsUp := settings.smt_show_sym1 ? helper.ShortTicker(settings.psp_sym1) : " "
                    // Low side: chart and sym1 disagree on whether a new low was made.
                    if chartLL != sym1LL
                        divLabelsDown := settings.smt_show_sym1 ? helper.ShortTicker(settings.psp_sym1) : " "

                // sym2
                if A.smt_use2 and B.smt_use2 and A.smt_valid2 and B.smt_valid2 and not na(A.smt_h2) and not na(B.smt_h2) and not na(A.smt_l2) and not na(B.smt_l2)
                    bool sym2HH = B.smt_h2 > A.smt_h2
                    bool sym2LL = B.smt_l2 < A.smt_l2
                    if chartHH != sym2HH
                        divLabelsUp := divLabelsUp == "" ? (settings.smt_show_sym2 ? helper.ShortTicker(settings.psp_sym2) : " ") : divLabelsUp + (settings.smt_show_sym2 ? " " + helper.ShortTicker(settings.psp_sym2) : "")
                    if chartLL != sym2LL
                        divLabelsDown := divLabelsDown == "" ? (settings.smt_show_sym2 ? helper.ShortTicker(settings.psp_sym2) : " ") : divLabelsDown + (settings.smt_show_sym2 ? " " + helper.ShortTicker(settings.psp_sym2) : "")

                // sym3
                if A.smt_use3 and B.smt_use3 and A.smt_valid3 and B.smt_valid3 and not na(A.smt_h3) and not na(B.smt_h3) and not na(A.smt_l3) and not na(B.smt_l3)
                    bool sym3HH = B.smt_h3 > A.smt_h3
                    bool sym3LL = B.smt_l3 < A.smt_l3
                    if chartHH != sym3HH
                        divLabelsUp := divLabelsUp == "" ? (settings.smt_show_sym3 ? helper.ShortTicker(settings.psp_sym3) : " ") : divLabelsUp + (settings.smt_show_sym3 ? " " + helper.ShortTicker(settings.psp_sym3) : "")
                    if chartLL != sym3LL
                        divLabelsDown := divLabelsDown == "" ? (settings.smt_show_sym3 ? helper.ShortTicker(settings.psp_sym3) : " ") : divLabelsDown + (settings.smt_show_sym3 ? " " + helper.ShortTicker(settings.psp_sym3) : "")

                bool bearishSMT = divLabelsUp != ""    // high-side divergence exists
                bool bullishSMT = divLabelsDown != ""  // low-side divergence exists

                // A pair can legitimately show both a high-side AND low-side divergence
                // (e.g. an inside/outside bar situation) — draw both when present.
                if bearishSMT
                    hasSMT := true
                    string lblTextUp = str.trim(divLabelsUp)
                    // Bearish SMT: diagonal from A.high (left) → B.high (right)
                    B.smt_high_line := line.new(A_cx, A.h, B_cx, B.h,
                         xloc = xloc.bar_index, color = smtColor, width = 1, style = line.style_solid)
                    if settings.smt_label_show and lblTextUp != "" and not bullishSMT
                        // Only place the high-side label here when there's no low-side
                        // divergence on this same pair; if both fire, the combined label
                        // below (drawn at the low) carries both so nothing is dropped.
                        B.smt_label := label.new(B_cx, B.h,
                             lblTextUp, xloc = xloc.bar_index,
                             style = label.style_label_down, color = #ffffff00,
                             textcolor = smtColor, size = size.small)

                if bullishSMT
                    hasSMT := true
                    string lblTextDown = str.trim(divLabelsDown)
                    // Bullish SMT: diagonal from A.low (left) → B.low (right)
                    B.smt_low_line := line.new(A_cx, A.l, B_cx, B.l,
                         xloc = xloc.bar_index, color = smtColor, width = 1, style = line.style_solid)
                    if settings.smt_label_show
                        // If a high-side divergence ALSO fired on this same pair (rare —
                        // e.g. an outside bar), combine both into one label so neither is
                        // silently dropped, rather than one label handle overwriting the other.
                        string combinedText = bearishSMT and str.trim(divLabelsUp) != "" ? str.trim(divLabelsUp) + " / " + lblTextDown : lblTextDown
                        if combinedText != ""
                            B.smt_label := label.new(B_cx, B.l,
                                 combinedText, xloc = xloc.bar_index,
                                 style = label.style_label_up, color = #ffffff00,
                                 textcolor = smtColor, size = size.small)

            // ── HTF Sweep (suppressed when SMT found on this pair) ─────────────
            // Sweep line: horizontal line at A's extreme starting at A's wick center,
            // extending right PAST B's candle to B's right edge (not just to B's wick
            // center), matching the reference style where the sweep line visibly passes
            // beyond the candle that broke the level rather than stopping at its middle.
            if settings.sweep_show and not hasSMT
                // High sweep: B broke above A's high
                if B.h > A.h
                    // Line from A's wick center (A_cx) at A.h → across past B's right edge
                    B.sweep_high_line := line.new(A_cx, A.h, B_r, A.h,
                         xloc = xloc.bar_index, color = sweepColor, width = 1, style = line.style_solid)

                // Low sweep: B broke below A's low
                if B.l < A.l
                    B.sweep_low_line := line.new(A_cx, A.l, B_r, A.l,
                         xloc = xloc.bar_index, color = sweepColor, width = 1, style = line.style_solid)

        // FIX: the oldest still-visible candle (index sz-1) is only ever used as "A" in the
        // loop above — it's never revisited as "B", so its drawings are never cleared/redrawn
        // here. If it was drawn as "B" on a previous bar (back when it was newer, before more
        // candles arrived in front of it), that old line/label is left anchored at its
        // original bar_index coordinates while every other candle keeps shifting left as new
        // ones unshift in. The result is exactly what shows up during bar replay: an SMT/sweep
        // line that visually "stays behind" instead of moving or disappearing with the rest of
        // the set. Since this candle has no newer neighbor to pair against, it can't get a
        // fresh line — so just clear whatever it's still holding.
        Candle oldest = candleSet.candles.get(sz - 1)
        if not na(oldest.sweep_high_line)
            line.delete(oldest.sweep_high_line)
            oldest.sweep_high_line := na
        if not na(oldest.sweep_low_line)
            line.delete(oldest.sweep_low_line)
            oldest.sweep_low_line := na
        if not na(oldest.smt_high_line)
            line.delete(oldest.smt_high_line)
            oldest.smt_high_line := na
        if not na(oldest.smt_low_line)
            line.delete(oldest.smt_low_line)
            oldest.smt_low_line := na
        if not na(oldest.smt_label)
            label.delete(oldest.smt_label)
            oldest.smt_label := na

    candleSet

method Monitor(CandleSet candleSet) =>
    HTFBarTime = time(candleSet.settings.htf, 'america/New_York')
    isNewHTFCandle = ta.change(HTFBarTime) > 0

    if isNewHTFCandle
        Candle candle = Candle.new()
        candle.o := open
        candle.c := close
        candle.h := high
        candle.l := low
        candle.o_time := time
        bull = candle.c > candle.o

        [isPSP, pspBody, pspBorder, pspWick] = helper.PSPColor(bull, HTFBarTime,
             candleSet.settings.sym1_c, candleSet.settings.sym1_o, candleSet.settings.sym1_t,
             candleSet.settings.sym2_c, candleSet.settings.sym2_o, candleSet.settings.sym2_t,
             candleSet.settings.sym3_c, candleSet.settings.sym3_o, candleSet.settings.sym3_t,
             candleSet.settings.sym4_c, candleSet.settings.sym4_o, candleSet.settings.sym4_t)
        color bodyColor = isPSP ? pspBody : (bull ? settings.bull_body : settings.bear_body)
        color borderColor = isPSP ? pspBorder : (bull ? settings.bull_border : settings.bear_border)
        color wickColor = isPSP ? pspWick : (bull ? settings.bull_wick : settings.bear_wick)

        candle.body := box.new(bar_index, math.max(candle.o, candle.c), bar_index + 2, math.min(candle.o, candle.c), borderColor, 1, bgcolor = bodyColor)
        candle.wick_up := line.new(bar_index + 1, candle.h, bar_index, math.max(candle.o, candle.c), color = wickColor)
        candle.wick_down := line.new(bar_index + 1, math.min(candle.o, candle.c), bar_index, candle.l, color = wickColor)

        // Store each reference symbol's REAL high/low for SMT comparison (FIX v2 — issue 1/2).
        candle.smt_h1   := candleSet.settings.sym1_h
        candle.smt_l1   := candleSet.settings.sym1_l
        candle.smt_h2   := candleSet.settings.sym2_h
        candle.smt_l2   := candleSet.settings.sym2_l
        candle.smt_h3   := candleSet.settings.sym3_h
        candle.smt_l3   := candleSet.settings.sym3_l
        // FIX (cross-chart mismatch): a reference symbol only counts toward SMT if (a) it's
        // enabled, (b) its own HTF bar time exactly matches this candle's bar time (same guard
        // PSP already uses — prevents comparing against a stale/desynced prior or not-yet-
        // rolled-over period), and (c) it isn't the same underlying instrument as the chart
        // itself (a reference symbol that resolves to the same root as the chart — e.g. the
        // chart is YM and Ticker 2 is also set to a YM alias on a different exchange route —
        // can never produce a meaningful divergence; any apparent difference is purely a
        // feed/permission artifact between the two aliases, not a real SMT event).
        candle.smt_use1 := settings.psp_sym1_use and not helper.SameInstrument(settings.psp_sym1)
        candle.smt_use2 := settings.psp_sym2_use and not helper.SameInstrument(settings.psp_sym2)
        candle.smt_use3 := settings.psp_sym3_use and not helper.SameInstrument(settings.psp_sym3)
        candle.smt_valid1 := not na(candleSet.settings.sym1_t) and candleSet.settings.sym1_t == HTFBarTime
        candle.smt_valid2 := not na(candleSet.settings.sym2_t) and candleSet.settings.sym2_t == HTFBarTime
        candle.smt_valid3 := not na(candleSet.settings.sym3_t) and candleSet.settings.sym3_t == HTFBarTime
        candleSet.candles.unshift(candle)

        if candleSet.candles.size() > candleSet.settings.max_display
            Candle delCandle = array.pop(candleSet.candles)
            box.delete(delCandle.body)
            line.delete(delCandle.wick_up)
            line.delete(delCandle.wick_down)
            delCandle.dow_label.delete()
            // FIX: sweep/SMT lines and the SMT label were never deleted on eviction, so once
            // a candle aged out past max_display (e.g. scrolling forward during bar replay,
            // or simply accumulating enough HTF bars over time), any sweep/SMT drawing still
            // attached to it from when it was last redrawn as "B" stayed on the chart forever
            // — orphaned, since nothing else ever points at or clears that line/label again.
            // Deleting them here, at the moment the candle leaves the array, closes that leak.
            if not na(delCandle.sweep_high_line)
                line.delete(delCandle.sweep_high_line)
            if not na(delCandle.sweep_low_line)
                line.delete(delCandle.sweep_low_line)
            if not na(delCandle.smt_high_line)
                line.delete(delCandle.smt_high_line)
            if not na(delCandle.smt_low_line)
                line.delete(delCandle.smt_low_line)
            if not na(delCandle.smt_label)
                label.delete(delCandle.smt_label)

        // Separator (ported from reference script): draws one full vertical line on the
        // underlying chart itself, marking the open of whichever HTF TIMEFRAME the user picked
        // via settings.sep_tf (a native timeframe picker, e.g. "15", "30", "60", "1D" — matches
        // the same widget style as each HTF slot's own timeframe input). Fires whenever a
        // CandleSet whose configured timeframe matches that choice rolls to a new bar. If more
        // than one HTF slot happens to share the same timeframe string, the separator draws
        // once per matching slot's own "new HTF candle" event (they're the same underlying
        // period, so this is harmless — duplicate lines at the same bar simply overlap).
        if settings.show_sep and settings.sep_tf == candleSet.settings.htf
            line new_separator = line.new(x1 = bar_index, x2 = bar_index, y1 = high + syminfo.mintick, y2 = low - syminfo.mintick, extend = extend.both, color = settings.sep_color, style = helper.LineStyle(settings.sep_style), width = settings.sep_width)
            separators.push(new_separator)

            if separators.size() > candleSet.settings.max_display
                line.delete(separators.shift())

    candleSet

method Update(CandleSet candleSet, int offset) =>
    if candleSet.candles.size() > 0
        Candle candle = candleSet.candles.first()
        bool isLiveCandle = candle.o_time == time(candleSet.settings.htf, 'america/New_York')
        candle.h := high > candle.h ? high : candle.h
        candle.l := low < candle.l ? low : candle.l
        candle.c := close

        bull = candle.c > candle.o

        if isLiveCandle
            HTFBarTime = time(candleSet.settings.htf, 'america/New_York')
            [isPSP, pspBody, pspBorder, pspWick] = helper.PSPColor(bull, HTFBarTime,
                 candleSet.settings.sym1_c, candleSet.settings.sym1_o, candleSet.settings.sym1_t,
                 candleSet.settings.sym2_c, candleSet.settings.sym2_o, candleSet.settings.sym2_t,
                 candleSet.settings.sym3_c, candleSet.settings.sym3_o, candleSet.settings.sym3_t,
                 candleSet.settings.sym4_c, candleSet.settings.sym4_o, candleSet.settings.sym4_t)
            color bodyColor = isPSP ? pspBody : (bull ? settings.bull_body : settings.bear_body)
            color borderColor = isPSP ? pspBorder : (bull ? settings.bull_border : settings.bear_border)
            color wickColor = isPSP ? pspWick : (bull ? settings.bull_wick : settings.bear_wick)

            box.set_bgcolor(candle.body, bodyColor)
            box.set_border_color(candle.body, borderColor)
            line.set_color(candle.wick_up, wickColor)
            line.set_color(candle.wick_down, wickColor)

            // Keep the stored reference high/low current while this candle is still live, so
            // the eventual "frozen" snapshot reflects the latest, most up-to-date reference
            // data rather than a value sampled mid-formation (FIX v2 — real h/l, not a flip).
            candle.smt_h1 := candleSet.settings.sym1_h
            candle.smt_l1 := candleSet.settings.sym1_l
            candle.smt_h2 := candleSet.settings.sym2_h
            candle.smt_l2 := candleSet.settings.sym2_l
            candle.smt_h3 := candleSet.settings.sym3_h
            candle.smt_l3 := candleSet.settings.sym3_l
            // FIX: keep the same-period validity flags current too, for the same reason —
            // a reference symbol can roll over mid-formation, so re-check every live bar
            // rather than trusting the validity captured back at candle-creation time.
            candle.smt_valid1 := not na(candleSet.settings.sym1_t) and candleSet.settings.sym1_t == HTFBarTime
            candle.smt_valid2 := not na(candleSet.settings.sym2_t) and candleSet.settings.sym2_t == HTFBarTime
            candle.smt_valid3 := not na(candleSet.settings.sym3_t) and candleSet.settings.sym3_t == HTFBarTime

        box.set_top(candle.body, candle.o)
        box.set_bottom(candle.body, candle.c)
        line.set_y1(candle.wick_up, candle.h)
        line.set_y2(candle.wick_up, math.max(candle.o, candle.c))
        line.set_y1(candle.wick_down, candle.l)
        line.set_y2(candle.wick_down, math.min(candle.o, candle.c))

        if barstate.isrealtime or barstate.islast
            candleSet.Reorder(offset)
    candleSet

int cnt = 0
int last = helper.HTFEnabled()

int offset = settings.offset
if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
    htf1.UpdateTime(offset)
    htf1.Monitor().Update(offset).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf1.candles.size() * settings.width + (htf1.candles.size() > 0 ? (htf1.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf) and cnt < last
    htf2.UpdateTime(offset)
    htf2.Monitor().Update(offset).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf2.candles.size() * settings.width + (htf2.candles.size() > 0 ? (htf2.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf) and cnt < last
    htf3.UpdateTime(offset)
    htf3.Monitor().Update(offset).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf3.candles.size() * settings.width + (htf3.candles.size() > 0 ? (htf3.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf) and cnt < last
    htf4.UpdateTime(offset)
    htf4.Monitor().Update(offset).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf4.candles.size() * settings.width + (htf4.candles.size() > 0 ? (htf4.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf) and cnt < last
    htf5.UpdateTime(offset)
    htf5.Monitor().Update(offset).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf5.candles.size() * settings.width + (htf5.candles.size() > 0 ? (htf5.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf) and cnt < last
    htf6.UpdateTime(offset)
    htf6.Monitor().Update(offset).FindImbalance()
    cnt := cnt + 1
    offset := offset + (cnt > 0 ? htf6.candles.size() * settings.width + (htf6.candles.size() > 0 ? (htf6.candles.size() - 1) * settings.buffer : 0) + settings.htf_buffer : 0)
    offset
if htf7.settings.show and helper.ValidTimeframe(htf7.settings.htf) and cnt < last
    htf7.UpdateTime(offset)
    htf7.Monitor().Update(offset).FindImbalance()

// ── Sweep & SMT pass: runs after all candles are positioned ──────────────────
if htf1.settings.show and helper.ValidTimeframe(htf1.settings.htf)
    htf1.DrawSweepAndSMT()
if htf2.settings.show and helper.ValidTimeframe(htf2.settings.htf)
    htf2.DrawSweepAndSMT()
if htf3.settings.show and helper.ValidTimeframe(htf3.settings.htf)
    htf3.DrawSweepAndSMT()
if htf4.settings.show and helper.ValidTimeframe(htf4.settings.htf)
    htf4.DrawSweepAndSMT()
if htf5.settings.show and helper.ValidTimeframe(htf5.settings.htf)
    htf5.DrawSweepAndSMT()
if htf6.settings.show and helper.ValidTimeframe(htf6.settings.htf)
    htf6.DrawSweepAndSMT()
if htf7.settings.show and helper.ValidTimeframe(htf7.settings.htf)
    htf7.DrawSweepAndSMT()
````
