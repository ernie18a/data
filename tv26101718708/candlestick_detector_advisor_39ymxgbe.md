# CandleStick Detector - Advisor

- url: https://www.tradingview.com/script/39YMxgbE-CandleStick-Detector-Advisor/
- type: indicator
- pine_id: PUB;81097c863b4f443caad4e1f737ce7532
- version: 1.0

## Description

MARKET ADVISOR — Candlestick Pattern Detection + Plain English Analysis

════════════════════════════════════════
WHAT THIS DOES
════════════════════════════════════════

Market Advisor reads price action in real time and explains what it sees in plain English — like having a trading friend beside you. Instead of showing 10 indicators and leaving you to figure it out, this script detects key candlestick formations, marks them on the chart, identifies the current trend structure, and tells you exactly what the pattern means in context.

No signals. No buy/sell arrows. No false promises.
Just honest pattern recognition and plain language analysis.

════════════════════════════════════════
HOW IT WORKS — THE LOGIC
════════════════════════════════════════

The script runs three engines simultaneously:

1. CANDLE MATH ENGINE
Every bar, the script calculates:
- Body size: math.abs(close - open)
- Full range: high - low
- Upper wick: high - max(close, open)
- Lower wick: min(close, open) - low
- Body percentage: bodySize / fullRange

These ratios are used to classify candle formations without ambiguity.

2. PATTERN DETECTION ENGINE
Eight patterns are detected using strict mathematical conditions:

- Bullish Engulfing: Current bar is bullish, previous was bearish, current body fully covers previous body, current body is larger.

- Bearish Engulfing: Opposite of above. Current bar is bearish, fully covers previous bullish body.

- Hammer: Lower wick is at least 2x the body size. Upper wick is less than 0.5x body. Body percentage under 45%. Shows price was pushed down then rejected.

- Shooting Star: Upper wick is at least 2x body. Lower wick under 0.5x body. Body percentage under 45%. Shows price was pushed up then rejected.

- Doji: Body percentage under 8% of the full range. Buyers and sellers ended equal.

- Inside Bar: Current high is below previous high AND current low is above previous low. Price is compressing inside the prior candle.

- Morning Star: 3-bar pattern. Bar 2 ago is bearish. Middle bar (1 ago) has a tiny body (under 25% of range). Current bar is bullish and closes above the midpoint of bar 2.

- Evening Star: 3-bar pattern. Bar 2 ago is bullish. Middle bar has tiny body. Current bar is bearish and closes below midpoint of bar 2.

3. MARKET STRUCTURE ENGINE
Uses pivot highs and lows (ta.pivothigh / ta.pivotlow) to identify:
- Uptrend: Current pivot high > previous pivot high AND current pivot low > previous pivot low (Higher Highs, Higher Lows)
- Downtrend: Current pivot high < previous pivot high AND current pivot low < previous pivot low (Lower Highs, Lower Lows)
- Ranging: Neither condition met

The structure context changes the advisor text. A Hammer in an uptrend gets different advice than a Hammer in a downtrend. Same pattern, different meaning.

════════════════════════════════════════
WHAT APPEARS ON CHART
════════════════════════════════════════

- Engulfing patterns → shaded box spanning both candles
- Hammers / Shooting Stars → small label above or below the candle
- Inside Bars → golden shaded box covering both candles
- Doji → small label
- Morning / Evening Star → label on the third candle
- Swing levels → dotted horizontal lines at pivot highs and lows

════════════════════════════════════════
THE ADVISOR PANEL
════════════════════════════════════════

A panel in the corner shows:
- Current market structure (Uptrend / Downtrend / Ranging)
- Most recent pattern detected
- Line 1: What happened (factual description)
- Line 2: What it means in context of the trend
- Line 3: What to watch for next

The panel retains the last detected pattern until a new one forms. On bars with no pattern it reads "Watching market..." so you always know the script is active.

════════════════════════════════════════
SETTINGS
════════════════════════════════════════

Toggle each pattern type on or off independently. Swing Sensitivity controls how many bars left and right are used to validate a pivot — higher values find stronger, less frequent swings. Panel position can be moved to any corner.

════════════════════════════════════════
ALERTS
════════════════════════════════════════

8 alert conditions available:
Bullish Engulfing, Bearish Engulfing, Hammer, Shooting Star, Morning Star, Evening Star, Inside Bar, Doji.

Set alerts via the TradingView alert menu after adding to chart.

════════════════════════════════════════
IMPORTANT DISCLAIMER
════════════════════════════════════════

This script is an educational tool. It identifies and labels candlestick patterns based on mathematical price relationships. It does not predict future price movement. Candlestick patterns are observations of past price behaviour — they show what buyers and sellers did, not what they will do.

No pattern has a 100% success rate. Always use proper risk management. This is not financial advice.

Past performance of any pattern does not guarantee future results.

════════════════════════════════════════
CREDITS
════════════════════════════════════════


Built entirely in Pine Script v6.
Pattern logic based on standard candlestick theory (Japanese candlestick charting techniques).
No external libraries used.

## Source Code

````pine
//@version=6
indicator("CandleStick Detector - Advisor", shorttitle="Candlestick Detector ", overlay=true, max_boxes_count=50, max_labels_count=150, max_lines_count=100)

// ============================================================
//  MARKET ADVISOR  ·  KrishEdge
//  Reads the market like a trading friend beside you
// ============================================================

c_bull = #089981
c_bear = #f23645
c_gold = #ffb300
c_gray = #787b86
c_text = #d1d4dc
c_bg   = color.new(#131722, 5)
c_hd   = #1c2230

gPAT = "Patterns"
gSTR = "Structure"
gDSH = "Advisor Panel"

showEngulf = input.bool(true, "Engulfing Candles",        group=gPAT)
showPinBar = input.bool(true, "Hammers / Shooting Stars", group=gPAT)
showInside = input.bool(true, "Inside Bar",               group=gPAT)
showDoji   = input.bool(true, "Doji",                     group=gPAT)
showStar   = input.bool(true, "Morning / Evening Star",   group=gPAT)
showLevels = input.bool(true, "Mark Swing Levels",        group=gSTR)
swingLen   = input.int(6,     "Swing Sensitivity",        group=gSTR, minval=3, maxval=20)
dashPos    = input.string("Top Right", "Panel Position",  group=gDSH, options=["Top Right","Top Left","Bottom Right","Bottom Left"])

// ============================================================
// CANDLE MATH
// ============================================================
bodySize  = math.abs(close - open)
fullRange = high - low
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low
bodyPct   = fullRange > 0 ? bodySize / fullRange : 0.0
bullBar   = close > open
bearBar   = close < open

// ============================================================
// PATTERNS
// ============================================================
bullEngulf  = bullBar and bearBar[1] and close > open[1] and open < close[1] and bodySize > bodySize[1]
bearEngulf  = bearBar and bullBar[1] and close < open[1] and open > close[1] and bodySize > bodySize[1]
insideBar   = high < high[1] and low > low[1]
hammer      = lowerWick >= bodySize * 2.0 and upperWick <= bodySize * 0.5 and bodyPct < 0.45 and not bearEngulf
shootStar   = upperWick >= bodySize * 2.0 and lowerWick <= bodySize * 0.5 and bodyPct < 0.45 and not bullEngulf
doji        = bodyPct < 0.08 and fullRange > 0 and not insideBar
morningStar = bearBar[2] and bodyPct[1] < 0.25 and bullBar and close > (open[2] + close[2]) / 2
eveningStar = bullBar[2] and bodyPct[1] < 0.25 and bearBar and close < (open[2] + close[2]) / 2

// ============================================================
// MARKET STRUCTURE
// ============================================================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low,  swingLen, swingLen)

var float ph1 = na
var float ph2 = na
var float pl1 = na
var float pl2 = na

if not na(ph)
    ph2 := ph1
    ph1 := ph
if not na(pl)
    pl2 := pl1
    pl1 := pl

uptrend   = not na(ph1) and not na(ph2) and not na(pl1) and not na(pl2) and ph1 > ph2 and pl1 > pl2
downtrend = not na(ph1) and not na(ph2) and not na(pl1) and not na(pl2) and ph1 < ph2 and pl1 < pl2

trendTxt = uptrend ? "Uptrend" : downtrend ? "Downtrend" : "Ranging"
trendCol = uptrend ? c_bull : downtrend ? c_bear : c_gold

// ============================================================
// MARK PATTERNS ON CHART
// ============================================================
if showEngulf and bullEngulf
    box.new(bar_index-1, math.max(high, high[1]), bar_index, math.min(low, low[1]), bgcolor=color.new(c_bull,82), border_color=color.new(c_bull,30), border_width=1)
    label.new(bar_index, low, "Engulf", yloc=yloc.belowbar, color=color.new(c_bull,100), textcolor=c_bull, size=size.tiny, style=label.style_label_up)

if showEngulf and bearEngulf
    box.new(bar_index-1, math.max(high, high[1]), bar_index, math.min(low, low[1]), bgcolor=color.new(c_bear,82), border_color=color.new(c_bear,30), border_width=1)
    label.new(bar_index, high, "Engulf", yloc=yloc.abovebar, color=color.new(c_bear,100), textcolor=c_bear, size=size.tiny, style=label.style_label_down)

if showPinBar and hammer
    label.new(bar_index, low, "Hammer", yloc=yloc.belowbar, color=color.new(c_bull,100), textcolor=c_bull, size=size.tiny, style=label.style_label_up)

if showPinBar and shootStar
    label.new(bar_index, high, "Shoot.Star", yloc=yloc.abovebar, color=color.new(c_bear,100), textcolor=c_bear, size=size.tiny, style=label.style_label_down)

if showInside and insideBar
    box.new(bar_index-1, high[1], bar_index, low[1], bgcolor=color.new(c_gold,88), border_color=color.new(c_gold,40), border_width=1)
    label.new(bar_index, high[1], "IB", yloc=yloc.abovebar, color=color.new(c_gold,100), textcolor=c_gold, size=size.tiny, style=label.style_label_down)

if showDoji and doji
    label.new(bar_index, high, "Doji", yloc=yloc.abovebar, color=color.new(c_gold,100), textcolor=c_gold, size=size.tiny, style=label.style_label_down)

if showStar and morningStar
    label.new(bar_index, low, "Morn.Star", yloc=yloc.belowbar, color=color.new(c_bull,100), textcolor=c_bull, size=size.small, style=label.style_label_up)

if showStar and eveningStar
    label.new(bar_index, high, "Eve.Star", yloc=yloc.abovebar, color=color.new(c_bear,100), textcolor=c_bear, size=size.small, style=label.style_label_down)

if showLevels and not na(ph)
    line.new(bar_index-swingLen, ph, bar_index+12, ph, color=color.new(c_bear,55), style=line.style_dotted, width=1)
if showLevels and not na(pl)
    line.new(bar_index-swingLen, pl, bar_index+12, pl, color=color.new(c_bull,55), style=line.style_dotted, width=1)

// ============================================================
// ADVISOR ENGINE  (plain English, no ternary across lines)
// ============================================================
var string patName   = "Watching market..."
var string adv1      = "No pattern detected yet."
var string adv2      = "Scanning for setups."
var string adv3      = ""
var bool   isBullPat = true

if bullEngulf and barstate.isconfirmed
    patName   := "Bullish Engulfing"
    isBullPat := true
    adv3      := "Next candle closing green = confirmed."
    if uptrend
        adv1 := "Trend is up and bulls just proved it. Strong move."
        adv2 := "Continuation signal. Pullback was cleanly rejected."
    else if downtrend
        adv1 := "Bears had control, but bulls just swallowed that candle."
        adv2 := "Possible reversal. Don't rush in — let it confirm."
    else
        adv1 := "Bulls stepped in and took over from bears."
        adv2 := "Market picking direction. Watch next candle closely."

if bearEngulf and barstate.isconfirmed
    patName   := "Bearish Engulfing"
    isBullPat := false
    adv3      := "Next candle closing red = confirmed."
    if downtrend
        adv1 := "Trend is down and bears just proved it. Strong move."
        adv2 := "Continuation signal. The bounce was rejected hard."
    else if uptrend
        adv1 := "Bulls had control, but bears just crushed that candle."
        adv2 := "Possible reversal. Wait — do not short into thin air."
    else
        adv1 := "Bears stepped in and took over from bulls."
        adv2 := "Market picking direction. Watch next candle closely."

if morningStar and barstate.isconfirmed
    patName   := "Morning Star"
    isBullPat := true
    adv3      := "Enter only after a strong green follow-through."
    if downtrend
        adv1 := "3-candle reversal against the downtrend. Higher risk."
        adv2 := "Bulls fighting back. Size down and wait for confirmation."
    else
        adv1 := "3-bar reversal — sellers exhausted, buyers returned."
        adv2 := "Momentum shifting to bulls. Confirm before entering."

if eveningStar and barstate.isconfirmed
    patName   := "Evening Star"
    isBullPat := false
    adv3      := "Enter only after a strong red follow-through."
    if uptrend
        adv1 := "3-candle reversal against the uptrend. Higher risk."
        adv2 := "Bears fighting back. Size down and wait for confirmation."
    else
        adv1 := "3-bar top — buyers exhausted, sellers returned."
        adv2 := "Momentum shifting to bears. Confirm before entering."

if hammer and barstate.isconfirmed
    patName   := "Hammer"
    isBullPat := true
    adv3      := "Strongest when sitting right at a support level."
    if uptrend
        adv1 := "Pullback was rejected. Bulls are defending the trend."
        adv2 := "Clean continuation setup forming. Watch for entry."
    else if downtrend
        adv1 := "Bears pushed hard, buyers pushed right back."
        adv2 := "Potential bottom. Wait for next candle to confirm."
    else
        adv1 := "Long lower wick — price rejected at this low."
        adv2 := "Buyers defended this area. Worth watching."

if shootStar and barstate.isconfirmed
    patName   := "Shooting Star"
    isBullPat := false
    adv3      := "Strongest when sitting right at a resistance level."
    if downtrend
        adv1 := "Rally was rejected. Bears are defending the trend."
        adv2 := "Clean continuation setup forming. Watch for short entry."
    else if uptrend
        adv1 := "Buyers pushed high, sellers took it all back."
        adv2 := "Warning sign. Uptrend may be losing steam here."
    else
        adv1 := "Long upper wick — price rejected at this high."
        adv2 := "Sellers defended this area. Worth watching."

if insideBar and barstate.isconfirmed
    patName   := "Inside Bar"
    isBullPat := true
    adv1      := "Market is coiled. Price held inside last candle."
    adv2      := "Big move is building. Watch which side breaks."
    if uptrend
        adv3 := "Break up = bulls. Break down = warning sign."
    else if downtrend
        adv3 := "Break down = bears. Break up = warning sign."
    else
        adv3 := "No bias yet. Follow the breakout direction."

if doji and barstate.isconfirmed
    patName   := "Doji"
    isBullPat := true
    adv1      := "Bulls and bears ended exactly equal. Nobody won."
    adv2      := "Forcing a trade here is gambling. Be patient."
    if uptrend
        adv3 := "At resistance? Could flip down. Let next candle decide."
    else if downtrend
        adv3 := "At support? Could flip up. Let next candle decide."
    else
        adv3 := "Sit on hands. Wait for next candle to show direction."

// ============================================================
// DASHBOARD
// ============================================================
f_pos(p) =>
    p == "Top Left" ? position.top_left : p == "Bottom Right" ? position.bottom_right : p == "Bottom Left" ? position.bottom_left : position.top_right

if barstate.islast
    patCol = isBullPat ? c_bull : c_bear
    var table t = table.new(f_pos(dashPos), 1, 8, bgcolor=c_bg, border_color=color.new(c_gray,55), border_width=1, frame_color=color.new(c_gray,40), frame_width=1)
    table.cell(t, 0, 0, "  Market Advisor  ",   text_color=color.white, text_size=size.small, bgcolor=c_hd,                   text_halign=text.align_center)
    table.cell(t, 0, 1, trendTxt,               text_color=trendCol,    text_size=size.small, bgcolor=color.new(c_hd, 40),    text_halign=text.align_center)
    table.cell(t, 0, 2, patName,                text_color=patCol,      text_size=size.tiny,                                  text_halign=text.align_center)
    table.cell(t, 0, 3, " ",                    text_color=c_gray,      text_size=size.tiny)
    table.cell(t, 0, 4, adv1, text_color=c_text, text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 0, 5, adv2, text_color=c_gray, text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 0, 6, adv3, text_color=c_gold, text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 0, 7, "whop.com/krishedge",   text_color=color.new(c_gray,60), text_size=size.tiny, text_halign=text.align_center)

// ============================================================
// ALERTS
// ============================================================
alertcondition(bullEngulf,  "Bullish Engulfing", "Advisor: Bullish engulfing detected")
alertcondition(bearEngulf,  "Bearish Engulfing", "Advisor: Bearish engulfing detected")
alertcondition(hammer,      "Hammer",             "Advisor: Hammer - bullish rejection")
alertcondition(shootStar,   "Shooting Star",      "Advisor: Shooting star - bearish rejection")
alertcondition(morningStar, "Morning Star",        "Advisor: Morning star reversal")
alertcondition(eveningStar, "Evening Star",        "Advisor: Evening star reversal")
alertcondition(insideBar,   "Inside Bar",          "Advisor: Inside bar - watch for breakout")
alertcondition(doji,        "Doji",                "Advisor: Doji - market undecided")
````
