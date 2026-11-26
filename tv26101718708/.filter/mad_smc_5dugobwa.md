# [MAD] SMC

- url: https://www.tradingview.com/script/5DuGoBwA-MAD-SMC/
- type: indicator
- pine_id: PUB;3d5bd801cbee4693a90839193bff460b
- version: 2.0

## Description

[b]1. OVERVIEW[/b]
[MAD] SMC Event Markers is a complete Smart-Money-Concepts toolkit that draws every major institutional footprint on the chart — and then [b]ranks every zone by relevance[/b] so you instantly see which ones actually matter.

Most SMC indicators have the same problem: they paint dozens of FVGs, order blocks, and liquidity lines, and leave you to decide what to trade. After ten zones the chart looks like a dropped Lego set. This indicator solves that. Every active zone is scored 0–100 against five independent factors. Low-scoring zones fade or disappear automatically. A compact dashboard pins the top-ranked setups to a chart corner so you always know where the high-probability opportunities are.

The indicator detects 14+ SMC event types — FVG, IFVG, Order Blocks, Breaker Blocks, BSL/SSL, BPR, EQH/EQL, BOS/CHoCH, Sweep, IDM, Reversal Confirmed, Premium/Discount/Equilibrium, OTE, Volume Imbalance, SMT Divergence, PDH/PDL/PWH/PWL/PMH/PML, and ICT killzones. Every zone is ranked 0–100 by a [b]relevance score[/b] built from five factors; [b]opacity scales with that score[/b] so the eye is drawn to the bright zones while weak ones recede, and a [b]threshold filter[/b] deletes the weakest zones entirely to free chart drawing budget. A [b]top-N dashboard[/b] ranks the strongest setups by price, direction, age, and score. [b]Three colour schemas[/b] — Default (customizable), Dark, and Light — are switchable globally, with all 22 default colours exposed as individual inputs. Per-type drawing caps and an FVG merge engine keep performance steady on busy timeframes.

https://www.tradingview.com/x/qEiA7dCl/

[b]2. HOW IT WORKS[/b]
[b]SMC Event Detection[/b]
The script identifies institutional footprints in real time. Every event has its own creation logic and mitigation logic — once price returns and fills the inefficiency, the zone is removed from the chart.

[b]Fair Value Gaps[/b] are 3-bar imbalances where the wicks don't touch, rendered as semi-transparent boxes with a centre-line at the consequent encroachment (CE). [b]Order Blocks[/b] are the last opposite-coloured candle before a structure break, gated by minimum displacement (× ATR). [b]Breaker Blocks[/b] are Order Blocks that flip side after price violates them, indicating role reversal. [b]Liquidity (BSL / SSL)[/b] lines mark confirmed swing highs and lows where retail stops cluster, while [b]BPR (Balanced Price Range)[/b] zones are detected as overlaps between opposing FVGs — high-probability institutional pivots.

[b]EQH / EQL[/b] marks equal highs and lows within an ATR tolerance, identifying magnet liquidity. [b]BOS / CHoCH[/b] distinguishes Break of Structure (continuation) from Change of Character (reversal); when a CHoCH prints shortly after a liquidity sweep, it is auto-tagged as [b]Reversal Confirmed[/b]. The script also detects [b]Sweep[/b], [b]IDM (Inducement)[/b], and [b]SMT divergence[/b] against a configurable reference symbol, and shades [b]Killzones[/b] for the Asia, London, NY-AM, and NY-PM sessions in the timezone of your choice.

https://www.tradingview.com/x/v1kkVhJY/

[b]Confluence Scoring[/b]
For every active zone, the script counts how many other zones overlap its price range within an ATR-based tolerance. Confluence between an Order Block, a Fair Value Gap, and a previous-day high is the textbook setup smart-money traders look for — this metric quantifies it.

[b]Composite Relevance Score[/b]
Each zone is scored 0–100 from five normalised factors with user-editable weights: [b]Confluence[/b] (default 30%) measuring how many other zones overlap, [b]Freshness[/b] (20%) decaying exponentially with bars since creation, [b]Displacement[/b] (20%) capturing the size of the impulse that created the zone divided by ATR, [b]Trend Alignment[/b] (15%) rewarding zones that match the current swing-structure direction, and [b]Proximity[/b] (15%) favouring zones near current price normalised by ATR reach. Weights don't have to sum to 100 — normalisation happens internally. The score recalculates every bar, so as price moves the proximity factor updates and the ranking shifts in real time.

https://www.tradingview.com/x/478yBT9X/

[b]Visual Hierarchy[/b]
Opacity scales with score — a zone at score 90 is vivid; at score 35 it's nearly transparent. Same colours, different volume. The threshold filter takes this further: anything below a configurable score (default 30) is deleted, not just dimmed — this frees drawing slots and prevents drawing-limit overflow on busy charts. Every zone label optionally appends its score, e.g. "Bull OB 82".

[b]Dashboard Panel[/b]
On the last bar, a compact table renders in the chart corner showing the top N zones ranked by score. Each row displays rank, type, price, direction, age in bars, and score with star rating and tier colour (≥80 green, ≥60 teal, ≥40 amber, <40 grey). The table updates with every new bar.

[b]3. HOW TO USE[/b]
[b]The Dashboard Workflow[/b]
Glance at the dashboard. The top 2–3 zones are your high-probability watchlist for this chart — combine the price level shown with the type and direction to plan your entries. If nothing has a score above 60, the market isn't offering quality setups; wait.

[b]Trading Reversals[/b]
Look for this sequence on the chart. First, price sweeps a BSL or SSL line and a sweep label appears. Within a few bars, CHoCH prints — a close back through the opposing swing — and a Reversal Confirmed label fires at that CHoCH point. From there, look for a fresh Order Block or FVG in the direction of the new bias, ideally inside the Discount or Premium zone or the OTE. Enter on retracement to that zone, place your stop beyond the swept extreme, and target the opposite liquidity pool (the BSL or SSL on the other side).

[b]Trading Continuations[/b]
After a BOS in the direction of the current trend, the OB or FVG that produced the break becomes a high-probability retracement entry. The dashboard will surface it automatically if its score is in the top tier.

[b]Decluttering for Clarity[/b]
The Threshold input is your declutter dial. On a busy 1H chart with 50+ historical zones, set it to 60 — only the cream stays visible. On a clean 15m intraday, set it to 30 to keep more context. At 0, every detected zone is drawn (legacy mode).

[b]Combine With Other Confluence[/b]
The scoring system already integrates intra-indicator confluence. For external confluence, overlay your higher-timeframe levels, a volume profile, or session VWAPs — anything that aligns with a high-score zone is a stronger setup.

[b]4. SETTINGS[/b]
Settings are organised into logical groups in the dialog.
[list]
[*][b]Structure:[/b] swing and internal pivot lengths, BOS / CHoCH toggles, HH/HL/LH/LL labels
[*][b]Liquidity:[/b] BSL/SSL/INT_LQ toggles, sweep window, IDM, Reversal Confirmed
[*][b]Order Blocks:[/b] minimum displacement (× ATR), Breaker conversion on violation
[*][b]EQH / EQL:[/b] ATR tolerance for equal levels
[*][b]Fair Value Gap:[/b] small-gap filter, extension bars, mitigation-on-close, BPR detection
[*][b]FVG Merge:[/b] consolidates old overlapping FVGs by age and ATR tolerance
[*][b]Volume Imbalance:[/b] body-to-body gap detection
[*][b]Premium / Discount:[/b] range plot and OTE zone (62–79% retrace)
[*][b]Previous H/L:[/b] PDH/PDL, PWH/PWL, PMH/PML toggles
[*][b]SMT:[/b] divergence reference symbol (default NQ futures)
[*][b]Killzones:[/b] session backgrounds in selectable timezone
[*][b]Drawing Limits:[/b] per-type caps to control total draw count
[*][b]Scoring:[/b] confluence tolerance, freshness decay, proximity reach, five weights, threshold, opacity toggle, score-in-label toggle
[*][b]Dashboard:[/b] show / rows / position / cell size
[*][b]Colors:[/b] schema enum (Default / Dark / Light) plus 22 individual colour inputs
[*][b]Style:[/b] label size, extension bars, all event label text
[/list]

[b]5. DESIGN DECISIONS[/b]
This indicator was built around three principles.

[b]Decluttering is more valuable than detection.[/b] Anyone can detect an FVG — the hard part is knowing which of the twelve currently on screen is the one you should care about. The scoring system exists because the trader's biggest enemy is signal-to-noise, not missing signals.

[b]Every zone should justify its space.[/b] Opacity scaling and the threshold-delete behaviour mean that low-conviction zones don't merely fade — they're erased from the drawing pool, so the chart stays performant even on minute-tick instruments with thousands of bars of history. The drawing-limit caps (configurable per event type) reinforce this.

[b]Customisation should be opt-in.[/b] The Default schema is the production-ready palette. Most traders won't touch the 22 colour inputs. But for designers who care, every base colour is individually editable. Dark and Light schemas exist as one-click presets for OLED users and light-theme users respectively.

[b]6. CREDITS AND ATTRIBUTION[/b]
The Smart Money Concepts framework is a community-developed body of knowledge built on the work of [b]Richard Wyckoff[/b] (1930s — accumulation / distribution cycles, composite-man theory), [b]Charles Dow[/b] (higher-highs / higher-lows market structure), [b]Michael J. Huddleston / ICT[/b] (modern SMC terminology — BOS, CHoCH, Liquidity, Breaker, FVG, OTE, Killzones), and the wider SMC trading community that refined, tested, and disseminated these ideas.

[b]7. DISCLAIMER[/b]
For educational and informational purposes only — not financial advice. Past performance does not guarantee future results, and all trading decisions are made at your own risk. The author accepts no liability for any loss arising from use of or reliance on this script.

## Source Code

````pine
//@version=6
// =============================================================================
//   [MAD] SMC Event Markers v5 — Scoring + Dashboard
//   Conceptual lineage: Wyckoff, Dow, ICT (terminology). 
//   © 2026 — Original implementation, no third-party codereused.
// =============================================================================
indicator("[MAD] SMC Events", shorttitle = "[MAD]SMC-E", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 2000)

//Blockmarker TYPE_DEFINITIONS {
// Enums must be declared before any input.enum() call uses them.
enum Schema
    DEFAULT = "Default"
    DARK    = "Dark"
    LIGHT   = "Light"

enum DashPos
    TOP_LEFT      = "Top left"
    TOP_CENTER    = "Top center"
    TOP_RIGHT     = "Top right"
    MIDDLE_LEFT   = "Middle left"
    MIDDLE_CENTER = "Middle center"
    MIDDLE_RIGHT  = "Middle right"
    BOTTOM_LEFT   = "Bottom left"
    BOTTOM_CENTER = "Bottom center"
    BOTTOM_RIGHT  = "Bottom right"

// }

//Blockmarker INPUTS {
// ─── Market Structure ───────────────────────────────────────────────────────
s_gStr = "Market Structure"
i_swLen   = input.int(50, "Swing pivot length", minval = 2, group = s_gStr, tooltip = "Bars required on each side to confirm a swing pivot. Higher = fewer, more significant pivots. Lower = more pivots, responsive but noisier.")
i_inLen   = input.int(5, "Internal pivot length", minval = 2, group = s_gStr, tooltip = "Bars required on each side to confirm an internal (smaller) pivot. Drives BOS/CHoCH detection at sub-swing scale.")
b_showSw  = input.bool(true,  "Swing BOS / CHoCH",    group = s_gStr, tooltip = "Plot Break of Structure (continuation) and Change of Character (reversal) lines drawn from confirmed swing pivots.")
b_showIn  = input.bool(false, "Internal BOS / CHoCH", group = s_gStr, tooltip = "Plot BOS/CHoCH from internal pivots. Off by default — adds detail but clutters busy charts.")
b_showSP  = input.bool(true,  "HH / HL / LH / LL",    group = s_gStr, tooltip = "Label every confirmed swing pivot as Higher-High, Higher-Low, Lower-High, or Lower-Low.")

// ─── Liquidity ──────────────────────────────────────────────────────────────
s_gLq = "Liquidity"
b_showBSL   = input.bool(true,  "BSL",                group = s_gLq, tooltip = "Plot Buy-Side Liquidity lines above swing highs — where stop-loss orders from short traders cluster.")
b_showSSL   = input.bool(true,  "SSL",                group = s_gLq, tooltip = "Plot Sell-Side Liquidity lines below swing lows — where stop-loss orders from long traders cluster.")
b_showINT   = input.bool(false, "Internal LQ",        group = s_gLq, tooltip = "Plot lines at internal pivot highs/lows. Off by default — only useful on cleaner charts.")
b_showSwp   = input.bool(true,  "Sweep",              group = s_gLq, tooltip = "Mark candles that pierce a liquidity level then close back inside (the textbook stop-hunt).")
b_showRev   = input.bool(true,  "Reversal Confirmed", group = s_gLq, tooltip = "Mark when a CHoCH prints shortly after a sweep — a high-probability reversal signature.")
i_sweepBars = input.int(8, "Sweep → CHoCH window (bars)", minval = 1, group = s_gLq, tooltip = "Maximum bars allowed between a sweep and a CHoCH for Reversal Confirmed to fire.")
b_showIDM   = input.bool(true,  "Inducement (IDM)",   group = s_gLq, tooltip = "Mark inducement pivots — minor pivots formed before a major swing, often used to trap retail.")

// ─── Order Blocks ───────────────────────────────────────────────────────────
s_gOb = "Order Blocks"
b_showOB   = input.bool(true, "Order Blocks", group = s_gOb, tooltip = "Detect Bull and Bear order blocks — the last opposite-coloured candle before a structure break.")
f_obAtrMin = input.float(0.5, "Min displacement (× ATR)", step = 0.1, group = s_gOb, tooltip = "Minimum impulse size (in ATR multiples) required to qualify as an order block. Filters out weak setups.")
b_showBB   = input.bool(true, "Convert to Breaker on violation", group = s_gOb, tooltip = "When price breaks through an OB the wrong way, repaint it as a Breaker Block instead of deleting — Breakers often act as future resistance/support.")

// ─── Fair Value Gaps ────────────────────────────────────────────────────────
s_gFvg = "Fair Value Gaps"
b_showFVG  = input.bool(true, "FVG", group = s_gFvg, tooltip = "Detect 3-bar imbalances where bar 1 wick and bar 3 wick do not overlap.")
b_fvgFilt  = input.bool(true, "Filter small FVGs", group = s_gFvg, tooltip = "Hide FVGs smaller than the minimum size below.")
f_fvgAtr   = input.float(0.25, "Min FVG size (× ATR)", step = 0.05, group = s_gFvg, tooltip = "Minimum FVG height (in ATR multiples) when the small-FVG filter is on.")
i_fvgExt   = input.int(30, "FVG extension (bars)", minval = 1, group = s_gFvg, tooltip = "How many bars to extend FVG boxes forward into the future.")
b_fvgClear = input.bool(true, "Clear on mitigation", group = s_gFvg, tooltip = "Delete an FVG when price returns through it (mitigation). Off = keep all FVGs historically.")
b_showBPR  = input.bool(true, "BPR (Balanced Price Range)", group = s_gFvg, tooltip = "Detect overlaps between opposing FVGs — institutional pivots where buyers and sellers both left imbalances.")
b_fvgMerge = input.bool(true, "Merge old FVGs", group = s_gFvg, tooltip = "Consolidate older overlapping FVGs into a single zone to reduce chart clutter.")
i_mergeAge = input.int(200, "Merge: age threshold (bars)", minval = 10, group = s_gFvg, tooltip = "Only merge FVGs older than this many bars. Fresh FVGs stay separate.")
f_mergeTol = input.float(0.3, "Merge: price tolerance (× ATR)", step = 0.05, group = s_gFvg, tooltip = "How close two FVGs must be (in ATR) to be considered overlapping for merge purposes.")

// ─── Equal Highs / Lows ─────────────────────────────────────────────────────
s_gEq = "Equal Highs / Lows"
b_showEQ = input.bool(true, "EQH / EQL", group = s_gEq, tooltip = "Detect equal highs (EQH) and equal lows (EQL) — magnet levels where liquidity accumulates.")
f_eqAtr  = input.float(0.15, "Tolerance (× ATR)", step = 0.05, group = s_gEq, tooltip = "How close two pivot prices must be (in ATR) to count as 'equal'.")

// ─── Premium / Discount / OTE ───────────────────────────────────────────────
s_gPd = "Premium / Discount"
b_showPD  = input.bool(true, "Premium / Equilibrium / Discount", group = s_gPd, tooltip = "Plot the current dealing range and split into Premium (sell zone), Equilibrium, and Discount (buy zone).")
b_showOTE = input.bool(true, "OTE (Optimal Trade Entry)",        group = s_gPd, tooltip = "Plot the OTE zone — the 62%–79% retracement of the active f_leg, a high-probability entry area.")

// ─── Volume Imbalance ───────────────────────────────────────────────────────
s_gVi = "Volume Imbalance"
b_showVI = input.bool(false, "Volume Imbalance", group = s_gVi, tooltip = "Detect VI — gaps between consecutive candle bodies (excluding wicks). Off by default — short-lived and noisy.")

// ─── Previous Highs / Lows ──────────────────────────────────────────────────
s_gPhl = "Previous Highs / Lows"
b_showPDH = input.bool(true,  "PDH / PDL", group = s_gPhl, tooltip = "Show Previous Day High and Previous Day Low as horizontal lines.")
b_showPWH = input.bool(true,  "PWH / PWL", group = s_gPhl, tooltip = "Show Previous Week High and Previous Week Low.")
b_showPMH = input.bool(false, "PMH / PML", group = s_gPhl, tooltip = "Show Previous Month High and Previous Month Low. Off by default — only relevant on high timeframes.")

// ─── SMT Divergence ─────────────────────────────────────────────────────────
s_gSmt = "SMT Divergence"
b_showSMT   = input.bool(false, "SMT divergence", group = s_gSmt, tooltip = "Detect when this symbol makes a higher high (or lower low) but the reference symbol does not — classic inter-market divergence.")
s_smtSymbol = input.symbol("CME_MINI:NQ1!", "Reference symbol", group = s_gSmt, tooltip = "Symbol to compare against. Default NQ futures works for ES / MES / NQ relationships. Use related instruments (e.g. DXY for EURUSD).")

// ─── Killzones ──────────────────────────────────────────────────────────────
s_gKz = "Killzones (Sessions)"
s_kzTz         = input.string("America/New_York", "Timezone", options = ["America/New_York", "Europe/London", "UTC", "Asia/Tokyo"], group = s_gKz, tooltip = "Timezone for session highlight calculation. NY is the conventional default.")
b_showKZAsia   = input.bool(false, "Asia session",     group = s_gKz, tooltip = "Highlight 20:00–00:00 NY time.")
b_showKZLondon = input.bool(false, "London session",   group = s_gKz, tooltip = "Highlight 02:00–05:00 NY time.")
b_showKZNYAM   = input.bool(false, "NY morning",       group = s_gKz, tooltip = "Highlight 07:00–10:00 NY time — the NY-AM killzone.")
b_showKZNYPM   = input.bool(false, "NY afternoon",     group = s_gKz, tooltip = "Highlight 13:30–16:00 NY time — the NY-PM killzone.")

// ─── Relevance Scoring ──────────────────────────────────────────────────────
s_gSc = "Relevance Scoring"
f_conflTol         = input.float(0.15, "Confluence tolerance (× ATR)", step = 0.05, group = s_gSc, tooltip = "How close two zones must be (in ATR) to count as overlapping when computing confluence.")
i_decayBars        = input.int(100, "Freshness decay (bars)", minval = 10, group = s_gSc, tooltip = "How many bars before a zone is roughly half-as-fresh. Higher = old zones stay relevant longer.")
i_proxBars         = input.int(20, "Proximity reach (× ATR)", minval = 1, group = s_gSc, tooltip = "Distance from current price (in ATR) at which a zone is fully out of range and scores zero on proximity.")
i_wConfl           = input.int(30, "Weight: confluence",       minval = 0, maxval = 100, group = s_gSc, tooltip = "Weight for overlap count with other zones. Higher = confluence dominates the score.")
i_wFresh           = input.int(20, "Weight: freshness",        minval = 0, maxval = 100, group = s_gSc, tooltip = "Weight for zone age. Higher = newer zones rank higher.")
i_wDispl           = input.int(20, "Weight: displacement",     minval = 0, maxval = 100, group = s_gSc, tooltip = "Weight for the impulse size that created the zone. Higher = strong-impulse zones rank higher.")
i_wTrend           = input.int(15, "Weight: trend alignment",  minval = 0, maxval = 100, group = s_gSc, tooltip = "Weight for whether a zone direction matches the current swing trend.")
i_wProx            = input.int(15, "Weight: proximity",        minval = 0, maxval = 100, group = s_gSc, tooltip = "Weight for distance from current price. Weights do not need to sum to 100 — normalised internally.")
i_scoreThreshold   = input.int(30, "Hide / delete below score", minval = 0, maxval = 100, group = s_gSc, tooltip = "Zones below this score are deleted from the chart, freeing drawing budget. 0 = keep everything. 80 = only A-grade setups.")
b_applyOpacity     = input.bool(true,  "Scale opacity with score", group = s_gSc, tooltip = "Higher score = more vivid. Low score = nearly transparent. Lets the eye lock onto the relevant zones.")
b_showScoreInLabel = input.bool(false, "Append score to zone labels", group = s_gSc, tooltip = "Show the numeric score next to each zone label, e.g. 'Bull OB [82]'.")

// ─── Dashboard ──────────────────────────────────────────────────────────────
s_gDash = "Dashboard"
b_showDash = input.bool(true, "Show dashboard", group = s_gDash, tooltip = "Display the top-N zones ranked by relevance in a corner table.")
i_dashRows = input.int(6, "Rows (split long / short)", minval = 2, maxval = 20, step = 2, group = s_gDash, tooltip = "Total rows in the dashboard, split evenly into long and short halves. Step of 2 — e.g. 6 = 3 long + 3 short, 10 = 5 long + 5 short. Max 20.")
e_dashPos  = input.enum(DashPos.TOP_RIGHT, "Position", group = s_gDash, tooltip = "Where on the chart to anchor the dashboard.")
s_dashSize = input.string("small", "Cell text size", options = ["tiny", "small", "normal"], group = s_gDash, tooltip = "Text size for each dashboard cell.")

// ─── Drawing Limits (advanced) ──────────────────────────────────────────────
s_gLim = "Drawing Limits (advanced)"
i_capLQ     = input.int(5,  "BSL / SSL per side",  minval = 1, group = s_gLim, tooltip = "Maximum BSL or SSL lines drawn at once. Oldest are removed first.")
i_capOB     = input.int(5,  "OB per side",         minval = 1, group = s_gLim, tooltip = "Maximum Bull or Bear order blocks drawn at once.")
i_capFVG    = input.int(12, "FVG per side",        minval = 1, group = s_gLim, tooltip = "Maximum Bull or Bear FVGs drawn at once.")
i_capBPR    = input.int(6,  "BPR",                 minval = 1, group = s_gLim, tooltip = "Maximum BPR zones drawn at once.")
i_capVI     = input.int(6,  "VI",                  minval = 1, group = s_gLim, tooltip = "Maximum volume imbalance boxes drawn at once.")
i_capSwBOS  = input.int(20, "Swing BOS / CHoCH",   minval = 1, group = s_gLim, tooltip = "Maximum swing-level BOS/CHoCH markers retained.")
i_capIntBOS = input.int(15, "Internal BOS / CHoCH", minval = 1, group = s_gLim, tooltip = "Maximum internal BOS/CHoCH markers retained.")
i_capEQL    = input.int(10, "EQH / EQL",           minval = 1, group = s_gLim, tooltip = "Maximum equal-high / equal-low lines retained.")
i_capINTLQ  = input.int(8,  "Internal LQ",         minval = 1, group = s_gLim, tooltip = "Maximum internal liquidity lines retained.")
i_capSwp    = input.int(12, "Sweep markers",       minval = 1, group = s_gLim, tooltip = "Maximum sweep labels retained.")
i_capIDM    = input.int(10, "IDM markers",         minval = 1, group = s_gLim, tooltip = "Maximum inducement labels retained.")
i_capSPL    = input.int(25, "Swing point labels",  minval = 1, group = s_gLim, tooltip = "Maximum HH/HL/LH/LL labels retained.")
i_capRev    = input.int(5,  "Reversal markers",    minval = 1, group = s_gLim, tooltip = "Maximum Reversal Confirmed labels retained.")
i_capSMTl   = input.int(5,  "SMT markers",         minval = 1, group = s_gLim, tooltip = "Maximum SMT divergence labels retained.")

// ─── Labels & Style ─────────────────────────────────────────────────────────
s_gSty = "Labels & Style"
s_lblSzInp   = input.string("small", "Event label size", options = ["tiny", "small", "normal", "large"], group = s_gSty, tooltip = "Text size for all event labels on the chart.")
i_extendBars = input.int(20, "Zone extension (bars)", minval = 0, group = s_gSty, tooltip = "How far BSL/SSL/OB zones extend to the right of the current bar.")
s_lblBSL  = input.string("Buy Side LQ",        "BSL label",           group = s_gSty, tooltip = "Display text for BSL labels.")
s_lblSSL  = input.string("SSL",                "SSL label",           group = s_gSty, tooltip = "Display text for SSL labels.")
s_lblINT  = input.string("INT_LQ",             "Internal LQ label",   group = s_gSty, tooltip = "Display text for internal liquidity labels.")
s_lblBOS  = input.string("BOS",                "BOS label",           group = s_gSty, tooltip = "Display text for Break of Structure labels.")
s_lblCHO  = input.string("CHoCH",              "CHoCH label",         group = s_gSty, tooltip = "Display text for Change of Character labels.")
s_lblEQH  = input.string("EQH",                "EQH label",           group = s_gSty, tooltip = "Display text for equal-high labels.")
s_lblEQL  = input.string("EQL",                "EQL label",           group = s_gSty, tooltip = "Display text for equal-low labels.")
s_lblFVG  = input.string("FVG",                "FVG label",           group = s_gSty, tooltip = "Display text for FVG labels.")
s_lblREV  = input.string("Reversal Confirmed", "Reversal label",      group = s_gSty, tooltip = "Display text for Reversal Confirmed labels.")
s_lblSWP  = input.string("Sweep",              "Sweep label",         group = s_gSty, tooltip = "Display text for sweep labels.")
s_lblIDM  = input.string("IDM",                "IDM label",           group = s_gSty, tooltip = "Display text for inducement labels.")
s_lblOBu  = input.string("Bull OB",            "Bull OB label",       group = s_gSty, tooltip = "Display text for bull order block labels.")
s_lblOBe  = input.string("Bear OB",            "Bear OB label",       group = s_gSty, tooltip = "Display text for bear order block labels.")
s_lblBBu  = input.string("Bull BB",            "Bull Breaker label",  group = s_gSty, tooltip = "Display text for bull breaker block labels.")
s_lblBBe  = input.string("Bear BB",            "Bear Breaker label",  group = s_gSty, tooltip = "Display text for bear breaker block labels.")
s_lblVIu  = input.string("Bull VI",            "Bull VI label",       group = s_gSty, tooltip = "Display text for bull volume imbalance labels.")
s_lblVIe  = input.string("Bear VI",            "Bear VI label",       group = s_gSty, tooltip = "Display text for bear volume imbalance labels.")
s_lblBPR  = input.string("BPR",                "BPR label",           group = s_gSty, tooltip = "Display text for BPR labels.")
s_lblPRM  = input.string("Premium",            "Premium label",       group = s_gSty, tooltip = "Display text for the Premium zone label.")
s_lblDSC  = input.string("Discount",           "Discount label",      group = s_gSty, tooltip = "Display text for the Discount zone label.")
s_lblEQU  = input.string("Equilibrium",        "Equilibrium label",   group = s_gSty, tooltip = "Display text for the Equilibrium line label.")
s_lblOTE  = input.string("OTE",                "OTE label",           group = s_gSty, tooltip = "Display text for the OTE zone label.")
s_lblSMTu = input.string("SMT bull",           "SMT bull label",      group = s_gSty, tooltip = "Display text for bull SMT divergence labels.")
s_lblSMTe = input.string("SMT bear",           "SMT bear label",      group = s_gSty, tooltip = "Display text for bear SMT divergence labels.")

// ─── Colors ─────────────────────────────────────────────────────────────────
s_gClr = "Colors"
e_schema   = input.enum(Schema.DEFAULT, "Color e_schema", group = s_gClr, tooltip = "Default uses the color inputs below. Dark / Light switch to preset palettes — color inputs are ignored in those modes.")
c_inBull = input.color(#26a69a, "Bull (FVG / OB)",  group = s_gClr, inline = "r1",  tooltip = "Base colour for bullish FVGs and order blocks.")
c_inBear = input.color(#ef5350, "Bear (FVG / OB)",  group = s_gClr, inline = "r1",  tooltip = "Base colour for bearish FVGs and order blocks.")
c_inBsl  = input.color(#42a5f5, "BSL",              group = s_gClr, inline = "r2",  tooltip = "Colour for Buy-Side Liquidity lines.")
c_inSsl  = input.color(#ffa726, "SSL",              group = s_gClr, inline = "r2",  tooltip = "Colour for Sell-Side Liquidity lines.")
c_inBpr  = input.color(#ab47bc, "BPR",              group = s_gClr, inline = "r3",  tooltip = "Colour for Balanced Price Range zones.")
c_inEq   = input.color(#ffd740, "EQH / EQL",        group = s_gClr, inline = "r3",  tooltip = "Colour for equal-high / equal-low lines.")
c_inPdh  = input.color(#42a5f5, "PDH / PDL",        group = s_gClr, inline = "r4",  tooltip = "Colour for Previous Day High / Low.")
c_inPwh  = input.color(#ab47bc, "PWH / PWL",        group = s_gClr, inline = "r4",  tooltip = "Colour for Previous Week High / Low.")
c_inPmh  = input.color(#ffa726, "PMH / PML",        group = s_gClr,                 tooltip = "Colour for Previous Month High / Low.")
c_inBullBreak = input.color(#00e676, "Bull CHoCH",       group = s_gClr, inline = "r6",  tooltip = "Colour for bullish Change-of-Character lines (vs neutral bull for BOS).")
c_inBearBreak = input.color(#ff1744, "Bear CHoCH",       group = s_gClr, inline = "r6",  tooltip = "Colour for bearish Change-of-Character lines.")
c_inInt   = input.color(#78909c, "Internal LQ",      group = s_gClr, inline = "r7",  tooltip = "Colour for internal liquidity markers.")
c_inSweep   = input.color(#b388ff, "Sweep",            group = s_gClr, inline = "r7",  tooltip = "Colour for sweep labels.")
c_inIdm   = input.color(#00bcd4, "IDM",              group = s_gClr, inline = "r8",  tooltip = "Colour for inducement labels.")
c_inReversal   = input.color(#e040fb, "Reversal",         group = s_gClr, inline = "r8",  tooltip = "Colour for Reversal Confirmed markers.")
c_inSmt   = input.color(#ff4081, "SMT",              group = s_gClr, inline = "r9",  tooltip = "Colour for SMT divergence labels.")
c_inVi    = input.color(#7e57c2, "VI",               group = s_gClr, inline = "r9",  tooltip = "Colour for volume imbalance boxes.")
c_inEqu   = input.color(#b0bec5, "Equilibrium",      group = s_gClr, inline = "r10", tooltip = "Colour for the Equilibrium line in the PD range.")
c_inOte   = input.color(#ffb300, "OTE",              group = s_gClr, inline = "r10", tooltip = "Colour for the OTE retracement zone.")
c_inTier1 = input.color(#00e676, "Score tier 1 (≥80)", group = s_gClr, inline = "r11", tooltip = "Dashboard text colour for top-tier (≥80) scores.")
c_inTier2 = input.color(#26a69a, "Score tier 2 (≥60)", group = s_gClr, inline = "r11", tooltip = "Dashboard text colour for second-tier (≥60) scores.")
c_inTier3 = input.color(#ffa726, "Score tier 3 (≥40)", group = s_gClr, inline = "r12", tooltip = "Dashboard text colour for third-tier (≥40) scores.")
c_inTier4 = input.color(#78909c, "Score tier 4 (<40)", group = s_gClr, inline = "r12", tooltip = "Dashboard text colour for low-tier (<40) scores.")

// }

//Blockmarker Requests {
// Previous-period high/low requests (daily, weekly, monthly).
[f_pdh,f_pdl] = request.security(syminfo.tickerid, "D", [high[1],low[1]], lookahead = barmerge.lookahead_off)
[f_pwh,f_pwl] = request.security(syminfo.tickerid, "W", [high[1],low[1]], lookahead = barmerge.lookahead_off)
[f_pmh,f_pml] = request.security(syminfo.tickerid, "M", [high[1],low[1]], lookahead = barmerge.lookahead_off)
//}

//Blockmarker DECLARATIONS {
// SMT divergence reference symbol (defaults to current ticker if blank).
s_smtTk = s_smtSymbol == "" ? syminfo.tickerid : s_smtSymbol
[f_smtHi, f_smtLo] = request.security(s_smtTk, timeframe.period, [high, low], lookahead = barmerge.lookahead_off)

// --- Top-level series (ATR + pivots) - evaluated each bar ---
f_atrV = ta.atr(200)
f_phSw = ta.pivothigh(high, i_swLen, i_swLen)
f_plSw = ta.pivotlow(low, i_swLen, i_swLen)
f_phIn = ta.pivothigh(high, i_inLen, i_inLen)
f_plIn = ta.pivotlow(low, i_inLen, i_inLen)

// --- Composite relevance score variables ---
int i_wTot = i_wConfl + i_wFresh + i_wDispl + i_wTrend + i_wProx
float f_wSum = i_wTot > 0 ? float(i_wTot) : 1.0
float f_tol = f_conflTol * f_atrV
float f_proxDenom = math.max(1.0, float(i_proxBars) * f_atrV)

// ─── Palette resolution (schema-driven color assignment) ─────────────────
// Schema resolution: Dark/Light use hardcoded presets, Default uses color inputs
bool b_sDk = e_schema == Schema.DARK
bool b_sLt = e_schema == Schema.LIGHT
c_bull = b_sDk ? #00e676 : b_sLt ? #00695c : c_inBull
c_bear = b_sDk ? #ff1744 : b_sLt ? #b71c1c : c_inBear
c_bsl  = b_sDk ? #29b6f6 : b_sLt ? #1565c0 : c_inBsl
c_ssl  = b_sDk ? #ffb74d : b_sLt ? #e65100 : c_inSsl
c_bpr  = b_sDk ? #d500f9 : b_sLt ? #6a1b9a : c_inBpr
c_eq   = b_sDk ? #ffea00 : b_sLt ? #f57f17 : c_inEq
c_pdh  = b_sDk ? #29b6f6 : b_sLt ? #1565c0 : c_inPdh
c_pwh  = b_sDk ? #d500f9 : b_sLt ? #6a1b9a : c_inPwh
c_pmh  = b_sDk ? #ffb74d : b_sLt ? #e65100 : c_inPmh
c_bullBreak = b_sDk ? #00ff7f : b_sLt ? #2e7d32 : c_inBullBreak
c_bearBreak = b_sDk ? #ff5252 : b_sLt ? #c62828 : c_inBearBreak
c_intLq  = b_sDk ? #90a4ae : b_sLt ? #455a64 : c_inInt
c_sweep   = b_sDk ? #d1c4e9 : b_sLt ? #5e35b1 : c_inSweep
c_idm  = b_sDk ? #4dd0e1 : b_sLt ? #006064 : c_inIdm
c_reversal   = b_sDk ? #ea80fc : b_sLt ? #8e24aa : c_inReversal
c_smt  = b_sDk ? #ff80ab : b_sLt ? #ad1457 : c_inSmt
c_viBorder  = b_sDk ? #9575cd : b_sLt ? #4527a0 : c_inVi
c_breakerBg  = color.new(b_sLt ? #b0bec5 : #78909c, 85)
c_viBg  = color.new(c_viBorder, 80)
c_equilibrium  = b_sDk ? #cfd8dc : b_sLt ? #607d8b : c_inEqu
c_oteHex = b_sDk ? #ffb300 : b_sLt ? #ff6f00 : c_inOte
c_oteAlpha  = color.new(c_oteHex, 60)
c_tier1 = b_sDk ? #69f0ae : b_sLt ? #00c853 : c_inTier1
c_tier2 = b_sDk ? #4db6ac : b_sLt ? #00897b : c_inTier2
c_tier3 = b_sDk ? #ffb74d : b_sLt ? #ef6c00 : c_inTier3
c_tier4 = b_sDk ? #b0bec5 : b_sLt ? #546e7a : c_inTier4
// Dashboard chrome (e_schema-derived only)
c_dashBg        = b_sLt ? color.new(#f5f5f5, 20) : b_sDk ? color.new(#0a0a0a, 20) : color.new(#1e1e1e, 30)
c_dashBorder    = b_sLt ? color.new(#90a4ae, 50) : color.new(#444444, 50)
c_dashTitleTx   = b_sLt ? color.rgb(33, 33, 33)  : color.white
c_dashTitleBg   = b_sLt ? color.new(#cfd8dc, 20) : color.new(#263238, 20)
c_dashHeaderBg  = b_sLt ? color.new(#e0e0e0, 30) : color.new(#37474f, 30)
c_dashHeaderTx  = b_sLt ? color.rgb(66, 66, 66)  : #b0bec5
c_dashBodyTx    = b_sLt ? color.rgb(55, 71, 79)  : #cfd8dc
c_dashEmptyTx   = b_sLt ? color.new(#cfd8dc, 50) : color.new(#555555, 50)
sz_label = s_lblSzInp == "tiny" ? size.tiny : s_lblSzInp == "small" ? size.small : s_lblSzInp == "large" ? size.large : size.normal
sz_dash = s_dashSize == "tiny" ? size.tiny : s_dashSize == "normal" ? size.normal : size.small

// ─── Persistent state (var declarations) ────────────────────────────────
var float f_swH = na
var int i_swHx = na
var bool b_swHBroken = false
var float f_swL = na
var int i_swLx = na
var bool b_swLBroken = false
var int i_swTrend = 0
var float f_inH = na
var int i_inHx = na
var bool b_inHBroken = false
var float f_inL = na
var int i_inLx = na
var bool b_inLBroken = false
var int i_inTrend = 0
var float f_prevPHi = na
var int i_prevPHix = na
var float f_prevSmtPHi = na
var float f_prevPLo = na
var int i_prevPLox = na
var float f_prevSmtPLo = na
var int i_swSweepHiBar = na
var int i_swSweepLoBar = na
// BSL: line, label, price, f_displ, creation bar, score
var array<line>  arr_bslLn = array.new<line>()
var array<label> arr_bslLb = array.new<label>()
var array<float> arr_bslPr = array.new<float>()
var array<float> arr_bslDi = array.new<float>()
var array<int>   arr_bslBr = array.new<int>()
var array<float> arr_bslSc = array.new<float>()
// SSL
var array<line>  arr_sslLn = array.new<line>()
var array<label> arr_sslLb = array.new<label>()
var array<float> arr_sslPr = array.new<float>()
var array<float> arr_sslDi = array.new<float>()
var array<int>   arr_sslBr = array.new<int>()
var array<float> arr_sslSc = array.new<float>()
// Bull OB
var array<box>   arr_bullObBx = array.new<box>()
var array<label> arr_bullObLb = array.new<label>()
var array<float> arr_bullObT = array.new<float>()
var array<float> arr_bullObB = array.new<float>()
var array<float> arr_bullObDi = array.new<float>()
var array<int>   arr_bullObBr = array.new<int>()
var array<float> arr_bullObSc = array.new<float>()
// Bear OB
var array<box>   arr_bearObBx = array.new<box>()
var array<label> arr_bearObLb = array.new<label>()
var array<float> arr_bearObT = array.new<float>()
var array<float> arr_bearObB = array.new<float>()
var array<float> arr_bearObDi = array.new<float>()
var array<int>   arr_bearObBr = array.new<int>()
var array<float> arr_bearObSc = array.new<float>()
// Bull FVG
var array<float> arr_bFvgT = array.new<float>()
var array<float> arr_bFvgB = array.new<float>()
var array<int>   arr_bFvgBr = array.new<int>()
var array<box>   arr_bFvgBx = array.new<box>()
var array<line>  arr_bFvgMd = array.new<line>()
var array<label> arr_bFvgLb = array.new<label>()
var array<float> arr_bFvgDi = array.new<float>()
var array<float> arr_bFvgSc = array.new<float>()
// Bear FVG
var array<float> arr_sFvgT = array.new<float>()
var array<float> arr_sFvgB = array.new<float>()
var array<int>   arr_sFvgBr = array.new<int>()
var array<box>   arr_sFvgBx = array.new<box>()
var array<line>  arr_sFvgMd = array.new<line>()
var array<label> arr_sFvgLb = array.new<label>()
var array<float> arr_sFvgDi = array.new<float>()
var array<float> arr_sFvgSc = array.new<float>()
// BPR
var array<box>   arr_bprBx = array.new<box>()
var array<label> arr_bprLb = array.new<label>()
var array<float> arr_bprT = array.new<float>()
var array<float> arr_bprB = array.new<float>()
var array<int>   arr_bprCr = array.new<int>()
var array<float> arr_bprDi = array.new<float>()
var array<float> arr_bprSc = array.new<float>()
// EQH/EQL (combined, direction stored)
var array<line>  arr_eqLn = array.new<line>()
var array<label> arr_eqLb = array.new<label>()
var array<float> arr_eqPr = array.new<float>()
var array<int>   arr_eqBr = array.new<int>()
var array<bool>  arr_eqIsBull = array.new<bool>()
var array<float> arr_eqSc = array.new<float>()
// VI (capped, not scored)
var array<box>   arr_viBx = array.new<box>()
var array<label> arr_viLb = array.new<label>()
// BOS/CHoCH lines (capped, not scored — historical markers)
var array<line>  arr_swBosLn = array.new<line>()
var array<label> arr_swBosLb = array.new<label>()
var array<line>  arr_intBosLn = array.new<line>()
var array<label> arr_intBosLb = array.new<label>()
// INT_LQ (capped, not scored)
var array<line>  arr_intLqLn = array.new<line>()
var array<label> arr_intLqLb = array.new<label>()
// Marker labels (capped, not scored)
var array<label> arr_sweepLb = array.new<label>()
var array<label> arr_idmLb = array.new<label>()
var array<label> arr_spLb = array.new<label>()
var array<label> arr_revLb = array.new<label>()
var array<label> arr_smtLb = array.new<label>()
// IDM lookup pivot history
var array<float> arr_intLowVal = array.new<float>()
var array<int>   arr_intLowBar = array.new<int>()
var array<float> arr_intHighVal = array.new<float>()
var array<int>   arr_intHighBar = array.new<int>()
// PD lines + labels (reused)
var line ln_premium = na
var line ln_equilibrium = na
var line ln_discount = na
var line ln_oteTop = na
var line ln_oteBot = na
var label lb_premium = na
var label lb_equilibrium = na
var label lb_discount = na
var label lb_ote = na
var label lb_pdh = na
var label lb_pdl = na
var label lb_pwh = na
var label lb_pwl = na
var label lb_pmh = na
var label lb_pml = na
// Dashboard
var table tb_dashboard = na
// }

//Blockmarker FUNCTIONS {
// @function    f_mkLabel
// @description Create a label with a background-tinted color (85% alpha) and text color.
// @param       x       int     bar_index x-coordinate
// @param       y       float   price y-coordinate
// @param       s_txt   string  label text
// @param       c_bg    color   background tint color
// @param       c_tc    color   text color
// @param       s_sty   string  style direction ("left", "down", or "up")
// @returns     label   the created label object
f_mkLabel(int x, float y, string s_txt, color c_bg, color c_tc, string s_sty) =>
    s = s_sty == "left" ? label.style_label_left : s_sty == "down" ? label.style_label_down : label.style_label_up
    label.new(x, y, s_txt, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(c_bg, 85), textcolor = c_tc, style = s, size = sz_label)

// @function    f_mkTextLabel
// @description Create a small text-only label (no background) above or below price.
// @param       x       int     bar_index x-coordinate
// @param       y       float   price y-coordinate
// @param       s_txt   string  label text
// @param       c       color   text color
// @param       b_ab    bool    true = anchor above price, false = below
// @returns     label   the created label object
f_mkTextLabel(int x, float y, string s_txt, color c, bool b_ab) =>
    label.new(x, y, s_txt, xloc = xloc.bar_index, yloc = yloc.price, color = color(na), textcolor = c, style = b_ab ? label.style_label_down : label.style_label_up, size = size.tiny)
// @function    f_capLL
// @description Cap a parallel pair of line+label arrays to size c by shifting oldest off the front.
// @param       a       array<line>     line array
// @param       b       array<label>    label array (parallel to a)
// @param       c       int             max size to retain
// @returns     void
f_capLL(array<line> a, array<label> b, int c) =>
    while array.size(a) > c
        line.delete(array.shift(a))
        label.delete(array.shift(b))
// @function    f_capLbl
// @description Cap a label array to size c by shifting oldest off the front.
// @param       a       array<label>    label array
// @param       c       int             max size to retain
// @returns     void
f_capLbl(array<label> a, int c) =>
    while array.size(a) > c
        label.delete(array.shift(a))
// @function    f_capBL
// @description Cap a parallel pair of box+label arrays to size c by shifting oldest off the front.
// @param       a       array<box>      box array
// @param       b       array<label>    label array (parallel to a)
// @param       c       int             max size to retain
// @returns     void
f_capBL(array<box> a, array<label> b, int c) =>
    while array.size(a) > c
        box.delete(array.shift(a))
        label.delete(array.shift(b))

// @function    f_scoreAlpha
// @description Convert a 0-100 score to a Pine alpha (0-95). Higher score = lower alpha = more opaque.
// @param       f_sc    float   score in 0-100
// @returns     int     alpha in 0-95
f_scoreAlpha(float f_sc) =>
    int a = math.round(95.0 - f_sc * 0.85)
    math.max(0, math.min(95, a))

// @function    f_recolorBox
// @description Update an OB/BPR box and its label colour based on relevance score.
// @param       bx      box     the box to recolour
// @param       lb      label   the label to recolour
// @param       c_hex   color   base hex color
// @param       f_sc    float   relevance score (0-100)
// @returns     void
f_recolorBox(box bx, label lb, color c_hex, float f_sc) =>
    int a = f_scoreAlpha(f_sc)
    box.set_bgcolor(bx, color.new(c_hex, math.min(95, a + 5)))
    box.set_border_color(bx, color.new(c_hex, math.max(0, a - 30)))
    label.set_color(lb, color.new(c_hex, math.min(95, a + 10)))
    label.set_textcolor(lb, color.new(c_hex, math.max(0, a - 50)))

// @function    f_recolorFVG
// @description Update an FVG box, its midline, and its label colour based on relevance score.
// @param       bx      box     the box to recolour
// @param       md      line    the FVG midline
// @param       lb      label   the label to recolour
// @param       c_hex   color   base hex color
// @param       f_sc    float   relevance score (0-100)
// @returns     void
f_recolorFVG(box bx, line md, label lb, color c_hex, float f_sc) =>
    int a = f_scoreAlpha(f_sc)
    box.set_bgcolor(bx, color.new(c_hex, math.min(95, a + 5)))
    box.set_border_color(bx, color.new(c_hex, math.max(0, a - 30)))
    line.set_color(md, color.new(c_hex, math.max(0, a - 20)))
    label.set_color(lb, color.new(c_hex, math.min(95, a + 10)))
    label.set_textcolor(lb, color.new(c_hex, math.max(0, a - 50)))

// @function    f_recolorLine
// @description Update a BSL/SSL/INT-LQ line and its label colour based on relevance score.
// @param       ln      line    the line to recolour
// @param       lb      label   the label to recolour
// @param       c_hex   color   base hex color
// @param       f_sc    float   relevance score (0-100)
// @returns     void
f_recolorLine(line ln, label lb, color c_hex, float f_sc) =>
    int a = f_scoreAlpha(f_sc)
    line.set_color(ln, color.new(c_hex, math.max(0, a - 30)))
    label.set_color(lb, color.new(c_hex, math.min(95, a + 10)))
    label.set_textcolor(lb, color.new(c_hex, math.max(0, a - 50)))

// @function    f_overlap
// @description Test whether two price ranges overlap, allowing a tolerance band.
// @param       f_tA    float   range A top
// @param       f_bA    float   range A bottom
// @param       f_tB    float   range B top
// @param       f_bB    float   range B bottom
// @param       f_tol   float   tolerance (positive widens the overlap criterion)
// @returns     bool    true if the ranges overlap within tolerance
f_overlap(float f_tA, float f_bA, float f_tB, float f_bB, float f_tol) =>
    math.min(f_tA, f_tB) - math.max(f_bA, f_bB) + f_tol > 0

// @function    f_stars
// @description Convert a 0-100 score to a 5-star Unicode string.
// @param       f_sc    float   score in 0-100
// @returns     string  five-character star rating
f_stars(float f_sc) =>
    int n = math.floor(f_sc / 20)
    n == 0 ? "☆☆☆☆☆" : n == 1 ? "★☆☆☆☆" : n == 2 ? "★★☆☆☆" : n == 3 ? "★★★☆☆" : n == 4 ? "★★★★☆" : "★★★★★"

// @function    f_tierColor
// @description Map a 0-100 score to one of four tier colours (tier1=highest, tier4=lowest).
// @param       f_sc    float   score in 0-100
// @returns     color   tier colour
f_tierColor(float f_sc) =>
    f_sc >= 80 ? c_tier1 : f_sc >= 60 ? c_tier2 : f_sc >= 40 ? c_tier3 : c_tier4

// @function    f_insertTopN
// @description Insert a record into sorted top-N parallel arrays (descending by score). Index 0 holds the highest score; index n-1 the lowest.
// @param       arr_sc   array<float>    score array (sorted descending, will be updated in place)
// @param       arr_tp   array<string>   type-label array (parallel)
// @param       arr_pr   array<float>    price array (parallel)
// @param       arr_dr   array<string>   direction-symbol array (parallel)
// @param       arr_ag   array<int>      age-in-bars array (parallel)
// @param       n        int             fixed array size (top-N cap)
// @param       f_newSc  float           new record score
// @param       s_newTp  string          new record type label
// @param       f_newPr  float           new record price
// @param       s_newDr  string          new record direction symbol
// @param       i_newAg  int             new record age in bars
// @returns     void    (arrays updated in place)
f_insertTopN(array<float> arr_sc, array<string> arr_tp, array<float> arr_pr, array<string> arr_dr, array<int> arr_ag, int n, float f_newSc, string s_newTp, float f_newPr, string s_newDr, int i_newAg) =>
    if f_newSc > array.get(arr_sc, n - 1)
        int i_slot = 0
        while i_slot < n and array.get(arr_sc, i_slot) >= f_newSc
            i_slot += 1
        int i_kk = n - 1
        while i_kk > i_slot
            array.set(arr_sc, i_kk, array.get(arr_sc, i_kk - 1))
            array.set(arr_tp, i_kk, array.get(arr_tp, i_kk - 1))
            array.set(arr_pr, i_kk, array.get(arr_pr, i_kk - 1))
            array.set(arr_dr, i_kk, array.get(arr_dr, i_kk - 1))
            array.set(arr_ag, i_kk, array.get(arr_ag, i_kk - 1))
            i_kk -= 1
        array.set(arr_sc, i_slot, f_newSc)
        array.set(arr_tp, i_slot, s_newTp)
        array.set(arr_pr, i_slot, f_newPr)
        array.set(arr_dr, i_slot, s_newDr)
        array.set(arr_ag, i_slot, i_newAg)

// @function    f_confluence
// @description Count how many other zones/points overlap a given zone, within tolerance, excluding the zone itself.
// @param       f_zT       float    zone top
// @param       f_zB       float    zone bottom
// @param       s_selfTag  string   two-letter tag identifying which array the zone belongs to (e.g. "bF" for bull FVG)
// @param       i_selfIdx  int      the zone's index in its own array, used to skip self-comparison
// @returns     int        confluence count (number of overlapping zones/points across all sources)
f_confluence(float f_zT, float f_zB, string s_selfTag, int i_selfIdx) =>
    int i_cnt = 0
    int n = 0
    int k = 0
    // Bull FVG
    n := array.size(arr_bFvgT)
    k := 0
    while k < n
        if not (s_selfTag == "bF" and k == i_selfIdx)
            if f_overlap(f_zT, f_zB, array.get(arr_bFvgT, k), array.get(arr_bFvgB, k), f_tol)
                i_cnt += 1
        k += 1
    // Bear FVG
    n := array.size(arr_sFvgT)
    k := 0
    while k < n
        if not (s_selfTag == "sF" and k == i_selfIdx)
            if f_overlap(f_zT, f_zB, array.get(arr_sFvgT, k), array.get(arr_sFvgB, k), f_tol)
                i_cnt += 1
        k += 1
    // Bull OB
    n := array.size(arr_bullObT)
    k := 0
    while k < n
        if not (s_selfTag == "bO" and k == i_selfIdx)
            if f_overlap(f_zT, f_zB, array.get(arr_bullObT, k), array.get(arr_bullObB, k), f_tol)
                i_cnt += 1
        k += 1
    // Bear OB
    n := array.size(arr_bearObT)
    k := 0
    while k < n
        if not (s_selfTag == "eO" and k == i_selfIdx)
            if f_overlap(f_zT, f_zB, array.get(arr_bearObT, k), array.get(arr_bearObB, k), f_tol)
                i_cnt += 1
        k += 1
    // BPR
    n := array.size(arr_bprT)
    k := 0
    while k < n
        if not (s_selfTag == "bp" and k == i_selfIdx)
            if f_overlap(f_zT, f_zB, array.get(arr_bprT, k), array.get(arr_bprB, k), f_tol)
                i_cnt += 1
        k += 1
    // BSL (point)
    n := array.size(arr_bslPr)
    k := 0
    while k < n
        if not (s_selfTag == "bL" and k == i_selfIdx)
            float p = array.get(arr_bslPr, k)
            if f_overlap(f_zT, f_zB, p + f_tol / 2, p - f_tol / 2, f_tol)
                i_cnt += 1
        k += 1
    // SSL (point)
    n := array.size(arr_sslPr)
    k := 0
    while k < n
        if not (s_selfTag == "sL" and k == i_selfIdx)
            float p = array.get(arr_sslPr, k)
            if f_overlap(f_zT, f_zB, p + f_tol / 2, p - f_tol / 2, f_tol)
                i_cnt += 1
        k += 1
    // EQ (point)
    n := array.size(arr_eqPr)
    k := 0
    while k < n
        if not (s_selfTag == "eq" and k == i_selfIdx)
            float p = array.get(arr_eqPr, k)
            if f_overlap(f_zT, f_zB, p + f_tol / 2, p - f_tol / 2, f_tol)
                i_cnt += 1
        k += 1
    // PDH/PDL/etc
    if b_showPDH and not na(f_pdh)
        if f_overlap(f_zT, f_zB, f_pdh + f_tol / 2, f_pdh - f_tol / 2, f_tol)
            i_cnt += 1
    if b_showPDH and not na(f_pdl)
        if f_overlap(f_zT, f_zB, f_pdl + f_tol / 2, f_pdl - f_tol / 2, f_tol)
            i_cnt += 1
    if b_showPWH and not na(f_pwh)
        if f_overlap(f_zT, f_zB, f_pwh + f_tol / 2, f_pwh - f_tol / 2, f_tol)
            i_cnt += 1
    if b_showPWH and not na(f_pwl)
        if f_overlap(f_zT, f_zB, f_pwl + f_tol / 2, f_pwl - f_tol / 2, f_tol)
            i_cnt += 1
    if b_showPMH and not na(f_pmh)
        if f_overlap(f_zT, f_zB, f_pmh + f_tol / 2, f_pmh - f_tol / 2, f_tol)
            i_cnt += 1
    if b_showPMH and not na(f_pml)
        if f_overlap(f_zT, f_zB, f_pml + f_tol / 2, f_pml - f_tol / 2, f_tol)
            i_cnt += 1
    i_cnt

// @function    f_score
// @description Compute a 0-100 composite relevance score for a zone, combining confluence, freshness, displacement, trend alignment, and proximity to current price.
// @param       f_zT       float   zone top
// @param       f_zB       float   zone bottom
// @param       f_displ    float   displacement size (in price units) of the move that created the zone
// @param       i_creBar   int     bar_index at which the zone was created
// @param       b_isBull   bool    true for bullish zones (used in trend-alignment factor)
// @param       b_bidir    bool    true for bidirectional zones (BPR / EQ) — gives full trend credit either way
// @param       s_selfTag  string  see f_confluence
// @param       i_selfIdx  int     see f_confluence
// @returns     float      score in 0-100
f_score(float f_zT, float f_zB, float f_displ, int i_creBar, bool b_isBull, bool b_bidir, string s_selfTag, int i_selfIdx) =>
    int i_confl = f_confluence(f_zT, f_zB, s_selfTag, i_selfIdx)
    float f_fConfl = math.min(i_confl / 4.0, 1.0)
    float f_fFresh = math.exp(-(bar_index - i_creBar) / math.max(1.0, float(i_decayBars)))
    float f_fDispl = math.min(f_displ / math.max(0.0001, f_atrV) / 2.0, 1.0)
    float f_fTrend = b_bidir ? 1.0 : (b_isBull ? (i_swTrend == 1 ? 1.0 : 0.5) : (i_swTrend == -1 ? 1.0 : 0.5))
    float f_zPrice = (f_zT + f_zB) / 2
    float f_fProx = 1.0 - math.min(math.abs(f_zPrice - close) / f_proxDenom, 1.0)
    100.0 * (i_wConfl * f_fConfl + i_wFresh * f_fFresh + i_wDispl * f_fDispl + i_wTrend * f_fTrend + i_wProx * f_fProx) / f_wSum

// @function    f_lblText
// @description Return the zone label text, optionally suffixed with the score in brackets.
// @param       s_base   string  base label text (e.g. "Bull OB")
// @param       f_sc     float   score in 0-100
// @returns     string   "Bull OB" or "Bull OB [82]" depending on b_showScoreInLabel
f_lblText(string s_base, float f_sc) =>
    b_showScoreInLabel ? s_base + " [" + str.tostring(math.round(f_sc)) + "]" : s_base

// @function    f_swingRange
// @description Returns the current swing-range size, or ATR fallback if no swings exist yet.
// @returns     float       abs(f_swH - f_swL), or f_atrV when either is na.
f_swingRange() => not na(f_swH) and not na(f_swL) ? math.abs(f_swH - f_swL) : f_atrV
// }

//Blockmarker EXECUTION {
// (Variables and palette/states were moved to Declarations)


// ─── PDH / PDL / PWH / PWL / PMH / PML right-edge label updates ─────────
if barstate.islast
    int i_rx0 = bar_index + 5
    if b_showPDH
        if na(lb_pdh)
            lb_pdh := label.new(i_rx0, f_pdh, "PDH", xloc = xloc.bar_index, color = color(na), textcolor = c_pdh, style = label.style_label_left, size = size.tiny)
            lb_pdl := label.new(i_rx0, f_pdl, "PDL", xloc = xloc.bar_index, color = color(na), textcolor = c_pdh, style = label.style_label_left, size = size.tiny)
        else
            label.set_x(lb_pdh, i_rx0)
            label.set_y(lb_pdh, f_pdh)
            label.set_x(lb_pdl, i_rx0)
            label.set_y(lb_pdl, f_pdl)
    if b_showPWH
        if na(lb_pwh)
            lb_pwh := label.new(i_rx0, f_pwh, "PWH", xloc = xloc.bar_index, color = color(na), textcolor = c_pwh, style = label.style_label_left, size = size.tiny)
            lb_pwl := label.new(i_rx0, f_pwl, "PWL", xloc = xloc.bar_index, color = color(na), textcolor = c_pwh, style = label.style_label_left, size = size.tiny)
        else
            label.set_x(lb_pwh, i_rx0)
            label.set_y(lb_pwh, f_pwh)
            label.set_x(lb_pwl, i_rx0)
            label.set_y(lb_pwl, f_pwl)
    if b_showPMH
        if na(lb_pmh)
            lb_pmh := label.new(i_rx0, f_pmh, "PMH", xloc = xloc.bar_index, color = color(na), textcolor = c_pmh, style = label.style_label_left, size = size.tiny)
            lb_pml := label.new(i_rx0, f_pml, "PML", xloc = xloc.bar_index, color = color(na), textcolor = c_pmh, style = label.style_label_left, size = size.tiny)
        else
            label.set_x(lb_pmh, i_rx0)
            label.set_y(lb_pmh, f_pmh)
            label.set_x(lb_pml, i_rx0)
            label.set_y(lb_pml, f_pml)


// ─── Main SMC detection logic (swing pivots → BOS / CHoCH → OB → FVG → BPR → mitigation → merge → scoring → dynamic extension) ─
// ════════════════════════ 8.  SWING PIVOTS ══════════════════════════════════
if not na(f_phSw)
    int i_pv = bar_index - i_swLen
    float f_smp = f_smtHi[i_swLen]
    if b_showEQ and not na(f_prevPHi) and math.abs(f_phSw - f_prevPHi) <= f_eqAtr * f_atrV
        array.push(arr_eqLn, line.new(i_prevPHix, f_prevPHi, i_pv, f_phSw, xloc = xloc.bar_index, color = c_eq, style = line.style_dotted, width = 2))
        array.push(arr_eqLb, f_mkLabel(i_pv + 2, f_phSw, s_lblEQH, c_eq, c_eq, "left"))
        array.push(arr_eqPr, (f_phSw + f_prevPHi) / 2)
        array.push(arr_eqBr, i_pv)
        array.push(arr_eqIsBull, true)
        array.push(arr_eqSc, 0.0)
        while array.size(arr_eqLn) > i_capEQL
            line.delete(array.shift(arr_eqLn))
            label.delete(array.shift(arr_eqLb))
            array.shift(arr_eqPr)
            array.shift(arr_eqBr)
            array.shift(arr_eqIsBull)
            array.shift(arr_eqSc)
    if b_showSP and not na(f_prevPHi)
        array.push(arr_spLb, f_mkTextLabel(i_pv, f_phSw, f_phSw > f_prevPHi ? "HH" : "LH", c_bull, true))
        f_capLbl(arr_spLb, i_capSPL)
    if b_showSMT and not na(f_prevPHi) and not na(f_prevSmtPHi)
        if f_phSw > f_prevPHi and f_smp <= f_prevSmtPHi
            array.push(arr_smtLb, f_mkLabel(i_pv, f_phSw, s_lblSMTe, c_smt, c_smt, "down"))
            f_capLbl(arr_smtLb, i_capSMTl)
    if b_showIDM and not na(i_prevPHix)
        int i_idx = array.size(arr_intLowBar) - 1
        int i_ib2 = na
        float f_iv2 = na
        while i_idx >= 0
            int i_b2 = array.get(arr_intLowBar, i_idx)
            float f_v2 = array.get(arr_intLowVal, i_idx)
            if i_b2 > i_prevPHix and i_b2 < i_pv
                if na(i_ib2) or f_v2 < f_iv2
                    i_ib2 := i_b2
                    f_iv2 := f_v2
            i_idx -= 1
        if not na(i_ib2)
            array.push(arr_idmLb, f_mkLabel(i_ib2, f_iv2, s_lblIDM, c_idm, c_idm, "b_up"))
            f_capLbl(arr_idmLb, i_capIDM)
    f_swH := f_phSw
    i_swHx := i_pv
    b_swHBroken := false
    f_prevPHi := f_phSw
    i_prevPHix := i_pv
    f_prevSmtPHi := f_smp
    if b_showBSL
        array.push(arr_bslLn, line.new(i_pv, f_phSw, bar_index + i_extendBars, f_phSw, xloc = xloc.bar_index, color = c_bsl, style = line.style_solid, width = 1))
        array.push(arr_bslLb, f_mkLabel(bar_index + i_extendBars, f_phSw, s_lblBSL, c_bsl, c_bsl, "left"))
        array.push(arr_bslPr, f_phSw)
        array.push(arr_bslDi, f_swingRange())
        array.push(arr_bslBr, i_pv)
        array.push(arr_bslSc, 0.0)
        while array.size(arr_bslLn) > i_capLQ
            line.delete(array.shift(arr_bslLn))
            label.delete(array.shift(arr_bslLb))
            array.shift(arr_bslPr)
            array.shift(arr_bslDi)
            array.shift(arr_bslBr)
            array.shift(arr_bslSc)

if not na(f_plSw)
    int i_pv = bar_index - i_swLen
    float f_smp = f_smtLo[i_swLen]
    if b_showEQ and not na(f_prevPLo) and math.abs(f_plSw - f_prevPLo) <= f_eqAtr * f_atrV
        array.push(arr_eqLn, line.new(i_prevPLox, f_prevPLo, i_pv, f_plSw, xloc = xloc.bar_index, color = c_eq, style = line.style_dotted, width = 2))
        array.push(arr_eqLb, f_mkLabel(i_pv + 2, f_plSw, s_lblEQL, c_eq, c_eq, "left"))
        array.push(arr_eqPr, (f_plSw + f_prevPLo) / 2)
        array.push(arr_eqBr, i_pv)
        array.push(arr_eqIsBull, false)
        array.push(arr_eqSc, 0.0)
        while array.size(arr_eqLn) > i_capEQL
            line.delete(array.shift(arr_eqLn))
            label.delete(array.shift(arr_eqLb))
            array.shift(arr_eqPr)
            array.shift(arr_eqBr)
            array.shift(arr_eqIsBull)
            array.shift(arr_eqSc)
    if b_showSP and not na(f_prevPLo)
        array.push(arr_spLb, f_mkTextLabel(i_pv, f_plSw, f_plSw > f_prevPLo ? "HL" : "LL", c_bear, false))
        f_capLbl(arr_spLb, i_capSPL)
    if b_showSMT and not na(f_prevPLo) and not na(f_prevSmtPLo)
        if f_plSw < f_prevPLo and f_smp >= f_prevSmtPLo
            array.push(arr_smtLb, f_mkLabel(i_pv, f_plSw, s_lblSMTu, c_smt, c_smt, "b_up"))
            f_capLbl(arr_smtLb, i_capSMTl)
    if b_showIDM and not na(i_prevPLox)
        int i_idx = array.size(arr_intHighBar) - 1
        int i_ib2 = na
        float f_iv2 = na
        while i_idx >= 0
            int i_b2 = array.get(arr_intHighBar, i_idx)
            float f_v2 = array.get(arr_intHighVal, i_idx)
            if i_b2 > i_prevPLox and i_b2 < i_pv
                if na(i_ib2) or f_v2 > f_iv2
                    i_ib2 := i_b2
                    f_iv2 := f_v2
            i_idx -= 1
        if not na(i_ib2)
            array.push(arr_idmLb, f_mkLabel(i_ib2, f_iv2, s_lblIDM, c_idm, c_idm, "down"))
            f_capLbl(arr_idmLb, i_capIDM)
    f_swL := f_plSw
    i_swLx := i_pv
    b_swLBroken := false
    f_prevPLo := f_plSw
    i_prevPLox := i_pv
    f_prevSmtPLo := f_smp
    if b_showSSL
        array.push(arr_sslLn, line.new(i_pv, f_plSw, bar_index + i_extendBars, f_plSw, xloc = xloc.bar_index, color = c_ssl, style = line.style_solid, width = 1))
        array.push(arr_sslLb, f_mkLabel(bar_index + i_extendBars, f_plSw, s_lblSSL, c_ssl, c_ssl, "left"))
        array.push(arr_sslPr, f_plSw)
        array.push(arr_sslDi, f_swingRange())
        array.push(arr_sslBr, i_pv)
        array.push(arr_sslSc, 0.0)
        while array.size(arr_sslLn) > i_capLQ
            line.delete(array.shift(arr_sslLn))
            label.delete(array.shift(arr_sslLb))
            array.shift(arr_sslPr)
            array.shift(arr_sslDi)
            array.shift(arr_sslBr)
            array.shift(arr_sslSc)

// ════════════════════════ 9.  INTERNAL PIVOTS ═══════════════════════════════
if not na(f_phIn)
    f_inH := f_phIn
    i_inHx := bar_index - i_inLen
    b_inHBroken := false
    array.push(arr_intHighVal, f_phIn)
    array.push(arr_intHighBar, i_inHx)
    while array.size(arr_intHighVal) > 60
        array.shift(arr_intHighVal)
        array.shift(arr_intHighBar)
    if b_showINT
        array.push(arr_intLqLn, line.new(i_inHx, f_inH, bar_index + i_extendBars, f_inH, xloc = xloc.bar_index, color = c_intLq, style = line.style_dashed, width = 1))
        array.push(arr_intLqLb, f_mkLabel(bar_index + i_extendBars, f_inH, s_lblINT, c_intLq, c_intLq, "left"))
        f_capLL(arr_intLqLn, arr_intLqLb, i_capINTLQ)
if not na(f_plIn)
    f_inL := f_plIn
    i_inLx := bar_index - i_inLen
    b_inLBroken := false
    array.push(arr_intLowVal, f_plIn)
    array.push(arr_intLowBar, i_inLx)
    while array.size(arr_intLowVal) > 60
        array.shift(arr_intLowVal)
        array.shift(arr_intLowBar)
    if b_showINT
        array.push(arr_intLqLn, line.new(i_inLx, f_inL, bar_index + i_extendBars, f_inL, xloc = xloc.bar_index, color = c_intLq, style = line.style_dashed, width = 1))
        array.push(arr_intLqLb, f_mkLabel(bar_index + i_extendBars, f_inL, s_lblINT, c_intLq, c_intLq, "left"))
        f_capLL(arr_intLqLn, arr_intLqLb, i_capINTLQ)

// ════════════════════════ 10.  SWEEP ════════════════════════════════════════
b_hiSweepNow = not na(f_swH) and not b_swHBroken and high > f_swH and close < f_swH
b_loSweepNow = not na(f_swL) and not b_swLBroken and low < f_swL and close > f_swL
if b_hiSweepNow
    i_swSweepHiBar := bar_index
    if b_showSwp
        array.push(arr_sweepLb, f_mkLabel(bar_index, high, s_lblSWP, c_sweep, c_sweep, "down"))
        f_capLbl(arr_sweepLb, i_capSwp)
if b_loSweepNow
    i_swSweepLoBar := bar_index
    if b_showSwp
        array.push(arr_sweepLb, f_mkLabel(bar_index, low, s_lblSWP, c_sweep, c_sweep, "b_up"))
        f_capLbl(arr_sweepLb, i_capSwp)

// ════════════════════════ 11.  SWING BREAKS ═════════════════════════════════
bool b_bullBk = not b_swHBroken and not na(f_swH) and close > f_swH
bool b_bearBk = not b_swLBroken and not na(f_swL) and close < f_swL
if b_bullBk
    bool b_isRev = i_swTrend == -1
    bool b_isCf = b_isRev and not na(i_swSweepLoBar) and bar_index - i_swSweepLoBar <= i_sweepBars
    color c_lc = b_isRev ? c_bullBreak : c_bull
    string s_tx = b_isRev ? s_lblCHO : s_lblBOS
    if b_showSw
        array.push(arr_swBosLn, line.new(i_swHx, f_swH, bar_index, f_swH, xloc = xloc.bar_index, color = c_lc, style = line.style_solid, width = b_isRev ? 2 : 1))
        array.push(arr_swBosLb, f_mkLabel(int((i_swHx + bar_index) / 2), f_swH, s_tx, c_lc, c_lc, "down"))
        f_capLL(arr_swBosLn, arr_swBosLb, i_capSwBOS)
        if b_showRev and b_isCf
            array.push(arr_revLb, f_mkLabel(bar_index, f_swH, s_lblREV, c_reversal, c_reversal, "down"))
            f_capLbl(arr_revLb, i_capRev)
    if b_showOB
        int i_oi = -1
        for i = 1 to 30 by 1
            if close[i] < open[i]
                i_oi := i
                break
        if i_oi >= 0
            float f_di = close - low[i_oi]
            if f_di >= f_obAtrMin * f_atrV
                int i_ob = bar_index - i_oi
                array.push(arr_bullObBx, box.new(i_ob, high[i_oi], bar_index + i_extendBars, low[i_oi], xloc = xloc.bar_index, bgcolor = color.new(c_bull, 82), border_color = c_bull, border_width = 1))
                array.push(arr_bullObLb, f_mkLabel(bar_index + i_extendBars, (high[i_oi] + low[i_oi]) / 2, s_lblOBu, c_bull, c_bull, "left"))
                array.push(arr_bullObT, high[i_oi])
                array.push(arr_bullObB, low[i_oi])
                array.push(arr_bullObDi, f_di)
                array.push(arr_bullObBr, bar_index)
                array.push(arr_bullObSc, 0.0)
                while array.size(arr_bullObBx) > i_capOB
                    box.delete(array.shift(arr_bullObBx))
                    label.delete(array.shift(arr_bullObLb))
                    array.shift(arr_bullObT)
                    array.shift(arr_bullObB)
                    array.shift(arr_bullObDi)
                    array.shift(arr_bullObBr)
                    array.shift(arr_bullObSc)
    b_swHBroken := true
    i_swTrend := 1
if b_bearBk
    bool b_isRev = i_swTrend == 1
    bool b_isCf = b_isRev and not na(i_swSweepHiBar) and bar_index - i_swSweepHiBar <= i_sweepBars
    color c_lc = b_isRev ? c_bearBreak : c_bear
    string s_tx = b_isRev ? s_lblCHO : s_lblBOS
    if b_showSw
        array.push(arr_swBosLn, line.new(i_swLx, f_swL, bar_index, f_swL, xloc = xloc.bar_index, color = c_lc, style = line.style_solid, width = b_isRev ? 2 : 1))
        array.push(arr_swBosLb, f_mkLabel(int((i_swLx + bar_index) / 2), f_swL, s_tx, c_lc, c_lc, "b_up"))
        f_capLL(arr_swBosLn, arr_swBosLb, i_capSwBOS)
        if b_showRev and b_isCf
            array.push(arr_revLb, f_mkLabel(bar_index, f_swL, s_lblREV, c_reversal, c_reversal, "b_up"))
            f_capLbl(arr_revLb, i_capRev)
    if b_showOB
        int i_oi = -1
        for i = 1 to 30 by 1
            if close[i] > open[i]
                i_oi := i
                break
        if i_oi >= 0
            float f_di = high[i_oi] - close
            if f_di >= f_obAtrMin * f_atrV
                int i_ob = bar_index - i_oi
                array.push(arr_bearObBx, box.new(i_ob, high[i_oi], bar_index + i_extendBars, low[i_oi], xloc = xloc.bar_index, bgcolor = color.new(c_bear, 82), border_color = c_bear, border_width = 1))
                array.push(arr_bearObLb, f_mkLabel(bar_index + i_extendBars, (high[i_oi] + low[i_oi]) / 2, s_lblOBe, c_bear, c_bear, "left"))
                array.push(arr_bearObT, high[i_oi])
                array.push(arr_bearObB, low[i_oi])
                array.push(arr_bearObDi, f_di)
                array.push(arr_bearObBr, bar_index)
                array.push(arr_bearObSc, 0.0)
                while array.size(arr_bearObBx) > i_capOB
                    box.delete(array.shift(arr_bearObBx))
                    label.delete(array.shift(arr_bearObLb))
                    array.shift(arr_bearObT)
                    array.shift(arr_bearObB)
                    array.shift(arr_bearObDi)
                    array.shift(arr_bearObBr)
                    array.shift(arr_bearObSc)
    b_swLBroken := true
    i_swTrend := -1

// ════════════════════════ 12.  INTERNAL BREAKS ══════════════════════════════
if not b_inHBroken and not na(f_inH) and close > f_inH
    bool b_ir = i_inTrend == -1
    if b_showIn
        array.push(arr_intBosLn, line.new(i_inHx, f_inH, bar_index, f_inH, xloc = xloc.bar_index, color = b_ir ? c_bullBreak : c_bull, style = line.style_dashed, width = 1))
        array.push(arr_intBosLb, f_mkLabel(int((i_inHx + bar_index) / 2), f_inH, b_ir ? s_lblCHO : s_lblBOS, c_bull, c_bull, "down"))
        f_capLL(arr_intBosLn, arr_intBosLb, i_capIntBOS)
    b_inHBroken := true
    i_inTrend := 1
if not b_inLBroken and not na(f_inL) and close < f_inL
    bool b_ir = i_inTrend == 1
    if b_showIn
        array.push(arr_intBosLn, line.new(i_inLx, f_inL, bar_index, f_inL, xloc = xloc.bar_index, color = b_ir ? c_bearBreak : c_bear, style = line.style_dashed, width = 1))
        array.push(arr_intBosLb, f_mkLabel(int((i_inLx + bar_index) / 2), f_inL, b_ir ? s_lblCHO : s_lblBOS, c_bear, c_bear, "b_up"))
        f_capLL(arr_intBosLn, arr_intBosLb, i_capIntBOS)
    b_inLBroken := true
    i_inTrend := -1

// ════════════════════════ 13.  OB to BREAKER ════════════════════════════════
int i_obi = array.size(arr_bullObBx) - 1
while i_obi >= 0
    if close < array.get(arr_bullObB, i_obi)
        if b_showBB
            box.set_bgcolor(array.get(arr_bullObBx, i_obi), c_breakerBg)
            box.set_border_color(array.get(arr_bullObBx, i_obi), c_bear)
            label bl = array.get(arr_bullObLb, i_obi)
            label.set_text(bl, s_lblBBe)
            label.set_textcolor(bl, c_bear)
        else
            box.delete(array.get(arr_bullObBx, i_obi))
            label.delete(array.get(arr_bullObLb, i_obi))
        array.remove(arr_bullObBx, i_obi)
        array.remove(arr_bullObLb, i_obi)
        array.remove(arr_bullObT, i_obi)
        array.remove(arr_bullObB, i_obi)
        array.remove(arr_bullObDi, i_obi)
        array.remove(arr_bullObBr, i_obi)
        array.remove(arr_bullObSc, i_obi)
    i_obi -= 1
i_obi := array.size(arr_bearObBx) - 1
while i_obi >= 0
    if close > array.get(arr_bearObT, i_obi)
        if b_showBB
            box.set_bgcolor(array.get(arr_bearObBx, i_obi), c_breakerBg)
            box.set_border_color(array.get(arr_bearObBx, i_obi), c_bull)
            label bl = array.get(arr_bearObLb, i_obi)
            label.set_text(bl, s_lblBBu)
            label.set_textcolor(bl, c_bull)
        else
            box.delete(array.get(arr_bearObBx, i_obi))
            label.delete(array.get(arr_bearObLb, i_obi))
        array.remove(arr_bearObBx, i_obi)
        array.remove(arr_bearObLb, i_obi)
        array.remove(arr_bearObT, i_obi)
        array.remove(arr_bearObB, i_obi)
        array.remove(arr_bearObDi, i_obi)
        array.remove(arr_bearObBr, i_obi)
        array.remove(arr_bearObSc, i_obi)
    i_obi -= 1

// ════════════════════════ 14.  FVG + BPR ════════════════════════════════════
bool b_bullFvg = low[1] > high[3]
bool b_bearFvg = high[1] < low[3]
if b_showFVG and b_bullFvg
    float f_gt = low[1]
    float f_gb = high[3]
    if not b_fvgFilt or f_gt - f_gb >= f_fvgAtr * f_atrV
        float f_mid = (f_gt + f_gb) / 2
        array.push(arr_bFvgT, f_gt)
        array.push(arr_bFvgB, f_gb)
        array.push(arr_bFvgBr, bar_index)
        array.push(arr_bFvgBx, box.new(bar_index[2], f_gt, bar_index + i_fvgExt, f_gb, xloc = xloc.bar_index, bgcolor = color.new(c_bull, 85), border_color = color.new(c_bull, 40), border_width = 1))
        array.push(arr_bFvgMd, line.new(bar_index[2], f_mid, bar_index + i_fvgExt, f_mid, xloc = xloc.bar_index, color = c_bull, style = line.style_dotted, width = 1))
        array.push(arr_bFvgLb, f_mkLabel(bar_index + i_fvgExt, f_mid, s_lblFVG, c_bull, c_bull, "left"))
        array.push(arr_bFvgDi, f_gt - f_gb)
        array.push(arr_bFvgSc, 0.0)
        while array.size(arr_bFvgT) > i_capFVG
            box.delete(array.shift(arr_bFvgBx))
            line.delete(array.shift(arr_bFvgMd))
            label.delete(array.shift(arr_bFvgLb))
            array.shift(arr_bFvgT)
            array.shift(arr_bFvgB)
            array.shift(arr_bFvgBr)
            array.shift(arr_bFvgDi)
            array.shift(arr_bFvgSc)
        if b_showBPR
            int j = array.size(arr_sFvgT) - 1
            while j >= 0
                float f_ov = math.min(f_gt, array.get(arr_sFvgT, j))
                float f_ob2 = math.max(f_gb, array.get(arr_sFvgB, j))
                if f_ov > f_ob2
                    array.push(arr_bprBx, box.new(math.min(array.get(arr_sFvgBr, j), bar_index[1]), f_ov, bar_index + i_fvgExt, f_ob2, xloc = xloc.bar_index, bgcolor = color.new(c_bpr, 75), border_color = c_bpr, border_width = 1))
                    array.push(arr_bprLb, f_mkLabel(bar_index + i_fvgExt, (f_ov + f_ob2) / 2, s_lblBPR, c_bpr, c_bpr, "left"))
                    array.push(arr_bprT, f_ov)
                    array.push(arr_bprB, f_ob2)
                    array.push(arr_bprCr, bar_index)
                    array.push(arr_bprDi, f_ov - f_ob2)
                    array.push(arr_bprSc, 0.0)
                    while array.size(arr_bprBx) > i_capBPR
                        box.delete(array.shift(arr_bprBx))
                        label.delete(array.shift(arr_bprLb))
                        array.shift(arr_bprT)
                        array.shift(arr_bprB)
                        array.shift(arr_bprCr)
                        array.shift(arr_bprDi)
                        array.shift(arr_bprSc)
                j -= 1
if b_showFVG and b_bearFvg
    float f_gt = low[3]
    float f_gb = high[1]
    if not b_fvgFilt or f_gt - f_gb >= f_fvgAtr * f_atrV
        float f_mid = (f_gt + f_gb) / 2
        array.push(arr_sFvgT, f_gt)
        array.push(arr_sFvgB, f_gb)
        array.push(arr_sFvgBr, bar_index)
        array.push(arr_sFvgBx, box.new(bar_index[2], f_gt, bar_index + i_fvgExt, f_gb, xloc = xloc.bar_index, bgcolor = color.new(c_bear, 85), border_color = color.new(c_bear, 40), border_width = 1))
        array.push(arr_sFvgMd, line.new(bar_index[2], f_mid, bar_index + i_fvgExt, f_mid, xloc = xloc.bar_index, color = c_bear, style = line.style_dotted, width = 1))
        array.push(arr_sFvgLb, f_mkLabel(bar_index + i_fvgExt, f_mid, s_lblFVG, c_bear, c_bear, "left"))
        array.push(arr_sFvgDi, f_gt - f_gb)
        array.push(arr_sFvgSc, 0.0)
        while array.size(arr_sFvgT) > i_capFVG
            box.delete(array.shift(arr_sFvgBx))
            line.delete(array.shift(arr_sFvgMd))
            label.delete(array.shift(arr_sFvgLb))
            array.shift(arr_sFvgT)
            array.shift(arr_sFvgB)
            array.shift(arr_sFvgBr)
            array.shift(arr_sFvgDi)
            array.shift(arr_sFvgSc)
        if b_showBPR
            int j = array.size(arr_bFvgT) - 1
            while j >= 0
                float f_ov = math.min(f_gt, array.get(arr_bFvgT, j))
                float f_ob2 = math.max(f_gb, array.get(arr_bFvgB, j))
                if f_ov > f_ob2
                    array.push(arr_bprBx, box.new(math.min(array.get(arr_bFvgBr, j), bar_index[1]), f_ov, bar_index + i_fvgExt, f_ob2, xloc = xloc.bar_index, bgcolor = color.new(c_bpr, 75), border_color = c_bpr, border_width = 1))
                    array.push(arr_bprLb, f_mkLabel(bar_index + i_fvgExt, (f_ov + f_ob2) / 2, s_lblBPR, c_bpr, c_bpr, "left"))
                    array.push(arr_bprT, f_ov)
                    array.push(arr_bprB, f_ob2)
                    array.push(arr_bprCr, bar_index)
                    array.push(arr_bprDi, f_ov - f_ob2)
                    array.push(arr_bprSc, 0.0)
                    while array.size(arr_bprBx) > i_capBPR
                        box.delete(array.shift(arr_bprBx))
                        label.delete(array.shift(arr_bprLb))
                        array.shift(arr_bprT)
                        array.shift(arr_bprB)
                        array.shift(arr_bprCr)
                        array.shift(arr_bprDi)
                        array.shift(arr_bprSc)
                j -= 1

// ════════════════════════ 14b.  FVG + BPR MITIGATION ════════════════════════
if b_fvgClear
    int i_fi = array.size(arr_bFvgB) - 1
    while i_fi >= 0
        if bar_index > array.get(arr_bFvgBr, i_fi) and low <= array.get(arr_bFvgB, i_fi)
            box.delete(array.get(arr_bFvgBx, i_fi))
            line.delete(array.get(arr_bFvgMd, i_fi))
            label.delete(array.get(arr_bFvgLb, i_fi))
            array.remove(arr_bFvgT, i_fi)
            array.remove(arr_bFvgB, i_fi)
            array.remove(arr_bFvgBr, i_fi)
            array.remove(arr_bFvgBx, i_fi)
            array.remove(arr_bFvgMd, i_fi)
            array.remove(arr_bFvgLb, i_fi)
            array.remove(arr_bFvgDi, i_fi)
            array.remove(arr_bFvgSc, i_fi)
        i_fi -= 1
    i_fi := array.size(arr_sFvgT) - 1
    while i_fi >= 0
        if bar_index > array.get(arr_sFvgBr, i_fi) and high >= array.get(arr_sFvgT, i_fi)
            box.delete(array.get(arr_sFvgBx, i_fi))
            line.delete(array.get(arr_sFvgMd, i_fi))
            label.delete(array.get(arr_sFvgLb, i_fi))
            array.remove(arr_sFvgT, i_fi)
            array.remove(arr_sFvgB, i_fi)
            array.remove(arr_sFvgBr, i_fi)
            array.remove(arr_sFvgBx, i_fi)
            array.remove(arr_sFvgMd, i_fi)
            array.remove(arr_sFvgLb, i_fi)
            array.remove(arr_sFvgDi, i_fi)
            array.remove(arr_sFvgSc, i_fi)
        i_fi -= 1
    i_fi := array.size(arr_bprBx) - 1
    while i_fi >= 0
        if bar_index > array.get(arr_bprCr, i_fi) and (low <= array.get(arr_bprB, i_fi) or high >= array.get(arr_bprT, i_fi))
            box.delete(array.get(arr_bprBx, i_fi))
            label.delete(array.get(arr_bprLb, i_fi))
            array.remove(arr_bprBx, i_fi)
            array.remove(arr_bprLb, i_fi)
            array.remove(arr_bprT, i_fi)
            array.remove(arr_bprB, i_fi)
            array.remove(arr_bprCr, i_fi)
            array.remove(arr_bprDi, i_fi)
            array.remove(arr_bprSc, i_fi)
        i_fi -= 1

// ════════════════════════ 14c.  FVG MERGE ═══════════════════════════════════
if b_fvgMerge and not na(f_atrV)
    int i_mi = 0
    while i_mi < array.size(arr_bFvgB) - 1
        if bar_index - array.get(arr_bFvgBr, i_mi) > i_mergeAge
            float f_tI = array.get(arr_bFvgT, i_mi)
            float f_bI = array.get(arr_bFvgB, i_mi)
            int i_mj = i_mi + 1
            bool b_merged = false
            while i_mj < array.size(arr_bFvgB) and not b_merged
                if bar_index - array.get(arr_bFvgBr, i_mj) > i_mergeAge
                    float f_tJ = array.get(arr_bFvgT, i_mj)
                    float f_bJ = array.get(arr_bFvgB, i_mj)
                    float overlap = math.min(f_tI, f_tJ) - math.max(f_bI, f_bJ)
                    if overlap >= -(f_mergeTol * f_atrV)
                        float f_nT = math.max(f_tI, f_tJ)
                        float f_nB = math.min(f_bI, f_bJ)
                        float f_nM = (f_nT + f_nB) / 2
                        array.set(arr_bFvgT, i_mi, f_nT)
                        array.set(arr_bFvgB, i_mi, f_nB)
                        array.set(arr_bFvgDi, i_mi, f_nT - f_nB)
                        box.set_top(array.get(arr_bFvgBx, i_mi), f_nT)
                        box.set_bottom(array.get(arr_bFvgBx, i_mi), f_nB)
                        line.set_y1(array.get(arr_bFvgMd, i_mi), f_nM)
                        line.set_y2(array.get(arr_bFvgMd, i_mi), f_nM)
                        label.set_y(array.get(arr_bFvgLb, i_mi), f_nM)
                        box.delete(array.get(arr_bFvgBx, i_mj))
                        line.delete(array.get(arr_bFvgMd, i_mj))
                        label.delete(array.get(arr_bFvgLb, i_mj))
                        array.remove(arr_bFvgT, i_mj)
                        array.remove(arr_bFvgB, i_mj)
                        array.remove(arr_bFvgBr, i_mj)
                        array.remove(arr_bFvgBx, i_mj)
                        array.remove(arr_bFvgMd, i_mj)
                        array.remove(arr_bFvgLb, i_mj)
                        array.remove(arr_bFvgDi, i_mj)
                        array.remove(arr_bFvgSc, i_mj)
                        b_merged := true
                    else
                        i_mj += 1
                else
                    i_mj += 1
            if not b_merged
                i_mi += 1
        else
            i_mi += 1
    i_mi := 0
    while i_mi < array.size(arr_sFvgB) - 1
        if bar_index - array.get(arr_sFvgBr, i_mi) > i_mergeAge
            float f_tI = array.get(arr_sFvgT, i_mi)
            float f_bI = array.get(arr_sFvgB, i_mi)
            int i_mj = i_mi + 1
            bool b_merged = false
            while i_mj < array.size(arr_sFvgB) and not b_merged
                if bar_index - array.get(arr_sFvgBr, i_mj) > i_mergeAge
                    float f_tJ = array.get(arr_sFvgT, i_mj)
                    float f_bJ = array.get(arr_sFvgB, i_mj)
                    float overlap = math.min(f_tI, f_tJ) - math.max(f_bI, f_bJ)
                    if overlap >= -(f_mergeTol * f_atrV)
                        float f_nT = math.max(f_tI, f_tJ)
                        float f_nB = math.min(f_bI, f_bJ)
                        float f_nM = (f_nT + f_nB) / 2
                        array.set(arr_sFvgT, i_mi, f_nT)
                        array.set(arr_sFvgB, i_mi, f_nB)
                        array.set(arr_sFvgDi, i_mi, f_nT - f_nB)
                        box.set_top(array.get(arr_sFvgBx, i_mi), f_nT)
                        box.set_bottom(array.get(arr_sFvgBx, i_mi), f_nB)
                        line.set_y1(array.get(arr_sFvgMd, i_mi), f_nM)
                        line.set_y2(array.get(arr_sFvgMd, i_mi), f_nM)
                        label.set_y(array.get(arr_sFvgLb, i_mi), f_nM)
                        box.delete(array.get(arr_sFvgBx, i_mj))
                        line.delete(array.get(arr_sFvgMd, i_mj))
                        label.delete(array.get(arr_sFvgLb, i_mj))
                        array.remove(arr_sFvgT, i_mj)
                        array.remove(arr_sFvgB, i_mj)
                        array.remove(arr_sFvgBr, i_mj)
                        array.remove(arr_sFvgBx, i_mj)
                        array.remove(arr_sFvgMd, i_mj)
                        array.remove(arr_sFvgLb, i_mj)
                        array.remove(arr_sFvgDi, i_mj)
                        array.remove(arr_sFvgSc, i_mj)
                        b_merged := true
                    else
                        i_mj += 1
                else
                    i_mj += 1
            if not b_merged
                i_mi += 1
        else
            i_mi += 1

// ════════════════════════ 14d.  SCORING ═════════════════════════════════════
// Compute composite relevance score for every active zone, then optionally
// apply opacity scaling and delete zones below threshold.
// (Composite relevance score variables were moved to Declarations)

// f_confluence: count overlaps of (top, bot, s_selfTag, i_selfIdx) against all other zones
// Score all zones + apply opacity + threshold filter
// Bull FVG
int i_si = array.size(arr_bFvgB) - 1
while i_si >= 0
    float f_sc = f_score(array.get(arr_bFvgT, i_si), array.get(arr_bFvgB, i_si), array.get(arr_bFvgDi, i_si), array.get(arr_bFvgBr, i_si), true, false, "bF", i_si)
    array.set(arr_bFvgSc, i_si, f_sc)
    if f_sc < i_scoreThreshold
        box.delete(array.get(arr_bFvgBx, i_si))
        line.delete(array.get(arr_bFvgMd, i_si))
        label.delete(array.get(arr_bFvgLb, i_si))
        array.remove(arr_bFvgT, i_si)
        array.remove(arr_bFvgB, i_si)
        array.remove(arr_bFvgBr, i_si)
        array.remove(arr_bFvgBx, i_si)
        array.remove(arr_bFvgMd, i_si)
        array.remove(arr_bFvgLb, i_si)
        array.remove(arr_bFvgDi, i_si)
        array.remove(arr_bFvgSc, i_si)
    else
        if b_applyOpacity
            f_recolorFVG(array.get(arr_bFvgBx, i_si), array.get(arr_bFvgMd, i_si), array.get(arr_bFvgLb, i_si), c_bull, f_sc)
        label.set_text(array.get(arr_bFvgLb, i_si), f_lblText(s_lblFVG, f_sc))
    i_si -= 1
// Bear FVG
i_si := array.size(arr_sFvgB) - 1
while i_si >= 0
    float f_sc = f_score(array.get(arr_sFvgT, i_si), array.get(arr_sFvgB, i_si), array.get(arr_sFvgDi, i_si), array.get(arr_sFvgBr, i_si), false, false, "sF", i_si)
    array.set(arr_sFvgSc, i_si, f_sc)
    if f_sc < i_scoreThreshold
        box.delete(array.get(arr_sFvgBx, i_si))
        line.delete(array.get(arr_sFvgMd, i_si))
        label.delete(array.get(arr_sFvgLb, i_si))
        array.remove(arr_sFvgT, i_si)
        array.remove(arr_sFvgB, i_si)
        array.remove(arr_sFvgBr, i_si)
        array.remove(arr_sFvgBx, i_si)
        array.remove(arr_sFvgMd, i_si)
        array.remove(arr_sFvgLb, i_si)
        array.remove(arr_sFvgDi, i_si)
        array.remove(arr_sFvgSc, i_si)
    else
        if b_applyOpacity
            f_recolorFVG(array.get(arr_sFvgBx, i_si), array.get(arr_sFvgMd, i_si), array.get(arr_sFvgLb, i_si), c_bear, f_sc)
        label.set_text(array.get(arr_sFvgLb, i_si), f_lblText(s_lblFVG, f_sc))
    i_si -= 1
// Bull OB
i_si := array.size(arr_bullObT) - 1
while i_si >= 0
    float f_sc = f_score(array.get(arr_bullObT, i_si), array.get(arr_bullObB, i_si), array.get(arr_bullObDi, i_si), array.get(arr_bullObBr, i_si), true, false, "bO", i_si)
    array.set(arr_bullObSc, i_si, f_sc)
    if f_sc < i_scoreThreshold
        box.delete(array.get(arr_bullObBx, i_si))
        label.delete(array.get(arr_bullObLb, i_si))
        array.remove(arr_bullObBx, i_si)
        array.remove(arr_bullObLb, i_si)
        array.remove(arr_bullObT, i_si)
        array.remove(arr_bullObB, i_si)
        array.remove(arr_bullObDi, i_si)
        array.remove(arr_bullObBr, i_si)
        array.remove(arr_bullObSc, i_si)
    else
        if b_applyOpacity
            f_recolorBox(array.get(arr_bullObBx, i_si), array.get(arr_bullObLb, i_si), c_bull, f_sc)
        label.set_text(array.get(arr_bullObLb, i_si), f_lblText(s_lblOBu, f_sc))
    i_si -= 1
// Bear OB
i_si := array.size(arr_bearObT) - 1
while i_si >= 0
    float f_sc = f_score(array.get(arr_bearObT, i_si), array.get(arr_bearObB, i_si), array.get(arr_bearObDi, i_si), array.get(arr_bearObBr, i_si), false, false, "eO", i_si)
    array.set(arr_bearObSc, i_si, f_sc)
    if f_sc < i_scoreThreshold
        box.delete(array.get(arr_bearObBx, i_si))
        label.delete(array.get(arr_bearObLb, i_si))
        array.remove(arr_bearObBx, i_si)
        array.remove(arr_bearObLb, i_si)
        array.remove(arr_bearObT, i_si)
        array.remove(arr_bearObB, i_si)
        array.remove(arr_bearObDi, i_si)
        array.remove(arr_bearObBr, i_si)
        array.remove(arr_bearObSc, i_si)
    else
        if b_applyOpacity
            f_recolorBox(array.get(arr_bearObBx, i_si), array.get(arr_bearObLb, i_si), c_bear, f_sc)
        label.set_text(array.get(arr_bearObLb, i_si), f_lblText(s_lblOBe, f_sc))
    i_si -= 1
// BPR (bidirectional)
i_si := array.size(arr_bprT) - 1
while i_si >= 0
    float f_sc = f_score(array.get(arr_bprT, i_si), array.get(arr_bprB, i_si), array.get(arr_bprDi, i_si), array.get(arr_bprCr, i_si), true, true, "bp", i_si)
    array.set(arr_bprSc, i_si, f_sc)
    if f_sc < i_scoreThreshold
        box.delete(array.get(arr_bprBx, i_si))
        label.delete(array.get(arr_bprLb, i_si))
        array.remove(arr_bprBx, i_si)
        array.remove(arr_bprLb, i_si)
        array.remove(arr_bprT, i_si)
        array.remove(arr_bprB, i_si)
        array.remove(arr_bprCr, i_si)
        array.remove(arr_bprDi, i_si)
        array.remove(arr_bprSc, i_si)
    else
        if b_applyOpacity
            f_recolorBox(array.get(arr_bprBx, i_si), array.get(arr_bprLb, i_si), c_bpr, f_sc)
        label.set_text(array.get(arr_bprLb, i_si), f_lblText(s_lblBPR, f_sc))
    i_si -= 1
// BSL (point zones)
i_si := array.size(arr_bslPr) - 1
while i_si >= 0
    float p = array.get(arr_bslPr, i_si)
    float f_sc = f_score(p + f_tol / 2, p - f_tol / 2, array.get(arr_bslDi, i_si), array.get(arr_bslBr, i_si), true, false, "bL", i_si)
    array.set(arr_bslSc, i_si, f_sc)
    if f_sc < i_scoreThreshold
        line.delete(array.get(arr_bslLn, i_si))
        label.delete(array.get(arr_bslLb, i_si))
        array.remove(arr_bslLn, i_si)
        array.remove(arr_bslLb, i_si)
        array.remove(arr_bslPr, i_si)
        array.remove(arr_bslDi, i_si)
        array.remove(arr_bslBr, i_si)
        array.remove(arr_bslSc, i_si)
    else
        if b_applyOpacity
            f_recolorLine(array.get(arr_bslLn, i_si), array.get(arr_bslLb, i_si), c_bsl, f_sc)
        label.set_text(array.get(arr_bslLb, i_si), f_lblText(s_lblBSL, f_sc))
    i_si -= 1
// SSL
i_si := array.size(arr_sslPr) - 1
while i_si >= 0
    float p = array.get(arr_sslPr, i_si)
    float f_sc = f_score(p + f_tol / 2, p - f_tol / 2, array.get(arr_sslDi, i_si), array.get(arr_sslBr, i_si), false, false, "sL", i_si)
    array.set(arr_sslSc, i_si, f_sc)
    if f_sc < i_scoreThreshold
        line.delete(array.get(arr_sslLn, i_si))
        label.delete(array.get(arr_sslLb, i_si))
        array.remove(arr_sslLn, i_si)
        array.remove(arr_sslLb, i_si)
        array.remove(arr_sslPr, i_si)
        array.remove(arr_sslDi, i_si)
        array.remove(arr_sslBr, i_si)
        array.remove(arr_sslSc, i_si)
    else
        if b_applyOpacity
            f_recolorLine(array.get(arr_sslLn, i_si), array.get(arr_sslLb, i_si), c_ssl, f_sc)
        label.set_text(array.get(arr_sslLb, i_si), f_lblText(s_lblSSL, f_sc))
    i_si -= 1
// EQ (point zones)
i_si := array.size(arr_eqPr) - 1
while i_si >= 0
    float p = array.get(arr_eqPr, i_si)
    bool isB = array.get(arr_eqIsBull, i_si)
    float f_sc = f_score(p + f_tol / 2, p - f_tol / 2, f_eqAtr * f_atrV, array.get(arr_eqBr, i_si), isB, false, "eq", i_si)
    array.set(arr_eqSc, i_si, f_sc)
    if f_sc < i_scoreThreshold
        line.delete(array.get(arr_eqLn, i_si))
        label.delete(array.get(arr_eqLb, i_si))
        array.remove(arr_eqLn, i_si)
        array.remove(arr_eqLb, i_si)
        array.remove(arr_eqPr, i_si)
        array.remove(arr_eqBr, i_si)
        array.remove(arr_eqIsBull, i_si)
        array.remove(arr_eqSc, i_si)
    else
        if b_applyOpacity
            f_recolorLine(array.get(arr_eqLn, i_si), array.get(arr_eqLb, i_si), c_eq, f_sc)
        label.set_text(array.get(arr_eqLb, i_si), f_lblText(isB ? s_lblEQH : s_lblEQL, f_sc))
    i_si -= 1

// ════════════════════════ 15.  VOLUME IMBALANCE ═════════════════════════════
if b_showVI
    float f_pBT = math.max(open[1], close[1])
    float f_pBB = math.min(open[1], close[1])
    float f_cBT2 = math.max(open[0], close[0])
    float f_cBB2 = math.min(open[0], close[0])
    if f_cBB2 > f_pBT
        array.push(arr_viBx, box.new(bar_index[1], f_cBB2, bar_index + 5, f_pBT, xloc = xloc.bar_index, bgcolor = c_viBg, border_color = c_viBorder, border_width = 1))
        array.push(arr_viLb, f_mkLabel(bar_index + 5, (f_cBB2 + f_pBT) / 2, s_lblVIu, c_viBorder, c_bull, "left"))
        f_capBL(arr_viBx, arr_viLb, i_capVI)
    if f_cBT2 < f_pBB
        array.push(arr_viBx, box.new(bar_index[1], f_pBB, bar_index + 5, f_cBT2, xloc = xloc.bar_index, bgcolor = c_viBg, border_color = c_viBorder, border_width = 1))
        array.push(arr_viLb, f_mkLabel(bar_index + 5, (f_pBB + f_cBT2) / 2, s_lblVIe, c_viBorder, c_bear, "left"))
        f_capBL(arr_viBx, arr_viLb, i_capVI)

// ════════════════════════ 16.  PREMIUM / DISCOUNT / OTE ═════════════════════
if b_showPD and not na(f_swH) and not na(f_swL) and barstate.islast
    float f_rH = f_swH
    float f_rL = f_swL
    float f_rE = (f_rH + f_rL) / 2
    int i_x1 = math.min(i_swHx, i_swLx)
    int i_x2 = bar_index + i_extendBars
    if na(ln_premium)
        ln_premium := line.new(i_x1, f_rH, i_x2, f_rH, xloc = xloc.bar_index, color = c_bear, style = line.style_solid, width = 1)
        ln_discount := line.new(i_x1, f_rL, i_x2, f_rL, xloc = xloc.bar_index, color = c_bull, style = line.style_solid, width = 1)
        ln_equilibrium := line.new(i_x1, f_rE, i_x2, f_rE, xloc = xloc.bar_index, color = c_equilibrium, style = line.style_dashed, width = 1)
        lb_premium := f_mkLabel(i_x2, f_rH, s_lblPRM, c_bear, c_bear, "left")
        lb_discount := f_mkLabel(i_x2, f_rL, s_lblDSC, c_bull, c_bull, "left")
        lb_equilibrium := f_mkLabel(i_x2, f_rE, s_lblEQU, c_equilibrium, c_equilibrium, "left")
    else
        line.set_x1(ln_premium, i_x1)
        line.set_y1(ln_premium, f_rH)
        line.set_x2(ln_premium, i_x2)
        line.set_y2(ln_premium, f_rH)
        line.set_x1(ln_discount, i_x1)
        line.set_y1(ln_discount, f_rL)
        line.set_x2(ln_discount, i_x2)
        line.set_y2(ln_discount, f_rL)
        line.set_x1(ln_equilibrium, i_x1)
        line.set_y1(ln_equilibrium, f_rE)
        line.set_x2(ln_equilibrium, i_x2)
        line.set_y2(ln_equilibrium, f_rE)
        label.set_x(lb_premium, i_x2)
        label.set_y(lb_premium, f_rH)
        label.set_x(lb_discount, i_x2)
        label.set_y(lb_discount, f_rL)
        label.set_x(lb_equilibrium, i_x2)
        label.set_y(lb_equilibrium, f_rE)
    if b_showOTE
        bool b_up = i_swHx > i_swLx
        float f_leg = f_rH - f_rL
        float f_oT = b_up ? f_rH - 0.62 * f_leg : f_rL + 0.79 * f_leg
        float f_oB = b_up ? f_rH - 0.79 * f_leg : f_rL + 0.62 * f_leg
        if na(ln_oteTop)
            ln_oteTop := line.new(i_x1, f_oT, i_x2, f_oT, xloc = xloc.bar_index, color = c_oteAlpha, style = line.style_dotted, width = 1)
            ln_oteBot := line.new(i_x1, f_oB, i_x2, f_oB, xloc = xloc.bar_index, color = c_oteAlpha, style = line.style_dotted, width = 1)
            lb_ote := f_mkLabel(i_x2, (f_oT + f_oB) / 2, s_lblOTE, c_oteAlpha, c_oteAlpha, "left")
        else
            line.set_x1(ln_oteTop, i_x1)
            line.set_y1(ln_oteTop, f_oT)
            line.set_x2(ln_oteTop, i_x2)
            line.set_y2(ln_oteTop, f_oT)
            line.set_x1(ln_oteBot, i_x1)
            line.set_y1(ln_oteBot, f_oB)
            line.set_x2(ln_oteBot, i_x2)
            line.set_y2(ln_oteBot, f_oB)
            label.set_x(lb_ote, i_x2)
            label.set_y(lb_ote, (f_oT + f_oB) / 2)

// ════════════════════════ 16b.  DYNAMIC EXTENSION ═══════════════════════════
int i_rx2 = bar_index + i_extendBars
int i_rxf = bar_index + i_fvgExt
int k = 0
while k < array.size(arr_bslLn)
    line.set_x2(array.get(arr_bslLn, k), i_rx2)
    label.set_x(array.get(arr_bslLb, k), i_rx2)
    k += 1
k := 0
while k < array.size(arr_sslLn)
    line.set_x2(array.get(arr_sslLn, k), i_rx2)
    label.set_x(array.get(arr_sslLb, k), i_rx2)
    k += 1
k := 0
while k < array.size(arr_bullObBx)
    box.set_right(array.get(arr_bullObBx, k), i_rx2)
    label.set_x(array.get(arr_bullObLb, k), i_rx2)
    k += 1
k := 0
while k < array.size(arr_bearObBx)
    box.set_right(array.get(arr_bearObBx, k), i_rx2)
    label.set_x(array.get(arr_bearObLb, k), i_rx2)
    k += 1
k := 0
while k < array.size(arr_intLqLn)
    line.set_x2(array.get(arr_intLqLn, k), i_rx2)
    label.set_x(array.get(arr_intLqLb, k), i_rx2)
    k += 1
k := 0
while k < array.size(arr_bFvgBx)
    box.set_right(array.get(arr_bFvgBx, k), i_rxf)
    line.set_x2(array.get(arr_bFvgMd, k), i_rxf)
    label.set_x(array.get(arr_bFvgLb, k), i_rxf)
    k += 1
k := 0
while k < array.size(arr_sFvgBx)
    box.set_right(array.get(arr_sFvgBx, k), i_rxf)
    line.set_x2(array.get(arr_sFvgMd, k), i_rxf)
    label.set_x(array.get(arr_sFvgLb, k), i_rxf)
    k += 1
k := 0
while k < array.size(arr_bprBx)
    box.set_right(array.get(arr_bprBx, k), i_rxf)
    label.set_x(array.get(arr_bprLb, k), i_rxf)
    k += 1


// ─── Dashboard collection and table rendering ───────────────────────────
if b_showDash and barstate.islast
    int N     = i_dashRows
    int i_halfN = N / 2

    // Long-side and short-side top-half arrays
    array<float>  arr_topScoreLong = array.new<float>(i_halfN, 0.0)
    array<string> arr_topTypeLong = array.new<string>(i_halfN, "")
    array<float>  arr_topPriceLong = array.new<float>(i_halfN, na)
    array<string> arr_topDirLong = array.new<string>(i_halfN, "")
    array<int>    arr_topAgeLong = array.new<int>(i_halfN, 0)
    array<float>  arr_topScoreShort = array.new<float>(i_halfN, 0.0)
    array<string> arr_topTypeShort = array.new<string>(i_halfN, "")
    array<float>  arr_topPriceShort = array.new<float>(i_halfN, na)
    array<string> arr_topDirShort = array.new<string>(i_halfN, "")
    array<int>    arr_topAgeShort = array.new<int>(i_halfN, 0)

    int i_totalTypes = 8
    int i_srcN      = 0
    float f_srcSc   = 0.0
    string s_srcTp  = ""
    float f_srcPr   = 0.0
    string s_srcDr  = ""
    int i_srcAg     = 0
    bool b_srcLong  = true

    // Walk through every source array, classify each zone, insert into the right side
    int i_typeIdx = 0
    while i_typeIdx < i_totalTypes
        i_srcN := i_typeIdx == 0 ? array.size(arr_bFvgSc) : i_typeIdx == 1 ? array.size(arr_sFvgSc) : i_typeIdx == 2 ? array.size(arr_bullObSc) : i_typeIdx == 3 ? array.size(arr_bearObSc) : i_typeIdx == 4 ? array.size(arr_bprSc) : i_typeIdx == 5 ? array.size(arr_bslSc) : i_typeIdx == 6 ? array.size(arr_sslSc) : array.size(arr_eqSc)
        int i_ii = 0
        while i_ii < i_srcN
            if i_typeIdx == 0
                f_srcSc   := array.get(arr_bFvgSc, i_ii)
                s_srcTp   := "FVG bull"
                f_srcPr   := (array.get(arr_bFvgT, i_ii) + array.get(arr_bFvgB, i_ii)) / 2
                s_srcDr   := "▲"
                i_srcAg   := bar_index - array.get(arr_bFvgBr, i_ii)
                b_srcLong := true
            else if i_typeIdx == 1
                f_srcSc   := array.get(arr_sFvgSc, i_ii)
                s_srcTp   := "FVG bear"
                f_srcPr   := (array.get(arr_sFvgT, i_ii) + array.get(arr_sFvgB, i_ii)) / 2
                s_srcDr   := "▼"
                i_srcAg   := bar_index - array.get(arr_sFvgBr, i_ii)
                b_srcLong := false
            else if i_typeIdx == 2
                f_srcSc   := array.get(arr_bullObSc, i_ii)
                s_srcTp   := "Bull OB"
                f_srcPr   := (array.get(arr_bullObT, i_ii) + array.get(arr_bullObB, i_ii)) / 2
                s_srcDr   := "▲"
                i_srcAg   := bar_index - array.get(arr_bullObBr, i_ii)
                b_srcLong := true
            else if i_typeIdx == 3
                f_srcSc   := array.get(arr_bearObSc, i_ii)
                s_srcTp   := "Bear OB"
                f_srcPr   := (array.get(arr_bearObT, i_ii) + array.get(arr_bearObB, i_ii)) / 2
                s_srcDr   := "▼"
                i_srcAg   := bar_index - array.get(arr_bearObBr, i_ii)
                b_srcLong := false
            else if i_typeIdx == 4
                // BPR is bidirectional — classify by side relative to current price
                f_srcSc   := array.get(arr_bprSc, i_ii)
                s_srcTp   := "BPR"
                f_srcPr   := (array.get(arr_bprT, i_ii) + array.get(arr_bprB, i_ii)) / 2
                s_srcDr   := "◆"
                i_srcAg   := bar_index - array.get(arr_bprCr, i_ii)
                b_srcLong := f_srcPr <= close
            else if i_typeIdx == 5
                // BSL = stops above a swing high → short opportunity on sweep-and-reverse
                f_srcSc   := array.get(arr_bslSc, i_ii)
                s_srcTp   := "BSL"
                f_srcPr   := array.get(arr_bslPr, i_ii)
                s_srcDr   := "▼"
                i_srcAg   := bar_index - array.get(arr_bslBr, i_ii)
                b_srcLong := false
            else if i_typeIdx == 6
                // SSL = stops below a swing low → long opportunity on sweep-and-reverse
                f_srcSc   := array.get(arr_sslSc, i_ii)
                s_srcTp   := "SSL"
                f_srcPr   := array.get(arr_sslPr, i_ii)
                s_srcDr   := "▲"
                i_srcAg   := bar_index - array.get(arr_sslBr, i_ii)
                b_srcLong := true
            else
                // EQH = bull pivots clustered → short target; EQL = bear pivots → long target
                bool b_eqB = array.get(arr_eqIsBull, i_ii)
                f_srcSc   := array.get(arr_eqSc, i_ii)
                s_srcTp   := b_eqB ? "EQH" : "EQL"
                f_srcPr   := array.get(arr_eqPr, i_ii)
                s_srcDr   := b_eqB ? "▼" : "▲"
                i_srcAg   := bar_index - array.get(arr_eqBr, i_ii)
                b_srcLong := not b_eqB

            if b_srcLong
                f_insertTopN(arr_topScoreLong, arr_topTypeLong, arr_topPriceLong, arr_topDirLong, arr_topAgeLong, i_halfN, f_srcSc, s_srcTp, f_srcPr, s_srcDr, i_srcAg)
            else
                f_insertTopN(arr_topScoreShort, arr_topTypeShort, arr_topPriceShort, arr_topDirShort, arr_topAgeShort, i_halfN, f_srcSc, s_srcTp, f_srcPr, s_srcDr, i_srcAg)
            i_ii += 1
        i_typeIdx += 1

    // Build / update table
    string s_dPos = e_dashPos == DashPos.TOP_LEFT      ? position.top_left      : e_dashPos == DashPos.TOP_CENTER    ? position.top_center    : e_dashPos == DashPos.TOP_RIGHT     ? position.top_right    : e_dashPos == DashPos.MIDDLE_LEFT   ? position.middle_left   : e_dashPos == DashPos.MIDDLE_CENTER ? position.middle_center : e_dashPos == DashPos.MIDDLE_RIGHT  ? position.middle_right : e_dashPos == DashPos.BOTTOM_LEFT   ? position.bottom_left   : e_dashPos == DashPos.BOTTOM_CENTER ? position.bottom_center : position.bottom_right
    // Row layout: title(0) + headers(1) + LONG-sep(2) + i_halfN longs + SHORT-sep + i_halfN shorts
    int i_totalRows = 4 + N
    int i_rLongSep  = 2
    int i_rLongStart = 3
    int i_rShortSep = 3 + i_halfN
    int i_rShortStart = 4 + i_halfN
    if na(tb_dashboard)
        tb_dashboard := table.new(s_dPos, 6, i_totalRows, bgcolor = c_dashBg, border_color = c_dashBorder, border_width = 1, frame_color = c_dashBorder, frame_width = 1)
    // Title (row 0)
    table.cell(tb_dashboard, 0, 0, "SMC ZONES — Top " + str.tostring(N), text_color = c_dashTitleTx, text_size = sz_dash, bgcolor = c_dashTitleBg)
    table.merge_cells(tb_dashboard, 0, 0, 5, 0)
    // Headers (row 1)
    table.cell(tb_dashboard, 0, 1, "#",     text_color = c_dashHeaderTx, text_size = sz_dash, bgcolor = c_dashHeaderBg)
    table.cell(tb_dashboard, 1, 1, "Type",  text_color = c_dashHeaderTx, text_size = sz_dash, bgcolor = c_dashHeaderBg)
    table.cell(tb_dashboard, 2, 1, "Price", text_color = c_dashHeaderTx, text_size = sz_dash, bgcolor = c_dashHeaderBg)
    table.cell(tb_dashboard, 3, 1, "Dir",   text_color = c_dashHeaderTx, text_size = sz_dash, bgcolor = c_dashHeaderBg)
    table.cell(tb_dashboard, 4, 1, "Age",   text_color = c_dashHeaderTx, text_size = sz_dash, bgcolor = c_dashHeaderBg)
    table.cell(tb_dashboard, 5, 1, "Score", text_color = c_dashHeaderTx, text_size = sz_dash, bgcolor = c_dashHeaderBg)
    // LONG separator
    table.cell(tb_dashboard, 0, i_rLongSep, "▲  LONG", text_color = c_bull, text_size = sz_dash, bgcolor = c_dashTitleBg)
    table.merge_cells(tb_dashboard, 0, i_rLongSep, 5, i_rLongSep)
    // Long rows
    for i_ri = 0 to i_halfN - 1
        float f_scR    = array.get(arr_topScoreLong, i_ri)
        bool  b_empty  = f_scR <= 0
        color c_tColor = b_empty ? c_dashEmptyTx : f_tierColor(f_scR)
        string s_scTxt = b_empty ? "—" : f_stars(f_scR) + "  " + str.tostring(math.round(f_scR))
        int i_rowY = i_rLongStart + i_ri
        table.cell(tb_dashboard, 0, i_rowY, b_empty ? "" : str.tostring(i_ri + 1),                                       text_color = c_dashHeaderTx, text_size = sz_dash)
        table.cell(tb_dashboard, 1, i_rowY, b_empty ? "" : array.get(arr_topTypeLong, i_ri),                                      text_color = c_dashBodyTx,   text_size = sz_dash)
        table.cell(tb_dashboard, 2, i_rowY, b_empty ? "" : str.tostring(array.get(arr_topPriceLong, i_ri), format.mintick),        text_color = c_dashBodyTx,   text_size = sz_dash)
        table.cell(tb_dashboard, 3, i_rowY, b_empty ? "" : array.get(arr_topDirLong, i_ri),                                      text_color = c_bull,        text_size = sz_dash)
        table.cell(tb_dashboard, 4, i_rowY, b_empty ? "" : str.tostring(array.get(arr_topAgeLong, i_ri)),                        text_color = c_dashBodyTx,   text_size = sz_dash)
        table.cell(tb_dashboard, 5, i_rowY, s_scTxt,                                                                   text_color = c_tColor,       text_size = sz_dash)
    // SHORT separator
    table.cell(tb_dashboard, 0, i_rShortSep, "▼  SHORT", text_color = c_bear, text_size = sz_dash, bgcolor = c_dashTitleBg)
    table.merge_cells(tb_dashboard, 0, i_rShortSep, 5, i_rShortSep)
    // Short rows
    for i_ri = 0 to i_halfN - 1
        float f_scR    = array.get(arr_topScoreShort, i_ri)
        bool  b_empty  = f_scR <= 0
        color c_tColor = b_empty ? c_dashEmptyTx : f_tierColor(f_scR)
        string s_scTxt = b_empty ? "—" : f_stars(f_scR) + "  " + str.tostring(math.round(f_scR))
        int i_rowY = i_rShortStart + i_ri
        table.cell(tb_dashboard, 0, i_rowY, b_empty ? "" : str.tostring(i_ri + 1),                                       text_color = c_dashHeaderTx, text_size = sz_dash)
        table.cell(tb_dashboard, 1, i_rowY, b_empty ? "" : array.get(arr_topTypeShort, i_ri),                                      text_color = c_dashBodyTx,   text_size = sz_dash)
        table.cell(tb_dashboard, 2, i_rowY, b_empty ? "" : str.tostring(array.get(arr_topPriceShort, i_ri), format.mintick),        text_color = c_dashBodyTx,   text_size = sz_dash)
        table.cell(tb_dashboard, 3, i_rowY, b_empty ? "" : array.get(arr_topDirShort, i_ri),                                      text_color = c_bear,        text_size = sz_dash)
        table.cell(tb_dashboard, 4, i_rowY, b_empty ? "" : str.tostring(array.get(arr_topAgeShort, i_ri)),                        text_color = c_dashBodyTx,   text_size = sz_dash)
        table.cell(tb_dashboard, 5, i_rowY, s_scTxt,                                                                   text_color = c_tColor,       text_size = sz_dash)
// }

//Blockmarker ALERTS {
alertcondition(b_bullBk, "Bull break", "Close > swing high.")
alertcondition(b_bearBk, "Bear break", "Close < swing low.")
alertcondition(b_bullFvg, "Bull FVG", "Bull FVG formed.")
alertcondition(b_bearFvg, "Bear FVG", "Bear FVG formed.")
alertcondition(b_hiSweepNow, "BSL sweep", "BSL swept.")
alertcondition(b_loSweepNow, "SSL sweep", "SSL swept.")

// }

//Blockmarker PLOTTING {
// Session killzones (background shading)
bgcolor(b_showKZAsia   and not na(time(timeframe.period, "2000-0000:23456", s_kzTz)) ? color.new(#607d8b, 93) : na, title = "Asia")
bgcolor(b_showKZLondon and not na(time(timeframe.period, "0200-0500:23456", s_kzTz)) ? color.new(#42a5f5, 93) : na, title = "London")
bgcolor(b_showKZNYAM   and not na(time(timeframe.period, "0700-1000:23456", s_kzTz)) ? color.new(#26a69a, 93) : na, title = "NY-AM")
bgcolor(b_showKZNYPM   and not na(time(timeframe.period, "1330-1600:23456", s_kzTz)) ? color.new(#ffa726, 93) : na, title = "NY-PM")


// Previous-period high/low plots
plot(b_showPDH ? f_pdh : na, "PDH", c_pdh, style = plot.style_linebr)
plot(b_showPDH ? f_pdl : na, "PDL", c_pdh, style = plot.style_linebr)
plot(b_showPWH ? f_pwh : na, "PWH", c_pwh, style = plot.style_linebr, linewidth = 2)
plot(b_showPWH ? f_pwl : na, "PWL", c_pwh, style = plot.style_linebr, linewidth = 2)
plot(b_showPMH ? f_pmh : na, "PMH", c_pmh, style = plot.style_linebr, linewidth = 2)
plot(b_showPMH ? f_pml : na, "PML", c_pmh, style = plot.style_linebr, linewidth = 2)
// }
````
