<!-- tradingview-pine-id: PUB;fa948758017a45948ec2b0b40509ee12 -->
<!-- tradingviewscripts-format: 1 -->
# FlowScope [Hapharmonic]

Source: https://www.tradingview.com/script/0j7OWDAT-FlowScope-Hapharmonic/

## Description

FlowScope: Uncover the Market's True Intent 🔬
[image]https://www.tradingview.com/x/Ms0YivAm/[/image]
Ever wished you could look inside the candles and see where the real action is happening? FlowScope is your microscope for the market's flow, designed to give you a powerful edge by revealing the volume distribution that price action alone can't show you.

Instead of just looking at the open, high, low, and close, FlowScope lets you dive deeper into the market's auction process. It groups candles together and builds a detailed Volume Profile for that period, showing you exactly where the trading happened and revealing the story behind the price action.

Let's explore how you can use it to gain a powerful new edge.

🧐 Core Concept: How It Works

At its heart, FlowScope does three key things:

[*] It Groups Candles: You decide how many candles to group together. For example, setting "Group Candles" to 4 on a 5-minute chart effectively gives you a detailed 20-minute candle and profile. This helps you see the bigger picture and filter out market noise.

[*] It Builds a Volume Profile: For each group, FlowScope analyzes the volume at every single price level. It then displays this as a horizontal histogram (we call this a "footprint" or profile). Longer bars mean more volume was traded at that price, indicating a "fair" price or an area of acceptance. Shorter bars mean price moved through quickly, indicating rejection.

[*] It Creates a Custom "Grouped Candle": To summarize the group's overall price action, FlowScope draws a single, custom candle representing the entire group's:
    
    [*] Open: The open of the first candle in the group.
    [*] High: The absolute highest price reached within the group.
    [*] Low: The absolute lowest price reached within the group.
    [*] Close: The close of the last candle in the group.
    
This gives you a crystal-clear view of the group's net result, free from the back-and-forth noise of the individual candles inside it.

Below are some of the stunning preset color palettes you can choose from to customize your view:

[image]https://www.tradingview.com/x/kxKvqfFH/[/image]
[image]https://www.tradingview.com/x/xoCmF4Ud/[/image]
[image]https://www.tradingview.com/x/Cb0RngWi/[/image]
[image]https://www.tradingview.com/x/srLs4MUa/[/image]
[image]https://www.tradingview.com/x/aLeMHnnl/[/image]
[image]https://www.tradingview.com/x/nAr4IUai/[/image]
[image]https://www.tradingview.com/x/MbnHNbbj/[/image]
[image]https://www.tradingview.com/x/CC4WWzXt/[/image]
[image]https://www.tradingview.com/x/GSIbYa3V/[/image]
[image]https://www.tradingview.com/x/2YcWwVQS/[/image]

🚀 How to Use: Practical Applications

FlowScope isn't just for looking pretty; it's a powerful analysis tool. Here are a few ways to integrate it into your trading:

[*] Identify High-Volume Nodes (HVNs): Look for the longest bars in the profile. These are price levels where the market spent the most time and traded the most volume. HVNs often act as powerful "magnets" for price, becoming key areas of support and resistance.

[*] Spot Low-Volume Nodes (LVNs): These are areas with very short bars or gaps in the profile. They represent price levels that the market moved through quickly and inefficiently. If price returns to an LVN, it's likely to move through it quickly again.

[*] Analyze the Summary Box: This is where the real magic happens! ✨
    
    [*] Total Volume (Σ): The total volume for the entire group.
    [*] Buy (B) vs. Sell (S) Volume: FlowScope analyzes the lower timeframe action to estimate the buying and selling pressure that made up the total volume. Is a big red candle mostly aggressive selling, or was it just a lack of buyers? The B/S data gives you clues. A high-volume candle with nearly 50/50 buy/sell pressure might indicate absorption or a potential reversal.
    
[*] Use the Grouped Candle for Clarity: Is the market in a clear uptrend, or is it just choppy? The grouped candle can give you a much clearer signal. A series of strong, green grouped candles shows much more conviction than a mix of small green and red candles.

⚙️ Settings & Customization

This is where you can truly make FlowScope your own. Let's walk through each setting.

    Profile Settings
    
    [*] Group Candles: The number of standard chart candles you want to combine into a single FlowScope profile. A setting of 1 will analyze every single bar. A higher number gives you a broader market view. When Group Candles is set to 5, the data from the 5 individual candles are combined, and the volume is calculated accordingly.
    [image]https://www.tradingview.com/x/qaUnYXDb/[/image]

    [*] Max Profile Boxes: This setting is more than just a number; it's a smart limit that ensures your profiles are always readable and relevant to the current market conditions.
        
        [*] Adaptive Sizing (The Ideal Goal): FlowScope first tries to create the perfect profile by making each volume box's height proportional to the current market volatility. It calculates an "ideal" box height based on the Average True Range (ATR / 10). This is powerful because it automatically adapts: you get smaller, more detailed boxes in quiet, low-volatility markets, and larger, clearer boxes in volatile, fast-moving markets.

        [*] The Safety Cap (Your Setting): However, what if you group several candles during a massive price move? The price range could be huge! If we only used the small, ATR-based box height, you might end up with hundreds of tiny, unreadable boxes. This is where your Max Profile Boxes setting (defaulting to 50) comes in. It acts as a maximum detail cap. If the adaptive, volatility-based calculation determines that it would need more boxes than your setting (e.g., more than 50), the indicator will override it. It will then simply divide the entire price range of the group into exactly the number of boxes you specified (e.g., 50).
        
    In short: You are setting the maximum allowable detail. FlowScope intelligently adapts the profile's granularity below that limit based on market volatility, ensuring you always get a clear and meaningful picture.
    

    Style
    
    [*] Show Profile BG: A simple toggle to show or hide the faint background color behind the volume bars. Turning it off can create a cleaner look.
    [*] Color Mode: This dropdown controls how the volume profile text is colored.
        
        [*] Custom Gradient: This mode uses the three custom colors you select in the "Profile Colors" section to create a beautiful gradient across the profile.
        [*] Candle Color: This mode colors the profile based on whether the grouped candle was bullish (green) or bearish (red). The color will be a gradient, with the most intense color applied to the box with the highest volume; the colors of the other boxes will fade out from that point. It's a great way to see the profile's "mood" at a glance.
        
        [image]https://www.tradingview.com/x/jBeeILmM/[/image]
    

    Profile Colors 🎨
    
    [*] Use Preset Palette: This is the master switch!
        
        [*] If checked: You can choose from 10 stunning, pre-designed color palettes from the Palette dropdown. The custom color pickers below will be disabled.
        [*] If unchecked (Default): The Palette dropdown will be disabled, and you can now choose your own three colors for the gradient.
        
    [*] Palette: (Only active when "Use Preset Palette" is checked). Choose from 10 luxurious, eye-catching color schemes like "Solar Flare" or "Deep Space" to instantly change the look and feel of your chart.

    [*] Low Price / Mid Price / High Price: (Only active when "Use Preset Palette" is unchecked). These three color pickers allow you to design your own unique gradient for the Custom Gradient color mode.
    

    Candle Display
    
    [*]These settings control the custom "Grouped Candle" that summarizes the profile. When using the "Show Custom Candle" feature, you should change the chart's candlestick display to Bars for a cleaner view.
    [image]https://www.tradingview.com/x/tW5PRgU5/[/image]
    [*] Show Custom Candle: This is the main toggle. When you check this box, the original chart candles will be hidden, and your custom FlowScope candle will be displayed instead. This custom candle is intentionally small to ensure it does not visually overlap with the volume profile boxes.
    [image]https://www.tradingview.com/x/6bHpsYXW/[/image]
    [*] Show Body: (Only active when "Show Custom Candle" is checked). Toggles the visibility of the candle's body.
    [*] Wick Width & Body Width: (Only active when "Show Custom Candle" is checked). These sliders let you control the thickness of the wick and body lines to match your personal style.
    [*] Up Color / Down Color: (Only active when "Show Custom Candle" is checked). Choose the colors for your bullish and bearish custom candles.
    

Experiment with the settings, find a style that works for you, and start seeing the market in a whole new light.

Happy trading! 📈😊

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hapharmonic

//@version=6
indicator("FlowScope [Hapharmonic]", "Hapharmonic - FlowScope", overlay=true, max_boxes_count=500, max_lines_count=500, max_bars_back=1000)

int FOOTPRINT_BLOCKS_PER_BAR = 10

enum ColorMode
    CUSTOM = "Custom Gradient"
    CANDLE = "Candle Color"

enum Palette
    SOLAR_FLARE     = "Solar Flare"
    DEEP_SPACE      = "Deep Space"
    EMERALD_SEA     = "Emerald Sea"
    ROYAL_GOLD      = "Royal Gold"
    CYBERPUNK_NIGHT = "Cyberpunk Night"
    PHOENIX_FIRE    = "Phoenix Fire"
    ARCTIC_DAWN     = "Arctic Dawn"
    STARLIGHT       = "Starlight"
    NEON_GLOW       = "Neon Glow"
    GILDED_ONYX     = "Gilded Onyx"

type CandleProfile
    float profileHigh
    float profileLow
    int   numBoxes
    float boxHeight
    array<float> volumeDistribution
    float maxVolumeInProfile
    int   maxVolumeIndex

// --- Inputs ---
string GRP_PROFILE = "Profile Settings"
int    groupSizeInput = input.int(1, "Group Candles"     , minval=1, maxval=10, group=GRP_PROFILE, tooltip="Number of candles to aggregate into a single profile. 1 = default behavior.")
int    maxBoxesInput  = input.int(50, "Max Profile Boxes", minval=5, maxval=200, group=GRP_PROFILE, tooltip="Sets the maximum number of volume boxes per profile to maintain readability.")

string    GRP_STYLE       = "Style"
bool      showBoxBgInput  = input.bool(false, "Show Profile BG", group=GRP_STYLE)
ColorMode colorModeInput  = input.enum(ColorMode.CUSTOM, "Color Mode", group=GRP_STYLE)

bool isCustomColorMode = colorModeInput == ColorMode.CUSTOM
bool isCandleColorMode = colorModeInput == ColorMode.CANDLE

// --- Conditional Color Inputs ---
string GRP_COLORS     = "Profile Colors"
bool   usePresetInput = input.bool(false, "Use Preset Palette", group=GRP_COLORS, tooltip="If checked, uses a predefined color palette. If unchecked, allows custom color selection below.")

Palette presetPaletteInput = input.enum(Palette.SOLAR_FLARE, "Palette", group=GRP_COLORS, active=usePresetInput)

color startColorInput = input.color(color.new(#00BCD4, 0), "Low Price", group=GRP_COLORS, inline="custom", active=not usePresetInput and isCustomColorMode)
color midColorInput   = input.color(color.new(#FFEB3B, 0), "Mid Price", group=GRP_COLORS, inline="custom", active=not usePresetInput and isCustomColorMode)
color endColorInput   = input.color(color.new(#F44336, 0), "High Price", group=GRP_COLORS, inline="custom", active=not usePresetInput and isCustomColorMode)

int fadePercentageInput = input.int(95, "Gradient Fade %", minval=0, maxval=95, step=5, group=GRP_STYLE, 
     tooltip="Controls the transparency of the gradient in 'Candle Color' mode.", 
     active=isCandleColorMode)
color summaryBgColorInput = input.color(color.new(#673AB7, 75), "Summary Box BG", group=GRP_STYLE)

string GRP_CANDLE          = "Candle Display"
bool  showWickInput        = input.bool(true, "Show Custom Candle", group=GRP_CANDLE)
bool  showBodyInput        = input.bool(true, "Show Body", group=GRP_CANDLE, active=showWickInput)
int   wickWidthInput       = input.int(1, "Wick Width", minval=1, maxval=5, group=GRP_CANDLE, active=showWickInput)
int   bodyWidthInput       = input.int(7, "Body Width", minval=1, maxval=10, group=GRP_CANDLE, active=showBodyInput)
color candleUpColorInput   = input.color(color.green, "Up Color", group=GRP_CANDLE, inline="candlecolor", active=showWickInput)
color candleDownColorInput = input.color(color.red, "Down Color", group=GRP_CANDLE, inline="candlecolor", active=showWickInput)

// --- Final Color Selection Logic ---
color finalStartColor = na, color finalMidColor = na, color finalEndColor = na
if usePresetInput
    [s, m, e] = switch presetPaletteInput
        Palette.SOLAR_FLARE     => [color.new(#780000, 0), color.new(#FF4500, 0), color.new(#FFD700, 0)]
        Palette.DEEP_SPACE      => [color.new(#4B0082, 0), color.new(#FF00FF, 0), color.new(#00FFFF, 0)]
        Palette.EMERALD_SEA     => [color.new(#004D40, 0), color.new(#00C853, 0), color.new(#A7FFEB, 0)]
        Palette.ROYAL_GOLD      => [color.new(#4A148C, 0), color.new(#FFD700, 0), color.new(#FFF8E1, 0)]
        Palette.CYBERPUNK_NIGHT => [color.new(#00BFFF, 0), color.new(#FF69B4, 0), color.new(#E6E6FA, 0)]
        Palette.PHOENIX_FIRE    => [color.new(#FEEA3B, 0), color.new(#DC143C, 0), color.new(#4B0082, 0)]
        Palette.ARCTIC_DAWN     => [color.new(#483D8B, 0), color.new(#87CEEB, 0), color.new(#F0FFFF, 0)]
        Palette.STARLIGHT       => [color.new(#2C3E50, 0), color.new(#BDC3C7, 0), color.new(#FFFFFF, 0)]
        Palette.NEON_GLOW       => [color.new(#FF007F, 0), color.new(#00FFFF, 0), color.new(#ADFF2F, 0)]
        Palette.GILDED_ONYX     => [color.new(#1C1C1C, 0), color.new(#D4AF37, 0), color.new(#F5F5DC, 0)]
    finalStartColor := s, finalMidColor := m, finalEndColor := e
else
    finalStartColor := startColorInput, finalMidColor := midColorInput, finalEndColor := endColorInput

// --- State Variables ---
var array<float> groupLtfHighs = array.new<float>(), var array<float> groupLtfLows = array.new<float>(), var array<float> groupLtfVolumes = array.new<float>()
var array<float> groupBuyVolumes = array.new<float>(), var array<float> groupSellVolumes = array.new<float>()
var float groupHigh = na, var float groupLow = na, var float groupOpen = na, var float groupClose = na

// --- Functions & Methods ---
f_buildVolumeBar(int filledBlocks, int totalBlocks) =>
    string result = ""
    for i = 1 to totalBlocks
        result += i <= filledBlocks ? "█" : "░"
    result

f_createProfile(float candleHigh, float candleLow, float targetBoxHeight, array<float> ltfH, array<float> ltfL, array<float> ltfV) =>
    float barRange = candleHigh - candleLow
    int numBoxes = math.max(1, int(math.round(barRange / targetBoxHeight)))
    float adjustedBoxHeight = barRange / numBoxes
    array<float> volDist = array.new_float(numBoxes, 0.0)
    for i = 0 to array.size(ltfH) - 1
        float ltfBarH = array.get(ltfH, i), float ltfBarL = array.get(ltfL, i), float ltfBarV = array.get(ltfV, i)
        float ltfBarRange = math.max(ltfBarH - ltfBarL, syminfo.mintick)
        for boxIndex = 0 to numBoxes - 1
            float boxBottom = candleLow + (boxIndex * adjustedBoxHeight), float boxTop = boxBottom + adjustedBoxHeight
            float overlapHeight = math.max(0, math.min(boxTop, ltfBarH) - math.max(boxBottom, ltfBarL))
            if overlapHeight > 0
                array.set(volDist, boxIndex, array.get(volDist, boxIndex) + ltfBarV * (overlapHeight / ltfBarRange))
    float maxVolume = array.max(volDist)
    int maxVolIdx = array.indexof(volDist, maxVolume)
    CandleProfile.new(candleHigh, candleLow, numBoxes, adjustedBoxHeight, volDist, maxVolume, maxVolIdx)

method draw(CandleProfile this, int startBar, int endBar, int groupSize, ColorMode mode, int fadePercentage, color startC, color midC, color endC, float totalBuyVol, float totalSellVol) =>
    int maxVolIdx = this.maxVolumeIndex
    int totalBlocks = int(FOOTPRINT_BLOCKS_PER_BAR + (FOOTPRINT_BLOCKS_PER_BAR * 0.3 * (groupSize - 1)))
    for i = 0 to this.numBoxes - 1
        float boxBottom = this.profileLow + (i * this.boxHeight), float boxTop = boxBottom + this.boxHeight
        float currentBoxVolume = array.get(this.volumeDistribution, i)
        if currentBoxVolume > 0
            int filledBlocks = this.maxVolumeInProfile > 0 ? int(math.round((currentBoxVolume / this.maxVolumeInProfile) * totalBlocks)) : 0
            string boxText = f_buildVolumeBar(filledBlocks, totalBlocks) + " " + str.tostring(currentBoxVolume, format.volume)
            color textColor = na
            if mode == ColorMode.CUSTOM
                if i < maxVolIdx
                    textColor := color.from_gradient(i, 0, maxVolIdx, startC, midC)
                else if i > maxVolIdx
                    textColor := color.from_gradient(i, maxVolIdx, this.numBoxes - 1, midC, endC)
                else
                    textColor := midC
            else // CANDLE mode
                color midColor  = groupClose > groupOpen ? color.new(color.green, 0) : color.new(color.red, 0)
                color fadeColor = color.new(midColor, fadePercentage)
                if i < maxVolIdx
                    textColor := color.from_gradient(i, 0, maxVolIdx, fadeColor, midColor)
                else if i > maxVolIdx
                    textColor := color.from_gradient(i, maxVolIdx, this.numBoxes - 1, midColor, fadeColor)
                else
                    textColor := midColor
            color boxBgColor = showBoxBgInput ? color.new(textColor, 80) : color(na)
            box.new(startBar, boxTop, endBar + 1, boxBottom, bgcolor=boxBgColor, border_color=na, text=boxText, text_color=textColor, text_halign=text.align_left, text_valign=text.align_center)
    float totalVolume = array.sum(this.volumeDistribution)
    if totalVolume > 0
        float buyPercent   = totalVolume > 0 ? (totalBuyVol / totalVolume) * 100 : 0
        float sellPercent  = totalVolume > 0 ? (totalSellVol / totalVolume) * 100 : 0
        string summaryText = "Σ: " + str.tostring(totalVolume, format.volume) + "\n" +
             "B: " + str.tostring(totalBuyVol, format.volume) + " (" + str.tostring(buyPercent, "#.##") + "%) \n " +
             "S: " + str.tostring(totalSellVol, format.volume) + " (" + str.tostring(sellPercent, "#.##") + "%)"
        box.new(startBar, this.profileLow, endBar + 1, this.profileLow - (this.boxHeight * 1.5), bgcolor=summaryBgColorInput, border_color=color.new(color.white, 50), text=summaryText, text_color=color.white, text_halign=text.align_center, text_valign=text.align_center, text_formatting=text.format_bold)

barcolor(showWickInput ? color.new(color.black, 100) : na)

// --- Data Retrieval & Accumulation ---
[ltfOpens, ltfHighs, ltfLows, ltfCloses, ltfVolumes] = request.security_lower_tf(syminfo.tickerid, "1", [open, high, low, close, volume])
if array.size(ltfHighs) > 0
    groupLtfHighs.concat(ltfHighs), groupLtfLows.concat(ltfLows), groupLtfVolumes.concat(ltfVolumes)
    for i = 0 to array.size(ltfVolumes) - 1
        float ltfH     = array.get(ltfHighs, i), float ltfL = array.get(ltfLows, i), float ltfC = array.get(ltfCloses, i), float ltfV = array.get(ltfVolumes, i)
        float ltfRange = math.max(ltfH - ltfL, syminfo.mintick)
        float buyVol   = ltfV * (ltfC - ltfL) / ltfRange
        float sellVol  = ltfV * (ltfH - ltfC) / ltfRange
        groupBuyVolumes.push(buyVol)
        groupSellVolumes.push(sellVol)
    if na(groupOpen)
        groupOpen := open
    groupHigh := na(groupHigh) ? high : math.max(groupHigh, high)
    groupLow := na(groupLow) ? low : math.min(groupLow, low)
    groupClose := close

// --- Trigger, Draw, and Reset Logic ---
bool isGroupEnd = (bar_index + 1) % groupSizeInput == 0
bool canDraw    = groupLtfHighs.size() > 0 and (groupHigh - groupLow) > syminfo.mintick
if (isGroupEnd or barstate.islast) and canDraw
    int actualGroupSize   = barstate.islast ? (bar_index % groupSizeInput) + 1 : groupSizeInput
    int endBar = bar_index, int startBar = endBar - actualGroupSize + 1
    float totalBuyVolume  = array.sum(groupBuyVolumes)
    float totalSellVolume = array.sum(groupSellVolumes)
    float baseBoxHeight   = ta.atr(14) / 10, float groupRange = groupHigh - groupLow
    float targetBoxHeight = (groupRange / baseBoxHeight) > maxBoxesInput ? groupRange / maxBoxesInput : baseBoxHeight
    CandleProfile profile = f_createProfile(groupHigh, groupLow, targetBoxHeight, groupLtfHighs, groupLtfLows, groupLtfVolumes)
    profile.draw(startBar, endBar, actualGroupSize, colorModeInput, fadePercentageInput, finalStartColor, finalMidColor, finalEndColor, totalBuyVolume, totalSellVolume)

    if showWickInput
        color wickColor = groupClose > groupOpen ? candleUpColorInput : candleDownColorInput
        line.new(startBar, groupHigh, startBar, groupLow, xloc.bar_index, extend.none, wickColor, width=wickWidthInput)
        if showBodyInput
            line.new(startBar, groupOpen, startBar, groupClose, xloc.bar_index, extend.none, wickColor, width=bodyWidthInput)

    // Reset state for the next group
    groupLtfHighs.clear(), groupLtfLows.clear(), groupLtfVolumes.clear()
    groupBuyVolumes.clear(), groupSellVolumes.clear()
    groupHigh := na, groupLow := na, groupOpen := na, groupClose := na
````
