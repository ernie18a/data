# Aquile Reali Debt Scenario

- url: https://www.tradingview.com/script/oo1KiVTr/
- type: indicator
- pine_id: PUB;9216a6e395ed44049c8ec97fa6a03b22
- version: 1.0

## Description

🦅 AQUILE REALI — DEBT SCENARIO
Can the United States inflate its debt away? And what does it mean for gold?
 
This indicator answers one question in a single table: which "debt regime" is the market in right now — and how gold has historically behaved in it.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THE IDEA IN ONE MINUTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
Imagine you owe the bank 100,000 on a fixed-rate mortgage, and you earn 2,000 a month. Then strong inflation hits: prices double, and so does your salary — now 4,000. But your debt is still 100,000. The number on the contract never changes.
 
Before, your debt was worth 50 months of salary. Now it is worth 25. You repaid nothing, yet your debt has been cut in half. Who paid for it? The bank: it gets back money that buys half as much.
 
A government can do exactly the same. With debt above 100% of GDP, letting inflation run makes the debt shrink on its own — as long as the interest rate it pays stays BELOW inflation. Economists call this "financial repression". It is a hidden tax on savers and bondholders.
 
It has been done before:
• United States after World War II — debt above 100% of GDP. Until 1951 the Fed kept Treasury yields capped, inflation did the rest, and within roughly 25 years debt fell to around a quarter of GDP.
• Italy in the 1970s — double-digit inflation, and the central bank bought the Treasury bills the market didn't want. When that arrangement ended in 1981, real rates turned positive and high, and the debt exploded during the 1980s.
 
The lesson: the trick works... until the market notices. Lenders are not stupid. If they expect inflation, they stop lending at 1% and ask for 5%, 6%, 8%. And since a government must constantly roll over its maturing debt, it has to pay those higher rates — and the trick breaks.
 
That tug-of-war between the State and the bond market is exactly what this indicator measures.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THE 3 SCENARIOS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
🔴 SCENARIO 1 · THE MARKET WINS
Investors refuse to be "inflated away". They demand higher yields at Treasury auctions, real yields climb, the Fed stays tight to fight inflation. The US pays a lot of interest, but inflation slowly cools.
Like the bank that says: "I'll lend to you again — but at 8%."
→ Gold: held back. Rising real yields and a strong dollar are its two classic headwinds.
What you see: real yield rising, breakeven inflation flat or falling, Fed balance sheet flat or shrinking, auction yields higher than last time, FedWatch leaning towards hikes.
 
🟢 SCENARIO 2 · FINANCIAL REPRESSION
The burden becomes too heavy and the State forces the market's hand. The Fed buys bonds to keep rates down, the Treasury shifts to short-term issuance, pressure builds to keep yields low while inflation stays high. The trick works: debt shrinks in real terms, savers pay the bill.
Like the post-war US or 1970s Italy.
→ Gold: the best environment of all. When bonds pay less than inflation, money flees bonds and cash and looks for something that cannot be printed.
What you see: real yield falling, breakeven inflation rising, Fed balance sheet growing again, auction yields easing, FedWatch leaning towards cuts.
 
🟠 SCENARIO 3 · SOMETHING BREAKS
Rates rise so far that something cracks — stocks, banks, real estate, a funding market. Volatility explodes and the Fed is forced to cut in a hurry to save the system.
→ Gold: often falls first (everything is sold to raise cash, gold included), then usually rallies hard once the Fed starts easing.
What you see: VIX above the threshold (default 25). This overrides every other signal.
 
⚪ SCENARIO 0 · TRANSITION
Mixed signals, no clear regime. Often the moment when one scenario is ending and the next has not yet taken over.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT THE INDICATOR READS — AUTOMATICALLY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
• 10Y real yield (FRED DFII10) — the real cost of money after inflation. The single most important driver of gold.
• 10Y breakeven inflation (FRED T10YIE) — the inflation the bond market expects.
• Fed balance sheet (FRED WALCL, weekly, released Thursdays) — is the Fed buying debt again?
• VIX — the market's fear gauge.
• 10Y nominal yield and DXY — context: what the US pays to borrow, and the dollar.
• FedWatch-style probabilities for the next FOMC meeting, calculated from CBOT 30-Day Fed Funds futures (ZQ) and the effective fed funds rate (FRED EFFR). Same logic as the CME tool; results may differ by a few points.
• FOMC calendar built in (2026 and the Fed's tentative 2027 dates). The indicator finds the next meeting by itself.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT YOU UPDATE — ONCE A MONTH (2 MINUTES)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
Pine Script cannot read websites, so the US Treasury auction results are entered by hand. They are the best real-time proof of whether the market is "accepting" the debt or pushing back.
 
1. Open the indicator Settings → section "Manual data".
2. The day after the monthly 30-year auction, enter for both the 10-year note and the 30-year bond: auction date, high yield, previous auction yield, bid-to-cover.
3. Where to find them: the US Treasury auction results (TreasuryDirect), or any economic calendar listing "10-Year Note Auction" and "30-Year Bond Auction".
 
You never have to remember the date. The official US Treasury auction calendar is built in: the "Data status" row shows the exact day of the next update (for example: "next update 13/11/26 — 10Y auction 10/11, 30Y 12/11") and turns to ⚠ UPDATE NEEDED as soon as a new result is out. An optional alert reminds you once a day until you do it.
 
How to read an auction: a yield higher than the previous auction means investors demanded more to lend → the market is pushing back (scenario 1). Bid-to-cover is the number of bids for every bond sold: when it falls, demand is weakening.
 
The script is updated after each auction month with the new default values.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW THE SCORE WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
Six signals, one point each, to scenario 1 or scenario 2:
1. Real yield direction
2. Breakeven inflation direction
3. Fed balance sheet direction
4. Real yield vs threshold (default 2.80%)
5. Auction yields vs previous auction
6. FedWatch: hike more likely than cut, or the opposite
4 points out of 6 decide the scenario (3 out of 4 if you switch the manual data off). VIX above its threshold overrides everything → scenario 3.
The comparison period is selectable: 1 week, 20 days or 1 month (default).
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TABLE VERSIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
• Weekly — value and 1-week change for every asset, auctions and FedWatch included (default)
• Full — every asset across 3 periods, date of each data point, optional "meaning" column
• Minimal — only the 4 assets that drive the scenario
• Survival — scenario and gold impact only, for a clean trading chart
Classic, Dark and Light themes · 9 positions · 5 text sizes · English / Italiano.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
Create alert → Condition "AR Debt Scenario" → "Any alert() function call".
You will be notified when the scenario changes (with all the values in the message) and when the manual data needs updating. Separate alert conditions are also available for entering each scenario.
 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 
• FRED series are published with about one business day of delay; the "As of" column in the Full table shows the date of each value.
• This is a macro context tool for the bigger picture, not an entry signal. Nobody knows the timing: a regime can last months or years.
 
Personal opinion, not financial advice.
 
Aquile Reali
Nate per volare, nate per osare · Be Stable. Be Strong. 🦅

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
// Aquile Reali — Debt Scenario v2.0  ·  by giua64
// Which "debt regime" is the US in, and what it means for gold.
//   1 = Market wins           (real yields rising)                → gold held back
//   2 = Financial repression  (real yields falling, inflation up) → gold favoured
//   3 = Something breaks      (VIX spike)                         → gold: down first, then up
//
// AUTOMATIC DATA: FRED:DFII10, FRED:T10YIE, FRED:WALCL, TVC:VIX, TVC:US10Y, TVC:DXY,
//                 FedWatch-style probabilities from CBOT ZQ futures + FRED:EFFR,
//                 FOMC calendar built in (through Dec 2027).
// MANUAL DATA (once a month, the day after the 30Y auction):
//                 US Treasury 10Y and 30Y auction results → Settings → "Manual data".
//                 Official auction calendar built in (array auc10List / auc30List below):
//                 the table shows the NEXT UPDATE date and "⚠ UPDATE NEEDED" as soon as a new auction is out.
//
// ═══ UPDATE CALENDAR (US Treasury tentative schedule, verified 16/10/2026) ═══
//   10Y auction   30Y auction   → UPDATE ON
//   10/11/2026    12/11/2026    → 13/11/2026
//   08/12/2026    10/12/2026    → 11/12/2026
//   12/01/2027    13/01/2027    → 14/01/2027
//   Schedule ends 02/02/2027: the Treasury publishes the next quarter around end of January →
//   add the new dates to auc10List / auc30List (the table will remind you).
// ══════════════════════════════════════════════════════════════════════════════

indicator("Aquile Reali Debt Scenario", shorttitle = "AR Debt Scenario", overlay = true)

// ───────── Language / theme / layout ─────────
grpT     = "Display / Visualizzazione"
lang     = input.string("English", "Language / Lingua", options = ["English", "Italiano"], group = grpT)
mode     = input.string("Weekly / Settimana", "Table version / Versione tabella", options = ["Full / Completa", "Weekly / Settimana", "Minimal / Minimale", "Survival"], group = grpT,
     tooltip = "Full = all data and 3 periods · Weekly = value + 1-week change for every asset · Minimal = the 4 scenario assets · Survival = scenario only\nCompleta = tutto · Settimana = valore + variazione 1 settimana · Minimale = i 4 asset dello scenario · Survival = solo scenario")
theme    = input.string("Classic", "Theme / Tema", options = ["Classic", "Dark", "Light"], group = grpT)
posIn    = input.string("Top right", "Position / Posizione", options = ["Top left", "Top center", "Top right", "Middle left", "Middle center", "Middle right", "Bottom left", "Bottom center", "Bottom right"], group = grpT)
sizeIn   = input.string("Normal", "Text size / Dimensione testo", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpT)
bgTr     = input.int(15, "Background transparency / Trasparenza sfondo", minval = 0, maxval = 90, group = grpT)
showDesc = input.bool(false, "Full: show 'Meaning' column / Completa: colonna 'Cosa significa'", group = grpT)

// ───────── Manual data: Treasury auctions ─────────
ttAuc = "UPDATE ONCE A MONTH, the day after the 30Y auction. The table's 'Data status' row shows the exact next update date (official Treasury calendar built in). Upcoming: 13/11/2026 · 11/12/2026 · 14/01/2027.\nWhere: US Treasury auction results (TreasuryDirect) or the ForexFactory calendar ('10-y Note Auction' / '30-y Bond Auction').\nWhen you enter a new auction, today's yield becomes the 'previous'.\n\nAGGIORNARE 1 VOLTA AL MESE, il giorno dopo l'asta 30Y. La riga 'Stato dati' mostra la data esatta del prossimo aggiornamento. Prossimi: 13/11/2026 · 11/12/2026 · 14/01/2027.\nDove: risultati aste del Tesoro USA (TreasuryDirect) o calendario ForexFactory.\nCon la nuova asta, il rendimento attuale diventa il 'precedente'."
grpA    = "✍ Manual data · 10Y Treasury auction (monthly)"
a10T    = input.time(timestamp("2026-10-07 00:00 +0000"), "Auction date / Data asta", group = grpA, tooltip = ttAuc)
a10Yld  = input.float(5.300, "High yield % / Rendimento %", step = 0.001, group = grpA, tooltip = ttAuc)
a10Prev = input.float(4.834, "Previous auction yield % / Precedente %", step = 0.001, group = grpA, tooltip = ttAuc)
a10Bc   = input.float(2.77, "Bid-to-cover", step = 0.01, group = grpA, tooltip = ttAuc)
a10BcP  = input.float(2.71, "Previous bid-to-cover (0 = n/a)", step = 0.01, group = grpA, tooltip = ttAuc)

grpB    = "✍ Manual data · 30Y Treasury auction (monthly)"
a30T    = input.time(timestamp("2026-10-08 00:00 +0000"), "Auction date / Data asta", group = grpB, tooltip = ttAuc)
a30Yld  = input.float(5.618, "High yield % / Rendimento %", step = 0.001, group = grpB, tooltip = ttAuc)
a30Prev = input.float(5.308, "Previous auction yield % / Precedente %", step = 0.001, group = grpB, tooltip = ttAuc)
a30Bc   = input.float(2.54, "Bid-to-cover", step = 0.01, group = grpB, tooltip = ttAuc)
a30BcP  = input.float(2.61, "Previous bid-to-cover (0 = n/a)", step = 0.01, group = grpB, tooltip = ttAuc)
staleD  = input.int(35, "Fallback warning after N days (if auction calendar ended) / Avviso di riserva dopo N giorni", minval = 20, group = grpB)
useMan  = input.bool(true, "Use auctions + FedWatch in the scenario score / Usa aste e FedWatch nel punteggio", group = grpB)

// ───────── FedWatch ─────────
grpF    = "⚙ FedWatch (automatic / automatico)"
fwAuto  = input.bool(true, "Automatic from CBOT ZQ futures / Automatico dai futures ZQ", group = grpF,
     tooltip = "Same method as CME FedWatch: compares the current rate (FRED:EFFR) with the rate priced by Fed Funds futures. May differ by a few points from the CME site.\nStesso metodo del CME FedWatch; può differire di qualche punto.")
fomcMan = input.bool(false, "Force manual FOMC date (normally OFF) / Forza data FOMC manuale", group = grpF)
fomcInp = input.time(timestamp("2026-10-28 00:00 +0000"), "Manual FOMC date / Data FOMC manuale", group = grpF)
fwCutM  = input.float(0.0,  "Fallback: cut % / Taglio %", minval = 0, maxval = 100, group = grpF)
fwHoldM = input.float(80.0, "Fallback: hold % / Fermi %", minval = 0, maxval = 100, group = grpF)
fwHikeM = input.float(20.0, "Fallback: hike % / Rialzo %", minval = 0, maxval = 100, group = grpF)

// ───────── Periods & scenario ─────────
grpP    = "Periods (trading sessions) / Periodi (sedute)"
d1      = input.int(5,  "1 week / 1 settimana", minval = 1, group = grpP)
d2      = input.int(14, "20 days / 20 giorni", minval = 1, group = grpP)
d3      = input.int(21, "1 month / 1 mese", minval = 1, group = grpP)
w1      = input.int(1, "Fed balance sheet weeks · 1W", minval = 1, group = grpP)
w2      = input.int(3, "Fed balance sheet weeks · 20D", minval = 1, group = grpP)
w3      = input.int(4, "Fed balance sheet weeks · 1M", minval = 1, group = grpP)
grpC    = "Scenario / Scenario"
scenPer = input.string("1 month", "Period that decides the scenario / Periodo per lo scenario", options = ["1 week", "20 days", "1 month"], group = grpC)
dfiiThr = input.float(2.80, "Real yield threshold % / Soglia rend. reale %", step = 0.05, group = grpC)
vixThr  = input.float(25.0, "VIX threshold (scenario 3) / Soglia VIX", step = 0.5, group = grpC)

// ───────── Helpers ─────────
isEN = lang == "English"
tr(string it, string en) => isEN ? en : it
f0(float x) => str.tostring(x, "0")
f1(float x) => str.tostring(x, "0.0")
f2(float x) => str.tostring(x, "0.00")
f3(float x) => str.tostring(x, "0.000")
arrow(float x) => na(x) ? "–" : x > 0 ? "▲" : x < 0 ? "▼" : "="
sgn(float x) => x > 0 ? "+" : ""

// ───────── Automatic data ─────────
[dfii, dfii1, dfii2, dfii3, dfiiT] = request.security("FRED:DFII10", "D", [close, close[d1], close[d2], close[d3], time])
[be,   be1,   be2,   be3,   beT]   = request.security("FRED:T10YIE", "D", [close, close[d1], close[d2], close[d3], time])
[fedR, fedR1, fedR2, fedR3, fedT]  = request.security("FRED:WALCL",  "W", [close, close[w1], close[w2], close[w3], time])
[vix,  vix1,  vix2,  vix3,  vixT]  = request.security("TVC:VIX",     "D", [close, close[d1], close[d2], close[d3], time])
[us,   us1,   us2,   us3,   usT]   = request.security("TVC:US10Y",   "D", [close, close[d1], close[d2], close[d3], time])
[dx,   dx1,   dx2,   dx3,   dxT]   = request.security("TVC:DXY",     "D", [close, close[d1], close[d2], close[d3], time])

// WALCL: TradingView may deliver dollars or millions of dollars → normalise to dollars
fedK = fedR > 1e10 ? 1.0 : 1e6
fed  = fedR * fedK
fed1 = fedR1 * fedK
fed2 = fedR2 * fedK
fed3 = fedR3 * fedK

pick(float a, float b, float c) =>
    switch scenPer
        "1 week"  => a
        "20 days" => b
        => c

dfiiChg = dfii - pick(dfii1, dfii2, dfii3)
beChg   = be   - pick(be1, be2, be3)
fedChg  = fed  - pick(fed1, fed2, fed3)

// ───────── FOMC calendar (decision day) — verified 16/10/2026 ─────────
// 2026: 28/1, 18/3, 29/4, 17/6, 29/7, 16/9, 28/10, 9/12 · 2027 (Fed tentative): 27/1, 17/3, 28/4, 9/6, 28/7, 15/9, 27/10, 8/12
var array<int> fomcList = array.from(
     timestamp("UTC", 2026, 10, 28, 0, 0), timestamp("UTC", 2026, 12, 9, 0, 0),
     timestamp("UTC", 2027, 1, 27, 0, 0),  timestamp("UTC", 2027, 3, 17, 0, 0),
     timestamp("UTC", 2027, 4, 28, 0, 0),  timestamp("UTC", 2027, 6, 9, 0, 0),
     timestamp("UTC", 2027, 7, 28, 0, 0),  timestamp("UTC", 2027, 9, 15, 0, 0),
     timestamp("UTC", 2027, 10, 27, 0, 0), timestamp("UTC", 2027, 12, 8, 0, 0))

int fomcAutoT = na
for ft in fomcList
    if na(fomcAutoT) and ft + 86400000 > timenow
        fomcAutoT := ft
bool fomcListEnded = na(fomcAutoT)
int fomcT = fomcMan ? fomcInp : fomcListEnded ? array.last(fomcList) : fomcAutoT

mY = year(fomcT, "UTC")
mM = month(fomcT, "UTC")
mD = dayofmonth(fomcT, "UTC")
bool nextNoM = true
for ft in fomcList
    if (mM == 12 ? year(ft, "UTC") == mY + 1 and month(ft, "UTC") == 1 : year(ft, "UTC") == mY and month(ft, "UTC") == mM + 1)
        nextNoM := false

// ───────── FedWatch-style probabilities from ZQ ─────────
nowY = year(timenow, "America/New_York")
nowM = month(timenow, "America/New_York")
int zqOff = (mY - nowY) * 12 + (mM - nowM)
bool fomcPast = zqOff < 0 or (zqOff == 0 and dayofmonth(timenow, "America/New_York") > mD)
int offC = math.max(zqOff, 0)
nY = mM == 12 ? mY + 1 : mY
nM = mM == 12 ? 1 : mM + 1
float nDays = (timestamp("UTC", nY, nM, 1, 0, 0) - timestamp("UTC", mY, mM, 1, 0, 0)) / 86400000.0

zqMeet = request.security("CBOT:ZQ" + str.tostring(offC + 1) + "!", "D", close)
zqNext = request.security("CBOT:ZQ" + str.tostring(offC + 2) + "!", "D", close)
effr   = request.security("FRED:EFFR", "D", close)

float rPost = nextNoM ? 100 - zqNext : ((100 - zqMeet) - effr * mD / nDays) / ((nDays - mD) / nDays)
float rDiff = rPost - effr
float hikeA = rDiff > 0 ? math.min(rDiff / 0.25, 1) * 100 : 0
float cutA  = rDiff < 0 ? math.min(-rDiff / 0.25, 1) * 100 : 0
bool autoOk = fwAuto and not na(rPost) and not na(effr) and not fomcPast
float fwCut  = autoOk ? cutA : fwCutM
float fwHike = autoOk ? hikeA : fwHikeM
float fwHold = autoOk ? 100 - hikeA - cutA : fwHoldM
string fwFomc = str.format_time(fomcT, "dd/MM/yy", "UTC")

// ───────── Treasury auction calendar (US Treasury tentative schedule, verified 16/10/2026) ─────────
var array<int> auc10List = array.from(
     timestamp("UTC", 2026, 11, 10, 0, 0), timestamp("UTC", 2026, 12, 8, 0, 0), timestamp("UTC", 2027, 1, 12, 0, 0))
var array<int> auc30List = array.from(
     timestamp("UTC", 2026, 11, 12, 0, 0), timestamp("UTC", 2026, 12, 10, 0, 0), timestamp("UTC", 2027, 1, 13, 0, 0))
DAY = 86400000

// Is there an auction in the list AFTER the one entered that is already out? (results available the day after)
missedAuc(array<int> lst, int entered) =>
    bool missed = false
    for at in lst
        if at > entered + DAY and at + DAY <= timenow
            missed := true
    missed
// Next auction still to come
nextAuc(array<int> lst) =>
    int nx = na
    for at in lst
        if na(nx) and at + DAY > timenow
            nx := at
    nx

int nx10 = nextAuc(auc10List)
int nx30 = nextAuc(auc30List)
bool aucListEnded = na(nx10) or na(nx30)
float a10Age = (timenow - a10T) / 86400000.0
float a30Age = (timenow - a30T) / 86400000.0
bool a10Stale = missedAuc(auc10List, a10T) or (aucListEnded and a10Age > staleD)
bool a30Stale = missedAuc(auc30List, a30T) or (aucListEnded and a30Age > staleD)
bool manStale = a10Stale or a30Stale or fomcListEnded
int nextUpd = na(nx30) ? na : nx30 + DAY
string nextUpdTxt = aucListEnded ? tr("calendario aste finito: aggiungi le nuove date", "auction calendar ended: add new dates") :
     str.format_time(nextUpd, "dd/MM/yy", "UTC") + tr(" (aste 10Y ", " (10Y auction ") + str.format_time(nx10, "dd/MM", "UTC") + tr(" e 30Y ", ", 30Y ") + str.format_time(nx30, "dd/MM", "UTC") + ")"
string statusTxt = manStale ?
     "⚠ " + tr("DA AGGIORNARE: ", "UPDATE NEEDED: ") + (a10Stale ? tr("asta 10Y  ", "10Y auction  ") : "") + (a30Stale ? tr("asta 30Y  ", "30Y auction  ") : "") + (fomcListEnded ? tr("calendario FOMC", "FOMC calendar") : "") :
     "✅ " + tr("Aggiornato · prossimo aggiornamento ", "Up to date · next update ") + nextUpdTxt

// ───────── Scenario logic ─────────
a10Chg = a10Yld - a10Prev
a30Chg = a30Yld - a30Prev
aucBad = (a10Chg + a30Chg) / 2 > 0
fwBad  = fwHike > fwCut
fwGood = fwCut > fwHike

int maxPts  = useMan ? 6 : 4
int needPts = useMan ? 4 : 3
int s2man = useMan ? (aucBad ? 0 : 1) + (fwGood ? 1 : 0) : 0
int s1man = useMan ? (aucBad ? 1 : 0) + (fwBad ? 1 : 0) : 0
s2pts = (dfiiChg < 0 ? 1 : 0) + (beChg > 0 ? 1 : 0) + (fedChg > 0 ? 1 : 0) + (dfii < dfiiThr ? 1 : 0) + s2man
s1pts = (dfiiChg > 0 ? 1 : 0) + (beChg <= 0 ? 1 : 0) + (fedChg <= 0 ? 1 : 0) + (dfii >= dfiiThr ? 1 : 0) + s1man
bool vixAlert = vix >= vixThr
int scen = vixAlert ? 3 : s2pts >= needPts ? 2 : s1pts >= needPts ? 1 : 0

scenName(int s) =>
    s == 1 ? tr("1 · Il mercato vince", "1 · Market wins") : s == 2 ? tr("2 · Repressione finanziaria", "2 · Financial repression") : s == 3 ? tr("3 · Si rompe qualcosa", "3 · Something breaks") : tr("0 · Transizione", "0 · Transition")
scenGold(int s) =>
    s == 1 ? tr("Oro frenato", "Gold held back") : s == 2 ? tr("Oro favorito", "Gold favoured") : s == 3 ? tr("Oro: prima giù, poi su", "Gold: down first, then up") : tr("Nessun segnale chiaro", "No clear signal")

// ───────── Theme ─────────
classic = theme == "Classic"
dark    = theme == "Dark"
cBg1    = classic ? color.new(color.black, bgTr) : color.new(dark ? #131722 : #FFFFFF, bgTr)
cBg2    = classic ? color.new(color.black, bgTr) : color.new(dark ? #1E222D : #F0F3FA, bgTr)
cHead   = classic ? color.new(color.blue, 40) : color.new(dark ? #2A2E39 : #E0E3EB, bgTr)
cTxt    = classic ? color.white : dark ? #D1D4DC : #131722
cMuted  = classic ? color.silver : #787B86
cBorder = classic ? color.new(color.gray, 60) : dark ? #363A45 : #D1D4DC
cManBg  = color.new(color.purple, 50)
cGold   = #F0B90B
cGood   = classic ? color.green : #26A69A
cBad    = classic ? color.red : #EF5350
cWarn   = classic ? color.orange : #FF9800
cMan    = classic ? color.white : dark ? #B39DDB : #7E57C2
scenCol(int s) => s == 1 ? cBad : s == 2 ? cGood : s == 3 ? cWarn : cMuted
statusCol = manStale ? cWarn : cGood

tPos = switch posIn
    "Top left"      => position.top_left
    "Top center"    => position.top_center
    "Top right"     => position.top_right
    "Middle left"   => position.middle_left
    "Middle center" => position.middle_center
    "Middle right"  => position.middle_right
    "Bottom left"   => position.bottom_left
    "Bottom center" => position.bottom_center
    => position.bottom_right
sz = switch sizeIn
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    => size.huge

var table t = table.new(tPos, 8, 16, frame_color = cBorder, frame_width = 1, border_color = cBorder, border_width = 1)

// ───────── Cell helpers ─────────
rowBg(int r) => r % 2 == 0 ? cBg2 : cBg1
txtCell(int c, int r, string s, color col, color bg) =>
    table.cell(t, c, r, s, text_color = col, bgcolor = bg, text_size = sz, text_halign = text.align_left)
numCell(int c, int r, string s, color col, color bg) =>
    table.cell(t, c, r, s, text_color = col, bgcolor = bg, text_size = sz, text_halign = classic ? text.align_center : text.align_right, text_font_family = classic ? font.family_default : font.family_monospace)
ctrCell(int c, int r, string s, color col, color bg) =>
    table.cell(t, c, r, s, text_color = col, bgcolor = bg, text_size = sz, text_halign = text.align_center)
hdr(int c, string s) =>
    table.cell(t, c, 0, s, text_color = classic ? color.white : c == 0 ? cGold : cMuted, bgcolor = cHead, text_size = sz, text_halign = c == 0 ? text.align_left : text.align_center)
wide(int r, int lastCol, string label, string s, color col, color bg) =>
    txtCell(0, r, label, cMuted, bg)
    ctrCell(1, r, s, col, bg)
    table.merge_cells(t, 1, r, lastCol, r)

// kind: 0 = basis points · 1 = points · 2 = percent · 3 = billions of dollars
fmtChg(float now, float past, int kind) =>
    float x = now - past
    string out = "–"
    if not na(x)
        out := switch kind
            0 => arrow(x) + " " + sgn(x) + f0(x * 100) + " bp"
            1 => arrow(x) + " " + sgn(x) + f2(x)
            2 => arrow(x) + " " + sgn(x) + f2(x / past * 100) + "%"
            => arrow(x) + " " + sgn(x) + f1(x / 1e9) + tr(" mld $", " B$")
    out
chgCol(float now, float past, bool upGood) =>
    float x = now - past
    na(x) or x == 0 ? cMuted : (x > 0) == upGood ? cGood : cBad
effTxt(float x, bool upGood) =>
    na(x) or x == 0 ? tr("Neutro", "Neutral") : (x > 0) == upGood ? tr("Pro oro", "Gold +") : tr("Contro oro", "Gold −")
fedVal(float x) => isEN ? "$" + f2(x / 1e12) + "T" : f2(x / 1e12) + " mila mld $"
bcTxt(float bc, float bcP) => "b/c " + f2(bc) + (bcP > 0 ? " (" + f2(bcP) + ")" : "")
aucDetail(float prev, float chg, float bc, float bcP) =>
    tr("prec. ", "prev. ") + f3(prev) + "% (" + sgn(chg) + f0(chg * 100) + " bp) · " + bcTxt(bc, bcP)
fwDetail() =>
    "FOMC " + fwFomc + tr(": taglio ", ": cut ") + f0(fwCut) + "% · " + tr("fermi ", "hold ") + f0(fwHold) + "%"
fwLabel() => autoOk ? tr("⚙ FedWatch auto", "⚙ FedWatch auto") : tr("✍ FedWatch manuale", "✍ FedWatch manual")
fwColor() => fwBad ? cBad : fwGood ? cGood : cMuted
fwEff() => fwBad ? tr("Contro oro", "Gold −") : fwGood ? tr("Pro oro", "Gold +") : tr("Neutro", "Neutral")

// ═════════ SURVIVAL ═════════
if barstate.islast and mode == "Survival"
    table.clear(t, 0, 0, 7, 15)
    table.cell(t, 0, 0, "🦅 " + scenName(scen), text_color = color.white, bgcolor = scenCol(scen), text_size = sz)
    ctrCell(0, 1, scenGold(scen), scenCol(scen), cBg1)
    ctrCell(0, 2, tr("Reale ", "Real ") + f2(dfii) + "% " + arrow(dfiiChg) + "  ·  VIX " + f1(vix) + (vixAlert ? " ⚠" : ""), cMuted, cBg2)
    if manStale
        ctrCell(0, 3, statusTxt, cWarn, cBg1)

// ═════════ WEEKLY ═════════
wkRow(int r, string name, string val, float now, float past, int kind, bool upGood) =>
    color bg = rowBg(r)
    txtCell(0, r, name, cTxt, bg)
    numCell(1, r, val, cTxt, bg)
    numCell(2, r, fmtChg(now, past, kind), chgCol(now, past, upGood), bg)
    ctrCell(3, r, effTxt(now - past, upGood), chgCol(now, past, upGood), bg)

manRow(int r, string name, string val, string detail, color col, string eff) =>
    color bg = rowBg(r)
    txtCell(0, r, name, cMan, classic ? cManBg : bg)
    numCell(1, r, val, cTxt, bg)
    ctrCell(2, r, detail, col, bg)
    ctrCell(3, r, eff, col, bg)

if barstate.islast and mode == "Weekly / Settimana"
    table.clear(t, 0, 0, 7, 15)
    hdr(0, "🦅 AR Debt Scenario")
    hdr(1, tr("Valore", "Value"))
    hdr(2, tr("vs 1 sett fa", "vs 1 week ago"))
    hdr(3, tr("Effetto oro", "Gold"))
    wkRow(1, tr("Rend. reale 10Y", "10Y real yield"), f2(dfii) + "%", dfii, dfii1, 0, false)
    wkRow(2, tr("Inflazione attesa", "Breakeven inflation"), f2(be) + "%", be, be1, 0, true)
    wkRow(3, tr("Bilancio Fed", "Fed balance sheet"), fedVal(fed), fed, fed1, 3, true)
    // VIX: own effect wording
    color bgV = rowBg(4)
    txtCell(0, 4, "VIX", cTxt, bgV)
    numCell(1, 4, f2(vix), cTxt, bgV)
    numCell(2, 4, fmtChg(vix, vix1, 1), chgCol(vix, vix1, false), bgV)
    ctrCell(3, 4, vixAlert ? tr("ALLARME", "ALERT") : tr("Calmo", "Calm"), vixAlert ? cWarn : cMuted, bgV)
    wkRow(5, tr("Rend. nominale 10Y", "10Y nominal yield"), f3(us) + "%", us, us1, 0, false)
    wkRow(6, tr("Dollaro DXY", "US Dollar DXY"), f2(dx), dx, dx1, 2, false)
    manRow(7, tr("✍ Asta 10Y ", "✍ 10Y auction ") + str.format_time(a10T, "dd/MM", "UTC") + (a10Stale ? " ⚠" : ""), f3(a10Yld) + "%",
         aucDetail(a10Prev, a10Chg, a10Bc, a10BcP), a10Chg > 0 ? cBad : cGood, effTxt(a10Chg, false))
    manRow(8, tr("✍ Asta 30Y ", "✍ 30Y auction ") + str.format_time(a30T, "dd/MM", "UTC") + (a30Stale ? " ⚠" : ""), f3(a30Yld) + "%",
         aucDetail(a30Prev, a30Chg, a30Bc, a30BcP), a30Chg > 0 ? cBad : cGood, effTxt(a30Chg, false))
    manRow(9, fwLabel(), tr("Rialzo ", "Hike ") + f0(fwHike) + "%", fwDetail(), fwColor(), fwEff())
    table.cell(t, 0, 10, "SCENARIO", text_color = cTxt, bgcolor = cBg1, text_size = sz, text_halign = text.align_left)
    table.cell(t, 1, 10, scenName(scen), text_color = color.white, bgcolor = scenCol(scen), text_size = sz)
    table.merge_cells(t, 1, 10, 3, 10)
    wide(11, 3, tr("Oro", "Gold"), scenGold(scen) + "  ·  S2 " + str.tostring(s2pts) + "/" + str.tostring(maxPts) + "  ·  S1 " + str.tostring(s1pts) + "/" + str.tostring(maxPts), scenCol(scen), cBg2)
    wide(12, 3, tr("Stato dati", "Data status"), statusTxt, statusCol, cBg1)

// ═════════ MINIMAL ═════════
if barstate.islast and mode == "Minimal / Minimale"
    table.clear(t, 0, 0, 7, 15)
    hdr(0, "🦅 AR Debt Scenario")
    hdr(1, tr("Valore", "Value"))
    hdr(2, "Δ " + scenPer)
    hdr(3, tr("Oro", "Gold"))
    wkRow(1, tr("Rend. reale 10Y", "10Y real yield"), f2(dfii) + "%", dfii, pick(dfii1, dfii2, dfii3), 0, false)
    wkRow(2, tr("Inflazione attesa", "Breakeven inflation"), f2(be) + "%", be, pick(be1, be2, be3), 0, true)
    wkRow(3, tr("Bilancio Fed", "Fed balance sheet"), fedVal(fed), fed, pick(fed1, fed2, fed3), 3, true)
    color bgV2 = rowBg(4)
    txtCell(0, 4, "VIX", cTxt, bgV2)
    numCell(1, 4, f2(vix), cTxt, bgV2)
    numCell(2, 4, fmtChg(vix, pick(vix1, vix2, vix3), 1), chgCol(vix, pick(vix1, vix2, vix3), false), bgV2)
    ctrCell(3, 4, vixAlert ? tr("ALLARME", "ALERT") : tr("Calmo", "Calm"), vixAlert ? cWarn : cMuted, bgV2)
    table.cell(t, 0, 5, "SCENARIO", text_color = cTxt, bgcolor = cBg1, text_size = sz, text_halign = text.align_left)
    table.cell(t, 1, 5, scenName(scen), text_color = color.white, bgcolor = scenCol(scen), text_size = sz)
    table.merge_cells(t, 1, 5, 3, 5)
    wide(6, 3, tr("Oro", "Gold"), scenGold(scen), scenCol(scen), cBg2)
    if manStale
        wide(7, 3, tr("Stato dati", "Data status"), statusTxt, cWarn, cBg1)

// ═════════ FULL ═════════
fullRow(int r, string name, string val, float now, float p1, float p2, float p3, int kind, bool upGood, string eff, color effCol, int dt, string desc) =>
    color bg = rowBg(r)
    txtCell(0, r, name, cTxt, bg)
    numCell(1, r, val, cTxt, bg)
    numCell(2, r, fmtChg(now, p1, kind), chgCol(now, p1, upGood), bg)
    numCell(3, r, fmtChg(now, p2, kind), chgCol(now, p2, upGood), bg)
    numCell(4, r, fmtChg(now, p3, kind), chgCol(now, p3, upGood), bg)
    ctrCell(5, r, eff, effCol, bg)
    ctrCell(6, r, na(dt) ? "–" : str.format_time(dt, "dd/MM", "Europe/Rome"), cMuted, bg)
    if showDesc
        txtCell(7, r, desc, cMuted, bg)

fullMan(int r, string name, string val, string detail, color col, string eff, string dt, string desc) =>
    color bg = rowBg(r)
    txtCell(0, r, name, cMan, classic ? cManBg : bg)
    numCell(1, r, val, cTxt, bg)
    ctrCell(2, r, detail, col, bg)
    table.merge_cells(t, 2, r, 4, r)
    ctrCell(5, r, eff, col, bg)
    ctrCell(6, r, dt, cMuted, bg)
    if showDesc
        txtCell(7, r, desc, cMuted, bg)

if barstate.islast and mode == "Full / Completa"
    table.clear(t, 0, 0, 7, 15)
    lastCol = showDesc ? 7 : 6
    hdr(0, "🦅 AR Debt Scenario")
    hdr(1, tr("Valore", "Value"))
    hdr(2, tr("1 sett", "1W"))
    hdr(3, tr("20 gg", "20D"))
    hdr(4, tr("1 mese", "1M"))
    hdr(5, tr("Oro*", "Gold*"))
    hdr(6, tr("Dato del", "As of"))
    if showDesc
        hdr(7, tr("Cosa significa", "Meaning"))
    fullRow(1, tr("Rend. reale 10Y", "10Y real yield"), f2(dfii) + "%", dfii, dfii1, dfii2, dfii3, 0, false,
         effTxt(dfiiChg, false), dfiiChg < 0 ? cGood : cBad, dfiiT,
         tr("Interesse vero dopo l'inflazione. Sale = oro frenato", "Yield after inflation. Rising = headwind for gold"))
    fullRow(2, tr("Inflazione attesa", "Breakeven inflation"), f2(be) + "%", be, be1, be2, be3, 0, true,
         effTxt(beChg, true), beChg > 0 ? cGood : cBad, beT,
         tr("Inflazione attesa dal mercato. Sale = il debito si sgonfia", "Market-implied inflation. Rising = debt being inflated away"))
    fullRow(3, tr("Bilancio Fed", "Fed balance sheet"), fedVal(fed), fed, fed1, fed2, fed3, 3, true,
         effTxt(fedChg, true), fedChg > 0 ? cGood : cBad, fedT,
         tr("Titoli comprati dalla Fed. Esce il giovedì", "Assets bought by the Fed. Released Thursdays"))
    fullRow(4, "VIX", f2(vix), vix, vix1, vix2, vix3, 1, false,
         vixAlert ? tr("ALLARME", "ALERT") : tr("Calmo", "Calm"), vixAlert ? cWarn : cMuted, vixT,
         tr("Sopra soglia = qualcosa si rompe (scenario 3)", "Above threshold = something breaks (scenario 3)"))
    fullRow(5, tr("Rend. nominale 10Y", "10Y nominal yield"), f3(us) + "%", us, us1, us2, us3, 0, false,
         "info", cMuted, usT, tr("Interesse pagato dagli USA", "What the US pays to borrow"))
    fullRow(6, tr("Dollaro DXY", "US Dollar DXY"), f2(dx), dx, dx1, dx2, dx3, 2, false,
         "info", cMuted, dxT, tr("Dollaro forte = oro frenato", "Strong dollar = headwind for gold"))
    fullMan(7, tr("✍ Asta 10Y", "✍ 10Y auction"), f3(a10Yld) + "%", aucDetail(a10Prev, a10Chg, a10Bc, a10BcP), a10Chg > 0 ? cBad : cGood,
         effTxt(a10Chg, false), str.format_time(a10T, "dd/MM", "UTC") + (a10Stale ? " ⚠" : ""),
         tr("Rendimento più alto della volta prima = il mercato resiste", "Higher than last time = market pushing back"))
    fullMan(8, tr("✍ Asta 30Y", "✍ 30Y auction"), f3(a30Yld) + "%", aucDetail(a30Prev, a30Chg, a30Bc, a30BcP), a30Chg > 0 ? cBad : cGood,
         effTxt(a30Chg, false), str.format_time(a30T, "dd/MM", "UTC") + (a30Stale ? " ⚠" : ""),
         tr("b/c = offerte per titolo. Scende = meno compratori", "b/c = bids per bond. Falling = weaker demand"))
    fullMan(9, fwLabel(), tr("Rialzo ", "Hike ") + f0(fwHike) + "%", fwDetail(), fwColor(), fwEff(), autoOk ? "auto" : "–",
         tr("Rialzo probabile = Fed restrittiva", "Hike likely = hawkish Fed"))
    table.cell(t, 0, 10, "SCENARIO", text_color = cTxt, bgcolor = cBg1, text_size = sz, text_halign = text.align_left)
    table.cell(t, 1, 10, scenName(scen), text_color = color.white, bgcolor = scenCol(scen), text_size = sz)
    table.merge_cells(t, 1, 10, lastCol, 10)
    wide(11, lastCol, tr("Oro", "Gold"), scenGold(scen), scenCol(scen), cBg2)
    wide(12, lastCol, tr("Punteggio", "Score"),
         "S2 " + str.tostring(s2pts) + "/" + str.tostring(maxPts) + "  ·  S1 " + str.tostring(s1pts) + "/" + str.tostring(maxPts) + tr("  ·  servono ", "  ·  needs ") + str.tostring(needPts) + tr("  ·  *periodo: ", "  ·  *period: ") + scenPer,
         cMuted, cBg1)
    wide(13, lastCol, tr("Stato dati", "Data status"), statusTxt, statusCol, cBg2)

// ───────── Alerts ─────────
// TradingView: Create alert → Condition "AR Debt Scenario" → "Any alert() function call"
var int lastScen = na
if barstate.isconfirmed
    if not na(lastScen) and scen != lastScen
        alert("AR Debt Scenario: " + scenName(lastScen) + " → " + scenName(scen) + " | " + scenGold(scen) +
              " | DFII10 " + f2(dfii) + "% | BE " + f2(be) + "% | VIX " + f1(vix) + " | US10Y " + f3(us) + "% | DXY " + f2(dx),
              alert.freq_once_per_bar_close)
    lastScen := scen

varip int lastStaleDay = na
if barstate.islast and barstate.isrealtime and manStale and dayofmonth(timenow) != lastStaleDay
    alert("AR Debt Scenario: " + statusTxt, alert.freq_once_per_bar)
    lastStaleDay := dayofmonth(timenow)

alertcondition(scen == 1 and scen[1] != 1, "Scenario 1 · Market wins", "AR Debt Scenario: scenario 1 (market wins) - gold held back")
alertcondition(scen == 2 and scen[1] != 2, "Scenario 2 · Financial repression", "AR Debt Scenario: scenario 2 (financial repression) - gold favoured")
alertcondition(scen == 3 and scen[1] != 3, "Scenario 3 · Something breaks", "AR Debt Scenario: scenario 3 (something breaks) - VIX spike")
````
