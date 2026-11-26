# Global vs China Liquidity Proxy

- url: https://www.tradingview.com/script/0ur4HVU1/
- type: indicator
- pine_id: PUB;5e3dbb9daa9a4e6ebdf6b6139d217546
- version: 4.0

## Description

[b]Global vs China Liquidity Proxy
[/b]
One-line summary: Two central-bank liquidity composites — Global and China — plotted on a common normalized scale, with a divergence histogram, expansion/contraction regime shading, a configurable lead, and a live correlation to whatever asset the chart is on.


[b]What it does
[/b]
This indicator builds two macro-liquidity composites from central-bank balance sheets and financial-conditions data, then puts them on a shared, comparable scale so you can read global liquidity, China liquidity, and — most importantly — the gap between them at a glance.

Global composite — the four largest central-bank balance sheets converted to USD (Fed + BoJ/USDJPY + PBoC/USDCNY + ECB/USDEUR), modulated by a risk/financial-conditions block (China 10Y yield, the dollar index, and the US high-yield credit spread).

China composite — a Chinese liquidity stock (M2 by default, switchable to M1 or the PBoC balance sheet) modulated by China-native conditions: the 10Y yield, USD/CNY, and the interbank funding rate. China liquidity is largely a commercial-bank credit-creation story, which is why M2 — not the central-bank balance sheet — is the default base.

Because the two raw composites differ by orders of magnitude, they are always shown through a normalization transform so they can be compared directly.

[b]Why YoY and Z-Score matter
[/b]
In level terms, both composites are dominated by the relentless growth of central-bank balance sheets, and the risk modulators barely register. The growth rate (YoY) and the rolling Z-Score are where the financial-conditions signal actually shows up, and where the two regions become genuinely comparable. The level/indexed view is best read as a pure liquidity-stock line; YoY and Z-Score are the analytical views.

[b]Inputs
[/b]
Display transform


Indexed to 100 — both lines = 100 at an anchor date; reads relative divergence since that date.
YoY % — true 12-calendar-month change (computed from a monthly buffer, so it reads identically on Daily, Weekly, or Monthly).
Z-Score — rolling standardized score; detrends the series into an oscillator and is base-date-independent.
Raw — unprocessed composites (scales differ; for debugging a single line only).


[b]Modulator mode
[/b]

Raw levels — modulators applied as direct multiplicative factors.
Z-scored — modulators applied as exp(−k · tightness), where tightness is the combined Z-Score of the conditions block, so they meaningfully move the line. The k sensitivity controls the strength.


China liquidity base — M2 (broad, bank-credit-driven; default), M1 (the activity/impulse gauge), or the PBoC balance sheet (central-bank only).

[b]Overlays & lead
[/b]

China − Global divergence histogram — green when China is leading the global cycle, red when lagging.
YoY regime shading — green background when both composites' YoY > 0 (joint expansion), red when both < 0 (joint contraction), clear when they disagree.
Lead / offset (months) — shifts the proxies forward to align their known lead over risk assets, and lags them by the same amount inside the correlation calculation.


[b]Correlation[/b] — rolling correlation of each composite to the chart's asset, computed YoY-vs-YoY (growth rate against growth rate) to avoid the spurious correlation you get from comparing two trending levels. Shown live in the table and optionally plotted.

[b]How to use it
[/b]

Run it on Daily, Weekly, or Monthly — the underlying economic series update monthly.
Watch the divergence histogram for China leading or lagging the global liquidity cycle. A flip to red while the regime stays green (global still expanding, China rolling over) is the classic setup where China-beta assets begin to underperform before the broad tape reacts.
Use the correlation cell to confirm whether the asset on your chart is actually tracking liquidity right now, and which region it tracks more closely.
Use the lead/offset to align the proxy's turning points with later price turns, since liquidity typically leads risk assets by a couple of months.


Alerts

China YoY zero-cross (up/down), Global YoY zero-cross (up/down), divergence sign-flip (China leading / lagging), and regime change (both expanding / both contracting).

Notes


Some component symbols may require a higher TradingView data plan; substitute or remove any that don't load in your account.
Readings stabilize once roughly 13+ months of history are loaded.
This is a macro context and research tool, not a signal generator, and nothing here is financial advice.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════
//  Global vs China Liquidity Proxy  —  v3
//  Two normalized macro-liquidity composites + extension modules:
//   1) Net liquidity (subtract US TGA+RRP) and M2/CBBS/Average source select
//   2) Liquidity-beta scanner (correlation + implied direction for an asset basket)
//   3) Composite liquidity-momentum score (−100..+100) + Risk-On/Off + bar color
//   4) Signal-quality filter (Kaufman Efficiency Ratio: trending vs choppy)
//   5) GRID regime overlay (Goldilocks / Reflation / Inflation / Deflation)
//   6) Speed/format: HMA, double-normalization, noise threshold, multi-horizon RoC
//  Run on Daily / Weekly / Monthly — the underlying economic data is monthly.
//  NOTE: many request.security symbols; some may need a higher data plan.
// ════════════════════════════════════════════════════════════════════
indicator("Global vs China Liquidity Proxy", shorttitle="Liq GCN3",
          overlay=false, precision=2, max_bars_back=1500)

// ─────────────── Preset ───────────────
gP = "Preset (core view)"
preset = input.string("0 · Default (All-rounder)", "Preset", group=gP, options=[
     "Custom","0 · Default (All-rounder)","1 · Macro Regime / Now-Casting","2 · Risk-Asset Timing",
     "3 · China Decoupling / Early Warning","4 · Commodities / China Credit Impulse",
     "5 · Financial-Conditions Stress","6 · Structural / Long-Term"],
     tooltip="Sets the core view (transform, modulators, China base, lead, smoothing, divergence, regime, correlation). The extension modules below have their own independent toggles.")

// ─────────────── Core manual inputs (active when Preset = Custom) ───────────────
g1 = "Display (Custom)"
transform = input.string("Indexed to 100", "Display transform", options=["Indexed to 100","YoY %","Z-Score","Raw"], group=g1)
smoothLen = input.int(1, "Smoothing SMA (1 = off)", minval=1, group=g1)

g2 = "Composition (Custom)"
modMode = input.string("Raw levels", "Modulator mode", options=["Raw levels","Z-scored"], group=g2)
kSens   = input.float(0.15, "Z-mod sensitivity (k)", minval=0.0, step=0.05, group=g2)
cnBase  = input.string("M2 (CNM2)", "China liquidity base", options=["M2 (CNM2)","M1 (CNM1)","PBoC balance sheet (CNCBBS)"], group=g2)

g3 = "Overlays & lead (Custom)"
showDiv    = input.bool(true, "China − Global divergence histogram", group=g3)
showRegime = input.bool(true, "YoY regime shading (uses background mode below)", group=g3)
leadM      = input.int(0, "Lead / offset (months)", minval=0, maxval=24, group=g3)

// ─────────────── Module 1: liquidity sources ───────────────
gLIQ = "1 · Liquidity sources"
globalSrc = input.string("CBBS", "Global stock source", options=["CBBS","M2","Average"], group=gLIQ,
     tooltip="CBBS = central-bank balance sheets (default). M2 = broad money. Average = mean of both.")
netLiq    = input.bool(false, "Net liquidity (subtract US TGA + RRP)", group=gLIQ,
     tooltip="Replaces the US leg with WALCL − TGA − RRP (Fed net liquidity). Uses FRED units; if the US leg looks mis-scaled, that is the cause.")

// ─────────────── Module 6: speed & format ───────────────
gSPD = "6 · Speed & format"
useHMA  = input.bool(false, "HMA smoothing on lines", group=gSPD)
hmaLen  = input.int(8, "HMA length", minval=2, group=gSPD)
dblNorm = input.bool(false, "Double-normalize (Z-Score mode, faster for crypto)", group=gSPD)
noiseThr= input.float(0.0, "Divergence noise threshold (gray below)", minval=0.0, step=0.1, group=gSPD)
showRoC = input.bool(true, "Show multi-horizon RoC row", group=gSPD)

// ─────────────── Module 3: composite score & risk ───────────────
gSC = "3 · Composite score & risk"
bgMode   = input.string("Regime (YoY)", "Background mode", options=["Regime (YoY)","Risk-On/Off (score)","None"], group=gSC)
scoreThr = input.float(10.0, "Risk state threshold (±)", minval=0.0, group=gSC)
plotScore= input.bool(false, "Plot score line (own scale)", group=gSC)
barCol   = input.bool(false, "Color chart bars by risk state", group=gSC)

// ─────────────── Module 4: signal quality ───────────────
gSIG = "4 · Signal quality"
showSig = input.bool(true, "Show signal-quality (Efficiency Ratio)", group=gSIG)

// ─────────────── Module 5: GRID regime ───────────────
gGR = "5 · GRID regime"
showGrid = input.bool(true, "Show GRID regime cell", group=gGR)
inflSym  = input.symbol("FRED:T5YIE", "Inflation proxy", group=gGR,
     tooltip="Rising = inflationary. Default = 5y breakeven inflation. Alternatives: a copper/gold ratio or a commodity index.")

// ─────────────── Module 2: liquidity-beta scanner ───────────────
gSCAN = "2 · Liquidity-beta scanner"
showScan  = input.bool(true, "Show scanner table", group=gSCAN)
scanRef   = input.string("Global", "Scanner reference proxy", options=["Global","China"], group=gSCAN)
scanSharpe= input.bool(false, "Add per-asset Sharpe~ column", group=gSCAN)
a1s = input.symbol("INDEX:BTCUSD",      "Asset 1", group=gSCAN)
a2s = input.symbol("INDEX:ETHUSD",      "Asset 2", group=gSCAN)
a3s = input.symbol("CRYPTOCAP:TOTAL2",  "Asset 3", group=gSCAN)
a4s = input.symbol("SP:SPX",            "Asset 4", group=gSCAN)
a5s = input.symbol("TVC:GOLD",          "Asset 5", group=gSCAN)
a6s = input.symbol("COMEX:HG1!",        "Asset 6", group=gSCAN)
a7s = input.symbol("AMEX:HYG",          "Asset 7", group=gSCAN)
a8s = input.symbol("AMEX:EEM",          "Asset 8", group=gSCAN)

// ─────────────── Always-active toggles & lookbacks ───────────────
g3b = "Display toggles (always active)"
showG     = input.bool(true, "Show Global", group=g3b)
showC     = input.bool(true, "Show China",  group=g3b)
showTable = input.bool(true, "Show status table", group=g3b)
anchorT   = input.time(timestamp("01 Jan 2020 00:00"), "Index anchor date", group=g3b)

g4 = "Correlation"
corrOn   = input.bool(true,  "Correlate proxies to chart asset", group=g4)
corrPlot = input.bool(false, "Plot correlation lines (own scale)", group=g4)

g5 = "Lookbacks (0 = auto)"
corrIn = input.int(0, "Correlation length", minval=0, group=g5)
zIn    = input.int(0, "Z-Score length",     minval=0, group=g5)

// ─────────────── Effective parameters (preset or custom) ───────────────
string eTransform = transform
string eModMode   = modMode
float  eK         = kSens
string eCnBase    = cnBase
int    eLead      = leadM
int    eSmooth    = smoothLen
bool   eDiv       = showDiv
bool   eRegime    = showRegime
bool   eCorr      = corrOn
string recTF      = "—"
if preset == "0 · Default (All-rounder)"
    eTransform := "Z-Score",  eModMode := "Z-scored",   eK := 0.20, eCnBase := "M2 (CNM2)"
    eLead := 2, eSmooth := 1, eDiv := true,  eRegime := true, eCorr := true,  recTF := "Weekly"
else if preset == "1 · Macro Regime / Now-Casting"
    eTransform := "YoY %",    eModMode := "Raw levels", eK := 0.15, eCnBase := "M2 (CNM2)"
    eLead := 0, eSmooth := 2, eDiv := true,  eRegime := true, eCorr := true,  recTF := "Weekly/Monthly"
else if preset == "2 · Risk-Asset Timing"
    eTransform := "Z-Score",  eModMode := "Z-scored",   eK := 0.20, eCnBase := "M2 (CNM2)"
    eLead := 2, eSmooth := 1, eDiv := true,  eRegime := true, eCorr := true,  recTF := "Weekly"
else if preset == "3 · China Decoupling / Early Warning"
    eTransform := "Z-Score",  eModMode := "Raw levels", eK := 0.15, eCnBase := "M1 (CNM1)"
    eLead := 0, eSmooth := 1, eDiv := true,  eRegime := true, eCorr := true,  recTF := "Weekly"
else if preset == "4 · Commodities / China Credit Impulse"
    eTransform := "YoY %",    eModMode := "Raw levels", eK := 0.15, eCnBase := "M1 (CNM1)"
    eLead := 6, eSmooth := 2, eDiv := true,  eRegime := true, eCorr := true,  recTF := "Weekly/Monthly"
else if preset == "5 · Financial-Conditions Stress"
    eTransform := "Z-Score",  eModMode := "Z-scored",   eK := 0.30, eCnBase := "M2 (CNM2)"
    eLead := 1, eSmooth := 1, eDiv := true,  eRegime := true, eCorr := true,  recTF := "Weekly"
else if preset == "6 · Structural / Long-Term"
    eTransform := "Indexed to 100", eModMode := "Raw levels", eK := 0.15, eCnBase := "M2 (CNM2)"
    eLead := 0, eSmooth := 4, eDiv := false, eRegime := true, eCorr := false, recTF := "Monthly"

// ─────────────── Timeframe-aware lengths ───────────────
zLen    = zIn    > 0 ? zIn    : timeframe.isdaily ? 504 : timeframe.isweekly ? 104 : timeframe.ismonthly ? 24 : 504
corrLen = corrIn > 0 ? corrIn : timeframe.isdaily ? 252 : timeframe.isweekly ? 52  : timeframe.ismonthly ? 24 : 252
bpm     = timeframe.isdaily ? 21 : timeframe.isweekly ? 4 : timeframe.ismonthly ? 1 : 21
offBars = math.max(0, int(math.round(eLead * bpm)))

// ─────────────── Data ───────────────
tf = timeframe.period
cn10y  = request.security("TVC:CN10Y",         tf, close)
dxy    = request.security("TVC:DXY",           tf, close)
hyoas  = request.security("FRED:BAMLH0A0HYM2", tf, close)
uscbbs = request.security("ECONOMICS:USCBBS",  tf, close)
jpn    = request.security("FRED:JPNASSETS",    tf, close)
usdjpy = request.security("FX:USDJPY",         tf, close)
cncbbs = request.security("ECONOMICS:CNCBBS",  tf, close)
usdcny = request.security("FX_IDC:USDCNY",     tf, close)
ecb    = request.security("FRED:ECBASSETSW",   tf, close)
usdeur = request.security("FX_IDC:USDEUR",     tf, close)
cninbr = request.security("ECONOMICS:CNINBR",  tf, close)
cnm2   = request.security("ECONOMICS:CNM2",    tf, close)
cnm1   = request.security("ECONOMICS:CNM1",    tf, close)
// net liquidity + M2 sources
walcl  = request.security("FRED:WALCL",        tf, close)   // Fed total assets ($mn)
tga    = request.security("FRED:WTREGEN",      tf, close)   // Treasury General Account ($bn)
rrp    = request.security("FRED:RRPONTSYD",    tf, close)   // Overnight RRP ($bn)
usm2   = request.security("ECONOMICS:USM2",    tf, close)
eum2   = request.security("ECONOMICS:EUM2",    tf, close)
jpm2   = request.security("ECONOMICS:JPM2",    tf, close)
// inflation proxy + scanner basket
infl   = request.security(inflSym, tf, close)
a1 = request.security(a1s, tf, close)
a2 = request.security(a2s, tf, close)
a3 = request.security(a3s, tf, close)
a4 = request.security(a4s, tf, close)
a5 = request.security(a5s, tf, close)
a6 = request.security(a6s, tf, close)
a7 = request.security(a7s, tf, close)
a8 = request.security(a8s, tf, close)

// ─────────────── Helpers ───────────────
f_z(src, len) =>
    s = ta.stdev(src, len)
    na(s) or s == 0 ? na : (src - ta.sma(src, len)) / s

f_yoyM(src) =>
    var float[] buf = array.new_float()
    if timeframe.change("1M")
        array.push(buf, src)
        if array.size(buf) > 13
            array.shift(buf)
    ya = array.size(buf) >= 13 ? array.get(buf, 0) : na
    na(ya) or ya == 0 ? na : (src - ya) / ya * 100.0

f_er(src, len) =>            // Kaufman Efficiency Ratio: 1 = trending, 0 = choppy
    chg = math.abs(src - src[len])
    vol = math.sum(math.abs(src - src[1]), len)
    vol == 0 or na(vol) ? na : chg / vol

f_rocN(src, n) =>
    p = src[n]
    na(p) or p == 0 ? na : (src - p) / p * 100.0

// ─────────────── Liquidity stocks (source select + net liquidity) ───────────────
usLeg     = netLiq ? (walcl - tga*1000.0 - rrp*1000.0) : uscbbs
stockCBBS = usLeg + jpn/usdjpy + cncbbs/usdcny + ecb/usdeur
stockM2   = usm2  + jpm2/usdjpy + cnm2/usdcny   + eum2/usdeur
stockG    = globalSrc == "M2" ? stockM2 : globalSrc == "Average" ? (stockCBBS + stockM2)/2.0 : stockCBBS
cnStock   = eCnBase == "M2 (CNM2)" ? cnm2 : eCnBase == "M1 (CNM1)" ? cnm1 : cncbbs

// ─────────────── Composite (modulator mode) ───────────────
gRawMod = cn10y / dxy / hyoas * stockG
cRawMod = cn10y / usdcny / cninbr * cnStock
zTightG = f_z(dxy, zLen)    + f_z(hyoas, zLen)  - f_z(cn10y, zLen)
zTightC = f_z(usdcny, zLen) + f_z(cninbr, zLen) - f_z(cn10y, zLen)
gZMod = stockG  * math.exp(-eK * zTightG)
cZMod = cnStock * math.exp(-eK * zTightC)
globalLiq = eModMode == "Z-scored" ? gZMod : gRawMod
chinaLiq  = eModMode == "Z-scored" ? cZMod : cRawMod

// ─────────────── YoY, regime ───────────────
gYoY = f_yoyM(globalLiq)
cYoY = f_yoyM(chinaLiq)
regimeUp = gYoY > 0 and cYoY > 0
regimeDn = gYoY < 0 and cYoY < 0

// ─────────────── Display transform (+ double-norm + HMA) ───────────────
var float baseG = na
var float baseC = na
if na(baseG) and time >= anchorT and not na(globalLiq)
    baseG := globalLiq
if na(baseC) and time >= anchorT and not na(chinaLiq)
    baseC := chinaLiq

f_disp(src, base, yoy) =>
    eTransform == "Indexed to 100" ? (na(base) ? na : src/base*100.0) :
         eTransform == "YoY %"   ? yoy :
         eTransform == "Z-Score" ? f_z(src, zLen) : src

gB = f_disp(globalLiq, baseG, gYoY)
cB = f_disp(chinaLiq,  baseC, cYoY)
if eTransform == "Z-Score" and dblNorm
    gB := f_z(gB, zLen)
    cB := f_z(cB, zLen)
gH = ta.hma(gB, hmaLen)
cH = ta.hma(cB, hmaLen)
gDisp = ta.sma(useHMA ? gH : gB, eSmooth)
cDisp = ta.sma(useHMA ? cH : cB, eSmooth)
divCG = cDisp - gDisp

// ─────────────── Correlation to chart asset ───────────────
aYoY  = f_yoyM(close)
gLead = offBars > 0 ? gYoY[offBars] : gYoY
cLead = offBars > 0 ? cYoY[offBars] : cYoY
corrG = eCorr ? ta.correlation(aYoY, gLead, corrLen) : na
corrC = eCorr ? ta.correlation(aYoY, cLead, corrLen) : na

// ─────────────── Module 3: composite score & risk ───────────────
zScoreG = f_z(globalLiq, zLen)
zScoreC = f_z(chinaLiq,  zLen)
zDxyInv = -f_z(dxy, zLen)                       // weaker dollar = liquidity tailwind
scoreRaw = (zScoreG + zScoreC + zDxyInv) / 3.0
score = math.max(-100.0, math.min(100.0, scoreRaw * 33.0))
riskOn  = score >  scoreThr
riskOff = score < -scoreThr
riskTxt = riskOn ? "Risk-On" : riskOff ? "Risk-Off" : "Neutral"
riskCol = riskOn ? color.green : riskOff ? color.red : color.gray

// ─────────────── Module 4: signal quality ───────────────
erWin = math.max(2, 6*bpm)
er    = f_er(globalLiq, erWin)
sigTxt = na(er) ? "—" : er > 0.40 ? "Trending" : er < 0.20 ? "Choppy" : "Transitional"
sigCol = na(er) ? color.gray : er > 0.40 ? color.green : er < 0.20 ? color.red : color.orange

// ─────────────── Module 5: GRID regime ───────────────
inflMom = f_z(infl, zLen)
growthUp = gYoY > 0
inflUp   = inflMom > 0
grid = growthUp ? (inflUp ? "Reflation" : "Goldilocks") : (inflUp ? "Inflation" : "Deflation")
gridCol = grid == "Goldilocks" ? color.green : grid == "Reflation" ? color.teal : grid == "Inflation" ? color.orange : color.red

// ─────────────── Module 2: scanner ───────────────
refY = scanRef == "China" ? cYoY : gYoY
liqDir = math.sign(score)                       // liquidity momentum direction
a1y = f_yoyM(a1)
a2y = f_yoyM(a2)
a3y = f_yoyM(a3)
a4y = f_yoyM(a4)
a5y = f_yoyM(a5)
a6y = f_yoyM(a6)
a7y = f_yoyM(a7)
a8y = f_yoyM(a8)
c1 = ta.correlation(refY, a1y, corrLen)
c2 = ta.correlation(refY, a2y, corrLen)
c3 = ta.correlation(refY, a3y, corrLen)
c4 = ta.correlation(refY, a4y, corrLen)
c5 = ta.correlation(refY, a5y, corrLen)
c6 = ta.correlation(refY, a6y, corrLen)
c7 = ta.correlation(refY, a7y, corrLen)
c8 = ta.correlation(refY, a8y, corrLen)

f_sharpe(src) =>
    r  = ta.roc(src, corrLen)
    sd = ta.stdev(ta.roc(src, 1), corrLen)
    na(sd) or sd == 0 ? na : r / (sd * math.sqrt(corrLen))

// ─────────────── Plots ───────────────
colG = color.new(#00897B, 0)
colC = color.new(#F57C00, 0)
plot(showG ? gDisp : na, "Global Liquidity", color=colG, linewidth=2, offset=offBars)
plot(showC ? cDisp : na, "China Liquidity",  color=colC, linewidth=2, offset=offBars)

refLvl = eTransform == "Indexed to 100" ? 100.0 : (eTransform == "YoY %" or eTransform == "Z-Score") ? 0.0 : na
plot(refLvl, "Reference", color=color.new(color.gray, 40), linewidth=1)

divColor = math.abs(divCG) < noiseThr ? color.new(color.gray, 55) : (divCG >= 0 ? color.new(#26A69A, 35) : color.new(#EF5350, 35))
plot(eDiv ? divCG : na, "China − Global", style=plot.style_columns, color=divColor, offset=offBars)

bg = bgMode == "Risk-On/Off (score)" ? (riskOn ? color.new(color.green, 88) : riskOff ? color.new(color.red, 88) : na) : bgMode == "Regime (YoY)" and eRegime ? (regimeUp ? color.new(color.green, 88) : regimeDn ? color.new(color.red, 88) : na) : na
bgcolor(bg, title="Background")
barcolor(barCol ? riskCol : na, title="Risk bar color")

plot(plotScore ? score : na, "Score", color=color.new(color.blue, 20), linewidth=1)
plot(corrPlot and eCorr ? corrG : na, "Corr Global↔asset", color=color.new(#00897B, 45), linewidth=1)
plot(corrPlot and eCorr ? corrC : na, "Corr China↔asset",  color=color.new(#F57C00, 45), linewidth=1)

// ─────────────── Alerts ───────────────
alertcondition(ta.crossover(cYoY, 0),  "China YoY ▲ 0",  "China liquidity YoY crossed ABOVE zero.")
alertcondition(ta.crossunder(cYoY, 0), "China YoY ▼ 0",  "China liquidity YoY crossed BELOW zero.")
alertcondition(ta.crossover(gYoY, 0),  "Global YoY ▲ 0", "Global liquidity YoY crossed ABOVE zero.")
alertcondition(ta.crossunder(gYoY, 0), "Global YoY ▼ 0", "Global liquidity YoY crossed BELOW zero.")
alertcondition(ta.crossover(divCG, 0),  "Divergence ▲ (China leading)", "China−Global divergence flipped POSITIVE.")
alertcondition(ta.crossunder(divCG, 0), "Divergence ▼ (China lagging)", "China−Global divergence flipped NEGATIVE.")
alertcondition(ta.crossover(score, 0),  "Score ▲ 0 (Risk-On)",  "Composite liquidity score turned positive.")
alertcondition(ta.crossunder(score, 0), "Score ▼ 0 (Risk-Off)", "Composite liquidity score turned negative.")
alertcondition(regimeUp and not regimeUp[1], "Regime → Both expanding",   "Both proxies' YoY now > 0.")
alertcondition(regimeDn and not regimeDn[1], "Regime → Both contracting", "Both proxies' YoY now < 0.")

// ─────────────── Status table ───────────────
f_cellNum(v, u) => str.tostring(v, "#.##") + u
if showTable and barstate.islast
    var table t = table.new(position.top_right, 2, 14, border_width=1)
    table.clear(t, 0, 0, 1, 13)
    unit = eTransform == "YoY %" ? " %" : ""
    hdr  = color.new(color.gray, 70)
    regimeTxt = regimeUp ? "Both expanding" : regimeDn ? "Both contracting" : "Mixed"
    regimeCol = regimeUp ? color.green : regimeDn ? color.red : color.gray
    curTF = timeframe.isweekly ? "Weekly" : timeframe.ismonthly ? "Monthly" : timeframe.isdaily ? "Daily" : "Intraday"
    tfOk  = recTF == "—" or str.contains(recTF, curTF)
    int r = 0
    table.cell(t, 0, r, "Metric", bgcolor=hdr, text_color=color.white, text_size=size.small)
    table.cell(t, 1, r, eTransform, bgcolor=hdr, text_color=color.white, text_size=size.small)
    r += 1
    table.cell(t, 0, r, "Global", text_color=colG, text_size=size.small)
    table.cell(t, 1, r, f_cellNum(gDisp, unit), text_color=colG, text_size=size.small)
    r += 1
    table.cell(t, 0, r, "China", text_color=colC, text_size=size.small)
    table.cell(t, 1, r, f_cellNum(cDisp, unit), text_color=colC, text_size=size.small)
    r += 1
    table.cell(t, 0, r, "China−Global", text_color=color.white, text_size=size.small)
    table.cell(t, 1, r, f_cellNum(divCG, unit), text_color=divCG >= 0 ? color.new(#26A69A,0) : color.new(#EF5350,0), text_size=size.small)
    r += 1
    table.cell(t, 0, r, "YoY regime", text_color=color.white, text_size=size.small)
    table.cell(t, 1, r, regimeTxt, text_color=regimeCol, text_size=size.small)
    r += 1
    table.cell(t, 0, r, "Score", text_color=color.white, text_size=size.small)
    table.cell(t, 1, r, str.tostring(score, "#"), text_color=riskCol, text_size=size.small)
    r += 1
    table.cell(t, 0, r, "Risk state", text_color=color.white, text_size=size.small)
    table.cell(t, 1, r, riskTxt, text_color=riskCol, text_size=size.small)
    r += 1
    if showSig
        table.cell(t, 0, r, "Signal", text_color=color.white, text_size=size.small)
        table.cell(t, 1, r, sigTxt, text_color=sigCol, text_size=size.small)
        r += 1
    if showGrid
        table.cell(t, 0, r, "GRID", text_color=color.white, text_size=size.small)
        table.cell(t, 1, r, grid, text_color=gridCol, text_size=size.small)
        r += 1
    if eCorr
        table.cell(t, 0, r, "Corr G↔" + syminfo.ticker, text_color=color.white, text_size=size.small)
        table.cell(t, 1, r, f_cellNum(corrG, ""), text_color=corrG >= 0 ? color.new(#00897B,0) : color.new(#EF5350,0), text_size=size.small)
        r += 1
        table.cell(t, 0, r, "Corr C↔" + syminfo.ticker, text_color=color.white, text_size=size.small)
        table.cell(t, 1, r, f_cellNum(corrC, ""), text_color=corrC >= 0 ? color.new(#F57C00,0) : color.new(#EF5350,0), text_size=size.small)
        r += 1
    if showRoC
        table.cell(t, 0, r, "G RoC 3/6/12m", text_color=color.white, text_size=size.small)
        table.cell(t, 1, r, str.tostring(f_rocN(globalLiq, bpm*3), "#") + " / " + str.tostring(f_rocN(globalLiq, bpm*6), "#") + " / " + str.tostring(f_rocN(globalLiq, bpm*12), "#"), text_color=color.silver, text_size=size.small)
        r += 1
    table.cell(t, 0, r, "Rec. TF", text_color=color.white, text_size=size.small)
    table.cell(t, 1, r, recTF + " (now: " + curTF + ")", text_color=tfOk ? color.green : color.orange, text_size=size.small)

// ─────────────── Scanner table ───────────────
var table st = table.new(position.bottom_right, 4, 9, border_width=1)

f_row(tbl, idx, sym, src, corr) =>
    dir = corr >= 0 ? liqDir : -liqDir
    arrow = dir > 0 ? "▲" : dir < 0 ? "▼" : "–"
    acol = dir > 0 ? color.green : dir < 0 ? color.red : color.gray
    ccol = math.abs(corr) > 0.5 ? color.white : color.new(color.gray, 30)
    table.cell(tbl, 0, idx, sym, text_color=color.silver, text_size=size.small)
    table.cell(tbl, 1, idx, str.tostring(corr, "#.##"), text_color=ccol, text_size=size.small)
    table.cell(tbl, 2, idx, arrow, text_color=acol, text_size=size.small)
    if scanSharpe
        table.cell(tbl, 3, idx, str.tostring(f_sharpe(src), "#.##"), text_color=color.silver, text_size=size.small)

if showScan and barstate.islast
    table.clear(st, 0, 0, 3, 8)
    hdr = color.new(color.gray, 70)
    table.cell(st, 0, 0, "Asset (ref " + scanRef + ")", bgcolor=hdr, text_color=color.white, text_size=size.small)
    table.cell(st, 1, 0, "Corr", bgcolor=hdr, text_color=color.white, text_size=size.small)
    table.cell(st, 2, 0, "Impl", bgcolor=hdr, text_color=color.white, text_size=size.small)
    if scanSharpe
        table.cell(st, 3, 0, "Sharpe~", bgcolor=hdr, text_color=color.white, text_size=size.small)
    f_row(st, 1, a1s, a1, c1)
    f_row(st, 2, a2s, a2, c2)
    f_row(st, 3, a3s, a3, c3)
    f_row(st, 4, a4s, a4, c4)
    f_row(st, 5, a5s, a5, c5)
    f_row(st, 6, a6s, a6, c6)
    f_row(st, 7, a7s, a7, c7)
    f_row(st, 8, a8s, a8, c8)

// ─────────────── Timeframe guard ───────────────
if barstate.islast and not (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)
    var table w = table.new(position.bottom_center, 1, 1)
    table.cell(w, 0, 0, "⚠ Economic data is monthly — use Daily, Weekly, or Monthly", bgcolor=color.new(color.orange, 0), text_color=color.black, text_size=size.small)
````
