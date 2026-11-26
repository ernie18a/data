# Minsky Instability Clock [SpokoStocks]

- url: https://www.tradingview.com/script/yBrJ0Yuf-Minsky-Instability-Clock-SpokoStocks/
- type: indicator
- pine_id: PUB;5a5b876f5fdb41e5bc66f1108da25bdf
- version: 1.0

## Description

When does a boom become fragile? This Minsky-based clock turns 11 public macro indicators — credit, profits, yield curve, bank lending, credit spreads and AI capex — into one easy-to-read warning scoreboard.

"Stability is destabilizing." — Hyman P. Minsky

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OVERVIEW

The Minsky Instability Clock maps the US credit cycle through the lens of Hyman Minsky's Financial Instability Hypothesis. Long periods of calm encourage borrowing, borrowing fuels asset booms, and a boom becomes fragile once credit growth stops accelerating and financing conditions begin to tighten.

The script combines public macroeconomic data — household and corporate debt, asset prices, corporate profits, the yield curve, bank lending standards and credit spreads — into a single clock. It highlights the rare periods when a credit-fuelled boom is losing its financing. Historically, that has been the setting of the largest US equity drawdowns.

It is a macro regime tool, not a trading signal. It is designed for monthly or weekly charts of broad US equity indices such as the S&P 500.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

THE IDEA

Minsky argued that financial systems move from stability to fragility on their own. As confidence grows, borrowers move from "hedge" finance (income covers debt service) toward "speculative" and eventually "Ponzi" finance, which depends on rising asset prices and continuous new lending. A boom does not need credit to shrink in order to fail. It only needs credit growth to slow while the debt taken on during the boom still has to be serviced.

Michał Kalecki's profit equation adds the second leg: corporate debt stays healthy only while profits keep validating it. When profits roll over, lenders tighten and spreads widen, and the "Minsky moment" arrives.

The clock therefore asks two questions every month:
1. Has there been a genuine credit-plus-asset boom, and is that credit now decelerating? (the regime)
2. Are financing conditions starting to break? (the triggers)

Only when both are true does the clock enter its IMMINENT state.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW IT WORKS

1) CREDIT CYCLE — the Minsky regime

- Credit boom
The 3-year change in household debt/GDP or non-financial corporate debt/GDP ranks in the top 20% of its own history (Federal Reserve Z.1 Financial Accounts). Percentiles are expanding and point-in-time, so each reading is compared only with the history available at that moment.

- Asset boom
3-year growth in real (CPI-deflated) S&P 500 prices or real FHFA house prices ranks in the top third of its history.

- Pop window
Within 24 months of a combined credit and asset boom, a booming credit channel starts to decelerate: its credit impulse (the change in the growth of debt/GDP, smoothed over two quarters) turns negative. This is the phase in which the boom can no longer be financed at the pace it requires.

2) MINSKY-MOMENT TRIGGERS — financing stress

- Corporate profits below their level a year earlier (the Kalecki profit channel)
- Yield curve (10Y minus 3M) back above zero after an inversion in the previous 18 months
- Fed Senior Loan Officer Opinion Survey: net share of banks tightening business lending standards up 10+ points in 6 months
- ICE BofA US High Yield option-adjusted spread 1+ point above its 12-month low
- Moody's Baa corporate yield spread over 10-year Treasuries 0.3+ point above its 12-month low

3) IMMINENT STATE

IMMINENT = pop window open AND at least 2 triggers firing (adjustable from 1 to 5).

It combines a fragile regime with confirmed financing stress. In the historical data it has been rare — roughly seven episodes since the late 1980s — which is what makes it informative.

4) AI CYCLE MONITOR — context layer

The current AI infrastructure build-out is financed partly outside the credit aggregates above: hyperscaler bond issuance, private credit and off-balance-sheet data-centre vehicles. To keep this cycle visible, a separate context layer tracks:

- AI capex boom
The 3-year rise in IT-equipment investment relative to GDP ranks in its top 20%, while real semiconductor-index (SOX) growth ranks in its top third.

- Semiconductor break
The semiconductor index falls 15% or more against the equity index from its 12-month relative high.

- AI stress
Within 24 months of an AI capex boom, a semiconductor break occurs together with at least one financing trigger.

This layer is for monitoring only and does not feed the IMMINENT state. The closest historical analogue — the 1995–2001 telecom and internet capex cycle — does not provide enough independent cases to validate timing, and the rules tested did not improve historical reliability. It is labelled as context everywhere in the script.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HOW TO READ IT

PRICE CHART
- Pink background with a "◆ IMMINENT" label: pop window plus financing stress. Hover over the label to see which triggers were active when the state began. The pink deepens as more triggers fire.
- Optional amber background with a "◇ pop window" label: the credit boom is decelerating but financing stress is not yet confirmed.
- Optional cyan background with a "◇ AI stress" label: AI context layer.
By default only the IMMINENT state is drawn, keeping the price chart clean.

LOWER PANE — WARNING-LIGHT COLUMNS
The columns show how many of 11 warning lights are on (0–11):
- deep navy → steel blue → gold → red as lights accumulate
- amber when a pop window is open
- pink when the clock is IMMINENT
Dotted guides mark 3 and 6 lights. A thin edge line traces the count over time.

LOWER PANE — SCOREBOARD
A compact table shows each light with ✔ (calm) or ⚠ (warning) and its current reading, grouped as:

CREDIT CYCLE
- Household credit boom
- Corporate credit boom
- Asset boom (stocks / houses)
- Credit decelerating after boom (pop window)

FINANCING STRESS
- Corporate profits falling
- Yield curve un-inverted
- Banks tightening lending
- High-yield spread widening
- Baa spread widening

AI CYCLE (context)
- AI capex boom
- Semiconductors breaking vs index

The header shows the total (for example "3/11") and the current state. Every raw value is also available in TradingView's Data Window.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SETTINGS

Model
- Equity index used for the asset-boom test (default TVC:SPX)
- Triggers required for IMMINENT (default 2)
- Credit-impulse smoothing in quarters (default 2)

Price chart
- IMMINENT background and label (on)
- Pop-window background and label (off)
- Trigger-intensity shading (on)

AI cycle monitor
- Show in lower pane (on)
- AI-stress background and label on price chart (off)
- Semiconductor index symbol (default NASDAQ:SOX)

Lower pane
- Scoreboard on/off and position
- Warning-light columns on/off
- Optional detail curves on a 0–100 scale: credit fuel, financing stress, asset boom and AI capex gauge (switch off the columns to read them)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ALERTS

- IMMINENT started
- IMMINENT ended
- Pop window opened
- Trigger count increased
- Warning lights increased
- AI capex boom
- AI stress

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DATA AND NON-REPAINTING DESIGN

All inputs are public FRED series that update automatically on TradingView, so nothing needs to be entered by hand:
household debt (CMDEBT), non-financial corporate debt (BCNSDODNS), GDP, FHFA house price index (USSTHPI), CPI (CPIAUCSL), corporate profits (CP), 10-year and 3-month Treasury yields (GS10, TB3MS), Senior Loan Officer Survey (DRTSCILM), ICE BofA High Yield OAS (BAMLH0A0HYM2), Moody's Baa yield (DBAA) and IT-equipment investment (Y033RC1Q027SBEA), plus the chosen equity and semiconductor indices.

Each series is shifted by its publication lag (quarterly Z.1 and profit data are used two quarters later, for example), and all higher-timeframe requests read confirmed, completed periods only. Historical readings therefore reflect what was knowable at the time, and the signals do not repaint.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HISTORICAL BEHAVIOUR (educational context)

On monthly data the IMMINENT state appeared ahead of or near the start of the 1990, 2000–2002, 2007–2009 and 2022 declines. It has also produced false or early signals, for example in 2005 and 2014–2015.

By design it does not register shocks that were not preceded by a credit boom, such as 1987, 1998, 2020 and 2025. Before 1990 several bear markets were driven mainly by inflation and interest rates rather than credit, and those lie largely outside what this tool measures.

Design notes: several extensions were tested and deliberately left out because they did not improve historical reliability. These were margin-debt surges, faster monthly bank and consumer credit series, and an "equity boom plus financing stress without a credit boom" path. In the data, booms became fragile through broad credit growth, and the clock stays focused on that channel.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LIMITATIONS

- Macro data is revised and published with delays, so the clock moves slowly by design.
- There are few historical credit busts, so treat the state as context, not certainty.
- The AI Cycle Monitor has no historical validation and is labelled as context throughout.
- The script is built for the US economy and broad US equity indices.
- The script depends on TradingView's FRED data feeds; if a feed stops updating, the related reading stays at its last value.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REFERENCES

- Hyman P. Minsky — "The Financial Instability Hypothesis" (1992); Stabilizing an Unstable Economy (1986)
- Michał Kalecki — Theory of Economic Dynamics (profit equation)
- Robin Greenwood, Samuel G. Hanson, Andrei Shleifer, Jakob Ahm Sørensen — "Predictable Financial Crises", Journal of Finance (2022)
- Bank for International Settlements — research on credit-to-GDP gaps and on the financing of the AI infrastructure boom
- Federal Reserve Board — Z.1 Financial Accounts; Senior Loan Officer Opinion Survey

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DISCLAIMER

This script is for educational and research purposes only. It does not provide investment, financial or trading advice and does not recommend any action. Past behaviour of any indicator does not guarantee future results. Always do your own research.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SpokoStocks
//
// MINSKY INSTABILITY CLOCK [SpokoStocks]
// ─────────────────────────────────────────────────────────────────────────────────────────────
// Hyman Minsky: "stability is destabilizing". Long booms are financed by ever-faster borrowing;
// when that borrowing stops accelerating and financing conditions tighten, the boom loses its
// support. This script maps that sequence with public macro data.
//
// REGIME (credit cycle, Fed Z.1 data)
//   Credit boom   : 3-yr change in household or corporate debt/GDP in the top 20% of its own history
//   Asset boom    : 3-yr real S&P 500 or real house-price growth in the top third of its history
//   Pop window    : within 24 months of credit boom + asset boom, a booming credit channel decelerates
//
// MINSKY-MOMENT TRIGGERS (financing stress)
//   1 Corporate profits below a year earlier (Kalecki profit channel)
//   2 Yield curve 10Y-3M back above zero after an inversion in the last 18 months
//   3 Fed Senior Loan Officer Survey: net tightening up 10+ points in 6 months
//   4 High-yield OAS 1+ point above its 12-month low
//   5 Baa-Treasury spread 0.3+ point above its 12-month low
//
// IMMINENT = pop window open AND >= N triggers (default 2).
// In monthly history since the late 1980s this state has been rare (about 7 episodes) and has
// frequently overlapped with the start of large S&P 500 declines; it has also produced false
// signals, and it does not register shocks that were not preceded by a credit boom.
//
// Design note (equity-financed booms such as the AI cycle): margin-debt surges and an
// "equity boom + financing stress, without a credit boom" path were tested on 1952-2026 data and
// excluded, because neither improved historical reliability. In the data, booms became fragile
// through broad credit growth; this script therefore stays focused on that channel.
//
// AI CYCLE MONITOR (context layer — NOT part of IMMINENT, not historically validated)
//   AI capex boom : 3-yr rise in IT-equipment investment / GDP in its top 20% AND real semiconductor
//                   index (SOX) 3-yr growth in its top third
//   AI stress     : within 24 months of an AI capex boom, semiconductors fall 15%+ versus the equity
//                   index from their 12-month relative high AND at least 1 financing trigger fires
//   Built for the current AI build-out, which is financed partly outside the credit aggregates above
//   (hyperscaler bonds, private credit, off-balance-sheet vehicles). The closest analogue
//   (1995-2001 telecom/internet capex) does not provide enough independent cases to validate
//   timing: tested variants did not improve historical reliability. Shown for monitoring only.
//
// LOWER PANE
//   Scoreboard: 11 warning lights in 3 groups (credit cycle, financing stress, AI cycle), each OK or WARN.
//   Columns   : number of warning lights on (0-11). Pink when IMMINENT.
//   Optional detail curves (0-100 scale, switch off the count to read them):
//   Upward columns   = credit fuel (strongest credit channel, historical percentile 0-100)
//   Downward columns = financing stress (share of the 5 triggers firing)
//   Line             = asset boom (stronger of real stocks / real house prices, percentile)
//   Cyan line        = AI capex boom gauge (IT investment / GDP, 3-yr change percentile)
//   Colours: amber = pop window open, pink = IMMINENT
//
// NOTES
//   • All inputs are public FRED series that update automatically on TradingView; each is used
//     only after its publication lag (Z.1 ~ 2 quarters, profits ~ 2 quarters, survey ~ 1 quarter).
//   • Educational and research tool only. Not investment advice. Past behaviour of any
//     indicator does not guarantee future results.
// ─────────────────────────────────────────────────────────────────────────────────────────────
//@version=6
indicator("Minsky Instability Clock [SpokoStocks]", shorttitle="Minsky Clock [SpokoStocks]", overlay=false, max_labels_count=200)

// ============================ INPUTS ============================
gM = "Model"
eqSym     = input.symbol("TVC:SPX", "Equity index (asset-boom test)", group=gM)
needTrig  = input.int(2, "Triggers required for IMMINENT", minval=1, maxval=5, group=gM)
impSmooth = input.int(2, "Credit-impulse smoothing (quarters)", minval=1, maxval=4, group=gM)

gC = "Price chart"
bgImm  = input.bool(true,  "IMMINENT background", group=gC, inline="i")
lbImm  = input.bool(true,  "label", group=gC, inline="i")
bgAnt  = input.bool(false, "Pop-window background", group=gC, inline="a")
lbAnt  = input.bool(false, "label", group=gC, inline="a")
glow   = input.bool(true,  "Intensity scales with number of triggers", group=gC)
gA = "AI cycle monitor (context, not validated)"
aiOn   = input.bool(true,  "Show AI monitor in lower pane", group=gA)
bgAI   = input.bool(false, "AI-stress background on price chart", group=gA, inline="ai")
lbAI   = input.bool(false, "label", group=gA, inline="ai")
semiSym = input.symbol("NASDAQ:SOX", "Semiconductor index", group=gA)

gP = "Lower pane"
showBoard  = input.bool(true,  "Warning-light scoreboard", group=gP)
boardPos   = input.string("Top left", "Scoreboard position", options=["Top left", "Top right", "Bottom left", "Bottom right"], group=gP)
showCount  = input.bool(true,  "Warning-light count (columns)", group=gP)
showDetail = input.bool(false, "Detail curves (credit fuel / stress / asset / AI gauge, 0-100 scale)", group=gP)

cImm  = #d6249f
cPop  = #e67e22
cFuelLo = #1f3a4d
cFuelHi = #d4a017
cStress = #8e44ad
cAI     = #17c3d6

LA = barmerge.lookahead_on
f_xpct(x) =>
    var float[] h = array.new_float(0)
    float p = na
    if not na(x)
        array.push(h, x)
        int c = 0
        for v in h
            c += v <= x ? 1 : 0
        p := array.size(h) >= 40 ? float(c) / array.size(h) : na
    p

// ============================ REGIME ============================
f_credit() =>
    r   = close
    pct = f_xpct(r - r[12])
    imp = ta.sma((r - r[4]) - (r[4] - r[8]), impSmooth)
    [pct[2], imp[2]]
[hhPct, hhImp]     = request.security("FRED:CMDEBT/FRED:GDP", "3M", f_credit(), lookahead=LA)
[corpPct, corpImp] = request.security("FRED:BCNSDODNS/FRED:GDP", "3M", f_credit(), lookahead=LA)
f_hp() =>
    p = f_xpct(close / close[12] - 1)
    p[2]
f_eq() =>
    p = f_xpct(close / close[36] - 1)
    p[1]
hpPct = request.security("FRED:USSTHPI/FRED:CPIAUCSL", "3M", f_hp(), lookahead=LA)
eqPct = request.security(eqSym + "/FRED:CPIAUCSL", "M", f_eq(), lookahead=LA)

fragile = (hhPct >= 0.80 or corpPct >= 0.80) and (eqPct >= 0.67 or hpPct >= 0.67)
decel   = (hhPct >= 0.60 and hhImp < 0) or (corpPct >= 0.60 and corpImp < 0)
var float lastFragile = na
if fragile
    lastFragile := time
recentFragile = not na(lastFragile) and (time - lastFragile) <= 24 * 30.44 * 86400000
popWindow = recentFragile and decel

// ============================ TRIGGERS ============================
f_prof() =>
    v = close / close[4] - 1
    v[2]
profYoY = request.security("FRED:CP", "3M", f_prof(), lookahead=LA)
f_curve() =>
    v = ta.lowest(close, 18) < 0 and close > 0 ? 1.0 : 0.0
    v[1]
curveUninv = request.security("FRED:GS10-FRED:TB3MS", "M", f_curve(), lookahead=LA)
f_sloos() =>
    v = close - close[2]
    v[1]
sloosChg = request.security("FRED:DRTSCILM", "3M", f_sloos(), lookahead=LA)
f_widen() =>
    v = close - ta.lowest(close, 12)
    v[1]
hyWiden  = request.security("FRED:BAMLH0A0HYM2", "M", f_widen(), lookahead=LA)
baaWiden = request.security("FRED:DBAA-FRED:GS10", "M", f_widen(), lookahead=LA)


t1 = not na(profYoY) and profYoY < 0
t2 = curveUninv > 0
t3 = not na(sloosChg) and sloosChg >= 10
t4 = not na(hyWiden) and hyWiden >= 1.0
t5 = not na(baaWiden) and baaWiden >= 0.3
b(x) => x ? 1 : 0
nTrig = b(t1) + b(t2) + b(t3) + b(t4) + b(t5)

// ============================ STATE ============================
ready    = not na(hhPct) and not na(corpPct)
imminent = ready and popWindow and nTrig >= needTrig
popOnly  = ready and popWindow and not imminent

// ============================ AI CYCLE MONITOR ============================
f_itcap() =>
    p = f_xpct(close - close[12])
    p[2]
itPct = request.security("FRED:Y033RC1Q027SBEA/FRED:GDP", "3M", f_itcap(), lookahead=LA)
f_semiBoom() =>
    p = f_xpct(close / close[36] - 1)
    p[1]
semiPct = request.security(semiSym + "/FRED:CPIAUCSL", "M", f_semiBoom(), lookahead=LA)
f_rel() =>
    v = close / ta.highest(close, 12) - 1
    v[1]
semiRelDD = request.security(semiSym + "/" + eqSym, "M", f_rel(), lookahead=LA)
aiBoom = not na(itPct) and not na(semiPct) and itPct >= 0.80 and semiPct >= 0.67
var float lastAiBoom = na
if aiBoom
    lastAiBoom := time
aiRecent = not na(lastAiBoom) and (time - lastAiBoom) <= 24 * 30.44 * 86400000
aiStress = aiRecent and not na(semiRelDD) and semiRelDD <= -0.15 and nTrig >= 1

// ============================ PRICE CHART ============================
immAlpha = glow ? math.max(45, 78 - (nTrig - needTrig) * 8) : 62
bgcolor(bgImm and imminent ? color.new(cImm, immAlpha) : na, title="IMMINENT window", force_overlay=true)
bgcolor(bgAnt and popOnly ? color.new(cPop, 82) : na, title="Pop window", force_overlay=true)
bgcolor(bgAI and aiStress and not imminent ? color.new(cAI, 80) : na, title="AI stress (context)", force_overlay=true)

trigList() =>
    s = ""
    s += t1 ? "• Corporate profits below a year earlier\n" : ""
    s += t2 ? "• Yield curve un-inverted\n" : ""
    s += t3 ? "• Banks tightening lending standards\n" : ""
    s += t4 ? "• High-yield spread widening\n" : ""
    s += t5 ? "• Baa spread widening\n" : ""
    s

if lbImm and imminent and not imminent[1]
    label.new(bar_index, high, "◆ IMMINENT", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down,
         color=cImm, textcolor=color.white, size=size.small, force_overlay=true,
         tooltip="Minsky pop window + " + str.tostring(nTrig) + "/5 financing-stress triggers:\n" + trigList())
if lbAI and aiStress and not aiStress[1]
    label.new(bar_index, high, "◇ AI stress", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down,
         color=cAI, textcolor=color.black, size=size.tiny, force_overlay=true,
         tooltip="AI capex boom in last 24m + semiconductors " + str.tostring(semiRelDD * 100, "#") + "% vs index from 12m relative high + " + str.tostring(nTrig) + " financing trigger(s). Context only; not historically validated.")
if lbAnt and popWindow and not popWindow[1]
    label.new(bar_index, high, "◇ pop window", xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down,
         color=cPop, textcolor=color.white, size=size.tiny, force_overlay=true,
         tooltip="Credit boom decelerating within 24 months of a credit + asset boom.")

// ============================ LOWER PANE ============================
// ---- warning lights ----
w1  = hhPct >= 0.80                                    // household credit boom
w2  = corpPct >= 0.80                                  // corporate credit boom
w3  = eqPct >= 0.67 or hpPct >= 0.67                   // asset boom
w4  = popWindow                                        // credit decelerating after boom
w5  = t1
w6  = t2
w7  = t3
w8  = t4
w9  = t5
w10 = aiBoom or aiRecent                               // AI capex boom (now or within 24m)
w11 = not na(semiRelDD) and semiRelDD <= -0.15         // semis breaking vs index
nWarn = b(w1) + b(w2) + b(w3) + b(w4) + b(w5) + b(w6) + b(w7) + b(w8) + b(w9) + b(w10) + b(w11)
cntCol = imminent ? cImm : nWarn >= 6 ? #c0392b : nWarn >= 3 ? #e67e22 : #1e9e6a

plot(showCount ? nWarn : na, "Warning lights on (0-11)", color=color.new(cntCol, 15), style=plot.style_columns)
hline(3, "3 lights", color=color.new(#e67e22, 60), linestyle=hline.style_dotted)
hline(6, "6 lights", color=color.new(#c0392b, 60), linestyle=hline.style_dotted)

// ---- optional detail curves ----
fuel   = math.max(nz(hhPct), nz(corpPct)) * 100
stress = -nTrig / 5.0 * 100
fuelCol   = imminent ? cImm : popWindow ? cPop : color.from_gradient(fuel, 40, 100, cFuelLo, cFuelHi)
stressCol = imminent ? cImm : nTrig > 0 ? color.new(cStress, 100 - nTrig * 17) : color.new(cStress, 90)
plot(ready and showDetail ? fuel : na,     "Credit fuel (pct)",      color=fuelCol,   style=plot.style_columns)
plot(ready and showDetail ? stress : na, "Financing stress (-%)",  color=stressCol, style=plot.style_columns)
plot(ready and showDetail ? math.max(nz(eqPct), nz(hpPct)) * 100 : na, "Asset boom (pct)", color=color.new(color.silver, 40), linewidth=1)
plot(showDetail and aiOn and not na(itPct) ? itPct * 100 : na, "AI capex boom gauge (pct)", color=aiRecent ? cAI : color.new(cAI, 55), linewidth=2)
plot(showDetail and aiOn and aiStress ? 100 : na, "AI stress", color=cAI, style=plot.style_circles, linewidth=3)
bgcolor(imminent ? color.new(cImm, 88) : (aiOn and aiStress) ? color.new(cAI, 90) : na, title="State (pane)")

// ---- scoreboard ----
bPos = boardPos == "Top left" ? position.top_left : boardPos == "Top right" ? position.top_right : boardPos == "Bottom left" ? position.bottom_left : position.bottom_right
var table sb = table.new(bPos, 3, 16, border_width=0, frame_width=1, frame_color=color.new(color.gray, 70))
cOK   = color.new(#1e9e6a, 0)
cWR   = color.new(#e74c3c, 0)
cHead = color.new(color.gray, 40)
bgT   = color.new(color.black, 55)
pcs(x) => na(x) ? "n/a" : str.tostring(x * 100, "#") + "th pct"
light(r, name, on, val) =>
    table.cell(sb, 0, r, on ? "⚠" : "✔", text_color=on ? cWR : cOK, bgcolor=bgT, text_size=size.small)
    table.cell(sb, 1, r, name, text_color=on ? color.white : color.silver, bgcolor=bgT, text_size=size.small, text_halign=text.align_left)
    table.cell(sb, 2, r, val, text_color=color.silver, bgcolor=bgT, text_size=size.tiny, text_halign=text.align_right)
header(r, txt) =>
    table.cell(sb, 0, r, "", bgcolor=bgT)
    table.cell(sb, 1, r, txt, text_color=cHead, bgcolor=bgT, text_size=size.tiny, text_halign=text.align_left)
    table.cell(sb, 2, r, "", bgcolor=bgT)
if showBoard and barstate.islast
    stTxt = imminent ? "IMMINENT" : popWindow ? "POP WINDOW" : aiStress ? "AI STRESS (context)" : "No IMMINENT signal"
    table.cell(sb, 0, 0, str.tostring(nWarn) + "/11", text_color=color.white, bgcolor=cntCol, text_size=size.normal)
    table.cell(sb, 1, 0, "warning lights on", text_color=color.white, bgcolor=cntCol, text_size=size.small, text_halign=text.align_left)
    table.cell(sb, 2, 0, stTxt, text_color=color.white, bgcolor=imminent ? cImm : cntCol, text_size=size.small)
    header(1, "CREDIT CYCLE (Minsky regime)")
    light(2,  "Household credit boom", w1, pcs(hhPct))
    light(3,  "Corporate credit boom", w2, pcs(corpPct))
    light(4,  "Asset boom (stocks / houses)", w3, pcs(math.max(nz(eqPct), nz(hpPct))))
    light(5,  "Credit decelerating after boom", w4, popWindow ? "pop window" : "no")
    header(6, "FINANCING STRESS (triggers)")
    light(7,  "Corporate profits falling", w5, na(profYoY) ? "n/a" : str.tostring(profYoY * 100, "#.#") + "% YoY")
    light(8,  "Yield curve un-inverted", w6, t2 ? "yes" : "no")
    light(9,  "Banks tightening lending", w7, na(sloosChg) ? "n/a" : str.tostring(sloosChg, "#.#") + " pts")
    light(10, "High-yield spread widening", w8, na(hyWiden) ? "n/a" : "+" + str.tostring(hyWiden, "#.##"))
    light(11, "Baa spread widening", w9, na(baaWiden) ? "n/a" : "+" + str.tostring(baaWiden, "#.##"))
    header(12, "AI CYCLE (context)")
    light(13, "AI capex boom", w10, pcs(itPct))
    light(14, "Semis breaking vs index", w11, na(semiRelDD) ? "n/a" : str.tostring(semiRelDD * 100, "#") + "%")
    table.cell(sb, 0, 15, "", bgcolor=bgT)
    table.cell(sb, 1, 15, "IMMINENT needs: pop window + " + str.tostring(needTrig) + " stress lights", text_color=cHead, bgcolor=bgT, text_size=size.tiny, text_halign=text.align_left)
    table.cell(sb, 2, 15, "", bgcolor=bgT)

// values for the Data Window (hover), not drawn
plot(nTrig, "Triggers firing (0-5)", display=display.data_window)
plot(hhPct * 100, "Household credit pct", display=display.data_window)
plot(corpPct * 100, "Corporate credit pct", display=display.data_window)
plot(profYoY * 100, "Corporate profits YoY %", display=display.data_window)
plot(sloosChg, "Loan-standards tightening 6m chg", display=display.data_window)
plot(hyWiden, "HY OAS vs 12m low", display=display.data_window)
plot(baaWiden, "Baa spread vs 12m low", display=display.data_window)
plot(semiPct * 100, "Real semiconductor 3y growth pct", display=display.data_window)
plot(semiRelDD * 100, "Semis vs index from 12m rel. high %", display=display.data_window)

// ============================ ALERTS ============================
alertcondition(imminent and not imminent[1], "IMMINENT started", "Minsky Instability Clock: pop window + financing-stress triggers.")
alertcondition(not imminent and imminent[1], "IMMINENT ended", "Minsky Instability Clock: IMMINENT state ended.")
alertcondition(popWindow and not popWindow[1], "Pop window opened", "Minsky Instability Clock: pop window opened.")
alertcondition(aiBoom and not aiBoom[1], "AI capex boom", "Minsky Instability Clock: AI capex boom conditions (context layer).")
alertcondition(aiStress and not aiStress[1], "AI stress", "Minsky Instability Clock: AI capex boom + semiconductor relative break + financing stress (context layer, not validated).")
alertcondition(nWarn > nWarn[1], "Warning lights increased", "Minsky Instability Clock: another warning light turned on.")
alertcondition(nTrig > nTrig[1], "Trigger count increased", "Minsky Instability Clock: another financing-stress trigger is firing.")
````
