# Astro Cycle Confluence Swing [Jayadev Rana]

- url: https://www.tradingview.com/script/aEPAwwIn-Astro-Cycle-Confluence-Swing-Jayadev-Rana/
- type: indicator
- pine_id: PUB;23e09b305e9948b7be81243b6d0cc6e0
- version: 1.0

## Description

Astro Cycle Confluence Swing is an experimental daily-timeframe indicator that builds swing buy and sell signals purely from astronomical time cycles. It reads no price to compute the cycles: every celestial value is a deterministic function of the bar's UTC timestamp, so the cycle track is fixed in advance and does not repaint.

WHAT IT COMBINES
The script fuses eight classic cycle ideas into two composite readings:
1. Lunar synodic phase - new moon and full moon turning points, plus a phase bias.
2. Lunar anomalistic distance - perigee and apogee windows (often associated with volatility).
3. Lunar declination cycle - a tropical-month oscillation (approximate).
4. Solar season and declination - the four Gann cardinal points (equinoxes and solstices).
5. Planetary synodic composite - a weighted sum of cosines of the heliocentric angular separations between planet pairs from Mercury through Saturn. This is an original construction inspired by classic planetary cycle models, not a copy of any specific one.
6. Mercury retrograde window - a synodic inferior-conjunction proxy (approximate).
7. Gann time cycles - calendar-day counts (30, 45, 60, 90, 120, 144, 180, 270, 360) measured from the last confirmed swing pivot.
8. Fibonacci time cycles - Fibonacci day counts (13, 21, 34, 55, 89, 144, 233) from the same anchor.

HOW SIGNALS FORM
Two composites are derived on each bar:
- Net Astro Bias (range -1 to +1): a weighted blend of the directional components (lunar phase, planetary composite, seasonal momentum, lunar declination).
- Turn Energy (range 0 to 1): a weighted blend of the event components (moon phase change, perigee or apogee, cardinal points, planetary composite extreme, Gann and Fibonacci time hits, Mercury station).
A BUY prints when Net Astro Bias crosses up through the bias threshold while Turn Energy is elevated within a small window around an astro event. A SELL is the mirror. Optional filters can also require price to sit at a swing extreme, require a confirming candle, and enforce a minimum bar gap between same-side signals.

INPUTS
- Signal engine: bias threshold, turn-energy threshold and reference, turn window, minimum gap, swing-extreme filter, confirming-candle filter.
- Directional bias weights: per-theory weights and a lunar-bias invert switch.
- Turning-point weights: per-event weights.
- Cycle anchor: swing pivot strength used for the Gann and Fibonacci time counts.
- Display: signal markers, bias background tint, dashboard position, and colors.

DASHBOARD
A table summarizes the current lunar phase and illumination, lunar distance and declination state, season and solar declination, planetary composite value and direction, Mercury direct or retrograde state, days since the anchor, Net Astro Bias, Turn Energy, and the active signal.

ALERTS
Two alertcondition slots (BUY and SELL) plus dynamic alert() calls that name the current ticker.

INTENDED USE
Built for the 1-day timeframe as a swing tool. The dashboard shows a reminder when the chart is not daily. It works on any symbol because the cycles are time-based rather than instrument-based.

LIMITATIONS AND NOTES
- All ephemeris terms use mean orbital elements that are linear in time. They are approximations suitable for multi-day cycle timing, not for arc-second astronomy. Event timing can be off by about a bar.
- Astronomical and astrological market cycles are a speculative and unproven framework. This tool is provided for study and experimentation, not as a forecast.
- The Gann and Fibonacci time anchors update on confirmed pivots, and a pivot confirms only after the pivot-strength number of bars, so those anchor-based rows lag by that many bars. The astronomical crossings themselves are exact and do not repaint.

DISCLAIMER
This script is for educational and informational purposes only. It is not financial advice and does not guarantee any result. Past cycle alignments do not predict future price. Always do your own research and manage your own risk.

## Source Code

````pine
// ==============================================================================
//  Astro Cycle Confluence Swing [Jayadev Rana]
// ------------------------------------------------------------------------------
//  A daily-timeframe swing signal engine built entirely from time-based
//  astronomical cycles. Nothing here reads price to compute the cycles - every
//  celestial value is a deterministic function of the bar's UTC timestamp, so
//  the cycle track is fixed in advance and never repaints.
//
//  Theories combined into one confluence score:
//    1. Lunar synodic phase        - new / full moon turning points + bias
//    2. Lunar anomalistic distance - perigee / apogee (volatility windows)
//    3. Lunar declination cycle    - tropical-month nodal oscillation (approx)
//    4. Solar season / declination - Gann cardinal points (equinox/solstice)
//    5. Planetary synodic composite- weighted cos of heliocentric pair angles
//    6. Mercury retrograde window  - synodic inferior-conjunction proxy (approx)
//    7. Gann time cycles           - calendar-day counts from last swing anchor
//    8. Fibonacci time cycles      - Fib day counts from the same anchor
//
//  A directional Net Astro Bias (-1..+1) is fused from the biased components;
//  a Turn Energy (0..1) is fused from the event/turning components. A swing
//  BUY fires when bias crosses up through a threshold while Turn Energy is
//  elevated (optionally at a fresh swing low); SELL is the mirror.
//
//  All ephemeris terms use mean orbital elements (linear in time). They are
//  approximations - accurate enough for multi-day cycle timing, not for
//  arc-second astronomy.
// ==============================================================================

//@version=6
indicator("Astro Cycle Confluence Swing [Jayadev Rana]", shorttitle="AstroSwing", overlay=true, max_labels_count=500)

// ------------------------------------------------------------------------------
//  0. Helpers
// ------------------------------------------------------------------------------
rad = math.pi / 180.0

norm360(float x) =>
    float m = x % 360.0
    m < 0.0 ? m + 360.0 : m

crossedUp(float p, float c, float t) =>
    p < t and c >= t

// ------------------------------------------------------------------------------
//  1. Inputs
// ------------------------------------------------------------------------------
grpS  = "Signal engine"
biasThresh = input.float(0.20, "Bias threshold (|Net Bias| to arm)", minval=0.05, maxval=0.90, step=0.05, group=grpS)
turnThresh = input.float(0.35, "Turn Energy threshold", minval=0.10, maxval=1.0, step=0.05, group=grpS)
turnRef    = input.float(2.0, "Turn Energy reference (weight for full energy)", minval=0.5, maxval=5.0, step=0.1, group=grpS)
turnWindow = input.int(3, "Turn window (bars around an astro event)", minval=1, maxval=15, group=grpS)
minGap     = input.int(5, "Min bars between same-side signals", minval=1, maxval=60, group=grpS)
requireSwing = input.bool(false, "Require price at a swing extreme", group=grpS)
swingLook  = input.int(10, "Swing extreme lookback", minval=2, maxval=100, group=grpS)
useConfirm = input.bool(false, "Require confirming candle (close vs open)", group=grpS)

grpB  = "Directional bias weights"
wLunar   = input.float(1.0, "Lunar phase bias weight", minval=0.0, maxval=3.0, step=0.1, group=grpB)
wPlanetB = input.float(1.0, "Planetary composite bias weight", minval=0.0, maxval=3.0, step=0.1, group=grpB)
wSeasonB = input.float(0.4, "Solar season bias weight", minval=0.0, maxval=3.0, step=0.1, group=grpB)
wLunDec  = input.float(0.3, "Lunar declination bias weight", minval=0.0, maxval=3.0, step=0.1, group=grpB)
invertLunar = input.bool(false, "Invert lunar bias (sell new / buy full)", group=grpB)

grpT  = "Turning-point weights"
wMoonPhase = input.float(1.0, "New/Full moon", minval=0.0, maxval=3.0, step=0.1, group=grpT)
wMoonDist  = input.float(0.6, "Perigee/Apogee", minval=0.0, maxval=3.0, step=0.1, group=grpT)
wCardinal  = input.float(1.0, "Solstice/Equinox (Gann cardinal)", minval=0.0, maxval=3.0, step=0.1, group=grpT)
wPlanet    = input.float(0.7, "Planetary composite extreme", minval=0.0, maxval=3.0, step=0.1, group=grpT)
wGann      = input.float(0.9, "Gann time cycle hit", minval=0.0, maxval=3.0, step=0.1, group=grpT)
wFib       = input.float(0.5, "Fibonacci time cycle hit", minval=0.0, maxval=3.0, step=0.1, group=grpT)
wRetro     = input.float(0.5, "Mercury retro station", minval=0.0, maxval=3.0, step=0.1, group=grpT)

grpC  = "Cycle anchor"
pivLen = input.int(5, "Swing pivot strength (for time-cycle anchor)", minval=2, maxval=50, group=grpC)

grpU  = "Display"
showSignals = input.bool(true, "Show BUY/SELL markers", group=grpU)
showTint    = input.bool(true, "Tint background by Net Bias", group=grpU)
showDash    = input.bool(true, "Show dashboard", group=grpU)
dashPos     = input.string("Top Right", "Dashboard position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpU)
bullCol = input.color(color.new(#26a69a, 0), "Bull color", group=grpU)
bearCol = input.color(color.new(#ef5350, 0), "Bear color", group=grpU)

// ------------------------------------------------------------------------------
//  2. Time base -> Julian Date -> days since J2000
// ------------------------------------------------------------------------------
jd = time / 86400000.0 + 2440587.5
d  = jd - 2451545.0

// ------------------------------------------------------------------------------
//  3. Solar terms (mean elements)
// ------------------------------------------------------------------------------
Lsun = norm360(280.4665 + 0.98564736 * d)
gsun = norm360(357.5291 + 0.98560028 * d)
lambdaSun = norm360(Lsun + 1.915 * math.sin(rad * gsun) + 0.020 * math.sin(rad * 2.0 * gsun))
sinDecl = math.sin(rad * 23.4393) * math.sin(rad * lambdaSun)
declSun = math.asin(sinDecl) * 180.0 / math.pi

// ------------------------------------------------------------------------------
//  4. Lunar terms (mean elements)
// ------------------------------------------------------------------------------
Lmoon = norm360(218.3165 + 13.17639648 * d)
Mmoon = norm360(134.9634 + 13.06499295 * d)   // anomalistic mean anomaly -> perigee/apogee
Fmoon = norm360(93.2721  + 13.22935024 * d)   // argument of latitude -> declination cycle
Delong = norm360(297.8502 + 12.19074912 * d)  // mean elongation ~ phase

phaseAngle = Delong                            // 0 = new, 180 = full
illum = (1.0 - math.cos(rad * phaseAngle)) / 2.0
distProxy = 1.0 - 0.0549 * math.cos(rad * Mmoon)   // ~1 near mean; min at perigee
lunDec = math.sin(rad * Fmoon)                     // -1..+1 declination-cycle proxy

// ------------------------------------------------------------------------------
//  5. Planetary heliocentric mean longitudes (deg)
// ------------------------------------------------------------------------------
Lmer = norm360(252.2509 + 4.09233880 * d)
Lven = norm360(181.9798 + 1.60213023 * d)
Lear = norm360(100.4644 + 0.98560760 * d)
Lmar = norm360(355.4533 + 0.52402076 * d)
Ljup = norm360( 34.4044 + 0.08308530 * d)
Lsat = norm360( 49.9443 + 0.03344423 * d)

// Original weighted synodic composite (pairwise cosine of angular separation).
compRaw = 0.9 * math.cos(rad * (Lven - Lear)) + 0.8 * math.cos(rad * (Lear - Lmar)) + 1.2 * math.cos(rad * (Ljup - Lsat)) + 0.6 * math.cos(rad * (Lmer - Lven)) + 0.7 * math.cos(rad * (Lear - Ljup)) + 0.5 * math.cos(rad * (Lven - Ljup))
compW = 0.9 + 0.8 + 1.2 + 0.6 + 0.7 + 0.5
comp = compRaw / compW                             // -1..+1

// Mercury retrograde proxy: near inferior conjunction (Mercury synodic vs Earth ~ 0)
syn = norm360(Lmer - Lear)
retro = syn > 320.0 or syn < 40.0
retroStation = retro != retro[1]

// ------------------------------------------------------------------------------
//  6. Event / turning-point detection (deterministic, non-repainting)
// ------------------------------------------------------------------------------
newMoon   = phaseAngle < phaseAngle[1]                         // synodic wrap 360->0
fullCross = phaseAngle[1] < 180.0 and phaseAngle >= 180.0
perigee   = Mmoon < Mmoon[1]                                   // anomalistic wrap
apogee    = Mmoon[1] < 180.0 and Mmoon >= 180.0

// Solar cardinal crossings (0/90/180/270 ecliptic longitude)
lamPrev = lambdaSun[1]
cardSpring = lambdaSun < lamPrev                               // wrap 360->0 = spring equinox
cardSummer = crossedUp(lamPrev, lambdaSun, 90.0)
cardAutumn = crossedUp(lamPrev, lambdaSun, 180.0)
cardWinter = crossedUp(lamPrev, lambdaSun, 270.0)
cardinalTurn = cardSpring or cardSummer or cardAutumn or cardWinter

// Planetary composite local extreme (slope sign flip)
compRising = comp > comp[1]
compTurn = compRising != compRising[1]

// ------------------------------------------------------------------------------
//  7. Gann + Fibonacci time cycles from last confirmed swing pivot
// ------------------------------------------------------------------------------
var float anchorTime = na
plConf = ta.pivotlow(pivLen, pivLen)
phConf = ta.pivothigh(pivLen, pivLen)
if not na(plConf)
    anchorTime := time[pivLen]
if not na(phConf)
    anchorTime := time[pivLen]

daysSince = na(anchorTime) ? na : (time - anchorTime) / 86400000.0
dsCur  = daysSince
dsPrev = daysSince[1]
anchorSteady = not na(anchorTime) and not na(anchorTime[1]) and anchorTime == anchorTime[1]
cycleValid = anchorSteady and not na(dsCur) and not na(dsPrev)

gannHit = cycleValid and (crossedUp(dsPrev, dsCur, 30.0) or crossedUp(dsPrev, dsCur, 45.0) or crossedUp(dsPrev, dsCur, 60.0) or crossedUp(dsPrev, dsCur, 90.0) or crossedUp(dsPrev, dsCur, 120.0) or crossedUp(dsPrev, dsCur, 144.0) or crossedUp(dsPrev, dsCur, 180.0) or crossedUp(dsPrev, dsCur, 270.0) or crossedUp(dsPrev, dsCur, 360.0))
fibHit  = cycleValid and (crossedUp(dsPrev, dsCur, 13.0) or crossedUp(dsPrev, dsCur, 21.0) or crossedUp(dsPrev, dsCur, 34.0) or crossedUp(dsPrev, dsCur, 55.0) or crossedUp(dsPrev, dsCur, 89.0) or crossedUp(dsPrev, dsCur, 144.0) or crossedUp(dsPrev, dsCur, 233.0))

// ------------------------------------------------------------------------------
//  8. Fuse Net Astro Bias (-1..+1) and Turn Energy (0..1)
// ------------------------------------------------------------------------------
lunarBias = (invertLunar ? -1.0 : 1.0) * math.cos(rad * phaseAngle)   // +1 new, -1 full
declMom = declSun - declSun[10]
seasonalBias = math.max(-1.0, math.min(1.0, declMom / 4.0))

biasNum = wLunar * lunarBias + wPlanetB * comp + wSeasonB * seasonalBias + wLunDec * lunDec
biasDen = wLunar + wPlanetB + wSeasonB + wLunDec
netBias = biasDen > 0.0 ? biasNum / biasDen : 0.0

turnNum = (newMoon or fullCross ? wMoonPhase : 0.0) + (perigee or apogee ? wMoonDist : 0.0) + (cardinalTurn ? wCardinal : 0.0) + (compTurn ? wPlanet : 0.0) + (gannHit ? wGann : 0.0) + (fibHit ? wFib : 0.0) + (retroStation ? wRetro : 0.0)
// Reference-scaled so ~one major event (weight ~= turnRef/2) already lifts energy toward the threshold.
turnEnergy = math.min(1.0, turnNum / turnRef)
turnRecent = ta.highest(turnEnergy, turnWindow)

// ------------------------------------------------------------------------------
//  9. Swing signals
// ------------------------------------------------------------------------------
atLow  = low  <= ta.lowest(low, swingLook)
atHigh = high >= ta.highest(high, swingLook)
confBuy  = not useConfirm or close > open
confSell = not useConfirm or close < open

buyRaw  = ta.crossover(netBias, biasThresh)  and turnRecent >= turnThresh and confBuy  and (not requireSwing or atLow)
sellRaw = ta.crossunder(netBias, -biasThresh) and turnRecent >= turnThresh and confSell and (not requireSwing or atHigh)

var int lastBuyBar  = na
var int lastSellBar = na
buyOk  = na(lastBuyBar)  or (bar_index - lastBuyBar)  >= minGap
sellOk = na(lastSellBar) or (bar_index - lastSellBar) >= minGap
buy  = buyRaw  and buyOk
sell = sellRaw and sellOk
if buy
    lastBuyBar := bar_index
if sell
    lastSellBar := bar_index

// ------------------------------------------------------------------------------
//  10. Plots
// ------------------------------------------------------------------------------
plotshape(showSignals and buy,  title="Buy",  style=shape.triangleup,   location=location.belowbar, color=bullCol, text="BUY",  textcolor=bullCol, size=size.small)
plotshape(showSignals and sell, title="Sell", style=shape.triangledown, location=location.abovebar, color=bearCol, text="SELL", textcolor=bearCol, size=size.small)

tintCol = netBias > biasThresh ? color.new(bullCol, 90) : netBias < -biasThresh ? color.new(bearCol, 90) : na
bgcolor(showTint ? tintCol : na, title="Bias tint")

plot(netBias,    "Net Astro Bias",       color=color.new(color.blue, 0),   display=display.data_window)
plot(comp,       "Planetary Composite",  color=color.new(color.purple, 0), display=display.data_window)
plot(illum,      "Lunar Illumination",   color=color.new(color.gray, 0),   display=display.data_window)
plot(turnEnergy, "Turn Energy",          color=color.new(color.orange, 0), display=display.data_window)
plot(declSun,    "Solar Declination",    color=color.new(color.teal, 0),   display=display.data_window)

// ------------------------------------------------------------------------------
//  11. Alerts
// ------------------------------------------------------------------------------
alertcondition(buy,  "Astro Swing BUY",  "Astro Cycle Confluence: BUY signal")
alertcondition(sell, "Astro Swing SELL", "Astro Cycle Confluence: SELL signal")
if buy
    alert("Astro Cycle Confluence BUY on " + syminfo.ticker, alert.freq_once_per_bar)
if sell
    alert("Astro Cycle Confluence SELL on " + syminfo.ticker, alert.freq_once_per_bar)

// ------------------------------------------------------------------------------
//  12. Dashboard
// ------------------------------------------------------------------------------
phaseName = phaseAngle < 22.5 or phaseAngle >= 337.5 ? "New Moon" : phaseAngle < 67.5 ? "Waxing Crescent" : phaseAngle < 112.5 ? "First Quarter" : phaseAngle < 157.5 ? "Waxing Gibbous" : phaseAngle < 202.5 ? "Full Moon" : phaseAngle < 247.5 ? "Waning Gibbous" : phaseAngle < 292.5 ? "Last Quarter" : "Waning Crescent"
seasonName = lambdaSun < 90.0 ? "Spring" : lambdaSun < 180.0 ? "Summer" : lambdaSun < 270.0 ? "Autumn" : "Winter"
distName = distProxy < 0.97 ? "Near Perigee" : distProxy > 1.03 ? "Near Apogee" : "Mid"
biasName = netBias > biasThresh ? "Bullish" : netBias < -biasThresh ? "Bearish" : "Neutral"
biasCol  = netBias > biasThresh ? bullCol : netBias < -biasThresh ? bearCol : color.gray
sigName  = buy ? "BUY" : sell ? "SELL" : "-"
sigCol   = buy ? bullCol : sell ? bearCol : color.gray

dPos = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table dash = table.new(dPos, 3, 12, border_width=1, frame_color=color.new(color.gray, 60), frame_width=1)

f_row(int r, string k, string v, color vc) =>
    table.cell(dash, 0, r, k, text_size=size.small, text_color=color.new(color.gray, 0), text_halign=text.align_left)
    table.cell(dash, 1, r, v, text_size=size.small, text_color=vc, text_halign=text.align_right)

if showDash and barstate.islast
    table.cell(dash, 0, 0, "Astro Confluence", text_size=size.small, text_color=color.white, bgcolor=color.new(color.gray, 40))
    table.cell(dash, 1, 0, timeframe.isdaily ? "1D OK" : "use 1D", text_size=size.small, text_color=timeframe.isdaily ? bullCol : bearCol, bgcolor=color.new(color.gray, 40))
    f_row(1, "Lunar phase",   phaseName + " " + str.tostring(illum * 100.0, "#") + "%", lunarBias > 0 ? bullCol : bearCol)
    f_row(2, "Lunar dist",    distName, color.gray)
    f_row(3, "Lunar decl",    lunDec > 0 ? "North" : "South", color.gray)
    f_row(4, "Season",        seasonName + " " + str.tostring(declSun, "#.#") + "deg", color.gray)
    f_row(5, "Planet comp",   str.tostring(comp, "#.##") + (compRising ? " up" : " dn"), comp > 0 ? bullCol : bearCol)
    f_row(6, "Mercury",       retro ? "Retrograde" : "Direct", retro ? bearCol : color.gray)
    f_row(7, "Days/anchor",   na(daysSince) ? "-" : str.tostring(daysSince, "#"), color.gray)
    f_row(8, "Net bias",      str.tostring(netBias, "#.##") + " " + biasName, biasCol)
    f_row(9, "Turn energy",   str.tostring(turnRecent, "#.##") + (turnRecent >= turnThresh ? " HIGH" : " low"), turnRecent >= turnThresh ? color.orange : color.gray)
    f_row(10, "Signal",       sigName, sigCol)
    f_row(11, "Timeframe",    timeframe.period, color.gray)
````
