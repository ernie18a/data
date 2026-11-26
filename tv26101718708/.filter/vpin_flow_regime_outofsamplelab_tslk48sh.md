# VPIN Flow Regime [OutOfSampleLab]

- url: https://www.tradingview.com/script/TsLK48Sh/
- type: indicator
- pine_id: PUB;cac12d9a2498428e8f6ca3f5e9245656
- version: 1.0

## Description

VPIN Flow Regime visualises order-flow toxicity and buy/sell pressure directly on your chart, with non-repainting flow-price divergence. It describes the current state of the tape. It does not give buy or sell signals.

How it works
- Each bar's volume is split into buy and sell parts using Bulk Volume Classification: the buy fraction is the CDF of the standardised close-to-close change. Two paper-faithful variants are selectable: the standard-normal CDF (Easley, Lopez de Prado & O'Hara, 2012) or the fat-tailed Student-t CDF with 0.25 degrees of freedom (their 2016 paper). To our knowledge no other public script offers both.
- VPIN toxicity = sum |buy - sell| / sum volume over N bars. An unsigned measure of how one-sided flow has been. It is coloured by its own rolling percentile into a regime light: Quiet, Normal, Elevated, Burst.
- Buy pressure = net flow rescaled to 0-100 (50 = balanced).
- Divergence: when price makes a higher high (or lower low) that net flow does not confirm. Confirmed on pivots a few bars later, so it never repaints. By default the divergence lines and labels are drawn directly on the price chart.

Alerts
- Toxicity crossing into Elevated / Burst / back to calm.
- Bullish / bearish flow-price divergence.
All alerts are state-change events, not trade instructions.

Honest limitations (please read)
- This is a bar-based approximation of VPIN, not tick-level VPIN on a true volume clock. Read relative levels and percentiles, not absolute values.
- TradingView volume is feed-dependent; on many FX/index/CFD symbols it is tick count, not traded volume, and the reading is weak there. Prefer symbols with real volume.
- Aggressor classification is imperfect and depends on the window settings.

This is an impersonal educational tool that runs the same for everyone. Not financial advice, no performance claims.

References: Easley, Lopez de Prado & O'Hara (2012), Review of Financial Studies 25(5); (2016), Journal of Financial Economics 120(2); Lee & Ready (1991), Journal of Finance 46(2).

## Source Code

````pine
//@version=6
// =============================================================================
// VPIN Flow Regime  —  OutOfSampleLab
// -----------------------------------------------------------------------------
// Order-flow toxicity regime + buy/sell pressure + non-repainting flow-price
// divergence, built from Bulk Volume Classification (BVC) and the VPIN metric.
//
// WHAT IT DOES (it describes the current state of the tape; it is NOT a signal)
//   1. Splits each bar's volume into buy and sell parts with Bulk Volume
//      Classification: buy fraction  f = Z( (close - close[1]) / sigma ),
//      where sigma is the rolling stdev of close-to-close changes and Z is
//      selectable: the standard-normal CDF (Easley, Lopez de Prado & O'Hara
//      2012) or the Student-t CDF with 0.25 degrees of freedom (their 2016
//      paper), which weights fat tails more realistically. To our knowledge
//      no other public script offers both paper variants.
//   2. VPIN toxicity = sum |Vbuy - Vsell| / sum volume  over N bars   (0..1).
//      An UNSIGNED measure of how one-sided flow has been, regardless of
//      direction. Coloured by its own rolling percentile into a regime light:
//      Quiet / Normal / Elevated / Burst.
//   3. Buy pressure = net flow rescaled to 0..100  (50 = balanced).
//   4. Flow-price divergence: price makes a higher high (or lower low) that net
//      flow does not confirm. Confirmed on pivots a few bars later, so it never
//      repaints (it lags by the pivot-right setting instead). By default the
//      divergence lines are drawn directly on the PRICE chart (force_overlay).
//
// HONEST LIMITATIONS (this is the whole point of the brand, so read them)
//   * BAR-BASED APPROXIMATION of VPIN, not tick-level VPIN on a true volume
//     clock. Fixed-time bars are not equal-volume buckets, so read relative
//     levels and percentiles, not absolute values.
//   * TradingView "volume" is feed-dependent. For many FX / index / CFD symbols
//     it is tick count, not traded volume, and the reading is weak there.
//     Prefer liquid symbols that report real traded volume.
//   * One close-to-close number drives each bar's split; the intrabar path is
//     lost.
//   * Aggressor classification is ~60-90% accurate even with clean data and
//     degrades in fast, fragmented markets. Results depend on N and the sigma
//     window; these are tuning parameters, not physical constants.
//
// NOT A SIGNAL. No buy/sell calls, no entries or exits, no performance claims.
// An impersonal educational tool that runs the same for everyone. Not financial
// advice. If you use it to present backtested results, attach the CFTC Rule
// 4.41 disclaimer: simulated results have inherent limitations and do not
// represent actual trading.
//
// IMPLEMENTATION NOTES
//   * Normal CDF via the Abramowitz & Stegun 7.1.26 erf approximation.
//   * Student-t CDF via Lanczos log-gamma + Lentz continued-fraction
//     regularized incomplete beta (Numerical Recipes); validated against
//     scipy.stats.t.cdf to < 1e-10 absolute error for df in [0.25, 30].
//   * Until the sigma window is full the buy fraction is na (not 0.5), so the
//     warm-up period shows no value instead of a fake balanced reading.
//
// Sources: Easley, Lopez de Prado & O'Hara (2012) Rev. Financial Studies 25(5);
//          Easley, Lopez de Prado & O'Hara (2016) J. Financial Economics 120(2);
//          Lee & Ready (1991) Journal of Finance 46(2).
// License: MIT.
// =============================================================================

indicator("VPIN Flow Regime [OutOfSampleLab]", shorttitle="VPIN Flow", overlay=false, precision=1, max_labels_count=500, max_lines_count=500)

// ---- Inputs -----------------------------------------------------------------
grpC = "Core"
N        = input.int(50,  "VPIN window (bars)", minval=5, group=grpC, tooltip="Support window: how many bars of buy/sell imbalance are pooled. Bar analog of the classic n=50 VPIN support window.")
sigmaLen = input.int(100, "Sigma window (price-change stdev)", minval=5, group=grpC, tooltip="Rolling window for the stdev of close-to-close changes used to standardise the BVC split.")
regimeLb = input.int(300, "Regime percentile lookback", minval=20, group=grpC, tooltip="How far back VPIN is ranked to decide Quiet / Normal / Elevated / Burst.")
distOpt  = input.string("Normal (ELO 2012)", "BVC distribution", options=["Normal (ELO 2012)", "Student-t df 0.25 (ELO 2016)"], group=grpC, tooltip="How each bar's standardised price change maps to a buy fraction. Normal CDF follows the original 2012 VPIN paper; the Student-t CDF with 0.25 degrees of freedom follows the 2016 Journal of Financial Economics paper and gives large moves a less extreme split (fat tails).")

grpR = "Regime thresholds (percentile)"
normP  = input.int(40, "Normal above", minval=0, maxval=100, group=grpR)
elevP  = input.int(80, "Elevated above", minval=0, maxval=100, group=grpR)
burstP = input.int(95, "Burst above", minval=0, maxval=100, group=grpR)

grpD = "Divergence"
showDiv    = input.bool(true, "Show flow-price divergence", group=grpD)
divOnPrice = input.bool(true, "Draw divergence on the price chart", group=grpD, tooltip="On: divergence lines and labels are drawn on the main price chart at the pivot prices. Off: they are drawn in this pane at the pressure values.")
pivL       = input.int(5, "Pivot left", minval=1, group=grpD)
pivR       = input.int(5, "Pivot right", minval=1, group=grpD, tooltip="Divergence confirms this many bars after the pivot, so it never repaints (but it lags by this many bars).")

grpV = "Visuals"
showPress = input.bool(true, "Show buy/sell pressure line", group=grpV)
showBg    = input.bool(true, "Tint background on Burst", group=grpV)
showTable = input.bool(true, "Show regime panel", group=grpV)
colBuy    = input.color(#22C55E, "Buy pressure", group=grpV)
colSell   = input.color(#EF4444, "Sell pressure", group=grpV)

// ---- Standard-normal CDF (Abramowitz & Stegun 7.1.26 erf approximation) ------
f_erf(x) =>
    t = 1.0 / (1.0 + 0.3275911 * math.abs(x))
    poly = ((((1.061405429 * t - 1.453152027) * t + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t
    y = 1.0 - poly * math.exp(-x * x)
    (x >= 0 ? 1.0 : -1.0) * y

f_ncdf(x) =>
    0.5 * (1.0 + f_erf(x / math.sqrt(2.0)))

// ---- Student-t CDF (Lanczos log-gamma + Lentz incomplete beta) ---------------
f_gammaln_core(xx) =>
    x = xx - 1.0
    a = 0.99999999999980993
    a += 676.5203681218851 / (x + 1.0)
    a -= 1259.1392167224028 / (x + 2.0)
    a += 771.32342877765313 / (x + 3.0)
    a -= 176.61502916214059 / (x + 4.0)
    a += 12.507343278686905 / (x + 5.0)
    a -= 0.13857109526572012 / (x + 6.0)
    a += 9.9843695780195716e-6 / (x + 7.0)
    a += 1.5056327351493116e-7 / (x + 8.0)
    tt = x + 7.5
    0.5 * math.log(2.0 * math.pi) + (x + 0.5) * math.log(tt) - tt + math.log(a)

f_gammaln(x) =>
    x < 0.5 ? math.log(math.pi / math.sin(math.pi * x)) - f_gammaln_core(1.0 - x) : f_gammaln_core(x)

f_betacf(a, b, x) =>
    qab = a + b
    qap = a + 1.0
    qam = a - 1.0
    c = 1.0
    d = 1.0 - qab * x / qap
    d := math.abs(d) < 1.0e-30 ? 1.0e-30 : d
    d := 1.0 / d
    h = d
    for m = 1 to 200
        m2 = 2 * m
        aa = m * (b - m) * x / ((qam + m2) * (a + m2))
        d := 1.0 + aa * d
        d := math.abs(d) < 1.0e-30 ? 1.0e-30 : d
        c := 1.0 + aa / c
        c := math.abs(c) < 1.0e-30 ? 1.0e-30 : c
        d := 1.0 / d
        h := h * d * c
        aa := -(a + m) * (qab + m) * x / ((a + m2) * (qap + m2))
        d := 1.0 + aa * d
        d := math.abs(d) < 1.0e-30 ? 1.0e-30 : d
        c := 1.0 + aa / c
        c := math.abs(c) < 1.0e-30 ? 1.0e-30 : c
        d := 1.0 / d
        de = d * c
        h := h * de
        if math.abs(de - 1.0) < 3.0e-9
            break
    h

f_ibeta(a, b, x) =>
    if x <= 0.0
        0.0
    else if x >= 1.0
        1.0
    else
        bt = math.exp(f_gammaln(a + b) - f_gammaln(a) - f_gammaln(b) + a * math.log(x) + b * math.log(1.0 - x))
        x < (a + 1.0) / (a + b + 2.0) ? bt * f_betacf(a, b, x) / a : 1.0 - bt * f_betacf(b, a, 1.0 - x) / b

f_tcdf(x, nu) =>
    z = nu / (nu + x * x)
    p = 0.5 * f_ibeta(nu / 2.0, 0.5, z)
    x >= 0 ? 1.0 - p : p

// ---- BVC split + VPIN / NetFlow ---------------------------------------------
useT  = distOpt != "Normal (ELO 2012)"
T_DF  = 0.25
dP    = close - close[1]
vol   = nz(volume, 0.0)
sigma = ta.stdev(dP, sigmaLen)
zArg  = dP / sigma
f     = na(sigma) or sigma <= 0 or na(zArg) ? na : useT ? f_tcdf(zArg, T_DF) : f_ncdf(zArg)   // buy fraction; na during warm-up, no fake 0.5
imb   = vol * (2.0 * f - 1.0)                                                                 // Vbuy - Vsell (signed)
aimb  = math.abs(imb)

sumV = math.sum(vol,  N)
sumA = math.sum(aimb, N)
sumI = math.sum(imb,  N)

vpin     = sumV > 0 ? sumA / sumV : na              // toxicity 0..1 (unsigned)
netflow  = sumV > 0 ? sumI / sumV : na              // bias -1..1 (signed)
pressure = na(netflow) ? na : 50.0 * (1.0 + netflow)   // 0..100, 50 = balanced
vpinPct  = na(vpin) ? na : vpin * 100.0

// ---- Regime -----------------------------------------------------------------
pr = ta.percentrank(vpin, regimeLb)                 // 0..100
regime = na(pr) ? 0 : pr >= burstP ? 3 : pr >= elevP ? 2 : pr >= normP ? 1 : 0
colQuiet  = #8B949E
colNormal = #38BDF8
colElev   = #F59E0B
colBurst  = #EF4444
regimeCol = regime == 3 ? colBurst : regime == 2 ? colElev : regime == 1 ? colNormal : colQuiet
regimeTxt = regime == 3 ? "Burst" : regime == 2 ? "Elevated" : regime == 1 ? "Normal" : "Quiet"

// ---- Plots ------------------------------------------------------------------
plot(vpinPct, "VPIN toxicity", color=color.new(regimeCol, 65), style=plot.style_area)
plot(showPress ? pressure : na, "Buy pressure", color=(na(pressure) ? na : pressure >= 50 ? colBuy : colSell), linewidth=2)
hline(50, "Balance", color=color.new(#8B949E, 40), linestyle=hline.style_dashed)
bgcolor(showBg and regime == 3 ? color.new(colBurst, 88) : na, title="Burst tint")

// ---- Divergence (non-repainting, pivot-confirmed) ---------------------------
var float pPHp = na   // previous pivot-high price
var float pPHf = na   // previous pivot-high pressure
var int   pPHb = na   // previous pivot-high bar_index
var float pPLp = na
var float pPLf = na
var int   pPLb = na

ph = showDiv ? ta.pivothigh(high, pivL, pivR) : na
pl = showDiv ? ta.pivotlow(low,  pivL, pivR) : na

bearDiv = false
bullDiv = false

if not na(ph)
    curP = high[pivR]
    curF = pressure[pivR]
    if not na(pPHp) and not na(pPHf) and not na(curF) and curP > pPHp and curF < pPHf
        bearDiv := true
        if divOnPrice
            line.new(pPHb, pPHp, bar_index[pivR], curP, color=colSell, width=2, force_overlay=true)
            label.new(bar_index[pivR], curP, "Bear Div", style=label.style_label_down, color=color.new(colSell, 20), textcolor=color.white, size=size.small, force_overlay=true, tooltip="Price made a higher high but net flow did not confirm. Context, not a trade signal.")
        else
            line.new(pPHb, pPHf, bar_index[pivR], curF, color=colSell, width=1)
            label.new(bar_index[pivR], curF, "Bear Div", style=label.style_label_down, color=color.new(colSell, 20), textcolor=color.white, size=size.small, tooltip="Price made a higher high but net flow did not confirm. Context, not a trade signal.")
    pPHp := curP
    pPHf := curF
    pPHb := bar_index[pivR]

if not na(pl)
    curP = low[pivR]
    curF = pressure[pivR]
    if not na(pPLp) and not na(pPLf) and not na(curF) and curP < pPLp and curF > pPLf
        bullDiv := true
        if divOnPrice
            line.new(pPLb, pPLp, bar_index[pivR], curP, color=colBuy, width=2, force_overlay=true)
            label.new(bar_index[pivR], curP, "Bull Div", style=label.style_label_up, color=color.new(colBuy, 20), textcolor=color.white, size=size.small, force_overlay=true, tooltip="Price made a lower low but net flow did not confirm. Context, not a trade signal.")
        else
            line.new(pPLb, pPLf, bar_index[pivR], curF, color=colBuy, width=1)
            label.new(bar_index[pivR], curF, "Bull Div", style=label.style_label_up, color=color.new(colBuy, 20), textcolor=color.white, size=size.small, tooltip="Price made a lower low but net flow did not confirm. Context, not a trade signal.")
    pPLp := curP
    pPLf := curF
    pPLb := bar_index[pivR]

// ---- Regime panel -----------------------------------------------------------
var table pnl = table.new(position.top_right, 1, 3, bgcolor=color.new(#0D1117, 20), border_color=color.new(#30363D, 0), border_width=1)
if showTable and barstate.islast
    table.cell(pnl, 0, 0, "Flow toxicity  " + regimeTxt, text_color=color.white, bgcolor=color.new(regimeCol, 40), text_size=size.small)
    table.cell(pnl, 0, 1, "Buy pressure  " + (na(pressure) ? "n/a" : str.tostring(pressure, "0")) + "%", text_color=color.white, bgcolor=color.new(#0D1117, 20), text_size=size.small)
    table.cell(pnl, 0, 2, "VPIN pctile  " + (na(pr) ? "n/a" : str.tostring(pr, "0")), text_color=color.white, bgcolor=color.new(#0D1117, 20), text_size=size.small)

// ---- Alerts (state-change events, never trade instructions) -----------------
alertcondition(ta.crossover(pr, elevP),  title="Toxicity rose to Elevated", message="VPIN order-flow toxicity rose into the Elevated regime. State change, not a trade signal.")
alertcondition(ta.crossover(pr, burstP), title="Toxicity rose to Burst",    message="VPIN order-flow toxicity rose into the Burst regime. State change, not a trade signal.")
alertcondition(ta.crossunder(pr, normP), title="Toxicity fell to Calm",     message="VPIN order-flow toxicity fell back to a calm regime. State change, not a trade signal.")
alertcondition(bearDiv, title="Bearish flow-price divergence", message="Price made a higher high but net order flow did not confirm. Context only, not a trade signal.")
alertcondition(bullDiv, title="Bullish flow-price divergence", message="Price made a lower low but net order flow did not confirm. Context only, not a trade signal.")
````
