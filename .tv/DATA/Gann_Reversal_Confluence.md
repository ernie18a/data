<!-- tradingview-pine-id: PUB;64b32d876b47441ab7eec8cc0cbfcb95 -->
<!-- tradingviewscripts-format: 1 -->
# Gann Reversal Confluence

Source: https://www.tradingview.com/script/Q18RGwxV-Gann-Reversal-Confluence/

## Description

Why this works

W.D. Gann never traded a reversal bar in isolation — a swing high/low break, key reversal, or outside bar was a trigger, not a signal on its own. He wanted it lining up with the bigger picture: was the move overextended, was volume backing it, was it a big enough bar to matter. Most free "Gann reversal" scripts on TradingView just plot the raw bar pattern and stop there — every swing break gets a triangle, whether it's a meaningful turn or noise. This indicator keeps the classic pattern detection but scores each one against the context Gann actually cared about, so you can see how much is lining up, not just that a shape appeared.

How this works

Pattern detection — pick one of three classic reversal triggers: Swing (price closes beyond the recent N-bar high/low), Key Reversal (new extreme that closes back through the prior close), or Outside Bar (engulfs the prior range and closes in the reversal direction).
Confluence scoring — every raw pattern is checked against up to five independent factors:
Range (ATR) — was the bar itself big enough to matter, or just noise?
Volume — did participation back the move?
Momentum (RSI) — was the market actually stretched, or was this a mid-range wiggle?
Trend (EMA) — is this a pullback with the trend, or a potential trend change against it? (shown, not scored against you)
Hour-ruler (optional, off by default) — a traditional Chaldean planetary-hour tag. Descriptive only, not a validated filter — treat it as a curiosity layered on top of the technical factors, not evidence on its own.
Cooldown — a minimum bar gap between signals stops the same swing from re-triggering repeatedly.
Everything commits on bar close only. Nothing here repaints or changes after the fact.

How to use it

Start with the defaults. Watch how the confluence score (shown next to each signal and in the status table) moves with the setups you'd have taken anyway.
Raise "Minimum confluence score to show signal" to hide everything below your conviction threshold — e.g. set it to 3 to only see signals where 3+ factors agree.
Use the level line each signal draws as a reference point for how price behaved on the next visit, not as a target.
This is a confluence aid, meant to sit alongside your own read of the chart and risk management — not a standalone entry/exit system.

Settings

Logic — reversal method, swing length, close vs. wick confirmation, minimum bars between signals.
Confluence — independently toggle ATR/Volume/RSI/Trend, tune each threshold, and set the minimum score required to show a signal.
Astro (optional) — off by default; enables the hour-ruler tag and lets you set a location for the sunrise/sunset calc it depends on.
Display — swing band, signal level lines, background highlight, confluence score label, status table (with position control), colors, and line styling.
Non-repainting. Every signal is final the moment it prints.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PyraTime

//@version=6
indicator("Gann Reversal Confluence", overlay = true, max_lines_count = 500)

// Automates Gann's two-bar reversal: a turn is flagged when price closes beyond
// the recent swing high/low, on a key reversal bar, or on an outside bar.
// A reversal bar alone isn't a trade signal, so this scores each raw pattern
// against range, volume, momentum, trend, and (optional) planetary hour to show
// how much is actually confirming it. Confirms on bar close only, no repainting.

// --- Inputs: logic ---
method   = input.string("Swing (HiLo)", "Reversal method", options = ["Swing (HiLo)", "Key reversal", "Outside bar"], group = "Logic")
swingLen = input.int(8, "Swing length", minval = 1, maxval = 20, group = "Logic", tooltip = "Bars used for the swing high/low. Lower = more sensitive.")
useClose = input.bool(true, "Confirm on close (vs wick)", group = "Logic", tooltip = "Applies to all three methods: Swing compares close vs the swing band, Key reversal/Outside bar require the close (not just the wick) to have reversed.")
minBarsBetween = input.int(20, "Min bars between signals", minval = 0, maxval = 100, group = "Logic", tooltip = "Suppresses new signals for N bars after the last one, to cut noise on choppy/short swing settings. 0 = no filter.")

// --- Inputs: confluence ---
useATR    = input.bool(true,  "Range significance (ATR)", group = "Confluence", tooltip = "Reversal bar's range must be at least ATR × multiplier — filters out small, low-conviction bars.")
atrLen    = input.int(14, "ATR length", minval = 1, group = "Confluence")
atrMult   = input.float(1.2, "ATR multiplier", minval = 0.1, step = 0.1, group = "Confluence")
useVol    = input.bool(true,  "Volume confirmation", group = "Confluence", tooltip = "Reversal bar's volume must exceed its average by the multiplier. Off automatically on symbols with no volume.")
volLen    = input.int(20, "Volume avg length", minval = 1, group = "Confluence")
volMult   = input.float(1.2, "Volume multiplier", minval = 0.1, step = 0.1, group = "Confluence")
useRSI    = input.bool(true,  "Momentum extreme (RSI)", group = "Confluence", tooltip = "Bullish reversals need RSI at/below the oversold line, bearish need RSI at/above overbought.")
rsiLen    = input.int(14, "RSI length", minval = 1, group = "Confluence")
rsiOS     = input.int(30, "RSI oversold", minval = 1, maxval = 50, group = "Confluence")
rsiOB     = input.int(70, "RSI overbought", minval = 50, maxval = 99, group = "Confluence")
useTrend  = input.bool(true,  "Trend context (EMA)", group = "Confluence", tooltip = "Flags whether the reversal is WITH the prevailing trend (continuation pullback) or AGAINST it (potential trend change) — informational, always counts as a confluence point when the reversal has any relation to the EMA slope.")
trendLen  = input.int(50, "Trend EMA length", minval = 1, group = "Confluence")
minConfluence = input.int(0, "Minimum confluence score to show signal", minval = 0, maxval = 5, group = "Confluence", tooltip = "0 = show every raw reversal pattern regardless of confluence. Raise to only see higher-conviction signals.")

// --- Inputs: astro (hour-ruler tone) ---
gAstro    = "Astro (optional)"
useRuler  = input.bool(false, "Hour-ruler tone (Chaldean)", group = gAstro, tooltip = "Descriptive traditional overlay, not a validated filter: tags a bullish reversal as aligned when the current planetary hour is ruled by Sun/Venus/Jupiter/Moon, and a bearish reversal as aligned when ruled by Mars/Saturn. Mercury-ruled hours are neutral and never contribute. Off by default — treat this as a curiosity/context factor alongside the technical ones, not evidence on its own.")
obs_lat   = input.float(0.0, "Latitude (+N/-S)", minval = -90, maxval = 90, group = gAstro, tooltip = "Only used for the hour-ruler sunrise/sunset calc. 0,0 (Null Island) is a reasonable default for 24/7 crypto.")
obs_lon   = input.float(0.0, "Longitude (+E/-W)", minval = -180, maxval = 180, group = gAstro)

// --- Inputs: display ---
showBand  = input.bool(false, "Show swing band", group = "Display")
showLine  = input.bool(true,  "Draw level at each signal", group = "Display")
showBg    = input.bool(false, "Highlight signal bar background", group = "Display")
showScore = input.bool(true,  "Show confluence score on signal", group = "Display")
showTable = input.bool(true,  "Show status table", group = "Display")
tablePos  = input.string("Top right", "Table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = "Display")
anchor    = input.string("Midpoint", "Level anchor", options = ["Midpoint", "Low", "High"], group = "Display")
lineLen   = input.int(6, "Level length (bars)", minval = 1, maxval = 60, group = "Display")
lineWid   = input.int(1, "Level width", minval = 1, maxval = 4, group = "Display")
lineSty   = input.string("Solid", "Level style", options = ["Solid", "Dashed", "Dotted"], group = "Display")
bullCol   = input.color(color.lime, "Bull", inline = "col", group = "Display")
bearCol   = input.color(color.red,  "Bear", inline = "col", group = "Display")

// --- Parse Line Style ---
parsedStyle = switch lineSty
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    =>          line.style_solid

// --- Swing reference (prior swing high / low) ---
hiBand = ta.highest(high, swingLen)
loBand = ta.lowest(low,  swingLen)

// --- Reversal conditions ---
upTrig = useClose ? close : high
dnTrig = useClose ? close : low

// Swing: price takes out the prior swing extreme
swingUp = upTrig > hiBand[1]
swingDn = dnTrig < loBand[1]

// Key reversal: new low that closes up / new high that closes down
keyUp = low  < low[1]  and (useClose ? close > close[1] and close > open : high > high[1])
keyDn = high > high[1] and (useClose ? close < close[1] and close < open : low  < low[1])

// Outside bar: engulfs the prior range and closes in the reversal direction
outUp = high > high[1] and low < low[1] and (useClose ? close > open : upTrig > dnTrig)
outDn = high > high[1] and low < low[1] and (useClose ? close < open : dnTrig < upTrig)

rawUp = switch method
    "Key reversal" => keyUp
    "Outside bar"  => outUp
    => swingUp

rawDn = switch method
    "Key reversal" => keyDn
    "Outside bar"  => outDn
    => swingDn

// --- Chaldean hour-ruler (only computed if useRuler is on) ---
f_rev(x) => x - math.floor(x / 360.0) * 360.0
f_wrap180(x) =>
    y = x - math.floor(x / 360.0) * 360.0
    y > 180.0 ? y - 360.0 : y

f_atan2(y, x) =>
    r = 0.0
    if x > 0
        r := math.atan(y / x)
    else if x < 0 and y >= 0
        r := math.atan(y / x) + math.pi
    else if x < 0 and y < 0
        r := math.atan(y / x) - math.pi
    else if x == 0 and y > 0
        r := math.pi / 2.0
    else if x == 0 and y < 0
        r := -math.pi / 2.0
    else
        r := 0.0
    r

f_ecc(M_deg, e) =>
    M = math.toradians(M_deg)
    E = M + e * math.sin(M) * (1.0 + e * math.cos(M))
    E := E - (E - e * math.sin(E) - M) / (1.0 - e * math.cos(E))
    E := E - (E - e * math.sin(E) - M) / (1.0 - e * math.cos(E))
    E := E - (E - e * math.sin(E) - M) / (1.0 - e * math.cos(E))
    E

var string[] rulerNames = array.from("Sun", "Moon", "Mercury", "Venus", "Mars", "Jupiter", "Saturn")
int   ph_rulerBody = int(na)
int   ph_hourNum   = int(na)
bool  ph_isNight   = bool(na)
float ph_remMin    = float(na)
bool  rulerBenefic = false
bool  rulerMalefic = false

if useRuler
    jd  = time / 86400000.0 + 2440587.5
    d   = jd - 2451543.5
    ut  = (jd + 0.5 - math.floor(jd + 0.5)) * 24.0

    ws  = 282.9404 + 4.70935e-5 * d
    es  = 0.016709 - 1.151e-9 * d
    Ms  = f_rev(356.0470 + 0.9856002585 * d)
    Es  = f_ecc(Ms, es)
    xvs = math.cos(Es) - es
    yvs = math.sqrt(1.0 - es * es) * math.sin(Es)
    vs  = f_atan2(yvs, xvs)
    sunLon = f_rev(math.todegrees(vs) + ws)
    Ls  = f_rev(Ms + ws)

    ecl   = 23.4393 - 3.563e-7 * d
    eclr  = math.toradians(ecl)
    phir  = math.toradians(obs_lat)
    sunLonR = math.toradians(sunLon)
    decl    = math.asin(math.sin(eclr) * math.sin(sunLonR))
    raDeg   = f_rev(math.todegrees(f_atan2(math.cos(eclr) * math.sin(sunLonR), math.cos(sunLonR))))
    eotMin  = 4.0 * f_wrap180(Ls - raDeg)
    noonMin = 720.0 - 4.0 * obs_lon - eotMin
    cosH0   = (math.sin(math.toradians(-0.833)) - math.sin(phir) * math.sin(decl)) / (math.cos(phir) * math.cos(decl))
    ph_polar = cosH0 > 1.0 or cosH0 < -1.0
    H0deg   = ph_polar ? 90.0 : math.todegrees(math.acos(cosH0))
    sunrise = ph_polar ? 360.0  : noonMin - 4.0 * H0deg
    sunset  = ph_polar ? 1080.0 : noonMin + 4.0 * H0deg
    tmin    = ut * 60.0
    dayLen  = sunset - sunrise
    nightHr = (1440.0 - dayLen) / 12.0
    dayHr   = dayLen / 12.0

    var int[] startIdxByDow = array.from(3, 6, 2, 5, 1, 4, 0)
    var int[] chaldeanBody  = array.from(6, 5, 4, 0, 3, 2, 1)

    int   hIdx = 0
    float hourStart = sunrise
    int   gdow = dayofweek(time, "UTC")
    if tmin >= sunrise and tmin < sunset
        hIdx      := int(math.floor((tmin - sunrise) / dayHr))
        hourStart := sunrise + hIdx * dayHr
        gdow      := dayofweek(time, "UTC")
    else if tmin >= sunset
        hIdx      := 12 + int(math.floor((tmin - sunset) / nightHr))
        hourStart := sunset + (hIdx - 12) * nightHr
        gdow      := dayofweek(time, "UTC")
    else
        hIdx      := 12 + int(math.floor((tmin + 1440.0 - sunset) / nightHr))
        hourStart := (sunset - 1440.0) + (hIdx - 12) * nightHr
        gdow      := dayofweek(time - 86400000, "UTC")
    hIdx := math.max(0, math.min(23, hIdx))

    ph_isNight := hIdx >= 12
    hourLen      = ph_isNight ? nightHr : dayHr
    startIdx     = array.get(startIdxByDow, gdow - 1)
    ph_rulerBody := array.get(chaldeanBody, (startIdx + hIdx) % 7)
    ph_hourNum   := (hIdx % 12) + 1
    ph_remMin    := math.max(0.0, hourLen - (tmin - hourStart))

    // Sun(0), Moon(1), Venus(3), Jupiter(5) = classically benefic/luminary; Mars(4), Saturn(6) = malefic; Mercury(2) = neutral, contributes to neither
    rulerBenefic := ph_rulerBody == 0 or ph_rulerBody == 1 or ph_rulerBody == 3 or ph_rulerBody == 5
    rulerMalefic := ph_rulerBody == 4 or ph_rulerBody == 6

// --- Confluence factors ---
atrVal      = ta.atr(atrLen)
rangeOk     = not useATR or (high - low) >= atrVal * atrMult

hasVolume   = ta.cum(volume) > 0
volAvg      = ta.sma(volume, volLen)
volOk       = not useVol or not hasVolume or volume >= volAvg * volMult

rsiVal      = ta.rsi(close, rsiLen)
rsiOkUp     = not useRSI or rsiVal <= rsiOS
rsiOkDn     = not useRSI or rsiVal >= rsiOB

emaVal      = ta.ema(close, trendLen)
trendUp     = close > emaVal
// with-trend pullback and against-trend turn are both valid setups, so trend
// always scores a point when enabled — it's just context, shown in the table
trendOkUp   = not useTrend or true
trendOkDn   = not useTrend or true

rulerOkUp   = not useRuler or rulerBenefic
rulerOkDn   = not useRuler or rulerMalefic

confluenceUp = (useATR ? (rangeOk ? 1 : 0) : 0) + (useVol ? (volOk ? 1 : 0) : 0) + (useRSI ? (rsiOkUp ? 1 : 0) : 0) + (useTrend ? 1 : 0) + (useRuler ? (rulerOkUp ? 1 : 0) : 0)
confluenceDn = (useATR ? (rangeOk ? 1 : 0) : 0) + (useVol ? (volOk ? 1 : 0) : 0) + (useRSI ? (rsiOkDn ? 1 : 0) : 0) + (useTrend ? 1 : 0) + (useRuler ? (rulerOkDn ? 1 : 0) : 0)
maxScore     = (useATR ? 1 : 0) + (useVol ? 1 : 0) + (useRSI ? 1 : 0) + (useTrend ? 1 : 0) + (useRuler ? 1 : 0)

qualifiedUp = rawUp and confluenceUp >= minConfluence
qualifiedDn = rawDn and confluenceDn >= minConfluence

// --- Swing state machine (commit on bar close only -> no repaint) ---
var int dir = 0
var int lastSignalBar = na
var int lastScore = na
buy  = false
sell = false

if barstate.isconfirmed
    cooldownOk = na(lastSignalBar) or (bar_index - lastSignalBar) >= minBarsBetween
    if qualifiedUp and dir <= 0 and cooldownOk
        buy := true
        dir := 1
        lastSignalBar := bar_index
        lastScore := confluenceUp
    else if qualifiedDn and dir >= 0 and cooldownOk
        sell := true
        dir := -1
        lastSignalBar := bar_index
        lastScore := confluenceDn

// --- Level line at each signal ---
level = anchor == "Low" ? low : anchor == "High" ? high : math.avg(high, low)

if showLine and buy
    line.new(bar_index - lineLen, level, bar_index + lineLen, level, xloc = xloc.bar_index, color = bullCol, width = lineWid, style = parsedStyle)
if showLine and sell
    line.new(bar_index - lineLen, level, bar_index + lineLen, level, xloc = xloc.bar_index, color = bearCol, width = lineWid, style = parsedStyle)

// --- Plots ---
plot(showBand ? hiBand : na, "Swing high", color = color.new(bearCol, 55), style = plot.style_stepline)
plot(showBand ? loBand : na, "Swing low",  color = color.new(bullCol, 55), style = plot.style_stepline)

plotshape(buy,  "Buy",  shape.triangleup,   location.belowbar, bullCol, size = size.small, text = "BUY",  textcolor = bullCol)
plotshape(sell, "Sell", shape.triangledown, location.abovebar, bearCol, size = size.small, text = "SELL", textcolor = bearCol)

if showScore and buy
    label.new(bar_index, low,  str.tostring(lastScore) + "/" + str.tostring(maxScore), style = label.style_none, color = color.new(bullCol, 100), textcolor = bullCol, size = size.tiny, yloc = yloc.belowbar)
if showScore and sell
    label.new(bar_index, high, str.tostring(lastScore) + "/" + str.tostring(maxScore), style = label.style_none, color = color.new(bearCol, 100), textcolor = bearCol, size = size.tiny, yloc = yloc.abovebar)

bgcolor(showBg ? (buy ? color.new(bullCol, 90) : sell ? color.new(bearCol, 90) : na) : na, title = "Signal highlight")

// --- Status table ---
tablePosVal = switch tablePos
    "Top left"     => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left"  => position.bottom_left
    => position.top_right
var table statusTable = table.new(tablePosVal, 2, 7, border_width = 1)

f_row(_r, _label, _value, _color) =>
    table.cell(statusTable, 0, _r, _label, text_halign = text.align_left,  text_color = color.gray,  bgcolor = color.new(color.black, 85))
    table.cell(statusTable, 1, _r, _value, text_halign = text.align_right, text_color = _color,      bgcolor = color.new(color.black, 85))

if showTable and barstate.islast
    trendLabel = trendUp ? "Up" : "Down"
    barsAgo    = na(lastSignalBar) ? "—" : str.tostring(bar_index - lastSignalBar)
    lastDir    = dir == 1 ? "BUY" : dir == -1 ? "SELL" : "—"
    lastDirCol = dir == 1 ? bullCol : dir == -1 ? bearCol : color.gray

    f_row(0, "Method",        method,                              color.gray)
    f_row(1, "Last signal",   lastDir,                             lastDirCol)
    f_row(2, "Bars ago",      barsAgo,                              color.gray)
    f_row(3, "Confluence",    na(lastScore) ? "—" : str.tostring(lastScore) + "/" + str.tostring(maxScore), color.gray)
    f_row(4, "RSI",           str.tostring(rsiVal, "#.#"),          color.gray)
    f_row(5, "Trend (EMA " + str.tostring(trendLen) + ")", trendLabel, trendUp ? bullCol : bearCol)
    if useRuler
        rulerLbl = array.get(rulerNames, ph_rulerBody) + " " + (ph_isNight ? "N" : "D") + str.tostring(ph_hourNum)
        rulerCol = rulerBenefic ? bullCol : rulerMalefic ? bearCol : color.gray
        f_row(6, "Hour ruler",    rulerLbl,                          rulerCol)

// --- Alerts ---
// alertcondition() for the static dropdown in TV's alert dialog, alert() below
// for dynamic text with ticker/price/confluence baked in — kept both on purpose
alertcondition(buy,         "Buy reversal",  "Gann Reversal Confluence: BUY")
alertcondition(sell,        "Sell reversal", "Gann Reversal Confluence: SELL")
alertcondition(buy or sell, "Any reversal",  "Gann Reversal Confluence: new signal")

if buy
    alert("Gann BUY Reversal on " + syminfo.ticker + " at " + str.tostring(close) + " (confluence " + str.tostring(lastScore) + "/" + str.tostring(maxScore) + ")", alert.freq_once_per_bar_close)
if sell
    alert("Gann SELL Reversal on " + syminfo.ticker + " at " + str.tostring(close) + " (confluence " + str.tostring(lastScore) + "/" + str.tostring(maxScore) + ")", alert.freq_once_per_bar_close)
````
