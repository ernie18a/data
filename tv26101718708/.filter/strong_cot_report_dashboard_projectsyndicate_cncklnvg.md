# Strong COT Report Dashboard | ProjectSyndicate

- url: https://www.tradingview.com/script/CnCKlnVg-Strong-COT-Report-Dashboard-ProjectSyndicate/
- type: indicator
- pine_id: PUB;368c1e736258420b93001f9be58a447d
- version: 1.0

## Description

Strong COT Report Dashboard takes the CFTC Commitments of Traders Legacy report and turns it into a live, side-by-side positioning matrix for up to 12 futures markets at once. Every Tuesday's release refreshes the whole grid with Non‑Commercial (large speculator) and Commercial (hedger) positioning, three COT indices, flip%, weekly OI change, a derived bias state, a synthesized scenario/outlook narrative, and an N‑week Flip% heat strip — all rendered in a compact Bloomberg amber terminal. The whole tool runs on one idea: raw NC net contracts mean nothing on their own — but when you can see 26‑week, 52‑week and 156‑week COT indices next to each other, the direction of last week's change, where OI is going, and how flip% has moved across the last eight weeks, positioning tells you exactly which end of the curve every market is at.

This is a positioning matrix, not a signal generator. It tells you which markets are stretched, which are turning, which are building fresh trend, and which are stuck in the middle — for equities, metals, energies, crypto, the dollar, and optionally FX crosses, softs and VIX, all on one screen.

🟢🔴 Summary how to use this more details below, read entire guide. Two clean reads: fade the extreme, or ride the build. Prefer markets tagged TOP RISK / BOTTOM SETUP for the fade, and markets tagged Building Long / Building Short with an aligned 52w index and OI expansion for the trend. The Scenario / Outlook column and the Flip% heat strip tell you at a glance whether positioning is at an inflection point or grinding in a regime. Runs on Daily or Weekly chart only.

⚠️ CHART TIMEFRAME — Weekly COT data is only accumulated on Daily or Weekly charts. Load this on any intraday chart and it will halt with a runtime error. Use Daily as the default; Weekly compresses the same view and works too.

🧱 CFTC Legacy — the only source of truth — Every row is pulled from the official CFTC Commitments of Traders Legacy report via TradingView's LibraryCOT, one release per week, Tuesday for the prior Tuesday's snapshot. You choose Futures Only or Futures and Options at the top of the settings. Nothing here is estimated, projected or derived from price — the whole grid is real reported contracts.

📐 24-Market Universe · 12 Active at a Time — Twelve markets ship enabled by default: ES · NQ · YM · RTY · NKD · GC · SI · HG · CL · NG · BTC · DX. Twelve more sit hidden and ready: 6E · 6J · 6B · 6A · 6C · 6S · ETH · PL · ZW · ZC · ZS · VX.

⚠️ HARD 12-MARKET CAP — TradingView caps the number of external data requests a script can make, and this dashboard uses five requests per market (OI + NC longs + NC shorts + Com longs + Com shorts). Twelve markets is the ceiling — any market you toggle on beyond that limit is silently skipped in list order.

▪️ To swap in a hidden market: first DISABLE at least one of the 12 default markets (e.g. turn off NKD or DX), then ENABLE the hidden one you want (e.g. 6E Euro FX or ETH Ether).
▪️ If you toggle on a hidden symbol and it doesn't appear on the dashboard, you're over the 12-market cap — go back and switch off one of the defaults first.
▪️ The two groups in settings are just organizational — the cap applies across both groups combined.

BTC / NQ / GC snapshot

🏷️ The Column Set — Every market gets its own row. Left to right:
▪️ Market — ticker + full name.
▪️ NC Net — Non‑Commercial net position in contracts (longs − shorts). The core large-spec read.
▪️ ΔNet W — change in NC net vs the prior COT week. This is the momentum column.
▪️ L% / S% — NC longs and shorts as % of open interest. Concentration read.
▪️ Flip% — NC Long% − Short%. Positive = specs net long, negative = specs net short. The regime tag.
▪️ Ix26 / Ix52 / Ix3Y — COT stochastic indices of NC net over 26, 52 and 156 weeks. 0 = most short in the window, 100 = most long. Ix52 is the year-context read; Ix3Y is the cycle read.
▪️ Com Net / CIx52 (optional) — Commercial net and its 52-week index. Hedgers usually sit opposite the specs — when they don't, that's a signal.
▪️ ΔOI% — weekly open interest change. Rising OI + rising net = real build; falling OI + rising net = short-covering, not conviction.
▪️ Bias — one-word positioning state: TOP RISK, BOTTOM SETUP, Building Long, Building Short, or a neutral trend tag. Colored by conviction.
▪️ Scenario / Outlook — a synthesized read that fuses extremes, streaks, regime flips, OI mechanics and cycle divergence into one line. HOVER the cell for the full narrative.
◆ Flip% Heat Strip — the signature panel — Set the strip to N weeks (up to 12) and every row gains N extra cells — one per prior COT week — heat-mapped on an amber/red axis around zero. Positive flip% (specs net long) burns amber; negative (specs net short) burns red; intensity scales to the flip scale you set. Read left to right along a row and you see the last 2-3 months of positioning at a glance:

▪️ A row that goes red → red → red → dim → amber → amber has just flipped regime from net-short to net-long.
▪️ A row that stays deep amber for 8 weeks is a crowded long — the fade candidate.
▪️ A row of soft mixed colors is regime chop — leave it alone.

XAU / DX / SI snapshot

🔥 The Bias Engine — Every row is auto-graded into a positioning state:
▪️ TOP RISK — 52w NC index at an extreme high and specs crowded long. The fade candidate.
▪️ BOTTOM SETUP — 52w NC index at an extreme low and specs crowded short. The mean-reversion setup.
▪️ Building Long / Building Short — indices are trending in one direction with OI expansion. The ride-the-build read.
▪️ Neutral trend tags — for markets sitting mid-range without directional conviction.

TOP RISK burns red, BOTTOM SETUP burns amber-hot, builds burn steady amber, neutral goes dim. You are reading the state of every market with your peripheral vision before you read a single number.

📋 Bloomberg Amber Terminal — Pure black background, amber-gradient text, alternating row shading, monospaced font, thin dark-amber frame, muted header row. Numeric coloring is gradient-driven — COT indices burn hotter at extremes, signed values shift from amber to red as they turn negative, flip% cells run their own heat map. Weekly release dates render in a compact format so the whole grid stays scannable.

🔔 Native Alerts — Alert on 52w COT Index Extremes fires once per new COT week when any market's NC 52w index crosses into the ≥80 zone (spec long extreme) or ≤20 zone (spec short extreme). One alert covers every enabled market — you get a message with the ticker, the direction and the index level. Enable it once and the dashboard tells you when a positioning inflection has actually printed, not before.

ES / CL / RTY snapshot

🔧 Fully Customizable — 12+12 market toggles, Futures Only vs Futures and Options source, max weekly history stored, dashboard position/size, text size, top offset padding, Commercial columns on/off, Flip% heat strip length 0-12 and its scale, alert toggle, and the entire Bloomberg amber palette flows automatically from the theme — nothing to fight with.

🎯 Why this is different — Most COT tools give you one market on a subchart with a couple of moving averages, or a wall of numbers with no visual weighting. This one pulls 12 markets into a single grid, indexes each of them across three timescales, tags the state, writes an outlook line, and heat-strips the last 8-12 weeks of flip% into a row you can read horizontally. The chart itself does the filtering — you see instantly which two or three markets deserve deeper work this week.

🚀 Apply on a Daily or Weekly chart of any symbol — the dashboard is independent of the chart symbol, so load it on your favorite index or continuous futures contract and it will fill regardless.

🎯 How To Trade It — Two Approaches

Everything hinges on the bias state and the index columns. Raw NC Net alone is noise; a market tagged TOP RISK with Ix52 ≥ 80 and 6 straight amber weeks in the heat strip is where the real information sits.

◾ 1 FADE THE EXTREME — trade the reversion
This is the classic COT read. Specs are crowded to one side, indices are pinned near an extreme, and the Bias column has flagged it.
▪️ Setup: a market tagged TOP RISK or BOTTOM SETUP, with Ix52 ≥ 80 or ≤ 20, and the Flip% heat strip showing several consecutive weeks in the same regime (crowd conviction). CIx52 pointing opposite (commercials leaning the other way) strengthens the read.
▪️ Trigger: this dashboard is not the trigger. Go to the chart of that market and wait for your own reversal confirmation — price rejection, structure break, momentum divergence.
▪️ Stop: beyond the most recent swing that made the extreme.
▪️ Targets: mean-reversion targets — the 52w index moving back through 50, or price returning to a mid-range value area.

⚖️ The cleanest version: NC Ix52 ≥ 85, Com Ix52 ≤ 15 (they disagree hard), Flip% has been extreme for 6+ weeks in the heat strip, and ΔNet W just printed its first meaningful flip against the trend. That's a positioning exhaustion signal.
◾ 2 RIDE THE BUILD — trade with the trend
The mirror case, and the one that matters when nothing is extreme yet.
▪️ Setup: a market tagged Building Long or Building Short. NC net is trending, ΔNet W has been consistently positive (or negative), ΔOI% is expanding (real money coming in, not short-covering), and the Flip% heat strip shows a clean color gradient in one direction.
▪️ Trigger: enter on your chart in the direction of the build on any of your own continuation setups.
▪️ Stop: on a decisive break of the ongoing structure.
▪️ Targets: run it until the Bias column flips to TOP RISK / BOTTOM SETUP — that is your exit warning. Positioning has become the trade instead of driving it.

⚖️ Watch ΔOI%. A build with rising OI is a real institutional position; a build with falling OI is specs chasing an old move — those don't last.
Rule of thumb: ⭐ Market tagged TOP RISK / BOTTOM SETUP with an extreme Ix52 → prepare to fade on price confirmation. ⭐ Market tagged Building X with expanding OI and a clean heat strip → trade continuation with the build. ⭐ Anything mid-range, no color in the heat strip, neutral bias → no trade, look elsewhere.

⚠️ IMPORTANT NOTICE: Strong COT Report Dashboard [Bloomberg] renders CFTC Legacy COT data and derives descriptive positioning states from it. The Bias column, the Scenario / Outlook narrative and the 0-100 COT indices are descriptive conviction readouts built from reported positioning — they are not backtested win-rates, and this indicator tracks no trade outcomes and reports no performance statistics. COT data is released weekly with a Tuesday-for-Tuesday delay, so the dashboard is a structural read, not a real-time signal. This is decision support, not a standalone trade trigger. Always combine it with your own strategy, price-action confirmation and risk management. Past positioning does not guarantee future results.

## Source Code

````pine
//@version=6
import TradingView/LibraryCOT/2 as cot

indicator("Strong COT Report Dashboard", overlay = true, dynamic_requests = true)

if timeframe.in_seconds() < timeframe.in_seconds("D")
    runtime.error("COT data is weekly — please switch to a Daily or Weekly chart")

grpData = "COT Data"
i_src   = input.string("Futures Only", "Report Data", options = ["Futures Only", "Futures and Options"], group = grpData)
i_weeks = input.int(200, "Max Weeks Stored", minval = 60, maxval = 400, group = grpData, tooltip = "Weekly history window kept for COT index calculations. 156+ needed for the 3-year index.")

grpMkts = "Markets"
showES  = input.bool(true, "ES  — S&P 500 E-mini",   group = grpMkts)
showNQ  = input.bool(true, "NQ  — Nasdaq 100 E-mini", group = grpMkts)
showYM  = input.bool(true, "YM  — Dow Jones",         group = grpMkts)
showRTY = input.bool(true, "RTY — Russell 2000",      group = grpMkts)
showNKD = input.bool(true, "NKD — Nikkei 225",        group = grpMkts)
showGC  = input.bool(true, "GC  — Gold",              group = grpMkts)
showSI  = input.bool(true, "SI  — Silver",            group = grpMkts)
showHG  = input.bool(true, "HG  — Copper",            group = grpMkts)
showCL  = input.bool(true, "CL  — Crude Oil WTI",     group = grpMkts)
showNG  = input.bool(true, "NG  — Natural Gas",       group = grpMkts)
showBTC = input.bool(true, "BTC — Bitcoin",           group = grpMkts)
showDX  = input.bool(true, "DX  — US Dollar Index",   group = grpMkts)

grpMkt2 = "Markets — FX / Ags / More (max 12 active in total)"
showEUR = input.bool(false, "6E  — Euro FX",          group = grpMkt2)
showJPY = input.bool(false, "6J  — Japanese Yen",     group = grpMkt2)
showGBP = input.bool(false, "6B  — British Pound",    group = grpMkt2)
showAUD = input.bool(false, "6A  — Australian Dollar", group = grpMkt2)
showCAD = input.bool(false, "6C  — Canadian Dollar",  group = grpMkt2)
showCHF = input.bool(false, "6S  — Swiss Franc",      group = grpMkt2)
showETH = input.bool(false, "ETH — Ether",            group = grpMkt2)
showPL  = input.bool(false, "PL  — Platinum",         group = grpMkt2)
showZW  = input.bool(false, "ZW  — Wheat",            group = grpMkt2)
showZC  = input.bool(false, "ZC  — Corn",             group = grpMkt2)
showZS  = input.bool(false, "ZS  — Soybeans",         group = grpMkt2)
showVX  = input.bool(false, "VX  — VIX Futures",      group = grpMkt2)

grpTbl  = "Dashboard"
yPos    = input.string("Top",    "Table Position", options = ["Top", "Middle", "Bottom"], inline = "p", group = grpTbl)
xPos    = input.string("Right",  "",               options = ["Right", "Center", "Left"], inline = "p", group = grpTbl)
txtIn   = input.string("Small",  "Text Size",      options = ["Tiny", "Small", "Normal", "Large"], group = grpTbl)
showCom = input.bool(true, "Show Commercial Columns", group = grpTbl)
heatWks = input.int(8, "Flip% Heat Strip Weeks", minval = 0, maxval = 12, group = grpTbl, tooltip = "0 hides the heat strip. Each cell is one prior week of NC Flip% (net spec positioning as % of open interest).")
flipScl = input.float(35.0, "Flip% Heat Scale", minval = 5.0, step = 5.0, group = grpTbl)
topPad  = input.int(2, "Top Offset Rows", minval = 0, maxval = 6, group = grpTbl, tooltip = "Invisible spacer rows above the dashboard so the chart's indicator name / status line doesn't cover the title and headers. Applied only when Table Position is Top.")

grpAlr  = "Alerts"
doAlert = input.bool(true, "Alert on 52w COT Index Extremes", group = grpAlr, tooltip = "Fires once per new COT week when a market's Non-Commercial 52w index enters the >=80 or <=20 zone.")

txtSize  = txtIn == "Tiny" ? size.tiny : txtIn == "Small" ? size.small : txtIn == "Large" ? size.large : size.normal
tablePos = yPos == "Top"    and xPos == "Right"  ? position.top_right     :
           yPos == "Top"    and xPos == "Center" ? position.top_center    :
           yPos == "Top"    and xPos == "Left"   ? position.top_left      :
           yPos == "Middle" and xPos == "Right"  ? position.middle_right  :
           yPos == "Middle" and xPos == "Center" ? position.middle_center :
           yPos == "Middle" and xPos == "Left"   ? position.middle_left   :
           yPos == "Bottom" and xPos == "Right"  ? position.bottom_right  :
           yPos == "Bottom" and xPos == "Center" ? position.bottom_center : position.bottom_left

C_BG     = #0A0A0A
C_TITLE  = #FFB000
C_HEADER = #FFA028
C_HDR_BG = #1C1206
C_FRAME  = #3A2A0E
C_ROW_A  = #0E0B05
C_ROW_B  = #17110A
C_NUM    = #8A7A52
C_TICKER = #FFC24D
C_NAME   = #C9A86A
C_STAT   = #E0B85E
C_HOT    = #FFD23F
C_WARM   = #FF9500
C_MID    = #C29A3E
C_COOL   = #C77A4A
C_COLD   = #E0552E
C_RED    = #FF3B30
C_DIM    = #6E6048

getRowColor(int row) => row % 2 == 0 ? C_ROW_A : C_ROW_B

f_idxColor(float v) =>
    na(v)     ? C_DIM  :
     v >= 80  ? C_HOT  :
     v >= 60  ? C_TITLE :
     v >= 40  ? C_MID  :
     v >= 20  ? C_COOL : C_RED

f_sgnColor(float v) =>
    na(v)    ? C_DIM  :
     v >= 15 ? C_HOT  :
     v >= 5  ? C_TITLE :
     v >= 0  ? C_MID  :
     v > -5  ? C_COOL :
     v > -15 ? C_COLD : C_RED

f_heatBg(float v, float scl) =>
    if na(v)
        color.new(C_BG, 0)
    else
        float x = math.max(math.min(v / math.max(scl, 1.0), 1.0), -1.0)
        x >= 0 ? color.from_gradient(x, 0.0, 1.0, #241804, #FFB000) :
                 color.from_gradient(-x, 0.0, 1.0, #1C0906, #C81E14)

f_heatTxt(float v, float scl) =>
    na(v) ? C_DIM : math.abs(v) / math.max(scl, 1.0) > 0.55 ? color.black : C_STAT

f_k(float v) =>
    na(v) ? "-" :
     math.abs(v) >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" :
     math.abs(v) >= 1e3 ? str.tostring(v / 1e3, "#.#") + "K"  :
     str.tostring(v, "#")

f_kSgn(float v) => na(v) ? "-" : (v > 0 ? "+" : "") + f_k(v)
f_pct(float v)  => na(v) ? "-" : str.tostring(v, "#.#") + "%"
f_pctSgn(float v) => na(v) ? "-" : (v > 0 ? "+" : "") + str.tostring(v, "#.#") + "%"
f_idx(float v)  => na(v) ? "-" : str.tostring(v, "#")
f_date(int t)   => na(t) ? "-" : str.format_time(t, "dd MMM yyyy", syminfo.timezone)

int N_MKT = 24
var array<string> mktTick = array.from("ES", "NQ", "YM", "RTY", "NKD", "GC", "SI", "HG", "CL", "NG", "BTC", "DX", "6E", "6J", "6B", "6A", "6C", "6S", "ETH", "PL", "ZW", "ZC", "ZS", "VX")
var array<string> mktName = array.from("S&P 500 E-mini", "Nasdaq 100 E-mini", "Dow Jones", "Russell 2000", "Nikkei 225", "Gold", "Silver", "Copper", "Crude Oil WTI", "Natural Gas", "Bitcoin", "US Dollar Idx", "Euro FX", "Japanese Yen", "British Pound", "Australian Dlr", "Canadian Dlr", "Swiss Franc", "Ether", "Platinum", "Wheat", "Corn", "Soybeans", "VIX Futures")
var array<string> mktCode = array.from("13874A", "209742", "12460+", "239742", "240741", "088691", "084691", "085692", "067651", "023651", "133741", "098662", "099741", "097741", "096742", "232741", "090741", "092741", "146021", "076651", "001602", "002602", "005602", "1170E1")

bool incOpt = i_src == "Futures and Options"

f_req(string code, string metric, string dir) =>
    float v = na
    if code != ""
        string t = cot.COTTickerid(COTType = "Legacy", CFTCCode = code, includeOptions = incOpt, metricName = metric, metricDirection = dir, metricType = "All")
        v := request.security(t, "W", close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
    v

f_fetch(string code) =>
    float oi  = f_req(code, "Open Interest", "No direction")
    float ncl = f_req(code, "Noncommercial Positions", "Long")
    float ncs = f_req(code, "Noncommercial Positions", "Short")
    float cml = f_req(code, "Commercial Positions", "Long")
    float cms = f_req(code, "Commercial Positions", "Short")
    [oi, ncl, ncs, cml, cms]

int maxMkts = 12
int n0  = 0
bool ok1  = showES  and n0  < maxMkts
int n1  = n0  + (ok1  ? 1 : 0)
bool ok2  = showNQ  and n1  < maxMkts
int n2  = n1  + (ok2  ? 1 : 0)
bool ok3  = showYM  and n2  < maxMkts
int n3  = n2  + (ok3  ? 1 : 0)
bool ok4  = showRTY and n3  < maxMkts
int n4  = n3  + (ok4  ? 1 : 0)
bool ok5  = showNKD and n4  < maxMkts
int n5  = n4  + (ok5  ? 1 : 0)
bool ok6  = showGC  and n5  < maxMkts
int n6  = n5  + (ok6  ? 1 : 0)
bool ok7  = showSI  and n6  < maxMkts
int n7  = n6  + (ok7  ? 1 : 0)
bool ok8  = showHG  and n7  < maxMkts
int n8  = n7  + (ok8  ? 1 : 0)
bool ok9  = showCL  and n8  < maxMkts
int n9  = n8  + (ok9  ? 1 : 0)
bool ok10 = showNG  and n9  < maxMkts
int n10 = n9  + (ok10 ? 1 : 0)
bool ok11 = showBTC and n10 < maxMkts
int n11 = n10 + (ok11 ? 1 : 0)
bool ok12 = showDX  and n11 < maxMkts
int n12 = n11 + (ok12 ? 1 : 0)
bool ok13 = showEUR and n12 < maxMkts
int n13 = n12 + (ok13 ? 1 : 0)
bool ok14 = showJPY and n13 < maxMkts
int n14 = n13 + (ok14 ? 1 : 0)
bool ok15 = showGBP and n14 < maxMkts
int n15 = n14 + (ok15 ? 1 : 0)
bool ok16 = showAUD and n15 < maxMkts
int n16 = n15 + (ok16 ? 1 : 0)
bool ok17 = showCAD and n16 < maxMkts
int n17 = n16 + (ok17 ? 1 : 0)
bool ok18 = showCHF and n17 < maxMkts
int n18 = n17 + (ok18 ? 1 : 0)
bool ok19 = showETH and n18 < maxMkts
int n19 = n18 + (ok19 ? 1 : 0)
bool ok20 = showPL  and n19 < maxMkts
int n20 = n19 + (ok20 ? 1 : 0)
bool ok21 = showZW  and n20 < maxMkts
int n21 = n20 + (ok21 ? 1 : 0)
bool ok22 = showZC  and n21 < maxMkts
int n22 = n21 + (ok22 ? 1 : 0)
bool ok23 = showZS  and n22 < maxMkts
int n23 = n22 + (ok23 ? 1 : 0)
bool ok24 = showVX  and n23 < maxMkts
int n24 = n23 + (ok24 ? 1 : 0)
int reqCnt = (showES ? 1 : 0) + (showNQ ? 1 : 0) + (showYM ? 1 : 0) + (showRTY ? 1 : 0) + (showNKD ? 1 : 0) + (showGC ? 1 : 0) + (showSI ? 1 : 0) + (showHG ? 1 : 0) + (showCL ? 1 : 0) + (showNG ? 1 : 0) + (showBTC ? 1 : 0) + (showDX ? 1 : 0) + (showEUR ? 1 : 0) + (showJPY ? 1 : 0) + (showGBP ? 1 : 0) + (showAUD ? 1 : 0) + (showCAD ? 1 : 0) + (showCHF ? 1 : 0) + (showETH ? 1 : 0) + (showPL ? 1 : 0) + (showZW ? 1 : 0) + (showZC ? 1 : 0) + (showZS ? 1 : 0) + (showVX ? 1 : 0)
int skipped = reqCnt - n24

[oi1,  ncl1,  ncs1,  cml1,  cms1]  = f_fetch(ok1  ? "13874A" : "")
[oi2,  ncl2,  ncs2,  cml2,  cms2]  = f_fetch(ok2  ? "209742" : "")
[oi3,  ncl3,  ncs3,  cml3,  cms3]  = f_fetch(ok3  ? "12460+" : "")
[oi4,  ncl4,  ncs4,  cml4,  cms4]  = f_fetch(ok4  ? "239742" : "")
[oi5,  ncl5,  ncs5,  cml5,  cms5]  = f_fetch(ok5  ? "240741" : "")
[oi6,  ncl6,  ncs6,  cml6,  cms6]  = f_fetch(ok6  ? "088691" : "")
[oi7,  ncl7,  ncs7,  cml7,  cms7]  = f_fetch(ok7  ? "084691" : "")
[oi8,  ncl8,  ncs8,  cml8,  cms8]  = f_fetch(ok8  ? "085692" : "")
[oi9,  ncl9,  ncs9,  cml9,  cms9]  = f_fetch(ok9  ? "067651" : "")
[oi10, ncl10, ncs10, cml10, cms10] = f_fetch(ok10 ? "023651" : "")
[oi11, ncl11, ncs11, cml11, cms11] = f_fetch(ok11 ? "133741" : "")
[oi12, ncl12, ncs12, cml12, cms12] = f_fetch(ok12 ? "098662" : "")
[oi13, ncl13, ncs13, cml13, cms13] = f_fetch(ok13 ? "099741" : "")
[oi14, ncl14, ncs14, cml14, cms14] = f_fetch(ok14 ? "097741" : "")
[oi15, ncl15, ncs15, cml15, cms15] = f_fetch(ok15 ? "096742" : "")
[oi16, ncl16, ncs16, cml16, cms16] = f_fetch(ok16 ? "232741" : "")
[oi17, ncl17, ncs17, cml17, cms17] = f_fetch(ok17 ? "090741" : "")
[oi18, ncl18, ncs18, cml18, cms18] = f_fetch(ok18 ? "092741" : "")
[oi19, ncl19, ncs19, cml19, cms19] = f_fetch(ok19 ? "146021" : "")
[oi20, ncl20, ncs20, cml20, cms20] = f_fetch(ok20 ? "076651" : "")
[oi21, ncl21, ncs21, cml21, cms21] = f_fetch(ok21 ? "001602" : "")
[oi22, ncl22, ncs22, cml22, cms22] = f_fetch(ok22 ? "002602" : "")
[oi23, ncl23, ncs23, cml23, cms23] = f_fetch(ok23 ? "005602" : "")
[oi24, ncl24, ncs24, cml24, cms24] = f_fetch(ok24 ? "1170E1" : "")

oiArr  = array.from(oi1, oi2, oi3, oi4, oi5, oi6, oi7, oi8, oi9, oi10, oi11, oi12, oi13, oi14, oi15, oi16, oi17, oi18, oi19, oi20, oi21, oi22, oi23, oi24)
nclArr = array.from(ncl1, ncl2, ncl3, ncl4, ncl5, ncl6, ncl7, ncl8, ncl9, ncl10, ncl11, ncl12, ncl13, ncl14, ncl15, ncl16, ncl17, ncl18, ncl19, ncl20, ncl21, ncl22, ncl23, ncl24)
ncsArr = array.from(ncs1, ncs2, ncs3, ncs4, ncs5, ncs6, ncs7, ncs8, ncs9, ncs10, ncs11, ncs12, ncs13, ncs14, ncs15, ncs16, ncs17, ncs18, ncs19, ncs20, ncs21, ncs22, ncs23, ncs24)
cmlArr = array.from(cml1, cml2, cml3, cml4, cml5, cml6, cml7, cml8, cml9, cml10, cml11, cml12, cml13, cml14, cml15, cml16, cml17, cml18, cml19, cml20, cml21, cml22, cml23, cml24)
cmsArr = array.from(cms1, cms2, cms3, cms4, cms5, cms6, cms7, cms8, cms9, cms10, cms11, cms12, cms13, cms14, cms15, cms16, cms17, cms18, cms19, cms20, cms21, cms22, cms23, cms24)
shwArr = array.from(ok1, ok2, ok3, ok4, ok5, ok6, ok7, ok8, ok9, ok10, ok11, ok12, ok13, ok14, ok15, ok16, ok17, ok18, ok19, ok20, ok21, ok22, ok23, ok24)

ncNetArr  = array.new_float(N_MKT, na)
comNetArr = array.new_float(N_MKT, na)
ncFlipArr = array.new_float(N_MKT, na)
ncLpArr   = array.new_float(N_MKT, na)
ncSpArr   = array.new_float(N_MKT, na)
for r = 0 to N_MKT - 1
    float oi  = array.get(oiArr, r)
    float nl  = array.get(nclArr, r)
    float ns  = array.get(ncsArr, r)
    float cl  = array.get(cmlArr, r)
    float cs  = array.get(cmsArr, r)
    array.set(ncNetArr,  r, nl - ns)
    array.set(comNetArr, r, cl - cs)
    if not na(oi) and oi > 0
        array.set(ncLpArr,   r, nl / oi * 100.0)
        array.set(ncSpArr,   r, ns / oi * 100.0)
        array.set(ncFlipArr, r, (nl - ns) / oi * 100.0)

var matrix<float> ncNetM  = matrix.new<float>(N_MKT, 0)
var matrix<float> comNetM = matrix.new<float>(N_MKT, 0)
var matrix<float> ncFlipM = matrix.new<float>(N_MKT, 0)
var matrix<float> oiM     = matrix.new<float>(N_MKT, 0)
var array<int>    weekT   = array.new_int()

bool newWeek = timeframe.change("W") or barstate.isfirst

if newWeek
    matrix.add_col(ncNetM,  0, ncNetArr)
    matrix.add_col(comNetM, 0, comNetArr)
    matrix.add_col(ncFlipM, 0, ncFlipArr)
    matrix.add_col(oiM,     0, oiArr)
    array.unshift(weekT, time("W"))
    if matrix.columns(ncNetM) > i_weeks
        matrix.remove_col(ncNetM,  matrix.columns(ncNetM)  - 1)
        matrix.remove_col(comNetM, matrix.columns(comNetM) - 1)
        matrix.remove_col(ncFlipM, matrix.columns(ncFlipM) - 1)
        matrix.remove_col(oiM,     matrix.columns(oiM)     - 1)
        array.pop(weekT)
else if matrix.columns(ncNetM) > 0
    for r = 0 to N_MKT - 1
        matrix.set(ncNetM,  r, 0, array.get(ncNetArr,  r))
        matrix.set(comNetM, r, 0, array.get(comNetArr, r))
        matrix.set(ncFlipM, r, 0, array.get(ncFlipArr, r))
        matrix.set(oiM,     r, 0, array.get(oiArr,     r))

f_get(matrix<float> m, int r, int c) =>
    c >= 0 and c < matrix.columns(m) ? matrix.get(m, r, c) : na

f_cotIndex(matrix<float> m, int r, int len, int off) =>
    float res = na
    int nc = matrix.columns(m)
    if nc > off
        int last = math.min(off + len - 1, nc - 1)
        float v = matrix.get(m, r, off)
        if not na(v)
            float lo = na
            float hi = na
            int cnt = 0
            for c = off to last
                float x = matrix.get(m, r, c)
                if not na(x)
                    cnt += 1
                    lo := na(lo) or x < lo ? x : lo
                    hi := na(hi) or x > hi ? x : hi
            if cnt >= 8
                res := hi == lo ? 50.0 : (v - lo) / (hi - lo) * 100.0
    res

f_bias(float ncIdx, float comIdx, float flip, float dNet) =>
    string b = "NEUTRAL"
    if not na(ncIdx)
        float ci = na(comIdx) ? 100.0 - ncIdx : comIdx
        if ncIdx >= 80 and ci <= 20
            b := "TOP RISK"
        else if ncIdx <= 20 and ci >= 80
            b := "BOTTOM SETUP"
        else if ncIdx >= 55 and flip > 0 and dNet > 0
            b := "BULL TREND"
        else if ncIdx <= 45 and flip < 0 and dNet < 0
            b := "BEAR TREND"
        else if not na(dNet) and dNet > 0 and ncIdx > 50
            b := "LONG BUILD"
        else if not na(dNet) and dNet < 0 and ncIdx < 50
            b := "SHORT BUILD"
    b

f_biasColor(string b) =>
    b == "TOP RISK"     ? C_RED  :
     b == "BOTTOM SETUP" ? C_HOT  :
     b == "BULL TREND"   ? C_TITLE :
     b == "BEAR TREND"   ? C_COLD :
     b == "LONG BUILD"   ? C_MID  :
     b == "SHORT BUILD"  ? C_COOL : C_DIM

f_netStreak(matrix<float> m, int r) =>
    int s = 0
    int nc = matrix.columns(m)
    if nc >= 2
        float d0 = matrix.get(m, r, 0) - matrix.get(m, r, 1)
        if not na(d0) and d0 != 0
            int sgn = d0 > 0 ? 1 : -1
            s := sgn
            for c = 1 to math.min(nc - 2, 7)
                float d = matrix.get(m, r, c) - matrix.get(m, r, c + 1)
                if na(d) or (d > 0 ? 1 : d < 0 ? -1 : 0) != sgn
                    break
                s += sgn
    s

f_flipAge(matrix<float> m, int r) =>
    int age = 999
    int nc = matrix.columns(m)
    if nc >= 2
        float f0 = matrix.get(m, r, 0)
        if not na(f0)
            int sgn = f0 >= 0 ? 1 : -1
            for c = 1 to math.min(nc - 1, 12)
                float f = matrix.get(m, r, c)
                if not na(f) and (f >= 0 ? 1 : -1) != sgn
                    age := c
                    break
    age

f_scenario(float ix26, float ix52, float ix156, float cix52, float flip, float dNet, int stk, int fAge, float dOi) =>
    string lbl = "BALANCED"
    color  cl  = C_DIM
    string tip = "No dominant positioning force — spec and commercial books are mid-range and weekly flows are small. COT offers no edge here this week; defer to price structure."
    if na(ix52)
        lbl := "AWAITING DATA"
        cl  := C_NUM
        tip := "Not enough weekly COT history accumulated yet for index calculations (8+ weeks minimum; the 52w and 3yr indices need more). Keep the chart on Daily/Weekly and let history build."
    else
        float ci = na(cix52) ? 100.0 - ix52 : cix52
        string pos = "Specs " + f_idx(ix52) + "/100 of 52w range, commercials " + f_idx(ci) + "/100. Net Δ " + f_kSgn(dNet) + (stk >= 2 ? " — " + str.tostring(stk) + "w build streak" : stk <= -2 ? " — " + str.tostring(-stk) + "w reduce streak" : "") + ". OI " + f_pctSgn(dOi) + " w/w.  »  "
        if ix52 >= 90 and ci <= 10
            lbl := "BLOW-OFF RISK"
            cl  := C_RED
            tip := pos + "Crowded late-cycle configuration: speculators near max-long against hedgers near max-short. Continuation needs ever-new buyers; the larger asymmetry is a long-liquidation flush. Trigger to watch: ΔNet turning negative."
        else if ix52 <= 10 and ci >= 90
            lbl := "CAPITULATION LOW"
            cl  := C_HOT
            tip := pos + "Washout configuration: speculators near max-short while hedgers are near max-long. Downside is running out of new sellers and the short base is squeeze fuel. Trigger to watch: ΔNet turning positive."
        else if ix52 >= 75 and dNet < 0 and stk <= -2
            lbl := "LONG UNWIND"
            cl  := C_COLD
            tip := pos + "Specs are cutting longs from an elevated 52w extreme — early-stage distribution. Falling OI alongside would confirm liquidation rather than rotation. Pressure persists while the reduce streak runs."
        else if ix52 <= 25 and dNet > 0 and stk >= 2
            lbl := "SHORT SQUEEZE"
            cl  := C_TITLE
            tip := pos + "Shorts are covering off a 52w extreme — this produces the sharpest rallies inside downtrends. Durable only if OI turns up (new longs entering); with OI falling it is covering-only and tends to fade."
        else if fAge <= 4
            lbl := flip >= 0 ? "FLIPPED LONG" : "FLIPPED SHORT"
            cl  := C_TICKER
            tip := pos + "Regime change: speculators crossed to net " + (flip >= 0 ? "LONG" : "SHORT") + " " + str.tostring(fAge) + " week(s) ago. Fresh flips mark early trend phases — positioning has room to build before it becomes crowded. Directional bias follows the new sign while the flip holds."
        else if stk >= 4 and dOi > 0
            lbl := "TREND: NEW LONGS"
            cl  := C_TITLE
            tip := pos + "Persistent long accumulation with rising open interest = fresh money funding the move, not repositioning. Historically trend-supportive while the build streak and OI expansion continue."
        else if stk <= -4 and dOi > 0
            lbl := "TREND: NEW SHORTS"
            cl  := C_COLD
            tip := pos + "Persistent short accumulation with rising open interest = fresh money pressing the downside. Bearish-trend confirmation while the streak and OI expansion continue."
        else if dOi < 0 and dNet < 0 and ix52 > 50
            lbl := "LONG LIQUIDATION"
            cl  := C_COOL
            tip := pos + "Longs exiting with shrinking open interest — corrective de-risking rather than new bear conviction. Often resolves once the 52w index cools toward mid-range."
        else if dOi < 0 and dNet > 0 and ix52 < 50
            lbl := "SHORT COVERING"
            cl  := C_MID
            tip := pos + "Shorts closing with shrinking open interest — relief-rally mechanics, not fresh demand. Tends to stall unless OI turns positive with continued net buying."
        else if ix156 >= 70 and ix26 <= 30
            lbl := "DIP IN LONG CYCLE"
            cl  := C_MID
            tip := pos + "Short-term spec pullback (26w index depressed) inside a multi-year long build (3yr index elevated) — historically the zone where longer-cycle buyers reload. Counter-signal only if the 3yr index also breaks down."
        else if ix156 <= 30 and ix26 >= 70
            lbl := "POP IN SHORT CYCLE"
            cl  := C_COOL
            tip := pos + "Short-term long burst (26w index hot) inside a multi-year short regime (3yr index depressed) — counter-trend until the 52w index confirms a genuine turn."
        else
            tip := pos + tip
    [lbl, tip, cl]

var array<int> extState = array.new_int(N_MKT, 0)
if doAlert and newWeek and not barstate.isfirst
    for r = 0 to N_MKT - 1
        if array.get(shwArr, r)
            float idxNow = f_cotIndex(ncNetM, r, 52, 0)
            if not na(idxNow)
                int zone = idxNow >= 80 ? 1 : idxNow <= 20 ? -1 : 0
                if zone != 0 and zone != array.get(extState, r)
                    string nm = array.get(mktTick, r) + " " + array.get(mktName, r)
                    alert("COT: " + nm + " Non-Commercial 52w index " + (zone == 1 ? ">= 80 (spec long extreme)" : "<= 20 (spec short extreme)") + " at " + f_idx(idxNow), alert.freq_once_per_bar)
                array.set(extState, r, zone)

int  N_CORE  = 14
int  comHide = showCom ? 0 : 2
int  totCols = N_CORE - comHide + heatWks
int rowOff = yPos == "Top" ? topPad : 0
var table dash = table.new(tablePos, 27, N_MKT + 10, color.new(C_BG, 100), color.new(C_FRAME, 100), 0, color.new(C_FRAME, 100), 0)

f_hdr(int col, string txt, string tip) =>
    table.cell(dash, col, 1 + rowOff, txt, text_color = C_HEADER, bgcolor = C_HDR_BG, text_size = txtSize, text_halign = text.align_center, text_font_family = font.family_monospace, tooltip = tip)

if barstate.islast
    table.clear(dash, 0, 0, 26, N_MKT + 9)

    if rowOff > 0
        for i = 0 to rowOff - 1
            table.cell(dash, 0, i, " ", text_color = color.new(C_BG, 100), bgcolor = color.new(C_BG, 100), text_size = size.normal)

    table.cell(dash, 0, rowOff, "COT REPORT DASHBOARD — CFTC LEGACY | " + i_src, text_color = C_TITLE, bgcolor = C_BG, text_size = size.normal, text_halign = text.align_center, text_font_family = font.family_monospace)
    table.merge_cells(dash, 0, rowOff, totCols - 1, rowOff)

    f_hdr(0, "Market", "CFTC Legacy futures market")
    f_hdr(1, "NC Net", "Non-Commercial (large spec) net position: long - short contracts")
    f_hdr(2, "ΔNet W", "Change in NC net position vs prior COT week")
    f_hdr(3, "L%", "NC longs as % of open interest")
    f_hdr(4, "S%", "NC shorts as % of open interest")
    f_hdr(5, "Flip%", "NC Long% - Short%. Positive = specs net long")
    f_hdr(6, "Ix26", "COT index of NC net over 26 weeks (0 = most short, 100 = most long)")
    f_hdr(7, "Ix52", "COT index of NC net over 52 weeks (1 year)")
    f_hdr(8, "Ix3Y", "COT index of NC net over 156 weeks (3 years)")
    int col = 9
    if showCom
        f_hdr(col, "Com Net", "Commercial (hedger) net position: long - short contracts")
        f_hdr(col + 1, "CIx52", "COT index of Commercial net over 52 weeks")
        col += 2
    f_hdr(col, "ΔOI%", "Weekly open-interest change %")
    f_hdr(col + 1, "Bias", "Positioning read: extremes (TOP RISK / BOTTOM SETUP), trend, or build direction")
    f_hdr(col + 2, "Scenario / Outlook", "Synthesized read of all columns: extremes, streaks, regime flips, OI mechanics, cycle divergence. HOVER a cell for the full outlook narrative and reasoning.")
    col += 3
    if heatWks > 0
        for w = 0 to heatWks - 1
            f_hdr(col + w, "W-" + str.tostring(w + 1), "NC Flip% " + str.tostring(w + 1) + " week(s) ago")

    int vis = 0
    for r = 0 to N_MKT - 1
        if array.get(shwArr, r)
            int   row   = vis + 2 + rowOff
            color rowBg = getRowColor(vis)
            vis += 1

            float ncNet  = f_get(ncNetM,  r, 0)
            float dNet   = f_get(ncNetM,  r, 0) - f_get(ncNetM, r, 1)
            float lp     = array.get(ncLpArr, r)
            float sp     = array.get(ncSpArr, r)
            float flip   = f_get(ncFlipM, r, 0)
            float ix26   = f_cotIndex(ncNetM, r, 26, 0)
            float ix52   = f_cotIndex(ncNetM, r, 52, 0)
            float ix156  = f_cotIndex(ncNetM, r, 156, 0)
            float comNet = f_get(comNetM, r, 0)
            float cix52  = f_cotIndex(comNetM, r, 52, 0)
            float oi0    = f_get(oiM, r, 0)
            float oi1w   = f_get(oiM, r, 1)
            float dOiPct = not na(oi0) and not na(oi1w) and oi1w > 0 ? (oi0 - oi1w) / oi1w * 100.0 : na
            string bias  = f_bias(ix52, cix52, flip, dNet)
            int    stk   = f_netStreak(ncNetM, r)
            int    fAge  = f_flipAge(ncFlipM, r)
            [scnLbl, scnTip, scnCol] = f_scenario(ix26, ix52, ix156, cix52, flip, dNet, stk, fAge, dOiPct)
            bool noData  = na(ncNet)

            table.cell(dash, 0, row, array.get(mktTick, r) + "  " + array.get(mktName, r), text_color = C_TICKER, bgcolor = rowBg, text_size = txtSize, text_halign = text.align_left, text_font_family = font.family_monospace, tooltip = noData ? "No COT data returned — check symbol availability" : "CFTC code " + array.get(mktCode, r))
            table.cell(dash, 1, row, f_k(ncNet),      text_color = na(ncNet) ? C_DIM : ncNet >= 0 ? C_STAT : C_COLD, bgcolor = rowBg, text_size = txtSize, text_halign = text.align_right, text_font_family = font.family_monospace)
            table.cell(dash, 2, row, f_kSgn(dNet),    text_color = f_sgnColor(na(dNet) or na(ncNet) or ncNet == 0 ? na : dNet / math.max(math.abs(ncNet), 1.0) * 100.0), bgcolor = rowBg, text_size = txtSize, text_halign = text.align_right, text_font_family = font.family_monospace)
            table.cell(dash, 3, row, f_pct(lp),       text_color = C_STAT, bgcolor = rowBg, text_size = txtSize, text_halign = text.align_right, text_font_family = font.family_monospace)
            table.cell(dash, 4, row, f_pct(sp),       text_color = C_STAT, bgcolor = rowBg, text_size = txtSize, text_halign = text.align_right, text_font_family = font.family_monospace)
            table.cell(dash, 5, row, f_pctSgn(flip),  text_color = f_sgnColor(flip), bgcolor = rowBg, text_size = txtSize, text_halign = text.align_right, text_font_family = font.family_monospace)
            table.cell(dash, 6, row, f_idx(ix26),     text_color = f_idxColor(ix26),  bgcolor = rowBg, text_size = txtSize, text_halign = text.align_right, text_font_family = font.family_monospace)
            table.cell(dash, 7, row, f_idx(ix52),     text_color = f_idxColor(ix52),  bgcolor = rowBg, text_size = txtSize, text_halign = text.align_right, text_font_family = font.family_monospace)
            table.cell(dash, 8, row, f_idx(ix156),    text_color = f_idxColor(ix156), bgcolor = rowBg, text_size = txtSize, text_halign = text.align_right, text_font_family = font.family_monospace)
            int c2 = 9
            if showCom
                table.cell(dash, c2, row, f_k(comNet),     text_color = na(comNet) ? C_DIM : comNet >= 0 ? C_NAME : C_COOL, bgcolor = rowBg, text_size = txtSize, text_halign = text.align_right, text_font_family = font.family_monospace)
                table.cell(dash, c2 + 1, row, f_idx(cix52), text_color = f_idxColor(cix52), bgcolor = rowBg, text_size = txtSize, text_halign = text.align_right, text_font_family = font.family_monospace)
                c2 += 2
            table.cell(dash, c2, row, f_pctSgn(dOiPct), text_color = f_sgnColor(dOiPct), bgcolor = rowBg, text_size = txtSize, text_halign = text.align_right, text_font_family = font.family_monospace)
            table.cell(dash, c2 + 1, row, bias, text_color = f_biasColor(bias), bgcolor = rowBg, text_size = txtSize, text_halign = text.align_center, text_font_family = font.family_monospace, tooltip = "NC Ix52 " + f_idx(ix52) + " | Com Ix52 " + f_idx(cix52) + " | Flip " + f_pctSgn(flip))
            table.cell(dash, c2 + 2, row, scnLbl, text_color = scnCol, bgcolor = rowBg, text_size = txtSize, text_halign = text.align_left, text_font_family = font.family_monospace, tooltip = scnTip)
            c2 += 3
            if heatWks > 0
                for w = 0 to heatWks - 1
                    float hv = f_get(ncFlipM, r, w + 1)
                    table.cell(dash, c2 + w, row, f_pctSgn(hv), text_color = f_heatTxt(hv, flipScl), bgcolor = na(hv) ? rowBg : f_heatBg(hv, flipScl), text_size = txtSize, text_halign = text.align_center, text_font_family = font.family_monospace, tooltip = array.get(mktTick, r) + " NC Flip% " + str.tostring(w + 1) + "w ago")

    if vis == 0
        table.cell(dash, 0, 2 + rowOff, "Enable at least one market in Settings", text_color = C_NAME, bgcolor = C_ROW_A, text_size = txtSize, text_halign = text.align_left, text_font_family = font.family_monospace)

    int fRow = vis + 2 + rowOff
    int lastWk = array.size(weekT) > 0 ? array.get(weekT, 0) : na
    table.cell(dash, 0, fRow, "COT week: " + f_date(lastWk) + "  |  history: " + str.tostring(matrix.columns(ncNetM)) + "w stored  |  markets: " + str.tostring(vis) + "/12 active" + (skipped > 0 ? "  |  ⚠ " + str.tostring(skipped) + " market(s) skipped — max 12 active at once (data-request limit). Disable another market first." : "") + "  |  NC = large specs · Com = hedgers  |  index 0 = most short / 100 = most long in window", text_color = skipped > 0 ? C_WARM : C_NUM, bgcolor = C_HDR_BG, text_size = size.tiny, text_halign = text.align_left, text_font_family = font.family_monospace)
    table.merge_cells(dash, 0, fRow, totCols - 1, fRow)
````
