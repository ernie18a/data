# FVG & OB Quality Scorer

- url: https://www.tradingview.com/script/g6N0I2et-FVG-OB-Quality-Scorer/
- type: indicator
- pine_id: PUB;be1c0f3dc6f0417d8afcdbe86e9c1d25
- version: 1.0

## Description

ICT FVG & OB Quality Scorer
Core idea: Not all Fair Value Gaps and Order Blocks are created equal. This indicator answers the question "Which FVG or Order Block will actually work?" by scoring every detected zone on 10 confluence pillars derived from ICT's (InnerCircleTrader) 2022–2024 Mentorship methodology.

How It Works
Every time an FVG or Order Block forms on the chart, the indicator runs it through a 10-factor scoring engine (each factor scored 0–10, total 0–100):

#	Pillar	What It Checks
❶	Displacement / CISD	Was the move impulsive? Body > 70% of candle range = institutional candle. Also checks for Change in State of Delivery (close crossing prior candle's open).
❷	Liquidity Sweep	Was BSL or SSL taken before the zone formed? Checks swing pivots, Prior Day High/Low, and IPDA 20-day levels.
❸	Premium / Discount	Bullish zones in discount (< 50% of range) score high. Bearish zones in premium (> 50%) score high.
❹	Market Structure	Is the zone aligned with the current trend (BOS)? With-trend = 10, counter-trend = 1.
❺	HTF Bias	Does the Daily (configurable) candle direction agree with the zone? Misalignment = low probability.
❻	OTE Fibonacci	Is the zone inside the 62%–79% Optimal Trade Entry retracement? The 70.5% "sweet spot" scores perfect 10.
❼	FVG + OB Overlap	Is there a confluence zone where an FVG and Order Block exist at the same price level? This is ICT's highest-probability setup.
❽	Volume	Was displacement volume above the 20-bar average? 3x+ average = clear institutional activity.
❾	Kill Zone Timing	Formed during London KZ, NY AM KZ, or Silver Bullet windows? "Time supersedes price."
❿	Freshness	First-touch zones score highest. Zones decay in score and fade in color as they age.

Grading Scale
Score	Grade	Meaning
86–100	S	Elite — high conviction, full size
71–85	A/A+	Strong — tradeable with confirmation
51–70	B/B+	Above average — needs extra confluence
26–50	C/C+	Below average — watch only
0–25	D	Weak — skip entirely

What You See On The Chart

Color-graded zones: Red (weak) → Orange → Gold → Green → Bright Green (elite)
FVGs = solid-border boxes labeled BISI / SIBI
Order Blocks = dashed-border boxes labeled +OB / -OB
CE line = dotted midline (Consequent Encroachment — ICT's 50% level)
MT line = solid midline on OBs (Mean Threshold — ICT's precision entry)
Score labels with letter grade — hover for full 10-pillar tooltip breakdown

Dashboard table ranking all active zones by score with market context (Structure, HTF Bias, Kill Zone status)

Zones fade in color as they age (freshness decay) and are removed/dimmed on mitigation
Key Settings

Min Score to Display — Set to 60+ to only see B+ and above (recommended for clean charts)

Mitigate On — Wick vs Close (ICT uses Close for higher conviction)

HTF Timeframe — Defaults to Daily; change to 4H for swing setups

IPDA Reference Lines — Toggle 20-day high/low institutional levels

Kill Zone sessions — All configurable in NY time

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("ICT FVG & OB Quality Scorer", shorttitle="FVG/OB Scr", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// =====================================================================
// ICT FVG & ORDER BLOCK QUALITY SCORER
// =====================================================================
// Based on InnerCircleTrader's 2022/2023/2024 Mentorship Methodology.
//
// Core ICT Principle: "Not all FVGs and Order Blocks are created equal."
// An FVG or OB is NOT a standalone strategy — it requires CONFLUENCE.
// This indicator scores each zone on 10 ICT-authentic confluence pillars
// to predict which ones are most likely to produce a reaction.
//
// ═══════════════════════════════════════════════════════════════════
// THE 10 PILLARS OF CONFLUENCE (ICT Methodology)
// ═══════════════════════════════════════════════════════════════════
//
//  1. DISPLACEMENT (CISD)     — Was the creating move impulsive?
//                                Did it show a Change in State of Delivery?
//                                Body > 70% of range = institutional candle.
//
//  2. LIQUIDITY SWEEP          — Was buy-side or sell-side liquidity
//                                taken BEFORE this zone formed?
//                                (Prior Day H/L, Swing H/L, IPDA levels)
//
//  3. PREMIUM / DISCOUNT       — Is a bullish zone in Discount (<50%)?
//                                Is a bearish zone in Premium (>50%)?
//                                Deep zones (OTE: 62-79%) score highest.
//
//  4. MARKET STRUCTURE ALIGN   — Does a BOS or MSS confirm direction?
//                                With-trend = high prob, counter = risky.
//
//  5. HTF BIAS CONFIRMATION    — Does the higher timeframe agree?
//                                (Daily/4H candle direction alignment)
//
//  6. OTE FIBONACCI CONFLUENCE — Does the zone sit inside the Optimal
//                                Trade Entry zone (62%–79% retracement)?
//                                The 70.5% "sweet spot" scores highest.
//
//  7. FVG + OB OVERLAP         — Is there a confluence zone where an
//                                FVG overlaps with an Order Block?
//                                This is the highest-probability setup.
//
//  8. VOLUME CONFIRMATION      — Was volume above average during the
//                                displacement? Institutional footprint.
//
//  9. KILL ZONE TIMING         — Was it formed during London (02-05),
//                                NY AM (08:30-11), or Silver Bullet
//                                windows? Time supersedes price.
//
// 10. FRESHNESS (Unmitigated)  — Is this the first touch? Fresh zones
//                                that haven't been revisited score highest.
//                                Decay over time = reduced conviction.
//
// Each factor scores 0–10 points → Total = 0–100.
// Zones are color-graded: Red (Weak) → Orange → Gold → Green (Strong).
// =====================================================================

// ─────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────

grp_general = "⚙ General Settings"
minScore        = input.int(35, "Min Score to Display", minval=0, maxval=100, group=grp_general, tooltip="Zones scoring below this are hidden. Lower = more zones, higher = only best setups. ICT recommends focusing on A/A+ setups.")
lookbackDays    = input.int(5, "Lookback (Days)", minval=1, maxval=30, group=grp_general)
mitigateMode    = input.string("Wick", "Mitigate On", options=["Wick", "Close"], group=grp_general, tooltip="Wick: Zone removed when wick touches far edge. Close: Only when candle closes through it. ICT uses 'Close' for higher conviction.")
showMitigated   = input.bool(false, "Show Mitigated Zones (Dimmed)", group=grp_general)
showScoreLabels = input.bool(true, "Show Score Labels on Zones", group=grp_general)
showCELine      = input.bool(true, "Show Consequent Encroachment (50%)", group=grp_general)
showMTLine      = input.bool(true, "Show Mean Threshold (OB 50%)", group=grp_general)

grp_fvg = "📊 FVG Detection"
useFVG = input.bool(true, "Detect Fair Value Gaps (BISI/SIBI)", group=grp_fvg)

grp_ob = "🔲 Order Block Detection"
useOB        = input.bool(true, "Detect Order Blocks", group=grp_ob)
obScanDepth  = input.int(10, "OB Scan Depth (Bars Back)", minval=2, maxval=20, group=grp_ob, tooltip="How many bars back to search for the last opposing candle before displacement.")

grp_struct = "📐 Market Structure"
structLen = input.int(5, "Pivot Length (Swing Detection)", minval=2, maxval=20, group=grp_struct)

grp_htf = "📈 Higher Timeframe Bias"
htfTimeframe = input.timeframe("D", "HTF Timeframe", group=grp_htf, tooltip="Higher timeframe used to confirm directional bias. ICT recommends Daily for intraday traders.")

grp_pd = "💲 Premium / Discount & OTE"
pdLookback = input.int(50, "Dealing Range Lookback", minval=10, maxval=200, group=grp_pd)

grp_session = "⏰ Kill Zone Sessions (NY Time)"
kzLondon   = input.session("0200-0500", "London Kill Zone", group=grp_session)
kzNYAM     = input.session("0830-1100", "NY AM Kill Zone", group=grp_session)
kzNYPM     = input.session("1330-1500", "NY PM / Silver Bullet 3", group=grp_session)
kzSB1      = input.session("0300-0400", "Silver Bullet 1 (London)", group=grp_session)
kzSB2      = input.session("1000-1100", "Silver Bullet 2 (NY AM)", group=grp_session)

grp_ipda = "📅 IPDA Data Ranges"
showIPDA   = input.bool(false, "Show IPDA Reference Lines", group=grp_ipda, tooltip="Mark the 20/40/60-day highs and lows as institutional reference levels per ICT's IPDA framework.")

grp_dash = "📋 Dashboard"
showDash    = input.bool(true, "Show Dashboard Table", group=grp_dash)
dashPos     = input.string("Top Right", "Dashboard Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grp_dash)

grp_colors = "🎨 Color Scheme"
colS1 = input.color(color.new(#EF5350, 25), "Score 0-25 (D — Weak)", group=grp_colors)
colS2 = input.color(color.new(#FF9800, 35), "Score 26-50 (C — Below Avg)", group=grp_colors)
colS3 = input.color(color.new(#FDD835, 40), "Score 51-70 (B — Above Avg)", group=grp_colors)
colS4 = input.color(color.new(#66BB6A, 25), "Score 71-85 (A — Strong)", group=grp_colors)
colS5 = input.color(color.new(#00E676, 15), "Score 86-100 (S — Elite)", group=grp_colors)

// ─────────────────────────────────────────────────────────────────────
// USER DEFINED TYPES
// ─────────────────────────────────────────────────────────────────────

type Zone
    float   top
    float   bot
    bool    isBull
    bool    isFVG           // true = FVG, false = OB
    int     startBar
    int     creationBar
    float   score
    string  scoreBreakdown
    bool    mitigated
    bool    ceHit
    bool    hasOverlap       // FVG+OB confluence detected
    box     bx
    label   lbl
    line    ceLine
    line    mtLine           // mean threshold line for OBs

// ─────────────────────────────────────────────────────────────────────
// STATE VARIABLES
// ─────────────────────────────────────────────────────────────────────

var array<Zone> activeZones = array.new<Zone>()

// ATR
float atr14 = ta.atr(14)

// Volume
float avgVol = ta.sma(volume, 20)

// Dealing Range for Premium/Discount + OTE
float drHigh = ta.highest(high, pdLookback)
float drLow  = ta.lowest(low, pdLookback)
float drMid  = (drHigh + drLow) / 2.0
float drRange = drHigh - drLow

// OTE Fibonacci Levels (from the dealing range swing)
float ote62 = drHigh - drRange * 0.62
float ote705 = drHigh - drRange * 0.705
float ote79 = drHigh - drRange * 0.79

// IPDA Data Ranges (20/40/60 day)
float ipda20H = ta.highest(high, 20)
float ipda20L = ta.lowest(low, 20)
float ipda40H = ta.highest(high, 40)
float ipda40L = ta.lowest(low, 40)
float ipda60H = ta.highest(high, 60)
float ipda60L = ta.lowest(low, 60)

// Prior Day High/Low for liquidity sweep
float pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
float pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)

// HTF Bias (Daily candle direction)
float htfClose = request.security(syminfo.tickerid, htfTimeframe, close, lookahead=barmerge.lookahead_off)
float htfOpen  = request.security(syminfo.tickerid, htfTimeframe, open, lookahead=barmerge.lookahead_off)
float htfClose1 = request.security(syminfo.tickerid, htfTimeframe, close[1], lookahead=barmerge.lookahead_on)
float htfOpen1  = request.security(syminfo.tickerid, htfTimeframe, open[1], lookahead=barmerge.lookahead_on)
int   htfBias  = htfClose1 > htfOpen1 ? 1 : htfClose1 < htfOpen1 ? -1 : 0  // 1=bull, -1=bear

// Market Structure (Swing Pivots for BOS/MSS + Trend Detection)
float pivotHigh = ta.pivothigh(high, structLen, structLen)
float pivotLow  = ta.pivotlow(low, structLen, structLen)

var float lastSH = na
var float lastSL = na
var float prevSH = na
var float prevSL = na
var int   trend  = 0  // 1 = bullish, -1 = bearish

if not na(pivotHigh)
    if not na(lastSH)
        prevSH := lastSH
    lastSH := pivotHigh

if not na(pivotLow)
    if not na(lastSL)
        prevSL := lastSL
    lastSL := pivotLow

// Trend from structure: HH+HL = bull, LH+LL = bear
if not na(pivotHigh) and not na(prevSH) and not na(prevSL) and not na(lastSL)
    if pivotHigh > prevSH and lastSL > prevSL
        trend := 1
    else if pivotHigh < prevSH
        trend := -1

if not na(pivotLow) and not na(prevSL) and not na(prevSH) and not na(lastSH)
    if pivotLow < prevSL and lastSH < prevSH
        trend := -1
    else if pivotLow > prevSL
        trend := 1

// Session / Kill Zone
bool inKZ_London = not na(time(timeframe.period, kzLondon, "America/New_York"))
bool inKZ_NYAM   = not na(time(timeframe.period, kzNYAM, "America/New_York"))
bool inKZ_NYPM   = not na(time(timeframe.period, kzNYPM, "America/New_York"))
bool inKZ_SB1    = not na(time(timeframe.period, kzSB1, "America/New_York"))
bool inKZ_SB2    = not na(time(timeframe.period, kzSB2, "America/New_York"))
bool inKZ        = inKZ_London or inKZ_NYAM or inKZ_NYPM or inKZ_SB1 or inKZ_SB2
bool inAsian     = not na(time(timeframe.period, "2000-0000", "America/New_York"))

// Time window filter
bool inWindow = (timenow - time) <= (lookbackDays * 86400000)

// ─────────────────────────────────────────────────────────────────────
// HELPER FUNCTIONS
// ─────────────────────────────────────────────────────────────────────

f_scoreColor(float sc) =>
    sc <= 25 ? colS1 : sc <= 50 ? colS2 : sc <= 70 ? colS3 : sc <= 85 ? colS4 : colS5

f_scoreTextColor(float sc) =>
    sc <= 25 ? color.new(#EF5350, 0) : sc <= 50 ? color.new(#FF9800, 0) : sc <= 70 ? color.new(#FDD835, 0) : sc <= 85 ? color.new(#66BB6A, 0) : color.new(#00E676, 0)

f_grade(float sc) =>
    sc <= 20 ? "D" : sc <= 35 ? "C" : sc <= 50 ? "C+" : sc <= 60 ? "B" : sc <= 70 ? "B+" : sc <= 80 ? "A" : sc <= 90 ? "A+" : "S"

f_dashPosition(string pos) =>
    switch pos
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        => position.top_right

// ─────────────────────────────────────────────────────────────────────
// SCORING ENGINE — 10 PILLARS (each 0–10 pts, total 0–100)
// ─────────────────────────────────────────────────────────────────────

// ──── PILLAR 1: DISPLACEMENT & CISD (0–10) ────
// ICT: Displacement = strong institutional candle, body > 70% of range,
// range > 1.5x ATR. CISD = close above/below opening of prior sequence.
f_scoreDisplacement(bool isBull, int idx) =>
    float sc = 0.0
    float bodySize = math.abs(close[idx] - open[idx])
    float candleRange = high[idx] - low[idx]
    float bodyRatio = candleRange > 0 ? bodySize / candleRange : 0
    float atrRatio = atr14 > 0 ? candleRange / atr14 : 0

    // Body ratio: ICT "institutional candle" = body > 70% of range
    if bodyRatio > 0.80
        sc += 3.0     // Very strong displacement candle
    else if bodyRatio > 0.70
        sc += 2.0     // Institutional candle
    else if bodyRatio > 0.50
        sc += 1.0     // Moderate

    // ATR ratio: How impulsive relative to normal volatility
    if atrRatio > 2.5
        sc += 4.0     // Extreme displacement
    else if atrRatio > 1.8
        sc += 3.0
    else if atrRatio > 1.2
        sc += 2.0
    else if atrRatio > 0.8
        sc += 0.5

    // CISD: Check if close of displacement candle crosses the open of the prior candle
    // (Change in State of Delivery confirmation)
    bool cisd = false
    if isBull and close[idx] > open[idx + 1] and close[idx + 1] < open[idx + 1]
        cisd := true
    else if not isBull and close[idx] < open[idx + 1] and close[idx + 1] > open[idx + 1]
        cisd := true
    if cisd
        sc += 3.0     // CISD confirmed — strong signal

    math.min(sc, 10.0)


// ──── PILLAR 2: LIQUIDITY SWEEP (0–10) ────
// ICT: The best setups occur AFTER liquidity is taken. Check PDH/PDL,
// swing highs/lows, and IPDA levels (20/40/60-day H/L).
f_scoreLiqSweep(bool isBull, int startIdx) =>
    float sc = 0.0

    if isBull
        // For bullish zones: SSL (sell-side) should have been swept
        for j = startIdx to math.min(startIdx + 15, 499)
            // Swept a swing low
            if not na(lastSL) and low[j] < lastSL
                sc := math.max(sc, 6.0)
                break
            // Swept prior day low — very significant
            if not na(pdl) and low[j] < pdl
                sc := math.max(sc, 8.0)
                break
            // Near a swing low (within 0.3 ATR)
            if not na(lastSL) and math.abs(low[j] - lastSL) <= atr14 * 0.3
                sc := math.max(sc, 4.0)
                break

        // IPDA level sweep bonus
        if not na(ipda20L)
            for j = startIdx to math.min(startIdx + 15, 499)
                if low[j] <= ipda20L
                    sc := math.min(sc + 2.0, 10.0)
                    break
    else
        // For bearish zones: BSL (buy-side) should have been swept
        for j = startIdx to math.min(startIdx + 15, 499)
            if not na(lastSH) and high[j] > lastSH
                sc := math.max(sc, 6.0)
                break
            if not na(pdh) and high[j] > pdh
                sc := math.max(sc, 8.0)
                break
            if not na(lastSH) and math.abs(high[j] - lastSH) <= atr14 * 0.3
                sc := math.max(sc, 4.0)
                break

        if not na(ipda20H)
            for j = startIdx to math.min(startIdx + 15, 499)
                if high[j] >= ipda20H
                    sc := math.min(sc + 2.0, 10.0)
                    break
    sc


// ──── PILLAR 3: PREMIUM / DISCOUNT (0–10) ────
// ICT: Buy in Discount (below 50%), Sell in Premium (above 50%).
// Deep discount/premium scores highest.
f_scorePD(bool isBull, float zoneTop, float zoneBot) =>
    float sc = 0.0
    float zoneMid = (zoneTop + zoneBot) / 2.0
    if drRange > 0
        float pctFromLow = (zoneMid - drLow) / drRange
        if isBull
            if pctFromLow <= 0.20
                sc := 10.0   // Deep discount — ideal for longs
            else if pctFromLow <= 0.35
                sc := 8.0
            else if pctFromLow <= 0.50
                sc := 5.0    // Near equilibrium
            else if pctFromLow <= 0.65
                sc := 2.0    // Slight premium — risky for longs
            else
                sc := 0.0    // Deep premium — bad for longs
        else
            if pctFromLow >= 0.80
                sc := 10.0   // Deep premium — ideal for shorts
            else if pctFromLow >= 0.65
                sc := 8.0
            else if pctFromLow >= 0.50
                sc := 5.0    // Near equilibrium
            else if pctFromLow >= 0.35
                sc := 2.0    // Slight discount — risky for shorts
            else
                sc := 0.0    // Deep discount — bad for shorts
    sc


// ──── PILLAR 4: MARKET STRUCTURE ALIGNMENT (0–10) ────
// ICT: With-trend setups (after BOS) are continuation. After MSS = reversal.
// Counter-trend without MSS = low probability.
f_scoreStructure(bool isBull) =>
    float sc = 0.0
    if isBull and trend == 1
        sc := 10.0   // Bullish zone in bullish structure
    else if not isBull and trend == -1
        sc := 10.0   // Bearish zone in bearish structure
    else if trend == 0
        sc := 5.0    // Neutral / consolidation
    else
        sc := 1.0    // Counter-trend — risky without MSS
    sc


// ──── PILLAR 5: HTF BIAS CONFIRMATION (0–10) ────
// ICT: Always check the higher timeframe. Trading against HTF = low prob.
f_scoreHTF(bool isBull) =>
    float sc = 0.0
    if isBull and htfBias == 1
        sc := 10.0   // HTF bullish, zone bullish — aligned
    else if not isBull and htfBias == -1
        sc := 10.0   // HTF bearish, zone bearish — aligned
    else if htfBias == 0
        sc := 5.0    // HTF neutral (doji/indecision)
    else
        sc := 1.0    // Misaligned with HTF — low probability
    sc


// ──── PILLAR 6: OTE FIBONACCI CONFLUENCE (0–10) ────
// ICT: OTE zone = 62%–79% retracement. 70.5% is the "sweet spot".
// Zones sitting inside OTE score highest.
f_scoreOTE(bool isBull, float zoneTop, float zoneBot) =>
    float sc = 0.0
    float zoneMid = (zoneTop + zoneBot) / 2.0

    if drRange > 0
        // For bullish: OTE is measured from the swing high down
        // ote62, ote705, ote79 are calculated from drHigh
        // Bullish OTE zone = between ote62 and ote79 (discount side)
        if isBull
            if zoneMid >= ote79 and zoneMid <= ote62
                // Inside OTE zone
                float distTo705 = math.abs(zoneMid - ote705)
                float oteBandWidth = math.abs(ote62 - ote79)
                if oteBandWidth > 0 and distTo705 / oteBandWidth <= 0.15
                    sc := 10.0   // Right at 70.5% sweet spot
                else
                    sc := 7.0    // Inside OTE band
            else if zoneMid >= ote79 - atr14 * 0.5 and zoneMid <= ote62 + atr14 * 0.5
                sc := 4.0        // Near OTE zone
        else
            // For bearish: OTE is the premium mirror
            // Premium OTE = drLow + drRange * 0.62 to drLow + drRange * 0.79
            float bearOte62 = drLow + drRange * 0.62
            float bearOte705 = drLow + drRange * 0.705
            float bearOte79 = drLow + drRange * 0.79
            if zoneMid >= bearOte62 and zoneMid <= bearOte79
                float distTo705 = math.abs(zoneMid - bearOte705)
                float oteBandWidth = math.abs(bearOte79 - bearOte62)
                if oteBandWidth > 0 and distTo705 / oteBandWidth <= 0.15
                    sc := 10.0
                else
                    sc := 7.0
            else if zoneMid >= bearOte62 - atr14 * 0.5 and zoneMid <= bearOte79 + atr14 * 0.5
                sc := 4.0
    sc


// ──── PILLAR 7: FVG + OB OVERLAP (0–10) ────
// ICT: When an FVG overlaps with an OB at the same level, it creates
// the highest-probability "confluence zone". This is scored dynamically
// after zone creation by scanning existing zones.
f_scoreOverlap(bool isBull, bool isFVG, float zTop, float zBot) =>
    float sc = 0.0
    if array.size(activeZones) > 0
        for i = 0 to array.size(activeZones) - 1
            Zone existing = array.get(activeZones, i)
            if existing.mitigated
                continue
            // Look for opposing type (FVG vs OB) with same direction
            if existing.isFVG != isFVG and existing.isBull == isBull
                float overlapTop = math.min(zTop, existing.top)
                float overlapBot = math.max(zBot, existing.bot)
                if overlapTop > overlapBot
                    // There IS overlap — score based on overlap percentage
                    float zSize = zTop - zBot
                    float overlapSize = overlapTop - overlapBot
                    float overlapPct = zSize > 0 ? overlapSize / zSize : 0
                    if overlapPct > 0.5
                        sc := 10.0   // Significant overlap
                    else if overlapPct > 0.2
                        sc := 6.0
                    else
                        sc := 3.0    // Partial overlap
                    break
    sc


// ──── PILLAR 8: VOLUME CONFIRMATION (0–10) ────
// ICT: Institutional moves carry volume. Above-average volume on
// displacement candle = institutional sponsorship.
f_scoreVolume(int idx) =>
    float sc = 0.0
    float vol = volume[idx]
    if avgVol > 0
        float volRatio = vol / avgVol
        if volRatio > 3.0
            sc := 10.0   // Extreme volume — clear institutional activity
        else if volRatio > 2.0
            sc := 8.0
        else if volRatio > 1.5
            sc := 6.0
        else if volRatio > 1.0
            sc := 3.0    // Above average
        else
            sc := 1.0    // Below average — low conviction
    sc


// ──── PILLAR 9: KILL ZONE TIMING (0–10) ────
// ICT: "Time supersedes price." Kill Zones and Silver Bullet windows
// are when institutions execute. Asian session is accumulation (lower prob).
f_scoreSession() =>
    float sc = 0.0
    if inKZ_NYAM
        sc := 10.0   // NY AM Kill Zone — highest volume session
    else if inKZ_London
        sc := 9.0    // London Kill Zone — major session
    else if inKZ_SB1 or inKZ_SB2
        sc := 9.0    // Silver Bullet windows — precision timing
    else if inKZ_NYPM
        sc := 7.0    // NY PM — still active but lower
    else if inAsian
        sc := 2.0    // Asian session — accumulation, low displacement
    else
        sc := 4.0    // Regular hours outside KZ
    sc


// ──── PILLAR 10: FRESHNESS / UNMITIGATED (0–10) ────
// ICT: First touch of an FVG/OB is the highest probability.
// Zones lose relevance over time if untested.
f_scoreFreshness(int creationBar_idx) =>
    float sc = 0.0
    int age = bar_index - creationBar_idx
    if age <= 2
        sc := 10.0   // Brand new, first candle after formation
    else if age <= 5
        sc := 8.0
    else if age <= 15
        sc := 6.0
    else if age <= 30
        sc := 4.0
    else if age <= 60
        sc := 2.0
    else
        sc := 1.0    // Very old — significantly less reliable
    sc


// ─────────────────────────────────────────────────────────────────────
// IPDA REFERENCE LINES (optional visual)
// ─────────────────────────────────────────────────────────────────────
var line ipda20H_line = na
var line ipda20L_line = na

if showIPDA and barstate.islast
    if not na(ipda20H_line)
        line.delete(ipda20H_line)
    if not na(ipda20L_line)
        line.delete(ipda20L_line)
    ipda20H_line := line.new(bar_index - 20, ipda20H, bar_index + 5, ipda20H, color=color.new(color.aqua, 50), style=line.style_dotted, width=1)
    ipda20L_line := line.new(bar_index - 20, ipda20L, bar_index + 5, ipda20L, color=color.new(color.aqua, 50), style=line.style_dotted, width=1)


// ─────────────────────────────────────────────────────────────────────
// ZONE DETECTION & SCORING
// ─────────────────────────────────────────────────────────────────────

if barstate.isconfirmed and inWindow

    // ── FVG Detection ──
    if useFVG
        bool isBullFVG = low > high[2]
        bool isBearFVG = high < low[2]

        if isBullFVG
            float fTop = low
            float fBot = high[2]
            float s1 = f_scoreDisplacement(true, 1)
            float s2 = f_scoreLiqSweep(true, 2)
            float s3 = f_scorePD(true, fTop, fBot)
            float s4 = f_scoreStructure(true)
            float s5 = f_scoreHTF(true)
            float s6 = f_scoreOTE(true, fTop, fBot)
            float s7 = f_scoreOverlap(true, true, fTop, fBot)
            float s8 = f_scoreVolume(1)
            float s9 = f_scoreSession()
            float s10 = f_scoreFreshness(bar_index)
            float totalScore = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10

            string bd = "═══ BISI Quality Score ═══\n"
             + "❶ Displacement/CISD: " + str.tostring(s1, "#.#") + "/10\n"
             + "❷ Liq Sweep:         " + str.tostring(s2, "#.#") + "/10\n"
             + "❸ Prem/Disc Zone:    " + str.tostring(s3, "#.#") + "/10\n"
             + "❹ Mkt Structure:     " + str.tostring(s4, "#.#") + "/10\n"
             + "❺ HTF Bias:          " + str.tostring(s5, "#.#") + "/10\n"
             + "❻ OTE Confluence:    " + str.tostring(s6, "#.#") + "/10\n"
             + "❼ FVG+OB Overlap:    " + str.tostring(s7, "#.#") + "/10\n"
             + "❽ Volume:            " + str.tostring(s8, "#.#") + "/10\n"
             + "❾ Kill Zone:         " + str.tostring(s9, "#.#") + "/10\n"
             + "❿ Freshness:         " + str.tostring(s10, "#.#") + "/10\n"
             + "═════════════════════\n"
             + "TOTAL: " + str.tostring(totalScore, "#.#") + "/100 [" + f_grade(totalScore) + "]"

            if totalScore >= minScore
                color boxCol = f_scoreColor(totalScore)
                box bx = box.new(bar_index - 2, fTop, bar_index, fBot, border_color=color.new(boxCol, 0), bgcolor=boxCol)
                label lbl = na
                if showScoreLabels
                    string lt = "BISI " + str.tostring(totalScore, "#") + " [" + f_grade(totalScore) + "]"
                    lbl := label.new(bar_index, fTop, text=lt, tooltip=bd, textcolor=f_scoreTextColor(totalScore), color=color.new(color.white, 100), style=label.style_label_down, size=size.tiny)
                line ce = na
                if showCELine
                    ce := line.new(bar_index - 2, (fTop + fBot) / 2.0, bar_index, (fTop + fBot) / 2.0, color=color.new(boxCol, 20), style=line.style_dotted)
                array.push(activeZones, Zone.new(fTop, fBot, true, true, bar_index - 2, bar_index, totalScore, bd, false, false, s7 > 0, bx, lbl, ce, na))

        if isBearFVG
            float fTop = low[2]
            float fBot = high
            float s1 = f_scoreDisplacement(false, 1)
            float s2 = f_scoreLiqSweep(false, 2)
            float s3 = f_scorePD(false, fTop, fBot)
            float s4 = f_scoreStructure(false)
            float s5 = f_scoreHTF(false)
            float s6 = f_scoreOTE(false, fTop, fBot)
            float s7 = f_scoreOverlap(false, true, fTop, fBot)
            float s8 = f_scoreVolume(1)
            float s9 = f_scoreSession()
            float s10 = f_scoreFreshness(bar_index)
            float totalScore = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10

            string bd = "═══ SIBI Quality Score ═══\n"
             + "❶ Displacement/CISD: " + str.tostring(s1, "#.#") + "/10\n"
             + "❷ Liq Sweep:         " + str.tostring(s2, "#.#") + "/10\n"
             + "❸ Prem/Disc Zone:    " + str.tostring(s3, "#.#") + "/10\n"
             + "❹ Mkt Structure:     " + str.tostring(s4, "#.#") + "/10\n"
             + "❺ HTF Bias:          " + str.tostring(s5, "#.#") + "/10\n"
             + "❻ OTE Confluence:    " + str.tostring(s6, "#.#") + "/10\n"
             + "❼ FVG+OB Overlap:    " + str.tostring(s7, "#.#") + "/10\n"
             + "❽ Volume:            " + str.tostring(s8, "#.#") + "/10\n"
             + "❾ Kill Zone:         " + str.tostring(s9, "#.#") + "/10\n"
             + "❿ Freshness:         " + str.tostring(s10, "#.#") + "/10\n"
             + "═════════════════════\n"
             + "TOTAL: " + str.tostring(totalScore, "#.#") + "/100 [" + f_grade(totalScore) + "]"

            if totalScore >= minScore
                color boxCol = f_scoreColor(totalScore)
                box bx = box.new(bar_index - 2, fTop, bar_index, fBot, border_color=color.new(boxCol, 0), bgcolor=boxCol)
                label lbl = na
                if showScoreLabels
                    string lt = "SIBI " + str.tostring(totalScore, "#") + " [" + f_grade(totalScore) + "]"
                    lbl := label.new(bar_index, fBot, text=lt, tooltip=bd, textcolor=f_scoreTextColor(totalScore), color=color.new(color.white, 100), style=label.style_label_up, size=size.tiny)
                line ce = na
                if showCELine
                    ce := line.new(bar_index - 2, (fTop + fBot) / 2.0, bar_index, (fTop + fBot) / 2.0, color=color.new(boxCol, 20), style=line.style_dotted)
                array.push(activeZones, Zone.new(fTop, fBot, false, true, bar_index - 2, bar_index, totalScore, bd, false, false, s7 > 0, bx, lbl, ce, na))

    // ── Order Block Detection ──
    if useOB
        bool isBullFVG_ob = low > high[2]
        bool isBearFVG_ob = high < low[2]

        if isBullFVG_ob
            int obIdx = na
            for j = 2 to obScanDepth
                if j < 500 and close[j] < open[j]  // Last down-close candle
                    obIdx := j
                    break
            if not na(obIdx)
                float obTop = high[obIdx]
                float obBot = low[obIdx]

                float s1 = f_scoreDisplacement(true, 1)
                float s2 = f_scoreLiqSweep(true, obIdx)
                float s3 = f_scorePD(true, obTop, obBot)
                float s4 = f_scoreStructure(true)
                float s5 = f_scoreHTF(true)
                float s6 = f_scoreOTE(true, obTop, obBot)
                float s7 = f_scoreOverlap(true, false, obTop, obBot)
                float s8 = f_scoreVolume(obIdx)
                float s9 = f_scoreSession()
                float s10 = f_scoreFreshness(bar_index)
                float totalScore = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10

                string bd = "═══ +OB Quality Score ═══\n"
                 + "❶ Displacement/CISD: " + str.tostring(s1, "#.#") + "/10\n"
                 + "❷ Liq Sweep:         " + str.tostring(s2, "#.#") + "/10\n"
                 + "❸ Prem/Disc Zone:    " + str.tostring(s3, "#.#") + "/10\n"
                 + "❹ Mkt Structure:     " + str.tostring(s4, "#.#") + "/10\n"
                 + "❺ HTF Bias:          " + str.tostring(s5, "#.#") + "/10\n"
                 + "❻ OTE Confluence:    " + str.tostring(s6, "#.#") + "/10\n"
                 + "❼ FVG+OB Overlap:    " + str.tostring(s7, "#.#") + "/10\n"
                 + "❽ Volume:            " + str.tostring(s8, "#.#") + "/10\n"
                 + "❾ Kill Zone:         " + str.tostring(s9, "#.#") + "/10\n"
                 + "❿ Freshness:         " + str.tostring(s10, "#.#") + "/10\n"
                 + "═════════════════════\n"
                 + "TOTAL: " + str.tostring(totalScore, "#.#") + "/100 [" + f_grade(totalScore) + "]"

                if totalScore >= minScore
                    color boxCol = f_scoreColor(totalScore)
                    box bx = box.new(bar_index[obIdx], obTop, bar_index, obBot, border_color=color.new(boxCol, 0), bgcolor=color.new(boxCol, 10), border_width=2, border_style=line.style_dashed)
                    label lbl = na
                    if showScoreLabels
                        string lt = "+OB " + str.tostring(totalScore, "#") + " [" + f_grade(totalScore) + "]"
                        lbl := label.new(bar_index, obTop, text=lt, tooltip=bd, textcolor=f_scoreTextColor(totalScore), color=color.new(color.white, 100), style=label.style_label_down, size=size.tiny)
                    line ce = na
                    if showCELine
                        ce := line.new(bar_index[obIdx], (obTop + obBot) / 2.0, bar_index, (obTop + obBot) / 2.0, color=color.new(boxCol, 20), style=line.style_dotted)
                    line mt = na
                    if showMTLine
                        mt := line.new(bar_index[obIdx], (obTop + obBot) / 2.0, bar_index, (obTop + obBot) / 2.0, color=color.new(boxCol, 40), style=line.style_solid, width=1)
                    array.push(activeZones, Zone.new(obTop, obBot, true, false, bar_index[obIdx], bar_index, totalScore, bd, false, false, s7 > 0, bx, lbl, ce, mt))

        if isBearFVG_ob
            int obIdx = na
            for j = 2 to obScanDepth
                if j < 500 and close[j] > open[j]  // Last up-close candle
                    obIdx := j
                    break
            if not na(obIdx)
                float obTop = high[obIdx]
                float obBot = low[obIdx]

                float s1 = f_scoreDisplacement(false, 1)
                float s2 = f_scoreLiqSweep(false, obIdx)
                float s3 = f_scorePD(false, obTop, obBot)
                float s4 = f_scoreStructure(false)
                float s5 = f_scoreHTF(false)
                float s6 = f_scoreOTE(false, obTop, obBot)
                float s7 = f_scoreOverlap(false, false, obTop, obBot)
                float s8 = f_scoreVolume(obIdx)
                float s9 = f_scoreSession()
                float s10 = f_scoreFreshness(bar_index)
                float totalScore = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8 + s9 + s10

                string bd = "═══ -OB Quality Score ═══\n"
                 + "❶ Displacement/CISD: " + str.tostring(s1, "#.#") + "/10\n"
                 + "❷ Liq Sweep:         " + str.tostring(s2, "#.#") + "/10\n"
                 + "❸ Prem/Disc Zone:    " + str.tostring(s3, "#.#") + "/10\n"
                 + "❹ Mkt Structure:     " + str.tostring(s4, "#.#") + "/10\n"
                 + "❺ HTF Bias:          " + str.tostring(s5, "#.#") + "/10\n"
                 + "❻ OTE Confluence:    " + str.tostring(s6, "#.#") + "/10\n"
                 + "❼ FVG+OB Overlap:    " + str.tostring(s7, "#.#") + "/10\n"
                 + "❽ Volume:            " + str.tostring(s8, "#.#") + "/10\n"
                 + "❾ Kill Zone:         " + str.tostring(s9, "#.#") + "/10\n"
                 + "❿ Freshness:         " + str.tostring(s10, "#.#") + "/10\n"
                 + "═════════════════════\n"
                 + "TOTAL: " + str.tostring(totalScore, "#.#") + "/100 [" + f_grade(totalScore) + "]"

                if totalScore >= minScore
                    color boxCol = f_scoreColor(totalScore)
                    box bx = box.new(bar_index[obIdx], obTop, bar_index, obBot, border_color=color.new(boxCol, 0), bgcolor=color.new(boxCol, 10), border_width=2, border_style=line.style_dashed)
                    label lbl = na
                    if showScoreLabels
                        string lt = "-OB " + str.tostring(totalScore, "#") + " [" + f_grade(totalScore) + "]"
                        lbl := label.new(bar_index, obBot, text=lt, tooltip=bd, textcolor=f_scoreTextColor(totalScore), color=color.new(color.white, 100), style=label.style_label_up, size=size.tiny)
                    line ce = na
                    if showCELine
                        ce := line.new(bar_index[obIdx], (obTop + obBot) / 2.0, bar_index, (obTop + obBot) / 2.0, color=color.new(boxCol, 20), style=line.style_dotted)
                    line mt = na
                    if showMTLine
                        mt := line.new(bar_index[obIdx], (obTop + obBot) / 2.0, bar_index, (obTop + obBot) / 2.0, color=color.new(boxCol, 40), style=line.style_solid, width=1)
                    array.push(activeZones, Zone.new(obTop, obBot, false, false, bar_index[obIdx], bar_index, totalScore, bd, false, false, s7 > 0, bx, lbl, ce, mt))


    // ─────────────────────────────────────────────────────────────────
    // ZONE MANAGEMENT: Extend, CE Detection, Mitigation, Decay
    // ─────────────────────────────────────────────────────────────────

    if array.size(activeZones) > 0
        for i = array.size(activeZones) - 1 to 0
            Zone z = array.get(activeZones, i)
            if z.mitigated
                continue

            bool shouldMitigate = false
            float ceMid = (z.top + z.bot) / 2.0

            // CE Detection
            if not z.ceHit
                if z.isBull and low <= ceMid
                    z.ceHit := true
                else if not z.isBull and high >= ceMid
                    z.ceHit := true

            // Mitigation Check
            if z.isBull
                shouldMitigate := mitigateMode == "Wick" ? low <= z.bot : close <= z.bot
            else
                shouldMitigate := mitigateMode == "Wick" ? high >= z.top : close >= z.top

            if shouldMitigate
                z.mitigated := true
                box.set_right(z.bx, bar_index)
                if not na(z.ceLine)
                    line.set_x2(z.ceLine, bar_index)
                if not na(z.mtLine)
                    line.set_x2(z.mtLine, bar_index)
                if not showMitigated
                    box.delete(z.bx)
                    if not na(z.lbl)
                        label.delete(z.lbl)
                    if not na(z.ceLine)
                        line.delete(z.ceLine)
                    if not na(z.mtLine)
                        line.delete(z.mtLine)
                    array.remove(activeZones, i)
                else
                    box.set_bgcolor(z.bx, color.new(color.gray, 90))
                    box.set_border_color(z.bx, color.new(color.gray, 60))
                    if not na(z.lbl)
                        label.set_textcolor(z.lbl, color.new(color.gray, 40))
                        label.set_text(z.lbl, label.get_text(z.lbl) + " ✗")
            else
                // Extend active zone visuals
                box.set_right(z.bx, bar_index)
                if not na(z.ceLine)
                    line.set_x2(z.ceLine, bar_index)
                if not na(z.mtLine)
                    line.set_x2(z.mtLine, bar_index)
                if not na(z.lbl)
                    label.set_x(z.lbl, bar_index)

                // Dynamic freshness decay — fade color as zone ages
                float currentFresh = f_scoreFreshness(z.creationBar)
                float decay = 10.0 - currentFresh
                if decay > 0
                    float adjScore = math.max(z.score - decay, 0)
                    color newCol = f_scoreColor(adjScore)
                    box.set_bgcolor(z.bx, z.isFVG ? newCol : color.new(newCol, 10))
                    box.set_border_color(z.bx, color.new(newCol, 0))

    // ── Garbage Collection ──
    if array.size(activeZones) > 200
        Zone old = array.shift(activeZones)
        box.delete(old.bx)
        if not na(old.lbl)
            label.delete(old.lbl)
        if not na(old.ceLine)
            line.delete(old.ceLine)
        if not na(old.mtLine)
            line.delete(old.mtLine)


// ─────────────────────────────────────────────────────────────────────
// REAL-TIME DASHBOARD
// ─────────────────────────────────────────────────────────────────────

if showDash and barstate.islast
    var table dash = table.new(f_dashPosition(dashPos), 7, 13, bgcolor=color.new(#0d1117, 5), border_color=color.new(#161b22, 0), border_width=1, frame_color=color.new(#30363d, 0), frame_width=2)

    // Title Row
    table.cell(dash, 0, 0, "ICT Zone Scorer", text_color=color.new(#58a6ff, 0), text_size=size.tiny, text_halign=text.align_left)
    table.merge_cells(dash, 0, 0, 6, 0)

    // Header Row
    table.cell(dash, 0, 1, "Type",    text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 1, 1, "Side",    text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 2, 1, "Score",   text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 3, 1, "Grade",   text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 4, 1, "Level",   text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 5, 1, "CE",      text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_center)
    table.cell(dash, 6, 1, "OB+FVG",  text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_center)

    // Collect and sort active zones by score (descending)
    var array<int> shownIdx = array.new_int()
    array.clear(shownIdx)
    var array<float> tempScores = array.new_float()
    array.clear(tempScores)

    if array.size(activeZones) > 0
        for i = 0 to array.size(activeZones) - 1
            Zone z = array.get(activeZones, i)
            if not z.mitigated
                array.push(shownIdx, i)
                array.push(tempScores, z.score)

    // Sort descending
    if array.size(tempScores) > 1
        for pass = 0 to array.size(tempScores) - 2
            for j = 0 to array.size(tempScores) - 2 - pass
                if array.get(tempScores, j) < array.get(tempScores, j + 1)
                    float tmpSc = array.get(tempScores, j)
                    array.set(tempScores, j, array.get(tempScores, j + 1))
                    array.set(tempScores, j + 1, tmpSc)
                    int tmpIdx = array.get(shownIdx, j)
                    array.set(shownIdx, j, array.get(shownIdx, j + 1))
                    array.set(shownIdx, j + 1, tmpIdx)

    int rowCount = math.min(array.size(shownIdx), 10)
    if rowCount > 0
        for row = 0 to rowCount - 1
            int zIdx = array.get(shownIdx, row)
            Zone z = array.get(activeZones, zIdx)
            string typeStr = z.isFVG ? "FVG" : "OB"
            string sideStr = z.isBull ? "▲ Bull" : "▼ Bear"
            color sideCol = z.isBull ? color.new(#3fb950, 0) : color.new(#f85149, 0)
            color scoreCol = f_scoreTextColor(z.score)
            string ceStr = z.ceHit ? "⚠" : "✓"
            color ceCol = z.ceHit ? color.new(#d29922, 0) : color.new(#3fb950, 0)
            string overlapStr = z.hasOverlap ? "★" : "—"
            color overlapCol = z.hasOverlap ? color.new(#f0883e, 0) : color.new(#484f58, 0)
            string priceStr = str.tostring((z.top + z.bot) / 2.0, format.mintick)

            table.cell(dash, 0, row + 2, typeStr,                                text_color=color.new(#c9d1d9, 0), text_size=size.tiny, text_halign=text.align_center)
            table.cell(dash, 1, row + 2, sideStr,                                text_color=sideCol,                text_size=size.tiny, text_halign=text.align_center)
            table.cell(dash, 2, row + 2, str.tostring(z.score, "#.#"),            text_color=scoreCol,               text_size=size.tiny, text_halign=text.align_center)
            table.cell(dash, 3, row + 2, f_grade(z.score),                        text_color=scoreCol,               text_size=size.tiny, text_halign=text.align_center)
            table.cell(dash, 4, row + 2, priceStr,                                text_color=color.new(#c9d1d9, 20), text_size=size.tiny, text_halign=text.align_center)
            table.cell(dash, 5, row + 2, ceStr,                                   text_color=ceCol,                  text_size=size.tiny, text_halign=text.align_center)
            table.cell(dash, 6, row + 2, overlapStr,                              text_color=overlapCol,             text_size=size.tiny, text_halign=text.align_center)
    else
        table.cell(dash, 0, 2, "No active zones above threshold", text_color=color.new(#484f58, 0), text_size=size.tiny, text_halign=text.align_center)
        table.merge_cells(dash, 0, 2, 6, 2)

    // Footer: Current market context
    string ctxTrend = trend == 1 ? "▲ Bullish" : trend == -1 ? "▼ Bearish" : "◆ Neutral"
    string ctxHTF = htfBias == 1 ? "▲ Bullish" : htfBias == -1 ? "▼ Bearish" : "◆ Neutral"
    string ctxKZ = inKZ ? "✓ Active" : "✗ Outside"
    color trendCol = trend == 1 ? color.new(#3fb950, 0) : trend == -1 ? color.new(#f85149, 0) : color.new(#8b949e, 0)
    color htfCol = htfBias == 1 ? color.new(#3fb950, 0) : htfBias == -1 ? color.new(#f85149, 0) : color.new(#8b949e, 0)
    color kzCol = inKZ ? color.new(#3fb950, 0) : color.new(#f85149, 0)

    int footerRow = rowCount > 0 ? rowCount + 2 : 3
    table.cell(dash, 0, footerRow, "Struct:", text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 1, footerRow, ctxTrend, text_color=trendCol, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 2, footerRow, "HTF:", text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 3, footerRow, ctxHTF, text_color=htfCol, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 4, footerRow, "KZ:", text_color=color.new(#8b949e, 0), text_size=size.tiny, text_halign=text.align_right)
    table.cell(dash, 5, footerRow, ctxKZ, text_color=kzCol, text_size=size.tiny, text_halign=text.align_left)
````
