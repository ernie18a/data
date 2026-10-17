# Education Trend | Wizard Academy

- url: https://www.tradingview.com/script/pIGMQxdW-Education-Trend-Wizard-Academy/
- type: indicator
- pine_id: PUB;c8e65e5dcaf54399bb0dbef2efbf9814
- version: 1.0

## Description

Educativ Trend | Wizard Academy

educativ trend is an educational trend-reading module built to teach traders how to identify real market structure, understand trend direction, avoid weak market conditions, and recognize clean pullback locations.

the tool is designed for beginners who want a clear framework, but it also gives advanced traders a structured way to read price action without relying on emotion or random candle reactions.

the main idea is simple:

a trend is not a feeling.
a trend is not only price above or below a moving average.
a trend is a sequence of swing points.

an uptrend is confirmed by:

higher high + higher low

a downtrend is confirmed by:

lower high + lower low

anything else is treated as range, transition, or unclear structure.

main features

confirmed market structure

the indicator detects confirmed swing highs and swing lows, then classifies them as:

HH = higher high
HL = higher low
LH = lower high
LL = lower low
EQH = equal high
EQL = equal low

each swing label includes educational context so the trader can understand what happened and why it matters.

trend state engine

the trend state is decided from structure only.

uptrend = HH + HL
downtrend = LH + LL
range = mixed or unclear structure

this helps traders avoid the common mistake of forcing trend trades inside a range.

ema context

the tool includes two moving averages:

fast ema
slow ema

the slow ema is used as long-term bias.
the fast ema is used as short-term fair value and pullback context.

the moving averages are not treated as the trend definition. they are used as context around the real structure.

bos and choch

the indicator marks important structure breaks:

BOS = break of structure
CHoCH = change of character

a bullish BOS shows continuation above the last confirmed swing high.

a bearish BOS shows continuation below the last confirmed swing low.

a bullish CHoCH appears when a bearish structure is damaged by a break above the last swing high.

a bearish CHoCH appears when a bullish structure is damaged by a break below the last swing low.

pullback module

the tool highlights textbook pullbacks into the fast ema when trend structure and bias agree.

a long pullback setup can appear when:

structure is bullish
price is above the slow ema
price pulls into the fast ema
price closes back above the fast ema
the candle closes bullish

a short pullback setup can appear when:

structure is bearish
price is below the slow ema
price rallies into the fast ema
price closes back below the fast ema
the candle closes bearish

this helps beginners avoid chasing breakouts and focus on better trade locations.

projected swing levels

the last confirmed swing high and swing low can be projected to the right side of the chart.

these levels show what price needs to break next.

close above the last swing high can create bullish BOS or bullish CHoCH.

close below the last swing low can create bearish BOS or bearish CHoCH.

dashboard

the live dashboard gives a quick read of the current market state.

it displays:

trend structure
last swing high
last swing low
price vs slow ema
fast ema vs slow ema
fast ema slope
distance from slow ema
checklist quality
live coaching message

the first title row uses an orange accent for a clean institutional look.

lesson card

the lesson card gives a simple nine-rule framework for reading trends.

it teaches:

structure first
ema second
entry last
do not chase breakouts
pullbacks are cleaner locations
ranges are dangerous for beginners
invalidation matters

glossary card

the glossary card explains the main structure terms directly on the chart.

it includes:

HH
HL
LH
LL
BOS
CHoCH
EQH / EQL
golden cross
death cross
PB

each panel can be moved to different chart positions, including corners and middle placements.

how to use the indicator

step 1: read the trend state

start with the dashboard.

if the dashboard says uptrend, the market has confirmed HH + HL.

if the dashboard says downtrend, the market has confirmed LH + LL.

if the dashboard says range, the highs and lows do not agree.

beginners should avoid forcing trend trades when the dashboard shows range.

step 2: check the slow ema bias

look at price versus the slow ema.

price above the slow ema shows bullish long-term context.

price below the slow ema shows bearish long-term context.

the ema does not define the trend by itself, but it helps confirm whether structure and bias agree.

step 3: check the fast ema pullback zone

the fast ema acts like short-term fair value.

in a bullish trend, price often pulls back into the fast ema before continuing.

in a bearish trend, price often rallies into the fast ema before continuing lower.

the cleanest entries usually come after a pullback, not after chasing a breakout candle.

step 4: watch the last swing levels

the projected swing high and swing low show the next important structure levels.

if price closes above the last swing high, bullish structure is strengthened or a bearish trend is damaged.

if price closes below the last swing low, bearish structure is strengthened or a bullish trend is damaged.

step 5: use bos and choch correctly

BOS is usually continuation.

CHoCH is usually the first warning that a trend may be changing.

a CHoCH is not automatically an entry. it is a warning to stop blindly trading the old trend and wait for new structure.

beginner long example

1. the dashboard shows uptrend
2. the last structure is HH + HL
3. price is above the slow ema
4. the fast ema is above the slow ema
5. price pulls back into the fast ema
6. price closes bullish above the fast ema
7. the indicator marks a pullback long
8. risk can be planned below the most recent higher low

this is a cleaner long setup than buying after a vertical breakout.

beginner short example

1. the dashboard shows downtrend
2. the last structure is LH + LL
3. price is below the slow ema
4. the fast ema is below the slow ema
5. price rallies into the fast ema
6. price closes bearish below the fast ema
7. the indicator marks a pullback short
8. risk can be planned above the most recent lower high

this is a cleaner short setup than selling after a large breakdown candle.

how to read the checklist

the checklist gives a simple structure-quality score.

3 / 3 = textbook condition
2 / 3 = partial condition
1 / 3 = weak condition
0 / 3 = avoid

a textbook condition means structure, ema bias, and alignment agree.

a partial condition means the market is not fully aligned yet.

a weak condition means the setup is not clean.

best beginner settings

fast ema: 20
slow ema: 200
swing left bars: 5
swing right bars: 5
equal high/low tolerance: 0.05 × atr
show structure labels: on
show bos / choch: on
show pullbacks: on
show dashboard: on
show lesson card: on
show glossary card: on

for faster markets

reduce swing left/right bars to 3 or 4.

this creates faster structure detection, but it can also create more noise.

for cleaner structure

increase swing left/right bars to 7, 8, or 10.

this gives fewer swings, but the structure is stronger and easier to read.

tips

do not use moving averages alone as a trend definition.

do not buy only because price is above the slow ema.

do not short only because price is below the slow ema.

wait for structure confirmation.

avoid trading in the middle of ranges.

a higher high alone does not confirm an uptrend.

a lower low alone does not confirm a downtrend.

the best long setups usually come after a higher low.

the best short setups usually come after a lower high.

BOS confirms strength.

CHoCH warns that the previous trend may be damaged.

equal highs and equal lows often act as liquidity zones.

do not chase extended candles far away from the fast ema.

wait for price to return to value.

use the most recent HL or LH as invalidation.

alerts

available alerts include:

uptrend confirmed
downtrend confirmed
trend lost / range
bullish BOS
bearish BOS
bullish CHoCH
bearish CHoCH
textbook pullback long
textbook pullback short
golden cross
death cross

for cleaner alerts, use once per bar close.

important note

this tool is built as an educational structure-reading module.

it is designed to help traders understand trend logic, market structure, pullbacks, continuation, transition, and invalidation.

always use risk management, position sizing, and confirmation from your own trading plan.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("Education Trend | Wizard Academy", "ETWA", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

string G_MA  = "①  MOVING AVERAGES  ·  Market Bias"
string G_STR = "②  MARKET STRUCTURE  ·  HH / HL / LH / LL"
string G_EDU = "③  EDUCATION MODULE"
string G_STY = "④  STYLE"

fastLen   = input.int(20,  "EMA Fast  ·  short-term fair value", minval = 1, group = G_MA, tooltip = "The EMA20 is the level price keeps returning to during a healthy trend. It is a MAGNET and a dynamic support/resistance.\n\nIt is NOT a trend definition. Price crossing it means nothing on its own.")
slowLen   = input.int(200, "EMA Slow  ·  long-term bias",        minval = 1, group = G_MA, tooltip = "The EMA200 answers ONE question: who owns this market?\n\nAbove = buyers own it. Below = sellers own it.\n\nIt is a filter, not a signal.")
maSrc     = input.source(close, "Source", group = G_MA)
showGlow  = input.bool(false, "Neon glow rendering", group = G_MA)
showRib   = input.bool(true, "Fill the zone between both EMAs", group = G_MA, tooltip = "The THICKNESS of this zone = trend strength.\nA thin, flat, twisting zone = no trend. Stay out.")
showCross = input.bool(true, "Mark Golden Cross / Death Cross", group = G_MA)

pivLeft   = input.int(5, "Swing detection  ·  Left bars",  minval = 1, group = G_STR, tooltip = "How many bars to the LEFT must be lower (for a high) for the point to count as a swing.")
pivRight  = input.int(5, "Swing detection  ·  Right bars", minval = 1, group = G_STR, tooltip = "A swing only becomes REAL once N bars have closed after it.\n\nThat is why labels appear N bars late. This delay is the PRICE OF HONESTY: nothing repaints.")
eqTol     = input.float(0.05, "Equal High/Low tolerance (× ATR)", minval = 0, step = 0.01, group = G_STR, tooltip = "Two swings within this distance are treated as EQUAL (EQH / EQL) instead of Higher/Lower. Equal levels = resting liquidity.")
showSw    = input.bool(true, "Show HH / HL / LH / LL labels", group = G_STR)
showZig   = input.bool(true, "Draw the structure skeleton", group = G_STR)
showBOS   = input.bool(true, "Mark BOS / CHoCH (structure breaks)", group = G_STR)
showPB    = input.bool(true, "Mark textbook pullbacks into EMA Fast", group = G_STR)
showLvl   = input.bool(true, "Project last swing levels to the right", group = G_STR)
showState = input.bool(true, "Announce trend state changes on chart", group = G_STR)

showDash   = input.bool(true, "Live dashboard", group = G_EDU)
dashPos    = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = G_EDU)
showLesson = input.bool(true, "Lesson card  ·  the 9 rules", group = G_EDU)
lessonPos  = input.string("Bottom Left", "Lesson card position", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = G_EDU)
showGloss  = input.bool(true, "Glossary card", group = G_EDU)
glossPos   = input.string("Bottom Right", "Glossary card position", options = ["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group = G_EDU)
showBg     = input.bool(true, "Tint background by trend state", group = G_EDU)
bgOpacity = input.int(15, "Background opacity", minval = 0, maxval = 100, group = G_EDU)

cBull = input.color(#00FFD1, "Bull / Support",        group = G_STY)
cBear = input.color(#FF3B5C, "Bear / Resistance",     group = G_STY)
cGold = input.color(#FFD23F, "Accent / Neutral",      group = G_STY)
cTitle= input.color(#FF9F1C, "Panel title orange",    group = G_STY)
cNeut = input.color(#9AB0C7, "Secondary text",        group = G_STY)
cBg   = input.color(#0A0E14, "Panel background",      group = G_STY)

string TIP_HH = "HIGHER HIGH  (HH)\n\nWHAT HAPPENED\nPrice printed a swing high ABOVE the previous swing high.\nBuyers were able to push further than they did last time.\n\nWHAT IT MEANS\nThis is HALF of an uptrend. On its own it proves nothing —\na market can print a Higher High and immediately collapse.\n\nWHAT TO OBSERVE\nWait for the NEXT low. If it lands above the previous low (HL),\nthe uptrend is confirmed. If it lands below, the HH was a trap."

string TIP_HL = "HIGHER LOW  (HL)\n\nWHAT HAPPENED\nBuyers stepped in EARLIER than the previous time.\nSellers could not drag price as low as before.\n\nWHAT IT MEANS\nCombined with a Higher High, the UPTREND is now confirmed.\nThis low is your line in the sand.\n\nWHAT TO OBSERVE\nThe last Higher Low is your INVALIDATION.\nA close below it is the first real warning the trend is dying.\nStops belong under it — never in the middle of nowhere."

string TIP_LH = "LOWER HIGH  (LH)\n\nWHAT HAPPENED\nSellers capped price EARLIER than last time.\nBuyers ran out of fuel before reaching the old high.\n\nWHAT IT MEANS\nSupply is winning. This is HALF of a downtrend.\n\nWHAT TO OBSERVE\nWatch the next low. Below the previous low (LL) = downtrend confirmed.\nBeginners buy Lower Highs because they 'look cheap'. Don't."

string TIP_LL = "LOWER LOW  (LL)\n\nWHAT HAPPENED\nSellers pushed price beyond the previous swing low.\n\nWHAT IT MEANS\nWith a Lower High before it, the DOWNTREND is confirmed.\n\nWHAT TO OBSERVE\nThe last Lower High is the invalidation of this downtrend.\nUntil price closes above it, every bounce is a selling opportunity,\nnot a bottom."

string TIP_EQH = "EQUAL HIGH  (EQH)\n\nWHAT HAPPENED\nPrice stopped at (almost) the exact same high as before.\n\nWHAT IT MEANS\nStop-losses of short sellers are stacked just above this level.\nThat is RESTING LIQUIDITY — fuel.\n\nWHAT TO OBSERVE\nThese levels get swept far more often than they get respected.\nA fast spike above followed by an instant rejection is not a breakout.\nIt is a liquidity grab."

string TIP_EQL = "EQUAL LOW  (EQL)\n\nWHAT HAPPENED\nPrice bottomed at (almost) the same low as before.\n\nWHAT IT MEANS\nBuy-side stops are stacked just under this level: resting liquidity.\n\nWHAT TO OBSERVE\nExpect a sweep below, then a violent reclaim.\nThat sweep is where beginners get stopped out and professionals enter."

string TIP_FIRST = "FIRST SWING\n\nThis is the first confirmed swing point on the chart.\nThere is nothing to compare it to yet.\n\nWAIT for the next swing of the same type — only then can we say\nwhether it is Higher or Lower, and only then does a trend exist."

string TIP_BOSU = "BREAK OF STRUCTURE  —  BULLISH  (BOS ▲)\n\nWHAT HAPPENED\nPrice CLOSED above the last confirmed swing high\nwhile the market was already bullish or neutral.\n\nWHAT IT MEANS\nContinuation. The trend just proved itself again.\n\nWHAT TO OBSERVE\nDo NOT buy the break itself. Buy the pullback that follows,\nwith a stop under the new Higher Low that forms."

string TIP_BOSD = "BREAK OF STRUCTURE  —  BEARISH  (BOS ▼)\n\nWHAT HAPPENED\nPrice CLOSED below the last confirmed swing low\nwhile the market was already bearish or neutral.\n\nWHAT IT MEANS\nContinuation of selling pressure.\n\nWHAT TO OBSERVE\nSell the retest into the last Lower High, not the breakdown candle."

string TIP_CHU = "CHANGE OF CHARACTER  —  BULLISH  (CHoCH ▲)\n\nWHAT HAPPENED\nThe market was in a confirmed DOWNTREND (LH + LL),\nand price just closed ABOVE the last swing high.\n\nWHAT IT MEANS\nThe sequence of Lower Highs is broken. This is the FIRST clue —\nnot proof — that the downtrend may be over.\n\nWHAT TO OBSERVE\nA CHoCH is a warning, never an entry.\nWait for price to build a Higher Low above the old structure.\nMost CHoCH events fail. The ones that don't start the next trend."

string TIP_CHD = "CHANGE OF CHARACTER  —  BEARISH  (CHoCH ▼)\n\nWHAT HAPPENED\nThe market was in a confirmed UPTREND (HH + HL),\nand price just closed BELOW the last swing low.\n\nWHAT IT MEANS\nThe last Higher Low is lost. The uptrend has been damaged.\n\nWHAT TO OBSERVE\nStop buying dips. Wait: either price reclaims and prints a new HL,\nor it builds a Lower High and the downtrend begins."

string TIP_PBL = "TEXTBOOK PULLBACK  —  LONG SIDE\n\nWHAT HAPPENED\n1) Structure is a confirmed UPTREND (HH + HL)\n2) Price is above the EMA200 (bias agrees)\n3) Price dipped INTO the EMA20 and closed back above it\n4) The candle closed green\n\nWHY IT MATTERS\nThis is the highest-quality, lowest-risk location to join a trend:\nyou are buying value, not chasing a breakout.\n\nWHAT TO OBSERVE\nRisk goes below the most recent Higher Low.\nIf that low breaks, the idea is dead — no negotiation."

string TIP_PBS = "TEXTBOOK PULLBACK  —  SHORT SIDE\n\nWHAT HAPPENED\n1) Structure is a confirmed DOWNTREND (LH + LL)\n2) Price is below the EMA200\n3) Price rallied INTO the EMA20 and closed back below it\n4) The candle closed red\n\nWHAT TO OBSERVE\nRisk goes above the most recent Lower High.\nSelling into strength inside a downtrend beats selling into weakness."

string TIP_GC = "GOLDEN CROSS\n\nThe EMA20 crossed ABOVE the EMA200.\n\nWHAT IT MEANS\nShort-term fair value is now above long-term fair value.\nThe long-term bias has flipped bullish.\n\nWHAT IT DOES NOT MEAN\nIt is not an entry. It is a LAGGING confirmation of something\nmarket structure already told you dozens of bars ago.\nUse it as a filter, never as a trigger."

string TIP_DC = "DEATH CROSS\n\nThe EMA20 crossed BELOW the EMA200.\n\nWHAT IT MEANS\nLong-term bias flipped bearish.\n\nWHAT IT DOES NOT MEAN\nIt is not a short signal. By the time it prints, the move is old.\nIt is a context filter: it tells you which side to hunt setups on."

string TIP_UP = "UPTREND CONFIRMED\n\nThe last swing high was HIGHER than the one before it,\nAND the last swing low was HIGHER than the one before it.\n\nBoth conditions true = uptrend. That is the entire definition.\nNo indicator, no opinion, no vibe."

string TIP_DN = "DOWNTREND CONFIRMED\n\nLower High + Lower Low. That is the entire definition."

string TIP_RG = "NO TREND  —  RANGE / TRANSITION\n\nThe highs and the lows disagree (e.g. Higher High + Lower Low).\nThere is no sequence, therefore there is no trend.\n\nThis is where most beginner accounts die: they force trend logic\nonto a market that has none.\n\nWHAT TO OBSERVE\nEither stand aside, or trade the edges of the range and expect\nto be wrong often. Wait for a BOS to pick a side."

emaF = ta.ema(maSrc, fastLen)
emaS = ta.ema(maSrc, slowLen)
atr  = ta.atr(14)
tolv = na(atr) ? 0.0 : atr * eqTol

fCol = emaF > emaS ? cBull : cBear

plot(showGlow ? emaS : na, "EMA Slow · halo", color.new(cGold, 91), 11, editable = false)
plot(showGlow ? emaS : na, "EMA Slow · heat", color.new(cGold, 80),  6, editable = false)
pS = plot(emaS, "EMA Slow · core", cGold, 2)

plot(showGlow ? emaF : na, "EMA Fast · halo", color.new(fCol, 91), 9, editable = false)
plot(showGlow ? emaF : na, "EMA Fast · heat", color.new(fCol, 80), 5, editable = false)
pF = plot(emaF, "EMA Fast · core", fCol, 2)

fill(pF, pS, showRib ? color.new(emaF > emaS ? cBull : cBear, 89) : na, "EMA Zone")

gCross = ta.crossover(emaF,  emaS)
dCross = ta.crossunder(emaF, emaS)

if showCross and gCross and barstate.isconfirmed
    label.new(bar_index, low, "GOLDEN CROSS", xloc = xloc.bar_index, yloc = yloc.belowbar, color = color.new(cBg, 15), style = label.style_label_up, textcolor = cBull, size = size.tiny, tooltip = TIP_GC)

if showCross and dCross and barstate.isconfirmed
    label.new(bar_index, high, "DEATH CROSS", xloc = xloc.bar_index, yloc = yloc.abovebar, color = color.new(cBg, 15), style = label.style_label_down, textcolor = cBear, size = size.tiny, tooltip = TIP_DC)

ph = ta.pivothigh(high, pivLeft, pivRight)
pl = ta.pivotlow(low,   pivLeft, pivRight)

var float phLast = na
var float phPrev = na
var int   phBar  = na
var float plLast = na
var float plPrev = na
var int   plBar  = na

var string tagH  = "—"
var string tagL  = "—"
var int    trend = 0          // 1 = uptrend, -1 = downtrend, 0 = range/transition

newPH = not na(ph)
newPL = not na(pl)

if newPH
    phPrev := phLast
    phLast := ph
    phBar  := bar_index - pivRight
    tagH   := na(phPrev) ? "H" : phLast > phPrev + tolv ? "HH" : phLast < phPrev - tolv ? "LH" : "EQH"

if newPL
    plPrev := plLast
    plLast := pl
    plBar  := bar_index - pivRight
    tagL   := na(plPrev) ? "L" : plLast > plPrev + tolv ? "HL" : plLast < plPrev - tolv ? "LL" : "EQL"

if newPH or newPL
    trend := tagH == "HH" and tagL == "HL" ? 1 : tagH == "LH" and tagL == "LL" ? -1 : 0

if showSw and newPH
    txtC = tagH == "HH" ? cBull : tagH == "LH" ? cBear : cGold
    tipH = tagH == "HH" ? TIP_HH : tagH == "LH" ? TIP_LH : tagH == "EQH" ? TIP_EQH : TIP_FIRST
    label.new(phBar, phLast, tagH, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 25), style = label.style_label_down, textcolor = txtC, size = size.tiny, tooltip = tipH)

if showSw and newPL
    txtC = tagL == "HL" ? cBull : tagL == "LL" ? cBear : cGold
    tipL = tagL == "HL" ? TIP_HL : tagL == "LL" ? TIP_LL : tagL == "EQL" ? TIP_EQL : TIP_FIRST
    label.new(plBar, plLast, tagL, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 25), style = label.style_label_up, textcolor = txtC, size = size.tiny, tooltip = tipL)

var int   zBar    = na
var float zPx     = na
var bool  zIsHigh = false
var bool  zHave   = false

if showZig and newPH
    if zHave
        legC = not zIsHigh ? color.new(cBull, 55) : color.new(cNeut, 70)
        line.new(zBar, zPx, phBar, phLast, xloc.bar_index, extend.none, legC, line.style_solid, 1)
    zBar    := phBar
    zPx     := phLast
    zIsHigh := true
    zHave   := true

if showZig and newPL
    if zHave
        legC = zIsHigh ? color.new(cBear, 55) : color.new(cNeut, 70)
        line.new(zBar, zPx, plBar, plLast, xloc.bar_index, extend.none, legC, line.style_solid, 1)
    zBar    := plBar
    zPx     := plLast
    zIsHigh := false
    zHave   := true

var bool usedHigh = false
var bool usedLow  = false

if newPH
    usedHigh := false
if newPL
    usedLow := false

brkUp = showBOS and not na(phLast) and not usedHigh and close > phLast and barstate.isconfirmed
brkDn = showBOS and not na(plLast) and not usedLow  and close < plLast and barstate.isconfirmed

chochUp = brkUp and trend == -1
chochDn = brkDn and trend ==  1
bosUp   = brkUp and trend != -1
bosDn   = brkDn and trend !=  1

if brkUp
    usedHigh := true
    label.new(bar_index, low, chochUp ? "CHoCH ▲" : "BOS ▲", xloc = xloc.bar_index, yloc = yloc.belowbar, color = color.new(cBg, 15), style = label.style_label_up, textcolor = chochUp ? cGold : cBull, size = size.tiny, tooltip = chochUp ? TIP_CHU : TIP_BOSU)

if brkDn
    usedLow := true
    label.new(bar_index, high, chochDn ? "CHoCH ▼" : "BOS ▼", xloc = xloc.bar_index, yloc = yloc.abovebar, color = color.new(cBg, 15), style = label.style_label_down, textcolor = chochDn ? cGold : cBear, size = size.tiny, tooltip = chochDn ? TIP_CHD : TIP_BOSD)

var int lastPBbar = na
pbReady = na(lastPBbar) or (bar_index - lastPBbar) > 5

pbLong  = showPB and pbReady and barstate.isconfirmed and trend ==  1 and close > emaS and low  <= emaF and close > emaF and close > open
pbShort = showPB and pbReady and barstate.isconfirmed and trend == -1 and close < emaS and high >= emaF and close < emaF and close < open

if pbLong
    lastPBbar := bar_index
    label.new(bar_index, low, "PB ▲", xloc = xloc.bar_index, yloc = yloc.belowbar, color = color.new(cBull, 80), style = label.style_label_up, textcolor = cBull, size = size.tiny, tooltip = TIP_PBL)

if pbShort
    lastPBbar := bar_index
    label.new(bar_index, high, "PB ▼", xloc = xloc.bar_index, yloc = yloc.abovebar, color = color.new(cBear, 80), style = label.style_label_down, textcolor = cBear, size = size.tiny, tooltip = TIP_PBS)

newUp    = trend ==  1 and trend[1] !=  1
newDn    = trend == -1 and trend[1] != -1
newRange = trend ==  0 and trend[1] !=  0

if showState and newUp
    label.new(bar_index, low, "▲ UPTREND CONFIRMED\nHH + HL", xloc = xloc.bar_index, yloc = yloc.belowbar, color = color.new(cBg, 10), style = label.style_label_up, textcolor = cBull, size = size.tiny, textalign = text.align_left, tooltip = TIP_UP)

if showState and newDn
    label.new(bar_index, high, "▼ DOWNTREND CONFIRMED\nLH + LL", xloc = xloc.bar_index, yloc = yloc.abovebar, color = color.new(cBg, 10), style = label.style_label_down, textcolor = cBear, size = size.tiny, textalign = text.align_left, tooltip = TIP_DN)

if showState and newRange
    label.new(bar_index, high, "■ NO TREND — RANGE", xloc = xloc.bar_index, yloc = yloc.abovebar, color = color.new(cBg, 10), style = label.style_label_down, textcolor = cGold, size = size.tiny, tooltip = TIP_RG)

bgTransp = 100 - bgOpacity
bgcolor(showBg ? (trend == 1 ? color.new(cBull, bgTransp) : trend == -1 ? color.new(cBear, bgTransp) : color.new(cNeut, bgTransp)) : na, title = "Trend state tint")

var line  lnHi = na
var line  lnLo = na
var label lbHi = na
var label lbLo = na

if barstate.islast and showLvl
    if not na(phLast)
        if na(lnHi)
            lnHi := line.new(phBar, phLast, bar_index + 14, phLast, xloc.bar_index, extend.none, color.new(cBear, 60), line.style_dashed, 1)
            lbHi := label.new(bar_index + 14, phLast, "", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 100), style = label.style_label_left, textcolor = cBear, size = size.tiny)
        line.set_xy1(lnHi, phBar, phLast)
        line.set_xy2(lnHi, bar_index + 14, phLast)
        label.set_xy(lbHi, bar_index + 14, phLast)
        label.set_text(lbHi, "swing high " + str.tostring(phLast, format.mintick) + "  ·  close above = " + (trend == -1 ? "CHoCH ▲" : "BOS ▲"))

    if not na(plLast)
        if na(lnLo)
            lnLo := line.new(plBar, plLast, bar_index + 14, plLast, xloc.bar_index, extend.none, color.new(cBull, 60), line.style_dashed, 1)
            lbLo := label.new(bar_index + 14, plLast, "", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 100), style = label.style_label_left, textcolor = cBull, size = size.tiny)
        line.set_xy1(lnLo, plBar, plLast)
        line.set_xy2(lnLo, bar_index + 14, plLast)
        label.set_xy(lbLo, bar_index + 14, plLast)
        label.set_text(lbLo, "swing low " + str.tostring(plLast, format.mintick) + "  ·  close below = " + (trend == 1 ? "CHoCH ▼" : "BOS ▼"))

biasUp   = close > emaS
alignUp  = emaF  > emaS
slope3   = emaF - emaF[3]
distPct  = (close - emaS) / emaS * 100.0
extPct   = math.abs(close - emaF) / emaF * 100.0

trName = trend == 1 ? "UPTREND   ·  HH + HL" : trend == -1 ? "DOWNTREND  ·  LH + LL" : "NO TREND  ·  RANGE"
trCol  = trend == 1 ? cBull : trend == -1 ? cBear : cGold

bearMode = trend == -1
chkTxt1  = bearMode ? "Price  <  EMA" + str.tostring(slowLen) : "Price  >  EMA" + str.tostring(slowLen)
chkTxt2  = bearMode ? "EMA" + str.tostring(fastLen) + "  <  EMA" + str.tostring(slowLen) : "EMA" + str.tostring(fastLen) + "  >  EMA" + str.tostring(slowLen)
chkTxt3  = bearMode ? "Structure = LH + LL" : "Structure = HH + HL"

chk1 = bearMode ? close < emaS : close > emaS
chk2 = bearMode ? emaF  < emaS : emaF  > emaS
chk3 = bearMode ? trend == -1  : trend ==  1

score   = (chk1 ? 1 : 0) + (chk2 ? 1 : 0) + (chk3 ? 1 : 0)
scoreTx = score == 3 ? "3 / 3  ·  TEXTBOOK" : score == 2 ? "2 / 3  ·  PARTIAL — wait" : score == 1 ? "1 / 3  ·  DO NOT TRADE" : "0 / 3  ·  DO NOT TRADE"
scoreCol= score == 3 ? (bearMode ? cBear : cBull) : score == 2 ? cGold : cNeut

coach = switch
    trend ==  1 and close < emaS => "⚠ CONFLICT\nStructure is bullish (HH+HL) but price lost the EMA" + str.tostring(slowLen) + ".\nBias and structure disagree. Cut size or stand aside\nuntil one of them gives in."
    trend == -1 and close > emaS => "⚠ CONFLICT\nStructure is bearish (LH+LL) but price reclaimed the EMA" + str.tostring(slowLen) + ".\nDo not press shorts into a rising long-term bias."
    trend ==  1 and close < emaF => "◆ PULLBACK ZONE — LONG SIDE\nPrice is inside the EMA" + str.tostring(fastLen) + " while structure stays bullish.\nOBSERVE: a bullish reaction candle, then a new Higher Low.\nNever short a pullback inside an uptrend."
    trend == -1 and close > emaF => "◆ PULLBACK ZONE — SHORT SIDE\nPrice is rallying into the EMA" + str.tostring(fastLen) + " inside a downtrend.\nOBSERVE: a bearish reaction candle, then a new Lower High."
    trend ==  1 and extPct > 2.0 => "⚑ EXTENDED\nPrice sits " + str.tostring(extPct, "#.##") + "% above the EMA" + str.tostring(fastLen) + ".\nChasing here is the #1 beginner mistake: worst possible R:R.\nLet price come back to you."
    trend == -1 and extPct > 2.0 => "⚑ EXTENDED\nPrice sits " + str.tostring(extPct, "#.##") + "% below the EMA" + str.tostring(fastLen) + ".\nShorting into a vertical drop is how you buy the bottom by accident."
    trend ==  1                  => "✓ HEALTHY UPTREND\nHH + HL confirmed, price above the EMA" + str.tostring(slowLen) + ".\nPLAN: longs on pullbacks into the EMA" + str.tostring(fastLen) + ".\nSTOP: under the most recent Higher Low. No exceptions."
    trend == -1                  => "✓ HEALTHY DOWNTREND\nLH + LL confirmed, price below the EMA" + str.tostring(slowLen) + ".\nPLAN: shorts on rallies into the EMA" + str.tostring(fastLen) + ".\nSTOP: above the most recent Lower High."
    =>                              "■ NO TREND — RANGE\nThe highs and the lows disagree, so no sequence exists.\nMost beginner losses happen right here, forcing trend logic\nonto a market that has none.\nWAIT for a BOS to pick a side."

posOf(s) =>
    s == "Top Right" ? position.top_right :
     s == "Top Center" ? position.top_center :
     s == "Top Left" ? position.top_left :
     s == "Middle Right" ? position.middle_right :
     s == "Middle Center" ? position.middle_center :
     s == "Middle Left" ? position.middle_left :
     s == "Bottom Right" ? position.bottom_right :
     s == "Bottom Center" ? position.bottom_center :
     position.bottom_left

var table dash = table.new(posOf(dashPos), 2, 14, bgcolor = color.new(cBg, 6), frame_color = color.new(cNeut, 55), frame_width = 1, border_color = color.new(cNeut, 82), border_width = 1)

if barstate.islast and showDash
    table.cell(dash, 0, 0, "WIZARD  TREND  ACADEMY", text_color = cTitle, text_size = size.tiny, bgcolor = color.new(cTitle, 88))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "TREND  (structure)", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 1, trName, text_color = trCol, text_size = size.tiny, bgcolor = color.new(trCol, 90))

    table.cell(dash, 0, 2, "Last swing HIGH", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 2, tagH + "   " + (na(phLast) ? "—" : str.tostring(phLast, format.mintick)), text_color = tagH == "HH" ? cBull : tagH == "LH" ? cBear : cGold, text_size = size.tiny)

    table.cell(dash, 0, 3, "Last swing LOW", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 3, tagL + "   " + (na(plLast) ? "—" : str.tostring(plLast, format.mintick)), text_color = tagL == "HL" ? cBull : tagL == "LL" ? cBear : cGold, text_size = size.tiny)

    table.cell(dash, 0, 4, "Price vs EMA" + str.tostring(slowLen), text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 4, biasUp ? "ABOVE  ·  buyers own it" : "BELOW  ·  sellers own it", text_color = biasUp ? cBull : cBear, text_size = size.tiny)

    table.cell(dash, 0, 5, "EMA" + str.tostring(fastLen) + " vs EMA" + str.tostring(slowLen), text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 5, alignUp ? "BULL alignment" : "BEAR alignment", text_color = alignUp ? cBull : cBear, text_size = size.tiny)

    table.cell(dash, 0, 6, "EMA" + str.tostring(fastLen) + " slope (3 bars)", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 6, slope3 > 0 ? "RISING  ↑" : slope3 < 0 ? "FALLING  ↓" : "FLAT  →", text_color = slope3 > 0 ? cBull : slope3 < 0 ? cBear : cGold, text_size = size.tiny)

    table.cell(dash, 0, 7, "Distance to EMA" + str.tostring(slowLen), text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(distPct, "#.##") + " %", text_color = distPct > 0 ? cBull : cBear, text_size = size.tiny)

    table.cell(dash, 0, 8, "CHECKLIST  ·  " + (bearMode ? "SHORT SIDE" : "LONG SIDE"), text_color = cGold, text_size = size.tiny, bgcolor = color.new(cGold, 92))
    table.merge_cells(dash, 0, 8, 1, 8)

    table.cell(dash, 0, 9, chkTxt1, text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 9, chk1 ? "✔" : "✘", text_color = chk1 ? cBull : cBear, text_size = size.tiny)

    table.cell(dash, 0, 10, chkTxt2, text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 10, chk2 ? "✔" : "✘", text_color = chk2 ? cBull : cBear, text_size = size.tiny)

    table.cell(dash, 0, 11, chkTxt3, text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 11, chk3 ? "✔" : "✘", text_color = chk3 ? cBull : cBear, text_size = size.tiny)

    table.cell(dash, 0, 12, "Setup quality", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 12, scoreTx, text_color = scoreCol, text_size = size.tiny, bgcolor = color.new(scoreCol, 90))

    table.cell(dash, 0, 13, coach, text_color = trCol, text_size = size.tiny, text_halign = text.align_left, bgcolor = color.new(cBg, 20))
    table.merge_cells(dash, 0, 13, 1, 13)

var table lesson = table.new(posOf(lessonPos), 1, 10, bgcolor = color.new(cBg, 6), frame_color = color.new(cNeut, 55), frame_width = 1, border_color = color.new(cNeut, 85), border_width = 1)

if barstate.islast and showLesson
    table.cell(lesson, 0, 0, "LESSON  ·  HOW TO READ A TREND", text_color = cTitle, text_size = size.tiny, bgcolor = color.new(cTitle, 88))
    table.cell(lesson, 0, 1, "1 ·  A trend is a SEQUENCE, not a feeling.",            text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(lesson, 0, 2, "2 ·  UPTREND    =  Higher High  +  Higher Low",        text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(lesson, 0, 3, "3 ·  DOWNTREND  =  Lower High   +  Lower Low",         text_color = cBear, text_size = size.tiny, text_halign = text.align_left)
    table.cell(lesson, 0, 4, "4 ·  Anything else = RANGE. Stay out.",                text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(lesson, 0, 5, "5 ·  EMA200 = who owns the market (bias).",            text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(lesson, 0, 6, "6 ·  EMA20  = where price returns (pullback).",        text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(lesson, 0, 7, "7 ·  Entry = the pullback. Never the breakout chase.", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(lesson, 0, 8, "8 ·  Invalidation = the last HL / LH is lost.",        text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(lesson, 0, 9, "9 ·  Structure first.  EMA second.  Entry last.",      text_color = cGold, text_size = size.tiny, text_halign = text.align_left)

var table gloss = table.new(posOf(glossPos), 2, 11, bgcolor = color.new(cBg, 6), frame_color = color.new(cNeut, 55), frame_width = 1, border_color = color.new(cNeut, 85), border_width = 1)

if barstate.islast and showGloss
    table.cell(gloss, 0, 0, "GLOSSARY", text_color = cTitle, text_size = size.tiny, bgcolor = color.new(cTitle, 88))
    table.merge_cells(gloss, 0, 0, 1, 0)

    table.cell(gloss, 0, 1, "HH",      text_color = cBull, text_size = size.tiny)
    table.cell(gloss, 0, 2, "HL",      text_color = cBull, text_size = size.tiny)
    table.cell(gloss, 0, 3, "LH",      text_color = cBear, text_size = size.tiny)
    table.cell(gloss, 0, 4, "LL",      text_color = cBear, text_size = size.tiny)
    table.cell(gloss, 0, 5, "BOS",     text_color = cNeut, text_size = size.tiny)
    table.cell(gloss, 0, 6, "CHoCH",   text_color = cGold, text_size = size.tiny)
    table.cell(gloss, 0, 7, "EQH/EQL", text_color = cGold, text_size = size.tiny)
    table.cell(gloss, 0, 8, "G.CROSS", text_color = cBull, text_size = size.tiny)
    table.cell(gloss, 0, 9, "D.CROSS", text_color = cBear, text_size = size.tiny)
    table.cell(gloss, 0, 10, "PB",     text_color = cNeut, text_size = size.tiny)

    table.cell(gloss, 1, 1,  "Higher High — buyers pushed further than last time",   text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(gloss, 1, 2,  "Higher Low — buyers defended earlier than last time",  text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(gloss, 1, 3,  "Lower High — sellers capped price earlier",            text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(gloss, 1, 4,  "Lower Low — sellers pushed beyond the last low",       text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(gloss, 1, 5,  "Break of Structure — the trend confirms itself again", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(gloss, 1, 6,  "Change of Character — first clue the trend may flip",  text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(gloss, 1, 7,  "Equal levels — resting liquidity, usually swept",      text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(gloss, 1, 8,  "EMA fast crosses above EMA slow (lagging filter)",     text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(gloss, 1, 9,  "EMA fast crosses below EMA slow (lagging filter)",     text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(gloss, 1, 10, "Pullback — retrace into EMA fast, trend intact",       text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)

alertcondition(newUp,    "Uptrend confirmed (HH + HL)",   "WIZARD TREND ACADEMY — Uptrend confirmed: Higher High + Higher Low")
alertcondition(newDn,    "Downtrend confirmed (LH + LL)", "WIZARD TREND ACADEMY — Downtrend confirmed: Lower High + Lower Low")
alertcondition(newRange, "Trend lost — range",            "WIZARD TREND ACADEMY — Structure no longer aligned: range / transition")
alertcondition(bosUp,    "BOS bullish",                   "WIZARD TREND ACADEMY — Bullish Break of Structure")
alertcondition(bosDn,    "BOS bearish",                   "WIZARD TREND ACADEMY — Bearish Break of Structure")
alertcondition(chochUp,  "CHoCH bullish",                 "WIZARD TREND ACADEMY — Bullish Change of Character (downtrend damaged)")
alertcondition(chochDn,  "CHoCH bearish",                 "WIZARD TREND ACADEMY — Bearish Change of Character (uptrend damaged)")
alertcondition(pbLong,   "Textbook pullback long",        "WIZARD TREND ACADEMY — Textbook pullback into EMA fast, uptrend intact")
alertcondition(pbShort,  "Textbook pullback short",       "WIZARD TREND ACADEMY — Textbook pullback into EMA fast, downtrend intact")
alertcondition(gCross,   "Golden Cross",                  "WIZARD TREND ACADEMY — Golden Cross")
alertcondition(dCross,   "Death Cross",                   "WIZARD TREND ACADEMY — Death Cross")
````
