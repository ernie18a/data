# Hash Dispersion Cone

- url: https://www.tradingview.com/script/GWlbatIi-Hash-Dispersion-Cone/
- type: indicator
- pine_id: PUB;abe824aa23a448e29d4926775e2971a5
- version: 1.0

## Description

[b]## Overview[/b]
The **Hash Dispersion Cone** is a forward-projecting statistical probability envelope built on realized volatility. Anchored to the current bar's close price, it projects where price is statistically expected to trade over the next N bars using log-normal volatility scaling — the same mathematical framework used by professional options desks and quantitative risk managers.

This is not a buy/sell signal generator. It is a **probability map** — a live, continuously recalculating field that shows the market's statistical boundaries given current realized volatility. When volatility is low, the cone is tight. When volatility is expanding, the cone widens in real time.

> *"Know your range before the market shows it to you."*
> — Hash Capital Research

---

[b]## How It Works[/b]
[b]### The Mathematics[/b]
The cone is constructed using the **square-root-of-time rule**, a foundational principle of financial mathematics. At each forward bar `t`, the projected price boundaries are calculated as:

```
Upper_k(t) = AnchorPrice × exp( +k × σ × √t )
Lower_k(t) = AnchorPrice × exp( −k × σ × √t )
```

Where:
- `k` = standard deviation multiplier (1 for 1σ, 2 for 2σ)
- `σ` = realized volatility per bar (selected method)
- `t` = number of bars forward

Using the **log-normal form** is intentional and correct. It keeps the cone asymmetric in price space — the upside boundary is always further from anchor than the downside boundary by an equal percentage amount. This reflects how asset prices actually behave: they cannot go below zero, but can theoretically rise without limit.

[b]### Why the Cone Moves With Price[/b]
The cone repaints every bar because it is always anchored to the **current close**. This is by design. It answers the question: *"Given what volatility is right now, where could price go from here?"* — not where it could have gone from a past bar.

---

[b]## Volatility Methods[/b]
Three realized volatility estimators are available. Each has distinct statistical properties suited to different market conditions.

[b]### Close-to-Close (Default)[/b]
The standard log-return standard deviation:
```
σ = stdev( ln(Close / Close[1]), lookback )
```
Most widely understood. Can underestimate volatility on assets that gap frequently or have large intrabar swings. Best for: **daily timeframes, equities, stable assets**.

### Parkinson (High-Low)
Uses the high-low range instead of close-to-close returns:
```
σ² = mean[ ln(H/L)² ] / (4 × ln2)
```
Approximately **5x more statistically efficient** than Close-to-Close for the same lookback period. Captures intrabar volatility that close-to-close misses. Best for: **crypto, commodities, FX — any asset with large intrabar ranges**.

[b]### Garman-Klass (OHLC)[/b]
The most efficient of the three estimators, using all four price points:
```
σ² = mean[ 0.5×(ln(H/L))² − (2×ln2−1)×(ln(C/O))² ]
```
Most accurate for intraday analysis where the open-to-close gap carries information. Best for: **intraday timeframes (1H, 4H), equities with significant opening gaps**.

---

[b]## Inputs Reference
### Volatility Calculation[/b]

| Input | Default | Description |
|---|---|---|
| Lookback Period | 30 | Bars used to calculate σ. Lower = more reactive. Higher = smoother. |
| Volatility Method | Close-to-Close | Estimator used. See Volatility Methods above. |
| Vol Trend MA Length | 10 | SMA length applied to σ for regime classification. |

**Lookback Tuning Guide:**
- `10–20` bars → reactive, tracks recent volatility closely, cone resizes quickly
- `30` bars → balanced default, smooths out single-spike distortions
- `60–100` bars → slow-moving, regime-level volatility, stable cone width

[b]### Projection[/b]
| Input | Default | Description |
|---|---|---|
| Forward Bars | 15 | How many bars ahead the cone projects. |
| Show 1σ Band | On | Displays ±1σ boundary (~68% probability zone). |
| Show 2σ Band | On | Displays ±2σ boundary (~95% probability zone). |
| Show Midline Anchor | On | Dotted horizontal line at anchor price. |

**Forward Bars Tuning Guide:**
- `5–10` bars → scalping and intraday setups
- `10–20` bars → swing trading (recommended for 4H/Daily)
- `20–50` bars → position trading and options expiry targeting

**Important:** Doubling forward bars does NOT double the projected range. Due to the √t rule, doubling projection bars widens the cone by only ~41%.

[b]## Visual Guide
### Band Colors and Meaning[/b]
```
+2σ ────────────────────────────  Crimson solid (outer extreme, ~95%)
     ░░░░ TEAL FILL (upside risk zone) ░░░░
+1σ  - - - - - - - - - - - - - -  Green dashed (primary upside boundary, ~68%)
     ▓▓▓▓ NAVY FILL (highest-probability core) ▓▓▓▓
MID  ·····························  Grey dotted (anchor / flat scenario)
     ▓▓▓▓ NAVY FILL (highest-probability core) ▓▓▓▓
−1σ  - - - - - - - - - - - - - -  White dashed (primary downside boundary, ~68%)
     ░░░░ MAGENTA FILL (downside risk zone) ░░░░
−2σ ────────────────────────────  Crimson solid (outer extreme, ~95%)
```

[b]### Three-Layer Fill System[/b]
**Navy Core (±1σ interior):** The highest-probability zone. Statistically, ~68% of all future closes are expected to land here. This is where price "wants" to stay in a low-volatility regime.

**Teal Upside Zone (+1σ to +2σ):** The upside risk corridor. Price entering this zone is statistically elevated — possible, but in the outer 14% of expected outcomes.

**Magenta Downside Zone (−1σ to −2σ):** The downside risk corridor. Mirror of the teal zone. Price here signals a statistically significant down-move.

---

[b]## Trading Applications[/b]
### 1. Cone Width as Regime Filter
The most important signal is the **width of the cone itself**, not where price is within it.

- **Tight cone** = low volatility, compressed range → range-bound playbook (fade edges, mean revert to midline)
- **Wide cone** = high volatility, expanded range → momentum playbook (ride direction, wider stops)

Never take a counter-trend trade in a wide, expanding cone. Never chase a breakout in a tight, contracting cone.

[b]### 2. Price at 1σ Edge = Mean Reversion Setup[/b]
When price reaches the projected +1σ or −1σ label price, it has statistically entered the outer 32% of expected outcomes.

**Setup:**
```
Condition 1: Vol Regime is STABLE (─)
Condition 2: Price has reached the ±1σ label level
Condition 3: Rejection candle confirms (wick, doji, engulf)
Entry:        Fade the move back toward midline
Target:       Anchor price (midline)
Stop:         Just beyond the ±2σ label
R:R:          Typically 2:1 to 3:1 depending on cone width
```

[b]### 3. 2σ Touch = Extreme Signal[/b]
A touch of the ±2σ boundary represents a 2-standard-deviation move. Statistically, only ~5% of future closes are expected to exceed this level.

- In a **stable** or **contracting** regime: high-conviction mean reversion entry with defined risk to the 2σ line
- In an **expanding** regime: possible breakout continuation — wait for candle confirmation before fading
- Use the 2σ label price directly as a hard stop level for trades taken inside the cone

[b]### 4. Vol Regime Arrow as Trade Filter[/b]
The regime classification in the dashboard acts as a meta-filter over all other signals.

- **▲ EXPANDING (red):** Do not counter-trend trade. Only take momentum entries in the direction of the move or stay flat. Cone edges are likely to be broken.
- **▼ CONTRACTING (green):** Volatility is compressing. A breakout is loading. Watch for the first expansion candle and trade the direction of the break. This is often the highest R:R setup the cone generates.
- **─ STABLE (white):** Range conditions active. Mean reversion setups at σ edges are highest probability in this state.

[b]### 5. Stop Placement Reference[/b]
The σ label prices at the cone's right edge provide statistically-grounded stop levels:

- **Conservative stop:** Beyond ±2σ label (95% of moves contained)
- **Standard stop:** Beyond ±1σ label (68% of moves contained)
- **Tight stop:** A fixed percentage of the ±1σ distance

This gives every trade a volatility-adjusted stop rather than an arbitrary fixed-pip or percentage stop.

---

[b]## Timeframe Recommendations[/b]
| Timeframe | Lookback | Forward Bars | Vol Method | Best Use |
|---|---|---|---|---|
| 5m / 15m | 20 | 10 | Garman-Klass | Scalping entries |
| 1H | 30 | 15 | Parkinson or GK | Intraday swing |
| 4H | 30 | 15 | Parkinson | Swing trading (default) |
| Daily | 30–50 | 20 | Close-to-Close | Position trading |
| Weekly | 20 | 10 | Close-to-Close | Macro range framing |

---

[b]## Asset Class Notes[/b]
**Crypto (BTC, ETH, SOL, etc.):**
Parkinson is recommended over Close-to-Close due to large intrabar ranges common in 24/7 markets. Cone will be noticeably wider than equities at equivalent timeframes, reflecting structurally higher realized volatility. The 2σ touch setup is especially reliable on 4H BTC during STABLE regimes.

**FX:**
Parkinson works well. Forward Bars of 10–15 on 4H aligns well with typical intraweek swing durations. Cone width is generally tighter than crypto, making σ edge touches more frequent.

**Equities / Indices:**
Garman-Klass recommended for intraday. Close-to-Close is standard for daily and above. Be aware that equity close-to-close can underestimate true vol during earnings season — consider switching to Garman-Klass temporarily.

**Commodities:**
Parkinson preferred. Energy and agricultural commodities have gap and range behavior similar to crypto.

---

## Technical Notes
- The cone redraws on every bar close. It is anchored to the current close and always projects forward from the most recent confirmed price. This is expected behavior — not a repaint flaw.
- Fills are capped at 16 segments per zone to remain within Pine Script's linefill object limit (~50 total). At default 15 forward bars, all fills render completely.
- The annualization factor is automatically adjusted for timeframe: Daily (√252), Weekly (√52), Monthly (√12), and intrabar (derived from `timeframe.in_seconds()`).
- All price labels use comma-formatted output (e.g., `74,161.34`) for readability at large price scales.

---

## Disclaimer
The Hash Dispersion Cone is an educational and analytical tool. Statistical probability does not guarantee any specific price outcome. All trading involves risk. Past statistical behavior does not guarantee future results. This indicator does not constitute financial advice.

---
*Published on TradingView by Hash Capital Research [HCR]*

## Source Code

````pine
//@version=6
indicator("Hash Dispersion Cone", shorttitle="Hash DispCone", overlay=true, max_lines_count=500, max_labels_count=20)

// ═══════════════════════════════════════════════════════════════════
// HASH CAPITAL RESEARCH — DISPERSION CONE  v3.1
// Forward-projects a statistical probability envelope based on
// realized volatility. The cone shows where price is statistically
// expected to trade over the next N bars — not a prediction,
// a probability field. Green = upside boundary. White = downside.
// Red = outer 2σ extremes (~95% of all moves contained within).
// ═══════════════════════════════════════════════════════════════════

// ───── INPUTS — VOLATILITY CALCULATION ─────
grpVol = "Volatility Calculation"

lookback = input.int(30, "Lookback Period", minval=5, maxval=500, group=grpVol,
     tooltip="Number of bars used to calculate realized volatility.\n\n" +
             "TUNING GUIDE:\n" +
             "• 10–20 bars → reactive, tracks recent vol closely, cone resizes fast\n" +
             "• 30 bars    → balanced default, smooths out single-spike distortion\n" +
             "• 60–100     → slow-moving, regime-level vol, cone changes gradually\n\n" +
             "Lower values suit scalping / high-frequency setups. Higher values suit " +
             "swing and position traders who want stable cone width.")

volMethod = input.string("Close-to-Close", "Volatility Method",
     options=["Close-to-Close", "Parkinson (HL)", "Garman-Klass"], group=grpVol,
     tooltip="How realized volatility (σ) is calculated each bar.\n\n" +
             "TUNING GUIDE:\n" +
             "• Close-to-Close → standard log-return stdev. Most widely understood. " +
             "Can underestimate vol on gapping or highly volatile assets.\n" +
             "• Parkinson (HL) → uses High/Low range. ~5x more statistically efficient " +
             "than C-to-C. Better for assets with large intrabar swings (crypto, commodities).\n" +
             "• Garman-Klass   → uses full OHLC bar. Most efficient estimator. " +
             "Best choice for intraday timeframes where open/close gap matters.\n\n" +
             "Recommended: Parkinson for crypto/FX, Garman-Klass for equities intraday.")

volTrendLen = input.int(10, "Vol Trend MA Length", minval=3, maxval=50, group=grpVol,
     tooltip="Length of the simple moving average applied to σ to detect regime shifts.\n\n" +
             "TUNING GUIDE:\n" +
             "• Current σ > MA × 1.02 → Vol EXPANDING  (▲, red in dashboard)\n" +
             "• Current σ < MA × 0.98 → Vol CONTRACTING (▼, green in dashboard)\n" +
             "• Within band            → STABLE          (─, neutral)\n\n" +
             "• 5–8  bars → sensitive, catches early regime changes quickly\n" +
             "• 10   bars → balanced default\n" +
             "• 20+  bars → only flags sustained, confirmed regime shifts\n\n" +
             "Lower values generate more arrows. Higher values filter noise.")

// ───── INPUTS — PROJECTION ─────
grpProj = "Projection"

projBars = input.int(15, "Forward Bars", minval=5, maxval=50, group=grpProj,
     tooltip="How many bars ahead the cone is projected.\n\n" +
             "TUNING GUIDE:\n" +
             "• Match this to your typical trade hold time.\n" +
             "• Scalp / intraday → 5–10 bars\n" +
             "• Swing trade      → 10–20 bars\n" +
             "• Position trade   → 20–50 bars\n\n" +
             "The cone widens with √time (square-root-of-time rule), so doubling " +
             "forward bars does NOT double the range — it widens by ~41%.")

showOneSig = input.bool(true, "Show 1σ Band (~68%)", group=grpProj,
     tooltip="Displays the ±1σ boundary lines.\n\n" +
             "Statistically, ~68% of all future closes should land inside this band " +
             "assuming log-normal returns. Upper boundary is green, lower is white.\n\n" +
             "This is the primary decision band — entries near the boundary edge " +
             "carry higher mean-reversion probability.")

showTwoSig = input.bool(true, "Show 2σ Band (~95%)", group=grpProj,
     tooltip="Displays the ±2σ boundary lines (red).\n\n" +
             "Statistically, ~95% of future closes should land inside this band. " +
             "Touches or breaks beyond 2σ are high-probability mean-reversion signals " +
             "and can also mark the start of a vol-expansion breakout — context matters.\n\n" +
             "Use as a hard stop reference or options strike selection guide.")

showMid = input.bool(true, "Show Midline Anchor", group=grpProj,
     tooltip="Displays a dotted horizontal line at the cone's anchor price (current close).\n\n" +
             "Useful as a visual reference for the neutral/flat scenario. " +
             "Price hugging the midline signals low conviction — neither bull nor bear zone.")

// ───── INPUTS — STYLE ─────
grpStyle = "Style"

colorUpSig = input.color(color.new(#00FF88, 0), "Upper 1σ Line Color", group=grpStyle,
     tooltip="Color of the upper +1σ boundary line.\n" +
             "Default: bright green. Represents the upside probability boundary.")

colorDnSig = input.color(color.new(#FFFFFF, 0), "Lower 1σ Line Color", group=grpStyle,
     tooltip="Color of the lower −1σ boundary line.\n" +
             "Default: white. Represents the downside probability boundary.")

color2Sig = input.color(color.new(#FF4444, 0), "2σ Line Color", group=grpStyle,
     tooltip="Color of both ±2σ outer boundary lines.\n" +
             "Default: crimson. These are the statistical extreme edges of the cone.")

fadeStart = input.int(45, "Inner Fade (%)", minval=0, maxval=95, group=grpStyle,
     tooltip="Transparency of lines at the cone's anchor (leftmost) bar.\n\n" +
             "TUNING GUIDE:\n" +
             "• 0–20  → fully opaque at origin, strong visual presence\n" +
             "• 40–55 → balanced fade, lines fade naturally into the future\n" +
             "• 70+   → very ghost-like from the start\n\n" +
             "Lower = more visible near current price.")

fadeEnd = input.int(80, "Outer Fade (%)", minval=50, maxval=99, group=grpStyle,
     tooltip="Transparency of lines at the cone's far edge (rightmost bar).\n\n" +
             "TUNING GUIDE:\n" +
             "• 60–70 → strong presence all the way to the edge\n" +
             "• 80–85 → natural fade — near-term is prominent, far-term is ghosted\n" +
             "• 90+   → heavily faded at the edge, emphasis on near-term projection\n\n" +
             "Higher fadeEnd makes the cone feel like it dissolves into uncertainty.")

lineWidth = input.int(2, "Line Width", minval=1, maxval=4, group=grpStyle,
     tooltip="Stroke width of all boundary lines in pixels.\n\n" +
             "• 1 → minimal, clean for busy charts\n" +
             "• 2 → default, good balance of presence and clarity\n" +
             "• 3–4 → bold, best for presentations or large monitors")

showLabels = input.bool(true, "Show σ Labels at Edge", group=grpStyle,
     tooltip="Displays price labels at the end of each band showing the σ level and exact projected price.\n\n" +
             "Labels use comma-formatted prices (e.g. 74,161.34) for readability.\n" +
             "Disable if chart is crowded or you are using the cone alongside other edge labels.")

showFill = input.bool(true, "Show Gradient Fill", group=grpStyle,
     tooltip="Enables the three-layer probability fill inside the cone.\n\n" +
             "LAYERS:\n" +
             "• Teal    (+1σ → +2σ) → upside risk zone\n" +
             "• Magenta (−1σ → −2σ) → downside risk zone\n" +
             "• Navy    (±1σ core)   → highest-probability interior\n\n" +
             "TUNING GUIDE:\n" +
             "• Disable on very short projections (5–8 bars) where fill can look cluttered\n" +
             "• Pairs well with dark chart themes — adjust Fill Opacity for light themes")

fillAlpha = input.int(85, "Fill Opacity", minval=60, maxval=97, group=grpStyle,
     tooltip="Controls how transparent the gradient fill zones are.\n\n" +
             "TUNING GUIDE:\n" +
             "• 60–70 → rich, vivid zones — strong visual weight\n" +
             "• 80–88 → subtle, professional — fill is present without dominating\n" +
             "• 90+   → nearly invisible, ghosted reference only\n\n" +
             "Recommended: 82–88 for dark themes, 90–95 for light themes.")

showTable = input.bool(false, "Show Info Table", group=grpStyle,
     tooltip="Displays the institutional dashboard (top-right) showing:\n" +
             "σ per bar, annualized vol + trend direction, expected 1σ range, " +
             "lookback setting, and vol regime classification.\n\n" +
             "Disable if screen space is limited or using multi-pane layouts.")

// ───── VOLATILITY CALCULATION ─────
logRet  = math.log(close / close[1])
sigmaCC = ta.stdev(logRet, lookback)

hlRatio = math.log(high / low)
parkVar = ta.sma(hlRatio * hlRatio, lookback) / (4.0 * math.log(2.0))
sigmaPK = math.sqrt(parkVar)

coRatio = math.log(close / open)
gkTerm  = 0.5 * hlRatio * hlRatio - (2.0 * math.log(2.0) - 1.0) * coRatio * coRatio
gkVar   = ta.sma(gkTerm, lookback)
sigmaGK = gkVar > 0 ? math.sqrt(gkVar) : sigmaCC

sigmaBar = volMethod == "Parkinson (HL)" ? sigmaPK : volMethod == "Garman-Klass" ? sigmaGK : sigmaCC

// ───── VOL TREND ─────
sigmaMa  = ta.sma(sigmaBar, volTrendLen)
volTrend = sigmaBar > sigmaMa * 1.02 ? 1 : sigmaBar < sigmaMa * 0.98 ? -1 : 0

// ───── PRICE FORMATTER ─────
fmtPrice(float v) =>
    str.tostring(v, "#,##0.00")

// ───── ARRAYS ─────
var array<line>     upper2Lines = array.new<line>()
var array<line>     lower2Lines = array.new<line>()
var array<line>     upper1Lines = array.new<line>()
var array<line>     lower1Lines = array.new<line>()
var array<line>     midLines    = array.new<line>()
var array<label>    edgeLabels  = array.new<label>()
var array<linefill> bullFills   = array.new<linefill>()
var array<linefill> bearFills   = array.new<linefill>()
var array<linefill> innerFills  = array.new<linefill>()

// ───── HELPERS ─────
clearLines(array<line> arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            line.delete(array.get(arr, i))
        array.clear(arr)

clearLabels(array<label> arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            label.delete(array.get(arr, i))
        array.clear(arr)

clearFills(array<linefill> arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            linefill.delete(array.get(arr, i))
        array.clear(arr)

fadeAt(int step, int total, int t0, int t1) =>
    frac = total <= 1 ? 0.0 : float(step) / float(math.max(total - 1, 1))
    int(math.round(float(t0) + float(t1 - t0) * frac))

// ───── CONE CONSTRUCTION ─────
if barstate.islast and not na(sigmaBar) and sigmaBar > 0
    clearLines(upper2Lines)
    clearLines(lower2Lines)
    clearLines(upper1Lines)
    clearLines(lower1Lines)
    clearLines(midLines)
    clearLabels(edgeLabels)
    clearFills(bullFills)
    clearFills(bearFills)
    clearFills(innerFills)

    anchorBar   = bar_index
    anchorPrice = close

    for t = 1 to projBars
        tPrev     = t - 1
        sqrtT     = math.sqrt(float(t))
        sqrtTPrev = math.sqrt(float(tPrev))

        u2Now  = anchorPrice * math.exp( 2.0 * sigmaBar * sqrtT)
        l2Now  = anchorPrice * math.exp(-2.0 * sigmaBar * sqrtT)
        u1Now  = anchorPrice * math.exp( 1.0 * sigmaBar * sqrtT)
        l1Now  = anchorPrice * math.exp(-1.0 * sigmaBar * sqrtT)

        u2Prev = anchorPrice * math.exp( 2.0 * sigmaBar * sqrtTPrev)
        l2Prev = anchorPrice * math.exp(-2.0 * sigmaBar * sqrtTPrev)
        u1Prev = anchorPrice * math.exp( 1.0 * sigmaBar * sqrtTPrev)
        l1Prev = anchorPrice * math.exp(-1.0 * sigmaBar * sqrtTPrev)

        segFade = fadeAt(t - 1, projBars, fadeStart, fadeEnd)

        // 2σ outer — crimson solid
        if showTwoSig
            c2 = color.new(color2Sig, math.min(segFade + 8, 99))
            array.push(upper2Lines, line.new(anchorBar + tPrev, u2Prev, anchorBar + t, u2Now, color=c2, width=lineWidth, style=line.style_solid))
            array.push(lower2Lines, line.new(anchorBar + tPrev, l2Prev, anchorBar + t, l2Now, color=c2, width=lineWidth, style=line.style_solid))

        // 1σ inner — green upper dashed, white lower dashed
        if showOneSig
            cUp = color.new(colorUpSig, segFade)
            cDn = color.new(colorDnSig, segFade)
            array.push(upper1Lines, line.new(anchorBar + tPrev, u1Prev, anchorBar + t, u1Now, color=cUp, width=lineWidth, style=line.style_dashed))
            array.push(lower1Lines, line.new(anchorBar + tPrev, l1Prev, anchorBar + t, l1Now, color=cDn, width=lineWidth, style=line.style_dashed))

        // Midline — dotted grey
        if showMid
            cm = color.new(#CCCCCC, math.min(segFade + 25, 99))
            array.push(midLines, line.new(anchorBar + tPrev, anchorPrice, anchorBar + t, anchorPrice, color=cm, width=1, style=line.style_dotted))

    // ── Three-layer gradient fill ──
    if showFill and showTwoSig and showOneSig
        nFills = math.min(math.min(array.size(upper2Lines), array.size(upper1Lines)), 16)
        if nFills > 0
            for i = 0 to nFills - 1
                array.push(bullFills,  linefill.new(array.get(upper2Lines, i), array.get(upper1Lines, i), color=color.new(#00E5FF, fillAlpha)))
                array.push(bearFills,  linefill.new(array.get(lower1Lines, i), array.get(lower2Lines, i), color=color.new(#FF007F, fillAlpha)))
                array.push(innerFills, linefill.new(array.get(upper1Lines, i), array.get(lower1Lines, i), color=color.new(#050E2A, math.min(fillAlpha + 5, 97))))

    // ── Edge labels ──
    if showLabels
        sqrtEnd = math.sqrt(float(projBars))
        u1End   = anchorPrice * math.exp( 1.0 * sigmaBar * sqrtEnd)
        l1End   = anchorPrice * math.exp(-1.0 * sigmaBar * sqrtEnd)
        u2End   = anchorPrice * math.exp( 2.0 * sigmaBar * sqrtEnd)
        l2End   = anchorPrice * math.exp(-2.0 * sigmaBar * sqrtEnd)

        if showOneSig
            array.push(edgeLabels, label.new(anchorBar + projBars, u1End, "+1σ  " + fmtPrice(u1End), color=color.new(colorUpSig, 50), textcolor=color.white, style=label.style_label_left, size=size.normal))
            array.push(edgeLabels, label.new(anchorBar + projBars, l1End, "−1σ  " + fmtPrice(l1End), color=color.new(colorDnSig, 50), textcolor=color.white, style=label.style_label_left, size=size.normal))
        if showTwoSig
            array.push(edgeLabels, label.new(anchorBar + projBars, u2End, "+2σ  " + fmtPrice(u2End), color=color.new(color2Sig, 45), textcolor=color.white, style=label.style_label_left, size=size.normal))
            array.push(edgeLabels, label.new(anchorBar + projBars, l2End, "−2σ  " + fmtPrice(l2End), color=color.new(color2Sig, 45), textcolor=color.white, style=label.style_label_left, size=size.normal))

// ───── INSTITUTIONAL DASHBOARD ─────
var table infoTable = table.new(position.top_right, 2, 7, bgcolor=color.new(#05050E, 5), border_width=1, border_color=color.new(#1A1A38, 0), frame_width=2, frame_color=color.new(#3333BB, 55))

if barstate.islast and showTable and not na(sigmaBar)
    annFactor = timeframe.isdaily ? math.sqrt(252) : timeframe.isweekly ? math.sqrt(52) : timeframe.ismonthly ? math.sqrt(12) : math.sqrt(365 * 24 * 60 / math.max(timeframe.in_seconds() / 60, 1))
    annVol    = sigmaBar * annFactor * 100
    expMove1  = (math.exp(sigmaBar * math.sqrt(float(projBars))) - 1) * 100

    trendArrow = volTrend == 1 ? "  ▲" : volTrend == -1 ? "  ▼" : "  ─"
    trendColor = volTrend == 1 ? color.new(#FF4444, 0) : volTrend == -1 ? color.new(#00C853, 0) : color.white
    regimeStr  = volTrend == 1 ? "EXPANDING" : volTrend == -1 ? "CONTRACTING" : "STABLE"

    hdrBg  = color.new(#0C0C28, 0)
    cellBg = color.new(#05050E, 0)
    ftBg   = color.new(#0A0A1E, 0)

    // Row 0 — Header
    table.cell(infoTable, 0, 0, "HASH DISPERSION CONE", bgcolor=hdrBg, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 0, volMethod,               bgcolor=hdrBg, text_color=color.white, text_size=size.small, text_halign=text.align_right)

    // Row 1 — σ per bar
    table.cell(infoTable, 0, 1, "σ  /  bar",  bgcolor=cellBg, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 1, str.tostring(sigmaBar * 100, "#.##") + "%", bgcolor=cellBg, text_color=color.white, text_size=size.small, text_halign=text.align_right)

    // Row 2 — σ annualized + trend arrow
    table.cell(infoTable, 0, 2, "σ  annualized", bgcolor=cellBg, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 2, str.tostring(annVol, "#.##") + "%" + trendArrow, bgcolor=cellBg, text_color=trendColor, text_size=size.small, text_halign=text.align_right)

    // Row 3 — Expected 1σ range
    table.cell(infoTable, 0, 3, "1σ  range",  bgcolor=cellBg, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 3, "±" + str.tostring(expMove1, "#.##") + "%  / " + str.tostring(projBars) + "b", bgcolor=cellBg, text_color=color.white, text_size=size.small, text_halign=text.align_right)

    // Row 4 — Lookback
    table.cell(infoTable, 0, 4, "Lookback",  bgcolor=cellBg, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 4, str.tostring(lookback) + " bars", bgcolor=cellBg, text_color=color.white, text_size=size.small, text_halign=text.align_right)

    // Row 5 — Vol Regime
    table.cell(infoTable, 0, 5, "Vol Regime", bgcolor=cellBg, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(infoTable, 1, 5, regimeStr,    bgcolor=cellBg, text_color=trendColor,  text_size=size.small, text_halign=text.align_right)

    // Row 6 — Footer
    table.cell(infoTable, 0, 6, "HASH CAPITAL RESEARCH", bgcolor=ftBg, text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(infoTable, 1, 6, "hcr.trade",             bgcolor=ftBg, text_color=color.white, text_size=size.tiny, text_halign=text.align_right)
````
