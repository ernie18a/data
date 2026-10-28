# Strong PWH PWL Zones | ProjectSyndicate

- url: https://www.tradingview.com/script/oYDDo9sG-Strong-PWH-PWL-Zones-ProjectSyndicate/
- type: indicator
- pine_id: PUB;b0df26a8ec5e4464805b1a0f25edce7e
- version: 1.0

## Description

Strong PWH PWL Zones

Strong PWH PWL Zones power-ranks the weekly levels that price keeps reacting to. For every week it plots the prior week's High, Low, Golden Pocket (the 50–61.8% retracement of the previous week's range) and Equilibrium as clean equal-height zones, then scores each High and Low 0–10 from measurable level quality — so you instantly know which previous-week level is likely to hold and which is likely to break. Where most PWH/PWL tools stop at drawing the level, this one tracks what price actually does to it: every extreme is followed through its full lifecycle from INTACT to SWEPT to ACCEPTED to FAILED BREAK, and the zone recolours as it goes. Anchor switchable between Weekly, Bi-Weekly and Monthly.

⬛ Core Framework

◾ Power-Ranking System (0–10) — every PWH and PWL earns a live grade from seven weighted factors: prior-week volume vs its baseline, range significance vs AWR, the rejection close (how far price closed off the extreme), distance from round numbers, isolation from recent weeks' extremes, stop-run context, and body-built extreme. Every weight is exposed and auto-normalised, so you can zero any factor you don't accept and the remaining ones rescale to fill the gap. Read the scoring provenance note below before you lean on the number.

◾ In-Zone Strength Labels — each level carries its grade inside the band: stars, the X.X/10 score, and a tier (FORMING → WEAK → MODERATE → STRONG → ELITE). Quality reads instantly without a separate panel.

◾ Previous Week Golden Pocket — the prior week's 50–61.8% fib zone, plotted automatically as the mean-reversion pocket where intraweek pullbacks so often stall.

◾ Equilibrium & Premium / Discount — the prior range's 50% line, with optional tinting of the premium and discount halves, so you always know which side of the weekly range you're trading from.

◾ Uniform AWR Zone Height — every zone (High, Low, Golden Pocket) is normalised to one identical AWR-based thickness, centred on its level, for a consistent look on any instrument.

◾ Period Separators — a full-height divider at the first bar of every anchor period, so each weekly block is visually bounded and you can never misread which week a level belongs to.

⬛ Level Lifecycle Engine

The heart of this build. A prior-week level isn't a static line — it has a life, and the state it's in tells you what to do with it.

▪️ INTACT — price has not resolved the level in either direction. ▪️ SWEPT — a wick pushed past the Sweep Trap line but the bar closed back inside the level. The stop-hunt happened and failed. ▪️ ACCEPTED — a close pushed beyond the Acceptance line. This is a real break, not a wick. ▪️ FAILED BREAK — price accepted beyond the level and then closed back inside it. Historically the highest-conviction reversal condition on the chart, and the one most tools never show you.

Each transition recolours the zone, retags its label, and prints an event marker on the bar that caused it. Twelve of the thirteen alerts are wired to these events, so you can be notified the moment a level changes character rather than hunting for it manually.

⬛ Weekly-Specific Layers

◾ Virgin Level Magnets — a prior-week extreme that the following week never traded into is unfilled business. It gets promoted to a persistent projection that survives the display cull and keeps reaching right until price finally tags it, then freezes at the tag bar so the interaction stays on the record. These are the levels price tends to travel back for.

◾ Sweep Trap & Acceptance Lines — two dashed levels above the PWH and two below the PWL. The amber Sweep Trap sits just beyond the level to mark the stop-hunt zone; the red Acceptance line sits further out to mark where a move becomes a genuine break rather than a wick. Both are fully offset-adjustable in AWR terms, and both feed the lifecycle engine directly — they are not decoration.

◾ Range Extension Targets — a measured continuation target projected beyond each extreme, sized from the prior week's own range, for when acceptance does hold.

◾ Opening Gap Tracking — the gap between the prior week's close and the new week's open, gated by a minimum AWR size so noise is ignored, with live fill tracking and a relabel the moment it closes.

⬛ Presentation & Control

◾ Strength-Shaded Fill — stronger levels render more opaque while weak ones stay faint, so the chart shows which levels carry weight before you read a single score.

◾ Score Filter — hide every level below a threshold so the chart only carries what earned its place. Purely visual: hidden levels are still tracked by the lifecycle engine, still fire alerts, and can still become magnets.

◾ Native Alerts (13) — zone touches for PWH, PWL and Golden Pocket; dedicated touches of STRONG (≥7/10) PWH and PWL; sweeps above PWH and below PWL; acceptance either side; failed breaks either side; virgin level tagged; opening gap filled.

◾ Fully Customisable — anchor period, scoring weights and normalisers, zone height, golden-pocket fib bounds, sweep/acceptance/extension offsets, separator style, magnet style and cap, gap threshold, colours, transparency, label text and size, and round-number step.

◾ Object-Budget Safe — at the heaviest setting (30 periods, every module on) the script draws well inside TradingView's 500-object limits, so nothing silently drops off the left edge of your chart.

⬛ Scoring Provenance — read this before you trust the number

Being straight with you about what has and hasn't been measured, because the score is only useful if you know what's behind it.

▪️ Five factors carry directions validated on DAILY data across FX and metals datasets — volume, range significance, rejection close, round-number distance and isolation. In that work, low-scored daily levels reacted meaningfully less often than high-scored ones. ▪️ Those directions have not been re-validated on weekly ranges. They are carried into this build as a reasoned prior, not as a measured weekly edge. Weekly levels are a different animal — fewer samples, wider ranges, different participants — and the daily result is not a promise that it transfers. ▪️ Two factors are structural priors and have not been backtested at all. Stop-run context (a week that took out the previous week's extreme and closed back inside it) and body-built extreme (an extreme built by candle bodies rather than a lone wick) come from market-structure reasoning, not from a study. ▪️ This is why every weight is exposed. Set the two new factors to 0 for the validated-direction subset, or reweight anything you disagree with. The score rescales automatically.

⬛ Repainting — what locks and what doesn't

▪️ Level geometry and scores are non-repainting. They lock in from the completed prior period and never change. Zones span exactly one period and close cleanly at the boundary — no bleed into the next week. ▪️ Lifecycle states evaluate against live price. On the currently forming bar a state can advance and its marker print before the bar closes, and the state will not step back down if price retreats within that same bar. On all closed bars the states reflect actual closes. If you want state changes to be strictly close-confirmed, wait for the bar close before acting on a live transition.

⬛ Why this is different

Most "previous week high/low" tools draw three equal-weight lines and leave you to guess which one matters. This one grades each level from prior-week behaviour, then keeps watching it — so you're not only told which level is worth respecting, you're told what price has already done to it. A STRONG level still INTACT is a level to fade. The same level flipped to FAILED BREAK is a reversal already in progress. And a virgin magnet sitting above an untouched high is where price is likely to reach for next.

🚀 Apply to Gold (XAUUSD), Silver, Forex, Crypto and Indices. Use a chart timeframe below your chosen anchor — H1 to H4 suits the weekly anchor well. The script warns you on-chart if your chart timeframe isn't lower than the anchor, since it can't resolve intra-period behaviour otherwise.

⬛ How To Trade It — Three Approaches

The score decides which approach fits; the lifecycle state tells you when it's live.

1) Sweep → Failed Break → Reversal (fade the trap) — use on STRONG / ELITE levels (≥7)

Best when the PWH or PWL is rated STRONG or ELITE.

▪️ Wait for price to push through the previous-week level and tag the amber Sweep Trap line beyond it — the liquidity grab that takes stops. The zone turns to its SWEPT tone and a marker prints. ▪️ Look for failure to reach or hold the red Acceptance line — the move stalls inside the trap band and prints rejection back through the level. ▪️ Entry: on the reversal back inside the level (a close back below PWH / above PWL). ▪️ Stop: just beyond the Acceptance line — if price closes there, the trap thesis is wrong and it's a genuine break. ▪️ Targets: Equilibrium and the Golden Pocket first, then the opposite previous-week level. ▪️ Strongest variant: let the level go to ACCEPTED and then flip to FAILED BREAK. You give up the best price but you're trading a break that has already been rejected rather than anticipating one. Use the Failed break alerts for this.

2) Acceptance Breakout → Trade With the Move — use on WEAK / MODERATE levels

Best when the level is rated WEAK or MODERATE, or formed on low prior-week volume.

▪️ Wait for a decisive break that closes beyond the red Acceptance line on expanding volume — not a single wick. The zone turns to its ACCEPTED tone. ▪️ The Sweep Trap line being cleared and held is your confirmation it's a real break, not a stop-hunt. ▪️ Entry: in the direction of the break on the close beyond the Acceptance line, or on a retest of the broken level. ▪️ Stop: back inside the level, beyond the Golden Pocket. ▪️ Targets: the Range Extension Target, trailing as the move extends. ▪️ A broken PWH flips to support, a broken PWL flips to resistance — the old level often becomes the retest entry. Watch for FAILED BREAK: if it appears, the flip has failed and you're on the wrong side.

3) Virgin Magnet Targeting — a weekly-only play

▪️ Identify a virgin magnet — a prior-week extreme the following week never reached, still projecting right. ▪️ Treat it as a destination rather than an entry. It gives your approach-1 and approach-2 trades a logical target that is defined by unfinished business rather than by a fixed multiple. ▪️ Use the Virgin level tagged alert to know the moment the magnet is reached, which is often exactly where a completed move runs out of fuel.

Rule of thumb: ⭐ STRONG/ELITE → expect a reaction, trade the trap reversal. ⭐ WEAK/MODERATE on volume → expect follow-through, trade the acceptance break. ⭐ FAILED BREAK → the market has already told you; trade the rejection.

⚠️ IMPORTANT NOTICE: This indicator identifies previous-week levels, grades them, and frames trap vs breakout scenarios. It should NOT be used as a standalone signal for entering trades. Five of the seven scoring factors carry directions validated on daily data and re-validated on nothing; two are untested structural priors. Always combine this tool with your own strategy, price-action analysis and risk management to confirm setups. Past statistical behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Strong PWH PWL Zones", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

grpA      = "Anchor & Zones"
anchorTf  = input.string("W", "Anchor Period", options=["W","2W","M"], group=grpA, tooltip="W = weekly (PWH / PWL). 2W = bi-weekly. M = monthly. Every range, AWR baseline, score and separator follows this anchor.")
perStr    = input.string("8", "Periods of Zones to Plot", options=["1","2","3","4","6","8","12","20","30"], group=grpA, tooltip="Most recent completed periods that keep their zones drawn. Older periods are deleted — virgin-level magnets survive the cull.")
maxPer    = int(str.tonumber(perStr))
heightLen = input.int(10, "Universal Height — AWR Length (periods)", minval=1, maxval=100, group=grpA, tooltip="Average period range (AWR) used to size every zone. All zones get the SAME thickness.")
uniHeight = input.float(0.060, "Universal Zone Height (× AWR)", minval=0.01, maxval=3.0, step=0.005, group=grpA, tooltip="Exact thickness applied to PWH, PWL and Golden Pocket alike, centered on each level.")
extendBars= input.int(0, "Extend Latest Period Zones (bars)", minval=0, maxval=500, group=grpA)
showLabels= input.bool(true, "Show Labels", group=grpA)
tintByStr = input.bool(true, "Shade Zone Opacity by Strength", group=grpA, tooltip="Stronger levels render more opaque.")

grpGP     = "Golden Pocket & Equilibrium"
gpFibLow  = input.float(0.50,  "Lower Fib", minval=0.0, maxval=1.0, step=0.001, group=grpGP)
gpFibHigh = input.float(0.618, "Upper Fib", minval=0.0, maxval=1.0, step=0.001, group=grpGP)
showEQ    = input.bool(true,  "Show Equilibrium (50%) Line", group=grpGP)
showPD    = input.bool(false, "Shade Premium / Discount Halves", group=grpGP, tooltip="Tints the upper half of the prior range as premium and the lower half as discount. Off by default to keep the chart light.")
pdTransp  = input.int(93, "Premium / Discount Transparency", minval=80, maxval=99, group=grpGP)

grpSM     = "Sweep / Acceptance Engine  (NEW)"
showState = input.bool(true, "Show Lifecycle State on Zones", group=grpSM, tooltip="Recolors each zone as its state changes: INTACT -> SWEPT -> ACCEPTED -> FAILED BREAK. Tracking itself is ALWAYS on — this only controls the drawing, so turning it off never changes which levels the alerts and magnets react to.")
showMarks = input.bool(true, "Plot Lifecycle Event Markers", group=grpSM)
maxMark   = input.int(40, "Max Event Markers Kept", minval=4, maxval=200, group=grpSM)
mkSize    = input.string("tiny", "Marker Size", options=["tiny","small","normal"], group=grpSM)
tagState  = input.bool(true, "Append State Tag to Zone Label", group=grpSM)

grpVM     = "Virgin Level Magnets  (NEW)"
useMagnet = input.bool(true, "Track Untouched Levels as Magnets", group=grpVM, tooltip="A prior-period extreme that the FOLLOWING period never traded into is left unfilled. It is promoted to a persistent magnet line that keeps projecting right until price finally tags it.")
maxMagnet = input.int(8, "Max Active Magnets", minval=1, maxval=40, group=grpVM)
magWidth  = input.int(1, "Magnet Line Width", minval=1, maxval=4, group=grpVM)
magStyle  = input.string("dotted", "Magnet Line Style", options=["dotted","dashed","solid"], group=grpVM)
magLabels = input.bool(true, "Label Magnets", group=grpVM)
txtMagH   = input.string("VIRGIN PWH", "Magnet High Text", group=grpVM)
txtMagL   = input.string("VIRGIN PWL", "Magnet Low Text", group=grpVM)

grpG      = "Opening Gap  (NEW)"
useGap    = input.bool(true, "Track Period Opening Gap", group=grpG, tooltip="Zone between the prior period's close and the new period's open. Tracks whether the gap has been filled.")
minGapMult= input.float(0.05, "Minimum Gap (× AWR)", minval=0.0, maxval=2.0, step=0.01, group=grpG)
txtGapU   = input.string("GAP UP — UNFILLED", "Gap Up Text", group=grpG)
txtGapD   = input.string("GAP DOWN — UNFILLED", "Gap Down Text", group=grpG)
txtGapF   = input.string("GAP FILLED", "Gap Filled Text", group=grpG)

grpS      = "Strength Scoring (0–10)"
adrLen    = input.int(10, "AWR / Volume Baseline (periods)", minval=3, maxval=60, group=grpS)
wVol      = input.float(0.22, "Weight: Prior-Period Volume", minval=0, maxval=1, step=0.01, group=grpS, tooltip="Higher prior-period volume = stronger level. Direction validated on DAILY data (+, 5/5 symbols); carried over untested on this anchor.")
wRange    = input.float(0.16, "Weight: Range Significance", minval=0, maxval=1, step=0.01, group=grpS, tooltip="Bigger prior-period range vs AWR = stronger. Direction validated on DAILY data (+); untested on this anchor.")
wRej      = input.float(0.12, "Weight: Rejection Close", minval=0, maxval=1, step=0.01, group=grpS, tooltip="Period closing away from its extreme = stronger. Direction validated on DAILY data (+); untested on this anchor.")
wRound    = input.float(0.15, "Weight: Round-Number Distance", minval=0, maxval=1, step=0.01, group=grpS, tooltip="Levels NEAR round numbers get swept more. Distance from round = stronger. Direction validated on DAILY data (-, 5/5); untested on this anchor.")
wConf     = input.float(0.11, "Weight: Isolation (low confluence)", minval=0, maxval=1, step=0.01, group=grpS, tooltip="Levels clustered with recent periods' extremes break more. Isolation = stronger. Direction validated on DAILY data (-, 4/5); untested on this anchor.")
wFail     = input.float(0.14, "Weight: Stop-Run Context  (NEW)", minval=0, maxval=1, step=0.01, group=grpS, tooltip="STRUCTURAL PRIOR, NOT BACKTESTED. A period that took out the previous period's extreme and then closed back inside it left a failed expansion — the resulting level is treated as stronger. Plain continuation scores lower. Set to 0 to disable.")
wBody     = input.float(0.10, "Weight: Body-Built Extreme  (NEW)", minval=0, maxval=1, step=0.01, group=grpS, tooltip="STRUCTURAL PRIOR, NOT BACKTESTED. An extreme built by candle BODIES (acceptance) scores higher than a lone wick spike, which is treated as a liquidity print more likely to be re-swept. Set to 0 to disable, or use it inverted by preference.")
volFull   = input.float(1.30, "Full-credit Volume (x avg)", minval=1.0, maxval=4.0, step=0.05, group=grpS)
rngFull   = input.float(1.40, "Full-credit Range (x AWR)", minval=1.0, maxval=4.0, step=0.05, group=grpS)
rejFull   = input.float(0.60, "Full-credit Rejection (frac of range)", minval=0.1, maxval=1.0, step=0.05, group=grpS)
bodyNorm  = input.float(0.15, "Body-Built Tolerance (frac of range)", minval=0.01, maxval=0.60, step=0.01, group=grpS, tooltip="How far below the high (above the low) the most extreme candle body may sit before body credit decays to zero.")
roundStepIn = input.float(0.0, "Round-Number Step (0 = auto)", minval=0.0, group=grpS)
minScore  = input.float(0.0, "Hide Levels Below Score", minval=0.0, maxval=10.0, step=0.5, group=grpS, tooltip="Display filter only. Hidden levels are still tracked by the lifecycle engine, still fire alerts and can still become virgin magnets.")

grpL      = "Labels"
txtHigh   = input.string("PREVIOUS WEEK HIGH", "PWH Text", group=grpL)
txtLow    = input.string("PREVIOUS WEEK LOW",  "PWL Text", group=grpL)
txtGP     = input.string("PREVIOUS WEEK GOLDEN POCKET", "Golden Pocket Text", group=grpL)
txtEQ     = input.string("EQUILIBRIUM 50%", "Equilibrium Text", group=grpL)
showStars = input.bool(true, "Show Stars & Tier", group=grpL)
labelSz   = input.string("normal", "Label Size", options=["tiny","small","normal","large"], group=grpL)

grpLv     = "Dashed Levels & Targets"
showLevels = input.bool(true, "Show Dashed Levels", group=grpLv)
sweepMult  = input.float(0.08, "Sweep Trap Offset (× AWR)", minval=0.0, maxval=5.0, step=0.01, group=grpLv, tooltip="Distance of the SWEEP TRAP lines above PWH / below PWL. Also the wick threshold the lifecycle engine calls a sweep.")
breakMult  = input.float(0.30, "Acceptance Offset (× AWR)", minval=0.0, maxval=5.0, step=0.01, group=grpLv, tooltip="Distance of the ACCEPTANCE lines beyond PWH / PWL. A close beyond this line is what the lifecycle engine calls acceptance.")
showExt    = input.bool(true, "Show Range-Extension Targets", group=grpLv, tooltip="Projects a measured continuation target beyond each extreme, sized from the prior period's own range.")
extMult    = input.float(0.50, "Extension Target (× prior range)", minval=0.1, maxval=3.0, step=0.05, group=grpLv)
txtSweep   = input.string("SWEEP TRAP LEVEL", "Sweep Trap Text", group=grpLv)
txtBreak   = input.string("ACCEPTANCE LEVEL", "Acceptance Text", group=grpLv)
txtExt     = input.string("RANGE EXTENSION TARGET", "Extension Text", group=grpLv)
sweepCol   = input.color(#E0A52E, "Sweep Trap Color", group=grpLv)
breakCol   = input.color(#BE3B3B, "Acceptance Color", group=grpLv)
extCol     = input.color(#5A7FA8, "Extension Target Color", group=grpLv)
lvWidth    = input.int(2, "Line Width", minval=1, maxval=5, group=grpLv)
lvLabelSz  = input.string("normal", "Level Label Size", options=["tiny","small","normal","large","huge"], group=grpLv)
lvTxtColor = input.color(#A8A8A8, "Level Label Text", group=grpLv)

grpSep    = "Period Separators  (NEW)"
showSep   = input.bool(true, "Show Period Separators", group=grpSep, tooltip="Vertical divider at the first bar of every anchor period, so each weekly / bi-weekly / monthly block is visually bounded on the chart.")
sepCol    = input.color(#5C6470, "Separator Color", group=grpSep)
sepWidth  = input.int(1, "Separator Width", minval=1, maxval=4, group=grpSep)
sepStyle  = input.string("dashed", "Separator Style", options=["dashed","dotted","solid"], group=grpSep)

grpC      = "Colors"
highColor = input.color(#0D5447, "PWH Zone", group=grpC)
gpColor   = input.color(#787878, "Golden Pocket Zone", group=grpC)
lowColor  = input.color(#6E1E28, "PWL Zone", group=grpC)
sweptCol  = input.color(#C99A2E, "State: Swept", group=grpC)
accCol    = input.color(#4A4A55, "State: Accepted", group=grpC)
failCol   = input.color(#C6483F, "State: Failed Break", group=grpC)
premCol   = input.color(#3E5C7A, "Premium Half", group=grpC)
discCol   = input.color(#3E7A5C, "Discount Half", group=grpC)
gapCol    = input.color(#8A7BB8, "Opening Gap", group=grpC)
magCol    = input.color(#9AA5B1, "Virgin Magnet", group=grpC)
eqCol     = input.color(#8E8E8E, "Equilibrium Line", group=grpC)
gpTransp  = input.int(72, "Golden Pocket Transparency", minval=40, maxval=96, group=grpC)
baseTransp = input.int(58, "Zone Transparency (weakest)", minval=40, maxval=96, group=grpC)
gapTransp = input.int(84, "Opening Gap Transparency", minval=40, maxval=99, group=grpC)
txtColor  = input.color(#CFCFCF, "Label Text", group=grpC)
showBorder = input.bool(false, "Show Zone Borders", group=grpC)
borderCol = input.color(color.new(#9A9A9A, 60), "Border Color", group=grpC)

type PerDraw
    box   bHigh = na
    box   bGP   = na
    box   bLow  = na
    box   bPrem = na
    box   bDisc = na
    box   bGap  = na
    label lHigh = na
    label lGP   = na
    label lLow  = na
    label lEQ   = na
    label lGap  = na
    line  nUS   = na
    line  nUB   = na
    line  nLS   = na
    line  nLB   = na
    line  nEQ   = na
    line  nEU   = na
    line  nEL   = na
    label aUS   = na
    label aUB   = na
    label aLS   = na
    label aLB   = na
    label aEU   = na
    label aEL   = na

f_delPer(PerDraw d) =>
    if not na(d.bHigh)
        box.delete(d.bHigh)
    if not na(d.bGP)
        box.delete(d.bGP)
    if not na(d.bLow)
        box.delete(d.bLow)
    if not na(d.bPrem)
        box.delete(d.bPrem)
    if not na(d.bDisc)
        box.delete(d.bDisc)
    if not na(d.bGap)
        box.delete(d.bGap)
    if not na(d.lHigh)
        label.delete(d.lHigh)
    if not na(d.lGP)
        label.delete(d.lGP)
    if not na(d.lLow)
        label.delete(d.lLow)
    if not na(d.lEQ)
        label.delete(d.lEQ)
    if not na(d.lGap)
        label.delete(d.lGap)
    if not na(d.nUS)
        line.delete(d.nUS)
    if not na(d.nUB)
        line.delete(d.nUB)
    if not na(d.nLS)
        line.delete(d.nLS)
    if not na(d.nLB)
        line.delete(d.nLB)
    if not na(d.nEQ)
        line.delete(d.nEQ)
    if not na(d.nEU)
        line.delete(d.nEU)
    if not na(d.nEL)
        line.delete(d.nEL)
    if not na(d.aUS)
        label.delete(d.aUS)
    if not na(d.aUB)
        label.delete(d.aUB)
    if not na(d.aLS)
        label.delete(d.aLS)
    if not na(d.aLB)
        label.delete(d.aLB)
    if not na(d.aEU)
        label.delete(d.aEU)
    if not na(d.aEL)
        label.delete(d.aEL)

f_size()   => labelSz=="tiny" ? size.tiny : labelSz=="small" ? size.small : labelSz=="large" ? size.large : size.normal
f_lvSize() => lvLabelSz=="tiny" ? size.tiny : lvLabelSz=="small" ? size.small : lvLabelSz=="normal" ? size.normal : lvLabelSz=="huge" ? size.huge : size.large
f_mkSize() => mkSize=="tiny" ? size.tiny : mkSize=="small" ? size.small : size.normal
f_magStyle() => magStyle=="dashed" ? line.style_dashed : magStyle=="solid" ? line.style_solid : line.style_dotted
f_sepStyle() => sepStyle=="dotted" ? line.style_dotted : sepStyle=="solid" ? line.style_solid : line.style_dashed

f_stars(float s) => s>=8 ? "★★★★" : s>=6.5 ? "★★★" : s>=5 ? "★★" : s>=3 ? "★" : "·"
f_tier(float s)  => s>=8 ? "ELITE" : s>=6.5 ? "STRONG" : s>=5 ? "MODERATE" : s>=3 ? "WEAK" : "FORMING"
f_stateTag(int st) => st==1 ? "SWEPT" : st==2 ? "ACCEPTED" : st==3 ? "FAILED BREAK" : "INTACT"
f_stateCol(int st, color baseC) => st==1 ? sweptCol : st==2 ? accCol : st==3 ? failCol : baseC

f_roundStep(float px) =>
    roundStepIn > 0 ? roundStepIn : math.pow(10.0, math.floor(math.log10(math.max(px, 1e-9))) - 2.0)

f_roundProx(float level, float px) =>
    step = f_roundStep(px)
    d = math.abs(level - math.round(level/step)*step) / step
    1.0 - math.min(d/0.5, 1.0)

f_avg(array<float> a, int n) =>
    sz  = array.size(a)
    cnt = math.min(sz, n)
    s   = 0.0
    used = 0
    if cnt > 0
        for k = 0 to cnt-1
            v = array.get(a, k)
            if not na(v)
                s += v
                used += 1
    used > 0 ? s/used : na

f_confluence(array<float> a, float level, float tol) =>
    sz  = array.size(a)
    cnt = math.min(sz, 5)
    c   = 0
    if cnt > 0
        for k = 0 to cnt-1
            if math.abs(array.get(a, k) - level) <= tol
                c += 1
    c

f_score(float rejFrac, float volR, float rangeR, float level, float px, int confN, float failSc, float bodySc) =>
    volSc  = math.min(math.max(volR,0.0)   / math.max(volFull,1.0), 1.0)
    rngSc  = math.min(math.max(rangeR,0.0) / math.max(rngFull,1.0), 1.0)
    rejSc  = math.min(math.max(rejFrac,0.0)/ math.max(rejFull,0.1), 1.0)
    rndSc  = 1.0 - f_roundProx(level, px)
    confSc = 1.0 - math.min(confN/2.0, 1.0)
    fSc    = math.min(math.max(failSc,0.0), 1.0)
    bSc    = math.min(math.max(bodySc,0.0), 1.0)
    wTot   = wVol + wRange + wRej + wRound + wConf + wFail + wBody
    raw    = wTot>0 ? (wVol*volSc + wRange*rngSc + wRej*rejSc + wRound*rndSc + wConf*confSc + wFail*fSc + wBody*bSc)/wTot : 0.0
    math.round(math.min(math.max(raw,0.0),1.0) * 100.0) / 10.0

f_transp(float sc) =>
    t = tintByStr ? baseTransp - (sc/10.0)*30.0 : baseTransp - 12.0
    math.round(math.max(math.min(t, 96.0), 30.0))

f_centerLabel(label lb, int leftB, int rightB) =>
    if not na(lb)
        label.set_x(lb, math.round((leftB + rightB)/2.0))

var float pHigh    = na
var float pLow     = na
var float pVol     = na
var float pBodyTop = na
var float pBodyBot = na

var array<PerDraw> drawPer = array.new<PerDraw>()
var array<float> rngHist = array.new<float>()
var array<float> volHist = array.new<float>()
var array<float> hiHist  = array.new<float>()
var array<float> loHist  = array.new<float>()

var int   abLeft = na
var box   abHigh = na
var box   abGP   = na
var box   abLow  = na
var box   abPrem = na
var box   abDisc = na
var box   abGap  = na
var label alHigh = na
var label alGP   = na
var label alLow  = na
var label alEQ   = na
var label alGap  = na
var line  lnUS = na
var line  lnUB = na
var line  lnLS = na
var line  lnLB = na
var line  lnEQ = na
var line  lnEU = na
var line  lnEL = na
var label laUS = na
var label laUB = na
var label laLS = na
var label laLB = na
var label laEU = na
var label laEL = na

var bool  haveActive = false
var float lvHigh  = na
var float lvLow   = na
var float lvHalf  = na
var float lvSwU   = na
var float lvBkU   = na
var float lvSwL   = na
var float lvBkL   = na
var int   stU     = 0
var int   stL     = 0
var bool  tchU    = false
var bool  tchL    = false
var float scHighActive = na
var float scLowActive  = na

var bool  gapActive = false
var bool  gapUp     = false
var bool  gapFilled = false
var float gapRef    = na

var array<float> magPx   = array.new<float>()
var array<line>  magLn   = array.new<line>()
var array<label> magLb   = array.new<label>()

var array<label> mkArr = array.new<label>()

var array<line> sepArr = array.new<line>()

evSweepU  = false
evSweepL  = false
evAccU    = false
evAccL    = false
evFailU   = false
evFailL   = false
evMagTag  = false
evGapFill = false

newP = ta.change(time(anchorTf)) != 0

if newP
    boundaryBar = bar_index

    if haveActive
        if not tchU
            if useMagnet and not na(lvHigh)
                ln = line.new(abLeft, lvHigh, boundaryBar, lvHigh, xloc=xloc.bar_index, color=magCol, width=magWidth, style=f_magStyle())
                lb = magLabels ? label.new(boundaryBar, lvHigh, txtMagH, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=magCol, style=label.style_label_left, size=f_mkSize()) : na
                array.push(magPx, lvHigh)
                array.push(magLn, ln)
                array.push(magLb, lb)

        if not tchL
            if useMagnet and not na(lvLow)
                ln2 = line.new(abLeft, lvLow, boundaryBar, lvLow, xloc=xloc.bar_index, color=magCol, width=magWidth, style=f_magStyle())
                lb2 = magLabels ? label.new(boundaryBar, lvLow, txtMagL, xloc=xloc.bar_index, color=color.new(color.gray,100), textcolor=magCol, style=label.style_label_left, size=f_mkSize()) : na
                array.push(magPx, lvLow)
                array.push(magLn, ln2)
                array.push(magLb, lb2)

        while array.size(magPx) > maxMagnet
            array.shift(magPx)
            oldLn = array.shift(magLn)
            oldLb = array.shift(magLb)
            if not na(oldLn)
                line.delete(oldLn)
            if not na(oldLb)
                label.delete(oldLb)

    if showSep
        sepLn = line.new(boundaryBar, low - syminfo.mintick, boundaryBar, high + syminfo.mintick, xloc=xloc.bar_index, extend=extend.both, color=sepCol, width=sepWidth, style=f_sepStyle())
        array.push(sepArr, sepLn)
        while array.size(sepArr) > maxPer + 1
            oldSep = array.shift(sepArr)
            if not na(oldSep)
                line.delete(oldSep)

    prevH  = pHigh
    prevL  = pLow
    prevC  = close[1]
    prevV  = pVol
    prevBT = pBodyTop
    prevBB = pBodyBot
    prevH2 = array.size(hiHist) > 0 ? array.get(hiHist, 0) : na
    prevL2 = array.size(loHist) > 0 ? array.get(loHist, 0) : na

    valid = not na(prevH) and not na(prevL) and prevH > prevL and not na(prevC)

    haveActive := false
    stU := 0
    stL := 0
    tchU := false
    tchL := false

    if valid
        rng = prevH - prevL

        array.unshift(rngHist, rng)
        array.unshift(volHist, na(prevV) ? na : prevV)
        if array.size(rngHist) > 60
            array.pop(rngHist)
            array.pop(volHist)

        awr    = f_avg(rngHist, adrLen)
        avgV   = f_avg(volHist, adrLen)
        tol    = na(awr) ? rng*0.10 : awr*0.10
        volR   = (not na(avgV) and avgV>0 and not na(prevV)) ? prevV/avgV : 1.0
        rangeR = (not na(awr) and awr>0) ? rng/awr : 1.0

        confH = f_confluence(hiHist, prevH, tol)
        confL = f_confluence(loHist, prevL, tol)

        rejH = (prevH - prevC)/rng
        rejL = (prevC - prevL)/rng

        failH = na(prevH2) ? 0.5 : (prevH > prevH2 ? (prevC < prevH2 ? 1.0 : 0.35) : 0.5)
        failL = na(prevL2) ? 0.5 : (prevL < prevL2 ? (prevC > prevL2 ? 1.0 : 0.35) : 0.5)

        bNorm = math.max(rng * bodyNorm, syminfo.mintick)
        bodyH = na(prevBT) ? 0.5 : 1.0 - math.min(math.max(prevH - prevBT, 0.0)/bNorm, 1.0)
        bodyL = na(prevBB) ? 0.5 : 1.0 - math.min(math.max(prevBB - prevL, 0.0)/bNorm, 1.0)

        scH = f_score(rejH, volR, rangeR, prevH, prevC, confH, failH, bodyH)
        scL = f_score(rejL, volR, rangeR, prevL, prevC, confL, failL, bodyL)
        scHighActive := scH
        scLowActive  := scL

        array.unshift(hiHist, prevH)
        array.unshift(loHist, prevL)
        if array.size(hiHist) > 20
            array.pop(hiHist)
            array.pop(loHist)

        awrH  = f_avg(rngHist, heightLen)
        awrU  = not na(awrH) and awrH > 0 ? awrH : rng
        zh    = awrU * uniHeight
        halfH = zh / 2.0
        eqMid = prevL + rng * 0.5
        gpMid = prevL + rng * ((gpFibLow + gpFibHigh) / 2.0)
        gpU   = gpMid + halfH
        gpL   = gpMid - halfH

        bw = showBorder ? 1 : 0
        clearC = color.new(color.gray, 100)
        bordC  = showBorder ? borderCol : clearC

        showH = scH >= minScore
        showL = scL >= minScore

        haveActive := true
        lvHigh := prevH
        lvLow  := prevL
        lvHalf := halfH
        lvSwU  := prevH + awrU*sweepMult
        lvBkU  := prevH + awrU*breakMult
        lvSwL  := prevL - awrU*sweepMult
        lvBkL  := prevL - awrU*breakMult

        abLeft := boundaryBar
        abHigh := showH ? box.new(boundaryBar, prevH+halfH, boundaryBar, prevH-halfH, border_color=bordC, border_width=bw, bgcolor=color.new(highColor, f_transp(scH))) : na
        abGP   := box.new(boundaryBar, gpU, boundaryBar, gpL, border_color=bordC, border_width=bw, bgcolor=color.new(gpColor, gpTransp))
        abLow  := showL ? box.new(boundaryBar, prevL+halfH, boundaryBar, prevL-halfH, border_color=bordC, border_width=bw, bgcolor=color.new(lowColor, f_transp(scL))) : na
        abPrem := showPD ? box.new(boundaryBar, prevH, boundaryBar, eqMid, border_color=clearC, border_width=0, bgcolor=color.new(premCol, pdTransp)) : na
        abDisc := showPD ? box.new(boundaryBar, eqMid, boundaryBar, prevL, border_color=clearC, border_width=0, bgcolor=color.new(discCol, pdTransp)) : na

        if showLabels
            sH = showStars ? "  " + f_stars(scH) + "  " + str.tostring(scH,"#.0") + "/10 (" + f_tier(scH) + ")" : "  " + str.tostring(scH,"#.0") + "/10"
            sL = showStars ? "  " + f_stars(scL) + "  " + str.tostring(scL,"#.0") + "/10 (" + f_tier(scL) + ")" : "  " + str.tostring(scL,"#.0") + "/10"
            alHigh := showH ? label.new(boundaryBar, prevH, txtHigh + sH, xloc=xloc.bar_index, color=clearC, textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center) : na
            alGP   := label.new(boundaryBar, gpMid, txtGP, xloc=xloc.bar_index, color=clearC, textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center)
            alLow  := showL ? label.new(boundaryBar, prevL, txtLow + sL, xloc=xloc.bar_index, color=clearC, textcolor=txtColor, style=label.style_none, size=f_size(), textalign=text.align_center) : na
            alEQ   := showEQ ? label.new(boundaryBar, eqMid, txtEQ, xloc=xloc.bar_index, color=clearC, textcolor=eqCol, style=label.style_none, size=f_size(), textalign=text.align_center) : na
        else
            alHigh := na
            alGP   := na
            alLow  := na
            alEQ   := na

        lnEQ := showEQ ? line.new(boundaryBar, eqMid, boundaryBar, eqMid, xloc=xloc.bar_index, color=eqCol, width=1, style=line.style_dotted) : na

        if showLevels
            lnUS := line.new(boundaryBar, lvSwU, boundaryBar, lvSwU, xloc=xloc.bar_index, color=sweepCol, width=lvWidth, style=line.style_dashed)
            lnUB := line.new(boundaryBar, lvBkU, boundaryBar, lvBkU, xloc=xloc.bar_index, color=breakCol, width=lvWidth, style=line.style_dashed)
            lnLS := line.new(boundaryBar, lvSwL, boundaryBar, lvSwL, xloc=xloc.bar_index, color=sweepCol, width=lvWidth, style=line.style_dashed)
            lnLB := line.new(boundaryBar, lvBkL, boundaryBar, lvBkL, xloc=xloc.bar_index, color=breakCol, width=lvWidth, style=line.style_dashed)
            laUS := label.new(boundaryBar, lvSwU, txtSweep, xloc=xloc.bar_index, color=clearC, textcolor=lvTxtColor, style=label.style_none, size=f_lvSize(), textalign=text.align_center)
            laUB := label.new(boundaryBar, lvBkU, txtBreak, xloc=xloc.bar_index, color=clearC, textcolor=lvTxtColor, style=label.style_none, size=f_lvSize(), textalign=text.align_center)
            laLS := label.new(boundaryBar, lvSwL, txtSweep, xloc=xloc.bar_index, color=clearC, textcolor=lvTxtColor, style=label.style_none, size=f_lvSize(), textalign=text.align_center)
            laLB := label.new(boundaryBar, lvBkL, txtBreak, xloc=xloc.bar_index, color=clearC, textcolor=lvTxtColor, style=label.style_none, size=f_lvSize(), textalign=text.align_center)
        else
            lnUS := na
            lnUB := na
            lnLS := na
            lnLB := na
            laUS := na
            laUB := na
            laLS := na
            laLB := na

        if showExt
            euY = prevH + rng*extMult
            elY = prevL - rng*extMult
            lnEU := line.new(boundaryBar, euY, boundaryBar, euY, xloc=xloc.bar_index, color=extCol, width=1, style=line.style_dashed)
            lnEL := line.new(boundaryBar, elY, boundaryBar, elY, xloc=xloc.bar_index, color=extCol, width=1, style=line.style_dashed)
            laEU := label.new(boundaryBar, euY, txtExt, xloc=xloc.bar_index, color=clearC, textcolor=lvTxtColor, style=label.style_none, size=f_lvSize(), textalign=text.align_center)
            laEL := label.new(boundaryBar, elY, txtExt, xloc=xloc.bar_index, color=clearC, textcolor=lvTxtColor, style=label.style_none, size=f_lvSize(), textalign=text.align_center)
        else
            lnEU := na
            lnEL := na
            laEU := na
            laEL := na

        gapSz = math.abs(open - prevC)
        if useGap and gapSz > awrU*minGapMult and gapSz > 0
            gapUp     := open > prevC
            gapActive := true
            gapFilled := false
            gapRef    := prevC
            gTop = math.max(open, prevC)
            gBot = math.min(open, prevC)
            abGap  := box.new(boundaryBar, gTop, boundaryBar, gBot, border_color=clearC, border_width=0, bgcolor=color.new(gapCol, gapTransp))
            alGap  := showLabels ? label.new(boundaryBar, (gTop+gBot)/2.0, gapUp ? txtGapU : txtGapD, xloc=xloc.bar_index, color=clearC, textcolor=gapCol, style=label.style_none, size=f_lvSize(), textalign=text.align_center) : na
        else
            gapActive := false
            gapFilled := false
            gapRef    := na
            abGap     := na
            alGap     := na

        array.push(drawPer, PerDraw.new(bHigh=abHigh, bGP=abGP, bLow=abLow, bPrem=abPrem, bDisc=abDisc, bGap=abGap, lHigh=alHigh, lGP=alGP, lLow=alLow, lEQ=alEQ, lGap=alGap, nUS=lnUS, nUB=lnUB, nLS=lnLS, nLB=lnLB, nEQ=lnEQ, nEU=lnEU, nEL=lnEL, aUS=laUS, aUB=laUB, aLS=laLS, aLB=laLB, aEU=laEU, aEL=laEL))
        while array.size(drawPer) > maxPer
            f_delPer(array.shift(drawPer))
    else
        abHigh := na
        abGP   := na
        abLow  := na
        abPrem := na
        abDisc := na
        abGap  := na
        alHigh := na
        alGP   := na
        alLow  := na
        alEQ   := na
        alGap  := na
        lnUS := na
        lnUB := na
        lnLS := na
        lnLB := na
        lnEQ := na
        lnEU := na
        lnEL := na
        gapActive := false

    pHigh    := high
    pLow     := low
    pVol     := volume
    pBodyTop := math.max(open, close)
    pBodyBot := math.min(open, close)
else
    pHigh    := na(pHigh) ? high : math.max(pHigh, high)
    pLow     := na(pLow)  ? low  : math.min(pLow, low)
    pVol     := na(pVol)  ? volume : pVol + volume
    pBodyTop := na(pBodyTop) ? math.max(open, close) : math.max(pBodyTop, math.max(open, close))
    pBodyBot := na(pBodyBot) ? math.min(open, close) : math.min(pBodyBot, math.min(open, close))

rightB = bar_index + (barstate.islast ? extendBars : 0)
if not na(abGP)
    box.set_right(abGP, rightB)
    if not na(abHigh)
        box.set_right(abHigh, rightB)
    if not na(abLow)
        box.set_right(abLow, rightB)
    if not na(abPrem)
        box.set_right(abPrem, rightB)
    if not na(abDisc)
        box.set_right(abDisc, rightB)
    f_centerLabel(alHigh, abLeft, rightB)
    f_centerLabel(alGP,   abLeft, rightB)
    f_centerLabel(alLow,  abLeft, rightB)
    f_centerLabel(alEQ,   abLeft, rightB)
    if not na(lnEQ)
        line.set_x2(lnEQ, rightB)
    if not na(lnUS)
        line.set_x2(lnUS, rightB)
        line.set_x2(lnUB, rightB)
        line.set_x2(lnLS, rightB)
        line.set_x2(lnLB, rightB)
        f_centerLabel(laUS, abLeft, rightB)
        f_centerLabel(laUB, abLeft, rightB)
        f_centerLabel(laLS, abLeft, rightB)
        f_centerLabel(laLB, abLeft, rightB)
    if not na(lnEU)
        line.set_x2(lnEU, rightB)
        line.set_x2(lnEL, rightB)
        f_centerLabel(laEU, abLeft, rightB)
        f_centerLabel(laEL, abLeft, rightB)

if haveActive
    if high >= lvHigh - lvHalf and low <= lvHigh + lvHalf
        tchU := true
    if high >= lvLow - lvHalf and low <= lvLow + lvHalf
        tchL := true

    sweepU = high >= lvSwU and close < lvHigh
    sweepL = low  <= lvSwL and close > lvLow
    acceptU = close > lvBkU
    acceptL = close < lvBkL

    prevStU = stU
    prevStL = stL

    if acceptU
        stU := 2
    else if stU == 2 and close < lvHigh
        stU := 3
    else if stU == 0 and sweepU
        stU := 1

    if acceptL
        stL := 2
    else if stL == 2 and close > lvLow
        stL := 3
    else if stL == 0 and sweepL
        stL := 1

    evSweepU := stU == 1 and prevStU == 0
    evSweepL := stL == 1 and prevStL == 0
    evAccU   := stU == 2 and prevStU != 2
    evAccL   := stL == 2 and prevStL != 2
    evFailU  := stU == 3 and prevStU == 2
    evFailL  := stL == 3 and prevStL == 2

    scU = nz(scHighActive, 5.0)
    scD = nz(scLowActive, 5.0)
    if showState and stU != prevStU
        if not na(abHigh)
            box.set_bgcolor(abHigh, color.new(f_stateCol(stU, highColor), f_transp(scU)))
        if tagState and not na(alHigh)
            sH2 = showStars ? "  " + f_stars(scU) + "  " + str.tostring(scU,"#.0") + "/10 (" + f_tier(scU) + ")" : "  " + str.tostring(scU,"#.0") + "/10"
            label.set_text(alHigh, txtHigh + sH2 + "  ·  " + f_stateTag(stU))
    if showState and stL != prevStL
        if not na(abLow)
            box.set_bgcolor(abLow, color.new(f_stateCol(stL, lowColor), f_transp(scD)))
        if tagState and not na(alLow)
            sL2 = showStars ? "  " + f_stars(scD) + "  " + str.tostring(scD,"#.0") + "/10 (" + f_tier(scD) + ")" : "  " + str.tostring(scD,"#.0") + "/10"
            label.set_text(alLow, txtLow + sL2 + "  ·  " + f_stateTag(stL))

    if showMarks
        if evSweepU
            mk1 = label.new(bar_index, high, "SWEEP ▲", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(sweptCol, 25), textcolor=#101010, style=label.style_label_down, size=f_mkSize())
            array.push(mkArr, mk1)
        if evSweepL
            mk2 = label.new(bar_index, low, "SWEEP ▼", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(sweptCol, 25), textcolor=#101010, style=label.style_label_up, size=f_mkSize())
            array.push(mkArr, mk2)
        if evAccU
            mk3 = label.new(bar_index, high, "ACCEPT ▲", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(accCol, 25), textcolor=#E8E8E8, style=label.style_label_down, size=f_mkSize())
            array.push(mkArr, mk3)
        if evAccL
            mk4 = label.new(bar_index, low, "ACCEPT ▼", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(accCol, 25), textcolor=#E8E8E8, style=label.style_label_up, size=f_mkSize())
            array.push(mkArr, mk4)
        if evFailU
            mk5 = label.new(bar_index, high, "FAILED BREAK", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(failCol, 20), textcolor=#F2F2F2, style=label.style_label_down, size=f_mkSize())
            array.push(mkArr, mk5)
        if evFailL
            mk6 = label.new(bar_index, low, "FAILED BREAK", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(failCol, 20), textcolor=#F2F2F2, style=label.style_label_up, size=f_mkSize())
            array.push(mkArr, mk6)
        while array.size(mkArr) > maxMark
            oldMk = array.shift(mkArr)
            if not na(oldMk)
                label.delete(oldMk)

if gapActive and not na(abGap)
    if not gapFilled
        box.set_right(abGap, rightB)
        f_centerLabel(alGap, abLeft, rightB)
        filled = gapUp ? low <= gapRef : high >= gapRef
        if filled
            gapFilled := true
            evGapFill := true
            box.set_bgcolor(abGap, color.new(gapCol, math.min(gapTransp + 8, 99)))
            if not na(alGap)
                label.set_text(alGap, txtGapF)
                label.set_textcolor(alGap, #7A7A7A)

if array.size(magPx) > 0
    for i = array.size(magPx) - 1 to 0
        px = array.get(magPx, i)
        ln = array.get(magLn, i)
        lb = array.get(magLb, i)
        tagged = low <= px and high >= px
        if tagged
            evMagTag := true
            if not na(ln)
                line.set_x2(ln, bar_index)
                line.set_color(ln, color.new(magCol, 55))
            if not na(lb)
                label.delete(lb)
            array.remove(magPx, i)
            array.remove(magLn, i)
            array.remove(magLb, i)
        else
            if not na(ln)
                line.set_x2(ln, rightB)
            if not na(lb)
                label.set_x(lb, rightB)

tfTooBig = timeframe.in_seconds() >= timeframe.in_seconds(anchorTf)
var label warnLb = na
if barstate.islast
    if not na(warnLb)
        label.delete(warnLb)
        warnLb := na
    if tfTooBig
        warnLb := label.new(bar_index, high, "Chart timeframe is not lower than the " + anchorTf + " anchor —\nswitch to an intra-period timeframe for this tool to resolve levels.", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#7A2B2B, 15), textcolor=#F0F0F0, style=label.style_label_down, size=size.small, textalign=text.align_left)

touchH = not na(abHigh) and high >= box.get_bottom(abHigh) and low <= box.get_top(abHigh)
touchL = not na(abLow)  and high >= box.get_bottom(abLow)  and low <= box.get_top(abLow)
touchG = not na(abGP)   and high >= box.get_bottom(abGP)   and low <= box.get_top(abGP)

alertcondition(touchH, "Touch PWH Zone", "Price touched the Previous Week High zone")
alertcondition(touchL, "Touch PWL Zone", "Price touched the Previous Week Low zone")
alertcondition(touchG, "Touch Golden Pocket", "Price touched the prior-period Golden Pocket")
alertcondition(touchH and scHighActive >= 7.0, "Touch STRONG PWH", "Price touched a STRONG (≥7) Previous Week High")
alertcondition(touchL and scLowActive  >= 7.0, "Touch STRONG PWL", "Price touched a STRONG (≥7) Previous Week Low")
alertcondition(evSweepU, "Sweep above PWH", "Liquidity sweep above the Previous Week High — closed back inside")
alertcondition(evSweepL, "Sweep below PWL", "Liquidity sweep below the Previous Week Low — closed back inside")
alertcondition(evAccU, "Acceptance above PWH", "Close accepted above the Previous Week High")
alertcondition(evAccL, "Acceptance below PWL", "Close accepted below the Previous Week Low")
alertcondition(evFailU, "Failed break above PWH", "Accepted above the PWH then closed back inside — failed break")
alertcondition(evFailL, "Failed break below PWL", "Accepted below the PWL then closed back inside — failed break")
alertcondition(evMagTag, "Virgin level tagged", "Price tagged a previously untouched prior-period level")
alertcondition(evGapFill, "Opening gap filled", "The period opening gap has been filled")
````
