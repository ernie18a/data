# Wonra Alchemist SNR Engine

- url: https://www.tradingview.com/script/ANCSINu0-Wonra-Alchemist-SNR-Engine/
- type: indicator
- pine_id: PUB;37d4171e342f4dbebd3d328472ee67f0
- version: 9.0

## Description

Wonra Alchemist SNR Engine
An implementation of Malaysian SNR (MSNR) and the Quasimodo reversal pattern, built as one engine because in that method the pieces are not independent indicators. A level means nothing without knowing which way the story is running, and the story is told by levels. This publishes the whole reading rather than one part of it.

Everything below is visible in the source. This is published open-source so the code is the final word on any of it.

How levels are found

Malaysian SNR ignores wicks. A level is marked by joining one candle's close to the next candle's open, and the space between those two prices is the level itself. Where the two meet you get a hairline; where they do not, the space between them never traded, and that untraded space is what the method calls a GAP. The engine treats both as one construct: a level is a band, and a gap is a band you can see.

That has consequences the code follows through on:

A touch registers at either edge of the band.
A break requires a close through the far edge. Closing inside the band has broken nothing, because nothing in there ever traded.
Levels are seeded from confirmed swings (an ATR-threshold zigzag, so minor noise does not create a level of its own) and from close-to-open gaps above a size floor.

How a level earns weight

Two things strengthen a level, and the second is the one most tools ignore.

Touches. Price left the level, came back and was refused. Leaving is required: price hovering at a price does not add a touch every bar.
Misses. Price swung toward the level and turned before reaching it. In MSNR a miss validates a level rather than doing nothing, and the reasoning is that the resting liquidity was never taken, so all of it is still there. A level with three misses is not the same as one with three taps, and the label shows them separately.
Role flip (SBR / RBS)

A level closed through does not disappear, it changes sides. Broken support becomes resistance and broken resistance becomes support, keeping its history. This is the SBR/RBS part of the method and it is why the chart does not empty out over a session.

Quasimodo (QM / QML)

The engine looks for the QM shape: a shoulder, a head beyond it, and a return. For a bullish QM the head must be a lower low than the left shoulder; the level drawn is the left shoulder, not the head, which is where the pattern is traded from. Each candidate must also produce a structure break before it is accepted, and combinations are scanned across several swings so a pattern is still found when a minor swing sits inside it.

Supply zones extend up from the QM level and demand zones extend down from it, on one side only, so price is not counted as having reached a zone while it is still short of the level.

Storyline (direction)

MSNR determines direction from higher-timeframe levels, and the engine follows the four rules the method states:

Direction comes from higher-timeframe levels, read from bodies, not from wick extremes.
A storyline begins with a rejection: a close back below resistance, or back above support.
It is confirmed by a breakout on a lower timeframe. The engine distinguishes the two kinds the method names — an internal breakout of a level formed after the rejection, and an external breakout of one that already existed — and reports which occurred.
Levels against the established direction are roadblocks: the places pullbacks are expected to stop on the way. They are marked rather than hidden, because they are the one thing the method tells you to expect.
Engulfing zones (EG / EF)

An engulfing candle above a size floor creates a zone. The rule that makes it worth having is what happens when it fails: a bullish zone that price closes through becomes a failed zone read the other way, at the same prices, because that is where the other side proved itself. Broken twice and it is discarded, having now been wrong in both directions.

Imbalances

Three-candle gaps, drawn as neutral background. Zones spanning a market closure are discarded — a weekend is not unfinished business between buyers and sellers, it is a closed market, and it happens to leave the largest and most eye-catching gap on the chart.

Scoring

Confirmed patterns are scored 0-100 from what the engine already knows about them: the size of the structure, the quality of the break, whether liquidity was swept and how cleanly, whether an imbalance sits inside the zone, and how proven the levels involved are. The score sets how loudly a pattern is drawn. Nothing is deleted for scoring low.

Why this is one script and not several

Because in this method the parts are not separable. The storyline decides which levels are tradeable and which are roadblocks. The QM level is only a setup when it agrees with the storyline. A level's weight comes from its own touch and miss history. Splitting these into separate indicators would produce three scripts that each need the other two to say anything, which is the situation this replaces.

How to use it

The panel gives the current reading: storyline direction and which breakout confirmed it, how many fresh zones are live on each side, the nearest zone in ATR, and whether a confluence is being watched.
Fresh zones are the tradeable ones. A zone that has been used is faded, not removed, so the history stays readable.
Zone reactions are marked where they happen. A diamond marks a reaction from a level that had already proven itself.
Levels against the storyline are marked RB. Expect a pause there, not a reversal.
Higher timeframes for direction, lower for entry timing. The storyline timeframe is automatic and can be set manually.
Credits

The concepts are not mine. Malaysian SNR, the storyline structure, roadblocks, fresh and unfresh levels, the MISS, SBR/RBS and the Quasimodo entry come from Malaysian SNR and Alchemist educational material that circulates publicly. This is an implementation of that method, not a new one.

The Strong FVG section is taken from "Customizable Strong FVGs" by Fleezzuss, published open-source under the Mozilla Public License 2.0. The three-candle detection, the sensitivity modes and the zone lifecycle are their work. This script is published open-source under the same licence because of it.

Added on top: a gap is not drawn when it would sit on one already on the chart, so consecutive impulse candles stop stacking zones at the same price; gaps spanning a market closure are discarded, because a weekend is a closed market rather than an imbalance; and the palette is neutral so imbalances sit behind the levels instead of competing with them.

Not financial advice. This is an analysis tool. It does not predict outcomes and does not tell you to buy or sell. Every level can fail.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// (c) Wonra
//
// Wonra Alchemist SNR Engine - QML, Malaysian SNR, Flipzone & Confluence Engine
// Built on Pine Script v6
//
// LICENSING NOTE. Section 16 (Strong FVG) is taken from "Customizable Strong FVGs" by
// Fleezzuss, published under the Mozilla Public License 2.0. Under that licence, and
// under TradingView's rule that reusing another author's open-source code requires the
// publication to be open-source too, this script is published open-source under the
// same licence, and Fleezzuss is credited in the publication description.

//@version=6
// Title is plain 7-bit ASCII: TradingView requires it and rejects emoji in script titles.
indicator("Wonra Alchemist SNR Engine", shorttitle="Wonra Alchemist SNR", overlay=true, max_bars_back=5000, max_labels_count=500, max_lines_count=500, max_boxes_count=500, precision=8)

// ============================================================================
// 1. CONSTANTS & VISUAL DESIGN SYSTEM
// ============================================================================
color CLEAR = color.rgb(0, 0, 0, 100)

// ─── TEMA ALGILAMA ───
// Reads chart background luminance and picks a palette for light or dark mode.
// Pastel tones wash out on white, so light mode uses deeper, more saturated
// equivalents of the same hues: identity is kept, contrast is gained.
float _bgLum  = color.r(chart.bg_color) * 0.299 + color.g(chart.bg_color) * 0.587 + color.b(chart.bg_color) * 0.114
bool  isLight = _bgLum > 140

color WONRA_BULL = isLight ? color.rgb(118, 148, 124) : color.rgb(164, 182, 168)  // Sage (pastel)
color WONRA_BEAR = isLight ? color.rgb(174, 130, 130) : color.rgb(192, 164, 164)  // Muted Rose (pastel)
color WONRA_GOLD = isLight ? color.rgb(178, 146, 62)  : color.rgb(216, 188, 108)  // Alchemist Gold (pastel)
color WONRA_GRAY = isLight ? color.rgb(132, 132, 132) : color.rgb(152, 152, 152)  // Slate
color WONRA_BOS  = isLight ? color.rgb(190, 158, 70)  : color.rgb(240, 208, 120)  // BOS Gold

// --- DASHBOARD PALETTE (readable in both modes) ---
color DASH_BG     = isLight ? color.rgb(250, 248, 243, 6)  : color.rgb(18, 22, 32, 10)
color DASH_HEAD   = isLight ? color.rgb(234, 229, 217)     : color.rgb(15, 18, 28)
color DASH_TEXT   = isLight ? color.rgb(62, 66, 74)        : color.rgb(222, 225, 232)
color DASH_MUTED  = isLight ? color.rgb(122, 126, 134)     : color.rgb(150, 154, 164)
color DASH_BORDER = isLight ? color.rgb(206, 200, 188)     : color.rgb(50, 55, 70)
color WONRA_BG    = DASH_BG
// Text on a filled colour chip: light mode chips are dark so text goes light, and vice versa.
color CHIP_TEXT   = isLight ? color.rgb(250, 249, 245) : color.rgb(20, 22, 28)

// ============================================================================
// 2. INPUTS
// ============================================================================
GRP1 = '1) Core & Market Structure'
GRP2 = '2) Quality & Scoring Engine'
GRP3 = '3) Malaysian SNR, SBR / RBS & Flipzones'
GRP4 = '4) Trendline & Point 3 Confluence Engine'
GRP5 = '5) Freshness (Zikir Cycles) & Visuals'
GRP6 = '6) Storyline — Direction Engine (MSNR)'

// ─── 1) CORE & MARKET STRUCTURE ───
signal_mode       = input.string("Structure", "Signal Mode", options=["Structure", "First Touch Back", "Both"], group=GRP1, tooltip="Structure = On BOS break. First Touch Back = On price return to zone (Zikir). Both = Combined.", display=display.none)
strictness_preset = input.string("Loose", "Strictness Preset", options=["Loose", "Balanced", "Strict"], group=GRP1, tooltip="Controls how strict the engine is about signal quality.", display=display.none)
// --- SWING ENGINE: ATR-threshold zigzag ---
// No fixed bar window. A turn becomes a swing once price retraces the ATR
// threshold from the extreme. Duration is irrelevant; magnitude decides.
swing_atr_len     = input.int(14, "Swing ATR Period", minval=2, group=GRP1, display=display.none)
// THE ONE SETTING WORTH UNDERSTANDING. Every pattern here is built from swings, so this
// decides what the engine is able to see at all. A Quasimodo needs five of them; if a turn
// was never registered as a swing, no pattern can be found there no matter how clear it
// looks by eye.
swing_atr_mult    = input.float(1.3, "Swing Threshold (x ATR)", minval=0.2, step=0.1, group=GRP1, tooltip="How far price must travel for a turn to count as a swing. Everything on this chart is built from swings, so this decides what the engine can see.\n\nLOWER IT (1.0 to 1.2) when the engine misses a structure you can see clearly, or when you move to a higher timeframe. ATR grows with the timeframe, so the same turn that was a swing on 3m dissolves into one leg on 15m and the pattern stops being found.\n\nRAISE IT (1.6 to 2.0) when the chart is crowded and you only want the turns that matter.\n\nSettings are saved per chart, so a lower value on your higher timeframe and a higher one on your lower timeframe is the normal way to run this.", display=display.none)
swing_confirm_bars = input.int(2, "Swing Confirmation (Bars)", minval=1, maxval=20, group=GRP1, tooltip="How long a turn must hold before it is confirmed as a swing.", display=display.none)
show_engine_swings = input.bool(false, "🔍 Show Engine Swings (Debug)", group=GRP1, tooltip="Draws the swing structure the engine is reading. Use it to check that it matches the structure you see.", display=display.none)
atr_length        = input.int(14, "ATR Period", group=GRP1, display=display.none)

// ─── 2) QUALITY & SCORING ───
min_score_input   = input.int(0, "Minimum Quality Score (0-100)", minval=0, maxval=100, group=GRP2, tooltip="0 shows everything and lets the grade separate quality. Raising this quickly reduces the number of setups.", display=display.none)
require_liq       = input.bool(false, "Require Liquidity Pool Sweep", group=GRP2, display=display.none)
require_fvg       = input.bool(false, "Require Fair Value Gap (FVG)", group=GRP2, display=display.none)
use_htf_bias      = input.bool(true, "HTF Trend Bias Filter", group=GRP2, display=display.none)
htf_tf_input      = input.string("", "Custom HTF Timeframe (Blank = Auto)", group=GRP2, display=display.none)
htf_mode_input    = input.string("Soft Score", "HTF Mode", options=["Soft Score", "Hard Gate", "Off"], group=GRP2, display=display.none)
// ─── Quality factors ───
use_sweep_filter  = input.bool(true, "Quality: Liquidity Sweep Depth", group=GRP2, tooltip="Rewards setups where price genuinely swept liquidity before turning.", display=display.none)
use_fvg_filter    = input.bool(true, "Quality: FVG Confluence", group=GRP2, display=display.none)
use_div_filter    = input.bool(true, "Quality: RSI Divergence", group=GRP2, display=display.none)
use_volume_filter = input.bool(true, "Quality: Volume & Body Ratio", group=GRP2, display=display.none)
use_regime        = input.bool(true, "Quality: Volatility Regime Multiplier", group=GRP2, tooltip="Reduces the score in choppy, directionless conditions.", display=display.none)
use_freshness     = input.bool(false, "Block Re-used QML Levels", group=GRP2, tooltip="Blocks a second setup from a level that was recently used. Off by default, as it can quietly remove valid setups.", display=display.none)
show_grade        = input.bool(true, "Show Grade (A+ / A / B / C)", group=GRP2, display=display.none)
min_struct_atr    = input.float(1.0, "Min Structure Height (x ATR)", minval=0.3, maxval=5.0, step=0.1, group=GRP2, display=display.none)
// The heaviest of the structural gates by a wide margin, so it gets a switch. It is the
// reference implementation's h2 > h1: the pattern should be ending a move, not appearing in
// the middle of one. Correct in principle, but it refuses several times more candidates
// than it accepts, and the only way to know whether a level you expected was lost to this
// rule or to something else is to be able to turn it off and look.
require_qm_context = input.bool(true, "QM Needs A Move To Reverse", group=GRP2, tooltip="Demands the high before the shoulder sit above the neck (mirrored for bearish), so the pattern ends a move rather than forming inside one. Counted as Cx in the trace. Turn off to see which levels this rule is removing.", display=display.none)

// ─── 3) MALAYSIAN SNR & FLIPZONES ───
show_classic_av   = input.bool(true, "Show Classic A & V (SR Levels)", group=GRP3, display=display.none)
show_sbr_rbs      = input.bool(true, "Show SBR / RBS Flipzones (Fake & Brake)", group=GRP3, display=display.none)
// Named OCL, because that is what it is called and what the chart labels it. It was listed
// as "Gap SNR" while the levels themselves read OCL, so anyone looking for OCL in the
// settings concluded the engine did not have it.
show_gap_snr      = input.bool(true, "Show OCL Levels (Open Close Level)", group=GRP3, tooltip="The junction of one candle's close and the next one's open. Where the two prices do not meet, the space between them never traded, and that is the doctrine's OCL or GAP level.", display=display.none)
gap_min_atr       = input.float(0.10, "Min Gap Size (x ATR)", minval=0.0, step=0.02, group=GRP3, tooltip="Every candle leaves a fraction between its open and the last close. This is the size at which that space becomes a level worth drawing.", display=display.none)
// Engulfing is a whole chapter of the doctrine and this switch controlled nothing at all:
// it was declared here and never read anywhere in the script. The module now exists and
// this is its switch. Its own settings live in group 8.
show_engulfing    = input.bool(true, "Show Engulfing Zones (EG / EF)", group=GRP3, tooltip="Engulfing and Failed Engulfing zones, the doctrine's EG to EG, EG to EF and EF to EG setups. Detailed settings are in group 8.", display=display.none)
snr_extend_bars   = input.int(40, "SNR Level Extension (Bars)", minval=5, group=GRP3, display=display.none)
snr_body_mode     = input.bool(true, "Body / Line-Chart Levels (MSNR Rule)", group=GRP3, tooltip="Draws levels from candle bodies rather than wick extremes, the way they are read on a line chart.", display=display.none)
max_snr_per_type  = input.int(6, "Max Levels Per Type", minval=1, maxval=40, group=GRP3, tooltip="How many levels of each type to keep on the chart.", display=display.none)
hide_tested_snr   = input.bool(true, "Hide Tested (Unfresh) Levels", group=GRP3, tooltip="Hides levels that have already been used. Turn off to keep them visible but faded.", display=display.none)
snr_max_dist_atr  = input.float(0.0, "Hide Levels Farther Than (x ATR)", minval=0, step=1.0, group=GRP3, tooltip="Disabled at 0. Hides levels that are too far from current price to matter.", display=display.none)
snr_cluster_atr   = input.float(0.50, "Level Match Tolerance (x ATR)", minval=0.05, step=0.05, group=GRP3, tooltip="Levels this close together are treated as one, so a level carries its full history instead of appearing as several stacked lines.", display=display.none)
snr_min_touches   = input.int(1, "Min Touches To Show", minval=1, maxval=5, group=GRP3, tooltip="Set to 1 to show every level weighted by strength, or 2 to show only levels that have already proven themselves.", display=display.none)
snr_touch_cd      = input.int(3, "Touch Cooldown (Bars)", minval=1, group=GRP3, tooltip="Stops price hovering at a level from counting as several separate touches.", display=display.none)
snr_touch_tol     = input.float(0.15, "Touch Tolerance (x ATR)", minval=0, step=0.05, group=GRP3, tooltip="A near miss still counts. If price turns just short of a level, that reaction is valid and confirms the level.", display=display.none)
// THE MISS. Malaysian SNR treats an approach that never reaches the level as CONFIRMATION,
// not as a non-event: the liquidity resting there was not taken, so it is all still there.
// A level price has missed is worth more than one already tapped.
snr_count_miss    = input.bool(true, "Count MISSES As Strength", group=GRP3, tooltip="A swing that turns back before reaching a level is a MISS, and in Malaysian SNR a miss validates the level rather than doing nothing. Misses are counted alongside touches and shown separately on the label.", display=display.none)
snr_miss_atr      = input.float(0.60, "Miss Window (x ATR)", minval=0.1, step=0.05, group=GRP3, tooltip="How near a swing has to turn for it to count as a miss rather than unrelated price action. Measured from the level, starting just outside the touch tolerance.", display=display.none)
show_snr_reaction = input.bool(true, "Mark SNR Reactions (◆)", group=GRP3, tooltip="Marks a reaction from a proven level on its own, without needing a full pattern around it.", display=display.none)
snr_react_touches = input.int(3, "SNR Reaction Min Touches", minval=2, maxval=8, group=GRP3, tooltip="How many times a level must have held before its reactions get marked. Higher means fewer but heavier levels.", display=display.none)
snr_away_atr      = input.float(1.0, "Must Leave Level By (x ATR)", minval=0.1, step=0.1, group=GRP3, tooltip="A reversal means price left and came back. Price must move this far away before it can register a new touch.", display=display.none)
snr_confirm_win   = input.int(3, "Reaction Confirm Window (Bars)", minval=1, maxval=10, group=GRP3, tooltip="How long the reaction has to confirm. The marker is placed on the candle that hit the level, even if confirmation arrives a little later.", display=display.none)
sig_cooldown      = input.int(12, "Signal Cooldown (Bars)", minval=1, group=GRP3, tooltip="Keeps one marker per reversal, so several levels stacked together do not each fire on the same turn.", display=display.none)

// ─── 4) TRENDLINE & POINT 3 CONFLUENCE ───
show_trendlines   = input.bool(true, "Show Dynamic Trendlines", group=GRP4, display=display.none)
show_broken_tl    = input.bool(true, "Show Broken Trendlines", group=GRP4, display=display.none)
tl_extend_bars    = input.int(120, "Trendline Extension (Bars)", minval=5, group=GRP4, tooltip="How far a broken trendline is carried forward for a possible retest.", display=display.none)
max_broken_tl     = input.int(6, "Max Broken Trendlines Kept", minval=1, maxval=50, group=GRP4, tooltip="How many broken trendlines to keep on the chart.", display=display.none)
// A trendline is an angled SNR, and an SNR in this method is a body, not a wick.
// Which END of the body matters. The course is explicit: "Resistance: Body Bullish,
// Support: Body Bearish". A rising line holds the bottom of the body, a falling line the
// top. Taking the close regardless of the candle direction put the anchor on the wrong end
// whenever the pivot happened to be the opposite colour, so a rising line appeared to start
// from the top of a green candle and a falling line from the bottom of a red one.
tl_use_close      = input.bool(true, "Anchor Trendlines To Closes", group=GRP4, tooltip="On: the line is pinned to the body, at the end that faces the trend. A rising line holds the bottom of the body, a falling line the top, and wicks are ignored the way this method ignores them everywhere else. Off: pinned to the wick extreme.", display=display.none)
tl_pivot_len      = input.int(20, "Trendline Pivot Lookback", minval=3, group=GRP4, display=display.none)
show_point3       = input.bool(true, "Detect Point 3 Confluence (● circle marker)", group=GRP4, display=display.none)
conf_dist_atr     = input.float(0.35, "Confluence Max Dist (x ATR)", step=0.05, group=GRP4, display=display.none)
// The method names four kinds of POI and only one of them was being checked.
snr_tl_confluence = input.bool(true, "Trendline x SNR Counts As Confluence", group=GRP4, tooltip="A trendline arriving on a fresh OCL, A, V, SBR or RBS is the confluence the method asks for, exactly as a Quasimodo is. Only Quasimodo was counted before.", display=display.none)
snr_tl_min_proof  = input.int(2, "Trendline x SNR Min Proof", minval=1, maxval=6, group=GRP4, tooltip="Touches plus misses the level must carry before a trendline meeting it counts. Keeps the pool to levels the chart has actually respected.", display=display.none)
// --- Shoulder entry: price turns at a level without reaching the zone ---
use_shoulder_entry = input.bool(true, "Right-Shoulder Entry (QML level not reached)", group=GRP4, tooltip="Price does not always return all the way to the level. If the turn lands on a support or resistance instead, that reaction still counts.", display=display.none)
shoulder_band     = input.float(0.75, "Shoulder Max Depth (0-1 of leg)", minval=0.1, maxval=1.0, step=0.05, group=GRP4, tooltip="How shallow the turn is allowed to be and still count. Higher values accept turns that stop further away from the level.", display=display.none)
shoulder_min_snr  = input.int(2, "Shoulder Requires SNR Touches", minval=0, maxval=5, group=GRP4, tooltip="How proven the level under the turn must be. Setting 0 removes the requirement and adds noise.", display=display.none)
show_qml_snr_poi  = input.bool(true, "Project QML × SNR Areas (Analysis)", group=GRP4, tooltip="Marks areas worth watching before price gets there. These are expectations, not signals.", display=display.none)
poi_project_bars  = input.int(30, "Projection Length (Bars)", minval=5, group=GRP4, display=display.none)
poi_max_count     = input.int(8, "Max Projected Areas", minval=1, maxval=30, group=GRP4, display=display.none)

// ─── 5) FRESHNESS (ZIKIR CYCLES), TRADE TOOL & VISUALS ───
show_only_fresh   = input.bool(true, "Show ONLY Active Fresh Zones (Valid)", tooltip="Clean chart mode. Tested (Zikir complete) zones are automatically removed.", group=GRP5, display=display.none)
dim_non_fresh     = input.bool(true, "Dim Non-Fresh (If Shown)", group=GRP5, display=display.none)
ftb_confirm_mode  = input.string("Close Reclaim", "FTB Confirmation Mode", options=["Touch Only", "Wick Rejection", "Close Reclaim", "Displacement Confirmation"], group=GRP5, display=display.none)
invalidation_mode = input.string("Close Beyond Head", "Invalidation Mode", options=["Wick Beyond Head", "Close Beyond Head", "ATR Buffer", "Zone Close"], group=GRP5, display=display.none)
show_qml_zone     = input.bool(true, "Show QML Zone Boxes", group=GRP5, display=display.none)
// The seventh level. The engine always knew where the head was and never drew it.
show_apex         = input.bool(true, "Show QM Apex (head)", group=GRP5, tooltip="The head of the Quasimodo, drawn dotted above the LS line. Not an entry: it is the barrier behind the entry, the price the pattern failed at.", display=display.none)
// The zone says how much room the reaction has, which the line cannot. It was switched off
// because stacked duplicates made a solid block of colour; that is now handled by merging
// overlapping areas into one box instead of by hiding all of them.
qml_zone_mode     = input.string("ATR Zone", "Zone Width Mode", options=["Line", "ATR Zone", "Wick Zone", "Body Zone"], group=GRP5, tooltip="Line draws the QML level only. The other modes shade a band around it. Detection is unaffected either way — the band exists in the engine whether or not it is drawn.", display=display.none)
qml_zone_atr_mult = input.float(0.20, "Zone Width Mult (x ATR)", step=0.05, group=GRP5, display=display.none)
qml_zone_merge    = input.float(50.0, "Merge Zones Overlapping By (%)", minval=0.0, maxval=100.0, step=5.0, group=GRP5, tooltip="Two patterns holding levels a fraction apart describe the same area. Above this overlap the second one draws its line and name but leaves the shading to the first. Both patterns stay fully active. 0 draws every box.", display=display.none)
qml_max_age_bars  = input.int(300, "QML Max Age (Bars)", minval=0, group=GRP5, tooltip="Disabled at 0. Removes zones that have gone untouched long enough to lose relevance.", display=display.none)
qml_max_dist_atr  = input.float(25.0, "QML Max Distance (x ATR)", minval=0, step=0.5, group=GRP5, tooltip="Disabled at 0. Removes zones once price has moved far enough away that they no longer apply.", display=display.none)
max_active_qml    = input.int(120, "Max Active QML Patterns", minval=20, maxval=400, group=GRP5, tooltip="Performance limit. Lower this if the chart becomes slow or unresponsive when changing settings.", display=display.none)
max_drawn_qml     = input.int(25, "Max Drawn QML Zones", minval=10, maxval=200, group=GRP5, tooltip="How many zones to draw at once. Older, already-used zones stop being drawn first; active ones are always kept.", display=display.none)
visual_density    = input.string("Minimal", "Visual Density", options=["Minimal", "Normal", "Detailed"], group=GRP5, tooltip="Minimal keeps the chart clean with marks only. Normal adds short labels. Detailed shows scores and grades.", display=display.none)
marker_offset_atr = input.float(0.45, "Label Distance From Candle (x ATR)", minval=0, step=0.05, group=GRP5, tooltip="How far text labels sit from the candle.", display=display.none)
marker_transp     = input.int(30, "Marker Transparency", minval=0, maxval=90, group=GRP5, tooltip="Marker transparency. Higher is softer.", display=display.none)
show_dashboard     = input.bool(true, "Show Wonra Alchemist Dashboard", group=GRP5, display=display.none)
dash_position     = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=GRP5, display=display.none)
// DEBUG: draw the swings the pattern was actually built from, so a level you disagree with
// can be argued with instead of guessed at. Off by default; this is for reading the engine,
// not for trading from.
show_qml_skeleton = input.bool(false, "Debug: Draw QM Structure", group=GRP5, tooltip="Connects the swings each accepted pattern was assembled from: shoulder, the low or high between, the head, and the break. If a QML looks wrong, this shows which five points the engine used to justify it.", display=display.none)
skel_max          = input.int(12, "Debug: Max Structures Drawn", minval=1, maxval=40, group=GRP5, display=display.none)
verbose_trace     = input.bool(false, "Verbose Trace (dev)", group=GRP5, tooltip="Internal counter output. Not required for normal operation.", display=display.none)

// --- 6) STORYLINE (DIRECTION ENGINE) ---
// Tap a higher-timeframe level, get a rejection, then a lower-timeframe breakout confirms direction.
storyline_mode    = input.string("Mark As Roadblock", "Storyline Filter", options=["Off", "Mark As Roadblock", "Dim Opposite", "Hide Opposite"], group=GRP6, tooltip="Fades or hides anything working against the established direction. It does not stop signals from forming.", display=display.none)
stl_tf_input      = input.string("", "Storyline Timeframe (Blank = Auto)", group=GRP6, display=display.none)
stl_pivot_len     = input.int(5, "Storyline HTF Pivot Length", minval=2, group=GRP6, display=display.none)
stl_reject_tol    = input.float(0.5, "Rejection Tolerance (x ATR)", minval=0.1, step=0.1, group=GRP6, tooltip="How close price must come to a higher-timeframe level to count as a tap.", display=display.none)
show_stl_levels   = input.bool(true, "Show HTF Storyline Levels", group=GRP6, display=display.none)

// ============================================================================
// 3. HELPER FUNCTIONS
// ============================================================================
f_table_pos(string p) =>
    switch p
        'Top Right'    => position.top_right
        'Bottom Right' => position.bottom_right
        'Top Left'     => position.top_left
        'Bottom Left'  => position.bottom_left
        => position.bottom_right

f_preset_min_score() =>
    strictness_preset == "Loose" ? math.max(35, min_score_input - 10) :
     strictness_preset == "Strict" ? math.min(85, min_score_input + 15) : min_score_input

f_preset_ftb_tolerance() =>
    strictness_preset == "Loose" ? 1.3 : strictness_preset == "Strict" ? 0.7 : 1.0

f_preset_bos_body_weight() =>
    strictness_preset == "Strict" ? 0.55 : 0.45

int effectiveMinScore = f_preset_min_score()

// ─── Internal constants (kept out of the menu) ───
float min_break_atr        = 0.15
int   bos_timeout_bars     = 150
float min_bos_atr          = 0.15
float displacement_atr     = 0.4
int   adx_threshold        = 15
string range_mode          = "Soft Gate"
bool  require_bos_close    = true
string bos_close_mode      = "Body Close"

f_grade(int score) =>
    score >= 90 ? "A+" : score >= 80 ? "A" : score >= 70 ? "B" : score >= 60 ? "C" : "Low"

// ============================================================================
// 4. CORE SERIES & METRICS
// ============================================================================
atr14   = ta.atr(atr_length)
atrSafe = nz(atr14, syminfo.mintick * 100)
safeAtr = atrSafe
rsiVal  = ta.rsi(close, 14)
emaVal  = ta.ema(close, 50)
[diPlus, diMinus, adxReal] = ta.dmi(14, 14)

atrPct      = safeAtr / close
atrPctMean  = ta.sma(atrPct, 200)
atrRegime   = nz(atrPctMean, atrPct) > 0 ? atrPct / atrPctMean : 1.0
volSma20    = ta.sma(volume, 20)

levelTol   = safeAtr * 0.15
clusterTol = safeAtr * 0.25

max_bars_back(close, 500)
max_bars_back(open, 500)
max_bars_back(high, 500)
max_bars_back(low, 500)
max_bars_back(volume, 500)
max_bars_back(rsiVal, 500)
max_bars_back(safeAtr, 500)

f_atr_lookup(int barIdx) =>
    int diff = bar_index - barIdx
    diff >= 0 and diff < 500 ? safeAtr[diff] : safeAtr

f_rsi_at(int barIdx) =>
    int diff = bar_index - barIdx
    diff >= 0 and diff < 500 ? rsiVal[diff] : float(na)

f_vol_at(int barIdx) =>
    int diff = bar_index - barIdx
    diff >= 0 and diff < 500 ? volume[diff] : float(na)

// Scales bar counts to the chart timeframe (5m baseline).
float chart_tf_seconds = timeframe.in_seconds()
f_adapt_bars(int base_bars, int min_bars, int max_bars) =>
    int result = base_bars
    if not na(chart_tf_seconds) and chart_tf_seconds > 0
        result := int(math.round(float(base_bars) * 300.0 / chart_tf_seconds))
        result := int(math.max(min_bars, math.min(max_bars, result)))
    result

int fresh_age_bars = f_adapt_bars(200, 50, 1000)

float snrClusterTol = safeAtr * snr_cluster_atr

// Visual density switches, referenced by every drawing site.
bool vMin = visual_density == "Minimal"
bool vDet = visual_density == "Detailed"

// Marker shapes are kept distinct from other indicators that may share the chart,
// so the two are never confused.
float markerOff = safeAtr * marker_offset_atr

// Marker fill: soft and translucent so it never overpowers the candle.
f_mcol(bool isBull) =>
    color.new(isBull ? WONRA_BULL : WONRA_BEAR, marker_transp)

// ─── HTF TREND BIAS RESOLVER ───
f_auto_htf() =>
    int curSec = timeframe.in_seconds()
    string tf = "1D"
    if curSec <= 60
        tf := "60"
    else if curSec <= 900
        tf := "240"
    else if curSec <= 3600
        tf := "D"
    else
        tf := "W"
    tf

string htfResolved = htf_tf_input == "" ? f_auto_htf() : htf_tf_input
[htfEma50, htfEma200] = request.security(syminfo.tickerid, htfResolved, [ta.ema(close, 50)[1], ta.ema(close, 200)[1]], lookahead=barmerge.lookahead_off)
bool htfBullBias = not na(htfEma50) and not na(htfEma200) and htfEma50 > htfEma200
bool htfBearBias = not na(htfEma50) and not na(htfEma200) and htfEma50 < htfEma200

// ============================================================================
// 5. TYPES & DATA STRUCTURES
// ============================================================================
type SwingPoint
    int   index
    float price
    int   dir       // +1 = High, -1 = Low
    bool  confirmed

type QMLPattern
    bool  isBull
    float h2
    float h1
    float h0
    float l2
    float l1
    float l0
    int   h2i
    int   h1i
    int   h0i
    int   l2i
    int   l1i
    int   l0i
    float qmlLevel
    float headLevel
    float invalidLevel
    float bosLevel
    int   bosIndex
    bool  bosBody
    float sweepLevel
    int   sweepIndex
    int   createdBar
    int   score
    bool  isFresh
    bool  ftbTouched
    int   ftbTouchedBar
    float zoneTop
    float zoneBot
    box   zoneBox
    line  qmlLine
    label qmlLabel
    bool  isFlipped     // level was broken and switched role (resistance becomes support and vice versa)
    line  apexLine      // the QM head: seventh of the doctrine's levels, the strongest barrier
    label apexLabel

type FvgZone
    float top
    float bot
    int   dir
    int   bar
    bool  mitigated

type LiqPool
    float lvl
    int   side
    int   touches
    int   lastBar
    bool  swept

type SnrLevel
    float levelPrice
    int startIdx
    string levelType    // "Classic A", "Classic V", "SBR", "RBS", "Gap SNR", "Engulfing"
    bool isBull         // true = support | false = resistance
    bool isFresh        // untouched = tradeable
    bool isTested       // already tested = unfresh
    int  touches        // number of confirmed touches = strength
    float bandHi        // the close-to-open junction is a BAND, not one price
    float bandLo
    int  misses         // MSNR "MISS": price swung toward the level and turned before reaching it
    int  lastMissIdx    // bar of the last counted miss
    int  lastTouchIdx   // bar of the last counted touch
    bool isFlipped      // bir kez flip oldu mu (A→RBS / V→SBR)
    line lineId
    label labelId
    int  lastSignalIdx  // bar of the last reaction marker
    bool awayOk         // has price moved far enough away? a touch only counts after leaving and returning
    int  pendingBar     // index of the candle that hit the level; the marker lands here even if confirmation is late

// Global stores
var array<SwingPoint> swings    = array.new<SwingPoint>()
var array<FvgZone>    fvgList   = array.new<FvgZone>()
var array<LiqPool>    liqList   = array.new<LiqPool>()
var array<QMLPattern> qmlActive = array.new<QMLPattern>()
var array<SnrLevel>   snrList   = array.new<SnrLevel>()
var array<line>       drawnLines  = array.new<line>()
var array<line>       qmlSkel     = array.new<line>()   // debug: the swing chain behind each pattern
var array<label>      qmlSkelLb   = array.new<label>() // debug: the name of each point in that chain
var array<label>      drawnLabels = array.new<label>()
var array<box>        drawnBoxes  = array.new<box>()

// ============================================================================
// 6. CONFIRMED UNIFIED SWING ENGINE (SWING POINT TRACKER)
// ============================================================================
f_add_swing(int idx, float price, int dir) =>
    int event = 0
    if not na(idx) and not na(price)
        int sz = array.size(swings)
        if sz == 0
            array.push(swings, SwingPoint.new(idx, price, dir, true))
            event := 1
        else
            SwingPoint last = array.get(swings, sz - 1)
            bool moreExtreme = dir == 1 ? price > last.price : price < last.price
            if idx <= last.index
                if idx == last.index and dir == last.dir and moreExtreme
                    array.set(swings, sz - 1, SwingPoint.new(idx, price, dir, true))
                    event := 2
            else if last.dir == dir
                if moreExtreme
                    array.set(swings, sz - 1, SwingPoint.new(idx, price, dir, true))
                    event := 2
            else
                array.push(swings, SwingPoint.new(idx, price, dir, true))
                event := 1
                while array.size(swings) > 140
                    array.shift(swings)
    event

// --- ATR-THRESHOLD ZIGZAG ---
float swingAtrV   = ta.atr(swing_atr_len)
float swThreshold = na(swingAtrV) ? 0.0 : swingAtrV * swing_atr_mult

var float sInitialHigh = na, var float sInitialLow = na
var int   sInitialHighIdx = na, var int sInitialLowIdx = na
var float sExtremePrice = na
var int   sExtremeIndex = na
var int   sTrendDir = 0
var float sCandHighPrice = na, var int sCandHighIdx = na
var float sCandLowPrice  = na, var int sCandLowIdx  = na
var float sPrevHigh = na, var int sPrevHighIdx = na
var float sPrevLow  = na, var int sPrevLowIdx  = na

bool newHighConfirmed = false
bool newLowConfirmed  = false

if na(sInitialHigh)
    sInitialHigh := high
    sInitialLow  := low
    sInitialHighIdx := bar_index
    sInitialLowIdx  := bar_index
    sExtremePrice := close
    sExtremeIndex := bar_index

if sTrendDir == 0
    if high > sInitialHigh
        sInitialHigh := high
        sInitialHighIdx := bar_index
    if low < sInitialLow
        sInitialLow := low
        sInitialLowIdx := bar_index

    if high > sInitialLow + swThreshold
        sTrendDir := -1
        sExtremePrice := high
        sExtremeIndex := bar_index
        sCandLowPrice := sInitialLow
        sCandLowIdx   := sInitialLowIdx
    else if low < sInitialHigh - swThreshold
        sTrendDir := 1
        sExtremePrice := low
        sExtremeIndex := bar_index
        sCandHighPrice := sInitialHigh
        sCandHighIdx   := sInitialHighIdx
else if sTrendDir == 1
    if not na(sCandHighIdx)
        if high > sCandHighPrice
            sTrendDir := -1
            sExtremePrice := high
            sExtremeIndex := bar_index
            sCandHighPrice := na
            sCandHighIdx := na
    if sTrendDir == 1
        if low < sExtremePrice
            sExtremePrice := low
            sExtremeIndex := bar_index
        else if high > sExtremePrice + swThreshold
            sTrendDir := -1
            sCandLowPrice := sExtremePrice
            sCandLowIdx   := sExtremeIndex
            sExtremePrice := high
            sExtremeIndex := bar_index
else if sTrendDir == -1
    if not na(sCandLowIdx)
        if low < sCandLowPrice
            sTrendDir := 1
            sExtremePrice := low
            sExtremeIndex := bar_index
            sCandLowPrice := na
            sCandLowIdx := na
    if sTrendDir == -1
        if high > sExtremePrice
            sExtremePrice := high
            sExtremeIndex := bar_index
        else if low < sExtremePrice - swThreshold
            sTrendDir := 1
            sCandHighPrice := sExtremePrice
            sCandHighIdx   := sExtremeIndex
            sExtremePrice := low
            sExtremeIndex := bar_index

// Candidate confirmation: hold for swing_confirm_bars bars.
if not na(sCandLowIdx) and (bar_index - sCandLowIdx >= swing_confirm_bars)
    newLowConfirmed := true
    sPrevLow    := sCandLowPrice
    sPrevLowIdx := sCandLowIdx
    sCandLowPrice := na
    sCandLowIdx   := na

if not na(sCandHighIdx) and (bar_index - sCandHighIdx >= swing_confirm_bars)
    newHighConfirmed := true
    sPrevHigh    := sCandHighPrice
    sPrevHighIdx := sCandHighIdx
    sCandHighPrice := na
    sCandHighIdx   := na

// Downstream keeps the ph/pl names, but highs and lows now carry separate indices.
float ph    = newHighConfirmed ? sPrevHigh : na
int   phIdx = newHighConfirmed ? sPrevHighIdx : int(na)
float pl    = newLowConfirmed ? sPrevLow : na
int   plIdx = newLowConfirmed ? sPrevLowIdx : int(na)

if not na(ph)
    f_add_swing(phIdx, ph, 1)
if not na(pl)
    f_add_swing(plIdx, pl, -1)

// ============================================================================
// 7. FVG & LIQUIDITY POOL DETECTORS
// ============================================================================
if barstate.isconfirmed and low > high[2]
    array.push(fvgList, FvgZone.new(low, high[2], 1, bar_index, false))
if barstate.isconfirmed and high < low[2]
    array.push(fvgList, FvgZone.new(low[2], high, -1, bar_index, false))
while array.size(fvgList) > 200
    array.shift(fvgList)

if barstate.isconfirmed and array.size(fvgList) > 0
    for i = 0 to array.size(fvgList) - 1
        FvgZone z = array.get(fvgList, i)
        if not z.mitigated
            if z.dir == 1 and low < z.bot
                z.mitigated := true
                array.set(fvgList, i, z)
            else if z.dir == -1 and high > z.top
                z.mitigated := true
                array.set(fvgList, i, z)

// ============================================================================
// 7B. LIQUIDITY POOLS (feeds pool-sweep quality)
// ============================================================================
float pvh = ta.pivothigh(high, 5, 5)
float pvl = ta.pivotlow(low, 5, 5)
int liqPivotIdx = bar_index - 5

if barstate.isconfirmed and not na(pvh)
    bool mergedHigh = false
    if array.size(liqList) > 0
        for i = 0 to array.size(liqList) - 1
            LiqPool p = array.get(liqList, i)
            if not mergedHigh and p.side == 1 and math.abs(p.lvl - pvh) <= clusterTol
                p.touches := p.touches + 1
                p.lastBar := liqPivotIdx
                mergedHigh := true
    if not mergedHigh
        array.push(liqList, LiqPool.new(pvh, 1, 1, liqPivotIdx, false))

if barstate.isconfirmed and not na(pvl)
    bool mergedLow = false
    if array.size(liqList) > 0
        for i = 0 to array.size(liqList) - 1
            LiqPool p = array.get(liqList, i)
            if not mergedLow and p.side == -1 and math.abs(p.lvl - pvl) <= clusterTol
                p.touches := p.touches + 1
                p.lastBar := liqPivotIdx
                mergedLow := true
    if not mergedLow
        array.push(liqList, LiqPool.new(pvl, -1, 1, liqPivotIdx, false))

while array.size(liqList) > 200
    array.shift(liqList)

if barstate.isconfirmed and array.size(liqList) > 0
    for i = 0 to array.size(liqList) - 1
        LiqPool p = array.get(liqList, i)
        if not p.swept
            if p.side == -1 and low < p.lvl and close > p.lvl
                p.swept := true
            else if p.side == 1 and high > p.lvl and close < p.lvl
                p.swept := true

// ============================================================================
// 8. QUALITY SCORING SYSTEM (0-100)
// ============================================================================
f_fvg_quality(float refLvl, bool isBull, int afterBar, int beforeBar) =>
    float bestQ = 0.0
    int sz = array.size(fvgList)
    if sz > 0
        int stopAt = math.max(0, sz - 80)
        int loopRange = sz - stopAt
        if loopRange > 0
            for offset = 0 to loopRange - 1
                int i = sz - 1 - offset
                FvgZone z = array.get(fvgList, i)
                if z.bar > afterBar and z.bar <= beforeBar and not z.mitigated
                    bool dirOk   = isBull ? z.dir == 1 : z.dir == -1
                    bool nearLvl = refLvl >= z.bot - levelTol and refLvl <= z.top + levelTol
                    if dirOk and nearLvl
                        float sizeQ  = math.min(1.0, math.abs(z.top - z.bot) / safeAtr / 1.5)
                        float freshQ = math.max(0.25, 1.0 - float(beforeBar - z.bar) / 120.0)
                        float q = sizeQ * 0.6 + freshQ * 0.4
                        if q > bestQ
                            bestQ := q
    bestQ

f_direct_sweep_quality(float sweptLvl, bool isBullSetup, int headIdx) =>
    float q = 0.0
    int diff = bar_index - headIdx
    if diff >= 0 and diff < 500
        float atrRef = f_atr_lookup(headIdx)
        float depth  = isBullSetup ? sweptLvl - low[diff] : high[diff] - sweptLvl
        bool broke     = depth >= atrRef * min_break_atr
        bool reclaimed = isBullSetup ? close[diff] > sweptLvl : close[diff] < sweptLvl
        if broke
            float depthQ   = math.min(1.0, depth / atrRef / 0.75)
            float reclaimQ = reclaimed ? 1.0 : 0.45
            q := depthQ * 0.65 + reclaimQ * 0.35
    q

f_pool_sweep_quality(float sweptLvl, bool isBullSetup, int headIdx) =>
    int targetType = isBullSetup ? -1 : 1
    float bestQ = 0.0
    int diff = bar_index - headIdx
    int sz = array.size(liqList)
    if sz > 0 and diff >= 0 and diff < 500
        float hLow   = low[diff]
        float hHigh  = high[diff]
        float hClose = close[diff]
        float atrRef = f_atr_lookup(headIdx)
        int stopAt = math.max(0, sz - 80)
        int loopRange = sz - stopAt
        if loopRange > 0
            for offset = 0 to loopRange - 1
                int i = sz - 1 - offset
                LiqPool p = array.get(liqList, i)
                if p.side == targetType and p.touches >= 2 and p.lastBar < headIdx and math.abs(p.lvl - sweptLvl) <= clusterTol
                    float depth = isBullSetup ? p.lvl - hLow : hHigh - p.lvl
                    bool sweepOk = isBullSetup ? (hLow < p.lvl and hClose > p.lvl) : (hHigh > p.lvl and hClose < p.lvl)
                    if sweepOk
                        float depthQ = math.min(1.0, depth / atrRef / 0.75)
                        float touchQ = math.min(1.0, float(p.touches) / 4.0)
                        float q = depthQ * 0.65 + touchQ * 0.35
                        if q > bestQ
                            bestQ := q
    bestQ

f_div_score(bool isBull, int idxA, int idxB, float priceA, float priceB) =>
    float ra = f_rsi_at(idxA)
    float rb = f_rsi_at(idxB)
    float q = 0.0
    if not na(ra) and not na(rb)
        if isBull and priceB < priceA and rb > ra
            q := math.min(1.0, math.abs(rb - ra) / 15.0)
        else if not isBull and priceB > priceA and rb < ra
            q := math.min(1.0, math.abs(ra - rb) / 15.0)
    q

f_volume_score(int headIdx, int bosIdx) =>
    float headVol = f_vol_at(headIdx)
    float bosVol  = f_vol_at(bosIdx)
    float avgV    = nz(volSma20, 1.0)
    float sweepVolQ = na(headVol) ? 0.0 : math.min(1.0, headVol / avgV / 1.5)
    float bosVolQ   = na(bosVol)  ? 0.0 : math.min(1.0, bosVol / avgV / 1.2)
    int diff = bar_index - bosIdx
    float barRange = diff >= 0 and diff < 500 ? high[diff] - low[diff] : high - low
    float bodySize = diff >= 0 and diff < 500 ? math.abs(close[diff] - open[diff]) : math.abs(close - open)
    float bodyRatio = barRange > 0 ? bodySize / barRange : 0.0
    float deltaQ = math.min(1.0, bodyRatio / 0.6)
    sweepVolQ * 0.35 + bosVolQ * 0.35 + deltaQ * 0.30

f_displacement_score(bool isBull, int eventIdx) =>
    int diff = bar_index - eventIdx
    float eventOpen  = diff >= 0 and diff < 500 ? open[diff] : open
    float eventClose = diff >= 0 and diff < 500 ? close[diff] : close
    float bodySize = math.abs(eventClose - eventOpen)
    float bodyQ = math.min(1.0, (bodySize / f_atr_lookup(eventIdx)) / displacement_atr / 1.5)
    bool dirOk = isBull ? eventClose > eventOpen : eventClose < eventOpen
    dirOk ? bodyQ : bodyQ * 0.3

f_regime_state() =>
    string s = "trending"
    if not na(adxReal) and adxReal < adx_threshold
        s := "ranging"
    else if atrRegime > 1.8
        s := "volatile"
    else if atrRegime < 0.6
        s := "compressed"
    s

f_regime_multiplier(string regime) =>
    float m = 1.0
    if regime == "ranging"
        m := range_mode == "Soft Gate" ? 0.65 : range_mode == "Hard Gate" ? 0.0 : 1.0
    else if regime == "volatile"
        m := 0.85
    else if regime == "compressed"
        m := 0.90
    m

// Structure-break validation. Returns [ok, bodyBreak, depth, quality, index, price].
f_bos_check(bool isBull, float level, int headIdx) =>
    int barsFromHead = bar_index - headIdx
    bool bodyRequired = require_bos_close and bos_close_mode == "Body Close"
    bool ok = false
    bool foundBody = false
    float foundDepth = 0.0
    float foundPrice = float(na)
    int foundIdx = int(na)
    if barsFromHead > 0
        int maxLook = math.min(math.min(barsFromHead, bos_timeout_bars), 500)
        int step = 1
        while step <= maxLook and not ok
            int eventIdx = headIdx + step
            int off = bar_index - eventIdx
            if off >= 0 and off < 500
                float threshold = f_atr_lookup(eventIdx) * min_bos_atr
                float c = close[off]
                bool bodyBreak = isBull ? c > level + threshold : c < level - threshold
                bool wickBreak = isBull ? high[off] > level + threshold : low[off] < level - threshold
                bool breakOk = bodyRequired ? bodyBreak : wickBreak
                if breakOk
                    ok := true
                    foundBody := bodyBreak
                    foundIdx  := eventIdx
                    foundPrice := isBull ? (bodyBreak ? c : high[off]) : (bodyBreak ? c : low[off])
                    foundDepth := isBull ? foundPrice - level : level - foundPrice
            step := step + 1
    float bosBodyW = f_preset_bos_body_weight()
    float modeQ  = foundBody ? 1.0 : 0.65
    float depthQ = math.min(1.0, foundDepth / safeAtr / 0.75)
    float timeQ  = ok ? math.max(0.2, 1.0 - float(foundIdx - headIdx) / float(math.max(bos_timeout_bars, 1))) : 0.0
    float q = ok ? modeQ * bosBodyW + depthQ * 0.35 + timeQ * (1.0 - bosBodyW - 0.35) : 0.0
    [ok, foundBody, foundDepth, q, foundIdx, foundPrice]

f_compute_score(bool isBull, int headIdx, int bosIdx, int divIdxA, int divIdxB, float divPriceA, float divPriceB, float directSweepQ, float poolSweepQ, float fvgQ, float bosQ) =>
    float sweep = use_sweep_filter ? math.max(directSweepQ * 0.65 + poolSweepQ * 0.35, directSweepQ * 0.75) : 0.5
    float fvg   = use_fvg_filter ? fvgQ : 0.5
    float disp  = f_displacement_score(isBull, bosIdx)
    float vol   = use_volume_filter ? f_volume_score(headIdx, bosIdx) : 0.5
    float div   = use_div_filter ? f_div_score(isBull, divIdxA, divIdxB, divPriceA, divPriceB) : 0.5
    bool aligned = (isBull and htfBullBias) or (not isBull and htfBearBias)
    float htf = 0.5
    if use_htf_bias and htf_mode_input != "Off"
        htf := aligned ? 1.0 : 0.0
    float regimeMult = use_regime ? f_regime_multiplier(f_regime_state()) : 1.0
    float raw = sweep * 22.0 + bosQ * 22.0 + fvg * 16.0 + disp * 14.0 + vol * 10.0 + div * 8.0 + htf * 8.0
    int(math.round(math.min(100.0, raw * regimeMult)))

// ─── FTB REACTION CONFIRMATION ───
// When price returns to a level, this separates a genuine reaction from price
// simply passing through. This is the entry itself.
float ftb_rejection_wick_ratio = 0.45
float ftb_min_body_atr         = 0.25

f_ftb_reaction(bool isBull, float lvl, float zoneTop, float zoneBot) =>
    float tolMult   = f_preset_ftb_tolerance()
    float body      = math.abs(close - open)
    float rng       = high - low
    float upperWick = high - math.max(open, close)
    float lowerWick = math.min(open, close) - low
    bool rangeOk = rng > 0
    bool result  = false

    if ftb_confirm_mode == "Touch Only"
        bool touched = isBull ? low <= (na(zoneTop) ? lvl : zoneTop) + levelTol * tolMult : high >= (na(zoneBot) ? lvl : zoneBot) - levelTol * tolMult
        result := rangeOk and touched

    else if ftb_confirm_mode == "Wick Rejection"
        float wickRatio = ftb_rejection_wick_ratio * tolMult
        if isBull
            result := rangeOk and lowerWick / rng >= wickRatio and close > lvl
        else
            result := rangeOk and upperWick / rng >= wickRatio and close < lvl

    else if ftb_confirm_mode == "Close Reclaim"
        float minReact = safeAtr * 0.05 * tolMult
        bool closeAway  = isBull ? close > lvl + minReact : close < lvl - minReact
        bool bodySide   = isBull ? (open > lvl and close > lvl) : (open < lvl and close < lvl)
        bool candleDir  = isBull ? close >= open : close <= open
        bool wickReject = isBull ? lowerWick > upperWick * 0.8 : upperWick > lowerWick * 0.8
        result := rangeOk and closeAway and bodySide and (candleDir or wickReject)

    else if ftb_confirm_mode == "Displacement Confirmation"
        float minDisp = safeAtr * ftb_min_body_atr * 1.2 * tolMult
        bool dirOk = isBull ? close > open : close < open
        bool sideOk = isBull ? close > lvl : close < lvl
        float bodyRatio = rng > 0 ? body / rng : 0.0
        result := rangeOk and dirOk and sideOk and body >= minDisp and bodyRatio >= 0.6

    result

// ─── Level re-use filter ───
var array<float> usedBullLvl = array.new<float>()
var array<float> usedBearLvl = array.new<float>()
var array<int>   usedBullBar = array.new<int>()
var array<int>   usedBearBar = array.new<int>()

f_is_fresh(float lvl, bool isBull) =>
    bool fresh = true
    if use_freshness
        if isBull
            int sz = array.size(usedBullLvl)
            if sz > 0
                for i = 0 to sz - 1
                    if fresh and math.abs(array.get(usedBullLvl, i) - lvl) <= levelTol and (bar_index - array.get(usedBullBar, i)) < fresh_age_bars
                        fresh := false
        else
            int sz = array.size(usedBearLvl)
            if sz > 0
                for i = 0 to sz - 1
                    if fresh and math.abs(array.get(usedBearLvl, i) - lvl) <= levelTol and (bar_index - array.get(usedBearBar, i)) < fresh_age_bars
                        fresh := false
    fresh

f_mark_used(float lvl, bool isBull) =>
    if isBull
        array.push(usedBullLvl, lvl)
        array.push(usedBullBar, bar_index)
        while array.size(usedBullLvl) > 30
            array.shift(usedBullLvl)
            array.shift(usedBullBar)
    else
        array.push(usedBearLvl, lvl)
        array.push(usedBearBar, bar_index)
        while array.size(usedBearLvl) > 30
            array.shift(usedBearLvl)
            array.shift(usedBearBar)

// ============================================================================
// 8B. STORYLINE ENGINE (DIRECTION)
// ============================================================================
// Tap a higher-timeframe level, get a rejection, then a lower-timeframe breakout.
// Once direction is locked, anything against it is faded or hidden.
string stlTf = stl_tf_input == "" ? f_auto_htf() : stl_tf_input

// BODY LEVELS, NOT WICK EXTREMES.
// "The Malaysian traders ignore the conventional way of trading the support and resistance
//  levels but rather a focus on the BODY of the candlestick."
// The storyline was reading its higher-timeframe levels from pivots on high and low, which
// is the conventional way the doctrine explicitly sets aside. A wick that spiked once is
// not where the story turns. The junction of the bodies is.
[stlPh, stlPl] = request.security(syminfo.tickerid, stlTf, [ta.pivothigh(math.max(open, close), stl_pivot_len, stl_pivot_len), ta.pivotlow(math.min(open, close), stl_pivot_len, stl_pivot_len)], lookahead=barmerge.lookahead_off)

var float stlRes = na
var float stlSup = na
if not na(stlPh)
    stlRes := stlPh
if not na(stlPl)
    stlSup := stlPl

// Most recent confirmed swing, price AND the bar it formed on. The bar is what tells
// internal from external later.
f_last_swing(int dir) =>
    float v = na
    int   b = na
    if array.size(swings) > 0
        for i = array.size(swings) - 1 to 0
            if na(v)
                SwingPoint s = array.get(swings, i)
                if s.dir == dir
                    v := s.price
                    b := s.index
    [v, b]

var int   stlPending    = 0        // -1 = bearish candidate, +1 = bullish candidate
var float stlBreakLvl   = na
var int   stlBreakBar   = na       // bar the break level was formed on
var int   stlRejectBar  = na       // bar the higher-timeframe rejection happened on
var bool  stlInternal   = false    // was the break level born after the rejection?
var int   storylineDir  = 0        // -1 / 0 / +1 confirmed direction
var int   stlConfirmBar = na

float stlTol = safeAtr * stl_reject_tol

// 1) Tap a higher-timeframe level and get rejected
if not na(stlRes) and high >= stlRes - stlTol and close < stlRes - stlTol * 0.2
    stlPending   := -1
    stlRejectBar := bar_index
if not na(stlSup) and low <= stlSup + stlTol and close > stlSup + stlTol * 0.2
    stlPending   := 1
    stlRejectBar := bar_index

// The level to break is kept CURRENT while the rejection waits for its confirmation.
// It used to be fixed at the moment of the rejection, which quietly made every breakout an
// external one: the level was by definition already there. The doctrine has two kinds and
// the difference is which side of the rejection the level was born on.
//   "Internal : BO level that was formed AFTER the rejection.
//    External : BO level that was formed BEFORE the rejection."
if stlPending != 0
    [swPx, swBar] = f_last_swing(stlPending)
    if not na(swPx)
        stlBreakLvl := swPx
        stlBreakBar := swBar

// 2) Lower-timeframe breakout confirms and locks direction
bool stlBroke = stlPending == -1 and not na(stlBreakLvl) and close < stlBreakLvl
bool stlBrokeUp = stlPending == 1 and not na(stlBreakLvl) and close > stlBreakLvl
if stlBroke or stlBrokeUp
    storylineDir  := stlPending
    stlInternal   := not na(stlBreakBar) and not na(stlRejectBar) and stlBreakBar > stlRejectBar
    stlPending    := 0
    stlConfirmBar := bar_index

// Is this object working against the established direction?
f_stl_opposes(bool isBull) =>
    storyline_mode != "Off" and storylineDir != 0 and ((isBull and storylineDir == -1) or (not isBull and storylineDir == 1))

// Draw the higher-timeframe storyline levels.
var line stlResLine = na
var line stlSupLine = na
if show_stl_levels and barstate.islast
    int stlLeft = math.max(0, bar_index - 300)
    if not na(stlRes)
        line.delete(stlResLine)
        stlResLine := line.new(stlLeft, stlRes, bar_index + snr_extend_bars, stlRes, color=color.new(WONRA_BEAR, 35), width=2, style=line.style_dashed)
    if not na(stlSup)
        line.delete(stlSupLine)
        stlSupLine := line.new(stlLeft, stlSup, bar_index + snr_extend_bars, stlSup, color=color.new(WONRA_BULL, 35), width=2, style=line.style_dashed)

// ============================================================================
// 9. LEVEL ENGINE (BODY LEVELS + FRESHNESS LIFECYCLE)
// ============================================================================
// Levels are drawn from candle bodies, not wick extremes.
//   Resistance = the close of a bullish candle immediately followed by a bearish one.
//   Support = the close of a bearish candle immediately followed by a bullish one.
// A level closed through by a body dies; one touched by a wick becomes unfresh.

// --- Find the body-based level around a swing (close-to-open junction) ---
// "You draw a line across the first candlestick's CLOSE to join the next candlestick's
//  OPEN. Ignore the wicks."
// It is a junction of TWO prices, and only the close was being kept. Where the two meet the
// band is a hairline and this is the ordinary Classic A or V. Where they do not meet, the
// space between them never traded, and that space is the doctrine's GAP. They are the same
// construct: a level is a band, and a gap is simply a band you can see.
// Returns [midpoint, band high, band low, index of the bar that formed it].
f_body_level(int pivIdx, int win, bool wantResistance) =>
    float best   = na
    float bandHi = na
    float bandLo = na
    int   bestIx = na
    for k = -win to win
        int off = bar_index - (pivIdx + k)
        if off >= 1 and off < 480
            bool bullK    = close[off] > open[off]
            bool bearK    = close[off] < open[off]
            bool bullNext = close[off - 1] > open[off - 1]
            bool bearNext = close[off - 1] < open[off - 1]
            if wantResistance
                if bullK and bearNext and (na(best) or close[off] > best)
                    best   := close[off]
                    bandHi := math.max(close[off], open[off - 1])
                    bandLo := math.min(close[off], open[off - 1])
                    bestIx := pivIdx + k
            else
                if bearK and bullNext and (na(best) or close[off] < best)
                    best   := close[off]
                    bandHi := math.max(close[off], open[off - 1])
                    bandLo := math.min(close[off], open[off - 1])
                    bestIx := pivIdx + k
    // THE LEVEL IS THE CLOSE. Not the middle of the junction.
    // "Harga Close is the ONLY valid price for drawing a level. Harga Open is NOT used."
    // The junction of close and next open tells you WHERE the level is; the price you draw
    // is the close, which is the one price buyers and sellers actually agreed on, and the
    // one a line chart plots. The band is kept for tolerance, because the untraded space
    // between the two is real, but the line itself belongs on the close.
    [best, bandHi, bandLo, bestIx]

// --- Was the level already broken before it was born? (covers confirmation lag) ---
f_already_broken(float lvl, int startIdx, bool isBull) =>
    bool brk = false
    int off0 = bar_index - startIdx
    if off0 > 0
        for k = off0 - 1 to 0
            if not brk
                float c = close[k]
                if (isBull ? (c < lvl - levelTol) : (c > lvl + levelTol))
                    brk := true
    brk

// --- Per-type count limit: drop the oldest ---
f_prune_snr(string ltype) =>
    int cnt = 0
    int i = 0
    while i < array.size(snrList)
        SnrLevel s = array.get(snrList, i)
        bool removed = false
        if s.levelType == ltype
            cnt += 1
            if cnt > max_snr_per_type
                line.delete(s.lineId)
                label.delete(s.labelId)
                array.remove(snrList, i)
                removed := true
        if not removed
            i += 1

// --- Level factory: match an existing level first, otherwise create one ---
// A match means the level already exists: no new line, just another touch.
// The line already starts at the earliest occurrence, so history is preserved.
f_new_snr(float lvl, float bHi, float bLo, int startIdx, string ltype, bool isBull) =>
    if not na(lvl)
        bool merged = false
        if array.size(snrList) > 0
            for i = 0 to array.size(snrList) - 1
                SnrLevel s = array.get(snrList, i)
                if not merged and s.isBull == isBull and math.abs(s.levelPrice - lvl) <= snrClusterTol
                    s.touches      := s.touches + 1
                    s.lastTouchIdx := bar_index
                    merged := true
        if not merged and not f_already_broken(lvl, startIdx, isBull)
            color c    = isBull ? WONRA_BULL : WONRA_BEAR
            // The doctrine's own names: an A-shaped peak is R, a V-shaped bottom is S, and
            // the close-to-open junction is OCL. The old tags used R and S for the FLIPPED
            // levels, which collided head-on with the names for plain resistance and support:
            // a reader seeing S read "support" when it meant a support that had become a
            // resistance, the exact opposite of what the line was saying.
            string tag = ltype == "Gap SNR" ? "OCL" : isBull ? "S" : "R"
            line l   = line.new(startIdx, lvl, bar_index + snr_extend_bars, lvl, color=color.new(c, 25), width=1, style=line.style_solid)
            label lb = label.new(bar_index + snr_extend_bars, lvl, tag, style=label.style_label_left, color=CLEAR, textcolor=color.new(c, 15), size=size.tiny)
            array.unshift(snrList, SnrLevel.new(lvl, startIdx, ltype, isBull, true, false, 1, nz(bHi, lvl), nz(bLo, lvl), 0, int(na), startIdx, false, l, lb, int(na), true, int(na)))
            f_prune_snr(ltype)

// ─── CLASSIC A / V ───
if not na(ph) and show_classic_av
    [bLvlA, bHiA, bLoA, bIxA] = f_body_level(phIdx, 3, true)
    bool useBodyA = snr_body_mode and not na(bLvlA)
    f_new_snr(useBodyA ? bLvlA : ph, useBodyA ? bHiA : ph, useBodyA ? bLoA : ph, useBodyA ? bIxA : phIdx, "Classic A", false)

if not na(pl) and show_classic_av
    [bLvlV, bHiV, bLoV, bIxV] = f_body_level(plIdx, 3, false)
    bool useBodyV = snr_body_mode and not na(bLvlV)
    f_new_snr(useBodyV ? bLvlV : pl, useBodyV ? bHiV : pl, useBodyV ? bLoV : pl, useBodyV ? bIxV : plIdx, "Classic V", true)

// --- GAP LEVELS: the hidden zone between one candle's CLOSE and the next one's OPEN ---
// "To mark the SNR Level, your focus is on the CLOSE and OPEN prices. You draw a line
//  across the first candlestick's close to join the next candlestick's open."
// When those two prices do not meet, the space between them is the doctrine's GAP, the
// hidden zone that never traded. This was previously reading the OPEN of any large candle,
// which is not a gap at all: a big candle whose open sits exactly on the last close leaves
// nothing behind, and the level being drawn was just an arbitrary price inside a range.
// The level is the middle of the untraded space, and the gap has to be large enough to be
// real rather than the fraction of a tick every candle leaves behind.
float gapUp   = open - close[1]
float gapDn   = close[1] - open
float gapMin  = safeAtr * gap_min_atr

// A bullish gap is left behind by a move away from the previous close, so it sits under
// price and reads as support. A bearish gap sits above it.
if show_gap_snr and gapUp >= gapMin
    f_new_snr(close[1], math.max(open, close[1]), math.min(open, close[1]), bar_index, "Gap SNR", true)

if show_gap_snr and gapDn >= gapMin
    f_new_snr(close[1], math.max(open, close[1]), math.min(open, close[1]), bar_index, "Gap SNR", false)

// --- LIFECYCLE: touch counting, role flip, strength weighting ---
if array.size(snrList) > 0
    for i = array.size(snrList) - 1 to 0
        SnrLevel s = array.get(snrList, i)
        bool alive = true

        if bar_index > s.startIdx
            // 1) BODY BREAK — through the FAR edge of the band.
            // Closing inside the junction has not broken anything: that space never traded,
            // and price sitting in it is still at the level, not past it.
            bool broken = s.isBull ? (close < s.bandLo - levelTol) : (close > s.bandHi + levelTol)
            if broken
                if show_sbr_rbs and not s.isFlipped
                    // Broken resistance becomes support, broken support becomes resistance.
                    // The level does not die; it changes role and keeps its touch history.
                    s.isBull    := not s.isBull
                    s.isFlipped := true
                    s.isFresh   := true
                    s.isTested  := false
                    s.levelType := s.isBull ? "RBS" : "SBR"
                    label.set_text(s.labelId, s.isBull ? "RBS" : "SBR")
                else
                    line.delete(s.lineId)
                    label.delete(s.labelId)
                    array.remove(snrList, i)
                    alive := false
            // 2) WICK TOUCH: only counts if price left the level first.
            //    Price hovering at a level must not inflate the counter; a reversal is leave-and-return.
            // A near miss counts: turning just short of the level is still a touch.
            // Measured against the BAND. Reaching either edge of the close-to-open junction
            // is reaching the level; there is nothing between them that price has to cross.
            else if high >= s.bandLo - safeAtr * snr_touch_tol and low <= s.bandHi + safeAtr * snr_touch_tol
                if s.awayOk and (bar_index - s.lastTouchIdx) > snr_touch_cd
                    s.touches      := s.touches + 1
                    s.lastTouchIdx := bar_index
                    s.awayOk       := false
                    s.pendingBar   := bar_index   // the candle that hit the level; the marker goes here
                if s.isFresh
                    s.isFresh  := false
                    s.isTested := true

            // 2B) THE MISS.
            // "A MISS is when an SNR forms and price moves away, but the following candles'
            // wicks fail to touch the level. The Miss validates an SNR Level."
            // Price came for the level, turned before reaching it, and left the level behind
            // untouched. In the doctrine that does not weaken the level, it PROVES it: the
            // liquidity sitting there was never taken, so it is all still there. A missed
            // level is worth more than one that has already been tapped, and the engine was
            // counting the opposite way round by only ever rewarding touches.
            // The approach has to be a real one. A swing that turns halfway across the chart
            // is not a miss, it is unrelated price action, so the turn has to land inside a
            // window near the level and outside the tolerance that would have made it a touch.
            else if snr_count_miss
                float missNear = safeAtr * snr_miss_atr
                float missFar  = safeAtr * snr_touch_tol
                // Measured from the edge price would have had to reach, not the middle of
                // the band. Falling short is falling short of the near side.
                bool approached = s.isBull ? (not na(pl) and pl > s.bandHi + missFar and pl <= s.bandHi + missNear) : (not na(ph) and ph < s.bandLo - missFar and ph >= s.bandLo - missNear)
                if approached and s.awayOk and (na(s.lastMissIdx) or (bar_index - s.lastMissIdx) > snr_touch_cd)
                    s.misses      := s.misses + 1
                    s.lastMissIdx := bar_index
                    s.awayOk      := false

            // 3) DEPARTURE TRACKING: once price leaves far enough, the next return can count.
            if not s.awayOk and math.abs(close - s.levelPrice) > safeAtr * snr_away_atr
                s.awayOk := true

        if alive and barstate.islast
            color base    = s.isBull ? WONRA_BULL : WONRA_BEAR
            float distAtr = math.abs(close - s.levelPrice) / safeAtr
            bool  tooFar  = snr_max_dist_atr > 0 and distAtr > snr_max_dist_atr

            // STRENGTH TIERS. Touches AND misses set the visual weight, because the doctrine
            // treats both as confirmation: a level price reached and respected is proven, and
            // so is one price turned back from without ever reaching. Counting only touches
            // left the strongest levels on the chart looking like the weakest.
            int proof  = s.touches + s.misses
            int transp = proof >= 3 ? 0 : proof == 2 ? 35 : 75
            int width  = proof >= 3 ? 2 : 1
            if s.isFlipped
                transp := math.max(0, transp - 15)   // flipped levels carry extra significance

            // A LEVEL AGAINST THE STORYLINE IS A ROADBLOCK, NOT NOISE.
            // "Roadblocks to a storyline are areas of interest found one timeframe lower.
            //  Before price completes its storyline, it will be bouncing from support and
            //  resistance found 1 TF lower."
            // These are where the pullbacks stop. Fading them was throwing away the one
            // thing the doctrine says to expect on the way, and hiding them meant the trader
            // walked into every bounce blind. Marked instead, so they can be read for what
            // they are: a pause in the story, not a contradiction of it.
            bool isRoadblock = f_stl_opposes(s.isBull)
            if isRoadblock
                transp := storyline_mode == "Hide Opposite" ? 100 : storyline_mode == "Mark As Roadblock" ? transp : math.min(100, transp + 30)

            if tooFar or proof < snr_min_touches
                transp := 100
            if s.isTested and hide_tested_snr and proof < 2
                transp := 100

            line.set_x2(s.lineId, bar_index + snr_extend_bars)
            line.set_color(s.lineId, color.new(base, transp))
            line.set_width(s.lineId, width)
            label.set_x(s.labelId, bar_index + snr_extend_bars)
            // Minimal: only levels with 3+ touches carry text, and only the count.
            string baseTag = s.levelType == "Gap SNR" ? "OCL" : s.levelType == "RBS" ? "RBS" : s.levelType == "SBR" ? "SBR" : s.isBull ? "S" : "R"
            // Misses are shown apart from touches. Two levels can both read "×3" and mean
            // very different things: three taps have spent the liquidity, three misses have
            // left every bit of it sitting there.
            string missTag = s.misses > 0 ? " ⌀" + str.tostring(s.misses) : ""
            string rbTag   = isRoadblock and storyline_mode == "Mark As Roadblock" ? " RB" : ""
            // Every line says what it is. Minimal mode used to leave weaker levels with no
            // text at all, which left a chart of horizontal lines and no way to tell an
            // untested support from a support that had already turned into a resistance.
            // The name is two or three characters; it is the count that gets dropped when
            // things need to be quiet, not the identity of the line.
            string lblTxt  = vMin ? (proof >= 3 ? baseTag + " ×" + str.tostring(s.touches) + missTag + rbTag : baseTag + rbTag) : proof >= 2 ? baseTag + " ×" + str.tostring(s.touches) + missTag + rbTag : baseTag + rbTag
            label.set_text(s.labelId, lblTxt)
            label.set_textcolor(s.labelId, color.new(base, transp))

// ============================================================================
// 9B. LEVEL REACTION MARKER (standalone)
// ============================================================================
// The other three signals all require an active pattern around them.
// A reaction from a proven level is meaningful on its own: price touches a
// well-tested level and closes back on the right side.
var bool snrReactBull = false
var bool snrReactBear = false
snrReactBull := false
snrReactBear := false

// Last signal bar per direction, so stacked levels do not each fire on
// the same turn. One reversal, one marker.
var int lastSigBullBar = na
var int lastSigBearBar = na

// Diagnostic counters: answers why a marker was or was not placed.
var int dbgWeak     = 0   // level was still below threshold when price hit it
var int dbgNoConf   = 0   // hit the level but no confirmation arrived in the window
var int dbgCooldown = 0   // confirmed but suppressed by the direction cooldown
var int dbgFired    = 0   // marker placed

if show_snr_reaction and barstate.isconfirmed and array.size(snrList) > 0
    for i = 0 to array.size(snrList) - 1
        SnrLevel s = array.get(snrList, i)
        if not na(s.pendingBar)
            int age = bar_index - s.pendingBar
            // Level not proven yet: drop the record so it does not linger.
            if (s.touches + s.misses) < snr_react_touches
                dbgWeak += 1
                s.pendingBar := int(na)
            else if age > snr_confirm_win
                dbgNoConf += 1
                s.pendingBar := int(na)          // confirmation window expired
            else if f_ftb_reaction(s.isBull, s.levelPrice, float(na), float(na))
                bool cdOk = s.isBull ? (na(lastSigBullBar) or (bar_index - lastSigBullBar) > sig_cooldown) : (na(lastSigBearBar) or (bar_index - lastSigBearBar) > sig_cooldown)
                if not cdOk
                    dbgCooldown += 1
                if cdOk
                    // The marker goes on the candle that hit the level, even if confirmation was late.
                    int off = bar_index - s.pendingBar
                    float ry = off >= 0 and off < 500 ? (s.isBull ? low[off] : high[off]) : (s.isBull ? low : high)
                    label.new(s.pendingBar, s.isBull ? ry - markerOff : ry + markerOff, "◆", style=label.style_none, textcolor=f_mcol(s.isBull), size=size.tiny, tooltip="Reaction from a proven level — " + s.levelType + " ×" + str.tostring(s.touches) + " touches, " + str.tostring(s.misses) + " misses (" + (s.isBull ? "bullish" : "bearish") + ")")
                    s.lastSignalIdx := s.pendingBar
                    dbgFired += 1
                    if s.isBull
                        snrReactBull := true
                        lastSigBullBar := bar_index
                    else
                        snrReactBear := true
                        lastSigBearBar := bar_index
                s.pendingBar := int(na)

// ============================================================================
// 10. TRENDLINE ENGINE (broken lines extend forward for a possible retest)
// ============================================================================
var line[] pivot_high_array = array.new_line()
var line[] pivot_low_array  = array.new_line()
var line[] broken_tl_array  = array.new_line()

// Broken trendline store: the oldest beyond the limit are removed.
prune_broken_tl() =>
    while array.size(broken_tl_array) > max_broken_tl
        line old = array.pop(broken_tl_array)
        line.delete(old)

int pivLen_L = tl_pivot_len

// THE PIVOT IS PICKED FROM THE SAME SERIES THE LINE IS DRAWN FROM.
// It was not. The pivot was chosen by the WICK while the line anchored to the BODY, which
// are two different measurements, and they do not always point at the same candle. A bar
// can have the lowest wick on the chart while the bar beside it has a lower body. The wick
// won the selection, the body was then used for the anchor, and the line ended up holding a
// body sitting in mid range with a lower one right next to it. Rare, and absurd when it
// happens. One series decides both now.
float tlHiSrc = tl_use_close ? math.max(open, close) : high
float tlLoSrc = tl_use_close ? math.min(open, close) : low

ph_tl_raw = ta.pivothigh(tlHiSrc, pivLen_L, pivLen_L)
pl_tl_raw = ta.pivotlow(tlLoSrc, pivLen_L, pivLen_L)

var float prev_close_H = na, var float curr_close_H = na
var float prev_close_L = na, var float curr_close_L = na

var int X_prev_low = na, var float Y_prev_low = na, var int X_curr_low = na, var float Y_curr_low = na
var int X_curr_high = na, var float Y_curr_high = na, var int X_prev_high = na, var float Y_prev_high = na

var float activeUpperTL = na
var float activeLowerTL = na

if not na(pl_tl_raw)
    X_prev_low := X_curr_low, Y_prev_low := Y_curr_low, prev_close_L := curr_close_L
    X_curr_low := bar_index[pivLen_L], Y_curr_low := tlLoSrc[pivLen_L], curr_close_L := close[pivLen_L]
    if Y_prev_low < Y_curr_low and show_trendlines and Y_curr_low > prev_close_L
        line nl = line.new(X_prev_low, Y_prev_low, X_curr_low, Y_curr_low, extend=extend.right, color=color.new(WONRA_GRAY, 20), width=1, style=line.style_solid)
        array.unshift(pivot_low_array, nl)

if not na(ph_tl_raw)
    X_prev_high := X_curr_high, Y_prev_high := Y_curr_high, prev_close_H := curr_close_H
    X_curr_high := bar_index[pivLen_L], Y_curr_high := tlHiSrc[pivLen_L], curr_close_H := close[pivLen_L]
    if Y_prev_high > Y_curr_high and show_trendlines and prev_close_H > Y_curr_high
        line nh = line.new(X_prev_high, Y_prev_high, X_curr_high, Y_curr_high, extend=extend.right, color=color.new(WONRA_GRAY, 20), width=1, style=line.style_solid)
        array.unshift(pivot_high_array, nh)

// Track breaks on active trendlines and manage retest extension.
if array.size(pivot_high_array) > 0
    for i = array.size(pivot_high_array) - 1 to 0
        line l = array.get(pivot_high_array, i)
        float x1 = line.get_x1(l), float y1 = line.get_y1(l)
        float x2 = line.get_x2(l), float y2 = line.get_y2(l)
        float slope = (x2 == x1) ? 0.0 : (y2 - y1) / (x2 - x1)
        float curY = y2 + slope * (bar_index - x2)
        activeUpperTL := curY
        if close > curY
            // Extend forward for a possible retest after the break.
            line.set_extend(l, extend.none)
            int targetX = bar_index + tl_extend_bars
            line.set_x2(l, targetX)
            line.set_y2(l, y2 + slope * (targetX - x2))
            line.set_color(l, color.new(WONRA_BULL, 50))
            line.set_style(l, line.style_solid)
            array.remove(pivot_high_array, i)
            if show_broken_tl
                array.unshift(broken_tl_array, l)
                prune_broken_tl()
            else
                line.delete(l)

if array.size(pivot_low_array) > 0
    for i = array.size(pivot_low_array) - 1 to 0
        line l = array.get(pivot_low_array, i)
        float x1 = line.get_x1(l), float y1 = line.get_y1(l)
        float x2 = line.get_x2(l), float y2 = line.get_y2(l)
        float slope = (x2 == x1) ? 0.0 : (y2 - y1) / (x2 - x1)
        float curY = y2 + slope * (bar_index - x2)
        activeLowerTL := curY
        if close < curY
            // Extend forward for a possible retest after the break.
            line.set_extend(l, extend.none)
            int targetX = bar_index + tl_extend_bars
            line.set_x2(l, targetX)
            line.set_y2(l, y2 + slope * (targetX - x2))
            line.set_color(l, color.new(WONRA_BEAR, 50))
            line.set_style(l, line.style_solid)
            array.remove(pivot_low_array, i)
            if show_broken_tl
                array.unshift(broken_tl_array, l)
                prune_broken_tl()
            else
                line.delete(l)

// --- CONFLUENCE DETECTION: level meets trendline ---
var bool point3ConfluenceBull = false
var bool point3ConfluenceBear = false
point3ConfluenceBull := false
point3ConfluenceBear := false

if show_point3 and array.size(qmlActive) > 0
    float maxTol = safeAtr * conf_dist_atr
    for i = 0 to array.size(qmlActive) - 1
        QMLPattern q = array.get(qmlActive, i)
        if q.isFresh
            if not q.isBull and not na(activeUpperTL) and math.abs(q.qmlLevel - activeUpperTL) <= maxTol
                if high >= q.qmlLevel - maxTol and low <= q.qmlLevel + maxTol
                    point3ConfluenceBear := true
                    box.new(bar_index - 2, q.qmlLevel + (safeAtr * 0.15), bar_index + 15, q.qmlLevel - (safeAtr * 0.15), bgcolor=color.new(WONRA_BEAR, 80), border_color=WONRA_BEAR, border_width=1)
                    break

            if q.isBull and not na(activeLowerTL) and math.abs(q.qmlLevel - activeLowerTL) <= maxTol
                if low <= q.qmlLevel + maxTol and high >= q.qmlLevel - maxTol
                    point3ConfluenceBull := true
                    box.new(bar_index - 2, q.qmlLevel + (safeAtr * 0.15), bar_index + 15, q.qmlLevel - (safeAtr * 0.15), bgcolor=color.new(WONRA_BULL, 80), border_color=WONRA_BULL, border_width=1)
                    break

// --- THE POI POOL IS FOUR THINGS, NOT ONE ---
// "No POI, no trade. If there is no valid and fresh POI on the trendline (Point of
//  Interest: OCL, SBR, QM, OB) a trade is NEVER taken."
// The rule was already being honoured: a trendline touch on its own produced nothing, and
// it still does. What was wrong is the pool. Only a Quasimodo counted, so a trendline
// arriving on a fresh OCL, or on a support that had become a resistance, produced nothing
// at all, and those are two of the four the method names. Every one of them already exists
// in this engine, labelled on the chart. They were simply never asked about.
// Freshness is the doctrine's own condition: Press is an untouched level, Unpress is one
// already worked through and worth less. Only Press counts here.
if snr_tl_confluence and array.size(snrList) > 0
    float snrTol = safeAtr * conf_dist_atr
    for i = 0 to array.size(snrList) - 1
        SnrLevel s = array.get(snrList, i)
        int  proofS = s.touches + s.misses
        bool eligible = s.isFresh and proofS >= snr_tl_min_proof
        if eligible and not point3ConfluenceBear and not s.isBull and not na(activeUpperTL) and math.abs(s.levelPrice - activeUpperTL) <= snrTol
            if high >= s.levelPrice - snrTol and low <= s.levelPrice + snrTol
                point3ConfluenceBear := true
                label.new(bar_index, s.levelPrice + markerOff, "TL×" + s.levelType, style=label.style_none, textcolor=WONRA_BEAR, size=size.tiny, tooltip="Trendline meeting a fresh " + s.levelType + ". The POI the method requires before a trendline is worth anything.")
        if eligible and not point3ConfluenceBull and s.isBull and not na(activeLowerTL) and math.abs(s.levelPrice - activeLowerTL) <= snrTol
            if low <= s.levelPrice + snrTol and high >= s.levelPrice - snrTol
                point3ConfluenceBull := true
                label.new(bar_index, s.levelPrice - markerOff, "TL×" + s.levelType, style=label.style_none, textcolor=WONRA_BULL, size=size.tiny, tooltip="Trendline meeting a fresh " + s.levelType + ". The POI the method requires before a trendline is worth anything.")

// ============================================================================
// 11. QML DETECTION & DRAWING
// ============================================================================
f_draw_qml_structure(QMLPattern p) =>
    color baseColor = p.isBull ? WONRA_BULL : WONRA_BEAR
    int qmlStart = p.isBull ? p.l1i : p.h1i
    int qmlEnd   = bar_index + snr_extend_bars

    // THE ZONE SITS ON ONE SIDE OF THE LEVEL, NOT ASTRIDE IT.
    // On the cheat sheet a supply zone is drawn from the QM level UPWARD and a demand zone
    // DOWNWARD. Drawing it symmetrically put half the zone on the wrong side, so price
    // counted as having reached the zone while it was still short of the level, and the
    // reaction was being read before the level had been touched at all.
    float zt = p.isBull ? p.qmlLevel : p.qmlLevel + (safeAtr * qml_zone_atr_mult)
    float zb = p.isBull ? p.qmlLevel - (safeAtr * qml_zone_atr_mult) : p.qmlLevel

    // ONE BOX PER AREA, NOT ONE PER PATTERN.
    // This is what made the zones unreadable and got them switched off altogether. Several
    // patterns can hold levels a fraction apart, each drawing its own box, and a stack of
    // them is a solid block of colour that hides the candles it is meant to describe. The
    // area is the same area however many patterns found it, so the second one to arrive
    // draws its line and its name and leaves the shading to the first. The pattern is still
    // fully alive: it is counted, scored, and reacts on its own.
    bool zoneCovered = false
    if array.size(qmlActive) > 0
        for zi = 0 to array.size(qmlActive) - 1
            QMLPattern zq = array.get(qmlActive, zi)
            if not na(zq.zoneBox) and zq.isBull == p.isBull
                float ov = math.min(zt, zq.zoneTop) - math.max(zb, zq.zoneBot)
                float sm = math.min(zt - zb, zq.zoneTop - zq.zoneBot)
                if ov > 0 and sm > 0 and (ov / sm) >= qml_zone_merge / 100.0
                    zoneCovered := true

    box bZone = na
    if show_qml_zone and qml_zone_mode != "Line" and not zoneCovered
        // Minimal: plain box | Normal: grade | Detailed: score and grade
        // The box says what it IS, in the middle of itself. It used to carry a grade tucked
        // against its right edge, so a chart full of these was a chart full of unnamed boxes
        // that had to be told apart from the engulfing zones, the imbalances and the levels
        // by colour alone. Now it reads QML where you are looking, and the fill drops back
        // far enough that a stack of them no longer buries the candles.
        string boxTxt = vDet ? ("QML " + str.tostring(p.score) + (show_grade ? " " + f_grade(p.score) : "")) : vMin ? "QML" : ("QML" + (show_grade ? " " + f_grade(p.score) : ""))
        bZone := box.new(qmlStart, zt, qmlEnd, zb, border_color=color.new(baseColor, vMin ? 82 : 68), bgcolor=color.new(baseColor, vMin ? 96 : 93), border_width=1, text=boxTxt, text_color=color.new(baseColor, 30), text_size=size.tiny, text_halign=text.align_center, text_valign=text.align_center)
        p.zoneBox := bZone

    p.qmlLine := line.new(qmlStart, p.qmlLevel, qmlEnd, p.qmlLevel, color=baseColor, width=1, style=line.style_solid)
    // The QM level has a name in the method and the line never carried it. It is the LEFT
    // SHOULDER, and that is the point of interest the entry is taken from, so the line says
    // LS. Without it a chart with several of these is a set of unnamed horizontals sitting
    // among the SNR levels, indistinguishable from them.
    p.qmlLabel := label.new(qmlEnd, p.qmlLevel, "LS", style=label.style_label_left, color=CLEAR, textcolor=color.new(baseColor, 20), size=size.tiny, tooltip="Quasimodo left shoulder - the level the QM entry is taken from")

    // DEBUG SKELETON: the five points the pattern was assembled from, joined in order.
    // Bearish reads low, SHOULDER, low, HEAD, break. Bullish is the mirror. If a level looks
    // wrong on the chart this is the argument the engine is making for it, drawn out, and
    // either the shape is there or it is not.
    // Drawn DASHED and in a colour of its own, and every point is named. Sharing the swing
    // engine's colour made the skeleton indistinguishable from the zigzag already on the
    // chart, which is no help at all: the whole question is which points the engine chose,
    // and that is only answered by writing the answer next to them.
    if show_qml_skeleton
        color sk = color.new(#7C4DFF, 15)
        if p.isBull
            array.push(qmlSkel, line.new(p.h2i, p.h2, p.l1i, p.l1, color=sk, width=2, style=line.style_dashed))
            array.push(qmlSkel, line.new(p.l1i, p.l1, p.h1i, p.h1, color=sk, width=2, style=line.style_dashed))
            array.push(qmlSkel, line.new(p.h1i, p.h1, p.l0i, p.l0, color=sk, width=2, style=line.style_dashed))
            array.push(qmlSkel, line.new(p.l0i, p.l0, p.h0i, p.h0, color=sk, width=2, style=line.style_dashed))
            array.push(qmlSkelLb, label.new(p.l1i, p.l1, "LS",   style=label.style_label_up,   color=CLEAR, textcolor=sk, size=size.tiny))
            array.push(qmlSkelLb, label.new(p.h1i, p.h1, "NECK", style=label.style_label_down, color=CLEAR, textcolor=sk, size=size.tiny))
            array.push(qmlSkelLb, label.new(p.l0i, p.l0, "HEAD", style=label.style_label_up,   color=CLEAR, textcolor=sk, size=size.tiny))
            array.push(qmlSkelLb, label.new(p.h0i, p.h0, "BOS",  style=label.style_label_down, color=CLEAR, textcolor=sk, size=size.tiny))
        else
            array.push(qmlSkel, line.new(p.l2i, p.l2, p.h1i, p.h1, color=sk, width=2, style=line.style_dashed))
            array.push(qmlSkel, line.new(p.h1i, p.h1, p.l1i, p.l1, color=sk, width=2, style=line.style_dashed))
            array.push(qmlSkel, line.new(p.l1i, p.l1, p.h0i, p.h0, color=sk, width=2, style=line.style_dashed))
            array.push(qmlSkel, line.new(p.h0i, p.h0, p.l0i, p.l0, color=sk, width=2, style=line.style_dashed))
            array.push(qmlSkelLb, label.new(p.h1i, p.h1, "LS",   style=label.style_label_down, color=CLEAR, textcolor=sk, size=size.tiny))
            array.push(qmlSkelLb, label.new(p.l1i, p.l1, "NECK", style=label.style_label_up,   color=CLEAR, textcolor=sk, size=size.tiny))
            array.push(qmlSkelLb, label.new(p.h0i, p.h0, "HEAD", style=label.style_label_down, color=CLEAR, textcolor=sk, size=size.tiny))
            array.push(qmlSkelLb, label.new(p.l0i, p.l0, "BOS",  style=label.style_label_up,   color=CLEAR, textcolor=sk, size=size.tiny))
        while array.size(qmlSkel) > skel_max * 4
            line.delete(array.shift(qmlSkel))
        while array.size(qmlSkelLb) > skel_max * 4
            label.delete(array.shift(qmlSkelLb))

    // APEX: the head of the QM, and the seventh of the doctrine's seven levels. It was the
    // only one the engine knew about and never drew. It is not an entry, it is the barrier
    // behind the entry: the price the pattern failed at, and the last place the idea is
    // still alive. Drawn thinner and fainter than the shoulder so the two are not confused.
    if show_apex and not na(p.headLevel)
        p.apexLine  := line.new(qmlStart, p.headLevel, qmlEnd, p.headLevel, color=color.new(baseColor, 45), width=1, style=line.style_dotted)
        p.apexLabel := label.new(qmlEnd, p.headLevel, "APEX", style=label.style_label_left, color=CLEAR, textcolor=color.new(baseColor, 45), size=size.tiny, tooltip="Quasimodo head - the strongest barrier of the pattern, and where the idea dies")

// --- Diagnostic counters ---
// An array, not scalars: globals cannot be assigned from inside a function
// but arrays are references, so their contents can be mutated.
// 0=Size 1=BOS 2=Fresh 3=Score 4=Dup 5=Found 6=Side 7=Shape 8=Context
// The last three are the conditions added while fixing the levels that were landing in odd
// places. They belong in the trace for the same reason the others do: when a structure is
// plainly on the chart and no pattern comes out of it, the only useful question is which
// gate ate it, and guessing at that has cost more time here than anything else.
var array<int> rejCnt = array.new<int>(9, 0)

f_bump(int idx) =>
    array.set(rejCnt, idx, array.get(rejCnt, idx) + 1)

// --- PATTERN CANDIDATE FUNCTIONS ---
// Separate functions so the same structure can be tried against different
// swing combinations, letting minor swings be skipped and read as one move.
// This is how these patterns are read by eye: noise is ignored if the shape holds.

// SKIPPING A SWING IS FINE. SKIPPING THE ONE THAT BREAKS THE SHAPE IS NOT.
// The combination scan is gone, but the same reasoning applies to adjacent swings too: it
// was free to jump over a swing that contradicts the very structure being claimed: a
// "shoulder" with a HIGHER high sitting between it and the head is not a shoulder, it is an
// earlier high buried under a bigger one, and the real shoulder is the high that was jumped
// over. Same for the neck: if a lower low sits inside the span, that low is the neck.
// This checks the span between the shoulder and the head and refuses the pattern when a
// swing in there makes a better claim to one of the roles than the point chosen for it.
f_shape_clean(bool isBull, int fromIdx, int toIdx, float shoulder, float neck) =>
    bool ok = true
    if array.size(swings) > 0
        for i = 0 to array.size(swings) - 1
            SwingPoint s = array.get(swings, i)
            if s.index > fromIdx and s.index < toIdx
                if isBull
                    // Bullish: shoulder is a low, neck is the high between it and the head.
                    if s.dir == -1 and s.price < shoulder
                        ok := false
                    if s.dir == 1 and s.price > neck
                        ok := false
                else
                    if s.dir == 1 and s.price > shoulder
                        ok := false
                    if s.dir == -1 and s.price < neck
                        ok := false
    ok

f_try_bull_qml(SwingPoint a0, SwingPoint a1, SwingPoint a2, SwingPoint a3, SwingPoint a4) =>
    bool chronOk = a0.index < a1.index and a1.index < a2.index and a2.index < a3.index and a3.index < a4.index
    if chronOk and a0.dir == -1 and a1.dir == 1 and a2.dir == -1 and a3.dir == 1 and a4.dir == -1
        float l2v = a0.price, float h2v = a1.price
        float l1v = a2.price, float h1v = a3.price
        float l0v = a4.price
        int l2bi = a0.index, int h2bi = a1.index
        int l1bi = a2.index, int h1bi = a3.index, int l0bi = a4.index

        // THE PATTERN NEEDS SOMETHING TO REVERSE.
        // The reference implementation demands h2 > h1: the high BEFORE the shoulder has to
        // sit above the neck. That makes the highs descending into the pattern, which is the
        // downtrend a bullish Quasimodo is supposed to end. Without it the shape could be
        // assembled anywhere, including in the middle of a rally where there is nothing to
        // turn, and that is where the levels appearing in odd places were coming from.
        bool contextOk = not require_qm_context or h2v > h1v
        bool sweptLow = l0v < l1v
        bool sizeOk   = math.abs(h2v - l0v) >= f_atr_lookup(l0bi) * min_struct_atr

        // Cheap structural tests first; the expensive scan only runs when needed.
        if sweptLow and not contextOk
            f_bump(8)
        if sweptLow and contextOk and not sizeOk
            f_bump(0)

        if sweptLow and contextOk and sizeOk
            [bosOk, bosBody, bosDepth, bosQ, bosIdx, bosPrice] = f_bos_check(true, h1v, l0bi)
            bool freshOkB = f_is_fresh(l1v, true)

            if not bosOk
                f_bump(1)
            else if not freshOkB
                f_bump(2)

            // PRICE HAS TO BE ON THE RIGHT SIDE OF THE SHOULDER RIGHT NOW.
            // The break is found by scanning forward from the head, so it can already be
            // many bars old by the time the pattern is registered on the current bar. In
            // between, price can have recovered straight back through the shoulder. Marking
            // it then puts a level where price has already gone: not something waiting to be
            // retested, just a price that has been left behind. The reference version of
            // this pattern makes the same demand, and it is the condition that was missing.
            bool sideOkB  = close > l1v
            bool shapeOkB = f_shape_clean(true, l1bi, l0bi, l1v, h1v)
            if bosOk and freshOkB and not sideOkB
                f_bump(6)
            if bosOk and freshOkB and sideOkB and not shapeOkB
                f_bump(7)
            if bosOk and freshOkB and sideOkB and shapeOkB
                float directSweepQ = f_direct_sweep_quality(l1v, true, l0bi)
                float poolSweepQ   = f_pool_sweep_quality(l1v, true, l0bi)
                float fvgQ         = f_fvg_quality(l1v, true, l0bi, bar_index)
                int score = f_compute_score(true, l0bi, bosIdx, l1bi, l0bi, l1v, l0v, directSweepQ, poolSweepQ, fvgQ, bosQ)

                if score < effectiveMinScore
                    f_bump(3)
                else
                    bool isDuplicate = false
                    if array.size(qmlActive) > 0
                        for k = 0 to array.size(qmlActive) - 1
                            QMLPattern existP = array.get(qmlActive, k)
                            if existP.isBull and math.abs(existP.qmlLevel - l1v) <= safeAtr * 0.15
                                isDuplicate := true
                                break

                    if isDuplicate
                        f_bump(4)
                    else
                        QMLPattern pat = QMLPattern.new(true, h2v, h1v, bosPrice, l2v, l1v, l0v, h2bi, h1bi, bosIdx, l2bi, l1bi, bosIdx, l1v, l0v, l0v, h1v, bosIdx, bosBody, l1v, l0bi, bar_index, score, true, false, int(na), l1v, l1v - safeAtr * qml_zone_atr_mult, na, na, na, false, na, na)
                        f_draw_qml_structure(pat)
                        array.unshift(qmlActive, pat)
                        f_mark_used(l1v, true)
                        f_bump(5)

f_try_bear_qml(SwingPoint a0, SwingPoint a1, SwingPoint a2, SwingPoint a3, SwingPoint a4) =>
    bool chronOk = a0.index < a1.index and a1.index < a2.index and a2.index < a3.index and a3.index < a4.index
    if chronOk and a0.dir == 1 and a1.dir == -1 and a2.dir == 1 and a3.dir == -1 and a4.dir == 1
        float h2v = a0.price, float l2v = a1.price
        float h1v = a2.price, float l1v = a3.price
        float h0v = a4.price
        int h2bi = a0.index, int l2bi = a1.index
        int h1bi = a2.index, int l1bi = a3.index, int h0bi = a4.index

        // Mirror of the bullish context rule: the low before the shoulder must sit below the
        // neck, so the lows are ascending into the pattern. That is the uptrend a bearish
        // Quasimodo ends.
        bool contextOk = not require_qm_context or l2v < l1v
        bool sweptHigh = h0v > h1v
        bool sizeOk    = math.abs(h0v - l2v) >= f_atr_lookup(h0bi) * min_struct_atr

        if sweptHigh and not contextOk
            f_bump(8)
        if sweptHigh and contextOk and not sizeOk
            f_bump(0)

        if sweptHigh and contextOk and sizeOk
            [bosOk, bosBody, bosDepth, bosQ, bosIdx, bosPrice] = f_bos_check(false, l1v, h0bi)
            bool freshOkS = f_is_fresh(h1v, false)

            if not bosOk
                f_bump(1)
            else if not freshOkS
                f_bump(2)

            // Same requirement, mirrored: price must be under the shoulder for the shoulder
            // to be resistance overhead. Above it there is nothing to sell into.
            bool sideOkS  = close < h1v
            bool shapeOkS = f_shape_clean(false, h1bi, h0bi, h1v, l1v)
            if bosOk and freshOkS and not sideOkS
                f_bump(6)
            if bosOk and freshOkS and sideOkS and not shapeOkS
                f_bump(7)
            if bosOk and freshOkS and sideOkS and shapeOkS
                float directSweepQ = f_direct_sweep_quality(h1v, false, h0bi)
                float poolSweepQ   = f_pool_sweep_quality(h1v, false, h0bi)
                float fvgQ         = f_fvg_quality(h1v, false, h0bi, bar_index)
                int score = f_compute_score(false, h0bi, bosIdx, h1bi, h0bi, h1v, h0v, directSweepQ, poolSweepQ, fvgQ, bosQ)

                if score < effectiveMinScore
                    f_bump(3)
                else
                    bool isDuplicate = false
                    if array.size(qmlActive) > 0
                        for k = 0 to array.size(qmlActive) - 1
                            QMLPattern existP = array.get(qmlActive, k)
                            if not existP.isBull and math.abs(existP.qmlLevel - h1v) <= safeAtr * 0.15
                                isDuplicate := true
                                break

                    if isDuplicate
                        f_bump(4)
                    else
                        QMLPattern pat = QMLPattern.new(false, h2v, h1v, h0v, l2v, l1v, bosPrice, h2bi, h1bi, h0bi, l2bi, l1bi, bosIdx, h1v, h0v, h0v, l1v, bosIdx, bosBody, h1v, h0bi, bar_index, score, true, false, int(na), h1v + safeAtr * qml_zone_atr_mult, h1v, na, na, na, false, na, na)
                        f_draw_qml_structure(pat)
                        array.unshift(qmlActive, pat)
                        f_mark_used(h1v, false)
                        f_bump(5)

// --- DRIVER: the last five swings, in order ---
// The Quasimodo is a sequence: shoulder, neck, head, break. It is read from the five most
// recent swings and nothing else. The combination scan that used to sit here could step over
// intermediate swings, and stepping over the wrong one produced a shoulder joined to a neck
// by a line that passed straight above the deepest low in the span, which was the real head.
int swSzFull = array.size(swings)
if barstate.isconfirmed and swSzFull >= 5
    int lastI = swSzFull - 1
    SwingPoint p0 = array.get(swings, lastI - 4)
    SwingPoint p1 = array.get(swings, lastI - 3)
    SwingPoint p2 = array.get(swings, lastI - 2)
    SwingPoint p3 = array.get(swings, lastI - 1)
    SwingPoint p4 = array.get(swings, lastI)
    f_try_bull_qml(p0, p1, p2, p3, p4)
    f_try_bear_qml(p0, p1, p2, p3, p4)

// ============================================================================
// 11B. SHOULDER ENTRY (turn at a level without reaching the zone)
// ============================================================================
// Doktrin (10X QML "QML SNR + Key Level" / Emperor "Confluence SNR+TL"):
// Price does not always return to the zone. If the turn lands on a proven
// level instead, that level takes over the role of the zone.
var bool shoulderBull = false
var bool shoulderBear = false
shoulderBull := false
shoulderBear := false

// Is there a proven level at this price? Returns its touch count, 0 if none.
f_snr_at(float px, bool wantSupport) =>
    int best = 0
    if array.size(snrList) > 0
        for i = 0 to array.size(snrList) - 1
            SnrLevel s = array.get(snrList, i)
            if s.isBull == wantSupport and math.abs(s.levelPrice - px) <= snrClusterTol and (s.touches + s.misses) > best
                best := s.touches + s.misses
    best

if use_shoulder_entry and barstate.isconfirmed and array.size(qmlActive) > 0
    // A newly confirmed low: could it be the shoulder of an active bullish setup?
    if not na(pl)
        for i = 0 to array.size(qmlActive) - 1
            QMLPattern q = array.get(qmlActive, i)
            if not shoulderBull and q.isFresh and q.isBull and plIdx > q.bosIndex
                // Tolerance at the edge, so a level sitting right on the boundary is not dropped.
                float band = q.qmlLevel + (q.bosLevel - q.qmlLevel) * shoulder_band + snrClusterTol
                if pl > q.qmlLevel and pl <= band
                    int snrT = f_snr_at(pl, true)
                    if snrT >= shoulder_min_snr
                        shoulderBull := true
                        label.new(plIdx, pl - markerOff, vDet ? "■ QM×SNR ×" + str.tostring(snrT) : "■", style=label.style_none, textcolor=f_mcol(true), size=size.tiny, tooltip="Shoulder entry — turned at a proven level without reaching the zone")
                        // A record that the zone worked, not an offer. Anchored at the swing and
                        // faint, so it reads as "this held here" rather than "this is live".
                        if not vMin
                            box.new(plIdx - 2, pl + safeAtr * 0.20, plIdx + 14, pl - safeAtr * 0.20, bgcolor=color.new(WONRA_BULL, 88), border_color=color.new(WONRA_BULL, 45), border_width=1)

    // A newly confirmed high: could it be the shoulder of an active bearish setup?
    if not na(ph)
        for i = 0 to array.size(qmlActive) - 1
            QMLPattern q = array.get(qmlActive, i)
            if not shoulderBear and q.isFresh and not q.isBull and phIdx > q.bosIndex
                float band = q.qmlLevel - (q.qmlLevel - q.bosLevel) * shoulder_band - snrClusterTol
                if ph < q.qmlLevel and ph >= band
                    int snrT = f_snr_at(ph, false)
                    if snrT >= shoulder_min_snr
                        shoulderBear := true
                        label.new(phIdx, ph + markerOff, vDet ? "■ QM×SNR ×" + str.tostring(snrT) : "■", style=label.style_none, textcolor=f_mcol(false), size=size.tiny, tooltip="Shoulder entry — turned at a proven level without reaching the zone")
                        if not vMin
                            box.new(phIdx - 2, ph + safeAtr * 0.20, phIdx + 14, ph - safeAtr * 0.20, bgcolor=color.new(WONRA_BEAR, 88), border_color=color.new(WONRA_BEAR, 45), border_width=1)

// ============================================================================
// 12. FRESHNESS ENGINE & ZIKIR CYCLE MANAGER (RETEST & CLEANUP)
// ============================================================================
var int freshBullCount = 0
var int freshBearCount = 0
var bool ftbFired = false
var bool ftbFiredBull = false
freshBullCount := 0
freshBearCount := 0
ftbFired := false

if array.size(qmlActive) > 0
    for i = array.size(qmlActive) - 1 to 0
        QMLPattern q = array.get(qmlActive, i)
        if q.isFresh
            // --- STALENESS: age and distance limits remove zones that lost context ---
            bool tooOld  = qml_max_age_bars > 0 and (bar_index - q.createdBar) > qml_max_age_bars
            bool tooFarQ = qml_max_dist_atr > 0 and (math.abs(close - q.qmlLevel) / safeAtr) > qml_max_dist_atr
            bool stale   = tooOld or tooFarQ

            if stale
                if not na(q.qmlLine)
                    line.delete(q.qmlLine)
                    if not na(q.qmlLabel)
                        label.delete(q.qmlLabel)
                    if not na(q.apexLine)
                        line.delete(q.apexLine)
                    if not na(q.apexLabel)
                        label.delete(q.apexLabel)
                if not na(q.zoneBox)
                    box.delete(q.zoneBox)

                array.remove(qmlActive, i)

            // --- FLIP: a zone closed through by a body changes role ---
            // Broken resistance becomes support and vice versa. The level survives;
            // a retest from the other side is now a signal in the opposite direction.
            if not stale and not q.isFlipped and bar_index > q.bosIndex + 2
                bool brokeOpp = q.isBull ? (close < q.qmlLevel - levelTol) : (close > q.qmlLevel + levelTol)
                if brokeOpp
                    q.isBull    := not q.isBull
                    q.isFlipped := true
                    q.isFresh   := true
                    // Invalidation is redefined for the new role: a second break kills the level.
                    q.headLevel := q.qmlLevel
                    color fc = q.isBull ? WONRA_BULL : WONRA_BEAR
                    if not na(q.qmlLine)
                        line.set_color(q.qmlLine, fc)
                    if not na(q.zoneBox)
                        box.set_bgcolor(q.zoneBox, color.new(fc, vMin ? 92 : 85))
                        box.set_border_color(q.zoneBox, color.new(fc, vMin ? 70 : 50))
                        // The text lives inside the same box and has to turn with it. It did not,
                        // so a zone that flipped kept green lettering inside a red box.
                        box.set_text_color(q.zoneBox, color.new(fc, 30))


            if not stale
                if not na(q.qmlLine)
                    line.set_x2(q.qmlLine, bar_index + snr_extend_bars)
                if not na(q.zoneBox)
                    box.set_right(q.zoneBox, bar_index + snr_extend_bars)

                if q.isBull
                    freshBullCount += 1
                else
                    freshBearCount += 1

            // --- Did price return to the zone, and was it a genuine reaction? ---
            // Proximity alone is not enough; the reaction must be confirmed.
            bool inZone = q.isBull ? (low <= q.qmlLevel + (safeAtr * 0.18) and high >= q.qmlLevel - (safeAtr * 0.18)) : (high >= q.qmlLevel - (safeAtr * 0.18) and low <= q.qmlLevel + (safeAtr * 0.18))
            bool afterBos = bar_index > q.bosIndex + 2
            bool reacted  = inZone and afterBos and f_ftb_reaction(q.isBull, q.qmlLevel, q.zoneTop, q.zoneBot)
            bool retested = inZone and afterBos

            // Invalidation check, all four modes
            bool invalidated = false
            float invBuf = safeAtr * 0.15
            if invalidation_mode == "Wick Beyond Head"
                invalidated := q.isBull ? low < q.headLevel : high > q.headLevel
            else if invalidation_mode == "Close Beyond Head"
                invalidated := q.isBull ? close < q.headLevel : close > q.headLevel
            else if invalidation_mode == "ATR Buffer"
                invalidated := q.isBull ? low < q.headLevel - invBuf : high > q.headLevel + invBuf
            else if invalidation_mode == "Zone Close"
                invalidated := q.isBull ? close < nz(q.zoneBot, q.headLevel) : close > nz(q.zoneTop, q.headLevel)

            // --- THE ENTRY: this is the moment to mark, not to erase ---
            if not stale and reacted
                ftbFired := true
                ftbFiredBull := q.isBull
                // Main reversal marker is drawn later as a shape.
                // Detailed mode adds a text label as well.
                if vDet
                    label.new(bar_index, q.isBull ? low - markerOff : high + markerOff, (q.isBull ? "FTB BUY " : "FTB SELL ") + f_grade(q.score), style=label.style_none, textcolor=q.isBull ? WONRA_BULL : WONRA_BEAR, size=size.tiny)

            if not stale and (retested or invalidated)
                q.isFresh := false

                // Invalidated zones are removed; zones that reacted stay and fade, so the entry remains visible.
                // A ZONE THAT PRODUCED A MARKER IS NEVER DELETED.
                // The marker is a separate drawing and it survives on its own, so deleting
                // the zone underneath it left an entry symbol floating in empty space with
                // nothing to explain it. Nothing in the doctrine deletes a level anyway: a
                // touched level becomes UNFRESH and a broken one FLIPS its role. Neither
                // disappears. The zone stays, frozen and faded, as the record of what
                // happened there.
                bool killIt = (invalidated or (show_only_fresh and not reacted)) and not reacted
                if killIt
                    if not na(q.qmlLine)
                        line.delete(q.qmlLine)
                        if not na(q.qmlLabel)
                            label.delete(q.qmlLabel)
                        if not na(q.apexLine)
                            line.delete(q.apexLine)
                        if not na(q.apexLabel)
                            label.delete(q.apexLabel)
                    if not na(q.zoneBox)
                        box.delete(q.zoneBox)

                    array.remove(qmlActive, i)
                else if dim_non_fresh
                    // Faded, not erased. These numbers were pushed too far in one go: a line at
                    // 82 transparency is invisible at normal zoom, so a level that had done its
                    // job simply vanished and looked like a bug. Quiet is the goal, not gone.
                    // FROZEN, not merely dimmed. A zone that has been reacted to has done
                    // its job; it is a record of what happened there, not a level still
                    // being offered. It stops here — the right edge is pinned to this bar
                    // instead of being pushed forward every bar into empty space — and it
                    // fades far enough back that the eye passes over it unless it is
                    // looking for it.
                    color dc = q.isBull ? WONRA_BULL : WONRA_BEAR
                    if not na(q.qmlLine)
                        line.set_x2(q.qmlLine, bar_index)
                        line.set_color(q.qmlLine, color.new(dc, 60))
                    if not na(q.zoneBox)
                        box.set_right(q.zoneBox, bar_index)
                        box.set_bgcolor(q.zoneBox, color.new(dc, 93))
                        box.set_border_color(q.zoneBox, color.new(dc, 72))
                        box.set_text_color(q.zoneBox, color.new(dc, 45))

        else
            // A LEVEL PRICE HAS GONE THROUGH IS NOT A LEVEL.
            // Nothing used to happen to a zone once it stopped being fresh — the whole
            // branch above is gated on isFresh — so a frozen record sat on the chart for
            // the rest of the session even after price closed clean through it. The zone
            // is kept in memory (the pattern still counts, and a flip can still read it);
            // only the drawing goes.
            bool goneThrough = q.isBull ? (close < q.qmlLevel - levelTol) : (close > q.qmlLevel + levelTol)
            if goneThrough
                if not na(q.qmlLine)
                    line.delete(q.qmlLine)
                    if not na(q.qmlLabel)
                        label.delete(q.qmlLabel)
                    if not na(q.apexLine)
                        line.delete(q.apexLine)
                    if not na(q.apexLabel)
                        label.delete(q.apexLabel)
                    q.qmlLine := na
                    q.qmlLabel := na
                    q.apexLine := na
                    q.apexLabel := na
                    q.apexLine := na
                    q.apexLabel := na
                if not na(q.zoneBox)
                    box.delete(q.zoneBox)
                    q.zoneBox := na


// ============================================================================
// 12A. DRAWING BUDGET
// ============================================================================
// Past the platform limit the oldest drawings are dropped automatically, which
// can remove zones that still matter. We make the choice instead: the pattern
// stays in memory and keeps working, only the drawings of the oldest, already
// faded zones are released. Active zones are never touched.
// --- ARRAY CAP: runs every bar, critical for performance ---
// Patterns are no longer deleted on retest, so the store could grow without bound.
// Every bar runs many candidate combinations, each scanning this store for
// duplicates, so cost scales with its size and settings changes become slow.
if array.size(qmlActive) > max_active_qml
    // Drop already-used zones first
    int over = array.size(qmlActive) - max_active_qml
    for i = array.size(qmlActive) - 1 to 0
        if over > 0
            QMLPattern q = array.get(qmlActive, i)
            if not q.isFresh
                if not na(q.qmlLine)
                    line.delete(q.qmlLine)
                    if not na(q.qmlLabel)
                        label.delete(q.qmlLabel)
                    if not na(q.apexLine)
                        line.delete(q.apexLine)
                    if not na(q.apexLabel)
                        label.delete(q.apexLabel)
                if not na(q.zoneBox)
                    box.delete(q.zoneBox)

                array.remove(qmlActive, i)
                over -= 1
    // If everything is still active, enforce the cap from the oldest end.
    while array.size(qmlActive) > max_active_qml
        QMLPattern q = array.pop(qmlActive)
        if not na(q.qmlLine)
            line.delete(q.qmlLine)
            if not na(q.qmlLabel)
                label.delete(q.qmlLabel)
            if not na(q.apexLine)
                line.delete(q.apexLine)
            if not na(q.apexLabel)
                label.delete(q.apexLabel)
        if not na(q.zoneBox)
            box.delete(q.zoneBox)


if barstate.islast and array.size(qmlActive) > 0
    int drawnCount = 0
    for i = 0 to array.size(qmlActive) - 1
        QMLPattern q = array.get(qmlActive, i)
        if not na(q.qmlLine) or not na(q.zoneBox)
            drawnCount += 1

    if drawnCount > max_drawn_qml
        int toFree = drawnCount - max_drawn_qml
        for i = array.size(qmlActive) - 1 to 0
            if toFree > 0
                QMLPattern q = array.get(qmlActive, i)
                if not q.isFresh and (not na(q.qmlLine) or not na(q.zoneBox))
                    if not na(q.qmlLine)
                        line.delete(q.qmlLine)
                        if not na(q.qmlLabel)
                            label.delete(q.qmlLabel)
                        if not na(q.apexLine)
                            line.delete(q.apexLine)
                        if not na(q.apexLabel)
                            label.delete(q.apexLabel)
                        q.qmlLine := na
                        q.qmlLabel := na
                        q.apexLine := na
                        q.apexLabel := na
                        q.apexLine := na
                        q.apexLabel := na
                    if not na(q.zoneBox)
                        box.delete(q.zoneBox)
                        q.zoneBox := na

                    toFree -= 1

// ============================================================================
// 12B. PROJECTED CONFLUENCE AREAS
// ============================================================================
// Once direction is confirmed, mark the levels price could turn from before
// it gets there. These are not triggers: they are proven levels sitting inside
// the shoulder band of an active setup.
var array<box>   poiBoxes  = array.new<box>()
var array<label> poiLabels = array.new<label>()
var array<line>  poiLines  = array.new<line>()

if barstate.islast
    // Rebuild projections each time so nothing stale remains.
    while array.size(poiBoxes) > 0
        box.delete(array.pop(poiBoxes))
    while array.size(poiLabels) > 0
        label.delete(array.pop(poiLabels))
    while array.size(poiLines) > 0
        line.delete(array.pop(poiLines))

    // One line per PRICE, not one per level. Several SNR levels can sit inside the same
    // shoulder band a fraction apart, and each was getting its own projection, so the chart
    // ended with a bundle of near-identical lines at the current price that read as a smear
    // instead of a level. A confluence is supposed to be easier to see, not harder.
    array<float> poiDrawnPx = array.new<float>()
    if show_qml_snr_poi and array.size(qmlActive) > 0 and array.size(snrList) > 0
        for i = 0 to array.size(qmlActive) - 1
            QMLPattern q = array.get(qmlActive, i)
            if q.isFresh and (array.size(poiBoxes) + array.size(poiLines)) < poi_max_count
                // Shoulder band: the valid turn range between the zone and the break level.
                float bandEdge = q.qmlLevel + (q.bosLevel - q.qmlLevel) * shoulder_band
                float lo = math.min(q.qmlLevel, bandEdge) - snrClusterTol
                float hi = math.max(q.qmlLevel, bandEdge) + snrClusterTol
                for j = 0 to array.size(snrList) - 1
                    SnrLevel s = array.get(snrList, j)
                    bool already = false
                    if array.size(poiDrawnPx) > 0
                        for k = 0 to array.size(poiDrawnPx) - 1
                            if math.abs(array.get(poiDrawnPx, k) - s.levelPrice) <= snrClusterTol
                                already := true
                    if not already and (array.size(poiBoxes) + array.size(poiLines)) < poi_max_count and s.isBull == q.isBull and (s.touches + s.misses) >= shoulder_min_snr and s.levelPrice >= lo and s.levelPrice <= hi
                        array.push(poiDrawnPx, s.levelPrice)
                        color c = q.isBull ? WONRA_BULL : WONRA_BEAR
                        if vMin
                            // Minimal: a thin dotted line and a single mark, no text.
                            line pl2 = line.new(bar_index, s.levelPrice, bar_index + poi_project_bars, s.levelPrice, color=color.new(c, 45), width=1, style=line.style_dotted)
                            label pd = label.new(bar_index + poi_project_bars, s.levelPrice, "◇", style=label.style_label_left, color=CLEAR, textcolor=c, size=size.tiny)
                            array.push(poiLines, pl2)
                            array.push(poiLabels, pd)
                        else
                            box b = box.new(bar_index, s.levelPrice + safeAtr * 0.12, bar_index + poi_project_bars, s.levelPrice - safeAtr * 0.12, bgcolor=color.new(c, 80), border_color=color.new(c, 25), border_width=1)
                            label lb = label.new(bar_index + poi_project_bars, s.levelPrice, (vDet ? "QML×SNR ×" : "◇ ×") + str.tostring(s.touches + s.misses), style=label.style_label_left, color=CLEAR, textcolor=c, size=size.tiny)
                            array.push(poiBoxes, b)
                            array.push(poiLabels, lb)

// ============================================================================
// 12C. DIAGNOSTIC: THE SWING STRUCTURE THE ENGINE READS
// ============================================================================
// If the structure you see does not match this zigzag, none of the rules below
// can match either. Align this first.
var array<line>  swingDbgLines  = array.new<line>()
var array<label> swingDbgLabels = array.new<label>()

if barstate.islast
    while array.size(swingDbgLines) > 0
        line.delete(array.pop(swingDbgLines))
    while array.size(swingDbgLabels) > 0
        label.delete(array.pop(swingDbgLabels))

    if show_engine_swings and array.size(swings) >= 2
        int sz = array.size(swings)
        int startI = math.max(0, sz - 40)
        for i = startI to sz - 2
            SwingPoint a = array.get(swings, i)
            SwingPoint b = array.get(swings, i + 1)
            line sl = line.new(a.index, a.price, b.index, b.price, color=color.new(WONRA_GOLD, 25), width=1, style=line.style_solid)
            array.push(swingDbgLines, sl)
        // Small mark at each swing point
        for i = startI to sz - 1
            SwingPoint a = array.get(swings, i)
            label sp = label.new(a.index, a.price, a.dir == 1 ? "▾" : "▴", style=a.dir == 1 ? label.style_label_down : label.style_label_up, color=CLEAR, textcolor=WONRA_GOLD, size=size.tiny)
            array.push(swingDbgLabels, sp)

// ============================================================================
// 13. (REMOVED) POSITION TOOL
// ============================================================================
// Deleted. It drew an entry, a stop and three targets from the live candle, and its
// condition never went false again once any zone had been retested, so it redrew all five
// on every bar for the rest of the session. What it called the entry was simply the current
// candle low, with the stop and targets built out from that, which made the whole set a
// number that changed every bar and described nothing. This tool reads structure; where an
// order goes and what it risks is the trader's.

// ============================================================================
// 14. WONRA ALCHEMIST DASHBOARD TABLE
// ============================================================================
var table dashTable = table.new(f_table_pos(dash_position), 2, 11, bgcolor=DASH_BG, border_color=DASH_BORDER, border_width=1)

if show_dashboard and barstate.islast
    // Clear so the trace rows do not linger when switched off.
    table.clear(dashTable, 0, 0, 1, 10)
    table.cell(dashTable, 0, 0, "WONRA ALCHEMIST", text_color=WONRA_GOLD, text_size=size.small, bgcolor=DASH_HEAD)
    table.cell(dashTable, 1, 0, "MASTER ENGINE 🧙‍♂️", text_color=WONRA_GOLD, text_size=size.small, bgcolor=DASH_HEAD)

    table.cell(dashTable, 0, 1, "Fresh Bull QML", text_color=DASH_TEXT, text_size=size.small)
    table.cell(dashTable, 1, 1, str.tostring(freshBullCount), text_color=freshBullCount > 0 ? WONRA_BULL : DASH_MUTED, text_size=size.small)

    table.cell(dashTable, 0, 2, "Fresh Bear QML", text_color=DASH_TEXT, text_size=size.small)
    table.cell(dashTable, 1, 2, str.tostring(freshBearCount), text_color=freshBearCount > 0 ? WONRA_BEAR : DASH_MUTED, text_size=size.small)

    table.cell(dashTable, 0, 3, "FTB Entry", text_color=DASH_TEXT, text_size=size.small)
    string entryTxt = ftbFired ? (ftbFiredBull ? "BUY ▲" : "SELL ▼") : (snrReactBull or snrReactBear) ? (snrReactBull ? "SNR BUY ◆" : "SNR SELL ◆") : (point3ConfluenceBull or point3ConfluenceBear) ? "Point 3 ●" : "Scanning"
    color entryCol = ftbFired ? (ftbFiredBull ? WONRA_BULL : WONRA_BEAR) : (snrReactBull or snrReactBear) ? (snrReactBull ? WONRA_BULL : WONRA_BEAR) : (point3ConfluenceBull or point3ConfluenceBear) ? WONRA_GOLD : DASH_MUTED
    table.cell(dashTable, 1, 3, entryTxt, text_color=entryCol, text_size=size.small)

    table.cell(dashTable, 0, 4, "Active Patterns", text_color=DASH_TEXT, text_size=size.small)
    table.cell(dashTable, 1, 4, str.tostring(array.size(qmlActive)), text_color=array.size(qmlActive) > 0 ? WONRA_GOLD : DASH_MUTED, text_size=size.small)

    // Counting unfilled zones is not direction: in a downtrend bullish zones pile
    // up unfilled. Direction belongs to the Storyline row.
    // This shows the nearest active zone instead: actionable, and claims nothing.
    float nearDist = 1e10
    bool  nearBull = false
    bool  nearFound = false
    if array.size(qmlActive) > 0
        for i = 0 to array.size(qmlActive) - 1
            QMLPattern q = array.get(qmlActive, i)
            if q.isFresh
                float d = math.abs(close - q.qmlLevel)
                if d < nearDist
                    nearDist  := d
                    nearBull  := q.isBull
                    nearFound := true
    string nearTxt = nearFound ? ((nearBull ? "Bull " : "Bear ") + str.tostring(math.round(nearDist / safeAtr * 10) / 10) + " ATR") : "—"
    table.cell(dashTable, 0, 5, "Nearest Zone", text_color=DASH_TEXT, text_size=size.small)
    table.cell(dashTable, 1, 5, nearTxt, text_color=nearFound ? (nearBull ? WONRA_BULL : WONRA_BEAR) : DASH_MUTED, text_size=size.small)

    // The breakout type is part of the read, not decoration: an internal breakout formed
    // after the rejection and belongs to it, an external one was already there.
    string stlBoTag = storylineDir == 0 ? "" : stlInternal ? " · int BO" : " · ext BO"
    string stlTxt = storylineDir == 1 ? "BULLISH ▲ (" + stlTf + ")" + stlBoTag : storylineDir == -1 ? "BEARISH ▼ (" + stlTf + ")" + stlBoTag : stlPending != 0 ? "Rejection — awaiting BO" : "No Storyline"
    table.cell(dashTable, 0, 6, "Storyline", text_color=DASH_TEXT, text_size=size.small)
    table.cell(dashTable, 1, 6, stlTxt, text_color=storylineDir == 1 ? WONRA_BULL : storylineDir == -1 ? WONRA_BEAR : DASH_MUTED, text_size=size.small)

    // --- Diagnostic: which gate is filtering setups out ---
    table.cell(dashTable, 0, 7, "QML Found (total)", text_color=DASH_TEXT, text_size=size.small)
    int qmlFoundV = array.get(rejCnt, 5)
    table.cell(dashTable, 1, 7, str.tostring(qmlFoundV), text_color=qmlFoundV > 0 ? WONRA_GOLD : WONRA_BEAR, text_size=size.small)

    int poiCount = array.size(poiBoxes) + array.size(poiLines)
    string shTxt = shoulderBull ? "BUY @ SNR ■" : shoulderBear ? "SELL @ SNR ■" : poiCount > 0 ? "Watching " + str.tostring(poiCount) + " QML×SNR" : "Scanning"
    table.cell(dashTable, 0, 8, "Shoulder Entry", text_color=DASH_TEXT, text_size=size.small)
    table.cell(dashTable, 1, 8, shTxt, text_color=shoulderBull ? WONRA_BULL : shoulderBear ? WONRA_BEAR : poiCount > 0 ? WONRA_GOLD : DASH_MUTED, text_size=size.small)

    // Internal counters, last and off by default so the panel stays clean when shared.
    if verbose_trace
        string rejTxt = "Sz " + str.tostring(array.get(rejCnt, 0)) + " | BOS " + str.tostring(array.get(rejCnt, 1)) + " | Fr " + str.tostring(array.get(rejCnt, 2)) + " | Sc " + str.tostring(array.get(rejCnt, 3)) + " | Dup " + str.tostring(array.get(rejCnt, 4)) + " | Sd " + str.tostring(array.get(rejCnt, 6)) + " | Sh " + str.tostring(array.get(rejCnt, 7)) + " | Cx " + str.tostring(array.get(rejCnt, 8))
        table.cell(dashTable, 0, 9, "Rejected By", text_color=DASH_TEXT, text_size=size.small)
        table.cell(dashTable, 1, 9, rejTxt, text_color=DASH_MUTED, text_size=size.tiny)

        string dbgTxt = "fired " + str.tostring(dbgFired) + " | weak " + str.tostring(dbgWeak) + " | noConf " + str.tostring(dbgNoConf) + " | cd " + str.tostring(dbgCooldown)
        table.cell(dashTable, 0, 10, "◆ Reaction Debug", text_color=DASH_TEXT, text_size=size.small)
        table.cell(dashTable, 1, 10, dbgTxt, text_color=DASH_MUTED, text_size=size.tiny)

// ============================================================================
// 14B. MARKERS
// ============================================================================
// Shapes rather than labels: much smaller, they never cover the candle and
// they sit exactly under or over the correct bar.
bool mkFtbBull  = ftbFired and ftbFiredBull
bool mkFtbBear  = ftbFired and not ftbFiredBull

// Diamonds, not triangles. Discipline Flow marks its own entries with triangles, and when
// both engines are on one chart two different systems were speaking in the same symbol.
plotshape(mkFtbBull,             title="◆ FTB Reversal BUY",  style=shape.diamond,      location=location.belowbar, color=f_mcol(true),  size=size.tiny, display=display.pane)
plotshape(mkFtbBear,             title="◆ FTB Reversal SELL", style=shape.diamond,      location=location.abovebar, color=f_mcol(false), size=size.tiny, display=display.pane)
plotshape(point3ConfluenceBull,  title="● Point 3 BUY",       style=shape.circle,       location=location.belowbar, color=f_mcol(true),  size=size.tiny, display=display.pane)
plotshape(point3ConfluenceBear,  title="● Point 3 SELL",      style=shape.circle,       location=location.abovebar, color=f_mcol(false), size=size.tiny, display=display.pane)

// ============================================================================
// 15. ALARMLAR (TRADINGVIEW ALERTS)
// ============================================================================
alertcondition(point3ConfluenceBull, "Point 3 Bull Confluence", "Wonra Alchemist: Point 3 Bullish Confluence formed!")
alertcondition(point3ConfluenceBear, "Point 3 Bear Confluence", "Wonra Alchemist: Point 3 Bearish Confluence formed!")
alertcondition(freshBullCount > 0, "Fresh Bullish QML Zone", "Wonra Alchemist: Fresh Bullish QML Zone Active!")
alertcondition(freshBearCount > 0, "Fresh Bearish QML Zone", "Wonra Alchemist: Fresh Bearish QML Zone Active!")
alertcondition(shoulderBull, "Shoulder Entry BUY @ SNR", "Wonra Alchemist: shoulder entry from a proven level — BUY")
alertcondition(shoulderBear, "Shoulder Entry SELL @ SNR", "Wonra Alchemist: shoulder entry from a proven level — SELL")
alertcondition(ftbFired and ftbFiredBull, "FTB Entry BUY", "Wonra Alchemist: reversal confirmed at zone — BUY")
alertcondition(ftbFired and not ftbFiredBull, "FTB Entry SELL", "Wonra Alchemist: reversal confirmed at zone — SELL")
alertcondition(snrReactBull, "SNR Reaction BUY", "Wonra Alchemist: bullish reaction from a proven level")
alertcondition(snrReactBear, "SNR Reaction SELL", "Wonra Alchemist: bearish reaction from a proven level")

// ============================================================================
// 16. STRONG FVG (imbalance zones)
// ============================================================================
// A three-candle imbalance: the middle candle moves far enough that the wicks
// of the two outer candles never meet. The gap left behind is unfinished
// business, and price tends to come back for it.
//
// ATTRIBUTION. This section is taken from "Customizable Strong FVGs" by Fleezzuss,
// published open-source under the Mozilla Public License 2.0
// (https://mozilla.org/MPL/2.0/). The three-candle detection, the sensitivity modes and
// the zone lifecycle are Fleezzuss's work, not ours.
//
// Because of it, this whole script is published open-source under the same licence.
//
// Added here: a zone is skipped when it would overlap one already on the chart, so
// consecutive impulse candles stop stacking gaps at the same price; zones spanning a
// market closure are discarded, since a weekend is not an imbalance; and the palette
// is neutral so imbalances read as background rather than competing with the levels.

type FvgInfo
    float top
    float bottom
    int   barIndex
    bool  isBullish
    box   boxId
    label labelId
    bool  wasEntered
    int   filledBar     // bar the gap was covered on; the zone stops growing there

GRP7 = '7) Strong FVG'
sfvg_show        = input.bool(true, "Show Strong FVGs", group=GRP7, display=display.none)
sfvg_sensitivity = input.string("Balanced", "Sensitivity Mode", options=["All (Catch More)", "Balanced", "Conservative (Strong Only)"], group=GRP7, tooltip="All: every gap. Balanced: filters out the very small ones. Conservative: only large impulse gaps.", display=display.none)
sfvg_threshold   = input.float(0.5, "Min Gap Size (x ATR)", minval=0.0, step=0.1, group=GRP7, tooltip="Only active in Balanced and Conservative modes. 0 disables size filtering.", display=display.none)
sfvg_atr_len     = input.int(14, "FVG ATR Period", minval=1, group=GRP7, display=display.none)
// OFF now. A filled gap stops at the bar that filled it either way; this only decides
// whether the record of it stays on the chart or is thrown away. Keeping it costs nothing
// visually since a filled zone is drawn back almost to nothing, and it is useful to see
// where the imbalances have already been worked through.
sfvg_remove      = input.bool(false, "Delete Gaps Once Filled", group=GRP7, tooltip="A filled gap always stops extending at the bar that filled it. This decides whether it is then deleted or kept as a faded record.", display=display.none)
sfvg_max_active  = input.int(60, "Max Active FVGs", minval=10, maxval=200, group=GRP7, tooltip="Boxes are a shared budget across the whole indicator. Raising this too far can start pushing QML zones off the chart.", display=display.none)
sfvg_border_w    = input.int(1, "Border Width", minval=0, group=GRP7, display=display.none)
sfvg_border_st   = input.string(line.style_solid, "Border Style", options=[line.style_solid, line.style_dashed, line.style_dotted], group=GRP7, display=display.none)
sfvg_stack_pct   = input.float(60.0, "Skip Gap If It Overlaps An Existing One By (%)", minval=0.0, maxval=100.0, step=5.0, group=GRP7, tooltip="Back-to-back impulse candles leave gaps stacked at the same price. Above this overlap the new one is not drawn — the zone is already on the chart. 0 draws every gap.", display=display.none)
sfvg_show_label  = input.bool(true, "Show 'Str FVG' Label", group=GRP7, display=display.none)
sfvg_label_size  = input.string(size.tiny, "Label Size", options=[size.tiny, size.small, size.normal], group=GRP7, display=display.none)

var array<FvgInfo> activeFvgs = array.new<FvgInfo>(0)

// Same tonal treatment as the QML zones, so the two never clash — and quieter than before.
// These are context, not signals: they should be readable when looked for and invisible
// when they are not.
// GREY, ON PURPOSE. Every layer on this chart was drawn in the same two colours, so an FVG,
// an engulfing zone, a QML zone and an SNR level all read as the same kind of statement.
// They are not. An imbalance is background: somewhere price may want to revisit. It gets no
// colour of its own and sits at the bottom of the visual order, which leaves green and red
// to mean what they should, a direction someone is being asked to act on.
color SFVG_BULL_BG  = color.new(WONRA_GRAY, vMin ? 97 : 94)
color SFVG_BEAR_BG  = color.new(WONRA_GRAY, vMin ? 97 : 94)
color SFVG_BULL_BRD = color.new(WONRA_GRAY, vMin ? 88 : 80)
color SFVG_BEAR_BRD = color.new(WONRA_GRAY, vMin ? 88 : 80)

// --- Stacking guard ---
// Consecutive impulse candles each leave a gap, and those gaps sit on top of one another
// at the same price. Drawn individually they read as one dark smear whose edges mean
// nothing. A new gap that is largely inside one already on the chart adds no information.
f_sfvg_stacked(float t, float b) =>
    bool hit = false
    if array.size(activeFvgs) > 0
        for i = 0 to array.size(activeFvgs) - 1
            FvgInfo e = array.get(activeFvgs, i)
            float overlap = math.min(t, e.top) - math.max(b, e.bottom)
            float smaller = math.min(t - b, e.top - e.bottom)
            if overlap > 0 and smaller > 0 and (overlap / smaller) >= sfvg_stack_pct / 100.0
                hit := true
    hit

float sfvgAtr = ta.atr(sfvg_atr_len)

// Strength criteria driven by the sensitivity mode
float sfvgGapSize = sfvg_sensitivity == "All (Catch More)" ? 0.0 : (sfvg_sensitivity == "Balanced" ? sfvgAtr * sfvg_threshold : sfvgAtr * (sfvg_threshold + 0.5))
bool  sfvgImpulse = sfvg_sensitivity == "Conservative (Strong Only)" ? (math.abs(close[1] - open[1]) > (high[1] - low[1]) * 0.6) : true

// A WEEKEND IS NOT AN IMBALANCE.
// The space left when the market is shut is not unfinished business between buyers and
// sellers, it is a market that was closed. It also happens to be the largest space on the
// chart, so it produced the biggest and most eye-catching zone on there every Monday while
// meaning nothing at all. A bar that opens far later than the timeframe accounts for is on
// the other side of a break, and any three-candle pattern spanning one is discarded.
int  sfvgBarMs   = timeframe.in_seconds() * 1000
bool sfvgBreak   = (time - time[1]) > sfvgBarMs * 2 or (time[1] - time[2]) > sfvgBarMs * 2

bool sfvgBull = sfvg_show and not sfvgBreak and low > high[2] and (low - high[2]) >= nz(sfvgGapSize) and sfvgImpulse
bool sfvgBear = sfvg_show and not sfvgBreak and high < low[2] and (low[2] - high) >= nz(sfvgGapSize) and sfvgImpulse

// The tag lives INSIDE the box, right-aligned, exactly like the QML zone labels.
// A separate label object would stay pinned to the bar it was created on while the
// box keeps extending, which is what left the text stranded on the left edge.
string sfvgTag = sfvg_show_label ? "Str FVG" : ""

if sfvgBull and not f_sfvg_stacked(low, high[2])
    box sfvgBox = box.new(bar_index - 2, low, bar_index, high[2], xloc=xloc.bar_index, border_color=SFVG_BULL_BRD, border_width=sfvg_border_w, border_style=sfvg_border_st, bgcolor=SFVG_BULL_BG, text=sfvgTag, text_color=color.new(WONRA_GRAY, 25), text_size=sfvg_label_size, text_halign=text.align_right, text_valign=text.align_center)
    array.push(activeFvgs, FvgInfo.new(low, high[2], bar_index - 2, true, sfvgBox, na, false, int(na)))
    alert("New Bullish Strong FVG detected!", alert.freq_once_per_bar)

if sfvgBear and not f_sfvg_stacked(high, low[2])
    box sfvgBox = box.new(bar_index - 2, low[2], bar_index, high, xloc=xloc.bar_index, border_color=SFVG_BEAR_BRD, border_width=sfvg_border_w, border_style=sfvg_border_st, bgcolor=SFVG_BEAR_BG, text=sfvgTag, text_color=color.new(WONRA_GRAY, 25), text_size=sfvg_label_size, text_halign=text.align_right, text_valign=text.align_center)
    array.push(activeFvgs, FvgInfo.new(low[2], high, bar_index - 2, false, sfvgBox, na, false, int(na)))
    alert("New Bearish Strong FVG detected!", alert.freq_once_per_bar)

// --- Lifecycle: extend while open, STOP at the fill ---
// A gap is unfinished business, so a zone is only live while the business is unfinished.
// Once price has traded back across the whole gap there is nothing left in there and the
// zone has no future: it stops at the bar that filled it. Every zone used to be pushed out
// to the current bar on every bar, filled or not, so old gaps ran the width of the chart
// and the ones still open were impossible to pick out among them.
// Filling is price TRADING through the gap, not closing beyond it. Wicks fill gaps; the old
// test asked for a close all the way past, which is a different and much rarer event, and
// it is why filled zones were still on the chart.
if array.size(activeFvgs) > 0
    for i = array.size(activeFvgs) - 1 to 0
        FvgInfo sfvg = array.get(activeFvgs, i)

        bool sfvgInside = low < sfvg.top and high > sfvg.bottom
        if sfvgInside and not sfvg.wasEntered
            sfvg.wasEntered := true
            alert("Price entered an active Strong FVG zone!", alert.freq_once_per_bar)

        // Covered end to end: a bullish gap sits below price and is filled by trading down
        // through its floor, a bearish one by trading up through its ceiling.
        bool sfvgFilled = na(sfvg.filledBar) and bar_index > sfvg.barIndex + 1 and (sfvg.isBullish ? low <= sfvg.bottom : high >= sfvg.top)

        if sfvgFilled
            sfvg.filledBar := bar_index
            if sfvg_remove
                box.delete(sfvg.boxId)
                label.delete(sfvg.labelId)
                array.remove(activeFvgs, i)
            else
                // Kept as a record, frozen at the fill and dimmer than a live zone.
                box.set_right(sfvg.boxId, bar_index)
                box.set_bgcolor(sfvg.boxId, color.new(WONRA_GRAY, vMin ? 99 : 97))
                box.set_border_color(sfvg.boxId, color.new(WONRA_GRAY, vMin ? 94 : 88))
        else if na(sfvg.filledBar)
            // Still open, so it still reaches the present.
            box.set_right(sfvg.boxId, bar_index)

// Safety limit — shares the 500-box budget with the QML and POI drawings
if array.size(activeFvgs) > sfvg_max_active
    FvgInfo oldFvg = array.shift(activeFvgs)
    box.delete(oldFvg.boxId)
    label.delete(oldFvg.labelId)

alertcondition(sfvgBull, "Strong FVG Bullish", "Wonra Alchemist: bullish Strong FVG formed")
alertcondition(sfvgBear, "Strong FVG Bearish", "Wonra Alchemist: bearish Strong FVG formed")

// ============================================================================
// 17. ENGULFING ZONES — EG / EF
// ============================================================================
// The doctrine's own words:
//
//   "We will always use Engulfing (EG) or Engulfing failed (EF) as our potential zone of
//    buying or selling. Setups will always be based on EG TO EG, EG TO EF, EF TO EG."
//
//   "If Bullish Engulfing is broken it becomes Engulf Failed sell zone and
//    if Bearish Engulfing is broken, it becomes Engulf Failed Buy zone."
//
// That second rule is the whole point of the module and it is what makes an engulfing
// different from any other candle pattern: the zone does not die when price goes through
// it. It CHANGES SIDES. A bullish zone that fails is where sellers proved themselves, and
// it becomes a selling zone at the same prices.
//
// Marking follows the doctrine as well: mark the zone, then look for the fresh A / V / Gap
// levels sitting inside it. Those levels already exist in this script, so the zone is drawn
// as an area and the levels inside it keep doing their own work.

GRP8 = '8) Engulfing Zones (EG / EF)'
eg_min_atr    = input.float(0.8, "Min Engulfing Size (x ATR)", minval=0.0, step=0.1, group=GRP8, tooltip="How large the engulfing candle has to be. Every chart produces small engulfings constantly and they carry no information; this is what separates a zone from noise.", display=display.none)
eg_wick_engulf= input.bool(false, "Require Full Wick Engulf", group=GRP8, tooltip="Off: the engulfing candle's BODY must cover the previous body, which is how the doctrine marks it. On: its whole range must cover the previous range, which is stricter and much rarer.", display=display.none)
eg_zone_body  = input.bool(true, "Zone Is The Body", group=GRP8, tooltip="The zone is the ENGULFED candle, the last opposite candle before the move, which is what the doctrine treats as the order block. On: its open to close, in keeping with Malaysian SNR reading bodies and ignoring wicks. Off: its full range.", display=display.none)
eg_keep_failed= input.bool(true, "Keep Zones After They Fail (EF)", group=GRP8, tooltip="A broken bullish zone becomes a Failed Engulfing SELL zone and vice versa. Turning this off deletes a zone once it breaks, which throws away the EG to EF and EF to EG setups.", display=display.none)
eg_max_active = input.int(20, "Max Active Zones", minval=2, maxval=60, group=GRP8, tooltip="Boxes are shared with the QML zones and the FVG module. Raising this can push other drawings off the chart.", display=display.none)
eg_show_label = input.bool(true, "Show Zone Labels", group=GRP8, display=display.none)

type EgZone
    float top
    float bottom
    int   startIdx
    bool  isBull        // current bias: which way the zone is now read
    bool  isFailed      // has it already flipped once?
    bool  wasEntered
    box   boxId

var array<EgZone> egList = array.new<EgZone>()

// A zone that has flipped is drawn in gold: it is neither a plain bullish nor a plain
// bearish zone any more, it is a level that has already proven one side wrong.
f_eg_fill(bool isBull, bool failed) => color.new(failed ? WONRA_GOLD : isBull ? WONRA_BULL : WONRA_BEAR, vMin ? 94 : 89)
f_eg_edge(bool isBull, bool failed) => color.new(failed ? WONRA_GOLD : isBull ? WONRA_BULL : WONRA_BEAR, vMin ? 80 : 62)

// --- DETECTION ---
// Body engulf is the default because Malaysian SNR reads bodies and ignores wicks, and it
// is the definition the course marks its zones from.
float egBody     = math.abs(close - open)
float egBodyPrev = math.abs(close[1] - open[1])
bool  egBigEnough = egBody >= safeAtr * eg_min_atr

bool egBullRaw = close > open and close[1] < open[1] and (eg_wick_engulf ? (high >= high[1] and low <= low[1]) : (close >= open[1] and open <= close[1]))
bool egBearRaw = close < open and close[1] > open[1] and (eg_wick_engulf ? (high >= high[1] and low <= low[1]) : (close <= open[1] and open >= close[1]))

bool egBull = show_engulfing and egBullRaw and egBigEnough and egBody > egBodyPrev
bool egBear = show_engulfing and egBearRaw and egBigEnough and egBody > egBodyPrev

// THE ZONE IS THE ENGULFED CANDLE, NOT THE ENGULFING ONE.
// The doctrine calls this an order block ("EF OB is an Order Block that is a reversal
// signal"), and an order block is the last opposite candle before the move: the one that
// got engulfed. That candle is where the orders were sitting. The engulfing candle is the
// reaction to them, not the place they rest, and drawing it put the zone one candle late
// and at the wrong prices every time.
f_eg_new(bool isBull) =>
    float t = eg_zone_body ? math.max(open[1], close[1]) : high[1]
    float b = eg_zone_body ? math.min(open[1], close[1]) : low[1]
    box bx = box.new(bar_index - 1, t, bar_index + snr_extend_bars, b, xloc=xloc.bar_index, border_color=f_eg_edge(isBull, false), border_width=1, bgcolor=f_eg_fill(isBull, false), text=eg_show_label ? (isBull ? "EG" : "EG") : "", text_color=color.new(isBull ? WONRA_BULL : WONRA_BEAR, 20), text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_center)
    array.push(egList, EgZone.new(t, b, bar_index, isBull, false, false, bx))
    int(0)

if barstate.isconfirmed and egBull
    f_eg_new(true)
if barstate.isconfirmed and egBear
    f_eg_new(false)

// --- LIFECYCLE: extend, flip on failure, retire on the second failure ---
if barstate.isconfirmed and array.size(egList) > 0
    for i = array.size(egList) - 1 to 0
        EgZone z = array.get(egList, i)
        box.set_right(z.boxId, bar_index + snr_extend_bars)

        if not z.wasEntered and low <= z.top and high >= z.bottom and bar_index > z.startIdx + 1
            z.wasEntered := true

        // Failure is a close all the way through the zone against its bias.
        bool failed = bar_index > z.startIdx + 1 and (z.isBull ? close < z.bottom : close > z.top)
        if failed
            if eg_keep_failed and not z.isFailed
                // THE FLIP. Same prices, opposite meaning: a bullish zone that could not
                // hold is where the sellers won, so it is now a selling zone.
                z.isBull     := not z.isBull
                z.isFailed   := true
                z.wasEntered := false
                box.set_bgcolor(z.boxId, f_eg_fill(z.isBull, true))
                box.set_border_color(z.boxId, f_eg_edge(z.isBull, true))
                box.set_text(z.boxId, eg_show_label ? "EF" : "")
                box.set_text_color(z.boxId, color.new(WONRA_GOLD, 20))
            else
                // Already flipped once and broken again: it has now failed in both
                // directions and is telling us nothing.
                box.delete(z.boxId)
                array.remove(egList, i)

// Shared drawing budget with the QML zones and the FVG module.
while array.size(egList) > eg_max_active
    EgZone oldEg = array.shift(egList)
    box.delete(oldEg.boxId)

alertcondition(egBull, "Engulfing Bullish", "Wonra Alchemist: bullish Engulfing zone formed")
alertcondition(egBear, "Engulfing Bearish", "Wonra Alchemist: bearish Engulfing zone formed")
````
