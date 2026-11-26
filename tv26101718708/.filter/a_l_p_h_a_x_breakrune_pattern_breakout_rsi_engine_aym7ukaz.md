# [ A L P H A X ] BREAKRUNE - Pattern Breakout RSI Engine

- url: https://www.tradingview.com/script/AYM7Ukaz-A-L-P-H-A-X-BREAKRUNE-Pattern-Breakout-RSI-Engine/
- type: indicator
- pine_id: PUB;bd172c0bae8243328d635b8e213579a9
- version: 1.0

## Description

[b]AlphaX BREAKRUNE — Pattern Breakout Intelligence + RSI Trigger Engine: Real vs Fake Breakout Classification, Five-Pattern Detection, Fakeout Reversal Signals & Pending State Machine[/b]

AlphaX BREAKRUNE is a professional-grade breakout intelligence system built around a single foundational problem that defeats most breakout traders: the inability to distinguish a genuine structural breakout from a fakeout in real time. Most breakout indicators fire on any close beyond a pattern boundary — and then leave the trader holding a loss when price immediately reverses back inside the structure. BREAKRUNE solves this at the architectural level by separating breakout detection into three sequential phases — pattern recognition, breakout classification, and RSI trigger confirmation — and requiring all three to align before a signal fires. Every raw break is first classified as PENDING, then evaluated over a configurable decision window for either TRUE BREAK or FAKEOUT status using candle body and wick geometry, and only confirmed true breaks with RSI momentum alignment produce long or short entry signals. Fakeouts become their own opportunity: when a breakout is classified as fake, BREAKRUNE reverses the bias and watches for an RSI-confirmed trap reversal signal in the opposite direction. The result is a system that profits not just from real breakouts but also from the very fakeouts that trap the crowd — with the RSI trigger layer ensuring every entry has genuine momentum behind it. Designed for traders across crypto, forex, gold, and indices on any timeframe.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔮 [b]The Core Philosophy — Three Phases Before a Signal[/b]

The fundamental failure of conventional breakout systems is compression of the detection and confirmation steps into a single bar event. Price closes above resistance — signal fires. This approach has no mechanism for distinguishing momentum breakouts from stop-hunt spikes, thin-market wicks, or false structural breaks that reverse immediately.

BREAKRUNE separates these into three distinct sequential phases that every potential signal must pass through:

[b]Phase 1 — Pattern Recognition:[/b]
The system continuously scans the pivot structure to identify one of five major pattern types — Range, Double Top/Bottom, Triangle, Wedge, or Trend Channel. The detected pattern provides the structural context for the breakout evaluation: where the resistance and support levels are, what the directional bias of the formation is, and whether the pattern height meets the minimum size requirement for a qualified break.

[b]Phase 2 — Breakout Classification:[/b]
When a raw break of the pattern boundary occurs, the system enters PENDING state. Over the next configurable bars (the fakeout decision window), it watches for one of two outcomes. If candles close back inside the structure with a significant rejection wick, the break is reclassified as FAKEOUT. If the required number of candles all close beyond the boundary without a wick rejection, the break is classified as TRUE BREAK. No premature signal fires during this window — the system waits for the evidence.

[b]Phase 3 — RSI Trigger Confirmation:[/b]
Only after a TRUE BREAK or FAKEOUT classification does the RSI trigger layer evaluate. For true breaks, the Fast RSI must be above the configured long trigger (default: 55) with Core RSI above 50 and both RSI slopes positive. For fakeout reversals, the Fast RSI must cross the midline in the reversal direction with positive directional slope. Both must pass the quality score gate. Only then does a signal fire.

This three-phase architecture is what makes BREAKRUNE categorically different from breakout indicators that react to a single bar event.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📐 [b]Five-Pattern Detection Engine[/b]

BREAKRUNE continuously classifies the current market structure into one of five pattern types using the most recent confirmed pivot highs and lows. Every pattern provides resistance (res) and support (sup) levels used as the breakout boundaries.

[b]Pattern detection uses:[/b]
Confirmed fractal pivot highs and lows (configurable pivot length, default: 5 bars each side), ATR-normalized tolerance values for determining flat vs sloped levels, and a minimum pattern height filter to eliminate micro-structures.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]Range:[/b]
Both the most recent pivot high and pivot low are within the flat level tolerance (default: 0.35× ATR) of their respective prior pivots — price has been oscillating between approximately horizontal support and resistance. The pattern bias is neutral (patBias = 0) — a range can break either direction. The resistance is the average of the two pivot highs; support is the average of the two pivot lows.

[b]Double Top / Double Bottom:[/b]
Two pivot highs at approximately the same level (within flat tolerance) with the current price below both peaks — Double Top, bearish bias. Or two pivot lows at the same level with current price above — Double Bottom, bullish bias. The pattern height is the distance from the support/resistance level to the opposing pivot extreme. The directional bias (patBias) is set accordingly — bearish for Double Top, bullish for Double Bottom.

[b]Triangle (Converging):[/b]
The pivot highs are trending lower (by more than the trend shift tolerance, default: 0.20× ATR, between consecutive highs) while the pivot lows are trending higher — a symmetrical converging triangle. No directional bias is set (patBias = 0) since triangles resolve in either direction. The resistance is the most recent pivot high; support is the most recent pivot low.

[b]Wedge:[/b]
Both pivot highs and pivot lows are trending in the same direction. Rising Wedge: both highs and lows trending upward — despite the upward direction the narrowing structure is bearish (patBias = -1). Falling Wedge: both trending downward — bullish (patBias = 1). The wedge pattern is identified when the pivot-to-pivot shift exceeds the trend tolerance on both sides in the same direction.

[b]Trend Channel:[/b]
Pivot highs are trending in one direction and pivot lows are trending in the same direction, but the high trend direction opposes the expected wedge classification — a parallel channel. The channel bias follows the direction of the trend (upward-sloping channel = bullish patBias, downward = bearish).

[b]Pattern freshness filter:[/b]
All pivot-based pattern detections are subject to a maximum age constraint (default: 80 bars from the most recent contributing pivot). Patterns older than this threshold are excluded from pattern detection — the oldest pivot must be within the freshness window for the pattern to be considered current and relevant.

[b]Pattern size validation:[/b]
The pattern height (distance from support to resistance) must meet or exceed the minimum pattern height in ATR multiples (default: 1.1× ATR). This sizeOk condition contributes 2 points to the quality score — the largest single weight component — and reflects that properly sized patterns have more institutional significance than micro-structures.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]The Breakout Classifier — PENDING → TRUE BREAK or FAKEOUT[/b]

When price closes beyond a pattern boundary by more than the break threshold (default: 0.12× ATR), a raw break event is registered and the breakout classifier enters PENDING state. From this moment, every bar within the fakeout decision window (default: 5 bars) is evaluated.

[b]Raw break detection:[/b]
[list]
[*][b]Long raw break:[/b] Close above the resistance level plus break threshold, with the pattern allowing long breaks (not a bearish pattern — Double Top and Rising Wedge suppress long breaks)
[*][b]Short raw break:[/b] Close below the support level minus break threshold, with the pattern allowing short breaks
[/list]

[b]PENDING state variables stored at the break bar:[/b]
The direction (pendingDir), the exact level broken (pendingLvl), the bar index of the break (pendingBar), and the pattern name (pendingPat) are all stored in persistent variables. The PENDING state is displayed on the dashboard CLASS row as PENDING — visible awareness that a break has occurred and is being evaluated.

[b]FAKEOUT classification:[/b]
Within the fakeout window (pendingAge ≤ fakeWindow), if price closes back inside the pattern:
[list]
[*]For a long break fakeout: close falls back below the broken resistance level AND the upper wick of the current bar exceeds the configurable minimum wick rejection ratio (default: 45% of bar range) — the bar closed back inside with a dominant upper wick, confirming selling rejection of the attempted breakout
[*]For a short break fakeout: close rises back above the broken support AND the lower wick exceeds the minimum ratio
[/list]
When these conditions are met, pendingFake is set to true and the CLASS row displays FAKEOUT — the orange classification that activates the trap reversal signal pathway.

[b]TRUE BREAK classification:[/b]
When the configurable number of consecutive candles (default: 2 bars) all close beyond the broken level — `ta.lowest(close, confirmBars) > pendingLvl` for longs, `ta.highest(close, confirmBars) < pendingLvl` for shorts — without any fakeout having been detected, pendingTrue is set to true and CLASS displays TRUE BREAK. The confirmed candles all remaining beyond the level eliminates the single-bar false breakout.

[b]Window expiry:[/b]
If neither FAKEOUT nor TRUE BREAK is classified within the fakeout window, the pending state expires silently — pendingDir resets to zero, the level clears, and the system resumes scanning. This prevents stale pending states from generating signals long after the relevant price action has passed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]The RSI Trigger Layer — Momentum Gating on Classified Breaks[/b]

The RSI trigger layer is the final gate before a signal fires. It ensures every entry — whether on a true break or a fakeout reversal — has genuine momentum direction behind it at the moment of entry.

[b]Dual RSI architecture:[/b]
[list]
[*][b]Fast RSI (default: 7 periods)[/b] — the timing layer. Reacts quickly to price movement and provides the momentum trigger reading
[*][b]Core RSI (default: 14 periods)[/b] — the confirmation layer. The intermediate momentum context that must agree with the fast RSI direction
[/list]

[b]RSI slope measurement:[/b]
Both RSI slopes are computed over the configurable slope bars (default: 3 bars) — the current RSI value minus the value N bars ago. A positive slope means RSI is accelerating; a negative slope means decelerating.

[b]True Break Long RSI conditions (rsiLongOk):[/b]
[list]
[*]Fast RSI above the long trigger threshold (default: 55) — momentum has already crossed into bullish territory
[*]Core RSI above 50 — the intermediate RSI confirms the bullish bias
[*]Fast RSI slope positive — momentum is still accelerating upward
[*]Core RSI slope non-negative — intermediate momentum is not rolling over
[/list]

[b]True Break Short RSI conditions (rsiShortOk):[/b]
[list]
[*]Fast RSI below the short trigger threshold (default: 45)
[*]Core RSI below 50
[*]Fast RSI slope negative
[*]Core RSI slope non-positive
[/list]

[b]Fakeout Reversal RSI conditions:[/b]
[list]
[*][b]Trap Long (rsiTrapLong):[/b] Fast RSI crosses above 50 (ta.crossover) with a positive slope — the RSI midline crossover after the fakeout confirms the reversal is gaining momentum
[*][b]Trap Short (rsiTrapShort):[/b] Fast RSI crosses below 50 with a negative slope
[/list]

[b]Why the RSI trigger is a layer, not a gate:[/b] The RSI conditions are required for the signal to fire but are also the primary quality score component (2 points when fully met). This dual role means the RSI is simultaneously a hard entry requirement and a quality contributor — signals that barely pass the RSI threshold score lower than signals where momentum is strongly confirmed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔀 [b]The Fakeout Reversal — Trapping the Trap[/b]

The fakeout reversal is BREAKRUNE's most distinctive and high-reward signal type. When a long breakout is classified as FAKEOUT (price returned below resistance with a rejection wick), the crowd that bought the breakout is now trapped — holding longs above what has become confirmed resistance again. The RSI trap reversal watches for the Fast RSI to cross below 50 with negative slope: the momentum of the trapped buyers failing. When this occurs within the cooldown window, a short signal fires — entering precisely as the trapped longs begin capitulating.

[b]Why fakeout reversals often produce the strongest moves:[/b] A failed breakout above resistance concentrates stop losses of all the breakout buyers just above the resistance level. As those stops are triggered on the reversal, they add selling pressure to the downside move — creating a self-reinforcing cascade. The fakeout reversal entry captures this cascade from near the top.

[b]Enabling/disabling:[/b] The Enable Fakeout Reversal Signals setting (default: on) controls whether trap reversal signals are active. Disabling it restricts BREAKRUNE to true break signals only — appropriate for traders who prefer pure momentum continuation entries.

[b]Visual differentiation:[/b] True break signals are rendered in the standard bull/bear score-based colors (yellow-green for longs, red for shorts). Fakeout reversal signals fire through the same triangle shapes but with the quality score reflecting the trap penalty — trap signals score 1 point on the setup component vs 2 for true breaks, naturally producing slightly lower overall scores that are reflected in the triangle's brightness.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏅 [b]The 10-Point Quality Score[/b]

Every signal — true break or fakeout reversal — is scored through a 10-point composite system before it can fire. Signals below the minimum threshold (default: 5) are suppressed regardless of classification.

[b]Score components:[/b]

[b]Pattern Size (up to 2 points):[/b]
sizeOk (pattern height ≥ minimum ATR threshold) scores 2 points. A zero-score here (pattern too small) alone can suppress a signal by 2 points — the largest single deduction possible. Well-sized patterns carry proportionally more institutional significance and this component enforces that.

[b]RSI Trigger Alignment (up to 2 points):[/b]
rsiLongOk (for long signals) or rsiShortOk (for short signals) scores 2 points. This is the second largest component — reflecting that genuine momentum confirmation at the moment of entry is as important as pattern quality. Signals where RSI barely meets the threshold (Fast RSI just above 55 with flat slope) score these 2 points; signals where RSI is not aligned at all score 0.

[b]Signal Type (1–2 points):[/b]
True break signals score 2 points; fakeout reversal (trap) signals score 1 point. This weighting reflects the inherently lower confirmation of a reversal trade versus a confirmed structural continuation — the trap trade is valid but carries more uncertainty.

[b]Volume Confirmation (1 point):[/b]
Current bar volume meets or exceeds the volume average × multiplier (default: 1.1×). When volume confirmation is disabled in settings, this point is always awarded.

[b]Non-Chop Market (1 point):[/b]
Choppiness Index is below the configured threshold (default: 62.0). Also enforced as a hard gate — extreme chop blocks all signals regardless of score.

[b]HTF Bias (up to 2 points):[/b]
When useHtf is on and the higher timeframe EMA structure agrees with the signal direction (htfBull for longs, htfBear for shorts), 2 points are awarded. When HTF is disabled, 1 neutral point is always given. When HTF opposes the signal and useHtf is on, 0 points. This component has the same maximum weight as RSI and pattern size — reflecting the institutional significance of macro directional alignment.

[b]Grade-coded signal colors:[/b]
Score 8–10 → full brightness (colBull / colBear). Score 6–7 → slightly dimmer. Score below 6 → transparent-tinted version. The triangle color communicates quality at a glance without reading the dashboard.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 [b]Live Dashboard[/b]

The 10-row real-time dashboard displays the complete internal state of the breakout classifier and all filter conditions.

[list]
[*][b]PATTERN[/b] — the current detected pattern: Range, Dbl Top, Dbl Bot, Triangle, Rising Wedge, Falling Wedge, Up Channel, Down Channel. Purple color. Updates on every bar as the pivot structure evolves
[*][b]CLASS[/b] — the current breakout classification state: IDLE (no pending break), PENDING (raw break registered, evaluating), TRUE BREAK (confirmed continuation), FAKEOUT (rejection detected, reversal watching). Color-coded — yellow-green for TRUE BREAK, orange for FAKEOUT, neutral for IDLE/PENDING
[*][b]BIAS[/b] — the directional bias: BULL (pendingDir=1 or patBias=1), BEAR (pendingDir=-1 or patBias=-1), or NEUTRAL. Yellow-green or red
[*][b]LEVELS[/b] — the current support and resistance levels as a price pair (e.g., "2450.50 / 2490.25"). The exact boundaries the breakout classifier is watching
[*][b]QUALITY[/b] — the live quality score out of 10. Yellow-green when at or above the minimum threshold, neutral otherwise
[*][b]RSI F/C[/b] — the live Fast RSI and Core RSI values as a pair (e.g., "58.4 / 53.7"). Yellow-green when above 50, red when below
[*][b]HTF[/b] — higher timeframe EMA structure: ▲ BULL, ▼ BEAR, or — FLAT
[*][b]CHOP[/b] — live Choppiness Index value. Orange when above the block threshold
[*][b]VOL[/b] — CONFIRMED (volume above threshold) or LIGHT (below threshold). Yellow-green or orange
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 [b]Chart Visual System[/b]

[list]
[*][b]Pattern Boundary Lines[/b] — when Show Pattern Boundary Lines is enabled, a resistance line (res, red-tinted) and support line (sup, yellow-green-tinted) are drawn from the pattern's origin bar to the current bar, showing the exact levels the breakout classifier is watching
[*][b]▲ Triangle (below bar)[/b] — long signal. Full brightness yellow-green for score 8+, standard for 6–7, transparent-tinted for minimum score. Fires on both TRUE BREAK longs and FAKEOUT reversal longs (trap shorts become long entries)
[*][b]▼ Triangle (above bar)[/b] — short signal with matching grade-coded coloring
[*][b]✕ Cross (above bar, orange)[/b] — fakeout mark for a failed long breakout. Appears when Show Fakeout Marks is enabled and fakeLongNow fires. The orange × above the bar is the visual alert that a bull breakout has been rejected
[*][b]✕ Cross (below bar, orange)[/b] — fakeout mark for a failed short breakout
[*][b]Candle tinting[/b] — when Show Tint Candles by Active Bias is enabled, bars are tinted yellow-green (bias=1) or red (bias=-1) during active pending or pattern-biased periods. The tint shows the directional context continuously, not just at signal bars
[*][b]SL Line (red dashed)[/b] — when Show SL + TP1 + TP2 is on, the ATR-based stop loss level extending guideExtend bars forward
[*][b]TP1 Line (lime dotted)[/b] — first take profit at 1.8× ATR from entry
[*][b]TP2 Line (bright yellow-green dashed, width 2)[/b] — second take profit at 3.0× ATR from entry
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 [b]How to Trade with AlphaX BREAKRUNE — Step by Step[/b]

[b]Step 1 — Read the Pattern and Levels[/b]
[list]
[*]Check the PATTERN row on the dashboard — what structure is the system currently detecting? A Triangle or Wedge has directional bias; a Range or Double Top/Bottom has a directional expectation. Understanding the pattern context helps you assess which breakout direction is more probable
[*]Check the LEVELS row — note the exact support and resistance prices. These are the lines the classifier is watching. If price is approaching resistance, a long break event may be imminent
[*]Check BIAS — if it already shows BULL or BEAR from the pattern's directional classification, the system has a pre-existing directional lean before any break occurs
[/list]

[b]Step 2 — Monitor the Breakout Classification[/b]
[list]
[*]When CLASS changes from IDLE to PENDING, a raw break has occurred. Watch the dashboard closely over the next fakeWindow bars — CLASS will shift to either TRUE BREAK or FAKEOUT
[*]If CLASS shows FAKEOUT with an orange × appearing on the chart, the fakeout reversal pathway has activated. Check RSI F/C — is the Fast RSI approaching or crossing the 50 midline in the reversal direction?
[*]If CLASS shows TRUE BREAK, check RSI F/C — is Fast RSI above 55 (long) or below 45 (short) with Core RSI confirming and slopes positive? If yes, a signal is likely imminent or has just fired
[/list]

[b]Step 3 — Enter on the Triangle Signal[/b]
[list]
[*]A ▲ or ▼ triangle confirms all three phases have aligned — pattern identified, break classified, RSI triggered, quality scored
[*]Read the triangle color — bright full-color triangle is Grade A (score 8+). This is the premium entry with all components confirming. Faded triangles are Grade C — valid but with reduced size
[*]The QUALITY row shows the exact score. For fakeout reversal signals, the score will typically be 1 point lower than an equivalent true break signal due to the trap signal type weighting
[*]Enable Show SL + TP1 + TP2 to see the ATR guide levels projecting forward from the signal bar
[/list]

[b]Step 4 — Manage the Trade[/b]
[list]
[*]Watch the CLASS row during the trade. A new PENDING state in the opposing direction during an open position is an early warning that a counter-breakout is developing
[*]Monitor RSI F/C — if Fast RSI begins rolling toward 50 against the trade direction, intermediate momentum is weakening. Consider taking TP1
[*]The candle tint changing from yellow-green to red (or vice versa) during a trade means the bias has reversed — this is a structural exit cue
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Identifying Low-Quality Conditions — When Not to Trade[/b]

[b]Stand aside when:[/b]
[list]
[*][b]CHOP is orange on the dashboard[/b] — the hard chop gate is active. All signals are blocked. Pattern breakouts in extreme chop environments are dominated by noise — the range is too oscillatory for genuine structural breaks
[*][b]CLASS shows PENDING for multiple consecutive bars with no resolution[/b] — when the system remains in PENDING state approaching the fakeWindow expiry without classifying as either TRUE BREAK or FAKEOUT, the break is ambiguous. The system will expire it silently. This ambiguity itself is a warning — directional commitment is absent
[*][b]Pattern height is too small (sizeOk = false, quality score below 7)[/b] — the pattern exists but is too narrow to produce meaningful measured moves. Low-quality entries at micro-patterns carry reduced reward with the same stop risk
[*][b]HTF Bias opposes the breakout direction[/b] — a bull breakout signal against a bearish HTF produces 0 HTF confluence points. The signal may still fire if other components score sufficiently, but counter-HTF breakouts resolve in the HTF direction far more often than not
[*][b]FAKEOUT class appears but RSI is not approaching the midline[/b] — a fakeout has been detected but the RSI trigger for the reversal has not yet materialized. ARM SHORT / ARM LONG conditions are developing but no signal has fired. Do not anticipate the reversal signal without the RSI confirmation — the reversal could still fail
[*][b]Multiple rapid PENDING → expiry cycles without TRUE BREAK or FAKEOUT[/b] — when the classifier repeatedly enters and exits PENDING state without resolving, the pattern boundary is being tested multiple times without follow-through. This is range-bound behavior masquerading as a breakout environment. Increase the break threshold or wait for a cleaner structural setup
[/list]

[b]The ideal BREAKRUNE setup:[/b]
[list]
[*]Well-sized pattern (sizeOk true, pattern height 2× ATR or more)
[*]Clean single raw break bar followed by TRUE BREAK classification within 2–3 bars
[*]Fast RSI clearly above 55 (long) or below 45 (short) with positive/negative slopes on both RSI layers
[*]HTF aligned with the breakout direction
[*]Volume confirmed on the breakout bar
[*]Chop Index well below threshold
[*]Quality score at 8–10 (Grade A triangle, full brightness)
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚡ [b]Key Features[/b]
[list]
[*]🔮 Three-phase breakout architecture — Pattern Recognition → Breakout Classification (PENDING → TRUE BREAK or FAKEOUT) → RSI Trigger Confirmation. No signal fires without all three phases completing sequentially
[*]📐 Five-pattern detection engine — Range, Double Top/Bottom, Triangle, Rising/Falling Wedge, and Trend Channel identified from confirmed pivot structure with freshness and size filters
[*]⚡ Real vs fake breakout classifier — candle body and wick geometry over a configurable decision window distinguishes genuine structural breaks from stop-hunt reversals before the signal fires
[*]🔀 Fakeout reversal signal mode — when a break is classified as FAKEOUT, BREAKRUNE reverses bias and watches for an RSI midline crossover trap signal in the opposing direction, profiting from the crowd that got trapped
[*]📊 Dual RSI trigger layer — Fast RSI (7) for timing precision and Core RSI (14) for momentum confirmation, with slope measurement on both. Required alignment conditions differ between true break and trap reversal entries
[*]✕ Live fakeout markers — orange × marks above (failed long break) or below (failed short break) on bars where fakeout classification occurs, providing real-time awareness of failed breakouts independently of signal generation
[*]🏅 10-point quality scoring — Pattern Size (2pts), RSI Alignment (2pts), Signal Type (1–2pts), Volume (1pt), Non-Chop (1pt), HTF Bias (2pts). Grade-coded triangle colors reflect score quality at a glance
[*]🎨 Candle tinting — bars tinted yellow-green during bull pending/bias periods and red during bear periods, providing continuous directional context between signals
[*]📊 10-row live dashboard — Pattern, Class, Bias, Levels, Quality, RSI F/C, HTF, Chop, and Volume updated in real time every bar
[*]🔔 3 alert conditions — BREAKRUNE Long, BREAKRUNE Short, BREAKRUNE Fakeout (independent alert for fakeout detection regardless of reversal signal)
[*]⚙ Fully configurable — pivot length, flat and trend tolerances, minimum pattern height, freshness window, break threshold, confirmation bars, fakeout decision window, wick rejection minimum, volume filter, dual RSI periods and trigger levels, RSI slope lookback, fakeout reversal enable, cooldown, quality minimum, HTF parameters, chop gate, SL/TP ATR multiples, guide extension, all visual toggles, and all colors are independently adjustable
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙ [b]Settings Reference[/b]

[b]Pattern Intelligence[/b]
[list]
[*]Pivot Length — fractal sensitivity for pivot detection (default: 5). Lower = more frequent smaller patterns; higher = fewer, larger structural patterns
[*]Flat Level Tol (xATR) — ATR tolerance for determining whether consecutive pivots are at the same level (default: 0.35). Controls Double Top/Bottom and Range classification sensitivity
[*]Trend Shift Tol (xATR) — ATR tolerance for determining whether consecutive pivots show a directional shift (default: 0.20). Controls Triangle, Wedge, and Channel classification
[*]Min Pattern Height (xATR) — minimum pattern height for the sizeOk condition and quality score (default: 1.1). Raise to filter micro-patterns
[*]Pattern Freshness (bars) — maximum age of the oldest contributing pivot for pattern classification (default: 80). Older pivots are excluded
[/list]

[b]Breakout Classifier[/b]
[list]
[*]Break Threshold (xATR) — minimum close extension beyond the pattern boundary to register a raw break (default: 0.12). Lower = more sensitive; higher = requires stronger breaks
[*]True Break Confirmation Bars — consecutive candles that must all close beyond the level for TRUE BREAK classification (default: 2)
[*]Fakeout Decision Window — maximum bars after the raw break within which FAKEOUT or TRUE BREAK must be classified (default: 5). After this window, the pending state expires
[*]Fakeout Wick Rejection Min — minimum wick-to-body ratio required for FAKEOUT classification (default: 0.45). Higher = requires more obvious rejection wicks
[*]Volume Confirm — require volume above average on the signal bar (default: on)
[*]Volume Avg Length / Volume vs Avg — volume baseline parameters (defaults: 20 bars / 1.1×)
[/list]

[b]RSI Trigger Layer[/b]
[list]
[*]RSI Fast — the timing RSI period (default: 7)
[*]RSI Core — the confirmation RSI period (default: 14)
[*]Long Trigger — minimum Fast RSI level for a true break long (default: 55). Above 50 is the baseline; raising this requires stronger bull momentum
[*]Short Trigger — maximum Fast RSI level for a true break short (default: 45)
[*]RSI Slope Bars — lookback period for RSI slope calculation (default: 3)
[*]Enable Fakeout Reversal Signals — toggle the trap reversal signal mode (default: on)
[/list]

[b]Confluence Gate[/b]
[list]
[*]Signal Cooldown (bars) — minimum bars between consecutive signals (default: 6)
[*]Min Quality Score (of 10) — minimum score to fire a signal (default: 5)
[*]HTF Bias Layer — when on, HTF alignment contributes up to 2 points to the quality score (default: on)
[*]Hard HTF Alignment — when on, counter-HTF signals are fully blocked regardless of score (default: off)
[*]HTF Timeframe / HTF Fast / Slow EMA — higher timeframe parameters (defaults: 60-minute / 21 / 55)
[*]Block Extreme Chop / Choppiness Length / Chop Block Above — chop gate parameters (defaults: on / 14 / 62.0)
[/list]

[b]Entry / Exit Guides[/b]
[list]
[*]Show SL + TP1 + TP2 — toggle guide line display (default: off)
[*]ATR Length — ATR calculation lookback (default: 14)
[*]SL (xATR) — stop loss distance in ATR multiples (default: 1.2)
[*]TP1 (xATR) — first take profit distance (default: 1.8)
[*]TP2 (xATR) — second take profit distance (default: 3.0)
[*]Guide Extend (bars) — bars forward the guide lines project (default: 30)
[/list]

[b]Display[/b]
[list]
[*]Show Pattern Boundary Lines — toggle the resistance and support boundary lines (default: on)
[*]Show Signals — toggle signal triangle rendering (default: on)
[*]Show Fakeout Marks — toggle the orange × fakeout markers (default: on)
[*]Tint Candles by Active Bias — toggle directional candle tinting (default: on)
[*]Show Dashboard — toggle the full dashboard (default: on)
[*]Dashboard Position — Top Left / Top Right / Bottom Left / Bottom Right
[/list]

[b]Colors[/b]
[list]
[*]Bull / Bull Bright — yellow-green family for bullish signals and tinting
[*]Bear / Bear Bright — red family for bearish signals
[*]Pattern Accent — purple for pattern labels, boundary lines, and structural elements
[*]Pending / Fakeout — orange for fakeout marks, CHOP warnings, and VOL LIGHT indicators
[*]Neutral — gray for IDLE class and neutral dashboard states
[*]Stop / TP1 / TP2 — individual guide line colors
[*]Dash BG / Dash Header / Dash Section / Dash Frame / Dash Text — full dashboard color control
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔔 [b]Alert Conditions (3 total)[/b]

[list]
[*][b]BREAKRUNE Long[/b] — all three phases confirmed for a long entry: pattern identified, TRUE BREAK or FAKEOUT reversal classified, RSI trigger aligned, quality score met
[*][b]BREAKRUNE Short[/b] — all conditions confirmed for a short entry
[*][b]BREAKRUNE Fakeout[/b] — a fakeout has been classified on the current bar (fakeLongNow or fakeShortNow). This fires independently of whether a reversal signal follows — useful for awareness of failed breaks even when the reversal RSI conditions are not yet met
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 [b]Recommended Settings by Instrument & Timeframe[/b]

The default configuration is optimized for [b]XAUUSD, major forex pairs, and crypto on M5–H1[/b]:
[list]
[*]Pivot Length at 5 — captures intraday structural swings without excessive micro-sensitivity
[*]Fakeout Window at 5 — on M5 this is 25 minutes, sufficient to observe whether a break holds or fails without waiting too long. On M15, consider reducing to 3
[*]Confirmation Bars at 2 — requires two consecutive closes beyond the level before TRUE BREAK classification. On M1, consider reducing to 1
[*]RSI Long/Short Triggers at 55/45 — the asymmetric thresholds (not 60/40) accept momentum confirmation that is directional but not yet overbought/oversold
[/list]

For other instruments or timeframes, adjust:
[list]
[*][b]M1–M3 scalping[/b] — reduce Pivot Length to 3, reduce Fakeout Window to 3, reduce Confirmation Bars to 1, reduce Cooldown to 3, tighten Break Threshold to 0.08
[*][b]H4–Daily swing trading[/b] — increase Pivot Length to 8–10, increase Pattern Freshness to 150, increase Fakeout Window to 8–10, increase Confirmation Bars to 3, increase TP2 to 5.0× ATR
[*][b]Crypto (BTC, ETH)[/b] — increase Fakeout Wick Rejection to 0.50 for crypto's wider rejection wicks, increase Break Threshold to 0.18, increase Min Quality to 6 for tighter filtering on volatile instruments
[*][b]Indices (NAS100, US30)[/b] — use Hard HTF Alignment (on), set RSI Long Trigger to 57, increase Confirmation Bars to 3 for cleaner index breakouts
[*][b]Pure true-break mode[/b] — disable Enable Fakeout Reversal Signals, raise Min Quality to 6, raise RSI Long Trigger to 58 for higher-conviction momentum-only entries
[*][b]Fakeout-specialist mode[/b] — enable Fakeout Reversal Signals, reduce Fakeout Wick Rejection to 0.38 for more sensitive fakeout detection, lower RSI Slope Bars to 2 for faster RSI crossover detection
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👥 [b]Who This Is For[/b]
[list]
[*]🔮 [b]Breakout traders who are tired of being faked out[/b] — BREAKRUNE is built specifically around the fakeout problem. The three-phase architecture exists for one reason: to separate genuine structural breaks from the stop-hunt reversals that cost breakout traders money consistently
[*]🔀 [b]Traders who want to profit from both real breaks AND fakeouts[/b] — the fakeout reversal signal mode transforms the system's most common failure scenario into its own entry opportunity. The crowd that bought the false breakout becomes the fuel for the reversal trade
[*]📊 [b]Pattern-aware traders who want quantified structure[/b] — the five-pattern detection engine provides automatic structural context without manual drawing. Every signal tells you which pattern type it came from
[*]📐 [b]Momentum traders who need RSI precision[/b] — the dual RSI trigger layer (Fast 7 + Core 14) with slope measurement provides the most precise momentum timing gate in the AlphaX breakout signal suite
[*]🧠 [b]Systematic traders who want state transparency[/b] — the PENDING → TRUE BREAK / FAKEOUT classification state machine is fully visible on the dashboard in real time. You always know exactly what phase the system is in and why
[*]🥇 [b]Gold and forex intraday traders[/b] — breakout and fakeout patterns are particularly consistent on XAUUSD and major forex pairs during London and New York session transitions. Default settings are calibrated for these instruments
[*]⚠ [b]Traders who struggle with breakout timing[/b] — the RSI trigger layer forces every entry to have genuine momentum behind it at the moment of entry, eliminating the common experience of entering a breakout just as momentum exhausts
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 [b]Notes[/b]
[list]
[*]All signals are confirmed on bar close — the indicator is non-repainting by design. Pattern detection, breakout classification, and RSI conditions all finalize on confirmed bars
[*]The pending state machine uses persistent variables (var) — the PENDING, TRUE BREAK, and FAKEOUT states persist across bars until resolved or expired. This is essential for multi-bar classification but means the state machine holds values from previous breakout events. A signal firing clears all pending state variables
[*]Pattern detection is a best-fit classification — the system selects the most matching pattern from the available pivot structure on every bar. When the pivot structure changes (new pivots form), the pattern classification may update. This means the PATTERN row on the dashboard may change between signal events as new structure forms
[*]The Pattern Freshness filter (default: 80 bars) ensures the oldest contributing pivot is recent. On slower timeframes with infrequent pivots, this may cause pattern detection to intermittently show — before new pivots form. Increase the freshness window on higher timeframes
[*]Maximum 80 labels, 120 lines, and 600 bars back are configured. On very active low-timeframe charts, the oldest guide lines may be removed by TradingView's rendering limits
[*]The fakeout mark (orange ×) fires independently of the reversal signal. A fakeout mark can appear without a subsequent reversal signal if the RSI trap conditions (midline cross with slope) are not met — the fakeout is real but the reversal momentum confirmation is absent
[*]The indicator does not track open positions or P&L and does not connect to any broker or account
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠ [b]Disclaimer[/b]

This indicator is a technical analysis and visualization tool intended for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. All signals are generated from historical and real-time price data using mathematical calculations — their accuracy or profitability is not guaranteed. Past performance of any signal type does not guarantee future results. Always conduct your own analysis, use proper risk management, and consult a licensed financial advisor before making any trading decisions. The author accepts no responsibility for any losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[i]Built for traders who understand that a breakout is not a signal — it is the beginning of an evaluation. The signal comes after the market proves whether the break was real.[/i]

## Source Code

````pine
// © AlphaX — BREAKRUNE v1.0
// Pattern Breakout Intelligence + RSI Trigger Engine.
// Detects major structures, classifies real vs fake breakouts, then triggers only on RSI-confirmed breaks.

//@version=6
indicator("[ A L P H A X ] BREAKRUNE - Pattern Breakout RSI Engine", shorttitle="AlphaX BREAKRUNE",
  overlay=true, max_labels_count=80, max_lines_count=120, max_bars_back=600)

// ═══════════════════════════════════════════════════════════════════════════════
//  PATTERN + BREAKOUT ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
grpPat = "Pattern Intelligence"
pivLen         = input.int(5, "Pivot Length", minval=2, maxval=20, group=grpPat)
flatTolAtr     = input.float(0.35, "Flat Level Tol (xATR)", minval=0.05, maxval=1.5, step=0.05, group=grpPat)
trendTolAtr    = input.float(0.20, "Trend Shift Tol (xATR)", minval=0.05, maxval=1.5, step=0.05, group=grpPat)
minRangeAtr    = input.float(1.1, "Min Pattern Height (xATR)", minval=0.4, maxval=4.0, step=0.1, group=grpPat)
patternFresh   = input.int(80, "Pattern Freshness (bars)", minval=20, maxval=300, group=grpPat)

grpBrk = "Breakout Classifier"
breakAtr       = input.float(0.12, "Break Threshold (xATR)", minval=0.02, maxval=1.0, step=0.01, group=grpBrk)
confirmBars    = input.int(2, "True Break Confirmation Bars", minval=1, maxval=8, group=grpBrk)
fakeWindow     = input.int(5, "Fakeout Decision Window", minval=1, maxval=20, group=grpBrk)
wickRejectMin  = input.float(0.45, "Fakeout Wick Rejection Min", minval=0.1, maxval=0.9, step=0.05, group=grpBrk)
useVol         = input.bool(true, "Volume Confirm", group=grpBrk)
volLen         = input.int(20, "Volume Avg Length", minval=5, maxval=100, group=grpBrk)
volMult        = input.float(1.1, "Volume vs Avg", minval=0.8, maxval=3.0, step=0.05, group=grpBrk)

grpRsi = "RSI Trigger Layer"
rsiFastLen     = input.int(7, "RSI Fast", minval=3, maxval=30, group=grpRsi)
rsiCoreLen     = input.int(14, "RSI Core", minval=5, maxval=50, group=grpRsi)
rsiLongTrig    = input.float(55, "Long Trigger", minval=45, maxval=70, step=0.5, group=grpRsi)
rsiShortTrig   = input.float(45, "Short Trigger", minval=30, maxval=55, step=0.5, group=grpRsi)
rsiSlopeBars   = input.int(3, "RSI Slope Bars", minval=1, maxval=10, group=grpRsi)
allowTrapReversal = input.bool(true, "Enable Fakeout Reversal Signals", group=grpRsi)

grpConf = "Confluence Gate"
cooldown       = input.int(6, "Signal Cooldown (bars)", minval=1, maxval=40, group=grpConf)
minScore       = input.int(5, "Min Quality Score (of 10)", minval=3, maxval=10, group=grpConf)
useHtf         = input.bool(true, "HTF Bias Layer", group=grpConf)
requireHtf     = input.bool(false, "Hard HTF Alignment", group=grpConf)
htfTf          = input.timeframe("60", "HTF Timeframe", group=grpConf)
htfFastLen     = input.int(21, "HTF Fast EMA", minval=5, maxval=100, group=grpConf)
htfSlowLen     = input.int(55, "HTF Slow EMA", minval=10, maxval=200, group=grpConf)
useChop        = input.bool(true, "Block Extreme Chop", group=grpConf)
chopLen        = input.int(14, "Choppiness Length", minval=5, maxval=50, group=grpConf)
chopMax        = input.float(62.0, "Chop Block Above", minval=50, maxval=80, step=0.5, group=grpConf)

grpRisk = "Entry / Exit Guides"
showGuides     = input.bool(false, "Show SL + TP1 + TP2", group=grpRisk)
atrLen         = input.int(14, "ATR Length", minval=2, maxval=100, group=grpRisk)
slAtr          = input.float(1.2, "SL (xATR)", minval=0.3, maxval=5.0, step=0.1, group=grpRisk)
tp1Atr         = input.float(1.8, "TP1 (xATR)", minval=0.5, maxval=8.0, step=0.1, group=grpRisk)
tp2Atr         = input.float(3.0, "TP2 (xATR)", minval=1.0, maxval=12.0, step=0.1, group=grpRisk)
guideExtend    = input.int(30, "Guide Extend (bars)", minval=10, maxval=80, group=grpRisk)

grpVis = "Display"
showPatternLines = input.bool(true, "Show Pattern Boundary Lines", group=grpVis)
showSignals      = input.bool(true, "Show Signals", group=grpVis)
showFakeMarks    = input.bool(true, "Show Fakeout Marks", group=grpVis)
showBarTint      = input.bool(true, "Tint Candles by Active Bias", group=grpVis)
showDash         = input.bool(true, "Show Dashboard", group=grpVis)
dashPos          = input.string("Top Right", "Dashboard Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grpVis)

grpColors = "Colors (AlphaX Palette)"
colBull       = input.color(#c8e624, "Bull", group=grpColors)
colBullBr     = input.color(#d4f03a, "Bull Bright", group=grpColors)
colBear       = input.color(#ff1744, "Bear", group=grpColors)
colBearBr     = input.color(#ff5252, "Bear Bright", group=grpColors)
colLattice    = input.color(#8b6fd0, "Pattern Accent", group=grpColors)
colPending    = input.color(#ff9800, "Pending / Fakeout", group=grpColors)
colNeutral    = input.color(#555555, "Neutral", group=grpColors)
colDashBg     = input.color(#1a1a1a, "Dash BG", group=grpColors)
colDashHeader = input.color(#111111, "Dash Header", group=grpColors)
colDashSec    = input.color(#222222, "Dash Section", group=grpColors)
colDashFrame  = input.color(#c8e624, "Dash Frame", group=grpColors)
colTextLt     = input.color(#cccccc, "Dash Text", group=grpColors)
colSlLine     = input.color(#ff1744, "Stop", group=grpColors)
colTp1Line    = input.color(#9ccc65, "TP1", group=grpColors)
colTp2Line    = input.color(#c8e624, "TP2", group=grpColors)

// ═══════════════════════════════════════════════════════════════════════════════
//  STATE
// ═══════════════════════════════════════════════════════════════════════════════
type Plan
    bool valid
    bool bull
    float entry
    float sl
    float tp1
    float tp2

var Plan EMPTY_PLAN = Plan.new(false, false, na, na, na, na)
var Plan activePlan = EMPTY_PLAN

var int lastSigBar = na
var int pendingDir = 0
var float pendingLvl = na
var int pendingBar = na
var bool pendingFake = false
var bool pendingTrue = false
var string pendingPat = "—"

var line topLn = na
var line botLn = na
var line[] guideLns = array.new_line()

var string dPattern = "—"
var string dClass = "IDLE"
var string dBias = "NEUTRAL"
var int dScore = 0
var float dRes = na
var float dSup = na

f_dashPos(p) =>
    switch p
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        => position.bottom_right

f_clearGuides() =>
    int n = array.size(guideLns)
    if n > 0
        for i = 0 to n - 1
            ln = array.get(guideLns, i)
            if not na(ln)
                line.delete(ln)
        array.clear(guideLns)

f_drawGuides(Plan p) =>
    f_clearGuides()
    if p.valid and showGuides
        int x0 = bar_index
        int x1 = bar_index + guideExtend
        array.push(guideLns, line.new(x0, p.entry, x1, p.entry, color=p.bull ? colBullBr : colBearBr, style=line.style_dashed, width=1))
        array.push(guideLns, line.new(x0, p.sl, x1, p.sl, color=colSlLine, style=line.style_dashed, width=1))
        array.push(guideLns, line.new(x0, p.tp1, x1, p.tp1, color=colTp1Line, style=line.style_dotted, width=1))
        array.push(guideLns, line.new(x0, p.tp2, x1, p.tp2, color=colTp2Line, style=line.style_dashed, width=2))

f_scoreColor(bool bull, int score) =>
    if bull
        score >= 8 ? colBull : score >= 6 ? colBullBr : color.new(colBullBr, 35)
    else
        score >= 8 ? colBear : score >= 6 ? colBearBr : color.new(colBearBr, 35)

// ═══════════════════════════════════════════════════════════════════════════════
//  CORE SERIES
// ═══════════════════════════════════════════════════════════════════════════════
atr = ta.atr(atrLen)
volAvg = ta.sma(volume, volLen)
volOk = not useVol or volume >= volAvg * volMult

rsiF = ta.rsi(close, rsiFastLen)
rsiC = ta.rsi(close, rsiCoreLen)
rsiSlopeF = rsiF - rsiF[rsiSlopeBars]
rsiSlopeC = rsiC - rsiC[rsiSlopeBars]

htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
htfFast = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFastLen), barmerge.gaps_off, barmerge.lookahead_off)
htfSlow = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlowLen), barmerge.gaps_off, barmerge.lookahead_off)
htfBull = htfFast > htfSlow and htfClose > htfFast
htfBear = htfFast < htfSlow and htfClose < htfFast

ciNum = math.sum(ta.atr(1), chopLen)
ciDen = ta.highest(high, chopLen) - ta.lowest(low, chopLen)
chop = ciDen > 0 ? 100 * math.log10(ciNum / ciDen) / math.log10(chopLen) : 50.0
chopOk = not useChop or chop < chopMax

// ═══════════════════════════════════════════════════════════════════════════════
//  MAJOR PATTERN IDENTIFICATION (pivot-structure driven)
// ═══════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

lastH = ta.valuewhen(not na(ph), ph, 0)
prevH = ta.valuewhen(not na(ph), ph, 1)
lastL = ta.valuewhen(not na(pl), pl, 0)
prevL = ta.valuewhen(not na(pl), pl, 1)
lastHBar = ta.valuewhen(not na(ph), bar_index - pivLen, 0)
lastLBar = ta.valuewhen(not na(pl), bar_index - pivLen, 0)

hasCore = not na(lastH) and not na(prevH) and not na(lastL) and not na(prevL)
flatH = hasCore and math.abs(lastH - prevH) <= flatTolAtr * atr
flatL = hasCore and math.abs(lastL - prevL) <= flatTolAtr * atr
higherL = hasCore and lastL > prevL + trendTolAtr * atr
lowerH = hasCore and lastH < prevH - trendTolAtr * atr
higherH = hasCore and lastH > prevH + trendTolAtr * atr
lowerL = hasCore and lastL < prevL - trendTolAtr * atr

patternHeight = hasCore ? math.max(lastH, prevH) - math.min(lastL, prevL) : na
sizeOk = hasCore and patternHeight >= minRangeAtr * atr
freshOk = hasCore and bar_index - math.max(lastHBar, lastLBar) <= patternFresh

string pat = "NONE"
int patBias = 0
float res = na
float sup = na
if hasCore and sizeOk and freshOk
    if flatH and higherL
        pat := "ASC TRIANGLE"
        patBias := 1
        res := math.max(lastH, prevH)
        sup := math.min(lastL, prevL)
    else if flatL and lowerH
        pat := "DESC TRIANGLE"
        patBias := -1
        res := math.max(lastH, prevH)
        sup := math.min(lastL, prevL)
    else if flatH and flatL
        pat := "RANGE BOX"
        patBias := 0
        res := math.max(lastH, prevH)
        sup := math.min(lastL, prevL)
    else if higherH and higherL
        pat := "BULL CHANNEL"
        patBias := 1
        res := lastH
        sup := lastL
    else if lowerH and lowerL
        pat := "BEAR CHANNEL"
        patBias := -1
        res := lastH
        sup := lastL

// pattern lines (latest only)
if showPatternLines and barstate.islast and pat != "NONE" and not na(res) and not na(sup)
    if not na(topLn)
        line.delete(topLn)
    if not na(botLn)
        line.delete(botLn)
    topLn := line.new(bar_index - patternFresh, res, bar_index + 1, res, color=color.new(colLattice, 25), width=1, style=line.style_dashed)
    botLn := line.new(bar_index - patternFresh, sup, bar_index + 1, sup, color=color.new(colLattice, 25), width=1, style=line.style_dashed)

// ═══════════════════════════════════════════════════════════════════════════════
//  BREAKOUT CLASSIFICATION + RSI TRIGGERS
// ═══════════════════════════════════════════════════════════════════════════════
breakBuf = breakAtr * atr
longBreakRaw = pat != "NONE" and not na(res) and close > res + breakBuf and close[1] <= res + breakBuf
shortBreakRaw = pat != "NONE" and not na(sup) and close < sup - breakBuf and close[1] >= sup - breakBuf

allowLongPat = patBias >= 0
allowShortPat = patBias <= 0

if longBreakRaw and allowLongPat
    pendingDir := 1
    pendingLvl := res
    pendingBar := bar_index
    pendingFake := false
    pendingTrue := false
    pendingPat := pat
if shortBreakRaw and allowShortPat
    pendingDir := -1
    pendingLvl := sup
    pendingBar := bar_index
    pendingFake := false
    pendingTrue := false
    pendingPat := pat

int pendingAge = not na(pendingBar) ? bar_index - pendingBar : na
float body = math.max(high - low, syminfo.mintick)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low

fakeLongNow = pendingDir == 1 and not na(pendingAge) and pendingAge <= fakeWindow and close < pendingLvl and upperWick / body >= wickRejectMin
fakeShortNow = pendingDir == -1 and not na(pendingAge) and pendingAge <= fakeWindow and close > pendingLvl and lowerWick / body >= wickRejectMin
if fakeLongNow or fakeShortNow
    pendingFake := true

confLongNow = pendingDir == 1 and not na(pendingAge) and pendingAge >= confirmBars - 1 and ta.lowest(close, confirmBars) > pendingLvl and not pendingFake
confShortNow = pendingDir == -1 and not na(pendingAge) and pendingAge >= confirmBars - 1 and ta.highest(close, confirmBars) < pendingLvl and not pendingFake
if confLongNow or confShortNow
    pendingTrue := true

rsiLongOk = rsiF > rsiLongTrig and rsiC > 50 and rsiSlopeF > 0 and rsiSlopeC >= 0
rsiShortOk = rsiF < rsiShortTrig and rsiC < 50 and rsiSlopeF < 0 and rsiSlopeC <= 0
rsiTrapLong = ta.crossover(rsiF, 50) and rsiSlopeF > 0
rsiTrapShort = ta.crossunder(rsiF, 50) and rsiSlopeF < 0

f_score(bool bull, bool trap) =>
    int s = 0
    s += sizeOk ? 2 : 0
    s += (bull ? rsiLongOk : rsiShortOk) ? 2 : 0
    s += trap ? 1 : 2
    s += volOk ? 1 : 0
    s += chopOk ? 1 : 0
    s += not useHtf ? 1 : (bull ? (htfBull ? 2 : 0) : (htfBear ? 2 : 0))
    math.min(s, 10)

coolOk = na(lastSigBar) or bar_index - lastSigBar >= cooldown
htfLongOk = not requireHtf or htfBull
htfShortOk = not requireHtf or htfBear

trueBreakLong = showSignals and pendingTrue and pendingDir == 1 and rsiLongOk and coolOk and htfLongOk and chopOk
trueBreakShort = showSignals and pendingTrue and pendingDir == -1 and rsiShortOk and coolOk and htfShortOk and chopOk

trapLong = showSignals and allowTrapReversal and pendingFake and pendingDir == -1 and rsiTrapLong and coolOk and htfLongOk and chopOk
trapShort = showSignals and allowTrapReversal and pendingFake and pendingDir == 1 and rsiTrapShort and coolOk and htfShortOk and chopOk

scoreLong = f_score(true, trapLong)
scoreShort = f_score(false, trapShort)

longSignal = (trueBreakLong and scoreLong >= minScore) or (trapLong and scoreLong >= minScore)
shortSignal = (trueBreakShort and scoreShort >= minScore) or (trapShort and scoreShort >= minScore)

if longSignal or shortSignal
    lastSigBar := bar_index
    pendingDir := 0
    pendingLvl := na
    pendingBar := na
    pendingFake := false
    pendingTrue := false
    pendingPat := "—"

if not na(pendingBar) and pendingAge > fakeWindow and not pendingTrue
    pendingDir := 0
    pendingLvl := na
    pendingBar := na
    pendingFake := false
    pendingPat := "—"

// ═══════════════════════════════════════════════════════════════════════════════
//  TRADE GUIDE + DISPLAY
// ═══════════════════════════════════════════════════════════════════════════════
if longSignal
    ent = close
    sl = ent - slAtr * atr
    tp1 = ent + tp1Atr * atr
    tp2 = ent + tp2Atr * atr
    activePlan := Plan.new(true, true, ent, sl, tp1, tp2)
    f_drawGuides(activePlan)

if shortSignal
    ent = close
    sl = ent + slAtr * atr
    tp1 = ent - tp1Atr * atr
    tp2 = ent - tp2Atr * atr
    activePlan := Plan.new(true, false, ent, sl, tp1, tp2)
    f_drawGuides(activePlan)

int bias = pendingDir == 1 ? 1 : pendingDir == -1 ? -1 : patBias
color barTint = bias == 1 ? color.new(colBull, 82) : bias == -1 ? color.new(colBear, 82) : na
barcolor(showBarTint ? barTint : na)

plotshape(longSignal, title="Long Signal", style=shape.triangleup, location=location.belowbar,
  color=f_scoreColor(true, scoreLong), size=size.small)
plotshape(shortSignal, title="Short Signal", style=shape.triangledown, location=location.abovebar,
  color=f_scoreColor(false, scoreShort), size=size.small)
plotshape(showFakeMarks and fakeLongNow, title="Fake Long Breakout", style=shape.xcross, location=location.abovebar,
  color=colPending, size=size.tiny)
plotshape(showFakeMarks and fakeShortNow, title="Fake Short Breakout", style=shape.xcross, location=location.belowbar,
  color=colPending, size=size.tiny)

dPattern := pat
dClass := pendingFake ? "FAKEOUT" : pendingTrue ? "TRUE BREAK" : pendingDir != 0 ? "PENDING" : "IDLE"
dBias := bias == 1 ? "BULL" : bias == -1 ? "BEAR" : "NEUTRAL"
dScore := bias == 1 ? scoreLong : bias == -1 ? scoreShort : math.max(scoreLong, scoreShort)
dRes := res
dSup := sup

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(f_dashPos(dashPos), 2, 10,
  border_width=1, border_color=color.new(colDashFrame, 65),
  frame_width=1, frame_color=color.new(colDashFrame, 45))

if showDash and barstate.islast
    dbg = color.new(colDashBg, 0)
    sec = color.new(colDashSec, 0)
    table.cell(dash, 0, 0, "AlphaX BREAKRUNE", text_color=colBull, bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color=color.new(colBull, 30), bgcolor=color.new(colDashHeader, 0), text_halign=text.align_center)

    table.cell(dash, 0, 1, "PATTERN", text_color=colTextLt, bgcolor=dbg)
    table.cell(dash, 1, 1, dPattern, text_color=colLattice, bgcolor=dbg)

    table.cell(dash, 0, 2, "CLASS", text_color=colTextLt, bgcolor=dbg)
    table.cell(dash, 1, 2, dClass, text_color=dClass == "TRUE BREAK" ? colBull : dClass == "FAKEOUT" ? colPending : colNeutral, bgcolor=dbg)

    table.cell(dash, 0, 3, "BIAS", text_color=colTextLt, bgcolor=dbg)
    table.cell(dash, 1, 3, dBias, text_color=dBias == "BULL" ? colBull : dBias == "BEAR" ? colBear : colNeutral, bgcolor=dbg)

    table.cell(dash, 0, 4, "LEVELS", text_color=colTextLt, bgcolor=dbg)
    table.cell(dash, 1, 4, (not na(dSup) ? str.tostring(dSup, format.mintick) : "—") + " / " + (not na(dRes) ? str.tostring(dRes, format.mintick) : "—"), text_color=colTextLt, bgcolor=dbg)

    table.cell(dash, 0, 5, "QUALITY", text_color=colTextLt, bgcolor=dbg)
    table.cell(dash, 1, 5, str.tostring(dScore) + " / 10", text_color=dScore >= minScore ? colBull : colNeutral, bgcolor=dbg)

    table.cell(dash, 0, 6, "RSI F/C", text_color=colTextLt, bgcolor=sec)
    table.cell(dash, 1, 6, str.tostring(rsiF, "#.#") + " / " + str.tostring(rsiC, "#.#"), text_color=rsiF >= 50 ? colBull : colBear, bgcolor=sec)

    table.cell(dash, 0, 7, "HTF", text_color=colTextLt, bgcolor=dbg)
    table.cell(dash, 1, 7, htfBull ? "▲ BULL" : htfBear ? "▼ BEAR" : "— FLAT", text_color=htfBull ? colBull : htfBear ? colBear : colNeutral, bgcolor=dbg)

    table.cell(dash, 0, 8, "CHOP", text_color=colTextLt, bgcolor=dbg)
    table.cell(dash, 1, 8, str.tostring(chop, "#.#"), text_color=chopOk ? colTextLt : colPending, bgcolor=dbg)

    table.cell(dash, 0, 9, "VOL", text_color=colTextLt, bgcolor=dbg)
    table.cell(dash, 1, 9, volOk ? "CONFIRMED" : "LIGHT", text_color=volOk ? colBull : colPending, bgcolor=dbg)

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(longSignal, title="BREAKRUNE Long", message="[AlphaX BREAKRUNE] Long breakout signal on {{ticker}} {{interval}}")
alertcondition(shortSignal, title="BREAKRUNE Short", message="[AlphaX BREAKRUNE] Short breakout signal on {{ticker}} {{interval}}")
alertcondition(fakeLongNow or fakeShortNow, title="BREAKRUNE Fakeout", message="[AlphaX BREAKRUNE] Fake breakout detected on {{ticker}} {{interval}}")
````
