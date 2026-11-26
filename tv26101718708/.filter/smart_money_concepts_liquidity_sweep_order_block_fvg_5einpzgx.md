# Smart Money Concepts  Liquidity Sweep, Order Block & FVG

- url: https://www.tradingview.com/script/5eInpzGX-Smart-Money-Concepts-Liquidity-Sweep-Order-Block-FVG/
- type: indicator
- pine_id: PUB;2133283b99cc47788fe5d5c99ac299b5
- version: 2.0

## Description

OVERVIEW
 
Every Smart Money indicator draws order blocks and tells you they work. This one scores them 0–100 and then forward-tests whether the score is actually true — on your instrument, on your timeframe.
 
It maps liquidity, detects stop-hunts, builds entry zones from the displacement that follows, confirms them with real order flow, and grades every zone that price returns to. Instead of "here is an order block, trust me", the panel tells you something like:
 
   Tier-A zones returned +0.23R vs +0.08R for a matched control, n=61, t=2.1 — PROVEN
 
...or, just as usefully, NOT PROVEN. It is built to be able to tell you it doesn't work.
 
This is a research and framing tool. It is NOT a strategy, NOT a signal service, and NOT a validated edge.
 
 
WHY THESE PARTS ARE ONE TOOL (mashup rationale)
 
The Smart Money / ICT model is a SEQUENCE. Each step is meaningless on its own, and that is why they are combined here rather than sold as separate scripts:
 
1. LIQUIDITY POOLS — Stops cluster above equal highs (buy-side) and below equal lows (sell-side). Swing points within an ATR tolerance are clustered into a single pool; the more swings, the more stops resting there. A pool is not a signal. It is a magnet and a target.
 
2. THE SWEEP — Price wicks THROUGH the pool and closes back INSIDE it. That is a stop-hunt, and it is the only part of the sequence that reveals intent. A sweep alone is still not a trade.
 
3. DISPLACEMENT — An impulsive, ATR-normalised move away from the swept level. This is what separates a SWEEP (reversal) from a RUN (continuation).
 
4. THE ZONE — Displacement leaves footprints: a FAIR VALUE GAP (a three-bar imbalance) and an ORDER BLOCK (the last opposing candle before the impulse). Where an FVG sits INSIDE an order block, two independent structures agree — flagged as a confluence zone.
 
5. LOCATION — The zone is then judged on WHERE it sits. Against the VOLUME PROFILE (value area, point of control, and untested "naked" POCs), and against the DEALING-RANGE EQUILIBRIUM. A bullish zone in DISCOUNT is a zone you are being paid to buy; the same zone in premium is not.
 
6. ORDER FLOW — The question structure cannot answer: did anyone actually show up? Intrabar delta signs each lower-timeframe bar's volume by its own direction. A bullish zone born on NEGATIVE delta is a vacuum, not a footprint — and scores nothing for it.
 
7. THE ENTRY — Price is never chased. The engine arms only when price RETRACES into a fresh zone, then frames entry / stop / target — the target being THE NEXT OPPOSING POOL OF STOPS, because that is where the next batch of liquidity is resting.
 
8. THE CALIBRATION — Without it, everything above is folklore.
 
Remove any one of these and the tool marks noise, chases price, targets nothing, ignores where value actually is, or reports a confidence it has not earned.
 
 
THE SCORE (0–100, eight measurable components, no discretion)
 
   Displacement strength ...... impulse body ÷ ATR — the energy behind the zone
   Participation (RVOL) ....... volume at formation vs its own recent average
   Born from a sweep .......... did a stop-hunt precede it? (the core ICT claim)
   Imbalance size ............. FVG height ÷ ATR
   HTF alignment .............. does the higher timeframe agree?
   Premium / discount ......... bullish zone in DISCOUNT? bearish zone in PREMIUM?
   Volume-profile location .... at value, at the POC, or at an untested POC?
   Order flow (delta) ......... was the displacement backed by real aggressive flow?
 
Tiers: A (70+) · B (40–69) · C (below 40). Every weight is an input — if you think the sweep matters more than I do, turn it up, and let the calibration tell you whether you were right.
 
 
THE CALIBRATION — AND WHY IT IS HONEST
 
Every zone trade is paired with a MATCHED CONTROL: the same bar, the same direction, and the SAME R:R — but entered at market with an ATR stop instead of at the zone. This isolates exactly one variable: does entering AT THE ZONE beat entering anywhere else on identical geometry? Under a random walk, this control has zero expectancy, so anything the zones earn is real.
 
Each tier is tested against its OWN control, because an A-zone may carry a very different R:R from a C-zone, and a trade's hit rate depends on its R:R.
 
Results are reported as EXPECTANCY IN R, not hit rate. When R:R varies from trade to trade, a hit rate on its own is meaningless: a 6R winner at 20% is +0.4R (excellent), while a 1R winner at 55% is +0.1R (barely worth the commission).
 
A Welch t-test decides whether the difference is real or luck. The panel does not say "proven" unless t > 1.96.
 
The panel also answers the one question that matters most: DOES TIER A BEAT TIER C? If the scoring model has any value, A-grade zones must outperform C-grade zones. If they don't, the score is noise — and it will say so.
 
Conventions are deliberately chosen so the tool cannot flatter itself:
 · Both barriers touched on the same bar → the STOP is assumed first.
 · Expired trades are marked to market, not counted as wins or losses.
 · Everything is logged and resolved on confirmed bars only.
 
 
HOW TO USE IT
 
1. Read the bias, the liquidity map, and the premium/discount shading. Pools above are buy-side, pools below are sell-side, and price usually travels from one to the other.
2. Wait for a SWEEP, then for a zone to be created by the displacement that follows.
3. Do NOT chase. The engine arms an entry only when price RETRACES into a fresh zone.
4. Watch for ABSORPTION at the zone — heavy volume, a small range, price holding. Someone is soaking up the aggression. That is a defended zone, and it is the best live confirmation available.
5. READ THE CALIBRATION BEFORE YOU WEIGHT ANY OF IT. If Tier A is not proven on your instrument and timeframe, a zone is a LOCATION, not a PROBABILITY — treat it as context only.
6. Entry / stop / target and the resulting R:R are drawn on the chart. They are arithmetic, not advice.
 
Do not tune the weights until the numbers turn green. That is curve-fitting, and the calibration exists to catch it — not to be defeated by it.
 
 
ORIGINALITY
 
The underlying SMC concepts are public and credited below. What is assembled here is the specific synthesis: an eight-component measurable score, the fusion of SMC structure with auction-theory location (volume profile and premium/discount), true intrabar order-flow confirmation, a per-tier matched control, expectancy-in-R reporting, and a significance test that can — and frequently does — return "not proven".
 
Clean-room implementation. No third-party Pine code is reused.
 
 
UNIVERSAL / DATA REQUIREMENTS
 
Works on any symbol and any timeframe — the engine is ATR-normalised throughout, so it adapts to the instrument rather than assuming point values.
 
Volume improves the score but is NOT required. On a symbol without real volume, the RVOL, volume-profile and order-flow components neutralise and the panel says so, rather than blanking or pretending.
 
Intrabar delta requires a timeframe strictly below the chart's. The script AUTO-MAPS this (1m→5s, 3m→15s, 5m→30s, 15m→1m, and so on) because if the intrabar timeframe equals the chart timeframe there is only ONE intrabar — the bar itself — and delta degenerates to ±100% on every bar. Where true intrabar data is unavailable, the script falls back to a close-location proxy AND LABELS IT AS A PROXY in the panel.
 
 
NON-REPAINTING
 
Pools, sweeps, displacement, zones, the volume profile, absorption and entries are ALL computed on confirmed bars only.
 
Swing points use ta.pivot* and are therefore known only AFTER their confirmation bars. This is why a liquidity pool appears a few bars after its swing. That delay is the honest cost of not repainting, and it is paid deliberately — a level that moves after the fact is worse than no level at all.
 
The higher-timeframe read uses lookahead_off with a live-bar offset. The calibration harness logs AND resolves on confirmed bars, so its statistics cannot inflate intrabar. Nothing here is drawn and then moved.
 
 
HONEST LIMITATIONS — PLEASE READ
 
Smart Money Concepts is a popular framework, not a proven one. That is precisely why this script measures it instead of asserting it.
 
The calibration figures are IN-SAMPLE, close-to-close, with NO costs or slippage, and they use overlapping windows. A proven in-sample edge is NOT a guarantee of out-of-sample results.
 
The rolling volume profile is an APPROXIMATION — each bar's volume is spread uniformly across the bins its range covers. It is not tick data.
 
Small samples are unreliable. A tier with a low "n" is provisional even if it looks good.
 
If the edge is near zero, negative, or unstable across timeframes, the honest conclusion is that this model carries no edge on that instrument. The tool is designed to be able to tell you that, and you should believe it when it does.
 
Nothing here predicts price.
 
 
CONCEPT CREDITS
 
Smart Money / ICT concepts — liquidity pools, stop-hunts, displacement, fair value gaps, order blocks, premium/discount and optimal trade entry — are public trading concepts popularised by Michael J. Huddleston (Inner Circle Trader) and the wider SMC community.
Market Profile, the point of control and the value area — J. Peter Steidlmayer and the CBOT.
Market structure theory — Charles Dow.
Average True Range — J. Welles Wilder.
Wilson score interval — Edwin B. Wilson.
Triple-barrier forward labelling — Marcos López de Prado.
Welch's t-test — B. L. Welch.
 
The zone-scoring model, the order-flow fusion, the per-tier matched control and the tier calibration are the author's own. Not affiliated with, nor endorsed by, any of the above.
 
 
DISCLAIMER
 
This is a research and educational tool only. It is NOT financial advice, NOT a recommendation, and offers NO guarantee of profitability or accuracy. Indicators describe past behaviour; they do not predict the future. Entry, stop and target output is arithmetic, not advice. Trading carries a risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability for any use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// SMART MONEY CONCEPTS — LIQUIDITY SWEEP, ORDER BLOCK & FVG ENTRY ENGINE                     v1.2
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A Smart-Money / ICT engine that maps liquidity, detects stop-hunts, and builds entry zones from
//   the displacement that follows — and then does the one thing no other SMC tool does:
//   IT SCORES EVERY ZONE AND FORWARD-TESTS WHETHER THE SCORE ACTUALLY WORKS.
//
//   Every order block and fair-value gap is graded 0-100 from MEASURABLE features. Each zone is then
//   tracked from the moment price returns to it: did it produce the move, or fail? The dashboard
//   reports the hit rate PER SCORE TIER against the UNCONDITIONAL BASE RATE of the same trade
//   geometry, with a Wilson 95% lower bound.
//
//   So instead of "here is an order block, trust me", you get: "A-grade zones held 61% (base 43%),
//   Edge +18pp, n=57, proven" — or, just as usefully, "no proven edge on this symbol".
//   It is a research and framing tool — NOT a strategy, NOT a signal service, NOT a validated edge.
//
// WHAT IS DIFFERENT ABOUT THE SCORE
//   Most SMC tools treat an order block as an order block. But a zone sitting on a HIGH-VOLUME NODE
//   is a zone the market has already agreed on, and a zone in DISCOUNT is a zone you are being paid
//   to buy. So the score fuses SMC structure with AUCTION-THEORY location:
//     • VOLUME PROFILE — a rolling profile gives the POC, the value area, and a running list of
//       NAKED POCs (a prior point of control price has not traded back to). A zone that overlaps
//       value, or a naked POC, is a zone with real business behind it.
//     • PREMIUM / DISCOUNT — the dealing range (recent swing high to swing low) has an EQUILIBRIUM at
//       its midpoint. ICT's premium/discount is exactly this: buying in discount and selling in
//       premium is the whole idea of Optimal Trade Entry. A bullish zone below equilibrium scores;
//       a bullish zone in premium does not.
//   These are not decoration. They are two more measurable columns in a score that is then TESTED.
//
// WHY THESE PARTS ARE ONE TOOL  (mashup rationale)
//   The ICT model is a SEQUENCE, and each step is meaningless alone:
//     1. LIQUIDITY POOLS. Stops cluster above equal highs (buy-side) and below equal lows (sell-
//        side). Swing points within an ATR tolerance are clustered into a pool; the more touches,
//        the more stops rest there. A pool is not a signal — it is a magnet and a target.
//     2. THE SWEEP. Price wicks THROUGH the pool and closes back INSIDE it. That is a stop-hunt, and
//        it is the only part of the sequence that reveals intent. A sweep alone is still not a trade.
//     3. DISPLACEMENT. An impulsive, ATR-normalised move away from the swept level. This is what
//        separates a sweep (reversal) from a run (continuation).
//     4. THE ZONE. Displacement leaves footprints: a FAIR VALUE GAP (three-bar imbalance) and an
//        ORDER BLOCK (the last opposing candle before the impulse). Where an FVG sits INSIDE an OB,
//        two independent structures agree — flagged as a CONFLUENCE zone.
//     5. LOCATION. The zone is then judged on WHERE it sits: against the volume profile (value, POC,
//        naked POC) and against the dealing-range equilibrium (premium vs discount).
//     6. THE ENTRY. Price is not chased. The engine waits for a retrace INTO the zone, then frames
//        entry / stop / target — the target being THE NEXT OPPOSING LIQUIDITY POOL, because that is
//        where the next batch of stops is resting.
//     7. THE CALIBRATION. Without it, everything above is folklore.
//   Remove any one and the tool marks noise, chases price, targets nothing, ignores where value
//   actually is, or — worst of all — reports a confidence it has not earned.
//
// THE SCORE  (0-100, every component measurable, no discretion)
//   • Displacement strength   impulse body / ATR — the energy behind the zone
//   • Participation (RVOL)    volume at formation vs its own recent average
//   • Born from a sweep       did a stop-hunt precede it? (the core ICT claim)
//   • Imbalance size          FVG height / ATR
//   • HTF alignment           does the higher timeframe agree with the zone's direction?
//   • Premium / discount      is a bullish zone in DISCOUNT (or a bearish zone in PREMIUM)?
//   • Volume-profile location does the zone overlap the value area, the POC, or a NAKED POC?
//   Every weight is an INPUT. Tiers: A (>=70) · B (40-69) · C (<40). The calibration reports each
//   tier separately, so the score is not asserted — it is TESTED. If A-grade zones do not beat
//   C-grade zones, the scoring model is not working on this instrument and the panel will show it.
//
//  FIXED IN v1.1 - CVD DIVERGENCE DETECTION
//    The CVD divergence test called ta.lowest / ta.highest after an `and`. Pine short-circuits, so
//    on any bar where the price comparison failed the CVD extremes were never evaluated and their
//    rolling windows drifted over a broken history - making the divergence read unreliable. All
//    four extremes are now computed unconditionally and combined afterwards.
//
// HOW TO USE
//   1. Read the BIAS, the liquidity map and the premium/discount shading. Pools above are buy-side,
//      pools below are sell-side, and price usually travels from one to the other.
//   2. Wait for a SWEEP marker, then a zone created by the displacement that follows.
//   3. Do NOT chase. The engine arms an entry only when price RETRACES into a fresh zone.
//   4. Read the tier and the CALIBRATION before you weight it. If A-grade has no proven edge here,
//      a zone is a location, not a probability — treat it as context only.
//   5. Entry / stop / target and the resulting R:R are drawn. They are arithmetic, not advice.
//
// DATA / SCOPE
//   Any symbol, any timeframe — the engine is ATR-normalised throughout, so it adapts to the
//   instrument rather than assuming point values. Volume improves the score but is NOT required: on
//   a symbol without real volume the RVOL and volume-profile components are neutralised and the
//   panel says so. Works best where liquidity actually clusters: index futures, FX, liquid stocks.
//
// NON-REPAINT
//   Pools, sweeps, displacement, zones, the volume profile and entries are ALL computed on CONFIRMED
//   bars only. Swing points use ta.pivot* and so are known only after their confirmation bars — this
//   is why a pool appears a few bars after its swing, and it is the honest cost of not repainting.
//   The HTF read uses lookahead_off with a live-bar offset. The calibration harness logs AND resolves
//   on confirmed bars, so its statistics cannot inflate intrabar. Nothing is drawn and then moved.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_Bias · EXP_Sweep · EXP_ZoneDir · EXP_ZoneScore · EXP_InZone · EXP_Entry · EXP_Stop ·
//   EXP_Target · EXP_RR · EXP_EdgeA · EXP_POC · EXP_Equilibrium · EXP_PremDisc
//
// CONCEPT CREDIT
//   Smart-Money / ICT concepts — liquidity pools, stop-hunts, displacement, fair value gaps, order
//   blocks, premium/discount and optimal trade entry — are public trading concepts popularised by
//   Michael J. Huddleston (Inner Circle Trader) and the wider SMC community. Market Profile, the
//   point of control and the value area — J. Peter Steidlmayer and the CBOT. Market-structure theory
//   traces to Charles Dow. ATR — J. Welles Wilder. Wilson score interval — Edwin B. Wilson.
//   Triple-barrier forward labelling — Marcos López de Prado.
//   The zone-scoring model, the volume-profile / premium-discount fusion, the tier calibration and
//   the base-rate harness are the author's own. Independent implementation; no third-party Pine code
//   is reused. Not affiliated with, nor endorsed by, any of the above.
//
// HONESTY / LIMITATIONS
//   SMC is a popular framework, not a proven one — which is precisely why this script measures it
//   instead of asserting it. Calibration figures are IN-SAMPLE, with no costs or slippage, and use
//   overlapping windows; a proven in-sample edge is NOT a guarantee out-of-sample. When both barriers
//   are touched on the same bar, the STOP is assumed first — the conservative assumption, and the one
//   that cannot flatter the result. The rolling volume profile is an APPROXIMATION (bar range spread
//   uniformly across bins), not tick data. If the Edge is near zero, negative, or unstable across
//   timeframes, the honest conclusion is that this model carries no edge on that instrument.
//   Nothing here predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice, NOT a recommendation, and NO guarantee
//   of results. Entry/stop/target output is arithmetic, not advice. Trading carries risk of loss.
//   Test out-of-sample and make your own decisions. The author accepts no liability for any use.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Smart Money Concepts — Liquidity Sweep, Order Block & FVG Entry Engine", "SMC Engine",
     overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500,
     max_bars_back = 3000)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
g1 = "01 · Liquidity map"
g2 = "02 · Sweep & displacement"
g3 = "03 · Zones (order blocks & FVGs)"
gV = "04 · Volume profile & naked POC"
gP = "05 · Premium / discount (dealing range)"
g4 = "06 · Scoring weights"
g5 = "07 · Entry framing"
g6 = "08 · Calibration (does the score work?)"
g7 = "09 · Levels & drawing"
g8 = "10 · Labels"
g9 = "11 · Dashboard & theme"

pivLen   = input.int(8, "Swing length", minval = 2, maxval = 50, group = g1, tooltip = "Bars either side of a swing point. Larger = fewer, more significant pools. Swings confirm this many bars AFTER the fact — the honest cost of not repainting.")
eqTolA   = input.float(0.25, "Equal-level tolerance (×ATR)", minval = 0.02, maxval = 2.0, step = 0.01, group = g1, tooltip = "Swings within this distance are clustered into ONE liquidity pool. ATR-normalised, so it adapts to the instrument.")
maxPools = input.int(12, "Max pools per side", minval = 2, maxval = 40, group = g1)
poolExt  = input.int(60, "Extend pools (bars)", minval = 5, maxval = 500, group = g1)

dispMin  = input.float(1.0, "Displacement threshold (×ATR)", minval = 0.2, maxval = 5.0, step = 0.1, group = g2, tooltip = "The impulse body must exceed this multiple of ATR. This is what separates a real displacement from an ordinary bar.")
sweepBars= input.int(6, "Sweep-to-displacement window (bars)", minval = 1, maxval = 30, group = g2, tooltip = "How soon after a sweep the displacement must arrive for the zone to count as 'born from a sweep'.")
needClose= input.bool(true, "Sweep must close back inside the pool", group = g2, tooltip = "The wick prints through, the close prints back inside. Without this you are marking breakouts, not stop-hunts.")

useFVG   = input.bool(true, "Detect fair value gaps", group = g3)
useOB    = input.bool(true, "Detect order blocks", group = g3)
minGapA  = input.float(0.10, "Min FVG size (×ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = g3)
maxZones = input.int(16, "Max live zones", minval = 2, maxval = 60, group = g3)
mitigMode= input.string("Close through", "Zone is spent when", options = ["Close through", "Wick through"], group = g3, tooltip = "'Close through' is stricter and keeps zones alive longer — a wick INTO a zone is what you want, not what kills it.")

useVP    = input.bool(true, "Use the volume profile", group = gV, tooltip = "A rolling profile giving the POC, the value area and a list of NAKED POCs. A zone with real business behind it is a better zone — and the calibration tests whether that is true here.")
vpLook   = input.int(200, "Profile lookback (bars)", minval = 30, maxval = 1000, group = gV)
vpBins   = input.int(24, "Profile bins", minval = 8, maxval = 60, group = gV, tooltip = "Resolution of the profile. More bins = finer POC, heavier script.")
vpVA     = input.float(70.0, "Value area (%)", minval = 50.0, maxval = 90.0, step = 5.0, group = gV)
vpEvery  = input.int(5, "Recompute every N bars", minval = 1, maxval = 50, group = gV, tooltip = "The profile moves slowly, so it does not need rebuilding on every bar. Raise this if the script feels heavy.")
maxNPOC  = input.int(8, "Max naked POCs kept", minval = 0, maxval = 30, group = gV, tooltip = "A naked POC is a prior point of control that price has NOT traded back to. They act as magnets.")

gO       = "05b · Order flow"
ofMode   = input.string("Intrabar delta (true)", "Order flow", options = ["Intrabar delta (true)", "Bar proxy (close location)", "Off"], group = gO, tooltip = "Intrabar delta reads the LOWER timeframe and signs each intrabar's volume by its own direction — real aggressor flow. The bar proxy uses the close's position in the bar's range, which is an approximation and is labelled as one. Intrabar is heavier but honest.")
ofLtfMode= input.string("Auto", "Intrabar timeframe", options = ["Auto","Manual"], group = gO, tooltip = "AUTO picks a timeframe well below the chart's. This matters: if the intrabar timeframe EQUALS the chart timeframe there is only ONE intrabar — the bar itself — and delta degenerates to +/-100% on every bar. Auto prevents that.")
ofLtfMan = input.timeframe("1", "Manual intrabar timeframe", group = gO, tooltip = "Only used when the mode above is Manual. If this is not strictly below your chart timeframe the script falls back to the proxy and says so.")
absorbRV = input.float(1.5, "Absorption: RVOL above", minval = 1.0, maxval = 6.0, step = 0.1, group = gO, tooltip = "Absorption = heavy volume with a SMALL range while price sits in the zone. Someone is soaking up the aggression — that is a defended zone.")
absorbRg = input.float(0.7, "Absorption: range below (×ATR)", minval = 0.1, maxval = 2.0, step = 0.1, group = gO)
cvdLen   = input.int(50, "CVD divergence lookback", minval = 5, maxval = 300, group = gO)

usePD    = input.bool(true, "Use premium / discount", group = gP, tooltip = "The dealing range (recent swing high to swing low) has an equilibrium at its midpoint. Buying in DISCOUNT and selling in PREMIUM is the whole idea behind Optimal Trade Entry.")
drLook   = input.int(80, "Dealing-range lookback (bars)", minval = 20, maxval = 500, group = gP)
shadePD  = input.bool(true, "Shade premium / discount", group = gP)

wDisp    = input.int(25, "Weight · displacement", minval = 0, maxval = 60, group = g4)
wRvol    = input.int(15, "Weight · participation (RVOL)", minval = 0, maxval = 60, group = g4)
wSweep   = input.int(20, "Weight · born from a sweep", minval = 0, maxval = 60, group = g4, tooltip = "The core ICT claim: a zone created after a stop-hunt is higher quality. The calibration tests whether that is true HERE.")
wGap     = input.int(10, "Weight · imbalance size", minval = 0, maxval = 60, group = g4)
wHTF     = input.int(10, "Weight · HTF alignment", minval = 0, maxval = 60, group = g4)
wPD      = input.int(10, "Weight · premium / discount", minval = 0, maxval = 60, group = g4)
wVP      = input.int(10, "Weight · volume-profile location", minval = 0, maxval = 60, group = g4)
wOF      = input.int(15, "Weight · order flow (delta at formation)", minval = 0, maxval = 60, group = g4, tooltip = "Was the displacement backed by REAL aggressive flow in the zone's direction, or was it a vacuum? This is the question the structure alone cannot answer.")
rvolLen  = input.int(20, "RVOL length", minval = 5, maxval = 200, group = g4)
htfTf    = input.timeframe("60", "Higher timeframe", group = g4)
tierA    = input.int(70, "Tier A at / above", minval = 50, maxval = 95, group = g4)
tierB    = input.int(40, "Tier B at / above", minval = 15, maxval = 49, group = g4)

minEntry = input.int(0, "Only arm entries at / above score", minval = 0, maxval = 90, group = g5, tooltip = "0 = frame every zone. Raise it once the calibration tells you which tier actually pays.")
stopBufA = input.float(0.25, "Stop buffer beyond zone (×ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = g5)
tgtMode  = input.string("Next liquidity pool", "Target", options = ["Next liquidity pool", "Naked POC", "Fixed R multiple"], group = g5, tooltip = "Liquidity target = price travels from one pool of stops to the next. Naked POC = the untested point of control acts as a magnet. Fixed R = the fallback.")
rrFixed  = input.float(2.0, "Fixed R multiple", minval = 0.5, maxval = 10.0, step = 0.5, group = g5)
minRR    = input.float(1.0, "Hide setups below R:R", minval = 0.0, maxval = 10.0, step = 0.25, group = g5)
maxRR    = input.float(6.0, "Cap R:R at", minval = 1.0, maxval = 30.0, step = 0.5, group = g5, tooltip = "A liquidity pool 10R away gives a beautiful-looking R:R that almost never fills. Capping keeps the geometry realistic — and keeps the calibration comparable.")

calibOn  = input.bool(true, "Forward-test the zone score", group = g6, tooltip = "Every zone price returns to is graded with a triple barrier: did it reach the target before the stop? Reported PER TIER against the unconditional base rate of the same geometry, Wilson-bounded.")
calHor   = input.int(50, "Grading horizon (bars)", minval = 5, maxval = 300, group = g6)
calMinN  = input.int(15, "Min sample per tier", minval = 5, maxval = 300, group = g6)
// The control is MATCHED: every zone trade is paired with a same-bar, same-direction, same-R:R trade
// entered at market with an ATR stop. That isolates the zone's contribution and nothing else.

showPools= input.bool(true, "Draw liquidity pools", group = g7)
showSweep= input.bool(true, "Mark sweeps", group = g7)
showZones= input.bool(true, "Draw zones", group = g7)
showVP   = input.bool(true, "Draw POC / value area", group = g7)
showNPOC = input.bool(true, "Draw naked POCs", group = g7)
showEQ   = input.bool(true, "Draw equilibrium", group = g7)
showSetup= input.bool(true, "Draw entry / stop / target", group = g7)
showOF   = input.bool(true, "Mark absorption / CVD divergence", group = g7)
showMitig= input.bool(false, "Keep spent zones on the chart", group = g7)
lineW    = input.int(2, "Line width", minval = 1, maxval = 6, group = g7)
colBull  = input.color(#26a69a, "Bullish", inline = "c", group = g7)
colBear  = input.color(#ef5350, "Bearish", inline = "c", group = g7)
colLiq   = input.color(#ffa726, "Liquidity", inline = "c", group = g7)
colVP    = input.color(#ab47bc, "Volume profile", inline = "c", group = g7)

showLbl  = input.bool(true, "Show labels", group = g8)
lblPool  = input.bool(true, "Label liquidity pools", group = g8)
lblZone  = input.bool(true, "Label zones (tier + score)", group = g8)
lblVP    = input.bool(true, "Label POC / naked POC", group = g8)
lblSetup = input.bool(true, "Label entry / stop / target with R:R", group = g8)
lblSize  = input.string("Small", "Label size", options = ["Tiny","Small","Normal"], group = g8)

showPanel= input.bool(true, "Show dashboard", group = g9)
panelMode= input.string("Compact", "Dashboard detail", options = ["Compact","Pro"], group = g9)
panelPos = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g9)
legendPos= input.string("Bottom Right", "Legend position", options = ["Bottom Right","Bottom Left","Middle Left","Top Left"], group = g9, tooltip = "TradingView's own watermark sits bottom-LEFT and will clip a legend placed there.")
showLegend=input.bool(true, "Show legend / key", group = g9)
themeOpt = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g9)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          TYPES
// ═════════════════════════════════════════════════════════════════════════════════════════
type Pool
    float px
    int   bi
    int   side
    int   hits
    bool  swept
    line  ln
    label lb

type Zone
    float top
    float bot
    int   bi
    int   dir
    float score
    bool  isFVG
    bool  fromSweep
    bool  confluence
    bool  atValue
    bool  spent
    bool  armed
    box   bx
    label lb

type Trade
    int   bi
    float entry
    float stop
    float tgt
    int   dir
    int   tier
    float rr            // planned R multiple — the outcome is scored in R, not just win/lose

type NPoc
    float px
    int   bi
    bool  tested
    line  ln
    label lb

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                    ENGINE PRIMITIVES
// ═════════════════════════════════════════════════════════════════════════════════════════
float atr    = ta.atr(14)
bool  hasVol = ta.cum(nz(volume)) > 0
float vol0   = nz(volume, 0.0)
float rvol   = hasVol ? vol0 / math.max(ta.sma(vol0, rvolLen), 1e-9) : 1.0

float htfEma  = request.security(syminfo.tickerid, htfTf, ta.ema(close, 20)[barstate.isrealtime ? 1 : 0], lookahead = barmerge.lookahead_off)
float htfPx   = request.security(syminfo.tickerid, htfTf, close[barstate.isrealtime ? 1 : 0], lookahead = barmerge.lookahead_off)
int   htfBias = na(htfEma) or na(htfPx) ? 0 : htfPx > htfEma ? 1 : -1

float ph = ta.pivothigh(high, pivLen, pivLen)
float pl = ta.pivotlow(low, pivLen, pivLen)

f_lblSize() => lblSize == "Tiny" ? size.tiny : lblSize == "Normal" ? size.normal : size.small
f_lum(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : s == "Middle Left" ? position.middle_left : position.top_right
f_wilsonLo(float w, float n, float z) =>
    if n <= 0
        na
    else
        p = w / n
        d = 1.0 + z * z / n
        c = (p + z * z / (2.0 * n)) / d
        m = (z * math.sqrt(p * (1.0 - p) / n + z * z / (4.0 * n * n))) / d
        c - m

bool darkUI   = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)

// ═════════════════════════════════════════════════════════════════════════════════════════
//   STATE — every array below is mutated ONLY on confirmed bars.
//   Pine rolls back `var` SCALARS between intrabar ticks but NOT array contents: an ungated push
//   would duplicate pools/zones on every tick of the live bar and evict real history.
//
//   AND THE LOOP TRAP: `for i = 0 to array.size(a) - 1` on an EMPTY array becomes `for i = 0 to -1`,
//   and Pine COUNTS DOWN when `to` < `from` — so it runs with i = 0 and array.get() throws
//   "index 0 is out of bounds, array size is 0". EVERY loop below is size-guarded.
// ═════════════════════════════════════════════════════════════════════════════════════════
var array<Pool>  poolsHi = array.new<Pool>()
var array<Pool>  poolsLo = array.new<Pool>()
var array<Zone>  zones   = array.new<Zone>()
var array<Trade> pend    = array.new<Trade>()
var array<NPoc>  npocs   = array.new<NPoc>()
// Buckets 1/2/3 = zone tiers C/B/A. Buckets 5/6/7 = THEIR OWN matched controls (tier + 4).
// The control MUST be per-tier: an A-zone may carry R:R 6 while a C-zone carries R:R 1.2, and the
// hit rate of a trade depends on its R:R. Pooling every tier's control into one bucket would give
// Tier A a yardstick built mostly from other tiers' geometry — which is not a matched control at all.
var array<int>   tW  = array.from(0, 0, 0, 0, 0, 0, 0, 0)
var array<int>   tN  = array.from(0, 0, 0, 0, 0, 0, 0, 0)
var array<float> tR  = array.from(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)   // SUM of R → expectancy
var array<float> tR2 = array.from(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)   // SUM of R² → variance → t

var int   lastSweepBar = -1000
var int   lastSweepDir = 0
var float pocPx = na
var float vahPx = na
var float valPx = na

// ═════════════════════════════════════════════════════════════════════════════════════════
//        A · ROLLING VOLUME PROFILE  →  POC, value area, and NAKED POCs
//   Bar volume is spread uniformly across the bins its range covers. That is an APPROXIMATION of a
//   true tick profile — stated plainly — but it is stable, fast, and enough to locate value.
//   Rebuilt every vpEvery bars because the profile moves slowly.
// ═════════════════════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed and useVP and hasVol and bar_index > vpLook and bar_index % vpEvery == 0
    float hiB = ta.highest(high, vpLook)
    float loB = ta.lowest(low, vpLook)
    float rng = hiB - loB
    if rng > 0
        array<float> bins = array.new<float>(vpBins, 0.0)
        float bw = rng / vpBins
        for k = 0 to vpLook - 1
            float bv = nz(volume[k])
            int i0 = math.max(0, math.min(vpBins - 1, int((low[k] - loB) / bw)))
            int i1 = math.max(0, math.min(vpBins - 1, int((high[k] - loB) / bw)))
            float share = bv / (i1 - i0 + 1)
            for b = i0 to i1
                array.set(bins, b, array.get(bins, b) + share)
        int   pocI = 0
        float pocV = -1.0
        for b = 0 to vpBins - 1
            if array.get(bins, b) > pocV
                pocV := array.get(bins, b)
                pocI := b
        float newPoc = loB + (pocI + 0.5) * bw
        // value area: expand outward from the POC until vpVA% of the volume is enclosed
        float total = array.sum(bins)
        float acc = pocV
        int   uI  = pocI
        int   dI  = pocI
        while acc < total * vpVA / 100.0 and (uI < vpBins - 1 or dI > 0)
            float upV = uI < vpBins - 1 ? array.get(bins, uI + 1) : -1.0
            float dnV = dI > 0 ? array.get(bins, dI - 1) : -1.0
            if upV >= dnV and uI < vpBins - 1
                uI += 1
                acc += upV
            else if dI > 0
                dI -= 1
                acc += dnV
            else
                break
        vahPx := loB + (uI + 1) * bw
        valPx := loB + dI * bw
        // when the POC MOVES, the one it left behind becomes a naked-POC candidate
        if not na(pocPx) and math.abs(newPoc - pocPx) > bw and maxNPOC > 0
            array.push(npocs, NPoc.new(pocPx, bar_index, false, na, na))
            while array.size(npocs) > maxNPOC
                NPoc old = array.shift(npocs)
                line.delete(old.ln)
                label.delete(old.lb)
        pocPx := newPoc

// a naked POC stops being naked the moment price trades back through it
if barstate.isconfirmed and array.size(npocs) > 0
    for i = 0 to array.size(npocs) - 1
        NPoc np = array.get(npocs, i)
        if not np.tested and low <= np.px and high >= np.px and bar_index > np.bi
            np.tested := true

bool inValue = not na(vahPx) and not na(valPx) and close <= vahPx and close >= valPx

// ═════════════════════════════════════════════════════════════════════════════════════════
//        B · PREMIUM / DISCOUNT  (the dealing range and its equilibrium)
// ═════════════════════════════════════════════════════════════════════════════════════════
float drHi = ta.highest(high, drLook)
float drLo = ta.lowest(low, drLook)
float eqPx = (drHi + drLo) / 2.0
int   pdSide = not usePD or na(eqPx) ? 0 : close > eqPx ? 1 : -1      // +1 premium · -1 discount

// ═════════════════════════════════════════════════════════════════════════════════════════
//        C · ORDER FLOW  —  was the displacement REAL, and is anyone defending the zone?
//   Structure tells you WHERE. Order flow tells you WHETHER ANYONE SHOWED UP.
//   • DELTA is built from the LOWER timeframe: each intrabar's volume is signed by its own
//     direction, then summed. That is aggressor flow, not a guess. Where intrabar data is not
//     available the script falls back to the close-location proxy AND SAYS SO — it does not
//     silently pass off an approximation as the real thing.
//   • ABSORPTION is the tell on the retest: heavy volume, small range, price holding inside the
//     zone. Someone is soaking up the aggression. That is a defended zone.
//   • CVD DIVERGENCE at the zone: price makes a lower low while cumulative delta makes a higher
//     low — sellers pressing with no result.
// ═════════════════════════════════════════════════════════════════════════════════════════
bool ofOn = ofMode != "Off" and hasVol

// close-location proxy: where in the bar's range did it close? (-1 .. +1) × volume
float clvProxy = (high - low) > 0 ? vol0 * (2.0 * (close - low) / (high - low) - 1.0) : 0.0

// true intrabar delta
// AUTO intrabar timeframe: roughly one-fifth of the chart's, and never equal to it.
// If the intrabar TF equals the chart TF there is exactly ONE intrabar — the bar itself — and delta
// collapses to +/-100% on every bar. That is not order flow, it is a tautology, and it silently
// poisons the score. This is why the mapping exists.
f_autoLtf() =>
    int cs = timeframe.in_seconds()
    cs <= 60    ? "5S"  :
       cs <= 180   ? "15S" :
       cs <= 300   ? "30S" :
       cs <= 900   ? "1"   :
       cs <= 3600  ? "5"   :
       cs <= 14400 ? "15"  :
       cs <= 86400 ? "60"  : "240"
string ofLtf = ofLtfMode == "Auto" ? f_autoLtf() : ofLtfMan
// degeneracy guard: the intrabar TF must be STRICTLY below the chart TF
bool ltfValid = timeframe.in_seconds(ofLtf) < timeframe.in_seconds()

float ltfDelta = na
bool  ltfOK = false
if ofOn and ofMode == "Intrabar delta (true)" and ltfValid
    [ltfC, ltfO, ltfV] = request.security_lower_tf(syminfo.tickerid, ofLtf, [close, open, volume])
    if array.size(ltfC) > 1        // >1: a single intrabar IS the bar — that is not order flow
        float d = 0.0
        for i = 0 to array.size(ltfC) - 1
            float c = array.get(ltfC, i)
            float o = array.get(ltfO, i)
            float v = nz(array.get(ltfV, i))
            d += c > o ? v : c < o ? -v : 0.0
        ltfDelta := d
        ltfOK := true

float barDelta = not ofOn ? 0.0 : ltfOK ? ltfDelta : clvProxy
string ofSrc   = not ofOn ? "off" : ltfOK ? "intrabar " + ofLtf : (not ltfValid ? "proxy (intrabar TF too high)" : "proxy (no intrabar data)")

// normalised delta: what share of this bar's volume was net-aggressive, and which way? (-1..+1)
float deltaPct = (ofOn and vol0 > 0) ? math.max(-1.0, math.min(1.0, barDelta / vol0)) : 0.0
float cvd = ta.cum(barDelta)
float deltaSm = ta.ema(deltaPct, 10)      // the raw per-bar delta is too jumpy to read; smooth it

// ABSORPTION — heavy volume, small range: the signature of a defended level.
// Evaluated on CONFIRMED bars only. On a live bar the range is small simply because the bar has not
// finished forming, so an ungated test reads "absorbing" almost every bar — which is worse than
// useless, it is confidently wrong.
var bool absorbBar = false
if barstate.isconfirmed
    absorbBar := ofOn and rvol >= absorbRV and (high - low) <= absorbRg * atr

// CVD divergence over the lookback (price low vs delta low, and the mirror)
// ta.lowest / ta.highest are STATEFUL - they must run on EVERY bar. Pine's `and`
// short-circuits, so the CVD extremes were skipped on any bar where the price
// comparison failed, leaving their rolling windows computed over a broken
// history and making the divergence test unreliable. Hoist, then combine.
float loPx  = ta.lowest(low,  cvdLen)
float hiPx  = ta.highest(high, cvdLen)
float loCvd = ta.lowest(cvd,  cvdLen)
float hiCvd = ta.highest(cvd, cvdLen)
bool cvdBullDiv = ofOn and low  <= loPx and cvd > loCvd
bool cvdBearDiv = ofOn and high >= hiPx and cvd < hiCvd

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          1 · LIQUIDITY POOLS  (cluster the swings)
// ═════════════════════════════════════════════════════════════════════════════════════════
f_addPool(array<Pool> arr, float px, int side, float tol, int cap) =>
    int hit = -1
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            Pool p = array.get(arr, i)
            if math.abs(p.px - px) <= tol
                hit := i
                break
    if hit >= 0
        Pool p = array.get(arr, hit)
        p.hits += 1
        p.px := (p.px * (p.hits - 1) + px) / p.hits    // running mean of the cluster
        p.bi := bar_index
    else
        array.push(arr, Pool.new(px, bar_index, side, 1, false, na, na))
    while array.size(arr) > cap
        Pool old = array.shift(arr)
        line.delete(old.ln)
        label.delete(old.lb)

if barstate.isconfirmed
    if not na(ph)
        f_addPool(poolsHi, ph, 1, eqTolA * atr, maxPools)
    if not na(pl)
        f_addPool(poolsLo, pl, -1, eqTolA * atr, maxPools)

// ═════════════════════════════════════════════════════════════════════════════════════════
//              2 · THE SWEEP  (wick through the pool, close back inside)
// ═════════════════════════════════════════════════════════════════════════════════════════
bool sweptHi = false
bool sweptLo = false

if barstate.isconfirmed
    if array.size(poolsHi) > 0
        for i = 0 to array.size(poolsHi) - 1
            Pool p = array.get(poolsHi, i)
            if not p.swept and bar_index > p.bi and high > p.px and (not needClose or close < p.px)
                p.swept := true
                sweptHi := true
    if array.size(poolsLo) > 0
        for i = 0 to array.size(poolsLo) - 1
            Pool p = array.get(poolsLo, i)
            if not p.swept and bar_index > p.bi and low < p.px and (not needClose or close > p.px)
                p.swept := true
                sweptLo := true
    // a swept HIGH is buy-side liquidity taken → the reversal that follows is BEARISH, and vice versa
    if sweptHi or sweptLo
        lastSweepBar := bar_index
        lastSweepDir := sweptHi ? -1 : 1

// ═════════════════════════════════════════════════════════════════════════════════════════
//        3 · DISPLACEMENT  (the impulsive move that reveals the reversal)
// ═════════════════════════════════════════════════════════════════════════════════════════
float body   = math.abs(close - open)
float dispZ  = atr > 0 ? body / atr : 0.0
bool  dispUp = close > open and dispZ >= dispMin
bool  dispDn = close < open and dispZ >= dispMin
bool  sweepFresh = (bar_index - lastSweepBar) <= sweepBars
bool  bornUp = dispUp and sweepFresh and lastSweepDir == 1
bool  bornDn = dispDn and sweepFresh and lastSweepDir == -1

// ═════════════════════════════════════════════════════════════════════════════════════════
//                4 · ZONES  —  scored on STRUCTURE and on LOCATION
// ═════════════════════════════════════════════════════════════════════════════════════════
// does the zone overlap value, the POC, or an untested POC? (auction-theory location)
f_vpBonus(float top, float bot) =>
    float b = 0.5                                    // no volume → neutralise, do not penalise
    if useVP and hasVol
        bool atPoc = not na(pocPx) and pocPx >= bot and pocPx <= top
        bool atVA  = not na(vahPx) and not na(valPx) and top >= valPx and bot <= vahPx
        bool atNP  = false
        if array.size(npocs) > 0
            for i = 0 to array.size(npocs) - 1
                NPoc np = array.get(npocs, i)
                if not np.tested and np.px >= bot and np.px <= top
                    atNP := true
        b := atPoc or atNP ? 1.0 : atVA ? 0.6 : 0.0
    b

f_score(float dz, float rv, bool sw, float gapA, int dir, float top, float bot) =>
    float sDisp = math.min(1.0, dz / (dispMin * 2.0)) * wDisp
    float sRvol = hasVol ? math.min(1.0, math.max(0.0, rv - 1.0)) * wRvol : wRvol * 0.5
    float sSwp  = sw ? wSweep : 0.0
    float sGap  = math.min(1.0, gapA / 0.5) * wGap
    float sHtf  = htfBias == dir ? wHTF : 0.0
    // a BULLISH zone earns its premium/discount points in DISCOUNT; a bearish zone in PREMIUM
    float sPd   = (not usePD or pdSide == 0) ? wPD * 0.5 : ((dir == 1 and pdSide == -1) or (dir == -1 and pdSide == 1)) ? wPD : 0.0
    float sVp   = f_vpBonus(top, bot) * wVP
    // ORDER FLOW: was the displacement backed by aggressive flow in the zone's OWN direction?
    // A bullish zone born on negative delta is a vacuum, not a footprint — and scores nothing here.
    float sOf   = not ofOn ? wOF * 0.5 : math.max(0.0, deltaPct * dir) * wOF
    float tot   = sDisp + sRvol + sSwp + sGap + sHtf + sPd + sVp + sOf
    float maxT  = wDisp + wRvol + wSweep + wGap + wHTF + wPD + wVP + wOF
    maxT > 0 ? math.min(100.0, tot / maxT * 100.0) : 0.0

f_tier(float s) => s >= tierA ? 3 : s >= tierB ? 2 : 1
f_tierTxt(int t) => t == 3 ? "A" : t == 2 ? "B" : "C"
f_tierCol(int t, int dir) => color.new(dir == 1 ? colBull : colBear, t == 3 ? 62 : t == 2 ? 76 : 88)

f_pushZone(float top, float bot, int dir, float score, bool isFVG, bool fromSweep, bool conf, bool atVal) =>
    array.push(zones, Zone.new(top, bot, bar_index, dir, score, isFVG, fromSweep, conf, atVal, false, false, na, na))
    while array.size(zones) > maxZones
        Zone old = array.shift(zones)
        box.delete(old.bx)
        label.delete(old.lb)

if barstate.isconfirmed and bar_index > pivLen + 3
    float gapUpT = low
    float gapUpB = high[2]
    float gapDnT = low[2]
    float gapDnB = high
    bool  fvgUp  = useFVG and gapUpB < gapUpT and (gapUpT - gapUpB) >= minGapA * atr and dispUp
    bool  fvgDn  = useFVG and gapDnB < gapDnT and (gapDnT - gapDnB) >= minGapA * atr and dispDn

    bool  obUp = useOB and dispUp and close[1] < open[1]
    bool  obDn = useOB and dispDn and close[1] > open[1]
    float obT  = high[1]
    float obB  = low[1]

    bool confUp = fvgUp and obUp and gapUpB >= obB and gapUpT <= obT
    bool confDn = fvgDn and obDn and gapDnB >= obB and gapDnT <= obT

    if fvgUp
        float gA = atr > 0 ? (gapUpT - gapUpB) / atr : 0.0
        f_pushZone(gapUpT, gapUpB, 1, f_score(dispZ, rvol, bornUp, gA, 1, gapUpT, gapUpB), true, bornUp, confUp, f_vpBonus(gapUpT, gapUpB) >= 0.6)
    if fvgDn
        float gA = atr > 0 ? (gapDnT - gapDnB) / atr : 0.0
        f_pushZone(gapDnT, gapDnB, -1, f_score(dispZ, rvol, bornDn, gA, -1, gapDnT, gapDnB), true, bornDn, confDn, f_vpBonus(gapDnT, gapDnB) >= 0.6)
    if obUp and not confUp
        f_pushZone(obT, obB, 1, f_score(dispZ, rvol, bornUp, 0.0, 1, obT, obB), false, bornUp, false, f_vpBonus(obT, obB) >= 0.6)
    if obDn and not confDn
        f_pushZone(obT, obB, -1, f_score(dispZ, rvol, bornDn, 0.0, -1, obT, obB), false, bornDn, false, f_vpBonus(obT, obB) >= 0.6)

// ═════════════════════════════════════════════════════════════════════════════════════════
//     5 · MITIGATION + ENTRY FRAMING  (wait for the retrace; never chase)
// ═════════════════════════════════════════════════════════════════════════════════════════
var float eEntry = na
var float eStop  = na
var float eTgt   = na
var int   eDir   = 0
var float eScore = na
var int   eTier  = 0
var float eRR    = na
var int   eBar   = -1000

f_nextPool(int dir, float from) =>
    float best = na
    if dir == 1
        if array.size(poolsHi) > 0
            for i = 0 to array.size(poolsHi) - 1
                Pool p = array.get(poolsHi, i)
                if not p.swept and p.px > from and (na(best) or p.px < best)
                    best := p.px
    else
        if array.size(poolsLo) > 0
            for i = 0 to array.size(poolsLo) - 1
                Pool p = array.get(poolsLo, i)
                if not p.swept and p.px < from and (na(best) or p.px > best)
                    best := p.px
    best

f_nearNPOC(int dir, float from) =>
    float best = na
    if array.size(npocs) > 0
        for i = 0 to array.size(npocs) - 1
            NPoc np = array.get(npocs, i)
            if not np.tested
                if dir == 1 and np.px > from and (na(best) or np.px < best)
                    best := np.px
                if dir == -1 and np.px < from and (na(best) or np.px > best)
                    best := np.px
    best

bool armedNow = false
bool inAnyZone = false          // is price actually sitting in a live zone right now?
if barstate.isconfirmed and array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        Zone z = array.get(zones, i)
        if not z.spent
            if low <= z.top and high >= z.bot
                inAnyZone := true
            bool through = mitigMode == "Close through" ? (z.dir == 1 ? close < z.bot : close > z.top) : (z.dir == 1 ? low < z.bot : high > z.top)
            bool touched = low <= z.top and high >= z.bot
            if through
                z.spent := true
            else if touched and not z.armed and z.score >= minEntry and bar_index > z.bi
                z.armed := true
                float en = z.dir == 1 ? z.top : z.bot
                float st = z.dir == 1 ? z.bot - stopBufA * atr : z.top + stopBufA * atr
                float risk = math.abs(en - st)
                float lp = tgtMode == "Naked POC" ? f_nearNPOC(z.dir, en) : f_nextPool(z.dir, en)
                float tgRaw = (not na(lp) and tgtMode != "Fixed R multiple") ? lp : (z.dir == 1 ? en + rrFixed * risk : en - rrFixed * risk)
                float rrRaw = risk > 0 ? math.abs(tgRaw - en) / risk : na
                // Cap the R:R. A pool 10R away produces a beautiful number that almost never fills —
                // and, worse, makes the hit rate incomparable with any control.
                float rr = na(rrRaw) ? na : math.min(rrRaw, maxRR)
                float tg = na(rr) ? na : (z.dir == 1 ? en + rr * risk : en - rr * risk)
                if not na(rr) and rr >= minRR
                    eEntry := en
                    eStop  := st
                    eTgt   := tg
                    eDir   := z.dir
                    eScore := z.score
                    eTier  := f_tier(z.score)
                    eRR    := rr
                    eBar   := bar_index
                    armedNow := true
                    if calibOn
                        array.push(pend, Trade.new(bar_index, en, st, tg, z.dir, f_tier(z.score), rr))
                        // ── THE MATCHED CONTROL ──
                        // Same bar, same direction, SAME R:R — but entered at market with an ATR stop
                        // instead of at the zone. It isolates exactly one variable: does entering AT
                        // THE ZONE beat entering anywhere else on identical geometry? Under a random
                        // walk this control has ZERO expectancy, so anything the zones earn is real.
                        float cRisk = atr
                        float cEn   = close
                        float cSt   = z.dir == 1 ? cEn - cRisk : cEn + cRisk
                        float cTg   = z.dir == 1 ? cEn + rr * cRisk : cEn - rr * cRisk
                        array.push(pend, Trade.new(bar_index, cEn, cSt, cTg, z.dir, f_tier(z.score) + 4, rr))

// ═════════════════════════════════════════════════════════════════════════════════════════
//   6 · CALIBRATION  —  triple-barrier grading, and the base rate that keeps it honest
// ═════════════════════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed and array.size(pend) > 0
    int i = 0
    while i < array.size(pend)
        Trade t = array.get(pend, i)
        bool hitT = t.dir == 1 ? high >= t.tgt : low  <= t.tgt
        bool hitS = t.dir == 1 ? low  <= t.stop : high >= t.stop
        bool expd = bar_index - t.bi >= calHor
        if bar_index > t.bi and (hitT or hitS or expd)
            // both barriers touched on the same bar → the STOP is assumed first. The conservative
            // assumption, and the only one that cannot flatter the result.
            int   win = hitS ? 0 : hitT ? 1 : 0
            float risk = math.abs(t.entry - t.stop)
            // R outcome: +rr on target, -1 on stop, and marked-to-market if the horizon expires —
            // an expired trade is neither a win nor a loss, and pretending otherwise would lie.
            float rOut = hitS ? -1.0 : hitT ? t.rr : (risk > 0 ? (close - t.entry) * t.dir / risk : 0.0)
            array.set(tN, t.tier, array.get(tN, t.tier) + 1)
            array.set(tW, t.tier, array.get(tW, t.tier) + win)
            array.set(tR, t.tier, array.get(tR, t.tier) + rOut)
            array.set(tR2, t.tier, array.get(tR2, t.tier) + rOut * rOut)
            array.remove(pend, i)
        else
            i += 1

f_hit(int ix) =>
    int n = array.get(tN, ix)
    n > 0 ? array.get(tW, ix) / float(n) * 100.0 : na
// EXPECTANCY in R. This is the number that matters: when the R:R varies from trade to trade, a hit
// rate on its own is meaningless. A 6R winner at 20% is +0.4R — excellent. A 1R winner at 55% is
// +0.1R — barely worth the commission.
f_exp(int ix) =>
    int n = array.get(tN, ix)
    n > 0 ? array.get(tR, ix) / float(n) : na

// SD of the R outcomes per tier — needed to say whether a difference in expectancy is REAL or noise.
f_sd(int ix) =>
    int n = array.get(tN, ix)
    if n < 2
        na
    else
        float m = array.get(tR, ix) / n
        float v = array.get(tR2, ix) / n - m * m
        math.sqrt(math.max(v, 0.0))

// Welch's t: is Tier-A expectancy genuinely above the matched control, or is this just a small sample?
// This is the number that decides whether the tool says "proven" — and it is deliberately hard to pass.
f_tstat(int ixA, int ixB) =>
    int nA = array.get(tN, ixA)
    int nB = array.get(tN, ixB)
    float sA = f_sd(ixA)
    float sB = f_sd(ixB)
    if nA < 2 or nB < 2 or na(sA) or na(sB)
        na
    else
        float se = math.sqrt(sA * sA / nA + sB * sB / nB)
        se <= 0 ? na : (array.get(tR, ixA) / nA - array.get(tR, ixB) / nB) / se

float hitA = f_hit(3)
float hitB = f_hit(2)
float hitC = f_hit(1)
float expA = f_exp(3)
float expB = f_exp(2)
float expC = f_exp(1)
float ctlA = f_exp(7)      // the control matched to TIER A's own geometry
float ctlB = f_exp(6)
float ctlC = f_exp(5)
float hCtlA = f_hit(7)
float expBase = ctlA
float baseHit = hCtlA
float edgeExpA = (na(expA) or na(ctlA)) ? na : expA - ctlA
float edgeA = (na(hitA) or na(hCtlA)) ? na : hitA - hCtlA
float tA = f_tstat(3, 7)      // Tier A vs ITS OWN matched control
// "Proven" requires an adequate sample AND a t-statistic clearing 1.96 — i.e. the expectancy gap is
// unlikely to be luck. Anything less honestly reads "not proven".
bool  provenA = not na(tA) and array.get(tN, 3) >= calMinN and tA > 1.96

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                   PLOTS  (price layer)
// ═════════════════════════════════════════════════════════════════════════════════════════
pEQ  = plot(showEQ and usePD ? eqPx : na, "Equilibrium", color.new(colVP, 20), lineW, style = plot.style_linebr)
pDRH = plot(shadePD and usePD ? drHi : na, "Dealing range high", color.new(colBear, 80), 1, style = plot.style_linebr)
pDRL = plot(shadePD and usePD ? drLo : na, "Dealing range low",  color.new(colBull, 80), 1, style = plot.style_linebr)
fill(pDRH, pEQ, color.new(colBear, 94), title = "Premium (sell zone)")
fill(pEQ, pDRL, color.new(colBull, 94), title = "Discount (buy zone)")

pPOC = plot(showVP and useVP ? pocPx : na, "POC", color.new(colVP, 0),  lineW + 1, style = plot.style_linebr)
pVAH = plot(showVP and useVP ? vahPx : na, "VAH", color.new(colVP, 55), 1, style = plot.style_linebr)
pVAL = plot(showVP and useVP ? valPx : na, "VAL", color.new(colVP, 55), 1, style = plot.style_linebr)
fill(pVAH, pVAL, color.new(colVP, 95), title = "Value area")

plotshape(showSweep and sweptHi, "Sweep (buy-side taken)",  shape.triangledown, location.abovebar, color.new(colLiq, 0), text = "SWEEP", textcolor = color.white, size = size.tiny)
plotshape(showSweep and sweptLo, "Sweep (sell-side taken)", shape.triangleup,   location.belowbar, color.new(colLiq, 0), text = "SWEEP", textcolor = color.white, size = size.tiny)
plotshape(showOF and absorbBar and inAnyZone, "Absorption at a zone", shape.square, location.belowbar, color.new(#ffa726, 0), size = size.tiny)
plotchar(showOF and cvdBullDiv, "CVD bull divergence", "▲", location.belowbar, colBull, size = size.tiny)
plotchar(showOF and cvdBearDiv, "CVD bear divergence", "▼", location.abovebar, colBear, size = size.tiny)

bool setupLive = showSetup and not na(eEntry) and (bar_index - eBar) < 200
plot(setupLive ? eEntry : na, "Entry",  color.new(color.gray, 0),                    lineW, style = plot.style_linebr)
plot(setupLive ? eStop  : na, "Stop",   color.new(eDir == 1 ? colBear : colBull, 0), lineW, style = plot.style_linebr)
plot(setupLive ? eTgt   : na, "Target", color.new(eDir == 1 ? colBull : colBear, 0), lineW, style = plot.style_linebr)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                     DRAWING  (objects — redrawn on the last bar)
// ═════════════════════════════════════════════════════════════════════════════════════════
var label lE   = na
var label lS   = na
var label lT   = na
var label lPOC = na

if barstate.islast
    if array.size(poolsHi) > 0
        for i = 0 to array.size(poolsHi) - 1
            Pool p = array.get(poolsHi, i)
            line.delete(p.ln)
            label.delete(p.lb)
            if showPools and not p.swept
                p.ln := line.new(p.bi, p.px, bar_index + poolExt, p.px, xloc = xloc.bar_index, color = color.new(colLiq, 25), width = lineW, style = line.style_dashed)
                if showLbl and lblPool
                    p.lb := label.new(bar_index + poolExt, p.px, "BSL " + str.tostring(p.hits) + "x  " + str.tostring(p.px, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(colLiq, 20), textcolor = color.white, size = f_lblSize())
    if array.size(poolsLo) > 0
        for i = 0 to array.size(poolsLo) - 1
            Pool p = array.get(poolsLo, i)
            line.delete(p.ln)
            label.delete(p.lb)
            if showPools and not p.swept
                p.ln := line.new(p.bi, p.px, bar_index + poolExt, p.px, xloc = xloc.bar_index, color = color.new(colLiq, 25), width = lineW, style = line.style_dashed)
                if showLbl and lblPool
                    p.lb := label.new(bar_index + poolExt, p.px, "SSL " + str.tostring(p.hits) + "x  " + str.tostring(p.px, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(colLiq, 20), textcolor = color.white, size = f_lblSize())

    if array.size(npocs) > 0
        for i = 0 to array.size(npocs) - 1
            NPoc np = array.get(npocs, i)
            line.delete(np.ln)
            label.delete(np.lb)
            if showNPOC and useVP and not np.tested
                np.ln := line.new(np.bi, np.px, bar_index + poolExt, np.px, xloc = xloc.bar_index, color = color.new(colVP, 35), width = 1, style = line.style_dotted)
                if showLbl and lblVP
                    np.lb := label.new(bar_index + poolExt, np.px, "nPOC  " + str.tostring(np.px, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(colVP, 30), textcolor = color.white, size = f_lblSize())

    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            Zone z = array.get(zones, i)
            box.delete(z.bx)
            label.delete(z.lb)
            if showZones and (showMitig or not z.spent)
                int tt = f_tier(z.score)
                z.bx := box.new(z.bi, z.top, bar_index + 10, z.bot, xloc = xloc.bar_index, bgcolor = z.spent ? color.new(color.gray, 92) : f_tierCol(tt, z.dir), border_color = color.new(z.dir == 1 ? colBull : colBear, z.spent ? 80 : 35), border_width = 1)
                if showLbl and lblZone and not z.spent
                    string tag = f_tierTxt(tt) + " " + str.tostring(z.score, "#") + (z.confluence ? " *" : "") + (z.fromSweep ? " ⚡" : "") + (z.atValue ? " ◆" : "") + "  " + (z.isFVG ? "FVG" : "OB")
                    z.lb := label.new(bar_index + 10, z.dir == 1 ? z.top : z.bot, tag, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(z.dir == 1 ? colBull : colBear, 20), textcolor = color.white, size = f_lblSize())

    label.delete(lE)
    label.delete(lS)
    label.delete(lT)
    label.delete(lPOC)
    if setupLive and showLbl and lblSetup
        lE := label.new(bar_index + 3, eEntry, "ENTRY  " + str.tostring(eEntry, format.mintick) + "   " + f_tierTxt(eTier) + " " + str.tostring(eScore, "#"), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.gray, 10), textcolor = color.white, size = f_lblSize())
        lS := label.new(bar_index + 3, eStop,  "STOP  " + str.tostring(eStop, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(eDir == 1 ? colBear : colBull, 10), textcolor = color.white, size = f_lblSize())
        lT := label.new(bar_index + 3, eTgt,   "TARGET  " + str.tostring(eTgt, format.mintick) + "   R:R " + str.tostring(eRR, "#.##"), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(eDir == 1 ? colBull : colBear, 10), textcolor = color.white, size = f_lblSize())
    if showVP and useVP and showLbl and lblVP and not na(pocPx)
        lPOC := label.new(bar_index + 3, pocPx, "POC  " + str.tostring(pocPx, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(colVP, 10), textcolor = color.white, size = f_lblSize())

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════════════════
bool isPro = panelMode == "Pro"
var table tb = table.new(f_pos(panelPos), 3, 15, frame_width = 1, border_width = 1)
f_row2(int r, string k, string v, color c, color bg) =>
    table.cell(tb, 0, r, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left, bgcolor = bg)
    table.cell(tb, 1, r, v, text_color = c, text_size = size.small, text_halign = text.align_right, bgcolor = bg)
    table.cell(tb, 2, r, "", bgcolor = bg)
f_row3(int r, string k, string a, string b, color c, color bg) =>
    table.cell(tb, 0, r, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left, bgcolor = bg)
    table.cell(tb, 1, r, a, text_color = c, text_size = size.small, text_halign = text.align_right, bgcolor = bg)
    table.cell(tb, 2, r, b, text_color = c, text_size = size.small, text_halign = text.align_right, bgcolor = bg)

if showPanel and barstate.islast
    table.set_bgcolor(tb, panelBg)
    table.set_frame_color(tb, frameC)
    table.set_border_color(tb, frameC)
    color hdrC = htfBias == 1 ? colBull : htfBias == -1 ? colBear : color.new(color.gray, 20)
    color hdrT = f_lum(hdrC) > 140 ? color.rgb(10, 10, 10) : color.white
    int nA = array.get(tN, 3)
    string edgeStr = not calibOn ? "off" : nA < calMinN ? "warming (" + str.tostring(nA) + "/" + str.tostring(calMinN) + ")" : (na(edgeExpA) ? "-" : str.tostring(expA, "+#.00") + "R vs " + str.tostring(expBase, "+#.00") + "R  n=" + str.tostring(nA) + (provenA ? "  PROVEN" : "  (not proven)"))
    color edgeCol = (not calibOn or nA < calMinN) ? txtMut : provenA ? colBull : color.new(#ffa726, 0)
    string ofTxt = not ofOn ? "off" : str.tostring(deltaSm * 100, "+#") + "%  (" + ofSrc + ")"
    color  ofCol = not ofOn ? txtMut : deltaSm > 0.15 ? colBull : deltaSm < -0.15 ? colBear : txtMut
    // "At the zone" must MEAN at the zone — absorption anywhere else is not a zone signal.
    string absTxt = not ofOn ? "-" : not inAnyZone ? "price not in a zone" : absorbBar ? "ABSORBING (defended)" : cvdBullDiv ? "CVD bull divergence" : cvdBearDiv ? "CVD bear divergence" : "in zone · no absorption"
    color  absCol = not inAnyZone ? txtMut : absorbBar ? color.new(#ffa726, 0) : cvdBullDiv ? colBull : cvdBearDiv ? colBear : txtMain
    string setTxt = setupLive ? (eDir == 1 ? "LONG " : "SHORT ") + f_tierTxt(eTier) + " " + str.tostring(eScore, "#") + "  R:R " + str.tostring(eRR, "#.##") : "none armed"
    color  setCol = setupLive ? (eDir == 1 ? colBull : colBear) : txtMut
    string pdTxt = not usePD ? "off" : pdSide == 1 ? "PREMIUM (sell zone)" : pdSide == -1 ? "DISCOUNT (buy zone)" : "-"
    color  pdCol = pdSide == 1 ? colBear : pdSide == -1 ? colBull : txtMut

    table.cell(tb, 0, 0, "LIQUIDITY ENGINE", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 0, htfBias == 1 ? "BULLISH" : htfBias == -1 ? "BEARISH" : "NEUTRAL", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 2, 0, htfTf, text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_right)
    if isPro
        f_row2(1, "Live setup", setTxt, setCol, rowAlt)
        f_row2(2, "Order flow (delta)", ofTxt, ofCol, panelBg)
        f_row2(3, "At the zone", absTxt, absCol, rowAlt)
        f_row2(4, "Premium / discount", pdTxt, pdCol, panelBg)
        f_row2(5, "Price vs value", (not useVP or not hasVol) ? "no volume" : inValue ? "INSIDE value" : "outside value", (useVP and hasVol and inValue) ? colBull : txtMut, rowAlt)
        f_row2(6, "POC / naked POCs", (na(pocPx) ? "-" : str.tostring(pocPx, format.mintick)) + "  /  " + str.tostring(array.size(npocs)), txtMain, panelBg)
        f_row2(7, "Pools above / below", str.tostring(array.size(poolsHi)) + " / " + str.tostring(array.size(poolsLo)), txtMain, rowAlt)
        table.cell(tb, 0, 8, "CALIBRATION", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_left)
        table.cell(tb, 1, 8, "zone (R)", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_right)
        table.cell(tb, 2, 8, "its control · n", text_color = txtMain, bgcolor = frameC, text_size = size.small, text_halign = text.align_right)
        f_row3(9,  "Tier A (>=" + str.tostring(tierA) + ")", na(expA) ? "-" : str.tostring(expA, "+#.00") + "R", (na(ctlA) ? "-" : str.tostring(ctlA, "+#.00") + "R · " + str.tostring(array.get(tN, 3))), (not na(expA) and not na(ctlA) and expA > ctlA) ? colBull : colBear, rowAlt)
        f_row3(10, "Tier B", na(expB) ? "-" : str.tostring(expB, "+#.00") + "R", (na(ctlB) ? "-" : str.tostring(ctlB, "+#.00") + "R · " + str.tostring(array.get(tN, 2))), (not na(expB) and not na(ctlB) and expB > ctlB) ? colBull : txtMain, panelBg)
        f_row3(11, "Tier C", na(expC) ? "-" : str.tostring(expC, "+#.00") + "R", (na(ctlC) ? "-" : str.tostring(ctlC, "+#.00") + "R · " + str.tostring(array.get(tN, 1))), (not na(expC) and not na(ctlC) and expC > ctlC) ? colBull : txtMut, rowAlt)
        f_row2(12, "Does A beat C?", (na(expA) or na(expC)) ? "-" : (expA > expC ? "yes — the score ranks" : "NO — the score does not rank"), (not na(expA) and not na(expC) and expA > expC) ? colBull : color.new(#ffa726, 0), panelBg)
        f_row2(13, "Significance (t)", na(tA) ? "-" : str.tostring(tA, "#.2") + (provenA ? "  > 1.96 PROVEN" : "  (needs > 1.96)"), provenA ? colBull : txtMut, rowAlt)
        f_row2(14, "Note", "expectancy in R · in-sample · not advice", txtMut, panelBg)
    else
        f_row2(1, "Live setup", setTxt, setCol, rowAlt)
        f_row2(2, "Order flow (delta)", ofTxt, ofCol, panelBg)
        f_row2(3, "At the zone", absTxt, absCol, rowAlt)
        f_row2(4, "Premium / discount", pdTxt, pdCol, panelBg)
        f_row2(5, "Tier-A expectancy", edgeStr, edgeCol, rowAlt)
        f_row2(6, "Note", "in-sample · not advice", txtMut, panelBg)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       LEGEND / KEY
// ═════════════════════════════════════════════════════════════════════════════════════════
var table lg = table.new(f_pos(legendPos), 2, 11, frame_width = 1, border_width = 1)
f_lg(int r, string sw, color c, string txt) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(lg, 0, r, sw,  text_color = c,      bgcolor = bg, text_size = size.tiny, text_halign = text.align_center)
    table.cell(lg, 1, r, txt, text_color = txtSub, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
if showLegend and barstate.islast
    table.set_bgcolor(lg, panelBg)
    table.set_frame_color(lg, frameC)
    table.set_border_color(lg, frameC)
    table.cell(lg, 0, 0, "KEY", text_color = txtMain, bgcolor = frameC, text_size = size.tiny)
    table.cell(lg, 1, 0, "what you're looking at", text_color = txtMain, bgcolor = frameC, text_size = size.tiny, text_halign = text.align_left)
    f_lg(1, "- -",  colLiq,  "BSL / SSL — pools of stops. n x = swings clustered there")
    f_lg(2, "▲▼",   colLiq,  "SWEEP — the wick took the stops, the close came back")
    f_lg(3, "▭",    colBull, "Zone — brighter = higher score. FVG or OB")
    f_lg(4, "A",    colBull, "Tier A >=" + str.tostring(tierA) + " · B >=" + str.tostring(tierB) + " · C below")
    f_lg(5, "* ⚡ ◆", colBull, "* FVG-in-OB · ⚡ born from a sweep · ◆ at value")
    f_lg(6, "━━",   colVP,   "POC + value area · nPOC = untested POC (a magnet)")
    f_lg(7, "▒",    colBear, "Premium (sell zone) above equilibrium · Discount below")
    f_lg(8, "━━",   txtMain, "Entry / Stop / Target — target = the NEXT pool of stops")
    f_lg(9, "▪",    color.new(#ffa726, 0), "Absorption — heavy volume, small range: a defended zone")
    f_lg(10, "R",   colBull, "Expectancy in R vs a MATCHED control (same bar, same R:R)")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                  EXPORTS  (Data Window — consume elsewhere via input.source())
// ═════════════════════════════════════════════════════════════════════════════════════════
color exC = color.new(color.gray, 100)
plot(htfBias,                        "EXP_Bias",        exC, display = display.data_window)
plot(sweptHi ? -1 : sweptLo ? 1 : 0, "EXP_Sweep",       exC, display = display.data_window)
plot(armedNow ? eDir : 0,            "EXP_ZoneDir",     exC, display = display.data_window)
plot(armedNow ? eScore : na,         "EXP_ZoneScore",   exC, display = display.data_window)
plot(setupLive ? 1 : 0,              "EXP_InZone",      exC, display = display.data_window)
plot(eEntry,                         "EXP_Entry",       exC, display = display.data_window)
plot(eStop,                          "EXP_Stop",        exC, display = display.data_window)
plot(eTgt,                           "EXP_Target",      exC, display = display.data_window)
plot(eRR,                            "EXP_RR",          exC, display = display.data_window)
plot(edgeA,                          "EXP_EdgeA",       exC, display = display.data_window)
plot(pocPx,                          "EXP_POC",         exC, display = display.data_window)
plot(eqPx,                           "EXP_Equilibrium", exC, display = display.data_window)
plot(pdSide,                         "EXP_PremDisc",    exC, display = display.data_window)
plot(deltaSm,                        "EXP_Delta",       exC, display = display.data_window)
plot(cvd,                            "EXP_CVD",         exC, display = display.data_window)
plot((absorbBar and inAnyZone) ? 1 : 0, "EXP_Absorption",  exC, display = display.data_window)
plot(expA,                           "EXP_ExpectancyA", exC, display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(sweptHi,  "Buy-side liquidity swept",  "Liquidity Engine: buy-side stops taken above a pool — watch for bearish displacement (context, not advice)")
alertcondition(sweptLo,  "Sell-side liquidity swept", "Liquidity Engine: sell-side stops taken below a pool — watch for bullish displacement (context, not advice)")
alertcondition(armedNow, "Entry armed", "Liquidity Engine: price retraced into a fresh zone — setup framed (context, not advice)")
alertcondition(absorbBar and inAnyZone, "Absorption at a zone", "SMC Engine: absorption at a live zone — heavy volume, small range, someone is defending it (context, not advice)")
````
