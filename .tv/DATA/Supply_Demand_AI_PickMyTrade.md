<!-- tradingview-pine-id: PUB;05b11b8e494e4da1a97aa3741f46c389 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Supply Demand AI [PickMyTrade]

Source: https://www.tradingview.com/script/mN8VuA7d-Supply-Demand-AI-PickMyTrade/

## Description

Supply Demand AI [PickMyTrade] asks the question every supply/demand tool skips: when price returns to a zone, does this arrival look like the ones that reversed — or like the ones that ate straight through?

Every supply/demand indicator draws the zone. None of them score the arrival. This one does. Each time price re-enters a zone, nine properties of the return are frozen before the outcome is known — approach speed, prior tap count, zone age, departure strength, base tightness, base volume, trend pressure, relative volume and zone width — and the arrival is voted on by a Lorentzian nearest-neighbour search over every similar return this chart has already resolved. The result is stated in the past tense: of the arrivals that looked like this, X% produced the configured reaction move before the zone failed.

The script also scores two doctrines stated everywhere in supply/demand teaching and measured almost nowhere: whether fresh zones genuinely outperform tapped ones on this chart, and whether heavy-volume bases genuinely outperform quiet ones. The info table reports what actually happened, not what the doctrine says should have.

――――――――――――――――――――――――――――――――――――――
https://www.tradingview.com/x/vDtnqCm1/

🔷 WHAT IT MEASURES

🔸 Zone formation — base-and-departure, not pivot clustering A zone is born from a run of compressed candles (the base) followed by an impulsive leg away of a configurable ATR multiple within a fixed window — the Rally-Base-Drop / Drop-Base-Rally shape, detected as a sequence rather than asserted from a single bar. A pivot cluster has no departure to measure; a base-and-departure zone has three properties frozen at birth that a pivot never carries: how hard the market left, how tight the base was, and which side was trading volume while it sat there.

🔸 Zone geometry The origin block (solid segment) marks the actual base candles. The projection (lighter band) carries those prices forward to where they can be tested. The departure measure (vertical bar on the departure candle) shows the full distance the move reached — readable straight off the price scale. Freshness is written as text ("fresh" / "2 taps"), not encoded in a line style that has to be decoded.

🔸 Outcome — reaction magnitude, not hold-or-break A return that drives the configured ATR multiple back away from the zone edge before closing decisively through it = REACTED. A return that closes beyond the far edge by the break buffer = FAILED. A return that does neither inside the timeout window = STALLED and discarded from training — price sitting inside a zone is not evidence either way.

🔸 Two doctrine read-outs The info table reports the freshness edge (did untouched zones react more often than tapped ones on this chart?) and the base-volume edge (did heavy-volume bases outperform quiet ones?). Either can come back negative, and the table says so when it does.

――――――――――――――――――――――――――――――――――――――

🔷 THE LORENTZIAN NEAREST-NEIGHBOUR CLASSIFIER

🔸 Why Lorentzian, not Naive Bayes A Naive Bayes model was the obvious alternative and is the wrong tool here: it assumes the features are conditionally independent given the class. Departure strength, base tightness and zone width all describe the same underlying impulse from three angles — multiplying their densities counts one piece of evidence three times. A nearest-neighbour vote makes no independence assumption at all. It asks a narrower, more honest question: of the returns already resolved on this chart, what happened to the ones that arrived most like this one?

🔸 Distance metric Distance is Lorentzian — log(1 + |a − b|) — applied per axis and summed. Against a library of this size, plain Euclidean distance lets one outlier axis dominate; the log compresses extremes, so a return that is typical on eight features and unusual on the ninth still finds its true neighbours.

🔸 Shared library — supply and demand in one pool Every feature is written relative to the direction of the test, so a fast approach into demand and a fast approach into supply are the same event described the same way. Sharing one library across both directions doubles the effective sample count without mixing unlike distributions.

🔸 Shrinkage The neighbour vote is shrunk toward the library's own base rate. Without it, k unanimous neighbours read as a certainty the sample size cannot support. The shrinkage weight is expressed in neighbour-equivalents so it is independent of k.

🔸 Honest caveat — stated here, not buried in a tooltip The classifier learns as history replays, so loading a different amount of chart history changes how many returns have trained it and therefore the percentage shown on a zone. The zones themselves, their boundaries and which bars they appear on are unaffected. This is inherent to on-chart learning.

――――――――――――――――――――――――――――――――――――――

🔷 SIGNALS AND DISPLAY

🔸 Zone appearance Full-strength blue (demand) or orange (supply) border at or above the conviction threshold. Muted at the opposite end. Neutral while price is inside — the zone is neither reacting nor failing yet. Grey once consumed. A zone born from twice the required departure draws with a heavier border — the one property worth reading before any text.

🔸 Zone label Nearest live demand, nearest live supply, and any zone with a return open right now receive a worded label: zone type · departure in ATR · evidence grade (A–D) · tap count · classifier read. Every other zone speaks through colour alone, which caps visible labels at roughly three regardless of timeframe or zoom.

🔸 Evidence grade (A–D) Measures accumulated evidence only — departure strength (35%), base tightness (25%), resolved return count (20%), age (20%). Deliberately excludes the classifier's probability so the grade and the percentage remain two different statements: the grade says how much stands behind the zone; the percentage says how similar arrivals resolved.

🔸 Return history ticks A coloured tick inside the zone at every bar where one of its own returns resolved — blue for a reaction, orange for a failure. Renders each zone's individual track record in place so the percentage can be read against the evidence behind it.

🔸 Order flow band A band above the trend EMA while cumulative volume delta is rising, below it while delta is falling. Opacity scales with how strong that pressure is against its own recent range — a faint band means the tape is undecided; a solid band means one side is leaning on it. Context, not a signal: it says which side is pressing when price arrives at a zone.

🔸 Info table Zones on chart · returns graded · overall reaction rate · freshness edge · base-volume edge · base-flow edge · live order flow direction and z-score · nearest demand and supply with ATR distance. Reads LEARNING until the warmup sample count is met.

🔸 Alerts Four alertcondition() calls: price entered a zone · return reacted · return failed · any resolved return. Worded as observations. Recommended alert setting: Once Per Bar Close.

――――――――――――――――――――――――――――――――――――――

🔷 INPUTS

🔸 Zone Detection Base Candle Max Range (ATR ×) — a candle counts as base while its range is below this multiple. Lower = cleaner zones, fewer of them. Default 0.60. Min / Max Base Candles — fewest and most candles that form a valid base. Default 1 / 6. Departure Strength (ATR ×) — how far price must travel from the base before the base qualifies as a zone. The single most important setting. Default 1.60. Departure Window (bars) — bars allowed for the departure to reach its target. Default 5. Zone Boundaries — Wick or Body extent for the base. Wick is the conservative read. Default Wick. Minimum Zone Height (ATR ×) — floor on zone thickness, expanded symmetrically about the base midpoint. Default 0.45. ATR Period — volatility yardstick for all distances. Default 14.

🔸 Return Resolution Reaction Target (ATR ×) — how far back away from the zone counts as a REACTION. Default 1.50. Break Buffer (ATR ×) — how far beyond the far edge price must CLOSE to count as a failure. Default 0.30. Return Timeout (bars) — bars a return stays open before being discarded as STALLED. Default 20. Zone Consumed On — Wick Touch / Body Touch / 50% Fill / Full Fill. Governs retirement only; returns always measure from the first wick. Default Body Touch. Max Returns Per Zone — a zone revisited this many times behaves like a range boundary. Default 4.

🔸 Probability Engine Warmup Samples — resolved returns required before the classifier replaces the running reaction rate. Default 25. Neighbours Compared — k in the nearest-neighbour vote. Smaller = more local; larger drifts toward the library rate. Default 8. Conviction Threshold — probability at or above which a zone draws at full conviction. Default 0.62. Approach Window — bars used to measure how fast price entered the zone. Default 5. Volume Baseline — averaging window for relative volume. Default 20. Trend EMA Period — reference for the trend-pressure feature. Default 50.

🔸 Order Flow Order Flow Band — show / hide. Default on. Flow Momentum Period — lookback for the rate of change of CVD. Default 14. Flow Band Width (ATR ×) — height of the band from the EMA to its outer edge. Default 1.00. Flow Normalisation Window — z-score window so the band reads the same across instruments. Default 50.

🔸 Visual Demand / Supply / In-zone / Consumed Colours · Show Zones · Zone Labels · Return History Ticks · Keep Consumed Zones · Max Live Zones (cap on live slots; consumed zones are free) · Zones Per Side (nearest N zones above and below price) · Show Zones Within ATR × (safety ceiling) · Label Every Zone · Label Size · Zone Border Width · Zone Evidence Grade.

🔸 Display Zen Mode — hides labels and info table; zones and ticks remain. Show Info Table.

――――――――――――――――――――――――――――――――――――――

🔷 REQUIREMENTS AND LIMITATIONS

🔸 The classifier reads what this chart has seen — not a pre-trained model and not a fixed statistical table. On a chart with thin history or a symbol the market has recently repriced, the library may be small and the read thin. The sample count travels with every zone label and the table header so this is never hidden. 🔸 Loading a different amount of chart history changes how many returns have trained the classifier, which changes the percentage shown on a zone. The zones themselves are unaffected — this is inherent to on-chart instance-based learning. 🔸 Zone geometry is fixed at birth and never re-centred. No request.security() call is made anywhere. Test state advances only on barstate.isconfirmed. No future data is referenced. 🔸 The departure is measured over bars that have already closed. A zone appears on the bar its departure qualifies and never moves afterwards. 🔸 Base volume and base flow are estimated from the close-position formula — a synthetic proxy, not true bid/ask data. The classifier adapts to the noise, but the quality of the read improves on instruments with genuine intrabar price travel. 🔸 The evidence grade (A–D) and the classifier percentage are two different statements by design. Do not read either alone. 🔸 Past resolved returns are hypothetical observations — no commission, no slippage — and are not a record of trading results. This script does not issue trade instructions and nothing in it is financial advice.

――――――――――――――――――――――――――――――――――――――

Built natively in Pine Script® v6. Lorentzian k-nearest-neighbour classifier trained on-chart from resolved supply/demand returns — no external libraries, no lookahead, no repainting. Zone formation uses a base-and-departure state machine; outcome is reaction magnitude, not hold-or-break. Attribution: the Rally-Base-Drop / Drop-Base-Rally construction is long-established public technical analysis, implemented independently here. The evidence grade and drawing layer are shared with the author's own Support Resistance AI [PickMyTrade] — stated here plainly rather than left for a reader to find.

Open source — Mozilla Public License 2.0.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// Supply Demand AI [PickMyTrade]
//
// THE QUESTION
// Every supply/demand tool draws the zone. None answer the question that matters
// when price comes back to it: does THIS return look like the ones that reversed,
// or like the ones that ate straight through?
//
// And every one of them repeats the same doctrine — trade fresh zones, a zone is
// spent after the first tap. That claim is stated everywhere and measured almost
// nowhere. Here the tap count is fed to the classifier as a feature and the
// dashboard reports what this chart actually did with it. If untouched zones
// reacted more often, the table says so. If they did not, the table says that
// instead. The script does not defend the doctrine; it scores it.
//
// THE METHOD
// A zone is born from a departure, never from a pivot. A run of compressed base
// candles, then an impulsive leg away from that base of at least a configurable
// ATR multiple within a fixed window — the classic Rally-Base-Drop / Drop-Base-
// Rally shape, detected as a sequence rather than asserted from a single bar.
//
// Each time price returns into a zone, nine properties of the ARRIVAL are frozen
// before the outcome is known: approach speed, prior taps, zone age, the strength
// of the departure that created it, how tight the base was, how much volume that
// base itself traded, trend pressure, relative volume on arrival, and zone width.
// Three of those — departure strength, base tightness and base volume — are
// properties of the zone's BIRTH, not of the test, and they are what a
// pivot-clustered level has no way to carry.
//
// The outcome is not hold-or-break. It is REACTION MAGNITUDE: did the return
// produce a measured move of i_react ATR away from the zone before price closed
// decisively through it? A return that does neither inside the window is recorded
// as STALLED and discarded from training — a zone price merely sat in is not
// evidence either way, and counting it would deflate the reaction rate.
//
// Those resolved outcomes accumulate into a library of past returns, and a new
// arrival is judged by Lorentzian nearest-neighbour vote against it — of the
// returns already resolved on this chart, what happened to the ones that arrived
// most like this one. No distribution is assumed and nothing is fitted; the
// comparison is between whole feature vectors.
//
// A Naive Bayes model was the obvious alternative and is the wrong tool here: it
// assumes the features are conditionally independent, and departure strength,
// base tightness and zone width plainly are not — they describe one impulse from
// three angles, and multiplying their densities counts that evidence three times.
//
// Supply and demand share one library: every feature is written relative to the
// direction of the test, so a fast approach into demand and a fast approach into
// supply are the same event described the same way.
//
// WHAT YOU SEE
// A zone is drawn in two parts, because a supply/demand zone is two things and a
// horizontal level is only one. The ORIGIN BLOCK is the solid segment on the left:
// the actual base candles the market left from. The PROJECTION is the lighter band
// running right from it — the same prices, carried forward to where they can be
// tested again. Standing on the departure candle is the DEPARTURE MEASURE, a heavy
// vertical bar running from the base edge to the extreme the move reached. Its
// height is the departure, read straight off the price scale, and it is the one
// mark on this chart that a clustered-pivot level could never draw, because a
// pivot has no departure to measure.
//
// Every border is a solid line. Freshness is written on the label — "fresh", or
// "2 taps" — rather than encoded in a line style that has to be decoded, and a
// consumed zone steps back to grey.
//
// ATTRIBUTION
// The Rally-Base-Drop / Drop-Base-Rally construction is long-established public
// technical analysis, implemented independently here. The base-and-departure
// state machine, the reaction-magnitude outcome definition, the per-return
// signature and the freshness read-out are the original contribution.
//
// No third-party code is reused. The evidence grade and the rank-based drawing
// layer are shared with this author's own Support Resistance AI [PickMyTrade] —
// stated here plainly rather than left for a reader to find. Nothing else is:
// that script fits a Naive Bayes model over pivot-clustered levels and asks
// whether a level held; this one votes over stored episodes with a Lorentzian
// metric, builds its zones from a measured base-and-departure, resolves them on
// reaction MAGNITUDE rather than hold-or-break, consumes them rather than
// flipping their role, and scores three properties of a zone's BIRTH that a
// pivot cluster has no way to carry.
//
// NON-REPAINTING
// Zone formation looks strictly backward from confirmed bars: the base is already
// complete when the departure is measured, and the departure is measured over
// bars that have already closed. There is no pivot-confirmation delay in this
// script because nothing here needs a right-hand lookback — a zone appears on the
// bar its departure qualifies and never moves afterwards. Zone geometry is fixed
// at birth and is never re-centred, so an older box sits exactly where it did
// when it first appeared.
//
// No request.security() call is made anywhere in this script. Test state advances
// only on barstate.isconfirmed. No future data is referenced at any point.
//
// The one honest caveat, stated here rather than left in a tooltip: the
// classifier learns as history replays, so loading a different amount of chart
// history changes how many returns have trained it and therefore the percentage
// shown on a zone. The zones themselves, their boundaries and which bars they
// appear on are unaffected. This is inherent to on-chart learning.
//
// Recommended alert setting: "Once Per Bar Close".

//@version=6
indicator("Supply Demand AI [PickMyTrade]", "SD AI[PMT]",
         overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// ── Input Groups ──────────────────────────────────────────────────────────────
var string G_ZONE = "Zone Detection"
var string G_TEST = "Return Resolution"
var string G_PROB = "Probability Engine"
var string G_FLOW = "Order Flow"
var string G_VIS  = "Visual"
var string G_ZEN  = "Display"

// Zone Detection
i_base_atr   = input.float(0.60, "Base Candle Max Range (ATR x)", group=G_ZONE, minval=0.1, maxval=2.0, step=0.05,
     tooltip="A candle counts as part of a base while its range stays under this multiple of ATR. Lower values demand a genuinely quiet consolidation and produce fewer, cleaner zones; higher values accept choppier bases and produce more.")
i_base_min   = input.int  (1,    "Min Base Candles",   group=G_ZONE, minval=1, maxval=10,
     tooltip="Fewest compressed candles that can form a base. One is the classic single-candle origin; raising this keeps only zones built on a visible pause.")
i_base_max   = input.int  (6,    "Max Base Candles",   group=G_ZONE, minval=1, maxval=30,
     tooltip="Most candles a base may run to. Past this the pause has become a range in its own right, and the level it eventually leaves behind is no longer a supply/demand origin.")
i_dep_atr    = input.float(1.60, "Departure Strength (ATR x)", group=G_ZONE, minval=0.3, maxval=8.0, step=0.1,
     tooltip="How far price must travel away from the base, in ATR, before the base is accepted as a zone. This is the single most important setting here — it is what separates an origin the market actually left in a hurry from any random quiet patch on the chart.")
i_dep_win    = input.int  (5,    "Departure Window (bars)", group=G_ZONE, minval=1, maxval=30,
     tooltip="Bars allowed for the departure to reach its ATR target. A base that has not been left decisively within this window is discarded rather than kept as a weak zone.")
i_zone_src   = input.string("Wick", "Zone Boundaries", group=G_ZONE, options=["Wick", "Body"],
     tooltip="Wick uses the base's full high-to-low extent — the conservative reading, and the one that catches returns that only tag the extreme. Body uses the base's open/close extent, which draws tighter zones that are touched less often.")
i_zone_minh  = input.float(0.45, "Minimum Zone Height (ATR x)", group=G_ZONE, minval=0.0, maxval=2.0, step=0.05,
     tooltip="Floor on how thin a drawn zone may be, as a multiple of ATR. A single quiet base candle can leave a band only a few ticks tall — real, but too thin to see and too thin to test, because price steps straight over it without ever registering a return. Where the base is thinner than this the band is expanded SYMMETRICALLY around its own midpoint, so the level it is centred on never moves. Set to 0 to draw the raw base extent and nothing else.")
i_atr_len    = input.int  (14,   "ATR Period",         group=G_ZONE, minval=5, maxval=50,
     tooltip="Volatility yardstick. Every width, distance and threshold in this script is expressed in ATR so it behaves the same across instruments and timeframes.")

// Return Resolution
i_react      = input.float(1.50, "Reaction Target (ATR x)", group=G_TEST, minval=0.3, maxval=8.0, step=0.1,
     tooltip="How far price must travel back away from the zone to count as a REACTION. This is the outcome the classifier is trained on — not merely that the zone held, but that holding it was worth something.")
i_break_buf  = input.float(0.30, "Break Buffer (ATR x)", group=G_TEST, minval=0.0, maxval=2.0, step=0.05,
     tooltip="How far beyond the zone's far edge price must CLOSE to count the return as a failure. The buffer stops one marginal close from writing off a zone.")
i_test_bars  = input.int  (20,   "Return Timeout (bars)", group=G_TEST, minval=3, maxval=200,
     tooltip="Bars a single return stays open. If neither the reaction target nor a decisive break happens in that time the return is recorded as STALLED and discarded from training — price sitting inside a zone is not evidence either way.")
i_mitig      = input.string("Body Touch", "Zone Consumed On", group=G_TEST, options=["Wick Touch", "Body Touch", "50% Fill", "Full Fill"],
     tooltip="When a zone is treated as spent and stops being drawn as live. Wick Touch retires it the moment any wick tags it; Full Fill keeps it until price has traded through the whole band. Body Touch is the middle reading most supply/demand desks use. This governs RETIREMENT only — a return is always measured from the first wick that enters, whatever this is set to.")
i_max_taps   = input.int  (4,    "Max Returns Per Zone", group=G_TEST, minval=1, maxval=20,
     tooltip="Returns a single zone may record before it is retired regardless of the consumption rule. A level being revisited this often is behaving like a range boundary rather than an origin.")

// Probability Engine
i_warmup     = input.int  (25,   "Warmup Samples",     group=G_PROB, minval=5, maxval=400,
     tooltip="Resolved returns required before the classifier is used. Below this the display shows the chart's running reaction rate instead, and the info table reads LEARNING.")
i_k          = input.int  (8,    "Neighbours Compared", group=G_PROB, minval=3, maxval=30,
     tooltip="How many of the most similar past returns are polled for each new arrival. Smaller is more local and more reactive; larger drifts toward the library's overall reaction rate. The library is rebuilt from whatever history the chart has loaded, so a chart with more bars can hold more episodes and read differently on the same bar.")
i_thresh     = input.float(0.62, "Conviction Threshold", group=G_PROB, minval=0.50, maxval=0.95, step=0.01,
     tooltip="Probability at or above which a zone is drawn at full conviction. The mirrored value below it marks the opposite case with equal strength.")
i_appr_len   = input.int  (5,    "Approach Window",    group=G_PROB, minval=2, maxval=30,
     tooltip="Bars used to measure how fast price travelled into the zone. A zone struck by an impulse has historically behaved differently from one drifted into.")
i_vol_len    = input.int  (20,   "Volume Baseline",    group=G_PROB, minval=5, maxval=200,
     tooltip="Averaging window for relative volume. On symbols without volume data this feature flattens and is neutralised in the maths rather than distorting it.")
i_ema_len    = input.int  (50,   "Trend EMA Period",   group=G_PROB, minval=5, maxval=500,
     tooltip="Reference for the trend-pressure feature: how far, and which way, price is stretched from its mean on arrival at the zone.")

// Order Flow
i_show_flow  = input.bool (true, "Order Flow Band", group=G_FLOW,
     tooltip="Draws a band above the trend EMA while cumulative volume delta is rising, and below it while delta is falling. Its opacity scales with how strong that pressure is against its own recent range. It is CONTEXT, not a signal: it says which side is currently pressing, which is what a trader wants to know at the moment price arrives at a zone.")
i_flow_len   = input.int  (14, "Flow Momentum Period", group=G_FLOW, minval=3, maxval=100,
     tooltip="Look-back for the rate of change of cumulative volume delta. Shorter reacts faster and flickers more.")
i_flow_w     = input.float(1.00, "Flow Band Width (ATR x)", group=G_FLOW, minval=0.05, maxval=3.0, step=0.05,
     tooltip="Height of the flow band as a multiple of ATR, measured from the trend EMA to the band's outer edge. 1.0 is a full ATR, which is the size that reads as a ribbon following price rather than as a line on top of it. Lower it toward 0.3 if you want flow to sit quietly behind the zones instead.")
i_flow_z     = input.int  (50, "Flow Normalisation Window", group=G_FLOW, minval=10, maxval=200,
     tooltip="Window used to z-score flow momentum so the band means the same thing across instruments and timeframes rather than tracking raw contract size.")

// Visual
dem_col      = input.color(color.new(#2962FF, 0), "Demand Colour", group=G_VIS)
sup_col      = input.color(color.new(#FF6D00, 0), "Supply Colour", group=G_VIS)
inzone_col   = input.color(color.new(#787B86, 0), "Price Inside Zone", group=G_VIS,
     tooltip="Neutral colour applied while price is trading inside a zone. At that moment the zone is neither reacting nor failing, and colouring it either way would overstate what is known.")
spent_col    = input.color(color.new(color.gray, 82), "Consumed Zone", group=G_VIS,
     tooltip="Colour a zone takes once it has been consumed under the chosen rule, or has failed. Kept on the chart because a spent origin is still where the move came from.")
show_zones   = input.bool (true,  "Show Zones",        group=G_VIS)
show_lbl     = input.bool (true,  "Zone Labels",       group=G_VIS,
     tooltip="Prints the live reaction probability, evidence grade and tap count on each zone. The figure re-reads as the classifier keeps learning, so an older zone reflects current statistics.")
show_hist    = input.bool (true,  "Return History Ticks", group=G_VIS,
     tooltip="Draws a coloured tick inside the zone at every bar where one of its own returns resolved — blue for a reaction, orange for a failure. It renders each zone's individual track record in place, so the percentage can be read against the evidence behind it.")
show_spent   = input.bool (true,  "Keep Consumed Zones", group=G_VIS,
     tooltip="Off hides a zone the moment it is consumed. On keeps it drawn in grey — useful for reading how the chart has treated its origins, and it costs no live-zone slot either way.")
i_max_zones  = input.int  (14,    "Max Live Zones",   group=G_VIS, minval=3, maxval=40,
     tooltip="Cap on LIVE zones. Consumed zones do not consume slots. When the cap is reached the weakest zone is dropped — the one with the softest departure and fewest resolved returns — rather than simply the oldest.")
i_show_n     = input.int  (5,     "Zones Per Side",   group=G_VIS, minval=1, maxval=12,
     tooltip="How many of the NEAREST zones to draw above price, and below price. Rank-based rather than a fixed distance, so the chart is populated the same way on a 5-minute chart as on a daily one — a fixed ATR radius that fills one timeframe leaves another empty.")
i_show_dist  = input.float(30.0,  "Show Zones Within (ATR x)", group=G_VIS, minval=2.0, maxval=100.0, step=0.5,
     tooltip="Safety ceiling on top of Zones Per Side: a zone farther than this from current price is never drawn, however few zones are nearby. Stops one extreme old origin from stretching the chart's y-axis.")
show_all_lbl = input.bool (false, "Label Every Zone", group=G_VIS,
     tooltip="Off (default): worded labels render only on the nearest live demand, the nearest live supply, and any zone with a return open right now — the zones a trader is actually asking about. Every other zone speaks through its colour alone, which is what stops labels stacking into an unreadable pile.")
i_lbl_size   = input.string("Small", "Label Size", group=G_VIS, options=["Tiny", "Small", "Normal", "Large", "Huge"],
     tooltip="Text size of the worded zone labels.")
i_border_w   = input.int  (1, "Zone Border Width", group=G_VIS, minval=1, maxval=4,
     tooltip="Base border width for every zone. Zones born from a departure of twice the required strength always draw one step heavier than this. History ticks scale with it too.")
i_show_grade = input.bool (true, "Zone Evidence Grade (A–D)", group=G_VIS,
     tooltip="Stamps an A–D grade in each zone's corner and on its worded label. The grade measures accumulated EVIDENCE — departure strength, base tightness, resolved returns and age — never the classifier's probability, so the grade and the percentage remain two different statements: the grade is how much stands behind the zone, the percentage is how similar arrivals resolved.")

// Display
zen_mode     = input.bool (false, "Zen Mode",         group=G_ZEN,
     tooltip="Hides zone labels and the info table. Zones and history ticks remain — for clean screenshots and live use.")
show_table   = input.bool (true,  "Show Info Table",  group=G_ZEN)

// ── SIZE MAPPING ──────────────────────────────────────────────────────────────
string lblSize = i_lbl_size == "Tiny" ? size.tiny : i_lbl_size == "Normal" ? size.normal : i_lbl_size == "Large" ? size.large : i_lbl_size == "Huge" ? size.huge : size.small

// ── ZONE TYPE ─────────────────────────────────────────────────────────────────
// A zone carries the frozen signature of its most recent return, so its
// probability can be re-read live as the classifier keeps learning, plus the
// birth properties a pivot-clustered level has no way to hold: how hard the
// market left this base, and how tight the base was when it left.
type SDZone
    float top        = na
    float bot        = na
    int   born       = 0
    int   born_time  = 0   // unix ms — the box's left edge uses this, never the bar
                            // index. Pine rejects bar-index box coordinates once they
                            // sit too many bars behind the current bar (RE10026);
                            // time coordinates have no such limit. born is kept
                            // separately for the age feature, which is genuinely
                            // bar-count math rather than display.
    bool  is_supply  = false
    float dep_str    = 0.0 // departure strength in ATR, frozen at birth
    float base_tight = 0.0 // base range in ATR at birth — lower is tighter
    float base_flow  = 0.0 // signed order-flow polarity of the base, -1 to +1.
                            // +1 means every unit of volume in the base was
                            // buying pressure. This is the axis that separates
                            // an accumulation base from a base that was merely
                            // quiet, and it is frozen at birth with the rest.
    float base_vol   = 1.0 // average per-bar volume during the base, relative to
                            // the chart's own baseline. Frozen at birth like the
                            // two above. This is the term the volume-profile
                            // tools gesture at and never score: whether the base
                            // was built on real participation or on nobody
                            // trading. Defaults to neutral 1.0 on feeds without
                            // volume rather than distorting the comparison.
    int   origin_end = 0   // unix ms of the first bar AFTER the base. The origin
                            // block spans born_time → here, so it covers exactly
                            // the base candles and nothing else. Time-based for
                            // the same RE10026 reason born_time is.
    int   dep_time   = 0   // unix ms of the bar the departure qualified on
    float dep_price  = na  // the extreme the departure reached — the far end of
                            // the arrow. Frozen at birth like dep_str.
    int   taps       = 0
    int   reacts     = 0
    int   tests      = 0
    bool  spent      = false
    int   end_time   = 0   // unix ms at which the zone stopped being live. The
                            // box's right edge freezes here, so a consumed origin
                            // stays drawn across the span it was actually live
                            // for — including one consumed by a sweep that never
                            // opened a return, where the last-test time is unset.
    bool  testing    = false
    int   t_bar      = 0
    float t_atr      = na  // ATR frozen at arrival — the reaction target and break
                            // buffer must not drift as volatility changes mid-test
    float t_f0       = na
    float t_f1       = na
    float t_f2       = na
    float t_f3       = na
    float t_f4       = na
    float t_f5       = na
    float t_f6       = na
    float t_f7       = na
    float t_f8       = na
    float t_f9       = na
    float prob       = na
    box   bx         = na
    box   obx        = na  // origin block — the base candles themselves
    line  dep_ln     = na  // departure leg
    label lbl        = na
    array<line> ticks = na

// ── LORENTZIAN NEAREST-NEIGHBOUR CLASSIFIER ──────────────────────────────────
// Not a Naive Bayes model, and the reason is specific to this script rather than
// a preference. Naive Bayes assumes every feature is conditionally independent
// given the class. Here they demonstrably are not: departure strength, base
// tightness and zone width all describe the same underlying impulse and move
// together. Multiplying their densities as if they were independent counts one
// piece of evidence three times.
//
// A nearest-neighbour vote makes no independence assumption at all. It asks a
// narrower and more honest question — of the returns already resolved on this
// chart, what happened to the ones that ARRIVED most like this one — and answers
// it by comparing whole feature vectors rather than by modelling each axis.
//
// Distance is Lorentzian, log(1 + |a - b|), applied per axis and summed. Against
// a library this size a plain Euclidean distance lets one unusual axis dominate
// the whole comparison; the log compresses outliers, so a return that is typical
// on eight axes and strange on the ninth still finds its true neighbours.
//
// Supply and demand share one library. Every feature is written relative to the
// direction of the test, so a fast approach into demand and a fast approach into
// supply are the same event described the same way, and sharing doubles the
// effective sample count without mixing unlike distributions.
int   K_LIB_CAP = 100
float K_SHRINK  = 4.0

type SDEp
    float z0  = 0.0
    float z1  = 0.0
    float z2  = 0.0
    float z3  = 0.0
    float z4  = 0.0
    float z5  = 0.0
    float z6  = 0.0
    float z7  = 0.0
    float z8  = 0.0
    float z9  = 0.0
    int   lbl = 0

// Pine forbids a function from reassigning a global, so the count and label sum
// are derived from the array rather than carried in running counters. Mutating
// the array's CONTENTS from a function is allowed — it is the `:=` on a global
// that is not — so the push below is fine and only the bookkeeping had to move.
// The scan is O(library) but runs once per neighbour search, not once per
// neighbour, so it is lost in the noise of the search itself.
var array<SDEp> g_lib = array.new<SDEp>()

f_lorentz(float a, float b) =>
    math.log(1.0 + math.abs(a - b))

f_baseRate() =>
    int   n   = array.size(g_lib)
    float sum = 0.0
    if n > 0
        for i = 0 to n - 1
            sum += float(array.get(g_lib, i).lbl)
    n > 0 ? sum / float(n) : 0.5

model_ready() =>
    array.size(g_lib) >= i_warmup

// lbl is 1 for a REACTED return and 0 for a FAILED one, so the running mean of
// the labels is the reaction rate directly.
f_libPush(int lbl, float a0, float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8, float a9) =>
    SDEp e = SDEp.new()
    e.z0  := a0
    e.z1  := a1
    e.z2  := a2
    e.z3  := a3
    e.z4  := a4
    e.z5  := a5
    e.z6  := a6
    e.z7  := a7
    e.z8  := a8
    e.z9  := a9
    e.lbl := lbl
    array.push(g_lib, e)
    // The library is a rolling window of what this chart has recently done, not
    // an archive. Evicting the oldest keeps the read current on an instrument
    // whose character has changed, and bounds the search cost.
    while array.size(g_lib) > K_LIB_CAP
        array.shift(g_lib)
    true

// Returns na until the library holds at least i_k episodes: a vote taken over
// fewer neighbours than were asked for is not the measurement this claims to be.
f_knn(float q0, float q1, float q2, float q3, float q4, float q5, float q6, float q7, float q8, float q9) =>
    int   n   = array.size(g_lib)
    float res = na
    if n >= i_k
        array<float> d = array.new_float(n, 0.0)
        for i = 0 to n - 1
            SDEp e = array.get(g_lib, i)
            array.set(d, i,
                 f_lorentz(q0, e.z0) + f_lorentz(q1, e.z1) + f_lorentz(q2, e.z2) +
                 f_lorentz(q3, e.z3) + f_lorentz(q4, e.z4) + f_lorentz(q5, e.z5) +
                 f_lorentz(q6, e.z6) + f_lorentz(q7, e.z7) + f_lorentz(q8, e.z8) +
                 f_lorentz(q9, e.z9))
        float vs = 0.0
        float ws = 0.0
        // Repeated minimum-find with masking rather than a sort: Pine cannot sort
        // one array by another, and k passes over n is cheap at this size. The
        // masked slot is set beyond any real distance rather than removed, so the
        // index stays aligned with the library.
        for kk = 0 to math.min(i_k, n) - 1
            int   mi = -1
            float mv = 1e20
            for i = 0 to n - 1
                float dv = array.get(d, i)
                if dv < mv
                    mv := dv
                    mi := i
            if mi >= 0
                float w = 1.0 / (1.0 + mv)
                vs += w * float(array.get(g_lib, mi).lbl)
                ws += w
                array.set(d, mi, 1e20)
        // Shrinkage toward the library's own base rate. Without it k unanimous
        // neighbours read as a certainty the sample size cannot support;
        // K_SHRINK is the weight of that prior in neighbour-equivalents.
        res := (vs + K_SHRINK * f_baseRate()) / (ws + K_SHRINK)
    res

// Always a usable number for display — the neighbour vote where the library can
// support one, the running reaction rate where it cannot.
f_prob(float q0, float q1, float q2, float q3, float q4, float q5, float q6, float q7, float q8, float q9) =>
    float r = f_knn(q0, q1, q2, q3, q4, q5, q6, q7, q8, q9)
    na(r) ? f_baseRate() : r

// ── THE TWO DOCTRINE READ-OUTS ───────────────────────────────────────────────
// Two claims are repeated everywhere in supply/demand teaching and measured
// almost nowhere: that a zone is spent after its first tap, and that a zone born
// on heavy volume is worth more than one born quiet. Both enter the classifier as
// ordinary features — z1 and z8 — and both are read back out here by comparing
// what the REACTED episodes carried against what the FAILED ones carried.
//
// One scan serves both. A positive freshness edge means reacting returns arrived
// with fewer prior taps than failing ones, so the doctrine held on this chart. A
// positive volume edge means reacting returns came from bases that traded heavier
// volume. Either can come back negative, and the table says so when it does.
f_edges() =>
    float rn = 0.0
    float fn = 0.0
    float rTap = 0.0
    float fTap = 0.0
    float rVol = 0.0
    float fVol = 0.0
    float rFlw = 0.0
    float fFlw = 0.0
    if array.size(g_lib) > 0
        for i = 0 to array.size(g_lib) - 1
            SDEp e = array.get(g_lib, i)
            if e.lbl == 1
                rn   += 1.0
                rTap += e.z1
                rVol += e.z8
                rFlw += e.z9
            else
                fn   += 1.0
                fTap += e.z1
                fVol += e.z8
                fFlw += e.z9
    bool ok = rn > 0.0 and fn > 0.0
    // Scaled back out of feature space into the units the labels already use, so
    // a number in the table means the same thing as a number on a zone.
    float tapEdge = ok ? ((fTap / fn) - (rTap / rn)) * float(i_max_taps) : na
    float volEdge = ok ? ((rVol / rn) - (fVol / fn)) * 3.0 : na
    // z9 is already oriented so 1.0 means "the base flowed the way this zone
    // needed". A positive edge therefore means flow-aligned bases reacted more,
    // which is the accumulation thesis holding. Left on its native 0-1 scale.
    float flowEdge = ok ? ((rFlw / rn) - (fFlw / fn)) : na
    [tapEdge, volEdge, flowEdge]

// ── ZONE COLOURS ──────────────────────────────────────────────────────────────
// Fill stays translucent so candles read through the zone; the border stays crisp
// so the origin itself is never ambiguous. While price is INSIDE a zone it is
// neither reacting nor failing yet, so it renders neutral rather than implying an
// outcome it has not earned.
sd_base(bool is_supply) =>
    is_supply ? sup_col : dem_col

sd_fill(bool is_supply, bool spent, bool inside, float p) =>
    spent ? spent_col : inside ? color.new(inzone_col, 86) : p >= i_thresh ? color.new(sd_base(is_supply), 80) : p <= 1.0 - i_thresh ? color.new(sd_base(is_supply), 90) : color.new(sd_base(is_supply), 86)

sd_border(bool is_supply, bool spent, bool inside, float p) =>
    spent ? color.new(color.gray, 62) : inside ? color.new(inzone_col, 25) : p >= i_thresh ? color.new(sd_base(is_supply), 0) : p <= 1.0 - i_thresh ? color.new(sd_base(is_supply), 55) : color.new(sd_base(is_supply), 30)

// ── EVIDENCE GRADE ────────────────────────────────────────────────────────────
// Measures accumulated evidence only — how hard the market left this base, how
// tight the base was, how many returns have resolved, and age. The classifier's
// probability is deliberately NOT an input: the grade and the percentage must
// remain two different statements. Departure strength and base tightness are
// weighted highest because they are the only two terms fixed at birth; a zone
// earns its grade the moment it forms and then refines it with evidence.
// Full age credit accrues at ~300 bars (log(1+300) ~= 5.71); log damping means
// the difference between 50 and 150 bars matters far more than 500 versus 1000.
f_gradeScore(float dep, float tight, int tests, int born) =>
    float gDep = math.min(dep / (i_dep_atr * 2.0), 1.0)
    float gTgt = math.max(0.0, 1.0 - math.min(tight / math.max(i_base_atr * 2.0, 0.1), 1.0))
    float gTst = math.min(tests / 3.0, 1.0)
    float gAge = math.min(math.log(1.0 + math.max(bar_index - born, 0)) / 5.71, 1.0)
    100.0 * (0.35 * gDep + 0.25 * gTgt + 0.20 * gTst + 0.20 * gAge)

f_gradeTag(float s) =>
    s >= 75 ? "A" : s >= 55 ? "B" : s >= 35 ? "C" : "D"

// ── BASE MEASURES ─────────────────────────────────────────────────────────────
float atr       = ta.atr(i_atr_len)
float ema_line  = ta.ema(close, i_ema_len)
float vol_avg   = ta.sma(volume, i_vol_len)
bool  confirmed = barstate.isconfirmed
// Milliseconds per bar on this chart's timeframe — used only to nudge a box's
// time-based right edge a few bars into the future. An approximation is fine
// here (session gaps aren't accounted for); it only needs to land visually near
// "now", never to be exact.
var int bar_ms  = timeframe.in_seconds(timeframe.period) * 1000

// ── CUMULATIVE VOLUME DELTA ──────────────────────────────────────────────────
// Buying and selling pressure estimated from where each bar closed inside its
// own range — the standard proxy where true bid/ask volume is not available on
// the feed. It is an approximation and is treated as one: it enters as ONE axis
// of ten, never as a signal in its own right.
//
// What it is actually for here is the question no supply/demand tool asks. A
// base is either accumulation or a pause, and the difference is whether the
// market was BUYING while it sat there. Total volume cannot tell those apart;
// signed delta can. That reading is frozen at birth alongside the zone's other
// birth properties and reported back by f_edges().
float hl_rng    = high - low + syminfo.mintick
float bull_vol  = nz(volume) * (close - low)  / hl_rng
float bear_vol  = nz(volume) * (high - close) / hl_rng
float delta_bar = bull_vol - bear_vol
var float cvd   = 0.0
cvd := cvd + delta_bar

// Flow momentum, z-scored so the band reads the same on any instrument.
float cvd_roc  = (cvd - cvd[i_flow_len]) / (math.abs(cvd[i_flow_len]) + syminfo.mintick)
float roc_mean = ta.sma  (cvd_roc, i_flow_z)
float roc_std  = ta.stdev(cvd_roc, i_flow_z)
float flow_z   = roc_std > 0 ? (cvd_roc - roc_mean) / roc_std : 0.0

// ── ZONE STORE ────────────────────────────────────────────────────────────────
var array<SDZone> zones = array.new<SDZone>()

// Drops the weakest LIVE zone when the cap is reached. Weakest is the softest
// departure with the fewest resolved returns — not simply the oldest. An old
// origin the market has respected twice is worth more chart space than a fresh
// one that barely qualified, and dropping by age alone would delete the first
// and keep the second.
f_drop(int idx) =>
    SDZone z = array.get(zones, idx)
    if not na(z.bx)
        box.delete(z.bx)
    if not na(z.obx)
        box.delete(z.obx)
    if not na(z.dep_ln)
        line.delete(z.dep_ln)
    if not na(z.lbl)
        label.delete(z.lbl)
    if not na(z.ticks) and array.size(z.ticks) > 0
        for k = 0 to array.size(z.ticks) - 1
            line.delete(array.get(z.ticks, k))
    array.remove(zones, idx)
    true

f_trimLive() =>
    int live   = 0
    int spentN = 0
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            if array.get(zones, i).spent
                spentN := spentN + 1
            else
                live := live + 1
    if live > i_max_zones
        int   worst  = -1
        float wscore = 1e20
        for i = 0 to array.size(zones) - 1
            SDZone z = array.get(zones, i)
            if not z.spent and not z.testing
                float s = z.dep_str + float(z.tests) * 0.75
                if s < wscore
                    wscore := s
                    worst  := i
        if worst >= 0
            f_drop(worst)
    // Consumed zones are history, and history has to be bounded too. Without
    // this the array grows for the life of the chart — every origin the market
    // ever traded through stays in it — and the ranking pass in the draw block
    // is O(n^2) over that array. One consumed zone is released per new zone
    // created, which keeps the two in balance.
    if spentN > i_max_zones
        int oldest = -1
        int obar   = 2147483647
        for i = 0 to array.size(zones) - 1
            SDZone z = array.get(zones, i)
            if z.spent and z.born < obar
                obar   := z.born
                oldest := i
        if oldest >= 0
            f_drop(oldest)
    // Explicit terminal value. The branches above end on a void array call and
    // on nothing at all; as a function's implicit return that mix is rejected
    // (CE10235). Ending on a plain literal makes the return type unambiguous —
    // callers ignore it.
    true

// ── BASE + DEPARTURE STATE MACHINE ────────────────────────────────────────────
// Stage 1  a run of compressed candles accumulates into a base.
// Stage 2  the first candle that breaks the compression ends the base and opens
//          a departure window.
// Stage 3  within that window price must travel i_dep_atr ATR away from the base
//          edge. The direction it travels decides supply or demand.
//
// The window is abandoned — not downgraded — if price returns inside the base
// before the target is met. A base the market left and immediately came back
// into was never departed from; keeping it as a weak zone is what fills a chart
// with origins nothing ever originated at.
//
// Everything here reads bars that have already closed. There is no right-hand
// confirmation lookback anywhere in this script, which is why a zone appears on
// the bar its departure qualifies rather than N bars later.
var float base_hi   = na
var float base_lo   = na
var int   base_n    = 0
var float base_vol  = 0.0    // volume accumulated across the base's candles
var float base_dlt  = 0.0    // SIGNED delta accumulated across the same candles
var int   base_left = 0      // bar_index of the base's first candle
var int   base_time = 0      // unix ms of the base's first candle

var bool  pend      = false  // a departure window is open
var float pend_hi   = na     // frozen base geometry for that window
var float pend_lo   = na
var int   pend_born = 0
var int   pend_time = 0
var float pend_tght = na
var float pend_bvol = 1.0
var float pend_bflw = 0.0
var int   pend_bar  = 0      // bar the window opened on
var int   pend_endt = 0      // unix ms of that bar — the first bar AFTER the base,
                              // so the origin block's right edge lands exactly on
                              // the end of the base rather than on the departure
var bool  pend_left = false  // has any bar CLOSED outside the base since it opened

f_baseEdge(bool wick, bool useHi) =>
    useHi ? (wick ? high : math.max(open, close)) : (wick ? low : math.min(open, close))

if confirmed and not na(atr) and atr > 0
    bool  isWick   = i_zone_src == "Wick"
    float cHi      = f_baseEdge(isWick, true)
    float cLo      = f_baseEdge(isWick, false)
    // Compression is judged on the candle's true extent regardless of which
    // source draws the zone. A body-only compression test would accept a bar
    // with a quiet body and violent wicks, which is the opposite of a base.
    bool  compress = (high - low) <= i_base_atr * atr

    // ── Stage 1 / 2 — accumulate the base, then open a window ──────────────
    // Opening runs BEFORE the departure is measured so that the very bar which
    // broke the compression counts toward its own departure. That bar is
    // usually the displacement itself; skipping it would mean every zone needed
    // a second impulse bar to qualify.
    if compress
        if base_n == 0
            base_hi   := cHi
            base_lo   := cLo
            base_left := bar_index
            base_time := time
            base_vol  := nz(volume)
            base_dlt  := delta_bar
        else
            base_hi  := math.max(base_hi, cHi)
            base_lo  := math.min(base_lo, cLo)
            base_vol += nz(volume)
            base_dlt += delta_bar
        base_n := base_n + 1
        // A base that has outgrown the cap is a range, not an origin. Reset
        // rather than truncate — truncating would leave the zone anchored to an
        // arbitrary slice of a consolidation.
        if base_n > i_base_max
            base_n := 0
    else
        // One departure in flight at a time: an open window blocks a new one.
        // Two overlapping candidates would both be built from bases the market
        // had not finished leaving.
        if base_n >= i_base_min and base_n <= i_base_max and not na(base_hi) and not na(base_lo) and base_hi > base_lo and not pend
            pend      := true
            pend_hi   := base_hi
            pend_lo   := base_lo
            pend_born := base_left
            pend_time := base_time
            pend_tght := (base_hi - base_lo) / atr
            // Average per-bar volume across the base, against the chart's own
            // 20-bar baseline. Per-bar rather than total, so a six-candle base
            // is not automatically rated above a one-candle base for being
            // longer. Neutral 1.0 where the feed carries no volume.
            pend_bvol := (na(vol_avg) or vol_avg <= 0 or base_n <= 0) ? 1.0 : (base_vol / float(base_n)) / vol_avg
            // Signed polarity of the base: the delta it traded divided by the
            // volume it traded, so the result is -1 to +1 regardless of size.
            // Neutral 0.0 where there was no volume to divide by.
            pend_bflw := base_vol > 0 ? math.max(-1.0, math.min(1.0, base_dlt / base_vol)) : 0.0
            pend_bar  := bar_index
            pend_endt := time
            pend_left := false
        base_n := 0

    // ── Stage 3 — resolve the open departure window ────────────────────────
    if pend
        bool  expired = bar_index - pend_bar > i_dep_win
        float upMove  = (high - pend_hi) / atr
        float dnMove  = (pend_lo - low)  / atr
        bool  upOk    = upMove >= i_dep_atr
        bool  dnOk    = dnMove >= i_dep_atr
        // Re-entry can only be judged once price has actually left. On the bar
        // the window opens price is still overlapping the base by construction,
        // so an unguarded overlap test would kill every window immediately.
        if close > pend_hi or close < pend_lo
            pend_left := true
        bool reentry = pend_left and close <= pend_hi and close >= pend_lo
        if upOk or dnOk
            // Both sides qualifying on one bar means an outside bar swallowed
            // the base in both directions. That is a volatility event, not a
            // departure from an origin, so neither zone is created.
            if upOk != dnOk
                SDZone z     = SDZone.new()
                // Expanded symmetrically about the base's own midpoint when the
                // base is thinner than the floor, so the PRICE the zone marks is
                // unchanged and only the band around it grows. Applied here, at
                // birth, rather than at draw time — the return test and the drawn
                // box must describe the same band or the script would be scoring
                // one thing and showing another.
                float raw_h  = pend_hi - pend_lo
                float min_h  = atr * i_zone_minh
                float mid_p  = (pend_hi + pend_lo) * 0.5
                float half_h = math.max(raw_h, min_h) * 0.5
                z.top        := mid_p + half_h
                z.bot        := mid_p - half_h
                z.born       := pend_born
                z.born_time  := pend_time
                // Price left upward, so the base it left is DEMAND — the origin
                // sits below price and is approached from above.
                z.is_supply  := dnOk
                z.dep_str    := upOk ? upMove : dnMove
                z.base_tight := pend_tght
                z.base_vol   := pend_bvol
                z.base_flow  := pend_bflw
                // Geometry of the departure itself, frozen at birth alongside its
                // strength. The arrow runs from the base edge the market left
                // through, to the extreme this bar reached — which is the same
                // extreme dep_str was measured from, so the drawn leg and the
                // scored number can never disagree.
                z.origin_end := pend_endt
                z.dep_time   := time
                z.dep_price  := upOk ? high : low
                z.ticks      := array.new<line>()
                array.push(zones, z)
                f_trimLive()
            pend := false
        else if expired or reentry
            pend := false

// ── FEATURE VECTOR ────────────────────────────────────────────────────────────
// All nine are written relative to the direction of the test and normalised to
// roughly 0-1. Normalisation matters more here than it would under a Gaussian
// model: the Lorentzian distance sums per-axis differences directly, so an axis
// left on a wider scale would quietly dominate every comparison.
//
// F0 Approach   — distance travelled into the zone over the approach window, in
//                 ATR. An impulse arrival and a drift arrival are different events.
// F1 Taps       — prior returns to THIS zone. The freshness doctrine — "a zone is
//                 spent after the first tap" — enters as a measurement here and
//                 is reported back by f_edges() rather than assumed.
// F2 Age        — bars since the zone formed, log-damped.
// F3 Departure  — how hard the market left this base, frozen at birth. A pivot
//                 cluster has no equivalent; this is the S/D-specific term.
// F4 Tightness  — how compressed the base was, frozen at birth, inverted so
//                 higher always means better evidence.
// F5 Trend      — how far price is stretched from its mean on arrival, signed
//                 with respect to the zone's direction.
// F6 Volume     — relative volume on arrival. Flattens to neutral on feeds
//                 without volume rather than distorting the model.
// F7 Width      — zone thickness in ATR. Tight origins and broad areas are not
//                 the same object.
// F8 BaseVolume — how much volume the base itself traded, frozen at birth. The
//                 volume-profile tools build their zones out of exactly this and
//                 never test whether it predicted anything; here it is one axis
//                 among ten and f_edges() reports what it was worth.
// F9 BaseFlow   — WHICH SIDE traded that volume, frozen at birth and oriented to
//                 the zone: 1.0 means the base was bought while a demand zone
//                 formed, or sold while a supply zone formed. Total volume cannot
//                 separate accumulation from a quiet pause; signed delta can, and
//                 this is the only axis in the script that carries that.
f_features(SDZone z, float a) =>
    float f0 = math.min(math.abs(close - close[i_appr_len]) / (a * 3.0), 1.0)
    float f1 = math.min(float(z.taps) / float(i_max_taps), 1.0)
    float f2 = math.min(math.log(1.0 + math.max(bar_index - z.born, 0)) / 5.71, 1.0)
    float f3 = math.min(z.dep_str / (i_dep_atr * 3.0), 1.0)
    float f4 = math.max(0.0, 1.0 - math.min(z.base_tight / math.max(i_base_atr * 2.0, 0.1), 1.0))
    // Signed toward the zone: positive means price arrived stretched in the
    // direction that would make this zone work.
    float raw5 = (close - ema_line) / (a * 3.0)
    float f5 = math.min(math.max((z.is_supply ? raw5 : -raw5) * 0.5 + 0.5, 0.0), 1.0)
    float f6 = na(vol_avg) or vol_avg <= 0 ? 0.5 : math.min(volume / (vol_avg * 3.0), 1.0)
    float f7 = math.min((z.top - z.bot) / (a * 3.0), 1.0)
    float f8 = math.min(z.base_vol / 3.0, 1.0)
    // Oriented like f5: a demand zone wants its base BOUGHT, a supply zone wants
    // its base SOLD, so both map to "higher is better evidence" and the two
    // directions can share one library.
    float f9 = math.min(math.max((z.is_supply ? -z.base_flow : z.base_flow) * 0.5 + 0.5, 0.0), 1.0)
    [f0, f1, f2, f3, f4, f5, f6, f7, f8, f9]

// ── RETURN LIFECYCLE ──────────────────────────────────────────────────────────
// A return OPENS on the first wick that enters the zone, whatever the
// consumption rule is set to — the consumption rule governs retirement, not
// measurement. Conflating the two would make the outcome definition move
// whenever a display preference changed.
//
// It RESOLVES three ways:
//   REACTED  price travelled i_react ATR back away from the zone edge
//   FAILED   price CLOSED beyond the far edge by the break buffer
//   STALLED  neither, within i_test_bars — discarded from training
//
// The break test is checked before the reaction test on the same bar: a bar that
// both pierced the far edge on a close and tagged the reaction target has
// resolved as a failure that later recovered, and calling that a reaction would
// flatter every number in the script.
var bool mark_react = false
var bool mark_fail  = false
var bool mark_new   = false
mark_react := false
mark_fail  := false
mark_new   := false

if confirmed and not na(atr) and atr > 0 and array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        SDZone z = array.get(zones, i)
        if not z.spent
            bool inZone = low <= z.top and high >= z.bot

            // ── open a return ──────────────────────────────────────────────
            if not z.testing and inZone and z.taps < i_max_taps
                z.testing    := true
                z.t_bar      := bar_index
                z.t_atr      := atr
                // Features are read BEFORE the tap counter advances. F1 is the
                // count of PRIOR returns, so a genuinely untouched zone must
                // enter its first return carrying zero — incrementing first
                // would put every fresh zone at one and quietly destroy the
                // freshness comparison this script exists to make.
                [g0, g1, g2, g3, g4, g5, g6, g7, g8, g9] = f_features(z, atr)
                z.taps       := z.taps + 1
                z.t_f0 := g0
                z.t_f1 := g1
                z.t_f2 := g2
                z.t_f3 := g3
                z.t_f4 := g4
                z.t_f5 := g5
                z.t_f6 := g6
                z.t_f7 := g7
                z.t_f8 := g8
                z.t_f9 := g9
                z.prob := f_prob(g0, g1, g2, g3, g4, g5, g6, g7, g8, g9)
                mark_new := true

            // ── resolve an open return ─────────────────────────────────────
            else if z.testing
                // ATR frozen at arrival, not re-read here: the reaction target
                // and the break buffer must describe the same distances the
                // moment the return opened, or a volatility expansion mid-test
                // silently moves the goalposts on an outcome already in flight.
                float tatr  = z.t_atr
                float farEd = z.is_supply ? z.top : z.bot
                float nearE = z.is_supply ? z.bot : z.top
                bool  broke = z.is_supply ? close >= farEd + i_break_buf * tatr : close <= farEd - i_break_buf * tatr
                bool  react = z.is_supply ? low   <= nearE - i_react     * tatr : high  >= nearE + i_react     * tatr
                bool  timeUp = bar_index - z.t_bar >= i_test_bars

                if broke or react or timeUp
                    z.testing := false
                    // STALLED is recorded on neither class. A zone price merely
                    // sat inside is not evidence for or against a reaction, and
                    // training on it would drag the base rate toward whichever
                    // outcome timeouts happen to resemble.
                    if broke or react
                        int cls = broke ? 1 : 0
                        // cls is 0 for a reaction and 1 for a failure — it drives
                        // the tick colour below. The library stores the inverse,
                        // 1 = reacted, so the running mean of its labels IS the
                        // reaction rate and needs no second interpretation.
                        f_libPush(cls == 0 ? 1 : 0, z.t_f0, z.t_f1, z.t_f2, z.t_f3, z.t_f4, z.t_f5, z.t_f6, z.t_f7, z.t_f8, z.t_f9)
                        z.tests := z.tests + 1
                        if not broke
                            z.reacts := z.reacts + 1
                        if broke
                            mark_fail := true
                        else
                            mark_react := true
                        if show_hist and not na(z.ticks)
                            line tk = line.new(bar_index, z.bot, bar_index, z.top,
                                 color = color.new(cls == 0 ? dem_col : sup_col, 45),
                                 width = i_border_w + 1)
                            array.push(z.ticks, tk)
                    // A decisive break retires the origin outright. Unlike a
                    // support level there is no role to flip into: the orders
                    // that made this a zone have been filled, and what is left
                    // is a price the market has already traded through.
                    if broke
                        z.spent    := true
                        z.end_time := time

            // ── consumption rule ───────────────────────────────────────────
            // Evaluated every bar but deliberately held back while a return is
            // open: retiring a zone mid-test would abandon a sample the
            // classifier is already waiting on, and under the Wick Touch setting
            // that would be every sample. A zone therefore retires on the first
            // bar after its return resolves, not during it.
            if not z.spent
                float mid = (z.top + z.bot) * 0.5
                float bHi = math.max(open, close)
                float bLo = math.min(open, close)
                bool consumed = switch i_mitig
                    "Wick Touch" => z.is_supply ? high >= z.bot : low <= z.top
                    "Body Touch" => z.is_supply ? bHi  >= z.bot : bLo <= z.top
                    "50% Fill"   => z.is_supply ? high >= mid   : low <= mid
                    => z.is_supply ? high >= z.top : low <= z.bot
                if (consumed or z.taps >= i_max_taps) and not z.testing
                    z.spent    := true
                    z.end_time := time

            array.set(zones, i, z)

// ── DRAW ──────────────────────────────────────────────────────────────────────
// Rank-based selection: the nearest i_show_n live zones above price and below it,
// plus every zone with a return open right now. A fixed ATR radius that
// populates a 5-minute chart leaves a daily one empty, so distance is used only
// as a safety ceiling on top of the rank.
if barstate.islast or confirmed
    if array.size(zones) > 0
        // Rank live zones by distance from price, per side.
        int rankUp = 0
        int rankDn = 0
        // Two passes: collect distances, then assign ranks. Pine has no sort on
        // a UDT array, so rank is computed by counting how many same-side zones
        // sit nearer — O(n^2) on a list capped at i_max_zones, which is cheap.
        for i = 0 to array.size(zones) - 1
            SDZone z = array.get(zones, i)
            float mid = (z.top + z.bot) * 0.5
            bool  above = mid > close
            // Live zones rank among live zones, consumed among consumed. Ranking
            // them together would let a stack of consumed origins crowd out the
            // live ones; not ranking the consumed at all would draw every one
            // ever recorded and exhaust the box budget.
            int   nearer = 0
            for j = 0 to array.size(zones) - 1
                if j != i
                    SDZone o = array.get(zones, j)
                    if o.spent == z.spent
                        float omid = (o.top + o.bot) * 0.5
                        if (omid > close) == above and math.abs(omid - close) < math.abs(mid - close)
                            nearer := nearer + 1
            bool inside  = low <= z.top and high >= z.bot
            bool farOff  = na(atr) or atr <= 0 ? false : math.abs(mid - close) / atr > i_show_dist
            bool drawIt  = show_zones and not farOff and (z.spent ? (show_spent and nearer < i_show_n) : (nearer < i_show_n or z.testing))

            if drawIt
                // The stored signature is re-scored against the CURRENT model
                // every time the zone is drawn. That is what lets an older
                // zone's percentage reflect everything the classifier has
                // learned since it was last touched, instead of a number frozen
                // at the moment of arrival. The signature itself never changes —
                // only what the model makes of it.
                // Re-scored on the LAST bar only. The neighbour search is
                // O(library x k) where the old model was a constant-time read,
                // and this block runs on every confirmed bar — refreshing every
                // drawn zone across the whole chart would multiply that cost for
                // a figure nobody reads except at the right-hand edge. Historical
                // bars keep the reading their return actually opened with, which
                // is the honest value for them to carry anyway.
                if barstate.islast and not na(z.t_f0)
                    z.prob := f_prob(z.t_f0, z.t_f1, z.t_f2, z.t_f3, z.t_f4, z.t_f5, z.t_f6, z.t_f7, z.t_f8, z.t_f9)
                // A zone never returned to carries no signature and so no
                // probability. Drawing it at a neutral 0.5 lands it in the
                // mid-conviction band, which is the honest rendering — rather
                // than letting an na fall through every colour comparison below.
                float pDraw = na(z.prob) ? 0.5 : z.prob
                if na(z.bx)
                    z.bx  := box.new(z.born_time, z.top, time + 5 * bar_ms, z.bot,
                         xloc = xloc.bar_time, border_width = i_border_w)
                    z.lbl := label.new(bar_index + 5, (z.top + z.bot) * 0.5, "",
                         style = label.style_label_left, size = lblSize,
                         color = color.new(color.black, 80))
                // The PROJECTION — the zone's prices carried forward from the base
                // to where they can be tested again. Left edge is the base's first
                // candle so the two parts join seamlessly; the origin block below
                // is drawn over its left end.
                // Right edge is time-based like the left (see box.new above) and
                // only needs to land visually near "now".
                box.set_top         (z.bx, z.top)
                box.set_bottom      (z.bx, z.bot)
                box.set_left        (z.bx, z.born_time)
                box.set_right       (z.bx, z.spent ? math.max(z.born_time + bar_ms, z.end_time + 5 * bar_ms) : time + 5 * bar_ms)
                box.set_bgcolor     (z.bx, sd_fill  (z.is_supply, z.spent, inside, pDraw))
                box.set_border_color(z.bx, sd_border(z.is_supply, z.spent, inside, pDraw))
                // A zone born from twice the required departure draws heavier —
                // the one property worth reading before any text is.
                box.set_border_width(z.bx, z.dep_str >= i_dep_atr * 2.0 ? i_border_w + 1 : i_border_w)
                // Solid, always. A dashed or dotted edge was tried for tap state
                // and read badly: at the width a zone border actually draws, a
                // broken line stops looking like a style and starts looking like
                // a different, weaker object — and on a thin zone it disappears
                // into the candles entirely. Freshness is carried in the label
                // ("fresh" / "2 taps") and in the table instead, where it can be
                // read rather than decoded.
                box.set_border_style(z.bx, line.style_solid)

                // ── ORIGIN BLOCK — the base candles themselves ────────────────
                // Solid where the projection is translucent. This is the half of a
                // supply/demand zone that a horizontal level has no equivalent for:
                // the projection says WHERE, the origin block says WHERE FROM.
                int obx_r = math.max(z.origin_end, z.born_time + bar_ms)
                if na(z.obx)
                    z.obx := box.new(z.born_time, z.top, obx_r, z.bot,
                         xloc = xloc.bar_time, border_width = i_border_w + 1)
                box.set_top         (z.obx, z.top)
                box.set_bottom      (z.obx, z.bot)
                box.set_left        (z.obx, z.born_time)
                box.set_right       (z.obx, obx_r)
                box.set_bgcolor     (z.obx, z.spent ? color.new(color.gray, 80) : color.new(sd_base(z.is_supply), 55))
                box.set_border_color(z.obx, z.spent ? color.new(color.gray, 62) : color.new(sd_base(z.is_supply), 0))

                // ── DEPARTURE MEASURE — why this base is a zone at all ───────
                // A VERTICAL bar standing on the departure candle, running from
                // the edge the market left through to the extreme it reached.
                //
                // This was a diagonal arrow from the base to the extreme, and it
                // read badly: a slanted line crossing a dozen candles looks like
                // a drawing someone left behind, not a measurement, and the eye
                // cannot judge its length against the price axis because it is
                // moving in two dimensions at once. Standing it upright on the
                // bar that actually produced the move fixes both — it occupies
                // one bar column, and its height IS the departure, readable
                // straight off the price scale. It is drawn heavy because it is
                // the one mark on this chart a clustered-pivot level can never
                // have: a pivot has no departure to measure.
                if not na(z.dep_price) and z.dep_time > 0
                    float dep_from = z.is_supply ? z.bot : z.top
                    if na(z.dep_ln)
                        z.dep_ln := line.new(z.dep_time, dep_from, z.dep_time, z.dep_price,
                             xloc = xloc.bar_time, style = line.style_solid,
                             width = i_border_w + 2)
                    line.set_xy1 (z.dep_ln, z.dep_time, dep_from)
                    line.set_xy2 (z.dep_ln, z.dep_time, z.dep_price)
                    line.set_width(z.dep_ln, i_border_w + 2)
                    line.set_color(z.dep_ln, z.spent ? color.new(color.gray, 78) : color.new(sd_base(z.is_supply), 15))

                float gScore = f_gradeScore(z.dep_str, z.base_tight, z.tests, z.born)
                string gTag  = i_show_grade and not zen_mode ? f_gradeTag(gScore) : ""
                box.set_text        (z.bx, gTag)
                box.set_text_color  (z.bx, color.new(sd_base(z.is_supply), 20))
                box.set_text_size   (z.bx, size.tiny)
                box.set_text_halign (z.bx, text.align_right)
                box.set_text_valign (z.bx, z.is_supply ? text.align_top : text.align_bottom)

                // Overlap is solved structurally, not with a distance knob: the
                // worded label renders only on the zones a trader is actually
                // asking about — the nearest live demand, the nearest live
                // supply, and any zone with a return open right now. Every other
                // zone speaks through its colour alone, which caps the label
                // count at roughly three regardless of timeframe or zoom.
                bool lblOn = show_lbl and not zen_mode and not z.spent and (show_all_lbl or z.testing or nearer == 0)
                // na(z.prob) is structurally impossible once a return has opened,
                // but a percentage is the last place a defect should surface —
                // treat it as untouched rather than let a comparison with na fall
                // through.
                bool untested = (z.tests == 0 and not z.testing) or na(z.prob)
                string role = z.is_supply ? "Supply" : "Demand"
                int nbTot = array.size(g_lib)
                string nstr = "  (n=" + str.tostring(nbTot) + ")"
                // Past tense, and the classifier's sample size travels with the
                // figure. A bare "68% reaction" would read as a forward-looking
                // forecast about an unresolved event; what is actually reported
                // is how comparable past arrivals on this chart resolved.
                // Reordered so the label reads as a supply/demand statement rather
                // than a level statement: what it IS, how hard the market left it,
                // how much stands behind it, whether it is still fresh — and only
                // then the classifier's read. The percentage stays past tense and
                // still carries its sample size; a bare forward-looking number is
                // exactly what this script is written not to imply.
                string verdict = untested ? "untouched" : z.spent ? "consumed" : not model_ready() ? "learning" + nstr : z.prob <= 1.0 - i_thresh ? str.tostring(math.round((1.0 - z.prob) * 100)) + "% failed" + nstr : str.tostring(math.round(z.prob * 100)) + "% reacted" + nstr
                string dep_txt = str.tostring(z.dep_str, "#.#") + " ATR departure"
                string tap_txt = z.taps == 0 ? "fresh" : str.tostring(z.taps) + (z.taps == 1 ? " tap" : " taps")
                string gtxt = gTag != "" ? gTag + "  ·  " : ""
                // Colour follows the direction the historical reading leans, and
                // is held neutral until the classifier is actually in use.
                color dirCol = untested or inside or not model_ready() ? color.new(color.gray, 20) : z.prob >= i_thresh ? color.new(sd_base(z.is_supply), 0) : color.new(sd_base(not z.is_supply), 0)
                label.set_x        (z.lbl, bar_index + 5)
                label.set_y        (z.lbl, (z.top + z.bot) * 0.5)
                label.set_text     (z.lbl, lblOn ? role + " origin  ·  " + dep_txt + "  ·  " + gtxt + tap_txt + "  ·  " + verdict : "")
                label.set_textcolor(z.lbl, dirCol)
                label.set_size     (z.lbl, lblSize)
                label.set_color    (z.lbl, lblOn ? color.new(color.black, 80) : color.new(color.black, 100))
            else
                if not na(z.bx)
                    box.delete(z.bx)
                    z.bx := na
                // The origin block and the departure leg hide WITH their zone.
                // Left behind they would read as a stray block and a stray arrow
                // floating where no zone is drawn. Their geometry is frozen at
                // birth, so both are rebuilt exactly as they were when the zone
                // comes back into range.
                if not na(z.obx)
                    box.delete(z.obx)
                    z.obx := na
                if not na(z.dep_ln)
                    line.delete(z.dep_ln)
                    z.dep_ln := na
                if not na(z.lbl)
                    label.delete(z.lbl)
                    z.lbl := na
            array.set(zones, i, z)

// ── ORDER FLOW BAND ──────────────────────────────────────────────────────────
// Context, drawn behind everything else. The band sits above the trend EMA while
// delta is rising and below it while delta is falling, and its opacity scales
// with how strong that pressure is against its own recent range — so a faint
// band means the tape is undecided and a solid one means one side is leaning on
// it. It never produces a mark of its own and nothing keys off it; the point is
// that when price arrives at a zone you can see, without a second indicator,
// whether flow is arriving with it or against it.
float flow_str = math.min(math.abs(flow_z) / 2.5, 1.0)
// Steep, not shallow. The first version ran 82 down to 40, which never got
// solid enough to read as a ribbon and never got faint enough to disappear when
// the tape was undecided — it just sat there at a constant mid-grey. This runs
// 80 down to 10, so a genuinely one-sided tape paints an obvious band and a
// balanced one nearly vanishes. Floored at 10 rather than 0 so it never becomes
// an opaque slab that hides the candles underneath it.
int   flow_a   = int(math.round(math.max(10.0, 80.0 - flow_str * 70.0)))

fb_top = plot(i_show_flow ? ema_line + atr * i_flow_w : na, "Flow Band Top", display=display.none)
fb_mid = plot(i_show_flow ? ema_line                   : na, "Flow Band Mid", display=display.none)
fb_bot = plot(i_show_flow ? ema_line - atr * i_flow_w : na, "Flow Band Bottom", display=display.none)

fill(fb_top, fb_mid, color = i_show_flow and flow_z > 0 ? color.new(dem_col, flow_a) : na, title = "Buying Pressure")
fill(fb_mid, fb_bot, color = i_show_flow and flow_z < 0 ? color.new(sup_col, flow_a) : na, title = "Selling Pressure")

// ── INFO TABLE ────────────────────────────────────────────────────────────────
// 14 rows: 10 data rows plus a 4-row legend for the visual language.
var table tbl = table.new(position.top_right, 2, 14,
     bgcolor      = color.new(color.black, 75),
     border_color = color.new(color.gray,  60),
     border_width = 1,
     frame_color  = color.new(color.gray,  50),
     frame_width  = 1)

if barstate.islast and show_table and not zen_mode
    bool rdy    = model_ready()
    int  graded = array.size(g_lib)
    int   act = 0
    float nd  = na
    float ns  = na
    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            SDZone z = array.get(zones, i)
            if not z.spent
                act := act + 1
                float m = (z.top + z.bot) * 0.5
                if m <= close
                    nd := na(nd) ? m : math.max(nd, m)
                else
                    ns := na(ns) ? m : math.min(ns, m)
    color txt_wht = color.new(color.white, 0)
    // Distance travels with the price so the row answers both questions a
    // trader has at a glance: where is it, and how far away is it.
    string nd_txt = na(nd) ? "—" : str.tostring(nd, format.mintick) + (not na(atr) and atr > 0 ? "  ·  " + str.tostring(math.abs(close - nd) / atr, "#.#") + " ATR" : "")
    string ns_txt = na(ns) ? "—" : str.tostring(ns, format.mintick) + (not na(atr) and atr > 0 ? "  ·  " + str.tostring(math.abs(close - ns) / atr, "#.#") + " ATR" : "")

    // The two doctrine verdicts. Reported only once the library is warm — below
    // that it holds too few returns for either gap to mean anything. Both are
    // called either way only past a small dead band, which is a real difference
    // rather than sampling noise, and both are allowed to come back against the
    // doctrine they are testing.
    [fe, ve, xe] = f_edges()
    string fe_txt = not rdy or na(fe) ? "—" : fe > 0.1 ? "fresh zones reacted more" : fe < -0.1 ? "tapped zones reacted more" : "no measurable difference"
    color  fe_col = not rdy or na(fe) or math.abs(fe) <= 0.1 ? color.new(color.gray, 20) : color.new(fe > 0 ? dem_col : sup_col, 0)
    string ve_txt = not rdy or na(ve) ? "—" : ve > 0.05 ? "heavy bases reacted more" : ve < -0.05 ? "quiet bases reacted more" : "no measurable difference"
    color  ve_col = not rdy or na(ve) or math.abs(ve) <= 0.05 ? color.new(color.gray, 20) : color.new(ve > 0 ? dem_col : sup_col, 0)
    string xe_txt = not rdy or na(xe) ? "—" : xe > 0.03 ? "flow-aligned bases reacted more" : xe < -0.03 ? "flow-opposed bases reacted more" : "no measurable difference"
    color  xe_col = not rdy or na(xe) or math.abs(xe) <= 0.03 ? color.new(color.gray, 20) : color.new(xe > 0 ? dem_col : sup_col, 0)
    bool   flowUp = flow_z > 0

    table.cell(tbl, 0, 0, "SD AI", text_color=color.new(color.gray, 0), text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(tbl, 1, 0, rdy ? "● LIVE" : "● LEARNING", text_color=rdy ? color.new(color.lime, 0) : color.new(color.yellow, 0), text_size=size.small, bgcolor=color.new(color.black, 60))

    table.cell(tbl, 0, 1, "Zones On Chart", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(act), text_color=txt_wht, text_size=size.small)

    table.cell(tbl, 0, 2, "Returns Graded", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(graded) + (rdy ? "" : " / " + str.tostring(i_warmup)), text_color=rdy ? color.new(color.lime, 0) : color.new(color.yellow, 0), text_size=size.small)

    table.cell(tbl, 0, 3, "Zones Reacted", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(math.round(f_baseRate() * 100)) + "% of returns", text_color=txt_wht, text_size=size.small)

    table.cell(tbl, 0, 4, "Freshness Edge", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 4, fe_txt, text_color=fe_col, text_size=size.small)

    table.cell(tbl, 0, 5, "Base Volume Edge", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 5, ve_txt, text_color=ve_col, text_size=size.small)

    table.cell(tbl, 0, 6, "Base Flow Edge", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 6, xe_txt, text_color=xe_col, text_size=size.small)

    // Live tape state, not a verdict about any zone — it is the one row here that
    // describes right now rather than the record.
    table.cell(tbl, 0, 7, "Order Flow", text_color=txt_wht, text_size=size.small)
    table.cell(tbl, 1, 7, (flowUp ? "▲ buying" : "▼ selling") + "  ·  " + str.tostring(math.abs(flow_z), "#.#") + "σ",
         text_color=color.new(flowUp ? dem_col : sup_col, 0), text_size=size.small)

    table.cell(tbl, 0, 8, "Nearest Demand", text_color=color.new(dem_col, 0), text_size=size.small)
    table.cell(tbl, 1, 8, nd_txt, text_color=color.new(dem_col, 0), text_size=size.small)

    table.cell(tbl, 0, 9, "Nearest Supply", text_color=color.new(sup_col, 0), text_size=size.small)
    table.cell(tbl, 1, 9, ns_txt, text_color=color.new(sup_col, 0), text_size=size.small)

    // Legend for the visual language rather than for the palette alone. The two
    // hues say direction; the SHAPE says everything a horizontal level cannot.
    table.cell(tbl, 0, 10, "Blue", text_color=color.new(dem_col, 0), text_size=size.tiny)
    table.cell(tbl, 1, 10, "demand · orange = supply", text_color=color.new(color.gray, 20), text_size=size.tiny)

    table.cell(tbl, 0, 11, "Solid block", text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(tbl, 1, 11, "the base it left from", text_color=color.new(color.gray, 20), text_size=size.tiny)

    table.cell(tbl, 0, 12, "Vertical bar", text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(tbl, 1, 12, "the departure that made it", text_color=color.new(color.gray, 20), text_size=size.tiny)

    table.cell(tbl, 0, 13, "Heavy edge", text_color=color.new(color.gray, 20), text_size=size.tiny)
    table.cell(tbl, 1, 13, "departure 2x+ required", text_color=color.new(color.gray, 20), text_size=size.tiny)

// ── ALERTS ────────────────────────────────────────────────────────────────────
// Worded as observations. This script reports how a return to a zone resolved and
// what the historical record associates with that kind of arrival; it does not
// direct anyone to take a position.
alertcondition(mark_new,   "Price entered a zone",
     "Supply Demand AI [PickMyTrade]: price has entered a supply or demand zone and a return is now open. The zone's label carries the evidence grade and how similar past arrivals on this chart resolved. Informational, not a trade instruction.")
alertcondition(mark_react, "Return reacted",
     "Supply Demand AI [PickMyTrade]: a return to a zone produced the configured reaction target before the zone failed. Informational, not a trade instruction.")
alertcondition(mark_fail,  "Return failed",
     "Supply Demand AI [PickMyTrade]: price closed decisively through a zone before producing the reaction target. The zone is retired — the orders that made it an origin have been filled. Informational, not a trade instruction.")
alertcondition(mark_react or mark_fail, "Any resolved return",
     "Supply Demand AI [PickMyTrade]: a return to a zone resolved and the classifier has been updated with the outcome.")
````
