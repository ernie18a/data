# FVG RADAR Scanner | julzALGO

- url: https://www.tradingview.com/script/2BtHiPWs-FVG-RADAR-Scanner-julzALGO/
- type: indicator
- pine_id: PUB;58ce02f9d1f3437ca4c96f49164b5aab
- version: 1.0

## Description

📘 Summary

FVG RADAR Scanner is a Fair Value Gap detection, directional liquidity intelligence, and radar-based market imbalance framework designed to transform traditional FVG scanning into a structured visual market detection system.

🔷 RADAR = Range Analysis Detection And Reaction
This framework expands beyond traditional Fair Value Gap indicators by combining:
• Range positioning
• Structural analysis
• Imbalance detection
• Contextual liquidity integration
• Strategic trader reaction
Rather than only plotting bullish and bearish imbalance zones, this framework scans historical price action, identifies Fair Value Gaps, tracks whether they remain active or filled, estimates directional buy/sell participation, and converts these structures into a radar-style interface that visually maps liquidity zones, imbalance strength, and bull vs bear dominance around current market price.
This creates a hybrid between:
• Fair Value Gap Scanner
• Liquidity Mapping Engine
• Radar Visualization System
• Directional Volume Allocation Dashboard
• Bull vs Bear Dominance Scanner
The result is a structured market intelligence environment where traders can monitor:
• Range location relative to liquidity
• Where imbalance originated
• Which FVGs remain active
• Which side (bulls or bears) created stronger displacement
• Which gaps are strongest
• Which zones are closest to current price
• How FVGs are detected, filtered, and converted into radar targets
• Whether nearby liquidity is currently being scanned
• Whether directional flow currently favors buyers or sellers

📘 Features

🔷 Historical FVG Scanner
Automatically scans customizable historical lookback ranges to identify:
• Bullish FVGs (upward displacement inefficiencies)
• Bearish FVGs (downward displacement inefficiencies)
• Gap size ranking
• Filled vs Unfilled FVG status
• Largest structural imbalance
https://www.tradingview.com/x/ec4lhkga/

🔷 Radar Display Engine
Transforms detected FVGs into a circular radar-based liquidity system:
• Live radar rings
• Clockwise sweep scanner
• Sweep trail
• Detection diamonds (blips)
• MAX priority signal
• Relative FVG distance from current price
https://www.tradingview.com/x/k1EnuS3f/

🔷 Directional Bias Radar
Expands traditional FVG detection into directional dominance analysis:
• Bull FVG count
• Bear FVG count
• Buy vs Sell FVG volume
• Dominant directional FLOW
• Structural bull vs bear imbalance scoreboard
https://www.tradingview.com/x/1gxIva2Y/

🔷 FVG Zone Mapping
Plots full FVG structures directly on chart:
• Bullish FVG zones
• Bearish FVG zones
• Largest FVG highlighted as dominant liquidity
• Optional unfilled-only mode
🟣 Bear Zone
● Price
🔷 Bull Zone
🔶 MAX
🔷 Directional Volume Modeling
https://www.tradingview.com/x/H9mNXMB1/

Uses candle anatomy and estimated directional participation:
• Estimated Buy Volume
• Estimated Sell Volume
• Buy/Sell imbalance
• FVG-specific volume distribution
• Dominance %

🔷 FVG Intelligence Dashboard
Displays:
• Bullish FVG count
• Bearish FVG count
• Active / Filled ratio
• Total FVG volume
• Buy vs Sell participation
• Dominant FLOW bias
• Largest FVG location
https://www.tradingview.com/x/pi22OO62/

📘 Logic

🔷 Core Concept: Radar for Market Imbalance
Traditional Fair Value Gap indicators often focus only on plotting static imbalance zones.
FVG Radar Scanner expands this concept by combining liquidity location, directional pressure, structural imbalance, target qualification, and trader response into a broader strategic framework:

🔷 RADAR = Range Analysis Detection And Reaction

🔷 R — Range
Where is price positioned relative to surrounding liquidity?
The radar rings spatially organize qualified FVGs around current market price:
• Inner Ring → Closest liquidity
• Middle Ring → Mid-range liquidity
• Outer Ring → Major liquidity zones
https://www.tradingview.com/x/XKlz1OZp/

🔷 A — Analysis
What is happening structurally?
The framework analyzes:
• Bull vs Bear count
• Buy vs Sell flow
• MAX strength
• Structural dominance
https://www.tradingview.com/x/CWqaSsMQ/

🔷 D — Detection
What imbalance currently exists?
Using 3-candle displacement logic:
Bullish FVG: Current low > High 2 candles ago
Bearish FVG: Current high < Low 2 candles ago

🔷 FVG Detection to Radar Conversion Process
The radar does not randomly generate targets.
Every radar diamond begins as a historically detected Fair Value Gap.

Step 1 — Detect
The scanner reviews historical bars across selected lookback.
Bull:
Low(3) > High(1)
Bear:
High(3) < Low(1)

Step 2 — Filter
Detected FVGs are qualified by:
• Minimum gap size
• Tick threshold
• ATR filter (optional)
• Filled / Unfilled condition
Detect
 ↓
Gap Size
 ↓
ATR Filter
 ↓
Qualified

Step 3 — Convert
Qualified FVGs are converted into radar coordinates based on:
• Distance from current price
• Gap size
• Bull/Bear type
• Strength rank
• MAX status
FVG Zone
  ↓
Distance
  ↓
Ring Placement
  ↓
Diamond

Step 4 — Scan
Radar Sweep Logic
The sweep scanner functions as an active liquidity detection and target-priority system.
When sweep overlaps a radar diamond:
SCAN HIT
The radar reveals:
• Bull/Bear type
• Price level
• Distance
• Strength
• MAX status
https://www.tradingview.com/x/Pu3bbyMD/
https://www.tradingview.com/x/ZbyhBypK/

How do liquidity structure flow connect?
Liquidity :
 + Structure
 + Flow
 = Context

🔷 R — Reaction
What should traders do next?
• Pullback
• Retest
• Rejection
• Continuation
• Risk management
Detect
 ↓
Prioritize
 ↓
React

🔷 Volume Estimation Model
This script does not treat raw volume as neutral.
Using:
• Close position
• Wick structure
• Candle body ratio
• Range efficiency
Wicks + Body + Close
        ↓
Buy / Sell Estimate

📘 Usage

🔷 Best For
• FVG traders
• Smart Money Concept traders
• Liquidity sweep traders
• Pullback / retest traders
• Institutional repricing analysis
• Bull versus Bear dominance tracking
• Traders who want a visual map of imbalance above and below current price

🔷 How to Read the Illustration
This illustration shows how the FVG Radar Scanner converts chart-based Fair Value Gaps into a radar-style liquidity map.
https://www.tradingview.com/x/e5RnNSD9/
The chart and radar should be read together:
• FVG boxes show the actual imbalance zones on price
• Radar diamonds show where those FVGs are positioned relative to current price
• The sweep highlights nearby or important radar targets
• The info table summarizes bull/bear imbalance, volume, FLOW, and MAX location

🔷 Quick Visual Legend
🟣 Purple FVG Box / Diamond
→ Bearish FVG
→ Premium supply
→ Potential resistance, rejection, or mitigation zone
🔷 Blue FVG Box / Diamond
→ Bullish FVG
→ Discount demand
→ Potential support, pullback defense, or reaction zone
🔶 Gold MAX FVG
→ Largest detected Fair Value Gap
→ Strongest displacement zone in the scan
→ Major retest or reaction candidate
● Current Price
→ Market decision point
→ Center of the current supply-versus-demand battlefield

🔷 Battlefield Reading

In the example image:

• Purple FVGs are positioned above price
• Blue FVGs are stacked below price
• Gold MAX FVG is above current price
• Radar shows a stronger cluster of blue FVGs below the market
• The dashboard shows bull/bear count, volume, FLOW, and MAX price

This means price is trading between overhead premium supply and lower discount demand.

The market is inside a liquidity battlefield:

        🟣 ABOVE PRICE
        Bearish FVG / Supply
        Premium imbalance
        Possible resistance

                ↓

        ● CURRENT PRICE
        Decision zone
        Bull/Bear pressure center

                ↓

        🔷 BELOW PRICE
        Bullish FVG / Demand
        Discount imbalance
        Possible support

🔷 FVG Box Retest Framework

FVG boxes are not only visual zones. They are potential retest, mitigation, rejection, or continuation areas.
🔷 Bullish FVG Retest:
When price pulls back into a blue bullish FVG box:
→ Potential discount retest
→ Watch for support, mitigation, reclaim, or continuation
→ If defended, the zone may act as demand
https://www.tradingview.com/x/mnQPpOhe/
Price expands upward
↓
Price pulls back
↓
[ 🔷 Bullish FVG Box ]
↓
Hold / Reclaim
↓
Potential continuation upward

🟣Bearish FVG Retest: 
When price rallies into a purple bearish FVG box:
→ Potential premium retest
→ Watch for rejection, mitigation, failed reclaim, or continuation lower
→ If rejected, the zone may act as supply
https://www.tradingview.com/x/7NzU5DqK/
Price expands downward
↓
Price rallies back
↓
[ 🟣 Bearish FVG Box ]
↓
Reject / Fail
↓
Potential continuation downward

🔶MAX FVG Retest

The gold MAX FVG marks the largest detected imbalance.

If MAX is above price:
https://www.tradingview.com/x/K6BcfMgc/
→ Major premium retest candidate
→ Potential resistance
→ Watch for rejection or failed reclaim

If MAX is below price:
https://www.tradingview.com/x/MAkoi8cA/
→ Major discount retest candidate
→ Potential support
→ Watch for defense or reclaim

🔷 Sweep + Retest Priority
The sweep scanner adds priority to the radar map.
When the sweep hits an FVG while price is near or retesting that same zone, the setup becomes more important.
Sweep Hit + Bullish FVG Retest
• Sweep detects Bull FVG
• Price pulls into the blue FVG box
→ Potential demand defense zone
Sweep Hit + Bearish FVG Retest
• Sweep detects Bear FVG
• Price rallies into the purple FVG box
→ Potential supply rejection zone
Sweep Hit + MAX FVG
• Sweep detects the gold MAX FVG
→ Highest-priority imbalance zone in the current scan
🔷 Practical Reading Workflow
1. Locate Current Price
First, identify whether price is trading closer to upper bearish FVGs or lower bullish FVGs.
2. Check Nearby FVG Boxes
Look for the closest active FVG zones above and below price.
3. Watch the Radar Blips
Use the radar to see whether imbalance is clustered above price, below price, or balanced on both sides.
4. Monitor Sweep Hits
A SCAN HIT means the radar is actively prioritizing that FVG target.
5. Confirm With Price Action
Use reaction, rejection, reclaim, candle close, BOS / CHoCH, or your confirmation model before making decisions.
🔷 Practical Frameworks
Bullish Framework
Bullish FVG below or near current price
→ Potential discount imbalance
→ Watch for pullback, mitigation, reclaim, or defense
Bearish Framework
Bearish FVG above or near current price
→ Potential premium imbalance
→ Watch for rejection, mitigation, or supply response
Retest Framework
Price returns into an existing FVG box
→ Watch whether imbalance holds, fails, or fully mitigates
Sweep Framework
Sweep hit on nearby FVG
→ Active liquidity awareness
→ Zone becomes short-term priority
MAX Framework
Gold MAX FVG
→ Largest displacement zone
→ Institutional imbalance anchor
→ High-priority retest or reaction candidate
🔷 Decision Model
Box = Zone
Radar = Map
Sweep = Priority
Retest = Decision
Reaction = Confirmation
🔷 Bottom Line
FVG Radar Scanner is designed to help traders move from simple imbalance detection into structured liquidity interpretation.
The boxes show where imbalance exists.
The radar shows where those imbalances sit relative to price.
The sweep highlights which zones deserve attention.
The retest shows whether the market respects or invalidates the imbalance.

📘 Settings

🔷 FVG Scanner
Scan Lookback Bars — Controls how many historical candles the scanner reviews to detect past Fair Value Gaps for radar qualification.
Minimum FVG Size (ticks) — Filters out smaller inefficiencies by requiring a minimum gap size before an FVG becomes valid.
Use ATR Gap Filter — Enables ATR-based volatility filtering so detected FVGs can adapt to market conditions.
ATR Length — Defines the ATR calculation period used for adaptive gap qualification.
Min Gap ATR Multiplier — Controls how large an FVG must be relative to ATR when ATR filtering is enabled.
Show Only Unfilled FVGs — Displays only active imbalance zones that have not yet been mitigated or filled.
Max Radar FVG Blips — Controls how many qualified FVG targets appear on the radar at one time.
🔷 Candle Marks
Show Diamond On Detection Candle — Places a diamond marker directly on the candle where a bullish or bearish FVG is first detected.
Show FVG Zones — Enables or disables full chart plotting of detected FVG zones.
Max Zones — Controls the maximum number of visible FVG zones plotted on chart.
🔷 Radar Display
Show FVG Radar — Enables or disables the radar interface.
Radar Location — Choose whether radar center is based on:
• Current Price
• Range Mid
Radar Offset Bars — Moves the radar horizontally away from live candles for better visibility.
Radar Horizontal Radius — Controls radar width.
Radar ATR Radius Multiplier — Controls radar height scaling relative to volatility.
Show Clockwise Sweep — Enables active radar scanning sweep.
Sweep Speed — Controls sweep rotation speed.
Show Sweep Trail — Displays trailing sweep lines for visual scanning effect.
Sweep Hit Width Degrees — Controls how precise or wide the sweep detection zone is.
Show Radar Text — Displays SCAN HIT and FVG details when targets are scanned.
🔷 FVG Info Table
Show FVG Info Table — Displays the directional intelligence dashboard showing:
• Bull count
• Bear count
• Active / Filled
• Volume
• Buy/Sell
• FLOW
• MAX
🔷 Style
Bullish FVG Color — Sets bullish FVG color.
Bearish FVG Color — Sets bearish FVG color.
Largest FVG Color (MAX) — Sets dominant liquidity highlight color.
Radar Grid Color — Controls radar ring/grid appearance.
Radar Sweep Color — Controls sweep scanner color.
Zone Transparency — Adjusts active FVG zone visibility.
Filled Zone Transparency — Adjusts mitigated FVG visibility.

📘 Disclaimer
This script is an educational and analytical framework designed to visualize Fair Value Gaps, directional imbalance, liquidity positioning, structural bull vs bear dominance, and radar-based trader response.
It does not predict future price movement and should not be used as standalone financial advice.
Always combine with:
• Market structure
• BOS / CHoCH
• Confirmation
• Risk management
julzALGO frameworks are designed to improve market interpretation, liquidity awareness, structural bias recognition, and strategic reaction planning — not guarantee outcomes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © julzALGO

//@version=6
indicator("FVG RADAR Scanner | julzALGO", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_polylines_count=100, max_bars_back=5000, calc_bars_count=1500)

//────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────
groupFVG = "FVG SCANNER"
lookback = input.int(600, "Scan Lookback Bars", minval=50, maxval=1000, group=groupFVG)
minGapTicks = input.int(2, "Minimum FVG Size (ticks)", minval=1, maxval=500, group=groupFVG)
useAtrFilter = input.bool(false, "Use ATR Gap Filter", group=groupFVG)
atrLen = input.int(100, "ATR Length", minval=1, group=groupFVG)
minGapAtrMult = input.float(0.05, "Min Gap ATR Multiplier", minval=0.0, step=0.01, group=groupFVG)
showOnlyUnfilled = input.bool(true, "Show Only Unfilled FVGs", group=groupFVG)
maxRadarBlips = input.int(14, "Max Radar FVG Blips", minval=3, maxval=30, group=groupFVG)

groupMarks = "CANDLE MARKS"
showDiamonds = input.bool(true, "Show Diamond On Detection Candle", group=groupMarks)
showFVGZones = input.bool(true, "Show FVG Zones", group=groupMarks)
maxZones = input.int(80, "Max Zones", minval=10, maxval=250, group=groupMarks)

groupRadar = "RADAR DISPLAY"
showRadar = input.bool(true, "Show FVG Radar", group=groupRadar)
radarCenterMode = input.string("Current Price", "Radar Location", options=["Current Price", "Range Mid"], group=groupRadar)
radarOffset = input.int(22, "Radar Offset Bars", minval=5, maxval=100, group=groupRadar)
radarRadiusBars = input.int(22, "Radar Horizontal Radius", minval=8, maxval=60, group=groupRadar)
radarAtrMult = input.float(8.0, "Radar ATR Radius Mult", minval=1.0, step=0.5, group=groupRadar)
showSweep = input.bool(true, "Show Clockwise Sweep", group=groupRadar)
sweepSpeed = input.int(8, "Sweep Speed", minval=1, maxval=30, group=groupRadar)
showSweepTrail = input.bool(true, "Show Sweep Trail", group=groupRadar)
sweepHitWidthDeg = input.float(16.0, "Sweep Hit Width Degrees", minval=4.0, maxval=60.0, step=1.0, group=groupRadar)
showRadarText = input.bool(true, "Show Radar Text", group=groupRadar)

groupInfo = "FVG INFO TABLE"
showInfoBox = input.bool(true, "Show FVG Info Table", group=groupInfo)
int infoGapBars = 0
int infoWidthBars = 10

groupStyle = "STYLE"
bullCol = input.color(color.rgb(0, 176, 230), "Bullish FVG", group=groupStyle)
bearCol = input.color(color.rgb(137, 82, 255), "Bearish FVG", group=groupStyle)
pocCol = input.color(color.rgb(255, 196, 87), "Largest FVG", group=groupStyle)
gridCol = input.color(color.new(color.white, 78), "Radar Grid", group=groupStyle)
sweepCol = input.color(color.new(color.white, 35), "Radar Sweep", group=groupStyle)
zoneTransp = input.int(86, "Zone Transparency", minval=0, maxval=100, group=groupStyle)
filledTransp = input.int(94, "Filled Zone Transparency", minval=0, maxval=100, group=groupStyle)

//────────────────────────────────────────────
// HELPERS
//────────────────────────────────────────────
PI = 3.14159265359
TWO_PI = 6.28318530718
INFO_TEXT_CLAMP_TICKS = 8.0

clampFloat(x, lo, hi) =>
    math.max(lo, math.min(hi, x))

angleDiff(a, b) =>
    float d = math.abs(a - b)
    d > PI ? TWO_PI - d : d

fmtVol(v) =>
    float av = math.abs(v)
    av >= 1000000000 ? str.tostring(av / 1000000000, "#.##") + "B" :
     av >= 1000000 ? str.tostring(av / 1000000, "#.##") + "M" :
     av >= 1000 ? str.tostring(av / 1000, "#.#") + "K" :
     str.tostring(av, "#")

fmtDist(px) =>
    close != 0 ? str.tostring(math.abs(px - close) / close * 100.0, "#.##") + "%" : "0%"

safeInfoText(float top, float bot, string txt) =>
    float cellTicks = math.abs(top - bot) / syminfo.mintick
    cellTicks >= INFO_TEXT_CLAMP_TICKS ? txt : ""

makeRing(int cx, float cy, int rx, float ry, color css, int width) =>
    array<chart.point> pts = array.new<chart.point>()
    int steps = 72

    for n = 0 to steps
        float a = 2.0 * PI * n / steps
        int x = cx + int(math.round(math.cos(a) * rx))
        float y = cy + math.sin(a) * ry
        array.push(pts, chart.point.from_index(x, y))

    polyline.new(pts, false, false, xloc=xloc.bar_index, line_color=css, line_width=width)

makeInfoCell(int left, int right, float top, float bot, string txt, color txtCol, color bgCol, color borderCol, bool alignRight) =>
    box.new(
         left=left,
         top=top,
         right=right,
         bottom=bot,
         xloc=xloc.bar_index,
         bgcolor=bgCol,
         border_color=borderCol,
         border_width=1,
         text=safeInfoText(top, bot, txt),
         text_color=txtCol,
         text_size=size.auto,
         text_halign=alignRight ? text.align_right : text.align_left,
         text_valign=text.align_center
    )

//────────────────────────────────────────────
// STORAGE
//────────────────────────────────────────────
var box[] zoneBoxes = array.new<box>()
var box[] infoBoxes = array.new<box>()
var line[] radarLines = array.new<line>()
var label[] radarLabels = array.new<label>()
var polyline[] radarRings = array.new<polyline>()

clearDrawings() =>
    while array.size(zoneBoxes) > 0
        box.delete(array.pop(zoneBoxes))
    while array.size(infoBoxes) > 0
        box.delete(array.pop(infoBoxes))
    while array.size(radarLines) > 0
        line.delete(array.pop(radarLines))
    while array.size(radarLabels) > 0
        label.delete(array.pop(radarLabels))
    while array.size(radarRings) > 0
        polyline.delete(array.pop(radarRings))

//────────────────────────────────────────────
// RAW B/S VOLUME ESTIMATION
//────────────────────────────────────────────
float trNow = ta.tr(true)
float priceRange = math.max(trNow, syminfo.mintick)

float body = close - open
float bodySize = math.abs(body)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low

float totalCandle = bodySize + upperWick + lowerWick
totalCandle := totalCandle == 0 ? syminfo.mintick : totalCandle

float bodyRatio = body / priceRange
float wickBuy = lowerWick / totalCandle
float wickSell = upperWick / totalCandle
float closePos = clampFloat((close - low) / priceRange, 0.0, 1.0)

float buyStrength =
     closePos * 0.60 +
     wickBuy * 0.25 +
     math.max(0.0, bodyRatio) * 0.35

float sellStrength =
     (1.0 - closePos) * 0.60 +
     wickSell * 0.25 +
     math.max(0.0, -bodyRatio) * 0.35

float strengthTotal = buyStrength + sellStrength
strengthTotal := strengthTotal == 0 ? 1.0 : strengthTotal

float estBuyVol = volume * buyStrength / strengthTotal
float estSellVol = volume * sellStrength / strengthTotal

//────────────────────────────────────────────
// FVG DETECTION
//────────────────────────────────────────────
float atrNow = ta.atr(atrLen)
float minGapBase = syminfo.mintick * minGapTicks
float minGapNow = math.max(minGapBase, useAtrFilter ? atrNow * minGapAtrMult : 0.0)

bool bullFVG = bar_index >= 2 and low > high[2] and (low - high[2]) >= minGapNow
bool bearFVG = bar_index >= 2 and high < low[2] and (low[2] - high) >= minGapNow

plotshape(showDiamonds and bullFVG, title="Bullish FVG Diamond", style=shape.diamond, location=location.belowbar, color=color.new(bullCol, 0), size=size.tiny)
plotshape(showDiamonds and bearFVG, title="Bearish FVG Diamond", style=shape.diamond, location=location.abovebar, color=color.new(bearCol, 0), size=size.tiny)

// Calculated on every bar to avoid Pine consistency warnings.
float scanH = ta.highest(high, lookback)
float scanL = ta.lowest(low, lookback)
float scanRangeNow = math.max(nz(scanH - scanL, syminfo.mintick), syminfo.mintick)

//────────────────────────────────────────────
// RADAR SCAN
//────────────────────────────────────────────
if barstate.islast
    clearDrawings()

    float H = nz(scanH, high)
    float L = nz(scanL, low)
    float scanRange = scanRangeNow

    float[] fvgMidArr = array.new_float()
    float[] fvgTopArr = array.new_float()
    float[] fvgBotArr = array.new_float()
    float[] fvgGapArr = array.new_float()
    int[] fvgAgeArr = array.new_int()
    bool[] fvgBullArr = array.new_bool()
    bool[] fvgFilledArr = array.new_bool()

    int bullFvgCount = 0
    int bearFvgCount = 0
    int activeFvgCount = 0
    int filledFvgCount = 0
    float bullFvgVol = 0.0
    float bearFvgVol = 0.0
    float fvgBuyVolSum = 0.0
    float fvgSellVolSum = 0.0

    for k = 0 to lookback - 1
        if k + 2 <= bar_index
            float atrK = nz(atrNow[k], atrNow)
            float minGapK = math.max(minGapBase, useAtrFilter ? atrK * minGapAtrMult : 0.0)

            bool bullK = low[k] > high[k + 2] and (low[k] - high[k + 2]) >= minGapK
            bool bearK = high[k] < low[k + 2] and (low[k + 2] - high[k]) >= minGapK

            if bullK or bearK
                float top = bullK ? low[k] : low[k + 2]
                float bot = bullK ? high[k + 2] : high[k]
                float mid = math.avg(top, bot)
                float gap = math.abs(top - bot)

                bool filled = false

                if k > 0
                    for j = 0 to k - 1
                        if bullK and low[j] <= bot
                            filled := true
                        if bearK and high[j] >= top
                            filled := true

                bool keepFVG = showOnlyUnfilled ? not filled : true

                if keepFVG
                    float fvgBuyVol = nz(estBuyVol[k], 0) + nz(estBuyVol[k + 1], 0) + nz(estBuyVol[k + 2], 0)
                    float fvgSellVol = nz(estSellVol[k], 0) + nz(estSellVol[k + 1], 0) + nz(estSellVol[k + 2], 0)
                    float fvgTotVol = fvgBuyVol + fvgSellVol

                    array.push(fvgMidArr, mid)
                    array.push(fvgTopArr, top)
                    array.push(fvgBotArr, bot)
                    array.push(fvgGapArr, gap)
                    array.push(fvgAgeArr, k)
                    array.push(fvgBullArr, bullK)
                    array.push(fvgFilledArr, filled)

                    if bullK
                        bullFvgCount += 1
                        bullFvgVol += fvgTotVol
                    else
                        bearFvgCount += 1
                        bearFvgVol += fvgTotVol

                    if filled
                        filledFvgCount += 1
                    else
                        activeFvgCount += 1

                    fvgBuyVolSum += fvgBuyVol
                    fvgSellVolSum += fvgSellVol

    int fvgCount = array.size(fvgMidArr)
    float maxGap = 0.0
    int strongestIx = -1

    if fvgCount > 0
        for i = 0 to fvgCount - 1
            float g = array.get(fvgGapArr, i)
            if g > maxGap
                maxGap := g
                strongestIx := i

    //────────────────────────────────────────
    // FVG ZONES
    //────────────────────────────────────────
    if showFVGZones and fvgCount > 0
        int drawn = 0

        for i = 0 to fvgCount - 1
            if drawn < maxZones
                float top = array.get(fvgTopArr, i)
                float bot = array.get(fvgBotArr, i)
                int age = array.get(fvgAgeArr, i)
                bool isBull = array.get(fvgBullArr, i)
                bool filled = array.get(fvgFilledArr, i)
                bool isStrongest = i == strongestIx

                int detectBar = bar_index - age
                int leftX = math.max(0, detectBar - 2)
                int rightX = bar_index

                color baseCol =
                     isStrongest ? pocCol :
                     isBull ? bullCol :
                     bearCol

                box z = box.new(
                     left=leftX,
                     top=top,
                     right=rightX,
                     bottom=bot,
                     xloc=xloc.bar_index,
                     bgcolor=color.new(baseCol, filled ? filledTransp : zoneTransp),
                     border_color=color.new(baseCol, filled ? 90 : 55),
                     border_width=isStrongest ? 2 : 1
                )
                array.push(zoneBoxes, z)

                drawn += 1

    //────────────────────────────────────────
    // RADAR PANEL - ALWAYS NEAR CURRENT
    //────────────────────────────────────────
    if showRadar
        int rx = radarRadiusBars
        int infoWidth = infoWidthBars
        int rightNeed = rx + (showInfoBox ? infoGapBars + infoWidth : 0)
        int maxCx = bar_index + 480 - rightNeed

        int cx = bar_index + radarOffset
        cx := math.min(cx, maxCx)
        cx := math.max(rx, cx)

        float cy = radarCenterMode == "Range Mid" ? math.avg(H, L) : close

        float priceRadius = math.max(atrNow * radarAtrMult, scanRange * 0.38)
        priceRadius := math.max(priceRadius, syminfo.mintick * 20.0)

        int tickSeed = int(timenow / 1000)
        float sweepDegrees = (bar_index * sweepSpeed + tickSeed * sweepSpeed) % 360
        float sweepAngle = -sweepDegrees * PI / 180.0
        sweepAngle := sweepAngle < 0 ? sweepAngle + TWO_PI : sweepAngle

        float hitWidth = sweepHitWidthDeg * PI / 180.0

        array.push(radarRings, makeRing(cx, cy, int(rx * 0.33), priceRadius * 0.33, color.new(gridCol, 12), 1))
        array.push(radarRings, makeRing(cx, cy, int(rx * 0.66), priceRadius * 0.66, color.new(gridCol, 4), 1))
        array.push(radarRings, makeRing(cx, cy, rx, priceRadius, gridCol, 1))

        line hLine = line.new(cx - rx, cy, cx + rx, cy, xloc=xloc.bar_index, color=color.new(gridCol, 22), width=1, style=line.style_dotted)
        line vLine = line.new(cx, cy - priceRadius, cx, cy + priceRadius, xloc=xloc.bar_index, color=color.new(gridCol, 22), width=1, style=line.style_dotted)

        array.push(radarLines, hLine)
        array.push(radarLines, vLine)

        if showSweep
            if showSweepTrail
                for t = 1 to 4
                    float trailAngle = sweepAngle + t * PI / 18.0
                    int trailX = cx + int(math.round(math.cos(trailAngle) * rx))
                    float trailY = cy + math.sin(trailAngle) * priceRadius
                    line trail = line.new(cx, cy, trailX, trailY, xloc=xloc.bar_index, color=color.new(sweepCol, 35 + t * 12), width=1)
                    array.push(radarLines, trail)

            int sweepX = cx + int(math.round(math.cos(sweepAngle) * rx))
            float sweepY = cy + math.sin(sweepAngle) * priceRadius
            line sweep = line.new(cx, cy, sweepX, sweepY, xloc=xloc.bar_index, color=sweepCol, width=2)
            array.push(radarLines, sweep)

        label centerDot = label.new(cx, cy, "•", xloc=xloc.bar_index, style=label.style_none, textcolor=color.new(color.white, 0), color=color.new(color.black, 100), size=size.small)
        array.push(radarLabels, centerDot)

        if fvgCount > 0 and maxGap > 0
            bool[] picked = array.new_bool(fvgCount, false)
            float maxDistance = math.max(math.abs(H - close), math.abs(close - L))
            maxDistance := math.max(maxDistance, syminfo.mintick)

            for pick = 0 to maxRadarBlips - 1
                int bestIx = -1
                float bestScore = -1.0

                for i = 0 to fvgCount - 1
                    float gap = array.get(fvgGapArr, i)
                    if not array.get(picked, i) and gap > bestScore
                        bestScore := gap
                        bestIx := i

                if bestIx >= 0
                    array.set(picked, bestIx, true)

                    float mid = array.get(fvgMidArr, bestIx)
                    float gap = array.get(fvgGapArr, bestIx)
                    bool isBull = array.get(fvgBullArr, bestIx)
                    bool filled = array.get(fvgFilledArr, bestIx)
                    bool isStrongest = bestIx == strongestIx

                    float strength = maxGap > 0 ? gap / maxGap : 0.0
                    float dist = mid - close
                    float distNorm = clampFloat(math.abs(dist) / maxDistance, 0.10, 1.0)

                    float baseAngle = dist >= 0 ? PI / 2.0 : PI * 1.5
                    float spread = ((bestIx % 7) - 3) * (PI / 28.0)
                    float angle = baseAngle + spread
                    angle := angle < 0 ? angle + TWO_PI : angle
                    angle := angle > TWO_PI ? angle - TWO_PI : angle

                    float sweepDist = angleDiff(angle, sweepAngle)
                    bool scannerHit = showSweep and sweepDist <= hitWidth

                    int blipX = cx + int(math.round(math.cos(angle) * rx * distNorm))
                    float blipY = cy + math.sin(angle) * priceRadius * distNorm

                    color blipCol =
                         isStrongest ? pocCol :
                         isBull ? bullCol :
                         bearCol

                    int baseTransp = filled ? 75 : 28
                    int hitTransp = filled ? 38 : 0
                    int blipTransp = scannerHit ? hitTransp : baseTransp

                    string blipSize =
                         scannerHit ? size.normal :
                         strength >= 0.80 ? size.normal :
                         strength >= 0.50 ? size.small :
                         size.tiny

                    label blip = label.new(blipX, blipY, "", xloc=xloc.bar_index, style=label.style_diamond, color=color.new(blipCol, blipTransp), textcolor=blipCol, size=blipSize)
                    array.push(radarLabels, blip)

                    if scannerHit
                        label ping = label.new(blipX, blipY, "", xloc=xloc.bar_index, style=label.style_circle, color=color.new(blipCol, 72), textcolor=blipCol, size=size.large)
                        array.push(radarLabels, ping)

                    if showRadarText and (isStrongest or strength >= 0.60 or scannerHit)
                        string sideTxt = isBull ? "Bull FVG" : "Bear FVG"
                        string txt =
                             (scannerHit ? "SCAN HIT\n" : "") +
                             (isStrongest ? "MAX\n" : "") +
                             sideTxt +
                             "\n" + str.tostring(mid, format.mintick) +
                             "\n" + fmtDist(mid)

                        label info = label.new(blipX + 1, blipY, txt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 84), textcolor=blipCol, size=size.tiny, text_font_family=font.family_monospace)
                        array.push(radarLabels, info)

        //────────────────────────────────────
        // RIGHT SIDE INFO TABLE
        //────────────────────────────────────
        if showInfoBox
            int infoLeft = cx + rx + infoGapBars
            int infoRight = infoLeft + infoWidth
            int infoMid = infoLeft + int(math.round(infoWidth * 0.45))

            float topPanel = cy + priceRadius
            float botPanel = cy - priceRadius
            float rowH = (topPanel - botPanel) / 8.0

            float totalFvgVol = bullFvgVol + bearFvgVol
            float netVol = fvgBuyVolSum - fvgSellVolSum
            float domPct = totalFvgVol > 0 ? math.abs(netVol) / totalFvgVol * 100.0 : 0.0

            string biasTxt = netVol > 0 ? "BUY" : netVol < 0 ? "SELL" : "NEU"
            color biasCol = netVol >= 0 ? bullCol : bearCol

            string maxTxt = "n/a"
            color maxCol = pocCol

            if strongestIx >= 0
                bool maxBull = array.get(fvgBullArr, strongestIx)
                float maxMid = array.get(fvgMidArr, strongestIx)
                maxTxt := (maxBull ? "B " : "S ") + str.tostring(maxMid, format.mintick)
                maxCol := maxBull ? bullCol : bearCol

            for r = 0 to 7
                float rowTop = topPanel - rowH * r
                float rowBot = topPanel - rowH * (r + 1)

                color bgCol = r == 0 ? color.new(pocCol, 82) : color.new(color.black, 84)
                color brdCol = color.new(chart.fg_color, 82)

                if r == 0
                    box headerCell = box.new(
                         left=infoLeft,
                         top=rowTop,
                         right=infoRight,
                         bottom=rowBot,
                         xloc=xloc.bar_index,
                         bgcolor=bgCol,
                         border_color=brdCol,
                         border_width=2,
                         text=safeInfoText(rowTop, rowBot, "FVG RADAR"),
                         text_color=pocCol,
                         text_size=size.auto,
                         text_halign=text.align_center,
                         text_valign=text.align_center
                    )
                    array.push(infoBoxes, headerCell)
                else
                    string leftTxt =
                         r == 1 ? "BULL" :
                         r == 2 ? "BEAR" :
                         r == 3 ? "ACTIVE" :
                         r == 4 ? "VOLUME" :
                         r == 5 ? "Buy/Sell" :
                         r == 6 ? "FLOW" :
                         "MAX"

                    string rightTxt =
                         r == 1 ? str.tostring(bullFvgCount) + " | " + fmtVol(bullFvgVol) :
                         r == 2 ? str.tostring(bearFvgCount) + " | " + fmtVol(bearFvgVol) :
                         r == 3 ? str.tostring(activeFvgCount) + " / " + str.tostring(filledFvgCount) :
                         r == 4 ? fmtVol(totalFvgVol) :
                         r == 5 ? fmtVol(fvgBuyVolSum) + " / " + fmtVol(fvgSellVolSum) :
                         r == 6 ? biasTxt + "  " + str.tostring(domPct, " # ") + " % " :
                         maxTxt

                    color leftCol =
                         r == 1 ? bullCol :
                         r == 2 ? bearCol :
                         r == 6 ? biasCol :
                         r == 7 ? maxCol :
                         chart.fg_color

                    color rightCol =
                         r == 1 ? bullCol :
                         r == 2 ? bearCol :
                         r == 6 ? biasCol :
                         r == 7 ? maxCol :
                         chart.fg_color

                    box lCell = makeInfoCell(infoLeft, infoMid, rowTop, rowBot, leftTxt, leftCol, bgCol, brdCol, false)
                    box rCell = makeInfoCell(infoMid, infoRight, rowTop, rowBot, rightTxt, rightCol, bgCol, brdCol, true)

                    array.push(infoBoxes, lCell)
                    array.push(infoBoxes, rCell)

alertcondition(bullFVG, "Bullish FVG Detected", "Bullish FVG detected by FVG Radar Scanner.")
alertcondition(bearFVG, "Bearish FVG Detected", "Bearish FVG detected by FVG Radar Scanner.")
````
