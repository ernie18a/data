# GTS5.alvin - BOS/ChoCH 

- url: https://www.tradingview.com/script/3INa0MS2-GTS5-alvin-BOS-ChoCH/
- type: indicator
- pine_id: PUB;8ec3b75e5e2f4989b7ae0a6fbfea566a
- version: 1.0

## Description

💥 Smart Market Structure • Break of Structure • Change of Character • Swing Intelligence

🚀 [b]What This Indicator Does[/b]

The [b]GTS5.alvin - BOS/ChoCH[/b] is a precision market structure tracker that automatically identifies:

📈 Higher Highs (HH) & Higher Lows (HL)
📉 Lower Highs (LH) & Lower Lows (LL)
⚡ Breaks of Structure (BOS)
🔄 Change of Character (ChoCH)
🧭 Real-time market bias shifts
📊 Key swing levels with automatic breakout detection

This is not a basic structure tool.

This is a clean, execution-grade market intelligence system designed to show you what price is actually doing — not what you think it’s doing.


🧬 [b]Why This Indicator Hits Different[/b]

Most traders lose because they are:

Trading random highs/lows
Guessing trend direction
Entering before structure confirms
Reacting emotionally instead of structurally

This tool fixes that.

It builds a clean narrative of the market:

“Where is structure forming?”
“Where did it break?”
“Was that continuation… or reversal?”

Now you always know.

⚔️ [b]Core Features[/b]
🧱 True Market Structure Detection


[b]MUST use a 11-candle swing model (5 left / pivot / 5 right) to accurately define:[/b]

[list]
[*]Swing highs
[*]Swing lows
[*]Market structure shifts
[/list]

No noisy micro-swings. Only meaningful structure.


🔥 [b]BOS & ChoCH Engine[/b]

[b]Automatically distinguishes:[/b]

💥 [b]BOS (Break of Structure) [/b]→ continuation trend behavior
🔁 [b]ChoCH (Change of Character)[/b] → potential reversal zones

Color-coded and labeled directly on chart for instant clarity.


🧭 [b]Bias Tracking (Hidden Edge)[/b]

The script continuously tracks directional bias:

Bullish (1)
Bearish (-1)
Neutral (0)

This allows perfect classification of:

Trend continuation vs reversal breaks
LH/HL vs HH/LL behavior shifts


📊 [b]Smart Swing Labels[/b]

Auto-labels:

HH / HL → bullish structure
LH / LL → bearish structure

Minimal chart clutter. Maximum meaning.


📍 [b]Break Level Mapping[/b]

Every structural break includes:

Horizontal level projection
Mid-level BOS/ChoCH label
Break candle marker tag

You don’t just see the break —
you see exactly where it came from.


⚡ [b]Wick or Close Break Logic[/b]

Choose how structure is validated:

Close-based confirmation (cleaner, stricter)
Wick-based detection (faster, aggressive)

Perfect for scalpers or swing traders.


🔔 [b]Advanced Alert System[/b]

Built-in alerts for:

Bullish Breaks
Bearish Breaks
HH → BOS continuation events
LL → BOS continuation events
New Higher Highs
New Lower Lows

This turns your chart into a semi-automated signal radar.


🧠 [b]How Traders Use It[/b]

📈 [b]Trend Following[/b]

Wait for:

BOS in direction of bias
Then ride continuation after HH/HL confirmation


🔄 [b]Reversal Detection[/b]

Look for:

ChoCH after strong HH/HL or LL/LH sequence
Bias flip + structure break alignment


⚡ [b]Smart Entries[/b]

Combine:

Swing structure
Break levels
ChoCH confirmation

To enter with institutional-style timing instead of retail guessing


🧩 [b]What Makes It Different From Other Structure Tools[/b]

Most indicators:
❌ Show messy swings
❌ Don’t distinguish BOS vs ChoCH properly
❌ Don’t track bias
❌ Overload charts with noise

This one:
✔ Clean structure logic
✔ Context-aware labeling
✔ Bias-driven classification
✔ Minimal but powerful visuals
✔ Designed for real execution decisions


🎯 [b]Ideal For[/b]

Smart Money Concept traders (SMC)
Price action traders
ICT-style traders
Scalpers & intraday traders
Swing traders needing structure confirmation


⚡[b] Final Thought[/b]

If you don’t know where structure broke…

You’re not trading.

You’re guessing.

This indicator turns chaos into a readable market story:

Structure → Break → Confirmation → Bias → Opportunity

No noise. No confusion. Just clarity.

=======================
NOTE FROM THE CREATOR: 
=======================

Combine this indicator with the [b]GTS5.alvin - HMA Tracker 2.0[/b] then use the following strategy to help better your trading edge:

[list=1]
[*]Wait for a BOS of a HH/LL
[*]Then immediately check to see if the expansion/strength meter measures 50%+ 
[/list]

If so, consider entering the trade with the momentum. (If the meter measures less than 50% then consider waiting for another setup.)

Take profit: Once expansion/strength meter falls back to 50% then consider exiting trade.
Stop Loss: Consider placing behind HH/LL market structure swing.

---------------------------------
[i][b]Disclaimer: This is ONLY for educational purposes only! This indicator will NOT print you money. My success does NOT guarantee your success. I have EXTENSIVE EXPERTISE IN MARKET MANIPULATIONS! Use at your own discretion.[/b][/i]

## Source Code

````pine
//@version=5
indicator("GTS 5.alvin - BOS/ChoCH ", overlay=true, max_labels_count=500, max_lines_count=500)

// TRUE 5-candle swing → 2 left + pivot + 2 right
swingSide        = input.int(2, "Swing Strength (bars each side)", minval=1)

useCloseBreak    = input.bool(true, "Break Uses Close (else Wick)")
showSwings       = input.bool(true, "Show HH/HL/LH/LL Labels")
showBreaks       = input.bool(true, "Show BOS/ChoCH")
showLevels       = input.bool(true, "Draw Break Level Lines")

showTinyTag      = input.bool(true, "Show Tiny Tag On Break Candle")
showBigLineLabel = input.bool(true, "Show Big Label Near Level Line")

lblSizeOpt       = input.string("Tiny", "Label Size", options=["Tiny","Small","Normal"])
bigOffsetTicks   = input.int(12, "Big Label Offset (ticks)")
tinyOffsetTicks  = input.int(6, "Tiny Tag Offset (ticks)")

txtSwingBull     = input.color(color.lime, "Swing Bull Color (HH/HL)")
txtSwingBear     = input.color(color.red, "Swing Bear Color (LH/LL)")

colBosBull       = input.color(color.lime, "BOS Bull Color")
colBosBear       = input.color(color.red, "BOS Bear Color")
colChoch         = input.color(color.orange, "ChoCH Color")

colLevelBull     = input.color(color.new(color.lime, 0), "Level Line Bull")
colLevelBear     = input.color(color.new(color.red, 0), "Level Line Bear")
levelWidth       = input.int(1, "Level Line Width")

_ls = lblSizeOpt == "Tiny" ? size.tiny : lblSizeOpt == "Small" ? size.small : size.normal

tick    = syminfo.mintick
offBig  = bigOffsetTicks * tick
offTiny = tinyOffsetTicks * tick

// Pivot detection
ph = ta.pivothigh(high, swingSide, swingSide)
pl = ta.pivotlow(low, swingSide, swingSide)

pivotHighBar = bar_index - swingSide
pivotLowBar  = bar_index - swingSide

var float prevHigh = na
var float prevLow  = na

var float lastHigh = na
var int   lastHighBar = na
var float lastLow  = na
var int   lastLowBar = na

var bool highBroken = false
var bool lowBroken  = false
var int bias = 0

// Store swing classifications
var string lastHighClass = ""
var string lastLowClass  = ""

// HH / LH
if not na(ph)
    lastHigh := ph
    lastHighBar := pivotHighBar
    highBroken := false
    string t = na(prevHigh) ? "HH" : ph > prevHigh ? "HH" : "LH"
    lastHighClass := t
    color c = t == "HH" ? txtSwingBull : txtSwingBear
    if showSwings
        label.new(lastHighBar, lastHigh, t, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, textcolor=c, color=color.new(color.black, 100), size=_ls)
    prevHigh := ph

// HL / LL
if not na(pl)
    lastLow := pl
    lastLowBar := pivotLowBar
    lowBroken := false
    string t = na(prevLow) ? "HL" : pl > prevLow ? "HL" : "LL"
    lastLowClass := t
    color c = t == "HL" ? txtSwingBull : txtSwingBear
    if showSwings
        label.new(lastLowBar, lastLow, t, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, textcolor=c, color=color.new(color.black, 100), size=_ls)
    prevLow := pl

// Break detection
breakHigh = not na(lastHigh) and not highBroken and bar_index > lastHighBar and (useCloseBreak ? close > lastHigh : high > lastHigh)
breakLow  = not na(lastLow)  and not lowBroken  and bar_index > lastLowBar  and (useCloseBreak ? close < lastLow  : low < lastLow)

bodyTop = math.max(open, close)
bodyBot = math.min(open, close)

f_big(bool isChoch) => isChoch ? "ChoCH" : "BOS"
f_small(bool isChoch) => isChoch ? "choch" : "bos"

// Bullish break
if showBreaks and breakHigh
    bool isChoch = bias == -1
    color col = isChoch ? colChoch : colBosBull

    if showLevels
        line.new(lastHighBar, lastHigh, bar_index, lastHigh, xloc=xloc.bar_index, color=colLevelBull, width=levelWidth)

    if showBigLineLabel
        label.new(math.round((lastHighBar + bar_index) / 2), lastHigh + offBig, f_big(isChoch), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, textcolor=col, color=color.new(color.black, 80), size=_ls)

    if showTinyTag
        label.new(bar_index, bodyTop + offTiny, f_small(isChoch), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, textcolor=col, color=color.new(color.black, 85), size=size.tiny)

    highBroken := true
    bias := 1

// Bearish break
if showBreaks and breakLow
    bool isChoch = bias == 1
    color col = isChoch ? colChoch : colBosBear

    if showLevels
        line.new(lastLowBar, lastLow, bar_index, lastLow, xloc=xloc.bar_index, color=colLevelBear, width=levelWidth)

    if showBigLineLabel
        label.new(math.round((lastLowBar + bar_index) / 2), lastLow - offBig, f_big(isChoch), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, textcolor=col, color=color.new(color.black, 80), size=_ls)

    if showTinyTag
        label.new(bar_index, bodyBot - offTiny, f_small(isChoch), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, textcolor=col, color=color.new(color.black, 85), size=size.tiny)

    lowBroken := true
    bias := -1

// Base Alerts
alertcondition(breakHigh and showBreaks, "Bullish Break", "Bullish structure break on {{ticker}} {{interval}}")
alertcondition(breakLow and showBreaks, "Bearish Break", "Bearish structure break on {{ticker}} {{interval}}")

// LH/HL BOS Alerts (BOS only, not ChoCH)
bullBosFromLH = showBreaks and breakHigh and bias == 1 and lastHighClass == "LH"
bearBosFromHL = showBreaks and breakLow  and bias == -1 and lastLowClass  == "HL"
alertcondition(bullBosFromLH, "BOS Above LH (LH→BOS)", "BOS above a Lower High (LH→BOS) on {{ticker}} {{interval}}")
alertcondition(bearBosFromHL, "BOS Below HL (HL→BOS)", "BOS below a Higher Low (HL→BOS) on {{ticker}} {{interval}}")

// ✅ NEW: HH/LL BOS Alerts (BOS only, not ChoCH)
bullBosFromHH = showBreaks and breakHigh and bias == 1 and lastHighClass == "HH"
bearBosFromLL = showBreaks and breakLow  and bias == -1 and lastLowClass  == "LL"
alertcondition(bullBosFromHH, "BOS Above HH (HH→BOS)", "BOS above a Higher High (HH→BOS) on {{ticker}} {{interval}}")
alertcondition(bearBosFromLL, "BOS Below LL (LL→BOS)", "BOS below a Lower Low (LL→BOS) on {{ticker}} {{interval}}")
// HH / LL Alerts
newHH = not na(ph) and lastHighClass == "HH"
newLL = not na(pl) and lastLowClass == "LL"

alertcondition(newHH, "New Higher High", "New Higher High formed on {{ticker}} {{interval}}")
alertcondition(newLL, "New Lower Low", "New Lower Low formed on {{ticker}} {{interval}}")
````
