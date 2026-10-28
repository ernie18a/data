# Strong V DOL FVG Signals | ProjectSyndicate

- url: https://www.tradingview.com/script/xV5x5g20-Strong-V-DOL-FVG-Signals-ProjectSyndicate/
- type: indicator
- pine_id: PUB;a5777ed8f9bf47b9b6df6092fa08e8f7
- version: 1.0

## Description

Strong V DOL FVG Signals catches the moment a stop-hunt gets rejected so violently that price snaps back through the level it just raided — the V-shape — and it only takes that reversal when the snap-back leaves an institutional footprint behind and has somewhere real to go. Markets raid the obvious swing lows and highs to fill size against trapped traders. Most of those raids simply continue. The ones that matter reverse immediately: price stabs beyond the pool, refuses to accept the new low or high, and displaces back through the level in a handful of bars, carving a sharp V pivot instead of a slow rounded base. 

That refusal is the event. The engine then demands a second thing most reversal tools never check — an imbalance created or flipped by that displacement, a Fair Value Gap or an Inversion FVG that gives the entry a structural edge — and a third thing almost none of them check: an explicit destination, the higher-timeframe Draw on Liquidity the move is actually running at. Sweep, refusal, imbalance, magnet. Every setup that clears all four gets a structural invalidation behind the V extreme, a DOL-anchored target ladder, a 0–10 V-Score with a star rank, and is tracked live on a two-card statistics dashboard — including honest stop-outs — so you can see exactly how the logic behaves on the symbol and timeframe you trade.

🧠 V-Shape Core

The core idea, expressed as a lifecycle: POOL ▸ RAID ▸ V-SHAPE ▸ INVERSION ▸ ENTRY ▸ DOL. A confirmed swing high or low defines where stops are resting — internal range liquidity. A raid happens when price trades beyond that pool by a minimum ATR depth, running the stops. The V-shape is the refusal: price must close back through the raided pool inside a reclaim window, and the recovery leg must survive three geometry gates before it counts. Swept lows flip to a LONG, swept highs to a SHORT. Pivots come from confirmed swings and every condition is evaluated on the bar's close, so the structure and the signal do not repaint once they confirm.

📐 The Three Geometry Gates — what separates a V from a bounce

This is the part that does the heavy lifting, because "price swept a low and came back" describes half of all price action. A qualifying V must satisfy all three simultaneously: Displacement — the distance from the V extreme to the reclaim close, measured in ATR, so the recovery has to be aggressive, not incidental. V Width — the bars between the extreme and the reclaim, capped, so a slow multi-bar grind is rejected no matter how far it travels. V Sharpness — displacement divided by width, the ATR-per-bar velocity of the snap-back, which is the single dial that most directly controls how violent a reversal has to be before the engine calls it a V. A wide, rounded recovery fails all three. A knife-edge rejection passes all three. Tighten sharpness for fewer, more explosive setups; loosen it for more activity.

🔀 FVG / IFVG Confirmation — the imbalance the displacement leaves behind

A qualified V is not yet a trade. The engine then looks for the institutional footprint of that displacement and uses it as the entry zone. An IFVG (Inversion FVG) is the premium case: an opposing three-candle Fair Value Gap that the displacement closed straight through, flipping its role from resistance to support (or support to resistance). That flip is proof the recovery had enough force to invalidate the prior imbalance, and a freshness window keeps only recently inverted gaps eligible. A fresh FVG is the fallback: a new three-candle gap left by the displacement leg itself. You choose the policy — IFVG → FVG (auto), IFVG only, or FVG only — and a minimum gap size in ATR filters out noise. If you want the pure geometry play, Require A Zone To Trade can be switched off so a qualified V fires on displacement alone, and the panel will tell you it was a RAW V entry.

🎯 Entry — retest limit or immediate

Two execution models. Retest Zone (limit) arms the imbalance and waits for price to trade back into it, filling at the zone edge — the patient version, which is why an arm window exists to discard setups that never come back, and why an armed setup is killed outright if price closes back beyond the V extreme before the retest. Immediate On Displacement fills at the confirmation close and accepts worse average location in exchange for never missing the ones that run without a pullback. Both are honest about what they are: the armed state, the zone range, and the expiry are all visible on the panel while you wait.

🧲 Draw on Liquidity — the target engine

Most reversal tools stop at a flat R multiple. This one asks where the move is actually going. The DOL engine maintains a live pool of higher-timeframe liquidity — swing highs and lows from a timeframe you choose, previous day high and low, optional previous week high and low, optional chart-timeframe swings — and tracks which of them have already been traded through. Only unswept levels can be targets, because liquidity that has already been taken is no longer a magnet. When a signal fires, the engine selects the nearest qualifying draw beyond the entry that sits inside a configurable R window, so it never targets something two ticks away or something unreachable this session, and that level becomes TP3. If nothing qualifies, it falls back cleanly to a flat R target and says so. Two live DOL rails are drawn at all times — the nearest unswept draw above and below current price — so you always know what the market is fishing for even when no setup is active.

🔋 V-Score Anatomy

A V-shape is not just true or false; it is scored for how clean the reversal is. The V-Score fuses six reversal-native ingredients into a single 0–10 read: sweep depth (how far past the pool the raid reached), displacement (how hard the recovery pushed), V sharpness (the velocity of the snap-back), rejection wick (how decisively the extreme bar was rejected), volume surge (participation on the reversal versus its baseline), and room to DOL (how much R the target actually offers — a setup with nowhere to go is scored down no matter how pretty the candle). Each ingredient carries its own adjustable weight. A higher-timeframe bias read then either adjusts the score or hard-filters the signal, your choice. You shape what qualifies through those weights and the geometry thresholds rather than chasing a single number.

🎯 Structural Invalidation + Universal Zones

The stop is anchored to the V, not guessed. Invalidation sits just beyond the V-shape extreme — the price that, if reclaimed, means the raid was real and the reversal failed — plus an ATR buffer for cushion. Universal Zone Height then clamps that distance between an ATR floor and an ATR ceiling, so one wide V can't draw a stop five times the height of the next and the R unit stays comparable across every signal on the chart. TP1 and TP2 are clean R multiples; TP3 is the DOL itself, reported with its true R multiple rather than a rounded one. Every signal plots its full Entry / SL / TP1 / TP2 / TP3 set, labeled level prices, a filled risk zone and reward zone, the raided liquidity level tagged IRL, a V-SHAPE tag on the extreme, the entry line doubling as the break-even rail, and an optional 0 / 0.5 equilibrium split — and every zone is drawn at the same fixed width, so a three-bar stop-out and a two-hundred-bar runner leave an identical, uniform footprint on the chart.

⭐ 0–10 Strength with Star Tiers

Every signal is labeled with its numeric V-Score, a star rank, and a tier ladder running WEAK → VALID → STRONG → ELITE, so the raw quality of a setup reads at a glance without checking the number. Treat the score as a cleanliness and confluence read for ranking and thinning setups — it describes how textbook a V-shape-into-imbalance is, not a guaranteed outcome. The Min V-Score gate restricts what fires, the Strong Tier threshold sets where the star ladder breaks, and the dashboard keeps tracking every closed trade in the background so you can see, on your own data, whether stricter settings actually convert better.

🎚️ Conviction Controls

A compact set of dials sets how serious a raid must be before it counts: the liquidity swing length that decides which pools qualify, the min sweep depth that defines a real stop run, the reclaim window that separates a sweep from genuine acceptance, the three geometry gates (displacement, V width, sharpness), the zone policy and min gap size, the IFVG freshness window, the arm window for retests, the min V-Score, the HTF bias mode, and the risk floor and cap. Tighten them for rare, violent, textbook reversals; loosen them for more activity. This is your main control over conviction versus frequency.

🧭 Single-Ticket Discipline & Honest Accounting

Only one ticket is active at a time, so one chaotic session can't stack overlapping trades — a signal that fires while a trade is running is still labeled and still shown in the scenario panel, marked plainly as SIGNAL ONLY, but it is not double-counted in the statistics. Resolution is SL-first pessimistic: when a bar touches both a target and the stop, the stop wins, because intrabar sequence is unknowable. Partial targets are booked honestly — a trade that reaches TP1 or TP2 and is later stopped books the highest target it actually reached rather than being rounded up to a full win or buried. Armed setups that never get their retest expire instead of lingering. The max-drawn-trades cap is visual only — it thins old drawings off the chart while the statistics stay cumulative over the entire history.

📊 Two-Card Live Dashboard

A non-intrusive panel, built as two visually separate cards divided by a transparent spacer so the chart shows through the gap.

Card 1 · MODEL tracks the engine in real time: current status (waiting → sweeping → armed → in trade), the higher-timeframe bias, the live V-Score as a gauge with its tier, the armed entry zone and its price range, the nearest unswept DOL above and below with ATR distance, the last signal and its stars, win rate with the raw closed-trade count, profit factor, average R per trade, long versus short win rate, current and max streaks, and a TP1 / TP2 / TP3 / SL outcome breakdown.

Card 2 · SCENARIO is the full anatomy of the newest signal, always on and always visible: the setup with its score and tier, the confirmation type (IFVG, FVG, or RAW V) with the exact zone range, the raided IRL level with its sweep depth in ATR, the V geometry expressed as displacement, bar count and velocity, the entry price, the invalidation with its ATR width, TP1 and TP2, the DOL target with its R multiple, whether the HTF bias agreed, and the outcome — running live open R while the trade is on, then locking to the terminal result.

Every filled trade that reaches an outcome is counted — winners and stop-outs alike — so the numbers are computed live from the real signals on your current symbol and timeframe, not a figure printed in a description.

🎨 Clean Themed Visuals

Six coherent palettes, all tuned for a black chart background — Aurora (the clean mint-and-rose default), Gold Noir, Ice Blue, Aqua Violet, Neon Magenta, and Institutional — shade the signal labels, the risk and reward zones, the imbalance zone, the raided-liquidity band, the DOL rails and the dashboard to one consistent look, so direction and quality read at a glance. Each reversal prints a labeled V-SHAPE LONG or V-SHAPE SHORT signal carrying its score, star tier, and confirmation type.

🔔 Detailed Alerts

Fires on V-Shape Armed LONG and SHORT (a qualified V has formed and its zone is waiting for the retest — the early warning), V-Shape Entry LONG and SHORT, any entry, and on Final Target Hit and Stop Hit, formatted for manual or automated use.

🔧 Fully Customizable

Every component is exposed: the liquidity swing length, ATR length, reclaim window and min sweep depth; the displacement, V width and sharpness gates plus the volume baseline; the zone policy, min gap size, inversion freshness, entry trigger and arm window; the DOL timeframe, swing length, day and week level sources, and the min and max target distance in R; the risk buffer, universal-height floor and cap, the R targets, the uniform zone width and the max drawn trades; the min V-Score, strong-tier threshold, long and short toggles, HTF bias mode and timeframe, and each of the six score weights; the dashboard position, size, card gap and every section toggle; all six themes; and every label, line, box, tag and zone.

🎯 Why this is different

Most sweep tools fire on the raid and hope. Most FVG tools draw every gap on the chart and leave you to guess which one matters. This one requires all three layers to line up in sequence: liquidity must actually be raided, the recovery must be violent enough to qualify as a V on three independent geometry measures, and the displacement must leave or flip an imbalance that becomes the entry — then it anchors invalidation behind the V extreme, targets a real unswept higher-timeframe draw instead of an arbitrary R multiple, ranks the whole thing on an objective 0–10 scale, and layers a live, honest statistics panel that counts stop-outs in full. You tune and judge it on real, current data from your own chart instead of a marketing number.

🚀 Where to use it

The mechanics are symbol-agnostic and rest on universal behavior: every liquid market raids its obvious highs and lows, and some of those raids fail immediately. It suits index futures, gold and metals, FX majors and crosses, and crypto on intraday timeframes, where session raids and stop-runs are a constant feature and the higher-timeframe draw is well defined. Because it fades exhaustion, it shines around session extremes and range edges and demands more care in violent one-way trends, where a raid can keep extending rather than reject. Lower timeframes produce more V-shapes but noisier ones — raise the sharpness and min-score gates as you go down. Let the dashboard tell you whether the logic suits the pair and timeframe before you commit.

🎯 How to trade it

Apply it to a liquid symbol on an intraday timeframe and let the dashboard populate. Read the live win rate, profit factor and average R for your symbol and timeframe first — if the logic doesn't suit that market, you'll see it there before you risk anything.

Watch the DOL rails to frame the session — they show the unswept liquidity above and below, which is where price is being pulled.

Wait for a labeled V-SHAPE LONG / SHORT signal. It marks a confirmed close where a pool was raided, the recovery cleared all three geometry gates, and an imbalance confirmed the entry — with score, tier, and the full Entry / SL / TP1 / TP2 / TP3 already plotted.

Read the Scenario card for the fast conviction check: an IFVG confirmation, a deep sweep, high velocity and plenty of R to the DOL is the textbook version. RAW V with thin room to target is the marginal one.

Manage with the plotted levels — the structural stop behind the V defines your risk, TP1 and TP2 are your R scale-outs, and TP3 is the draw the move is actually hunting. Bank or trail however suits your style.

Use the sharpness gate, min V-Score, zone policy and HTF bias filter to set your tempo — stricter for rare, textbook reversals; looser for more activity.

⚠️ Important

This is a decision-support tool, not a standalone buy/sell system, and it makes no performance guarantees. The default settings are sensible starting points, not the output of a historical optimization study — they have not been curve-fit to any one symbol, and you should expect to adjust the geometry gates and score threshold for your market before the signal quality is where you want it. Behavior will vary by symbol, timeframe, session and configuration; the dashboard's statistics are historical and descriptive, not a forecast.

The trade model resolves stop-first and books partial-target exits honestly, so some trades close for a fraction of a target rather than a full win — these are counted in full, which is honest but means win rate alone is misleading; always weigh it together with average R and profit factor. Because TP3 tracks a real liquidity draw rather than a fixed multiple, R per trade varies by design — a 2R target and an 8R target are both legitimate outcomes of the same logic, and the average R figure is the number that reconciles them.

Signals confirm on the closed bar, and the pivot-based liquidity pools confirm a few bars after a swing forms — so the armed state appears slightly after the raw extreme prints, which is inherent to pivot confirmation and is exactly why the retest entry mode exists. Always wait for the labeled signal on a closed candle. Because the system fades a move, a real breakout or a raid that keeps extending can run straight through a stop — combine it with your own analysis and risk management, and test it on your market before trading it live.

## Source Code

````pine
//@version=6

indicator("Strong V DOL FVG Signals", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 1500)

var string G1 = "01 · Liquidity Sweep (IRL)"
pivotLen    = input.int(5, "Liquidity Swing Length", minval = 2, maxval = 50, group = G1, tooltip = "Bars each side that confirm the swing high / low holding the resting stops. Larger = only major pools are raided.")
atrLen      = input.int(14, "ATR Length", minval = 2, maxval = 100, group = G1)
sweepWin    = input.int(8, "Max Reclaim Window (bars)", minval = 1, maxval = 40, group = G1, tooltip = "The raided pool must be reclaimed within this many bars. Slower reclaims are treated as genuine acceptance, not a sweep, and are discarded.")
minSweepAtr = input.float(0.08, "Min Sweep Depth (ATR)", minval = 0.0, maxval = 3.0, step = 0.01, group = G1, tooltip = "Minimum penetration beyond the pool to count as a stop raid.")
showPools   = input.bool(true, "Show Liquidity Pools", group = G1)
showBand    = input.bool(true, "Shade Raided Liquidity", group = G1, tooltip = "Marks the bars that actually raided the pool, so it stays anchored to the raid rather than the uniform trade footprint.")

var string G2 = "02 · V-Shape Displacement"
maxVBars    = input.int(12, "Max V Width (bars)", minval = 1, maxval = 60, group = G2, tooltip = "Bars allowed between the V extreme and the reclaim close. Wide, rounded recoveries are not V-shapes.")
minDispAtr  = input.float(0.60, "Min Displacement (ATR)", minval = 0.0, maxval = 10.0, step = 0.05, group = G2, tooltip = "Distance from the V extreme to the reclaim close. This is the aggression filter.")
minSharp    = input.float(0.12, "Min V Sharpness (ATR / bar)", minval = 0.0, maxval = 3.0, step = 0.01, group = G2, tooltip = "Displacement divided by V width — the velocity of the recovery.")
volLen      = input.int(20, "Volume Baseline", minval = 2, maxval = 200, group = G2)
volRef      = input.float(1.8, "Volume Surge Ref (x)", minval = 1.1, maxval = 8.0, step = 0.1, group = G2)

var string G3 = "03 · FVG / IFVG Entry"
zoneMode    = input.string("IFVG → FVG (auto)", "Entry Zone Source", options = ["IFVG → FVG (auto)", "IFVG only", "FVG only"], group = G3, tooltip = "IFVG = an opposing fair value gap the displacement closed through, flipping its role. FVG = a fresh gap left by the displacement leg itself.")
requireZone = input.bool(true, "Require A Zone To Trade", group = G3, tooltip = "Off = a qualified V-shape can fire on displacement alone, with no imbalance present.")
minGapAtr   = input.float(0.10, "Min Gap Size (ATR)", minval = 0.0, maxval = 3.0, step = 0.01, group = G3)
invWin      = input.int(12, "Max Bars Since Inversion", minval = 1, maxval = 60, group = G3, tooltip = "An IFVG only counts as fresh confirmation for this many bars after it flipped.")
entryMode   = input.string("Retest Zone (limit)", "Entry Trigger", options = ["Retest Zone (limit)", "Immediate On Displacement"], group = G3)
armWin      = input.int(18, "Zone Arm Window (bars)", minval = 1, maxval = 100, group = G3, tooltip = "How long an armed zone waits for its retest before the setup is discarded.")
showGaps    = input.bool(false, "Draw All FVG / IFVG Zones", group = G3)
gapCap      = input.int(24, "Max Tracked Gaps", minval = 4, maxval = 60, group = G3)

var string G4 = "04 · Draw On Liquidity (DOL)"
useDol      = input.bool(true, "Target The DOL", group = G4, tooltip = "Off = targets fall back to a flat R multiple.")
dolTf       = input.timeframe("60", "DOL Timeframe", group = G4)
dolPiv      = input.int(3, "DOL Swing Length", minval = 1, maxval = 20, group = G4)
useDayLvl   = input.bool(true, "Include PDH / PDL", group = G4)
useWeekLvl  = input.bool(false, "Include PWH / PWL", group = G4)
useLocalLvl = input.bool(false, "Include Chart-TF Swings", group = G4, tooltip = "Adds local swing highs / lows to the target pool. Useful on very low timeframes where the HTF swings are far away.")
minDolRR    = input.float(2.0, "Min DOL Distance (R)", minval = 0.5, maxval = 20.0, step = 0.1, group = G4)
maxDolRR    = input.float(12.0, "Max DOL Distance (R)", minval = 1.0, maxval = 60.0, step = 0.5, group = G4, tooltip = "Targets further than this are ignored as unrealistic for the session.")
showDolLive = input.bool(true, "Show Live DOL Rails", group = G4)

var string G5 = "05 · Trade Model"
showTrades  = input.bool(true, "Simulate Trades", group = G5)
slBufAtr    = input.float(0.15, "SL Buffer Beyond V (ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = G5)
normRisk    = input.bool(true, "Universal Zone Height (normalize risk)", group = G5, tooltip = "On = the structural stop is clamped between the floor and cap below, so every SL/TP zone draws at a comparable height instead of one setup dwarfing the next. Off = the stop sits exactly at the V extreme and over-wide setups are skipped instead of clamped.")
maxRiskAtr  = input.float(3.0, "Max Risk (ATR) — stop cap",  minval = 0.2, maxval = 20.0, step = 0.1, group = G5)
minRiskAtr  = input.float(0.5, "Min Risk (ATR) — stop floor", minval = 0.1, maxval = 10.0, step = 0.1, group = G5, tooltip = "Stops the zones collapsing to a sliver when the V is razor tight.")
tp1R        = input.float(1.0, "TP1 (R)", minval = 0.2, maxval = 20, step = 0.1, group = G5)
tp2R        = input.float(2.0, "TP2 (R)", minval = 0.3, maxval = 30, step = 0.1, group = G5)
tp3R        = input.float(3.0, "TP3 (R) — used when no DOL qualifies", minval = 0.5, maxval = 50, step = 0.1, group = G5, tooltip = "Resolution model: a trade that reaches TP1 or TP2 and is later stopped books the highest target reached. Same-bar ambiguity always resolves SL-first.")
levelLen    = input.int(24, "Zone Width (bars) — uniform", minval = 2, maxval = 500, group = G5, tooltip = "Fixed width of every SL/TP shaded zone, level line and price tag. All signals draw at this same width regardless of how long the trade lasts.")
showBoxes   = input.bool(true, "Show Risk / Reward Zones", group = G5)
showLines   = input.bool(true, "Show Entry / SL / TP Lines", group = G5)
showLevelLbl= input.bool(true, "Label Level Prices", group = G5)
showExitLbl = input.bool(true, "Show Trade Result Labels", group = G5)
showFib     = input.bool(false, "Show 0 / 0.5 Equilibrium", group = G5)
maxHist     = input.int(20, "Max Historical Trades Drawn", minval = 1, maxval = 60, group = G5, tooltip = "Visual cap only. Statistics always count every closed trade.")

var string G6 = "06 · V-Score & Filters"
minScore    = input.float(5.0, "Min V-Score (0-10)", minval = 0.0, maxval = 10.0, step = 0.1, group = G6)
strongThr   = input.float(7.5, "Strong Tier (V-Score)", minval = 0.0, maxval = 10.0, step = 0.1, group = G6)
longsOn     = input.bool(true, "Long Setups", group = G6)
shortsOn    = input.bool(true, "Short Setups", group = G6)
biasMode    = input.string("Score Only", "HTF Bias", options = ["Off", "Score Only", "Filter Signals"], group = G6)
biasTf      = input.timeframe("240", "Bias Timeframe", group = G6)
biasLen     = input.int(50, "Bias EMA Length", minval = 2, maxval = 400, group = G6)
wDepth      = input.float(1.0, "Weight · Sweep Depth", minval = 0, maxval = 3, step = 0.1, group = G6)
wDisp       = input.float(1.0, "Weight · Displacement", minval = 0, maxval = 3, step = 0.1, group = G6)
wSharp      = input.float(1.0, "Weight · V Sharpness", minval = 0, maxval = 3, step = 0.1, group = G6)
wWick       = input.float(1.0, "Weight · Rejection Wick", minval = 0, maxval = 3, step = 0.1, group = G6)
wVol        = input.float(1.0, "Weight · Volume Surge", minval = 0, maxval = 3, step = 0.1, group = G6)
wRoom       = input.float(1.0, "Weight · Room To DOL", minval = 0, maxval = 3, step = 0.1, group = G6)

var string G7 = "07 · Dashboard"
showDash    = input.bool(true, "Show Dashboard", group = G7)
dashPosOpt  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = G7)
dashSizeOpt = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal"], group = G7)
showSetupRows = input.bool(true, "Show Live Setup Rows", group = G7)
showHeatRow = input.bool(true, "Show Per-Target Breakdown", group = G7)
showScen    = input.bool(true, "Show Scenario Panel (card 2)", group = G7, tooltip = "Fixed second card under the main panel, separated by transparent spacer rows. Holds the full breakdown of the newest V-SHAPE signal — the same detail carried by the signal label.")
cardGap     = input.int(1, "Gap Between Cards (rows)", minval = 1, maxval = 4, group = G7, tooltip = "Transparent spacer rows between cards. Pine only offers nine table anchor positions and a table frame wraps its whole bounding box, so two genuinely separate tables cannot be stacked in one corner. Spacer rows are how the card gap is produced — the chart shows through them.")

var string G8 = "08 · Visuals"
theme       = input.string("Aurora", "Color Theme", options = ["Aurora", "Gold Noir", "Ice Blue", "Aqua Violet", "Neon Magenta", "Institutional"], group = G8, tooltip = "All themes are tuned for a black chart background. Aurora (mint / rose) is the clean default.")
showStars   = input.bool(true, "Show ★ Ranking On Labels", group = G8)
showSigLbl  = input.bool(true, "Show Signal Labels", group = G8)
showVTag    = input.bool(true, "Show V-SHAPE / IRL Tags", group = G8)
lblSizeOpt  = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = G8)

longCol  = theme == "Gold Noir" ? color.rgb(230, 184, 75) : theme == "Ice Blue" ? color.rgb(38, 198, 255) : theme == "Aqua Violet" ? color.rgb(0, 225, 200) : theme == "Neon Magenta" ? color.rgb(0, 230, 200) : theme == "Institutional" ? color.rgb(31, 176, 118) : color.rgb(20, 214, 122)
shortCol = theme == "Gold Noir" ? color.rgb(203, 68, 56) : theme == "Ice Blue" ? color.rgb(255, 112, 92) : theme == "Aqua Violet" ? color.rgb(184, 122, 255) : theme == "Neon Magenta" ? color.rgb(255, 62, 190) : theme == "Institutional" ? color.rgb(176, 62, 74) : color.rgb(243, 62, 110)
tpFill   = theme == "Gold Noir" ? color.rgb(120, 92, 20) : theme == "Ice Blue" ? color.rgb(0, 92, 132) : theme == "Aqua Violet" ? color.rgb(0, 96, 88) : theme == "Neon Magenta" ? color.rgb(0, 98, 86) : theme == "Institutional" ? color.rgb(18, 96, 66) : color.rgb(12, 104, 64)
slFill   = theme == "Gold Noir" ? color.rgb(120, 40, 30) : theme == "Ice Blue" ? color.rgb(140, 44, 66) : theme == "Aqua Violet" ? color.rgb(96, 40, 120) : theme == "Neon Magenta" ? color.rgb(128, 26, 90) : theme == "Institutional" ? color.rgb(110, 34, 42) : color.rgb(140, 30, 62)
zoneCol  = theme == "Gold Noir" ? color.rgb(222, 214, 186) : theme == "Ice Blue" ? color.rgb(255, 214, 120) : theme == "Aqua Violet" ? color.rgb(255, 196, 120) : theme == "Neon Magenta" ? color.rgb(255, 214, 90) : theme == "Institutional" ? color.rgb(198, 166, 86) : color.rgb(226, 196, 64)
dolCol   = theme == "Gold Noir" ? color.rgb(255, 226, 122) : theme == "Ice Blue" ? color.rgb(127, 233, 255) : theme == "Aqua Violet" ? color.rgb(184, 122, 255) : theme == "Neon Magenta" ? color.rgb(120, 255, 235) : theme == "Institutional" ? color.rgb(150, 165, 185) : color.rgb(150, 225, 255)
poolCol  = theme == "Institutional" ? color.rgb(138, 142, 150) : theme == "Gold Noir" ? color.rgb(150, 142, 124) : color.rgb(124, 136, 156)

color panelBg     = #0a0c12
color panelBgAlt  = #0f131c
color panelHdr    = #161b27
color panelBorder = #2c3342
color txtHi       = #ebeef5
color txtLo       = #8791a2
color neutralCol  = #69748a
color goodCol     = #21c87a
color warnCol     = #e6be46
color badCol      = #e6435a

f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_pos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Right" => position.middle_right
        => position.top_right

clamp(v, lo, hi) => math.min(math.max(v, lo), hi)
clamp01(v)       => math.min(math.max(v, 0.0), 1.0)

f_gauge(v) =>
    fill = int(math.round(clamp(v, 0, 10)))
    str.repeat("█", fill) + str.repeat("░", 10 - fill)

f_stars(s)   => s >= 9.0 ? "★★★★★" : s >= strongThr ? "★★★★" : s >= 6.0 ? "★★★" : s >= 4.5 ? "★★" : s >= 3.0 ? "★" : "·"
f_tier(s)    => s >= 9.0 ? "ELITE" : s >= strongThr ? "STRONG" : s >= minScore ? "VALID" : "WEAK"
f_signedR(v) => (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "R"

atr     = ta.atr(atrLen)
safeAtr = math.max(nz(atr, high - low), syminfo.mintick)
volAvg  = ta.sma(volume, volLen)
atrPct  = ta.percentrank(atr, 100)
volSurgeNow = nz(volAvg, 0) > 0 ? nz(volume, 0) / volAvg : 1.0

allowIfvg = zoneMode != "FVG only"
allowFvg  = zoneMode != "IFVG only"
retestMode = entryMode == "Retest Zone (limit)"

[biasClose, biasEma] = request.security(syminfo.tickerid, biasTf, [close[1], ta.ema(close, biasLen)[1]], lookahead = barmerge.lookahead_on)
biasBull = biasMode != "Off" and not na(biasClose) and not na(biasEma) and biasClose > biasEma
biasBear = biasMode != "Off" and not na(biasClose) and not na(biasEma) and biasClose < biasEma
biasTxt  = biasMode == "Off" ? "OFF" : biasBull ? "BULLISH" : biasBear ? "BEARISH" : "FLAT"

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float poolLo     = na
var bool  poolLoDone = false
var float poolHi     = na
var bool  poolHiDone = false
var array<line> poolLines = array.new<line>()

if not na(pl)
    poolLo := pl
    poolLoDone := false
    if showPools
        array.push(poolLines, line.new(bar_index - pivotLen, pl, bar_index, pl, color = color.new(longCol, 55), style = line.style_dotted, width = 1))
if not na(ph)
    poolHi := ph
    poolHiDone := false
    if showPools
        array.push(poolLines, line.new(bar_index - pivotLen, ph, bar_index, ph, color = color.new(shortCol, 55), style = line.style_dotted, width = 1))

while array.size(poolLines) > 60
    line.delete(array.shift(poolLines))

var array<float> dolHiVal = array.new<float>()
var array<bool>  dolHiHit = array.new<bool>()
var array<float> dolLoVal = array.new<float>()
var array<bool>  dolLoHit = array.new<bool>()

f_hasNear(array<float> arr, float v, float tol) =>
    bool found = false
    if array.size(arr) > 0
        for i = array.size(arr) - 1 to 0
            if math.abs(array.get(arr, i) - v) <= tol
                found := true
                break
    found

dolTol = safeAtr * 0.25

[htfPH, htfPL] = request.security(syminfo.tickerid, dolTf, [ta.pivothigh(high, dolPiv, dolPiv)[1], ta.pivotlow(low, dolPiv, dolPiv)[1]], lookahead = barmerge.lookahead_on)
[pdh, pdl]     = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl]     = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)

if not na(htfPH) and (na(htfPH[1]) or htfPH != htfPH[1]) and not f_hasNear(dolHiVal, htfPH, dolTol)
    array.push(dolHiVal, htfPH), array.push(dolHiHit, false)
if not na(htfPL) and (na(htfPL[1]) or htfPL != htfPL[1]) and not f_hasNear(dolLoVal, htfPL, dolTol)
    array.push(dolLoVal, htfPL), array.push(dolLoHit, false)

if useDayLvl and not na(pdh) and (na(pdh[1]) or pdh != pdh[1]) and not f_hasNear(dolHiVal, pdh, dolTol)
    array.push(dolHiVal, pdh), array.push(dolHiHit, false)
if useDayLvl and not na(pdl) and (na(pdl[1]) or pdl != pdl[1]) and not f_hasNear(dolLoVal, pdl, dolTol)
    array.push(dolLoVal, pdl), array.push(dolLoHit, false)

if useWeekLvl and not na(pwh) and (na(pwh[1]) or pwh != pwh[1]) and not f_hasNear(dolHiVal, pwh, dolTol)
    array.push(dolHiVal, pwh), array.push(dolHiHit, false)
if useWeekLvl and not na(pwl) and (na(pwl[1]) or pwl != pwl[1]) and not f_hasNear(dolLoVal, pwl, dolTol)
    array.push(dolLoVal, pwl), array.push(dolLoHit, false)

if useLocalLvl and not na(ph) and not f_hasNear(dolHiVal, ph, dolTol)
    array.push(dolHiVal, ph), array.push(dolHiHit, false)
if useLocalLvl and not na(pl) and not f_hasNear(dolLoVal, pl, dolTol)
    array.push(dolLoVal, pl), array.push(dolLoHit, false)

while array.size(dolHiVal) > 90
    array.shift(dolHiVal), array.shift(dolHiHit)
while array.size(dolLoVal) > 90
    array.shift(dolLoVal), array.shift(dolLoHit)

if array.size(dolHiVal) > 0
    for i = 0 to array.size(dolHiVal) - 1
        if not array.get(dolHiHit, i) and high > array.get(dolHiVal, i)
            array.set(dolHiHit, i, true)
if array.size(dolLoVal) > 0
    for i = 0 to array.size(dolLoVal) - 1
        if not array.get(dolLoHit, i) and low < array.get(dolLoVal, i)
            array.set(dolLoHit, i, true)

f_dolAbove(float ent, float risk, float floorRR) =>
    float best = na
    if useDol and risk > 0 and array.size(dolHiVal) > 0
        for i = 0 to array.size(dolHiVal) - 1
            v = array.get(dolHiVal, i)
            if not array.get(dolHiHit, i) and v > ent
                rr = (v - ent) / risk
                if rr >= floorRR and rr <= maxDolRR and (na(best) or v < best)
                    best := v
    best

f_dolBelow(float ent, float risk, float floorRR) =>
    float best = na
    if useDol and risk > 0 and array.size(dolLoVal) > 0
        for i = 0 to array.size(dolLoVal) - 1
            v = array.get(dolLoVal, i)
            if not array.get(dolLoHit, i) and v < ent
                rr = (ent - v) / risk
                if rr >= floorRR and rr <= maxDolRR and (na(best) or v > best)
                    best := v
    best

f_nearestUp() =>
    float best = na
    if array.size(dolHiVal) > 0
        for i = 0 to array.size(dolHiVal) - 1
            v = array.get(dolHiVal, i)
            if not array.get(dolHiHit, i) and v > close and (na(best) or v < best)
                best := v
    best

f_nearestDn() =>
    float best = na
    if array.size(dolLoVal) > 0
        for i = 0 to array.size(dolLoVal) - 1
            v = array.get(dolLoVal, i)
            if not array.get(dolLoHit, i) and v < close and (na(best) or v > best)
                best := v
    best

type gapz
    float top    = na
    float bot    = na
    int   dir    = 0
    int   bar    = 0
    bool  inv    = false
    int   invBar = 0
    bool  dead   = false
    box   bx     = na

var array<gapz> gaps = array.new<gapz>()

bullGap = low > high[2] and (low - high[2]) >= minGapAtr * safeAtr
bearGap = high < low[2] and (low[2] - high) >= minGapAtr * safeAtr

if bullGap or bearGap
    float gt = bullGap ? low : low[2]
    float gb = bullGap ? high[2] : high
    int   gd = bullGap ? 1 : -1
    box gbx = na
    if showGaps
        gbx := box.new(bar_index - 2, gt, bar_index, gb, xloc = xloc.bar_index, bgcolor = color.new(gd == 1 ? longCol : shortCol, 88), border_color = color.new(gd == 1 ? longCol : shortCol, 60), border_width = 1)
    array.push(gaps, gapz.new(gt, gb, gd, bar_index, false, 0, false, gbx))

if array.size(gaps) > 0
    for i = array.size(gaps) - 1 to 0
        gapz g = array.get(gaps, i)
        if not g.dead
            if not g.inv
                if g.dir == 1 and close < g.bot
                    g.inv := true
                    g.invBar := bar_index
                    if showGaps and not na(g.bx)
                        box.set_bgcolor(g.bx, color.new(zoneCol, 84))
                        box.set_border_color(g.bx, color.new(zoneCol, 40))
                else if g.dir == -1 and close > g.top
                    g.inv := true
                    g.invBar := bar_index
                    if showGaps and not na(g.bx)
                        box.set_bgcolor(g.bx, color.new(zoneCol, 84))
                        box.set_border_color(g.bx, color.new(zoneCol, 40))
            else
                if (g.dir == 1 and close > g.top) or (g.dir == -1 and close < g.bot)
                    g.dead := true
                    if showGaps and not na(g.bx)
                        box.delete(g.bx)
                        g.bx := na
            if showGaps and not g.dead and not na(g.bx)
                box.set_right(g.bx, bar_index + 1)

while array.size(gaps) > gapCap
    gapz og = array.shift(gaps)
    if not na(og.bx)
        box.delete(og.bx)

f_zoneLong(float vLow, float px, int vBar) =>
    float zt = na
    float zb = na
    int   zk = 0
    if array.size(gaps) > 0 and allowIfvg
        for i = array.size(gaps) - 1 to 0
            gapz g = array.get(gaps, i)
            if not g.dead and g.dir == -1 and g.inv and (bar_index - g.invBar) <= invWin and g.top <= px and g.bot >= vLow
                if na(zt) or g.top > zt
                    zt := g.top
                    zb := g.bot
                    zk := 1
    if na(zt) and allowFvg and array.size(gaps) > 0
        for i = array.size(gaps) - 1 to 0
            gapz g = array.get(gaps, i)
            if not g.dead and g.dir == 1 and not g.inv and g.bar >= vBar and g.top <= px and g.bot >= vLow
                if na(zt) or g.top > zt
                    zt := g.top
                    zb := g.bot
                    zk := 2
    [zt, zb, zk]

f_zoneShort(float vHigh, float px, int vBar) =>
    float zt = na
    float zb = na
    int   zk = 0
    if array.size(gaps) > 0 and allowIfvg
        for i = array.size(gaps) - 1 to 0
            gapz g = array.get(gaps, i)
            if not g.dead and g.dir == 1 and g.inv and (bar_index - g.invBar) <= invWin and g.bot >= px and g.top <= vHigh
                if na(zb) or g.bot < zb
                    zt := g.top
                    zb := g.bot
                    zk := 1
    if na(zb) and allowFvg and array.size(gaps) > 0
        for i = array.size(gaps) - 1 to 0
            gapz g = array.get(gaps, i)
            if not g.dead and g.dir == -1 and not g.inv and g.bar >= vBar and g.bot >= px and g.top <= vHigh
                if na(zb) or g.bot < zb
                    zt := g.top
                    zb := g.bot
                    zk := 2
    [zt, zb, zk]

f_vscore(float depthAtr, float dispAtr, float sharp, float wickFrac, float volSurge, float roomRR, bool aligned) =>
    sD = clamp01(depthAtr / 0.80)
    sX = clamp01(dispAtr / 1.50)
    sS = clamp01(sharp / 0.40)
    sW = clamp01(wickFrac)
    sV = clamp01((volSurge - 1.0) / math.max(volRef - 1.0, 0.1))
    sR = clamp01(roomRR / 5.0)
    wSum = math.max(wDepth + wDisp + wSharp + wWick + wVol + wRoom, 0.0001)
    raw  = (wDepth * sD + wDisp * sX + wSharp * sS + wWick * sW + wVol * sV + wRoom * sR) / wSum
    adj  = biasMode == "Score Only" ? (aligned ? 0.7 : -0.7) : 0.0
    clamp(raw * 10.0 + adj, 0.0, 10.0)

f_tip(int dir, float sc, float lvl, int zk, float dolPx) =>
    string d = dir == 1 ? "LONG — sell-side liquidity swept, V-shape recovery" : "SHORT — buy-side liquidity swept, V-shape rejection"
    string z = zk == 1 ? "IFVG — an opposing gap the displacement inverted" : zk == 2 ? "FVG — a fresh gap left by the displacement" : "Raw V — no imbalance present"
    string tt = "V-Score: " + str.tostring(sc, "#.#") + "/10  " + f_stars(sc) + "  " + f_tier(sc)
    tt += "\nDirection: " + d
    tt += "\nEntry zone: " + z
    tt += "\nRaided level (IRL): " + str.tostring(lvl, format.mintick)
    tt += "\nDOL target: " + (na(dolPx) ? "none in range — flat R target used" : str.tostring(dolPx, format.mintick))
    tt += "\nVolatility pctile: " + str.tostring(atrPct, "#") + "  (calmer = cleaner displacement)"
    tt += "\nScore is a confluence read, not a win-rate guarantee."
    tt

var int   Lst    = 0
var float LvLow  = na
var int   LvBar  = na
var float Lpool  = na
var int   LsBar  = na
var float Lwick  = na
var float LvolS  = na
var float Lscore = na
var float Ldepth = na
var float Ldisp  = na
var float Lsharp = na
var int   LvW    = 0
var bool  Lbias  = false
var float LzTop  = na
var float LzBot  = na
var int   LzKind = 0
var int   LarmBar= na

var int   Sst    = 0
var float SvHigh = na
var int   SvBar  = na
var float Spool  = na
var int   SsBar  = na
var float Swick  = na
var float SvolS  = na
var float Sscore = na
var float Sdepth = na
var float Sdisp  = na
var float Ssharp = na
var int   SvW    = 0
var bool  Sbias  = false
var float SzTop  = na
var float SzBot  = na
var int   SzKind = 0
var int   SarmBar= na

var bool  tActive = false

bool fireLong  = false
bool fireShort = false
float sigScore = na
float sigEntry = na
float sigStop  = na
float sigVext  = na
float sigPool  = na
int   sigVBar  = na
int   sigSBar  = na
float sigZT    = na
float sigZB    = na
int   sigZK    = 0
float sigDepth = na
float sigDisp  = na
float sigSharp = na
int   sigVW    = 0
bool  sigBias  = false

floorRR = math.max(minDolRR, tp2R + 0.25)

if longsOn
    if Lst == 0 and not na(poolLo) and not poolLoDone and low < poolLo
        Lst   := 1
        LvLow := low
        LvBar := bar_index
        LsBar := bar_index
        Lpool := poolLo
        Lwick := (math.min(open, close) - low) / math.max(high - low, syminfo.mintick)
        LvolS := volSurgeNow
    else if Lst == 1
        if low < LvLow
            LvLow := low
            LvBar := bar_index
            Lwick := (math.min(open, close) - low) / math.max(high - low, syminfo.mintick)
            LvolS := volSurgeNow
        bool reclaimed = close > Lpool
        int  vBars     = bar_index - LvBar
        if reclaimed
            depthAtr = (Lpool - LvLow) / safeAtr
            dispAtr  = (close - LvLow) / safeAtr
            sharp    = dispAtr / math.max(vBars, 1)
            provEnt  = close
            provStop = LvLow - slBufAtr * safeAtr
            provRisk = provEnt - provStop
            dolPx    = f_dolAbove(provEnt, provRisk, floorRR)
            roomRR   = provRisk > 0 ? (na(dolPx) ? tp3R : (dolPx - provEnt) / provRisk) : 0.0
            sc       = f_vscore(depthAtr, dispAtr, sharp, nz(Lwick, 0), nz(LvolS, 1), roomRR, biasBull)
            bool okBias = biasMode != "Filter Signals" or biasBull
            bool okGeo  = depthAtr >= minSweepAtr and dispAtr >= minDispAtr and sharp >= minSharp and vBars <= maxVBars
            bool okRisk = provRisk > 0 and (normRisk or provRisk <= maxRiskAtr * safeAtr)
            if okGeo and okBias and okRisk and sc >= minScore
                [zt, zb, zk] = f_zoneLong(LvLow, close, LvBar)
                bool haveZone = not na(zt)
                if haveZone or not requireZone
                    Lscore := sc
                    Ldepth := depthAtr
                    Ldisp  := dispAtr
                    Lsharp := sharp
                    LvW    := vBars
                    Lbias  := biasBull
                    LzTop  := zt
                    LzBot  := zb
                    LzKind := zk
                    if retestMode and haveZone
                        Lst := 2
                        LarmBar := bar_index
                    else
                        fireLong := true
                        sigScore := sc
                        sigEntry := close
                        sigStop  := provStop
                        sigVext  := LvLow
                        sigPool  := Lpool
                        sigVBar  := LvBar
                        sigSBar  := LsBar
                        sigZT    := zt
                        sigZB    := zb
                        sigZK    := zk
                        sigDepth := Ldepth
                        sigDisp  := Ldisp
                        sigSharp := Lsharp
                        sigVW    := LvW
                        sigBias  := Lbias
                        Lst := 0
                else
                    Lst := 0
            else
                Lst := 0
            poolLoDone := true
        else if (bar_index - LsBar) > sweepWin
            Lst := 0
            poolLoDone := true
    else if Lst == 2
        if close < LvLow or (bar_index - LarmBar) > armWin
            Lst := 0
        else if not tActive and low <= LzTop
            ent = math.min(LzTop, open)
            stp = LvLow - slBufAtr * safeAtr
            if ent - stp > 0 and (normRisk or (ent - stp) <= maxRiskAtr * safeAtr)
                fireLong := true
                sigScore := Lscore
                sigEntry := ent
                sigStop  := stp
                sigVext  := LvLow
                sigPool  := Lpool
                sigVBar  := LvBar
                sigSBar  := LsBar
                sigZT    := LzTop
                sigZB    := LzBot
                sigZK    := LzKind
                sigDepth := Ldepth
                sigDisp  := Ldisp
                sigSharp := Lsharp
                sigVW    := LvW
                sigBias  := Lbias
            Lst := 0

if shortsOn and not fireLong
    if Sst == 0 and not na(poolHi) and not poolHiDone and high > poolHi
        Sst    := 1
        SvHigh := high
        SvBar  := bar_index
        SsBar  := bar_index
        Spool  := poolHi
        Swick  := (high - math.max(open, close)) / math.max(high - low, syminfo.mintick)
        SvolS  := volSurgeNow
    else if Sst == 1
        if high > SvHigh
            SvHigh := high
            SvBar  := bar_index
            Swick  := (high - math.max(open, close)) / math.max(high - low, syminfo.mintick)
            SvolS  := volSurgeNow
        bool reclaimedS = close < Spool
        int  vBarsS     = bar_index - SvBar
        if reclaimedS
            depthAtrS = (SvHigh - Spool) / safeAtr
            dispAtrS  = (SvHigh - close) / safeAtr
            sharpS    = dispAtrS / math.max(vBarsS, 1)
            provEntS  = close
            provStopS = SvHigh + slBufAtr * safeAtr
            provRiskS = provStopS - provEntS
            dolPxS    = f_dolBelow(provEntS, provRiskS, floorRR)
            roomRRS   = provRiskS > 0 ? (na(dolPxS) ? tp3R : (provEntS - dolPxS) / provRiskS) : 0.0
            scS       = f_vscore(depthAtrS, dispAtrS, sharpS, nz(Swick, 0), nz(SvolS, 1), roomRRS, biasBear)
            bool okBiasS = biasMode != "Filter Signals" or biasBear
            bool okGeoS  = depthAtrS >= minSweepAtr and dispAtrS >= minDispAtr and sharpS >= minSharp and vBarsS <= maxVBars
            bool okRiskS = provRiskS > 0 and (normRisk or provRiskS <= maxRiskAtr * safeAtr)
            if okGeoS and okBiasS and okRiskS and scS >= minScore
                [zts, zbs, zks] = f_zoneShort(SvHigh, close, SvBar)
                bool haveZoneS = not na(zbs)
                if haveZoneS or not requireZone
                    Sscore := scS
                    Sdepth := depthAtrS
                    Sdisp  := dispAtrS
                    Ssharp := sharpS
                    SvW    := vBarsS
                    Sbias  := biasBear
                    SzTop  := zts
                    SzBot  := zbs
                    SzKind := zks
                    if retestMode and haveZoneS
                        Sst := 2
                        SarmBar := bar_index
                    else
                        fireShort := true
                        sigScore  := scS
                        sigEntry  := close
                        sigStop   := provStopS
                        sigVext   := SvHigh
                        sigPool   := Spool
                        sigVBar   := SvBar
                        sigSBar   := SsBar
                        sigZT     := zts
                        sigZB     := zbs
                        sigZK     := zks
                        sigDepth  := Sdepth
                        sigDisp   := Sdisp
                        sigSharp  := Ssharp
                        sigVW     := SvW
                        sigBias   := Sbias
                        Sst := 0
                else
                    Sst := 0
            else
                Sst := 0
            poolHiDone := true
        else if (bar_index - SsBar) > sweepWin
            Sst := 0
            poolHiDone := true
    else if Sst == 2
        if close > SvHigh or (bar_index - SarmBar) > armWin
            Sst := 0
        else if not tActive and high >= SzBot
            entS = math.max(SzBot, open)
            stpS = SvHigh + slBufAtr * safeAtr
            if stpS - entS > 0 and (normRisk or (stpS - entS) <= maxRiskAtr * safeAtr)
                fireShort := true
                sigScore  := Sscore
                sigEntry  := entS
                sigStop   := stpS
                sigVext   := SvHigh
                sigPool   := Spool
                sigVBar   := SvBar
                sigSBar   := SsBar
                sigZT     := SzTop
                sigZB     := SzBot
                sigZK     := SzKind
                sigDepth  := Sdepth
                sigDisp   := Sdisp
                sigSharp  := Ssharp
                sigVW     := SvW
                sigBias   := Sbias
            Sst := 0

type ticket
    array<line>  ln
    array<box>   bx
    array<label> lb

var array<ticket> history = array.new<ticket>()

var array<line>  aLn   = array.new<line>()
var array<box>   aBx   = array.new<box>()
var array<label> aLbR  = array.new<label>()
var array<label> aLbS  = array.new<label>()

var int   tSide   = 0
var int   tBar    = na
var float tEntry  = na
var float tStop   = na
var float tT1     = na
var float tT2     = na
var float tT3     = na
var float tR3     = na
var bool  tDol    = false
var float tScore  = na
var int   tZKind  = 0
var int   bestStage = 0

var int   sClosed = 0
var int   sWins   = 0
var int   sTp1    = 0
var int   sTp2    = 0
var int   sTp3    = 0
var int   sSl     = 0
var float sR      = 0.0
var float sGrossW = 0.0
var float sGrossL = 0.0
var int   sLong     = 0
var int   sLongWin  = 0
var int   sShort    = 0
var int   sShortWin = 0
var int   sCurWin = 0
var int   sCurLos = 0
var int   sMaxWin = 0
var int   sMaxLos = 0
var int   sStreak = 0
var float lastScore = na
var int   lastSide  = 0

var int    scSide  = 0
var float  scScore = na
var int    scZK    = 0
var float  scZT    = na
var float  scZB    = na
var float  scPool  = na
var float  scVext  = na
var float  scEnt   = na
var float  scStop  = na
var float  scRisk  = na
var float  scT1    = na
var float  scT2    = na
var float  scDol   = na
var float  scR3    = na
var float  scDepth = na
var float  scDisp  = na
var float  scSharp = na
var int    scVW    = 0
var bool   scBias  = false
var int    scBar   = na
var bool   scTracked = false
var string scOutcome = "—"
var float  scOutR  = na

closedTp3 = false
closedSl  = false
closedTp  = false

if tActive
    isL = tSide == 1
    bool tp1Hit = isL ? high >= tT1 : low <= tT1
    bool tp2Hit = isL ? high >= tT2 : low <= tT2
    bool tp3Hit = isL ? high >= tT3 : low <= tT3
    bool slHit  = isL ? low  <= tStop : high >= tStop
    int  stage  = tp3Hit ? 3 : tp2Hit ? 2 : tp1Hit ? 1 : 0
    bool sameBarSl = slHit and stage > 0
    if stage > bestStage and not sameBarSl
        bestStage := stage
    bool finalTp3 = not sameBarSl and bestStage == 3
    bool finalSl  = slHit and (bestStage == 0 or sameBarSl)
    bool finalTp  = slHit and not sameBarSl and bestStage > 0 and bestStage < 3
    if finalTp3 or finalSl or finalTp
        closedTp3 := finalTp3
        closedSl  := finalSl
        closedTp  := finalTp
        float resR = finalTp3 ? tR3 : finalTp and bestStage == 2 ? tp2R : finalTp and bestStage == 1 ? tp1R : -1.0
        bool isWin = resR > 0
        sClosed += 1
        sR += resR
        if isWin
            sWins += 1
            sGrossW += resR
            sCurWin += 1
            sCurLos := 0
            sMaxWin := math.max(sMaxWin, sCurWin)
            sStreak := sCurWin
        else
            sGrossL += 1.0
            sCurLos += 1
            sCurWin := 0
            sMaxLos := math.max(sMaxLos, sCurLos)
            sStreak := -sCurLos
        if isL
            sLong += 1
            sLongWin += isWin ? 1 : 0
        else
            sShort += 1
            sShortWin += isWin ? 1 : 0
        if finalTp3
            sTp3 += 1
        else if finalTp and bestStage == 2
            sTp2 += 1
        else if finalTp and bestStage == 1
            sTp1 += 1
        else
            sSl += 1
        int rStage = finalTp3 ? 3 : finalTp ? bestStage : 0
        float resPx = finalTp3 ? tT3 : finalTp and rStage == 2 ? tT2 : finalTp and rStage == 1 ? tT1 : tStop
        string exTxt = finalTp3 ? (tDol ? "DOL ✔ " : "TP3 ✔ ") + f_signedR(resR) : finalTp ? "TP" + str.tostring(rStage) + " ✔ " + f_signedR(resR) : "SL ✘ −1R"
        color exCol = isWin ? goodCol : badCol
        if showExitLbl
            array.push(aLbS, label.new(bar_index, resPx, exTxt, style = (isL == isWin) ? label.style_label_down : label.style_label_up, color = color.new(exCol, 6), textcolor = color.white, size = f_size(lblSizeOpt)))
        if scTracked and scBar == tBar
            scOutcome := exTxt
            scOutR    := resR
        array.concat(aLbR, aLbS)
        array.push(history, ticket.new(aLn, aBx, aLbR))
        aLn  := array.new<line>()
        aBx  := array.new<box>()
        aLbR := array.new<label>()
        aLbS := array.new<label>()
        while array.size(history) > maxHist
            ticket old = array.shift(history)
            if array.size(old.ln) > 0
                for i = 0 to array.size(old.ln) - 1
                    line.delete(array.get(old.ln, i))
            if array.size(old.bx) > 0
                for i = 0 to array.size(old.bx) - 1
                    box.delete(array.get(old.bx, i))
            if array.size(old.lb) > 0
                for i = 0 to array.size(old.lb) - 1
                    label.delete(array.get(old.lb, i))
        tActive := false
        tSide   := 0
        tBar    := na
        bestStage := 0

if (fireLong or fireShort) and not na(atr)
    isLc  = fireLong
    rk0   = math.abs(sigEntry - sigStop)
    rk    = normRisk ? math.min(math.max(rk0, minRiskAtr * safeAtr), maxRiskAtr * safeAtr) : rk0
    dolC  = isLc ? f_dolAbove(sigEntry, rk, floorRR) : f_dolBelow(sigEntry, rk, floorRR)
    t3c   = na(dolC) ? (isLc ? sigEntry + rk * tp3R : sigEntry - rk * tp3R) : dolC
    scSide  := isLc ? 1 : -1
    scScore := sigScore
    scZK    := sigZK
    scZT    := sigZT
    scZB    := sigZB
    scPool  := sigPool
    scVext  := sigVext
    scEnt   := sigEntry
    scStop  := isLc ? sigEntry - rk : sigEntry + rk
    scRisk  := rk
    scT1    := isLc ? sigEntry + rk * tp1R : sigEntry - rk * tp1R
    scT2    := isLc ? sigEntry + rk * tp2R : sigEntry - rk * tp2R
    scDol   := dolC
    scR3    := rk > 0 ? math.abs(t3c - sigEntry) / rk : na
    scDepth := sigDepth
    scDisp  := sigDisp
    scSharp := sigSharp
    scVW    := sigVW
    scBias  := sigBias
    scBar   := bar_index
    scTracked := showTrades and not tActive and not closedTp3 and not closedSl and not closedTp and rk > 0
    scOutcome := scTracked ? "LIVE" : showTrades ? "SIGNAL ONLY · trade already active" : "SIGNAL ONLY · simulation off"
    scOutR    := na

if showTrades and not tActive and (fireLong or fireShort) and not na(atr) and not closedTp3 and not closedSl and not closedTp
    isL   = fireLong
    ent   = sigEntry
    risk0 = math.abs(ent - sigStop)
    risk  = normRisk ? math.min(math.max(risk0, minRiskAtr * safeAtr), maxRiskAtr * safeAtr) : risk0
    stp   = isL ? ent - risk : ent + risk
    if risk > 0
        dolPx = isL ? f_dolAbove(ent, risk, floorRR) : f_dolBelow(ent, risk, floorRR)
        bool haveDol = not na(dolPx)
        t1 = isL ? ent + risk * tp1R : ent - risk * tp1R
        t2 = isL ? ent + risk * tp2R : ent - risk * tp2R
        t3 = haveDol ? dolPx : (isL ? ent + risk * tp3R : ent - risk * tp3R)
        r3 = math.abs(t3 - ent) / risk
        tActive := true
        tSide   := isL ? 1 : -1
        tBar    := bar_index
        tEntry  := ent
        tStop   := stp
        tT1     := t1
        tT2     := t2
        tT3     := t3
        tR3     := r3
        tDol    := haveDol
        tScore  := sigScore
        tZKind  := sigZK
        bestStage := 0
        lastScore := sigScore
        lastSide  := tSide
        col = isL ? longCol : shortCol
        xr  = bar_index + levelLen
        int xl = bar_index

        if showBand and not na(sigPool) and not na(sigVext)
            array.push(aBx, box.new(math.min(nz(sigSBar, bar_index), bar_index) - 1, isL ? sigPool : sigVext, bar_index + 2, isL ? sigVext : sigPool, xloc = xloc.bar_index, bgcolor = color.new(poolCol, 82), border_color = color.new(poolCol, 60), border_width = 1))

        if showBoxes
            array.push(aBx, box.new(xl, isL ? ent : stp, xr, isL ? stp : ent, xloc = xloc.bar_index, bgcolor = color.new(slFill, 82), border_color = color.new(shortCol, 45), border_width = 1))
            array.push(aBx, box.new(xl, isL ? t3 : ent, xr, isL ? ent : t3, xloc = xloc.bar_index, bgcolor = color.new(tpFill, 82), border_color = color.new(col, 35), border_width = 1))
            if sigZK > 0 and not na(sigZT) and not na(sigZB)
                array.push(aBx, box.new(xl, sigZT, xr, sigZB, xloc = xloc.bar_index, bgcolor = color.new(zoneCol, 80), border_color = color.new(zoneCol, 45), border_width = 1))

        if showLines
            array.push(aLn, line.new(bar_index, ent, xr, ent, xloc = xloc.bar_index, color = color.new(col, 0), width = 2))
            array.push(aLn, line.new(bar_index, stp, xr, stp, xloc = xloc.bar_index, color = color.new(badCol, 5), width = 1, style = line.style_dashed))
            array.push(aLn, line.new(bar_index, t1, xr, t1, xloc = xloc.bar_index, color = color.new(col, 20), width = 1))
            array.push(aLn, line.new(bar_index, t2, xr, t2, xloc = xloc.bar_index, color = color.new(col, 35), width = 1))
            array.push(aLn, line.new(bar_index, t3, xr, t3, xloc = xloc.bar_index, color = color.new(haveDol ? dolCol : col, 10), width = haveDol ? 2 : 1, style = haveDol ? line.style_solid : line.style_dotted))
            if not na(sigPool)
                array.push(aLn, line.new(xl, sigPool, xr, sigPool, xloc = xloc.bar_index, color = color.new(poolCol, 20), width = 1))
        if showFib
            eq = (sigVext + t3) / 2.0
            array.push(aLn, line.new(xl, sigVext, xr, sigVext, xloc = xloc.bar_index, color = color.new(poolCol, 45), width = 1, style = line.style_dotted))
            array.push(aLn, line.new(xl, eq, xr, eq, xloc = xloc.bar_index, color = color.new(dolCol, 45), width = 1, style = line.style_dotted))
            array.push(aLbS, label.new(xl, sigVext, "0", xloc = xloc.bar_index, style = label.style_label_right, color = color.new(panelBg, 20), textcolor = txtLo, size = size.tiny))
            array.push(aLbS, label.new(xl, eq, "0.5", xloc = xloc.bar_index, style = label.style_label_right, color = color.new(panelBg, 20), textcolor = txtLo, size = size.tiny))

        if showVTag
            array.push(aLbS, label.new(xl, (ent + stp) / 2.0, "V-SHAPE", xloc = xloc.bar_index, style = label.style_none, textcolor = color.new(color.white, 10), size = f_size(lblSizeOpt)))
            if not na(sigPool)
                array.push(aLbS, label.new(xl, sigPool, "IRL", xloc = xloc.bar_index, style = label.style_none, textcolor = color.new(txtLo, 0), size = size.tiny))

        if showLevelLbl
            zTag = sigZK == 1 ? "IFVG" : sigZK == 2 ? "FVG" : "RAW"
            head = (isL ? "LONG " : "SHORT ") + zTag + "  " + str.tostring(sigScore, "#.#") + "/10"
            array.push(aLbR, label.new(xr, ent, head + "  @ " + str.tostring(ent, format.mintick) + "  · BE", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 0), textcolor = color.white, size = f_size(lblSizeOpt)))
            array.push(aLbR, label.new(xr, stp, "SL @ " + str.tostring(stp, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(badCol, 5), textcolor = color.white, size = f_size(lblSizeOpt)))
            array.push(aLbR, label.new(xr, t1, "TP1 " + str.tostring(tp1R, "#.#") + "R @ " + str.tostring(t1, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 15), textcolor = color.white, size = f_size(lblSizeOpt)))
            array.push(aLbR, label.new(xr, t2, "TP2 " + str.tostring(tp2R, "#.#") + "R @ " + str.tostring(t2, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(col, 30), textcolor = color.white, size = f_size(lblSizeOpt)))
            array.push(aLbR, label.new(xr, t3, (haveDol ? "DOL " : "TP3 ") + str.tostring(r3, "#.#") + "R @ " + str.tostring(t3, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(haveDol ? dolCol : col, 10), textcolor = color.new(#0b0e16, 0), size = f_size(lblSizeOpt)))

if showSigLbl and (fireLong or fireShort)
    isL  = fireLong
    col  = isL ? longCol : shortCol
    zTag = sigZK == 1 ? "IFVG" : sigZK == 2 ? "FVG" : "RAW V"
    rk   = math.abs(sigEntry - sigStop)
    dp   = isL ? f_dolAbove(sigEntry, rk, floorRR) : f_dolBelow(sigEntry, rk, floorRR)
    head = isL ? "V-SHAPE LONG" : "V-SHAPE SHORT"
    txt  = showStars ? head + "\n" + f_stars(sigScore) + "  " + str.tostring(sigScore, "#.#") + "/10  " + f_tier(sigScore) + "  ·  " + zTag : head
    array.push(aLbS, label.new(bar_index, isL ? low : high, txt, style = isL ? label.style_label_up : label.style_label_down, color = color.new(col, 6), textcolor = color.white, size = f_size(lblSizeOpt), tooltip = f_tip(isL ? 1 : -1, sigScore, nz(sigPool, 0), sigZK, dp)))

if not tActive
    while array.size(aLbS) > 40
        label.delete(array.shift(aLbS))

var line dolUpLn = na
var line dolDnLn = na
var label dolUpLb = na
var label dolDnLb = na
upDol = f_nearestUp()
dnDol = f_nearestDn()

if barstate.islast and showDolLive
    if not na(dolUpLn)
        line.delete(dolUpLn)
    if not na(dolDnLn)
        line.delete(dolDnLn)
    if not na(dolUpLb)
        label.delete(dolUpLb)
    if not na(dolDnLb)
        label.delete(dolDnLb)
    if not na(upDol)
        dolUpLn := line.new(bar_index - 40, upDol, bar_index + 20, upDol, xloc = xloc.bar_index, color = color.new(dolCol, 35), width = 1, style = line.style_dashed)
        dolUpLb := label.new(bar_index + 20, upDol, "DOL ↑", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(dolCol, 20), textcolor = color.new(#0b0e16, 0), size = size.tiny)
    if not na(dnDol)
        dolDnLn := line.new(bar_index - 40, dnDol, bar_index + 20, dnDol, xloc = xloc.bar_index, color = color.new(dolCol, 35), width = 1, style = line.style_dashed)
        dolDnLb := label.new(bar_index + 20, dnDol, "DOL ↓", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(dolCol, 20), textcolor = color.new(#0b0e16, 0), size = size.tiny)

winRate = sClosed > 0 ? sWins / sClosed * 100.0 : 0.0
avgR    = sClosed > 0 ? sR / sClosed : 0.0
pf      = sGrossL > 0 ? sGrossW / sGrossL : sGrossW > 0 ? 999.0 : 0.0
longWR  = sLong  > 0 ? sLongWin  / sLong  * 100.0 : 0.0
shortWR = sShort > 0 ? sShortWin / sShort * 100.0 : 0.0
tp1Rate = sClosed > 0 ? sTp1 / sClosed * 100.0 : 0.0
tp2Rate = sClosed > 0 ? sTp2 / sClosed * 100.0 : 0.0
tp3Rate = sClosed > 0 ? sTp3 / sClosed * 100.0 : 0.0
slRate  = sClosed > 0 ? sSl  / sClosed * 100.0 : 0.0

statusTxt = tActive ? (tSide == 1 ? "IN LONG" : "IN SHORT") : Lst == 2 ? "ARMED LONG" : Sst == 2 ? "ARMED SHORT" : Lst == 1 ? "SWEEPING LOWS" : Sst == 1 ? "SWEEPING HIGHS" : "WAITING"
statusC   = tActive ? (tSide == 1 ? longCol : shortCol) : Lst == 2 ? longCol : Sst == 2 ? shortCol : (Lst == 1 or Sst == 1) ? warnCol : neutralCol
liveScore = Lst == 2 ? Lscore : Sst == 2 ? Sscore : tActive ? tScore : na
zoneTxt   = Lst == 2 ? (LzKind == 1 ? "IFVG " : "FVG ") + str.tostring(LzBot, format.mintick) + " – " + str.tostring(LzTop, format.mintick) : Sst == 2 ? (SzKind == 1 ? "IFVG " : "FVG ") + str.tostring(SzBot, format.mintick) + " – " + str.tostring(SzTop, format.mintick) : tActive ? (tZKind == 1 ? "IFVG entry" : tZKind == 2 ? "FVG entry" : "Raw V entry") : "—"
dolUpTxt  = na(upDol) ? "—" : str.tostring(upDol, format.mintick) + "  (" + str.tostring((upDol - close) / safeAtr, "#.#") + " ATR)"
dolDnTxt  = na(dnDol) ? "—" : str.tostring(dnDol, format.mintick) + "  (" + str.tostring((close - dnDol) / safeAtr, "#.#") + " ATR)"
bestDir   = sLong == 0 and sShort == 0 ? "—" : sLong > 0 and sShort == 0 ? "LONG" : sShort > 0 and sLong == 0 ? "SHORT" : longWR > shortWR ? "LONG" : shortWR > longWR ? "SHORT" : "EVEN"
streakTxt = sStreak > 0 ? "W" + str.tostring(sStreak) : sStreak < 0 ? "L" + str.tostring(math.abs(sStreak)) : "—"
pfTxt     = pf >= 999.0 ? "INF" : str.tostring(pf, "#.##")
wrC       = winRate >= 55 ? goodCol : winRate >= 45 ? warnCol : badCol
pfC       = pf >= 1.5 ? goodCol : pf >= 1.0 ? warnCol : badCol
lastTxt   = lastSide == 1 ? "LONG" : lastSide == -1 ? "SHORT" : "—"

scHas    = scSide != 0
scDirTxt = scSide == 1 ? "V-SHAPE LONG" : scSide == -1 ? "V-SHAPE SHORT" : "no signal yet"
scDirCol = scSide == 1 ? longCol : scSide == -1 ? shortCol : neutralCol
scSetupT = scHas ? f_stars(scScore) + "  " + str.tostring(scScore, "#.#") + "/10  " + f_tier(scScore) : "—"
scConfT  = not scHas ? "—" : scZK == 0 ? "RAW V · no imbalance" : (scZK == 1 ? "IFVG  " : "FVG  ") + str.tostring(scZB, format.mintick) + " – " + str.tostring(scZT, format.mintick)
scRaidT  = scHas and not na(scPool) ? str.tostring(scPool, format.mintick) + "  ·  " + str.tostring(nz(scDepth), "#.##") + " ATR deep" : "—"
scGeoT   = scHas ? str.tostring(nz(scDisp), "#.##") + " ATR in " + str.tostring(scVW) + " bars  ·  " + str.tostring(nz(scSharp), "#.##") + "/bar" : "—"
scEntT   = scHas ? str.tostring(scEnt, format.mintick) : "—"
scStopT  = scHas ? str.tostring(scStop, format.mintick) + "   (" + str.tostring(scRisk / safeAtr, "#.##") + " ATR)" : "—"
scTpT    = scHas ? str.tostring(scT1, format.mintick) + "  /  " + str.tostring(scT2, format.mintick) : "—"
scDolT   = not scHas ? "—" : na(scDol) ? "none in range · flat " + str.tostring(tp3R, "#.#") + "R" : str.tostring(scDol, format.mintick) + "   (" + str.tostring(scR3, "#.#") + "R)"
scBiasT  = not scHas ? "—" : biasMode == "Off" ? "filter off" : (scBias ? "ALIGNED" : "AGAINST") + "  ·  " + biasTxt
scLiveR  = tActive and scBar == tBar and not na(tEntry) and math.abs(tEntry - tStop) > 0 ? (tSide == 1 ? close - tEntry : tEntry - close) / math.abs(tEntry - tStop) : na
scOutT   = scOutcome == "LIVE" and not na(scLiveR) ? "LIVE   " + f_signedR(scLiveR) + " open" : scOutcome
scOutC   = not na(scOutR) ? (scOutR > 0 ? goodCol : badCol) : scOutcome == "LIVE" ? warnCol : neutralCol

f_prow(table t, int r, string k, string v, color vc, color bg, string ts) =>
    table.cell(t, 0, r, k, text_color = txtLo, text_size = ts, text_halign = text.align_left,   bgcolor = bg)
    table.cell(t, 1, r, v, text_color = vc,    text_size = ts, text_halign = text.align_center, bgcolor = bg)

f_psec(table t, int r, string title, string note, color nc, string ts) =>
    table.cell(t, 0, r, title, text_color = txtHi, text_size = ts, text_halign = text.align_left,   bgcolor = panelHdr)
    table.cell(t, 1, r, note,  text_color = nc,    text_size = ts, text_halign = text.align_center, bgcolor = panelHdr)

int card1Rows = 9 + (showSetupRows ? 4 : 0) + (showHeatRow ? 1 : 0)
int needRows  = card1Rows + (showScen ? cardGap + 11 : 0)

var table dash  = na
var int   dashN = 0

if barstate.islast and showDash
    if na(dash) or dashN != needRows
        if not na(dash)
            table.delete(dash)
        dash  := table.new(f_pos(dashPosOpt), 2, needRows, bgcolor = #00000000, border_width = 0, frame_width = 0)
        dashN := needRows
    table.clear(dash, 0, 0, 1, needRows - 1)
    ps = f_size(dashSizeOpt)
    int r = 0

    f_psec(dash, r, "STRONG V DOL FVG", "SIGNALS", dolCol, ps), r += 1
    f_prow(dash, r, "Status", statusTxt, statusC, panelBg, ps), r += 1
    f_prow(dash, r, "HTF Bias (" + biasTf + ")", biasTxt, biasBull ? longCol : biasBear ? shortCol : neutralCol, panelBgAlt, ps), r += 1
    if showSetupRows
        f_prow(dash, r, "V-Score", na(liveScore) ? "—" : f_gauge(liveScore) + " " + str.tostring(liveScore, "#.#") + " " + f_tier(liveScore), na(liveScore) ? neutralCol : liveScore >= strongThr ? goodCol : liveScore >= minScore ? warnCol : txtLo, panelBg, ps), r += 1
        f_prow(dash, r, "Entry Zone", zoneTxt, zoneTxt == "—" ? neutralCol : zoneCol, panelBgAlt, ps), r += 1
        f_prow(dash, r, "DOL Above", dolUpTxt, na(upDol) ? neutralCol : txtHi, panelBg, ps), r += 1
        f_prow(dash, r, "DOL Below", dolDnTxt, na(dnDol) ? neutralCol : txtHi, panelBgAlt, ps), r += 1
    f_prow(dash, r, "Last Signal", lastTxt + (na(lastScore) ? "" : "  " + f_stars(lastScore)), lastSide == 1 ? longCol : lastSide == -1 ? shortCol : neutralCol, panelBg, ps), r += 1
    f_prow(dash, r, "Win Rate", sClosed > 0 ? str.tostring(winRate, "#.#") + "%  (" + str.tostring(sWins) + "/" + str.tostring(sClosed) + ")" : "—", sClosed > 0 ? wrC : neutralCol, panelBgAlt, ps), r += 1
    f_prow(dash, r, "Profit Factor", sClosed > 0 ? pfTxt : "—", sClosed > 0 ? pfC : neutralCol, panelBg, ps), r += 1
    f_prow(dash, r, "Avg R / Trade", sClosed > 0 ? f_signedR(avgR) : "—", sClosed > 0 ? (avgR >= 0 ? goodCol : badCol) : neutralCol, panelBgAlt, ps), r += 1
    f_prow(dash, r, "L / S Win%", sClosed > 0 ? str.tostring(longWR, "#") + " / " + str.tostring(shortWR, "#") : "—", txtHi, panelBg, ps), r += 1
    f_prow(dash, r, "Streak", streakTxt + "  (max W" + str.tostring(sMaxWin) + " / L" + str.tostring(sMaxLos) + ")", sStreak >= 0 ? goodCol : badCol, panelBgAlt, ps), r += 1
    if showHeatRow
        f_prow(dash, r, "TP1/2/3 · SL", str.tostring(tp1Rate, "#") + "/" + str.tostring(tp2Rate, "#") + "/" + str.tostring(tp3Rate, "#") + " · " + str.tostring(slRate, "#") + "%", txtHi, panelHdr, ps), r += 1

    if showScen
        for g = 1 to cardGap
            table.cell(dash, 0, r, "", bgcolor = #00000000, text_size = ps)
            table.cell(dash, 1, r, "", bgcolor = #00000000, text_size = ps)
            r += 1
        f_psec(dash, r, "SCENARIO", scDirTxt, scDirCol, ps), r += 1
        f_prow(dash, r, "Setup",        scSetupT, scHas ? scDirCol : neutralCol, panelBg, ps), r += 1
        f_prow(dash, r, "Confirmation", scConfT, scHas and scZK > 0 ? zoneCol : neutralCol, panelBgAlt, ps), r += 1
        f_prow(dash, r, "Raid (IRL)",   scRaidT, scHas ? poolCol : neutralCol, panelBg, ps), r += 1
        f_prow(dash, r, "V Geometry",   scGeoT, scHas ? txtHi : neutralCol, panelBgAlt, ps), r += 1
        f_prow(dash, r, "Entry",        scEntT, scHas ? scDirCol : neutralCol, panelBg, ps), r += 1
        f_prow(dash, r, "Invalidation", scStopT, scHas ? badCol : neutralCol, panelBgAlt, ps), r += 1
        f_prow(dash, r, "TP1 · TP2",    scTpT, scHas ? txtHi : neutralCol, panelBg, ps), r += 1
        f_prow(dash, r, "DOL Target",   scDolT, scHas and not na(scDol) ? dolCol : scHas ? txtLo : neutralCol, panelBgAlt, ps), r += 1
        f_prow(dash, r, "HTF Bias",     scBiasT, not scHas ? neutralCol : scBias ? goodCol : warnCol, panelBg, ps), r += 1
        f_prow(dash, r, "Outcome",      scOutT, scOutC, panelBgAlt, ps), r += 1

armedLong  = Lst == 2 and Lst[1] != 2
armedShort = Sst == 2 and Sst[1] != 2
alertcondition(armedLong,  "Strong V Armed LONG",  "Strong V DOL FVG Signals: sell-side liquidity swept and reclaimed on {{ticker}} {{interval}} — bullish IFVG/FVG zone armed, waiting for the retest.")
alertcondition(armedShort, "Strong V Armed SHORT", "Strong V DOL FVG Signals: buy-side liquidity swept and reclaimed on {{ticker}} {{interval}} — bearish IFVG/FVG zone armed, waiting for the retest.")
alertcondition(fireLong,   "Strong V Entry LONG",  "Strong V DOL FVG Signals: LONG entry on {{ticker}} {{interval}} @ {{close}} — V-shape recovery confirmed, targeting the DOL above.")
alertcondition(fireShort,  "Strong V Entry SHORT", "Strong V DOL FVG Signals: SHORT entry on {{ticker}} {{interval}} @ {{close}} — V-shape rejection confirmed, targeting the DOL below.")
alertcondition(fireLong or fireShort, "Any Strong V Entry", "Strong V DOL FVG Signals: new V-shape entry on {{ticker}} {{interval}} @ {{close}}.")
alertcondition(closedTp3,  "Strong V Final Target Hit", "Strong V DOL FVG Signals: DOL / final target reached on {{ticker}} {{interval}}.")
alertcondition(closedSl,   "Strong V Stop Hit", "Strong V DOL FVG Signals: stop hit behind the V-shape extreme on {{ticker}} {{interval}}.")
````
