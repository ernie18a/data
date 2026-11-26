# Strong Candlestick Patterns | ProjectSyndicate

- url: https://www.tradingview.com/script/UJvedU2W-Strong-Candlestick-Patterns-ProjectSyndicate/
- type: indicator
- pine_id: PUB;1d4ed8392814489c974c0f0748d1f37f
- version: 1.0

## Description

[b]Strong Candlestick Patterns automatically detects, scores, and highlights 25 classic Japanese candlestick patterns using an objective, non-repainting engine built on the teachings of Steve Nison. It confirms every pattern on the bar close, grades each setup 0–10 for quality, draws it as a clean color-coded zone with a name label and ★ star rating, and surfaces the most recent signal on every timeframe through a non-intrusive multi-timeframe scanner — turning subjective candle-reading into a quantifiable, repeatable process.[/b]

🕯️ 25-Pattern Detection — recognizes the full Nison family from raw geometry: Hammer, Hanging Man, Inverted Hammer, Shooting Star, Dragonfly / Gravestone / Long-Legged Doji, Bullish / Bearish Marubozu, Bullish / Bearish Engulfing, Bullish / Bearish Harami, Piercing Line, Dark Cloud Cover, Tweezer Top / Bottom, Bullish / Bearish Windows (gaps), Morning Star, Evening Star, Three White Soldiers, Three Black Crows, and Rising / Falling Three Methods.
🔒 Close-Confirmed, Non-Repainting — patterns are evaluated on confirmed candles only; the live bar waits for its close before committing, so signals, zones, and labels are stable and never redrawn after the fact.
⭐ 0–10 Quality Scoring — every setup is graded by blending five factors Nison stresses: textbook shape fit (40%), candle significance vs ATR (22%), trend-context strength (18%), volume confirmation (12%), and EMA confluence (8%). The result is shown as a ★ star meter with a numeric score and a WEAK / MODERATE / STRONG / ELITE tier, so you can instantly gauge conviction and filter for only the best.

🧭 Trend-Context Gating — reversal patterns fire only counter-trend and continuation patterns only with-trend (toggleable), enforcing the core rule that a pattern is meaningless without the right preceding trend.
🎨 Direction-Matched Zones & Labels — each pattern is boxed as a blue (bullish), orange-red (bearish), or gray (neutral) zone spanning its candles, with a clean name label and rating placed above bearish setups and below bullish ones for instant, clutter-free read.
📡 Multi-Timeframe Scanner Row — a non-repainting top dashboard shows the symbol plus eight fully configurable timeframes (M15 → D1 by default), each displaying the latest pattern and its bars-ago count, with fresh signals highlighted so you can spot multi-timeframe alignment at a glance.
✅ Advanced Quality-Control Filters — strong-only mode (default: ELITE 8+), direction filter, ATR-based minimum candle-size gate, per-pattern shape tolerances (doji body %, shadow multiple, engulfing/tweezer/star ratios), minimum bars between signals, and individual on/off toggles for all twelve pattern groups eliminate noise and over-signaling.

🔔 Comprehensive Alerts — a single rich alert() message (direction, pattern name, 0–10 score, symbol, timeframe, close) for automation, plus three individually selectable named conditions: Bullish Pattern, Bearish Pattern, and Elite Pattern (8+).
🔧 Fully Customizable — control trend EMA and lookback, volume average, zone padding and transparency, bullish/bearish/neutral colors, label and scanner text sizes, scanner position, and the per-timeframe set.
🎯 Why this is unique: Standard candlestick tools simply paint a name on a candle with no context or grading. This is an objective, fully-gated, non-repainting engine that recognizes 25 patterns from raw OHLC geometry, confirms each on the close, validates it against trend context and volume, grades its quality 0–10, and tracks it across eight timeframes — so you act only on the highest-conviction setups instead of every random wick.

🚀 Apply to Gold (XAUUSD), Forex, Crypto, Indices, and equities on any timeframe. The ATR-based, self-scaling logic adapts from M5 scalping to H4/Daily swing trading.
🎯 How to use this? Favor higher-star (STRONG/ELITE) setups that align with the higher-timeframe trend shown in the scanner row. Use the strong-only threshold to keep the chart sparse and focus on quality; loosen the shape tolerances if a pattern fires too rarely on a given asset, or tighten them to reduce noise.

⚠️ IMPORTANT NOTICE: This indicator identifies quality-graded candlestick signals; it should NOT be used as a standalone entry trigger. Always combine it with your own trading strategy, price-action analysis, key support/resistance levels, and sound risk management to confirm setups.

## Source Code

````pine
//@version=6
indicator("Strong Candlestick Patterns", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)
gD            = "═══ Detection ═══"
dojiBodyPct   = input.float(8.0,  "Doji Max Body (% of range)",      minval=1.0, maxval=25.0, step=0.5, group=gD, tooltip="A candle is a doji when its body is at most this % of the full high-low range.")
shadowMult    = input.float(2.0,  "Hammer/Star Shadow (x body)",     minval=1.0, maxval=5.0,  step=0.1, group=gD, tooltip="Long shadow must be at least this multiple of the real body for Hammer / Shooting-Star family.")
smallBodyPct  = input.float(38.0, "Hammer/Star Body (% of range)",   minval=10.0,maxval=60.0, step=1.0, group=gD, tooltip="Real body must be at most this % of the range to qualify as a small-bodied reversal candle.")
maruBodyPct   = input.float(88.0, "Marubozu Body (% of range)",      minval=70.0,maxval=99.0, step=1.0, group=gD)
engBodyMult   = input.float(1.0,  "Engulfing Min Body (x prior)",    minval=0.6, maxval=3.0,  step=0.1, group=gD, tooltip="Engulfing body must be at least this multiple of the prior body.")
eqTolPct      = input.float(10.0, "Tweezer Equal Tol (% ATR)",       minval=1.0, maxval=40.0, step=1.0, group=gD, tooltip="Highs/lows are 'equal' for tweezers when within this % of ATR.")
starBodyPct   = input.float(45.0, "Star Body Max (% of avg)",        minval=10.0,maxval=80.0, step=1.0, group=gD, tooltip="Middle candle of Morning/Evening Star must be smaller than this % of the two outer bodies' average.")
sigAtrMult    = input.float(0.50, "Min Candle Size (x ATR)",         minval=0.0, maxval=3.0,  step=0.1, group=gD, tooltip="Ignore patterns whose key candle range is below this multiple of ATR (noise filter). 0 disables.")
minSpacing    = input.int(1,      "Min Bars Between Signals",        minval=0,   maxval=50,    group=gD)
gC            = "═══ Trend Context ═══"
requireCtx    = input.bool(true,  "Require Trend Context",           group=gC, tooltip="Reversal patterns only fire counter-trend; continuation patterns only fire with-trend. Off = detect everywhere.")
emaLen        = input.int(50,     "Trend EMA Length",                minval=5,   maxval=400,   group=gC)
trendLook     = input.int(8,      "Prior-Trend Lookback (bars)",     minval=2,   maxval=60,    group=gC)
volLen        = input.int(20,     "Volume Average Length",           minval=2,   maxval=200,   group=gC)
gF            = "═══ Filter ═══"
strongOnly    = input.bool(true, "Show Strong Patterns Only",       group=gF)
strongThr     = input.float(8.0,  "Strong Threshold (0-10)",         minval=0.0, maxval=10.0, step=0.5, group=gF)
sideFilter    = input.string("All","Direction Filter", options=["All","Bullish Only","Bearish Only"], group=gF)
gP            = "═══ Pattern Groups ═══"
pHammer       = input.bool(true,  "Hammer / Hanging Man",            inline="r1", group=gP)
pInvShoot     = input.bool(true,  "Inverted Hammer / Shooting Star", inline="r1", group=gP)
pDoji         = input.bool(true,  "Doji (Dragonfly/Gravestone/LL)",  inline="r2", group=gP)
pMaru         = input.bool(true,  "Marubozu",                        inline="r2", group=gP)
pEngulf       = input.bool(true,  "Engulfing",                       inline="r3", group=gP)
pHarami       = input.bool(true,  "Harami",                          inline="r3", group=gP)
pPierce       = input.bool(true,  "Piercing / Dark Cloud",           inline="r4", group=gP)
pTweezer      = input.bool(true,  "Tweezers",                        inline="r4", group=gP)
pWindow       = input.bool(true,  "Windows (Gaps)",                  inline="r5", group=gP)
pStar         = input.bool(true,  "Morning / Evening Star",          inline="r5", group=gP)
pThree        = input.bool(true,  "3 Soldiers / 3 Crows",            inline="r6", group=gP)
pMethods      = input.bool(true,  "Rising / Falling 3 Methods",      inline="r6", group=gP)
gV            = "═══ Display ═══"
showZones     = input.bool(true,  "Highlight Pattern Zones",         group=gV)
showLabels    = input.bool(true,  "Show Name Labels",                group=gV)
showStars     = input.bool(true,  "Append ★ Stars to Labels",        group=gV)
lblSize       = input.string("Small","Label Size", options=["Tiny","Small","Normal","Large"], group=gV)
zonePadPct    = input.float(8.0,  "Zone Padding (% ATR)",            minval=0.0, maxval=50.0, step=1.0, group=gV)
zoneAlpha     = input.int(80,     "Zone Transparency",               minval=0,   maxval=100,   group=gV)
gCol          = "═══ Colours ═══"
bullCol       = input.color(#2196f3, "Bullish",  inline="cc", group=gCol)
bearCol       = input.color(#ff5722, "Bearish",  inline="cc", group=gCol)
neutCol       = input.color(#9e9e9e, "Neutral",  inline="cc", group=gCol)
gS            = "═══ MTF Scanner ═══"
showScanner   = input.bool(true,  "Show MTF Scanner Row",            group=gS)
scanPos       = input.string("Top Center","Scanner Position", options=["Top Center","Top Right","Top Left","Bottom Center"], group=gS)
freshBars     = input.int(8,      "Highlight Fresh ≤ N bars",        minval=1, maxval=200, group=gS)
scanScoreMin  = input.float(0.0,  "Scanner Min Strength",            minval=0.0, maxval=10.0, step=0.5, group=gS, tooltip="Scanner ignores patterns weaker than this on each timeframe.")
tf1           = input.timeframe("15",  "TF 1", inline="t1", group=gS)
tf2           = input.timeframe("30",  "TF 2", inline="t1", group=gS)
tf3           = input.timeframe("60",  "TF 3", inline="t2", group=gS)
tf4           = input.timeframe("120", "TF 4", inline="t2", group=gS)
tf5           = input.timeframe("240", "TF 5", inline="t3", group=gS)
tf6           = input.timeframe("480", "TF 6", inline="t3", group=gS)
tf7           = input.timeframe("720", "TF 7", inline="t4", group=gS)
tf8           = input.timeframe("D",   "TF 8", inline="t4", group=gS)
dashSz        = input.string("Small","Scanner Text Size", options=["Tiny","Small","Normal"], group=gS)
gAl           = "═══ Alerts ═══"
alertsOn      = input.bool(true,  "Enable alert() Calls",            group=gAl)
alBull        = input.bool(true,  "Bullish Pattern",                 inline="a1", group=gAl)
alBear        = input.bool(true,  "Bearish Pattern",                 inline="a1", group=gAl)
alStrongAl    = input.bool(false, "Alert: Strong Only",              group=gAl)
float atr     = ta.atr(14)
float adr10   = request.security(syminfo.tickerid, "D", (math.sum(high[1] - low[1], 10)) / 10, lookahead=barmerge.lookahead_off)
float adrSafe = nz(adr10) > 0.0 ? adr10 : close * 0.005
float volAvg  = ta.sma(volume, volLen)
float emaT    = ta.ema(close, emaLen)
float bodyHi = math.max(open, close)
float bodyLo = math.min(open, close)
float body   = bodyHi - bodyLo
float rng    = high - low
float upSh   = high - bodyHi
float dnSh   = bodyLo - low
bool  isBull = close > open
bool  isBear = close < open
float rngS   = rng <= 0 ? syminfo.mintick : rng
float bodyS  = body <= 0 ? syminfo.mintick : body
float o1 = open[1],  c1 = close[1],  h1 = high[1],  l1 = low[1]
float o2 = open[2],  c2 = close[2],  h2 = high[2],  l2 = low[2]
float bHi1 = math.max(o1,c1), bLo1 = math.min(o1,c1), body1 = bHi1 - bLo1
float bHi2 = math.max(o2,c2), bLo2 = math.min(o2,c2), body2 = bHi2 - bLo2
bool  bull1 = c1 > o1, bear1 = c1 < o1
bool  bull2 = c2 > o2, bear2 = c2 < o2
bool  enough = bar_index > (trendLook + 6)
float riseAmt = enough ? (c1 - close[1 + trendLook]) : 0.0
float dropAmt = -riseAmt
bool  priorUp   = enough and (riseAmt >  atr * 0.3) and c1 > emaT[1]
bool  priorDown = enough and (dropAmt >  atr * 0.3) and c1 < emaT[1]
bool  ctxBullRev  = not requireCtx or priorDown
bool  ctxBearRev  = not requireCtx or priorUp
bool  ctxBullCont = not requireCtx or priorUp
bool  ctxBearCont = not requireCtx or priorDown
bool  bigEnough = sigAtrMult <= 0.0 or rng >= atr * sigAtrMult
float sizeQ = math.min(1.0, rng / (atr * 1.3 + 1e-9))
float volQ  = volAvg > 0 ? math.min(1.0, volume / (volAvg * 1.5)) : 0.5
float conflQ = math.max(0.0, 1.0 - math.abs(close - emaT) / (atr * 2.0 + 1e-9))
float ctxUpQ   = math.min(1.0, math.max(0.0, riseAmt) / (atr * trendLook * 0.22 + 1e-9))
float ctxDnQ   = math.min(1.0, math.max(0.0, dropAmt) / (atr * trendLook * 0.22 + 1e-9))
mkScore(float shapeQ, float ctxQ) =>
    float s = (0.40 * shapeQ + 0.22 * sizeQ + 0.18 * ctxQ + 0.12 * volQ + 0.08 * conflQ) * 10.0
    math.round(math.max(0.0, math.min(10.0, s)) * 10.0) / 10.0
patName(int i) =>
    switch i
        0  => "Hammer"
        1  => "Hanging Man"
        2  => "Inverted Hammer"
        3  => "Shooting Star"
        4  => "Dragonfly Doji"
        5  => "Gravestone Doji"
        6  => "Long-Legged Doji"
        7  => "Bullish Marubozu"
        8  => "Bearish Marubozu"
        9  => "Bullish Engulfing"
        10 => "Bearish Engulfing"
        11 => "Bullish Harami"
        12 => "Bearish Harami"
        13 => "Piercing Line"
        14 => "Dark Cloud Cover"
        15 => "Tweezer Bottom"
        16 => "Tweezer Top"
        17 => "Bullish Window"
        18 => "Bearish Window"
        19 => "Morning Star"
        20 => "Evening Star"
        21 => "Three White Soldiers"
        22 => "Three Black Crows"
        23 => "Rising Three Methods"
        24 => "Falling Three Methods"
        => "—"
patAbbr(int i) =>
    switch i
        0  => "Hammer"
        1  => "HangMan"
        2  => "InvHammer"
        3  => "ShootStar"
        4  => "Dragonfly"
        5  => "Gravestn"
        6  => "LLDoji"
        7  => "BullMaru"
        8  => "BearMaru"
        9  => "BullEng"
        10 => "BearEng"
        11 => "BullHar"
        12 => "BearHar"
        13 => "Pierce"
        14 => "DarkCloud"
        15 => "TweezBot"
        16 => "TweezTop"
        17 => "BullGap"
        18 => "BearGap"
        19 => "MorStar"
        20 => "EveStar"
        21 => "3Soldiers"
        22 => "3Crows"
        23 => "Rising3"
        24 => "Falling3"
        => "—"
patDir(int i) =>
    bool b = i==0 or i==2 or i==4 or i==7 or i==9 or i==11 or i==13 or i==15 or i==17 or i==19 or i==21 or i==23
    bool s = i==1 or i==3 or i==5 or i==8 or i==10 or i==12 or i==14 or i==16 or i==18 or i==20 or i==22 or i==24
    b ? 1 : s ? -1 : 0
patSpan(int i) =>
    i <= 8  ? 1 :
     i <= 18 ? 2 :
     i <= 22 ? 3 : 5
patEnabled(int i) =>
    switch i
        0 => pHammer
        1 => pHammer
        2 => pInvShoot
        3 => pInvShoot
        4 => pDoji
        5 => pDoji
        6 => pDoji
        7 => pMaru
        8 => pMaru
        9 => pEngulf
        10 => pEngulf
        11 => pHarami
        12 => pHarami
        13 => pPierce
        14 => pPierce
        15 => pTweezer
        16 => pTweezer
        17 => pWindow
        18 => pWindow
        19 => pStar
        20 => pStar
        21 => pThree
        22 => pThree
        23 => pMethods
        24 => pMethods
        => false
float eqTol = atr * eqTolPct / 100.0
bool  isDoji = body <= rngS * dojiBodyPct / 100.0
bool  smallBody = body <= rngS * smallBodyPct / 100.0
float starAvgBody = (body2 + body) / 2.0
scOf(bool cond, int id, float shapeQ, float ctxQ) =>
    (cond and patEnabled(id) and bigEnough) ? mkScore(shapeQ, ctxQ) : 0.0
var array<float> scArr = array.new<float>(25, 0.0)
for zi = 0 to 24
    array.set(scArr, zi, 0.0)
bool hammerShape = smallBody and not isDoji and dnSh >= bodyS * shadowMult and upSh <= bodyS * 0.6 and bodyLo >= low + rng * 0.45
float hammerQ = math.min(1.0, (dnSh / bodyS) / (shadowMult * 1.5)) * 0.6 + math.max(0.0, 1.0 - upSh/(bodyS+1e-9)) * 0.4
array.set(scArr, 0, scOf(hammerShape and ctxBullRev, 0, hammerQ, ctxDnQ))
array.set(scArr, 1, scOf(hammerShape and ctxBearRev, 1, hammerQ, ctxUpQ))
bool invShape = smallBody and not isDoji and upSh >= bodyS * shadowMult and dnSh <= bodyS * 0.6 and bodyHi <= high - rng * 0.45
float invQ = math.min(1.0, (upSh / bodyS) / (shadowMult * 1.5)) * 0.6 + math.max(0.0, 1.0 - dnSh/(bodyS+1e-9)) * 0.4
array.set(scArr, 2, scOf(invShape and ctxBullRev, 2, invQ, ctxDnQ))
array.set(scArr, 3, scOf(invShape and ctxBearRev, 3, invQ, ctxUpQ))
bool dragonfly = isDoji and dnSh >= rngS * 0.55 and upSh <= rngS * 0.12
bool gravestone= isDoji and upSh >= rngS * 0.55 and dnSh <= rngS * 0.12
bool llDoji    = isDoji and upSh >= rngS * 0.30 and dnSh >= rngS * 0.30 and not dragonfly and not gravestone
array.set(scArr, 4, scOf(dragonfly and ctxBullRev, 4, math.min(1.0, dnSh/(rngS*0.6)), ctxDnQ))
array.set(scArr, 5, scOf(gravestone and ctxBearRev, 5, math.min(1.0, upSh/(rngS*0.6)), ctxUpQ))
array.set(scArr, 6, scOf(llDoji, 6, math.min(1.0, (upSh+dnSh)/(rngS*0.8)), math.max(ctxUpQ, ctxDnQ)))
bool maruBull = isBull and body >= rngS * maruBodyPct/100.0
bool maruBear = isBear and body >= rngS * maruBodyPct/100.0
float maruQ = math.min(1.0, body / (rngS * maruBodyPct/100.0))
array.set(scArr, 7, scOf(maruBull and ctxBullCont, 7, maruQ, ctxUpQ))
array.set(scArr, 8, scOf(maruBear and ctxBearCont, 8, maruQ, ctxDnQ))
bool bullEng = bear1 and isBull and close >= bHi1 and open <= bLo1 and body >= body1 * engBodyMult and body1 > 0
bool bearEng = bull1 and isBear and close <= bLo1 and open >= bHi1 and body >= body1 * engBodyMult and body1 > 0
float engQ = math.min(1.0, body / (body1 + 1e-9) / (engBodyMult + 0.6))
array.set(scArr, 9,  scOf(bullEng and ctxBullRev, 9, engQ, ctxDnQ))
array.set(scArr, 10, scOf(bearEng and ctxBearRev, 10, engQ, ctxUpQ))
bool bullHar = bear1 and isBull and bHi1 >= bodyHi and bLo1 <= bodyLo and body1 > body * 1.4 and body1 > 0
bool bearHar = bull1 and isBear and bHi1 >= bodyHi and bLo1 <= bodyLo and body1 > body * 1.4 and body1 > 0
float harQ = math.min(1.0, body1 / (body + 1e-9) / 2.2)
array.set(scArr, 11, scOf(bullHar and ctxBullRev, 11, harQ, ctxDnQ))
array.set(scArr, 12, scOf(bearHar and ctxBearRev, 12, harQ, ctxUpQ))
float mid1 = (o1 + c1) / 2.0
bool pierce = bear1 and isBull and open < l1 and close > mid1 and close < o1 and body1 > 0
bool darkCl = bull1 and isBear and open > h1 and close < mid1 and close > o1 and body1 > 0
float pierceQ = math.min(1.0, (close - mid1) / (body1 * 0.5 + 1e-9))
float darkQ   = math.min(1.0, (mid1 - close) / (body1 * 0.5 + 1e-9))
array.set(scArr, 13, scOf(pierce and ctxBullRev, 13, pierceQ, ctxDnQ))
array.set(scArr, 14, scOf(darkCl and ctxBearRev, 14, darkQ, ctxUpQ))
bool tweezBot = math.abs(low - l1) <= eqTol and bear1 and isBull and rng > 0
bool tweezTop = math.abs(high - h1) <= eqTol and bull1 and isBear and rng > 0
float tweezBotQ = math.max(0.0, 1.0 - math.abs(low - l1) / (eqTol + 1e-9))
float tweezTopQ = math.max(0.0, 1.0 - math.abs(high - h1) / (eqTol + 1e-9))
array.set(scArr, 15, scOf(tweezBot and ctxBullRev, 15, tweezBotQ, ctxDnQ))
array.set(scArr, 16, scOf(tweezTop and ctxBearRev, 16, tweezTopQ, ctxUpQ))
bool bullWin = low > h1
bool bearWin = high < l1
float bullWinQ = math.min(1.0, (low - h1) / (atr * 0.5 + 1e-9))
float bearWinQ = math.min(1.0, (l1 - high) / (atr * 0.5 + 1e-9))
array.set(scArr, 17, scOf(bullWin and ctxBullCont, 17, bullWinQ, ctxUpQ))
array.set(scArr, 18, scOf(bearWin and ctxBearCont, 18, bearWinQ, ctxDnQ))
float starBodyCur = body1
bool smallStar = body1 <= starAvgBody * starBodyPct/100.0
bool morningStar = bear2 and smallStar and isBull and close > (o2 + c2)/2.0 and body2 > 0
bool eveningStar = bull2 and smallStar and isBear and close < (o2 + c2)/2.0 and body2 > 0
float msQ = math.min(1.0, (close - (o2+c2)/2.0) / (body2 * 0.5 + 1e-9))
float esQ = math.min(1.0, ((o2+c2)/2.0 - close) / (body2 * 0.5 + 1e-9))
float riseAmt3 = enough ? (c2 - close[2 + trendLook]) : 0.0
float dropAmt3 = -riseAmt3
bool  priorUp3   = enough and (riseAmt3 >  atr * 0.3)
bool  priorDown3 = enough and (dropAmt3 >  atr * 0.3)
float ctxUp3Q = math.min(1.0, math.max(0.0, riseAmt3) / (atr * trendLook * 0.22 + 1e-9))
float ctxDn3Q = math.min(1.0, math.max(0.0, dropAmt3) / (atr * trendLook * 0.22 + 1e-9))
array.set(scArr, 19, scOf(morningStar and (not requireCtx or priorDown3), 19, msQ, ctxDn3Q))
array.set(scArr, 20, scOf(eveningStar and (not requireCtx or priorUp3),   20, esQ, ctxUp3Q))
bool threeSold = isBull and bull1 and bull2 and close > c1 and c1 > c2 and open < c1 and open > o1 and o1 < c2 and o1 > o2 and body > rngS*0.5 and body1 > 0 and body2 > 0
bool threeCrow = isBear and bear1 and bear2 and close < c1 and c1 < c2 and open > c1 and open < o1 and o1 > c2 and o1 < o2 and body > rngS*0.5 and body1 > 0 and body2 > 0
array.set(scArr, 21, scOf(threeSold and (not requireCtx or priorDown3), 21, 0.85, ctxDn3Q))
array.set(scArr, 22, scOf(threeCrow and (not requireCtx or priorUp3),   22, 0.85, ctxUp3Q))
float o3=open[3], c3=close[3], h3=high[3], l3=low[3]
float o4=open[4], c4=close[4], h4=high[4], l4=low[4]
bool rising3 = (c4 > o4) and ((c4 - o4) > atr*0.6) and isBull and close > c4 and h3 <= h4 and l3 >= l4 and h2 <= h4 and l2 >= l4 and h1 <= h4 and l1 >= l4
bool falling3 = (o4 > c4) and ((o4 - c4) > atr*0.6) and isBear and close < c4 and h3 <= h4 and l3 >= l4 and h2 <= h4 and l2 >= l4 and h1 <= h4 and l1 >= l4
array.set(scArr, 23, scOf(rising3 and ctxBullCont,  23, 0.9, ctxUpQ))
array.set(scArr, 24, scOf(falling3 and ctxBearCont, 24, 0.9, ctxDnQ))
int   bestId   = -1
float bestScore = 0.0
for fi = 0 to 24
    float v = array.get(scArr, fi)
    if v > bestScore
        bestScore := v
        bestId    := fi
int bestDir  = bestId >= 0 ? patDir(bestId)  : 0
int bestSpan = bestId >= 0 ? patSpan(bestId) : 1
bool dirPass = sideFilter == "All" or (sideFilter == "Bullish Only" and bestDir == 1) or (sideFilter == "Bearish Only" and bestDir == -1)
bool strongPass = not strongOnly or bestScore >= strongThr
var int lastSigBar = -100000
bool spacingOk = (bar_index - lastSigBar) >= minSpacing
bool detRaw = bestId >= 0 and dirPass and strongPass and spacingOk
int   sig_dir = 0
int   sig_idx = -1
float sig_str = 0.0
int   sig_bar = 0
if detRaw
    sig_dir := bestDir == 0 ? 2 : bestDir
    sig_idx := bestId
    sig_str := bestScore
    sig_bar := bar_index
bool sig_new = detRaw
bool detFinal = detRaw and barstate.isconfirmed
if detFinal
    lastSigBar := bar_index
starStr(float sc) =>
    int filled = math.round(sc / 2.0)
    filled := math.max(0, math.min(5, filled))
    string s = ""
    for i = 0 to 4
        s := s + (i < filled ? "★" : "☆")
    s
tierStr(float sc) =>
    sc >= 8 ? "ELITE" : sc >= 6 ? "STRONG" : sc >= 4 ? "MODERATE" : "WEAK"
string lSz = lblSize == "Tiny" ? size.tiny : lblSize == "Small" ? size.small : lblSize == "Normal" ? size.normal : size.large
float zPad = atr * zonePadPct / 100.0
if detFinal and (showZones or showLabels)
    int span = bestSpan
    int b0    = bar_index - (span - 1)
    int b1    = bar_index
    float zTop = high
    float zBot = low
    for k = 0 to span - 1
        zTop := math.max(zTop, high[k])
        zBot := math.min(zBot, low[k])
    zTop := zTop + zPad
    zBot := zBot - zPad
    color dc = bestDir == 1 ? bullCol : bestDir == -1 ? bearCol : neutCol
    if showZones
        box.new(b0, zTop, b1, zBot, border_color=color.new(dc, 35), border_width=1, bgcolor=color.new(dc, zoneAlpha))
    if showLabels
        bool placeAbove = bestDir == -1
        float ly = placeAbove ? zTop : zBot
        string txt = patName(bestId) + (showStars ? ("\n" + starStr(bestScore) + " " + str.tostring(bestScore, "#.#")) : "")
        label.new(b1, ly, txt,
             style = placeAbove ? label.style_label_down : label.style_label_up,
             color = color.new(dc, 10), textcolor = color.white, size = lSz)
plotshape(detFinal and bestDir == 1,  title="Bullish", style=shape.triangleup,   location=location.belowbar, color=color.new(bullCol,0), size=size.tiny)
plotshape(detFinal and bestDir == -1, title="Bearish", style=shape.triangledown, location=location.abovebar, color=color.new(bearCol,0), size=size.tiny)
[d1d, d1i, d1s] = request.security(syminfo.tickerid, tf1, [sig_dir[1], sig_idx[1], sig_str[1]], lookahead=barmerge.lookahead_on)
[d2d, d2i, d2s] = request.security(syminfo.tickerid, tf2, [sig_dir[1], sig_idx[1], sig_str[1]], lookahead=barmerge.lookahead_on)
[d3d, d3i, d3s] = request.security(syminfo.tickerid, tf3, [sig_dir[1], sig_idx[1], sig_str[1]], lookahead=barmerge.lookahead_on)
[d4d, d4i, d4s] = request.security(syminfo.tickerid, tf4, [sig_dir[1], sig_idx[1], sig_str[1]], lookahead=barmerge.lookahead_on)
[d5d, d5i, d5s] = request.security(syminfo.tickerid, tf5, [sig_dir[1], sig_idx[1], sig_str[1]], lookahead=barmerge.lookahead_on)
[d6d, d6i, d6s] = request.security(syminfo.tickerid, tf6, [sig_dir[1], sig_idx[1], sig_str[1]], lookahead=barmerge.lookahead_on)
[d7d, d7i, d7s] = request.security(syminfo.tickerid, tf7, [sig_dir[1], sig_idx[1], sig_str[1]], lookahead=barmerge.lookahead_on)
[d8d, d8i, d8s] = request.security(syminfo.tickerid, tf8, [sig_dir[1], sig_idx[1], sig_str[1]], lookahead=barmerge.lookahead_on)
int a1 = request.security(syminfo.tickerid, tf1, ta.barssince(sig_new))
int a2 = request.security(syminfo.tickerid, tf2, ta.barssince(sig_new))
int a3 = request.security(syminfo.tickerid, tf3, ta.barssince(sig_new))
int a4 = request.security(syminfo.tickerid, tf4, ta.barssince(sig_new))
int a5 = request.security(syminfo.tickerid, tf5, ta.barssince(sig_new))
int a6 = request.security(syminfo.tickerid, tf6, ta.barssince(sig_new))
int a7 = request.security(syminfo.tickerid, tf7, ta.barssince(sig_new))
int a8 = request.security(syminfo.tickerid, tf8, ta.barssince(sig_new))
var int p1d=0, p1i=-1
var int p2d=0, p2i=-1
var int p3d=0, p3i=-1
var int p4d=0, p4i=-1
var int p5d=0, p5i=-1
var int p6d=0, p6i=-1
var int p7d=0, p7i=-1
var int p8d=0, p8i=-1
var float p1s=0.0, p2s=0.0, p3s=0.0, p4s=0.0, p5s=0.0, p6s=0.0, p7s=0.0, p8s=0.0
if d1d != 0 and d1s >= scanScoreMin
    p1d := d1d, p1i := d1i, p1s := d1s
if d2d != 0 and d2s >= scanScoreMin
    p2d := d2d, p2i := d2i, p2s := d2s
if d3d != 0 and d3s >= scanScoreMin
    p3d := d3d, p3i := d3i, p3s := d3s
if d4d != 0 and d4s >= scanScoreMin
    p4d := d4d, p4i := d4i, p4s := d4s
if d5d != 0 and d5s >= scanScoreMin
    p5d := d5d, p5i := d5i, p5s := d5s
if d6d != 0 and d6s >= scanScoreMin
    p6d := d6d, p6i := d6i, p6s := d6s
if d7d != 0 and d7s >= scanScoreMin
    p7d := d7d, p7i := d7i, p7s := d7s
if d8d != 0 and d8s >= scanScoreMin
    p8d := d8d, p8i := d8i, p8s := d8s
scanColor(int dir) => dir == 1 ? bullCol : dir == -1 ? bearCol : dir == 2 ? neutCol : color.new(color.gray, 30)
scanText(int dir, int idx, int ago) =>
    dir == 0 ? "—" : patAbbr(idx) + "(" + str.tostring(ago) + ")"
tfLabel(string tf) =>
    tf=="15"?"M15":tf=="30"?"M30":tf=="60"?"H1":tf=="120"?"H2":tf=="180"?"H3":tf=="240"?"H4":tf=="480"?"H8":tf=="720"?"H12":tf=="1440"?"D1":tf=="D"?"D1":tf=="W"?"W1":tf
f_hdr(table t, int col, string tf, int dir, int ago, string sz) =>
    bool fresh = dir != 0 and ago <= freshBars
    color hb = fresh ? color.new(#26a69a, 25) : color.new(#363a45, 40)
    table.cell(t, col, 1, tfLabel(tf), text_color=color.white, text_size=sz, bgcolor=hb)
f_val(table t, int col, int dir, int idx, int ago, string sz) =>
    color tcol = dir == 0 ? color.new(color.gray, 30) : color.new(scanColor(dir), 0)
    color bg   = dir == 0 ? color.new(#1c2030, 0) : (ago <= freshBars ? color.new(scanColor(dir), 78) : color.new(#1c2030, 0))
    table.cell(t, col, 2, scanText(dir, idx, ago), text_color=tcol, text_size=sz, bgcolor=bg)
if showScanner and barstate.islast
    string szT = dashSz == "Tiny" ? size.tiny : dashSz == "Small" ? size.small : size.normal
    scPos = scanPos == "Top Center" ? position.top_center : scanPos == "Top Right" ? position.top_right : scanPos == "Top Left" ? position.top_left : position.bottom_center
    var table sc = table.new(position.top_center, 9, 3, bgcolor=color.new(#161a25, 0), frame_color=color.new(#2962ff, 30), frame_width=1, border_color=color.new(#2a2e39, 50), border_width=1)
    table.set_position(sc, scPos)
    table.cell(sc, 0, 0, "◆ CANDLESTICK PATTERN SCANNER  —  " + syminfo.ticker, text_color=color.white, text_size=szT, bgcolor=color.new(#2962ff, 10))
    for ci = 1 to 8
        table.cell(sc, ci, 0, "", bgcolor=color.new(#2962ff, 10))
    table.merge_cells(sc, 0, 0, 8, 0)
    table.cell(sc, 0, 1, syminfo.ticker, text_color=color.white, text_size=szT, bgcolor=color.new(#363a45, 30))
    f_hdr(sc, 1, tf1, p1d, a1, szT)
    f_hdr(sc, 2, tf2, p2d, a2, szT)
    f_hdr(sc, 3, tf3, p3d, a3, szT)
    f_hdr(sc, 4, tf4, p4d, a4, szT)
    f_hdr(sc, 5, tf5, p5d, a5, szT)
    f_hdr(sc, 6, tf6, p6d, a6, szT)
    f_hdr(sc, 7, tf7, p7d, a7, szT)
    f_hdr(sc, 8, tf8, p8d, a8, szT)
    table.cell(sc, 0, 2, "Pattern", text_color=color.new(color.white, 30), text_size=szT, bgcolor=color.new(#1c2030, 0))
    f_val(sc, 1, p1d, p1i, a1, szT)
    f_val(sc, 2, p2d, p2i, a2, szT)
    f_val(sc, 3, p3d, p3i, a3, szT)
    f_val(sc, 4, p4d, p4i, a4, szT)
    f_val(sc, 5, p5d, p5i, a5, szT)
    f_val(sc, 6, p6d, p6i, a6, szT)
    f_val(sc, 7, p7d, p7i, a7, szT)
    f_val(sc, 8, p8d, p8i, a8, szT)
var label curTag = na
if barstate.islast
    label.delete(curTag)
    if bestId >= 0
        color dc = bestDir == 1 ? bullCol : bestDir == -1 ? bearCol : neutCol
        curTag := label.new(bar_index, high + atr*1.5,
             patName(bestId) + "\n" + starStr(bestScore) + " " + str.tostring(bestScore,"#.#") + "/10  " + tierStr(bestScore),
             style=label.style_label_down, color=color.new(dc, 15), textcolor=color.white, size=size.small)
bool fireBull = detFinal and bestDir == 1
bool fireBear = detFinal and bestDir == -1
bool strongAlPass = not alStrongAl or bestScore >= strongThr
if alertsOn and alBull and fireBull and strongAlPass
    alert("BULLISH " + patName(bestId) + "  " + str.tostring(bestScore,"#.#") + "/10\nSymbol: " + syminfo.tickerid + "  TF: " + timeframe.period + "\nClose: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if alertsOn and alBear and fireBear and strongAlPass
    alert("BEARISH " + patName(bestId) + "  " + str.tostring(bestScore,"#.#") + "/10\nSymbol: " + syminfo.tickerid + "  TF: " + timeframe.period + "\nClose: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
alertcondition(detFinal and bestDir == 1,  "Bullish Candlestick Pattern", "Bullish candlestick pattern detected")
alertcondition(detFinal and bestDir == -1, "Bearish Candlestick Pattern", "Bearish candlestick pattern detected")
alertcondition(detFinal and bestScore >= 8.0, "Elite Pattern (8+)", "Elite-strength candlestick pattern detected")
````
