# Exhaustion Zones (Momentum Episodes) [HermesCore]

- url: https://www.tradingview.com/script/ZJzJTK3n-Exhaustion-Zones-Momentum-Episodes-HermesCore/
- type: indicator
- pine_id: PUB;3fbfefa55d5b48dcad8c8066ef552730
- version: 1.0

## Description

[b]WHAT THIS INDICATOR DOES[/b]

[i] Exhaustion Zones (Momentum Episodes) [/i]watches RSI, the Relative Strength Index, a standard momentum gauge that runs from 0 to 100. When it closes beyond a threshold (70 high, 30 low by default), a saturation episode begins. While the episode lasts I track two things: the most extreme price it prints, and the highest or lowest RSI it reaches. The moment RSI closes back inside, the episode is over and one event fires.

That event leaves a zone on the chart. Not an arbitrary band: the zone is the wick of the bar that printed the episode extreme. That wick is the exact range where the last buyers or sellers ran out. The question this script keeps asking is simple: where did price stand when the fuel ran out, and does that place get respected afterwards?

Every zone gets a 0 to 6 quality score at birth, and from then on the script counts what happens: held or broken, per grade, with sample sizes shown.

[b]WHY IT IS DIFFERENT[/b]

Most overbought and oversold tools mark the moment and move on. An arrow prints at RSI 70 and nobody ever counts what happened next. My rules are:

- An episode is one event, not a stream of signals. RSI can sit above 70 for thirty bars; that is still one episode, one zone. The state machine needs no cooldown tricks because episodes are naturally separate: RSI has to leave and come back.
- The zone is price structure, not decoration. It spans the wick of the episode-extreme bar, padded to a minimum thickness when the wick is thin, rejected entirely when a single mega-candle would paint an unusable block (the dashboard counts those rejections too).
- The score never changes after birth. It is built only from facts known the moment the episode ends.
- Every zone resolves and every resolution is counted. Held versus broken, per grade, with n. If grade A zones hold no better than grade C zones on your chart, the dashboard will tell you so.
- Everything updates on confirmed bars only. An episode cannot start, peak or end within a forming candle. No intrabar flicker, no repainting events.

[b]HOW TO READ THE CHART[/b]

- Zone box: red above price (exhaustion high, resistance), green below (exhaustion low, support). A label like "Exh High A  S:5  RSI:77" reads: exhaustion high, grade A, score 5, the episode peaked at RSI 77.
- The saturated inner band at the extreme side is the core: the final half ATR (Average True Range, a standard volatility measure) of the wick, where the move was most exhausted. The fainter remainder is the rest of the wick.
- The vivid one-candle stripe inside the zone marks the exact bar that printed the extreme.
- Gold color with a soft glow: the grade is A or S. Those are the premium zones.
- Thicker border: the zone was touched, price came back to it at least once.
- Faint grey boxes without text: resolved history. A slightly stronger outline means the zone held, a weaker one means it broke. History whispers, it does not shout.
- Zones farther than 6 ATR from price render dimmed, so your eye goes to what is in play.

[b]THE SCORE[/b]

- Saturation depth: peak RSI reached 80 or beyond (20 or below for lows), +2. Just past the threshold, +1.
- Climax volume: the extreme bar traded above its own volume average, +1.
- Fast fade: RSI closed back inside within 5 bars of its peak, a fast rejection, +1.
- Episode divergence: price printed a more extreme level than the previous episode while peak RSI stayed less extreme, +1. Compared episode to episode, and stated as such.
- Wick quality: the rejection wick of the extreme bar is at least 45 percent of its body, +1.

Grades: S (6), A (5), B (4), C (3), D (0 to 2). The strength filter is off by default: episodes are scarce enough to show them all and let the grade speak. Turn it on if you only want premium zones.

[b]HELD VERSUS BROKEN[/b]

A zone is broken when price closes beyond its far edge. A zone is held when it survives to its maximum age (400 bars by default) without that happening. Every resolved zone lands in the per-grade statistics: "18% held  32 / 149  (n=181)" reads as 32 held, 149 broken, 181 judged in total.

Be aware what the definition means: held is a strict standard. Surviving 400 bars unbroken is a long time, so the absolute percentages run low by design. What matters is the ordering. On my charts S grades hold clearly better than A and B, which hold better than C. That ordering is the evidence that the score measures something real, and your own dashboard will show you whether it does on your market.

[b]DASHBOARD[/b]

RSI now with its state. Episode now: when a saturation episode is live you see its running extreme and peak RSI update bar by bar, so you watch the zone being born. Active zone count per side. Five grade rows with held percentage, raw counts and n. Lifetime events per side plus total touches. Guard rejects, the oversized zones that were refused. Heat bars are proportional.

[b]HOW I USE IT[/b]

This script is deliberately timeframe agnostic: an RSI episode means the same thing on every chart, only the rhythm changes.

- 4H is where I read regime. Episodes are scarce there and the zones land on swing highs and lows you would have marked by hand. An A or S exhaustion high on 4H is a place I expect sellers to defend.
- 1H is the middle ground: more events, still clean structure.
- 15m is the execution and evidence frame. Episodes are frequent, so the statistics build n fast, and I use the zones as intraday reaction levels. Expect more mediocre grades here; the dashboard shows you exactly how mediocre.

My core read is the combination of grade and first touch. A fresh A or S zone that gets its first touch is the highest quality moment this script produces: price returning to the exact range where the last push died, while the statistics tell me how often that place held in the past. A D zone breaking is not a surprise, it is the base rate.

[b]SETTINGS THAT MATTER[/b]

- Saturation Level High and Low (70/30): the episode thresholds. Widen to 75/25 for fewer, heavier episodes.
- Deep Saturation Level (80): the line between +1 and +2 for depth.
- Zone Max Age (400 bars): the held standard. Lower it and held becomes easier to earn; the statistics will recalculate accordingly. Neither setting is the truth, they answer different questions.
- Min Zone Thickness (0.25 ATR) and Max Zone Height (3.0 ATR): the zone sanity guards.
- Broken Zones Become: greyed history or deleted. Your choice of how loud the past is.
- Show Exhaustion Core, Highlight Extreme Candle, Focus Fade: the visual layers, all styling only, all on by default.

[b]ALERTS[/b]

New Exhaustion High Zone, New Exhaustion Low Zone, Exhaustion High First Touch, Exhaustion Low First Touch, Exhaustion Zone Broken, New A/S Exhaustion Zone. Touch alerts fire on the first touch only.

[b]CALCULATION DETAILS[/b]

- All state changes happen on confirmed bars. Episodes start, extend and end on closes only.
- RSI length 14 on close by default. The episode tracks the running price extreme and RSI peak; both freeze the moment the episode ends.
- The zone spans from the episode extreme to the body edge of the extreme bar, padded to the minimum thickness, rejected above the height cap.
- Divergence needs a previous episode on the same side to compare against, so the first episode per side can never score that point.
- The statistics are computed from the bars your chart loads, so they differ per timeframe and per symbol. Neither is wrong, they measure different samples.

[b]HONEST LIMITATIONS[/b]

- The statistics describe the past. They tell you how often these zones held on the loaded history, not what the next one will do.
- Held is defined as surviving the maximum age. That is a strict standard and it keeps the absolute percentages modest. Read the ordering between grades, not the raw numbers, and recalibrate the age to your own horizon.
- Scores on a fresh chart need history: volume averages and the previous episode for divergence take time to fill in.
- RSI is calculated on the chart's candles. On Heikin Ashi, Renko or other synthetic chart types the closes are not real prices and every result is distorted. Use standard candles.
- A zone is a place where exhaustion happened, not a guarantee of reversal. Strong trends break exhaustion zones routinely; that is exactly what the broken counts are there to show you.

[b]ORIGINALITY[/b]

Overbought and oversold are as old as RSI itself. The episode state machine, the wick-anchored zone construction, the 0 to 6 scoring, the held versus broken accounting per grade and the visual language are my own work, built from scratch in Pine v6. Every number on the dashboard is recomputable from the rules in this description.

Questions and suggestions are welcome in the comments. Enjoy.

## Source Code

````pine
//@version=6
indicator("Exhaustion Zones (Momentum Episodes) [HermesCore]", "EXH-HC", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=500)

// Where did price stand when the fuel ran out. A saturation episode starts
// when RSI closes beyond its threshold, tracks the price extreme and the
// RSI peak while it lasts, and fires when RSI closes back inside. The zone
// is the wick of the extreme bar: the exact range where the last buyers or
// sellers ran out. Scored 0 to 6 from formation facts, then tracked
// honestly: held versus broken per grade, with n shown. All state changes
// on confirmed bars only.

// Inputs
group_main = "01 Main"
rsiLen = input.int(14, "RSI Length", minval=2, maxval=100, group=group_main)
obLevel = input.float(70, "Saturation Level High", minval=55, maxval=95, group=group_main, tooltip="An episode on the high side starts when RSI closes at or above this level and ends when it closes back below. The event fires at the end.")
osLevel = input.float(30, "Saturation Level Low", minval=5, maxval=45, group=group_main)
extendBars = input.int(40, "Zone Extension", minval=5, maxval=300, group=group_main)
maxZones = input.int(10, "Max Zones / Side", minval=1, maxval=50, group=group_main)
showBearZones = input.bool(true, "Show Exhaustion Highs (resistance)", group=group_main)
showBullZones = input.bool(true, "Show Exhaustion Lows (support)", group=group_main)

group_logic = "02 Logic"
deepLevel = input.float(80, "Deep Saturation Level", minval=60, maxval=99, group=group_logic, tooltip="A peak RSI at or beyond this level scores +2 for saturation depth instead of +1. Mirrored for lows at 100 minus this value.")
fadeBars = input.int(5, "Fast Fade Window (bars)", minval=1, maxval=30, group=group_logic, tooltip="If RSI closes back inside within this many bars after its peak, the rejection was fast and scores +1.")
minThickATR = input.float(0.25, "Min Zone Thickness (ATR mult)", minval=0.05, maxval=2.0, step=0.05, group=group_logic, tooltip="A wick thinner than this is padded to this thickness so the zone stays tradeable.")
maxZoneATR = input.float(3.0, "Max Zone Height (ATR mult)", minval=0.5, maxval=10.0, step=0.1, group=group_logic, tooltip="Zones taller than this many ATR are rejected. Keeps a single mega-candle from painting an unusable zone.")
zoneMaxAge = input.int(400, "Zone Max Age (bars)", minval=20, maxval=2000, group=group_logic, tooltip="A zone that reaches this age unbroken resolves as held and freezes as history.")
brokenMode = input.string("Greyed History", "Broken Zones Become", options=["Greyed History", "Deleted"], group=group_logic)
useScoreFilter = input.bool(false, "Use Strength Filter", group=group_logic)
minScore = input.int(3, "Minimum Strength Score", minval=0, maxval=6, group=group_logic)

group_score = "03 Strength Score"
atrLen = input.int(14, "ATR Length", minval=1, group=group_score)
volumeLen = input.int(20, "Volume MA Length", minval=1, group=group_score)
useDepthScore = input.bool(true, "Use Saturation Depth", group=group_score)
useVolumeScore = input.bool(true, "Use Climax Volume", group=group_score)
useFadeScore = input.bool(true, "Use Fast Fade", group=group_score)
useDivScore = input.bool(true, "Use Episode Divergence", group=group_score, tooltip="Price printed a more extreme level than the previous episode while peak RSI stayed less extreme. Compared episode to episode, stated as such.")
useWickScore = input.bool(true, "Use Wick Quality", group=group_score)

group_visual = "04 Visuals"
showLabels = input.bool(true, "Show Zone Labels", group=group_visual)
showRsiLabel = input.bool(true, "Show Peak RSI in Label", group=group_visual)
showMidlines = input.bool(true, "Show Midlines", group=group_visual)
showZoneEdges = input.bool(true, "Show Zone Edge Lines", group=group_visual)
showDashboard = input.bool(true, "Show Dashboard", group=group_visual)
showGlow = input.bool(true, "Show Premium Glow (A/S zones)", group=group_visual, tooltip="Gold glow drawn only around zones graded A or S, so quality is visible from across the room.")
showOriginSpine = input.bool(true, "Highlight Extreme Candle", group=group_visual, tooltip="A vivid one-candle stripe inside the zone marking the exact bar that printed the episode extreme.")
showCoreLayer = input.bool(true, "Show Exhaustion Core", group=group_visual, tooltip="A more saturated inner layer on the extreme side of the zone, capped at half an ATR. The closer to the episode extreme, the more exhausted the move was. Styling only.")
showFocusFade = input.bool(true, "Focus Fade", group=group_visual, tooltip="Active zones farther than 6 ATR from price render dimmed. Styling only.")

group_colors = "05 Colors"
bullColor = input.color(color.rgb(0, 220, 170), "Exhaustion Low Color", group=group_colors)
bearColor = input.color(color.rgb(255, 70, 110), "Exhaustion High Color", group=group_colors)
goldColor = input.color(color.rgb(245, 190, 80), "High Score Color", group=group_colors)
neutralColor = input.color(color.rgb(160, 160, 160), "Neutral Color", group=group_colors)

// Series
rsiSeries = ta.rsi(close, rsiLen)
atrSeries = ta.atr(atrLen)
volMaSeries = ta.sma(volume, volumeLen)

// Helpers
f_transparency(int score) =>
    score >= 6 ? 48 :
     score >= 5 ? 58 :
     score >= 4 ? 68 :
     score >= 3 ? 76 :
     86

f_grade(int score) =>
    score >= 6 ? "S" :
     score >= 5 ? "A" :
     score >= 4 ? "B" :
     score >= 3 ? "C" : "D"

f_gbucket(int score) =>
    score >= 6 ? 0 : score == 5 ? 1 : score == 4 ? 2 : score == 3 ? 3 : 4

f_score_color(bool bullish, int score) =>
    score >= 5 ? goldColor : bullish ? bullColor : bearColor

f_zone_fill(bool bullish, int score) =>
    color base = bullish ? bullColor : bearColor
    color.new(base, f_transparency(score))

f_heat(int pct) =>
    str.repeat("█", math.max(1, int(math.ceil(pct / 20.0))))

// Episode state, index 0 = high side (bearish zones), 1 = low side
var bool[] epiOn = array.new_bool(2, false)
var float[] epiExt = array.new_float(2, na)
var int[] epiExtBar = array.new_int(2, 0)
var float[] epiPeak = array.new_float(2, na)
var int[] epiPeakBar = array.new_int(2, 0)
// previous episode memory for divergence, per side: extreme and peak RSI
var float[] prevExt = array.new_float(2, na)
var float[] prevPeak = array.new_float(2, na)

// Zone pools, parallel arrays per side
var box[] bearBoxes = array.new_box()
var box[] bearGlows = array.new_box()
var box[] bearSpines = array.new_box()
var box[] bearCores = array.new_box()
var line[] bearMids = array.new_line()
var line[] bearTopE = array.new_line()
var line[] bearBotE = array.new_line()
var bool[] bearTouched = array.new_bool()
var int[] bearBirth = array.new_int()
var int[] bearScoreA = array.new_int()

var box[] bullBoxes = array.new_box()
var box[] bullGlows = array.new_box()
var box[] bullSpines = array.new_box()
var box[] bullCores = array.new_box()
var line[] bullMids = array.new_line()
var line[] bullTopE = array.new_line()
var line[] bullBotE = array.new_line()
var bool[] bullTouched = array.new_bool()
var int[] bullBirth = array.new_int()
var int[] bullScoreA = array.new_int()

// Lifetime statistics per grade bucket S A B C D: held vs broken
var int[] statHeld = array.new_int(5, 0)
var int[] statBroken = array.new_int(5, 0)
var int[] tot = array.new_int(4, 0)
// tot: 0 bear events, 1 bull events, 2 zones touched, 3 zones rejected by guards

// Events for alerts: 0 new bear zone, 1 new bull zone, 2 first touch bear,
// 3 first touch bull, 4 zone broken, 5 new A/S zone
var bool[] evt = array.new_bool(6, false)

f_drop_zone(bool bullish, int i) =>
    box[] boxes = bullish ? bullBoxes : bearBoxes
    box[] glows = bullish ? bullGlows : bearGlows
    box[] spines = bullish ? bullSpines : bearSpines
    box[] cores = bullish ? bullCores : bearCores
    line[] mids = bullish ? bullMids : bearMids
    line[] tops = bullish ? bullTopE : bearTopE
    line[] bots = bullish ? bullBotE : bearBotE
    bool[] flags = bullish ? bullTouched : bearTouched
    int[] births = bullish ? bullBirth : bearBirth
    int[] scores = bullish ? bullScoreA : bearScoreA
    array.remove(boxes, i)
    array.remove(glows, i)
    array.remove(spines, i)
    array.remove(cores, i)
    array.remove(mids, i)
    array.remove(tops, i)
    array.remove(bots, i)
    array.remove(flags, i)
    array.remove(births, i)
    array.remove(scores, i)
    true

// Build the zone from a finished episode. Bearish: the upper wick of the
// extreme bar, from the episode extreme down to the body top. Bullish
// mirrored. Padded to the minimum thickness, rejected above the height cap.
f_spawn(bool bullish, float ext, int extBar, float peakRsi, int peakBar) =>
    int ago = bar_index - extBar
    bool ok = ago >= 0 and ago <= 400
    if ok
        float bodyTop = math.max(open[ago], close[ago])
        float bodyBot = math.min(open[ago], close[ago])
        float top = bullish ? bodyBot : ext
        float bottom = bullish ? ext : bodyTop
        if top - bottom < minThickATR * atrSeries
            if bullish
                top := bottom + minThickATR * atrSeries
            else
                bottom := top - minThickATR * atrSeries
        if top - bottom > maxZoneATR * atrSeries
            array.set(tot, 3, array.get(tot, 3) + 1)
        else
            // score, frozen here, every component a countable formation fact
            float body = math.abs(close[ago] - open[ago])
            float upperWick = high[ago] - math.max(open[ago], close[ago])
            float lowerWick = math.min(open[ago], close[ago]) - low[ago]
            float depthRef = bullish ? 100.0 - deepLevel : deepLevel
            int pDepth = useDepthScore ? (bullish ? (peakRsi <= depthRef ? 2 : 1) : (peakRsi >= depthRef ? 2 : 1)) : 0
            int pVol = useVolumeScore and volume[ago] > volMaSeries[ago] ? 1 : 0
            int pFade = useFadeScore and bar_index - peakBar <= fadeBars ? 1 : 0
            int side = bullish ? 1 : 0
            float pe = array.get(prevExt, side)
            float pp = array.get(prevPeak, side)
            bool divOk = not na(pe) and not na(pp) and (bullish ? (ext < pe and peakRsi > pp) : (ext > pe and peakRsi < pp))
            int pDiv = useDivScore and divOk ? 1 : 0
            int pWick = useWickScore and (bullish ? lowerWick > body * 0.45 : upperWick > body * 0.45) ? 1 : 0
            int score = pDepth + pVol + pFade + pDiv + pWick
            if not useScoreFilter or score >= minScore
                int x2 = bar_index + extendBars
                color border = f_score_color(bullish, score)
                float mid = math.avg(top, bottom)
                string rsiTxt = showRsiLabel ? "  RSI:" + str.tostring(peakRsi, "#") : ""
                string txt = showLabels ? (bullish ? "Exh Low " : "Exh High ") + f_grade(score) + "  S:" + str.tostring(score) + rsiTxt : ""
                box gl = na
                if showGlow and score >= 5
                    gl := box.new(extBar, top + atrSeries * 0.06, x2, bottom - atrSeries * 0.06, bgcolor=color.new(goldColor, 90), border_color=color.new(goldColor, 82))
                box b = box.new(extBar, top, x2, bottom, bgcolor=f_zone_fill(bullish, score), border_color=border, text=txt, text_color=border, text_size=score >= 5 ? size.small : size.tiny, text_halign=text.align_right)
                box sp = na
                if showOriginSpine
                    sp := box.new(extBar, top, extBar + 1, bottom, bgcolor=color.new(border, 58), border_color=color.new(border, 35))
                box co = na
                if showCoreLayer
                    float coreDepth = math.min(atrSeries * 0.5, (top - bottom) * 0.4)
                    float coTop = bullish ? bottom + coreDepth : top
                    float coBot = bullish ? bottom : top - coreDepth
                    co := box.new(extBar, coTop, x2, coBot, bgcolor=color.new(border, math.max(30, f_transparency(score) - 16)), border_color=color.new(border, 100))
                line ml = na
                if showMidlines
                    ml := line.new(extBar, mid, x2, mid, color=color.new(border, 55), style=line.style_dotted, width=1)
                line e1 = na
                line e2 = na
                if showZoneEdges
                    e1 := line.new(extBar, top, x2, top, color=color.new(border, 78), width=1)
                    e2 := line.new(extBar, bottom, x2, bottom, color=color.new(border, 78), width=1)
                box[] boxes = bullish ? bullBoxes : bearBoxes
                box[] glows = bullish ? bullGlows : bearGlows
                box[] spines = bullish ? bullSpines : bearSpines
                box[] cores = bullish ? bullCores : bearCores
                line[] mids = bullish ? bullMids : bearMids
                line[] tops = bullish ? bullTopE : bearTopE
                line[] bots = bullish ? bullBotE : bearBotE
                bool[] flags = bullish ? bullTouched : bearTouched
                int[] births = bullish ? bullBirth : bearBirth
                int[] scores = bullish ? bullScoreA : bearScoreA
                array.push(boxes, b)
                array.push(glows, gl)
                array.push(spines, sp)
                array.push(cores, co)
                array.push(mids, ml)
                array.push(tops, e1)
                array.push(bots, e2)
                array.push(flags, false)
                array.push(births, bar_index)
                array.push(scores, score)
                array.set(tot, bullish ? 1 : 0, array.get(tot, bullish ? 1 : 0) + 1)
                array.set(evt, bullish ? 1 : 0, true)
                if score >= 5
                    array.set(evt, 5, true)
                if array.size(boxes) > maxZones
                    box.delete(array.get(boxes, 0))
                    box.delete(array.get(glows, 0))
                    box.delete(array.get(spines, 0))
                    box.delete(array.get(cores, 0))
                    line.delete(array.get(mids, 0))
                    line.delete(array.get(tops, 0))
                    line.delete(array.get(bots, 0))
                    f_drop_zone(bullish, 0)
    true

// Resolve a zone: held freezes as grey history, broken greys or deletes
f_resolve(bool bullish, int i, bool held) =>
    box[] boxes = bullish ? bullBoxes : bearBoxes
    box[] glows = bullish ? bullGlows : bearGlows
    box[] spines = bullish ? bullSpines : bearSpines
    box[] cores = bullish ? bullCores : bearCores
    line[] mids = bullish ? bullMids : bearMids
    line[] tops = bullish ? bullTopE : bearTopE
    line[] bots = bullish ? bullBotE : bearBotE
    int[] scores = bullish ? bullScoreA : bearScoreA
    int gb = f_gbucket(array.get(scores, i))
    box b = array.get(boxes, i)
    box.delete(array.get(glows, i))
    box.delete(array.get(spines, i))
    box.delete(array.get(cores, i))
    line.delete(array.get(mids, i))
    line.delete(array.get(tops, i))
    line.delete(array.get(bots, i))
    if held
        array.set(statHeld, gb, array.get(statHeld, gb) + 1)
        box.set_bgcolor(b, color.new(neutralColor, 96))
        box.set_border_color(b, color.new(neutralColor, 60))
        box.set_text(b, "")
        box.set_right(b, bar_index)
    else
        array.set(statBroken, gb, array.get(statBroken, gb) + 1)
        array.set(evt, 4, true)
        if brokenMode == "Deleted"
            box.delete(b)
        else
            box.set_bgcolor(b, color.new(neutralColor, 96))
            box.set_border_color(b, color.new(neutralColor, 78))
            box.set_text(b, "")
            box.set_right(b, bar_index)
    f_drop_zone(bullish, i)
    true

// Engine, confirmed bars only
if barstate.isconfirmed
    array.fill(evt, false)

    // episode state machine, high side
    if rsiSeries >= obLevel
        if not array.get(epiOn, 0)
            array.set(epiOn, 0, true)
            array.set(epiExt, 0, high)
            array.set(epiExtBar, 0, bar_index)
            array.set(epiPeak, 0, rsiSeries)
            array.set(epiPeakBar, 0, bar_index)
        else
            if high > array.get(epiExt, 0)
                array.set(epiExt, 0, high)
                array.set(epiExtBar, 0, bar_index)
            if rsiSeries > array.get(epiPeak, 0)
                array.set(epiPeak, 0, rsiSeries)
                array.set(epiPeakBar, 0, bar_index)
    else if array.get(epiOn, 0)
        array.set(epiOn, 0, false)
        if showBearZones
            f_spawn(false, array.get(epiExt, 0), array.get(epiExtBar, 0), array.get(epiPeak, 0), array.get(epiPeakBar, 0))
        array.set(prevExt, 0, array.get(epiExt, 0))
        array.set(prevPeak, 0, array.get(epiPeak, 0))

    // episode state machine, low side
    if rsiSeries <= osLevel
        if not array.get(epiOn, 1)
            array.set(epiOn, 1, true)
            array.set(epiExt, 1, low)
            array.set(epiExtBar, 1, bar_index)
            array.set(epiPeak, 1, rsiSeries)
            array.set(epiPeakBar, 1, bar_index)
        else
            if low < array.get(epiExt, 1)
                array.set(epiExt, 1, low)
                array.set(epiExtBar, 1, bar_index)
            if rsiSeries < array.get(epiPeak, 1)
                array.set(epiPeak, 1, rsiSeries)
                array.set(epiPeakBar, 1, bar_index)
    else if array.get(epiOn, 1)
        array.set(epiOn, 1, false)
        if showBullZones
            f_spawn(true, array.get(epiExt, 1), array.get(epiExtBar, 1), array.get(epiPeak, 1), array.get(epiPeakBar, 1))
        array.set(prevExt, 1, array.get(epiExt, 1))
        array.set(prevPeak, 1, array.get(epiPeak, 1))

    // zone lifecycle, bearish (resistance above): broken on close above top
    int i = array.size(bearBoxes) - 1
    while i >= 0
        box b = array.get(bearBoxes, i)
        float top = box.get_top(b)
        float bottom = box.get_bottom(b)
        if close > top
            f_resolve(false, i, false)
        else if bar_index - array.get(bearBirth, i) > zoneMaxAge
            f_resolve(false, i, true)
        else
            if close <= top and close >= bottom and not array.get(bearTouched, i)
                array.set(bearTouched, i, true)
                array.set(tot, 2, array.get(tot, 2) + 1)
                array.set(evt, 2, true)
                box.set_border_width(b, 2)
            box.set_right(b, bar_index + extendBars)
            box gl = array.get(bearGlows, i)
            if not na(gl)
                box.set_right(gl, bar_index + extendBars)
            box co = array.get(bearCores, i)
            if not na(co)
                box.set_right(co, bar_index + extendBars)
            line ml = array.get(bearMids, i)
            if not na(ml)
                line.set_x2(ml, bar_index + extendBars)
            line e1 = array.get(bearTopE, i)
            if not na(e1)
                line.set_x2(e1, bar_index + extendBars)
            line e2 = array.get(bearBotE, i)
            if not na(e2)
                line.set_x2(e2, bar_index + extendBars)
        i -= 1

    // zone lifecycle, bullish (support below): broken on close below bottom
    i := array.size(bullBoxes) - 1
    while i >= 0
        box b = array.get(bullBoxes, i)
        float top = box.get_top(b)
        float bottom = box.get_bottom(b)
        if close < bottom
            f_resolve(true, i, false)
        else if bar_index - array.get(bullBirth, i) > zoneMaxAge
            f_resolve(true, i, true)
        else
            if close <= top and close >= bottom and not array.get(bullTouched, i)
                array.set(bullTouched, i, true)
                array.set(tot, 2, array.get(tot, 2) + 1)
                array.set(evt, 3, true)
                box.set_border_width(b, 2)
            box.set_right(b, bar_index + extendBars)
            box gl = array.get(bullGlows, i)
            if not na(gl)
                box.set_right(gl, bar_index + extendBars)
            box co = array.get(bullCores, i)
            if not na(co)
                box.set_right(co, bar_index + extendBars)
            line ml = array.get(bullMids, i)
            if not na(ml)
                line.set_x2(ml, bar_index + extendBars)
            line e1 = array.get(bullTopE, i)
            if not na(e1)
                line.set_x2(e1, bar_index + extendBars)
            line e2 = array.get(bullBotE, i)
            if not na(e2)
                line.set_x2(e2, bar_index + extendBars)
        i -= 1

// Focus Fade: styling only, recomputed on the last bar
if barstate.islast and showFocusFade
    float band = atrSeries * 6
    int fs = 0
    while fs < 2
        bool bl = fs == 1
        box[] fBoxes = bl ? bullBoxes : bearBoxes
        box[] fGlows = bl ? bullGlows : bearGlows
        box[] fCores = bl ? bullCores : bearCores
        int[] fScores = bl ? bullScoreA : bearScoreA
        int f = array.size(fBoxes) - 1
        while f >= 0
            box pb = array.get(fBoxes, f)
            float mid = math.avg(box.get_top(pb), box.get_bottom(pb))
            bool far = math.abs(close - mid) > band
            int sc = array.get(fScores, f)
            color bc = f_score_color(bl, sc)
            box.set_border_color(pb, color.new(bc, far ? 45 : 0))
            box.set_bgcolor(pb, color.new(bl ? bullColor : bearColor, math.min(95, f_transparency(sc) + (far ? 12 : 0))))
            box.set_text_color(pb, color.new(bc, far ? 40 : 0))
            box gl = array.get(fGlows, f)
            if not na(gl)
                box.set_bgcolor(gl, color.new(goldColor, far ? 95 : 90))
                box.set_border_color(gl, color.new(goldColor, far ? 90 : 82))
            box co = array.get(fCores, f)
            if not na(co)
                box.set_bgcolor(co, color.new(bc, math.min(95, math.max(30, f_transparency(sc) - 16) + (far ? 12 : 0))))
            f -= 1
        fs += 1

// Dashboard
var table dash = table.new(position.top_right, 3, 11, bgcolor=color.new(color.black, 12), border_color=color.new(color.gray, 65), border_width=1)

f_grade_row(int row, int gb, string nm) =>
    int h = array.get(statHeld, gb)
    int br = array.get(statBroken, gb)
    int n = h + br
    int pc = n > 0 ? int(math.round(h * 100.0 / n)) : 0
    color rc = n > 0 ? color.from_gradient(pc, 0, 100, bearColor, bullColor) : neutralColor
    table.cell(dash, 0, row, nm, text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, row, n > 0 ? str.tostring(pc) + "% held  " + str.tostring(h) + " / " + str.tostring(br) + "  (n=" + str.tostring(n) + ")" : "no data yet", text_color=rc, text_size=size.tiny)
    table.cell(dash, 2, row, n > 0 ? f_heat(pc) : "", text_color=rc, text_size=size.tiny)

if showDashboard and barstate.islast
    string rsiState = rsiSeries >= obLevel ? "SATURATED HIGH" : rsiSeries <= osLevel ? "SATURATED LOW" : "neutral"
    color rsiCol = rsiSeries >= obLevel ? bearColor : rsiSeries <= osLevel ? bullColor : neutralColor

    table.cell(dash, 0, 0, "Exhaustion Zones", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, "Held vs broken", text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 0, "Heat", text_color=color.white, text_size=size.small)

    table.cell(dash, 0, 1, "RSI now", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 1, str.tostring(rsiSeries, "#.#") + "  " + rsiState, text_color=rsiCol, text_size=size.tiny)
    table.cell(dash, 2, 1, "█", text_color=rsiCol, text_size=size.small)

    string epiTxt = "none"
    color epiCol = neutralColor
    if array.get(epiOn, 0)
        epiTxt := "HIGH episode, extreme " + str.tostring(array.get(epiExt, 0), format.mintick) + ", peak RSI " + str.tostring(array.get(epiPeak, 0), "#")
        epiCol := bearColor
    else if array.get(epiOn, 1)
        epiTxt := "LOW episode, extreme " + str.tostring(array.get(epiExt, 1), format.mintick) + ", peak RSI " + str.tostring(array.get(epiPeak, 1), "#")
        epiCol := bullColor
    table.cell(dash, 0, 2, "Episode now", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 2, epiTxt, text_color=epiCol, text_size=size.tiny)
    table.cell(dash, 2, 2, array.get(epiOn, 0) or array.get(epiOn, 1) ? "█" : "", text_color=epiCol, text_size=size.small)

    table.cell(dash, 0, 3, "Active zones", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 3, str.tostring(array.size(bearBoxes)) + " high / " + str.tostring(array.size(bullBoxes)) + " low", text_color=neutralColor, text_size=size.tiny)
    table.cell(dash, 2, 3, "█", text_color=neutralColor, text_size=size.small)

    f_grade_row(4, 0, "S zones")
    f_grade_row(5, 1, "A zones")
    f_grade_row(6, 2, "B zones")
    f_grade_row(7, 3, "C zones")
    f_grade_row(8, 4, "D zones")

    table.cell(dash, 0, 9, "Lifetime", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 9, str.tostring(array.get(tot, 0)) + " high / " + str.tostring(array.get(tot, 1)) + " low events, " + str.tostring(array.get(tot, 2)) + " touched", text_color=neutralColor, text_size=size.tiny)
    table.cell(dash, 2, 9, "", text_color=neutralColor, text_size=size.tiny)

    table.cell(dash, 0, 10, "Guard rejects", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 10, str.tostring(array.get(tot, 3)) + " oversized", text_color=neutralColor, text_size=size.tiny)
    table.cell(dash, 2, 10, "", text_color=neutralColor, text_size=size.tiny)

// Alerts, first touch only
alertcondition(array.get(evt, 0), "New Exhaustion High Zone", "A high side saturation episode ended and left a resistance zone")
alertcondition(array.get(evt, 1), "New Exhaustion Low Zone", "A low side saturation episode ended and left a support zone")
alertcondition(array.get(evt, 2), "Exhaustion High First Touch", "Price entered an exhaustion high zone (first touch)")
alertcondition(array.get(evt, 3), "Exhaustion Low First Touch", "Price entered an exhaustion low zone (first touch)")
alertcondition(array.get(evt, 4), "Exhaustion Zone Broken", "An exhaustion zone was broken by a close beyond its far edge")
alertcondition(array.get(evt, 5), "New A/S Exhaustion Zone", "An exhaustion zone armed with grade A or S")
````
