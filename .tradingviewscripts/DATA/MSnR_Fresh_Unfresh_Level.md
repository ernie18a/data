<!-- tradingview-pine-id: PUB;31997ede1e914e09a3fd25d26bb168df -->
<!-- tradingviewscripts-format: 1 -->
# MSnR Fresh & Unfresh Level

Source: https://www.tradingview.com/script/J4VA7UpR-MSnR-Fresh-Unfresh-Level/

## Description

MSnR Fresh & Unfresh Level

This script tracks the real-time strength of support and resistance levels by assigning them one of two states: Fresh or Unfresh.

Every new level—whether it is an A Level, V Level, Bullish Gap, or Bearish Gap—starts its life in the strongest possible state: Fresh. As price action continues and interacts with these levels, their state changes based on exactly how price reacts to them. This provides an ongoing read of a level's current structural importance.

WHAT MAKES THIS DIFFERENT

1. Dynamic state tracking.

Most tools draw a line and leave it there forever. This indicator constantly monitors price interaction with every level. If a level is touched and rejected, its state updates. If it is broken, its state updates again. The chart always shows what the level means right now, not what it meant when it was created.

2. Breakouts revive old levels.

A level that has been tested multiple times doesn't just die. If price finally closes through it, breaking out to the other side, that level flips its role (support becomes resistance, or vice versa) and becomes Fresh all over again.

3. Clear visual distinction.

The two states are instantly recognizable through color coding. Fresh levels are displayed in deep green, while Unfresh levels are displayed in deep red. You don't need to guess whether a zone has been tested; the color tells you at a glance.

4. Built on market structure.

Levels are not arbitrary lines. They are built precisely from A Levels, V Levels, Bullish Gaps, and Bearish Gaps, using the closes as the level prices. This anchors everything in actual market agreement rather than just wicks.

THE TWO STATES

Fresh
The strongest state a level can be in. A level is Fresh under two conditions:
- When it is newly created. It has not yet been touched or tested on its current side.
- When it undergoes a breakout. If price closes through an existing level, the level flips to the opposite side and becomes Fresh again, because it is entirely untested in its new role.

Unfresh
A level that has been tested but still holds. A level becomes Unfresh when price comes back to it, touches it with a wick (High or Low), and gets rejected without closing through it. This means the market has reacted to the level at least once. While still a valid reference point, it is structurally weaker than a Fresh level.

HOW A LEVEL CHANGES STATE

Every level is continuously re-evaluated against new price action. The state transitions work like this:

Rejection -> Unfresh
For a resistance level (A Level, Bearish Gap), if the High touches the level but the Close stays below it, the level has been rejected and becomes Unfresh.
For a support level (V Level, Bullish Gap), if the Low touches the level but the Close stays above it, the level has been rejected and becomes Unfresh.

Breakout -> Fresh (and Flip)
For a resistance level, if price Closes above it, this is a breakout. The level flips to become support and becomes Fresh again.
For a support level, if price Closes below it, this is a breakout. The level flips to become resistance and becomes Fresh again.

Breakouts always take priority. If a single candle touches a level and then closes through it, that is a breakout, not a rejection. A single level can toggle back and forth between Fresh and Unfresh many times as it gets rejected, broken, rejected again, and broken again.

READING THE CHART

The visual language is straightforward:
- Green line and green label: The level is currently Fresh.
- Red line and red label: The level is currently Unfresh.

Both the line and the label update their color automatically when a level changes state. Lines extend forward from the point the level was created, and the label sits at the origin. You can easily spot clusters of Fresh levels or areas where multiple Unfresh levels indicate heavy previous testing.

SETTINGS

Scan
- Scan Length (closed candles): how many closed candles are scanned backwards. Every level inside that window is monitored and drawn.

Display
- Show Fresh Levels: Toggle visibility of levels currently in the Fresh state.
- Show Unfresh Levels: Toggle visibility of levels currently in the Unfresh state.
- Show Text Labels: Toggle the text labels on the levels.

Style
- Fresh Level Line Color: The color of the line for levels currently in the Fresh state.
- Unfresh Level Line Color: The color of the line for levels currently in the Unfresh state.
- Label Offset (ticks): How far the label sits above or below the level. This is measured in ticks, so adjust it depending on the asset you are trading.
- Label Size: The size of the text labels drawn at each level.

ALERTS

Three alert conditions are available: Fresh Created, Fresh -> Unfresh, and Unfresh -> Fresh.

Each message carries the event type, the symbol, the timeframe and the closing price. The same messages are also sent through the alert function, so the "Any alert() function call" alert type can deliver everything through a single alert.

All alerts are evaluated only after a candle has fully closed.

REPAINTING

This script does not repaint.

- Detection reads confirmed candles only. The scan starts one bar behind the latest bar, so the candle that is still forming is never part of any calculation.
- Alert signals can only become true once a candle has finished. Price moving inside an open candle cannot make a signal appear and then disappear.
- Levels are rebuilt on the last bar from confirmed history. A level's price never moves. Its state can change, but only forward and only when a candle CLOSES through it or rejects from it. Once drawn, nothing shifts backwards.

When you create an alert, TradingView may show a caution banner saying the indicator can repaint. That banner appears automatically for any script that uses the built in bar state variables, no matter how they are used, because the platform cannot check the intent behind them. This script uses them for the opposite purpose: one of them is what restricts every signal to bar close, and the other is what redraws the levels efficiently on the final bar. Choosing "Once Per Bar Close" when creating the alert is still recommended.

NOTES AND LIMITATIONS

- This chart can become dense. Since every candle pair forms a level, a wide scan window will produce many levels. If you want fewer lines, lower the Scan Length.
- TradingView caps drawings at 500 lines and 500 labels. A very long Scan Length will hit that ceiling and the oldest drawings will be dropped. The default is chosen to stay well inside it.
- The label offset is measured in ticks, and a tick is worth a very different amount on a crypto pair than on a forex pair. Expect to adjust it when you move between symbols.
- Level prices come from closes, so a level can sit in the middle of a long wick. That is deliberate, not a bug.
- The same level can toggle between Fresh and Unfresh multiple times. This is the intended behavior reflecting the ongoing story of market structure.

HOW TO USE IT

Use the states to gauge the strength of support and resistance zones. Fresh levels represent untouched, maximum-strength zones, making them ideal areas to watch for initial reactions. Unfresh levels indicate areas where price has already struggled, showing proven but potentially weakening support or resistance.

When multiple Fresh levels cluster together, it signals a highly confluent, untested zone. Breakouts that convert a cluster of old levels into Fresh levels in the opposite direction can signal significant structural shifts.

These are structural references, not automatic entry signals. Use them alongside higher timeframe context, and apply your own confirmation and risk management.

DISCLAIMER

This indicator is a level detection tool. It is not financial advice and it makes no claim about profitability. Trading involves risk. Always apply your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator("MSnR Fresh & Unfresh Level", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================ SETTINGS ============================
groupScan  = "Scan"
candleLen  = input.int(20, "Scan Length (closed candles)", tooltip="Number of closed candles to scan backwards.", minval=5, maxval=100, group=groupScan)

groupDisp  = "Display"
showFresh   = input.bool(true, "Show Fresh Levels",   group=groupDisp)
showUnfresh = input.bool(true, "Show Unfresh Levels", group=groupDisp)
showText    = input.bool(true, "Show Text Labels",    group=groupDisp)

groupStyle = "Style"
freshLineColor   = input.color(color.rgb(16, 122, 52),  "Fresh Level Line Color",   group=groupStyle)
unfreshLineColor = input.color(color.rgb(178, 34, 34),  "Unfresh Level Line Color", group=groupStyle)
labelOffsetTicks = input.int(30, "Label Offset (ticks)", minval=1, group=groupStyle)
labelSizeStr     = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=groupStyle)

labelSize = labelSizeStr == "Tiny" ? size.tiny : labelSizeStr == "Small" ? size.small : labelSizeStr == "Large" ? size.large : size.normal

maxLevelsKeep = input.int(200, "Max Levels To Keep", minval=10, maxval=500)

// ============================ COLORS (same style) ============================
deepRed   = color.rgb(178, 34, 34)
deepGreen = color.rgb(16, 122, 52)
whiteTxt  = color.white

// Precision/tick safety
touchTol = syminfo.mintick * 0.5

f_roundToTick(float x) =>
    math.round(x / syminfo.mintick) * syminfo.mintick

// ============================ TYPES ============================
enum LvlType
    A
    V
    BullGap
    BearGap

f_isUpperType(LvlType t) =>
    t == LvlType.A or t == LvlType.BearGap

// Text above/below rule (like your existing script):
// A + Bearish Gap => above
// V + Bullish Gap => below
f_isAbove(LvlType t) =>
    t == LvlType.A or t == LvlType.BearGap

f_isBelow(LvlType t) =>
    t == LvlType.V or t == LvlType.BullGap

// Label text for Fresh/Unfresh
f_textFor(bool isFresh) =>
    isFresh ? "Fresh Level" : "Unfresh Level"

// Background color per state
f_stateBg(bool isFresh) =>
    isFresh ? deepGreen : deepRed

// ============================ SIDE-AWARE LOGIC ============================
// sideRes = true  => Resistance mode
// sideRes = false => Support mode
f_touch(bool sideRes, float levelPrice) =>
    sideRes ? (high >= levelPrice - touchTol) : (low <= levelPrice + touchTol)

f_breakout(bool sideRes, float levelPrice) =>
    sideRes ? (close > levelPrice) : (close < levelPrice)

f_rejection(bool sideRes, float levelPrice) =>
    bool touched = f_touch(sideRes, levelPrice)
    sideRes ? (touched and close < levelPrice) : (touched and close > levelPrice)

// ============================ STORAGE ============================
var arr_type    = array.new<LvlType>()
var arr_price   = array.new<float>()
var arr_fresh   = array.new<bool>()
var arr_created = array.new<int>()
var arr_sideRes = array.new<bool>()      // true=Resistance, false=Support
var arr_line    = array.new<line>()
var arr_label   = array.new<label>()

f_deleteAt(int i) =>
    line  ln = array.get(arr_line, i)
    label lb = array.get(arr_label, i)
    if not na(ln)
        line.delete(ln)
    if not na(lb)
        label.delete(lb)

    array.remove(arr_type, i)
    array.remove(arr_price, i)
    array.remove(arr_fresh, i)
    array.remove(arr_created, i)
    array.remove(arr_sideRes, i)
    array.remove(arr_line, i)
    array.remove(arr_label, i)

// Candle Length based on created bar only
f_cleanupStrict() =>
    int sz = array.size(arr_created)
    if sz > 0
        for i = sz - 1 to 0
            int createdIdx = array.get(arr_created, i)
            if bar_index - createdIdx > candleLen
                f_deleteAt(i)

    while array.size(arr_created) > maxLevelsKeep
        f_deleteAt(0)

f_makeLine(float price, bool isFresh) =>
    line.new(
        x1=bar_index - 1, y1=price,
        x2=bar_index,     y2=price,
        extend=extend.right,
        color=isFresh ? freshLineColor : unfreshLineColor, width=1
    )

f_makeLabelAtStart(LvlType t, float price, bool isFresh, int xStart) =>
    float offsetY = syminfo.mintick * labelOffsetTicks
    float y = price + (f_isAbove(t) ? offsetY : 0) - (f_isBelow(t) ? offsetY : 0)

    label.new(
        x=xStart,
        y=y,
        xloc=xloc.bar_index,
        yloc=yloc.price,
        style=label.style_label_center,
        text=f_textFor(isFresh),
        textcolor=whiteTxt,
        size=labelSize,
        color=f_stateBg(isFresh)
    )

f_createLevel(LvlType t, float priceRaw) =>
    float price = f_roundToTick(priceRaw)

    // Initial side:
    // A/BearGap => Resistance, V/BullGap => Support
    bool initRes = f_isUpperType(t)

    int originBar = bar_index - 1  // level price comes from close[1]

    line  ln = f_makeLine(price, true)
    label lb = na
    if showText
        lb := f_makeLabelAtStart(t, price, true, originBar)  // created = Fresh

    array.push(arr_type, t)
    array.push(arr_price, price)
    array.push(arr_fresh, true)
    array.push(arr_created, originBar)
    array.push(arr_sideRes, initRes)
    array.push(arr_line, ln)
    array.push(arr_label, lb)

// Keep label fixed at start (xStart), update text/color only
f_syncVisual(int i) =>
    LvlType t      = array.get(arr_type, i)
    float   price  = array.get(arr_price, i)
    bool    fresh  = array.get(arr_fresh, i)
    int     xStart = array.get(arr_created, i)
    line    ln     = array.get(arr_line, i)
    label   lb     = array.get(arr_label, i)

    bool shouldShow = (fresh and showFresh) or ((not fresh) and showUnfresh)

    if not na(ln)
        color lineCol = fresh ? freshLineColor : unfreshLineColor
        line.set_color(ln, shouldShow ? lineCol : color.new(lineCol, 100))

    if showText and shouldShow
        float offsetY = syminfo.mintick * labelOffsetTicks
        float y = price + (f_isAbove(t) ? offsetY : 0) - (f_isBelow(t) ? offsetY : 0)

        if na(lb)
            lb := label.new(
                x=xStart, y=y, xloc=xloc.bar_index, yloc=yloc.price,
                style=label.style_label_center,
                text=f_textFor(fresh),
                textcolor=whiteTxt,
                size=labelSize,
                color=f_stateBg(fresh)
            )
            array.set(arr_label, i, lb)
        else
            label.set_x(lb, xStart)
            label.set_y(lb, y)
            label.set_style(lb, label.style_label_center)
            label.set_text(lb, f_textFor(fresh))
            label.set_color(lb, f_stateBg(fresh))
            label.set_textcolor(lb, whiteTxt)
            label.set_size(lb, labelSize)
    else
        if not na(lb)
            label.delete(lb)
            array.set(arr_label, i, na)

// ============================ PATTERNS (2 closed candles) ============================
// Level price = close[1]
isGreen1 = close[1] > open[1]
isRed1   = close[1] < open[1]
isGreen0 = close > open
isRed0   = close < open

newA       = isGreen1 and isRed0
newV       = isRed1 and isGreen0
newBullGap = isGreen1 and isGreen0
newBearGap = isRed1 and isRed0

// ============================ ALERT FLAGS ============================
var bool al_freshCreated = false
var bool al_toUnfresh    = false
var bool al_toFresh      = false

al_freshCreated := false
al_toUnfresh    := false
al_toFresh      := false

// ============================ MAIN (closed candle only) ============================
if barstate.isconfirmed and bar_index >= 1
    f_cleanupStrict()

    float lvlPrice = close[1]

    // Create levels (always Fresh on creation)
    if newA
        f_createLevel(LvlType.A, lvlPrice), al_freshCreated := true
    if newV
        f_createLevel(LvlType.V, lvlPrice), al_freshCreated := true
    if newBullGap
        f_createLevel(LvlType.BullGap, lvlPrice), al_freshCreated := true
    if newBearGap
        f_createLevel(LvlType.BearGap, lvlPrice), al_freshCreated := true

    // Update states (continuous)
    int n = array.size(arr_price)
    if n > 0
        for i = 0 to n - 1
            int createdIdx = array.get(arr_created, i)

            // Do not update on the bar where the pattern completed
            if createdIdx == bar_index - 1
                f_syncVisual(i)
            else
                float level   = array.get(arr_price, i)
                bool  wasFr   = array.get(arr_fresh, i)
                bool  sideRes = array.get(arr_sideRes, i)

                bool breakout = f_breakout(sideRes, level)
                bool reject   = (not breakout) and f_rejection(sideRes, level)

                // Breakout => Fresh + flip side
                if breakout
                    array.set(arr_fresh, i, true)
                    array.set(arr_sideRes, i, not sideRes)
                    if not wasFr
                        al_toFresh := true

                // Rejection => Unfresh (only if currently Fresh)
                else if reject
                    if wasFr
                        array.set(arr_fresh, i, false)
                        al_toUnfresh := true

                f_syncVisual(i)

// ============================ ALERTS ============================
alertMsg(string tag) =>
    tag + " | " + syminfo.ticker + " " + timeframe.period + " | Close " + str.tostring(close, format.mintick)

if barstate.isconfirmed
    if al_freshCreated
        alert(alertMsg("Fresh Created"), alert.freq_once_per_bar_close)
    if al_toUnfresh
        alert(alertMsg("Fresh -> Unfresh"), alert.freq_once_per_bar_close)
    if al_toFresh
        alert(alertMsg("Unfresh -> Fresh"), alert.freq_once_per_bar_close)

alertcondition(al_freshCreated, title="Fresh Created",    message="Fresh Created | {{ticker}} {{interval}} | {{close}}")
alertcondition(al_toUnfresh,    title="Fresh -> Unfresh", message="Fresh -> Unfresh | {{ticker}} {{interval}} | {{close}}")
alertcondition(al_toFresh,      title="Unfresh -> Fresh", message="Unfresh -> Fresh | {{ticker}} {{interval}} | {{close}}")
````
