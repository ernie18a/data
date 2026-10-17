# J_MO Structure Pro UTC-4

- url: https://www.tradingview.com/script/SWme4wII-J-MO-Structure-Pro-UTC-4/
- type: indicator
- pine_id: PUB;36ff568173a04bb1b3623b8c7903dd0e
- version: 1.0

## Description

An all-in-one scalping overlay for index futures: custom session windows, EMA trend structure, supply and demand zones, previous day high/low levels, Bollinger Bands, and a multi-timeframe trend panel that flags when lower timeframes run into higher timeframe structure.

Built for the 1, 5 and 15 minute charts, and designed to be read in a fixed order so the parts reinforce each other rather than compete for attention.

Credits and inspiration

The methods this indicator draws on were learned from two YouTube channels, and the credit for the underlying ideas belongs to them.

Scalp Trading Lab — the supply and demand zone approach, the contrary-candle rule for marking a base, the "only untouched zones count" principle, the session-based high and low of day, and the idea that a move draws its power from supply and demand sitting inside a higher timeframe trend. The session shading and the day-level windows follow this channel's teachings.
StocksNOptionsRUs — the multi-timeframe trend framework, reading trend separately on every timeframe rather than one, the rule that a smaller timeframe's trend cannot break itself and needs a higher timeframe to do it, the run-in concept where a lower timeframe pushes into higher timeframe structure, and the use of Bollinger Bands to read compression and band rides.
This script is an independent implementation of those ideas. It is not affiliated with, endorsed by, or published by either channel.

What it draws

Six custom session windows — each shaded in its own colour, each with its own on/off switch and time range. Only candles inside a shaded window are eligible to form a zone, so the sessions do double duty: they show you where you are in the day, and they filter out quiet periods from zone detection.
Supply and demand zones — built from a base candle and a strong push candle that closes beyond the whole base. Red base before a move up makes demand; green base before a move down makes supply. Zones are detected on the 1, 5 and 15 minute timeframes, labelled by timeframe and type, and removed automatically once price touches them so only unused levels stay on the chart.
Previous day levels — HOD, LOD, PHOD and PLOD, each measured inside the 01:00 to 15:14 UTC-4 window. The current day's pair draws in full colour and the older pair sits behind it, faded and dashed, with each line named at its right end.
Three EMAs — 5, 10 and 20, with selectable lengths, colours and width.
Bollinger Bands — 20 period, 2 standard deviations, with a narrow band flag that highlights the background when the market has compressed, which often precedes a move.
Trend panel — reads eight timeframes (1m, 5m, 15m, 30m, 1H, 4H, D, W) across three columns: Trend (EMA 5 vs 20), Stack (whether the 5, 10 and 20 sit in clean order or are tangled), and Ride (whether the 1m and 5m are running along their upper band and sitting inside a higher timeframe structure). Summary rows show confluence across timeframe groups and the current run-in state.
Run-in signals — the indicator's main signal. A run-in fires when a lower timeframe's moving average crosses into the band formed by a higher timeframe's own EMA structure. Markers appear below the bar, colour-coded and sized by which structure was hit — 4H, daily or weekly — and brighten when a second lower timeframe joins the move while the first is still riding. This escalation is the part worth watching, since the 1 and 5 minute charts rarely arrive at a structure at the same moment.
How to read it

Trend first, to know which direction you are looking for. Structure second, to see whether the timeframes agree. Supply and demand third, to find where a move would draw its power. Day levels fourth, to know whether price is inside or outside yesterday's range. The run-in markers last, as the moment the lower timeframes reach the higher structure. The highest-quality setup is a run-in arrow firing while both timeframes are in a band ride with their stacks in order, price arriving into an unused zone that agrees with the trend.

Notes

All signals confirm on closed candles, so a state can appear on the forming bar and change when it closes. This is intentional and prevents signals flickering.
The timezone defaults to UTC-4. Every session window and day level follows this setting, so change it only if your day boundaries genuinely shift.
Lower-timeframe reads (1m and 5m) are skipped on charts of 15 minutes and above, since those timeframes cannot be read reliably from a slower chart.
The trend structure uses EMAs rather than SMAs, which makes the reads slightly faster than an SMA-based equivalent.
Settings

Everything has a switch, so the chart can be simplified without removing the indicator. Times, colours, EMA lengths, zone sensitivity, day-level window, band ride threshold and panel position are all adjustable from the settings window.

Two notes on the credits, since you're publishing under your own name.

The wording makes clear these are influences you learned from, not collaborators — "independent implementation", "not affiliated with, endorsed by, or published by". That's the accurate framing and it protects you if either channel ever sees it.

One thing I'd flag: I couldn't verify the exact names both channels trade under or their preferred attribution format. If either posts a specific credit line they ask people to use, tell me and I'll match it.




dont credit


Here's the description with the credits removed. Paste this into the TradingView publish page.

J_MO Time Based Areas UTC-4

An all-in-one scalping overlay for index futures: custom session windows, EMA trend structure, supply and demand zones, previous day high/low levels, Bollinger Bands, and a multi-timeframe trend panel that flags when lower timeframes run into higher timeframe structure.

Built for the 1, 5 and 15 minute charts, and designed to be read in a fixed order so the parts reinforce each other rather than compete for attention.

What it draws

Six custom session windows — each shaded in its own colour, each with its own on/off switch and time range. Only candles inside a shaded window are eligible to form a zone, so the sessions do double duty: they show you where you are in the day, and they filter out quiet periods from zone detection.
Supply and demand zones — built from a base candle and a strong push candle that closes beyond the whole base. Red base before a move up makes demand; green base before a move down makes supply. Zones are detected on the 1, 5 and 15 minute timeframes, labelled by timeframe and type, and removed automatically once price touches them so only unused levels stay on the chart.
Previous day levels — HOD, LOD, PHOD and PLOD, each measured inside the 01:00 to 15:14 UTC-4 window. The current day's pair draws in full colour and the older pair sits behind it, faded and dashed, with each line named at its right end.
Three EMAs — 5, 10 and 20, with selectable lengths, colours and width.
Bollinger Bands — 20 period, 2 standard deviations, with a narrow band flag that highlights the background when the market has compressed, which often precedes a move.
Trend panel — reads eight timeframes (1m, 5m, 15m, 30m, 1H, 4H, D, W) across three columns: Trend (EMA 5 vs 20), Stack (whether the 5, 10 and 20 sit in clean order or are tangled), and Ride (whether the 1m and 5m are running along their upper band and sitting inside a higher timeframe structure). Summary rows show confluence across timeframe groups and the current run-in state.
Run-in signals — the indicator's main signal. A run-in fires when a lower timeframe's moving average crosses into the band formed by a higher timeframe's own EMA structure. Markers appear below the bar, colour-coded and sized by which structure was hit — 4H, daily or weekly — and brighten when a second lower timeframe joins the move while the first is still riding. This escalation is the part worth watching, since the 1 and 5 minute charts rarely arrive at a structure at the same moment.
How to read it

Trend first, to know which direction you are looking for. Structure second, to see whether the timeframes agree. Supply and demand third, to find where a move would draw its power. Day levels fourth, to know whether price is inside or outside yesterday's range. The run-in markers last, as the moment the lower timeframes reach the higher structure. The highest-quality setup is a run-in arrow firing while both timeframes are in a band ride with their stacks in order, price arriving into an unused zone that agrees with the trend.

Notes

All signals confirm on closed candles, so a state can appear on the forming bar and change when it closes. This is intentional and prevents signals flickering.
The timezone defaults to UTC-4. Every session window and day level follows this setting, so change it only if your day boundaries genuinely shift.
Lower-timeframe reads (1m and 5m) are skipped on charts of 15 minutes and above, since those timeframes cannot be read reliably from a slower chart.
The trend structure uses EMAs rather than SMAs, which makes the reads slightly faster than an SMA-based equivalent.
Settings

Everything has a switch, so the chart can be simplified without removing the indicator. Times, colours, EMA lengths, zone sensitivity, day-level window, band ride threshold and panel position are all adjustable from the settings window.

## Source Code

````pine
//@version=6
indicator("J_MO Time Based Areas UTC-4", overlay = true, scale = scale.right, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ───────── Timezone ─────────
tz = input.string("GMT-4", "Timezone", options = ["GMT-4", "America/New_York", "GMT-5", "UTC"])
showStartLine = input.bool(false, "Draw vertical line at each session start")

// ───────── Session inputs ─────────
grp1 = "Session 1"
s1On  = input.bool(true, "Show Session 1", group = grp1)
s1    = input.session("0100-0245", "Time", group = grp1)
s1Col = input.color(color.new(#b05fb0, 60), "Color", group = grp1)

grp2 = "Session 2"
s2On  = input.bool(true, "Show Session 2", group = grp2)
s2    = input.session("0300-0600", "Time", group = grp2)
s2Col = input.color(color.new(#8b2c2c, 60), "Color", group = grp2)

grp3 = "Session 3"
s3On  = input.bool(true, "Show Session 3", group = grp3)
s3    = input.session("0600-0815", "Time", group = grp3)
s3Col = input.color(color.new(#3cb043, 60), "Color", group = grp3)

grp4 = "Session 4"
s4On  = input.bool(true, "Show Session 4", group = grp4)
s4    = input.session("0900-1030", "Time", group = grp4)
s4Col = input.color(color.new(#d4c94a, 60), "Color", group = grp4)

grp5 = "Session 5"
s5On  = input.bool(true, "Show Session 5", group = grp5)
s5    = input.session("1000-1315", "Time", group = grp5)
s5Col = input.color(color.new(#c98a5e, 60), "Color", group = grp5)

grp6 = "Session 6"
s6On  = input.bool(true, "Show Session 6", group = grp6)
s6    = input.session("1830-2100", "Time", group = grp6)
s6Col = input.color(color.new(#2ec4c4, 60), "Color", group = grp6)

// ───────── EMA inputs ─────────
grpE = "EMAs"
emaSrc = input.source(close, "EMA Source", group = grpE)
e1On  = input.bool(true, "EMA 1", group = grpE, inline = "e1")
e1Len = input.int(5, "", minval = 1, group = grpE, inline = "e1")
e1Col = input.color(color.red, "", group = grpE, inline = "e1")
e2On  = input.bool(true, "EMA 2", group = grpE, inline = "e2")
e2Len = input.int(10, "", minval = 1, group = grpE, inline = "e2")
e2Col = input.color(color.white, "", group = grpE, inline = "e2")
e3On  = input.bool(true, "EMA 3", group = grpE, inline = "e3")
e3Len = input.int(20, "", minval = 1, group = grpE, inline = "e3")
e3Col = input.color(color.blue, "", group = grpE, inline = "e3")
emaWidth = input.int(2, "Line Width", minval = 1, maxval = 4, group = grpE)

// ───────── Supply / Demand inputs ─────────
grpSD = "Supply & Demand Zones"
drawMode   = input.string("Line", "Draw As", options = ["Line", "Box", "Both"], group = grpSD)
pushMult   = input.float(1.5, "Push Strength (x avg body)", minval = 0.5, step = 0.1, group = grpSD)
lookBack   = input.int(10, "Lookback (candles)", minval = 1, maxval = 30, group = grpSD)
sdWidth    = input.int(1, "Line Width", minval = 1, maxval = 4, group = grpSD)
delTouched = input.bool(true, "Remove zone once touched", group = grpSD)

m1On  = input.bool(true, "1m", group = grpSD, inline = "m1")
m1Max = input.int(4, "Max", minval = 1, maxval = 30, group = grpSD, inline = "m1")
m1Col = input.color(#1e3a8a, "", group = grpSD, inline = "m1")

m5On  = input.bool(true, "5m", group = grpSD, inline = "m5")
m5Max = input.int(4, "Max", minval = 1, maxval = 30, group = grpSD, inline = "m5")
m5Col = input.color(#2563eb, "", group = grpSD, inline = "m5")

m15On  = input.bool(true, "15m", group = grpSD, inline = "m15")
m15Max = input.int(4, "Max", minval = 1, maxval = 30, group = grpSD, inline = "m15")
m15Col = input.color(#7c3aed, "", group = grpSD, inline = "m15")

// ───────── Bollinger Band inputs ─────────
grpBB = "Bollinger Bands"
bbOn    = input.bool(true, "Show Bands", group = grpBB)
bbLen   = input.int(20, "Length", minval = 2, group = grpBB)
bbMult  = input.float(2.0, "Std Dev", minval = 0.5, step = 0.1, group = grpBB)
bbCol   = input.color(#8a8a8a, "Band Color", group = grpBB)
bbNarrowOn  = input.bool(true, "Flag Narrow Band", group = grpBB)
bbNarrowPct = input.float(30, "Narrow = width below this % of its 100-bar average", minval = 5, maxval = 90, group = grpBB)
bbNarrowCol = input.color(#ffcc00, "Narrow Flag Color", group = grpBB)

// ───────── High / Low of Day inputs ─────────
grpPD = "High / Low of Day"
rangeSess  = input.session("0100-1514", "Range Window (UTC-4)", group = grpPD)
hodOn      = input.bool(true, "Show HOD / LOD (1 day back)", group = grpPD)
phodOn     = input.bool(true, "Show PHOD / PLOD (2 days back)", group = grpPD)
pdHCol     = input.color(color.red, "High Color", group = grpPD)
pdLCol     = input.color(color.lime, "Low Color", group = grpPD)
pdWidth    = input.int(2, "Line Width", minval = 1, maxval = 4, group = grpPD)
phodStyle  = input.string("Dashed", "PHOD / PLOD Style", options = ["Solid", "Dashed", "Dotted"], group = grpPD)
phodTransp = input.int(40, "PHOD / PLOD Transparency", minval = 0, maxval = 90, group = grpPD)
showDayLbl = input.bool(true, "Show Line Names", group = grpPD)

// ───────── Higher Timeframe Structure inputs ─────────
grpHT = "HTF Structure"
htfFast = input.int(5,  "HTF Fast EMA", minval = 1, group = grpHT)
htfSlow = input.int(20, "HTF Slow EMA", minval = 1, group = grpHT)
htf4Col = input.color(#4a90d9, "4H Color", group = grpHT)
htfDCol = input.color(#d9a84a, "Daily Color", group = grpHT)
htfWCol = input.color(#a44ad9, "Weekly Color", group = grpHT)

// ───────── Run-In Signal inputs ─────────
grpRI = "Run-In Signals"
riOn     = input.bool(true, "Show Run-In Markers", group = grpRI)
riUseTF  = input.bool(true, "Only chart timeframe and above", group = grpRI)
ri4On    = input.bool(true, "Signal into 4H", group = grpRI)
riDOn    = input.bool(true, "Signal into Daily", group = grpRI)
riWOn    = input.bool(true, "Signal into Weekly", group = grpRI)

// ───────── Band Ride inputs ─────────
grpBR = "Band Ride"
brBars    = input.int(3, "Closes above band to count as riding", minval = 1, maxval = 20, group = grpBR)
brUseStack = input.bool(true, "Also require EMA stack (5>10>20)", group = grpBR)
br1On     = input.bool(true, "Track 1m", group = grpBR)
br5On     = input.bool(true, "Track 5m", group = grpBR)
brHiCol   = input.color(color.lime, "Riding + Arrived Color", group = grpBR)
brMidCol  = input.color(#ffcc00, "Riding, Not Arrived Color", group = grpBR)
brLowCol  = input.color(color.gray, "Arrived, Not Riding Color", group = grpBR)

// ───────── Trend Panel inputs ─────────
grpTP = "Trend Panel"
tpOn    = input.bool(true, "Show Trend Panel", group = grpTP)
tpFast  = input.int(5,  "Fast EMA", minval = 1, group = grpTP)
tpMid   = input.int(10, "Mid EMA",  minval = 1, group = grpTP)
tpSlow  = input.int(20, "Slow EMA", minval = 1, group = grpTP)
tpPos   = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = grpTP)
tpText  = input.int(10, "Text Size", minval = 8, maxval = 20, group = grpTP)

// ───────── Session helpers ─────────
inSess(string sess) =>
    not na(time(timeframe.period, sess, tz))

sessStart(string sess) =>
    inSess(sess) and not inSess(sess)[1]

// A candle only counts as a base candle if it sits inside one of the enabled sessions.
inAnySession() =>
    (s1On and inSess(s1)) or (s2On and inSess(s2)) or (s3On and inSess(s3)) or (s4On and inSess(s4)) or (s5On and inSess(s5)) or (s6On and inSess(s6))

// ───────── Shading ─────────
color bg = na
bg := s1On and inSess(s1) ? s1Col : bg
bg := s2On and inSess(s2) ? s2Col : bg
bg := s3On and inSess(s3) ? s3Col : bg
bg := s4On and inSess(s4) ? s4Col : bg
bg := s5On and inSess(s5) ? s5Col : bg
bg := s6On and inSess(s6) ? s6Col : bg
bgcolor(bg)

drawStart(bool on, string sess, color c) =>
    if showStartLine and on and sessStart(sess)
        line.new(bar_index, low, bar_index, high, extend = extend.both, color = color.new(c, 0), width = 1)

drawStart(s1On, s1, s1Col)
drawStart(s2On, s2, s2Col)
drawStart(s3On, s3, s3Col)
drawStart(s4On, s4, s4Col)
drawStart(s5On, s5, s5Col)
drawStart(s6On, s6, s6Col)

// ───────── EMAs ─────────
plot(e1On ? ta.ema(emaSrc, e1Len) : na, "EMA 5",  color = e1Col, linewidth = emaWidth)
plot(e2On ? ta.ema(emaSrc, e2Len) : na, "EMA 10", color = e2Col, linewidth = emaWidth)
plot(e3On ? ta.ema(emaSrc, e3Len) : na, "EMA 20", color = e3Col, linewidth = emaWidth)

// ───────── Bollinger Bands (chart timeframe) ─────────
[bbMid, bbUp, bbLo] = ta.bb(close, bbLen, bbMult)
bbAvgW = ta.sma(bbUp - bbLo, 100)
bbWidthPct = not na(bbAvgW) and bbAvgW > 0 ? (bbUp - bbLo) / bbAvgW * 100 : na
bbNarrow = bbNarrowOn and not na(bbWidthPct) and bbWidthPct < bbNarrowPct

plot(bbOn ? bbUp : na, "BB Upper", color = bbCol, linewidth = 1)
plot(bbOn ? bbLo : na, "BB Lower", color = bbCol, linewidth = 1)
plot(bbOn ? bbMid : na, "BB Basis", color = color.new(bbCol, 50), linewidth = 1)
bgcolor(bbNarrow and bbOn ? color.new(bbNarrowCol, 88) : na, title = "Narrow Band")

// ───────── HTF structure bands (where the higher-timeframe EMAs sit) ─────────
[f4, s4v] = request.security(syminfo.tickerid, "240", [ta.ema(close, htfFast), ta.ema(close, htfSlow)])
[fD, sDv] = request.security(syminfo.tickerid, "D",   [ta.ema(close, htfFast), ta.ema(close, htfSlow)])
[fW, sWv] = request.security(syminfo.tickerid, "W",   [ta.ema(close, htfFast), ta.ema(close, htfSlow)])

htfTop4 = math.max(f4, s4v)
htfBot4 = math.min(f4, s4v)
htfTopD = math.max(fD, sDv)
htfBotD = math.min(fD, sDv)
htfTopW = math.max(fW, sWv)
htfBotW = math.min(fW, sWv)

// ── Combined per-timeframe read ──
lowerRead(string tf, float top4, float bot4, float topD, float botD, float topW, float botW) =>
    fast    = ta.ema(close, tpFast)
    mid     = ta.ema(close, tpMid)
    slow    = ta.ema(close, tpSlow)
    [bbBasisL, bbUpL, bbLoL] = ta.bb(close, bbLen, bbMult)
    upBand  = bbUpL
    above   = close > upBand
    riding  = ta.barssince(not above) >= brBars
    stacked = fast > mid and mid > slow
    ri4 = (fast <= top4 and fast >= bot4) or (slow <= top4 and slow >= bot4)
    riD = (fast <= topD and fast >= botD) or (slow <= topD and slow >= botD)
    riW = (fast <= topW and fast >= botW) or (slow <= topW and slow >= botW)
    ri4e = ri4 and not ri4[1]
    riDe = riD and not riD[1]
    riWe = riW and not riW[1]
    [fast, mid, slow, riding, stacked, ri4e, riDe, riWe, ri4, riD, riW]

[l1f, l1m, l1s, l1Ride, l1Stack, l1e4, l1eD, l1eW, l1in4, l1inD, l1inW] = lowerRead("1", htfTop4, htfBot4, htfTopD, htfBotD, htfTopW, htfBotW)
[l5f, l5m, l5s, l5Ride, l5Stack, l5e4, l5eD, l5eW, l5in4, l5inD, l5inW] = lowerRead("5", htfTop4, htfBot4, htfTopD, htfBotD, htfTopW, htfBotW)

chartSecRI = timeframe.in_seconds()
riOk1 = not riUseTF or 60  >= chartSecRI
riOk5 = not riUseTF or 300 >= chartSecRI

ride1 = br1On and l1Ride and (not brUseStack or l1Stack)
ride5 = br5On and l5Ride and (not brUseStack or l5Stack)

arr1_4 = riOk1 and l1e4
arr1_D = riOk1 and l1eD
arr1_W = riOk1 and l1eW
arr5_4 = riOk5 and l5e4
arr5_D = riOk5 and l5eD
arr5_W = riOk5 and l5eW

sig4 = ri4On and (arr1_4 or arr5_4)
sigD = riDOn and (arr1_D or arr5_D)
sigW = riWOn and (arr1_W or arr5_W)

esc4 = sig4 and ((arr1_4 and ride5) or (arr5_4 and ride1))
escD = sigD and ((arr1_D and ride5) or (arr5_D and ride1))
escW = sigW and ((arr1_W and ride5) or (arr5_W and ride1))

plotshape(riOn and sig4, "Run-In 4H", shape.triangleup, location.belowbar, color.new(htf4Col, esc4 ? 0 : 60), size = size.small)
plotshape(riOn and sigD, "Run-In D",  shape.triangleup, location.belowbar, color.new(htfDCol, escD ? 0 : 60), size = size.normal)
plotshape(riOn and sigW, "Run-In W",  shape.triangleup, location.belowbar, color.new(htfWCol, escW ? 0 : 60), size = size.large)

// ───────── Supply / Demand zones ─────────
labelOffset() =>
    time + 8 * timeframe.in_seconds() * 1000

type Zone
    float top
    float bot
    bool  dem
    line  ln
    box   bx
    label lb

addZone(array<Zone> arr, float top, float bot, bool dem, int t, color c, string txt, int maxN) =>
    price = dem ? top : bot
    line ln = na
    box  bx = na
    if drawMode != "Box"
        ln := line.new(t, price, t + 1, price, xloc = xloc.bar_time, extend = extend.right, color = c, width = sdWidth)
    if drawMode != "Line"
        bx := box.new(t, top, t + 1, bot, xloc = xloc.bar_time, extend = extend.right, border_color = c, bgcolor = color.new(c, 85))
    lb = label.new(labelOffset(), price, txt, xloc = xloc.bar_time, style = label.style_none, textcolor = c, size = size.small)
    arr.push(Zone.new(top, bot, dem, ln, bx, lb))
    if arr.size() > maxN
        old = arr.shift()
        line.delete(old.ln)
        box.delete(old.bx)
        label.delete(old.lb)

checkTouch(array<Zone> arr) =>
    if delTouched and arr.size() > 0
        for i = arr.size() - 1 to 0
            z = arr.get(i)
            hit = z.dem ? low <= z.top : high >= z.bot
            if hit
                line.delete(z.ln)
                box.delete(z.bx)
                label.delete(z.lb)
                arr.remove(i)

moveLabels(array<Zone> arr) =>
    for z in arr
        label.set_x(z.lb, labelOffset())

nearestDemand(array<Zone> arr) =>
    float best = na
    if arr.size() > 0
        for z in arr
            if z.dem and z.top < close and (na(best) or z.top > best)
                best := z.top
    best

nearestSupply(array<Zone> arr) =>
    float best = na
    if arr.size() > 0
        for z in arr
            if not z.dem and z.bot > close and (na(best) or z.bot < best)
                best := z.bot
    best

// ── Zone detection ──
zoneData(float mult, int back) =>
    body   = math.abs(close - open)
    avgB   = ta.sma(body, 20)
    strong = body[1] >= mult * avgB[1]

    float dTop = na
    float dBot = na
    int   dIdx = na
    float uTop = na
    float uBot = na
    int   uIdx = na

    for i = 0 to back - 1
        b = i + 2

        if na(dIdx) and close[b] < open[b] and inAnySession()[b]
            sameColour = (close[b + 1] < open[b + 1]) or (close[b - 1] < open[b - 1])
            if not sameColour
                dTop := high[b]
                dBot := low[b]
                dIdx := b

        if na(uIdx) and close[b] > open[b] and inAnySession()[b]
            sameColour = (close[b + 1] > open[b + 1]) or (close[b - 1] > open[b - 1])
            if not sameColour
                uTop := high[b]
                uBot := low[b]
                uIdx := b

    dem = false
    sup = false

    if strong and close[1] > open[1] and not na(dIdx) and close[1] > high[dIdx]
        dem := true

    if strong and close[1] < open[1] and not na(uIdx) and close[1] < low[uIdx]
        sup := true

    [dem, sup, dIdx, uIdx, dTop, dBot, uTop, uBot]

[d1, u1, b1D, b1U, d1Top, d1Bot, u1Top, u1Bot]         = request.security(syminfo.tickerid, "1",  zoneData(pushMult, lookBack))
[d5, u5, b5D, b5U, d5Top, d5Bot, u5Top, u5Bot]         = request.security(syminfo.tickerid, "5",  zoneData(pushMult, lookBack))
[d15, u15, b15D, b15U, d15Top, d15Bot, u15Top, u15Bot] = request.security(syminfo.tickerid, "15", zoneData(pushMult, lookBack))

zoneTime(int barsBack) =>
    time[barsBack]

chartSec = timeframe.in_seconds()
ok1  = m1On  and 60  >= chartSec
ok5  = m5On  and 300 >= chartSec
ok15 = m15On and 900 >= chartSec

var array<Zone> z1  = array.new<Zone>()
var array<Zone> z5  = array.new<Zone>()
var array<Zone> z15 = array.new<Zone>()
var int last1 = na
var int last5 = na
var int last15 = na

checkTouch(z1)
checkTouch(z5)
checkTouch(z15)

if ok1 and d1
    t = zoneTime(b1D)
    if t != last1
        addZone(z1, d1Top, d1Bot, true, t, m1Col, "1m D", m1Max)
        last1 := t
if ok1 and u1
    t = zoneTime(b1U)
    if t != last1
        addZone(z1, u1Top, u1Bot, false, t, m1Col, "1m S", m1Max)
        last1 := t

if ok5 and d5
    t = zoneTime(b5D)
    if t != last5
        addZone(z5, d5Top, d5Bot, true, t, m5Col, "5m D", m5Max)
        last5 := t
if ok5 and u5
    t = zoneTime(b5U)
    if t != last5
        addZone(z5, u5Top, u5Bot, false, t, m5Col, "5m S", m5Max)
        last5 := t

if ok15 and d15
    t = zoneTime(b15D)
    if t != last15
        addZone(z15, d15Top, d15Bot, true, t, m15Col, "15m D", m15Max)
        last15 := t
if ok15 and u15
    t = zoneTime(b15U)
    if t != last15
        addZone(z15, u15Top, u15Bot, false, t, m15Col, "15m S", m15Max)
        last15 := t

if barstate.islast
    moveLabels(z1)
    moveLabels(z5)
    moveLabels(z15)

// ───────── High / Low of Day (01:00 → 15:14 UTC-4) ─────────
var float curH = na
var float curL = na
var float hod  = na
var float lod  = na
var float phod = na
var float plod = na
var int dayStart = na

newDay = dayofweek(time, tz) != dayofweek(time[1], tz)

if inSess(rangeSess) and na(dayStart)
    dayStart := time

if newDay
    if not na(curH)
        phod := hod
        plod := lod
        hod  := curH
        lod  := curL
    curH := na
    curL := na
    dayStart := na

if inSess(rangeSess)
    curH := na(curH) ? high : math.max(curH, high)
    curL := na(curL) ? low  : math.min(curL, low)

phodStyleVal = phodStyle == "Dashed" ? line.style_dashed : phodStyle == "Dotted" ? line.style_dotted : line.style_solid

var line lnHod  = na
var line lnLod  = na
var line lnPhod = na
var line lnPlod = na
var label lbHod  = na
var label lbLod  = na
var label lbPhod = na
var label lbPlod = na

if barstate.islast and not na(hod) and not na(dayStart)
    line.delete(lnHod)
    line.delete(lnLod)
    line.delete(lnPhod)
    line.delete(lnPlod)
    label.delete(lbHod)
    label.delete(lbLod)
    label.delete(lbPhod)
    label.delete(lbPlod)

    x2 = time + 4 * timeframe.in_seconds() * 1000

    if hodOn
        lnHod := line.new(dayStart, hod, x2, hod, xloc = xloc.bar_time, color = pdHCol, width = pdWidth)
        lnLod := line.new(dayStart, lod, x2, lod, xloc = xloc.bar_time, color = pdLCol, width = pdWidth)
        if showDayLbl
            lbHod := label.new(x2, hod, "HOD", xloc = xloc.bar_time, style = label.style_none, textcolor = pdHCol, size = size.small)
            lbLod := label.new(x2, lod, "LOD", xloc = xloc.bar_time, style = label.style_none, textcolor = pdLCol, size = size.small)
    if phodOn and not na(phod)
        lnPhod := line.new(dayStart, phod, x2, phod, xloc = xloc.bar_time, color = color.new(pdHCol, phodTransp), width = pdWidth, style = phodStyleVal)
        lnPlod := line.new(dayStart, plod, x2, plod, xloc = xloc.bar_time, color = color.new(pdLCol, phodTransp), width = pdWidth, style = phodStyleVal)
        if showDayLbl
            lbPhod := label.new(x2, phod, "PHOD", xloc = xloc.bar_time, style = label.style_none, textcolor = color.new(pdHCol, phodTransp), size = size.small)
            lbPlod := label.new(x2, plod, "PLOD", xloc = xloc.bar_time, style = label.style_none, textcolor = color.new(pdLCol, phodTransp), size = size.small)

// ───────── Trend Panel ─────────
tfRead(string tf) =>
    [f, m, s] = request.security(syminfo.tickerid, tf, [ta.ema(close, tpFast), ta.ema(close, tpMid), ta.ema(close, tpSlow)])
    trendUp = f > s
    stackUp = f > m and m > s
    stackDn = f < m and m < s
    [trendUp, stackUp, stackDn]

[tr15, st15, sd15] = tfRead("15")
[tr30, st30, sd30] = tfRead("30")
[tr60, st60, sd60] = tfRead("60")
[tr240,st240,sd240]= tfRead("240")
[trD,  stD,  sdD]  = tfRead("D")
[trW,  stW,  sdW]  = tfRead("W")

tr1  = l1f > l1s
tr5  = l5f > l5s
st1  = l1Stack
st5  = l5Stack
sd1  = l1f < l1m and l1m < l1s
sd5  = l5f < l5m and l5m < l5s

tpPosVal = tpPos == "Top Left" ? position.top_left : tpPos == "Bottom Right" ? position.bottom_right : tpPos == "Bottom Left" ? position.bottom_left : tpPos == "Middle Right" ? position.middle_right : position.top_right

stackText(bool up, bool dn) =>
    up ? "Stacked Up" : dn ? "Stacked Dn" : "Tangled"

stackCol(bool up, bool dn) =>
    up ? color.lime : dn ? color.red : color.gray

rideText(bool riding, bool in4, bool inD, bool inW) =>
    arrived = in4 or inD or inW
    riding and arrived ? "RIDE + IN" : riding ? "Riding" : arrived ? "In Structure" : "-"

rideCol(bool riding, bool in4, bool inD, bool inW) =>
    arrived = in4 or inD or inW
    riding and arrived ? brHiCol : riding ? brMidCol : arrived ? brLowCol : color.gray

cnt = 0
cnt := ride1 and (l1in4 or l1inD or l1inW) ? cnt + 1 : cnt
cnt := ride5 and (l5in4 or l5inD or l5inW) ? cnt + 1 : cnt

var table tp = na
if barstate.islast and tpOn
    table.delete(tp)
    tp := table.new(tpPosVal, 4, 11, border_width = 1, border_color = color.new(color.gray, 60), frame_width = 1, frame_color = color.new(color.gray, 40))
    table.cell(tp, 0, 0, "TF",     text_color = color.white, text_size = tpText, bgcolor = color.new(color.gray, 70))
    table.cell(tp, 1, 0, "Trend",  text_color = color.white, text_size = tpText, bgcolor = color.new(color.gray, 70))
    table.cell(tp, 2, 0, "Stack",  text_color = color.white, text_size = tpText, bgcolor = color.new(color.gray, 70))
    table.cell(tp, 3, 0, "Ride",   text_color = color.white, text_size = tpText, bgcolor = color.new(color.gray, 70))

    table.cell(tp, 0, 1, "1m", text_color = color.white, text_size = tpText, bgcolor = color.new(color.gray, 80))
    table.cell(tp, 1, 1, tr1 ? "Up" : "Down", text_color = tr1 ? color.lime : color.red, text_size = tpText, bgcolor = color.new(color.gray, 80))
    table.cell(tp, 2, 1, stackText(st1, sd1), text_color = stackCol(st1, sd1), text_size = tpText, bgcolor = color.new(color.gray, 80))
    table.cell(tp, 3, 1, rideText(ride1, l1in4, l1inD, l1inW), text_color = rideCol(ride1, l1in4, l1inD, l1inW), text_size = tpText, bgcolor = color.new(color.gray, 80))

    table.cell(tp, 0, 2, "5m", text_color = color.white, text_size = tpText, bgcolor = color.new(color.gray, 80))
    table.cell(tp, 1, 2, tr5 ? "Up" : "Down", text_color = tr5 ? color.lime : color.red, text_size = tpText, bgcolor = color.new(color.gray, 80))
    table.cell(tp, 2, 2, stackText(st5, sd5), text_color = stackCol(st5, sd5), text_size = tpText, bgcolor = color.new(color.gray, 80))
    table.cell(tp, 3, 2, rideText(ride5, l5in4, l5inD, l5inW), text_color = rideCol(ride5, l5in4, l5inD, l5inW), text_size = tpText, bgcolor = color.new(color.gray, 80))

    tfs = array.from("15m", "30m", "1H", "4H", "D", "W")
    trs = array.from(tr15, tr30, tr60, tr240, trD, trW)
    sts = array.from(st15, st30, st60, st240, stD, stW)
    sds = array.from(sd15, sd30, sd60, sd240, sdD, sdW)
    for i = 0 to 5
        t = trs.get(i)
        u = sts.get(i)
        d = sds.get(i)
        table.cell(tp, 0, i + 3, tfs.get(i), text_color = color.white, text_size = tpText, bgcolor = color.new(color.gray, 80))
        table.cell(tp, 1, i + 3, t ? "Up" : "Down", text_color = t ? color.lime : color.red, text_size = tpText, bgcolor = color.new(color.gray, 80))
        table.cell(tp, 2, i + 3, stackText(u, d), text_color = stackCol(u, d), text_size = tpText, bgcolor = color.new(color.gray, 80))
        table.cell(tp, 3, i + 3, "", text_color = color.white, text_size = tpText, bgcolor = color.new(color.gray, 80))

    riNowTxt = sigW ? "Weekly" : sigD ? "Daily" : sig4 ? "4H" : "None"
    riNowCol = sigW ? color.new(htfWCol, 0) : sigD ? color.new(htfDCol, 0) : sig4 ? color.new(htf4Col, 0) : color.gray
    rideNowTxt = str.tostring(cnt) + "/2 riding + in"
    rideNowCol = cnt == 2 ? brHiCol : cnt == 1 ? brMidCol : brLowCol

    table.cell(tp, 0, 9, "Run-In", text_color = color.white, text_size = tpText, bgcolor = color.new(color.gray, 70))
    table.cell(tp, 1, 9, riNowTxt, text_color = riNowCol, text_size = tpText, bgcolor = color.new(color.gray, 80))
    table.cell(tp, 2, 9, rideNowTxt, text_color = rideNowCol, text_size = tpText, bgcolor = color.new(color.gray, 80))
    table.cell(tp, 3, 9, cnt == 2 ? "Power Move" : "", text_color = cnt == 2 ? brHiCol : color.gray, text_size = tpText, bgcolor = color.new(color.gray, 80))
````
