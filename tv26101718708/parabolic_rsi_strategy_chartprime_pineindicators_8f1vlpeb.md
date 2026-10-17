# Parabolic RSI Strategy [ChartPrime × PineIndicators]

- url: https://www.tradingview.com/script/8F1vlPeb-Parabolic-RSI-Strategy-ChartPrime-PineIndicators/
- type: strategy
- pine_id: PUB;93dcee53c1e84039ab761dc715217bab
- version: 1.0

## Description

This strategy combines the strengths of the Relative Strength Index (RSI) with a Parabolic SAR logic applied directly to RSI values.
[b]Full credit to ChartPrime for the original concept and indicator, licensed under the MPL 2.0.[/b]

It provides clear momentum-based trade signals using an innovative method that tracks RSI trend reversals via a customized Parabolic SAR, enhancing traditional oscillator strategies with dynamic trend confirmation.

[b]How It Works[/b]
The system overlays a Parabolic SAR on the RSI, detecting trend shifts in RSI itself rather than on price, offering early reversal insight with visual and algorithmic clarity.

[b]Core Components[/b]
[b]1. RSI-Based Trend Detection[/b]
[list]
[*] Calculates RSI using a customizable length (default: 14).
[*] Uses upper and lower thresholds (default: 70/30) for overbought/oversold zones.
[/list]

[b]2. Parabolic SAR Applied to RSI[/b]
[list]
[*] A custom Parabolic SAR function tracks momentum within the RSI, not price.
[*] This allows the system to capture RSI trend reversals more responsively.
[*] Configurable SAR parameters: Start, Increment, and Maximum acceleration.
[/list]

[b]3. Signal Generation[/b]
[list]
[*] [b]Long Entry:[/b] Triggered when the SAR flips below the RSI line.
[*] [b]Short Entry:[/b] Triggered when the SAR flips above the RSI line.
[*] Optional RSI filter ensures that:
[list]
[*] Long entries only occur above a minimum RSI (e.g. 50).
[*] Short entries only occur below a maximum RSI.
[/list]
[*] Built-in logic prevents new positions from being opened against trend without prior exit.
[/list]

[b]Trade Modes & Controls[/b]
[list]
[*] Choose from:
[list]
[*] [b]Long Only[/b]
[*] [b]Short Only[/b]
[*] [b]Long & Short[/b]
[/list]
[*] Optional setting to [b]reverse positions on opposite signal[/b] (instead of waiting for a flat close).
[/list]

[b]Visual Features[/b]
[b]1. RSI Plotting with Thresholds[/b]
[list]
[*] RSI is displayed in a dedicated pane with overbought/oversold fill zones.
[*] Custom horizontal lines mark threshold boundaries.
[/list]

[b]2. Parabolic SAR Overlay on RSI[/b]
[list]
[*] SAR dots color-coded for trend direction.
[*] Visible only when enabled by user input.
[/list]

[b]3. Entry & Exit Markers[/b]
[list]
[*] [b]Diamonds:[/b] Mark entry points (above for shorts, below for longs).
[*] [b]Crosses:[/b] Mark exit points.
[/list]

[b]Strategy Strengths[/b]
[list]
[*] Provides early momentum reversal entries without relying on price candles.
[*] Combines oscillator and trend logic without repainting.
[*] Works well in both trending and mean-reverting markets.
[*] Easy to configure with fine-tuned filter options.
[/list]

[b]Recommended Use Cases[/b]
[list]
[*] Intraday or swing traders who want to catch RSI-based reversals early.
[*] Traders seeking smoother signals than price-based Parabolic SAR entries.
[*] Users of RSI looking to reduce false positives via trend tracking.
[/list]

[b]Customization Options[/b]
[list]
[*] RSI Length and Thresholds.
[*] SAR Start, Increment, and Maximum values.
[*] Trade Direction Mode (Long, Short, Both).
[*] Optional RSI filter and reverse-on-signal settings.
[*] SAR dot color customization.
[/list]

[b]Conclusion[/b]
The Parabolic RSI Strategy [ChartPrime × PineIndicators] is an [b]innovative, non-repainting momentum strategy[/b] that enhances RSI-based systems with trend-confirming logic using Parabolic SAR. By applying SAR logic to RSI values, this strategy offers early, visualized, and filtered entries and exits that adapt to market dynamics.

[b]Credit to ChartPrime for the original methodology, published under MPL-2.0.[/b]

## Source Code

````pine
// © ChartPrime – MPL-2.0 : https://mozilla.org/MPL/2.0
//@version=6
strategy(
     "Parabolic RSI Strategy [ChartPrime × PineIndicators]",
     overlay            = false,                 // draw in its own pane
     default_qty_type   = strategy.percent_of_equity,
     default_qty_value  = 20,
     pyramiding         = 0,
     commission_value   = 0.01,
     margin_long        = 0,
     margin_short       = 0,
     slippage           = 1
     )

// ───────────── USER INPUTS ─────────────
len   = input.int(14,  "RSI length",            group = "RSI")
upper = input.int(70,  "RSI upper threshold",   group = "RSI")
lower = input.int(30,  "RSI lower threshold",   group = "RSI")

displaySAR = input.bool(true,  "Show SAR dots", group = "SAR")
sarStart   = input.float(0.02, "Start",     step = 0.01, inline = "SAR", group = "SAR")
sarInc     = input.float(0.02, "Increment", step = 0.01, inline = "SAR", group = "SAR")
sarMax     = input.float(0.20, "Maximum",   step = 0.01, inline = "SAR", group = "SAR")
colUp      = input.color(#EEA47F, "Up colour",   inline = "col", group = "SAR")
colDn      = input.color(#00539C, "Down colour", inline = "col", group = "SAR")

tradeDir = input.string(
     "Long & Short", "Trade direction",
     options = ["Long & Short", "Long Only", "Short Only"],
     group   = "Strategy options")
doReverse = input.bool(false, "Reverse on opposite signal",
                       group = "Strategy options")

useFilter   = input.bool(false, "Enable RSI filter", group = "RSI filter")
longRsiMin  = input.float(50,   "Long only if RSI ≥", group = "RSI filter")
shortRsiMax = input.float(50,   "Short only if RSI ≤", group = "RSI filter")

// ───────────── CALCULATIONS ─────────────
rsi = ta.rsi(close, len)

// — Parabolic SAR on RSI —
pineSar(src, start, inc, max) =>
    srcH = src + 1
    srcL = src - 1
    var float sar     = na
    var float ep      = na
    var float acc     = na
    var bool  isBelow = false
    bool firstBar     = false

    if bar_index <= len + 2
        isBelow  := src > src[1]
        ep       := isBelow ? srcH : srcL
        sar      := isBelow ? srcL[1] : srcH[1]
        firstBar := true
        acc      := start

    sar += acc * (ep - sar)

    if (isBelow and sar > srcL) or (not isBelow and sar < srcH)
        firstBar := true
        isBelow  := not isBelow
        sar      := isBelow ? math.max(srcH, ep) : math.min(srcL, ep)
        ep       := isBelow ? srcL : srcH
        acc      := start

    if not firstBar
        if (isBelow and srcH > ep) or (not isBelow and srcL < ep)
            ep  := isBelow ? math.max(srcH, ep) : math.min(srcL, ep)
            acc := math.min(acc + inc, max)

    sar := isBelow ? math.min(sar, srcL[1]) : math.max(sar, srcH[1])
    if bar_index > 1
        sar := isBelow ? math.min(sar, srcL[2]) : math.max(sar, srcH[2])

    [sar, isBelow]

[sarRsi, isBelow] = pineSar(rsi, sarStart, sarInc, sarMax)

// — Signals & filters —
sigLong  = ta.change(isBelow) and  isBelow
sigShort = ta.change(isBelow) and not isBelow

longOK  = not useFilter or (rsi >= longRsiMin)
shortOK = not useFilter or (rsi <= shortRsiMax)

allowLong  = tradeDir != "Short Only"
allowShort = tradeDir != "Long Only"

// ───────────── ORDER MANAGEMENT ─────────────
flatten(id) =>
    if strategy.position_size != 0
        strategy.close(id)     // close position if one exists
    0                          // return an int → compiler happy

if sigLong and longOK
    if allowLong
        if strategy.position_size <= 0
            if strategy.position_size < 0
                strategy.close("Short")
            strategy.entry("Long", strategy.long)
    else
        flatten("Short")

if sigShort and shortOK
    if allowShort
        if strategy.position_size >= 0
            if strategy.position_size > 0
                strategy.close("Long")
            strategy.entry("Short", strategy.short)
    else
        flatten("Long")

// ───────────── FLAGS FOR PLOTTING ─────────────
entryLong   = allowLong  and sigLong  and longOK
entryShort  = allowShort and sigShort and shortOK
exitLong    = strategy.position_size[1] >  0 and strategy.position_size == 0
exitShort   = strategy.position_size[1] <  0 and strategy.position_size == 0

// ───────────── VISUALS ─────────────
plot(rsi, "RSI", color = chart.fg_color)
uLine = hline(upper, "Upper", color = #787B86)
lLine = hline(lower, "Lower", color = #787B86)
fill(uLine, lLine, color = #c292571a)

plot(displaySAR ? sarRsi : na, "SAR dots",
     style = plot.style_circles,
     color = isBelow ? colUp : colDn)

// Entry diamonds
plotshape(entryLong,
          title    = "Entry long",
          style    = shape.diamond,
          location = location.belowbar,
          color    = colUp,
          size     = size.tiny,
          force_overlay = true)

plotshape(entryShort,
          title    = "Entry short",
          style    = shape.diamond,
          location = location.abovebar,
          color    = colDn,
          size     = size.tiny,
          force_overlay = true)

// Exit crosses
plotshape(exitLong,
          title    = "Exit long",
          style    = shape.xcross,
          location = location.belowbar,
          color    = colUp,
          size     = size.tiny,
          force_overlay = true)

plotshape(exitShort,
          title    = "Exit short",
          style    = shape.xcross,
          location = location.abovebar,
          color    = colDn,
          size     = size.tiny,
          force_overlay = true)

// Dummy invisible plot to guarantee the script always has a plotting call
plotchar(na, title = "invisible", location = location.top)
````
