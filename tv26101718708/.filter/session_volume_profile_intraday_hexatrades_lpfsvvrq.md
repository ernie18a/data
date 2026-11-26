# Session Volume Profile - Intraday [HexaTrades]

- url: https://www.tradingview.com/script/lpfSVvRQ-Session-Volume-Profile-Intraday-HexaTrades/
- type: indicator
- pine_id: PUB;b5947c88a3f443e48056534887fb442b
- version: 1.0

## Description

Session Volume Profile Intraday is a comprehensive volume profile indicator designed specifically for intraday traders. It builds a separate volume profile for each session and automatically identifies the most important auction-market levels, including Point of Control (POC), Value Area High (VAH), Value Area Low (VAL), Previous Session Levels, VWAP, Previous Day High/Low, Initial Balance, and Naked POCs.

The goal of this indicator is to help traders understand where the market is accepting price, where major volume has traded, and where important support/resistance or liquidity zones may form during the trading session.

[b]⭐️ How it works[/b]
 
-Binning: the session's price range (highest high to lowest low) is divided into Rows per Profile equal price bins.
-Volume distribution: each bar's volume is spread evenly across every bin its high–low range spans, and tagged buy or sell by candle direction.
-POC: the bin holding the most total volume.
- Value Area: starting from the POC, the algorithm expands outward always toward the heavier of the two neighbouring bins, until the accumulated volume reaches the chosen Value Area % (default 70%). The top and bottom edges of the included bins become VAH and VAL.
-Width: each row's bar length is scaled to its volume relative to the POC row, capped by the width settings.


[b]⭐️What This Indicator Shows
[/b]

🔷 [b]Session Volume Profile:[/b] The indicator creates a horizontal volume profile for each trading session. Each profile shows how much volume traded at different price levels during that session.
The widest part of the profile represents the area with the highest traded volume. Thin areas show low-volume zones where price may move faster.

🔷[b]POC - Point of Control:[/b] POC is the price level with the highest traded volume during the session.
It is one of the most important levels on the chart because it represents the price where the market spent the most activity.

How to use POC:

- Price above POC can suggest buyers are in control.
- Price below POC can suggest sellers are in control.
- A retest of POC can act as support or resistance.
- A strong rejection from POC may create a trade setup.
- A clean reclaim of POC may show a change in intraday bias.


[b]🔷 VAH and VAL - Value Area High / Low[/b]

The Value Area represents the price zone where most of the session’s volume traded, usually 70%.
VAH is the upper boundary of the value area.
VAL is the lower boundary of the value area.

How to use Value Area:

- Price inside value area = balanced market.
- Price above VAH = bullish acceptance/strength.
- Price below VAL = bearish acceptance/weakness.
- Rejection from VAH may create a short setup.
- Rejection from VAL may create a long setup.
- Breakout above VAH can indicate trend continuation.
- Breakdown below VAL can indicate downside continuation.

[b]🔷 Previous Session POC / VAH / VAL[/b]

The indicator carries forward the previous session’s important profile levels into the current session.
These levels often act as strong support, resistance, or reaction zones.

How to use previous session levels:

- Previous POC can act as a major magnet level.
- Previous VAH/VAL can act as important breakout or rejection zones.
- If price opens above previous value, the market may be bullish.
- If price opens below the previous value, the market may be bearish.
- If price opens inside the previous value, the market may be balanced or rotational.


[b]🔷 PDH and PDL - Previous Day High / Low[/b]

PDH means Previous Day High.
PDL means Previous Day Low.

These are important liquidity levels watched by many intraday traders.

How to use PDH/PDL:

- Break above PDH may show bullish momentum.
- Break below PDL may show bearish momentum.
- A fake breakout above PDH followed by rejection can indicate a liquidity sweep.
- A fake breakdown below PDL followed by recovery can indicate a downside liquidity sweep.


[b]🔷 VWAP - Session VWAP[/b]

VWAP shows the average traded price of the session based on volume.

How to use VWAP:

- Price above VWAP = bullish intraday bias.
- Price below VWAP = bearish intraday bias.
- VWAP can act as dynamic support or resistance.
- POC + VWAP confluence can create a stronger reaction zone.


[b]🔷 Initial Balance — IBH / IBL[/b]

Initial Balance is the high and low of the first part of the trading session. By default, it uses the first 60 minutes.
IBH = Initial Balance High
IBL = Initial Balance Low

How to use Initial Balance:

- Break above IBH may indicate a bullish trend day.
- Break below IBL may indicate a bearish trend day.
- Rejection from IBH/IBL may indicate range continuation.
- IB range helps define early-session structure.


[b]🔷 Naked POCs[/b]

A Naked POC is a previous session POC that has not yet been retested by price.

How to use Naked POCs:

- They can act as future price magnets.
- Price often reacts when revisiting them.
- They can be used as target zones.
- Once price trades through a Naked POC, the level is considered tested.


[b]⭐️ Dashboard[/b]

The dashboard provides a real-time summary of the current session and key reference levels, helping traders quickly assess market structure, auction location, and intraday bias.

- Price Location: Shows whether the current price is trading Above Value, Inside Value, or Below Value relative to the developing session Value Area.
- Session POC: Current session's Point of Control — the price level with the highest traded volume.
- Session VAH: Current session Value Area High.
- Session VAL: Current session Value Area Low.
- VWAP: Current session Volume Weighted Average Price.
- Prev POC: Previous session Point of Control, often acting as an important support, resistance, or mean-reversion level.
- Prev VAH: Previous session Value Area High, frequently used as a resistance level or bullish breakout trigger.
- Prev VAL: Previous session Value Area Low, frequently used as a support level or bearish breakdown trigger.
- PDH: Previous Day High, a key liquidity and breakout reference level.
- PDL: Previous Day Low, a key liquidity and breakdown reference level.
- IBH: Initial Balance High, representing the upper boundary of the opening range.
- IBL: Initial Balance Low, representing the lower boundary of the opening range.
- Naked POCs: Displays the number of active untested POCs from previous sessions that have not yet been revisited by price.

https://www.tradingview.com/x/L0VvPvrL/


[b][b]⭐️ How to Use This Indicator[/b][/b]

[b]🔷Step 1: Identify Market Bias[/b]

First, check where price is trading compared to VWAP, POC, and Value Area.

Bullish bias:

-Price above VWAP
-Price above session POC
-Price above VAH
-POC shifting higher

Bearish bias:

-Price below VWAP
-Price below session POC
-Price below VAL
-POC shifting lower

Neutral/balanced market:

-Price inside value area
-Price moving around POC
-VWAP is flat
-No clear acceptance above VAH or below VAL


[b]🔷Step 2: Watch Key Reaction Levels[/b]

The most important reaction levels are:

- Current Session POC
-Previous Session POC
-VAH / VAL
-VWAP
-PDH / PDL
-IBH / IBL
-Naked POCs

When multiple levels are close together, that area becomes stronger confluence.

Example:

If VWAP, POC, and VAL are near the same price, that zone becomes an important support/resistance area.


[b]🔷 Step 3: Look for Confirmation[/b]

Do not take trades only because price touches a level.

Wait for confirmation such as:

- Strong rejection candle
- Close above/below the level
- Retest and hold
- Volume expansion
- Failed breakout
- Market structure shift
- VWAP reclaim or rejection

[b]Example Trade Setups[/b]

[b]POC Rejection Setup[/b]

Bearish example:

- Price is below VWAP.
- Price rallies back to POC.
- Price rejects from POC.
- A bearish confirmation candle forms.
Possible entry: After rejection confirmation.
Possible stop: Above POC or above VAH.
Possible targets: VAL, PDL, or Naked POC.
https://www.tradingview.com/x/zY6XIo9U/


[b]POC Reclaim Setup[/b]

Bullish example:
- Price trades below POC.
- Price reclaims POC with a strong candle close.
- Price retests POC and holds.
- VWAP is also reclaimed.
- Possible entry: After retest and hold.
- Possible stop: Below POC or below VWAP.
- Possible targets: VAH, PDH, or previous value area.
https://www.tradingview.com/x/hGW8MAYF/


[b]Value Area Breakout[/b]

Bullish example:
- Price trades inside value area.
- Price breaks above VAH.
- Price holds above VAH.
- VWAP supports the move.
- Possible entry: Above VAH after confirmation.
-Possible stop:Back inside value area.
Possible targets: PDH, Naked POC, or next resistance zone.
https://www.tradingview.com/x/uxCSqQnJ/

[b]Value Area Breakdown[/b]

Bearish example:

- Price trades inside value area.
- Price breaks below VAL.
- Price holds below VAL.
- Price remains below VWAP.
- Possible entry: Below VAL after confirmation.
- Possible stop: Back inside value area.
- Possible targets:PDL, Naked POC, or next support zone.

https://www.tradingview.com/x/76vCkCu6/

[b]Previous Day High / Low Liquidity Sweep[/b]

[b]Bullish PDL sweep example:[/b]
- Price breaks below PDL.
- Sellers get trapped.
- Price quickly reclaims PDL.
- Bullish candle closes back above PDL.
- Possible entry:After reclaim confirmation.
- Possible stop: Below sweep low.
- Possible targets: VWAP, POC, or VAH.
https://www.tradingview.com/x/fmGSrAHZ/


[b]Bearish PDH sweep example:[/b]
-Price breaks above PDH.
- Buyers get trapped.
- Price quickly falls back below PDH.
- Bearish candle closes below PDH.
- Possible entry: After rejection confirmation.
- Possible stop: Above sweep high.
- Possible targets: VWAP, POC, or VAL.
https://www.tradingview.com/x/zyMXl5QX/


[b]Initial Balance Breakout[/b]

Bullish example:
- First 60-minute range forms.
- Price breaks above IBH.
- Price holds above IBH.
- VWAP and POC support the move.
-Possible entry: After the breakout and retest.
- Possible stop: Back inside IB range.
- Possible targets: VAH, PDH, or Naked POC.


[b]Best Timeframes[/b]
- 5-minute chart
-15-minute chart
- Intraday futures
- Stocks
- Crypto
- Forex pairs
- For faster entries, the 5-minute can be used.

[b] ⭐️Alerts[/b]
All alerts are evaluated on confirmed bars only (no repaint):

- POC Cross Up / Down — price crosses the session POC.
- Value Area Breakout / Breakdown — price accepts above VAH or rejects below VAL.
- Prev POC Test — price tests the previous session's POC.
- PDH Break / PDL Break — price breaks the previous day's high or low.
- VWAP Cross — price crosses the session VWAP.

Session Volume Profile Intraday is designed to help traders visualise market-generated support and resistance using volume-based auction principles. By combining Session Volume Profiles, POC, Value Areas, VWAP, Previous Session Levels, PDH/PDL, Initial Balance, and Naked POCs, it provides a complete framework for intraday market analysis. Use it to identify key reaction zones, assess market bias, and improve trade planning. As always, combine it with sound risk management and your own trading strategy for the best results.

We would love to hear your suggestions. If you have ideas for new features, indicators, analytics, or improvements, please share your feedback. Your input helps guide future updates and improve the indicator for all traders.

[i]This indicator is for educational and analytical purposes only. It should not be considered financial advice. Always use proper risk management and make trading decisions based on your own analysis[/i]

## Source Code

````pine
//@version=6
indicator("Session Volume Profile — Intraday", "HexaTrades Session Volume Profile - Intraday", overlay = true, behind_chart = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 200)

// =====================================================================================
//  INPUTS
// =====================================================================================
grpP        = "═══ Profile ═══"
profileTF   = input.timeframe("D", "Session Anchor", group = grpP, tooltip = "Each profile resets on a new period. 'D' = one profile per day. Use '240'/'60' for finer intraday profiles.")
profileRows = input.int(20,  "Rows per Profile", minval = 8, maxval = 100, group = grpP, tooltip = "Vertical resolution of each profile (higher = finer). Each session draws roughly Rows×2 boxes and a script is capped at 500 boxes total, so high Rows + many Sessions will silently drop the OLDEST profiles. Guide: Rows 20 → keep ~8 sessions; Rows 40 → keep ~5 sessions; Rows 100 → keep ~2 sessions.")
valueArea   = input.float(70, "Value Area %", minval = 50, maxval = 95, step = 1, group = grpP)
maxSessions = input.int(5,   "Historical Sessions to Keep", minval = 1, maxval = 10, group = grpP, tooltip = "How many completed sessions to keep on the chart. Higher values + high Rows can exceed the 500-box limit, dropping the oldest profiles. ~5–6 sessions at 24 rows is a safe, clean setup.")
widthPct    = input.float(0.32, "Profile Width (% of session)", minval = 0.05, maxval = 1.0, step = 0.02, group = grpP, tooltip = "Width of the widest (POC) row as a fraction of the session's bar-width.")
maxWidthBar = input.int(90,  "Max Profile Width (bars)", minval = 10, maxval = 300, group = grpP)
showLive    = input.bool(true, "Show Developing (current) Profile", group = grpP)

grpC        = "═══ Colors / Gradient ═══"
colBuy      = input.color(#90bff9, "Buy (up) Volume",    group = grpC, inline = "c1", tooltip = "Buy volume — extends from the spine to the right of each row.")
colSell     = input.color(#b39ddb, "Sell (down) Volume", group = grpC, inline = "c1", tooltip = "Sell volume — sits at the left of each row.")
colPOC      = input.color(#5b6472, "POC",        group = grpC, inline = "c2")
colVA       = input.color(#60a5fa, "Value Area",  group = grpC, inline = "c2")
colVWAP     = input.color(#ab47bc, "VWAP",        group = grpC, inline = "c3")
// Radiant gradient (fixed, not exposed in settings): rows are graded by their volume
// share — the POC row renders at gPeak opacity (vivid) and rows fade smoothly toward
// gEdge opacity (faint). Tweak these two constants in code if you want a different look.
gPeak       = 3      // transparency of the highest-volume (POC) rows — lower = darker
gEdge       = 68     // transparency of the lowest-volume rows — higher = more faded
vaBoost     = input.float(1.18, "Value Area Emphasis", minval = 1.0, maxval = 2.0, step = 0.02, group = grpC, tooltip = "Extra brightness for rows inside the value area.")
showBackdrop= input.bool(true, "Soft Range Backdrop", group = grpC)

grpL        = "═══ Intraday Levels ═══"
showPrev    = input.bool(true,  "Prev Session POC / VAH / VAL", group = grpL)
showPDHL    = input.bool(true,  "Prev Day High / Low (PDH/PDL)", group = grpL)
showNaked   = input.bool(false, "Naked / Untested POCs", group = grpL)
showVWAP    = input.bool(true,  "Session VWAP", group = grpL)
vwapSrc     = input.source(hlc3, "  VWAP Source", group = grpL, tooltip = "Price series the VWAP is built from. Default hlc3 (typical price).")
vwapAnchor  = input.timeframe("D", "  VWAP Anchor", group = grpL, tooltip = "When the VWAP resets. 'D' = daily (a fresh VWAP each day). Use 'W'/'M' for weekly/monthly, or '60'/'240' for intraday anchors.")
vwapWidth   = input.int(2, "  VWAP Width", minval = 1, maxval = 4, group = grpL)
vwapBands   = input.bool(false, "  VWAP ± StdDev Bands", group = grpL)
vwapMult    = input.float(1.0, "  Band StdDev Multiplier", minval = 0.1, maxval = 5.0, step = 0.1, group = grpL)
showIB      = input.bool(true,  "Initial Balance", group = grpL)
ibMinutes   = input.int(60, "Initial Balance Minutes", minval = 5, maxval = 240, group = grpL)
levelExt    = input.int(12, "Level Extend (bars right)", minval = 0, maxval = 60, group = grpL)

grpD        = "═══ Dashboard / Alerts ═══"
showDash    = input.bool(true, "Show Dashboard", group = grpD)
dashPos     = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpD)

// =====================================================================================
//  HELPERS
// =====================================================================================

// Index of the maximum value (guarded against the Pine for-loop auto-reverse on size 1).
f_maxIdx(array<float> a) =>
    mi = 0
    mv = array.get(a, 0)
    if array.size(a) > 1
        for i = 1 to array.size(a) - 1
            v = array.get(a, i)
            if v > mv
                mv := v
                mi := i
    mi

// Clear helpers for redrawable object pools.
f_clearBoxes(array<box> a) =>
    if array.size(a) > 0
        for i = 0 to array.size(a) - 1
            box.delete(array.get(a, i))
        array.clear(a)

f_clearLines(array<line> a) =>
    if array.size(a) > 0
        for i = 0 to array.size(a) - 1
            line.delete(array.get(a, i))
        array.clear(a)

f_clearLabels(array<label> a) =>
    if array.size(a) > 0
        for i = 0 to array.size(a) - 1
            label.delete(array.get(a, i))
        array.clear(a)

// Compute-only profile levels (no drawing) — used for alerts/dashboard on confirmed bars.
f_levels(array<float> H, array<float> L, array<float> V) =>
    n = array.size(V)
    float top = array.get(H, 0)
    float bot = array.get(L, 0)
    if n > 1
        for i = 1 to n - 1
            top := math.max(top, array.get(H, i))
            bot := math.min(bot, array.get(L, i))
    rows = profileRows
    rh   = (top - bot) / rows
    vr = array.new<float>(rows, 0.0)
    if rh > 0
        for i = 0 to n - 1
            // Clamp BOTH bins fully into [0, rows-1]. A bar whose low sits exactly at
            // the session top maps to bin == rows, which would overflow the array.
            rB = math.min(rows - 1, math.max(0, int(math.floor((array.get(L, i) - bot) / rh))))
            rT = math.min(rows - 1, math.max(0, int(math.floor((array.get(H, i) - bot) / rh))))
            ve = array.get(V, i) / (rT - rB + 1)
            for r = rB to rT
                array.set(vr, r, array.get(vr, r) + ve)
    pIdx = f_maxIdx(vr)
    tot  = array.sum(vr)
    target = tot * valueArea / 100.0
    vaVol = array.get(vr, pIdx)
    up = pIdx
    dn = pIdx
    while vaVol < target and (up < rows - 1 or dn > 0)
        uV = up < rows - 1 ? array.get(vr, up + 1) : -1.0
        dV = dn > 0        ? array.get(vr, dn - 1) : -1.0
        if uV >= dV
            up += 1
            vaVol += uV
        else
            dn -= 1
            vaVol += dV
    [bot + (pIdx + 0.5) * rh, bot + (up + 1) * rh, bot + dn * rh]

// Draw one session's profile into the given box/line pools. Returns nothing — the
// carry-forward levels are obtained separately via f_levels() to keep the interface clean.
f_draw(int x1, int x2, array<float> H, array<float> L, array<float> V, array<float> U, array<box> bp, array<line> lp) =>
    n = array.size(V)
    float top = array.get(H, 0)
    float bot = array.get(L, 0)
    if n > 1
        for i = 1 to n - 1
            top := math.max(top, array.get(H, i))
            bot := math.min(bot, array.get(L, i))
    rows = profileRows
    rh   = (top - bot) / rows

    vr = array.new<float>(rows, 0.0)   // total volume per row
    ur = array.new<float>(rows, 0.0)   // up (buy) volume per row
    dr = array.new<float>(rows, 0.0)   // down (sell) volume per row
    if rh > 0
        for i = 0 to n - 1
            bv   = array.get(V, i)
            isUp = array.get(U, i) > 0.5
            // Clamp BOTH bins fully into [0, rows-1]. A bar whose low sits exactly at
            // the session top maps to bin == rows, which would overflow the array.
            rB = math.min(rows - 1, math.max(0, int(math.floor((array.get(L, i) - bot) / rh))))
            rT = math.min(rows - 1, math.max(0, int(math.floor((array.get(H, i) - bot) / rh))))
            ve = bv / (rT - rB + 1)
            for r = rB to rT
                array.set(vr, r, array.get(vr, r) + ve)
                if isUp
                    array.set(ur, r, array.get(ur, r) + ve)
                else
                    array.set(dr, r, array.get(dr, r) + ve)

    pIdx = f_maxIdx(vr)
    maxV = array.max(vr)
    tot  = array.sum(vr)

    // Value Area expansion from POC.
    target = tot * valueArea / 100.0
    vaVol = array.get(vr, pIdx)
    up = pIdx
    dn = pIdx
    while vaVol < target and (up < rows - 1 or dn > 0)
        uV = up < rows - 1 ? array.get(vr, up + 1) : -1.0
        dV = dn > 0        ? array.get(vr, dn - 1) : -1.0
        if uV >= dV
            up += 1
            vaVol += uV
        else
            dn -= 1
            vaVol += dV

    float pocP = bot + (pIdx + 0.5) * rh
    float vahP = bot + (up + 1) * rh
    float valP = bot + dn * rh

    // Horizontal width scaling.
    int sessW = math.max(1, x2 - x1)
    int wMax  = math.min(maxWidthBar, math.max(3, int(sessW * widthPct)))

    // ---- Layered radiant backdrop (drawn first, behind everything) ----
    // 1) Soft full-range panel for depth.
    if showBackdrop
        array.push(bp, box.new(x1, top, x2, bot, border_width = 0, bgcolor = color.new(colVA, 95)))
    // 2) Value Area highlight panel.
    array.push(bp, box.new(x1, vahP, x2, valP, border_width = 0, bgcolor = color.new(colVA, 87)))

    // ---- Histogram rows, volume-graded for a radiant gradient ----
    // Each row's opacity is interpolated from gEdge (faint) at zero volume to gPeak
    // (vivid) at the POC, so the profile glows brightest at its highest-volume nodes.
    if maxV > 0 and rh > 0
        for r = 0 to rows - 1
            tv = array.get(vr, r)
            if tv > 0
                w  = math.max(1, int(tv / maxV * wMax))
                dW = int(array.get(dr, r) / tv * w)   // sell width
                uW = w - dW                           // buy width
                rTopP = bot + (r + 1) * rh
                rBotP = bot + r * rh
                // Volume share (0..1), brightened a touch inside the value area.
                inVA = r >= dn and r <= up
                shr  = math.min(1.0, (tv / maxV) * (inVA ? vaBoost : 1.0))
                tr   = int(gEdge - shr * (gEdge - gPeak))   // gEdge -> gPeak as shr 0 -> 1
                sellC = color.new(colSell, tr)
                buyC  = color.new(colBuy,  tr)
                if dW > 0
                    array.push(bp, box.new(x1,      rTopP, x1 + dW,      rBotP, border_width = 0, bgcolor = sellC))
                if uW > 0
                    array.push(bp, box.new(x1 + dW, rTopP, x1 + dW + uW, rBotP, border_width = 0, bgcolor = buyC))

    // ---- POC: translucent band + crisp center line for a glow effect ----
    array.push(bp, box.new(x1, pocP + rh * 0.5, x2, pocP - rh * 0.5, border_width = 0, bgcolor = color.new(colPOC, 62)))
    array.push(lp, line.new(x1, pocP, x2, pocP, color = color.new(colPOC, 15), width = 4))

// =====================================================================================
//  SESSION STATE
// =====================================================================================
var array<float> pH = array.new<float>()   // current session bar highs
var array<float> pL = array.new<float>()   // current session bar lows
var array<float> pV = array.new<float>()   // current session bar volumes
var array<float> pU = array.new<float>()   // 1.0 = up bar, 0.0 = down bar

var int   sStart   = bar_index             // current session start bar_index
var int   barsInS  = 0
var float curHi    = na
var float curLo    = na
var float ibHi     = na
var float ibLo     = na

// Previous completed-session reference levels.
// (Pine has no comma-separated multi-var declaration — each needs its own typed line.)
var float pPoc = na
var float pVah = na
var float pVal = na
var float pdh  = na
var float pdl  = na

// Current developing-session levels (computed every confirmed bar for alerts).
var float cPoc = na
var float cVah = na
var float cVal = na

// Naked POC tracking.
var array<float> nakedP = array.new<float>()
var array<int>   nakedX = array.new<int>()

// Permanent drawing pools for completed sessions (+ per-session batch sizes for trimming).
var array<box>  histB = array.new<box>()
var array<line> histL = array.new<line>()
var array<int>  batchB = array.new<int>()
var array<int>  batchL = array.new<int>()

// Redrawable pools (cleared every last bar).
var array<box>   liveB  = array.new<box>()
var array<line>  liveL   = array.new<line>()
var array<line>  lvlL    = array.new<line>()
var array<label> lvlLbl  = array.new<label>()

// Bars that make up the Initial Balance window.
ibBars = math.max(1, int(ibMinutes / math.max(1, timeframe.in_seconds() / 60.0)))

newSession = timeframe.change(profileTF)

// =====================================================================================
//  COLLECTION & SESSION FINALIZATION  (confirmed bars only -> non-repaint)
// =====================================================================================
if barstate.isconfirmed
    if newSession
        // The previous session has fully closed — draw it permanently.
        if array.size(pV) > 0
            // Carry-forward levels (compute), then draw the permanent profile.
            [fp, fvh, fvl] = f_levels(pH, pL, pV)
            b0 = array.size(histB)
            l0 = array.size(histL)
            f_draw(sStart, bar_index - 1, pH, pL, pV, pU, histB, histL)
            array.push(batchB, array.size(histB) - b0)
            array.push(batchL, array.size(histL) - l0)
            pPoc := fp
            pVah := fvh
            pVal := fvl
            pdh  := curHi
            pdl  := curLo
            // Register the just-closed POC as a (currently) naked POC.
            array.push(nakedP, fp)
            array.push(nakedX, bar_index - 1)
            // Cap the naked-POC list so lines/labels stay bounded over many days.
            while array.size(nakedP) > 30
                array.shift(nakedP)
                array.shift(nakedX)
            // Trim oldest sessions beyond the keep-limit.
            while array.size(batchB) > maxSessions
                nb = array.shift(batchB)
                if nb > 0
                    for i = 1 to nb
                        box.delete(array.shift(histB))
                nl = array.shift(batchL)
                if nl > 0
                    for i = 1 to nl
                        line.delete(array.shift(histL))

        // Reset for the new session.
        array.clear(pH)
        array.clear(pL)
        array.clear(pV)
        array.clear(pU)
        sStart  := bar_index
        barsInS := 0
        curHi   := na
        curLo   := na
        ibHi    := na
        ibLo    := na

    // Collect this confirmed bar into the current session.
    array.push(pH, high)
    array.push(pL, low)
    array.push(pV, volume)
    array.push(pU, close >= open ? 1.0 : 0.0)
    curHi := na(curHi) ? high : math.max(curHi, high)
    curLo := na(curLo) ? low  : math.min(curLo, low)
    barsInS += 1
    if barsInS <= ibBars
        ibHi := na(ibHi) ? high : math.max(ibHi, high)
        ibLo := na(ibLo) ? low  : math.min(ibLo, low)

    // Remove naked POCs that price has now traded through (high >= poc >= low).
    if array.size(nakedP) > 0
        for i = array.size(nakedP) - 1 to 0
            p = array.get(nakedP, i)
            if low <= p and high >= p
                array.remove(nakedP, i)
                array.remove(nakedX, i)

    // Developing-session levels for alerts/dashboard (compute only, no draw).
    if array.size(pV) > 0
        [dp, dvh, dvl] = f_levels(pH, pL, pV)
        cPoc := dp
        cVah := dvh
        cVal := dvl

// =====================================================================================
//  SESSION VWAP
// =====================================================================================
// VWAP from the chosen source, reset on the chosen anchor; optional ±σ bands.
vwapAnc = timeframe.change(vwapAnchor)
[vwapVal, vwapUp, vwapDn] = ta.vwap(vwapSrc, vwapAnc, vwapMult)
plot(showVWAP ? vwapVal : na, "VWAP", color = colVWAP, linewidth = vwapWidth)
plot(showVWAP and vwapBands ? vwapUp : na, "VWAP Upper Band", color = color.new(colVWAP, 45), linewidth = 1)
plot(showVWAP and vwapBands ? vwapDn : na, "VWAP Lower Band", color = color.new(colVWAP, 45), linewidth = 1)

// =====================================================================================
//  LIVE DRAWING  (only on the last bar)
// =====================================================================================
// Draw a horizontal level line at its TRUE price.
f_lvlLine(float price, color col, string style, int wid, int x1, int x2) =>
    array.push(lvlL, line.new(x1, price, x2, price, color = col, width = wid, style = style))

// Place queued labels with vertical anti-overlap. Labels are sorted by price (ascending)
// and each is nudged up by at least `gap` from the previous one, so their text never
// overlaps. The level LINES stay at their true price — only the label bubbles move apart.
f_placeLabels(array<float> ys, array<string> txts, array<color> cols, int x, float gap) =>
    n = array.size(ys)
    if n > 0
        used = array.new<bool>(n, false)
        float lastY = na
        for k = 0 to n - 1
            // Find the lowest-priced label not yet placed (selection sort; n is tiny).
            int   mi = -1
            float mv = 0.0
            for j = 0 to n - 1
                if not array.get(used, j)
                    v = array.get(ys, j)
                    if mi == -1 or v < mv
                        mi := j
                        mv := v
            array.set(used, mi, true)
            float dispY = na(lastY) ? mv : math.max(mv, lastY + gap)
            lastY := dispY
            c = array.get(cols, mi)
            array.push(lvlLbl, label.new(x, dispY, array.get(txts, mi), style = label.style_label_left, color = color.new(c, 80), textcolor = c, size = size.small))

// Scale-aware vertical spacing for level labels (≈ a small fraction of the recent range).
pxRange  = ta.highest(high, 100) - ta.lowest(low, 100)
labelGap = (na(pxRange) or pxRange <= 0) ? syminfo.mintick * 20 : pxRange * 0.025

if barstate.islast
    f_clearBoxes(liveB)
    f_clearLines(liveL)
    f_clearLines(lvlL)
    f_clearLabels(lvlLbl)

    rightX = bar_index + levelExt

    // Developing current-session profile.
    if showLive and array.size(pV) > 0
        f_draw(sStart, bar_index, pH, pL, pV, pU, liveB, liveL)

    // Draw the reference-level LINES at their true price and queue their labels.
    // Labels are placed afterwards with anti-overlap so close levels stay readable.
    reqY   = array.new<float>()
    reqTxt = array.new<string>()
    reqCol = array.new<color>()

    // Previous-session reference levels carried into the current session (bolder width 3).
    if showPrev and not na(pPoc)
        f_lvlLine(pPoc, color.new(colPOC, 0), line.style_solid,  3, sStart, rightX)
        f_lvlLine(pVah, color.new(colVA, 20), line.style_dashed, 3, sStart, rightX)
        f_lvlLine(pVal, color.new(colVA, 20), line.style_dashed, 3, sStart, rightX)
        array.push(reqY, pPoc)
        array.push(reqTxt, "pPOC " + str.tostring(pPoc, format.mintick))
        array.push(reqCol, colPOC)
        array.push(reqY, pVah)
        array.push(reqTxt, "pVAH " + str.tostring(pVah, format.mintick))
        array.push(reqCol, colVA)
        array.push(reqY, pVal)
        array.push(reqTxt, "pVAL " + str.tostring(pVal, format.mintick))
        array.push(reqCol, colVA)

    if showPDHL and not na(pdh)
        f_lvlLine(pdh, color.new(#ef5350, 0), line.style_dotted, 3, sStart, rightX)
        f_lvlLine(pdl, color.new(#26a69a, 0), line.style_dotted, 3, sStart, rightX)
        array.push(reqY, pdh)
        array.push(reqTxt, "PDH " + str.tostring(pdh, format.mintick))
        array.push(reqCol, #ef5350)
        array.push(reqY, pdl)
        array.push(reqTxt, "PDL " + str.tostring(pdl, format.mintick))
        array.push(reqCol, #26a69a)

    if showIB and not na(ibHi)
        f_lvlLine(ibHi, color.new(#ffa726, 0), line.style_solid, 1, sStart, rightX)
        f_lvlLine(ibLo, color.new(#ffa726, 0), line.style_solid, 1, sStart, rightX)
        array.push(reqY, ibHi)
        array.push(reqTxt, "IBH " + str.tostring(ibHi, format.mintick))
        array.push(reqCol, #ffa726)
        array.push(reqY, ibLo)
        array.push(reqTxt, "IBL " + str.tostring(ibLo, format.mintick))
        array.push(reqCol, #ffa726)

    // Naked / untested POCs from earlier sessions.
    if showNaked and array.size(nakedP) > 0
        for i = 0 to array.size(nakedP) - 1
            np = array.get(nakedP, i)
            // A bar_index x-coordinate must stay within ~10000 bars of the current bar,
            // but a naked POC can originate from a much older session. Clamp the line's
            // start so it still renders (it only shortens the left tail).
            nx = math.max(array.get(nakedX, i), bar_index - 9000)
            f_lvlLine(np, color.new(#ff9800, 30), line.style_dotted, 3, nx, rightX)
            array.push(reqY, np)
            array.push(reqTxt, "nPOC " + str.tostring(np, format.mintick))
            array.push(reqCol, #ff9800)

    // Place every queued label with vertical anti-overlap so none collide.
    f_placeLabels(reqY, reqTxt, reqCol, rightX, labelGap)

// =====================================================================================
//  DASHBOARD
// =====================================================================================
f_tpos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

// ---- Dashboard theme (flat, modern, zebra-striped) ----
cFrame  = #2b3340      // outer frame
cHdrBg  = #0d1b2a      // header band (deep navy)
cHdrTxt = #e6edf3      // header brand text
cAccent = #58a6ff      // accent (symbol / timeframe)
cZebraA = #161b22      // even-row background
cZebraB = #1b212b      // odd-row background
cLbl    = #8b949e      // muted label text
// Value colors mirror the CHART line/label colors so the table reads as a legend:
//   POC = gray (colPOC), Value Area = blue (colVA), VWAP = purple (colVWAP),
//   PDH = red, PDL = green, Initial Balance = orange, Naked POC = orange-amber.
cPDH    = #ef5350      // prev-day high   (matches chart PDH)
cPDL    = #26a69a      // prev-day low    (matches chart PDL)
cIB     = #ffa726      // initial balance (matches chart IBH/IBL)
cNaked  = #ff9800      // naked POC       (matches chart nPOC)

var table dash = table.new(f_tpos(dashPos), 2, 14, border_width = 0, frame_width = 1, frame_color = cFrame)

// One label/value row with zebra striping and a right-aligned, colored value.
f_drow(int r, string k, string v, color vc) =>
    bg = r % 2 == 0 ? cZebraA : cZebraB
    table.cell(dash, 0, r, "  " + k,       text_color = cLbl, text_size = size.small, text_halign = text.align_left,  bgcolor = bg)
    table.cell(dash, 1, r, v + "   ",      text_color = vc,   text_size = size.small, text_halign = text.align_right, bgcolor = bg)

// Where is price relative to the developing value area?
locTxt = na(cVah) ? "—" : close > cVah ? "Above Value" : close < cVal ? "Below Value" : "Inside Value"

if showDash and barstate.islast
    // Header band: brand + symbol·timeframe.
    table.cell(dash, 0, 0, "  ◧ SVP · INTRADAY", text_color = cHdrTxt, text_size = size.normal, text_halign = text.align_left,  bgcolor = cHdrBg)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period + "  ", text_color = cAccent, text_size = size.normal, text_halign = text.align_right, bgcolor = cHdrBg)

    // Price-location status badge (filled, semantic).
    locBg = na(cVah) ? #30363d : close > cVah ? #14532d : close < cVal ? #7f1d2b : #353c48
    locTc = na(cVah) ? cLbl    : close > cVah ? #7ee2a8 : close < cVal ? #ffb3bb : #cfd6e0
    table.cell(dash, 0, 1, "  Price Location", text_color = cLbl, text_size = size.small, text_halign = text.align_left,  bgcolor = cZebraB)
    table.cell(dash, 1, 1, " " + locTxt + " ", text_color = locTc, text_size = size.small, text_halign = text.align_right, bgcolor = locBg)

    f_drow(2,  "Session POC", na(cPoc) ? "—" : str.tostring(cPoc, format.mintick), colPOC)
    f_drow(3,  "Session VAH", na(cVah) ? "—" : str.tostring(cVah, format.mintick), colVA)
    f_drow(4,  "Session VAL", na(cVal) ? "—" : str.tostring(cVal, format.mintick), colVA)
    f_drow(5,  "VWAP",        str.tostring(vwapVal, format.mintick), colVWAP)
    f_drow(6,  "Prev POC",    na(pPoc) ? "—" : str.tostring(pPoc, format.mintick), colPOC)
    f_drow(7,  "Prev VAH",    na(pVah) ? "—" : str.tostring(pVah, format.mintick), colVA)
    f_drow(8,  "Prev VAL",    na(pVal) ? "—" : str.tostring(pVal, format.mintick), colVA)
    f_drow(9,  "PDH",         na(pdh)  ? "—" : str.tostring(pdh, format.mintick), cPDH)
    f_drow(10, "PDL",         na(pdl)  ? "—" : str.tostring(pdl, format.mintick), cPDL)
    f_drow(11, "IBH",         na(ibHi) ? "—" : str.tostring(ibHi, format.mintick), cIB)
    f_drow(12, "IBL",         na(ibLo) ? "—" : str.tostring(ibLo, format.mintick), cIB)
    f_drow(13, "Naked POCs",  str.tostring(array.size(nakedP)), cNaked)

// =====================================================================================
//  ALERTS  (evaluated on confirmed bars -> non-repaint)
// =====================================================================================
cf = barstate.isconfirmed
alertcondition(cf and not na(cPoc) and ta.crossover(close, cPoc),  "POC Cross Up",   "SVP: Price crossed above session POC")
alertcondition(cf and not na(cPoc) and ta.crossunder(close, cPoc), "POC Cross Down", "SVP: Price crossed below session POC")
alertcondition(cf and not na(cVah) and ta.crossover(close, cVah),  "Value Area Breakout",  "SVP: Price accepted above Value Area High")
alertcondition(cf and not na(cVal) and ta.crossunder(close, cVal), "Value Area Breakdown", "SVP: Price rejected below Value Area Low")
alertcondition(cf and not na(pPoc) and (ta.crossover(close, pPoc) or ta.crossunder(close, pPoc)), "Prev POC Test", "SVP: Price testing previous session POC")
alertcondition(cf and not na(pdh) and ta.crossover(close, pdh),  "PDH Break", "SVP: Price broke previous day high")
alertcondition(cf and not na(pdl) and ta.crossunder(close, pdl), "PDL Break", "SVP: Price broke previous day low")
alertcondition(cf and showVWAP and ta.cross(close, vwapVal), "VWAP Cross", "SVP: Price crossed session VWAP")
````
