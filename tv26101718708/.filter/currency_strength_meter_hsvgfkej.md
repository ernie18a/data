# Currency Strength Meter

- url: https://www.tradingview.com/script/hSVgFkEj-Currency-Strength-Meter/
- type: indicator
- pine_id: PUB;99a286e452774742b8b453e0787b523f
- version: 2.0

## Description

[b]Currency Strength Meter — 8 Majors[/b]

Track real-time relative strength across the 8 major currencies in a single panel: USD, EUR, JPY, GBP, AUD, CHF, CAD and NZD. Each currency is benchmarked against the average performance of the group, so you can instantly see which currencies are bid and which are offered — without flipping between a dozen FX charts.

[b]What it shows[/b]

Each line represents a currency's strength relative to the basket average, expressed in basis points (bps) of percentage move since the anchor reset. A currency above the zero line is outperforming the average, below zero it's underperforming. The relative ranking matters more than the absolute values — if USD is at +40 bps and JPY is at -60 bps, you're looking at a 100 bps gap of relative momentum that typically shows up in USD/JPY price action.

The math: the script pulls EURUSD, GBPUSD, AUDUSD, NZDUSD, USDJPY, USDCHF, USDCAD, computes each currency's percentage move since the anchor (inverted for the quote currencies), then subtracts the basket mean so all 8 strengths sum to zero. This removes the USD bias inherent to most "strength meters" that just measure pairs against the dollar.

[b]Why it matters[/b]

Currency strength meters cut through the noise of individual pair charts. When you see the same pattern repeated across multiple pairs (EUR weak vs USD, EUR weak vs JPY, EUR weak vs GBP), it's no longer about one pair — it's about EUR itself. This indicator surfaces that signal in one glance.

Particularly useful for:
[list]
[*]Pair selection — long the strongest, short the weakest for maximum dispersion
[*]Avoiding chop — when two currencies are clustered near zero, their cross is likely to range
[*]Spotting regime shifts when a currency suddenly breaks away from the pack
[*]Confirming or fading reactions to central bank decisions, CPI, NFP across the FX complex
[*]Filtering out fake breakouts on individual pairs that aren't backed by broader strength
[/list]

[b]Viewport-following labels (the killer feature)[/b]

Unlike most strength meters where labels stick to the latest bar, the labels here [b]follow the right edge of your visible viewport[/b]. Scroll back in history and the labels update to show the strength values [b]at that point in time[/b] — not at the current bar. This lets you study historical setups with the same readability as the live state, no zooming and hovering required.

Labels are automatically positioned to avoid overlap when multiple currencies are clustered, with configurable spacing (auto or manual).

[b]Anchor modes[/b]

[list]
[*][b]Daily[/b]: reset at the start of each trading day (default — best for intraday)
[*][b]Weekly[/b]: reset at the start of each week (best for swing trading)
[*][b]Session (Lookback)[/b]: rolling N-bar window for continuous measurement (best for context-free relative strength)
[/list]

[b]Settings[/b]

[list]
[*][b]Reset anchor[/b]: Daily, Weekly, or rolling Session lookback
[*][b]EMA smoothing[/b]: optional smoothing to filter intrabar noise (1 = raw, no smoothing)
[*][b]Line width[/b]: 1 to 4
[*][b]Currency toggles[/b]: show or hide each of the 8 currencies independently
[*][b]Custom colors[/b]: each currency line can be recolored
[*][b]Label gap[/b]: auto (scales with range) or manual (fixed bps gap)
[*][b]Zero line[/b]: visual reference for relative strength sign
[/list]

[b]Recommended setup[/b]

Apply on any forex pair, on a 15m to 1h timeframe for intraday work, or 4h to daily for swing analysis. The indicator uses the chart's symbol only as a time base — the strength calculation is independent of which pair you're viewing.

Best paired with the underlying price action: when a currency breaks out on the strength meter, look at its strongest/weakest counterpart to find the best pair to trade the move.

[b]Notes[/b]

Strength is measured against the 7 majors using direct or inverted USD crosses. JPY, CHF and CAD are inverted (since they're quote currencies vs USD in their major pair), so a rising USDJPY shows as JPY weakness, not strength. The mean-subtraction step normalizes the basket so all 8 values sum to zero, giving you true relative momentum rather than dollar-skewed readings.

Feedback and suggestions welcome.

## Source Code

````pine
//@version=6
indicator("Currency Strength Meter", overlay=false, precision=1, max_labels_count=50, max_bars_back=5000)

// === ANCHOR ===
anchorMode = input.string("Daily", "Reset anchor", options=["Daily", "Weekly", "Session (Lookback)"])
lookbackBars = input.int(96, "Lookback bars (Session mode)", minval=1)

smooth = input.int(1, "EMA smoothing (1 = none)", minval=1)
lineWidth = input.int(1, "Line width", minval=1, maxval=4)

showZero = input.bool(true, "Show zero line")

// === LABELS ===
g_l = "Labels"
showLabels = input.bool(true, "Show labels (follow viewport)", group=g_l)
autoGap = input.bool(true, "Auto label gap", group=g_l)
gapPct = input.float(7.0, "Auto gap (% of range)", minval=2.0, maxval=20.0, step=0.5, group=g_l)
manualGap = input.float(8.0, "Manual gap (if Auto OFF, in bps)", minval=1.0, step=0.5, group=g_l)

// === CURRENCY TOGGLES ===
g_c = "Currencies"
showUSD = input.bool(true, "USD", group=g_c, inline="r1")
showEUR = input.bool(true, "EUR", group=g_c, inline="r1")
showJPY = input.bool(true, "JPY", group=g_c, inline="r1")
showGBP = input.bool(true, "GBP", group=g_c, inline="r1")
showAUD = input.bool(true, "AUD", group=g_c, inline="r2")
showCHF = input.bool(true, "CHF", group=g_c, inline="r2")
showCAD = input.bool(true, "CAD", group=g_c, inline="r2")
showNZD = input.bool(true, "NZD", group=g_c, inline="r2")

// === COLORS ===
g_co = "Colors"
colUSD = input.color(color.orange,  "USD", group=g_co, inline="c1")
colEUR = input.color(color.red,     "EUR", group=g_co, inline="c1")
colJPY = input.color(color.aqua,    "JPY", group=g_co, inline="c1")
colGBP = input.color(color.lime,    "GBP", group=g_co, inline="c1")
colAUD = input.color(color.blue,    "AUD", group=g_co, inline="c2")
colCHF = input.color(#8B4513,       "CHF", group=g_co, inline="c2")
colCAD = input.color(color.purple,  "CAD", group=g_co, inline="c2")
colNZD = input.color(color.fuchsia, "NZD", group=g_co, inline="c2")

// === FETCH MAJORS ===
eurusd = request.security("FX:EURUSD", timeframe.period, close)
gbpusd = request.security("FX:GBPUSD", timeframe.period, close)
audusd = request.security("FX:AUDUSD", timeframe.period, close)
nzdusd = request.security("FX:NZDUSD", timeframe.period, close)
usdjpy = request.security("FX:USDJPY", timeframe.period, close)
usdchf = request.security("FX:USDCHF", timeframe.period, close)
usdcad = request.security("FX:USDCAD", timeframe.period, close)

// === ANCHOR DETECTION ===
isNewAnchor = switch anchorMode
    "Daily"  => ta.change(time("D")) != 0
    "Weekly" => ta.change(time("W")) != 0
    => false

var float a_eu = na
var float a_gu = na
var float a_au = na
var float a_nu = na
var float a_uj = na
var float a_uc = na
var float a_ud = na

if isNewAnchor or barstate.isfirst
    a_eu := eurusd
    a_gu := gbpusd
    a_au := audusd
    a_nu := nzdusd
    a_uj := usdjpy
    a_uc := usdchf
    a_ud := usdcad

if anchorMode == "Session (Lookback)"
    a_eu := eurusd[lookbackBars]
    a_gu := gbpusd[lookbackBars]
    a_au := audusd[lookbackBars]
    a_nu := nzdusd[lookbackBars]
    a_uj := usdjpy[lookbackBars]
    a_uc := usdchf[lookbackBars]
    a_ud := usdcad[lookbackBars]

// === % MOVES vs USD (basis points) ===
m_eur = (eurusd / a_eu - 1) * 10000
m_gbp = (gbpusd / a_gu - 1) * 10000
m_aud = (audusd / a_au - 1) * 10000
m_nzd = (nzdusd / a_nu - 1) * 10000
m_jpy = -(usdjpy / a_uj - 1) * 10000
m_chf = -(usdchf / a_uc - 1) * 10000
m_cad = -(usdcad / a_ud - 1) * 10000
m_usd = 0.0

// === STRENGTH ===
mean_m = (m_usd + m_eur + m_gbp + m_jpy + m_chf + m_cad + m_aud + m_nzd) / 8

s_usd = ta.ema(m_usd - mean_m, smooth)
s_eur = ta.ema(m_eur - mean_m, smooth)
s_jpy = ta.ema(m_jpy - mean_m, smooth)
s_gbp = ta.ema(m_gbp - mean_m, smooth)
s_aud = ta.ema(m_aud - mean_m, smooth)
s_chf = ta.ema(m_chf - mean_m, smooth)
s_cad = ta.ema(m_cad - mean_m, smooth)
s_nzd = ta.ema(m_nzd - mean_m, smooth)

// === PLOTS ===
plot(showUSD ? s_usd : na, "USD", color=colUSD, linewidth=lineWidth)
plot(showEUR ? s_eur : na, "EUR", color=colEUR, linewidth=lineWidth)
plot(showJPY ? s_jpy : na, "JPY", color=colJPY, linewidth=lineWidth)
plot(showGBP ? s_gbp : na, "GBP", color=colGBP, linewidth=lineWidth)
plot(showAUD ? s_aud : na, "AUD", color=colAUD, linewidth=lineWidth)
plot(showCHF ? s_chf : na, "CHF", color=colCHF, linewidth=lineWidth)
plot(showCAD ? s_cad : na, "CAD", color=colCAD, linewidth=lineWidth)
plot(showNZD ? s_nzd : na, "NZD", color=colNZD, linewidth=lineWidth)

hline(0, "Zero", color=showZero ? color.new(color.gray, 50) : color.new(color.gray, 100))

// === LABELS THAT FOLLOW LINES IN REAL-TIME ON SCROLL ===
var label[] labels = array.new<label>()

if barstate.islast and showLabels
    // Clear previous labels
    for lbl in labels
        label.delete(lbl)
    array.clear(labels)

    // Find the right visible bar (triggers redraw on scroll/zoom)
    right_time = chart.right_visible_bar_time
    bar_duration = time - time[1]

    // Compute offset back from current bar to reach the right visible bar
    target_offset = 0
    if not na(right_time) and not na(bar_duration) and bar_duration > 0 and right_time < last_bar_time
        time_diff = last_bar_time - right_time
        target_offset := math.round(time_diff / bar_duration)
        target_offset := math.min(math.max(0, target_offset), bar_index)

    label_time = na(right_time) or right_time > last_bar_time ? last_bar_time : right_time

    // Get strength values AT the right visible bar
    s_usd_t = s_usd[target_offset]
    s_eur_t = s_eur[target_offset]
    s_jpy_t = s_jpy[target_offset]
    s_gbp_t = s_gbp[target_offset]
    s_aud_t = s_aud[target_offset]
    s_chf_t = s_chf[target_offset]
    s_cad_t = s_cad[target_offset]
    s_nzd_t = s_nzd[target_offset]

    // Build arrays of visible currencies
    strengths = array.new<float>()
    names = array.new<string>()
    cols = array.new<color>()

    if showUSD and not na(s_usd_t)
        array.push(strengths, s_usd_t)
        array.push(names, "USD")
        array.push(cols, colUSD)
    if showEUR and not na(s_eur_t)
        array.push(strengths, s_eur_t)
        array.push(names, "EUR")
        array.push(cols, colEUR)
    if showJPY and not na(s_jpy_t)
        array.push(strengths, s_jpy_t)
        array.push(names, "JPY")
        array.push(cols, colJPY)
    if showGBP and not na(s_gbp_t)
        array.push(strengths, s_gbp_t)
        array.push(names, "GBP")
        array.push(cols, colGBP)
    if showAUD and not na(s_aud_t)
        array.push(strengths, s_aud_t)
        array.push(names, "AUD")
        array.push(cols, colAUD)
    if showCHF and not na(s_chf_t)
        array.push(strengths, s_chf_t)
        array.push(names, "CHF")
        array.push(cols, colCHF)
    if showCAD and not na(s_cad_t)
        array.push(strengths, s_cad_t)
        array.push(names, "CAD")
        array.push(cols, colCAD)
    if showNZD and not na(s_nzd_t)
        array.push(strengths, s_nzd_t)
        array.push(names, "NZD")
        array.push(cols, colNZD)

    n = array.size(strengths)

    if n > 0
        max_s = array.max(strengths)
        min_s = array.min(strengths)
        range_s = max_s - min_s
        effective_gap = autoGap ? math.max(3.0, range_s * gapPct / 100.0) : manualGap

        // Sort by strength descending
        sortedIdx = array.sort_indices(strengths, order.descending)

        // Anti-collision: top-down pass
        adjustedY = array.new<float>(n, 0.0)
        for i = 0 to n - 1
            idx = array.get(sortedIdx, i)
            actualY = array.get(strengths, idx)
            if i == 0
                array.set(adjustedY, i, actualY)
            else
                prevY = array.get(adjustedY, i - 1)
                array.set(adjustedY, i, math.min(actualY, prevY - effective_gap))

        // Detect history view (scrolled back)
        in_history = not na(right_time) and right_time < last_bar_time

        // When in history: anchor on right visible bar, body extends LEFT into viewport
        // When live: anchor 2 bars past last bar (in right margin), body extends RIGHT
        offset_ms = in_history ? 0 : (na(bar_duration) ? 0 : bar_duration * 2)
        chosen_style = in_history ? label.style_label_right : label.style_label_left

        // Create labels
        for i = 0 to n - 1
            idx = array.get(sortedIdx, i)
            name = array.get(names, idx)
            strength = array.get(strengths, idx)
            col = array.get(cols, idx)
            yLabel = array.get(adjustedY, i)
            txt = name + " " + str.tostring(strength, "#.0")
            lbl = label.new(label_time + offset_ms, yLabel, txt, xloc=xloc.bar_time, color=col, textcolor=color.white, style=chosen_style, size=size.small)
            array.push(labels, lbl)
````
