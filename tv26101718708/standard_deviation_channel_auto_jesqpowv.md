# Standard Deviation Channel (Auto)

- url: https://www.tradingview.com/script/jEsqpOwV-Standard-Deviation-Channel-Auto/
- type: indicator
- pine_id: PUB;ee914b2062ac4a139772b6dbbffe70f5
- version: 1.0

## Description

A regression channel inspired by the ThinkorSwim Standard Deviation Channel. It finds the trend length for you.

HOW IT WORKS
1. The script draws a straight line through recent price (linear regression).
2. It draws bands above and below that line at 1, 2, and 3 standard deviations. Standard deviation is a measure of how far price usually strays from the line.
3. In Auto mode, it tests many lengths. It keeps the length where price follows the line best, using the highest |Pearson R|. Pearson R is a score from 0 to 1 for how straight the trend is.
4. A small label shows the trend (up, down, or none), the length it chose, and R. If |R| is below your minimum, the label says "No clear trend".

SETTINGS
- Auto length: on or off. Off uses your Manual length.
- Auto min length, max length, and step: the range of lengths it tests.
- Min |R|: how strong R must be to call it a trend.
- Each level (1, 2, 3) has its own show box, deviation number, color, width, style, and fill.
- The middle line has its own color, width, and style.
- Extend lines left or right.

NOTES
- Short windows can score a high R by chance. If the channel looks too short, raise the min length.
- Auto mode picks the best R out of many lengths, so treat R as a guide, not proof.
- This is not an exact copy of ThinkorSwim. The deviation math may differ a little.
- The lines redraw when new bars arrive. Auto mode may pick a new length.
- For learning only. This is not financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Based on: dharmatech : Standard Deviation Channel
//@version=6
indicator("Standard Deviation Channel (Auto)", shorttitle = "SDC Auto", overlay = true, max_bars_back = 5000)

// ----------------------------------------------------------------------
// Inputs
// ----------------------------------------------------------------------
const string G_LEN = "Length"
const string G_MID = "Middle line"
const string G_L1  = "Level 1"
const string G_L2  = "Level 2"
const string G_L3  = "Level 3"
const string G_LBL = "Info label"
const string G_VIS = "Visual Settings"

src     = input.source(close, "Source", group = G_LEN)
autoLen = input.bool(true, "Auto length (best fit)", group = G_LEN,
     tooltip = "ON: the script tests many lengths and keeps the one with the highest |Pearson R|. OFF: it uses the manual length.")
manLen  = input.int(100, "Manual length", minval = 2, maxval = 5000, group = G_LEN)
minLen  = input.int(50,  "Auto: min length", minval = 5,  maxval = 5000, group = G_LEN,
     tooltip = "Short windows often give a high R by chance. Raise this to ignore very short trends.")
maxLen  = input.int(500, "Auto: max length", minval = 10, maxval = 5000, group = G_LEN)
stepLen = input.int(5,   "Auto: step", minval = 1, maxval = 100, group = G_LEN)
minR    = input.float(0.5, "Min |R| to call it a trend", minval = 0.0, maxval = 1.0, step = 0.05, group = G_LEN)

// Middle line (same as the original: orange, dashed)
midCol   = input.color(color.orange, "Color", inline = "m", group = G_MID)
midW     = input.int(1, "Width", minval = 1, maxval = 10, inline = "m", group = G_MID)
midStyle = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "m", group = G_MID)

// Level 1 (blue)
show1  = input.bool(true, "Show ±", inline = "a1", group = G_L1)
mult1  = input.float(1.0, "", minval = 0.0, step = 0.5, inline = "a1", group = G_L1)
fill1  = input.bool(true, "Fill", inline = "a1", group = G_L1)
col1   = input.color(color.blue, "Color", inline = "b1", group = G_L1)
w1     = input.int(1, "Width", minval = 1, maxval = 10, inline = "b1", group = G_L1)
style1 = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "b1", group = G_L1)

// Level 2 (green)
show2  = input.bool(true, "Show ±", inline = "a2", group = G_L2)
mult2  = input.float(2.0, "", minval = 0.0, step = 0.5, inline = "a2", group = G_L2)
fill2  = input.bool(false, "Fill", inline = "a2", group = G_L2)
col2   = input.color(color.green, "Color", inline = "b2", group = G_L2)
w2     = input.int(1, "Width", minval = 1, maxval = 10, inline = "b2", group = G_L2)
style2 = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "b2", group = G_L2)

// Level 3 (red)
show3  = input.bool(true, "Show ±", inline = "a3", group = G_L3)
mult3  = input.float(3.0, "", minval = 0.0, step = 0.5, inline = "a3", group = G_L3)
fill3  = input.bool(false, "Fill", inline = "a3", group = G_L3)
col3   = input.color(color.red, "Color", inline = "b3", group = G_L3)
w3     = input.int(1, "Width", minval = 1, maxval = 10, inline = "b3", group = G_L3)
style3 = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], inline = "b3", group = G_L3)

// Info label colors (the label shows the detected trend)
showInfo = input.bool(true, "Show info label", group = G_LBL)
upCol    = input.color(color.green, "Uptrend",   inline = "lc", group = G_LBL)
dnCol    = input.color(color.red,   "Downtrend", inline = "lc", group = G_LBL)
flatCol  = input.color(color.gray,  "No trend",  inline = "lc", group = G_LBL)

fillTransp = input.int(95, "Fill transparency", minval = 0, maxval = 100, group = G_VIS)
extL = input.bool(false, "Extend Lines Left",  group = G_VIS)
extR = input.bool(true,  "Extend Lines Right", group = G_VIS)

exs = extL and extR ? extend.both : extL ? extend.left : extR ? extend.right : extend.none

styleOf(string s) =>
    s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed

// ----------------------------------------------------------------------
// Drawing objects (kept between bars so we can delete and redraw)
// ----------------------------------------------------------------------
var array<line>     chLines = array.new<line>()
var array<linefill> chFills = array.new<linefill>()
var label           info    = na

// ----------------------------------------------------------------------
// Everything runs on the last bar only
// ----------------------------------------------------------------------
if barstate.islast
    for l in chLines
        line.delete(l)
    chLines.clear()
    for f in chFills
        linefill.delete(f)
    chFills.clear()
    label.delete(info)

    int scanMax = math.min(autoLen ? maxLen : manLen, bar_index + 1)

    if scanMax >= 2
        // x = age of the bar (0 = newest). y = price minus the newest price
        // (this keeps the math accurate for big prices).
        float sumX  = 0.0
        float sumY  = 0.0
        float sumXX = 0.0
        float sumXY = 0.0
        float sumYY = 0.0

        float bestScore = -1.0
        int   bestN     = 0
        float bestM     = 0.0
        float bestB     = 0.0
        float bestSd    = 0.0
        float bestR     = 0.0

        for i = 0 to scanMax - 1
            float x = i
            float y = src[i] - src
            sumX  += x
            sumY  += y
            sumXX += x * x
            sumXY += x * y
            sumYY += y * y

            int n = i + 1
            bool isCand = n == scanMax or (autoLen and n >= minLen and (n - minLen) % stepLen == 0)

            if isCand and n >= 2
                float dX  = n * sumXX - sumX * sumX
                float dY  = n * sumYY - sumY * sumY
                float cov = n * sumXY - sumX * sumY
                float m   = dX > 0 ? cov / dX : 0.0
                float b   = (sumY - m * sumX) / n
                float r   = dX > 0 and dY > 0 ? cov / math.sqrt(dX * dY) : 0.0
                float sse = math.max(sumYY - b * sumY - m * sumXY, 0.0)
                float sd  = math.sqrt(sse / n)
                float score = math.abs(r)

                if score > bestScore
                    bestScore := score
                    bestN  := n
                    bestM  := m
                    bestB  := b
                    bestSd := sd
                    bestR  := r

        if bestN >= 2
            // Price slope per bar (x runs from new to old, so flip the sign)
            float slopeBar = -bestM
            float rTime    = -bestR
            bool  trendOk  = math.abs(bestR) >= minR

            int   x1     = bar_index - (bestN - 1)
            int   x2     = bar_index
            float yEnd   = bestB + src
            float yStart = bestB + bestM * (bestN - 1) + src

            line midLine = line.new(x1, yStart, x2, yEnd, extend = exs, color = midCol, style = styleOf(midStyle), width = midW)
            chLines.push(midLine)

            array<bool>   showArr  = array.from(show1, show2, show3)
            array<bool>   fillArr  = array.from(fill1, fill2, fill3)
            array<float>  multArr  = array.from(mult1, mult2, mult3)
            array<color>  colArr   = array.from(col1, col2, col3)
            array<int>    widthArr = array.from(w1, w2, w3)
            array<string> styleArr = array.from(style1, style2, style3)

            for k = 0 to 2
                if showArr.get(k)
                    float off  = multArr.get(k) * bestSd
                    color lc   = colArr.get(k)
                    int   lw   = widthArr.get(k)
                    string ls  = styleArr.get(k)
                    line upL = line.new(x1, yStart + off, x2, yEnd + off, extend = exs, color = lc, style = styleOf(ls), width = lw)
                    line dnL = line.new(x1, yStart - off, x2, yEnd - off, extend = exs, color = lc, style = styleOf(ls), width = lw)
                    chLines.push(upL)
                    chLines.push(dnL)
                    if fillArr.get(k)
                        chFills.push(linefill.new(upL, midLine, color.new(lc, fillTransp)))
                        chFills.push(linefill.new(dnL, midLine, color.new(lc, fillTransp)))

            if showInfo
                color  lblCol   = not trendOk ? flatCol : slopeBar > 0 ? upCol : dnCol
                string trendTxt = not trendOk ? "No clear trend" : slopeBar > 0 ? "Uptrend" : "Downtrend"
                string txt = trendTxt + "\nLength " + str.tostring(bestN) + "\nR " + str.tostring(rTime, "#.##")
                info := label.new(x2, yEnd, txt, style = label.style_label_left, color = lblCol, textcolor = color.white, size = size.small)
````
