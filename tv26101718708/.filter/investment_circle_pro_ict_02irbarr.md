# Investment Circle Pro ICT

- url: https://www.tradingview.com/script/02IrbARr-Investment-Circle-Pro-ICT/
- type: indicator
- pine_id: PUB;f64bd7230dd249e0831414c87d36049e
- version: 1.0

## Description

v20 — Momentum signals, exit markers, position calculator & stability fix
This update reworks how entries are generated, adds exit markers, a position-size calculator, and fixes a memory issue that could cause the indicator to stop updating over long sessions.
New

Momentum signal engine (primary): buy/sell arrows now print when momentum turns up in an up-trend or down in a down-trend, with a selectable trend filter (EMA50 / Supertrend / multi-timeframe / none) and an adjustable cooldown. This replaces the old, rarely-firing zone-only trigger.
Exit markers (X): every long/short signal now also gets a "finished" marker when momentum rolls back against it — so you see both the start and the end of a move.
Flip on opposite signal: an opposing signal closes the active trade so you're never left in a stale position.
Position calculator: enter trade size, SL% and TP% (as % of stake), an optional "Buy 2" top-up and your leverage; the panel returns loss/profit in money, market exposure, the price move needed to reach SL/TP, and R:R. Optional auto-mode pulls SL%/TP% from the active signal.
Buyside/Sellside liquidity (BSL/SSL): equal highs/lows are marked as liquidity pools, flagged when swept, and used as take-profit targets.
Session levels: Asia / London / NY session highs and lows drawn as clean horizontal levels (no boxes).
Configurable macro asset: point the macro panel at gold, silver, oil, copper, OMX30, Nasdaq 100 or S&P 500.

Improved

OB and inverted-FVG zones are now toggleable independently, with a size filter to reduce clutter.
New-listing safeguard: no signals until enough history exists (useful on fresh IPOs).
Added a session filter, panel position/size controls, and a separate signal/performance panel (win rate, profit factor, expectancy, net PnL%).

Fixed

Stability: the dashboard and panels were being rebuilt on every tick, which could exhaust memory over a long session and make the indicator stop updating until re-added. Panels are now created once and only refreshed — this should resolve the "disappears after a day" issue.

This tool is for technical analysis and education only. It is not financial advice and does not predict future results. Always do your own research and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Westfelt

//@version=6
indicator("Investment Circle Pro ICT", overlay=true, max_bars_back=500, max_boxes_count=100, max_lines_count=200, max_labels_count=500)

// ============================================================================
// InvestmentCircle ICP v19
//  - SMC + volym-motor (struktur, sweep, displacement+FVG, order block, P/D)
//  - Strukturell SL + TP1/2/3 och DCA2 i R (risk multiples)
//  - R/Expectancy-tracker (modellerar 3 partiella TP + break-even; ej DCA)
//  - Utritade OB- och FVG-zoner
//  - Ombyggd, renare dashboard
//  OBS: pivots bekraftas swLen barer efter topp/botten => strukturen slapar
//  nagra barer (ej repaint). Ingen garanti for hitrate - backtesta sjalv.
// ============================================================================

// ---------------------------------------------------------------- Inputs
g1 = "Trend"
emaFast  = input.int(9,    "EMA Fast",  group=g1)
emaSlow  = input.int(21,   "EMA Slow",  group=g1)
emaFilt  = input.int(50,   "EMA 50",    group=g1)
stFactor = input.float(2.0,"ST Factor", group=g1)
stAtrLen = input.int(10,   "ST ATR",    group=g1)
adxLen   = input.int(14,   "ADX Len",   group=g1)
adxMin   = input.int(18,   "ADX Min",   group=g1)

g2 = "Momentum"
rsiLen  = input.int(14, "RSI Len",   group=g2)
macdF   = input.int(12, "MACD Fast", group=g2)
macdSl  = input.int(26, "MACD Slow", group=g2)
macdSig = input.int(9,  "MACD Sig",  group=g2)
stochK  = input.int(14, "Stoch K",   group=g2)
stochD  = input.int(3,  "Stoch D",   group=g2)
stochSm = input.int(3,  "Stoch Sm",  group=g2)

g9 = "Structure / Zones"
swLen    = input.int(8,     "Swing-pivot langd",          group=g9, tooltip="Bekraftas swLen barer efter topp/botten - strukturen slapar nagra barer (ej repaint).")
dispVolX = input.float(1.5, "Displacement-volym x snitt", group=g9, step=0.1)
obVolX   = input.float(1.2, "OB-volym x snitt",           group=g9, step=0.1)
sweepWin = input.int(6,     "Sweep giltig i N barer",     group=g9)
relevATR = input.float(12.0,"Zon relevant inom (ATR)",    group=g9, tooltip="Zoner narmare priset an detta (i ATR) visas tydligt, langre bort tonas ned.")
ifvgMinATR = input.float(1.0, "iFVG min storlek (ATR)",   group=g9, step=0.1, tooltip="Bara iFVG-zoner hogre an detta (i ATR) ritas - filtrerar bort smatt kladd. Hogre varde = bara de storre zonerna.")

g5 = "Key Levels"
showPD   = input.bool(true, "PDH PDL",  group=g5)
showPW   = input.bool(true, "PWH PWL",  group=g5)
showPM   = input.bool(true, "PMH PML",  group=g5)
showEQ   = input.bool(true, "Premium/Discount", group=g5)
showLiq  = input.bool(true, "Liquidity BSL/SSL", group=g5, tooltip="Markerar likviditetspooler vid lika toppar (buyside, BSL) och lika bottnar (sellside, SSL) - dar stop-orders ofta ligger.")
eqTol    = input.float(0.5, "EQH/EQL tolerans (ATR)", group=g5, step=0.1, tooltip="Hur nara tva toppar/bottnar maste vara for att raknas som en likviditetspool.")

g6 = "Visuals"
showVwap  = input.bool(true, "VWAP",        group=g6)
showDash  = input.bool(true, "Dashboard",   group=g6)
showBOS   = input.bool(true, "BOS CHoCH",   group=g6)
showSwings= input.bool(true, "Swing labels HH/HL/LH/LL", group=g6)
showOB    = input.bool(true, "OB zones", group=g6)
showIFVG  = input.bool(true, "iFVG zones", group=g6, tooltip="Inverterade FVG-zoner pa chart-timeframen. Bara zoner storre an 'iFVG min storlek' ritas (mot kladd).")
showSigPanel = input.bool(false, "Signal + Performance-panel (separat)", group=g6, tooltip="Visar en egen liten panel nere till hoger med aktiv signal och statistik. Av = renare graf.")
keepSigHist  = input.bool(false, "Behall gamla signal-markorer", group=g6, tooltip="Pa = alla BUY/SELL/EXIT-markorer ligger kvar pa grafen (bra for att utvardera historik). Av = bara den aktiva visas.")

g10 = "Level 2: MTF EQ + POC"
showMtfEq = input.bool(true, "MTF Equilibrium (1h/4h)", group=g10)
eqLook    = input.int(60,    "EQ lookback (HTF-barer)",  group=g10)
showPOC   = input.bool(true, "POC line",                 group=g10, tooltip="Point of Control = mest handlade priset (volym) over fonstret.")
pocLen    = input.int(150,   "POC lookback (barer)",     group=g10)
pocBins   = input.int(50,    "POC upplosning (bins)",    group=g10)

g11 = "Signal (SMC zon/sweep - avancerat)"
enableSig  = input.bool(false, "Aktivera SMC zon/sweep-signaler", group=g11, tooltip="Den gamla SMC-motorn (zon-tap + sweep). Av som standard - momentum-motorn nedan ar nu primar.")
enable1H   = input.bool(true, "1H swing-setups (HTF haller med)", group=g11, tooltip="Setups i linje med hogre timeframe-trenden. Storre mal, langre halltid.")
enable5M   = input.bool(true, "5M scalp-setups (lokal reaktion)", group=g11, tooltip="Snabbare reaktioner som inte kraver HTF-medhall. Tightare, kortare livslangd.")
useSmartExit = input.bool(true, "Smart exit (momentum/volym)", group=g11, tooltip="Stang traden tidigt nar farten gar ur: MACD vander emot positionen, motsatt impuls, eller tva barer med under-snitts-volym i vinst.")
confirmWin = input.int(6, "Bekraftelse-fonster (barer)", group=g11, tooltip="Efter att priset tappat en zon: sa manga barer far det ta innan en bekraftande stangning kommer. Storre = fler men senare signaler.")
reqLoc     = input.bool(false, "Krav: ratt premium/discount-lage", group=g11, tooltip="Av = fler signaler. Pa = ta bara long i discount och short i premium (kvalitet, men faerre).")
reqStruct  = input.bool(true,  "Krav: struktur i linje", group=g11, tooltip="Av = fler signaler (tillater motvands-bounces). Pa = bara med lokal struktur.")
slBufAtr   = input.float(0.3, "SL-buffert (ATR)",             group=g11, step=0.1)
sigCool    = input.int(3,     "Cooldown (barer)",             group=g11, tooltip="Min antal barer mellan signaler. Lagre = fler signaler.")
sigMaxBars = input.int(60,    "Max livslangd pa ritning",     group=g11, tooltip="Hur lange en 1H-trade ligger kvar innan timeout. 5M anvander ca 40% av detta.")
riskPct    = input.float(1.0, "Risk per trade % (for PNL%)",  group=g11, step=0.25, tooltip="Antagen risk per trade. PNL% = summa R x denna risk.")
minHist    = input.int(100,  "Min historik for signaler (barer)", group=g11, tooltip="Inga signaler forran sa har manga barer finns - skyddar mot skrap pa nya noteringar (t.ex. IPO:er) utan historik.")
enableSweep = input.bool(true, "Sweep-entries (BSL/SSL + CHoCH)", group=g11, tooltip="Avfyra nar priset tar ut en likviditetspool (BSL/SSL) och sedan vander med CHoCH. Kraver att Liquidity BSL/SSL ar pa.")
reqEntryVol = input.bool(false, "Krav: volym/impuls vid entry", group=g11, tooltip="Bara signaler dar bekraftelse-baren har over-snitts-volym eller ar en impuls. Faerre men starkare signaler.")
useSession = input.bool(false, "Handla bara vald session",    group=g11, tooltip="Filtrerar bort signaler utanfor sessionen (t.ex. tunn asiatisk handel for guld/forex).")
sessTime   = input.session("0800-2100", "Session (chart-tid)", group=g11, tooltip="Ungefar London-oppning till NY-stangning. Justera efter din chart-tidszon.")

g12 = "Layout (paneler)"
dashPos = input.string("Top Right",    "Huvudpanel: placering",     options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=g12)
dashSz  = input.string("Small",        "Huvudpanel: textstorlek",   options=["Tiny", "Small", "Normal", "Large"], group=g12)
panPos  = input.string("Bottom Right", "Signal-panel: placering",   options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=g12)
panSz   = input.string("Small",        "Signal-panel: textstorlek", options=["Tiny", "Small", "Normal", "Large"], group=g12)

g13 = "Sessions"
sessAsiaOn = input.bool(true, "Asia",   group=g13, inline="a", tooltip="Sessionernas high/low ritas som horisontella nivaer (PDL-stil). Tiderna ar i din chart-tidszon - justera falten om linjerna hamnar fel.")
sessAsia   = input.session("0000-0800", "", group=g13, inline="a")
sessLonOn  = input.bool(true, "London", group=g13, inline="l")
sessLon    = input.session("0800-1600", "", group=g13, inline="l")
sessNYOn   = input.bool(true, "NY",     group=g13, inline="n")
sessNY     = input.session("1330-2200", "", group=g13, inline="n")
colA       = input.color(#5aa0c7, "Asia",   group=g13, inline="ca")
colL       = input.color(#c79a3a, "London", group=g13, inline="cl")
colN       = input.color(#a86bb0, "NY",     group=g13, inline="cn")

g14 = "Positionskalkylator"
showCalc    = input.bool(true,  "Visa positionskalkylator", group=g14, tooltip="Visas som en sektion langst ner i huvudpanelen.")
calcAuto    = input.bool(false, "Auto: hamta SL/TP fran aktiv signal", group=g14, tooltip="Pa = SL% och TP% raknas fran den aktiva signalens entry/SL/TP3. Av = anvand faltens varden nedan.")
tradeKr     = input.float(10000, "Tradestorlek (kr)", group=g14, step=1000, tooltip="Summan du satsar i traden (din insats).")
kop2On      = input.bool(false,  "Lagg till Kop 2 (fyll pa)", group=g14, tooltip="Andra ingangen som fyller pa positionen med beloppet nedan.")
kop2Kr      = input.float(10000, "Kop 2 (kr)",        group=g14, step=1000, tooltip="Summa som laggs till originalsumman vid Kop 2.")
slCalcPct   = input.float(5.0,   "SL % (av tradesumman)", group=g14, step=0.5, tooltip="Hur manga procent av totala tradesumman du ar villig att forlora.")
tpCalcPct   = input.float(10.0,  "TP %",              group=g14, step=0.5, tooltip="Vinstmal i procent av totala tradesumman.")
levCalc     = input.float(10,    "Havstang",          group=g14, step=1, tooltip="Din havstang. Pverkar inte kr-forlust/vinst (de ar % av insatsen) men visar hur lite priset behover rora sig for att na SL/TP.")

g15 = "Momentum-signaler (primar)"
enableMom   = input.bool(true,  "Momentum-signaler (kop/salj-pilar)", group=g15, tooltip="Pil upp = momentum vander upp i uppattrend (kop). Pil ner = momentum vander ner i nedattrend (salj). Ritas pa varje signal.")
momTrendType = input.string("EMA50", "Trendfilter", options=["EMA50", "Supertrend", "MTF", "Inget"], group=g15, tooltip="Vad som maste halla med for en signal. 'Inget' = inga trendkrav (flest signaler).")
momCool     = input.int(6,      "Cooldown (barer)", group=g15, tooltip="Min antal barer mellan momentum-signaler. Lagre = fler.")
momRsiBuy   = input.int(45,     "RSI kop-niva",  group=g15, tooltip="RSI som korsas uppat raknas som kop-trigger.")
momRsiSell  = input.int(55,     "RSI salj-niva", group=g15, tooltip="RSI som korsas nerat raknas som salj-trigger.")
momSlLook   = input.int(10,     "SL swing-lookback", group=g15, tooltip="SL placeras bortom hogsta/lagsta de senaste sa har barerna.")
momFlip     = input.bool(true,  "Vand position pa motsatt signal", group=g15, tooltip="Stang en aktiv trade direkt nar en motsatt signal kommer.")
enableMomExit = input.bool(true, "Visa exit-markorer (X)", group=g15, tooltip="Satter ett gratt kryss nar en kop/salj-signal bedoms vara over (MACD/EMA vander emot, eller trendfiltret flippar). Kryss ovanfor = lang ar slut, kryss under = kort ar slut.")

g8 = "Macro DXY US10Y"
macroAsset = input.string("Guld", "Makro-outlook for", options=["Guld", "Silver", "Olja", "Koppar", "OMX30", "Nasdaq100", "SP500"], group=g8, tooltip="Vilken tillgang makro-outlooken galler. Ravaror ar USD-prissatta (svagare dollar = medvind). Index ar rantekansliga (lagre rantor = medvind).")
dxySym   = input.symbol("TVC:DXY",   "DXY symbol",   group=g8)
us10ySym = input.symbol("TVC:US10Y", "US10Y symbol", group=g8)

// ---------------------------------------------------------------- Helpers
bTxt(v)  => v ? "Bullish" : "Bearish"
bCol(v)  => v ? color.new(#2f7d5b, 0) : color.new(#a8413d, 0)
mSig(b)  => b ? "Bull" : "Bear"
mColF(b) => b ? color.new(#2f7d5b, 0) : color.new(#a8413d, 0)
f_lvl(x) => na(x) ? "-" : str.tostring(math.round(x, 2))
f_ago(b) => na(b) ? "" : (bar_index - b == 0 ? "now" : str.tostring(bar_index - b) + " bars ago")
f_dir(d) => d == 1 ? "Bullish" : d == -1 ? "Bearish" : "-"
f_de(d, b) => d == 0 ? "-" : f_dir(d) + ", " + f_ago(b)
f_bar(pct) =>
    filled = math.max(0, math.min(10, math.round(pct / 100 * 10)))
    out = ""
    for i = 1 to 10
        out := out + (i <= filled ? "|" : ".")
    out

// ---------------------------------------------------------------- Auto HTF
var string htf = "60"
if timeframe.isminutes
    if timeframe.multiplier <= 15
        htf := "60"
    else if timeframe.multiplier <= 60
        htf := "240"
    else if timeframe.multiplier <= 240
        htf := "D"
    else
        htf := "W"
else
    htf := "W"

// ---------------------------------------------------------------- Indicators
ef   = ta.ema(close, emaFast)
es   = ta.ema(close, emaSlow)
e50  = ta.ema(close, emaFilt)
emaBull = close > ef and ef > es and close > e50
emaBear = close < ef and ef < es and close < e50

[stLine, stDir] = ta.supertrend(stFactor, stAtrLen)
stBull = stDir < 0
stBear = stDir > 0

[dip, dim, adxVal] = ta.dmi(adxLen, adxLen)
adxOk = adxVal > adxMin

rsi = ta.rsi(close, rsiLen)
[macdLine, sigLine, histLine] = ta.macd(close, macdF, macdSl, macdSig)
kLine = ta.sma(ta.stoch(close, high, low, stochK), stochSm)
dLine = ta.sma(kLine, stochD)

atr   = ta.atr(14)
atrMa = ta.sma(atr, 20)
atrOk = atr > atrMa * 0.7

vma   = ta.sma(volume, 20)
volOk = volume > vma * 1.1

// Session buy/sell volume
var float sBuyVol  = 0.0
var float sSellVol = 0.0
if dayofweek != dayofweek[1]
    sBuyVol  := 0.0
    sSellVol := 0.0
sBuyVol  += close >= open ? volume : 0.0
sSellVol += close <  open ? volume : 0.0

// HTF filter (1 anrop)
[htfC, htfEF, htfES] = request.security(syminfo.tickerid, htf, [close, ta.ema(close, emaFast), ta.ema(close, emaSlow)])
htfBull = htfC > htfEF and htfEF > htfES
htfBear = htfC < htfEF and htfEF < htfES
htfPct  = htfES != 0 ? (htfC - htfES) / htfES * 100 : 0.0

// MTF (5 anrop)
[tf5b,   tf5rsi]   = request.security(syminfo.tickerid, "5",   [ta.ema(close,9) > ta.ema(close,21), ta.rsi(close,14)])
[tf15b,  tf15rsi]  = request.security(syminfo.tickerid, "15",  [ta.ema(close,9) > ta.ema(close,21), ta.rsi(close,14)])
[tf60b,  tf60rsi]  = request.security(syminfo.tickerid, "60",  [ta.ema(close,9) > ta.ema(close,21), ta.rsi(close,14)])
[tf240b, tf240rsi] = request.security(syminfo.tickerid, "240", [ta.ema(close,9) > ta.ema(close,21), ta.rsi(close,14)])
[tf1db,  tf1drsi]  = request.security(syminfo.tickerid, "D",   [ta.ema(close,9) > ta.ema(close,21), ta.rsi(close,14)])
tf5pct   = math.round(math.min(100, math.abs(tf5rsi   - 50) * 2), 0)
tf15pct  = math.round(math.min(100, math.abs(tf15rsi  - 50) * 2), 0)
tf60pct  = math.round(math.min(100, math.abs(tf60rsi  - 50) * 2), 0)
tf240pct = math.round(math.min(100, math.abs(tf240rsi - 50) * 2), 0)
tf1dpct  = math.round(math.min(100, math.abs(tf1drsi  - 50) * 2), 0)

// Macro (1 anrop per symbol, dagens close vs open, inga gap)
[dxyClose,   dxyOpen]   = request.security(dxySym,   "D", [close, open], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[us10yClose, us10yOpen] = request.security(us10ySym, "D", [close, open], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
dxyUp    = dxyClose > dxyOpen
us10yUp  = us10yClose > us10yOpen
dxyChg   = dxyOpen   != 0 ? (dxyClose   - dxyOpen)   / dxyOpen   * 100 : 0.0
us10yChg = us10yOpen != 0 ? (us10yClose - us10yOpen) / us10yOpen * 100 : 0.0
macroIsIndex = macroAsset == "OMX30" or macroAsset == "Nasdaq100" or macroAsset == "SP500"
// Index: rantor dominerar (lagre = medvind). Ravaror: svag dollar + lagre rantor = medvind.
macroBull = macroIsIndex ? (not us10yUp and not dxyUp) : (not dxyUp and not us10yUp)
macroBear = macroIsIndex ? us10yUp : (dxyUp and us10yUp)

// Countdown
bSec  = timeframe.in_seconds()
elap  = math.round((timenow - time) / 1000)
rSec  = math.max(0, bSec - elap)
rMin  = math.floor(rSec / 60)
rSec2 = rSec - rMin * 60
cdTxt = rMin > 0 ? str.tostring(rMin) + ":" + (rSec2 < 10 ? "0" : "") + str.tostring(rSec2) : str.tostring(rSec2) + "s"

// Strength
rsiStr  = (rsi - 50) * 2
macdStr = sigLine != 0 ? math.min(math.max(histLine / math.abs(sigLine) * 100, -100), 100) : 0.0
emaStr  = es == 0 ? 0.0 : emaBull ? math.min((ef - es) / es * 5000, 100) : emaBear ? math.max((ef - es) / es * 5000, -100) : 0.0
tfStr   = (rsiStr + macdStr + emaStr) / 3
tfBull  = tfStr >= 0
strPct  = math.max(0, math.min(100, 50 + tfStr / 2))

// ================================================================ SMC ENGINE
// Struktur (swings)
ph = ta.pivothigh(high, swLen, swLen)
pl = ta.pivotlow(low,  swLen, swLen)
var float swHigh = na
var float swLow  = na
var float prevSwHigh = na
var float prevSwLow  = na
var int   swHighBar = na
var int   swLowBar  = na
if not na(ph)
    prevSwHigh := swHigh
    swHigh := ph
    swHighBar := bar_index - swLen
    if showSwings
        hhlh = na(prevSwHigh) or ph > prevSwHigh ? "HH" : "LH"
        label.new(bar_index - swLen, ph + atr * 0.2, hhlh, style=label.style_none, textcolor=hhlh == "HH" ? #4aa583 : #c98b6b, size=size.small)
if not na(pl)
    prevSwLow := swLow
    swLow := pl
    swLowBar := bar_index - swLen
    if showSwings
        hlll = na(prevSwLow) or pl < prevSwLow ? "LL" : "HL"
        label.new(bar_index - swLen, pl - atr * 0.2, hlll, style=label.style_none, textcolor=hlll == "HL" ? #4aa583 : #c98b6b, size=size.small)

var int structDir = 0

// Sweep-setup (vantande) + alert-flagga
var int   pendSwpDir = 0
var float pendSwpLvl = na
var int   pendSwpBar = na
bool aSweep = false

// ============ Buyside / Sellside liquidity (EQH / EQL) ============
// Lika toppar = buyside-likviditet (BSL, stops over). Lika bottnar = sellside (SSL, stops under).
var array<line>  liqLn  = array.new<line>()
var array<label> liqLb  = array.new<label>()
var array<float> liqLvl = array.new<float>()
var array<int>   liqDir = array.new<int>()
var array<bool>  liqOn  = array.new<bool>()

if showLiq and not na(ph) and not na(prevSwHigh) and math.abs(ph - prevSwHigh) <= eqTol * atr
    lvl = math.max(ph, prevSwHigh)
    lN  = line.new(swHighBar, lvl, bar_index + 10, lvl, color=color.new(#c79a3a, 15), width=1, style=line.style_dotted)
    lB  = label.new(bar_index + 10, lvl, "BSL", style=label.style_none, textcolor=color.new(#c79a3a, 0), size=size.tiny, textalign=text.align_left)
    array.push(liqLn, lN)
    array.push(liqLb, lB)
    array.push(liqLvl, lvl)
    array.push(liqDir, 1)
    array.push(liqOn, true)
if showLiq and not na(pl) and not na(prevSwLow) and math.abs(pl - prevSwLow) <= eqTol * atr
    lvl = math.min(pl, prevSwLow)
    lN  = line.new(swLowBar, lvl, bar_index + 10, lvl, color=color.new(#5aa0c7, 15), width=1, style=line.style_dotted)
    lB  = label.new(bar_index + 10, lvl, "SSL", style=label.style_none, textcolor=color.new(#5aa0c7, 0), size=size.tiny, textalign=text.align_left)
    array.push(liqLn, lN)
    array.push(liqLb, lB)
    array.push(liqLvl, lvl)
    array.push(liqDir, -1)
    array.push(liqOn, true)

if showLiq and array.size(liqLn) > 0
    for i = array.size(liqLn) - 1 to 0
        ln  = array.get(liqLn, i)
        lb  = array.get(liqLb, i)
        lvl = array.get(liqLvl, i)
        d   = array.get(liqDir, i)
        if array.get(liqOn, i)
            taken = d == 1 ? high >= lvl : low <= lvl
            if taken
                array.set(liqOn, i, false)
                line.set_x2(ln, bar_index)
                line.set_color(ln, color.new(#5a6470, 55))
                line.set_style(ln, line.style_dashed)
                label.set_text(lb, (d == 1 ? "BSL" : "SSL") + " swept")
                label.set_x(lb, bar_index)
                label.set_textcolor(lb, color.new(#5a6470, 25))
                aSweep := true
                // Arma sweep-setup: BSL svept -> mojlig SHORT, SSL svept -> mojlig LONG
                if enableSweep
                    pendSwpDir := d == 1 ? -1 : 1
                    pendSwpLvl := lvl
                    pendSwpBar := bar_index
            else
                line.set_x2(ln, bar_index + 10)
                label.set_x(lb, bar_index + 10)
    if array.size(liqLn) > 16
        line.delete(array.shift(liqLn))
        label.delete(array.shift(liqLb))
        array.shift(liqLvl)
        array.shift(liqDir)
        array.shift(liqOn)


bosU = not na(swHigh) and close > swHigh and close[1] <= swHigh
bosD = not na(swLow)  and close < swLow  and close[1] >= swLow
chU  = bosU and structDir == -1
chD  = bosD and structDir == 1
if bosU
    structDir := 1
if bosD
    structDir := -1

// Likviditets-sweep
swpLow  = not na(swLow)  and low  < swLow  and close > swLow
swpHigh = not na(swHigh) and high > swHigh and close < swHigh
var int swpLowBar  = na
var int swpHighBar = na
if swpLow
    swpLowBar := bar_index
if swpHigh
    swpHighBar := bar_index
sweepLongOk  = not na(swpLowBar)  and bar_index - swpLowBar  <= sweepWin
sweepShortOk = not na(swpHighBar) and bar_index - swpHighBar <= sweepWin

// Displacement + FVG, volymbekraftad
fvgUp  = low  > high[2]
fvgDn  = high < low[2]
dispUp = fvgUp and close > open and volume > vma * dispVolX
dispDn = fvgDn and close < open and volume > vma * dispVolX

// Order block (sista motsatta candle fore displacement, med volym)
obBullValid = close[2] < open[2] and volume[2] > vma * obVolX
obBearValid = close[2] > open[2] and volume[2] > vma * obVolX

// Premium / Discount
eqLevel    = not na(swHigh) and not na(swLow) ? (swHigh + swLow) / 2 : hlc3
inDiscount = close < eqLevel
inPremium  = close > eqLevel

// Volym pa baren
volBullOk = close > open and volume > vma
volBearOk = close < open and volume > vma

// ================================================================
// SIGNAL-DELEN BORTTAGEN (byggs om fran grunden).
// Strukturanalysen ovan (swings, BOS/CHoCH, sweep, displacement, OB,
// premium/discount) lever vidare och driver visuals + dashboard.
// ================================================================

// ================================================================ DRAWINGS
// VWAP
vwap = ta.vwap(hlc3)
plot(showVwap ? vwap : na, "VWAP", color.new(color.white, 15), 2)

// Key levels (3 anrop, lookahead_on + [1] = korrekt)
[pdH, pdL] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pwH, pwL] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[pmH, pmL] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead=barmerge.lookahead_on)

var line ln_pdH = na
var line ln_pdL = na
var line ln_pwH = na
var line ln_pwL = na
var line ln_pmH = na
var line ln_pmL = na
var label lb_pdH = na
var label lb_pdL = na
var label lb_pwH = na
var label lb_pwL = na
var label lb_pmH = na
var label lb_pmL = na
if barstate.islast
    line.delete(ln_pdH), line.delete(ln_pdL), line.delete(ln_pwH), line.delete(ln_pwL), line.delete(ln_pmH), line.delete(ln_pmL)
    label.delete(lb_pdH), label.delete(lb_pdL), label.delete(lb_pwH), label.delete(lb_pwL), label.delete(lb_pmH), label.delete(lb_pmL)
    startBar = math.max(0, bar_index - 300)
    if showPD
        ln_pdH := line.new(startBar, pdH, bar_index + 5, pdH, color=color.new(color.white, 20), width=1, extend=extend.right)
        ln_pdL := line.new(startBar, pdL, bar_index + 5, pdL, color=color.new(color.white, 20), width=1, extend=extend.right)
        lb_pdH := label.new(bar_index + 3, pdH, "PDH", style=label.style_none, textcolor=color.new(color.white, 20), size=size.small)
        lb_pdL := label.new(bar_index + 3, pdL, "PDL", style=label.style_none, textcolor=color.new(color.white, 20), size=size.small)
    if showPW
        ln_pwH := line.new(startBar, pwH, bar_index + 5, pwH, color=color.new(color.white, 45), width=1, extend=extend.right)
        ln_pwL := line.new(startBar, pwL, bar_index + 5, pwL, color=color.new(color.white, 45), width=1, extend=extend.right)
        lb_pwH := label.new(bar_index + 3, pwH, "PWH", style=label.style_none, textcolor=color.new(color.white, 35), size=size.small)
        lb_pwL := label.new(bar_index + 3, pwL, "PWL", style=label.style_none, textcolor=color.new(color.white, 35), size=size.small)
    if showPM
        ln_pmH := line.new(startBar, pmH, bar_index + 5, pmH, color=color.new(#c7a45a, 45), width=1, style=line.style_dotted, extend=extend.right)
        ln_pmL := line.new(startBar, pmL, bar_index + 5, pmL, color=color.new(#c7a45a, 45), width=1, style=line.style_dotted, extend=extend.right)
        lb_pmH := label.new(bar_index + 3, pmH, "PMH", style=label.style_none, textcolor=color.new(#c7a45a, 20), size=size.small)
        lb_pmL := label.new(bar_index + 3, pmL, "PML", style=label.style_none, textcolor=color.new(#c7a45a, 20), size=size.small)

// ---------------------------------------------------------------- Sessions (high/low-nivaer, PDL-stil)
// Per session: spara high/low, rita horisontella nivaer som extenderar hoger (som PDH/PDL).
var array<float> ssHi  = array.new<float>(3, na)
var array<float> ssLo  = array.new<float>(3, na)
var array<line>  ssHiL = array.new<line>(3, na)
var array<line>  ssLoL = array.new<line>(3, na)
var array<label> ssHiB = array.new<label>(3, na)
var array<label> ssLoB = array.new<label>(3, na)

aIn = sessAsiaOn and not na(time(timeframe.period, sessAsia))
lIn = sessLonOn  and not na(time(timeframe.period, sessLon))
nIn = sessNYOn   and not na(time(timeframe.period, sessNY))
insArr   = array.from(aIn, lIn, nIn)
startArr = array.from(aIn and not aIn[1], lIn and not lIn[1], nIn and not nIn[1])
nmArr    = array.from("Asia", "London", "NY")
colArr   = array.from(colA, colL, colN)

if barstate.isconfirmed
    for i = 0 to 2
        ins = array.get(insArr, i)
        st  = array.get(startArr, i)
        nm  = array.get(nmArr, i)
        col = array.get(colArr, i)
        if st
            array.set(ssHi, i, high)
            array.set(ssLo, i, low)
            line.delete(array.get(ssHiL, i))
            line.delete(array.get(ssLoL, i))
            label.delete(array.get(ssHiB, i))
            label.delete(array.get(ssLoB, i))
            array.set(ssHiL, i, line.new(bar_index, high, bar_index + 5, high, color=color.new(col, 40), width=1, style=line.style_dotted, extend=extend.right))
            array.set(ssLoL, i, line.new(bar_index, low,  bar_index + 5, low,  color=color.new(col, 40), width=1, style=line.style_dotted, extend=extend.right))
            array.set(ssHiB, i, label.new(bar_index + 3, high, nm + " H", style=label.style_none, textcolor=color.new(col, 12), size=size.small))
            array.set(ssLoB, i, label.new(bar_index + 3, low,  nm + " L", style=label.style_none, textcolor=color.new(col, 12), size=size.small))
        else if ins
            nh = math.max(array.get(ssHi, i), high)
            nl = math.min(array.get(ssLo, i), low)
            array.set(ssHi, i, nh)
            array.set(ssLo, i, nl)
            hl = array.get(ssHiL, i)
            if not na(hl)
                line.set_y1(hl, nh)
                line.set_y2(hl, nh)
                ll = array.get(ssLoL, i)
                line.set_y1(ll, nl)
                line.set_y2(ll, nl)
                label.set_y(array.get(ssHiB, i), nh)
                label.set_y(array.get(ssLoB, i), nl)
        hb = array.get(ssHiB, i)
        if not na(hb)
            label.set_x(hb, bar_index + 3)
            label.set_x(array.get(ssLoB, i), bar_index + 3)

// Premium / Equilibrium / Discount (aktuell dealing range, persistenta objekt)
var box   pr_box = na
var box   di_box = na
var line  eq_ln  = na
var label lb_pr  = na
var label lb_di  = na
var label lb_eq  = na
var label lb_hi  = na
var label lb_lo  = na
if showEQ and barstate.islast and not na(swHigh) and not na(swLow)
    line.delete(eq_ln)
    box.delete(pr_box)
    box.delete(di_box)
    label.delete(lb_pr)
    label.delete(lb_di)
    label.delete(lb_eq)
    label.delete(lb_hi)
    label.delete(lb_lo)
    eqMid = (swHigh + swLow) / 2
    lhb   = na(swHighBar) ? bar_index - 50 : swHighBar
    llb   = na(swLowBar)  ? bar_index - 50 : swLowBar
    leftB = math.min(lhb, llb)
    rightB = bar_index + 18
    pr_box := box.new(leftB, swHigh, rightB, eqMid, border_color=color.new(#a8413d, 75), bgcolor=color.new(#a8413d, 93), border_width=1)
    di_box := box.new(leftB, eqMid, rightB, swLow,  border_color=color.new(#2f7d5b, 75), bgcolor=color.new(#2f7d5b, 93), border_width=1)
    eq_ln  := line.new(leftB, eqMid, rightB, eqMid, color=color.new(#c7a45a, 35), width=1, style=line.style_dotted)
    lb_pr  := label.new(rightB, eqMid + (swHigh - eqMid) * 0.5, "Premium",     style=label.style_none, textcolor=color.new(#c97b78, 0), size=size.small)
    lb_di  := label.new(rightB, swLow + (eqMid - swLow) * 0.5,  "Discount",    style=label.style_none, textcolor=color.new(#6bb094, 0), size=size.small)
    lb_eq  := label.new(rightB, eqMid, "Equilibrium",                          style=label.style_none, textcolor=color.new(#c7a45a, 0), size=size.small)
    hiTxt = (structDir == -1 ? "Strong High" : "Weak High") + "  -  BSL (buy-side liq)"
    loTxt = (structDir == 1  ? "Strong Low"  : "Weak Low")  + "  -  SSL (sell-side liq)"
    lb_hi  := label.new(rightB, swHigh, hiTxt, style=label.style_none, textcolor=color.new(#9fb0c3, 0), size=size.small)
    lb_lo  := label.new(rightB, swLow,  loTxt, style=label.style_none, textcolor=color.new(#9fb0c3, 0), size=size.small)

// ---- "Senast sedda" trackers (for dashboard) ----
var int dispDir = 0
var int dispBar = na
if dispUp
    dispDir := 1
    dispBar := bar_index
else if dispDn
    dispDir := -1
    dispBar := bar_index

var int obDir = 0
var int obBar = na
if obBullValid
    obDir := 1
    obBar := bar_index
else if obBearValid
    obDir := -1
    obBar := bar_index

var int swpDir = 0
var int swpBar = na
if swpLow
    swpDir := 1
    swpBar := bar_index
else if swpHigh
    swpDir := -1
    swpBar := bar_index

// ============ ZONER: Order blocks + iFVG (inversion), slacks vid mitigering ============
var array<box>   zBox = array.new<box>()
var array<float> zTop = array.new<float>()
var array<float> zBot = array.new<float>()
var array<int>   zTy  = array.new<int>()   // 1 = stod (bull), -1 = motstand (bear)
var array<bool>  zOn  = array.new<bool>()
var array<int>   zBar = array.new<int>()

// Vantande FVG (ritas EJ - bara nar de inverteras till iFVG)
var array<float> pTop = array.new<float>()
var array<float> pBot = array.new<float>()
var array<int>   pDir = array.new<int>()
var array<int>   pBar = array.new<int>()

if barstate.isconfirmed
    // Registrera nya FVG (vantande, ej ritade)
    if showIFVG
        if fvgUp
            array.push(pTop, low)
            array.push(pBot, high[2])
            array.push(pDir, 1)
            array.push(pBar, bar_index - 1)
        if fvgDn
            array.push(pTop, low[2])
            array.push(pBot, high)
            array.push(pDir, -1)
            array.push(pBar, bar_index - 1)
        if array.size(pDir) > 30
            array.shift(pTop)
            array.shift(pBot)
            array.shift(pDir)
            array.shift(pBar)

    // OB-zon vid volymbekraftad displacement
    if showOB and dispUp and obBullValid
        bx = box.new(bar_index - 2, high[2], bar_index + 3, low[2], border_color=color.new(#42a5f5, 30), bgcolor=color.new(#42a5f5, 90), border_width=1, text="OB+ " + timeframe.period, text_color=color.new(#42a5f5, 0), text_size=size.tiny, text_halign=text.align_right)
        array.push(zBox, bx)
        array.push(zTop, high[2])
        array.push(zBot, low[2])
        array.push(zTy, 1)
        array.push(zOn, true)
        array.push(zBar, bar_index)
    if showOB and dispDn and obBearValid
        bx = box.new(bar_index - 2, high[2], bar_index + 3, low[2], border_color=color.new(#ef5350, 30), bgcolor=color.new(#ef5350, 90), border_width=1, text="OB- " + timeframe.period, text_color=color.new(#ef5350, 0), text_size=size.tiny, text_halign=text.align_right)
        array.push(zBox, bx)
        array.push(zTop, high[2])
        array.push(zBot, low[2])
        array.push(zTy, -1)
        array.push(zOn, true)
        array.push(zBar, bar_index)

    // Inversion av vantande FVG -> iFVG-zon (bara storre an filtret)
    if showIFVG and array.size(pDir) > 0
        for i = array.size(pDir) - 1 to 0
            d  = array.get(pDir, i)
            tp = array.get(pTop, i)
            bt = array.get(pBot, i)
            br = array.get(pBar, i)
            inv = d == 1 ? close < bt : close > tp
            if inv
                if tp - bt >= ifvgMinATR * atr
                    ty  = d == 1 ? -1 : 1
                    col = ty == 1 ? #26a69a : #ef5350
                    bx  = box.new(br, tp, bar_index + 3, bt, border_color=color.new(col, 25), bgcolor=color.new(col, 85), border_width=1, text=(ty == 1 ? "iFVG+ " : "iFVG- ") + timeframe.period, text_color=color.new(col, 0), text_size=size.tiny, text_halign=text.align_left)
                    array.push(zBox, bx)
                    array.push(zTop, tp)
                    array.push(zBot, bt)
                    array.push(zTy, ty)
                    array.push(zOn, true)
                    array.push(zBar, bar_index)
                array.remove(pTop, i)
                array.remove(pBot, i)
                array.remove(pDir, i)
                array.remove(pBar, i)

// Uppdatera aktiva zoner: extendera tills mitigering, frys sedan
// + arma vantande setup vid tap (bekraftas i signalmotorn)
int    sigFire = 0
float  sigZT   = na
float  sigZB   = na
string sigCls  = ""
bool   aTap    = false
var int   pendDir = 0
var float pendTop = na
var float pendBot = na
var int   pendBar = na
if (showOB or showIFVG) and array.size(zBox) > 0
    for i = array.size(zBox) - 1 to 0
        if array.get(zOn, i) and bar_index > array.get(zBar, i)
            b   = array.get(zBox, i)
            ty  = array.get(zTy, i)
            top = array.get(zTop, i)
            bot = array.get(zBot, i)
            mit = ty == 1 ? low <= top : high >= bot
            if mit
                box.set_right(b, bar_index)
                box.set_bgcolor(b, color.new(ty == 1 ? #26a69a : #ef5350, 94))
                box.set_border_color(b, color.new(ty == 1 ? #26a69a : #ef5350, 65))
                array.set(zOn, i, false)
                aTap := true
                // Arma en vantande setup nar en zon tappas (bekraftas senare i motorn)
                if enableSig
                    pendDir := ty
                    pendTop := top
                    pendBot := bot
                    pendBar := bar_index
            else
                box.set_right(b, bar_index + 3)
                // Relevans: zon i spel (nara priset) = tydlig, langt bort = nedtonad
                zc   = ty == 1 ? #26a69a : #ef5350
                dist = close > top ? close - top : close < bot ? bot - close : 0.0
                near = dist <= relevATR * atr
                box.set_bgcolor(b, color.new(zc, near ? 84 : 93))
                box.set_border_color(b, color.new(zc, near ? 25 : 70))
    if array.size(zBox) > 14
        box.delete(array.shift(zBox))
        array.shift(zTop)
        array.shift(zBot)
        array.shift(zTy)
        array.shift(zOn)
        array.shift(zBar)

// ============ LEVEL 2: MTF Equilibrium (1h/4h) + POC ============
f_mid(len) =>
    hi = ta.highest(high, len)
    lo = ta.lowest(low, len)
    (hi + lo) / 2
eq1h = request.security(syminfo.tickerid, "60",  f_mid(eqLook))
eq4h = request.security(syminfo.tickerid, "240", f_mid(eqLook))

var line  ln_eq1 = na
var line  ln_eq4 = na
var label lb_eq1 = na
var label lb_eq4 = na
if showMtfEq and barstate.islast
    line.delete(ln_eq1)
    line.delete(ln_eq4)
    label.delete(lb_eq1)
    label.delete(lb_eq4)
    sB = math.max(0, bar_index - 250)
    ln_eq1 := line.new(sB, eq1h, bar_index + 5, eq1h, color=color.new(#7e9cc4, 45), width=1, style=line.style_dashed, extend=extend.right)
    ln_eq4 := line.new(sB, eq4h, bar_index + 5, eq4h, color=color.new(#7e9cc4, 20), width=1, style=line.style_dashed, extend=extend.right)
    lb_eq1 := label.new(bar_index + 3, eq1h, "EQ (1h)", style=label.style_none, textcolor=color.new(#9ab0d0, 0), size=size.small)
    lb_eq4 := label.new(bar_index + 3, eq4h, "EQ (4h)", style=label.style_none, textcolor=color.new(#9ab0d0, 0), size=size.small)

// POC (Point of Control) - mest handlade priset over fonstret
var line  ln_poc = na
var label lb_poc = na
var float pocVal = na
if showPOC and barstate.islast
    hh = ta.highest(high, pocLen)
    ll = ta.lowest(low,  pocLen)
    bs = (hh - ll) / pocBins
    if bs > 0
        vbin = array.new<float>(pocBins, 0.0)
        for i = 0 to pocLen - 1
            pr = (high[i] + low[i] + close[i]) / 3
            bi = int(math.min(pocBins - 1, math.max(0, math.floor((pr - ll) / bs))))
            array.set(vbin, bi, array.get(vbin, bi) + volume[i])
        maxv = 0.0
        maxi = 0
        for i = 0 to pocBins - 1
            v = array.get(vbin, i)
            if v > maxv
                maxv := v
                maxi := i
        pocP = ll + (maxi + 0.5) * bs
        pocVal := pocP
        line.delete(ln_poc)
        label.delete(lb_poc)
        ln_poc := line.new(bar_index - pocLen, pocP, bar_index + 5, pocP, color=color.new(#d65f5f, 0), width=1, extend=extend.right)
        lb_poc := label.new(bar_index + 3, pocP, "POC", style=label.style_none, textcolor=color.new(#e08585, 0), size=size.small)

// ============ BOS / CHoCH (snyggare, linje fran swing till brott) ============
f_struct(sBar, lvl, txt, col) =>
    line.new(sBar, lvl, bar_index, lvl, color=color.new(col, 40), width=1, style=line.style_dashed)
    label.new(math.round((sBar + bar_index) / 2), lvl, txt, style=label.style_none, textcolor=col, size=size.small)

bosReady = barstate.isconfirmed
if showBOS and bosReady and bosU and not chU and not na(swHighBar)
    f_struct(swHighBar, swHigh, "BOS", #4aa583)
if showBOS and bosReady and bosD and not chD and not na(swLowBar)
    f_struct(swLowBar, swLow, "BOS", #c98b6b)
if showBOS and bosReady and chU and not na(swHighBar)
    f_struct(swHighBar, swHigh, "CHoCH", #c7a45a)
if showBOS and bosReady and chD and not na(swLowBar)
    f_struct(swLowBar, swLow, "CHoCH", #c7a45a)

// ================================================================ MOMENTUM-SIGNALER (primar)
// Pil upp nar momentum vander upp i uppattrend, pil ner i nedattrend. Decoupled - ritas alltid.
mtfN    = (tf5b ? 1 : 0) + (tf15b ? 1 : 0) + (tf60b ? 1 : 0) + (tf240b ? 1 : 0) + (tf1db ? 1 : 0)
inSess  = not useSession or not na(time(timeframe.period, sessTime))
trendUpL = momTrendType == "EMA50" ? close > e50 : momTrendType == "Supertrend" ? stBull : momTrendType == "MTF" ? mtfN >= 3 : true
trendDnS = momTrendType == "EMA50" ? close < e50 : momTrendType == "Supertrend" ? stBear : momTrendType == "MTF" ? mtfN <= 2 : true
xStochUp = ta.crossover(kLine, dLine)
xStochDn = ta.crossunder(kLine, dLine)
xRsiUp   = ta.crossover(rsi, momRsiBuy)
xRsiDn   = ta.crossunder(rsi, momRsiSell)
xMacdUp  = ta.crossover(histLine, 0)
xMacdDn  = ta.crossunder(histLine, 0)
xEmaUp   = ta.crossover(close, ef)
xEmaDn   = ta.crossunder(close, ef)
buyTrig  = xStochUp or xRsiUp or xMacdUp or xEmaUp
sellTrig = xStochDn or xRsiDn or xMacdDn or xEmaDn
loSw = ta.lowest(low, momSlLook)
hiSw = ta.highest(high, momSlLook)
var int lastMomBar = na
momCoolOk = na(lastMomBar) or bar_index - lastMomBar >= momCool
longSig  = enableMom and barstate.isconfirmed and trendUpL and buyTrig and momCoolOk and bar_index >= minHist and inSess
shortSig = enableMom and barstate.isconfirmed and trendDnS and sellTrig and momCoolOk and bar_index >= minHist and inSess and not longSig
if longSig or shortSig
    lastMomBar := bar_index

// Exit-markorer: nar en kop/salj-signal bedoms vara over (momentum vander emot)
trendFlipDn = momTrendType == "EMA50" ? ta.crossunder(close, e50) : momTrendType == "Supertrend" ? (stBear and not stBear[1]) : momTrendType == "MTF" ? (mtfN <= 2 and mtfN[1] > 2) : false
trendFlipUp = momTrendType == "EMA50" ? ta.crossover(close, e50)  : momTrendType == "Supertrend" ? (stBull and not stBull[1]) : momTrendType == "MTF" ? (mtfN >= 3 and mtfN[1] < 3) : false
longEndTrig  = xMacdDn or xEmaDn or trendFlipDn
shortEndTrig = xMacdUp or xEmaUp or trendFlipUp
var int momState = 0
bool longExitSig = false
bool shortExitSig = false
if barstate.isconfirmed
    if longSig
        momState := 1
    else if shortSig
        momState := -1
    else if momState == 1 and longEndTrig
        longExitSig := true
        momState := 0
    else if momState == -1 and shortEndTrig
        shortExitSig := true
        momState := 0

plotshape(longSig,  title="Kop",  style=shape.triangleup,   location=location.belowbar, color=color.new(#2f7d5b, 0), size=size.small)
plotshape(shortSig, title="Salj", style=shape.triangledown, location=location.abovebar, color=color.new(#a8413d, 0), size=size.small)
plotshape(enableMomExit and longExitSig,  title="Exit lang", style=shape.xcross, location=location.abovebar, color=color.new(#8a929e, 0), size=size.tiny)
plotshape(enableMomExit and shortExitSig, title="Exit kort", style=shape.xcross, location=location.belowbar, color=color.new(#8a929e, 0), size=size.tiny)
alertcondition(longSig,  title="KOP (momentum)",  message="KOP {{ticker}} @ {{close}}")
alertcondition(shortSig, title="SALJ (momentum)", message="SALJ {{ticker}} @ {{close}}")
alertcondition(longExitSig or shortExitSig, title="EXIT (momentum)", message="EXIT {{ticker}} @ {{close}}")

// ================================================================ SIGNAL ENGINE
// Entry = bekraftad zon-tap (close). DCA2 = zon-mitt. SL = bortom zonen.
// TP1-3 = narmaste likviditet/nivaer (swing, EQ, POC, PDH/PWH/PMH), R som reserv.
var int    tDir    = 0
var int    tBar    = na
var float  tEntry  = na
var float  tSL     = na
var float  tT3     = na
var bool   tp1Hit  = false
var bool   beAct   = false
var string sigClass = ""
var float  dEntry = na
var float  dSL    = na
var float  dT1    = na
var float  dT2    = na
var float  dT3    = na
var float  dDCA   = na

var line lnE = na
var line lnSL = na
var line lnT1 = na
var line lnT2 = na
var line lnT3 = na
var line lnD = na
var label lbE = na
var label lbSL = na
var label lbT1 = na
var label lbT2 = na
var label lbT3 = na
var label lbD = na

var int lastSigBar = na

// Tracker (partiell 1/3-modell, BE efter TP1, pessimistisk vid tie)
var int    tkDir   = 0
var int    tkStart = na
var int    tkLeash = na
var string tkCls   = ""
var float  tkEntry = na
var float  tkSL    = na
var float  tkRisk  = na
var float  tkT1    = na
var float  tkT2    = na
var float  tkT3    = na
var bool   kT1     = false
var bool   kT2     = false
var bool   kT3     = false
var float  tkBook  = 0.0
// Ackumulatorer per klass: 5M
var int    nTr5    = 0
var int    nWin5   = 0
var float  sumR5   = 0.0
var float  sumWin5 = 0.0
var float  sumLoss5 = 0.0
// Ackumulatorer per klass: 1H
var int    nTr1    = 0
var int    nWin1   = 0
var float  sumR1   = 0.0
var float  sumWin1 = 0.0
var float  sumLoss1 = 0.0

// En aktiv signal i taget pa chart: hanterade entry/exit-markorer
var label mkEntry = na
var label mkExit  = na

cdOk = na(lastSigBar) or (bar_index - lastSigBar) >= sigCool

// Utvardera vantande zon-setup: avfyra nar en bekraftande stangning kommer inom fonstret
if enableSig and pendDir != 0 and barstate.isconfirmed and tDir == 0
    if bar_index - pendBar > confirmWin
        pendDir := 0
    else if pendDir == 1
        swingL = htfBull
        locOk  = not reqLoc or not swingL or inDiscount
        strOk  = not reqStruct or structDir == 1
        clsEn  = swingL ? enable1H : enable5M
        eVol   = not reqEntryVol or volume > vma * 1.1 or dispUp
        mid    = (pendTop + pendBot) / 2
        if strOk and locOk and clsEn and eVol and close > open and close >= mid
            sigFire := 1
            sigZT := pendTop
            sigZB := pendBot
            sigCls := swingL ? "1H" : "5M"
            pendDir := 0
    else
        swingS = htfBear
        locOk  = not reqLoc or not swingS or inPremium
        strOk  = not reqStruct or structDir == -1
        clsEn  = swingS ? enable1H : enable5M
        eVol   = not reqEntryVol or volume > vma * 1.1 or dispDn
        mid    = (pendTop + pendBot) / 2
        if strOk and locOk and clsEn and eVol and close < open and close <= mid
            sigFire := -1
            sigZT := pendTop
            sigZB := pendBot
            sigCls := swingS ? "1H" : "5M"
            pendDir := 0

// Utvardera sweep-setup: BSL/SSL svept + CHoCH i vandriktningen (om ingen zon-signal redan)
if enableSig and enableSweep and sigFire == 0 and pendSwpDir != 0 and barstate.isconfirmed and tDir == 0
    if bar_index - pendSwpBar > confirmWin
        pendSwpDir := 0
    else if pendSwpDir == 1
        swingL = htfBull
        clsEn  = swingL ? enable1H : enable5M
        eVol   = not reqEntryVol or volume > vma * 1.1 or dispUp
        if chU and clsEn and eVol and close > open
            sigFire := 1
            sigZB := math.min(low, pendSwpLvl)
            sigZT := close
            sigCls := swingL ? "1H" : "5M"
            pendSwpDir := 0
    else
        swingS = htfBear
        clsEn  = swingS ? enable1H : enable5M
        eVol   = not reqEntryVol or volume > vma * 1.1 or dispDn
        if chD and clsEn and eVol and close < open
            sigFire := -1
            sigZT := math.max(high, pendSwpLvl)
            sigZB := close
            sigCls := swingS ? "1H" : "5M"
            pendSwpDir := 0

// Momentum-signal driver trade-motorn (entry/SL/TP/statistik) nar vi ar flat
if enableMom and sigFire == 0 and tDir == 0
    if longSig
        sigFire := 1
        sigZB := loSw
        sigZT := close
        sigCls := htfBull ? "1H" : "5M"
    else if shortSig
        sigFire := -1
        sigZT := hiSw
        sigZB := close
        sigCls := htfBear ? "1H" : "5M"

fire = sigFire != 0 and cdOk and tDir == 0 and bar_index >= minHist and inSess
bool aExit = false

if fire
    entry = close
    zhi   = sigZT
    zlo   = sigZB
    dca   = (zhi + zlo) / 2
    sl    = sigFire == 1 ? zlo - atr * slBufAtr : zhi + atr * slBufAtr
    risk  = math.max(math.abs(entry - sl), atr * 0.2)
    buf   = atr * 0.15

    // Kandidatnivaer (likviditet + nyckelnivaer)
    cand = array.new<float>()
    if not na(swHigh)
        array.push(cand, swHigh)
    if not na(prevSwHigh)
        array.push(cand, prevSwHigh)
    if not na(swLow)
        array.push(cand, swLow)
    if not na(prevSwLow)
        array.push(cand, prevSwLow)
    if not na(eq1h)
        array.push(cand, eq1h)
    if not na(eq4h)
        array.push(cand, eq4h)
    if not na(pocVal)
        array.push(cand, pocVal)
    if not na(pdH)
        array.push(cand, pdH)
    if not na(pdL)
        array.push(cand, pdL)
    if not na(pwH)
        array.push(cand, pwH)
    if not na(pwL)
        array.push(cand, pwL)
    if not na(pmH)
        array.push(cand, pmH)
    if not na(pmL)
        array.push(cand, pmL)
    // BSL/SSL likviditetspooler som TP-magneter (aktiva, ej svepta)
    if showLiq and array.size(liqLvl) > 0
        for li = 0 to array.size(liqLvl) - 1
            if array.get(liqOn, li)
                array.push(cand, array.get(liqLvl, li))
    array.sort(cand, order.ascending)

    float t1 = na
    float t2 = na
    float t3 = na
    if array.size(cand) > 0
        if sigFire == 1
            cnt = 0
            for i = 0 to array.size(cand) - 1
                v = array.get(cand, i)
                if v > entry + buf
                    cnt += 1
                    if cnt == 1
                        t1 := v
                    if cnt == 2
                        t2 := v
                    if cnt == 3
                        t3 := v
                        break
        else
            cnt = 0
            for i = array.size(cand) - 1 to 0
                v = array.get(cand, i)
                if v < entry - buf
                    cnt += 1
                    if cnt == 1
                        t1 := v
                    if cnt == 2
                        t2 := v
                    if cnt == 3
                        t3 := v
                        break
    // Reserv: R-multiplar dar nivaer saknas (alltid i ordning)
    sgn = sigFire == 1 ? 1.0 : -1.0
    t1 := na(t1) ? entry + sgn * risk : t1
    t2 := na(t2) ? t1 + sgn * risk : t2
    t3 := na(t3) ? t2 + sgn * risk : t3

    // Spara + rita
    leash = sigCls == "5M" ? math.max(10, math.round(sigMaxBars * 0.4)) : sigMaxBars
    lastSigBar := bar_index
    tDir   := sigFire
    tBar   := bar_index
    tEntry := entry
    tSL    := sl
    tT3    := t3
    tp1Hit := false
    beAct  := false
    sigClass := sigCls
    dEntry := entry
    dSL := sl
    dT1 := t1
    dT2 := t2
    dT3 := t3
    dDCA := dca

    rB = bar_index + 8
    lnE  := line.new(bar_index, entry, rB, entry, color=color.new(#9aa3b2, 40), width=1, style=line.style_dotted)
    lnSL := line.new(bar_index, sl,    rB, sl,    color=color.new(#a8413d, 25), width=1, style=line.style_dashed)
    lnT1 := line.new(bar_index, t1,    rB, t1,    color=color.new(#2f7d5b, 25), width=1, style=line.style_dashed)
    lnT2 := line.new(bar_index, t2,    rB, t2,    color=color.new(#2f7d5b, 25), width=1, style=line.style_dashed)
    lnT3 := line.new(bar_index, t3,    rB, t3,    color=color.new(#2f7d5b, 25), width=1, style=line.style_dashed)
    lnD  := line.new(bar_index, dca,   rB, dca,   color=color.new(#7a6326, 35), width=1, style=line.style_dotted)
    lbE  := label.new(rB, entry, "Entry " + f_lvl(entry), style=label.style_label_left, color=color.new(#0a0d12, 10), textcolor=color.new(#c4cbd4, 0), size=size.small)
    lbSL := label.new(rB, sl,    "SL "    + f_lvl(sl),    style=label.style_label_left, color=color.new(#0a0d12, 10), textcolor=color.new(#c97b78, 0), size=size.small)
    lbT1 := label.new(rB, t1,    "TP1 "   + f_lvl(t1),    style=label.style_label_left, color=color.new(#0a0d12, 10), textcolor=color.new(#6bb094, 0), size=size.small)
    lbT2 := label.new(rB, t2,    "TP2 "   + f_lvl(t2),    style=label.style_label_left, color=color.new(#0a0d12, 10), textcolor=color.new(#6bb094, 0), size=size.small)
    lbT3 := label.new(rB, t3,    "TP3 "   + f_lvl(t3),    style=label.style_label_left, color=color.new(#0a0d12, 10), textcolor=color.new(#6bb094, 0), size=size.small)
    lbD  := label.new(rB, dca,   "DCA2 "  + f_lvl(dca),   style=label.style_label_left, color=color.new(#0a0d12, 10), textcolor=color.new(#c7a45a, 0), size=size.small)

    // Pilen ritas av plotshape (momentum). Ingen extra entry-etikett behovs.
    if not keepSigHist
        label.delete(mkExit)
    mkExit := na
    mkEntry := na

    // Oppna tracker-trade (oberoende av ritningen)
    if tkDir == 0
        tkDir   := sigFire
        tkStart := bar_index
        tkLeash := leash
        tkCls   := sigCls
        tkEntry := entry
        tkSL    := sl
        tkRisk  := risk
        tkT1    := t1
        tkT2    := t2
        tkT3    := t3
        kT1     := false
        kT2     := false
        kT3     := false
        tkBook  := 0.0

else if tDir != 0
    // Break-even efter TP1
    if not tp1Hit and (tDir == 1 ? high >= line.get_y1(lnT1) : low <= line.get_y1(lnT1))
        tp1Hit := true
        beAct  := true
        tSL    := tEntry
        line.set_y1(lnSL, tEntry)
        line.set_y2(lnSL, tEntry)
        line.set_color(lnSL, color.new(#c7a45a, 25))
        label.set_text(lbSL, "BE " + f_lvl(tEntry))
        label.set_textcolor(lbSL, color.new(#c7a45a, 0))
        line.set_color(lnT1, color.new(#6bb094, 10))
    // Stang & radera linjer nar SL/TP3/timeout, motsatt struktur, eller smart exit
    hitStop  = tDir == 1 ? low <= tSL : high >= tSL
    hitFinal = tDir == 1 ? high >= tT3 : low <= tT3
    oppStruct = (tDir == 1 and chD) or (tDir == -1 and chU)
    expired  = bar_index - tBar > (sigClass == "5M" ? math.max(10, math.round(sigMaxBars * 0.4)) : sigMaxBars)
    // Smart exit: farten gar ur (MACD vander emot + motsatt impuls + volym-tapp i vinst)
    inProfit = tDir == 1 ? close > tEntry : close < tEntry
    momoRoll = tDir == 1 ? (histLine < 0 and histLine[1] >= 0) : (histLine > 0 and histLine[1] <= 0)
    oppImp   = tDir == 1 ? dispDn : dispUp
    volFade  = volume < vma and volume[1] < vma and inProfit and (tDir == 1 ? close < open : close > open)
    smartExit = useSmartExit and (momoRoll or oppImp or volFade)
    oppSig   = momFlip and ((tDir == 1 and shortSig) or (tDir == -1 and longSig))
    closeNow = hitStop or hitFinal or expired or oppStruct or smartExit or oppSig
    if closeNow
        reason = hitStop ? (beAct ? "BE" : "SL") : hitFinal ? "TP3" : oppStruct ? "CHoCH" : oppSig ? "vand" : smartExit ? (oppImp ? "impuls" : volFade ? "volym" : "momentum") : "timeout"
        line.delete(lnE), line.delete(lnSL), line.delete(lnT1), line.delete(lnT2), line.delete(lnT3), line.delete(lnD)
        label.delete(lbE), label.delete(lbSL), label.delete(lbT1), label.delete(lbT2), label.delete(lbT3), label.delete(lbD)
        // EXIT-markor (ersatter ev. tidigare exit-markor om vi inte sparar historik)
        if not keepSigHist
            label.delete(mkExit)
        mkExit := label.new(bar_index, tDir == 1 ? high + atr * 0.5 : low - atr * 0.5, "EXIT (" + reason + ")", style=tDir == 1 ? label.style_label_down : label.style_label_up, color=color.new(#5a6470, 0), textcolor=color.white, size=size.small)
        aExit := true
        tDir := 0
    else
        rext = bar_index + 8
        line.set_x2(lnE, rext), line.set_x2(lnSL, rext), line.set_x2(lnT1, rext), line.set_x2(lnT2, rext), line.set_x2(lnT3, rext), line.set_x2(lnD, rext)
        label.set_x(lbE, rext), label.set_x(lbSL, rext), label.set_x(lbT1, rext), label.set_x(lbT2, rext), label.set_x(lbT3, rext), label.set_x(lbD, rext)

alertcondition(fire and sigFire == 1, title="BUY",  message="BUY {{ticker}} @ {{close}}")
alertcondition(fire and sigFire == -1, title="SELL", message="SELL {{ticker}} @ {{close}}")
alertcondition(aExit, title="EXIT", message="EXIT {{ticker}} @ {{close}}")
alertcondition(aTap, title="Zon-tap", message="Zon tappad {{ticker}} @ {{close}}")
alertcondition(aSweep, title="Liquidity sweep", message="BSL/SSL svept {{ticker}} @ {{close}}")

// ================================================================ TRACKER (R / expectancy / PF)
// Partiell modell: 1/3 av positionen bokas vid TP1, TP2, TP3. SL flyttas till BE efter TP1.
// R per TP raknas fran faktiska nivapriser (inte fast R). Pessimistisk: SL kollas fore TP.
if tkDir != 0 and bar_index > tkStart
    third = 1.0 / 3.0
    openThirds = 3 - ((kT1 ? 1 : 0) + (kT2 ? 1 : 0) + (kT3 ? 1 : 0))
    curStop = kT1 ? tkEntry : tkSL
    timedOut = bar_index - tkStart >= tkLeash
    // Samma smart exit som ritningen
    inProf = tkDir == 1 ? close > tkEntry : close < tkEntry
    mRoll  = tkDir == 1 ? (histLine < 0 and histLine[1] >= 0) : (histLine > 0 and histLine[1] <= 0)
    oImp   = tkDir == 1 ? dispDn : dispUp
    vFade  = volume < vma and volume[1] < vma and inProf and (tkDir == 1 ? close < open : close > open)
    soft   = timedOut or (useSmartExit and (mRoll or oImp or vFade))
    closed = false
    if tkDir == 1
        if low <= curStop
            tkBook := tkBook + openThirds * third * (kT1 ? 0.0 : -1.0)
            closed := true
        if not closed
            if not kT1 and high >= tkT1
                kT1 := true
                tkBook := tkBook + third * ((tkT1 - tkEntry) / tkRisk)
            if not kT2 and high >= tkT2
                kT2 := true
                tkBook := tkBook + third * ((tkT2 - tkEntry) / tkRisk)
            if not kT3 and high >= tkT3
                kT3 := true
                tkBook := tkBook + third * ((tkT3 - tkEntry) / tkRisk)
                closed := true
        if not closed and soft
            tkBook := tkBook + (3 - ((kT1 ? 1 : 0) + (kT2 ? 1 : 0) + (kT3 ? 1 : 0))) * third * ((close - tkEntry) / tkRisk)
            closed := true
    else
        if high >= curStop
            tkBook := tkBook + openThirds * third * (kT1 ? 0.0 : -1.0)
            closed := true
        if not closed
            if not kT1 and low <= tkT1
                kT1 := true
                tkBook := tkBook + third * ((tkEntry - tkT1) / tkRisk)
            if not kT2 and low <= tkT2
                kT2 := true
                tkBook := tkBook + third * ((tkEntry - tkT2) / tkRisk)
            if not kT3 and low <= tkT3
                kT3 := true
                tkBook := tkBook + third * ((tkEntry - tkT3) / tkRisk)
                closed := true
        if not closed and soft
            tkBook := tkBook + (3 - ((kT1 ? 1 : 0) + (kT2 ? 1 : 0) + (kT3 ? 1 : 0))) * third * ((tkEntry - close) / tkRisk)
            closed := true
    if closed
        win = tkBook > 0
        if tkCls == "5M"
            nTr5 := nTr5 + 1
            sumR5 := sumR5 + tkBook
            if win
                nWin5 := nWin5 + 1
                sumWin5 := sumWin5 + tkBook
            else
                sumLoss5 := sumLoss5 + (-tkBook)
        else
            nTr1 := nTr1 + 1
            sumR1 := sumR1 + tkBook
            if win
                nWin1 := nWin1 + 1
                sumWin1 := sumWin1 + tkBook
            else
                sumLoss1 := sumLoss1 + (-tkBook)
        tkDir := 0

// ================================================================ DASHBOARD
// Palett (institutionell, daempad)
var color cBg   = color.new(#0a0d12, 0)    // panel
var color cBg2  = color.new(#10151c, 0)    // alt rad
var color cTxt  = color.new(#d6dde6, 0)    // ljus text
var color cDim  = color.new(#737d8a, 0)    // dampad text
var color cUp   = color.new(#2f7d5b, 0)    // dampad gron
var color cDn   = color.new(#a8413d, 0)    // dampad rod
var color cNu   = color.new(#1a212c, 0)    // neutral
var color cLine = color.new(#222a35, 0)    // separator/ram
var color cAcc  = color.new(#3a4757, 0)    // header

f_pos(s) =>
    s == "Top Center" ? position.top_center : s == "Top Left" ? position.top_left : s == "Middle Right" ? position.middle_right : s == "Middle Center" ? position.middle_center : s == "Middle Left" ? position.middle_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Center" ? position.bottom_center : s == "Bottom Left" ? position.bottom_left : position.top_right

f_sz(s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small

var string tblTxt = size.small

f_hdr(t, r, txt, tip) =>
    table.cell(t, 0, r, txt, text_color=color.new(#9fb0c3, 0), text_size=tblTxt, bgcolor=color.new(#161d27, 0), text_halign=text.align_left, tooltip=tip)
    table.cell(t, 1, r, "",  text_color=color.new(#9fb0c3, 0), text_size=tblTxt, bgcolor=color.new(#161d27, 0))
    table.merge_cells(t, 0, r, 1, r)

f_item(t, r, k, v, bg, tip) =>
    table.cell(t, 0, r, k, text_color=color.new(#737d8a, 0), text_size=tblTxt, bgcolor=color.new(#0a0d12, 0), text_halign=text.align_left, tooltip=tip)
    table.cell(t, 1, r, v, text_color=color.new(#e6ebf1, 0), text_size=tblTxt, bgcolor=bg, text_halign=text.align_right)

var table dash = na
var string dashSig = ""
if showDash and barstate.islast
    tblTxt := f_sz(dashSz)
    calcN = showCalc ? 13 : 0
    dSig = dashPos + "|" + dashSz + "|" + str.tostring(26 + calcN)
    if na(dash) or dashSig != dSig
        if not na(dash)
            table.delete(dash)
        dash := table.new(f_pos(dashPos), 2, 26 + calcN, bgcolor=cBg, border_width=1, border_color=cLine, frame_width=1, frame_color=cLine)
        dashSig := dSig

    sScore = ((tf5b?1:-1)*tf5pct + (tf15b?1:-1)*tf15pct + (tf60b?1:-1)*tf60pct + (tf240b?1:-1)*tf240pct + (tf1db?1:-1)*tf1dpct) / 5
    overBull = sScore >= 0
    overStr  = math.round(math.abs(sScore))
    nBull    = (tf5b?1:0)+(tf15b?1:0)+(tf60b?1:0)+(tf240b?1:0)+(tf1db?1:0)

    table.cell(dash, 0, 0, "Investment Circle Pro ICT", text_color=color.white, text_size=tblTxt, bgcolor=color.new(#0a0d12, 0), text_halign=text.align_left, tooltip="SMC-struktur, nivaer och makro. Signal + statistik finns i den separata panelen (slas pa under Visuals).")
    table.cell(dash, 1, 0, htf + "  " + cdTxt, text_color=color.new(#c7a45a, 0), text_size=tblTxt, bgcolor=color.new(#0a0d12, 0), text_halign=text.align_right, tooltip="Hogre timeframe + tid kvar pa aktuell bar.")

    f_hdr(dash, 1, "TREND SUMMARY", "Snabb helhetsbild av trenden over alla timeframes.")
    f_item(dash, 2, "Overall trend", (overBull ? "Bullish" : "Bearish") + "  " + f_bar(overStr) + " " + str.tostring(overStr) + "%", overStr < 12 ? cNu : overBull ? cUp : cDn, "Sammanvagd riktning + styrka fran alla 5 timeframes.")
    f_item(dash, 3, "TF alignment", str.tostring(nBull) + "/5 bullish  " + f_bar(nBull / 5 * 100), nBull >= 4 ? cUp : nBull <= 1 ? cDn : cNu, "Hur manga av de 5 timeframsen som pekar uppat.")

    f_hdr(dash, 4, "MARKET STRUCTURE", "Var marknaden star strukturellt just nu.")
    f_item(dash, 5, "Higher-TF trend", bTxt(htfBull), bCol(htfBull), "Trenden pa hogre timeframe (" + htf + "m).")
    f_item(dash, 6, "Market structure", structDir == 1 ? "Bullish" : structDir == -1 ? "Bearish" : "-", structDir == 1 ? cUp : structDir == -1 ? cDn : cNu, "Strukturen fran svangningar. Bullish = hogre toppar/bottnar.")
    swNow = sweepLongOk or sweepShortOk
    f_item(dash, 7, "Liquidity sweep", f_de(swpDir, swpBar), swNow ? (swpDir == 1 ? cUp : cDn) : cNu, "Stop hunt: pris tog ut topp/botten och vande. 'now' = senaste baren.")
    dispNow = dispUp or dispDn
    f_item(dash, 8, "Impulse (FVG)", f_de(dispDir, dispBar), dispNow ? (dispDir == 1 ? cUp : cDn) : cNu, "Volymdriven impuls som lamnar ett gap.")
    obNow = obBullValid or obBearValid
    f_item(dash, 9, "Order block", f_de(obDir, obBar), obNow ? (obDir == 1 ? cUp : cDn) : cNu, "Sista motsatta candeln fore impulsen.")
    f_item(dash, 10, "Price location", inDiscount ? "Discount (cheap)" : "Premium (expensive)", inDiscount ? cUp : cDn, "Discount = billigt (koplage), Premium = dyrt (saljlage).")

    f_hdr(dash, 11, "KEY LEVELS", "Viktiga referensnivaer fran hogre timeframes och volym.")
    f_item(dash, 12, "EQ (1h)", f_lvl(eq1h), close > eq1h ? cUp : cDn, "1h equilibrium. Over = bullish bias, under = bearish.")
    f_item(dash, 13, "EQ (4h)", f_lvl(eq4h), close > eq4h ? cUp : cDn, "4h equilibrium.")
    f_item(dash, 14, "POC", na(pocVal) ? "-" : f_lvl(pocVal) + (close > pocVal ? "  (over)" : "  (under)"), na(pocVal) ? cNu : close > pocVal ? cUp : cDn, "Point of Control = mest handlade priset (rod linje).")

    f_hdr(dash, 15, "TREND PER TIMEFRAME", "Trendriktning och styrka (0-100%) pa olika timeframes.")
    f_item(dash, 16, "5 min",  mSig(tf5b)   + " " + f_bar(tf5pct)   + " " + str.tostring(tf5pct)   + "%", mColF(tf5b),  "5-min trend. Bull/Bear = riktning, stapel + % = styrka.")
    f_item(dash, 17, "15 min", mSig(tf15b)  + " " + f_bar(tf15pct)  + " " + str.tostring(tf15pct)  + "%", mColF(tf15b), "15-min trend och styrka.")
    f_item(dash, 18, "1 hour", mSig(tf60b)  + " " + f_bar(tf60pct)  + " " + str.tostring(tf60pct)  + "%", mColF(tf60b), "1-timmes trend och styrka.")
    f_item(dash, 19, "4 hour", mSig(tf240b) + " " + f_bar(tf240pct) + " " + str.tostring(tf240pct) + "%", mColF(tf240b),"4-timmes trend och styrka.")
    f_item(dash, 20, "1 day",  mSig(tf1db)  + " " + f_bar(tf1dpct)  + " " + str.tostring(tf1dpct)  + "%", mColF(tf1db), "Daglig trend och styrka.")

    f_hdr(dash, 21, "MACRO (" + macroAsset + ")", "Dollar och rantor ar de stora makrodrivarna. Valj tillgang i installningarna. Forenklad vy, inte en prognos.")
    dxyStr = (dxyChg >= 0 ? "+" : "") + str.tostring(dxyChg, "#.##") + "%"
    u10Str = (us10yChg >= 0 ? "+" : "") + str.tostring(us10yChg, "#.##") + "%"
    f_item(dash, 22, "Dollar (DXY)", (dxyUp ? "Up " : "Down ") + dxyStr, dxyUp ? cDn : cUp, "Dollarindex idag. Starkare dollar = oftast motvind for USD-prissatta tillgangar (ravaror).")
    f_item(dash, 23, "10Y yield", (us10yUp ? "Up " : "Down ") + u10Str, us10yUp ? cDn : cUp, "10-arsranta idag. Hogre ranta = oftast motvind, sarskilt for guld och rantekansliga index (Nasdaq).")
    goldTxt = macroBull ? "BULLISH" : macroBear ? "BEARISH" : "CHOPPY"
    goldBg  = macroBull ? cUp : macroBear ? cDn : color.new(#7a6326, 0)
    f_item(dash, 24, macroAsset + " outlook", goldTxt, goldBg, "Sammanvagd makrobild for " + macroAsset + " (fran dollar + rantor).")

    // Positionskalkylator (langst ner, valbar)
    if showCalc
        slP = slCalcPct
        tpP = tpCalcPct
        if calcAuto and tDir != 0 and not na(dEntry) and not na(dSL) and not na(dT3) and dEntry != 0
            slP := math.abs(dEntry - dSL) / dEntry * 100 * levCalc
            tpP := math.abs(dT3 - dEntry) / dEntry * 100 * levCalc
        totalKr  = tradeKr + (kop2On ? kop2Kr : 0)
        lossKr   = totalKr * slP / 100
        profitKr = totalKr * tpP / 100
        rrCalc   = slP != 0 ? tpP / slP : 0.0
        notional = totalKr * levCalc
        priceSL  = levCalc != 0 ? slP / levCalc : slP
        priceTP  = levCalc != 0 ? tpP / levCalc : tpP
        f_hdr(dash, 25, "POSITION CALC" + (calcAuto and tDir != 0 ? "  (auto)" : ""), "Spot-modell: SL/TP ar procent av tradesumman (din insats). Havstang visar hur lite priset behover rora sig. Slas av/pa under Positionskalkylator.")
        f_item(dash, 26, "Tradestorlek", str.tostring(math.round(tradeKr)) + " kr", cBg2, "Summan du satsar (insats).")
        f_item(dash, 27, "Kop 2", kop2On ? str.tostring(math.round(kop2Kr)) + " kr" : "av", kop2On ? cBg2 : cNu, "Pafyllning vid andra ingangen.")
        f_item(dash, 28, "Total insats", str.tostring(math.round(totalKr)) + " kr", cBg2, "Tradestorlek + Kop 2.")
        f_item(dash, 29, "Havstang", str.tostring(levCalc, "#.#") + "x", cBg2, "Din havstang.")
        f_item(dash, 30, "Exponering", str.tostring(math.round(notional)) + " kr", cBg2, "Faktisk marknadsexponering = total insats x havstang.")
        f_item(dash, 31, "SL %", str.tostring(slP, "#.##") + "%", cBg2, "Andel av insatsen du forlorar vid SL.")
        f_item(dash, 32, "Forlust vid SL", "-" + str.tostring(math.round(lossKr)) + " kr", color.new(#a8413d, 0), "Forlust i kronor om SL traffas (total insats x SL%).")
        f_item(dash, 33, "Prisrorelse SL", str.tostring(priceSL, "#.##") + "%", cBg2, "Hur langt priset behover ga emot dig for att na SL (SL% / havstang).")
        f_item(dash, 34, "TP %", str.tostring(tpP, "#.##") + "%", cBg2, "Vinstmal i procent av insatsen.")
        f_item(dash, 35, "Vinst vid TP", "+" + str.tostring(math.round(profitKr)) + " kr", color.new(#2f7d5b, 0), "Vinst i kronor om TP traffas (total insats x TP%).")
        f_item(dash, 36, "Prisrorelse TP", str.tostring(priceTP, "#.##") + "%", cBg2, "Hur langt priset behover ga for att na TP (TP% / havstang).")
        f_item(dash, 37, "RR", str.tostring(rrCalc, "#.##"), rrCalc >= 2 ? cUp : rrCalc >= 1 ? cNu : cDn, "Risk/reward = TP% delat med SL%.")

    fRow = 25 + calcN
    table.cell(dash, 0, fRow, "ICP v20", text_color=color.new(#3f4855, 0), text_size=size.tiny, bgcolor=color.new(#0a0d12, 0), text_halign=text.align_left)
    table.cell(dash, 1, fRow, "", text_color=color.new(#737d8a, 0), text_size=size.tiny, bgcolor=color.new(#0a0d12, 0), text_halign=text.align_right)

// ---------------------------------------------------------------- Separat panel: Signal + Performance
var table sigp = na
var string panSig = ""
if showSigPanel and barstate.islast
    tblTxt := f_sz(panSz)
    pSig = panPos + "|" + panSz
    if na(sigp) or panSig != pSig
        if not na(sigp)
            table.delete(sigp)
        sigp := table.new(f_pos(panPos), 2, 16, bgcolor=cBg, border_width=1, border_color=cLine, frame_width=1, frame_color=cLine)
        panSig := pSig
    inTrade = tDir != 0

    wr5  = nTr5 > 0 ? math.round(nWin5 / nTr5 * 100) : 0
    wr1  = nTr1 > 0 ? math.round(nWin1 / nTr1 * 100) : 0
    exp5 = nTr5 > 0 ? sumR5 / nTr5 : 0.0
    exp1 = nTr1 > 0 ? sumR1 / nTr1 : 0.0
    pf5  = sumLoss5 > 0 ? sumWin5 / sumLoss5 : (sumWin5 > 0 ? 99.0 : 0.0)
    pf1  = sumLoss1 > 0 ? sumWin1 / sumLoss1 : (sumWin1 > 0 ? 99.0 : 0.0)
    has5 = nTr5 > 0
    has1 = nTr1 > 0
    bestExp = exp5 >= exp1 ? exp5 : exp1

    table.cell(sigp, 0, 0, "SIGNAL & STATS", text_color=color.white, text_size=tblTxt, bgcolor=color.new(#0a0d12, 0), text_halign=text.align_left, tooltip="Aktiv signal + statistik per setup-klass. Stang av panelen under Visuals.")
    table.cell(sigp, 1, 0, inTrade ? (beAct ? "BE" : "live") : "flat", text_color=color.new(#c7a45a, 0), text_size=tblTxt, bgcolor=color.new(#0a0d12, 0), text_halign=text.align_right)

    f_hdr(sigp, 1, "SIGNAL", "Den aktiva signalen. Bara en at gangen. 1H = i linje med HTF (swing), 5M = lokal reaktion (scalp).")
    sigTxt = inTrade ? (tDir == 1 ? "LONG " : "SHORT ") + sigClass : "WAIT"
    sigBg  = inTrade ? (tDir == 1 ? cUp : cDn) : cNu
    f_item(sigp, 2, "Signal", sigTxt, sigBg, "LONG/SHORT = aktiv setup (entry pa stangning) + klass. WAIT = inget lage just nu.")
    f_item(sigp, 3, "Entry",       inTrade ? f_lvl(dEntry) : "-", inTrade ? cBg2 : cNu, "Ingang (priset vid bekraftad zon-tap).")
    f_item(sigp, 4, "Stop loss",   inTrade ? f_lvl(dSL)    : "-", inTrade ? color.new(#a8413d, 0) : cNu, "Bortom zonen. Flyttas till break-even efter TP1.")
    f_item(sigp, 5, "Take profit 1", inTrade ? f_lvl(dT1) : "-", inTrade ? color.new(#2f7d5b, 0) : cNu, "Narmaste likviditet/niva i trade-riktningen.")
    f_item(sigp, 6, "Take profit 2", inTrade ? f_lvl(dT2) : "-", inTrade ? color.new(#2f7d5b, 0) : cNu, "Nasta niva.")
    f_item(sigp, 7, "Take profit 3", inTrade ? f_lvl(dT3) : "-", inTrade ? color.new(#2f7d5b, 0) : cNu, "Tredje nivan / langsta malet.")
    f_item(sigp, 8, "DCA2 (avg down)", inTrade ? f_lvl(dDCA) : "-", inTrade ? color.new(#7a6326, 0) : cNu, "Andra ingangen vid zon-mitten for battre snittpris.")

    f_hdr(sigp, 9, "PERFORMANCE  (5M | 1H)", "Statistik per setup-klass. Modell: 1/3 bokas vid varje TP, BE efter TP1, smart exit, pessimistisk vid tie. R fran faktiska nivapriser. Nollstalls vid omladdning.")
    f_item(sigp, 10, "Win rate", (has5 ? str.tostring(wr5) + "%" : "-") + "  |  " + (has1 ? str.tostring(wr1) + "%" : "-"), cNu, "Andel vinnande trades. 5M vanster, 1H hoger.")
    f_item(sigp, 11, "Profit factor", (has5 ? (pf5 >= 99 ? "inf" : str.tostring(pf5, "#.##")) : "-") + "  |  " + (has1 ? (pf1 >= 99 ? "inf" : str.tostring(pf1, "#.##")) : "-"), cNu, "Vinst-R / forlust-R. > 1 lonsamt, > 1.5 bra. 5M | 1H.")
    f_item(sigp, 12, "Expectancy", (has5 ? (exp5 >= 0 ? "+" : "") + str.tostring(exp5, "#.##") : "-") + "R | " + (has1 ? (exp1 >= 0 ? "+" : "") + str.tostring(exp1, "#.##") : "-") + "R", (has5 or has1) ? (bestExp > 0 ? cUp : cDn) : cNu, "Forvantat R per trade. Nyckeltalet, inte win rate. 5M | 1H.")
    f_item(sigp, 13, "Net (PnL%)", (has5 ? (sumR5 >= 0 ? "+" : "") + str.tostring(sumR5 * riskPct, "#.#") + "%" : "-") + " | " + (has1 ? (sumR1 >= 0 ? "+" : "") + str.tostring(sumR1 * riskPct, "#.#") + "%" : "-"), cNu, "Uppskattad PNL vid " + str.tostring(riskPct, "#.##") + "% risk/trade. 5M | 1H.")
    f_item(sigp, 14, "Trades", str.tostring(nTr5) + " (" + str.tostring(nWin5) + "W) | " + str.tostring(nTr1) + " (" + str.tostring(nWin1) + "W)", cNu, "Antal avslutade trades (vinnare). Fa = osakert. 5M | 1H.")

    table.cell(sigp, 0, 15, "ICP v20", text_color=color.new(#3f4855, 0), text_size=size.tiny, bgcolor=color.new(#0a0d12, 0), text_halign=text.align_left)
    table.cell(sigp, 1, 15, "5M|1H", text_color=color.new(#3f4855, 0), text_size=size.tiny, bgcolor=color.new(#0a0d12, 0), text_halign=text.align_right)
````
