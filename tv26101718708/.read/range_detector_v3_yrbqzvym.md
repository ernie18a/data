# Range Detector v3

- url: https://www.tradingview.com/script/YrBqzVYM-Range-Detector-v3/
- type: indicator
- pine_id: PUB;505bf1ec18b04e239e82db84cd22bb07
- version: 1.0

## Description

range detector v3 is a technical range detection tool designed to identify periods of market consolidation, evaluate their quality, map the internal structure of a range, and detect confirmed breakouts and retests.

the script uses a five-factor confirmation model built around adx, choppiness, bollinger bandwidth, bollinger/keltner compression, and linear regression slope. instead of defining a range from a single condition, it requires multiple factors to agree before a structure can become confirmed.

detection options

adx length
controls the calculation period used for adx.

adx ceiling
defines the maximum adx value accepted as a ranging condition. lower adx generally represents weaker directional movement.

choppiness length
sets the calculation period for the choppiness index.

choppiness floor
defines the minimum choppiness value required for the factor to qualify as a ranging condition.

bb / kc length
controls the calculation length used by the bollinger bands and keltner channel.

bollinger mult
adjusts the width of the bollinger bands.

keltner mult
adjusts the width of the keltner channel.

bandwidth percentile ceiling
measures the current bollinger bandwidth relative to its recent 100-bar range. lower values require stronger volatility compression.

linear regression length
sets the period used to calculate the regression slope.

slope ceiling
defines how flat price must be in atr-per-bar terms for the slope factor to qualify.

confirmation options

factors required
selects how many of the five detection factors must agree. the script can require between two and five factors.

confirmed bars needed
controls how long the required factor confluence must persist.

minimum range length
prevents very short structures from being immediately classified as confirmed ranges.

maximum range length
limits how long an active range can remain open before it is archived.

max historical ranges kept
controls the number of completed historical ranges displayed and retained by the indicator.

breakout and retest options

detect breakouts
enables breakout detection above or below a confirmed range.

a breakout is not based only on price crossing a rail. the script also evaluates candle displacement and relative volume participation.

break displacement
sets the minimum candle body size relative to atr required for breakout confirmation.

break participation
sets the minimum relative volume required for a breakout.

detect retests
enables detection of price returning to a previously broken range boundary.

retest lookback
defines how many bars after a breakout remain eligible for retest detection.

range analytics

quartile lines
displays the internal 25%, 50%, and 75% levels of a confirmed range.

these levels can help visualize where price is trading inside the structure rather than treating the entire range as a single zone.

volume poc of the range
calculates an estimated volume point of control inside the range by distributing bar volume according to price bins.

poc bins
controls the resolution used for the range poc calculation.

premium / discount split
divides the active range around its midpoint to provide a simple visual representation of its upper premium and lower discount areas.

visual options

the script includes institutional cyan, neon wizard, and obsidian gold themes.

extend right controls how far the active range structure extends beyond the current bar.

range labels displays information directly on the active range.

live range readout shows the current price position as a percentage of the confirmed range.

dashboard

the dashboard provides a compact view of the current detection state and underlying conditions.

it displays:

state
range quality
active factors
adx
choppiness
bollinger bandwidth condition
compression state
regression slope
range size
current location inside the range
distance from the upper and lower rails
relative volume participation
range age and rail touches
last breakout
last retest
range history
active detection model

the dashboard position and text size can be adjusted from the indicator settings.

quick start

add the indicator to a chart and begin with the default settings.

when the state is idle, the required range conditions are not currently established.

when the state changes to candidate, the detection factors have started to align, but the structure has not yet completed the required confirmation process.

when confirmed appears, the required factor confluence and minimum structural conditions have been satisfied.

the upper and lower rails define the detected range boundaries. use the quartiles, midpoint, poc, premium/discount zones, and live position readout to evaluate where price is trading inside that structure.

if price leaves the range, the breakout engine checks displacement and relative volume before registering a range break.

after a confirmed break, the retest engine can identify a return to the broken rail when the configured conditions are satisfied.

for stricter detection, increase the number of required factors, increase the confirmation period, or tighten the individual factor thresholds.

for more responsive detection, reduce the confirmation requirements while understanding that this can increase the number of detected structures.

how the script can help

range detector v3 is designed to make consolidation structures easier to identify and analyze.

it can help distinguish compressed or non-directional market conditions from stronger directional environments, visualize the boundaries and internal structure of a consolidation, track where price is positioned inside a confirmed range, identify displacement-based range breaks with volume participation, and monitor subsequent retests.

it can also be used as contextual information alongside other trading methods. for example, traders can use the detected rails, midpoint, quartiles, poc, premium/discount areas, breakout events, and retests as additional structural references when building their own setups.

the script also exposes hidden outputs for range high, range low, range state, factor score, adx, choppiness, bandwidth percentile, and slope, and includes alert conditions for range confirmation, bullish and bearish range breaks, and bullish and bearish retests.

range detector v3 is an analytical tool. its signals describe conditions detected by the configured model and should not be interpreted as guaranteed trade outcomes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6

indicator("RANGE DETECTOR v3",

     overlay = true,

     max_boxes_count  = 500,

     max_lines_count  = 500,

     max_labels_count = 500)

const string G1 = "🔬  DETECTION FACTORS"

const string G2 = "✅  CONFIRMATION"

const string G3 = "💥  BREAKOUT / RETEST"

const string G4 = "📊  ANALYTICS"

const string G5 = "🎨  VISUALS"

const string G6 = "🖥️  DASHBOARD"

int    adxLen      = input.int(14, "ADX Length", minval = 5, group = G1)

float  adxMax      = input.float(20.0, "ADX ceiling (< = range)", minval = 5.0, step = 1.0, group = G1)

int    chopLen     = input.int(14, "Choppiness Length", minval = 5, group = G1)

float  chopMin     = input.float(61.8, "Choppiness floor (> = range)", minval = 40.0, step = 0.1, group = G1)

int    bbLen       = input.int(20, "BB / KC Length", minval = 5, group = G1)

float  bbMult      = input.float(2.0, "Bollinger Mult", minval = 0.5, step = 0.1, group = G1)

float  kcMult      = input.float(1.5, "Keltner Mult", minval = 0.5, step = 0.1, group = G1)

float  bwPctMax    = input.float(0.25, "BandWidth percentile ceiling", minval = 0.05, maxval = 0.5, step = 0.05, group = G1, tooltip = "BB width must be in the lower N of its 100-bar range to count as compressed.")

int    lrLen       = input.int(20, "Linear Regression Length", minval = 5, group = G1)

float  slopeMax    = input.float(0.15, "|slope| ceiling (ATR/bar)", minval = 0.02, step = 0.01, group = G1)

int    confirmFactors = input.int(3, "Factors required (of 5)", minval = 2, maxval = 5, group = G2)

int    confirmBars    = input.int(5, "Confirmed bars needed", minval = 2, maxval = 20, group = G2)

int    minRangeBars   = input.int(10, "Minimum range length (bars)", minval = 3, group = G2)

int    maxRangeBars   = input.int(400, "Maximum range length (bars)", minval = 40, group = G2)

int    maxHistory     = input.int(6, "Max historical ranges kept", minval = 1, maxval = 12, group = G2)

bool   detectBreak  = input.bool(true, "Detect Breakouts", group = G3)

float  dispMult     = input.float(0.60, "Break displacement (body ATR x)", minval = 0.1, step = 0.05, group = G3)

float  volMult      = input.float(1.15, "Break participation (relative volume)", minval = 0.5, step = 0.05, group = G3)

bool   detectRet    = input.bool(true, "Detect Retests", group = G3)

int    retLookback  = input.int(25, "Retest lookback (bars)", minval = 3, group = G3)

bool   showQuart    = input.bool(true, "Quartile Lines (25 / 50 / 75)", group = G4)

bool   showPoc      = input.bool(true, "Volume POC of the Range", group = G4)

int    pocBins      = input.int(24, "POC Bins", minval = 8, maxval = 48, group = G4)

bool   showPd       = input.bool(true, "Premium / Discount Split", group = G4)

string themeSel     = input.string("Institutional Cyan", "Theme", options = ["Institutional Cyan", "Neon Wizard", "Obsidian Gold"], group = G5)

int    extendR      = input.int(4, "Extend Right (bars)", minval = 0, group = G5)

bool   showLbl      = input.bool(true, "Range Labels", group = G5)

bool   showLive     = input.bool(true, "Live Live-Range Readout", group = G5)

string dashPos      = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = G6)

string dashSize     = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = G6)

bool   showDash     = input.bool(true, "Show Dashboard", group = G6)

bool  isCyan = themeSel == "Institutional Cyan"

bool  isNeon = themeSel == "Neon Wizard"

bool  isGold = themeSel == "Obsidian Gold"

color cRng   = isCyan ? #00D9FF : isNeon ? #00FFD1 : #FFD23F

color cUp    = isCyan ? #26E5B0 : isNeon ? #00FFD1 : #26E5B0

color cDn    = isCyan ? #FF4E6A : isNeon ? #FF3B5C : #FF4E6A

color cGold  = isCyan ? #FFD23F : isNeon ? #FFD23F : #FFB800

color cSoft  = #8A93A6

color BGD    = #0A0E14

color pBg      = #0B0F14

color pHeader  = #111820

color pCell    = #0E141B

color pBorder  = #293541

color pText    = #D7DEE7

color pMuted   = #7E8A99

color pBull    = #43B59E

color pBear    = #C96978

color pGold    = #C7A96B

color pBlue    = #829DB8

float atrV   = ta.atr(14)

float volSma = ta.sma(volume, 50)

float rvol   = volSma > 0 ? volume / volSma : 1.0

[diPlus, diMinus, adxV] = ta.dmi(adxLen, adxLen)

float atrSum = math.sum(ta.tr(true), chopLen)

float hhCh   = ta.highest(high, chopLen)

float llCh   = ta.lowest(low,  chopLen)

float chopV  = hhCh > llCh ? 100.0 * math.log10(atrSum / (hhCh - llCh)) / math.log10(chopLen) : 50.0

float basis  = ta.sma(close, bbLen)

float dev    = bbMult * ta.stdev(close, bbLen)

float bbUp   = basis + dev

float bbDn   = basis - dev

float kcUp   = basis + kcMult * ta.atr(bbLen)

float kcDn   = basis - kcMult * ta.atr(bbLen)

bool  squeeze = bbUp < kcUp and bbDn > kcDn

float bbw    = basis != 0 ? (bbUp - bbDn) / basis : 0.0

float bbwMin = ta.lowest(bbw, 100)

float bbwMax = ta.highest(bbw, 100)

float bbwPct = bbwMax > bbwMin ? (bbw - bbwMin) / (bbwMax - bbwMin) : 0.5

float lr0    = ta.linreg(close, lrLen, 0)

float lr1    = ta.linreg(close, lrLen, 1)

float slopeAtr = atrV > 0 ? (lr0 - lr1) / atrV : 0.0

bool fAdx   = adxV      <  adxMax

bool fChop  = chopV     >  chopMin

bool fBbw   = bbwPct    <  bwPctMax

bool fSqz   = squeeze

bool fSlope = math.abs(slopeAtr) < slopeMax

int score  = (fAdx ? 1 : 0) + (fChop ? 1 : 0) + (fBbw ? 1 : 0) + (fSqz ? 1 : 0) + (fSlope ? 1 : 0)

bool factorHit = score >= confirmFactors

var int   rL   = na            // left bar

var float rHi  = na            // upper rail

var float rLo  = na            // lower rail

var int   rSt  = 0             // 0 idle · 1 candidate · 2 confirmed · 3 broken

var int   rHold= 0             // consecutive factor-hit bars

var int   rTouch = 0           // rail touches (respect count)

var int[]   hL0  = array.new_int()

var int[]   hL1  = array.new_int()

var float[] hHi  = array.new_float()

var float[] hLo  = array.new_float()

var int[]   hBrk = array.new_int()      // +1 up broken, -1 down broken, 0 timed-out

var float[] hPoc = array.new_float()

var int   brkBar = na

var int   brkDir = 0

var float brkPx  = na

var int[]   evBar = array.new_int()

var int[]   evDir = array.new_int()

var float[] evPx  = array.new_float()

var int[]   rtBar = array.new_int()

var int[]   rtDir = array.new_int()

var float[] rtPx  = array.new_float()

var box[]   rBx = array.new<box>()

var line[]  rLn = array.new<line>()

var label[] rLb = array.new<label>()

f_txtSize(string s) =>

    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

f_dashPos(string s) =>

    s == "Top Right" ? position.top_right : s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : position.bottom_left

f_wipe() =>

    while array.size(rBx) > 0

        box.delete(array.pop(rBx))

    while array.size(rLn) > 0

        line.delete(array.pop(rLn))

    while array.size(rLb) > 0

        label.delete(array.pop(rLb))

f_pocOfRange(int b0, int b1, float top, float bot) =>

    float poc = (top + bot) / 2.0

    if b1 > b0 and top > bot and pocBins > 2

        float step = (top - bot) / pocBins

        float[] bins = array.new_float(pocBins, 0.0)

        int span = b1 - b0

        if span > 0 and span <= 500

            for k = 0 to span - 1

                int off = bar_index - b0 - k

                if off >= 0 and off < 500

                    float px = (high[off] + low[off]) / 2.0

                    float vv = volume[off]

                    if px >= bot and px <= top

                        int idx = int(math.min(pocBins - 1, (px - bot) / step))

                        array.set(bins, idx, array.get(bins, idx) + vv)

            float best = 0.0

            int bi = 0

            for k = 0 to pocBins - 1

                if array.get(bins, k) > best

                    best := array.get(bins, k)

                    bi := k

            poc := bot + (bi + 0.5) * step

    poc

f_pushHistory(int b0, int b1, float top, float bot, int brk) =>

    array.push(hL0, b0)

    array.push(hL1, b1)

    array.push(hHi, top)

    array.push(hLo, bot)

    array.push(hBrk, brk)

    array.push(hPoc, showPoc ? f_pocOfRange(b0, b1, top, bot) : na)

    while array.size(hL0) > maxHistory

        array.shift(hL0)

        array.shift(hL1)

        array.shift(hHi)

        array.shift(hLo)

        array.shift(hBrk)

        array.shift(hPoc)

bool evtConfirmed = false

bool evtBrkUp    = false

bool evtBrkDn    = false

bool evtRetUp    = false

bool evtRetDn    = false

if barstate.isconfirmed

    if rSt == 0

        if factorHit

            rSt   := 1

            rL    := bar_index

            rHold := 1

            rHi   := high

            rLo   := low

            rTouch := 0

        else

            rHold := 0

    else if rSt == 1

        if factorHit

            rHold := rHold + 1

            rHi := math.max(rHi, high)

            rLo := math.min(rLo, low)

            if rHold >= confirmBars and bar_index - rL >= minRangeBars

                rSt := 2

                evtConfirmed := true

        else

            rSt := 0

            rL  := na

            rHi := na

            rLo := na

            rHold := 0

    else if rSt == 2

        float tol = atrV * 0.15

        if high >= rHi - tol

            rTouch := rTouch + 1

        if low <= rLo + tol

            rTouch := rTouch + 1

        if high > rHi and high - rHi < atrV * 0.35

            rHi := high

        if low < rLo and rLo - low < atrV * 0.35

            rLo := low

        if detectBreak

            float body = math.abs(close - open)

            bool dispOK = body >= dispMult * atrV

            bool volOK  = rvol >= volMult

            if high > rHi and close > rHi and dispOK and volOK and close > open

                rSt := 3

                brkBar := bar_index

                brkDir := 1

                brkPx  := rHi

                evtBrkUp := true

                array.push(evBar, bar_index)

                array.push(evDir, 1)

                array.push(evPx, rHi)

                f_pushHistory(rL, bar_index, rHi, rLo, 1)

            else if low < rLo and close < rLo and dispOK and volOK and close < open

                rSt := 3

                brkBar := bar_index

                brkDir := -1

                brkPx  := rLo

                evtBrkDn := true

                array.push(evBar, bar_index)

                array.push(evDir, -1)

                array.push(evPx, rLo)

                f_pushHistory(rL, bar_index, rHi, rLo, -1)

        if rSt == 2 and bar_index - rL > maxRangeBars

            f_pushHistory(rL, bar_index, rHi, rLo, 0)

            rSt := 0

            rL := na

            rHi := na

            rLo := na

            rHold := 0

            rTouch := 0

    else if rSt == 3

        rSt := 0

        rL  := na

        rHi := na

        rLo := na

        rHold := 0

        rTouch := 0

    if detectRet and not na(brkBar) and bar_index - brkBar <= retLookback and bar_index - brkBar >= 2

        if brkDir == 1 and low <= brkPx and close > brkPx and close > open

            evtRetUp := true

            array.push(rtBar, bar_index)

            array.push(rtDir, 1)

            array.push(rtPx, brkPx)

        else if brkDir == -1 and high >= brkPx and close < brkPx and close < open

            evtRetDn := true

            array.push(rtBar, bar_index)

            array.push(rtDir, -1)

            array.push(rtPx, brkPx)

    while array.size(evBar) > 30

        array.shift(evBar)

        array.shift(evDir)

        array.shift(evPx)

    while array.size(rtBar) > 20

        array.shift(rtBar)

        array.shift(rtDir)

        array.shift(rtPx)

if barstate.islast

    f_wipe()

    int rt = bar_index + extendR

    int budget = 0

    int hsz = array.size(hL0)

    if hsz > 0

        for i = 0 to hsz - 1

            if budget < 470

                int b0 = array.get(hL0, i)

                int b1 = array.get(hL1, i)

                float top = array.get(hHi, i)

                float bot = array.get(hLo, i)

                int brk = array.get(hBrk, i)

                color hc = brk == 1 ? cUp : brk == -1 ? cDn : cSoft

                array.push(rBx, box.new(b0, top, b1, bot,

                     border_color = color.new(hc, 60),

                     border_width = 1,

                     border_style = line.style_solid,

                     bgcolor = color.new(hc, 92)))

                budget := budget + 1

                if showQuart

                    float mid = (top + bot) / 2.0

                    array.push(rLn, line.new(b0, mid, b1, mid, color = color.new(hc, 70), width = 1, style = line.style_dotted))

                    budget := budget + 1

                if showPoc and not na(array.get(hPoc, i))

                    float poc = array.get(hPoc, i)

                    array.push(rLn, line.new(b0, poc, b1, poc, color = color.new(cGold, 40), width = 1, style = line.style_dashed))

                    budget := budget + 1

    if rSt >= 1 and not na(rL) and not na(rHi) and not na(rLo)

        color ac  = rSt == 1 ? cSoft : cRng

        int   bw  = rSt == 2 ? 2 : 1

        bst = rSt == 1 ? line.style_dashed : line.style_solid

        array.push(rBx, box.new(rL, rHi, rt, rLo,

             border_color = color.new(ac, 25),

             border_width = bw,

             border_style = bst,

             bgcolor = color.new(ac, 90)))

        budget := budget + 1

        array.push(rLn, line.new(rL, rHi, rt, rHi, color = color.new(ac, 15), width = bw))

        array.push(rLn, line.new(rL, rLo, rt, rLo, color = color.new(ac, 15), width = bw))

        budget := budget + 2

        float mid = (rHi + rLo) / 2.0

        if showPd

            array.push(rBx, box.new(rL, rHi, rt, mid, border_color = na, bgcolor = color.new(cDn, 96)))

            array.push(rBx, box.new(rL, mid, rt, rLo, border_color = na, bgcolor = color.new(cUp, 96)))

            budget := budget + 2

        if showQuart and rSt == 2

            float q1 = rLo + (rHi - rLo) * 0.25

            float q3 = rLo + (rHi - rLo) * 0.75

            array.push(rLn, line.new(rL, mid, rt, mid, color = color.new(cGold, 30), width = 1, style = line.style_dashed))

            array.push(rLn, line.new(rL, q1, rt, q1, color = color.new(cSoft, 60), width = 1, style = line.style_dotted))

            array.push(rLn, line.new(rL, q3, rt, q3, color = color.new(cSoft, 60), width = 1, style = line.style_dotted))

            budget := budget + 3

        if showPoc and rSt == 2

            float poc = f_pocOfRange(rL, bar_index, rHi, rLo)

            array.push(rLn, line.new(rL, poc, rt, poc, color = color.new(cGold, 15), width = 2, style = line.style_solid))

            array.push(rLb, label.new(rt, poc, "POC  " + str.tostring(poc, format.mintick), style = label.style_label_left, color = color.new(BGD, 100), textcolor = color.new(cGold, 10), size = size.tiny))

            budget := budget + 2

        if showLbl

            string tag = rSt == 1 ? "◐ CANDIDATE" : "◉ RANGE " + str.tostring(bar_index - rL) + "b"

            array.push(rLb, label.new(rt, rHi, tag + "  " + str.tostring(rHi, format.mintick), style = label.style_label_left, color = color.new(BGD, 15), textcolor = color.new(ac, 5), size = size.tiny))

            array.push(rLb, label.new(rt, rLo, str.tostring(rLo, format.mintick), style = label.style_label_left, color = color.new(BGD, 15), textcolor = color.new(ac, 20), size = size.tiny))

            budget := budget + 2

    int esz = array.size(evBar)

    if esz > 0

        for i = 0 to esz - 1

            int b = array.get(evBar, i)

            int age = bar_index - b

            if age <= 30 and budget < 480

                int d = array.get(evDir, i)

                float px = array.get(evPx, i)

                color fc = d == 1 ? cUp : cDn

                for k = 1 to 3

                    int wd = k * 3

                    array.push(rLn, line.new(b - wd, px, b + wd, px, color = color.new(fc, 45 + age * 2 + k * 10), width = 1))

                    budget := budget + 1

                array.push(rLn, line.new(b, px - atrV * 0.5, b, px + atrV * 0.5, color = color.new(fc, 30 + age * 2), width = 2))

                array.push(rLb, label.new(b, d == 1 ? px + atrV * 0.8 : px - atrV * 0.8, d == 1 ? "▲ RANGE BREAK" : "▼ RANGE BREAK", style = d == 1 ? label.style_label_down : label.style_label_up, color = color.new(BGD, 15), textcolor = fc, size = size.small))

                budget := budget + 2

    if detectRet

        int rsz = array.size(rtBar)

        if rsz > 0

            for i = 0 to rsz - 1

                int b = array.get(rtBar, i)

                int age = bar_index - b

                if age <= 40 and budget < 490

                    int d = array.get(rtDir, i)

                    float px = array.get(rtPx, i)

                    color fc = d == 1 ? cUp : cDn

                    array.push(rLb, label.new(b, px, "◆ RETEST", style = d == 1 ? label.style_label_up : label.style_label_down, color = color.new(BGD, 30), textcolor = color.new(fc, 15), size = size.tiny))

                    budget := budget + 1

    if showLive and rSt == 2 and not na(rHi) and not na(rLo)

        float pos = (rHi - rLo) > 0 ? (close - rLo) / (rHi - rLo) * 100.0 : na

        color rc = na(pos) ? cSoft : pos >= 75 ? cDn : pos <= 25 ? cUp : cGold

        array.push(rLb, label.new(bar_index + 1, close, "◆ " + (na(pos) ? "—" : str.tostring(pos, "#.#") + "%"), style = label.style_label_left, color = color.new(BGD, 20), textcolor = rc, size = size.small))

var table tb = table.new(

     f_dashPos(dashPos), 2, 18,

     bgcolor = pBg,

     frame_width = 1,

     frame_color = pBorder,

     border_width = 1,

     border_color = color.new(pBorder, 25))

if barstate.islast

    if showDash

        string ts = dashSize

        string stTxt = rSt == 0 ? "⚪ IDLE" : rSt == 1 ? "🟡 CANDIDATE" : rSt == 2 ? "🟢 CONFIRMED" : "🔴 BROKEN"

        color stC = rSt == 0 ? pMuted : rSt == 1 ? pGold : rSt == 2 ? pBull : brkDir == 1 ? pBull : pBear

        float rangeWidth = not na(rHi) and not na(rLo) ? rHi - rLo : na

        float widthAtr = not na(rangeWidth) and atrV > 0 ? rangeWidth / atrV : na

        string rwTxt = na(rangeWidth) ? "NO ACTIVE RANGE" : str.tostring(rangeWidth, format.mintick) + " · " + str.tostring(widthAtr, "#.##") + " ATR"

        float livePos = rSt == 2 and not na(rHi) and not na(rLo) and rHi > rLo ? (close - rLo) / (rHi - rLo) * 100.0 : na

        string zoneTxt = na(livePos) ? "WAITING FOR RANGE" : livePos >= 75 ? "🔴 PREMIUM HIGH" : livePos >= 50 ? "🟠 PREMIUM" : livePos <= 25 ? "🟢 DISCOUNT LOW" : "🔵 DISCOUNT"

        color zoneC = na(livePos) ? pMuted : livePos >= 75 ? pBear : livePos >= 50 ? pGold : livePos <= 25 ? pBull : pBlue

        float dTopAtr = rSt == 2 and not na(rHi) and atrV > 0 ? (rHi - close) / atrV : na

        float dBotAtr = rSt == 2 and not na(rLo) and atrV > 0 ? (close - rLo) / atrV : na

        string distTxt = na(dTopAtr) or na(dBotAtr) ? "NO ACTIVE RAILS" : "↑ " + str.tostring(dTopAtr, "#.##") + " · ↓ " + str.tostring(dBotAtr, "#.##") + " ATR"

        int qualityPct = int(math.round(score / 5.0 * 100.0))

        string qualTxt = score >= 5 ? "🟢 VERY STRONG" : score >= 4 ? "🟢 STRONG" : score >= confirmFactors ? "🟡 VALID" : "⚪ BUILDING"

        color qualC = score >= 4 ? pBull : score >= confirmFactors ? pGold : pMuted

        string compTxt = fSqz ? "⚡ SQUEEZE" : fBbw ? "🟡 COMPRESSED" : "⚪ OPEN"

        color compC = fSqz ? pGold : fBbw ? pBlue : pMuted

        string slopeTxt = fSlope ? "➖ FLAT" : slopeAtr > 0 ? "📈 RISING" : "📉 FALLING"

        color slopeC = fSlope ? pBull : slopeAtr > 0 ? pGold : pGold

        string adxTxt = str.tostring(adxV, "#.#") + (fAdx ? " ✅" : " ❌")

        string chopTxt = str.tostring(chopV, "#.#") + (fChop ? " ✅" : " ❌")

        string bbwTxt = str.tostring(bbwPct * 100.0, "#") + "%" + (fBbw ? " ✅" : " ❌")

        string rvolTxt = "×" + str.tostring(rvol, "#.##") + (rvol >= volMult ? " ✅" : " ⚪")

        color rvolC = rvol >= volMult ? pBull : pMuted

        string breakTxt = na(brkBar) ? "NONE YET" :

             (brkDir == 1 ? "▲ " : "▼ ") +

             str.tostring(bar_index - brkBar) + "b · " +

             str.tostring(brkPx, format.mintick)

        color breakC = na(brkBar) ? pMuted : brkDir == 1 ? pBull : pBear

        string retTxt = "NONE YET"

        color retC = pMuted

        int rtSz = array.size(rtBar)

        if rtSz > 0

            int lastRt = rtSz - 1

            int rtB = array.get(rtBar, lastRt)

            int rtD = array.get(rtDir, lastRt)

            float rtP = array.get(rtPx, lastRt)

            retTxt := (rtD == 1 ? "▲ " : "▼ ") + str.tostring(bar_index - rtB) + "b · " + str.tostring(rtP, format.mintick)

            retC := rtD == 1 ? pBull : pBear

        string ageTxt = rSt >= 1 and not na(rL) ? str.tostring(bar_index - rL) + " bars" : "NO ACTIVE RANGE"

        string touchTxt = rSt == 2 ? str.tostring(rTouch) + " touches" : rSt == 1 ? "CANDIDATE" : "NO CONFIRMED RANGE"

        table.cell(tb, 0, 0, "🏛️ RANGE DESK", text_color = pText, text_size = f_txtSize(ts), bgcolor = pHeader)

        table.cell(tb, 1, 0, "INSTITUTIONAL", text_color = pGold, text_size = size.tiny, bgcolor = pHeader)

        table.cell(tb, 0, 1, "🧭 STATE", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 1, stTxt, text_color = stC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 2, "🏅 QUALITY", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 2, qualTxt + " · " + str.tostring(qualityPct) + "%", text_color = qualC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 3, "🧮 FACTORS", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 3, str.tostring(score) + " / 5 · need " + str.tostring(confirmFactors), text_color = factorHit ? pBull : pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 4, "📉 ADX", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 4, adxTxt + " < " + str.tostring(adxMax, "#.#"), text_color = fAdx ? pBull : pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 5, "🌀 CHOP", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 5, chopTxt + " > " + str.tostring(chopMin, "#.#"), text_color = fChop ? pBull : pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 6, "📦 BB WIDTH", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 6, bbwTxt, text_color = fBbw ? pBull : pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 7, "⚡ COMPRESSION", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 7, compTxt, text_color = compC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 8, "📐 SLOPE", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 8, slopeTxt + " · " + str.tostring(math.abs(slopeAtr), "#.##") + " ATR/b", text_color = slopeC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 9, "📏 RANGE SIZE", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 9, rwTxt, text_color = pBlue, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 10, "🎯 LOCATION", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 10, zoneTxt + (na(livePos) ? "" : " · " + str.tostring(livePos, "#.#") + "%"), text_color = zoneC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 11, "↕️ RAIL DIST", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 11, distTxt, text_color = pBlue, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 12, "📊 PARTICIPATION", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 12, rvolTxt, text_color = rvolC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 13, "🕒 AGE / RESPECT", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 13, ageTxt + " · " + touchTxt, text_color = pGold, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 14, "💥 LAST BREAK", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 14, breakTxt, text_color = breakC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 15, "🔁 LAST RETEST", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 15, retTxt, text_color = retC, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 16, "🗂️ HISTORY", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 16, array.size(hL0) == 0 ? "0 / " + str.tostring(maxHistory) + " · NO HISTORY YET" : str.tostring(array.size(hL0)) + " / " + str.tostring(maxHistory) + " ranges", text_color = pBlue, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 0, 17, "✅ MODEL", text_color = pMuted, text_size = f_txtSize(ts), bgcolor = pCell)

        table.cell(tb, 1, 17, "ADX · CHOP · BBW · SQZ · SLOPE", text_color = pGold, text_size = size.tiny, bgcolor = pCell)

    else

        table.clear(tb, 0, 0, 1, 17)

alertcondition(evtConfirmed, "Range Confirmed",   "RANGE DETECTOR: new range confirmed — 5-factor confluence held for N bars.")

alertcondition(evtBrkUp,     "Range Break ▲",     "RANGE DETECTOR: upper rail broken by displacement candle with participation.")

alertcondition(evtBrkDn,     "Range Break ▼",     "RANGE DETECTOR: lower rail broken by displacement candle with participation.")

alertcondition(evtRetUp,     "Range Retest ▲",    "RANGE DETECTOR: upper rail retested and held as support.")

alertcondition(evtRetDn,     "Range Retest ▼",    "RANGE DETECTOR: lower rail retested and held as resistance.")

plot(rHi,      "RangeHi",   display = display.none)

plot(rLo,      "RangeLo",   display = display.none)

plot(rSt,      "RangeState",display = display.none)

plot(score,    "FactorScore", display = display.none)

plot(adxV,     "ADX",       display = display.none)

plot(chopV,    "Choppiness",display = display.none)

plot(bbwPct,   "BBWpct",    display = display.none)

plot(slopeAtr, "SlopeATR",  display = display.none)
````
