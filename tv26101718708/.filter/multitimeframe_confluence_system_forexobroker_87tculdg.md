# Multi-Timeframe Confluence System [forexobroker]

- url: https://www.tradingview.com/script/87TCuLDg-Multi-Timeframe-Confluence-System-forexobroker/
- type: indicator
- pine_id: PUB;1f1cb20ddd3a4d689304aa01cbb0a8d3
- version: 1.0

## Description

Multi-Timeframe Confluence System eliminates low-probability trades by requiring agreement across multiple timeframes before generating any signal. It checks three dimensions — trend direction, momentum state, and market structure — on each of 4 configurable higher timeframes plus your current chart, then fires signals only when your defined confluence threshold is met.

THE PROBLEM WITH SINGLE-TIMEFRAME TRADING

Most traders make decisions based on one timeframe. This leads to three common problems:

False Signals — A bullish setup on the 15-minute chart means nothing if the 4-hour and daily are bearish. Without multi-timeframe confirmation, you're trading against the bigger picture.

Low Win Rate — Studies consistently show that trades aligned with higher timeframe trends have significantly higher win rates. Single-timeframe setups ignore this edge entirely.

Manual Checking — Serious traders already check multiple timeframes before entering. But doing this manually is slow, subjective, and inconsistent. You might check 3 timeframes on one trade but forget on the next.

Multi-Timeframe Confluence System automates and systematizes this process. Every bar, every timeframe, every dimension — checked algorithmically, scored objectively.

HOW IT WORKS

The system analyzes three dimensions on each timeframe:

1. Trend Direction

Using a triple EMA system (Fast 9, Slow 21, Trend 50):

Bullish: Fast EMA > Slow EMA AND price > Trend EMA
Bearish: Fast EMA < Slow EMA AND price < Trend EMA
Neutral: Mixed conditions
This captures both short-term direction (fast/slow cross) and longer-term context (price vs trend EMA).

2. Momentum State

Using RSI (14) with optional MACD histogram confirmation:

Bullish Momentum: RSI above the bull threshold (default 50) AND MACD histogram positive
Bearish Momentum: RSI below the bear threshold (default 50) AND MACD histogram negative
Neutral: RSI in no-man's land or MACD contradicts RSI
MACD confirmation is optional but recommended — it filters out weak RSI readings.

3. Market Structure

Using swing point analysis (pivothigh/pivotlow):

Bullish Structure: Higher highs AND higher lows (HH/HL)
Bearish Structure: Lower highs AND lower lows (LH/LL)
Mixed: No clear structural pattern
Structure is the most reliable but slowest-moving dimension. It confirms that the price action pattern supports the direction.

CONFLUENCE SCORING

Each enabled timeframe contributes 1 point to the bull or bear confluence score if its required conditions are met.

With all 5 timeframes enabled (chart + 4 HTFs):

5/5: Perfect alignment — highest probability setup
4/5: Strong alignment — high probability
3/5: Moderate alignment — standard signal (default minimum)
2/5: Weak alignment — consider skipping
1/5 or 0/5: No alignment — no signal
Quality Score (1-10): Confluence count divided by enabled TFs, scaled to 10. A score of 8+ means near-perfect alignment across all checked timeframes.

CONFIGURABLE REQUIREMENTS

You control which dimensions must align for each TF to count:

Setting	Effect When ON	Effect When OFF
Require Trend	TF's EMA trend must match direction	Trend ignored, only other factors count
Require Momentum	TF's RSI/MACD must match direction	Momentum ignored
Require Structure	TF's swing structure must match direction	Structure ignored (recommended for beginners)
Default: Trend + Momentum required, Structure optional. This provides a good balance of signal quality vs frequency.

SIGNAL GENERATION

Signals fire when:

Bull or bear confluence meets your minimum threshold
The cooldown period has elapsed since the last same-direction signal
The bar is confirmed (no repainting)
Signal labels show:

Direction (BUY/SELL)
Confluence count (e.g., "4/5")
Quality score (e.g., "Q:8")
DASHBOARD

The dashboard provides a complete multi-timeframe overview:

Section	Shows
TF Grid	Each timeframe's Trend/Momentum/Structure status with color coding
Bull Score	Bullish confluence count, quality, and signal state
Bear Score	Bearish confluence count, quality, and signal state
Last Signal	Direction, quality, and bars since last signal
Total Signals	Running bull/bear signal counts
Settings	Active requirements (T/M/S), minimum confluence, cooldown
Chart RSI	Current RSI value and MACD direction
Each TF row shows BULL/BEAR/FLAT for trend, momentum, and structure, with ALIGNED/MIXED status.

FEATURES

4 configurable higher timeframes + current chart timeframe
Triple EMA trend detection (9/21/50)
RSI momentum with optional MACD histogram confirmation
Swing-based market structure analysis (HH/HL vs LH/LL)
Confluence scoring with configurable minimum threshold
Quality score 1-10 for signal strength assessment
Customizable requirements (trend/momentum/structure toggles)
Signal cooldown to prevent clustering
BUY/SELL labels with confluence count and quality
Bar coloring by confluence strength
Background shading when confluence threshold met
5-column dashboard with per-TF breakdown
Theme-aware colors for light and dark charts
Data Window integration for all metrics
Only 4 request.security() calls (well within 40 limit)
barstate.isconfirmed on all signals — no repainting
6 alert conditions including full alignment alerts
Works on any instrument and timeframe

ALERTS

Alert	Fires When
Bullish Confluence Signal	Bull confluence meets minimum threshold
Bearish Confluence Signal	Bear confluence meets minimum threshold
High Quality Signal	Signal with quality score 8+
Any Confluence Signal	Any bull or bear signal
Full Bull Alignment	ALL enabled timeframes bullish
Full Bear Alignment	ALL enabled timeframes bearish
USE CASES

Trend Following — Set TFs to 15m/1H/4H/Daily. Require trend + momentum. Wait for 4/5+ confluence before entering in the trend direction. This filters out counter-trend noise.

Swing Entry Timing — Use daily trend as your bias, then wait for the 15m/1H to align for precise entry timing. The system tells you exactly when all your timeframes agree.

Signal Filtering — Combine with other indicators as a filter. Only take signals from your primary indicator when MTF Confluence shows 3+ aligned timeframes.

Session Trading — Set your 4 TFs to cover intraday through daily. Only trade during sessions where confluence is high. The background shading makes alignment visually obvious.

Position Sizing — Use the quality score to size positions: full size on Q:8+, half size on Q:6-7, skip trades below Q:6.

SETTINGS OVERVIEW

Timeframes: Enable/disable each of 4 HTFs with configurable timeframe selection.

Trend Detection: Fast EMA, Slow EMA, Trend EMA lengths.

Momentum: RSI length, bull/bear thresholds, MACD confirmation toggle.

Structure: Swing pivot lookback length.

Confluence: Minimum confluence count, required dimensions (trend/momentum/structure toggles), signal cooldown bars.

Display: Signal labels, bar colors, background zones, dashboard, table position, text size.

Colors: Bullish, bearish, strong signal, weak signal, neutral.

TECHNICAL NOTES

Only 4 request.security() calls using tuple syntax — returns trend, momentum, structure, strength, RSI, and MACD per call
All analysis via f_analyze() function called on each timeframe
barmerge.lookahead_off on all security calls
Signals only on barstate.isconfirmed
Cooldown prevents signal clustering
Structure uses ta.pivothigh/pivotlow with confirmation delay
Dashboard renders on barstate.islast only

DISCLAIMER

This indicator is for educational and informational purposes only. It does not constitute financial advice. Multi-timeframe confluence increases probability but does not guarantee outcomes. Higher timeframe data is subject to the limitations of TradingView's request.security() function. Always use proper risk management. Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Multi-Timeframe Confluence System [forexobroker]",
     shorttitle="MTF Confluence",
     overlay=true,
     max_labels_count=500,
     max_lines_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// Multi-Timeframe Confluence System [forexobroker]
// Version 1.0
//
// Generates trading signals ONLY when multiple timeframe conditions align.
// Checks trend direction, momentum state, and market structure across 4
// configurable timeframes plus the current chart. Signals fire when the
// user-defined confluence threshold is met, with quality scoring 1-10.
// Dramatically reduces false signals by requiring multi-TF agreement.
//
// (c) forexobroker | Invite-only (paid)
// ══════════════════════════════════════════════════════════════════════════════

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ INPUTS                                                                  │
// └──────────────────────────────────────────────────────────────────────────┘

// Timeframes
grpTF = "Timeframes"
tf1Enable = input.bool(true, "Enable TF1", group=grpTF, inline="tf1")
tf1       = input.timeframe("15", "TF1", group=grpTF, inline="tf1")
tf2Enable = input.bool(true, "Enable TF2", group=grpTF, inline="tf2")
tf2       = input.timeframe("60", "TF2", group=grpTF, inline="tf2")
tf3Enable = input.bool(true, "Enable TF3", group=grpTF, inline="tf3")
tf3       = input.timeframe("240", "TF3", group=grpTF, inline="tf3")
tf4Enable = input.bool(true, "Enable TF4", group=grpTF, inline="tf4")
tf4       = input.timeframe("D", "TF4", group=grpTF, inline="tf4")

// Trend Detection
grpTrend = "Trend Detection"
emaFast    = input.int(9, "Fast EMA", minval=2, maxval=50, group=grpTrend, tooltip="Fast EMA for trend direction")
emaSlow    = input.int(21, "Slow EMA", minval=5, maxval=100, group=grpTrend, tooltip="Slow EMA for trend confirmation")
emaTrend   = input.int(50, "Trend EMA", minval=20, maxval=200, group=grpTrend, tooltip="Longer EMA for overall trend context")

// Momentum Detection
grpMom = "Momentum Detection"
rsiLen     = input.int(14, "RSI Length", minval=2, maxval=50, group=grpMom)
rsiBullZone = input.int(50, "RSI Bull Threshold", minval=40, maxval=70, group=grpMom, tooltip="RSI above this = bullish momentum")
rsiBearZone = input.int(50, "RSI Bear Threshold", minval=30, maxval=60, group=grpMom, tooltip="RSI below this = bearish momentum")
macdSignal  = input.bool(true, "Use MACD Confirmation", group=grpMom, tooltip="Require MACD histogram to align with direction")

// Structure Detection
grpStruct = "Structure Detection"
structLen  = input.int(5, "Swing Length", minval=2, maxval=20, group=grpStruct, tooltip="Pivot lookback for higher-high/lower-low detection")

// Confluence Settings
grpConf = "Confluence Settings"
minConfluence    = input.int(3, "Min Confluence Factors", minval=2, maxval=5, group=grpConf, tooltip="Minimum number of aligned conditions to generate a signal (out of 5: chart + 4 TFs)")
requireTrend     = input.bool(true, "Require Trend Alignment", group=grpConf, tooltip="Trend (EMA) must align for each counted TF")
requireMomentum  = input.bool(true, "Require Momentum Alignment", group=grpConf, tooltip="Momentum (RSI) must align for each counted TF")
requireStructure = input.bool(false, "Require Structure Alignment", group=grpConf, tooltip="Structure (HH/HL or LH/LL) must align for each counted TF")
signalCooldown   = input.int(5, "Signal Cooldown (bars)", minval=1, maxval=30, group=grpConf, tooltip="Minimum bars between signals to prevent clustering")

// Display
grpDisp = "Display"
showSignals    = input.bool(true, "Show Signal Labels", group=grpDisp)
showBarColors  = input.bool(true, "Show Bar Colors", group=grpDisp, tooltip="Color bars by confluence strength")
showDashboard  = input.bool(true, "Show Dashboard", group=grpDisp)
showZones      = input.bool(true, "Show Confluence Zones", group=grpDisp, tooltip="Shade the background when confluence is high")
tablePosition  = input.string("top_right", "Table Position", options=["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group=grpDisp)
textSizeInput  = input.string("small", "Text Size", options=["tiny","small","normal"], group=grpDisp)

// Colors
grpCol = "Colors"
bullCol   = input.color(#26A69A, "Bullish", group=grpCol)
bearCol   = input.color(#EF5350, "Bearish", group=grpCol)
strongCol = input.color(#00C853, "Strong Signal", group=grpCol)
weakCol   = input.color(#FF9800, "Weak Signal", group=grpCol)
neutralCol = input.color(#787B86, "Neutral", group=grpCol)

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ THEME-AWARE COLORS                                                      │
// └──────────────────────────────────────────────────────────────────────────┘

bool isDark = color.r(chart.bg_color) < 128
headerBg   = isDark ? #2A2E39 : #E8E8E8
headerText = isDark ? #D1D4DC : #333333
cellBg     = isDark ? #1E222D : #F5F5F5
borderCol  = isDark ? #363A45 : #D0D0D0
mutedText  = isDark ? #787B86 : #999999
titleBg    = #1565C0
titleText  = color.white

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ HELPER FUNCTIONS                                                        │
// └──────────────────────────────────────────────────────────────────────────┘

getTablePos() =>
    switch tablePosition
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_center" => position.middle_center
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        "bottom_right"  => position.bottom_right

getTextSize() =>
    switch textSizeInput
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal

getTfLabel(string tf) =>
    tf == "1" ? "M1" : tf == "3" ? "M3" : tf == "5" ? "M5" : tf == "15" ? "M15" : tf == "30" ? "M30" : tf == "60" ? "H1" : tf == "120" ? "H2" : tf == "240" ? "H4" : tf == "D" ? "D1" : tf == "W" ? "W1" : tf == "M" ? "MN" : tf

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ MTF ANALYSIS FUNCTION                                                   │
// └──────────────────────────────────────────────────────────────────────────┘

// Returns tuple: [trendDir, momentumDir, structureDir, trendStrength, rsiVal, macdHist]
// trendDir: 1=bull, -1=bear, 0=neutral
// momentumDir: 1=bull, -1=bear, 0=neutral
// structureDir: 1=bull (HH+HL), -1=bear (LH+LL), 0=neutral

f_analyze() =>
    ef = ta.ema(close, emaFast)
    es = ta.ema(close, emaSlow)
    et = ta.ema(close, emaTrend)

    // Trend: fast > slow > trend EMA = bullish
    tDir = ef > es and close > et ? 1.0 : ef < es and close < et ? -1.0 : 0.0
    tStr = math.abs(ef - es) / nz(ta.atr(14), 1.0) * 100

    // Momentum: RSI + MACD
    rsiV = ta.rsi(close, rsiLen)
    [ml, sl, mh] = ta.macd(close, 12, 26, 9)
    mDir = rsiV > rsiBullZone ? 1.0 : rsiV < rsiBearZone ? -1.0 : 0.0
    if macdSignal
        if mDir == 1.0 and mh < 0
            mDir := 0.0
        if mDir == -1.0 and mh > 0
            mDir := 0.0

    // Structure: higher-high/higher-low vs lower-high/lower-low
    ph = ta.pivothigh(high, structLen, structLen)
    pl = ta.pivotlow(low, structLen, structLen)
    var float lastPH = na
    var float prevPH = na
    var float lastPL = na
    var float prevPL = na
    if not na(ph)
        prevPH := lastPH
        lastPH := ph
    if not na(pl)
        prevPL := lastPL
        lastPL := pl

    hhhl = not na(lastPH) and not na(prevPH) and not na(lastPL) and not na(prevPL) and lastPH > prevPH and lastPL > prevPL
    lhll = not na(lastPH) and not na(prevPH) and not na(lastPL) and not na(prevPL) and lastPH < prevPH and lastPL < prevPL
    sDir = hhhl ? 1.0 : lhll ? -1.0 : 0.0

    [tDir, mDir, sDir, tStr, rsiV, mh]

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ CURRENT TF ANALYSIS                                                     │
// └──────────────────────────────────────────────────────────────────────────┘

[ctTrend, ctMom, ctStruct, ctTStr, ctRSI, ctMACD] = f_analyze()

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ HTF DATA (4 request.security calls)                                     │
// └──────────────────────────────────────────────────────────────────────────┘

[t1Trend, t1Mom, t1Struct, t1TStr, t1RSI, t1MACD] = request.security(syminfo.tickerid, tf1, f_analyze(), lookahead=barmerge.lookahead_off)
[t2Trend, t2Mom, t2Struct, t2TStr, t2RSI, t2MACD] = request.security(syminfo.tickerid, tf2, f_analyze(), lookahead=barmerge.lookahead_off)
[t3Trend, t3Mom, t3Struct, t3TStr, t3RSI, t3MACD] = request.security(syminfo.tickerid, tf3, f_analyze(), lookahead=barmerge.lookahead_off)
[t4Trend, t4Mom, t4Struct, t4TStr, t4RSI, t4MACD] = request.security(syminfo.tickerid, tf4, f_analyze(), lookahead=barmerge.lookahead_off)

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ CONFLUENCE SCORING                                                      │
// └──────────────────────────────────────────────────────────────────────────┘

// Count how many TFs agree on direction
// Each TF contributes a score if its required conditions are met

f_tfScore(float trend, float mom, float struc, bool enabled) =>
    bullScore = 0
    bearScore = 0
    if enabled
        // Check what conditions need to pass
        bool trendBull = not requireTrend or trend > 0
        bool trendBear = not requireTrend or trend < 0
        bool momBull   = not requireMomentum or mom > 0
        bool momBear   = not requireMomentum or mom < 0
        bool structBull = not requireStructure or struc > 0
        bool structBear = not requireStructure or struc < 0

        if trendBull and momBull and structBull
            bullScore := 1
        if trendBear and momBear and structBear
            bearScore := 1
    [bullScore, bearScore]

[ctBull, ctBear] = f_tfScore(ctTrend, ctMom, ctStruct, true)
[t1Bull, t1Bear] = f_tfScore(nz(t1Trend), nz(t1Mom), nz(t1Struct), tf1Enable)
[t2Bull, t2Bear] = f_tfScore(nz(t2Trend), nz(t2Mom), nz(t2Struct), tf2Enable)
[t3Bull, t3Bear] = f_tfScore(nz(t3Trend), nz(t3Mom), nz(t3Struct), tf3Enable)
[t4Bull, t4Bear] = f_tfScore(nz(t4Trend), nz(t4Mom), nz(t4Struct), tf4Enable)

int bullConfluence = ctBull + t1Bull + t2Bull + t3Bull + t4Bull
int bearConfluence = ctBear + t1Bear + t2Bear + t3Bear + t4Bear

int enabledTFs = 1 + (tf1Enable ? 1 : 0) + (tf2Enable ? 1 : 0) + (tf3Enable ? 1 : 0) + (tf4Enable ? 1 : 0)

// Quality score 1-10
float bullQuality = enabledTFs > 0 ? bullConfluence * 10.0 / enabledTFs : 0.0
float bearQuality = enabledTFs > 0 ? bearConfluence * 10.0 / enabledTFs : 0.0
int bullQ = math.round(bullQuality)
int bearQ = math.round(bearQuality)

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ SIGNAL GENERATION                                                       │
// └──────────────────────────────────────────────────────────────────────────┘

var int lastBullBar = 0
var int lastBearBar = 0
var int totalBullSignals = 0
var int totalBearSignals = 0
var int lastSignalQuality = 0
var string lastSignalDir = "None"

// Signal flags
bullSignal = false
bearSignal = false
highQualitySignal = false

if barstate.isconfirmed
    bool bullCooldownOk = bar_index - lastBullBar >= signalCooldown
    bool bearCooldownOk = bar_index - lastBearBar >= signalCooldown

    if bullConfluence >= minConfluence and bullCooldownOk
        bullSignal := true
        lastBullBar := bar_index
        totalBullSignals += 1
        lastSignalQuality := bullQ
        lastSignalDir := "BULLISH"
        if bullQ >= 8
            highQualitySignal := true

    if bearConfluence >= minConfluence and bearCooldownOk
        bearSignal := true
        lastBearBar := bar_index
        totalBearSignals += 1
        lastSignalQuality := bearQ
        lastSignalDir := "BEARISH"
        if bearQ >= 8
            highQualitySignal := true

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ SIGNAL LABELS                                                           │
// └──────────────────────────────────────────────────────────────────────────┘

if showSignals and bullSignal and barstate.isconfirmed
    sigCol = bullQ >= 8 ? strongCol : bullQ >= 6 ? bullCol : weakCol
    sigText = "BUY " + str.tostring(bullConfluence) + "/" + str.tostring(enabledTFs) + "\nQ:" + str.tostring(bullQ)
    label.new(bar_index, low, sigText, style=label.style_label_up, color=color.new(sigCol, 20), textcolor=color.white, size=size.small)

if showSignals and bearSignal and barstate.isconfirmed
    sigCol = bearQ >= 8 ? strongCol : bearQ >= 6 ? bearCol : weakCol
    sigText = "SELL " + str.tostring(bearConfluence) + "/" + str.tostring(enabledTFs) + "\nQ:" + str.tostring(bearQ)
    label.new(bar_index, high, sigText, style=label.style_label_down, color=color.new(sigCol, 20), textcolor=color.white, size=size.small)

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ BAR COLORING + BACKGROUND ZONES                                         │
// └──────────────────────────────────────────────────────────────────────────┘

barCol = not showBarColors ? na : bullConfluence >= minConfluence ? color.new(bullCol, 30) : bearConfluence >= minConfluence ? color.new(bearCol, 30) : bullConfluence >= minConfluence - 1 ? color.new(bullCol, 70) : bearConfluence >= minConfluence - 1 ? color.new(bearCol, 70) : na
barcolor(barCol)

bullZone = showZones and bullConfluence >= minConfluence ? color.new(bullCol, 92) : na
bearZone = showZones and bearConfluence >= minConfluence ? color.new(bearCol, 92) : na
bgcolor(bullZone)
bgcolor(bearZone)

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ DATA WINDOW                                                             │
// └──────────────────────────────────────────────────────────────────────────┘

plot(bullConfluence * 1.0, "Bull Confluence",   display=display.data_window)
plot(bearConfluence * 1.0, "Bear Confluence",   display=display.data_window)
plot(bullQ * 1.0,          "Bull Quality",      display=display.data_window)
plot(bearQ * 1.0,          "Bear Quality",      display=display.data_window)
plot(ctRSI,                "Chart RSI",         display=display.data_window)
plot(ctMACD,               "Chart MACD Hist",   display=display.data_window)
plot(totalBullSignals * 1.0, "Total Bull Sigs", display=display.data_window)
plot(totalBearSignals * 1.0, "Total Bear Sigs", display=display.data_window)

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ DASHBOARD                                                               │
// └──────────────────────────────────────────────────────────────────────────┘

if showDashboard and barstate.islast
    // Columns: Label | Trend | Momentum | Structure | Status
    var table dash = table.new(getTablePos(), 5, 14, border_width=1, border_color=borderCol, frame_width=2, frame_color=borderCol)
    tSz = getTextSize()
    int row = 0

    // Row 0 — Title
    table.cell(dash, 0, row, "MTF CONFLUENCE", text_color=titleText, bgcolor=titleBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, "Trend", text_color=titleText, bgcolor=titleBg, text_size=tSz)
    table.cell(dash, 2, row, "Mom", text_color=titleText, bgcolor=titleBg, text_size=tSz)
    table.cell(dash, 3, row, "Struct", text_color=titleText, bgcolor=titleBg, text_size=tSz)
    table.cell(dash, 4, row, "Status", text_color=titleText, bgcolor=titleBg, text_size=tSz)
    row += 1

    // TF row data: [name, trend, mom, struct, enabled] — inline since Pine can't pass table to functions
    // Use arrays to loop over 5 TF rows
    tfNames   = array.from("Chart", getTfLabel(tf1), getTfLabel(tf2), getTfLabel(tf3), getTfLabel(tf4))
    tfTrends  = array.from(ctTrend, nz(t1Trend), nz(t2Trend), nz(t3Trend), nz(t4Trend))
    tfMoms    = array.from(ctMom, nz(t1Mom), nz(t2Mom), nz(t3Mom), nz(t4Mom))
    tfStructs = array.from(ctStruct, nz(t1Struct), nz(t2Struct), nz(t3Struct), nz(t4Struct))
    tfEnabled = array.from(true, tf1Enable, tf2Enable, tf3Enable, tf4Enable)

    for i = 0 to 4
        string rName = array.get(tfNames, i)
        float  rTrend = array.get(tfTrends, i)
        float  rMom   = array.get(tfMoms, i)
        float  rStruc = array.get(tfStructs, i)
        bool   rOn    = array.get(tfEnabled, i)

        if not rOn
            table.cell(dash, 0, row, rName, text_color=mutedText, bgcolor=cellBg, text_size=tSz, text_halign=text.align_left)
            table.cell(dash, 1, row, "OFF", text_color=mutedText, bgcolor=cellBg, text_size=tSz)
            table.cell(dash, 2, row, "OFF", text_color=mutedText, bgcolor=cellBg, text_size=tSz)
            table.cell(dash, 3, row, "OFF", text_color=mutedText, bgcolor=cellBg, text_size=tSz)
            table.cell(dash, 4, row, "—", text_color=mutedText, bgcolor=cellBg, text_size=tSz)
        else
            color tCol = rTrend > 0 ? bullCol : rTrend < 0 ? bearCol : neutralCol
            color mCol = rMom > 0 ? bullCol : rMom < 0 ? bearCol : neutralCol
            color sCol = rStruc > 0 ? bullCol : rStruc < 0 ? bearCol : neutralCol
            string tText = rTrend > 0 ? "BULL" : rTrend < 0 ? "BEAR" : "FLAT"
            string mText = rMom > 0 ? "BULL" : rMom < 0 ? "BEAR" : "FLAT"
            string sText = rStruc > 0 ? "HH/HL" : rStruc < 0 ? "LH/LL" : "MIXED"

            bool allBull = (not requireTrend or rTrend > 0) and (not requireMomentum or rMom > 0) and (not requireStructure or rStruc > 0)
            bool allBear = (not requireTrend or rTrend < 0) and (not requireMomentum or rMom < 0) and (not requireStructure or rStruc < 0)
            string statusText = allBull ? "ALIGNED" : allBear ? "ALIGNED" : "MIXED"
            color  statusCol  = allBull ? bullCol : allBear ? bearCol : neutralCol

            table.cell(dash, 0, row, rName, text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
            table.cell(dash, 1, row, tText, text_color=color.white, bgcolor=color.new(tCol, 40), text_size=tSz)
            table.cell(dash, 2, row, mText, text_color=color.white, bgcolor=color.new(mCol, 40), text_size=tSz)
            table.cell(dash, 3, row, sText, text_color=color.white, bgcolor=color.new(sCol, 40), text_size=tSz)
            table.cell(dash, 4, row, statusText, text_color=color.white, bgcolor=color.new(statusCol, 30), text_size=tSz)
        row += 1

    // Row 6 — Section header: Confluence
    table.cell(dash, 0, row, "CONFLUENCE", text_color=titleText, bgcolor=color.new(strongCol, 30), text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, "", text_color=titleText, bgcolor=color.new(strongCol, 30), text_size=tSz)
    table.cell(dash, 2, row, "", text_color=titleText, bgcolor=color.new(strongCol, 30), text_size=tSz)
    table.cell(dash, 3, row, "", text_color=titleText, bgcolor=color.new(strongCol, 30), text_size=tSz)
    table.cell(dash, 4, row, "", text_color=titleText, bgcolor=color.new(strongCol, 30), text_size=tSz)
    row += 1

    // Row 7 — Bull Confluence
    bullText = str.tostring(bullConfluence) + " / " + str.tostring(enabledTFs)
    bullC = bullConfluence >= minConfluence ? bullCol : bullConfluence >= minConfluence - 1 ? weakCol : neutralCol
    table.cell(dash, 0, row, "Bull Score", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, bullText, text_color=bullC, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "Q: " + str.tostring(bullQ), text_color=bullC, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, bullConfluence >= minConfluence ? "SIGNAL" : "—", text_color=bullConfluence >= minConfluence ? color.white : mutedText, bgcolor=bullConfluence >= minConfluence ? color.new(bullCol, 30) : cellBg, text_size=tSz)
    table.cell(dash, 4, row, bullQ >= 8 ? "HIGH" : bullQ >= 6 ? "MED" : "LOW", text_color=bullQ >= 8 ? strongCol : bullQ >= 6 ? bullCol : mutedText, bgcolor=cellBg, text_size=tSz)
    row += 1

    // Row 8 — Bear Confluence
    bearText = str.tostring(bearConfluence) + " / " + str.tostring(enabledTFs)
    bearC = bearConfluence >= minConfluence ? bearCol : bearConfluence >= minConfluence - 1 ? weakCol : neutralCol
    table.cell(dash, 0, row, "Bear Score", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, bearText, text_color=bearC, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "Q: " + str.tostring(bearQ), text_color=bearC, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, bearConfluence >= minConfluence ? "SIGNAL" : "—", text_color=bearConfluence >= minConfluence ? color.white : mutedText, bgcolor=bearConfluence >= minConfluence ? color.new(bearCol, 30) : cellBg, text_size=tSz)
    table.cell(dash, 4, row, bearQ >= 8 ? "HIGH" : bearQ >= 6 ? "MED" : "LOW", text_color=bearQ >= 8 ? strongCol : bearQ >= 6 ? bearCol : mutedText, bgcolor=cellBg, text_size=tSz)
    row += 1

    // Row 9 — Section header: Status
    table.cell(dash, 0, row, "STATUS", text_color=titleText, bgcolor=color.new(titleBg, 30), text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, "", text_color=titleText, bgcolor=color.new(titleBg, 30), text_size=tSz)
    table.cell(dash, 2, row, "", text_color=titleText, bgcolor=color.new(titleBg, 30), text_size=tSz)
    table.cell(dash, 3, row, "", text_color=titleText, bgcolor=color.new(titleBg, 30), text_size=tSz)
    table.cell(dash, 4, row, "", text_color=titleText, bgcolor=color.new(titleBg, 30), text_size=tSz)
    row += 1

    // Row 10 — Last Signal
    lsCol = lastSignalDir == "BULLISH" ? bullCol : lastSignalDir == "BEARISH" ? bearCol : mutedText
    lsAge = lastSignalDir == "BULLISH" ? bar_index - lastBullBar : lastSignalDir == "BEARISH" ? bar_index - lastBearBar : 0
    lsText = lastSignalDir != "None" ? lastSignalDir + " Q:" + str.tostring(lastSignalQuality) : "Waiting..."
    table.cell(dash, 0, row, "Last Signal", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, lsText, text_color=lsCol, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "", text_color=mutedText, bgcolor=cellBg, text_size=tSz)
    ageText = lastSignalDir != "None" ? str.tostring(lsAge) + " bars" : "—"
    table.cell(dash, 3, row, ageText, text_color=lsAge <= 5 ? bullCol : lsAge <= 15 ? weakCol : mutedText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 4, row, "", text_color=mutedText, bgcolor=cellBg, text_size=tSz)
    row += 1

    // Row 11 — Total Signals
    table.cell(dash, 0, row, "Total Signals", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, "Bull: " + str.tostring(totalBullSignals), text_color=bullCol, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "Bear: " + str.tostring(totalBearSignals), text_color=bearCol, bgcolor=cellBg, text_size=tSz)
    totalS = totalBullSignals + totalBearSignals
    table.cell(dash, 3, row, "Total: " + str.tostring(totalS), text_color=headerText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 4, row, "", text_color=mutedText, bgcolor=cellBg, text_size=tSz)
    row += 1

    // Row 12 — Settings Info
    reqText = (requireTrend ? "T" : "") + (requireMomentum ? "M" : "") + (requireStructure ? "S" : "")
    table.cell(dash, 0, row, "Required", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    table.cell(dash, 1, row, reqText, text_color=headerText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 2, row, "Min: " + str.tostring(minConfluence), text_color=headerText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, "CD: " + str.tostring(signalCooldown), text_color=headerText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 4, row, str.tostring(enabledTFs) + " TFs", text_color=headerText, bgcolor=cellBg, text_size=tSz)
    row += 1

    // Row 13 — RSI snapshot
    table.cell(dash, 0, row, "Chart RSI", text_color=headerText, bgcolor=headerBg, text_size=tSz, text_halign=text.align_left)
    rsiStr = str.tostring(ctRSI, "#.#")
    rsiColor = ctRSI > 70 ? bearCol : ctRSI < 30 ? bullCol : ctRSI > rsiBullZone ? bullCol : ctRSI < rsiBearZone ? bearCol : neutralCol
    table.cell(dash, 1, row, rsiStr, text_color=rsiColor, bgcolor=cellBg, text_size=tSz)
    macdStr = ctMACD > 0 ? "+" : ctMACD < 0 ? "-" : "0"
    macdColor = ctMACD > 0 ? bullCol : ctMACD < 0 ? bearCol : neutralCol
    table.cell(dash, 2, row, "MACD " + macdStr, text_color=macdColor, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 3, row, "", text_color=mutedText, bgcolor=cellBg, text_size=tSz)
    table.cell(dash, 4, row, "", text_color=mutedText, bgcolor=cellBg, text_size=tSz)

// ┌──────────────────────────────────────────────────────────────────────────┐
// │ ALERTS                                                                  │
// └──────────────────────────────────────────────────────────────────────────┘

alertcondition(bullSignal, "Bullish Confluence Signal", "MTF Confluence: Bullish signal — multiple timeframes aligned")
alertcondition(bearSignal, "Bearish Confluence Signal", "MTF Confluence: Bearish signal — multiple timeframes aligned")
alertcondition(highQualitySignal, "High Quality Signal", "MTF Confluence: High quality signal (Q8+) detected")
alertcondition(bullSignal or bearSignal, "Any Confluence Signal", "MTF Confluence: Signal detected")
alertcondition(bullConfluence >= enabledTFs, "Full Bull Alignment", "MTF Confluence: ALL timeframes bullish")
alertcondition(bearConfluence >= enabledTFs, "Full Bear Alignment", "MTF Confluence: ALL timeframes bearish")
````
