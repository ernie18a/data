# Multi-Oscillator Divergence Scanner [Quantum Algo]

- url: https://www.tradingview.com/script/XTUJjAGf-Multi-Oscillator-Divergence-Scanner-Quantum-Algo/
- type: indicator
- pine_id: PUB;fee163a8aa4e4039ad839bbed78e599d
- version: 1.0

## Description

Multi-Oscillator Divergence Scanner [Quantum Algo]
====================================================

🔶 OVERVIEW

Multi-Oscillator Divergence Scanner is a confluence-based divergence indicator that scans up to seven classic oscillators simultaneously — Relative Strength Index, Moving Average Convergence Divergence, Stochastic Oscillator, Commodity Channel Index, On Balance Volume, Money Flow Index, and Momentum — and displays the result on two synchronized canvases at once. Divergence lines, graded labels, and reaction zones are drawn directly on the price chart, while a dedicated pane below plots a Composite Oscillator built from every enabled engine, with the same divergence lines mirrored onto the composite itself. You see both slopes of every divergence — price disagreeing with momentum — in one glance.

The problem this script solves is selective divergence trading. Any single oscillator produces frequent divergences, and most of them fail. Requiring multiple mathematically independent engines — momentum-based, volume-based, and volatility-normalized — to diverge at the same confirmed swing filters the noise down to setups where disagreement between price and participation is broad, not incidental.

🔶 WHAT IS A DIVERGENCE?

A divergence occurs when price prints a new extreme but an oscillator refuses to confirm it. A regular bullish divergence forms when price makes a lower low while the oscillator makes a higher low — a classic reversal condition. A regular bearish divergence forms when price makes a higher high while the oscillator makes a lower high. Hidden divergences are the continuation counterparts: price makes a higher low while the oscillator makes a lower low (hidden bullish), or price makes a lower high while the oscillator makes a higher high (hidden bearish). This scanner detects all four types on confirmed swing pivots.

🔶 WHAT IS THE COMPOSITE OSCILLATOR?

The Composite Oscillator is the consensus reading of every engine you enable. Bounded oscillators (Relative Strength Index, Stochastic, Money Flow Index) contribute their native zero-to-one-hundred values; unbounded engines (Moving Average Convergence Divergence histogram, On Balance Volume, Momentum) are range-normalized over a configurable lookback; the Commodity Channel Index is rescaled onto the same axis. The average of all enabled engines plots as a single gradient line with overbought and oversold guides, a midline fill, and divergence lines drawn directly on it — so the pane shows aggregate momentum from the same engines that vote on every signal, not a separate calculation.

🔶 WHY THIS SCRIPT IS ORIGINAL

1. True multi-engine confluence. Divergences are not detected on one oscillator and decorated with others. All seven engines are evaluated independently at every confirmed pivot, and a signal only exists when the minimum confluence count you set is reached.

2. Dual-canvas mirroring. Every qualified divergence is drawn twice: on price, and on the Composite Oscillator in the pane, connected at the same two pivots. Both slopes of the disagreement are visible simultaneously — the visual proof that defines a divergence.

3. Consensus composite pane. The pane line is not one more oscillator; it is the averaged, normalized voice of the exact engines doing the scanning, colored by a gradient between the oversold and overbought guides.

4. Full transparency on every label. Each signal prints its strength as a diamond meter and lists the exact oscillators that diverged (for example: RSI · OBV · MFI). You always know why a signal exists — nothing is a black box.

5. Strength-scaled visuals. Divergence lines thicken with confluence on both canvases, and signals reaching the Strong threshold upgrade to the accent color, so chart hierarchy communicates quality instantly.

6. Reaction zones with a life cycle. Every regular divergence projects a volatility-sized zone around its pivot (measured in Average True Range). Zones gray out automatically the moment price invalidates them, so the chart always distinguishes live zones from dead ones.

7. Divergence pressure gauge. A decaying pressure model accumulates bullish and bearish divergence weight over time, giving a one-glance read on which side has been stacking disagreement with price.

🔶 HOW IT WORKS

Pivot scanning: Swing highs and swing lows are confirmed with a symmetric pivot lookback. All divergence checks are evaluated on closed bars at pivot confirmation, so historical signals do not repaint. Confirmation lag equals the right-side pivot length by design.

Confluence evaluation: At each confirmed pivot, every enabled oscillator's value at that pivot is compared against its value at the previous same-side pivot. The four divergence types are tested independently per oscillator, and contributions are counted.

Signal grading: Signals meeting the Minimum Oscillator Confluence print with strength diamonds (one per contributing oscillator). Signals reaching the Strong Signal Threshold upgrade to the accent color and thicker geometry on both the price chart and the composite pane.

Composite rendering: The pane plots the consensus line with a gradient fill to the midline, dashed overbought and oversold guides, tinted extreme bands, triangle marks at divergence bars, and the mirrored divergence lines.

Reaction zones: Each regular divergence projects a box around its pivot sized by Average True Range, extended a configurable number of bars. A bullish zone grays out when price closes below it; a bearish zone grays out when price closes above it.

Dashboard: A fully themeable panel on the price chart shows the last signal, a live divergence pressure meter, and one row per engine with its live value — color-coded for overbought, oversold, or directional state — plus each engine's most recent divergence side. Text size (four steps), position, and every color (title band, background, frame, grid, header, body, muted) are adjustable.

Chart hygiene: The number of divergences kept is capped by input, on both canvases. Older lines, labels, and zones are deleted automatically, keeping the chart readable and the auto-scale anchored to current price.

🔶 HOW TO USE IT

1. Works on any market — cryptocurrency, forex, gold, indices, stocks, futures — and any timeframe. Higher timeframes produce fewer, larger-structure signals.
2. Start with Minimum Oscillator Confluence at 2 and the Strong threshold at 4. Raise the minimum to 3 for a strict, low-frequency reversal tool; lower it to 1 to study single-oscillator behavior.
3. Read the pane and the chart together: a valid signal shows price sloping one way and the composite sloping the other, connected at the same pivots.
4. Regular divergences are reversal-oriented: treat them as exhaustion evidence at swing extremes, strongest when the composite is also inside an overbought or oversold band.
5. Hidden divergences are continuation-oriented: treat them as trend re-entry evidence during pullbacks, and do not read them like reversal signals.
6. Use the reaction zone as the decision area: a live zone holding on retest supports the signal; a grayed zone means the divergence failed.
7. The pressure meter is context, not a trigger — persistent one-sided pressure alongside fresh strong signals is the highest-quality condition.

🔶 SETTINGS

- Pivot Left / Right Length — swing size; larger values scan bigger structures.
- Independent toggles and lengths for all seven oscillator engines.
- Composite pane: normalization lookback, overbought and oversold levels, pane marks, and mirrored divergence lines toggle.
- Regular and hidden divergence toggles, minimum confluence, strong threshold.
- Reaction zone height (Average True Range ratio) and extension.
- Divergences To Keep — caps historical drawings on both canvases for chart cleanliness and stable auto-scale.
- Dashboard with adjustable text size, position, live oscillator values, and full color theming.
- Full color customization for all chart drawings and pivot markers.

🔶 ALERTS

- Bullish Divergence / Bearish Divergence — a regular divergence met the confluence minimum.
- Hidden Bullish Divergence / Hidden Bearish Divergence — a continuation divergence met the minimum.
- Strong Divergence — a regular divergence reached the strong threshold.

🔶 FREQUENTLY ASKED QUESTIONS

Does the indicator repaint? No. Divergences are evaluated only on confirmed pivots at bar close. The trade-off is intentional confirmation lag equal to the right-side pivot length.

Why does a pane divergence line sometimes start slightly off the composite's visual peak? Divergence is measured at price structure points. The line connects the composite's values at the two confirmed price pivots, which is the correct comparison even when the composite made its own extreme a bar or two away.

Why do some obvious divergences not print? Either the confluence minimum was not reached, the oscillator involved is disabled, or the swing did not confirm as a pivot under the current lengths.

Which oscillators should I enable? The default set mixes momentum and volume perspectives, which is the point of confluence: independent evidence, not seven copies of the same math.

Is a Strong signal a guaranteed reversal? No. Strength counts agreement between engines; it is a transparency measure, not a probability of profit.

🔶 CREDITS

This script builds its scanning and composite engine on classic, public-domain oscillators, and gratefully credits their creators: the Relative Strength Index by J. Welles Wilder Jr. (1978), Moving Average Convergence Divergence by Gerald Appel, the Stochastic Oscillator popularized by George C. Lane, the Commodity Channel Index by Donald Lambert (1980), On Balance Volume by Joseph Granville (1963), and the Money Flow Index by Gene Quong and Avrum Soudack. All oscillator calculations use standard built-in formulas. Drawing divergence lines on an oscillator is a long-established charting convention popularized by many community authors, acknowledged here as shared prior art. The multi-engine confluence scanner, the consensus Composite Oscillator, the dual-canvas mirroring, transparency labeling, strength grading, reaction zone life cycle, pressure model, and all code in this script are original work — no third-party or open-source script code was reused.

🔶 LIMITATIONS

Divergence can persist or fail entirely during strong trends; regular divergences against a powerful trend are the weakest application. Volume-based engines (On Balance Volume, Money Flow Index) are less meaningful on symbols with unreliable volume reporting. The composite's normalized components depend on the normalization lookback. Pivot confirmation introduces intentional delay. No indicator replaces independent analysis.

🔶 DISCLAIMER

This script is provided strictly for educational and informational purposes. It is not financial advice, an investment recommendation, or a solicitation to buy or sell any financial instrument. Past behavior of any signal does not guarantee future results. Trading involves substantial risk. Always do your own research and manage risk independently.

## Source Code

````pine
//@version=6
indicator("Multi-Oscillator Divergence Scanner [Quantum Algo]", overlay = false, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ════════════════════════════════════════════════════════════════
//  Oscillator concept credits (all public-domain classics):
//  Relative Strength Index — J. Welles Wilder Jr. (1978)
//  Moving Average Convergence Divergence — Gerald Appel (1970s)
//  Stochastic Oscillator — George C. Lane (1950s)
//  Commodity Channel Index — Donald Lambert (1980)
//  On Balance Volume — Joseph Granville (1963)
//  Money Flow Index — Gene Quong & Avrum Soudack
//  The divergence scanning, confluence grading, composite pane,
//  reaction zones and all code in this script are original work.
// ════════════════════════════════════════════════════════════════

// ════════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════════
grpP = "Pivot Detection"
pivL     = input.int(5, "Pivot Left Length", minval = 2, maxval = 30, group = grpP)
pivR     = input.int(5, "Pivot Right Length", minval = 2, maxval = 30, group = grpP, tooltip = "Bars required to confirm a swing. Divergences print this many bars after the pivot by design, which keeps signals fixed once drawn.")
keepDivs = input.int(12, "Divergences To Keep", minval = 2, maxval = 40, group = grpP, tooltip = "Older divergence drawings beyond this count are deleted so the chart stays clean and the auto-scale stays anchored to current price.")

grpO = "Oscillator Engines"
useRsi   = input.bool(true, "Relative Strength Index", inline = "o1", group = grpO)
rsiLen   = input.int(14, "", minval = 2, inline = "o1", group = grpO)
useMacd  = input.bool(true, "Moving Average Convergence Divergence", inline = "o2", group = grpO)
macdFast = input.int(12, "", minval = 2, inline = "o2", group = grpO)
macdSlow = input.int(26, "", minval = 3, inline = "o2", group = grpO)
macdSig  = input.int(9, "", minval = 2, inline = "o2", group = grpO)
useStoch = input.bool(true, "Stochastic Oscillator", inline = "o3", group = grpO)
stochLen = input.int(14, "", minval = 2, inline = "o3", group = grpO)
useCci   = input.bool(true, "Commodity Channel Index", inline = "o4", group = grpO)
cciLen   = input.int(20, "", minval = 2, inline = "o4", group = grpO)
useObv   = input.bool(true, "On Balance Volume", inline = "o5", group = grpO)
useMfi   = input.bool(true, "Money Flow Index", inline = "o6", group = grpO)
mfiLen   = input.int(14, "", minval = 2, inline = "o6", group = grpO)
useMom   = input.bool(true, "Momentum", inline = "o7", group = grpO)
momLen   = input.int(10, "", minval = 2, inline = "o7", group = grpO)

grpC = "Composite Oscillator Pane"
showComp = input.bool(true, "Show Composite Oscillator", group = grpC)
normLen  = input.int(100, "Normalization Lookback", minval = 20, maxval = 500, group = grpC, tooltip = "Lookback used to map the unbounded engines (Convergence Divergence, On Balance Volume, Momentum) onto the 0 to 100 scale.")
obLvl    = input.float(80, "Overbought Level", minval = 50, maxval = 100, group = grpC)
osLvl    = input.float(20, "Oversold Level", minval = 0, maxval = 50, group = grpC)
showMarks = input.bool(true, "Mark Divergence Bars In Pane", group = grpC)
showPaneLines = input.bool(true, "Draw Divergence Lines On Composite", group = grpC)

grpD = "Divergence Types & Strength"
showReg  = input.bool(true, "Regular Divergences (Reversal)", group = grpD)
showHid  = input.bool(true, "Hidden Divergences (Continuation)", group = grpD)
minConf  = input.int(2, "Minimum Oscillator Confluence", minval = 1, maxval = 7, group = grpD, tooltip = "How many oscillators must diverge at the same pivot before anything is drawn.")
strongTh = input.int(4, "Strong Signal Threshold", minval = 2, maxval = 7, group = grpD, tooltip = "Confluence count at which a signal is upgraded to Strong and highlighted in the accent color.")

grpZ = "Reaction Zones"
showZones = input.bool(true, "Show Reaction Zones", group = grpZ)
zoneAtr   = input.float(0.75, "Zone Height (Average True Range Ratio)", step = 0.05, minval = 0.1, group = grpZ)
zoneExt   = input.int(20, "Zone Extension (Bars)", minval = 5, maxval = 100, group = grpZ)

grpV = "Chart Visuals"
bullCol    = input.color(#26d0ce, "Bullish Color", group = grpV)
bearCol    = input.color(#f7567c, "Bearish Color", group = grpV)
goldCol    = input.color(#e8b64c, "Strong Signal Color", group = grpV)
silvCol    = input.color(#9aa7b8, "Neutral Color", group = grpV)
markPivots = input.bool(true, "Mark Scanned Pivots On Price", group = grpV)

grpT = "Dashboard"
showDash   = input.bool(true, "Show Dashboard", group = grpT)
dashPos    = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpT)
dashSize   = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpT)
showVals   = input.bool(true, "Show Live Oscillator Values", group = grpT)
dashTitleBg = input.color(color.new(#16233a, 0), "Title Band", group = grpT)
dashBg      = input.color(color.new(#0d1522, 15), "Background", group = grpT)
dashFrame   = input.color(color.new(#9aa7b8, 55), "Frame", group = grpT)
dashGrid    = input.color(color.new(#9aa7b8, 90), "Grid", group = grpT)
dashHeadTxt = input.color(color.new(#e8b64c, 0), "Header Text", group = grpT)
dashBodyTxt = input.color(color.new(#eef2f7, 5), "Body Text", group = grpT)
dashMuteTxt = input.color(color.new(#9aa7b8, 15), "Muted Text", group = grpT)

// ════════════════════════════════════════════════════════════════
//  OSCILLATOR ENGINES
// ════════════════════════════════════════════════════════════════
rsiV = ta.rsi(close, rsiLen)
[macdM, macdS, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)
stochV = ta.sma(ta.stoch(close, high, low, stochLen), 3)
cciV = ta.cci(hlc3, cciLen)
obvV = ta.obv
obvSma = ta.sma(obvV, 20)
mfiV = ta.mfi(hlc3, mfiLen)
momV = ta.mom(close, momLen)
atr  = ta.atr(14)

// ════════════════════════════════════════════════════════════════
//  COMPOSITE OSCILLATOR (all engines normalized to 0 - 100)
// ════════════════════════════════════════════════════════════════
nMac = ta.stoch(macdHist, macdHist, macdHist, normLen)
nObv = ta.stoch(obvV, obvV, obvV, normLen)
nMom = ta.stoch(momV, momV, momV, normLen)
nCci = math.min(100, math.max(0, 50 + cciV * 0.25))

compArr = array.from(rsiV, nMac, stochV, nCci, nObv, mfiV, nMom)
enArrC  = array.from(useRsi, useMacd, useStoch, useCci, useObv, useMfi, useMom)
float sumN = 0.0
int   cntN = 0
for i = 0 to 6
    if enArrC.get(i) and not na(compArr.get(i))
        sumN += compArr.get(i)
        cntN += 1
comp = cntN > 0 ? sumN / cntN : na

compCol = color.from_gradient(nz(comp, 50), osLvl, obLvl, bearCol, bullCol)
pComp = plot(showComp ? comp : na, "Composite Oscillator", color = compCol, linewidth = 2)
pMid  = plot(showComp ? 50 : na, "Midline", color = color.new(#9aa7b8, 75), linewidth = 1)
fill(pComp, pMid, color = color.new(compCol, 82), title = "Composite Fill")
hOb  = hline(80, "Overbought Guide", color = color.new(#f7567c, 65), linestyle = hline.style_dashed)
hOs  = hline(20, "Oversold Guide", color = color.new(#26d0ce, 65), linestyle = hline.style_dashed)
hTop = hline(100, "Scale Top", color = color.new(#9aa7b8, 100))
hBot = hline(0, "Scale Bottom", color = color.new(#9aa7b8, 100))
fill(hOb, hTop, color = color.new(#f7567c, 93), title = "Overbought Band")
fill(hOs, hBot, color = color.new(#26d0ce, 93), title = "Oversold Band")

// ════════════════════════════════════════════════════════════════
//  PIVOT SCANNER STATE
// ════════════════════════════════════════════════════════════════
plNow = ta.pivotlow(low, pivL, pivR)
phNow = ta.pivothigh(high, pivL, pivR)

var float pLowPrev     = na
var int   pLowPrevBar  = na
var float pHighPrev    = na
var int   pHighPrevBar = na
var array<float> oscLowPrev  = array.new<float>(7, na)
var array<float> oscHighPrev = array.new<float>(7, na)
var array<int>   lastDir     = array.new<int>(7, 0)
var float compLowPrev  = na
var float compHighPrev = na

var array<line>  dLines = array.new<line>()
var array<line>  oLines = array.new<line>()
var array<label> dLabs  = array.new<label>()
var array<box>   dZones = array.new<box>()
var array<int>   dZDirs = array.new<int>()

var string lastSig = "—"
var float pressure = 0.0

f_rep(string s, int n) =>
    out = ""
    if n > 0
        for i = 1 to n
            out += s
    out

// event flags for alerts (reset every bar)
bool evBullR = false
bool evBullH = false
bool evBearR = false
bool evBearH = false
int  evBullRCnt = 0
int  evBearRCnt = 0
int  bullAdd = 0
int  bearAdd = 0

// ════════════════════════════════════════════════════════════════
//  BULLISH SCAN — CONFIRMED PIVOT LOWS
// ════════════════════════════════════════════════════════════════
if not na(plNow) and barstate.isconfirmed
    pb = bar_index - pivR
    cv = array.from(rsiV[pivR], macdHist[pivR], stochV[pivR], cciV[pivR], obvV[pivR], mfiV[pivR], momV[pivR])
    en = array.from(useRsi, useMacd, useStoch, useCci, useObv, useMfi, useMom)
    nm = array.from("RSI", "MACD", "Stochastic", "CCI", "OBV", "MFI", "Momentum")
    cvC = comp[pivR]
    if not na(pLowPrev)
        cntR = 0
        cntH = 0
        txtR = ""
        txtH = ""
        for i = 0 to 6
            if en.get(i) and not na(oscLowPrev.get(i)) and not na(cv.get(i))
                if plNow < pLowPrev and cv.get(i) > oscLowPrev.get(i)
                    cntR += 1
                    txtR += (txtR == "" ? "" : " · ") + nm.get(i)
                    lastDir.set(i, 1)
                if plNow > pLowPrev and cv.get(i) < oscLowPrev.get(i)
                    cntH += 1
                    txtH += (txtH == "" ? "" : " · ") + nm.get(i)
                    lastDir.set(i, 1)
        if showReg and cntR >= minConf
            evBullR := true
            evBullRCnt := cntR
            bullAdd += cntR
            strong = cntR >= strongTh
            head = strong ? "Strong Bullish Divergence" : "Bullish Divergence"
            lastSig := head + " ×" + str.tostring(cntR)
            dLines.push(line.new(pLowPrevBar, pLowPrev, pb, plNow, color = color.new(strong ? goldCol : bullCol, 10), width = 1 + math.min(cntR - 1, 2), force_overlay = true))
            if showPaneLines and not na(compLowPrev) and not na(cvC)
                oLines.push(line.new(pLowPrevBar, compLowPrev, pb, cvC, color = color.new(strong ? goldCol : bullCol, 10), width = 1 + math.min(cntR - 1, 2)))
            dLabs.push(label.new(pb, plNow, "▲ " + head + "  " + f_rep("◆", cntR) + "\n" + txtR, style = label.style_label_up, color = color.new(strong ? goldCol : bullCol, strong ? 0 : 12), textcolor = #06222b, size = size.small, force_overlay = true))
            if showZones
                dZones.push(box.new(pb, plNow + atr * zoneAtr, pb + zoneExt, plNow - atr * 0.25, border_color = color.new(strong ? goldCol : bullCol, 55), bgcolor = color.new(strong ? goldCol : bullCol, 86), force_overlay = true))
                dZDirs.push(1)
        if showHid and cntH >= minConf
            evBullH := true
            bullAdd += cntH
            lastSig := "Hidden Bullish Divergence ×" + str.tostring(cntH)
            dLines.push(line.new(pLowPrevBar, pLowPrev, pb, plNow, color = color.new(bullCol, 40), width = 1 + math.min(cntH - 1, 2), style = line.style_dashed, force_overlay = true))
            if showPaneLines and not na(compLowPrev) and not na(cvC)
                oLines.push(line.new(pLowPrevBar, compLowPrev, pb, cvC, color = color.new(bullCol, 40), width = 1 + math.min(cntH - 1, 2), style = line.style_dashed))
            dLabs.push(label.new(pb, plNow, "▲ Hidden Bullish Divergence  " + f_rep("◇", cntH) + "\n" + txtH, style = label.style_label_up, color = color.new(bullCol, 45), textcolor = color.new(#eef2f7, 5), size = size.small, force_overlay = true))
    pLowPrev := plNow
    pLowPrevBar := pb
    compLowPrev := cvC
    for i = 0 to 6
        oscLowPrev.set(i, cv.get(i))

// ════════════════════════════════════════════════════════════════
//  BEARISH SCAN — CONFIRMED PIVOT HIGHS
// ════════════════════════════════════════════════════════════════
if not na(phNow) and barstate.isconfirmed
    pb = bar_index - pivR
    cv = array.from(rsiV[pivR], macdHist[pivR], stochV[pivR], cciV[pivR], obvV[pivR], mfiV[pivR], momV[pivR])
    en = array.from(useRsi, useMacd, useStoch, useCci, useObv, useMfi, useMom)
    nm = array.from("RSI", "MACD", "Stochastic", "CCI", "OBV", "MFI", "Momentum")
    cvC = comp[pivR]
    if not na(pHighPrev)
        cntR = 0
        cntH = 0
        txtR = ""
        txtH = ""
        for i = 0 to 6
            if en.get(i) and not na(oscHighPrev.get(i)) and not na(cv.get(i))
                if phNow > pHighPrev and cv.get(i) < oscHighPrev.get(i)
                    cntR += 1
                    txtR += (txtR == "" ? "" : " · ") + nm.get(i)
                    lastDir.set(i, -1)
                if phNow < pHighPrev and cv.get(i) > oscHighPrev.get(i)
                    cntH += 1
                    txtH += (txtH == "" ? "" : " · ") + nm.get(i)
                    lastDir.set(i, -1)
        if showReg and cntR >= minConf
            evBearR := true
            evBearRCnt := cntR
            bearAdd += cntR
            strong = cntR >= strongTh
            head = strong ? "Strong Bearish Divergence" : "Bearish Divergence"
            lastSig := head + " ×" + str.tostring(cntR)
            dLines.push(line.new(pHighPrevBar, pHighPrev, pb, phNow, color = color.new(strong ? goldCol : bearCol, 10), width = 1 + math.min(cntR - 1, 2), force_overlay = true))
            if showPaneLines and not na(compHighPrev) and not na(cvC)
                oLines.push(line.new(pHighPrevBar, compHighPrev, pb, cvC, color = color.new(strong ? goldCol : bearCol, 10), width = 1 + math.min(cntR - 1, 2)))
            dLabs.push(label.new(pb, phNow, "▼ " + head + "  " + f_rep("◆", cntR) + "\n" + txtR, style = label.style_label_down, color = color.new(strong ? goldCol : bearCol, strong ? 0 : 12), textcolor = #2b0612, size = size.small, force_overlay = true))
            if showZones
                dZones.push(box.new(pb, phNow + atr * 0.25, pb + zoneExt, phNow - atr * zoneAtr, border_color = color.new(strong ? goldCol : bearCol, 55), bgcolor = color.new(strong ? goldCol : bearCol, 86), force_overlay = true))
                dZDirs.push(-1)
        if showHid and cntH >= minConf
            evBearH := true
            bearAdd += cntH
            lastSig := "Hidden Bearish Divergence ×" + str.tostring(cntH)
            dLines.push(line.new(pHighPrevBar, pHighPrev, pb, phNow, color = color.new(bearCol, 40), width = 1 + math.min(cntH - 1, 2), style = line.style_dashed, force_overlay = true))
            if showPaneLines and not na(compHighPrev) and not na(cvC)
                oLines.push(line.new(pHighPrevBar, compHighPrev, pb, cvC, color = color.new(bearCol, 40), width = 1 + math.min(cntH - 1, 2), style = line.style_dashed))
            dLabs.push(label.new(pb, phNow, "▼ Hidden Bearish Divergence  " + f_rep("◇", cntH) + "\n" + txtH, style = label.style_label_down, color = color.new(bearCol, 45), textcolor = color.new(#eef2f7, 5), size = size.small, force_overlay = true))
    pHighPrev := phNow
    pHighPrevBar := pb
    compHighPrev := cvC
    for i = 0 to 6
        oscHighPrev.set(i, cv.get(i))

// ════════════════════════════════════════════════════════════════
//  DRAWING MEMORY CAPS + ZONE LIFE CYCLE
// ════════════════════════════════════════════════════════════════
while dLines.size() > keepDivs
    line.delete(dLines.shift())
while dLabs.size() > keepDivs
    label.delete(dLabs.shift())
while oLines.size() > keepDivs
    line.delete(oLines.shift())
while dZones.size() > keepDivs
    box.delete(dZones.shift())
    dZDirs.shift()

if dZones.size() > 0
    for i = 0 to dZones.size() - 1
        zb = dZones.get(i)
        zd = dZDirs.get(i)
        if zd == 1 and close < box.get_bottom(zb)
            box.set_bgcolor(zb, color.new(silvCol, 93))
            box.set_border_color(zb, color.new(silvCol, 80))
            dZDirs.set(i, 0)
        else if zd == -1 and close > box.get_top(zb)
            box.set_bgcolor(zb, color.new(silvCol, 93))
            box.set_border_color(zb, color.new(silvCol, 80))
            dZDirs.set(i, 0)

// pivot markers on the price chart
plotshape(markPivots and not na(plNow), title = "Scanned Pivot Low", style = shape.circle, location = location.belowbar, color = color.new(#9aa7b8, 70), size = size.tiny, offset = -pivR, force_overlay = true)
plotshape(markPivots and not na(phNow), title = "Scanned Pivot High", style = shape.circle, location = location.abovebar, color = color.new(#9aa7b8, 70), size = size.tiny, offset = -pivR, force_overlay = true)

// divergence marks inside the oscillator pane
plotshape(showMarks and (evBullR or evBullH), title = "Pane Bullish Mark", style = shape.triangleup, location = location.bottom, color = color.new(#26d0ce, 0), size = size.tiny, offset = -pivR)
plotshape(showMarks and (evBearR or evBearH), title = "Pane Bearish Mark", style = shape.triangledown, location = location.top, color = color.new(#f7567c, 0), size = size.tiny, offset = -pivR)

// ════════════════════════════════════════════════════════════════
//  DIVERGENCE PRESSURE
// ════════════════════════════════════════════════════════════════
pressure := pressure * 0.9 + bullAdd - bearAdd

// ════════════════════════════════════════════════════════════════
//  PREMIUM DASHBOARD (on the price chart)
// ════════════════════════════════════════════════════════════════
dPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
bodySize = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.small
headSize = dashSize == "Tiny" ? size.small : dashSize == "Large" ? size.large : dashSize == "Normal" ? size.normal : size.small

var table tb = table.new(dPos, 3, 11, bgcolor = dashBg, frame_color = dashFrame, frame_width = 1, border_color = dashGrid, border_width = 1, force_overlay = true)

if showDash and barstate.islast
    table.cell(tb, 0, 0, "◈ DIVERGENCE SCANNER", bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = headSize, text_halign = text.align_left)
    table.cell(tb, 1, 0, "", bgcolor = dashTitleBg)
    table.cell(tb, 2, 0, f_rep("◆", math.min(5, math.max(evBullRCnt, evBearRCnt))), bgcolor = dashTitleBg, text_color = dashHeadTxt, text_size = bodySize)
    table.cell(tb, 0, 1, "Last Signal", text_color = dashMuteTxt, text_size = bodySize, text_halign = text.align_left)
    table.cell(tb, 1, 1, lastSig, text_color = dashBodyTxt, text_size = bodySize, text_halign = text.align_left)
    table.cell(tb, 2, 1, "", text_size = bodySize)
    pmag = math.min(5, int(math.round(math.abs(pressure) / 2)))
    pTxt = pmag == 0 ? "Neutral" : (pressure > 0 ? "Bullish " : "Bearish ") + f_rep("▮", pmag)
    pCol = pmag == 0 ? dashBodyTxt : pressure > 0 ? bullCol : bearCol
    table.cell(tb, 0, 2, "Pressure", text_color = dashMuteTxt, text_size = bodySize, text_halign = text.align_left)
    table.cell(tb, 1, 2, pTxt, text_color = pCol, text_size = bodySize, text_halign = text.align_left)
    table.cell(tb, 2, 2, "", text_size = bodySize)
    table.cell(tb, 0, 3, "Oscillator", text_color = dashMuteTxt, text_size = bodySize, text_halign = text.align_left)
    table.cell(tb, 1, 3, showVals ? "Value" : "", text_color = dashMuteTxt, text_size = bodySize)
    table.cell(tb, 2, 3, "Signal", text_color = dashMuteTxt, text_size = bodySize)
    nmD  = array.from("Relative Strength Index", "Convergence Divergence", "Stochastic Oscillator", "Commodity Channel Index", "On Balance Volume", "Money Flow Index", "Momentum")
    enD  = array.from(useRsi, useMacd, useStoch, useCci, useObv, useMfi, useMom)
    vlD  = array.from(rsiV, macdHist, stochV, cciV, obvV, mfiV, momV)
    for i = 0 to 6
        rowBg = i % 2 == 0 ? color.new(#ffffff, 97) : na
        v = vlD.get(i)
        vTxt = not showVals or not enD.get(i) or na(v) ? "" : i == 4 ? str.tostring(v, format.volume) : i == 1 or i == 6 ? str.tostring(v, format.mintick) : str.tostring(v, "#.0")
        vCol = dashBodyTxt
        if enD.get(i) and not na(v)
            if i == 0
                vCol := v >= 70 ? bearCol : v <= 30 ? bullCol : dashBodyTxt
            else if i == 1
                vCol := v > 0 ? bullCol : v < 0 ? bearCol : dashBodyTxt
            else if i == 2
                vCol := v >= 80 ? bearCol : v <= 20 ? bullCol : dashBodyTxt
            else if i == 3
                vCol := v >= 100 ? bearCol : v <= -100 ? bullCol : dashBodyTxt
            else if i == 4
                vCol := v > obvSma ? bullCol : bearCol
            else if i == 5
                vCol := v >= 80 ? bearCol : v <= 20 ? bullCol : dashBodyTxt
            else
                vCol := v > 0 ? bullCol : v < 0 ? bearCol : dashBodyTxt
        d = lastDir.get(i)
        sTxt = not enD.get(i) ? "Off" : d == 1 ? "● Bull" : d == -1 ? "● Bear" : "—"
        sCol = not enD.get(i) ? color.new(#9aa7b8, 55) : d == 1 ? bullCol : d == -1 ? bearCol : dashBodyTxt
        table.cell(tb, 0, 4 + i, nmD.get(i), bgcolor = rowBg, text_color = dashMuteTxt, text_size = bodySize, text_halign = text.align_left)
        table.cell(tb, 1, 4 + i, vTxt, bgcolor = rowBg, text_color = vCol, text_size = bodySize)
        table.cell(tb, 2, 4 + i, sTxt, bgcolor = rowBg, text_color = sCol, text_size = bodySize)

// ════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════
alertcondition(evBullR, "Bullish Divergence", "A regular bullish divergence met the minimum oscillator confluence.")
alertcondition(evBearR, "Bearish Divergence", "A regular bearish divergence met the minimum oscillator confluence.")
alertcondition(evBullH, "Hidden Bullish Divergence", "A hidden bullish divergence met the minimum oscillator confluence.")
alertcondition(evBearH, "Hidden Bearish Divergence", "A hidden bearish divergence met the minimum oscillator confluence.")
alertcondition((evBullR and evBullRCnt >= strongTh) or (evBearR and evBearRCnt >= strongTh), "Strong Divergence", "A divergence reached the strong confluence threshold.")
````
