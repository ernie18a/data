# Kyoka Suigetsu - Range Clock & Weekday / Hour / Month Profiles

- url: https://www.tradingview.com/script/EYixazNJ-Kyoka-Suigetsu-Range-Clock-Weekday-Hour-Month-Profiles/
- type: indicator
- pine_id: PUB;d8ce9be460674b96a62bb1af68f3c2ac
- version: 5.0

## Description

[image]https://www.tradingview.com/x/118Plkd3/[/image][image]https://www.tradingview.com/x/3nQlfhyj/[/image][b]KYOKA SUIGETSU[/b]
[i] "Mirror Flower, Water Moon"[/i]

Named after Sosuke Aizen's zanpakuto, whose complete hypnosis controls everything its victims perceive. This indicator works the other way round. It shows what is actually typical for this hour, this weekday and this month, so the day you think you're seeing can be checked against the days that really happened.

It's a context map, not a signal generator. It tells you where today sits against its own history; what you do with that is your call.


[b]WHAT IT SHOWS[/b]

[b]Range clock[/b]
- Today's running range, or its net move from the 18:00 ET open, plotted live against the typical path for every hour of the trading day.
- The typical path is the median at the same time of day over the last N trading days, or the last N of today's weekday. Around it sit 25–75 and 10–90 bands.
- A [b]neutral zone[/b] hugs the median. It's the statistical uncertainty of the median itself, so it narrows as the sample grows. Today's line changes colour depending on whether it sits [b]above[/b], [b]inside[/b] or [b]below[/b] that zone.
- Underneath, on the same time axis: an hour-of-high / hour-of-low histogram and a session strip (Asia · London · NY AM · Lunch · NY PM).
- A live label shows today's value, its percentile, its status and what's typical by now. The end label shows the typical day in % and points, with P25 / P75.

[b]Distributions[/b]
- [b]Day of week:[/b] range or net move % for each weekday, every day as a dot (up days green, down days red, older days fading), an all-days column for comparison, and today marked .
- [b]Hour of high / low:[/b] which hour (ET) the trading day set its high and its low, for today's weekday or for all days.
- [b]Month of year:[/b] net move or range % for each calendar month, contract-roll gaps removed, every year as a dot, with the month to date marked.

[b]Cards[/b]
- [b]Status:[/b] range so far against typical with a percentile meter, daily ATR and how much of it is used, the typical day in points and how far is left, net move against typical, how often the current hour sets the day's high or low, month to date against that month's history, and today's weekday profile.
- [b]Weekdays[/b], [b]Months[/b] and [b]Hours[/b] reference cards.
- Each card can sit on the price chart or in the indicator pane, in any corner.


[b]HOW THE NUMBERS ARE BUILT[/b]
- [b]Full trading day only, 18:00–17:00 ET.[/b] There's no RTH split anywhere, and all times are worked out in New York time whatever your chart's timezone is.
- Everything is a % of the open, so years at very different price levels compare fairly. Points are shown alongside.
- Only completed days and months go into the samples. Today never counts toward its own baseline.
- Monthly points come from TradingView's back-adjusted series, so a contract roll doesn't add a fake gap. The % base comes from the unadjusted series, so the % reflects the price level at the time.
- ATR comes from completed daily bars on the back-adjusted series.


[b]BUILT FOR CONTINUOUS CONTRACTS![/b]

[b]Use it on NQ1!, ES1! and RTY1!.[/b] That's what it was made for.

A single contract month (NQZ2026, for example) only trades properly while it's the front month. Before and after that, its bars thin out as volume and open interest come and go, so any baseline built on it would be short and distorted. A continuous contract joins each front month onto the next, which gives the long, unbroken history the weekday, hour and month profiles need. The roll-gap removal also only works on continuous contracts.

[b]Get TradingView's CME real-time data add-on.[/b] Without it, CME data is delayed, so the live clock, the status card and the alerts all run behind the market. You won't regret it.

Also note:
- The Range clock needs an intraday chart of 60 minutes or lower. Distributions and cards work on any timeframe.
- The hour profile and the clock's baseline are built from 60-minute bars, so how far back they reach depends on how much bar history your plan gives you.


[b]USING IT[/b]
- [b]Pane:[/b] Range clock, Distributions, or Cards only.
- [b]Layout:[/b] Desktop or Mobile. Mobile uses compact cards and short labels with the numbers written into the text, because the app doesn't show tooltips.
- [b]Theme:[/b] Auto follows your chart background.
- [b]Baseline:[/b] last N days (the default) or same weekday.
- [b]Neutral zone:[/b] 68 / 80 / 90 / 95%. Wider means more days read as Neutral.
- [b]Typical path colour:[/b] left at the default it follows your chart's text colour; otherwise pick your own.
- [b]Cards:[/b] give each card its own corner. Cards at the top sit below the indicator title, and the gap is adjustable.
- [b]Alerts:[/b] create one alert using [i]"Any alert() function call"[/i] to get:
   – range moving above or below the neutral zone
   – the typical day's range being reached
   – 100% of ATR being used
   Each fires once per event per day.


[b]WORK IN PROGRESS[/b]
This is version one. More data is on the way: longer per-contract daily history with volume and open interest, ES and RTY intraday data, and the volatility indices. Kyoka Suigetsu will keep growing as each piece is tested and added, so expect updates.

One day this might arm the rest of us with the kind of equipment that can challenge a Bloomberg terminal. I'm only kidding… but with data and imagination, the sky's the limit.


[b]CREDITS[/b]
Distribution column layout inspired by [i]"Day Of Week Price Distribution"[/i] by LuxAlgo (CC BY-NC-SA 4.0). Written from scratch; no LuxAlgo code is used.

Open source under the Mozilla Public License 2.0. Use it, build on it, improve it.

## Source Code

````pine
//@version=6
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Unclehk2000
//
// Kyōka Suigetsu (鏡花水月 · "Mirror Flower, Water Moon")
// Named for Sōsuke Aizen's zanpakutō, whose complete hypnosis rules what you perceive. This one works the other way:
// it shows what is actually typical for this hour, weekday and month, so the day you think you are seeing can be
// checked against the days that really happened.
//
// Range clock — today's running range (or net move from the 18:00 open) drawn live against the typical path for each
//   hour of the trading day: median, 25–75 and 10–90 bands, and a neutral zone (the uncertainty of the median). Today's
//   line is coloured by where it sits: above, inside or below the neutral zone. Beneath it, the hour-of-high/low
//   histogram and the session strip share the same time axis.
// Distributions — weekday columns, hour-of-high/low profile and month-of-year seasonality, every day / year as a dot.
// Expected range — today's range forecast from the last 1, 5 and 22 days' ranges anchored to the past year, yesterday's
//   move, inside days, holidays, opex Friday and turn of month (fitted on NQ / ES / RTY 2010–2026), a live projection
//   that blends it with the range made so far, hour by hour, and the chance today's high / low is already in.
// Cards — status (range, ATR, expected and projected range, high / low in, net, hour, month, weekday), weekdays, months
//   and hours.
// Full trading day only (18:00–17:00 ET). Built for CME index futures on continuous charts (NQ1!, ES1!, RTY1!).
//
// Distribution column layout inspired by "Day Of Week Price Distribution" by LuxAlgo (CC BY-NC-SA 4.0).
// Written from scratch; no LuxAlgo code is used.

indicator("Kyōka Suigetsu", "Kyōka Suigetsu", overlay = false, max_labels_count = 500, max_boxes_count = 150, max_lines_count = 100, max_polylines_count = 20)

TZ   = "America/New_York"
HOUR = 3600000

// ═══════════════════════════════════════════════════════════════ Inputs
gV = "View"
view   = input.string("Range clock", "Pane", options = ["Range clock", "Distributions", "Cards only"], group = gV, tooltip = "Range clock: today's running range or net move against the typical path for this time of day. Distributions: weekday, hour and month columns with every day / year as a dot. Cards only: an empty pane that holds the cards.", display = display.none)
clkMet = input.string("Range", "Clock measure", options = ["Range", "Net move"], group = gV, display = display.none)
theme  = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = gV, tooltip = "Auto follows the chart background.", display = display.none)
layout = input.string("Desktop", "Layout", options = ["Desktop", "Mobile"], group = gV, tooltip = "Mobile: compact cards, one distribution block at a time, short labels with the numbers in the text (the mobile app doesn't show tooltips).", display = display.none)

gK = "Range clock"
kBands = input.bool(true, "25–75 and 10–90 bands", group = gK, display = display.none)
colMed = input.color(#000001, "Typical path colour", group = gK, tooltip = "Colour of the typical (median) path and its end label. Left at the default it follows the chart's text colour, so it shows on light and dark charts alike; pick any colour to override.", display = display.none)
kPast  = input.bool(true, "Earlier days' paths, faded", group = gK, display = display.none)
kHist  = input.bool(true, "Hour-of-high/low histogram", group = gK, display = display.none)
kSess  = input.bool(true, "Session strip (Asia · London · NY AM · Lunch · NY PM)", group = gK, display = display.none)
kLbl   = input.bool(true, "Labels", group = gK, display = display.none)

gS = "Status card"
showDash = input.bool(true, "Status card", group = gS, inline = "s1", tooltip = "Each card needs its own position on its surface; two cards in the same spot replace each other. On the Mobile layout, centre positions move to the right-hand corner because phone panes are too narrow for a centre card.", display = display.none)
dashOn   = input.string("Price chart", "", options = ["Price chart", "Indicator pane"], group = gS, inline = "s1", display = display.none)
dashPos  = input.string("Top right", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = gS, inline = "s1", display = display.none)
dashSzI  = input.string("Small", "Text", options = ["Tiny", "Small", "Normal"], group = gS, display = display.none)
atrLen   = input.int(14, "ATR length (days)", minval = 2, maxval = 100, group = gS, tooltip = "Daily ATR from completed days, back-adjusted so a contract roll doesn't count as a true range.", display = display.none)
byBase   = input.string("Last N days", "Baseline", options = ["Last N days", "Same weekday"], group = gS, tooltip = "The typical path, bands and statuses come from the same time of day on the last N trading days, or on the last N of today's weekday (N = Days in profile). On NQ 2018–2026 the last-N-days baseline sorted the rest of the day slightly better, so it is the default.", display = display.none)
bandCI   = input.string("80%", "Neutral zone", options = ["68%", "80%", "90%", "95%"], group = gS, tooltip = "Neutral = inside this confidence band around the median at the same time of day. The band is the uncertainty of the median itself, so it narrows as the sample grows. Wider = more days read Neutral.", display = display.none)

gX = "Expected range"
xOn    = input.bool(true, "Expected range and live projection", group = gX, tooltip = "Expected: today's range forecast from the last 1, 5 and 22 days' ranges anchored to the past year, yesterday's move, inside days, holidays, opex Friday and turn of month. Walk-forward 2013–2026 it beat the median of the last 30 days in 13/14 (NQ), 14/14 (ES) and 13/14 (RTY) years. Projected: the range so far, scaled by the typical share of the day done by this hour, blended with the expected range — mostly the forecast early in the session, mostly the live range by midday.", display = display.none)
xMkt   = input.string("Auto", "Model", options = ["Auto", "NQ", "ES", "RTY", "Pooled"], group = gX, tooltip = "Auto: NQ / MNQ use the NQ fit, ES / MES the ES fit, RTY / M2K the RTY fit, anything else the pooled fit.", display = display.none)
xBand  = input.string("P25–P75", "Band", options = ["P25–P75", "P10–P90"], group = gX, display = display.none)
xCal   = input.bool(true, "Today's drivers on the status card", group = gX, tooltip = "Which of today's conditions move the expected range, with their multipliers: inside day, holidays, opex Friday, turn of month, weekday, yesterday's move.", display = display.none)
xExt   = input.bool(true, "Chance the high / low is already in", group = gX, tooltip = "From how far price is from today's high and low, and how much volatility is still to come before 17:00 ET (the expected range × the share of the day's variance still ahead, measured on NQ, ES and RTY 1-minute data; RTY uses its own profile). Tested 2025–26: well calibrated, and 23–25% sharper than the plain base rate for the hour (NQ 25%, ES 23%, RTY 25%; about 40% from 09:30 on). Needs an intraday chart of 60 minutes or lower.", display = display.none)
colExp = input.color(#ab47bc, "Expected / projected", group = gX, display = display.none)

gR = "Reference cards"
cWk    = input.bool(true, "Weekdays", group = gR, inline = "r1", display = display.none)
cWkOn  = input.string("Indicator pane", "", options = ["Price chart", "Indicator pane"], group = gR, inline = "r1", display = display.none)
cWkPos = input.string("Top left", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = gR, inline = "r1", display = display.none)
cMo    = input.bool(true, "Months", group = gR, inline = "r2", display = display.none)
cMoOn  = input.string("Price chart", "", options = ["Price chart", "Indicator pane"], group = gR, inline = "r2", display = display.none)
cMoPos = input.string("Bottom left", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = gR, inline = "r2", display = display.none)
cHr    = input.bool(false, "Hours", group = gR, inline = "r3", display = display.none)
cHrOn  = input.string("Indicator pane", "", options = ["Price chart", "Indicator pane"], group = gR, inline = "r3", display = display.none)
cHrPos = input.string("Top center", "", options = ["Top left", "Top center", "Top right", "Middle left", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = gR, inline = "r3", display = display.none)
topGap = input.float(7.0, "Gap under the title for top cards (% of pane)", minval = 0, maxval = 20, step = 0.5, group = gR, tooltip = "Cards placed Top left or Top center sit this far below the indicator title. Cards on the price chart use half of it; the Mobile layout adds 40% because panes are shorter.", display = display.none)
cSzI   = input.string("Tiny", "Text", options = ["Tiny", "Small", "Normal"], group = gR, display = display.none)

gA = "Alerts (create one alert with 'Any alert() function call')"
alStat = input.bool(true, "Range moves Above / Below the neutral zone", group = gA, display = display.none)
alDay  = input.bool(true, "Typical day range reached", group = gA, display = display.none)
alAtr  = input.bool(true, "100% of ATR used", group = gA, display = display.none)
alExp  = input.bool(true, "Expected day range reached", group = gA, display = display.none)
alPrj  = input.bool(true, "Projection breaks above the expected band", group = gA, display = display.none)

gH = "Day of week"
nWk     = input.int(20, "Days per weekday", minval = 5, maxval = 36, group = gH, tooltip = "How many of each weekday to sample: 20 = the last 20 Mondays, the last 20 Tuesdays and so on. From daily bars, so it works on any chart timeframe.", display = display.none)
metric  = input.string("Range %", "Measure", options = ["Range %", "Net move %"], group = gH, tooltip = "Range % = (high − low) / open. Net move % = (close − open) / open. Both use the full trading day.", display = display.none)
showAll = input.bool(true, "All-days column", group = gH, display = display.none)
showDot = input.bool(true, "Each day as a dot", group = gH, tooltip = "Green = the day closed up, red = down. Older days fade.", display = display.none)

gT = "Hour of high / low"
showHr  = input.bool(true, "Hour block in Distributions", group = gT, display = display.none)
hrFor   = input.string("Today's weekday", "Profile", options = ["Today's weekday", "All weekdays"], group = gT, display = display.none)
hrN     = input.int(30, "Days in profile", minval = 10, maxval = 120, group = gT, tooltip = "From 60-minute bars. Also N for the clock's baseline. How far back it reaches depends on your plan's bar history.", display = display.none)
colHi   = input.color(#f23645, "Hour of the high", group = gT, display = display.none)
colLo   = input.color(#089981, "Hour of the low", group = gT, display = display.none)

gM = "Month of year"
monYrs  = input.int(16, "Years per month", minval = 5, maxval = 20, group = gM, tooltip = "How many of each calendar month to sample: 16 = the last 16 completed Januaries, Februaries and so on. Use a continuous contract (NQ1!) so the history is long enough.", display = display.none)
monMet  = input.string("Net move %", "Measure", options = ["Net move %", "Range %"], group = gM, tooltip = "Net move % = month close − prior month close, as a % of the prior month close. Range % = month high − low over the same base. Points come from the back-adjusted series so contract rolls don't add a gap; the base comes from the unadjusted series so the % is true to the price level at the time.", display = display.none)
monPP   = input.float(0.5, "Strong / weak when median is ± pp vs all months", step = 0.1, group = gM, display = display.none)
showMd  = input.bool(true, "Each year as a dot", group = gM, display = display.none)

gW = "Distributions layout"
showWhat = input.string("Weekdays, hours and months", "Show (desktop)", options = ["Weekdays, hours and months", "Weekdays and hours", "Months only"], group = gW, display = display.none)
mView    = input.string("Weekdays", "Show (mobile)", options = ["Weekdays", "Hours", "Months"], group = gW, display = display.none)
gap      = input.int(14, "Weekday spacing (bars)", minval = 6, maxval = 60, group = gW, display = display.none)
hrW      = input.int(5, "Hour width (bars)", minval = 3, maxval = 12, group = gW, display = display.none)
mGap     = input.int(10, "Month spacing (bars)", minval = 5, maxval = 40, group = gW, display = display.none)
txtSz    = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = gW, display = display.none)

gC = "Colours"
wideX   = input.float(1.05, "Wide when median ≥ × all", step = 0.01, group = gC, display = display.none)
narX    = input.float(0.95, "Narrow when median ≤ × all", step = 0.01, group = gC, display = display.none)
colWide = input.color(#ff6d00, "Wide / above", group = gC, display = display.none)
colNar  = input.color(#00acc1, "Narrow / below", group = gC, display = display.none)
colNorm = input.color(#787b86, "Typical", group = gC, display = display.none)
colAll  = input.color(#b2b5be, "All days", group = gC, display = display.none)
colUp   = input.color(#089981, "Up / strong", group = gC, display = display.none)
colDn   = input.color(#f23645, "Down / weak", group = gC, display = display.none)
colNow  = input.color(#ffb300, "Today / now", group = gC, display = display.none)
colNeu  = input.color(#d1d4dc, "Neutral", group = gC, display = display.none)
colBand = input.color(#5b6b8c, "Clock bands", group = gC, display = display.none)

// ═══════════════════════════════════════════════════════════════ Settings, palette
mob     = layout == "Mobile"
sz      = txtSz == "Tiny" ? size.tiny : txtSz == "Small" ? size.small : size.normal
dSz     = mob ? size.tiny : dashSzI == "Tiny" ? size.tiny : dashSzI == "Small" ? size.small : size.normal
cSz     = cSzI == "Tiny" ? size.tiny : cSzI == "Small" ? size.small : size.normal
zCI     = bandCI == "68%" ? 1.0 : bandCI == "80%" ? 1.2816 : bandCI == "90%" ? 1.6449 : 1.96
baseAll = byBase == "Last N days"
drawWkI = mob ? mView == "Weekdays" : showWhat != "Months only"
drawHrI = mob ? mView == "Hours" : showWhat != "Months only" and showHr
drawMoI = mob ? mView == "Months" : showWhat != "Weekdays and hours"
gapE    = mob ? 6 : gap
hrWE    = mob ? 3 : hrW
mGapE   = mob ? 5 : mGap
dotsW   = showDot and not mob
dotsM   = showMd and not mob
szE     = mob ? size.tiny : sz

float bgLum = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool  dark  = theme == "Dark" or (theme == "Auto" and bgLum < 128)
color cBg   = dark ? #0e1117 : #ffffff
color cHd   = dark ? #171c28 : #eef1f6
color cBd   = dark ? #262c3a : #d5dae4
color cTx   = dark ? #e6e9ef : #131722
color cSub  = dark ? #9aa3b5 : #4a5163
color cMu   = dark ? #5d6476 : #9aa1b2
bool  chDark = bgLum < 128
color pFg    = chart.fg_color
color cNeuL  = chDark ? colNeu : #5d6476
color cZone  = chDark ? color.new(colNeu, 72) : color.new(#787b86, 62)
bool  medAuto = color.r(colMed) == 0 and color.g(colMed) == 0 and color.b(colMed) == 1
color medC    = medAuto ? color.new(pFg, 10) : colMed
color medLbl  = medAuto ? color.new(pFg, 25) : colMed

// card cells are painted solid: any tint is pre-mixed onto the card background so nothing behind the card shows through
solid(color c) =>
    color out = cBg
    if not na(color.r(c))
        float a = 1.0 - color.t(c) / 100.0
        out := color.rgb(color.r(c) * a + color.r(cBg) * (1.0 - a), color.g(c) * a + color.g(cBg) * (1.0 - a), color.b(c) * a + color.b(cBg) * (1.0 - a), 0)
    out

posOf(string s) =>
    switch s
        "Top left"      => position.top_left
        "Top center"    => position.top_center
        "Top right"     => position.top_right
        "Middle left"   => position.middle_left
        "Middle right"  => position.middle_right
        "Bottom left"   => position.bottom_left
        "Bottom center" => position.bottom_center
        => position.bottom_right

// ═══════════════════════════════════════════════════════════════ History requests (completed periods only)
tkU = ticker.modify(syminfo.tickerid, backadjustment = backadjustment.off)
tkA = ticker.modify(syminfo.tickerid, backadjustment = backadjustment.on)

// Daily context: pushes the previous day's figures on every daily bar, so today is never in the sample.
dayHist(int keep) =>
    var array<float> rg = array.new<float>()
    var array<float> nt = array.new<float>()
    var array<float> pt = array.new<float>()
    var array<int>   dw = array.new<int>()
    var array<int>   tt = array.new<int>()
    if bar_index > 0 and open[1] > 0
        rg.push(100.0 * (high[1] - low[1]) / open[1])
        nt.push(100.0 * (close[1] - open[1]) / open[1])
        pt.push(high[1] - low[1])
        dw.push(dayofweek(time_tradingday[1], "UTC"))
        tt.push(time_tradingday[1])
        if rg.size() > keep
            rg.shift()
            nt.shift()
            pt.shift()
            dw.shift()
            tt.shift()
    [rg, nt, pt, dw, tt]

// 60-minute context. Per completed day: the ET hour of the high and of the low, and the running range and net move at
// the end of each hour slot (18:00 … 16:00). Near the live edge it also packs, for every slot, the baseline's p10, p25,
// neutral-zone low, median, neutral-zone high, p75, p90 — range in the first 7×23 values, net move in the next 7×23.
hourHist(int keep, int want, bool anyDay, float z) =>
    var array<int>   hi = array.new<int>()
    var array<int>   lo = array.new<int>()
    var array<int>   dw = array.new<int>()
    var array<float> cR = array.new<float>()
    var array<float> cN = array.new<float>()
    var array<float> dR = array.new<float>(23, na)
    var array<float> dN = array.new<float>(23, na)
    var array<float> qq = array.new<float>(345, na)
    var float dO   = na
    var float dH   = na
    var float dL   = na
    var int   hH   = 0
    var int   hL   = 0
    var int   dd   = 0
    var int   seen = 0
    var int   np   = 0
    bool nd   = bar_index == 0 or time_tradingday != time_tradingday[1]
    int  hNow = hour(time, "America/New_York")
    int  slot = (hNow - 18 + 24) % 24
    if nd
        if seen > 1
            hi.push(hH)
            lo.push(hL)
            dw.push(dd)
            float lr = 0.0
            float ln = 0.0
            for j = 0 to 22
                if not na(dR.get(j))
                    lr := dR.get(j)
                    ln := dN.get(j)
                cR.push(lr)
                cN.push(ln)
            if dw.size() > keep + 50
                hi := hi.slice(50, hi.size()).copy()
                lo := lo.slice(50, lo.size()).copy()
                dw := dw.slice(50, dw.size()).copy()
                cR := cR.slice(50 * 23, cR.size()).copy()
                cN := cN.slice(50 * 23, cN.size()).copy()
        seen += 1
        dO := open
        dH := high
        dL := low
        hH := hNow
        hL := hNow
        dd := dayofweek(time_tradingday, "UTC")
        dR.fill(na)
        dN.fill(na)
    else
        if high > dH
            dH := high
            hH := hNow
        if low < dL
            dL := low
            hL := hNow
    if slot <= 22 and dO > 0
        dR.set(slot, 100.0 * (dH - dL) / dO)
        dN.set(slot, 100.0 * (close - dO) / dO)
    if timenow - time < 6 * 86400000
        array<int> pick = array.new<int>()
        int nD = dw.size()
        if nD > 0
            for i = nD - 1 to 0
                if anyDay or dw.get(i) == dd
                    pick.push(i)
                    if pick.size() >= want
                        break
        np := pick.size()
        if np >= 5
            int r1 = math.max(0, math.floor(np / 2.0 - z * math.sqrt(np) / 2.0))
            int r2 = math.max(r1, math.min(np - 1, math.ceil(np / 2.0 + z * math.sqrt(np) / 2.0) - 1))
            for m = 0 to 1
                for s = 0 to 22
                    array<float> v = array.new<float>()
                    for i in pick
                        v.push(m == 0 ? cR.get(i * 23 + s) : cN.get(i * 23 + s))
                    v.sort(order.ascending)
                    int ob = m * 161
                    qq.set(ob + s, v.percentile_linear_interpolation(10))
                    qq.set(ob + 23 + s, v.percentile_linear_interpolation(25))
                    qq.set(ob + 46 + s, v.get(r1))
                    qq.set(ob + 69 + s, v.median())
                    qq.set(ob + 92 + s, v.get(r2))
                    qq.set(ob + 115 + s, v.percentile_linear_interpolation(75))
                    qq.set(ob + 138 + s, v.percentile_linear_interpolation(90))
            // typical share of the day's final range already made by the end of each hour slot
            for s = 0 to 22
                array<float> v = array.new<float>()
                for i in pick
                    float fin = cR.get(i * 23 + 22)
                    if fin > 0
                        v.push(cR.get(i * 23 + s) / fin)
                qq.set(322 + s, v.size() > 0 ? v.median() : na)
    [hi, lo, dw, qq, np]

// Monthly contexts. Each completed month is keyed by its mid-point time (same in both series).
// Unadjusted: the level the month started from (prior month close).
monBase(int keep) =>
    var array<int>   mk = array.new<int>()
    var array<float> mb = array.new<float>()
    if bar_index > 1
        mk.push(int((time[1] + time_close[1]) / 2))
        mb.push(close[2])
        if mk.size() > keep
            mk.shift()
            mb.shift()
    [mk, mb, close[1]]

// Back-adjusted: the month's move and range in points with roll gaps removed (completed months only).
monMove(int keep) =>
    var array<int>   mk = array.new<int>()
    var array<float> mp = array.new<float>()
    var array<float> mr = array.new<float>()
    if bar_index > 1
        mk.push(int((time[1] + time_close[1]) / 2))
        mp.push(close[1] - close[2])
        mr.push(high[1] - low[1])
        if mk.size() > keep
            mk.shift()
            mp.shift()
            mr.shift()
    [mk, mp, mr]

// Back-adjusted daily context: this month's starting close and its high / low over completed days only, in the
// current contract's terms, so the chart can add today's live move without any look-ahead.
mtdAdj() =>
    var float mStart = na
    var float mHi    = na
    var float mLo    = na
    if bar_index > 0
        if month(time_tradingday, "UTC") != month(time_tradingday[1], "UTC")
            mStart := close[1]
            mHi    := na
            mLo    := na
        else
            mHi := na(mHi) ? high[1] : math.max(mHi, high[1])
            mLo := na(mLo) ? low[1] : math.min(mLo, low[1])
    [mStart, mHi, mLo]

[dRg, dNt, dPt, dDw, dTt]  = request.security(tkU, "D", dayHist(nWk * 5 + 40), lookahead = barmerge.lookahead_on)
[hHi, hLo, hDw, hQ, hNp]   = request.security(tkU, "60", hourHist(hrN * 5 + 40, hrN, baseAll, zCI), lookahead = barmerge.lookahead_on)
[uK, uB, uCurB]            = request.security(tkU, "M", monBase(monYrs * 12 + 24), lookahead = barmerge.lookahead_on)
[aK, aP, aR]               = request.security(tkA, "M", monMove(monYrs * 12 + 24), lookahead = barmerge.lookahead_on)
[mStA, mHiA, mLoA]         = request.security(tkA, "D", mtdAdj(), lookahead = barmerge.lookahead_on)
atrD                       = request.security(tkA, "D", ta.atr(atrLen)[1], lookahead = barmerge.lookahead_on)

// ═══════════════════════════════════════════════════════════════ Expected range (anchored HAR, completed days only)
// Unadjusted daily context: log range % of the last 250 completed days (the anchor L) and the last 1 / 5 / 22-day means
// relative to it; plus today's trading-day-of-month count.
harU() =>
    var array<float> lrA = array.new<float>()
    var int td = 0
    bool newM = bar_index == 0 or month(time_tradingday, "UTC") != month(time_tradingday[1], "UTC")
    td := newM ? 1 : td + 1
    if bar_index > 0 and open[1] > 0 and high[1] > low[1]
        lrA.push(math.log(100.0 * (high[1] - low[1]) / open[1]))
        if lrA.size() > 250
            lrA.shift()
    float L   = na
    float d1  = na
    float d5  = na
    float d22 = na
    int   n   = lrA.size()
    if n >= 120
        L := lrA.avg()
        d1 := lrA.get(n - 1) - L
        float s5 = 0.0
        for k = n - 5 to n - 1
            s5 += lrA.get(k)
        d5 := s5 / 5.0 - L
        float s22 = 0.0
        for k = n - 22 to n - 1
            s22 += lrA.get(k)
        d22 := s22 / 22.0 - L
    [L, d1, d5, d22, td, n]
// Back-adjusted daily context: yesterday's close-to-close move (%) and whether yesterday was an inside day.
harA() =>
    float r1  = bar_index > 1 and close[2] > 0 ? 100.0 * (close[1] - close[2]) / close[2] : na
    int   in1 = bar_index > 1 and high[1] <= high[2] and low[1] >= low[2] ? 1 : 0
    [r1, in1]
[xL, xD1, xD5, xD22, xTd, xN] = request.security(tkU, "D", harU(), lookahead = barmerge.lookahead_on)
[xR1, xIn]                   = request.security(tkA, "D", harA(), lookahead = barmerge.lookahead_on)

// Coefficients fitted on 2010–2026 daily bars: const, d1, d5, d22, down move, up move, inside, Tue, Wed, Thu, Fri,
// opex Friday, turn of month, pre-holiday, post-holiday | residual quantiles q10, q25, q50, q75, q90.
mktR = xMkt != "Auto" ? xMkt : (syminfo.root == "NQ" or syminfo.root == "MNQ") ? "NQ" : (syminfo.root == "ES" or syminfo.root == "MES") ? "ES" : (syminfo.root == "RTY" or syminfo.root == "M2K") ? "RTY" : "Pooled"
cfFor(string m) =>
    switch m
        "NQ"  => array.from(-0.0157, 0.2168, 0.4872, 0.2038, 0.0641, -0.1362, 0.1238, 0.0075, 0.0405, 0.0663, 0.0238, -0.0679, 0.0418, -0.1257, 0.1070, -0.4863, -0.2687, -0.0127, 0.2500, 0.4925)
        "ES"  => array.from(-0.0424, 0.2529, 0.5028, 0.1748, 0.0671, -0.1786, 0.1195, 0.0383, 0.0689, 0.1109, 0.0785, -0.0725, 0.0620, -0.1432, 0.1423, -0.4863, -0.2696, -0.0201, 0.2483, 0.5056)
        "RTY" => array.from(0.0043, 0.2132, 0.4513, 0.2411, 0.0273, -0.0980, 0.0915, 0.0030, 0.0218, 0.0368, 0.0056, -0.0868, 0.0623, -0.1194, 0.0821, -0.4515, -0.2500, -0.0144, 0.2296, 0.4647)
        => array.from(-0.0178, 0.2311, 0.4818, 0.2022, 0.0465, -0.1286, 0.1125, 0.0152, 0.0430, 0.0701, 0.0353, -0.0762, 0.0548, -0.1279, 0.1120, -0.4753, -0.2628, -0.0158, 0.2451, 0.4912)
var array<float> CF = cfFor(mktR)
bandW = xBand == "P25–P75"
qLoI  = bandW ? 16 : 15
qHiI  = bandW ? 18 : 19
bandTx = bandW ? "P25–P75" : "P10–P90"
// Live projection weights by hour slot (end of 18:00 … end of 16:00 ET), fitted on NQ, ES and RTY 1-minute data 2018–2026:
// final = max(range so far, proj + c + w × (expected − proj)), proj = range so far ÷ typical share of the day done.
var array<float> PW10 = array.from(0.851, 0.816, 0.767, 0.734, 0.708, 0.704, 0.690, 0.675, 0.658, 0.612, 0.587, 0.562, 0.542, 0.502, 0.396, 0.203, 0.101, 0.059, 0.037, 0.030, 0.018, 0.0, 0.0)
var array<float> PC10 = array.from(-0.459, -0.455, -0.449, -0.448, -0.448, -0.446, -0.440, -0.437, -0.429, -0.421, -0.416, -0.413, -0.406, -0.397, -0.373, -0.308, -0.219, -0.157, -0.115, -0.075, -0.029, 0.0, 0.0)
var array<float> PW25 = array.from(0.870, 0.849, 0.796, 0.760, 0.734, 0.725, 0.715, 0.696, 0.677, 0.629, 0.610, 0.585, 0.566, 0.533, 0.468, 0.287, 0.141, 0.079, 0.048, 0.031, 0.0, 0.0, 0.0)
var array<float> PC25 = array.from(-0.248, -0.244, -0.240, -0.242, -0.234, -0.235, -0.230, -0.228, -0.227, -0.228, -0.222, -0.225, -0.221, -0.218, -0.203, -0.185, -0.135, -0.094, -0.062, -0.028, 0.0, 0.0, 0.0)
var array<float> PW50 = array.from(0.858, 0.821, 0.790, 0.764, 0.742, 0.733, 0.725, 0.708, 0.688, 0.648, 0.620, 0.615, 0.603, 0.577, 0.508, 0.360, 0.234, 0.146, 0.075, 0.015, 0.0, 0.0, 0.0)
var array<float> PC50 = array.from(-0.008, -0.004, -0.004, 0.0, -0.002, -0.001, -0.001, -0.003, -0.006, -0.006, -0.005, 0.002, 0.001, 0.001, 0.001, 0.0, 0.005, 0.006, 0.006, 0.003, 0.0, 0.0, 0.0)
var array<float> PW75 = array.from(0.853, 0.820, 0.798, 0.763, 0.752, 0.748, 0.746, 0.740, 0.727, 0.691, 0.673, 0.664, 0.653, 0.625, 0.560, 0.426, 0.317, 0.235, 0.189, 0.140, 0.062, 0.0, 0.0)
var array<float> PC75 = array.from(0.248, 0.243, 0.247, 0.243, 0.242, 0.241, 0.243, 0.244, 0.241, 0.237, 0.238, 0.239, 0.239, 0.234, 0.222, 0.208, 0.186, 0.162, 0.147, 0.124, 0.082, 0.0, 0.0)
var array<float> PW90 = array.from(0.834, 0.803, 0.789, 0.767, 0.746, 0.723, 0.724, 0.728, 0.730, 0.706, 0.684, 0.682, 0.671, 0.656, 0.585, 0.473, 0.393, 0.327, 0.277, 0.222, 0.118, 0.025, 0.0)
var array<float> PC90 = array.from(0.505, 0.497, 0.500, 0.493, 0.494, 0.492, 0.493, 0.493, 0.490, 0.485, 0.487, 0.477, 0.478, 0.473, 0.450, 0.428, 0.390, 0.355, 0.314, 0.274, 0.201, 0.053, 0.0)
// Share of the day's price variance still to come at the end of each hour slot, 1-minute data 2018–2026: NQ and ES
// (also used for anything else), and RTY on its own, since RTY gets more of its day done by midday (at 12:00 ET about 28%
// of its variance is still to come vs 33% for NQ / ES, in every period tested). KAPPA is the day's volatility as a
// multiple of the expected range. Together they give the chance the high / low is already in.
var array<float> VREM = array.from(0.968, 0.952, 0.930, 0.906, 0.892, 0.883, 0.869, 0.855, 0.835, 0.802, 0.776, 0.757, 0.734, 0.707, 0.634, 0.528, 0.412, 0.332, 0.271, 0.206, 0.135, 0.031, 0.0)
var array<float> VREMR = array.from(0.969, 0.955, 0.935, 0.914, 0.902, 0.895, 0.885, 0.874, 0.856, 0.825, 0.798, 0.780, 0.752, 0.724, 0.640, 0.504, 0.371, 0.288, 0.228, 0.167, 0.096, 0.021, 0.0)
var array<float> VRM = mktR == "RTY" ? VREMR : VREM
KAPPA = 0.655

// CME equity-index holiday rules (full-day closures). Good Friday sessions that did trade are listed by year.
dowOf(int y, int m, int d) => dayofweek(timestamp("UTC", y, m, d, 0, 0), "UTC")
nthDow(int y, int m, int wd, int n) =>
    int f = dowOf(y, m, 1)
    1 + (wd - f + 7) % 7 + 7 * (n - 1)
lastDow(int y, int m, int wd, int dim) =>
    int ld = dowOf(y, m, dim)
    dim - (ld - wd + 7) % 7
easterTs(int y) =>
    int a  = y % 19
    int b  = int(math.floor(y / 100.0))
    int c  = y % 100
    int d  = int(math.floor(b / 4.0))
    int e  = b % 4
    int f  = int(math.floor((b + 8) / 25.0))
    int g  = int(math.floor((b - f + 1) / 3.0))
    int h  = (19 * a + b - d - g + 15) % 30
    int i  = int(math.floor(c / 4.0))
    int k  = c % 4
    int lw = (32 + 2 * e + 2 * i - h - k) % 7
    int mm = int(math.floor((a + 11 * h + 22 * lw) / 451.0))
    int mo = int(math.floor((h + lw - 7 * mm + 114) / 31.0))
    int dd = (h + lw - 7 * mm + 114) % 31 + 1
    timestamp("UTC", y, mo, dd, 0, 0)
isHol(int y, int m, int d) =>
    int  w   = dowOf(y, m, d)
    bool hol = false
    if w >= 2 and w <= 6
        int  gf     = easterTs(y) - 2 * 86400000
        bool gfOpen = y == 2010 or y == 2012 or y == 2015 or y == 2023 or y == 2026
        hol := (m == 1 and (d == 1 or (d == 2 and w == 2))) or (m == 1 and d == nthDow(y, 1, 2, 3)) or (m == 2 and d == nthDow(y, 2, 2, 3)) or (not gfOpen and m == month(gf, "UTC") and d == dayofmonth(gf, "UTC")) or (m == 5 and d == lastDow(y, 5, 2, 31)) or (y >= 2022 and m == 6 and (d == 19 or (d == 18 and w == 6) or (d == 20 and w == 2))) or (m == 7 and (d == 4 or (d == 3 and w == 6) or (d == 5 and w == 2))) or (m == 9 and d == nthDow(y, 9, 2, 1)) or (m == 11 and d == nthDow(y, 11, 5, 4)) or (m == 12 and (d == 25 or (d == 24 and w == 6) or (d == 26 and w == 2)))
    hol
holTs(int t) => isHol(year(t, "UTC"), month(t, "UTC"), dayofmonth(t, "UTC"))
// next / previous weekday (dir = 1 / −1) from a UTC midnight timestamp
dayStep(int ts, int dir) =>
    int t = ts + dir * 86400000
    while dayofweek(t, "UTC") == 1 or dayofweek(t, "UTC") == 7
        t += dir * 86400000
    t
nextTD(int ts) =>
    int t = dayStep(ts, 1)
    int guard = 0
    while holTs(t) and guard < 5
        t := dayStep(t, 1)
        guard += 1
    t

// ═══════════════════════════════════════════════════════════════ Today, live from the chart
var float tO   = na
var float tHi  = na
var float tLo  = na
var int   tHhr = na
var int   tLhr = na
bool newTd = ta.change(time_tradingday) != 0
if newTd or na(tO)
    tO   := open
    tHi  := high
    tLo  := low
    tHhr := hour(time, TZ)
    tLhr := tHhr
else
    if high > tHi
        tHi  := high
        tHhr := hour(time, TZ)
    if low < tLo
        tLo  := low
        tLhr := hour(time, TZ)

int   tDow   = dayofweek(time_tradingday, "UTC")
int   curMo  = month(time_tradingday, "UTC")
bool  isWk   = tDow >= 2 and tDow <= 6
float tRng   = 100.0 * (tHi - tLo) / tO
float tNet   = 100.0 * (close - tO) / tO
int   tdOpen = timestamp(TZ, year(time_tradingday, "UTC"), month(time_tradingday, "UTC"), dayofmonth(time_tradingday, "UTC"), 18, 0) - 86400000
int   lbS    = last_bar_time + 6 * HOUR
int   lastTd = timestamp("UTC", year(lbS, TZ), month(lbS, TZ), dayofmonth(lbS, TZ), 0, 0)
bool  isTodayBar = time_tradingday == lastTd
float moNetLive = uCurB > 0 and not na(mStA) ? 100.0 * (close - mStA) / uCurB : na
float moRngLive = uCurB > 0 ? 100.0 * (math.max(nz(mHiA, tHi), tHi) - math.min(nz(mLoA, tLo), tLo)) / uCurB : na

// today's calendar drivers (worked out once per trading day)
var bool cPre  = false
var bool cPost = false
var bool cLast = false
var bool cOpex = false
if newTd or barstate.isfirst
    int tt = time_tradingday
    cPre  := holTs(dayStep(tt, 1))
    cPost := holTs(dayStep(tt, -1))
    cLast := month(nextTD(tt), "UTC") != month(tt, "UTC")
    cOpex := dayofweek(tt, "UTC") == 6 and dayofmonth(tt, "UTC") >= 15 and dayofmonth(tt, "UTC") <= 21
bool  cTom = cLast or (not na(xTd) and xTd <= 3)
float xR1v = nz(xR1)
float xLog = na
if xOn and nz(xN) >= 120 and not na(xL) and not na(xD1) and not na(xD5) and not na(xD22)
    xLog := xL + CF.get(0) + CF.get(1) * xD1 + CF.get(2) * xD5 + CF.get(3) * xD22 + CF.get(4) * math.max(-xR1v, 0) + CF.get(5) * math.max(xR1v, 0) + CF.get(6) * nz(xIn) + CF.get(7) * (tDow == 3 ? 1 : 0) + CF.get(8) * (tDow == 4 ? 1 : 0) + CF.get(9) * (tDow == 5 ? 1 : 0) + CF.get(10) * (tDow == 6 ? 1 : 0) + CF.get(11) * (cOpex ? 1 : 0) + CF.get(12) * (cTom ? 1 : 0) + CF.get(13) * (cPre ? 1 : 0) + CF.get(14) * (cPost ? 1 : 0)
float expMed = math.exp(xLog + CF.get(17))
float expLo  = math.exp(xLog + CF.get(qLoI))
float expHi  = math.exp(xLog + CF.get(qHiI))

// ═══════════════════════════════════════════════════════════════ Helpers
var array<label>    pL = array.new<label>()
var array<box>      pB = array.new<box>()
var array<line>     pN = array.new<line>()
var array<polyline> pP = array.new<polyline>()
var array<string>   BLK = array.from("▁", "▂", "▃", "▄", "▅", "▆", "▇", "█")

wipe() =>
    for l in pL
        l.delete()
    for b in pB
        b.delete()
    for n in pN
        n.delete()
    for p in pP
        p.delete()
    pL.clear()
    pB.clear()
    pN.clear()
    pP.clear()

// Indices (oldest → newest) of the last `want` days on weekday `wd` (0 = any weekday).
idxFor(array<int> dws, int wd, int want) =>
    array<int> out = array.new<int>()
    int n = 0
    if not na(dws)
        n := dws.size()
    if n > 0
        for i = n - 1 to 0
            int d = dws.get(i)
            if (wd == 0 and d >= 2 and d <= 6) or d == wd
                out.unshift(i)
                if out.size() >= want
                    break
    out

// Indices (oldest → newest) of the last `want` completed months that are calendar month `m`.
moIdx(array<int> mids, int m, int want) =>
    array<int> out = array.new<int>()
    int n = mids.size()
    if n > 0
        for i = n - 1 to 0
            if month(mids.get(i), "UTC") == m
                out.unshift(i)
                if out.size() >= want
                    break
    out

valsAt(array<float> srcA, array<int> idx) =>
    array<float> out = array.new<float>()
    for i in idx
        out.push(srcA.get(i))
    out

lastN(array<float> srcA, int k) =>
    array<float> out = array.new<float>()
    int n = srcA.size()
    if n > 0
        for i = math.max(0, n - k) to n - 1
            out.push(srcA.get(i))
    out

rankOf(array<float> a, float x) =>
    float r = na
    int n = a.size()
    if n > 0 and not na(x)
        int c = 0
        for v in a
            if v <= x
                c += 1
        r := 100.0 * c / n
    r

// packed slot quantiles: m 0 = range, 1 = net; k 0 p10, 1 p25, 2 zone low, 3 median, 4 zone high, 5 p75, 6 p90
qAt(array<float> qa, int m, int k, int s) => qa.get(m * 161 + k * 23 + s)
qInterp(array<float> qa, int m, int k, int j, float f) =>
    float v = na
    if not na(qa)
        if qa.size() >= 322 and j >= 0 and j <= 22
            float b = qa.get(m * 161 + k * 23 + j)
            float a = j > 0 ? qa.get(m * 161 + k * 23 + j - 1) : 0.0
            if not na(b) and not na(a)
                v := a + (b - a) * f
    v

// approximate percentile from the packed quantiles
pctQ(float x, float q10, float q25, float q50, float q75, float q90) =>
    float p = na
    if not na(x) and not na(q10) and not na(q90)
        if x < q10
            p := 5.0
        else if x <= q25
            p := 10.0 + 15.0 * (x - q10) / math.max(q25 - q10, 1e-9)
        else if x <= q50
            p := 25.0 + 25.0 * (x - q25) / math.max(q50 - q25, 1e-9)
        else if x <= q75
            p := 50.0 + 25.0 * (x - q50) / math.max(q75 - q50, 1e-9)
        else if x <= q90
            p := 75.0 + 15.0 * (x - q75) / math.max(q90 - q75, 1e-9)
        else
            p := 95.0
    p
pTxt(float p) => na(p) ? "—" : p <= 5.0 ? "<P10" : p >= 95.0 ? ">P90" : "≈P" + str.tostring(p, "0")

stTxt(float x, float lo, float hi) => na(x) or na(lo) or na(hi) ? "" : x > hi ? "Above" : x < lo ? "Below" : "Neutral"
pill(string s) => s == "Above" ? "▲ ABOVE" : s == "Below" ? "▼ BELOW" : s == "Neutral" ? "● NEUTRAL" : "—"

// text gauges for monospace cells
gauge(float frac) =>
    string out = "░░░░░░░░░░"
    if not na(frac)
        int k = int(math.round(math.max(0.0, math.min(1.0, frac)) * 10))
        out := str.repeat("█", k) + str.repeat("░", 10 - k)
    out
meter(float p) =>
    string out = "──────────"
    if not na(p)
        int k = int(math.round(math.max(0.0, math.min(100.0, p)) / 10.0))
        out := str.repeat("─", k) + "●" + str.repeat("─", 10 - k)
    out
// distribution shape of a sample as an 8-bin sparkline
sparkDist(array<float> v, float lo, float hi) =>
    string s = ""
    if v.size() > 0 and hi > lo
        array<int> cnt = array.new<int>(8, 0)
        for x in v
            int b = math.min(7, math.max(0, int(math.floor((x - lo) / (hi - lo) * 8.0))))
            cnt.set(b, cnt.get(b) + 1)
        int mxc = math.max(1, int(cnt.max()))
        for k = 0 to 7
            int c = cnt.get(k)
            s += c == 0 ? " " : BLK.get(math.min(7, int(math.floor(c * 7.0 / mxc))))
    s

// table cells: regular and bold, monospace
tc(table t, int c, int r, string s, color fg, color bg, string tsz, string ha = text.align_left, string tip = "") =>
    t.cell(c, r, s, text_color = fg, bgcolor = solid(bg), text_size = tsz, text_halign = ha, tooltip = tip, text_font_family = font.family_monospace)
tcB(table t, int c, int r, string s, color fg, color bg, string tsz, string ha = text.align_left, string tip = "") =>
    t.cell(c, r, s, text_color = fg, bgcolor = solid(bg), text_size = tsz, text_halign = ha, tooltip = tip, text_font_family = font.family_monospace, text_formatting = text.format_bold)

// weight for the current point in the session: end of the previous slot → end of the current slot
pwI(array<float> a, int j, float f) => j <= 0 ? a.get(0) : a.get(j - 1) + (a.get(j) - a.get(j - 1)) * f
// standard normal CDF (Abramowitz–Stegun 26.2.17, error < 1e-7)
nCdf(float x) =>
    float z = math.abs(x)
    float t = 1.0 / (1.0 + 0.2316419 * z)
    float p = 1.0 - 0.3989422804 * math.exp(-0.5 * z * z) * t * (0.319381530 + t * (-0.356563782 + t * (1.781477937 + t * (-1.821255978 + t * 1.330274429))))
    x >= 0 ? p : 1.0 - p
mapY(float v, float a0, float a1, float b0, float b1) => a1 > a0 ? b0 + (v - a0) / (a1 - a0) * (b1 - b0) : b0

f1(float x) => str.tostring(x, "0.0")
f2(float x) => str.tostring(x, "0.00")
sgn(float x) => (x >= 0 ? "+" : "") + str.tostring(x, "0.00")
sgn1(float x) => (x >= 0 ? "+" : "") + str.tostring(x, "0.0")
sgn0(float x) => (x >= 0 ? "+" : "") + str.tostring(x, "0")
dayName(int d) => d == 2 ? "Mon" : d == 3 ? "Tue" : d == 4 ? "Wed" : d == 5 ? "Thu" : d == 6 ? "Fri" : d == 7 ? "Sat" : "Sun"
moName(int m) => m == 1 ? "Jan" : m == 2 ? "Feb" : m == 3 ? "Mar" : m == 4 ? "Apr" : m == 5 ? "May" : m == 6 ? "Jun" : m == 7 ? "Jul" : m == 8 ? "Aug" : m == 9 ? "Sep" : m == 10 ? "Oct" : m == 11 ? "Nov" : "Dec"

// polyline helpers for the clock (time-anchored, so they hold their place at any zoom)
bandPoly(array<float> qa, int m, int kUp, int kDn, int t0, color fillC) =>
    array<chart.point> pts = array.new<chart.point>()
    pts.push(chart.point.from_time(t0, 0.0))
    for j = 0 to 22
        pts.push(chart.point.from_time(t0 + (j + 1) * 3600000, qa.get(m * 161 + kUp * 23 + j)))
    for j = 22 to 0
        pts.push(chart.point.from_time(t0 + (j + 1) * 3600000, qa.get(m * 161 + kDn * 23 + j)))
    polyline.new(pts, curved = false, closed = true, xloc = xloc.bar_time, line_color = #00000000, fill_color = fillC)
pathPoly(array<float> qa, int m, int k, int t0, color lc, int lw, string ls) =>
    array<chart.point> pts = array.new<chart.point>()
    pts.push(chart.point.from_time(t0, 0.0))
    for j = 0 to 22
        pts.push(chart.point.from_time(t0 + (j + 1) * 3600000, qa.get(m * 161 + k * 23 + j)))
    polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_time, line_color = lc, line_width = lw, line_style = ls)

// ═══════════════════════════════════════════════════════════════ Cards (created once)
var table tS = na
var table tW = na
var table tM = na
var table tH = na
// Phone panes are too narrow for a centre card beside a corner card, so the Mobile layout moves centre cards to the
// right-hand corner of the same edge.
effPos(string p) => mob ? (p == "Top center" ? "Top right" : p == "Bottom center" ? "Bottom right" : p) : p
pS = effPos(dashPos)
pW = effPos(cWkPos)
pM = effPos(cMoPos)
pH = effPos(cHrPos)
// cards along the top edge sit below the indicator title (and, in the pane, below the pane's own buttons on the right)
needGap(string p, string on) => p == "Top left" or p == "Top center" or (p == "Top right" and on == "Indicator pane")
padFor(string p, string on) => needGap(p, on) ? topGap * (on == "Price chart" ? 0.5 : 1.0) * (mob ? 1.4 : 1.0) : 0.0
offS = needGap(pS, dashOn) ? 1 : 0
nStat = mob ? 5 + (xOn ? 1 : 0) + (xOn and xExt ? 1 : 0) : 11 + (xOn ? 1 : 0) + (xOn and xCal ? 1 : 0) + (xOn and xExt ? 1 : 0)
offW = needGap(pW, cWkOn) ? 1 : 0
offM = needGap(pM, cMoOn) ? 1 : 0
offH = needGap(pH, cHrOn) ? 1 : 0
// Each table has exactly the columns and rows its layout uses, and every body cell starts filled, so no empty cell grid
// is ever drawn. The gap row is one merged, unfilled cell.
mkTable(string p, string on, int cols, int rows, string tsz) =>
    table t = na
    if on == "Price chart"
        t := table.new(posOf(p), cols, rows, bgcolor = #00000000, frame_width = 0, border_color = cBd, border_width = 1, force_overlay = true)
    else
        t := table.new(posOf(p), cols, rows, bgcolor = #00000000, frame_width = 0, border_color = cBd, border_width = 1, force_overlay = false)
    int r0 = 0
    if needGap(p, on)
        t.cell(0, 0, "", height = padFor(p, on), bgcolor = #00000000)
        t.merge_cells(0, 0, cols - 1, 0)
        r0 := 1
    for r = r0 to rows - 1
        for c = 0 to cols - 1
            t.cell(c, r, "", bgcolor = solid(cBg), text_size = tsz)
    t
if barstate.isfirst
    if showDash
        tS := mkTable(pS, dashOn, 3, nStat + offS, dSz)
        tS.merge_cells(0, offS, 2, offS)
        if not mob
            tS.merge_cells(0, nStat - 1 + offS, 2, nStat - 1 + offS)
    if cWk
        tW := mkTable(pW, cWkOn, mob ? 4 : 7, 8 + offW, cSz)
        tW.merge_cells(0, offW, mob ? 3 : 6, offW)
    if cMo
        tM := mkTable(pM, cMoOn, 13, (mob ? 3 : 5) + offM, cSz)
        tM.merge_cells(0, offM, 12, offM)
    if cHr
        tH := mkTable(pH, cHrOn, mob ? 2 : 24, (mob ? 4 : 5) + offH, cSz)
        tH.merge_cells(0, offH, mob ? 1 : 23, offH)

// ═══════════════════════════════════════════════════════════════ Range clock: today's live path (plots)
bool  clkTF  = timeframe.isintraday and timeframe.in_seconds() <= 3600
bool  clkOn  = view == "Range clock" and clkTF
bool  clkR   = clkMet == "Range"
int   mSel   = clkR ? 0 : 1
int   jB     = (hour(time, TZ) - 18 + 24) % 24
float fB     = math.min(1.0, (minute(time, TZ) + timeframe.in_seconds() / 60.0) / 60.0)
float vB     = clkR ? tRng : tNet
string stB   = stTxt(vB, qInterp(hQ, mSel, 2, jB, fB), qInterp(hQ, mSel, 4, jB, fB))
color upC    = clkR ? colWide : colUp
color dnC    = clkR ? colNar : colDn
color liveC  = stB == "Above" ? upC : stB == "Below" ? dnC : stB == "Neutral" ? cNeuL : colNow
plot(clkOn and isTodayBar and not newTd ? vB : na, "Today", color = liveC, linewidth = 3, style = plot.style_linebr, display = display.all - display.status_line)
plot(clkOn and kPast and not isTodayBar and not newTd ? vB : na, "Earlier days", color = color.new(pFg, 72), linewidth = 1, style = plot.style_linebr, display = display.all - display.status_line)

// ═══════════════════════════════════════════════════════════════ Alerts state
varip string alLast  = ""
varip bool   alDayOk = false
varip bool   alAtrOk = false
varip int    alTd    = 0
varip int    beat    = 0
varip bool   alExpOk = false
varip bool   alPrjOk = false
if barstate.isrealtime
    beat += 1

// ═══════════════════════════════════════════════════════════════ Draw and fill (last bar only)
// values shared by the last-bar blocks below (filled once, on the last bar)
string stamp = ""
string stampS = ""
string dn = ""
bool hasMo = false
bool hasQ = false
float rPts = na
float nPts = na
int jN = na
float fN = na
int nB = na
string bl = ""
array<int> jK = na
array<float> jNet = na
array<float> jRng = na
array<float> jPts = na
int wdH = na
array<int> ixh = na
int nh = na
array<int> cH = na
array<int> cL = na
int mx = na
string who = ""
float rMed = na
float rZlo = na
float rZhi = na
float rP = na
float nMed = na
float nZlo = na
float nZhi = na
float nP = na
bool tmOK = false
string sR = ""
string sN = ""
float dayMed = na
float dayP75 = na
float dayPts = na
float atrUse = na
float expPts = na
float prjMed = na
float prjLo = na
float prjHi = na
bool qShOK = false
float prjPts = na
string prjSt = ""
string drvTx = ""
float drvMul = na
array<float> allR = na
float medAllR = na
float gLo = na
float gHi = na
float todayMult = na
float todayUp = na
float moNet = na
array<float> mvC = na
float mvMed = na
float mvRk = na
int hNowET = na
float hShH = na
float hShL = na
float pHiIn = na
float pLoIn = na
float sigPts = na

if barstate.islast
    wipe()
    stamp := str.format_time(time, "HH:mm MM/dd", TZ)
    stampS := str.format_time(time, "HH:mm", TZ)
    dn := isWk ? dayName(tDow) : "—"
    hasMo := not na(aK) and not na(uK)
    hasQ := not na(hQ) and nz(hNp) >= 5
    rPts := tHi - tLo
    nPts := close - tO
    jN := (hour(time, TZ) - 18 + 24) % 24
    fN := timeframe.isintraday ? math.min(1.0, (minute(time, TZ) + timeframe.in_seconds() / 60.0) / 60.0) : 1.0
    nB := na(hNp) ? 0 : hNp
    bl := baseAll ? "last " + str.tostring(nB) + " days" : "last " + str.tostring(nB) + " " + dn + "s"

    // ── month values (roll-free points over the unadjusted base)
    jK := array.new<int>()
    jNet := array.new<float>()
    jRng := array.new<float>()
    jPts := array.new<float>()
    if hasMo
        int nA = aK.size()
        if nA > 0
            for i = 0 to nA - 1
                int k = uK.indexof(aK.get(i))
                if k >= 0
                    float mb0 = uB.get(k)
                    if mb0 > 0
                        jK.push(aK.get(i))
                        jNet.push(100.0 * aP.get(i) / mb0)
                        jRng.push(100.0 * aR.get(i) / mb0)
                        jPts.push(aP.get(i))

    // ── hour-of-high/low counts
    wdH := hrFor == "Today's weekday" and isWk ? tDow : 0
    ixh := idxFor(hDw, wdH, hrN)
    nh := ixh.size()
    cH := array.new<int>(24, 0)
    cL := array.new<int>(24, 0)
    if not na(hHi)
        for i in ixh
            int a = hHi.get(i)
            int b = hLo.get(i)
            cH.set(a, cH.get(a) + 1)
            cL.set(b, cL.get(b) + 1)
    mx := math.max(1, int(math.max(cH.max(), cL.max())))
    who := wdH == 0 ? "days" : dayName(wdH) + "s"

    // ── statuses at this minute (shared by the clock, the card and the alerts)
    rMed := qInterp(hQ, 0, 3, jN, fN)
    rZlo := qInterp(hQ, 0, 2, jN, fN)
    rZhi := qInterp(hQ, 0, 4, jN, fN)
    rP := pctQ(tRng, qInterp(hQ, 0, 0, jN, fN), qInterp(hQ, 0, 1, jN, fN), rMed, qInterp(hQ, 0, 5, jN, fN), qInterp(hQ, 0, 6, jN, fN))
    nMed := qInterp(hQ, 1, 3, jN, fN)
    nZlo := qInterp(hQ, 1, 2, jN, fN)
    nZhi := qInterp(hQ, 1, 4, jN, fN)
    nP := pctQ(tNet, qInterp(hQ, 1, 0, jN, fN), qInterp(hQ, 1, 1, jN, fN), nMed, qInterp(hQ, 1, 5, jN, fN), qInterp(hQ, 1, 6, jN, fN))
    tmOK := clkTF and isWk and hasQ and jN <= 22
    sR := tmOK ? stTxt(tRng, rZlo, rZhi) : ""
    sN := tmOK ? stTxt(tNet, nZlo, nZhi) : ""
    dayMed := hasQ ? qAt(hQ, 0, 3, 22) : na
    dayP75 := hasQ ? qAt(hQ, 0, 5, 22) : na
    dayPts := dayMed / 100.0 * tO
    atrUse := rPts / atrD

    // ── live projection of today's final range (in %), with its band
    expPts := expMed / 100.0 * tO
    prjMed := na
    prjLo := na
    prjHi := na
    qShOK := false
    if not na(hQ)
        qShOK := hQ.size() >= 345
    if xOn and not na(xLog) and timeframe.isintraday and timeframe.in_seconds() <= 3600 and isWk and hasQ and qShOK
        float lrun = math.log(math.max(tRng, 1e-4))
        if jN > 22
            prjMed := tRng
            prjLo  := tRng
            prjHi  := tRng
        else if jN == 0
            prjMed := math.max(tRng, expMed)
            prjLo  := math.max(tRng, expLo)
            prjHi  := math.max(tRng, expHi)
        else
            float sh0 = hQ.get(322 + jN - 1)
            float sh1 = hQ.get(322 + jN)
            if not na(sh0) and not na(sh1)
                float sh = math.max(sh0 + (sh1 - sh0) * fN, 1e-3)
                float pj = lrun - math.log(sh)
                array<float> wLo = bandW ? PW25 : PW10
                array<float> cLo = bandW ? PC25 : PC10
                array<float> wHi = bandW ? PW75 : PW90
                array<float> cHi = bandW ? PC75 : PC90
                prjMed := math.exp(math.max(lrun, pj + pwI(PC50, jN, fN) + pwI(PW50, jN, fN) * (xLog - pj)))
                prjLo  := math.exp(math.max(lrun, pj + pwI(cLo, jN, fN) + pwI(wLo, jN, fN) * (xLog - pj)))
                prjHi  := math.exp(math.max(lrun, pj + pwI(cHi, jN, fN) + pwI(wHi, jN, fN) * (xLog - pj)))
    prjPts := prjMed / 100.0 * tO
    prjSt := na(prjMed) or na(xLog) ? "" : prjMed > expHi ? "Above" : prjMed < expLo ? "Below" : "Neutral"
    // today's drivers, with their multipliers on the expected range
    drvTx := ""
    drvMul := 1.0
    if not na(xLog)
        if nz(xIn) == 1
            drvTx += "inside ×" + str.tostring(math.exp(CF.get(6)), "0.00")
            drvMul *= math.exp(CF.get(6))
        if tDow >= 3 and tDow <= 6
            float wm = math.exp(CF.get(tDow + 4))
            drvTx += (drvTx == "" ? "" : " · ") + dn + " ×" + str.tostring(wm, "0.00")
            drvMul *= wm
        if cOpex
            drvTx += (drvTx == "" ? "" : " · ") + "opex ×" + str.tostring(math.exp(CF.get(11)), "0.00")
            drvMul *= math.exp(CF.get(11))
        if cTom
            drvTx += (drvTx == "" ? "" : " · ") + "turn of month ×" + str.tostring(math.exp(CF.get(12)), "0.00")
            drvMul *= math.exp(CF.get(12))
        if cPre
            drvTx += (drvTx == "" ? "" : " · ") + "pre-holiday ×" + str.tostring(math.exp(CF.get(13)), "0.00")
            drvMul *= math.exp(CF.get(13))
        if cPost
            drvTx += (drvTx == "" ? "" : " · ") + "post-holiday ×" + str.tostring(math.exp(CF.get(14)), "0.00")
            drvMul *= math.exp(CF.get(14))
        float mv = math.exp(CF.get(4) * math.max(-xR1v, 0) + CF.get(5) * math.max(xR1v, 0))
        if math.abs(mv - 1.0) >= 0.02
            drvTx += (drvTx == "" ? "" : " · ") + "yday " + sgn1(xR1v) + "% ×" + str.tostring(mv, "0.00")
            drvMul *= mv
    // chance today's high / low is already in: price must still travel to beat them, against the volatility left
    // (random-walk reflection: P(no new high) = 2Φ(distance ÷ σ left) − 1, σ left = KAPPA × expected range × √variance left)
    pHiIn := na
    pLoIn := na
    sigPts := na
    if xOn and xExt and not na(xLog) and timeframe.isintraday and timeframe.in_seconds() <= 3600 and isWk and tO > 0
        float vr = jN > 22 ? 0.0 : jN == 0 ? 1.0 - (1.0 - VRM.get(0)) * fN : VRM.get(jN - 1) + (VRM.get(jN) - VRM.get(jN - 1)) * fN
        if vr <= 1e-6
            pHiIn  := 1.0
            pLoIn  := 1.0
            sigPts := 0.0
        else
            float sg = KAPPA * math.exp(xLog) * math.sqrt(vr)
            pHiIn  := 2.0 * nCdf(100.0 * (tHi - close) / tO / sg) - 1.0
            pLoIn  := 2.0 * nCdf(100.0 * (close - tLo) / tO / sg) - 1.0
            sigPts := sg / 100.0 * tO

    // ══════════ Shared card data
    // weekday stats (full day, last nWk of each weekday)
    allR := valsAt(dRg, idxFor(dDw, 0, nWk * 5))
    medAllR := allR.size() > 0 ? allR.median() : na
    gLo := allR.size() > 0 ? allR.percentile_linear_interpolation(5) : na
    gHi := allR.size() > 0 ? allR.percentile_linear_interpolation(95) : na
    todayMult := na
    todayUp := na
    if isWk and not na(dRg)
        array<int> ixT = idxFor(dDw, tDow, nWk)
        array<float> vT = valsAt(dRg, ixT)
        array<float> nT = valsAt(dNt, ixT)
        if vT.size() >= 3 and medAllR > 0
            todayMult := vT.median() / medAllR
            int upT = 0
            for x in nT
                if x > 0
                    upT += 1
            todayUp := 100.0 * upT / nT.size()
    // month to date (net, roll-free) and this month's history
    moNet := moNetLive
    mvC := valsAt(jNet, moIdx(jK, curMo, monYrs))
    mvMed := mvC.size() >= 3 ? mvC.median() : na
    mvRk := rankOf(mvC, moNet)
    // this hour
    hNowET := hour(time, TZ)
    hShH := nh > 0 ? 100.0 * cH.get(hNowET) / nh : na
    hShL := nh > 0 ? 100.0 * cL.get(hNowET) / nh : na


// ══════════ Range clock
if barstate.islast and (clkOn and hasQ)
    int   tfMs = timeframe.in_seconds() * 1000
    int   t0  = tdOpen
    int   t1  = tdOpen + 23 * HOUR - tfMs
    int   tP  = tdOpen - tfMs
    float yMx = clkR ? math.max(qAt(hQ, 0, 6, 22), tRng, nz(expHi), nz(prjHi)) : tNet
    float yMn = clkR ? 0.0 : tNet
    if not clkR
        for j = 0 to 22
            yMx := math.max(yMx, qAt(hQ, 1, 6, j))
            yMn := math.min(yMn, qAt(hQ, 1, 0, j))
    float H = math.max(yMx - yMn, 1e-6)
    if kBands
        pP.push(bandPoly(hQ, mSel, 6, 0, tP, color.new(colBand, 86)))
        pP.push(bandPoly(hQ, mSel, 5, 1, tP, color.new(colBand, 74)))
    pP.push(bandPoly(hQ, mSel, 4, 2, tP, cZone))
    // typical (median) path: the chart's text colour by default, or the colour picked in the inputs
    pP.push(pathPoly(hQ, mSel, 3, tP, medC, 2, line.style_solid))
    if not clkR
        pN.push(line.new(t0, 0.0, t1, 0.0, xloc = xloc.bar_time, color = color.new(pFg, 55), style = line.style_dotted, width = 1))
    // now marker
    pN.push(line.new(time, yMn - 0.02 * H, time, yMx, xloc = xloc.bar_time, color = color.new(colNow, 55), style = line.style_dotted, width = 1))
    // expected range for today (band + median) and the live projection (needle + ◆) at the session end
    if clkR and not na(xLog)
        int xa = t1 - 40 * 60000
        pB.push(box.new(xa, expHi, t1, expLo, xloc = xloc.bar_time, border_color = color.new(colExp, 45), border_width = 1, bgcolor = color.new(colExp, 80)))
        pN.push(line.new(xa, expMed, t1, expMed, xloc = xloc.bar_time, color = colExp, width = 2))
        if not na(prjMed)
            int xm = t1 - 20 * 60000
            pN.push(line.new(xm, prjLo, xm, prjHi, xloc = xloc.bar_time, color = colExp, width = 3))
            pL.push(label.new(xm, prjMed, "◆", xloc = xloc.bar_time, color = #00000000, style = label.style_label_center, textcolor = colExp, size = size.small, tooltip = "Projected day range " + f2(prjMed) + "% ≈ " + str.tostring(prjPts, "0") + " pts (" + bandTx + " " + str.tostring(prjLo / 100.0 * tO, "0") + "–" + str.tostring(prjHi / 100.0 * tO, "0") + ")"))

    // hour-of-high/low histogram on the same time axis
    float h1 = yMn - 0.04 * H
    float h0 = yMn - 0.26 * H
    if kHist and nh >= 5
        for j = 0 to 22
            int h  = (18 + j) % 24
            int ts = t0 + j * HOUR
            int kH = cH.get(h)
            int kL = cL.get(h)
            if kH > 0
                pB.push(box.new(ts, h0 + (h1 - h0) * kH / mx, ts + 1800000, h0, xloc = xloc.bar_time, border_color = color.new(colHi, 100), bgcolor = color.from_gradient(kH, 0, mx, color.new(colHi, 85), color.new(colHi, 10))))
            if kL > 0
                pB.push(box.new(ts + 1800000, h0 + (h1 - h0) * kL / mx, ts + HOUR, h0, xloc = xloc.bar_time, border_color = color.new(colLo, 100), bgcolor = color.from_gradient(kL, 0, mx, color.new(colLo, 85), color.new(colLo, 10))))

    // session strip
    if kSess
        float s1 = yMn - 0.30 * H
        float s0 = yMn - 0.38 * H
        pB.push(box.new(t0 + 2 * HOUR, s1, t0 + 6 * HOUR, s0, xloc = xloc.bar_time, border_color = cBd, bgcolor = color.new(colBand, 75), text = mob ? "AS" : "Asia", text_color = pFg, text_size = size.tiny))
        pB.push(box.new(t0 + 8 * HOUR, s1, t0 + 11 * HOUR, s0, xloc = xloc.bar_time, border_color = cBd, bgcolor = color.new(colBand, 65), text = mob ? "LDN" : "London", text_color = pFg, text_size = size.tiny))
        pB.push(box.new(t0 + 15 * HOUR + 1800000, s1, t0 + 17 * HOUR, s0, xloc = xloc.bar_time, border_color = cBd, bgcolor = color.new(colNow, 70), text = mob ? "AM" : "NY AM", text_color = pFg, text_size = size.tiny))
        pB.push(box.new(t0 + 17 * HOUR + 1800000, s1, t0 + 19 * HOUR, s0, xloc = xloc.bar_time, border_color = cBd, bgcolor = color.new(colBand, 80), text = mob ? "L" : "Lunch", text_color = pFg, text_size = size.tiny))
        pB.push(box.new(t0 + 19 * HOUR + 1800000, s1, t0 + 22 * HOUR, s0, xloc = xloc.bar_time, border_color = cBd, bgcolor = color.new(colBand, 65), text = mob ? "PM" : "NY PM", text_color = pFg, text_size = size.tiny))

    // labels — one per spot so nothing stacks: the live point (value, percentile, status, typical by now), the
    // session end (typical day with P25 / P75), and one legend line under the session strip
    if kLbl
        float vNow = clkR ? tRng : tNet
        float mNow = clkR ? rMed : nMed
        string sNow = clkR ? sR : sN
        string vTxt = clkR ? f2(tRng) + "%" + (mob ? "" : " · " + str.tostring(rPts, "0") + " pts") : sgn(tNet) + "%" + (mob ? "" : " · " + sgn0(nPts) + " pts")
        string mTxt = na(mNow) ? "" : (mob ? " · typ " : " · typical by now ") + (clkR ? f2(mNow) : sgn(mNow)) + "%"
        string tNow = vTxt + " · " + pTxt(clkR ? rP : nP) + "\n" + pill(sNow) + mTxt + (mob ? "" : " · " + stampS)
        pL.push(label.new(time, vNow, tNow, xloc = xloc.bar_time, color = #00000000, style = label.style_label_left, textcolor = liveC, size = szE, textalign = text.align_left))

        int   mE   = clkR ? 0 : 1
        float eMed = qAt(hQ, mE, 3, 22)
        float eTop = qAt(hQ, mE, 6, 22)
        float eBot = qAt(hQ, mE, 0, 22)
        string xTx = na(xLog) or not clkR ? "" : mob ? "exp " + str.tostring(expPts, "0") + (na(prjMed) ? "" : "\nproj " + str.tostring(prjPts, "0")) + " pts" : "expected " + f2(expMed) + "% ≈ " + str.tostring(expPts, "0") + " pts (" + bandTx + " " + str.tostring(expLo / 100.0 * tO, "0") + "–" + str.tostring(expHi / 100.0 * tO, "0") + ")" + (na(prjMed) ? "" : "\nprojected ≈ " + str.tostring(prjPts, "0") + " pts (" + str.tostring(prjLo / 100.0 * tO, "0") + "–" + str.tostring(prjHi / 100.0 * tO, "0") + ")")
        string eTx = xTx != "" ? xTx : mob ? (clkR ? "typ day " + f2(eMed) + "%\n≈ " + str.tostring(eMed / 100.0 * tO, "0") + " pts" : "typ close\n" + sgn(eMed) + "%") : (clkR ? "typical day " + f2(eMed) + "% ≈ " + str.tostring(eMed / 100.0 * tO, "0") + " pts" : "typical close " + sgn(eMed) + "%") + ("\nP25 " + (clkR ? f2(qAt(hQ, mE, 1, 22)) : sgn(qAt(hQ, mE, 1, 22))) + "% · P75 " + (clkR ? f2(qAt(hQ, mE, 5, 22)) : sgn(qAt(hQ, mE, 5, 22))) + "%")
        // within 3 hours of the close the live label is near the end label: lift it above the bands, or drop it
        // below them when today is already above the 90th percentile
        bool  nearEnd = t1 - time < math.max(3 * HOUR, (mob ? 30 : 50) * tfMs)
        float aMed    = xTx != "" ? expMed : eMed
        float aTop    = xTx != "" ? math.max(eTop, expHi, nz(prjHi)) : eTop
        float aBot    = xTx != "" ? math.min(eBot, expLo) : eBot
        bool  goLow   = nearEnd and vNow >= aTop - 0.08 * H
        float eY      = not nearEnd ? aMed : goLow ? aBot : aTop
        string eSt    = not nearEnd ? label.style_label_left : goLow ? label.style_label_upper_left : label.style_label_lower_left
        pL.push(label.new(t1, eY, eTx, xloc = xloc.bar_time, color = #00000000, style = eSt, textcolor = xTx != "" ? colExp : medLbl, size = size.tiny, textalign = text.align_left))

        string lg = mob ? (clkR ? "RANGE" : "NET") + " · " + str.tostring(nB) + (baseAll ? "d" : " " + dn + "s") + " · zone " + bandCI : (clkR ? "RANGE" : "NET MOVE") + " CLOCK · typical path from the " + bl + " · neutral zone " + bandCI + (kHist and nh >= 5 ? " · bars: hour of the high ▮ / low ▮, last " + str.tostring(nh) + " " + who : "")
        float lgY = yMn - (kSess ? 0.40 : kHist ? 0.28 : 0.06) * H
        pL.push(label.new(time, lgY, lg, xloc = xloc.bar_time, color = #00000000, style = label.style_label_upper_right, textcolor = color.new(pFg, 40), size = size.tiny, textalign = text.align_right))

// ══════════ Distributions (weekday | hour | month columns, bar-anchored)
if barstate.islast and (view == "Distributions")
    bool drawWk = drawWkI and not na(dRg)
    bool drawHr = drawHrI and not na(hHi)
    bool drawMo = drawMoI and hasMo
    bool isR    = metric == "Range %"
    bool mR     = monMet == "Range %"
    int nCol = showAll ? 6 : 5
    int w    = math.max(1, math.floor(gapE / 4))
    int hb   = math.max(1, math.floor((hrWE - 1) / 2))
    int mw   = math.max(1, math.floor(mGapE / 4))
    int cur  = bar_index - 2
    int xR   = cur - w
    int xL   = xR - (nCol - 1) * gapE
    if drawWk
        cur := xL - w - gapE
    int x0   = cur - 23 * hrWE + 1
    if drawHr
        cur := x0 - gapE
    int xM0  = cur - mw - 11 * mGapE

    array<float> srcW = isR ? dRg : dNt
    float tVal   = isR ? tRng : tNet
    array<float> allV = array.new<float>()
    float medAll = na
    float yLo = na
    float yHi = na
    if drawWk
        allV := valsAt(srcW, idxFor(dDw, 0, nWk * 5))
        medAll := allV.size() > 0 ? allV.median() : na
        for c = 0 to nCol - 1
            int wd = c < 5 ? c + 2 : 0
            array<float> v = valsAt(srcW, idxFor(dDw, wd, wd == 0 ? nWk * 5 : nWk))
            if v.size() >= 3
                float lo = dotsW and wd != 0 ? v.min() : v.percentile_linear_interpolation(10)
                float hi = dotsW and wd != 0 ? v.max() : v.percentile_linear_interpolation(90)
                yLo := na(yLo) ? lo : math.min(yLo, lo)
                yHi := na(yHi) ? hi : math.max(yHi, hi)
        if isWk and not na(tVal) and not na(yLo)
            yLo := math.min(yLo, tVal)
            yHi := math.max(yHi, tVal)

    float moNow = na
    float mLo   = na
    float mHi   = na
    if drawMo
        if uCurB > 0
            moNow := mR ? moRngLive : moNetLive
        array<float> mSrc0 = mR ? jRng : jNet
        for m = 1 to 12
            array<float> v = valsAt(mSrc0, moIdx(jK, m, monYrs))
            if v.size() >= 3
                float lo = dotsM ? v.min() : v.percentile_linear_interpolation(10)
                float hi = dotsM ? v.max() : v.percentile_linear_interpolation(90)
                mLo := na(mLo) ? lo : math.min(mLo, lo)
                mHi := na(mHi) ? hi : math.max(mHi, hi)
        if not na(moNow) and not na(mLo)
            mLo := math.min(mLo, moNow)
            mHi := math.max(mHi, moNow)
        if not mR and not na(mLo)
            mLo := math.min(mLo, 0.0)
            mHi := math.max(mHi, 0.0)

    if na(yLo)
        if drawHr and nh >= 5
            yLo := 0.0
            yHi := 100.0 * mx / nh
        else if drawMo
            yLo := mLo
            yHi := mHi

    if not na(yLo) and yHi > yLo
        float pad = 0.06 * (yHi - yLo)
        // approximate height of one text line in price units, used to stagger labels so neighbours never collide
        float Lh  = (yHi - yLo) * (szE == size.tiny ? 0.075 : szE == size.small ? 0.09 : 0.11)

        if drawWk
            int   todayX = na
            float rkW    = na
            float medW   = na
            int   nW     = 0
            for c = 0 to nCol - 1
                int wd = c < 5 ? c + 2 : 0
                array<int> ix = idxFor(dDw, wd, wd == 0 ? nWk * 5 : nWk)
                array<float> v = valsAt(srcW, ix)
                int n = v.size()
                if n >= 3
                    int   xc   = xL + c * gapE
                    float med  = v.median()
                    float q1   = v.percentile_linear_interpolation(25)
                    float q3   = v.percentile_linear_interpolation(75)
                    float p10  = v.percentile_linear_interpolation(10)
                    float p90  = v.percentile_linear_interpolation(90)
                    float mult = isR and medAll > 0 ? med / medAll : na
                    bool  isT  = isWk and wd == tDow
                    color cc   = wd == 0 ? colAll : not isR ? colNorm : mult >= wideX ? colWide : mult <= narX ? colNar : colNorm
                    pN.push(line.new(xc, p10, xc, p90, color = color.new(cc, 40), width = 1))
                    pB.push(box.new(xc - w, q3, xc + w, q1, border_color = isT ? colNow : cc, border_width = isT ? 2 : 1, bgcolor = color.new(cc, 80)))
                    pN.push(line.new(xc - w - 1, med, xc + w + 1, med, color = cc, width = 3))
                    int ups = 0
                    for j = 0 to n - 1
                        int i = ix.get(j)
                        if dNt.get(i) > 0
                            ups += 1
                        if dotsW and wd != 0
                            int   tr  = int(75.0 * (n - 1 - j) / math.max(1, n - 1))
                            color dc  = color.new(dNt.get(i) >= 0 ? colUp : colDn, tr)
                            string tip = str.format_time(dTt.get(i), "EEE MM/dd/yy", "UTC") + "\nrange " + f2(dRg.get(i)) + "% (" + str.tostring(dPt.get(i), "0") + " pts)\nnet " + sgn(dNt.get(i)) + "%"
                            pL.push(label.new(xc - w + (j % (2 * w + 1)), v.get(j), "•", color = #00000000, style = label.style_label_center, textcolor = dc, size = szE, tooltip = tip))
                    string nm  = wd == 0 ? "All" : dayName(wd)
                    string stD = isR ? nm + "\n" + f2(med) + "%" + (wd == 0 ? "\n " : "\n×" + str.tostring(mult, "0.00")) : nm + "\nup " + str.tostring(100.0 * ups / n, "0") + "%\n" + sgn(med) + "%"
                    string stM = isR ? nm + "\n" + str.tostring(med, "0.0") : nm + "\n" + str.tostring(100.0 * ups / n, "0") + "%"
                    string stT = (wd == 0 ? "All days" : dayName(wd)) + " · median " + (isR ? f2(med) : sgn(med)) + "%" + (isR and wd != 0 ? " · ×" + str.tostring(mult, "0.00") + " vs all" : "") + " · up " + str.tostring(100.0 * ups / n, "0") + "% · n " + str.tostring(n)
                    float yS = yLo - pad - (c % 2) * (mob ? 2 : 3) * Lh
                    pL.push(label.new(xc, yS, mob ? stM : stD, color = #00000000, style = label.style_label_up, textcolor = isT ? colNow : cc, size = szE, tooltip = stT))
                    if isT and not na(tVal)
                        todayX := xc
                        rkW    := rankOf(v, tVal)
                        medW   := med
                        nW     := n
                        pL.push(label.new(xc, tVal, "◆", color = #00000000, style = label.style_label_center, textcolor = colNow, size = szE))
            string hdW = "DAY OF WEEK · " + (isR ? "range" : "net") + " %" + (mob ? "" : " · last " + str.tostring(nWk))
            pL.push(label.new(xL - w, yHi + pad, hdW, color = #00000000, style = label.style_label_lower_left, textcolor = chart.fg_color, size = szE, tooltip = (isR ? "Range" : "Net move") + " as % of the daily open, last " + str.tostring(nWk) + " of each weekday, full trading day"))
            if not na(todayX)
                int xEnd = xR + w + 2
                pN.push(line.new(todayX, tVal, xEnd, tVal, color = colNow, style = line.style_dotted, width = 1))
                float rkA  = rankOf(allV, tVal)
                string txD = isR ? "Today " + dn + " · " + f2(tRng) + "% (" + str.tostring(rPts, "0") + " pts)\nP" + str.tostring(rkW, "0") + " of " + str.tostring(nW) + " " + dn + " · P" + str.tostring(rkA, "0") + " of all days\n" + dn + " median " + f2(medW) + "% ≈ " + str.tostring(medW / 100.0 * tO, "0") + " pts · " + stamp : "Today " + dn + " · " + sgn(tNet) + "%\nP" + str.tostring(rkW, "0") + " of " + str.tostring(nW) + " " + dn + " · P" + str.tostring(rkA, "0") + " of all days · " + stamp
                string txM = (isR ? f2(tRng) : sgn(tNet)) + "% · P" + str.tostring(rkW, "0") + "\n" + stampS
                pL.push(label.new(xEnd, tVal, mob ? txM : txD, color = #00000000, style = label.style_label_left, textcolor = colNow, size = szE, textalign = text.align_left))

        if drawHr and nh >= 5
            float hgt = yHi - yLo
            for j = 0 to 22
                int h  = (18 + j) % 24
                int xi = x0 + j * hrWE
                int kH = cH.get(h)
                int kL = cL.get(h)
                if kH > 0
                    pB.push(box.new(xi, yLo + hgt * kH / mx, xi + hb, yLo, border_color = colHi, bgcolor = color.new(colHi, 35)))
                if kL > 0
                    pB.push(box.new(xi + hb, yLo + hgt * kL / mx, xi + 2 * hb, yLo, border_color = colLo, bgcolor = color.new(colLo, 35)))
                if mob
                    if h % 6 == 0
                        pL.push(label.new(xi + hb, yLo - pad, str.tostring(h, "00"), color = #00000000, style = label.style_label_up, textcolor = chart.fg_color, size = size.tiny))
                else
                    string tip = str.tostring(h, "00") + ":00 ET\nday's high here " + str.tostring(100.0 * kH / nh, "0") + "%\nday's low here " + str.tostring(100.0 * kL / nh, "0") + "%\nof the last " + str.tostring(nh) + " " + who
                    pL.push(label.new(xi + hb, yLo - pad, h % 3 == 0 ? str.tostring(h, "00") : "·", color = #00000000, style = label.style_label_up, textcolor = chart.fg_color, size = size.tiny, tooltip = tip))
            string hdH = "HOUR OF HIGH ▮ / LOW ▮" + (mob ? "" : " · " + str.tostring(nh) + " " + who)
            pL.push(label.new(x0, yHi + pad + (drawWk and drawMo ? Lh : 0.0), hdH, color = #00000000, style = label.style_label_lower_left, textcolor = chart.fg_color, size = szE, tooltip = "Hour (ET) in which the trading day set its high (left bar) and low (right bar), last " + str.tostring(nh) + " " + who))
            if timeframe.isintraday and isWk
                if jN <= 22
                    int xn = x0 + jN * hrWE + hb
                    pN.push(line.new(xn, yLo, xn, yHi, color = colNow, style = line.style_dotted, width = 1))
                if timeframe.in_seconds() <= 3600 and not na(tHhr)
                    int jh = (tHhr - 18 + 24) % 24
                    int jl = (tLhr - 18 + 24) % 24
                    string pH  = str.tostring(100.0 * cH.get(tHhr) / nh, "0") + "%"
                    string pLo = str.tostring(100.0 * cL.get(tLhr) / nh, "0") + "%"
                    if jh <= 22
                        pL.push(label.new(x0 + jh * hrWE, yLo + hgt * cH.get(tHhr) / mx, mob ? "H " + pH : "H", color = #00000000, style = label.style_label_down, textcolor = colNow, size = szE, tooltip = "Today's high so far: " + str.tostring(tHhr, "00") + ":00 hour · " + pH + " of the last " + str.tostring(nh) + " " + who + " set their high here · " + stamp))
                    if jl <= 22
                        pL.push(label.new(x0 + jl * hrWE + 2 * hb, yLo + hgt * cL.get(tLhr) / mx, mob ? "L " + pLo : "L", color = #00000000, style = label.style_label_down, textcolor = colNow, size = szE, tooltip = "Today's low so far: " + str.tostring(tLhr, "00") + ":00 hour · " + pLo + " of the last " + str.tostring(nh) + " " + who + " set their low here · " + stamp))

        if drawMo and not na(mLo) and mHi > mLo
            array<float> mSrc = mR ? jRng : jNet
            array<float> allM = lastN(mSrc, monYrs * 12)
            float medAllM = allM.size() > 0 ? allM.median() : na
            float moRk  = na
            float moMed = na
            int   moN   = 0
            int   moUp  = 0
            for m = 1 to 12
                array<int> ix = moIdx(jK, m, monYrs)
                array<float> v = valsAt(mSrc, ix)
                int n = v.size()
                if n >= 3
                    int   xc   = xM0 + (m - 1) * mGapE
                    float med  = v.median()
                    float q1   = v.percentile_linear_interpolation(25)
                    float q3   = v.percentile_linear_interpolation(75)
                    float p10  = v.percentile_linear_interpolation(10)
                    float p90  = v.percentile_linear_interpolation(90)
                    float mult = mR and medAllM > 0 ? med / medAllM : na
                    float dpp  = med - medAllM
                    bool  isC  = m == curMo
                    color cc   = mR ? (mult >= wideX ? colWide : mult <= narX ? colNar : colNorm) : (dpp >= monPP ? colUp : dpp <= -monPP ? colDn : colNorm)
                    pN.push(line.new(xc, mapY(p10, mLo, mHi, yLo, yHi), xc, mapY(p90, mLo, mHi, yLo, yHi), color = color.new(cc, 40), width = 1))
                    pB.push(box.new(xc - mw, mapY(q3, mLo, mHi, yLo, yHi), xc + mw, mapY(q1, mLo, mHi, yLo, yHi), border_color = isC ? colNow : cc, border_width = isC ? 2 : 1, bgcolor = color.new(cc, 80)))
                    pN.push(line.new(xc - mw - 1, mapY(med, mLo, mHi, yLo, yHi), xc + mw + 1, mapY(med, mLo, mHi, yLo, yHi), color = cc, width = 3))
                    int ups = 0
                    for j = 0 to n - 1
                        int i = ix.get(j)
                        if jNet.get(i) > 0
                            ups += 1
                        if dotsM
                            int   tr  = int(75.0 * (n - 1 - j) / math.max(1, n - 1))
                            color dc  = color.new(jNet.get(i) >= 0 ? colUp : colDn, tr)
                            string tip = str.format_time(jK.get(i), "MMM yyyy", "UTC") + "\nnet " + sgn(jNet.get(i)) + "% (" + str.tostring(jPts.get(i), "0.00") + " pts)\nrange " + f2(jRng.get(i)) + "%"
                            pL.push(label.new(xc - mw + (j % (2 * mw + 1)), mapY(v.get(j), mLo, mHi, yLo, yHi), "•", color = #00000000, style = label.style_label_center, textcolor = dc, size = szE, tooltip = tip))
                    string stD = mR ? moName(m) + "\n" + f2(med) + "%\n×" + str.tostring(mult, "0.00") : moName(m) + "\n" + sgn(med) + "%\nup " + str.tostring(100.0 * ups / n, "0") + "%"
                    string stM = moName(m) + "\n" + (mR ? str.tostring(med, "0.0") : sgn1(med))
                    string stT = moName(m) + " · median " + (mR ? f2(med) : sgn(med)) + "% · up " + str.tostring(100.0 * ups / n, "0") + "% · n " + str.tostring(n)
                    float yS = yLo - pad - ((m - 1) % 2) * (mob ? 2 : 3) * Lh
                    pL.push(label.new(xc, yS, mob ? stM : stD, color = #00000000, style = label.style_label_up, textcolor = isC ? colNow : cc, size = szE, tooltip = stT))
                    if isC and not na(moNow)
                        moRk  := rankOf(v, moNow)
                        moMed := med
                        moN   := n
                        moUp  := ups
                        pL.push(label.new(xc, mapY(moNow, mLo, mHi, yLo, yHi), "◆", color = #00000000, style = label.style_label_center, textcolor = colNow, size = szE, tooltip = moName(m) + " to date " + (mR ? f2(moNow) : sgn(moNow)) + "% · " + stamp))
            if not mR
                float y0 = mapY(0.0, mLo, mHi, yLo, yHi)
                pN.push(line.new(xM0 - mw - 1, y0, xM0 + 11 * mGapE + mw + 1, y0, color = color.new(chart.fg_color, 60), style = line.style_dotted, width = 1))
            string nowD = na(moRk) ? "" : "\n" + moName(curMo) + " to date " + (mR ? f2(moNow) : sgn(moNow)) + "% · P" + str.tostring(moRk, "0") + " of " + str.tostring(moN) + " " + moName(curMo) + "s · median " + (mR ? f2(moMed) : sgn(moMed)) + "%" + (mR ? "" : " · up " + str.tostring(100.0 * moUp / moN, "0") + "%") + " · " + stamp
            string nowM = na(moRk) ? "" : "\n" + moName(curMo) + " " + (mR ? f2(moNow) : sgn(moNow)) + "% · P" + str.tostring(moRk, "0") + " · med " + (mR ? f2(moMed) : sgn(moMed)) + "%"
            string hdM  = "MONTHS · " + (mR ? "range" : "net") + " %" + (mob ? "" : " · " + str.tostring(monYrs) + " yrs" + (drawWk ? " · scaled" : ""))
            pL.push(label.new(xM0 - mw, yHi + pad, hdM, color = #00000000, style = label.style_label_lower_left, textcolor = chart.fg_color, size = szE, tooltip = (mR ? "Range" : "Net move") + " as % of the prior month close, roll gaps removed, last " + str.tostring(monYrs) + " years" + (drawWk ? ", scaled to fit beside the weekdays" : "") + nowD))

// ══════════ Weekday card
if barstate.islast and (cWk and not na(dRg) and not na(tW))
    table T = tW
    tcB(T, 0, 0 + offW, mob ? "WEEKDAYS · last " + str.tostring(nWk) : "WEEKDAYS · range % of open · last " + str.tostring(nWk) + " each", colNow, cHd, cSz)
    if not mob
        tc(T, 0, 1 + offW, "Day", cMu, cBg, cSz)
        tc(T, 1, 1 + offW, "Range", cMu, cBg, cSz, text.align_right)
        tc(T, 2, 1 + offW, "×All", cMu, cBg, cSz, text.align_right)
        tc(T, 3, 1 + offW, "Up", cMu, cBg, cSz, text.align_right)
        tc(T, 4, 1 + offW, "Net", cMu, cBg, cSz, text.align_right)
        tc(T, 5, 1 + offW, "Shape", cMu, cBg, cSz, text.align_center, "Distribution of the sample's daily range, low to high, 8 bins")
        tc(T, 6, 1 + offW, "n", cMu, cBg, cSz, text.align_right)
    else
        tc(T, 0, 1 + offW, "Day", cMu, cBg, cSz)
        tc(T, 1, 1 + offW, "Rng", cMu, cBg, cSz, text.align_right)
        tc(T, 2, 1 + offW, "×", cMu, cBg, cSz, text.align_right)
        tc(T, 3, 1 + offW, "Up", cMu, cBg, cSz, text.align_right)
    for c = 0 to 5
        int wd = c < 5 ? c + 2 : 0
        array<int> ix = idxFor(dDw, wd, wd == 0 ? nWk * 5 : nWk)
        array<float> vr = valsAt(dRg, ix)
        array<float> vn = valsAt(dNt, ix)
        int n = vr.size()
        int r = c + 2
        if n >= 3
            float med  = vr.median()
            float mult = medAllR > 0 ? med / medAllR : na
            int ups = 0
            for x in vn
                if x > 0
                    ups += 1
            float up = 100.0 * ups / n
            bool isT = isWk and wd == tDow
            color mBg = wd == 0 ? cHd : color.from_gradient(mult, narX - 0.10, wideX + 0.10, color.new(colNar, 25), color.new(colWide, 25))
            color uBg = color.from_gradient(up, 35, 65, color.new(colDn, 35), color.new(colUp, 35))
            string nm = wd == 0 ? "All" : dayName(wd)
            if isT
                tcB(T, 0, r + offW, "▸" + nm, #131722, colNow, cSz)
            else
                tc(T, 0, r + offW, " " + nm, wd == 0 ? cSub : cTx, cBg, cSz)
            tc(T, 1, r + offW, f2(med) + (mob ? "" : "%"), cTx, cBg, cSz, text.align_right)
            tc(T, 2, r + offW, wd == 0 ? "1.00" : str.tostring(mult, "0.00"), wd == 0 ? cSub : #ffffff, mBg, cSz, text.align_right)
            tc(T, 3, r + offW, str.tostring(up, "0") + "%", #ffffff, uBg, cSz, text.align_right)
            if not mob
                tc(T, 4, r + offW, sgn(vn.median()) + "%", vn.median() >= 0 ? colUp : colDn, cBg, cSz, text.align_right)
                tc(T, 5, r + offW, sparkDist(vr, gLo, gHi), isT ? colNow : cSub, cBg, cSz, text.align_left)
                tc(T, 6, r + offW, str.tostring(n), cMu, cBg, cSz, text.align_right)

// ══════════ Month card
if barstate.islast and (cMo and hasMo and not na(tM))
    table T = tM
    array<float> allM2 = lastN(jNet, monYrs * 12)
    float medAllM2 = allM2.size() > 0 ? allM2.median() : na
    tcB(T, 0, 0 + offM, mob ? "MONTHS · net % · " + str.tostring(monYrs) + " yrs" + (na(moNet) ? "" : " · " + moName(curMo) + " " + sgn(moNet) + "%") : "MONTHS · net % · last " + str.tostring(monYrs) + " yrs · roll-free" + (na(moNet) ? "" : " · " + moName(curMo) + " to date " + sgn(moNet) + "%"), colNow, cHd, cSz)
    tc(T, 0, 1 + offM, "", cMu, cBg, cSz)
    tc(T, 0, 2 + offM, "Med", cMu, cBg, cSz)
    if not mob
        tc(T, 0, 3 + offM, "Up", cMu, cBg, cSz)
        tc(T, 0, 4 + offM, "Now", cMu, cBg, cSz)
    for m = 1 to 12
        array<int> ix = moIdx(jK, m, monYrs)
        array<float> v = valsAt(jNet, ix)
        int n = v.size()
        bool isC = m == curMo
        if isC
            tcB(T, m, 1 + offM, moName(m), #131722, colNow, cSz, text.align_center)
        else
            tc(T, m, 1 + offM, moName(m), cSub, cBg, cSz, text.align_center)
        if n >= 3
            float med = v.median()
            int ups = 0
            for x in v
                if x > 0
                    ups += 1
            color mBg = color.from_gradient(med - medAllM2, -2.0, 2.0, color.new(colDn, 20), color.new(colUp, 20))
            string tipM = moName(m) + " · median " + sgn(med) + "% · up " + str.tostring(100.0 * ups / n, "0") + "% of " + str.tostring(n) + " · all-months median " + sgn(medAllM2) + "%"
            tc(T, m, 2 + offM, sgn1(med), #ffffff, mBg, cSz, text.align_center, tipM)
            if not mob
                tc(T, m, 3 + offM, str.tostring(100.0 * ups / n, "0"), cSub, cBg, cSz, text.align_center)
                tc(T, m, 4 + offM, isC and not na(moNet) ? sgn1(moNet) : "", isC ? colNow : cMu, cBg, cSz, text.align_center)

// ══════════ Hours card
if barstate.islast and (cHr and nh >= 5 and not na(tH))
    table T = tH
    if mob
        string sH = ""
        string sL = ""
        string sM = ""
        for j = 0 to 22
            int h = (18 + j) % 24
            sH += cH.get(h) == 0 ? " " : BLK.get(math.min(7, int(math.floor(cH.get(h) * 7.0 / mx))))
            sL += cL.get(h) == 0 ? " " : BLK.get(math.min(7, int(math.floor(cL.get(h) * 7.0 / mx))))
            sM += h == hNowET ? "▲" : " "
        tcB(T, 0, 0 + offH, "HOURS · " + str.tostring(nh) + " " + who, colNow, cHd, cSz)
        tc(T, 0, 1 + offH, "H", colHi, cBg, cSz)
        tc(T, 1, 1 + offH, sH, colHi, cBg, cSz)
        tc(T, 0, 2 + offH, "L", colLo, cBg, cSz)
        tc(T, 1, 2 + offH, sL, colLo, cBg, cSz)
        tc(T, 0, 3 + offH, "", cMu, cBg, cSz)
        tc(T, 1, 3 + offH, sM, colNow, cBg, cSz)
    else
        tcB(T, 0, 0 + offH, "HOUR OF THE DAY'S HIGH / LOW · ET · last " + str.tostring(nh) + " " + who, colNow, cHd, cSz)
        tc(T, 0, 1 + offH, "", cMu, cBg, cSz)
        tc(T, 0, 2 + offH, "High", colHi, cBg, cSz)
        tc(T, 0, 3 + offH, "Low", colLo, cBg, cSz)
        tc(T, 0, 4 + offH, "", cMu, cBg, cSz)
        for j = 0 to 22
            int h = (18 + j) % 24
            bool isNow = h == hNowET and timeframe.isintraday
            float ph = 100.0 * cH.get(h) / nh
            float pl = 100.0 * cL.get(h) / nh
            tc(T, j + 1, 1 + offH, str.tostring(h, "00"), isNow ? colNow : cMu, cBg, cSz, text.align_center)
            tc(T, j + 1, 2 + offH, ph >= 5 ? str.tostring(ph, "0") : "", #ffffff, color.from_gradient(cH.get(h), 0, mx, color.new(colHi, 95), color.new(colHi, 10)), cSz, text.align_center, str.tostring(h, "00") + ":00 ET · set the day's high on " + str.tostring(ph, "0") + "% of days")
            tc(T, j + 1, 3 + offH, pl >= 5 ? str.tostring(pl, "0") : "", #ffffff, color.from_gradient(cL.get(h), 0, mx, color.new(colLo, 95), color.new(colLo, 10)), cSz, text.align_center, str.tostring(h, "00") + ":00 ET · set the day's low on " + str.tostring(pl, "0") + "% of days")
            tc(T, j + 1, 4 + offH, isNow ? "▲" : "", colNow, cBg, cSz, text.align_center)

// ══════════ Status card
if barstate.islast and (showDash and not na(tS))
    table T = tS
    string live = barstate.isrealtime ? (beat % 2 == 0 ? "●" : "○") : "◆"
    color rUpC = colWide
    color rDnC = colNar
    color sRbg = sR == "Above" ? color.new(rUpC, 10) : sR == "Below" ? color.new(rDnC, 10) : sR == "Neutral" ? colNeu : cHd
    color sNbg = sN == "Above" ? color.new(colUp, 10) : sN == "Below" ? color.new(colDn, 10) : sN == "Neutral" ? colNeu : cHd
    color sRfg = sR == "Neutral" ? #131722 : sR == "" ? cSub : #ffffff
    color sNfg = sN == "Neutral" ? #131722 : sN == "" ? cSub : #ffffff
    color sPbg = prjSt == "Above" ? color.new(rUpC, 10) : prjSt == "Below" ? color.new(rDnC, 10) : prjSt == "Neutral" ? colNeu : cHd
    color sPfg = prjSt == "Neutral" ? #131722 : prjSt == "" ? cSub : #ffffff
    string tipR = "Range so far vs the same time of day on the " + bl + ". Neutral = inside the " + bandCI + " band around the median."
    string tipN = "Net move from the 18:00 open vs the same time of day on the " + bl + ". Neutral = inside the " + bandCI + " band around the median."
    bool   hasX = xOn and not na(xLog)
    float  refPts = hasX ? expPts : dayPts
    string toGo = na(refPts) ? "—" : rPts >= refPts ? (hasX ? "✓ expected reached" : "✓ typical day reached") : "+" + str.tostring(refPts - rPts, "0") + (hasX ? " pts to expected" : " pts to typical")
    string tipX = "Expected range for today (" + mktR + " model): last 1 / 5 / 22 days' ranges anchored to the past year, yesterday's move, inside day, holidays, opex Friday, turn of month. " + bandTx + " band. Typical of the " + bl + ": " + (na(dayMed) ? "—" : f2(dayMed) + "% ≈ " + str.tostring(dayPts, "0") + " pts") + "."
    string tipP = "Projected final range: the range so far ÷ the typical share of the day done by now, blended with the expected range (mostly the forecast early, mostly the live range by midday). " + bandTx + " band."
    string pill2 = prjSt == "Above" ? "▲ ABOVE EXP" : prjSt == "Below" ? "▼ BELOW EXP" : prjSt == "Neutral" ? "● IN BAND" : "—"
    string tipE = "Chance today's high / low is already in: how far price is from each, against the volatility still to come before 17:00 ET (expected range × the share of the day's variance still ahead, from NQ, ES and RTY 1-minute data 2018–2026; RTY has its own profile). Random-walk geometry, not a signal. Tested on 2025–26 it was well calibrated."
    string tipS = "One standard deviation of the move still to come before 17:00 ET, in points."
    string eHi = na(pHiIn) ? "—" : pHiIn >= 0.995 ? ">99%" : pHiIn < 0.005 ? "<1%" : str.tostring(100.0 * pHiIn, "0") + "%"
    string eLo = na(pLoIn) ? "—" : pLoIn >= 0.995 ? ">99%" : pLoIn < 0.005 ? "<1%" : str.tostring(100.0 * pLoIn, "0") + "%"
    tcB(T, 0, 0 + offS, mob ? live + " KYŌKA · " + syminfo.ticker + " · " + dn + " " + stampS : live + " KYŌKA SUIGETSU  " + syminfo.ticker + " · " + dn + " · " + stampS + " ET", colNow, cHd, dSz, text.align_left, "Live status vs the " + bl + " at this time of day. Hover any cell for detail.")
    int r = 1 + offS
    if mob
        tc(T, 0, r, "Range", cSub, cBg, dSz)
        tc(T, 1, r, f2(tRng) + "% " + pTxt(rP), cTx, cBg, dSz)
        tcB(T, 2, r, pill(sR), sRfg, sRbg, dSz, text.align_center, tipR)
        r += 1
        if xOn
            tc(T, 0, r, "Exp", colExp, cBg, dSz)
            tc(T, 1, r, hasX ? str.tostring(expPts, "0") + (na(prjMed) ? "" : " → " + str.tostring(prjPts, "0")) + " pts" : "—", cTx, cBg, dSz)
            tcB(T, 2, r, na(prjMed) ? (hasX and rPts >= expPts ? "✓ REACHED" : "—") : pill2, sPfg, sPbg, dSz, text.align_center, tipP)
            r += 1
        if xOn and xExt
            tc(T, 0, r, "H/L in", colExp, cBg, dSz, text.align_left, tipE)
            tc(T, 1, r, eHi + " / " + eLo, cTx, cBg, dSz, text.align_left, tipE)
            tc(T, 2, r, na(sigPts) ? "—" : "σ " + str.tostring(sigPts, "0"), cSub, cBg, dSz, text.align_center, tipS)
            r += 1
        tc(T, 0, r, "ATR", cSub, cBg, dSz)
        tc(T, 1, r, gauge(atrUse), na(atrUse) ? cMu : atrUse >= 1 ? colWide : cTx, cBg, dSz)
        tc(T, 2, r, na(atrUse) ? "—" : str.tostring(100.0 * atrUse, "0") + "%", cTx, cBg, dSz, text.align_center)
        r += 1
        tc(T, 0, r, "Net", cSub, cBg, dSz)
        tc(T, 1, r, sgn(tNet) + "% " + pTxt(nP), cTx, cBg, dSz)
        tcB(T, 2, r, pill(sN), sNfg, sNbg, dSz, text.align_center, tipN)
        r += 1
        tc(T, 0, r, moName(curMo), cSub, cBg, dSz)
        tc(T, 1, r, na(moNet) ? "—" : sgn(moNet) + "% MTD", cTx, cBg, dSz)
        tc(T, 2, r, na(mvMed) ? "" : "med " + sgn1(mvMed), cSub, cBg, dSz, text.align_center)
    else
        tc(T, 0, r, "RANGE", cSub, cBg, dSz)
        tc(T, 1, r, f2(tRng) + "% · " + str.tostring(rPts, "0") + " pts", cTx, cBg, dSz)
        tcB(T, 2, r, pill(sR), sRfg, sRbg, dSz, text.align_center, tipR)
        r += 1
        tc(T, 0, r, "  vs typical", cMu, cBg, dSz)
        tc(T, 1, r, meter(rP) + " " + pTxt(rP), sR == "Above" ? rUpC : sR == "Below" ? rDnC : cSub, cBg, dSz, text.align_left, "Where today's range sits in the baseline's spread at this time: left = small, right = large.")
        tc(T, 2, r, na(rMed) ? "—" : "typ " + f2(rMed) + "%", cSub, cBg, dSz, text.align_center, na(rZlo) ? "" : "Neutral zone " + f2(rZlo) + "–" + f2(rZhi) + "%")
        r += 1
        tc(T, 0, r, "ATR " + str.tostring(atrLen), cSub, cBg, dSz)
        tc(T, 1, r, na(atrD) ? "—" : str.tostring(atrD, "0") + " pts · " + f2(100.0 * atrD / tO) + "%", cTx, cBg, dSz)
        tc(T, 2, r, gauge(atrUse) + " " + (na(atrUse) ? "—" : str.tostring(100.0 * atrUse, "0") + "%"), na(atrUse) ? cMu : atrUse >= 1 ? colWide : cTx, cBg, dSz, text.align_left, "Share of the daily ATR already covered by today's range")
        r += 1
        if xOn
            tcB(T, 0, r, "EXPECTED", colExp, cBg, dSz, text.align_left, tipX)
            tc(T, 1, r, hasX ? f2(expMed) + "% ≈ " + str.tostring(expPts, "0") + " pts · " + bandTx + " " + str.tostring(expLo / 100.0 * tO, "0") + "–" + str.tostring(expHi / 100.0 * tO, "0") : "— (needs 120 days of daily history)", cTx, cBg, dSz, text.align_left, tipX)
            tc(T, 2, r, toGo, hasX and rPts >= expPts ? colExp : cSub, cBg, dSz, text.align_center)
            r += 1
            tcB(T, 0, r, "PROJECTED", colExp, cBg, dSz, text.align_left, tipP)
            tc(T, 1, r, na(prjMed) ? "— (intraday chart ≤ 60 min)" : "≈ " + str.tostring(prjPts, "0") + " pts · " + f2(prjMed) + "% · " + str.tostring(prjLo / 100.0 * tO, "0") + "–" + str.tostring(prjHi / 100.0 * tO, "0"), cTx, cBg, dSz, text.align_left, tipP)
            tcB(T, 2, r, pill2, sPfg, sPbg, dSz, text.align_center, tipP)
            r += 1
            if xExt
                tcB(T, 0, r, "HIGH / LOW IN", colExp, cBg, dSz, text.align_left, tipE)
                tc(T, 1, r, na(pHiIn) ? (hasX ? "— (intraday chart ≤ 60 min)" : "—") : "high in " + eHi + " · low in " + eLo, cTx, cBg, dSz, text.align_left, tipE)
                tc(T, 2, r, na(sigPts) ? "—" : "σ left ≈ " + str.tostring(sigPts, "0") + " pts", cSub, cBg, dSz, text.align_center, tipS)
                r += 1
            if xCal
                tc(T, 0, r, "  drivers", cMu, cBg, dSz)
                tc(T, 1, r, drvTx == "" ? "none today" : drvTx, drvTx == "" ? cMu : cTx, cBg, dSz, text.align_left, "Today's conditions and their multipliers on the expected range (2010–2026 fit). Weekdays are relative to Monday.")
                tc(T, 2, r, drvTx == "" ? "×1.00" : "×" + str.tostring(drvMul, "0.00"), drvMul >= 1.02 ? colWide : drvMul <= 0.98 ? colNar : cSub, cBg, dSz, text.align_center)
                r += 1
        else
            tc(T, 0, r, "DAY", cSub, cBg, dSz)
            tc(T, 1, r, na(dayMed) ? "—" : "typical " + f2(dayMed) + "% ≈ " + str.tostring(dayPts, "0") + " pts", cTx, cBg, dSz, text.align_left, na(dayP75) ? "" : "P75 day " + f2(dayP75) + "% ≈ " + str.tostring(dayP75 / 100.0 * tO, "0") + " pts")
            tc(T, 2, r, toGo, rPts >= dayPts ? colWide : cSub, cBg, dSz, text.align_center)
            r += 1
        tc(T, 0, r, "NET", cSub, cBg, dSz)
        tc(T, 1, r, sgn(tNet) + "% · " + sgn0(nPts) + " pts", tNet >= 0 ? colUp : colDn, cBg, dSz)
        tcB(T, 2, r, pill(sN), sNfg, sNbg, dSz, text.align_center, tipN)
        r += 1
        tc(T, 0, r, "  vs typical", cMu, cBg, dSz)
        tc(T, 1, r, meter(nP) + " " + pTxt(nP), sN == "Above" ? colUp : sN == "Below" ? colDn : cSub, cBg, dSz)
        tc(T, 2, r, na(nMed) ? "—" : "typ " + sgn(nMed) + "%", cSub, cBg, dSz, text.align_center, na(nZlo) ? "" : "Neutral zone " + sgn(nZlo) + " to " + sgn(nZhi) + "%")
        r += 1
        tc(T, 0, r, "HOUR", cSub, cBg, dSz)
        tc(T, 1, r, str.tostring(hNowET, "00") + ":00 ET", cTx, cBg, dSz)
        tc(T, 2, r, na(hShH) ? "—" : "H " + str.tostring(hShH, "0") + "% · L " + str.tostring(hShL, "0") + "%", cSub, cBg, dSz, text.align_center, "How often this hour set the day's high / low on the last " + str.tostring(nh) + " " + who)
        r += 1
        tc(T, 0, r, str.upper(moName(curMo)), cSub, cBg, dSz)
        tc(T, 1, r, na(moNet) ? "—" : sgn(moNet) + "% month to date", na(moNet) ? cMu : moNet >= 0 ? colUp : colDn, cBg, dSz)
        tc(T, 2, r, na(mvMed) ? "—" : "med " + sgn1(mvMed) + "% · " + pTxt(mvRk), cSub, cBg, dSz, text.align_center, "Median of the last " + str.tostring(mvC.size()) + " " + moName(curMo) + "s, roll-free")
        r += 1
        tc(T, 0, r, str.upper(dn), cSub, cBg, dSz)
        tc(T, 1, r, na(todayMult) ? "—" : "range ×" + str.tostring(todayMult, "0.00") + " vs all days", na(todayMult) ? cMu : todayMult >= wideX ? colWide : todayMult <= narX ? colNar : cTx, cBg, dSz)
        tc(T, 2, r, na(todayUp) ? "—" : "up " + str.tostring(todayUp, "0") + "%", cSub, cBg, dSz, text.align_center, "Last " + str.tostring(nWk) + " " + dn + "s")
        r += 1
        tc(T, 0, r, "baseline " + bl + " · neutral zone " + bandCI + " · full day 18:00–17:00 ET", cMu, cBg, size.tiny)

// ══════════ Alerts (real time, once per event per day)
if barstate.islast and (barstate.isrealtime)
    if time_tradingday != alTd
        alTd    := time_tradingday
        alLast  := ""
        alDayOk := false
        alAtrOk := false
        alExpOk := false
        alPrjOk := false
    if alStat and (sR == "Above" or sR == "Below") and sR != alLast and alLast != ""
        alert("Kyōka Suigetsu · " + syminfo.ticker + " · range now " + str.upper(sR) + " typical for " + stampS + " ET · " + f2(tRng) + "% vs " + f2(rMed) + "% median", alert.freq_once_per_bar)
    if sR != ""
        alLast := sR
    if alDay and not alDayOk and not na(dayPts) and rPts >= dayPts
        alDayOk := true
        alert("Kyōka Suigetsu · " + syminfo.ticker + " · typical day range reached · " + str.tostring(rPts, "0") + " pts (" + f2(tRng) + "%) at " + stampS + " ET", alert.freq_once_per_bar)
    if alAtr and not alAtrOk and atrUse >= 1
        alAtrOk := true
        alert("Kyōka Suigetsu · " + syminfo.ticker + " · 100% of ATR " + str.tostring(atrLen) + " used · " + str.tostring(rPts, "0") + " pts at " + stampS + " ET", alert.freq_once_per_bar)
    if alExp and xOn and not alExpOk and not na(expPts) and rPts >= expPts
        alExpOk := true
        alert("Kyōka Suigetsu · " + syminfo.ticker + " · expected day range reached · " + str.tostring(rPts, "0") + " pts vs " + str.tostring(expPts, "0") + " expected at " + stampS + " ET", alert.freq_once_per_bar)
    if alPrj and xOn and not alPrjOk and not na(prjMed) and prjMed > expHi
        alPrjOk := true
        alert("Kyōka Suigetsu · " + syminfo.ticker + " · projected day range ≈ " + str.tostring(prjPts, "0") + " pts, above the expected " + bandTx + " band (" + str.tostring(expHi / 100.0 * tO, "0") + ") at " + stampS + " ET", alert.freq_once_per_bar)
````
