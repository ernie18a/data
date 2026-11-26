# Auto Trend Channel & Breakout Expectancy in R

- url: https://www.tradingview.com/script/nKtMgR1m-Auto-Trend-Channel-Breakout-Expectancy-in-R/
- type: indicator
- pine_id: PUB;58abb966de9742afba7a2c59a316beb4
- version: 2.0

## Description

OVERVIEW
 
An auto-drawn trend channel is easy. Knowing whether breaking it has ever paid on YOUR symbol is not — and it is the only thing that matters.
 
This tool draws the channel objectively and then does the part nobody else does: it forward-resolves every historical break through a real target and stop, and reports, in R, what breaks like the current one have actually returned. Not a prediction. A track record.
 
     Expectancy        exp +1.24R · need 15% @ RR 6.0
     HV win/loss       38/59% n400 ✓
     MV win/loss       32/65% n150 ✓
     LV win/loss       17/83% n55
     Null / net        net 1.29R  t=3.1 ✓
 
It is a research and framing tool. NOT a strategy, NOT a signal service, NOT a validated edge.
 
 
HOW THE CHANNEL IS BUILT — objectively, no hand-placed anchors
 
The support and resistance lines come from a CONVEX HULL over confirmed pivots, not from two points a human chose. The opposite boundary is drawn parallel, and the channel WIDTH becomes the measured-move target. Because the construction is mechanical, the same rule produces the same channel on every symbol and every timeframe — there is nothing to curve-fit.
 
 
HOW A BREAK IS GRADED — and why volume is split three ways
 
A break is a confirmed CLOSE beyond the boundary. Every break is then sorted by its break-bar volume percentile into HV / MV / LV (high / medium / low), and each tier is calibrated SEPARATELY.
 
That split is the point. "Breakouts need volume" is repeated everywhere and tested almost nowhere. Here you can read straight off the panel whether heavy breaks on your instrument actually pay more than thin ones — and often they do not, which is worth knowing before you wait for a volume confirmation that costs you the entry.
 
 
THE FORWARD TEST — expectancy in R, on identical geometry
 
Every break is resolved through a triple barrier: a target at the channel-width move, a stop at a fixed ATR distance, and a horizon. Win, loss, or chop. The expectancy is the exact realized R per trade — a win contributes +RR, a loss contributes −1, chop contributes 0 — so the win rate and the R:R are on the SAME footing, computed from the same resolved trades. There is no mixing of a win rate from one calculation with an R:R from another.
 
The R:R shown is the target-to-stop RATIO, and it is deliberately not the headline. A 6:1 target sounds wonderful and is reached maybe a third of the time; quoting it alone flatters a low-hit-rate system. So the panel leads with the realized EXPECTANCY, then states the breakeven win rate the geometry requires, then shows the win rate actually achieved. Expectancy first, because expectancy is the thing that is actually true.
 
Nothing is rated until a tier has at least 30 resolved trades. Below that, no checkmark, no verdict, no meta call — a Wilson floor on a dozen trials is too wide to certify anything, and pretending otherwise is how bad tiers get a green tick.
 
 
THE RANDOM-DIRECTION NULL — the honesty check
 
Here is the trap this defends against. A 6:1 target with a nearby stop is an asymmetric payoff, and on a drifting instrument an asymmetric payoff makes money in a RANDOM direction — the geometry earns, not the signal. So for every real break the script ALSO runs a coin-flip-direction trade with the identical target and stop, and reports its expectancy alongside.
 
If the null earns as much as the signal, the "edge" is just the geometry capturing drift, and you should believe the null. And it is now TESTED, not just displayed: a Welch t between the signal's realized-R distribution and the null's turns "net 1.29R" into "net 1.29R, t = 3.1, real" — or into "ns", not significant, which is the more common and more honest outcome.
 
 
THE OPTIONAL META-LABEL — a learned second opinion
 
An online logistic model trains on this script's own resolved outcomes and outputs a calibrated probability of follow-through for the current break. No hand-tuned weights; it self-corrects as more breaks resolve, and it reports its own reliability (the realized win rate inside each probability bin) so you can see whether its confidence is earned. It is off by default and it never overrides the forward test — it is a second opinion, not the verdict.
 
 
THE ANTI-BIAS GUARDS
 
ENTRY IS THE CLOSE (or, in retest mode, the line touch) — a break is a signal, not a fill, and entering at a better price than the trade actually offered would manufacture an edge.
 
Both barriers on one bar: the STOP is assumed first — conservative, and the only assumption that cannot flatter the result. Unresolved trades at the horizon are scored as chop (zero), not as wins.
 
THE NULL is direction-randomised on the same geometry, which is what isolates signal from payoff structure. Every rating is gated by a minimum sample and a Wilson lower bound, and the null gap is significance-tested. Nothing here is asserted that has not cleared a test.
 
 
NON-REPAINT
 
Confirmed pivots, confirmed-close breaks, and forward-resolved calibration that never looks ahead. The channel can extend and re-fit as new pivots confirm, but a resolved trade is never re-scored, and no barrier is evaluated on a bar that has not closed.
 
 
DATA AND SCOPE
 
Any symbol, any timeframe. ATR-normalised throughout. Volume is used for the tier split; without it the tiers collapse to one and everything else still works.
 
 
EXPORTS (Data Window — consume from other scripts via input.source())
 
Channel high, channel low, break direction, volume tier, entry, stop, target, per-tier expectancy, null expectancy, meta probability — see the Exports group.
 
 
CONCEPT CREDIT
 
The convex-hull approach to objective trendlines, the triple-barrier forward-labelling method and the meta-labelling idea are from Marcos Lopez de Prado ("Advances in Financial Machine Learning"). The trading-range break as a formal, testable rule was first studied at scale by Brock, Lakonishok and LeBaron (Journal of Finance, 1992); its vulnerability to data-snooping was shown by Sullivan, Timmermann and White (1999) — which is exactly why this tool measures the rule on your instrument instead of asserting it. Wilson score interval — E. B. Wilson (1927). Welch's t-test — B. L. Welch. ATR — J. Welles Wilder.
 
The convex-hull channel implementation, the volume-tier calibration, the random-direction null with its significance test, and the online meta-label are the author's own. Clean-room implementation; no third-party Pine code is reused. Not affiliated with, nor endorsed by, any of the above.
 
 
HONESTY AND LIMITATIONS
 
Calibration is IN-SAMPLE, fixed-barrier, and assumes idealised fills — no commission, no slippage, no partial fills. It describes the past; it does not predict the future. Real costs will reduce every number, and they reduce the low-hit-rate high-RR tiers most.
 
Overlapping windows mean the samples are not fully independent, so treat the t-stats as directional evidence, not exact p-values. A tier that is proven in-sample is not guaranteed out-of-sample.
 
The null being beaten is the single most important line on the panel, and on many instruments it will read "ns". That is a real result. A tool that cannot report "no edge here" is selling you something.
 
Nothing in this script predicts price.
 
 
DISCLAIMER
 
Research and educational tool only. NOT financial advice, NOT a recommendation, and NO guarantee of results. Entry, stop and target output is arithmetic, not advice. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability for any use.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Market_Logic_India
// ══════════════════════════════════════════════════════════════════════════════
//  AUTO TREND CHANNEL & BREAKOUT — Expectancy in R                              v1.1
//  shorttitle: Channel Breaks                                       Pine Script v6
// ──────────────────────────────────────────────────────────────────────────────
//  v1.1 — Correctness: hoisted a stateful ta.pivothigh out of a short-circuiting `or` in the
//         order-flow VWAP-anchor proxy so both pivots evaluate on every bar (Pine requirement for
//         series functions; clears CW10004). House standard: renamed the Data-Window exports to the
//         EXP_ bus convention (EXP_ResLine, EXP_Break, EXP_Entry, …). No logic, inputs, geometry or
//         calibration changed — export values are identical, only their Data-Window titles differ.
// ──────────────────────────────────────────────────────────────────────────────
//  An auto-drawn trend channel with a built-in, self-measuring statistics engine.
//  The channel is fit objectively (convex hull — no hand-placed anchors); breaks
//  are graded by volume; and every historical break is forward-resolved through a
//  fixed target/stop barrier so the script can show you, in R, what breaks like the
//  current one have actually paid on THIS symbol and timeframe — never on opinion.
//
//  COMPONENTS (and why they are combined — see publication notes):
//    • CONVEX-HULL TREND CHANNEL — objective support/resistance + parallel boundary.
//      The boundary width is the measured-move target.
//    • VOLUME-GRADED BREAK (HV/MV/LV) — break-bar volume percentile, calibrated per
//      tier, so you learn whether heavy breaks actually pay more than thin ones.
//    • FORWARD CALIBRATION (triple-barrier) — every break is resolved win/loss/none
//      against its own target & stop; expectancy is reported in R per trade.
//    • RANDOM-DIRECTION NULL — the same geometry with a coin-flip direction, to
//      prove the edge is the signal and not just an asymmetric payoff structure.
//    • OPTIONAL META-LABEL — an online classifier that scores each break's odds of
//      follow-through and self-reports its own reliability.
//
//  Everything is DESCRIPTIVE and educational. Forward statistics are in-sample,
//  fixed-barrier, and assume idealized fills (no commission/slippage/partial
//  fills) — they describe the past, they do not predict the future and are NOT a
//  recommendation. Non-repainting: confirmed pivots, confirmed-close breaks, and
//  forward-resolved (never look-ahead) calibration.
// ══════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("Auto Trend Channel & Breakout — Expectancy in R", "Channel Breaks", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ───────────────────────────── INPUTS ──────────────────────────────────────
gS="1 · Source", gP="2 · Pivots & Hull", gV="3 · Validity", gB="4 · Break Validation"
gCh="5 · Channel", gVol="6 · Volume Tier", gEn="7 · Entry / Invalidation"
gR="8 · Regime", gC="9 · Forward Calibration", gD="10 · Display", gK="11 · Dashboard", gE="12 · Exports"
gM="13 · Meta-Label (learned)"

gG="6b · External Confirmation (optional)"

srcHigh = input.source(high,  "High source",  group=gS, tooltip="Raw data the channel is built from. Defaults to standard OHLC so the script works on any symbol/timeframe. Change these to use Heikin-Ashi, a different series, or another feed.")
srcLow  = input.source(low,   "Low source",   group=gS)
srcCls  = input.source(close, "Close source", group=gS)

useCvdGate = input.bool(true, "Require external agreement on breaks", group=gG, tooltip="OPTIONAL. Wire any directional signal that outputs +1 / 0 / -1 (e.g. an order-flow or momentum sub-script's 'EXP_Break' output) into the source below, then a price break is 'confirmed' only if that signal agrees within the window. SAFE TO LEAVE ON: if the wired source is not a valid +1/0/-1 signal, the gate auto-disables and changes nothing. Raw and gated follow-through are calibrated SEPARATELY so you can see the lift.")
cvdBreakSrc = input.source(close, "Confirmation signal (+1/0/-1)", group=gG, tooltip="Select an external indicator output that emits +1 (up), -1 (down), or 0 (none). Leave as a price series to keep the gate inactive.")
cvdGateWin  = input.int(8, "Agreement window (bars)", minval=1, maxval=50, group=gG, tooltip="The external signal must have agreed within this many bars of the price break.")

gH="6c · Higher-TF VWAP Alignment"
useHtfVwap = input.bool(true, "Align breaks with anchored VWAP", group=gH, tooltip="Measures whether each break agrees with the anchored-VWAP direction on the timeframe chosen below. Agreement feeds the break STRENGTH model and the dashboard; turn on 'require' to also gate DIRECTION.")
htfChoice  = input.string("Same TF", "VWAP timeframe", ["Same TF","3× TF","5× TF"], group=gH, tooltip="Which anchored-VWAP timeframe to align breaks with. Same-TF (default) mostly measures extension — a fresh break usually already sits on its own side of the same-TF VWAP, so it rarely disagrees and acts more as a confirmation/extension read than a hard filter. 3× and 5× are higher-context: they CAN disagree with a break, so they carry more direction information if you want a stricter filter (turn on 'require' below).")
htfAnchor  = input.string("Order-flow", "VWAP anchor", ["Order-flow","Session","Rolling"], group=gH, tooltip="Order-flow = a VWAP that re-anchors on cumulative-delta swings. Session = today's VWAP. Rolling = a moving volume-VWAP. Order-flow matches an order-flow anchored-VWAP study most closely.")
htfRequire = input.bool(false, "Require VWAP agreement on breaks", group=gH, tooltip="ON = a break only marks/enters and counts as confirmed when it agrees with the chosen VWAP direction. OFF (default) = alignment still feeds the strength model and dashboard but never suppresses a break, so standalone behaviour is unchanged.")
htfExtMode = input.bool(false, "Use external OF-anchored bias instead of internal", group=gH, tooltip="Wire a +1/0/-1 order-flow anchored-VWAP bias series (e.g. exported from a dedicated anchored-VWAP study) into the source below for a higher-fidelity read than the internal proxy.")
htfSrcX    = input.source(close, "External bias (+1/0/-1)", group=gH)

autoPivot   = input.bool(true, "Auto-scale pivots to timeframe", group=gP, tooltip="Keeps the channel proportional across timeframes by fixing the STRUCTURE WINDOW in time, not bars. A fixed 8-bar pivot = 24min on 3m but 2h on 15m, which is why the channel felt differently scaled.")
pivotMinutes= input.int(40, "Target structure window (min)", minval=5, maxval=240, group=gP, tooltip="Each half-swing spans roughly this many minutes when auto-scaling is on.")
pivLenManual= input.int(8,  "Pivot length (manual)", minval=2, maxval=50, group=gP, tooltip="Used when auto-scale is off. Bars each side of a swing; pivots confirm this many bars late (non-repaint).")
int chartMin = math.max(1, int(timeframe.in_seconds()/60))
int pivLen   = autoPivot ? math.max(3, math.min(50, int(math.round(pivotMinutes/chartMin)))) : pivLenManual
hullWin = input.int(20, "Hull window (recent pivots)", minval=4, maxval=60, group=gP)

minSlope = input.float(0.02, "Min slope (ATR/bar)", minval=0.0, maxval=1.0, step=0.01, group=gV)
maxSlope = input.float(2.0,  "Max slope (ATR/bar)", minval=0.2, maxval=10.0, step=0.1, group=gV)
touchTol = input.float(0.5,  "Touch tolerance (× ATR)", minval=0.1, maxval=2.0, step=0.1, group=gV)

breakBuf = input.float(0.15, "Break buffer (× ATR)", minval=0.0, maxval=1.0, step=0.05, group=gB)
dispATR  = input.float(1.0,  "Displacement (× ATR)", minval=0.2, maxval=3.0, step=0.1, group=gB)
antiWick = input.float(0.55, "Anti-wick close position (0-1)", minval=0.5, maxval=0.9, step=0.05, group=gB)

showChannel = input.bool(true, "Draw channel boundary", group=gCh)

volLen = input.int(50, "Volume percentile window", minval=10, maxval=500, group=gVol)
hvThr  = input.float(70, "HV percentile ≥", minval=50, maxval=95, step=5, group=gVol)
lvThr  = input.float(30, "LV percentile ≤", minval=5, maxval=50, step=5, group=gVol)
useHV  = input.bool(true, "Act on HV breaks", group=gVol, inline="tier", tooltip="Tick the volume tiers you want marks/entries/alerts for. Calibration still tracks all tiers so you can compare.")
useMV  = input.bool(true, "MV",  group=gVol, inline="tier")
useLV  = input.bool(true, "LV",  group=gVol, inline="tier")

enableEntry = input.bool(true, "Enable entry marks", group=gEn)
entryMode = input.string("Retest", "Entry mode", ["Retest","Breakout"], group=gEn, tooltip="Retest = wait for pullback to hold (cleaner). Breakout = enter on break close (earlier).")
invalWin  = input.int(6, "Invalidation / arm window (bars)", minval=1, maxval=30, group=gEn)
stopAtLine= input.bool(false, "Stop at broken line (else bar extreme)", group=gEn)
minStopATR= input.float(0.5, "Min stop distance × ATR", minval=0.0, maxval=3.0, step=0.1, group=gEn, tooltip="Floor on stop distance. Without it a tiny break-bar gives a 3-point stop and an absurd R:R that would get wicked out instantly.")
tgtMode   = input.string("Channel width", "Target", ["Channel width","ATR"], group=gEn)
tgtATR    = input.float(1.5, "Target × ATR (if ATR mode / fallback)", minval=0.3, maxval=20.0, step=0.1, group=gEn)
tgtCapATR = input.float(3.0, "Max target distance × ATR", minval=0.5, maxval=10.0, step=0.5, group=gEn, tooltip="Caps the measured-move target so a very wide channel can't produce a fantasy R:R (e.g. 70:1) you'd never actually realise.")

erLen=input.int(20,"Efficiency-ratio length",minval=5,maxval=200,group=gR)
erGate=input.float(0.35,"Trend gate (ER ≥)",minval=0.1,maxval=0.9,step=0.05,group=gR)
adxLen=input.int(14,"ADX length",minval=5,maxval=100,group=gR)
adxGate=input.float(20.0,"Trend gate (ADX ≥)",minval=5,maxval=50,group=gR)

calEnable=input.bool(true,"Track break follow-through",group=gC)
horizon=input.int(20,"Horizon (bars)",minval=3,maxval=100,group=gC,tooltip="Bars to wait for a barrier touch before scoring the break as chop.")
// Calibration now resolves at each trade's REAL target/stop (set in the Entry group),
// so the win rate corresponds to the trade shown and is judged against its own breakeven.
minSamp=input.int(30,"Min samples to trust",minval=10,maxval=200,group=gC,tooltip="No tier is rated — no ✓, no verdict, no meta call — until it has at least this many resolved trades. Live, a tier with n=13 was printing a ✓; a Wilson floor on 13 trials is too wide to certify anything, which defeats the purpose of having a floor. 30 is the floor below which a proportion simply cannot be trusted.")
nullEnable=input.bool(true,"Random-direction null baseline",group=gC,tooltip="For each real break, also runs a coin-flip-direction trade with the SAME target/stop. If the null earns as much as the signal, the 'edge' is just the asymmetric geometry capturing drift — not your signal.")
costR=input.float(0.10,"Cost per trade (R)",minval=0.0,maxval=1.0,step=0.01,group=gC,tooltip="Round-trip cost (brokerage+STT+slippage+optimistic fill) expressed in R, subtracted from expectancy for the NET figure.")

metaEnable = input.bool(true, "Learn a meta-label on break outcomes", group=gM, tooltip="An online logistic model trains on this script's own resolved triple-barrier outcomes and outputs a calibrated P(continuation). No hand-tuned weights. Replaces the verdict rule with a learned, self-correcting probability.")
metaLR     = input.float(0.05, "Learning rate", minval=0.001, maxval=0.5, step=0.005, group=gM)
metaL2     = input.float(0.001, "L2 regularization", minval=0.0, maxval=0.1, step=0.001, group=gM)
metaEMA    = input.float(0.02, "Feature standardizer speed", minval=0.005, maxval=0.2, step=0.005, group=gM, tooltip="EMA rate for online mean/variance used to z-score features. Lower = slower, steadier.")
metaMinTrain = input.int(30, "Min trained samples before trusting", minval=10, maxval=200, group=gM)

extBars=input.int(10,"Right projection (bars)",minval=0,maxval=60,group=gD)
showBreak=input.bool(true,"Mark breaks on price",group=gD)
colUp=input.color(#26a69a,"Support / bullish",group=gD)
colDn=input.color(#ef5350,"Resistance / bearish",group=gD)
chanLineW = input.int(2, "Channel boundary width", minval=1, maxval=5, group=gD, tooltip="The parallel 'alt' boundary line of the channel. Raise if it's hard to see.")
chanDashed= input.bool(true, "Channel boundary dashed (else dotted)", group=gD)
tradeLineW= input.int(2, "Entry/stop/target width", minval=1, maxval=5, group=gD)
maxEntryLbl= input.int(4, "Max entry labels on chart", minval=1, maxval=40, group=gD, tooltip="Keeps only the most recent N entry labels so chart history doesn't get buried under a wall of RR tags.")

showDash=input.bool(true,"Show dashboard",group=gK)
dashPos=input.string("Top Right","Position",["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"],group=gK)
dashTheme=input.string("Auto","Table theme",["Auto","Dark","Light"],group=gK,tooltip="Auto reads the chart background brightness and flips text/cell colors so the dashboard stays legible on dark OR light themes. Force Dark/Light if you prefer.")
showMTF = input.bool(true, "Show MTF trend row", group=gK, tooltip="A compact 1/2/3/5/15/30/60m trend strip (▲ up / ▼ down), each cell colored. It's a regression-slope direction proxy per timeframe, not the full per-TF hull channel (too heavy on 7 timeframes).")
mtfLen  = input.int(20, "MTF trend EMA length", minval=5, maxval=100, group=gK)
mtfPos  = input.string("Bottom Right","MTF strip position",["Bottom Right","Bottom Left","Top Left","Middle Right","Top Right"],group=gK,tooltip="The MTF strip is its own small table so it stays tidy; place it where it won't overlap the main dashboard.")
showEXP=input.bool(true,"Emit data-window outputs (for other scripts)",group=gE)

// ───────────────────────────── HELPERS ─────────────────────────────────────
f_pos(s)=> s=="Top Left"?position.top_left : s=="Bottom Right"?position.bottom_right : s=="Bottom Left"?position.bottom_left : s=="Middle Right"?position.middle_right : position.top_right

f_er(src,len)=>
    ch=math.abs(src-src[len])
    vs=math.sum(math.abs(ta.change(src)),len)
    vs!=0?ch/vs:0.0

f_wilsonLo(w,t,zc)=>
    float r=na
    if t>0.0
        p=w/t
        d=1.0+zc*zc/t
        c=(p+zc*zc/(2.0*t))/d
        m=zc*math.sqrt(p*(1.0-p)/t+zc*zc/(4.0*t*t))/d
        r:=c-m
    r

f_sigmoid(x)=> 1.0/(1.0+math.exp(-math.max(-30.0,math.min(30.0,x))))
f_dot(w,z)=>
    float s=0.0
    int n=math.min(array.size(w),array.size(z))
    for k=0 to n-1
        s+=array.get(w,k)*array.get(z,k)
    s

f_hullEdge(xs,ys,upper)=>
    float rx1=na, float ry1=na, float rx2=na, float ry2=na
    int n=array.size(xs)
    if n>=2
        hx=array.new<float>(), hy=array.new<float>()
        for i=0 to n-1
            px=array.get(xs,i), py=array.get(ys,i)
            bool cont=true
            while cont and array.size(hx)>=2
                int m=array.size(hx)
                ax=array.get(hx,m-2), ay=array.get(hy,m-2)
                bx=array.get(hx,m-1), byy=array.get(hy,m-1)
                cross=(bx-ax)*(py-ay)-(byy-ay)*(px-ax)
                bool pop=upper?(cross>=0.0):(cross<=0.0)
                if pop
                    array.pop(hx), array.pop(hy)
                else
                    cont:=false
            array.push(hx,px), array.push(hy,py)
        int mm=array.size(hx)
        if mm>=2
            rx1:=array.get(hx,mm-2), ry1:=array.get(hy,mm-2)
            rx2:=array.get(hx,mm-1), ry2:=array.get(hy,mm-1)
    [rx1,ry1,rx2,ry2]

f_touches(xs,ys,x1,y1,x2,y2,tol)=>
    int c=0
    if x2!=x1
        slope=(y2-y1)/(x2-x1)
        int n=array.size(xs)
        if n>0
            for i=0 to n-1
                px=array.get(xs,i)
                if px>=x1
                    py=array.get(ys,i)
                    ly=y1+slope*(px-x1)
                    if math.abs(py-ly)<=tol
                        c+=1
    c

// max deviation of pivots from a line, on one side. below=true -> (lineY - py)
f_maxDev(xs,ys,x1,y1,x2,y2,below)=>
    float g=na
    if x2!=x1
        slope=(y2-y1)/(x2-x1)
        int n=array.size(xs)
        if n>0
            for i=0 to n-1
                px=array.get(xs,i)
                if px>=x1
                    py=array.get(ys,i)
                    ly=y1+slope*(px-x1)
                    d=below?(ly-py):(py-ly)
                    if na(g) or d>g
                        g:=d
    g

f_cell(tbl,c,r,txt,tc,bg)=> table.cell(tbl,c,r,txt,text_color=tc,bgcolor=bg,text_size=size.small,text_halign=text.align_left)

// per-timeframe trend proxy (regression-slope sign ≈ channel centerline direction)
f_tfDir()=>
    float l0=ta.linreg(close,mtfLen,0)
    float l1=ta.linreg(close,mtfLen,1)
    l0>l1?1:l0<l1?-1:0
f_arrow(int d)=> d>0?"▲":d<0?"▼":"·"

// higher-TF string from a multiple of the chart timeframe
f_tfMult(int m) =>
    float s = timeframe.in_seconds(timeframe.period) * m
    s < 60 ? str.tostring(math.round(s)) + "S" : s < 86400 ? str.tostring(math.round(s/60.0)) : s < 604800 ? str.tostring(math.round(s/86400.0)) + "D" : str.tostring(math.round(s/604800.0)) + "W"

// anchored-VWAP bias (+1 above / -1 below / 0) — order-flow / session / rolling
f_htfBias() =>
    int b = 0
    if htfAnchor == "Rolling"
        float pv = math.sum(hlc3*volume, 20), float vv = math.sum(volume, 20)
        float vw = vv>0 ? pv/vv : na
        b := na(vw) ? 0 : close>vw ? 1 : close<vw ? -1 : 0
    else if htfAnchor == "Session"
        float vw = ta.vwap(hlc3)
        b := na(vw) ? 0 : close>vw ? 1 : close<vw ? -1 : 0
    else
        // order-flow anchor: VWAP re-anchored on cumulative-delta swings
        float ret = close - nz(close[1], close)
        float sd  = ta.stdev(ta.change(close), 20)
        float zz  = sd>0 ? ret/sd : 0.0
        float bf  = 0.5*(1.0 + zz/math.sqrt(1.0+zz*zz))         // cheap buy-fraction
        float dl  = volume*(2.0*bf - 1.0)
        float cvd = ta.cum(dl)
        // STATEFUL HOIST: `or` short-circuits, so ta.pivothigh was skipped on every bar where
        // ta.pivotlow returned non-na — corrupting the pivot-high buffer. Evaluate both every bar, then combine.
        float pLoC = ta.pivotlow(cvd,8,8)
        float pHiC = ta.pivothigh(cvd,8,8)
        bool  rst = not na(pLoC) or not na(pHiC)
        var float pv=0.0, var float vv=0.0, var int ab=na
        if rst or na(ab)
            pv := hlc3*volume, vv := volume, ab := bar_index
        else
            pv += hlc3*volume, vv += volume
        float vw = vv>0 ? pv/vv : na
        b := na(vw) ? 0 : close>vw ? 1 : close<vw ? -1 : 0
    b

// ───────────────────────────── CORE SERIES ─────────────────────────────────
float atr=ta.atr(14)
float atrSafe=atr>0?atr:srcCls*0.001
float rng=math.max(srcHigh-srcLow,syminfo.mintick)
float bodyR=math.abs(srcCls-open)/rng
float volMa=ta.sma(volume,20)
float volZ=volMa>0?(volume-volMa)/math.max(volMa,1e-9):0.0
float volPct=ta.percentrank(volume,volLen)
int   tierI=volPct>=hvThr?2:volPct<=lvThr?0:1
string tierS=tierI==2?"HV":tierI==0?"LV":"MV"
bool tierAllowed = tierI==2 ? useHV : tierI==0 ? useLV : useMV

float erV=f_er(srcCls,erLen)
[dip,dim,adxV]=ta.dmi(adxLen,adxLen)
bool isTrend=erV>=erGate and adxV>=adxGate
int  regNow=isTrend?1:0

// MTF trend strip (1/2/3/5/15/30/60m) — non-repaint, confirmed HTF closes
int mt1 = showMTF ? request.security(syminfo.tickerid,"1",  f_tfDir(), lookahead=barmerge.lookahead_off) : 0
int mt2 = showMTF ? request.security(syminfo.tickerid,"2",  f_tfDir(), lookahead=barmerge.lookahead_off) : 0
int mt3 = showMTF ? request.security(syminfo.tickerid,"3",  f_tfDir(), lookahead=barmerge.lookahead_off) : 0
int mt5 = showMTF ? request.security(syminfo.tickerid,"5",  f_tfDir(), lookahead=barmerge.lookahead_off) : 0
int mt15= showMTF ? request.security(syminfo.tickerid,"15", f_tfDir(), lookahead=barmerge.lookahead_off) : 0
int mt30= showMTF ? request.security(syminfo.tickerid,"30", f_tfDir(), lookahead=barmerge.lookahead_off) : 0
int mt60= showMTF ? request.security(syminfo.tickerid,"60", f_tfDir(), lookahead=barmerge.lookahead_off) : 0

// ── Anchored-VWAP alignment (user-chosen timeframe: same / 3× / 5×) ──
int    htfMul = htfChoice=="5× TF" ? 5 : htfChoice=="3× TF" ? 3 : 1
string htfTf  = f_tfMult(htfMul)
int hbSec = request.security(syminfo.tickerid, htfTf, f_htfBias(), lookahead=barmerge.lookahead_off)
int htfAlign = not useHtfVwap ? 0 : htfExtMode ? (math.sign(htfSrcX) != 0 ? int(math.sign(htfSrcX)) : 0) : hbSec   // -1 / 0 / +1

// ───────────────────────────── PIVOT STORES ────────────────────────────────
var float[] phX=array.new<float>(), var float[] phY=array.new<float>()
var float[] plX=array.new<float>(), var float[] plY=array.new<float>()
float ph=ta.pivothigh(srcHigh,pivLen,pivLen)
float pl=ta.pivotlow(srcLow,pivLen,pivLen)

// ───────────────────────────── RESISTANCE (upper hull) ─────────────────────
var float resX1=na, var float resY1=na, var float resX2=na, var float resY2=na
var bool resOK=false, var int resTouch=0, var bool resBroken=false
if not na(ph)
    array.push(phX,float(bar_index-pivLen)), array.push(phY,ph)
    while array.size(phX)>hullWin
        array.shift(phX), array.shift(phY)
    [ex1,ey1,ex2,ey2]=f_hullEdge(phX,phY,true)
    bool ok=false
    if not na(ex1) and ex2!=ex1
        slA=(ey2-ey1)/(ex2-ex1)/atrSafe
        if slA<=-minSlope and slA>=-maxSlope
            ok:=true
    bool changed=ex1!=resX1 or ey1!=resY1 or ex2!=resX2 or ey2!=resY2
    resX1:=ex1, resY1:=ey1, resX2:=ex2, resY2:=ey2, resOK:=ok
    if ok
        resTouch:=f_touches(phX,phY,ex1,ey1,ex2,ey2,touchTol*atrSafe)
    if changed
        resBroken:=false

// ───────────────────────────── SUPPORT (lower hull) ────────────────────────
var float supX1=na, var float supY1=na, var float supX2=na, var float supY2=na
var bool supOK=false, var int supTouch=0, var bool supBroken=false
if not na(pl)
    array.push(plX,float(bar_index-pivLen)), array.push(plY,pl)
    while array.size(plX)>hullWin
        array.shift(plX), array.shift(plY)
    [ex1,ey1,ex2,ey2]=f_hullEdge(plX,plY,false)
    bool ok=false
    if not na(ex1) and ex2!=ex1
        slA=(ey2-ey1)/(ex2-ex1)/atrSafe
        if slA>=minSlope and slA<=maxSlope
            ok:=true
    bool changed=ex1!=supX1 or ey1!=supY1 or ex2!=supX2 or ey2!=supY2
    supX1:=ex1, supY1:=ey1, supX2:=ex2, supY2:=ey2, supOK:=ok
    if ok
        supTouch:=f_touches(plX,plY,ex1,ey1,ex2,ey2,touchTol*atrSafe)
    if changed
        supBroken:=false

// ───────────────────────────── BREAK DETECTION ─────────────────────────────
bool disp=(srcHigh-srcLow)>=dispATR*atrSafe and bodyR>=0.5
float resNow=(resOK and resX2!=resX1)?resY1+(resY2-resY1)/(resX2-resX1)*(bar_index-resX1):na
float supNow=(supOK and supX2!=supX1)?supY1+(supY2-supY1)/(supX2-supX1)*(bar_index-supX1):na

bool resBreak=false
if resOK and not na(resNow)
    bool aw=(srcCls-srcLow)/rng>=antiWick
    if not resBroken and barstate.isconfirmed and srcCls>resNow+breakBuf*atrSafe and disp and aw
        resBreak:=true, resBroken:=true
bool supBreak=false
if supOK and not na(supNow)
    bool aw=(srcHigh-srcCls)/rng>=antiWick
    if not supBroken and barstate.isconfirmed and srcCls<supNow-breakBuf*atrSafe and disp and aw
        supBreak:=true, supBroken:=true
int breakDir=resBreak?1:supBreak?-1:0

// external confirmation gate — agreement of the wired ±1 signal within the window
bool gateWired = cvdBreakSrc != close
float upAgoF = ta.barssince(cvdBreakSrc == 1)
float dnAgoF = ta.barssince(cvdBreakSrc == -1)
int cvdRecent = (na(upAgoF) and na(dnAgoF)) ? 0 : (nz(upAgoF, 1e9) <= nz(dnAgoF, 1e9) ? 1 : -1)
float cvdAgoF = cvdRecent == 1 ? upAgoF : cvdRecent == -1 ? dnAgoF : na
bool cvdAgree = (not useCvdGate or not gateWired) ? true : (breakDir != 0 and breakDir == cvdRecent and not na(cvdAgoF) and cvdAgoF <= cvdGateWin)

// higher-TF VWAP agreement with the break direction
bool htfAgree = breakDir != 0 and ((breakDir>0 and htfAlign>0) or (breakDir<0 and htfAlign<0))
bool htfOK    = (not useHtfVwap or not htfRequire) ? true : htfAgree
// combined confirmation drives marks/entries and the GATED calibration track
bool confAgree = cvdAgree and htfOK

// ───────────────────────────── CHANNEL BOUNDARIES ──────────────────────────
float resGap=resOK?f_maxDev(plX,plY,resX1,resY1,resX2,resY2,true):na    // lows below res line
float supGap=supOK?f_maxDev(phX,phY,supX1,supY1,supX2,supY2,false):na   // highs above sup line
resGap:=na(resGap)?na:math.max(resGap,0.0)
supGap:=na(supGap)?na:math.max(supGap,0.0)

f_grade(int t)=> t>=4?3:t>=3?2:1
var line resLn=na, var line supLn=na, var line resChL=na, var line supChU=na

if resOK and not resBroken and not na(resX1)
    slope=(resY2-resY1)/(resX2-resX1)
    yP=resY1+slope*(bar_index+extBars-resX1)
    int g=f_grade(resTouch)
    if na(resLn)
        resLn:=line.new(int(resX1),resY1,bar_index+extBars,yP,color=colDn,width=g)
    else
        line.set_xy1(resLn,int(resX1),resY1), line.set_xy2(resLn,bar_index+extBars,yP)
        line.set_color(resLn,colDn), line.set_width(resLn,g), line.set_style(resLn,line.style_solid)
    if showChannel and not na(resGap)
        y1=resY1-resGap, yPl=yP-resGap
        if na(resChL)
            resChL:=line.new(int(resX1),y1,bar_index+extBars,yPl,color=color.new(colDn,15),style=chanDashed?line.style_dashed:line.style_dotted,width=chanLineW)
        else
            line.set_xy1(resChL,int(resX1),y1), line.set_xy2(resChL,bar_index+extBars,yPl)
    else if not na(resChL)
        line.delete(resChL), resChL:=na
else if not resOK and not na(resLn) and not resBroken
    line.delete(resLn), resLn:=na
    if not na(resChL)
        line.delete(resChL), resChL:=na
if resBreak and not na(resLn)
    line.set_x2(resLn,bar_index), line.set_y2(resLn,resNow)
    line.set_color(resLn,color.new(colDn,55)), line.set_style(resLn,line.style_dotted), resLn:=na

if supOK and not supBroken and not na(supX1)
    slope=(supY2-supY1)/(supX2-supX1)
    yP=supY1+slope*(bar_index+extBars-supX1)
    int g=f_grade(supTouch)
    if na(supLn)
        supLn:=line.new(int(supX1),supY1,bar_index+extBars,yP,color=colUp,width=g)
    else
        line.set_xy1(supLn,int(supX1),supY1), line.set_xy2(supLn,bar_index+extBars,yP)
        line.set_color(supLn,colUp), line.set_width(supLn,g), line.set_style(supLn,line.style_solid)
    if showChannel and not na(supGap)
        y1=supY1+supGap, yPu=yP+supGap
        if na(supChU)
            supChU:=line.new(int(supX1),y1,bar_index+extBars,yPu,color=color.new(colUp,15),style=chanDashed?line.style_dashed:line.style_dotted,width=chanLineW)
        else
            line.set_xy1(supChU,int(supX1),y1), line.set_xy2(supChU,bar_index+extBars,yPu)
    else if not na(supChU)
        line.delete(supChU), supChU:=na
else if not supOK and not na(supLn) and not supBroken
    line.delete(supLn), supLn:=na
    if not na(supChU)
        line.delete(supChU), supChU:=na
if supBreak and not na(supLn)
    line.set_x2(supLn,bar_index), line.set_y2(supLn,supNow)
    line.set_color(supLn,color.new(colUp,55)), line.set_style(supLn,line.style_dotted), supLn:=na

// break marks + volume tier label (only for selected tiers)
plotshape(showBreak and resBreak and tierAllowed and confAgree, "Res break", shape.triangleup, location.belowbar, colUp, size=size.small)
plotshape(showBreak and supBreak and tierAllowed and confAgree, "Sup break", shape.triangledown, location.abovebar, colDn, size=size.small)
if showBreak and resBreak and tierAllowed and confAgree
    label.new(bar_index, low, tierS, yloc=yloc.belowbar, style=label.style_label_up, color=color.new(colUp,20), textcolor=color.white, size=size.tiny)
if showBreak and supBreak and tierAllowed and confAgree
    label.new(bar_index, high, tierS, yloc=yloc.abovebar, style=label.style_label_down, color=color.new(colDn,20), textcolor=color.white, size=size.tiny)

// ───────────────────────────── ENTRY / INVALIDATION ────────────────────────
f_target(float entry, float chW, int dir)=>
    float w = tgtMode=="ATR" or na(chW) ? tgtATR*atrSafe : chW
    w := math.min(w, tgtCapATR*atrSafe)
    dir>0 ? entry + w : entry - w

var array<label> entryLbls = array.new<label>()
f_capLbl(label lb)=>
    array.push(entryLbls, lb)
    if array.size(entryLbls) > maxEntryLbl
        label.delete(array.shift(entryLbls))

var int   resSetup=0, var int resBkBar=na, var float resChW=na, var int resTierSet=1
var float resEntry=na, var float resStop=na, var float resTgt=na, var float resRR=na, var bool resRet=false
var int   supSetup=0, var int supBkBar=na, var float supChW=na, var int supTierSet=1
var float supEntry=na, var float supStop=na, var float supTgt=na, var float supRR=na, var bool supRet=false
var line  reEn=na, var line reSt=na, var line reTg=na, var line seEn=na, var line seSt=na, var line seTg=na

f_drawTrade(line en, line st, line tg, float e, float s, float t)=>
    line a=na(en)?line.new(bar_index,e,bar_index+extBars,e,color=color.new(color.white,0),width=tradeLineW,extend=extend.right):en
    if not na(en)
        line.set_xy1(en,bar_index,e), line.set_xy2(en,bar_index+extBars,e)
    line b=na(st)?line.new(bar_index,s,bar_index+extBars,s,color=color.new(colDn,0),style=line.style_dashed,width=tradeLineW,extend=extend.right):st
    if not na(st)
        line.set_xy1(st,bar_index,s), line.set_xy2(st,bar_index+extBars,s)
    line c=na(tg)?line.new(bar_index,t,bar_index+extBars,t,color=color.new(colUp,0),style=line.style_dashed,width=tradeLineW,extend=extend.right):tg
    if not na(tg)
        line.set_xy1(tg,bar_index,t), line.set_xy2(tg,bar_index+extBars,t)
    [a,b,c]

// resistance / long
if enableEntry and resBreak and tierAllowed and confAgree
    resSetup:=1, resBkBar:=bar_index, resTierSet:=tierI, resRet:=false
    resChW:=na(resGap)?tgtATR*atrSafe:resGap
    if entryMode=="Breakout"
        resEntry:=srcCls, resStop:=math.min(stopAtLine?resNow:low, resEntry - minStopATR*atrSafe), resTgt:=f_target(resEntry,resChW,1)
        resRR:=(resTgt-resEntry)/math.max(resEntry-resStop,atrSafe*0.1), resSetup:=2
        [a,b,c]=f_drawTrade(reEn,reSt,reTg,resEntry,resStop,resTgt), reEn:=a, reSt:=b, reTg:=c
        f_capLbl(label.new(bar_index,resEntry,"LONG "+tierS+"  RR "+str.tostring(resRR,"0.0"),style=label.style_label_left,color=color.new(colUp,10),textcolor=color.white,size=size.small))
else if enableEntry and resSetup==1
    if srcCls<resNow and barstate.isconfirmed
        resSetup:=3
    else if bar_index-resBkBar>invalWin
        resSetup:=3
    else if entryMode=="Retest"
        if low<=resNow+touchTol*atrSafe
            resRet:=true
        if resRet and srcCls>resNow and barstate.isconfirmed
            resEntry:=srcCls, resStop:=math.min(stopAtLine?resNow:low, resEntry - minStopATR*atrSafe), resTgt:=f_target(resEntry,resChW,1)
            resRR:=(resTgt-resEntry)/math.max(resEntry-resStop,atrSafe*0.1), resSetup:=2
            [a,b,c]=f_drawTrade(reEn,reSt,reTg,resEntry,resStop,resTgt), reEn:=a, reSt:=b, reTg:=c
            f_capLbl(label.new(bar_index,resEntry,"LONG "+tierS+"  RR "+str.tostring(resRR,"0.0"),style=label.style_label_left,color=color.new(colUp,10),textcolor=color.white,size=size.small))
if resSetup==2
    if high>=resTgt or low<=resStop
        resSetup:=4

// support / short
if enableEntry and supBreak and tierAllowed and confAgree
    supSetup:=1, supBkBar:=bar_index, supTierSet:=tierI, supRet:=false
    supChW:=na(supGap)?tgtATR*atrSafe:supGap
    if entryMode=="Breakout"
        supEntry:=srcCls, supStop:=math.max(stopAtLine?supNow:high, supEntry + minStopATR*atrSafe), supTgt:=f_target(supEntry,supChW,-1)
        supRR:=(supEntry-supTgt)/math.max(supStop-supEntry,atrSafe*0.1), supSetup:=2
        [a,b,c]=f_drawTrade(seEn,seSt,seTg,supEntry,supStop,supTgt), seEn:=a, seSt:=b, seTg:=c
        f_capLbl(label.new(bar_index,supEntry,"SHORT "+tierS+"  RR "+str.tostring(supRR,"0.0"),style=label.style_label_left,color=color.new(colDn,10),textcolor=color.white,size=size.small))
else if enableEntry and supSetup==1
    if srcCls>supNow and barstate.isconfirmed
        supSetup:=3
    else if bar_index-supBkBar>invalWin
        supSetup:=3
    else if entryMode=="Retest"
        if high>=supNow-touchTol*atrSafe
            supRet:=true
        if supRet and srcCls<supNow and barstate.isconfirmed
            supEntry:=srcCls, supStop:=math.max(stopAtLine?supNow:high, supEntry + minStopATR*atrSafe), supTgt:=f_target(supEntry,supChW,-1)
            supRR:=(supEntry-supTgt)/math.max(supStop-supEntry,atrSafe*0.1), supSetup:=2
            [a,b,c]=f_drawTrade(seEn,seSt,seTg,supEntry,supStop,supTgt), seEn:=a, seSt:=b, seTg:=c
            f_capLbl(label.new(bar_index,supEntry,"SHORT "+tierS+"  RR "+str.tostring(supRR,"0.0"),style=label.style_label_left,color=color.new(colDn,10),textcolor=color.white,size=size.small))
if supSetup==2
    if low<=supTgt or high>=supStop
        supSetup:=4

// ──── CALIBRATION — symmetric ±move barriers: CONTINUATION vs FADE vs CHOP ───
// For each break we ask which 1-move barrier price touches FIRST: the one in the
// break direction (continuation) or against it (fade). Neither within horizon = chop.
// Symmetric barriers ⇒ breakeven is 50%, so a side is a real edge only if its
// Wilson lower bound clears 0.5. Bucketed by Vmult tier (HV/MV/LV) × regime.
type Brk
    int dir
    int reg
    int tier
    float entry
    float atr0
    int bidx
    bool done
    bool conf
    array<float> z
    float pcont
    bool started
    float lineRef
    int brkBar
    float tMul
    float sMul
    bool isNull
var array<Brk> pend=array.new<Brk>()
// raw counts, idx = tier(0 LV,1 MV,2 HV)*2 + regime(0 chop,1 trend)
var int[] contN=array.new<int>(6,0)
var int[] fadeN=array.new<int>(6,0)
var int[] chopN=array.new<int>(6,0)
var int[] totN =array.new<int>(6,0)
// per-bucket sums of target/stop ATR-multiples → bucket average R:R for breakeven
var float[] sumT=array.new<float>(6,0.0)
var float[] sumS=array.new<float>(6,0.0)
var float[] sumR=array.new<float>(6,0.0)   // exact realized R per bucket (win=+RR, loss=-1, chop=0)
// random-direction null baseline (same geometry, coin-flip direction)
var float nullSumR=0.0
var float nullSumR2=0.0
var int   nullN=0
// the SIGNAL side needs its own second moment for the Welch test against the null
var float sigSumR=0.0
var float sigSumR2=0.0
var int   sigN=0
var int   rngState=987654321
// CVD-gate lift (continuation rate), per regime
var float[] aWin=array.new<float>(2,0.0), var float[] aTot=array.new<float>(2,0.0), var int[] aN=array.new<int>(2,0)
var float[] gWin=array.new<float>(2,0.0), var float[] gTot=array.new<float>(2,0.0), var int[] gN=array.new<int>(2,0)

// ── META-LABEL state: online logistic + online standardizer + reliability bins ─
int NF = 8
var float[] mW    = array.new<float>(NF+1, 0.0)   // [0]=bias, [1..NF]=weights
var float[] mMean = array.new<float>(NF, 0.0)
var float[] mVar  = array.new<float>(NF, 1.0)
var int     mTrained = 0
var float[] relTot  = array.new<float>(10, 0.0)
var float[] relCont = array.new<float>(10, 0.0)
var float[] relFade = array.new<float>(10, 0.0)
var float   lastP   = na
var int     lastBin = na
// feature inputs (continuous, non-repaint)
float erNum = math.abs(srcCls - srcCls[10])
float erDen = math.sum(math.abs(ta.change(srcCls)), 10)
float erVal = erDen>0 ? erNum/erDen : 0.0
float vAvg  = ta.sma(volume,20)
float vmult = vAvg>0 ? volume/vAvg : 1.0

if calEnable and breakDir!=0 and barstate.isconfirmed and atr>0.0
    array<float> z = na
    float pc = na
    if metaEnable
        float lineSlope = breakDir>0 ? (resNow-resNow[1]) : (supNow-supNow[1])
        float beyond    = breakDir>0 ? (srcCls-resNow) : (supNow-srcCls)
        array<float> raw = array.new<float>(NF)
        array.set(raw,0, vmult)
        array.set(raw,1, erVal)
        array.set(raw,2, math.abs(lineSlope)/atrSafe)
        array.set(raw,3, float(breakDir>0?resTouch:supTouch))
        array.set(raw,4, (srcHigh-srcLow)/atrSafe)
        array.set(raw,5, beyond/atrSafe)
        array.set(raw,6, gateWired ? (cvdAgree?1.0:-1.0) : 0.0)
        array.set(raw,7, useHtfVwap ? float(breakDir*htfAlign) : 0.0)   // +1 VWAP agrees with break, -1 opposes, 0 flat/off
        z := array.new<float>(NF+1)
        array.set(z,0,1.0)
        for k=0 to NF-1
            float m=array.get(mMean,k), v=array.get(mVar,k), x=array.get(raw,k)
            float zk=(x-m)/math.sqrt(v+1e-9)
            array.set(z,k+1, math.max(-6.0,math.min(6.0,zk)))
            array.set(mMean,k, m+metaEMA*(x-m))
            array.set(mVar,k, math.max(1e-6, v+metaEMA*((x-m)*(x-m)-v)))
        pc := f_sigmoid(f_dot(mW, z))
        lastP := pc
        lastBin := math.min(9, math.max(0, int(math.floor(pc*10))))
    float lref = resBreak?resNow:supNow
    bool startNow = entryMode=="Breakout"
    float e0 = startNow ? srcCls : na
    // the trade's REAL geometry (same formulas as the entry module), in ATR units
    float gapNow = resBreak ? resGap : supGap
    float tDist  = math.min(na(gapNow) ? tgtATR*atrSafe : gapNow, tgtCapATR*atrSafe)
    float tMul   = tDist/atrSafe
    float sMul   = minStopATR
    pend.push(Brk.new(breakDir,regNow,tierI,e0,atr,bar_index,false,confAgree,z,pc,startNow,lref,bar_index,tMul,sMul,false))
    if nullEnable
        rngState := (rngState*1103515245 + 12345) % 2147483647
        int ndir = (rngState % 2)==0 ? 1 : -1
        pend.push(Brk.new(ndir,regNow,tierI,srcCls,atr,bar_index,false,false,na,na,true,na,bar_index,tMul,sMul,true))
if calEnable and barstate.isconfirmed and pend.size()>0
    for i=pend.size()-1 to 0
        Brk p=pend.get(i)
        if not p.done
            if not p.started
                // Retest mode: don't score until price actually returns to the line
                // (the real entry). Anchor the barriers there, restart the horizon.
                bool touched = low<=p.lineRef and high>=p.lineRef
                if touched
                    p.started:=true, p.entry:=p.lineRef, p.bidx:=bar_index
                else if bar_index-p.brkBar > invalWin
                    p.done:=true                    // never retested → no trade, discard
                    pend.remove(i)
            else if bar_index > p.bidx
                float favor  = p.dir>0?(srcHigh-p.entry):(p.entry-srcLow)
                float adverse= p.dir>0?(p.entry-srcLow):(srcHigh-p.entry)
                bool cHit = favor   >= p.tMul*p.atr0     // target (continuation) hit
                bool fHit = adverse >= p.sMul*p.atr0     // stop (fade) hit
                bool tmOut= bar_index-p.bidx>=horizon
                if cHit or fHit or tmOut
                    p.done:=true
                    int outcome = (cHit and not fHit) ? 1 : fHit ? 2 : 0   // 1 win/cont, 2 stop/fade (tie→stop), 0 chop
                    float rMul = p.sMul>0 ? p.tMul/p.sMul : 0.0
                    if p.isNull
                        float rN = outcome==1 ? rMul : outcome==2 ? -1.0 : 0.0
                        nullN += 1
                        nullSumR += rN
                        nullSumR2 += rN*rN
                    else
                        float rS = outcome==1 ? rMul : outcome==2 ? -1.0 : 0.0
                        sigN += 1
                        sigSumR += rS
                        sigSumR2 += rS*rS
                        int idx=p.tier*2+(p.reg==1?1:0)
                        array.set(totN,idx,array.get(totN,idx)+1)
                        array.set(sumT,idx,array.get(sumT,idx)+p.tMul)
                        array.set(sumS,idx,array.get(sumS,idx)+p.sMul)
                        if outcome==1
                            array.set(contN,idx,array.get(contN,idx)+1)
                            array.set(sumR,idx,array.get(sumR,idx)+rMul)
                        else if outcome==2
                            array.set(fadeN,idx,array.get(fadeN,idx)+1)
                            array.set(sumR,idx,array.get(sumR,idx)-1.0)
                        else
                            array.set(chopN,idx,array.get(chopN,idx)+1)
                        int rg=p.reg==1?1:0
                        array.set(aN,rg,array.get(aN,rg)+1), array.set(aTot,rg,array.get(aTot,rg)+1.0)
                        if outcome==1
                            array.set(aWin,rg,array.get(aWin,rg)+1.0)
                        if p.conf
                            array.set(gN,rg,array.get(gN,rg)+1), array.set(gTot,rg,array.get(gTot,rg)+1.0)
                            if outcome==1
                                array.set(gWin,rg,array.get(gWin,rg)+1.0)
                        if metaEnable and not na(p.z)
                            float pp = f_sigmoid(f_dot(mW, p.z))
                            float y  = outcome==1 ? 1.0 : 0.0
                            float g  = pp - y
                            int K = array.size(mW)
                            for k=0 to K-1
                                float wk=array.get(mW,k), zk=array.get(p.z,k)
                                float reg = k==0 ? 0.0 : metaL2*wk
                                array.set(mW,k, wk - metaLR*(g*zk + reg))
                            mTrained += 1
                            int bn = math.min(9, math.max(0, int(math.floor(p.pcont*10))))
                            array.set(relTot,bn, array.get(relTot,bn)+1.0)
                            if outcome==1
                                array.set(relCont,bn, array.get(relCont,bn)+1.0)
                            else if outcome==2
                                array.set(relFade,bn, array.get(relFade,bn)+1.0)
                    pend.remove(i)

f_setName(int s)=> s==2?"ENTERED":s==1?"ARMED":s==3?"INVALID":s==4?"DONE":"—"

// best gross expectancy (R) among qualifying tiers — for the net-vs-null readout
f_bestE(int rr,float be)=>
    float bestE=na
    for t=0 to 2
        int idx=t*2+rr
        int n=array.get(totN,idx)
        if n>=minSamp
            float cLo=f_wilsonLo(array.get(contN,idx),n,1.96)
            if not na(cLo) and cLo>be
                float e=array.get(sumR,idx)/n
                bestE := na(bestE) or e>bestE ? e : bestE
    bestE

// "win%/loss% n## RRx ✓" — ✓ only when win Wilson floor clears the trade's breakeven
f_cf(int t,int rr,float be)=>
    int idx=t*2+rr
    int n=array.get(totN,idx)
    string out = "warming n"+str.tostring(n)
    if n>=minSamp
        int c=array.get(contN,idx), fz=array.get(fadeN,idx)
        float cLo=f_wilsonLo(c,n,1.96)
        string mk = (not na(cLo) and cLo>be) ? " ✓" : ""
        out := str.tostring(c/n*100,"0")+"/"+str.tostring(fz/n*100,"0")+"% n"+str.tostring(n)+mk
    out

// best POSITIVE-expectancy tier in the current regime (win Wilson floor > breakeven)
f_verdict(int rr,float be,float rrAvg)=>
    float bestE=0.0
    string best="no edge yet"
    for t=0 to 2
        int idx=t*2+rr
        int n=array.get(totN,idx)
        if n>=minSamp
            int c=array.get(contN,idx)
            float cLo=f_wilsonLo(c,n,1.96)
            if not na(cLo) and cLo>be
                float e=array.get(sumR,idx)/n     // EXACT mean realized R per trade
                if e>bestE
                    bestE:=e
                    string tn=t==2?"HV":t==1?"MV":"LV"
                    best:=tn+" +"+str.tostring(e,"0.00")+"R"
    best

// reliability of the prediction bin: realized cont/fade in that bin
f_metaRel(int bn)=>
    string s="n0"
    if not na(bn)
        float t=array.get(relTot,bn)
        if t>=1
            s := str.tostring(array.get(relCont,bn)/t*100,"0")+"/"+str.tostring(array.get(relFade,bn)/t*100,"0")+"% n"+str.tostring(int(t))
    s
// meta call from the bin's Wilson floor vs the trade's breakeven (TAKE CONT / SKIP)
f_metaCall(int bn,float be)=>
    string call="SKIP"
    if not na(bn)
        float t=array.get(relTot,bn)
        if t>=minSamp
            float cLo=f_wilsonLo(array.get(relCont,bn),t,1.96)
            call := (not na(cLo) and cLo>be) ? "TAKE CONT" : "SKIP"
    call

// global breakeven from accumulated trade geometry (used by dashboard + exports)
float sumTall=0.0, float sumSall=0.0
for bi=0 to 5
    sumTall+=array.get(sumT,bi), sumSall+=array.get(sumS,bi)
float avgRR  = sumSall>0 ? sumTall/sumSall : na
float beRate = not na(avgRR) ? 1.0/(1.0+avgRR) : 0.5

// ───────────────────────────── DASHBOARD ───────────────────────────────────
var table dash=table.new(f_pos(dashPos),2,23,border_width=1)
var table mtfTbl=table.new(f_pos(mtfPos),7,2,border_width=1)
if showDash and barstate.islast
    color _bg = chart.bg_color
    float _lum = 0.299*color.r(_bg) + 0.587*color.g(_bg) + 0.114*color.b(_bg)
    bool darkBg = dashTheme=="Auto" ? _lum < 128 : dashTheme=="Dark"
    color cTxt = darkBg ? color.new(color.white,0) : color.new(#0b0b0b,0)
    color cBg  = darkBg ? color.new(color.gray,82) : color.new(color.gray,75)
    int rr=regNow
    string regTxt=isTrend?"TREND":"CHOP"
    string resTxt=resOK and not resBroken?("active · T"+str.tostring(resTouch)):resBroken?"broken":"—"
    string supTxt=supOK and not supBroken?("active · T"+str.tostring(supTouch)):supBroken?"broken":"—"
    // pick the live setup to show
    int    shS = resSetup==2 or resSetup==1 ? resSetup : supSetup==2 or supSetup==1 ? supSetup : math.max(resSetup,supSetup)
    bool   shLong = (resSetup>=1 and resSetup!=4) and not (supSetup==1 or supSetup==2)
    float  shE = shLong?resEntry:supEntry, shStp=shLong?resStop:supStop, shT=shLong?resTgt:supTgt, shRR=shLong?resRR:supRR
    string shSide = shLong?"LONG":"SHORT"
    // ── row 0 = plain-language ACTION banner (at-a-glance for non-technical users) ──
    string actTxt = shS==2 ? (regTxt+" · "+shSide+" ACTIVE — manage to target/stop") : shS==1 ? (regTxt+" · "+shSide+" SETUP — waiting for trigger") : (regTxt+" · NO SETUP — stand aside")
    color  actBg  = shS>=1 ? (shLong?color.new(colUp,0):color.new(colDn,0)) : color.new(color.gray,30)
    f_cell(dash,0,0,"CHANNEL BREAKS",color.new(color.white,0),actBg)
    f_cell(dash,1,0,actTxt,color.new(color.white,0),actBg)
    f_cell(dash,0,1,"Resistance",cTxt,cBg), f_cell(dash,1,1,resTxt,color.new(colDn,0),cBg)
    f_cell(dash,0,2,"Support",cTxt,cBg),    f_cell(dash,1,2,supTxt,color.new(colUp,0),cBg)
    f_cell(dash,0,3,"Last break",cTxt,cBg), f_cell(dash,1,3,tierS,cTxt,cBg)
    // "exp +1.24R · need 15% @ RR 6.0" — realized expectancy FIRST (the thing that is actually true),
    // then the breakeven win rate the geometry requires. RR quoted alone flatters a low-hit-rate
    // system; leading with expectancy does not.
    float globalE = sigN>0 ? sigSumR/sigN : na
    string beTxt = na(avgRR) ? "warming" : (na(globalE) ? "" : "exp "+(globalE>=0?"+":"")+str.tostring(globalE,"0.00")+"R · ")+"need "+str.tostring(beRate*100,"0")+"% @ RR "+str.tostring(avgRR,"0.0")
    f_cell(dash,0,4,"Expectancy",cTxt,color.new(color.gray,55)), f_cell(dash,1,4,beTxt, na(globalE)?cTxt:(globalE>0?color.new(colUp,0):color.new(colDn,0)),color.new(color.gray,55))
    f_cell(dash,0,5,"HV win/loss",color.new(colUp,0),cBg), f_cell(dash,1,5,f_cf(2,rr,beRate),cTxt,cBg)
    f_cell(dash,0,6,"MV win/loss",cTxt,cBg),                f_cell(dash,1,6,f_cf(1,rr,beRate),cTxt,cBg)
    f_cell(dash,0,7,"LV win/loss",color.new(colDn,0),cBg),  f_cell(dash,1,7,f_cf(0,rr,beRate),cTxt,cBg)
    f_cell(dash,0,8,"SETUP",cTxt,color.new(color.gray,55)), f_cell(dash,1,8,f_setName(shS)+(shS>=1 and shS!=4?" "+shSide:""),cTxt,color.new(color.gray,55))
    f_cell(dash,0,9,"Entry",cTxt,cBg),  f_cell(dash,1,9,shS>=2?str.tostring(shE,format.mintick):"—",cTxt,cBg)
    f_cell(dash,0,10,"Stop",cTxt,cBg),  f_cell(dash,1,10,shS>=2?str.tostring(shStp,format.mintick):"—",color.new(colDn,0),cBg)
    f_cell(dash,0,11,"Target",cTxt,cBg),f_cell(dash,1,11,shS>=2?str.tostring(shT,format.mintick):"—",color.new(colUp,0),cBg)
    f_cell(dash,0,12,"R:R",cTxt,cBg),   f_cell(dash,1,12,shS>=2 and not na(shRR)?str.tostring(shRR,"0.0"):"—",cTxt,cBg)
    string filtS = (useHV?"H":"-")+(useMV?"M":"-")+(useLV?"L":"-")
    f_cell(dash,0,13,"Tiers · mode · pend",cTxt,cBg), f_cell(dash,1,13,filtS+" · "+entryMode+" · "+str.tostring(pend.size()),cTxt,cBg)
    int aNn=array.get(aN,rr)
    float aHit = array.get(aTot,rr)>0 ? array.get(aWin,rr)/array.get(aTot,rr) : na
    int gNn=array.get(gN,rr)
    float gHit = array.get(gTot,rr)>0 ? array.get(gWin,rr)/array.get(gTot,rr) : na
    string rawS = aNn>=minSamp and not na(aHit) ? str.tostring(aHit*100,"0")+"% n"+str.tostring(aNn) : "warming n"+str.tostring(aNn)
    string gatS = (useCvdGate and gateWired) ? (gNn>=minSamp and not na(gHit) ? str.tostring(gHit*100,"0")+"% n"+str.tostring(gNn) : "warming n"+str.tostring(gNn)) : "—"
    string liftS = (useCvdGate and gateWired and not na(aHit) and not na(gHit) and gNn>=minSamp) ? ("  "+(gHit-aHit>=0?"+":"")+str.tostring((gHit-aHit)*100,"0")+"%") : ""
    color  liftC = (useCvdGate and gateWired and not na(aHit) and not na(gHit) and gNn>=minSamp) ? (gHit>aHit?color.new(colUp,0):color.new(colDn,0)) : cTxt
    f_cell(dash,0,14,"CONFIRM",cTxt,color.new(color.gray,55)), f_cell(dash,1,14,(useCvdGate and gateWired)?"ON":(useCvdGate?"not wired":"off"),(useCvdGate and gateWired)?color.new(colUp,0):color.new(color.gray,0),color.new(color.gray,55))
    f_cell(dash,0,15,"Raw f/t",cTxt,cBg),   f_cell(dash,1,15,rawS,cTxt,cBg)
    f_cell(dash,0,16,"Gated f/t",cTxt,cBg), f_cell(dash,1,16,gatS+liftS,liftC,cBg)
    string vrd = f_verdict(rr,beRate,na(avgRR)?1.0:avgRR)
    bool hasEdge = vrd != "no edge yet"
    f_cell(dash,0,17,"VERDICT",cTxt,color.new(color.gray,45)), f_cell(dash,1,17,vrd,hasEdge?color.new(colUp,0):color.new(color.orange,0),color.new(color.gray,45))
    string mP = (not metaEnable)?"off":(mTrained<metaMinTrain?("learning "+str.tostring(mTrained)+"/"+str.tostring(metaMinTrain)):(na(lastP)?"—":str.tostring(lastP*100,"0")+"%"))
    string mRel = (metaEnable and not na(lastBin))?f_metaRel(lastBin):"—"
    string mCall = (metaEnable and mTrained>=metaMinTrain and not na(lastBin))?f_metaCall(lastBin,beRate):"—"
    color  mCol = mCall=="TAKE CONT"?color.new(colUp,0):mCall=="FADE"?color.new(#3b82f6,0):mCall=="SKIP"?color.new(color.orange,0):cTxt
    f_cell(dash,0,18,"META P(cont)",cTxt,color.new(color.gray,45)), f_cell(dash,1,18,mP,cTxt,color.new(color.gray,45))
    f_cell(dash,0,19,"Reliability(bin)",cTxt,cBg),                   f_cell(dash,1,19,mRel,cTxt,cBg)
    f_cell(dash,0,20,"META CALL",cTxt,color.new(color.gray,35)),    f_cell(dash,1,20,mCall,mCol,color.new(color.gray,35))
    // anchored-VWAP alignment (chosen timeframe) vs the live/last break
    string htfTxt = not useHtfVwap ? "off" : (htfChoice+" "+f_arrow(htfAlign)+(breakDir!=0?(htfAgree?"  ✓ agree":"  ✗ oppose"):""))
    color htfCol = not useHtfVwap ? cTxt : breakDir!=0 ? (htfAgree?color.new(colUp,0):color.new(colDn,0)) : (htfAlign>0?color.new(colUp,0):htfAlign<0?color.new(colDn,0):cTxt)
    f_cell(dash,0,21,"VWAP align",cTxt,cBg), f_cell(dash,1,21,htfTxt,htfCol,cBg)
    float nullE = nullN>=minSamp ? nullSumR/nullN : na
    // Welch t: is the SIGNAL's mean R distinguishable from the NULL's coin-flip mean R?
    float sMean = sigN>0 ? sigSumR/sigN : na
    float sVar  = sigN>1 ? math.max(sigSumR2/sigN - sMean*sMean, 0.0) : na
    float nMean = nullN>0 ? nullSumR/nullN : na
    float nVar  = nullN>1 ? math.max(nullSumR2/nullN - nMean*nMean, 0.0) : na
    float tNull = (sigN>=minSamp and nullN>=minSamp and not na(sVar) and not na(nVar) and (sVar/sigN + nVar/nullN)>0) ? (sMean - nMean)/math.sqrt(sVar/sigN + nVar/nullN) : na
    float gE = f_bestE(rr,beRate)
    float netE = (not na(gE) and not na(nullE)) ? (gE - nullE - costR) : na
    string nullTxt = na(nullE) ? ("warming n"+str.tostring(nullN)) : ("net "+(na(netE)?"—":str.tostring(netE,"0.00")+"R")+(na(tNull)?"":"  t="+str.tostring(tNull,"0.0")+(math.abs(tNull)>1.96?" ✓":" ns")))
    color  nullCol = not na(netE) ? (netE>0?color.new(colUp,0):color.new(colDn,0)) : cTxt
    f_cell(dash,0,22,"Null / net",cTxt,color.new(color.gray,45)), f_cell(dash,1,22,nullTxt,nullCol,color.new(color.gray,45))
    // MTF strip — its own tidy table so the colored cells don't spill out of the dashboard
    if showMTF
        f_cell(mtfTbl,0,0,"1m",cTxt,color.new(color.gray,55)),  f_cell(mtfTbl,1,0,"2m",cTxt,color.new(color.gray,55)),  f_cell(mtfTbl,2,0,"3m",cTxt,color.new(color.gray,55))
        f_cell(mtfTbl,3,0,"5m",cTxt,color.new(color.gray,55)),  f_cell(mtfTbl,4,0,"15m",cTxt,color.new(color.gray,55)), f_cell(mtfTbl,5,0,"30m",cTxt,color.new(color.gray,55)), f_cell(mtfTbl,6,0,"60m",cTxt,color.new(color.gray,55))
        f_cell(mtfTbl,0,1,f_arrow(mt1), mt1>0?color.new(colUp,0):mt1<0?color.new(colDn,0):cTxt,cBg)
        f_cell(mtfTbl,1,1,f_arrow(mt2), mt2>0?color.new(colUp,0):mt2<0?color.new(colDn,0):cTxt,cBg)
        f_cell(mtfTbl,2,1,f_arrow(mt3), mt3>0?color.new(colUp,0):mt3<0?color.new(colDn,0):cTxt,cBg)
        f_cell(mtfTbl,3,1,f_arrow(mt5), mt5>0?color.new(colUp,0):mt5<0?color.new(colDn,0):cTxt,cBg)
        f_cell(mtfTbl,4,1,f_arrow(mt15),mt15>0?color.new(colUp,0):mt15<0?color.new(colDn,0):cTxt,cBg)
        f_cell(mtfTbl,5,1,f_arrow(mt30),mt30>0?color.new(colUp,0):mt30<0?color.new(colDn,0):cTxt,cBg)
        f_cell(mtfTbl,6,1,f_arrow(mt60),mt60>0?color.new(colUp,0):mt60<0?color.new(colDn,0):cTxt,cBg)

// ───────────────────────────── ALERTS ──────────────────────────────────────
alertcondition(resBreak,"Channel break up (bullish)","Channel Breaks: resistance / channel broken up")
alertcondition(supBreak,"Channel break down (bearish)","Channel Breaks: support / channel broken down")
alertcondition(resSetup==2 and resSetup[1]!=2,"Long entry armed","Channel Breaks: long entry triggered")
alertcondition(supSetup==2 and supSetup[1]!=2,"Short entry armed","Channel Breaks: short entry triggered")
if resBreak and tierAllowed
    alert("Channel Breaks: bullish channel break ("+tierS+" volume)",alert.freq_once_per_bar_close)
if supBreak and tierAllowed
    alert("Channel Breaks: bearish channel break ("+tierS+" volume)",alert.freq_once_per_bar_close)

// ───────────────────────────── EXPORTS ─────────────────────────────────────
color exC=color.new(color.gray,100)
float chW = resBreak?resGap:supBreak?supGap:na
plot(showEXP?resNow:na,"EXP_ResLine",color=exC,display=display.data_window)
plot(showEXP?supNow:na,"EXP_SupLine",color=exC,display=display.data_window)
plot(showEXP?breakDir:na,"EXP_Break",color=exC,display=display.data_window)         // +1 up · -1 down · 0 none
plot(showEXP?tierI:na,"EXP_VolTier",color=exC,display=display.data_window)          // 0 LV · 1 MV · 2 HV
plot(showEXP?(na(chW)?na:chW):na,"EXP_ChanWidth",color=exC,display=display.data_window)
plot(showEXP?(resSetup==2?resEntry:supSetup==2?supEntry:na):na,"EXP_Entry",color=exC,display=display.data_window)
plot(showEXP?(resSetup==2?resStop:supSetup==2?supStop:na):na,"EXP_Stop",color=exC,display=display.data_window)
plot(showEXP?(resSetup==2?resTgt:supSetup==2?supTgt:na):na,"EXP_Target",color=exC,display=display.data_window)
plot(showEXP?(resSetup>0?resSetup:supSetup>0?-supSetup:0):na,"EXP_SetupState",color=exC,display=display.data_window)
int metaCallCode = 0
if metaEnable and mTrained>=metaMinTrain and not na(lastBin)
    float t=array.get(relTot,lastBin)
    if t>=minSamp
        float cLo=f_wilsonLo(array.get(relCont,lastBin),t,1.96)
        metaCallCode := (not na(cLo) and cLo>beRate) ? 1 : 0
plot(showEXP?lastP:na,"EXP_ContProb",color=exC,display=display.data_window)
plot(showEXP?metaCallCode:na,"EXP_MetaCall",color=exC,display=display.data_window)  // 1 take cont · -1 fade · 0 skip
plot(showEXP?mTrained:na,"EXP_MetaSamples",color=exC,display=display.data_window)
````
