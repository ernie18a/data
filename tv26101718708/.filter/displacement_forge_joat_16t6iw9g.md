# Displacement Forge [JOAT]

- url: https://www.tradingview.com/script/16t6iw9g-Displacement-Forge-JOAT/
- type: indicator
- pine_id: PUB;efd1adaf8c4a44f784c8d95d8bd0eb67
- version: 1.0

## Description

[b]Displacement Forge [JOAT][/b]

[b]Introduction[/b]

Displacement Forge is an open-source order block detection engine built on Z-Score impulse analysis. It identifies statistically significant price displacements — moves that exceed a configurable standard deviation threshold relative to recent price change history — and marks the candle immediately preceding each displacement as an Order Block Zone. Order blocks represent the price ranges from which institutional order flow originates. Price regularly returns to these zones to fill remaining orders, and Displacement Forge identifies and tracks each one, monitors for zone reactions, and records cumulative rejection statistics.

The problem order block analysis solves is entry precision. A trend bias tells you direction. An order block tells you at what price the institutions that created that trend loaded their positions. Returning to those prices to enter alongside institutional flow — rather than chasing moves already in progress — is the conceptual foundation Displacement Forge is built on. The Z-Score gate ensures only statistically significant displacements qualify, filtering out small impulses caused by normal market noise.

[image]https://www.tradingview.com/x/Rawsid75/[/image]

[b]Core Concepts[/b]

[b]1. Z-Score Displacement Detection[/b]

Rather than using fixed ATR multiples to define a "significant" move, Displacement Forge computes the Z-Score of each bar's price change relative to the rolling distribution of recent price changes. The Z-Score measures how many standard deviations the current move is from the recent mean:

[pine]
priceChg = close - close[1]
avgChg   = ta.sma(priceChg, zscoreLen)
stdChg   = ta.stdev(priceChg, zscoreLen)
zscore   = stdChg > 0 ? (priceChg - avgChg) / stdChg : 0.0
[/pine]

A positive Z-Score above the threshold with a bullish candle close and a higher close than recent highs — filtered by an EMA and VWAP trend context — constitutes a bullish displacement impulse. A negative Z-Score below the negative threshold with a bearish close and lower-than-recent lows in the opposing trend context constitutes a bearish displacement impulse.

[b]2. Order Block Zone Identification[/b]

When a displacement impulse is detected, the indicator looks backward through the impulse lookback window for the last candle in the opposite direction — the candle just before the institutional move began. That candle's high and low define the order block zone. This captures the price range where institutional orders were being placed before the displacement candle consumed available liquidity:

[pine]
if bullImpulse
    for i = 1 to impulseLook
        if close[i] < open[i]   // Last bearish candle before the impulse
            obLow  := low[i]
            obHigh := high[i]
            break
[/pine]

Each zone is drawn as a box on the chart using the pre-impulse candle's range. Bull order blocks are drawn with a bullish tint (price expected to react bullishly when revisited). Bear order blocks with a bearish tint.

[b]3. EMA and VWAP Trend Filter[/b]

Two independent trend filters gate displacement qualification. The EMA filter (200-period by default, configurable) requires bull displacements to occur above the EMA and bear displacements below it. The VWAP filter adds an intraday fair-value gate — bull displacements require price to be above the current VWAP, bear displacements require price to be below. Both filters can be independently enabled or disabled:

[pine]
bullImpulse = zscore > threshold and close > open
    and close > ta.highest(close, impulseLook)[1]
    and (not useEma  or close > ema200)
    and (not useVwap or close > ta.vwap)
[/pine]

[b]4. Zone Reaction Detection and Rejection Counting[/b]

Active order block zones are continuously monitored for price reactions. A bullish reaction occurs when the candle low touches or enters the bull zone range with a bullish close. A bearish reaction occurs when the high touches or enters the bear zone range with a bearish close. Each confirmed reaction increments the independent bull and bear rejection counters displayed in the dashboard:

[pine]
if ob.isBull and low <= ob.top and low >= ob.bottom and close > open
    bullReactionDetected := true
    totalBullRejections  += 1
[/pine]

[b]5. Zone Lifespan and Active Zone Management[/b]

Each zone carries an age counter that increments bar by bar. Zones exceeding the maximum age (configurable) are automatically removed as inactive. The active zone count and total tested zone count are tracked and displayed in the dashboard, giving a running picture of how many zones are currently relevant versus how many have been tested and absorbed.

[image]https://www.tradingview.com/x/niLd9UKD/[/image]

[b]Features[/b]

[list]
[*][b]Z-Score impulse gate:[/b] Displacement qualification based on standard deviations from the rolling price-change distribution, not arbitrary fixed thresholds
[*][b]Order block zone boxes:[/b] Pre-impulse candle ranges drawn as colored boxes on the chart for both bull and bear impulses
[*][b]EMA trend filter:[/b] Configurable EMA length gates displacement direction relative to long-term trend
[*][b]VWAP trend filter:[/b] Intraday VWAP provides a fair-value gate alongside the EMA for dual confirmation
[*][b]Zone reaction monitoring:[/b] Active zones continuously checked for price reactions with independent bull and bear rejection counters
[*][b]Zone age management:[/b] Configurable maximum zone age with automatic removal of expired zones
[*][b]Active and tested zone counts:[/b] Dashboard tracks how many zones are live versus how many have been tested
[*][b]Bull and bear rejection totals:[/b] Cumulative counts of all confirmed zone reactions by direction
[*][b]Displacement markers:[/b] Labeled arrows at each confirmed displacement bar (BULL DISP, BEAR DISP) with size and style differentiation
[*][b]Divergence detection:[/b] Z-Score divergence against price direction labeled (BULL DIV, BEAR DIV) and hidden divergence (H.BULL, H.BEAR)
[*][b]Institutional dashboard (top right):[/b] 13-row table with Z-Score, displacement state, OB reactions, active zone count, tested zone count, EMA and VWAP filter status
[*][b]Fully configurable:[/b] Z-Score length and threshold, impulse lookback, EMA length, VWAP toggle, zone max age, and zone visibility independently adjustable
[*][b]Alerts:[/b] Separate alertconditions for bullish and bearish displacement impulses
[/list]

[b]Input Parameters[/b]

[b]Displacement Detection:[/b]
[list]
[*]Z-Score Length: Rolling window for mean and standard deviation calculation (default: 20)
[*]Z-Score Threshold: Standard deviation threshold for displacement qualification (default: 1.5)
[*]Impulse Lookback: Bars back to search for the pre-impulse order block candle (default: 5)
[/list]

[b]Trend Filters:[/b]
[list]
[*]EMA Length: Trend EMA period (default: 200)
[*]Use EMA Filter toggle (default: enabled)
[*]Use VWAP Filter toggle (default: enabled)
[/list]

[b]Zone Management:[/b]
[list]
[*]Max Zone Age (Bars): Maximum bar lifespan of active zones before automatic removal (default: 100)
[*]Show OB Zones toggle
[/list]

[b]Display:[/b]
[list]
[*]Show Dashboard toggle
[*]Show Divergence Labels toggle
[*]Bullish and Bearish color inputs
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the Current Z-Score and Displacement State[/b]
The dashboard shows the live Z-Score value and displacement state (BULL IMPULSE, BEAR IMPULSE, or NEUTRAL). Use the Z-Score value as a real-time gauge of how statistically extreme the current price move is relative to recent history.

[b]Step 2: Locate Active Order Block Zones[/b]
After any displacement, a colored box marks the pre-impulse candle range. These zones are the areas where institutional orders were accumulated before the move. The dashboard's Active Zones row shows how many live zones are currently on the chart.

[b]Step 3: Wait for Price to Return to a Zone[/b]
When price retraces after a displacement and enters an active zone, watch for a reaction candle. A bullish close from within a bull zone or a bearish close from within a bear zone constitutes a zone reaction and increments the dashboard's rejection counter.

[b]Step 4: Apply EMA and VWAP Context[/b]
The EMA filter status (ABOVE/BELOW) and VWAP filter status in the dashboard confirm whether the trend context supports the zone direction. An active bull zone with price above both the EMA and VWAP provides a higher-context long reaction than the same zone in a downtrend.

[b]Step 5: Observe Divergence Labels[/b]
BULL DIV and BEAR DIV labels appear when the Z-Score diverges from price direction — Z-Score momentum and price momentum disagree. H.BULL and H.BEAR mark hidden divergence. These are secondary signals that may precede displacement reversals.

[b]Indicator Limitations[/b]

[list]
[*]The Z-Score is computed relative to the rolling price-change distribution of the configured lookback period. During regime changes or low-liquidity periods, the distribution can shift and cause the threshold to misfire
[*]Order block identification looks backward from the displacement bar. The pre-impulse candle selection is algorithmic — it finds the last opposite-direction candle within the lookback. In some impulse structures this may not match the manually identified order block
[*]Zone reaction detection requires the candle to touch the zone range in the same bar that a directional close occurs. Multi-bar zone entry sequences are not separately tracked
[*]The VWAP calculation resets at daily boundaries. On instruments that trade across midnight or on continuous futures contracts, the VWAP reset behavior may differ from expectations
[*]This indicator identifies order block zones and reactions. It does not generate trade entry signals, and zone reactions do not guarantee price continuation from the zone
[/list]

[b]Originality Statement[/b]

Displacement Forge is original in its application of Z-Score analysis to price change distribution as the gate for order block qualification, combined with a dual trend filter and automatic zone reaction monitoring with cumulative statistics. This indicator is published because:

[list]
[*]Using the rolling Z-Score of bar-by-bar price changes — rather than raw ATR multiples — to define what constitutes a statistically significant displacement provides an adaptive, distribution-aware threshold that adjusts to current volatility rather than using fixed values
[*]The pre-impulse candle lookback logic that identifies the order block as the last opposite-direction candle before the displacement provides a specific, repeatable rule for zone placement that eliminates the ambiguity of manual order block selection
[*]The dual trend filter combining a configurable EMA with VWAP — both independently togglable — provides layered directional context that single-MA systems do not offer
[*]Tracking cumulative bull and bear rejection counts alongside active and tested zone counts provides ongoing statistical feedback on how the order block zones are performing across the chart history
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Order block zones are identified using statistical and structural criteria but do not guarantee any particular price reaction when revisited. Z-Score thresholds are parameters that require adjustment to match specific instruments and timeframes. Past zone reactions do not guarantee future reactions. Always use proper risk management. The author is not responsible for any trading losses resulting from the use of this indicator.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Displacement Forge [JOAT]", shorttitle="Disp Forge [JOAT]", overlay=true,
     max_boxes_count=500, max_lines_count=200, max_labels_count=200)
// ─── INPUTS ────────────────────────────────────────────────────────────────────
grpDetect = "Zone Detection"
zscoreLen    = input.int(20,    "Z-Score Period",       minval=5, maxval=100,   group=grpDetect)
zscoreThres  = input.float(1.5, "Z-Score Threshold",   minval=0.5, maxval=4.0, step=0.1, group=grpDetect,
     tooltip="Minimum Z-Score of price change to qualify as a displacement move.")
impulseLook  = input.int(5,     "Impulse Lookback",     minval=2, maxval=20,    group=grpDetect,
     tooltip="Bars to scan for the origin candle before the impulse.")
preventOverlap = input.bool(true,"Prevent Overlapping Zones",                   group=grpDetect)

grpFilter = "Confluence Filters"
useEmaFilt  = input.bool(true, "EMA Trend Filter",   group=grpFilter)
emaLen      = input.int(200,   "EMA Length",          minval=10, maxval=1000, group=grpFilter)
useVwapFilt = input.bool(true, "VWAP Filter",         group=grpFilter)

grpLifecycle = "Zone Lifecycle"
maxAge       = input.int(100,  "Max Zone Age (bars)", minval=10, maxval=500, group=grpLifecycle)
ageFade      = input.bool(true,"Age-Based Fading",    group=grpLifecycle,
     tooltip="Newer zones appear more opaque, older zones gradually fade.")
maxActiveOB  = input.int(8,    "Max Active Zones",    minval=2, maxval=20,  group=grpLifecycle)
showMidline  = input.bool(true,"Show Zone Midline",   group=grpLifecycle)

grpDisplay = "Display"
showDash   = input.bool(true, "Show Dashboard", group=grpDisplay)
showEma    = input.bool(true, "Show EMA Line",  group=grpDisplay)

grpColors = "Colors"
bullZoneCol   = input.color(color.new(#00897B, 78), "Bullish Zone Fill",   group=grpColors)
bearZoneCol   = input.color(color.new(#E65100, 78), "Bearish Zone Fill",   group=grpColors)
testedBorder  = input.color(color.new(#FFB300, 30), "Tested Zone Border",  group=grpColors)
brokenCol     = input.color(color.new(#424242, 85), "Broken Zone",         group=grpColors)
midlineCol    = input.color(color.new(#78909C, 60), "Midline",             group=grpColors)

// ─── CORE CALCULATIONS ────────────────────────────────────────────────────────
priceChange = close - close[1]
avgChange   = ta.sma(priceChange, zscoreLen)
stdChange   = ta.stdev(priceChange, zscoreLen)
zscore      = stdChange > 0 ? (priceChange - avgChange) / stdChange : 0.0

emaLine     = ta.ema(close, emaLen)
vwapLine    = ta.vwap(hlc3)

plot(showEma ? emaLine : na, "EMA", color=color.new(#B0BEC5, 50), linewidth=1)

// ─── IMPULSE DETECTION ─────────────────────────────────────────────────────────
emaCondBull  = not useEmaFilt  or close > emaLine
emaCondBear  = not useEmaFilt  or close < emaLine
vwapCondBull = not useVwapFilt or close > vwapLine
vwapCondBear = not useVwapFilt or close < vwapLine

bullImpulse = zscore > zscoreThres  and close > open and close > ta.highest(close, impulseLook)[1] and emaCondBull  and vwapCondBull and barstate.isconfirmed
bearImpulse = zscore < -zscoreThres and close < open and close < ta.lowest(close, impulseLook)[1]  and emaCondBear  and vwapCondBear  and barstate.isconfirmed

// ─── ZONE TYPE ─────────────────────────────────────────────────────────────────
type OBZone
    box   zoneBox
    line  midLine
    float top
    float bottom
    int   birthBar
    bool  isBull
    int   state       // 0 = Active, 1 = Tested, 2 = Broken

var array<OBZone> zones = array.new<OBZone>()

// Lifetime counters
var int totalCreated       = 0
var int totalTested        = 0
var int totalBroken        = 0
var int totalBullRejection = 0
var int totalBearRejection = 0

// ─── OVERLAP CHECK ─────────────────────────────────────────────────────────────
isOverlapping(float newTop, float newBot) =>
    overlap = false
    if preventOverlap and array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            ob = array.get(zones, i)
            if ob.state < 2
                if not (newBot > ob.top or newTop < ob.bottom)
                    overlap := true
                    break
    overlap

// ─── CREATE BULLISH ZONES ──────────────────────────────────────────────────────
// Origin candle is the last down-close (bearish) candle before the impulse.
if bullImpulse
    baseLow  = low[1]
    baseHigh = high[1]
    baseIdx  = 1
    for i = 1 to impulseLook
        if close[i] < open[i]
            baseLow  := low[i]
            baseHigh := high[i]
            baseIdx  := i
            break

    obTop = baseHigh
    obBot = baseLow

    if not isOverlapping(obTop, obBot)
        bx = box.new(bar_index - baseIdx, obTop, bar_index + 1, obBot,
             bgcolor=bullZoneCol, border_color=color.new(#00897B, 40), border_width=1)
        ml = showMidline ? line.new(bar_index - baseIdx, (obTop + obBot) / 2, bar_index + 1, (obTop + obBot) / 2,
             color=midlineCol, style=line.style_dashed, width=1) : na
        array.push(zones, OBZone.new(bx, ml, obTop, obBot, bar_index, true, 0))
        totalCreated += 1

// ─── CREATE BEARISH ZONES ──────────────────────────────────────────────────────
// Origin candle is the last up-close (bullish) candle before the impulse.
if bearImpulse
    baseHigh = high[1]
    baseLow  = low[1]
    baseIdx  = 1
    for i = 1 to impulseLook
        if close[i] > open[i]
            baseHigh := high[i]
            baseLow  := low[i]
            baseIdx  := i
            break

    obTop = baseHigh
    obBot = baseLow

    if not isOverlapping(obTop, obBot)
        bx = box.new(bar_index - baseIdx, obTop, bar_index + 1, obBot,
             bgcolor=bearZoneCol, border_color=color.new(#E65100, 40), border_width=1)
        ml = showMidline ? line.new(bar_index - baseIdx, (obTop + obBot) / 2, bar_index + 1, (obTop + obBot) / 2,
             color=midlineCol, style=line.style_dashed, width=1) : na
        array.push(zones, OBZone.new(bx, ml, obTop, obBot, bar_index, false, 0))
        totalCreated += 1

// ─── ZONE LIFECYCLE UPDATE ─────────────────────────────────────────────────────
if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        if i >= array.size(zones)
            continue

        ob      = array.get(zones, i)
        obAge   = bar_index - ob.birthBar
        baseCol = ob.isBull ? #00897B : #E65100

        priceInZone   = high >= ob.bottom and low <= ob.top
        closedThrough = ob.isBull ? close < ob.bottom : close > ob.top

        if ob.state == 0 and priceInZone and not closedThrough
            ob.state := 1
            totalTested += 1

        if closedThrough and ob.state != 2
            ob.state := 2
            totalBroken += 1

        if ob.state == 0
            float activeAlpha = ageFade ? math.min(78.0 + obAge * 0.25, 94.0) : 78.0
            box.set_bgcolor(ob.zoneBox, color.new(baseCol, int(activeAlpha)))
            box.set_border_color(ob.zoneBox, color.new(baseCol, int(activeAlpha) - 30))
            box.set_border_style(ob.zoneBox, line.style_solid)
            box.set_border_width(ob.zoneBox, 1)
            box.set_right(ob.zoneBox, bar_index + 1)
            if showMidline and not na(ob.midLine)
                line.set_x2(ob.midLine, bar_index + 1)

        else if ob.state == 1
            float testedAlpha = ageFade ? math.min(80.0 + obAge * 0.25, 94.0) : 82.0
            box.set_bgcolor(ob.zoneBox, color.new(baseCol, int(testedAlpha)))
            box.set_border_color(ob.zoneBox, testedBorder)
            box.set_border_style(ob.zoneBox, line.style_solid)
            box.set_border_width(ob.zoneBox, 2)
            box.set_right(ob.zoneBox, bar_index + 1)
            if showMidline and not na(ob.midLine)
                line.set_x2(ob.midLine, bar_index + 1)

        else if ob.state == 2
            box.set_bgcolor(ob.zoneBox, brokenCol)
            box.set_border_color(ob.zoneBox, color.new(#424242, 60))
            box.set_border_style(ob.zoneBox, line.style_dotted)
            box.set_border_width(ob.zoneBox, 1)
            box.set_right(ob.zoneBox, bar_index)
            if showMidline and not na(ob.midLine)
                line.set_x2(ob.midLine, bar_index)
            array.remove(zones, i)
            continue

        if obAge > maxAge * 2 and ob.state != 2
            box.delete(ob.zoneBox)
            if not na(ob.midLine)
                line.delete(ob.midLine)
            array.remove(zones, i)

// ─── CAP ACTIVE ZONES ──────────────────────────────────────────────────────────
while array.size(zones) > maxActiveOB
    oldest = array.shift(zones)
    box.delete(oldest.zoneBox)
    if not na(oldest.midLine)
        line.delete(oldest.midLine)

// ─── REJECTION SIGNAL ──────────────────────────────────────────────────────────
// Fires when a wick touches an active/tested zone but the body stays outside.
// High-probability institutional reaction: zone absorbed the price probe.
bool bullRejection = false
bool bearRejection = false

if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        ob = array.get(zones, i)
        if ob.state <= 1
            zoneHeight = ob.top - ob.bottom
            minBounce  = zoneHeight * 0.4

            if ob.isBull
                wickTouches = low <= ob.top and low >= ob.bottom
                bodyOut     = math.min(open, close) > ob.top
                bounces     = close > open and (close - low) > minBounce
                if wickTouches and not bodyOut and bounces
                    bullRejection := true
            else
                wickTouches = high >= ob.bottom and high <= ob.top
                bodyOut     = math.max(open, close) < ob.bottom
                bounces     = close < open and (high - close) > minBounce
                if wickTouches and not bodyOut and bounces
                    bearRejection := true

if bullRejection
    totalBullRejection += 1
if bearRejection
    totalBearRejection += 1

// ─── DASHBOARD ─────────────────────────────────────────────────────────────────
var table dash = table.new(position.top_right, 2, 13,
     bgcolor=color.new(#0D1117, 5),
     border_color=color.new(#1A2332, 0),
     border_width=1,
     frame_color=color.new(#00897B, 40),
     frame_width=1)

if barstate.islast and showDash
    color DARK_BG = color.new(#0D1117, 0)
    color SEP_BG  = color.new(#080D13, 0)
    color LBL_C   = color.new(#546E7A, 0)

    int activeCount = 0
    int testedCount = 0
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            st = array.get(zones, i).state
            if st == 0
                activeCount += 1
            else if st == 1
                testedCount += 1

    color zCol = math.abs(zscore) > zscoreThres ? color.new(#E65100, 0) : color.new(#546E7A, 0)

    // Row 0: Header
    table.cell(dash, 0, 0, "DISPLACEMENT FORGE", text_color=color.new(#ECEFF1, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 0, "[JOAT]",             text_color=color.new(#00897B, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 1: Separator
    table.cell(dash, 0, 1, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 1, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 2: Active Zones (prominent)
    table.cell(dash, 0, 2, "Active Zones",  text_color=LBL_C,               text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(activeCount),
         text_color=color.new(#00897B, 0), text_size=size.normal,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 3: Tested Zones
    table.cell(dash, 0, 3, "Tested Zones",  text_color=LBL_C,               text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(testedCount),
         text_color=color.new(#FFB300, 0), text_size=size.normal,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 4: Separator
    table.cell(dash, 0, 4, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 4, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 5: Total Created
    table.cell(dash, 0, 5, "Total Created",  text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(totalCreated),
         text_color=color.new(#78909C, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 6: Total Tested
    table.cell(dash, 0, 6, "Total Tested",   text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 6, str.tostring(totalTested),
         text_color=color.new(#78909C, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 7: Total Broken
    table.cell(dash, 0, 7, "Total Broken",   text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(totalBroken),
         text_color=color.new(#546E7A, 0), text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 8: Separator
    table.cell(dash, 0, 8, "", bgcolor=SEP_BG, text_size=size.tiny)
    table.cell(dash, 1, 8, "", bgcolor=SEP_BG, text_size=size.tiny)

    // Row 9: OB Rejections
    table.cell(dash, 0, 9, "OB Rejections",  text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 9,
         str.tostring(totalBullRejection) + " bull / " + str.tostring(totalBearRejection) + " bear",
         text_color=color.new(#78909C, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 10: Z-Score live value
    table.cell(dash, 0, 10, "Z-Score",       text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(zscore, "#.##"),
         text_color=zCol, text_size=size.small,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 11: Threshold
    table.cell(dash, 0, 11, "Threshold",     text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    table.cell(dash, 1, 11, str.tostring(zscoreThres, "#.##") + " SD",
         text_color=color.new(#546E7A, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

    // Row 12: Filters active
    table.cell(dash, 0, 12, "EMA / VWAP",   text_color=LBL_C,               text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_left)
    string filterStr = (useEmaFilt ? "EMA " : "") + (useVwapFilt ? "VWAP" : "") + (not useEmaFilt and not useVwapFilt ? "Off" : "")
    table.cell(dash, 1, 12, filterStr,
         text_color=color.new(#546E7A, 0), text_size=size.tiny,
         bgcolor=DARK_BG, text_halign=text.align_right)

// ─── ALERTS ────────────────────────────────────────────────────────────────────
alertcondition(bullImpulse,   "Bullish Displacement", "Displacement Forge: Bullish impulse detected")
alertcondition(bearImpulse,   "Bearish Displacement", "Displacement Forge: Bearish impulse detected")
alertcondition(bullRejection, "Bullish OB Rejection", "Displacement Forge: Price rejected from bullish OB zone")
alertcondition(bearRejection, "Bearish OB Rejection", "Displacement Forge: Price rejected from bearish OB zone")
````
