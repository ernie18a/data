<!-- tradingview-pine-id: PUB;74dd31dba4c74a3290a323fbee59bd22 -->
<!-- tradingviewscripts-format: 1 -->
# BigE Signals

Source: https://www.tradingview.com/script/6TB5p9KT-BigE-Support-and-Resistance/

## Description

BigE Signals is a multi-timeframe trade-planning and signal indicator designed primarily for Nasdaq-100 futures traders. It identifies when specific bullish or bearish strategies are approaching, developing, or confirmed—rather than placing signals on every green or red candle.

The indicator combines price structure, EMA alignment, VWAP positioning, predefined support and resistance zones, higher-timeframe trend confirmation, volatility conditions, candle rejection patterns, and breakout/retest logic. Signals are organized into two stages:

WATCH signals alert traders when price enters a qualified strategy zone and the required setup conditions are beginning to form.
ENTRY signals appear only after the strategy receives additional confirmation, such as a reclaim, rejection, breakout, breakdown, or successful retest.

---

## Source Code

````pine
//@version=6
indicator(
     "BigE Signals",
     shorttitle = "BigE Signals",
     overlay = true,
     max_lines_count = 120,
     max_boxes_count = 60,
     max_labels_count = 120)

//=============================================================================
// PURPOSE
//=============================================================================
// BigE Signals v16 updates the August 5, 2026 midday failed-breakout plan, uses confirmed higher-timeframe data, and keeps WATCH/ENTRY signals tied to the exact published strategy zones.
// Each zone has:
//   • Orange horizontal lines at BOTH zone boundaries.
//   • A right-side text label showing the range and confluence.
//   • White shading for bearish reversal zones.
//   • Yellow shading for bullish reversal zones.
//
// It also plots:
//   • Overnight high/low in blue.
//   • Real-time bullish/bearish setup warnings before confirmation.
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
float r1Low = input.float(29780.00, "R1 lower boundary", step = 0.25, group = GROUP_R1)
float r1High = input.float(29805.00, "R1 upper boundary", step = 0.25, group = GROUP_R1)
string r1Confluence = input.string(
     "Immediate failed-bounce zone: 1m/5m EMA cluster + broken intraday support near 29780-29805",
     "R1 confluence",
     group = GROUP_R1)

string GROUP_R2 = "4. Resistance R2"
float r2Low = input.float(29830.00, "R2 lower boundary", step = 0.25, group = GROUP_R2)
float r2High = input.float(29860.00, "R2 upper boundary", step = 0.25, group = GROUP_R2)
string r2Confluence = input.string(
     "5m EMA 200 + 15m EMA 20/50 and high-volume resistance near 29830-29860",
     "R2 confluence",
     group = GROUP_R2)

string GROUP_R3 = "5. Resistance R3"
float r3Low = input.float(29880.00, "R3 lower boundary", step = 0.25, group = GROUP_R3)
float r3High = input.float(29915.00, "R3 upper boundary", step = 0.25, group = GROUP_R3)
string r3Confluence = input.string(
     "15m/30m VWAP cluster + overnight pivot/POC and 29911 reference",
     "R3 confluence",
     group = GROUP_R3)

string GROUP_R4 = "6. Resistance R4"
float r4Low = input.float(29960.00, "R4 lower boundary", step = 0.25, group = GROUP_R4)
float r4High = input.float(29985.00, "R4 upper boundary", step = 0.25, group = GROUP_R4)
string r4Confluence = input.string(
     "Failed-breakout base + 1h volatility band and prior 29978 resistance",
     "R4 confluence",
     group = GROUP_R4)

string GROUP_R5 = "7. Resistance R5"
float r5Low = input.float(30000.00, "R5 lower boundary", step = 0.25, group = GROUP_R5)
float r5High = input.float(30020.00, "R5 upper boundary", step = 0.25, group = GROUP_R5)
string r5Confluence = input.string(
     "Psychological 30000 + prior-day high near 30012.50",
     "R5 confluence",
     group = GROUP_R5)

string GROUP_R6 = "8. Resistance R6"
float r6Low = input.float(30045.00, "R6 lower boundary", step = 0.25, group = GROUP_R6)
float r6High = input.float(30065.00, "R6 upper boundary", step = 0.25, group = GROUP_R6)
string r6Confluence = input.string(
     "Current-session high near 30059 + major failed-breakout liquidity",
     "R6 confluence",
     group = GROUP_R6)

//=============================================================================
// MAJOR SUPPORT ZONES
//=============================================================================
string GROUP_S1 = "9. Support S1"
float s1Low = input.float(29740.00, "S1 lower boundary", step = 0.25, group = GROUP_S1)
float s1High = input.float(29760.00, "S1 upper boundary", step = 0.25, group = GROUP_S1)
string s1Confluence = input.string(
     "Current intraday low shelf + 30m EMA 50 and descending-channel support",
     "S1 confluence",
     group = GROUP_S1)

string GROUP_S2 = "10. Support S2"
float s2Low = input.float(29705.00, "S2 lower boundary", step = 0.25, group = GROUP_S2)
float s2High = input.float(29725.00, "S2 upper boundary", step = 0.25, group = GROUP_S2)
string s2Confluence = input.string(
     "Morning swing-low liquidity + lower 15m/30m channel support",
     "S2 confluence",
     group = GROUP_S2)

string GROUP_S3 = "11. Support S3"
float s3Low = input.float(29650.00, "S3 lower boundary", step = 0.25, group = GROUP_S3)
float s3High = input.float(29680.00, "S3 upper boundary", step = 0.25, group = GROUP_S3)
string s3Confluence = input.string(
     "Measured intraday extension + round-number demand beneath the morning low",
     "S3 confluence",
     group = GROUP_S3)

string GROUP_S4 = "12. Support S4"
float s4Low = input.float(29475.00, "S4 lower boundary", step = 0.25, group = GROUP_S4)
float s4High = input.float(29510.00, "S4 upper boundary", step = 0.25, group = GROUP_S4)
string s4Confluence = input.string(
     "1h EMA 50 near 29492 + prior breakout structure",
     "S4 confluence",
     group = GROUP_S4)

string GROUP_S5 = "13. Support S5"
float s5Low = input.float(29240.00, "S5 lower boundary", step = 0.25, group = GROUP_S5)
float s5High = input.float(29280.00, "S5 upper boundary", step = 0.25, group = GROUP_S5)
string s5Confluence = input.string(
     "4h EMA 20 near 29260 + higher-timeframe pullback demand",
     "S5 confluence",
     group = GROUP_S5)

string GROUP_S6 = "14. Support S6"
float s6Low = input.float(29100.00, "S6 lower boundary", step = 0.25, group = GROUP_S6)
float s6High = input.float(29125.00, "S6 upper boundary", step = 0.25, group = GROUP_S6)
string s6Confluence = input.string(
     "4h EMA 200/reclaimed pivot near 29110-29117",
     "S6 confluence",
     group = GROUP_S6)

string GROUP_S7 = "15. Support S7"
float s7Low = input.float(28980.00, "S7 lower boundary", step = 0.25, group = GROUP_S7)
float s7High = input.float(29020.00, "S7 upper boundary", step = 0.25, group = GROUP_S7)
string s7Confluence = input.string(
     "Daily EMA cluster + psychological 29000",
     "S7 confluence",
     group = GROUP_S7)

string GROUP_S8 = "16. Support S8"
float s8Low = input.float(28830.00, "S8 lower boundary", step = 0.25, group = GROUP_S8)
float s8High = input.float(28890.00, "S8 upper boundary", step = 0.25, group = GROUP_S8)
string s8Confluence = input.string(
     "4h EMA 50 + deeper reclaimed swing structure",
     "S8 confluence",
     group = GROUP_S8)

string GROUP_S9 = "17. Support S9"
float s9Low = input.float(28280.00, "S9 lower boundary", step = 0.25, group = GROUP_S9)
float s9High = input.float(28330.00, "S9 upper boundary", step = 0.25, group = GROUP_S9)
string s9Confluence = input.string(
     "Weekly EMA 20 near 28308 + major swing demand",
     "S9 confluence",
     group = GROUP_S9)

string GROUP_S10 = "18. Support S10"
float s10Low = input.float(26900.00, "S10 lower boundary", step = 0.25, group = GROUP_S10)
float s10High = input.float(26950.00, "S10 upper boundary", step = 0.25, group = GROUP_S10)
string s10Confluence = input.string(
     "Daily EMA 200 near 26922 + long-term structural support",
     "S10 confluence",
     group = GROUP_S10)

// Current chart-plan context — August 5, 2026, 12:17 CT:
//   Immediate bias: intraday bearish below 29780-29805 after the rejection from 30059.
//   Recovery sequence: reclaim 29805, then 29830-29860, then 29880-29915 before treating the decline as repaired.
//   Higher timeframe: 4h/daily/weekly structure remains broadly bullish above 29695 and the 29240-29280 demand zone.
//   VIX has fallen toward 18.29, which supports stabilization, but Nasdaq breadth near -762 remains weak.
//   Preferred execution: short failed bounces into resistance; buy only a confirmed support sweep/reclaim or resistance breakout-retest.
//   Strategy arrows remain conditional and print only after confirmed entries.

//=============================================================================
// EARLY SETUP SIGNALS
//=============================================================================
string GROUP_EARLY = "19. Early Setup Signals"
bool enableEarlySetupSignals = input.bool(
     true,
     "Enable setup-forming warnings",
     tooltip = "Signals when price is approaching a level and the setup conditions are beginning to align. This is an early warning, not a confirmed entry.",
     group = GROUP_EARLY)
string setupDistanceMode = input.string(
     "Fixed points",
     "Setup proximity method",
     options = ["Fixed points", "ATR"],
     group = GROUP_EARLY)
float setupProximityPoints = input.float(
     6.0,
     "Setup proximity (points)",
     minval = 0.25,
     step = 0.25,
     group = GROUP_EARLY)
float setupProximityATR = input.float(
     0.30,
     "Setup proximity (ATR multiplier)",
     minval = 0.05,
     step = 0.05,
     group = GROUP_EARLY)
bool showLiveSetupLabel = input.bool(
     true,
     "Show current setup-status label",
     group = GROUP_EARLY)
string signalDisplayMode = input.string(
     "Recent signals",
     "Signal display mode",
     options = ["Realtime only", "Recent signals", "All history"],
     tooltip = "Recent signals prevents a confirmed arrow from disappearing as soon as the next bar opens.",
     group = GROUP_EARLY)
int recentSignalBars = input.int(
     150,
     "Recent signal lookback (bars)",
     minval = 10,
     maxval = 5000,
     group = GROUP_EARLY)
bool showSignalDiagnostics = input.bool(
     false,
     "Show signal diagnostics in live label",
     tooltip = "Adds bullish/bearish setup scores and filter status to the current setup label.",
     group = GROUP_EARLY)
bool enableIntrabarSetupAlerts = input.bool(
     true,
     "Enable intrabar alert() calls",
     tooltip = "Create an alert using 'Any alert() function call' to receive setup-forming warnings during the live bar.",
     group = GROUP_EARLY)
bool strictStrategyWatchMode = input.bool(
     true,
     "Strict strategy-specific WATCH logic",
     tooltip = "When enabled, WATCH markers only appear near the exact support/resistance zones and trigger sequences from the current technical plan.",
     group = GROUP_EARLY)
float breakoutWatchDistance = input.float(
     2.0,
     "Breakout WATCH distance (points)",
     minval = 0.25,
     step = 0.25,
     tooltip = "Maximum distance from the exact breakout or breakdown trigger before a WATCH can appear.",
     group = GROUP_EARLY)
float minimumRejectionWickRatio = input.float(
     0.20,
     "Minimum rejection-wick ratio",
     minval = 0.0,
     maxval = 0.80,
     step = 0.05,
     tooltip = "Requires a meaningful rejection wick for reversal WATCH signals. A value of 0.20 means the wick must be at least 20% of the candle range.",
     group = GROUP_EARLY)
int watchCooldownBars = input.int(
     10,
     "WATCH cooldown (bars)",
     minval = 0,
     maxval = 100,
     tooltip = "Prevents the same directional WATCH from printing repeatedly while price remains in the same setup area.",
     group = GROUP_EARLY)

//=============================================================================
// STRATEGY INPUTS
//=============================================================================
string GROUP_SIGNALS = "20. Strategy Triggers"
bool enableReversalEntries = input.bool(true, "Reversal / mean-reversion entries", group = GROUP_SIGNALS)
bool enableBreakoutRetests = input.bool(true, "Breakout/breakdown retest entries", group = GROUP_SIGNALS)
bool enableTrendPullbacks = input.bool(true, "EMA trend-pullback entries", group = GROUP_SIGNALS)
bool strictStrategyEntryMode = input.bool(
     true,
     "Require entry to match an active plan zone",
     tooltip = "Prevents generic EMA pullback arrows away from the support/resistance zones in the current technical plan.",
     group = GROUP_SIGNALS)
bool requireRecentWatchForEntry = input.bool(
     true,
     "Require a recent WATCH before ENTRY",
     tooltip = "When enabled, a confirmed arrow must follow a strategy-specific WATCH within the selected number of bars.",
     group = GROUP_SIGNALS)
int watchToEntryWindowBars = input.int(
     12,
     "WATCH-to-ENTRY window (bars)",
     minval = 1,
     maxval = 100,
     group = GROUP_SIGNALS)
int retestWindowBars = input.int(8, "Retest window (bars)", minval = 1, maxval = 50, group = GROUP_SIGNALS)
float retestTolerancePoints = input.float(6.0, "Retest tolerance (points)", minval = 0.25, step = 0.25, group = GROUP_SIGNALS)
int signalCooldownBars = input.int(5, "Minimum bars between arrows", minval = 0, maxval = 100, group = GROUP_SIGNALS)
bool useVWAPFilter = input.bool(true, "Use VWAP confirmation", group = GROUP_SIGNALS)
bool useVIXFilter = input.bool(true, "Use VIX direction confirmation", group = GROUP_SIGNALS)
float vixNeutralBand = input.float(
     0.05,
     "VIX neutral band",
     minval = 0.0,
     step = 0.01,
     tooltip = "Allows both directions when VIX is very close to its EMA 9, preventing one-tick changes from suppressing bullish or bearish signals.",
     group = GROUP_SIGNALS)
string vixSymbol = input.symbol("CBOE:VIX", "VIX symbol", group = GROUP_SIGNALS)
string vixTimeframe = input.timeframe("15", "VIX timeframe", group = GROUP_SIGNALS)
bool useHigherTimeframeTrendFilter = input.bool(
     true,
     "Use higher-timeframe trend confirmation",
     tooltip = "Applies the selected higher-timeframe EMA trend to breakout and trend-pullback WATCH/ENTRY signals. Reversal and mean-reversion signals remain available.",
     group = GROUP_SIGNALS)
string higherTimeframe = input.timeframe(
     "30",
     "Higher-timeframe confirmation",
     group = GROUP_SIGNALS)

//=============================================================================
// TARGET INPUTS
//=============================================================================
string GROUP_TARGETS = "21. Targets"
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

f_price_near_zone(float zoneLow, float zoneHigh, float proximity) =>
    float lowerPrice = math.min(zoneLow, zoneHigh)
    float upperPrice = math.max(zoneLow, zoneHigh)
    close >= lowerPrice - proximity and close <= upperPrice + proximity

f_price_approaching_zone_from_below(float zoneLow, float zoneHigh, float proximity) =>
    float lowerPrice = math.min(zoneLow, zoneHigh)
    close < lowerPrice and close >= lowerPrice - proximity

f_price_approaching_zone_from_above(float zoneLow, float zoneHigh, float proximity) =>
    float upperPrice = math.max(zoneLow, zoneHigh)
    close > upperPrice and close <= upperPrice + proximity

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
float setupProximity = setupDistanceMode == "ATR" ? atr * setupProximityATR : setupProximityPoints
float ema9 = ta.ema(close, 9)
float ema20 = ta.ema(close, 20)
float ema50 = ta.ema(close, 50)
float vwapValue = ta.vwap(hlc3)

float vixClose = request.security(vixSymbol, vixTimeframe, close, lookahead = barmerge.lookahead_off)
float vixEMA9 = request.security(vixSymbol, vixTimeframe, ta.ema(close, 9), lookahead = barmerge.lookahead_off)

// Use the last completed higher-timeframe bar so HTF direction does not
// fluctuate or repaint while the current higher-timeframe candle is forming.
float htfClose = request.security(
     syminfo.tickerid,
     higherTimeframe,
     close[1],
     lookahead = barmerge.lookahead_on)
float htfEMA9 = request.security(
     syminfo.tickerid,
     higherTimeframe,
     ta.ema(close, 9)[1],
     lookahead = barmerge.lookahead_on)
float htfEMA20 = request.security(
     syminfo.tickerid,
     higherTimeframe,
     ta.ema(close, 20)[1],
     lookahead = barmerge.lookahead_on)

bool longHTFTrendOk =
     not useHigherTimeframeTrendFilter or
     na(htfClose) or
     na(htfEMA9) or
     na(htfEMA20) or
     (htfClose >= htfEMA20 and htfEMA9 >= htfEMA20)

bool shortHTFTrendOk =
     not useHigherTimeframeTrendFilter or
     na(htfClose) or
     na(htfEMA9) or
     na(htfEMA20) or
     (htfClose <= htfEMA20 and htfEMA9 <= htfEMA20)

bool longVWAPOk = not useVWAPFilter or na(vwapValue) or close > vwapValue
bool shortVWAPOk = not useVWAPFilter or na(vwapValue) or close < vwapValue
bool longVIXOk =
     not useVIXFilter or
     na(vixClose) or
     na(vixEMA9) or
     vixClose <= vixEMA9 + vixNeutralBand

bool shortVIXOk =
     not useVIXFilter or
     na(vixClose) or
     na(vixEMA9) or
     vixClose >= vixEMA9 - vixNeutralBand

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
var line r6LowLine = na
var line r6HighLine = na

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
r6LowLine := f_update_line(r6LowLine, r6Low, showResistance, srColor, lineWidth)
r6HighLine := f_update_line(r6HighLine, r6High, showResistance, srColor, lineWidth)

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
var line s10LowLine = na
var line s10HighLine = na

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
s10LowLine := f_update_line(s10LowLine, s10Low, showSupport, srColor, lineWidth)
s10HighLine := f_update_line(s10HighLine, s10High, showSupport, srColor, lineWidth)

// Shaded reversal zones
var box r1Box = na
var box r2Box = na
var box r3Box = na
var box r4Box = na
var box r5Box = na
var box r6Box = na
var box s1Box = na
var box s2Box = na
var box s3Box = na
var box s4Box = na
var box s5Box = na
var box s6Box = na
var box s7Box = na
var box s8Box = na
var box s9Box = na
var box s10Box = na

r1Box := f_update_zone_box(r1Box, r1Low, r1High, showResistance and showReversalZones, bearishZoneColor)
r2Box := f_update_zone_box(r2Box, r2Low, r2High, showResistance and showReversalZones, bearishZoneColor)
r3Box := f_update_zone_box(r3Box, r3Low, r3High, showResistance and showReversalZones, bearishZoneColor)
r4Box := f_update_zone_box(r4Box, r4Low, r4High, showResistance and showReversalZones, bearishZoneColor)
r5Box := f_update_zone_box(r5Box, r5Low, r5High, showResistance and showReversalZones, bearishZoneColor)
r6Box := f_update_zone_box(r6Box, r6Low, r6High, showResistance and showReversalZones, bearishZoneColor)

s1Box := f_update_zone_box(s1Box, s1Low, s1High, showSupport and showReversalZones, bullishZoneColor)
s2Box := f_update_zone_box(s2Box, s2Low, s2High, showSupport and showReversalZones, bullishZoneColor)
s3Box := f_update_zone_box(s3Box, s3Low, s3High, showSupport and showReversalZones, bullishZoneColor)
s4Box := f_update_zone_box(s4Box, s4Low, s4High, showSupport and showReversalZones, bullishZoneColor)
s5Box := f_update_zone_box(s5Box, s5Low, s5High, showSupport and showReversalZones, bullishZoneColor)
s6Box := f_update_zone_box(s6Box, s6Low, s6High, showSupport and showReversalZones, bullishZoneColor)
s7Box := f_update_zone_box(s7Box, s7Low, s7High, showSupport and showReversalZones, bullishZoneColor)
s8Box := f_update_zone_box(s8Box, s8Low, s8High, showSupport and showReversalZones, bullishZoneColor)
s9Box := f_update_zone_box(s9Box, s9Low, s9High, showSupport and showReversalZones, bullishZoneColor)
s10Box := f_update_zone_box(s10Box, s10Low, s10High, showSupport and showReversalZones, bullishZoneColor)

// Confluence labels
var label r1Label = na
var label r2Label = na
var label r3Label = na
var label r4Label = na
var label r5Label = na
var label r6Label = na
var label s1Label = na
var label s2Label = na
var label s3Label = na
var label s4Label = na
var label s5Label = na
var label s6Label = na
var label s7Label = na
var label s8Label = na
var label s9Label = na
var label s10Label = na

r1Label := f_update_zone_label(r1Label, "R1", r1Low, r1High, r1Confluence, showResistance and showConfluenceLabels, color.white, confluenceTextSize)
r2Label := f_update_zone_label(r2Label, "R2", r2Low, r2High, r2Confluence, showResistance and showConfluenceLabels, color.white, confluenceTextSize)
r3Label := f_update_zone_label(r3Label, "R3", r3Low, r3High, r3Confluence, showResistance and showConfluenceLabels, color.white, confluenceTextSize)
r4Label := f_update_zone_label(r4Label, "R4", r4Low, r4High, r4Confluence, showResistance and showConfluenceLabels, color.white, confluenceTextSize)
r5Label := f_update_zone_label(r5Label, "R5", r5Low, r5High, r5Confluence, showResistance and showConfluenceLabels, color.white, confluenceTextSize)
r6Label := f_update_zone_label(r6Label, "R6", r6Low, r6High, r6Confluence, showResistance and showConfluenceLabels, color.white, confluenceTextSize)

s1Label := f_update_zone_label(s1Label, "S1", s1Low, s1High, s1Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s2Label := f_update_zone_label(s2Label, "S2", s2Low, s2High, s2Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s3Label := f_update_zone_label(s3Label, "S3", s3Low, s3High, s3Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s4Label := f_update_zone_label(s4Label, "S4", s4Low, s4High, s4Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s5Label := f_update_zone_label(s5Label, "S5", s5Low, s5High, s5Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s6Label := f_update_zone_label(s6Label, "S6", s6Low, s6High, s6Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s7Label := f_update_zone_label(s7Label, "S7", s7Low, s7High, s7Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s8Label := f_update_zone_label(s8Label, "S8", s8Low, s8High, s8Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s9Label := f_update_zone_label(s9Label, "S9", s9Low, s9High, s9Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)
s10Label := f_update_zone_label(s10Label, "S10", s10Low, s10High, s10Confluence, showSupport and showConfluenceLabels, color.yellow, confluenceTextSize)

//=============================================================================
// BUILD LEVEL ARRAYS FOR SIGNALS AND TARGETS
//=============================================================================
array<float> resistanceLowerLevels = array.from(r1Low, r2Low, r3Low, r4Low, r5Low, r6Low)
array<float> resistanceUpperLevels = array.from(r1High, r2High, r3High, r4High, r5High, r6High)
array<float> resistanceTargets = array.from(
     r1Low, r1High,
     r2Low, r2High,
     r3Low, r3High,
     r4Low, r4High,
     r5Low, r5High,
     r6Low, r6High)

array<float> supportLowerLevels = array.from(s1Low, s2Low, s3Low, s4Low, s5Low, s6Low, s7Low, s8Low, s9Low, s10Low)
array<float> supportUpperLevels = array.from(s1High, s2High, s3High, s4High, s5High, s6High, s7High, s8High, s9High, s10High)
array<float> supportTargets = array.from(
     s1Low, s1High,
     s2Low, s2High,
     s3Low, s3High,
     s4Low, s4High,
     s5Low, s5High,
     s6Low, s6High,
     s7Low, s7High,
     s8Low, s8High,
     s9Low, s9High,
     s10Low, s10High)

//=============================================================================
// REAL-TIME SETUP-FORMING ENGINE
//=============================================================================
// v16 does not treat ordinary red/green candles as setups. Each WATCH must
// match one of the explicitly published strategies and its exact price zone.
//
// Published long plans:
//   1) Current-low sweep/reclaim at S1.
//   2) Morning-low liquidity sweep/reclaim at S2.
//   3) Deeper intraday reversal at S3.
//   4) Bullish repair breakout/retest through R1.
//   5) Higher-timeframe swing pullback at S4-S10.
//   6) Trend-reversal breakout attempt through R3.
//
// Published short plans:
//   1) Immediate failed bounce/rejection at R1.
//   2) Major resistance rejection at R2-R6.
//   3) Bearish continuation breakdown below S1.
// A normal bearish candle away from these conditions is not a WATCH signal.

float watchCandleRange = math.max(high - low, syminfo.mintick)
float watchUpperWick = high - math.max(open, close)
float watchLowerWick = math.min(open, close) - low
float watchUpperWickRatio = watchUpperWick / watchCandleRange
float watchLowerWickRatio = watchLowerWick / watchCandleRange
float watchCloseLocation = (close - low) / watchCandleRange

bool bullishRejectionDeveloping =
     close > open and
     watchCloseLocation >= 0.58 and
     watchLowerWickRatio >= minimumRejectionWickRatio

bool bearishRejectionDeveloping =
     close < open and
     watchCloseLocation <= 0.42 and
     watchUpperWickRatio >= minimumRejectionWickRatio

bool bullishContinuationDeveloping =
     close > open and
     close >= ema9 and
     watchCloseLocation >= 0.60

bool bearishContinuationDeveloping =
     close < open and
     close <= ema9 and
     watchCloseLocation <= 0.40

// Exact zone interaction states.
bool touchingS1 = f_zone_touched(s1Low, s1High)
bool touchingS2 = f_zone_touched(s2Low, s2High)
bool touchingS3 = f_zone_touched(s3Low, s3High)
bool touchingS4 = f_zone_touched(s4Low, s4High)
bool touchingS5 = f_zone_touched(s5Low, s5High)
bool touchingS6 = f_zone_touched(s6Low, s6High)
bool touchingS7 = f_zone_touched(s7Low, s7High)
bool touchingS8 = f_zone_touched(s8Low, s8High)
bool touchingS9 = f_zone_touched(s9Low, s9High)
bool touchingS10 = f_zone_touched(s10Low, s10High)

bool touchingR1 = f_zone_touched(r1Low, r1High)
bool touchingR2 = f_zone_touched(r2Low, r2High)
bool touchingR3 = f_zone_touched(r3Low, r3High)
bool touchingR4 = f_zone_touched(r4Low, r4High)
bool touchingR5 = f_zone_touched(r5Low, r5High)
bool touchingR6 = f_zone_touched(r6Low, r6High)

bool approachingR1Breakout =
     close < r1High and
     high >= r1Low - breakoutWatchDistance and
     close >= r1Low - breakoutWatchDistance

bool approachingR3Breakout =
     close < r3High and
     high >= r3Low - breakoutWatchDistance and
     close >= r3Low - breakoutWatchDistance

bool approachingS1Breakdown =
     close > s1Low - breakoutWatchDistance and
     low <= s1High + breakoutWatchDistance and
     close <= s1High + breakoutWatchDistance

// Current intraday balance is the area between the morning-low support and
// the first failed-bounce resistance.
bool overnightRangeIntact =
     close > s2Low and
     close < r1High

bool shortTermEMACompression =
     math.abs(ema9 - ema20) <= math.max(setupProximity * 0.75, syminfo.mintick)

//-------------------------------------------------------------------------
// STRATEGY-SPECIFIC LONG WATCHES
//-------------------------------------------------------------------------
bool longImmediatePullbackWatch =
     enableEarlySetupSignals and
     enableReversalEntries and
     touchingS1 and
     bullishRejectionDeveloping and
     close >= s1Low and
     longVIXOk

bool longPrimaryTrendPullbackWatch =
     enableEarlySetupSignals and
     enableReversalEntries and
     touchingS2 and
     bullishRejectionDeveloping and
     close >= s2Low and
     longVIXOk

bool longVWAPReclaimWatch =
     enableEarlySetupSignals and
     enableReversalEntries and
     touchingS3 and
     bullishRejectionDeveloping and
     close >= ema9 - breakoutWatchDistance and
     longVIXOk

bool longBreakoutWatch =
     enableEarlySetupSignals and
     enableBreakoutRetests and
     approachingR1Breakout and
     bullishContinuationDeveloping and
     ema9 >= ema20 and
     close >= r1Low and
     longVIXOk

bool longSwingPullbackWatch =
     enableEarlySetupSignals and
     enableReversalEntries and
     (
         touchingS4 or touchingS5 or touchingS6 or touchingS7 or
         touchingS8 or touchingS9 or touchingS10
     ) and
     bullishRejectionDeveloping and
     longHTFTrendOk and
     longVIXOk

bool longHigherTimeframeBreakoutWatch =
     enableEarlySetupSignals and
     enableBreakoutRetests and
     approachingR3Breakout and
     bullishContinuationDeveloping and
     ema9 >= ema20 and
     longHTFTrendOk and
     longVIXOk

//-------------------------------------------------------------------------
// STRATEGY-SPECIFIC SHORT WATCHES
//-------------------------------------------------------------------------
bool shortOvernightRangeRejectionWatch =
     enableEarlySetupSignals and
     enableReversalEntries and
     touchingR1 and
     overnightRangeIntact and
     bearishRejectionDeveloping and
     ema9 <= ema20 and
     close <= ema20 and
     shortVIXOk

bool shortMajorResistanceRejectionWatch =
     enableEarlySetupSignals and
     enableReversalEntries and
     (
         touchingR2 or touchingR3 or touchingR4 or
         touchingR5 or touchingR6
     ) and
     bearishRejectionDeveloping and
     shortVIXOk

bool shortBreakdownWatch =
     enableEarlySetupSignals and
     enableBreakoutRetests and
     approachingS1Breakdown and
     bearishContinuationDeveloping and
     ema9 <= ema20 and
     close < s1High and
     shortVWAPOk and
     shortVIXOk

// Legacy mode is retained as an optional fallback, but strict mode is the
// default. Even legacy mode now requires a true zone interaction.
bool legacyLongWatch =
     enableEarlySetupSignals and
     (
         (
             touchingS1 or touchingS2 or touchingS3 or touchingS4 or touchingS5 or
             touchingS6 or touchingS7 or touchingS8 or touchingS9 or touchingS10
         ) and
         bullishRejectionDeveloping
     )

bool legacyShortWatch =
     enableEarlySetupSignals and
     (
         (
             touchingR1 or touchingR2 or touchingR3 or
             touchingR4 or touchingR5 or touchingR6
         ) and
         bearishRejectionDeveloping
     )

bool rawLongSetup =
     strictStrategyWatchMode ?
         (
             longImmediatePullbackWatch or
             longPrimaryTrendPullbackWatch or
             longVWAPReclaimWatch or
             longBreakoutWatch or
             longSwingPullbackWatch or
             longHigherTimeframeBreakoutWatch
         ) :
         legacyLongWatch

bool rawShortSetup =
     strictStrategyWatchMode ?
         (
             shortOvernightRangeRejectionWatch or
             shortMajorResistanceRejectionWatch or
             shortBreakdownWatch
         ) :
         legacyShortWatch

int longSetupScore =
     (longImmediatePullbackWatch ? 5 : 0) +
     (longPrimaryTrendPullbackWatch ? 5 : 0) +
     (longVWAPReclaimWatch ? 5 : 0) +
     (longBreakoutWatch ? 6 : 0) +
     (longSwingPullbackWatch ? 5 : 0) +
     (longHigherTimeframeBreakoutWatch ? 6 : 0) +
     (longHTFTrendOk ? 1 : 0) +
     (longVWAPOk ? 1 : 0) +
     (longVIXOk ? 1 : 0)

int shortSetupScore =
     (shortOvernightRangeRejectionWatch ? 5 : 0) +
     (shortMajorResistanceRejectionWatch ? 6 : 0) +
     (shortBreakdownWatch ? 6 : 0) +
     (shortHTFTrendOk ? 1 : 0) +
     (shortVWAPOk ? 1 : 0) +
     (shortVIXOk ? 1 : 0)

bool bullishTieBreaker = close >= ema20 and ema9 >= ema20
bool bearishTieBreaker = close <= ema20 and ema9 <= ema20

bool conflictingSetup = rawLongSetup and rawShortSetup

bool longSetupWinsConflict =
     longSetupScore > shortSetupScore or
     (longSetupScore == shortSetupScore and bullishTieBreaker and not bearishTieBreaker)

bool shortSetupWinsConflict =
     shortSetupScore > longSetupScore or
     (shortSetupScore == longSetupScore and bearishTieBreaker and not bullishTieBreaker)

bool longSetupActive =
     rawLongSetup and
     (not conflictingSetup or longSetupWinsConflict)

bool shortSetupActive =
     rawShortSetup and
     (not conflictingSetup or shortSetupWinsConflict)

string longSetupName =
     longImmediatePullbackWatch ? "CURRENT-LOW RECLAIM LONG FORMING AT S1" :
     longPrimaryTrendPullbackWatch ? "MORNING-LOW SWEEP LONG FORMING AT S2" :
     longVWAPReclaimWatch ? "DEEP SUPPORT RECLAIM LONG FORMING AT S3" :
     longBreakoutWatch ? "BULLISH REPAIR BREAKOUT FORMING THROUGH R1" :
     longSwingPullbackWatch ? "HIGHER-TIMEFRAME PULLBACK LONG FORMING AT S4-S10" :
     "TREND-REVERSAL BREAKOUT LONG FORMING THROUGH R3"

string shortSetupName =
     shortOvernightRangeRejectionWatch ? "FAILED BOUNCE SHORT FORMING AT R1" :
     shortMajorResistanceRejectionWatch ? "MAJOR RESISTANCE REJECTION SHORT FORMING AT R2-R6" :
     "BEARISH CONTINUATION SHORT FORMING BELOW S1"

bool longSetupTransition =
     longSetupActive and
     not longSetupActive[1]

bool shortSetupTransition =
     shortSetupActive and
     not shortSetupActive[1]

var int lastLongWatchBar = na
var int lastShortWatchBar = na

bool longWatchCooldownComplete =
     na(lastLongWatchBar) or
     bar_index - lastLongWatchBar > watchCooldownBars

bool shortWatchCooldownComplete =
     na(lastShortWatchBar) or
     bar_index - lastShortWatchBar > watchCooldownBars

bool longSetupStart =
     longSetupTransition and
     longWatchCooldownComplete

bool shortSetupStart =
     shortSetupTransition and
     shortWatchCooldownComplete

if longSetupStart
    lastLongWatchBar := bar_index

if shortSetupStart
    lastShortWatchBar := bar_index

bool isRecentSignalBar = bar_index >= last_bar_index - recentSignalBars
bool showThisSignalBar =
     signalDisplayMode == "All history" or
     (signalDisplayMode == "Recent signals" and isRecentSignalBar) or
     barstate.isrealtime

bool displayLongSetupMarker =
     longSetupStart and
     showThisSignalBar

bool displayShortSetupMarker =
     shortSetupStart and
     showThisSignalBar

plotshape(
     displayLongSetupMarker,
     title = "Long Strategy Setup Forming",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.aqua,
     size = size.small,
     text = "WATCH",
     textcolor = color.white)

plotshape(
     displayShortSetupMarker,
     title = "Short Strategy Setup Forming",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.orange,
     size = size.small,
     text = "WATCH",
     textcolor = color.white)

// Current-bar setup status. This label updates on realtime price changes.
var label liveSetupStatusLabel = na

if barstate.islast
    if showLiveSetupLabel
        if na(liveSetupStatusLabel)
            liveSetupStatusLabel := label.new(
                 bar_index + 1,
                 close,
                 "",
                 xloc = xloc.bar_index,
                 yloc = yloc.price,
                 style = label.style_label_left,
                 color = color.new(color.gray, 20),
                 textcolor = color.white,
                 size = size.small)

        string baseSetupStatusText =
             longSetupActive ? longSetupName + "\nWait for confirmed green arrow" :
             shortSetupActive ? shortSetupName + "\nWait for confirmed red arrow" :
             "NO ACTIVE SETUP\nWaiting for an exact strategy zone and trigger sequence"

        string diagnosticText =
             "\nStrict WATCH/ENTRY: " +
             (strictStrategyWatchMode ? "ON" : "OFF") + "/" +
             (strictStrategyEntryMode ? "ON" : "OFF") +
             "\nRecent WATCH required: " +
             (requireRecentWatchForEntry ? "YES" : "NO") +
             "\nSetup score L/S: " +
             str.tostring(longSetupScore) + "/" +
             str.tostring(shortSetupScore) +
             "\nHTF L/S: " +
             (longHTFTrendOk ? "Y" : "N") + "/" +
             (shortHTFTrendOk ? "Y" : "N") +
             " | VIX L/S: " +
             (longVIXOk ? "Y" : "N") + "/" +
             (shortVIXOk ? "Y" : "N")

        string setupStatusText =
             showSignalDiagnostics ? baseSetupStatusText + diagnosticText : baseSetupStatusText

        color setupStatusColor =
             longSetupActive ? color.new(color.teal, 10) :
             shortSetupActive ? color.new(color.orange, 10) :
             color.new(color.gray, 35)

        label.set_x(liveSetupStatusLabel, bar_index + 1)
        label.set_y(liveSetupStatusLabel, close)
        label.set_text(liveSetupStatusLabel, setupStatusText)
        label.set_color(liveSetupStatusLabel, setupStatusColor)
        label.set_textcolor(liveSetupStatusLabel, color.white)
    else
        if not na(liveSetupStatusLabel)
            label.delete(liveSetupStatusLabel)
            liveSetupStatusLabel := na

// Intrabar alerts notify as soon as the setup first becomes active on a live bar.
// In TradingView, create an alert using: BigE Signals > Any alert() function call.
if enableIntrabarSetupAlerts and barstate.isrealtime and longSetupStart
    alert(
         "BigE Signals | STRATEGY-GATED LONG WATCH | " +
         syminfo.ticker + " | Price " +
         str.tostring(close, format.mintick) + " | " +
         longSetupName,
         alert.freq_once_per_bar)

if enableIntrabarSetupAlerts and barstate.isrealtime and shortSetupStart
    alert(
         "BigE Signals | STRATEGY-GATED SHORT WATCH | " +
         syminfo.ticker + " | Price " +
         str.tostring(close, format.mintick) + " | " +
         shortSetupName,
         alert.freq_once_per_bar)

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
     longVIXOk

bool bearishReversalEntry =
     enableReversalEntries and
     anyBearishReject and
     close < open and
     close < ema9 and
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
     longVIXOk and
     longHTFTrendOk

bool bearishBreakdownRetestEntry =
     shortBreakdownArmed and
     bar_index > shortBreakdownBar and
     high >= shortBreakdownLevel - retestTolerancePoints and
     close < shortBreakdownLevel and
     close < open and
     close < ema9 and
     shortVWAPOk and
     shortVIXOk and
     shortHTFTrendOk

if barstate.isconfirmed and bullishBreakoutRetestEntry
    longBreakoutArmed := false

if barstate.isconfirmed and bearishBreakdownRetestEntry
    shortBreakdownArmed := false

//=============================================================================
// EMA TREND-PULLBACK ENTRIES
//=============================================================================
bool activeLongPlanZone =
     touchingS1 or touchingS2 or touchingS3 or touchingS4 or touchingS5 or
     touchingS6 or touchingS7 or touchingS8 or touchingS9 or touchingS10

bool activeShortPlanZone =
     touchingR1 or touchingR2 or touchingR3 or touchingR4 or touchingR5 or touchingR6

bool bullishTrendPullbackEntry =
     enableTrendPullbacks and
     bullishStack and
     low <= ema20 and
     ta.crossover(close, ema9) and
     (not strictStrategyEntryMode or activeLongPlanZone) and
     longVWAPOk and
     longVIXOk and
     longHTFTrendOk

bool bearishTrendPullbackEntry =
     enableTrendPullbacks and
     bearishStack and
     high >= ema20 and
     ta.crossunder(close, ema9) and
     (not strictStrategyEntryMode or activeShortPlanZone) and
     shortVWAPOk and
     shortVIXOk and
     shortHTFTrendOk

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

int longEntryScore =
     (bullishBreakoutRetestEntry ? 5 : 0) +
     (bullishReversalEntry ? 4 : 0) +
     (bullishTrendPullbackEntry ? 4 : 0) +
     (close > ema20 ? 1 : 0) +
     (longHTFTrendOk ? 1 : 0) +
     (longVWAPOk ? 1 : 0) +
     (longVIXOk ? 1 : 0)

int shortEntryScore =
     (bearishBreakdownRetestEntry ? 5 : 0) +
     (bearishReversalEntry ? 4 : 0) +
     (bearishTrendPullbackEntry ? 4 : 0) +
     (close < ema20 ? 1 : 0) +
     (shortHTFTrendOk ? 1 : 0) +
     (shortVWAPOk ? 1 : 0) +
     (shortVIXOk ? 1 : 0)

float candleRange = math.max(high - low, syminfo.mintick)
float closeLocation = (close - low) / candleRange
bool bullishCloseDominant = closeLocation >= 0.60
bool bearishCloseDominant = closeLocation <= 0.40

bool longEntryWinsConflict =
     longEntryScore > shortEntryScore or
     (longEntryScore == shortEntryScore and bullishCloseDominant and not bearishCloseDominant)

bool shortEntryWinsConflict =
     shortEntryScore > longEntryScore or
     (shortEntryScore == longEntryScore and bearishCloseDominant and not bullishCloseDominant)

var int lastSignalBar = na
bool cooldownComplete = na(lastSignalBar) or bar_index - lastSignalBar > signalCooldownBars

bool recentLongWatchAvailable =
     not requireRecentWatchForEntry or
     (not na(lastLongWatchBar) and bar_index - lastLongWatchBar <= watchToEntryWindowBars)

bool recentShortWatchAvailable =
     not requireRecentWatchForEntry or
     (not na(lastShortWatchBar) and bar_index - lastShortWatchBar <= watchToEntryWindowBars)

bool longEntry =
     barstate.isconfirmed and
     rawLongEntry and
     recentLongWatchAvailable and
     cooldownComplete and
     (not rawShortEntry or longEntryWinsConflict)

bool shortEntry =
     barstate.isconfirmed and
     rawShortEntry and
     recentShortWatchAvailable and
     cooldownComplete and
     (not rawLongEntry or shortEntryWinsConflict)

if longEntry or shortEntry
    lastSignalBar := bar_index

bool displayLongEntry =
     longEntry and
     showThisSignalBar

bool displayShortEntry =
     shortEntry and
     showThisSignalBar

plotshape(
     displayLongEntry,
     title = "Bullish Entry",
     style = shape.arrowup,
     location = location.belowbar,
     color = color.lime,
     size = size.small,
     text = "ENTRY",
     textcolor = color.white)

plotshape(
     displayShortEntry,
     title = "Bearish Entry",
     style = shape.arrowdown,
     location = location.abovebar,
     color = color.red,
     size = size.small,
     text = "ENTRY",
     textcolor = color.white)

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

// Confirmed entry alerts fire at the bar close after conflict resolution.
if barstate.isrealtime and longEntry
    alert(
         "BigE Signals | BULLISH ENTRY CONFIRMED | " +
         syminfo.ticker + " | Price " +
         str.tostring(close, format.mintick),
         alert.freq_once_per_bar_close)

if barstate.isrealtime and shortEntry
    alert(
         "BigE Signals | BEARISH ENTRY CONFIRMED | " +
         syminfo.ticker + " | Price " +
         str.tostring(close, format.mintick),
         alert.freq_once_per_bar_close)

//=============================================================================
// ALERTS
//=============================================================================
alertcondition(
     longSetupStart,
     title = "BigE Long Setup Forming",
     message = "BigE Signals: a bullish setup is forming on {{ticker}} near {{close}}. Wait for the confirmed green entry arrow.")

alertcondition(
     shortSetupStart,
     title = "BigE Short Setup Forming",
     message = "BigE Signals: a bearish setup is forming on {{ticker}} near {{close}}. Wait for the confirmed red entry arrow.")

alertcondition(
     longEntry,
     title = "BigE Bullish Entry Confirmed",
     message = "BigE Signals: bullish strategy trigger and entry confirmed on {{ticker}} at {{close}}.")

alertcondition(
     shortEntry,
     title = "BigE Bearish Entry Confirmed",
     message = "BigE Signals: bearish strategy trigger and entry confirmed on {{ticker}} at {{close}}.")
````
