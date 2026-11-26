# MTF S&R Confluence Detector

- url: https://www.tradingview.com/script/qJmkG7ex-MTF-S-R-Confluence-Detector/
- type: indicator
- pine_id: PUB;8461beefec92478987ee8af2c062a725
- version: 1.0

## Description

[b]MTF S&R Confluence Detector[/b]

[b]OVERVIEW[/b]

MTF S&R Confluence Detector automatically maps support and resistance across three independently configurable timeframes, then highlights the spots where those levels stack on top of one another. Confluence — the alignment of multiple structural levels in the same price area — is one of the more reliable ways to identify zones where price is likely to react, and this script does the work of tracking it in real time instead of requiring you to flip between chart timeframes and eyeball it yourself.

Alongside the multi-timeframe pivots, the script also plots Previous Day High/Low and Today's High/Low, and checks those session levels for confluence with your MTF pivots — surfacing "high conviction" areas where intraday structure and prior-session structure line up.

Built and tested on Pine Script v6.

[b]HOW IT WORKS[/b]

For each of the three timeframes, the script finds swing highs and swing lows using pivot detection (ta.pivothigh / ta.pivotlow) with independently adjustable lookback and lookahead periods. Each pivot is only confirmed once price has moved the required number of bars past it, so the levels you see are based on confirmed swing points, not predictions.

The most recently confirmed support and resistance level from each timeframe is held on the chart as a line until a new pivot forms and replaces it. A percentage-based "range" is drawn around each level (also configurable per timeframe) to represent a zone rather than a single exact price.

[b]CONFLUENCE DETECTION[/b]

The script compares the current support level (and separately, the current resistance level) across all three timeframes. If two levels sit within your chosen confluence threshold (a percentage distance you control), they're flagged as confluent and both lines turn gold. If all three timeframes agree, that's flagged as a "triple confluence" — the strongest signal the script can produce. Confluent zones also get a soft gold fill so they stand out visually from ordinary single-timeframe levels.

The same confluence logic is applied to Previous Day High/Low against your MTF levels, so you can immediately see when a prior session extreme is reinforced by higher-timeframe structure.

[b]KEY FEATURES[/b]

- Three independent, fully configurable timeframes for support/resistance detection (defaults: 1H, 4H, Daily)
- Adjustable pivot lookback/lookahead for support and resistance detection separately
- Per-timeframe color, and adjustable percentage "zone" width around each level
- Automatic confluence detection between any two timeframes, plus triple-confluence detection
- Adjustable confluence threshold (%) to control how close levels need to be to count as aligned
- Gold highlighting and zone fills on confluent levels so they stand out at a glance
- Previous Day High/Low and Today's High/Low overlays, each independently toggleable
- Increasing visual weight by timeframe — the highest timeframe is drawn thicker and dashed so higher-timeframe structure reads as more significant
- Clean price-scale labels identifying which timeframe each level belongs to

[b]ALERTS[/b]

The indicator ships with a full set of ready-to-use alert conditions, including:

- Pairwise support/resistance confluence for every timeframe combination
- Triple confluence (all three timeframes aligned) for both support and resistance
- Price entering a confluent support or resistance zone
- Price breaking above Previous Day High or below Previous Day Low
- Price making a new session high or low
- Previous Day High/Low aligning with multi-timeframe resistance/support (high-conviction setups)

[b]HOW TO USE IT[/b]

1. Set your three timeframes under the "Timeframe 1/2/3" input groups. By default these are 1H, 4H, and Daily, but you can set them to whatever combination fits your trading style (e.g., 15m/1H/4H for intraday, or 4H/D/W for swing trading).
2. Tune the pivot lookback/lookahead under "S&R Detection" to control how sensitive the swing detection is — shorter values find levels faster but produce more of them; longer values are more selective.
3. Adjust the "Confluence Threshold" to set how close levels from different timeframes need to be before they're treated as the same zone. Tighter for precision, wider to catch near-misses.
4. Toggle Previous Day High/Low and Today's High/Low on or off depending on whether you trade session-based levels.
5. Set alerts on any of the built-in alert conditions to get notified the moment a confluence zone forms or price reaches one.

NOTES

- Support and resistance levels are based on confirmed pivots — a pivot only appears after the lookahead period has elapsed, which is standard practice for pivot-based tools and avoids false, unconfirmed levels, but it also means levels are inherently a few bars behind the most recent swing.

- Because the script pulls data from higher timeframes via request.security, values on historical bars from an unclosed higher-timeframe candle can adjust intrabar until that higher-timeframe candle closes — as with any multi-timeframe tool, always wait for confirmation on the current higher-timeframe bar before treating a fresh level as final.

- This indicator is a visual and analytical tool for identifying areas of interest; it does not generate buy or sell signals and should be combined with your own risk management and analysis. Nothing here is financial advice.

## Source Code

````pine
//@version=6
indicator(title="MTF S&R Confluence Detector", overlay=true, max_bars_back=5000)

// ══════════════════════════════════════════════════════════════════════════════
//  COLORS
// ══════════════════════════════════════════════════════════════════════════════
green           = color.new(#2DBD85, 0)
lightGreen      = color.new(#2DBD85, 80)
red             = color.new(#E02A4A, 0)
lightRed        = color.new(#E02A4A, 80)
white           = color.new(#ffffff, 0)
transparent     = color.new(#ffffff, 100)
confluenceColor = color.new(#FFD700, 0)
lightConfluence = color.new(#FFD700, 75)

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS — S&R DETECTION
// ══════════════════════════════════════════════════════════════════════════════
supportLookBack     = input.int(22, "Support Lookback",     group="S&R Detection")
supportLookAhead    = input.int(26, "Support Lookahead",    group="S&R Detection")
resistanceLookBack  = input.int(30, "Resistance Lookback",  group="S&R Detection")
resistanceLookAhead = input.int(27, "Resistance Lookahead", group="S&R Detection")

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS — CONFLUENCE
// ══════════════════════════════════════════════════════════════════════════════
confluenceThreshold = input.float(0.5, "Confluence Threshold (%)", group="Confluence",
     minval=0.01, step=0.05,
     tooltip="Max % distance between levels to be considered confluent")
showConfluenceZones = input.bool(true, "Highlight Confluence Zones", group="Confluence")

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS — TIMEFRAME 1
// ══════════════════════════════════════════════════════════════════════════════
tf1              = input.timeframe("60",  "Timeframe 1", group="Timeframe 1")
enableTF1        = input.bool(true,  "Enable TF1",          group="Timeframe 1")
showRanges1      = input.bool(true,  "Show Ranges",         group="Timeframe 1")
supportRange1    = input.float(0.25, "Support Range (%)",    inline="s1", group="Timeframe 1")
supportColor1    = input.color(green, "",                    inline="s1", group="Timeframe 1")
resistanceRange1 = input.float(0.25, "Resistance Range (%)", inline="r1", group="Timeframe 1")
resistanceColor1 = input.color(red,  "",                     inline="r1", group="Timeframe 1")

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS — TIMEFRAME 2
// ══════════════════════════════════════════════════════════════════════════════
tf2              = input.timeframe("240", "Timeframe 2", group="Timeframe 2")
enableTF2        = input.bool(true,  "Enable TF2",          group="Timeframe 2")
showRanges2      = input.bool(true,  "Show Ranges",         group="Timeframe 2")
supportRange2    = input.float(0.25, "Support Range (%)",    inline="s2", group="Timeframe 2")
supportColor2    = input.color(green, "",                    inline="s2", group="Timeframe 2")
resistanceRange2 = input.float(0.25, "Resistance Range (%)", inline="r2", group="Timeframe 2")
resistanceColor2 = input.color(red,  "",                     inline="r2", group="Timeframe 2")

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS — DAILY LEVELS  (Previous Day & Today's High/Low)
// ══════════════════════════════════════════════════════════════════════════════
enablePDHL      = input.bool(true,  "Show Previous Day High/Low",  group="Daily Levels")
pdHighColor     = input.color(color.new(#FF8C00, 0),  "Prev Day High", inline="pdh", group="Daily Levels")
pdLowColor      = input.color(color.new(#1E90FF, 0),  "Prev Day Low",  inline="pdl", group="Daily Levels")
enableTDHL      = input.bool(true,  "Show Today's High/Low",        group="Daily Levels")
tdHighColor     = input.color(color.new(#FF8C00, 55), "Today High",   inline="tdh", group="Daily Levels")
tdLowColor      = input.color(color.new(#1E90FF, 55), "Today Low",    inline="tdl", group="Daily Levels")

// ══════════════════════════════════════════════════════════════════════════════
//  INPUTS — TIMEFRAME 3  (higher TF — drawn thicker + dashed)
// ══════════════════════════════════════════════════════════════════════════════
tf3              = input.timeframe("D",   "Timeframe 3", group="Timeframe 3")
enableTF3        = input.bool(true,  "Enable TF3",          group="Timeframe 3")
showRanges3      = input.bool(true,  "Show Ranges",         group="Timeframe 3")
supportRange3    = input.float(0.25, "Support Range (%)",    inline="s3", group="Timeframe 3")
supportColor3    = input.color(green, "",                    inline="s3", group="Timeframe 3")
resistanceRange3 = input.float(0.25, "Resistance Range (%)", inline="r3", group="Timeframe 3")
resistanceColor3 = input.color(red,  "",                     inline="r3", group="Timeframe 3")

// ══════════════════════════════════════════════════════════════════════════════
//  HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════
getSupport(lb, la)    => fixnan(ta.pivotlow(lb, la)[1])
getResistance(lb, la) => fixnan(ta.pivothigh(lb, la)[1])

// Human-readable label for a timeframe string
tfLabel(tf) =>
    switch tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1H"
        "120" => "2H"
        "180" => "3H"
        "240" => "4H"
        "D"   => "1D"
        "W"   => "1W"
        "M"   => "1M"
        =>  tf

// Returns true when two price levels are within confluenceThreshold % of each other
isConfluent(a, b) =>
    not na(a) and not na(b) and math.abs(a - b) / math.max(a, b) * 100 <= confluenceThreshold

// ══════════════════════════════════════════════════════════════════════════════
//  FETCH DAILY LEVELS
// ══════════════════════════════════════════════════════════════════════════════
prevDayHigh = request.security(syminfo.ticker, "D", high[1], lookahead=barmerge.lookahead_on)
prevDayLow  = request.security(syminfo.ticker, "D", low[1],  lookahead=barmerge.lookahead_on)
todayHigh   = request.security(syminfo.ticker, "D", high)
todayLow    = request.security(syminfo.ticker, "D", low)

// ══════════════════════════════════════════════════════════════════════════════
//  FETCH MULTI-TIMEFRAME LEVELS
// ══════════════════════════════════════════════════════════════════════════════
support1    = request.security(syminfo.ticker, tf1, getSupport(supportLookBack, supportLookAhead))
resistance1 = request.security(syminfo.ticker, tf1, getResistance(resistanceLookBack, resistanceLookAhead))

support2    = request.security(syminfo.ticker, tf2, getSupport(supportLookBack, supportLookAhead))
resistance2 = request.security(syminfo.ticker, tf2, getResistance(resistanceLookBack, resistanceLookAhead))

support3    = request.security(syminfo.ticker, tf3, getSupport(supportLookBack, supportLookAhead))
resistance3 = request.security(syminfo.ticker, tf3, getResistance(resistanceLookBack, resistanceLookAhead))

// ══════════════════════════════════════════════════════════════════════════════
//  PERSIST MOST-RECENT LEVELS (only update when pivot changes)
// ══════════════════════════════════════════════════════════════════════════════
var float mrS1 = na
var float mrR1 = na
var float mrS2 = na
var float mrR2 = na
var float mrS3 = na
var float mrR3 = na

mrS1 := ta.change(support1)    != 0 ? support1    : mrS1
mrR1 := ta.change(resistance1) != 0 ? resistance1 : mrR1
mrS2 := ta.change(support2)    != 0 ? support2    : mrS2
mrR2 := ta.change(resistance2) != 0 ? resistance2 : mrR2
mrS3 := ta.change(support3)    != 0 ? support3    : mrS3
mrR3 := ta.change(resistance3) != 0 ? resistance3 : mrR3

// ══════════════════════════════════════════════════════════════════════════════
//  CONFLUENCE FLAGS
// ══════════════════════════════════════════════════════════════════════════════
// Support pairs
sConf12 = isConfluent(mrS1, mrS2)   // TF1 <> TF2 support
sConf13 = isConfluent(mrS1, mrS3)   // TF1 <> TF3 support
sConf23 = isConfluent(mrS2, mrS3)   // TF2 <> TF3 support
sTriple = sConf12 and sConf13       // All 3 TFs support confluent

// Resistance pairs
rConf12 = isConfluent(mrR1, mrR2)   // TF1 <> TF2 resistance
rConf13 = isConfluent(mrR1, mrR3)   // TF1 <> TF3 resistance
rConf23 = isConfluent(mrR2, mrR3)   // TF2 <> TF3 resistance
rTriple = rConf12 and rConf13       // All 3 TFs resistance confluent

// ══════════════════════════════════════════════════════════════════════════════
//  PERSISTENT DRAWING OBJECTS  (v6 requires all `var` at global scope)
// ══════════════════════════════════════════════════════════════════════════════
var line s1Line = na
var line r1Line = na
var label s1Lbl = na
var label r1Lbl = na
var line s1RT = na
var line s1RB = na
var line r1RT = na
var line r1RB = na

var line s2Line = na
var line r2Line = na
var label s2Lbl = na
var label r2Lbl = na
var line s2RT = na
var line s2RB = na
var line r2RT = na
var line r2RB = na

var line s3Line = na
var line r3Line = na
var label s3Lbl = na
var label r3Lbl = na
var line s3RT = na
var line s3RB = na
var line r3RT = na
var line r3RB = na

var line cS12T = na
var line cS12B = na
var line cS13T = na
var line cS13B = na
var line cS23T = na
var line cS23B = na
var line cR12T = na
var line cR12B = na
var line cR13T = na
var line cR13B = na
var line cR23T = na
var line cR23B = na

var line pdHighLine = na
var line pdLowLine  = na
var label pdHighLbl = na
var label pdLowLbl  = na
var line tdHighLine = na
var line tdLowLine  = na
var label tdHighLbl = na
var label tdLowLbl  = na

// ══════════════════════════════════════════════════════════════════════════════
//  DRAW — TIMEFRAME 1  (width 1, solid)
// ══════════════════════════════════════════════════════════════════════════════
line.delete(s1Line)
line.delete(r1Line)
label.delete(s1Lbl)
label.delete(r1Lbl)

if enableTF1
    _s1c = (sConf12 or sConf13) ? confluenceColor : supportColor1
    _r1c = (rConf12 or rConf13) ? confluenceColor : resistanceColor1
    s1Line := line.new(bar_index - 10, mrS1, bar_index, mrS1, color=_s1c, width=1, extend=extend.both)
    r1Line := line.new(bar_index - 10, mrR1, bar_index, mrR1, color=_r1c, width=1, extend=extend.both)
    s1Lbl  := label.new(bar_index + 30, mrS1, tfLabel(tf1), color=_s1c, textcolor=white, style=label.style_label_down, size=size.small)
    r1Lbl  := label.new(bar_index + 30, mrR1, tfLabel(tf1), color=_r1c, textcolor=white, style=label.style_label_down, size=size.small)

if showRanges1 and enableTF1
    line.delete(s1RT)
    line.delete(s1RB)
    line.delete(r1RT)
    line.delete(r1RB)
    s1RT := line.new(bar_index, mrS1 * (1 + supportRange1    / 100), bar_index - 1, mrS1 * (1 + supportRange1    / 100), color=transparent, extend=extend.both)
    s1RB := line.new(bar_index, mrS1 * (1 - supportRange1    / 100), bar_index - 1, mrS1 * (1 - supportRange1    / 100), color=transparent, extend=extend.both)
    r1RT := line.new(bar_index, mrR1 * (1 + resistanceRange1 / 100), bar_index - 1, mrR1 * (1 + resistanceRange1 / 100), color=transparent, extend=extend.both)
    r1RB := line.new(bar_index, mrR1 * (1 - resistanceRange1 / 100), bar_index - 1, mrR1 * (1 - resistanceRange1 / 100), color=transparent, extend=extend.both)
    linefill.new(s1RT, s1RB, lightGreen)
    linefill.new(r1RT, r1RB, lightRed)

// ══════════════════════════════════════════════════════════════════════════════
//  DRAW — TIMEFRAME 2  (width 2, solid)
// ══════════════════════════════════════════════════════════════════════════════
line.delete(s2Line)
line.delete(r2Line)
label.delete(s2Lbl)
label.delete(r2Lbl)

if enableTF2
    _s2c = (sConf12 or sConf23) ? confluenceColor : supportColor2
    _r2c = (rConf12 or rConf23) ? confluenceColor : resistanceColor2
    s2Line := line.new(bar_index - 10, mrS2, bar_index, mrS2, color=_s2c, width=2, extend=extend.both)
    r2Line := line.new(bar_index - 10, mrR2, bar_index, mrR2, color=_r2c, width=2, extend=extend.both)
    s2Lbl  := label.new(bar_index + 45, mrS2, tfLabel(tf2), color=_s2c, textcolor=white, style=label.style_label_down, size=size.small)
    r2Lbl  := label.new(bar_index + 45, mrR2, tfLabel(tf2), color=_r2c, textcolor=white, style=label.style_label_down, size=size.small)

if showRanges2 and enableTF2
    line.delete(s2RT)
    line.delete(s2RB)
    line.delete(r2RT)
    line.delete(r2RB)
    s2RT := line.new(bar_index, mrS2 * (1 + supportRange2    / 100), bar_index - 1, mrS2 * (1 + supportRange2    / 100), color=transparent, extend=extend.both)
    s2RB := line.new(bar_index, mrS2 * (1 - supportRange2    / 100), bar_index - 1, mrS2 * (1 - supportRange2    / 100), color=transparent, extend=extend.both)
    r2RT := line.new(bar_index, mrR2 * (1 + resistanceRange2 / 100), bar_index - 1, mrR2 * (1 + resistanceRange2 / 100), color=transparent, extend=extend.both)
    r2RB := line.new(bar_index, mrR2 * (1 - resistanceRange2 / 100), bar_index - 1, mrR2 * (1 - resistanceRange2 / 100), color=transparent, extend=extend.both)
    linefill.new(s2RT, s2RB, lightGreen)
    linefill.new(r2RT, r2RB, lightRed)

// ══════════════════════════════════════════════════════════════════════════════
//  DRAW — TIMEFRAME 3  (width 3, dashed — highest weight)
// ══════════════════════════════════════════════════════════════════════════════
line.delete(s3Line)
line.delete(r3Line)
label.delete(s3Lbl)
label.delete(r3Lbl)

if enableTF3
    _s3c = (sConf13 or sConf23) ? confluenceColor : supportColor3
    _r3c = (rConf13 or rConf23) ? confluenceColor : resistanceColor3
    s3Line := line.new(bar_index - 10, mrS3, bar_index, mrS3, color=_s3c, width=3, style=line.style_dashed, extend=extend.both)
    r3Line := line.new(bar_index - 10, mrR3, bar_index, mrR3, color=_r3c, width=3, style=line.style_dashed, extend=extend.both)
    s3Lbl  := label.new(bar_index + 60, mrS3, tfLabel(tf3), color=_s3c, textcolor=white, style=label.style_label_down, size=size.normal)
    r3Lbl  := label.new(bar_index + 60, mrR3, tfLabel(tf3), color=_r3c, textcolor=white, style=label.style_label_down, size=size.normal)

if showRanges3 and enableTF3
    line.delete(s3RT)
    line.delete(s3RB)
    line.delete(r3RT)
    line.delete(r3RB)
    s3RT := line.new(bar_index, mrS3 * (1 + supportRange3    / 100), bar_index - 1, mrS3 * (1 + supportRange3    / 100), color=transparent, extend=extend.both)
    s3RB := line.new(bar_index, mrS3 * (1 - supportRange3    / 100), bar_index - 1, mrS3 * (1 - supportRange3    / 100), color=transparent, extend=extend.both)
    r3RT := line.new(bar_index, mrR3 * (1 + resistanceRange3 / 100), bar_index - 1, mrR3 * (1 + resistanceRange3 / 100), color=transparent, extend=extend.both)
    r3RB := line.new(bar_index, mrR3 * (1 - resistanceRange3 / 100), bar_index - 1, mrR3 * (1 - resistanceRange3 / 100), color=transparent, extend=extend.both)
    linefill.new(s3RT, s3RB, lightGreen)
    linefill.new(r3RT, r3RB, lightRed)

// ══════════════════════════════════════════════════════════════════════════════
//  CONFLUENCE ZONE HIGHLIGHTS  (golden fills where TFs align)
// ══════════════════════════════════════════════════════════════════════════════
if showConfluenceZones
    if sConf12
        avg = (mrS1 + mrS2) / 2
        line.delete(cS12T)
        line.delete(cS12B)
        cS12T := line.new(bar_index, avg * (1 + confluenceThreshold / 100), bar_index - 1, avg * (1 + confluenceThreshold / 100), color=transparent, extend=extend.both)
        cS12B := line.new(bar_index, avg * (1 - confluenceThreshold / 100), bar_index - 1, avg * (1 - confluenceThreshold / 100), color=transparent, extend=extend.both)
        linefill.new(cS12T, cS12B, lightConfluence)

    if sConf13
        avg = (mrS1 + mrS3) / 2
        line.delete(cS13T)
        line.delete(cS13B)
        cS13T := line.new(bar_index, avg * (1 + confluenceThreshold / 100), bar_index - 1, avg * (1 + confluenceThreshold / 100), color=transparent, extend=extend.both)
        cS13B := line.new(bar_index, avg * (1 - confluenceThreshold / 100), bar_index - 1, avg * (1 - confluenceThreshold / 100), color=transparent, extend=extend.both)
        linefill.new(cS13T, cS13B, lightConfluence)

    if sConf23
        avg = (mrS2 + mrS3) / 2
        line.delete(cS23T)
        line.delete(cS23B)
        cS23T := line.new(bar_index, avg * (1 + confluenceThreshold / 100), bar_index - 1, avg * (1 + confluenceThreshold / 100), color=transparent, extend=extend.both)
        cS23B := line.new(bar_index, avg * (1 - confluenceThreshold / 100), bar_index - 1, avg * (1 - confluenceThreshold / 100), color=transparent, extend=extend.both)
        linefill.new(cS23T, cS23B, lightConfluence)

    if rConf12
        avg = (mrR1 + mrR2) / 2
        line.delete(cR12T)
        line.delete(cR12B)
        cR12T := line.new(bar_index, avg * (1 + confluenceThreshold / 100), bar_index - 1, avg * (1 + confluenceThreshold / 100), color=transparent, extend=extend.both)
        cR12B := line.new(bar_index, avg * (1 - confluenceThreshold / 100), bar_index - 1, avg * (1 - confluenceThreshold / 100), color=transparent, extend=extend.both)
        linefill.new(cR12T, cR12B, lightConfluence)

    if rConf13
        avg = (mrR1 + mrR3) / 2
        line.delete(cR13T)
        line.delete(cR13B)
        cR13T := line.new(bar_index, avg * (1 + confluenceThreshold / 100), bar_index - 1, avg * (1 + confluenceThreshold / 100), color=transparent, extend=extend.both)
        cR13B := line.new(bar_index, avg * (1 - confluenceThreshold / 100), bar_index - 1, avg * (1 - confluenceThreshold / 100), color=transparent, extend=extend.both)
        linefill.new(cR13T, cR13B, lightConfluence)

    if rConf23
        avg = (mrR2 + mrR3) / 2
        line.delete(cR23T)
        line.delete(cR23B)
        cR23T := line.new(bar_index, avg * (1 + confluenceThreshold / 100), bar_index - 1, avg * (1 + confluenceThreshold / 100), color=transparent, extend=extend.both)
        cR23B := line.new(bar_index, avg * (1 - confluenceThreshold / 100), bar_index - 1, avg * (1 - confluenceThreshold / 100), color=transparent, extend=extend.both)
        linefill.new(cR23T, cR23B, lightConfluence)

// ══════════════════════════════════════════════════════════════════════════════
//  DRAW — DAILY LEVELS
// ══════════════════════════════════════════════════════════════════════════════
line.delete(pdHighLine)
line.delete(pdLowLine)
label.delete(pdHighLbl)
label.delete(pdLowLbl)
line.delete(tdHighLine)
line.delete(tdLowLine)
label.delete(tdHighLbl)
label.delete(tdLowLbl)

if enablePDHL
    pdHighLine := line.new(bar_index - 10, prevDayHigh, bar_index, prevDayHigh, color=pdHighColor, width=2, style=line.style_dashed, extend=extend.both)
    pdLowLine  := line.new(bar_index - 10, prevDayLow,  bar_index, prevDayLow,  color=pdLowColor,  width=2, style=line.style_dashed, extend=extend.both)
    pdHighLbl  := label.new(bar_index + 75, prevDayHigh, "PDH", color=pdHighColor, textcolor=white, style=label.style_label_down, size=size.small)
    pdLowLbl   := label.new(bar_index + 75, prevDayLow,  "PDL", color=pdLowColor,  textcolor=white, style=label.style_label_down, size=size.small)

if enableTDHL
    tdHighLine := line.new(bar_index - 10, todayHigh, bar_index, todayHigh, color=tdHighColor, width=1, style=line.style_dotted, extend=extend.both)
    tdLowLine  := line.new(bar_index - 10, todayLow,  bar_index, todayLow,  color=tdLowColor,  width=1, style=line.style_dotted, extend=extend.both)
    tdHighLbl  := label.new(bar_index + 75, todayHigh, "TDH", color=tdHighColor, textcolor=white, style=label.style_label_down, size=size.small)
    tdLowLbl   := label.new(bar_index + 75, todayLow,  "TDL", color=tdLowColor,  textcolor=white, style=label.style_label_down, size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
//  PRICE SCALE PLOTS
// ══════════════════════════════════════════════════════════════════════════════
plot(mrS1, "TF1 Support",    color=green, display=display.price_scale, editable=false)
plot(mrR1, "TF1 Resistance", color=red,   display=display.price_scale, editable=false)
plot(mrS2, "TF2 Support",    color=green, display=display.price_scale, editable=false)
plot(mrR2, "TF2 Resistance", color=red,   display=display.price_scale, editable=false)
plot(mrS3, "TF3 Support",    color=green, display=display.price_scale, editable=false)
plot(mrR3, "TF3 Resistance", color=red,   display=display.price_scale, editable=false)
plot(prevDayHigh, "Prev Day High", color=color.new(#FF8C00, 0), display=display.price_scale, editable=false)
plot(prevDayLow,  "Prev Day Low",  color=color.new(#1E90FF, 0), display=display.price_scale, editable=false)
plot(todayHigh,   "Today High",    color=color.new(#FF8C00, 55), display=display.price_scale, editable=false)
plot(todayLow,    "Today Low",     color=color.new(#1E90FF, 55), display=display.price_scale, editable=false)

// ══════════════════════════════════════════════════════════════════════════════
//  PRICE PROXIMITY CHECKS  (is close currently inside a level's range?)
// ══════════════════════════════════════════════════════════════════════════════
nearS1 = math.abs(close - mrS1) / mrS1 * 100 <= supportRange1
nearR1 = math.abs(close - mrR1) / mrR1 * 100 <= resistanceRange1
nearS2 = math.abs(close - mrS2) / mrS2 * 100 <= supportRange2
nearR2 = math.abs(close - mrR2) / mrR2 * 100 <= resistanceRange2

// ══════════════════════════════════════════════════════════════════════════════
//  ALERT CONDITIONS
// ══════════════════════════════════════════════════════════════════════════════
// — Confluence formed (levels across TFs aligned within threshold) —
alertcondition(sConf12, title="Support Confluence TF1+TF2",     message="MTF S&R: Support confluence · TF1 & TF2 aligned")
alertcondition(sConf13, title="Support Confluence TF1+TF3",     message="MTF S&R: Support confluence · TF1 & TF3 aligned")
alertcondition(sConf23, title="Support Confluence TF2+TF3",     message="MTF S&R: Support confluence · TF2 & TF3 aligned")
alertcondition(sTriple, title="TRIPLE Support Confluence",       message="MTF S&R: TRIPLE support confluence — all 3 TFs aligned!")

alertcondition(rConf12, title="Resistance Confluence TF1+TF2",  message="MTF S&R: Resistance confluence · TF1 & TF2 aligned")
alertcondition(rConf13, title="Resistance Confluence TF1+TF3",  message="MTF S&R: Resistance confluence · TF1 & TF3 aligned")
alertcondition(rConf23, title="Resistance Confluence TF2+TF3",  message="MTF S&R: Resistance confluence · TF2 & TF3 aligned")
alertcondition(rTriple, title="TRIPLE Resistance Confluence",    message="MTF S&R: TRIPLE resistance confluence — all 3 TFs aligned!")

// — Price entering a confluent zone —
alertcondition(nearS1 and (sConf12 or sConf13), title="Price at Confluent Support",    message="MTF S&R: Price entering confluent support zone!")
alertcondition(nearR1 and (rConf12 or rConf13), title="Price at Confluent Resistance", message="MTF S&R: Price entering confluent resistance zone!")

// — Daily level breaks —
alertcondition(ta.crossover(close, prevDayHigh),  title="Price Broke Above PDH",   message="MTF S&R: Price broke above Previous Day High!")
alertcondition(ta.crossunder(close, prevDayLow),  title="Price Broke Below PDL",   message="MTF S&R: Price broke below Previous Day Low!")
alertcondition(ta.crossover(close, todayHigh[1]), title="Price Made New Session High", message="MTF S&R: Price made a new session high!")
alertcondition(ta.crossunder(close, todayLow[1]), title="Price Made New Session Low",  message="MTF S&R: Price made a new session low!")

// — PDH/PDL aligning with MTF confluence (extra high conviction) —
alertcondition(isConfluent(prevDayHigh, mrR1) or isConfluent(prevDayHigh, mrR2) or isConfluent(prevDayHigh, mrR3), title="PDH Aligns with MTF Resistance", message="MTF S&R: Previous Day High aligns with MTF resistance — high conviction level!")
alertcondition(isConfluent(prevDayLow,  mrS1) or isConfluent(prevDayLow,  mrS2) or isConfluent(prevDayLow,  mrS3), title="PDL Aligns with MTF Support",    message="MTF S&R: Previous Day Low aligns with MTF support — high conviction level!")
````
