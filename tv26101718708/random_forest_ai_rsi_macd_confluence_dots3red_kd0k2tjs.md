# Random Forest AI - RSI MACD Confluence [Dots3Red]

- url: https://www.tradingview.com/script/kd0k2tJS-Random-Forest-AI-RSI-MACD-Confluence-Dots3Red/
- type: indicator
- pine_id: PUB;5d167170169543d09fc95c1e26466361
- version: 1.0

## Description

█ RANDOM FOREST AI — RSI MACD CONFLUENCE [Dots3Red]
This script combines 15 simple, independent decision rules ("trees") into one weighted verdict. Each tree looks at a different combination of RSI, MACD, ATR, volume, DMI, and price-vs-moving-average conditions and casts one vote: bullish, bearish, or neutral. What makes this different from simply averaging several indicators is that every tree's historical accuracy is tracked continuously, and that accuracy becomes the tree's voting weight — a rule that has actually been right more often on this specific chart counts for more than one that hasn't.

█ WHY THIS APPROACH
A single indicator like RSI applies the same fixed rule forever: "below 30 means buy," regardless of whether that rule has been working lately on the instrument you're watching. It has no way to notice that its own signal has become less reliable in a strong trend, or more reliable during a ranging period.

This script addresses that by running many small, simple rules in parallel and grading each one against what actually happened afterward. A rule's influence on the final verdict rises when it's been accurate and falls when it hasn't — without requiring the trader to manually decide which indicator to trust in current conditions.

This is a simplified, Pine-native ensemble. A literal machine-learning Random Forest trains via recursive data-splitting across bootstrap-sampled datasets, which isn't something Pine Script's execution model supports. What's implemented here captures the core idea in a form that runs natively on every bar: multiple diverse, simple voters, weighted by empirical track record rather than by a fixed formula.

█ HOW IT WORKS
[b]1. Base features[/b]
Six indicators are computed every bar and feed into the trees:
• RSI (configurable length)
• MACD histogram
• ATR ratio — current ATR relative to a 50-bar baseline (volatility context)
• Volume ratio — current volume relative to its moving average
• DI difference — +DI minus -DI from the DMI system (directional pressure)
• Price vs. moving average — distance from a trend MA, expressed in ATR units

[b]2. The 15 trees[/b]
Each tree is a short, explicit rule combining two or three of the base features. They are deliberately varied in character:
• Some are trend-following (DI direction, MACD momentum, full trend confluence combining three features at once)
• Some are contrarian / mean-reversion (an extreme price extension combined with an extreme RSI reading votes for a pullback, not a continuation)
• Some are volatility-filtered (an RSI extreme only counts when the ATR ratio shows calm conditions, on the reasoning that overbought/oversold readings are less reliable during high volatility)
• Some require multi-indicator confluence before voting at all (MACD direction agreeing with volume expansion, or RSI agreeing with MACD)

Any single tree by itself is simplistic. The value comes from having 15 of them looking at the situation from different angles simultaneously.

[b]3. Historical grading and weighting[/b]
Every tree's vote from a configurable number of bars ago ("Outcome Window") is compared against what price actually did between then and now. If the tree voted bullish and price rose, that's a correct call; if it voted bullish and price fell, that's incorrect. A running hit/total count is kept per tree.

Each tree's weight is its accuracy rate (hits ÷ total) once it has accumulated a minimum number of graded votes. Before that minimum is reached, a tree counts at a neutral 0.5 weight so early, unproven trees don't disproportionately swing the verdict.

[b]4. The forest verdict[/b]
Bullish and bearish contributions are summed across all 15 trees, weighted by each tree's current accuracy, then expressed as a percentage split (e.g. 73% bullish / 27% bearish). The overall verdict — BULLISH, BEARISH, or NEUTRAL — is determined by configurable thresholds (default: 60% for bullish, below 40% bullish-share for bearish).

[b]5. RSI confluence[/b]
Separately from its role inside the 15 trees, RSI's classic overbought/oversold state is checked against the forest's overall verdict. If RSI is oversold and the forest is bullish, that's flagged as "AGREE." If RSI is oversold but the forest is bearish, that's flagged as "CONFLICT." This gives a second, independent read using the indicator most traders already know, alongside the ensemble's own conclusion.


█ SIGNAL MARKERS AND SPACING
A marker appears only when three conditions line up at once: the forest's weighted verdict crosses its threshold, RSI's classic overbought/oversold state independently agrees with that direction, and the bar has fully closed. Markers never appear on a still-forming bar — the script waits for bar confirmation so a marker never appears and then vanishes as the live bar changes.

Each marker is drawn in two parts: a small triangle at the bar, and a text block showing three values — the weighted percentage that triggered it, the word AGREE confirming RSI's independent agreement, and how many of the 15 trees were actively voting (non-neutral) at that moment. A reading of "73% / AGREE / 9/15 trees" carries different weight than "61% / AGREE / 4/15 trees," even though both pass the threshold — the first reflects broad participation across the ensemble, the second a thin majority among few active voters.

Two mechanisms prevent marker clutter on intraday timeframes:
• [b]One marker per episode[/b] — when the verdict enters a bullish or bearish state, only the first qualifying signal of that run is marked. The verdict flickering around the threshold (61% → 59% → 62%) does not produce repeated markers; the internal latch resets only when the verdict genuinely changes state.
• [b]Signal Cooldown[/b] — a configurable minimum number of bars between same-side markers, which absorbs the remaining case where a brief state change resets the latch and the condition re-triggers shortly after. On a 5-minute chart, a cooldown of 30 bars means at least 2.5 hours between same-direction markers.

Both mechanisms apply per direction — a bearish marker shortly after a bullish one is never suppressed, because an ensemble flip is meaningful information rather than clutter.


█ READING THE CHART
[b]Bar coloring[/b] tints candles by the current verdict — cyan for bullish, magenta for bearish, slate for neutral.

[b]Dashboard[/b] (top-right by default) shows the current verdict, the bull/bear percentage split with a progress bar, how many trees are actively voting, RSI's state and its agreement with the verdict, and a breakdown of five representative trees showing each one's live weight and how many samples that weight is based on.


█ SETTINGS
[b]Feature Settings[/b] — lengths for RSI, MACD, ATR baseline, volume MA, DMI, and the trend MA used by the price-vs-MA feature.

[b]Ensemble Settings[/b]
• Outcome Window (bars) — how far ahead each vote is checked against actual price movement
• Min Samples Before Weighting — how many graded votes a tree needs before its real accuracy replaces the neutral 0.5 default
• Bullish / Bearish Threshold % — where the weighted percentage split has to cross before the verdict label changes

[b]Visualization[/b]
• Color Bars by Verdict — toggle candle tinting
• Show Confluence Markers — toggle the triangle markers
• Signal Cooldown (bars) — minimum bars between same-side markers; raise this on lower timeframes if markers feel too frequent

[b]Dashboard[/b] — toggle the table, choose its position, toggle the per-tree accuracy breakdown.


█ EXAMPLE
Suppose the dashboard shows: Verdict BULLISH, 73% / 27%, 9/15 trees active, RSI at 28 (OVERSOLD), Agreement: AGREE. This means the weighted vote across all 15 trees currently favors upside by roughly 3-to-1, nine of the trees have a non-neutral opinion right now, and the classic RSI reading independently supports the same bullish read. If the per-tree breakdown shows "Calm-Market RSI" at 78% (n=45) while "RSI Extremes" sits at 52% (n=45), that's telling you the version of the RSI rule that only fires during low volatility has actually been considerably more reliable on this chart than the raw, unfiltered version — information a plain RSI plot could never surface on its own.

[image]https://www.tradingview.com/x/BAgIKGrq/[/image]


█ NOTES
Weights start neutral and only become meaningful once each tree has accumulated enough graded votes (set by "Min Samples Before Weighting"). On a fresh chart or a newly added timeframe, expect the dashboard's percentages to be less informative until that history builds up. The ensemble adapts continuously — a tree's weight can and will drift as market conditions change and its track record evolves.

On intraday timeframes, tune the Signal Cooldown to the chart's pace. The default suits higher timeframes; 5-minute and 15-minute charts generally benefit from a larger value.

█ DISCLAIMER
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical accuracy of any individual rule or the ensemble as a whole does not guarantee future performance.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Random Forest AI — RSI MACD Confluence [Dots3Red]",
          shorttitle = "RF - RSI MACD Confluence [D3R]",
          overlay    = true,
          max_labels_count = 500)


// COLORS
C_BULL    = color.new(#00F0FF, 0)
C_BEAR    = color.new(#FF00AA, 0)
C_GREEN   = color.new(#00FF9D, 0)
C_RED     = color.new(#FF0055, 0)
C_AMBER   = color.new(#ffb700, 0)
C_NEUTRAL = color.new(#64748b, 0)
C_BG      = color.new(#131722, 5)
C_TXT     = color.new(#f8fafc, 0)
C_DIM     = color.new(#94a3b8, 0)
C_BORD    = color.new(#334155, 0)


// INPUTS
GRP_FEAT = "📐 Feature Settings"
GRP_ENS  = "🌲 Ensemble Settings"
GRP_VIS  = "🎨 Visualization"
GRP_HUD  = "🖥️ Dashboard"

rsi_len   = input.int(14, "RSI Length", group=GRP_FEAT)
macd_fast = input.int(12, "MACD Fast", group=GRP_FEAT)
macd_slow = input.int(26, "MACD Slow", group=GRP_FEAT)
macd_sig  = input.int(9,  "MACD Signal", group=GRP_FEAT)
atr_base_len = input.int(50, "ATR Baseline Period", group=GRP_FEAT)
vol_ma_len   = input.int(20, "Volume MA Period", group=GRP_FEAT)
dmi_len      = input.int(14, "DMI Length", group=GRP_FEAT)
ma_len       = input.int(50, "Trend MA Length", group=GRP_FEAT)

outcome_bars     = input.int(10, "Outcome Window (bars)", minval=3, maxval=50, group=GRP_ENS,
                   tooltip="Bars after each vote to check whether price actually moved the voted direction.")
min_track_samples = input.int(20, "Min Samples Before Weighting", minval=5, maxval=200, group=GRP_ENS,
                   tooltip="A tree's accuracy weight only kicks in once it has this many graded votes. Before that, it counts as a neutral 0.5 weight.")
bull_thresh = input.float(60.0, "Bullish Threshold %", minval=50.0, maxval=90.0, group=GRP_ENS)
bear_thresh = input.float(40.0, "Bearish Threshold %", minval=10.0, maxval=50.0, group=GRP_ENS)

show_bar_color = input.bool(true, "Color Bars by Verdict", group=GRP_VIS)
show_markers   = input.bool(true, "Show Confluence Markers", group=GRP_VIS)
signal_cooldown = input.int(10, "Signal Cooldown (bars)", minval=0, maxval=100, group=GRP_VIS)


show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_HUD)
show_tree_breakdown = input.bool(true, "Show Per-Tree Accuracy", group=GRP_HUD)


// BASE FEATURES — every bar, plain series so [n] history indexing works
rsi_val = ta.rsi(close, rsi_len)
[macd_line, macd_signal, macd_hist] = ta.macd(close, macd_fast, macd_slow, macd_sig)

atr_raw     = ta.atr(14)
atr_base_ma = ta.sma(atr_raw, atr_base_len)
atr_ratio   = atr_raw / math.max(atr_base_ma, 1e-9)

vol_ma   = ta.sma(volume, vol_ma_len)
vol_ratio = vol_ma > 0 ? volume / vol_ma : 1.0

[plus_di, minus_di, adx_val] = ta.dmi(dmi_len, dmi_len)
di_diff = plus_di - minus_di

trend_ma    = ta.sma(close, ma_len)
price_vs_ma = (close - trend_ma) / math.max(atr_raw, 1e-9)


// THE 15 TREES — each a small explicit rule, deliberately diverse
vote1  = rsi_val < 30 ? 1.0 : rsi_val > 70 ? -1.0 : 0.0
vote2  = macd_hist > 0 ? 1.0 : macd_hist < 0 ? -1.0 : 0.0
vote3  = (rsi_val < 40 and macd_hist > 0) ? 1.0 : (rsi_val > 60 and macd_hist < 0) ? -1.0 : 0.0
vote4  = di_diff > 5 ? 1.0 : di_diff < -5 ? -1.0 : 0.0
vote5  = price_vs_ma > 0.5 ? 1.0 : price_vs_ma < -0.5 ? -1.0 : 0.0
vote6  = (macd_hist > 0 and vol_ratio > 1.2) ? 1.0 : (macd_hist < 0 and vol_ratio > 1.2) ? -1.0 : 0.0
vote7  = (rsi_val > 50 and rsi_val > rsi_val[1]) ? 1.0 : (rsi_val < 50 and rsi_val < rsi_val[1]) ? -1.0 : 0.0
vote8  = (atr_ratio < 1.5 and di_diff > 3) ? 1.0 : (atr_ratio < 1.5 and di_diff < -3) ? -1.0 : 0.0
vote9  = (price_vs_ma > 1.0 and rsi_val > 65) ? -1.0 : (price_vs_ma < -1.0 and rsi_val < 35) ? 1.0 : 0.0
vote10 = (vol_ratio > 2.0 and macd_hist < 0) ? -1.0 : (vol_ratio > 2.0 and macd_hist > 0) ? 1.0 : 0.0
vote11 = (rsi_val > 50 and rsi_val < 70) ? 1.0 : (rsi_val < 50 and rsi_val > 30) ? -1.0 : 0.0
vote12 = (di_diff > 0 and vol_ratio > 1.0) ? 1.0 : (di_diff < 0 and vol_ratio > 1.0) ? -1.0 : 0.0
vote13 = (macd_hist > 0 and price_vs_ma > 0) ? 1.0 : (macd_hist < 0 and price_vs_ma < 0) ? -1.0 : 0.0
vote14 = (atr_ratio < 1.2 and rsi_val < 30) ? 1.0 : (atr_ratio < 1.2 and rsi_val > 70) ? -1.0 : 0.0
vote15 = (di_diff > 0 and macd_hist > 0 and price_vs_ma > 0) ? 1.0 :
         (di_diff < 0 and macd_hist < 0 and price_vs_ma < 0) ? -1.0 : 0.0

string tree1_name  = "RSI Extremes"
string tree2_name  = "MACD Momentum"
string tree3_name  = "RSI+MACD Confluence"
string tree4_name  = "DI Direction"
string tree5_name  = "Price vs MA"
string tree6_name  = "Volume-Confirmed MACD"
string tree7_name  = "RSI Momentum Shift"
string tree8_name  = "ATR-Filtered DI"
string tree9_name  = "Mean-Reversion Extremes"
string tree10_name = "Volume Spike Reversal"
string tree11_name = "RSI Trend Zone"
string tree12_name = "DI+Volume Confluence"
string tree13_name = "MACD+Trend Position"
string tree14_name = "Calm-Market RSI"
string tree15_name = "Full Trend Confluence"

// PER-TREE ACCURACY TRACKING — graded against what actually happened
var int[] hits   = array.new<int>(15, 0)
var int[] totals = array.new<int>(15, 0)

f_grade(float past_vote, float ret) =>
    bool graded  = false
    bool correct = false
    if past_vote != 0.0
        graded  := true
        correct := (past_vote > 0 and ret > 0) or (past_vote < 0 and ret < 0)
    [graded, correct]

if barstate.isconfirmed and bar_index >= outcome_bars
    float ret_now = close - close[outcome_bars]

    votes_hist = array.from(
         vote1[outcome_bars],  vote2[outcome_bars],  vote3[outcome_bars],
         vote4[outcome_bars],  vote5[outcome_bars],  vote6[outcome_bars],
         vote7[outcome_bars],  vote8[outcome_bars],  vote9[outcome_bars],
         vote10[outcome_bars], vote11[outcome_bars], vote12[outcome_bars],
         vote13[outcome_bars], vote14[outcome_bars], vote15[outcome_bars])

    for i = 0 to 14
        float pv = array.get(votes_hist, i)
        [graded, correct] = f_grade(pv, ret_now)
        if graded
            array.set(totals, i, array.get(totals, i) + 1)
            if correct
                array.set(hits, i, array.get(hits, i) + 1)


// WEIGHTS — accuracy once enough samples, neutral 0.5 until then
f_weight(int i) =>
    int t = array.get(totals, i)
    float w = t >= min_track_samples ? float(array.get(hits, i)) / float(t) : 0.5
    w

w1  = f_weight(0)
w2  = f_weight(1)
w3  = f_weight(2)
w4  = f_weight(3)
w5  = f_weight(4)
w6  = f_weight(5)
w7  = f_weight(6)
w8  = f_weight(7)
w9  = f_weight(8)
w10 = f_weight(9)
w11 = f_weight(10)
w12 = f_weight(11)
w13 = f_weight(12)
w14 = f_weight(13)
w15 = f_weight(14)


// FOREST AGGREGATE — weighted vote share
f_bull_contrib(float v, float w) => v > 0 ? w : 0.0
f_bear_contrib(float v, float w) => v < 0 ? w : 0.0

bull_score = f_bull_contrib(vote1,w1)  + f_bull_contrib(vote2,w2)  + f_bull_contrib(vote3,w3) +
             f_bull_contrib(vote4,w4)  + f_bull_contrib(vote5,w5)  + f_bull_contrib(vote6,w6) +
             f_bull_contrib(vote7,w7)  + f_bull_contrib(vote8,w8)  + f_bull_contrib(vote9,w9) +
             f_bull_contrib(vote10,w10)+ f_bull_contrib(vote11,w11)+ f_bull_contrib(vote12,w12)+
             f_bull_contrib(vote13,w13)+ f_bull_contrib(vote14,w14)+ f_bull_contrib(vote15,w15)

bear_score = f_bear_contrib(vote1,w1)  + f_bear_contrib(vote2,w2)  + f_bear_contrib(vote3,w3) +
             f_bear_contrib(vote4,w4)  + f_bear_contrib(vote5,w5)  + f_bear_contrib(vote6,w6) +
             f_bear_contrib(vote7,w7)  + f_bear_contrib(vote8,w8)  + f_bear_contrib(vote9,w9) +
             f_bear_contrib(vote10,w10)+ f_bear_contrib(vote11,w11)+ f_bear_contrib(vote12,w12)+
             f_bear_contrib(vote13,w13)+ f_bear_contrib(vote14,w14)+ f_bear_contrib(vote15,w15)

total_score = bull_score + bear_score
bull_pct    = total_score > 0 ? bull_score / total_score * 100.0 : 50.0
bear_pct    = 100.0 - bull_pct

int active_trees = 0
if vote1 != 0
    active_trees += 1
if vote2 != 0
    active_trees += 1
if vote3 != 0
    active_trees += 1
if vote4 != 0
    active_trees += 1
if vote5 != 0
    active_trees += 1
if vote6 != 0
    active_trees += 1
if vote7 != 0
    active_trees += 1
if vote8 != 0
    active_trees += 1
if vote9 != 0
    active_trees += 1
if vote10 != 0
    active_trees += 1
if vote11 != 0
    active_trees += 1
if vote12 != 0
    active_trees += 1
if vote13 != 0
    active_trees += 1
if vote14 != 0
    active_trees += 1
if vote15 != 0
    active_trees += 1

string verdict = bull_pct >= bull_thresh ? "BULLISH" : bear_pct >= (100.0 - bear_thresh) ? "BEARISH" : "NEUTRAL"
color  verdict_c = bull_pct >= bull_thresh ? C_BULL : bear_pct >= (100.0 - bear_thresh) ? C_BEAR : C_NEUTRAL


// RSI CONFLUENCE — does the classic overbought/oversold state
// agree or conflict with the forest's overall verdict?
int    rsi_bias = rsi_val < 30 ? 1 : rsi_val > 70 ? -1 : 0
string rsi_state = rsi_val < 30 ? "OVERSOLD" : rsi_val > 70 ? "OVERBOUGHT" : "NEUTRAL"

string confluence = "—"
color  confluence_c = C_DIM
if rsi_bias != 0
    bool agrees = (rsi_bias > 0 and verdict == "BULLISH") or (rsi_bias < 0 and verdict == "BEARISH")
    bool conflicts = (rsi_bias > 0 and verdict == "BEARISH") or (rsi_bias < 0 and verdict == "BULLISH")
    if agrees
        confluence   := "AGREE"
        confluence_c := C_GREEN
    else if conflicts
        confluence   := "CONFLICT"
        confluence_c := C_AMBER


// VISUALS
barcolor(show_bar_color ? color.new(verdict_c, 40) : na)

bool strong_bull_signal = show_markers and verdict == "BULLISH" and confluence == "AGREE" and bull_pct >= bull_thresh
bool strong_bear_signal = show_markers and verdict == "BEARISH" and confluence == "AGREE" and bear_pct >= (100.0 - bear_thresh)

bool strong_bull_new = strong_bull_signal and not strong_bull_signal[1]
bool strong_bear_new = strong_bear_signal and not strong_bear_signal[1]

var int last_bull_bar = na
var int last_bear_bar = na
var bool fired_this_run = false
bool can_fire_bull = na(last_bull_bar) or (bar_index - last_bull_bar) >= signal_cooldown
bool can_fire_bear = na(last_bear_bar) or (bar_index - last_bear_bar) >= signal_cooldown

// Reset the latch whenever the verdict changes state
if verdict != verdict[1]
    fired_this_run := false


if barstate.isconfirmed
    if strong_bull_new and can_fire_bull and not fired_this_run
        label.new(bar_index, na, text="",
                style=label.style_triangleup, yloc=yloc.belowbar,
                color=color.new(C_GREEN, 15), size=4)
        string bull_txt = str.tostring(math.round(bull_pct)) + "%\nAGREE\n" + str.tostring(active_trees) + "/15 trees"
        float  bull_txt_y = low - atr_raw * 3.5
        label.new(bar_index, bull_txt_y, text=bull_txt,
                style=label.style_label_center,
                color=color.new(#000000, 100), textcolor=C_GREEN,
                size=size.small)
        last_bull_bar := bar_index
        fired_this_run := true

    if strong_bear_new and can_fire_bear and not fired_this_run
        label.new(bar_index, na, text="",
                style=label.style_triangledown, yloc=yloc.abovebar,
                color=color.new(C_RED, 15), size=4)
        string bear_txt = str.tostring(math.round(bear_pct)) + "%\nAGREE\n" + str.tostring(active_trees) + "/15 trees"
        float  bear_txt_y = high + atr_raw * 4.5
        label.new(bar_index, bear_txt_y, text=bear_txt,
                style=label.style_label_center,
                color=color.new(#000000, 100), textcolor=C_RED,
                size=size.small)
        last_bear_bar := bar_index
        fired_this_run := true


// DASHBOARD
f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

var table hud = table.new(f_hud_pos(hud_pos), 2, 20,
                           bgcolor=C_BG, border_color=C_BORD,
                           border_width=1, frame_color=C_BORD, frame_width=2)

f_row(int row_i, string name, float v, float w, int tot) =>
    string vs = v > 0 ? "▲" : v < 0 ? "▼" : "–"
    color  vc = v > 0 ? C_BULL : v < 0 ? C_BEAR : C_DIM
    string txt = str.tostring(math.round(w * 100)) + "%  (n=" + str.tostring(tot) + ")"
    table.cell(hud, 0, row_i, vs + " " + name, text_color=vc, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, row_i, txt, text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

if show_hud and barstate.islast
    table.cell(hud, 0, 0, "RANDOM FOREST [D3R]", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "Verdict", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 1, verdict, text_color=verdict_c, bgcolor=color.new(#1e293b, 40),
               text_size=11, text_halign=text.align_center, text_formatting=text.format_bold)

    int fb = math.round(bull_pct / 10)
    string pb = ""
    for _i = 1 to 10
        pb += _i <= fb ? "■" : "□"
    table.cell(hud, 0, 2, "Bull / Bear %", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 2, pb + "  " + str.tostring(math.round(bull_pct)) + "% / " + str.tostring(math.round(bear_pct)) + "%",
               text_color=verdict_c, bgcolor=color.new(#0f172a, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 3, "Active Trees", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 3, str.tostring(active_trees) + " / 15", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 4, "─── RSI Confluence ───", text_color=C_DIM,
               bgcolor=color.new(#0f172a, 0), text_size=11, text_halign=text.align_center)
    table.merge_cells(hud, 0, 4, 1, 4)

    table.cell(hud, 0, 5, "RSI State", text_color=C_DIM, bgcolor=color.new(#1e293b, 40), text_size=11)
    table.cell(hud, 1, 5, rsi_state + " (" + str.tostring(math.round(rsi_val)) + ")",
               text_color=C_TXT, bgcolor=color.new(#1e293b, 40), text_size=11, text_halign=text.align_center)

    table.cell(hud, 0, 6, "Agreement", text_color=C_DIM, bgcolor=color.new(#0f172a, 40), text_size=11)
    table.cell(hud, 1, 6, confluence, text_color=confluence_c, bgcolor=color.new(#0f172a, 40),
               text_size=11, text_halign=text.align_center, text_formatting=text.format_bold)

    if show_tree_breakdown
        table.cell(hud, 0, 7, "─── Top Weighted Trees ───", text_color=C_DIM,
                   bgcolor=color.new(#0f172a, 0), text_size=11, text_halign=text.align_center)
        table.merge_cells(hud, 0, 7, 1, 7)

        // Show a fixed handful of representative trees with live weight + vote       

        f_row(8,  tree1_name,  vote1,  w1,  array.get(totals, 0))
        f_row(9,  tree3_name,  vote3,  w3,  array.get(totals, 2))
        f_row(10, tree4_name,  vote4,  w4,  array.get(totals, 3))
        f_row(11, tree9_name,  vote9,  w9,  array.get(totals, 8))
        f_row(12, tree15_name, vote15, w15, array.get(totals, 14))


bgcolor(#131722)

//ALERTS
bool verdict_changed = verdict != verdict[1]
alertcondition(strong_bull_new, "Strong Bull Confluence", "D3R RF Ensemble: forest bullish AND RSI oversold agree")
alertcondition(strong_bear_new, "Strong Bear Confluence", "D3R RF Ensemble: forest bearish AND RSI overbought agree")
alertcondition(verdict_changed, "Verdict Changed", "D3R RF Ensemble: forest verdict has changed")
````
