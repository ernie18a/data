# CVD MTF Dashboard with Insights

- url: https://www.tradingview.com/script/T0wGMnm2-CVD-MTF-Dashboard-with-Insights/
- type: indicator
- pine_id: PUB;f3cba06e11404a3e8a64b894a27a84dc
- version: 3.0

## Description

The hardest part about Cumulative Volume Delta isn’t finding a CVD indicator.
It’s actually understanding what the data is trying to say before price punishes you for misunderstanding it.

Most traders who first encounter CVD quickly realize the same thing:
[list]
[*]The raw data is powerful…
[*]But interpreting it in real time is difficult.
[*]Especially across multiple timeframes.
[*]Especially during transitions, traps, divergences, and session rotations.
[/list]
That’s where this dashboard separates itself from typical CVD tools.
Instead of simply plotting delta and forcing the user to “figure it out,” this system acts more like a real-time market interpreter — translating complex participation behavior into structured, readable context that traders can immediately act on.

At its core, the dashboard combines:
[list]
[*]Multi-timeframe CVD flow analysis
[*]Buyer vs seller participation modeling
[*]Momentum acceleration detection
[*]ADX regime filtering
[*]Divergence recognition
[*]Trend freshness analysis
[*]Context-aware market insights
[/list]
But the real innovation is not any single component.
It’s the way the information is organized into a decision-support framework that dramatically lowers the learning curve of CVD interpretation while still remaining advanced enough for experienced traders.

The dashboard doesn’t just tell you:
 “Buyers are active.”

It tells you things like:
[list]
[*]Whether participation is expanding or fading
[*]Whether momentum is accelerating or slowing
[*]Whether lower timeframes are leading higher timeframes
[*]Whether the move is fresh or becoming exhausted
[*]Whether divergence warns against chasing
[*]Whether conditions favor continuation, patience, or caution
[/list]
That is an enormous difference.

Most CVD tools leave inexperienced traders staring at squiggly lines trying to guess what matters.

This dashboard transforms that complexity into readable market structure.

The INSIGHTS engine is arguably the standout feature.

Rather than forcing traders to manually interpret conflicting signals, the system synthesizes 
multiple layers of market behavior into plain-English contextual guidance such as:
[list]
[*]“Strong bullish participation. CVD supports long continuation setups.”
[*]“Bear trend active, but freshness is fading. Avoid chasing lows.”
[*]“Participation is weak and rotational. Patience favored.”
[*]“Divergence active. Watch for traps, failed continuation, or reversal pressure.”
[/list]
This is where the indicator begins to feel less like a traditional study and more like a professional-grade market intelligence panel.

Another standout feature is the emphasis on freshness.

Many indicators can identify trend direction.

Very few can communicate whether the move is still developing or already becoming stale.

By tracking the age and recency of directional participation across multiple timeframes, the dashboard helps traders avoid one of the most common retail mistakes:
entering trends after the highest-probability portion of the move has already occurred.

The visual design also deserves recognition.

Rather than cluttering the screen with overwhelming oscillator noise, the interface presents institutional-style information architecture:
[list]
[*]Clean state classifications
[*]Structured momentum visualization
[*]Simplified buyer/seller participation bars
[*]Multi-timeframe alignment summaries
[*]Minimalistic premium styling
[*]Readable divergence alerts
[*]Clear regime identification
[/list]
The result is an indicator that feels surprisingly approachable despite the sophistication under the hood.

For newer traders, it makes CVD understandable.

For experienced traders, it makes CVD actionable.

And that combination is rare.

In a market flooded with recycled oscillators and cosmetic overlays, this dashboard stands out because it solves a real problem:

It bridges the gap between raw order-flow complexity and practical decision-making.

This is the kind of tool that feels less like another indicator…
and more like having a professional market interpreter sitting beside you during live trading.

## Source Code

````pine
//@version=6

indicator("CVD MTF Dashboard — W / Insights", overlay=true, max_labels_count=500)

groupDash = "Dashboard"

showDashboard = input.bool(true, "Show Dashboard", group=groupDash, tooltip="Shows or hides the complete CVD dashboard without changing its calculations.")

colorTheme = input.string(

     "Graphite",

     "Color Theme",

     options=["Graphite", "Classic Navy"],

     group=groupDash,

     tooltip="Graphite matches the CVD X-RAY dashboard. Classic Navy restores the original CVD MTF Dashboard colors.")

isGraphite = colorTheme == "Graphite"

dashPosInput = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupDash, tooltip="Selects the corner of the chart where the dashboard is displayed.")

rowHeight = input.float(6.5, "Row Height (Padding)", minval=1.0, maxval=15.0, step=0.5, group=groupDash, tooltip="Adjusts vertical dashboard spacing without changing calculations.")

groupTF = "Timeframes"

showTF1 = input.bool(false, "Enable", inline="TF1", group=groupTF)

tf1 = input.timeframe("5", "TF 1", inline="TF1", group=groupTF, tooltip="Sets TF 1. When enabled, this timeframe appears in the dashboard and contributes to alignment, averages, divergence, freshness, summary, and insight calculations.")

showTF2 = input.bool(true, "Enable", inline="TF2", group=groupTF)

tf2 = input.timeframe("15", "TF 2", inline="TF2", group=groupTF, tooltip="Sets TF 2. When enabled, this timeframe appears in the dashboard and contributes to alignment, averages, divergence, freshness, summary, and insight calculations.")

showTF3 = input.bool(true, "Enable", inline="TF3", group=groupTF)

tf3 = input.timeframe("60", "TF 3", inline="TF3", group=groupTF, tooltip="Sets TF 3. When enabled, this timeframe appears in the dashboard and contributes to alignment, averages, divergence, freshness, summary, and insight calculations.")

showTF4 = input.bool(true, "Enable", inline="TF4", group=groupTF)

tf4 = input.timeframe("240", "TF 4", inline="TF4", group=groupTF, tooltip="Sets TF 4. When enabled, this timeframe appears in the dashboard and contributes to alignment, averages, divergence, freshness, summary, and insight calculations.")

groupLogic = "Logic"

adxLen = input.int(14, "ADX Length", minval=2, group=groupLogic, tooltip="Controls the sensitivity of the ADX regime measurement. Lower values respond faster; higher values are smoother.")

cvdEmaLen = input.int(10, "CVD Momentum EMA", minval=2, group=groupLogic, tooltip="Smooths cumulative volume delta for the Accelerating, Building, Balanced, and Slowing momentum states.")

divLookback = input.int(6, "Divergence Lookback", minval=3, group=groupLogic, tooltip="Sets the number of bars used to compare price extremes with CVD extremes for divergence detection.")

freshLimitMin = input.int(240, "Fresh Limit Minutes", minval=1, group=groupLogic, tooltip="Sets the maximum signal age, in minutes, classified as fresh. Older readings are displayed as stale.")

color C_FRAME = isGraphite ? color.new(#38383C, 52) : color.rgb(38, 49, 61)

color C_BG = isGraphite ? #17181C : color.rgb(7, 11, 16)

color C_TITLE = isGraphite ? #17181C : color.rgb(29, 32, 40)

color C_SOFT = isGraphite ? #222225 : color.rgb(21, 28, 38)

color C_CELL = isGraphite ? #2D2D30 : color.rgb(11, 17, 24)

color C_CELL2 = isGraphite ? #29292C : color.rgb(15, 23, 32)

color C_TEXT = isGraphite ? color.white : color.rgb(244, 247, 251)

color C_MUTED = isGraphite ? #929296 : color.rgb(156, 168, 183)

color C_CYAN = isGraphite ? #B9B9BD : color.rgb(36, 191, 255)

color C_GREEN = isGraphite ? #26C6B8 : color.rgb(32, 230, 163)

color C_RED = isGraphite ? #A83A68 : color.rgb(255, 77, 109)

color C_AMBER = isGraphite ? #D6A756 : color.rgb(255, 194, 71)

color C_BLUE = isGraphite ? #667582 : color.rgb(77, 182, 255)

dashPos = dashPosInput == "Top Right" ? position.top_right : dashPosInput == "Top Left" ? position.top_left : dashPosInput == "Bottom Right" ? position.bottom_right : position.bottom_left

visibleCount = (showTF1 ? 1 : 0) + (showTF2 ? 1 : 0) + (showTF3 ? 1 : 0) + (showTF4 ? 1 : 0)

safeCount = math.max(visibleCount, 1)

tableRows = 5 + visibleCount

var table dash = table.new(dashPos, 7, tableRows, border_width=1, frame_width=1, frame_color=C_FRAME, border_color=C_FRAME)

calc_adx(int len) =>

    up = ta.change(high)

    down = -ta.change(low)

    plusDM = na(up) ? 0 : up > down and up > 0 ? up : 0

    minusDM = na(down) ? 0 : down > up and down > 0 ? down : 0

    trur = ta.rma(ta.tr(true), len)

    plus = fixnan(100 * ta.rma(plusDM, len) / trur)

    minus = fixnan(100 * ta.rma(minusDM, len) / trur)

    sum = plus + minus

    100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), len)

get_data(string tf) =>

    [o, h, l, c, v, a] = request.security(syminfo.tickerid, tf, [open, high, low, close, volume, calc_adx(adxLen)])

    priceRange = math.max(h - l, syminfo.mintick)

    closePos = (c - l) / priceRange

    buyPct = math.max(0, math.min(100, math.round(closePos * 100)))

    delta = v * ((closePos - 0.5) * 2.0)

    cvd = ta.cum(delta)

    cvdEma = ta.ema(cvd, cvdEmaLen)

    cvdUp = ta.rising(cvd, 3)

    cvdDown = ta.falling(cvd, 3)

    momUp = ta.rising(cvdEma, 2)

    momDown = ta.falling(cvdEma, 2)

    priceHH = c > ta.highest(c[1], divLookback)

    priceLL = c < ta.lowest(c[1], divLookback)

    cvdHH = cvd > ta.highest(cvd[1], divLookback)

    cvdLL = cvd < ta.lowest(cvd[1], divLookback)

    bearDiv = priceHH and not cvdHH

    bullDiv = priceLL and not cvdLL

    state = buyPct >= 58 and cvdUp ? "BULL FLOW" : buyPct <= 42 and cvdDown ? "BEAR FLOW" : "NEUTRAL"

    regime = a >= 25 ? "EXPANDING" : a >= 18 ? "BALANCED" : "SLOWING"

    momentum = momUp and a >= 18 ? "ACCELERATING" : momUp ? "BUILDING" : momDown ? "SLOWING" : "BALANCED"

    divText = bearDiv ? "BEAR DIV" : bullDiv ? "BULL DIV" : "NONE"

    changed = ta.change(cvdUp ? 1 : cvdDown ? -1 : 0) != 0

    barsFresh = ta.barssince(changed)

    tfSec = timeframe.in_seconds(tf)

    freshMin = na(barsFresh) ? 999999 : math.round((barsFresh * tfSec) / 60)

    [buyPct, state, regime, momentum, divText, freshMin, a, cvdUp, cvdDown]

[bp1, st1, rg1, mo1, dv1, fr1, ax1, up1, dn1] = get_data(tf1)

[bp2, st2, rg2, mo2, dv2, fr2, ax2, up2, dn2] = get_data(tf2)

[bp3, st3, rg3, mo3, dv3, fr3, ax3, up3, dn3] = get_data(tf3)

[bp4, st4, rg4, mo4, dv4, fr4, ax4, up4, dn4] = get_data(tf4)

tfLabel(string tf) =>

    tf == "60" ? "1H" : tf == "240" ? "4H" : tf == "D" ? "1D" : tf + "M"

buyerBar(int pct) =>

    sellPct = 100 - pct

    filled = math.round(pct / 5)

    bar = ""

    for i = 1 to 20

        bar += i <= filled ? "|" : "."

    bar + "\n \n" + str.tostring(pct) + "% B   |   " + str.tostring(sellPct) + "% S"

momDots(string momentum) =>

    dots = momentum == "ACCELERATING" ? "● ● ● ● ○" : momentum == "BUILDING" ? "● ● ● ○ ○" : momentum == "SLOWING" ? "● ○ ○ ○ ○" : "● ● ○ ○ ○"

    dots + "\n \n" + momentum

freshText(int mins) =>

    mins > 1440 ? "STALE" : mins < 60 ? str.tostring(mins) + "M" : str.tostring(math.round(mins / 60)) + "H"

freshColor(int mins) =>

    mins <= freshLimitMin ? C_GREEN : C_AMBER

stateColor(string s) =>

    s == "BULL FLOW" ? C_GREEN : s == "BEAR FLOW" ? C_RED : C_AMBER

momColor(string m) =>

    m == "ACCELERATING" or m == "BUILDING" ? C_GREEN : m == "SLOWING" ? C_AMBER : C_MUTED

divColor(string d) =>

    d == "NONE" ? C_MUTED : d == "BULL DIV" ? C_GREEN : C_RED

cellBG(int r) =>

    r % 2 == 0 ? C_CELL : C_CELL2

bullScore = (showTF1 and up1 ? 1 : 0) + (showTF2 and up2 ? 1 : 0) + (showTF3 and up3 ? 1 : 0) + (showTF4 and up4 ? 1 : 0)

bearScore = (showTF1 and dn1 ? 1 : 0) + (showTF2 and dn2 ? 1 : 0) + (showTF3 and dn3 ? 1 : 0) + (showTF4 and dn4 ? 1 : 0)

weightedBull = (showTF1 and up1 ? 1 : 0) + (showTF2 and up2 ? 2 : 0) + (showTF3 and up3 ? 3 : 0) + (showTF4 and up4 ? 4 : 0)

weightedBear = (showTF1 and dn1 ? 1 : 0) + (showTF2 and dn2 ? 2 : 0) + (showTF3 and dn3 ? 3 : 0) + (showTF4 and dn4 ? 4 : 0)

alignScore = math.max(bullScore, bearScore)

avgBuy = math.round(((showTF1 ? bp1 : 0) + (showTF2 ? bp2 : 0) + (showTF3 ? bp3 : 0) + (showTF4 ? bp4 : 0)) / safeCount)

avgAdx = ((showTF1 ? ax1 : 0) + (showTF2 ? ax2 : 0) + (showTF3 ? ax3 : 0) + (showTF4 ? ax4 : 0)) / safeCount

divCount = (showTF1 and dv1 != "NONE" ? 1 : 0) + (showTF2 and dv2 != "NONE" ? 1 : 0) + (showTF3 and dv3 != "NONE" ? 1 : 0) + (showTF4 and dv4 != "NONE" ? 1 : 0)

freshCount = (showTF1 and fr1 <= freshLimitMin ? 1 : 0) + (showTF2 and fr2 <= freshLimitMin ? 1 : 0) + (showTF3 and fr3 <= freshLimitMin ? 1 : 0) + (showTF4 and fr4 <= freshLimitMin ? 1 : 0)

buildCount = (showTF1 and (mo1 == "BUILDING" or mo1 == "ACCELERATING") ? 1 : 0) + (showTF2 and (mo2 == "BUILDING" or mo2 == "ACCELERATING") ? 1 : 0) + (showTF3 and (mo3 == "BUILDING" or mo3 == "ACCELERATING") ? 1 : 0) + (showTF4 and (mo4 == "BUILDING" or mo4 == "ACCELERATING") ? 1 : 0)

slowCount = (showTF1 and mo1 == "SLOWING" ? 1 : 0) + (showTF2 and mo2 == "SLOWING" ? 1 : 0) + (showTF3 and mo3 == "SLOWING" ? 1 : 0) + (showTF4 and mo4 == "SLOWING" ? 1 : 0)

lowerBull = showTF1 and showTF2 and up1 and up2

lowerBear = showTF1 and showTF2 and dn1 and dn2

bullDominant = weightedBull > weightedBear

bearDominant = weightedBear > weightedBull

biasThreshold = visibleCount >= 3 ? 3 : visibleCount == 2 ? 2 : 1

summaryState = visibleCount == 0 ? "NO TFs" : bullScore >= biasThreshold ? "LONG BIAS" : bearScore >= biasThreshold ? "SHORT BIAS" : lowerBull and bullDominant ? "EARLY LONG" : lowerBear and bearDominant ? "EARLY SHORT" : "MIXED"

bias = visibleCount == 0 ? "NO ACTIVE TFs" : bullDominant ? "BULLISH BIAS" : bearDominant ? "BEARISH BIAS" : "MIXED BIAS"

regimeSummary = visibleCount == 0 ? "OFF" : avgAdx >= 25 ? "EXPANDING" : avgAdx >= 18 ? "MIXED" : "SLOWING"

strongBullTrend = visibleCount > 0 and weightedBull >= 6 and avgAdx >= 22 and freshCount >= 2

strongBearTrend = visibleCount > 0 and weightedBear >= 6 and avgAdx >= 22 and freshCount >= 2

activeBullTrend = visibleCount > 0 and bullDominant and bullScore >= math.min(2, visibleCount) and avgAdx >= 18 and buildCount >= math.min(2, visibleCount)

activeBearTrend = visibleCount > 0 and bearDominant and bearScore >= math.min(2, visibleCount) and avgAdx >= 18 and buildCount >= math.min(2, visibleCount)

earlyBullExpansion = lowerBull and bullDominant and avgAdx >= 18 and buildCount >= 2

earlyBearExpansion = lowerBear and bearDominant and avgAdx >= 18 and buildCount >= 2

transitionExpansion = visibleCount > 0 and avgAdx >= 18 and buildCount >= math.min(2, visibleCount) and freshCount >= 1 and alignScore >= math.min(2, visibleCount)

trueWait = visibleCount > 0 and avgAdx < 18 and alignScore <= 1 and buildCount <= 1 and divCount == 0

lateTrendRisk = visibleCount > 0 and alignScore >= math.min(3, visibleCount) and (freshCount <= 1 or slowCount >= 2)

insight =

     visibleCount == 0 ? "Enable at least one timeframe." :

     divCount > 0 and strongBullTrend ? "Bull trend active, but divergence warns against chasing highs." :

     divCount > 0 and strongBearTrend ? "Bear trend active, but divergence warns against chasing lows." :

     divCount > 0 ? "Divergence active. Watch for traps, failed continuation, or reversal pressure." :

     strongBullTrend ? "Strong bullish participation. CVD supports long continuation setups." :

     strongBearTrend ? "Strong bearish participation. CVD supports short continuation setups." :

     activeBullTrend ? "Bullish participation active. Pullback continuation setups are favored." :

     activeBearTrend ? "Bearish participation active. Pullback continuation setups are favored." :

     earlyBullExpansion ? "Early bullish expansion. Lower TFs are leading before confirmation." :

     earlyBearExpansion ? "Early bearish expansion. Lower TFs are leading before confirmation." :

     lateTrendRisk and bullDominant ? "Bull trend active, but freshness is fading. Avoid chasing highs." :

     lateTrendRisk and bearDominant ? "Bear trend active, but freshness is fading. Avoid chasing lows." :

     transitionExpansion and bullDominant ? "Bullish pressure improving. Market may be shifting into expansion." :

     transitionExpansion and bearDominant ? "Bearish pressure improving. Market may be shifting into expansion." :

     trueWait ? "Participation is weak and rotational. Patience favored." :

     "Mixed but playable context. Use structure and session direction."

renderHeader() =>

    table.merge_cells(dash, 0, 0, 6, 1)

    table.cell(dash, 0, 0, "CUMULATIVE VOLUME DELTA (CVD)\nSYMBOL : " + syminfo.ticker, text_color=C_TEXT, bgcolor=C_TITLE, text_size=size.large, text_halign=text.align_center)

    table.cell(dash, 0, 2, "MTF", text_color=C_MUTED, bgcolor=C_SOFT)

    table.cell(dash, 1, 2, "STATE", text_color=C_MUTED, bgcolor=C_SOFT)

    table.cell(dash, 2, 2, "BUYERS / SELLERS", text_color=C_MUTED, bgcolor=C_SOFT)

    table.cell(dash, 3, 2, "MOMENTUM", text_color=C_MUTED, bgcolor=C_SOFT)

    table.cell(dash, 4, 2, "ADX / REGIME", text_color=C_MUTED, bgcolor=C_SOFT)

    table.cell(dash, 5, 2, "DIVERGENCE", text_color=C_MUTED, bgcolor=C_SOFT)

    table.cell(dash, 6, 2, "FRESH", text_color=C_MUTED, bgcolor=C_SOFT)

renderRow(int r, string tf, int bp, string st, string rg, string mo, string dv, int fr, float ax) =>

    cBG = cellBG(r)

    table.cell(dash, 0, r, tfLabel(tf), text_color=C_CYAN, bgcolor=cBG)

    table.cell(dash, 1, r, st + "\n" + rg, text_color=stateColor(st), bgcolor=cBG)

    table.cell(dash, 2, r, buyerBar(bp), text_color=C_TEXT, bgcolor=cBG)

    table.cell(dash, 3, r, momDots(mo), text_color=momColor(mo), bgcolor=cBG)

    table.cell(dash, 4, r, rg + "\n" + str.tostring(ax, "#.#"), text_color=C_CYAN, bgcolor=cBG)

    table.cell(dash, 5, r, dv, text_color=divColor(dv), bgcolor=cBG)

    table.cell(dash, 6, r, freshText(fr), text_color=freshColor(fr), bgcolor=cBG)

renderSummary(int r) =>

    table.cell(dash, 0, r, "SUMMARY", text_color=C_MUTED, bgcolor=C_SOFT)

    table.cell(dash, 1, r, "STATE\n" + summaryState, text_color=C_TEXT, bgcolor=C_SOFT)

    table.cell(dash, 2, r, "BUYERS\n" + str.tostring(avgBuy) + "%", text_color=C_TEXT, bgcolor=C_SOFT)

    table.cell(dash, 3, r, bias, text_color=C_AMBER, bgcolor=C_SOFT)

    table.cell(dash, 4, r, "REGIME\n" + regimeSummary, text_color=C_AMBER, bgcolor=C_SOFT)

    table.cell(dash, 5, r, str.tostring(divCount) + " SIGNALS", text_color=divCount > 0 ? C_AMBER : C_BLUE, bgcolor=C_SOFT)

    table.cell(dash, 6, r, str.tostring(freshCount) + "/" + str.tostring(visibleCount), text_color=C_GREEN, bgcolor=C_SOFT)

renderInsights(int r) =>

    table.cell(dash, 0, r, "INSIGHTS", text_color=C_MUTED, bgcolor=C_BG)

    table.merge_cells(dash, 1, r, 6, r)

    table.cell(dash, 1, r, insight, text_color=C_TEXT, bgcolor=C_BG, text_halign=text.align_left)

if showDashboard and barstate.islast

    renderHeader()

    row = 3

    if showTF1

        renderRow(row, tf1, bp1, st1, rg1, mo1, dv1, fr1, ax1)

        row += 1

    if showTF2

        renderRow(row, tf2, bp2, st2, rg2, mo2, dv2, fr2, ax2)

        row += 1

    if showTF3

        renderRow(row, tf3, bp3, st3, rg3, mo3, dv3, fr3, ax3)

        row += 1

    if showTF4

        renderRow(row, tf4, bp4, st4, rg4, mo4, dv4, fr4, ax4)

        row += 1

    renderSummary(row)

    row += 1

    renderInsights(row)

    for r = 2 to tableRows - 1

        for c = 0 to 6

            table.cell_set_height(dash, c, r, rowHeight)
````
