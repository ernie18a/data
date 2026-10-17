# Structural Leg Profiler [LuxAlgo]

- url: https://www.tradingview.com/script/tYFQSk49-Structural-Leg-Profiler-LuxAlgo/
- type: indicator
- pine_id: PUB;8412fdf52fca4161b3c852e2fe4098e4
- version: 1.0

## Description

The [b]Structural Leg Profiler[/b] indicator is a comprehensive structural analysis tool that dynamically maps lower-timeframe volume distributions onto major market swings to reveal where the most significant trading activity occurs within a trend.

🔶 [b]USAGE[/b]

The tool is designed to bridge the gap between traditional price action swings and order flow analysis. By using an ATR-based swing detection mechanism, the indicator automatically identifies structural "legs" (upward or downward price movements) and generates a detailed volume distribution profile for each one.

Users can leverage this tool to identify high-interest zones (Point of Control) and determine whether a move is supported by aggressive buying or selling volume through the Delta coloring mode.

🔹 [b]Interpreting the Profiles[/b]
Each structural leg displays a volume profile across its duration, constructed from lower-timeframe data to ensure precision.

[list][*][b]Volume Gradient Mode:[/b] Highlights nodes based on total activity. The colors transition from low-volume areas to high-volume nodes, with the Point of Control (POC) being the most prominent.[*][b]Delta Mode:[/b] Colors the profile blocks based on the net difference between buying and selling volume. Bright green indicates heavy aggressive buying, while bright red indicates heavy aggressive selling.[*][b]Summary Labels:[/b] Each leg includes a summary label showing the Total Leg Volume, the Net Delta, and the exact POC price.[/list]

🔹 [b]Volume Anomalies[/b]
The script automatically detects and highlights candles with unusual volume spikes using dynamic "bubbles." This helps in identifying potential exhaustion points or strong breakout momentum.

[list][*][b]Standard Bubbles:[/b] Indicate volume that is significantly above the 20-period average.[*][b]Large Bubbles with Values:[/b] Indicate extreme volume spikes, with the exact volume printed inside the bubble for immediate context.[/list]

🔶 [b]DETAILS[/b]

🔹 [b]Untested POC Extensions[/b]
A core feature of this script is the "Naked POC" logic. When a structural leg is completed, its Point of Control is projected forward as a dashed line. These levels often act as high-probability support or resistance zones. The line continues to extend until price eventually "tests" or crosses it, at which point it automatically terminates to keep the chart clean.

🔹 [b]Lower Timeframe Precision[/b]
Unlike standard profiles that use only chart-resolution data, this script utilizes

[pine]request.security_lower_tf[/pine]

to pull granular data. This provides a much more accurate view of how volume was distributed within each leg compared to simple OHLC-based approximations.

🔶 [b]SETTINGS[/b]

🔹 [b]Swing Detection[/b]

[list][*][b]ATR Period:[/b] The lookback period used to calculate volatility for swing detection.[*][b]Swing Multiplier (ATR):[/b] Controls the sensitivity of the legs. Higher values capture major trends; lower values capture micro-swings.[/list]

🔹 [b]Profile Settings[/b]

[list][*][b]Max Profile Boxes:[/b] Defines the vertical resolution and maximum number of rows in the profiles.[*][b]Profile Alignment:[/b] Determines where the volume bars are anchored (Left, Right, or Center) within the leg area.[*][b]Show Volume Value:[/b] Toggles the visibility of numeric volume values inside the profile boxes.[*][b]Extend Untested POCs:[/b] Enables the forward projection of POC lines until they are mitigated by price.[/list]

🔹 [b]Volume Anomalies[/b]

[list][*][b]Show Volume Bubbles:[/b] Toggles the volume anomaly visualization.[*][b]Spike Threshold:[/b] The multiplier relative to the 20-period average volume that triggers an anomaly bubble.[/list]

🔹 [b]Style & Colors[/b]

[list][*][b]Box Color Mode:[/b] Choose between "Volume Gradient" (Total Volume focus) or "Delta" (Buy vs. Sell focus).[*][b]Up/Down Leg Colors:[/b] Customizable color gradients for both bullish and bearish structural legs.[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Structural Leg Profiler [LuxAlgo]", "LuxAlgo - Leg Profiler", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// Inputs
//---------------------------------------------------------------------------------------------------------------------{
string GRP_SWING   = "Swing Detection"
int    atrPeriod   = input.int(5, "ATR Period", group=GRP_SWING)
float  swingMult   = input.float(2.5, "Swing Multiplier (ATR)", step=0.1, group=GRP_SWING, tooltip="Higher values create larger structural legs. Lower values capture micro-swings.")

string GRP_PROFILE = "Profile Settings"
int    maxBoxes    = input.int(50, "Max Profile Boxes", minval=10, maxval=150, group=GRP_PROFILE)
string alignMode   = input.string("Left", "Profile Alignment", options=["Left", "Right", "Center"], group=GRP_PROFILE)
bool   showBoxVol  = input.bool(true, "Show Volume Value Inside Boxes", group=GRP_PROFILE)
bool   extendPoc   = input.bool(true, "Extend Untested POCs", group=GRP_PROFILE, tooltip="Extends the Point of Control line forward until price touches and tests it.")

string GRP_BUBBLES = "Volume Anomalies"
bool   showBubbles = input.bool(true, "Show Volume Bubbles", group=GRP_BUBBLES)
float  bubbleMult  = input.float(2.0, "Spike Threshold (x SMA)", step=0.1, group=GRP_BUBBLES, tooltip="Highlights candles where volume is X times greater than the 20-period average.")

string GRP_COLORS  = "Style & Colors"
string colorMode   = input.string("Volume Gradient", "Box Color Mode", options=["Volume Gradient", "Delta (Buy vs Sell)"], group=GRP_COLORS)

color  upStartC    = input.color(color.new(#01579B, 0), "Up Leg (Low Vol)", group=GRP_COLORS, inline="up")
color  upMidC      = input.color(color.new(#2962FF, 0), "Up Leg (Mid Vol)", group=GRP_COLORS, inline="up")
color  upEndC      = input.color(color.new(#00E5FF, 0), "Up Leg (High Vol)", group=GRP_COLORS, inline="up")

color  dnStartC    = input.color(color.new(#311B92, 0), "Down Leg (Low Vol)", group=GRP_COLORS, inline="dn")
color  dnMidC      = input.color(color.new(#C51162, 0), "Down Leg (Mid Vol)", group=GRP_COLORS, inline="dn")
color  dnEndC      = input.color(color.new(#FF5252, 0), "Down Leg (High Vol)", group=GRP_COLORS, inline="dn")

//---------------------------------------------------------------------------------------------------------------------}
// Types
//---------------------------------------------------------------------------------------------------------------------{
type LTFBar
    int chartBar
    float h
    float l
    float v
    float buyV
    float sellV

type CandleProfile
    float profileHigh
    float profileLow
    int   numBoxes
    float boxHeight
    array<float> volumeDistribution
    array<float> deltaDistribution
    float maxVolumeInProfile
    int   maxVolumeIndex
    float pocPrice

type UntestedPOC
    line  pocLine
    float price
    bool  isBull
    int   endBar

//---------------------------------------------------------------------------------------------------------------------}
// State Variables
//---------------------------------------------------------------------------------------------------------------------{
var array<LTFBar>      ltfHistory   = array.new<LTFBar>()
var array<UntestedPOC> untestedPocs = array.new<UntestedPOC>()

var int   zzDir          = 1
var float zzHigh         = high
var int   zzHighBar      = bar_index
var float zzLow          = low
var int   zzLowBar       = bar_index
var int   lastPivotBar   = bar_index
var float lastPivotPrice = close

//---------------------------------------------------------------------------------------------------------------------}
// Methods / Functions
//---------------------------------------------------------------------------------------------------------------------{
f_buildVolumeBar(int filledBlocks, int totalBlocks) =>
    string result = ""
    for i = 1 to totalBlocks
        result += i <= filledBlocks ? "█" : "░"
    result

f_createProfile(float legHigh, float legLow, float targetBoxHeight, array<LTFBar> legBars) =>
    float barRange = legHigh - legLow
    int numBoxes = math.max(1, int(math.round(barRange / targetBoxHeight)))
    float adjustedBoxHeight = barRange / numBoxes
    array<float> volDist = array.new_float(numBoxes, 0.0)
    array<float> deltaDist = array.new_float(numBoxes, 0.0)
    
    for i = 0 to legBars.size() - 1
        LTFBar b = legBars.get(i)
        float ltfBarRange = math.max(b.h - b.l, syminfo.mintick)
        
        for boxIndex = 0 to numBoxes - 1
            float boxBottom = legLow + (boxIndex * adjustedBoxHeight)
            float boxTop = boxBottom + adjustedBoxHeight
            float overlapHeight = math.max(0, math.min(boxTop, b.h) - math.max(boxBottom, b.l))
            
            if overlapHeight > 0
                float overlapRatio = overlapHeight / ltfBarRange
                float volContrib = b.v * overlapRatio
                float buyContrib = b.buyV * overlapRatio
                float sellContrib = b.sellV * overlapRatio
                
                volDist.set(boxIndex, volDist.get(boxIndex) + volContrib)
                deltaDist.set(boxIndex, deltaDist.get(boxIndex) + (buyContrib - sellContrib))
                
    float maxVolume = volDist.max()
    int maxVolIdx = volDist.indexof(maxVolume)
    float pocPrice = legLow + (maxVolIdx * adjustedBoxHeight) + (adjustedBoxHeight / 2)
    
    CandleProfile.new(legHigh, legLow, numBoxes, adjustedBoxHeight, volDist, deltaDist, maxVolume, maxVolIdx, pocPrice)

method draw(CandleProfile this, int startBar, int endBar, bool isUpLeg, float totalBuyVol, float totalSellVol) =>
    int bLeft = startBar
    int bRight = math.max(startBar + 1, endBar)
    int totalBlocks = math.max(5, math.min(30, int(15 * ((bRight - bLeft) / 50.0))))

    color startC = isUpLeg ? upStartC : dnStartC
    color midC   = isUpLeg ? upMidC : dnMidC
    color endC   = isUpLeg ? upEndC : dnEndC
    
    string parsedAlign = alignMode == "Left" ? text.align_left : alignMode == "Right" ? text.align_right : text.align_center
    
    for i = 0 to this.numBoxes - 1
        float boxBottom = this.profileLow + (i * this.boxHeight)
        float boxTop = boxBottom + this.boxHeight
        float currentBoxVolume = this.volumeDistribution.get(i)
        float currentBoxDelta = this.deltaDistribution.get(i)
        
        if currentBoxVolume > 0
            int filledBlocks = this.maxVolumeInProfile > 0 ? int(math.round((currentBoxVolume / this.maxVolumeInProfile) * totalBlocks)) : 0
            string boxText = f_buildVolumeBar(filledBlocks, totalBlocks)
            if showBoxVol
                boxText += " " + str.tostring(currentBoxVolume, format.volume)
            
            color textColor = na
            
            if colorMode == "Delta (Buy vs Sell)"
                if currentBoxDelta > 0
                    textColor := color.from_gradient(currentBoxDelta, 0, this.maxVolumeInProfile, color.new(color.green, 60), color.new(color.green, 0))
                else if currentBoxDelta < 0
                    textColor := color.from_gradient(math.abs(currentBoxDelta), 0, this.maxVolumeInProfile, color.new(color.red, 60), color.new(color.red, 0))
                else
                    textColor := color.gray
            else
                if i < this.maxVolumeIndex
                    textColor := color.from_gradient(i, 0, this.maxVolumeIndex, startC, midC)
                else if i > this.maxVolumeIndex
                    textColor := color.from_gradient(i, this.maxVolumeIndex, this.numBoxes - 1, midC, endC)
                else
                    textColor := midC
                
            color bgC = color.new(textColor, 90)
            box.new(left=bLeft, top=boxTop, right=bRight, bottom=boxBottom, border_color=color(na), bgcolor=bgC, text=boxText, text_size=size.small, text_color=textColor, text_halign=parsedAlign, text_valign=text.align_center, text_wrap=text.wrap_none, text_font_family=font.family_monospace)
            
    line pocL = line.new(startBar, this.pocPrice, endBar, this.pocPrice, color=color.new(endC, 0), style=line.style_dashed, width=2)
    if extendPoc
        untestedPocs.push(UntestedPOC.new(pocL, this.pocPrice, isUpLeg, endBar))
        
    float delta = totalBuyVol - totalSellVol
    color deltaColor = delta > 0 ? color.green : color.red
    string deltaSign = delta > 0 ? "+" : ""
    
    string summaryText = "Leg Vol: " + str.tostring(totalBuyVol + totalSellVol, format.volume) + "\n" +
                         "Delta: " + deltaSign + str.tostring(delta, format.volume) + "\n" +
                         "POC: " + str.tostring(this.pocPrice, format.mintick)
                         
    int midBar = int(math.round((startBar + endBar) / 2))
    float summaryY = isUpLeg ? this.profileHigh : this.profileLow
    label.new(midBar, summaryY, text=summaryText, color=color.new(chart.bg_color, 20), style=isUpLeg ? label.style_label_down : label.style_label_up, textcolor=deltaColor, size=size.tiny)

f_processLeg(int startBar, int endBar, float startPrice, float endPrice, bool isUpLeg, array<LTFBar> history, float baseBoxHeight) =>
    line.new(startBar, startPrice, endBar, endPrice, color=color.new(color.gray, 50), width=2, style=line.style_dotted)
    
    array<LTFBar> legBars = array.new<LTFBar>()
    float totalBuy = 0.0
    float totalSell = 0.0
    float maxH = -1.0
    float minL = 99999999.0
    
    for i = 0 to history.size() - 1
        LTFBar b = history.get(i)
        if b.chartBar >= startBar and b.chartBar <= endBar
            legBars.push(b)
            totalBuy += b.buyV
            totalSell += b.sellV
            maxH := math.max(maxH, b.h)
            minL := math.min(minL, b.l)
            
    if legBars.size() > 0
        float groupRange = maxH - minL
        float targetBoxHeight = (groupRange / baseBoxHeight) > maxBoxes ? groupRange / maxBoxes : baseBoxHeight
        
        CandleProfile profile = f_createProfile(maxH, minL, targetBoxHeight, legBars)
        profile.draw(startBar, endBar, isUpLeg, totalBuy, totalSell)
        
    array<LTFBar> newHistory = array.new<LTFBar>()
    for i = 0 to history.size() - 1
        if history.get(i).chartBar >= endBar
            newHistory.push(history.get(i))
    newHistory

//---------------------------------------------------------------------------------------------------------------------}
// Data Retrieval & Accumulation
//---------------------------------------------------------------------------------------------------------------------{
[ltfOpens, ltfHighs, ltfLows, ltfCloses, ltfVolumes] = request.security_lower_tf(syminfo.tickerid, "1", [open, high, low, close, volume])

if ltfHighs.size() > 0
    for i = 0 to ltfHighs.size() - 1
        float h = ltfHighs.get(i)
        float l = ltfLows.get(i)
        float c = ltfCloses.get(i)
        float v = ltfVolumes.get(i)
        
        float rng = math.max(h - l, syminfo.mintick)
        float buyVol = v * (c - l) / rng
        float sellVol = v * (h - c) / rng
        
        ltfHistory.push(LTFBar.new(bar_index, h, l, v, buyVol, sellVol))
else
    float rng = math.max(high - low, syminfo.mintick)
    float buyVol = volume * (close - low) / rng
    float sellVol = volume * (high - close) / rng
    ltfHistory.push(LTFBar.new(bar_index, high, low, volume, buyVol, sellVol))

if ltfHistory.size() > 90000
    ltfHistory.shift()

//---------------------------------------------------------------------------------------------------------------------}
// Swing Logic & Profiling
//---------------------------------------------------------------------------------------------------------------------{
float globalAtr = ta.atr(atrPeriod)
float globalAtr14 = ta.atr(14)
float revAmount = globalAtr * swingMult

bool isSwingHigh = false
bool isSwingLow = false

if zzDir == 1
    if high > zzHigh
        zzHigh := high
        zzHighBar := bar_index
    if low < zzHigh - revAmount
        zzDir := -1
        zzLow := low
        zzLowBar := bar_index
        isSwingHigh := true
else
    if low < zzLow
        zzLow := low
        zzLowBar := bar_index
    if high > zzLow + revAmount
        zzDir := 1
        zzHigh := high
        zzHighBar := bar_index
        isSwingLow := true

if isSwingHigh
    float boxHeightLimit = globalAtr14 / 10
    ltfHistory := f_processLeg(lastPivotBar, zzHighBar, lastPivotPrice, zzHigh, true, ltfHistory, boxHeightLimit)
    lastPivotBar := zzHighBar
    lastPivotPrice := zzHigh

if isSwingLow
    float boxHeightLimit = globalAtr14 / 10
    ltfHistory := f_processLeg(lastPivotBar, zzLowBar, lastPivotPrice, zzLow, false, ltfHistory, boxHeightLimit)
    lastPivotBar := zzLowBar
    lastPivotPrice := zzLow

//---------------------------------------------------------------------------------------------------------------------}
// Untested POC Extensions
//---------------------------------------------------------------------------------------------------------------------{
if untestedPocs.size() > 0
    for i = untestedPocs.size() - 1 to 0
        UntestedPOC p = untestedPocs.get(i)
        bool isTested = high >= p.price and low <= p.price
        
        if isTested
            p.pocLine.set_x2(bar_index)
            untestedPocs.remove(i)
        else
            p.pocLine.set_x2(bar_index)
            
    if untestedPocs.size() > 0
        int bullCount = 0
        int bearCount = 0
        for i = untestedPocs.size() - 1 to 0
            UntestedPOC p = untestedPocs.get(i)
            if p.isBull
                bullCount += 1
                if bullCount > 2
                    p.pocLine.set_x2(p.endBar)
                    untestedPocs.remove(i)
            else
                bearCount += 1
                if bearCount > 2
                    p.pocLine.set_x2(p.endBar)
                    untestedPocs.remove(i)

//---------------------------------------------------------------------------------------------------------------------}
// Volume Anomalies
//---------------------------------------------------------------------------------------------------------------------{
if showBubbles
    float volSma = ta.sma(volume, 20)
    if volSma > 0
        float volRatio = volume / volSma
        if volRatio >= bubbleMult
            bool isBull = close >= open
            color bubColor = isBull ? color.new(upEndC, 40) : color.new(dnEndC, 40)
            int dynSize = int(math.max(6, math.min(volRatio * 4, 20)))
            string bubText = volRatio >= (bubbleMult * 1.5) ? str.tostring(volume, format.volume) : ""
            label.new(bar_index, hl2, text=bubText, color=bubColor, style=label.style_circle, textcolor=color.white, size=dynSize, tooltip="Volume: " + str.tostring(volume, format.volume) + "\nSpike: " + str.tostring(volRatio, "#.##") + "x Average")

//---------------------------------------------------------------------------------------------------------------------}
````
