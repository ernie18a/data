# XABCD Formation Engine + PVM Confirm

- url: https://www.tradingview.com/script/B7RVCSCM/
- type: indicator
- pine_id: PUB;a912021d4baa42aaa801ee5e861b6132
- version: 2.0

## Description

# XABCD Formation Engine + PVM Confirmation

XABCD Formation Engine is a pattern recognition and confirmation framework designed to detect classical market structures and validate them with a proprietary Price-Volume Momentum (PVM) engine.

Unlike traditional pattern indicators that simply draw formations and trigger signals at breakout points, this system focuses on filtering weak structures and reducing false breakouts through volume, momentum, and trend confirmation.

## Supported Pattern Structures

The engine automatically monitors and validates:

• Head & Shoulders (H&S)
• Inverse Head & Shoulders (INV H&S)
• Cup
• Inverse Cup
• XABCD Swing Structures

The indicator continuously tracks X-A-B-C-D pivot development, allowing traders to identify formation progress before a breakout occurs.

## Preparation Stage

One of the unique features of this system is the Preparation (Setup) phase.

Before a complete pattern is confirmed, the engine identifies developing structures and displays preparation zones. This allows traders to monitor potential opportunities before the crowd notices the breakout.

Preparation labels do not represent entry signals. They indicate that a valid structure is forming and should be monitored.

## PVM Confirmation Engine

The core confirmation system is built around the proprietary PVM engine.

PVM combines two independent market components:

### Trend Engine

The Trend Engine measures the relationship between price movement and volume participation.

Healthy trends typically show price and volume moving together. When volume supports price expansion, trend quality increases.

This allows the engine to distinguish between:

• Genuine trend development
• Weak trend continuation
• Low-conviction breakouts

### Impulse Engine

The Impulse Engine measures:

ATR Expansion × Relative Volume

This component is specifically designed to detect the arrival of aggressive participation before a major breakout occurs.

The goal is to identify:

• Early momentum acceleration
• Institutional participation
• Emerging directional pressure

before most classical indicators react.

## False Breakout Filtering

One of the main objectives of this indicator is to reduce false pattern signals.

A breakout is not considered valid simply because price crosses a neckline or resistance level.

The system additionally evaluates:

• Trend quality
• Volume participation
• Momentum expansion
• Impulse strength

Only when these factors align does the confirmation engine approve the breakout.

This helps filter many low-quality formations that frequently fail after triggering.

## XABCD Visualization

The XABCD structure serves as the foundation of pattern construction.

Each pivot is labeled:

X → A → B → C → D

These points allow traders to visually inspect the internal geometry of the formation before confirmation occurs.

The XABCD sequence is not merely decorative. It provides insight into:

• Swing symmetry
• Shoulder balance
• Formation quality
• Structural integrity

## Color Interpretation

### Cyan Labels and Zones

Bullish structures and confirmations.

Used for:

• Inverse Head & Shoulders
• Bullish Cups
• Long confirmations

### Red Labels and Zones

Bearish structures and confirmations.

Used for:

• Head & Shoulders
• Inverse Cups
• Short confirmations

### Yellow Labels

Preparation phase.

These indicate that the structure is still developing and has not yet received confirmation from the PVM engine.

### Purple Structure Components

Used to highlight key swing relationships inside the XABCD sequence and improve pattern readability.

## Neckline Logic

The neckline is one of the most important decision levels inside the system.

The indicator continuously tracks neckline development and monitors:

• Breakouts
• Breakdown events
• Confirmation quality

Signals are only generated when both structural and PVM requirements are satisfied.

## Multi-Language Support

The indicator includes built-in support for:

• English
• Turkish
• Russian
• Arabic
• Hindi

All major labels, states, signals, and pattern names can be displayed in the selected language.

## Design Philosophy

The purpose of this indicator is not to predict the future.

Its objective is to identify high-quality structures and validate them using trend participation and impulse strength.

By combining classical chart patterns with volume-driven confirmation, the system attempts to detect emerging directional moves while reducing exposure to weak and deceptive breakout conditions.

This indicator is designed for traders who prefer confirmation over prediction and structure over randomness.

## Source Code

````pine
//@version=6
indicator("XABCD Formation Engine + PVM Confirm", shorttitle="XABCD PRO", overlay=true, max_labels_count=300, max_lines_count=300)

//━━━━━━━━━━━━━━━━━━━
// LANGUAGE
//━━━━━━━━━━━━━━━━━━━
lang = input.string("English", "Language", options=["English", "Türkçe", "Русский", "العربية", "हिन्दी"])

txtBuy      = lang == "Türkçe" ? "AL" : lang == "Русский" ? "ПОКУПКА" : lang == "العربية" ? "شراء" : lang == "हिन्दी" ? "खरीद" : "BUY"
txtSell     = lang == "Türkçe" ? "SAT" : lang == "Русский" ? "ПРОДАЖА" : lang == "العربية" ? "بيع" : lang == "हिन्दी" ? "बेचें" : "SELL"
txtSetup    = lang == "Türkçe" ? "HAZIRLIK" : lang == "Русский" ? "ПОДГОТОВКА" : lang == "العربية" ? "إعداد" : lang == "हिन्दी" ? "तैयारी" : "SETUP"
txtTOBO     = lang == "Türkçe" ? "TOBO" : lang == "Русский" ? "ИНВ H&S" : lang == "العربية" ? "رأس وكتفين مقلوب" : lang == "हिन्दी" ? "उल्टा H&S" : "INV H&S"
txtOBO      = lang == "Türkçe" ? "OBO" : lang == "Русский" ? "H&S" : lang == "العربية" ? "رأس وكتفين" : lang == "हिन्दी" ? "H&S" : "H&S"
txtCup      = lang == "Türkçe" ? "ÇANAK" : lang == "Русский" ? "ЧАШКА" : lang == "العربية" ? "كوب" : lang == "हिन्दी" ? "कप" : "CUP"
txtInvCup   = lang == "Türkçe" ? "TERS ÇANAK" : lang == "Русский" ? "ОБР ЧАШКА" : lang == "العربية" ? "كوب معكوس" : lang == "हिन्दी" ? "उल्टा कप" : "INV CUP"
txtBullPvm  = lang == "Türkçe" ? "BOĞA PVM" : lang == "Русский" ? "БЫЧИЙ PVM" : lang == "العربية" ? "PVM صاعد" : lang == "हिन्दी" ? "बुलिश PVM" : "BULL PVM"
txtBearPvm  = lang == "Türkçe" ? "AYI PVM" : lang == "Русский" ? "МЕДВЕЖИЙ PVM" : lang == "العربية" ? "PVM هابط" : lang == "हिन्दी" ? "बेयरिश PVM" : "BEAR PVM"
txtLong     = lang == "Türkçe" ? "UZUN" : lang == "Русский" ? "ЛОНГ" : lang == "العربية" ? "شراء" : lang == "हिन्दी" ? "लॉन्ग" : "LONG"
txtShort    = lang == "Türkçe" ? "KISA" : lang == "Русский" ? "ШОРТ" : lang == "العربية" ? "بيع" : lang == "हिन्दी" ? "शॉर्ट" : "SHORT"
txtScan     = lang == "Türkçe" ? "TARAMA" : lang == "Русский" ? "ПОИСК" : lang == "العربية" ? "فحص" : lang == "हिन्दी" ? "स्कैन" : "SCAN"
txtNeutral  = lang == "Türkçe" ? "NÖTR" : lang == "Русский" ? "НЕЙТРАЛЬНО" : lang == "العربية" ? "محايد" : lang == "हिन्दी" ? "न्यूट्रल" : "NEUTRAL"
txtWait     = lang == "Türkçe" ? "BEKLE" : lang == "Русский" ? "ЖДАТЬ" : lang == "العربية" ? "انتظار" : lang == "हिन्दी" ? "प्रतीक्षा" : "WAIT"
txtState    = lang == "Türkçe" ? "Durum" : lang == "Русский" ? "Статус" : lang == "العربية" ? "الحالة" : lang == "हिन्दी" ? "स्थिति" : "State"
txtSignal   = lang == "Türkçe" ? "Sinyal" : lang == "Русский" ? "Сигнал" : lang == "العربية" ? "إشارة" : lang == "हिन्दी" ? "सिग्नल" : "Signal"
txtNeckline = lang == "Türkçe" ? "Boyun" : lang == "Русский" ? "Линия шеи" : lang == "العربية" ? "خط العنق" : lang == "हिन्दी" ? "नेकलाइन" : "Neckline"
txtImpulse  = lang == "Türkçe" ? "İmpuls" : lang == "Русский" ? "Импульс" : lang == "العربية" ? "اندفاع" : lang == "हिन्दी" ? "इम्पल्स" : "Impulse"
txtQuality  = lang == "Türkçe" ? "Kalite" : lang == "Русский" ? "Качество" : lang == "العربية" ? "الجودة" : lang == "हिन्दी" ? "गुणवत्ता" : "Quality"
txtThrow    = lang == "Türkçe" ? "GERİ TEST" : lang == "Русский" ? "РЕТЕСТ" : lang == "العربية" ? "إعادة اختبار" : lang == "हिन्दी" ? "रीटेस्ट" : "THROWBACK"

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
leftBars  = input.int(4, "Pivot Left", minval=1)
rightBars = input.int(4, "Pivot Right", minval=1)
tolPct    = input.float(5.0, "Shoulder Tolerance %", minval=0.1, step=0.1)

showPrep   = input.bool(true, "Show Preparation")
showLines  = input.bool(true, "Show XABCD Lines")
showXABCD  = input.bool(true, "Show XABCD Points")
requirePvm = input.bool(true, "Require PVM Confirmation")

useCup   = input.bool(true, "Use Cup / Inverse Cup")
cupLen   = input.int(80, "Cup Length", minval=20)
cupDepth = input.float(2.0, "Min Cup ATR Depth", minval=0.5, step=0.1)

useThrowback     = input.bool(false, "Require Throwback After Breakout")
throwAtrTol      = input.float(0.6, "Throwback ATR Tolerance", minval=0.1, step=0.1)
maxThrowBars     = input.int(20, "Max Throwback Bars", minval=3)

useQualityFilter = input.bool(false, "Use Quality Score Filter")
minQuality       = input.float(60.0, "Minimum Quality Score", minval=0, maxval=100, step=1)

shZone  = input.bool(true, "Neckline Zone Fill")
shPanel = input.bool(true, "Show Panel")
shBadge = input.bool(true, "Show State Badge")

corrLen   = input.int(55, "PVM Correlation Length", minval=2)
impLen    = input.int(14, "PVM ATR Length", minval=1)
volLen    = input.int(34, "Relative Volume Length", minval=1)
smoothLen = input.int(9, "PVM Smooth", minval=1)
normLen   = input.int(100, "PVM Normalize", minval=20)

bullC = input.color(#00E5FF, "Bull")
bearC = input.color(#FF2D55, "Bear")
prepC = input.color(#FFCA28, "Prep")
headC = input.color(#7B61FF, "Head")
neutC = input.color(color.gray, "Neutral")
goldC = input.color(#FFD700, "Power")

labelGapMult = input.float(1.2, "Pattern Label Distance ATR", minval=0.1, step=0.1)

//━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━
normalize(src, len) =>
    lo = ta.lowest(src, len)
    hi = ta.highest(src, len)
    hi != lo ? 100.0 * (src - lo) / (hi - lo) : 50.0

nearPct(a, b, pct) =>
    math.abs(a - b) / math.max(math.abs(b), syminfo.mintick) * 100.0 <= pct

clamp100(x) =>
    math.max(0.0, math.min(100.0, x))

scoreNearPct(a, b, pct) =>
    diff = math.abs(a - b) / math.max(math.abs(b), syminfo.mintick) * 100.0
    clamp100(100.0 - diff / pct * 100.0)

labelGap = ta.atr(14) * labelGapMult
atr14 = ta.atr(14)

//━━━━━━━━━━━━━━━━━━━
// PVM ENGINE
//━━━━━━━━━━━━━━━━━━━
priceChange  = ta.change(close)
volumeChange = ta.change(volume)

corrRaw = nz(ta.correlation(priceChange, volumeChange, corrLen), 0)
trendEngine = ta.ema((corrRaw + 1.0) * 50.0, smoothLen)

relVolBase = ta.ema(volume, volLen)
relVol = volume / math.max(relVolBase, 1.0)
 
atrNow = ta.atr(impLen)
atrBase = ta.ema(atrNow, volLen)
atrExpansion = atrNow / math.max(atrBase, syminfo.mintick)

impulseRaw = atrExpansion * relVol
impulseEngine = ta.ema(normalize(impulseRaw, normLen), smoothLen)

priceRoc = ta.roc(close, impLen)
directionEngine = ta.ema(normalize(priceRoc, normLen), smoothLen)

bullPvm = trendEngine > 50 and directionEngine > 50 and impulseEngine > 45
bearPvm = trendEngine > 50 and directionEngine < 50 and impulseEngine > 45

bullOk = not requirePvm or bullPvm
bearOk = not requirePvm or bearPvm

//━━━━━━━━━━━━━━━━━━━
// XABCD MEMORY
//━━━━━━━━━━━━━━━━━━━
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

var float xVal = na
var float aVal = na
var float bVal = na
var float cVal = na
var float dVal = na

var int xType = 0
var int aType = 0
var int bType = 0
var int cType = 0
var int dType = 0

var int xBar = na
var int aBar = na
var int bBar = na
var int cBar = na
var int dBar = na

bool newPivot = false
float newVal = na
int newType = 0
int newBar = na

if not na(ph)
    newPivot := true
    newVal := ph
    newType := 1
    newBar := bar_index - rightBars
else if not na(pl)
    newPivot := true
    newVal := pl
    newType := -1
    newBar := bar_index - rightBars

if newPivot
    xVal := aVal
    aVal := bVal
    bVal := cVal
    cVal := dVal
    dVal := newVal

    xType := aType
    aType := bType
    bType := cType
    cType := dType
    dType := newType

    xBar := aBar
    aBar := bBar
    bBar := cBar
    cBar := dBar
    dBar := newBar

//━━━━━━━━━━━━━━━━━━━
// SETUP LOGIC
//━━━━━━━━━━━━━━━━━━━
bool prepTOBO = false
bool prepOBO = false

if newPivot
    if xType == -1 and aType == 1 and bType == -1 and cType == 1
        if bVal < xVal
            prepTOBO := true

    if xType == 1 and aType == -1 and bType == 1 and cType == -1
        if bVal > xVal
            prepOBO := true

//━━━━━━━━━━━━━━━━━━━
// ACTIVE FORMATION + QUALITY
//━━━━━━━━━━━━━━━━━━━
var bool activeTOBO = false
var bool activeOBO = false
var float toboNeck = na
var float oboNeck = na
var float activeQuality = na
var float activeHarmonic = na

bool newTOBO = false
bool newOBO = false

float patternQualityNow = na
float harmonicNow = na

if newPivot
    if xType == -1 and aType == 1 and bType == -1 and cType == 1 and dType == -1
        shouldersOk = nearPct(xVal, dVal, tolPct)
        headOk = bVal < xVal and bVal < dVal

        shoulderScore = scoreNearPct(xVal, dVal, tolPct)
        headDepthScore = clamp100((math.min(xVal, dVal) - bVal) / math.max(atr14, syminfo.mintick) * 30.0)
        neckScore = scoreNearPct(aVal, cVal, tolPct * 2.0)

        leftWidth = math.abs(bBar - xBar)
        rightWidth = math.abs(dBar - bBar)
        widthScore = clamp100(100.0 - math.abs(leftWidth - rightWidth) / math.max(math.max(leftWidth, rightWidth), 1) * 100.0)

        harmonicNow := shoulderScore * 0.35 + neckScore * 0.25 + widthScore * 0.25 + headDepthScore * 0.15
        patternQualityNow := harmonicNow * 0.55 + impulseEngine * 0.25 + trendEngine * 0.20

        qualityOk = not useQualityFilter or patternQualityNow >= minQuality

        if shouldersOk and headOk and qualityOk
            activeTOBO := true
            activeOBO := false
            toboNeck := math.max(aVal, cVal)
            activeQuality := patternQualityNow
            activeHarmonic := harmonicNow
            newTOBO := true

    if xType == 1 and aType == -1 and bType == 1 and cType == -1 and dType == 1
        shouldersOk2 = nearPct(xVal, dVal, tolPct)
        headOk2 = bVal > xVal and bVal > dVal

        shoulderScore2 = scoreNearPct(xVal, dVal, tolPct)
        headDepthScore2 = clamp100((bVal - math.max(xVal, dVal)) / math.max(atr14, syminfo.mintick) * 30.0)
        neckScore2 = scoreNearPct(aVal, cVal, tolPct * 2.0)

        leftWidth2 = math.abs(bBar - xBar)
        rightWidth2 = math.abs(dBar - bBar)
        widthScore2 = clamp100(100.0 - math.abs(leftWidth2 - rightWidth2) / math.max(math.max(leftWidth2, rightWidth2), 1) * 100.0)

        harmonicNow := shoulderScore2 * 0.35 + neckScore2 * 0.25 + widthScore2 * 0.25 + headDepthScore2 * 0.15
        patternQualityNow := harmonicNow * 0.55 + impulseEngine * 0.25 + trendEngine * 0.20

        qualityOk2 = not useQualityFilter or patternQualityNow >= minQuality

        if shouldersOk2 and headOk2 and qualityOk2
            activeOBO := true
            activeTOBO := false
            oboNeck := math.min(aVal, cVal)
            activeQuality := patternQualityNow
            activeHarmonic := harmonicNow
            newOBO := true

//━━━━━━━━━━━━━━━━━━━
// IMPROVED CUP / INVERSE CUP GEOMETRY
//━━━━━━━━━━━━━━━━━━━
cupHigh = ta.highest(high, cupLen)
cupLow = ta.lowest(low, cupLen)
cupDepthAtr = (cupHigh - cupLow) / math.max(atr14, syminfo.mintick)

cupBreakLevel = ta.highest(high, cupLen)[1]
invCupBreakLevel = ta.lowest(low, cupLen)[1]

cupLowOffset = ta.lowestbars(low, cupLen)
cupHighOffset = ta.highestbars(high, cupLen)

cupBottomPos = cupLen - math.abs(cupLowOffset)
cupTopPos = cupLen - math.abs(cupHighOffset)

cupMidOk = cupBottomPos > cupLen * 0.25 and cupBottomPos < cupLen * 0.75
invCupMidOk = cupTopPos > cupLen * 0.25 and cupTopPos < cupLen * 0.75

cupRightRecovery = close > ta.ema(close, math.max(5, cupLen / 4))
invCupRightWeakness = close < ta.ema(close, math.max(5, cupLen / 4))

cupGeoScore = clamp100(cupDepthAtr / cupDepth * 50.0 + (cupMidOk ? 30.0 : 0.0) + (cupRightRecovery ? 20.0 : 0.0))
invCupGeoScore = clamp100(cupDepthAtr / cupDepth * 50.0 + (invCupMidOk ? 30.0 : 0.0) + (invCupRightWeakness ? 20.0 : 0.0))

cupQuality = cupGeoScore * 0.55 + impulseEngine * 0.25 + trendEngine * 0.20
invCupQuality = invCupGeoScore * 0.55 + impulseEngine * 0.25 + trendEngine * 0.20

bool cupBuy = false
bool cupSell = false

if useCup
    cupQualityOk = not useQualityFilter or cupQuality >= minQuality
    invCupQualityOk = not useQualityFilter or invCupQuality >= minQuality

    if cupDepthAtr >= cupDepth and cupMidOk and cupRightRecovery and ta.crossover(close, cupBreakLevel) and bullOk and cupQualityOk
        cupBuy := true
        activeQuality := cupQuality
        activeHarmonic := cupGeoScore

    if cupDepthAtr >= cupDepth and invCupMidOk and invCupRightWeakness and ta.crossunder(close, invCupBreakLevel) and bearOk and invCupQualityOk
        cupSell := true
        activeQuality := invCupQuality
        activeHarmonic := invCupGeoScore

//━━━━━━━━━━━━━━━━━━━
// THROWBACK STATE
//━━━━━━━━━━━━━━━━━━━
var bool waitThrowBuy = false
var bool waitThrowSell = false
var float throwLevel = na
var int throwStartBar = na
var float throwQuality = na

//━━━━━━━━━━━━━━━━━━━
// SIGNAL STATE
//━━━━━━━━━━━━━━━━━━━
var int signalState = 0

bool buySignal = false
bool sellSignal = false
bool rawBreakBuy = false
bool rawBreakSell = false

if activeTOBO and not na(toboNeck)
    if ta.crossover(close, toboNeck) and bullOk
        rawBreakBuy := true
        if useThrowback
            waitThrowBuy := true
            waitThrowSell := false
            throwLevel := toboNeck
            throwStartBar := bar_index
            throwQuality := activeQuality
            activeTOBO := false
        else
            buySignal := true
            activeTOBO := false
            signalState := 1

if activeOBO and not na(oboNeck)
    if ta.crossunder(close, oboNeck) and bearOk
        rawBreakSell := true
        if useThrowback
            waitThrowSell := true
            waitThrowBuy := false
            throwLevel := oboNeck
            throwStartBar := bar_index
            throwQuality := activeQuality
            activeOBO := false
        else
            sellSignal := true
            activeOBO := false
            signalState := -1

if waitThrowBuy and not na(throwLevel)
    retestOk = low <= throwLevel + atr14 * throwAtrTol and close > throwLevel and bullOk
    timeOk = bar_index - throwStartBar <= maxThrowBars
    if retestOk and timeOk
        buySignal := true
        waitThrowBuy := false
        signalState := 1
        activeQuality := throwQuality
    else if not timeOk or close < throwLevel - atr14 * throwAtrTol
        waitThrowBuy := false
        signalState := 0

if waitThrowSell and not na(throwLevel)
    retestOk2 = high >= throwLevel - atr14 * throwAtrTol and close < throwLevel and bearOk
    timeOk2 = bar_index - throwStartBar <= maxThrowBars
    if retestOk2 and timeOk2
        sellSignal := true
        waitThrowSell := false
        signalState := -1
        activeQuality := throwQuality
    else if not timeOk2 or close > throwLevel + atr14 * throwAtrTol
        waitThrowSell := false
        signalState := 0

if cupBuy
    buySignal := true
    signalState := 1

if cupSell
    sellSignal := true
    signalState := -1

if activeTOBO and not na(bVal)
    if close < bVal
        activeTOBO := false
        signalState := 0

if activeOBO and not na(bVal)
    if close > bVal
        activeOBO := false
        signalState := 0

if not activeTOBO and not activeOBO and not waitThrowBuy and not waitThrowSell and signalState != 0 and not buySignal and not sellSignal
    signalState := 0

//━━━━━━━━━━━━━━━━━━━
// NECKLINE PLOTS
//━━━━━━━━━━━━━━━━━━━
pNeckTOBO = plot(activeTOBO ? toboNeck : na, "TOBO Neck", color=color.new(bullC, 0), linewidth=3, style=plot.style_linebr)
pNeckOBO  = plot(activeOBO ? oboNeck : na, "OBO Neck", color=color.new(bearC, 0), linewidth=3, style=plot.style_linebr)
pThrow    = plot((waitThrowBuy or waitThrowSell) ? throwLevel : na, "Throwback Level", color=color.new(goldC, 0), linewidth=2, style=plot.style_linebr)
pPrice    = plot(close, "Price Shadow", color=color.new(color.white, 100), linewidth=1)

fill(pPrice, pNeckTOBO, color=shZone and activeTOBO ? color.new(bullC, 92) : na, title="TOBO Zone")
fill(pPrice, pNeckOBO, color=shZone and activeOBO ? color.new(bearC, 92) : na, title="OBO Zone")
fill(pPrice, pThrow, color=shZone and (waitThrowBuy or waitThrowSell) ? color.new(goldC, 92) : na, title="Throwback Zone")

//━━━━━━━━━━━━━━━━━━━
// XABCD LINES
//━━━━━━━━━━━━━━━━━━━
if showLines and newPivot
    if not na(xVal) and not na(aVal)
        line.new(xBar, xVal, aBar, aVal, color=color.new(neutC, 60), style=line.style_dashed, width=1)

    if not na(aVal) and not na(bVal)
        line.new(aBar, aVal, bBar, bVal, color=color.new(headC, 50), style=line.style_solid, width=2)

    if not na(bVal) and not na(cVal)
        line.new(bBar, bVal, cBar, cVal, color=color.new(neutC, 60), style=line.style_dashed, width=1)

    if not na(cVal) and not na(dVal)
        line.new(cBar, cVal, dBar, dVal, color=color.new(headC, 50), style=line.style_solid, width=2)

//━━━━━━━━━━━━━━━━━━━
// PREP & ACTIVE LABELS
//━━━━━━━━━━━━━━━━━━━
if showPrep and prepTOBO
    label.new(cBar, cVal - labelGap, txtSetup, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(prepC, 0), textcolor=color.black, size=size.tiny)

if showPrep and prepOBO
    label.new(cBar, cVal + labelGap, txtSetup, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(prepC, 0), textcolor=color.black, size=size.tiny)

if newTOBO
    label.new(dBar, dVal - labelGap, txtTOBO + "\nQ " + str.tostring(activeQuality, "#"), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(bullC, 0), textcolor=color.black, size=size.small)

if newOBO
    label.new(dBar, dVal + labelGap, txtOBO + "\nQ " + str.tostring(activeQuality, "#"), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(bearC, 0), textcolor=color.white, size=size.small)

if rawBreakBuy and useThrowback
    label.new(bar_index, high + labelGap, txtThrow, xloc=xloc.bar_index, yloc=yloc.price, color=goldC, textcolor=color.black, style=label.style_label_down, size=size.tiny)

if rawBreakSell and useThrowback
    label.new(bar_index, low - labelGap, txtThrow, xloc=xloc.bar_index, yloc=yloc.price, color=goldC, textcolor=color.black, style=label.style_label_up, size=size.tiny)

//━━━━━━━━━━━━━━━━━━━
// CUP LABELS
//━━━━━━━━━━━━━━━━━━━
if cupBuy
    label.new(bar_index, low - labelGap, txtCup + "\n" + txtBuy + "\nQ " + str.tostring(activeQuality, "#"), xloc=xloc.bar_index, yloc=yloc.price, color=bullC, textcolor=color.black, style=label.style_label_up, size=size.small)

if cupSell
    label.new(bar_index, high + labelGap, txtInvCup + "\n" + txtSell + "\nQ " + str.tostring(activeQuality, "#"), xloc=xloc.bar_index, yloc=yloc.price, color=bearC, textcolor=color.white, style=label.style_label_down, size=size.small)

//━━━━━━━━━━━━━━━━━━━
// BUY / SELL LABELS
//━━━━━━━━━━━━━━━━━━━
if buySignal
    label.new(bar_index, low - labelGap * 1.8, "▲ " + txtBuy + "\nPVM OK\nQ " + str.tostring(activeQuality, "#"), xloc=xloc.bar_index, yloc=yloc.price, color=bullC, textcolor=color.black, style=label.style_label_up, size=size.small)

if sellSignal
    label.new(bar_index, high + labelGap * 1.8, "▼ " + txtSell + "\nPVM OK\nQ " + str.tostring(activeQuality, "#"), xloc=xloc.bar_index, yloc=yloc.price, color=bearC, textcolor=color.white, style=label.style_label_down, size=size.small)

//━━━━━━━━━━━━━━━━━━━
// XABCD LABELS
//━━━━━━━━━━━━━━━━━━━
if showXABCD and newTOBO
    label.new(xBar, xVal, "X", style=label.style_label_up, textcolor=color.white, color=color.new(bullC, 15), yloc=yloc.price, size=size.small)
    label.new(aBar, aVal, "A", style=label.style_label_down, textcolor=color.white, color=color.new(neutC, 25), yloc=yloc.price, size=size.small)
    label.new(bBar, bVal, "B", style=label.style_label_up, textcolor=color.white, color=color.new(headC, 15), yloc=yloc.price, size=size.small)
    label.new(cBar, cVal, "C", style=label.style_label_down, textcolor=color.white, color=color.new(neutC, 25), yloc=yloc.price, size=size.small)
    label.new(dBar, dVal, "D", style=label.style_label_up, textcolor=color.white, color=color.new(bullC, 15), yloc=yloc.price, size=size.small)

if showXABCD and newOBO
    label.new(xBar, xVal, "X", style=label.style_label_down, textcolor=color.white, color=color.new(bearC, 15), yloc=yloc.price, size=size.small)
    label.new(aBar, aVal, "A", style=label.style_label_up, textcolor=color.white, color=color.new(neutC, 25), yloc=yloc.price, size=size.small)
    label.new(bBar, bVal, "B", style=label.style_label_down, textcolor=color.white, color=color.new(headC, 15), yloc=yloc.price, size=size.small)
    label.new(cBar, cVal, "C", style=label.style_label_up, textcolor=color.white, color=color.new(neutC, 25), yloc=yloc.price, size=size.small)
    label.new(dBar, dVal, "D", style=label.style_label_down, textcolor=color.white, color=color.new(bearC, 15), yloc=yloc.price, size=size.small)

//━━━━━━━━━━━━━━━━━━━
// STATE BADGE
//━━━━━━━━━━━━━━━━━━━
var label badge = na

if shBadge and barstate.islast
    label.delete(badge)

    color badgeCol = neutC
    string badgeTxt = txtScan

    if waitThrowBuy or waitThrowSell
        badgeCol := goldC
        badgeTxt := txtThrow
    else if activeTOBO
        badgeCol := bullC
        badgeTxt := txtTOBO
    else if activeOBO
        badgeCol := bearC
        badgeTxt := txtOBO
    else if prepTOBO
        badgeCol := prepC
        badgeTxt := txtSetup + " " + txtTOBO
    else if prepOBO
        badgeCol := prepC
        badgeTxt := txtSetup + " " + txtOBO

    badge := label.new(bar_index + 3, high + atr14, badgeTxt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(badgeCol, 0), textcolor=color.black, size=size.small)

//━━━━━━━━━━━━━━━━━━━
// PANEL
//━━━━━━━━━━━━━━━━━━━
var table pan = na

if shPanel and barstate.islast
    if na(pan)
        pan := table.new(position.top_right, 2, 7, bgcolor=color.new(#0A0A0A, 0), border_width=2, border_color=color.new(color.gray, 60))

    bg = color.new(#111111, 0)

    string stateTxt = txtScan
    color stateCol = neutC

    if waitThrowBuy or waitThrowSell
        stateTxt := txtThrow
        stateCol := goldC
    else if activeTOBO
        stateTxt := txtTOBO
        stateCol := bullC
    else if activeOBO
        stateTxt := txtOBO
        stateCol := bearC
    else if prepTOBO
        stateTxt := txtSetup + " " + txtTOBO
        stateCol := bullC
    else if prepOBO
        stateTxt := txtSetup + " " + txtOBO
        stateCol := bearC

    string pvmTxt = txtNeutral
    color pvmCol = neutC

    if bullPvm
        pvmTxt := txtBullPvm
        pvmCol := bullC
    else if bearPvm
        pvmTxt := txtBearPvm
        pvmCol := bearC

    float neckVal = na
    if activeTOBO
        neckVal := toboNeck
    else if activeOBO
        neckVal := oboNeck
    else if waitThrowBuy or waitThrowSell
        neckVal := throwLevel

    string sigTxt = txtWait
    color sigCol = neutC

    if signalState == 1
        sigTxt := txtLong
        sigCol := bullC
    else if signalState == -1
        sigTxt := txtShort
        sigCol := bearC

    table.cell(pan, 0, 0, "XABCD", text_color=color.white, text_size=size.large, bgcolor=bg)
    table.cell(pan, 1, 0, "ENGINE", text_color=goldC, text_size=size.large, bgcolor=bg)

    table.cell(pan, 0, 1, txtState, text_color=color.gray, text_size=size.small, bgcolor=bg)
    table.cell(pan, 1, 1, stateTxt, text_color=stateCol, text_size=size.small, bgcolor=bg)

    table.cell(pan, 0, 2, "PVM", text_color=color.gray, text_size=size.small, bgcolor=bg)
    table.cell(pan, 1, 2, pvmTxt, text_color=pvmCol, text_size=size.small, bgcolor=bg)

    table.cell(pan, 0, 3, txtImpulse, text_color=color.gray, text_size=size.small, bgcolor=bg)
    table.cell(pan, 1, 3, str.tostring(impulseEngine, "#.#"), text_color=impulseEngine > 60 ? goldC : neutC, text_size=size.small, bgcolor=bg)

    table.cell(pan, 0, 4, txtQuality, text_color=color.gray, text_size=size.small, bgcolor=bg)
    table.cell(pan, 1, 4, not na(activeQuality) ? str.tostring(activeQuality, "#") : "—", text_color=not na(activeQuality) ? goldC : color.gray, text_size=size.small, bgcolor=bg)

    table.cell(pan, 0, 5, txtNeckline, text_color=color.gray, text_size=size.small, bgcolor=bg)
    table.cell(pan, 1, 5, not na(neckVal) ? str.tostring(neckVal, "#.#") : "—", text_color=not na(neckVal) ? stateCol : color.gray, text_size=size.small, bgcolor=bg)

    table.cell(pan, 0, 6, txtSignal, text_color=color.gray, text_size=size.small, bgcolor=bg)
    table.cell(pan, 1, 6, sigTxt, text_color=sigCol, text_size=size.small, bgcolor=bg)

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
alertcondition(buySignal, "XABCD PVM BUY", "XABCD pattern confirmed by PVM: BUY {{ticker}} @ {{close}}")
alertcondition(sellSignal, "XABCD PVM SELL", "XABCD pattern confirmed by PVM: SELL {{ticker}} @ {{close}}")
alertcondition(newTOBO, "XABCD INV H&S Active", "XABCD Inverse Head & Shoulders formation ACTIVE on {{ticker}}")
alertcondition(newOBO, "XABCD H&S Active", "XABCD Head & Shoulders formation ACTIVE on {{ticker}}")
````
