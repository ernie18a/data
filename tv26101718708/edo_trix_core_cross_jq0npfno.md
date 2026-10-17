# Edo TRIX Core Cross

- url: https://www.tradingview.com/script/jQ0npfNo-Edo-TRIX-Core-Cross/
- type: indicator
- pine_id: PUB;d85db14910e04d2295cbb5904b0a7d60
- version: 1.0

## Description

Edo TRIX Core Cross — Dual TRIX Oscillator with Four-State Momentum Histogram and Cross Detection

Momentum tells you more than direction — it tells you whether a move is gaining force, holding steady or already losing energy. Most momentum readings collapse all of that into a single color-coded line. Edo TRIX Core Cross separates it into two things the trader can read at a glance: where the momentum stands, and what it is doing right now.

The indicator runs two TRIX oscillators — one fast, one slow — and plots their difference as a histogram color-coded across four states: bullish expansion, bullish fading, bearish expansion and bearish fading. An information panel shows the current bias, the momentum state and the configured lengths bar by bar. Cross markers print directly on the pane when the fast line crosses above or below the slow line.

What the indicator does

The TRIX oscillator is built on a triple exponentially smoothed moving average. Each additional smoothing pass removes progressively more short-cycle noise, leaving only the rate of change of the underlying trend. That is the core reason TRIX tends to produce fewer false signals than single or double-smoothed oscillators: most of the short-term reactivity has already been filtered out by the time the rate of change is calculated.

Edo TRIX Core Cross takes that base and adds a second layer of context. Rather than reading a single TRIX value in isolation, the indicator compares a Fast TRIX against a Slow TRIX and tracks their relationship continuously. The result is a cleaner momentum signal that still retains the ability to flag directional changes before they become obvious on price.

The two lines

Fast TRIX — default length 5. The reactive line. It responds first to changes in short-term momentum and acts as the dynamic reference of the system.

Slow TRIX — default length 9. The stabilizing line. It filters noise and represents the underlying momentum trend. Its movements are gradual and less influenced by temporary shifts in price action.

When Fast is above Slow, short-term momentum is outpacing the reference and the bias is bullish. When Fast is below Slow, short-term momentum is giving ground and the bias is bearish. The distance between the two lines tells you how strong that bias is at any given moment.

The four-state histogram

The histogram plots the difference between Fast TRIX and Slow TRIX. Most histograms in the public domain color bars using two states — green above zero, red below. Edo TRIX Core Cross uses four:

Bullish expansion (solid green) — histogram is positive and larger than the previous bar. Momentum is accelerating upward.

Bullish fading (faded green) — histogram is positive but equal to or smaller than the previous bar. Momentum is still positive but losing strength.

Bearish expansion (solid red) — histogram is negative and more negative than the previous bar. Momentum is accelerating downward.

Bearish fading (faded red) — histogram is negative but equal to or less negative than the previous bar. Downside momentum is easing.

This distinction matters because momentum does not reverse in a single bar. It decelerates, flattens, and only then turns. The faded states capture that deceleration in real time — a transition from solid to faded on the histogram is often the first visible sign that the current move is running out of fuel.

Information panel

A compact on-pane panel keeps the key readings visible bar by bar:

TRIX CROSS — header.
Bias — BULLISH when Fast is above Slow, BEARISH when Fast is below Slow. Text color matches the bias state.
Momentum — combines the histogram direction and its acceleration state into four possible readings: Expanding ▲, Fading ▼, Expanding ▼, Fading ▲. This single field mirrors the four-state histogram in text form.
Fast / Slow — the currently configured lengths for both lines.

Position and theme are configurable: four corner positions plus Dark or Light mode to match the chart background.

Cross detection

Every time Fast crosses Slow, the indicator prints a marker on the pane. A green upward triangle at the bottom marks a bullish cross; a red downward triangle at the top marks a bearish cross. The markers are explicit and easy to see without overlapping the lines themselves.

A cross should always be read in context. Its relevance depends on where the lines sit relative to the zero line at the moment of the cross, what the histogram is doing around it, and how the cross aligns with the price structure on the main chart. A bullish cross formed well below zero with both lines still in negative territory is a very different event from a bullish cross formed above zero during an ongoing expansion.

Settings

TRIX Settings — Fast Length (default 5) and Slow Length (default 9).

Display — Show Histogram, Show TRIX Lines and Show Cross Markers, each toggled independently. Fast and Slow line colors and widths, plus bull and bear cross marker colors.

Panel — Panel Position (four corners) and Panel Theme (Dark / Light).

How to read it

Start with the bias. Fast above Slow and above the zero line, with a solid-green histogram, is the cleanest bullish state the indicator produces. Fast below Slow and below zero, with a solid-red histogram, is the cleanest bearish state.

Then watch the histogram color shift between solid and faded. Solid bars mean the current move is still accelerating; faded bars mean it is slowing. Repeated faded bars after an extended expansion often precede a cross, giving advance notice that the bias may be about to flip.

Use cross markers as confirmation events rather than triggers. A bullish cross above zero with prior bullish expansion carries more weight than a bullish cross near the zero line in a directionless market. Combine the cross location, the histogram state at the cross bar and the surrounding price structure before drawing conclusions.

Alerts

Four alert conditions are included and can be configured from the standard TradingView alert dialog:

TRIX Bull Cross — Fast crosses above Slow.
TRIX Bear Cross — Fast crosses below Slow.
Histogram Crossed Zero Up — the histogram crosses above the zero line, signaling bullish pressure forming.
Histogram Crossed Zero Down — the histogram crosses below the zero line, signaling bearish pressure forming.

The zero-line alerts are independent of the cross alerts. The histogram can cross zero without Fast and Slow crossing each other, which lets the trader catch shifts in momentum pressure that have not yet produced a formal cross between the lines.

Open source

Edo TRIX Core Cross is released as an open-source indicator. The full Pine Script is publicly available on TradingView for study, adaptation and integration into any workflow. Default parameters are tuned for immediate use across multiple asset classes and timeframes.

Important

This indicator is a technical analysis tool intended for educational and informational purposes only. It does not generate automatic buy or sell signals, does not predict tops or bottoms, and is not a substitute for proper risk management or the trader's own judgment. Always use it within a broader analysis framework.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────
// ███████╗██████╗  ██████╗ ██╗      █████╗ ██████╗
// ██╔════╝██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗
// █████╗  ██║  ██║██║   ██║██║     ███████║██████╔╝
// ██╔══╝  ██║  ██║██║   ██║██║     ██╔══██║██╔══██╗
// ███████╗██████╔╝╚██████╔╝███████╗██║  ██║██████╔╝
// ╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝
// ─────────────────────────────────────────────────────────────────
// ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗███████╗████████╗███████╗
// ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝██╔════╝
// ██╔████╔██║███████║██████╔╝█████╔╝ █████╗     ██║   ███████╗
// ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝     ██║   ╚════██║
// ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗███████╗   ██║   ███████║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝
// ─────────────────────────────────────────────────────────────────
// © Edolab Markets


//@version=6
indicator("Edo TRIX Core Cross", shorttitle="Edo TRIX Core Cross", overlay=false)

// ================== INPUTS ==================
trixFastLen     = input.int(5, "Fast Length", minval=1, group="TRIX Settings")
trixSlowLen     = input.int(9, "Slow Length", minval=1, group="TRIX Settings")
showHistogram   = input.bool(true, "Show Histogram",     group="Display")
showLines       = input.bool(true, "Show TRIX Lines",    group="Display")
showCrossShapes = input.bool(true, "Show Cross Markers", group="Display")
colorFastInput  = input.color(#2962FF, "Fast Line Color", group="Display")
colorSlowInput  = input.color(#E6B800, "Slow Line Color", group="Display")
lineWidthFast   = input.int(3, "Fast Line Width", minval=1, maxval=5, group="Display")
lineWidthSlow   = input.int(1, "Slow Line Width", minval=1, maxval=5, group="Display")
colorBullShape  = input.color(#1FA64B, "Bull Cross Color", group="Display")
colorBearShape  = input.color(#C73535, "Bear Cross Color", group="Display")
panelPosition   = input.string("Top Right", "Panel Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group="Panel")
panelTheme      = input.string("Dark", "Panel Theme",
     options=["Dark", "Light"],
     group="Panel")

// ================== COLORS ==================
colorBullStrong = color.new(#1FA64B, 0)
colorBullFade   = color.new(#1FA64B, 60)
colorBearStrong = color.new(#C73535, 0)
colorBearFade   = color.new(#C73535, 60)
colorZero       = color.new(color.gray, 60)

// ================== PANEL THEME ==================
panelBg       = panelTheme == "Dark" ? color.new(#1A1A2E, 10) : color.new(color.white, 5)
panelBorder   = panelTheme == "Dark" ? color.new(color.gray, 50) : color.new(color.gray, 50)
panelTextMain = panelTheme == "Dark" ? color.new(color.white, 0) : color.new(color.black, 0)
panelTextSub  = panelTheme == "Dark" ? color.new(color.white, 30) : color.new(color.black, 30)

// ================== TRIX CALCULATION ==================
trix(src, len) =>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    e3 = ta.ema(e2, len)
    (e3 - e3[1]) / e3[1] * 100

trixFast = trix(close, trixFastLen)
trixSlow = trix(close, trixSlowLen)
diff     = trixFast - trixSlow

// ================== HISTOGRAM COLOR (4 TONES BY ACCELERATION) ==================
histColor =
     diff >= 0 and diff > diff[1]  ? colorBullStrong :
     diff >= 0 and diff <= diff[1] ? colorBullFade   :
     diff <  0 and diff < diff[1]  ? colorBearStrong :
                                      colorBearFade

// ================== CROSS DETECTION ==================
bullCross = ta.crossover(trixFast, trixSlow)
bearCross = ta.crossunder(trixFast, trixSlow)

// ================== PLOTS ==================
plot(showLines ? trixFast : na, "TRIX Fast", color=colorFastInput, linewidth=lineWidthFast)
plot(showLines ? trixSlow : na, "TRIX Slow", color=colorSlowInput, linewidth=lineWidthSlow)
plot(showHistogram ? diff : na,  "Histogram", style=plot.style_columns, color=histColor)
hline(0, "Zero Line", color=colorZero, linestyle=hline.style_dashed)

// ================== CROSS MARKERS ==================
plotshape(showCrossShapes and bullCross, "Bull Cross",
     style=shape.triangleup, location=location.bottom,
     color=colorBullShape, size=size.small)
plotshape(showCrossShapes and bearCross, "Bear Cross",
     style=shape.triangledown, location=location.top,
     color=colorBearShape, size=size.small)

// ================== PANEL ==================
var table panel = table.new(
     panelPosition == "Top Right"    ? position.top_right    :
     panelPosition == "Top Left"     ? position.top_left     :
     panelPosition == "Bottom Right" ? position.bottom_right :
                                       position.bottom_left,
     2, 4,
     bgcolor=panelBg,
     border_color=panelBorder,
     border_width=1,
     frame_color=panelBorder,
     frame_width=1)

trixState    = trixFast > trixSlow ? "BULLISH" : "BEARISH"
trixStateCol = trixFast > trixSlow ? colorBullStrong : colorBearStrong

histState =
     diff >= 0 and diff > diff[1]  ? "Expanding ▲" :
     diff >= 0 and diff <= diff[1] ? "Fading ▼"    :
     diff <  0 and diff < diff[1]  ? "Expanding ▼" :
                                      "Fading ▲"
histStateCol =
     diff >= 0 and diff > diff[1]  ? colorBullStrong :
     diff >= 0 and diff <= diff[1] ? colorBullFade   :
     diff <  0 and diff < diff[1]  ? colorBearStrong :
                                      colorBearFade

if barstate.islast
    table.cell(panel, 0, 0, "TRIX CROSS",
         text_color=panelTextMain, text_size=size.small,
         bgcolor=panelBg)
    table.cell(panel, 1, 0, "Edo TRIX Core Cross",
         text_color=panelTextSub, text_size=size.tiny,
         bgcolor=panelBg)

    table.cell(panel, 0, 1, "Bias",
         text_color=panelTextMain, text_size=size.tiny,
         bgcolor=panelBg)
    table.cell(panel, 1, 1, trixState,
         text_color=trixStateCol, text_size=size.small,
         bgcolor=panelBg)

    table.cell(panel, 0, 2, "Momentum",
         text_color=panelTextMain, text_size=size.tiny,
         bgcolor=panelBg)
    table.cell(panel, 1, 2, histState,
         text_color=histStateCol, text_size=size.small,
         bgcolor=panelBg)

    table.cell(panel, 0, 3, "Fast / Slow",
         text_color=panelTextMain, text_size=size.tiny,
         bgcolor=panelBg)
    table.cell(panel, 1, 3, str.tostring(trixFastLen) + " / " + str.tostring(trixSlowLen),
         text_color=panelTextSub, text_size=size.tiny,
         bgcolor=panelBg)

// ================== ALERTS ==================
alertcondition(bullCross,
     "TRIX Bull Cross",
     "Edo TRIX Core Cross — Fast crossed above Slow. Bullish momentum.")
alertcondition(bearCross,
     "TRIX Bear Cross",
     "Edo TRIX Core Cross — Fast crossed below Slow. Bearish momentum.")
alertcondition(ta.crossover(diff, 0),
     "Histogram Crossed Zero Up",
     "Edo TRIX Core Cross — Histogram crossed above zero. Bullish pressure.")
alertcondition(ta.crossunder(diff, 0),
     "Histogram Crossed Zero Down",
     "Edo TRIX Core Cross — Histogram crossed below zero. Bearish pressure.")
````
