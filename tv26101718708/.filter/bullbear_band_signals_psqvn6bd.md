# Bull/Bear Band Signals

- url: https://www.tradingview.com/script/psQVn6Bd-Bull-Bear-Band-Signals/
- type: indicator
- pine_id: PUB;7003960657b946caa9388a4fa4a5c9a8
- version: 1.0

## Description

[b]Bull/Bear Band Signals [/b]

Bull/Bear Band Signals is an adaptation of the Bull Market Support Band concept, combining a Simple Moving Average (SMA) and an Exponential Moving Average (EMA) into a band that shows where price sits relative to both averages.

The classic Bull Market Support Band uses a 20-week SMA and a 21-week EMA. This indicator calculates its averages on the current chart timeframe and offers several length presets. With the Position preset on a weekly chart and Close selected as the source, it uses the classic 20-week SMA / 21-week EMA combination.

The underlying moving-average concept is established. This implementation focuses on confirmed-bar signals, configurable visuals, and alerts for transitions outside and back inside the band.

https://www.tradingview.com/x/vDXNxCeP/

[b]Reading the band[/b]

The SMA is blue and the EMA is orange by default. Their colors remain distinct when they cross and can be customized independently.

The higher average defines the upper boundary, and the lower average defines the lower boundary. The fill turns green when the selected source finishes above both averages and red when it finishes below both.

Inside the band, the fill retains its last directional color by default. An optional neutral mode changes it to gray. A green or red fill therefore does not necessarily mean the source is currently outside the band.

Close is the default source. Other built-in OHLC sources are available and, when selected, are used for both the averages and signal conditions.

[b]Signals[/b]

• Bull Reclaim: a small green triangle appears when the selected source finishes above the band after the previous bar was not above it.

• Bear Breakdown: a small red triangle appears when the selected source finishes below the band after the previous bar was not below it.

• SMA/EMA Cross: a small dot marks a confirmed crossing of the averages. It is a separate visual event and does not trigger or filter the directional triangles.

The triangles identify transitions, not guaranteed entries. Another signal in the same direction can appear after a return into the band followed by a new exit.

https://www.tradingview.com/x/0Rm8E44s/

[b]Retest and inside-band alerts[/b]

Retest Bull identifies a return into the band from above. Retest Bear identifies a return from below. These events describe re-entry only; they do not confirm that support or resistance has held.

Generic inside-band alerts can be disabled, triggered on entry, or triggered on every confirmed bar inside the band. When an enabled retest alert applies, it takes priority over the generic inside-band alert.

[b]Presets[/b]

• Scalp — SMA 20 / EMA 21
• Intraday — SMA 50 / EMA 55
• Swing — SMA 100 / EMA 110
• Position — SMA 20 / EMA 21

Auto selects Scalp for seconds-based charts and minute charts up to 15 minutes, Intraday for minute charts above 15 and up to 60 minutes, and Swing for intraday charts above 60 minutes and up to 12 hours. Other supported timeframes use Position.

All lengths refer to bars on the current chart. These are convenient parameter presets, not settings claimed to be optimal for every market.

https://www.tradingview.com/x/zTCOcikv/

[b]Confirmed-bar behavior[/b]

Signals, alerts, band values, and regime colors update only when the chart candle closes. During an open candle, the band retains its last confirmed values.

The script does not use future data, external indicator sources, or multi-timeframe requests. It does not backdate signals, and it uses plotted markers rather than deleting older signals through a label-retention limit.

This prevents provisional intrabar signals from appearing and disappearing as the current candle changes. The trade-off is that a signal becomes available only at the close, not at the first intrabar crossing.

Historical results remain dependent on the selected settings and available input data. Provider corrections, changes in loaded history, or changes to the symbol and timeframe can produce different calculations. Synthetic chart types are disabled.

[b]Alerts and customization[/b]

The indicator provides individual event alerts and optional JSON messages for webhook integrations. Select “Any alert() function call” to use the JSON route. It sends at most one selected event per confirmed bar per alert instance.

Band transparency, edge colors, line width, signal visibility, and marker spacing can be adjusted. ATR is used only to position the directional markers away from the candles; it does not determine band width or filter signals.

Visual settings and alert settings are independent. Hiding a triangle does not disable its corresponding alert.

[b]Limitations[/b]

Like other moving-average tools, the indicator reacts to price and can lag fast moves. Sideways conditions can generate frequent opposing signals. There are no volume, trend-strength, or market-structure filters.

The script is an indicator, not a trading strategy. It does not manage positions, define exits, or provide a backtested performance claim. Its purpose is to make band transitions visible and consistently report them at bar close.

[b]For informational and educational purposes only. Signals may be incorrect and do not constitute financial or investment advice. Trading involves substantial risk, and users remain responsible for their decisions and risk management.[/b]

## Source Code

````pine
// This Pine Script® code is subject to the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// Original code: © talgos. Adapted edition: BBBS.
//@version=6
indicator("Bull/Bear Band Signals", overlay=true)

if barstate.isfirst and not chart.is_standard
    runtime.error("Use standard price candles/bars. Synthetic charts are disabled in Confirmed mode.")

// Risk disclosure is informational only and does not affect calculations or alerts.
grpAttn = "About and Risk Disclosure"
attMsg = "Bull/Bear Band Signals is provided for informational and educational purposes only and does not constitute financial or investment advice. " +
     "Its signals and levels are based on historical price data, may be incorrect, and do not guarantee future market movements or trading results. " +
     "Confirmation at bar close helps prevent intrabar signal changes, but it does not eliminate market risk or ensure profitability. " +
     "Trading involves substantial risk, including the possible loss of all capital committed to trading, and past performance is not a reliable indicator of future results. " +
     "Before acting on any signal, assess its suitability for your circumstances and use appropriate risk management, including position sizing and stop-loss orders, while recognizing that these measures cannot eliminate losses. " +
     "You remain responsible for your trading decisions and their outcomes."
_attnInfo = input.bool(true, attMsg, group=grpAttn, tooltip="Informational text only. This checkbox does not hide the disclosure or affect indicator behavior.")

grpCore = "Band and events"
preset = input.string("Auto", "Preset", options=["Auto", "Scalp", "Intraday", "Swing", "Position"], group=grpCore)
sourceChoice = input.string("Close", "Calculation source", options=["Close", "Open", "High", "Low", "HL2", "HLC3", "OHLC4"], group=grpCore, tooltip="Chart OHLC only. Every event waits for bar close. External indicators are not accepted.")
insideMode = input.string("OnEnter", "Inside Band Alert Mode", options=["Off", "OnEnter", "EveryBar"], group=grpCore)
enableRetest = input.bool(true, "Enable Retest Events", group=grpCore, tooltip="Return into the band from outside. Does not confirm a bounce.")

f_autoPreset() =>
    if timeframe.isseconds or (timeframe.isminutes and timeframe.multiplier <= 15)
        "Scalp"
    else if timeframe.isminutes and timeframe.multiplier <= 60
        "Intraday"
    else if timeframe.isintraday and timeframe.multiplier <= 720
        "Swing"
    else
        "Position"

resolved = preset == "Auto" ? f_autoPreset() : preset
smaLen = switch resolved
    "Scalp" => 20
    "Intraday" => 50
    "Swing" => 100
    => 20
emaLen = switch resolved
    "Scalp" => 21
    "Intraday" => 55
    "Swing" => 110
    => 21
src = switch sourceChoice
    "Open" => open
    "High" => high
    "Low" => low
    "HL2" => hl2
    "HLC3" => hlc3
    "OHLC4" => ohlc4
    => close

// Calculate series on every execution; publish only at close.
smaLine = ta.sma(src, smaLen)
emaLine = ta.ema(src, emaLen)
upper = math.max(smaLine, emaLine)
lower = math.min(smaLine, emaLine)
atr14 = ta.atr(14)
crossRaw = ta.cross(smaLine, emaLine)
ready = not na(src) and not na(upper) and not na(lower)
previousReady = not na(src[1]) and not na(upper[1]) and not na(lower[1])
eventReady = barstate.isconfirmed and ready and previousReady
bullNow = ready and src > upper
bearNow = ready and src < lower
insideNow = ready and src >= lower and src <= upper
bullPrev = previousReady and src[1] > upper[1]
bearPrev = previousReady and src[1] < lower[1]
insidePrev = previousReady and src[1] >= lower[1] and src[1] <= upper[1]

bullSignal = eventReady and bullNow and not bullPrev
bearSignal = eventReady and bearNow and not bearPrev
retestBull = eventReady and enableRetest and insideNow and bullPrev
retestBear = eventReady and enableRetest and insideNow and bearPrev
insideEvent = eventReady and insideNow and (insideMode == "EveryBar" or (insideMode == "OnEnter" and not insidePrev))
crossEvent = eventReady and crossRaw

grpVis = "Visuals — confirmed only"
showEdges = input.bool(true, "Show SMA/EMA Edges", group=grpVis)
smaEdgeColor = input.color(color.blue, "SMA Edge Color", group=grpVis)
emaEdgeColor = input.color(color.orange, "EMA Edge Color", group=grpVis)
bullColor = input.color(color.lime, "Bull Color", group=grpVis)
bearColor = input.color(color.red, "Bear Color", group=grpVis)
neutralColor = input.color(color.gray, "Neutral Color", group=grpVis)
edgeWidth = input.int(2, "Edge Width", minval=1, maxval=4, group=grpVis)
bandTransp = input.int(85, "Band Transparency", minval=0, maxval=100, group=grpVis)
neutralFillInside = input.bool(false, "Neutral Fill Inside Band", group=grpVis)
showSignals = input.bool(true, "Show Signals", group=grpVis)
showBullSignal = input.bool(true, "Show Bull Signal", group=grpVis)
showBearSignal = input.bool(true, "Show Bear Signal", group=grpVis)
signalOffsetATR = input.float(0.5, "Signal Offset (ATR)", minval=0.0, step=0.1, group=grpVis)
showCrossDot = input.bool(true, "Show SMA/EMA Cross Dot", group=grpVis)
crossColor = input.color(color.black, "Cross Dot Color", group=grpVis)

var int regime = 0
var float closedSma = na
var float closedEma = na
if barstate.isconfirmed
    closedSma := ready ? smaLine : na
    closedEma := ready ? emaLine : na
    if not ready
        regime := 0
    else if bullNow
        regime := 1
    else if bearNow
        regime := -1
    else if neutralFillInside
        regime := 0

// On an open bar these carry the previous committed values, without flickering.
regimeColor = regime == 1 ? bullColor : regime == -1 ? bearColor : neutralColor
plot(showEdges ? closedSma : na, "SMA (confirmed)", color=smaEdgeColor, linewidth=edgeWidth)
plot(showEdges ? closedEma : na, "EMA (confirmed)", color=emaEdgeColor, linewidth=edgeWidth)
pU = plot(math.max(closedSma, closedEma), "Upper (confirmed)", display=display.none)
pL = plot(math.min(closedSma, closedEma), "Lower (confirmed)", display=display.none)
fill(pU, pL, color=color.new(regimeColor, bandTransp), title="Confirmed Band", fillgaps=false)

// Series plots retain historical markers; no label queue or deletion limit.
bullY = low - nz(atr14, 0.0) * signalOffsetATR
bearY = high + nz(atr14, 0.0) * signalOffsetATR
plotshape(showSignals and showBullSignal and bullSignal ? bullY : na, title="Bull Reclaim", style=shape.triangleup, location=location.absolute, color=bullColor, size=size.tiny)
plotshape(showSignals and showBearSignal and bearSignal ? bearY : na, title="Bear Breakdown", style=shape.triangledown, location=location.absolute, color=bearColor, size=size.tiny)
plotshape(showCrossDot and crossEvent ? (smaLine + emaLine) / 2.0 : na, title="SMA/EMA Cross", style=shape.circle, location=location.absolute, color=crossColor, size=size.tiny)

grpAlerts = "Alert Events — confirmed only"
alertReclaim = input.bool(true, "Alert: Reclaim", group=grpAlerts)
alertBreakdown = input.bool(true, "Alert: Breakdown", group=grpAlerts)
alertInside = input.bool(true, "Alert: Inside Band", group=grpAlerts)
alertRetest = input.bool(true, "Alert: Retest", group=grpAlerts)
emitBull = alertReclaim and bullSignal
emitBear = alertBreakdown and bearSignal
emitRetestBull = alertRetest and retestBull
emitRetestBear = alertRetest and retestBear
emitInside = alertInside and insideEvent and not emitRetestBull and not emitRetestBear

grpWH = "Webhook JSON"
useWebhookAlerts = input.bool(true, "Enable alert() JSON", group=grpWH, tooltip="Create one alert using Any alert() function call. Do not also subscribe to classic alerts for the same events.")
payloadDetail = input.string("Verbose", "Payload Detail", options=["Minimal", "Verbose"], group=grpWH)
token = input.string("", "Webhook Token", group=grpWH)
signalIdPrefix = input.string("talgos", "Signal ID Prefix", group=grpWH)
instanceId = input.string("default", "Instance ID", group=grpWH, tooltip="Use a distinct ID for each independently configured alert instance.")
customTag = input.string("", "Custom Tag", group=grpWH)
priceField = input.string("close", "Price Field", options=["close", "open", "high", "low", "hl2", "ohlc4"], group=grpWH)

f_escape(string value) =>
    string result = str.replace_all(value, "\\", "\\\\")
    result := str.replace_all(result, "\"", "\\\"")
    result := str.replace_all(result, "\n", "\\n")
    result := str.replace_all(result, "\r", "\\r")
    result := str.replace_all(result, "\t", "\\t")
    result

f_num(float value) =>
    na(value) ? "null" : str.tostring(value, format.mintick)

f_price(string field) =>
    switch field
        "open" => open
        "high" => high
        "low" => low
        "hl2" => hl2
        "ohlc4" => ohlc4
        => close

f_payload(string action, string eventName, string side) =>
    string id = signalIdPrefix + "_" + instanceId + "_" + syminfo.tickerid + "_" + timeframe.period + "_" + resolved + "_" + sourceChoice + "_" + eventName + "_" + side + "_" + str.tostring(time)
    string p = "{\"version\":\"1.1\",\"confirmed\":true"
    p += ",\"token\":\"" + f_escape(token) + "\",\"signal_id\":\"" + f_escape(id) + "\""
    p += ",\"tag\":\"" + f_escape(customTag) + "\",\"action\":\"" + action + "\",\"event\":\"" + eventName + "\",\"side\":\"" + side + "\""
    p += ",\"symbol\":\"" + f_escape(syminfo.ticker) + "\",\"tickerid\":\"" + f_escape(syminfo.tickerid) + "\",\"tf\":\"" + timeframe.period + "\""
    p += ",\"price\":" + f_num(f_price(priceField)) + ",\"price_field\":\"" + priceField + "\""
    p += ",\"time\":" + str.tostring(time) + ",\"time_close\":" + (na(time_close) ? "null" : str.tostring(time_close))
    if payloadDetail == "Verbose"
        p += ",\"exchange\":\"" + f_escape(syminfo.prefix) + "\",\"preset\":\"" + resolved + "\",\"source\":\"" + sourceChoice + "\""
        p += ",\"sma_len\":" + str.tostring(smaLen) + ",\"ema_len\":" + str.tostring(emaLen)
        p += ",\"o\":" + f_num(open) + ",\"h\":" + f_num(high) + ",\"l\":" + f_num(low) + ",\"c\":" + f_num(close)
        p += ",\"volume\":" + (na(volume) ? "null" : str.tostring(volume))
        p += ",\"sma\":" + f_num(smaLine) + ",\"ema\":" + f_num(emaLine) + ",\"upper\":" + f_num(upper) + ",\"lower\":" + f_num(lower)
        p += ",\"regime\":" + str.tostring(regime)
    p + "}"

// One selected JSON event per confirmed bar. All conditions are mutually exclusive.
if useWebhookAlerts and eventReady
    if emitBull
        alert(f_payload("buy", "reclaim", "bull"), alert.freq_once_per_bar_close)
    else if emitBear
        alert(f_payload("sell", "breakdown", "bear"), alert.freq_once_per_bar_close)
    else if emitRetestBull
        alert(f_payload("retest", "retest", "bull"), alert.freq_once_per_bar_close)
    else if emitRetestBear
        alert(f_payload("retest", "retest", "bear"), alert.freq_once_per_bar_close)
    else if emitInside
        alert(f_payload("neutral", "inside", "neutral"), alert.freq_once_per_bar_close)

// Alternative alert route. Conditions cannot become true before bar close.
alertcondition(emitBull, "Reclaim (confirmed)", "Reclaim | {{exchange}}:{{ticker}} | TF={{interval}} | Close={{close}}")
alertcondition(emitBear, "Breakdown (confirmed)", "Breakdown | {{exchange}}:{{ticker}} | TF={{interval}} | Close={{close}}")
alertcondition(emitRetestBull, "Retest Bull (confirmed)", "Return into band from above | {{ticker}} | TF={{interval}} | Close={{close}}")
alertcondition(emitRetestBear, "Retest Bear (confirmed)", "Return into band from below | {{ticker}} | TF={{interval}} | Close={{close}}")
alertcondition(emitInside, "Inside Band (confirmed)", "Inside band | {{ticker}} | TF={{interval}} | Close={{close}}")
````
