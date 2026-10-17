# ICT Order Block

- url: https://www.tradingview.com/script/HVcKIE8w-ICT-Order-Block/
- type: indicator
- pine_id: PUB;3a0701dcdf8247eda7724e88f0ea3e0a
- version: 1.0

## Description

[b]OVERVIEW[/b]

ICT Order Block marks the last opposite candle before a strong, one-sided move. A bullish order block is the last down candle before a strong up candle, and a bearish order block is the last up candle before a strong down candle. The block is drawn as a box that extends to the right, and it is faded once price has traded back into it. Optional filters and a breaker block option are included.


[b]HOW IT WORKS[/b]

A displacement is a candle whose body is at least a chosen multiple of the average true range. When a bullish displacement appears, the indicator looks back for the last bearish candle before it and draws its range as a bullish order block. A bearish displacement is the mirror. The block can be built from several consecutive candles of the same direction. Optional filters accept a block only if the displacement also left a fair value gap, only if a break of structure or a change of character occurred just before it, or mark it weak if most candles after it are inside bars or dojis. Optional body refinement draws a second, filled box from body to body. A block is mitigated the first time price trades into it, measured on the close or on the wick, and is then faded or hidden. A block that price breaks through can be turned into a breaker block, the same box in the opposite direction. Blocks are tracked for a chosen number of bars.


[image]62xFZjQI[/image]
[i]Order blocks drawn as shaded boxes extended to the right on a 4h Bitcoin chart.[/i]


[b]WHAT YOU'LL SEE ON THE CHART[/b]

[list]
[*][b]Order blocks[/b] — shaded boxes extended to the right, in the bullish or bearish colour, labelled OB.
[*][b]Body boxes[/b] — with refinement on, a dashed outer box wick to wick and a filled inner box body to body.
[*][b]Faded blocks[/b] — mitigated or weak blocks shown faded, or hidden.
[*][b]Breaker blocks[/b] — boxes with dashed borders for blocks that price broke through.
[*][b]Dashboard[/b] — a small table with the count of active bullish and bearish blocks.
[/list]

[image]OXJRFoJj[/image]
[i]The same indicator on a 4h Ethereum chart, with two bearish blocks above price.[/i]


[b]BEST FOR[/b]

This indicator draws and labels price structure rather than reporting a single event type, so no market or timeframe group is singled out. It was not measured, and it reads the candles of whatever chart it is placed on.


[b]ALERTS[/b]

[list]
[*]Bullish Displacement
[*]Bearish Displacement
[*]Bullish OB Mitigated
[*]Bearish OB Mitigated
[*]Bullish Breaker Formed
[*]Bearish Breaker Formed
[/list]


[b]LIMITATIONS[/b]

The script reads the candles of the chart it is placed on, so results on non-standard chart types differ from results on regular candles. Swing points are known only after the chosen number of bars has passed, so swing-based items appear with that delay. It is a drawing and labelling tool, not a forecast. It is weaker in these situations:

[list]
[*]Quiet markets with few strong candles, where few blocks form
[*]Very strong trends, where many blocks form in a row
[*]Breaker blocks, which form mainly when a single bar passes right through a block, since a block counts as mitigated the first time price enters it
[*]Soft confirmation, which needs the midpoint touch and the exit in the same bar to complete
[/list]


[b]OPEN SOURCE[/b]

The source code is open. This script is one module of the author's own larger ICT toolkit, published here on its own so it can be read, checked and reused under the Mozilla Public License 2.0.


[b]ACCESS[/b]

Free, open-source script.


[b]DISCLAIMER[/b]

[i]This indicator is a technical analysis tool, not investment advice. The author is not a registered investment adviser, broker or dealer. Nothing here is a recommendation to buy, sell or hold any instrument. What you see on the chart is the output of a calculation you configured. Any decision you take from it is yours. Past behaviour of an indicator — including anything you observe in historical bars or in a backtest, which is a simulation — does not indicate future results. Trading carries a real risk of loss, including your entire capital. Charting uses TradingView® technology. TradingView is unaffiliated with the author. For educational purposes only. Not investment advice.[/i]

## Source Code

````pine
// Split from the author's own "ICT Smart Money Toolkit" (all modules in one script).
// ═══════════════════════════════════════════════════════════════
//  ICT Order Block
//  v1.0.0 · 2026-10-05
//  Open source, Mozilla Public License 2.0
//
//  Measures : Order blocks, the last opposing candle before a displacement,
//             tracked until price trades into them, and the breaker blocks
//             they turn into.
//  Not      : This is not investment advice.
// ═══════════════════════════════════════════════════════════════
//@version=6
indicator("ICT Order Block", shorttitle="ICT OB", overlay=true, behind_chart=false, max_bars_back=300, max_boxes_count=500, max_labels_count=500)
// max_bars_back=300 — Pine's own default; deepest explicit history: the order block search and the structural window (up to 15 bars).
// max_boxes_count / max_labels_count declared because this script draws box, label objects; the source declared 500 for all three.

// ── THEME ─────────────────────────────────────────────────────
// [§3.1] design tokens — do not edit per-indicator.
C_UP       = #26A69A
C_DOWN     = #EF5350
C_NEUTRAL  = #787B86
C_ACCENT   = #F0B90B
C_INFO     = #2962FF
C_TEXT     = #D1D4DC
C_TEXT_DIM = #787B86
C_BG       = #131722
C_BORDER   = #2A2E39

// ── INPUTS ────────────────────────────────────────────────────
// [§4.1] Group names and their order are fixed. Unused groups are omitted.
G_CORE    = "◆━━━━━━━ Calculation ━━━━━━━◆"
G_FILTER  = "◆━━━━━━━ Filters ━━━━━━━◆"
G_VISUAL  = "◆━━━━━━━ Appearance ━━━━━━━◆"
G_TABLE   = "◆━━━━━━━ Dashboard ━━━━━━━◆"

i_showOB         = input.bool(true, "Show Order Blocks", group = G_CORE, tooltip = "Detects and draws order blocks: the last opposite candle before a displacement move.")
i_obLookback     = input.int(50, "Lookback (Bars)", minval = 10, maxval = 200, group = G_CORE, tooltip = "How many bars an order block stays tracked before it is removed.")
i_obBreakMode    = input.string("Bar Close", "Break Detection Mode", options = ["Bar Close", "Wick (High/Low)"], group = G_CORE, tooltip = "Whether a mitigation or a break of an order block is measured on the candle close or on the wick.")
i_obMaxShow      = input.int(5, "Max Order Blocks", minval = 1, maxval = 20, group = G_CORE, tooltip = "Half of the active order blocks kept on the chart: both sides together hold up to twice this number and the oldest are removed first.")
i_obMultiCandle  = input.bool(false, "Use Multi-Candle OB", group = G_CORE, tooltip = "Builds the block from consecutive same-direction candles instead of a single candle.")
i_obMultiMax     = input.int(3, "Max Candles In Zone", minval = 2, maxval = 5, group = G_CORE, tooltip = "Most consecutive candles merged into one block.")
i_dispMultiplier = input.float(1.5, "Displacement Multiplier (ATR)", minval = 1.0, maxval = 5.0, step = 0.1, group = G_CORE, tooltip = "Minimum candle body, in multiples of ATR, for a candle to count as a displacement.")
i_dispATRLen     = input.int(14, "ATR Length", minval = 5, maxval = 50, group = G_CORE, tooltip = "Length of the ATR used as the volatility reference.")
i_showBB         = input.bool(true, "Show Breaker Blocks", group = G_FILTER, tooltip = "Turns a broken order block into a breaker block instead of removing it.")
i_obIMBFilter    = input.bool(false, "Use IMB Confirmation", group = G_FILTER, tooltip = "Only accepts an order block when the displacement candle also leaves a fair value gap.")
i_obSoftConfirm  = input.bool(false, "Use Soft Confirmation", group = G_FILTER, tooltip = "Marks a new order block as unconfirmed until price touches its midpoint and then leaves it in the trend direction.")
i_obStructural   = input.bool(false, "Use Structural OB", group = G_FILTER, tooltip = "Only accepts an order block when a BOS or CHoCH occurred inside the structural window.")
i_obStructWindow = input.int(5, "Structural Window (Bars)", minval = 1, maxval = 15, group = G_FILTER, tooltip = "How many bars back from the displacement a BOS or CHoCH is searched for.")
i_swingLen       = input.int(5, "Swing Sensitivity", minval = 2, maxval = 50, group = G_FILTER, tooltip = "Bars required on each side of a pivot for it to count as a swing. Only the structure used by this indicator reads it.")
i_obRefinement   = input.bool(false, "Use Body Refinement", group = G_FILTER, tooltip = "Draws two boxes per block: a dashed wick-to-wick outer box and a filled body-to-body entry box. Mitigation is measured on the body box.")
i_obIndecision   = input.bool(false, "Use Indecision Filter", group = G_FILTER, tooltip = "Inspects the candles after the block; if most are inside bars or dojis the block is marked weak.")
i_obIndLen       = input.int(3, "Candles To Check", minval = 2, maxval = 5, group = G_FILTER, tooltip = "How many candles after the block are inspected.")
i_obIndMin       = input.int(2, "Min Indecision Count", minval = 1, maxval = 4, group = G_FILTER, tooltip = "Number of inside or doji candles that makes a block weak.")
i_obDojiRatio    = input.float(20.0, "Doji Threshold (%)", minval = 5.0, maxval = 40.0, step = 5.0, group = G_FILTER, tooltip = "A candle is a doji when its body is below this percentage of its range.")
i_obMitigated    = input.string("Fade", "Mitigated OB", options = ["Fade", "Hide"], group = G_VISUAL, tooltip = "What happens to an order block after price has traded into it.")
i_obIndAction    = input.string("Fade", "Weak OB Action", options = ["Fade", "Hide"], group = G_VISUAL, tooltip = "What happens to blocks the indecision filter marks as weak.")

i_colUp     = input.color(C_UP, "Bullish Color", group = G_VISUAL, tooltip = "Colour of bullish order blocks and bullish breaker blocks.")
i_colDown   = input.color(C_DOWN, "Bearish Color", group = G_VISUAL, tooltip = "Colour of bearish order blocks and bearish breaker blocks.")

i_showTable      = input.bool(true, "Show Dashboard", group = G_TABLE, tooltip = "Shows the summary table on the chart.")
i_tablePos       = input.string("Top Right", "Dashboard Position", options = ["Top Left", "Bottom Left", "Top Right", "Bottom Right"], group = G_TABLE, tooltip = "Corner of the chart where the dashboard is placed.")

// ── CALC ──────────────────────────────────────────────────────
f_getPosition(posStr) =>
    switch posStr
        "Top Left" => position.top_left
        "Bottom Left" => position.bottom_left
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right

// Swing pivots. A pivot is known i_swingLen bars after it formed.
pivotHigh    = ta.pivothigh(high, i_swingLen, i_swingLen)
pivotLow     = ta.pivotlow(low, i_swingLen, i_swingLen)
pivotHighBar = bar_index - i_swingLen
pivotLowBar  = bar_index - i_swingLen

atrValue = ta.atr(i_dispATRLen)

// Displacement: candle body larger than a multiple of ATR (aggressive institutional entry).
bullishDisplacement = (close - open) > (atrValue * i_dispMultiplier) and close > open
bearishDisplacement = (open - close) > (atrValue * i_dispMultiplier) and close < open

// IMB confirmation: displacement candle is bar[1]; the gap is between bar[2] high and bar[0] low.
bullDispHasIMB = bullishDisplacement[1] and (low > high[2])
bearDispHasIMB = bearishDisplacement[1] and (low[2] > high)

// ── STATE / SIGNAL ────────────────────────────────────────────
// Signals are evaluated on every tick, as in the source script; they are not gated with barstate.isconfirmed.
// An intrabar event can therefore appear and disappear on the open bar. See the notes in identity.yaml.

// ── swing state ──
var float s_lastSwingHigh     = na
var int   s_lastSwingHighBar  = na
var float s_lastSwingLow      = na
var int   s_lastSwingLowBar   = na
var float s_prevSwingHigh     = na
var int   s_prevSwingHighBar  = na
var float s_prevSwingLow      = na
var int   s_prevSwingLowBar   = na
var string s_lastHighType     = ""    // HH or LH
var string s_lastLowType      = ""    // HL or LL
var int   s_lastSwingType     = 0     // 1 = last swing was a high, -1 = a low (swings alternate)

// Alternating swings: two highs in a row update the earlier one instead of creating a new swing.
bool swingHighConfirmed = false
bool swingLowConfirmed  = false

if not na(pivotHigh)
    if s_lastSwingType == 1
        highType = na(s_prevSwingHigh) ? "HH" : (pivotHigh > s_prevSwingHigh ? "HH" : "LH")
        s_lastSwingHigh    := pivotHigh
        s_lastSwingHighBar := pivotHighBar
        s_lastHighType     := highType
        swingHighConfirmed := true
    else
        highType = na(s_lastSwingHigh) ? "HH" : (pivotHigh > s_lastSwingHigh ? "HH" : "LH")
        s_prevSwingHigh    := s_lastSwingHigh
        s_prevSwingHighBar := s_lastSwingHighBar
        s_lastSwingHigh    := pivotHigh
        s_lastSwingHighBar := pivotHighBar
        s_lastHighType     := highType
        s_lastSwingType    := 1
        swingHighConfirmed := true

if not na(pivotLow)
    if s_lastSwingType == -1
        lowType = na(s_prevSwingLow) ? "HL" : (pivotLow > s_prevSwingLow ? "HL" : "LL")
        s_lastSwingLow    := pivotLow
        s_lastSwingLowBar := pivotLowBar
        s_lastLowType     := lowType
        swingLowConfirmed := true
    else
        lowType = na(s_lastSwingLow) ? "HL" : (pivotLow > s_lastSwingLow ? "HL" : "LL")
        s_prevSwingLow    := s_lastSwingLow
        s_prevSwingLowBar := s_lastSwingLowBar
        s_lastSwingLow    := pivotLow
        s_lastSwingLowBar := pivotLowBar
        s_lastLowType     := lowType
        s_lastSwingType   := -1
        swingLowConfirmed := true

// ── BOS / CHoCH ──
// Market bias: 1 bullish, -1 bearish, 0 undefined. A close through the last swing is a BOS when it
// follows the bias and a CHoCH when it goes against it. A swing level can only be broken once.
var int   s_marketBias     = 0
var bool  s_bosUp          = false
var bool  s_bosDn          = false
var bool  s_chochUp        = false
var bool  s_chochDn        = false
var float s_lastBrokenHigh = na
var float s_lastBrokenLow  = na

s_bosUp   := false
s_bosDn   := false
s_chochUp := false
s_chochDn := false

bullBreak = not na(s_lastSwingHigh) and (na(s_lastBrokenHigh) or s_lastSwingHigh != s_lastBrokenHigh) and close > s_lastSwingHigh and close[1] <= s_lastSwingHigh

if bullBreak
    if s_marketBias == 1 or s_marketBias == 0
        s_bosUp := true
        s_marketBias := 1
    else
        s_chochUp := true
        s_marketBias := 1
    s_lastBrokenHigh := s_lastSwingHigh

bearBreak = not na(s_lastSwingLow) and (na(s_lastBrokenLow) or s_lastSwingLow != s_lastBrokenLow) and close < s_lastSwingLow and close[1] >= s_lastSwingLow and not bullBreak

if bearBreak
    if s_marketBias == -1 or s_marketBias == 0
        s_bosDn := true
        s_marketBias := -1
    else
        s_chochDn := true
        s_marketBias := -1
    s_lastBrokenLow := s_lastSwingLow

// ── order blocks / breaker blocks ──
type OrderBlock
    int    startBar        // first bar of the block
    float  top             // wick-to-wick top
    float  bottom          // wick-to-wick bottom
    float  bodyTop         // body-to-body top (refinement)
    float  bodyBottom      // body-to-body bottom (refinement)
    int    direction       // 1 bullish, -1 bearish
    bool   isMitigated     // price traded into the block
    bool   isBreaker       // converted to a breaker block
    bool   isConfirmed     // soft confirmation completed
    bool   touchedMid      // soft confirmation step 1: midpoint touched
    float  midPoint        // block midpoint
    bool   isWeak          // indecision filter marked it weak
    int    indCheckBar     // bar on which the indecision check runs
    box    obBox           // main box (body box when refinement is on)
    box    obWickBox       // refinement: wick-to-wick outer box
    label  obLabel

var array<OrderBlock> s_activeOBs = array.new<OrderBlock>()

// Structural OB: a BOS or CHoCH inside the last N bars.
bool recentBullStructure = false
bool recentBearStructure = false
if i_obStructural
    for i = 0 to i_obStructWindow - 1
        if s_bosUp[i] == true or s_chochUp[i] == true
            recentBullStructure := true
            break
    for i = 0 to i_obStructWindow - 1
        if s_bosDn[i] == true or s_chochDn[i] == true
            recentBearStructure := true
            break
else
    recentBullStructure := true
    recentBearStructure := true

// Bullish OB: last bearish candle before a bullish displacement.
// IMB filter on: displacement is bar[1] with a gap, search starts at bar[2]; off: displacement is bar[0], search starts at bar[1].
bool bullOBBase = i_obIMBFilter ? bullDispHasIMB : bullishDisplacement
bullOBAllowed = bullOBBase and recentBullStructure

if bullOBAllowed and i_showOB
    int searchFrom = i_obIMBFilter ? 2 : 1
    int obBar = na
    float obTop = na
    float obBottom = na
    float obBodyTop = na
    float obBodyBot = na

    int firstFound = na
    for i = searchFrom to searchFrom + 4
        if close[i] < open[i]
            firstFound := i
            obBar      := bar_index - i
            obTop      := high[i]
            obBottom   := low[i]
            obBodyTop  := open[i]
            obBodyBot  := close[i]
            break

    if not na(firstFound) and i_obMultiCandle
        int extraCount = 0
        for j = firstFound + 1 to firstFound + i_obMultiMax - 1
            if close[j] < open[j]
                obBar     := bar_index - j
                obTop     := math.max(obTop, high[j])
                obBottom  := math.min(obBottom, low[j])
                obBodyTop := math.max(obBodyTop, open[j])
                obBodyBot := math.min(obBodyBot, close[j])
                extraCount += 1
            else
                break

    if not na(obBar)
        if not i_obRefinement
            obBodyTop := obTop
            obBodyBot := obBottom

        obMidY = (obBodyTop + obBodyBot) / 2.0
        bool initConfirmed = not i_obSoftConfirm

        color bullBoxBg    = i_obSoftConfirm ? color.new(i_colUp, 88) : color.new(i_colUp, 80)
        color bullBoxBdr   = i_obSoftConfirm ? color.new(i_colUp, 60) : color.new(i_colUp, 30)
        string bullLblText = i_obSoftConfirm ? "OB?" : "OB"

        obBoxRef = box.new(obBar, obBodyTop, bar_index + 5, obBodyBot, bgcolor = bullBoxBg, border_color = bullBoxBdr, border_width = 1, extend = extend.right)

        box wickBoxRef = na
        if i_obRefinement
            wickBoxRef := box.new(obBar, obTop, bar_index + 5, obBottom, bgcolor = color.new(i_colUp, 97), border_color = color.new(i_colUp, 50), border_width = 1, border_style = line.style_dashed, extend = extend.right)

        obLabelRef = label.new(obBar, obMidY, bullLblText, style = label.style_none, textcolor = i_colUp, size = size.small)

        int indCheckAt = i_obIndecision ? bar_index + i_obIndLen : na

        newOB = OrderBlock.new(obBar, obTop, obBottom, obBodyTop, obBodyBot, 1, false, false, initConfirmed, false, obMidY, false, indCheckAt, obBoxRef, wickBoxRef, obLabelRef)
        array.push(s_activeOBs, newOB)

// Bearish OB: last bullish candle before a bearish displacement.
bool bearOBBase = i_obIMBFilter ? bearDispHasIMB : bearishDisplacement
bearOBAllowed = bearOBBase and recentBearStructure

if bearOBAllowed and i_showOB
    int searchFrom = i_obIMBFilter ? 2 : 1
    int obBar = na
    float obTop = na
    float obBottom = na
    float obBodyTop = na
    float obBodyBot = na

    int firstFound = na
    for i = searchFrom to searchFrom + 4
        if close[i] > open[i]
            firstFound := i
            obBar      := bar_index - i
            obTop      := high[i]
            obBottom   := low[i]
            obBodyTop  := close[i]
            obBodyBot  := open[i]
            break

    if not na(firstFound) and i_obMultiCandle
        int extraCount = 0
        for j = firstFound + 1 to firstFound + i_obMultiMax - 1
            if close[j] > open[j]
                obBar     := bar_index - j
                obTop     := math.max(obTop, high[j])
                obBottom  := math.min(obBottom, low[j])
                obBodyTop := math.max(obBodyTop, close[j])
                obBodyBot := math.min(obBodyBot, open[j])
                extraCount += 1
            else
                break

    if not na(obBar)
        if not i_obRefinement
            obBodyTop := obTop
            obBodyBot := obBottom

        obMidY = (obBodyTop + obBodyBot) / 2.0
        bool initConfirmed = not i_obSoftConfirm

        color bearBoxBg    = i_obSoftConfirm ? color.new(i_colDown, 88) : color.new(i_colDown, 80)
        color bearBoxBdr   = i_obSoftConfirm ? color.new(i_colDown, 60) : color.new(i_colDown, 30)
        string bearLblText = i_obSoftConfirm ? "OB?" : "OB"

        obBoxRef = box.new(obBar, obBodyTop, bar_index + 5, obBodyBot, bgcolor = bearBoxBg, border_color = bearBoxBdr, border_width = 1, extend = extend.right)

        box wickBoxRef = na
        if i_obRefinement
            wickBoxRef := box.new(obBar, obTop, bar_index + 5, obBottom, bgcolor = color.new(i_colDown, 97), border_color = color.new(i_colDown, 50), border_width = 1, border_style = line.style_dashed, extend = extend.right)

        obLabelRef = label.new(obBar, obMidY, bearLblText, style = label.style_none, textcolor = i_colDown, size = size.small)

        int indCheckAt = i_obIndecision ? bar_index + i_obIndLen : na

        newOB = OrderBlock.new(obBar, obTop, obBottom, obBodyTop, obBodyBot, -1, false, false, initConfirmed, false, obMidY, false, indCheckAt, obBoxRef, wickBoxRef, obLabelRef)
        array.push(s_activeOBs, newOB)

// Mitigation and breaker conversion, checked on every bar for every tracked block.
var bool s_obMitigatedBull  = false
var bool s_obMitigatedBear  = false
var bool s_breakerFormedBull = false
var bool s_breakerFormedBear = false

s_obMitigatedBull   := false
s_obMitigatedBear   := false
s_breakerFormedBull := false
s_breakerFormedBear := false

bool useCloseBreak = i_obBreakMode == "Bar Close"
float breakHi = useCloseBreak ? close : high
float breakLo = useCloseBreak ? close : low

if array.size(s_activeOBs) > 0
    int removeCount = 0
    for i = array.size(s_activeOBs) - 1 to 0
        ob = array.get(s_activeOBs, i)

        if bar_index - ob.startBar > i_obLookback
            box.delete(ob.obBox)
            box.delete(ob.obWickBox)
            label.delete(ob.obLabel)
            array.remove(s_activeOBs, i)
            continue

        if ob.isMitigated
            continue

        // Indecision filter: runs once, i_obIndLen bars after the block formed.
        if i_obIndecision and not ob.isWeak and not na(ob.indCheckBar) and bar_index >= ob.indCheckBar
            int indecisionCount = 0
            for k = 1 to i_obIndLen
                float cRange = high[k] - low[k]
                float cBody  = math.abs(close[k] - open[k])
                bool isDoji = cRange > 0 and (cBody / cRange * 100.0) < i_obDojiRatio
                bool isInside = k < i_obIndLen ? (high[k] <= high[k + 1] and low[k] >= low[k + 1]) : false
                if isDoji or isInside
                    indecisionCount += 1
            if indecisionCount >= i_obIndMin
                ob.isWeak := true
                if i_obIndAction == "Hide"
                    box.delete(ob.obBox)
                    box.delete(ob.obWickBox)
                    label.delete(ob.obLabel)
                    array.remove(s_activeOBs, i)
                    continue
                else
                    if ob.direction == 1
                        box.set_bgcolor(ob.obBox, color.new(i_colUp, 93))
                        box.set_border_color(ob.obBox, color.new(i_colUp, 75))
                        label.set_text(ob.obLabel, "OB weak")
                    else
                        box.set_bgcolor(ob.obBox, color.new(i_colDown, 93))
                        box.set_border_color(ob.obBox, color.new(i_colDown, 75))
                        label.set_text(ob.obLabel, "OB weak")
            ob.indCheckBar := na

        // Soft confirmation: touch the midpoint, then leave the block in the trend direction.
        float scTop = i_obRefinement ? ob.bodyTop : ob.top
        float scBot = i_obRefinement ? ob.bodyBottom : ob.bottom
        if i_obSoftConfirm and not ob.isConfirmed
            if ob.direction == 1
                if not ob.touchedMid and low <= ob.midPoint
                    ob.touchedMid := true
                if ob.touchedMid and close > scTop
                    ob.isConfirmed := true
                    box.set_bgcolor(ob.obBox, color.new(i_colUp, 80))
                    box.set_border_color(ob.obBox, color.new(i_colUp, 30))
                    label.set_text(ob.obLabel, "OB conf")
            else
                if not ob.touchedMid and high >= ob.midPoint
                    ob.touchedMid := true
                if ob.touchedMid and close < scBot
                    ob.isConfirmed := true
                    box.set_bgcolor(ob.obBox, color.new(i_colDown, 80))
                    box.set_border_color(ob.obBox, color.new(i_colDown, 30))
                    label.set_text(ob.obLabel, "OB conf")

        // Mitigation is measured on the body box when refinement is on.
        float mitTop = i_obRefinement ? ob.bodyTop : ob.top
        float mitBot = i_obRefinement ? ob.bodyBottom : ob.bottom
        if ob.direction == 1
            if breakLo <= mitTop and breakLo >= mitBot
                ob.isMitigated := true
                s_obMitigatedBull := true

                if i_obMitigated == "Hide"
                    box.delete(ob.obBox)
                    box.delete(ob.obWickBox)
                    label.delete(ob.obLabel)
                    array.remove(s_activeOBs, i)
                    continue
                else
                    box.set_bgcolor(ob.obBox, color.new(i_colUp, 92))
                    box.set_border_color(ob.obBox, color.new(i_colUp, 80))
                    box.set_extend(ob.obBox, extend.none)
                    box.set_right(ob.obBox, bar_index)
                    if not na(ob.obWickBox)
                        box.set_extend(ob.obWickBox, extend.none)
                        box.set_right(ob.obWickBox, bar_index)
                    label.set_text(ob.obLabel, "OB mit")

            // Price broke fully below a bullish block: bearish breaker.
            if breakLo < ob.bottom and not ob.isBreaker
                ob.isBreaker := true
                ob.isMitigated := true
                s_breakerFormedBear := true

                if i_showBB
                    box.set_bgcolor(ob.obBox, color.new(i_colDown, 80))
                    box.set_border_color(ob.obBox, color.new(i_colDown, 30))
                    box.set_border_style(ob.obBox, line.style_dashed)
                    box.set_extend(ob.obBox, extend.right)
                    label.set_text(ob.obLabel, "BB")
                    label.set_textcolor(ob.obLabel, i_colDown)
                    box.delete(ob.obWickBox)
                else
                    box.delete(ob.obBox)
                    box.delete(ob.obWickBox)
                    label.delete(ob.obLabel)
                    array.remove(s_activeOBs, i)
                    continue

        if ob.direction == -1
            if breakHi >= mitBot and breakHi <= mitTop
                ob.isMitigated := true
                s_obMitigatedBear := true

                if i_obMitigated == "Hide"
                    box.delete(ob.obBox)
                    box.delete(ob.obWickBox)
                    label.delete(ob.obLabel)
                    array.remove(s_activeOBs, i)
                    continue
                else
                    box.set_bgcolor(ob.obBox, color.new(i_colDown, 92))
                    box.set_border_color(ob.obBox, color.new(i_colDown, 80))
                    box.set_extend(ob.obBox, extend.none)
                    box.set_right(ob.obBox, bar_index)
                    if not na(ob.obWickBox)
                        box.set_extend(ob.obWickBox, extend.none)
                        box.set_right(ob.obWickBox, bar_index)
                    label.set_text(ob.obLabel, "OB mit")

            // Price broke fully above a bearish block: bullish breaker.
            if breakHi > ob.top and not ob.isBreaker
                ob.isBreaker := true
                ob.isMitigated := true
                s_breakerFormedBull := true

                if i_showBB
                    box.set_bgcolor(ob.obBox, color.new(i_colUp, 80))
                    box.set_border_color(ob.obBox, color.new(i_colUp, 30))
                    box.set_border_style(ob.obBox, line.style_dashed)
                    box.set_extend(ob.obBox, extend.right)
                    label.set_text(ob.obLabel, "BB")
                    label.set_textcolor(ob.obLabel, i_colUp)
                    box.delete(ob.obWickBox)
                else
                    box.delete(ob.obBox)
                    box.delete(ob.obWickBox)
                    label.delete(ob.obLabel)
                    array.remove(s_activeOBs, i)
                    continue

while array.size(s_activeOBs) > i_obMaxShow * 2
    oldest = array.shift(s_activeOBs)
    box.delete(oldest.obBox)
    box.delete(oldest.obWickBox)
    label.delete(oldest.obLabel)

// ── PLOT ──────────────────────────────────────────────────────

// ── DASHBOARD ─────────────────────────────────────────────────
// Dashboard. Strings are built on the last bar only.
if barstate.islast and i_showTable
    var table s_dash = table.new(f_getPosition(i_tablePos), 3, 2, bgcolor = C_BG, border_width = 1, border_color = C_BORDER)
    table.cell(s_dash, 0, 0, "ICT Order Block", text_color = C_TEXT, text_size = size.small, bgcolor = C_BORDER)
    table.cell(s_dash, 1, 0, "", bgcolor = C_BORDER)
    table.cell(s_dash, 2, 0, timeframe.period, text_color = C_TEXT_DIM, text_size = size.small, bgcolor = C_BORDER)

    int bullOBCount = 0
    int bearOBCount = 0
    if array.size(s_activeOBs) > 0
        for i = 0 to array.size(s_activeOBs) - 1
            ob = array.get(s_activeOBs, i)
            if not ob.isMitigated
                if ob.direction == 1
                    bullOBCount += 1
                else
                    bearOBCount += 1

    table.cell(s_dash, 0, 1, "Order Block", text_color = C_TEXT, text_size = size.tiny)
    table.cell(s_dash, 1, 1, str.tostring(bullOBCount) + " Bull", text_color = i_colUp, text_size = size.tiny)
    table.cell(s_dash, 2, 1, str.tostring(bearOBCount) + " Bear", text_color = i_colDown, text_size = size.tiny)

// ── ALERTS ────────────────────────────────────────────────────
alertcondition(bullishDisplacement, title = "Bullish Displacement", message = "{{ticker}} {{interval}} - Bullish displacement: strong buying candle, a bullish order block may have formed.")
alertcondition(bearishDisplacement, title = "Bearish Displacement", message = "{{ticker}} {{interval}} - Bearish displacement: strong selling candle, a bearish order block may have formed.")
alertcondition(s_obMitigatedBull, title = "Bullish OB Mitigated", message = "{{ticker}} {{interval}} - Bullish order block mitigated: price traded back into it.")
alertcondition(s_obMitigatedBear, title = "Bearish OB Mitigated", message = "{{ticker}} {{interval}} - Bearish order block mitigated: price traded back into it.")
alertcondition(s_breakerFormedBull, title = "Bullish Breaker Formed", message = "{{ticker}} {{interval}} - A bearish order block was broken: bullish breaker block formed.")
alertcondition(s_breakerFormedBear, title = "Bearish Breaker Formed", message = "{{ticker}} {{interval}} - A bullish order block was broken: bearish breaker block formed.")
````
