# Goldbach Zone Coach 4-PO3

- url: https://www.tradingview.com/script/pmR4rPZ8-Goldbach-Zone-Coach-4-PO3/
- type: indicator
- pine_id: PUB;81f04e4afa7c43ae9fc60f97c2d3805e
- version: 2.0

## Description

GOLDBACH ZONE COACH
4-PO3 Edition — Operator Manual
Pine Script v6 companion indicator for the Goldbach Trifecta framework
Built for MNQ futures trading
Multi-timeframe PO3 confluence with weighted conviction scoring
 
Table of Contents
Table of Contents	2
1. What This Indicator Does	4
1.1 Why four ranges	4
1.2 The four ranges	4
2. Quick Start	5
Step 1. Load the indicator	5
Step 2. Pick a session preset	5
Step 3. Read the Trifecta	5
Step 4. Enter the ranges	5
Step 5. Save and trade	5
3. Reading the Coach Table	6
3.1 Header	6
3.2 Range rows (R1–R4)	6
3.3 CONVICTION row (traffic light)	6
3.4 GUIDANCE row	6
3.5 R1 Playbook (bottom five rows)	7
4. How Conviction Scoring Works	8
4.1 Band scores	8
4.2 Weighting	8
4.3 Scoring ceiling and rating scale	8
5. Session Presets	9
5.1 When to use each preset	9
5.2 Switching presets mid-session	9
6. Alerts	10
6.1 General alerts (fire automatically when enabled)	10
6.2 Specific alertconditions (wire to different destinations)	10
6.3 Recommended alert setup	10
7. Daily Workflow	11
Before market open	11
At session open	11
During the session	11
When a range expands (price breaks [100] or [0])	11
At session transition (e.g., London → NY)	11
End of day (4:15pm for prop firms)	11
8. Zone Playbooks Reference	12
Above [100] — range expansion higher	12
[97]–[100] — premium extreme sweep	12
[89]–[97] — approach to [97]	12
[83]–[89] — inside upper order block	12
[71]–[83] — premium mitigation	12
[59]–[71] — upper eq transit	12
[50]–[59] — above equilibrium	12
[41]–[50] — below equilibrium	12
[29]–[41] — lower eq transit	12
[17]–[29] — discount mitigation	12
[11]–[17] — inside lower order block	12
[3]–[11] — approach to [3]	13
[0]–[3] — discount extreme sweep	13
Below [0] — range expansion lower	13
9. Troubleshooting & Tips	14
Table shows wrong zones	14
Conviction score seems 'off'	14
All ranges show Premium but chart looks neutral	14
Alert fires but guidance says 'wait for edge'	14
Lines and boxes clutter the chart	14
Score flips wildly during chop	14
9.1 Calibration tips	14
9.2 Known limitations	14
10. Appendix: Quick Reference Card	16
Traffic light thresholds	16
Guidance priority (highest to lowest)	16
Range weights	16
Common confluence scores to memorize	16
Session preset cheat sheet	16
Zone types quick lookup	16
Daily checklist	17

 
1. What This Indicator Does
The Goldbach Zone Coach is a companion indicator to the Goldbach Trifecta. Where the Trifecta draws the PO3 levels on your chart, the Zone Coach tells you what to do with them — which zone price is currently in, what the playbook for that zone is, and how strongly multiple timeframes agree on direction.
It tracks up to four simultaneous PO3 dealing ranges (scalp / trading / session / macro), applies a weighted conviction score, and displays everything in a compact coach table that updates in real time. The table gives you four things at a glance:
•	Where price sits in each of your four PO3 ranges
•	A traffic-light conviction verdict across all timeframes
•	A size-scaled trade recommendation (A+ / B+ / C / counter-trend / skip)
•	The specific playbook for your scalp range's current zone
1.1 Why four ranges
A single PO3 range tells you where price is within one timeframe. Four ranges tell you how that one timeframe aligns with broader structure. When your scalp range says 'long setup zone' and the trading range AND session range AND macro range all agree, that's an A+ setup. When they disagree, you're in chop and should skip.
The four ranges are weighted by how well they match your intraday trading horizon. Smaller PO3s (resolve in minutes-hours) get more weight. Larger PO3s (resolve in days) get less. This prevents macro bias from vetoing good intraday setups on prop-firm accounts that require 4:15pm exits.
1.2 The four ranges
Range	Role	Typical PO3	Weight	Resolves in
R1	Scalp / entry	27, 81, 243	4x	Minutes to 1 hour
R2	Trading	81, 243, 729	3x	1 to 4 hours
R3	Session	243, 729, 2187	2x	Same-day to overnight
R4	Macro flavor	729, 2187, 6561	1x	Multi-day structural
 
2. Quick Start
Five steps to get live in about 90 seconds per session.
Step 1. Load the indicator
Paste the Pine Script into TradingView's Pine Editor and click Add to Chart.
Step 2. Pick a session preset
At the top of the settings you'll find a Session Preset dropdown. Pick the one that matches what you're trading right now:
•	Asia (27/81/243) — quiet overnight session
•	London (81/243/729) — active European session
•	NY AM (81/243/729/2187) — all four ranges, full NY morning
•	NY PM (81/243) — scalp-only for the wind-down
•	Scalp only (27/81) — very tight scalping mode
•	Swing (243/729/2187) — position-style trading
•	Custom — manual control of everything
Step 3. Read the Trifecta
Look at your Goldbach Trifecta indicator on the chart. For each enabled range, find the [0] low price and the [100] high price of the active PO3 range.
Step 4. Enter the ranges
Fill in the R1 low, R1 high, R2 low, R2 high, etc. for each enabled range. The indicator handles everything from there.
Step 5. Save and trade
The coach table appears in your chosen corner. When the session shifts or the Trifecta redraws a PO3, change the preset and update the values. Roughly 60 seconds of input per session transition.
 
3. Reading the Coach Table
The table has four sections, each answering a different question.
3.1 Header
Shows the active preset name (e.g., 'GOLDBACH · London (81/243/729)') and column labels: Band, %, Score. In Custom mode the header just says 'GOLDBACH COACH'.
3.2 Range rows (R1–R4)
One row per range. Each row shows four pieces of information:
•	Left cell (colored accent): Range name, PO3 size, and weight. Color indicates current bias — red for premium, green for discount, blue for neutral, orange for extreme sweep.
•	Band: Which pair of Goldbach levels price is currently between, plus the zone type (e.g., '[83]–[89] upper OB').
•	%: Exact position within the range as a percentage. 0% = [0] low, 50% = [50] equilibrium, 100% = [100] high. Values above 100 or below 0 indicate range expansion.
•	Score: This range's weighted contribution to the overall conviction. Positive = premium/short contribution, negative = discount/long contribution.
3.3 CONVICTION row (traffic light)
The headline verdict combining all four ranges. Three possible states:
Light	Score Range	Meaning
GREEN	≥ ±10	Strong directional alignment across ranges. Take the setup full size if R1 zone supports it.
YELLOW	±5 to ±9	Moderate directional lean. Some ranges agree, others don't. Proceed with reduced size or wait for a better setup.
RED	-4 to +4	No edge, genuine chop. Skip unless R1 setup is textbook A+ quality and you're scalping small.

The number in parentheses is the raw weighted score. See section 4 for how it's calculated.
3.4 GUIDANCE row
Synthesizes the R1 zone with the conviction score into a specific sizing recommendation. The combinations produce nine possible guidance tiers:
R1 Zone	Score	Guidance
Long setup	≤ -10	A+ LONG — full size, textbook entry
Long setup	-5 to -9	B+ LONG — normal size
Long setup	-4 to +4	C LONG — half size, tight stops
Long setup	+5 to +9	⚠ COUNTER-TREND LONG — HTF leans short, your call
Long setup	≥ +10	⚠⚠ AGAINST STRONG HTF — scalp only or skip
Short setup	≥ +10	A+ SHORT — full size, textbook entry
Short setup	+5 to +9	B+ SHORT — normal size
Short setup	-4 to +4	C SHORT — half size, tight stops
Short setup	-5 to -9	⚠ COUNTER-TREND SHORT — HTF leans long, your call
Short setup	≤ -10	⚠⚠ AGAINST STRONG HTF — scalp only or skip
Neutral	any	R1 in neutral zone — wait for edge

Long setup zones are [0]–[29] (discount territory). Short setup zones are [71]–[100] (premium territory). The middle range [29]–[71] is equilibrium transit where fresh entries are low probability.
3.5 R1 Playbook (bottom five rows)
When verbose mode is on, the bottom of the table shows the zone-specific playbook for R1's current band. Five rows:
•	Zone: The full name of R1's current band.
•	Read: What this zone means — is it a decision level, a transit zone, a rejection block?
•	Reject: The setup if price rejects this zone upward — what to target, what size makes sense.
•	Break: The setup if price breaks through this zone downward — what to target.
•	Watch: Specific confirmation signals to look for — wick rejections, displacement candles, test counts.
 
4. How Conviction Scoring Works
4.1 Band scores
Each band gets a signed score based on how far from equilibrium [50] it sits. Positive scores push toward short bias, negative toward long bias.
Band	Score	Bias
above [100] / [97]–[100]	+3	Extreme premium
[83]–[97]	+2	Premium
[71]–[83]	+1	Upper mitigation
[29]–[71]	0	Equilibrium (neutral)
[17]–[29]	-1	Lower mitigation
[3]–[17]	-2	Discount
[0]–[3] / below [0]	-3	Extreme discount
4.2 Weighting
Each range's raw band score is multiplied by its weight before summing. Smaller PO3s get more weight because they resolve within the intraday trading window.
conviction = (R1_score × 4) + (R2_score × 3) + (R3_score × 2) + (R4_score × 1)

This weighting prevents the macro timeframe (R4) from vetoing otherwise-good intraday setups. A maxed-out R4 can only push the score by ±3, while R1 alone can push it by ±12. Macro matters as flavor, not mandate.
4.3 Scoring ceiling and rating scale
Maximum positive: 12 + 9 + 6 + 3 = +30. Maximum negative: -30. Practical range: ±30.
Score	Tier	Mental interpretation
±10 to ±13	Strong	Just crossed into green. Directional bias confirmed. Take the trade if R1 supports.
±14 to ±19	High	Solid multi-range alignment. High-conviction setups. Lean into size.
±20 to ±26	Very high	Rare territory. Multiple ranges at extreme together. A+ setups when R1 aligns.
±27 to ±30	Ceiling	Theoretical maximum. All four ranges at extreme same direction. Very rare.
 
5. Session Presets
Presets change which ranges are enabled and what PO3 size each defaults to. They don't set the [0] and [100] values — you still enter those manually from the Trifecta.
5.1 When to use each preset
Preset	Ranges	Use when
Asia	27 / 81 / 243	6 PM – 3 AM ET. Quiet session, small ranges. Scalping or position-holding through the overnight.
London	81 / 243 / 729	2 AM – 5 AM ET open, running to ~7 AM. Active European session. Good for catching London open sweeps.
NY AM	81 / 243 / 729 / 2187	7 AM – 11 AM ET. Full fractal coverage. The highest-volume session and where macro context matters most.
NY PM	81 / 243	1 PM – 4 PM ET. Slower afternoon session. Scalp-focused, less macro relevance before the close.
Scalp only	27 / 81	Any time you're in pure scalping mode with small targets. Tight confluence on the two smallest PO3s.
Swing	243 / 729 / 2187	Multi-day position-style trading. Less useful for 4:15pm prop firm exits but good for analysis.
Custom	manual	Override preset defaults. Use when you want specific PO3 sizes that don't match any preset.
5.2 Switching presets mid-session
You can change presets anytime. The range enables and size labels update instantly. You'll need to update the [0] and [100] values to match whatever the Trifecta is showing for the new PO3 sizes — the preset can't read those from the Trifecta automatically.
 
6. Alerts
Two general alerts and seven specific alertconditions for granular routing.
6.1 General alerts (fire automatically when enabled)
•	R1 band entry: Fires whenever price transitions into a new band on R1. Message includes the full playbook. Toggle 'key bands only' to filter to just the high-conviction zones (extremes and approaches).
•	Conviction green: Fires when the traffic light transitions from yellow or red to green. Message includes the direction and the R1 guidance.
6.2 Specific alertconditions (wire to different destinations)
Create alerts manually in TradingView and pick one of these pre-built conditions:
•	R1: [97]-[100] premium extreme (high-conviction short zone)
•	R1: [0]-[3] discount extreme (high-conviction long zone)
•	R1: approaching [97] (premium rejection block approach)
•	R1: approaching [3] (discount rejection block approach)
•	R1: range expansion (price broke above [100] or below [0])
•	Conviction GREEN short (weighted score turned green positive)
•	Conviction GREEN long (weighted score turned green negative)
6.3 Recommended alert setup
For daily trading, three alerts cover most scenarios:
•	Sound/push notification on 'Conviction GREEN short' and 'Conviction GREEN long' — your A+ setup triggers
•	Popup on 'R1 approaching [97]' and 'R1 approaching [3]' — lets you watch the test develop
•	Email on 'R1 range expansion' — reminder to update your [0] and [100] inputs
 
7. Daily Workflow
A typical day using the indicator, end to end.
Before market open
•	Pull up the Goldbach Trifecta on your main chart
•	Identify the active PO3 ranges for the session you're about to trade
•	Note down the [0] and [100] prices for each range you'll track
At session open
•	Select the matching preset in the Zone Coach settings
•	Enter the [0] and [100] values for each enabled range
•	Confirm the table appears correctly and shows your current bias
During the session
•	Let alerts drive your attention, not random chart-watching
•	When a green conviction alert fires, verify R1 zone supports the direction (check guidance row)
•	If guidance reads A+ or B+, prepare your Sniper Slingshot wick rejection entry
•	If guidance reads C, consider reduced size or wait
•	If guidance reads counter-trend, pass or scalp only
When a range expands (price breaks [100] or [0])
•	The indicator will show 'EXPANSION' in the zone label
•	Don't fade the move — let the new PO3 form
•	When the new range is clear on the Trifecta, update your [0] and [100] inputs
At session transition (e.g., London → NY)
•	Change the preset dropdown
•	Update [0] and [100] values for the new PO3 sizes
•	Table recalculates everything automatically
End of day (4:15pm for prop firms)
•	Close all positions before the cutoff
•	Screenshot your table state for journaling
•	Note which guidance tiers were accurate today — feeds calibration
 
8. Zone Playbooks Reference
All 14 possible R1 zones and their complete playbooks. This is what the indicator shows in the verbose section of the coach table.
Above [100] — range expansion higher
PO3 is being redrawn. Do NOT fade. Wait for new range to form, then longs on pullback to old [97]. Watch for: new swing high, consolidation, new anchor candle.
[97]–[100] — premium extreme sweep
Past [97] into final 3%. Liquidity sweep — algos take stops then reverse. Highest-conviction short zone. Targets: [83] → [71] → [50]. Watch for: wick rejection back below [97], bearish displacement, volume spike without follow-through.
[89]–[97] — approach to [97]
Final push into premium rejection zone. If stall + reject before [97]: short to [83] → [71] with smaller size. If break: push to [97] likely, prepare short thesis. Watch for: clean punch-through versus tag-and-reject.
[83]–[89] — inside upper order block
Decision level. Trending days rip through to [97]; balanced days reverse here. Short target [71] → [50]. Watch for: first tag (continues) versus third-plus retest (reverses).
[71]–[83] — premium mitigation
Pullback on moves down from [97], continuation up from [50]. Approach direction matters. From above: short to [50]. From below: [71] holds as support, long to [83]/[97]. Watch for: [71] as resistance (bearish) versus support (bullish).
[59]–[71] — upper eq transit
No-man's-land. Transit, not reaction. Skip fresh entries. Use for bias context only. If forced: shorts to [50], longs to [71].
[50]–[59] — above equilibrium
Bulls defending [50] as support. Dictates day bias. Bounce off [50] long to [71] is mid-conviction if [50] has held prior tests. Loss of [50] flips regime to discount. Watch test count: 1–2 usually hold, 3+ break.
[41]–[50] — below equilibrium
Bears defending [50] as resistance. Reject at [50] from below short to [29] is mid-conviction. Reclaim of [50] flips regime to premium. Watch for: wick rejection below [50] is clean, body close above flips bullish.
[29]–[41] — lower eq transit
Transit zone. Skip fresh entries. Note direction and speed through the band.
[17]–[29] — discount mitigation
Pullback on moves up from [3], continuation down from [50]. From below: long to [50]. From above: [29] as resistance, short to [17]/[3]. Watch for: [29] as support (bullish) versus resistance (bearish).
[11]–[17] — inside lower order block
Decision level. Balanced days reverse, trending-down days rip to [3]. Long to [29] → [50]. Watch for: first tag continues, third-plus retest bounces.
[3]–[11] — approach to [3]
Final stretch toward discount rejection zone. If stall + bounce before [3]: long to [17] → [29] with smaller size. If break: push to [3] likely, prepare long thesis. Watch for: clean punch-through versus tag-and-reverse.
[0]–[3] — discount extreme sweep
Past [3] into final 3%. Liquidity sweep — algos take stops then reverse. Highest-conviction long zone. Targets: [17] → [29] → [50]. Watch for: wick rejection back above [3], bullish displacement, volume spike with absorption.
Below [0] — range expansion lower
PO3 being redrawn lower. Do NOT catch knife. Wait for new range, then shorts on pullback to old [3]. Watch for: new swing low, consolidation, new anchor candle.
 
9. Troubleshooting & Tips
Table shows wrong zones
The [0] and [100] values are probably stale. Check the Trifecta to see if the PO3 has rolled over to a new range. Update the inputs.
Conviction score seems 'off'
Three common causes. First: a range is enabled but its [0]/[100] values are from a different PO3 size than labeled. Second: you're in a Custom preset and one of the ranges is enabled with values you forgot to update. Third: R4 is pulling the score slightly — this is intentional and usually minor.
All ranges show Premium but chart looks neutral
Price might be hovering near [50] on R1 but deeper in premium on the larger ranges. The table is reporting accurately — the larger timeframes haven't rotated back down yet. This is a yellow-light situation, not a red flag.
Alert fires but guidance says 'wait for edge'
Conviction went green but R1 is still in a neutral zone ([29]–[71]). The bigger ranges are positioned for a move but R1 hasn't reached its setup zone yet. Wait for R1 to push into premium or discount territory before entering.
Lines and boxes clutter the chart
Turn off level lines and band highlights for R2/R3/R4. Keep only R1 lines visible for your actual trading range. The coach table communicates the other ranges' state without needing visual overlay.
Score flips wildly during chop
Normal during tight chop near equilibrium zones. If it's bothering you, watch the guidance row instead of the raw score — it's more stable because it requires R1 to be in a setup zone before flipping.
9.1 Calibration tips
•	Screenshot the table each day when you enter a trade. After 2 weeks, review: which guidance tiers actually produced winners? Adjust your personal size-per-tier based on data, not theory.
•	Track A+ setups separately. These are the rare high-conviction moments. If your A+ win rate is 70%+ after 20+ trades, you've validated the framework for your style.
•	If counter-trend alerts keep hitting you, consider blocking those trades entirely rather than 'using your call.' The warning exists for a reason.
•	During news events, the PO3 ranges often expand rapidly. Disable the indicator's alerts 15 minutes before major releases to avoid false signals.
9.2 Known limitations
•	Requires manual [0]/[100] inputs — cannot auto-read the Trifecta's values. Plan ~60 seconds of input per session transition.
•	Cannot perfectly match the Trifecta's proprietary anchor logic. Values you enter should come directly from the Trifecta's displayed labels.
•	Range expansion detection is reactive — by the time 'EXPANSION' shows, price has already broken out. This is a range update signal, not an entry signal.
•	Historical backtesting is impractical due to manual inputs. The indicator is designed for live trading, not replay analysis.
 
10. Appendix: Quick Reference Card
The one-page cheat sheet. Print this and keep it next to your trading screen.
Traffic light thresholds
GREEN:  score ≥ ±10   →   Strong alignment, take full size
YELLOW: score ±5 to ±9  →   Moderate lean, reduced size
RED:    score -4 to +4  →   No edge, skip

Guidance priority (highest to lowest)
A+  →  R1 in setup zone + score ≥ ±10    →   Full size
B+  →  R1 in setup zone + score ±5 to ±9  →   Normal size
C   →  R1 in setup zone + score neutral   →   Half size
⚠   →  R1 setup opposes HTF score ±5-9    →   Your call
⚠⚠  →  R1 setup opposes HTF score ±10+    →   Skip

Range weights
R1 × 4 = scalp/entry range (highest weight)
R2 × 3 = trading range
R3 × 2 = session context
R4 × 1 = macro flavor (lowest weight)

Common confluence scores to memorize
R1 at [97] alone        = +12  (green short by itself)
R1 + R2 both premium    = +14  (solid green)
All 4 ranges moderate   = +10  (green threshold)
R1 extreme + R3 mild opp = +9   (yellow, not green)

Session preset cheat sheet
Asia (overnight):    27 / 81 / 243
London (morning):    81 / 243 / 729
NY AM (peak):        81 / 243 / 729 / 2187
NY PM (afternoon):   81 / 243
Scalp only:          27 / 81
Swing (multi-day):   243 / 729 / 2187

Zone types quick lookup
Long setup zones (take longs here):  [0]-[29]
Short setup zones (take shorts here): [71]-[100]
Neutral transit (skip entries):       [29]-[71]
Range expansion (update inputs):      above [100] / below [0]

Daily checklist
•	Read Trifecta [0] and [100] for active PO3s
•	Select session preset in Zone Coach
•	Enter [0]/[100] values for enabled ranges
•	Verify table shows current bias correctly
•	Set alerts for green conviction and key zones
•	Update inputs when preset changes or PO3 expands
•	Screenshot entries for post-session review
•	Close all positions before 4:15 PM ET cutoff
— End of Manual —

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════
//  GOLDBACH MTF SUMMARY
//  Four base-0 PO3 dealing ranges, read as one state.
//
//  Does NOT redraw the Goldbach levels — run Trifecta for those.
//  This adds the two things Trifecta can't show you:
//    1. all four ranges' array state at a glance
//    2. cross-range confluence levels (where 2+ ranges land on the same
//       price), the only high-conviction levels in a nested base-0 grid
//
//  Anchoring is fixed base-0:  low = floor(price / PO3) * PO3
//  Verified against Trifecta on MNQ for PO3 2187 / 729 / 243 / 81.
//
//  ARRAY = the book's PD array (Fundamentals p.26-27): a zone runs from
//  the previous Goldbach level up to the named one, mirrored about 50,
//  with no gaps.
//  ZONE  = the layer that array belongs to, in Trifecta's wording:
//    DISCOUNT / PREMIUM LIQUIDITY LAYER   0-17  / 83-100
//        Rejection, Order Block, FVG
//    DISCOUNT / PREMIUM FLOW LAYER        17-41 / 59-83
//        Liquidity Void, Breaker
//    DISCOUNT / PREMIUM REBALANCE LAYER   41-50 / 50-59
//        Mitigation, Equilibrium
// ═══════════════════════════════════════════════════════════════════════
indicator("Goldbach MTF Summary", "GB MTF", overlay = true, max_lines_count = 60, max_labels_count = 60)

// ─── INPUTS ────────────────────────────────────────────────────────────
gS = "PO3 STACK   (highest → lowest)"
i1 = input.int(2187, "", group = gS, inline = "a")
i2 = input.int(729,  "", group = gS, inline = "a")
i3 = input.int(243,  "", group = gS, inline = "a")
i4 = input.int(81,   "", group = gS, inline = "a")
dec = input.float(1.0, "Decimate", group = gS, tooltip = "PO3 is quoted in pips for FX, points for indices. EURUSD 243 pips → 10000. MNQ/NQ → 1.")

gC = "CONFLUENCE"
showL  = input.bool(true, "Draw confluence levels", group = gC)
minW   = input.int(2, "Min agreeing ranges", minval = 2, maxval = 4, group = gC)
rankIn = input.int(2, "Must involve top N ranges", minval = 1, maxval = 4, group = gC, tooltip = "81↔243 pairs occur every few points and crowd out the levels that matter. 2 = the confluence must include PO3 #1 or #2.")
tolTk  = input.int(8, "Cluster tolerance (ticks)", minval = 0, group = gC, tooltip = "Exact confluences have zero spread. Raise this to also catch near-misses — those are where PO3 liquidity forms.")
winPct = input.float(1.0, "Draw window  ± % of price", minval = 0.1, group = gC)
nBars  = input.int(250, "Line length (bars)", minval = 10, group = gC)

gR = "SETUP READER"
rejBars = input.int(20, "Rejection lookback (bars)", minval = 2, group = gR, tooltip = "A range counts as REJECTED when price tagged its 3/97 zone within this many bars and has since closed back through 11/89.")

gT = "TABLE"
posIn = input.string("Top right", "Position", options = ["Top right", "Middle right", "Bottom right", "Top left", "Bottom left"], group = gT)
sizIn = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = gT)
dark  = input.bool(true, "Dark theme", group = gT)

// ─── PALETTE ───────────────────────────────────────────────────────────
cLIQ  = #26a69a
cFLOW = #2962ff
cREB  = #ef5350
cHOT  = #ffb300
cTXT  = dark ? color.new(#d1d4dc, 0) : color.new(#131722, 0)
cDIM  = color.new(#787b86, 0)
cBG   = dark ? color.new(#131722, 12) : color.new(#ffffff, 8)
cHDR  = dark ? color.new(#1e222d, 0)  : color.new(#f0f3fa, 0)

// ─── HELPERS ───────────────────────────────────────────────────────────
// Book PD arrays, gapless, mirrored about 50.
f_array(float p) =>
    p <  3 ? "Rejection"     : p < 11 ? "Order Block" : p < 17 ? "FVG"         :
      p < 29 ? "Liq Void"    : p < 41 ? "Breaker"     : p < 47 ? "Mitigation"  :
      p < 53 ? "Equilibrium" : p < 59 ? "Mitigation"  : p < 71 ? "Breaker"     :
      p < 83 ? "Liq Void"    : p < 89 ? "FVG"         : p < 97 ? "Order Block" : "Rejection"

// Family the array belongs to.
f_fam(float p) =>
    p < 17 ? "LIQUIDITY" : p < 41 ? "FLOW" : p < 59 ? "REBALANCE" : p < 83 ? "FLOW" : "LIQUIDITY"

f_fcol(string f) =>
    f == "LIQUIDITY" ? cLIQ : f == "FLOW" ? cFLOW : cREB

// Layer name, Trifecta's wording, applied to the gapless family partition.
f_zone(float p) =>
    (p > 50 ? "PREMIUM " : "DISCOUNT ") + f_fam(p) + " LAYER"

f_pos() =>
    posIn == "Top right"    ? position.top_right    :
      posIn == "Middle right" ? position.middle_right :
      posIn == "Bottom right" ? position.bottom_right :
      posIn == "Top left"     ? position.top_left     : position.bottom_left

f_siz() =>
    sizIn == "Tiny" ? size.tiny : sizIn == "Small" ? size.small : sizIn == "Normal" ? size.normal : size.large

f_rejHi(float l, float s, float hN, float c) => hN >= l + 0.97 * s and c < l + 0.89 * s
f_rejLo(float l, float s, float lN, float c) => lN <= l + 0.03 * s and c > l + 0.11 * s

f_p(float x) => str.tostring(x, format.mintick)
// Explicit sign. A leading plus inside a Pine number-format pattern is treated
// as a literal prefix, so negatives render ambiguously. Build the sign by hand.
f_d(float d) => (d >= 0 ? "+" : "-") + str.tostring(math.abs(d), "#.0")
f_r(float x, float s) => s >= 27 ? str.tostring(math.round(x)) : str.tostring(x, format.mintick)

// ─── STATE ─────────────────────────────────────────────────────────────
var array<int>   GB  = array.from(0, 3, 11, 17, 23, 29, 35, 41, 47, 50, 53, 59, 65, 71, 77, 83, 89, 97, 100)
var table        TBL = table.new(position.top_right, 6, 11, border_width = 1)
float hiN = ta.highest(high, rejBars)
float loN = ta.lowest(low, rejBars)

var array<line>  LN  = array.new<line>()
var array<label> LB  = array.new<label>()

if barstate.islast
    float tol = tolTk * syminfo.mintick
    float px  = close

    // ── the four ranges ────────────────────────────────────────────────
    array<float> raw = array.from(i1 * 1.0, i2 * 1.0, i3 * 1.0, i4 * 1.0)
    array<float> sz  = array.new<float>()
    array<float> lo  = array.new<float>()
    array<float> pc  = array.new<float>()
    for k = 0 to 3
        float s = math.max(raw.get(k), 1.0) / dec
        float l = math.floor(px / s) * s
        sz.push(s)
        lo.push(l)
        pc.push((px - l) / s * 100.0)

    // ── every level from every range ───────────────────────────────────
    array<float> lp = array.new<float>()
    array<int>   lg = array.new<int>()
    array<int>   lk = array.new<int>()
    for k = 0 to 3
        for j = 0 to GB.size() - 1
            lp.push(lo.get(k) + GB.get(j) / 100.0 * sz.get(k))
            lg.push(GB.get(j))
            lk.push(k)

    // ── cluster across ranges (one member per PO3 max) ─────────────────
    int n = lp.size()
    array<bool>   used = array.new<bool>(n, false)
    array<float>  cp   = array.new<float>()
    array<int>    cw   = array.new<int>()
    array<string> cs   = array.new<string>()
    array<float>  csp  = array.new<float>()
    array<int>    ct   = array.new<int>()

    for a = 0 to n - 1
        if not used.get(a)
            used.set(a, true)
            array<bool> seen = array.new<bool>(4, false)
            seen.set(lk.get(a), true)
            float pMin = lp.get(a)
            float pMax = lp.get(a)
            float rep  = lp.get(a)
            float repP = raw.get(lk.get(a))
            string s   = str.tostring(math.round(raw.get(lk.get(a)))) + "·" + str.tostring(lg.get(a))
            int w      = 1
            int top    = lk.get(a)
            if a < n - 1
                for b = a + 1 to n - 1
                    if not used.get(b) and not seen.get(lk.get(b)) and math.abs(lp.get(b) - lp.get(a)) <= tol
                        used.set(b, true)
                        seen.set(lk.get(b), true)
                        w += 1
                        pMin := math.min(pMin, lp.get(b))
                        pMax := math.max(pMax, lp.get(b))
                        s := s + "  " + str.tostring(math.round(raw.get(lk.get(b)))) + "·" + str.tostring(lg.get(b))
                        top := lk.get(b) < top ? lk.get(b) : top
                        if raw.get(lk.get(b)) > repP
                            repP := raw.get(lk.get(b))
                            rep  := lp.get(b)
            cp.push(rep)
            cw.push(w)
            cs.push(s)
            csp.push(pMax - pMin)
            ct.push(top)

    // ── nearest confluence above / below ───────────────────────────────
    float upP  = na
    float dnP  = na
    int   upW  = 0
    int   dnW  = 0
    string upS = ""
    string dnS = ""
    float upSp = 0.0
    float dnSp = 0.0
    for a = 0 to cp.size() - 1
        if cw.get(a) >= minW and ct.get(a) < rankIn
            float p = cp.get(a)
            if p > px and (na(upP) or p < upP)
                upP  := p
                upW  := cw.get(a)
                upS  := cs.get(a)
                upSp := csp.get(a)
            if p <= px and (na(dnP) or p > dnP)
                dnP  := p
                dnW  := cw.get(a)
                dnS  := cs.get(a)
                dnSp := csp.get(a)

    // ── draw ───────────────────────────────────────────────────────────
    for l in LN
        line.delete(l)
    LN.clear()
    for b in LB
        label.delete(b)
    LB.clear()

    if showL
        float win = px * winPct / 100.0
        for a = 0 to cp.size() - 1
            if cw.get(a) >= minW and ct.get(a) < rankIn and math.abs(cp.get(a) - px) <= win
                color col = cw.get(a) >= 3 ? cHOT : cDIM
                LN.push(line.new(bar_index - nBars, cp.get(a), bar_index + 12, cp.get(a), color = col, width = cw.get(a) >= 3 ? 2 : 1))
                LB.push(label.new(bar_index + 12, cp.get(a), "×" + str.tostring(cw.get(a)) + (csp.get(a) <= syminfo.mintick ? " = " : " ~ ") + cs.get(a), style = label.style_label_left, color = color.new(col, 88), textcolor = cTXT, size = size.tiny))

    // ── setup reader ───────────────────────────────────────────────────
    string f0 = f_fam(pc.get(0))
    string f1 = f_fam(pc.get(1))
    string f3 = f_fam(pc.get(3))
    bool   p0 = pc.get(0) > 50
    bool   p1 = pc.get(1) > 50
    bool   p3 = pc.get(3) > 50

    // how many ranges, counting down from the largest, agree price is at an extreme
    int  depth = 0
    bool halt  = false
    for k = 0 to 3
        if not halt
            if f_fam(pc.get(k)) == "LIQUIDITY"
                depth += 1
            else
                halt := true

    // rejection-block confirmation per range: tagged 3/97, closed back through 11/89
    array<bool> rHi = array.new<bool>()
    array<bool> rLo = array.new<bool>()
    for k = 0 to 3
        rHi.push(f_rejHi(lo.get(k), sz.get(k), hiN, px))
        rLo.push(f_rejLo(lo.get(k), sz.get(k), loN, px))

    int  hIdx  = f0 == "REBALANCE" ? 0 : f1 == "REBALANCE" ? 1 : -1
    bool hSide = hIdx == 0 ? p0 : p1

    string sName  = "NO SETUP"
    string sRate  = ""
    string sInfo  = ""
    string sRead  = "no multi-range agreement"
    string sWatch = "—"
    color  sCol   = cDIM

    if depth >= 3
        int  dK   = depth - 1
        bool side = p0
        bool rej  = side ? rHi.get(dK) : rLo.get(dK)
        sName  := "STACKED EXTREME ×" + str.tostring(depth)
        sRate  := depth >= 4 ? "1.3%" : "2.5%"
        sCol   := cLIQ
        sInfo  := str.tostring(depth) + " ranges at the " + (side ? "premium" : "discount") + " extreme"
        sRead  := "reversal zone — Algo 1 starts at 0/100; expect a PO3 stop run"
        sWatch := rej ? "REJECTED on " + str.tostring(math.round(raw.get(dK))) + " — trigger live" : "wait: tag " + (side ? "97/100" : "0/3") + " then close back through " + (side ? "89" : "11")
    else if hIdx >= 0 and f3 == "LIQUIDITY" and hSide == p3
        bool rej = p3 ? rHi.get(3) : rLo.get(3)
        sName  := "TRACEBACK"
        sRate  := "5.8%"
        sCol   := cREB
        sInfo  := str.tostring(math.round(raw.get(hIdx))) + " rebalance " + (hSide ? "P" : "D") + " · 81 at " + (p3 ? "premium" : "discount") + " extreme"
        sRead  := "HTF stalling at EQ where algos fail; 81 at a reversal array"
        sWatch := rej ? "81 REJECTED — traceback toward " + str.tostring(math.round(raw.get(hIdx))) + " EQ live" : "wait for 81 to close back through " + (p3 ? "89" : "11")
    else if depth == 2
        sName  := "ARMED — NO TRIGGER"
        sRate  := "7.5%"
        sCol   := cFLOW
        sInfo  := "2187 + 729 at the " + (p0 ? "premium" : "discount") + " extreme · 243 in " + f_array(pc.get(2))
        sRead  := "top two ranges agree on the extreme; lower two have not confirmed"
        sWatch := "wait for 243 then 81 to reach the same " + (p0 ? "premium" : "discount") + " extreme"
    else if (pc.get(3) <= 3 or pc.get(3) >= 97) and f0 != "LIQUIDITY"
        sName  := "RANGE EXPANSION WATCH"
        sRate  := "3.3%"
        sCol   := cHOT
        sInfo  := "81 pinned at its " + (p3 ? "high" : "low") + ", " + str.tostring(math.round(raw.get(0))) + " mid-range"
        sRead  := "small range being abandoned — read from the next PO3 up"
        sWatch := "expect a PO3 stop run into the adjacent 81 partition"
    else if f0 == "FLOW" and f3 == "FLOW" and p0 == p3
        sName  := "EXPANSION REGIME"
        sRate  := "10.6%"
        sCol   := cFLOW
        sInfo  := "2187 and 81 both in flow, " + (p0 ? "premium" : "discount")
        sRead  := "12% void/breaker blocks — one-directional regime, do not fade"
        sWatch := "join on a retrace into the non-GB level (23/35 or 65/77)"

    // ── table ──────────────────────────────────────────────────────────
    string ts = f_siz()
    table.set_position(TBL, f_pos())
    table.set_bgcolor(TBL, cBG)
    table.clear(TBL, 0, 0, 5, 10)

    table.cell(TBL, 0, 0, "GOLDBACH MTF  " + syminfo.ticker, text_color = cTXT, text_size = ts, bgcolor = cHDR, text_halign = text.align_left)
    table.cell(TBL, 1, 0, "", bgcolor = cHDR)
    table.cell(TBL, 2, 0, "", bgcolor = cHDR)
    table.cell(TBL, 3, 0, "", bgcolor = cHDR)
    table.cell(TBL, 4, 0, "", bgcolor = cHDR)
    table.cell(TBL, 5, 0, f_p(px), text_color = cTXT, text_size = ts, bgcolor = cHDR, text_halign = text.align_right)

    table.cell(TBL, 0, 1, "PO3",   text_color = cDIM, text_size = ts)
    table.cell(TBL, 1, 1, "RANGE", text_color = cDIM, text_size = ts)
    table.cell(TBL, 2, 1, "%",     text_color = cDIM, text_size = ts, text_halign = text.align_right)
    table.cell(TBL, 3, 1, "ARRAY", text_color = cDIM, text_size = ts)
    table.cell(TBL, 4, 1, "▼ / ▲", text_color = cDIM, text_size = ts, text_halign = text.align_right)
    table.cell(TBL, 5, 1, "ZONE",  text_color = cDIM, text_size = ts)

    for k = 0 to 3
        int  gLo = 0
        int  gHi = 100
        bool fnd = false
        for j = 0 to GB.size() - 1
            float v = lo.get(k) + GB.get(j) / 100.0 * sz.get(k)
            if v <= px
                gLo := GB.get(j)
            else if not fnd
                gHi := GB.get(j)
                fnd := true

        int rw = k + 2
        table.cell(TBL, 0, rw, str.tostring(math.round(raw.get(k))), text_color = cTXT, text_size = ts)
        table.cell(TBL, 1, rw, f_r(lo.get(k), sz.get(k)) + "–" + f_r(lo.get(k) + sz.get(k), sz.get(k)), text_color = cTXT, text_size = ts)
        table.cell(TBL, 2, rw, str.tostring(pc.get(k), "#.0"), text_color = cTXT, text_size = ts, text_halign = text.align_right)
        table.cell(TBL, 3, rw, f_array(pc.get(k)), text_color = cTXT, text_size = ts)
        table.cell(TBL, 4, rw, str.tostring(gLo) + " / " + str.tostring(gHi), text_color = cTXT, text_size = ts, text_halign = text.align_right)
        table.cell(TBL, 5, rw, f_zone(pc.get(k)), text_color = f_fcol(f_fam(pc.get(k))), text_size = ts)

    table.cell(TBL, 0, 6, "SETUP", text_color = cDIM, text_size = ts)
    table.cell(TBL, 1, 6, sName, text_color = sCol, text_size = ts)
    table.cell(TBL, 2, 6, sRate, text_color = cDIM, text_size = ts, text_halign = text.align_right, tooltip = "How often this configuration occurs by geometry alone. A base rate, not a win rate.")
    table.cell(TBL, 3, 6, "", text_size = ts)
    table.cell(TBL, 4, 6, "", text_size = ts)
    table.cell(TBL, 5, 6, sInfo, text_color = cTXT, text_size = ts)

    table.cell(TBL, 0, 7, "READ", text_color = cDIM, text_size = ts)
    table.cell(TBL, 1, 7, "", text_size = ts)
    table.cell(TBL, 2, 7, "", text_size = ts)
    table.cell(TBL, 3, 7, "", text_size = ts)
    table.cell(TBL, 4, 7, "", text_size = ts)
    table.cell(TBL, 5, 7, sRead, text_color = cTXT, text_size = ts)

    table.cell(TBL, 0, 8, "WATCH", text_color = cDIM, text_size = ts)
    table.cell(TBL, 1, 8, "", text_size = ts)
    table.cell(TBL, 2, 8, "", text_size = ts)
    table.cell(TBL, 3, 8, "", text_size = ts)
    table.cell(TBL, 4, 8, "", text_size = ts)
    table.cell(TBL, 5, 8, sWatch, text_color = sCol, text_size = ts)

    table.cell(TBL, 0, 9, "▲", text_color = cLIQ, text_size = ts)
    table.cell(TBL, 1, 9, na(upP) ? "—" : f_p(upP), text_color = cTXT, text_size = ts)
    table.cell(TBL, 2, 9, na(upP) ? "" : f_d(upP - px), text_color = cDIM, text_size = ts, text_halign = text.align_right)
    table.cell(TBL, 3, 9, na(upP) ? "" : "×" + str.tostring(upW), text_color = upW >= 3 ? cHOT : cTXT, text_size = ts)
    table.cell(TBL, 4, 9, na(upP) ? "" : (upSp <= syminfo.mintick ? "=" : "~"), text_color = cDIM, text_size = ts, text_halign = text.align_right)
    table.cell(TBL, 5, 9, upS, text_color = cTXT, text_size = ts)

    table.cell(TBL, 0, 10, "▼", text_color = cREB, text_size = ts)
    table.cell(TBL, 1, 10, na(dnP) ? "—" : f_p(dnP), text_color = cTXT, text_size = ts)
    table.cell(TBL, 2, 10, na(dnP) ? "" : f_d(dnP - px), text_color = cDIM, text_size = ts, text_halign = text.align_right)
    table.cell(TBL, 3, 10, na(dnP) ? "" : "×" + str.tostring(dnW), text_color = dnW >= 3 ? cHOT : cTXT, text_size = ts)
    table.cell(TBL, 4, 10, na(dnP) ? "" : (dnSp <= syminfo.mintick ? "=" : "~"), text_color = cDIM, text_size = ts, text_halign = text.align_right)
    table.cell(TBL, 5, 10, dnS, text_color = cTXT, text_size = ts)
````
