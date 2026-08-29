<!-- tradingview-pine-id: PUB;8b6a92e7dc5045c09423b222345d0236 -->
<!-- tradingviewscripts-format: 1 -->
# MSnR CC Level [6 Types]

Source: https://www.tradingview.com/script/FNzQRXdb-MSnR-CC-Level-6-Types/

## Description

MSnR CC Level [6 Types]

This script detects and maps Confirmation Candle (CC) levels, a 3-candle confirmation structure that checks whether a previously created level gets touched and rejected by the latest closed candle while keeping directional continuation.

Rather than looking at single swing points, CC detection requires a specific three-part pattern to validate a level. The result is a complete structural map of confirmed rejections inside the scan window, with each of the six CC types drawn so it can be told apart at a glance.

WHAT MAKES THIS DIFFERENT

1. Complete structural confirmation, not just arbitrary levels.

Most level tools draw lines where price has simply turned around. This tool requires a strict 3-candle structural proof. A level must be established, tested, and actively rejected with continuation to be drawn on the chart.

2. Identifies six distinct CC structures.

The script distinguishes between A CC, V CC, Bullish Gap CC, Bearish Gap CC, SBR CC, and RBS CC. The type is visually indicated, so you know exactly what structure formed the level without having to check the candles manually.

3. SBR and RBS are one-shot dynamic flips.

When an established level is broken, the script immediately starts looking for the very next candle to act as the signal candle, confirming a Support Become Resistance (SBR) or Resistance Become Support (RBS) setup.

THE SIX CC TYPES

A candle is Green when close is greater than or equal to open (a Doji counts as Green) and Red when close is less than open. The running candle is never used.

For the first four types, a 3-candle sequence is evaluated:
- Candle 1 establishes the reference level (the close of the first candle).
- Candle 2 provides the middle structure.
- Candle 3 is the signal candle that must reject the level and maintain directional strength.

V CC (Bullish)
Red, Green, Green. The signal candle low touches the V level, the body remains above it, and its close is greater than or equal to the middle candle's close.

Bullish Gap CC
Green, Green, Green. Follows the same touch, body, and continuation rules as the V CC.

A CC (Bearish)
Green, Red, Red. The signal candle high touches the A level, the body remains below it, and its close is less than or equal to the middle candle's close.

Bearish Gap CC
Red, Red, Red. Follows the same touch, body, and continuation rules as the A CC.

For the broken levels:

SBR CC
When a support level breaks down, the very next candle must act as the signal candle. It must reject the freshly flipped level from below, satisfying the same touch, body, and continuation rules as a bearish CC.

RBS CC
When a resistance level breaks up, the very next candle must act as the signal candle. It must reject the freshly flipped level from above, satisfying the same touch, body, and continuation rules as a bullish CC.

READING THE CHART

Colour tells you the side:

- Red labels: bearish rejections. A CC, Bearish Gap CC, SBR CC.
- Green labels: bullish rejections. V CC, Bullish Gap CC, RBS CC.

Each CC level starts at the candle that created its structure and extends to the right. The labels sit cleanly at the right edge of the chart to keep the price action visible. If multiple CC levels form at the same price, their labels are merged into a single entry to keep the chart clean. Nearby labels are automatically staggered horizontally to avoid overlap.

SETTINGS

Scan
- Scan Length (closed candles): how many closed candles are scanned backwards from the latest bar. Every CC Level found inside this window is drawn. The running candle is always excluded.

Display
- An individual switch for each of the six CC types, plus a toggle for the text labels.

Style
- Level Line Color, Label Size, and spacing options. You can adjust the distance used to merge same-price labels, the gap before staggering, and the horizontal stagger step.

ALERTS

Six alert conditions are available: A CC, V CC, Bullish Gap CC, Bearish Gap CC, SBR CC and RBS CC.

Each message carries the level type, the symbol, the timeframe and the closing price. The same messages are also sent through the alert function, so the "Any alert() function call" alert type can deliver everything through a single alert.

All alerts are evaluated only after a candle has fully closed.

REPAINTING

This script does not repaint.

- Detection reads confirmed candles only. The scan starts one bar behind the latest bar, so the candle that is still forming is never part of any calculation.
- Alert signals can only become true once a candle has finished. Price moving inside an open candle cannot make a signal appear and then disappear.
- Levels are rebuilt on the last bar from confirmed history. A level's price never moves. Once drawn, nothing shifts backwards.

When you create an alert, TradingView may show a caution banner saying the indicator can repaint. That banner appears automatically for any script that uses the built in bar state variables, no matter how they are used, because the platform cannot check the intent behind them. This script uses them for the opposite purpose: one of them is what restricts every signal to bar close, and the other is what redraws the levels efficiently on the final bar. Choosing "Once Per Bar Close" when creating the alert is still recommended.

NOTES AND LIMITATIONS

- TradingView caps drawings at 500 lines and 500 labels. A very long Scan Length will hit that ceiling and the oldest drawings will be dropped.
- The label offset and merge gap are measured in ticks. Expect to adjust these settings when moving between symbols with different tick values.
- Detection is purely structural. It reports where valid CC patterns have formed. It does not measure what happened afterwards, or produce entries, targets or stops.

HOW TO USE IT

Use these CC levels to map where the market has shown confirmed structural rejection. Areas where multiple CC structures stack together often represent stronger zones of interest.

These are reference areas, not automated entry signals. Use them alongside higher timeframe structure, and apply your own confirmation and risk management.

DISCLAIMER

This indicator is a level detection tool. It is not financial advice and it makes no claim about profitability. Trading involves risk. Always apply your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator(
     title="MSnR CC Level [6 Types]",
     overlay=true,
     max_lines_count=500,
     max_labels_count=500,
     max_bars_back=5000
)

// ============================ SETTINGS ============================
groupScan  = "Scan"
candleLen  = input.int(50, "Scan Length (closed candles)", minval=5, group=groupScan, tooltip="How many closed candles are scanned backwards from the latest bar. Every CC Level found inside this window is drawn. The running candle is always excluded.")

groupDisp  = "Display"
showACC       = input.bool(true,  "A CC",             group=groupDisp)
showVCC       = input.bool(true,  "V CC",             group=groupDisp)
showBullGapCC = input.bool(true,  "Bullish Gap CC",   group=groupDisp)
showBearGapCC = input.bool(true,  "Bearish Gap CC",   group=groupDisp)
showSBRCC     = input.bool(true,  "SBR CC",           group=groupDisp)
showRBSCC     = input.bool(true,  "RBS CC",           group=groupDisp)
showLabels    = input.bool(true,  "Show Text Labels", group=groupDisp)

groupStyle = "Style"
levelColor    = input.color(color.new(color.rgb(37, 99, 235), 0), "Level Line Color", group=groupStyle) // blue
labelSizeStr  = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=groupStyle)
mergeTolTicks = input.int(2,  "Merge Same-Price Labels (ticks)", minval=0, group=groupStyle, tooltip="CC levels within this distance share one line and one combined label. Set 0 to disable merging.")
rowGapTicks   = input.int(60, "Label Row Gap (ticks)", minval=0, group=groupStyle, tooltip="Labels closer than this are staggered to the right instead of overlapping. Increase if labels still overlap on your symbol.")
staggerBars   = input.int(10, "Label Stagger (bars)", minval=1, group=groupStyle, tooltip="Horizontal step used when nearby labels are staggered.")

labelSize = labelSizeStr == "Tiny" ? size.tiny : labelSizeStr == "Small" ? size.small : labelSizeStr == "Large" ? size.large : size.normal

// ============================ CONSTANTS ============================
// CC types
var int TYPE_A_CC        = 0
var int TYPE_V_CC        = 1
var int TYPE_BULL_GAP_CC = 2
var int TYPE_BEAR_GAP_CC = 3
var int TYPE_SBR_CC      = 4
var int TYPE_RBS_CC      = 5

// Base level types (internal, only for SBR CC / RBS CC tracking)
var int BASE_A        = 0
var int BASE_V        = 1
var int BASE_BULL_GAP = 2
var int BASE_BEAR_GAP = 3

// Colors for labels
deepRed   = color.rgb(178, 34, 34)
deepGreen = color.rgb(16, 122, 52)
whiteTxt  = color.white

// ============================ UTILS ============================
// Pattern #34 local color rule: Green = close >= open (Doji counts as Green), Red = close < open
isGreen(int i) => close[i] >= open[i]
isRed(int i)   => close[i] < open[i]

// visibility based on type + toggles
f_type_visible(int t) =>
    bool vis = false
    if t == TYPE_A_CC
        vis := showACC
    else if t == TYPE_V_CC
        vis := showVCC
    else if t == TYPE_BULL_GAP_CC
        vis := showBullGapCC
    else if t == TYPE_BEAR_GAP_CC
        vis := showBearGapCC
    else if t == TYPE_SBR_CC
        vis := showSBRCC
    else if t == TYPE_RBS_CC
        vis := showRBSCC
    vis

f_label_text_for_type(int t) =>
    switch t
        TYPE_A_CC        => "A CC"
        TYPE_V_CC        => "V CC"
        TYPE_BULL_GAP_CC => "Bullish Gap CC"
        TYPE_BEAR_GAP_CC => "Bearish Gap CC"
        TYPE_SBR_CC      => "SBR CC"
        TYPE_RBS_CC      => "RBS CC"
        => ""

// label color helpers (Bearish CC = deep red, Bullish CC = deep green)
f_is_above_type(int t) =>
    t == TYPE_A_CC or t == TYPE_BEAR_GAP_CC or t == TYPE_SBR_CC

f_is_below_type(int t) =>
    t == TYPE_V_CC or t == TYPE_BULL_GAP_CC or t == TYPE_RBS_CC

// ============================ CC SIGNAL CONDITION HELPERS ============================
// Bullish side signal candle: low touches the level, body fully above, continuation up
// prevClose = close of the candle immediately before the signal (middle candle / breakout candle)
f_bull_signal_ok(int sigOff, float lvl, float prevClose) =>
    low[sigOff] <= lvl and math.min(open[sigOff], close[sigOff]) > lvl and close[sigOff] >= prevClose

// Bearish side signal candle: high touches the level, body fully below, continuation down
f_bear_signal_ok(int sigOff, float lvl, float prevClose) =>
    high[sigOff] >= lvl and math.max(open[sigOff], close[sigOff]) < lvl and close[sigOff] <= prevClose

// ============================ DRAW ARRAYS (last-bar redraw) ============================
var float[] ccPrices  = array.new_float()
var int[]   ccTypes   = array.new_int()
var int[]   ccOffsets = array.new_int()

var line[]  drawnLines  = array.new_line()
var label[] drawnLabels = array.new_label()

// ============================ ALERT STORAGE (bounded, bar-close only) ============================
// Base levels waiting for a possible SBR/RBS conversion
var float[] s_prices = array.new_float()
var int[]   s_types  = array.new_int()

// One-shot pending conversions (created on the Breakout Candle, checked ONLY on the very next bar)
var float[] p_prices     = array.new_float()
var bool[]  p_isSbr      = array.new_bool()
var float[] p_breakClose = array.new_float()

f_level_push(float p, int t) =>
    array.push(s_prices, p)
    array.push(s_types,  t)
    int cap = candleLen * 6
    while array.size(s_prices) > cap
        array.shift(s_prices)
        array.shift(s_types)

// ============================ ALERT SIGNALS (series bool) ============================
var bool alertNewACC       = false
var bool alertNewVCC       = false
var bool alertNewBullGapCC = false
var bool alertNewBearGapCC = false
var bool alertNewSBRCC     = false
var bool alertNewRBSCC     = false

alertNewACC       := false
alertNewVCC       := false
alertNewBullGapCC := false
alertNewBearGapCC := false
alertNewSBRCC     := false
alertNewRBSCC     := false

// ============================ ALERT LOGIC (bar-close only) ============================
if barstate.isconfirmed and bar_index >= 2
    // ---- Step 1: check one-shot pending SBR/RBS conversions from the previous bar
    // The current closed bar is the Signal Candle candidate (the VERY NEXT candle after the Breakout Candle)
    int nP = array.size(p_prices)
    if nP > 0
        for idx = 0 to nP - 1
            float p  = array.get(p_prices, idx)
            bool  sb = array.get(p_isSbr, idx)
            float bc = array.get(p_breakClose, idx)
            if sb and isRed(0) and high >= p and math.max(open, close) < p and close <= bc
                alertNewSBRCC := true
            if not sb and isGreen(0) and low <= p and math.min(open, close) > p and close >= bc
                alertNewRBSCC := true
    array.clear(p_prices)
    array.clear(p_isSbr)
    array.clear(p_breakClose)

    // ---- Step 2: trio CC checks on the last 3 closed candles [2],[1],[0]
    if isRed(2) and isGreen(1) and isGreen(0) and f_bull_signal_ok(0, close[2], close[1])
        alertNewVCC := true
    if isGreen(2) and isGreen(1) and isGreen(0) and f_bull_signal_ok(0, close[2], close[1])
        alertNewBullGapCC := true
    if isGreen(2) and isRed(1) and isRed(0) and f_bear_signal_ok(0, close[2], close[1])
        alertNewACC := true
    if isRed(2) and isRed(1) and isRed(0) and f_bear_signal_ok(0, close[2], close[1])
        alertNewBearGapCC := true

    // ---- Step 3: SBR/RBS conversions on this bar (this bar = Breakout Candle) -> pending for next bar
    int nS = array.size(s_prices)
    if nS > 0
        for idx = nS - 1 to 0
            float p = array.get(s_prices, idx)
            int   t = array.get(s_types,  idx)
            if (t == BASE_V or t == BASE_BULL_GAP) and isRed(0) and close < p
                array.push(p_prices, p)
                array.push(p_isSbr, true)
                array.push(p_breakClose, close)
                array.remove(s_prices, idx)
                array.remove(s_types, idx)
            else if (t == BASE_A or t == BASE_BEAR_GAP) and isGreen(0) and close > p
                array.push(p_prices, p)
                array.push(p_isSbr, false)
                array.push(p_breakClose, close)
                array.remove(s_prices, idx)
                array.remove(s_types, idx)

    // ---- Step 4: new base levels created on this bar (pair [1],[0]) - born on this bar, can convert later
    if isGreen(1) and isRed(0)
        f_level_push(close[1], BASE_A)
    if isRed(1) and isGreen(0)
        f_level_push(close[1], BASE_V)
    if isGreen(1) and isGreen(0)
        f_level_push(close[1], BASE_BULL_GAP)
    if isRed(1) and isRed(0)
        f_level_push(close[1], BASE_BEAR_GAP)

alertcondition(alertNewACC,       title="A CC",           message="A CC | {{ticker}} {{interval}} | {{close}}")
alertcondition(alertNewVCC,       title="V CC",           message="V CC | {{ticker}} {{interval}} | {{close}}")
alertcondition(alertNewBullGapCC, title="Bullish Gap CC", message="Bullish Gap CC | {{ticker}} {{interval}} | {{close}}")
alertcondition(alertNewBearGapCC, title="Bearish Gap CC", message="Bearish Gap CC | {{ticker}} {{interval}} | {{close}}")
alertcondition(alertNewSBRCC,     title="SBR CC",         message="SBR CC | {{ticker}} {{interval}} | {{close}}")
alertcondition(alertNewRBSCC,     title="RBS CC",         message="RBS CC | {{ticker}} {{interval}} | {{close}}")

alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Close " + str.tostring(close, format.mintick)

if barstate.isconfirmed
    if alertNewACC
        alert(alertMsg("A CC"), alert.freq_once_per_bar_close)
    if alertNewVCC
        alert(alertMsg("V CC"), alert.freq_once_per_bar_close)
    if alertNewBullGapCC
        alert(alertMsg("Bullish Gap CC"), alert.freq_once_per_bar_close)
    if alertNewBearGapCC
        alert(alertMsg("Bearish Gap CC"), alert.freq_once_per_bar_close)
    if alertNewSBRCC
        alert(alertMsg("SBR CC"), alert.freq_once_per_bar_close)
    if alertNewRBSCC
        alert(alertMsg("RBS CC"), alert.freq_once_per_bar_close)

// ============================ DRAWING (NON-REPAINT, LAST BAR ONLY) ============================
if barstate.islast
    array.clear(ccPrices)
    array.clear(ccTypes)
    array.clear(ccOffsets)

    int nL = array.size(drawnLines)
    if nL > 0
        for i = 0 to nL - 1
            line ln = array.get(drawnLines, i)
            if not na(ln)
                line.delete(ln)
        array.clear(drawnLines)

    int nLab = array.size(drawnLabels)
    if nLab > 0
        for i = 0 to nLab - 1
            label lb = array.get(drawnLabels, i)
            if not na(lb)
                label.delete(lb)
        array.clear(drawnLabels)

    int scanMax = math.min(candleLen, bar_index)

    // ---- Trio CC scan: creator = c, middle = c-1, signal = c-2 (signal must be a closed bar)
    if scanMax >= 3
        for c = scanMax to 3
            int c1 = c
            int c2 = c - 1
            int c3 = c - 2

            if isRed(c1) and isGreen(c2) and isGreen(c3) and f_bull_signal_ok(c3, close[c1], close[c2])
                array.push(ccPrices, close[c1])
                array.push(ccTypes, TYPE_V_CC)
                array.push(ccOffsets, c1)

            if isGreen(c1) and isGreen(c2) and isGreen(c3) and f_bull_signal_ok(c3, close[c1], close[c2])
                array.push(ccPrices, close[c1])
                array.push(ccTypes, TYPE_BULL_GAP_CC)
                array.push(ccOffsets, c1)

            if isGreen(c1) and isRed(c2) and isRed(c3) and f_bear_signal_ok(c3, close[c1], close[c2])
                array.push(ccPrices, close[c1])
                array.push(ccTypes, TYPE_A_CC)
                array.push(ccOffsets, c1)

            if isRed(c1) and isRed(c2) and isRed(c3) and f_bear_signal_ok(c3, close[c1], close[c2])
                array.push(ccPrices, close[c1])
                array.push(ccTypes, TYPE_BEAR_GAP_CC)
                array.push(ccOffsets, c1)

    // ---- SBR CC / RBS CC scan:
    // base pair level -> FIRST conversion (chronological, colored close-breakout) = Breakout Candle
    // -> the VERY NEXT candle must be the Signal Candle (one-shot)
    if scanMax >= 4
        for i = scanMax to 4
            int firstOff  = i
            int secondOff = i - 1
            float p = close[firstOff]

            bool baseSupport    = isGreen(secondOff)   // V (R->G) or Bullish Gap (G->G) -> support side
            bool baseResistance = isRed(secondOff)     // A (G->R) or Bearish Gap (R->R) -> resistance side

            for k = i - 2 to 1
                if baseSupport and isRed(k) and close[k] < p
                    int sigS = k - 1
                    if sigS >= 1
                        if isRed(sigS) and high[sigS] >= p and math.max(open[sigS], close[sigS]) < p and close[sigS] <= close[k]
                            array.push(ccPrices, p)
                            array.push(ccTypes, TYPE_SBR_CC)
                            array.push(ccOffsets, firstOff)
                    break
                if baseResistance and isGreen(k) and close[k] > p
                    int sigR = k - 1
                    if sigR >= 1
                        if isGreen(sigR) and low[sigR] <= p and math.min(open[sigR], close[sigR]) > p and close[sigR] >= close[k]
                            array.push(ccPrices, p)
                            array.push(ccTypes, TYPE_RBS_CC)
                            array.push(ccOffsets, firstOff)
                    break

    // ---- PROFESSIONAL VISUAL PASS ----
    // 1) merge same-price CC levels into ONE line + ONE combined label (newest wins)
    // 2) place all labels at the RIGHT of the last candle (candles stay clean)
    // 3) stagger nearby labels horizontally so they never overlap
    int nCC = array.size(ccPrices)
    if nCC > 0
        float tolMerge = syminfo.mintick * mergeTolTicks
        float rowGap   = syminfo.mintick * rowGapTicks

        // visual entries (deduped by price, newest first)
        float[]  eP   = array.new_float()
        string[] eTxt = array.new_string()
        color[]  eBg  = array.new_color()
        int[]    eOff = array.new_int()

        for idx = nCC - 1 to 0
            float price = array.get(ccPrices, idx)
            int   t     = array.get(ccTypes, idx)
            int   off   = array.get(ccOffsets, idx)

            if not f_type_visible(t)
                continue

            string txt = f_label_text_for_type(t)
            color  bg  = f_is_above_type(t) ? deepRed : deepGreen

            int found = -1
            int nE0 = array.size(eP)
            if nE0 > 0
                for j = 0 to nE0 - 1
                    if math.abs(array.get(eP, j) - price) <= tolMerge
                        found := j
                        break

            if found == -1
                array.push(eP, price)
                array.push(eTxt, txt)
                array.push(eBg, bg)
                array.push(eOff, off)
            else if not str.contains(array.get(eTxt, found), txt)
                array.set(eTxt, found, array.get(eTxt, found) + " + " + txt)

        int nE = array.size(eP)
        if nE > 0
            // one line per merged level, starting at its newest creator candle
            for j = 0 to nE - 1
                line ln = line.new(
                     x1=bar_index - array.get(eOff, j),
                     y1=array.get(eP, j),
                     x2=bar_index,
                     y2=array.get(eP, j),
                     xloc=xloc.bar_index,
                     extend=extend.right,
                     color=levelColor,
                     width=1
                )
                array.push(drawnLines, ln)

            if showLabels
                // sort entries by price (descending) for collision staggering
                int[] order = array.new_int()
                for j = 0 to nE - 1
                    array.push(order, j)
                if nE > 1
                    for a = 0 to nE - 2
                        int best = a
                        for b = a + 1 to nE - 1
                            if array.get(eP, array.get(order, b)) > array.get(eP, array.get(order, best))
                                best := b
                        if best != a
                            int tmpO = array.get(order, a)
                            array.set(order, a, array.get(order, best))
                            array.set(order, best, tmpO)

                float lastPlaced = na
                int   col = 0
                for a = 0 to nE - 1
                    int j2 = array.get(order, a)
                    float p2 = array.get(eP, j2)

                    // nearby label -> slide one column to the right
                    if not na(lastPlaced) and math.abs(lastPlaced - p2) < rowGap
                        col += 1
                    else
                        col := 0
                    lastPlaced := p2

                    int xLbl = bar_index + 3 + col * staggerBars
                    label lb = label.new(
                         x=xLbl,
                         y=p2,
                         xloc=xloc.bar_index,
                         yloc=yloc.price,
                         style=label.style_label_left,
                         text=array.get(eTxt, j2),
                         textcolor=whiteTxt,
                         size=labelSize,
                         color=array.get(eBg, j2)
                    )
                    array.push(drawnLabels, lb)
````
