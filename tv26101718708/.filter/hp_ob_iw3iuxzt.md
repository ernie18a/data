# HP OB

- url: https://www.tradingview.com/script/Iw3iUXZt-HP-OB/
- type: indicator
- pine_id: PUB;2dbfc0b601f04dc399ffb5ed78ae8018
- version: 1.0

## Description

HP orderblocks for picking up good zones to work from, testing is a must

## Source Code

````pine
//@version=6
indicator("Institutional 15m OBs (Auto-Clean)", overlay = true, max_boxes_count = 100)

// --- Groups ---
var string G_OB      = "15m Order Block Logic"
var string G_INST    = "Institutional Move Filters"
var string G_ALERTS  = "Alert Settings"
var string G_STYLE   = "Style"

// --- Inputs ---
string htfTimeframe   = input.timeframe("15", "OB Timeframe", group = G_OB, tooltip = "The timeframe to calculate 'Damage' (BOS + FVG).")
int lengthInput       = input.int(5, "Swing Lookback", minval = 2, group = G_OB)
int boxLimit          = input.int(10, "Max Active Boxes", minval = 1, maxval = 50, group = G_OB)

// Institutional Filters
float volMult         = input.float(1.2, "Volume Multiplier", minval = 1.0, group = G_INST, tooltip = "The candle breaking structure must have volume X times the average to be considered institutional.")
float bodyMult        = input.float(1.5, "Body Size Multiplier", minval = 1.0, group = G_INST, tooltip = "The candle breaking structure must have a body size X times the average body size.")

// Proximity Alerts
bool enableProxAlert  = input.bool(true, "Enable Proximity Alerts", group = G_ALERTS)
float alertThreshold = input.float(0.05, "Proximity Threshold (%)", minval = 0.0, step = 0.01, group = G_ALERTS)

color bullColorInput  = input.color(color.new(#089981, 80), "Bullish OB", group = G_STYLE, inline = "bull")
color bullBorderInput = input.color(#089981, "Border", group = G_STYLE, inline = "bull")
color bearColorInput  = input.color(color.new(#f23645, 80), "Bearish OB", group = G_STYLE, inline = "bear")
color bearBorderInput = input.color(#f23645, "Border", group = G_STYLE, inline = "bear")

// --- Types ---
type OrderBlock
    box   id
    float top
    float bottom
    bool  isBull
    bool  mitigated

// --- Global Variables ---
var bullOBs = array.new<OrderBlock>()
var bearOBs = array.new<OrderBlock>()

// --- Function to Calculate OBs on HTF ---
getHTFSignals() =>
    float ph = ta.pivothigh(high, lengthInput, lengthInput)
    float pl = ta.pivotlow(low, lengthInput, lengthInput)
    
    // Average Volume and Body Size for Institutional Filter
    float avgVol  = ta.sma(volume, 20)
    float bodySize = math.abs(close - open)
    float avgBody  = ta.sma(bodySize, 20)

    var float lastPH = na
    var float lastPL = na
    var int   lastPHTime = na
    var int   lastPLTime = na

    if not na(ph)
        lastPH := ph
        lastPHTime := time[lengthInput]
    if not na(pl)
        lastPL := pl
        lastPLTime := time[lengthInput]

    bool bullBOS = ta.crossover(close, lastPH)
    bool bearBOS = ta.crossunder(close, lastPL)
    
    // Check for Institutional Move (Damage)
    bool isInstitutional = volume > avgVol * volMult and bodySize > avgBody * bodyMult

    float obTop = na
    float obBot = na
    int obTime  = na
    int sigType = 0 

    if bullBOS and isInstitutional
        for i = 1 to 50
            if open[i] > close[i]
                // Mandatory FVG check for high-prob displacement
                hasFVG = false
                for j = 0 to 3
                    if low[j] > high[j+2]
                        hasFVG := true
                        break
                
                if hasFVG
                    obTop   := high[i]
                    obBot   := low[i]
                    obTime  := time[i]
                    sigType := 1
                    lastPH  := na
                break

    if bearBOS and isInstitutional
        for i = 1 to 50
            if open[i] < close[i]
                hasFVG = false
                for j = 0 to 3
                    if high[j] < low[j+2]
                        hasFVG := true
                        break
                
                if hasFVG
                    obTop   := high[i]
                    obBot   := low[i]
                    obTime  := time[i]
                    sigType := -1
                    lastPL  := na
                break
    
    [sigType, obTop, obBot, obTime]

// Fetch 15m (HTF) Data
[htfSig, htfTop, htfBot, htfTime] = request.security(syminfo.tickerid, htfTimeframe, getHTFSignals(), lookahead = barmerge.lookahead_on)

// --- Handle Signal Detection on LTF ---
var int lastProcessedTime = 0

if not na(htfSig) and htfTime != lastProcessedTime
    if htfSig == 1 
        box b = box.new(htfTime, htfTop, time, htfBot, xloc = xloc.bar_time, bgcolor = bullColorInput, border_color = bullBorderInput, extend = extend.right)
        array.push(bullOBs, OrderBlock.new(b, htfTop, htfBot, true, false))
    else if htfSig == -1 
        box b = box.new(htfTime, htfTop, time, htfBot, xloc = xloc.bar_time, bgcolor = bearColorInput, border_color = bearBorderInput, extend = extend.right)
        array.push(bearOBs, OrderBlock.new(b, htfTop, htfBot, false, false))
    
    lastProcessedTime := htfTime

// --- Mitigation & Deletion Logic ---
manageOBs(array<OrderBlock> obArray, bool isBull) =>
    bool anyProx = false
    if array.size(obArray) > 0
        for i = array.size(obArray) - 1 to 0
            OrderBlock ob = array.get(obArray, i)
            
            // Check for mitigation (Played Through)
            bool mitigated = isBull ? low < ob.bottom : high > ob.top
            
            if mitigated
                // DELETE box immediately once played through to keep chart clean
                box.delete(ob.id)
                array.remove(obArray, i)
            else
                box.set_right(ob.id, time)
                
                if enableProxAlert
                    float dist = isBull ? (low - ob.top) : (ob.bottom - high)
                    float thresholdValue = close * (alertThreshold / 100)
                    if dist > 0 and dist <= thresholdValue
                        anyProx := true

            // Cleanup limit
            if array.size(obArray) > boxLimit and i < array.size(obArray) - boxLimit
                box.delete(ob.id)
                array.remove(obArray, i)
    anyProx

bool bullProx = manageOBs(bullOBs, true)
bool bearProx = manageOBs(bearOBs, false)

// --- Alerts ---
if bullProx or bearProx
    alert("Institutional OB Proximity Alert!", alert.freq_once_per_bar)

// Visual BOS feedback (HTF)
plotshape(htfSig != 0 and htfTime != htfTime[1], "HTF Institutional Break", shape.circle, location.top, color.new(chart.fg_color, 50), size = size.tiny)
````
