# Support & Resistance  Confluence Levels, Hold Record & Reversal

- url: https://www.tradingview.com/script/V3Sv11GD-Support-Resistance-Confluence-Levels-Hold-Record-Reversal/
- type: indicator
- pine_id: PUB;d48b595e0e2d45a6ba3a7d8c7ac3ffeb
- version: 2.0

## Description

OVERVIEW
 
Four lines. Two above price, two below. That is the whole chart.
 
Every other support/resistance tool has the opposite problem. It finds forty levels and leaves you to work out which two matter. Forty levels is not information, it is wallpaper — and a level you have to hunt for is a level you will not trade.
 
So this tool inverts the design. It does not ask "where are the levels?" It asks:
 
WHICH LEVEL WOULD I ACTUALLY TRADE, RIGHT NOW, AND WHY SHOULD I BELIEVE IT?
 
A price is only promoted to a level when SEVERAL INDEPENDENT METHODS AGREE ON IT. One method finding a level proves nothing — every method finds levels everywhere. The signal is AGREEMENT.
 
This is a research and framing tool. It is NOT a strategy, NOT a signal service, and NOT a validated edge.
 
 
THE SIX VOICES — four propose, two confirm
 
PROPOSERS. Each nominates candidate prices, independently:
 
  ◆ SWING PIVOT       the classic. Where price actually turned.
 
  ~ KERNEL EXTREMUM   the turning point of the SMOOTHED price (Nadaraya-Watson), which is the shape
                      rather than the noise. This is Lo, Mamaysky and Wang's method, and it finds
                      structurally different levels from a raw pivot. That independence is exactly
                      what makes agreement between the two worth something. Agreement between two
                      methods that make the same mistakes is worth nothing at all.
 
  ⇈ HIGHER TIMEFRAME  a swing on the HTF. The level a bigger participant is watching.
 
  ▣ PRIOR PERIOD      yesterday's high and low. Last week's high and low. The most watched prices on
                      any chart — and missing from almost every auto-S/R script on TradingView.
 
CONFIRMERS. They do not nominate, they vouch:
 
  ▪ VOLUME NODE       the level sits where volume actually transacted. Real business was done here,
                      not merely a turning point.
 
  ○ ROUND NUMBER      the psychological grid.
 
Candidates within an ATR tolerance merge, and the merged level inherits every voice that spoke for it. A level needs MIN VOICES to exist at all. Everything below that is DISCARDED, not hidden. Then only the nearest two above and two below are drawn.
 
The label tells you why the level is there: "◆~▣▪ 4v held 3/4 24,247.00" — four independent voices, tested four times, held three.
 
 
AND THEN THE PART NOBODY DOES: WE TEST WHETHER CONFLUENCE ACTUALLY RANKS
 
"Levels are stronger when several methods agree" is one of the most repeated claims in technical analysis and almost nobody has ever checked it. It is checkable. So the panel reports:
 
     High confluence (3+)    +0.24R   n=61    PROVEN
     Low confluence          -0.03R   n=88
     Control (unconditional) +0.02R   n=240
     DOES CONFLUENCE RANK?   YES — more voices IS better
 
And the control is DIRECTION-MATCHED. Reversals at support are overwhelmingly LONG on a drifting index — and a long-biased event set compared against a 50/50 control is handed the drift for free and calls it an edge. Longs are compared only with control longs, shorts only with control shorts, and the control is then blended back using the events' OWN direction mix. It is a subtle trap and it will manufacture an edge out of nothing if you let it.
 
And the verdict is a TEST, not a comparison. High confluence is measured against low confluence with a Welch t-test, and the difference must clear |t| > 1.96 before it is allowed to be a finding. Below that, the panel prints the least satisfying answer there is — NO DIFFERENCE — because that is the honest one. A tool that reports a 0.02R gap as a verdict is not measuring anything, it is decorating.
 
If the extra voices do not rank on your instrument, then on your instrument they do not rank, and no amount of agreement between methods will change that. That row is the reason this script exists.
 
 
THE HOLD RECORD — and why "held 3/4" is not what most scripts mean by it
 
A TEST IS AN EPISODE, NOT A BAR. Price arrives at the level and the test stays OPEN until price LEAVES it — back the way it came (HELD) or straight through (BROKE). A bar that closes INSIDE the zone has resolved nothing and is counted as nothing.
 
Counting every touching bar as a completed test drops an entire consolidation into the denominator as failures, and manufactures hold rates near 10% that say nothing about the level and everything about the counter. An unresolved test is neither a hold nor a break, exactly as an unresolved trade is neither a win nor a loss.
 
AND A TEST IS AN APPROACH, NOT A BAR TOUCHING A BOX. Price exits the zone (HELD), the next bar dips straight back in — and without a re-arm rule that counts as a brand-new test. Chop sitting on a level then logs a hundred "tests" that were really one event. Measured live before this was fixed: 224 tests of a single level on a 5m chart, and hold rates that all landed between 61% and 75% no matter which level you looked at. A statistic that cannot tell any two levels apart is not measuring the levels — it is measuring the bar size. Price must now travel clear of the zone before the level can be tested again. One approach, one test.
 
The volume filter gates the SIGNAL and never the RECORD. A level that holds on thin volume still HELD. Quietly dropping it from the numerator while leaving it in the denominator is how a hold rate gets manufactured.
 
 
IF TWO ZONES OVERLAP, THEY ARE THE SAME LEVEL
 
The merge tolerance is held to at least the combined zone half-widths. Otherwise two levels a fraction of an ATR apart refuse to merge and then draw overlapping boxes anyway, and the geometry contradicts itself on the chart for anyone to see. It is a small thing that quietly tells you the tool was never looked at.
 
 
A LEVEL IS AN ANCHOR, NOT A TRAILING AVERAGE
 
Levels merge as new candidates arrive, and the merged price is a COUNT-WEIGHTED mean: the tenth candidate moves the level by a tenth of the gap, not half of it. This sounds like a detail. It is not. A level that moves halfway toward every new candidate will slide toward price — because price is where new candidates come from — until it is no longer an anchor at all, but a trailing average sitting in the middle of the action, "tested" on every swing. The maths here is the difference between a level and a moving average with extra steps.
 
Levels are retired by DISTANCE, and confluence buys REACH. A level far from price is useless however many voices it has; a level at price is what you are trading. But eviction cannot simply drop the weakest, either — every level is BORN with one voice, so a weakest-first rule kills every new level in the cradle, before it can earn a second, and the chart slowly fills with ancient far-away fossils while nothing can form where price actually is. Confluence buys a level the right to be further away. It does not buy it immortality.
 
 
THE REVERSAL TRADE — because nobody looks at a level to admire it
 
Price tests the level and closes back out. Entry at the CLOSE, stop beyond the level, target a fixed R multiple.
 
  ENTRY IS THE CLOSE, for the event and for the control alike. A rejection is a SIGNAL, not a fill.
  Entering at the level — a better price — while the control enters at the close hands every level a
  free head start, and it would "win" without the level having done anything at all.
 
  THE R MULTIPLE IS FIXED so that the event and the control are measured on IDENTICAL geometry. A
  variable target against a fixed-target control is not a comparison: the near target is reached more
  often AND resolves inside the grading horizon more often, so the two are not even being asked the
  same question.
 
  THE NEXT OPPOSING LEVEL is drawn too, and separately tested: is it reached before the stop, and HOW
  FAR AWAY IS IT IN R? A hit rate with no distance attached is a fact about the distance, not about
  the levels — a target half a unit of risk away being reached often proves nothing.
 
Signals fire only at the levels actually on screen. Every level keeps its record; only the ones you are watching can fire. You do not trade a level twelve levels away from price.
 
And when a level BREAKS, you are told. A level holding is the reversal; a level giving way is the other half of why anyone draws one. Breaks are marked with an x and carry their own alerts — reported as pure information, with no trade framed and no claim made, because the break is not what this engine calibrated. Saying so is cheaper than pretending otherwise.
 
 
NON-REPAINT, AND ITS HONEST COST
 
Pivots confirm some bars late. The kernel extremum confirms a half-window late — a centred kernel looks into the future, and we refuse to. So a level appears some bars AFTER the swing that created it. That lag is the price of not repainting and it is paid deliberately.
 
Levels, tests, holds, breaks, signals and every calibration event are computed on CONFIRMED bars only. The HTF read uses lookahead_off. Nothing is drawn and then moved.
 
 
DATA AND SCOPE
 
Any symbol, any timeframe. ATR-normalised throughout. Volume improves the score but is NOT required — without it the volume-node voice simply abstains rather than guessing.
 
 
HOW TO USE
 
0. Turn the KEY on once (Dashboard & theme > Show the key). It explains the six glyphs. Turn it off
   again — you only need it the first time.
1. MIN VOICES is the one input that matters. 1 gives you the forty-line wallpaper every other S/R
   script gives you. 2 requires agreement. 3 shows only the prices several independent methods
   arrived at on their own. Raise it until the chart shows levels you would actually trade.
2. Read the hold record. "Held 3/4" tells you more than any colour ever will.
3. READ THE CONFLUENCE VERDICT BEFORE YOU WEIGHT ANY OF IT. If the voices do not rank here, a level
   is a LOCATION, not a probability — treat it as context, not as a signal.
4. Wait for the rejection: price into the level, close back out, on real volume.
5. Entry, stop and target are drawn. They are arithmetic, not advice.
 
 
ALERTS
 
  Support held · Resistance held · Any rejection · Support broke · Resistance broke
 
 
EXPORTS (Data Window — consume from other scripts via input.source())
 
EXP_Sup1, EXP_Sup2, EXP_Res1, EXP_Res2, EXP_SupVoices, EXP_ResVoices, EXP_Signal, EXP_Entry, EXP_Stop, EXP_Target, EXP_ConfluenceEdge
 
 
CONCEPT CREDIT
 
Support/resistance and polarity are long-standing public trading concepts with no single author; the written tradition runs through Charles Dow, Richard Wyckoff and Edwards & Magee.
 
The TRADING-RANGE BREAK — the formal S/R rule — was first tested at scale by William Brock, Josef Lakonishok and Blake LeBaron, "Simple Technical Trading Rules and the Stochastic Properties of Stock Returns", Journal of Finance 47(5), 1992. Their findings were later shown to be vulnerable to data-snooping (Sullivan, Timmermann and White, 1999) — which is precisely why this tool MEASURES the rule on your instrument instead of asserting it.
 
Nonparametric kernel regression for level detection is from Andrew W. Lo, Harry Mamaysky and Jiang Wang, Journal of Finance 55(4), 2000; the Nadaraya-Watson estimator is due to Nadaraya and Watson (1964). ATR — J. Welles Wilder. Triple-barrier forward labelling — Marcos Lopez de Prado. Welch's t-test — B. L. Welch.
 
The confluence gate, the voice model, the episode-based hold record, the confluence-ranking test and the direction-matched control are the author's own. Clean-room implementation; no third-party Pine code is reused. Not affiliated with, nor endorsed by, any of the above.
 
 
HONESTY AND LIMITATIONS
 
Calibration is IN-SAMPLE, with no costs or slippage, and uses overlapping windows. A proven in-sample edge is NOT a guarantee out-of-sample. Real fills, spreads and commissions will reduce it.
 
The confluence gate is one rule among many — a different tolerance gives different levels.
 
Confluence is TESTED here, not assumed. If the panel says the extra voices do not rank, then on this instrument they do not, and no amount of agreement between methods will change that.
 
Both barriers on one bar: the STOP is assumed first — conservative, and the only assumption that cannot flatter the result. Unresolved trades at the horizon are marked to market, not booked as losses. Nothing is marked PROVEN below t = 1.96, and nothing is rated at all below the minimum sample.
 
Nothing in this script predicts price.
 
 
DISCLAIMER
 
Research and educational tool only. NOT financial advice, NOT a recommendation, and NO guarantee of results. Entry, stop and target output is arithmetic, not advice. Trading carries risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability for any use.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                                    MPL-2.0
// SUPPORT & RESISTANCE — CONFLUENCE LEVELS, HOLD RECORD & REVERSAL ENTRY                    v1.1
// ────────────────────────────────────────────────────────────────────────────────────────────
// v1.1 — Correctness fix (material): the volume-profile extrema ta.highest/ta.lowest were computed
//        inside a `bar_index % 10 == 0` block, so they ran on one bar in ten and their rolling
//        windows saw only a tenth of the data — the HVN 'voice' was built on wrong high/low range.
//        They now evaluate every bar and are read inside the block. Also hoisted ta.sma (RVOL
//        ternary) and the raw-pivot calls behind the swing-pivot toggle so all stateful functions
//        run on every bar per Pine's requirement. Clears CW10004.
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   FOUR LINES. Two above price, two below. That is the whole chart.
//
//   Every other support/resistance tool has the opposite problem: it finds forty levels and leaves
//   you to work out which two matter. Forty levels is not information, it is wallpaper — and a level
//   you have to hunt for is a level you will not trade.
//
//   So this tool inverts the design. It does not ask "where are the levels?" It asks:
//
//        WHICH LEVEL WOULD I ACTUALLY TRADE, RIGHT NOW, AND WHY SHOULD I BELIEVE IT?
//
//   A price is only promoted to a LEVEL when SEVERAL INDEPENDENT METHODS AGREE ON IT. One method
//   finding a level proves nothing — every method finds levels everywhere. The signal is AGREEMENT.
//
// THE SIX VOICES  (four propose · two confirm)
//   PROPOSERS — each one nominates candidate prices, independently:
//     ◆ SWING PIVOT      the classic. Where price actually turned.
//     ~ KERNEL EXTREMUM  the turning point of the SMOOTHED price (Nadaraya-Watson), which is the
//                        shape rather than the noise. This is Lo, Mamaysky & Wang's method, and it
//                        finds structurally different levels from a raw pivot — that independence is
//                        exactly what makes the agreement between them worth something.
//     ⇈ HIGHER TIMEFRAME a swing on the HTF. The level a bigger participant is watching.
//     ▣ PRIOR PERIOD     yesterday's high and low, last week's high and low. The most watched prices
//                        on any chart, and absent from almost every "auto S/R" script.
//   CONFIRMERS — they do not nominate, they vouch:
//     ▪ VOLUME NODE      the price sits on a high-volume node: real business was transacted here, not
//                        merely a turning point.
//     ○ ROUND NUMBER     the psychological grid.
//
//   Candidates within an ATR tolerance merge, and the merged level inherits every voice that spoke
//   for it. A level needs MIN VOICES agreement to exist at all. Everything below that is discarded —
//   not hidden, DISCARDED. Then only the nearest two above and two below are drawn.
//
// AND THEN THE PART NOBODY DOES: WE TEST WHETHER CONFLUENCE ACTUALLY RANKS
//   "Levels are stronger when several methods agree" is one of the most repeated claims in technical
//   analysis and almost nobody has ever checked it. It is checkable. So the panel reports:
//
//        3+ voices   +0.24R   n=61   ✓ PROVEN
//        2 voices    -0.03R   n=88     (not proven)
//        Control     +0.02R   n=240
//
//   If the high-confluence levels do NOT beat the low-confluence ones, the confluence idea is noise
//   ON THIS INSTRUMENT, and the panel says so in plain English. That row is the reason this script
//   exists. A tool that cannot report its own failure is not a measurement, it is an advertisement.
//
// THE HOLD RECORD  —  and why "held 3/4" is not what most scripts mean by it
//   A TEST IS AN EPISODE, NOT A BAR. Price arrives at the level and the test stays OPEN until price
//   LEAVES — back the way it came (HELD) or straight through (BROKE). A bar that closes INSIDE the
//   zone has resolved nothing and is counted as nothing. Counting every touching bar as a completed
//   test drops an entire consolidation into the denominator as failures, and manufactures hold rates
//   around 10% that say nothing about the level and everything about the counter. An unresolved test
//   is neither a hold nor a break, exactly as an unresolved trade is neither a win nor a loss.
//
// THE REVERSAL TRADE  —  because nobody looks at a level to admire it
//   Price tests the level and closes back out → entry at the CLOSE, stop beyond the level, target a
//   fixed R multiple. The R multiple is fixed so that the event and the control are measured on
//   IDENTICAL geometry; a variable target against a fixed-target control is not a comparison.
//   The NEXT OPPOSING LEVEL is drawn too, and separately tested: is it reached before the stop, and
//   HOW FAR AWAY IS IT IN R? A hit rate with no distance attached is a fact about the distance, not
//   about the levels — a target half a unit of risk away being reached often proves nothing at all.
//
// NON-REPAINT  (and its honest cost)
//   Pivots confirm `pivLen` bars late. The kernel extremum confirms a half-window late — a centred
//   kernel looks into the future, and we refuse to. So a level appears some bars AFTER the swing that
//   created it. That lag is the price of not repainting and it is paid deliberately. Levels, tests,
//   holds, breaks, signals and every calibration event are computed on CONFIRMED bars only. The HTF
//   read uses lookahead_off. Nothing is drawn and then moved.
//
// DATA / SCOPE
//   Any symbol, any timeframe. ATR-normalised throughout. Volume improves the score but is NOT
//   required — without it the volume-node voice simply abstains rather than guessing.
//
// EXPORTS  (Data Window — consume from other scripts via input.source())
//   EXP_Sup1 · EXP_Sup2 · EXP_Res1 · EXP_Res2 · EXP_SupVoices · EXP_ResVoices · EXP_Signal ·
//   EXP_Entry · EXP_Stop · EXP_Target · EXP_ConfluenceEdge
//
// CONCEPT CREDIT
//   Support/resistance and polarity are long-standing public trading concepts with no single author;
//   the written tradition runs through Charles Dow, Richard Wyckoff and Edwards & Magee. The
//   TRADING-RANGE BREAK — the formal S/R rule — was first tested at scale by William Brock, Josef
//   Lakonishok and Blake LeBaron, "Simple Technical Trading Rules and the Stochastic Properties of
//   Stock Returns", Journal of Finance 47(5), 1992; their findings were later shown to be vulnerable
//   to data-snooping (Sullivan, Timmermann & White, 1999), which is precisely why this tool measures
//   the rule on YOUR instrument instead of asserting it. Nonparametric kernel regression for level
//   detection is from Andrew W. Lo, Harry Mamaysky and Jiang Wang, Journal of Finance 55(4), 2000;
//   the Nadaraya-Watson estimator is due to Nadaraya and Watson (1964). ATR — J. Welles Wilder.
//   Triple-barrier forward labelling — Marcos López de Prado. Welch's t-test — B. L. Welch.
//   The confluence gate, the voice model, the episode-based hold record, the confluence-ranking test
//   and the direction-matched control are the author's own. Clean-room implementation; no third-party
//   Pine code is reused. Not affiliated with, nor endorsed by, any of the above.
//
// HONESTY / LIMITATIONS
//   Calibration is IN-SAMPLE, with no costs or slippage, and uses overlapping windows; a proven
//   in-sample edge is NOT a guarantee out-of-sample. Real fills, spreads and commissions will reduce
//   it. The confluence gate is one rule among many — a different tolerance gives different levels.
//   Confluence is TESTED here, not assumed: if the panel says the extra voices do not rank, then on
//   this instrument they do not, and no amount of agreement between methods will change that.
//   Nothing in this script predicts price.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice, NOT a recommendation, and NO guarantee
//   of results. Entry/stop/target output is arithmetic, not advice. Trading carries risk of loss.
//   Test out-of-sample and make your own decisions. The author accepts no liability for any use.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Support & Resistance — Confluence Levels, Hold Record & Reversal Entry", "S/R Levels",
     overlay = true, max_lines_count = 100, max_labels_count = 100, max_boxes_count = 100,
     max_bars_back = 3000)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
g1 = "01 · The confluence gate"
g2 = "02 · The six voices"
g3 = "03 · The reversal trade"
g4 = "04 · Does confluence actually rank?"
g5 = "05 · Drawing"
g6 = "06 · Dashboard & theme"

minVoice = input.int(2, "MIN VOICES for a level to exist", minval = 1, maxval = 6, group = g1, tooltip = "THE ONE INPUT THAT MATTERS. A price must be nominated or vouched for by at least this many INDEPENDENT methods before it is a level at all. 1 = every swing is a level, and you get the forty-line wallpaper every other S/R script gives you. 2 = agreement required. 3 = only the prices several methods independently arrived at. Raise it until the chart shows you levels you would actually trade — and then check the panel to see whether the extra voices are earning their keep.")
showN    = input.int(2, "Levels drawn each side", minval = 1, maxval = 5, group = g1, tooltip = "Two above, two below. That is what a trader looks at. Levels beyond this still exist, are still tested and still counted — they are simply not drawn, because a level you have to hunt for is a level you will not trade.")
clusterA = input.float(0.4, "Merge tolerance (×ATR)", minval = 0.05, maxval = 2.0, step = 0.05, group = g1, tooltip = "Candidates within this distance are the SAME level and merge, pooling their voices. ATR-normalised, so it travels across instruments.")
zoneWA   = input.float(0.25, "Level half-width (×ATR)", minval = 0.0, maxval = 2.0, step = 0.05, group = g1, tooltip = "A level is a zone, not a number. Set to 0 for a bare line.")
maxLvl   = input.int(40, "Levels tracked in memory", minval = 10, maxval = 100, group = g1, tooltip = "How many levels the engine keeps records for. Only `Levels drawn each side` are ever DRAWN — this is the memory, not the display.")

usePiv   = input.bool(true, "◆ Swing pivot", group = g2, tooltip = "The classic. Where price actually turned.")
pivLen   = input.int(10, "     swing length", minval = 2, maxval = 60, group = g2, tooltip = "Bars either side. Swings confirm this many bars AFTER the fact — the honest cost of not repainting.")
useKer   = input.bool(true, "~ Kernel extremum (Lo-Mamaysky-Wang)", group = g2, tooltip = "The turning point of the SMOOTHED price, not the raw price — the shape rather than the noise. It finds STRUCTURALLY DIFFERENT levels from a raw pivot, and that independence is exactly what makes agreement between the two worth something. Agreement between two methods that make the same mistakes is worth nothing.")
kW       = input.int(16, "     kernel half-window", minval = 4, maxval = 60, group = g2, tooltip = "Also the lag: an extremum cannot be confirmed until the window has passed.")
kH       = input.float(7.0, "     kernel bandwidth", minval = 1.0, maxval = 40.0, step = 0.5, group = g2)
useHTF   = input.bool(true, "⇈ Higher-timeframe swing", group = g2, tooltip = "The level a bigger participant is watching.")
htfTf    = input.timeframe("240", "     higher timeframe", group = g2)
usePP    = input.bool(true, "▣ Prior period high / low", group = g2, tooltip = "Yesterday's high and low. Last week's high and low. The most watched prices on any chart — and missing from almost every auto-S/R script on TradingView.")
useHVN   = input.bool(true, "▪ Volume node (confirms only)", group = g2, tooltip = "Does the level sit where volume ACTUALLY TRANSACTED? A level with real business behind it is a different animal from a level that is merely a turning point. This voice does not nominate levels — it vouches for them.")
vpLook   = input.int(250, "     profile lookback", minval = 50, maxval = 1000, group = g2)
vpBins   = input.int(24, "     profile bins", minval = 8, maxval = 60, group = g2)
useRound = input.bool(true, "○ Round number (confirms only)", group = g2)
roundStep= input.float(100.0, "     round-number step", minval = 0.0001, maxval = 100000.0, group = g2, tooltip = "The psychological grid. NIFTY = 100 (or 50). Match how your instrument is quoted.")

needVol  = input.float(1.2, "SIGNAL needs RVOL above", minval = 0.0, maxval = 5.0, step = 0.1, group = g3, tooltip = "A rejection on no volume is a wick, not a defence — so this gates the TRADE SIGNAL. It does NOT gate the level's RECORD. A level that holds on thin volume still HELD, and quietly dropping it from the numerator while leaving it in the denominator is how a hold rate gets manufactured.")
testTTL  = input.int(20, "Cancel an unresolved test after (bars)", minval = 3, maxval = 200, group = g3, tooltip = "If price simply SITS inside a level, that is not a test — it is a consolidation. The open test is cancelled and counted as NEITHER a hold nor a break, because it was neither.")
reArmA   = input.float(1.0, "Re-arm a level after price moves away (×ATR)", minval = 0.0, maxval = 5.0, step = 0.1, group = g3, tooltip = "A TEST IS AN APPROACH, NOT A BAR TOUCHING A BOX. Without this, price exits the zone (HELD), the next bar dips straight back in, and that counts as a brand-new test — so chop sitting on a level logs a hundred 'tests' that were really one event. Live, this produced 224 tests of a single level on a 5m chart, and hold rates that all landed between 61% and 75% no matter which level you looked at: a statistic that cannot tell any two levels apart is not measuring the levels, it is measuring the bar size. Price must now travel this far CLEAR of the zone before the level can be tested again. Set to 0 for the old bar-by-bar behaviour.")
stopBufA = input.float(0.3, "Stop beyond the level (×ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = g3)
tgtR     = input.float(2.0, "Trade target (R multiple)", minval = 0.5, maxval = 10.0, step = 0.5, group = g3, tooltip = "FIXED, so that the event and the control are measured on IDENTICAL geometry. A variable target against a fixed-target control is not a comparison — the near target is reached more often AND resolves inside the horizon more often, so the two are not even being asked the same question.")
showNext = input.bool(true, "Draw & test the next opposing level", group = g3, tooltip = "Where the trade is actually going. It is drawn AND its hit rate is measured — reported NEXT TO its distance in R, because a hit rate without a distance is a fact about the distance.")

calibOn  = input.bool(true, "Test whether confluence ranks", group = g4, tooltip = "Levels with MANY voices are bucketed separately from levels with FEW, and both are compared against an unconditional, direction-matched control. This is the reason the script exists.")
splitAt  = input.int(3, "'High confluence' means voices >=", minval = 2, maxval = 6, group = g4)
calHor   = input.int(40, "Grading horizon (bars)", minval = 5, maxval = 300, group = g4)
calMinN  = input.int(25, "Min sample before rating", minval = 5, maxval = 300, group = g4)
ctlEvery = input.int(20, "Control sample every N bars", minval = 3, maxval = 200, group = g4)

showLvl  = input.bool(true, "Draw the levels", group = g5)
showSetup= input.bool(true, "Draw entry / stop / target", group = g5)
showSig  = input.bool(true, "Mark rejections", group = g5)
extendN  = input.int(20, "Extend levels (bars right)", minval = 0, maxval = 200, group = g5)
lineW    = input.int(2, "Line width", minval = 1, maxval = 5, group = g5)
zoneTr   = input.int(85, "Zone transparency", minval = 50, maxval = 99, group = g5)
colSup   = input.color(#26a69a, "Support", inline = "c", group = g5)
colRes   = input.color(#ef5350, "Resistance", inline = "c", group = g5)
lblSize  = input.string("Small", "Label size", options = ["Tiny","Small","Normal"], group = g5)

showLegend=input.bool(false, "Show the key (what ◆ ~ ⇈ ▣ ▪ ○ mean)", group = g6, tooltip = "OFF by default — you learn the six glyphs once and then never need the key again, but it costs chart space every bar after that.")
legendPos= input.string("Bottom Right", "Key position", options = ["Bottom Right","Middle Left","Top Left","Middle Right"], group = g6, tooltip = "TradingView's own watermark sits bottom-LEFT and will clip a key placed there.")
showPanel= input.bool(true, "Show dashboard", group = g6)
panelMode= input.string("Compact", "Dashboard detail", options = ["Compact","Pro"], group = g6, tooltip = "Pro shows the confluence-ranking table — the whole point of the tool.")
panelPos = input.string("Top Right", "Dashboard position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g6)
themeOpt = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g6)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          TYPES
// ═════════════════════════════════════════════════════════════════════════════════════════
type Lvl
    float px            // the level — a COUNT-WEIGHTED mean of every candidate that merged into it
    float top
    float bot
    float w             // half-width, FROZEN at birth (a zone that breathes with live ATR repaints)
    int   nCand         // how many candidates have merged in. This is what makes px STABLE:
                        //   px += (new - px) / nCand
                        // The old rule was px := (px + new) / 2, which drags the level HALFWAY to
                        // every new candidate. Price generates candidates near itself, so a level
                        // near price kept absorbing them and kept SLIDING toward price. It stopped
                        // being an anchor and became a trailing average — which is why the live
                        // chart showed "support" 0.2 points under spot, hold records of 31/42, and
                        // a flip tag on nearly every level. An incremental mean converges instead:
                        // the tenth candidate moves the level by a tenth of the gap, not half of it.
    int   bi            // the bar it was confirmed on
    // THE SIX VOICES. (Pine has no bitwise operators, so these are plain fields — which reads
    // better than a bitmask anyway: you can see at the type definition exactly what a level is.)
    bool  vPiv          // ◆ swing pivot
    bool  vKer          // ~ kernel extremum
    bool  vHtf          // ⇈ higher-timeframe swing
    bool  vPP           // ▣ prior period high / low
    bool  vHvn          // ▪ volume node      (confirms only)
    bool  vRnd          // ○ round number     (confirms only)
    // ── THE RECORD ──  a test is an EPISODE, not a bar
    int   tst           // 0 = none open · +1 = support test open · -1 = resistance test open
    int   tstBi
    int   touches       // COMPLETED tests
    int   holds
    int   breaks
    bool  bornSup       // was price ABOVE it when it was born?
    bool  armed         // can this level be TESTED again yet? (see the re-arm rule below)
    box   bx
    label lb

type Trade
    int   bi
    float entry
    float stop
    float tgt
    int   dir
    int   bucket
    float rr

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                    ENGINE PRIMITIVES
// ═════════════════════════════════════════════════════════════════════════════════════════
float atr    = ta.atr(14)
bool  hasVol = ta.cum(nz(volume)) > 0
float vol0   = nz(volume, 0.0)
// STATEFUL HOIST: ta.sma must run every bar; inside the `hasVol ?` ternary it was skipped while
// cumulative volume was still zero, corrupting the average. Compute unconditionally, then mask.
float vol0Sma = ta.sma(vol0, 20)
float rvol   = hasVol ? vol0 / math.max(vol0Sma, 1e-9) : 1.0

// Pine's "+#.00" treats the '+' as a LITERAL, so -0.25 renders as "-+.25". Sign it by hand.
f_R(float v) => na(v) ? "-" : (v >= 0 ? "+" : "") + str.tostring(v, "#.00") + "R"
f_lblSize() => lblSize == "Tiny" ? size.tiny : lblSize == "Normal" ? size.normal : size.small
f_lum(color c) => na(c) ? 0.0 : 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_pos(string s) => s == "Top Left" ? position.top_left : s == "Bottom Right" ? position.bottom_right : s == "Bottom Left" ? position.bottom_left : s == "Middle Right" ? position.middle_right : position.top_right

// how many voices spoke for this level
f_nVoice(Lvl L) => (L.vPiv ? 1 : 0) + (L.vKer ? 1 : 0) + (L.vHtf ? 1 : 0) + (L.vPP ? 1 : 0) + (L.vHvn ? 1 : 0) + (L.vRnd ? 1 : 0)
// the voices, as glyphs — so the label SHOWS you WHY the level exists, not merely that it does
f_voiceTxt(Lvl L) => (L.vPiv ? "◆" : "") + (L.vKer ? "~" : "") + (L.vHtf ? "⇈" : "") + (L.vPP ? "▣" : "") + (L.vHvn ? "▪" : "") + (L.vRnd ? "○" : "")

bool darkUI   = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color colWarn = color.new(#ffa726, 0)

// ═════════════════════════════════════════════════════════════════════════════════════════
//   A · THE KERNEL SMOOTHER  (Nadaraya-Watson, Gaussian)
//   Evaluated at bar_index - kW using bars 0..2kW back, so the whole window is HISTORY. That is why
//   it does not repaint, and why the extremum confirms kW bars late.
//   It MUST be called on every bar — it reads kSrc[j], and calling it inside a ternary leaves its
//   history buffer inconsistent (CW10004). Call unconditionally, then mask.
// ═════════════════════════════════════════════════════════════════════════════════════════
f_nw() =>
    float num = 0.0
    float den = 0.0
    for j = 0 to 2 * kW
        float z = (j - kW) / kH
        float k = math.exp(-0.5 * z * z)
        num += k * close[j]
        den += k
    den > 0 ? num / den : na
float smRaw = f_nw()
float sm    = bar_index > 2 * kW ? smRaw : na

// ═════════════════════════════════════════════════════════════════════════════════════════
//   B · THE VOLUME PROFILE  —  the HVN voice (it confirms, it does not nominate)
// ═════════════════════════════════════════════════════════════════════════════════════════
var array<float> hvns = array.new<float>()
// STATEFUL HOIST: these ran only on bars where bar_index % 10 == 0 — one bar in ten — so their
// rolling windows saw a fraction of the bars and returned wrong extrema. Compute every bar, use inside.
float hvnHi = ta.highest(high, vpLook)
float hvnLo = ta.lowest(low, vpLook)
if barstate.isconfirmed and useHVN and hasVol and bar_index % 10 == 0 and bar_index > vpLook
    array.clear(hvns)
    float hi = hvnHi
    float lo = hvnLo
    float rng = hi - lo
    if rng > 0
        array<float> bins = array.new<float>(vpBins, 0.0)
        for j = 0 to vpLook - 1
            int b = math.min(vpBins - 1, math.max(0, int((close[j] - lo) / rng * vpBins)))
            array.set(bins, b, array.get(bins, b) + nz(volume[j], 0.0))
        float mx = array.max(bins)
        if mx > 0
            for b = 0 to vpBins - 1
                if array.get(bins, b) >= mx * 0.70          // a high-volume node
                    array.push(hvns, lo + (b + 0.5) / vpBins * rng)

f_isHVN(float px, float tol) =>
    bool hit = false
    if array.size(hvns) > 0
        for i = 0 to array.size(hvns) - 1
            if math.abs(array.get(hvns, i) - px) <= tol
                hit := true
                break
    hit

// ═════════════════════════════════════════════════════════════════════════════════════════
//   C · THE FOUR PROPOSERS
// ═════════════════════════════════════════════════════════════════════════════════════════
// ◆ swing pivots
// STATEFUL HOIST (defensive): pivots computed every bar so the buffer stays consistent. `usePiv`
// is a constant input so this was benign, but hoisting clears CW10004 and matches house standard.
float rawPvH = ta.pivothigh(high, pivLen, pivLen)
float rawPvL = ta.pivotlow(low, pivLen, pivLen)
float pvH = usePiv ? rawPvH : na
float pvL = usePiv ? rawPvL : na

// ~ kernel extrema of the SMOOTHED series
bool kMax = not na(sm) and not na(sm[2]) and sm[1] > sm[2] and sm[1] > sm
bool kMin = not na(sm) and not na(sm[2]) and sm[1] < sm[2] and sm[1] < sm
float kH_ = useKer and kMax ? high[kW + 1] : na
float kL_ = useKer and kMin ? low[kW + 1]  : na

// ⇈ higher-timeframe swings — lookahead_off, and read one bar back so the HTF bar is CLOSED
htfH = request.security(syminfo.tickerid, htfTf, ta.pivothigh(high, 2, 2), lookahead = barmerge.lookahead_off)
htfL = request.security(syminfo.tickerid, htfTf, ta.pivotlow(low, 2, 2),   lookahead = barmerge.lookahead_off)

// ▣ prior period high / low — yesterday, and last week
pdH = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_off)
pdL = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_off)
pwH = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_off)
pwL = request.security(syminfo.tickerid, "W", low[1],  lookahead = barmerge.lookahead_off)

// ═════════════════════════════════════════════════════════════════════════════════════════
//   D · CLUSTERING  —  candidates merge, and the merged level INHERITS EVERY VOICE
// ═════════════════════════════════════════════════════════════════════════════════════════
var array<Lvl> lvls = array.new<Lvl>()

// voice: 1 = pivot · 2 = kernel · 3 = HTF · 4 = prior period
// IF TWO ZONES OVERLAP, THEY ARE THE SAME LEVEL. The merge tolerance must therefore be at least the
// combined half-widths — otherwise two levels 0.45 ATR apart refuse to merge and then draw
// overlapping boxes anyway, and the geometry contradicts itself on the chart for anyone to see.
f_mergeTol() => math.max(clusterA, 2.0 * zoneWA) * atr

f_addCand(float px, int voice) =>
    if not na(px) and atr > 0
        float tol = f_mergeTol()
        int hit = -1
        if array.size(lvls) > 0
            for i = 0 to array.size(lvls) - 1
                Lvl L = array.get(lvls, i)
                if math.abs(L.px - px) <= tol
                    hit := i
                    break
        if hit >= 0
            // MERGE — and this is the whole point: the level absorbs the candidate AND ITS VOICE.
            // A price that a pivot found and the kernel independently also found is not one level
            // discovered twice. It is one level discovered by two methods that do not share a bias.
            Lvl L = array.get(lvls, hit)
            L.nCand += 1
            L.px  := L.px + (px - L.px) / L.nCand      // incremental mean — converges, does not chase
            L.top := L.px + L.w
            L.bot := L.px - L.w
            L.vPiv := L.vPiv or voice == 1
            L.vKer := L.vKer or voice == 2
            L.vHtf := L.vHtf or voice == 3
            L.vPP  := L.vPP  or voice == 4
        else
            float w = math.max(zoneWA * atr, syminfo.mintick)
            array.push(lvls, Lvl.new(px, px + w, px - w, w, 1, bar_index, voice == 1, voice == 2, voice == 3, voice == 4, false, false, 0, 0, 0, 0, 0, close > px, true, na, na))
        // ══ EVICTION ══
        // DISTANCE decides, and voices BUY REACH. Both of the obvious rules are wrong:
        //
        //   Evict the OLDEST (array.shift) — throws away last week's high, which is precisely the
        //   level that does not stop mattering because it is old.
        //
        //   Evict the WEAKEST — catastrophic, and subtly so. Every level is BORN with one voice, so
        //   every new level is by definition the weakest on the chart, so every new level is killed
        //   on the next push, BEFORE it can ever earn a second voice. Old strong levels become
        //   immortal, nothing can form near current price, and the array silently fills with ancient
        //   far-away fossils. Live, that left a 3m chart reporting its nearest resistance as a
        //   six-voice level 1,795 points away, and NO support at all. Strength is EARNED OVER TIME;
        //   a rule that evicts on strength strangles every level in the cradle.
        //
        // So: score = distance from price (in ATR), minus REACH earned by each extra voice. A newborn
        // level sitting at price scores ~0 and is safe. A six-voice fossil 70 ATR away scores 70-50
        // and goes first. Confluence buys a level the right to be further away — it does not buy it
        // immortality.
        while array.size(lvls) > maxLvl
            int   worst = 0
            float wS    = -1e18
            for i = 0 to array.size(lvls) - 1
                Lvl L2 = array.get(lvls, i)
                float sc = math.abs(L2.px - close) / atr - (f_nVoice(L2) - 1) * 10.0
                if sc > wS
                    worst := i
                    wS    := sc
            Lvl o = array.remove(lvls, worst)
            box.delete(o.bx)
            label.delete(o.lb)

if barstate.isconfirmed and atr > 0
    // Pivots and kernel extrema are EVENTS — they are na except on the bar they confirm, so they
    // propose exactly once, which is correct.
    f_addCand(pvH, 1)
    f_addCand(pvL, 1)
    f_addCand(kH_, 2)
    f_addCand(kL_, 2)
    // The HTF swing and the prior-period highs/lows are STANDING VALUES — request.security holds them
    // on every bar until they change. Re-proposing the same price on every single bar re-runs the
    // merge and the eviction sweep thousands of times for one level, inflates its candidate count
    // (which then freezes the incremental mean), and — once it is far from price — churns it in and
    // out of the array forever. Propose them ONLY WHEN THEY CHANGE. Once is once.
    if useHTF
        if htfH != htfH[1]
            f_addCand(htfH, 3)
        if htfL != htfL[1]
            f_addCand(htfL, 3)
    if usePP
        if pdH != pdH[1]
            f_addCand(pdH, 4)
        if pdL != pdL[1]
            f_addCand(pdL, 4)
        if pwH != pwH[1]
            f_addCand(pwH, 4)
        if pwL != pwL[1]
            f_addCand(pwL, 4)

// ── THE CONFIRMERS vouch every bar: they do not nominate levels, they endorse them ──
if barstate.isconfirmed and array.size(lvls) > 0 and atr > 0
    for i = 0 to array.size(lvls) - 1
        Lvl L = array.get(lvls, i)
        // STICKY. Once a voice has spoken for a level it does not un-speak. Re-testing the condition
        // every bar meant a level could LOSE a voice as the rolling volume profile shifted beneath it,
        // drop below MIN VOICES, and vanish from the chart — the level SET itself was repainting.
        L.vHvn := useHVN  and (L.vHvn or (hasVol and f_isHVN(L.px, f_mergeTol())))
        L.vRnd := useRound and (L.vRnd or (roundStep > 0 and math.abs(L.px - math.round(L.px / roundStep) * roundStep) <= clusterA * atr * 0.5))

// ═════════════════════════════════════════════════════════════════════════════════════════
//   D2 · FINDING THE LEVELS THAT MATTER
// ═════════════════════════════════════════════════════════════════════════════════════════
// The NEXT OPPOSING LEVEL is the one the trade is travelling to — so it must be somewhere ELSE.
// A level sitting a tick from the entry is not the next level, it is the SAME price, and reporting
// it as a target produced "NEXT LEVEL 0.0R" printed directly on top of the entry label on every
// chart. Anything inside the merge tolerance is the same congestion; step over it.
f_nextOpp(int dir, float from) =>
    float best = na
    float gap  = f_mergeTol()
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl L = array.get(lvls, i)
            if f_nVoice(L) >= minVoice
                bool side = dir == 1 ? L.px > from + gap : L.px < from - gap
                if side and (na(best) or (dir == 1 ? L.px < best : L.px > best))
                    best := L.px
    best

f_nearest(int dir, int rank) =>
    // dir +1 = above price (resistance) · -1 = below (support). rank 0 = nearest.
    float best = na
    int   bestV = 0
    float prev = na
    for r = 0 to rank
        float cur = na
        int   curV = 0
        if array.size(lvls) > 0
            for i = 0 to array.size(lvls) - 1
                Lvl L = array.get(lvls, i)
                bool ok = f_nVoice(L) >= minVoice
                bool side = dir == 1 ? L.px > close : L.px < close
                bool past = na(prev) ? true : (dir == 1 ? L.px > prev : L.px < prev)
                if ok and side and past and (na(cur) or (dir == 1 ? L.px < cur : L.px > cur))
                    cur  := L.px
                    curV := f_nVoice(L)
        prev := cur
        best := cur
        bestV := curV
    [best, bestV]

// ═════════════════════════════════════════════════════════════════════════════════════════
//   E · THE RECORD  —  a test is an EPISODE, not a bar
// ═════════════════════════════════════════════════════════════════════════════════════════
var array<Trade> pend   = array.new<Trade>()
var array<Trade> pendNX = array.new<Trade>()
// ── BUCKETS, SPLIT BY DIRECTION ──
//   1 = LOW  confluence LONG   ·  2 = LOW  confluence SHORT
//   3 = HIGH confluence LONG   ·  4 = HIGH confluence SHORT
//   5 = control LONG           ·  6 = control SHORT
// The split exists because of a trap that has bitten this codebase before. Reversals at SUPPORT are
// overwhelmingly LONG on a drifting index — and a long-biased event set compared against a 50/50
// control is handed the index drift for free and calls it an edge. Longs are therefore compared only
// with control LONGS, shorts only with control SHORTS, and the control is then blended back using
// the EVENTS' OWN direction mix.
var array<int>   bN  = array.new<int>(7, 0)
var array<float> bR  = array.new<float>(7, 0.0)
var array<float> bR2 = array.new<float>(7, 0.0)
// the next-opposing-level target: reached / attempted / and HOW FAR IT WAS, in R.  1 = low · 2 = high
var array<int>   nxH = array.new<int>(3, 0)
var array<int>   nxN = array.new<int>(3, 0)
var array<float> nxR = array.new<float>(3, 0.0)

// THE WATCHED SET — the levels currently drawn: nearest `showN` above and below. Rebuilt each bar,
// BEFORE the test loop, so the loop can ask "is this one of the levels the trader is looking at?"
// in O(1) instead of re-scanning every level for every level.
// A LOCAL array (not `var`), so it is rebuilt from scratch every bar and cannot go stale — and so it
// needs no barstate gate, because there is no cross-bar state to roll back.
array<float> watch = array.new<float>()
for r = 0 to showN - 1
    [pS, vS] = f_nearest(-1, r)
    if not na(pS)
        array.push(watch, pS)
    [pR, vR] = f_nearest(1, r)
    if not na(pR)
        array.push(watch, pR)
f_watched(float px) =>
    bool hit = false
    if array.size(watch) > 0
        for i = 0 to array.size(watch) - 1
            if math.abs(array.get(watch, i) - px) < syminfo.mintick
                hit := true
                break
    hit

bool  sigLong  = false
bool  sigShort = false
float sigPx    = na
int   sigVox   = 0
// A level HOLDING is the reversal. A level BREAKING is the other half of why anyone draws one —
// and it is reported as pure information: a marker and an alert, with no trade framed and no claim
// made, because the break is not what this engine calibrated.
bool  brkUp    = false
bool  brkDn    = false

if barstate.isconfirmed and array.size(lvls) > 0 and atr > 0
    for i = 0 to array.size(lvls) - 1
        Lvl L = array.get(lvls, i)
        if bar_index > L.bi and f_nVoice(L) >= minVoice
            bool into = low <= L.top and high >= L.bot

            // RE-ARM once price has travelled clear of the level. A level that price is still sitting
            // on has not been "re-approached" — it is being chopped through, and every one of those
            // bars is the SAME event.
            if not L.armed and (close > L.top + reArmA * atr or close < L.bot - reArmA * atr)
                L.armed := true

            // OPEN a test when price ARRIVES from outside — and only if the level is armed
            if L.tst == 0 and into and L.armed
                if close[1] > L.top
                    L.tst   := 1
                    L.tstBi := bar_index
                else if close[1] < L.bot
                    L.tst   := -1
                    L.tstBi := bar_index

            // RESOLVE it only when price LEAVES. "Still inside" is not a result.
            bool held  = L.tst == 1 ? close > L.top : L.tst == -1 ? close < L.bot : false
            bool broke = L.tst == 1 ? close < L.bot : L.tst == -1 ? close > L.top : false

            if held
                L.touches += 1
                L.holds   += 1
                // THE RECORD IS A FACT ABOUT THE LEVEL. THE SIGNAL IS A DECISION ABOUT THE TRADE.
                // The volume filter, and the requirement that this be a level you are actually
                // WATCHING, both belong to the second and never to the first. Every level keeps its
                // record; only the drawn ones can fire.
                if (needVol <= 0 or rvol >= needVol) and f_watched(L.px)
                    if L.tst == 1
                        sigLong := true
                    else
                        sigShort := true
                    sigPx  := L.px
                    sigVox := f_nVoice(L)
                L.tst   := 0
                L.armed := false            // one approach, one test
            else if broke
                L.touches += 1
                L.breaks  += 1
                if f_watched(L.px)
                    if L.tst == 1
                        brkDn := true          // support gave way
                    else
                        brkUp := true          // resistance gave way
                L.tst   := 0
                L.armed := false
            else if L.tst != 0 and bar_index - L.tstBi > testTTL
                L.tst   := 0                  // price just sat there. Not a test. Count nothing.
                L.armed := false

// ═════════════════════════════════════════════════════════════════════════════════════════
//   F · THE FOUR LEVELS ON SCREEN  —  the only ones a trader ever looks at
// ═════════════════════════════════════════════════════════════════════════════════════════
[sup1, sup1v] = f_nearest(-1, 0)
[sup2, sup2v] = f_nearest(-1, 1)
[res1, res1v] = f_nearest(1, 0)
[res2, res2v] = f_nearest(1, 1)

// ═════════════════════════════════════════════════════════════════════════════════════════
//   G · THE REVERSAL TRADE
// ═════════════════════════════════════════════════════════════════════════════════════════
var float eEn  = na
var float eSt  = na
var float eTg  = na
var float eNX  = na
var float eNXR = na
var int   eDir = 0
var int   eVox = 0
var int   eBar = -1000
var bool  eOpen = false
var int   eRes  = 0
bool firedNow = false

if barstate.isconfirmed and (sigLong or sigShort) and atr > 0
    int dir = sigLong ? 1 : -1
    // ENTRY IS THE CLOSE — a rejection is a SIGNAL, not a fill. Entering at the level (a better price
    // than the close) while the control enters at the close hands every level a free head start, and
    // it would "win" without the level having done anything at all.
    float en   = close
    float st   = dir == 1 ? math.min(low, sigPx) - stopBufA * atr : math.max(high, sigPx) + stopBufA * atr
    float risk = math.abs(en - st)
    if risk > 0
        eEn := en
        eSt := st
        eTg := dir == 1 ? en + tgtR * risk : en - tgtR * risk
        eDir := dir
        eVox := sigVox
        eBar := bar_index
        eOpen := true
        eRes  := 0
        firedNow := true
        // where the trade is actually GOING — the next opposing level, and it must be ELSEWHERE
        float nx = f_nextOpp(dir, en)
        eNX  := nx
        eNXR := na(nx) ? na : math.abs(nx - en) / risk
        if calibOn
            int grp = sigVox >= splitAt ? 2 : 1                 // 1 = low confluence · 2 = high
            int b   = (grp == 2 ? 3 : 1) + (dir == 1 ? 0 : 1)   // ...split by direction
            array.push(pend, Trade.new(bar_index, en, st, eTg, dir, b, tgtR))
            if not na(nx)
                array.push(pendNX, Trade.new(bar_index, en, st, nx, dir, grp, math.abs(nx - en) / risk))

// the setup is a TRADE, and a trade ENDS. It does not simply fade after N bars.
if barstate.isconfirmed and eOpen and not na(eEn) and bar_index > eBar
    bool tHit = eDir == 1 ? high >= eTg : low  <= eTg
    bool sHit = eDir == 1 ? low  <= eSt : high >= eSt
    if sHit
        eOpen := false
        eRes  := -1
    else if tHit
        eOpen := false
        eRes  := 1
    else if bar_index - eBar >= calHor
        eOpen := false
        eRes  := 0

// ═════════════════════════════════════════════════════════════════════════════════════════
//   H · CALIBRATION  —  does confluence actually RANK?
//   The control is unconditional and DIRECTION-MATCHED, on identical geometry. Every event uses the
//   SAME fixed R multiple as the control, so the comparison is apples to apples.
// ═════════════════════════════════════════════════════════════════════════════════════════
if barstate.isconfirmed and calibOn and atr > 0 and bar_index % ctlEvery == 0
    float risk = atr
    array.push(pend, Trade.new(bar_index, close, close - risk, close + tgtR * risk,  1, 5, tgtR))
    array.push(pend, Trade.new(bar_index, close, close + risk, close - tgtR * risk, -1, 6, tgtR))

if barstate.isconfirmed and array.size(pend) > 0
    int i = 0
    while i < array.size(pend)
        Trade t = array.get(pend, i)
        bool hitT = t.dir == 1 ? high >= t.tgt : low  <= t.tgt
        bool hitS = t.dir == 1 ? low  <= t.stop : high >= t.stop
        bool expd = bar_index - t.bi >= calHor
        if bar_index > t.bi and (hitT or hitS or expd)
            // both barriers on one bar → the STOP is assumed first. Conservative, and the only
            // assumption that cannot flatter the result.
            float risk = math.abs(t.entry - t.stop)
            // an expired trade is MARKED TO MARKET — it is neither a win nor a loss.
            float rOut = hitS ? -1.0 : hitT ? t.rr : (risk > 0 ? (close - t.entry) * t.dir / risk : 0.0)
            array.set(bN,  t.bucket, array.get(bN,  t.bucket) + 1)
            array.set(bR,  t.bucket, array.get(bR,  t.bucket) + rOut)
            array.set(bR2, t.bucket, array.get(bR2, t.bucket) + rOut * rOut)
            array.remove(pend, i)
        else
            i += 1

if barstate.isconfirmed and array.size(pendNX) > 0
    int i = 0
    while i < array.size(pendNX)
        Trade t = array.get(pendNX, i)
        bool hitX = t.dir == 1 ? high >= t.tgt : low  <= t.tgt
        bool hitS = t.dir == 1 ? low  <= t.stop : high >= t.stop
        bool expd = bar_index - t.bi >= calHor
        if bar_index > t.bi and (hitX or hitS or expd)
            array.set(nxN, t.bucket, array.get(nxN, t.bucket) + 1)
            array.set(nxH, t.bucket, array.get(nxH, t.bucket) + ((hitX and not hitS) ? 1 : 0))
            array.set(nxR, t.bucket, array.get(nxR, t.bucket) + t.rr)
            array.remove(pendNX, i)
        else
            i += 1

f_n(int ix)   => array.get(bN, ix)
f_exp(int ix) =>
    int n = array.get(bN, ix)
    n > 0 ? array.get(bR, ix) / float(n) : na
f_var(int ix) =>
    int n = array.get(bN, ix)
    if n < 2
        na
    else
        float m = array.get(bR, ix) / n
        math.max(array.get(bR2, ix) / n - m * m, 0.0)

// ── A CONFLUENCE GROUP vs A CONTROL BLENDED TO MATCH ITS OWN DIRECTION MIX ──
// base 1 = low confluence · base 3 = high. Returns [mean, control, n, variance, t].
f_grp(int base) =>
    int iL = base
    int iS = base + 1
    int nL = f_n(iL)
    int nS = f_n(iS)
    int nE = nL + nS
    if nE < 2
        [float(na), float(na), nE, float(na), float(na)]
    else
        float sR  = array.get(bR, iL)  + array.get(bR, iS)
        float sR2 = array.get(bR2, iL) + array.get(bR2, iS)
        float mE  = sR / nE
        float vE  = math.max(sR2 / nE - mE * mE, 0.0)
        float seE = math.sqrt(vE / nE)
        // the control is rebuilt to the EVENTS' OWN long/short mix — not 50/50
        float wL  = nL / float(nE)
        float wS  = nS / float(nE)
        float mCL = f_exp(5)
        float mCS = f_exp(6)
        float mC  = (na(mCL) ? 0.0 : wL * mCL) + (na(mCS) ? 0.0 : wS * mCS)
        float vCL = f_var(5)
        float vCS = f_var(6)
        int   nCL = f_n(5)
        int   nCS = f_n(6)
        float seC = math.sqrt((nCL > 1 and not na(vCL) ? wL * wL * vCL / nCL : 0.0) + (nCS > 1 and not na(vCS) ? wS * wS * vCS / nCS : 0.0))
        float se  = math.sqrt(seE * seE + seC * seC)
        [mE, mC, nE, vE, se > 0 ? (mE - mC) / se : na]

f_nxRate(int g) =>
    int n = array.get(nxN, g)
    n > 0 ? array.get(nxH, g) / float(n) * 100.0 : na
f_nxDist(int g) =>
    int n = array.get(nxN, g)
    n > 0 ? array.get(nxR, g) / float(n) : na

[expHi, ctlHi, nHi, varHi, tHi] = f_grp(3)
[expLo, ctlLo, nLo, varLo, tLo] = f_grp(1)
bool provHi = not na(tHi) and nHi >= calMinN and tHi > 1.96

// ── DOES CONFLUENCE RANK? ──
// The one question the script is built to answer — and it is NOT answered by `expHi > expLo`.
// That is a bare comparison with no test in it, and it will happily call +0.01R vs +0.01R a YES.
// Live, it flipped its verdict across timeframes on differences of 0.02R: it was reporting sampling
// noise as a finding, which is the exact sin this codebase exists to avoid. A difference must CLEAR
// THE NOISE before it is allowed to be a verdict. Below that, the honest answer is the least
// satisfying one — no difference detected — and the panel says so.
float seAB  = (nHi > 1 and nLo > 1 and not na(varHi) and not na(varLo)) ? math.sqrt(varHi / nHi + varLo / nLo) : na
float tRank = (na(seAB) or seAB <= 0 or na(expHi) or na(expLo)) ? na : (expHi - expLo) / seAB
bool  warmR = nHi < calMinN or nLo < calMinN
int   rankV = (warmR or na(tRank)) ? 0 : tRank > 1.96 ? 1 : tRank < -1.96 ? -1 : 0
bool  ranks = rankV == 1
string rankTxt = not calibOn ? "off" : warmR ? "warming (" + str.tostring(math.min(nLo, nHi)) + "/" + str.tostring(calMinN) + ")" : rankV == 1 ? "YES — more voices IS better" : rankV == -1 ? "NO — more voices is WORSE here" : "NO DIFFERENCE — voices do not rank"
color  rankCol = (not calibOn or warmR) ? txtMut : rankV == 1 ? colSup : rankV == -1 ? colRes : colWarn

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        DRAWING
// ═════════════════════════════════════════════════════════════════════════════════════════
plotshape(showSig and firedNow and eDir == 1,  "Support rejection",    shape.triangleup,   location.belowbar, colSup, size = size.small)
plotshape(showSig and firedNow and eDir == -1, "Resistance rejection", shape.triangledown, location.abovebar, colRes, size = size.small)
plotchar(showSig and brkDn, "Support broke",    "×", location.belowbar, colRes, size = size.tiny)
plotchar(showSig and brkUp, "Resistance broke", "×", location.abovebar, colSup, size = size.tiny)

bool setupLive = showSetup and eOpen and not na(eEn)

var line  sE = na
var line  sS = na
var line  sT = na
var line  sX = na
var label lE = na
var label lS = na
var label lT = na

if barstate.islast
    // clear every level's drawing, then redraw ONLY the ones that matter
    if array.size(lvls) > 0
        for i = 0 to array.size(lvls) - 1
            Lvl L = array.get(lvls, i)
            box.delete(L.bx)
            label.delete(L.lb)
    if showLvl and array.size(lvls) > 0 and atr > 0
        for i = 0 to array.size(lvls) - 1
            Lvl L = array.get(lvls, i)
            int nv = f_nVoice(L)
            bool isSup = close > L.px
            // the SAME watched set the signal uses — so what is drawn and what can fire are, by
            // construction, the same four levels. (It also drops an O(n²) rescan.)
            if f_watched(L.px) and nv >= minVoice
                color c = isSup ? colSup : colRes
                // MORE VOICES = STRONGER PAINT. The chart shows you the conviction at a glance.
                int tr = math.max(60, zoneTr - (nv - minVoice) * 8)
                L.bx := box.new(math.max(L.bi, bar_index - 400), L.top, bar_index + extendN, L.bot, xloc = xloc.bar_index, bgcolor = color.new(c, tr), border_color = color.new(c, 25), border_width = 1)
                string rec = L.touches > 0 ? str.tostring(L.holds) + "/" + str.tostring(L.touches) : "untested"
                // FLIPPED is computed, never latched: is its role TODAY the opposite of its role at
                // birth? A broken support IS resistance, and that is often the most useful thing it
                // ever does — but a permanent "flipped" flag ends up on every level and means nothing.
                string flp = (isSup != L.bornSup) ? " ⇄" : ""
                // COUNT THE GLYPHS. "◆~▣▪" IS four voices — printing "4v" next to it says the same
                // thing twice and makes the label long enough to run under the dashboard.
                L.lb := label.new(bar_index + extendN, L.px, f_voiceTxt(L) + "  " + rec + flp + "   " + str.tostring(L.px, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 12), textcolor = color.white, size = f_lblSize())

    line.delete(sE)
    line.delete(sS)
    line.delete(sT)
    line.delete(sX)
    label.delete(lE)
    label.delete(lS)
    label.delete(lT)
    if setupLive
        color cD = eDir == 1 ? colSup : colRes
        sE := line.new(eBar, eEn, bar_index + 3, eEn, xloc = xloc.bar_index, color = color.new(color.gray, 0), width = lineW)
        sS := line.new(eBar, eSt, bar_index + 3, eSt, xloc = xloc.bar_index, color = color.new(eDir == 1 ? colRes : colSup, 0), width = lineW)
        sT := line.new(eBar, eTg, bar_index + 3, eTg, xloc = xloc.bar_index, color = color.new(cD, 0), width = lineW)
        lE := label.new(bar_index + 3, eEn, "▶ ENTRY " + str.tostring(eEn, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.gray, 10), textcolor = color.white, size = f_lblSize())
        lS := label.new(bar_index + 3, eSt, "▶ STOP " + str.tostring(eSt, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(eDir == 1 ? colRes : colSup, 10), textcolor = color.white, size = f_lblSize())
        int nb = eVox >= splitAt ? 2 : 1
        string nxTxt = (not showNext or na(eNX)) ? "" : "   ·   next level " + str.tostring(eNX, format.mintick) + " (" + str.tostring(eNXR, "#.#") + "R" + (na(f_nxRate(nb)) ? "" : ", reached " + str.tostring(f_nxRate(nb), "#") + "%") + ")"
        lT := label.new(bar_index + 3, eTg, "TARGET " + str.tostring(tgtR, "#.#") + "R  " + str.tostring(eTg, format.mintick) + nxTxt, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(cD, 10), textcolor = color.white, size = f_lblSize())
        // THE NEXT LEVEL IS ALREADY ON THE CHART — it is one of the drawn levels, with its own label
        // and its own hold record. Printing a second "NEXT LEVEL" chip at the same price simply
        // stacked two labels on top of each other and made both unreadable. Draw the dashed line so
        // you can SEE where the trade is going; the level it lands on is already introducing itself.
        if showNext and not na(eNX)
            sX := line.new(eBar, eNX, bar_index + 3, eNX, xloc = xloc.bar_index, color = color.new(cD, 55), width = 1, style = line.style_dashed)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════════════════
bool isPro = panelMode == "Pro"
var table tb = table.new(f_pos(panelPos), 3, 12, frame_width = 1, border_width = 1)
f_row(int r, string k, string v, color c, color bg) =>
    table.cell(tb, 0, r, k, text_color = txtSub,  bgcolor = bg, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, r, v, text_color = c,       bgcolor = bg, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 2, r, "", bgcolor = bg)

if showPanel and barstate.islast
    table.set_bgcolor(tb, panelBg)
    table.set_frame_color(tb, frameC)
    table.set_border_color(tb, frameC)
    color hdrC = setupLive ? (eDir == 1 ? colSup : colRes) : color.new(color.gray, 20)
    color hdrT = f_lum(hdrC) > 140 ? color.rgb(10, 10, 10) : color.white
    table.cell(tb, 0, 0, "S/R LEVELS", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_left)
    table.cell(tb, 1, 0, str.tostring(minVoice) + "+ voices", text_color = hdrT, bgcolor = hdrC, text_size = size.small, text_halign = text.align_right)
    table.cell(tb, 2, 0, "", bgcolor = hdrC)

    string setTxt = setupLive ? (eDir == 1 ? "LONG " : "SHORT ") + str.tostring(eVox) + " voices  " + str.tostring(tgtR, "#.#") + "R" : na(eEn) ? "none" : eRes == 1 ? "last: target hit" : eRes == -1 ? "last: stopped" : "last: expired"
    color  setCol = setupLive ? (eDir == 1 ? colSup : colRes) : na(eEn) ? txtMut : eRes == 1 ? colSup : eRes == -1 ? colRes : txtMut
    f_row(1, "Live setup", setTxt, setCol, rowAlt)
    f_row(2, "Resistance", na(res1) ? "-" : str.tostring(res1, format.mintick) + "   " + str.tostring(res1v) + "v", colRes, panelBg)
    f_row(3, "Support",    na(sup1) ? "-" : str.tostring(sup1, format.mintick) + "   " + str.tostring(sup1v) + "v", colSup, rowAlt)

    if isPro
        // ══ THE TABLE THE SCRIPT EXISTS FOR ══
        f_row(4, "High confluence (" + str.tostring(splitAt) + "+)", nHi < calMinN ? "warming (" + str.tostring(nHi) + "/" + str.tostring(calMinN) + ")" : f_R(expHi) + " vs " + f_R(ctlHi) + "  n=" + str.tostring(nHi) + (provHi ? "  ✓" : ""), nHi < calMinN ? txtMut : provHi ? colSup : colRes, panelBg)
        f_row(5, "Low confluence", nLo < calMinN ? "warming (" + str.tostring(nLo) + "/" + str.tostring(calMinN) + ")" : f_R(expLo) + " vs " + f_R(ctlLo) + "  n=" + str.tostring(nLo), nLo < calMinN ? txtMut : txtMain, rowAlt)
        f_row(6, "Control (direction-matched)", na(f_exp(5)) ? "-" : "L " + f_R(f_exp(5)) + "  S " + f_R(f_exp(6)) + "  n=" + str.tostring(f_n(5) + f_n(6)), txtMain, panelBg)
        f_row(7, "DOES CONFLUENCE RANK?", rankTxt, rankCol, rowAlt)
        f_row(8, "  high vs low (t)", na(tRank) ? "-" : str.tostring(tRank, "#.2") + "   (needs |t| > 1.96)", rankCol, panelBg)
        f_row(9, "  high vs control (t)", na(tHi) ? "-" : str.tostring(tHi, "#.2") + (provHi ? "  > 1.96 PROVEN" : "  (needs > 1.96)"), provHi ? colSup : txtMut, rowAlt)
        f_row(10, "Next level reached?", na(f_nxRate(2)) ? "-" : str.tostring(f_nxRate(2), "#") + "%  ·  it sits " + str.tostring(f_nxDist(2), "#.#") + "R away", txtMain, panelBg)
        f_row(11, "Note", "entry = close · in-sample · not advice", txtMut, rowAlt)
    else
        f_row(4, "Does confluence rank?", rankTxt, rankCol, panelBg)
        f_row(5, "Note", "Pro panel for the full test", txtMut, rowAlt)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                        THE KEY
// ═════════════════════════════════════════════════════════════════════════════════════════
var table lg = table.new(f_pos(legendPos), 2, 10, frame_width = 1, border_width = 1)
f_lg(int r, string sym, color c, string txt) =>
    color bg = r % 2 == 0 ? panelBg : rowAlt
    table.cell(lg, 0, r, sym, text_color = c,      bgcolor = bg, text_size = size.tiny, text_halign = text.align_center)
    table.cell(lg, 1, r, txt, text_color = txtSub, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
if showLegend and barstate.islast
    table.set_bgcolor(lg, panelBg)
    table.set_frame_color(lg, frameC)
    table.set_border_color(lg, frameC)
    table.cell(lg, 0, 0, "KEY", text_color = txtMain, bgcolor = frameC, text_size = size.tiny)
    table.cell(lg, 1, 0, "why this level exists", text_color = txtMain, bgcolor = frameC, text_size = size.tiny, text_halign = text.align_left)
    f_lg(1, "◆",  txtMain, "Swing pivot — where price actually turned")
    f_lg(2, "~",  txtMain, "Kernel extremum — the turning point of the SMOOTHED price")
    f_lg(3, "⇈",  txtMain, "Higher-timeframe swing — what a bigger participant is watching")
    f_lg(4, "▣",  txtMain, "Prior period high / low — yesterday, and last week")
    f_lg(5, "▪",  txtMain, "Volume node — real business was transacted here")
    f_lg(6, "○",  txtMain, "Round number — the psychological grid")
    f_lg(7, "4v", colSup,  "How many INDEPENDENT voices agree. That is the whole idea")
    f_lg(8, "3/4", colSup, "The hold record: tested 4 times, held 3")
    f_lg(9, "⇄",  colWarn, "Flipped — a broken support is now resistance")

// ═════════════════════════════════════════════════════════════════════════════════════════
//                  EXPORTS  (Data Window — consume elsewhere via input.source())
// ═════════════════════════════════════════════════════════════════════════════════════════
color exC = color.new(color.gray, 100)
plot(sup1,  "EXP_Sup1",       exC, display = display.data_window)
plot(sup2,  "EXP_Sup2",       exC, display = display.data_window)
plot(res1,  "EXP_Res1",       exC, display = display.data_window)
plot(res2,  "EXP_Res2",       exC, display = display.data_window)
plot(sup1v, "EXP_SupVoices",  exC, display = display.data_window)
plot(res1v, "EXP_ResVoices",  exC, display = display.data_window)
plot(firedNow ? eDir : 0, "EXP_Signal", exC, display = display.data_window)
plot(eEn,   "EXP_Entry",      exC, display = display.data_window)
plot(eSt,   "EXP_Stop",       exC, display = display.data_window)
plot(eTg,   "EXP_Target",     exC, display = display.data_window)
plot(na(expHi) or na(expLo) ? na : expHi - expLo, "EXP_ConfluenceEdge", exC, display = display.data_window)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════
alertcondition(firedNow and eDir == 1,  "Support held",    "S/R Levels: price tested a confluence support and closed back above it (context, not advice)")
alertcondition(firedNow and eDir == -1, "Resistance held", "S/R Levels: price tested a confluence resistance and closed back below it (context, not advice)")
alertcondition(firedNow, "Any rejection", "S/R Levels: a confluence level was tested and held (context, not advice)")
alertcondition(brkDn, "Support broke",    "S/R Levels: a confluence support gave way — it is now resistance (context, not advice)")
alertcondition(brkUp, "Resistance broke", "S/R Levels: a confluence resistance gave way — it is now support (context, not advice)")
````
