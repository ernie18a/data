# Uptrick: Adaptive Momentum Bands

- url: https://www.tradingview.com/script/fj98QZe8-Uptrick-Adaptive-Momentum-Bands/
- type: indicator
- pine_id: PUB;5ca5e4e120734acd805e070011c59a46
- version: 1.0

## Description

[b][i]Introduction[/i][/b]
Adaptive Momentum Bands is an overlay indicator that combines an Adaptive Moving Average baseline with dynamically scaled ATR bands to define trend state, generate entry signals, and provide a real-time market context dashboard. Unlike static band systems that apply a fixed multiplier regardless of market conditions, this indicator continuously adjusts its band width and baseline responsiveness based on how directional price movement currently is. The result is a system that tightens during trending phases and loosens during choppy conditions automatically, without requiring manual parameter changes.

The core philosophy behind this tool is that a single fixed lookback or multiplier will inevitably either over-signal in noise or under-signal in trends. By anchoring both the baseline speed and the band expansion to a live Efficiency Ratio calculation, the indicator adapts its behavior to the market it is analyzing rather than forcing the market into a fixed model.

[b][i]Originality[/i][/b]
The baseline is not a standard EMA or KAMA. It is a multi-stage adaptive construction: an Adaptive Moving Average driven by a per-bar Efficiency Ratio smoothing coefficient is passed through two additional EMA layers to produce a stable, low-lag midline. This midline is then used as the reference point for asymmetric ATR bands that apply independent upper and lower multipliers, each of which is further scaled by a volatility ratio comparing short-term ATR to its longer-term normalized average. This means the bands breathe with volatility in real time. The trend state uses a latching mechanism: the indicator never enters a neutral zone. Once price closes above the upper band it locks to bullish, once it closes below the lower band it locks to bearish, and it holds that state until the opposite condition is met. This produces clean, decisive, non-flickering bias coloring across candles, bands, midline, and labels.

[b][i]Features[/i][/b]
[list]
[*] Adaptive baseline engine using an Efficiency Ratio-driven smoothing coefficient that automatically speeds up during directional moves and slows down during chop
[*] Multi-stage midline construction combining an AMA layer with two EMA passes for a smooth, responsive center reference
[*] Asymmetric upper and lower band multipliers allowing independent control over how loose or tight each side of the channel is
[*] Volatility ratio scaling that expands the bands during high-volatility regimes and contracts them during low-volatility periods, using a ratio of short-term ATR to its normalized average
[*] Three display modes: Bands mode showing the full channel with gradient fill, Midline Only mode for a clean ribbon overlay, and Trail mode that switches the visible line to the active support or resistance side
Bands:
[image]https://www.tradingview.com/x/arGB6uCb/[/image]
Trail:
[image]https://www.tradingview.com/x/rZHHiNqA/[/image]
Midline:
[image]https://www.tradingview.com/x/DwzR98Dp/[/image]
[*] Latching trend state that is always bullish or bearish with no neutral zone, toggling only on confirmed band crossovers
[*] Colored candles, wick coloring, and candle borders all driven by the live trend state
[*] Signal labels on trend flips with configurable anchor point (High/Low, Midline, or Bands), ATR-based label offset control, and four label size options
[*] Status dashboard table displaying: current trend bias, bars held in the current state, Efficiency Ratio percentage with color-coded thresholds, band width as a percentage of midline, price distance from midline as a percentage, smoothed ATR value, 1-bar ROC, 5-bar ROC, 20-bar ROC, and the active upper and lower multiplier values
[image]https://www.tradingview.com/x/O9TJykDY/[/image]
[*] Independent alert conditions for bullish and bearish transitions, triggering only on the first confirmed bar of a new state
[/list]

[b][i]Inputs[/i][/b]
[list]
[*]Base Length: Controls the period used in the internal EMA pass over the AMA layer. Shorter values produce a faster and more reactive midline.
[*]ATR Length: Sets the lookback for the ATR calculation used in band construction. Shorter values make bands more responsive to recent volatility spikes.
[*]Band Smoothing: Applies EMA smoothing to both the ATR value and the final band plots. Higher values produce smoother, less reactive bands.
[*]Upper Band Multiplier: Determines how far the upper band sits above the midline as a multiple of the smoothed ATR. Higher values reduce the frequency of bullish signals.
[*]Lower Band Multiplier: Determines how far the lower band sits below the midline as a multiple of the smoothed ATR. Higher values reduce the frequency of bearish signals.
[*]Efficiency Period: The lookback used to calculate the Efficiency Ratio. This controls how quickly the adaptive baseline reacts to changes in trend quality.
[*]Fast EMA and Slow EMA: Define the fast and slow smoothing constants used in the adaptive speed calculation. The indicator interpolates between these two speeds based on the current Efficiency Ratio.
[*]Display Mode: Selects between Bands, Midline Only, and Trail rendering modes.
[*]Fill Opacity: Controls the transparency of the band fill.
[*]Bull and Bear Colour: Fully customizable primary colors used for all trend-state visuals.
[*]Show Labels, Label Anchor, Offset Multiplier, Label Size: Controls for the flip signal labels.
[*]Show Table, Position, Text Size: Controls for the status dashboard.
[/list]

[b][i]How to Use[/i][/b]
Apply the indicator to any chart and timeframe. The colored candles will immediately show the current trend bias. When the system is in bullish state, the bands and midline render in the bullish color. When bearish, they switch to the bearish color. A 𝓛𝓸𝓷𝓰 label marks each new bullish flip and a 𝓢𝓱𝓸𝓻𝓽 label marks each new bearish flip.

Use the Efficiency Ratio row in the status table to gauge how much to trust the current signal. A reading above 60 indicates a strong trend where band-based signals are more reliable. Readings below 35 indicate a choppy environment where signals should be treated with more caution. The band width percentage and distance from midline rows help assess whether price is extended or near the center of the range. ROC rows provide quick momentum context across three timeframes.

For tighter and more frequent signals, reduce the band multipliers. For wider and less frequent signals, increase them. The asymmetric design means you can independently adjust sensitivity to bullish and bearish entries.

[b][i]Conclusion[/i][/b]
Adaptive Momentum Bands provides a self-calibrating trend framework that eliminates the need to manually switch parameters across assets or timeframes. The combination of adaptive baseline speed, volatility-scaled asymmetric bands, a latching trend state, and a live metrics table gives traders a complete picture of current market structure in a single overlay tool.

[quote]Disclaimer
This indicator is for informational and educational purposes only and does not constitute financial advice. Past performance of any signals produced by this tool does not guarantee future results. All trading involves risk. Use this tool as one input among many and always apply your own risk management.[/quote]

## Source Code

````pine
// This work is licensed under an Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0) 
// https://creativecommons.org/licenses/by-sa/4.0/
// © Uptrick
//@version=6


//    ██╗   ██╗██████╗ ████████╗██████╗ ██╗ ██████╗██╗  ██╗
//    ██║   ██║██╔══██╗╚══██╔══╝██╔══██╗██║██╔════╝██║ ██╔╝
//    ██║   ██║██████╔╝   ██║   ██████╔╝██║██║     █████╔╝ 
//    ██║   ██║██╔═══╝    ██║   ██╔══██╗██║██║     ██╔═██╗ 
//    ╚██████╔╝██║        ██║   ██║  ██║██║╚██████╗██║  ██╗
//     ╚═════╝ ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝
indicator('Uptrick: Adaptive Momentum Bands', overlay = true, max_labels_count = 500)

// ╔══════════════════════════════════════════════════════════════════╗
// ║  CORE SETTINGS                                                   ║
// ╚══════════════════════════════════════════════════════════════════╝
grp1 = '━━━━━━━━  Core Settings  ━━━━━━━━'
baseLen    = input.int(8,    'Base Length',       minval = 2,   maxval = 50,  group = grp1)
atrLen     = input.int(7,    'ATR Length',        minval = 3,   maxval = 30,  group = grp1)
bandSmooth = input.int(8,    'Band Smoothing',    minval = 2,   maxval = 50,  group = grp1)

// ╔══════════════════════════════════════════════════════════════════╗
// ║  SEPARATE BAND MULTIPLIERS                                       ║
// ╚══════════════════════════════════════════════════════════════════╝
grp1b = '━━━━━━━━  Band Multipliers  ━━━━━━━━'
upperMult  = input.float(1.5, 'Upper Band Multiplier', minval = 0.1, maxval = 6.0, step = 0.05, group = grp1b,
     tooltip = 'Controls how far the upper band sits above the midline. Higher = looser (fewer bull signals).')
lowerMult  = input.float(1.5, 'Lower Band Multiplier', minval = 0.1, maxval = 6.0, step = 0.05, group = grp1b,
     tooltip = 'Controls how far the lower band sits below the midline. Higher = looser (fewer bear signals).')

// ╔══════════════════════════════════════════════════════════════════╗
// ║  ADAPTIVE SENSITIVITY                                            ║
// ╚══════════════════════════════════════════════════════════════════╝
grp2      = '━━━━━━━━  Adaptive Sensitivity  ━━━━━━━━'
adaptLen   = input.int(14, 'Efficiency Period', minval = 5,  maxval = 50, group = grp2)
fastSmooth = input.int(2,  'Fast EMA',          minval = 1,  maxval = 5,  group = grp2)
slowSmooth = input.int(10, 'Slow EMA',          minval = 3,  maxval = 30, group = grp2)

// ╔══════════════════════════════════════════════════════════════════╗
// ║  DISPLAY                                                         ║
// ╚══════════════════════════════════════════════════════════════════╝
grp3        = '━━━━━━━━  Display  ━━━━━━━━'
displayMode = input.string('Bands', 'Display Mode',
     options = ['Bands', 'Midline Only', 'Trail'], group = grp3)
fillTrans   = input.int(85, 'Fill Opacity', minval = 50, maxval = 99, group = grp3)

// ╔══════════════════════════════════════════════════════════════════╗
// ║  COLOURS                                                         ║
// ╚══════════════════════════════════════════════════════════════════╝
grp4      = '━━━━━━━━  Colours  ━━━━━━━━'
bullMain  = input.color(color.new(#5CF0D7, 0), 'Bull Colour', group = grp4)
bearMain  = input.color(color.new(#B32AC3, 0), 'Bear Colour', group = grp4)

// ╔══════════════════════════════════════════════════════════════════╗
// ║  SIGNAL LABELS                                                   ║
// ╚══════════════════════════════════════════════════════════════════╝
grpL           = '━━━━━━━━  Signal Labels  ━━━━━━━━'
showLabels     = input.bool(true,  'Show Labels',         group = grpL)
labelAnchor    = input.string('Main Line', 'Label Anchor',
     options   = ['High/Low', 'Main Line', 'Bands'],      group = grpL)
labelOffsetMult = input.float(0.50, 'Offset Mult (ATR)',
     minval    = 0.0, step = 0.05,                        group = grpL)
labelSize      = input.string('Normal', 'Label Size',
     options   = ['Tiny', 'Small', 'Normal', 'Large'],    group = grpL)

// ╔══════════════════════════════════════════════════════════════════╗
// ║  STATUS TABLE                                                    ║
// ╚══════════════════════════════════════════════════════════════════╝
grpT        = '━━━━━━━━  Status Table  ━━━━━━━━'
showTable   = input.bool(true,  'Show Table',   group = grpT)
tblPos      = input.string('Bottom Right', 'Position',
     options = ['Top Left','Top Right','Bottom Left','Bottom Right'], group = grpT)
tblTextSize = input.string('Small', 'Text Size',
     options = ['Tiny','Small','Normal'], group = grpT)

// ══════════════════════════════════════════════════════════════════
//  ADAPTIVE SPEED
// ══════════════════════════════════════════════════════════════════
direction = math.abs(close - close[adaptLen])
noise     = math.sum(math.abs(close - close[1]), adaptLen)
er        = noise != 0 ? direction / noise : 0.0

fastSC = 2.0 / (fastSmooth + 1)
slowSC = 2.0 / (slowSmooth + 1)
sc     = math.pow(er * (fastSC - slowSC) + slowSC, 2)

// ══════════════════════════════════════════════════════════════════
//  ADAPTIVE BASELINE
// ══════════════════════════════════════════════════════════════════
var float ama1 = na
ama1    := na(ama1[1]) ? close : ama1[1] + sc * (close - ama1[1])
ama2    = ta.ema(ama1, math.max(2, math.round(baseLen * 0.5)))
amrLine = ta.ema(ama2, 2)
ema2Line = ta.ema(amrLine, 2)

// ══════════════════════════════════════════════════════════════════
//  SMOOTH BANDS  (separate upper / lower multipliers)
// ══════════════════════════════════════════════════════════════════
atrSmooth = ta.ema(ta.atr(atrLen), bandSmooth)
atrNorm   = ta.ema(atrSmooth, atrLen)
volRatio  = atrSmooth / atrNorm

dynMultUp = upperMult * math.max(0.5, math.min(volRatio, 1.8))
dynMultDn = lowerMult * math.max(0.5, math.min(volRatio, 1.8))

upperBand = ta.ema(amrLine + dynMultUp * atrSmooth, bandSmooth)
lowerBand = ta.ema(amrLine - dynMultDn * atrSmooth, bandSmooth)

// ══════════════════════════════════════════════════════════════════
//  TREND STATE  — latching, never neutral
// ══════════════════════════════════════════════════════════════════
var bool isBull = true
if close > upperBand
    isBull := true
if close < lowerBand
    isBull := false

trendCol = isBull ? bullMain : bearMain

// ══════════════════════════════════════════════════════════════════
//  DISPLAY FLAGS
// ══════════════════════════════════════════════════════════════════
isBands   = displayMode == 'Bands'
isMidline = displayMode == 'Midline Only'
isTrail   = displayMode == 'Trail'

trailLine = isBull ? lowerBand : upperBand

// ══════════════════════════════════════════════════════════════════
//  PLOTS
// ══════════════════════════════════════════════════════════════════

// Bands
pUpper = plot(isBands ? upperBand : na, 'Upper Band',
     color = color.new(trendCol, 45), linewidth = 1)
pLower = plot(isBands ? lowerBand : na, 'Lower Band',
     color = color.new(trendCol, 45), linewidth = 1)

// Midline (thick glow + thin crisp)
pMid   = plot(not isTrail ? amrLine  : na, 'AMR Midline',
     color = trendCol, linewidth = 2)
pEma2  = plot(not isTrail ? ema2Line : na, 'EMA2 of Midline',
     color = color.new(trendCol, 55), linewidth = 1)
pMid1  = plot(not isTrail ? amrLine  : na, 'AMR Midline Glow',
     color = color.new(trendCol, 70), linewidth = 10)
pEma21 = plot(not isTrail ? ema2Line : na, 'EMA2 Glow',
     color = color.new(trendCol, 70), linewidth = 10)

// Trail
pTrail    = plot(isTrail ? trailLine : na, 'Trail',
     color = trendCol, linewidth = 2)
pMidTrail = plot(isTrail ? amrLine   : na, 'Midline (trail)',
     color = color.new(trendCol, 60), linewidth = 1)

// ══════════════════════════════════════════════════════════════════
//  FILLS
// ══════════════════════════════════════════════════════════════════
fill(pUpper, pLower,
     color = isBands ? color.new(trendCol, fillTrans) : na,
     title = 'Band Fill')

fill(pMid, pEma2,
     color = not isTrail ? color.new(trendCol, 0) : na,
     title = 'Midline Ribbon')

fill(pTrail, pMidTrail,
     top_value    = isTrail ? isBull ? amrLine   : trailLine : na,
     bottom_value = isTrail ? isBull ? trailLine : amrLine   : na,
     top_color    = isTrail ? isBull ? color.new(trendCol, 100) : color.new(trendCol, 70)  : na,
     bottom_color = isTrail ? isBull ? color.new(trendCol, 70)  : color.new(trendCol, 100) : na,
     title        = 'Trail Gradient')

// ══════════════════════════════════════════════════════════════════
//  BAR / CANDLE COLOUR
// ══════════════════════════════════════════════════════════════════
barcolor(color.new(trendCol, 0))
plotcandle(open, high, low, close,
     color       = color.new(trendCol, 0),
     wickcolor   = color.new(trendCol, 0),
     bordercolor = color.new(trendCol, 0))

// ══════════════════════════════════════════════════════════════════
//  SIGNAL LABELS  — LONG / SHORT
// ══════════════════════════════════════════════════════════════════
f_lblSize(string s) =>
    s == 'Tiny'   ? size.tiny   :
     s == 'Small'  ? size.small  :
     s == 'Large'  ? size.large  :
     size.normal

int   lastState  = isBull ? 1 : -1
var int prevState = lastState

labelOffset = ta.atr(14) * labelOffsetMult

baseLongY  =
     labelAnchor == 'High/Low' ? low       :
     labelAnchor == 'Bands'    ? lowerBand :
     amrLine

baseShortY =
     labelAnchor == 'High/Low' ? high      :
     labelAnchor == 'Bands'    ? upperBand :
     amrLine

longY  = baseLongY  - labelOffset
shortY = baseShortY + labelOffset

if barstate.isconfirmed
    if showLabels and lastState != prevState and prevState != 0
        if lastState == 1
            label.new(
                 bar_index, longY,
                 '𝓛𝓸𝓷𝓰',
                 style     = label.style_label_up,
                 color     = bullMain,
                 textcolor = color.black,
                 size      = f_lblSize(labelSize)
            )
        else if lastState == -1
            label.new(
                 bar_index, shortY,
                 '𝓢𝓱𝓸𝓻𝓽',
                 style     = label.style_label_down,
                 color     = bearMain,
                 textcolor = color.white,
                 size      = f_lblSize(labelSize)
            )
    prevState := lastState

// ══════════════════════════════════════════════════════════════════
//  STATUS TABLE
// ══════════════════════════════════════════════════════════════════

// ── Helpers ────────────────────────────────────────────────────────
f_tblPos(string p) =>
    p == 'Top Left'     ? position.top_left     :
     p == 'Top Right'    ? position.top_right    :
     p == 'Bottom Left'  ? position.bottom_left  :
     position.bottom_right

f_tblTxt(string s) =>
    s == 'Tiny'   ? size.tiny   :
     s == 'Normal' ? size.normal :
     size.small

// ── Derived metrics ────────────────────────────────────────────────
float roc1  = ta.roc(close, 1)
float roc5  = ta.roc(close, 5)
float roc20 = ta.roc(close, 20)

// Efficiency Ratio (already computed above as `er`) — re-expose as pct
float erPct = math.round(er * 100, 1)

// Band width as % of midline
float bWidth = amrLine != 0.0 ?
     math.round((upperBand - lowerBand) / amrLine * 100, 2) : na

// Distance of close from midline (%)
float distMid = amrLine != 0.0 ?
     math.round((close - amrLine) / amrLine * 100, 2) : na

// Bars since last flip
var int barsSinceFlip = 0
if lastState != prevState[1]          // detect flip on the confirmed bar
    barsSinceFlip := 0
else
    barsSinceFlip += 1

// ATR value (smoothed)
float atrVal = math.round(atrSmooth, 2)

// ── Colour helpers ─────────────────────────────────────────────────
BLK  = #0a0a0a
DGRY = color.new(color.gray, 55)
LGRY = color.new(color.gray, 25)
WHT  = #e8e8e8
ACC  = isBull ? bullMain : bearMain

f_valCol(float v) => v > 0 ? bullMain : bearMain
f_fmt(float v, string suf) => str.tostring(math.round(v, 2)) + suf

// ── Table declaration ──────────────────────────────────────────────
var table tbl = table.new(
     f_tblPos(tblPos), 2, 11,
     bgcolor      = color.new(BLK, 5),
     border_color = color.new(color.gray, 60),
     frame_color  = color.new(color.gray, 45),
     frame_width  = 1,
     border_width = 1
)

// ── Draw table every realtime / history bar ─────────────────────────
if showTable and (barstate.islastconfirmedhistory or barstate.isrealtime)
    sz = f_tblTxt(tblTextSize)

    // ── Row 0: Header ────────────────────────────────────────────
    table.cell(tbl, 0, 0, 'AMB v2  ·  Status',
         text_color   = ACC,
         bgcolor      = color.new(BLK, 0),
         text_halign  = text.align_center,
         text_size    = sz,
         text_font_family = font.family_monospace)
    table.merge_cells(tbl, 0, 0, 1, 0)

    // ── Row 1: Trend ─────────────────────────────────────────────
    trendStr = isBull ? '▲  BULL' : '▼  BEAR'
    trendC   = isBull ? bullMain  : bearMain
    table.cell(tbl, 0, 1, 'Trend',
         text_color = LGRY, bgcolor = color.new(trendC, 90),
         text_halign = text.align_left, text_size = sz,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 1, trendStr,
         text_color = trendC, bgcolor = color.new(trendC, 90),
         text_halign = text.align_right, text_size = sz,
         text_font_family = font.family_monospace)

    // ── Row 2: Bars in State ──────────────────────────────────────
    table.cell(tbl, 0, 2, 'Bars in State',
         text_color = LGRY, bgcolor = color.new(BLK, 20),
         text_halign = text.align_left, text_size = sz,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 2, str.tostring(barsSinceFlip),
         text_color = WHT, bgcolor = color.new(BLK, 20),
         text_halign = text.align_right, text_size = sz,
         text_font_family = font.family_monospace)

    // ── Row 3: Efficiency Ratio ───────────────────────────────────
    erC = erPct > 60 ? bullMain : erPct > 35 ? color.orange : bearMain
    table.cell(tbl, 0, 3, 'Efficiency Ratio',
         text_color = LGRY, bgcolor = color.new(BLK, 20),
         text_halign = text.align_left, text_size = sz,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 3, f_fmt(erPct, '%'),
         text_color = erC, bgcolor = color.new(BLK, 20),
         text_halign = text.align_right, text_size = sz,
         text_font_family = font.family_monospace)

    // ── Row 4: Band Width ─────────────────────────────────────────
    bwC = na(bWidth) ? LGRY : bWidth > 5.0 ? bearMain : bullMain
    table.cell(tbl, 0, 4, 'Band Width %',
         text_color = LGRY, bgcolor = color.new(BLK, 20),
         text_halign = text.align_left, text_size = sz,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 4, na(bWidth) ? '—' : f_fmt(bWidth, '%'),
         text_color = bwC, bgcolor = color.new(BLK, 20),
         text_halign = text.align_right, text_size = sz,
         text_font_family = font.family_monospace)

    // ── Row 5: Dist from Midline ──────────────────────────────────
    dmC = na(distMid) ? LGRY : distMid > 0 ? bullMain : bearMain
    table.cell(tbl, 0, 5, 'Dist Midline %',
         text_color = LGRY, bgcolor = color.new(BLK, 20),
         text_halign = text.align_left, text_size = sz,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 5, na(distMid) ? '—' : f_fmt(distMid, '%'),
         text_color = dmC, bgcolor = color.new(BLK, 20),
         text_halign = text.align_right, text_size = sz,
         text_font_family = font.family_monospace)

    // ── Row 6: ATR ───────────────────────────────────────────────
    table.cell(tbl, 0, 6, 'ATR (smoothed)',
         text_color = LGRY, bgcolor = color.new(BLK, 20),
         text_halign = text.align_left, text_size = sz,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 6, str.tostring(atrVal),
         text_color = WHT, bgcolor = color.new(BLK, 20),
         text_halign = text.align_right, text_size = sz,
         text_font_family = font.family_monospace)

    // ── Row 7: ROC 1-bar ─────────────────────────────────────────
    table.cell(tbl, 0, 7, 'ROC  1-bar',
         text_color = LGRY, bgcolor = color.new(BLK, 20),
         text_halign = text.align_left, text_size = sz,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 7, f_fmt(math.round(roc1,  2), '%'),
         text_color = f_valCol(roc1), bgcolor = color.new(BLK, 20),
         text_halign = text.align_right, text_size = sz,
         text_font_family = font.family_monospace)

    // ── Row 8: ROC 5-bar ─────────────────────────────────────────
    table.cell(tbl, 0, 8, 'ROC  5-bar',
         text_color = LGRY, bgcolor = color.new(BLK, 20),
         text_halign = text.align_left, text_size = sz,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 8, f_fmt(math.round(roc5,  2), '%'),
         text_color = f_valCol(roc5), bgcolor = color.new(BLK, 20),
         text_halign = text.align_right, text_size = sz,
         text_font_family = font.family_monospace)

    // ── Row 9: ROC 20-bar ────────────────────────────────────────
    table.cell(tbl, 0, 9, 'ROC 20-bar',
         text_color = LGRY, bgcolor = color.new(BLK, 20),
         text_halign = text.align_left, text_size = sz,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 9, f_fmt(math.round(roc20, 2), '%'),
         text_color = f_valCol(roc20), bgcolor = color.new(BLK, 20),
         text_halign = text.align_right, text_size = sz,
         text_font_family = font.family_monospace)

    // ── Row 10: Multipliers reminder ─────────────────────────────
    multStr = '↑ ' + str.tostring(upperMult) + '  ↓ ' + str.tostring(lowerMult)
    table.cell(tbl, 0, 10, 'Mults  U / L',
         text_color = DGRY, bgcolor = color.new(BLK, 5),
         text_halign = text.align_left, text_size = sz,
         text_font_family = font.family_monospace)
    table.cell(tbl, 1, 10, multStr,
         text_color = ACC, bgcolor = color.new(BLK, 5),
         text_halign = text.align_right, text_size = sz,
         text_font_family = font.family_monospace)

// ══════════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════════
alertcondition(
     close > upperBand and not (close[1] > upperBand[1]),
     'Turned Bullish',
     'AMB v2: Price closed above upper band — LONG signal')
alertcondition(
     close < lowerBand and not (close[1] < lowerBand[1]),
     'Turned Bearish',
     'AMB v2: Price closed below lower band — SHORT signal')
````
