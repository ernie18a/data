# SMC Ultimate Shift 

- url: https://www.tradingview.com/script/aWPboaEH-smc-ultimate-shift/
- type: indicator
- pine_id: PUB;aca421cc8dc74a0797f2dbe8cc5170d6
- version: 1.0

## Description

Key Functionality
Swing Identification: It uses a 3-bar swing pattern to detect potential turning points in market structure.

Structural Validation (Inducement): To reduce false signals, the indicator requires a "sweep" of structural liquidity (the most recent high or low) before it accepts a shift as valid.

Global Invalidation Logic: It includes a user-defined price level for invalidation. If the price breaches this level and stays there for more than one hour, the indicator automatically disables itself, protecting you from trading in a broken market context.

Visual States:

Pending Shift (Dashed line): Indicates that the necessary structural conditions are met, but the final confirmation (a body break) has not yet occurred.

Confirmed Shift (Solid line): Signals that the market has successfully broken the level, confirming the structural shift.

## Source Code

````pine
//@version=6
indicator("SMC Ultimate Shift [Global Invalidation]", overlay=true, shorttitle="SMC Shift")

// ==========================================
// --- CORE SETTINGS ---
// ==========================================
var string G_MAIN = "Context"
directionStr = input.string("Long", title="Direction:", options=["Long", "Short"], group=G_MAIN)
isLong = directionStr == "Long"

var string G_VIS = "Visibility Settings"
useTfFilter = input.bool(true, title="Clarify shift TF", group=G_VIS)
tfShift     = input.timeframe("3",  title="Shift Timeframe", tooltip="Shift logic and lines will only be active on this specific timeframe.", group=G_VIS)

var string G_INV = "Invalidation Level & Timer"
useInv      = input.bool(false, title="Enable Invalidation Level", group=G_INV)
invPrice    = input.float(0.0, title="Invalidation Price", tooltip="Long: Price must stay ABOVE this level.\nShort: Price must stay BELOW this level.", group=G_INV)

// Invalidation Line Styling
invColor    = input.color(color.new(color.gray, 50), title="Line Color", group=G_INV, inline="i1")
invWidth    = input.int(1, title="Width", minval=1, maxval=5, group=G_INV, inline="i1")
invStyleStr = input.string("Dotted", title="Style", options=["Solid", "Dashed", "Dotted"], group=G_INV)

// ==========================================
// --- SHIFT STYLING ---
// ==========================================
var string G_WAIT = "Pending Shift Styling"
waitColor    = input.color(color.red, title="Color", group=G_WAIT, inline="w1")
waitWidth    = input.int(2, title="Width", minval=1, maxval=5, group=G_WAIT, inline="w1")
waitStyleStr = input.string("Dashed", title="Style", options=["Solid", "Dashed", "Dotted"], group=G_WAIT)

var string G_CONF = "Confirmed Shift Styling"
confColor    = input.color(color.green, title="Color", group=G_CONF, inline="c1")
confWidth    = input.int(2, title="Width", minval=1, maxval=5, group=G_CONF, inline="c1")
confStyleStr = input.string("Solid", title="Style", options=["Solid", "Dashed", "Dotted"], group=G_CONF)

// Helper function to parse line styles
getLineStyle(styleStr) =>
    switch styleStr
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid 

waitStyle = getLineStyle(waitStyleStr)
confStyle = getLineStyle(confStyleStr)
invStyle  = getLineStyle(invStyleStr)

// ==========================================
// --- VISIBILITY FILTERS ---
// ==========================================
// Restrict Shift calculations to the selected timeframe
bool isVisibleShift = not useTfFilter or (timeframe.period == tfShift)

// ==========================================
// --- INVALIDATION & TIMER LOGIC ---
// ==========================================
var int ONE_HOUR_MS = 3600000 
var int exitTime = na
var bool isZoneActive = true

bool validInv = useInv and invPrice != 0

if validInv
    // Check if price is on the correct side of the invalidation level
    bool isPriceValid = isLong ? (close >= invPrice) : (close <= invPrice)

    if isPriceValid
        isZoneActive := true
        exitTime := na // Reset grace period timer
    else
        if na(exitTime)
            exitTime := time // Start timer on breach
        
        if (time - exitTime) >= ONE_HOUR_MS
            isZoneActive := false // Hard invalidation after 1 hour
else
    isZoneActive := true

// Draw Global Invalidation Line (Visible everywhere if enabled)
var line lineInv = na

if validInv and barstate.islast
    line.delete(lineInv)
    lineInv := line.new(bar_index - 100, invPrice, bar_index + 10, invPrice, color=invColor, width=invWidth, style=invStyle, extend=extend.both)

// ==========================================
// --- CORE ALGORITHM (SMART MONEY SHIFT) ---
// ==========================================

// 3-Bar Swing Pattern
isSwingHigh = high[1] > high[2] and high[1] > high[0]
isSwingLow  = low[1] < low[2] and low[1] < low[0]
isSwing = isLong ? isSwingHigh : isSwingLow

var float extremumSinceValid = na
var bool  requireStructBreak = false

var float pot_shiftPrice     = na
var float pot_confirmPrice   = na
var float pot_targetExtremum = na
var int   pot_barIndex       = na
var bool  hasPotential       = false
var bool  middleBroken       = false
var bool  structBroken       = false

var line  activeShiftLine    = na
var float valid_shiftLevel   = na
var bool  waitingForShift    = false

// --- HARD RESET: Clear memory when zone reactivates ---
if isZoneActive and not isZoneActive[1]
    requireStructBreak := false
    extremumSinceValid := na
    hasPotential       := false
    waitingForShift    := false
    if not na(activeShiftLine)
        line.delete(activeShiftLine)
        activeShiftLine := na

// 1. Track Structural Liquidity (Inducement)
if isZoneActive and isVisibleShift
    if isLong
        extremumSinceValid := na(extremumSinceValid) ? low : math.min(extremumSinceValid, low)
    else
        extremumSinceValid := na(extremumSinceValid) ? high : math.max(extremumSinceValid, high)

// 2. Erase pending setups if timer kills the zone
if not isZoneActive and waitingForShift and isVisibleShift
    line.delete(activeShiftLine)
    waitingForShift := false
    hasPotential := false

// 3. Register Potential Swing
if isSwing and isZoneActive and isVisibleShift
    pot_shiftPrice     := isLong ? high[1] : low[1]
    pot_confirmPrice   := isLong ? low[1] : high[1]
    pot_targetExtremum := extremumSinceValid
    pot_barIndex       := bar_index - 1
    hasPotential       := true
    middleBroken       := false
    structBroken       := false

// 4. Dual Validation Logic
if hasPotential and isZoneActive and isVisibleShift
    bool isCanceled = isLong ? (high > pot_shiftPrice) : (low < pot_shiftPrice)
    
    if isCanceled
        hasPotential := false // Level breached before validation
    else
        // Condition 1: Body break of the middle bar
        if isLong ? (close < pot_confirmPrice) : (close > pot_confirmPrice)
            middleBroken := true
        
        // Condition 2: Structural extreme sweep (Inducement)
        bool isStructBroken = isLong ? (low <= pot_targetExtremum) : (high >= pot_targetExtremum)
        if isStructBroken or not requireStructBreak
            structBroken := true
        
        // Validation Success -> Draw Pending Line
        if middleBroken and structBroken
            valid_shiftLevel := pot_shiftPrice
            waitingForShift  := true
            hasPotential     := false
            
            extremumSinceValid := isLong ? low : high
            requireStructBreak := true 
            
            line.delete(activeShiftLine)
            activeShiftLine := line.new(x1=pot_barIndex, y1=valid_shiftLevel, x2=bar_index, y2=valid_shiftLevel, color=waitColor, width=waitWidth, style=waitStyle)

// 5. Extend Pending Line dynamically
if not na(activeShiftLine) and isZoneActive and waitingForShift and isVisibleShift
    line.set_x2(activeShiftLine, bar_index)

// 6. FINAL SHIFT (Market Shift)
if waitingForShift and isZoneActive and isVisibleShift
    bool isShift = isLong ? (close > valid_shiftLevel) : (close < valid_shiftLevel)
    
    // Confirmed body break
    if isShift
        waitingForShift := false 
        
        // Upgrade line visuals to Confirmed
        line.set_color(activeShiftLine, confColor)
        line.set_width(activeShiftLine, confWidth)
        line.set_style(activeShiftLine, confStyle)
        
        // Reset cycle for the next structural move
        requireStructBreak := false
        extremumSinceValid := isLong ? low : high
````
