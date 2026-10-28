# FVG Confluence [AFD]

- url: https://www.tradingview.com/script/i4riYfbR-FVG-Confluence-AFD/
- type: indicator
- pine_id: PUB;d0ed2a5e059d4a3999b10d56954e6b52
- version: 5.0

## Description

This Pine Script v6 overlay documents confirmed fair-value gaps (FVGs), optional order blocks (OBs), and overlap evidence from two selected higher timeframes. Its main output is a confluence band whose label identifies the two source timeframes and zone types when two same-direction zones overlap by a configurable amount.

This is a descriptive chart tool. It records what the source zones have done, how they overlap, and how price has interacted with them. It does not provide trade instructions, manage positions, or forecast an outcome.

────────── 1. Overview ──────────

The script has three related layers:

- Chart FVGs: three-candle fair-value gaps detected on the chart timeframe.
- Optional Order Blocks: the last opposite candle identified before a confirmed swing break.
- MTF Confluence: an overlap between source zones from Compare timeframe 1 and Compare timeframe 2.

By default, MTF confluence bands and labels showing their source timeframes and zone types are visible. Raw higher-timeframe source boxes are hidden by default and can be shown per timeframe with a choice of FVGs, Order Blocks, or both. Standalone chart FVG boxes and chart OB boxes are off by default; each appears when its respective Enable FVGs or Enable Order Blocks setting is turned on.

────────── 2. How FVGs are detected ──────────

A bullish chart FVG is recorded when the current confirmed bar's low is above the high from two bars earlier. A bearish FVG is the inverse. The Minimum gap filter removes gaps smaller than the selected ATR multiple or tick distance. The default filter is 0.05 ATR.

The same gap test is evaluated in each selected higher-timeframe context. Higher-timeframe events are admitted once per source origin time, which prevents the same source event from producing duplicate records on the chart.

────────── 3. FVG lifecycle ──────────

Each FVG keeps its original boundaries and tracks penetration using the selected Mitigation / fill rule:

- FRESH - price has not touched or entered the gap.
- TESTED - price has touched or entered the gap but has not reached its 50% midpoint.
- MITIGATED - price has reached the 50% midpoint but has not fully traversed the gap.
- FILLED - price has fully traversed the gap. Filled chart FVGs are removed unless Keep filled FVGs is enabled.

Wick mode uses the candle range for penetration and state changes. Close mode requires the candle close to reach the relevant boundary. The rule is applied consistently to chart FVGs, chart order blocks, and higher-timeframe FVG source zones. Higher-timeframe OB sources track penetration with the same FRESH → TESTED → MITIGATED lifecycle as chart OBs, so raw HTF OB labels show state and fill percentage. A higher-timeframe zone (FVG or OB) that is fully traversed becomes FILLED: it stays tracked internally, is hidden by default, can be revealed per timeframe with the Show 100% filled zones settings, and never feeds confluence.

A boundary touch counts as TESTED, while the fill percentage measures penetration through the original zone. A boundary-only test can therefore still display 0% Filled until price advances farther into the zone.

Shrink on partial fill changes only the displayed near edge of a chart FVG. The original boundaries and 50% midpoint remain available for fill measurement and lifecycle identity. Order Blocks have their own OB partial fill setting (off by default) that shrinks OB boxes the same way. Breaker blocks restart measurement from the near edge in the new direction.

The FVG Labels settings can show the percentage filled and, optionally, the FVG lifecycle state. Labels can be placed inside the box or to its right, with user-selected offset, size, and text color.

────────── 4. Order blocks ──────────

When enabled, the script confirms swing points using Swing strength and searches the configured OB candle lookback for the last opposite candle before a confirmed break. It records bullish and bearish blocks separately and limits the retained count per side.

OBs use the same Wick or Close interaction basis as FVGs. They can move from FRESH to TESTED and MITIGATED. If Show breakers is enabled, a block that is crossed changes direction and becomes a BREAKER with a new penetration measurement. If breakers are disabled, the crossed block is removed. When OB partial fill is enabled, OB boxes shrink their near edge inward as confirmed penetration advances, and breaker blocks restart measurement from the near edge in the new direction.

Chart OB detection, retention, and drawing are controlled together in the Order Blocks settings and are off by default.

────────── 5. MTF confluence ──────────

Confluence uses only the two selected comparison timeframes. The chart timeframe is not a confluence source. Both comparison timeframes must be strictly higher than the chart timeframe and must be different from each other. If either timeframe is invalid, or either source is disabled, the corresponding confluence path is not active.

The script compares source zones by:

1. Direction - bullish zones pair only with bullish zones, and bearish zones pair only with bearish zones.
2. Original geometry - qualification uses the original source boundaries, not a partially shrunk display edge.
3. Minimum overlap - the positive overlap must meet the configured threshold, measured as a multiple of the confirmed TF1 timeframe ATR and subject to a minimum tick. Using a fixed-timeframe ATR keeps band qualification stable when the chart timeframe changes.
4. Source details - a band retains both source origins, source timeframes, source types, and its own formation time.

The source HTF calculation uses shifted, completed higher-timeframe values and confirms pivot-based events before admission. This avoids using a developing higher-timeframe event, but it introduces confirmation delay. A source zone may therefore appear after the originating higher-timeframe movement rather than during it.

Raw HTF FVGs / OBs can be shown separately for inspection, with a per-timeframe choice of FVGs, Order Blocks, or both. The type selection is display-only; all raw zones still feed confluence. Each timeframe has its own raw partial fill setting (TF1 raw partial fill and TF2 raw partial fill) that shrinks the near edge of that timeframe's raw zone boxes (both FVGs and OBs) as penetration advances, and its own Show 100% filled zones setting (off by default) that keeps fully traversed raw zones visible. Raw HTF labels show state and fill percentage for all zone kinds. Confluence is FVG-only by default. If Include Order Blocks in confluence is enabled, same-direction FVG/OB, OB/FVG, and OB/OB overlaps can also qualify. Any band containing an OB is labeled STATIC because it does not have the pure FVG/FVG fill cycle.

────────── 6. Reading confluence bands ──────────

The band color describes overlap density, not a rating:

- One active overlap - the single-overlap color.
- Two active overlaps - the two-overlap color.
- Three or more active overlaps - the dense-overlap color.

Density counts active same-direction confluence records that share positive price overlap and are currently visible under the state and filled-band filters. Changing those visibility filters can therefore change a displayed band's density color. Density does not measure historical performance, reliability, or the future behavior of a level.

For pure FVG/FVG bands, Confluence partial fill can shrink the displayed band as confirmed penetration advances. Confluence fill % label reports penetration through the original overlap. The fill percentage is descriptive and is not a forecast.

Confluence labels can show:

- Source timeframes and source types.
- The number of overlapping active bands.
- Fill percentage for pure FVG/FVG bands on its own label line.
- FRESH, TESTED, PARTIAL, FILLED, or STATIC state, shown together with age on one horizontal metadata line.
- Age in chart bars or HH:MM:SS.
- Visits and breaks in the tooltip.

Fresh, Tested, Partial, and Filled visibility can be controlled independently. Filled confluence bands are hidden by default. Nearby labels are grouped onto a shared horizontal row and spaced by a configurable number of chart bars; this changes label placement only and does not change the bands.

────────── 7. Alerts ──────────

The script exposes two confirmed-bar alert conditions for chart-timeframe detections:

- FVG formed - a new confirmed chart-timeframe FVG.
- Order Block formed - a new confirmed chart-timeframe order block.

There are no built-in alerts for confluence formation, fills, mitigation, state changes, or position management. You can create TradingView alerts from the two available conditions.

────────── 8. Settings and defaults ──────────

FVG Drawings controls chart FVG detection, drawing, per-side retention, Wick or Close measurement, ATR or tick filtering, partial display shrink, filled-zone retention, lifecycle display, and bullish/bearish colors.

FVG Labels controls fill percentage, position, right-side offset, text size, and label color.

Order Blocks controls OB detection, drawing, per-side retention, swing strength, candle lookback, breaker behavior, partial fill, and colors.

MTF Confluence controls the MTF master enable, the two comparison timeframes, source inclusion, raw HTF visibility, and — independently per timeframe — raw zone types (FVGs, Order Blocks, or both), raw partial fill, filled-zone visibility, and source color. It also controls HTF retention, HTF lookback days, and raw labels. The default comparison pair is 30 minutes and 60 minutes.

Confluence Evidence controls partial fill, fill labels, OB-containing overlap inclusion, minimum overlap, maximum retained bands, source-detail labels, filled-band visibility, overlap colors, state and age display, label collision spacing, age format, and state filters.

Visuals controls the confluence label size.

────────── 9. How to use ──────────

1. Start on a time-based chart timeframe below both comparison timeframes. The default 30-minute and 60-minute pair is intended to be used from a lower chart timeframe such as 15 minutes.
2. Leave both comparison source checkboxes enabled when you want TF1 × TF2 confluence. Selecting the same comparison timeframe twice does not create a valid pair.
3. Use the default FVG-only mode when you want all bands to have the FVG lifecycle and fill measurement. Enable OB inclusion only when STATIC FVG/OB, OB/FVG, or OB/OB overlap evidence is useful to your analysis.
4. Use Wick or Close consistently with how you want penetration measured. Close mode ignores wick-only penetration for state and fill progression.
5. Turn on raw HTF zones, or enable chart FVGs/OBs in their own settings sections, only when you need to inspect those layers. They are intentionally hidden in the default chart view.
6. Use the state, age, fill, density, and source details to understand what produced a band and how price has interacted with it. Do not treat color density as a score.

────────── 10. What this script does not do ──────────

- It is not a strategy and does not provide backtests, win rates, performance statistics, or position sizing.
- It does not place orders, manage risk, or generate trade instructions.
- It does not use the chart timeframe as a confluence source.
- It does not create confluence from opposite-direction zones.
- It does not guarantee that every historical FVG or OB remains visible. Source retention, HTF lookback, state filters, filled-band visibility, and TradingView drawing limits can remove or hide records.
- It does not eliminate higher-timeframe confirmation delay. A valid setting can show no band when no recent confirmed source pair qualifies.
- It does not claim that every chart, symbol, session, or timeframe will produce the same number of zones. ATR, tick size, available history, market hours, and price behavior affect detection.

────────── 11. Limitations and developing values ──────────

Lifecycle mutations, HTF source admission, confluence identity, fill measurement, and state changes are gated on confirmed bars. Boxes and labels are redrawn on the last chart bar so their right edge, text, colors, and collision layout reflect the current view. This means the display can update while the underlying lifecycle remains confirmation-gated.

Changing the chart timeframe or either comparison timeframe clears the prior MTF context and rebuilds it from confirmed source history. The selected comparison timeframes must be higher than the new chart timeframe. If the new context has no retained qualifying source pair, the confluence view can be empty until confirmed source events are available. Band qualification uses the confirmed TF1 timeframe ATR, so the same source pairs qualify regardless of the chart timeframe. In the Wick basis, fill percentages and lifecycle states are chart-timeframe independent; in the Close basis, penetration follows chart-bar closes, so fill percentages and states can legitimately differ between chart timeframes.

The script is capped by TradingView drawing limits and by its own retention settings. Chart and higher-timeframe zone arrays prune older records according to their configured limits. The confluence maximum is a retained-record capacity: when a new qualifying pair arrives beyond the cap, the oldest record is removed first. A crowded chart can therefore show fewer drawings than the underlying detection logic considered. Higher-timeframe records are also limited by the HTF lookback-days and max-zones-per-HTF/type settings.

The implementation is confirmation-gated, but this description does not make an absolute non-repainting claim. Verify the current publication on TradingView with the intended symbols, timeframes, input changes, reload behavior, and Bar Replay before relying on its historical appearance.

────────── 12. Originality ──────────

FVGs, order blocks, pivots, ATR filters, and multi-timeframe analysis are established market-analysis concepts. The implementation focus here is showing which two source zones created each overlap and tracking its lifecycle: each confluence band preserves the source records that formed it, keeps immutable original overlap geometry, separates display-only partial fill from band identity, and exposes state, age, fill, visit, break, source, and overlap-density information instead of hiding them inside an unexplained composite value.

The source is open for inspection under the MPL 2.0 license. The calculations and visual labels are intended to be read as a record of price interaction, not as a promise about what happens next.

────────── 13. Disclaimer ──────────

For educational and informational purposes only. Not financial advice. Past chart behavior does not predict future results.

## Source Code

````pine
// This is Pine Script® v6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry
//@version=6
// Confirmed FVGs, optional Order Blocks, and overlap evidence from two selected higher timeframes.
indicator("FVG Confluence [AFD]", "FVGC [AFD]", overlay=true,
     max_boxes_count=300, max_labels_count=300, max_lines_count=300, max_bars_back=4000)


plot(na, "FVG Confluence output", display=display.none)

// Confluence bands describe overlaps between independently detected zones.
// They are not probabilities, quality scores, or entry signals.

type FvgZone
    float top
    float bottom
    float orig_top
    float orig_bottom
    float pen
    int origin
    int event_key
    int born_bar
    int direction
    string kind
    string tf
    string state
    int visits
    int breaks
    bool was_inside
    box bx
    label pct_lbl
    line ce_ln

type ConfluenceBand
    int key_a
    int key_b
    int born_bar
    int born_time
    float top
    float bottom
    float orig_top
    float orig_bottom
    float fill_top
    float fill_bottom
    int direction
    string tf_a
    string tf_b
    string source_a
    string source_b
    string kind_a
    string kind_b
    string state
    string prev_status
    int visits
    int breaks
    bool was_inside
    box bx
    label lbl
    line ce_ln

var int box_count = 0
var int label_count = 0
var int line_count = 0

// The 300-object budgets sit under the platform maximum of 500 line, box and
// label IDs per type (limitations page). Public retention maxima require at most
// 240 boxes, 241 labels including the timeframe warning, and 240 midpoint lines.
const int DRAW_MAX_BOXES = 300
const int DRAW_MAX_LABELS = 300
const int DRAW_MAX_LINES = 300
// A drawing may be positioned at most 500 bars into the future.
const int CONFL_LABEL_MAX_FUTURE_BARS = 500

// Crowded labels are nudged upward through this many collision gaps before the
// excess text is hidden. Placement is a single ascending sweep in one column.
const int LABEL_MAX_TIERS = 4

// Pine cannot read rendered panel dimensions. These presentation-only reference
// values estimate vertical label spacing and affect no calculation, no zone
// identity and no state.
const float LABEL_REF_HEIGHT_PX = 360.0
const float LABEL_ROW_HEIGHT_FACTOR = 2.25

// Drawing constructors return na at the object limit while preserving state.
f_new_index_box(int left, float top, int right, float bottom, color border, color bg) =>
    box_count < DRAW_MAX_BOXES ? box.new(left, top, right, bottom, border_color=border, bgcolor=bg) : na

f_new_time_box(int left, float top, int right, float bottom, color border, color bg) =>
    box_count < DRAW_MAX_BOXES ? box.new(left, top, right, bottom, xloc=xloc.bar_time, border_color=border, bgcolor=bg) : na

// Consequent-encroachment (50% midpoint) lines. Time coordinates throughout:
// every zone and band already stores the time of its own left edge, and time
// anchoring avoids xloc.bar_index's past-bar drawing limit on retained objects.
f_new_time_ce(int left, float y, int right, color line_color, string line_style, int line_width, int used_lines) =>
    used_lines < DRAW_MAX_LINES ? line.new(left, y, right, y, xloc=xloc.bar_time, color=line_color, style=line_style, width=line_width) : na

f_new_zone_label(int x, float y, color text_color, string text_size, int used_labels) =>
    int safe_x = math.min(x, bar_index + CONFL_LABEL_MAX_FUTURE_BARS)
    used_labels < DRAW_MAX_LABELS ?
      label.new(safe_x, y, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=text_color, size=text_size) :
      na

f_new_band_label(int x, float y, string title, color band_color, color text_color, string text_size, string tip) =>
    int safe_x = math.min(x, bar_index + CONFL_LABEL_MAX_FUTURE_BARS)
    label_count < DRAW_MAX_LABELS ?
      label.new(safe_x, y, title, style=label.style_label_left, color=color.new(band_color, 70), textcolor=text_color, size=text_size, tooltip=tip) :
      na

f_new_htf_label(int x, float y, string label_text, color base, string text_size, string tip, int used_labels) =>
    int safe_x = math.min(x, bar_index + CONFL_LABEL_MAX_FUTURE_BARS)
    used_labels < DRAW_MAX_LABELS ?
      label.new(safe_x, y, label_text, style=label.style_label_left, color=color.new(base, 70), textcolor=color.white, size=text_size, tooltip=tip) :
      na

f_new_mtf_warning(int x, float y, string warning_text) =>
    label_count < DRAW_MAX_LABELS ?
      label.new(x, y, warning_text, style=label.style_label_down, color=color.new(color.orange, 15), textcolor=color.white, size=size.small,
        tooltip="Choose two different comparison timeframes that are both higher than the chart timeframe.") :
      na

// ── Inputs ─────────────────────────────────────────────────────────────────────
const string G_FVG = "FVG Drawings"
bool fvg_enable = input.bool(true, "Enable FVGs", group=G_FVG, tooltip="• Draw confirmed 3-candle fair value gaps on the chart timeframe.\n• Gaps confirm on closed bars only; developing gaps never draw.\n• Chart FVGs are standalone and never feed MTF confluence.\n• On by default so the script draws its primary object on any chart, and so the FVG alert condition is reachable without changing settings.", display=display.none)
int fvg_max = input.int(12, "Max FVGs per side", minval=1, maxval=30, group=G_FVG, tooltip="• Maximum retained bullish and bearish chart FVGs.\n• The oldest zone is removed when the cap is exceeded.", display=display.none)
string fvg_confirm = input.string("Wick", "Mitigation / fill rule", options=["Wick", "Close"], group=G_FVG, tooltip="• Wick — tests and the 50% midpoint read from the candle range.\n• Close — the candle close must reach the boundary.\n• One basis governs lifecycle, fill %, and confluence break detection.", display=display.none)
string fvg_min_mode = input.string("ATR", "Minimum gap filter", options=["ATR", "Ticks"], group=G_FVG, tooltip="• ATR — qualify gaps as a multiple of the 14-period ATR.\n• Ticks — qualify gaps as a fixed number of ticks.", display=display.none)
float fvg_min_value = input.float(0.05, "Minimum gap", minval=0.0, step=0.01, group=G_FVG, tooltip="• Minimum gap height as a multiple of the ATR.\n• Applies when Minimum gap filter is ATR.\n• The 0.05 default is permissive; raise it to suppress smaller gaps.", display=display.none)
float fvg_min_ticks = input.float(1.0, "Minimum ticks", minval=1.0, group=G_FVG, tooltip="• Minimum gap height in ticks.\n• Applies when Minimum gap filter is Ticks.", display=display.none)
bool fvg_shrink = input.bool(false, "Shrink on partial fill", group=G_FVG, tooltip="• Move the near edge inward as confirmed penetration advances.\n• The 50% midpoint stays anchored to the original gap.", display=display.none)
bool fvg_keep_filled = input.bool(false, "Keep filled FVGs", group=G_FVG, tooltip="• Off removes a chart FVG once price fully traverses it and suppresses 0% fill text on fresh chart FVGs.\n• On keeps filled zones on the chart in a FILLED state and shows their full fill scale.", display=display.none)
bool fvg_show_state = input.bool(false, "Show state on FVG", group=G_FVG, tooltip="Lifecycle stage, aligned to the fill % (same Wick/Close basis):\n• FRESH — 0%, price has not entered the zone.\n• TESTED — >0% to <50%, price entered but has not reached the 50% midpoint.\n• MITIGATED — 50% to <100%, price reached or passed the 50% midpoint.\n• FILLED — 100%, zone fully covered (removed unless Keep filled FVGs is on).\n• BREAKER — order block that flipped after price closed through it; its % restarts measuring penetration in the new direction.", display=display.none)
color bull_fvg_color = input.color(color.new(color.green, 82), "FVG bull / bear", inline="fvg_colors", group=G_FVG, tooltip="• Box colors for chart FVGs: bullish (upside) on the left, bearish (downside) on the right.", display=display.none)
color bear_fvg_color = input.color(color.new(color.red, 82), "", inline="fvg_colors", group=G_FVG, display=display.none)

const string G_FVG_PCT = "FVG Labels"
bool fvg_pct_show = input.bool(true, "Show % filled", group=G_FVG_PCT, tooltip="• Show the fill percentage on chart FVG and Order Block zones.\n• Position, text size, and color below govern both the fill % and the state label.", display=display.none)
string fvg_pct_pos = input.string("Right of Box", "Label position", options=["Inside Box", "Right of Box"], group=G_FVG_PCT, tooltip="• Inside Box — render the text inside the zone box.\n• Right of Box — render a label to the right of the zone.\n• Position, text size, and color here govern both the fill % and the state label (Show state on FVG).", display=display.none)
int fvg_pct_offset = input.int(2, "Right offset (bars)", minval=0, maxval=50, group=G_FVG_PCT, tooltip="• Horizontal distance in bars between the zone edge and its label.\n• Applies when Label position is Right of Box.", display=display.none)
string fvg_pct_size = input.string("Medium", "Text size", options=["Small", "Medium", "Large"], group=G_FVG_PCT, tooltip="• Text size for the fill % and state labels.\n• Medium matches the platform Normal size.", display=display.none)
color fvg_pct_color = input.color(color.white, "FVG label color", group=G_FVG_PCT, tooltip="• Color for chart FVG and Order Block label text.\n• White follows the chart foreground automatically for dark/light contrast; any other selected color is used exactly.\n• Applies to both fill % and state, inside the box or to its right.", display=display.none)

const string G_OB = "Order Blocks"
bool ob_enable = input.bool(false, "Enable Order Blocks", group=G_OB, tooltip="• A block is the last opposite candle before a confirmed swing break.\n• The internal swing check is retained only to originate OBs; structure drawings are not part of this script.", display=display.none)
int ob_max = input.int(8, "Max OBs per side", minval=1, maxval=20, group=G_OB, tooltip="• Maximum retained bullish and bearish chart Order Blocks.\n• The oldest block is removed when the cap is exceeded.", display=display.none)
int ob_swing = input.int(5, "Swing strength", minval=1, maxval=20, group=G_OB, tooltip="• Pivot strength used to confirm swing highs and lows.\n• Higher values require more bars on each side and produce fewer, larger swings.\n• Governs chart Order Blocks only. The higher-timeframe engine has its own pair under MTF Structure.", display=display.none)
int ob_lookback = input.int(10, "OB candle lookback", minval=2, maxval=40, group=G_OB, tooltip="• How many bars back to search for the last opposite candle after a confirmed swing break.\n• Governs chart Order Blocks only. The higher-timeframe engine has its own pair under MTF Structure.", display=display.none)
bool ob_show_breakers = input.bool(true, "Show breakers", group=G_OB, tooltip="• On flips a crossed Order Block into a breaker in the opposite direction.\n• Breaker fill % restarts measuring penetration from the near edge.\n• Off removes crossed blocks from the chart.", display=display.none)
bool ob_partial_fill = input.bool(false, "OB partial fill", group=G_OB, tooltip="• Shrink the near edge of Order Block boxes inward as confirmed penetration advances, mirroring FVG partial fill.\n• Breaker blocks restart measurement from the near edge in the new direction.", display=display.none)
color bull_ob_color = input.color(color.new(color.teal, 78), "OB bull / bear", inline="ob_colors", group=G_OB, tooltip="• Box colors for chart Order Blocks: bullish on the left, bearish on the right.", display=display.none)
color bear_ob_color = input.color(color.new(color.maroon, 78), "", inline="ob_colors", group=G_OB, display=display.none)

const string G_MTF = "MTF Confluence"
bool mtf_enable = input.bool(true, "Enable MTF zones", group=G_MTF, tooltip="• Show confluence bands formed by the two selected comparison timeframes.\n• Both timeframes must be higher than the chart timeframe and different from each other.\n• Raw HTF source zones stay hidden unless Show TF1 raw zones or Show TF2 raw zones is enabled.", display=display.none)
string mtf_tf1_input = input.string("Auto", "Compare timeframe 1", options=["Auto", "1", "3", "5", "10", "15", "30", "45", "60", "120", "180", "240", "480", "720", "D", "W", "M"], group=G_MTF, tooltip="• First higher timeframe whose confirmed FVGs and Order Blocks feed confluence.\n• Auto tracks the chart: the first standard step above the chart timeframe.\n• A fixed selection must be higher than the chart timeframe or this side contributes nothing.", display=display.none)
string mtf_tf2_input = input.string("Auto", "Compare timeframe 2", options=["Auto", "1", "3", "5", "10", "15", "30", "45", "60", "120", "180", "240", "480", "720", "D", "W", "M"], group=G_MTF, tooltip="• Second higher timeframe whose confirmed FVGs and Order Blocks feed confluence.\n• Auto tracks the chart: the second standard step above the chart timeframe.\n• A fixed selection must be higher than the chart timeframe and different from Compare timeframe 1.", display=display.none)
bool src_tf1 = input.bool(true, "Include TF1 in confluence", group=G_MTF, tooltip="• Include TF1 zones as a confluence source.\n• Does not hide raw TF1 drawings — use Show TF1 raw zones.\n• Confluence needs both timeframes valid, enabled, and different.", display=display.none)
bool src_tf2 = input.bool(true, "Include TF2 in confluence", group=G_MTF, tooltip="• Include TF2 zones as a confluence source.\n• Does not hide raw TF2 drawings — use Show TF2 raw zones.\n• Confluence needs both timeframes valid, enabled, and different.", display=display.none)
bool mtf_show_raw_tf1 = input.bool(false, "Show TF1 raw zones", group=G_MTF, tooltip="• Draw the individual TF1 source zones in addition to confluence bands.\n• TF1 raw zone types selects FVGs, Order Blocks, or both.\n• Off keeps the chart focused on the selected-timeframe overlap evidence.", display=display.none)
string mtf_raw_tf1_kind = input.string("FVGs and Order Blocks", "TF1 raw zone types", options=["FVGs and Order Blocks", "FVGs only", "Order Blocks only"], group=G_MTF, tooltip="• Choose which TF1 raw zone types to draw when Show TF1 raw zones is enabled.\n• Display-only: every TF1 zone still feeds confluence regardless of this selection.", display=display.none)
bool mtf_raw_tf1_partial_fill = input.bool(true, "TF1 raw partial fill", group=G_MTF, tooltip="• Shrink the near edge of TF1 raw zone boxes as confirmed penetration advances.\n• Applies to both FVG and Order Block zones.\n• Draw-only: zone identity and confluence pairing never change.", display=display.none)
bool mtf_raw_tf1_show_filled = input.bool(false, "Show TF1 100% filled zones", group=G_MTF, tooltip="• Off hides TF1 raw zones whose gap is fully traversed.\n• Filled zones stay tracked internally and age out via Max zones per HTF/type.\n• Filled zones never feed confluence regardless of this setting.", display=display.none)
color mtf_tf1_color = input.color(color.new(color.blue, 75), "TF1 color", group=G_MTF, tooltip="• Box color for TF1 raw zones.", display=display.none)
bool mtf_show_raw_tf2 = input.bool(false, "Show TF2 raw zones", group=G_MTF, tooltip="• Draw the individual TF2 source zones in addition to confluence bands.\n• TF2 raw zone types selects FVGs, Order Blocks, or both.\n• Off keeps the chart focused on the selected-timeframe overlap evidence.", display=display.none)
string mtf_raw_tf2_kind = input.string("FVGs and Order Blocks", "TF2 raw zone types", options=["FVGs and Order Blocks", "FVGs only", "Order Blocks only"], group=G_MTF, tooltip="• Choose which TF2 raw zone types to draw when Show TF2 raw zones is enabled.\n• Display-only: every TF2 zone still feeds confluence regardless of this selection.", display=display.none)
bool mtf_raw_tf2_partial_fill = input.bool(true, "TF2 raw partial fill", group=G_MTF, tooltip="• Shrink the near edge of TF2 raw zone boxes as confirmed penetration advances.\n• Applies to both FVG and Order Block zones.\n• Draw-only: zone identity and confluence pairing never change.", display=display.none)
bool mtf_raw_tf2_show_filled = input.bool(false, "Show TF2 100% filled zones", group=G_MTF, tooltip="• Off hides TF2 raw zones whose gap is fully traversed.\n• Filled zones stay tracked internally and age out via Max zones per HTF/type.\n• Filled zones never feed confluence regardless of this setting.", display=display.none)
color mtf_tf2_color = input.color(color.new(color.purple, 75), "TF2 color", group=G_MTF, tooltip="• Box color for TF2 raw zones.", display=display.none)
int mtf_max = input.int(12, "Max zones per HTF/type", minval=1, maxval=30, group=G_MTF, tooltip="• Maximum retained zones for each timeframe and type (TF1/TF2 × FVG/OB).\n• The oldest zone is removed when the cap is exceeded.", display=display.none)
int mtf_days = input.int(20, "HTF lookback (calendar days)", minval=1, maxval=365, group=G_MTF, tooltip="• Retain and admit only HTF zones whose source origin is within this rolling window.\n• Counted in calendar days from the dataset's most recent bar, not trading sessions — on an equity or futures chart 20 calendar days is roughly 14 sessions.", display=display.none)
bool mtf_show_raw_labels = input.bool(true, "Show raw HTF labels", group=G_MTF, tooltip="• Show one single-line provenance label on each raw HTF zone.\n• Includes timeframe, direction, kind, lifecycle state, and fill percentage.\n• Visible only when Show TF1 raw zones or Show TF2 raw zones is enabled.", display=display.none)

const string G_CONF = "Confluence Evidence"
bool confl_include_obs = input.bool(false, "Include Order Blocks in confluence", group=G_CONF, tooltip="• Off keeps confluence FVG-only.\n• On permits mixed FVG/OB overlaps.\n• Mixed bands remain static and are labeled mixed.", display=display.none)
float confl_min_atr = input.float(0.05, "Minimum overlap (ATR)", minval=0.0, step=0.01, group=G_CONF, tooltip="• Minimum positive price overlap before two same-direction source zones form a band.\n• Measured as a multiple of the confirmed TF1 timeframe ATR.\n• A fixed-timeframe ATR keeps band qualification stable when the chart timeframe changes.\n• The 0.05 default is permissive; raise it to suppress narrower overlaps.", display=display.none)
int confl_max = input.int(8, "Max confluence bands", minval=1, maxval=20, group=G_CONF, tooltip="• Maximum number of retained confluence records.\n• Older records are removed when the cap is reached.", display=display.none)
bool confl_partial_fill = input.bool(true, "Confluence partial fill", group=G_CONF, tooltip="• For pure FVG overlaps, shrink the active band as confirmed penetration advances into either source gap.\n• Draw-only: band identity and provenance never change.", display=display.none)
bool confl_fill_label = input.bool(true, "Confluence fill % label", group=G_CONF, tooltip="• Report descriptive penetration through the original overlap.\n• It is not a probability.", display=display.none)
bool confl_show_labels = input.bool(true, "Show provenance labels", group=G_CONF, tooltip="• Show source timeframes, overlap count, fill %, lifecycle state, age, and provenance beside each band.\n• Lifecycle percentages: FRESH = 0% fill; TESTED = >0% to <50%; PARTIAL = 50% to <100%; FILLED = 100%.\n• STATIC = mixed FVG/OB evidence without an FVG fill cycle.", display=display.none)
bool confl_show_state = input.bool(true, "Show confluence state", group=G_CONF, tooltip="• Add the lifecycle state to each confluence label.\n• FRESH, TESTED, PARTIAL, FILLED, or STATIC for mixed FVG/OB evidence.", display=display.none)
bool confl_show_age = input.bool(true, "Show confluence age", group=G_CONF, tooltip="• Add the elapsed age to each confluence label.\n• Age starts when the confluence record is first formed.", display=display.none)
string confl_age_mode = input.string("Chart bars", "Confluence age format", options=["HH:MM:SS", "Chart bars"], group=G_CONF, tooltip="• HH:MM:SS — elapsed wall-clock time since formation.\n• Chart bars — number of chart bars since formation.", display=display.none)
float confl_label_gap_atr = input.float(0.75, "Label spacing (ATR)", minval=0.25, maxval=2.0, step=0.05, group=G_CONF, tooltip="• Vertical collision distance for external chart-zone, raw HTF, and confluence labels.\n• Labels closer together than this distance are nudged upward, in a single column, rather than overlapping.", display=display.none)
int confl_label_row_bars = input.int(3, "Confluence label offset (bars)", minval=1, maxval=100, group=G_CONF, tooltip="• How far right of the last bar a confluence label sits.\n• Labels are placed in one column at their own band's midpoint, then nudged upward only when two would collide.\n• Keep this small. The earlier behaviour spread labels across columns up to 500 bars into the future, which put them off-screen at most zoom levels.", display=display.none)
bool confl_show_fresh = input.bool(true, "FRESH", inline="band_states_1", group=G_CONF, tooltip="• Which lifecycle states stay visible.\n• FRESH — the overlap has not been penetrated.\n• TESTED — price entered the overlap but has not reached its midpoint.", display=display.none)
bool confl_show_tested = input.bool(true, "TESTED", inline="band_states_1", group=G_CONF, display=display.none)
bool confl_show_partial = input.bool(true, "PARTIAL", inline="band_states_2", group=G_CONF, tooltip="• PARTIAL — price reached the overlap midpoint but has not fully traversed it.\n• FILLED — the overlap area has been fully traversed. Hiding it preserves the underlying source-zone lifecycle.", display=display.none)
bool confl_show_filled = input.bool(false, "FILLED", inline="band_states_2", group=G_CONF, display=display.none)
color confl_single_color = input.color(color.yellow, "Overlap 1 / 2 / 3+", inline="band_colors", group=G_CONF, tooltip="• Band color by how many active same-direction bands share positive price overlap: exactly one, exactly two, three or more.\n• This is overlap density, not a score or a probability.", display=display.none)
color confl_double_color = input.color(color.orange, "", inline="band_colors", group=G_CONF, display=display.none)
color confl_dense_color = input.color(color.red, "", inline="band_colors", group=G_CONF, display=display.none)

const string G_VIEW = "Visuals"
string visual_size = input.string("Normal", "Label size", options=["Tiny", "Small", "Normal"], group=G_VIEW, tooltip="• Text size for confluence band labels and raw HTF provenance labels.", display=display.none)

// Every input below this line was added after publication. The input-order
// contract is append-only once a script is public, so each one is appended here
// and carries a group name that does not already exist — a group split across
// the declaration order would show two headers for one section.
const string G_CE = "Midpoint (CE)"
bool ce_show = input.bool(true, "Show 50% midpoint", group=G_CE, tooltip="• Draw the consequent-encroachment line at the 50% level of each drawn zone and band.\n• The midpoint is anchored to the original gap and never moves when partial fill shrinks the drawing.\n• It is the level the MITIGATED state already reads from; this only draws it.", display=display.none)
bool ce_show_chart = input.bool(true, "Chart zones", inline="ce_scope", group=G_CE, tooltip="• Which surfaces draw a midpoint line.", display=display.none)
bool ce_show_htf = input.bool(true, "Raw HTF", inline="ce_scope", group=G_CE, display=display.none)
bool ce_show_bands = input.bool(true, "Bands", inline="ce_scope", group=G_CE, display=display.none)
color ce_color = input.color(color.new(color.gray, 25), "Line color / style / width", inline="ce_style", group=G_CE, tooltip="• Appearance of the midpoint line.", display=display.none)
string ce_style_input = input.string("Dashed", "", options=["Solid", "Dashed", "Dotted"], inline="ce_style", group=G_CE, display=display.none)
int ce_width = input.int(1, "", minval=1, maxval=4, inline="ce_style", group=G_CE, display=display.none)

const string G_MTF_STRUCT = "MTF Structure"
int mtf_ob_swing = input.int(5, "HTF swing strength", minval=1, maxval=20, group=G_MTF_STRUCT, tooltip="• Pivot strength the higher-timeframe Order Block engine uses.\n• Separate from the chart Order Blocks setting so that tuning chart blocks cannot silently change which HTF blocks are admitted, and therefore which confluence bands form.", display=display.none)
int mtf_ob_lookback = input.int(10, "HTF OB candle lookback", minval=2, maxval=40, group=G_MTF_STRUCT, tooltip="• How many higher-timeframe bars back the engine searches for the last opposite candle after a confirmed swing break.\n• Separate from the chart Order Blocks setting for the same reason as HTF swing strength.", display=display.none)

const string G_ALERTS = "Alerts"
bool alert_band_formed = input.bool(true, "Band formed", inline="alerts_1", group=G_ALERTS, tooltip="• Which confluence events fire the dynamic alert.\n• All of them evaluate on confirmed bars only, at once-per-bar-close frequency.\n• Create the alert on this script and choose \"Any alert() function call\".", display=display.none)
bool alert_band_entered = input.bool(true, "Price entered", inline="alerts_1", group=G_ALERTS, display=display.none)
bool alert_band_mitigated = input.bool(true, "Reached 50%", inline="alerts_2", group=G_ALERTS, tooltip="• Reached 50% fires once when the band's own fill first reaches its midpoint.\n• Filled fires once when the overlap is fully traversed.", display=display.none)
bool alert_band_filled = input.bool(true, "Filled", inline="alerts_2", group=G_ALERTS, display=display.none)

const string G_DASH = "Dashboard"
bool dash_show = input.bool(true, "Show dashboard", group=G_DASH, tooltip="• A compact read-out of the nearest active confluence band, or the nearest active chart FVG when no band qualifies.\n• Every row is a description of what is on the chart right now. None of it is a signal, score, probability or forecast.", display=display.none)
string dash_position = input.string("Top right", "Position", options=["Top right", "Top left", "Middle right", "Bottom right", "Bottom left"], group=G_DASH, tooltip="• Where the dashboard sits on the chart.\n• Only one drawing may occupy each of the nine positions, so move it if another script already holds this corner.", display=display.none)
string dash_size = input.string("Small", "Text size", options=["Tiny", "Small", "Normal"], group=G_DASH, tooltip="• Text size for every dashboard row.", display=display.none)

// ── Confirmed HTF event engine ────────────────────────────────────────────────
// A one-HTF-bar offset and lookahead_on expose only completed event state from
// the next HTF open. Origin-time de-duplication admits each event once.
// Separate TF1 and TF2 engines preserve independent pivot history at each
// request.security() call site.
f_htf_events_tf1(int swing, int lookback, string gap_mode, float gap_value, float gap_ticks) =>
    float ph = ta.pivothigh(high, swing, swing)[1]
    float pl = ta.pivotlow(low, swing, swing)[1]
    var float last_sh = na
    var float last_sl = na
    var int last_sh_origin = na
    var int last_sl_origin = na
    var int break_up_origin = na
    var int break_dn_origin = na
    if not na(ph)
        last_sh := ph
        last_sh_origin := time[swing + 1]
    if not na(pl)
        last_sl := pl
        last_sl_origin := time[swing + 1]
    float ob_top = na
    float ob_bottom = na
    int ob_time = na
    int ob_event_key = na
    int ob_dir = 0
    if close[1] > last_sh and (na(break_up_origin) or break_up_origin != last_sh_origin)
        break_up_origin := last_sh_origin
        for k = 2 to lookback + 1
            if close[k] < open[k]
                ob_top := high[k]
                ob_bottom := low[k]
                ob_time := time[k]
                ob_event_key := last_sh_origin
                ob_dir := 1
                break
    if close[1] < last_sl and (na(break_dn_origin) or break_dn_origin != last_sl_origin)
        break_dn_origin := last_sl_origin
        for k = 2 to lookback + 1
            if close[k] > open[k]
                ob_top := high[k]
                ob_bottom := low[k]
                ob_time := time[k]
                ob_event_key := last_sl_origin
                ob_dir := -1
                break
    float f_top = na
    float f_bottom = na
    int f_time = na
    int f_dir = 0
    // ATR is shifted with the event data so qualification uses the same
    // completed HTF bar and remains stable after reload.
    float htf_atr = ta.atr(14)[1]
    float htf_min_gap = gap_mode == "ATR" ? htf_atr * gap_value : syminfo.mintick * gap_ticks
    if low[1] > high[3] and low[1] - high[3] >= htf_min_gap
        f_top := low[1]
        f_bottom := high[3]
        f_time := time[2]
        f_dir := 1
    else if high[1] < low[3] and low[3] - high[1] >= htf_min_gap
        f_top := low[3]
        f_bottom := high[1]
        f_time := time[2]
        f_dir := -1
    [f_top, f_bottom, f_time, f_dir, ob_top, ob_bottom, ob_time, ob_event_key, ob_dir, htf_atr]

f_htf_events_tf2(int swing, int lookback, string gap_mode, float gap_value, float gap_ticks) =>
    float ph = ta.pivothigh(high, swing, swing)[1]
    float pl = ta.pivotlow(low, swing, swing)[1]
    var float last_sh = na
    var float last_sl = na
    var int last_sh_origin = na
    var int last_sl_origin = na
    var int break_up_origin = na
    var int break_dn_origin = na
    if not na(ph)
        last_sh := ph
        last_sh_origin := time[swing + 1]
    if not na(pl)
        last_sl := pl
        last_sl_origin := time[swing + 1]
    float ob_top = na
    float ob_bottom = na
    int ob_time = na
    int ob_event_key = na
    int ob_dir = 0
    if close[1] > last_sh and (na(break_up_origin) or break_up_origin != last_sh_origin)
        break_up_origin := last_sh_origin
        for k = 2 to lookback + 1
            if close[k] < open[k]
                ob_top := high[k]
                ob_bottom := low[k]
                ob_time := time[k]
                ob_event_key := last_sh_origin
                ob_dir := 1
                break
    if close[1] < last_sl and (na(break_dn_origin) or break_dn_origin != last_sl_origin)
        break_dn_origin := last_sl_origin
        for k = 2 to lookback + 1
            if close[k] > open[k]
                ob_top := high[k]
                ob_bottom := low[k]
                ob_time := time[k]
                ob_event_key := last_sl_origin
                ob_dir := -1
                break
    float f_top = na
    float f_bottom = na
    int f_time = na
    int f_dir = 0
    // ATR is shifted with the event data so qualification uses the same
    // completed HTF bar and remains stable after reload.
    float htf_atr = ta.atr(14)[1]
    float htf_min_gap = gap_mode == "ATR" ? htf_atr * gap_value : syminfo.mintick * gap_ticks
    if low[1] > high[3] and low[1] - high[3] >= htf_min_gap
        f_top := low[1]
        f_bottom := high[3]
        f_time := time[2]
        f_dir := 1
    else if high[1] < low[3] and low[3] - high[1] >= htf_min_gap
        f_top := low[3]
        f_bottom := high[1]
        f_time := time[2]
        f_dir := -1
    [f_top, f_bottom, f_time, f_dir, ob_top, ob_bottom, ob_time, ob_event_key, ob_dir, htf_atr]

// ── Helpers ───────────────────────────────────────────────────────────────────

f_label_size() =>
    visual_size == "Tiny" ? size.tiny : visual_size == "Normal" ? size.normal : size.small

f_pct_size() =>
    fvg_pct_size == "Large" ? size.large : fvg_pct_size == "Medium" ? size.normal : size.small

f_chart_zone_text_color() =>
    fvg_pct_color == color.white ? chart.fg_color : fvg_pct_color

f_avg_char_px() =>
    float visual_px = visual_size == "Tiny" ? 7.0 : visual_size == "Normal" ? 11.0 : 9.0
    float chart_px = fvg_pct_size == "Large" ? 13.0 : fvg_pct_size == "Medium" ? 11.0 : 9.0
    math.max(visual_px, chart_px)

f_label_row_px() =>
    f_avg_char_px() * LABEL_ROW_HEIGHT_FACTOR

f_plural(int n, string unit) =>
    str.tostring(n) + " " + unit + (n == 1 ? "" : "s")

// Whole fill percentages omit decimals; fractional values use one decimal.
f_fill_text(float pct) =>
    bool whole = pct == math.round(pct)
    (whole ? str.tostring(int(math.round(pct))) : str.tostring(pct, "0.0")) + "% Filled"

f_direction_text(int direction) =>
    direction > 0 ? "Bullish" : "Bearish"

// Shared far-edge tests apply the selected Wick/Close basis to every lifecycle.
f_below(float level) =>
    fvg_confirm == "Close" ? close <= level : low <= level

f_above(float level) =>
    fvg_confirm == "Close" ? close >= level : high >= level

// Zone and band entry reads the same Wick/Close basis as every other lifecycle
// test. It was unconditionally wick-based, so in Close mode a bare wick still
// counted a visit and still fired the band-entry alert while the state text
// beside it correctly refused to advance.
f_inside(float top, float bottom) =>
    fvg_confirm == "Close" ? (close <= top and close >= bottom) : (high >= bottom and low <= top)

f_mid(FvgZone z) =>
    (z.orig_top + z.orig_bottom) * 0.5

// Converts Pine timeframe codes into descriptive provenance text.
f_tf_label(string tf) =>
    string result = tf
    if str.contains(tf, "S")
        string num_str = str.replace_all(tf, "S", "")
        int n = num_str == "" ? 1 : int(str.tonumber(num_str))
        result := f_plural(n, "second")

    else if str.contains(tf, "D")
        string num_str = str.replace_all(tf, "D", "")
        int n = num_str == "" ? 1 : int(str.tonumber(num_str))
        result := f_plural(n, "day")
    else if str.contains(tf, "W")
        string num_str = str.replace_all(tf, "W", "")
        int n = num_str == "" ? 1 : int(str.tonumber(num_str))
        result := f_plural(n, "week")
    else if str.contains(tf, "M")
        string num_str = str.replace_all(tf, "M", "")
        int n = num_str == "" ? 1 : int(str.tonumber(num_str))
        result := f_plural(n, "month")
    else
        int n = int(str.tonumber(tf))
        result := n >= 60 and n % 60 == 0 ? f_plural(n / 60, "hour") : f_plural(n, "minute")
    result

// Resolves the "Auto" comparison-timeframe selection against a fixed ladder of
// standard steps. Auto returns the first ladder step strictly above the chart
// timeframe for slot 1, and the next step up for slot 2, so the script always has
// two valid higher timeframes to compare no matter which chart it is opened on.
// A fixed selection is returned unchanged and is still validated downstream.
// Written as nested ternaries over the argument-less timeframe.in_seconds(),
// deliberately, with no array and no loop. array.get() returns a series value,
// and the result here is fed back into timeframe.in_seconds(), whose argument is
// not series-qualified — an array ladder compiles as a type error. Everything
// below is input- or simple-qualified, so the result is too. The ladder steps are
// the standard chart timeframes in seconds: 5m 300, 15m 900, 30m 1800, 60m 3600,
// 240m 14400, 1D 86400, 1W 604800, 1M 2592000, 3M 7776000.
//
// The ladder runs past "M" to "3M" and "12M": stopping at "M" would resolve both
// slots to "M" on a weekly chart, a duplicate selection that leaves the script at
// default settings showing the duplicate-timeframe warning with no confluence at
// all. The timeframes page gives the month multiplier range as 1 to 12, so "3M"
// and "12M" are both valid timeframe strings.
f_resolve_tf(simple string selection, simple int slot) =>
    float chart_seconds = timeframe.in_seconds()
    string auto_first = chart_seconds < 300 ? "5" : chart_seconds < 900 ? "15" :
      chart_seconds < 1800 ? "30" : chart_seconds < 3600 ? "60" :
      chart_seconds < 14400 ? "240" : chart_seconds < 86400 ? "D" :
      chart_seconds < 604800 ? "W" : chart_seconds < 2592000 ? "M" :
      chart_seconds < 7776000 ? "3M" : "12M"
    string auto_second = chart_seconds < 300 ? "15" : chart_seconds < 900 ? "30" :
      chart_seconds < 1800 ? "60" : chart_seconds < 3600 ? "240" :
      chart_seconds < 14400 ? "D" : chart_seconds < 86400 ? "W" :
      chart_seconds < 604800 ? "M" : chart_seconds < 2592000 ? "3M" : "12M"
    selection != "Auto" ? selection : slot == 1 ? auto_first : auto_second

f_line_style(string name) =>
    name == "Solid" ? line.style_solid : name == "Dotted" ? line.style_dotted : line.style_dashed

f_dash_position(string name) =>
    switch name
        "Top left" => position.top_left
        "Middle right" => position.middle_right
        "Bottom right" => position.bottom_right
        "Bottom left" => position.bottom_left
        => position.top_right

f_dash_size(string name) =>
    name == "Tiny" ? size.tiny : name == "Normal" ? size.normal : size.small

// Spacer padding, by position: Top left sits behind the OHLC header and the
// bid/ask boxes, Bottom right/left crowd the price axis and the watermark.
// Top right and Middle right already clear every collision at zero padding.
f_dash_pad_top(string name) =>
    name == "Top left" ? 20.0 : 0.0

f_dash_pad_bottom(string name) =>
    name == "Bottom right" or name == "Bottom left" ? 10.0 : 0.0

// The width floor matches f_band_fill_percent's. An Order Block sourced from a
// bar whose high equals its low has zero height, and the unguarded division was
// 0/0 at birth — the label rendered NaN rather than 0%.
f_fill(FvgZone z) =>
    float width = math.max(syminfo.mintick, z.orig_top - z.orig_bottom)
    float raw = z.direction > 0 ? (z.orig_top - z.pen) / width : (z.pen - z.orig_bottom) / width
    math.max(0.0, math.min(100.0, raw * 100.0))

f_live_top(FvgZone z) =>
    z.direction > 0 ? math.max(z.orig_bottom, z.pen) : z.orig_top

f_live_bottom(FvgZone z) =>
    z.direction < 0 ? math.min(z.orig_top, z.pen) : z.orig_bottom

f_overlap_top(FvgZone a, FvgZone b) =>
    // Pair identity uses immutable source geometry, independent of display shrink.
    math.min(a.orig_top, b.orig_top)

f_overlap_bottom(FvgZone a, FvgZone b) =>
    math.max(a.orig_bottom, b.orig_bottom)

f_state_rank(string s) =>
    s == "FRESH" ? 0 : s == "TESTED" ? 1 : s == "MITIGATED" ? 2 : s == "FILLED" ? 3 : 4

// ── State ─────────────────────────────────────────────────────────────────────
var array<FvgZone> fvg_bull = array.new<FvgZone>()
var array<FvgZone> fvg_bear = array.new<FvgZone>()
var array<FvgZone> ob_bull = array.new<FvgZone>()
var array<FvgZone> ob_bear = array.new<FvgZone>()
var array<FvgZone> htf1_fvg = array.new<FvgZone>()
var array<FvgZone> htf1_ob = array.new<FvgZone>()
var array<FvgZone> htf2_fvg = array.new<FvgZone>()
var array<FvgZone> htf2_ob = array.new<FvgZone>()
var array<ConfluenceBand> confluences = array.new<ConfluenceBand>()
var label mtf_warning_label = na
// One table, created once, positioned from the input in its own var initialiser.
// There is no later set_position call: the platform restarts the script when an
// input changes, so the initialiser re-runs with the new corner.
const int DASH_ROWS = 7
// Two extra rows carry position-conditional spacer padding so the table clears
// chart chrome and the watermark at every offered Position.
const int DASH_TABLE_ROWS = DASH_ROWS + 2
var table dashboard = table.new(f_dash_position(dash_position), 2, DASH_TABLE_ROWS, bgcolor=color.new(color.black, 82), frame_color=color.new(color.gray, 60), frame_width=1, border_color=color.new(color.gray, 80), border_width=1)
var int last_htf1_fvg = na
var int last_htf1_ob_event = na
var int last_htf2_fvg = na
var int last_htf2_ob_event = na
var string last_chart_tf = ""
var string last_mtf_config = ""

f_zone_box_count(array<FvgZone> zones) =>
    int count = 0
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            FvgZone z = array.get(zones, i)
            if not na(z.bx)
                count += 1
    count

f_zone_label_count(array<FvgZone> zones) =>
    int count = 0
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            FvgZone z = array.get(zones, i)
            if not na(z.pct_lbl)
                count += 1
    count

f_band_box_count() =>
    int count = 0
    if array.size(confluences) > 0
        for i = 0 to array.size(confluences) - 1
            ConfluenceBand b = array.get(confluences, i)
            if not na(b.bx)
                count += 1
    count

f_band_label_count() =>
    int count = 0
    if array.size(confluences) > 0
        for i = 0 to array.size(confluences) - 1
            ConfluenceBand b = array.get(confluences, i)
            if not na(b.lbl)
                count += 1
    count

f_zone_line_count(array<FvgZone> zones) =>
    int count = 0
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            FvgZone z = array.get(zones, i)
            if not na(z.ce_ln)
                count += 1
    count

f_band_line_count() =>
    int count = 0
    if array.size(confluences) > 0
        for i = 0 to array.size(confluences) - 1
            ConfluenceBand b = array.get(confluences, i)
            if not na(b.ce_ln)
                count += 1
    count

f_box_total() =>
    f_zone_box_count(fvg_bull) + f_zone_box_count(fvg_bear) + f_zone_box_count(ob_bull) + f_zone_box_count(ob_bear) + f_zone_box_count(htf1_fvg) + f_zone_box_count(htf1_ob) + f_zone_box_count(htf2_fvg) + f_zone_box_count(htf2_ob) + f_band_box_count()

f_label_total() =>
    f_zone_label_count(fvg_bull) + f_zone_label_count(fvg_bear) + f_zone_label_count(ob_bull) + f_zone_label_count(ob_bear) + f_zone_label_count(htf1_fvg) + f_zone_label_count(htf1_ob) + f_zone_label_count(htf2_fvg) + f_zone_label_count(htf2_ob) + f_band_label_count() + (not na(mtf_warning_label) ? 1 : 0)

f_line_total() =>
    f_zone_line_count(fvg_bull) + f_zone_line_count(fvg_bear) + f_zone_line_count(ob_bull) + f_zone_line_count(ob_bear) + f_zone_line_count(htf1_fvg) + f_zone_line_count(htf1_ob) + f_zone_line_count(htf2_fvg) + f_zone_line_count(htf2_ob) + f_band_line_count()

f_dash_row(int row, string key, string value) =>
    string cell_size = f_dash_size(dash_size)
    int r = row + 1
    table.cell(dashboard, 0, r, key, text_color=color.new(chart.fg_color, 35), text_size=cell_size, text_halign=text.align_left)
    table.cell(dashboard, 1, r, value, text_color=chart.fg_color, text_size=cell_size, text_halign=text.align_right)
    0

f_dash_spacer(int row, float pad_pct) =>
    table.cell(dashboard, 0, row, "", height=pad_pct)
    table.cell(dashboard, 1, row, "", height=pad_pct)
    0

f_delete_zone(FvgZone z) =>
    if not na(z.bx)
        box.delete(z.bx)
    if not na(z.pct_lbl)
        label.delete(z.pct_lbl)
    if not na(z.ce_ln)
        line.delete(z.ce_ln)
    0

f_delete_band(ConfluenceBand b) =>
    if not na(b.bx)
        box.delete(b.bx)
    if not na(b.lbl)
        label.delete(b.lbl)
    if not na(b.ce_ln)
        line.delete(b.ce_ln)
    0

f_prune_zones(array<FvgZone> zones, int keep) =>
    while array.size(zones) > keep
        FvgZone old = array.shift(zones)
        f_delete_zone(old)
    0

f_prune_zones_before(array<FvgZone> zones, int cutoff) =>
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            FvgZone z = array.get(zones, i)
            if z.origin < cutoff
                f_delete_zone(z)
                array.remove(zones, i)
    0

f_clear_zones(array<FvgZone> zones) =>
    while array.size(zones) > 0
        FvgZone old = array.pop(zones)
        f_delete_zone(old)
    0

f_clear_confluences() =>
    while array.size(confluences) > 0
        ConfluenceBand old = array.pop(confluences)
        f_delete_band(old)
    0

f_find_band(int ka, int kb, string ta, string tb, string source_a, string source_b, string kind_a, string kind_b) =>
    int found = -1
    if array.size(confluences) > 0
        for i = 0 to array.size(confluences) - 1
            ConfluenceBand b = array.get(confluences, i)
            if b.key_a == ka and b.key_b == kb and b.tf_a == ta and b.tf_b == tb and
              b.source_a == source_a and b.source_b == source_b and b.kind_a == kind_a and b.kind_b == kind_b
                found := i
                break
    found

f_band_state(FvgZone a, FvgZone b, bool mixed) =>
    mixed ? "STATIC" : (f_state_rank(a.state) >= f_state_rank(b.state) ? a.state : b.state)

f_band_fill_percent(ConfluenceBand b) =>
    bool pure_fvg = b.kind_a == "FVG" and b.kind_b == "FVG"
    float covered = b.orig_top - b.fill_top + b.fill_bottom - b.orig_bottom
    float width = math.max(syminfo.mintick, b.orig_top - b.orig_bottom)
    pure_fvg ? math.max(0.0, math.min(100.0, covered / width * 100.0)) : 0.0

f_band_fully_filled(ConfluenceBand b) =>
    b.kind_a == "FVG" and b.kind_b == "FVG" and f_band_fill_percent(b) >= 100.0

f_band_status(ConfluenceBand b) =>
    // Pure FVG confluence status follows the overlap's own penetration. Mixed
    // FVG/OB evidence stays static through its life because OBs have no FVG fill
    // cycle, but it still reaches FILLED on full traversal like any other band.
    string result = "STATIC"
    if b.state == "FILLED"
        result := "FILLED"
    else if b.kind_a == "FVG" and b.kind_b == "FVG"
        float pct = f_band_fill_percent(b)
        result := pct >= 100.0 ? "FILLED" : pct >= 50.0 ? "PARTIAL" : pct > 0.0 ? "TESTED" : "FRESH"
    result

f_band_status_visible(ConfluenceBand b) =>
    string status = f_band_status(b)
    bool visible = true
    if status == "FRESH"
        visible := confl_show_fresh
    else if status == "TESTED"
        visible := confl_show_tested
    else if status == "PARTIAL"
        visible := confl_show_partial
    else if status == "FILLED"
        visible := confl_show_filled
    visible

f_band_age_text(ConfluenceBand b) =>
    if confl_age_mode == "Chart bars"
        str.tostring(math.max(0, bar_index - b.born_bar)) + " bars"
    else
        int elapsed_seconds = int(math.max(0.0, (time - b.born_time) / 1000.0))
        int hours = int(elapsed_seconds / 3600)
        int minutes = int(elapsed_seconds / 60) % 60
        int seconds = elapsed_seconds % 60
        str.tostring(hours, "00") + ":" + str.tostring(minutes, "00") + ":" + str.tostring(seconds, "00")

f_source_allowed(FvgZone z) =>
    z.state != "FILLED" and (z.kind == "FVG" or confl_include_obs)

// Dynamic alert text. Every call site sits inside the confirmed-bar mutation
// path, so a fired message always describes a closed bar.
f_band_alert_text(ConfluenceBand b, string event) =>
    "FVG Confluence [AFD] | " + event + " | " + syminfo.ticker + " " + timeframe.period + " | " +
      f_direction_text(b.direction) + " " + f_tf_label(b.tf_a) + " x " + f_tf_label(b.tf_b) + " " +
      b.kind_a + "/" + b.kind_b + " | " + str.tostring(b.orig_bottom, format.mintick) + " to " +
      str.tostring(b.orig_top, format.mintick)

// Updates or creates one persistent provenance record for every qualifying pair.
f_add_pairs(array<FvgZone> left, array<FvgZone> right, array<int> seen, int now_bar, int now_time, float min_width,
     string source_a, string source_b) =>
    if array.size(left) > 0 and array.size(right) > 0
        for i = 0 to array.size(left) - 1
            FvgZone a = array.get(left, i)
            for j = 0 to array.size(right) - 1
                FvgZone b = array.get(right, j)
                bool same_direction = a.direction == b.direction
                bool both_fvg = a.kind == "FVG" and b.kind == "FVG"
                bool mixed = not both_fvg
                float top = f_overlap_top(a, b)
                float bottom = f_overlap_bottom(a, b)
                float live_top = both_fvg ? math.min(f_live_top(a), f_live_top(b)) : top
                float live_bottom = both_fvg ? math.max(f_live_bottom(a), f_live_bottom(b)) : bottom
                // A fully penetrated overlap collapses at its far edge.
                if both_fvg
                    if a.direction > 0
                        live_top := math.max(live_top, live_bottom)
                    else
                        live_bottom := math.min(live_bottom, live_top)
                int idx = f_find_band(a.event_key, b.event_key, a.tf, b.tf, source_a, source_b, a.kind, b.kind)
                bool sources_active = f_source_allowed(a) and f_source_allowed(b)
                bool supported_pair = same_direction and (both_fvg or confl_include_obs)
                // ATR qualification is a birth rule. An existing band's immutable
                // geometry and stored threshold remain qualified even when TF1 ATR
                // later changes; only a new pair must clear the current threshold.
                bool qualifies = supported_pair and (idx >= 0 or (sources_active and (top - bottom) >= min_width))
                if qualifies
                    // New bands are admitted unconditionally; a FIFO prune after the
                    // stale sweep trims the oldest records back to confl_max.
                    bool is_new = idx < 0
                    if is_new
                        ConfluenceBand fresh = ConfluenceBand.new(a.event_key, b.event_key, now_bar, now_time, top, bottom, top, bottom, live_top, live_bottom,
                          a.direction, a.tf, b.tf, source_a, source_b, a.kind, b.kind, f_band_state(a, b, mixed), "", 0, 0, false, na, na, na)
                        array.push(confluences, fresh)
                        idx := array.size(confluences) - 1
                    if idx >= 0
                        ConfluenceBand band = array.get(confluences, idx)
                        // Birth geometry remains immutable; fill_* tracks penetration
                        // for the optional draw-only shrink.
                        band.fill_top := both_fvg ? live_top : band.fill_top
                        band.fill_bottom := both_fvg ? live_bottom : band.fill_bottom
                        band.direction := a.direction
                        if band.state != "FILLED"
                            band.state := f_band_state(a, b, mixed)
                        bool inside = f_inside(band.top, band.bottom)
                        bool entered = inside and not band.was_inside
                        if entered
                            band.visits += 1
                        band.was_inside := inside
                        // Complete traversal is the terminal FILLED state for every
                        // band. A pure FVG band reaches it through its own fill
                        // percentage; a mixed FVG/OB band reaches it on far-edge
                        // traversal.
                        bool fully_filled = both_fvg ? f_band_fully_filled(band) :
                          (a.direction > 0 ? f_below(band.orig_bottom) : f_above(band.orig_top))
                        if fully_filled and band.state != "FILLED"
                            band.breaks += 1
                            band.state := "FILLED"
                        string status_now = f_band_status(band)
                        // One alert per transition. Every branch is inside the
                        // confirmed-bar path and fires at bar close.
                        if alert_band_formed and is_new
                            alert(f_band_alert_text(band, "Band formed"), alert.freq_once_per_bar_close)
                        if alert_band_entered and entered and not is_new
                            alert(f_band_alert_text(band, "Price entered band"), alert.freq_once_per_bar_close)
                        if alert_band_mitigated and status_now == "PARTIAL" and band.prev_status != "PARTIAL"
                            alert(f_band_alert_text(band, "Band reached 50%"), alert.freq_once_per_bar_close)
                        if alert_band_filled and status_now == "FILLED" and band.prev_status != "FILLED"
                            alert(f_band_alert_text(band, "Band filled"), alert.freq_once_per_bar_close)
                        band.prev_status := status_now
                        array.set(confluences, idx, band)
                        // Visibility filters do not alter persistent band identity.
                        array.push(seen, idx)
    0

float atr = ta.atr(14)
// Visible-range re-execution supplies a presentation-only price-span proxy for
// vertical label spacing.
var float visible_price_high = na
var float visible_price_low = na
bool in_visible_time_range = not na(chart.left_visible_bar_time) and not na(chart.right_visible_bar_time) and
  time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
if in_visible_time_range
    visible_price_high := na(visible_price_high) ? high : math.max(visible_price_high, high)
    visible_price_low := na(visible_price_low) ? low : math.min(visible_price_low, low)

float min_gap = fvg_min_mode == "ATR" ? atr * fvg_min_value : syminfo.mintick * fvg_min_ticks
int mtf_cutoff = last_bar_time - mtf_days * 86400000
float chart_tf_seconds = timeframe.in_seconds()
// "Auto" resolves against the chart before anything downstream reads a timeframe,
// so validation, the warning, the security calls and the context key all see the
// same two strings.
string mtf_tf1 = f_resolve_tf(mtf_tf1_input, 1)
string mtf_tf2 = f_resolve_tf(mtf_tf2_input, 2)
float tf1_seconds = timeframe.in_seconds(mtf_tf1)
float tf2_seconds = timeframe.in_seconds(mtf_tf2)

// A comparison timeframe contributes only when it is above the chart timeframe.
bool tf1_valid = tf1_seconds > chart_tf_seconds
bool tf2_valid = tf2_seconds > chart_tf_seconds
// Confluence uses only selected, valid TF1 and TF2 sources. Chart-timeframe
// zones remain standalone drawings.
bool src_tf1_active = src_tf1 and tf1_valid
bool src_tf2_active = src_tf2 and tf2_valid
bool duplicate_timeframes = tf1_seconds == tf2_seconds
bool pair_tf1_tf2 = src_tf1_active and src_tf2_active and not duplicate_timeframes
bool mtf_path_ready = pair_tf1_tf2
// The HTF engines take their own structure settings. Sharing the chart Order
// Blocks pair meant tuning a chart-only control silently changed which HTF blocks
// were admitted, and therefore which confluence bands formed.
[tf1_ft, tf1_fb, tf1_time, tf1_dir, tf1_ot, tf1_ob, tf1_otime, tf1_oevent, tf1_odir, tf1_atr] = request.security(syminfo.tickerid, mtf_tf1,
     f_htf_events_tf1(mtf_ob_swing, mtf_ob_lookback, fvg_min_mode, fvg_min_value, fvg_min_ticks), lookahead=barmerge.lookahead_on)
[tf2_ft, tf2_fb, tf2_time, tf2_dir, tf2_ot, tf2_ob, tf2_otime, tf2_oevent, tf2_odir, tf2_atr] = request.security(syminfo.tickerid, mtf_tf2,
     f_htf_events_tf2(mtf_ob_swing, mtf_ob_lookback, fvg_min_mode, fvg_min_value, fvg_min_ticks), lookahead=barmerge.lookahead_on)

// The raw-zone toggles and their type selectors join the context key because they
// now decide whether HTF Order Blocks are admitted at all, not just whether they
// are drawn.
//
// Built once with var. Every term is an input or a timeframe string, and the
// platform restarts the script from the first bar whenever either changes, so the
// key cannot differ from one bar to the next within a run — the comparison below
// can only be unequal on the first confirmed bar. Rebuilding it from a dozen
// string operations on every bar bought nothing.
var string mtf_config = (mtf_enable ? "1" : "0") + "|" + mtf_tf1 + "|" + mtf_tf2 + "|" +
  (src_tf1 ? "1" : "0") + "|" + (src_tf2 ? "1" : "0") + "|" + (confl_include_obs ? "1" : "0") + "|" +
  (mtf_show_raw_tf1 ? "1" : "0") + "|" + (mtf_show_raw_tf2 ? "1" : "0") + "|" +
  mtf_raw_tf1_kind + "|" + mtf_raw_tf2_kind + "|" +
  str.tostring(mtf_ob_swing) + "|" + str.tostring(mtf_ob_lookback)
bool mtf_context_changed = last_chart_tf != timeframe.period or last_mtf_config != mtf_config
string mtf_warning_text = ""
if mtf_enable
    if not tf1_valid
        mtf_warning_text := "TF1 must be higher than the chart timeframe."
    if not tf2_valid
        mtf_warning_text := mtf_warning_text + (mtf_warning_text == "" ? "" : "\n") + "TF2 must be higher than the chart timeframe."
    if duplicate_timeframes
        mtf_warning_text := mtf_warning_text + (mtf_warning_text == "" ? "" : "\n") + "TF1 and TF2 must be different."

f_band_source_active(string source) =>
    source == "TF1" ? src_tf1 and tf1_valid : source == "TF2" ? src_tf2 and tf2_valid : false

f_band_pair_active(ConfluenceBand b) =>
    mtf_enable and mtf_path_ready and f_band_source_active(b.source_a) and f_band_source_active(b.source_b) and
      (confl_include_obs or (b.kind_a == "FVG" and b.kind_b == "FVG"))

// One layout pass resolves visible chart, raw HTF, and confluence labels.
//
// Every label keeps its own horizontal offset and stays in one column. Collision
// is resolved by nudging upward only. A multi-column grid was tried and rejected:
// it put labels up to 500 bars into the future, which hid all label text when the
// chart was zoomed out (column pitch grew past the future-bar limit until only
// one column fitted and the tier budget was exhausted) and pushed labels
// off-screen to the right when the chart was zoomed in. There was no zoom level
// at which every label was both legible and on-screen.
f_collect_zone_labels(array<FvgZone> zones, int scope, int label_offset,
     array<float> mids, array<int> ids, array<label> labels, array<int> offsets) =>
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            FvgZone z = array.get(zones, i)
            if not na(z.pct_lbl)
                array.push(mids, label.get_y(z.pct_lbl))
                array.push(ids, scope * 1000 + i)
                array.push(labels, z.pct_lbl)
                array.push(offsets, label_offset)
    0

f_layout_visible_labels() =>
    array<float> mids = array.new_float()
    array<int> ids = array.new_int()
    array<label> labels = array.new<label>()
    array<int> offsets = array.new_int()

    f_collect_zone_labels(fvg_bull, 1, fvg_pct_offset, mids, ids, labels, offsets)
    f_collect_zone_labels(fvg_bear, 2, fvg_pct_offset, mids, ids, labels, offsets)
    f_collect_zone_labels(ob_bull, 3, fvg_pct_offset, mids, ids, labels, offsets)
    f_collect_zone_labels(ob_bear, 4, fvg_pct_offset, mids, ids, labels, offsets)
    f_collect_zone_labels(htf1_fvg, 5, fvg_pct_offset, mids, ids, labels, offsets)
    f_collect_zone_labels(htf1_ob, 6, fvg_pct_offset, mids, ids, labels, offsets)
    f_collect_zone_labels(htf2_fvg, 7, fvg_pct_offset, mids, ids, labels, offsets)
    f_collect_zone_labels(htf2_ob, 8, fvg_pct_offset, mids, ids, labels, offsets)
    if array.size(confluences) > 0
        for i = 0 to array.size(confluences) - 1
            ConfluenceBand b = array.get(confluences, i)
            if not na(b.lbl)
                array.push(mids, label.get_y(b.lbl))
                array.push(ids, 9000 + i)
                array.push(labels, b.lbl)
                array.push(offsets, confl_label_row_bars)

    int count = array.size(mids)
    if count > 1
        // A bounded selection sort makes placement deterministic. Ties resolve on
        // the synthetic id so a reordered input set produces identical placement.
        for i = 0 to count - 2
            int lowest = i
            for j = i + 1 to count - 1
                float candidate_mid = array.get(mids, j)
                float lowest_mid = array.get(mids, lowest)
                int candidate_id = array.get(ids, j)
                int lowest_id = array.get(ids, lowest)
                if candidate_mid < lowest_mid or (candidate_mid == lowest_mid and candidate_id < lowest_id)
                    lowest := j
            if lowest != i
                float swap_mid = array.get(mids, i)
                int swap_id = array.get(ids, i)
                label swap_label = array.get(labels, i)
                int swap_offset = array.get(offsets, i)
                array.set(mids, i, array.get(mids, lowest))
                array.set(ids, i, array.get(ids, lowest))
                array.set(labels, i, array.get(labels, lowest))
                array.set(offsets, i, array.get(offsets, lowest))
                array.set(mids, lowest, swap_mid)
                array.set(ids, lowest, swap_id)
                array.set(labels, lowest, swap_label)
                array.set(offsets, lowest, swap_offset)

    // Vertical spacing takes the larger of an ATR floor and a viewport-derived
    // row-height estimate. Both are presentation-only and affect no calculation.
    if count > 0
        float atr_label_gap = math.max(syminfo.mintick * 40.0, nz(atr, syminfo.mintick * 40.0) * confl_label_gap_atr)
        float visible_price_span = not na(visible_price_high) and not na(visible_price_low) ? visible_price_high - visible_price_low : 0.0
        float viewport_label_gap = visible_price_span > 0 ? visible_price_span * f_label_row_px() / LABEL_REF_HEIGHT_PX : 0.0
        float label_gap = math.max(atr_label_gap, viewport_label_gap)

        // Highest price already occupied in the single column; na while empty.
        float column_top = na

        for i = 0 to count - 1
            float own_y = array.get(mids, i)
            float placed_y = na(column_top) ? own_y : math.max(own_y, column_top + label_gap)
            label current = array.get(labels, i)
            int own_offset = math.min(array.get(offsets, i), CONFL_LABEL_MAX_FUTURE_BARS)
            if placed_y <= own_y + label_gap * (LABEL_MAX_TIERS - 1)
                column_top := placed_y
                label.set_xy(current, bar_index + own_offset, placed_y)
                label.set_style(current, label.style_label_left)
            else
                // Excess labels retain their zone anchor while their text is
                // hidden. The style is hidden with the text: raw HTF and band
                // labels carry a 70%-opaque background, so clearing the text alone
                // left an empty coloured shape stacked at exactly the crowded
                // price the tier ceiling exists to unclutter. label.style_none
                // renders text with no surrounding shape.
                label.set_xy(current, bar_index + own_offset, own_y)
                label.set_text(current, "")
                label.set_style(current, label.style_none)
    0

// Count active same-direction bands with positive price overlap. This is overlap
// density, not a score, and records may share a source zone.
f_band_overlap_count(int target_idx) =>
    int count = 0
    if array.size(confluences) > 0
        ConfluenceBand target = array.get(confluences, target_idx)
        for j = 0 to array.size(confluences) - 1
            if j != target_idx
                ConfluenceBand other = array.get(confluences, j)
                float shared_top = math.min(target.orig_top, other.orig_top)
                float shared_bottom = math.max(target.orig_bottom, other.orig_bottom)
                if other.direction == target.direction and f_band_pair_active(other) and
                  f_band_status_visible(other) and shared_top - shared_bottom > 0
                    count += 1
    count + 1

bool new_fvg = false
bool new_ob = false
float swing_high = ta.pivothigh(high, ob_swing, ob_swing)
float swing_low = ta.pivotlow(low, ob_swing, ob_swing)

// ── Chart FVG lifecycle ───────────────────────────────────────────────────────
f_update_fvg_array(array<FvgZone> zones) =>
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            FvgZone z = array.get(zones, i)
            if z.state == "FILLED"
                array.set(zones, i, z)
            else
                bool inside = f_inside(z.top, z.bottom)
                if inside and not z.was_inside
                    z.visits += 1
                z.was_inside := inside
                // Invalidation honors the Mitigation / fill rule: in Wick mode a wick
                // through the far edge fully fills the gap; in Close mode the close
                // must cross it.
                bool invalid = z.direction > 0 ? f_below(z.orig_bottom) : f_above(z.orig_top)
                bool touched = fvg_confirm == "Close" ? (z.direction > 0 ? close <= z.orig_top : close >= z.orig_bottom) : inside
                bool mid_reached = z.direction > 0 ? f_below(f_mid(z)) : f_above(f_mid(z))
                // Penetration, fill %, shrink geometry, and the state machine all read
                // from the same price basis. In Close mode a bare wick does not
                // advance penetration; only the close counts.
                float pen_up = fvg_confirm == "Close" ? close : low
                float pen_dn = fvg_confirm == "Close" ? close : high
                if z.direction > 0
                    z.pen := math.min(z.pen, pen_up)
                    if fvg_shrink
                        z.top := math.max(z.orig_bottom, z.pen)
                else
                    z.pen := math.max(z.pen, pen_dn)
                    if fvg_shrink
                        z.bottom := math.min(z.orig_top, z.pen)
                if invalid
                    z.breaks += 1
                    z.state := "FILLED"
                    if not fvg_keep_filled
                        f_delete_zone(z)
                        array.remove(zones, i)
                    else
                        array.set(zones, i, z)
                else
                    // FVG states advance monotonically.
                    string next_state = mid_reached ? "MITIGATED" : touched ? "TESTED" : z.state
                    if f_state_rank(next_state) > f_state_rank(z.state)
                        z.state := next_state
                    array.set(zones, i, z)
    0

// ── Chart OB lifecycle ─────────────────────────────────────────────────────────
f_update_ob_array(array<FvgZone> zones) =>
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            FvgZone z = array.get(zones, i)
            bool inside = f_inside(z.top, z.bottom)
            if inside and not z.was_inside
                z.visits += 1
            z.was_inside := inside
            // Penetration reads on the same Wick/Close basis as FVGs, so OB and
            // breaker fill % stays comparable to the FVG fill %.
            float ob_pen_up = fvg_confirm == "Close" ? close : low
            float ob_pen_dn = fvg_confirm == "Close" ? close : high
            if z.state == "BREAKER"
                if z.direction > 0
                    z.pen := math.min(z.pen, ob_pen_up)
                    if ob_partial_fill
                        z.top := math.max(z.orig_bottom, z.pen)
                else
                    z.pen := math.max(z.pen, ob_pen_dn)
                    if ob_partial_fill
                        z.bottom := math.min(z.orig_top, z.pen)
                array.set(zones, i, z)
            else
                bool crossed = fvg_confirm == "Close" ? (z.direction > 0 ? close < z.bottom : close > z.top) :
                  (z.direction > 0 ? low <= z.bottom : high >= z.top)
                if crossed
                    z.breaks += 1
                    if ob_show_breakers
                        z.state := "BREAKER"
                        z.direction := -z.direction
                        // Breaker conversion restores source bounds and restarts fill
                        // measurement from the new direction's near edge.
                        z.top := z.orig_top
                        z.bottom := z.orig_bottom
                        z.pen := z.direction > 0 ? z.orig_top : z.orig_bottom
                        array.set(zones, i, z)
                    else
                        f_delete_zone(z)
                        array.remove(zones, i)
                else
                    if z.direction > 0
                        z.pen := math.min(z.pen, ob_pen_up)
                        if ob_partial_fill
                            z.top := math.max(z.orig_bottom, z.pen)
                    else
                        z.pen := math.max(z.pen, ob_pen_dn)
                        if ob_partial_fill
                            z.bottom := math.min(z.orig_top, z.pen)
                    bool ob_touched = fvg_confirm == "Close" ? (z.direction > 0 ? close <= z.top : close >= z.bottom) : inside
                    bool ob_mid_reached = z.direction > 0 ? f_below(f_mid(z)) : f_above(f_mid(z))
                    // OB states advance monotonically.
                    if ob_touched
                        string next_ob_state = ob_mid_reached ? "MITIGATED" : "TESTED"
                        if f_state_rank(next_ob_state) > f_state_rank(z.state)
                            z.state := next_ob_state
                    array.set(zones, i, z)
    0

// ── Confirmed mutation ────────────────────────────────────────────────────────
if barstate.isconfirmed
    // MTF context changes rebuild persistent state on confirmed bars.
    if mtf_context_changed
        f_clear_zones(htf1_fvg)
        f_clear_zones(htf1_ob)
        f_clear_zones(htf2_fvg)
        f_clear_zones(htf2_ob)
        f_clear_confluences()
        last_htf1_fvg := na
        last_htf1_ob_event := na
        last_htf2_fvg := na
        last_htf2_ob_event := na
        last_chart_tf := timeframe.period
        last_mtf_config := mtf_config

    // The rolling day window is anchored to the dataset's latest bar.
    f_prune_zones_before(htf1_fvg, mtf_cutoff)
    f_prune_zones_before(htf1_ob, mtf_cutoff)
    f_prune_zones_before(htf2_fvg, mtf_cutoff)
    f_prune_zones_before(htf2_ob, mtf_cutoff)

    f_update_fvg_array(fvg_bull)
    f_update_fvg_array(fvg_bear)
    f_update_ob_array(ob_bull)
    f_update_ob_array(ob_bear)

    // Object counts are refreshed after lifecycle pruning.
    box_count := f_box_total()
    label_count := f_label_total()

    if fvg_enable and low > high[2] and low - high[2] >= min_gap
        box bx = f_new_index_box(bar_index - 2, low, bar_index, high[2], color.new(bull_fvg_color, 20), bull_fvg_color)
        FvgZone z = FvgZone.new(low, high[2], low, high[2], low, time[2], time[2], bar_index, 1, "FVG", "Chart", "FRESH", 0, 0, false, bx, na, na)
        array.push(fvg_bull, z)
        box_count += not na(bx) ? 1 : 0
        new_fvg := true
        if array.size(fvg_bull) > fvg_max
            FvgZone old = array.shift(fvg_bull)
            f_delete_zone(old)
            box_count -= not na(old.bx) ? 1 : 0
            label_count -= not na(old.pct_lbl) ? 1 : 0
    if fvg_enable and high < low[2] and low[2] - high >= min_gap
        box bx = f_new_index_box(bar_index - 2, low[2], bar_index, high, color.new(bear_fvg_color, 20), bear_fvg_color)
        FvgZone z = FvgZone.new(low[2], high, low[2], high, high, time[2], time[2], bar_index, -1, "FVG", "Chart", "FRESH", 0, 0, false, bx, na, na)
        array.push(fvg_bear, z)
        box_count += not na(bx) ? 1 : 0
        new_fvg := true
        if array.size(fvg_bear) > fvg_max
            FvgZone old = array.shift(fvg_bear)
            f_delete_zone(old)
            box_count -= not na(old.bx) ? 1 : 0
            label_count -= not na(old.pct_lbl) ? 1 : 0

    // Minimal chart structure check solely to anchor OBs.
    var float last_high = na
    var float last_low = na
    var int last_high_origin = na
    var int last_low_origin = na
    var int fired_high_origin = na
    var int fired_low_origin = na
    if not na(swing_high)
        last_high := swing_high
        last_high_origin := time[ob_swing]
    if not na(swing_low)
        last_low := swing_low
        last_low_origin := time[ob_swing]
    if ob_enable and not na(last_high) and close > last_high and (na(fired_high_origin) or fired_high_origin != last_high_origin)
        fired_high_origin := last_high_origin
        int found = -1
        for k = 1 to ob_lookback
            if close[k] < open[k]
                found := k
                break
        if found > 0
            box bx = f_new_index_box(bar_index - found, high[found], bar_index, low[found], color.new(bull_ob_color, 10), bull_ob_color)
            array.push(ob_bull, FvgZone.new(high[found], low[found], high[found], low[found], high[found], time[found], last_high_origin, bar_index, 1, "OB", "Chart", "FRESH", 0, 0, false, bx, na, na))
            box_count += not na(bx) ? 1 : 0
            new_ob := true
            if array.size(ob_bull) > ob_max
                FvgZone old = array.shift(ob_bull)
                f_delete_zone(old)
                box_count -= not na(old.bx) ? 1 : 0
    if ob_enable and not na(last_low) and close < last_low and (na(fired_low_origin) or fired_low_origin != last_low_origin)
        fired_low_origin := last_low_origin
        int found = -1
        for k = 1 to ob_lookback
            if close[k] > open[k]
                found := k
                break
        if found > 0
            box bx = f_new_index_box(bar_index - found, high[found], bar_index, low[found], color.new(bear_ob_color, 10), bear_ob_color)
            array.push(ob_bear, FvgZone.new(high[found], low[found], high[found], low[found], low[found], time[found], last_low_origin, bar_index, -1, "OB", "Chart", "FRESH", 0, 0, false, bx, na, na))
            box_count += not na(bx) ? 1 : 0
            new_ob := true
            if array.size(ob_bear) > ob_max
                FvgZone old = array.shift(ob_bear)
                f_delete_zone(old)
                box_count -= not na(old.bx) ? 1 : 0

    // Refresh object counts before HTF admission.
    box_count := f_box_total()
    label_count := f_label_total()

    // FVGs key on source origin; OBs key on pivot event and retain source-candle time.
    //
    // HTF Order Blocks are admitted only when something can actually consume
    // them. They used to be built and retained unconditionally, so at default
    // settings up to two full retention sets of boxes existed purely to be
    // painted fully transparent, holding drawing budget the visible surfaces need.
    //
    // The gate reads the per-timeframe zone-type selector as well as the raw
    // toggle. Reading the toggle alone left the same waste reachable: showing raw
    // zones with the type set to FVGs only still built and retained a full set of
    // Order Block boxes that nothing could ever draw.
    bool admit_htf_obs = confl_include_obs or (mtf_show_raw_tf1 and mtf_raw_tf1_kind != "FVGs only") or
      (mtf_show_raw_tf2 and mtf_raw_tf2_kind != "FVGs only")
    if mtf_enable and tf1_valid
        if not na(tf1_time) and tf1_dir != 0 and tf1_time >= mtf_cutoff and (na(last_htf1_fvg) or tf1_time != last_htf1_fvg)
            last_htf1_fvg := tf1_time
            box bx = f_new_time_box(tf1_time, tf1_ft, time, tf1_fb, color.new(mtf_tf1_color, 10), mtf_tf1_color)
            array.push(htf1_fvg, FvgZone.new(tf1_ft, tf1_fb, tf1_ft, tf1_fb, tf1_dir > 0 ? tf1_ft : tf1_fb, tf1_time, tf1_time, bar_index, tf1_dir, "FVG", mtf_tf1, "FRESH", 0, 0, false, bx, na, na))
            f_prune_zones(htf1_fvg, mtf_max)
            // Recount rather than increment: f_prune_zones deletes the pruned
            // zone's box, and a bare increment drifted the running budget high
            // enough to refuse a later box while the real object count was under
            // the cap. The same applies to the three admissions below.
            box_count := f_box_total()
        if admit_htf_obs and not na(tf1_otime) and not na(tf1_oevent) and tf1_odir != 0 and tf1_otime >= mtf_cutoff and (na(last_htf1_ob_event) or tf1_oevent != last_htf1_ob_event)
            last_htf1_ob_event := tf1_oevent
            box bx = f_new_time_box(tf1_otime, tf1_ot, time, tf1_ob, color.new(mtf_tf1_color, 5), color.new(mtf_tf1_color, 35))
            array.push(htf1_ob, FvgZone.new(tf1_ot, tf1_ob, tf1_ot, tf1_ob, tf1_odir > 0 ? tf1_ot : tf1_ob, tf1_otime, tf1_oevent, bar_index, tf1_odir, "OB", mtf_tf1, "FRESH", 0, 0, false, bx, na, na))
            f_prune_zones(htf1_ob, mtf_max)
            box_count := f_box_total()
    if mtf_enable and tf2_valid
        if not na(tf2_time) and tf2_dir != 0 and tf2_time >= mtf_cutoff and (na(last_htf2_fvg) or tf2_time != last_htf2_fvg)
            last_htf2_fvg := tf2_time
            box bx = f_new_time_box(tf2_time, tf2_ft, time, tf2_fb, color.new(mtf_tf2_color, 10), mtf_tf2_color)
            array.push(htf2_fvg, FvgZone.new(tf2_ft, tf2_fb, tf2_ft, tf2_fb, tf2_dir > 0 ? tf2_ft : tf2_fb, tf2_time, tf2_time, bar_index, tf2_dir, "FVG", mtf_tf2, "FRESH", 0, 0, false, bx, na, na))
            f_prune_zones(htf2_fvg, mtf_max)
            box_count := f_box_total()
        if admit_htf_obs and not na(tf2_otime) and not na(tf2_oevent) and tf2_odir != 0 and tf2_otime >= mtf_cutoff and (na(last_htf2_ob_event) or tf2_oevent != last_htf2_ob_event)
            last_htf2_ob_event := tf2_oevent
            box bx = f_new_time_box(tf2_otime, tf2_ot, time, tf2_ob, color.new(mtf_tf2_color, 5), color.new(mtf_tf2_color, 35))
            array.push(htf2_ob, FvgZone.new(tf2_ot, tf2_ob, tf2_ot, tf2_ob, tf2_odir > 0 ? tf2_ot : tf2_ob, tf2_otime, tf2_oevent, bar_index, tf2_odir, "OB", mtf_tf2, "FRESH", 0, 0, false, bx, na, na))
            f_prune_zones(htf2_ob, mtf_max)
            box_count := f_box_total()

// HTF FVGs use the chart FVG confirmed-only lifecycle.
f_update_htf_fvgs(array<FvgZone> zones) =>
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            FvgZone z = array.get(zones, i)
            bool inside = f_inside(z.top, z.bottom)
            if inside and not z.was_inside
                z.visits += 1
            z.was_inside := inside
            bool invalid = z.direction > 0 ? f_below(z.orig_bottom) : f_above(z.orig_top)
            bool touched = fvg_confirm == "Close" ? (z.direction > 0 ? close <= z.orig_top : close >= z.orig_bottom) : inside
            bool mid_reached = z.direction > 0 ? f_below(f_mid(z)) : f_above(f_mid(z))
            float pen_up = fvg_confirm == "Close" ? close : low
            float pen_dn = fvg_confirm == "Close" ? close : high
            // HTF source bounds remain immutable for confluence identity.
            if z.direction > 0
                z.pen := math.min(z.pen, pen_up)
            else
                z.pen := math.max(z.pen, pen_dn)
            // Filled HTF zones remain tracked for optional display but do not
            // qualify as confluence sources.
            if invalid
                z.state := "FILLED"
                array.set(zones, i, z)
            else
                // HTF FVG states advance monotonically.
                string next_htf_state = mid_reached ? "MITIGATED" : touched ? "TESTED" : z.state
                if f_state_rank(next_htf_state) > f_state_rank(z.state)
                    z.state := next_htf_state
                array.set(zones, i, z)
    0

// Update HTF OB state with a confirmed-only lifecycle and penetration tracking.
f_update_htf_obs(array<FvgZone> zones) =>
    if array.size(zones) > 0
        for i = array.size(zones) - 1 to 0
            FvgZone z = array.get(zones, i)
            bool inside = f_inside(z.top, z.bottom)
            if inside and not z.was_inside
                z.visits += 1
            z.was_inside := inside
            float ob_pen_up = fvg_confirm == "Close" ? close : low
            float ob_pen_dn = fvg_confirm == "Close" ? close : high
            if z.direction > 0
                z.pen := math.min(z.pen, ob_pen_up)
            else
                z.pen := math.max(z.pen, ob_pen_dn)
            // Full traversal of the block marks it FILLED so the per-timeframe
            // Show 100% filled zones input governs its visibility, matching the
            // HTF FVG lifecycle. HTF blocks have no breaker flip.
            bool ob_filled = z.direction > 0 ? z.pen <= z.orig_bottom : z.pen >= z.orig_top
            bool ob_touched = fvg_confirm == "Close" ? (z.direction > 0 ? close <= z.top : close >= z.bottom) : inside
            bool ob_mid_reached = z.direction > 0 ? f_below(f_mid(z)) : f_above(f_mid(z))
            // HTF OB states advance monotonically.
            string next_ob_state = ob_filled ? "FILLED" : ob_touched ? (ob_mid_reached ? "MITIGATED" : "TESTED") : z.state
            if f_state_rank(next_ob_state) > f_state_rank(z.state)
                z.state := next_ob_state
            array.set(zones, i, z)
    0

if barstate.isconfirmed
    // Live object references establish the current drawing budget.
    box_count := f_box_total()
    label_count := f_label_total()

    // Disabled or invalid MTF sources are cleared before new admission.
    if not mtf_enable
        f_clear_zones(htf1_fvg)
        f_clear_zones(htf1_ob)
        f_clear_zones(htf2_fvg)
        f_clear_zones(htf2_ob)
        f_clear_confluences()
        last_htf1_fvg := na
        last_htf1_ob_event := na
        last_htf2_fvg := na
        last_htf2_ob_event := na
    else
        // Source selection does not remove raw HTF drawings; an invalid
        // comparison timeframe clears that side and its stale pairings.
        if not tf1_valid
            f_clear_zones(htf1_fvg)
            f_clear_zones(htf1_ob)
            last_htf1_fvg := na
            last_htf1_ob_event := na
        if not tf2_valid
            f_clear_zones(htf2_fvg)
            f_clear_zones(htf2_ob)
            last_htf2_fvg := na
            last_htf2_ob_event := na
    f_update_htf_fvgs(htf1_fvg)
    f_update_htf_fvgs(htf2_fvg)
    f_update_htf_obs(htf1_ob)
    f_update_htf_obs(htf2_ob)

    // Qualification uses the confirmed TF1 ATR from the security context rather
    // than the chart-timeframe ATR, so band existence stays stable when the
    // chart timeframe changes.
    float overlap_min = math.max(syminfo.mintick, nz(tf1_atr) * confl_min_atr)
    array<int> seen = array.new_int()
    if mtf_enable
        // The selected TF1 and TF2 source sets form the confluence cross-product.
        array<FvgZone> set1 = array.copy(htf1_fvg)
        if confl_include_obs and array.size(htf1_ob) > 0
            array.concat(set1, array.copy(htf1_ob))
        array<FvgZone> set2 = array.copy(htf2_fvg)
        if confl_include_obs and array.size(htf2_ob) > 0
            array.concat(set2, array.copy(htf2_ob))
        if pair_tf1_tf2
            f_add_pairs(set1, set2, seen, bar_index, time, overlap_min, "TF1", "TF2")
    if array.size(confluences) > 0
        for i = array.size(confluences) - 1 to 0
            bool still_seen = array.includes(seen, i)
            if not still_seen
                ConfluenceBand stale = array.get(confluences, i)
                f_delete_band(stale)
                array.remove(confluences, i)
    // FIFO retention keeps the newest confluence records.
    while array.size(confluences) > confl_max
        ConfluenceBand oldest = array.shift(confluences)
        f_delete_band(oldest)

// ── Drawing pass ──────────────────────────────────────────────────────────────
// Both draw helpers return their label delta rather than touching the running
// budgets directly: a Pine function cannot assign to a global. The line budget is
// not returned alongside it — a tuple declaration in a local scope is not
// something the manual confirms, and the caller recomputes the true line total
// from live object references anyway.
f_draw_chart_zones(array<FvgZone> zones, color base, bool enabled) =>
    int label_delta = 0
    int labels_used = label_count
    int lines_used = line_count
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            FvgZone z = array.get(zones, i)
            if not na(z.bx)
                box.set_right(z.bx, bar_index)
                box.set_top(z.bx, z.top)
                box.set_bottom(z.bx, z.bottom)
                bool faint = z.state == "FILLED" or z.state == "BREAKER"
                box.set_bgcolor(z.bx, enabled ? color.new(base, faint ? 92 : z.state == "MITIGATED" ? 88 : z.state == "TESTED" ? 84 : 78) : color.new(color.gray, 100))
                box.set_border_color(z.bx, enabled ? color.new(base, faint ? 85 : 25) : color.new(color.gray, 100))
                // State and fill % are one horizontal label governed entirely by the
                // FVG Labels section: position, text size, and color apply to both.
                bool is_zone = z.kind == "FVG" or z.kind == "OB"
                float fill_pct = f_fill(z)
                bool suppress_zero_fvg_pct = z.kind == "FVG" and not fvg_keep_filled and fill_pct == 0.0
                bool want_state = fvg_show_state and is_zone
                bool want_pct = fvg_pct_show and is_zone and not suppress_zero_fvg_pct
                string lbl_txt = want_state or want_pct ? f_direction_text(z.direction) + " " + z.kind : ""
                if want_state
                    lbl_txt := lbl_txt + " · " + z.state
                if want_pct
                    lbl_txt := lbl_txt + (lbl_txt == "" ? "" : " · ") + f_fill_text(fill_pct)
                bool inside_pos = fvg_pct_pos == "Inside Box"
                color label_text_color = f_chart_zone_text_color()
                box.set_text(z.bx, enabled and inside_pos ? lbl_txt : "")
                box.set_text_color(z.bx, label_text_color)
                box.set_text_size(z.bx, f_pct_size())
                if enabled and not inside_pos and (want_state or want_pct)
                    if na(z.pct_lbl)
                        label new_lbl = f_new_zone_label(bar_index + fvg_pct_offset, (z.top + z.bottom) * 0.5, label_text_color, f_pct_size(), labels_used)
                        if not na(new_lbl)
                            z.pct_lbl := new_lbl
                            labels_used += 1
                            label_delta += 1
                    if not na(z.pct_lbl)
                        label.set_x(z.pct_lbl, math.min(bar_index + fvg_pct_offset, bar_index + CONFL_LABEL_MAX_FUTURE_BARS))
                        label.set_y(z.pct_lbl, (z.top + z.bottom) * 0.5)
                        label.set_text(z.pct_lbl, lbl_txt)
                        label.set_textcolor(z.pct_lbl, label_text_color)
                        label.set_size(z.pct_lbl, f_pct_size())
                else if not na(z.pct_lbl)
                    label.delete(z.pct_lbl)
                    labels_used -= 1
                    label_delta -= 1
                    z.pct_lbl := na
                // The 50% midpoint is anchored to the original gap, so partial-fill
                // shrink never moves it. This is the level MITIGATED already reads.
                bool want_ce = enabled and ce_show and ce_show_chart and is_zone
                if want_ce
                    float ce_y = f_mid(z)
                    // z.origin is the time of the zone box's own left edge for both
                    // kinds: time[2] for an FVG, time[found] for an Order Block. The
                    // time variant therefore spans exactly the drawn zone.
                    if na(z.ce_ln)
                        z.ce_ln := f_new_time_ce(z.origin, ce_y, time, ce_color, f_line_style(ce_style_input), ce_width, lines_used)
                        if not na(z.ce_ln)
                            lines_used += 1
                    if not na(z.ce_ln)
                        line.set_xy1(z.ce_ln, z.origin, ce_y)
                        line.set_xy2(z.ce_ln, time, ce_y)
                        line.set_color(z.ce_ln, ce_color)
                        line.set_style(z.ce_ln, f_line_style(ce_style_input))
                        line.set_width(z.ce_ln, ce_width)
                else if not na(z.ce_ln)
                    line.delete(z.ce_ln)
                    lines_used -= 1
                    z.ce_ln := na
                array.set(zones, i, z)
    label_delta

f_draw_htf_zones(array<FvgZone> zones, color base, bool enabled, bool show_labels, bool partial_fill, bool show_filled) =>
    int label_delta = 0
    int labels_used = label_count
    int lines_used = line_count
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            FvgZone z = array.get(zones, i)
            if not na(z.bx)
                // Fully traversed zones stay tracked but draw only when the
                // per-timeframe Show 100% filled zones input is on.
                bool zone_enabled = enabled and (show_filled or z.state != "FILLED")
                // Per-timeframe raw partial fill is a draw-only transform, mirroring
                // confluence partial fill: it reads the already-tracked pen but never
                // mutates z.top/z.bottom, so source identity and confluence pairing
                // stay intact.
                float draw_top = partial_fill ? f_live_top(z) : z.orig_top
                float draw_bottom = partial_fill ? f_live_bottom(z) : z.orig_bottom
                if partial_fill
                    if z.direction > 0
                        draw_top := math.max(draw_top, draw_bottom)
                    else
                        draw_bottom := math.min(draw_bottom, draw_top)
                box.set_right(z.bx, time)
                box.set_top(z.bx, draw_top)
                box.set_bottom(z.bx, draw_bottom)
                box.set_bgcolor(z.bx, zone_enabled ? color.new(base, z.kind == "OB" ? 86 : 88) : color.new(color.gray, 100))
                box.set_border_color(z.bx, zone_enabled ? color.new(base, 35) : color.new(color.gray, 100))
                bool want_label = zone_enabled and show_labels
                if want_label
                    // Raw HTF metadata renders on one line.
                    string lbl_txt = f_tf_label(z.tf) + " " + f_direction_text(z.direction) + " " + z.kind + " · " + z.state + " · " + f_fill_text(f_fill(z))
                    string lbl_tip = "Raw HTF zone\n" + lbl_txt
                    float lbl_y = (draw_top + draw_bottom) * 0.5
                    if na(z.pct_lbl)
                        label new_lbl = f_new_htf_label(bar_index, lbl_y, lbl_txt, base, f_label_size(), lbl_tip, labels_used)
                        if not na(new_lbl)
                            z.pct_lbl := new_lbl
                            labels_used += 1
                            label_delta += 1
                    if not na(z.pct_lbl)
                        label.set_xy(z.pct_lbl, bar_index, lbl_y)
                        label.set_text(z.pct_lbl, lbl_txt)
                        label.set_tooltip(z.pct_lbl, lbl_tip)
                        // Label text follows the chart foreground color so it stays readable against
                        // both light and dark chart backgrounds.
                        label.set_textcolor(z.pct_lbl, chart.fg_color)
                        label.set_size(z.pct_lbl, f_label_size())
                else if not na(z.pct_lbl)
                    label.delete(z.pct_lbl)
                    labels_used -= 1
                    label_delta -= 1
                    z.pct_lbl := na
                bool want_ce = zone_enabled and ce_show and ce_show_htf
                if want_ce
                    float ce_y = (z.orig_top + z.orig_bottom) * 0.5
                    if na(z.ce_ln)
                        z.ce_ln := f_new_time_ce(z.origin, ce_y, time, ce_color, f_line_style(ce_style_input), ce_width, lines_used)
                        if not na(z.ce_ln)
                            lines_used += 1
                    if not na(z.ce_ln)
                        line.set_xy1(z.ce_ln, z.origin, ce_y)
                        line.set_xy2(z.ce_ln, time, ce_y)
                        line.set_color(z.ce_ln, ce_color)
                        line.set_style(z.ce_ln, f_line_style(ce_style_input))
                        line.set_width(z.ce_ln, ce_width)
                else if not na(z.ce_ln)
                    line.delete(z.ce_ln)
                    lines_used -= 1
                    z.ce_ln := na
                array.set(zones, i, z)
    label_delta

if barstate.islast
    // The draw pass refreshes object counts before a confirmed context rebuild.
    box_count := f_box_total()
    label_count := f_label_total()
    line_count := f_line_total()

    // One consolidated warning owns all invalid/duplicate compare-timeframe
    // feedback. It is updated in place so settings changes never stack labels.
    if mtf_warning_text != ""
        float warning_y = high + math.max(syminfo.mintick * 20.0, nz(atr, syminfo.mintick * 20.0))
        if na(mtf_warning_label)
            mtf_warning_label := f_new_mtf_warning(bar_index, warning_y, mtf_warning_text)
            label_count += not na(mtf_warning_label) ? 1 : 0
        if not na(mtf_warning_label)
            label.set_xy(mtf_warning_label, bar_index, warning_y)
            label.set_text(mtf_warning_label, mtf_warning_text)
    else if not na(mtf_warning_label)
        label.delete(mtf_warning_label)
        mtf_warning_label := na
        label_count -= 1

    // Chart drawings follow their enable inputs; raw HTF drawings also follow
    // the selected per-timeframe zone type.
    bool draw_raw_tf1_fvg = mtf_enable and tf1_valid and mtf_show_raw_tf1 and mtf_raw_tf1_kind != "Order Blocks only"
    bool draw_raw_tf1_ob = mtf_enable and tf1_valid and mtf_show_raw_tf1 and mtf_raw_tf1_kind != "FVGs only"
    bool draw_raw_tf2_fvg = mtf_enable and tf2_valid and mtf_show_raw_tf2 and mtf_raw_tf2_kind != "Order Blocks only"
    bool draw_raw_tf2_ob = mtf_enable and tf2_valid and mtf_show_raw_tf2 and mtf_raw_tf2_kind != "FVGs only"
    // line_count is refreshed from live object references after each helper, so
    // the next one sees a true budget without a tuple crossing the boundary.
    label_count += f_draw_chart_zones(fvg_bull, bull_fvg_color, fvg_enable)
    line_count := f_line_total()
    label_count += f_draw_chart_zones(fvg_bear, bear_fvg_color, fvg_enable)
    line_count := f_line_total()
    label_count += f_draw_chart_zones(ob_bull, bull_ob_color, ob_enable)
    line_count := f_line_total()
    label_count += f_draw_chart_zones(ob_bear, bear_ob_color, ob_enable)
    line_count := f_line_total()
    label_count += f_draw_htf_zones(htf1_fvg, mtf_tf1_color, draw_raw_tf1_fvg, mtf_show_raw_labels, mtf_raw_tf1_partial_fill, mtf_raw_tf1_show_filled)
    line_count := f_line_total()
    label_count += f_draw_htf_zones(htf1_ob, mtf_tf1_color, draw_raw_tf1_ob, mtf_show_raw_labels, mtf_raw_tf1_partial_fill, mtf_raw_tf1_show_filled)
    line_count := f_line_total()
    label_count += f_draw_htf_zones(htf2_fvg, mtf_tf2_color, draw_raw_tf2_fvg, mtf_show_raw_labels, mtf_raw_tf2_partial_fill, mtf_raw_tf2_show_filled)
    line_count := f_line_total()
    label_count += f_draw_htf_zones(htf2_ob, mtf_tf2_color, draw_raw_tf2_ob, mtf_show_raw_labels, mtf_raw_tf2_partial_fill, mtf_raw_tf2_show_filled)
    line_count := f_line_total()

    // Stable contexts remove stale pairings and redraw active bands. Confirmed
    // mutation owns context transitions to avoid an interim blank chart.
    if (not mtf_context_changed or barstate.isconfirmed) and array.size(confluences) > 0
        for i = array.size(confluences) - 1 to 0
            ConfluenceBand band = array.get(confluences, i)
            if not f_band_pair_active(band)
                box_count -= not na(band.bx) ? 1 : 0
                label_count -= not na(band.lbl) ? 1 : 0
                f_delete_band(band)
                array.remove(confluences, i)
            else
                // State filters hide only the drawing; the persistent record stays
                // alive so a later selection can reveal it without waiting for a
                // new HTF event.
                //
                // Every object below is updated in place. That removes churn
                // across bar closes — a box and label created here on the last bar
                // are committed at its close and reused on the next bar, where the
                // earlier pass deleted and rebuilt both.
                //
                // It does not remove churn across the ticks of one open bar, and
                // no code here could: the execution model's rollback reverts each
                // open-bar execution and removes any object created during it
                // unless it is held by a varip variable. These are rebuilt every
                // tick whatever this block does.
                bool band_visible = f_band_status_visible(band)
                if band_visible
                    bool pure_fvg = band.kind_a == "FVG" and band.kind_b == "FVG"
                    string band_status = f_band_status(band)
                    int overlap_count = f_band_overlap_count(i)
                    // Confluence Partial Fill is a draw-only transform. Persistent
                    // top/bottom, origins, and birth anchors remain the band identity.
                    float draw_top = pure_fvg and confl_partial_fill ? band.fill_top : band.orig_top
                    float draw_bottom = pure_fvg and confl_partial_fill ? band.fill_bottom : band.orig_bottom
                    if pure_fvg and confl_partial_fill
                        if band.direction > 0
                            draw_top := math.max(draw_top, draw_bottom)
                        else
                            draw_bottom := math.min(draw_bottom, draw_top)
                    color band_color = overlap_count >= 3 ? confl_dense_color : overlap_count == 2 ? confl_double_color : confl_single_color
                    // Band opacity follows lifecycle progress.
                    int band_fill_alpha = band_status == "PARTIAL" ? 88 : band_status == "TESTED" ? 84 : 78
                    int band_border_alpha = band_status == "PARTIAL" ? 45 : band_status == "TESTED" ? 30 : 10
                    // Time coordinates avoid xloc.bar_index's 9,999-past-bar
                    // drawing limit when an old retained band is redrawn.
                    if na(band.bx)
                        band.bx := f_new_time_box(band.born_time, draw_top, time, draw_bottom, color.new(band_color, band_border_alpha), color.new(band_color, band_fill_alpha))
                        box_count += not na(band.bx) ? 1 : 0
                    if not na(band.bx)
                        box.set_left(band.bx, band.born_time)
                        box.set_top(band.bx, draw_top)
                        box.set_right(band.bx, time)
                        box.set_bottom(band.bx, draw_bottom)
                        box.set_bgcolor(band.bx, color.new(band_color, band_fill_alpha))
                        box.set_border_color(band.bx, color.new(band_color, band_border_alpha))
                    string density_text = overlap_count > 1 ? " · " + str.tostring(overlap_count) + " overlapping" : ""
                    string title = f_direction_text(band.direction) + " · " + f_tf_label(band.tf_a) + " × " + f_tf_label(band.tf_b) + " " + band.kind_a + "/" + band.kind_b + density_text
                    // Confluence metadata renders on one line.
                    string metadata = ""
                    if confl_show_state
                        metadata := band_status
                    if confl_show_age
                        metadata := metadata + (metadata == "" ? "" : " · ") + "Age " + f_band_age_text(band)
                    if metadata != ""
                        title := title + " · " + metadata
                    if confl_fill_label and pure_fvg
                        title := title + " · " + f_fill_text(f_band_fill_percent(band))
                    string tip = "Confluence provenance\n" + title + "\nOverlapping active bands: " + str.tostring(overlap_count) +
                      "\nDirection: " + (band.direction > 0 ? "Bullish" : "Bearish") + "\nState: " + band_status +
                      "\nAge: " + f_band_age_text(band) + "\nVisits: " + str.tostring(band.visits) + "\nBreaks / failed visits: " + str.tostring(band.breaks)
                    if confl_show_labels
                        if na(band.lbl)
                            band.lbl := f_new_band_label(bar_index, (draw_top + draw_bottom) * 0.5, title, band_color, chart.fg_color, f_label_size(), tip)
                            label_count += not na(band.lbl) ? 1 : 0
                        if not na(band.lbl)
                            label.set_xy(band.lbl, bar_index, (draw_top + draw_bottom) * 0.5)
                            label.set_text(band.lbl, title)
                            label.set_tooltip(band.lbl, tip)
                            // Label text follows the chart foreground color so it stays readable against
                            // a pale band on any chart background.
                            label.set_textcolor(band.lbl, chart.fg_color)
                            label.set_color(band.lbl, color.new(band_color, 70))
                            label.set_size(band.lbl, f_label_size())
                    else if not na(band.lbl)
                        label.delete(band.lbl)
                        label_count -= 1
                        band.lbl := na
                    // The band's own 50% midpoint, anchored to the immutable overlap.
                    if ce_show and ce_show_bands
                        float ce_y = (band.orig_top + band.orig_bottom) * 0.5
                        if na(band.ce_ln)
                            band.ce_ln := f_new_time_ce(band.born_time, ce_y, time, ce_color, f_line_style(ce_style_input), ce_width, line_count)
                            line_count += not na(band.ce_ln) ? 1 : 0
                        if not na(band.ce_ln)
                            line.set_xy1(band.ce_ln, band.born_time, ce_y)
                            line.set_xy2(band.ce_ln, time, ce_y)
                            line.set_color(band.ce_ln, ce_color)
                            line.set_style(band.ce_ln, f_line_style(ce_style_input))
                            line.set_width(band.ce_ln, ce_width)
                    else if not na(band.ce_ln)
                        line.delete(band.ce_ln)
                        line_count -= 1
                        band.ce_ln := na
                else
                    // Hidden by a state filter: drop the drawings, keep the record.
                    if not na(band.bx)
                        box.delete(band.bx)
                        box_count -= 1
                        band.bx := na
                    if not na(band.lbl)
                        label.delete(band.lbl)
                        label_count -= 1
                        band.lbl := na
                    if not na(band.ce_ln)
                        line.delete(band.ce_ln)
                        line_count -= 1
                        band.ce_ln := na
                array.set(confluences, i, band)

    // External labels share one deterministic layout pass.
    f_layout_visible_labels()

    // ── Dashboard ─────────────────────────────────────────────────────────────
    // A description of what is on the chart right now: the nearest active
    // confluence band, or the nearest active chart FVG when no band qualifies.
    // Every row is an observed count or measurement. None of it is a signal,
    // score, probability or forecast.
    if dash_show
        table.clear(dashboard, 0, 0, 1, DASH_TABLE_ROWS - 1)
        f_dash_spacer(0, f_dash_pad_top(dash_position))
        f_dash_spacer(DASH_TABLE_ROWS - 1, f_dash_pad_bottom(dash_position))
        float ref_price = close
        int best_band = -1
        float best_band_distance = na
        if array.size(confluences) > 0
            for i = 0 to array.size(confluences) - 1
                ConfluenceBand b = array.get(confluences, i)
                if f_band_pair_active(b) and f_band_status_visible(b)
                    float mid = (b.orig_top + b.orig_bottom) * 0.5
                    float distance = math.abs(ref_price - mid)
                    if best_band < 0 or distance < best_band_distance
                        best_band := i
                        best_band_distance := distance

        int active_bands = 0
        if array.size(confluences) > 0
            for i = 0 to array.size(confluences) - 1
                ConfluenceBand b = array.get(confluences, i)
                if f_band_pair_active(b) and f_band_status_visible(b)
                    active_bands += 1
        int chart_fvgs = array.size(fvg_bull) + array.size(fvg_bear)
        int chart_obs = array.size(ob_bull) + array.size(ob_bear)

        string target_label = "—"
        string target_state = "—"
        string target_range = "—"
        string target_fill = "—"
        string target_distance = "—"
        string target_age = "—"
        if best_band >= 0
            ConfluenceBand b = array.get(confluences, best_band)
            bool pure_fvg = b.kind_a == "FVG" and b.kind_b == "FVG"
            target_label := f_direction_text(b.direction) + " " + f_tf_label(b.tf_a) + " × " + f_tf_label(b.tf_b)
            target_state := f_band_status(b) + " · " + b.kind_a + "/" + b.kind_b
            target_range := str.tostring(b.orig_bottom, format.mintick) + " – " + str.tostring(b.orig_top, format.mintick)
            target_fill := pure_fvg ? f_fill_text(f_band_fill_percent(b)) : "static (mixed)"
            target_age := f_band_age_text(b) + " · " + f_plural(b.visits, "visit")
            float mid = (b.orig_top + b.orig_bottom) * 0.5
            float atr_units = nz(atr) > 0 ? math.abs(ref_price - mid) / atr : na
            target_distance := na(atr_units) ? "—" : str.tostring(atr_units, "0.00") + " ATR from midpoint"
        else
            // Fall back to the nearest active standalone chart FVG.
            float best_fvg_distance = na
            int best_side = 0
            int best_idx = -1
            for side = 0 to 1
                array<FvgZone> zones = side == 0 ? fvg_bull : fvg_bear
                if array.size(zones) > 0
                    for i = 0 to array.size(zones) - 1
                        FvgZone z = array.get(zones, i)
                        if z.state != "FILLED"
                            float mid = f_mid(z)
                            float distance = math.abs(ref_price - mid)
                            if best_idx < 0 or distance < best_fvg_distance
                                best_fvg_distance := distance
                                best_side := side
                                best_idx := i
            if best_idx >= 0
                array<FvgZone> zones = best_side == 0 ? fvg_bull : fvg_bear
                FvgZone z = array.get(zones, best_idx)
                target_label := f_direction_text(z.direction) + " chart FVG"
                target_state := z.state
                target_range := str.tostring(z.orig_bottom, format.mintick) + " – " + str.tostring(z.orig_top, format.mintick)
                target_fill := f_fill_text(f_fill(z))
                target_age := f_plural(bar_index - z.born_bar, "bar") + " · " + f_plural(z.visits, "visit")
                float atr_units = nz(atr) > 0 ? best_fvg_distance / atr : na
                target_distance := na(atr_units) ? "—" : str.tostring(atr_units, "0.00") + " ATR from midpoint"
            else
                target_label := mtf_warning_text != "" ? "Check comparison timeframes" : "No active zone"

        f_dash_row(0, "Nearest", target_label)
        f_dash_row(1, "State", target_state)
        f_dash_row(2, "Range", target_range)
        f_dash_row(3, "Fill", target_fill)
        f_dash_row(4, "Distance", target_distance)
        f_dash_row(5, "Age", target_age)
        f_dash_row(6, "On chart", str.tostring(active_bands) + " bands · " + str.tostring(chart_fvgs) + " FVG · " + str.tostring(chart_obs) + " OB")
    else
        table.clear(dashboard, 0, 0, 1, DASH_TABLE_ROWS - 1)

    box_count := f_box_total()
    label_count := f_label_total()
    line_count := f_line_total()

alertcondition(new_fvg, "FVG formed", "FVG Confluence: new confirmed FVG")
alertcondition(new_ob, "Order Block formed", "FVG Confluence: new confirmed Order Block")
````
