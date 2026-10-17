# Modern Bollinger Bands [GBB]

- url: https://www.tradingview.com/script/TH0fYiRa-Modern-Bollinger-Bands-GBB/
- type: indicator
- pine_id: PUB;a090f8281e6e4593b9f9c16fd202c9ed
- version: 1.0

## Description

[b]Modern Bollinger Bands [GBB][/b]

I rebuilt Bollinger Bands. Not because the original is bad, John Bollinger's work has held up for forty years, but because the defaults everyone uses were designed for daily stock charts in the 1980s and we're putting them on crypto perps at 3am. 
[b]
WHAT'S WRONG WITH THE CLASSIC[/b]

Five things, in my view.

The window is always 20 bars. Doesn't matter if the market is in a fast news week or a dead summer range, you get the same 20.

The bands assume returns follow a bell curve. Asset returns have fat tails, so price pokes outside a two sigma band far more often than the theory says it should.

A band touch has no meaning on its own. In a range, fading the touch works okay. In a trend, price walks down the band and runs over every single fade. The classic gives you nothing to tell those two situations apart, and that's the flaw that costs people real money.

The SMA basis is slow. Equal weight on every bar means the middle line describes the market as it was roughly ten bars ago.

And band width isn't comparable to anything. What counts as narrow on one chart means nothing on another, so squeeze thresholds end up being eyeballed.

[b]WHAT I CHANGED[/b]

The length adapts. An Ehlers homodyne discriminator measures the dominant cycle in price and the window becomes half of it, between 10 and 50 bars. When there's no measurable cycle because the market is trending too hard, the length freezes at the last good value instead of guessing.

The basis is a KAMA instead of SMA. It speeds up when price is actually going somewhere and almost stops updating in chop.

The bands are percentile bands, not sigma bands. 97.5th and 2.5th percentile of the real deviations around the basis, nearest rank, over a longer window. Your market's actual tails, not a textbook bell curve.

I added a regime filter: Kaufman efficiency ratio, percentile ranked against the last 252 bars, with 70/55 hysteresis so it doesn't flip flop on the boundary. Blue bands are RANGE, orange bands are TREND, and the signals respect the color.

And the squeeze is a score from 0 to 100. Percentile rank of band width against the last year of bars. A score of 8 reads the same on every symbol and every timeframe.

[b]THE SIGNALS[/b]

Three types, that only trigger on candle close, so there is nothing repainted.

Singal1: Blue triangles. The classic fade, but only where it belongs. Price closes outside a band, the next bar closes back inside, and the regime is RANGE. In TREND this signal simply doesn't exist.

Singal2: Orange circles. Trend pullback. Price dips into a zone around the basis, then closes back in the trend direction. TREND only and with the trend only. One thing about the chart markers: in a long trend this setup can fire on several nearby bars, so the chart draws the first circle of a cluster and skips the repeats for a few bars, so the chart does not get too cluttered.

Signal3: Diamonds. Squeeze release after at least 5 bars of squeeze, then the squeeze ends and price closes outside a band on that same bar. Important: While this is the most intuitive setup of the three and it's the one my testing supports least. Release events showed the same forward 20 bar volatility as typical bars from the same hours. Volume confirmation didn't help either, I tested that separately. The diamonds mark a real event, compression ended and price left the bands, but whether that's worth anything is a question my data answered with no. I included the signal and alert for it anyway, because I know many of you will want it.

[b]SETTINGS[/b]

Everything above is a toggle. The groups match the settings dialog, so here's what each one actually does and when you'd touch it.

Adaptive length: Length mode switches between Adaptive and Fixed. Adaptive is the point of this indicator. Fixed with the default of 20 exists for two reasons: reproducing the classic, and for people who want to trust their own number. The fixed length input only matters in Fixed mode.

Basis / bands: Basis picks KAMA or SMA for the middle line, bands picks Robust (percentile) or Stdev (classic sigma). Set Fixed 20 plus SMA plus Stdev and you have exact 1980s Bollinger Bands, that combination is deliberately supported. The stdev multiplier (2.0) only applies in Stdev mode. The robust percentiles (97.5 and 2.5) set where the bands sit in the deviation distribution, pull them toward 95/5 if you want more touches and more signals, push them out if you want only the extremes. The robust window multiplier and floor control how much history the percentile estimate uses, 4 times the adaptive length with a floor of 80 bars by default. Shorter windows react faster to volatility shifts but the tail estimates get noisy, I would leave these alone unless you know why you're changing them. KAMA fast and slow (2 and 30) are the standard Kaufman speeds, the basis moves between a 2 period and a 30 period EMA depending on how efficient the move is.

Regime / squeeze: KER length (20) is the window for the efficiency ratio itself. The percentile rank window (252) is what "recent history" means for both the regime and the squeeze score, about one year of daily bars, about ten days on 1h. TREND enter (70) and TREND exit (55) are the hysteresis levels: the market has to rank above the 70th percentile in efficiency to be called TREND and drop back below the 55th to be called RANGE again. Widen the gap and the regime switches less often but later, narrow it and you get earlier calls with more flip flops. These defaults sat on a flat plateau in sensitivity testing, meaning nearby values gave nearly identical results, so there's no magic in 70/55, but there's also nothing to gain from tuning them. Squeeze threshold (20) defines squeeze as band width below the 20th percentile, and min bars in squeeze (5) stops one bar dips from counting as compression.

Signals: One input, the S2 touch fraction (0.25). It sets how close to the basis a pullback has to come, measured as a fraction of the band halfwidth. Smaller means stricter pullbacks and fewer S2 signals.

Display: Clean display preset strips everything down to the three lines, no fill, no markers, no panel. The info panel (regime, KER percentile, adaptive length with its frozen flag, squeeze score, last signal) is off by default, turn it on when you want to see what the indicator is "thinking". Signal markers and the squeeze heat on the band fill can be switched off separately. The S2 marker debounce (5) is the cosmetic cluster filter from the signals section, set it to 0 if you want every circle drawn.

Parity: You can ignore this group for trading. It pins the computation start to a fixed timestamp so every value on the chart can be reproduced bar for bar against a Python reference implementation. It's how the validation was done and it stays in so anyone can check my work.

ALERTS

Six per signal alerts plus the combined JSON one with symbol, timeframe, signal, regime, squeeze score and band levels. Once per confirmed bar close, built for webhook bots.

No indicator prints money, this one included. It tells you regime, structure and volatility state, with the evidence behind each part published, nulls and all. Trade safe.

## Source Code

````pine
//@version=6
// Modern Bollinger Bands [GBB] 
indicator("Modern Bollinger Bands [GBB]", "MBB", overlay = true, max_bars_back = 500)

// ─────────────────────────────── inputs ───────────────────────────────

gA = "Adaptive length"
lenMode    = input.string("Adaptive", "Length mode", options = ["Adaptive", "Fixed"], group = gA, tooltip = "Fixed = classic parity/ablation mode", display = display.none)
fixedLen   = input.int(20, "Fixed length", minval = 2, group = gA, display = display.none)
LEN_MIN    = 10
LEN_MAX    = 50
DC_WARMUP  = 40
MAX_PER    = 50.0

gB = "Basis / bands"
basisMode  = input.string("KAMA", "Basis", options = ["KAMA", "SMA"], group = gB, display = display.none)
bandMode   = input.string("Robust", "Bands", options = ["Robust", "Stdev"], group = gB, display = display.none)
stdevK     = input.float(2.0, "Stdev multiplier", step = 0.1, group = gB, display = display.none)
pHi        = input.float(97.5, "Robust upper percentile", group = gB, display = display.none)
pLo        = input.float(2.5, "Robust lower percentile", group = gB, display = display.none)
lenPctMult = input.int(4, "Robust window multiplier", minval = 1, group = gB, display = display.none)
lenPctFlr  = input.int(80, "Robust window floor", group = gB, display = display.none)
kamaFast   = input.int(2, "KAMA fast", group = gB, display = display.none)
kamaSlow   = input.int(30, "KAMA slow", group = gB, display = display.none)

gC = "Regime / squeeze"
kerLen     = input.int(20, "KER length", group = gC, display = display.none)
rankLen    = input.int(252, "Percentile rank window", group = gC, display = display.none)
trendEnter = input.float(70, "TREND enter (KER pct >=)", group = gC, display = display.none)
trendExit  = input.float(55, "TREND exit (KER pct <=)", group = gC, display = display.none)
sqThresh   = input.float(20, "Squeeze threshold (score <)", group = gC, display = display.none)
sqMinBars  = input.int(5, "Min bars in squeeze before release", group = gC, display = display.none)

gD = "Signals"
touchFrac  = input.float(0.25, "S2 basis-touch fraction of halfwidth", group = gD, display = display.none)

gE = "Display"
cleanMode  = input.bool(false, "Clean display preset", group = gE, display = display.none)
showHud    = input.bool(false, "HUD panel", group = gE, display = display.none)
showSigs   = input.bool(true, "Signal markers", group = gE, display = display.none)
showHeat   = input.bool(true, "Squeeze heat on fill", group = gE, display = display.none)
s2Debounce = input.int(5, "S2 marker debounce (bars, 0 = show every signal)", minval = 0, group = gE, tooltip = "Chart markers only: shows the first S2 dot of a cluster and suppresses repeats until the signal has been quiet this many bars. Raw signals, alerts and parity series are unaffected.", display = display.none)

gP = "Parity"
useStart   = input.bool(false, "Parity: gate computation at start time", group = gP, display = display.none)
startTime  = input.time(timestamp("2023-01-01T00:00:00+0000"), "Parity computation start (UTC)", group = gP, display = display.none)

// ─────────────────────── bar counter (parity gating) ───────────────────────
bool active = not useStart or time >= startTime
var int startBar = na
if active and na(startBar)
    startBar := bar_index
int nsb = active and not na(startBar) ? bar_index - startBar : -1  // bars since start (= oracle t)

// ─────────────────────── Homodyne Discriminator (EACO v2.1 canon) ───────────────────────
float sm  = 0.0
float det = 0.0
float i1v = 0.0
float q1v = 0.0
float i2v = 0.0
float q2v = 0.0
float reV = 0.0
float imV = 0.0
float per = 0.0
float sper = 0.0
if nsb >= 6
    sm := (4.0 * hl2 + 3.0 * hl2[1] + 2.0 * hl2[2] + hl2[3]) / 10.0
    mult = 0.075 * nz(per[1]) + 0.54
    det := (0.0962 * sm + 0.5769 * nz(sm[2]) - 0.5769 * nz(sm[4]) - 0.0962 * nz(sm[6])) * mult
    q1v := (0.0962 * det + 0.5769 * nz(det[2]) - 0.5769 * nz(det[4]) - 0.0962 * nz(det[6])) * mult
    i1v := nz(det[3])
    jI = (0.0962 * i1v + 0.5769 * nz(i1v[2]) - 0.5769 * nz(i1v[4]) - 0.0962 * nz(i1v[6])) * mult
    jQ = (0.0962 * q1v + 0.5769 * nz(q1v[2]) - 0.5769 * nz(q1v[4]) - 0.0962 * nz(q1v[6])) * mult
    i2v := 0.2 * (i1v - jQ) + 0.8 * nz(i2v[1])
    q2v := 0.2 * (q1v + jI) + 0.8 * nz(q2v[1])
    reV := 0.2 * (i2v * nz(i2v[1]) + q2v * nz(q2v[1])) + 0.8 * nz(reV[1])
    imV := 0.2 * (i2v * nz(q2v[1]) - q2v * nz(i2v[1])) + 0.8 * nz(imV[1])
    p = nz(per[1])
    if imV != 0.0 and reV != 0.0
        p := 2.0 * math.pi / math.atan(imV / reV)
    // canonical order: rate limits FIRST, hard clamp SECOND (EACO v2.1)
    if p > 1.5 * nz(per[1])
        p := 1.5 * nz(per[1])
    if p < 0.67 * nz(per[1])
        p := 0.67 * nz(per[1])
    p := math.min(math.max(p, 6.0), MAX_PER)
    per := 0.2 * p + 0.8 * nz(per[1])
    sper := 0.33 * per + 0.67 * nz(sper[1])

bool cycleValid = nsb >= DC_WARMUP and sper < MAX_PER * 0.85

// ─────────────────────── adaptive length (freeze rule, spec 2.1) ───────────────────────
var int lastLen = na
if cycleValid
    lastLen := math.min(math.max(math.round(sper / 2.0), LEN_MIN), LEN_MAX)
int lenA = lenMode == "Adaptive" ? lastLen : fixedLen

// ─────────────────────── basis (spec 2.2) ───────────────────────
var int basisStartN = na
if na(basisStartN) and not na(lenA) and nsb >= lenA
    basisStartN := nsb

var float kamaPrev = na
float basis = na
if not na(basisStartN) and not na(lenA) and nsb >= lenA
    if basisMode == "SMA"
        s = 0.0
        for i = 0 to lenA - 1
            s += close[i]
        basis := s / lenA
    else
        if nsb == basisStartN  // seed: SMA of first ER window (spec section 5)
            s = 0.0
            for i = 0 to lenA - 1
                s += close[i]
            kamaPrev := s / lenA
        chg = math.abs(close - close[lenA])
        vs = 0.0
        for i = 0 to lenA - 1
            vs += math.abs(close[i] - close[i + 1])
        er = vs > 0 ? chg / vs : 0.0
        fastSc = 2.0 / (kamaFast + 1)
        slowSc = 2.0 / (kamaSlow + 1)
        sc = math.pow(er * (fastSc - slowSc) + slowSc, 2)
        kamaPrev := kamaPrev + sc * (close - kamaPrev)
        basis := kamaPrev

// ─────────────────────── bands (spec 2.3) ───────────────────────
int lenPctMax = math.max(lenPctMult * LEN_MAX, lenPctFlr)  // fixed validity: never flickers
float d = close - basis
float upperBand = na
float lowerBand = na
if not na(basis)
    if bandMode == "Stdev"
        m = 0.0
        for i = 0 to lenA - 1
            m += close[i]
        m /= lenA
        v = 0.0
        for i = 0 to lenA - 1
            v += math.pow(close[i] - m, 2)
        sd = math.sqrt(v / lenA)  // population, = ta.stdev default
        upperBand := basis + stdevK * sd
        lowerBand := basis - stdevK * sd
    else if nsb - basisStartN + 1 >= lenPctMax
        int lp = math.max(lenPctMult * lenA, lenPctFlr)
        arr = array.new_float()
        for i = 0 to lp - 1
            array.push(arr, d[i])
        array.sort(arr, order.ascending)
        rHi = math.min(math.max(math.ceil(pHi / 100.0 * lp), 1), lp)
        rLo = math.min(math.max(math.ceil(pLo / 100.0 * lp), 1), lp)
        upperBand := basis + array.get(arr, rHi - 1)  // UNCLAMPED by design (spec 2.3)
        lowerBand := basis + array.get(arr, rLo - 1)

// ─────────────────────── regime gate (spec 2.4) ───────────────────────
float ker = na
if nsb >= kerLen
    chg = math.abs(close - close[kerLen])
    vs = 0.0
    for i = 0 to kerLen - 1
        vs += math.abs(close[i] - close[i + 1])
    ker := vs > 0 ? chg / vs : 0.0

// percentrank: % of previous rankLen values <= current, current excluded (= oracle)
f_percentrank(float src, int len) =>
    float out = na
    if not na(src)
        cnt = 0
        ok = true
        for i = 1 to len
            v = src[i]
            if na(v)
                ok := false
                break
            if v <= src
                cnt += 1
        out := ok ? 100.0 * cnt / len : na
    out

float kerPct = f_percentrank(ker, rankLen)
var int regState = na
if not na(kerPct)
    if na(regState)
        regState := 0  // start in RANGE
    if regState == 0 and kerPct >= trendEnter
        regState := 1
    else if regState == 1 and kerPct <= trendExit
        regState := 0

// ─────────────────────── squeeze (spec 2.5) ───────────────────────
float bw = not na(upperBand) and basis != 0.0 ? (upperBand - lowerBand) / basis : na
float sqScore = f_percentrank(bw, rankLen)
var int sqRun = 0
bool inSqueeze = false
bool release = false
if not na(sqScore)
    inSqueeze := sqScore < sqThresh
    release := sqScore > sqThresh and not na(sqScore[1]) and sqScore[1] <= sqThresh and sqRun >= sqMinBars
    sqRun := inSqueeze ? sqRun + 1 : 0

// ─────────────────────── signals (spec 2.6 exact two-bar definitions) ───────────────────────
bool bandsOk = not na(upperBand) and not na(upperBand[1]) and not na(regState)
bool insideNow = close >= lowerBand and close <= upperBand

bool s1Long  = bandsOk and regState == 0 and close[1] < lowerBand[1] and insideNow
bool s1Short = bandsOk and regState == 0 and close[1] > upperBand[1] and insideNow

float b5 = basis[5]
float hwP = (upperBand[1] - lowerBand[1]) / 2.0
int trendDir = not na(b5) ? basis > b5 ? 1 : basis < b5 ? -1 : 0 : 0
bool s2Base = bandsOk and regState == 1 and nsb >= 5 and not na(b5)
bool s2Long  = s2Base and trendDir == 1 and low[1] <= basis[1] + touchFrac * hwP and close[1] >= basis[1] - touchFrac * hwP and close > basis and close > close[1]
bool s2Short = s2Base and trendDir == -1 and high[1] >= basis[1] - touchFrac * hwP and close[1] <= basis[1] + touchFrac * hwP and close < basis and close < close[1]

bool s3Long  = release and close > upperBand
bool s3Short = release and close < lowerBand

// ─────────────────────── alerts (confirmed bars only, spec 2.6) ───────────────────────
alertcondition(s1Long,  "GBB S1 long (range fade)",         "GBB S1 long: range fade at lower band")
alertcondition(s1Short, "GBB S1 short (range fade)",        "GBB S1 short: range fade at upper band")
alertcondition(s2Long,  "GBB S2 long (trend continuation)", "GBB S2 long: basis pullback continuation")
alertcondition(s2Short, "GBB S2 short (trend continuation)","GBB S2 short: basis pullback continuation")
alertcondition(s3Long,  "GBB S3 long (squeeze breakout)",   "GBB S3 long: squeeze release breakout up")
alertcondition(s3Short, "GBB S3 short (squeeze breakout)",  "GBB S3 short: squeeze release breakout down")

var string lastSignal = "—"
string sigNow = s1Long ? "S1_LONG" : s1Short ? "S1_SHORT" : s2Long ? "S2_LONG" : s2Short ? "S2_SHORT" : s3Long ? "S3_LONG" : s3Short ? "S3_SHORT" : na
if barstate.isconfirmed and not na(sigNow)
    lastSignal := sigNow
    alert('{"indicator":"GBB","symbol":"' + syminfo.ticker + '","tf":"' + timeframe.period + '","signal":"' + sigNow + '","regime":' + str.tostring(regState) + ',"squeeze_score":' + str.tostring(sqScore, "#.##") + ',"upper":' + str.tostring(upperBand, format.mintick) + ',"basis":' + str.tostring(basis, format.mintick) + ',"lower":' + str.tostring(lowerBand, format.mintick) + '}', alert.freq_once_per_bar_close)

// ─────────────────────── display ───────────────────────
color cTrend = color.new(#e8a33d, 0)
color cRange = color.new(#3da5e8, 0)
color cBasis = na(regState) ? color.gray : regState == 1 ? cTrend : cRange
int fillAlpha = showHeat and not cleanMode and not na(sqScore) ? int(97 - 7 * (1 - sqScore / 100)) : 96
color cFill = na(regState) ? color.new(color.gray, 97) : color.new(regState == 1 ? cTrend : cRange, fillAlpha)

// display.pane only: no status-line numbers, no price-scale labels on the right axis
pB = plot(basis, "Basis", color = cBasis, linewidth = 2, display = display.pane)
pU = plot(upperBand, "Upper band", color = color.new(cBasis, 40), display = display.pane)
pL = plot(lowerBand, "Lower band", color = color.new(cBasis, 40), display = display.pane)
fill(pU, pL, color = cleanMode ? na : cFill, title = "Band fill")

plotshape(showSigs and not cleanMode and s1Long,  "S1 long",  shape.triangleup,   location.belowbar, cRange,  size = size.tiny,  display = display.pane)
plotshape(showSigs and not cleanMode and s1Short, "S1 short", shape.triangledown, location.abovebar, cRange,  size = size.tiny,  display = display.pane)
// display-only S2 debounce: first marker of a cluster, then quiet until the raw
// signal has been absent for s2Debounce bars. Signal series/alerts untouched.
var int lastS2L = na
var int lastS2S = na
bool s2LongMark  = s2Long  and (s2Debounce == 0 or na(lastS2L) or bar_index - lastS2L > s2Debounce)
bool s2ShortMark = s2Short and (s2Debounce == 0 or na(lastS2S) or bar_index - lastS2S > s2Debounce)
if s2Long
    lastS2L := bar_index
if s2Short
    lastS2S := bar_index
plotshape(showSigs and not cleanMode and s2LongMark,  "S2 long",  shape.circle,   location.belowbar, cTrend,  size = size.tiny,  display = display.pane)
plotshape(showSigs and not cleanMode and s2ShortMark, "S2 short", shape.circle,   location.abovebar, cTrend,  size = size.tiny,  display = display.pane)
plotshape(showSigs and not cleanMode and s3Long,  "S3 long",  shape.diamond,      location.belowbar, color.new(#7ddc82, 0), size = size.small, display = display.pane)
plotshape(showSigs and not cleanMode and s3Short, "S3 short", shape.diamond,      location.abovebar, color.new(#dc7d7d, 0), size = size.small, display = display.pane)

var table hud = table.new(position.top_right, 2, 5, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 70))
if barstate.islast and showHud and not cleanMode
    table.cell(hud, 0, 0, "Regime",    text_color = color.gray,  text_size = size.small)
    table.cell(hud, 1, 0, na(regState) ? "warm-up" : regState == 1 ? "TREND" : "RANGE", text_color = na(regState) ? color.gray : regState == 1 ? cTrend : cRange, text_size = size.small)
    table.cell(hud, 0, 1, "KER pct",   text_color = color.gray,  text_size = size.small)
    table.cell(hud, 1, 1, na(kerPct) ? "—" : str.tostring(kerPct, "#.#"), text_color = color.white, text_size = size.small)
    table.cell(hud, 0, 2, "Adaptive len", text_color = color.gray, text_size = size.small)
    table.cell(hud, 1, 2, na(lenA) ? "—" : str.tostring(lenA) + (cycleValid ? "" : " (frozen)"), text_color = color.white, text_size = size.small)
    table.cell(hud, 0, 3, "Squeeze",   text_color = color.gray,  text_size = size.small)
    table.cell(hud, 1, 3, na(sqScore) ? "—" : str.tostring(sqScore, "#.#") + (inSqueeze ? " ●" : ""), text_color = inSqueeze ? color.new(#7ddc82, 0) : color.white, text_size = size.small)
    table.cell(hud, 0, 4, "Last signal", text_color = color.gray, text_size = size.small)
    table.cell(hud, 1, 4, lastSignal, text_color = color.white, text_size = size.small)

// ─────────────────────── parity plots (oracle column names) ───────────────────────
// Visible in the data window (and chart-data exports) only while parity mode is on;
// hidden everywhere in normal use so they don't clutter the Data Window / Style tab.
pDisp = useStart ? display.data_window : display.none
plot(sper,                       "dc",            display = pDisp)
plot(cycleValid ? 1 : 0,         "dc_valid",      display = pDisp)
plot(lenA,                       "len_adaptive",  display = pDisp)
plot(basis,                      "basis",         display = pDisp)
plot(upperBand,                  "upper",         display = pDisp)
plot(lowerBand,                  "lower",         display = pDisp)
plot(ker,                        "ker",           display = pDisp)
plot(kerPct,                     "ker_pct",       display = pDisp)
plot(regState,                   "regime",        display = pDisp)
plot(bw,                         "bw",            display = pDisp)
plot(sqScore,                    "squeeze_score", display = pDisp)
plot(not na(sqScore) and inSqueeze ? 1 : 0, "squeeze_state", display = pDisp)
plot(release ? 1 : 0,            "release",       display = pDisp)
plot(s1Long ? 1 : 0,             "s1_long",       display = pDisp)
plot(s1Short ? 1 : 0,            "s1_short",      display = pDisp)
plot(s2Long ? 1 : 0,             "s2_long",       display = pDisp)
plot(s2Short ? 1 : 0,            "s2_short",      display = pDisp)
plot(s3Long ? 1 : 0,             "s3_long",       display = pDisp)
plot(s3Short ? 1 : 0,            "s3_short",      display = pDisp)
````
