# Volume Weighted Average Price [OmegaTools]

- url: https://www.tradingview.com/script/fr41IfXY-Volume-Weighted-Average-Price-OmegaTools/
- type: indicator
- pine_id: PUB;47f9f02f946b4922a1c1ea91016d86e4
- version: 1.0

## Description

[b]Ω VWAP — Omega Volume Weighted Average Price[/b]

Ω VWAP plots VWAP and its standard deviation bands on four independent anchors: Extended Hours (the full trading day), Regular Trading Hours, Weekly and Rolling. For the anchored periods it also draws the levels at which the previous period closed. Each anchor is configured separately, so the script works as a single clean VWAP or as a full map of intraday, cash-session and weekly value.

[b]WHAT IT DOES[/b]
[list]
[*] Four VWAP engines in one script: Extended Hour, RTH (09:30–16:00 New York), Weekly and Rolling.
[*] ±1σ and ±2σ volume-weighted standard deviation bands on every anchor.
[*] Previous-period levels (mean and bands) for the Extended Hour, RTH and Weekly anchors, drawn as horizontal lines across the current period.
[*] Five fill modes that highlight the extension zones, the value area, or both.
[*] An optional external volume source, so you can build a real VWAP on instruments with missing or tick-only volume (CFDs, cash indices, spot FX).
[/list]

[b]HOW IT WORKS[/b]

[b]Anchored VWAP[/b]
From each anchor, the script keeps three running sums: Σ(p·v), Σv and Σ(p²·v). Here p is the bar's typical price (HLC3) and v is its volume. The VWAP is Σ(p·v) / Σv.

The band width is the volume-weighted standard deviation of price around the VWAP: √(Σ(p²·v) / Σv − VWAP²). The variance is floored at zero before the square root. This prevents invalid values caused by floating-point rounding when dispersion is close to zero, which typically happens on the first bars of a new period. Bands are plotted at VWAP ± 1σ and VWAP ± 2σ.

[b]Anchors[/b]
[list]
[*] [b]Extended Hour[/b]: resets at the start of each trading day as defined by the symbol's session. On futures, and on stocks with extended hours enabled, the day includes the overnight and pre-market session.
[*] [b]Regular Trading Hours[/b]: resets on the first bar inside 09:30–16:00 America/New_York. Only volume traded inside RTH enters the calculation, and the bands are drawn only during RTH, so overnight activity never distorts the cash-session VWAP.
[*] [b]Weekly[/b]: resets at the start of each trading week.
[*] [b]Rolling[/b]: has no anchor and never resets. Instead of cumulative sums, it applies Wilder's moving average (RMA) to p·v, v and p²·v, so the VWAP and σ adapt continuously.
[list]
[*] Length presets are Short (11), Mid (34) and Long (50).
[*] Mix averages the VWAPs and σ computed on lengths 9, 21 and 55. This blends fast and slow volume-weighted value into one smoother reference.
[/list]
[/list]

[b]Past levels[/b]
When an anchored period ends, its final VWAP and ±1σ/±2σ values are frozen. They are projected as horizontal lines across the next period:
[list]
[*] one trading day for Extended Hour;
[*] the 6.5-hour cash session for RTH;
[*] one week for Weekly.
[/list]
The lines start at the new anchor and extend into the chart's future space, so the prior day's, prior session's and prior week's value levels are visible before price reaches them. If the next period starts before a projection has ended (for example, a week that opened late after a holiday), the previous set is trimmed at the new anchor so levels from different periods never overlap.

[b]Fill modes[/b]
[list]
[*] [b]Extensions[/b]: shades the zones between 1σ and 2σ. The upper zone uses the DN colour and the lower zone uses the UP colour.
[*] [b]Area[/b]: shades the whole ±2σ envelope with a neutral tint of the MEAN colour.
[*] [b]Internal[/b]: shades only the ±1σ core.
[*] [b]Extensions & Area[/b]: a neutral ±1σ core plus coloured extension zones.
[/list]
Fills work for both the current bands and the past levels. They require deviations to be displayed.

[b]Custom Asset[/b]
When Custom Asset is enabled, the chart's volume is replaced by the volume of another symbol on the same timeframe. Price still comes from the chart. This lets you build a meaningful VWAP on instruments whose volume is missing or counts ticks only, for example by using CME futures volume on a broker's index CFD or on a cash index. Choose a symbol that tracks the same underlying and trades during the same hours.

[b]HOW TO USE IT[/b]
[list]
[*] [b]Fair value and control.[/b] VWAP is the average price paid per unit of volume since the anchor. Price holding above an anchor's VWAP shows that buyers have been in control over that period; price holding below it shows sellers have been.
[*] [b]Balance vs. trend.[/b]
[list]
[*] In rotational conditions, price tends to oscillate inside ±1σ. The 1σ–2σ extensions then act as stretch zones where reversion toward VWAP becomes more likely.
[*] In trending conditions, price accepts beyond 1σ, and the VWAP or the 1σ band acts as dynamic support or resistance on pullbacks.
[*] Identifying which regime is in play is more useful than fading every band touch.
[/list]
[*] [b]Prior value.[/b] Past levels show where the previous day, cash session or week settled its value. Where the open sits relative to the prior VWAP and bands (above, inside or below) frames the session, and these levels are often retested as support or resistance.
[*] [b]Multi-anchor confluence.[/b] When VWAPs or bands from different anchors converge (for example, the weekly VWAP near the prior RTH +1σ), the level reflects the cost basis of several groups of participants and is often watched more closely.
[*] [b]RTH vs. Extended.[/b] On index futures, the RTH VWAP reflects cash-session participants and the Extended Hour VWAP reflects all participants, including overnight. Comparing the two shows whether overnight trading moved value away from where the cash session begins.
[*] [b]Rolling VWAP.[/b] Use it on markets without a natural session, such as crypto, or on higher intraday timeframes. It gives an adaptive volume-weighted mean with dispersion bands that doesn't depend on an anchor.
[/list]

[b]SETTINGS[/b]
[list]
[*] [b]Custom Asset[/b]: toggle and symbol for the external volume source.
[*] [b]Current[/b] (each anchor): None / Mean / Deviations / Mean & Deviations for the live VWAP.
[*] [b]Past[/b] (Extended Hour, RTH, Weekly): None / Mean / Deviations / Mean & Deviations for the previous-period levels.
[*] [b]Fill[/b]: None / Extensions / Area / Internal / Extensions & Area, set separately for current and past.
[*] [b]Length[/b] (Rolling): Mix / Short / Mid / Long.
[*] [b]Colours[/b]: MEAN, UP (lower bands) and DN (upper bands), set per anchor.
[/list]
Every display is set to None by default. Enable only the anchors you need to keep the chart clean.

[b]NOTES AND LIMITATIONS[/b]
[list]
[*] The script is designed for intraday charts. On the daily timeframe and above, the Extended Hour anchor resets on every bar.
[*] The RTH anchor uses the New York cash session (09:30–16:00 ET) and is meant for US equities, indices and their futures.
[list]
[*] Use a timeframe whose bars align with 09:30 (30 minutes or lower).
[*] On hourly bars that open on the hour, RTH starts on the first bar that opens inside the window.
[/list]
[*] The VWAP and bands are only as good as the volume data behind them. On symbols with tick volume or no volume, use Custom Asset.
[*] Past levels are drawn with line objects. To stay within TradingView's drawing limit, the oldest levels are removed automatically.
[*] The bands measure the dispersion of volume-weighted price. Intraday price distributions are not normal, so ±1σ and ±2σ should not be read as exact probabilities.
[/list]

The source code is open: study it, learn from it and adapt it to your own workflow.

[i]This script is a technical analysis tool. It does not generate trading signals or give financial advice. How price has behaved around these levels in the past does not guarantee future results.[/i]

## Source Code

````pine
// © OmegaTools

//@version=6
indicator("Omega Volume Weighted Average Price", "Ω VWAP", overlay = true, max_lines_count = 500)

// ┌─────────────────────────────────────────────────────────────┐
// │                           Inputs                            │
// └─────────────────────────────────────────────────────────────┘

custominp = input.bool(false, 'Custom Asset', inline = 'cs')
customasset = input.symbol('', '', inline = 'cs')

dailycurrentinp = input.string('Mean & Deviations', 'Current', ['None', 'Mean', 'Deviations', 'Mean & Deviations'], group = 'Extended Hour', inline = 'daycurr')
dailycurrentfill = input.string('None', 'Fill', ['None', 'Extensions', 'Area', 'Internal', 'Extensions & Area'], group = 'Extended Hour', inline = 'daycurr')
dailypastinp = input.string('None', 'Past', ['None', 'Mean', 'Deviations', 'Mean & Deviations'], group = 'Extended Hour', inline = 'daypast')
dailypastfill = input.string('None', 'Fill', ['None', 'Extensions', 'Area', 'Internal', 'Extensions & Area'], group = 'Extended Hour', inline = 'daypast')
midc1 = input.color(color.gray, 'MEAN', inline = 'col', group = 'Extended Hour')
upc1 = input.color(#2962ff, 'UP', inline = 'col', group = 'Extended Hour')
dnc1 = input.color(#e91e63, 'DN', inline = 'col', group = 'Extended Hour')

nycurrentinp = input.string('Mean', 'Current', ['None', 'Mean', 'Deviations', 'Mean & Deviations'], group = 'Regular Trading Hours', inline = 'nycurr')
nycurrentfill = input.string('None', 'Fill', ['None', 'Extensions', 'Area', 'Internal', 'Extensions & Area'], group = 'Regular Trading Hours', inline = 'nycurr')
nypastinp = input.string('None', 'Past', ['None', 'Mean', 'Deviations', 'Mean & Deviations'], group = 'Regular Trading Hours', inline = 'nypast')
nypastfill = input.string('None', 'Fill', ['None', 'Extensions', 'Area', 'Internal', 'Extensions & Area'], group = 'Regular Trading Hours', inline = 'nypast')
midc2 = input.color(color.gray, 'MEAN', inline = 'col', group = 'Regular Trading Hours')
upc2 = input.color(#2962ff, 'UP', inline = 'col', group = 'Regular Trading Hours')
dnc2 = input.color(#e91e63, 'DN', inline = 'col', group = 'Regular Trading Hours')

weeklycurrentinp = input.string('None', 'Current', ['None', 'Mean', 'Deviations', 'Mean & Deviations'], group = 'Weekly', inline = 'weekcurr')
weeklycurrentfill = input.string('None', 'Fill', ['None', 'Extensions', 'Area', 'Internal', 'Extensions & Area'], group = 'Weekly', inline = 'weekcurr')
weeklypastinp = input.string('None', 'Past', ['None', 'Mean', 'Deviations', 'Mean & Deviations'], group = 'Weekly', inline = 'weekpast')
weeklypastfill = input.string('None', 'Fill', ['None', 'Extensions', 'Area', 'Internal', 'Extensions & Area'], group = 'Weekly', inline = 'weekpast')
midc3 = input.color(color.gray, 'MEAN', inline = 'col', group = 'Weekly')
upc3 = input.color(#2962ff, 'UP', inline = 'col', group = 'Weekly')
dnc3 = input.color(#e91e63, 'DN', inline = 'col', group = 'Weekly')

rollinginp = input.string('None', 'Current', ['None', 'Mean', 'Deviations', 'Mean & Deviations'], group = 'Rolling', inline = 'perpcurr')
rollingfill = input.string('None', 'Fill', ['None', 'Extensions', 'Area', 'Internal', 'Extensions & Area'], group = 'Rolling', inline = 'perpcurr')
rollinglnt = input.string('Mix', 'Length', ['Mix', 'Short', 'Mid', 'Long'], group = 'Rolling')
midc4 = input.color(color.gray, 'MEAN', inline = 'col', group = 'Rolling')
upc4 = input.color(#2962ff, 'UP', inline = 'col', group = 'Rolling')
dnc4 = input.color(#e91e63, 'DN', inline = 'col', group = 'Rolling')

// ┌─────────────────────────────────────────────────────────────┐
// │                         Calculations                        │
// └─────────────────────────────────────────────────────────────┘

vwap(src, vol, reset) =>
    var float num = 0.0
    var float den = 0.0
    var float num2 = 0.0

    if reset
        num := src * vol
        den := vol
        num2 := src * src * vol
    else
        num += src * vol
        den += vol
        num2 += src * src * vol

    v = num / den
    stdev = math.sqrt(math.max(num2 / den - v * v, 0))
    [v, stdev]

rvwap(src, vol, lnt) =>
    den = ta.rma(vol, lnt)
    rvwap = ta.rma(src * vol, lnt) / den
    var2 = ta.rma(src * src * vol, lnt) / den - rvwap * rvwap
    stdev = math.sqrt(math.max(var2, 0))
    [rvwap, stdev]

// Past session levels (one set of lines + fills per anchor period)
type Levels
    line m
    line u1
    line u2
    line l1
    line l2

drawPast(float m, float u1, float u2, float l1, float l2, int t1, int t2, bool showMean, bool showDev, string fillMode, color midc, color upc, color dnc) =>
    Levels lv = Levels.new()

    if showMean and not na(m)
        lv.m := line.new(t1, m, t2, m, xloc.bar_time, color = midc, style = line.style_solid, width = 1)

    if showDev and not na(u1)
        lv.u2 := line.new(t1, u2, t2, u2, xloc.bar_time, color = dnc, style = line.style_solid,  width = 1)
        lv.u1 := line.new(t1, u1, t2, u1, xloc.bar_time, color = dnc, style = line.style_dotted, width = 1)
        lv.l1 := line.new(t1, l1, t2, l1, xloc.bar_time, color = upc, style = line.style_dotted, width = 1)
        lv.l2 := line.new(t1, l2, t2, l2, xloc.bar_time, color = upc, style = line.style_solid,  width = 1)

        fillArea = fillMode == 'Area' or fillMode == 'Extensions & Area'
        fillExt = fillMode == 'Extensions' or fillMode == 'Extensions & Area'
        fillInt = fillMode == 'Internal'

        color top = fillExt ? color.new(dnc, 84) : fillArea ? color.new(midc, 92) : na
        color mid = fillArea or fillInt ? color.new(midc, 92) : na
        color bot = fillExt ? color.new(upc, 84) : fillArea ? color.new(midc, 92) : na

        if not na(top)
            linefill.new(lv.u2, lv.u1, top)
        if not na(mid)
            linefill.new(lv.u1, lv.l1, mid)
        if not na(bot)
            linefill.new(lv.l1, lv.l2, bot)
    lv

trimLine(line ln, int t) =>
    if not na(ln) and ln.get_x2() > t
        ln.set_x2(t)

// Cuts the previous set at the new anchor so projections never overlap
// (e.g. a week that started late after a holiday)
method trim(Levels this, int t) =>
    trimLine(this.m, t)
    trimLine(this.u1, t)
    trimLine(this.u2, t)
    trimLine(this.l1, t)
    trimLine(this.l2, t)

var durDms = timeframe.in_seconds('D') * 1000
var durWms = timeframe.in_seconds('W') * 1000
var durNYms = 23400 * 1000

src = hlc3
vol = request.security(custominp ? customasset : syminfo.tickerid, timeframe.period, volume)

resetD = timeframe.change('D')
[vD, sD] = vwap(src, vol, resetD)
u1D = vD + sD
u2D = vD + sD * 2
l1D = vD - sD
l2D = vD - sD * 2

var float pVD  = na
var float pU1D = na
var float pU2D = na
var float pL1D = na
var float pL2D = na
if resetD
    pVD  := vD[1]
    pU1D := u1D[1]
    pU2D := u2D[1]
    pL1D := l1D[1]
    pL2D := l2D[1]

isNY = time == time(timeframe.period, '0930-1600', 'America/New_York')
openNY = isNY and not isNY[1]

[vN, sN] = vwap(src, isNY ? vol : 0.0, openNY)
u1N = vN + sN
u2N = vN + sN * 2
l1N = vN - sN
l2N = vN - sN * 2

var float pVN  = na
var float pU1N = na
var float pU2N = na
var float pL1N = na
var float pL2N = na
if openNY
    pVN  := vN[1]
    pU1N := u1N[1]
    pU2N := u2N[1]
    pL1N := l1N[1]
    pL2N := l2N[1]

resetW = timeframe.change('W')
[vW, sW] = vwap(src, vol, resetW)
u1W = vW + sW
u2W = vW + sW * 2
l1W = vW - sW
l2W = vW - sW * 2

var float pVW  = na
var float pU1W = na
var float pU2W = na
var float pL1W = na
var float pL2W = na
if resetW
    pVW  := vW[1]
    pU1W := u1W[1]
    pU2W := u2W[1]
    pL1W := l1W[1]
    pL2W := l2W[1]

rlnt = switch rollinglnt
    'Mix' => 21
    'Short' => 11
    'Mid' => 34
    'Long' => 50
[vR1, sR1] = rvwap(src, vol, rlnt)
[vR2, sR2] = rvwap(src, vol, 9)
[vR3, sR3] = rvwap(src, vol, 55)
vR = rollinglnt == 'Mix' ? math.avg(vR1, vR2, vR3) : vR1
sR = rollinglnt == 'Mix' ? math.avg(sR1, sR2, sR3) : sR1
u1R = vR + sR
u2R = vR + sR * 2
l1R = vR - sR
l2R = vR - sR * 2

dpShowMean = dailypastinp == 'Mean' or dailypastinp == 'Mean & Deviations'
dpShowDev = dailypastinp == 'Deviations' or dailypastinp == 'Mean & Deviations'

npShowMean = nypastinp == 'Mean' or nypastinp == 'Mean & Deviations'
npShowDev = nypastinp == 'Deviations' or nypastinp == 'Mean & Deviations'

wpShowMean = weeklypastinp == 'Mean' or weeklypastinp == 'Mean & Deviations'
wpShowDev = weeklypastinp == 'Deviations' or weeklypastinp == 'Mean & Deviations'

// ┌─────────────────────────────────────────────────────────────┐
// │                           Plotting                          │
// └─────────────────────────────────────────────────────────────┘

// Extended Hour
dcShowMean = dailycurrentinp == 'Mean' or dailycurrentinp == 'Mean & Deviations'
dcShowDev = dailycurrentinp == 'Deviations' or dailycurrentinp == 'Mean & Deviations'
dcFillArea = dailycurrentfill == 'Area' or dailycurrentfill == 'Extensions & Area'
dcFillExt = dailycurrentfill == 'Extensions' or dailycurrentfill == 'Extensions & Area'
dcFillInt = dailycurrentfill == 'Internal'

pDC_U2 = plot(dcShowDev  and not resetD ? u2D : na, 'D Current Upper 2', dnc1,  1, style = plot.style_linebr)
pDC_U1 = plot(dcShowDev  and not resetD ? u1D : na, 'D Current Upper 1', dnc1,  1, style = plot.style_linebr, linestyle = plot.linestyle_dotted)
pDC_M = plot(dcShowMean and not resetD ? vD  : na, 'D Current Mean',    midc1, 1, style = plot.style_linebr)
pDC_L1 = plot(dcShowDev  and not resetD ? l1D : na, 'D Current Lower 1', upc1,  1, style = plot.style_linebr, linestyle = plot.linestyle_dotted)
pDC_L2 = plot(dcShowDev  and not resetD ? l2D : na, 'D Current Lower 2', upc1,  1, style = plot.style_linebr)

dcTop = dcFillExt ? color.new(dnc1, 84) : dcFillArea ? color.new(midc1, 92) : na
dcMid = dcFillArea or dcFillInt ? color.new(midc1, 92) : na
dcBot = dcFillExt ? color.new(upc1, 84) : dcFillArea ? color.new(midc1, 92) : na

fill(pDC_U2, pDC_U1, dcTop)
fill(pDC_U1, pDC_L1, dcMid)
fill(pDC_L1, pDC_L2, dcBot)

var Levels pastD = na
if resetD and (dpShowMean or dpShowDev) and not na(pVD)
    if not na(pastD)
        pastD.trim(time)
    pastD := drawPast(pVD, pU1D, pU2D, pL1D, pL2D, time, time + durDms, dpShowMean, dpShowDev, dailypastfill, midc1, upc1, dnc1)

// Regular Trading Hours
ncShowMean = nycurrentinp == 'Mean' or nycurrentinp == 'Mean & Deviations'
ncShowDev = nycurrentinp == 'Deviations' or nycurrentinp == 'Mean & Deviations'
ncFillArea = nycurrentfill == 'Area' or nycurrentfill == 'Extensions & Area'
ncFillExt = nycurrentfill == 'Extensions' or nycurrentfill == 'Extensions & Area'
ncFillInt = nycurrentfill == 'Internal'

pNC_U2 = plot(ncShowDev and isNY and not openNY ? u2N : na, 'NY Current Upper 2', dnc2, 1, style = plot.style_linebr)
pNC_U1 = plot(ncShowDev and isNY and not openNY ? u1N : na, 'NY Current Upper 1', dnc2, 1, style = plot.style_linebr, linestyle = plot.linestyle_dotted)
pNC_M = plot(ncShowMean and isNY and not openNY ? vN : na, 'NY Current Mean', midc2, 1, style = plot.style_linebr)
pNC_L1 = plot(ncShowDev and isNY and not openNY ? l1N : na, 'NY Current Lower 1', upc2, 1, style = plot.style_linebr, linestyle = plot.linestyle_dotted)
pNC_L2 = plot(ncShowDev and isNY and not openNY ? l2N : na, 'NY Current Lower 2', upc2, 1, style = plot.style_linebr)

ncTop = ncFillExt ? color.new(dnc2, 84) : ncFillArea ? color.new(midc2, 92) : na
ncMid = ncFillArea or ncFillInt ? color.new(midc2, 92) : na
ncBot = ncFillExt ? color.new(upc2, 84) : ncFillArea ? color.new(midc2, 92) : na

fill(pNC_U2, pNC_U1, ncTop)
fill(pNC_U1, pNC_L1, ncMid)
fill(pNC_L1, pNC_L2, ncBot)

var Levels pastN = na
if openNY and (npShowMean or npShowDev) and not na(pVN)
    if not na(pastN)
        pastN.trim(time)
    pastN := drawPast(pVN, pU1N, pU2N, pL1N, pL2N, time, time + durNYms, npShowMean, npShowDev, nypastfill, midc2, upc2, dnc2)

// Weekly
wcShowMean = weeklycurrentinp == 'Mean' or weeklycurrentinp == 'Mean & Deviations'
wcShowDev = weeklycurrentinp == 'Deviations' or weeklycurrentinp == 'Mean & Deviations'
wcFillArea = weeklycurrentfill == 'Area' or weeklycurrentfill == 'Extensions & Area'
wcFillExt = weeklycurrentfill == 'Extensions' or weeklycurrentfill == 'Extensions & Area'
wcFillInt = weeklycurrentfill == 'Internal'

pWC_U2 = plot(wcShowDev and not resetW ? u2W : na, 'W Current Upper 2', dnc3, 1, style = plot.style_linebr)
pWC_U1 = plot(wcShowDev and not resetW ? u1W : na, 'W Current Upper 1', dnc3, 1, style = plot.style_linebr, linestyle = plot.linestyle_dotted)
pWC_M = plot(wcShowMean and not resetW ? vW  : na, 'W Current Mean', midc3, 1, style = plot.style_linebr)
pWC_L1 = plot(wcShowDev and not resetW ? l1W : na, 'W Current Lower 1', upc3, 1, style = plot.style_linebr, linestyle = plot.linestyle_dotted)
pWC_L2 = plot(wcShowDev and not resetW ? l2W : na, 'W Current Lower 2', upc3, 1, style = plot.style_linebr)

wcTop = wcFillExt ? color.new(dnc3, 84) : wcFillArea ? color.new(midc3, 92) : na
wcMid = wcFillArea or wcFillInt ? color.new(midc3, 92) : na
wcBot = wcFillExt ? color.new(upc3, 84) : wcFillArea ? color.new(midc3, 92) : na

fill(pWC_U2, pWC_U1, wcTop)
fill(pWC_U1, pWC_L1, wcMid)
fill(pWC_L1, pWC_L2, wcBot)

var Levels pastW = na
if resetW and (wpShowMean or wpShowDev) and not na(pVW)
    if not na(pastW)
        pastW.trim(time)
    pastW := drawPast(pVW, pU1W, pU2W, pL1W, pL2W, time, time + durWms, wpShowMean, wpShowDev, weeklypastfill, midc3, upc3, dnc3)

// Rolling
rcShowMean = rollinginp == 'Mean' or rollinginp == 'Mean & Deviations'
rcShowDev = rollinginp == 'Deviations' or rollinginp == 'Mean & Deviations'
rcFillArea = rollingfill == 'Area' or rollingfill == 'Extensions & Area'
rcFillExt = rollingfill == 'Extensions' or rollingfill == 'Extensions & Area'
rcFillInt = rollingfill == 'Internal'

pR_U2 = plot(rcShowDev ? u2R : na, 'R Upper 2', dnc4, 1, style = plot.style_linebr)
pR_U1 = plot(rcShowDev ? u1R : na, 'R Upper 1', dnc4, 1, style = plot.style_linebr, linestyle = plot.linestyle_dotted)
pR_M = plot(rcShowMean ? vR : na, 'R Mean', midc4, 1, style = plot.style_linebr)
pR_L1 = plot(rcShowDev ? l1R : na, 'R Lower 1', upc4, 1, style = plot.style_linebr, linestyle = plot.linestyle_dotted)
pR_L2 = plot(rcShowDev ? l2R : na, 'R Lower 2', upc4, 1, style = plot.style_linebr)

rcTop = rcFillExt ? color.new(dnc4, 84) : rcFillArea ? color.new(midc4, 92) : na
rcMid = rcFillArea or rcFillInt ? color.new(midc4, 92) : na
rcBot = rcFillExt ? color.new(upc4, 84) : rcFillArea ? color.new(midc4, 92) : na

fill(pR_U2, pR_U1, rcTop)
fill(pR_U1, pR_L1, rcMid)
fill(pR_L1, pR_L2, rcBot)

// ┌─────────────────────────────────────────────────────────────┐
// │                        End of Script                        │
// └─────────────────────────────────────────────────────────────┘
````
