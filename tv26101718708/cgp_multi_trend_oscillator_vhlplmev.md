# [CGP] Multi Trend Oscillator

- url: https://www.tradingview.com/script/VHlPLmEV-CGP-Multi-Trend-Oscillator/
- type: indicator
- pine_id: PUB;781c291616064235bb2caa6c8bbe8b4b
- version: 1.0

## Description

[b]Overview[/b]

The [CGP] Multi Trend Oscillator by CryptoGameplan brings six fast/slow EMA comparisons into one daily trend score from 0 to 6. It shows how many of your selected trend horizons support a bullish reading—and when that combined trend filter starts passing.

Use it on standard 1D charts. “Multi Trend” means multiple EMA lookbacks on the daily chart, rather than multiple chart timeframes.

[b]Six comparisons, one score[/b]

Each pair contributes one point when its fast EMA is strictly above its slow EMA and the pair has enough uninterrupted daily history. Equal EMAs contribute zero. All six pairs have equal weight.

Default fast/slow periods:
[list]
[*]2 / 8
[*]4 / 16
[*]8 / 32
[*]16 / 64
[*]32 / 128
[*]64 / 256
[/list]

This excerpt counts the votes after the EMA values have been updated and the counters reset. Excerpts on this page show parts of the full source, rather than standalone scripts.

[pine]
for i = 0 to 5
    // Six configurable fast spans at 0..5; their paired slow spans at 6..11.
    bool ready = runIndex >= array.get(spans, i + 6)
    readyPairs += ready ? 1 : 0
    votes += ready and array.get(averages, i) > array.get(averages, i + 6) ? 1 : 0
[/pine]

The default filter requires four bullish pairs. Four counts as a pass; the score does not need to exceed four.

[pine]
bool assessable = not na(votes) and readyPairs >= passingThreshold
bool trendPass = assessable and votes >= passingThreshold
[/pine]

[b]Reading the display[/b]

[list]
[*][b]Score line:[/b] Exact daily readings from 0 to 6, connected without smoothing. Green means the filter passes; neutral means it does not pass or is warming up.
[*][b]Gold dashed level:[/b] Your selected passing threshold.
[*][b]Slim state ribbon:[/b] Green throughout passing periods, muted when the filter is not met and faint during warmup. It stays green at threshold equality. Its position below zero is a separate visual track, not a negative score.
[*][b]Gold transition guide:[/b] Marks the confirmed daily bar when the filter starts passing. Only the latest transition has a small “Trend confirmed” label; up to 200 recent guides are retained.
[*][b]Subtle green fill:[/b] Shows the margin between a passing score and its threshold. At equality the fill has no height; the ribbon still shows the passing state.
[*][b]Compact status:[/b] Shows the latest confirmed score, filter state and UTC daily bar date. Use the crosshair legend for historical readings.
[/list]

A diagonal line crossing between daily samples is not an intraday signal. The transition guide identifies the confirmed bar. “Trend confirmed” describes this filter's conditions, not a guaranteed trend or a buy instruction.

[b]Calculation settings[/b]

In Settings → Inputs, change any of the six fast/slow EMA pairs and the number of votes required. The threshold accepts whole numbers from 1 to 6. Fast periods must be positive and shorter than their paired slow periods; invalid combinations produce a pair-specific error.

Changing these inputs recalculates history. The threshold line, ribbon, transition guides, status and alert all follow the same filter rule. The score remains a count out of six.

The existing Show trend status toggle hides or shows the compact readout.

[b]Confirmation and alerts[/b]

EMA state and scores update only after the daily candle closes. During an unfinished candle, the display holds the previous confirmed reading. A fresh transition guide appears only at confirmation.

[pine]
bool startsPassing = barstate.isconfirmed and trendPass and not trendPass[1]
[/pine]

The “CGP trend filter starts passing” alert uses the same condition. Select Once Per Bar Close when creating it. The alert marks a transition into passing; it does not repeat on every passing day.

[b]Practical use[/b]

[list=1]
[*]Open a standard 1D chart.
[*]Keep the defaults or choose your EMA periods and passing threshold.
[*]Read the score and ribbon on the completed day relevant to your setup.
[*]Use the gold guide to locate a fresh transition into passing.
[*]Check your entry setup and wider-market conditions separately.
[/list]

This indicator consolidates six EMA relationships into one readable trend filter. It measures the selected chart's price trend; it does not assess fundamental quality, detect entry zones or include a separate crypto-market basket filter. Losing the passing state is not a tested sell rule.

[b]Warmup and data limits[/b]

EMAs seed from the first valid positive daily close in the loaded history. A pair with slow period N becomes eligible after N+1 consecutive daily observations. “Warming up” means too few pairs are eligible to reach the selected threshold; it is not a bearish verdict. At the defaults, passing first becomes possible after 65 consecutive daily observations.

A gap in UTC daily dates resets the EMA seeds and warmup. Invalid-price observations leave gaps and show “No valid price.”

The source uses no future bars, cross-timeframe requests or retrospective plot offsets. Confirmed-close handling prevents open-candle updates by design, but different feeds, revised data or a changed starting history can change historical EMA readings. Nonstandard charts and timeframes other than 1D are rejected. Custom settings define a different filter; no performance advantage is implied.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CryptoGameplan
//@version=6
// CryptoGameplan | [CGP] Crypto Multi Trend Oscillator v1.2.0
// Coin trend gate only. Six EWMAC votes; not a complete entry or exit system.
indicator("[CGP] Crypto Multi Trend Oscillator", shorttitle="[CGP] MULTI-TREND", overlay=false, precision=0, max_lines_count=200)
if not (timeframe.isdaily and timeframe.multiplier == 1)
    runtime.error("CGP Trend: select the 1D chart timeframe.")
if not chart.is_standard
    runtime.error("CGP Trend: use standard candles or a standard line chart.")
int passingThreshold = input.int(4, "Votes required", minval=1, maxval=6, group="Trend filter", display=display.none,
     tooltip="Minimum bullish EMA pairs required out of six. The original rule uses four. Custom settings recalculate history.")
int fast1 = input.int(2, "Pair 1 fast", minval=1, group="EMA pairs", inline="pair1", display=display.none)
int slow1 = input.int(8, "Slow", minval=2, group="EMA pairs", inline="pair1", display=display.none,
     tooltip="Pair 1: fast must be shorter than slow. The pair can vote after slow length + 1 uninterrupted daily prices.")
int fast2 = input.int(4, "Pair 2 fast", minval=1, group="EMA pairs", inline="pair2", display=display.none)
int slow2 = input.int(16, "Slow", minval=2, group="EMA pairs", inline="pair2", display=display.none,
     tooltip="Pair 2: fast must be shorter than slow. The pair can vote after slow length + 1 uninterrupted daily prices.")
int fast3 = input.int(8, "Pair 3 fast", minval=1, group="EMA pairs", inline="pair3", display=display.none)
int slow3 = input.int(32, "Slow", minval=2, group="EMA pairs", inline="pair3", display=display.none,
     tooltip="Pair 3: fast must be shorter than slow. The pair can vote after slow length + 1 uninterrupted daily prices.")
int fast4 = input.int(16, "Pair 4 fast", minval=1, group="EMA pairs", inline="pair4", display=display.none)
int slow4 = input.int(64, "Slow", minval=2, group="EMA pairs", inline="pair4", display=display.none,
     tooltip="Pair 4: fast must be shorter than slow. The pair can vote after slow length + 1 uninterrupted daily prices.")
int fast5 = input.int(32, "Pair 5 fast", minval=1, group="EMA pairs", inline="pair5", display=display.none)
int slow5 = input.int(128, "Slow", minval=2, group="EMA pairs", inline="pair5", display=display.none,
     tooltip="Pair 5: fast must be shorter than slow. The pair can vote after slow length + 1 uninterrupted daily prices.")
int fast6 = input.int(64, "Pair 6 fast", minval=1, group="EMA pairs", inline="pair6", display=display.none)
int slow6 = input.int(256, "Slow", minval=2, group="EMA pairs", inline="pair6", display=display.none,
     tooltip="Pair 6: fast must be shorter than slow. The pair can vote after slow length + 1 uninterrupted daily prices.")
bool showPanel = input.bool(true, "Show trend status", group="Display",
     tooltip="Shows the latest confirmed daily score and its UTC bar date. Use the crosshair and Trend score legend for historical readings.")
color bull = #47ED0B
color muted = color.new(#F5F5F5, 50)
color gold = #FFC906
color ink = #F5F5F5
var array<int> spans = array.from(fast1, fast2, fast3, fast4, fast5, fast6, slow1, slow2, slow3, slow4, slow5, slow6)
var array<float> averages = array.new_float(12, na)
var int lastDay = na
var int runIndex = -1
var int votes = na
var int readyPairs = 0
var int confirmedTime = na
// Reject reversed/equal pairs rather than silently changing their meaning.
if barstate.isfirst
    for i = 0 to 5
        if array.get(spans, i) >= array.get(spans, i + 6)
            runtime.error("CGP Trend: pair " + str.tostring(i + 1) + " fast EMA must be shorter than its slow EMA.")
// Commit only closed daily bars. Open-bar ticks leave the last state intact.
if barstate.isconfirmed
    int dayKey = int(math.floor(time / 86400000))
    if not na(close) and close > 0
        bool reset = na(lastDay) or dayKey != lastDay + 1
        runIndex := reset ? 0 : runIndex + 1
        for i = 0 to 11
            float previous = array.get(averages, i)
            float alpha = 2.0 / (array.get(spans, i) + 1)
            array.set(averages, i, reset ? close : previous + alpha * (close - previous))
        votes := 0
        readyPairs := 0
        for i = 0 to 5
            // Six configurable fast spans at 0..5; their paired slow spans at 6..11.
            bool ready = runIndex >= array.get(spans, i + 6)
            readyPairs += ready ? 1 : 0
            votes += ready and array.get(averages, i) > array.get(averages, i + 6) ? 1 : 0
        lastDay := dayKey
        confirmedTime := time
    else
        // Invalid observations are omitted by the research reader.
        // Keeping lastDay makes the next valid daily sample detect the gap.
        votes := na
        readyPairs := 0
        confirmedTime := time
bool assessable = not na(votes) and readyPairs >= passingThreshold
bool trendPass = assessable and votes >= passingThreshold
// Preserve exact samples; the separate ribbon locates each confirmed state change.
color stateColor = trendPass ? bull : color.new(chart.fg_color, 15)
scorePlot = plot(votes, "Trend score", color=stateColor, linewidth=2, style=plot.style_linebr)
hline(0, "Zero", color=color.new(ink, 90), linewidth=1)
hline(passingThreshold, "Trend filter threshold", color=color.new(gold, 35), linestyle=hline.style_dashed, linewidth=1)
hline(6, "Six", color=color.new(ink, 90), linewidth=1)
// Fill conveys passing margin; the ribbon remains visible at threshold equality.
thresholdPlot = plot(passingThreshold, "Fill reference", display=display.none)
fill(scorePlot, thresholdPlot, color=trendPass ? color.new(bull, 93) : na, title="Passing margin", fillgaps=false)
// Decorative state track below zero; its height is not a score or negative vote.
color ribbonColor = na(votes) ? na : not assessable ? color.new(ink, 88) : trendPass ? color.new(bull, 20) : color.new(ink, 78)
plot(na(votes) ? na : -0.25, "Confirmed trend state ribbon", color=ribbonColor,
     style=plot.style_columns, histbase=-0.55, display=display.pane)
````
