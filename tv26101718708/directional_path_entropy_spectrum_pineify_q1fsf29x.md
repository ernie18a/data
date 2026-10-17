# Directional Path Entropy Spectrum [Pineify]

- url: https://www.tradingview.com/script/q1fsf29X-Directional-Path-Entropy-Spectrum-Pineify/
- type: indicator
- pine_id: PUB;46e935f3e8a64f6bb58c8a3fed6b0b8b
- version: 1.0

## Description

[b]Overview[/b]
This trend quality indicator separates directional count imbalance from efficient price displacement. Three nested windows form a signed field; an optional fan shows score disagreement.

[b]Problem Definition[/b]
An equal net move can result from mostly one-sided closes or large offsetting steps. A slope hides the distance spent getting there. Binary sign entropy alone also fails: a single active step among many inactive bars has zero entropy. Quality requires count imbalance, efficient displacement and activity together. Here, "ordered" describes those measurements, not the temporal order of returns.

[b]Design Rationale[/b]
A prior-ATR dead zone excludes tiny direction counts; active share limits sparse samples. Path efficiency penalizes travel that cancels; ATR-scaled displacement suppresses small but perfectly efficient moves. Multiplication lets a weak component constrain quality; addition could mask it. Signed score agreement discounts opposing windows. Nested windows share samples; agreement is not independent evidence. Hysteresis and consecutive closes reduce phase chatter at the cost of delay.

[b]Key Features[/b]
[list]
[*]A signed quality field, with zero separating upward and downward net movement.
[*]Three optional window lines and a disagreement envelope.
[*]Confirmed phase diamonds, entropy background and a diagnostics table.
[*]Separate live candidate display and close-confirmed alerts.
[/list]

[b]How It Works[/b]
Defaults use 12, 24 and 48 bars, with a 14-bar ATR. Each valid close step is positive or negative only beyond the larger of 0.05 prior ATR and half a tick; other steps are inactive. In each window, H is binary entropy of positive versus negative active counts, scaled from zero to one. No active signs give H=0 and activity=0. E is absolute net change divided by total absolute steps, including inactive steps. D is absolute net change divided by prior ATR times the square root of window length. Window score = sign(net) * E * (1-H) * active share * D/(1+D). Agreement is absolute sum of scores divided by sum of absolute scores; the spectrum is their mean times agreement. Zero denominators return zero. Quiet takes priority, followed by ordered, noise, signed drift and otherwise transition. Every window needs full valid coverage after ATR warm-up. Invalid OHLC or ATR clears confirmed plots until full coverage returns.

[b]How Multiple Indicators Work Together[/b]
Sign counts describe directional balance; path length tests whether magnitudes support that balance. Activity closes the sparse-sample loophole, and normalized displacement separates meaningful travel from tiny drift. Only then does agreement combine windows. Removing any factor changes what can earn a high score; this is a constrained measurement chain rather than a vote among unrelated indicators.

[b]Trading Ideas and Insights[/b]
Use ordered phases to inspect progress across horizons alongside chart structure. A widening fan shows disagreement before the phase changes. Noise identifies active, balanced counts with inefficient net travel; it does not identify a tradable range. Entropy release invites reassessment, not a reversal forecast.

[b]Unique Aspects[/b]
Unlike slope or entropy alone, activity, cancellation and displacement cap quality before window disagreement is applied. Quiet data is separated from active noise. Ordered admission needs quality at least 0.20, agreement at least 0.80, mean entropy at most 0.45 and activity at least 0.55. Thus low entropy by itself cannot establish an ordered phase.

[b]How to Use[/b]
Wait for all three windows to mature on standard OHLC charts. Teal is positive direction, coral negative; the table names the confirmed phase. Fan width is score dispersion, not a confidence interval. Purple background intensity equals confirmed mean entropy times active share. Diamonds mark accepted changes; the optional gold dot is unconfirmed. Alerts should use once per bar close.

[b]Customization[/b]
Short window and multiplier keep lengths strictly increasing. Longer windows delay response. Dead zone changes sign counts but does not remove steps from efficiency. Ordered admission is adjustable; retention uses 60% of that score threshold with looser entropy, agreement and activity gates. Default drift admission is 0.07; noise requires all windows to satisfy H>=0.80 and E<=0.22. Two matching closes accept a phase; noise retention relaxes to H>=0.70 and E<=0.30. Fan, background, markers, table and live dot can be switched separately; defaults are starting points, not universal optima.

[b]Assumptions and Limitations[/b]
Sign entropy is a count statistic, not transition entropy or proof of randomness. Paths with the same counts, net and total travel can remain indistinguishable. Nested-window dependence, dead-zone choice, ATR lag and confirmation delay affect interpretation; a jump can dominate displacement. Quiet means low activity under these settings. Core plots and diagnostics hold the last close, while table candidate text and an enabled dot may change intrabar. Data-loss reset is immediate at a confirmed close; phase acceptance takes the selected number of closes. Feed revisions and history changes can alter output. No volume, order flow, higher-timeframe requests or execution model is used.

[b]Conclusion[/b]
Use confirmed phases as descriptive context. Window diagnostics show which of count imbalance, path efficiency, activity or displacement constrains quality; the score does not forecast the next move.

## Source Code

````pine
//@version=6
indicator("Directional Path Entropy Spectrum [Pineify]", overlay=false, precision=1, max_bars_back=1000)

// Independent implementation. Binary sign entropy measures counts, not sequence order.
// Signed displacement/path, activity and ATR amplitude constrain that interpretation.
int shortLength = input.int(12, "Short window", minval=4, maxval=60, group="Sampling")
int scaleFactor = input.int(2, "Window multiplier (S, S*M, S*M*M)", minval=2, maxval=3, group="Sampling")
int atrLength = input.int(14, "ATR scale length", minval=5, maxval=100, group="Sampling")
float deadZone = input.float(0.05, "Direction dead zone / prior ATR", minval=0.0, maxval=0.5, step=0.01, group="Sampling")
float orderedEntry = input.float(0.20, "Ordered quality admission", minval=0.10, maxval=0.70, step=0.01, group="States")
int confirmationBars = input.int(2, "Consecutive candidate closes", minval=1, maxval=8, group="States")
bool showFan = input.bool(true, "Three-window fan", group="Visuals")
bool showAtmosphere = input.bool(true, "Entropy diffusion background", group="Visuals")
bool showMarkers = input.bool(true, "Confirmed state markers", group="Visuals")
bool showTable = input.bool(true, "Window diagnostics", group="Visuals")
bool showPreview = input.bool(false, "Live candidate dot", group="Visuals")
color upColor = input.color(#008C87, "Positive direction", group="Visuals")
color downColor = input.color(#D85B45, "Negative direction", group="Visuals")
color noiseColor = input.color(#8062B6, "Noise diffusion", group="Visuals")
color transitionColor = input.color(#B58A2A, "Transition", group="Visuals")

int mediumLength = shortLength * scaleFactor
int longLength = mediumLength * scaleFactor
float priorAtr = ta.atr(atrLength)[1]
float step = close - close[1]
bool validBar = not na(close) and not na(close[1]) and not na(open) and not na(high) and not na(low) and high >= low and open >= low and open <= high and close >= low and close <= high and not na(priorAtr) and priorAtr > 0
float threshold = validBar ? math.max(priorAtr * deadZone, syminfo.mintick * 0.5) : na
int stepSign = validBar ? (step > threshold ? 1 : step < -threshold ? -1 : 0) : 0
float safeStep = validBar ? step : 0.0

f_entropy(float p) =>
    p > 0.0 and p < 1.0 ? -(p * math.log(p) + (1.0 - p) * math.log(1.0 - p)) / math.log(2.0) : 0.0

f_metrics(int length, int direction, float delta, bool valid, float atrScale) =>
    float coverage = math.sum(valid ? 1.0 : 0.0, length)
    float ups = math.sum(direction == 1 ? 1.0 : 0.0, length)
    float downs = math.sum(direction == -1 ? 1.0 : 0.0, length)
    float active = ups + downs
    float net = math.sum(delta, length)
    float path = math.sum(math.abs(delta), length)
    bool mature = not na(coverage) and coverage == length and not na(atrScale) and atrScale > 0.0
    float entropy = mature ? (active > 0.0 ? f_entropy(ups / active) : 0.0) : na
    float activity = mature ? active / length : na
    float efficiency = mature ? (path > 0.0 ? math.min(math.abs(net) / path, 1.0) : 0.0) : na
    float displacement = mature ? math.abs(net) / (atrScale * math.sqrt(length)) : na
    float amplitude = mature ? displacement / (1.0 + displacement) : na
    float quality = mature ? math.sign(net) * efficiency * (1.0 - entropy) * activity * amplitude : na
    [quality, entropy, efficiency, activity, displacement, path, mature]

[qS, hS, eS, aS, dS, pathS, matureS] = f_metrics(shortLength, stepSign, safeStep, validBar, priorAtr)
[qM, hM, eM, aM, dM, pathM, matureM] = f_metrics(mediumLength, stepSign, safeStep, validBar, priorAtr)
[qL, hL, eL, aL, dL, pathL, matureL] = f_metrics(longLength, stepSign, safeStep, validBar, priorAtr)
bool mature = matureS and matureM and matureL
float totalQuality = mature ? qS + qM + qL : na
float grossQuality = mature ? math.abs(qS) + math.abs(qM) + math.abs(qL) : na
float agreement = mature ? (grossQuality > 0.0 ? math.min(math.abs(totalQuality) / grossQuality, 1.0) : 0.0) : na
float spectrum = mature ? totalQuality / 3.0 * agreement : na
float meanEntropy = mature ? (hS + hM + hL) / 3.0 : na
float meanActivity = mature ? (aS + aM + aL) / 3.0 : na
bool noiseAdmission = mature and hS >= 0.80 and hM >= 0.80 and hL >= 0.80 and eS <= 0.22 and eM <= 0.22 and eL <= 0.22 and meanActivity >= 0.35
bool noiseRetention = mature and hS >= 0.70 and hM >= 0.70 and hL >= 0.70 and eS <= 0.30 and eM <= 0.30 and eL <= 0.30 and meanActivity >= 0.30

// Codes: +/-1 ordered, +/-2 drift, 3 noise, 4 transition, 5 quiet, 0 unavailable.
var int state = 0
var int pendingState = 0
var int pendingCount = 0
var float confirmedSpectrum = na
var float confirmedS = na
var float confirmedM = na
var float confirmedL = na
var float confirmedEntropy = na
var float confirmedAgreement = na
var float confirmedActivity = na
var float confirmedHS = na
var float confirmedHM = na
var float confirmedHL = na
var float confirmedES = na
var float confirmedEM = na
var float confirmedEL = na
var float confirmedAS = na
var float confirmedAM = na
var float confirmedAL = na
var float confirmedDS = na
var float confirmedDM = na
var float confirmedDL = na

int proposal = 0
if mature
    int direction = spectrum > 0.0 ? 1 : spectrum < 0.0 ? -1 : 0
    bool keepOrdered = math.abs(state) == 1 and direction == state and math.abs(spectrum) >= orderedEntry * 0.60 and agreement >= 0.65 and meanEntropy <= 0.60 and meanActivity >= 0.35
    bool admitOrdered = math.abs(spectrum) >= orderedEntry and agreement >= 0.80 and meanEntropy <= 0.45 and meanActivity >= 0.55
    bool keepDrift = math.abs(state) == 2 and direction == int(state / 2) and math.abs(spectrum) >= 0.04 and agreement >= 0.45 and meanActivity >= 0.15
    bool admitDrift = math.abs(spectrum) >= 0.07 and agreement >= 0.55 and meanActivity >= 0.25
    proposal := pathL == 0.0 or meanActivity < 0.05 ? 5 : keepOrdered or admitOrdered ? direction : noiseAdmission or (state == 3 and noiseRetention) ? 3 : keepDrift or admitDrift ? 2 * direction : 4

bool changed = false
bool entropyRelease = false
bool dataLost = false
if barstate.isconfirmed
    int previousState = state
    if not mature
        dataLost := previousState != 0
        state := 0
        pendingState := 0
        pendingCount := 0
    else if proposal == state
        pendingState := state
        pendingCount := 0
    else
        if proposal == pendingState
            pendingCount += 1
        else
            pendingState := proposal
            pendingCount := 1
        if pendingCount >= confirmationBars
            state := proposal
            pendingCount := 0
    changed := state != previousState and state != 0
    entropyRelease := math.abs(previousState) == 1 and (state == 3 or state == 4) and meanEntropy > 0.60
    confirmedSpectrum := spectrum
    confirmedS := mature ? qS : na
    confirmedM := mature ? qM : na
    confirmedL := mature ? qL : na
    confirmedEntropy := meanEntropy
    confirmedAgreement := agreement
    confirmedActivity := meanActivity
    confirmedHS := mature ? hS : na
    confirmedHM := mature ? hM : na
    confirmedHL := mature ? hL : na
    confirmedES := mature ? eS : na
    confirmedEM := mature ? eM : na
    confirmedEL := mature ? eL : na
    confirmedAS := mature ? aS : na
    confirmedAM := mature ? aM : na
    confirmedAL := mature ? aL : na
    confirmedDS := mature ? dS : na
    confirmedDM := mature ? dM : na
    confirmedDL := mature ? dL : na

f_state_name(int code) =>
    switch code
        1 => "Ordered up"
        -1 => "Ordered down"
        2 => "Drift up"
        -2 => "Drift down"
        3 => "Noise diffusion"
        4 => "Transition"
        5 => "Quiet / low activity"
        => "Warm-up / data gap"

f_pct(float value) =>
    na(value) ? "--" : str.tostring(100.0 * value, "0.0")

color stateColor = math.abs(state) == 1 or math.abs(state) == 2 ? (state > 0 ? upColor : downColor) : state == 3 ? noiseColor : state == 4 ? transitionColor : chart.fg_color
color directionColor = na(confirmedSpectrum) ? chart.fg_color : confirmedSpectrum >= 0.0 ? upColor : downColor
float upperFan = math.max(confirmedS, math.max(confirmedM, confirmedL)) * 100.0
float lowerFan = math.min(confirmedS, math.min(confirmedM, confirmedL)) * 100.0
pZero = plot(0.0, "Zero", color=color.new(chart.fg_color, 75))
pQuality = plot(confirmedSpectrum * 100.0, "Confirmed quality spectrum", color=directionColor, linewidth=3, style=plot.style_linebr)
fill(pQuality, pZero, color=color.new(directionColor, 82), title="Signed quality field", fillgaps=false)
pUpper = plot(showFan ? upperFan : na, "Fan upper boundary", color=color.new(chart.fg_color, 100), style=plot.style_linebr)
pLower = plot(showFan ? lowerFan : na, "Fan lower boundary", color=color.new(chart.fg_color, 100), style=plot.style_linebr)
fill(pUpper, pLower, color=color.new(transitionColor, 89), title="Window score disagreement", fillgaps=false)
plot(showFan ? confirmedS * 100.0 : na, "Short quality", color=color.new(confirmedS >= 0.0 ? upColor : downColor, 15), linewidth=1, style=plot.style_linebr)
plot(showFan ? confirmedM * 100.0 : na, "Medium quality", color=color.new(confirmedM >= 0.0 ? upColor : downColor, 42), linewidth=1, style=plot.style_linebr)
plot(showFan ? confirmedL * 100.0 : na, "Long quality", color=color.new(confirmedL >= 0.0 ? upColor : downColor, 64), linewidth=1, style=plot.style_linebr)
plot(orderedEntry * 100.0, "Ordered admission +", color=color.new(chart.fg_color, 85), style=plot.style_line)
plot(-orderedEntry * 100.0, "Ordered admission -", color=color.new(chart.fg_color, 85), style=plot.style_line)
plot(showPreview and not barstate.isconfirmed ? spectrum * 100.0 : na, "Live candidate (unconfirmed)", color=transitionColor, linewidth=3, style=plot.style_circles)
bgcolor(showAtmosphere and not na(confirmedEntropy) ? color.new(noiseColor, int(100.0 - 12.0 * confirmedEntropy * confirmedActivity)) : na, title="Active sign entropy")
plotshape(showMarkers and changed ? confirmedSpectrum * 100.0 : na, title="Confirmed phase change", style=shape.diamond, location=location.absolute, color=stateColor, size=size.tiny)
plot(confirmedEntropy * 100.0, "Mean sign entropy %", display=display.data_window)
plot(confirmedAgreement * 100.0, "Score agreement %", display=display.data_window)
plot(confirmedActivity * 100.0, "Active sign share %", display=display.data_window)
plot(state, "Confirmed state code", display=display.data_window)

var table summary = table.new(position.top_right, 5, 7, bgcolor=color.new(chart.bg_color, 10), frame_color=color.new(chart.fg_color, 75), frame_width=1)
if barstate.isfirst
    table.merge_cells(summary, 0, 0, 4, 0)
    table.merge_cells(summary, 0, 5, 4, 5)
    table.merge_cells(summary, 0, 6, 4, 6)
if barstate.islast
    if showTable
        table.cell(summary, 0, 0, f_state_name(state), text_color=stateColor, text_size=size.small)
        table.cell(summary, 0, 1, "Bars", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 1, 1, "H %", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 2, 1, "E %", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 3, 1, "Active %", text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 4, 1, "Move / ATR sqrt(N)", text_color=chart.fg_color, text_size=size.tiny)
        for row = 2 to 4
            int length = row == 2 ? shortLength : row == 3 ? mediumLength : longLength
            float entropy = row == 2 ? confirmedHS : row == 3 ? confirmedHM : confirmedHL
            float efficiency = row == 2 ? confirmedES : row == 3 ? confirmedEM : confirmedEL
            float activity = row == 2 ? confirmedAS : row == 3 ? confirmedAM : confirmedAL
            float displacement = row == 2 ? confirmedDS : row == 3 ? confirmedDM : confirmedDL
            table.cell(summary, 0, row, str.tostring(length), text_color=chart.fg_color, text_size=size.tiny)
            table.cell(summary, 1, row, f_pct(entropy), text_color=chart.fg_color, text_size=size.tiny)
            table.cell(summary, 2, row, f_pct(efficiency), text_color=chart.fg_color, text_size=size.tiny)
            table.cell(summary, 3, row, f_pct(activity), text_color=chart.fg_color, text_size=size.tiny)
            table.cell(summary, 4, row, na(displacement) ? "--" : str.tostring(displacement, "0.00"), text_color=chart.fg_color, text_size=size.tiny)
        table.cell(summary, 0, 5, "Q " + f_pct(confirmedSpectrum) + " | Agreement " + f_pct(confirmedAgreement) + "%", text_color=chart.fg_color, text_size=size.small)
        table.cell(summary, 0, 6, "Candidate: " + f_state_name(proposal) + " | pending " + str.tostring(pendingCount) + "/" + str.tostring(confirmationBars), text_color=chart.fg_color, text_size=size.tiny)
    else
        table.clear(summary, 0, 0, 4, 6)

alertcondition(changed and state == 1, "Ordered upward path", "Confirmed admission to multi-window ordered upward movement.")
alertcondition(changed and state == -1, "Ordered downward path", "Confirmed admission to multi-window ordered downward movement.")
alertcondition(entropyRelease, "Ordered path diffuses", "Confirmed ordered path released into transition/noise with increased sign entropy.")
alertcondition(changed and state == 3, "Multi-window noise diffusion", "All three windows meet confirmed sign-entropy and path-inefficiency noise gates.")
alertcondition(dataLost, "Sampling coverage lost", "Confirmed window maturity lost; spectrum and state cleared until full coverage returns.")
````
