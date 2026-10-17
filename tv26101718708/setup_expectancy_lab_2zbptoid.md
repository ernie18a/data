# Setup Expectancy Lab

- url: https://www.tradingview.com/script/2ZBPtoID-Setup-Expectancy-Lab/
- type: indicator
- pine_id: PUB;e0827e8808604e0f924d25e3561da100
- version: 1.0

## Description

Setup Expectancy Lab

█ OVERVIEW

The Setup Expectancy Lab is a measurement instrument, not a signal generator. You point it at a signal you already have — an event stream published by another indicator, or any plotted price line such as an EMA or VWAP — and it simulates the identical bracket trade on every occurrence across the loaded chart history. It then reports what that setup has actually been worth under one fixed mechanical rule: sample size, win rate with honest confidence intervals, expected R per trade, average time to resolution, and excursion diagnostics — optionally split by market regime.

It was originally built as the measurement companion to the HTF Regime Navigator [HRN] indicator, but it deliberately depends on nothing: the Price Line modes derive events from any visible plot on your chart, so the Lab is fully useful on its own from the first minute. The question it answers is the one most traders never quantify: is this setup worth taking — and under which conditions?

This is an indicator, not a strategy script. It places no orders and does not use the Strategy Tester; it is a statistics table driven by an internal trade simulator.

█ WHY IT'S ORIGINAL AND USEFUL

Pine has strategy() for backtesting complete systems. What it lacks is a lightweight, reusable instrument for measuring the quality of a RAW SIGNAL — any signal, from any indicator — under one fixed, comparable rule, without writing a new strategy script for every idea. That is the gap this tool fills, and several of its mechanisms are, to my knowledge, novel in combination:

• Universal signal intake. Three interpretation modes for the wired source: a ±1 event-stream protocol (any indicator that publishes hidden data plots), Price Line: Cross (long = close crosses above the wired line, short = below), and Price Line: Test (price holding above dips to touch the line and closes back above; mirrored for shorts). The line modes mean any plotted level — an EMA, a VWAP, a band — becomes a measurable entry with zero companion requirements.

• A data-integrity halt system. Pine source inputs default to `close`, and a lab wired to `close` would record every candle as an entry — confident-looking, meaningless statistics. This tool refuses: recording HALTS loudly until the source is wired, and type-aware validity checks catch both mistakes in both directions (a dollar-valued line wired as an event stream, and a ±1 stream wired as a line). Recording garbage that looks like data is worse than recording nothing.

• Statistical honesty machinery. Win rates carry a Wilson 95% confidence interval, chosen over the normal approximation because it stays honest at small N and extreme rates. A ★ is awarded only when the EXACT Wilson lower bound clears the bracket's breakeven win rate (stop ÷ (stop + target), shown live in the header) — meaning the edge is statistically distinguishable from chance at 95%. Rows below a minimum sample render dimmed, and tooltips carry gap-robust medians alongside means.

• A built-in control group. When the optional gate is on, every gate-REJECTED signal is fully simulated anyway with the identical bracket into a ✂ Reject row. One instance therefore runs a gated-vs-ungated A/B automatically: if the rejected signals underperform the accepted ones, the filter is earning its keep; if they carry edge, the filter is discarding value.

• A live pre-flight footer. A Next row shows exactly what would happen if a long or short confirmed at this bar's close — records, gate-rejected, in cooldown, direction-filtered, or halted — with an evaluation order that mirrors the recording logic precisely.

█ THE BRACKET ENGINE, MECHANICALLY

Entry is taken at the close of the confirmed signal bar. Target and stop are ATR multiples (defaults: 2×ATR(14) target, 1×ATR(14) stop), with a horizon expiry (default 20 bars; expiry marks to close and counts as a win only if R > 0). The simulator is deliberately conservative:

• Gap-aware: a bar OPENING beyond the stop or target fills at the open, not at the ideal price.
• Stop-first: when a single bar's range could have hit both levels, the loss is booked — OHLC cannot order intrabar events, so ambiguity always resolves against the setup.
• Confirmed bars only; a trade recorded this bar is not evaluated until the next. No lookahead anywhere.

The breakeven win rate for the current bracket — stop ÷ (stop + target), 33% at the defaults — is displayed in the Win% header, so every number in the table is read against the bar it must clear.

█ REGIME CONDITIONING (OPTIONAL)

Wire the Regime Source to a companion indicator's regime-code stream (protocol: 2 = Trend Up, 1 = Accumulation, 0 = Neutral, −1 = Distribution, −2 = Trend Down, read at the entry bar) and results split into five regime rows plus All — the same signal often carries edge in one environment and none in another, and this is how you find out. With no regime source on the chart, switch Condition by Regime off and the Lab reports a single All row. If the regime source is miswired, entries bucket to Neutral, the header warns, and the All row stays valid.

█ IMPORTANT: WHAT YOU SEE ON FIRST ADD (⛔)

When you first add the Lab, the table header reads "⛔ WIRE SIGNAL SOURCE" and nothing records. This is intentional, not a defect. Pine cannot default a source input to an external plot — it defaults to `close` — and an unwired lab would otherwise record every bar as an entry. Open Settings → Sources, point Signal Source at a real stream or a plotted line, choose the matching Signal Type, and the entire chart history replays instantly: you start with a populated table, not an empty one. The header tooltip explains every halt state and how to clear it.

█ WIRING RECIPES

• Any moving average, no companions needed: Signal Type = Price Line: Cross, Signal Source = the MA's plot. The table now answers "what has buying this line's reclaim been worth?" Use the Direction Filter (Long Only) if you only care about one side, and note that in Both mode each row mixes reclaim-longs with breakdown-shorts of the same line.
• The pullback test: Signal Type = Price Line: Test on a fast EMA, Dedupe Cooldown 3–5 (a trend riding the line can legitimately test it on consecutive bars). Cross bars are deliberately excluded from Test, so the two modes partition events instead of double-counting.
• An event-emitting companion: Signal Type = Event Stream (±1), Signal Source = the companion's hidden event plot (values ≥ +0.5 = long event, ≤ −0.5 = short). Impulse mode records one entry per transition; State mode records every qualifying bar.
• Your own script, in one line: add `plot(myCondition ? 1 : 0, display = display.none)` to anything you've written and it becomes a measurable signal here.
• Gate + A/B: enable the gate, wire a confluence/zone/divergence stream (or a price line — "only while above the 200 EMA" is a two-click gate), set the memory window, and compare the real rows against the ✂ Reject row.

Because Pine scripts cannot read the NAME of a wired source — only its values cross into the script — you label what you wired via the Signal and Gate nickname inputs; the table and footer stay legible no matter what is connected.

█ QUICK START: COMPANION SETTINGS FOR THE HTF REGIME NAVIGATOR

The Lab was designed alongside the HTF Regime Navigator (HRN), whose hidden bus streams map one-to-one onto the Lab's inputs. If you run both, this is the recommended starting configuration — it measures HRN's mechanical entry signal, split by HRN's own regime read:

• Signal Type = Price Line: Test (the Impulse/State dropdown is ignored in line modes — one less thing to set)
• Signal Mode = Impulse (transitions only) — HRN's streams emit one ±1 event per confirmation, so the default is already correct.
• Regime Source = HTF Regime Navigator: EXT: Regime Code · Condition by Regime = ON. The footer's Regime row should immediately show the same regime HRN's dashboard displays — a five-second wiring check.
• Direction Filter = Both · Dedupe Cooldown = 0 — HRN's own confirmation closes and signal cooldown already space its entries; a Lab cooldown on top would drop legitimate signals.
• Confluence Gate = OFF for the first pass. Establish the unconditioned baseline before testing any filter.
• Bracket Engine = defaults (target 2×ATR(14), stop 1×ATR(14), 20-bar horizon; breakeven 33%, shown live in the header). Keep the bracket identical across every configuration you intend to compare.
• Table Position = Middle Right — the default, chosen specifically so it does not collide with HRN's top-right dashboard or bottom-left breakdown table.

Once the baseline has a sample, the natural second pass is the gate A/B: Enable Gate · Gate Type = Event/State Stream (±1) · Gate Source = HTF Regime Navigator: EXT: Confluence State (or EXT: Golden Zone State) · Gate Nickname = "Confluence" · Gate Memory = 0–3 · Direction Logic = Match Signal Direction · Reject Row = ON. The real rows now answer "the signal inside the confluence zone," and the ✂ Reject row answers "the same signal outside it" — the filter's value, in one table. HRN's EXT: Spring / Upthrust stream deserves the same treatment as a Signal Source in a second instance: what a qualified spring has been worth, per regime, under the identical bracket.

█ QUICK START WITH THE HTF REGIME NAVIGATOR (HRN)

The Lab was built alongside the HTF Regime Navigator, and the recommended starting configuration measures the setup that system is built around: price holding above the fast EMA, dipping to test it, and closing back above — the reclaim-and-test entry. HRN's fast EMA is a visible plot, so this recipe also demonstrates the Price Line mode: no event stream required, just the line itself.

Baseline — the signature entry, measured raw:
• Signal Type = Price Line: Test (the Impulse/State dropdown is ignored in line modes — one less thing to set)
• Signal Source = HTF Regime Navigator: MA 1 (the fast EMA — chart-timeframe 50 at HRN's defaults) · Nickname "EMA1 Test"
• Regime Source = HTF Regime Navigator: EXT: Regime Code · Condition by Regime = ON
• Direction Filter = Long Only for the classic buy-the-test question — in Both, each regime row mixes tests of the EMA as support with tests of it as resistance
• Dedupe Cooldown = 3 — Test mode fires on each qualifying bar, and price riding an EMA in a trend can legitimately test it on consecutive bars; 3–5 thins them to distinct episodes
• Gate = OFF · Bracket Engine = defaults (2×ATR target, 1×ATR stop, 20-bar horizon → 33% breakeven)

Result: what buying the test of HRN's fast EMA has been worth on this chart, split by the regime it fired in. Wiring note: because MA 1 is a dollar-valued line, it must be wired under a Price Line type — under Event Stream it correctly trips the ⛔ magnitude halt, whose message points to this exact fix.

The upgrade — "inside the fibs" (location on trial):
• Enable the Gate · Gate Type = Event/State Stream (±1)
• Gate Source = HTF Regime Navigator: EXT: Golden Zone State (or EXT: Confluence State) · Nickname "Golden Zone"
• Gate Memory = 0–3 (state streams stay active while the condition holds, so a small window is correct — the default 8 is tuned for impulse-style divergence gates) · Direction Logic = Match Signal Direction

Result: the real rows become "the EMA test inside the Fibonacci value zone" and the ✂ Reject row becomes the identical test outside it — one table answering whether location is paying rent on this symbol.

Worth a second instance: Signal Type = Price Line: Cross on the same MA 1 measures the reclaim itself rather than the later test (the two modes partition events — a cross bar never double-counts as a test), and Signal Source = EXT: Entry Signal Confirmed (Event Stream, Impulse, Dedupe Cooldown 0 — HRN's engine applies its own confirmation and cooldown) measures the full mechanical signal engine. Keep brackets identical across instances so the expectancies are comparable. The Lab's table defaults to Middle Right specifically so it doesn't collide with HRN's Top Right and Bottom Left tables.

█ READING THE TABLE

• N — resolved simulated trades in the bucket. Rows below the minimum sample dim automatically.
• Win% — win rate ± the Wilson 95% half-width (the displayed ± approximates an asymmetric interval; the exact bounds are in each cell's tooltip). ★ = the exact lower bound clears the bracket's breakeven rate.
• Exp R — average R per resolved trade, the expectancy.
• Bars — average bars from entry to resolution.
• L·MFE — average maximum favorable excursion of LOSING trades, in R: how far losers ran in your favor before dying. Approaching the target multiple suggests the target is too far.
• W·MAE — average maximum adverse excursion of WINNING trades, in R: heat winners took. Well under 1.0 suggests the stop is wider than the setup needs. Excursions exclude each trade's resolution bar (OHLC cannot order intrabar events), so both are slightly understated — conservative by design.
• Last K — a rolling window over the most recent resolved trades with its own interval and a median-R tooltip; compare against All to spot edge decay or improvement.
• ✂ Reject — the gate's control group, aggregate only.
• Conditions footer — the live signal read (nickname, type, ▲/▼ when firing this bar), the live regime bucket, gate ages versus the memory window, and the Next pre-flight row (✔ records · ✂ gated · ⏸n cooldown · ✗off filtered · ⛔ halted).

Entry markers print on the chart for every recorded trade (five styles, fully customizable), and gated-out signals can be marked in gray so you can see exactly what a filter removed.

█ HONEST LIMITATIONS

• The statistics measure raw signal behavior under one fixed mechanical rule on the loaded chart's history. They are not a backtest of a complete trading plan, they include no commissions, slippage, or position sizing, and they are not predictive of future results.
• One symbol per instance — Pine cannot aggregate across a portfolio.
• The confidence interval assumes independent trades; overlapping open positions weaken it somewhat (stated in the header tooltip rather than hidden).
• Small samples are noise. The dimming and the intervals exist precisely so that small samples LOOK like noise.

█ SETTINGS NOTES

Every input carries a tooltip. The highest-leverage settings: Signal Type and Source (the wiring), the Bracket Engine multiples and horizon (changing the bracket changes the breakeven rate — the header recomputes it live), the Dedupe Cooldown for dense line tests, the Gate group with its memory window and direction logic, and Min N for the dimming threshold. For side-by-side comparisons, run multiple instances with tables at different positions — and keep the brackets identical, because expectancy is only comparable when the trade definition is fixed.

█ DISCLAIMER

This script and its description are for educational and informational purposes only and do not constitute financial advice. Win rates and expectancies shown are measurement outputs of historical, single-symbol simulations under one fixed mechanical rule — instruments for evaluating a process, never a promise about future trades. Always do your own research and manage your own risk.

## Source Code

````pine
//@version=6
indicator("Setup Expectancy Lab", "Exp Lab", overlay=true)

// ============================== HELPERS ==============================
getTablePos(string s) =>
    s == "Top Left" ? position.top_left : s == "Top Center" ? position.top_center : s == "Top Right" ? position.top_right : s == "Middle Right" ? position.middle_right : s == "Bottom Left" ? position.bottom_left : s == "Bottom Center" ? position.bottom_center : s == "Bottom Right" ? position.bottom_right : position.middle_right

getTxtSize(string s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small

// Wilson score interval for a binomial proportion (z fixed at 1.96 = 95%).
// Returns [center, halfWidth] as fractions 0–1. Chosen over the normal
// approximation because it stays honest at small N and extreme win rates.
wilsonCI(int w, int n) =>
    float z = 1.96
    float nf = float(n)
    float p = float(w) / nf
    float z2n = z * z / nf
    float center = (p + z2n / 2.0) / (1.0 + z2n)
    float half = z * math.sqrt(p * (1.0 - p) / nf + z * z / (4.0 * nf * nf)) / (1.0 + z2n)
    [center, half]

// Would a signal on this side record if it confirmed at this bar's close?
// Precedence EXACTLY mirrors the recording logic: halt → direction filter
// → dedupe cooldown → gate. Returns a short status glyph.
sideStatus(bool canRec, bool want, int lastFire, int cooldown, bool gatePass) =>
    string s = "✔"
    if not canRec
        s := "⛔"
    else if not want
        s := "✗off"
    else if not na(lastFire) and bar_index - lastFire <= cooldown
        s := "⏸" + str.tostring(cooldown - (bar_index - lastFire) + 1)
    else if not gatePass
        s := "✂"
    s

// =============================== INPUTS ==============================
// --- Sources ---
i_sigSrc    = input.source(close, "Signal Source", group="Sources", tooltip="What the lab tracks. With Signal Type = Event Stream: wire a ±1 EXT stream (e.g. 'RSI Div Pro: EXT: Any Bullish Div', 'HRN: EXT: Spring / Upthrust'). With Signal Type = Price Line: wire ANY price-level plot — HRN's EMA 1/2/3, a VWAP, RSI Div Pro's smoothing MA — and the lab derives the events itself. Pine cannot default to an external plot, so this MUST be re-pointed after adding the lab — until then recording is HALTED (⛔ in header).")
i_sigType   = input.string("Event Stream (±1)", "Signal Type", options=["Event Stream (±1)","Price Line: Cross","Price Line: Test"], group="Sources", tooltip="How to interpret the Signal Source. EVENT STREAM (±1): the source is a protocol stream (>= +0.5 long event, <= -0.5 short event) — all EXT bus streams. PRICE LINE: CROSS: the source is a price-level line; long = close crosses ABOVE it (the reclaim), short = close crosses BELOW. PRICE LINE: TEST: price was already holding above the line, dips to TOUCH it intrabar, and closes back above = long test (mirror for shorts). A cross bar does NOT double as a test — the two modes partition events cleanly. This is how you measure 'buying EMA 1/2/3': wire the EMA plot, pick Cross or Test.")
i_sigName   = input.string("Signal", "Signal Nickname", group="Sources", tooltip="Displayed in the Conditions section. Pine cannot read the NAME of a wired source — only its values cross into the script — so label what you wired yourself (e.g. 'EMA1 Reclaim', 'Bull Divs'). Purely a display label; changing it never affects the stats.")
i_sigMode   = input.string("Impulse (transitions only)", "Signal Mode", options=["Impulse (transitions only)","State (every signal bar)"], group="Sources", tooltip="Applies to Event Stream type only. Impulse (default): records only when the source TRANSITIONS into signal — one entry per event. State: records every bar in signal. IGNORED in Price Line types: a cross is inherently one event, and tests fire on each qualifying bar — use the Dedupe Cooldown to thin dense tests.")
i_regSrc    = input.source(close, "Regime Source", group="Sources", tooltip="Point this at 'HRN: EXT: Regime Code' (2=Trend Up, 1=Accum, 0=Neutral, -1=Dist, -2=Trend Down). Read at the entry bar. If invalid (|value| > 2.5), entries bucket to Neutral and the header warns — the All row stays valid.")
i_useRegime = input.bool(true, "Condition by Regime", group="Sources", tooltip="ON: results split into five regime rows + All. OFF: one All row only (use when HRN isn't on the chart).")
i_dirFilter = input.string("Both", "Direction Filter", options=["Both","Long Only","Short Only"], group="Sources", tooltip="Which side to record. A one-sided setting SKIPS the other side entirely — no entries, no markers, no ✂ count; the header shows '· L only' / '· S only'. For 'what is BUYING this EMA worth', use Long Only — in Both, each regime row mixes reclaim-longs and breakdown-shorts of the same line.")
i_cooldown  = input.int(0, "Dedupe Cooldown (bars)", minval=0, maxval=200, group="Sources", tooltip="A new entry is skipped unless MORE than this many bars have passed since the last RECORDED entry in the same direction (gated-out signals don't consume it). 0 = record every qualifying event. Recommended 3–5 for Price Line: Test on trending charts — price riding an EMA can test it on consecutive bars.")

// --- Confluence Gate ---
i_useGate = input.bool(false, "Enable Gate", group="Confluence Gate", inline="g0")
i_gateSrc = input.source(close, "", group="Confluence Gate", inline="g0", tooltip="A condition that must be (or recently have been) active for a signal to record. With Gate Type = Event/State Stream: wire a ±1 stream — 'HRN: EXT: Confluence State', 'EXT: Golden Zone State', or a divergence stream. With Gate Type = Price Line: wire any price-level plot — e.g. EMA 3 — and the bull side is active while close is ABOVE it, bear side while BELOW. If enabled but unwired/invalid, recording HALTS (⛔) — a gate reading garbage would silently corrupt the subset.")
i_gateType = input.string("Event/State Stream (±1)", "Gate Type", options=["Event/State Stream (±1)","Price Line: Above/Below"], group="Confluence Gate", tooltip="How to interpret the Gate Source. EVENT/STATE STREAM: ±1 protocol (>= +0.5 bull side active, <= -0.5 bear side). PRICE LINE: ABOVE/BELOW: bull side active while close > line, bear side while close < line — 'only take signals while structure holds above EMA 3' becomes a two-click gate.")
i_gateName = input.string("Gate", "Gate Nickname", group="Confluence Gate", tooltip="Displayed in the Conditions section — label what you wired (e.g. 'Confluence', 'Above EMA3'). Display only; Pine cannot read the wired source's name.")
i_gateWin = input.int(8, "Gate Memory (bars)", minval=0, maxval=100, group="Confluence Gate", tooltip="0 = gate must be active ON the signal bar itself. N > 0 = gate active within the last N bars. Default 8 covers RSI Div Pro's default 5-bar confirmation lag — 'the gate was live at or since roughly the divergence pivot'. Keep this >= your Pivot Lookback Right when gating divergences. Backward-looking only — no lookahead either way.")
i_gateDir = input.string("Match Signal Direction", "Direction Logic", options=["Match Signal Direction","Any Direction"], group="Confluence Gate", tooltip="Match (default): a long signal needs the BULL side of the gate active, a short needs the bear side. Any: gate passes if either side was active. Note: one-sided gate streams never emit the other sign — under Match, the other side is always gated out. That's by design; the ✂ counter, gray markers, and the ✂ Reject row will show it.")

// --- Bracket Engine (identical semantics to RSI Div Pro's tracker) ---
i_atrLen   = input.int(14, "ATR Length", minval=1, group="Bracket Engine", inline="b1")
i_tgtMult  = input.float(2.0, "Target ×ATR", minval=0.1, step=0.1, group="Bracket Engine", inline="b1")
i_stopMult = input.float(1.0, "Stop ×ATR", minval=0.1, step=0.1, group="Bracket Engine", inline="b2")
i_horizon  = input.int(20, "Horizon (bars)", minval=1, group="Bracket Engine", inline="b2", tooltip="Entry at the close of the confirmed signal bar; ATR-multiple target and stop; horizon expiry marks to close (win only if R > 0). Gap-aware: a bar OPENING beyond the stop/target fills at the open. Stop checked before target on a same-bar tie (conservative). Same engine as RSI Div Pro, so Exp R is directly comparable across tools.")

// --- Statistics ---
i_showCI  = input.bool(true, "Wilson 95% CI on Win%", group="Statistics", inline="s1")
i_starOn  = input.bool(true, "★ vs Breakeven", group="Statistics", inline="s1", tooltip="CI: Win% cells show ± the Wilson 95% half-width — a 58% on N=12 and N=180 stop looking alike. ★: awarded when the EXACT Wilson lower bound clears the bracket's breakeven win rate (stop ÷ (stop + target)) — the row's edge is statistically distinguishable from chance at 95%. Hover any Win% cell for the exact interval. Caveat: the CI assumes independent trades; overlapping open positions weaken it somewhat.")
i_showExc = input.bool(true, "MFE / MAE Columns", group="Statistics", tooltip="L·MFE = average Max Favorable Excursion of LOSING trades (R): how far losers ran in your favor before dying — approaching the target multiple means the target is too far. W·MAE = average Max Adverse Excursion of WINNING trades (R): heat winners took — well under 1.0 means the stop is wider than the setup needs. Excursions exclude each trade's resolution bar (OHLC can't order intrabar events), so both are slightly understated — conservative by design.")
i_showRecent = input.bool(true, "Recent Row", group="Statistics", inline="s2")
i_recentK = input.int(20, "", minval=5, maxval=200, group="Statistics", inline="s2", tooltip="Rolling window: Win%/Exp R over the last K resolved real trades, pooled across regimes. Compares against All to make edge decay (or improvement) visible. Exempt from min-N dimming — its small sample is by design; the CI carries the honesty. Tooltip on the row shows the window's median R (gap-robust where the mean isn't).")
i_showReject = input.bool(true, "Reject Row (Gate A/B)", group="Statistics", tooltip="When the gate is ON, rejected signals are fully simulated with the identical bracket into a ✂ Reject row — the control group. If Reject underperforms All (accepted), the gate is earning its keep; if Reject carries edge, the gate is throwing money away. Aggregate only (not regime-bucketed), excursions not tracked, own per-side dedupe cooldown.")

// --- Table ---
i_showTbl = input.bool(true, "Show Table", group="Table", inline="t0")
i_tblPos  = input.string("Middle Right", "", options=["Top Left","Top Center","Top Right","Middle Right","Bottom Left","Bottom Center","Bottom Right"], group="Table", inline="t0", tooltip="Defaults to Middle Right so it doesn't collide with HRN's Top Right / Bottom Left tables or RSI Div Pro's Bottom Right outcome table.")
i_tblSize = input.string("Small", "Text Size", options=["Tiny","Small","Normal","Large"], group="Table")
i_tblBg   = input.color(color.new(color.black, 70), "BG", group="Table", inline="t1")
i_tblTxt  = input.color(color.white, "Text", group="Table", inline="t1")
i_minN    = input.int(30, "Min N (dim below)", minval=1, group="Table", tooltip="Rows with fewer resolved trades than this render dimmed, and Exp R stays uncolored — small samples should LOOK like noise. The Recent row is exempt (small by design).")
i_showBars = input.bool(true, "Show Avg Bars Column", group="Table", tooltip="Average bars from entry to resolution per bucket.")
i_showCond = input.bool(true, "Show Conditions Section", group="Table", tooltip="Appends a live status footer: what the lab is tracking (your nicknames — Pine cannot read source names), the live regime read, gate ages vs the memory window, and a pre-flight 'Next' row showing whether a long/short confirming at THIS bar's close would record, be gated, sit in cooldown, be filtered, or be halted.")

// --- Table Rows (regime) ---
i_rTU = input.bool(true, "Trend Up", group="Table Rows", inline="rr1")
i_rAC = input.bool(true, "Accum",    group="Table Rows", inline="rr1")
i_rNE = input.bool(true, "Neutral",  group="Table Rows", inline="rr1")
i_rDI = input.bool(true, "Dist",     group="Table Rows", inline="rr2")
i_rTD = input.bool(true, "Trend Dn", group="Table Rows", inline="rr2", tooltip="Toggle any regime row off to shrink the table. The All row always shows.")
i_cTU = input.color(color.green,  "", group="Table Rows", inline="rc1")
i_cAC = input.color(color.lime,   "", group="Table Rows", inline="rc1")
i_cNE = input.color(color.gray,   "", group="Table Rows", inline="rc1")
i_cDI = input.color(color.orange, "", group="Table Rows", inline="rc1")
i_cTD = input.color(color.red,    "", group="Table Rows", inline="rc1", tooltip="Row name colors: Trend Up · Accum · Neutral · Dist · Trend Down. Defaults mirror HRN's regime palette.")

// --- Table Flash ---
i_flashOn   = input.bool(true, "Flash on New Entry", group="Table Flash", inline="f0")
i_flashBars = input.int(3, "Bars", minval=1, maxval=50, group="Table Flash", inline="f0")
i_flashBull = input.color(color.new(color.green, 55), "Long", group="Table Flash", inline="f1")
i_flashBear = input.color(color.new(color.red, 55),  "Short", group="Table Flash", inline="f1", tooltip="Tints the table when a new simulated trade is recorded — green long, red short.")

// --- Entry Markers ---
i_showMarks = input.bool(true, "Mark Recorded Entries", group="Entry Markers", inline="mk0")
i_markStyle = input.string("Triangle", "", options=["Triangle","Arrow","Circle","Text Bubble","Text Only"], group="Entry Markers", inline="mk0", tooltip="Marker shape. Triangle/Arrow/Circle = shape markers. Text Bubble = colored callout with custom text. Text Only = floating text. Longs render BELOW the bar, shorts ABOVE — always.")
i_markSize  = input.string("Tiny", "Size", options=["Tiny","Small","Normal","Large"], group="Entry Markers", inline="mk1")
i_markAlpha = input.int(20, "Bubble Bg Alpha", minval=0, maxval=100, group="Entry Markers", inline="mk1", tooltip="Background transparency for Text Bubble style only.")
i_markLCol  = input.color(color.lime, "Long", group="Entry Markers", inline="mk2")
i_markSCol  = input.color(color.red,  "Short", group="Entry Markers", inline="mk2", tooltip="Marker colors per side — shape fill, or bubble/text color in text modes.")
i_markLTxt  = input.string("▲", "Long Text", group="Entry Markers", inline="mk3")
i_markSTxt  = input.string("▼", "Short Text", group="Entry Markers", inline="mk3", tooltip="Marker text — used by Text Bubble and Text Only styles.")
i_markTxtCol = input.color(color.white, "Bubble Text", group="Entry Markers", inline="mk4")
i_maxMarks  = input.int(200, "Max Kept", minval=10, maxval=480, group="Entry Markers", inline="mk4", tooltip="Oldest markers removed beyond this (Pine label limit).")
i_markGatedOn = input.bool(true, "Mark Gated-Out Signals", group="Entry Markers", inline="mk5")
i_markGCol    = input.color(color.gray, "", group="Entry Markers", inline="mk5", tooltip="When the gate is on, signals it FILTERED are marked in this color (same style/text/position rules) — so you can see on the chart exactly what the filter removed.")

// ========================= GLOBAL CALCULATIONS =======================
float atrVal = ta.atr(i_atrLen)
float sigV  = i_sigSrc
float regV  = i_regSrc
float gateV = i_gateSrc
float beRate = i_stopMult / (i_stopMult + i_tgtMult)   // breakeven win rate for the bracket

bool sigTypeEvent = i_sigType == "Event Stream (±1)"
bool sigTypeCross = i_sigType == "Price Line: Cross"
bool sigTypeTest  = i_sigType == "Price Line: Test"
bool gateTypeLine = i_gateType == "Price Line: Above/Below"

// --- Event-stream semantics (used when Signal Type = Event Stream) ---
bool sigLong  = not na(sigV) and sigV >= 0.5
bool sigShort = not na(sigV) and sigV <= -0.5
bool wantLong  = i_dirFilter != "Short Only"
bool wantShort = i_dirFilter != "Long Only"

// --- Price-line derivations (ta.* hoisted unconditionally per the
// consistent-calculation rule; guards keep bools strict on na sources) ---
bool rawCrossUp = ta.crossover(close, sigV)
bool rawCrossDn = ta.crossunder(close, sigV)
bool crossUp = not na(sigV) and rawCrossUp
bool crossDn = not na(sigV) and rawCrossDn
bool lineAbove = not na(sigV) and close > sigV
bool lineBelow = not na(sigV) and close < sigV
// Test = was already on-side last bar, touched the line intrabar, closed
// back on-side. var-prev pattern (v6 bool strictness forbids bool[1], na on
// bar zero). A crossover bar is EXCLUDED — prev bar must already be on-side —
// so Cross and Test partition events instead of double-counting.
var bool prevAboveL = false
var bool prevBelowL = false
bool testLong  = sigTypeTest and lineAbove and prevAboveL and low <= sigV
bool testShort = sigTypeTest and lineBelow and prevBelowL and high >= sigV

// --- Impulse tracking for event streams ---
var bool prevLong  = false
var bool prevShort = false
bool impulse = i_sigMode == "Impulse (transitions only)"

// --- Unified event derivation: the ONE point where Signal Type acts.
// Everything downstream (gate, recording, stats, markers) is type-agnostic.
bool longEvt  = sigTypeEvent ? (impulse ? (sigLong  and not prevLong)  : sigLong)  : sigTypeCross ? crossUp : testLong
bool shortEvt = sigTypeEvent ? (impulse ? (sigShort and not prevShort) : sigShort) : sigTypeCross ? crossDn : testShort
prevLong   := sigLong
prevShort  := sigShort
prevAboveL := lineAbove
prevBelowL := lineBelow

// Gate state ages (updated BEFORE recording: gate active on the signal bar
// itself reads age 0). Backward-looking only — causally clean.
bool gateBullAct = i_useGate and (gateTypeLine ? (not na(gateV) and close > gateV) : (not na(gateV) and gateV >= 0.5))
bool gateBearAct = i_useGate and (gateTypeLine ? (not na(gateV) and close < gateV) : (not na(gateV) and gateV <= -0.5))
var int gateAgeB = 100000
var int gateAgeS = 100000
gateAgeB := gateBullAct ? 0 : math.min(gateAgeB + 1, 100000)
gateAgeS := gateBearAct ? 0 : math.min(gateAgeS + 1, 100000)
bool gatePassL = not i_useGate or (i_gateDir == "Any Direction" ? math.min(gateAgeB, gateAgeS) <= i_gateWin : gateAgeB <= i_gateWin)
bool gatePassS = not i_useGate or (i_gateDir == "Any Direction" ? math.min(gateAgeB, gateAgeS) <= i_gateWin : gateAgeS <= i_gateWin)

// ==================== SOURCE VALIDITY (halt gates) ===================
// Recording garbage that LOOKS like data is worse than recording nothing.
// Checks are TYPE-AWARE: the ±1.5 magnitude halt applies to Event Stream
// wiring only (a price line is SUPPOSED to carry dollar values); line types
// get the reverse check — a source that never leaves ±1.5 while the chart
// trades above $3 is an event stream wired under a line type (TYPE MISMATCH).
// On sub-$3 symbols that detector stays silent (stated, not hidden).
// Nothing persists across input changes — re-wiring replays history clean.
var bool sigInvalid    = false
var bool everDiffered  = false
var bool sigEverBig    = false
var bool gateInvalid   = false
var bool gateEverDiff  = false
var bool gateEverBig   = false
var bool regInvalid    = false
var int  obsBars = 0
var int  fireCnt = 0
var int  bigCloseBars = 0

if not na(sigV) and math.abs(sigV) > 1.5
    sigEverBig := true
    if sigTypeEvent
        sigInvalid := true
if not na(sigV) and sigV != close
    everDiffered := true
if i_useGate and not na(gateV) and math.abs(gateV) > 1.5
    gateEverBig := true
    if not gateTypeLine
        gateInvalid := true
if i_useGate and not na(gateV) and gateV != close
    gateEverDiff := true
if i_useRegime and not na(regV) and math.abs(regV) > 2.5
    regInvalid := true

bool fireForRate = sigTypeEvent ? (sigLong or sigShort) : (longEvt or shortEvt)
if barstate.isconfirmed
    obsBars += 1
    if close > 3
        bigCloseBars += 1
    if fireForRate
        fireCnt += 1

bool sigUnwired   = not everDiffered and obsBars >= 20
bool sigMisTyped  = (not sigTypeEvent) and (not sigEverBig) and bigCloseBars >= 20
bool gateUnwired  = i_useGate and not gateEverDiff and obsBars >= 20
bool gateMisTyped = i_useGate and gateTypeLine and (not gateEverBig) and bigCloseBars >= 20
bool gateHalt     = i_useGate and (gateInvalid or gateUnwired or gateMisTyped)
bool canRecord    = not sigInvalid and not sigUnwired and not sigMisTyped and not gateHalt

// Regime bucket at THIS bar: 0=TrendUp 1=Accum 2=Neutral 3=Dist 4=TrendDn
int curBucket = 2
if i_useRegime and not regInvalid and not na(regV)
    int rc = math.round(regV)
    curBucket := rc >= 2 ? 0 : rc == 1 ? 1 : rc == 0 ? 2 : rc == -1 ? 3 : 4

// ================================ STATE ==============================
// Pending pool — 11 parallel arrays; every push/remove site keeps lockstep.
var array<int>   pendDir   = array.new<int>()
var array<float> pendEntry = array.new<float>()
var array<float> pendTgt   = array.new<float>()
var array<float> pendStop  = array.new<float>()
var array<float> pendRisk  = array.new<float>()
var array<int>   pendDL    = array.new<int>()
var array<int>   pendBkt   = array.new<int>()
var array<int>   pendBar   = array.new<int>()
var array<int>   pendReal  = array.new<int>()    // 1 = real, 0 = shadow (gate-rejected)
var array<float> pendMFE   = array.new<float>()  // running max favorable excursion (R)
var array<float> pendMAE   = array.new<float>()  // running max adverse excursion (R)

var array<int>   winCnt  = array.from(0, 0, 0, 0, 0)
var array<int>   totCnt  = array.from(0, 0, 0, 0, 0)
var array<float> sumR    = array.from(0.0, 0.0, 0.0, 0.0, 0.0)
var array<int>   sumBars = array.from(0, 0, 0, 0, 0)
var array<float> sumMFEL = array.from(0.0, 0.0, 0.0, 0.0, 0.0)  // MFE of losers, per bucket
var array<float> sumMAEW = array.from(0.0, 0.0, 0.0, 0.0, 0.0)  // MAE of winners, per bucket

// master list of resolved real-trade R values (Recent row + medians).
// Soft cap 4000 — beyond any realistic chart output; shift keeps it bounded.
var array<float> allR = array.new<float>()

// shadow (gate-rejected) aggregate counters
var int   shdTot  = 0
var int   shdWin  = 0
var float shdSumR = 0.0
var int   lastShadL = na
var int   lastShadS = na

var int lastFireL  = na
var int lastFireS  = na
var int lastRecBar = na
var int lastRecDir = 0
var int gatedCnt   = 0
var array<label> marks = array.new<label>()

// ===================== WIN CELL FORMATTER ============================
// Returns [cellText, starred, tooltip]. Cell shows raw Win% ± Wilson
// half-width (approximate — the true interval is asymmetric at small N);
// the tooltip carries the EXACT bounds, and the ★ always uses the exact
// lower bound vs breakeven. Honest at a glance, exact one hover away.
winStats(int w, int n) =>
    string txt = "—"
    bool star = false
    string tip = ""
    if n > 0
        float praw = float(w) / float(n) * 100.0
        [c, h] = wilsonCI(w, n)
        float loP = math.max(0.0, (c - h) * 100.0)
        float hiP = math.min(100.0, (c + h) * 100.0)
        txt := str.tostring(praw, "0")
        if i_showCI
            txt += "±" + str.tostring(h * 100.0, "0")
        star := i_starOn and (c - h) > beRate
        if star
            txt += "★"
        tip := "Wilson 95% CI: " + str.tostring(loP, "0") + "–" + str.tostring(hiP, "0") + "%." + (star ? " Lower bound clears breakeven (" + str.tostring(beRate * 100.0, "0.0") + "%) — edge distinguishable from chance at 95%." : "")
    [txt, star, tip]

// ========================= MARKER HELPERS ============================
getMarkStyle(bool isLong) =>
    i_markStyle == "Arrow" ? (isLong ? label.style_arrowup : label.style_arrowdown) : i_markStyle == "Circle" ? label.style_circle : i_markStyle == "Text Bubble" ? (isLong ? label.style_label_up : label.style_label_down) : i_markStyle == "Text Only" ? label.style_none : (isLong ? label.style_triangleup : label.style_triangledown)

addMark(bool isLong, bool isGated) =>
    color base = isGated ? i_markGCol : (isLong ? i_markLCol : i_markSCol)
    bool textMode = i_markStyle == "Text Bubble" or i_markStyle == "Text Only"
    string txt = textMode ? (isLong ? i_markLTxt : i_markSTxt) : ""
    color bgCol = i_markStyle == "Text Bubble" ? color.new(base, i_markAlpha) : i_markStyle == "Text Only" ? na : base
    color txCol = i_markStyle == "Text Bubble" ? i_markTxtCol : base
    lb = label.new(bar_index, na, txt, xloc=xloc.bar_index, yloc = isLong ? yloc.belowbar : yloc.abovebar, style=getMarkStyle(isLong), color=bgCol, textcolor=txCol, size=getTxtSize(i_markSize))
    array.push(marks, lb)
    while array.size(marks) > i_maxMarks
        label.delete(array.shift(marks))

// ==================== RESOLUTION (before recording) ==================
// Confirmed bars only; a record created this bar isn't evaluated until
// the next (this block runs first). Gap-aware, stop-first tiebreak.
// Real trades feed bucket stats + allR; shadow trades feed shadow counters.
if barstate.isconfirmed and array.size(pendDir) > 0
    for i = array.size(pendDir) - 1 to 0
        int   dir = array.get(pendDir, i)
        float e   = array.get(pendEntry, i)
        float tg  = array.get(pendTgt, i)
        float st  = array.get(pendStop, i)
        float rk  = array.get(pendRisk, i)
        int   dl  = array.get(pendDL, i)
        int   bkt = array.get(pendBkt, i)
        int   eb  = array.get(pendBar, i)
        int   rl  = array.get(pendReal, i)
        float mfe = array.get(pendMFE, i)
        float mae = array.get(pendMAE, i)
        bool resolved = false
        bool win = false
        float rR = na
        if dir > 0
            if open <= st
                resolved := true
                win := false
                rR := (open - e) / rk
            else if open >= tg
                resolved := true
                win := true
                rR := (open - e) / rk
            else if low <= st
                resolved := true
                win := false
                rR := (st - e) / rk
            else if high >= tg
                resolved := true
                win := true
                rR := (tg - e) / rk
        else
            if open >= st
                resolved := true
                win := false
                rR := (e - open) / rk
            else if open <= tg
                resolved := true
                win := true
                rR := (e - open) / rk
            else if high >= st
                resolved := true
                win := false
                rR := (e - st) / rk
            else if low <= tg
                resolved := true
                win := true
                rR := (e - tg) / rk
        if not resolved and bar_index >= dl
            resolved := true
            rR := dir > 0 ? (close - e) / rk : (e - close) / rk
            win := rR > 0
        if resolved
            if rl == 1
                array.set(totCnt, bkt, array.get(totCnt, bkt) + 1)
                array.set(sumR, bkt, array.get(sumR, bkt) + rR)
                array.set(sumBars, bkt, array.get(sumBars, bkt) + (bar_index - eb))
                if win
                    array.set(winCnt, bkt, array.get(winCnt, bkt) + 1)
                    array.set(sumMAEW, bkt, array.get(sumMAEW, bkt) + mae)
                else
                    array.set(sumMFEL, bkt, array.get(sumMFEL, bkt) + mfe)
                array.push(allR, rR)
                if array.size(allR) > 4000
                    array.shift(allR)
            else
                shdTot += 1
                shdSumR += rR
                if win
                    shdWin += 1
            array.remove(pendDir, i)
            array.remove(pendEntry, i)
            array.remove(pendTgt, i)
            array.remove(pendStop, i)
            array.remove(pendRisk, i)
            array.remove(pendDL, i)
            array.remove(pendBkt, i)
            array.remove(pendBar, i)
            array.remove(pendReal, i)
            array.remove(pendMFE, i)
            array.remove(pendMAE, i)

// =================== EXCURSION UPDATE (survivors only) ==============
// Runs AFTER resolution: a trade's resolution bar is never counted in its
// excursions (OHLC can't order intrabar events — counting it would be quiet
// lookahead). New records this bar start at 0 and update from the next bar.
// Invariants this creates: L·MFE < target multiple, W·MAE < stop multiple
// (a survivor bar reaching either level would have resolved the trade).
if barstate.isconfirmed and array.size(pendDir) > 0
    for i = 0 to array.size(pendDir) - 1
        int   dir = array.get(pendDir, i)
        float e   = array.get(pendEntry, i)
        float rk  = array.get(pendRisk, i)
        float fav = dir > 0 ? (high - e) / rk : (e - low) / rk
        float adv = dir > 0 ? (e - low) / rk : (high - e) / rk
        if fav > array.get(pendMFE, i)
            array.set(pendMFE, i, fav)
        if adv > array.get(pendMAE, i)
            array.set(pendMAE, i, adv)

// ============================= RECORDING =============================
bool recLong  = false
bool recShort = false
if canRecord and barstate.isconfirmed and not na(atrVal) and atrVal > 0
    float e  = close
    float rk = i_stopMult * atrVal
    bool cdOKL = na(lastFireL) or bar_index - lastFireL > i_cooldown
    bool cdOKS = na(lastFireS) or bar_index - lastFireS > i_cooldown
    if longEvt and wantLong and cdOKL
        if gatePassL
            array.push(pendDir, 1)
            array.push(pendEntry, e)
            array.push(pendTgt, e + i_tgtMult * atrVal)
            array.push(pendStop, e - i_stopMult * atrVal)
            array.push(pendRisk, rk)
            array.push(pendDL, bar_index + i_horizon)
            array.push(pendBkt, curBucket)
            array.push(pendBar, bar_index)
            array.push(pendReal, 1)
            array.push(pendMFE, 0.0)
            array.push(pendMAE, 0.0)
            lastFireL := bar_index
            lastRecBar := bar_index
            lastRecDir := 1
            recLong := true
            if i_showMarks
                addMark(true, false)
        else
            gatedCnt += 1
            bool shOKL = na(lastShadL) or bar_index - lastShadL > i_cooldown
            if shOKL
                array.push(pendDir, 1)
                array.push(pendEntry, e)
                array.push(pendTgt, e + i_tgtMult * atrVal)
                array.push(pendStop, e - i_stopMult * atrVal)
                array.push(pendRisk, rk)
                array.push(pendDL, bar_index + i_horizon)
                array.push(pendBkt, curBucket)
                array.push(pendBar, bar_index)
                array.push(pendReal, 0)
                array.push(pendMFE, 0.0)
                array.push(pendMAE, 0.0)
                lastShadL := bar_index
            if i_showMarks and i_markGatedOn
                addMark(true, true)
    if shortEvt and wantShort and cdOKS
        if gatePassS
            array.push(pendDir, -1)
            array.push(pendEntry, e)
            array.push(pendTgt, e - i_tgtMult * atrVal)
            array.push(pendStop, e + i_stopMult * atrVal)
            array.push(pendRisk, rk)
            array.push(pendDL, bar_index + i_horizon)
            array.push(pendBkt, curBucket)
            array.push(pendBar, bar_index)
            array.push(pendReal, 1)
            array.push(pendMFE, 0.0)
            array.push(pendMAE, 0.0)
            lastFireS := bar_index
            lastRecBar := bar_index
            lastRecDir := -1
            recShort := true
            if i_showMarks
                addMark(false, false)
        else
            gatedCnt += 1
            bool shOKS = na(lastShadS) or bar_index - lastShadS > i_cooldown
            if shOKS
                array.push(pendDir, -1)
                array.push(pendEntry, e)
                array.push(pendTgt, e - i_tgtMult * atrVal)
                array.push(pendStop, e + i_stopMult * atrVal)
                array.push(pendRisk, rk)
                array.push(pendDL, bar_index + i_horizon)
                array.push(pendBkt, curBucket)
                array.push(pendBar, bar_index)
                array.push(pendReal, 0)
                array.push(pendMFE, 0.0)
                array.push(pendMAE, 0.0)
                lastShadS := bar_index
            if i_showMarks and i_markGatedOn
                addMark(false, true)

// =============================== TABLE ===============================
bool  flashActive = i_flashOn and not na(lastRecBar) and (bar_index - lastRecBar) <= i_flashBars
color tblBgNow = flashActive ? (lastRecDir > 0 ? i_flashBull : i_flashBear) : i_tblBg

var table lab = na
if i_showTbl and barstate.islast
    if not na(lab)
        table.delete(lab)
    array<string> bNames = array.from("Trend Up", "Accum", "Neutral", "Dist", "Trend Dn")
    array<color>  bCols  = array.from(i_cTU, i_cAC, i_cNE, i_cDI, i_cTD)
    array<bool>   bOn    = array.from(i_rTU, i_rAC, i_rNE, i_rDI, i_rTD)
    int nRegRows = 0
    if i_useRegime
        for k = 0 to 4
            if array.get(bOn, k)
                nRegRows += 1
    bool showRecentRow = i_showRecent
    bool showRejectRow = i_useGate and i_showReject
    int condRows = i_showCond ? 3 + (i_useGate ? 1 : 0) : 0
    int cols = 4 + (i_showBars ? 1 : 0) + (i_showExc ? 2 : 0)
    int rows = 1 + nRegRows + 1 + (showRecentRow ? 1 : 0) + (showRejectRow ? 1 : 0) + condRows
    int colBarsIdx = i_showBars ? 4 : -1
    int colMFEIdx  = i_showExc ? (i_showBars ? 5 : 4) : -1
    int colMAEIdx  = i_showExc ? colMFEIdx + 1 : -1
    lab := table.new(getTablePos(i_tblPos), cols, rows, bgcolor=tblBgNow, border_width=1, border_color=color.new(color.gray, 60))
    txSz = getTxtSize(i_tblSize)
    bool rateSuspect = obsBars > 100 and fireCnt * 4 > obsBars
    bool halted = sigInvalid or sigUnwired or sigMisTyped or gateHalt
    int nPend = array.size(pendDir)
    string dirTag = i_dirFilter == "Long Only" ? " · L only" : i_dirFilter == "Short Only" ? " · S only" : ""
    string haltName = sigMisTyped ? "SIGNAL TYPE MISMATCH" : gateMisTyped ? "GATE TYPE MISMATCH" : (sigInvalid or sigUnwired) ? "WIRE SIGNAL SOURCE" : "WIRE GATE SOURCE"
    string hdr = halted ? ("⛔ " + haltName) : ((regInvalid ? "⚠ REGIME SRC · " : rateSuspect ? "⚠ FIRE RATE · " : "") + "EXP LAB" + dirTag + (nPend > 0 ? " · " + str.tostring(nPend) + " open" : "") + (i_useGate ? " · ✂" + str.tostring(gatedCnt) : ""))
    color hdrCol = halted ? color.red : (regInvalid or rateSuspect) ? color.orange : i_tblTxt
    string hdrTip = sigInvalid ? "Signal Type is 'Event Stream (±1)' but source values exceed ±1.5 — this is a price series (an EMA/VWAP?), not an event stream. Recording HALTED. Either wire an EXT event stream, or switch Signal Type to a Price Line mode if a line is what you meant. Stats rebuild automatically." : sigUnwired ? "Signal Source has matched 'close' on every bar — still at its default. Recording HALTED until re-pointed." : sigMisTyped ? "Signal Type is a Price Line mode but the source never leaves ±1.5 while this chart trades above $3 — that looks like a ±1 EVENT stream wired as a line. Recording HALTED. Switch Signal Type to 'Event Stream (±1)' or wire an actual price line (EMA/VWAP)." : gateInvalid ? "Gate Type is 'Event/State Stream (±1)' but gate values exceed ±1.5 — that's a price series. Recording HALTED. Switch Gate Type to 'Price Line: Above/Below' if a line is what you meant, or wire a ±1 stream." : gateUnwired ? "Gate is ENABLED but its source has matched 'close' on every bar — still at its default. Recording HALTED until re-pointed (or disable the gate)." : gateMisTyped ? "Gate Type is 'Price Line' but the gate source never leaves ±1.5 while this chart trades above $3 — that looks like a ±1 stream wired as a line. Recording HALTED. Switch Gate Type to 'Event/State Stream (±1)' or wire an actual price line." : regInvalid ? "Regime Source values outside -2..2 (not wired to EXT: Regime Code). Entries bucketing to Neutral; the All row is still valid." : rateSuspect ? "Over 25% of bars carry a signal event. For Event Stream wiring this suggests a STATE source — check the wiring or use State mode + dedupe deliberately. For Price Line: Test, a strong trend riding the line can legitimately do this — thin it with the Dedupe Cooldown." : i_useGate ? ("Recording normally. ✂ = signals filtered by the gate (" + str.tostring(gatedCnt) + " so far). The ✂ Reject row simulates them as the control group.") : "Recording normally."
    string dirNote = i_dirFilter == "Long Only" ? " • Direction Filter = LONG ONLY: bearish events are skipped entirely — no entries, no markers, no ✂ count. Set it to Both to see shorts." : i_dirFilter == "Short Only" ? " • Direction Filter = SHORT ONLY: bullish events are skipped entirely. Set it to Both to see longs." : ""
    table.cell(lab, 0, 0, hdr, text_color=hdrCol, text_size=txSz, text_halign=text.align_left, tooltip=hdrTip + dirNote)
    table.cell(lab, 1, 0, "N", text_color=i_tblTxt, text_size=txSz)
    string winHdr = i_starOn ? "Win%·BE" + str.tostring(beRate * 100.0, "0") : "Win%"
    table.cell(lab, 2, 0, winHdr, text_color=i_tblTxt, text_size=txSz, tooltip="Win rate ± Wilson 95% half-width (approximate — the exact asymmetric interval is in each row's hover). Breakeven for the current bracket = stop ÷ (stop + target) = " + str.tostring(beRate * 100.0, "0.0") + "%. ★ = exact Wilson lower bound clears breakeven: edge statistically distinguishable from chance at 95%. Caveat: assumes independent trades; overlapping open positions weaken the interval somewhat.")
    table.cell(lab, 3, 0, "Exp R", text_color=i_tblTxt, text_size=txSz)
    if i_showBars
        table.cell(lab, colBarsIdx, 0, "Bars", text_color=i_tblTxt, text_size=txSz)
    if i_showExc
        table.cell(lab, colMFEIdx, 0, "L·MFE", text_color=i_tblTxt, text_size=txSz, tooltip="Avg Max Favorable Excursion of LOSING trades, in R — how far losers ran in your favor before dying. Approaching the target multiple (" + str.tostring(i_tgtMult / i_stopMult, "0.0") + " here) means the target is too far: profits existed and were returned. Excludes each trade's resolution bar, so slightly understated (conservative).")
        table.cell(lab, colMAEIdx, 0, "W·MAE", text_color=i_tblTxt, text_size=txSz, tooltip="Avg Max Adverse Excursion of WINNING trades, in R — heat winners took before paying. Well under 1.0 means the stop is wider than the setup needs; your realized R:R is better than the bracket implies. Excludes each trade's resolution bar.")
    int row = 1
    if i_useRegime
        for ti = 0 to 4
            if array.get(bOn, ti)
                int n  = array.get(totCnt, ti)
                int wn = array.get(winCnt, ti)
                float sr = array.get(sumR, ti)
                int sb = array.get(sumBars, ti)
                bool dim = n < i_minN
                color nameCol = dim ? color.new(array.get(bCols, ti), 55) : array.get(bCols, ti)
                color numCol  = dim ? color.new(i_tblTxt, 55) : i_tblTxt
                [wTxt, wStar, wTip] = winStats(wn, n)
                color winCol = (wStar and not dim) ? color.new(color.green, 0) : numCol
                float expv = n > 0 ? sr / n : na
                string expStr = n > 0 ? (expv >= 0 ? "+" : "") + str.tostring(expv, "0.00") : "—"
                color expCol = n > 0 and not dim ? (expv >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)) : numCol
                string barsStr = n > 0 ? str.tostring(float(sb) / float(n), "0.0") : "—"
                int nLoss = n - wn
                string mfeStr = nLoss > 0 ? str.tostring(array.get(sumMFEL, ti) / float(nLoss), "0.0") : "—"
                string maeStr = wn > 0 ? str.tostring(array.get(sumMAEW, ti) / float(wn), "0.0") : "—"
                table.cell(lab, 0, row, array.get(bNames, ti), text_color=nameCol, text_size=txSz, text_halign=text.align_left)
                table.cell(lab, 1, row, str.tostring(n), text_color=numCol, text_size=txSz)
                table.cell(lab, 2, row, wTxt, text_color=winCol, text_size=txSz, tooltip=wTip)
                table.cell(lab, 3, row, expStr, text_color=expCol, text_size=txSz)
                if i_showBars
                    table.cell(lab, colBarsIdx, row, barsStr, text_color=numCol, text_size=txSz)
                if i_showExc
                    table.cell(lab, colMFEIdx, row, mfeStr, text_color=numCol, text_size=txSz)
                    table.cell(lab, colMAEIdx, row, maeStr, text_color=numCol, text_size=txSz)
                row += 1
    // ---- All row ----
    int allN = 0
    int allW = 0
    float allR2 = 0.0
    int allB = 0
    float aMFEL = 0.0
    float aMAEW = 0.0
    for ti = 0 to 4
        allN += array.get(totCnt, ti)
        allW += array.get(winCnt, ti)
        allR2 += array.get(sumR, ti)
        allB += array.get(sumBars, ti)
        aMFEL += array.get(sumMFEL, ti)
        aMAEW += array.get(sumMAEW, ti)
    bool dimAll = allN < i_minN
    color allNumCol = dimAll ? color.new(i_tblTxt, 55) : i_tblTxt
    [aTxt, aStar, aTip] = winStats(allW, allN)
    color allWinCol = (aStar and not dimAll) ? color.new(color.green, 0) : allNumCol
    float allExp = allN > 0 ? allR2 / allN : na
    string allExpStr = allN > 0 ? (allExp >= 0 ? "+" : "") + str.tostring(allExp, "0.00") : "—"
    color allExpCol = allN > 0 and not dimAll ? (allExp >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)) : allNumCol
    string allBarsStr = allN > 0 ? str.tostring(float(allB) / float(allN), "0.0") : "—"
    int allLoss = allN - allW
    string aMfeStr = allLoss > 0 ? str.tostring(aMFEL / float(allLoss), "0.0") : "—"
    string aMaeStr = allW > 0 ? str.tostring(aMAEW / float(allW), "0.0") : "—"
    int szAll = array.size(allR)
    float lifeMed = szAll > 0 ? array.median(allR) : na
    string allNameTip = szAll > 0 ? "Lifetime median R: " + (lifeMed >= 0 ? "+" : "") + str.tostring(lifeMed, "0.00") + " — robust to gap outliers, unlike the mean." : ""
    table.cell(lab, 0, row, "All", text_color=i_tblTxt, text_size=txSz, text_halign=text.align_left, tooltip=allNameTip)
    table.cell(lab, 1, row, str.tostring(allN), text_color=allNumCol, text_size=txSz)
    table.cell(lab, 2, row, aTxt, text_color=allWinCol, text_size=txSz, tooltip=aTip)
    table.cell(lab, 3, row, allExpStr, text_color=allExpCol, text_size=txSz)
    if i_showBars
        table.cell(lab, colBarsIdx, row, allBarsStr, text_color=allNumCol, text_size=txSz)
    if i_showExc
        table.cell(lab, colMFEIdx, row, aMfeStr, text_color=allNumCol, text_size=txSz)
        table.cell(lab, colMAEIdx, row, aMaeStr, text_color=allNumCol, text_size=txSz)
    row += 1
    // ---- Recent row ----
    if showRecentRow
        int kk = math.min(i_recentK, szAll)
        int recW = 0
        float recMean = na
        float recMed = na
        if kk > 0
            array<float> tailArr = array.new<float>()
            for q = szAll - kk to szAll - 1
                float rv = array.get(allR, q)
                array.push(tailArr, rv)
                if rv > 0
                    recW += 1
            recMean := array.avg(tailArr)
            recMed := array.median(tailArr)
        [rTxt, rStar, rTip] = winStats(recW, kk)
        color recWinCol = rStar ? color.new(color.green, 0) : i_tblTxt
        string recExpStr = kk > 0 ? (recMean >= 0 ? "+" : "") + str.tostring(recMean, "0.00") : "—"
        color recExpCol = kk > 0 ? (recMean >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)) : i_tblTxt
        string recTip = kk > 0 ? "Most recent " + str.tostring(kk) + " resolved real trades, pooled across regimes (rejected/shadow excluded). Median R: " + (recMed >= 0 ? "+" : "") + str.tostring(recMed, "0.00") + ". Compare with All to spot edge decay or improvement. Small window by design — the CI carries the uncertainty." : "No resolved trades yet."
        table.cell(lab, 0, row, "Last " + str.tostring(kk), text_color=i_tblTxt, text_size=txSz, text_halign=text.align_left, tooltip=recTip)
        table.cell(lab, 1, row, str.tostring(kk), text_color=i_tblTxt, text_size=txSz)
        table.cell(lab, 2, row, rTxt, text_color=recWinCol, text_size=txSz, tooltip=rTip)
        table.cell(lab, 3, row, recExpStr, text_color=recExpCol, text_size=txSz)
        if i_showBars
            table.cell(lab, colBarsIdx, row, "—", text_color=i_tblTxt, text_size=txSz)
        if i_showExc
            table.cell(lab, colMFEIdx, row, "—", text_color=i_tblTxt, text_size=txSz)
            table.cell(lab, colMAEIdx, row, "—", text_color=i_tblTxt, text_size=txSz)
        row += 1
    // ---- Reject row (gate control group) ----
    if showRejectRow
        bool dimSh = shdTot < i_minN
        color shNumCol = dimSh ? color.new(i_tblTxt, 55) : i_tblTxt
        [sTxt, sStar, sTip] = winStats(shdWin, shdTot)
        color shWinCol = (sStar and not dimSh) ? color.new(color.green, 0) : shNumCol
        float shExp = shdTot > 0 ? shdSumR / shdTot : na
        string shExpStr = shdTot > 0 ? (shExp >= 0 ? "+" : "") + str.tostring(shExp, "0.00") : "—"
        color shExpCol = shdTot > 0 and not dimSh ? (shExp >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)) : shNumCol
        string shTip = "Signals the gate filtered OUT, fully simulated with the identical bracket — the control group. If this row underperforms All (accepted), the gate is earning its keep; if it carries edge (★), the gate is discarding value. Aggregate only (not regime-bucketed); excursions not tracked; own per-side dedupe cooldown."
        table.cell(lab, 0, row, "✂ Reject", text_color=dimSh ? color.new(i_markGCol, 55) : i_markGCol, text_size=txSz, text_halign=text.align_left, tooltip=shTip)
        table.cell(lab, 1, row, str.tostring(shdTot), text_color=shNumCol, text_size=txSz)
        table.cell(lab, 2, row, sTxt, text_color=shWinCol, text_size=txSz, tooltip=sTip)
        table.cell(lab, 3, row, shExpStr, text_color=shExpCol, text_size=txSz)
        if i_showBars
            table.cell(lab, colBarsIdx, row, "—", text_color=shNumCol, text_size=txSz)
        if i_showExc
            table.cell(lab, colMFEIdx, row, "—", text_color=shNumCol, text_size=txSz)
            table.cell(lab, colMAEIdx, row, "—", text_color=shNumCol, text_size=txSz)
        row += 1
    // ---- Conditions section (live status footer) ----
    if i_showCond
        string sigLabel  = str.length(i_sigName) > 0 ? i_sigName : "Signal"
        string gateLabel = str.length(i_gateName) > 0 ? i_gateName : "Gate"
        string typeTag = sigTypeEvent ? (impulse ? "Impulse" : "State") : sigTypeCross ? "Line·Cross" : "Line·Test"
        // Signal row: nickname + type, with live fire state
        string sigFire = longEvt ? "▲ " : shortEvt ? "▼ " : ""
        color  sigCol  = longEvt ? i_markLCol : shortEvt ? i_markSCol : i_tblTxt
        string sigVal  = sigFire + sigLabel + " · " + typeTag
        string sigTip  = "What the lab is tracking. Pine cannot read a wired source's NAME — only its values cross into the script — so this shows the nickname from Settings → Sources. Type: " + i_sigType + (sigTypeEvent ? " · Mode: " + (impulse ? "Impulse (one entry per transition)" : "State (every signal bar)") : " · long = " + (sigTypeCross ? "close crosses above the line, short = crosses below" : "hold-above dip-and-close-above test of the line, short = mirror")) + ". Direction filter: " + i_dirFilter + ". Cooldown: " + str.tostring(i_cooldown) + " bars. ▲/▼ prefix = an event is live on this bar; recording happens at bar close."
        table.cell(lab, 0, row, "Signal", text_color=i_tblTxt, text_size=txSz, text_halign=text.align_left)
        table.cell(lab, 1, row, sigVal, text_color=sigCol, text_size=txSz, text_halign=text.align_left, tooltip=sigTip)
        table.merge_cells(lab, 1, row, cols - 1, row)
        row += 1
        // Regime row: live bucket read
        string regVal = not i_useRegime ? "off" : regInvalid ? "⚠ invalid → Neutral" : array.get(bNames, curBucket)
        color  regCol = not i_useRegime ? color.new(i_tblTxt, 55) : regInvalid ? color.orange : array.get(bCols, curBucket)
        table.cell(lab, 0, row, "Regime", text_color=i_tblTxt, text_size=txSz, text_halign=text.align_left)
        table.cell(lab, 1, row, regVal, text_color=regCol, text_size=txSz, text_halign=text.align_left, tooltip="Live regime read — the bucket a new entry would be tagged with right now.")
        table.merge_cells(lab, 1, row, cols - 1, row)
        row += 1
        // Gate row (only when the gate is on)
        if i_useGate
            string bAgeS = gateAgeB > 999 ? "—" : str.tostring(gateAgeB)
            string sAgeS = gateAgeS > 999 ? "—" : str.tostring(gateAgeS)
            string bMk = gateAgeB <= i_gateWin ? "✓" : "✗"
            string sMk = gateAgeS <= i_gateWin ? "✓" : "✗"
            string gVal = gateLabel + (gateTypeLine ? " · Line" : "") + " · B" + bAgeS + bMk + " S" + sAgeS + sMk + " · win " + str.tostring(i_gateWin)
            string gTip = "Gate ages: bars since each side (Bull/Bear) of the gate was last active, vs the memory window (" + str.tostring(i_gateWin) + "). ✓ = within window — a matching signal would pass. " + (gateTypeLine ? "Line gate: bull side active while close is ABOVE the wired line, bear side while BELOW — so one side sits at 0 whenever price is clear of the line." : "Stream gate: bull = values >= +0.5, bear = values <= -0.5.") + " Direction logic: " + i_gateDir + ". '—' = not active in recent history."
            table.cell(lab, 0, row, "Gate", text_color=i_tblTxt, text_size=txSz, text_halign=text.align_left)
            table.cell(lab, 1, row, gVal, text_color=i_tblTxt, text_size=txSz, text_halign=text.align_left, tooltip=gTip)
            table.merge_cells(lab, 1, row, cols - 1, row)
            row += 1
        // Next row: pre-flight — would a signal confirming at this close record?
        string lStat = sideStatus(canRecord, wantLong, lastFireL, i_cooldown, gatePassL)
        string sStat = sideStatus(canRecord, wantShort, lastFireS, i_cooldown, gatePassS)
        string nextVal = "L " + lStat + "  ·  S " + sStat
        string nextTip = "If a signal confirms at THIS bar's close: ✔ = records · ✂ = gate rejects (feeds the ✂ Reject row) · ⏸n = dedupe cooldown, n bars remaining · ✗off = excluded by the Direction Filter · ⛔ = recording halted (wiring). Evaluation order matches the recording logic exactly: halt → filter → cooldown → gate."
        table.cell(lab, 0, row, "Next", text_color=i_tblTxt, text_size=txSz, text_halign=text.align_left)
        table.cell(lab, 1, row, nextVal, text_color=i_tblTxt, text_size=txSz, text_halign=text.align_left, tooltip=nextTip)
        table.merge_cells(lab, 1, row, cols - 1, row)

// === DEBUG (uncomment to verify source wiring) ===
// plot(sigV, "Debug: Signal Source Value", display=display.data_window)
// plot(regV, "Debug: Regime Source Value", display=display.data_window)
// plot(gateV, "Debug: Gate Source Value", display=display.data_window)
// plot(gateAgeB, "Debug: Gate Bull Age", display=display.data_window)
// plot(longEvt ? 1 : shortEvt ? -1 : 0, "Debug: Derived Event", display=display.data_window)
````
