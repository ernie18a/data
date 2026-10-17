# Quasimodo Pattern Structure By EmirTradeHub

- url: https://www.tradingview.com/script/0EHTdnnu/
- type: indicator
- pine_id: PUB;2bb7d4d31db9477c9787664a6261589f
- version: 1.0

## Description

Quasimodo Pattern Structure with Dynamic Entry, Stop & Take Profit

This indicator detects Bullish and Bearish Quasimodo market structure patterns and automatically creates a complete trade management structure including Entry, Stop Level, TP-1 and TP-2 levels.

The script is designed to help traders visually track structural reversals and possible reaction zones using a clean and fully automated pattern workflow.

━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━

• Automatic Bullish and Bearish Quasimodo pattern detection

• Dynamic A → B → C → D structure drawing

• Automatic Entry level generation

• Dynamic Stop Level tracking

• Automatic TP-1 and TP-2 levels

• Pattern expiration system

• Trade result tracking system

• Historical pattern visualization

• Fully customizable visual settings

• Integrated alert system

━━━━━━━━━━━━━━━━━━
ALERT SYSTEM
━━━━━━━━━━━━━━━━━━

The indicator includes built-in TradingView alert conditions for all major events.

Available alerts:

• Bullish Quasimodo Detected
• Bearish Quasimodo Detected

• Entry Triggered

• TP-1 Hit
• Take Profit Hit

• Stopped out

• Pattern expired

These alerts can be used for:
• Notifications
• Webhooks
• Automation systems
• Trade monitoring workflows

━━━━━━━━━━━━━━━━━━
HOW THE PATTERN WORKS
━━━━━━━━━━━━━━━━━━

Bearish Quasimodo Structure:

The indicator searches for a Higher High followed by a Lower Low structure shift.
After the structural shift forms, the script tracks the retracement level and creates an Entry zone.

Bullish Quasimodo Structure:

The indicator searches for a Lower Low followed by a Higher High structure shift.
After the structural shift forms, the script tracks the retracement level and creates an Entry zone.

The structure is automatically monitored after the D point is confirmed.

━━━━━━━━━━━━━━━━━━
ENTRY SYSTEM
━━━━━━━━━━━━━━━━━━

The Entry level is based on the A structure point.

When price returns to the Entry level, the script automatically activates the trade structure.

Before Entry occurs:

• TP levels are not active
• Stop Level is not active

If price never reaches the Entry level within the specified timeout period, the pattern becomes invalid and the script prints:

“Pattern expired”

━━━━━━━━━━━━━━━━━━
STOP & TAKE PROFIT SYSTEM
━━━━━━━━━━━━━━━━━━

Stop Level:

The Stop Level is dynamically created using the C structure point.

Take Profit Levels:

TP-1 and TP-2 levels are automatically generated from the pattern structure.

Trade Result Logic:

• If price directly hits Stop Level:
“Stopped out”

• If TP-1 is reached and price later hits Stop:
“TP-1 hit then stopped out”

• If TP-2 is reached:
“Take Profit Hit”

The script also stops extending trade management lines once the trade is completed.

━━━━━━━━━━━━━━━━━━
VISUAL SYSTEM
━━━━━━━━━━━━━━━━━━

Entry Line:
Blue colored dynamic Entry line.

Take Profit Lines:
Green TP-1 and TP-2 lines.

Stop Line:
Red Stop Level line.

All major visual elements can be customized from the settings panel:

• Line colors
• Line widths
• Text sizes
• Result label sizes

━━━━━━━━━━━━━━━━━━
SETTINGS
━━━━━━━━━━━━━━━━━━

ZigZag Settings

Left Bars
Controls pivot sensitivity on the left side.

Right Bars
Controls pivot confirmation on the right side.

━━━━━━━━━━━━━━━━━━

Other Settings

Quasimodo Mode
Choose Bullish, Bearish or Both pattern types.

Entry Timeout Bars
Maximum number of bars allowed before the pattern expires.

━━━━━━━━━━━━━━━━━━

Position Entry Visual Settings

Entry Line Color
Changes Entry line color.

Entry Line Width
Changes Entry line thickness.

Entry Text Size
Changes Entry line text size.

Entry Label Size
Changes Entry candle label size.

━━━━━━━━━━━━━━━━━━

Stop Visual Settings

Stop Line Color
Changes Stop Level line color.

Stop Line Width
Changes Stop Level line thickness.

Stop Text Size
Changes Stop Level text size.

━━━━━━━━━━━━━━━━━━

Take Profit Visual Settings

TP Line Color
Changes TP line color.

TP Line Width
Changes TP line thickness.

TP Text Size
Changes TP line text size.

━━━━━━━━━━━━━━━━━━

Trade Result Visual Settings

Result Label Size
Changes the size of trade result labels such as:
• Pattern expired
• Stopped out
• TP-1 hit then stopped out
• Take Profit Hit

━━━━━━━━━━━━━━━━━━
IMPORTANT NOTES
━━━━━━━━━━━━━━━━━━

This script uses pivot-based market structure logic.

Patterns are confirmed only after pivot confirmation occurs.
Because of this, structural signals can appear with confirmation delay.

The indicator is designed for analytical and educational purposes and should not be considered financial advice.

Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator('Quasimodo Pattern Structure with Dynamic Entry, Stop & Take Profit By EmirTradeHub', shorttitle = 'QM Structure Entry TP SL By EmirTradeHub', overlay = true, max_labels_count = 500, max_lines_count = 500)

zigzagGroup = 'ZigZag Settings'
otherGroup = 'Other Settings'
entryVisualGroup = 'Position Entry Visual Settings'
stopVisualGroup = 'Stop Visual Settings'
tpVisualGroup = 'Take Profit Visual Settings'
resultVisualGroup = 'Trade Result Visual Settings'

left = input.int(20, 'Left Bars', minval = 1, inline = 'ZZ1', group = zigzagGroup, tooltip = 'EN: Number of bars to the left used for pivot detection.\nTR: Pivot tespiti için soldaki bar sayısı.')
right = input.int(20, 'Right Bars', minval = 0, inline = 'ZZ1', group = zigzagGroup, tooltip = 'EN: Number of bars to the right used for pivot confirmation.\nTR: Pivot onayı için sağdaki bar sayısı.')

qmMode = input.string('Both', 'Quasimodo Mode', options = ['Both', 'Bullish', 'Bearish'], inline = 'OT1', group = otherGroup, tooltip = 'EN: Select which Quasimodo pattern type will be shown.\nTR: Hangi Quasimodo pattern türünün gösterileceğini seçer.')
entryTimeoutBars = input.int(200, 'Entry Timeout Bars', minval = 1, inline = 'OT2', group = otherGroup, tooltip = 'EN: Maximum number of bars after D point to wait for entry.\nTR: D noktasından sonra entry için beklenecek maksimum bar sayısı.')

entryLineColor = input.color(#0044FF, 'Entry Line Color', inline = 'EN1', group = entryVisualGroup, tooltip = 'EN: Color of the Entry line.\nTR: Entry çizgisinin rengi.')
entryLineWidth = input.int(2, 'Entry Line Width', minval = 1, maxval = 10, inline = 'EN1', group = entryVisualGroup, tooltip = 'EN: Thickness of the Entry line.\nTR: Entry çizgisinin kalınlığı.')
entryTextSize = input.string(size.tiny, 'Entry Text Size', options = [size.tiny, size.small, size.normal, size.large, size.huge], inline = 'EN2', group = entryVisualGroup, tooltip = 'EN: Size of the text placed on the Entry line.\nTR: Entry çizgisi üzerindeki yazının boyutu.')
entryLabelSize = input.string(size.tiny, 'Entry Label Size', options = [size.tiny, size.small, size.normal, size.large, size.huge], inline = 'EN2', group = entryVisualGroup, tooltip = 'EN: Size of the Entry label shown on the entry candle.\nTR: Entry mumunda çıkan Entry label boyutu.')

stopLineColor = input.color(#F23645, 'Stop Line Color', inline = 'ST1', group = stopVisualGroup, tooltip = 'EN: Color of the Stop Level line.\nTR: Stop Level çizgisinin rengi.')
stopLineWidth = input.int(2, 'Stop Line Width', minval = 1, maxval = 10, inline = 'ST1', group = stopVisualGroup, tooltip = 'EN: Thickness of the Stop Level line.\nTR: Stop Level çizgisinin kalınlığı.')
stopTextSize = input.string(size.tiny, 'Stop Text Size', options = [size.tiny, size.small, size.normal, size.large, size.huge], inline = 'ST2', group = stopVisualGroup, tooltip = 'EN: Size of the Stop Level text.\nTR: Stop Level yazısının boyutu.')

tpLineColor = input.color(#089981, 'TP Line Color', inline = 'TP1', group = tpVisualGroup, tooltip = 'EN: Color of TP-1 and TP-2 lines.\nTR: TP-1 ve TP-2 çizgilerinin rengi.')
tpLineWidth = input.int(2, 'TP Line Width', minval = 1, maxval = 10, inline = 'TP1', group = tpVisualGroup, tooltip = 'EN: Thickness of TP-1 and TP-2 lines.\nTR: TP-1 ve TP-2 çizgilerinin kalınlığı.')
tpTextSize = input.string(size.tiny, 'TP Text Size', options = [size.tiny, size.small, size.normal, size.large, size.huge], inline = 'TP2', group = tpVisualGroup, tooltip = 'EN: Size of TP-1 and TP-2 text.\nTR: TP-1 ve TP-2 yazı boyutu.')

resultLabelSize = input.string(size.small, 'Result Label Size', options = [size.tiny, size.small, size.normal, size.large, size.huge], inline = 'RS1', group = resultVisualGroup, tooltip = 'EN: Size of result labels such as Pattern expired, Stopped out and Take Profit Hit.\nTR: Pattern expired, Stopped out ve Take Profit Hit gibi sonuç label boyutu.')

zzColor = #2962FF
bullPatternLineColor = #089981
bearPatternLineColor = #F23645
timeoutColor = color.orange

n = bar_index
resultOffset = ta.atr(14) * 2.0

showBullishQM = qmMode == 'Both' or qmMode == 'Bullish'
showBearishQM = qmMode == 'Both' or qmMode == 'Bearish'

hi = high
lo = low


type zz
    float p
    int b


var int dir = 0
var int MAX_A_SIZE = 10
var array<zz> zigzag = array.new<zz>(3, zz.new(na, na))

var int lastBearDBar = na
var int lastBullDBar = na

var array<line> entryLines = array.new_line()
var array<line> stopLines = array.new_line()
var array<line> tp1Lines = array.new_line()
var array<line> tp2Lines = array.new_line()

var array<label> entryTextLabels = array.new_label()
var array<label> stopTextLabels = array.new_label()
var array<label> tp1TextLabels = array.new_label()
var array<label> tp2TextLabels = array.new_label()

var array<float> entryPrices = array.new_float()
var array<float> stopPrices = array.new_float()
var array<float> tp1Prices = array.new_float()
var array<float> tp2Prices = array.new_float()
var array<float> patternCPrice = array.new_float()

var array<int> patternABar = array.new_int()
var array<int> patternDBar = array.new_int()
var array<int> patternCBar = array.new_int()
var array<int> entryBarArr = array.new_int()

var array<bool> patternIsBullish = array.new_bool()
var array<bool> patternActive = array.new_bool()
var array<bool> entryActive = array.new_bool()
var array<bool> entryDone = array.new_bool()
var array<bool> stopActive = array.new_bool()
var array<bool> tp1Active = array.new_bool()
var array<bool> tp2Active = array.new_bool()
var array<bool> tp1Done = array.new_bool()
var array<bool> timeoutDone = array.new_bool()


method n(float piv) =>
    bool out = not na(piv)
    out

method add_to_zigzag(zz z) =>
    zigzag.unshift(z)
    if zigzag.size() > MAX_A_SIZE
        zigzag.pop()

method update_zigzag(zz z) =>
    zz1 = zigzag.first()
    if dir == 1 and z.p >= zz1.p or dir == -1 and z.p <= zz1.p
        zz1.p := z.p
        zz1.b := z.b

method clean(array<line> aL) =>
    while aL.size() > 500
        aL.shift().delete()

method cleanLabels(array<label> aLb) =>
    while aLb.size() > 500
        aLb.shift().delete()


f_hit(float level) =>
    bool wickTouch = high >= level and low <= level
    bool bodyTouch = math.max(open, close) >= level and math.min(open, close) <= level
    bool openCloseCross = open < level and close > level or open > level and close < level
    bool closeCross = close[1] < level and close > level or close[1] > level and close < level
    bool gapCross = open < level and close[1] > level or open > level and close[1] < level
    wickTouch or bodyTouch or openCloseCross or closeCross or gapCross

f_hit_at(float level, int offset) =>
    bool wickTouch = high[offset] >= level and low[offset] <= level
    bool bodyTouch = math.max(open[offset], close[offset]) >= level and math.min(open[offset], close[offset]) <= level
    bool openCloseCross = open[offset] < level and close[offset] > level or open[offset] > level and close[offset] < level
    bool closeCross = close[offset + 1] < level and close[offset] > level or close[offset + 1] > level and close[offset] < level
    bool gapCross = open[offset] < level and close[offset + 1] > level or open[offset] > level and close[offset + 1] < level
    wickTouch or bodyTouch or openCloseCross or closeCross or gapCross

f_result_y(float cPrice, bool isBullish) =>
    isBullish ? cPrice - resultOffset : cPrice + resultOffset

f_result_style(bool isBullish) =>
    isBullish ? label.style_label_up : label.style_label_down

f_mid(int x1, int x2) =>
    math.floor((x1 + x2) / 2)


float ph = ta.pivothigh(hi, left, right)
float pl = ta.pivotlow(lo, left, right)

dir := ph.n() and na(pl) ? 1 : pl.n() and na(ph) ? -1 : dir
bool ch_dir = ta.change(dir) != 0


if ch_dir
    zz.new(dir == 1 ? hi[right] : lo[right], n - right).add_to_zigzag()
else
    zz.new(dir == 1 ? hi[right] : lo[right], n - right).update_zigzag()


bool bearishQM =
     showBearishQM and
     zigzag.size() >= 5 and
     ch_dir and
     dir == 1 and
     not na(zigzag.get(1).p) and
     not na(zigzag.get(2).p) and
     not na(zigzag.get(3).p) and
     not na(zigzag.get(4).p) and
     zigzag.get(2).p > zigzag.get(4).p and
     zigzag.get(1).p < zigzag.get(3).p

bool bullishQM =
     showBullishQM and
     zigzag.size() >= 5 and
     ch_dir and
     dir == -1 and
     not na(zigzag.get(1).p) and
     not na(zigzag.get(2).p) and
     not na(zigzag.get(3).p) and
     not na(zigzag.get(4).p) and
     zigzag.get(2).p < zigzag.get(4).p and
     zigzag.get(1).p > zigzag.get(3).p


if bearishQM or bullishQM
    bool isBullish = bullishQM

    float dPrice = zigzag.get(1).p
    int dBar = zigzag.get(1).b

    float cPrice = zigzag.get(2).p
    int cBar = zigzag.get(2).b

    float bPrice = zigzag.get(3).p
    int bBar = zigzag.get(3).b

    float aPrice = zigzag.get(4).p
    int aBar = zigzag.get(4).b

    bool isNewPattern = isBullish ? na(lastBullDBar) or dBar != lastBullDBar : na(lastBearDBar) or dBar != lastBearDBar

    if isNewPattern
        if isBullish
            lastBullDBar := dBar
        else
            lastBearDBar := dBar

        color patternColor = isBullish ? bullPatternLineColor : bearPatternLineColor
        line.new(x1 = aBar, y1 = aPrice, x2 = bBar, y2 = bPrice, color = patternColor, width = 2)
        line.new(x1 = bBar, y1 = bPrice, x2 = cBar, y2 = cPrice, color = patternColor, width = 2)
        line.new(x1 = cBar, y1 = cPrice, x2 = dBar, y2 = dPrice, color = patternColor, width = 2)

        bool entryAlreadyHit = false
        int foundEntryBar = na

        if bar_index > dBar
            for j = dBar + 1 to math.min(bar_index, dBar + entryTimeoutBars)
                int offset = bar_index - j
                if not entryAlreadyHit and f_hit_at(aPrice, offset)
                    entryAlreadyHit := true
                    foundEntryBar := j

        bool timedOutAlready = not entryAlreadyHit and bar_index > dBar + entryTimeoutBars

        line entryLine = na
        label entryTextLabel = na

        if not timedOutAlready
            int entryEndBar = entryAlreadyHit ? foundEntryBar : bar_index
            entryLine := line.new(x1 = aBar, y1 = aPrice, x2 = entryEndBar, y2 = aPrice, color = entryLineColor, width = entryLineWidth)
            entryTextLabel := label.new(x = f_mid(aBar, entryEndBar), y = aPrice, text = 'Entry', style = label.style_none, textcolor = entryLineColor, color = color.new(color.white, 100), size = entryTextSize)

        line stopLine = na
        line tp1Line = na
        line tp2Line = na

        label stopTextLabel = na
        label tp1TextLabel = na
        label tp2TextLabel = na

        bool stopIsActive = false
        bool tp1IsActive = false
        bool tp2IsActive = false
        bool tp1AlreadyDone = false
        bool patternIsActive = not timedOutAlready

        if entryAlreadyHit
            label.new(x = foundEntryBar, y = aPrice, text = 'Entry', style = isBullish ? label.style_label_up : label.style_label_down, textcolor = color.white, color = entryLineColor, size = entryLabelSize)

            int lineStart = math.max(foundEntryBar - 5, 0)

            stopLine := line.new(x1 = lineStart, y1 = cPrice, x2 = bar_index, y2 = cPrice, color = stopLineColor, width = stopLineWidth)
            tp1Line := line.new(x1 = lineStart, y1 = bPrice, x2 = bar_index, y2 = bPrice, color = tpLineColor, width = tpLineWidth)
            tp2Line := line.new(x1 = lineStart, y1 = dPrice, x2 = bar_index, y2 = dPrice, color = tpLineColor, width = tpLineWidth)

            stopTextLabel := label.new(x = f_mid(lineStart, bar_index), y = cPrice, text = 'Stop Level', style = label.style_none, textcolor = stopLineColor, color = color.new(color.white, 100), size = stopTextSize)
            tp1TextLabel := label.new(x = f_mid(lineStart, bar_index), y = bPrice, text = 'TP-1', style = label.style_none, textcolor = tpLineColor, color = color.new(color.white, 100), size = tpTextSize)
            tp2TextLabel := label.new(x = f_mid(lineStart, bar_index), y = dPrice, text = 'TP-2', style = label.style_none, textcolor = tpLineColor, color = color.new(color.white, 100), size = tpTextSize)

            bool stopAlreadyHit = false
            bool tp1AlreadyHit = false
            bool tp2AlreadyHit = false
            int terminalBar = na

            if bar_index > foundEntryBar
                for j = foundEntryBar + 1 to bar_index
                    int offset = bar_index - j

                    bool tp1HitNow = not tp1AlreadyHit and f_hit_at(bPrice, offset)
                    bool stopHitNow = not stopAlreadyHit and f_hit_at(cPrice, offset)
                    bool tp2HitNow = not tp2AlreadyHit and f_hit_at(dPrice, offset)

                    if tp1HitNow
                        tp1AlreadyHit := true
                        tp1AlreadyDone := true
                        if not na(tp1Line)
                            line.set_x2(tp1Line, j)

                    if stopHitNow
                        stopAlreadyHit := true
                        if na(terminalBar)
                            terminalBar := j
                            string stopText = tp1AlreadyDone ? 'TP-1 hit then stopped out' : 'Stopped out'
                            label.new(x = cBar, y = f_result_y(cPrice, isBullish), text = stopText, style = f_result_style(isBullish), textcolor = color.white, color = stopLineColor, size = resultLabelSize)

                            if not tp1AlreadyDone
                                if not na(stopLine)
                                    line.delete(stopLine)
                                    stopLine := na
                                if not na(tp1Line)
                                    line.delete(tp1Line)
                                    tp1Line := na
                                if not na(tp2Line)
                                    line.delete(tp2Line)
                                    tp2Line := na
                                if not na(stopTextLabel)
                                    label.delete(stopTextLabel)
                                    stopTextLabel := na
                                if not na(tp1TextLabel)
                                    label.delete(tp1TextLabel)
                                    tp1TextLabel := na
                                if not na(tp2TextLabel)
                                    label.delete(tp2TextLabel)
                                    tp2TextLabel := na

                    if tp2HitNow
                        tp2AlreadyHit := true
                        if na(terminalBar)
                            terminalBar := j
                            label.new(x = cBar, y = f_result_y(cPrice, isBullish), text = 'Take Profit Hit', style = f_result_style(isBullish), textcolor = color.white, color = tpLineColor, size = resultLabelSize)

            if not na(terminalBar)
                if not na(stopLine)
                    line.set_x2(stopLine, terminalBar)
                if not na(tp1Line) and not tp1AlreadyHit
                    line.set_x2(tp1Line, terminalBar)
                if not na(tp2Line)
                    line.set_x2(tp2Line, terminalBar)
                patternIsActive := false

            stopIsActive := patternIsActive and not stopAlreadyHit
            tp1IsActive := patternIsActive and not tp1AlreadyHit
            tp2IsActive := patternIsActive and not tp2AlreadyHit

        if timedOutAlready
            line.new(x1 = aBar, y1 = aPrice, x2 = dBar, y2 = aPrice, color = entryLineColor, width = entryLineWidth)
            label.new(x = cBar, y = f_result_y(cPrice, isBullish), text = 'Pattern expired', style = f_result_style(isBullish), textcolor = color.white, color = timeoutColor, size = resultLabelSize)

        entryLines.push(entryLine)
        stopLines.push(stopLine)
        tp1Lines.push(tp1Line)
        tp2Lines.push(tp2Line)

        entryTextLabels.push(entryTextLabel)
        stopTextLabels.push(stopTextLabel)
        tp1TextLabels.push(tp1TextLabel)
        tp2TextLabels.push(tp2TextLabel)

        entryPrices.push(aPrice)
        stopPrices.push(cPrice)
        tp1Prices.push(bPrice)
        tp2Prices.push(dPrice)
        patternCPrice.push(cPrice)

        patternABar.push(aBar)
        patternDBar.push(dBar)
        patternCBar.push(cBar)
        entryBarArr.push(foundEntryBar)

        patternIsBullish.push(isBullish)
        patternActive.push(patternIsActive)
        entryActive.push(not entryAlreadyHit and not timedOutAlready)
        entryDone.push(entryAlreadyHit)
        stopActive.push(stopIsActive)
        tp1Active.push(tp1IsActive)
        tp2Active.push(tp2IsActive)
        tp1Done.push(tp1AlreadyDone)
        timeoutDone.push(timedOutAlready)


if patternActive.size() > 0
    for i = 0 to patternActive.size() - 1
        bool pActive = patternActive.get(i)

        if pActive
            bool isBullish = patternIsBullish.get(i)

            int aBarCheck = patternABar.get(i)
            int dBarCheck = patternDBar.get(i)
            int cBarCheck = patternCBar.get(i)
            float cPriceCheck = patternCPrice.get(i)

            float entryLvl = entryPrices.get(i)
            float stopLvl = stopPrices.get(i)
            float tp1Lvl = tp1Prices.get(i)
            float tp2Lvl = tp2Prices.get(i)

            bool eDone = entryDone.get(i)
            bool timedOut = not eDone and bar_index > dBarCheck + entryTimeoutBars

            if timedOut and not timeoutDone.get(i)
                if not na(entryLines.get(i))
                    line.delete(entryLines.get(i))
                if not na(entryTextLabels.get(i))
                    label.delete(entryTextLabels.get(i))

                line.new(x1 = aBarCheck, y1 = entryLvl, x2 = dBarCheck, y2 = entryLvl, color = entryLineColor, width = entryLineWidth)

                label.new(x = cBarCheck, y = f_result_y(cPriceCheck, isBullish), text = 'Pattern expired', style = f_result_style(isBullish), textcolor = color.white, color = timeoutColor, size = resultLabelSize)

                entryActive.set(i, false)
                stopActive.set(i, false)
                tp1Active.set(i, false)
                tp2Active.set(i, false)
                patternActive.set(i, false)
                timeoutDone.set(i, true)

            if not timedOut
                bool afterD = bar_index > dBarCheck
                bool entryHit = afterD and not eDone and f_hit(entryLvl)

                if entryActive.get(i)
                    line lnEntry = entryLines.get(i)
                    label lbEntryText = entryTextLabels.get(i)

                    if not na(lnEntry)
                        line.set_x2(lnEntry, bar_index)
                        line.set_y2(lnEntry, entryLvl)

                    if not na(lbEntryText) and not na(lnEntry)
                        label.set_x(lbEntryText, f_mid(line.get_x1(lnEntry), bar_index))
                        label.set_y(lbEntryText, entryLvl)
                        label.set_text(lbEntryText, 'Entry')
                        label.set_textcolor(lbEntryText, entryLineColor)
                        label.set_color(lbEntryText, color.new(color.white, 100))
                        label.set_style(lbEntryText, label.style_none)
                        label.set_size(lbEntryText, entryTextSize)

                    if entryHit
                        if not na(lnEntry)
                            line.set_x2(lnEntry, bar_index)
                            line.set_y2(lnEntry, entryLvl)

                        if not na(lbEntryText) and not na(lnEntry)
                            label.set_x(lbEntryText, f_mid(line.get_x1(lnEntry), bar_index))
                            label.set_y(lbEntryText, entryLvl)

                        label.new(x = bar_index, y = entryLvl, text = 'Entry', style = isBullish ? label.style_label_up : label.style_label_down, textcolor = color.white, color = entryLineColor, size = entryLabelSize)

                        entryActive.set(i, false)
                        entryDone.set(i, true)
                        entryBarArr.set(i, bar_index)

                        int lineStart = math.max(bar_index - 5, 0)

                        line newStopLine = line.new(x1 = lineStart, y1 = stopLvl, x2 = bar_index, y2 = stopLvl, color = stopLineColor, width = stopLineWidth)
                        line newTP1Line = line.new(x1 = lineStart, y1 = tp1Lvl, x2 = bar_index, y2 = tp1Lvl, color = tpLineColor, width = tpLineWidth)
                        line newTP2Line = line.new(x1 = lineStart, y1 = tp2Lvl, x2 = bar_index, y2 = tp2Lvl, color = tpLineColor, width = tpLineWidth)

                        label newStopText = label.new(x = f_mid(lineStart, bar_index), y = stopLvl, text = 'Stop Level', style = label.style_none, textcolor = stopLineColor, color = color.new(color.white, 100), size = stopTextSize)
                        label newTP1Text = label.new(x = f_mid(lineStart, bar_index), y = tp1Lvl, text = 'TP-1', style = label.style_none, textcolor = tpLineColor, color = color.new(color.white, 100), size = tpTextSize)
                        label newTP2Text = label.new(x = f_mid(lineStart, bar_index), y = tp2Lvl, text = 'TP-2', style = label.style_none, textcolor = tpLineColor, color = color.new(color.white, 100), size = tpTextSize)

                        stopLines.set(i, newStopLine)
                        tp1Lines.set(i, newTP1Line)
                        tp2Lines.set(i, newTP2Line)

                        stopTextLabels.set(i, newStopText)
                        tp1TextLabels.set(i, newTP1Text)
                        tp2TextLabels.set(i, newTP2Text)

                        stopActive.set(i, true)
                        tp1Active.set(i, true)
                        tp2Active.set(i, true)

                eDone := entryDone.get(i)

                if eDone
                    int eBar = entryBarArr.get(i)
                    bool afterEntry = not na(eBar) and bar_index > eBar

                    bool stopHit = afterEntry and stopActive.get(i) and f_hit(stopLvl)
                    bool tp1Hit = afterEntry and tp1Active.get(i) and f_hit(tp1Lvl)
                    bool tp2Hit = afterEntry and tp2Active.get(i) and f_hit(tp2Lvl)

                    bool closeAll = stopHit or tp2Hit

                    if stopActive.get(i)
                        line lnStop = stopLines.get(i)
                        label lbStop = stopTextLabels.get(i)

                        if not na(lnStop)
                            line.set_x2(lnStop, bar_index)
                            line.set_y2(lnStop, stopLvl)

                        if not na(lbStop) and not na(lnStop)
                            label.set_x(lbStop, f_mid(line.get_x1(lnStop), bar_index))
                            label.set_y(lbStop, stopLvl)
                            label.set_size(lbStop, stopTextSize)

                        if stopHit
                            string stopText = tp1Done.get(i) ? 'TP-1 hit then stopped out' : 'Stopped out'
                            label.new(x = cBarCheck, y = f_result_y(cPriceCheck, isBullish), text = stopText, style = f_result_style(isBullish), textcolor = color.white, color = stopLineColor, size = resultLabelSize)

                            if not tp1Done.get(i)
                                if not na(stopLines.get(i))
                                    line.delete(stopLines.get(i))
                                    stopLines.set(i, na)
                                if not na(tp1Lines.get(i))
                                    line.delete(tp1Lines.get(i))
                                    tp1Lines.set(i, na)
                                if not na(tp2Lines.get(i))
                                    line.delete(tp2Lines.get(i))
                                    tp2Lines.set(i, na)
                                if not na(stopTextLabels.get(i))
                                    label.delete(stopTextLabels.get(i))
                                    stopTextLabels.set(i, na)
                                if not na(tp1TextLabels.get(i))
                                    label.delete(tp1TextLabels.get(i))
                                    tp1TextLabels.set(i, na)
                                if not na(tp2TextLabels.get(i))
                                    label.delete(tp2TextLabels.get(i))
                                    tp2TextLabels.set(i, na)

                        if stopHit or closeAll
                            stopActive.set(i, false)

                    if tp1Active.get(i)
                        line lnTP1 = tp1Lines.get(i)
                        label lbTP1 = tp1TextLabels.get(i)

                        if not na(lnTP1)
                            line.set_x2(lnTP1, bar_index)
                            line.set_y2(lnTP1, tp1Lvl)

                        if not na(lbTP1) and not na(lnTP1)
                            label.set_x(lbTP1, f_mid(line.get_x1(lnTP1), bar_index))
                            label.set_y(lbTP1, tp1Lvl)
                            label.set_size(lbTP1, tpTextSize)

                        if tp1Hit
                            tp1Done.set(i, true)
                            tp1Active.set(i, false)

                        if closeAll
                            tp1Active.set(i, false)

                    if tp2Active.get(i)
                        line lnTP2 = tp2Lines.get(i)
                        label lbTP2 = tp2TextLabels.get(i)

                        if not na(lnTP2)
                            line.set_x2(lnTP2, bar_index)
                            line.set_y2(lnTP2, tp2Lvl)

                        if not na(lbTP2) and not na(lnTP2)
                            label.set_x(lbTP2, f_mid(line.get_x1(lnTP2), bar_index))
                            label.set_y(lbTP2, tp2Lvl)
                            label.set_size(lbTP2, tpTextSize)

                        if tp2Hit
                            label.new(x = cBarCheck, y = f_result_y(cPriceCheck, isBullish), text = 'Take Profit Hit', style = f_result_style(isBullish), textcolor = color.white, color = tpLineColor, size = resultLabelSize)

                        if tp2Hit or closeAll
                            tp2Active.set(i, false)

                    if closeAll
                        if stopActive.get(i) and not na(stopLines.get(i))
                            line.set_x2(stopLines.get(i), bar_index)
                            line.set_y2(stopLines.get(i), stopLvl)

                        if tp1Active.get(i) and not na(tp1Lines.get(i))
                            line.set_x2(tp1Lines.get(i), bar_index)
                            line.set_y2(tp1Lines.get(i), tp1Lvl)

                        if tp2Active.get(i) and not na(tp2Lines.get(i))
                            line.set_x2(tp2Lines.get(i), bar_index)
                            line.set_y2(tp2Lines.get(i), tp2Lvl)

                        stopActive.set(i, false)
                        tp1Active.set(i, false)
                        tp2Active.set(i, false)
                        patternActive.set(i, false)

alertcondition(
     bullishQM,
     title = 'Bullish Quasimodo Detected',
     message = 'Bullish Quasimodo pattern detected.')

alertcondition(
     bearishQM,
     title = 'Bearish Quasimodo Detected',
     message = 'Bearish Quasimodo pattern detected.')

bool entryAlert =
     entryDone.size() > 0 and
     entryDone.last() and
     entryBarArr.last() == bar_index

alertcondition(
     entryAlert,
     title = 'Entry Triggered',
     message = 'Entry level triggered.')

bool tp1Alert =
     tp1Done.size() > 0 and
     tp1Done.last() and
     tp1Active.size() > 0 and
     not tp1Active.last()

alertcondition(
     tp1Alert,
     title = 'TP-1 Hit',
     message = 'TP-1 level reached.')

bool tp2Alert =
     tp2Active.size() > 0 and
     not tp2Active.last() and
     patternActive.size() > 0 and
     not patternActive.last()

alertcondition(
     tp2Alert,
     title = 'Take Profit Hit',
     message = 'TP-2 level reached.')

bool stopAlert =
     stopActive.size() > 0 and
     not stopActive.last() and
     patternActive.size() > 0 and
     not patternActive.last()

alertcondition(
     stopAlert,
     title = 'Stopped out',
     message = 'Stop Level reached.')

bool expiredAlert =
     timeoutDone.size() > 0 and
     timeoutDone.last()

alertcondition(
     expiredAlert,
     title = 'Pattern expired',
     message = 'Pattern expired before entry.')

line.all.clean()
label.all.cleanLabels()
````
