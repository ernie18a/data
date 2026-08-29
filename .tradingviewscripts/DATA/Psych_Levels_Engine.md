<!-- tradingview-pine-id: PUB;71b39e6c39e540329eb4a29d840d015d -->
<!-- tradingviewscripts-format: 1 -->
# Psych Levels Engine

Source: https://www.tradingview.com/script/An4ysOg5-Psych-Levels-Engine/

## Description

PSYCH LEVELS ENGINE

Every chart has round numbers on it. Almost every indicator that draws them treats them all as equally important. This one doesn't. It watches each level, records every test, and colors the line by whether that level has actually been holding or breaking — in its current role, on your instrument, on your timeframe — measured against a hidden control baseline so you can see the edge instead of the raw hit rate.

Free and open source. Use it, fork it, tear it apart.

WHAT IT DOES

Round-number levels are drawn in three tiers (Major / Tradable / Sniper), auto-sized per instrument by preset — 500/100/25 on NQ, 100/25/5 on ES, 1.00/0.25/0.10 on CL, and so on, with a Custom option for anything else.

Each time price enters a level's zone, that visit is logged as a test and tracked until it resolves. The level's line then reflects its own measured history rather than a static assumption about round numbers.

WHAT MAKES IT DIFFERENT

Control levels. The script silently tracks "nothing" levels at an arbitrary offset from each round number and scores them with the identical logic. That pooled control rate becomes the baseline every real level is measured against. In a ranging market any price level will show a decent hold rate; the control tells you how much of it is the level and how much is just the tape. What the colors show is lift over a random price, not raw hold percentage. As far as I know nothing else on this platform does this, and it's the reason I built it.

First-touch resolution. A test resolves the moment price touches the hold target or the break level, whichever comes first — never by taking a close snapshot N bars later. A wick that ran your stop and came back is a break, and it gets recorded as one.

Role separation. A level below price is judged as SUPPORT, above price as RESISTANCE, and the two histories are kept apart. The same number can be a strong floor and a weak ceiling; averaging those together destroys the information.

Significance gate. A level only earns color once its lift clears roughly one standard error for its sample size — about 29pp at 3 tests, about 9pp at 30. Small samples have to show big lift to get a color. Everything unproven stays gray.

THE FLOW LAYER

Delta pressure at the moment of the test classifies it DEFENDED (buyers into support, sellers into resistance) or ATTACKED (aggression pressing through), which leans the line ahead of the outcome. Approach velocity (fast spike vs slow grind) and market regime (Kaufman efficiency ratio, with-trend vs counter-trend vs range) are tracked as interactions with flow rather than as standalone signals.

Delta is approximated with the tick rule on lower-timeframe sub-bars. TradingView has no true bid/ask tape, so this is a proxy — which is exactly why the validation panel exists.

READING THE CHART

Line color — green: holds better than a random level in this role. Red: breaks more (a magnet). Gray: no evidence either way yet.
Line width — thicker means higher tier and/or a more reliable reaction history.
Line style — solid: defend lean. Dashed: attack lean. Faded: not enough tests to resolve.
Glyphs — « / «≪ defend lean on a fast / slow approach, » / ≫ attack lean on a fast / slow approach.
★ — confluence: flow and CVD absorption defending the same level (optional handshake, see below).

Panels: a ranked table of the top levels near price, a Flow @ zone validation panel (hold rate by flow bucket plus the flow x velocity and flow x regime interactions), and an optional setup log showing recent resolved tests as entry lean to realized outcome. One Clean Chart switch hides all of it.

HOW TO USE IT

1. Set your Instrument Preset. For most people that is the only setting that needs touching.
2. Watch the Flow @ zone panel — it is the honesty check. If Defended% sits well above Attacked%, the flow lean is separating outcomes on your chart. If they're flat against each other, ignore the lean and use the lines as plain structure.
3. Once the sample is real (n in the dozens), let the colors do the work.

ALERTS

Two independent paths; pick one, not both. Classic alertconditions from the dropdown, one alert per condition. Or the Alert Engine: one alert set to "Any alert() function call," with in-script toggles deciding which events fire — confluence, defended, attacked, approaching a role-strong level. Engine messages are built live and carry the measured hold rate for the exact condition that fired.

OPTIONAL CVD HANDSHAKE

If you also run my Elite CVD Oscillator, wire its AbsorbFlag and AbsorbDir plots into the CVD Confluence inputs to unlock the ★ marker and the confluence alert. Entirely optional — the script is complete without it. If you would like to use the cvd indicator here is the link to that script. Also completely free. Because I love you filthy degens and I want us all to win. 

https://www.tradingview.com/script/9bxfutKs-Elite-Cumulative-Volume-Delta-Oscillator/

LIMITATIONS

The 15S delta timeframe requires a plan with seconds data; set it to "1" if yours doesn't have it. 

All statistics accumulate from the moment the indicator loads and reset when the chart reloads. They are a live forward sample, not a backtest. Give it real screen time before trusting a number.

Levels are round numbers, not magic. The control baseline exists to show you how much of the reaction is real — and on some instruments and some regimes the honest answer will be "not much." That's a feature.

 As always, backtest first to understand the behavior and how to use the psych level engine properly.

This is analysis, not financial advice. Nothing here is a signal to buy or sell.

---

## Source Code

````pine
//@version=6
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©Manifesting Gains

indicator("Psych Levels Engine", "Psych Engine", overlay=true, max_lines_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════════
//  PSYCH LEVELS — round numbers, scored by what they actually did on your chart
// ════════════════════════════════════════════════════════════════════════════
//
//  WHAT IT DOES
//  Every chart has round numbers on it. Almost every indicator that draws them
//  treats them all as equally important. This one doesn't: it watches each level,
//  records every test, and colors the line by whether that level has actually
//  been holding or breaking — in its current role, at your instrument, on your
//  timeframe.
//
//    Level tiers      Major / Tradable / Sniper round numbers, auto-sized per
//                     instrument by the preset (500 / 100 / 25 on NQ, etc.)
//    Test ledger      each visit to a level's zone is a test; it resolves
//                     first-touch — hold target or break level, whichever price
//                     touches first — never by a close snapshot N bars later
//    Role-aware       a level below price is judged as SUPPORT, above price as
//                     RESISTANCE, and the two histories are kept separate
//    Control levels   the honest part. The script secretly tracks "nothing"
//                     levels at an arbitrary offset from each round number and
//                     scores them the same way. That pooled control rate is the
//                     baseline every real level is measured against — so what
//                     you see is the EDGE over a random price, not the raw hold
//                     rate that any level would show in a ranging market.
//    Significance     a level only earns color once its lift clears roughly one
//                     standard error for its sample size: 3 tests need ~29pp,
//                     30 tests need ~9pp. Small samples must show big lift.
//    Delta pressure   flow at the moment of the test classifies it DEFENDED
//                     (buyers into support / sellers into resistance) or
//                     ATTACKED (aggression pressing through), which leans the
//                     line green or red ahead of the outcome
//    Approach speed   fast spike vs slow grind into the level, tracked as an
//                     interaction with flow rather than on its own
//    Regime           a Kaufman efficiency ratio tags each test trending vs
//                     ranging, and whether the pressure ran with or against
//                     the ambient trend
//
//  QUICK START
//    1. Pick your Instrument Preset. That sets the three round-number tiers.
//    2. Trade nothing off it for a few sessions. Watch the "Flow @ zone" panel
//       in the bottom right — it is the honesty check. If Defended% sits well
//       above Attacked%, the flow lean is separating outcomes on your chart. If
//       the two are flat against each other, ignore the lean and use the lines
//       as plain structure.
//    3. Once the sample is real (n in the dozens), let the colors do the work:
//       green = holds better than a random level in this role, red = breaks
//       more, gray = no evidence either way.
//
//  READING THE CHART
//    Line color    green = role-strong (holds), red = magnet (breaks),
//                  gray = neutral or not enough evidence yet
//    Line width    thicker = higher tier and/or reliable reaction history
//    Solid line    defended / hold lean        Dashed line   attacked / break lean
//    Faded line    not enough tests to resolve yet
//    « or «≪       defend lean, fast spike / slow grind approach
//    » or ≫        attack lean, fast spike / slow grind approach
//    ★             confluence — flow AND CVD absorption defending the level
//                  (requires the optional Elite CVD handshake to be wired)
//
//  PANELS
//    Ranked table    top 5 levels near price by proximity x reaction x tier
//    Flow @ zone     hold rate by flow bucket, and the flow x velocity and
//                    flow x regime interactions — the validation panel
//    Setup log       recent resolved tests: entry lean → realized outcome
//    Clean chart     one switch hides all of the above for screenshots/mobile
//
//  REQUIREMENTS AND LIMITATIONS
//    • Delta is approximated with the tick rule on lower-timeframe sub-bars.
//      TradingView has no true bid/ask tape. It is a proxy, and the validation
//      panel exists precisely so you can check whether the proxy still carries
//      the edge on your instrument instead of taking it on faith.
//    • The 15S delta timeframe needs a plan with seconds data. If yours doesn't
//      have it, set the delta lower timeframe to "1".
//    • All statistics accumulate from the moment the indicator loads and reset
//      when the chart reloads. They are a live forward sample, not a backtest.
//      Give it real screen time before trusting a number.
//    • Levels are round numbers, not magic. The whole point of the control-level
//      baseline is to show you how much of the reaction is real.
//    • This is analysis, not financial advice.
//
//  Every input below has a tooltip — hover the ⓘ if a setting isn't obvious.
// ════════════════════════════════════════════════════════════════════════════

// ─────────── SETTINGS GROUPS ───────────
// Numbered so the Settings dialog reads top-to-bottom in the order you'd actually
// configure it: instrument → what's drawn → how tests are judged → the flow
// layers → how it looks → what it reports.
G_INST  = "1 · Instrument Preset"
G_LVL   = "2 · Levels Shown"
G_ENG   = "3 · Test Engine"
G_DECAY = "4 · Recency Decay"
G_DELTA = "5 · Delta Pressure (Flow)"
G_VEL   = "6 · Approach Velocity"
G_REG   = "7 · Market Regime"
G_CONF  = "8 · CVD Confluence (optional)"
G_LINE  = "9 · Line Appearance & Markers"
G_PANEL = "10 · Panels & Labels"
G_LOG   = "11 · Setup Log"
G_ALERT = "12 · Alerts"

// ─────────── 1 · INSTRUMENT PRESET ───────────
preset = input.string("NQ (Nasdaq)", "Instrument Preset", group=G_INST,
     options=["ES (S&P 500)","NQ (Nasdaq)","YM (Dow)","RTY (Russell 2000)","CL (Crude Oil)","GC (Gold)","Custom"],
     tooltip="Sets the three round-number tiers for your instrument. This is the only setting most users need to touch.\n\nNQ: 500 / 100 / 25    ES: 100 / 25 / 5    YM: 1000 / 250 / 50\nRTY: 100 / 25 / 5    CL: 1.00 / 0.25 / 0.10    GC: 100 / 25 / 10\n\nCustom: uses the three step values below. For a stock around $50 you might use 10 / 5 / 1; for BTC, 10000 / 5000 / 1000. The rule of thumb: Major should be a number people quote in headlines, Tradable should print a few times a session, Sniper should be the fine grid price actually pauses at.")

customMajor = input.float(500.0, "Custom · Major Step", minval=0.0001, group=G_INST,
     tooltip="Only used when the preset above is set to Custom. The strongest tier — the numbers that make headlines. Ranked with a 1.5x significance boost.")

customTradable = input.float(100.0, "Custom · Tradable Step", minval=0.0001, group=G_INST,
     tooltip="Only used when the preset above is set to Custom. The workhorse intraday tier — the levels price actually tests several times a session.\n\nNote: this step also sets the offset of the hidden control levels, so it matters even if you hide the Tradable tier.")

customSniper = input.float(25.0, "Custom · Sniper Step", minval=0.0001, group=G_INST,
     tooltip="Only used when the preset above is set to Custom. The fine sub-grid. Dense — usually left hidden.")

majorStep =
     preset == "ES (S&P 500)"       ?  100.0 :
     preset == "NQ (Nasdaq)"        ?  500.0 :
     preset == "YM (Dow)"           ? 1000.0 :
     preset == "RTY (Russell 2000)" ?  100.0 :
     preset == "CL (Crude Oil)"     ?    1.0 :
     preset == "GC (Gold)"          ?  100.0 : customMajor

tradableStep =
     preset == "ES (S&P 500)"       ?  25.0 :
     preset == "NQ (Nasdaq)"        ? 100.0 :
     preset == "YM (Dow)"           ? 250.0 :
     preset == "RTY (Russell 2000)" ?  25.0 :
     preset == "CL (Crude Oil)"     ?   0.25 :
     preset == "GC (Gold)"          ?  25.0 : customTradable

sniperStep =
     preset == "ES (S&P 500)"       ?  5.0 :
     preset == "NQ (Nasdaq)"        ? 25.0 :
     preset == "YM (Dow)"           ? 50.0 :
     preset == "RTY (Russell 2000)" ?  5.0 :
     preset == "CL (Crude Oil)"     ?  0.1 :
     preset == "GC (Gold)"          ? 10.0 : customSniper

// ─────────── 2 · LEVELS SHOWN ───────────
showMajor = input.bool(true, "Show Major tier", group=G_LVL,
     tooltip="The strongest tier (e.g. 30000 / 30500 on NQ). Highest psychological weight; ranked with a 1.5x significance boost and always drawn at maximum width.")

showTradable = input.bool(true, "Show Tradable tier", group=G_LVL,
     tooltip="Mid-tier round numbers (every 100 on NQ). The workhorse intraday levels — this is where most of the useful sample accumulates.")

showSniper = input.bool(false, "Show Sniper tier", group=G_LVL,
     tooltip="Fine sub-levels (every 25 on NQ). Dense; off by default to keep the chart clean and the script fast. Turn on for scalping a tight range.")

atrMult = input.float(2.5, "Proximity filter (ATR mult)", group=G_LVL, minval=0.5,
     tooltip="Only track and draw levels within this many ATRs of price. Lower = fewer, more relevant levels near price — 2.5 to 3 is right for live trading. Raise it temporarily to study more levels at once, but expect the chart to get busy and the script to slow down.")

maxTracked = input.int(300, "Max tracked levels", group=G_LVL, minval=50,
     tooltip="Cap on how many levels are held in memory (real levels plus their hidden controls). When full, the lowest-activity level is evicted. Raise only if you show many tiers at once and notice levels losing their history.")

// ─────────── 3 · TEST ENGINE ───────────
// How a "test" is defined and how its outcome is judged. These are the numbers
// behind every statistic the panels report.
armATR = input.float(1.0, "Arm distance (ATR)", group=G_ENG, minval=0.1,
     tooltip="Price must travel at least this many ATRs away from a level before that level can register a NEW test. This is the debounce that stops one long chop from counting as dozens of tests.\n\nHigher = fewer, cleaner tests. Lower = more tests, but they start to overlap and the sample gets correlated.")

zoneATR = input.float(0.25, "Zone tolerance (ATR)", group=G_ENG, minval=0.0,
     tooltip="Half-width of the reaction ZONE around each round number, in ATRs. Price reacts in an AREA, not at the exact tick — a test counts when the bar's range enters this band.\n\nAuto-capped so the zone can never reach the hidden control level. Raise for wider zones on volatile instruments; 0 = hairline.")

holdATR = input.float(0.6, "Hold threshold (ATR)", group=G_ENG, minval=0.05,
     tooltip="Follow-through required to count as a HOLD, in ATRs, measured in the direction price approached from. The hold target sits at the level ± this many ATRs; touching it before the break level resolves the test as a hold.\n\nLower it (e.g. 0.4) to let shallow tap-and-reject reactions register as holds.")

breakATR = input.float(0.6, "Break threshold (ATR)", group=G_ENG, minval=0.05,
     tooltip="Follow-through against the approach direction required to count as a BREAK. On a bar that touches BOTH the hold target and the break level, the break wins — deliberately conservative, so the hold rates you see are if anything understated.")

fwdBars = input.int(8, "Max bars to resolve (timeout)", group=G_ENG, minval=3,
     tooltip="Tests resolve the moment price touches the hold target or the break level, judged on highs and lows bar by bar. This setting is only the TIMEOUT: if neither side is touched within this many bars, the test logs as neutral and is excluded from the hold-rate statistics.")

atrLen = input.int(14, "ATR length", group=G_ENG,
     tooltip="Lookback for the ATR that scales every ATR-relative setting in this indicator. 14 is standard and robust across timeframes.")

minTests = input.int(3, "Min tests (in role) before scored", group=G_ENG, minval=1,
     tooltip="A level stays neutral gray until it has accumulated at least this many tests IN ITS CURRENT ROLE — support-side if below price, resistance-side if above.\n\nColoring additionally requires the lift over baseline to clear a significance threshold that shrinks as tests accumulate, so a small sample must show big lift to earn a color. Lowering this does not bypass that check.")

// ─────────── 4 · RECENCY DECAY ───────────
decayEnabled = input.bool(false, "Enable recency decay", group=G_DECAY,
     tooltip="When on, older tests fade so a level can re-rate after a regime or role change instead of staying anchored to stale history. Worth enabling for intraday trading.\n\nDecay is applied both when a test is judged and lazily at read time (coloring, ranking, alerts), so a level that hasn't been re-tested since the decay accrued doesn't stay overweighted in between.")

decayHalfLife = input.float(500.0, "Decay half-life (bars)", group=G_DECAY, minval=20.0,
     tooltip="How many bars it takes for a test's weight to halve. On a 2-minute chart: 1000 bars is about 33 hours (very slow), 200-300 is within a session or two (faster role flips). Lower = forgets faster.")

// ─────────── 5 · DELTA PRESSURE (FLOW) ───────────
// Classifies each test by the order flow at the moment it forms: is the level
// being DEFENDED or ATTACKED? This is the leading read — it leans the line
// before the outcome is known.
lowerTf = input.timeframe("15S", "Delta lower timeframe", group=G_DELTA,
     tooltip="Sub-bar timeframe used to approximate bid/ask delta via the tick rule: sub-bar up-volume minus down-volume. 15S gives about 8 sub-bars per 2-minute bar.\n\nIf your TradingView plan has no seconds data, set this to '1' (1-minute) — it still works, just coarser. This is an APPROXIMATION of delta; the Flow @ zone panel is there so you can check whether it still carries the edge on your chart.")

useExtDelta = input.bool(false, "Use external CVD delta source", group=G_DELTA,
     tooltip="Source per-bar delta from another indicator instead of the internal tick-rule estimate above. Built for the free Elite CVD Oscillator, which publishes a 'DeltaPerBar' value to the Data Window — pointing this at it means both indicators classify flow off exactly one estimator instead of two approximations that quietly disagree.\n\n⚠ IMPORTANT: leave this OFF until the source below is actually wired. An unwired source input feeds PRICE into the classifier, not delta, and the DEF/ATK reads will be nonsense.\n\nIf the wired source reads na on a bar (data gap), the internal estimate covers that bar. Note that sigma re-estimates over ~50 bars after switching, so classification rates drift for a while and statistics gathered before and after the switch are not strictly comparable.")

extDeltaSrc = input.source(close, "  ↳ External delta source", group=G_DELTA,
     tooltip="Point this at the other indicator's per-bar delta output — for the Elite CVD Oscillator, that is 'DeltaPerBar'. Only read when the toggle above is ON.")

defendZ = input.float(-0.5, "Defend threshold (attack-Z ≤)", group=G_DELTA, maxval=0.0,
     tooltip="A test is classified DEFENDED when the attack-delta z-score is at or below this — flow is aligned with the level holding (buyers into support, sellers into resistance).\n\nMore negative = stricter, fewer DEF classifications but cleaner ones. If DEF events become too rare to build a sample, loosen toward -0.3 and watch the n column in the Flow @ zone panel.")

attackThr = input.float(1.0, "Attack threshold (attack-Z ≥)", group=G_DELTA, minval=0.0,
     tooltip="A test is classified ATTACKED when the attack-delta z-score is at or above this — heavy aggression pressing THROUGH the level.\n\nHigher = stricter. If ATK events become too rare, consider 0.7-0.8 and watch the n column in the Flow @ zone panel.")

flowExpiryBars = input.int(30, "Flow lean expiry (bars)", group=G_DELTA, minval=5,
     tooltip="A DEF/ATK/NEU lean is only trusted for this many bars after the test that produced it. After expiry the level reverts to no-read: the line color falls back to history, the Flow column shows —, the velocity glyph disappears, and the lean cannot arm alerts.\n\n30 bars is 1 hour on a 2-minute chart. Without this a morning read would still be coloring lines and firing alerts in the afternoon.")

// ─────────── 6 · APPROACH VELOCITY ───────────
velBars = input.int(5, "Approach window (bars)", group=G_VEL, minval=2, maxval=20,
     tooltip="How many bars back to measure the approach INTO the level. Velocity is the ATRs of distance-to-level covered over this window at the moment the test forms.")

velFastThr = input.float(1.2, "Fast approach threshold (ATRs covered)", group=G_VEL, minval=0.2, step=0.1,
     tooltip="A test is tagged FAST (spike) when price covered at least this many ATRs toward the level over the approach window; otherwise SLOW (grind).\n\nThe idea being tested: spikes into a level exhaust the aggressor and bounce, while slow grinds absorb the level and break it. The Flow @ zone panel reads this INSIDE each flow bucket (DEF·Fast vs DEF·Slow, ATK·Fast vs ATK·Slow) because velocity is a second-order factor — it only means something conditional on flow. Your own chart's numbers decide whether it holds up.")

// ─────────── 7 · MARKET REGIME ───────────
regLen = input.int(30, "Regime window (bars)", group=G_REG, minval=10, maxval=120,
     tooltip="Lookback for the Kaufman efficiency ratio: the absolute net move over the window divided by the sum of bar-to-bar moves. Near 1 = price actually went somewhere (trend); near 0 = it churned in place (range).\n\n30 bars is 1 hour on a 2-minute chart — deliberately a different, slower timescale than the 5-bar approach velocity. This is the AMBIENT environment; velocity is the microstructure.")

regTrendThr = input.float(0.30, "Trend threshold (efficiency ratio)", group=G_REG, minval=0.05, maxval=0.90, step=0.05,
     tooltip="Efficiency ratio at or above this = TRENDING; below = RANGE.\n\nIn a trending regime each directional test is further tagged WITH-trend (pressure direction matches the window's net direction) or AGAINST-trend. That three-way split — with-trend / counter-trend / range — is what the ATK rows of the Flow @ zone panel report, and it is the answer to 'when can I trust a break lean?'\n\n0.30 is a starting point, not a calibration. Watch the panel and move it.")

// ─────────── 8 · CVD CONFLUENCE (OPTIONAL) ───────────
// Optional handshake with the free Elite CVD Oscillator. Off by default so this
// script runs stand-alone.
useConf = input.bool(false, "Enable CVD confluence", group=G_CONF,
     tooltip="When a DEFENDED zone test coincides with CVD absorption defending that same level, the setup is tagged as CONFLUENCE: a ★ in the Flow column, a ★ in the setup log, and a maximum-thickness solid green line.\n\nThe reasoning: a flow lean says pressure favors the level; absorption says someone is actively taking the other side of the aggressor at it. Both at once is a materially different setup from either alone.\n\nRequires wiring the two sources below to the Elite CVD Oscillator (free). Off by default — this script works fine without it.")

cvdAbsorbSrc = input.source(close, "  ↳ CVD AbsorbFlag source", group=G_CONF,
     tooltip="Point this at the Elite CVD Oscillator's 'AbsorbFlag' output — it carries 1 when absorption is active, 0 otherwise. Only read when the toggle above is ON.")

cvdAbsorbDirSrc = input.source(close, "  ↳ CVD AbsorbDir source", group=G_CONF,
     tooltip="Point this at the Elite CVD Oscillator's 'AbsorbDir' output. +1 = buyers defending (bullish absorption), -1 = sellers defending (bearish). Used to confirm the absorption is defending the level in the RIGHT direction — absorption against the level is not confluence.")

confWin = input.int(2, "  ↳ Absorption match window (bars)", group=G_CONF, minval=0, maxval=5,
     tooltip="How many bars around the test entry to look for a coinciding absorption event — absorption and the test rarely land on the exact same bar. 2 = check the entry bar and the 2 bars before it.")

// ─────────── 9 · LINE APPEARANCE & MARKERS ───────────
holdCol = input.color(color.new(color.lime, 0), "Role-strong color", group=G_LINE,
     tooltip="Color for a level that HOLDS in its current role better than the control baseline (SUPPORT if below price, RESIST if above).")

breakCol = input.color(color.new(color.red, 0), "Break color", group=G_LINE,
     tooltip="Color for a level that BREAKS more than baseline in its current role — a magnet, or low-friction price.")

neutCol = input.color(color.new(color.gray, 30), "Neutral color", group=G_LINE,
     tooltip="Color for a level that is at baseline (coin-flip), lacks tests in its current role, or whose lift has not yet cleared the significance threshold for its sample size. Most levels look like this early on, and that is correct.")

lineColorMode = input.string("Blend (flow priority)", "Line color driver", group=G_LINE,
     options=["Historical lift","Live flow","Blend (flow priority)"],
     tooltip="What drives the line color.\n\nHistorical lift: the level's own hold/break record versus baseline. Slow, evidence-based, ignores what flow is doing right now.\n\nLive flow: the most recent test's delta pressure (DEF green / ATK red / NEU gray). Fast and reactive, but a single touch can recolor a level.\n\nBlend (default): use flow when a live lean exists, fall back to history otherwise. Best of both.\n\nExpired leans (see Delta Pressure) fall back to history in every mode.")

flowGuard = input.bool(true, "Concordance guard", group=G_LINE,
     tooltip="Stops a single flow read from recoloring a level with a STRONG opposite history. A lone 'Defended' touch won't turn a chronic BREAK level green, and a lone 'Attacked' touch won't turn a proven HOLD level red. Guarded levels keep their historical color, width and opacity.\n\nTurn it off for raw flow-priority behavior.")

guardLiftThr = input.float(0.15, "Guard: opposite-history strength (lift)", group=G_LINE, minval=0.0, step=0.05,
     tooltip="How strong the opposite history must be to block a flow override, expressed as hold-rate lift. 0.15 means flow cannot override a level whose history runs 15 percentage points against it.\n\nLower = stricter guard (blocks more overrides); higher = lets flow override all but the most extreme levels.")

flowWidthBoost = input.int(1, "Flow width boost (DEF/ATK)", group=G_LINE, minval=0, maxval=4,
     tooltip="Extra line thickness added when a level's most recent flow read is directional (Defended or Attacked). Makes flow-active levels pop out from the rest. 0 = off.")

flowOpaque = input.bool(true, "Full opacity on flow-active levels", group=G_LINE,
     tooltip="When a level has a directional flow lean, draw it fully opaque so it stands out from levels that have not resolved yet.")

styleByFlow = input.bool(true, "Style lines by flow (solid = defended, dashed = attacked)", group=G_LINE,
     tooltip="Encodes the flow lean in the line STYLE for an at-a-glance read: solid = defended / hold lean, dashed = attacked / break lean. Respects the concordance guard, so guarded levels stay solid. Turn off for all-solid lines.")

showVelGlyph = input.bool(true, "Mark approach velocity on active levels", group=G_LINE,
     tooltip="Draws a small chevron at the right edge of each level whose most recent (unexpired) test carried a directional flow lean, encoding how price approached.\n\nSingle chevron = fast (spike), double chevron = slow (grind). Attack chevrons point right, through the level, in red; defend chevrons point left, off it, in lime. So » is a fast attack and ≫ a slow grind into a break lean.\n\nExpires with the flow lean.")

velGlyphSize = input.string("Small", "Velocity glyph size", group=G_LINE, options=["Tiny","Small","Normal"],
     tooltip="Font size of the approach-velocity chevrons.")

// ─────────── 10 · PANELS & LABELS ───────────
cleanChart = input.bool(false, "Clean chart (hide all tables/panels/label)", group=G_PANEL,
     tooltip="One switch to hide the ranked table, the Flow @ zone panel, the setup log and the lean label — for a clean chart while trading, on mobile, or for screenshots. Lines and their colors stay.\n\nOverrides the individual show toggles below; nothing stops being tracked, it just stops being drawn.")

showTable = input.bool(true, "Show ranked table", group=G_PANEL,
     tooltip="The top-5 levels near price, ranked by proximity x reaction reliability x tier weight. Columns: distance in ATRs, tests in role, reaction rate versus baseline, lift, tag, and the current flow lean with its measured hold rate.")

tblPosStr = input.string("Top Right", "Ranked table position", group=G_PANEL,
     options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Bottom Right","Bottom Left","Bottom Center"],
     tooltip="Where the ranked table is anchored. Note the Flow @ zone panel is fixed bottom-right, so avoid that corner here.")

tblSizeStr = input.string("Small", "Ranked table text size", group=G_PANEL,
     options=["Tiny","Small","Normal","Large"],
     tooltip="Font size of the ranked table.")

showFlow = input.bool(true, "Show Flow @ zone validation panel", group=G_PANEL,
     tooltip="The honesty panel, bottom right. Hold rate for Defended vs Neutral vs Attacked tests, plus the flow x velocity split (DEF·Fast / DEF·Slow / ATK·Fast / ATK·Slow) and the flow x regime split (DEF·Trd / DEF·Rng / ATK·TW / ATK·TA / ATK·Rng).\n\nRead this before you trade the lean. If Defended% sits well above Attacked%, the delta-pressure read is separating outcomes on your chart. If they're flat against each other, it isn't — use the lines as plain structure instead. Watch the n column: small samples say nothing.")

showLean = input.bool(true, "Show live lean label at active zone", group=G_PANEL,
     tooltip="Draws a label next to the nearest level with a live flow read, showing whether current flow is DEFENDING (lean hold) or ATTACKING (lean break), the approach speed, and for attacks the regime alignment.")

leanProxATR = input.float(0.5, "Lean label proximity (ATR)", group=G_PANEL, minval=0.0,
     tooltip="How close (in ATRs) price must be to a level for its lean label to appear. Larger = the label shows earlier as price approaches and stays visible longer. 0 = only when the bar is physically inside the zone band, which can flicker.")

// ─────────── 11 · SETUP LOG ───────────
showLog = input.bool(false, "Show on-chart setup log", group=G_LOG,
     tooltip="A rolling table of the most recent resolved zone tests: entry lean → realized outcome. Did the lean pay?\n\nThis is the fastest way to build intuition for what DEF and ATK actually look like on your instrument, because you can scroll back to each row's bar and see the price action that produced it.")

logRows = input.int(12, "Setup log rows", group=G_LOG, minval=3, maxval=25,
     tooltip="How many recent resolved setups to show. The engine keeps the last 60 regardless of this setting.")

logSizeStr = input.string("Tiny", "Setup log text size", group=G_LOG, options=["Tiny","Small","Normal"],
     tooltip="Font size of the on-chart setup log.")

logPosStr = input.string("Middle Left", "Setup log position", group=G_LOG,
     options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Bottom Right","Bottom Left","Bottom Center"],
     tooltip="Where the on-chart setup log is anchored.")

// ─────────── 12 · ALERTS ───────────
// Two independent ways to get notified. Pick ONE — running both for the same
// events gives you duplicate notifications.
//
//  A) Classic (default, nothing to enable): right-click the chart → Add alert →
//     pick this indicator → choose a condition from the dropdown. One alert per
//     condition, fixed message text.
//
//  B) Alert Engine (toggle below): create ONE alert on this indicator with the
//     condition set to "Any alert() function call". The toggles below then
//     decide which events fire through it, and changing them takes effect
//     without recreating the alert. Messages are built live and carry the
//     measured hold rate for the exact condition that fired.
enableAlertEngine = input.bool(false, "Enable Alert Engine", group=G_ALERT,
     tooltip="Master switch for option B above. Create ONE alert on this indicator with the condition \"Any alert() function call\", then use the toggles below to decide what fires through it.\n\nAlerts are EDGE-TRIGGERED: they fire on the bar a level's state is entered — a directional flow lean forms, confluence arms, price closes into a role-strong zone — not on every bar price sits near the level. Confirmed bars only, so no intrabar phantoms that roll back before the close.\n\nEvery message carries the LIVE measured hold rate for the exact condition that fired, read from the same ledger as the Flow @ zone panel, so the notification itself tells you what the setup has been worth on YOUR chart.\n\n⚠ The classic per-condition alerts still exist. Do not run both for the same events or you will get duplicates.")

alertConfEng = input.bool(true, "⭐ Confluence (flow + absorption defend)", group=G_ALERT,
     tooltip="The strongest setup this script produces: a DEFENDED lean coinciding with CVD absorption defending the same level. Requires the CVD confluence handshake in group 8 to be wired. The message carries the measured DEF hold rate.")

alertDefEng = input.bool(true, "🟢 Defended (lean HOLD)", group=G_ALERT,
     tooltip="Flow is defending the tested level — buyers into support, sellers into resistance. The message carries the measured DEF hold rate and the approach velocity (fast spike / slow grind).\n\nSuppressed on any bar where the ⭐ Confluence alert fires, so you get one notification, the stronger one.")

alertAtkEng = input.bool(true, "🔴 Attacked (lean BREAK)", group=G_ALERT,
     tooltip="Aggressive flow pressing THROUGH the level. The message carries the regime alignment (·with-trend / ·counter-trend / ·range) AND the measured hold rate for that exact regime bucket — the tag names the bucket, the measured rate is the opinion.")

alertStrongEng = input.bool(false, "📍 Approaching role-strong level", group=G_ALERT,
     tooltip="Price comes within 1 ATR of a level whose hold-lift in its current role has cleared the significance threshold. OFF by default — it is context, not an entry trigger, and it fires often.")

// ─────────── DERIVED DISPLAY CONSTANTS ───────────
tblPos = tblPosStr == "Top Left" ? position.top_left : tblPosStr == "Top Center" ? position.top_center : tblPosStr == "Middle Right" ? position.middle_right : tblPosStr == "Middle Left" ? position.middle_left : tblPosStr == "Bottom Right" ? position.bottom_right : tblPosStr == "Bottom Left" ? position.bottom_left : tblPosStr == "Bottom Center" ? position.bottom_center : position.top_right
tblSize = tblSizeStr == "Tiny" ? size.tiny : tblSizeStr == "Normal" ? size.normal : tblSizeStr == "Large" ? size.large : size.small
logPos = logPosStr == "Top Right" ? position.top_right : logPosStr == "Top Center" ? position.top_center : logPosStr == "Middle Right" ? position.middle_right : logPosStr == "Middle Left" ? position.middle_left : logPosStr == "Bottom Right" ? position.bottom_right : logPosStr == "Bottom Left" ? position.bottom_left : logPosStr == "Bottom Center" ? position.bottom_center : position.top_left
logSize = logSizeStr == "Small" ? size.small : logSizeStr == "Normal" ? size.normal : size.tiny
velGlyphSz = velGlyphSize == "Tiny" ? size.tiny : velGlyphSize == "Normal" ? size.normal : size.small

atr = ta.atr(atrLen)
ctrlOffset = 0.37 * tradableStep
zoneW = math.min(zoneATR * atr, 0.4 * ctrlOffset)   // band half-width, capped so it can't reach the control

// ─────────── APPROXIMATE DELTA ───────────
// TradingView has no true bid/ask tape, so we approximate delta with the tick rule
// on lower-tf sub-bars: up-volume minus down-volume, summed across the chart bar.
// Sigma is the stdev of the SIGNED delta — stdev(|delta|) would measure the spread of
// a folded distribution, understating sigma and making the Z thresholds effectively
// tighter than labeled.
sVolArr = request.security_lower_tf(syminfo.tickerid, lowerTf, close >= open ? volume : -volume)
intDelta = array.size(sVolArr) > 0 ? array.sum(sVolArr) : na
// Optional external delta: read the Elite CVD Oscillator's DeltaPerBar export instead.
// A per-bar na from the wired source falls back to the internal estimate so the
// classifier never starves on a data gap. dstd is computed on whichever stream is
// live, so the Z-thresholds stay scaled to the delta they actually judge.
barDelta = useExtDelta ? (na(extDeltaSrc) ? intDelta : extDeltaSrc) : intDelta
dstd     = ta.stdev(nz(barDelta), 50)
// pressure stats [defH, defB, neuH, neuB, atkH, atkB] — real levels only, decisive events only
var array<int> pStats = array.new_int(6, 0)
// flow×velocity INTERACTION stats — real levels, decisive events, directional flow only.
// Velocity is a second-order factor: it matters (if at all) INSIDE a flow bucket, not
// pooled across them. Layout: [defFastH, defFastB, defSlowH, defSlowB, atkFastH, atkFastB, atkSlowH, atkSlowB]
var array<int> ivStats = array.new_int(8, 0)
// flow×REGIME interaction stats — the "when can you trust ATTACKING?" ledger.
// DEF is split trend/range; ATK is split three ways because DIRECTION matters:
// with-trend / against-trend / range.
// Layout: [defTrdH, defTrdB, defRngH, defRngB, atkTW_H, atkTW_B, atkTA_H, atkTA_B, atkRngH, atkRngB]
var array<int> rgStats = array.new_int(10, 0)

// tier significance multiplier for ranking (psychological weight)
tierMult(tier) => tier == 3 ? 1.5 : tier == 2 ? 1.0 : 0.7

// Significance-scaled lift threshold (~1 SE of a p=0.5 proportion).
// n=3 → 29pp, n=10 → 16pp, n=30 → 9pp; floored at 4pp for huge samples.
liftThr(nDec) => nDec > 0 ? math.max(0.04, math.sqrt(0.25 / nDec)) : 1.0

// ─────────── STATE ───────────
var array<float> tLevel = array.new_float()
var array<int>   tTier  = array.new_int()
var array<int>   tArmed = array.new_int()
var array<int>   tTests = array.new_int()
var array<float> tSupH  = array.new_float()
var array<float> tSupB  = array.new_float()
var array<float> tResH  = array.new_float()
var array<float> tResB  = array.new_float()
var array<float> tReact = array.new_float()   // reactions (wick or dwell)
var array<float> tReactN= array.new_float()   // total tests (for reaction-rate)
var array<int>   tLast  = array.new_int()
var array<int>   tLastUpd = array.new_int()
var array<int>   tIsCtl = array.new_int()
var array<int>   tLastPress = array.new_int()   // last test's flow bucket: -1 none, 0 defend, 1 neutral, 2 attack
var array<int>   tPressBar  = array.new_int()   // bar_index the last pressure was recorded (drives expiry)
var array<int>   tConf      = array.new_int()   // 1 = confluence (DEF lean + absorption defending) at last test
var array<int>   tLastVel   = array.new_int()   // last test's approach velocity: -1 none, 0 slow, 1 fast
var array<int>   tLastReg   = array.new_int()   // regime at last test: -9 none, 0 range, ±1 trend dir (expires with lean)

var array<float> peLevel = array.new_float()
var array<int>   peStart = array.new_int()
var array<int>   peSide  = array.new_int()
var array<float> peAtr   = array.new_float()
var array<int>   peCtl   = array.new_int()
var array<int>   peTime  = array.new_int()    // entry timestamp (ms) carried to maturity for logging
var array<int>   peAbs   = array.new_int()    // 1 = absorption defending at entry, carried to maturity for logging
var array<int>   peVel   = array.new_int()    // 1 = fast (spike) approach, 0 = slow (grind)
var array<int>   peReg   = array.new_int()    // regime at entry: 0=range, +1=trend up, -1=trend down

// Lazy decay factor for READ-time weighting (state is also decayed at judgment time;
// this covers the gap since the last judgment).
readF(li) => decayEnabled ? math.pow(0.5, (bar_index - array.get(tLastUpd, li)) / decayHalfLife) : 1.0

// ─────────── SETUP LOG (matured real-level events: entry lean → outcome) ───────────
var array<int>   logTime  = array.new_int()
var array<float> logLevel = array.new_float()
var array<int>   logSide  = array.new_int()   // +1 support, -1 resistance
var array<int>   logBkt   = array.new_int()   // 0 defend, 1 neutral, 2 attack
var array<int>   logOut   = array.new_int()   // 1 hold, -1 break
var array<int>   logAbs   = array.new_int()   // 1 = absorption defending at the test

// ─────────── HOISTED SERIES READS ───────────
// processLevel is called conditionally (proximity 'continue', tier toggles), so any
// [] history indexing INSIDE it builds inconsistent buffers. All series reads it
// needs are computed here, unconditionally, every bar.
prevClose  = close[1]
closeVelNb = nz(close[velBars], close)
// ----- REGIME: Kaufman efficiency ratio + signed trend direction -----
// er near 1 = price went somewhere (trend); near 0 = churn (range). Computed here,
// unconditionally, every bar — captured per-test at the moment the test forms.
erNum    = math.abs(close - nz(close[regLen], close))
erDen    = math.sum(math.abs(ta.change(close)), regLen)
effRatio = erDen > 0 ? erNum / erDen : 0.0
int regNow = effRatio >= regTrendThr ? (close > nz(close[regLen], close) ? 1 : -1) : 0   // 0=range, ±1=trend dir
bool absDefBull = false
bool absDefBear = false
if useConf
    for w = 0 to confWin
        if cvdAbsorbSrc[w] > 0
            if cvdAbsorbDirSrc[w] > 0
                absDefBull := true
            if cvdAbsorbDirSrc[w] < 0
                absDefBear := true

// ─────────── LEVEL POOL ───────────
ensureLevel(price, tier, isCtl) =>
    idx = array.indexof(tLevel, price)
    if idx == -1
        if array.size(tLevel) >= maxTracked
            worst = 0
            worstScore = 1.0e18
            for k = 0 to array.size(tLevel) - 1
                sc = array.get(tTests, k) + array.get(tLast, k) / 100000.0
                if sc < worstScore
                    worstScore := sc
                    worst := k
            array.remove(tLevel, worst)
            array.remove(tTier, worst)
            array.remove(tArmed, worst)
            array.remove(tTests, worst)
            array.remove(tSupH, worst)
            array.remove(tSupB, worst)
            array.remove(tResH, worst)
            array.remove(tResB, worst)
            array.remove(tReact, worst)
            array.remove(tReactN, worst)
            array.remove(tLast, worst)
            array.remove(tLastUpd, worst)
            array.remove(tIsCtl, worst)
            array.remove(tLastPress, worst)
            array.remove(tPressBar, worst)
            array.remove(tConf, worst)
            array.remove(tLastVel, worst)
            array.remove(tLastReg, worst)
        array.push(tLevel, price)
        array.push(tTier, tier)
        array.push(tArmed, 1)
        array.push(tTests, 0)
        array.push(tSupH, 0.0)
        array.push(tSupB, 0.0)
        array.push(tResH, 0.0)
        array.push(tResB, 0.0)
        array.push(tReact, 0.0)
        array.push(tReactN, 0.0)
        array.push(tLast, 0)
        array.push(tLastUpd, bar_index)
        array.push(tIsCtl, isCtl)
        array.push(tLastPress, -1)
        array.push(tPressBar, 0)
        array.push(tConf, 0)
        array.push(tLastVel, -1)
        array.push(tLastReg, -9)
        idx := array.size(tLevel) - 1
    idx

// ─────────── PROCESS ONE LEVEL (zone-aware debounced test) ───────────
processLevel(lp, tier, isCtl) =>
    idx = ensureLevel(lp, tier, isCtl)
    a = array.get(tArmed, idx)
    if math.abs(close - lp) >= armATR * atr
        array.set(tArmed, idx, 1)
        a := 1
    // zone touch: bar range enters the band around lp
    if a == 1 and low <= lp + zoneW and high >= lp - zoneW
        array.set(tTests, idx, array.get(tTests, idx) + 1)
        array.set(tLast, idx, bar_index)
        array.set(tArmed, idx, 0)
        side = prevClose < lp ? -1 : 1
        // ----- approach velocity — ATRs of distance-to-level covered over the window -----
        distThen = math.abs(closeVelNb - lp)
        distNow  = math.abs(close - lp)
        velATR   = atr > 0 ? (distThen - distNow) / atr : 0.0
        isFast   = velATR >= velFastThr
        // ----- CVD confluence: is absorption DEFENDING this level near the test? -----
        // (reads the hoisted per-side flags — no series indexing in here)
        absAligned = isCtl == 0 and useConf and (side == 1 ? absDefBull : absDefBear)
        array.push(peLevel, lp)
        array.push(peStart, bar_index)
        array.push(peSide, side)
        array.push(peAtr, atr)
        array.push(peCtl, isCtl)
        array.push(peTime, time)
        array.push(peAbs, absAligned ? 1 : 0)
        array.push(peVel, isFast ? 1 : 0)
        array.push(peReg, regNow)
        // ----- capture live flow lean at the moment the test forms (real levels only) -----
        if isCtl == 0
            bkt = -1
            if not na(barDelta) and dstd > 0
                attackE  = side == 1 ? -barDelta : barDelta
                attackZE = attackE / dstd
                bkt := attackZE <= defendZ ? 0 : (attackZE >= attackThr ? 2 : 1)
            array.set(tLastPress, idx, bkt)
            array.set(tPressBar, idx, bar_index)
            // confluence = defended lean AND absorption defending the level
            array.set(tConf, idx, (bkt == 0 and absAligned) ? 1 : 0)
            // persist the approach velocity of THIS test for the visual encoding
            array.set(tLastVel, idx, isFast ? 1 : 0)
            // persist the regime of THIS test (drives the enriched lean label)
            array.set(tLastReg, idx, regNow)

// ─────────── PROCESS A TIER ───────────
processTier(step, tier, show, rng) =>
    if show and step > 0
        base = math.round(close / step) * step
        for i = -rng to rng
            lp = math.round_to_mintick(base + i * step)
            if math.abs(lp - close) > atr * atrMult
                continue
            processLevel(lp, tier, 0)
            cp = math.round_to_mintick(lp + ctrlOffset)
            processLevel(cp, 0, 1)

// ─────────── JUDGE PENDING EVENTS (first-touch, path-aware) ───────────
// Each pending test is walked bar by bar. HOLD the moment the hold target
// (lp ± holdATR·ATR₀ in the approach-origin direction) is TOUCHED by high/low; BREAK
// the moment the break level is touched. On a bar touching both, BREAK wins
// (conservative). If neither is touched within fwdBars, the test times out neutral.
// Judging on touches rather than a close snapshot N bars later matters: a 2-ATR bounce
// that later retraced would otherwise score as neutral or a break, and every downstream
// statistic (lift, DEF/ATK rates, panels) would inherit that error.
judgePending() =>
    if array.size(peStart) > 0
        i = array.size(peStart) - 1
        while i >= 0
            startB = array.get(peStart, i)
            if bar_index > startB   // evaluate from the bar after entry
                lp    = array.get(peLevel, i)
                side  = array.get(peSide, i)
                a0    = array.get(peAtr, i)
                holdTouch  = side == 1 ? high >= lp + holdATR  * a0 : low  <= lp - holdATR  * a0
                breakTouch = side == 1 ? low  <= lp - breakATR * a0 : high >= lp + breakATR * a0
                entryOff = bar_index - startB
                timedOut = entryOff >= fwdBars
                // 9 = still open; break beats hold on a same-bar double touch
                outcome = breakTouch ? -1 : holdTouch ? 1 : timedOut ? 0 : 9

                if outcome != 9
                    // ----- reaction classification (entry-bar shape) -----
                    zoneWm = math.min(zoneATR * a0, 0.4 * ctrlOffset)
                    hh = high[entryOff]
                    ll = low[entryOff]
                    oo = open[entryOff]
                    cc = close[entryOff]
                    rr = hh - ll
                    wickReact = false
                    if side == -1
                        upW = rr > 0 ? (hh - math.max(oo, cc)) / rr : 0.0
                        wickReact := upW >= 0.4
                    else
                        loW = rr > 0 ? (math.min(oo, cc) - ll) / rr : 0.0
                        wickReact := loW >= 0.4
                    dwell = false
                    if entryOff >= 2
                        in1 = low[entryOff - 1] <= lp + zoneWm and high[entryOff - 1] >= lp - zoneWm
                        in2 = low[entryOff - 2] <= lp + zoneWm and high[entryOff - 2] >= lp - zoneWm
                        dwell := in1 or in2
                    reacted = wickReact or dwell

                    // ----- delta-pressure + velocity classification -----
                    isCtlEv = array.get(peCtl, i)
                    dAtTest = barDelta[entryOff]
                    sAtTest = dstd[entryOff]
                    if isCtlEv == 0 and outcome != 0 and not na(dAtTest) and sAtTest > 0
                        attack  = side == 1 ? -dAtTest : dAtTest
                        attackZ = attack / sAtTest
                        bkt = attackZ <= defendZ ? 0 : (attackZ >= attackThr ? 2 : 1)
                        bi  = bkt * 2 + (outcome == 1 ? 0 : 1)
                        array.set(pStats, bi, array.get(pStats, bi) + 1)
                        // flow×velocity interaction (DEF/ATK only — velocity is read inside flow)
                        if bkt == 0 or bkt == 2
                            iv = (bkt == 0 ? 0 : 4) + (array.get(peVel, i) == 1 ? 0 : 2) + (outcome == 1 ? 0 : 1)
                            array.set(ivStats, iv, array.get(ivStats, iv) + 1)
                            // flow×regime interaction — the ATK-trust ledger.
                            // Alignment uses the regime AT ENTRY (peReg) and this lean's pressure direction.
                            regE = array.get(peReg, i)
                            presDirJ = bkt == 0 ? (side == 1 ? 1 : -1) : (side == 1 ? -1 : 1)
                            rgiBase = bkt == 0 ? (regE != 0 ? 0 : 2) : (regE == 0 ? 8 : (presDirJ == regE ? 4 : 6))
                            rgi = rgiBase + (outcome == 1 ? 0 : 1)
                            array.set(rgStats, rgi, array.get(rgStats, rgi) + 1)
                        // append to rolling setup log (cap at 60, newest at end)
                        array.push(logTime,  array.get(peTime, i))
                        array.push(logLevel, lp)
                        array.push(logSide,  side)
                        array.push(logBkt,   bkt)
                        array.push(logOut,   outcome)
                        array.push(logAbs,   array.get(peAbs, i))
                        if array.size(logTime) > 60
                            array.shift(logTime)
                            array.shift(logLevel)
                            array.shift(logSide)
                            array.shift(logBkt)
                            array.shift(logOut)
                            array.shift(logAbs)

                    li = array.indexof(tLevel, lp)
                    if li != -1
                        if decayEnabled
                            gap = bar_index - array.get(tLastUpd, li)
                            if gap > 0
                                f = math.pow(0.5, gap / decayHalfLife)
                                array.set(tSupH, li, array.get(tSupH, li) * f)
                                array.set(tSupB, li, array.get(tSupB, li) * f)
                                array.set(tResH, li, array.get(tResH, li) * f)
                                array.set(tResB, li, array.get(tResB, li) * f)
                                array.set(tReact, li, array.get(tReact, li) * f)
                                array.set(tReactN, li, array.get(tReactN, li) * f)
                        array.set(tLastUpd, li, bar_index)
                        // reaction counters (every judged test counts)
                        array.set(tReactN, li, array.get(tReactN, li) + 1.0)
                        if reacted
                            array.set(tReact, li, array.get(tReact, li) + 1.0)
                        // hold/break counters (only decisive outcomes)
                        if outcome != 0
                            if side == 1
                                if outcome == 1
                                    array.set(tSupH, li, array.get(tSupH, li) + 1.0)
                                else
                                    array.set(tSupB, li, array.get(tSupB, li) + 1.0)
                            else
                                if outcome == 1
                                    array.set(tResH, li, array.get(tResH, li) + 1.0)
                                else
                                    array.set(tResB, li, array.get(tResB, li) + 1.0)
                    array.remove(peLevel, i)
                    array.remove(peStart, i)
                    array.remove(peSide, i)
                    array.remove(peAtr, i)
                    array.remove(peCtl, i)
                    array.remove(peTime, i)
                    array.remove(peAbs, i)
                    array.remove(peVel, i)
                    array.remove(peReg, i)
            i := i - 1

// ─────────── RUN ───────────
judgePending()
processTier(majorStep,    3, showMajor,    8)
processTier(tradableStep, 2, showTradable, 12)
processTier(sniperStep,   1, showSniper,   20)

// ----- flow-lean expiry: a stale read must stop coloring lines and arming alerts -----
if array.size(tLevel) > 0
    for k = 0 to array.size(tLevel) - 1
        if array.get(tLastPress, k) >= 0 and bar_index - array.get(tPressBar, k) > flowExpiryBars
            array.set(tLastPress, k, -1)
            array.set(tConf, k, 0)
            array.set(tLastVel, k, -1)
            array.set(tLastReg, k, -9)

// ─────────── BASELINE (pooled control levels, read-time decayed) ───────────
baseSupH = 0.0
baseSupB = 0.0
baseResH = 0.0
baseResB = 0.0
baseRx   = 0.0
baseRxN  = 0.0
if array.size(tLevel) > 0
    for k = 0 to array.size(tLevel) - 1
        if array.get(tIsCtl, k) == 1
            f = readF(k)
            baseSupH += array.get(tSupH, k) * f
            baseSupB += array.get(tSupB, k) * f
            baseResH += array.get(tResH, k) * f
            baseResB += array.get(tResB, k) * f
            baseRx   += array.get(tReact, k) * f
            baseRxN  += array.get(tReactN, k) * f
baseSupRate = (baseSupH + baseSupB) > 0 ? baseSupH / (baseSupH + baseSupB) : 0.5
baseResRate = (baseResH + baseResB) > 0 ? baseResH / (baseResH + baseResB) : 0.5
baseRxRate  = baseRxN > 0 ? baseRx / baseRxN : 0.5

// ─────────── DRAW LINES ───────────
var array<line>  drawn     = array.new<line>()
var array<label> velGlyphs = array.new<label>()
if barstate.islast
    while array.size(drawn) > 0
        line.delete(array.pop(drawn))
    while array.size(velGlyphs) > 0
        label.delete(array.pop(velGlyphs))
    for k = 0 to array.size(tLevel) - 1
        if array.get(tIsCtl, k) == 1
            continue
        lp = array.get(tLevel, k)
        if math.abs(lp - close) > atr * atrMult
            continue
        tier = array.get(tTier, k)
        okTier = (tier == 3 and showMajor) or (tier == 2 and showTradable) or (tier == 1 and showSniper)
        if not okTier
            continue
        fK = readF(k)   // lazy decay at read time
        isSup = lp < close
        roleH = (isSup ? array.get(tSupH, k) : array.get(tResH, k)) * fK
        roleB = (isSup ? array.get(tSupB, k) : array.get(tResB, k)) * fK
        roleBase = isSup ? baseSupRate : baseResRate
        roleDec = roleH + roleB
        roleRate = roleDec > 0 ? roleH / roleDec : na
        lift = na(roleRate) ? na : (roleRate - roleBase)
        rxN = array.get(tReactN, k) * fK
        rxRate = rxN > 0 ? array.get(tReact, k) * fK / rxN : na
        // --- historical-lift color: significance-scaled threshold ---
        thrK = liftThr(roleDec)
        colLift = neutCol
        if roleDec >= minTests and not na(lift)
            colLift := lift >= thrK ? holdCol : (lift <= -thrK ? breakCol : neutCol)
        // --- live-flow color (most recent test's pressure; expired leans are already -1) ---
        bktL = array.get(tLastPress, k)
        colFlow = bktL == 0 ? holdCol : bktL == 2 ? breakCol : bktL == 1 ? neutCol : na
        flowDir = bktL == 0 or bktL == 2   // directional lean present
        // --- concordance guard: flow may NOT override a strong opposite history ---
        flowOpposes = flowGuard and not na(lift) and ((bktL == 0 and lift <= -guardLiftThr) or (bktL == 2 and lift >= guardLiftThr))
        useFlow  = not na(colFlow) and not flowOpposes   // flow trusted for color
        boostFlow = flowDir and not flowOpposes          // flow trusted for width/opacity
        // --- choose color by mode ---
        col = colLift
        if lineColorMode == "Live flow"
            col := useFlow ? colFlow : (flowOpposes ? colLift : neutCol)
        else if lineColorMode == "Blend (flow priority)"
            col := useFlow ? colFlow : colLift
        // --- thickness: tier + reaction reliability, plus optional flow boost ---
        w = tier == 3 ? 3 : (not na(rxRate) and rxRate >= 0.65 and rxN >= minTests ? 2 : 1)
        if flowWidthBoost > 0 and boostFlow
            w := math.min(w + flowWidthBoost, 6)
        // --- opacity: opaque if resolved, or (optionally) if flow-active and trusted ---
        transp = roleDec >= minTests ? 0 : 68
        if flowOpaque and boostFlow
            transp := 0
        // --- line style: dashed = trusted attack lean (break), solid otherwise (guard-aware) ---
        lstyle = line.style_solid
        if styleByFlow and boostFlow and bktL == 2
            lstyle := line.style_dashed
        // --- CONFLUENCE override: DEF lean + absorption defending → max thickness, solid, opaque green ---
        if array.get(tConf, k) == 1
            col := holdCol
            w := 6
            transp := 0
            lstyle := line.style_solid
        ln = line.new(bar_index - 1, lp, bar_index, lp, color=color.new(col, transp), width=w, style=lstyle, extend=extend.both)
        array.push(drawn, ln)
        // ----- approach-velocity glyph (flow-color; encodes fast/slow) -----
        velK = array.get(tLastVel, k)
        if showVelGlyph and bktL >= 0 and velK >= 0 and (bktL == 0 or bktL == 2)
            isAtk = bktL == 2
            fast  = velK == 1
            // attack points right (through the level), defend points left (off it);
            // doubled chevron = slow (the stronger read on both sides).
            gTxt = isAtk ? (fast ? "»" : "≫") : (fast ? "«" : "«≪")
            gCol = isAtk ? color.new(color.red, 0) : color.new(color.lime, 0)
            gl = label.new(bar_index + 22, lp, gTxt, xloc=xloc.bar_index, style=label.style_none, textcolor=gCol, size=velGlyphSz)
            array.push(velGlyphs, gl)

// ─────────── RANKED TABLE ───────────
var table tbl = table.new(tblPos, 7, 6, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.new(color.gray, 60))
if barstate.islast and showTable and not cleanChart
    // chart-wide hold-rate per flow bucket (from the validation stats) for the Flow column
    fdH = array.get(pStats, 0)
    fdB = array.get(pStats, 1)
    fnH = array.get(pStats, 2)
    fnB = array.get(pStats, 3)
    faH = array.get(pStats, 4)
    faB = array.get(pStats, 5)
    hpDef = (fdH + fdB) > 0 ? fdH * 100.0 / (fdH + fdB) : na
    hpNeu = (fnH + fnB) > 0 ? fnH * 100.0 / (fnH + fnB) : na
    hpAtk = (faH + faB) > 0 ? faH * 100.0 / (faH + faB) : na
    table.cell(tbl, 0, 0, "Level",  text_color=color.aqua, text_size=tblSize)
    table.cell(tbl, 1, 0, "ΔATR",   text_color=color.aqua, text_size=tblSize)
    table.cell(tbl, 2, 0, "Tests",  text_color=color.aqua, text_size=tblSize)
    table.cell(tbl, 3, 0, "Rx%·b" + str.tostring(baseRxRate * 100, "0"), text_color=color.aqua, text_size=tblSize)
    table.cell(tbl, 4, 0, "Lift",   text_color=color.aqua, text_size=tblSize)
    table.cell(tbl, 5, 0, "Tag",    text_color=color.aqua, text_size=tblSize)
    table.cell(tbl, 6, 0, "Flow",   text_color=color.aqua, text_size=tblSize)
    // clear stale data rows so unused rows don't render as empty boxes (table shrinks to fit)
    table.clear(tbl, 0, 1, 6, 5)
    candIdx = array.new_int()
    candRel = array.new_float()
    for k = 0 to array.size(tLevel) - 1
        if array.get(tIsCtl, k) == 1
            continue
        lp = array.get(tLevel, k)
        distA = atr > 0 ? math.abs(lp - close) / atr : 999.0
        if distA > atrMult
            continue
        fK = readF(k)
        isSup = lp < close
        roleH = (isSup ? array.get(tSupH, k) : array.get(tResH, k)) * fK
        roleB = (isSup ? array.get(tSupB, k) : array.get(tResB, k)) * fK
        roleDec = roleH + roleB
        rxN = array.get(tReactN, k) * fK
        if roleDec < minTests and rxN < minTests
            continue
        rxRate = rxN > 0 ? array.get(tReact, k) * fK / rxN : 0.5
        tier = array.get(tTier, k)
        rel = tierMult(tier) * (0.5 + rxRate) * math.min(rxN, 30.0) / (1 + distA)
        array.push(candIdx, k)
        array.push(candRel, rel)
    shown = 0
    while shown < 5 and array.size(candRel) > 0
        best = 0
        bestv = -1.0
        for m = 0 to array.size(candRel) - 1
            if array.get(candRel, m) > bestv
                bestv := array.get(candRel, m)
                best := m
        k = array.get(candIdx, best)
        fK = readF(k)
        lp = array.get(tLevel, k)
        isSup = lp < close
        roleH = (isSup ? array.get(tSupH, k) : array.get(tResH, k)) * fK
        roleB = (isSup ? array.get(tSupB, k) : array.get(tResB, k)) * fK
        roleBase = isSup ? baseSupRate : baseResRate
        roleDec = roleH + roleB
        roleRate = roleDec > 0 ? roleH / roleDec : na
        lift = na(roleRate) ? na : (roleRate - roleBase)
        rxN = array.get(tReactN, k) * fK
        rxRate = rxN > 0 ? array.get(tReact, k) * fK / rxN : na
        rxLift = na(rxRate) ? na : (rxRate - baseRxRate)
        distA = atr > 0 ? math.abs(lp - close) / atr : 999.0
        dir = lp >= close ? "▲" : "▼"
        thrK = liftThr(roleDec)
        tag = na(lift) ? "—" : (lift >= thrK ? (isSup ? "SUPPORT" : "RESIST") : (lift <= -thrK ? "BREAK" : "NEU"))
        tagCol = na(lift) ? color.gray : (lift >= thrK ? color.lime : (lift <= -thrK ? color.red : color.gray))
        rxCol = na(rxLift) ? color.gray : (rxLift >= 0.05 ? color.lime : (rxLift <= -0.05 ? color.red : color.silver))
        row = shown + 1
        table.cell(tbl, 0, row, dir + " " + str.tostring(lp, format.mintick), text_color=color.white, text_size=tblSize)
        table.cell(tbl, 1, row, str.tostring(distA, "0.0"), text_color=color.silver, text_size=tblSize)
        table.cell(tbl, 2, row, str.tostring(math.round(roleDec)), text_color=color.silver, text_size=tblSize)
        table.cell(tbl, 3, row, na(rxRate) ? "—" : str.tostring(rxRate * 100, "0"), text_color=rxCol, text_size=tblSize)
        table.cell(tbl, 4, row, na(lift) ? "—" : ((lift >= 0 ? "+" : "") + str.tostring(lift * 100, "0") + "pp"), text_color=tagCol, text_size=tblSize)
        table.cell(tbl, 5, row, tag, text_color=tagCol, text_size=tblSize)
        // Flow lean for this level (from its most recent test's entry-bar pressure; expired = —)
        bkt = array.get(tLastPress, k)
        isConf = array.get(tConf, k) == 1
        flowLbl = bkt == 0 ? "DEF" : bkt == 2 ? "ATK" : bkt == 1 ? "NEU" : "—"
        flowPct = bkt == 0 ? hpDef : bkt == 2 ? hpAtk : bkt == 1 ? hpNeu : na
        flowTxt = bkt < 0 ? "—" : (na(flowPct) ? flowLbl : flowLbl + " " + str.tostring(flowPct, "0") + "%")
        flowTxt := isConf ? "★ " + flowTxt : flowTxt
        flowCol = bkt == 0 ? color.lime : bkt == 2 ? color.red : bkt == 1 ? color.silver : color.gray
        flowCol := isConf ? color.new(color.lime, 0) : flowCol
        table.cell(tbl, 6, row, flowTxt, text_color=flowCol, text_size=tblSize)
        array.remove(candIdx, best)
        array.remove(candRel, best)
        shown := shown + 1

// ─────────── DELTA-PRESSURE + VELOCITY VALIDATION PANEL ───────────
// The honesty panel: does the delta-pressure read actually separate outcomes on THIS
// chart? If "Defended" hold% sits well above "Attacked" hold%, the edge is real here;
// if the two are flat against each other, it isn't, and the lean should be ignored.
// Velocity is shown as the flow×velocity INTERACTION — approach speed only means
// something conditional on flow, so a pooled fast/slow split would average opposite
// conditional effects together and read as no-edge.
var table ptbl = table.new(position.bottom_right, 3, 13, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.new(color.gray, 60))
if showFlow and barstate.islast and not cleanChart
    defH = array.get(pStats, 0)
    defB = array.get(pStats, 1)
    neuH = array.get(pStats, 2)
    neuB = array.get(pStats, 3)
    atkH = array.get(pStats, 4)
    atkB = array.get(pStats, 5)
    defN = defH + defB
    neuN = neuH + neuB
    atkN = atkH + atkB
    rD = defN > 0 ? defH * 100.0 / defN : na
    rN = neuN > 0 ? neuH * 100.0 / neuN : na
    rA = atkN > 0 ? atkH * 100.0 / atkN : na
    dfH = array.get(ivStats, 0)
    dfB = array.get(ivStats, 1)
    dsH = array.get(ivStats, 2)
    dsB = array.get(ivStats, 3)
    afH = array.get(ivStats, 4)
    afB = array.get(ivStats, 5)
    asH = array.get(ivStats, 6)
    asB = array.get(ivStats, 7)
    dfN = dfH + dfB
    dsN = dsH + dsB
    afN = afH + afB
    asN = asH + asB
    rDF = dfN > 0 ? dfH * 100.0 / dfN : na
    rDS = dsN > 0 ? dsH * 100.0 / dsN : na
    rAF = afN > 0 ? afH * 100.0 / afN : na
    rAS = asN > 0 ? asH * 100.0 / asN : na
    table.cell(ptbl, 0, 0, "Flow @ zone", text_color=color.aqua, text_size=size.tiny)
    table.cell(ptbl, 1, 0, "Hold%",       text_color=color.aqua, text_size=size.tiny)
    table.cell(ptbl, 2, 0, "n",           text_color=color.aqua, text_size=size.tiny)
    table.cell(ptbl, 0, 1, "Defended", text_color=color.lime, text_size=size.tiny)
    table.cell(ptbl, 1, 1, na(rD) ? "—" : str.tostring(rD, "0") + "%", text_color=color.lime, text_size=size.tiny)
    table.cell(ptbl, 2, 1, str.tostring(defN), text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 0, 2, "Neutral", text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 1, 2, na(rN) ? "—" : str.tostring(rN, "0") + "%", text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 2, 2, str.tostring(neuN), text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 0, 3, "Attacked", text_color=color.red, text_size=size.tiny)
    table.cell(ptbl, 1, 3, na(rA) ? "—" : str.tostring(rA, "0") + "%", text_color=color.red, text_size=size.tiny)
    table.cell(ptbl, 2, 3, str.tostring(atkN), text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 0, 4, "DEF·Fast", text_color=color.lime, text_size=size.tiny)
    table.cell(ptbl, 1, 4, na(rDF) ? "—" : str.tostring(rDF, "0") + "%", text_color=color.lime, text_size=size.tiny)
    table.cell(ptbl, 2, 4, str.tostring(dfN), text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 0, 5, "DEF·Slow", text_color=color.lime, text_size=size.tiny)
    table.cell(ptbl, 1, 5, na(rDS) ? "—" : str.tostring(rDS, "0") + "%", text_color=color.lime, text_size=size.tiny)
    table.cell(ptbl, 2, 5, str.tostring(dsN), text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 0, 6, "ATK·Fast", text_color=color.red, text_size=size.tiny)
    table.cell(ptbl, 1, 6, na(rAF) ? "—" : str.tostring(rAF, "0") + "%", text_color=color.red, text_size=size.tiny)
    table.cell(ptbl, 2, 6, str.tostring(afN), text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 0, 7, "ATK·Slow", text_color=color.red, text_size=size.tiny)
    table.cell(ptbl, 1, 7, na(rAS) ? "—" : str.tostring(rAS, "0") + "%", text_color=color.red, text_size=size.tiny)
    table.cell(ptbl, 2, 7, str.tostring(asN), text_color=color.silver, text_size=size.tiny)
    // ----- flow×regime interaction (the ATK-trust ledger) -----
    dTrH = array.get(rgStats, 0)
    dTrB = array.get(rgStats, 1)
    dRgH = array.get(rgStats, 2)
    dRgB = array.get(rgStats, 3)
    aTWH = array.get(rgStats, 4)
    aTWB = array.get(rgStats, 5)
    aTAH = array.get(rgStats, 6)
    aTAB = array.get(rgStats, 7)
    aRgH = array.get(rgStats, 8)
    aRgB = array.get(rgStats, 9)
    dTrN = dTrH + dTrB
    dRgN = dRgH + dRgB
    aTWN = aTWH + aTWB
    aTAN = aTAH + aTAB
    aRgN = aRgH + aRgB
    rDT = dTrN > 0 ? dTrH * 100.0 / dTrN : na
    rDR = dRgN > 0 ? dRgH * 100.0 / dRgN : na
    rTW = aTWN > 0 ? aTWH * 100.0 / aTWN : na
    rTA = aTAN > 0 ? aTAH * 100.0 / aTAN : na
    rAR = aRgN > 0 ? aRgH * 100.0 / aRgN : na
    table.cell(ptbl, 0, 8, "DEF·Trd", text_color=color.lime, text_size=size.tiny)
    table.cell(ptbl, 1, 8, na(rDT) ? "—" : str.tostring(rDT, "0") + "%", text_color=color.lime, text_size=size.tiny)
    table.cell(ptbl, 2, 8, str.tostring(dTrN), text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 0, 9, "DEF·Rng", text_color=color.lime, text_size=size.tiny)
    table.cell(ptbl, 1, 9, na(rDR) ? "—" : str.tostring(rDR, "0") + "%", text_color=color.lime, text_size=size.tiny)
    table.cell(ptbl, 2, 9, str.tostring(dRgN), text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 0, 10, "ATK·TW", text_color=color.red, text_size=size.tiny)
    table.cell(ptbl, 1, 10, na(rTW) ? "—" : str.tostring(rTW, "0") + "%", text_color=color.red, text_size=size.tiny)
    table.cell(ptbl, 2, 10, str.tostring(aTWN), text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 0, 11, "ATK·TA", text_color=color.orange, text_size=size.tiny)
    table.cell(ptbl, 1, 11, na(rTA) ? "—" : str.tostring(rTA, "0") + "%", text_color=color.orange, text_size=size.tiny)
    table.cell(ptbl, 2, 11, str.tostring(aTAN), text_color=color.silver, text_size=size.tiny)
    table.cell(ptbl, 0, 12, "ATK·Rng", text_color=color.orange, text_size=size.tiny)
    table.cell(ptbl, 1, 12, na(rAR) ? "—" : str.tostring(rAR, "0") + "%", text_color=color.orange, text_size=size.tiny)
    table.cell(ptbl, 2, 12, str.tostring(aRgN), text_color=color.silver, text_size=size.tiny)

// ─────────── ON-CHART SETUP LOG (entry lean → outcome) ───────────
var table logTbl = table.new(logPos, 5, 26, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.new(color.gray, 60))
if showLog and barstate.islast and not cleanChart
    // clear all rows so unused rows don't render as empty boxes (log shrinks to fit)
    table.clear(logTbl, 0, 0, 4, 25)
    table.cell(logTbl, 0, 0, "Time",  text_color=color.aqua, text_size=logSize)
    table.cell(logTbl, 1, 0, "Level", text_color=color.aqua, text_size=logSize)
    table.cell(logTbl, 2, 0, "Lean",  text_color=color.aqua, text_size=logSize)
    table.cell(logTbl, 3, 0, "Abs",   text_color=color.aqua, text_size=logSize)
    table.cell(logTbl, 4, 0, "Out",   text_color=color.aqua, text_size=logSize)
    nlog = array.size(logTime)
    show = math.min(logRows, nlog)
    if show > 0
        for r = 0 to show - 1
            idx = nlog - 1 - r
            tt = array.get(logTime, idx)
            lv = array.get(logLevel, idx)
            sd = array.get(logSide, idx)
            bk = array.get(logBkt, idx)
            ou = array.get(logOut, idx)
            ab = array.get(logAbs, idx)
            conf = (bk == 0 and ab == 1)
            leanTxt = (conf ? "★" : "") + (bk == 0 ? "DEF" : bk == 2 ? "ATK" : "NEU")
            leanC   = bk == 0 ? color.lime : bk == 2 ? color.red : color.silver
            absTxt  = ab == 1 ? "Y" : "·"
            absC    = ab == 1 ? color.aqua : color.gray
            outTxt  = ou == 1 ? "HOLD" : "BREAK"
            outC    = ou == 1 ? color.lime : color.red
            roleC   = sd == 1 ? "S " : "R "
            table.cell(logTbl, 0, r + 1, str.format_time(tt, "HH:mm", syminfo.timezone), text_color=color.silver, text_size=logSize)
            table.cell(logTbl, 1, r + 1, roleC + str.tostring(lv, format.mintick), text_color=color.white, text_size=logSize)
            table.cell(logTbl, 2, r + 1, leanTxt, text_color=leanC, text_size=logSize)
            table.cell(logTbl, 3, r + 1, absTxt, text_color=absC, text_size=logSize)
            table.cell(logTbl, 4, r + 1, outTxt, text_color=outC, text_size=logSize)

// ─────────── LIVE LEAN LABEL (active zone) ───────────
var label leanLbl = label.new(bar_index, close, "", style=label.style_label_left, color=color.new(color.black, 100), textcolor=color.white, size=size.small)
if showLean and barstate.islast and not cleanChart
    actIdx = -1
    actDist = 1.0e18
    prox = math.max(leanProxATR * atr, zoneW)
    for k = 0 to array.size(tLevel) - 1
        if array.get(tIsCtl, k) == 1
            continue
        if array.get(tLastPress, k) < 0   // only levels with a live (unexpired) flow read
            continue
        lp = array.get(tLevel, k)
        d = math.abs(lp - close)
        if d <= prox and d < actDist
            actDist := d
            actIdx := k
    if actIdx >= 0
        bkt = array.get(tLastPress, actIdx)
        lp2 = array.get(tLevel, actIdx)
        conf = array.get(tConf, actIdx) == 1
        velA = array.get(tLastVel, actIdx)
        velStr = velA == 1 ? " (fast)" : velA == 0 ? " (slow)" : ""
        // regime alignment read for the ATK lean — the current role of the level
        // (support if below price) implies the attack's pressure direction.
        regA = array.get(tLastReg, actIdx)
        atkPres = close > lp2 ? -1 : 1   // attacking support presses down; resistance presses up
        regTxt = regA == -9 ? "" : regA == 0 ? " ·range" : atkPres == regA ? " ·with-trend" : " ·counter-trend"
        leanTxt = conf ? "★ CONFLUENCE — flow + absorption defend" : bkt == 0 ? "DEFENDING → lean HOLD" + velStr : bkt == 2 ? "ATTACKING → lean BREAK" + velStr + regTxt + (velA == 0 and regA != 0 and atkPres == regA ? " ⚠ clean-break read" : "") : bkt == 1 ? "NEUTRAL flow" : "flow n/a"
        leanC = conf ? color.new(color.aqua, 0) : bkt == 0 ? color.new(color.lime, 0) : bkt == 2 ? color.new(color.red, 0) : color.new(color.silver, 0)
        label.set_xy(leanLbl, bar_index + 3, lp2)
        label.set_text(leanLbl, str.tostring(lp2, format.mintick) + "  " + leanTxt)
        label.set_textcolor(leanLbl, leanC)
        label.set_color(leanLbl, color.new(color.black, 20))
    else
        label.set_text(leanLbl, "")
        label.set_color(leanLbl, color.new(color.black, 100))

// ─────────── ALERT ───────────
var bool nearStrong = false
nearStrong := false
float strongLvl = na
float strongRate = na
float strongN = na
if array.size(tLevel) > 0
    for k = 0 to array.size(tLevel) - 1
        if array.get(tIsCtl, k) == 1
            continue
        lp = array.get(tLevel, k)
        fK = readF(k)
        isSup = lp < close
        roleH = (isSup ? array.get(tSupH, k) : array.get(tResH, k)) * fK
        roleB = (isSup ? array.get(tSupB, k) : array.get(tResB, k)) * fK
        roleBase = isSup ? baseSupRate : baseResRate
        roleDec = roleH + roleB
        if roleDec < minTests
            continue
        roleRate = roleH / roleDec
        if (roleRate - roleBase) >= liftThr(roleDec) and math.abs(close - lp) <= atr * 1.0
            nearStrong := true
            strongLvl := lp
            strongRate := roleRate
            strongN := roleDec

alertcondition(nearStrong, title="Approaching role-strong level", message="Price approaching a psych level with positive hold-lift in its current role.")

// ─────────── CLEAN-TEXT FLOW ALERTS (edge-triggered, readable) ───────────
// Find the nearest real level price is currently near, and its lean/confluence state.
float activeZoneLvl = na
int   activeBkt = -1
bool  activeConf = false
int   activeIdx = -1
_adist = 1.0e18
proxA = math.max(leanProxATR * atr, zoneW)
if array.size(tLevel) > 0
    for k = 0 to array.size(tLevel) - 1
        if array.get(tIsCtl, k) == 1
            continue
        if array.get(tLastPress, k) < 0
            continue
        lp = array.get(tLevel, k)
        d = math.abs(lp - close)
        if d <= proxA and d < _adist
            _adist := d
            activeZoneLvl := lp
            activeBkt := array.get(tLastPress, k)
            activeConf := array.get(tConf, k) == 1
            activeIdx := k

// Export the active level so alert messages can print it via {{plot("PsychActiveZone")}}
plot(activeZoneLvl, "PsychActiveZone", display=display.data_window)

bool defNear = activeBkt == 0
bool atkNear = activeBkt == 2
bool confNear = activeConf
// edge-trigger: fire once when price ENTERS the state, not every bar it lingers
bool defendEnter = defNear  and not defNear[1]
bool attackEnter = atkNear  and not atkNear[1]
bool confEnter   = confNear and not confNear[1]
bool strongEnter = nearStrong and not nearStrong[1]

alertcondition(confEnter,   title="⭐ Psych CONFLUENCE (strong hold)", message='⭐ {{ticker}} psych level {{plot("PsychActiveZone")}} — CONFLUENCE: flow + absorption defending. Strong HOLD lean.')
alertcondition(defendEnter, title="🟢 Psych level DEFENDED",          message='🟢 {{ticker}} psych level {{plot("PsychActiveZone")}} DEFENDED — flow leans HOLD.')
alertcondition(attackEnter, title="🔴 Psych level ATTACKED",          message='🔴 {{ticker}} psych level {{plot("PsychActiveZone")}} ATTACKED — flow leans BREAK.')

// ─────────── ALERT ENGINE (one "Any alert() function call" alert; script-side routing) ───────────
// Edge-triggered, confirmed bars only, messages enriched with the live measured
// hold-rate for the EXACT condition that fired — same ledger the panel reads.
holdPct(int h, int b) =>
    n = h + b
    n > 0 ? str.tostring(h * 100.0 / n, "0") + "% holds (n=" + str.tostring(n) + ")" : "no sample yet"

if enableAlertEngine and barstate.isconfirmed and activeIdx >= 0
    string symA = syminfo.ticker
    string lvlA = str.tostring(activeZoneLvl, format.mintick)
    string pxA  = str.tostring(close, format.mintick)
    string roleA = activeZoneLvl < close ? "support" : "resistance"
    // approach velocity of the test that produced this lean
    int velA2 = array.get(tLastVel, activeIdx)
    string velTxt = velA2 == 1 ? "fast spike" : velA2 == 0 ? "slow grind" : "—"
    // ⭐ CONFLUENCE — flow + absorption defending (checked first: the A+ setup)
    if confEnter and alertConfEng
        alert(symA + ' ⭐ CONFLUENCE @ ' + lvlA + ' (' + roleA + ') — flow + absorption defending | DEF ' + holdPct(array.get(pStats, 0), array.get(pStats, 1)) + ' | px ' + pxA, alert.freq_once_per_bar)
    // 🟢 DEFENDED — lean HOLD (suppressed when confluence fired the same bar: one ping, the stronger one)
    else if defendEnter and alertDefEng
        alert(symA + ' 🟢 DEFENDED @ ' + lvlA + ' (' + roleA + ', ' + velTxt + ') — lean HOLD | DEF ' + holdPct(array.get(pStats, 0), array.get(pStats, 1)) + ' | px ' + pxA, alert.freq_once_per_bar)
    // 🔴 ATTACKED — lean BREAK, with the regime bucket that tells you whether to trust it
    if attackEnter and alertAtkEng
        int regA2 = array.get(tLastReg, activeIdx)
        int atkPresA = close > activeZoneLvl ? -1 : 1
        string regTag = regA2 == -9 or regA2 == 0 ? "·range" : atkPresA == regA2 ? "·with-trend" : "·counter-trend"
        string regStat = regA2 == -9 or regA2 == 0 ? holdPct(array.get(rgStats, 8), array.get(rgStats, 9)) : atkPresA == regA2 ? holdPct(array.get(rgStats, 4), array.get(rgStats, 5)) : holdPct(array.get(rgStats, 6), array.get(rgStats, 7))
        alert(symA + ' 🔴 ATTACKED @ ' + lvlA + ' (' + roleA + ', ' + velTxt + ') ' + regTag + ' — lean BREAK | ATK' + regTag + ' ' + regStat + ' | px ' + pxA, alert.freq_once_per_bar)

// 📍 Approaching role-strong level — context ping, independent of a live flow lean
if enableAlertEngine and barstate.isconfirmed and alertStrongEng and strongEnter and not na(strongLvl)
    alert(syminfo.ticker + ' 📍 approaching role-strong level ' + str.tostring(strongLvl, format.mintick) + ' — holds ' + str.tostring(strongRate * 100, "0") + '% in role (n=' + str.tostring(strongN, "0") + ') | px ' + str.tostring(close, format.mintick), alert.freq_once_per_bar)
````
