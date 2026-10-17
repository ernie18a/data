# Ultimate Robust VP Scorecard HUD

- url: https://www.tradingview.com/script/EwH6DnOf-Ultimate-Robust-VP-Scorecard-HUD/
- type: indicator
- pine_id: PUB;088ca0b07f414b3aadee6d77400c993c
- version: 1.0

## Description

VOLUME PROFILE BIAS DASHBOARD STRATEGY

CORE PHILOSOPHY

The strategy answers three questions:

1. DIRECTION (MACRO BIAS)

Determine the overall market bias using the 5-Day Volume Profile.

Rules:

• Price Above 5-Day VAH = Bullish Macro Bias
• Price At or Near 5-Day POC = Neutral Macro Bias
• Price Below 5-Day VAL = Bearish Macro Bias

The 5-Day Profile shows where value has been accepted over the last week.

Highest conviction occurs when Macro Bias and Session Bias agree.

--------------------------------------------------

2. SESSION CONTEXT (DAILY BIAS)

Determine the session bias using yesterday's volume profile.

Rules:

• Today's Open Above Yesterday VAH = Bullish Session Bias
• Today's Open Inside Yesterday Value Area = Neutral Session Bias
• Today's Open Below Yesterday VAL = Bearish Session Bias

Interpretation:

• Above VAH = Buyers accepted higher prices
• Inside Value = Balance / Chop
• Below VAL = Sellers accepted lower prices

--------------------------------------------------

3. LOCATION (KEY LEVELS)

Automatically calculate and display:

• Previous Session VAH
• Previous Session VAL
• Previous Session POC
• 5-Day VAH
• 5-Day VAL
• 5-Day POC
• HVNs (High Volume Nodes)
• LVNs (Low Volume Nodes)
• Hidden Bumps

These become the reaction zones and profit targets.

==================================================

DASHBOARD SCORECARD

Display in the top-right corner.

Bias Score (1 Point Each)

✅ Price Above 5-Day VAH
✅ Open Above Yesterday VAH
✅ Current Price Above Yesterday VAH
✅ Acceptance Outside Value Area
✅ Relative Volume Above Average

Total Score:

5/5 = A+ Bullish
4/5 = Strong Bullish
3/5 = Neutral
2/5 = Weak
0-1/5 = Bearish

Reverse the logic for bearish conditions.

==================================================

DASHBOARD DISPLAY

Macro Context:
• Bullish
• Neutral
• Bearish

Session Context:
• Bullish
• Neutral
• Bearish

Open Location:
• Above VAH
• Inside Value
• Below VAL

Current Location:
• Above VAH
• Inside Value
• Below VAL

Acceptance Status:
• Accepted Above Value
• Accepted Below Value
• Inside Value

Relative Volume:
• Strong
• Average
• Weak

Overall Bias Score:
• 0-5

Trade Rating:
• A+
• Strong
• Neutral
• Weak
• Bearish

==================================================

LONG SETUP

Requirements:

Macro:
✅ Price Above 5-Day VAH

Session:
✅ Open Above Yesterday VAH

Trigger:
✅ Pullback Holds VAH

Entry:
• Buy Acceptance Above VAH

Stop:
• Below VAH

Targets:
• Next HVN
• Next Hidden Bump
• Next VAH
• Major Volume Node

==================================================

SHORT SETUP

Requirements:

Macro:
✅ Price Below 5-Day VAL

Session:
✅ Open Below Yesterday VAL

Trigger:
✅ Retest Fails Below VAL

Entry:
• Sell Acceptance Below VAL

Stop:
• Above VAL

Targets:
• Next LVN
• Next Hidden Bump
• Next VAL
• Major Volume Node

==================================================

NO TRADE CONDITIONS

Avoid trading when:

❌ Open Inside Value Area
❌ Current Price Inside Value Area
❌ Macro Bias and Session Bias Disagree
❌ Relative Volume Is Weak
❌ Acceptance Is Not Confirmed

Display:

"NO TRADE - INSIDE VALUE"

or

"NO TRADE - CONFLICTING BIAS"

==================================================

IMPORTANT CONCEPTS

Value Area
• Area containing approximately 70% of the session's volume.

VAH (Value Area High)
• Upper edge of accepted value.

VAL (Value Area Low)
• Lower edge of accepted value.

POC (Point of Control)
• Price level with the highest volume traded.
• Acts as the market's center of gravity.

HVN (High Volume Node)
• Price area where the market accepted value.
• Often acts as support or resistance.

LVN (Low Volume Node)
• Price area where little volume traded.
• Price often moves quickly through these zones.

Hidden Bumps
• Aggressive institutional positioning zones inside thin profiles.
• Often create strong reactions.

==================================================

TRADING LOGIC

The strategy only answers three questions:

1. Direction
• Bullish
• Bearish
• Neutral

2. Location
• VAH
• VAL
• POC
• HVN
• LVN
• Hidden Bump

3. Trigger
• Acceptance Above Value
• Acceptance Below Value
• Pullback Hold
• Retest Failure

Everything else is noise.

==================================================

ULTIMATE GOAL

Create a Volume Profile Bias Dashboard that automatically identifies:

• 5-Day Macro Bias
• Daily Session Bias
• Opening Location
• Acceptance Outside Value
• HVNs
• LVNs
• Hidden Bumps
• Key Targets

Then generate:

• Bullish Trade Opportunities
• Bearish Trade Opportunities
• No Trade Conditions

The objective is to determine whether the market is accepting higher value, lower value, or remaining balanced before executing a trade.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ 
//@version=6
indicator("Ultimate Robust VP Scorecard HUD", shorttitle="VP Robust HUD", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// --- 1. Inputs ---
group_vp = "--- Profile Settings ---"
orbTime     = input.session("0930-0945", "ORB Time (NY)", group = group_vp)
rows        = input.int(35, "Profile Detail (Rows)", minval = 10, group = group_vp)
widthMult   = input.int(45, "Profile Width", group = group_vp)

group_dash = "--- HUD Settings ---"
dashPos     = input.string("bottom_center", "HUD Position", options = ["top_right", "bottom_right", "top_left", "bottom_left", "top_center", "bottom_center"], group = group_dash)
bullColor   = input.color(#089981, "Bullish Color", group = group_dash)
bearColor   = input.color(#f23645, "Bearish Color", group = group_dash)
neutralColor= input.color(#5b9cf6, "Neutral Color", group = group_dash)

// --- 2. Levels & Data ---
dHigh = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
dLow  = request.security(syminfo.tickerid, "D", low[1], lookahead = barmerge.lookahead_on)
yVah  = dHigh - (dHigh - dLow) * 0.15
yVal  = dLow + (dHigh - dLow) * 0.15
yPoc  = (dHigh + dLow) / 2

var float dayOpen = na
if ta.change(time("D", "America/New_York")) != 0
    dayOpen := open

// Buffers
var float[] orbP = array.new_float()
var float[] orbV = array.new_float()
var int orbStart = 0
bool inORB = not na(time(timeframe.period, orbTime, "America/New_York"))

if inORB
    if not inORB[1]
        array.clear(orbP), array.clear(orbV), orbStart := bar_index
    array.push(orbP, close), array.push(orbV, volume)

var float[] fDayP = array.new_float()
var float[] fDayV = array.new_float()
array.push(fDayP, close), array.push(fDayV, volume)
if array.size(fDayP) > 5000
    array.remove(fDayP, 0), array.remove(fDayV, 0)

// --- 3. Macro 5-Day Analysis ---
float macroVah = na
float macroVal = na
if array.size(fDayP) > 0
    float mn = array.min(fDayP)
    float mx = array.max(fDayP)
    macroVah := mx - (mx - mn) * 0.2
    macroVal := mn + (mx - mn) * 0.2

// --- 4. Order Flow & Bias Logic ---
float volAvg = ta.sma(volume, 20)
bool rvolStrong = volume > volAvg * 1.2
float delta = (close - open) * volume / (high - low + 0.000001)
bool deltaConf = (close > open and delta > 0) or (close < open and delta < 0)
float atr = ta.atr(14)
bool atrExp = atr > ta.sma(atr, 14)
bool vwapConf = (close > ta.vwap)

// Realtime Daily Bias Calculation
string dailyBias = "NEUTRAL"
color biasColor = neutralColor
if close > macroVah and close > yVah
    dailyBias := "BULLISH"
    biasColor := bullColor
else if close < macroVal and close < yVal
    dailyBias := "BEARISH"
    biasColor := bearColor

// Scorecard (10 pts)
bool c1 = close > yVah or close < yVal 
bool c2 = (close > yVah and dayOpen > yVah) or (close < yVal and dayOpen < yVal) 
bool c3 = (close > yVah and close > open) or (close < yVal and close < open) 
bool c4 = rvolStrong 
bool c5 = deltaConf 
bool c6 = atrExp 
bool c7 = vwapConf 
bool c8 = not (close < yVah and close > yVal) 
bool c9 = volume > volAvg 
bool c10 = math.abs(close - yPoc) > (yVah - yVal) * 0.3

int score = (c1?1:0) + (c2?1:0) + (c3?1:0) + (c4?1:0) + (c5?1:0) + (c6?1:0) + (c7?1:0) + (c8?1:0) + (c9?1:0) + (c10?1:0)
string rankText = score >= 9 ? "A+ INSTITUTIONAL" : score >= 7 ? "STRONG SETUP" : score >= 5 ? "NEUTRAL BIAS" : "LOW QUALITY"
color rankColor = score >= 8 ? bullColor : score >= 6 ? neutralColor : bearColor

// --- 5. Rendering & Labels ---
bgcolor(score < 5 ? color.new(color.gray, 92) : na)
plot(yVah, "YVah", color = color.new(bullColor, 40), linewidth = 2)
plot(yVal, "YVal", color = color.new(bearColor, 40), linewidth = 2)
plot(yPoc, "YPoc", color = color.yellow)

var label vahLabel = label.new(na, na, "VAH", style = label.style_label_left, color = #00000000, textcolor = bullColor, size = size.tiny)
var label valLabel = label.new(na, na, "VAL", style = label.style_label_left, color = #00000000, textcolor = bearColor, size = size.tiny)
var label pocLabel = label.new(na, na, "POC", style = label.style_label_left, color = #00000000, textcolor = color.yellow, size = size.tiny)

if barstate.islast
    label.set_xy(vahLabel, bar_index + 1, yVah)
    label.set_xy(valLabel, bar_index + 1, yVal)
    label.set_xy(pocLabel, bar_index + 1, yPoc)

    // Profile Rendering
    if array.size(fDayP) > 0
        float mn = array.min(fDayP), float mx = array.max(fDayP), stp = (mx - mn) / rows
        float[] bns = array.new_float(rows, 0.0)
        for i = 0 to array.size(fDayP) - 1
            int idx = int(math.min(rows - 1, math.floor((array.get(fDayP, i) - mn) / stp)))
            array.set(bns, idx, array.get(bns, idx) + array.get(fDayV, i))
        float mxV = 0.0, int pIdx = 0
        for i = 0 to rows - 1
            if array.get(bns, i) > mxV
                mxV := array.get(bns, i), pIdx := i
        for i = 0 to rows - 1
            float bPr = mn + (i * stp), l = (array.get(bns, i) / (mxV + 0.0001)) * widthMult
            line.new(bar_index, bPr, int(bar_index - l), bPr, color = i == pIdx ? color.yellow : color.new(color.gray, 70), width = 3)

    if array.size(orbP) > 0
        float mn = array.min(orbP), float mx = array.max(orbP), stp = (mx - mn) / rows
        float[] bns = array.new_float(rows, 0.0)
        for i = 0 to array.size(orbP) - 1
            int idx = int(math.min(rows - 1, math.floor((array.get(orbP, i) - mn) / stp)))
            array.set(bns, idx, array.get(bns, idx) + array.get(orbV, i))
        float mxV = 0.0, int pIdx = 0
        for i = 0 to rows - 1
            if array.get(bns, i) > mxV
                mxV := array.get(bns, i), pIdx := i
        for i = 0 to rows - 1
            float bPr = mn + (i * stp), l = (array.get(bns, i) / (mxV + 0.0001)) * widthMult
            line.new(orbStart, bPr, int(orbStart + l), bPr, color = i == pIdx ? color.yellow : color.new(color.gray, 70), width = 3)

    // --- Horizontal Wide Scorecard ---
    var table h = table.new(dashPos, 13, 2, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.gray)
    
    // Rating
    table.cell(h, 0, 0, "INSTITUTIONAL RATING", bgcolor = rankColor, text_color = color.white, text_size = size.tiny)
    table.cell(h, 0, 1, rankText + " [" + str.tostring(score) + "/10]", bgcolor = rankColor, text_color = color.white, text_size = size.small)
    table.merge_cells(h, 0, 0, 1, 0), table.merge_cells(h, 0, 1, 1, 1)

    // NEW: Realtime Daily Bias Column
    table.cell(h, 2, 0, "DAILY BIAS", bgcolor = biasColor, text_color = color.white, text_size = size.tiny)
    table.cell(h, 2, 1, dailyBias, bgcolor = biasColor, text_color = color.white, text_size = size.small)

    // Metric Data
    table.cell(h, 3, 0, "BREAK", text_color = color.gray, text_size = size.tiny)
    table.cell(h, 3, 1, c1 ? "✅" : "❌", text_size = size.small)
    table.cell(h, 4, 0, "BIAS", text_color = color.gray, text_size = size.tiny)
    table.cell(h, 4, 1, c2 ? "✅" : "❌", text_size = size.small)
    table.cell(h, 5, 0, "ACCEPT", text_color = color.gray, text_size = size.tiny)
    table.cell(h, 5, 1, c3 ? "✅" : "❌", text_size = size.small)
    table.cell(h, 6, 0, "RVOL", text_color = color.gray, text_size = size.tiny)
    table.cell(h, 6, 1, c4 ? "✅" : "❌", text_size = size.small)
    table.cell(h, 7, 0, "DELTA", text_color = color.gray, text_size = size.tiny)
    table.cell(h, 7, 1, c5 ? "✅" : "❌", text_size = size.small)
    table.cell(h, 8, 0, "ATR", text_color = color.gray, text_size = size.tiny)
    table.cell(h, 8, 1, c6 ? "✅" : "❌", text_size = size.small)
    table.cell(h, 9, 0, "VWAP", text_color = color.gray, text_size = size.tiny)
    table.cell(h, 9, 1, c7 ? "✅" : "❌", text_size = size.small)
    table.cell(h, 10, 0, "LOCATION", text_color = color.gray, text_size = size.tiny)
    table.cell(h, 10, 1, c8 ? "✅" : "❌", text_size = size.small)
    table.cell(h, 11, 0, "VOLUME", text_color = color.gray, text_size = size.tiny)
    table.cell(h, 11, 1, c9 ? "✅" : "❌", text_size = size.small)
    table.cell(h, 12, 0, "POC DIST", text_color = color.gray, text_size = size.tiny)
    table.cell(h, 12, 1, c10 ? "✅" : "❌", text_size = size.small)
````
