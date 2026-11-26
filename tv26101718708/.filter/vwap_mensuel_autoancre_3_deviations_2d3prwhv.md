# VWAP Mensuel Auto-Ancre (3 Deviations)

- url: https://www.tradingview.com/script/2d3prWhv/
- type: indicator
- pine_id: PUB;476b12b987d440b2a4fe7ece4d85d293
- version: 1.0

## Description

Monthly Auto-Anchored VWAP (3 Deviations) – Indicator Overview
Name: Monthly Auto-Anchored VWAP (3 Deviations)
Short Title: Monthly VWAP 3D
Type: Overlay Indicator (Plotted on Price Chart)
Key Features
This indicator calculates a Volume-Weighted Average Price (VWAP) anchored to the start of each month, providing a dynamic reference point for intramonth trading. It includes three customizable standard deviation bands, allowing traders to assess volatility, mean reversion zones, and potential support/resistance levels.

Customization Options
1. Calculation Settings

Source: Choose the price input (default: HLC/3).
Break Lines at New Month: Toggle whether to reset the VWAP and deviation lines at the start of each month.

2. Main VWAP Line

Visibility: Show/hide the primary VWAP line.
Appearance: Adjust color, line width (1–5), and style (solid, dashed, or dotted).

3. Deviation Bands (1–3)
Each deviation band is fully configurable:

Visibility: Show/hide individual bands.
Multiplier: Set the standard deviation multiplier (e.g., 1.0, 2.0, 3.0).
Appearance: Customize color, line width, and style (solid, dashed, or dotted).

How It Works

VWAP Calculation: Computes the volume-weighted average price from the start of the month, resetting automatically at month-end (or continuing seamlessly if disabled).
Standard Deviation Bands: Plots upper/lower bands based on the selected multipliers, helping identify overbought/oversold conditions relative to the monthly VWAP.
Auto-Anchoring: Eliminates manual anchor point selection, ideal for swing trading or intramonth analysis.

Use Cases

Trend Confirmation: Price above/below VWAP may signal bullish/bearish bias.
Mean Reversion: Deviations act as dynamic support/resistance zones.
Volatility Assessment: Wider bands indicate higher volatility; tighter bands suggest consolidation.

Why This Indicator?

Adaptive: Automatically adjusts to new monthly data.
Flexible: Customize bands to fit your trading strategy (e.g., tighter for scalping, wider for swing trading).
Clarity: Clean, non-cluttered visualization with user-defined styling.

Ideal for: Traders seeking a structured, volume-aware tool to gauge monthly trends and volatility without manual adjustments.

Personal Note :
"This indicator is like a wise old trader—it doesn’t just show you the average; it maps the battlefield of price and volume. Use it to spot when the market is stretching too far (deviations) or when it’s coiling for a move (VWAP as magnet). But remember: even the best tools need context. Combine it with volume spikes or momentum oscillators for higher-probability setups. And if the bands are too wide? The market’s whispering ‘caution’—listen."

## Source Code

````pine
//@version=6
indicator("VWAP Mensuel Auto-Ancre (3 Deviations)", shorttitle="Monthly VWAP 3D", overlay=true)

groupCalc = "Calcul"
src = input.source(hlc3, "Source", group=groupCalc)
breakAtNewMonth = input.bool(true, "Couper les lignes au debut du mois", group=groupCalc)

groupMain = "VWAP Principal"
showMain = input.bool(true, "Afficher VWAP principal", group=groupMain)
mainColor = input.color(color.new(color.white, 0), "Couleur", group=groupMain)
mainWidth = input.int(2, "Largeur", minval=1, maxval=5, group=groupMain)
mainStyleInput = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=groupMain)

groupDev1 = "Deviation 1"
showDev1 = input.bool(true, "Afficher", group=groupDev1)
mult1 = input.float(1.0, "Multiplicateur", minval=0.0, step=0.1, group=groupDev1)
dev1Color = input.color(color.new(color.aqua, 0), "Couleur", group=groupDev1)
dev1Width = input.int(1, "Largeur", minval=1, maxval=5, group=groupDev1)
dev1StyleInput = input.string("Dashed", "Style", options=["Solid", "Dashed", "Dotted"], group=groupDev1)

groupDev2 = "Deviation 2"
showDev2 = input.bool(true, "Afficher", group=groupDev2)
mult2 = input.float(2.0, "Multiplicateur", minval=0.0, step=0.1, group=groupDev2)
dev2Color = input.color(color.new(color.orange, 0), "Couleur", group=groupDev2)
dev2Width = input.int(1, "Largeur", minval=1, maxval=5, group=groupDev2)
dev2StyleInput = input.string("Dashed", "Style", options=["Solid", "Dashed", "Dotted"], group=groupDev2)

groupDev3 = "Deviation 3"
showDev3 = input.bool(true, "Afficher", group=groupDev3)
mult3 = input.float(3.0, "Multiplicateur", minval=0.0, step=0.1, group=groupDev3)
dev3Color = input.color(color.new(color.fuchsia, 0), "Couleur", group=groupDev3)
dev3Width = input.int(1, "Largeur", minval=1, maxval=5, group=groupDev3)
dev3StyleInput = input.string("Dotted", "Style", options=["Solid", "Dashed", "Dotted"], group=groupDev3)

toLineStyle(styleInput) =>
    styleInput == "Dashed" ? plot.linestyle_dashed : styleInput == "Dotted" ? plot.linestyle_dotted : plot.linestyle_solid

mainStyle = toLineStyle(mainStyleInput)
dev1Style = toLineStyle(dev1StyleInput)
dev2Style = toLineStyle(dev2StyleInput)
dev3Style = toLineStyle(dev3StyleInput)

bool newMonth = timeframe.change("M")

var float sumPV = na
var float sumV = na
var float sumP2V = na

if barstate.isfirst or newMonth
    sumPV := src * volume
    sumV := volume
    sumP2V := src * src * volume
else
    sumPV += src * volume
    sumV += volume
    sumP2V += src * src * volume

safeVolume = math.max(sumV, 1.0)
monthlyVwap = sumPV / safeVolume
variance = math.max(sumP2V / safeVolume - monthlyVwap * monthlyVwap, 0.0)
monthlyStdev = math.sqrt(variance)

lineMask = breakAtNewMonth and newMonth ? na : 1.0

mainPlot = showMain ? monthlyVwap * lineMask : na

u1 = showDev1 ? (monthlyVwap + mult1 * monthlyStdev) * lineMask : na
l1 = showDev1 ? (monthlyVwap - mult1 * monthlyStdev) * lineMask : na

u2 = showDev2 ? (monthlyVwap + mult2 * monthlyStdev) * lineMask : na
l2 = showDev2 ? (monthlyVwap - mult2 * monthlyStdev) * lineMask : na

u3 = showDev3 ? (monthlyVwap + mult3 * monthlyStdev) * lineMask : na
l3 = showDev3 ? (monthlyVwap - mult3 * monthlyStdev) * lineMask : na

plot(mainPlot, title="VWAP Mensuel", color=mainColor, linewidth=mainWidth, style=plot.style_line, linestyle=mainStyle)
plot(u1, title="Deviation 1 Haute", color=dev1Color, linewidth=dev1Width, style=plot.style_line, linestyle=dev1Style)
plot(l1, title="Deviation 1 Basse", color=dev1Color, linewidth=dev1Width, style=plot.style_line, linestyle=dev1Style)
plot(u2, title="Deviation 2 Haute", color=dev2Color, linewidth=dev2Width, style=plot.style_line, linestyle=dev2Style)
plot(l2, title="Deviation 2 Basse", color=dev2Color, linewidth=dev2Width, style=plot.style_line, linestyle=dev2Style)
plot(u3, title="Deviation 3 Haute", color=dev3Color, linewidth=dev3Width, style=plot.style_line, linestyle=dev3Style)
plot(l3, title="Deviation 3 Basse", color=dev3Color, linewidth=dev3Width, style=plot.style_line, linestyle=dev3Style)
````
