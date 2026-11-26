# Fair Value Studio engine paths scenario rails - ClaudeVibe

- url: https://www.tradingview.com/script/L5Eo0yMH-Fair-Value-Studio-engine-paths-scenario-rails-ClaudeVibe/
- type: indicator
- pine_id: PUB;be3606853eab4b92b88f5de1b375251a
- version: 1.0

## Description

***attempting to fill the gap between "autonomous-AI-research >INPUT*GAP*> chart-autofill"
open to collaboration if you are like-minded.***

your AI model > outputs the below FV rail paths for the stock of interest.
or you know, make a better AI script yourself to share for the retail community who want to get involved. advocacy for community driven investing>institutions.

refine it, make it quarterly when trying to find potential short term inflections.

Pine Script v6 — Fair Value Studio v4.1 rail cards
Paste each comma-separated string into the matching rail-card path input (2-decimal, 2026→2035). Leave blank to fall back to the CAGR shown.
// BEAR   (start 137.00 · CAGR 10.50%)
137.00,151.38,167.28,184.84,204.25,225.70,249.40,275.59,304.52,336.50

// BASE   (start 330.00 · CAGR 9.50%)
330.00,361.35,395.68,433.27,474.43,519.50,568.85,622.89,682.07,746.86

// BULL   (start 545.00 · CAGR 9.00%)
545.00,594.05,647.51,705.79,769.31,838.55,914.02,996.28,1085.95,1183.68

// BLUESKY  (start 864.00 · CAGR 8.50%)
864.00,937.44,1017.12,1103.58,1197.38,1299.16,1409.59,1529.40,1659.40,1800.45
Anchor inputs:
start_year   = 2026
end_year     = 2035
spot_ref     = 362.00
bear_cagr    = 0.105
base_cagr    = 0.095
bull_cagr    = 0.090
bluesky_cagr = 0.085
Two notes on construction so the rails behave the way you expect: the paths are intrinsic value compounding at each scenario's cost of equity, not a price forecast — they answer "what do I earn if this thesis is correct and the multiple holds," which is why bear still slopes up (a $137 fair value still accretes at 10.5%; the bear loss is the −62% gap to spot today, not a declining rail). And because GOOG's shareholder yield is now ~0.2% and net-dilutive post-raise, I let the rails accrete at the full CoE with no yield drag — if you want the rails to reflect the dilution explicitly, knock ~30–50bps off each CAGR for the ATM/convert overhang and the bear/base rails flatten meaningfully.
The chart's history line is illustrative (hits both 52-week extremes and the current 4-week pullback) — drop real OHLC into CONFIG.history and the log-regression channel refits automatically. 
What it is
It's a TradingView indicator that overlays valuation on top of price. Most charting tools show you what a stock has done; this one draws what it's arguably worth — today and projected forward — so you can see at a glance whether price is running ahead of or behind fundamentals. It's built for someone who does their own valuation work (DCF, multiples) and wants those outputs living on the chart instead of in a spreadsheet.
The core idea: two ways to value a stock
The indicator can either figure out a fair value itself, or take yours.
Automatic mode reads the company's financials from TradingView's data feed — earnings, free cash flow, EBITDA, debt, margins — and classifies the business by sector. A bank gets valued on earnings at ~12x; a heavy/capital-intensive name (energy, utilities, REITs) gets valued on EBITDA on an enterprise basis; a profitable tech company gets valued on free cash flow at a richer multiple, and so on. It picks the metric, the multiple, and the method that fit the business type, then draws the resulting fair value as a line across the price history. A built-in "outlier guard" stops a single weird quarter from throwing the whole thing off.
Manual / studio mode is for when you've done the work elsewhere. You type in a "fair value now" number, and optionally paste forward paths — your own year-by-year fair-value estimates for several scenarios. This matters because the automatic trailing-multiple approach is genuinely poor for certain companies: anything mid-ramp, heavily leveraged, or reinvesting so hard that current earnings understate the business. For those, the indicator will actually flag itself with a warning and tell you to paste a real model.
The headline feature: scenario rails
This is what makes it useful for decision-making. You define four scenarios — bear, base, bull, and a "blue-sky" upside — and the indicator projects each one forward as a "rail" stretching years into the future. You can drive each rail two ways:

Paste a path: a comma-separated list of dollar values, one per year (e.g. 330, 361, 396, 433...). The rail traces exactly those points. This is for when you've modeled each year explicitly.
CAGR fallback: just give a growth rate per scenario, and the rail compounds forward at that rate. Simpler, less precise.

On top of the four scenarios it draws a probability-weighted rail — you assign odds to each scenario (say 25% bear, 40% base, 25% bull, 10% blue-sky) and it blends them into one expected path. It also draws a grey market-implied rail, which just grows today's price at your cost of equity. That grey line is your benchmark: if your weighted rail sits above it, the stock offers more than the return you'd demand; below it, you're not being paid enough for the risk.
Reading the output
Beyond the lines, there's a summary table in the corner that does the arithmetic for you. The single most useful row is the IRR for each scenario — the annualized return you'd earn buying at today's price and reaching that scenario's target over your chosen horizon. It also shows the premium or discount of price versus fair value, what data it used, and whether any guards or warnings fired. There are crossover alerts too, so you can be notified when price crosses through fair value rather than watching the chart.
How someone would actually use it
The honest workflow is: add it to a chart, and if the company is a clean, profitable, stable business, let automatic mode give you a quick read. If it's a complex name — a turnaround, a heavy reinvestor, something with a real growth story — do your valuation elsewhere, then come back and paste your scenario paths and a fair-value anchor. Set your scenario probabilities to match your actual conviction (the defaults are just placeholders — change them). Then look at the weighted IRR and where price sits relative to the rails.
What to be careful about
A few honest limitations worth stating up front. The automatic valuation is a trailing-multiple model — it values the company on what it earned recently, which says nothing about where it's going; treat it as a rough sanity check, not a thesis. The forward rails are only as good as the assumptions you feed them — a beautifully drawn rail built on a wishful growth rate is just a wishful guess with better production values. And one structural quirk: all the scenario rails fan out from a single anchor point, so if your scenarios genuinely start from different intrinsic values, the early years are slightly stylized (the long-run targets and IRRs are unaffected). It's a framework for organizing and visualizing your own judgment — it doesn't replace the judgment.

## Source Code

````pine
//@version=6
indicator("Fair Value Studio v4.1 — engine paths + scenario rails", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
//  v4.1 CHANGES vs v4:
//   - NEW "Forward model" group: paste a per-year fair-value PATH per
//     scenario (comma-sep $, year 1..N) computed in the studio/chat.
//     Falls back to CAGR per-scenario when a path field is blank.
//   - NEW manual "Fair value now $" anchor (FCFF output) — when set,
//     rails start there and the trailing-multiple historical fair line
//     is suppressed (it's low-fit for ramp/levered names). The log-
//     regression channel remains as the historical relative-level read.
//   - Summary table + IRRs now read the path terminal values.
//  Everything else (auto-classifier, regression channel, guard) intact.
// ============================================================

// ---- Palette ----
cGreen = #97C459
cAmber = #EF9F27
cRed   = #F09595
cPurple= #9A90F0
cInk   = #E8E5DE
cTeal  = #5FB8A0
cGrey  = #8A8780

// ---- Inputs: mode ----
gM      = "Mode"
modeSel = input.string("Auto (classify by fundamentals)", "Config source", options=["Auto (classify by fundamentals)","Manual override"], group=gM)
per     = input.string("TTM", "Reporting period", options=["TTM","FY"], group=gM)
fairMode= input.string("Blend", "Multiple basis", options=["Fixed","Normal","Blend"], group=gM)
smoothN = input.int(1, "Smoothing (reports, 1=off)", minval=1, maxval=8, group=gM)

// ---- Inputs: manual override / fallback ----
gO      = "Manual override"
oMetric = input.string("EPS", "Metric", options=["EPS","Free cash flow","EBITDA"], group=gO)
oMult   = input.float(15.0, "Fair multiple x", minval=0.1, group=gO)
oEnt    = input.bool(false, "Enterprise (subtract net debt/sh)", group=gO)
oPS     = input.float(0.0, "Manual per-share $ (0 = use feed)", group=gO)
oND     = input.float(0.0, "Manual net debt/sh $", group=gO)

// ---- Inputs: outlier guard ----
gG      = "Outlier guard"
clampOn = input.bool(true, "Clamp metric spikes", group=gG)
clampLen= input.int(36, "Reference window (bars)", minval=6, group=gG)
loBand  = input.float(0.3, "Lower band x avg", group=gG)
hiBand  = input.float(3.0, "Upper band x avg", group=gG)

// ---- Inputs: forward model (PASTE FROM STUDIO/CHAT) ----
gF       = "Forward model (paste from studio)"
fwdSrc   = input.string("Path then CAGR fallback", "Forward source", options=["Path then CAGR fallback","CAGR only"], group=gF)
fvManual = input.float(0.0, "Fair value now $ (0 = use computed metric)", group=gF)
sBear    = input.string("", "Bear path ($/sh, comma, yr1..N)", group=gF)
sBase    = input.string("", "Base path ($/sh, comma, yr1..N)", group=gF)
sBull    = input.string("", "Bull path ($/sh, comma, yr1..N)", group=gF)
sBlue    = input.string("", "Blue-sky path ($/sh, comma, yr1..N)", group=gF)

// ---- Inputs: scenario rails (CAGR fallback) ----
gS      = "Scenario rails (CAGR fallback)"
projYrs = input.int(10, "Project forward (yrs)", minval=1, maxval=12, group=gS)
gBear   = input.float(-6.0, "Bear CAGR %", group=gS)
gBase   = input.float( 8.0, "Base CAGR %", group=gS)
gBull   = input.float(16.0, "Bull CAGR %", group=gS)
gBlue   = input.float(26.0, "Blue-sky CAGR %", group=gS)
wBear   = input.float(0.25, "Weight bear", group=gS)
wBase   = input.float(0.45, "Weight base", group=gS)
wBull   = input.float(0.22, "Weight bull", group=gS)
wBlue   = input.float(0.08, "Weight blue", group=gS)
Ke      = input.float(9.0, "Cost of equity % (mkt path)", group=gS)
divYld  = input.float(0.0, "Dividend yield %", group=gS)

// ---- Inputs: display ----
gD      = "Display"
showHist= input.bool(true, "Historical fair / normal lines", group=gD)
showReg = input.bool(true, "Log-regression ±2σ channel", group=gD)
regLen  = input.int(48, "Regression lookback (bars)", minval=10, group=gD)
showFill= input.bool(true, "Shade price vs fair value", group=gD)
showLbls= input.bool(true, "Rail labels ($ + YoY%)", group=gD)
showTbl = input.bool(true, "Summary table", group=gD)

tkr = str.upper(syminfo.ticker)

// ============================================================
//  GLOBAL HELPERS  (all flush-left — never inside a block)
// ============================================================
F(id) =>
    v = request.financial(syminfo.tickerid, id, per, ignore_invalid_symbol=true)
    var float held = na
    held := na(v) ? held : v
    held

perSh(shares, x) => na(shares) or shares == 0 or na(x) ? na : x / shares

irr(term, base, yrs) => na(term) or na(base) or base <= 0 ? na : math.pow(term / base, 1.0 / yrs) - 1

pct(x) => na(x) ? "n/a" : (x >= 0 ? "+" : "") + str.tostring(x * 100, "#.#") + "%"

mkL(arr, x1, y1, x2, y2, col, sty, w) => array.push(arr, line.new(x1, y1, x2, y2, xloc=xloc.bar_time, color=col, style=sty, width=w))

mkT(arr, x, y, txt, col, sty, sz) => array.push(arr, label.new(x, y, txt, xloc=xloc.bar_time, style=sty, color=color.new(col, 100), textcolor=col, size=sz))

tcell(tb, i, k, v, c) =>
    table.cell(tb, 0, i, k, text_color=cGrey, text_size=size.small, text_halign=text.align_left)
    table.cell(tb, 1, i, v, text_color=c,     text_size=size.small, text_halign=text.align_right)

parsePath(s) =>
    out = array.new_float()
    ss = na(s) ? "" : str.tostring(s)
    if str.length(ss) > 0
        parts = str.split(ss, ",")
        for p in parts
            v = str.tonumber(str.replace_all(p, " ", ""))
            if not na(v)
                array.push(out, v)
    out

railVal(pathArr, fvNow, g, t) =>
    n = array.size(pathArr)
    n >= t ? array.get(pathArr, t - 1) : n > 0 ? array.get(pathArr, n - 1) * math.pow(1 + g / 100, t - n) : fvNow * math.pow(1 + g / 100, t)

// ============================================================
//  AUTO-CLASSIFIER
// ============================================================
classify(secStr, profit, fcfPos, gMar, levRat) =>
    isEnergy = str.contains(secStr,"energy") or str.contains(secStr,"mineral") or str.contains(secStr,"oil") or str.contains(secStr,"mining") or str.contains(secStr,"metal")
    isFin    = str.contains(secStr,"financ") or str.contains(secStr,"bank") or str.contains(secStr,"insur")
    isReit   = str.contains(secStr,"reit") or str.contains(secStr,"real estate")
    isUtil   = str.contains(secStr,"utilit")
    isTech   = str.contains(secStr,"technolog") or str.contains(secStr,"software") or str.contains(secStr,"semiconduct")
    heavy    = isReit or isUtil or isEnergy

    autoMet = isFin ? "EPS" : heavy ? "EBITDA" : (isTech and fcfPos) ? "Free cash flow" : profit ? "EPS" : fcfPos ? "Free cash flow" : "EBITDA"
    baseMul = isFin ? 12.0 : heavy ? 9.0 : (isTech and fcfPos) ? 22.0 : profit ? 18.0 : fcfPos ? 16.0 : 9.0
    autoEnt = heavy or (not profit and not fcfPos)
    nudged  = baseMul * (not na(gMar) and gMar > 0.6 ? 1.1 : 1.0)
    autoMul = math.max(4.0, math.min(40.0, nudged))
    badFit  = (not profit and not fcfPos) or (not na(levRat) and levRat > 6.0)

    manual = modeSel != "Auto (classify by fundamentals)"
    mMet = manual ? oMetric : autoMet
    mMul = manual ? oMult   : autoMul
    mEnt = manual ? oEnt    : autoEnt
    mPS  = manual ? (oPS <= 0 ? na : oPS) : na
    mND  = manual ? oND     : na
    mFit = manual ? "manual" : badFit ? "low-fit->studio" : "auto"
    mNrm = manual ? true : not badFit
    [mMet, mMul, mEnt, mPS, mND, mFit, mNrm]

// ============================================================
//  FINANCIAL READS + SIGNALS
// ============================================================
sh   = F("TOTAL_SHARES_OUTSTANDING")
ni   = F("NET_INCOME")
fcf  = F("FREE_CASH_FLOW")
ebt  = F("EBITDA")
debt = F("TOTAL_DEBT")
csh  = F("CASH_N_SHORT_TERM_INVEST")
rev  = F("TOTAL_REVENUE")
gp   = F("GROSS_PROFIT")

profit = not na(ni)  and ni  > 0
fcfPos = not na(fcf) and fcf > 0
gMar   = na(gp) or na(rev) or rev == 0 ? na : gp / rev
levRat = na(debt) or na(ebt) or ebt <= 0 ? na : debt / ebt
secStr = str.lower(syminfo.sector + " " + syminfo.industry)

[pMet, pMul, pEnt, pPS, pND, pFit, pNrm] = classify(secStr, profit, fcfPos, gMar, levRat)
isStudio = str.contains(pFit, "studio")

// ============================================================
//  METRIC PER SHARE
// ============================================================
feedPS = pMet == "EPS" ? perSh(sh, ni) : pMet == "Free cash flow" ? perSh(sh, fcf) : perSh(sh, ebt)
psPre  = not na(pPS) ? pPS : (smoothN > 1 ? ta.sma(feedPS, smoothN) : feedPS)

refPS   = ta.sma(psPre, clampLen)
clamped = clampOn and not na(psPre) and not na(refPS) and (psPre > refPS * hiBand or psPre < refPS * loBand)
psEff   = not clampOn or na(psPre) or na(refPS) ? psPre : math.max(refPS * loBand, math.min(refPS * hiBand, psPre))
src     = not na(pPS) ? "preset/manual" : not na(feedPS) ? "feed" : "no data"

ndFeed = perSh(sh, (na(debt) ? 0.0 : debt) - (na(csh) ? 0.0 : csh))
ndEff  = not na(pPS) ? (na(pND) ? 0.0 : pND) : (na(ndFeed) ? 0.0 : ndFeed)

// ============================================================
//  FAIR / NORMAL VALUE
// ============================================================
curMult  = na(psEff) or psEff <= 0 ? na : close / psEff
normMult = pNrm ? ta.sma(curMult, 60) : na
effMult  = na(normMult) ? pMul : fairMode == "Normal" ? normMult : fairMode == "Blend" ? (pMul + normMult) / 2 : pMul

fv = na(psEff) or psEff <= 0 ? na : psEff * effMult - (pEnt ? ndEff : 0.0)
fv := na(fv) or fv <= 0 ? na : fv
nv = na(psEff) or psEff <= 0 or na(normMult) ? na : psEff * normMult - (pEnt ? ndEff : 0.0)
nv := na(nv) or nv <= 0 ? na : nv

manualFwd = fvManual > 0
fvAnchor  = manualFwd ? fvManual : fv

// ============================================================
//  PLOTS
// ============================================================
pP  = plot(close, "Price", color=color.new(cTeal, 0), linewidth=2)
pFV = plot(showHist and not manualFwd ? fv : na, "Fair value", color=color.new(cAmber, 0), linewidth=2, style=plot.style_stepline)
plot(showHist and not manualFwd ? nv : na, "Normal value", color=color.new(cPurple, 30), linewidth=2, style=plot.style_stepline)
fillCol = (not showFill) or manualFwd or na(fv) ? na : (close < fv ? color.new(cGreen, 82) : color.new(cRed, 86))
fill(pP, pFV, color=fillCol)

logc = math.log(close)
reg  = ta.linreg(logc, regLen, 0)
sdv  = ta.stdev(logc - reg, regLen)
plot(showReg ? math.exp(reg) : na, "Reg mid", color=color.new(cPurple, 40), linewidth=1)
pu = plot(showReg ? math.exp(reg + 2 * sdv) : na, "Reg +2σ", color=color.new(cPurple, 70), linewidth=1)
pd = plot(showReg ? math.exp(reg - 2 * sdv) : na, "Reg -2σ", color=color.new(cPurple, 70), linewidth=1)
fill(pu, pd, color=showReg ? color.new(cPurple, 93) : na)

// ============================================================
//  FORWARD SCENARIO RAILS
// ============================================================
var line[]  LL = array.new_line()
var label[] BL = array.new_label()
var float tvBear = na
var float tvBase = na
var float tvBull = na
var float tvBlue = na
var float tvWtd  = na

if barstate.islast and not na(fvAnchor)
    for l in LL
        line.delete(l)
    array.clear(LL)
    for b in BL
        label.delete(b)
    array.clear(BL)

    bearA = fwdSrc == "CAGR only" ? array.new_float() : parsePath(sBear)
    baseA = fwdSrc == "CAGR only" ? array.new_float() : parsePath(sBase)
    bullA = fwdSrc == "CAGR only" ? array.new_float() : parsePath(sBull)
    blueA = fwdSrc == "CAGR only" ? array.new_float() : parsePath(sBlue)

    yr = 31536000000
    t0 = time
    gArr = array.from(gBear, gBase, gBull, gBlue)
    cArr = array.from(cRed, cAmber, cGreen, cPurple)
    nArr = array.from("bear", "base", "bull", "blue")

    for s = 0 to 3
        g   = array.get(gArr, s)
        col = array.get(cArr, s)
        pa  = bearA
        if s == 1
            pa := baseA
        else if s == 2
            pa := bullA
        else if s == 3
            pa := blueA
        pTm = t0
        pVl = fvAnchor
        for t = 1 to projYrs
            v  = railVal(pa, fvAnchor, g, t)
            tt = t0 + t * yr
            mkL(LL, pTm, pVl, tt, v, col, line.style_dotted, 2)
            if s == 2 and showLbls
                mkT(BL, tt, v, "$" + str.tostring(v, "#.#"), col, label.style_label_down, size.tiny)
                yoy = (v / pVl - 1) * 100
                mkT(BL, t0 + int((t - 0.5) * yr), (pVl + v) / 2, (yoy >= 0 ? "+" : "") + str.tostring(yoy, "#") + "%", cGreen, label.style_none, size.tiny)
            if s == 1 and showLbls
                mkT(BL, tt, v, "$" + str.tostring(v, "#.#"), col, label.style_label_up, size.tiny)
            pTm := tt
            pVl := v
        term = railVal(pa, fvAnchor, g, projYrs)
        if s == 0
            tvBear := term
        else if s == 1
            tvBase := term
        else if s == 2
            tvBull := term
        else
            tvBlue := term
        mkT(BL, t0 + projYrs * yr, term, array.get(nArr, s) + " $" + str.tostring(term, "#.#"), col, label.style_label_left, size.small)

    wTm = t0
    wVl = fvAnchor
    for t = 1 to projYrs
        wv  = wBear * railVal(bearA, fvAnchor, gBear, t) + wBase * railVal(baseA, fvAnchor, gBase, t) + wBull * railVal(bullA, fvAnchor, gBull, t) + wBlue * railVal(blueA, fvAnchor, gBlue, t)
        wtt = t0 + t * yr
        mkL(LL, wTm, wVl, wtt, wv, cInk, line.style_solid, 2)
        wTm := wtt
        wVl := wv
    tvWtd := wVl
    mkT(BL, t0 + projYrs * yr, wVl, "wtd $" + str.tostring(wVl, "#.#"), cInk, label.style_label_left, size.normal)

    mTm = t0
    mVl = close
    for t = 1 to projYrs
        mv  = close * math.pow(1 + (Ke - divYld) / 100, t)
        mtt = t0 + t * yr
        mkL(LL, mTm, mVl, mtt, mv, cGrey, line.style_dashed, 1)
        mTm := mtt
        mVl := mv
    mkT(BL, t0 + projYrs * yr, mVl, "mkt $" + str.tostring(mVl, "#.#"), cGrey, label.style_label_left, size.tiny)

    mkT(BL, t0, close, "now $" + str.tostring(close, "#.#"), cTeal, label.style_label_left, size.small)
    mkT(BL, t0, fvAnchor, manualFwd ? "Fair now (manual $" + str.tostring(fvAnchor, "#.##") + ")" : "Fair (" + pMet + " x" + str.tostring(effMult, "#.#") + ")", cAmber, label.style_label_left, size.tiny)
    if showHist and not manualFwd and not na(nv)
        mkT(BL, t0, nv, "Normal (avg " + str.tostring(normMult, "#.#") + "x)", cPurple, label.style_label_left, size.tiny)
    if isStudio and not manualFwd
        mkT(BL, t0, high, "⚠ trailing-multiple model — low fit for " + tkr + "; paste a studio path", cAmber, label.style_label_down, size.small)

// ============================================================
//  ALERTS
// ============================================================
alertcondition(ta.crossover(close, fv),  "Price crossed ABOVE fair value",   "{{ticker}}: price above fair value")
alertcondition(ta.crossunder(close, fv), "Price crossed BELOW fair value",   "{{ticker}}: price below fair value")
alertcondition(ta.crossover(close, nv),  "Price crossed ABOVE normal value", "{{ticker}}: price above normal value")
alertcondition(ta.crossunder(close, nv), "Price crossed BELOW normal value", "{{ticker}}: price below normal value")

// ============================================================
//  SUMMARY TABLE
// ============================================================
var table tb = table.new(position.top_right, 2, 13, border_width=1, frame_color=cGrey, frame_width=1)
if showTbl and barstate.islast
    prem  = na(fvAnchor) ? na : close / fvAnchor - 1
    mktT  = close * math.pow(1 + (Ke - divYld) / 100, projYrs)
    fitCol= manualFwd ? cTeal : pFit == "auto" ? cGreen : isStudio ? cAmber : cGrey
    fitTxt= manualFwd ? "manual-path" : pFit
    tcell(tb, 0,  "Ticker · fit",      tkr + " · " + fitTxt, fitCol)
    tcell(tb, 1,  "Data · clamp",      src + (clamped ? " · CLAMPED" : ""), clamped ? cRed : src == "no data" ? cRed : cGrey)
    tcell(tb, 2,  "Fwd source",        fwdSrc, cInk)
    tcell(tb, 3,  "Fair value now",    na(fvAnchor) ? "n/a" : "$" + str.tostring(fvAnchor, "#.##"), cAmber)
    tcell(tb, 4,  "Price · prem",      "$" + str.tostring(close, "#.#") + "  " + pct(prem), na(prem) ? cGrey : prem > 0 ? cRed : cGreen)
    tcell(tb, 5,  "Bull " + str.tostring(projYrs) + "y/IRR", na(tvBull) ? "n/a" : "$" + str.tostring(tvBull, "#.#") + "  " + pct(irr(tvBull, close, projYrs)), cGreen)
    tcell(tb, 6,  "Base /IRR",         na(tvBase) ? "n/a" : "$" + str.tostring(tvBase, "#.#") + "  " + pct(irr(tvBase, close, projYrs)), cAmber)
    tcell(tb, 7,  "Bear /IRR",         na(tvBear) ? "n/a" : "$" + str.tostring(tvBear, "#.#") + "  " + pct(irr(tvBear, close, projYrs)), cRed)
    tcell(tb, 8,  "Blue-sky /IRR",     na(tvBlue) ? "n/a" : "$" + str.tostring(tvBlue, "#.#") + "  " + pct(irr(tvBlue, close, projYrs)), cPurple)
    tcell(tb, 9,  "Weighted /IRR",     na(tvWtd)  ? "n/a" : "$" + str.tostring(tvWtd, "#.#")  + "  " + pct(irr(tvWtd, close, projYrs)), cInk)
    tcell(tb, 10, "Eff × (auto)",      na(effMult) ? "n/a" : str.tostring(effMult, "#.#") + "x", cGrey)
    tcell(tb, 11, "Per share (feed)",  na(psEff) ? "n/a" : "$" + str.tostring(psEff, "#.##"), cGrey)
    tcell(tb, 12, "Mkt-implied " + str.tostring(projYrs) + "y", "$" + str.tostring(mktT, "#.#"), cGrey)
````
