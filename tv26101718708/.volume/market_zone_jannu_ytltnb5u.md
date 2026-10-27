# Market Zone [Jannu]

- url: https://www.tradingview.com/script/yTltnb5U-Market-Zone-Jannu/
- type: indicator
- pine_id: PUB;e5e7a0053926456c8b72b982a588bc65
- version: 1.0

## Description

[b]1. Description[/b]
Markets do not move in straight lines. Price frequently departs from equilibrium through gaps, rapid displacement, or impulsive expansion from compressed bases. These departures leave behind areas of unresolved imbalance;  zones where the auction process was incomplete. Market Zone [Jannu] is the foundational Imbalance component of the ET Massif Framework research suite. It identifies three distinct forms of such imbalance and renders them as dynamic, self-managing zones on the chart. [image]https://www.tradingview.com/x/VNw42aiv/[/image]
[b]2. Features[/b]
The indicator combines three detection methods:
[list]
[*][b]Fair Value Gaps (FVGs)[/b] 
Three-candle imbalances where a qualifying middle candle displaces price fast enough that the gap between the outer candles remains unfilled. Detection requires ATR expansion, minimum gap size, VWAP position relative to the gap, volume, and candle body proportion.
[*][b]Session Gaps[/b] 
Price discontinuities between consecutive session closes and opens, filtered by ATR magnitude.
[*][b]Points of Interest (POI) [/b]
The consolidation base that preceded a significant impulsive move. Once an impulse exceeding a defined ATR multiple is confirmed, the indicator locates the tight-range candle immediately before the expansion and uses its high/low as the zone boundary.
[/list][image]https://www.tradingview.com/x/UkncMWn4/[/image]
[b]3. Detection Logic[/b]

[b]A. Fair Value Gaps (FVG)[/b]
Detected using a qualified three-candle imbalance structure.
[i]Criteria:[/i][list]
[*]Low > High[2] (Bullish) or High < Low[2] (Bearish)
[*]Middle candle range > 1.1× ATR
[*]Gap size > 1.0× ATR
[*]Middle candle VWAP above High[2] (Bullish) or below Low[2] (Bearish)
[*]Volume > 1.2× 180-bar average volume
[*]Candle body > 65% of total range
[/list]Qualifying FVGs display a diamond marker at the middle candle VWAP. Diamond size scales with relative volume. Boxes extend forward with each new bar and contract as candle bodies close into the zone. Zones are removed once fully covered.[image]https://www.tradingview.com/x/wXyzUfsR/[/image]
[b]B. Session Gaps (FVG)[/b]
Detects price discontinuities between the current open and the prior close.
[i]Criteria:[/i][list]
[*]Absolute gap > 1.5× ATR
[/list]Gap boxes are drawn between the prior close and the current open, extend forward, and contract as candle bodies close into them. Zones are removed once fully covered.[image]https://www.tradingview.com/x/sqTY3PPV/[/image]
[b]C. Points of Interest (POI)[/b]
Identifies the consolidation base preceding a significant directional expansion.
[i]Criteria:[/i]
[list]
[*]An impulsive move within the previous 5 bars exceeding 2.0× ATR
[*]Majority of bars within the move are directional
[/list]Once an impulse is confirmed, the indicator searches the preceding bars for the first candle whose range is below 0.5× ATR. That candle's high and low define the POI zone. A 20-bar cooldown prevents overlapping detections. Zones are invalidated when a candle body closes through the zone boundary. Invalidated zones remain on the chart in grey.[image]https://www.tradingview.com/x/3Edza7la/[/image] [i]All criteria are configurable via settings. Use stricter rules for lower timeframes or volatile assets.[/i]

[b]4 . Use [/b]
Jannu is a structural reference tool. The zones mark where price departed from equilibrium; Determining which outcome is unfolding requires the broader analytical context in which the indicator is used.
[image] https://www.tradingview.com/x/eX1ULddE/[/image]
The same zone type can carry different interpretations depending on context. On the CRWD daily chart in early 2026, a cluster of large bearish FVGs formed during a sharp sell-off, yet price reversed immediately and never returned to those zones. The imbalance was not evidence of sellers in control; it was the mechanism through which aggressive selling exhausted supply before buyers drove price upward.[image]https://www.tradingview.com/x/wLS2WV0C/[/image] Contrast this with the series of bearish FVGs that formed during ADBE's long decline from late 2024. Same structure, different character. The indicator marks the zone; contextual analysis is required.[image]https://www.tradingview.com/x/dhxXRAL1/[/image]
[b]日本語概要 (Japanese Summary)[/b]
Jannuは、価格が均衡から乖離した領域を可視化するリファレンス指標であり、ET Massifインジケーターフレームワークの一部として開発されました。セッションギャップ、フェアバリューギャップ（FVG）、ポイント・オブ・インタレスト（POI）の3種類の価格不均衡を検出し、動的なゾーンとしてチャート上に表示します。これらのゾーンは、ローソク足の実体が内部に進入するにつれて縮小し、完全に埋まった時点で自動的に削除されます。市場構造の参照フレームワークとして機能します。

[b]中文概要（Chinese Summary）[/b]
Jannu 是一款將價格偏離均衡的區域進行視覺化呈現的參考指標，作為 ET Massif 指標框架的一部分所開發。本指標可偵測三種價格失衡類型：開盤缺口（Session Gap）、合理價值 gap（FVG）以及關注區域（POI），並將其作為動態區間顯示於圖表上。這些區間會隨著 K 線實體進入而縮減，並在完全填補時自動刪除。本指標作為市場結構的參考框架使用。

[b]Disclaimer:[/b]
This script is a research tool for market structure analysis and educational purposes only. It does not constitute financial advice. Trading involves risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © et20tradeview

//@version=6


indicator("Jannu", overlay=true,  max_boxes_count=500)

//--------------------------------------------------
// 1, Inputs
//--------------------------------------------------

showGap   = input.bool(true,  title="Show Gap", group="Display")
showFVG   = input.bool(true,  title="Show FVG", group="Display")
showPOI   = input.bool(true,  title="Show POI", group="Display")

atrPeriod   = input.int(14, title="ATR Period", group ="General")
volAvgLen   = input.int(180, title="Historical Volume Lookback", group ="General")


//FVG
fvgVolThresh = input.float(1.2, title = "FVG Volume Threshold",step=0.1, group ="FVG")
fvgATRThresh = input.float(1.1, title = "FVG Candle ATR Threshold",step=0.1, group ="FVG")
fvgCandleThresh = input.float(0.65, title = "FVG Candle Body Threshold",step=0.05, group ="FVG")
fvgDiffThresh   =  input.float(1.0, title = "FVG Range Difference Threshold",step=0.05, group ="FVG")
FVGAge = input.int(650, title = "FVG Max Bars", group ="FVG")

//POI
impulseLen    = input.int(5,    "Impulse Lookback",   minval = 2, group ="POI")
impulseMult   = input.float(2.0,"Impulse ATR Multiple",      step = 0.1, group ="POI")
baseLookback  = input.int(10,   "Base Lookback",      minval = 2, group ="POI")
baseTightMult = input.float(0.5,"Base Tightness (ATR)",   step = 0.05, group ="POI")
baseMinBars   = input.int(2,    "Min Base Bars",             minval = 1, group ="POI")
cooldownBars = input.int(20, "POI Cooldown (bars)", minval = 1, group ="POI")
trendLen   = input.int(50, "Trend EMA Length", group="POI")
POIAge = input.int(650, title = "POI Max Bars", group ="POI")

//Gap
gapThresh = input.float(1.5, title = "Session Gap ATR threshold", step=0.1,  group ="Session Gap")
gapAge = input.int(400, title = "Session Gap Max Bars", group ="Session Gap")

//--------------------------------------------------
// 2. Helper Function
//--------------------------------------------------

pine_ema(src, length) => 

    alpha = 2 / (length + 1)
    float ema_val = na
    ema_val := alpha * src + (1 - alpha) * nz(ema_val[1], src)
    ema_val


//----------------------------------------------------------------------------------
// 3. GAP Condition
//    A regular gap is when open - close[1]  is greater than ATR threshhold
//    Threshold is 1.5 by default. Threshold should be higher for lower timefrmes
//-------------------------------------------------------------------------------------


// --- 3a. Calculate Gap Metrics ---
candleRange = high - low
candleBody  = math.abs(close - open)
upperWick   = high - math.max(open, close)
lowerWick   = math.min(open, close) - low

dailyAtr    = ta.atr(atrPeriod)

isRegularSession = session.ismarket

gapUp   = isRegularSession and open > close[1]
gapDown = isRegularSession and open < close[1]
gapDiff = open - close[1]


// ----3b. Is Gap boolean ----
isGap = isRegularSession  and (math.abs(gapDiff) > dailyAtr * gapThresh) and showGap


// ----3c. Gap tops and bottoms  ----
gapTop = gapUp and isGap ? open : close[1]
gapBottom = gapUp and isGap ? close[1] : open


//--------------------------------------------------
// 4. Gap STORAGE
//--------------------------------------------------
var box[]   gapBoxes      = array.new_box()
var float[] gapTops       = array.new_float()
var float[] gapBottoms    = array.new_float()
var int[] gapBirths      = array.new_int()
var bool[]  gapDirections = array.new_bool()  // true = bullish gap, false = bearish gap

if isGap
    newGapBox =
         box.new(
             left         = bar_index,
             right        = bar_index,
             top          = gapTop,
             bottom       = gapBottom,
             bgcolor      = color.new(#9f8932, 85),
             border_width = 0
             )
    array.push(gapBoxes,      newGapBox)
    array.push(gapTops,       gapTop)
    array.push(gapBottoms,    gapBottom)
    array.push(gapBirths,     bar_index)
    array.push(gapDirections, gapUp)


  //--------------------------------------------------
  // UPDATE GAPS
  //--------------------------------------------------
if array.size(gapBoxes) > 0
    for i = array.size(gapBoxes) - 1 to 0
        b          = array.get(gapBoxes,      i)
        topGap     = array.get(gapTops,       i)
        botGap     = array.get(gapBottoms,    i)
        gapage     = array.get(gapBirths,     i)
        isBullish  = array.get(gapDirections, i)


        //--------------------------------------------------
        // AGE
        //--------------------------------------------------

        ageingap = bar_index - gapage

          //--------------------------------------------------
          // EXTEND TO CURRENT BAR
          //--------------------------------------------------
        box.set_right(b, bar_index)

          //--------------------------------------------------
        　// BODY Values
        　//--------------------------------------------------
        bodyHigh = math.max(open, close)
        bodyLow  = math.min(open, close)

          //--------------------------------------------------
          // GAP REFILL LOGIC
          //--------------------------------------------------
        gapFilled = false

        if barstate.isconfirmed
            if isBullish
                currentTop = box.get_top(b)
                newTop = math.min(currentTop, bodyLow)
                box.set_top(b, newTop)
                gapFilled := newTop <= botGap
            else
                currentBottom = box.get_bottom(b)
                newBottom = math.max(currentBottom, bodyHigh)
                box.set_bottom(b, newBottom)
                gapFilled := newBottom >= topGap


        //--------------------------------------------------
        // DELETE WHEN FULLY FILLED OR AFTER 400 BARS
        //--------------------------------------------------
        if gapFilled or ageingap > gapAge
            box.delete(b)
            array.remove(gapBoxes,      i)
            array.remove(gapTops,       i)
            array.remove(gapBottoms,    i)
            array.remove(gapBirths,    i)
            array.remove(gapDirections, i)




//--------------------------------------------------
// 5. FVG Condition
//  a. low > high[2] or high < low[2]
//  b. Difference of (a) > ATR threshhold
//  c. Middle candle range  > ATR threshold
//  d. VWAP of middle candle > high[2] or < low[2]
//  e. Volume of middle candle > Volume Threshold
//--------------------------------------------------


// --- 5a. FVG Metrics ---

bullish_FVG = low > high[2]  // current low above bar-2 high
bearish_FVG = high < low[2]  // current high below bar-2 low
middle_FVG = math.abs(high[1] - low[1])/ dailyAtr  // length of middle bar as ratio of ATR
right_FVG = bullish_FVG ? math.abs(low - high[2]) : math.abs(low[2]-high)
right_FVG_ATR = right_FVG / dailyAtr

// FVG ATR Threshhold
isfvgATRQualified = right_FVG_ATR >= fvgDiffThresh  

isfvgVolumeQualified = false
isfvgvwapQualified =false
currentVwap = ta.vwap
float fvgVwap  = currentVwap[1]

// FVG VWAP Threshhold
isfvgvwapQualified :=bullish_FVG?  fvgVwap > high[2] : fvgVwap <  low[2]
float averageVolume = pine_ema(volume, volAvgLen)
float fvgVolumeRatio = volume[1] / averageVolume

// FVG Volume Threshhold
isfvgVolumeQualified := fvgVolumeRatio > fvgVolThresh
fvgCandleRange = high[1]- low[1]
fvgCandleBody  = math.abs(close[1] - open[1])

// FVG Candle Threshhold
isfvgCandleFat = (fvgCandleRange > 0) ? (fvgCandleBody / fvgCandleRange > fvgCandleThresh) : false


// ----5b. Is FVG boolean ----
isfvgQualified   = (bullish_FVG or bearish_FVG) and (middle_FVG >=fvgATRThresh) and isfvgvwapQualified and isfvgVolumeQualified and isfvgATRQualified and isfvgCandleFat and showFVG

// ----5c. FVG Tops and Bottomw ----
fvgTop = bullish_FVG and isfvgQualified ? low : low[2]
fvgBottom = bullish_FVG  and isfvgQualified ? high[2] : high


// ----5d. FVG box colors ----
color dynamicDiamondColor = color.new(color.gray, 100)


if isfvgQualified 
    if bullish_FVG
        dynamicDiamondColor := color.new(color.teal, 40)
    else
        dynamicDiamondColor :=  color.new(color.orange, 40)


//--------------------------------------------------
// 6. FVG STORAGE
//--------------------------------------------------
var box[]   fvgBoxes      = array.new_box()
var float[]  fvgTops       = array.new_float()
var float[] fvgBottoms    = array.new_float()
var int[] fvgBirths      = array.new_int()
var bool[]  fvgDirections = array.new_bool() 

if isfvgQualified
    newFvgBox =
         box.new(
             left         = bar_index,
             right        = bar_index,
             top          = fvgTop,
             bottom       = fvgBottom,
             bgcolor       = bullish_FVG ?  color.new(color.teal, 85): color.new(color.orange, 85),
             border_color = bullish_FVG ?color.new(color.teal, 50) : color.new(color.orange, 50),
             border_width = 1
             )
    array.push(fvgBoxes,      newFvgBox)
    array.push(fvgTops,       fvgTop)
    array.push(fvgBottoms,    fvgBottom)
    array.push(fvgBirths,     bar_index)
    array.push(fvgDirections, bullish_FVG)


  //--------------------------------------------------
  // UPDATE FVG
  //--------------------------------------------------
if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        b          = array.get(fvgBoxes,      i)
        topGap     = array.get(fvgTops,       i)
        botGap     = array.get(fvgBottoms,    i)
        gapage     = array.get(fvgBirths,     i)
        isBullish  = array.get(fvgDirections, i)


        //--------------------------------------------------
        // AGE
        //--------------------------------------------------

        ageingfvg = bar_index - gapage


          //--------------------------------------------------
          // EXTEND TO CURRENT BAR
          //--------------------------------------------------
        box.set_right(b, bar_index)

          //--------------------------------------------------
        　// BODY VALUES
        　//--------------------------------------------------
        bodyHigh = math.max(open, close)
        bodyLow  = math.min(open, close)

          //--------------------------------------------------
          // GAP REFILL LOGIC
          //--------------------------------------------------
        gapFilled = false

        if barstate.isconfirmed
            if isBullish
                currentTop = box.get_top(b)
                newTop = math.min(currentTop, bodyLow)
                box.set_top(b, newTop)
                gapFilled := newTop <= botGap
            else
                currentBottom = box.get_bottom(b)
                newBottom = math.max(currentBottom, bodyHigh)
                box.set_bottom(b, newBottom)
                gapFilled := newBottom >= topGap





        //--------------------------------------------------
        // DELETE WHEN FULLY FILLED
        //--------------------------------------------------
        if gapFilled
            box.delete(b)
            array.remove(fvgBoxes,      i)
            array.remove(fvgTops,       i)
            array.remove(fvgBottoms,    i)
            array.remove(fvgBirths,    i)
            array.remove(fvgDirections, i)
        else if ageingfvg > FVGAge
            box.delete(b)
            array.remove(fvgBoxes,      i)
            array.remove(fvgTops,       i)
            array.remove(fvgBottoms,    i)
            array.remove(fvgBirths,    i)
            array.remove(fvgDirections, i)




//--------------------------------------------------
// 7. FVG Label
//--------------------------------------------------

//  Define FVG symbol size 
isFvgTiny = isfvgQualified and (fvgVolumeRatio <= 1.2)
isFvgSmall   = isfvgQualified and (fvgVolumeRatio > 1.2 and fvgVolumeRatio <= 1.5 )
isFvgNormal  = isfvgQualified and (fvgVolumeRatio > 1.5 and fvgVolumeRatio <= 2)
isFvgLarge = isfvgQualified and (fvgVolumeRatio > 2 and fvgVolumeRatio <= 2.7)
isFvgHuge   = isfvgQualified and (fvgVolumeRatio > 2.7)


// Plotting Main Chart Overlay (Diamond)
plotshape(isFvgTiny  ? fvgVwap : na, style=shape.diamond, location=location.absolute, color=dynamicDiamondColor, size=size.tiny,  title="Tiny FVG",  force_overlay=true)
plotshape(isFvgSmall  ? fvgVwap : na, style=shape.diamond, location=location.absolute, color=dynamicDiamondColor, size=size.small,  title="Small FVG",  force_overlay=true)
plotshape(isFvgNormal ? fvgVwap : na, style=shape.diamond, location=location.absolute, color=dynamicDiamondColor, size=size.normal, title="Normal FVG", force_overlay=true)
plotshape(isFvgLarge  ? fvgVwap : na, style=shape.diamond, location=location.absolute, color=dynamicDiamondColor, size=size.large,  title="Large FVG",  force_overlay=true)
plotshape(isFvgHuge   ? fvgVwap : na, style=shape.diamond, location=location.absolute, color=dynamicDiamondColor, size=size.huge,   title="Huge FVG",   force_overlay=true)


// Label
if isfvgQualified
    label.new(
        bar_index,
        fvgVwap,
        "FVG",   
        style = label.style_label_center,
        textcolor = color.white,
        color = color.new(color.black, 100),
        size = size.normal
    )

// -------------------------------------------------------------
// 8. POI Zone Detection
// Detece impules moves up to defined lookback number of bars
// Impulse move is filtered by ATR threshhold
// Counts the number of green or red candles involved in  the move
// Green bars should represent the majority of the move and vice versa
// Stops scanning once impulse matching above crietria is detected
// -------------------------------------------------------------

// --- 8a.  DYNAMIC IMPULSE DETECTION---

var int lastPOIbar = na

// max bars to look back for an impulse move
int maxImpulse = impulseLen   

bool dynBull = false
bool dynBear = false
int  dynLen  = na
int  dynStart = na

for i = 1 to maxImpulse
    float move = close - close[i]
    float atrStart = dailyAtr[i]

    bool bullMove = move >  impulseMult * atrStart
    bool bearMove = move < -impulseMult * atrStart

    // directional consistency check
    int bullCount = 0
    int bearCount = 0
    for k = 0 to i - 1
        if close[k] > close[k+1]
            bullCount += 1
        else
            bearCount += 1

    int minCons = math.round(i * 0.6)

    if bullMove and bullCount >= minCons
        dynBull := true
        dynLen  := i
        dynStart := bar_index - i
        break

    if bearMove and bearCount >= minCons
        dynBear := true
        dynLen  := i
        dynStart := bar_index - i
        break


// ----5b. Is Impulse ----
bool isBullImpulse = dynBull
bool isBearImpulse = dynBear


// ----8c. POI lengths and starting bar  ----
int impulseOffset = dynLen          // number of bars in the impulse
int impulseOrigin = dynStart        // bar_index of impulse start

//--------------------------------------------------
// 9. Base Identification
// Search number of bars before impulse breakout  
// Derive zone boundaries and leftmost bar_index
// ---------------------------------------------------

float baseTop    = na
float baseBottom = na
int   baseLeft   = na
int   baseBarsFound = 0


// --- 9a. Detect range before impule (breakou) ----

if isBullImpulse or isBearImpulse
    float _hi = na
    float _lo = na
    int   _count = 0

    // scan bars BEFORE the impulse start
    for i = 1 to baseLookback
        int idx = impulseOffset + i   // bars behind the impulse
        float barRange = high[idx] - low[idx]
        bool isTight = barRange < baseTightMult * dailyAtr[idx] //tight bar = total range < baseTightMult × ATR at that bar


        // take the FIRST tight bar only/ 
        if isTight and na(_hi)
            _hi := high[idx]
            _lo := low[idx]
            baseLeft := bar_index - idx
            baseBarsFound := 1
            break   // ← IMPORTANT: stop scanning older bars


    if baseBarsFound == 1
        baseTop := _hi
        baseBottom := _lo


// ---9b.  Is POI ----
bool isBullPOI = isBullImpulse and not na(baseTop) and showPOI // demand zone
bool isBearPOI = isBearImpulse and not na(baseTop) and showPOI // supply zone


// -----------------------------------------------------------------
// 10. TRAP CLASSIFICATION HOOK (stub)
// NOT IN USE -- Placeholder code stub using EMA cross over logic
// -----------------------------------------------------------------

float trendEma   = ta.ema(close, trendLen)
bool bullish = close > trendEma
bool bearish = close < trendEma

// trap logic --placeholder not in use
bool isTrap = (isBullPOI and bearish) or (isBearPOI and bullish)


//--------------------------------------------------
// 11. POI STORAGE
//--------------------------------------------------

var box[]   poiBoxes     = array.new_box()
var float[] poiTops      = array.new_float()
var float[] poiBottoms   = array.new_float()
var int[]   poiBirths    = array.new_int()
var bool[]  poiDirections = array.new_bool()  
var bool[]  poiTraps     = array.new_bool()
var bool[] poiActive = array.new_bool()
var poiLabels = array.new_label()

bool cooldownActive = not na(lastPOIbar) and (bar_index - lastPOIbar < cooldownBars)

if (isBullPOI or isBearPOI) and not cooldownActive and barstate.isconfirmed 
    lastPOIbar := bar_index
    color zoneColor = isBullPOI ? color.new(color.teal, 85) : color.new(color.red, 85)

    newBox = box.new(
         left         = baseLeft,
         right        = bar_index,
         top          = baseTop,
         bottom       = baseBottom,
         bgcolor      = zoneColor,
         border_width = 0
         )
         
    newLabel = label.new(
     x     = baseLeft,
     y     = (baseTop + baseBottom) / 2,
     text  = "POI",
     style = label.style_label_left,
     color = color.new(color.white, 0),
     textcolor = color.black,
     size  = size.tiny
    )
     
    array.push(poiBoxes,      newBox)
    array.push(poiTops,       baseTop)
    array.push(poiBottoms,    baseBottom)
    array.push(poiBirths,     bar_index)
    array.push(poiDirections, isBullPOI)
    array.push(poiTraps,      isTrap)
    array.push(poiActive, true)
    array.push(poiLabels, newLabel)


// ── UPDATE LOOP ───────────────────────────────────────────────────────────────
// body-close invalidation consistent with Jannu
// supply zone: body close above zone top = invalidated (price broke through)
// demand zone: body close below zone bottom = invalidated

if array.size(poiBoxes) > 0
    for i = array.size(poiBoxes) - 1 to 0
        b         = array.get(poiBoxes,      i)
        zTop      = array.get(poiTops,       i)
        zBot      = array.get(poiBottoms,    i)
        birth     = array.get(poiBirths,     i)
        isDemand  = array.get(poiDirections, i)
        isActive  = array.get(poiActive, i)
        lbl      = array.get(poiLabels, i)  

       
        boxLeft = box.get_left(b)
        boxTop  = box.get_top(b)
        boxBot  = box.get_bottom(b)

        label.set_x(lbl, boxLeft)
        label.set_y(lbl, (boxTop + boxBot) / 2)

 
        // only extend if active
        if isActive
            box.set_right(b, bar_index)
        else
             // inactive → grey
            box.set_bgcolor(b, color.new(color.gray, 85)) 
            
            if not na(label.get_text(lbl))
                //label.delete(lbl)
                label.set_text(lbl, "")
                label.set_color(lbl, color.new(color.gray, 100))

        bool zoneInvalidated = false

        if barstate.isconfirmed and isActive
            float bodyHigh = math.max(open, close)
            float bodyLow  = math.min(open, close)

            if isDemand
                // demand zone invalidated when body closes below zone bottom
                zoneInvalidated := bodyLow < zBot
            else
                // supply zone invalidated when body closes above zone top
                zoneInvalidated := bodyHigh > zTop

        // hard expiry
        int age = bar_index - birth
        if zoneInvalidated or age >= POIAge
            array.set(poiActive, i, false)
             // do NOT set right edge again — it is already frozen
````
