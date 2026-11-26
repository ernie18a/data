# Weekly POC Lines

- url: https://www.tradingview.com/script/Y1OzK6gq-Weekly-POC-Lines/
- type: indicator
- pine_id: PUB;2c648c75b14249d7bae0a7fafc00f355
- version: 2.0

## Description

This is Weekly POC indicator. It shows POC levels from previous weeks.

## Source Code

````pine
// This is Modry indicator
//@version=6
indicator("Weekly POC Lines", "Weekly POC", overlay = true, max_lines_count = 100, max_labels_count = 100)

//---------------------------------------------------------------------------------------------------------------------}
// Inputs
//---------------------------------------------------------------------------------------------------------------------{
string GRP_CORE    = 'Settings'
bool autoPrecInput = input.bool(true, "Auto Intrabar Precision", group = GRP_CORE, tooltip = "Automatically adjust lower timeframe based on chart timeframe.")
string manualPrecInput = input.timeframe("5", "Manual Precision", group = GRP_CORE, tooltip = "Used only when Auto Precision is disabled.")
int maxBarsInput   = input.int(500, "Max Bars Back", minval = 100, maxval = 5000, group = GRP_CORE)
int weeksToShow    = input.int(12, "Weeks to Show", minval = 1, maxval = 52, group = GRP_CORE, tooltip = "Number of past weeks to display POC lines.")

string GRP_STYLE   = 'Style'
color bullPocInput = input.color(#089981, "POC Color (Bull/Bear)", group = GRP_STYLE, inline = 'pocCol')
color bearPocInput = input.color(#f23645, "", group = GRP_STYLE, inline = 'pocCol')
int lineWidthInput = input.int(2, "Line Width", minval = 1, maxval = 5, group = GRP_STYLE)
string labelSizeInput = input.string("small", "Label Text Size", options = ["tiny", "small", "normal", "large", "huge"], group = GRP_STYLE, tooltip = "Font size for volume and week info")
bool extendInput   = input.bool(true, "Extend to Current Bar", group = GRP_STYLE)

//---------------------------------------------------------------------------------------------------------------------}
// Functions
//---------------------------------------------------------------------------------------------------------------------{
getLabelSize(string sizeStr) =>
    sizeStr == "tiny" ? size.tiny : sizeStr == "small" ? size.small : sizeStr == "normal" ? size.normal : sizeStr == "large" ? size.large : size.huge

getOptimalPrecision(string chartTf) =>
    int tfMinutes = timeframe.in_seconds(chartTf) / 60
    string precision = "5"
    
    if tfMinutes <= 1
        precision := "1"
    else if tfMinutes <= 5
        precision := "1"
    else if tfMinutes <= 15
        precision := "5"
    else if tfMinutes <= 30
        precision := "15"
    else if tfMinutes <= 60
        precision := "15"
    else if tfMinutes <= 240
        precision := "60"
    else if tfMinutes < 1440
        precision := "240"
    else
        precision := "D"
    
    precision

//---------------------------------------------------------------------------------------------------------------------}
// Types
//---------------------------------------------------------------------------------------------------------------------{
type BarData
    float o
    float h
    float l
    float c
    float v

type POCLevel
    int   startBar
    int   startTime
    float pocPrice
    float peakVolume
    float peakBullVol
    float peakBearVol
    line  pocLine  = na
    label pocLabel = na

//---------------------------------------------------------------------------------------------------------------------}
// Variables
//---------------------------------------------------------------------------------------------------------------------{
var array<POCLevel> pocLevels = array.new<POCLevel>()
var POCLevel activePOC = na
var int lastStart = bar_index
var sessionLtfData = array.new<BarData>()

string precInput = autoPrecInput ? getOptimalPrecision(timeframe.period) : manualPrecInput

[ltfO, ltfH, ltfL, ltfC, ltfV] = request.security_lower_tf(syminfo.tickerid, precInput, [open, high, low, close, volume])

//---------------------------------------------------------------------------------------------------------------------}
// Logic
//---------------------------------------------------------------------------------------------------------------------{
if bar_index >= bar_index - maxBarsInput
    bool isNewSession = ta.change(time("W")) != 0

    if isNewSession or barstate.isfirst
        if not na(activePOC)
            pocLevels.push(activePOC)
            
            // Limit to last X weeks
            while pocLevels.size() > weeksToShow
                POCLevel old = pocLevels.shift()
                if not na(old)
                    if not na(old.pocLine)
                        old.pocLine.delete()
                    if not na(old.pocLabel)
                        old.pocLabel.delete()
        
        lastStart := bar_index
        sessionLtfData.clear()
        
        activePOC := POCLevel.new(
             startBar    = bar_index, 
             startTime   = time,
             pocPrice    = na,
             peakVolume  = 0.0,
             peakBullVol = 0.0,
             peakBearVol = 0.0,
             pocLine     = line.new(na, na, na, na, style = line.style_solid),
             pocLabel    = label.new(na, na, "", style = label.style_label_left, color = #00000000, size = getLabelSize(labelSizeInput))
             )

    bool hasLtfData = not na(ltfH) and ltfH.size() > 0
    
    if hasLtfData
        for i = 0 to ltfH.size() - 1
            sessionLtfData.push(BarData.new(ltfO.get(i), ltfH.get(i), ltfL.get(i), ltfC.get(i), ltfV.get(i)))
    else
        if not na(volume)
            sessionLtfData.push(BarData.new(open, high, low, close, volume))

    if not na(activePOC) and sessionLtfData.size() > 0
        float sHigh = na
        float sLow  = na
        for i = 0 to sessionLtfData.size() - 1
            BarData d = sessionLtfData.get(i)
            if not na(d.h) and not na(d.l)
                sHigh := na(sHigh) ? d.h : math.max(sHigh, d.h)
                sLow  := na(sLow) ? d.l : math.min(sLow, d.l)
        
        if not na(sHigh) and not na(sLow) and sHigh > sLow
            int numRows = 50
            float rowSize = (sHigh - sLow) / numRows
            
            array<float> rowVolumes = array.new_float(numRows, 0.0)
            array<float> rowBullVol = array.new_float(numRows, 0.0)
            array<float> rowBearVol = array.new_float(numRows, 0.0)
            
            float maxVol = 0.0
            int peakIdx  = 0
            
            for i = 0 to sessionLtfData.size() - 1
                BarData d = sessionLtfData.get(i)
                if na(d.h) or na(d.l) or na(d.v)
                    continue
                
                bool isBull = d.c >= d.o
                int idxH = int(math.min(numRows - 1, math.max(0, math.floor((d.h - sLow) / rowSize))))
                int idxL = int(math.min(numRows - 1, math.max(0, math.floor((d.l - sLow) / rowSize))))
                int span = idxH - idxL + 1
                
                for j = idxL to idxH
                    float vSplit = d.v / span
                    float total  = rowVolumes.get(j) + vSplit
                    rowVolumes.set(j, total)
                    
                    if isBull
                        rowBullVol.set(j, rowBullVol.get(j) + vSplit)
                    else
                        rowBearVol.set(j, rowBearVol.get(j) + vSplit)
                    
                    if total > maxVol
                        maxVol  := total
                        peakIdx := j
            
            float pocPrice = sLow + (peakIdx * rowSize) + (rowSize / 2)
            
            activePOC.pocPrice    := pocPrice
            activePOC.peakVolume  := maxVol
            activePOC.peakBullVol := rowBullVol.get(peakIdx)
            activePOC.peakBearVol := rowBearVol.get(peakIdx)

            color pocCol = pocPrice < close ? bullPocInput : bearPocInput
            
            activePOC.pocLine.set_xy1(lastStart, pocPrice)
            activePOC.pocLine.set_xy2(bar_index, pocPrice)
            activePOC.pocLine.set_color(pocCol)
            activePOC.pocLine.set_width(lineWidthInput)

            float bPerc = activePOC.peakVolume > 0 ? (activePOC.peakBullVol / activePOC.peakVolume) * 100 : 0
            float sPerc = activePOC.peakVolume > 0 ? (activePOC.peakBearVol / activePOC.peakVolume) * 100 : 0
            string domTxt = bPerc >= sPerc ? str.format("{0}% B", math.round(bPerc)) : str.format("{0}% S", math.round(sPerc))
            
            int weeksAgo = math.floor((time - activePOC.startTime) / 604800000)
            string volTxt = str.format("Vol: {0} ({1})", str.tostring(activePOC.peakVolume, format.volume), domTxt)
            string labText = weeksAgo == 0 ? str.format("This Week | {0}", volTxt) : str.format("{0}W | {1}", weeksAgo, volTxt)
            
            activePOC.pocLabel.set_xy(bar_index, pocPrice)
            activePOC.pocLabel.set_text(labText)
            activePOC.pocLabel.set_textcolor(pocCol)

    // Update historical POC lines
    if pocLevels.size() > 0
        for i = 0 to pocLevels.size() - 1
            POCLevel poc = pocLevels.get(i)
            if not na(poc.pocLine) and not na(poc.pocPrice)
                color pCol = poc.pocPrice < close ? bullPocInput : bearPocInput
                
                poc.pocLine.set_color(pCol)
                poc.pocLine.set_width(lineWidthInput)
                poc.pocLine.set_y1(poc.pocPrice)
                poc.pocLine.set_y2(poc.pocPrice)
                
                int endX = bar_index
                if extendInput
                    poc.pocLine.set_x2(bar_index)
                else
                    endX := (i < pocLevels.size() - 1) ? pocLevels.get(i+1).startBar : bar_index
                    poc.pocLine.set_x2(endX)
                
                if not na(poc.pocLabel)
                    float hbPerc = poc.peakVolume > 0 ? (poc.peakBullVol / poc.peakVolume) * 100 : 0
                    float hsPerc = poc.peakVolume > 0 ? (poc.peakBearVol / poc.peakVolume) * 100 : 0
                    string hDomTxt = hbPerc >= hsPerc ? str.format("{0}% B", math.round(hbPerc)) : str.format("{0}% S", math.round(hsPerc))
                    
                    int wAgo = math.floor((time - poc.startTime) / 604800000)
                    string hVolTxt = str.format("Vol: {0} ({1})", str.tostring(poc.peakVolume, format.volume), hDomTxt)
                    string t = wAgo == 0 ? str.format("This Week | {0}", hVolTxt) : str.format("{0}W | {1}", wAgo, hVolTxt)
                    
                    poc.pocLabel.set_xy(endX, poc.pocPrice)
                    poc.pocLabel.set_text(t)
                    poc.pocLabel.set_textcolor(pCol)

//---------------------------------------------------------------------------------------------------------------------}
````
