# EMA Pullback Signals (MTF) [bitpunk]

- url: https://www.tradingview.com/script/UoXQzOt2/
- type: indicator
- pine_id: PUB;3484b23dc5a942f2979663f815ddf8dc
- version: 1.0

## Description

EMA Pullback Signals (MTF) [bitpunk]
Multi-timeframe EMA pullback signals with Fast and Trend zones, momentum-confirmed reclaims, and ATR-based spacing between new pullbacks.

[b]1. THE IDEA[/b]

A visual entry tool for swing and trend-continuation trading. A higher setup timeframe defines direction and two separate EMA pullback zones; the current chart confirms recovery. A reclaim means a real candle closes beyond the active zone's directional edge after a pullback touch, with price progress and momentum confirmation.

[i]Read the setup, wait for a pullback, then assess the confirmed recovery.[/i]

[b]2. HOW IT WORKS[/b]

[list=1]
[*][b]Context[/b] — Direction comes from completed setup price relative to EMA36 and its five-bar slope. EMA14 and EMA36 each have a separate zone, defaulting to ±0.25 ATR14.
[*][b]Pullback[/b] — Price first departs efficiently beyond both zones, then retests either one. A deeper retest can upgrade a Fast-zone recovery to the Trend zone without restarting its window.
[*][b]Signal[/b] — A real candle closes beyond the active zone edge with a directional body and price progress, confirmed by either a strong candle closing near its directional extreme or improving MACD histogram with aligned Heikin-Ashi direction.
[/list]

One entry or extension skip consumes that recovery attempt. A new contact with either zone can start another attempt after a pullback of at least 0.5 setup ATR from the best prior confirmed close since consumption. The preceding chart candle must not have overlapped the newly contacted zone. Setup direction must remain valid and setup departure efficiency must be at least 0.25. Continuous contact cannot repeat entries.

The ATR scale is frozen at consumption; favorable closes update the reference. Pending retouches do not extend their window; a newly qualified attempt gets its own. Heikin-Ashi supplies direction, never a synthetic entry price.

[b]3. DESIGN FOCUS[/b]

The indicator separates shallower Fast-zone pullbacks from deeper Trend-zone pullbacks while keeping trend direction on a higher timeframe and reclaim confirmation on the current chart. Fresh contact and ATR-based spacing allow another meaningful pullback to qualify after an earlier signal, including a later Trend-zone touch after a Fast-zone entry. The design focuses on the complete trend-continuation recovery sequence; its signal conditions do not measure the probability of a successful trade.

[b]4. READING THE CHART[/b]

[list]
[*][b]L / S[/b] — Close-confirmed long or short entry indications.
[*][b]Ribbons[/b] — Smoothed trend guides, not exact touch or entry boundaries. Read precise levels in Data Window.
[*][b]Reclaim observation[/b] — The pending recovery area and level; a reference, not a protective stop.
[*][b]Panel[/b] — Setup direction, current state and entry/setup timeframes.
[/list]

Band Effects and Signal Effects offer Normal / Enhanced: lighter visuals or stronger glow and signal emphasis, with identical events.

[b]5. SETUP AND ALERTS[/b]

Use standard candlesticks with a strictly higher setup timeframe. Auto includes 15m → 1h, 1h → 4h, 1D → 1W and 1W → 1M. Unsupported pairs disable signals. Defaults are Confirmation Window 7 setup intervals, Max Entry Extension 1 ATR, Zone Width 0.25 ATR per side and Rearm Distance 0.5 ATR. Seven approximates EMA14's decay time; the reset distance equals one full default zone width. These are coherent reference scales, not a claim of optimal signal quality.

Create one alert using [b]Any alert() function call[/b] for both directions:

15m ▲ LONG @123.45
1h ▼ SHORT @123.45

Alerts show the entry timeframe and real confirmation close, at realtime bar close. Recreate alerts after script or calculation-setting changes. Separate Long Entry / Short Entry conditions use TradingView's native interval notation.

[i]Designed for trend continuation; sideways conditions can produce whipsaws. Setup references use completed candles. Visual ribbons can move while the chart candle is open. Entry indications support discretionary analysis and do not provide automatic exits or execution.[/i]

## Source Code

````pine
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Bitpunk
//@version=6
indicator("EMA Pullback Signals (MTF) [bitpunk]", shorttitle="bitpunk.pb-reclaim", overlay=true, max_lines_count=1, max_boxes_count=1, max_labels_count=1)
// Independent public definitions and frozen controls: research/rearm-design.md.

// Inputs
int pullbackLength = input.int(14, "Pullback Length", minval=2, maxval=200, tooltip="Length of the fast EMA on the setup timeframe. Its zone accepts shallower pullbacks; this length also sets the departure-efficiency lookback. Lower values react sooner but follow more short-term movement; higher values make the reference slower.")
int trendLength = input.int(36, "Trend Length", minval=5, maxval=300, tooltip="Length of the slow EMA on the setup timeframe. Price position and its slope define direction, and its zone also accepts deeper pullbacks. Must be greater than Pullback Length. Higher values produce a slower-moving trend reference.")
string setupChoice = input.string("auto", "Setup Timeframe", options=["auto", "5m", "15m", "1h", "4h", "1D", "1W", "1M"], tooltip="Entries use the chart timeframe; setup must be higher. Auto pairs include 15m / 1h, 1h / 4h, 1D / 1W and 1W / 1M.\n\nFor manual intraday or 1D setup, use an intraday chart that divides evenly into it. Weekly/monthly setup also accepts 1D/1W charts when setup is higher. Only completed setup candles are used. Invalid or unsupported pairs disable entries; check the panel.")
int windowBars = input.int(7, "Confirmation Window", minval=1, maxval=30, tooltip="How long a touched zone can produce an entry, counted in setup intervals from its first touch, not chart candles. Seven intervals approximate one EMA14 decay time. A shorter window expires opportunities sooner; it does not speed up confirmation. Pending retouches and Fast-to-Trend upgrades never restart the window. A newly qualified pullback gets its own window.")
float maxEntryATR = input.float(1.0, "Max Entry Extension", minval=0.25, maxval=3, step=0.25, tooltip="Maximum signal-close distance beyond the active zone edge, measured in completed setup ATR14. Lower values skip more distant confirmations; higher values retain them.\n\nZone Width and this limit add together: defaults 0.25 + 1.0 allow a close up to 1.25 setup ATR from the active EMA. A recovery beyond the cap consumes that attempt. Another attempt needs a fresh zone contact and the Rearm Distance.")
float zoneWidth = input.float(0.25, "Zone Width (ATR)", minval=0.05, maxval=1.0, step=0.05, tooltip="Half-width of each setup EMA zone, in completed setup ATR14. At 0.25, the zone extends 0.25 ATR above and below the EMA, for a total width of 0.5 ATR. A wider zone accepts shallower touches but moves the departure and reclaim edges farther out. It also increases the total distance allowed from the EMA when Max Entry Extension is unchanged. This changes signals, not just appearance.")
float rearmATR = input.float(0.5, "Rearm Distance (ATR)", minval=0.1, maxval=2.0, step=0.1, tooltip="Minimum new pullback after an entry or extension skip, measured in setup ATR14 frozen at that recovery. Longs measure from the highest prior confirmed close since that recovery to the new candle's low; shorts mirror this.\n\nThe candle must newly contact Fast or Trend: the preceding candle must not have overlapped that same zone. Continuous contact cannot repeat signals. Higher values require deeper new pullbacks; lower values accept smaller revisits. The first opportunity still needs departure beyond both zones.")
bool showZone = input.bool(true, "Reference Zone", group="Display", tooltip="Show the two smoothed visual references for shallower (Fast) and deeper (Trend) pullbacks. They deliberately differ from the exact setup zones; touching a drawn ribbon alone does not guarantee a signal. Use the Data Window for exact boundaries. Turning this off keeps signals, alerts and the active reclaim observation enabled.")
string panelChoice = input.string("bottom", "Status Panel", options=["none", "bottom", "top"], group="Display", tooltip="Shows setup direction, the latest confirmed state and the entry/setup timeframe pair. Use it to check why entries are waiting or a timeframe pair is invalid. None hides only the panel.")
string bandEffects = input.string("Enhanced", "Band Effects", options=["Normal", "Enhanced"], group="Display", tooltip="Normal uses narrow, soft bands; Enhanced adds a wider glow. Choose Normal for a quieter chart or Enhanced to make the references more prominent. This setting changes appearance only.")
string signalEffects = input.string("Enhanced", "Signal Effects", options=["Normal", "Enhanced"], group="Display", tooltip="Normal uses small L/S labels suited to charts with other indicators. Enhanced uses larger labels plus a glow and pin at the signal candle closing price. Both show the same confirmed entries and alerts; the pin is a visual reference, not a separate trigger.")
color bullColor = input.color(color.rgb(0, 194, 255), "Bull", inline="theme", group="Theme Colors", tooltip="Bull sets long-side colors; Bear sets short-side colors. Bands, panel accents and entry marks derive from these two colors, with higher contrast for signals. Change them to match your chart theme.")
color bearColor = input.color(color.rgb(255, 56, 100), "Bear", inline="theme", group="Theme Colors", tooltip="Bull sets long-side colors; Bear sets short-side colors. Bands, panel accents and entry marks derive from these two colors, with higher contrast for signals. Change them to match your chart theme.")

// Helpers
f_dim(color source, float strength) =>
    color.from_gradient(strength, 0, 1, chart.bg_color, source)
f_ink(color source) =>
    float luminance = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
    luminance > 128 ? color.from_gradient(0.35, 0, 1, source, chart.fg_color) : source
f_signal(color source) =>
    float luminance = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
    color.from_gradient(luminance > 128 ? 0.50 : 0.18, 0, 1, source, chart.fg_color)

f_tf(string tf) =>
    float seconds = timeframe.in_seconds(tf)
    seconds < 60 ? str.tostring(seconds) + "s" : seconds < 3600 ? str.tostring(seconds / 60) + "m" : seconds < 86400 ? str.tostring(seconds / 3600) + "h" : tf == "D" ? "1D" : tf == "W" ? "1W" : tf == "M" ? "1M" : tf

// Fixed convenience pairs, not a search for the best-performing timeframe.
f_auto(float seconds) =>
    string target = timeframe.isdaily and timeframe.multiplier == 1 ? "W" : timeframe.isweekly and timeframe.multiplier == 1 ? "M" : seconds <= 60 ? "5" : seconds <= 300 ? "15" : seconds <= 900 ? "60" : seconds <= 3600 ? "240" : seconds <= 14400 ? "D" : ""
    float targetSeconds = timeframe.in_seconds(target)
    bool compatible = target == "W" or target == "M" or (timeframe.isminutes and targetSeconds > seconds and targetSeconds % seconds == 0)
    compatible ? target : timeframe.period

f_setup(string choice) =>
    switch choice
        "5m" => "5"
        "15m" => "15"
        "1h" => "60"
        "4h" => "240"
        "1D" => "D"
        "1W" => "W"
        "1M" => "M"
        => timeframe.period

// Display-only approximation from continuous ENTRY prices, not a filtered setup staircase.
// Match the setup EMA decay per unit time; two short causal passes soften local bends.
// Calendar durations are nominal for this cosmetic time scale, never signal calculations.
f_ribbon(float target, float alpha) =>
    var float estimate = na
    var float soft = na
    var float silk = na
    estimate := na(target) ? na : na(estimate[1]) ? target : estimate[1] + alpha * (target - estimate[1])
    soft := na(estimate) ? na : na(soft[1]) ? estimate : soft[1] + 0.5 * (estimate - soft[1])
    silk := na(soft) ? na : na(silk[1]) ? soft : silk[1] + 0.5 * (soft - silk[1])
    silk

// Theme palette
// Theme/input changes restart the script; these four colors are fixed per run.
var color bullInk = f_ink(bullColor)
var color bearInk = f_ink(bearColor)
var color bullSignal = f_signal(bullColor)
var color bearSignal = f_signal(bearColor)

// Only completed setup references leave this function; no developing setup gate.
f_context() =>
    float fast = ta.ema(close, pullbackLength)
    float slow = ta.ema(close, trendLength)
    float atr = ta.atr(14)
    float path = ta.sma(math.abs(close - close[1]), pullbackLength) * pullbackLength
    float er = path > 0 ? math.min(1, math.abs(close - close[pullbackLength]) / path) : 0
    bool ready = bar_index >= math.max(trendLength + 5, math.max(pullbackLength, 14)) and atr > 0 and not na(path) and not na(open) and not na(high) and not na(low) and not na(close)
    int side = ready and close > slow and slow > slow[5] ? 1 : ready and close < slow and slow < slow[5] ? -1 : 0
    float upper = fast + zoneWidth * atr
    float lower = fast - zoneWidth * atr
    float trendUpper = slow + zoneWidth * atr
    float trendLower = slow - zoneWidth * atr
    [side[1], upper[1], lower[1], atr[1], slow[1], er[1], bar_index[1], trendUpper[1], trendLower[1]]

float chartSeconds = timeframe.in_seconds()
bool autoMode = setupChoice == "auto"
string setupTf = autoMode ? f_auto(chartSeconds) : f_setup(setupChoice)
float setupSeconds = timeframe.in_seconds(setupTf)
bool higher = not na(chartSeconds) and setupSeconds > chartSeconds
bool evenFrame = higher and setupSeconds % chartSeconds == 0
bool calendarSetup = setupTf == "W" or setupTf == "M"
bool calendarChart = timeframe.isminutes or (timeframe.isdaily and timeframe.multiplier == 1) or (timeframe.isweekly and timeframe.multiplier == 1)
bool validFrame = higher and (calendarSetup ? calendarChart : timeframe.isintraday and evenFrame)
bool validChart = chart.is_standard and trendLength > pullbackLength and validFrame
[hs, upper, lower, setupATR, _, setupER, setupIndex, trendUpper, trendLower] = request.security(syminfo.tickerid, setupTf, f_context(), lookahead=barmerge.lookahead_on)

// Entry transforms use real chart OHLC. HA is a direction measure, not a price.
bool pricesReady = not na(open) and not na(high) and not na(low) and not na(close)
var float macdFast = na
var float macdSlow = na
var float macdSignal = na
macdFast := not pricesReady ? na : na(macdFast[1]) ? close : macdFast[1] + 2.0 / 13 * (close - macdFast[1])
macdSlow := not pricesReady ? na : na(macdSlow[1]) ? close : macdSlow[1] + 2.0 / 27 * (close - macdSlow[1])
float macd = macdFast - macdSlow
macdSignal := not pricesReady ? na : na(macdSignal[1]) ? macd : macdSignal[1] + 2.0 / 10 * (macd - macdSignal[1])
float histogram = macd - macdSignal
float haClose = pricesReady ? (open + high + low + close) / 4 : na
var float haOpen = na
haOpen := not pricesReady ? na : na(haOpen[1]) or na(haClose[1]) ? (open + close) / 2 : (haOpen[1] + haClose[1]) / 2

var int zoneDepth = 0
var int phase = 0
var int episodeSide = 0
var int firstSetupIndex = na
var int touchTime = na
var float touchedExtreme = na
// Spacing survives departure/expiry; only invalid context or direction clears it.
var float resetATR = na
var float recoveryPeak = na
var bool previousFastTouch = false
var bool previousTrendTouch = false
var string status = "Waiting for setup history"
var int displaySide = 0
var float watchLevel = na
var float watchExtreme = na
var int watchTime = na
bool longSignal = false
bool shortSignal = false
if barstate.isconfirmed
    watchLevel := na
    watchExtreme := na
    watchTime := na
    displaySide := validChart ? nz(hs) : 0
    if not validChart or not pricesReady or na(setupATR) or setupATR <= 0 or na(setupIndex) or na(setupER) or na(upper) or na(lower) or na(trendUpper) or na(trendLower)
        phase := 0
        episodeSide := 0
        resetATR := na
        recoveryPeak := na
        previousFastTouch := false
        previousTrendTouch := false
        status := not chart.is_standard ? "Use standard candles" : trendLength <= pullbackLength ? "Check average lengths" : not higher ? "Choose a higher setup" : not validFrame ? "Use compatible timeframes" : "Waiting for setup history"
    else if hs == 0
        phase := 0
        episodeSide := 0
        resetATR := na
        recoveryPeak := na
        previousFastTouch := false
        previousTrendTouch := false
        status := "No clear setup direction"
    else
        if hs != episodeSide
            phase := 0
            episodeSide := hs
            resetATR := na
            recoveryPeak := na
            previousFastTouch := false
            previousTrendTouch := false
        if phase == 2 and setupIndex - firstSetupIndex >= windowBars
            phase := 0
            status := "Recovery expired"
        bool separated = hs == 1 ? low > math.max(upper, trendUpper) : high < math.min(lower, trendLower)
        bool overlapsFast = low <= upper and high >= lower
        bool overlapsTrend = low <= trendUpper and high >= trendLower
        bool overlaps = overlapsFast or overlapsTrend
        bool freshTouch = (overlapsFast and not previousFastTouch) or (overlapsTrend and not previousTrendTouch)
        // Use only earlier closes as the swing reference; no intrabar-order guess.
        bool spaced = na(resetATR) or hs * (recoveryPeak - (hs == 1 ? low : high)) >= rearmATR * resetATR
        bool newPullback = overlaps and (na(resetATR) or (freshTouch and spaced and setupER >= 0.25))
        if (phase == 1 or phase == 3) and newPullback
            phase := 2
            zoneDepth := overlapsTrend ? 2 : 1
            firstSetupIndex := setupIndex
            touchTime := time
            touchedExtreme := hs == 1 ? low : high
        if phase == 2
            // Upgrade in the same episode, preserving original identity and expiry.
            if overlapsTrend
                zoneDepth := 2
            touchedExtreme := hs == 1 ? math.min(touchedExtreme, low) : math.max(touchedExtreme, high)
            float edge = zoneDepth == 2 ? (hs == 1 ? trendUpper : trendLower) : (hs == 1 ? upper : lower)
            bool priceRecovery = hs * (close - edge) > 0 and hs * (close - open) > 0 and hs * (close - close[1]) > 0
            float spread = high - low
            bool impulse = spread > 0 and hs * (close - open) / spread >= 0.5 and (hs == 1 ? close - low : high - close) / spread >= 0.75
            bool macdImproving = not na(histogram[1]) and hs * (histogram - histogram[1]) > 0
            bool haAligned = hs * (haClose - haOpen) > 0
            bool momentumRecovery = impulse or (macdImproving and haAligned)
            if priceRecovery and momentumRecovery
                phase := 3
                resetATR := setupATR
                recoveryPeak := close
                bool extended = hs * (close - edge) / setupATR > maxEntryATR
                longSignal := not extended and hs == 1
                shortSignal := not extended and hs == -1
                status := extended ? "Extended recovery skipped" : "Entry confirmed"
            else
                status := hs * (close - edge) <= 0 ? "Waiting for reclaim" : "Waiting for momentum"
            if phase == 2
                watchLevel := edge
                watchExtreme := touchedExtreme
                watchTime := touchTime
            // Last separated candle can confirm before the next episode is armed.
            if phase == 2 and separated and time > touchTime
                phase := setupER >= 0.25 ? 1 : 0
                watchLevel := na
                watchExtreme := na
                watchTime := na
                status := phase == 1 ? "Waiting for pullback" : "Waiting for a cleaner move"
        else if phase == 0
            if separated and setupER >= 0.25
                phase := 1
                status := "Waiting for pullback"
            else
                status := setupER >= 0.25 ? "Waiting for departure" : "Waiting for a cleaner move"
        else if phase == 3
            status := setupER < 0.25 ? "Waiting for a cleaner move" : not freshTouch ? "Waiting for a fresh touch" : not spaced ? "Waiting for a deeper pullback" : "Waiting for pullback"
        else
            status := "Waiting for pullback"
        if not na(resetATR)
            recoveryPeak := hs == 1 ? math.max(recoveryPeak, close) : math.min(recoveryPeak, close)
        previousFastTouch := overlapsFast
        previousTrendTouch := overlapsTrend

color accent = displaySide == 1 ? bullColor : displaySide == -1 ? bearColor : chart.fg_color

// Visual references
float visualFraction = validChart ? math.min(1, chartSeconds / setupSeconds) : 1
var float fastAlpha = 1 - math.pow(1 - 2.0 / (pullbackLength + 1), visualFraction)
var float trendAlpha = 1 - math.pow(1 - 2.0 / (trendLength + 1), visualFraction)
// Width follows known setup volatility with a one-setup-interval half-life.
var float widthAlpha = 1 - math.pow(0.5, visualFraction)
float visualPrice = validChart and pricesReady ? close : na
// This gate is fixed for the entire run. Enabled filters still process every bar,
// including missing data, so their history/reset behavior stays unchanged.
bool renderZone = showZone and validChart
float fastFlow = renderZone ? f_ribbon(visualPrice, fastAlpha) : na
float trendFlow = renderZone ? f_ribbon(visualPrice, trendAlpha) : na
float widthFlow = renderZone ? f_ribbon(validChart and pricesReady ? zoneWidth * setupATR : na, widthAlpha) : na
bool ribbons = renderZone and pricesReady and not na(widthFlow)
// Enhanced effects widen the existing gradient masks; no extra halo plots.
float glowWidth = widthFlow * (bandEffects == "Enhanced" ? 1.7 : 1.0)
float fastVisualUpper = ribbons ? fastFlow + glowWidth : na
float fastVisualLower = ribbons ? fastFlow - glowWidth : na
float trendVisualUpper = ribbons ? trendFlow + glowWidth : na
float trendVisualLower = ribbons ? trendFlow - glowWidth : na
color ribbonInk = displaySide == 1 ? bullInk : displaySide == -1 ? bearInk : chart.fg_color
// Invisible mask edges only support fills; constant na avoids color channels.
fastTop = plot(fastVisualUpper, "Fast Ribbon Upper", color=na, style=plot.style_linebr, display=display.pane)
fastMid = plot(ribbons ? fastFlow : na, "Fast Ribbon Spine", color=color.new(ribbonInk, 48), style=plot.style_linebr, display=display.pane)
fastBottom = plot(fastVisualLower, "Fast Ribbon Lower", color=na, style=plot.style_linebr, display=display.pane)
trendTop = plot(trendVisualUpper, "Trend Ribbon Upper", color=na, style=plot.style_linebr, display=display.pane)
trendMid = plot(ribbons ? trendFlow : na, "Setup Context", color=color.new(ribbonInk, displaySide == 0 ? 64 : 14), linewidth=2, style=plot.style_linebr, display=display.pane)
trendBottom = plot(trendVisualLower, "Trend Ribbon Lower", color=na, style=plot.style_linebr, display=display.pane)
color ribbonCore = color.new(ribbonInk, 78)
color ribbonRim = color.new(ribbonInk, 98)
fill(fastTop, fastMid, fastVisualUpper, fastFlow, ribbonRim, ribbonCore, title="Fast Upper Gradient", fillgaps=false)
fill(fastMid, fastBottom, fastFlow, fastVisualLower, ribbonCore, ribbonRim, title="Fast Lower Gradient", fillgaps=false)
fill(trendTop, trendMid, trendVisualUpper, trendFlow, ribbonRim, ribbonCore, title="Trend Upper Gradient", fillgaps=false)
fill(trendMid, trendBottom, trendFlow, trendVisualLower, ribbonCore, ribbonRim, title="Trend Lower Gradient", fillgaps=false)

// Exact levels and entry markers
// Exact calculation levels are intentionally restricted to Data Window; no raw boundary strokes.
plot(upper, "Fast Exact Upper", display=display.data_window)
plot(lower, "Fast Exact Lower", display=display.data_window)
plot(trendUpper, "Trend Exact Upper", display=display.data_window)
plot(trendLower, "Trend Exact Lower", display=display.data_window)
// Layered, fixed-cost historical marks: the glow locates the real confirmation close.
bool enhancedSignal = signalEffects == "Enhanced"
bool normalSignal = signalEffects == "Normal"
// Both directions share the same absolute-price glyph geometry and fixed sizes.
color entryAccent = longSignal ? bullColor : bearColor
color entryInk = longSignal ? bullSignal : bearSignal
plotshape(enhancedSignal and (longSignal or shortSignal) ? close : na, "Entry Glow", shape.circle, location.absolute, color.new(entryAccent, 78), size=size.large, display=display.pane)
plotshape(enhancedSignal and (longSignal or shortSignal) ? close : na, "Entry Close Pin", shape.circle, location.absolute, entryInk, size=size.tiny, display=display.pane)
plotshape(enhancedSignal and longSignal, "Long Entry", shape.labelup, location.belowbar, bullSignal, text="L", textcolor=chart.bg_color, size=size.small, display=display.pane)
plotshape(normalSignal and longSignal, "Long Normal", shape.labelup, location.belowbar, bullSignal, text="L", textcolor=chart.bg_color, size=size.tiny, display=display.pane)
plotshape(enhancedSignal and shortSignal, "Short Entry", shape.labeldown, location.abovebar, bearSignal, text="S", textcolor=chart.bg_color, size=size.small, display=display.pane)
plotshape(normalSignal and shortSignal, "Short Normal", shape.labeldown, location.abovebar, bearSignal, text="S", textcolor=chart.bg_color, size=size.tiny, display=display.pane)
plot(watchLevel, "Reclaim Edge", display=display.data_window)
plot(longSignal ? close : na, "Long Entry Close", display=display.data_window)
plot(shortSignal ? close : na, "Short Entry Close", display=display.data_window)

// Alerts
// Signal alerts are independent of all display settings. Select one alert route.
alertcondition(longSignal, "Long Entry", "{{interval}} ▲ LONG @{{close}}")
alertcondition(shortSignal, "Short Entry", "{{interval}} ▼ SHORT @{{close}}")
// Build the formatted message only for a realtime, close-confirmed entry event.
if barstate.isrealtime and barstate.isconfirmed and (longSignal or shortSignal)
    alert(f_tf(timeframe.period) + (longSignal ? " ▲ LONG @" : " ▼ SHORT @") + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

// Active recovery observation
var box watchBox = na
var line watchLine = na
var label watchTag = na
bool watching = not na(watchLevel) and not na(watchExtreme) and validChart
if barstate.islast
    if watching
        int right = time_close
        if na(watchBox)
            watchBox := box.new(watchTime, math.max(watchLevel, watchExtreme), right, math.min(watchLevel, watchExtreme), xloc=xloc.bar_time, border_color=f_dim(accent, 0.16), bgcolor=f_dim(accent, 0.035))
            watchLine := line.new(watchTime, watchLevel, right, watchLevel, xloc=xloc.bar_time, color=f_dim(accent, 0.7))
            watchTag := label.new(right, watchLevel, "", xloc=xloc.bar_time, color=f_dim(accent, 0.06), textcolor=ribbonInk, size=size.small)
        box.set_lefttop(watchBox, watchTime, math.max(watchLevel, watchExtreme))
        box.set_rightbottom(watchBox, right, math.min(watchLevel, watchExtreme))
        box.set_border_color(watchBox, f_dim(accent, 0.16))
        box.set_bgcolor(watchBox, f_dim(accent, 0.035))
        line.set_xy1(watchLine, watchTime, watchLevel)
        line.set_xy2(watchLine, right, watchLevel)
        line.set_color(watchLine, f_dim(accent, 0.7))
        label.set_xy(watchTag, right, watchLevel)
        label.set_color(watchTag, f_dim(accent, 0.06))
        label.set_textcolor(watchTag, ribbonInk)
        label.set_style(watchTag, displaySide == 1 ? label.style_label_lower_right : label.style_label_upper_right)
        label.set_text(watchTag, (zoneDepth == 2 ? "Trend reclaim " : "Fast reclaim ") + (displaySide == 1 ? "> " : "< ") + str.tostring(watchLevel, format.mintick))
    else
        box.delete(watchBox)
        line.delete(watchLine)
        label.delete(watchTag)
        watchBox := na
        watchLine := na
        watchTag := na

// Status panel
// One understated panel treatment, independent of Band/Signal Effects.
var table panel = na
if barstate.islast
    if panelChoice == "none"
        table.delete(panel)
        panel := na
    else
        if na(panel)
            panel := table.new(panelChoice == "top" ? position.top_right : position.bottom_right, 1, 3, bgcolor=f_dim(chart.fg_color, 0.025), frame_color=f_dim(chart.fg_color, 0.12), frame_width=1, border_width=0)
        bool setupReady = validChart and not na(setupATR) and setupATR > 0 and not na(setupER) and not na(setupIndex) and setupIndex >= math.max(trendLength + 5, math.max(pullbackLength, 14))
        string direction = not validChart ? "SETUP UNAVAILABLE" : not setupReady ? "WAITING FOR SETUP" : displaySide == 1 ? "LONG SETUP" : displaySide == -1 ? "SHORT SETUP" : "NO CLEAR DIRECTION"
        var string mapping = f_tf(timeframe.period) + " ENTRY  /  " + f_tf(setupTf) + " SETUP" + (autoMode ? " · AUTO" : "")
        string panelStatus = validChart and not setupReady ? "Waiting for setup history" : status
        color headingInk = setupReady and displaySide != 0 ? ribbonInk : f_dim(chart.fg_color, 0.66)
        color headingFill = f_dim(setupReady and displaySide != 0 ? accent : chart.fg_color, 0.06)
        table.cell(panel, 0, 0, "  " + direction + "  ", bgcolor=headingFill, text_color=headingInk, text_size=size.normal, text_halign=text.align_left)
        table.cell(panel, 0, 1, "  " + panelStatus + "  ", text_color=watching or longSignal or shortSignal ? ribbonInk : f_dim(chart.fg_color, 0.86), text_size=size.normal, text_halign=text.align_left)
        table.cell(panel, 0, 2, "  " + mapping + "  ", text_color=f_dim(chart.fg_color, 0.54), text_size=size.small, text_halign=text.align_left)
````
