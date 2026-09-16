<!-- tradingview-pine-id: PUB;d3693824f7f647a080d752228cb085fc -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Regime Range Map [AFD]

Source: https://www.tradingview.com/script/BK9h3hTP-Volatility-Regime-Range-Map-AFD/

## Description

Two stretches of the same chart can look alike and be nothing alike — one the quietest tape in months, the other the widest swings all year. 

Volatility Regime Range Map tells them apart on sight: it sorts every bar into one of four volatility regimes — QUIET, NORMAL, ELEVATED, EXTREME — and draws each unbroken stretch as a colored box on price. The calm and the turbulent history of your chart read at a glance instead of bar by bar.

What it does
[image]https://www.tradingview.com/x/226PHltY/[/image]
At a glance it names which of four volatility regimes the current stretch belongs to, and how it compares with the chart's own recent history.

[*]Regime episodes as boxes. Each unbroken stretch of one regime is a box spanning the bars it covered and the price range it reached. The current box glows and extends while the regime holds; recent finished episodes stay as faint boxes behind it — a map of which stretches were quiet and which were turbulent.
[*]A regime ranked over calendar time. Each bar's volatility is ranked as a percentile against a rolling calendar window (default 6 months), so a regime means the same span of history on a 5-minute chart or a daily one — whether the tape is calmer, wider, or about the same as this symbol usually runs.
[*]Higher-timeframe frames. The same engine on one or two higher timeframes, drawn as outline frames — HTF 1 dashed, HTF 2 dotted (default 1 month and 1 week) — each labelled with its timeframe and regime, so the broader context is on the same screen without switching charts.
[*]Optional dashboard. Off by default. When on, it shows the current regime, the episode's age and price range, where those rank among finished episodes, and the sample behind the ranking.
[*]A standing note in the Data Window — "Volatility-regime episodes · describes chart history · not a forecast" — that is always on.

Every one of those is a measurement of chart history. It reports what volatility has been; it does not tell you what price will do next or how long a regime will last.

How it works
[image]https://www.tradingview.com/x/f0WJDq01/[/image]
Parkinson

[image]https://www.tradingview.com/x/p2c6eQua/[/image]
Garman-Klass

[*]Estimator. Parkinson (default), Close-to-close, Garman-Klass, or ATR — the one you pick measures every regime on the chart.
[*]Percentile to tier, with hysteresis. The reading maps to a tier at the 25th, 75th and 85th percentiles, through a small hysteresis band so the regime does not flip on one borderline bar. QUIET below 25, NORMAL 25–75, ELEVATED 75–85, EXTREME 85 and above.
[*]An optional second route into EXTREME. Flags EXTREME when the short window reaches a set multiple of the long one — also while the window is still gathering enough history to rank.
[*]Confirmed bars only, no redraw. Regimes update on confirmed bars. A new box opens at the bar where the regime changes; once a box or a frame is drawn, later bars do not move it or recolour it.
[*]The higher-timeframe frames use request.security to read each timeframe's most recently confirmed regime.

How to use it

[*]Add it to any chart and timeframe. The defaults are the intended reading: Parkinson, Fast (5/30), a 6-month lookback, frames on (1M dashed + 1W dotted), dashboard off. Remove and re-add once so it draws in front of the candles.
[*]Read the boxes first — the colour names the regime you are in, and the height is the price range that stretch covered.
[*]Use the dashed and dotted frames to see the weekly and monthly regime on the chart you are trading.
[*]Turn on the dashboard for the current episode's age and range in numbers, and where they rank.
[*]Change the comparison lookback to widen or narrow the window a regime is judged against.

What it deliberately does not do
Every number is measured from this chart's own price history — nothing is implied, expected, or projected forward.

[*]No alerts, no signals, no entries or exits.
[*]No statement about what price will do next, or how long a regime will last.
[*]Counts and percentiles stay descriptions of this chart's history — never converted into odds.
[*]The regime names are labels for measured tiers, not ratings, scores, or predictions.

Why it is original
Most volatility tools hand you a line (ATR, standard deviation) or a band. This one segments the history into regime episodes and draws each as a box you can take in at a glance, ranks the regime over a rolling calendar window so it means the same across timeframes, and can stack one or two higher timeframes as nested frames on the chart. The classifier is the engine from the author's Volatility Regime Classifier, re-expressed here as an on-price map ranked over calendar time.

Open source under the Mozilla Public License 2.0. Native Pine v6; the optional higher-timeframe frames read the regime on higher timeframes via request.security, and nothing uses external data.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Auction Foundry

//@version=6
indicator("Volatility Regime Range Map [AFD]", "Volatility Map [AFD]", overlay = true, behind_chart = false, max_boxes_count = 500, max_labels_count = 50, max_bars_back = 500)

// ---------------------------------------------------------------------------
// Constants (regime engine copied verbatim from VRC_AFD_v1.pine)
// ---------------------------------------------------------------------------
int   SECONDS_PER_DAY = 86400
float LN2      = math.log(2.0)
float GK_COEFF = 2.0 * LN2 - 1.0

int TIER_QUIET    = 0
int TIER_NORMAL   = 1
int TIER_ELEVATED = 2
int TIER_EXTREME  = 3

float QUIET_TH    = 25.0
float ELEVATED_TH = 75.0
float EXTREME_TH  = 85.0
float TIER_BAND   = 1.0
int   MS_DAY          = 86400000  // milliseconds in one calendar day
int   MIN_RANK_SAMPLE = 30        // readings the comparison window must hold before a percentile is ranked
int   RANK_CAP        = 5000      // hard ceiling on the ranking buffer (low-timeframe performance + memory guard); its value is also written as a literal in the lookback tooltip (const-string context — keep in sync)
float BOUND_OPEN_LOW  = -1000000.0
float BOUND_OPEN_HIGH =  1000000.0

string EST_CLOSE     = "Close-to-close"
string EST_PARKINSON = "Parkinson (high-low)"
string EST_GK        = "Garman-Klass (OHLC)"
string EST_ATR       = "ATR (average true range)"

float OVERRIDE_CLOSE     = 2.00
float OVERRIDE_PARKINSON = 1.35
float OVERRIDE_GK        = 1.30
float OVERRIDE_ATR       = 1.40

string SENS_FAST   = "Fast (5 / 30)"
string SENS_NORMAL = "Normal (10 / 60)"
string SENS_SLOW   = "Slow (20 / 120)"

// Episode history + drawing constants
int   HIST_CAP         = 500    // completed episodes kept for the percentiles
int   MIN_SAMPLE       = 10     // completed episodes needed before a percentile shows
float HALO_FLOOR       = 0.12   // a halo layer never fades below this fraction of the core's opacity
int   GLOW_WIDTH_STEP  = 2      // each outward halo layer is this many pixels wider
int   HTF_FRAME_TRANSP = 25     // higher-timeframe frame border transparency (0 solid, 100 clear)

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
string GRP_ENGINE   = "Regime engine"
string GRP_COLORS   = "Regime colors"
string GRP_EPISODES = "Episode boxes"
string GRP_MTF      = "Higher timeframes"
string GRP_HUD      = "Dashboard"

// --- Regime engine ---
string estimatorInput = input.string(EST_PARKINSON, "Volatility estimator", display = display.none,
     options = [EST_PARKINSON, EST_CLOSE, EST_GK, EST_ATR], group = GRP_ENGINE,
     tooltip = "How each bar's movement is measured (same math as the Volatility Regime Classifier)." +
     "\n• Parkinson — high-low range (default)" +
     "\n• Close-to-close — spread of closing returns" +
     "\n• Garman-Klass — range plus open-to-close" +
     "\n• ATR — average true range vs price (simple N-bar, not Wilder's)")

string sensitivityInput = input.string(SENS_FAST, "Sensitivity", display = display.none,
     options = [SENS_FAST, SENS_NORMAL, SENS_SLOW], group = GRP_ENGINE,
     tooltip = "Bars per reading — shorter reacts sooner, longer is smoother." +
     "\n• Fast — 5 vs 30 (default)" +
     "\n• Normal — 10 vs 60" +
     "\n• Slow — 20 vs 120 (fewer, later changes)")

int    lookbackLengthInput = input.int(6, "Comparison lookback", minval = 1, maxval = 120, group = GRP_ENGINE, inline = "lb", display = display.none,
     tooltip = "Rolling calendar window the current volatility is ranked against — the same span on any timeframe." +
     "\n• Regime = the reading's percentile inside this window" +
     "\n• Months count as 30-day spans (approximate)" +
     "\n• Longer window = steadier regimes" +
     "\n• Very low timeframes cap at the last 5,000 readings")
string lookbackUnitInput = input.string("Months", "", options = ["Days", "Weeks", "Months"], group = GRP_ENGINE, inline = "lb", display = display.none)

bool extremeBySizeInput = input.bool(true, "Also call EXTREME by absolute size", group = GRP_ENGINE,
     tooltip = "A second path to EXTREME when the percentile can't reach it: the short window hits a set multiple of the long one. Also flags EXTREME before the window holds enough history to rank.")

bool excludeSessionGapInput = input.bool(true, "Exclude the session gap", group = GRP_ENGINE,
     tooltip = "Ignores the overnight gap on each session's first bar." +
     "\n• Affects Close-to-close and ATR only" +
     "\n• Range estimators read inside one bar, so they're unchanged")

// --- Regime colors (shared by the episode boxes and the HTF frames) ---
color colQuiet    = input.color(#2962ff, "QUIET",    group = GRP_COLORS, inline = "c1")
color colNormal   = input.color(#26a69a, "NORMAL",   group = GRP_COLORS, inline = "c1")
color colElevated = input.color(#ff9800, "ELEVATED", group = GRP_COLORS, inline = "c2")
color colExtreme  = input.color(#f23645, "EXTREME",  group = GRP_COLORS, inline = "c2")

// --- Episode boxes ---
int  primaryWidthInput = input.int(2, "Box border width", minval = 1, maxval = 6, group = GRP_EPISODES, display = display.none,
     tooltip = "Thickness of the current episode's border. Any glow builds outward from it.")
int  glowLayersInput   = input.int(3, "Glow layers", minval = 0, maxval = 6, group = GRP_EPISODES, display = display.none,
     tooltip = "Soft halo strokes around the current box. 0 draws a plain border.")
int  borderTranspInput = input.int(20, "Border transparency", minval = 0, maxval = 100, group = GRP_EPISODES, display = display.none,
     tooltip = "Border opacity — 0 solid, 100 invisible. The glow fades out from here.")
int  fillTranspInput   = input.int(88, "Fill transparency", minval = 0, maxval = 100, group = GRP_EPISODES, display = display.none,
     tooltip = "Box fill opacity — 0 solid, 100 clear.")
bool showLabelInput    = input.bool(true, "Label the current box", group = GRP_EPISODES)
bool showPastInput     = input.bool(true, "Show completed boxes", group = GRP_EPISODES,
     tooltip = "Keep recent finished episodes as faint boxes behind the current one.")
int  pastCapInput      = input.int(12, "Completed boxes kept", minval = 0, maxval = 60, group = GRP_EPISODES, active = showPastInput, display = display.none,
     tooltip = "How many finished boxes stay drawn; older ones drop off. Dashboard percentiles use the full history regardless.")

// --- Higher timeframes ---
bool   enableMtfInput = input.bool(true, "Draw higher-timeframe frames", group = GRP_MTF,
     tooltip = "Runs the same regime engine on one or two higher timeframes and outlines each timeframe's current bar on the chart." +
     "\n• HTF 1 dashed, HTF 2 dotted" +
     "\n• Colored by that timeframe's last CONFIRMED regime — no repaint" +
     "\n• Anchored at the period open (session open for daily), grows to the current bar" +
     "\n• A timeframe not higher than the chart is skipped")
string htf1Input = input.timeframe("1M", "HTF 1", group = GRP_MTF, active = enableMtfInput, display = display.none, inline = "htf1",
     tooltip = "First higher timeframe — drawn as a DASHED frame. Must be higher than the chart's.")
int    htf1WidthInput = input.int(2, "width", minval = 1, maxval = 6, group = GRP_MTF, active = enableMtfInput, display = display.none, inline = "htf1")
string htf2Input = input.timeframe("1W", "HTF 2", group = GRP_MTF, active = enableMtfInput, display = display.none, inline = "htf2",
     tooltip = "Second higher timeframe — drawn as a DOTTED frame. Set it equal to HTF 1 to show only one.")
int    htf2WidthInput = input.int(2, "width", minval = 1, maxval = 6, group = GRP_MTF, active = enableMtfInput, display = display.none, inline = "htf2")
bool   htfColorByRegimeInput = input.bool(true, "Color frames by regime", group = GRP_MTF, active = enableMtfInput,
     tooltip = "On — frames use the regime colors above (blue→red). Off — each frame uses its own color below.")
color  htf1ColorInput = input.color(#f23645, "HTF 1 color", group = GRP_MTF, inline = "htfc", active = enableMtfInput and not htfColorByRegimeInput)
color  htf2ColorInput = input.color(#2962ff, "HTF 2 color", group = GRP_MTF, inline = "htfc", active = enableMtfInput and not htfColorByRegimeInput)

// --- Dashboard ---
bool   showDashboardInput = input.bool(false, "Show dashboard", group = GRP_HUD,
     tooltip = "Table of the current regime, the episode's age and range, and where those rank among finished episodes.")
string hudPosInput = input.string("Top right", "Position", display = display.none,
     options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = GRP_HUD, active = showDashboardInput)
string hudSizeInput = input.string("Small", "Size", display = display.none,
     options = ["Tiny", "Small", "Normal"], group = GRP_HUD, active = showDashboardInput)
int    tableTranspInput = input.int(10, "Dashboard transparency", minval = 0, maxval = 100, group = GRP_HUD, active = showDashboardInput, display = display.none)

// ---------------------------------------------------------------------------
// Regime helpers (verbatim from VRC_AFD_v1.pine)
// ---------------------------------------------------------------------------
stdevPop(buf, length) =>
    float result = na
    int n = array.size(buf)
    if length > 0 and n >= length
        float total = 0.0
        for i = n - length to n - 1
            total += array.get(buf, i)
        float mean = total / length
        float sq = 0.0
        for i = n - length to n - 1
            float d = array.get(buf, i) - mean
            sq += d * d
        result := math.sqrt(sq / length)
    result

parkinsonBar(h, l) =>
    float result = na
    if not na(h) and not na(l) and h > 0 and l > 0 and h >= l
        float logRange = math.log(h / l)
        result := logRange * logRange / (4.0 * LN2)
    result

garmanKlassBar(o, h, l, c) =>
    float result = na
    if not na(o) and not na(h) and not na(l) and not na(c) and o > 0 and h > 0 and l > 0 and c > 0 and h >= l
        float logRange = math.log(h / l)
        float logBody = math.log(c / o)
        result := 0.5 * logRange * logRange - GK_COEFF * logBody * logBody
    result

rvFromTerms(buf, length) =>
    float result = na
    int n = array.size(buf)
    if length > 0 and n >= length
        float total = 0.0
        bool valid = true
        for i = n - length to n - 1
            float v = array.get(buf, i)
            if na(v)
                valid := false
            else
                total += v
        if valid
            float mean = total / length
            result := mean > 0 ? math.sqrt(mean) : 0.0
    result

atrBar(h, l, pc, c) =>
    float result = na
    if not na(h) and not na(l) and not na(pc) and not na(c) and h > 0 and l > 0 and pc > 0 and c > 0
        result := (math.max(h, pc) - math.min(l, pc)) / c
    result

meanFromTerms(buf, length) =>
    float result = na
    int n = array.size(buf)
    if length > 0 and n >= length
        float total = 0.0
        bool valid = true
        for i = n - length to n - 1
            float v = array.get(buf, i)
            if na(v)
                valid := false
            else
                total += v
        if valid
            float mean = total / length
            result := mean > 0 ? mean : 0.0
    result

realizedVol(returnBuffer, termBuffer, length, mode) =>
    float result = na
    if bar_index >= length
        result := mode == EST_CLOSE ? stdevPop(returnBuffer, length) : mode == EST_ATR ? meanFromTerms(termBuffer, length) : rvFromTerms(termBuffer, length)
    result

percentileRank(buf, current) =>
    float result = na
    int n = array.size(buf)
    if n > 0
        int hits = 0
        for i = 0 to n - 1
            if array.get(buf, i) <= current
                hits += 1
        result := 100.0 * hits / n
    result

pushCapped(buf, value, cap) =>
    array.push(buf, value)
    if array.size(buf) > cap
        array.shift(buf)

tierOf(p, quietTh, elevatedTh, extremeTh) =>
    int result = TIER_EXTREME
    if p < quietTh
        result := TIER_QUIET
    else if p < elevatedTh
        result := TIER_NORMAL
    else if p < extremeTh
        result := TIER_ELEVATED
    result

tierBoundLow(t, quietTh, elevatedTh, extremeTh) =>
    float result = BOUND_OPEN_LOW
    if t == TIER_NORMAL
        result := quietTh
    else if t == TIER_ELEVATED
        result := elevatedTh
    else if t == TIER_EXTREME
        result := extremeTh
    result

tierBoundHigh(t, quietTh, elevatedTh, extremeTh) =>
    float result = BOUND_OPEN_HIGH
    if t == TIER_QUIET
        result := quietTh
    else if t == TIER_NORMAL
        result := elevatedTh
    else if t == TIER_ELEVATED
        result := extremeTh
    result

applyHysteresis(raw, held, p, quietTh, elevatedTh, extremeTh, band) =>
    int result = raw
    if not na(held) and held != raw and band > 0
        if raw > held
            result := p >= tierBoundHigh(held, quietTh, elevatedTh, extremeTh) + band ? raw : held
        else
            result := p < tierBoundLow(held, quietTh, elevatedTh, extremeTh) - band ? raw : held
    result

tierName(t) =>
    string result = "-"
    if t == TIER_QUIET
        result := "QUIET"
    else if t == TIER_NORMAL
        result := "NORMAL"
    else if t == TIER_ELEVATED
        result := "ELEVATED"
    else if t == TIER_EXTREME
        result := "EXTREME"
    result

// ---------------------------------------------------------------------------
// Local helpers
// ---------------------------------------------------------------------------
regimeColor(t) =>
    t == TIER_QUIET ? colQuiet : t == TIER_NORMAL ? colNormal : t == TIER_ELEVATED ? colElevated : t == TIER_EXTREME ? colExtreme : chart.fg_color

// Fade a colour's opacity MULTIPLICATIVELY on its own headroom (never by adding
// transparency points), so a faint base never clamps to invisible. `factor` in
// (0,1] scales the visible span 100 - baseTransp; floored at HALO_FLOOR so no
// halo renders fainter than that fraction of the core.
glowColor(base, baseTransp, factor) =>
    float f = math.max(factor, HALO_FLOOR)
    float visible = (100.0 - baseTransp) * f
    color.new(base, 100.0 - visible)

tablePos(s) =>
    s == "Top left" ? position.top_left : s == "Bottom right" ? position.bottom_right : s == "Bottom left" ? position.bottom_left : position.top_right

tableSize(s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

// Draw one OUTLINE frame around the CURRENT higher-timeframe period. Anchored at
// the period open (`periodStart` = `time(htfInput)`; the RTH session open for a
// daily frame), extended to the current bar, spanning the high/low reached so far
// — i.e. that timeframe's developing bar as a box, in `baseColor` (its confirmed
// regime by default, or a custom colour) at `borderWidth`. Switching the higher
// timeframe moves the anchor to the new period's open, so the frames nest naturally
// (month ⊇ week ⊇ day). Outline only (`bgcolor = na`) so it never muddies the
// candles. A right-edge label names the timeframe and regime. Each call site keeps
// its own `var` state (two timeframes -> two period trackers). Drawn in
// `xloc.bar_time` (the period open can sit past the 10,000-bar `bar_index` limit).
updateHtfFrame(active, tier, baseColor, styleConst, tag, periodStart, borderWidth) =>
    var box   fBox   = na
    var label fLab   = na
    var int   pStart = na
    var float pHigh  = na
    var float pLow   = na
    if not active or na(tier) or na(periodStart)
        if not na(fBox)
            box.delete(fBox)
            fBox := na
        if not na(fLab)
            label.delete(fLab)
            fLab := na
        pStart := na
    else
        if na(pStart) or periodStart != pStart
            pStart := periodStart
            pHigh  := high
            pLow   := low
        else
            pHigh := math.max(pHigh, high)
            pLow  := math.min(pLow, low)
        color col = color.new(baseColor, HTF_FRAME_TRANSP)
        if na(fBox)
            fBox := box.new(pStart, pHigh, time, pLow, xloc = xloc.bar_time, bgcolor = na, border_color = col, border_width = borderWidth, border_style = styleConst)
        else
            box.set_left(fBox, pStart)
            box.set_top(fBox, pHigh)
            box.set_right(fBox, time)
            box.set_bottom(fBox, pLow)
            box.set_border_color(fBox, col)
            box.set_border_width(fBox, borderWidth)
            box.set_border_style(fBox, styleConst)
        string txt = tag + " · " + tierName(tier)
        if na(fLab)
            fLab := label.new(time, pHigh, txt, xloc = xloc.bar_time, style = label.style_label_left, color = color.new(chart.bg_color, 20), textcolor = baseColor, size = size.small)
        else
            label.set_xy(fLab, time, pHigh)
            label.set_text(fLab, txt)
            label.set_textcolor(fLab, baseColor)
    true    // side-effect function: consistent bool return regardless of branch

// ---------------------------------------------------------------------------
// Session-gap plumbing (verbatim from VRC)
// ---------------------------------------------------------------------------
bool isIntraday          = timeframe.in_seconds() < SECONDS_PER_DAY
bool sessionOpenBar      = isIntraday and session.isfirstbar
bool gapSensitiveEstimator = estimatorInput == EST_CLOSE or estimatorInput == EST_ATR
bool dropGapNow          = excludeSessionGapInput and gapSensitiveEstimator and sessionOpenBar

int shortLen = sensitivityInput == SENS_FAST ? 5 : sensitivityInput == SENS_SLOW ? 20 : 10
int longLen  = sensitivityInput == SENS_FAST ? 30 : sensitivityInput == SENS_SLOW ? 120 : 60
float extremeRatioNow = not extremeBySizeInput ? 0.0 : estimatorInput == EST_CLOSE ? OVERRIDE_CLOSE : estimatorInput == EST_PARKINSON ? OVERRIDE_PARKINSON : estimatorInput == EST_GK ? OVERRIDE_GK : OVERRIDE_ATR

int lookbackUnitMs = lookbackUnitInput == "Weeks" ? 7 * MS_DAY : lookbackUnitInput == "Months" ? 30 * MS_DAY : MS_DAY
int lookbackMs     = lookbackLengthInput * lookbackUnitMs

// ---------------------------------------------------------------------------
// Multi-timeframe regime — the SAME classifier, re-run in a self-contained
// function so `request.security` can evaluate it on a higher timeframe. The
// function owns its own buffers (each request.security call site gets its own
// persistent state, so the two higher timeframes never share readings) and
// reads the chart-level input globals, which are timeframe-independent settings.
// It advances only on confirmed bars, exactly like the inline engine, and holds
// the last known tier as the standing regime.
// ---------------------------------------------------------------------------
regimeTierFor() =>
    var array<float> hRetBuf  = array.new<float>(0)
    var array<float> hTermBuf = array.new<float>(0)
    var array<float> hPctBuf  = array.new<float>(0)
    var array<int>   hPctTime = array.new<int>(0)
    var int hHeld = na
    var int hTier = na
    if barstate.isconfirmed
        bool hIntraday = timeframe.in_seconds() < SECONDS_PER_DAY
        bool hDropGap  = excludeSessionGapInput and (estimatorInput == EST_CLOSE or estimatorInput == EST_ATR) and hIntraday and session.isfirstbar
        float hLogRet = bar_index > 0 and close > 0 and close[1] > 0 and not hDropGap ? math.log(close / close[1]) : na
        int hBufCap = math.max(longLen, shortLen)
        if not na(hLogRet)
            pushCapped(hRetBuf, hLogRet, hBufCap)
        float hBarTerm = estimatorInput == EST_PARKINSON ? parkinsonBar(high, low) : estimatorInput == EST_GK ? garmanKlassBar(open, high, low, close) : na
        float hAtrTerm = estimatorInput == EST_ATR and bar_index > 0 and not hDropGap ? atrBar(high, low, close[1], close) : na
        if estimatorInput == EST_ATR
            if not na(hAtrTerm)
                pushCapped(hTermBuf, hAtrTerm, hBufCap)
        else if estimatorInput != EST_CLOSE
            pushCapped(hTermBuf, hBarTerm, hBufCap)
        float hRvShort = realizedVol(hRetBuf, hTermBuf, shortLen, estimatorInput)
        float hRvLong  = realizedVol(hRetBuf, hTermBuf, longLen, estimatorInput)
        float hRatio   = not na(hRvShort) and not na(hRvLong) and hRvLong > 0 ? hRvShort / hRvLong : na
        if not na(hRvShort)
            array.push(hPctBuf, hRvShort)
            array.push(hPctTime, time)
            while array.size(hPctTime) > 0 and array.get(hPctTime, 0) < time - lookbackMs
                array.shift(hPctBuf)
                array.shift(hPctTime)
            while array.size(hPctBuf) > RANK_CAP
                array.shift(hPctBuf)
                array.shift(hPctTime)
        int hSampleN = array.size(hPctBuf)
        float hPct = not na(hRvShort) and hSampleN >= MIN_RANK_SAMPLE ? percentileRank(hPctBuf, hRvShort) : na
        bool hOverride = extremeRatioNow > 0 and not na(hRatio) and hRatio >= extremeRatioNow
        if hOverride
            hTier := TIER_EXTREME
            hHeld := TIER_EXTREME
        else if not na(hPct) and not na(hRvLong) and hRvLong > 0
            int hRaw = tierOf(hPct, QUIET_TH, ELEVATED_TH, EXTREME_TH)
            hTier := applyHysteresis(hRaw, hHeld, hPct, QUIET_TH, ELEVATED_TH, EXTREME_TH, TIER_BAND)
            hHeld := hTier
    hTier

// Non-repaint idiom (docs/PINE_GOTCHAS.md:752-771, from the Repainting authority
// page): the EXPR[1] offset AND lookahead_on TOGETHER return only the last
// confirmed higher-timeframe value — never a future leak, and never the compound
// two-period staleness of the offset-without-lookahead form. Called
// unconditionally at global scope; the display gates on whether the timeframe is
// actually higher than the chart's.
bool htf1Higher = timeframe.in_seconds(htf1Input) > timeframe.in_seconds()
bool htf2Higher = timeframe.in_seconds(htf2Input) > timeframe.in_seconds()
int htf1Tier = request.security(syminfo.tickerid, htf1Input, regimeTierFor()[1], lookahead = barmerge.lookahead_on)
int htf2Tier = request.security(syminfo.tickerid, htf2Input, regimeTierFor()[1], lookahead = barmerge.lookahead_on)
// Start time of each higher timeframe's CURRENT period — `time(htfInput)` returns
// the open time of the HTF bar the current chart bar belongs to (for a daily frame
// on an RTH chart, the RTH session open). The frame is anchored here and grows to
// the current bar. Evaluated unconditionally at global scope with the security reads.
int  htf1PeriodStart = time(htf1Input)
int  htf2PeriodStart = time(htf2Input)
bool htf1Active = enableMtfInput and htf1Higher
bool htf2Active = enableMtfInput and htf2Higher

// ---------------------------------------------------------------------------
// Persistent state
// ---------------------------------------------------------------------------
var array<float> retBuf     = array.new<float>(0)
var array<float> termBuf    = array.new<float>(0)
var array<float> pctBuf     = array.new<float>(0)
var array<int>   pctTimeBuf = array.new<int>(0)   // bar time (ms) parallel to pctBuf, for the calendar window
var int heldTier = na

var int   tierPrev  = na
var int   epiTier   = na
var int   epiStart  = na       // bar_index of the episode's first bar (age only)
var int   epiStartTime = na    // time of that bar (drawing anchor)
var int   epiEnd    = na       // bar_index of the episode's latest confirmed bar
var int   epiEndTime = na      // time of that bar (drawing anchor)
var float epiHigh   = na
var float epiLow    = na
var array<float> ageBuf   = array.new<float>(0)
var array<float> rangeBuf = array.new<float>(0)

var box curFill = na
var box curCore = na
var array<box> glowBoxes = array.new<box>(0)
var array<box> pastBoxes = array.new<box>(0)
var label curLabel = na

// ---------------------------------------------------------------------------
// Engine + segmentation + drawing — confirmed bars only, so state advances once
// per bar (matching reference/episode_reference.segment_episodes). Drawings use
// xloc.bar_time, so a long episode's anchor never drifts past the bar_index
// 10,000-bar drawing limit.
// ---------------------------------------------------------------------------
if barstate.isconfirmed
    // --- Regime classification (VRC subset: tier only) ---
    float logReturn = bar_index > 0 and close > 0 and close[1] > 0 and not dropGapNow ? math.log(close / close[1]) : na
    int bufCap = math.max(longLen, shortLen)
    if not na(logReturn)
        pushCapped(retBuf, logReturn, bufCap)

    float barTerm = estimatorInput == EST_PARKINSON ? parkinsonBar(high, low) : estimatorInput == EST_GK ? garmanKlassBar(open, high, low, close) : na
    float atrTerm = estimatorInput == EST_ATR and bar_index > 0 and not dropGapNow ? atrBar(high, low, close[1], close) : na
    if estimatorInput == EST_ATR
        if not na(atrTerm)
            pushCapped(termBuf, atrTerm, bufCap)
    else if estimatorInput != EST_CLOSE
        pushCapped(termBuf, barTerm, bufCap)

    float rvShort = realizedVol(retBuf, termBuf, shortLen, estimatorInput)
    float rvLong  = realizedVol(retBuf, termBuf, longLen, estimatorInput)
    float volRatio = not na(rvShort) and not na(rvLong) and rvLong > 0 ? rvShort / rvLong : na

    if not na(rvShort)
        array.push(pctBuf, rvShort)
        array.push(pctTimeBuf, time)
        // drop readings older than the calendar window (bars arrive in time order)
        while array.size(pctTimeBuf) > 0 and array.get(pctTimeBuf, 0) < time - lookbackMs
            array.shift(pctBuf)
            array.shift(pctTimeBuf)
        // low-timeframe guard: keep only the most recent RANK_CAP readings
        while array.size(pctBuf) > RANK_CAP
            array.shift(pctBuf)
            array.shift(pctTimeBuf)
    int sampleN = array.size(pctBuf)
    float volPercentile = not na(rvShort) and sampleN >= MIN_RANK_SAMPLE ? percentileRank(pctBuf, rvShort) : na

    bool extremeOverrideNow = extremeRatioNow > 0 and not na(volRatio) and volRatio >= extremeRatioNow

    int rawTier = na
    int volTier = na
    if extremeOverrideNow
        rawTier := TIER_EXTREME
        volTier := TIER_EXTREME
        heldTier := volTier
    else if not na(volPercentile) and not na(rvLong) and rvLong > 0
        rawTier := tierOf(volPercentile, QUIET_TH, ELEVATED_TH, EXTREME_TH)
        volTier := applyHysteresis(rawTier, heldTier, volPercentile, QUIET_TH, ELEVATED_TH, EXTREME_TH, TIER_BAND)
        heldTier := volTier

    // --- Episode segmentation ---
    bool regimeKnown = not na(volTier)
    if regimeKnown
        if na(epiTier)
            epiTier  := volTier
            epiStart := bar_index
            epiStartTime := time
            epiHigh  := high
            epiLow   := low
        else if volTier != tierPrev
            // Close the current episode: file its age and range (from its stored
            // start/end), draw it as a completed box, tear down the current stack
            // so the next episode's boxes are created ON TOP, then open the new one.
            float closedAge   = epiEnd - epiStart + 1
            float closedRange = epiHigh - epiLow
            pushCapped(ageBuf, closedAge, HIST_CAP)
            pushCapped(rangeBuf, closedRange, HIST_CAP)
            if showPastInput and pastCapInput > 0
                color pastBorder = color.new(regimeColor(epiTier), math.min(borderTranspInput + 35, 100))
                color pastFill   = color.new(regimeColor(epiTier), math.min(fillTranspInput + 6, 100))
                box pb = box.new(epiStartTime, epiHigh, epiEndTime, epiLow, xloc = xloc.bar_time, border_color = pastBorder, border_width = 1, bgcolor = pastFill)
                array.push(pastBoxes, pb)
                if array.size(pastBoxes) > pastCapInput
                    box evicted = array.shift(pastBoxes)
                    box.delete(evicted)
            if not na(curFill)
                box.delete(curFill)
                curFill := na
            if not na(curCore)
                box.delete(curCore)
                curCore := na
            if array.size(glowBoxes) > 0
                for gi = 0 to array.size(glowBoxes) - 1
                    box.delete(array.get(glowBoxes, gi))
                array.clear(glowBoxes)
            if not na(curLabel)
                label.delete(curLabel)
                curLabel := na
            epiTier  := volTier
            epiStart := bar_index
            epiStartTime := time
            epiHigh  := high
            epiLow   := low
        else
            epiHigh := math.max(epiHigh, high)
            epiLow  := math.min(epiLow, low)
        tierPrev := volTier

    // The open episode's box reaches every confirmed bar it covers, including a
    // transparent (na-tier) bar that neither changes the regime nor the extremes.
    if not na(epiTier)
        epiEnd     := bar_index
        epiEndTime := time

    // --- Draw the current episode (box + border glow) ---
    if not na(epiTier)
        color regCol = regimeColor(epiTier)
        if na(curFill)
            curFill := box.new(epiStartTime, epiHigh, epiEndTime, epiLow, xloc = xloc.bar_time, bgcolor = na, border_color = na)
            if glowLayersInput > 0
                for j = 1 to glowLayersInput
                    array.push(glowBoxes, box.new(epiStartTime, epiHigh, epiEndTime, epiLow, xloc = xloc.bar_time, bgcolor = na, border_color = na, border_width = 1))
            curCore := box.new(epiStartTime, epiHigh, epiEndTime, epiLow, xloc = xloc.bar_time, bgcolor = na, border_color = na, border_width = primaryWidthInput)
            if showLabelInput
                curLabel := label.new(epiStartTime, epiHigh, "", xloc = xloc.bar_time, style = label.style_label_down, color = na, textcolor = na, size = size.small)

        // fill (bottom of the z-order)
        box.set_left(curFill, epiStartTime)
        box.set_right(curFill, epiEndTime)
        box.set_top(curFill, epiHigh)
        box.set_bottom(curFill, epiLow)
        box.set_bgcolor(curFill, color.new(regCol, fillTranspInput))

        // halo layers: index 0 is the widest, faintest, outermost (created first)
        int nGlow = array.size(glowBoxes)
        if nGlow > 0
            for idx = 0 to nGlow - 1
                box hb = array.get(glowBoxes, idx)
                float factor = (idx + 1) / (nGlow + 1.0)          // inner layers brighter
                int   width  = primaryWidthInput + (nGlow - idx) * GLOW_WIDTH_STEP
                box.set_left(hb, epiStartTime)
                box.set_right(hb, epiEndTime)
                box.set_top(hb, epiHigh)
                box.set_bottom(hb, epiLow)
                box.set_bgcolor(hb, na)
                box.set_border_color(hb, glowColor(regCol, borderTranspInput, factor))
                box.set_border_width(hb, width)

        // crisp core border (top of the z-order)
        box.set_left(curCore, epiStartTime)
        box.set_right(curCore, epiEndTime)
        box.set_top(curCore, epiHigh)
        box.set_bottom(curCore, epiLow)
        box.set_border_color(curCore, color.new(regCol, borderTranspInput))
        box.set_border_width(curCore, primaryWidthInput)

        if showLabelInput and not na(curLabel)
            label.set_xy(curLabel, epiStartTime, epiHigh)
            label.set_text(curLabel, tierName(epiTier))
            label.set_textcolor(curLabel, regCol)
            label.set_color(curLabel, color.new(chart.bg_color, 20))

    // --- Higher-timeframe regime frames (nested outline boxes) ---
    // Drawn from the confirmed HTF tier series; HTF1 dashed, HTF2 dotted. Colored
    // by regime, or by a custom colour when "Color frames by regime" is off. A
    // frame shows only while the block is on and that timeframe is higher.
    color htf1Base = htfColorByRegimeInput ? regimeColor(htf1Tier) : htf1ColorInput
    color htf2Base = htfColorByRegimeInput ? regimeColor(htf2Tier) : htf2ColorInput
    updateHtfFrame(htf1Active, htf1Tier, htf1Base, line.style_dashed, htf1Input, htf1PeriodStart, htf1WidthInput)
    updateHtfFrame(htf2Active, htf2Tier, htf2Base, line.style_dotted, htf2Input, htf2PeriodStart, htf2WidthInput)

// ---------------------------------------------------------------------------
// Dashboard (rendered on the last bar only)
// ---------------------------------------------------------------------------
var table hud = table.new(tablePos(hudPosInput), 2, 10, border_width = 1)

if barstate.islast and showDashboardInput
    color bg       = color.new(chart.bg_color, tableTranspInput)
    color txt      = chart.fg_color
    color dim      = color.new(chart.fg_color, 34)
    color frameCol = color.new(chart.fg_color, 72)
    string sz      = tableSize(hudSizeInput)

    bool  haveEpisode = not na(epiTier)
    int   curAge   = haveEpisode ? epiEnd - epiStart + 1 : na      // confirmed bars only
    float curRange = haveEpisode ? epiHigh - epiLow : na
    float curMid   = haveEpisode ? (epiHigh + epiLow) / 2.0 : na
    float curRangePct = haveEpisode and curMid > 0 ? 100.0 * curRange / curMid : na
    int   completedN  = array.size(ageBuf)

    string ageP   = completedN >= MIN_SAMPLE and haveEpisode ? str.tostring(int(math.round(percentileRank(ageBuf, curAge)))) + "%" : "sample " + str.tostring(completedN) + "/" + str.tostring(MIN_SAMPLE)
    string rangeP = completedN >= MIN_SAMPLE and haveEpisode ? str.tostring(int(math.round(percentileRank(rangeBuf, curRange)))) + "%" : "sample " + str.tostring(completedN) + "/" + str.tostring(MIN_SAMPLE)

    string estShort = estimatorInput == EST_PARKINSON ? "Parkinson" : estimatorInput == EST_CLOSE ? "Close-to-close" : estimatorInput == EST_GK ? "Garman-Klass" : "ATR"
    string lbUnitShort = lookbackUnitInput == "Days" ? "d" : lookbackUnitInput == "Weeks" ? "w" : "mo"

    // fill contiguous rows via a running counter (overwrites in place each render).
    int r = 0
    table.cell(hud, 0, r, "REGIME", text_color = txt, bgcolor = bg, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, r, haveEpisode ? tierName(epiTier) : "warming up", text_color = haveEpisode ? regimeColor(epiTier) : dim, bgcolor = bg, text_size = sz, text_halign = text.align_right)
    r += 1
    table.cell(hud, 0, r, "Age", text_color = dim, bgcolor = bg, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, r, haveEpisode ? str.tostring(curAge) + " bars" : "-", text_color = txt, bgcolor = bg, text_size = sz, text_halign = text.align_right)
    r += 1
    table.cell(hud, 0, r, "Range", text_color = dim, bgcolor = bg, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, r, haveEpisode ? str.tostring(curRange, format.mintick) : "-", text_color = txt, bgcolor = bg, text_size = sz, text_halign = text.align_right)
    r += 1
    table.cell(hud, 0, r, "Range % of mid", text_color = dim, bgcolor = bg, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, r, haveEpisode and not na(curRangePct) ? str.tostring(curRangePct, "#.##") + "%" : "-", text_color = txt, bgcolor = bg, text_size = sz, text_halign = text.align_right)
    r += 1
    table.cell(hud, 0, r, "Age percentile", text_color = dim, bgcolor = bg, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, r, ageP, text_color = txt, bgcolor = bg, text_size = sz, text_halign = text.align_right)
    r += 1
    table.cell(hud, 0, r, "Range percentile", text_color = dim, bgcolor = bg, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, r, rangeP, text_color = txt, bgcolor = bg, text_size = sz, text_halign = text.align_right)
    r += 1
    table.cell(hud, 0, r, "History sample", text_color = dim, bgcolor = bg, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, r, str.tostring(completedN) + " episodes", text_color = txt, bgcolor = bg, text_size = sz, text_halign = text.align_right)
    r += 1
    table.cell(hud, 0, r, "Estimator", text_color = dim, bgcolor = bg, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, r, estShort, text_color = txt, bgcolor = bg, text_size = sz, text_halign = text.align_right)
    r += 1
    table.cell(hud, 0, r, "Regime sample", text_color = dim, bgcolor = bg, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, r, str.tostring(array.size(pctBuf)) + " in " + str.tostring(lookbackLengthInput) + lbUnitShort, text_color = txt, bgcolor = bg, text_size = sz, text_halign = text.align_right)
    r += 1

    table.cell(hud, 0, r, "Describes chart history · not a forecast", text_color = frameCol, bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(hud, 1, r, "", bgcolor = bg)

// ---------------------------------------------------------------------------
// Standing disclosure — carried in the Data Window, with no data-off switch.
// ---------------------------------------------------------------------------
plot(na, title = "Volatility-regime episodes · describes chart history · not a forecast", display = display.data_window)
````
