# Anchored VWAP Reversion Channel

- url: https://www.tradingview.com/script/HLcDy9mY-Anchored-VWAP-Reversion-Channel/
- type: indicator
- pine_id: PUB;40172e460145437990fe8f17e2444352
- version: 3.0

## Description

Anchored VWAP Reversion Channel — Regime-Gated Fade Framework

## What this script does

This is an **analytical study** that frames mean-reversion ("fade") setups around an **anchored, volume-weighted regression channel**, then **gates** those setups by a statistical market-state test and **scores** them against their own forward outcomes. It does not place orders and it is not a signal service — its purpose is to let you see, on your own instrument and timeframe, whether fading a stretched move actually has an edge, instead of assuming it does.

It plots one channel (a centre line plus inner/outer residual-σ bands), marks fade setups at the outer band, draws supporting context (volume-profile POC / value area, untested prior-session POCs, momentum divergences, liquidity sweeps, and multi-timeframe trend lines), and reports a compact validation panel.

## Why these components are combined (mashup rationale)

Fading an extreme is really three separate questions, and no single classic indicator answers all three. Stacking look-alike indicators just echoes one input, so this tool deliberately combines **three non-redundant lenses and makes them check each other**:

1. **WHERE is price stretched?** — A **volume-weighted polynomial regression** anchored at the most recent swing pivot, with **residual-σ bands**. Because the curve tilts with the active leg, an outer-band tag stays meaningful even inside a trend, where a flat cumulative VWAP would not. A **volume profile** anchored to the *same* window supplies POC and value area, and prior-session POCs that have never since been traded through become **reversion targets**.

2. **Is a reversion actually firing here?** — Three orthogonal **tells** evaluated only at the band: a **close-back rejection**, a **band-confluent momentum divergence**, and an **equal-high/low liquidity sweep** (stop-run). Crucially, all three are derived from the same stretch, so their agreement is shrunk by a **design-effect correction** (effective-sample-size): three correlated echoes are not allowed to masquerade as three independent confirmations.

3. **Is the market in a reverting state at all?** — A **regime gate** combining a **variance-ratio test** and a **reversion-trust correlation** only lets a fade through when recent increments are offsetting (mean-reverting) rather than compounding (trending).

The pieces are not bolted together side by side: they share **one geometry** (the anchored channel) and **one volatility unit** (residual σ / ATR), and each can veto the others. A band tag with no tell does nothing; a tell with no reverting regime does nothing. The design goal is to **suppress** low-quality fades — into a trend, mid-range, or backed by a single echoed tell — more than to generate them.

## The honesty layer (what makes this more than a drawing)

Every fade that fires is logged and, a fixed horizon later, **resolved**: its forward return is measured in ATR units and tabulated **with the regime gate ON versus OFF**, reporting follow-through %, whipsaw %, a Wilson 95% confidence interval, and the **mean return per fade**. A per-fade series also exports to the Data Window so you can study the full return distribution offline. The gate has to **beat its own ungated baseline** to justify itself — the framework is built to be tested, not trusted blindly.

## How to use it

1. Set the **Price source** (group 01). It works on any symbol and any market; volume-based parts need a real volume feed.
2. A fade **arms** when price tags the outer band **and** at least one tell prints, then **passes** only if the regime gate reports a reverting state. Solid triangles are gated fades; the target is the centre line or the nearest untested POC.
3. Read the panel top-down: does **Gate ON** beat **Gate OFF** on both follow-through and mean R, with non-overlapping intervals and a reasonable sample size? If not, the edge is not present on this symbol/timeframe — change them rather than forcing the trade.
4. The signal lives on **higher intraday timeframes**; one-minute data is mostly noise.

## Defaults

Shipped tuned for **NSE:NIFTY** index futures on intraday timeframes (sources, pivot lengths, value-area %, and the Tuesday-style weekly session context reflect that instrument). Every value is exposed as an input — change the **Price source** and the relevant lengths to run the framework on any other instrument or market.

## What is original

The original work is the **coordination**, not any single formula: an anchored polynomial-regression channel used as a reversion frame, three decorrelated band tells fused by a design-effect shrink, a statistical regime gate, and a built-in A/B + forward-return validation harness — combined so each lens can veto the others and the whole thing reports its own hit rate. It is not a re-skin of one indicator.

## Concept credits (techniques are standard; this implementation is original)

Anchored VWAP (standard); volume-weighted least-squares / polynomial regression (standard); residual-σ channel (standard); Volume Profile, Value Area and POC — Market Profile, Steidlmayer / CBOT; Variance-Ratio test — Lo & MacKinlay (1988); design effect / effective sample size — Kish (1965); proportion confidence interval — Wilson (1927); ATR trailing stop / Supertrend (classic, used for the multi-timeframe context lines); RSI — Wilder; Stochastic — Lane.

## Disclaimer

For research and education only. This is an analytical study, **not** financial advice, **not** a recommendation, and **not** a guarantee of future results. All statistics shown are **in-sample** on loaded history, close-to-close, without costs or slippage — a study aid, not a backtest. Mean reversion fails in trends and through regime breaks. Do your own research and manage your own risk.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════
//  ANCHORED VWAP REVERSION CHANNEL — Regime-Gated Fade Framework
// ------------------------------------------------------------------------
//  WHAT IT IS
//  An anchored, volume-weighted regression channel that frames mean-reversion
//  ("fade") setups and then GATES and SCORES them so the user can see whether
//  the setup actually has an edge on their instrument, rather than taking it on
//  faith. It is a study / framework, not a strategy and not a signal service.
//
//  It also runs a MULTI-FACTOR CONFLUENCE layer: nine different
//  "is price stretched?" factors (fair value / VWAP deviation, volatility /
//  range, efficiency, positioning / basis, trend extension / SAR-ATR, momentum /
//  RSI, equilibrium / linear-regression deviation, cycle / KST, order flow /
//  volume delta) are each standardized to one shared sigma scale, and the layer
//  counts how many reach the extreme at the same time (their CONFLUENCE). That
//  consensus count is a separate, independent "tell" confirming a band fade. The
//  band divergence itself is read on a single SHARP oscillator (Stoch RSI / RSI),
//  kept distinct so the divergence and the breadth read never blur together.
//
//  WHY THESE COMPONENTS BELONG TOGETHER (mashup rationale)
//  Fading an extreme asks three different questions, and no single classic tool
//  answers all three — so several NON-redundant lenses are combined and made to
//  check each other:
//    • WHERE is price stretched?  A volume-weighted polynomial regression
//      anchored at the most recent swing, with residual-sigma bands. A volume
//      profile anchored to the SAME window adds POC / value area; untested prior
//      POCs become reversion TARGETS.
//    • Is a reversion ACTUALLY firing?  Now FOUR orthogonal "tells" at the band:
//      a close-back rejection, a band-confluent momentum divergence (Stoch RSI /
//      RSI), an//      equal-high/low liquidity sweep, and — added here — a MULTI-FACTOR
//      consensus extreme (many factors stretched past ±σ together). Correlated
//      tells are shrunk by a design-effect correction so echoes can't masquerade
//      as independent confirmations.
//    • Is the market in a reverting STATE?  A regime gate (variance-ratio test +
//      a reversion-trust correlation) only lets the fade through when increments
//      are offsetting rather than compounding.
//  The components share ONE geometry (the anchored channel) and ONE volatility
//  unit (residual sigma / ATR), and each can veto the others. The goal is to
//  SUPPRESS low-quality fades more than to generate them.
//
//  THE HONESTY LAYER (what makes this more than a drawing)
//  Every fired fade is logged and, a fixed horizon later, RESOLVED: its forward
//  return is measured in ATR units and tabulated with the gate ON vs OFF
//  (follow-through %, whipsaw %, Wilson 95% interval, mean R per fade). A per-fade
//  series also exports to the Data Window. The gate has to EARN its place against
//  the ungated baseline — the tool is built to be falsified, not trusted blindly.
//
//  HOW TO USE
//   1. Set the Price source (works on any symbol / market). Volume-based parts
//      (profile, naked POC, VWAP and order-flow factors) need a real volume feed.
//   2. A fade arms when price tags the outer band AND at least one tell prints,
//      then passes only if the regime gate (and, optionally, the multi-factor
//      gate) says the market is reverting. Target is the centre line or the
//      nearest untested POC.
//   3. Read the panel top-down: does Gate ON beat Gate OFF on follow-through AND
//      mean R, with non-overlapping intervals and enough samples? If not, the
//      edge isn't there on this symbol/timeframe — change them, don't force it.
//   4. The signal lives on higher intraday timeframes; 1-minute is mostly noise.
//
//  ORIGINALITY
//  The original work is the COORDINATION: an anchored polynomial-regression
//  channel used as a reversion frame, decorrelated band tells fused by a design-
//  effect shrink, a multi-factor consensus (breadth) confirmer on a shared sigma
//  scale, a statistical regime gate, and a built-in A/B + forward-return
//  validation harness — combined so each lens can veto the others and the whole
//  thing reports its own hit rate. It is not a re-skin of one indicator.
//
//  CONCEPT CREDITS (techniques are standard; this implementation is original)
//   Anchored VWAP (standard); volume-weighted least-squares / polynomial
//   regression (standard); residual-sigma channel (standard); Volume Profile,
//   Value Area & POC — Market Profile, Steidlmayer / CBOT; Variance-Ratio test —
//   Lo & MacKinlay (1988); design effect / effective sample size — Kish (1965);
//   proportion confidence interval — Wilson (1927); ATR trailing stop / Supertrend
//   (classic, used for the MTF context lines); RSI, Parabolic SAR and ATR —
//   Wilder; Stochastic — Lane; Know Sure Thing — Pring; Efficiency Ratio —
//   Kaufman; basis / cost-of-carry — Kaldor (1939), Working (1948-49).
//
//  DISCLAIMER
//  For research and education only. This is an analytical study, NOT financial
//  advice, NOT a recommendation, and NOT a guarantee of future results. All
//  statistics shown are IN-SAMPLE on loaded history, close-to-close, without
//  costs or slippage — a study aid, not a backtest. Mean reversion fails in
//  trends and during regime breaks. Do your own research and manage your own risk.
// ════════════════════════════════════════════════════════════════════════
indicator("Anchored VWAP Reversion Channel — Regime-Gated Fade Framework", "AVWAP Reversion", overlay=true, max_bars_back=2000, max_lines_count=120, max_labels_count=120, max_boxes_count=20, dynamic_requests=true)

// ───────────────────────────── INPUTS ──────────────────────────────────
g0 = "01 · Data & Source"
src = input.source(hlc3, "Price source", group=g0, tooltip="The series the channel, profile, oscillator and multi-factor layer are built from. Default hlc3 suits most assets; switch to close / hl2 / ohlc4, or point at another indicator's plot, so the framework runs on ANY symbol or market. Volume-based parts (profile, naked POC, VWAP and order-flow factors) need a real volume feed — symbols without volume fall back to an equal weight or are skipped.")
srcHigh = input.source(high, "High source", group=g0, tooltip="High series used by the range factor, the SAR-extension factor and the divergence pivots. Defaults to the chart high; repoint for non-standard instruments or to feed the analysis from another series.")
srcLow  = input.source(low,  "Low source",  group=g0, tooltip="Low series, paired with the High source above.")

gA = "02 · Anchor & Curve"
anchorMode = input.string("Dual (auto)", "Anchor mode", options=["Rolling","Swing Low","Swing High","Dual (auto)"], group=gA, tooltip="Where the volume-weighted regression starts. Dual (auto) re-anchors at whichever swing pivot (high or low) is most recent, so the curve tracks the active leg. Swing Low/High pin to that pivot; Rolling uses a fixed trailing window.")
rollN      = input.int(89, "Rolling window (bars)", minval=5, maxval=400, group=gA)
pivFib     = input.string("21", "Swing pivot length (bars)", options=["8","13","21","34","55","89"], group=gA)
polyDeg    = input.int(1, "Curve degree (0 flat · 1 linear · 2 quad)", minval=0, maxval=2, group=gA)

gB = "03 · Channel & Bands"
mult1    = input.float(1.0, "Inner band (σ)", minval=0.1, step=0.1, group=gB)
mult2    = input.float(2.0, "Outer band — fade trigger (σ)", minval=0.1, step=0.1, group=gB, tooltip="Price must tag this residual-σ band to arm a fade. σ here is the regression's own residual scatter, not a probability — raise it to fade only deeper stretches.")
fillMode = input.string("Reversion heat", "Channel fill", options=["Reversion heat","Neon glow","Off"], group=gB)
glowOn   = input.bool(true, "Neon glow", group=gB)
lw       = input.int(2, "Line width", minval=1, maxval=6, group=gB)
colUp    = input.color(#21dfac, "Up / support", inline="c", group=gB)
colDn    = input.color(#df216d, "Down / resistance", inline="c", group=gB)

gP = "04 · Volume Profile"
showVP = input.bool(true, "Show POC / value area", group=gP)
vaPct  = input.float(70.0, "Value-area %", minval=50, maxval=95, step=1, group=gP) / 100.0
vpBins = input.int(24, "Profile resolution (bins)", minval=8, maxval=60, group=gP)
colPoc = input.color(#ffa600, "POC / VA color", group=gP)

gD = "05 · Momentum Divergence"
showDiv  = input.bool(true, "Show divergence", group=gD)
oscType  = input.string("Stoch RSI", "Divergence oscillator", options=["Stoch RSI","RSI"], group=gD, tooltip="The single oscillator the band-gated divergence is read on — kept sharp. The multi-factor layer contributes a separate CONSENSUS tell, not the divergence, so the two reads stay distinct.")
rsiLen   = input.int(14, "RSI length", minval=2, group=gD)
stochLen = input.int(14, "Stoch length", minval=2, group=gD)
kSmooth  = input.int(3, "Stoch %K smooth", minval=1, group=gD)
divPiv   = input.int(5, "Divergence pivot length", minval=2, maxval=30, group=gD)
confBand = input.string("1σ", "Confluence: pivot must reach", options=["Off","1σ","2σ"], group=gD, tooltip="A divergence only counts when its price pivot reached this band — discards mid-range divergences that carry no reversion context.")
showDivLine = input.bool(true, "Draw divergence lines + labels", group=gD)

gR = "06 · Regime Gate"
regMode  = input.string("Either", "Gate", options=["VR only","Reversion only","Either","Both","Off"], group=gR, tooltip="The 'is mean-reversion ON right now' switch. VR = variance-ratio < 1 (Lo-MacKinlay): increments offset rather than compound. Reversion = rolling correlation of prior deviation vs the next return is negative (price actively pulling back to its mean). Either / Both combine them. Off = score every fade.")
vrK      = input.int(5,   "VR horizon k (bars)", minval=2, maxval=30, group=gR)
vrLen    = input.int(100, "VR sample window", minval=20, maxval=400, group=gR)
vrBand   = input.float(0.10, "VR neutral band", minval=0.0, maxval=0.9, step=0.05, group=gR)
revMeanLen = input.int(20, "Reversion mean length", minval=5, group=gR)
revWin   = input.int(100, "Reversion corr window", minval=30, maxval=400, group=gR)
revThr   = input.float(0.15, "Reverting above corr score", minval=0.0, maxval=0.8, step=0.05, group=gR)

gN = "07 · Naked POC Magnets"
showNaked = input.bool(true, "Show untested prior-session POCs", group=gN, tooltip="A prior-session point of control never since traded through acts as a reversion TARGET; the nearest live one is the fade's magnet.")
nakedGrid = input.int(10, "Daily map grid (ticks/bin)", minval=1, maxval=200, group=gN)
nakedVa   = input.float(70, "Daily value-area %", minval=50, maxval=95, group=gN)
maxNaked  = input.int(15, "Keep last N naked POCs", minval=2, maxval=60, group=gN)

gW = "08 · Liquidity Sweeps"
useSweep  = input.bool(true, "Detect equal-high/low stop-runs", group=gW, tooltip="A wick beyond equal highs/lows that closes back inside is a stop-run — used only as a reversion TRIGGER when it lands at the band.")
swPiv     = input.int(8, "Swing pivot length", minval=2, maxval=30, group=gW)
swTolATR  = input.float(0.10, "Equal-level tolerance (x ATR)", minval=0.02, maxval=1.0, step=0.02, group=gW)

gF = "09 · Fade Signal"
confWin   = input.int(6, "Tell recency window (bars)", minval=1, maxval=30, group=gF, tooltip="A divergence or sweep counts toward a fade if it printed within this many bars of the band tag.")
fadeGap   = input.int(5, "Min bars between fades", minval=1, maxval=50, group=gF)
corrWin   = input.int(20, "Decorrelation window", minval=10, maxval=100, group=gF, tooltip="Window for the design-effect (Kish) shrink that stops correlated tells from inflating one confidence read.")
showFade  = input.bool(true, "Fade markers (gated)", group=gF)
showUngated = input.bool(false, "Also mark ungated-only fades (faint)", group=gF, tooltip="Diagnostic: shows fades the regime gate rejected. Off for a clean chart; turn on to see exactly what the gate is filtering out.")

gSc = "10 · Validation & Export Log"
horizon = input.int(10,  "Follow-through horizon (bars)", minval=3, maxval=100, group=gSc)
moveATR = input.float(0.5,"Follow-through size (x ATR)",   minval=0.1, maxval=3.0, step=0.1, group=gSc)
whipWin = input.int(10,  "Whipsaw window (bars)",          minval=2, maxval=60, group=gSc)
atrLen  = input.int(14,  "ATR length", minval=1, group=gSc)
logExport = input.bool(true, "Emit per-fade log (Data Window export)", group=gSc, tooltip="On each fade that RESOLVES (horizon bars after it fired) emit log:* series carrying the forward return in ATR (your R proxy), the gate flag, entry stretch and a win flag. Right-click the chart → Export chart data, then keep rows where log:fwdR_atr is non-empty — that is your per-trade R list. In-sample, close-to-close at the horizon, no costs/stops — a study aid, not a backtest.")

gV = "11 · Dashboard & Theme"
showPanel = input.bool(true, "Show validation panel", group=gV)
panelMode = input.string("Compact", "Panel detail", options=["Compact","Pro"], group=gV, tooltip="Compact (default): A/B scoreboard + expectancy + regime + multi-factor + now. Pro: also shows decorrelation, live tells, reversion score, naked-POC count, stretch and setup context.")
panelPos  = input.string("Bottom Left","Panel position", options=["Bottom Left","Bottom Right","Top Left","Top Right","Middle Left"], group=gV)
themeOpt  = input.string("Auto", "Panel theme", options=["Auto","Dark","Light"], group=gV, tooltip="Auto reads the chart background luminance so the panel stays legible on any colour scheme. Force Dark or Light to override.")

// ── 12 · MULTI-FACTOR DIVERGENCE CONFLUENCE (added layer) ───────────────
gMF = "12 · Multi-Factor Confluence"
mfOn      = input.bool(true, "Enable multi-factor confluence layer", group=gMF, tooltip="Nine 'is price stretched?' factors on one shared sigma scale. Counts how many are simultaneously at the extreme (consensus) and uses that breadth read as an extra fade tell — separate from the single-oscillator divergence.")
mfRefSym  = input.symbol("NSE:NIFTY", "Reference (cash / spot) symbol — Positioning factor", group=gMF, tooltip="Cash/spot series for the basis factor (chart - reference). Default NSE:NIFTY pairs with NIFTY futures.")
mfVwapSrc = input.source(hlc3, "VWAP source — Fair-value factor", group=gMF, tooltip="Series fed to the session VWAP. Needs real volume — use a futures contract.")
mfVWAPon  = input.bool(true, "Fair value (VWAP)",  inline="mf1", group=gMF)
mfRangeOn = input.bool(true, "Volatility (range)", inline="mf1", group=gMF)
mfEffOn   = input.bool(true, "Efficiency",         inline="mf2", group=gMF)
mfBasisOn = input.bool(true, "Positioning (basis)",inline="mf2", group=gMF)
mfSarOn   = input.bool(true, "Trend (SAR/ATR)",    inline="mf3", group=gMF)
mfRsiOn   = input.bool(true, "Momentum (RSI/StochRSI)", inline="mf3", group=gMF)
mfEquilOn = input.bool(true, "Equilibrium (linreg)",inline="mf4", group=gMF)
mfKstOn   = input.bool(true, "Cycle (KST)",        inline="mf4", group=gMF)
mfFlowOn  = input.bool(true, "Order flow (CVD)",   group=gMF)
mfMomSrc  = input.string("RSI", "Momentum factor source", options=["Stoch RSI","RSI"], group=gMF, tooltip="Which transform feeds the Momentum factor (and therefore the composite). Stoch RSI is more reactive; RSI is smoother. This is the only RSI-family input in the composite — Stoch RSI is NOT a separate factor, because it is a transform of RSI and adding it would double-count momentum.")
mfNormLen = input.int(50, "Normalization window (z-score)", minval=5, group=gMF)
mfExtSig  = input.float(2.5, "Extreme (σ)", minval=1.0, step=0.1, group=gMF, tooltip="A factor counts toward consensus when it sits beyond this many sigma.")
mfErLen   = input.int(20, "Efficiency length", minval=2, inline="ml1", group=gMF)
mfRngLen  = input.int(14, "Range length",      minval=2, inline="ml1", group=gMF)
mfEqLen   = input.int(50, "Equilibrium length",minval=5, group=gMF)
mfAuto    = input.bool(true, "Auto consensus threshold (by timeframe)", group=gMF, tooltip="Timeframe-adaptive consensus threshold: require 4 factors at the extreme on 1-minute, 3 on 2/3/5-minute, 2 on 15-minute and above. Clamped to the active-factor count.")
mfManualN = input.int(5, "Manual min factors at extreme", minval=1, maxval=9, group=gMF)
useMfTell = input.bool(true, "Use multi-factor confluence as a fade tell", group=gMF)
mfRequire = input.bool(false, "Require multi-factor confluence for a fade (gate)", group=gMF, tooltip="When on, a gated fade also needs the multi-factor consensus to agree (a consensus extreme on the fade side).")
showMfExt = input.bool(true, "Show extreme-consensus signals (Ext N)", group=gMF, tooltip="Mark bars where the multi-factor consensus reaches the extreme (factors past ±σ ≥ threshold): a dot on every extreme bar and an 'Ext N' tag (N = how many factors are stretched) when a new consensus run begins. Independent of the channel band.")
mfExtDot  = input.bool(true, "  · dot on every extreme bar", group=gMF)
mfExtTag  = input.bool(true, "  · Ext N tag on new consensus", group=gMF)

// ───────────────────────────── SETUP ──────────────────────────────────
int pivLen = switch pivFib
    "8"=>8
    "13"=>13
    "21"=>21
    "34"=>34
    "55"=>55
    "89"=>89
    =>21
float vw   = (na(volume) or volume <= 0) ? 1.0 : volume
float atrV = ta.atr(atrLen)

// ───────────────────────────── ENGINE: anchored poly + residual σ ──────
polyAVWAP(int paBar, int deg) =>
    var int   anc = na
    var float A0=0.0
    var float A1=0.0
    var float A2=0.0
    var float A3=0.0
    var float A4=0.0
    var float B0=0.0
    var float B1=0.0
    var float B2=0.0
    var float Q =0.0
    float Kp = 100.0
    float center = na
    float sigma  = na
    if not na(paBar)
        int span = bar_index - paBar
        if na(anc) or anc != paBar
            A0 := 0.0
            A1 := 0.0
            A2 := 0.0
            A3 := 0.0
            A4 := 0.0
            B0 := 0.0
            B1 := 0.0
            B2 := 0.0
            Q  := 0.0
            anc := paBar
            int seed = span < 1490 ? span : 1490
            for k = 0 to seed
                float u  = (span - k)/Kp
                float u2 = u*u
                float wk = vw[k]
                float yk = src[k]
                A0 += wk
                A1 += wk*u
                A2 += wk*u2
                A3 += wk*u2*u
                A4 += wk*u2*u2
                B0 += wk*yk
                B1 += wk*u*yk
                B2 += wk*u2*yk
                Q  += wk*yk*yk
        else
            float u  = span/Kp
            float u2 = u*u
            A0 += vw
            A1 += vw*u
            A2 += vw*u2
            A3 += vw*u2*u
            A4 += vw*u2*u2
            B0 += vw*src
            B1 += vw*u*src
            B2 += vw*u2*src
            Q  += vw*src*src
        if A0 > 0
            float uNow = span/Kp
            float c0 = na
            float c1 = 0.0
            float c2 = 0.0
            if deg <= 0
                c0 := B0/A0
            else if deg == 1
                float det = A0*A2 - A1*A1
                c0 := math.abs(det) > 1e-12 ? (B0*A2 - A1*B1)/det : B0/A0
                c1 := math.abs(det) > 1e-12 ? (A0*B1 - A1*B0)/det : 0.0
            else
                float e  = A2
                float f  = A3
                float h  = A3
                float ii = A4
                float det = A0*(e*ii - f*h) - A1*(A1*ii - f*A2) + A2*(A1*h - e*A2)
                if math.abs(det) > 1e-12
                    c0 := (B0*(e*ii - f*h) - A1*(B1*ii - f*B2) + A2*(B1*h - e*B2))/det
                    c1 := (A0*(B1*ii - f*B2) - B0*(A1*ii - f*A2) + A2*(A1*B2 - B1*A2))/det
                    c2 := (A0*(e*B2 - B1*h) - A1*(A1*B2 - B1*A2) + B0*(A1*h - e*A2))/det
                else
                    c0 := B0/A0
            center := c0 + c1*uNow + c2*uNow*uNow
            float sse = Q - (c0*B0 + c1*B1 + c2*B2)
            sigma := math.sqrt(math.max(sse/A0, 0.0))
    [center, sigma]

f_mapVA(m, st, pct) =>
    ks = map.keys(m)
    int nK = array.size(ks)
    float tot = 0.0
    float bestV = -1.0
    int bestK = 0
    int minK = nK > 0 ? array.get(ks, 0) : 0
    int maxK = nK > 0 ? array.get(ks, 0) : 0
    for i = 0 to nK - 1
        kk = array.get(ks, i)
        vv = map.get(m, kk)
        tot += vv
        if vv > bestV
            bestV := vv
            bestK := kk
        minK := math.min(minK, kk)
        maxK := math.max(maxK, kk)
    float acc = bestV
    int up = bestK
    int dn = bestK
    float target = tot * pct / 100.0
    span = maxK - minK + 2
    for n = 0 to span
        if acc >= target
            break
        upCan = up < maxK
        dnCan = dn > minK
        if not upCan and not dnCan
            break
        uV = upCan and map.contains(m, up + 1) ? map.get(m, up + 1) : 0.0
        dV = dnCan and map.contains(m, dn - 1) ? map.get(m, dn - 1) : 0.0
        if (uV >= dV and upCan) or not dnCan
            up += 1
            acc += uV
        else
            dn -= 1
            acc += dV
    [(bestK + 0.5) * st, (up + 1) * st, dn * st]

f_zscore(float x, int len) =>
    float m  = ta.sma(x, len)
    float sd = ta.stdev(x, len)
    sd == 0 ? 0.0 : (x - m) / sd

// ───────────────────────────── ANCHOR SELECTION ───────────────────────
pl = ta.pivotlow(low, pivLen, pivLen)
ph = ta.pivothigh(high, pivLen, pivLen)
var int lBar=na
var int hBar=na
if not na(pl)
    lBar := bar_index - pivLen
if not na(ph)
    hBar := bar_index - pivLen
bool dualLowRecent = nz(lBar,-1) >= nz(hBar,-1)
int dualBar = dualLowRecent ? lBar : hBar
int paBar = anchorMode == "Rolling" ? bar_index - (rollN - 1) : anchorMode == "Swing Low" ? lBar : anchorMode == "Swing High" ? hBar : dualBar
if na(paBar)
    paBar := bar_index - (rollN - 1)

[pvwap, psd] = polyAVWAP(paBar, polyDeg)

// ───────────────────────────── BANDS + PLOTS ──────────────────────────
bool  isUp = pvwap >= pvwap[1]
color tCol = isUp ? colUp : colDn
float u1 = pvwap + psd*mult1
float l1 = pvwap - psd*mult1
float u2 = pvwap + psd*mult2
float l2 = pvwap - psd*mult2

plot(glowOn ? pvwap : na, "halo 2", color=color.new(tCol, 77), linewidth=lw+6)
plot(glowOn ? pvwap : na, "halo 1", color=color.new(tCol, 49), linewidth=lw+2)
pMid = plot(pvwap, "AVWAP", color=tCol, linewidth=lw)
pU1 = plot(u1, "U1", color=color.new(tCol, glowOn ? 30 : 16))
pL1 = plot(l1, "L1", color=color.new(tCol, glowOn ? 30 : 16))
pU2 = plot(u2, "U2", color=color.new(tCol, glowOn ? 38 : 49))
pL2 = plot(l2, "L2", color=color.new(tCol, glowOn ? 38 : 49))
f_fc(int seg, bool up) =>
    fillMode == "Off" ? na : fillMode == "Reversion heat" ? color.new(up ? colDn : colUp, 84 - seg*16) : color.new(tCol, glowOn ? math.min(96, 82 + seg*9) : (seg == 0 ? 81 : 88))
fill(pMid, pU1, f_fc(0, true),  title="Fill 1σ up")
fill(pMid, pL1, f_fc(0, false), title="Fill 1σ dn")
fill(pU1,  pU2, f_fc(1, true),  title="Fill 2σ up")
fill(pL1,  pL2, f_fc(1, false), title="Fill 2σ dn")

// ───────────────────────────── VOLUME PROFILE (last bar) ──────────────
var line  pocLn=na
var box   vaBox=na
var label pocLb=na
var label vahLb=na
var label valLb=na
float vpPOC = na
if barstate.islast and showVP
    line.delete(pocLn)
    box.delete(vaBox)
    label.delete(pocLb)
    label.delete(vahLb)
    label.delete(valLb)
    int winLen = anchorMode == "Rolling" ? rollN : math.min(bar_index - paBar + 1, 1490)
    if not na(winLen) and winLen > 2
        int xa = math.max(0, bar_index - winLen + 1)
        int xe = bar_index + math.min(math.round(winLen*0.25), 60)
        float hi = high
        float lo = low
        for i = 0 to winLen - 1
            hi := math.max(hi, high[i])
            lo := math.min(lo, low[i])
        float step = (hi - lo) / vpBins
        if step > 0
            array<float> buckets = array.new<float>(vpBins, 0.0)
            for i = 0 to winLen - 1
                int idx = math.max(0, math.min(vpBins-1, int(math.floor((src[i]-lo)/step))))
                array.set(buckets, idx, array.get(buckets, idx) + vw[i])
            int pocBin = array.indexof(buckets, array.max(buckets))
            vpPOC := lo + (pocBin + 0.5)*step
            float tot = array.sum(buckets)
            float vaV = array.get(buckets, pocBin)
            int up = pocBin
            int dn = pocBin
            while vaV < tot*vaPct and (up < vpBins-1 or dn > 0)
                float aV = up < vpBins-1 ? array.get(buckets, up+1) : -1.0
                float bV = dn > 0 ? array.get(buckets, dn-1) : -1.0
                if aV < 0 and bV < 0
                    break
                if aV >= bV
                    up += 1
                    vaV += aV
                else
                    dn -= 1
                    vaV += bV
            float vah = lo + (up+1)*step
            float val = lo + dn*step
            vaBox := box.new(xa, vah, xe, val, border_color=color.new(colPoc,28), border_width=1, bgcolor=color.new(colPoc,86))
            pocLn := line.new(xa, vpPOC, xe, vpPOC, color=colPoc, width=2)
            pocLb := label.new(xe, vpPOC, "POC", style=label.style_label_left, color=color.new(colPoc,10), textcolor=color.white, size=size.small)
            vahLb := label.new(xe, vah, "VAH", style=label.style_label_left, color=color.new(colPoc,15), textcolor=color.white, size=size.tiny)
            valLb := label.new(xe, val, "VAL", style=label.style_label_left, color=color.new(colPoc,15), textcolor=color.white, size=size.tiny)

// ── MULTI-FACTOR CONFLUENCE ENGINE — nine factors on a shared σ scale; feeds the consensus tell + the Ext N marks (divergence stays a separate single-oscillator read)
float mfRefClose = request.security(mfRefSym, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
bool  mfBasisLive = not na(mfRefClose) and mfRefClose != 0
bool  mfVolLive   = ta.cum(nz(volume)) > 0
float mfVwapV = ta.vwap(mfVwapSrc)
float zfVwap  = f_zscore(src - mfVwapV, mfNormLen)
float zfRangeMag = f_zscore(srcHigh - srcLow, mfNormLen)
float mfRngDir = math.sign(src - src[mfRngLen])
float zfRange  = zfRangeMag * (mfRngDir == 0 ? 1.0 : mfRngDir)
float mfErChg = src - src[mfErLen]
float mfErVol = math.sum(math.abs(src - src[1]), mfErLen)
float mfErSer = mfErVol == 0 ? 0.0 : mfErChg / mfErVol
float zfEff   = f_zscore(mfErSer, mfNormLen)
float zfBasis = f_zscore(src - mfRefClose, mfNormLen)
float mfSar   = ta.sar(0.02, 0.02, 0.2)
int   mfSarDir = src > mfSar ? 1 : src < mfSar ? -1 : 0
float mfSarExt = mfSarDir == 1 ? (srcHigh - mfSar) : mfSarDir == -1 ? (mfSar - srcLow) : 0.0
float mfSarMag = (not na(atrV) and atrV > 0) ? math.max(0.0, math.min(mfSarExt / atrV, 10.0)) : 0.0
float zfSar   = f_zscore(mfSarMag, mfNormLen) * mfSarDir
float mfRsiRaw = ta.rsi(src, rsiLen)
float mfStoch  = ta.sma(ta.stoch(mfRsiRaw, mfRsiRaw, mfRsiRaw, stochLen), kSmooth)
float mfMom    = mfMomSrc == "RSI" ? mfRsiRaw : mfStoch
float zfRsi    = f_zscore(mfMom, mfNormLen)
float mfFair  = ta.linreg(src, mfEqLen, 0)
float mfEqDev = (not na(atrV) and atrV > 0) ? (src - mfFair) / atrV : 0.0
float zfEquil = f_zscore(mfEqDev, mfNormLen)
float mfRoc10 = ta.roc(src, 10)
float mfRoc15 = ta.roc(src, 15)
float mfRoc20 = ta.roc(src, 20)
float mfRoc30 = ta.roc(src, 30)
float mfKstV  = ta.sma(mfRoc10, 10) * 1.0 + ta.sma(mfRoc15, 10) * 2.0 + ta.sma(mfRoc20, 10) * 3.0 + ta.sma(mfRoc30, 15) * 4.0
float zfKst   = f_zscore(mfKstV, mfNormLen)
float mfBf    = (srcHigh - srcLow) == 0 ? 0.5 : math.max(0.0, math.min(1.0, (close - srcLow) / (srcHigh - srcLow)))
float mfSv    = volume * (2 * mfBf - 1)
float mfCvd   = ta.cum(mfSv)
float mfResid = mfCvd - ta.ema(mfCvd, mfNormLen)
float zfFlow  = f_zscore(mfResid, mfNormLen)

bool afVwap  = mfOn and mfVWAPon and mfVolLive and not na(mfVwapV)
bool afRange = mfOn and mfRangeOn
bool afEff   = mfOn and mfEffOn
bool afBasis = mfOn and mfBasisOn and mfBasisLive
bool afSar   = mfOn and mfSarOn
bool afRsi   = mfOn and mfRsiOn
bool afEquil = mfOn and mfEquilOn
bool afKst   = mfOn and mfKstOn
bool afFlow  = mfOn and mfFlowOn and mfVolLive

array<float> mfZA = array.from(zfVwap, zfRange, zfEff, zfBasis, zfSar, zfRsi, zfEquil, zfKst, zfFlow)
array<bool>  mfAA = array.from(afVwap, afRange, afEff, afBasis, afSar, afRsi, afEquil, afKst, afFlow)
float mfZSum = 0.0
int mfActN = 0
int mfExtHi = 0
int mfExtLo = 0
for i = 0 to 8
    if array.get(mfAA, i)
        float zz = array.get(mfZA, i)
        if not na(zz)
            mfActN += 1
            mfZSum += zz
            mfExtHi += (zz >= mfExtSig ? 1 : 0)
            mfExtLo += (zz <= -mfExtSig ? 1 : 0)
float mfMeanZ = mfActN > 0 ? mfZSum / mfActN : 0.0
int mfTfNeed = timeframe.in_seconds() <= 60 ? 4 : timeframe.in_seconds() <= 300 ? 3 : 2
int mfNeedN  = mfAuto ? math.min(mfTfNeed, math.max(1, mfActN)) : math.min(mfManualN, math.max(1, mfActN))
bool mfConsUp = mfOn and mfActN > 0 and mfExtHi >= mfNeedN
bool mfConsDn = mfOn and mfActN > 0 and mfExtLo >= mfNeedN
bool mfBearTell = useMfTell and mfOn and mfConsUp
bool mfBullTell = useMfTell and mfOn and mfConsDn

// extreme-consensus signals on price (the composite oscillator's "Ext N" marks, on the overlay)
plotshape(showMfExt and mfExtDot and mfConsUp ? high : na, "Consensus extreme OB", shape.circle, location.abovebar, color.new(colDn, 0), size=size.tiny)
plotshape(showMfExt and mfExtDot and mfConsDn ? low  : na, "Consensus extreme OS", shape.circle, location.belowbar, color.new(colUp, 0), size=size.tiny)
var array<label> mfExtLabs = array.new<label>()
if showMfExt and mfExtTag and mfConsUp and not mfConsUp[1]
    array.push(mfExtLabs, label.new(bar_index, high, "Ext " + str.tostring(mfExtHi), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(colDn, 18), textcolor=color.white, size=size.tiny))
    while array.size(mfExtLabs) > 40
        label.delete(array.shift(mfExtLabs))
if showMfExt and mfExtTag and mfConsDn and not mfConsDn[1]
    array.push(mfExtLabs, label.new(bar_index, low, "Ext " + str.tostring(mfExtLo), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(colUp, 18), textcolor=color.white, size=size.tiny))
    while array.size(mfExtLabs) > 40
        label.delete(array.shift(mfExtLabs))

// ───────────────────────────── DIVERGENCE ─────────────────────────────
float rsiV     = ta.rsi(close, rsiLen)
float stochRsi = ta.sma(ta.stoch(rsiV, rsiV, rsiV, stochLen), kSmooth)
float osc      = oscType == "RSI" ? rsiV : stochRsi
phD = ta.pivothigh(srcHigh, divPiv, divPiv)
plD = ta.pivotlow(srcLow, divPiv, divPiv)
var float dLastPH=na
var float dPrevPH=na
var float dLastPHo=na
var float dPrevPHo=na
var int   dLastPHb=na
var int   dPrevPHb=na
var float dLastPL=na
var float dPrevPL=na
var float dLastPLo=na
var float dPrevPLo=na
var int   dLastPLb=na
var int   dPrevPLb=na
bool atUp = confBand == "Off" ? true : confBand == "2σ" ? srcHigh[divPiv] >= u2[divPiv] : srcHigh[divPiv] >= u1[divPiv]
bool atLo = confBand == "Off" ? true : confBand == "2σ" ? srcLow[divPiv]  <= l2[divPiv] : srcLow[divPiv]  <= l1[divPiv]
bool bearDiv = false
bool bullDiv = false
if not na(phD)
    dPrevPH  := dLastPH
    dPrevPHo := dLastPHo
    dPrevPHb := dLastPHb
    dLastPH  := phD
    dLastPHo := osc[divPiv]
    dLastPHb := bar_index - divPiv
    if not na(dPrevPH) and not na(dPrevPHo)
        bearDiv := showDiv and dLastPH > dPrevPH and dLastPHo < dPrevPHo and atUp
if not na(plD)
    dPrevPL  := dLastPL
    dPrevPLo := dLastPLo
    dPrevPLb := dLastPLb
    dLastPL  := plD
    dLastPLo := osc[divPiv]
    dLastPLb := bar_index - divPiv
    if not na(dPrevPL) and not na(dPrevPLo)
        bullDiv := showDiv and dLastPL < dPrevPL and dLastPLo > dPrevPLo and atLo
plotshape(bearDiv ? srcHigh[divPiv] : na, "Bear div", shape.diamond, location.absolute, color.new(colDn,0), size=size.tiny, offset=-divPiv)
plotshape(bullDiv ? srcLow[divPiv]  : na, "Bull div", shape.diamond, location.absolute, color.new(colUp,0), size=size.tiny, offset=-divPiv)
var array<line>  dLines = array.new<line>()
var array<label> dLabs  = array.new<label>()
f_divDraw(int x1, float y1, int x2, float y2, color c) =>
    if glowOn
        array.push(dLines, line.new(x1, y1, x2, y2, color=color.new(c, 80), width=6))
        array.push(dLines, line.new(x1, y1, x2, y2, color=color.new(c, 60), width=4))
    array.push(dLines, line.new(x1, y1, x2, y2, color=color.new(c, 0), width=2, style=line.style_dashed))
    while array.size(dLines) > 90
        line.delete(array.shift(dLines))
    0
if showDivLine and bearDiv and not na(dPrevPHb)
    f_divDraw(dPrevPHb, dPrevPH, dLastPHb, dLastPH, colDn)
    array.push(dLabs, label.new(dLastPHb, dLastPH, "Div", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(colDn, 12), textcolor=color.white, size=size.tiny))
    while array.size(dLabs) > 30
        label.delete(array.shift(dLabs))
if showDivLine and bullDiv and not na(dPrevPLb)
    f_divDraw(dPrevPLb, dPrevPL, dLastPLb, dLastPL, colUp)
    array.push(dLabs, label.new(dLastPLb, dLastPL, "Div", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(colUp, 12), textcolor=color.white, size=size.tiny))
    while array.size(dLabs) > 30
        label.delete(array.shift(dLabs))
var int lastBearDivBar = na
var int lastBullDivBar = na
if bearDiv
    lastBearDivBar := bar_index
if bullDiv
    lastBullDivBar := bar_index


// ───────────────────────────── REGIME GATE ────────────────────────────
float ret  = math.log(close / close[1])
float r1v  = ta.variance(ret, vrLen)
float retK = math.log(close / close[vrK])
float rKv  = ta.variance(retK, vrLen)
float vr   = (r1v != 0 and vrK > 0) ? rKv / (vrK * r1v) : 1.0
bool  revertVR = vr <= 1.0 - vrBand
bool  trendVR  = vr >= 1.0 + vrBand
float revMean  = ta.sma(close, revMeanLen)
float revDev   = close - revMean
float revRet   = close - close[1]
float revCorr  = ta.correlation(revDev[1], revRet, revWin)
float revScore = not na(revCorr) ? math.max(0.0, -revCorr) : na
bool  reverting = not na(revScore) and revScore >= revThr
bool  regimeOK = regMode == "Off" ? true : regMode == "VR only" ? revertVR : regMode == "Reversion only" ? reverting : regMode == "Both" ? (revertVR and reverting) : (revertVR or reverting)

// ───────────────────────────── NAKED POC MAGNETS ──────────────────────
float nkStep = syminfo.mintick * nakedGrid
var map<int, float> nkMap = map.new<int, float>()
var array<float> nkPx   = array.new<float>(0)
var array<bool>  nkLive = array.new<bool>(0)
bool newDay = ta.change(time("D")) != 0
if showNaked and newDay and map.size(nkMap) > 0
    [dP, dH, dL] = f_mapVA(nkMap, nkStep, nakedVa)
    map.clear(nkMap)
    if not na(dP)
        bool straddled = false
        int lbk = math.min(20, bar_index)
        for kk = 0 to lbk
            if low[kk] <= dP and high[kk] >= dP
                straddled := true
                break
        if not straddled
            array.push(nkPx, dP)
            array.push(nkLive, true)
            if array.size(nkPx) > maxNaked
                array.shift(nkPx)
                array.shift(nkLive)
if showNaked and nkStep > 0 and high >= low
    float nVol = vw
    float nRng = high - low
    int   nSub = nRng <= 0 ? 1 : int(math.min(16, int(nRng / nkStep) + 1))
    float nVp = nVol / nSub
    for s = 0 to nSub - 1
        float nPx = nSub == 1 ? hlc3 : low + nRng * s / (nSub - 1)
        int nK = int(math.floor(nPx / nkStep))
        float pv = map.contains(nkMap, nK) ? map.get(nkMap, nK) : 0.0
        map.put(nkMap, nK, pv + nVp)
if showNaked and array.size(nkPx) > 0
    for i = 0 to array.size(nkPx) - 1
        if array.get(nkLive, i) and low <= array.get(nkPx, i) and high >= array.get(nkPx, i)
            array.set(nkLive, i, false)
float nkMagnet = na
float nkMagD = 1e20
if array.size(nkPx) > 0
    for i = 0 to array.size(nkPx) - 1
        if array.get(nkLive, i)
            float d = math.abs(array.get(nkPx, i) - close)
            if d < nkMagD
                nkMagD := d
                nkMagnet := array.get(nkPx, i)
var array<line> nkLines = array.new<line>()
if showNaked and barstate.islast
    if array.size(nkLines) > 0
        for ln in nkLines
            line.delete(ln)
        array.clear(nkLines)
    int nlx = bar_index - math.min(200, bar_index)
    int nrx = bar_index + 3
    if array.size(nkPx) > 0
        for i = 0 to array.size(nkPx) - 1
            if array.get(nkLive, i)
                float yv = array.get(nkPx, i)
                bool isMag = not na(nkMagnet) and yv == nkMagnet
                array.push(nkLines, line.new(nlx, yv, nrx, yv, color=color.new(#b39ddb, isMag ? 0 : 50), width=isMag ? 2 : 1, style=line.style_dashed))

// ───────────────────────────── LIQUIDITY SWEEP ────────────────────────
phS = ta.pivothigh(swPiv, swPiv)
plS = ta.pivotlow(swPiv, swPiv)
var float lastPH=na
var float prevPH=na
var float lastPL=na
var float prevPL=na
if not na(phS)
    prevPH := lastPH
    lastPH := phS
if not na(plS)
    prevPL := lastPL
    lastPL := plS
float eqDist = swTolATR * atrV
var float eqhLvl=na
var float eqlLvl=na
if not na(phS) and not na(prevPH) and math.abs(lastPH - prevPH) <= eqDist
    eqhLvl := math.max(lastPH, prevPH)
if not na(plS) and not na(prevPL) and math.abs(lastPL - prevPL) <= eqDist
    eqlLvl := math.min(lastPL, prevPL)
bool sweepHigh = useSweep and ((not na(eqhLvl) and high > eqhLvl and close < eqhLvl) or (not na(lastPH) and high > lastPH and close < lastPH and close < open))
bool sweepLow  = useSweep and ((not na(eqlLvl) and low  < eqlLvl and close > eqlLvl) or (not na(lastPL) and low  < lastPL and close > lastPL and close > open))
var int lastSweepHiBar=na
var int lastSweepLoBar=na
if sweepHigh
    lastSweepHiBar := bar_index
if sweepLow
    lastSweepLoBar := bar_index
bool freshSweepHi = not na(lastSweepHiBar) and (bar_index - lastSweepHiBar) <= 3
bool freshSweepLo = not na(lastSweepLoBar) and (bar_index - lastSweepLoBar) <= 3

// ───────────────────────────── FADE SIGNAL + CONFIDENCE ───────────────
float z = psd > 0 ? (close - pvwap)/psd : 0.0
bool tagUpper = high >= u2
bool tagLower = low  <= l2
bool rejUpper = tagUpper and close < u2
bool rejLower = tagLower and close > l2
bool recentDivU = not na(lastBearDivBar) and (bar_index - lastBearDivBar) <= confWin
bool recentDivL = not na(lastBullDivBar) and (bar_index - lastBullDivBar) <= confWin
// tells present at each side (rejection · divergence · sweep · multi-factor confluence)
int tellsU = (rejUpper ? 1 : 0) + (recentDivU ? 1 : 0) + (freshSweepHi ? 1 : 0) + (mfBearTell ? 1 : 0)
int tellsL = (rejLower ? 1 : 0) + (recentDivL ? 1 : 0) + (freshSweepLo ? 1 : 0) + (mfBullTell ? 1 : 0)
int maxTells = 3 + (useMfTell ? 1 : 0)
// Kish design-effect shrink from the three continuous tell-drivers
float sStretch = z
float sOsc = osc
float sClv = (high - low) > 0 ? ((close - low) - (high - close))/(high - low) : 0.0
float rA = ta.correlation(sStretch, sOsc, corrWin)
float rB = ta.correlation(sStretch, sClv, corrWin)
float rC = ta.correlation(sOsc, sClv, corrWin)
float rhoBar = (math.abs(nz(rA)) + math.abs(nz(rB)) + math.abs(nz(rC))) / 3.0
float nEff = 3.0 / (1.0 + 2.0 * rhoBar)
float famShrink = nEff / 3.0
f_conf(int tells) =>
    float eff = tells >= 1 ? 1.0 + (tells - 1) * famShrink : 0.0
    math.round(math.min(100.0, eff / float(maxTells) * 100.0))
int confU = f_conf(tellsU)
int confL = f_conf(tellsL)

var int lastFadeBar = na
bool cool = na(lastFadeBar) or (bar_index - lastFadeBar) >= fadeGap
bool shortRaw = tagUpper and tellsU >= 1 and cool
bool longRaw  = tagLower and tellsL >= 1 and cool
if shortRaw or longRaw
    lastFadeBar := bar_index
bool shortGated = shortRaw and regimeOK and (not mfRequire or mfBearTell)
bool longGated  = longRaw  and regimeOK and (not mfRequire or mfBullTell)

// markers
plotshape(showFade and shortGated ? high : na, "Fade short", shape.triangledown, location.abovebar, color.new(colDn,0), size=size.small)
plotshape(showFade and longGated  ? low  : na, "Fade long",  shape.triangleup,   location.belowbar, color.new(colUp,0), size=size.small)
plotshape(showUngated and shortRaw and not regimeOK ? high : na, "Fade short (ungated)", shape.triangledown, location.abovebar, color.new(colDn,70), size=size.tiny)
plotshape(showUngated and longRaw and not regimeOK ? low : na, "Fade long (ungated)", shape.triangleup, location.belowbar, color.new(colUp,70), size=size.tiny)

// ───────────────────────────── A/B SCORING HARNESS ────────────────────
// model 0 = ungated (all fades) · model 1 = gated (regime-OK only)
var array<int>   breaksN     = array.new<int>(2, 0)
var array<int>   whipN       = array.new<int>(2, 0)
var array<int>   whipPrevBar = array.new<int>(2, -1)
var array<int>   whipPrevDir = array.new<int>(2, 0)
var array<int>   calTot      = array.new<int>(2, 0)
var array<int>   calHit      = array.new<int>(2, 0)
var array<int>   pBar = array.new<int>(0)
var array<float> pPx  = array.new<float>(0)
var array<float> pAtr = array.new<float>(0)
var array<int>   pDir = array.new<int>(0)
var array<bool>  pGat = array.new<bool>(0)
var array<float> pZ   = array.new<float>(0)
var array<int>   pTime= array.new<int>(0)
var array<float> rSum = array.new<float>(2, 0.0)
var array<int>   rN   = array.new<int>(2, 0)

logFade(int dir, bool gated) =>
    int pb0 = array.get(whipPrevBar, 0)
    int pd0 = array.get(whipPrevDir, 0)
    if pb0 != -1 and dir != pd0 and (bar_index - pb0) <= whipWin
        array.set(whipN, 0, array.get(whipN, 0) + 1)
    array.set(whipPrevBar, 0, bar_index)
    array.set(whipPrevDir, 0, dir)
    array.set(breaksN, 0, array.get(breaksN, 0) + 1)
    if gated
        int pb1 = array.get(whipPrevBar, 1)
        int pd1 = array.get(whipPrevDir, 1)
        if pb1 != -1 and dir != pd1 and (bar_index - pb1) <= whipWin
            array.set(whipN, 1, array.get(whipN, 1) + 1)
        array.set(whipPrevBar, 1, bar_index)
        array.set(whipPrevDir, 1, dir)
        array.set(breaksN, 1, array.get(breaksN, 1) + 1)
    array.push(pBar, bar_index)
    array.push(pPx,  close)
    array.push(pAtr, atrV)
    array.push(pDir, dir)
    array.push(pGat, gated)
    array.push(pZ,   z)
    array.push(pTime, time)

float logTimeX = na
float logDirX  = na
float logGatX  = na
float logZX    = na
float logFwdRX = na
float logRawRX = na
float logWinX  = na
if barstate.isconfirmed
    if shortRaw
        logFade(-1, regimeOK and (not mfRequire or mfBearTell))
    if longRaw
        logFade(1, regimeOK and (not mfRequire or mfBullTell))
    int qi = 0
    while qi < array.size(pBar)
        if bar_index - array.get(pBar, qi) >= horizon
            float p0 = array.get(pPx, qi)
            float a0 = array.get(pAtr, qi)
            int   dr = array.get(pDir, qi)
            bool  gt = array.get(pGat, qi)
            float mv = close - p0
            bool  hit = dr == 1 ? mv >= moveATR*a0 : mv <= -moveATR*a0
            float fwdR = a0 > 0 ? dr * mv / a0 : na
            array.set(calTot, 0, array.get(calTot, 0) + 1)
            if hit
                array.set(calHit, 0, array.get(calHit, 0) + 1)
            if not na(fwdR)
                array.set(rSum, 0, array.get(rSum, 0) + fwdR)
                array.set(rN,   0, array.get(rN,   0) + 1)
            if gt
                array.set(calTot, 1, array.get(calTot, 1) + 1)
                if hit
                    array.set(calHit, 1, array.get(calHit, 1) + 1)
                if not na(fwdR)
                    array.set(rSum, 1, array.get(rSum, 1) + fwdR)
                    array.set(rN,   1, array.get(rN,   1) + 1)
            logTimeX := array.get(pTime, qi)
            logDirX  := dr
            logGatX  := gt ? 1.0 : 0.0
            logZX    := array.get(pZ, qi)
            logFwdRX := fwdR
            logRawRX := a0 > 0 ? mv / a0 : na
            logWinX  := hit ? 1.0 : 0.0
            array.remove(pBar, qi)
            array.remove(pPx,  qi)
            array.remove(pAtr, qi)
            array.remove(pDir, qi)
            array.remove(pGat, qi)
            array.remove(pZ,   qi)
            array.remove(pTime, qi)
        else
            qi += 1
    while array.size(pBar) > 500
        array.shift(pBar)
        array.shift(pPx)
        array.shift(pAtr)
        array.shift(pDir)
        array.shift(pGat)
        array.shift(pZ)
        array.shift(pTime)

// ───────────────────────────── PER-FADE EXPORT LOG ────────────────────
plot(logExport and not na(logFwdRX) ? logTimeX : na, "log:txn_time_ms",        display=display.data_window)
plot(logExport and not na(logFwdRX) ? logDirX  : na, "log:dir 1long/-1short",  display=display.data_window)
plot(logExport and not na(logFwdRX) ? logGatX  : na, "log:gated 1/0",          display=display.data_window)
plot(logExport and not na(logFwdRX) ? logZX    : na, "log:stretch_sigma",      display=display.data_window)
plot(logExport and not na(logFwdRX) ? logFwdRX : na, "log:fwdR_atr",           display=display.data_window)
plot(logExport and not na(logFwdRX) ? logRawRX : na, "log:rawRet_atr_signed",  display=display.data_window)
plot(logExport and not na(logFwdRX) ? logWinX  : na, "log:win 1/0",            display=display.data_window)

// ───────────────────────────── A/B PANEL (Compact / Pro) ──────────────
f_propCI(int hits, int total) =>
    float lo = na
    float hi = na
    if total >= 5
        float p   = hits / float(total)
        float zc  = 1.96
        float den = 1.0 + zc*zc/total
        float cen = (p + zc*zc/(2.0*total)) / den
        float hw  = zc * math.sqrt(p*(1.0-p)/total + zc*zc/(4.0*total*total)) / den
        lo := math.max(0.0, cen - hw)
        hi := math.min(1.0, cen + hw)
    [lo, hi]

bool panelDark = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (0.299*color.r(chart.bg_color) + 0.587*color.g(chart.bg_color) + 0.114*color.b(chart.bg_color)) < 128
color cBg      = panelDark ? color.new(#0d1117, 8)  : color.new(#ffffff, 6)
color cBord    = panelDark ? color.new(#2b3340, 0)  : color.new(#c2c8d0, 0)
color cTxt     = panelDark ? #c2cbd6 : #3a424e
color cStrong  = panelDark ? #f2f4f8 : #10151d
color cMut     = panelDark ? #9aa3b2 : #707a86
color cHdr     = panelDark ? color.new(#161d2b, 0) : color.new(#e9edf2, 0)
color cAccent  = panelDark ? #79c0ff : #1f6feb
color cAccent2 = panelDark ? #ffd166 : #9a6a00
color cAmber   = panelDark ? #e3b341 : #9a6a00
color cBull    = panelDark ? #2dd4bf : #0e7c5a
color cBear    = panelDark ? #ff6b6b : #c62828
ppMap = panelPos == "Bottom Right" ? position.bottom_right : panelPos == "Top Left" ? position.top_left : panelPos == "Top Right" ? position.top_right : panelPos == "Middle Left" ? position.middle_left : position.bottom_left
var table T = table.new(ppMap, 5, 16, bgcolor=cBg, border_color=cBord, border_width=1)
f_state(tbl, int r, string k, string v, color vc, string x) =>
    table.cell(tbl,0,r,k, text_color=cTxt, text_size=size.small, text_formatting=text.format_bold)
    table.cell(tbl,1,r,v, text_color=vc, text_size=size.small, text_formatting=text.format_bold)
    table.cell(tbl,2,r,x, text_color=cMut, text_size=size.small, text_formatting=text.format_bold)
    table.cell(tbl,3,r,"", text_color=cTxt, text_size=size.small)
    table.cell(tbl,4,r,"", text_color=cTxt, text_size=size.small)
if showPanel and barstate.islast
    table.clear(T, 0, 0, 4, 15)
    bool pro = panelMode == "Pro"
    int ri = 0
    table.cell(T,0,ri, pro ? "Reversion A/B · Pro" : "Reversion A/B", text_color=cAccent, text_size=size.small, bgcolor=cHdr, text_formatting=text.format_bold)
    table.cell(T,1,ri,"Brk",    text_color=cTxt, text_size=size.small, bgcolor=cHdr, text_formatting=text.format_bold)
    table.cell(T,2,ri,"FT%",    text_color=cTxt, text_size=size.small, bgcolor=cHdr, text_formatting=text.format_bold)
    table.cell(T,3,ri,"95% CI", text_color=cTxt, text_size=size.small, bgcolor=cHdr, text_formatting=text.format_bold)
    table.cell(T,4,ri,"Whip%",  text_color=cTxt, text_size=size.small, bgcolor=cHdr, text_formatting=text.format_bold)
    ri += 1
    array<string> nm = array.from("Gate OFF", "Gate ON")
    for m = 0 to 1
        int brk = array.get(breaksN, m)
        int tot = array.get(calTot, m)
        int hit = array.get(calHit, m)
        int wp  = array.get(whipN, m)
        float ftr = tot > 0 ? hit*100.0/tot : na
        [lo, hi] = f_propCI(hit, tot)
        float wpr = brk > 0 ? wp*100.0/brk : na
        string ftTxt = tot == 0 ? "—" : tot < 5 ? "warm" : str.tostring(ftr,"0") + "%"
        string ciTxt = na(lo) ? "—" : str.tostring(math.round(lo*100)) + "–" + str.tostring(math.round(hi*100)) + "%"
        string wpTxt = brk == 0 ? "—" : str.tostring(wpr,"0") + "%"
        color  ftCol = tot < 5 ? cMut : ftr >= 55 ? cBull : ftr >= 45 ? cAmber : cBear
        color  wpCol = brk == 0 ? cMut : wpr <= 25 ? cBull : wpr <= 45 ? cAmber : cBear
        table.cell(T,0,ri, array.get(nm,m), text_color=(m==1?cAccent2:cStrong), text_size=size.small, text_formatting=text.format_bold)
        table.cell(T,1,ri, str.tostring(brk), text_color=cStrong, text_size=size.small, text_formatting=text.format_bold)
        table.cell(T,2,ri, ftTxt, text_color=ftCol, text_size=size.small, text_formatting=text.format_bold)
        table.cell(T,3,ri, ciTxt, text_color=cStrong, text_size=size.small, text_formatting=text.format_bold)
        table.cell(T,4,ri, wpTxt, text_color=wpCol, text_size=size.small, text_formatting=text.format_bold)
        ri += 1
    int    rn0 = array.get(rN, 0)
    int    rn1 = array.get(rN, 1)
    float  er0 = rn0 > 0 ? array.get(rSum, 0)/rn0 : na
    float  er1 = rn1 > 0 ? array.get(rSum, 1)/rn1 : na
    string er0Txt = rn0 < 5 ? "warm" : str.tostring(er0, "+0.00;-0.00")
    string er1Txt = rn1 < 5 ? "warm" : str.tostring(er1, "+0.00;-0.00")
    color  erCol = rn1 < 5 ? cMut : er1 > 0.03 ? cBull : er1 < -0.03 ? cBear : cAmber
    f_state(T, ri, "Exp R off/on", er0Txt + " / " + er1Txt, erCol, "mean R/fade · n " + str.tostring(rn1))
    ri += 1
    string regTxt = "VR " + str.tostring(vr,"0.00") + (revertVR ? " ▼rev" : trendVR ? " ▲trend" : " ·") + (reverting ? " · corr✓" : "")
    f_state(T, ri, "Regime", regimeOK ? "ON" : "off", regimeOK ? cBull : cMut, regTxt)
    ri += 1
    string mfTxt = mfActN > 0 ? "OB " + str.tostring(mfExtHi) + " / OS " + str.tostring(mfExtLo) + " (need " + str.tostring(mfNeedN) + ")" : "no data"
    color  mfCol = mfConsUp ? cBear : mfConsDn ? cBull : cMut
    string mfSt  = mfConsUp ? "OVERBOUGHT" : mfConsDn ? "OVERSOLD" : "—"
    f_state(T, ri, "Multi-factor", mfSt, mfCol, mfTxt)
    ri += 1
    string fadeNow = shortGated ? "▼ SHORT " + str.tostring(confU) + "%" : longGated ? "▲ LONG " + str.tostring(confL) + "%" : tagUpper ? "at upper · wait" : tagLower ? "at lower · wait" : "—"
    f_state(T, ri, "Now", fadeNow, shortGated ? cBear : longGated ? cBull : cMut, na(nkMagnet) ? "" : ("→ POC " + str.tostring(nkMagnet, format.mintick)))
    ri += 1
    if pro
        f_state(T, ri, "Decorr ρ̄", str.tostring(rhoBar,"0.00"), cStrong, "×" + str.tostring(famShrink,"0.00") + " shrink")
        ri += 1
        string tU = (rejUpper?"R":"·") + (recentDivU?"D":"·") + (freshSweepHi?"S":"·") + (mfBearTell?"M":"·")
        string tL = (rejLower?"R":"·") + (recentDivL?"D":"·") + (freshSweepLo?"S":"·") + (mfBullTell?"M":"·")
        f_state(T, ri, "Tells U/L", tU + " / " + tL, cStrong, "conf " + str.tostring(math.max(confU, confL)) + "%")
        ri += 1
        f_state(T, ri, "Reversion", str.tostring(nz(revScore),"0.00") + (reverting ? " ✓" : " ·"), reverting ? cBull : cMut, "≥ " + str.tostring(revThr,"0.00"))
        ri += 1
        int liveN = 0
        if array.size(nkLive) > 0
            for i = 0 to array.size(nkLive) - 1
                if array.get(nkLive, i)
                    liveN += 1
        string nkDist = na(nkMagnet) or na(atrV) or atrV == 0 ? "—" : str.tostring(nkMagD/atrV, "0.0") + " ATR away"
        f_state(T, ri, "Naked POC", str.tostring(liveN) + " live", cStrong, nkDist)
        ri += 1
        f_state(T, ri, "Composite", str.tostring(mfMeanZ,"0.00") + "σ · " + str.tostring(mfActN) + " factors", cStrong, "stretch " + str.tostring(z,"0.00") + "σ")
        ri += 1
        f_state(T, ri, "Setup", anchorMode + " · d" + str.tostring(polyDeg), cStrong, syminfo.ticker + " " + timeframe.period)
        ri += 1

// ───────────────────────────── MTF S/R LINES (1/3/5/15/30/60) ──────────
gM = "13 · MTF Trend S/R"
useMtfSR = input.bool(true, "Show MTF S/R lines", group=gM)
mtfFac   = input.float(3.0, "Supertrend factor", minval=0.5, maxval=12.0, step=0.1, group=gM)
mtfAtr   = input.int(10, "Supertrend ATR length", minval=1, maxval=100, group=gM)
mtfLab   = input.bool(true, "Right-edge labels", group=gM)
mtfColUp = input.color(#21dfac, "Support (up) color", inline="mc", group=gM)
mtfColDn = input.color(#ff5d73, "Resistance (down) color", inline="mc", group=gM)
mtfTf1 = input.timeframe("1",  "TF 1", inline="t1", group=gM)
mtfTf2 = input.timeframe("3",  "TF 2", inline="t1", group=gM)
mtfTf3 = input.timeframe("5",  "TF 3", inline="t2", group=gM)
mtfTf4 = input.timeframe("15", "TF 4", inline="t2", group=gM)
mtfTf5 = input.timeframe("30", "TF 5", inline="t3", group=gM)
mtfTf6 = input.timeframe("60", "TF 6", inline="t3", group=gM)

f_htfst(simple float fac, simple int per) =>
    [stv, d] = ta.supertrend(fac, per)
    [stv[1], d[1]]

[mV1, mD1] = request.security(syminfo.tickerid, mtfTf1, f_htfst(mtfFac, mtfAtr), lookahead=barmerge.lookahead_off)
[mV2, mD2] = request.security(syminfo.tickerid, mtfTf2, f_htfst(mtfFac, mtfAtr), lookahead=barmerge.lookahead_off)
[mV3, mD3] = request.security(syminfo.tickerid, mtfTf3, f_htfst(mtfFac, mtfAtr), lookahead=barmerge.lookahead_off)
[mV4, mD4] = request.security(syminfo.tickerid, mtfTf4, f_htfst(mtfFac, mtfAtr), lookahead=barmerge.lookahead_off)
[mV5, mD5] = request.security(syminfo.tickerid, mtfTf5, f_htfst(mtfFac, mtfAtr), lookahead=barmerge.lookahead_off)
[mV6, mD6] = request.security(syminfo.tickerid, mtfTf6, f_htfst(mtfFac, mtfAtr), lookahead=barmerge.lookahead_off)
mUp1 = mD1 < 0
mUp2 = mD2 < 0
mUp3 = mD3 < 0
mUp4 = mD4 < 0
mUp5 = mD5 < 0
mUp6 = mD6 < 0

var line  mLn1 = na
var line  mLn2 = na
var line  mLn3 = na
var line  mLn4 = na
var line  mLn5 = na
var line  mLn6 = na
var label mLb1 = na
var label mLb2 = na
var label mLb3 = na
var label mLb4 = na
var label mLb5 = na
var label mLb6 = na
f_srDraw(line ln, label lb, int xL, int xR, float lvl, bool up, string tf, bool lab, int w) =>
    line.delete(ln)
    label.delete(lb)
    line  nl = na
    label nb = na
    if not na(lvl)
        col = up ? mtfColUp : mtfColDn
        nl := line.new(xL, lvl, xR, lvl, xloc=xloc.bar_index, color=color.new(col, 0), width=w)
        if lab
            nb := label.new(xR, lvl, tf + "m " + (up ? "support" : "resistance"), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(col, 12), textcolor=color.white, size=size.small)
    [nl, nb]
if useMtfSR and barstate.islast
    int xL = bar_index - 1
    int xR = bar_index + 8
    [a1, c1] = f_srDraw(mLn1, mLb1, xL, xR, mV1, mUp1, mtfTf1, mtfLab, 1)
    [a2, c2] = f_srDraw(mLn2, mLb2, xL, xR, mV2, mUp2, mtfTf2, mtfLab, 1)
    [a3, c3] = f_srDraw(mLn3, mLb3, xL, xR, mV3, mUp3, mtfTf3, mtfLab, 1)
    [a4, c4] = f_srDraw(mLn4, mLb4, xL, xR, mV4, mUp4, mtfTf4, mtfLab, 2)
    [a5, c5] = f_srDraw(mLn5, mLb5, xL, xR, mV5, mUp5, mtfTf5, mtfLab, 2)
    [a6, c6] = f_srDraw(mLn6, mLb6, xL, xR, mV6, mUp6, mtfTf6, mtfLab, 3)
    mLn1 := a1
    mLn2 := a2
    mLn3 := a3
    mLn4 := a4
    mLn5 := a5
    mLn6 := a6
    mLb1 := c1
    mLb2 := c2
    mLb3 := c3
    mLb4 := c4
    mLb5 := c5
    mLb6 := c6

// ───────────────────────────── ALERTS ─────────────────────────────────
alertcondition(shortGated, "Fade SHORT (gated)", "Regime-gated fade short: outer band tagged with a reversion tell, market mean-reverting.")
alertcondition(longGated,  "Fade LONG (gated)",  "Regime-gated fade long: outer band tagged with a reversion tell, market mean-reverting.")
alertcondition(bearDiv, "Bearish divergence at band", "Momentum divergence at the upper band.")
alertcondition(bullDiv, "Bullish divergence at band", "Momentum divergence at the lower band.")
alertcondition(mfConsUp, "Multi-factor consensus overbought", "Multi-factor consensus: several factors stretched overbought together.")
alertcondition(mfConsDn, "Multi-factor consensus oversold", "Multi-factor consensus: several factors stretched oversold together.")
````
