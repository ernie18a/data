# ICT Dealing Range [EmpArchitect]

- url: https://www.tradingview.com/script/q6O0kR6a-ICT-Dealing-Range-EmpArchitect/
- type: indicator
- pine_id: PUB;442c5f855d8945b799a6c3ecae0af9d7
- version: 1.0

## Description

█ OVERVIEW

ICT Dealing Range auto-detects the active confirmed swing range and maps premium, discount, equilibrium, and directional OTE context directly on your chart.

No manual Fibonacci drawing.
No signals.
No entries.
No targets.

This is a clean dealing-range framework for ICT, SMC, and price-action workflows.

The tool answers one question:

Where is price trading within the active range?

█ WHAT IT SHOWS

The script draws:

• Active confirmed swing range
• Premium zone
• Discount zone
• 50% equilibrium
• Directional OTE zone
• Range high and range low
• Compact dashboard state

Premium and discount are always based on the active range:

• Premium = above equilibrium
• Discount = below equilibrium
• Equilibrium = 50% midpoint of the range

█ DIRECTIONAL OTE

OTE is directional.

In Bull Pullback mode, the range is measured Low → High and the OTE zone is drawn inside discount.

In Bear Rally mode, the range is measured High → Low and the OTE zone is drawn inside premium.

Default OTE levels:

• 62%
• 70.5%
• 79%

The 70.5% midpoint is shown inside the OTE zone.

█ RANGE DETECTION

The indicator uses confirmed pivot highs and lows to define the active dealing range.

Auto mode uses the most recent valid alternating pivot sequence:

• Low → High = Bull Pullback
• High → Low = Bear Rally

A minimum ATR range-size filter helps reject noisy micro-ranges on lower timeframes.

Auto-Update can be turned off to freeze the current range.

█ DASHBOARD

The top-right dashboard summarizes current range context:

• Mode: Bull Pullback / Bear Rally
• Zone: Premium / Discount / EQ / Above Range / Below Range
• Bull OTE / Bear OTE: Inside / Above / Below
• Range: size in ATR, or Broken Low / Broken High if price exits the range
• Age: bars since the range formed

If price breaks below a bullish range low or above a bearish range high, the dashboard marks the broken-range state clearly.

█ RANGE MODE

Available modes:

• Auto — uses the latest valid alternating pivot sequence
• Bull Pullback — forces Low → High range, OTE in discount
• Bear Rally — forces High → Low range, OTE in premium

█ VISUAL SYSTEM

The color system matches the EmpArchitect suite:

• Premium = amber
• Discount = teal
• OTE = subtle white / silver
• EQ = gray dashed line

Line hierarchy:

• EQ = dashed, width 2
• Range edges = solid, thin
• OTE levels = dotted, thin

Right-edge labels show:

• 100% High
• 50% EQ
• 0% Low
• Bull OTE / Bear OTE

█ ALERTS

Included factual alerts:

• Price entered premium
• Price entered discount
• Price crossed equilibrium
• Price entered directional OTE
• Price left directional OTE

Alerts are context alerts only. They are not trade signals.

█ NON-REPAINTING LOGIC

Ranges are based on confirmed pivots.

Pivot-based ranges confirm only after the required right-side bars have closed. This is structural confirmation by design.

Once a range is confirmed, it remains stable until a new valid confirmed range replaces it, or Auto-Update is disabled to freeze the current range.

█ PAIRS WITH

Smart Liquidity Map [EmpArchitect] — liquidity context

HTF Context Overlay [EmpArchitect] — higher-timeframe reference levels

Liquidity Trap Zones [EmpArchitect] — failed reversal / trap context

CISD tools [EmpArchitect] — displacement confirmation context

█ NOTES

• Works on all instruments and timeframes
• Best on 15M–4H charts
• Pine Script v6
• Open-source
• Built by EmpArchitect

Educational context tool only.
Not financial advice.
Not a signal service.

## Source Code

````pine
//@version=6
indicator("ICT Dealing Range [EmpArchitect]", shorttitle="ICT Range [EA]", overlay=true, max_boxes_count=20, max_lines_count=30, max_labels_count=30)

// ═══════════════════════════════════════════════════════════════════
// ICT DEALING RANGE [EmpArchitect] v1.0
//
// Auto-detected premium, discount, equilibrium, and directional OTE
// context from the active confirmed swing range.
//
// No signals. No entries. No targets. Just range context.
//
// PAIRS WITH:
//   Smart Liquidity Map — where liquidity sits
//   HTF Context Overlay — HTF reference levels
//   ICT Dealing Range — where price is in the range
// ═══════════════════════════════════════════════════════════════════

// ─────────────── INPUTS ───────────────

grp1 = "Detection"
swingLen     = input.int(10, "Swing Length", minval=3, maxval=50, group=grp1, tooltip="Pivot detection sensitivity. Higher = bigger swings, fewer updates.")
minRangeATR  = input.float(1.5, "Min Range Size (ATR)", minval=0.5, maxval=10.0, step=0.25, group=grp1, tooltip="Rejects ranges smaller than this multiple of ATR. Prevents noise on lower timeframes.")
rangeMode    = input.string("Auto", "Range Mode", options=["Auto", "Bullish Pullback", "Bearish Rally"], group=grp1, tooltip="Auto: uses latest valid alternating pivots. Bullish Pullback: Low→High, OTE in discount. Bearish Rally: High→Low, OTE in premium.")
autoUpdate   = input.bool(true, "Auto-Update Range", group=grp1, tooltip="ON: updates when new valid range forms. OFF: freezes current range.")

grp2 = "Display"
showPremium  = input.bool(true, "Show Premium Zone", group=grp2)
showDiscount = input.bool(true, "Show Discount Zone", group=grp2)
showOTE      = input.bool(true, "Show Directional OTE", group=grp2)
showEQ       = input.bool(true, "Show EQ Line", group=grp2)
showRange    = input.bool(true, "Show Range High/Low", group=grp2)
showLabels   = input.bool(true, "Show Labels", group=grp2)
showFibLbls  = input.bool(false, "Show Fib Level Labels", group=grp2, tooltip="Shows 62%, 70.5%, 79% labels. Off by default for cleaner charts.")
showDash     = input.bool(true, "Show Dashboard", group=grp2)

grp3 = "OTE Settings"
oteLower     = input.float(0.62, "OTE Lower Retracement", minval=0.5, maxval=0.75, step=0.01, group=grp3)
oteMid       = input.float(0.705, "OTE Midpoint", minval=0.6, maxval=0.8, step=0.005, group=grp3)
oteUpper     = input.float(0.79, "OTE Upper Retracement", minval=0.7, maxval=0.9, step=0.01, group=grp3)

grp4 = "Style"
premCol      = input.color(color.new(#F59E0B, 88), "Premium Zone", group=grp4)
discCol      = input.color(color.new(#00D9A3, 88), "Discount Zone", group=grp4)
oteCol       = input.color(color.new(#DDE3EA, 85), "OTE Zone", group=grp4)
eqCol        = input.color(color.new(#9CA3AF, 20), "EQ Line", group=grp4)
rangeCol     = input.color(color.new(#6B7280, 40), "Range Edges", group=grp4)

// ─────────────── ATR ───────────────

atr = ta.atr(14)

// ─────────────── PIVOT DETECTION ───────────────

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

// Store confirmed pivots
var float lastPH = na
var int lastPHbar = na
var float lastPL = na
var int lastPLbar = na

// Track which pivot was most recent: true = high, false = low
var bool lastWasHigh = false
var bool pivotSeen = false

// Active range
var float activeHigh = na
var float activeLow = na
var int activeHighBar = na
var int activeLowBar = na
var bool activeBullish = true
var bool rangeValid = false

// Frozen range support
var float frozenHigh = na
var float frozenLow = na
var int frozenHighBar = na
var int frozenLowBar = na
var bool frozenBullish = true
var bool frozenValid = false

if not na(ph)
    lastPH := ph
    lastPHbar := bar_index - swingLen
    if not pivotSeen or not lastWasHigh
        // New alternating high after a low
        float rng = math.abs(lastPH - lastPL)
        if not na(lastPL) and not na(atr) and rng >= atr * minRangeATR
            if autoUpdate
                activeHigh := lastPH
                activeLow := lastPL
                activeHighBar := lastPHbar
                activeLowBar := lastPLbar
                activeBullish := lastPHbar > lastPLbar
                rangeValid := true
            else if not frozenValid
                frozenHigh := lastPH
                frozenLow := lastPL
                frozenHighBar := lastPHbar
                frozenLowBar := lastPLbar
                frozenBullish := lastPHbar > lastPLbar
                frozenValid := true
    lastWasHigh := true
    pivotSeen := true

if not na(pl)
    lastPL := pl
    lastPLbar := bar_index - swingLen
    if not pivotSeen or lastWasHigh
        // New alternating low after a high
        float rng = math.abs(lastPH - lastPL)
        if not na(lastPH) and not na(atr) and rng >= atr * minRangeATR
            if autoUpdate
                activeHigh := lastPH
                activeLow := lastPL
                activeHighBar := lastPHbar
                activeLowBar := lastPLbar
                activeBullish := lastPLbar > lastPHbar
                rangeValid := true
            else if not frozenValid
                frozenHigh := lastPH
                frozenLow := lastPL
                frozenHighBar := lastPHbar
                frozenLowBar := lastPLbar
                frozenBullish := lastPLbar > lastPHbar
                frozenValid := true
    lastWasHigh := false
    pivotSeen := true

// Use frozen range when auto-update is off
float useHigh = autoUpdate ? activeHigh : frozenHigh
float useLow = autoUpdate ? activeLow : frozenLow
int useHighBar = autoUpdate ? activeHighBar : frozenHighBar
int useLowBar = autoUpdate ? activeLowBar : frozenLowBar
bool useBullish = autoUpdate ? activeBullish : frozenBullish
bool useValid = autoUpdate ? rangeValid : frozenValid

// Manual override
if rangeMode == "Bullish Pullback"
    useBullish := true
else if rangeMode == "Bearish Rally"
    useBullish := false

// ─────────────── LEVEL CALCULATIONS ───────────────

float rngSize = useValid ? math.abs(useHigh - useLow) : na

// EQ
float eq = useValid ? useLow + rngSize * 0.5 : na

// Directional OTE
// Bullish: retracement FROM high INTO discount
// Bearish: retracement FROM low INTO premium
float oteTop = na
float oteMidLvl = na
float oteBot = na

if useValid
    if useBullish
        oteTop := useHigh - rngSize * oteLower
        oteMidLvl := useHigh - rngSize * oteMid
        oteBot := useHigh - rngSize * oteUpper
    else
        oteBot := useLow + rngSize * oteLower
        oteMidLvl := useLow + rngSize * oteMid
        oteTop := useLow + rngSize * oteUpper

// ─────────────── CURRENT STATE ───────────────

float eqBuffer = nz(atr, 0) * 0.10

string zoneState = "—"
if useValid and not na(eq)
    if close > useHigh
        zoneState := "Above Range"
    else if close > eq + eqBuffer
        zoneState := "Premium"
    else if close < useLow
        zoneState := "Below Range"
    else if close < eq - eqBuffer
        zoneState := "Discount"
    else
        zoneState := "EQ"

string oteLabel = useBullish ? "Bull OTE" : "Bear OTE"

string oteState = "—"
if useValid and not na(oteTop) and not na(oteBot)
    if close >= oteBot and close <= oteTop
        oteState := "Inside"
    else if close > oteTop
        oteState := "Above"
    else
        oteState := "Below"

string modeStr = useBullish ? "Bull Pullback" : "Bear Rally"

float rngATR = useValid and not na(atr) and atr > 0 ? rngSize / atr : na

int rangeStartBar = useValid ? math.min(nz(useHighBar, bar_index), nz(useLowBar, bar_index)) : na
int rangeAge = useValid and not na(rangeStartBar) ? bar_index - rangeStartBar : na

// ─────────────── DRAWING ───────────────

var box premBox = na
var box discBox = na
var box oteBox = na
var line eqLine = na
var line highLine = na
var line lowLine = na
var line oteMidLine = na

// Clean previous drawings
box.delete(premBox)
box.delete(discBox)
box.delete(oteBox)
line.delete(eqLine)
line.delete(highLine)
line.delete(lowLine)
line.delete(oteMidLine)

int xStart = useValid and not na(rangeStartBar) ? rangeStartBar : bar_index
int xEnd = bar_index + 3

if useValid and not na(useHigh) and not na(useLow) and not na(eq)
    // Premium zone: EQ → High
    if showPremium
        premBox := box.new(xStart, useHigh, xEnd, eq, bgcolor=premCol, border_color=color.new(#F59E0B, 60), border_width=1)

    // Discount zone: Low → EQ
    if showDiscount
        discBox := box.new(xStart, eq, xEnd, useLow, bgcolor=discCol, border_color=color.new(#00D9A3, 60), border_width=1)

    // OTE zone
    if showOTE and not na(oteTop) and not na(oteBot)
        oteBox := box.new(xStart, oteTop, xEnd, oteBot, bgcolor=oteCol, border_color=color.new(#DDE3EA, 50), border_width=1)

        // OTE midpoint line
        if not na(oteMidLvl)
            oteMidLine := line.new(xStart, oteMidLvl, xEnd, oteMidLvl, color=color.new(#DDE3EA, 40), style=line.style_dotted, width=1)

    // EQ line
    if showEQ
        eqLine := line.new(xStart, eq, xEnd, eq, color=eqCol, style=line.style_dashed, width=2)

    // Range edges
    if showRange
        highLine := line.new(xStart, useHigh, xEnd, useHigh, color=rangeCol, style=line.style_solid, width=1)
        lowLine := line.new(xStart, useLow, xEnd, useLow, color=rangeCol, style=line.style_solid, width=1)

// ─────────────── LABELS ───────────────

var label highLbl = na
var label lowLbl = na
var label eqLbl = na
var label oteLbl = na
var label oteUpperLbl = na
var label oteMidLbl = na
var label oteLowerLbl = na

if barstate.islast
    label.delete(highLbl)
    label.delete(lowLbl)
    label.delete(eqLbl)
    label.delete(oteLbl)
    label.delete(oteUpperLbl)
    label.delete(oteMidLbl)
    label.delete(oteLowerLbl)

    if useValid and showLabels
        int lx = bar_index + 3

        if showRange and not na(useHigh)
            highLbl := label.new(lx, useHigh, "100% High", style=label.style_none, textcolor=#F59E0B, size=size.tiny)
        if showRange and not na(useLow)
            lowLbl := label.new(lx, useLow, "0% Low", style=label.style_none, textcolor=#00D9A3, size=size.tiny)
        if showEQ and not na(eq)
            eqLbl := label.new(lx, eq, "50% EQ", style=label.style_none, textcolor=color.white, size=size.tiny)
        if showOTE and not na(oteMidLvl)
            oteLbl := label.new(lx, oteMidLvl, oteLabel, style=label.style_none, textcolor=color.white, size=size.tiny)

        // Optional fib labels
        if showFibLbls and showOTE
            if not na(oteTop)
                string upperPct = useBullish ? str.tostring(oteLower * 100, "#.#") + "%" : str.tostring(oteLower * 100, "#.#") + "%"
                oteUpperLbl := label.new(lx + 2, oteTop, upperPct, style=label.style_none, textcolor=color.new(#DDE3EA, 40), size=size.tiny)
            if not na(oteMidLvl)
                oteMidLbl := label.new(lx + 2, oteMidLvl, str.tostring(oteMid * 100, "#.#") + "%", style=label.style_none, textcolor=color.new(#DDE3EA, 40), size=size.tiny)
            if not na(oteBot)
                string lowerPct = useBullish ? str.tostring(oteUpper * 100, "#.#") + "%" : str.tostring(oteUpper * 100, "#.#") + "%"
                oteLowerLbl := label.new(lx + 2, oteBot, lowerPct, style=label.style_none, textcolor=color.new(#DDE3EA, 40), size=size.tiny)

// ─────────────── DASHBOARD ───────────────

var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 82), border_width=0)

if barstate.islast and showDash and useValid
    table.clear(dash, 0, 0, 1, 5)

    // Row 0: Title
    table.cell(dash, 0, 0, "ICT Dealing Range", text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, "v1.0", text_color=#6B7280, text_size=size.tiny, text_halign=text.align_right)

    // Row 1: Mode
    color modeCol = useBullish ? #00D9A3 : #F59E0B
    table.cell(dash, 0, 1, "Mode", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 1, modeStr, text_color=modeCol, text_size=size.tiny, text_halign=text.align_right)

    // Row 2: Zone
    color zoneCol = zoneState == "Premium" ? #F59E0B : zoneState == "Discount" ? #00D9A3 : zoneState == "Above Range" or zoneState == "Below Range" ? #FF4B5C : #9CA3AF
    table.cell(dash, 0, 2, "Zone", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 2, zoneState, text_color=zoneCol, text_size=size.tiny, text_halign=text.align_right)

    // Row 3: OTE (directional)
    color oteC = oteState == "Inside" ? color.white : #6B7280
    table.cell(dash, 0, 3, oteLabel, text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 3, oteState, text_color=oteC, text_size=size.tiny, text_halign=text.align_right)

    // Row 4: Range — shows Broken Low/High when price outside range
    bool brokenLow = not na(useLow) and close < useLow
    bool brokenHigh = not na(useHigh) and close > useHigh
    string rngStr = brokenLow ? "Broken Low" : brokenHigh ? "Broken High" : not na(rngATR) ? str.tostring(rngATR, "#.#") + " ATR" : "—"
    color rngCol = brokenLow or brokenHigh ? #FF4B5C : color.white
    table.cell(dash, 0, 4, "Range", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 4, rngStr, text_color=rngCol, text_size=size.tiny, text_halign=text.align_right)

    // Row 5: Age
    string ageStr = not na(rangeAge) ? str.tostring(rangeAge) + " bars" : "—"
    table.cell(dash, 0, 5, "Age", text_color=#9CA3AF, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 5, ageStr, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)

else if barstate.islast and (not showDash or not useValid)
    table.clear(dash, 0, 0, 1, 5)

// ─────────────── ALERTS ───────────────

bool enteredPremium = useValid and not na(eq) and close > eq and close[1] <= eq
bool enteredDiscount = useValid and not na(eq) and close < eq and close[1] >= eq
bool crossedEQ = useValid and not na(eq) and ((close > eq and close[1] < eq) or (close < eq and close[1] > eq))
bool enteredOTE = useValid and not na(oteTop) and not na(oteBot) and close >= oteBot and close <= oteTop and not (close[1] >= oteBot and close[1] <= oteTop)
bool leftOTE = useValid and not na(oteTop) and not na(oteBot) and not (close >= oteBot and close <= oteTop) and (close[1] >= oteBot and close[1] <= oteTop)

alertcondition(enteredPremium, title="Entered Premium", message="Price entered premium zone")
alertcondition(enteredDiscount, title="Entered Discount", message="Price entered discount zone")
alertcondition(crossedEQ, title="Crossed Equilibrium", message="Price crossed equilibrium level")
alertcondition(enteredOTE, title="Entered OTE", message="Price entered directional OTE zone")
alertcondition(leftOTE, title="Left OTE", message="Price left directional OTE zone")
````
