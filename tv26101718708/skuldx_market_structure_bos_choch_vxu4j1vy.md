# [SkuldX] Market Structure BOS & CHoCH

- url: https://www.tradingview.com/script/VxU4j1Vy-SkuldX-Market-Structure-BOS-CHoCH/
- type: indicator
- pine_id: PUB;611f77bd9e2442ecb3814bf9059bc04d
- version: 1.0

## Description

SkuldX Market Structure — BOS & CHoCH
by SkuldX Trading Systems

[b]What is it?[/b]
SkuldX Market Structure automatically maps the structural flow of price action by detecting Break of Structure and Change of Character events in real time. Instead of manually identifying swing highs and lows and drawing trend lines, the indicator does it for you — classifying every significant price move as either a trend continuation or a reversal signal, and labeling the market's structural state at every step.

[b]Core concepts[/b]
Market structure is the sequence of swing highs and swing lows that defines whether price is trending up, trending down, or transitioning between the two. Reading structure correctly is the foundation of ICT, Smart Money, and most institutional trading methodologies.
HH / HL / LH / LL — the four structural labels that appear at every confirmed swing point:
HH Higher High — price makes a new high above the previous swing high. Bullish continuation.
HL Higher Low — price makes a higher low before pushing up again. Confirms bullish structure.
LH Lower High — price fails to reach the previous high. First sign of bearish pressure.
LL Lower Low — price breaks below the previous swing low. Bearish continuation.

[b]BOS — Break of Structure[/b]
A BOS confirms that the existing trend is continuing. It fires when price breaks through the most recent swing extreme in the direction of the current trend.
BOS ▲ — price closes above the last swing high in an already bullish market. Institutions are adding to longs. The trend is intact and likely to continue.
BOS ▼ — price closes below the last swing low in an already bearish market. Sellers remain in control. The trend is intact.
BOS signals are ideal for trend-following entries — entering after a confirmed pullback when the BOS confirms trend resumption.

[b]CHoCH — Change of Character[/b]
A CHoCH signals a potential trend reversal. It fires when price breaks through the swing extreme in the opposite direction of the current trend — the first structural evidence that the dominant side is losing control.
CHoCH ▲ — price breaks above a swing high while the market was in a bearish structure. Buyers have stepped in with enough force to break the bearish sequence. A new bullish trend may be beginning.
CHoCH ▼ — price breaks below a swing low while the market was in a bullish structure. Sellers have overwhelmed the existing uptrend. A new bearish trend may be starting.
CHoCH is not a guarantee of reversal — it is the first structural signal that conditions are changing. It becomes high probability when combined with additional confluence such as a key S&R level, an SFP, or an OI signal.

[b]Two detection modes[/b]
Close mode — signals fire as soon as price closes beyond the structural level. Faster, more responsive, better for intraday trading on 15m and lower. May produce slightly more signals.
Pivot mode — signals fire only when a confirmed pivot point (N bars on each side) breaks the previous pivot extreme. Slower but structurally cleaner. Better for higher timeframes where false breaks are filtered naturally by requiring full confirmation.
Both modes can be used simultaneously on different chart instances for a multi-perspective view.

[b]What you see on the chart[/b]
HH / HL / LH / LL labels — appear at every confirmed pivot point showing whether each swing is making higher or lower extremes. Reading the sequence of these labels from left to right tells the full structural story of price action.
BOS / CHoCH labels — appear at the bar where the structural break occurs. Color-coded by direction and type — green for bullish BOS, red for bearish BOS, aqua for bullish CHoCH, orange for bearish CHoCH.
Dashed line — extends from the broken structural level to the right, marking the exact price that was breached. This level often acts as support or resistance on subsequent retests.
Zone box — shaded area between the broken level and the current close. Shows the range of the structural break — wider boxes indicate more decisive moves, tighter boxes indicate marginal breaks that deserve extra scrutiny.
Structure background — a very subtle background tint showing the current structural state across the chart. Green tint for bullish structure, red tint for bearish. Immediately visible even when zoomed out.

[b]Settings reference[/b]
Pivot Lookback — how many bars on each side a swing point must be the extreme to qualify as a pivot. Default 5. Lower values find more frequent swings, higher values require more significant structure. On 15m charts, 5 bars covers approximately 1.25 hours.
Detection Mode — Close for faster signals, Pivot for confirmed structure only
Show BOS — toggle Break of Structure signals
Bullish / Bearish BOS Color — independent color control
Show CHoCH — toggle Change of Character signals
Bullish / Bearish CHoCH Color — independent color control
Show Zone Box — toggle the shaded zone between level and close
Show Labels — toggle BOS/CHoCH text labels
Show HH/HL/LH/LL — toggle structural pivot labels
Show Structure Background — toggle the subtle trend tint
Box Transparency — opacity of the zone fill
Line Width — thickness of the broken level line
Label Size — tiny, small, or normal
Zone Extend — how many bars right the zone and line extend

[b]How to use it in practice[/b]
Reading the sequence — scan the HH/HL/LH/LL labels from left to right before looking at any signals. A clear sequence of HH → HL → HH → HL tells you the market is in a clean bullish structure. Any interruption of that sequence is a warning.
BOS as entry confirmation — after a pullback in a trending market, wait for a BOS in the direction of the trend. This confirms the pullback is over and the original direction is resuming. Enter at the close of the BOS candle with a stop below the previous HL for longs.
CHoCH as reversal alert — when a CHoCH appears, switch your bias. Do not immediately enter against the trend — wait for the new structure to develop. Ideally wait for the first BOS in the new direction after the CHoCH to confirm the reversal is gaining momentum.
Combining BOS and CHoCH — the most powerful setups occur when a CHoCH is followed by a BOS in the same new direction. CHoCH establishes the reversal intent. The subsequent BOS confirms it. Enter on the BOS, stop below the CHoCH swing low for longs.
Timeframe selection — on 15m and 1h the indicator works well for intraday structure. On 4h and daily it maps the larger swing structure that defines the week's directional bias. Running both simultaneously — 4h for bias, 15m for entry — is a common and effective approach.

[b]Part of the SkuldX Suite[/b]
SkuldX Market Structure integrates naturally with the full SkuldX indicator suite:
[list]
[*]A bullish CHoCH that coincides with a bullish SFP at a key S&R level from SkuldX SFP + Auto S&R is one of the strongest reversal confluences available — structure is changing and institutional players have swept liquidity at the same time
[*]A BOS that fires while price is between the VAL and POC zone confirms trend resumption from a high-value area
[*]A bearish CHoCH during the London+NY Overlap session with Bearish Trend OI Delta from SkuldX OI Delta signals institutional repositioning with full structural and flow confirmation
[*]The Structure Background tint aligns with the London Bias logic in SkuldX session strategies — bullish structure during London session = continuation long bias, bearish structure = short bias
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © skuldxtrade

//@version=6
indicator("[SkuldX] Market Structure — BOS & CHoCH", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)


// ══════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════

pivotLen       = input.int(5,  "Pivot Lookback (bars each side)", group = "Detection", minval = 2, maxval = 50)
detectionMode  = input.string("Close", "Detection Mode",          group = "Detection", options = ["Close", "Pivot"])

showBOS        = input.bool(true, "Show BOS",   group = "BOS")
colorBOSBull   = input.color(color.new(color.green,  0), "Bullish BOS",  group = "BOS")
colorBOSBear   = input.color(color.new(color.red,    0), "Bearish BOS",  group = "BOS")

showCHoCH      = input.bool(true, "Show CHoCH", group = "CHoCH")
colorCHoCHBull = input.color(color.new(color.aqua,   0), "Bullish CHoCH", group = "CHoCH")
colorCHoCHBear = input.color(color.new(color.orange, 0), "Bearish CHoCH", group = "CHoCH")

showBox        = input.bool(true,  "Show Zone Box",           group = "Display")
showLabel      = input.bool(true,  "Show Labels",             group = "Display")
showStructure  = input.bool(true,  "Show HH/HL/LH/LL",       group = "Display")
showBG         = input.bool(true,  "Show Structure Background", group = "Display")
boxAlpha       = input.int(90,     "Box Transparency",        group = "Display", minval = 50, maxval = 99)
lineWidth      = input.int(1,      "Line Width",              group = "Display", minval = 1, maxval = 4)
labelSize      = input.string("small", "Label Size",          group = "Display", options = ["tiny", "small", "normal"])
zoneExtend     = input.int(5,      "Zone Extend (bars)",      group = "Display", minval = 1, maxval = 30)


// ══════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════

szVal() =>
    switch labelSize
        "tiny"   => size.tiny
        "normal" => size.normal
        =>          size.small


// ══════════════════════════════════════════════════════
// PIVOT DETECTION
// ══════════════════════════════════════════════════════

float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low,  pivotLen, pivotLen)


// ══════════════════════════════════════════════════════
// SWING TRACKING
// Stores last two confirmed swing highs and lows
// Used to detect BOS and CHoCH
// ══════════════════════════════════════════════════════

var float swingHigh1    = na  // most recent swing high
var float swingHigh2    = na  // previous swing high
var int   swingHigh1Bar = na
var int   swingHigh2Bar = na

var float swingLow1     = na  // most recent swing low
var float swingLow2     = na  // previous swing low
var int   swingLow1Bar  = na
var int   swingLow2Bar  = na

var int   structureState = 0  // 1=bull -1=bear 0=undefined

// Update swing highs on new pivot high
if not na(ph)
    swingHigh2    := swingHigh1
    swingHigh2Bar := swingHigh1Bar
    swingHigh1    := ph
    swingHigh1Bar := bar_index - pivotLen

    // HH or LH label
    if showStructure and not na(swingHigh2)
        bool isHH     = ph > swingHigh2
        string lbl    = isHH ? "HH" : "LH"
        color  clr    = isHH ? colorBOSBull : colorBOSBear
        label.new(bar_index - pivotLen, ph, lbl,
             style     = label.style_label_down,
             color     = color.new(clr, 60),
             textcolor = clr,
             size      = size.tiny)

// Update swing lows on new pivot low
if not na(pl)
    swingLow2    := swingLow1
    swingLow2Bar := swingLow1Bar
    swingLow1    := pl
    swingLow1Bar := bar_index - pivotLen

    // LL or HL label
    if showStructure and not na(swingLow2)
        bool isLL     = pl < swingLow2
        string lbl    = isLL ? "LL" : "HL"
        color  clr    = isLL ? colorBOSBear : colorBOSBull
        label.new(bar_index - pivotLen, pl, lbl,
             style     = label.style_label_up,
             color     = color.new(clr, 60),
             textcolor = clr,
             size      = size.tiny)


// ══════════════════════════════════════════════════════
// BOS / CHoCH DETECTION
//
// Close mode:
//   Bullish: close crosses above swingHigh1
//   Bearish: close crosses below swingLow1
//
// Pivot mode:
//   Bullish: new pivot high > swingHigh2 (previous high)
//   Bearish: new pivot low  < swingLow2  (previous low)
// ══════════════════════════════════════════════════════

bool bullBreak = false
bool bearBreak = false
float breakLevel = na
int   breakBar   = na

if detectionMode == "Close"
    // Bullish break: close crosses above last swing high
    if not na(swingHigh1) and close > swingHigh1 and close[1] <= swingHigh1
        bullBreak  := true
        breakLevel := swingHigh1
        breakBar   := swingHigh1Bar

    // Bearish break: close crosses below last swing low
    if not na(swingLow1) and close < swingLow1 and close[1] >= swingLow1
        bearBreak  := true
        breakLevel := swingLow1
        breakBar   := swingLow1Bar

else  // Pivot mode
    // Bullish break: new pivot high exceeds previous pivot high
    if not na(ph) and not na(swingHigh2) and ph > swingHigh2
        bullBreak  := true
        breakLevel := swingHigh2
        breakBar   := swingHigh2Bar

    // Bearish break: new pivot low below previous pivot low
    if not na(pl) and not na(swingLow2) and pl < swingLow2
        bearBreak  := true
        breakLevel := swingLow2
        breakBar   := swingLow2Bar

// Classify as BOS or CHoCH based on current structure
bool bullishBOS   = bullBreak and structureState == 1
bool bearishBOS   = bearBreak and structureState == -1
bool bullishCHoCH = bullBreak and structureState == -1
bool bearishCHoCH = bearBreak and structureState == 1
bool bullishInit  = bullBreak and structureState == 0
bool bearishInit  = bearBreak and structureState == 0

// Update structure state
if bullBreak
    structureState := 1
if bearBreak
    structureState := -1


// ══════════════════════════════════════════════════════
// VISUALIZATION
// ══════════════════════════════════════════════════════

drawSignal(bool isBull, bool isBOS, float level, int levelBar) =>
    color clr   = isBOS ?
         (isBull ? colorBOSBull   : colorBOSBear) :
         (isBull ? colorCHoCHBull : colorCHoCHBear)
    string lbl  = isBOS ?
         (isBull ? "BOS ▲" : "BOS ▼") :
         (isBull ? "CHoCH ▲" : "CHoCH ▼")

    // Line from broken level to current bar
    if not na(level) and not na(levelBar)
        line.new(
             x1    = levelBar,
             y1    = level,
             x2    = bar_index + zoneExtend,
             y2    = level,
             color = color.new(clr, 20),
             width = lineWidth,
             style = line.style_dashed)

    // Zone box
    if showBox
        float boxTop = isBull ? close  : level
        float boxBot = isBull ? level  : close
        if boxTop > boxBot
            box.new(
                 left         = bar_index,
                 top          = boxTop,
                 right        = bar_index + zoneExtend,
                 bottom       = boxBot,
                 bgcolor      = color.new(clr, boxAlpha),
                 border_color = color.new(clr, 40),
                 border_width = 1)

    // Label
    if showLabel
        label.new(
             x         = bar_index,
             y         = isBull ? high : low,
             text      = lbl,
             style     = isBull ? label.style_label_up : label.style_label_down,
             color     = color.new(clr, 20),
             textcolor = color.white,
             size      = szVal())

// BOS signals
if showBOS
    if bullishBOS or bullishInit
        drawSignal(true,  true, breakLevel, breakBar)
    if bearishBOS or bearishInit
        drawSignal(false, true, breakLevel, breakBar)

// CHoCH signals
if showCHoCH
    if bullishCHoCH
        drawSignal(true,  false, breakLevel, breakBar)
    if bearishCHoCH
        drawSignal(false, false, breakLevel, breakBar)


// ══════════════════════════════════════════════════════
// STRUCTURE BACKGROUND
// ══════════════════════════════════════════════════════

bgcolor(showBG and structureState == 1  ? color.new(colorBOSBull, 97) :
        showBG and structureState == -1 ? color.new(colorBOSBear, 97) : na,
        title = "Structure Background")


// ══════════════════════════════════════════════════════
// DATA WINDOW
// ══════════════════════════════════════════════════════

plot(float(structureState), "Structure (1=Bull -1=Bear 0=Undef)",
     color = color.new(color.gray,   100), display = display.data_window)
plot(bullishBOS   ? 1.0 : 0.0, "Bullish BOS",   color = color.new(color.green,  100), display = display.data_window)
plot(bearishBOS   ? 1.0 : 0.0, "Bearish BOS",   color = color.new(color.red,    100), display = display.data_window)
plot(bullishCHoCH ? 1.0 : 0.0, "Bullish CHoCH", color = color.new(color.aqua,   100), display = display.data_window)
plot(bearishCHoCH ? 1.0 : 0.0, "Bearish CHoCH", color = color.new(color.orange, 100), display = display.data_window)
plot(swingHigh1,               "Swing High",    color = color.new(color.green,  100), display = display.data_window)
plot(swingLow1,                "Swing Low",     color = color.new(color.red,    100), display = display.data_window)
````
