# Smart Gap & Support and Resistance Breakout [MarkitTick]

- url: https://www.tradingview.com/script/n8uOg427-Smart-Gap-Support-and-Resistance-Breakout-MarkitTick/
- type: indicator
- pine_id: PUB;feec74c7dfec4f39b1f011c4f4b499c4
- version: 1.0

## Description

💡 This technical analysis script provides a highly sophisticated framework for market structure mapping, gap categorization, and breakout validation. By tracking structural pivot points and combining them with algorithmic gap analysis, the indicator systematically identifies areas of significant price imbalance and evaluates their impact on subsequent price action. The tool dynamically maps historical and developing support and resistance levels across multiple timeframes, integrating volume analysis and time-decay functions to ensure only the most relevant structural levels remain active. Designed for robust technical evaluation, it utilizes a strict non-repainting architecture for its multi-timeframe data retrieval, ensuring historical integrity during retrospective analysis.

[b]✨ Originality and Utility[/b]
While many indicators plot basic support and resistance levels or highlight price gaps, this tool introduces a high degree of originality through its algorithmic synthesis and mashup methodology. The combination of structural pivot tracking and gap categorization is a deliberate and logical confluence. Gaps inherently represent sudden shifts in supply and demand, frequently acting as hidden support or resistance zones. By merging gap analysis with traditional pivot-based market structure, the script provides a unified view of market geometry. 

Furthermore, the script distinguishes itself by categorizing gaps dynamically into three distinct types: Breakaway, Runaway, and Exhaustion. Rather than treating all price voids equally, it applies contextual logic—such as trend maturity and volume confirmation—to evaluate the probabilistic nature of the gap. The utility is further enhanced by an advanced multi-timeframe engine that overlays macro structural levels onto the active chart without introducing lookahead bias, providing traders with a pristine, top-down analytical perspective within a single pane.

[b]🔬 Methodology and Concepts[/b]
[b]● Structural Pivot Detection[/b]
The foundation of the script relies on identifying Swing Highs and Swing Lows. 
[list]
[*] A Pivot High is established when a specific high price is preceded and followed by a defined number of lower highs.
[*] A Pivot Low is established when a specific low price is preceded and followed by a defined number of higher lows.
[*] These points act as the empirical anchors for drawing support and resistance lines.
[/list]

[b]● Gap Categorization Engine[/b]
The script continuously scans for bullish and bearish price gaps (defined as a strict price void between the current low/high and the high/low of two bars prior, combined with directional candle confirmation). Once a gap exceeds the minimum size threshold, it is classified using the following methodology:
[list]
[*] Breakaway Gaps (BW): Identified if the gap's occurrence coincides with the breaking of the most recently established structural pivot level. This signifies a forceful escape from a prior consolidation or trend phase.
[*] Exhaustion Gaps (EX): Identified if the gap occurs after a prolonged trend duration (trend maturity) and is accompanied by a significant volume spike. This logic assumes that late-stage acceleration coupled with extreme volume often represents climatic buying or selling.
[*] Runaway Gaps (RW): Any valid gap that does not meet the strict criteria for Breakaway or Exhaustion is classified as Runaway, representing standard trend continuation.
[/list]

[b]● Non-Repainting Multi-Timeframe Integration[/b]
To map higher timeframe (HTF) levels onto the lower timeframe (LTF) chart safely, the script employs a strict index-offset methodology. When fetching HTF pivot data, the script references the previous bar's calculated state while utilizing a lookahead parameter. This architectural design explicitly prevents future data leakage (lookahead bias), ensuring that historical backtesting and real-time execution behave identically.

[b]● Breakout and Time-Decay Logic[/b]
Support and resistance lines are evaluated for breakouts based on closing prices. A breakout is only considered valid if the closing price decisively crosses the level and, if volume confirmation is enabled, the breakout bar's volume exceeds the defined moving average threshold. To maintain a clean visual workspace, levels can be subjected to a time-decay function, removing them from the chart after a user-defined number of bars.

[b]🎨 Visual Guide[/b]
[b]● Support and Resistance Lines[/b]
[list]
[*] Green Lines: Represent active support levels derived from current timeframe pivot lows.
[*] Red Lines: Represent active resistance levels derived from current timeframe pivot highs.
[*] Thick Light Blue Lines: Highlight major support levels from the higher timeframe.
[*] Thick Orange Lines: Highlight major resistance levels from the higher timeframe.
[/list]

[b]● Market Structure Labels[/b]
[list]
[*] Red "HH" / "LH" Labels: Denote Higher Highs or Lower Highs at resistance pivots.
[*] Blue/Green "LL" / "HL" Labels: Denote Lower Lows or Higher Lows at support pivots.
[*] Purple "EH" / "EL" Labels: Indicate Equal Highs or Equal Lows.
[/list]

[b]● Gap Visualization Boxes[/b]
[list]
[*] Blue Boxes: Highlight Breakaway Gaps (BW).
[*] Orange Boxes: Highlight Runaway Gaps (RW).
[*] Red Boxes: Highlight Exhaustion Gaps (EX).
[*] Dotted Mid-Lines: Each gap box contains a dotted line calculating the exact mathematical midpoint of the gap, often acting as a highly reactive micro-level.
[/list]

[b]● Breakout Markers[/b]
[list]
[*] Green Upward Triangles (▲): Plotted below the price to indicate a confirmed breakout of a resistance level. The number indicates how many distinct resistance levels were broken on that bar.
[*] Red Downward Triangles (▼): Plotted above the price to indicate a confirmed breakdown of a support level.
[*] Cyan/Orange Triangles: Represent breakouts of higher timeframe (HTF) levels.
[/list]

[b]📖 How to Use[/b]
[b]● Interpreting Gap Signals[/b]
[list]
[*] Breakaway Gaps: When a blue Breakaway gap forms, it suggests the initiation of a new directional phase. Traders typically monitor the borders of this gap to act as strong support or resistance upon any subsequent retests.
[*] Runaway Gaps: The appearance of an orange Runaway gap confirms underlying trend strength. The midpoint of these gaps (the dotted line) is often used to gauge short-term trend health.
[*] Exhaustion Gaps: A red Exhaustion gap serves as a cautionary signal. Because it indicates mature trend fatigue coupled with high volume, it suggests that the current directional momentum may be nearing a terminal phase or sharp retracement.
[/list]

[b]● Trading Support and Resistance Breakouts[/b]
[list]
[*] Structural Mapping: Use the dynamically drawn S/R lines to identify the boundaries of the current market range. 
[*] Volume Confirmation: When the indicator plots a breakout triangle, ensure that it aligns with your broader directional bias. If the volume confirmation setting is active, the triangle inherently signifies that the breakout possessed above-average participation, increasing the mathematical probability of continuation.
[*] Multi-Timeframe Confluence: Pay special attention when current timeframe price action interacts with the thicker HTF lines. A breakout that fractures both a LTF and HTF resistance level simultaneously carries significantly more structural weight.
[/list]

[b]⚙️ Inputs and Settings[/b]
[b]● Swing Logic[/b]
[list]
[*] Left Bars / Right Bars: Determines the number of bars required on either side of a candle to confirm a structural pivot. Higher values yield longer-term, more significant levels.
[*] Max Stored Levels: Controls how many historical S/R lines remain active on the chart to prevent visual clutter.
[*] Max Break Labels: Limits the number of historical breakout triangle markers displayed.
[/list]

[b]● Usability and Time Decay[/b]
[list]
[*] Multi-Timeframe: Allows overriding the base timeframe for calculations.
[*] Enable Time Decay: When activated, S/R levels that remain untested or unbroken will automatically expire and be removed from the chart.
[*] Decay Period (Bars): The specific threshold of bars after which an untested level is deleted.
[/list]

[b]● Higher Timeframe (HTF) Levels[/b]
[list]
[*] Enable HTF Levels: Toggles the calculation and plotting of macro S/R lines.
[*] HTF Timeframe: The target timeframe for macro structural analysis (e.g., Daily, Weekly).
[*] Hide Current TF When HTF Active: A visual filter to isolate only macro levels when desired.
[/list]

[b]● Algorithmic Filters and Analysis[/b]
[list]
[*] Volume Confirmation: When true, breakouts are only validated if the bar's volume exceeds a moving average.
[*] Min Gap Size (Points): Establishes a raw point threshold that a price void must exceed to be classified as a gap, filtering out negligible price skips.
[*] Volume Spike Multiplier: The factor by which current volume must exceed the average to trigger Exhaustion gap logic.
[*] Trend Maturity (Bars): The minimum number of bars a trend must have persisted from the last major pivot to allow for an Exhaustion gap classification.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
[b]● Auction Market Theory and Liquidity Voids[/b]
The gap categorization matrix within this script is deeply rooted in Auction Market Theory (AMT). In AMT, price discovery is a continuous auction searching for liquidity. A gap represents a structural liquidity void—a pricing zone where no double-sided auction occurred due to extreme urgency from either buyers or sellers. The script's identification of Breakaway gaps mathematically isolates moments where this urgency successfully overcomes historical supply or demand nodes (the pivots). The dotted midpoint lines inside the gap boxes serve as theoretical "Fair Value" approximations for the void, representing the mean reversion target if the market attempts to repair the inefficient auction.

[b]● Volume Spread Analysis (VSA) Integration[/b]
The Exhaustion gap classification heavily relies on principles derived from Volume Spread Analysis. In VSA, volume represents the effort of market participants, while price spread represents the result. The script mathematically quantifies an anomaly: when an extended trend (measured by the Trend Maturity parameter) produces a sudden gap on extreme volume (measured by the Volume Spike Multiplier), it implies climactic transfer of inventory from strong hands to weak hands. The algorithmic detection of these specific variables provides a quantifiable method for identifying trend exhaustion without relying on lagging, bounded oscillators.

[b]● Fractal Market Geometry[/b]
By rendering both LTF and HTF structural pivots within the same visual plane, the script operationalizes the concept of fractal market geometry. Financial time series exhibit self-similarity across different scales. A pivot high on a 15-minute chart is formed by the same behavioral mechanics as a pivot high on a Daily chart, but they carry vastly different liquidity weights. The script's strict index-offset MTF architecture ensures that the geometric relationship between these distinct fractal layers is evaluated with absolute temporal accuracy, providing a mathematically sound representation of macro supply and demand overlaying micro price action.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator("Smart Gap & Support and Resistance Breakout [MarkitTick]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)
// ── Fixed Colors ─────────────────────────────────────────────────────────────
var color C_RES     = color.rgb(255, 75, 75, 0)
var color C_SUP     = color.rgb(0, 220, 130, 0)
var color C_TXT     = color.rgb(240, 240, 255, 0)
var color C_BRK     = color.rgb(80, 160, 255, 0)
var color C_HTF_RES = color.rgb(255, 140, 0, 0)
var color C_HTF_SUP = color.rgb(0, 200, 255, 0)
// ── User Inputs ──────────────────────────────────────────────────────────────
string G_SWING      = 'Swing'
int leftBars        = input.int(5, "Left Bars", minval = 1, group = G_SWING)
int rightBars       = input.int(5, "Right Bars", minval = 1, group = G_SWING)
int maxLevels       = input.int(5, "Max Stored Levels", group = G_SWING)
int maxLabels       = input.int(10, "Max Break Labels", minval = 1, group = G_SWING)
string G_USE        = 'Usability'
string tf_input     = input.timeframe("", "Multi-Timeframe", group = G_USE)
bool use_decay      = input.bool(false, "Enable Time Decay", group = G_USE)
int decay_bars      = input.int(50, "Decay Period (Bars)", minval = 1, group = G_USE)
string G_HTF_LVL    = 'HTF Levels'
bool   use_htf      = input.bool(false, "Enable HTF Levels", group = G_HTF_LVL)
string htf_tf       = input.timeframe("D", "HTF Timeframe", group = G_HTF_LVL)
int    htf_left     = input.int(3, "HTF Left Bars", minval = 1, group = G_HTF_LVL)
int    htf_right    = input.int(3, "HTF Right Bars", minval = 1, group = G_HTF_LVL)
int    htf_max      = input.int(3, "HTF Max Levels", minval = 1, maxval = 10, group = G_HTF_LVL)
int    htf_linewidth = input.int(2, "HTF Line Width", minval = 1, maxval = 4, group = G_HTF_LVL)
bool   hide_ltf     = input.bool(false, "Hide Current TF When HTF Active", group = G_HTF_LVL)
string G_ANALYSIS   = 'Analysis'
bool use_vol        = input.bool(false, "Volume Confirmation", group = G_ANALYSIS)
int vol_len         = input.int(20, "Volume MA Length", minval = 1, group = G_ANALYSIS)
string G_VIS        = 'Vis'
bool show_struct    = input.bool(true, "Show Market Structure (HH/LL)", group = G_VIS)
bool show_ext       = input.bool(false, "Show Extended Lines", group = G_VIS)
string G_LOGIC      = 'Algorithmic Filters'
float  I_MIN_GAP    = input.float(0.0, 'Min Gap Size (Points)', minval = 0.0, group = G_LOGIC)
int    I_PIVOT_L    = input.int(5, 'Structure Lookback Left', minval = 1, group = G_LOGIC)
int    I_PIVOT_R    = input.int(5, 'Structure Lookback Right', minval = 1, group = G_LOGIC)
int    I_VOL_LEN    = input.int(20, 'Volume Avg Length', minval = 1, group = G_LOGIC)
float  I_VOL_MULT   = input.float(1.5, 'Volume Spike Multiplier', minval = 1.0, group = G_LOGIC)
int    I_TREND_MAT  = input.int(20, 'Trend Maturity (Bars)', minval = 5, group = G_LOGIC, tooltip = "")
string G_MTF        = 'Multi-Timeframe'
bool   I_HTF_ON     = input.bool(false, 'Enable Higher Timeframe Gaps', group = G_MTF)
string I_HTF_TF     = input.timeframe('D', 'Higher Timeframe', group = G_MTF)
color  I_HTF_TXT_C  = input.color(color.rgb(255, 220, 50, 0), 'HTF Label Color', group = G_MTF)
string G_GAP_VIS    = 'Gap Vis Colors'
color C_BREAKAWAY   = input.color(color.rgb(30, 120, 255, 70), 'Breakaway Gap (Start)', group = G_GAP_VIS)
color C_RUNAWAY     = input.color(color.rgb(255, 165, 0, 70), 'Runaway Gap (Middle)', group = G_GAP_VIS)
color C_EXHAUSTION  = input.color(color.rgb(220, 40, 80, 70), 'Exhaustion Gap (End)', group = G_GAP_VIS)
int   I_EXTEND      = input.int(10, 'Box Extension (Bars)', minval = 1, group = G_GAP_VIS)
// ── User-Defined Types (UDTs) ─────────────────────────────────────────────────
type PivotLevel
    float price
    int   start_bar
    line  l_obj
    bool  is_resistance

type SwingState
    PivotLevel[] res_levels
    PivotLevel[] sup_levels
    label[]      break_labels
    float        prev_ph
    float        prev_pl
    int          res_break_count
    int          sup_break_count

type StructureEngine
    float lastPivotHigh
    float lastPivotLow
    int   lastPivotHighIdx
    int   lastPivotLowIdx

type Gapmetrics
    bool  isValid
    bool  isBullish
    float top
    float bottom
    string gapType
    int   t_start
    int   t_end

// ── Persistent State Initialization ─────────────────────────────────────────
var SwingState state = SwingState.new(
     array.new<PivotLevel>(),
     array.new<PivotLevel>(),
     array.new<label>(),
     na,
     na,
     0,
     0)
var SwingState htf_state = SwingState.new(
     array.new<PivotLevel>(),
     array.new<PivotLevel>(),
     array.new<label>(),
     na,
     na,
     0,
     0)
var float last_htf_ph = na
var float last_htf_pl = na
var array<box>   activeBoxes     = array.new<box>()
var array<line>  activeLines     = array.new<line>()
var array<float> activeLevels    = array.new<float>()
var array<bool>  activeIsBullish = array.new<bool>()
var int          lastHTFTime     = 0
// ── Level Management Functions & Methods ─────────────────────────────────────
method manage_level(SwingState s, float price, int bar_idx, bool is_res, int max_len, bool draw_line, color c_line, int lw = 1) =>
    line new_l = na
    if draw_line
        new_l := line.new(bar_idx, price, bar_index, price, color = c_line, width = lw)
    PivotLevel new_lvl = PivotLevel.new(price, bar_idx, new_l, is_res)
    PivotLevel[] target_arr = is_res ? s.res_levels : s.sup_levels
    target_arr.unshift(new_lvl)
    if target_arr.size() > max_len
        PivotLevel old_lvl = target_arr.pop()
        if not na(old_lvl.l_obj)
            line.delete(old_lvl.l_obj)

method check_breaks(SwingState s, bool is_res, float curr_close, float prev_close, bool vol_ok, int decay_lim, bool use_decay_flag, bool draw_ext) =>
    PivotLevel[] arr = is_res ? s.res_levels : s.sup_levels
    int breaks_found = 0
    int arr_len = arr.size()
    if arr_len > 0
        for i = arr_len - 1 to 0
            PivotLevel lvl = arr.get(i)
            if draw_ext and not na(lvl.l_obj)
                line.set_x2(lvl.l_obj, bar_index)
            bool expired = use_decay_flag and (bar_index - lvl.start_bar > decay_lim)
            bool broken = false
            if is_res
                broken := vol_ok and curr_close > lvl.price and prev_close <= lvl.price
            else
                broken := vol_ok and curr_close < lvl.price and prev_close >= lvl.price
            if broken
                breaks_found += 1
                if is_res
                    s.res_break_count += 1
                else
                    s.sup_break_count += 1
                arr.remove(i)
            else if expired
                if not na(lvl.l_obj)
                    line.delete(lvl.l_obj)
                arr.remove(i)
    breaks_found

// ── Pivot High / Low Detection ────────────────────────────────
f_pivotHigh(series float src, simple int len) =>
    float candidate = src[len]
    bool  isValid   = true
    for i = 1 to len * 2
        if i != len and src[i] >= candidate
            isValid := false
    isValid ? candidate : na

f_pivotLow(series float src, simple int len) =>
    float candidate = src[len]
    bool  isValid   = true
    for i = 1 to len * 2
        if i != len and src[i] <= candidate
            isValid := false
    isValid ? candidate : na

// ── Structure & Gap Analysis Engine ─────────────────────────────────────────
method update(StructureEngine eng, simple int lLen, simple int rLen) =>
    float ph = f_pivotHigh(high, lLen)
    float pl = f_pivotLow(low, lLen)
    if not na(ph)
        eng.lastPivotHigh    := ph
        eng.lastPivotHighIdx := bar_index - rLen
    if not na(pl)
        eng.lastPivotLow    := pl
        eng.lastPivotLowIdx := bar_index - rLen

method analyzeGap(StructureEngine eng, float volAvg, float volMult, int maturityThreshold) =>
    Gapmetrics result = Gapmetrics.new(false, false, na, na, "Standard", time[2], time)
    bool bullGap = low > high[2] and close[1] > open[1]
    bool bearGap = high < low[2] and close[1] < open[1]
    float gapSize = 0.0
    if bullGap
        gapSize          := low - high[2]
        result.isValid   := true
        result.isBullish := true
        result.top       := low
        result.bottom    := high[2]
    else if bearGap
        gapSize          := low[2] - high
        result.isValid   := true
        result.isBullish := false
        result.top       := low[2]
        result.bottom    := high
    if result.isValid and gapSize >= I_MIN_GAP
        bool isBreakout = false
        if result.isBullish and not na(eng.lastPivotHigh)
            isBreakout := close[1] > eng.lastPivotHigh and close[2] <= eng.lastPivotHigh
        else if not result.isBullish and not na(eng.lastPivotLow)
            isBreakout := close[1] < eng.lastPivotLow and close[2] >= eng.lastPivotLow
        bool isHighVolume = volume[1] > volAvg * volMult
        int trendDuration = 0
        if result.isBullish
            if not na(eng.lastPivotLowIdx)
                trendDuration := bar_index - eng.lastPivotLowIdx
        else
            if not na(eng.lastPivotHighIdx)
                trendDuration := bar_index - eng.lastPivotHighIdx
        bool isExtended      = trendDuration > maturityThreshold
        bool isExhaustionSig = isHighVolume and isExtended
        if isBreakout
            result.gapType := "BW"
        else if isExhaustionSig
            result.gapType := "EX"
        else
            result.gapType := "RW"
    else
        result.isValid := false
    result

f_calculateGapLogic(simple int pLeft, simple int pRight, simple int vLen, float vMult, int tMat, float minGap) =>
    var StructureEngine localEngine = StructureEngine.new(na, na, na, na)
    localEngine.update(pLeft, pRight)
    float volMA  = ta.sma(volume, vLen)
    Gapmetrics g = localEngine.analyzeGap(volMA, vMult, tMat)
    if g.isValid and (g.top - g.bottom) < minGap
        g.isValid := false
    g

calc_ph(simple int l) =>
    f_pivotHigh(high, l)[1]

calc_pl(simple int l) =>
    f_pivotLow(low, l)[1]

// ── Data Requests (MTF) ──────────────────────────────────────────────────────
float raw_ph  = request.security(syminfo.tickerid, tf_input,  calc_ph(leftBars),  lookahead = barmerge.lookahead_on)
float raw_pl  = request.security(syminfo.tickerid, tf_input,  calc_pl(leftBars),  lookahead = barmerge.lookahead_on)
float htf_ph  = request.security(syminfo.tickerid, htf_tf,    calc_ph(htf_left),  lookahead = barmerge.lookahead_on)
float htf_pl  = request.security(syminfo.tickerid, htf_tf,    calc_pl(htf_left),  lookahead = barmerge.lookahead_on)
float vol_ma_val   = use_vol ? ta.sma(volume, vol_len) : na
bool vol_confirmed = not use_vol or volume > vol_ma_val
bool show_ltf      = not (use_htf and hide_ltf)
bool is_new_htf_ph = not na(htf_ph) and (na(last_htf_ph) or htf_ph != last_htf_ph)
bool is_new_htf_pl = not na(htf_pl) and (na(last_htf_pl) or htf_pl != last_htf_pl)
Gapmetrics currentGap = f_calculateGapLogic(I_PIVOT_L, I_PIVOT_R, I_VOL_LEN, I_VOL_MULT, I_TREND_MAT, I_MIN_GAP)
Gapmetrics htfGap = Gapmetrics.new(false, false, na, na, "", 0, 0)
if I_HTF_ON
    htfGap := request.security(syminfo.tickerid, I_HTF_TF, f_calculateGapLogic(I_PIVOT_L, I_PIVOT_R, I_VOL_LEN, I_VOL_MULT, I_TREND_MAT, I_MIN_GAP), lookahead = barmerge.lookahead_on)
var float visual_ph     = na
var float visual_pl     = na
var float visual_htf_ph = na
var float visual_htf_pl = na
// ── Structure Label & Break Colors ───────────────────────────────────────────
color C_HH_LBL  = color.rgb(255, 80, 80, 0)
color C_LH_LBL  = color.rgb(255, 160, 60, 0)
color C_HL_LBL  = color.rgb(80, 220, 120, 0)
color C_LL_LBL  = color.rgb(60, 180, 255, 0)
color C_EH_LBL  = color.rgb(200, 100, 255, 0)
color C_EL_LBL  = color.rgb(200, 100, 255, 0)
color C_BRK_UP  = color.rgb(0, 210, 120, 0)
color C_BRK_DN  = color.rgb(255, 60, 60, 0)
color C_HTF_BRK_UP = color.rgb(0, 240, 200, 0)
color C_HTF_BRK_DN = color.rgb(255, 120, 0, 0)
// ── Draw Current Timeframe Levels ────────────────────────────────────────────
if show_ltf
    if not na(raw_ph)
        visual_ph := raw_ph
        if show_struct
            string txt = "EH"
            color  lbl_c = C_EH_LBL
            if not na(state.prev_ph)
                bool isHH = raw_ph > state.prev_ph
                txt   := isHH ? "HH" : "LH"
                lbl_c := isHH ? C_HH_LBL : C_LH_LBL
            label.new(bar_index - rightBars, raw_ph, text = txt + "\n" + str.tostring(raw_ph, format.mintick), color = color(na), textcolor = lbl_c, style = label.style_label_down, size = size.normal)
        state.prev_ph := raw_ph
        state.manage_level(raw_ph, bar_index - rightBars, true, maxLevels, show_ext, C_RES, 1)
    if not na(raw_pl)
        visual_pl := raw_pl
        if show_struct
            string txt = "EL"
            color  lbl_c = C_EL_LBL
            if not na(state.prev_pl)
                bool isLL = raw_pl < state.prev_pl
                txt   := isLL ? "LL" : "HL"
                lbl_c := isLL ? C_LL_LBL : C_HL_LBL
            label.new(bar_index - rightBars, raw_pl, text = txt + "\n" + str.tostring(raw_pl, format.mintick), color = color(na), textcolor = lbl_c, style = label.style_label_up, size = size.normal)
        state.prev_pl := raw_pl
        state.manage_level(raw_pl, bar_index - rightBars, false, maxLevels, show_ext, C_SUP, 1)
// ── Draw Higher Timeframe (HTF) Levels ───────────────────────────────────────
if use_htf
    if is_new_htf_ph
        visual_htf_ph := htf_ph
        if show_struct
            string htf_txt = "HTF-R"
            color  htf_lbl_c = C_HTF_RES
            if not na(htf_state.prev_ph)
                bool isHTF_HH = htf_ph > htf_state.prev_ph
                htf_txt   := isHTF_HH ? "HTF-HH" : "HTF-LH"
                htf_lbl_c := isHTF_HH ? color.rgb(255, 100, 50, 0) : color.rgb(255, 180, 60, 0)
            label.new(bar_index, htf_ph, text = htf_txt + "\n" + str.tostring(htf_ph, format.mintick), color = color(na), textcolor = htf_lbl_c, style = label.style_label_down, size = size.large)
        htf_state.prev_ph := htf_ph
        htf_state.manage_level(htf_ph, bar_index, true, htf_max, true, C_HTF_RES, htf_linewidth)
        last_htf_ph := htf_ph
    if is_new_htf_pl
        visual_htf_pl := htf_pl
        if show_struct
            string htf_txt = "HTF-S"
            color  htf_lbl_c = C_HTF_SUP
            if not na(htf_state.prev_pl)
                bool isHTF_LL = htf_pl < htf_state.prev_pl
                htf_txt   := isHTF_LL ? "HTF-LL" : "HTF-HL"
                htf_lbl_c := isHTF_LL ? color.rgb(0, 180, 255, 0) : color.rgb(80, 240, 160, 0)
            label.new(bar_index, htf_pl, text = htf_txt + "\n" + str.tostring(htf_pl, format.mintick), color = color(na), textcolor = htf_lbl_c, style = label.style_label_up, size = size.large)
        htf_state.prev_pl := htf_pl
        htf_state.manage_level(htf_pl, bar_index, false, htf_max, true, C_HTF_SUP, htf_linewidth)
        last_htf_pl := htf_pl
// ── Level Break Detection & Label Drawing ────────────────────────────────────
int res_breaks_now = show_ltf ? state.check_breaks(true, close, close[1], vol_confirmed, decay_bars, use_decay, show_ext) : 0
int sup_breaks_now = show_ltf ? state.check_breaks(false, close, close[1], vol_confirmed, decay_bars, use_decay, show_ext) : 0
int htf_res_breaks = use_htf ? htf_state.check_breaks(true, close, close[1], true, 9999, false, true) : 0
int htf_sup_breaks = use_htf ? htf_state.check_breaks(false, close, close[1], true, 9999, false, true) : 0
bool needs_any_break = res_breaks_now > 0 or sup_breaks_now > 0 or htf_res_breaks > 0 or htf_sup_breaks > 0
float gap_base = needs_any_break ? nz(ta.atr(14), syminfo.mintick * 10) : 0.0
if res_breaks_now > 0
    float offset = gap_base * (0.5 + (0.1 * res_breaks_now))
    label lbl = label.new(bar_index, low - offset, text = "▲\n" + str.tostring(res_breaks_now), color = C_BRK_UP, textcolor = C_TXT, style = label.style_label_up, size = size.small)
    state.break_labels.push(lbl)
if sup_breaks_now > 0
    float offset = gap_base * (0.5 + (0.1 * sup_breaks_now))
    label lbl = label.new(bar_index, high + offset, text = "▼\n" + str.tostring(sup_breaks_now), color = C_BRK_DN, textcolor = C_TXT, style = label.style_label_down, size = size.small)
    state.break_labels.push(lbl)
if htf_res_breaks > 0
    float offset = gap_base * 1.5 * (0.8 + (0.15 * htf_res_breaks))
    label lbl = label.new(bar_index, low - offset, text = "▲ HTF\n" + str.tostring(htf_res_breaks), color = C_HTF_BRK_UP, textcolor = C_TXT, style = label.style_label_up, size = size.normal)
    htf_state.break_labels.push(lbl)
if htf_sup_breaks > 0
    float offset = gap_base * 1.5 * (0.8 + (0.15 * htf_sup_breaks))
    label lbl = label.new(bar_index, high + offset, text = "▼ HTF\n" + str.tostring(htf_sup_breaks), color = C_HTF_BRK_DN, textcolor = C_TXT, style = label.style_label_down, size = size.normal)
    htf_state.break_labels.push(lbl)
if state.break_labels.size() > maxLabels
    label.delete(state.break_labels.shift())
if htf_state.break_labels.size() > maxLabels
    label.delete(htf_state.break_labels.shift())
// ── Gap Drawing Function (Gap Boxes) ─────────────────────────────────────────
f_drawGap(Gapmetrics g, int extPixels, string tag, color textColor, string tSize) =>
    color boxColor = na
    color midColor = na
    string txt = na
    if g.gapType == "BW"
        boxColor := C_BREAKAWAY
        midColor := color.rgb(30, 120, 255, 20)
        txt      := "BW"
    else if g.gapType == "RW"
        boxColor := C_RUNAWAY
        midColor := color.rgb(255, 165, 0, 20)
        txt      := "RW"
    else if g.gapType == "EX"
        boxColor := C_EXHAUSTION
        midColor := color.rgb(220, 40, 80, 20)
        txt      := "EX"
    txt := txt + tag
    int extensionTime = int(extPixels * timeframe.in_seconds(timeframe.period) * 1000)
    box b = box.new(left = g.t_start, top = g.top, bottom = g.bottom, right = time + extensionTime,
         xloc = xloc.bar_time,
         bgcolor = boxColor,
         border_color = na,
         text = txt, text_color = textColor, text_size = tSize)
    float mid = math.avg(g.top, g.bottom)
    line l = line.new(x1 = g.t_start, y1 = mid, x2 = time + extensionTime, y2 = mid,
         xloc = xloc.bar_time,
         color = midColor, style = line.style_dotted)
    array.push(activeBoxes, b)
    array.push(activeLines, l)
    array.push(activeLevels, mid)
    array.push(activeIsBullish, g.isBullish)

// ── Activate Current & HTF Gap Drawing ───────────────────────────────────────
if currentGap.isValid
    color gap_txt_c = currentGap.isBullish ? color.rgb(80, 255, 160, 0) : color.rgb(255, 100, 100, 0)
    f_drawGap(currentGap, I_EXTEND, "", gap_txt_c, size.small)
if I_HTF_ON and htfGap.isValid and htfGap.t_start != lastHTFTime
    f_drawGap(htfGap, I_EXTEND, " [HTF]", I_HTF_TXT_C, size.normal)
    lastHTFTime := htfGap.t_start
int _sz = array.size(activeBoxes)
if _sz > 0
    for i = _sz - 1 to 0
        float level = array.get(activeLevels, i)
        bool isBull = array.get(activeIsBullish, i)
        bool remove = false
        if isBull and low <= level
            remove := true
        else if not isBull and high >= level
            remove := true
        if remove
            box.delete(array.get(activeBoxes, i))
            line.delete(array.get(activeLines, i))
            array.remove(activeBoxes, i)
            array.remove(activeLines, i)
            array.remove(activeLevels, i)
            array.remove(activeIsBullish, i)
plot(show_ltf ? visual_ph : na, "Pivot High Extension", style = plot.style_cross, color = C_RES, linewidth = 1, offset = -rightBars, display = display.all - display.price_scale - display.status_line)
plot(show_ltf ? visual_pl : na, "Pivot Low Extension", style = plot.style_cross, color = C_SUP, linewidth = 1, offset = -rightBars, display = display.all - display.price_scale - display.status_line)
plot(use_htf ? visual_htf_ph : na, "HTF Pivot High", style = plot.style_cross, color = C_HTF_RES, linewidth = 3, display = display.all - display.price_scale - display.status_line)
plot(use_htf ? visual_htf_pl : na, "HTF Pivot Low", style = plot.style_cross, color = C_HTF_SUP, linewidth = 3, display = display.all - display.price_scale - display.status_line)
alertcondition(res_breaks_now > 0, title = "Resistance Breakout", message = "Resistance Level Broken!")
alertcondition(sup_breaks_now > 0, title = "Support Breakout", message = "Support Level Broken!")
alertcondition(htf_res_breaks > 0, title = "HTF Resistance Breakout", message = "HTF Resistance Level Broken!")
alertcondition(htf_sup_breaks > 0, title = "HTF Support Breakout", message = "HTF Support Level Broken!")
````
