# Positioning Flow Index by DGT

- url: https://www.tradingview.com/script/L63e3kLK-Positioning-Flow-Index-by-DGT/
- type: indicator
- pine_id: PUB;3b3699a650b14b8e998284cf2e898f70
- version: 2.0

## Description

[b]Positioning Flow Index (PFI) - Price & Open Interest Positioning Analysis[/b]

[quote][b]Positioning Flow Index (PFI)[/b] is a positioning-analysis framework designed to evaluate how [b]price movement[/b] and [b]Open Interest[/b] interact to reveal changes in market participation and positioning.

Rather than interpreting price direction alone, PFI combines normalized [b]Price[/b] and [b]Open Interest[/b] changes to identify four distinct positioning regimes:

[b]Long Buildup - Short Buildup - Short Covering - Long Unwinding[/b]

The indicator evaluates the magnitude and direction of both Price and Open Interest through [b]Z-score normalization[/b], allowing unusually strong changes to be distinguished from ordinary market fluctuations.

In addition to the Positioning Flow Index itself, PFI provides a [b]Flow State[/b], [b]Signal Strength[/b], [b]Price Sentiment[/b], and an optional [b]State Ribbon[/b] to help traders interpret the underlying positioning environment.

The objective is not to produce a simple Buy or Sell signal, but to provide a structured view of whether price movement is being accompanied by increasing or decreasing market participation and how strongly those two dimensions are aligned.[image]https://www.tradingview.com/x/jJuh6CRO/[/image][/quote]

[b]The Positioning Flow Model[/b]

[b]Price + Open Interest[/b]

[quote]Price and Open Interest provide two different perspectives on market behavior.

[b]Price[/b] describes the direction and relative strength of the current price movement.

[b]Open Interest[/b] describes the change in outstanding derivative positions and provides an additional dimension for evaluating whether market participation is expanding or contracting.

PFI normalizes both dimensions using [b]Z-scores[/b], measuring how unusual the current Price and Open Interest changes are relative to their recent history.

A positive Z-score indicates a move above its recent average, while a negative Z-score indicates a move below its recent average.

This allows the indicator to distinguish between ordinary price/OI fluctuations and more statistically unusual changes in positioning.[/quote]

[b]Flow State[/b]

[quote]The [b]Flow State[/b] classifies the relationship between Price and Open Interest into four positioning regimes.

[b]LONG BUILDUP (LB)[/b]
Price is rising while Open Interest is increasing.

This combination indicates upward price pressure accompanied by expanding participation, a condition commonly associated with new long positioning.

[b]SHORT BUILDUP (SB)[/b]
Price is falling while Open Interest is increasing.

This indicates downward price pressure accompanied by expanding participation, commonly associated with new short positioning.

[b]SHORT COVERING (SC)[/b]
Price is rising while Open Interest is decreasing.

Price is moving upward while outstanding positions contract, a condition commonly associated with short positions being closed.

[b]LONG UNWINDING (LU)[/b]
Price is falling while Open Interest is decreasing.

Price is moving downward while outstanding positions contract, a condition commonly associated with long positions being closed.

When Price and Open Interest do not both exceed the required activity threshold, the market is classified as [b]NEUTRAL[/b].

Neutral does not mean that the market is inactive. It means there is insufficient synchronized Price + Open Interest evidence to assign one of the four directional positioning states.[image]https://www.tradingview.com/x/EeOzkiFk/[/image][/quote]

[b]Positioning Flow Index[/b]

[quote]The [b]Positioning Flow Index[/b] provides a bounded [b]-100 to +100[/b] representation of positioning flow.

Its calculation combines the normalized Open Interest and Price changes through a selectable Flow Model.

[b]Model A — OI × sign(Price)[/b]

Open Interest determines the magnitude of the flow while Price determines its direction.

This model emphasizes participation strength and can produce a strong reading even when the price movement itself is relatively small.

[b]Model B — OI × Price[/b]

The Open Interest and Price Z-scores are multiplied directly.

This captures the interaction between both dimensions, but unusually large Price Z-scores can have a greater influence on the resulting flow.

[b]Model C — Price Direction × OI Magnitude × Price Confirmation[/b]

Price determines directional pressure, Open Interest determines participation magnitude, and the absolute Price Z-score contribution is capped to reduce the influence of extreme price moves.

This model separates the directional role of Price from the participation role of Open Interest and is the default model.

The three models are intentionally provided as different ways of interpreting the same underlying Price/OI relationship rather than as competing signals.[image]https://www.tradingview.com/x/8SCaF1QV/[/image][/quote]

[b]Signal Strength[/b]

[quote]Not every Flow State carries the same level of evidence.

PFI therefore calculates a [b]Signal Strength[/b] based on two independent components:

[b]Participation[/b] — derived from the magnitude of the Open Interest Z-score.

[b]Confirmation[/b] — derived from the magnitude of the Price Z-score.

Both components are capped at [b]2σ[/b] and combined using their geometric mean:

[b]Signal Strength = √(Participation × Confirmation)[/b]

The result is expressed as a percentage and provides a measure of how strongly Price and Open Interest are moving together.

Higher values indicate stronger synchronized evidence.

Importantly, Signal Strength is [b]not a probability[/b] that the current move will continue. It measures the strength of the evidence supporting the current Flow State.[image]https://www.tradingview.com/x/1GgllIDg/[/image][/quote]

[b]Early Flow Warning & Confirmed Signals[/b]

[quote]PFI separates [b]early developing conditions[/b] from [b]confirmed state transitions[/b].

[b]Early Flow Warning[/b] uses the live, still-forming candle to identify a potential transition before the candle closes. These warnings are intentionally provisional and may change or disappear as Price or Open Interest changes during the candle.

[b]Confirmed Flow Signals[/b] are evaluated only when the candle closes.

Once confirmed, the LB / SB / SC / LU marker is based on the completed candle and does not change afterward.

This distinction allows traders to see developing positioning changes early while maintaining a clearly defined, non-repainting confirmation layer.

The indicator therefore does not attempt to hide the natural evolution of live Price and Open Interest data. Instead, it explicitly separates [b]early information[/b] from [b]confirmed information[/b].[image]https://www.tradingview.com/x/VJMsqlol/[/image][/quote]

[b]Price Sentiment[/b]

[quote]The optional [b]Price Sentiment[/b] component provides an independent view of price behavior.

Price movement is smoothed and normalized over its recent range, then expressed on the same [b]-100 to +100[/b] scale as the Positioning Flow Index.

This allows Price Sentiment and PFI to be compared directly:

[b]Price Sentiment[/b] describes the current character of price movement.

[b]PFI[/b] incorporates both Price direction and Open Interest positioning.

The two therefore answer different questions and can provide additional context when interpreted together.[image]https://www.tradingview.com/x/8CmYzo7m/[/image][/quote]

[b]Flow State Ribbon[/b]

[quote]The optional [b]State Ribbon[/b] provides a continuous visual representation of the current Flow State directly on the main price chart.

[b]Teal[/b] represents Long Buildup.

[b]Red[/b] represents Short Buildup.

[b]Yellow[/b] represents Short Covering.

[b]Orange[/b] represents Long Unwinding.

[b]Gray[/b] represents Neutral conditions.

The intensity of the ribbon is influenced by Signal Strength, allowing stronger positioning conditions to stand out visually without requiring additional labels on every bar.[image]https://www.tradingview.com/x/yvDs0a95/[/image][/quote]

[b]Flow Dashboard[/b]

[quote]The optional [b]Flow Dashboard[/b] summarizes the current positioning environment through five key readings:

• [b]Flow State[/b] — the current Price/OI positioning regime.

• [b]Signal Strength[/b] — the strength of synchronized Price + OI evidence.

• [b]PFI[/b] — the bounded Positioning Flow Index.

• [b]Price Z-Score[/b] — how unusual the current price movement is relative to its recent history.

• [b]OI Z-Score[/b] — how unusual the current Open Interest change is relative to its recent history.

Together, these readings provide both the classification and the underlying measurements used to interpret it.[image]https://www.tradingview.com/x/yjoKTmCs/[/image][/quote]

[b]How to Read PFI[/b]

[quote]PFI is best used as a [b]contextual positioning tool[/b] rather than a standalone entry system.

A strong [b]Long Buildup[/b] suggests rising price accompanied by expanding Open Interest.

A strong [b]Short Buildup[/b] suggests falling price accompanied by expanding Open Interest.

A strong [b]Short Covering[/b] condition suggests rising price while Open Interest contracts.

A strong [b]Long Unwinding[/b] condition suggests falling price while Open Interest contracts.

The [b]Signal Strength[/b] helps distinguish stronger synchronized conditions from weaker ones, while the [b]PFI[/b] provides a continuous measure of directional positioning flow.

As with all market-structure and positioning analysis, these states describe the current relationship between Price and Open Interest—they do not guarantee future price direction.[/quote]

[b]Important Notes[/b]

[quote]PFI is designed for markets where [b]Open Interest data[/b] is available.

The Flow State is based on the relationship between Price and Open Interest and should not be interpreted as a direct measure of individual trader intent.

[b]Early Flow Warnings are intentionally repaintable during the active candle[/b] because they use live, developing Price and Open Interest data.

[b]Confirmed Flow markers are non-repainting[/b] because they are generated only after the candle has closed.

The selected Flow Model affects the PFI calculation, while the Flow State and Signal Strength provide separate measurements of the underlying Price/OI relationship.[/quote]

[b]Summary[/b]

[quote][b]Positioning Flow Index[/b] brings Price and Open Interest together into a structured framework for analyzing market positioning.

Rather than asking only [i]"Is price going up or down?"[/i], PFI asks a broader question:

[b]"What is happening to market positioning as price moves?"[/b]

By combining [b]Flow State[/b], [b]Signal Strength[/b], [b]Positioning Flow Index[/b], [b]Price Sentiment[/b], and [b]confirmed versus early signals[/b], PFI provides a multi-dimensional view of positioning that can be incorporated into discretionary market analysis and existing trading frameworks.[/quote]

[b]DISCLAIMER[/b]
[quote]This script is intended for informational and educational purposes only. It does not constitute financial, investment, or trading advice. All trading decisions made based on its output are solely the responsibility of the user.[/quote]

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
//# *
//# * Study       : Positioning Flow Index
//# * Author      : © dgtrd
//# *
//# * Revision History
//# *  Release    : Aug 10, 2026
//# *  Update     : Direction from actual price / OI change, Price-OI divergence, alerts, OI symbol override, plain-English reading, dashboard on panel or main chart
//# *
//# * ══════════════════════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════════════════════════ //

indicator("Positioning Flow Index by DGT", 'PFI ☼☾', format = format.volume, max_labels_count = 500, max_lines_count = 500)

display = display.all - display.status_line

pfiGR = 'Positioning Flow Index'
oiFS   = input.bool(true, "Positioning Flow Index", inline = 'PFI', group = pfiGR, tooltip = "Enable to visualize the Positioning Flow Index (PFI), a bounded -100 to +100 measure of positioning flow derived from Open Interest change and price change.")
clUP   = input.color(#00897B, '', inline = 'PFI', group = pfiGR)
clDW   = input.color(#FF5252, '', inline = 'PFI', group = pfiGR)
pfiLen = input.int(34, '  Lookback', minval = 5, inline = 'void', group = pfiGR, display = display, tooltip = "Number of bars used to normalize OI change and price return into Z-scores.\n\nSmoothing applied to the final Positioning Flow Index line.")
smth   = input.int(3, 'Smoothing', minval = 1, inline = 'void', group = pfiGR, display = display)
flowModel = input.string("C: Price-dir x OI-mag x Price-conf", "  Flow Model", options = ["A: OI x sign(Price)", "B: OI x Price", "C: Price-dir x OI-mag x Price-conf"], group = pfiGR, display = display, tooltip = "A: Flow strength comes from OI magnitude; price determines only the direction. This can produce a strong reading even when price movement is small.\n\nB: Flow strength is the direct product of OI and Price Z-scores. This captures both dimensions, but unusually large Price Z-scores can dominate the result.\n\nC: Price determines directional pressure, OI determines participation magnitude, and the absolute Price Z-score contribution is capped at 1.0 to prevent extreme price moves from dominating. OI direction is interpreted separately by Flow State, so PFI and Flow State answer related but distinct questions. Compare the three models on a live chart to determine which best fits your use case.")

stateMinZ = input.float(0.50, "  Minimum State Z-Score", minval = 0, display = display, group = pfiGR, tooltip = "Both |OI Z-score| and |Price Z-score| must reach this threshold for a bar to receive a directional Flow State. Direction itself comes from the actual price change and OI change, while the Z-scores measure how significant those changes are. Below the threshold, the bar is classified as Neutral. Lower values increase sensitivity; higher values produce fewer, more selective states.")

oiOverride = input.string('', "  OI Symbol Override", group = pfiGR, tooltip = "Leave empty for automatic detection (exchange prefix + ticker, then ticker only). If the dashboard says no Open Interest data was found, enter the exact Open Interest symbol here, for example BINANCE:BTCUSDT.P_OI.")

prGR = "Price Sentiment"
prSS  = input.bool(true, "Price Sentiment", inline = 'prs', group = prGR, tooltip = "Enable to display Price Sentiment, normalized independently and clamped to the same -100 to +100 scale as the Positioning Flow Index for direct comparison.\n\nAdjust the smoothing factor for the Price Sentiment line.")
prSSC = input.color(color.new(#9598a1, 0), "", inline = 'prs', group = prGR)
smthP = input.int(3, 'Smoothing', minval = 1, inline = 'prs', group = prGR, display = display)

dashGR = "Flow Dashboard"
showDash = input.bool(true, "Show Flow Dashboard", group = dashGR, tooltip = "Enable to display the current Flow State, its strength, and the underlying PFI, Price Z-score, and OI Z-score readings.")
dashLoc = input.string("Main Chart", "  Dashboard Location", inline = 'DS', options = ["Panel", "Main Chart"], group = dashGR, display = display, tooltip = "Panel: the dashboard is drawn inside the indicator pane. Main Chart: the dashboard is drawn over the price chart instead.")
dashPosIn = input.string("Top Right", "", inline = 'DS', options = ["Top Right", "Top Left", "Bottom Left"], group = dashGR, display = display, tooltip = "Corner used by the dashboard. Bottom Right is reserved for the SoleMare Analytics logo.")

overlayGR = "Main Chart Overlays"
signalMode   = input.string("Off", "Flow State Markers", options = ["Off", "Confirmed Only", "Early + Confirmed"], group = overlayGR, display = display, tooltip = "Off: no on-chart markers. Confirmed Only: prints an LB/SB/SC/LU label only at candle close (barstate.isconfirmed) -- once printed it never repaints. Early + Confirmed: also shows a lighter, provisional 'LB?'-style Early Flow Warning while the candle is still forming; unlike the Confirmed marker, this warning can change or disappear before the candle closes since it reflects live, still-forming data.")
markerMinStrength = input.float(0.50, "  Minimum Signal Strength for Markers", minval = 0, maxval = 1, step = 0.05, display = display, group = overlayGR, tooltip = "Controls the minimum Signal Strength required for a state-transition marker. This is deliberately separate from Minimum State Z-Score: a valid Flow State can exist at roughly 25% Signal Strength with the default stateMinZ = 0.50, but the default 50% marker threshold prevents weaker transitions from cluttering the chart. The dashboard always shows the actual current state; this setting only gates the on-chart marker.")
divSH = input.bool(true, "Price-OI Divergence", inline = 'div', group = overlayGR, tooltip = "Marks swing highs and lows in price that are not confirmed by Open Interest.\n\n▼ DIV: price made a higher swing high, but OI at that high is lower than at the previous swing high, so the rally lacks fresh participation.\n▲ DIV: price made a lower swing low, but OI at that low is lower than at the previous swing low, so the decline lacks fresh participation.\n\nSwings are confirmed after the Pivot Length bars to the right, so a marker appears with that delay and does not repaint once printed. This describes participation, not a prediction.")
divLen = input.int(5, "", minval = 2, inline = 'div', group = overlayGR, display = display)
ribbonMode   = input.string("Off", "Flow State Ribbon", options = ["Off", "State Ribbon"], display = display, group = overlayGR, tooltip = "Off: rely on the LB/SB/SC/LU transition markers and dashboard instead. State Ribbon: displays a thin, continuous colored band around the price candles. Hue shows the current Flow State, while color intensity reflects Signal Strength. Neutral renders as a visible gray segment rather than a gap in the timeline.")

f_tanh(_x) =>
    x = math.max(math.min(_x, 20.0), -20.0)
    e2x = math.exp(2 * x)
    (e2x - 1) / (e2x + 1)

f_safeRange(_range) =>
    math.max(_range, syminfo.mintick)

f_meter(_pct) =>
    filled = int(math.max(0, math.min(10, math.round(_pct / 10))))
    bar = ""
    for i = 0 to 9
        bar += i < filled ? "█" : "░"
    bar

symAuto = str.endswith(syminfo.ticker, "USDT") or str.endswith(syminfo.ticker, "USDC") ? syminfo.ticker + ".P_OI" : str.endswith(syminfo.ticker, ".P") ? syminfo.ticker + "_OI" : syminfo.ticker + "T.P_OI"
symUsed = oiOverride != '' ? oiOverride : syminfo.prefix + ':' + symAuto
oiP = request.security(symUsed, timeframe.period, close, ignore_invalid_symbol = true)
oiU = request.security(symAuto, timeframe.period, close, ignore_invalid_symbol = true)
oiC = oiOverride != '' ? oiP : (na(oiP) ? oiU : oiP)
hasOI = not na(oiC)

if barstate.islast
    var table oiT = table.new(position.middle_center, 1, 1)
    if na(oiC)
        table.cell(oiT, 0, 0, 'No Open Interest data found for ' + syminfo.ticker + '.\nTried: ' + symUsed + (oiOverride == '' ? ' and ' + symAuto : '') + '\nEnter the exact symbol in "OI Symbol Override", e.g. BINANCE:BTCUSDT.P_OI', text_size = size.normal, text_color = #ff9800, text_halign = text.align_left)
    if syminfo.type != 'crypto'
        table.cell(oiT, 0, 0, 'Only Cryptocurrencies', text_size = size.normal, text_color = color.white, text_halign = text.align_left)

oiDelta = hasOI and oiC[1] > 0 and oiC > 0 ? math.log(oiC / oiC[1]) : na
oiMean  = ta.sma(oiDelta, pfiLen)
oiStd   = ta.stdev(oiDelta, pfiLen)
oiZ     = hasOI ? (oiStd > 0 ? (oiDelta - oiMean) / oiStd : 0.0) : na

prDelta = math.log(close / close[1])
prMean  = ta.sma(prDelta, pfiLen)
prStd   = ta.stdev(prDelta, pfiLen)
prZ     = prStd > 0 ? (prDelta - prMean) / prStd : 0.0

prDir = math.sign(prDelta)
oiDir = hasOI ? math.sign(oiDelta) : na

flow = switch flowModel
    "A: OI x sign(Price)"              => oiZ * prDir
    "B: OI x Price"                    => oiZ * prZ
    "C: Price-dir x OI-mag x Price-conf" => prDir * math.abs(oiZ) * math.min(math.abs(prZ), 1.0)
    => oiZ * prDir

pfi = ta.ema(100 * f_tanh(flow), smth)

oiActive = hasOI and not na(oiZ) and math.abs(oiZ) >= stateMinZ
prActive = math.abs(prZ) >= stateMinZ
active   = oiActive and prActive

state = not hasOI ? "OI DATA UNAVAILABLE" :
         not active ? "NEUTRAL" :
         prDir > 0 and oiDir > 0 ? "LONG BUILDUP" :
         prDir < 0 and oiDir > 0 ? "SHORT BUILDUP" :
         prDir > 0 and oiDir < 0 ? "SHORT COVERING" :
         prDir < 0 and oiDir < 0 ? "LONG UNWINDING" : "NEUTRAL"

participation = hasOI ? math.min(math.abs(oiZ), 2.0) / 2.0 : na
confirmation  = math.min(math.abs(prZ), 2.0) / 2.0
sigStrength = hasOI ? math.sqrt(participation * confirmation) : na
strengthPct = hasOI ? sigStrength * 100 : na

strengthLabel = not hasOI ? "" :
             sigStrength >= 0.75 ? "STRONG " :
             sigStrength >= 0.35 ? "" :
             "WEAK "
dispState = not hasOI ? state : state == "NEUTRAL" ? state : strengthLabel + state

headline = not hasOI ? "No Open Interest data" :
           state == "NEUTRAL" ? "" :
           (state == "LONG BUILDUP" ? "Longs are adding" : state == "SHORT BUILDUP" ? "Shorts are adding" : state == "SHORT COVERING" ? "Shorts are closing" : "Longs are closing") + " · " + (sigStrength >= 0.75 ? "Strong" : sigStrength >= 0.35 ? "Moderate" : "Weak")

prArrow = prDir > 0 ? ' ▲' : prDir < 0 ? ' ▼' : ''
oiArrow = oiDir > 0 ? ' ▲' : oiDir < 0 ? ' ▼' : ''

stateColor = state == "LONG BUILDUP"   ? clUP :
             state == "SHORT BUILDUP"  ? clDW :
             state == "SHORT COVERING" ? color.new(color.yellow, 0) :
             state == "LONG UNWINDING" ? color.new(color.orange, 0) :
             state == "OI DATA UNAVAILABLE" ? #ff9800 : color.gray

plot(oiFS ? pfi : na, 'Positioning Flow Index', pfi >= 0 ? (pfi[1] > pfi ? color.new(clUP, 50) : clUP) : (pfi[1] > pfi ? clDW : color.new(clDW, 50)), style = plot.style_columns, display = display)
hline(0, "Zero Line", color = color.new(color.gray, 60))

stateAbbrev = state == "LONG BUILDUP"   ? "LB" :
              state == "SHORT BUILDUP"  ? "SB" :
              state == "SHORT COVERING" ? "SC" :
              state == "LONG UNWINDING" ? "LU" : ""

isBearishFlavor = state == "SHORT BUILDUP" or state == "LONG UNWINDING"

confirmedStateChanged = barstate.isconfirmed and hasOI and state != state[1] and state != "NEUTRAL" and sigStrength >= markerMinStrength
earlyStateChanged     = not barstate.isconfirmed and hasOI and state != state[1] and state != "NEUTRAL" and sigStrength >= markerMinStrength

stateTitle = state == "LONG BUILDUP"   ? "Long Buildup" :
             state == "SHORT BUILDUP"  ? "Short Buildup" :
             state == "SHORT COVERING" ? "Short Covering" :
             state == "LONG UNWINDING" ? "Long Unwinding" : state

if (signalMode == "Confirmed Only" or signalMode == "Early + Confirmed") and confirmedStateChanged
    label.new(bar_index, isBearishFlavor ? high : low, text = stateAbbrev,
      style = isBearishFlavor ? label.style_label_down : label.style_label_up,
      color = stateColor, textcolor = color.white, size = size.tiny, force_overlay = true,
      tooltip = dispState + "\nPFI " + str.tostring(pfi, '#.#') + " | Price " + str.tostring(prZ, '#.##') + "σ | OI " + str.tostring(oiZ, '#.##') + "σ | Strength " + str.tostring(strengthPct, '#') + "%")
      //tooltip = "Confirmed " + dispState + "\nPFI " + str.tostring(pfi, '#.#') + " | Price " + str.tostring(prZ, '#.##') + "σ | OI " + str.tostring(oiZ, '#.##') + "σ | Strength " + str.tostring(strengthPct, '#') + "%")

if confirmedStateChanged
    alert('PFI • ' + syminfo.ticker + ' ' + stateTitle + ' | Strength ' + str.tostring(strengthPct, '#') + '% | PFI ' + str.tostring(pfi, '#.#') + ' @ ' + str.tostring(close, format.mintick) + ' | Anchor: ' + timeframe.period, alert.freq_once_per_bar_close)

var label earlyLbl = na
if signalMode == "Early + Confirmed" and not barstate.isconfirmed
    if earlyStateChanged
        earlyTooltip = "Early Flow Warning -- current Price/OI conditions indicate a potential " + stateTitle + ", but the candle has not closed. This may change or disappear before confirmation.\nPFI " + str.tostring(pfi, '#.#') + " | Price " + str.tostring(prZ, '#.##') + "σ | OI " + str.tostring(oiZ, '#.##') + "σ | Strength " + str.tostring(strengthPct, '#') + "%"
        if na(earlyLbl)
            earlyLbl := label.new(bar_index, isBearishFlavor ? high : low, text = "●\n" + stateAbbrev,
              style = isBearishFlavor ? label.style_label_down : label.style_label_up,
              color = color.new(stateColor, 60), textcolor = color.new(color.white, 20), size = size.tiny, force_overlay = true,
              tooltip = earlyTooltip)
        else
            label.set_xy(earlyLbl, bar_index, isBearishFlavor ? high : low)
            label.set_text(earlyLbl, "●\n" + stateAbbrev)
            label.set_style(earlyLbl, isBearishFlavor ? label.style_label_down : label.style_label_up)
            label.set_color(earlyLbl, color.new(stateColor, 60))
            label.set_tooltip(earlyLbl, earlyTooltip)
    else if not na(earlyLbl)
        label.delete(earlyLbl)
        earlyLbl := na

if barstate.isconfirmed and not na(earlyLbl)
    label.delete(earlyLbl)
    earlyLbl := na

pivHi = ta.pivothigh(high, divLen, divLen)
pivLo = ta.pivotlow(low, divLen, divLen)
oiAtHi = oiC[divLen]
oiAtLo = oiC[divLen]

var float phP = na
var float phO = na
var int   phB = na
var float plP = na
var float plO = na
var int   plB = na

if not na(pivHi) and not na(oiAtHi)
    pB = bar_index - divLen
    if divSH and not na(phP) and pivHi > phP and oiAtHi < phO
        line.new(phB, phP, pB, pivHi, color = color.new(clDW, 30), style = line.style_dashed, force_overlay = true)
        label.new(pB, pivHi, '▼ DIV', style = label.style_label_down, color = color.new(clDW, 60), textcolor = color.new(color.white, 10), size = size.tiny, force_overlay = true,
          tooltip = "Price-OI Divergence: price made a higher swing high, but Open Interest at this high is lower than at the previous swing high. The rally lacks fresh participation.\nOI " + str.tostring(oiAtHi, format.volume) + " vs " + str.tostring(phO, format.volume) + " at the previous swing high.")
        alert('PFI • ' + syminfo.ticker + ' Price-OI Divergence ▼ (higher high, lower OI) @ ' + str.tostring(pivHi, format.mintick) + ' | Anchor: ' + timeframe.period, alert.freq_once_per_bar_close)
    phP := pivHi
    phO := oiAtHi
    phB := pB

if not na(pivLo) and not na(oiAtLo)
    pB = bar_index - divLen
    if divSH and not na(plP) and pivLo < plP and oiAtLo < plO
        line.new(plB, plP, pB, pivLo, color = color.new(clUP, 30), style = line.style_dashed, force_overlay = true)
        label.new(pB, pivLo, '▲ DIV', style = label.style_label_up, color = color.new(clUP, 60), textcolor = color.new(color.white, 10), size = size.tiny, force_overlay = true,
          tooltip = "Price-OI Divergence: price made a lower swing low, but Open Interest at this low is lower than at the previous swing low. The decline lacks fresh participation.\nOI " + str.tostring(oiAtLo, format.volume) + " vs " + str.tostring(plO, format.volume) + " at the previous swing low.")
        alert('PFI • ' + syminfo.ticker + ' Price-OI Divergence ▲ (lower low, lower OI) @ ' + str.tostring(pivLo, format.mintick) + ' | Anchor: ' + timeframe.period, alert.freq_once_per_bar_close)
    plP := pivLo
    plO := oiAtLo
    plB := pB

stripTransp = state == "NEUTRAL" ? 75 :
              hasOI ? int(math.max(35, 80 - sigStrength * 45)) : 85
stripColor  = state == "LONG BUILDUP"   ? color.new(clUP, stripTransp) :
              state == "SHORT BUILDUP"  ? color.new(clDW, stripTransp) :
              state == "SHORT COVERING" ? color.new(color.yellow, stripTransp) :
              state == "LONG UNWINDING" ? color.new(color.orange, stripTransp) :
              color.new(color.gray, stripTransp)

stripOffset = ta.atr(14) * 0.40
stripLow    = low - stripOffset
stripHigh   = stripLow + stripOffset * 0.45
stripP1 = plot(ribbonMode == "State Ribbon" ? stripLow : na, title = "Flow State Ribbon (base)", color = color(na), display = display.none, editable = false, force_overlay = true)
stripP2 = plot(ribbonMode == "State Ribbon" ? stripHigh : na, title = "Flow State Ribbon (top)", color = color(na), display = display.none, editable = false, force_overlay = true)
fill(stripP1, stripP2, color = ribbonMode == "State Ribbon" ? stripColor : na, title = "Flow State Ribbon")

prF  = ta.ema(high + low - 2 * ta.ema(close, 13), smthP)
pHST = ta.highest(prF, 89)
pLST = ta.lowest(prF, 89)
prSentimentRaw = 100 * (prF - math.avg(pHST, pLST)) / f_safeRange((pHST - pLST) / 2)
prSentiment    = math.max(-100.0, math.min(100.0, prSentimentRaw))

plot(prSS ? prSentiment : na, 'Price Sentiment', prSSC, 1, display = display)

f_dash(table _t) =>
    if headline == ''
        table.clear(_t, 0, 0, 1, 0)
    else
        table.cell(_t, 0, 0, headline, text_color = stateColor, text_halign = text.align_center, text_size = size.small, tooltip = "Plain-English reading of the current Flow State and its Signal Strength. Derived from the same Price + Open Interest classification shown below; it describes positioning, not a forecast.")
        table.merge_cells(_t, 0, 0, 1, 0)
    table.cell(_t, 0, 1, 'FLOW STATE', text_color = color.gray, text_halign = text.align_left, text_size = size.small, tooltip = "Positioning regime based on Price and Open Interest: Long Buildup (price ↑, OI ↑), Short Buildup (price ↓, OI ↑), Short Covering (price ↑, OI ↓), Long Unwinding (price ↓, OI ↓). Neutral means there isn't enough synchronized Price + OI evidence to classify a regime; it does not mean there is no market activity.")
    table.cell(_t, 1, 1, dispState, text_color = stateColor, text_halign = text.align_left, text_size = size.small, tooltip = "WEAK/STRONG prefix reflects Signal Strength below, independent of the selected Flow Model.")
    table.cell(_t, 0, 2, 'SIGNAL STRENGTH', text_color = color.gray, text_halign = text.align_left, text_size = size.small, tooltip = "Signal Strength is calculated as sqrt(participation × confirmation), where participation comes from |OI Z-score| and confirmation from |Price Z-score|, each capped at 2σ. Independent of the selected Flow Model, it reflects the strength of synchronized Price + OI evidence behind the current classification. This is not a probability that the move will continue.")
    table.cell(_t, 1, 2, hasOI ? f_meter(strengthPct) + '  ' + str.tostring(strengthPct, '#') + '%' : 'N/A', text_color = chart.fg_color, text_halign = text.align_left, text_size = size.small, tooltip = "N/A when Open Interest data is unavailable for this symbol/timeframe.")
    table.cell(_t, 0, 3, 'PFI', text_color = color.gray, text_halign = text.align_left, text_size = size.small, tooltip = "Positioning Flow Index, bounded -100 to +100, from the selected Flow Model (see the Flow Model tooltip for details). Answers \"What direction and how strongly?\", while Flow State answers \"What does the positioning regime mean?\"")
    table.cell(_t, 1, 3, hasOI ? str.tostring(pfi, '#.#') : 'N/A', text_color = hasOI ? (pfi >= 0 ? clUP : clDW) : color.gray, text_halign = text.align_left, text_size = size.small, tooltip = "N/A when Open Interest data is unavailable for this symbol/timeframe.")
    table.cell(_t, 0, 4, 'PRICE Z-SCORE', text_color = color.gray, text_halign = text.align_left, text_size = size.small, tooltip = "Shows how unusual the current price move is compared with recent price moves. 0σ means the current move is close to its recent average. Positive values mean the price return is above its recent average; negative values mean it is below its recent average. Around ±1σ means moderately unusual, while around ±2σ means unusually large. The farther the value is from 0, the more unusual the price move. This is separate from direction: price direction comes from the actual price change, so price can rise while this value is negative if the rise is smaller than its recent average.")
    table.cell(_t, 1, 4, str.tostring(prZ, '#.##') + 'σ' + prArrow, text_color = chart.fg_color, text_halign = text.align_left, text_size = size.small, tooltip = "PRICE Z-SCORE: 0σ = close to the recent average price move. Positive = stronger upward price return than its recent average; negative = stronger downward price return. Around ±1σ = moderately unusual; around ±2σ = unusually large. Higher absolute values mean the current price move is more unusual compared with the recent Lookback period. The arrow shows the actual direction of the price change (▲ rose, ▼ fell), independent of the Z-score sign.")
    table.cell(_t, 0, 5, 'OI Z-SCORE', text_color = color.gray, text_halign = text.align_left, text_size = size.small, tooltip = "Shows how unusual the current Open Interest change is compared with recent OI changes. 0σ means the current OI change is close to its recent average. Positive values mean the OI change is above its recent average; negative values mean it is below its recent average. Around ±1σ means moderately unusual, while around ±2σ means unusually large. This is separate from direction: OI direction comes from the actual OI change, so OI can rise while this value is negative if the rise is smaller than its recent average.")
    table.cell(_t, 1, 5, hasOI ? str.tostring(oiZ, '#.##') + 'σ' + oiArrow : 'N/A', text_color = chart.fg_color, text_halign = text.align_left, text_size = size.small, tooltip = "OI Z-SCORE: 0σ = close to the recent average OI change. Positive = stronger OI change than its recent average; negative = weaker OI change than its recent average. Around ±1σ = moderately unusual; around ±2σ = unusually large. Higher absolute values mean the current OI change is more unusual compared with the recent Lookback period. The arrow shows the actual direction of the OI change (▲ increased, ▼ decreased), independent of the Z-score sign.")

dashPosV = dashPosIn == "Top Left" ? position.top_left : dashPosIn == "Bottom Left" ? position.bottom_left : position.top_right
var table dashP = table.new(dashPosV, 2, 6, bgcolor = color.new(chart.fg_color, 95), border_color = color.new(chart.fg_color, 95), border_width = 1, frame_color = color.new(chart.fg_color, 81), frame_width = 1)
var table dashM = table.new(dashPosV, 2, 6, bgcolor = color.new(chart.fg_color, 95), border_color = color.new(chart.fg_color, 95), border_width = 1, frame_color = color.new(chart.fg_color, 81), frame_width = 1, force_overlay = true)

if showDash and barstate.islast and syminfo.type == 'crypto'
    f_dash(dashLoc == "Main Chart" ? dashM : dashP)

var table logo  = table.new(position.bottom_right, 1, 1)
var table logo2 = table.new(position.bottom_right, 1, 1, force_overlay = true)
if barstate.islast
    table.cell(logo , 0, 0, '☼☾  ', text_size=size.normal, text_color=color.teal, tooltip = 'SoleMare Analytics')
    table.cell(logo2, 0, 0, '☼☾  ', text_size=size.normal, text_color=color.teal, tooltip = 'SoleMare Analytics')
````
