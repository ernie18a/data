# Stryk: Delta Candles

- url: https://www.tradingview.com/script/cAQ66hSa-Stryk-Delta-Candles/
- type: indicator
- pine_id: PUB;c3721300bbdd4806a7fd61e3ab4587a7
- version: 10.0

## Description

# Stryk: Delta Candles — publication description

---

Stryk: Delta Candles is an on-chart order flow engine. It estimates the buy/sell volume delta of a higher-timeframe candle while you trade a lower one, paints your candles by that delta, and marks the moments when price and aggression stop agreeing — the divergences, flips, and absorption events that tend to show up before a turn does.

Everything renders on the price chart itself: no separate pane, no second chart.

---

## Why delta at all

A candle tells you where price went. It does not tell you who was pushing. An hourly candle can close green while sellers hit the tape the entire hour — price held up by passive bids, not buyer initiative. That disagreement between *effort* (delta) and *result* (price) is some of the most useful context intraday trading offers, and it is invisible on a normal chart. This tool exists to make that one thing readable at a glance.

## How the delta is estimated — read this part

Pine Script has no access to bid/ask or tick aggressor data, so no TradingView indicator can measure true delta. This one does not claim to. Instead it requests lower-timeframe intrabars inside every chart bar and classifies each intrabar's volume by its direction: closed up = buying pressure, closed down = selling pressure (ties resolve against the prior close). Those signed volumes are summed into the higher-timeframe candle you select.

The script picks the intrabar resolution automatically: it solves for the finest resolution your TradingView plan's intrabar allowance can afford while still keeping a workable amount of history (you can override it manually). At the resolutions it typically selects — hundreds of classified intrabars per higher-timeframe candle — the estimate tracks the direction and relative size of real delta well on liquid instruments. It remains an estimate. Where intrabar data is unavailable (plan limits or beyond the intrabar history cap), the script falls back to whole-bar classification and says so in the info box.

## What you see on the chart

**Delta-painted candles.** Every candle — body, wick, border — is colored by the live delta of the higher-timeframe candle it belongs to, on a three-color gradient: bull color for strong positive delta, bear for strong negative, fading through neutral as delta approaches zero. Intensity is scaled against the largest delta in your lookback, so "bright" always means "big for recent conditions." The read that matters: price grinding up while the paint fades toward the bear color is selling into strength, visible before any signal prints.

**Closing delta tags.** When a higher-timeframe candle completes, its final delta prints at that candle's last bar (e.g. "CΔ −16.7K"). Scanning back along these tags gives you the auction's recent story in five seconds: who has been winning each hour, and whether the current move is being paid for.

**Three signal tiers, all evaluated only on completed higher-timeframe candles:**

- **Divergence (⚠, default)** — the candle closed up but delta finished negative, or the inverse. Effort and result disagree. This is the early warning; it is more frequent and lower conviction than the flip. Treat it as "pay attention," not "act."
- **Flip (▼ / ▲)** — delta's sign changed versus the prior candle *and* price finished flat or against the new delta. Positive-to-negative with price still holding up reads as distribution; the inverse reads as accumulation. This is the tool's core signal.
- **Absorption (🛑)** — delta far above the recent average magnitude, with price going nowhere. Outsized aggression met a passive counterparty and lost. The default interpretation follows the standard effort/result read (absorbed buyers = bearish); an input inverts it if your own review of your market says otherwise.

Markers sit above or below the candle by a configurable ATR distance per signal type, so stacked signals stay legible. Every marker, emoji, offset, and size is an input. Alerts fire for all three tiers on confirmed bars only.

**Volume structure.** From the same intrabar data the script builds an estimated volume profile per higher-timeframe candle: the live candle's POC, the previous candle's POC, and a composite POC plus 70% value area over the full lookback window. These print as customizable lines with optional name tags. The composite POC is the market's accepted price over the window — the strongest mean-reversion magnet the tool draws. Price outside the value area is unaccepted: expect either rejection back inside or genuine initiative.

**Rolling anchored VWAP with deviation bands.** A volume-weighted average price computed over exactly the last N higher-timeframe candles (the same N as everything else), with optional ±1/±2/±3 volume-weighted standard deviation bands. By default it draws only across its own window — from the anchor marker to now — so the line always depicts precisely the span the number describes; a toggle restores the full historical trail. Price stretched to the outer bands *while a flip or absorption prints against the move* is the highest-confluence read this indicator produces: extension and opposing order flow agreeing.

**Info box.** Current live delta, previous candle delta, average delta over N, POC prices, value area, exact VWAP, buy/sell volume split with delta as a percent of total, delta at the highs versus the lows of the candle (who finished the auction at the extremes), the largest single intrabar print, and session cumulative delta. Each block toggles independently; a Mobile layout strips it to the core numbers for small screens.

## Repainting and confirmation — stated plainly

- The **current** candle's delta, paint intensity, live POC, and info-box values update as the candle forms. That is the point of a live readout, and it is disclosed here: these values are not final until the higher-timeframe candle closes.
- **Previous delta, average delta, all three signal tiers, the closing tags, and the composite structure use completed higher-timeframe candles only.** Signals never fire intrabar and do not repaint once printed. Alerts are gated to confirmed bars.

## Limitations

- Delta is an intrabar polarity estimate, not exchange bid/ask data. On absorption-heavy bars it will understate true selling or buying pressure — the signal logic is designed around direction and relative magnitude, where the estimate is most reliable.
- Intrabar history is capped by TradingView plan. Beyond the covered range, older candles fall back to whole-bar classification (disclosed in the info box). Seconds-based resolutions require a plan with seconds data.
- The delta timeframe must be equal to or higher than the chart timeframe.
- Designed and tuned on liquid CME index futures at a 5-minute chart with a 60-minute delta timeframe; defaults reflect that. Other instruments and timeframes work but deserve their own tolerance settings — the flat-tolerance tooltip explains how to scale it.

## Settings

Every input carries a full tooltip explaining what it does and why the default is what it is. The ones worth understanding first: the delta timeframe (one structural level above your execution chart), the lookback N (window for the average, composite, and VWAP), and the flat tolerance (how much movement still counts as "flat" when judging a candle — scale it with your delta timeframe).

This indicator provides analysis of volume and price behavior. It does not predict outcomes and nothing here is trade advice.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Stryk: Delta Candles v11 — full on-price delta engine
// Defaults tuned for: 5-min chart · 30-min delta timeframe · CME index futures.
// Delta/profile are ESTIMATED from lower-timeframe bar polarity (disclosed
// design — Pine has no bid/ask data). Prev Δ, Avg Δ, POC prev, composite,
// and all signals use COMPLETED HTF candles only (non-repainting). Current Δ
// accumulates live by design.
// v11: HTF1/HTF2 timeframe + lookback selectors moved into the Delta Engine
//     section. Each HTF's read is now ENTIRELY in the info box — six rows:
//     HTF1 POC, HTF2 POC, HTF1 close (Δ @ price), HTF2 close, HTF1 dynamic
//     bias, HTF2 dynamic bias. HTF1/HTF2 draw nothing on the price chart (the
//     on-chart HTF closing tags were removed — they collided and were
//     unreadable). VWAP/band cross-override also removed (too sticky on high
//     TFs). The main per-candle closing-Δ tag still trails on price.
// v10: HTF1/HTF2 draw NOTHING on price (no VWAP/band/color) — their read lives
//     only in the info-box rows and the stacked closing tags. Closing tags now
//     STACK (current / HTF1 / HTF2). CONSOLIDATION engine: a candle closing
//     inside its prior candle flips its tag prefix CΔ → CCΔ (main/HTF1/HTF2).
// v9: MULTI-HTF BIAS — two independent higher timeframes, each own lookback,
//     each run through the same dynamic bias engine. Session backgrounds
//     removed. Info box moved to second position (after Delta Engine).
// v8: INFO BOX REBUILT — per-row toggles, smart column wrap, mobile mirror.
// v7: DYNAMIC BIAS (recency-weighted, five graded states). ABSORPTION MAGNET.
// v6: exact Ranges vol-participation engine + TICK read (wick-tracked extremes).
// ─────────────────────────────────────────────────────────────────────────────
indicator("Stryk: Delta Candles", "Stryk: ΔC", overlay = true, max_labels_count = 500, max_lines_count = 100, max_polylines_count = 20, max_bars_back = 300)

// ── Inputs ──────────────────────────────────────────────────────────────────
string GRP_M  = "Master Control"
string GRP_E  = "Delta Engine"
string GRP_C  = "Candle Paint"
string GRP_P  = "Profile / POC"
string GRP_V  = "Rolling VWAP"
string GRP_S  = "Signal Logic"
string GRP_SG = "Signal Markers (emoji + ATR offset)"
string GRP_CT = "Closing Delta Tag"
string GRP_X  = "TICK Engine / Vol Osc"
string GRP_T  = "Info Box"
string GRP_R  = "Info Box — Rows"

// MASTER CONTROL — one switch per feature block, declared first so it renders at
// the top of the settings panel. Each master OVERRIDES everything below it: turn
// a master OFF and that entire feature is off no matter how its own toggles are
// set, and turning it back ON restores exactly the sub-settings you had. Nothing
// is rewritten, so this is a clean way to strip the chart down for a screenshot
// or a focused session and then restore your full layout in one click.
mBox = input.bool(true, "Info box", group = GRP_M, inline = "m1",
     tooltip = "Master switches for each feature block. OFF forces that whole feature off regardless of its own toggles further down; ON hands control back to those toggles with your settings intact. Info box = the stats table. Candle paint = delta-colored candles (the chart's own candles stay visible underneath).")
mPaint = input.bool(true, "Candle paint", group = GRP_M, inline = "m1")
mProfile = input.bool(true, "Profile / level lines", group = GRP_M, inline = "m2",
     tooltip = "Profile / level lines = every horizontal level in the Profile / POC section at once — POC live and composite, value area, HTF POC, prev open/close, and the session high/low lines, plus their name tags. Rolling VWAP = the VWAP line, all deviation bands, and the anchor label.")
mVwap = input.bool(true, "Rolling VWAP + bands", group = GRP_M, inline = "m2")
mSignals = input.bool(true, "Signals", group = GRP_M, inline = "m3",
     tooltip = "Signals = the flip, divergence and absorption markers on price. Magnet targets = the dotted absorption revisit lines and their ✓ tags. These are separate so you can keep the magnets running while hiding the markers, or the reverse.")
mMagnet = input.bool(true, "Magnet targets", group = GRP_M, inline = "m3")
mTags = input.bool(true, "Closing delta tags", group = GRP_M, inline = "m4",
     tooltip = "Closing delta tags = the per-candle CΔ / CCΔ trail under price. TICK engine = the NYSE TICK rows AND the breadth star on signals — turning it off removes both, and signals then print unstarred.")
mTick = input.bool(true, "TICK engine + star", group = GRP_M, inline = "m4")
mVosc = input.bool(true, "Volume participation", group = GRP_M, inline = "m5",
     tooltip = "Volume participation = the vol-osc row and its background tint. Alerts = a master kill switch for every alert this script fires, including the deviation-band crosses. With Alerts off, nothing triggers even if you have alerts configured in TradingView — useful when replaying or testing without spamming your phone.")
mAlerts = input.bool(true, "Alerts", group = GRP_M, inline = "m5")

htfTf = input.timeframe("30", "Delta timeframe", group = GRP_E,
     tooltip = "The higher timeframe delta is bucketed into. Should be EQUAL TO or HIGHER than the chart timeframe. Scalping: 15 or 30 keeps the delta story tight to your execution chart. 60 = the balanced hourly auction read. 240 = swing context. Optimal is one structural level above the chart you execute on. With 'Auto-raise' below ON, moving to a higher chart timeframe won't break the script — it lifts this automatically.")
autoRaiseTf = input.bool(true, "Auto-raise timeframes to chart", group = GRP_E,
     tooltip = "Keeps the script working when you jump the chart to a HIGHER timeframe than your delta / HTF1 / HTF2 settings. ON (default): any of the three that would fall below the chart timeframe is automatically lifted to the chart timeframe for that session — flip your 5-min chart to 1-hour with a 30-min delta TF and the delta TF simply becomes 1-hour instead of erroring. Your saved settings are untouched; drop back to 5-min and the 30-min delta TF returns. The info box header shows the timeframe actually in use, so you always know when a raise is active. OFF: the original strict behavior — the script halts with an error telling you to fix the setting yourself.")
useAutoLtf = input.bool(true, "Auto intrabar resolution (optimal)", group = GRP_E,
     tooltip = "Computes the FINEST intrabar resolution your data budget can afford while still covering N HTF candles × the history multiple below. TradingView caps total intrabars by plan (100K on Basic–Premium, 125K Expert, 200K Ultimate), so finer bars = less history: the auto rule finds the accuracy/history optimum. Example — 60-min delta TF, N=20, 3× history, 100K budget → needs 216,000s of coverage → 1S only covers 100,000s (rejected) → 5S covers 500,000s (selected). Seconds resolutions also require a plan with seconds data; if unavailable the script falls back to whole-bar polarity and the info box shows 'fallback'.")
dataBudget = input.string("100K (Basic–Premium)", "Intrabar budget (your TV plan)", group = GRP_E,
     options = ["100K (Basic–Premium)", "125K (Expert)", "200K (Ultimate)"],
     tooltip = "TradingView's total intrabar allowance by plan. Set it to match yours — a bigger budget lets auto pick finer resolutions for the same history coverage.")
histMult = input.float(3.0, "History coverage (× N candles)", minval = 1.0, maxval = 10.0, step = 0.5, group = GRP_E,
     tooltip = "How many multiples of the N-candle window the intrabar data must cover before auto accepts a resolution. 3× means with N=20 hourly candles you get ~60 hours of full-accuracy delta history — the composite, avg, and VWAP are always fed. Lower toward 1.5 to force finer resolution (less history); raise toward 5 for deeper painted history (coarser bars).")
manualLtf = input.timeframe("1", "Manual intrabar resolution", group = GRP_E,
     tooltip = "Used only when Auto is OFF. Finer = more accurate delta but less covered history (budget ÷ intrabars-per-chart-bar = covered chart bars). Must be lower than the chart timeframe.")
lenN = input.int(8, "Lookback N (avg Δ, composite, VWAP)", minval = 1, maxval = 200, group = GRP_E,
     tooltip = "Completed HTF candles in the delta average, the composite volume profile, and the rolling VWAP window. Default 8 on a 30-min delta TF ≈ 4 hours — a current, scalp-friendly regime window. On a 60-min delta TF, 20 ≈ one session + overnight. Below ~5 the average and Bias get jumpy — two candles own the entire read. 40+ turns it into a multi-day regime filter.")
biasMode = input.string("Dynamic", "Bias engine", group = GRP_E, options = ["Dynamic", "Classic"],
     tooltip = "Classic = the sign of the plain N-candle average delta — slow, steady regime read; one large old candle can hold the bias for hours. Dynamic = recency-weighted: the newest completed candles count most, the FORMING candle blends in as it matures, and the readout grades into five states (STRONG BUYERS / BUYERS / MIXED / SELLERS / STRONG SELLERS) with the score shown. Reacts several candles earlier at the cost of more state changes. Flip warnings override both modes.")
biasMixTh = input.float(0.15, "Mixed zone", minval = 0.01, maxval = 1.0, step = 0.05, group = GRP_E, inline = "bt",
     tooltip = "Dynamic Bias dead zone: a score inside ±this (in multiples of the average |Δ|) reads MIXED — the tape is genuinely two-sided. Tighten for a more decisive row; widen for fewer state changes on choppy scalping tape.")
biasStrongTh = input.float(0.5, "Strong", minval = 0.1, maxval = 3.0, step = 0.05, group = GRP_E, inline = "bt",
     tooltip = "Dynamic Bias conviction line: a score beyond ±this (in multiples of the average |Δ|) upgrades the read to STRONG BUYERS / STRONG SELLERS — the recent tape is running well above its own normal one-sidedness.")
h1On = input.bool(true, "HTF1 bias", group = GRP_E, inline = "h1",
     tooltip = "First higher-timeframe bias track. Its delta over the last HTF1-N candles runs through the SAME dynamic bias engine as the main read (recency-weighted, five graded states with score). It appears ONLY in the info box (its bias row — toggle it in Info Box — Rows) and as its stacked closing-delta tag under the candle. HTF1 draws no lines, bands, or color on price — the graded dynamic bias is its whole read.")
h1Tf = input.timeframe("60", "", group = GRP_E, inline = "h1",
     tooltip = "HTF1 timeframe. Pick one structural level above your delta timeframe (e.g. delta 30-min → HTF1 60-min). Must be ≥ the chart timeframe.")
h1N = input.int(8, "HTF1 lookback N", minval = 2, maxval = 200, group = GRP_E,
     tooltip = "Completed HTF1 candles feeding HTF1's dynamic bias score. Fully independent of the main N and of HTF2. 20 on a 60-min HTF1 ≈ one session of higher-timeframe regime. Lower it (10–12) for a faster, more reactive HTF1 bias; raise it (30–40) for a slower structural anchor.")
h2On = input.bool(true, "HTF2 bias", group = GRP_E, inline = "h2",
     tooltip = "Second higher-timeframe bias track — same dynamic bias engine as HTF1, its own timeframe and lookback. Use it for a second, higher structural level (e.g. HTF1 60-min + HTF2 240-min) so the info box shows near / mid / far regime at a glance.")
h2Tf = input.timeframe("120", "", group = GRP_E, inline = "h2",
     tooltip = "HTF2 timeframe. Typically higher than HTF1 for a layered read (e.g. 240 above a 60-min HTF1). Must be ≥ the chart timeframe.")
h2N = input.int(12, "HTF2 lookback N", minval = 2, maxval = 200, group = GRP_E,
     tooltip = "Completed HTF2 candles feeding HTF2's dynamic bias score. Independent of the main N and of HTF1. 10 on a 240-min HTF2 ≈ multiple days of the highest structural regime. Keep it lower than HTF1's N by default — a big timeframe needs fewer candles to describe the same span. Raise for a deeper multi-day anchor.")
slopeLen = input.int(5, "VWAP slope lookback (bars)", minval = 1, maxval = 100, group = GRP_E,
     tooltip = "How many bars back each VWAP-slope % is measured over, per timeframe on its own bars (chart bars for the current read, HTF1 bars for HTF1, HTF2 bars for HTF2). slope% = (raw VWAP now − raw VWAP this-many-bars-ago) ÷ raw VWAP then × 100. Lower (2–3) = twitchy, reacts to the last couple of bars; higher (8–10) = smoother, reads the sustained drift of fair value. Raw on all three timeframes so they're on identical footing. It's a %, not a screen angle — honest across instruments and zoom.")


showTable_i = input.bool(true, "Show info box", group = GRP_T,
     tooltip = "The stats table. Every row is individually toggleable in the Rows section below — run lean (core 3 + Bias) or full desk view; the Mobile layout mirrors exactly the rows you enable.")
tPos = input.string("Bottom Right", "Position", group = GRP_T,
     options = ["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"],
     tooltip = "Any of 9 screen anchors.")
tLayout = input.string("Mobile", "Layout", group = GRP_T, options = ["Vertical","Mobile"],
     tooltip = "Vertical = full desktop labels. Mobile = the SAME rows you have toggled on, with abbreviated labels forced to Tiny size — expand or shrink the phone readout purely by toggling rows below. Both layouts obey the column wrap.")
tWrap = input.int(10, "Mobile: rows per column (0 = off)", minval = 0, maxval = 30, group = GRP_T,
     tooltip = "SMART WRAP — MOBILE LAYOUT ONLY: once a column fills with this many data rows, the next rows start a new column to the right, so a fully loaded phone box stays a compact grid instead of a strip down the screen. 4 = wrap after four rows. 0 = single column. The Vertical layout always renders the classic single tall column regardless of this setting; the header spans the full width when wrapped.")
tSizeIn = input.string("Tiny", "Text size", group = GRP_T, options = ["Tiny","Small","Normal","Large"],
     tooltip = "Text size for the Vertical layout. Mobile layout forces Tiny regardless.")
showHead = input.bool(true, "Show header row", group = GRP_T, inline = "hd",
     tooltip = "The title strip at the top of the box (name + delta TF + intrabar resolution), spanning all columns. Off = data rows only, minimum footprint.")
headTxt = input.string("STRYK Δ", "", group = GRP_T, inline = "hd",
     tooltip = "Header title text.")
tblBgCol = input.color(color.new(#0a0a0e, 12), "Box background", group = GRP_T, inline = "tc1",
     tooltip = "Info box background color (transparency in the picker).")
tblHeadCol = input.color(#00838f, "Header", group = GRP_T, inline = "tc1",
     tooltip = "Header strip background color.")
tblBorderCol = input.color(#2a2a33, "Border", group = GRP_T, inline = "tc2",
     tooltip = "Cell border color.")
tblLabelCol = input.color(#ffffff, "Labels", group = GRP_T, inline = "tc2",
     tooltip = "Metric-label text color. Value colors stay semantic (bull/bear/accent) so red always means selling.")
tblFrameW = input.int(1, "Border width", minval = 0, maxval = 4, group = GRP_T,
     tooltip = "Cell border width. 0 = borderless (flattest look), 1 = default grid, 2+ = heavy frame for stream visibility.")

rCur = input.bool(true, "Current Δ", group = GRP_R, inline = "r1")
rPrev = input.bool(true, "Prev Δ", group = GRP_R, inline = "r1")
rAvg = input.bool(true, "Avg Δ", group = GRP_R, inline = "r1",
     tooltip = "The core delta trio. Current Δ = the FORMING HTF candle's live net delta, updating tick by tick. Prev Δ = the last completed candle's locked final delta. Avg Δ = the plain N-candle average that anchors the Classic bias, the paint scale, and the absorption threshold.")
rPocL = input.bool(false, "POC live", group = GRP_R, inline = "r2")
rPocP = input.bool(false, "POC prev", group = GRP_R, inline = "r2")
rPocC = input.bool(false, "POC (N)", group = GRP_R, inline = "r2",
     tooltip = "Point-of-control prices. POC live = where the forming candle's volume is concentrating right now (updates live). POC prev = the last completed candle's final POC. POC (N) = the composite POC of the whole N-candle window — the market's accepted price and the strongest magnet on the chart. Watch the sequence: POC stepping up behind price = acceptance migrating higher.")
rVa = input.bool(false, "VAH / VAL", group = GRP_R, inline = "r3")
rVwap = input.bool(false, "R-VWAP", group = GRP_R, inline = "r3")
rBuy = input.bool(true, "Buy vol", group = GRP_R, inline = "r3",
     tooltip = "VAH / VAL = the composite 70% value area edges — price outside them is 'unaccepted'. R-VWAP = the exact unsmoothed rolling N-candle VWAP value (the line may be visually smoothed; this number never is). Buy vol = accumulated up-polarity volume inside the forming HTF candle.")
rSell = input.bool(true, "Sell vol", group = GRP_R, inline = "r4")
rDpct = input.bool(true, "Δ %", group = GRP_R, inline = "r4")
rDhl = input.bool(true, "Δ @ hi/lo", group = GRP_R, inline = "r4",
     tooltip = "Sell vol = accumulated down-polarity volume in the forming candle. Δ % = delta as a share of total volume — the imbalance QUALITY read: ±20%+ on an hourly candle is one-sided tape, single digits is a two-sided war regardless of the raw delta. Δ @ hi/lo = delta accumulated in the top third vs bottom third of the forming candle's range — who is active AT the extremes (sellers pressing at the highs is the distribution tell).")
rDhlP = input.bool(false, "Δ @ hi/lo prev", group = GRP_R, inline = "r5")
rMaxP = input.bool(false, "Max print", group = GRP_R, inline = "r5")
rTick = input.bool(true, "TICK", group = GRP_R, inline = "r5",
     tooltip = "Δ @ hi/lo prev = the same top-third/bottom-third read locked from the last completed candle. Max print = the single biggest intrabar delta print of the forming candle with its price — repeated large prints at one price mark a defended level. TICK = the live NYSE TICK reading (cash session only), colored extreme beyond the threshold.")
rTickHL = input.bool(false, "TICK hi/lo", group = GRP_R, inline = "r6")
rVoscR = input.bool(true, "Vol osc", group = GRP_R, inline = "r6")
rCvd = input.bool(true, "CVD", group = GRP_R, inline = "r6",
     tooltip = "TICK hi/lo = today's session TICK extremes, tracked off bar WICKS so spike-and-settle bars register. Vol osc = the 0–100 participation reading with its state. CVD = session cumulative delta, resetting each trading day — the day's running scoreboard of net aggression; read it against price (deep negative CVD with price holding = session-scale absorption).")
rBias = input.bool(true, "Bias", group = GRP_R, inline = "r7",
     tooltip = "The regime verdict row. Dynamic mode grades five states with the score; Classic shows the plain average's sign. A just-completed flip pattern overrides either mode with ⚠ SELL FLIP / ⚠ BUY FLIP for the following candle.")
rHtfSlope = input.bool(true, "HTF Slope", group = GRP_R, inline = "r7b",
     tooltip = "One row of VWAP slope % across all three timeframes — current, HTF1, HTF2 — shown as C▲.. 1▲.. 2▼.. (▲ rising fair value, ▼ falling). Each number is that timeframe's VWAP % change over the slope lookback (set in Delta Engine). The whole row is colored by ALIGNMENT: green when all three rise, red when all fall, amber when they disagree — so the color alone tells you whether your timeframes are in confluence or fighting each other. Sits under CVD, above the bias rows.")
rMagnet = input.bool(true, "Magnet tally", group = GRP_R, inline = "r7c",
     tooltip = "Running tally of absorption magnet targets on the delta timeframe currently in use (including one auto-raised to match the chart). Reads hits / resolved · rate · open — e.g. '14/19 · 74% · 3 open'. RESOLVED means the target was either tagged by price or dropped off the chart past the 'Max targets' cap while still untagged, so targets still waiting are counted separately as 'open' and don't drag the rate down. The tally accumulates over all the chart history the script loads, which is far deeper than the handful of target lines visible, and it restarts whenever the script recalculates — changing timeframe or any setting resets it. Read it as the recent hit frequency of this magnet distance on this timeframe, not a performance record.")
rH1Bias = input.bool(true, "HTF1 bias", group = GRP_R, inline = "r8")
rH2Bias = input.bool(true, "HTF2 bias", group = GRP_R, inline = "r8",
     tooltip = "The two higher-timeframe dynamic-bias rows. Each reads the same five graded states (STRONG BUYERS … STRONG SELLERS with score) computed on that HTF's own delta over its own lookback. HTF timeframes and lookbacks are set in the Delta Engine section.")
rH1Poc = input.bool(false, "HTF1 POC", group = GRP_R, inline = "r9")
rH2Poc = input.bool(false, "HTF2 POC", group = GRP_R, inline = "r9",
     tooltip = "Point-of-control price for each HTF's own N-candle window — the single price where the most volume traded on that timeframe. The big-picture accepted price / strongest magnet: HTF2 (e.g. daily) POC is the level the whole regime auctions around, HTF1 the intermediate one. Computed on the same tick bin size as the main profile; shown only in the box.")
rH1Close = input.bool(false, "HTF1 close Δ/level", group = GRP_R, inline = "r10")
rH2Close = input.bool(false, "HTF2 close Δ/level", group = GRP_R, inline = "r10",
     tooltip = "Each HTF's LAST COMPLETED candle: its closing delta and the price it closed at, shown as 'Δ @ price'. Updates only when that timeframe's candle actually closes (HTF1 on each 1h close, HTF2 on each daily close). The number tells you the net aggression of the most recent higher-timeframe bar and where it settled — all in the box, nothing drawn on price.")

paintOn_i = input.bool(true, "Paint candles by delta", group = GRP_C,
     tooltip = "Colors every candle (body, wick, and border) by the LIVE delta of the HTF candle it belongs to. The money read: price pushing UP while candles fade toward the bear color = selling into strength, before any signal prints. Hide the chart's own candles (eye icon next to the ticker) so only the painted set shows.")
colBull = input.color(#4ade80, "Bull", group = GRP_C, inline = "c",
     tooltip = "Bull = strong positive delta. Neutral = delta near zero (balance). Bear = strong negative delta. Intensity scales with delta size relative to the average |Δ| in the N lookback, fading through neutral as delta flips sign. These three colors also drive signal markers, tags, magnet targets, and info-box value colors — one palette everywhere.")
colNeut = input.color(#3b82f6, "Neutral", group = GRP_C, inline = "c")
colBear = input.color(#e63030, "Bear", group = GRP_C, inline = "c")
paintSens = input.float(1.5, "Paint sensitivity", minval = 0.5, maxval = 5.0, step = 0.25, group = GRP_C,
     tooltip = "How big delta must be to hit FULL color. In Delta size mode: full color at (sensitivity × average |Δ| of the lookback) — an average candle shows ~65% at 1.5. In Delta % mode: full color at (15 ÷ sensitivity)% imbalance — 1.5 = full at 10% Δ%. Lower = vivid sooner, higher = only standouts light up. Normalized vs the AVERAGE, so one monster candle can't mute the palette.")
paintMode = input.string("Delta % (imbalance)", "Paint mode", group = GRP_C, options = ["Delta size", "Delta % (imbalance)"],
     tooltip = "Delta size = intensity from delta magnitude vs recent average — big hours glow, quiet hours stay neutral. Delta % = intensity from delta as a share of total volume — reacts to imbalance QUALITY regardless of size, flips color fastest (meaningful from the first minutes of a candle), and stays vivid even in low-volume hours.")
paintCurve = input.string("Boosted", "Paint curve", group = GRP_C, options = ["Linear", "Boosted"],
     tooltip = "Linear = intensity proportional to delta. Boosted = square-root response: small and mid deltas render noticeably more colorful while extremes still cap at full — the fastest way to make color changes visible without touching thresholds.")
paintFloor = input.float(0.0, "Minimum flip color (0 = off)", minval = 0.0, maxval = 0.8, step = 0.05, group = GRP_C,
     tooltip = "Snap-to-color: once delta clears a small dead zone, the candle shows at least this intensity toward its side. TESTED OFF as default: on real ES delta paths the Boosted curve alone shows a genuine flip within ~2 bars, and adding a floor tripled false wrong-side flashes without flipping any faster. Raise it only if you want maximum snap and accept the head-fake noise.")

lnExtLeft = input.bool(false, "Extend level lines left (back over candles)", group = GRP_P,
     tooltip = "Direction every level line in this section runs from the current bar: POC live and composite, VAH / VAL, HTF1 and HTF2 POC, HTF1 previous open and close, current session high and low, and HTF1 session high and low. OFF (default): lines extend RIGHT, into the empty space ahead of price, leaving the candles unobstructed. ON: lines extend LEFT, back across the candles, so you can see exactly where each level has been tested, held or broken in the bars that already printed. Name tags stay at the right end either way, so the labels remain readable. This does not affect the magnet target lines, which are set in Signal Logic.")
binTicks = input.int(4, "Profile bin size (ticks)", minval = 1, group = GRP_P,
     tooltip = "Price bucket width for the estimated volume profile that feeds POC and value area. 4 ticks = 1 full point on NQ/ES — clean level resolution for hourly candles. Smaller bins = sharper POC but noisier; bigger bins = smoother zones. If the script feels slow on deep history, raising this is the first relief valve.")
showPocLn_i = input.bool(true, "POC lines (live + composite)", group = GRP_P,
     tooltip = "POC live = where the FORMING HTF candle's volume is concentrating (updates live). POC composite = highest-volume price of the last N candles — the market's accepted price and strongest magnet on the chart. Style each below.")
colPocLive = input.color(#ff6a00, "POC live", group = GRP_P, inline = "p1")
stPocLive = input.string("Dashed", "", group = GRP_P, inline = "p1", options = ["Solid","Dashed","Dotted"])
wdPocLive = input.int(1, "", minval = 1, maxval = 5, group = GRP_P, inline = "p1",
     tooltip = "Color / line style / line width for the live-candle POC line.")
colPocComp = input.color(color.new(#ffffff, 30), "POC composite", group = GRP_P, inline = "p2")
stPocComp = input.string("Solid", "", group = GRP_P, inline = "p2", options = ["Solid","Dashed","Dotted"])
wdPocComp = input.int(2, "", minval = 1, maxval = 5, group = GRP_P, inline = "p2",
     tooltip = "Color / line style / line width for the N-candle composite POC line.")
showVaLn_i = input.bool(true, "Value area lines (composite 70%)", group = GRP_P,
     tooltip = "Composite value area high/low — the band holding 70% of the last N candles' volume. Price outside the VA is 'unaccepted': expect rejection back inside (fade) or initiative continuation (breakout). Pairs with flip/absorption signals at these edges.")
colVa = input.color(#c0ca33, "VAH / VAL", group = GRP_P, inline = "p3")
stVa = input.string("Dotted", "", group = GRP_P, inline = "p3", options = ["Solid","Dashed","Dotted"])
wdVa = input.int(2, "", minval = 1, maxval = 5, group = GRP_P, inline = "p3",
     tooltip = "Color / line style / line width for both value area lines.")
showLnTags_i = input.bool(true, "Name tags on lines", group = GRP_P,
     tooltip = "Small labels at the right edge of each level line (POC 20, POC live, VAH, VAL, H1 POC, H2 POC) so styles never need decoding.")
showH1Poc_i = input.bool(true, "HTF1 POC line on chart", group = GRP_P, inline = "hp1",
     tooltip = "Draw HTF1's point-of-control (its N-window highest-volume price) as a level line on the price chart. This is the intermediate-timeframe accepted price / magnet. Toggle, then set color / style / width. The value also shows in the info-box HTF1 POC row.")
colH1Poc = input.color(color.new(#ffffff, 30), "", group = GRP_P, inline = "hp1")
stH1Poc = input.string("Solid", "", group = GRP_P, inline = "hp1", options = ["Solid","Dashed","Dotted"])
wdH1Poc = input.int(2, "", minval = 1, maxval = 5, group = GRP_P, inline = "hp1")
showH2Poc_i = input.bool(false, "HTF2 POC line on chart", group = GRP_P, inline = "hp2",
     tooltip = "Draw HTF2's point-of-control as a level line — the highest-timeframe accepted price, usually the strongest magnet on the chart. Toggle, then set color / style / width. The value also shows in the info-box HTF2 POC row.")
colH2Poc = input.color(color.new(#ffffff, 30), "", group = GRP_P, inline = "hp2")
stH2Poc = input.string("Solid", "", group = GRP_P, inline = "hp2", options = ["Solid","Dashed","Dotted"])
wdH2Poc = input.int(2, "", minval = 1, maxval = 5, group = GRP_P, inline = "hp2")
showH1O_i = input.bool(true, "HTF1 prev open", group = GRP_P, inline = "ho1",
     tooltip = "Draw the PREVIOUS (last completed) HTF1 candle's OPEN as a reference line at the right edge, tagged 'H1 O'. Set its style / width / color on this row. The prior HTF open is a level the current candle is judged against — holding above/below it signals acceptance. Independent of the close toggle.")
colH1O = input.color(#ff6d00, "", group = GRP_P, inline = "ho1")
stH1O = input.string("Solid", "", group = GRP_P, inline = "ho1", options = ["Solid","Dashed","Dotted"])
wdH1O = input.int(1, "", minval = 1, maxval = 5, group = GRP_P, inline = "ho1")
showH1C_i = input.bool(true, "HTF1 prev close", group = GRP_P, inline = "ho1b",
     tooltip = "Draw the previous HTF1 candle's CLOSE as a reference line, tagged 'H1 C'. Set its style / width / color on this row. The prior close is the most-watched HTF reference — reclaim above / rejection below drives the next candle's read. Independent of the open toggle.")
colH1C = input.color(#ff6d00, "", group = GRP_P, inline = "ho1b")
stH1C = input.string("Solid", "", group = GRP_P, inline = "ho1b", options = ["Solid","Dashed","Dotted"])
wdH1C = input.int(1, "", minval = 1, maxval = 5, group = GRP_P, inline = "ho1b")
showCurHi_i = input.bool(true, "Current session high", group = GRP_P, inline = "hl0a",
     tooltip = "Highest high over the current lookback session — the last N candles of the delta timeframe (Lookback N, the window the main composite POC is built on). Tagged 'Sess Hi'. Top of the recent accepted range = overhead resistance / breakout trigger. Set style / width / color on this row. Independent toggle.")
colCurHi = input.color(#26c6da, "", group = GRP_P, inline = "hl0a")
stCurHi = input.string("Dotted", "", group = GRP_P, inline = "hl0a", options = ["Solid","Dashed","Dotted"])
wdCurHi = input.int(2, "", minval = 1, maxval = 5, group = GRP_P, inline = "hl0a")
showCurLo_i = input.bool(true, "Current session low", group = GRP_P, inline = "hl0b",
     tooltip = "Lowest low over the current lookback session (last N delta-timeframe candles), tagged 'Sess Lo'. Bottom of the recent range = support / breakdown trigger. Set style / width / color on this row. Independent toggle.")
colCurLo = input.color(#26c6da, "", group = GRP_P, inline = "hl0b")
stCurLo = input.string("Dotted", "", group = GRP_P, inline = "hl0b", options = ["Solid","Dashed","Dotted"])
wdCurLo = input.int(2, "", minval = 1, maxval = 5, group = GRP_P, inline = "hl0b")
showH1Hi_i = input.bool(true, "HTF1 session high", group = GRP_P, inline = "hl1a",
     tooltip = "Highest high over HTF1's lookback session — the last HTF1-N candles (e.g. the last 20 hours on a 60-min HTF1). Dashed, tagged 'H1 sHi'. The intermediate-timeframe range high. Independent toggle.")
colH1Hi = input.color(#2962ff, "", group = GRP_P, inline = "hl1a")
stH1Hi = input.string("Dotted", "", group = GRP_P, inline = "hl1a", options = ["Solid","Dashed","Dotted"])
wdH1Hi = input.int(2, "", minval = 1, maxval = 5, group = GRP_P, inline = "hl1a")
showH1Lo_i = input.bool(true, "HTF1 session low", group = GRP_P, inline = "hl1b",
     tooltip = "Lowest low over HTF1's lookback session (last HTF1-N candles), dashed, tagged 'H1 sLo'. The intermediate-timeframe range low. Independent toggle.")
colH1Lo = input.color(#2962ff, "", group = GRP_P, inline = "hl1b")
stH1Lo = input.string("Dotted", "", group = GRP_P, inline = "hl1b", options = ["Solid","Dashed","Dotted"])
wdH1Lo = input.int(2, "", minval = 1, maxval = 5, group = GRP_P, inline = "hl1b")

showVwap_i = input.bool(true, "Show rolling anchored VWAP (N)", group = GRP_V,
     tooltip = "Volume-weighted average price over EXACTLY the last N candles of your delta timeframe (N is set in Delta Engine — with N=8 and a 30-min delta TF, this is the 4-hour VWAP). It rolls forward as candles complete; the ⚓ marks where the window starts.")
vwapCol = input.color(#35d0e0, "VWAP color", group = GRP_V,
     tooltip = "Line color for the rolling VWAP; also colors the R-VWAP row in the info box so line and number match.")
vwapSmooth = input.int(5, "Smoothing (EMA length, 1 = off)", minval = 1, maxval = 50, group = GRP_V,
     tooltip = "VISUAL ONLY — this is the 'no stepping' smoothing. The raw window VWAP jumps each time the oldest candle drops out of the N window; this EMA rounds those steps into a curve. 1 = raw stepped line, 5 = default, 10+ = glassier but lags turns slightly. The info box always shows the exact raw value. Bands use the same smoothing so they move together.")
showB1_i = input.bool(true, "±1σ band", group = GRP_V, inline = "b1")
multB1 = input.float(1.0, "×", minval = 0.1, step = 0.1, group = GRP_V, inline = "b1",
     tooltip = "Deviation bands: volume-weighted standard deviation of price around the VWAP, over the SAME N-candle window. ±1σ ≈ normal rotation — fade edges in balance. ±2σ = stretched — reversion zone unless delta confirms initiative. ±3σ = extreme — price out here WITH a delta flip against it is the highest-conviction reversal read this tool produces. Multipliers are editable per band.")
showB2_i = input.bool(true, "±2σ band", group = GRP_V, inline = "b2")
multB2 = input.float(2.0, "×", minval = 0.1, step = 0.1, group = GRP_V, inline = "b2",
     tooltip = "Toggle and multiplier for the second deviation band. Stretched-price zone: reversion is the default expectation out here unless delta confirms initiative drive.")
showB3_i = input.bool(true, "±3σ band", group = GRP_V, inline = "b3",
     tooltip = "Toggle and multiplier for the third deviation band — the extreme zone. Price beyond ±3σ WITH a delta flip against the move is the highest-conviction reversal context this tool produces. Off by default to keep the chart clean.")
multB3 = input.float(3.0, "×", minval = 0.1, step = 0.1, group = GRP_V, inline = "b3")
bandCol = input.color(#2962ff, "Band color", group = GRP_V,
     tooltip = "Applied to all enabled bands. Transparency is part of the color picker.")
bandXOn = input.bool(true, "Deviation-band cross alerts", group = GRP_V,
     tooltip = "Arms the six band-cross alerts — price crossing the ±1σ, ±2σ and ±3σ lines. Each band has its own UP-through and DOWN-through entry in the alert dropdown, twelve in total, so you can alert on just a 2σ breakout or just a 3σ reclaim. Crosses are measured against the SAME smoothed values the bands draw at, so an alert always matches what you see. Only bands you have enabled can fire, and the Alerts master switch overrides all of them. Reading them: crossing UP through an upper band is extension away from fair value; crossing back DOWN through it is rejection. Mirror that for the lower bands.")
vwapWidth = input.int(3, "VWAP line width", minval = 1, maxval = 5, group = GRP_V,
     tooltip = "Line width of the rolling VWAP itself.")
bandWidth = input.int(2, "Band line width", minval = 1, maxval = 5, group = GRP_V,
     tooltip = "Line width of all deviation bands.")
vwapFull = input.bool(true, "Show full VWAP history (backfill)", group = GRP_V,
     tooltip = "OFF (default): the VWAP and bands draw ONLY across the current N-candle window — from the ⚓ anchor to now — exactly the span the number describes. ON: draws the full historical trail across the whole chart (each bar showing what the rolling value was at that time).")
showAnchor_i = input.bool(false, "Anchor label", group = GRP_V, inline = "an",
     tooltip = "The marker pinned to the VWAP value at the first bar of the N-candle window — shows exactly where the rolling window begins. Off = line and bands only.")
anchorSym = input.string("⚓", "", group = GRP_V, inline = "an",
     tooltip = "Anchor marker symbol. Any emoji or text.")
anchorCol = input.color(color.new(#ffe45c, 100), "Anchor color", group = GRP_V, inline = "an2",
     tooltip = "Background color of the anchor label bubble.")
anchorSizeIn = input.string("Huge", "", group = GRP_V, inline = "an2", options = ["Tiny","Small","Normal","Large","Huge"],
     tooltip = "Anchor label size. Large/Huge for stream or screenshot visibility.")

flatTicks = input.int(24, "Flat tolerance (ticks)", minval = 0, group = GRP_S,
     tooltip = "How much price movement still counts as 'flat' when judging an HTF candle. 24 ticks = 6 points on NQ/ES — right for 60-min candles, where a 6-pt hourly close is genuinely 'going nowhere'. SCALE WITH DELTA TF: ~8 for 15-min, ~12–16 for 30-min, ~24 for 60-min, ~60+ for 240-min. Too small = flips/absorption almost never fire; too big = every pullback candle counts as flat.")
showFlip_i = input.bool(true, "Flip signals", group = GRP_S,
     tooltip = "THE regime-change signal: delta sign flipped vs the prior candle AND price finished flat/against the new delta. Positive→negative with price up/flat = distribution (sellers unloading into strength). Inverse = accumulation. Fires once, on candle completion, confirmed only.")
showDiv_i = input.bool(true, "Divergence warnings (pre-flip)", group = GRP_S,
     tooltip = "The early warning: candle CLOSED UP but delta finished negative (or inverse). Effort and result disagree — often the candle BEFORE the flip prints. More frequent and lower conviction than the flip; treat as 'pay attention', not 'act'.")
showAbsorb_i = input.bool(true, "Absorption signals", group = GRP_S,
     tooltip = "Outsized aggression that went nowhere: |Δ| at least [threshold]× the average |Δ| of the last N candles, with price flat. Someone passive absorbed the aggressor at that level.")
absorbMult = input.float(1.5, "Absorption Δ threshold (× avg |Δ|)", minval = 0.5, step = 0.1, group = GRP_S,
     tooltip = "How outsized delta must be vs the N-candle average |Δ| to qualify as absorption. 1.5 = fires a few times per week on NQ 60-min; 2.0+ = only the violent standouts. If ABS is chatty in your first sessions, raise this before doubting the read.")
absorbInv = input.bool(false, "Invert absorption read", group = GRP_S,
     tooltip = "ON (your tested default — magnet framing): treats outsized effort as a REVISIT magnet rather than a pure reversal. OFF (standard order-flow read): huge BUY delta + flat price = buyers absorbed by passive sellers → BEARISH marker above; huge SELL delta + flat = sellers absorbed → BULLISH below. Backtesting on ES 60-min favored the standard read for direction; on faster scalp TFs the difference narrows — this is left ON per your setup, flip it if your own logging disagrees.")
absBubble = input.bool(false, "Color-coded magnet bubbles", group = GRP_S,
     tooltip = "Draws the absorption marker as a color-coded bubble — red above for the bearish side, green below for the bullish side — so the 🧲 carries side color (emojis ignore text color settings). OFF = plain marker like the other signals.")
showAbsTarget_i = input.bool(true, "Magnet target lines", group = GRP_S,
     tooltip = "On every absorption signal, prints a dotted horizontal line at the marker's price level, extending right — the magnet revisit zone. The line freezes with a ✓ the moment price tags it. Targets mark zones price tends to revisit; treat them as context and confluence, not a standalone system.")
absTargetOff = input.float(3.0, "Target ATR distance", minval = 0.0, step = 0.1, group = GRP_S,
     tooltip = "Distance of the magnet target beyond the signal candle's extreme, in chart-TF ATRs. Backtested tag-rate on ES: 0.5 gets tagged most often (immediate revisit zone), larger values stretch the target further and it's hit less often but pays more when it is. Set to your risk/reward preference; 0 pins the target to the raw extreme itself.")
absTargetMax = input.int(20, "Max targets on chart", minval = 1, maxval = 20, group = GRP_S,
     tooltip = "Oldest magnet target lines are removed beyond this count, tagged or not, to keep the chart clean.")

atrLen = input.int(14, "ATR length (marker offsets)", minval = 1, group = GRP_SG,
     tooltip = "ATR is measured on the CHART timeframe (5-min here), so offsets breathe with current volatility. All marker distances below are multiples of this ATR.")
emjFlipS = input.string("▼", "Flip marker — sell", group = GRP_SG, inline = "f",
     tooltip = "Plain glyphs (▼ ▲ ● ◆) obey the color inputs — ▼ prints in your Bear color, ▲ in Bull. Emojis (🔻 🔺 🚨) render in their own fixed colors and IGNORE the color setting — the 🔺 emoji is red even on a buy. Use glyphs for color-true markers, emojis for pictures.")
emjFlipB = input.string("▲", "buy", group = GRP_SG, inline = "f",
     tooltip = "Buy-side flip marker. Prints below the candle low in your Bull color (if a glyph).")
offFlip = input.float(0.4, "Flip ATR distance", minval = 0.0, step = 0.1, group = GRP_SG,
     tooltip = "Distance from the candle extreme in chart-TF ATRs. Defaults stagger the three signal types (DIV 0.6 closest, FLIP 1.0, ABS 1.4 furthest) so they stack cleanly when several fire on the same candle.")
emjDivS = input.string("⚠️", "Divergence emoji — bear", group = GRP_SG, inline = "d",
     tooltip = "Same emoji both sides works — position (above/below) tells you the direction. Alternates: 📉 📈 🌀 👀.")
emjDivB = input.string("⚠️", "bull", group = GRP_SG, inline = "d",
     tooltip = "Bull-side divergence marker. Prints below the candle low.")
offDiv = input.float(0.7, "Divergence ATR distance", minval = 0.0, step = 0.1, group = GRP_SG,
     tooltip = "Distance of the divergence marker from the candle extreme, in chart-TF ATRs. 0.6 keeps it closest to price — the early warning sits nearest the action.")
emjAbsS = input.string("🧲", "Absorption emoji — bear", group = GRP_SG, inline = "a",
     tooltip = "🧲 = the magnet: outsized effort stopped at a level price tends to revisit. Alternates: 🛑 🧊 🧱. Avoid multi-part emojis (skin tones, joined sequences) — they can render as boxes on some systems.")
emjAbsB = input.string("🧲", "bull", group = GRP_SG, inline = "a",
     tooltip = "Bull-side absorption marker. Prints below the candle low (green bubble when magnet bubbles are on).")
offAbs = input.float(3.0, "Absorption ATR distance", minval = 0.0, step = 0.1, group = GRP_SG,
     tooltip = "Distance of the absorption marker from the candle extreme, in chart-TF ATRs. Visual position only — the magnet TARGET distance is set separately in Signal Logic.")
sigSizeIn = input.string("Normal", "Marker size", group = GRP_SG, options = ["Tiny","Small","Normal","Large","Huge"],
     tooltip = "Normal reads at typical zoom on a 5-min chart without covering candles. Huge is for stream/screenshot visibility.")
sigAddTxt = input.bool(false, "Append text to emoji (e.g. Δ SELL)", group = GRP_SG,
     tooltip = "Prints the signal name after the emoji ('🔻 Δ SELL'). Useful while learning the markers; turn off once they're muscle memory.")

showTag_i = input.bool(true, "Show closing delta tag", group = GRP_CT,
     tooltip = "On every main-HTF candle close, prints that candle's final delta under its last chart bar — a running per-candle delta history readable straight off price. With HTF1/HTF2 tags on, three lines stack (current, then HTF1, then HTF2). The prefix is CΔ normally, or the consolidation prefix (CCΔ) when that candle closed inside its prior candle. Shares the 500-label ceiling with signals, so roughly the last few hundred candles stay tagged.")
tagPos = input.string("Below", "Tag placement", group = GRP_CT, options = ["Below","Above","Auto by sign"],
     tooltip = "Below = the stack sits under the candle, HTF1/HTF2 lines descending further down (default, keeps signal emojis above uncluttered on sells). Above = stack above. Auto by sign = the main tag goes by its delta sign; the HTF lines follow the same direction so the three stay grouped.")
tagOff = input.float(0.5, "Tag ATR distance", minval = 0.0, step = 0.1, group = GRP_CT,
     tooltip = "Distance of the tag from the candle extreme, in chart-TF ATRs. 0.4 sits close under the candle inside the signal stack (DIV 0.5 / FLIP 1.0) without touching wicks.")
tagPre = input.string("CΔ ", "Tag prefix", group = GRP_CT,
     tooltip = "Text before the number on a NORMAL (non-consolidation) closing tag. 'CΔ ' = closing delta. When a candle closes inside its prior candle, the consolidation prefix below replaces the leading 'C' (→ 'CCΔ'). Set empty for numbers only.")
tagSizeIn = input.string("Small", "Tag size", group = GRP_CT, options = ["Tiny","Small","Normal","Large"],
     tooltip = "Small keeps ~400 tags on screen without noise; Tiny if you run other label-heavy Stryk tools on the same chart.")
tagUseSign = input.bool(true, "Color tag by delta sign", group = GRP_CT,
     tooltip = "ON: green positive / red negative (matches your paint colors). OFF: the fixed color below.")
tagColFix = input.color(#c8c8d2, "Fixed tag color (if not by sign)", group = GRP_CT,
     tooltip = "Tag color used when 'Color tag by delta sign' is OFF.")
tagPreCons = input.string("C", "Consolidation prefix", group = GRP_CT,
     tooltip = "Prefix used in place of the normal 'C' when a candle closed inside its prior candle's range (an inside bar / consolidation). Default CC → 'CCΔ'. Applies to the main closing tag on price.")

showTick_i = input.bool(true, "TICK engine", group = GRP_X,
     tooltip = "Master switch for the NYSE TICK engine (info-box rows + breadth star). TICK = upticking minus downticking NYSE stocks — market-wide participation behind the index move. A delta flip on ES that prints WHILE TICK is at an extreme carries far more weight than one on a neutral TICK. Extremes are tracked off the TICK bar's HIGH and LOW (the Ranges read) — a spike that settles back before the bar closes still registers. Requires the TICK symbol on your data plan; shows — if unavailable. TICK only prints during the NYSE cash session (9:30–16:00 ET).")
tickSym = input.symbol("USI:TICK", "TICK symbol", group = GRP_X,
     tooltip = "USI:TICK = NYSE. Alternates if your plan carries them: USI:TICKQ (Nasdaq), USI:TICK.US.")
tickExt = input.int(800, "TICK extreme threshold", minval = 200, step = 50, group = GRP_X,
     tooltip = "Beyond ±this, the TICK row colors extreme and the breadth star arms. ±800 is the Ranges default: readings out there mean nearly the whole NYSE is moving one way at once — program buying/selling and often short-term exhaustion. Overnight TICK is blank and signals cannot star.")
showBreadthStar_i = input.bool(true, "Breadth star on signals (★)", group = GRP_X,
     tooltip = "The Ranges Conviction breadth layer, ported to the delta signals: a bearish flip / DIV / absorption earns a ★ when TICK's HIGH hit the +extreme during that HTF candle (the fade fired while the whole market was maximally stretched UP — the stronger exhaustion case). Bullish signals star on the LOW hitting the −extreme. Starred and unstarred signals both print; the star marks the higher-conviction subset.")
showVosc_i = input.bool(true, "Volume participation osc", group = GRP_X,
     tooltip = "The AR/RE volume participation engine, exact: volume EMA compared to its OWN average over the lookback — 50 = average participation, above-average scales 50→100 against the lookback max, below-average scales 50→0 against the lookback min. High readings = the market is paying attention (moves are being paid for), low readings = activity drying up (distrust breakouts, expect chop). Reads volume ACTIVITY while delta reads volume DIRECTION — a delta flip on high participation is a crowd event; the same flip at 15 participation is noise.")
volOscEmaLen = input.int(20, "Volume EMA length", minval = 1, group = GRP_X,
     tooltip = "Smoothing length of the volume EMA that feeds the oscillator.")
volOscLook = input.int(100, "Vol-osc lookback", minval = 10, maxval = 500, group = GRP_X,
     tooltip = "How many bars the volume EMA's average / max / min are measured over for the 0–100 read.")
volOscHigh = input.int(60, "Vol-osc high", minval = 50, maxval = 100, group = GRP_X, inline = "vt",
     tooltip = "Row turns the high color at or above this reading — the crowd is present.")
volOscLow = input.int(40, "low", minval = 0, maxval = 50, group = GRP_X, inline = "vt",
     tooltip = "Row turns the low color at or below this reading — activity drying up. Between the two thresholds the row shows the mid color.")
showVolBg_i = input.bool(true, "Vol-osc background tint", group = GRP_X,
     tooltip = "The Ranges background: tints the whole chart background at participation EXTREMES so regime reads without looking at the box — high color when the crowd shows up, low color when the tape goes dead.")
volBgHigh = input.int(80, "BG tint high", minval = 50, maxval = 100, group = GRP_X, inline = "vb",
     tooltip = "Background tints the high color only at or above this — stricter than the row threshold so the tint marks true extremes.")
volBgLow = input.int(20, "low", minval = 0, maxval = 50, group = GRP_X, inline = "vb",
     tooltip = "Background tints the low color only at or below this — the dead-tape shader.")
volBgTransp = input.int(85, "BG tint transparency", minval = 50, maxval = 98, group = GRP_X,
     tooltip = "Transparency of the extreme tint. Higher = lighter.")
volOscGreen = input.color(#00bcd4, "High", group = GRP_X, inline = "vc",
     tooltip = "High-participation state color, used in the box row and the background tint.")
volOscYellow = input.color(#ffd700, "Mid", group = GRP_X, inline = "vc",
     tooltip = "Mid-participation state color.")
volOscRed = input.color(#9c27b0, "Low", group = GRP_X, inline = "vc",
     tooltip = "Low-participation state color, used in the box row and the dead-tape background tint.")

// ── Master gating ────────────────────────────────────────────────────────────
// Each feature's own toggle is ANDed with its master switch here, and the result
// keeps the original name — so every use further down automatically respects the
// master without any other change. A master OFF wins over its sub-toggles; a
// master ON simply hands control back to them with settings untouched.
bool paintOn         = mPaint   and paintOn_i
bool showPocLn       = mProfile and showPocLn_i
bool showVaLn        = mProfile and showVaLn_i
bool showLnTags      = mProfile and showLnTags_i
bool showH1Poc       = mProfile and showH1Poc_i
bool showH2Poc       = mProfile and showH2Poc_i
bool showH1O         = mProfile and showH1O_i
bool showH1C         = mProfile and showH1C_i
bool showCurHi       = mProfile and showCurHi_i
bool showCurLo       = mProfile and showCurLo_i
bool showH1Hi        = mProfile and showH1Hi_i
bool showH1Lo        = mProfile and showH1Lo_i
bool showVwap        = mVwap    and showVwap_i
bool showB1          = mVwap    and showB1_i
bool showB2          = mVwap    and showB2_i
bool showB3          = mVwap    and showB3_i
bool showAnchor      = mVwap    and showAnchor_i
bool showFlip        = mSignals and showFlip_i
bool showDiv         = mSignals and showDiv_i
bool showAbsorb      = mSignals and showAbsorb_i
bool showAbsTarget   = mMagnet  and showAbsTarget_i
bool showTag         = mTags    and showTag_i
bool showTick        = mTick    and showTick_i
bool showBreadthStar = mTick    and showBreadthStar_i
bool showVosc        = mVosc    and showVosc_i
bool showVolBg       = mVosc    and showVolBg_i
bool showTable       = mBox     and showTable_i

// ── Effective timeframes (auto-raise) / validation ──────────────────────────
// Any of the three timeframes that would sit BELOW the chart timeframe is
// lifted to the chart timeframe when auto-raise is on, so switching the chart
// to a higher TF never breaks the script. Saved inputs are untouched — the lift
// is per-session and reverts the moment you drop back down. These stay `simple`
// strings (ternary of two simple strings), which request.security requires.
int chartSec = timeframe.in_seconds(timeframe.period)
string htfEff = autoRaiseTf and timeframe.in_seconds(htfTf) < chartSec ? timeframe.period : htfTf
string h1Eff  = autoRaiseTf and timeframe.in_seconds(h1Tf)  < chartSec ? timeframe.period : h1Tf
string h2Eff  = autoRaiseTf and timeframe.in_seconds(h2Tf)  < chartSec ? timeframe.period : h2Tf
// true when a lift is actually in effect — surfaced in the info-box header
bool tfRaised = timeframe.in_seconds(htfEff) != timeframe.in_seconds(htfTf)

// with auto-raise OFF, keep the original strict behavior
if barstate.isfirst and not autoRaiseTf and timeframe.in_seconds(htfTf) < chartSec
    runtime.error("Stryk: ΔC — delta timeframe must be equal to or higher than the chart timeframe. Turn on 'Auto-raise timeframes to chart' in Delta Engine to have this handled automatically.")
if barstate.isfirst and not autoRaiseTf and h1On and timeframe.in_seconds(h1Tf) < chartSec
    runtime.error("Stryk: ΔC — HTF1 timeframe must be equal to or higher than the chart timeframe. Turn on 'Auto-raise timeframes to chart' in Delta Engine to have this handled automatically.")
if barstate.isfirst and not autoRaiseTf and h2On and timeframe.in_seconds(h2Tf) < chartSec
    runtime.error("Stryk: ΔC — HTF2 timeframe must be equal to or higher than the chart timeframe. Turn on 'Auto-raise timeframes to chart' in Delta Engine to have this handled automatically.")

// ── Optimal intrabar resolution ──────────────────────────────────────────────
// Finest resolution whose total coverage (budget × ltf seconds) still spans
// lenN HTF candles × histMult, and is below the chart timeframe.
int ibBudget = dataBudget == "200K (Ultimate)" ? 200000 : dataBudget == "125K (Expert)" ? 125000 : 100000
int htfSec = timeframe.in_seconds(htfEff)
// Floor of 2 trading days of coverage: prevents small HTFs from picking 1S with
// unusably thin history. Accuracy saturates near ~60+ intrabars per candle anyway.
float needSec = math.max(lenN * htfSec * histMult, 2.0 * 86400)

ltfAutoSec() =>
    array<int> lad = array.from(1, 5, 10, 15, 30, 60, 300, 900)
    int best = -1
    for s in lad
        if s < chartSec and best == -1 and ibBudget * s >= needSec
            best := s
    if best == -1
        for s in lad
            if s < chartSec
                best := s
    best

tfStrOf(int s) =>
    s == 1 ? "1S" : s == 5 ? "5S" : s == 10 ? "10S" : s == 15 ? "15S" : s == 30 ? "30S" : s == 60 ? "1" : s == 300 ? "5" : "15"

int autoSec = ltfAutoSec()
string ltf = useAutoLtf ? (autoSec > 0 ? tfStrOf(autoSec) : "1") : manualLtf

// ── Intrabar data ────────────────────────────────────────────────────────────
signedVol() =>
    float v = nz(volume)
    float out = 0.0
    if close > open
        out := v
    else if close < open
        out := -v
    else if close > close[1]
        out := v
    else if close < close[1]
        out := -v
    out

array<float> ivS = request.security_lower_tf(syminfo.tickerid, ltf, signedVol())
array<float> ivC = request.security_lower_tf(syminfo.tickerid, ltf, close)
array<float> ivV = request.security_lower_tf(syminfo.tickerid, ltf, nz(volume))

int nIB = math.min(array.size(ivS), math.min(array.size(ivC), array.size(ivV)))
bool haveLtf = nIB > 0

float atrV = ta.atr(atrLen)

// ── Profile helpers ──────────────────────────────────────────────────────────
float binSize = binTicks * syminfo.mintick

addBin(map<int, float> m, int k, float v) =>
    map.put(m, k, (map.contains(m, k) ? map.get(m, k) : 0.0) + v)

pocOf(map<int, float> m) =>
    float best = -1.0
    int bestK = 0
    array<int> ks = map.keys(m)
    for k in ks
        float v = map.get(m, k)
        if v > best
            best := v
            bestK := k
    best > 0 ? bestK * binSize : na

vaOf(map<int, float> m) =>
    array<int> ks = map.keys(m)
    int n = array.size(ks)
    float vah = na
    float val = na
    if n > 0
        array.sort(ks)
        array<float> vs = array.new_float()
        float total = 0.0
        int pocI = 0
        float best = -1.0
        for i = 0 to n - 1
            float v = map.get(m, array.get(ks, i))
            array.push(vs, v)
            total += v
            if v > best
                best := v
                pocI := i
        float acc = array.get(vs, pocI)
        int up = pocI + 1
        int dn = pocI - 1
        while acc < 0.7 * total and (up < n or dn >= 0)
            float vu = up < n ? array.get(vs, up) : -1.0
            float vd = dn >= 0 ? array.get(vs, dn) : -1.0
            if vu >= vd
                acc += vu
                up += 1
            else
                acc += vd
                dn -= 1
        val := array.get(ks, dn + 1) * binSize
        vah := array.get(ks, up - 1) * binSize
    [vah, val]

deltaExtremes(map<int, float> dm, float hi, float lo) =>
    float dHi = 0.0
    float dLo = 0.0
    if not na(hi) and not na(lo) and hi > lo
        float band = (hi - lo) / 3.0
        array<int> ks = map.keys(dm)
        for k in ks
            float p = k * binSize
            float v = map.get(dm, k)
            if p >= hi - band
                dHi += v
            if p <= lo + band
                dLo += v
    [dHi, dLo]

// ── Per-bar aggregation (na-hardened) ───────────────────────────────────────
float barDelta = 0.0
float barBuy   = 0.0
float barSell  = 0.0
float barPv    = 0.0
float barPv2   = 0.0
float barV     = 0.0
float barMaxPr = 0.0
float barMaxPrPx = na

if haveLtf
    for i = 0 to nIB - 1
        float sv = nz(array.get(ivS, i))
        float pc = array.get(ivC, i)
        float vv = nz(array.get(ivV, i))
        barDelta += sv
        if sv > 0
            barBuy += sv
        else
            barSell -= sv
        if not na(pc)
            barPv += pc * vv
            barPv2 += pc * pc * vv
            barV  += vv
        if math.abs(sv) > math.abs(barMaxPr)
            barMaxPr := sv
            barMaxPrPx := pc
else
    float v0 = nz(volume)
    barDelta := close > open ? v0 : close < open ? -v0 : 0.0
    barBuy   := barDelta > 0 ? barDelta : 0.0
    barSell  := barDelta < 0 ? -barDelta : 0.0
    barPv    := hlc3 * v0
    barPv2   := hlc3 * hlc3 * v0
    barV     := v0
    barMaxPr := barDelta
    barMaxPrPx := close

// ── HTF state ────────────────────────────────────────────────────────────────
var map<int, float> candleProf  = map.new<int, float>()
var map<int, float> candleDProf = map.new<int, float>()
var map<int, float> compProf    = map.new<int, float>()
var array<int>   fifoCounts = array.new_int()
var array<int>   fifoBins   = array.new_int()
var array<float> fifoVols   = array.new_float()

var float liveDelta = 0.0,  var float lastDelta = na,  var float prevLastDelta = na
var float liveBuy = 0.0,    var float liveSell = 0.0
var float livePv = 0.0,     var float livePv2 = 0.0,   var float liveV = 0.0
var float liveMaxPr = 0.0,  var float liveMaxPrPx = na
var float prevMaxPr = na,   var float prevMaxPrPx = na
var float prevDHi = na,     var float prevDLo = na
var float htfOpen = na,     var float htfHi = na,  var float htfLo = na
var float lastHi = na,      var float lastLo = na
var float prevHi = na,      var float prevLo = na
var bool  mainInside = false
var float lastPxChg = na,   var float prevPoc = na
var array<float> deltaHist = array.new_float()
var array<float> pvHist  = array.new_float()
var array<float> pv2Hist = array.new_float()
var array<float> vHist   = array.new_float()
var array<int>   startHist = array.new_int()
var int candleStart = 0

bool htfRoll   = timeframe.change(htfEff)
bool completed = false

if htfRoll
    if not na(htfOpen)
        prevLastDelta := lastDelta
        lastDelta := liveDelta
        lastPxChg := close[1] - htfOpen
        prevPoc   := pocOf(candleProf)
        prevMaxPr := liveMaxPr
        prevMaxPrPx := liveMaxPrPx
        prevHi := lastHi
        prevLo := lastLo
        lastHi := htfHi
        lastLo := htfLo
        mainInside := not na(prevHi) and not na(prevLo) and htfHi <= prevHi and htfLo >= prevLo
        [dh, dl] = deltaExtremes(candleDProf, htfHi, htfLo)
        prevDHi := dh
        prevDLo := dl
        array.push(deltaHist, lastDelta)
        if array.size(deltaHist) > lenN
            array.shift(deltaHist)
        array.push(pvHist, livePv)
        array.push(pv2Hist, livePv2)
        array.push(vHist, liveV)
        array.push(startHist, candleStart)
        if array.size(pvHist) > lenN
            array.shift(pvHist)
            array.shift(pv2Hist)
            array.shift(vHist)
            array.shift(startHist)
        array<int> ks = map.keys(candleProf)
        array.push(fifoCounts, array.size(ks))
        for k in ks
            float v = map.get(candleProf, k)
            array.push(fifoBins, k)
            array.push(fifoVols, v)
            addBin(compProf, k, v)
        if array.size(fifoCounts) > lenN
            int cnt = array.shift(fifoCounts)
            if cnt > 0
                for i = 0 to cnt - 1
                    int k2 = array.shift(fifoBins)
                    float v2 = array.shift(fifoVols)
                    float nv = map.get(compProf, k2) - v2
                    if nv <= 0
                        map.remove(compProf, k2)
                    else
                        map.put(compProf, k2, nv)
        completed := true
    liveDelta := 0.0
    liveBuy := 0.0
    liveSell := 0.0
    livePv := 0.0
    livePv2 := 0.0
    liveV := 0.0
    liveMaxPr := 0.0
    liveMaxPrPx := na
    htfOpen := open
    htfHi := na
    htfLo := na
    candleStart := bar_index
    candleProf := map.new<int, float>()
    candleDProf := map.new<int, float>()

liveDelta += nz(barDelta)
liveBuy   += nz(barBuy)
liveSell  += nz(barSell)
livePv    += nz(barPv)
livePv2   += nz(barPv2)
liveV     += nz(barV)
htfHi := na(htfHi) ? high : math.max(htfHi, high)
htfLo := na(htfLo) ? low : math.min(htfLo, low)
if math.abs(nz(barMaxPr)) > math.abs(liveMaxPr)
    liveMaxPr := nz(barMaxPr)
    liveMaxPrPx := barMaxPrPx
if haveLtf
    for i = 0 to nIB - 1
        float pc2 = array.get(ivC, i)
        if not na(pc2)
            int b = math.round(pc2 / binSize)
            addBin(candleProf, b, nz(array.get(ivV, i)))
            addBin(candleDProf, b, nz(array.get(ivS, i)))
else
    int b = math.round(close / binSize)
    addBin(candleProf, b, nz(volume))
    addBin(candleDProf, b, nz(barDelta))

float avgDelta = array.size(deltaHist) > 0 ? array.avg(deltaHist) : na
float livePoc  = pocOf(candleProf)
float compPoc  = pocOf(compProf)

float vwSumPv = array.sum(pvHist) + livePv
float vwSumV  = array.sum(vHist) + liveV
float rollVwap = vwSumV > 0 ? vwSumPv / vwSumV : na
float rollVwapS = ta.ema(rollVwap, vwapSmooth)
// current (chart) VWAP % slope over slopeLen bars — RAW, matches the HTFs
float mainVwPrev = rollVwap[slopeLen]
float mainSlope = not na(rollVwap) and not na(mainVwPrev) and mainVwPrev != 0 ? (rollVwap - mainVwPrev) / mainVwPrev * 100 : na
float vwSumPv2 = array.sum(pv2Hist) + livePv2
float vwVar = vwSumV > 0 ? vwSumPv2 / vwSumV - rollVwap * rollVwap : na
float vwSigma = na(vwVar) ? na : math.sqrt(math.max(vwVar, 0.0))
float vwSigmaS = ta.ema(vwSigma, vwapSmooth)

// ── VWAP deviation-band cross detection ──────────────────────────────────────
// Band levels use the SAME smoothed VWAP and sigma the bands are drawn from, so
// an alert always matches the line on screen. ta.crossover / ta.crossunder are
// called UNCONDITIONALLY (they carry history and must run every bar); the
// toggles gate the RESULT, never the call. Each band gets an up-through and a
// down-through: crossing up through an upper band is extension away from fair
// value, crossing back down through it is rejection — mirrored on the lower side.
float bandU1 = rollVwapS + multB1 * vwSigmaS
float bandD1 = rollVwapS - multB1 * vwSigmaS
float bandU2 = rollVwapS + multB2 * vwSigmaS
float bandD2 = rollVwapS - multB2 * vwSigmaS
float bandU3 = rollVwapS + multB3 * vwSigmaS
float bandD3 = rollVwapS - multB3 * vwSigmaS

bool cU1u = ta.crossover(close, bandU1)
bool cU1d = ta.crossunder(close, bandU1)
bool cU2u = ta.crossover(close, bandU2)
bool cU2d = ta.crossunder(close, bandU2)
bool cU3u = ta.crossover(close, bandU3)
bool cU3d = ta.crossunder(close, bandU3)
bool cD1u = ta.crossover(close, bandD1)
bool cD1d = ta.crossunder(close, bandD1)
bool cD2u = ta.crossover(close, bandD2)
bool cD2d = ta.crossunder(close, bandD2)
bool cD3u = ta.crossover(close, bandD3)
bool cD3d = ta.crossunder(close, bandD3)

bool xU1Up = bandXOn and showB1 and cU1u
bool xU1Dn = bandXOn and showB1 and cU1d
bool xU2Up = bandXOn and showB2 and cU2u
bool xU2Dn = bandXOn and showB2 and cU2d
bool xU3Up = bandXOn and showB3 and cU3u
bool xU3Dn = bandXOn and showB3 and cU3d
bool xD1Dn = bandXOn and showB1 and cD1d
bool xD1Up = bandXOn and showB1 and cD1u
bool xD2Dn = bandXOn and showB2 and cD2d
bool xD2Up = bandXOn and showB2 and cD2u
bool xD3Dn = bandXOn and showB3 and cD3d
bool xD3Up = bandXOn and showB3 and cD3u

int anchorIdx = array.size(startHist) > 0 ? array.get(startHist, 0) : candleStart

// window-only render buffers: one point per bar, pruned to the current N window
var array<chart.point> ptVw  = array.new<chart.point>()
var array<chart.point> ptB1u = array.new<chart.point>()
var array<chart.point> ptB1d = array.new<chart.point>()
var array<chart.point> ptB2u = array.new<chart.point>()
var array<chart.point> ptB2d = array.new<chart.point>()
var array<chart.point> ptB3u = array.new<chart.point>()
var array<chart.point> ptB3d = array.new<chart.point>()
if not na(rollVwapS)
    array.push(ptVw,  chart.point.from_index(bar_index, rollVwapS))
    float sg = nz(vwSigmaS)
    array.push(ptB1u, chart.point.from_index(bar_index, rollVwapS + multB1 * sg))
    array.push(ptB1d, chart.point.from_index(bar_index, rollVwapS - multB1 * sg))
    array.push(ptB2u, chart.point.from_index(bar_index, rollVwapS + multB2 * sg))
    array.push(ptB2d, chart.point.from_index(bar_index, rollVwapS - multB2 * sg))
    array.push(ptB3u, chart.point.from_index(bar_index, rollVwapS + multB3 * sg))
    array.push(ptB3d, chart.point.from_index(bar_index, rollVwapS - multB3 * sg))
prunePts(array<chart.point> a, int minIdx) =>
    while array.size(a) > 0 and (array.first(a).index < minIdx or array.size(a) > 9000)
        array.shift(a)
prunePts(ptVw, anchorIdx),  prunePts(ptB1u, anchorIdx), prunePts(ptB1d, anchorIdx)
prunePts(ptB2u, anchorIdx), prunePts(ptB2d, anchorIdx)
prunePts(ptB3u, anchorIdx), prunePts(ptB3d, anchorIdx)

var float cvd = 0.0
if timeframe.change("D")
    cvd := 0.0
cvd += nz(barDelta)

// ── TICK engine — exact Ranges read ──────────────────────────────────────────
// [high, low, close] of the breadth symbol on the chart timeframe (different
// symbol, same TF → non-repainting on closed bars). Extremes are tracked off
// the WICKS so a spike-and-settle bar registers; the live row shows the close.
// Call is unconditional (never gate a request.*); values gated where used.
// na outside the NYSE cash session — signals cannot star overnight.
[tickHiRaw, tickLoRaw, tickClRaw] = request.security(tickSym, timeframe.period, [high, low, close], lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)
float tickNow = tickClRaw
var float tickHi = na
var float tickLo = na
if timeframe.change("D")
    tickHi := na
    tickLo := na
if not na(tickHiRaw)
    tickHi := na(tickHi) ? tickHiRaw : math.max(tickHi, tickHiRaw)
if not na(tickLoRaw)
    tickLo := na(tickLo) ? tickLoRaw : math.min(tickLo, tickLoRaw)
// per-HTF-candle TICK extremes feed the breadth star (snapshot at the roll,
// like delta) — also wick-tracked, mirroring the Ranges Conviction layer
var float htfTkHi = na
var float htfTkLo = na
var float lastTkHi = na
var float lastTkLo = na
if htfRoll
    lastTkHi := htfTkHi
    lastTkLo := htfTkLo
    htfTkHi := na
    htfTkLo := na
if not na(tickHiRaw)
    htfTkHi := na(htfTkHi) ? tickHiRaw : math.max(htfTkHi, tickHiRaw)
if not na(tickLoRaw)
    htfTkLo := na(htfTkLo) ? tickLoRaw : math.min(htfTkLo, tickLoRaw)

// ── Volume participation oscillator — exact Ranges engine ────────────────────
// 50 is anchored at the volume EMA's own SMA average over the lookback; the
// above-average half scales 50→100 against the lookback max, the below-average
// half scales 50→0 against the lookback min. 50 = average participation, by
// construction. Calls unconditional.
float volEma    = ta.ema(nz(volume), volOscEmaLen)
float volEmaAvg = ta.sma(volEma, volOscLook)
float volEmaMax = ta.highest(volEma, volOscLook)
float volEmaMin = ta.lowest(volEma, volOscLook)
bool  volAbove  = volEma >= volEmaAvg
float volOscA   = volAbove and volEmaMax != volEmaAvg ? 50.0 + (volEma - volEmaAvg) / (volEmaMax - volEmaAvg) * 50.0 : 50.0
float volOscB   = not volAbove and volEmaAvg != volEmaMin ? 50.0 - (volEmaAvg - volEma) / (volEmaAvg - volEmaMin) * 50.0 : 50.0
float volOsc    = math.max(0, math.min(100, volAbove ? volOscA : volOscB))
color voStateCol = volOsc >= volOscHigh ? volOscGreen : volOsc <= volOscLow ? volOscRed : volOscYellow
color volBg = showVosc and showVolBg ? (volOsc >= volBgHigh ? color.new(volOscGreen, volBgTransp) : volOsc <= volBgLow ? color.new(volOscRed, volBgTransp) : na) : na
bgcolor(volBg, title = "Volume Extreme Shader")

// ── Session backgrounds removed in v9 ────────────────────────────────────────

// ── Multi-HTF bias engine ────────────────────────────────────────────────────
// For each HTF: one request.security bundles a UDT carrying the recency-weighted
// dynamic-bias score (same math as the main engine, computed HTF-side over its
// own N), the rolling-N VWAP, and volume-weighted sigma. Price cross of that
// VWAP / ±band overrides the HTF's bias readout. UDT keeps it to ONE tuple
// element per HTF (well within the 127-element / 40-call limits).
type HtfState
    float score      // dynamic-bias score normalized by avg|Δ| (na if unavailable)
    float lastDelta  // last completed HTF candle's delta (for the stacked tag)
    bool  inside     // is the last completed HTF candle inside its prior (consolidation)
    float lastClose  // last completed HTF candle's close (detects that HTF's roll)
    float poc        // point of control over the N window (highest-volume price)
    float slopeVal   // raw VWAP % slope over slopeLen bars
    float lastOpen   // last completed HTF candle's open (prev O/C reference lines)
    float sessHigh   // highest high over the N lookback window (session hi line)
    float sessLow    // lowest low over the N lookback window  (session lo line)

htfBias(simple int n) =>
    // signed volume on THIS (the requested) context, bar polarity
    float sv = close > open ? nz(volume) : close < open ? -nz(volume) : (close > close[1] ? nz(volume) : close < close[1] ? -nz(volume) : 0.0)
    // recency-weighted score over last n completed bars: newest weight n … oldest 1
    float wSum = 0.0
    float wTot = 0.0
    float aAbs = 0.0
    for i = 0 to n - 1
        float d = nz(sv[i])
        float w = n - i
        wSum += d * w
        wTot += w
        aAbs += math.abs(d)
    aAbs := aAbs / n
    float sc = aAbs > 0 ? (wSum / wTot) / aAbs : na
    // POC over the N window: distribute EACH candle's volume across its full
    // high→low range (one share per price bin it spanned), then pick the fullest
    // bin. This matches how an anchored volume profile builds — volume credited
    // where price actually traded, not dumped at the candle midpoint — so the HTF
    // POC lines up with a same-lookback anchored VP instead of drifting on trends.
    // Bins-per-candle is capped so a very wide HTF bar can't blow the loop budget;
    // past the cap the candle's volume is spread evenly over a downsampled set of
    // levels covering the same range (coarser, but keeps the location honest).
    map<int, float> prof = map.new<int, float>()
    for i = 0 to n - 1
        float hi = high[i]
        float lo = low[i]
        float vo = nz(volume[i])
        if not na(hi) and not na(lo) and vo > 0
            int bHi = math.round(hi / binSize)
            int bLo = math.round(lo / binSize)
            int span = math.max(1, bHi - bLo + 1)
            int steps = math.min(span, 200)          // cap bins touched per candle
            float per = vo / steps
            float stepSz = span * 1.0 / steps          // ≥1.0 when downsampling
            for s = 0 to steps - 1
                int b = bLo + math.round(s * stepSz)
                map.put(prof, b, (map.contains(prof, b) ? map.get(prof, b) : 0.0) + per)
    float bestV = 0.0
    int bestB = na
    array<int> pks = map.keys(prof)
    for k in pks
        float v = map.get(prof, k)
        if v > bestV
            bestV := v
            bestB := k
    float pocPx = na(bestB) ? na : bestB * binSize
    // VWAP % slope over slopeLen bars, RAW on this HTF context:
    //   (rawVWAP − rawVWAP[slopeLen]) ÷ rawVWAP[slopeLen] × 100 — the structural
    //   drift of fair value on this timeframe.
    // Session hi/lo = highest high / lowest low over the N-candle lookback window
    //   (the "previous lookback session" range on this timeframe).
    float pv = 0.0
    float vv = 0.0
    float sHi = na
    float sLo = na
    for i = 0 to n - 1
        float px = nz(hlc3[i])
        float vo2 = nz(volume[i])
        pv += px * vo2
        vv += vo2
        sHi := na(sHi) ? high[i] : math.max(sHi, high[i])
        sLo := na(sLo) ? low[i] : math.min(sLo, low[i])
    float vw = vv > 0 ? pv / vv : na
    float vwPrev = vw[slopeLen]
    float slopeM = not na(vw) and not na(vwPrev) and vwPrev != 0 ? (vw - vwPrev) / vwPrev * 100 : na
    // consolidation = last completed candle inside the one before it
    bool ins = high[1] <= high[2] and low[1] >= low[2]
    HtfState.new(sc, nz(sv[1]), ins, close[1], pocPx, slopeM, open[1], sHi, sLo)

// request.security runs UNCONDITIONALLY (never gate the call — gate the result).
// lookahead_off never leaks future data; on realtime bars it returns the forming
// HTF bar's running value (bias updates live within the HTF bar, same disclosed
// behavior as the main live delta). Historical bars are confirmed, non-repainting.
HtfState h1req = request.security(syminfo.tickerid, h1Eff, htfBias(h1N), lookahead = barmerge.lookahead_off)
HtfState h2req = request.security(syminfo.tickerid, h2Eff, htfBias(h2N), lookahead = barmerge.lookahead_off)
// Guard the OBJECT, not just its fields. request.security returning a user
// type hands back a plain `na` object on early bars — before that HTF has
// resolved its first value — and touching any field of a na object is a
// runtime error (RE10041), not a na read. Falling back to a fully-na-filled
// constructor keeps h1s/h2s always a real object, so every downstream
// `h1s.field` access is safe and simply reads na until data arrives.
HtfState h1s = h1On and not na(h1req) ? h1req : HtfState.new(na, na, false, na, na, na, na, na, na)
HtfState h2s = h2On and not na(h2req) ? h2req : HtfState.new(na, na, false, na, na, na, na, na, na)

// current session hi/lo: highest high / lowest low over the last lenN candles of
// the DELTA timeframe (the current lookback window — same span the main
// composite POC is built on). This is the previous-session range for the
// current read, matching how the HTF1 session hi/lo work on their own window.
[curSesHi, curSesLo] = request.security(syminfo.tickerid, htfEff, [ta.highest(high, lenN), ta.lowest(low, lenN)], lookahead = barmerge.lookahead_off)


// HTF1/HTF2 draw NOTHING on the price chart — no VWAP, no bands, no color. Each
// HTF's read is purely its dynamic bias (shown in the info-box rows) plus its
// stacked closing-delta tag. The VWAP/band cross-override engine was removed in
// this build — the graded dynamic bias is the whole HTF read now.





// ── Candle paint (never na — gaps impossible) ────────────────────────────────
// Normalized vs AVERAGE |Δ| of the lookback (not the max) so one outlier candle
// can't mute the palette. Clamped to ±1; sensitivity sets how many multiples of
// the average equal full color.
float avgAbsD = 0.0
if array.size(deltaHist) > 0
    for d in deltaHist
        avgAbsD += math.abs(nz(d))
    avgAbsD /= array.size(deltaHist)
float scaleRef = avgAbsD > 0 ? avgAbsD * paintSens : math.abs(nz(liveDelta))
float totVLive = liveBuy + liveSell
float dPctRaw = totVLive > 0 ? nz(liveDelta) / totVLive : 0.0
float rawN = paintMode == "Delta % (imbalance)" ? math.max(-1.0, math.min(1.0, dPctRaw * paintSens / 0.15)) : scaleRef > 0 ? math.max(-1.0, math.min(1.0, nz(liveDelta) / scaleRef)) : 0.0
float curvedN = paintCurve == "Boosted" ? math.sign(rawN) * math.pow(math.abs(rawN), 0.55) : rawN
float normD = paintFloor > 0 and math.abs(curvedN) > 0.05 ? math.sign(curvedN) * math.max(math.abs(curvedN), paintFloor) : curvedN
color gradCol = normD >= 0 ? color.from_gradient(normD, 0, 1, colNeut, colBull) : color.from_gradient(normD, -1, 0, colBear, colNeut)
color dCol = na(gradCol) ? colNeut : gradCol
barcolor(paintOn ? dCol : na)
plotcandle(open, high, low, close, "Δ Candles", color = paintOn ? dCol : na, wickcolor = paintOn ? dCol : na, bordercolor = paintOn ? dCol : na)

// ── Signals (completed candles only) ─────────────────────────────────────────
float tol = flatTicks * syminfo.mintick
bool pxUpFlat = not na(lastPxChg) and lastPxChg >= -tol
bool pxDnFlat = not na(lastPxChg) and lastPxChg <= tol
bool pxFlat   = not na(lastPxChg) and math.abs(lastPxChg) <= tol
bool pxUp     = not na(lastPxChg) and lastPxChg > tol
bool pxDn     = not na(lastPxChg) and lastPxChg < -tol

bool sellFlip = completed and showFlip and not na(prevLastDelta) and prevLastDelta > 0 and lastDelta < 0 and pxUpFlat
bool buyFlip  = completed and showFlip and not na(prevLastDelta) and prevLastDelta < 0 and lastDelta > 0 and pxDnFlat
bool divSell  = completed and showDiv and pxUp and lastDelta < 0 and not sellFlip
bool divBuy   = completed and showDiv and pxDn and lastDelta > 0 and not buyFlip

bool absBig     = completed and showAbsorb and avgAbsD > 0 and math.abs(lastDelta) >= absorbMult * avgAbsD and pxFlat
bool absorbSell = absBig and (absorbInv ? lastDelta < 0 : lastDelta > 0)
bool absorbBuy  = absBig and (absorbInv ? lastDelta > 0 : lastDelta < 0)

// CONSOLIDATION (the CCΔ tag): the just-completed HTF candle closed INSIDE its
// prior candle's range — an inside bar. Range contraction / coiling; often
// precedes an expansion move, and it's the state the CCΔ tag prefix marks.
bool consolid = completed and mainInside

szSig(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge

fmtD(float x) =>
    na(x) ? "—" : (x > 0 ? "+" : "") + str.tostring(x, format.volume)
fmtP(float x) =>
    na(x) ? "—" : str.tostring(x, format.mintick)
// VWAP-slope token: arrow (▲ rising / ▼ falling / ▶ flat) + abs % for the HTF Slope row
slopeTok(float s) =>
    na(s) ? "" : (s > 0 ? "▲" : s < 0 ? "▼" : "▶") + str.tostring(math.abs(s), "0.00")

// graded dynamic-bias string + color from a normalized score, shared by the
// main read and both HTF rows so the wording is identical everywhere
gradeBias(float sc, float mixTh, float strongTh, color cPos, color cNeg, color cBullSoft, color cBearSoft, color cMix, color cDim) =>
    string s = "—"
    color c = cDim
    if not na(sc)
        if sc >= strongTh
            s := "STRONG BUYERS " + str.tostring(sc, "+#.##")
            c := cPos
        else if sc >= mixTh
            s := "BUYERS " + str.tostring(sc, "+#.##")
            c := cBullSoft
        else if sc <= -strongTh
            s := "STRONG SELLERS " + str.tostring(sc, "#.##")
            c := cNeg
        else if sc <= -mixTh
            s := "SELLERS " + str.tostring(sc, "#.##")
            c := cBearSoft
        else
            s := "MIXED " + str.tostring(sc, "+#.##")
            c := cMix
    [s, c]

styleOf(string s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

mkTag(label old, bool on, float y, string txt, color c) =>
    if not na(old)
        label.delete(old)
    label result = na
    if on and not na(y)
        result := label.new(bar_index + 2, y, txt, style = label.style_none, textcolor = c, size = size.small)
    result


bool starBear = showBreadthStar and showTick and not na(lastTkHi) and lastTkHi >= tickExt
bool starBull = showBreadthStar and showTick and not na(lastTkLo) and lastTkLo <= -tickExt
string sB = starBear ? " ★" : ""
string sU = starBull ? " ★" : ""

// STARRED SIGNALS — a signal that printed while TICK reached its extreme during
// that same HTF candle: the higher-conviction subset. Bearish signals star off
// the TICK HIGH hitting the + extreme (the fade fired while the whole market was
// stretched up); bullish off the LOW hitting the − extreme. Overnight TICK is na,
// so these can only fire during the cash session.
bool starSigBear = starBear and (sellFlip or divSell or absorbSell)
bool starSigBull = starBull and (buyFlip or divBuy or absorbBuy)
bool starSigAny  = starSigBear or starSigBull

if completed and not na(lastHi) and not na(lastLo)
    int cx = bar_index - 1
    string ssz = szSig(sigSizeIn)
    if sellFlip
        label.new(cx, lastHi + atrV * offFlip, emjFlipS + (sigAddTxt ? " Δ SELL" : "") + sB, style = label.style_none, textcolor = colBear, size = ssz)
    if buyFlip
        label.new(cx, lastLo - atrV * offFlip, emjFlipB + (sigAddTxt ? " Δ BUY" : "") + sU, style = label.style_none, textcolor = colBull, size = ssz)
    if divSell
        label.new(cx, lastHi + atrV * offDiv, emjDivS + (sigAddTxt ? " DIV" : "") + sB, style = label.style_none, textcolor = color.new(#ff6a00, 0), size = ssz)
    if divBuy
        label.new(cx, lastLo - atrV * offDiv, emjDivB + (sigAddTxt ? " DIV" : "") + sU, style = label.style_none, textcolor = color.new(#ff6a00, 0), size = ssz)
    if absorbSell
        if absBubble
            label.new(cx, lastHi + atrV * offAbs, emjAbsS + (sigAddTxt ? " ABS" : "") + sB, style = label.style_label_down, color = colBear, textcolor = color.white, size = ssz)
        else
            label.new(cx, lastHi + atrV * offAbs, emjAbsS + (sigAddTxt ? " ABS" : "") + sB, style = label.style_none, textcolor = colBear, size = ssz)
    if absorbBuy
        if absBubble
            label.new(cx, lastLo - atrV * offAbs, emjAbsB + (sigAddTxt ? " ABS" : "") + sU, style = label.style_label_up, color = colBull, textcolor = color.white, size = ssz)
        else
            label.new(cx, lastLo - atrV * offAbs, emjAbsB + (sigAddTxt ? " ABS" : "") + sU, style = label.style_none, textcolor = colBull, size = ssz)

// ── Absorption magnet target lines ───────────────────────────────────────────
// One dotted line per absorption at (extreme ± target ATR distance), extending
// right until price tags it — then it freezes with a ✓. Oldest pruned past cap.
var array<line>  tgLn  = array.new<line>()
var array<float> tgLv  = array.new_float()
var array<int>   tgDir = array.new_int()   // 1 = target above price, -1 = below
var array<int>   tgAct = array.new_int()   // 1 = live/extending, 0 = tagged

// Running magnet tally for the info box. These are plain counters, NOT the arrays
// above — the arrays are capped at 'Max targets on chart' and prune their oldest
// entries, so they can't be counted for history. The counters accumulate over
// every bar the script processes, giving the deepest tally the loaded chart
// history allows on the delta timeframe currently in use. A magnet is RESOLVED
// once it is either tagged or pruned while still open; the rate is hits over
// resolved, so still-open targets don't drag it down. Counters restart whenever
// the script recalculates (timeframe or settings change) — that is inherent.
var int magMade = 0        // magnets created
var int magHit  = 0        // magnets tagged by price
var int magGone = 0        // magnets pruned while still open (never tagged)

if completed and showAbsTarget and not na(lastHi) and not na(lastLo)
    if absorbSell
        float lvS = lastHi + atrV * absTargetOff
        array.push(tgLn, line.new(bar_index - 1, lvS, bar_index, lvS, style = line.style_dotted, color = colBear, width = 1))
        array.push(tgLv, lvS)
        array.push(tgDir, 1)
        array.push(tgAct, 1)
        magMade += 1
    if absorbBuy
        float lvB = lastLo - atrV * absTargetOff
        array.push(tgLn, line.new(bar_index - 1, lvB, bar_index, lvB, style = line.style_dotted, color = colBull, width = 1))
        array.push(tgLv, lvB)
        array.push(tgDir, -1)
        array.push(tgAct, 1)
        magMade += 1
    while array.size(tgLn) > absTargetMax
        // shift the active flag first so a pruned-but-untagged target is counted
        if array.shift(tgAct) == 1
            magGone += 1
        line.delete(array.shift(tgLn))
        array.shift(tgLv)
        array.shift(tgDir)

bool magnetHit = false
if array.size(tgLn) > 0
    for i = 0 to array.size(tgLn) - 1
        if array.get(tgAct, i) == 1
            line lnI = array.get(tgLn, i)
            float lvI = array.get(tgLv, i)
            int dirI = array.get(tgDir, i)
            line.set_x2(lnI, bar_index)
            bool hitI = dirI == 1 ? high >= lvI : low <= lvI
            if hitI
                array.set(tgAct, i, 0)
                magnetHit := true
                magHit += 1
                label.new(bar_index, lvI, "✓", style = label.style_none, textcolor = dirI == 1 ? colBear : colBull, size = size.small)
                if barstate.isconfirmed and mAlerts
                    alert("Stryk ΔC [" + htfEff + "] MAGNET target tagged at " + fmtP(lvI) + ".", alert.freq_once_per_bar)

// ── Stacked closing-delta tags (current / HTF1 / HTF2) ───────────────────────
// Line 1: main HTF closing delta. Line 2: HTF1. Line 3: HTF2. Each prefixed
// CΔ normally, or (consolidation prefix)Δ when that timeframe's last candle
// closed INSIDE its prior candle. Only the main tag draws its own delta line;
// HTF lines stack beneath using the same anchor so the cluster reads top-down.
tagPrefix(bool inside) =>
    (inside ? tagPreCons : "") + tagPre

// v6 forbids [1] directly on a UDT field — copy fields to plain vars first.
// These feed the info-box HTF rows (closing Δ / level). HTF1/HTF2 no longer
// print anything ON the price chart — their whole read is in the info box.
float h1lc = h1s.lastClose
float h2lc = h2s.lastClose
float h1ld = h1s.lastDelta
float h2ld = h2s.lastDelta

// MAIN closing tag only — trails at each main-HTF close (per-candle Δ history).
if completed and showTag and not na(lastHi) and not na(lastLo)
    bool below = tagPos == "Below" or (tagPos == "Auto by sign" and lastDelta < 0)
    float ty = below ? lastLo - atrV * tagOff : lastHi + atrV * tagOff
    color tc = tagUseSign ? (lastDelta >= 0 ? colBull : colBear) : tagColFix
    label.new(bar_index - 1, ty, tagPrefix(mainInside) + fmtD(lastDelta), style = label.style_none, textcolor = tc, size = szSig(tagSizeIn))







if barstate.isconfirmed and mAlerts
    if sellFlip
        alert("Stryk ΔC [" + htfEff + "] Δ FLIP NEGATIVE with price up/flat — selling into strength." + (starBear ? " [TICK ★]" : ""), alert.freq_once_per_bar)
    if buyFlip
        alert("Stryk ΔC [" + htfEff + "] Δ FLIP POSITIVE with price down/flat — buying into weakness." + (starBull ? " [TICK ★]" : ""), alert.freq_once_per_bar)
    if divSell
        alert("Stryk ΔC [" + htfEff + "] DIVERGENCE — candle closed up on negative Δ. Potential flip building.", alert.freq_once_per_bar)
    if divBuy
        alert("Stryk ΔC [" + htfEff + "] DIVERGENCE — candle closed down on positive Δ. Potential flip building.", alert.freq_once_per_bar)
    if absorbSell
        alert("Stryk ΔC [" + htfEff + "] ABSORPTION — outsized buy Δ with no price result." + (starBear ? " [TICK ★]" : ""), alert.freq_once_per_bar)
    if absorbBuy
        alert("Stryk ΔC [" + htfEff + "] ABSORPTION — outsized sell Δ with no price result." + (starBull ? " [TICK ★]" : ""), alert.freq_once_per_bar)
    if consolid
        alert("Stryk ΔC [" + htfEff + "] CONSOLIDATION (CCΔ) — candle closed inside its prior range. Δ " + fmtD(lastDelta) + ". Range contracting.", alert.freq_once_per_bar)
    if starSigBear
        alert("Stryk ΔC [" + htfEff + "] ★ BREADTH STAR on a bearish signal — TICK high reached " + str.tostring(nz(lastTkHi), "#") + " (extreme " + str.tostring(tickExt, "#") + ") during that candle. Δ " + fmtD(lastDelta) + ".", alert.freq_once_per_bar)
    if starSigBull
        alert("Stryk ΔC [" + htfEff + "] ★ BREADTH STAR on a bullish signal — TICK low reached " + str.tostring(nz(lastTkLo), "#") + " (extreme -" + str.tostring(tickExt, "#") + ") during that candle. Δ " + fmtD(lastDelta) + ".", alert.freq_once_per_bar)
    if xU1Up
        alert("Stryk ΔC — price crossed UP through +1σ (" + fmtP(bandU1) + "). Extension above fair value.", alert.freq_once_per_bar)
    if xU1Dn
        alert("Stryk ΔC — price crossed back DOWN through +1σ (" + fmtP(bandU1) + "). Rejection.", alert.freq_once_per_bar)
    if xU2Up
        alert("Stryk ΔC — price crossed UP through +2σ (" + fmtP(bandU2) + "). Stretched.", alert.freq_once_per_bar)
    if xU2Dn
        alert("Stryk ΔC — price crossed back DOWN through +2σ (" + fmtP(bandU2) + "). Rejection from stretched.", alert.freq_once_per_bar)
    if xU3Up
        alert("Stryk ΔC — price crossed UP through +3σ (" + fmtP(bandU3) + "). Extreme.", alert.freq_once_per_bar)
    if xU3Dn
        alert("Stryk ΔC — price crossed back DOWN through +3σ (" + fmtP(bandU3) + "). Rejection from extreme.", alert.freq_once_per_bar)
    if xD1Dn
        alert("Stryk ΔC — price crossed DOWN through -1σ (" + fmtP(bandD1) + "). Extension below fair value.", alert.freq_once_per_bar)
    if xD1Up
        alert("Stryk ΔC — price reclaimed -1σ (" + fmtP(bandD1) + ") from below.", alert.freq_once_per_bar)
    if xD2Dn
        alert("Stryk ΔC — price crossed DOWN through -2σ (" + fmtP(bandD2) + "). Stretched.", alert.freq_once_per_bar)
    if xD2Up
        alert("Stryk ΔC — price reclaimed -2σ (" + fmtP(bandD2) + ") from below.", alert.freq_once_per_bar)
    if xD3Dn
        alert("Stryk ΔC — price crossed DOWN through -3σ (" + fmtP(bandD3) + "). Extreme.", alert.freq_once_per_bar)
    if xD3Up
        alert("Stryk ΔC — price reclaimed -3σ (" + fmtP(bandD3) + ") from below.", alert.freq_once_per_bar)

// ── Alert conditions (individually selectable in TradingView's alert dialog) ──
// The alert() calls above all fire under "Any alert() function call" — one alert
// for everything. These alertcondition() entries add each signal as its OWN
// named item in the alert dropdown, so you can alert on just Δ FLIP, or just
// CONSOLIDATION, without the rest. Messages use TradingView placeholders
// ({{ticker}}, {{interval}}, {{close}}) because alertcondition text must be a
// compile-time constant — the delta timeframe is in the alert() versions above.
alertcondition(sellFlip,   "Δ FLIP — sell (distribution)", "Stryk ΔC {{ticker}} {{interval}} — Δ FLIP NEGATIVE with price up/flat. Selling into strength at {{close}}.")
alertcondition(buyFlip,    "Δ FLIP — buy (accumulation)",  "Stryk ΔC {{ticker}} {{interval}} — Δ FLIP POSITIVE with price down/flat. Buying into weakness at {{close}}.")
alertcondition(sellFlip or buyFlip, "Δ FLIP — either side", "Stryk ΔC {{ticker}} {{interval}} — Δ FLIP: delta reversed against price at {{close}}.")
alertcondition(divSell,    "DIVERGENCE — bearish",         "Stryk ΔC {{ticker}} {{interval}} — DIVERGENCE: candle closed UP on negative Δ at {{close}}. Potential flip building.")
alertcondition(divBuy,     "DIVERGENCE — bullish",         "Stryk ΔC {{ticker}} {{interval}} — DIVERGENCE: candle closed DOWN on positive Δ at {{close}}. Potential flip building.")
alertcondition(divSell or divBuy, "DIVERGENCE — either side", "Stryk ΔC {{ticker}} {{interval}} — DIVERGENCE: effort and result disagree at {{close}}.")
alertcondition(absorbSell, "ABSORPTION — bearish",         "Stryk ΔC {{ticker}} {{interval}} — ABSORPTION: outsized Δ with no price result at {{close}}. Passive size defending.")
alertcondition(absorbBuy,  "ABSORPTION — bullish",         "Stryk ΔC {{ticker}} {{interval}} — ABSORPTION: outsized Δ with no price result at {{close}}. Passive size defending.")
alertcondition(absorbSell or absorbBuy, "ABSORPTION — either side", "Stryk ΔC {{ticker}} {{interval}} — ABSORPTION at {{close}}: outsized effort absorbed.")
alertcondition(consolid,   "CONSOLIDATION (CCΔ)",          "Stryk ΔC {{ticker}} {{interval}} — CONSOLIDATION: candle closed INSIDE its prior range at {{close}}. Range contracting, expansion often follows.")
alertcondition(magnetHit,  "MAGNET target tagged",         "Stryk ΔC {{ticker}} {{interval}} — MAGNET target tagged at {{close}}.")
alertcondition(starSigBear, "★ BREADTH STAR — bearish signal", "Stryk ΔC {{ticker}} {{interval}} — BREADTH STAR on a bearish signal at {{close}}: TICK reached its upper extreme during that candle. Higher-conviction subset.")
alertcondition(starSigBull, "★ BREADTH STAR — bullish signal", "Stryk ΔC {{ticker}} {{interval}} — BREADTH STAR on a bullish signal at {{close}}: TICK reached its lower extreme during that candle. Higher-conviction subset.")
alertcondition(starSigAny,  "★ BREADTH STAR — either side",    "Stryk ΔC {{ticker}} {{interval}} — BREADTH STAR on a signal at {{close}}: TICK at an extreme during that candle. Higher-conviction subset.")
alertcondition(xU1Up, "Band +1σ — cross UP",   "Stryk ΔC {{ticker}} {{interval}} — price crossed UP through the +1σ band at {{close}}. Extension above fair value.")
alertcondition(xU1Dn, "Band +1σ — cross DOWN", "Stryk ΔC {{ticker}} {{interval}} — price crossed back DOWN through the +1σ band at {{close}}. Rejection.")
alertcondition(xU2Up, "Band +2σ — cross UP",   "Stryk ΔC {{ticker}} {{interval}} — price crossed UP through the +2σ band at {{close}}. Stretched from fair value.")
alertcondition(xU2Dn, "Band +2σ — cross DOWN", "Stryk ΔC {{ticker}} {{interval}} — price crossed back DOWN through the +2σ band at {{close}}. Rejection from stretched.")
alertcondition(xU3Up, "Band +3σ — cross UP",   "Stryk ΔC {{ticker}} {{interval}} — price crossed UP through the +3σ band at {{close}}. Extreme extension.")
alertcondition(xU3Dn, "Band +3σ — cross DOWN", "Stryk ΔC {{ticker}} {{interval}} — price crossed back DOWN through the +3σ band at {{close}}. Rejection from extreme.")
alertcondition(xD1Dn, "Band -1σ — cross DOWN", "Stryk ΔC {{ticker}} {{interval}} — price crossed DOWN through the -1σ band at {{close}}. Extension below fair value.")
alertcondition(xD1Up, "Band -1σ — reclaim UP", "Stryk ΔC {{ticker}} {{interval}} — price reclaimed the -1σ band from below at {{close}}.")
alertcondition(xD2Dn, "Band -2σ — cross DOWN", "Stryk ΔC {{ticker}} {{interval}} — price crossed DOWN through the -2σ band at {{close}}. Stretched from fair value.")
alertcondition(xD2Up, "Band -2σ — reclaim UP", "Stryk ΔC {{ticker}} {{interval}} — price reclaimed the -2σ band from below at {{close}}.")
alertcondition(xD3Dn, "Band -3σ — cross DOWN", "Stryk ΔC {{ticker}} {{interval}} — price crossed DOWN through the -3σ band at {{close}}. Extreme extension.")
alertcondition(xD3Up, "Band -3σ — reclaim UP", "Stryk ΔC {{ticker}} {{interval}} — price reclaimed the -3σ band from below at {{close}}.")

// ── VWAP render: full-history plots OR window-only polylines ─────────────────
plot(showVwap and vwapFull ? rollVwapS : na, "Rolling VWAP (N)", color = vwapCol, linewidth = vwapWidth)
plot(showVwap and vwapFull and showB1 ? rollVwapS + multB1 * vwSigmaS : na, "VWAP +1σ", color = bandCol, linewidth = bandWidth)
plot(showVwap and vwapFull and showB1 ? rollVwapS - multB1 * vwSigmaS : na, "VWAP -1σ", color = bandCol, linewidth = bandWidth)
plot(showVwap and vwapFull and showB2 ? rollVwapS + multB2 * vwSigmaS : na, "VWAP +2σ", color = bandCol, linewidth = bandWidth)
plot(showVwap and vwapFull and showB2 ? rollVwapS - multB2 * vwSigmaS : na, "VWAP -2σ", color = bandCol, linewidth = bandWidth)
plot(showVwap and vwapFull and showB3 ? rollVwapS + multB3 * vwSigmaS : na, "VWAP +3σ", color = bandCol, linewidth = bandWidth)
plot(showVwap and vwapFull and showB3 ? rollVwapS - multB3 * vwSigmaS : na, "VWAP -3σ", color = bandCol, linewidth = bandWidth)

var polyline plVw  = na
var polyline plB1u = na
var polyline plB1d = na
var polyline plB2u = na
var polyline plB2d = na
var polyline plB3u = na
var polyline plB3d = na
mkPl(polyline old, array<chart.point> pts, bool on, color c, int w) =>
    if not na(old)
        polyline.delete(old)
    polyline result = na
    if on and array.size(pts) > 1
        result := polyline.new(pts, curved = false, closed = false, xloc = xloc.bar_index, line_color = c, line_width = w)
    result
if barstate.islast
    bool winMode = showVwap and not vwapFull
    plVw  := mkPl(plVw,  ptVw,  winMode, vwapCol, vwapWidth)
    plB1u := mkPl(plB1u, ptB1u, winMode and showB1, bandCol, bandWidth)
    plB1d := mkPl(plB1d, ptB1d, winMode and showB1, bandCol, bandWidth)
    plB2u := mkPl(plB2u, ptB2u, winMode and showB2, bandCol, bandWidth)
    plB2d := mkPl(plB2d, ptB2d, winMode and showB2, bandCol, bandWidth)
    plB3u := mkPl(plB3u, ptB3u, winMode and showB3, bandCol, bandWidth)
    plB3d := mkPl(plB3d, ptB3d, winMode and showB3, bandCol, bandWidth)

var label anchLb = na
if barstate.islast
    if showVwap and showAnchor
        float anchY = array.size(ptVw) > 0 ? array.first(ptVw).price : rollVwapS
        if na(anchLb)
            anchLb := label.new(anchorIdx, anchY, anchorSym, style = label.style_label_up, color = anchorCol, textcolor = #0a0a0e, size = szSig(anchorSizeIn))
        label.set_xy(anchLb, anchorIdx, anchY)
        label.set_text(anchLb, anchorSym)
        label.set_color(anchLb, anchorCol)
        label.set_size(anchLb, szSig(anchorSizeIn))
    else if not na(anchLb)
        label.delete(anchLb)
        anchLb := na

// ── POC / VA lines ───────────────────────────────────────────────────────────
var line lnLive = na
var line lnComp = na
var line lnVah  = na
var line lnVal  = na
var line lnH1Poc = na
var line lnH2Poc = na
var line lnH1O = na
var line lnH1C = na
var line lnCurHi = na
var line lnCurLo = na
var line lnH1Hi = na
var line lnH1Lo = na
if barstate.islast
    if showPocLn
        if na(lnLive)
            lnLive := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stPocLive), color = colPocLive, width = wdPocLive, extend = extend.right)
            lnComp := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stPocComp), color = colPocComp, width = wdPocComp, extend = extend.right)
        if not na(livePoc)
            line.set_xy1(lnLive, bar_index - 1, livePoc)
            line.set_xy2(lnLive, bar_index, livePoc)
        if not na(compPoc)
            line.set_xy1(lnComp, bar_index - 1, compPoc)
            line.set_xy2(lnComp, bar_index, compPoc)
    if showVaLn
        [cVah, cVal] = vaOf(compProf)
        if na(lnVah)
            lnVah := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stVa), color = colVa, width = wdVa, extend = extend.right)
            lnVal := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stVa), color = colVa, width = wdVa, extend = extend.right)
        if not na(cVah)
            line.set_xy1(lnVah, bar_index - 1, cVah)
            line.set_xy2(lnVah, bar_index, cVah)
        if not na(cVal)
            line.set_xy1(lnVal, bar_index - 1, cVal)
            line.set_xy2(lnVal, bar_index, cVal)
    // HTF1 / HTF2 POC level lines (info-box POC rows, mirrored on price)
    if showH1Poc and h1On
        if na(lnH1Poc)
            lnH1Poc := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stH1Poc), color = colH1Poc, width = wdH1Poc, extend = extend.right)
        if not na(h1s.poc)
            line.set_xy1(lnH1Poc, bar_index - 1, h1s.poc)
            line.set_xy2(lnH1Poc, bar_index, h1s.poc)
    if showH2Poc and h2On
        if na(lnH2Poc)
            lnH2Poc := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stH2Poc), color = colH2Poc, width = wdH2Poc, extend = extend.right)
        if not na(h2s.poc)
            line.set_xy1(lnH2Poc, bar_index - 1, h2s.poc)
            line.set_xy2(lnH2Poc, bar_index, h2s.poc)
    // prev HTF open (dashed) + close (solid) reference lines — independent toggles
    if showH1O and h1On
        if na(lnH1O)
            lnH1O := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stH1O), color = colH1O, width = wdH1O, extend = extend.right)
        if not na(h1s.lastOpen)
            line.set_xy1(lnH1O, bar_index - 1, h1s.lastOpen)
            line.set_xy2(lnH1O, bar_index, h1s.lastOpen)
    if showH1C and h1On
        if na(lnH1C)
            lnH1C := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stH1C), color = colH1C, width = wdH1C, extend = extend.right)
        if not na(h1s.lastClose)
            line.set_xy1(lnH1C, bar_index - 1, h1s.lastClose)
            line.set_xy2(lnH1C, bar_index, h1s.lastClose)
    // current prev-candle high / low + HTF1 session high / low reference lines
    if showCurHi
        if na(lnCurHi)
            lnCurHi := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stCurHi), color = colCurHi, width = wdCurHi, extend = extend.right)
        if not na(curSesHi)
            line.set_xy1(lnCurHi, bar_index - 1, curSesHi)
            line.set_xy2(lnCurHi, bar_index, curSesHi)
    if showCurLo
        if na(lnCurLo)
            lnCurLo := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stCurLo), color = colCurLo, width = wdCurLo, extend = extend.right)
        if not na(curSesLo)
            line.set_xy1(lnCurLo, bar_index - 1, curSesLo)
            line.set_xy2(lnCurLo, bar_index, curSesLo)
    if showH1Hi and h1On
        if na(lnH1Hi)
            lnH1Hi := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stH1Hi), color = colH1Hi, width = wdH1Hi, extend = extend.right)
        if not na(h1s.sessHigh)
            line.set_xy1(lnH1Hi, bar_index - 1, h1s.sessHigh)
            line.set_xy2(lnH1Hi, bar_index, h1s.sessHigh)
    if showH1Lo and h1On
        if na(lnH1Lo)
            lnH1Lo := line.new(bar_index - 1, close, bar_index, close, style = styleOf(stH1Lo), color = colH1Lo, width = wdH1Lo, extend = extend.right)
        if not na(h1s.sessLow)
            line.set_xy1(lnH1Lo, bar_index - 1, h1s.sessLow)
            line.set_xy2(lnH1Lo, bar_index, h1s.sessLow)
    // Direction every level line runs from the current bar. Applied with
    // line.set_extend each bar (rather than baked in at line.new) so flipping
    // the toggle takes effect immediately on the existing lines. Magnet target
    // lines are deliberately excluded — they belong to the signal engine.
    string extDir = lnExtLeft ? extend.left : extend.right
    if not na(lnLive)
        line.set_extend(lnLive, extDir)
    if not na(lnComp)
        line.set_extend(lnComp, extDir)
    if not na(lnVah)
        line.set_extend(lnVah, extDir)
    if not na(lnVal)
        line.set_extend(lnVal, extDir)
    if not na(lnH1Poc)
        line.set_extend(lnH1Poc, extDir)
    if not na(lnH2Poc)
        line.set_extend(lnH2Poc, extDir)
    if not na(lnH1O)
        line.set_extend(lnH1O, extDir)
    if not na(lnH1C)
        line.set_extend(lnH1C, extDir)
    if not na(lnCurHi)
        line.set_extend(lnCurHi, extDir)
    if not na(lnCurLo)
        line.set_extend(lnCurLo, extDir)
    if not na(lnH1Hi)
        line.set_extend(lnH1Hi, extDir)
    if not na(lnH1Lo)
        line.set_extend(lnH1Lo, extDir)
    // name tags at the right edge of each level line
    var label tgPocL = na
    var label tgPocC = na
    var label tgVah  = na
    var label tgVal  = na
    var label tgH1P  = na
    var label tgH2P  = na
    var label tgH1O  = na
    var label tgH1C  = na
    var label tgCurHi = na
    var label tgCurLo = na
    var label tgH1Hi = na
    var label tgH1Lo = na
    [tVah2, tVal2] = vaOf(compProf)
    tgPocL := mkTag(tgPocL, showLnTags and showPocLn, livePoc, "POC live", colPocLive)
    tgPocC := mkTag(tgPocC, showLnTags and showPocLn, compPoc, "POC " + str.tostring(lenN), color.new(colPocComp, 0))
    tgVah  := mkTag(tgVah,  showLnTags and showVaLn, tVah2, "VAH", color.new(colVa, 0))
    tgVal  := mkTag(tgVal,  showLnTags and showVaLn, tVal2, "VAL", color.new(colVa, 0))
    tgH1P  := mkTag(tgH1P,  showLnTags and showH1Poc and h1On, h1s.poc, "H1 POC", colH1Poc)
    tgH2P  := mkTag(tgH2P,  showLnTags and showH2Poc and h2On, h2s.poc, "H2 POC", colH2Poc)
    tgH1O  := mkTag(tgH1O,  showLnTags and showH1O and h1On, h1s.lastOpen,  "H1 O", colH1O)
    tgH1C  := mkTag(tgH1C,  showLnTags and showH1C and h1On, h1s.lastClose, "H1 C", colH1C)
    tgCurHi := mkTag(tgCurHi, showLnTags and showCurHi, curSesHi, "Sess Hi", colCurHi)
    tgCurLo := mkTag(tgCurLo, showLnTags and showCurLo, curSesLo, "Sess Lo", colCurLo)
    tgH1Hi  := mkTag(tgH1Hi,  showLnTags and showH1Hi and h1On, h1s.sessHigh, "H1 sHi", colH1Hi)
    tgH1Lo  := mkTag(tgH1Lo,  showLnTags and showH1Lo and h1On, h1s.sessLow,  "H1 sLo", colH1Lo)

// ── Info box ─────────────────────────────────────────────────────────────────
posOf(string s) =>
    s == "Top Left" ? position.top_left : s == "Top Center" ? position.top_center :
     s == "Top Right" ? position.top_right : s == "Middle Left" ? position.middle_left :
     s == "Middle Center" ? position.middle_center : s == "Middle Right" ? position.middle_right :
     s == "Bottom Left" ? position.bottom_left : s == "Bottom Center" ? position.bottom_center :
     position.bottom_right

szOf(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

var table tbl = na

if showTable and barstate.islast
    var array<string> lbl = array.new_string()
    var array<string> val = array.new_string()
    var array<color>  vc  = array.new_color()
    array.clear(lbl), array.clear(val), array.clear(vc)

    bool mobile = tLayout == "Mobile"
    color cPos = colBull
    color cNeg = colBear
    color cDim = color.new(#c8c8d2, 0)
    color cOr  = color.new(#ff6a00, 0)
    color cMix = color.new(#ffd700, 0)

    bool warnS = not na(prevLastDelta) and prevLastDelta > 0 and lastDelta < 0 and pxUpFlat
    bool warnB = not na(prevLastDelta) and prevLastDelta < 0 and lastDelta > 0 and pxDnFlat

    // Dynamic bias: recency-weighted completed deltas (newest weight N, oldest 1)
    // with the FORMING candle blended in proportional to how much of it has
    // elapsed — early minutes get a small vote, a nearly-done candle a full one.
    // Score normalized by avg |Δ| → tiers. Display-only; signals unaffected.
    float biasN = na
    int nH = array.size(deltaHist)
    if biasMode == "Dynamic" and nH > 0 and avgAbsD > 0
        float wSum = 0.0
        float wTot = 0.0
        for i = 0 to nH - 1
            float w = i + 1.0
            wSum += nz(array.get(deltaHist, i)) * w
            wTot += w
        float liveFrac = math.max(0.0, math.min(1.0, (bar_index - candleStart + 1) * 1.0 * chartSec / htfSec))
        float liveWt = liveFrac * (nH + 1.0)
        float score = (wSum + nz(liveDelta) * liveWt) / (wTot + liveWt)
        biasN := score / avgAbsD

    string bias = "—"
    color biasC = cDim
    if warnS
        bias := "⚠ SELL FLIP"
        biasC := cNeg
    else if warnB
        bias := "⚠ BUY FLIP"
        biasC := cPos
    else if biasMode == "Dynamic"
        if na(biasN)
            bias := "—"
            biasC := cDim
        else if biasN >= biasStrongTh
            bias := "STRONG BUYERS " + str.tostring(biasN, "+#.##")
            biasC := cPos
        else if biasN >= biasMixTh
            bias := "BUYERS " + str.tostring(biasN, "+#.##")
            biasC := color.new(colBull, 25)
        else if biasN <= -biasStrongTh
            bias := "STRONG SELLERS " + str.tostring(biasN, "#.##")
            biasC := cNeg
        else if biasN <= -biasMixTh
            bias := "SELLERS " + str.tostring(biasN, "#.##")
            biasC := color.new(colBear, 25)
        else
            bias := "MIXED " + str.tostring(biasN, "+#.##")
            biasC := cMix
    else
        bias := na(avgDelta) ? "—" : avgDelta > 0 ? "BUYERS" : avgDelta < 0 ? "SELLERS" : "NEUTRAL"
        biasC := na(avgDelta) ? cDim : avgDelta > 0 ? cPos : avgDelta < 0 ? cNeg : cDim

    // rows — every one gated by its own toggle; mobile uses the short label
    if rCur
        array.push(lbl, mobile ? "Δ" : "Current Δ (live)"), array.push(val, fmtD(liveDelta)), array.push(vc, liveDelta >= 0 ? cPos : cNeg)
    if rPrev
        array.push(lbl, mobile ? "Prev" : "Prev Δ"), array.push(val, fmtD(lastDelta)), array.push(vc, na(lastDelta) ? cDim : lastDelta >= 0 ? cPos : cNeg)
    if rAvg
        array.push(lbl, mobile ? "Avg" : "Avg Δ (" + str.tostring(lenN) + ")"), array.push(val, fmtD(avgDelta)), array.push(vc, na(avgDelta) ? cDim : avgDelta >= 0 ? cPos : cNeg)
    if rPocL
        array.push(lbl, mobile ? "PoC" : "POC live"), array.push(val, fmtP(livePoc)), array.push(vc, cOr)
    if rPocP
        array.push(lbl, mobile ? "PoC-1" : "POC prev"), array.push(val, fmtP(prevPoc)), array.push(vc, cDim)
    if rPocC
        array.push(lbl, mobile ? "PoC·N" : "POC (" + str.tostring(lenN) + ")"), array.push(val, fmtP(compPoc)), array.push(vc, cDim)
    if rVa
        [tVah, tVal] = vaOf(compProf)
        array.push(lbl, mobile ? "VA" : "VAH / VAL (" + str.tostring(lenN) + ")"), array.push(val, fmtP(tVah) + " / " + fmtP(tVal)), array.push(vc, cDim)
    if rVwap
        array.push(lbl, mobile ? "VW" : "R-VWAP (" + str.tostring(lenN) + ")"), array.push(val, fmtP(rollVwap)), array.push(vc, vwapCol)
    if rBuy
        array.push(lbl, mobile ? "Buy" : "Buy vol"), array.push(val, fmtD(liveBuy)), array.push(vc, cPos)
    if rSell
        array.push(lbl, mobile ? "Sell" : "Sell vol"), array.push(val, fmtD(-liveSell)), array.push(vc, cNeg)
    if rDpct
        float totV = liveBuy + liveSell
        array.push(lbl, "Δ %"), array.push(val, totV > 0 ? str.tostring(liveDelta / totV * 100, "#.#") + "%" : "—"), array.push(vc, liveDelta >= 0 ? cPos : cNeg)
    if rDhl
        [ldh, ldl] = deltaExtremes(candleDProf, htfHi, htfLo)
        array.push(lbl, mobile ? "Δh/l" : "Δ @ hi / lo"), array.push(val, fmtD(ldh) + " / " + fmtD(ldl)), array.push(vc, cDim)
    if rDhlP
        array.push(lbl, mobile ? "Δh/l-1" : "Δ @ hi / lo (prev)"), array.push(val, fmtD(prevDHi) + " / " + fmtD(prevDLo)), array.push(vc, cDim)
    if rMaxP
        array.push(lbl, mobile ? "Max" : "Max print"), array.push(val, na(liveMaxPrPx) ? fmtD(liveMaxPr) : fmtD(liveMaxPr) + " @ " + fmtP(liveMaxPrPx)), array.push(vc, liveMaxPr >= 0 ? cPos : cNeg)
    if rTick and showTick
        color tkC = na(tickNow) ? cDim : tickNow >= tickExt ? cPos : tickNow <= -tickExt ? cNeg : colNeut
        array.push(lbl, mobile ? "TK" : "TICK"), array.push(val, na(tickNow) ? "—" : str.tostring(tickNow, "#")), array.push(vc, tkC)
    if rTickHL and showTick
        array.push(lbl, mobile ? "TK h/l" : "TICK hi / lo"), array.push(val, (na(tickHi) ? "—" : str.tostring(tickHi, "#")) + " / " + (na(tickLo) ? "—" : str.tostring(tickLo, "#"))), array.push(vc, cDim)
    if rVoscR and showVosc
        string voState = volOsc >= volOscHigh ? "HIGH" : volOsc <= volOscLow ? "LOW" : "mid"
        array.push(lbl, mobile ? "VO" : "Vol participation"), array.push(val, str.tostring(volOsc, "#") + "  " + voState), array.push(vc, voStateCol)
    if rCvd
        array.push(lbl, mobile ? "CVD" : "CVD (session)"), array.push(val, fmtD(cvd)), array.push(vc, cvd >= 0 ? cPos : cNeg)
    if rHtfSlope
        // one token per active timeframe: arrow (rise/fall) + abs % over slopeLen
        string sTxt = "C" + slopeTok(mainSlope)
        if h1On
            sTxt := sTxt + "  1" + slopeTok(h1s.slopeVal)
        if h2On
            sTxt := sTxt + "  2" + slopeTok(h2s.slopeVal)
        // confluence color: all up = green, all down = red, disagree = amber
        int up = 0
        int dn = 0
        int act = 0
        if not na(mainSlope)
            act += 1
            up += mainSlope > 0 ? 1 : 0
            dn += mainSlope < 0 ? 1 : 0
        if h1On and not na(h1s.slopeVal)
            act += 1
            up += h1s.slopeVal > 0 ? 1 : 0
            dn += h1s.slopeVal < 0 ? 1 : 0
        if h2On and not na(h2s.slopeVal)
            act += 1
            up += h2s.slopeVal > 0 ? 1 : 0
            dn += h2s.slopeVal < 0 ? 1 : 0
        color slopeCol = act == 0 ? cDim : up == act ? cPos : dn == act ? cNeg : color.new(#ffb300, 0)
        array.push(lbl, mobile ? "Slope" : "HTF Slope"), array.push(val, sTxt), array.push(vc, slopeCol)
    if rMagnet
        int magRes = magHit + magGone
        int magOpen = 0
        if array.size(tgAct) > 0
            for ai = 0 to array.size(tgAct) - 1
                magOpen += array.get(tgAct, ai) == 1 ? 1 : 0
        string magTxt = magRes > 0
             ? str.tostring(magHit) + "/" + str.tostring(magRes) + " · " + str.tostring(math.round(100.0 * magHit / magRes)) + "% · " + str.tostring(magOpen) + " open"
             : (magOpen > 0 ? "0/0 · " + str.tostring(magOpen) + " open" : "—")
        color magCol = magRes < 5 ? cDim : (100.0 * magHit / magRes >= 60 ? cPos : (100.0 * magHit / magRes <= 40 ? cNeg : cMix))
        array.push(lbl, mobile ? "Mag" : "Magnet tally"), array.push(val, magTxt), array.push(vc, magCol)
    if rBias
        array.push(lbl, "Bias"), array.push(val, bias), array.push(vc, biasC)
    if rH1Bias and h1On
        [h1txt, h1c] = gradeBias(h1s.score, biasMixTh, biasStrongTh, cPos, cNeg, color.new(colBull, 25), color.new(colBear, 25), cMix, cDim)
        array.push(lbl, mobile ? "H1" : "HTF1 (" + h1Eff + ")"), array.push(val, h1txt), array.push(vc, h1c)
    if rH2Bias and h2On
        [h2txt, h2c] = gradeBias(h2s.score, biasMixTh, biasStrongTh, cPos, cNeg, color.new(colBull, 25), color.new(colBear, 25), cMix, cDim)
        array.push(lbl, mobile ? "H2" : "HTF2 (" + h2Eff + ")"), array.push(val, h2txt), array.push(vc, h2c)
    if rH1Poc and h1On
        array.push(lbl, mobile ? "H1 PoC" : "HTF1 POC"), array.push(val, fmtP(h1s.poc)), array.push(vc, cDim)
    if rH2Poc and h2On
        array.push(lbl, mobile ? "H2 PoC" : "HTF2 POC"), array.push(val, fmtP(h2s.poc)), array.push(vc, cDim)
    if rH1Close and h1On
        string h1cv = na(h1ld) ? "—" : fmtD(h1ld) + " @ " + fmtP(h1lc)
        array.push(lbl, mobile ? "H1 cl" : "HTF1 close"), array.push(val, h1cv), array.push(vc, na(h1ld) ? cDim : (h1ld >= 0 ? cPos : cNeg))
    if rH2Close and h2On
        string h2cv = na(h2ld) ? "—" : fmtD(h2ld) + " @ " + fmtP(h2lc)
        array.push(lbl, mobile ? "H2 cl" : "HTF2 close"), array.push(val, h2cv), array.push(vc, na(h2ld) ? cDim : (h2ld >= 0 ? cPos : cNeg))

    int n = array.size(lbl)
    if not na(tbl)
        table.delete(tbl)
        tbl := na

    if n > 0
        int headOff = showHead ? 1 : 0
        string tsz = szOf(mobile ? "Tiny" : tSizeIn)
        color lblC = tblLabelCol

        if not mobile
            // VERTICAL — classic single label|value column, exact v7 path
            tbl := table.new(posOf(tPos), 2, n + headOff, bgcolor = tblBgCol, border_width = tblFrameW, border_color = tblBorderCol)
            if showHead
                table.cell(tbl, 0, 0, headTxt, text_color = color.white, text_size = tsz, bgcolor = tblHeadCol)
                table.cell(tbl, 1, 0, htfEff + (tfRaised ? "↑" : "") + " · " + (haveLtf ? ltf + " bars" : "fallback"), text_color = lblC, text_size = tsz, bgcolor = tblHeadCol)
            for i = 0 to n - 1
                table.cell(tbl, 0, headOff + i, array.get(lbl, i), text_color = lblC, text_size = tsz)
                table.cell(tbl, 1, headOff + i, array.get(val, i), text_color = array.get(vc, i), text_size = tsz)
        else
            // MOBILE — smart wrap grid: fill down each column, spill right
            int wrapN = tWrap > 0 ? math.min(tWrap, n) : n
            int nCols = (n + wrapN - 1) / wrapN
            tbl := table.new(posOf(tPos), 2 * nCols, wrapN + headOff, bgcolor = tblBgCol, border_width = tblFrameW, border_color = tblBorderCol)
            if showHead
                table.cell(tbl, 0, 0, headTxt + "   " + htfEff + (tfRaised ? "↑" : "") + " · " + (haveLtf ? ltf + " bars" : "fallback"), text_color = color.white, text_size = tsz, bgcolor = tblHeadCol)
                if nCols > 1
                    table.merge_cells(tbl, 0, 0, 2 * nCols - 1, 0)
            for i = 0 to n - 1
                int cCol = (i / wrapN) * 2
                int cRow = (i % wrapN) + headOff
                table.cell(tbl, cCol, cRow, array.get(lbl, i), text_color = lblC, text_size = tsz)
                table.cell(tbl, cCol + 1, cRow, array.get(val, i), text_color = array.get(vc, i), text_size = tsz)
````
