# Round Number Magnet Map [AGPro Series]

- url: https://www.tradingview.com/script/fPuNv4g1-Round-Number-Magnet-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;5be610efd55d482c9df24f993e3d8d4c
- version: 5.0

## Description

Round Number Magnet Map [AGPro Series]
════════════════════════════════════════

🔹 OVERVIEW

Round numbers act as psychological magnets on every liquid market. Traders cluster stop orders, limit orders, and mental entries around levels like 2000, 2400, 50000. These levels attract price, get tested repeatedly, and either hold with sharp reactions or break with decisive momentum. Yet most round-number tools ship a hard-coded list (100, 500, 1000) that works on some charts and fails on others.

Round Number Magnet Map is a psychological level engine that detects the right round numbers for any symbol automatically, tracks every touch with a composite reaction grading system, and ranks the strongest magnets in a professional leaderboard. It works out of the box on Bitcoin at 100k, on Ethereum at 2k, on Solana at 10, on EUR/USD at 1.05, on the S&P 500 at 5000, and on gold at 2400 — no configuration required. Traders who prefer manual control can override the auto-detected tiers with their own comma-separated list.

The indicator is asset-agnostic, non-repainting, bar-confirmed, and optimized for speed. It is designed to be a permanent chart companion on any timeframe.


🔹 UNIQUE EDGE

What separates Round Number Magnet Map from generic round-number indicators:

1. Asset-aware auto-detection. The script reads current price magnitude and selects the correct tier spacing automatically — 10000/5000/1000 for high-cap assets, 100/50/10 for mid-cap, 0.01/0.005/0.001 for forex majors. Three nested tiers render simultaneously so both major and minor psychological levels are visible with a clear visual hierarchy.

2. Composite reaction grading. Each touch is not just counted — it is graded. The script combines three inputs: ATR reaction (how many ATRs price traveled after the touch), wick rejection ratio (how strongly the touch bar rejected the level), and relative volume (whether institutional flow confirmed the reaction). The result is a 0-100 score mapped to A/B/C/D grades, so traders can distinguish a truly respected magnet from a level that price simply grazed.

3. Broken-level recovery logic. Most tools mark a level as "broken" the first time price closes through it and leave it broken forever. That is wrong on round numbers — price oscillates around 2000, 3000, 10000 repeatedly across months and years. This engine un-breaks a level the moment price returns to its zone, so the map always reflects current reality.

4. On-chart leaderboard. The panel ranks the top 5 most-touched levels visible in the current chart window, with touch count and composite grade, so the strongest magnets are always one glance away.

5. Clean by design. Rendering is restricted to an ATR-scaled window around current price, with optional toggles to hide broken and untouched levels. The chart stays readable even on high timeframes where dozens of round numbers would otherwise clutter the view.


🔹 METHODOLOGY

Tier generation. When auto-detect is enabled, the script classifies current price into a magnitude bucket (>10000, 1000-10000, 100-1000, 10-100, 1-10, <1, etc.) and assigns a three-tier spacing. Tier 0 is the major step, tier 1 is a half-step, tier 2 is a fine step. All three tiers are generated around current price within an ATR-scaled search range, deduplicated, and capped at a configurable maximum (default 20).

Touch detection. Each level is surrounded by a zone of thickness (ATR × configurable multiplier, default 0.20). A touch is registered when a bar's high-low range intersects the zone and at least N bars have passed since the last touch on that level (cooldown, default 5). This prevents a single consolidation from inflating the touch count.

Reaction grading. Exactly N bars after a touch (default 5), the script computes:

• ATR reaction (60% weight): maximum favorable excursion from the level in the direction of the test, normalized against a target of 2 ATRs = score 100.
• Wick rejection (25% weight): the rejection wick on the touch bar relative to the bar's range.
• Relative volume (15% weight): volume on the touch bar relative to the 20-bar average.

The three components are combined into a single 0-100 composite score. Scores of 80+ are grade A, 65-80 are grade B, 45-65 are grade C, below 45 are grade D.

Break detection. A level is marked as broken only when, during a reaction grading, price has closed beyond the zone by an additional 0.3 ATR in the opposite direction of the test. This strict criterion avoids false breaks from single wicks or low-conviction closes. Broken levels are un-marked automatically when price returns to the zone.

Rendering. Active non-broken levels render as solid blue lines with an optional S/R-style zone box. Broken levels render as dashed gray lines with a BRK badge. Labels show price, touch count, and grade. Priority-0 (major) levels render with increased line width, and levels within 1 ATR of price render thicker still (magnet effect).


🔹 SIGNALS & ALERTS

The script generates four non-repainting, bar-confirmed alert conditions:

• Touch — price has entered a round-number zone.
• Held (Strong Reaction) — a touch has resolved with a composite score ≥ 60, meaning the level held with meaningful reaction strength.
• Broken — a level has been decisively broken by a strong close beyond the zone.
• Magnet Approach — price is within 0.5 ATR of a level, approaching without yet touching.

Each alert fires at bar close and carries ticker and timeframe tokens for routing to external automation.


🔹 KEY INPUTS

Detection
• Auto-Detect Tiers — asset-aware tier selection (recommended).
• Custom Tiers — comma-separated override (e.g., "1000,500,100" for BTC).
• Level Search Range — how far from price to generate levels, in ATR-scaled units.
• Max Active Levels — hard cap on rendered levels (default 20).

Touch & Zone
• Zone Thickness — size of each round-number zone in ATR units (default 0.20).
• ATR Length — period for ATR used in zone and reaction calculations (default 14).
• Touch Cooldown — minimum bars between touches on the same level (default 5).
• Reaction Window — bars after a touch used for reaction grading (default 5).

Reaction Grading
• Weight: ATR Reaction / Wick Rejection / Relative Volume — configurable composite weights. Weights are normalized automatically if they do not sum to 1.
• ATR Normalization Target — the ATR-reaction value that maps to score 100.

Visuals
• Show Zones, Show Level Labels, Hide Broken Levels, Hide Untouched Levels, Magnet Effect.
• Far Levels Transparency, Label Size, Label Offset.

Panel
• Show Panel, Panel Location (6 options), Panel Theme (Dark/Light), Panel Font Size.

Alerts
• Independent toggles for Touch, Held, Broken, Magnet Approach.


🔹 HOW TO USE

The indicator is designed for discretionary trading and framework-based decision making. A few practical patterns:

1. Use the nearest Above and Below levels in the panel as your immediate target and invalidation reference. The Strongest line on the panel is the highest-conviction magnet in view.

2. Grade A and B levels are historically respected by this market. When price approaches one, expect a reaction. When price approaches a Grade D level, expect a clean pass-through or a trap.

3. Confluence with other tools. Round numbers combined with a swing high/low, a moving average, or a Fibonacci level are far more likely to hold than a round number alone. Treat this indicator as one layer in a stacked decision framework.

4. Timeframe selection. Use higher timeframes (1D, 4H) to identify the dominant magnets for position trading, and drop to lower timeframes (1H, 15m) for execution around those same levels.

5. Broken levels are still information. A dashed level with 20+ historical touches is a zone where liquidity has been swept and where retests often provide re-entry opportunities.


🔹 LIMITATIONS & TRANSPARENCY

• This tool identifies psychological levels and grades their historical reaction quality. It does not predict price direction and it is not a trading strategy. Use it as part of a complete decision framework.

• Reaction grades are historical, not forward-looking. A level that held five times may still break on the next test, especially in strong trending conditions or during high-impact news events.

• Touch counts depend on chart history. On symbols with limited history, recent levels may have fewer touches than their true significance warrants.

• The reaction window is fixed (default 5 bars). Reactions that take longer to develop will be graded as weaker than they truly are. Adjust the window to match the instrument and timeframe.

• Extremely low-volume symbols may produce noisy reaction scores because the relative-volume component becomes unreliable. Reduce its weight to 0 in such cases.


🔹 RISK DISCLOSURE

This indicator is a technical analysis tool for educational and discretionary decision support. It does not constitute financial advice, investment advice, a solicitation, or a recommendation to buy or sell any instrument. Past reactions at any level do not guarantee future behavior. All trading involves substantial risk of loss. You are solely responsible for your trading decisions and for managing your capital.

## Source Code

````pine
// 
// Round Number Magnet Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.7
//
// Auto-detects psychological round number levels (100, 500, 1000, 10000, 50000)
// with asset-aware tier selection across crypto, forex, stocks and indices.
// Grades every touch with a composite reaction score (ATR reaction + wick
// rejection + relative volume) to separate held magnets from broken levels.
// Visualizes active magnets as clean horizontal zones, ranks the strongest
// levels in a professional leaderboard panel and fires bar-confirmed alerts
// on touch, hold, break and magnet-approach events. Version 2.7 introduces a
// focused, role-aware magnet hierarchy without changing the grading engine.
// 

//@version=6
indicator("Round Number Magnet Map [AGPro Series]",
     shorttitle = "AG Pro RN",
     overlay    = true,
     max_lines_count  = 500,
     max_boxes_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 500)

// 
//  NPUTS
// 

//  Detection
grpDet = "Detection"
modeAuto   = input.bool(true,  "Auto-Detect Tiers (Asset-Aware)", tooltip="When enabled, tier spacing is auto-selected based on current price magnitude and symbol class. Disable to use Custom Tiers.", group=grpDet)
customTiers= input.string("",  "Custom Tiers (comma-separated)", tooltip="Used only when Auto-Detect is off. Example for BTC: 1000,500,100. Example for ETH: 100,50,10. Example for forex majors: 0.01,0.005,0.001.", group=grpDet)
rangeMult  = input.float(5.0,  "Level Search Range (x ATR scaled)", minval=2.0, maxval=30.0, step=0.5, tooltip="How far above/below current price to generate levels, as a multiple of ATR-scaled range. Higher values = more levels, slower.", group=grpDet)
maxLevels  = input.int(20,     "Max Tracked Levels", minval=5, maxval=120, tooltip="Hard cap on internally tracked levels. The visual display count is controlled separately in the Visuals group.", group=grpDet)

//  Touch / Zone
grpTch = "Touch & Zone"
zoneAtr    = input.float(0.20, "Zone Thickness (x ATR)", minval=0.05, maxval=1.0, step=0.05, tooltip="Each round number is surrounded by a zone of this thickness (in ATR units). Price entering this zone counts as a touch.", group=grpTch)
atrLen     = input.int(14,     "ATR Length", minval=5, maxval=100, tooltip="ATR period used for zone thickness and reaction measurement.", group=grpTch)
touchCool  = input.int(5,      "Touch Cooldown (bars)", minval=1, maxval=50, tooltip="Minimum bars between two touches on the same level. Prevents a single consolidation from being counted as dozens of touches.", group=grpTch)
reactBars  = input.int(5,      "Reaction Window (bars)", minval=2, maxval=30, tooltip="Number of bars after a touch used to grade reaction quality.", group=grpTch)

//  Grading (Composite: ATR reaction 60% + Wick rejection 25% + Volume 15%)
grpGrd = "Reaction Grading"
wReact   = input.float(0.60, "Weight: ATR Reaction",  minval=0.0, maxval=1.0, step=0.05, tooltip="Weight of distance traveled (in ATRs) after touch. Primary component of reaction quality.", group=grpGrd)
wWick    = input.float(0.25, "Weight: Wick Rejection", minval=0.0, maxval=1.0, step=0.05, tooltip="Weight of rejection wick strength on the touch bar.", group=grpGrd)
wVol     = input.float(0.15, "Weight: Relative Volume", minval=0.0, maxval=1.0, step=0.05, tooltip="Weight of relative volume on the touch bar (0 if no volume data).", group=grpGrd)
reactNorm= input.float(2.0,  "ATR Normalization Target", minval=0.5, maxval=10.0, step=0.5, tooltip="Score of 100 for ATR reaction is reached at this many ATRs of post-touch movement.", group=grpGrd)

//  Visuals
grpVis = "Visuals"
displayMode  = input.string("Focused", "Display Mode", options=["Focused","Full Map"], tooltip="Focused renders only the nearest valid magnets. Full Map renders every valid level inside the active search range.", group=grpVis)
focusLevels  = input.int(7, "Focused Level Count", minval=5, maxval=15, tooltip="Number of nearest valid magnets shown in Focused mode. Seven keeps the chart informative without turning it into a level grid.", group=grpVis)
showZones    = input.bool(true,  "Show Zones", group=grpVis)
showLabels   = input.bool(true,  "Show Owned Magnet Map", tooltip="Shows or hides each rail, zone and badge as one owned visual unit. Individual bare rails are intentionally not supported.", group=grpVis)
hideBroken   = input.bool(true,  "Hide Broken Levels", tooltip="When enabled, levels that have been decisively broken are hidden. Turn off to see the full history.", group=grpVis)
hideUntouched= input.bool(false, "Hide Untouched Levels", tooltip="When enabled, only levels with at least one touch are shown. Useful on higher timeframes where many round numbers are far from price.", group=grpVis)
showMagnet   = input.bool(true,  "Magnet Effect (Thicken Near Price)", tooltip="Nearest levels are rendered thicker when price approaches them.", group=grpVis)
farAlpha     = input.int(70,     "Far Levels Transparency", minval=0, maxval=95, tooltip="Transparency applied to levels further than 30% of search range from price.", group=grpVis)
labelAlpha   = input.int(0,      "Badge Background Transparency", minval=0, maxval=25, tooltip="Controls filled badge transparency. The range is capped to preserve strong contrast on dark and light charts.", group=grpVis)
labelSize    = input.string("Normal", "Label Size",   options=["Tiny","Small","Normal","Large","Huge"], group=grpVis)
labelOffset  = input.int(12,     "Future Badge Lane (bars)", minval=6, maxval=100, tooltip="Width of the future badge corridor. A six-bar minimum keeps owned badges away from live candles.", group=grpVis)

//  Panel
grpPan = "Panel"
showPanel  = input.bool(true,   "Show Panel", group=grpPan)
panelLoc   = input.string("Top Right", "Panel Location", options=["Top Right","Top Center","Top Left","Middle Right","Middle Center","Middle Left","Bottom Right","Bottom Center","Bottom Left"], group=grpPan)
panelTheme = input.string("Dark", "Panel Theme", options=["Dark","Light"], group=grpPan)
panelFont  = input.string("Normal", "Panel Font Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpPan)

//  Alerts
grpAlr = "Alerts"
alertOnTouch  = input.bool(true, "Alert: Touch",  group=grpAlr)
alertOnHold   = input.bool(true, "Alert: Held (Strong Reaction)", group=grpAlr)
alertOnBreak  = input.bool(true, "Alert: Broken", group=grpAlr)
alertOnMagnet = input.bool(true, "Alert: Magnet Approach (< 0.5 ATR)", group=grpAlr)

// 
//  COLOR PALETTE (AGPro)
// 
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgDark   = color.rgb(15, 23, 42)
panelBgLight  = color.rgb(241, 245, 249)
panelBorder   = color.rgb(51, 65, 85)
panelLabelD   = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueD   = color.rgb(226, 232, 240)
panelValueL   = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
farColor      = color.rgb(148, 163, 184)
darkInk       = color.rgb(17, 24, 39)

panelBg    = panelTheme == "Dark" ? panelBgDark : panelBgLight
panelLabel = panelTheme == "Dark" ? panelLabelD : panelLabelL
panelValue = panelTheme == "Dark" ? panelValueD : panelValueL

// 
//  HELPERS
// 
f_toSize(s) =>
    s == "Tiny"   ? size.tiny   :
     s == "Small"  ? size.small  :
     s == "Large"  ? size.large  :
     s == "Huge"   ? size.huge   : size.normal

f_panelPos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Top Center"   ? position.top_center   :
     p == "Bottom Right" ? position.bottom_right :
     p == "Bottom Left"  ? position.bottom_left  :
     p == "Bottom Center" ? position.bottom_center :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Center" ? position.middle_center : position.middle_left

// Contrast-safe on-badge text color: dark ink on bright fills, light text on dark fills
f_text_on(col) =>
    br = (color.r(col) * 299 + color.g(col) * 587 + color.b(col) * 114) / 1000
    br >= 145 ? darkInk : headerText

// Asset-aware tier autodetect based on current price magnitude.
// Returns up to 3 tier spacings ordered from major to minor.
f_autoTiers(_price) =>
    arr = array.new_float()
    p = math.abs(_price)
    if p >= 10000.0
        array.push(arr, 10000.0)
        array.push(arr, 5000.0)
        array.push(arr, 1000.0)
    else if p >= 1000.0
        array.push(arr, 1000.0)
        array.push(arr, 500.0)
        array.push(arr, 100.0)
    else if p >= 100.0
        array.push(arr, 100.0)
        array.push(arr, 50.0)
        array.push(arr, 10.0)
    else if p >= 10.0
        array.push(arr, 10.0)
        array.push(arr, 5.0)
        array.push(arr, 1.0)
    else if p >= 1.0
        array.push(arr, 1.0)
        array.push(arr, 0.5)
        array.push(arr, 0.1)
    else if p >= 0.1
        array.push(arr, 0.1)
        array.push(arr, 0.05)
        array.push(arr, 0.01)
    else if p >= 0.01
        array.push(arr, 0.01)
        array.push(arr, 0.005)
        array.push(arr, 0.001)
    else
        array.push(arr, 0.001)
        array.push(arr, 0.0005)
        array.push(arr, 0.0001)
    arr

f_parseCustom(_str) =>
    arr = array.new_float()
    if str.length(_str) > 0
        parts = str.split(_str, ",")
        if array.size(parts) > 0
            for i = 0 to array.size(parts) - 1
                v = str.tonumber(str.replace_all(array.get(parts, i), " ", ""))
                if not na(v) and v > 0
                    array.push(arr, v)
    arr

// Priority of a level = spacing index (0 = major). Majors render thicker.
// Build unique sorted level price list from tiers.
f_buildLevels(_tiers, _center, _halfRange) =>
    prices   = array.new_float()
    priority = array.new_int()
    if array.size(_tiers) > 0
        for i = 0 to array.size(_tiers) - 1
            step = array.get(_tiers, i)
            if step > 0
                lo = math.floor((_center - _halfRange) / step) * step
                hi = math.ceil ((_center + _halfRange) / step) * step
                n  = math.min(int((hi - lo) / step) + 1, 400)
                for k = 0 to n - 1
                    p = lo + k * step
                    // deduplicate: keep highest priority (lowest index)
                    exists = false
                    if array.size(prices) > 0
                        for j = 0 to array.size(prices) - 1
                            if math.abs(array.get(prices, j) - p) < step * 1e-6
                                exists := true
                                if i < array.get(priority, j)
                                    array.set(priority, j, i)
                                break
                    if not exists
                        array.push(prices, p)
                        array.push(priority, i)
    [prices, priority]

// 
//  STATE (persistent via var)
// 

var array<float> lvlPrice    = array.new_float()
var array<int>   lvlPrio     = array.new_int()
var array<int>   lvlTouches  = array.new_int()
var array<float> lvlScoreSum = array.new_float()
var array<int>   lvlLastBar  = array.new_int()
var array<bool>  lvlBroken   = array.new_bool()
var array<int>   lvlPending  = array.new_int()    // bar index of open touch awaiting reaction grading, -1 if none
var array<float> lvlPendPx   = array.new_float()  // price where touch occurred
var array<int>   lvlPendDir  = array.new_int()    // 1 = touched from above (support test), -1 = from below (resistance test)
var array<line>  lvlLine     = array.new<line>()
var array<box>   lvlBox      = array.new<box>()
var array<label> lvlLbl      = array.new<label>()
var array<bool>  lvlVisible  = array.new_bool()

// Stop-aware magnet hold-rate tally (all graded touches across all levels)
var int holdTotal = 0
var int holdWins  = 0

var table       pnl          = na

// 
//  CORE CALCULATONS
// 
atr     = math.max(nz(ta.atr(atrLen), ta.tr(true)), syminfo.mintick)
zoneTh  = atr * zoneAtr
volAvg  = ta.sma(volume, 20)
relVol  = volAvg > 0 ? volume / volAvg : 1.0

// Rebuild level list on first bar and periodically (every 500 bars) or on range drift.
var float lastCenter = na
var float lastHalf   = na
needRebuild = barstate.isfirst or (not na(lastCenter) and math.abs(close - lastCenter) > lastHalf * 0.5) or (bar_index % 500 == 0 and bar_index > 0)

if needRebuild and (barstate.isconfirmed or barstate.isfirst)
    tiers = modeAuto ? f_autoTiers(close) : f_parseCustom(customTiers)
    halfR = atr * rangeMult * 8.0
    [newPrices, newPrio] = f_buildLevels(tiers, close, halfR)
    // Preserve statistics for surviving levels
    oldPrice   = array.copy(lvlPrice)
    oldTouch   = array.copy(lvlTouches)
    oldScore   = array.copy(lvlScoreSum)
    oldLast    = array.copy(lvlLastBar)
    oldBroken  = array.copy(lvlBroken)
    oldPend    = array.copy(lvlPending)
    oldPendPx  = array.copy(lvlPendPx)
    oldPendDir = array.copy(lvlPendDir)
    // Clear drawings
    if array.size(lvlLine) > 0
        for i = 0 to array.size(lvlLine) - 1
            ln = array.get(lvlLine, i)
            if not na(ln)
                line.delete(ln)
    if array.size(lvlBox) > 0
        for i = 0 to array.size(lvlBox) - 1
            bx = array.get(lvlBox, i)
            if not na(bx)
                box.delete(bx)
    if array.size(lvlLbl) > 0
        for i = 0 to array.size(lvlLbl) - 1
            lb = array.get(lvlLbl, i)
            if not na(lb)
                label.delete(lb)
    array.clear(lvlPrice)
    array.clear(lvlPrio)
    array.clear(lvlTouches)
    array.clear(lvlScoreSum)
    array.clear(lvlLastBar)
    array.clear(lvlBroken)
    array.clear(lvlPending)
    array.clear(lvlPendPx)
    array.clear(lvlPendDir)
    array.clear(lvlLine)
    array.clear(lvlBox)
    array.clear(lvlLbl)
    array.clear(lvlVisible)
    // Cap count (keep closest-to-price if too many)
    n = array.size(newPrices)
    keepdx = array.new_int()
    if n > 0
        if n <= maxLevels
            for i = 0 to n - 1
                array.push(keepdx, i)
        else
            // rank by distance
            dists = array.new_float()
            idxs  = array.new_int()
            for i = 0 to n - 1
                array.push(dists, math.abs(array.get(newPrices, i) - close))
                array.push(idxs, i)
            // simple selection: pick maxLevels smallest distances
            for s = 0 to maxLevels - 1
                if array.size(dists) > 0
                    min = 0
                    minV = array.get(dists, 0)
                    if array.size(dists) > 1
                        for j = 1 to array.size(dists) - 1
                            if array.get(dists, j) < minV
                                minV := array.get(dists, j)
                                min := j
                    array.push(keepdx, array.get(idxs, min))
                    array.remove(dists, min)
                    array.remove(idxs, min)
    // Populate level arrays with preserved stats if matching
    if array.size(keepdx) > 0
        for i = 0 to array.size(keepdx) - 1
            idx = array.get(keepdx, i)
            px  = array.get(newPrices, idx)
            pr  = array.get(newPrio,   idx)
            array.push(lvlPrice, px)
            array.push(lvlPrio,  pr)
            // Look up old stats
            foundT = 0
            foundS = 0.0
            foundL = 0
            foundB = false
            foundP = -1
            foundPx= 0.0
            foundD = 0
            if array.size(oldPrice) > 0
                for j = 0 to array.size(oldPrice) - 1
                    if math.abs(array.get(oldPrice, j) - px) < syminfo.mintick * 2
                        foundT  := array.get(oldTouch, j)
                        foundS  := array.get(oldScore, j)
                        foundL  := array.get(oldLast,  j)
                        foundB  := array.get(oldBroken,j)
                        foundP  := array.get(oldPend,  j)
                        foundPx := array.get(oldPendPx,j)
                        foundD  := array.get(oldPendDir,j)
                        break
            array.push(lvlTouches,  foundT)
            array.push(lvlScoreSum, foundS)
            array.push(lvlLastBar,  foundL)
            array.push(lvlBroken,   foundB)
            array.push(lvlPending,  foundP >= 0 ? foundP : -1)
            array.push(lvlPendPx,   foundPx)
            array.push(lvlPendDir,  foundD)
            line  nilLine = na
            box   nilBox  = na
            label nilLbl  = na
            array.push(lvlLine, nilLine)
            array.push(lvlBox,  nilBox)
            array.push(lvlLbl,  nilLbl)
            array.push(lvlVisible, false)
    lastCenter := close
    lastHalf   := halfR

// 
//  TOUCH DETECTON + PENDNG REACTON GRADNG
// 
var int   g_touchLvl  = -1
var bool  g_heldFlag  = false
var bool  g_brokeFlag = false
var bool  g_magnetFlag= false

g_touchLvl  := -1
g_heldFlag  := false
g_brokeFlag := false
g_magnetFlag:= false

if barstate.isconfirmed and array.size(lvlPrice) > 0
    for i = 0 to array.size(lvlPrice) - 1
        lp = array.get(lvlPrice, i)
        upper = lp + zoneTh
        lower = lp - zoneTh
        // Touch detection: current bar wicks into the zone
        isTouch = (high >= lower and low <= upper) and (bar_index - array.get(lvlLastBar, i) >= touchCool)
        // Broken detection: full body close beyond zone after having touched
        closedAbove = close > upper
        closedBelow = close < lower
        // Magnet approach
        dist = math.abs(close - lp)
        isMagnet = dist < atr * 0.5 and dist > zoneTh * 0.8 and showMagnet

        // Recovery: if price returns to the zone of a previously-broken level, un-break it.
        // This prevents the common false-broken cascade when price oscillates around a round number.
        if array.get(lvlBroken, i) and isTouch
            array.set(lvlBroken, i, false)

        if isTouch and not array.get(lvlBroken, i)
            array.set(lvlTouches, i, array.get(lvlTouches, i) + 1)
            array.set(lvlLastBar, i, bar_index)
            // Start pending reaction measurement
            array.set(lvlPending, i, bar_index)
            array.set(lvlPendPx,  i, lp)
            tdir = close > lp ? 1 : -1
            array.set(lvlPendDir, i, tdir)
            g_touchLvl := i

        // Pending reaction: grade after reactBars
        pendStart = array.get(lvlPending, i)
        if pendStart >= 0 and bar_index - pendStart >= reactBars
            lvl = array.get(lvlPendPx, i)
            pdir = array.get(lvlPendDir, i)
            // ATR reaction: max favorable excursion over reactBars following the touch
            maxFav = 0.0
            for b = 0 to reactBars - 1
                h = high[b]
                l = low[b]
                if pdir == 1
                    maxFav := math.max(maxFav, h - lvl)
                else
                    maxFav := math.max(maxFav, lvl - l)
            reactScore = atr > 0 ? math.min(100.0, (maxFav / atr) / reactNorm * 100.0) : 0.0
            // Wick rejection on the touch bar itself (reactBars ago)
            wickOffset = reactBars
            bh = high[wickOffset]
            bl = low[wickOffset]
            bo = open[wickOffset]
            bc = close[wickOffset]
            rng  = bh - bl
            wick = 0.0
            if pdir == 1
                wick := bc > bo ? math.max(0.0, bo - bl) : math.max(0.0, bc - bl)
            else
                wick := bc > bo ? math.max(0.0, bh - bc) : math.max(0.0, bh - bo)
            wickRatio = rng > 0 ? wick / rng : 0.0
            wickScore = math.min(100.0, wickRatio * 150.0)
            // Relative volume on the touch bar
            rv = relVol[wickOffset]
            volScore = math.min(100.0, math.max(0.0, (nz(rv, 1.0) - 1.0) * 50.0))
            wSum = wReact + wWick + wVol
            composite = 0.0
            if wSum > 0
                composite := (reactScore * wReact + wickScore * wWick + volScore * wVol) / wSum
            composite := math.max(0.0, math.min(100.0, composite))
            array.set(lvlScoreSum, i, array.get(lvlScoreSum, i) + composite)
            array.set(lvlPending, i, -1)
            if composite >= 60.0
                g_heldFlag := true
            // Broken only if price closed strongly beyond the zone (zone + 0.3 ATR) in the opposite direction.
            strongBreakDist = zoneTh + atr * 0.3
            if pdir == 1 and close < lp - strongBreakDist
                array.set(lvlBroken, i, true)
                g_brokeFlag := true
            if pdir == -1 and close > lp + strongBreakDist
                array.set(lvlBroken, i, true)
                g_brokeFlag := true
            // Stop-aware hold tally: did the magnet repel price (>= 0.5 ATR reaction)
            // before a strong break of the level? Break = loss, clean reaction = hold.
            brokeNow = (pdir == 1 and close < lp - strongBreakDist) or (pdir == -1 and close > lp + strongBreakDist)
            if brokeNow
                holdTotal += 1
            else if maxFav >= atr * 0.5
                holdTotal += 1
                holdWins  += 1
        if isMagnet
            g_magnetFlag := true

// 
//  RENDERNG (line/box/label with delete-and-recreate pattern)
// Uses xloc.bar_time with a 500-bar back xL (empirically within TV snapshot
// render window). Delete-and-recreate every render pass for snapshot consistency.
// 
lblSz = f_toSize(labelSize)
halfShow = atr * rangeMult * 4.0

shouldRender = barstate.islast or barstate.islastconfirmedhistory

tfSec = timeframe.in_seconds()
avgBarMs = int((tfSec > 0 ? tfSec : 3600) * 1000)
tL = time - avgBarMs * 500
tR = time + avgBarMs * labelOffset
tZoneCenter = time + int(math.round(avgBarMs * labelOffset * 0.5))

if shouldRender and array.size(lvlPrice) > 0
    // Delete all existing drawings first
    for i = 0 to array.size(lvlLine) - 1
        oldLn = array.get(lvlLine, i)
        if not na(oldLn)
            line.delete(oldLn)
    for i = 0 to array.size(lvlBox) - 1
        oldBx = array.get(lvlBox, i)
        if not na(oldBx)
            box.delete(oldBx)
    for i = 0 to array.size(lvlLbl) - 1
        oldLb = array.get(lvlLbl, i)
        if not na(oldLb)
            label.delete(oldLb)

    // Build one shared visibility mask so chart objects and panel statistics
    // always describe the same set of magnets.
    for i = 0 to array.size(lvlVisible) - 1
        array.set(lvlVisible, i, false)

    if displayMode == "Full Map"
        for i = 0 to array.size(lvlPrice) - 1
            lp = array.get(lvlPrice, i)
            tc = array.get(lvlTouches, i)
            brk = array.get(lvlBroken, i)
            candidate = math.abs(close - lp) < halfShow and not (hideBroken and brk) and not (hideUntouched and tc == 0)
            array.set(lvlVisible, i, candidate)
    else
        for slot = 0 to focusLevels - 1
            bestIdx = -1
            bestDist = 1e20
            for i = 0 to array.size(lvlPrice) - 1
                lp = array.get(lvlPrice, i)
                tc = array.get(lvlTouches, i)
                brk = array.get(lvlBroken, i)
                dist = math.abs(close - lp)
                candidate = dist < halfShow and not array.get(lvlVisible, i) and not (hideBroken and brk) and not (hideUntouched and tc == 0)
                if candidate and dist < bestDist
                    bestDist := dist
                    bestIdx := i
            if bestIdx >= 0
                array.set(lvlVisible, bestIdx, true)

    nearestAboveRender = -1
    nearestBelowRender = -1
    leaderRender = -1
    nearestAboveDist = 1e20
    nearestBelowDist = 1e20
    leaderKey = -1.0
    for i = 0 to array.size(lvlPrice) - 1
        if array.get(lvlVisible, i)
            lp = array.get(lvlPrice, i)
            tc = array.get(lvlTouches, i)
            avgScore = tc > 0 ? array.get(lvlScoreSum, i) / tc : 0.0
            d = lp - close
            if d >= 0 and d < nearestAboveDist
                nearestAboveDist := d
                nearestAboveRender := i
            if d <= 0 and -d < nearestBelowDist
                nearestBelowDist := -d
                nearestBelowRender := i
            candidateKey = tc * 1000.0 + avgScore
            if candidateKey > leaderKey
                leaderKey := candidateKey
                leaderRender := i

    for i = 0 to array.size(lvlPrice) - 1
        lp   = array.get(lvlPrice, i)
        pr   = array.get(lvlPrio,  i)
        tc   = array.get(lvlTouches, i)
        brk  = array.get(lvlBroken, i)
        dist = math.abs(close - lp)
        shouldShow = showLabels and array.get(lvlVisible, i)

        avgScore = tc > 0 ? array.get(lvlScoreSum, i) / tc : 0.0
        grade = brk ? "BRK" : avgScore >= 80 ? "A" : avgScore >= 65 ? "B" : avgScore >= 45 ? "C" : avgScore > 0 ? "D" : "NEW"
        isResistance = i == nearestAboveRender
        isSupport = i == nearestBelowRender
        isLeader = i == leaderRender and not isResistance and not isSupport
        roleText = brk ? "BROKEN" : isResistance ? "RESIST" : isSupport ? "SUPPORT" : isLeader ? "LEADER" : tc > 0 ? "MAGNET" : "ROUND"
        roleCol = brk ? farColor : isResistance ? bearColor : isSupport ? bullColor : isLeader ? accentColor : headerBg

        baseW = isResistance or isSupport or isLeader ? 2 : pr == 0 ? 2 : 1
        mag   = showMagnet and dist < atr * 1.0 ? 1 : 0
        lw    = math.min(3, baseW + mag)

        far = dist > halfShow * 0.3
        tr  = brk ? math.min(85, farAlpha + 15) : (far ? farAlpha : 0)
        lineCol = color.new(roleCol, tr)

        // Zone box (skipped for broken levels)
        zoneVisible = showZones and shouldShow and not brk
        if zoneVisible
            zoneAlpha  = 84 + (far ? 6 : 0)
            zoneBg     = color.new(roleCol, zoneAlpha)
            zoneBorder = color.new(roleCol, 55)
            nbx = box.new(time, lp + zoneTh, tR, lp - zoneTh, xloc=xloc.bar_time, border_color=zoneBorder, bgcolor=zoneBg)
            array.set(lvlBox, i, nbx)

        // Level line
        if shouldShow
            nln = line.new(tL, lp, tR, lp, xloc=xloc.bar_time, color=lineCol, width=lw, style=brk ? line.style_dashed : line.style_solid)
            array.set(lvlLine, i, nln)

        // One filled owner badge per visible rail. When zones are enabled the
        // badge is centered horizontally and vertically inside its future band.
        priceStr = str.tostring(lp, format.mintick)
        statsText = tc > 0 ? " | x" + str.tostring(tc) + " " + grade : " | " + grade
        txt = roleText + " | " + priceStr + statsText
        lblCol = color.new(roleCol, labelAlpha)
        if shouldShow
            if showZones and not brk
                nlbl = label.new(tZoneCenter, lp, txt, xloc=xloc.bar_time, yloc=yloc.price, color=lblCol, textcolor=f_text_on(roleCol), style=label.style_label_center, size=lblSz)
                array.set(lvlLbl, i, nlbl)
            else
                nlbl = label.new(tR, lp, txt, xloc=xloc.bar_time, yloc=yloc.price, color=lblCol, textcolor=f_text_on(roleCol), style=label.style_label_left, size=lblSz)
                array.set(lvlLbl, i, nlbl)

// 
//  PANEL
// 
if shouldRender and showPanel
    tableExists = not na(pnl)
    if not tableExists
        pnl := table.new(f_panelPos(panelLoc), 2, 13, bgcolor=panelBg, border_color=panelBorder, border_width=1, frame_color=panelBorder, frame_width=1)
    fsz = f_toSize(panelFont)
    // Row 0: merged single-cell header (brand blue)
    table.cell(pnl, 0, 0, "AG Pro Round Number Magnet Map", bgcolor=headerBg, text_color=headerText, text_size=fsz)
    table.cell(pnl, 1, 0, "", bgcolor=headerBg, text_color=headerText, text_size=fsz)
    if not tableExists
        table.merge_cells(pnl, 0, 0, 1, 0)

    // Find nearest level above and below; also compute strongest AMONG CURRENTLY-VSBLE (near) levels
    // so the panel never references a level that is off-screen and meaningless to the trader.
    nearAbovedx = -1
    nearBelowdx = -1
    distAbove = 1e20
    distBelow = 1e20
    activeCount = 0
    strongestdx = -1
    strongestTouches = 0
    sumReact = 0.0
    scoredLevels = 0
    halfShowPanel = atr * rangeMult * 4.0
    if array.size(lvlPrice) > 0
        for i = 0 to array.size(lvlPrice) - 1
            if array.get(lvlVisible, i) and not array.get(lvlBroken, i)
                lp = array.get(lvlPrice, i)
                activeCount += 1
                d = lp - close
                if d >= 0 and d < distAbove
                    distAbove := d
                    nearAbovedx := i
                if d <= 0 and -d < distBelow
                    distBelow := -d
                    nearBelowdx := i
                tc = array.get(lvlTouches, i)
                if tc > strongestTouches
                    strongestTouches := tc
                    strongestdx := i
                if tc > 0
                    scoredLevels += 1
                    sumReact += array.get(lvlScoreSum, i) / tc

    avgReactAll = scoredLevels > 0 ? sumReact / scoredLevels : 0.0
    naAbovePx = nearAbovedx >= 0 ? str.tostring(array.get(lvlPrice, nearAbovedx), format.mintick) : "-"
    naBelowPx = nearBelowdx >= 0 ? str.tostring(array.get(lvlPrice, nearBelowdx), format.mintick) : "-"
    strongPx  = strongestdx  >= 0 ? str.tostring(array.get(lvlPrice, strongestdx),  format.mintick) + "  (x" + str.tostring(strongestTouches) + ")" : "-"

    holdRate    = holdTotal > 0 ? holdWins / holdTotal * 100.0 : na
    holdRateTxt = holdTotal >= 6 ? str.tostring(math.round(holdRate)) + "%  (" + str.tostring(holdTotal) + ")" : "Building (" + str.tostring(holdTotal) + ")"
    holdRateCol = holdTotal >= 6 ? (holdRate >= 55.0 ? bullColor : holdRate >= 45.0 ? neutralColor : bearColor) : panelValue

    // Rows
    table.cell(pnl, 0, 1, "Above",      bgcolor=panelBg, text_color=panelLabel, text_size=fsz, text_halign=text.align_left)
    table.cell(pnl, 1, 1, naAbovePx,    bgcolor=panelBg, text_color=bearColor,   text_size=fsz, text_halign=text.align_right)
    table.cell(pnl, 0, 2, "Below",      bgcolor=panelBg, text_color=panelLabel,  text_size=fsz, text_halign=text.align_left)
    table.cell(pnl, 1, 2, naBelowPx,    bgcolor=panelBg, text_color=bullColor,   text_size=fsz, text_halign=text.align_right)
    table.cell(pnl, 0, 3, "Active Levels", bgcolor=panelBg, text_color=panelLabel, text_size=fsz, text_halign=text.align_left)
    table.cell(pnl, 1, 3, str.tostring(activeCount), bgcolor=panelBg, text_color=panelValue, text_size=fsz, text_halign=text.align_right)
    table.cell(pnl, 0, 4, "Strongest",  bgcolor=panelBg, text_color=panelLabel, text_size=fsz, text_halign=text.align_left)
    table.cell(pnl, 1, 4, strongPx,     bgcolor=panelBg, text_color=accentColor, text_size=fsz, text_halign=text.align_right)
    table.cell(pnl, 0, 5, "Avg Reaction", bgcolor=panelBg, text_color=panelLabel, text_size=fsz, text_halign=text.align_left)
    avgCol = avgReactAll >= 65 ? bullColor : avgReactAll >= 45 ? neutralColor : bearColor
    table.cell(pnl, 1, 5, str.tostring(avgReactAll, "#.0"), bgcolor=panelBg, text_color=avgCol, text_size=fsz, text_halign=text.align_right)
    table.cell(pnl, 0, 6, "Hold Rate", bgcolor=panelBg, text_color=panelLabel, text_size=fsz, text_halign=text.align_left)
    table.cell(pnl, 1, 6, holdRateTxt, bgcolor=panelBg, text_color=holdRateCol, text_size=fsz, text_halign=text.align_right)

    // Top 5 leaderboard header
    table.cell(pnl, 0, 7, "Top 5 Leaders", bgcolor=color.new(headerBg, 70), text_color=headerText, text_size=fsz, text_halign=text.align_left)
    table.cell(pnl, 1, 7, "Touches - Grade", bgcolor=color.new(headerBg, 70), text_color=headerText, text_size=fsz, text_halign=text.align_right)
    // Build a ranked copy by touches among NEAR levels (includes broken, marked distinctly)
    rankdx  = array.new_int()
    rankKey  = array.new_float()
    if array.size(lvlPrice) > 0
        for i = 0 to array.size(lvlPrice) - 1
            if array.get(lvlVisible, i)
                tc = array.get(lvlTouches, i)
                if tc > 0
                    avg = array.get(lvlScoreSum, i) / tc
                    array.push(rankdx, i)
                    array.push(rankKey, tc * 1000.0 + avg)
    // Simple selection sort top 5
    topN = math.min(5, array.size(rankdx))
    for s = 0 to 4
        if s < topN
            maxK = -1.0
            maxJ = -1
            for j = 0 to array.size(rankKey) - 1
                if array.get(rankKey, j) > maxK
                    maxK := array.get(rankKey, j)
                    maxJ := j
            if maxJ >= 0
                idx = array.get(rankdx, maxJ)
                px  = array.get(lvlPrice, idx)
                tc  = array.get(lvlTouches, idx)
                brokenL = array.get(lvlBroken, idx)
                avg = array.get(lvlScoreSum, idx) / tc
                gr  = brokenL ? "BRK" : avg >= 80 ? "A" : avg >= 65 ? "B" : avg >= 45 ? "C" : "D"
                grCol = brokenL ? farColor : avg >= 65 ? bullColor : avg >= 45 ? neutralColor : bearColor
                table.cell(pnl, 0, 8 + s, str.tostring(s + 1) + ". " + str.tostring(px, format.mintick), bgcolor=panelBg, text_color=panelValue, text_size=fsz, text_halign=text.align_left)
                table.cell(pnl, 1, 8 + s, "x" + str.tostring(tc) + " - " + gr, bgcolor=panelBg, text_color=grCol, text_size=fsz, text_halign=text.align_right)
                array.set(rankKey, maxJ, -1.0)
        else
            // Empty row: blank out cleanly
            table.cell(pnl, 0, 8 + s, "", bgcolor=panelBg, text_color=panelLabel, text_size=fsz, text_halign=text.align_left)
            table.cell(pnl, 1, 8 + s, "", bgcolor=panelBg, text_color=panelLabel, text_size=fsz, text_halign=text.align_right)
else if shouldRender and not showPanel and not na(pnl)
    table.clear(pnl, 0, 0, 1, 12)

// 
//  ALERTS (non-repainting: bar-confirmed)
// 
alertcondition(alertOnTouch  and g_touchLvl  >= 0, title="RNMM: Touch",           message="Round Number Magnet Map: price touched a psychological level on {{ticker}} {{interval}}.")
alertcondition(alertOnHold   and g_heldFlag,       title="RNMM: Held (Strong)",   message="Round Number Magnet Map: level HELD with strong reaction on {{ticker}} {{interval}}.")
alertcondition(alertOnBreak  and g_brokeFlag,      title="RNMM: Broken",          message="Round Number Magnet Map: level BROKEN on {{ticker}} {{interval}}.")
alertcondition(alertOnMagnet and g_magnetFlag,     title="RNMM: Magnet Approach", message="Round Number Magnet Map: price approaching magnet (< 0.5 ATR) on {{ticker}} {{interval}}.")
````
