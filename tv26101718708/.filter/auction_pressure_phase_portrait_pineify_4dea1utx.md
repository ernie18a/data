# Auction Pressure Phase Portrait [Pineify]

- url: https://www.tradingview.com/script/4DEa1uTx-Auction-Pressure-Phase-Portrait-Pineify/
- type: indicator
- pine_id: PUB;75888bbf84d9442996e72ce6c2aedb46
- version: 1.0

## Description

[b]Overview[/b]
This auction pressure indicator retains two OHLCV coordinates: direction D and wick rejection R. A ribbon tracks their separation, while a phase portrait shows the latest confirmed trajectory. It describes candle behavior beyond isolated patterns.

[b]Problem Definition[/b]
A bullish body, a lower wick and a busy volume bar answer different questions. The body records open-to-close displacement; the wick records an excursion that did not survive the close. A single candle label cannot distinguish repeated displacement from a one-bar rejection. Adding both into one score can also hide opposing evidence. The design keeps direction and rejection visible separately and asks whether either has persisted enough to define a phase.

[b]Design Rationale[/b]
The larger of current true range and prior average true range bounds excursions and restrains tiny candles. Prior median volume prevents the current spike from setting its own baseline. Capped square-root weighting reduces thin-volume evidence and limits spike influence. Separate half-life memories replace immediate pattern votes. Entry/release hysteresis and consecutive candidate closes reduce phase chatter, at the cost of delayed recognition. This retains disagreement that one blended oscillator would erase.

[b]Key Features[/b]
[list]
[*]Bounded D and R memories on a -100 to +100 scale.
[*]Accumulation, rejection, mixed pressure and balance phases with confirmed transitions.
[*]Recent phase trail, live participation diagnostics and data-interruption alerts.
[/list]

[b]How It Works[/b]
The prior window requires valid OHLC and positive volume. Its mean true range and median volume exclude the current bar. D blends 65% of close minus open with 35% of twice close minus high minus low; R is lower wick minus upper wick. Both divide by the range scale and receive the square root of the ratio of capped RVOL to the full-weight multiple. Zero-seeded memories blend old and new samples using the half-life. Display waits for memory maturity.

On confirmed closes, both small coordinates propose balance. Strong R meeting the dominance ratio proposes rejection first; otherwise strong D with supportive D+R proposes accumulation. Existing phases may hold above the release level; other cases propose mixed pressure. Consecutive candidates confirm a phase. A rejection flip must oppose the last accumulation since balance or a previous flip. Invalid data reset memory, phase and trail.

[b]How Multiple Indicators Work Together[/b]
Range scaling makes candle geometry comparable; volume weighting controls evidence entering both memories. Decay retains the path, and phase rules compare the coordinates. Removing R hides rejection dominance; blending D and R hides disagreement; removing coverage lets stale pressure survive missing participation. Volume weights evidence without assigning direction.

[b]Trading Ideas and Insights[/b]
Accumulation invites checking whether price accepts levels in that direction. A rejection takeover calls for inspecting the level and subsequent closes before considering a reversal. Ribbon width measures coordinate separation, not momentum strength. Balance means small remembered candle pressures; it establishes neither fair value nor a price range.

[b]Unique Aspects[/b]
Compared with static candle patterns or one blended pressure oscillator, the contribution is the retained two-coordinate path and its context-aware transitions. Rejection alone is distinguished from a flip against remembered accumulation. Data failure breaks that context. The portrait exposes agreement, opposition and return toward the origin without treating quadrant location as a probability.

[b]How to Use[/b]
Start with standard candles on liquid stocks, futures or crypto, typically 5m-1D, and wait for baseline and memory maturity. Read the D line and D-to-R ribbon before consulting the inset: D runs left/right and R up/down; @ is latest and fading dots are older confirmed points. Grid cells are quantized in 25-point steps and overlapping points keep the newest mark. Tables show the latest state, not the historical bar under the cursor.

[b]Customization[/b]
The baseline controls range and volume context; half-life controls memory decay, and maturity controls the startup gate. The full-weight volume multiple sets saturation. Entry, lower release, rejection dominance and candidate-close count tune phase persistence; release must remain below entry. Defaults are starting choices, not universal optima. Hide the rejection line, halo, background, markers, portrait or summary as needed; the core ribbon retains both coordinates.

[b]Assumptions and Limitations[/b]
D and R are related candle proxies, not independent measurements or true buyer/seller order flow. Gaps enlarge true range but receive no separate directional vote. Missing or zero volume require a complete new baseline and memory warm-up. Smoothing and confirmation lag; settings and loaded history affect the path. Confirmed curves and phases hold intrabar, while live RVOL diagnostics can change. Feed revisions can alter historical results. Wick rejection may precede continuation. No execution, profitability, forecast accuracy or immunity to repainting is established.

[b]Conclusion[/b]
Auction Pressure Phase Portrait separates remembered displacement from rejection. Read its confirmed phases as candle-context evidence, then assess price structure and risk before considering a trade.

## Source Code

````pine
//@version=6
indicator("Auction Pressure Phase Portrait [Pineify]", overlay=false, precision=1, max_bars_back=500)

// Independent OHLCV proxy: direction and wick rejection retain separate memories.
// Baseline failure: one candle cannot show sustained pressure or a rejection takeover.
// Convex decay preserves bounded coordinates; confirmed hysteresis defines phases.
// Ribbon width is coordinate separation; the inset maps D horizontally and R vertically.
string coreGroup = "Pressure model"
int baselineLength = input.int(40, "Prior range / volume baseline", minval=10, maxval=200, group=coreGroup)
float halfLife = input.float(5.0, "Memory half-life (bars)", minval=1.0, maxval=30.0, step=0.5, group=coreGroup)
int maturityBars = input.int(10, "Valid memory samples before display", minval=2, maxval=100, group=coreGroup)
float volumeCap = input.float(2.25, "Relative volume at full weight", minval=1.0, maxval=9.0, step=0.25, group=coreGroup)
string phaseGroup = "Phase confirmation"
float enterLevel = input.float(0.22, "Phase entry pressure", minval=0.05, maxval=0.80, step=0.01, group=phaseGroup)
float releaseLevel = input.float(0.10, "Phase release / balance pressure", minval=0.01, maxval=0.50, step=0.01, group=phaseGroup)
float rejectionRatio = input.float(1.10, "Rejection dominance ratio", minval=1.0, maxval=3.0, step=0.05, group=phaseGroup)
int confirmationBars = input.int(2, "Consecutive candidate closes", minval=1, maxval=10, group=phaseGroup)
string visualGroup = "Visual layers"
bool showRejection = input.bool(true, "Rejection coordinate line", group=visualGroup)
bool showGlow = input.bool(true, "Direction trace halo", group=visualGroup)
bool showWash = input.bool(false, "Confirmed phase background", group=visualGroup)
bool showMarkers = input.bool(true, "Phase transition markers", group=visualGroup)
bool showPortrait = input.bool(true, "Latest two-dimensional phase trail", group=visualGroup)
bool showSummary = input.bool(true, "Summary table", group=visualGroup)
int trailLength = input.int(12, "Portrait confirmed points", minval=3, maxval=24, group=visualGroup)

if barstate.isfirst and releaseLevel >= enterLevel
    runtime.error("Phase release must be below phase entry.")

color upColor = color.rgb(0, 151, 136)
color downColor = color.rgb(222, 83, 69)
color rejectionColor = color.rgb(133, 91, 205)
color neutralColor = color.rgb(119, 130, 145)
color balanceColor = color.rgb(57, 125, 181)

phaseName(int value) =>
    switch value
        1 => "Up accumulation"
        -1 => "Down accumulation"
        2 => "Upward rejection"
        -2 => "Downward rejection"
        0 => "Auction balance"
        3 => "Mixed pressure"
        => "Warming / unavailable"

phaseColor(int value) =>
    value == 1 ? upColor : value == -1 ? downColor : math.abs(value) == 2 ? rejectionColor : value == 0 ? balanceColor : neutralColor

bool priceValid = not na(open) and not na(high) and not na(low) and not na(close) and high >= math.max(open, close) and low <= math.min(open, close) and high >= low
bool volumeValid = not na(volume) and volume > 0
float currentRange = priceValid ? ta.tr(true) : 0.0
float priorRange = ta.sma(currentRange, baselineLength)[1]
float priorVolume = ta.median(volume, baselineLength)[1]
float priorCoverage = ta.sma(priceValid and volumeValid ? 1.0 : 0.0, baselineLength)[1]
bool sampleValid = priceValid and volumeValid and not na(close[1]) and not na(priorRange) and not na(priorVolume) and priorVolume > 0 and not na(priorCoverage) and priorCoverage >= 0.999999
float priceScale = sampleValid ? math.max(math.max(currentRange, priorRange), syminfo.mintick) : na
float candleRange = high - low
float body = close - open
float closeLocation = priceValid and candleRange > 0 ? (2.0 * close - high - low) / candleRange : 0.0
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float relativeVolume = sampleValid ? volume / priorVolume : na
float participation = sampleValid ? math.sqrt(math.min(relativeVolume, volumeCap) / volumeCap) : na
float directionSample = sampleValid ? participation * (0.65 * body + 0.35 * closeLocation * candleRange) / priceScale : na
float rejectionSample = sampleValid ? participation * (lowerWick - upperWick) / priceScale : na
float alpha = 1.0 - math.pow(0.5, 1.0 / halfLife)

var float directionMemory = na
var float rejectionMemory = na
var int validSamples = 0
var int phase = -9
var int pendingPhase = -9
var int pendingCloses = 0
var int lastAccumulation = 0
var array<float> trailD = array.new<float>()
var array<float> trailR = array.new<float>()
var array<color> trailColors = array.new<color>()
bool enteredUp = false
bool enteredDown = false
bool flippedUp = false
bool flippedDown = false
bool enteredBalance = false
bool lostData = false

if barstate.isconfirmed
    if not sampleValid
        lostData := validSamples >= maturityBars
        directionMemory := na
        rejectionMemory := na
        validSamples := 0
        phase := -9
        pendingPhase := -9
        pendingCloses := 0
        lastAccumulation := 0
        array.clear(trailD)
        array.clear(trailR)
        array.clear(trailColors)
    else
        // Seed from zero: a single candle does not initialize a full-strength memory.
        directionMemory := (1.0 - alpha) * nz(directionMemory) + alpha * directionSample
        rejectionMemory := (1.0 - alpha) * nz(rejectionMemory) + alpha * rejectionSample
        validSamples := math.min(validSamples + 1, 100)
        if validSamples >= maturityBars
            float d = directionMemory
            float r = rejectionMemory
            int dSign = d > 0 ? 1 : d < 0 ? -1 : 0
            int rSign = r > 0 ? 1 : r < 0 ? -1 : 0
            int candidate = 3
            if math.abs(d) <= releaseLevel and math.abs(r) <= releaseLevel
                candidate := 0
            else if math.abs(r) >= enterLevel and math.abs(r) >= rejectionRatio * math.abs(d)
                candidate := 2 * rSign
            else if math.abs(d) >= enterLevel and (d + r) * dSign > 0
                candidate := dSign
            else if math.abs(phase) == 2 and r * math.sign(phase) >= releaseLevel and (d + r) * math.sign(phase) > 0
                candidate := phase
            else if math.abs(phase) == 1 and d * phase >= releaseLevel and (d + r) * phase > 0 and math.abs(r) < rejectionRatio * math.abs(d)
                candidate := phase
            if candidate != pendingPhase
                pendingPhase := candidate
                pendingCloses := 1
            else
                pendingCloses := math.min(pendingCloses + 1, confirmationBars)
            if pendingCloses >= confirmationBars and candidate != phase
                int oldPhase = phase
                phase := candidate
                enteredUp := phase == 1
                enteredDown := phase == -1
                flippedUp := phase == 2 and lastAccumulation == -1
                flippedDown := phase == -2 and lastAccumulation == 1
                enteredBalance := phase == 0 and oldPhase != -9
                if math.abs(phase) == 1
                    lastAccumulation := phase
                else if phase == 0 or flippedUp or flippedDown
                    lastAccumulation := 0
            array.push(trailD, d)
            array.push(trailR, r)
            array.push(trailColors, phaseColor(phase))
            if array.size(trailD) > trailLength
                array.shift(trailD)
                array.shift(trailR)
                array.shift(trailColors)

bool mature = validSamples >= maturityBars
float dPlot = mature ? 100.0 * directionMemory : na
float rPlot = mature ? 100.0 * rejectionMemory : na
color stateColor = phaseColor(phase)
pZero = plot(0.0, "Pressure origin", color=color.new(chart.fg_color, 75), linewidth=1)
plot(showGlow ? dPlot : na, "Direction trace halo", color=color.new(stateColor, 88), linewidth=9, style=plot.style_linebr)
pDirection = plot(dPlot, "Directional memory D", color=stateColor, linewidth=3, style=plot.style_linebr)
pRejection = plot(rPlot, "Rejection memory R", color=showRejection ? rejectionColor : na, linewidth=1, style=plot.style_linebr)
fill(pDirection, pRejection, color=color.new(stateColor, 80), title="Coordinate separation ribbon", fillgaps=false)
fill(pZero, pDirection, color=color.new(stateColor, 93), title="Directional pressure field", fillgaps=false)
hline(100, "Bound +100", color=color.new(chart.fg_color, 95))
hline(-100, "Bound -100", color=color.new(chart.fg_color, 95))
hline(enterLevel * 100.0, "Entry +", color=color.new(chart.fg_color, 84), linestyle=hline.style_dotted)
hline(-enterLevel * 100.0, "Entry -", color=color.new(chart.fg_color, 84), linestyle=hline.style_dotted)
bgcolor(showWash and mature ? color.new(stateColor, 94) : na, title="Confirmed phase wash")
plotshape(showMarkers and enteredUp, "Up accumulation transition", shape.triangleup, location.bottom, upColor, size=size.tiny)
plotshape(showMarkers and enteredDown, "Down accumulation transition", shape.triangledown, location.top, downColor, size=size.tiny)
plotshape(showMarkers and flippedUp, "Up rejection flip", shape.diamond, location.bottom, rejectionColor, size=size.tiny)
plotshape(showMarkers and flippedDown, "Down rejection flip", shape.diamond, location.top, rejectionColor, size=size.tiny)
plotshape(showMarkers and enteredBalance, "Balance return", shape.circle, location.bottom, balanceColor, size=size.tiny)
plot(relativeVolume, "Candidate relative volume (live)", display=display.data_window)
plot(participation * 100.0, "Candidate participation weight (live)", display=display.data_window)
plot(validSamples, "Confirmed valid memory samples", display=display.data_window)
plot(phase, "Confirmed phase code", display=display.data_window)

// Fixed-position table: latest confirmed trail only, not bar-aligned historical points.
var table portrait = table.new(position.top_right, 9, 12, bgcolor=chart.bg_color, frame_color=color.new(chart.fg_color, 80), frame_width=1)
var table summary = table.new(position.bottom_left, 2, 5, bgcolor=chart.bg_color, frame_color=color.new(chart.fg_color, 80), frame_width=1)
if barstate.isfirst
    table.merge_cells(portrait, 0, 0, 8, 0)
    table.merge_cells(portrait, 0, 1, 8, 1)
    table.merge_cells(portrait, 0, 11, 8, 11)
if barstate.islast
    if showPortrait
        table.cell(portrait, 0, 0, "AUCTION PHASE | @ latest", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(portrait, 0, 1, "D horizontal / R vertical", text_color=chart.fg_color, text_size=size.tiny)
        for row = 0 to 8
            for col = 0 to 8
                string axis = col == 4 and row == 0 ? "R+" : col == 4 and row == 8 ? "R-" : row == 4 and col == 0 ? "D-" : row == 4 and col == 8 ? "D+" : row == 4 and col == 4 ? "+" : " "
                color gridColor = row == 4 or col == 4 ? color.new(chart.fg_color, 93) : chart.bg_color
                table.cell(portrait, col, row + 2, axis, width=1.5, height=2.0, text_color=color.new(chart.fg_color, 45), text_size=size.tiny, bgcolor=gridColor, tooltip="D=" + str.tostring((col - 4) * 25) + ", R=" + str.tostring((4 - row) * 25))
        int points = array.size(trailD)
        if points > 0
            for point = 0 to points - 1
                int col = int(math.round((array.get(trailD, point) + 1.0) * 4.0))
                int row = int(math.round((1.0 - array.get(trailR, point)) * 4.0)) + 2
                int fade = int(70.0 * (points - 1 - point) / math.max(points - 1, 1))
                table.cell(portrait, col, row, point == points - 1 ? "@" : ".", width=1.5, height=2.0, text_color=chart.fg_color, text_size=size.tiny, bgcolor=color.new(array.get(trailColors, point), fade), tooltip="Confirmed D=" + str.tostring(100 * array.get(trailD, point), "#.0") + ", R=" + str.tostring(100 * array.get(trailR, point), "#.0"))
        table.cell(portrait, 0, 11, phaseName(phase), text_color=stateColor, text_size=size.tiny)
    else
        table.clear(portrait, 0, 0, 8, 11)
    if showSummary
        table.cell(summary, 0, 0, "Confirmed phase", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 1, 0, phaseName(phase), text_color=stateColor, text_size=size.tiny)
        table.cell(summary, 0, 1, "D / R", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 1, 1, mature ? str.tostring(dPlot, "#.0") + " / " + str.tostring(rPlot, "#.0") : "--", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 0, 2, "Memory maturity", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 1, 2, str.tostring(math.min(validSamples, maturityBars)) + "/" + str.tostring(maturityBars), text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 0, 3, "RVOL candidate (live)", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 1, 3, sampleValid ? str.tostring(relativeVolume, "#.00") + "x" : "Unavailable", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 0, 4, "OHLCV proxy", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 1, 4, "No order-flow inference", text_color=chart.fg_color, text_size=size.tiny)
    else
        table.clear(summary, 0, 0, 1, 4)

alertcondition(enteredUp, "Up accumulation confirmed", "Auction pressure entered upward accumulation on a confirmed close.")
alertcondition(enteredDown, "Down accumulation confirmed", "Auction pressure entered downward accumulation on a confirmed close.")
alertcondition(flippedUp, "Up rejection flip confirmed", "Upward wick rejection took over the last downward accumulation memory.")
alertcondition(flippedDown, "Down rejection flip confirmed", "Downward wick rejection took over the last upward accumulation memory.")
alertcondition(enteredBalance, "Auction balance restored", "Both pressure memories returned to the release zone on confirmed closes.")
alertcondition(lostData, "Auction data interrupted", "OHLCV coverage failed; pressure memory and the phase trail were reset.")
````
