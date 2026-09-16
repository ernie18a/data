<!-- tradingview-pine-id: PUB;84189aede1c4428fbbce34fc0e529b2b -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Contested Volume Bubbles

Source: https://www.tradingview.com/script/6Pw3RCO2-Contested-Volume-Bubbles/

## Description

█ OVERVIEW

Contested Volume Bubbles marks bars where both sides of the trade committed unusually hard, drawing a bubble at the price where the fight actually happened. It measures contested volume — the volume committed by whichever side lost the bar.

In practice it is used to find areas of interest. Bubbles cluster at prices where the two sides repeatedly disagreed, and those levels often matter again on a return. A large bubble late in an extended move reads differently: a push meeting real opposition rather than clean continuation, which is the shape exhaustion usually takes.

█ CONCEPTS

Contested volume

For each bar, contested volume is the smaller of the two sides:

  contested = min(buy volume, sell volume)

Heavy volume that resolves cleanly in one direction gives you a low number. The same volume with both sides pushing and neither finishing ahead gives you a high one.

It's also exactly complementary to directional volume:

  contested = (total volume − total delta) ÷ 2

Contested volume, total volume and directional volume are three views of the same thing. You can trigger on one and size the bubble by another, which is where most of the flexibility comes from.

Lower timeframe sampling

You can't get any of this off a chart bar. A candle that closes mid-range looks balanced. The activity underneath it may have been not have been: heavy pushes both ways that happened to cancel by the close.

So every candle gets broken into as many as twenty lower-timeframe samples and measured piece by piece. The useful part is placement. The bubble lands on the section of the candle that carried the fight, so it sits at a price that actually traded instead of an average of the bar.

█ TIME OF DAY NORMALIZATION

Normally, volume is heavy at the open, declines through the morning, flat around midday, building into the close. Anything that compares a bar to the bars right behind it will be inherently flawed since volume activity shifts throughout the session. 

Time Of Day normalization gets rid of this issue. Instead of comparing a bar to whatever came before it, it compares the bar to what that clock slot USUALLY looks like. This minute against this minute, from previous sessions.

Session level

Time Of Day normalization can also account for how busy today is. Turn the setting down and a bubble means the bar was unusual for the time of day. Turn it up and the bar has to be unusual for the time of day and for today's own level.

There's a Standard mode as well, which ranks each bar against the bars right behind it. It needs no history and works on any chart type, and it carries the intraday bias described above.

█ WHAT EACH BUBBLE TELLS YOU

Three things drive each bubble:

 • Whether it appears — If it appears, it says the bar's level of contested volume was unusual based on your selected percentile rank.
 • Size — how big the bar's magnitude source is compared to the last 100 bars. By default, its Total Delta Volume. Other options are below.

Magnitude sources

 • Total delta volume — Total cumulative volume delta.
 • Contested volume — Total contested volume
 • Total volume — Simply how much traded.
 • Net delta — how directional the bar was end to end, ignoring churn that reversed inside it.

Hover any bubble and the tooltip gives you all four, the trigger rank, and in Time Of Day mode both the slot's normal level and how today is running against it.

█ NOTES

 • Time Of Day needs a few sessions of each clock slot before it prints anything, so a chart you just loaded starts empty at the left edge. It falls back to Standard on daily and above and on non-time-based charts.
 • Intrabar precision depends on lower-timeframe data, which may vary by symbol and by account plan. Without lower-timeframe data, the indicator will still work, but with much less precision.
 • Three alerts are available: any bubble, bubbles on a positive net delta bar, bubbles on a negative one. All initiate on bar close.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © B3AR_Trades
// An indicator by

// ######:   . ####:     :##:    ######:  
// #######   #######:     ##     #######  
// ##   :##  #:.   ##    ####    ##   :## 
// ##    ##        ##    ####    ##    ## 
// ##   :##        ##   :#  #:   ##   :## 
// #######.    #####     #::#    #######: 
// #######.    #####.   ##  ##   ######   
// ##   :##        ##   ######   ##   ##. 
// ##    ##        ##  .######.  ##   ##  
// ##   :##  #:    ##  :##  ##:  ##   :## 
// ########  #######:  ###  ###  ##    ##:
// ######    :#####:   ##:  :##  ##    ##:

//@version=6
indicator("Contested Volume Bubbles", "Bubbles", overlay = true,
     max_labels_count = 500, max_bars_back = 1100)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — PROFILE
// ══════════════════════════════════════════════════════════════════════════════

profile = input.string(
     "Selective", "Profile",
     options = ["Balanced", "Selective", "Very Selective", "Contested Volume ID", "Volume Delta ID", "Custom"],
     tooltip =
         "Presets for how often bubbles print and what they measure. Settings\n" +
         "marked 'Custom profile only' are ignored unless Profile is Custom.\n\n" +
         "Balanced            → about 4% of bars. General purpose.\n" +
         "Selective           → about 2%, with a stronger activity requirement.\n" +
         "Very Selective      → about 1%. Only bars that stand out over a wide\n" +
         "                      window and on real size.\n" +
         "Contested Volume ID → about 6%, sized by how big the fight was.\n" +
         "Volume Delta ID     → frequent local marks sized by directional volume.\n" +
         "                      Prints often; lower Halo Rings to keep history.",
     group = "Profile")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — TRIGGER
// ══════════════════════════════════════════════════════════════════════════════

inNormMode = input.string(
     "Time Of Day", "Normalization",
     options = ["Standard", "Time Of Day"],
     tooltip =
         "What counts as a lot of volume.\n\n" +
         "Standard    → judges each bar against the bars just before it. The rate\n" +
         "              drifts with the clock: quiet through a decline, heavy into\n" +
         "              the close, a burst at every open.\n" +
         "Time Of Day → judges each bar against what this time of day normally\n" +
         "              looks like. Even coverage, works overnight, needs a few\n" +
         "              sessions of history first.\n\n" +
         "Custom profile only.",
     group = "Trigger")

inTrigLen = input.int(
     50, "Trigger Lookback", minval = 10, maxval = 500, step = 5,
     tooltip =
         "How wide a stretch a bar has to stand out over. Short marks local\n" +
         "spikes, long marks rarer events — this is the real rarity control, not\n" +
         "the percentile. Time Of Day handles 150-250 well; Standard does not.\n\n" +
         "Custom profile only.",
     group = "Trigger")

inPctThresh = input.float(
     98.0, "Trigger Percentile", minval = 80.0, maxval = 100.0, step = 1.0,
     tooltip =
         "How exceptional a bar has to be to print. The rate is fixed by design\n" +
         "and does not change with the market: 98 prints about 4% of bars, 100\n" +
         "about 2%. Above 98 you need a longer Trigger Lookback to go finer.\n\n" +
         "Custom profile only.",
     group = "Trigger")

inActFloor = input.float(
     0.75, "Activity Floor", minval = 0.0, maxval = 2.0, step = 0.05,
     tooltip =
         "Keeps bubbles off the biggest bar of a dead stretch. Raise it if you\n" +
         "are seeing marks through lunch or in thin overnight tape. 0 disables.\n\n" +
         "Custom profile only.",
     group = "Trigger")

smoothLen = input.int(
     1, "Pre-Rank Smoothing", minval = 1, maxval = 50,
     tooltip =
         "Softens single-bar noise before the trigger sees it. Does little here —\n" +
         "worth trying only if you are getting isolated marks you do not trust.",
     group = "Trigger")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — TIME OF DAY
// ══════════════════════════════════════════════════════════════════════════════

todDays = input.int(
     10, "Seasonal Memory (sessions)", minval = 3, maxval = 60,
     tooltip =
         "How many recent sessions shape the expectation for each time of day.\n" +
         "Shorter re-adjusts faster after a volatility shift or a contract roll;\n" +
         "longer is steadier.",
     group = "Time Of Day")

todWarm = input.int(
     4, "Warm-Up Sessions", minval = 1, maxval = 20,
     tooltip =
         "How much history to gather before anything prints. Lower it to see\n" +
         "marks sooner on a fresh chart, at the cost of a rougher baseline.",
     group = "Time Of Day")

dayStr = input.float(
     0.6, "Session Level Normalization", minval = 0.0, maxval = 1.0, step = 0.1,
     tooltip =
         "Whether a busy day is context or is itself the event.\n\n" +
         "0 → a session running hot prints bubbles all day. Shows you which days\n" +
         "    were unusual.\n" +
         "1 → every session gets about the same count. Shows you the standout\n" +
         "    bars within whatever day you are in.\n\n" +
         "Each bubble's tooltip reports the session level separately, so you can\n" +
         "read both off one mark.",
     group = "Time Of Day")

dayClamp = input.float(
     0.9, "Session Estimator Clamp", minval = 0.3, maxval = 3.0, step = 0.1,
     tooltip =
         "Stops a few huge bars from raising the bar for everything after them.\n" +
         "Tighten it if the back half of an eventful session goes quiet.",
     group = "Time Of Day")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — INTRABAR PRECISION
// ══════════════════════════════════════════════════════════════════════════════

precisionMode = input.string(
     "High", "Intrabar Precision",
     options = ["Off", "Low", "Medium", "High", "Manual"],
     tooltip =
         "How closely the inside of each bar is examined. Finer resolves the\n" +
         "buy/sell split and places the bubble at the most contested moment\n" +
         "rather than the bar's midpoint. High is comfortable intraday; drop to\n" +
         "Medium on long histories.",
     group = "Intrabar Precision")

manualLtf = input.timeframe(
     "5S", "Manual Lower Timeframe",
     tooltip = "Used only when Intrabar Precision is set to Manual.",
     group   = "Intrabar Precision")

minLtfOpt = input.string(
     "5 seconds", "Minimum Lower Timeframe",
     options = ["1 second", "5 seconds", "10 seconds", "15 seconds", "30 seconds", "1 minute"],
     tooltip =
         "Floor on how fine the automatic setting will go. Very short intervals\n" +
         "often contain no price movement, which tells you nothing about who was\n" +
         "aggressive.",
     group = "Intrabar Precision")

skipFlat = input.bool(
     true, "Skip Zero-Range Intrabars",
     tooltip =
         "Ignore moments where price did not move. Counting them would make the\n" +
         "quietest moments read as the most contested — leave this on.",
     group = "Intrabar Precision")

requireLtf = input.bool(
     true, "Require Intrabar Data",
     tooltip =
         "Suppress bubbles where the detailed reading is not available. Detailed\n" +
         "data only goes back so far, and marks past that boundary are not\n" +
         "measuring the same thing as the recent ones.",
     group = "Intrabar Precision")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — BUBBLE SIZE
// ══════════════════════════════════════════════════════════════════════════════

inSizeSource = input.string(
     "Total Delta Volume", "Magnitude Source",
     options = ["Total Delta Volume", "Contested Volume", "Total Volume", "Net Delta"],
     tooltip =
         "What size and opacity mean. The trigger decides where bubbles appear;\n" +
         "this decides which of them look important.\n\n" +
         "Total Delta Volume → directional trading inside the bar, including what\n" +
         "                     reversed before the close. Adds information the\n" +
         "                     trigger does not carry.\n" +
         "Contested Volume   → how big the fight was. Agrees with the trigger by\n" +
         "                     construction.\n" +
         "Total Volume       → how much traded. Closely tracks the trigger.\n" +
         "Net Delta          → how one-sided the bar was end to end.\n\n" +
         "Custom profile only.",
     group = "Bubble Size")

sizeLen = input.int(
     100, "Size Lookback", minval = 10, maxval = 1000, step = 10,
     tooltip =
         "What bubble size is judged against. Longer keeps sizes comparable\n" +
         "across a session; shorter makes them relative to the immediate area.",
     group = "Bubble Size")

sizeBasis = input.string(
     "Range Position", "Size Basis",
     options = ["Range Position", "Percent Rank"],
     tooltip =
         "Range Position → sizes by distance from the extreme. Outliers dwarf\n" +
         "                 everything; most bubbles sit small.\n" +
         "Percent Rank   → sizes by how many bars it beat. Sizes spread evenly.",
     group = "Bubble Size")

inMinBubble = input.int(
     25, "Minimum Size", minval = 5, maxval = 100,
     tooltip = "Size of the smallest qualifying bubble.\n\nCustom profile only.",
     group   = "Bubble Size")

inMaxBubble = input.int(
     50, "Maximum Size", minval = 5, maxval = 100,
     tooltip = "Size of the largest bubble. No practical ceiling.\n\nCustom profile only.",
     group   = "Bubble Size")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — BUBBLE OPACITY
// ══════════════════════════════════════════════════════════════════════════════

transpLen = input.int(
     100, "Opacity Lookback", minval = 10, maxval = 1000, step = 10,
     tooltip = "What opacity is judged against. Longer keeps fading consistent across the session.",
     group   = "Bubble Opacity")

minTransp = input.int(
     35, "Transparency At 100th Percentile", minval = 0, maxval = 100, step = 5,
     tooltip = "Applied to the strongest bubbles. 0 = fully solid.",
     group   = "Bubble Opacity")

maxTransp = input.int(
     70, "Transparency At 0th Percentile", minval = 0, maxval = 100, step = 5,
     tooltip =
         "Applied to the weakest bubbles. This is what separates a bubble that\n" +
         "barely qualified from one that cleared on real size.",
     group = "Bubble Opacity")

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS — DISPLAY
// ══════════════════════════════════════════════════════════════════════════════

haloSpread = input.int(
     6, "Halo Rings", minval = 0, maxval = 6,
     tooltip =
         "Glow around each bubble. Costs history — six rings keeps about 71\n" +
         "bubbles on the chart, four keeps 100, zero keeps 500.",
     group = "Display")

haloReach = input.float(
     1, "Halo Reach", minval = 0.15, maxval = 1.0, step = 0.05,
     tooltip =
         "How far the glow extends past the bubble. Scales with bubble size, so\n" +
         "it reads the same at every size.",
     group = "Display")

haloIntensity = input.int(
     70, "Halo Intensity", minval = 0, maxval = 95, step = 5,
     tooltip = "Brightness of the glow. Lower is brighter.",
     group   = "Display")

colorTheme = input.string(
     "Modern", "Color Theme",
     options = ["Traditional", "Modern", "Heatwave", "Stealth", "Aurora", "Magma", "Plasma", "Custom"],
     tooltip =
         "Traditional → Green / Red\n" +
         "Modern      → Cyan / Red\n" +
         "Heatwave    → Amber / Violet\n" +
         "Stealth     → Teal / Rose\n" +
         "Aurora      → Lime / Indigo\n" +
         "Magma       → Ice White / Deep Red\n" +
         "Plasma      → Orange / Purple\n" +
         "Custom      → Choose your own colors",
     group = "Display")

customBull = input.color(color.rgb(41,  180, 83), "Custom Bullish", inline = "custom", group = "Display")
customBear = input.color(color.rgb(189, 43,  43), "Custom Bearish", inline = "custom", group = "Display")

bubbleColor = input.string(
     "Net Direction", "Bubble Coloring",
     options = ["Net Direction", "Single Hue"],
     tooltip =
         "Size carries how big the fight was, so color is free to carry who won\n" +
         "it.\n\n" +
         "Net Direction → tint by which side came out ahead.\n" +
         "Single Hue    → one color regardless of direction.",
     group = "Display")

// ══════════════════════════════════════════════════════════════════════════════
// PROFILE RESOLUTION
// Presets override the Trigger and Bubble Size inputs. Everything else stays
// manual. Custom passes the inputs through unchanged.
// ══════════════════════════════════════════════════════════════════════════════

isCustom = profile == "Custom"

normMode = isCustom ? inNormMode :
     profile == "Volume Delta ID" ? "Standard" : "Time Of Day"

trigLen = isCustom ? inTrigLen :
     profile == "Very Selective"  ? 100 :
     profile == "Volume Delta ID" ? 20  : 50

pctThresh = isCustom ? inPctThresh :
     profile == "Selective"           ? 99.0  :
     profile == "Very Selective"      ? 100.0 :
     profile == "Contested Volume ID" ? 96.0  :
     profile == "Volume Delta ID"     ? 85.0  : 98.0

actFloor = isCustom ? inActFloor :
     profile == "Selective"       ? 1.25 :
     profile == "Very Selective"  ? 1.75 :
     profile == "Volume Delta ID" ? 1.00 : 0.75

sizeSource = isCustom ? inSizeSource :
     profile == "Contested Volume ID" ? "Contested Volume" : "Total Delta Volume"

minBubble = isCustom ? inMinBubble :
     profile == "Contested Volume ID" ? 10 :
     profile == "Volume Delta ID"     ? 10 : 25

maxBubble = isCustom ? inMaxBubble :
     profile == "Volume Delta ID" ? 80 : 50

// ══════════════════════════════════════════════════════════════════════════════
// THEME COLORS
// ══════════════════════════════════════════════════════════════════════════════

themeBull =
     colorTheme == "Traditional" ? color.rgb(41,  180, 83)  :
     colorTheme == "Modern"      ? color.rgb(0,   229, 255) :
     colorTheme == "Heatwave"    ? color.rgb(255, 170, 0)   :
     colorTheme == "Stealth"     ? color.rgb(32,  178, 170) :
     colorTheme == "Aurora"      ? color.rgb(80,  220, 50)  :
     colorTheme == "Magma"       ? color.rgb(255, 230, 240) :
     colorTheme == "Plasma"      ? color.rgb(255, 140, 0)   :
     customBull

themeBear =
     colorTheme == "Traditional" ? color.rgb(189, 43,  43)  :
     colorTheme == "Modern"      ? color.rgb(255, 45,  45)  :
     colorTheme == "Heatwave"    ? color.rgb(138, 43,  226) :
     colorTheme == "Stealth"     ? color.rgb(255, 99,  132) :
     colorTheme == "Aurora"      ? color.rgb(72,  52,  212) :
     colorTheme == "Magma"       ? color.rgb(180, 10,  30)  :
     colorTheme == "Plasma"      ? color.rgb(148, 0,   211) :
     customBear

// ══════════════════════════════════════════════════════════════════════════════
// LOWER TIMEFRAME
// ══════════════════════════════════════════════════════════════════════════════

chartSec = timeframe.in_seconds(timeframe.period)

precRatio =
     precisionMode == "Low"    ? 4  :
     precisionMode == "Medium" ? 8  :
     precisionMode == "High"   ? 16 : 0

minLtfSec =
     minLtfOpt == "1 second"   ? 1  :
     minLtfOpt == "5 seconds"  ? 5  :
     minLtfOpt == "10 seconds" ? 10 :
     minLtfOpt == "15 seconds" ? 15 :
     minLtfOpt == "30 seconds" ? 30 : 60

rawTarget = precRatio > 0 ? chartSec / precRatio : 0.0
capTarget = math.max(rawTarget, minLtfSec)

snapSec =
     capTarget < 2.24     ? 1     :
     capTarget < 7.07     ? 5     :
     capTarget < 12.25    ? 10    :
     capTarget < 21.21    ? 15    :
     capTarget < 42.43    ? 30    :
     capTarget < 103.92   ? 60    :
     capTarget < 232.38   ? 180   :
     capTarget < 519.62   ? 300   :
     capTarget < 1272.79  ? 900   :
     capTarget < 2545.58  ? 1800  :
     capTarget < 5091.17  ? 3600  :
     capTarget < 10182.34 ? 7200  :
     capTarget < 35272.51 ? 14400 : 86400

autoLtf =
     snapSec == 1     ? "1S"  :
     snapSec == 5     ? "5S"  :
     snapSec == 10    ? "10S" :
     snapSec == 15    ? "15S" :
     snapSec == 30    ? "30S" :
     snapSec == 60    ? "1"   :
     snapSec == 180   ? "3"   :
     snapSec == 300   ? "5"   :
     snapSec == 900   ? "15"  :
     snapSec == 1800  ? "30"  :
     snapSec == 3600  ? "60"  :
     snapSec == 7200  ? "120" :
     snapSec == 14400 ? "240" : "D"

manualSec = timeframe.in_seconds(manualLtf)

useLTF =
     precisionMode == "Manual" ? manualSec < chartSec :
     precisionMode == "Off"    ? false :
     snapSec < chartSec

ltfTF = not useLTF             ? timeframe.period :
     precisionMode == "Manual" ? manualLtf : autoLtf

[ltfH, ltfL, ltfC, ltfV] = request.security_lower_tf(
     syminfo.tickerid, ltfTF,
     [high, low, close, nz(volume, 0.0)],
     ignore_invalid_timeframe = true)

// ══════════════════════════════════════════════════════════════════════════════
// VOLUME SPLIT
// ══════════════════════════════════════════════════════════════════════════════

splitVol(h, l, c, v) =>
    rng = h - l
    bF  = rng > 0 ? (c - l) / rng : 0.5
    sF  = rng > 0 ? (h - c) / rng : 0.5
    [v * bF, v * sF]

// ══════════════════════════════════════════════════════════════════════════════
// PER-BAR AGGREGATION AND ANCHOR SELECTION
// ══════════════════════════════════════════════════════════════════════════════

float barBuy    = 0.0
float barSell   = 0.0
float barAbsDel = 0.0
float bestScore = -1.0
float bestPrice = na

int nIB = useLTF and not na(ltfH) ? ltfH.size() : 0

if nIB > 0
    for j = 0 to nIB - 1
        ih = ltfH.get(j)
        il = ltfL.get(j)
        ic = ltfC.get(j)
        iv = nz(ltfV.get(j), 0.0)
        if not na(ih) and not na(il) and not na(ic)
            if not (skipFlat and ih == il)
                [ibV, isV] = splitVol(ih, il, ic, iv)
                barBuy    := barBuy    + ibV
                barSell   := barSell   + isV
                barAbsDel := barAbsDel + math.abs(ibV - isV)

                sc = math.min(ibV, isV)
                if sc > bestScore
                    bestScore := sc
                    bestPrice := (ih + il + ic) / 3.0
else
    if not (skipFlat and high == low)
        [bV, sV] = splitVol(high, low, close, nz(volume, 0.0))
        barBuy    := bV
        barSell   := sV
        barAbsDel := math.abs(bV - sV)

anchor = na(bestPrice) ? hlc3 : bestPrice

netDelta  = barBuy - barSell
absDelta  = math.abs(netDelta)
totalVol  = barBuy + barSell
contested = math.min(barBuy, barSell)

totalDelta = barAbsDel

ltfOK = not requireLtf or not useLTF or nIB > 0

// ══════════════════════════════════════════════════════════════════════════════
// TRIGGER — SHARED
// ══════════════════════════════════════════════════════════════════════════════

src = ta.ema(contested, smoothLen)

// ══════════════════════════════════════════════════════════════════════════════
// TRIGGER — STANDARD
// ══════════════════════════════════════════════════════════════════════════════

stdHi  = ta.highest(src, trigLen)[1]
stdLo  = ta.lowest(src,  trigLen)[1]
stdAvg = ta.sma(src, sizeLen)

stdAlive = src > 0
     and stdHi > stdLo
     and (actFloor == 0.0 or src >= actFloor * stdAvg)

// ══════════════════════════════════════════════════════════════════════════════
// TRIGGER — TIME OF DAY
// ══════════════════════════════════════════════════════════════════════════════

todAvailable = timeframe.isintraday and not timeframe.isticks and chartSec >= 15

nSlots = todAvailable ? int(math.ceil(86400.0 / chartSec)) : 1

var array<float> slotLog = array.new_float(nSlots, na)
var array<int>   slotCnt = array.new_int(nSlots, 0)

slot = todAvailable
     ? math.max(0, math.min(nSlots - 1, int((hour * 3600 + minute * 60 + second) / chartSec)))
     : 0

logC = math.log(contested + 1.0)

// READ 
float sSum = 0.0
int   sCnt = 0
if todAvailable
    for k = slot - 1 to slot + 1
        kk = math.max(0, math.min(nSlots - 1, k))
        sv = array.get(slotLog, kk)
        if not na(sv)
            sSum := sSum + sv
            sCnt := sCnt + 1

seasonal = sCnt > 0 ? sSum / sCnt : na
warmOK   = todAvailable and array.get(slotCnt, slot) >= todWarm
todLevel = na(seasonal) ? na : math.exp(seasonal) - 1.0

rawRes = na(seasonal) ? na : logC - seasonal

// WRITE 
if todAvailable and barstate.isconfirmed
    prev = array.get(slotLog, slot)
    a    = 2.0 / (todDays + 1)
    array.set(slotLog, slot, na(prev) ? logC : prev + a * (logC - prev))
    array.set(slotCnt, slot, array.get(slotCnt, slot) + 1)

// SESSION LEVEL
var float dayRun = 0.0
var int   dayN   = 0

if ta.change(time("D")) != 0
    dayRun := 0.0
    dayN   := 0

kappa  = 8.0
dayLoc = dayN > 0 ? dayRun / dayN : 0.0
dayAdj = dayStr * (dayN / (dayN + kappa)) * dayLoc

if barstate.isconfirmed and not na(rawRes)
    dayRun := dayRun + math.max(-dayClamp, math.min(dayClamp, rawRes))
    dayN   := dayN + 1

todSrc      = nz(rawRes - dayAdj, 0.0)
windowClean = nz(ta.barssince(na(rawRes)), trigLen) >= trigLen

todAlive = contested > 0
     and warmOK
     and windowClean
     and (actFloor == 0.0 or (not na(todLevel) and contested >= actFloor * todLevel))

// ══════════════════════════════════════════════════════════════════════════════
// TRIGGER
// ══════════════════════════════════════════════════════════════════════════════

useTod = normMode == "Time Of Day" and todAvailable

trigSrc = useTod ? todSrc : src
alive   = ltfOK and (useTod ? todAlive : stdAlive)
trigPct = ta.percentrank(trigSrc, trigLen)

trig = alive and trigPct >= pctThresh

// Single source of truth for both rendering and alerts, so an alert can never
// fire on a forming bar that goes on to draw nothing.
sig = trig and barstate.isconfirmed

// ══════════════════════════════════════════════════════════════════════════════
// MAGNITUDE
// ══════════════════════════════════════════════════════════════════════════════

magSrc =
     sizeSource == "Contested Volume" ? contested :
     sizeSource == "Total Volume"     ? totalVol  :
     sizeSource == "Net Delta"        ? absDelta  : totalDelta

// ══════════════════════════════════════════════════════════════════════════════
// SIZE
// ══════════════════════════════════════════════════════════════════════════════

hiM = ta.highest(magSrc, sizeLen)
loM = ta.lowest(magSrc,  sizeLen)

sizePos = sizeBasis == "Range Position"
     ? (hiM - loM > 0 ? (magSrc - loM) / (hiM - loM) : 0.0)
     : ta.percentrank(magSrc, sizeLen) / 100.0

loRad = math.min(minBubble, maxBubble)
hiRad = math.max(minBubble, maxBubble)

sizeIdx = int(math.round(loRad + sizePos * (hiRad - loRad)))
sizeIdx := math.max(5, math.min(100, sizeIdx))

// ══════════════════════════════════════════════════════════════════════════════
// OPACITY
// ══════════════════════════════════════════════════════════════════════════════

magPct = ta.percentrank(magSrc, transpLen) / 100.0

loT = math.min(minTransp, maxTransp)
hiT = math.max(minTransp, maxTransp)

dynTransp = int(math.round(hiT - magPct * (hiT - loT)))
dynTransp := math.max(0, math.min(100, dynTransp))

// ══════════════════════════════════════════════════════════════════════════════
// COLOR
// ══════════════════════════════════════════════════════════════════════════════

dirBull = bubbleColor == "Net Direction" ? netDelta >= 0 : true
baseCol = dirBull ? themeBull : themeBear

// ══════════════════════════════════════════════════════════════════════════════
// RENDERING
// Bubbles are setup as labels. 
// ══════════════════════════════════════════════════════════════════════════════

ringSize(int d) =>
    math.max(sizeIdx + 1, int(math.round(sizeIdx * (1.0 + haloReach * d / haloSpread))))

ringTransp(int d) =>
    f = d / float(haloSpread)
    int(math.round(haloIntensity + (99.0 - haloIntensity) * f))

compose(int ringT) =>
    int(math.round(100.0 - (100.0 - ringT) * (100.0 - dynTransp) / 100.0))

if sig
    if haloSpread > 0
        for d = haloSpread to 1
            label.new(
                 bar_index, anchor,
                 text      = "⬤",
                 color     = #00000000,
                 textcolor = color.new(baseCol, compose(ringTransp(d))),
                 style     = label.style_label_center,
                 size      = ringSize(d))

    label.new(
         bar_index, anchor,
         text      = "⬤",
         color     = #00000000,
         textcolor = color.new(baseCol, dynTransp),
         style     = label.style_label_center,
         size      = sizeIdx,
         tooltip   =
             "Contested: "    + str.tostring(contested,  format.volume) + "\n" +
             "Net delta: "    + str.tostring(netDelta,   format.volume) + "\n" +
             "Total delta: "  + str.tostring(totalDelta, format.volume) + "\n" +
             "Volume: "       + str.tostring(totalVol,   format.volume) + "\n" +
             "Trigger rank: " + str.tostring(trigPct, "#") + "\n" +
             "Size rank: "    + str.tostring(magPct * 100, "#") + " (" + sizeSource + ")\n" +
             (useTod
                  ? "Slot normal: "   + str.tostring(todLevel, format.volume) + "\n" +
                    "Session level: " + str.tostring(math.exp(dayLoc), "#.##") + "x\n"
                  : "") +
             "Price: "        + str.tostring(anchor, format.mintick))

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(sig,                   "Contested Bubble",        "Contested bubble printed")
alertcondition(sig and netDelta >= 0, "Contested Bubble — Buy",  "Contested bubble printed, net delta positive")
alertcondition(sig and netDelta <  0, "Contested Bubble — Sell", "Contested bubble printed, net delta negative")
````
