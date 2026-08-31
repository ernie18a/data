<!-- tradingview-pine-id: PUB;b912142ea4034a5581171cbffcc685f6 -->
<!-- tradingviewscripts-format: 1 -->
# NQ Full Major Levels + Confluence + Strategy Triggers v5

Source: https://www.tradingview.com/script/OFh0n9Lk-NQ-Full-Major-Levels-Confluence-Strategy-Triggers-v5/

## Description

NQ Major Levels, Confluence & Strategy Triggers is an overlay indicator designed to turn a structured Nasdaq futures trading plan into a clean, actionable chart layout.

The indicator plots key support and resistance zones, highlights areas where bullish or bearish reversals may develop, tracks the overnight range, and displays confirmed strategy signals with projected targets. It is intended for traders who use multi-timeframe market structure, moving averages, VWAP, volume-profile references, order blocks and volatility confirmation as part of their analysis.

---

## Source Code

````pine
//@version=6
indicator(
     "NQ Full Major Levels + Confluence + Strategy Triggers v5",
     shorttitle = "NQ Full Levels v5",
     overlay = true,
     max_lines_count = 100,
     max_boxes_count = 50,
     max_labels_count = 100)

//=============================================================================
// PURPOSE
//=============================================================================
// v5 plots every major resistance/support zone from the Aug. 3, 2026 17:38 CT update.
// Each zone has:
//   • Orange horizontal lines at BOTH zone boundaries.
//   • A right-side text label showing the range and confluence.
//   • White shading for bearish reversal zones.
//   • Yellow shading for bullish reversal zones.
//
// It also plots:
//   • Overnight high/low in blue.
//   • Confirmed bullish/bearish entry arrows.
//   • The two nearest targets in purple after a confirmed entry.
//
// IMPORTANT:
// These analysis levels are editable in Settings. Update the inputs when a new
// daily plan provides different levels.

//=============================================================================
// DISPLAY INPUTS
//=============================================================================
string GROUP_DISPLAY = "1. Display"
bool showResistance = input.bool(true, "Show major resistance", group = GROUP_DISPLAY)
bool showSupport = input.bool(true, "Show major support", group = GROUP_DISPLAY)
bool showReversalZones = input.bool(true, "Show reversal-zone shading", group = GROUP_DISPLAY)
bool showConfluenceLabels = input.bool(true, "Show confluence text", group = GROUP_DISPLAY)
string confluenceTextSizeInput = input.string(
     "Small",
     "Confluence text size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = GROUP_DISPLAY)
int levelLookbackBars = input.int(300, "Lines/zones extend left (bars)", minval = 25, maxval = 5000, group = GROUP_DISPLAY)
int labelOffsetBars = input.int(3, "Confluence-label offset (bars)", minval = 1, maxval = 50, group = GROUP_DISPLAY)
int zoneTransparency = input.int(
     72,
     "Zone transparency",
     minval = 0,
     maxval = 95,
     tooltip = "Lower values create stronger shading.",
     group = GROUP_DISPLAY)
int lineWidth = input.int(2, "Support/resistance line width", minval = 1, maxval = 4, group = GROUP_DISPLAY)

//=============================================================================
// OVERNIGHT HIGH / LOW
//=============================================================================
string GROUP_SESSION = "2. Overnight High / Low"
bool showOvernight = input.bool(true, "Show overnight high/low", group = GROUP_SESSION)
string overnightSession = input.session("1700-0830", "Overnight session", group = GROUP_SESSION)
string overnightDays = input.string("1234567", "Session days", tooltip = "1=Sunday ... 7=Saturday", group = GROUP_SESSION)
string sessionTimezone = input.string(
     "America/Chicago",
     "Session time zone",
     options = ["America/Chicago", "America/New_York", "Etc/UTC"],
     group = GROUP_SESSION)

//=============================================================================
// MAJOR RESISTANCE ZONES
//=============================================================================
string GROUP_R1 = "3. Resistance R1"
float r1Low = input.float(28944.50, "R1 lower boundary", step = 0.25, group = GROUP_R1)
float r1High = input.float(28960.00, "R1 upper boundary", step = 0.25, group = GROUP_R1)
string r1Confluence = input.string(
     "Overnight/session high 28959.75 + 1/5/15m supply + upper value-area edge",
     "R1 confluence",
     group = GROUP_R1)

string GROUP_R2 = "4. Resistance R2"
float r2Low = input.float(28980.00, "R2 lower boundary", step = 0.25, group = GROUP_R2)
float r2High = input.float(29010.00, "R2 upper boundary", step = 0.25, group = GROUP_R2)
string r2Confluence = input.string(
     "Psychological 29000 + 1-hour channel resistance + low-volume continuation area",
     "R2 confluence",
     group = GROUP_R2)

string GROUP_R3 = "5. Resistance R3"
float r3Low = input.float(29050.00, "R3 lower boundary", step = 0.25, group = GROUP_R3)
float r3High = input.float(29100.00, "R3 upper boundary", step = 0.25, group = GROUP_R3)
string r3Confluence = input.string(
     "4-hour EMA 200 near 29055.65 + descending-channel resistance",
     "R3 confluence",
     group = GROUP_R3)

string GROUP_R4 = "6. Resistance R4"
float r4Low = input.float(29200.00, "R4 lower boundary", step = 0.25, group = GROUP_R4)
float r4High = input.float(29450.00, "R4 upper boundary", step = 0.25, group = GROUP_R4)
string r4Confluence = input.string(
     "Major 4-hour bearish order-block and supply cluster",
     "R4 confluence",
     group = GROUP_R4)

string GROUP_R5 = "7. Resistance R5"
float r5Low = input.float(29900.00, "R5 lower boundary", step = 0.25, group = GROUP_R5)
float r5High = input.float(30500.00, "R5 upper boundary", step = 0.25, group = GROUP_R5)
string r5Confluence = input.string(
     "Daily supply / prior distribution and swing-high liquidity",
     "R5 confluence",
     group = GROUP_R5)

//=============================================================================
// MAJOR SUPPORT ZONES
//=============================================================================
string GROUP_S1 = "8. Support S1"
float s1Low = input.float(28932.00, "S1 lower boundary", step = 0.25, group = GROUP_S1)
float s1High = input.float(28942.00, "S1 upper boundary", step = 0.25, group = GROUP_S1)
string s1Confluence = input.string(
     "15m POC near 28939.75 + 1/5m VWAP and EMA cluster + local high-volume node",
     "S1 confluence",
     group = GROUP_S1)

string GROUP_S2 = "9. Support S2"
float s2Low = input.float(28918.00, "S2 lower boundary", step = 0.25, group = GROUP_S2)
float s2High = input.float(28930.00, "S2 upper boundary", step = 0.25, group = GROUP_S2)
string s2Confluence = input.string(
     "Overnight low near 28919 + 15m breakout shelf + short-term bullish order block",
     "S2 confluence",
     group = GROUP_S2)

string GROUP_S3 = "10. Support S3"
float s3Low = input.float(28882.00, "S3 lower boundary", step = 0.25, group = GROUP_S3)
float s3High = input.float(28900.00, "S3 upper boundary", step = 0.25, group = GROUP_S3)
string s3Confluence = input.string(
     "5m EMA 50 near 28898.94 + 15m bullish order block + prior value-area support",
     "S3 confluence",
     group = GROUP_S3)

string GROUP_S4 = "11. Support S4"
float s4Low = input.float(28835.00, "S4 lower boundary", step = 0.25, group = GROUP_S4)
float s4High = input.float(28850.00, "S4 upper boundary", step = 0.25, group = GROUP_S4)
string s4Confluence = input.string(
     "5m bullish order block + prior consolidation and imbalance support",
     "S4 confluence",
     group = GROUP_S4)

string GROUP_S5 = "12. Support S5"
float s5Low = input.float(28770.00, "S5 lower boundary", step = 0.25, group = GROUP_S5)
float s5High = input.float(28790.00, "S5 upper boundary", step = 0.25, group = GROUP_S5)
string s5Confluence = input.string(
     "15m EMA 50 near 28778.43 + intraday demand and channel support",
     "S5 confluence",
     group = GROUP_S5)

string GROUP_S6 = "13. Support S6"
float s6Low = input.float(28580.00, "S6 lower boundary", step = 0.25, group = GROUP_S6)
float s6High = input.float(28610.00, "S6 upper boundary", step = 0.25, group = GROUP_S6)
string s6Confluence = input.string(
     "15m volume-profile pivot near 28580 + prior breakout base",
     "S6 confluence",
     group = GROUP_S6)

string GROUP_S7 = "14. Support S7"
float s7Low = input.float(28460.00, "S7 lower boundary", step = 0.25, group = GROUP_S7)
float s7High = input.float(28525.00, "S7 upper boundary", step = 0.25, group = GROUP_S7)
string s7Confluence = input.string(
     "1h EMA 200 near 28470 + 1h EMA 50 near 28524 + 15m EMA 200 near 28513",
     "S7 confluence",
     group = GROUP_S7)

string GROUP_S8 = "15. Support S8"
float s8Low = input.float(28050.00, "S8 lower boundary", step = 0.25, group = GROUP_S8)
float s8High = input.float(28220.00, "S8 upper boundary", step = 0.25, group = GROUP_S8)
string s8Confluence = input.string(
     "Larger 1-hour bullish order block + rising-channel demand",
     "S8 confluence",
     group = GROUP_S8)

string GROUP_S9 = "16. Support S9"
float s9Low = input.float(27150.00, "S9 lower boundary", step = 0.25, group = GROUP_S9)
float s9High = input.float(27350.00, "S9 upper boundary", step = 0.25, group = GROUP_S9)
string s9Confluence = input.string(
     "Major 4-hour and daily demand + July washout reversal base",
     "S9 confluence",
     group = GROUP_S9)

// Current chart-plan context:
//   Intraday bias: bullish above S1/S2, but price is testing R1.
//   Higher timeframe: bullish rebound; 4h EMA 200 at R3 remains the main cap.
//   VIX reference: 18.48-18.58 is the risk-off confirmation zone.
//   Strategy arrows remain conditional and print only after confirmed entries.

//=============================================================================
// STRATEGY INPUTS
//=============================================================================
string GROUP_SIGNALS = "17. Strategy Triggers"
bool enableReversalEntries = input.bool(true, "Reversal / mean-reversion entries", group = GROUP_SIGNALS)
bool enableBreakoutRetests = input.bool(true, "Breakout/breakdown retest entries", group = GROUP_SIGNALS)
bool enableTrendPullbacks = input.bool(true, "EMA trend-pullback entries", group = GROUP_SIGNALS)
int retestWindowBars = input.int(8, "Retest window (bars)", minval = 1, maxval = 50, group = GROUP_SIGNALS)
float retestTolerancePoints = input.float(6.0, "Retest tolerance (points)", minval = 0.25, step = 0.25, group = GROUP_SIGNALS)
int signalCooldownBars = input.int(5, "Minimum bars between arrows", minval = 0, maxval = 100, group = GROUP_SIGNALS)
bool useVWAPFilter = input.bool(true, "Use VWAP confirmation", group = GROUP_SIGNALS)
bool useVIXFilter = input.bool(true, "Use VIX direction confirmation", group = GROUP_SIGNALS)
string vixSymbol = input.symbol("CBOE:VIX", "VIX symbol", group = GROUP_SIGNALS)
string vixTimeframe = input.timeframe("15", "VIX timeframe", group = GROUP_SIGNALS)

//=============================================================================
// TARGET INPUTS
//=============================================================================
string GROUP_TARGETS = "18. Targets"
int atrLength = input.int(14, "ATR length", minval = 2, group = GROUP_TARGETS)
bool showSecondTarget = input.bool(true, "Show second target", group = GROUP_TARGETS)
float fallbackTarget1ATR = input.float(1.5, "Fallback target 1 (ATR)", minval = 0.25, step = 0.25, group = GROUP_TARGETS)
float fallbackTarget2ATR = input.float(2.5, "Fallback target 2 (ATR)", minval = 0.50, step = 0.25, group = GROUP_TARGETS)

//=============================================================================
// HELPER FUNCTIONS
//=============================================================================
f_label_size(string selectedSize) =>
    selectedSize == "Small" ? size.small :
     selectedSize == "Normal" ? size.normal :
     selectedSize == "Large" ? size.large :
     selectedSize == "Huge" ? size.huge :
     size.tiny

f_update_line(line existingLine, float price, bool visible, color lineColor, int width) =>
    line result = existingLine
    if not visible or na(price)
        if not na(result)
            line.delete(result)
            result := na
    else
        int leftBar = math.max(0, bar_index - levelLookbackBars)
        if na(result)
            result := line.new(
                 leftBar,
                 price,
                 bar_index + 1,
                 price,
                 xloc = xloc.bar_index,
                 extend = extend.right,
                 color = lineColor,
                 width = width)
        else
            line.set_xy1(result, leftBar, price)
            line.set_xy2(result, bar_index + 1, price)
            line.set_extend(result, extend.right)
            line.set_color(result, lineColor)
            line.set_width(result, width)
    result

f_update_zone_box(box existingBox, float zoneLow, float zoneHigh, bool visible, color fillColor) =>
    box result = existingBox
    if not visible or na(zoneLow) or na(zoneHigh)
        if not na(result)
            box.delete(result)
            result := na
    else
        float bottomPrice = math.min(zoneLow, zoneHigh)
        float topPrice = math.max(zoneLow, zoneHigh)
        int leftBar = math.max(0, bar_index - levelLookbackBars)
        if na(result)
            result := box.new(
                 left = leftBar,
                 top = topPrice,
                 right = bar_index + 1,
                 bottom = bottomPrice,
                 xloc = xloc.bar_index,
                 extend = extend.right,
                 border_color = color.new(fillColor, 100),
                 bgcolor = fillColor)
        else
            box.set_left(result, leftBar)
            box.set_right(result, bar_index + 1)
            box.set_top(result, topPrice)
            box.set_bottom(result, bottomPrice)
            box.set_extend(result, extend.right)
            box.set_border_color(result, color.new(fillColor, 100))
            box.set_bgcolor(result, fillColor)
    result

f_update_zone_label(
     label existingLabel,
     string prefix,
     float zoneLow,
     float zoneHigh,
     string confluence,
     bool visible,
     color textColor,
     string textSize) =>
    label result = existingLabel
    if not visible or na(zoneLow) or na(zoneHigh)
        if not na(result)
            label.delete(result)
            result := na
    else
        float lowerPrice = math.min(zoneLow, zoneHigh)
        float upperPrice = math.max(zoneLow, zoneHigh)
        float middlePrice = (lowerPrice + upperPrice) / 2.0
        string zoneText = prefix + " " +
             str.tostring(lowerPrice, format.mintick) + "–" +
             str.tostring(upperPrice, format.mintick) + "\n" +
             confluence

        if na(result)
            result := label.new(
                 bar_index + labelOffsetBars,
                 middlePrice,
                 zoneText,
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_left,
                 color = color.new(color.black, 15),
                 textcolor = textColor,
                 size = textSize)
        else
            label.set_x(result, bar_index + labelOffsetBars)
            label.set_y(result, middlePrice)
            label.set_text(result, zoneText)
            label.set_color(result, color.new(color.black, 15))
            label.set_textcolor(result, textColor)
            label.set_style(result, label.style_label_left)
            label.set_size(result, textSize)
    result

f_zone_touched(float zoneLow, float zoneHigh) =>
    float lowerPrice = math.min(zoneLow, zoneHigh)
    float upperPrice = math.max(zoneLow, zoneHigh)
    high >= lowerPrice and low <= upperPrice

f_bullish_reclaim(float zoneLow, float zoneHigh) =>
    float upperPrice = math.max(zoneLow, zoneHigh)
    f_zone_touched(zoneLow, zoneHigh) and close > upperPrice

f_bearish_reject(float zoneLow, float zoneHigh) =>
    float lowerPrice = math.min(zoneLow, zoneHigh)
    f_zone_touched(zoneLow, zoneHigh) and close < lowerPrice

f_two_nearest_above(array<float> levels, float referencePrice) =>
    float target1 = na
    float target2 = na
    int count = array.size(levels)
    if count > 0
        for i = 0 to count - 1
            float level = array.get(levels, i)
            if level > referencePrice
                if na(target1) or level < target1
                    target2 := target1
                    target1 := level
                else if (na(target2) or level < target2) and level != target1
                    target2 := level
    [target1, target2]

f_two_nearest_below(array<float> levels, float referencePrice) =>
    float target1 = na
    float target2 = na
    int count = array.size(levels)
    if count > 0
        for i = 0 to count - 1
            float level = array.get(levels, i)
            if level < referencePrice
                if na(target1) or level > target1
                    target2 := target1
                    target1 := level
                else if (na(target2) or level > target2) and level != target1
                    target2 := level
    [target1, target2]

//=============================================================================
// CORE CALCULATIONS
//=============================================================================
float atr = ta.atr(atrLength)
float ema9 = ta.ema(close, 9)
float ema20 = ta.ema(close, 20)
float ema50 = ta.ema(close, 50)
float vwapValue = ta.vwap(hlc3)

float vixClose = request.security(vixSymbol, vixTimeframe, close, lookahead = barmerge.lookahead_off)
float vixEMA9 = request.security(vixSymbol, vixTimeframe, ta.ema(close, 9), lookahead = barmerge.lookahead_off)

bool longVWAPOk = not useVWAPFilter or na(vwapValue) or close > vwapValue
bool shortVWAPOk = not useVWAPFilter or na(vwapValue) or close < vwapValue
bool longVIXOk = not useVIXFilter or na(vixClose) or na(vixEMA9) or vixClose <= vixEMA9
bool shortVIXOk = not useVIXFilter or na(vixClose) or na(vixEMA9) or vixClose >= vixEMA9

bool bullishStack = ema9 > ema20 and ema20 > ema50
bool bearishStack = ema9 < ema20 and ema20 < ema50
string confluenceTextSize = f_label_size(confluenceTextSizeInput)

//=============================================================================
// OVERNIGHT HIGH / LOW — BLUE
//=============================================================================
string fullOvernightSession = overnightSession + ":" + overnightDays
bool inOvernight = not na(time(timeframe.period, fullOvernightSession, sessionTimezone))
bool overnightStart = inOvernight and not inOvernight[1]

var float overnightHigh = na
var float overnightLow = na
var line overnightHighLine = na
var line overnightLowLine = na

if overnightStart
    overnightHigh := high
    overnightLow := low

    if not na(overnightHighLine)
        line.delete(overnightHighLine)
    if not na(overnightLowLine)
        line.delete(overnightLowLine)

    overnightHighLine := na
    overnightLowLine := na

if inOvernight
    overnightHigh := na(overnightHigh) ? high : math.max(overnightHigh, high)
    overnightLow := na(overnightLow) ? low : math.min(overnightLow, low)

overnightHighLine := f_update_line(overnightHighLine, overnightHigh, showOvernight and not na(overnightHigh), color.blue, 2)
overnightLowLine := f_update_line(overnightLowLine, overnightLow, showOvernight and not na(overnightLow), color.blue, 2)

//=============================================================================
// DRAW ALL RESISTANCE/SUPPORT BOUNDARIES, ZONES, AND CONFLUENCE LABELS
//=============================================================================
color srColor = color.orange
color bearishZoneColor = color.new(color.white, zoneTransparency)
color bullishZoneColor = color.new(color.yellow, zoneTransparency)

// Resistance boundary lines
var line r1LowLine = na
var line r1HighLine = na
var line r2LowLine = na
var line r2HighLine = na
var line r3LowLine = na
var line r3HighLine = na
var line r4LowLine = na
var line r4HighLine = na
var line r5LowLine = na
var line r5HighLine = na

r1LowLine := f_update_line(r1LowLine, r1Low, showResistance, srColor, lineWidth)
r1HighLine := f_update_line(r1HighLine, r1High, showResistance, srColor, lineWidth)
r2LowLine := f_update_line(r2LowLine, r2Low, showResistance, srColor, lineWidth)
r2HighLine := f_update_line(r2HighLine, r2High, showResistance, srColor, lineWidth)
r3LowLine := f_update_line(r3LowLine, r3Low, showResistance, srColor, lineWidth)
r3HighLine := f_update_line(r3HighLine, r3High, showResistance, srColor, lineWidth)
r4LowLine := f_update_line(r4LowLine, r4Low, showResistance, srColor, lineWidth)
r4HighLine := f_update_line(r4HighLine, r4High, showResistance, srColor, lineWidth)
r5LowLine := f_update_line(r5LowLine, r5Low, showResistance, srColor, lineWidth)
r5HighLine := f_update_line(r5HighLine, r5High, showResistance, srColor, lineWidth)

// Support boundary lines
var line s1LowLine = na
var line s1HighLine = na
var line s2LowLine = na
var line s2HighLine = na
var line s3LowLine = na
var line s3HighLine = na
var line s4LowLine = na
var line s4HighLine = na
var line s5LowLine = na
var line s5HighLine = na
var line s6LowLine = na
var line s6HighLine = na
var line s7LowLine = na
var line s7HighLine = na
var line s8LowLine = na
var line s8HighLine = na
var line s9LowLine = na
var line s9HighLine = na

s1LowLine := f_update_line(s1LowLine, s1Low, showSupport, srColor, lineWidth)
s1HighLine := f_update_line(s1HighLine, s1High, showSupport, srColor, lineWidth)
s2LowLine := f_update_line(s2LowLine, s2Low, showSupport, srColor, lineWidth)
s2HighLine := f_update_line(s2HighLine, s2High, showSupport, srColor, lineWidth)
s3LowLine := f_update_line(s3LowLine, s3Low, showSupport, srColor, lineWidth)
s3HighLine := f_update_line(s3HighLine, s3High, showSupport, srColor, lineWidth)
s4LowLine := f_update_line(s4LowLine, s4Low, showSupport, srColor, lineWidth)
s4HighLine := f_update_line(s4HighLine, s4High, showSupport, srColor, lineWidth)
s5LowLine := f_update_line(s5LowLine, s5Low, showSupport, srColor, lineWidth)
s5HighLine := f_update_line(s5HighLine, s5High, showSupport, srColor, lineWidth)
s6LowLine := f_update_line(s6LowLine, s6Low, showSupport, srColor, lineWidth)
s6HighLine := f_update_line(s6HighLine, s6High, showSupport, srColor, lineWidth)
s7LowLine := f_update_line(s7LowLine, s7Low, showSupport, srColor, lineWidth)
s7HighLine := f_update_line(s7HighLine, s7High, showSupport, srColor, lineWidth)
s8LowLine := f_update_line(s8LowLine, s8Low, showSupport, srColor, lineWidth)
s8HighLine := f_update_line(s8HighLine, s8High, showSupport, srColor, lineWidth)
s9LowLine := f_update_line(s9LowLine, s9Low, showSupport, srColor, lineWidth)
s9HighLine := f_update_line(s9HighLine, s9High, showSupport, srColor, lineWidth)

// Shaded reversal zones
var box r1Box = na
var box r2Box = na
var box r3Box = na
var box r4Box = na
var box r5Box = na
var box s1Box = na
var box s2Box = na
var box s3Box = na
var box s4Box = na
var box s5Box = na
var box s6Box = na
var box s7Box = na
var box s8Box = na
var box s9Box = na

r1Box := f_update_zone_box(r1Box, r1Low, r1High, showResistance and showReversalZones, bearishZoneColor)
r2Box := f_update_zone_box(r2Box, r2Low, r2High, showResistance and showReversalZones, bearishZoneColor)
r3Box := f_update_zone_box(r3Box, r3Low, r3High, showResistance and showReversalZones, bearishZoneColor)
r4Box := f_update_zone_box(r4Box, r4Low, r4High, showResistance and showReversalZones, bearishZoneColor)
r5Box := f_update_zone_box(r5Box, r5Low, r5High, showResistance and showReversalZones, bearishZoneColor)

s1Box := f_update_zone_box(s1Box, s1Low, s1High, showSupport and showReversalZones, bullishZoneColor)
s2Box := f_update_zone_box(s2Box, s2Low, s2High, showSupport and showReversalZones, bullishZoneColor)
s3Box := f_update_zone_box(s3Box, s3Low, s3High, showSupport and showReversalZones, bullishZoneColor)
s4Box := f_update_zone_box(s4Box, s4Low, s4High, showSupport and showReversalZones, bullishZoneColor)
s5Box := f_update_zone_box(s5Box, s5Low, s5High, showSupport and showReversalZones, bullishZoneColor)
s6Box := f_update_zone_box(s6Box, s6Low, s6High, showSupport and showReversalZones, bullishZoneColor)
s7Box := f_update_zone_box(s7Box, s7Low, s7High, showSupport and showReversalZones, bullishZoneColor)
s8Box := f_update_zone_box(s8Box, s8Low, s8High, showSupport and showReversalZones, bullishZoneColor)
s9Box := f_update_zone_box(s9Box, s9Low, s9High, showSupport and showReversalZones, bullishZoneColor)

// Confluence labels
var label r1Label = na
var label r2Label = na
var label r3Label = na
var label r4Label = na
var label r5Label = na
var label s1Label = na
var label s2Label = na
var label s3Label = na
var label s4Label = na
var label s5Label = na
var label s6Label = na
var label s7Label = na
var label s8Label = na
var label s9Label = na

r1Label := f_update_zone_label(r1Label, "R1", r1Low, r1High, r1Confluence, showResistance and showConfluenceLabels, color.white, confluenceTextSize)
r2Label := f_update_zone_label(r2Label, "R2", r2Low, r2High, r2Confluence, showResistance and showConfluenceLabels, color.white, confluenceTextSize)
r3Label := f_update_zone_label(r3Label, "R3", r3Low, r3High, r3Confluence, showResistance and showConfluenceLabels, color.white, confluenceTextSize)
r4Label := f_update_zone_label(r4Label, "R4", r4Low, r4High, r4Confluence, showResistance and showConfluenceLabels, color.white, confluenceTextSize)
r5Label := f_update_zone_label(r5Label, "R5", r5Low, r5High, r5Confluence, showResistance and showConfluenceLabels, color.white, confluenceTextSize)

s1Label := f_update_zone_label(s1Label, "S1", s1Low, s1High, s1Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s2Label := f_update_zone_label(s2Label, "S2", s2Low, s2High, s2Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s3Label := f_update_zone_label(s3Label, "S3", s3Low, s3High, s3Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s4Label := f_update_zone_label(s4Label, "S4", s4Low, s4High, s4Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s5Label := f_update_zone_label(s5Label, "S5", s5Low, s5High, s5Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s6Label := f_update_zone_label(s6Label, "S6", s6Low, s6High, s6Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s7Label := f_update_zone_label(s7Label, "S7", s7Low, s7High, s7Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s8Label := f_update_zone_label(s8Label, "S8", s8Low, s8High, s8Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s9Label := f_update_zone_label(s9Label, "S9", s9Low, s9High, s9Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)

//=============================================================================
// BUILD LEVEL ARRAYS FOR SIGNALS AND TARGETS
//=============================================================================
array<float> resistanceLowerLevels = array.from(r1Low, r2Low, r3Low, r4Low, r5Low)
array<float> resistanceUpperLevels = array.from(r1High, r2High, r3High, r4High, r5High)
array<float> resistanceTargets = array.from(
     r1Low, r1High,
     r2Low, r2High,
     r3Low, r3High,
     r4Low, r4High,
     r5Low, r5High)

array<float> supportLowerLevels = array.from(s1Low, s2Low, s3Low, s4Low, s5Low, s6Low, s7Low, s8Low, s9Low)
array<float> supportUpperLevels = array.from(s1High, s2High, s3High, s4High, s5High, s6High, s7High, s8High, s9High)
array<float> supportTargets = array.from(
     s1Low, s1High,
     s2Low, s2High,
     s3Low, s3High,
     s4Low, s4High,
     s5Low, s5High,
     s6Low, s6High,
     s7Low, s7High,
     s8Low, s8High,
     s9Low, s9High)

//=============================================================================
// REVERSAL ENTRY LOGIC ACROSS ALL ZONES
//=============================================================================
bool anyBullishReclaim = false
for i = 0 to array.size(supportLowerLevels) - 1
    float zoneLow = array.get(supportLowerLevels, i)
    float zoneHigh = array.get(supportUpperLevels, i)
    anyBullishReclaim := anyBullishReclaim or f_bullish_reclaim(zoneLow, zoneHigh)

bool anyBearishReject = false
for i = 0 to array.size(resistanceLowerLevels) - 1
    float zoneLow = array.get(resistanceLowerLevels, i)
    float zoneHigh = array.get(resistanceUpperLevels, i)
    anyBearishReject := anyBearishReject or f_bearish_reject(zoneLow, zoneHigh)

bool bullishReversalEntry =
     enableReversalEntries and
     anyBullishReclaim and
     close > open and
     close > ema9 and
     longVWAPOk and
     longVIXOk

bool bearishReversalEntry =
     enableReversalEntries and
     anyBearishReject and
     close < open and
     close < ema9 and
     shortVWAPOk and
     shortVIXOk

//=============================================================================
// BREAKOUT / BREAKDOWN RETEST LOGIC ACROSS ALL ZONES
//=============================================================================
var bool longBreakoutArmed = false
var float longBreakoutLevel = na
var int longBreakoutBar = na

var bool shortBreakdownArmed = false
var float shortBreakdownLevel = na
var int shortBreakdownBar = na

bool bullishBreakoutTrigger = false
float newlyBrokenResistance = na

if enableBreakoutRetests
    for i = 0 to array.size(resistanceUpperLevels) - 1
        float zoneTop = array.get(resistanceUpperLevels, i)
        bool brokeThisZone = close > zoneTop and close[1] <= zoneTop
        if brokeThisZone and (na(newlyBrokenResistance) or zoneTop > newlyBrokenResistance)
            bullishBreakoutTrigger := true
            newlyBrokenResistance := zoneTop

bool bearishBreakdownTrigger = false
float newlyBrokenSupport = na

if enableBreakoutRetests
    for i = 0 to array.size(supportLowerLevels) - 1
        float zoneBottom = array.get(supportLowerLevels, i)
        bool brokeThisZone = close < zoneBottom and close[1] >= zoneBottom
        if brokeThisZone and (na(newlyBrokenSupport) or zoneBottom < newlyBrokenSupport)
            bearishBreakdownTrigger := true
            newlyBrokenSupport := zoneBottom

if barstate.isconfirmed and bullishBreakoutTrigger
    longBreakoutArmed := true
    longBreakoutLevel := newlyBrokenResistance
    longBreakoutBar := bar_index

if barstate.isconfirmed and bearishBreakdownTrigger
    shortBreakdownArmed := true
    shortBreakdownLevel := newlyBrokenSupport
    shortBreakdownBar := bar_index

if longBreakoutArmed
    bool expired = bar_index - longBreakoutBar > retestWindowBars
    bool failed = close < longBreakoutLevel - retestTolerancePoints
    if expired or failed
        longBreakoutArmed := false

if shortBreakdownArmed
    bool expired = bar_index - shortBreakdownBar > retestWindowBars
    bool failed = close > shortBreakdownLevel + retestTolerancePoints
    if expired or failed
        shortBreakdownArmed := false

bool bullishBreakoutRetestEntry =
     longBreakoutArmed and
     bar_index > longBreakoutBar and
     low <= longBreakoutLevel + retestTolerancePoints and
     close > longBreakoutLevel and
     close > open and
     close > ema9 and
     longVWAPOk and
     longVIXOk

bool bearishBreakdownRetestEntry =
     shortBreakdownArmed and
     bar_index > shortBreakdownBar and
     high >= shortBreakdownLevel - retestTolerancePoints and
     close < shortBreakdownLevel and
     close < open and
     close < ema9 and
     shortVWAPOk and
     shortVIXOk

if barstate.isconfirmed and bullishBreakoutRetestEntry
    longBreakoutArmed := false

if barstate.isconfirmed and bearishBreakdownRetestEntry
    shortBreakdownArmed := false

//=============================================================================
// EMA TREND-PULLBACK ENTRIES
//=============================================================================
bool bullishTrendPullbackEntry =
     enableTrendPullbacks and
     bullishStack and
     low <= ema20 and
     ta.crossover(close, ema9) and
     longVWAPOk and
     longVIXOk

bool bearishTrendPullbackEntry =
     enableTrendPullbacks and
     bearishStack and
     high >= ema20 and
     ta.crossunder(close, ema9) and
     shortVWAPOk and
     shortVIXOk

//=============================================================================
// FINAL CONFIRMED SIGNALS
//=============================================================================
bool rawLongEntry =
     bullishReversalEntry or
     bullishBreakoutRetestEntry or
     bullishTrendPullbackEntry

bool rawShortEntry =
     bearishReversalEntry or
     bearishBreakdownRetestEntry or
     bearishTrendPullbackEntry

var int lastSignalBar = na
bool cooldownComplete = na(lastSignalBar) or bar_index - lastSignalBar > signalCooldownBars

bool longEntry =
     barstate.isconfirmed and
     rawLongEntry and
     not rawShortEntry and
     cooldownComplete

bool shortEntry =
     barstate.isconfirmed and
     rawShortEntry and
     not rawLongEntry and
     cooldownComplete

if longEntry or shortEntry
    lastSignalBar := bar_index

plotshape(
     longEntry,
     title = "Bullish Entry",
     style = shape.arrowup,
     location = location.belowbar,
     color = color.lime,
     size = size.small)

plotshape(
     shortEntry,
     title = "Bearish Entry",
     style = shape.arrowdown,
     location = location.abovebar,
     color = color.red,
     size = size.small)

//=============================================================================
// TARGETS — PURPLE
//=============================================================================
var line target1Line = na
var line target2Line = na
var label target1Label = na
var label target2Label = na

if longEntry or shortEntry
    if not na(target1Line)
        line.delete(target1Line)
        target1Line := na
    if not na(target2Line)
        line.delete(target2Line)
        target2Line := na
    if not na(target1Label)
        label.delete(target1Label)
        target1Label := na
    if not na(target2Label)
        label.delete(target2Label)
        target2Label := na

    float target1 = na
    float target2 = na

    if longEntry
        [nearest1, nearest2] = f_two_nearest_above(resistanceTargets, close)
        target1 := na(nearest1) ? close + atr * fallbackTarget1ATR : nearest1
        target2 := na(nearest2) ? close + atr * fallbackTarget2ATR : nearest2

    if shortEntry
        [nearest1, nearest2] = f_two_nearest_below(supportTargets, close)
        target1 := na(nearest1) ? close - atr * fallbackTarget1ATR : nearest1
        target2 := na(nearest2) ? close - atr * fallbackTarget2ATR : nearest2

    target1Line := line.new(
         bar_index,
         target1,
         bar_index + 1,
         target1,
         xloc = xloc.bar_index,
         extend = extend.right,
         color = color.purple,
         width = 2)

    target1Label := label.new(
         bar_index + 1,
         target1,
         "T1 " + str.tostring(target1, format.mintick),
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.purple,
         textcolor = color.white,
         size = size.tiny)

    if showSecondTarget
        target2Line := line.new(
             bar_index,
             target2,
             bar_index + 1,
             target2,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.purple,
             style = line.style_dashed,
             width = 2)

        target2Label := label.new(
             bar_index + 1,
             target2,
             "T2 " + str.tostring(target2, format.mintick),
             xloc = xloc.bar_index,
             yloc = yloc.price,
             style = label.style_label_left,
             color = color.purple,
             textcolor = color.white,
             size = size.tiny)

// Keep target labels pinned near the right edge.
if not na(target1Label)
    label.set_x(target1Label, bar_index + labelOffsetBars)

if not na(target2Label)
    label.set_x(target2Label, bar_index + labelOffsetBars)

//=============================================================================
// ALERTS
//=============================================================================
alertcondition(
     longEntry,
     title = "NQ Bullish Entry",
     message = "NQ bullish strategy trigger and entry confirmed on {{ticker}} at {{close}}.")

alertcondition(
     shortEntry,
     title = "NQ Bearish Entry",
     message = "NQ bearish strategy trigger and entry confirmed on {{ticker}} at {{close}}.")
````
