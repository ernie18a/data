# Edo Ichimoku State

- url: https://www.tradingview.com/script/upOo2wDB-Edo-Ichimoku-State/
- type: indicator
- pine_id: PUB;e8eccab508e94aa982ee789f73bc3e07
- version: 1.0

## Description

Edo Ichimoku State — Five-State Structural Classifier for Ichimoku Kinko Hyo

[image]https://www.tradingview.com/x/DKtKO0DC/[/image]

Ichimoku Kinko Hyo is one of the most complete systems available for reading market structure at a single glance. Its name means roughly "one-glance equilibrium chart", yet in practice that single glance is anything but simple: a reader has to combine the position of price relative to the cloud, the slope of the cloud itself, the relationship between Tenkan and Kijun, and the position of the Chikou Span relative to past price before deciding whether the context is a confirmed trend, a directional bias, a transition, or no direction at all.

Edo Ichimoku State keeps that full engine intact and does the synthesis for you. It calculates the five classical Ichimoku lines with their original 9 / 26 / 52 periods, evaluates four independent conditions bar by bar, and returns a single market state, a dual Bull / Bear score, and a summary panel listing the conditions that support the reading. The aim is to turn a visually demanding but technically powerful system into a direct reading surface, without simplifying or discarding any of its original components.

WHAT IT DOES (AND WHAT IT IS NOT)

The indicator is a complete implementation of the Ichimoku system: its five lines, the cloud projected forward by the classical displacement, a discrete classification into five states, a 0-to-4 Bull / Bear score, an optional state-colored background, and a corner panel. By default only the cloud and the colored background are shown, keeping the chart clean; every other line can be turned on individually for those who want the full detail.

It is not a closed trading system or an automatic entry/exit signal generator. It does not predict specific highs or lows, nor does it replace risk management or the trader's own judgment. It is also not a simplified Ichimoku: all five original components are present and calculated with the canonical periods.

THE FIVE LINES

Tenkan-sen (Conversion Line): the midpoint of the last 9 periods' range, (highest high + lowest low) / 2. It is the most reactive line and the first to turn on a reversal.

Kijun-sen (Base Line): the midpoint of the last 26 periods' range. It acts as an intermediate structural reference and as classical dynamic support/resistance.

Senkou Span A (Leading Span A): (Tenkan + Kijun) / 2, displaced 26 bars forward. The first edge of the cloud; it reacts faster than Senkou B to trend changes.

Senkou Span B (Leading Span B): the midpoint of the last 52 periods' range, displaced 26 bars forward. The second, much more stable edge of the cloud; it defines the structural floor or ceiling.

Chikou Span (Lagging Line): the current close, displaced 26 bars backward. It compares current price to the price 26 bars ago and provides historical confirmation.

THE CLOUD (KUMO)

The cloud is the most characteristic element of Ichimoku and the only line shown enabled by default. It is the fill between the two Senkou Spans projected 26 bars forward. When Senkou A is above Senkou B the cloud is bullish and painted in a soft teal green; when Senkou A is below Senkou B the cloud is bearish and painted in a soft coral red. A crossover of the two spans flips the cloud color entirely, an event called a Cloud Flip.

Reading the Kumo is straightforward: price above the cloud is a bullish structural bias with the cloud acting as dynamic support; price below the cloud is a bearish bias with the cloud acting as dynamic resistance; price inside the cloud means no clear direction, and the indicator classifies that situation as Undefined. The thickness of the cloud is proportional to the strength of that support or resistance: a thin cloud breaks easily, a thick one is rarely crossed in a single move. Because the cloud is projected 26 bars forward, it also lets you anticipate the structural support or resistance price will face in the immediate future.

THE FIVE-STATE CLASSIFICATION

The market state is reduced to one of five discrete configurations, ordered from maximum bullish strength to maximum bearish strength:

Confirmed Up — all four bullish conditions active simultaneously.
Bias Up — at least two bullish conditions active and dominating over the bearish ones.
Undefined — price inside the cloud, or a balance between bullish and bearish conditions.
Bias Down — at least two bearish conditions active and dominating over the bullish ones.
Confirmed Down — all four bearish conditions active simultaneously.

The state is built from four independent conditions evaluated on every bar. Price vs Cloud checks whether price is above the cloud (bullish) or below it (bearish); if price is inside the cloud, neither side counts and the state is forced directly to Undefined, following the original Ichimoku logic that there is no operational direction inside the Kumo. Cloud Bias checks whether Senkou A is above or below Senkou B, measuring the projected direction of the cloud. TK vs KJ checks whether Tenkan-sen is above or below Kijun-sen, measuring recent momentum. Chikou Free checks whether current price is above or below the price 26 bars ago, measuring historical confirmation.

BULL SCORE AND BEAR SCORE

Alongside the discrete state, the indicator publishes two complementary scores. The Bull Score counts how many bullish conditions are active on the current bar, out of four; the Bear Score counts how many bearish conditions are active, built from the inverse of each bullish condition. The two are not strictly complementary: both can sit at intermediate values at the same time, for example Bull 2/4 and Bear 2/4 when the cloud is mixed or price is right on its edge. The discrete state resolves which reading prevails. The scores are especially useful for comparing bars within the same state: a Bias Up with Bull 3/4 and Bear 1/4 is more solid than a Bias Up with Bull 2/4 and Bear 2/4, even though both carry the same label.

INFORMATION PANEL

A summary panel sits in one corner of the chart and condenses the Ichimoku state on the most recent closed bar into seven rows. The first row shows the current state label together with its duration in bars (for example 21b), which tells you how long the market has held the same configuration. The next four rows show the individual conditions: Price vs Cloud (Above / Inside / Below), Cloud Bias (Bullish / Bearish), TK vs KJ (TK greater or less than KJ), and Chikou Free (Above / Below / Level). The last two rows show the Bull Score and Bear Score as N / 4. Panel position (any of the four corners), size (Small / Medium) and theme (Dark / Light) are all configurable.

HOW TO READ IT

The state and the score give an immediate reading, but the indicator gains depth when combined with recent transition history. A clean bullish activation typically runs Undefined to Bias Up to Confirmed Up over a few bars, with a Cloud Flip from bearish to bullish and a Bull Score climbing toward 4/4. Bullish exhaustion often shows a long-lived Confirmed Up whose Bull Score oscillates between 3/4 and 4/4 without settling. A drop into the cloud turns the state to Undefined and tends to resolve either as a bounce on Senkou A back into Bias Up, a full crossing that exits below into Bias Down, or sideways action inside the Kumo. A bearish confirmation sees price break the cloud downward while Cloud Bias turns bearish, TK falls under KJ and Chikou stays below historical price, moving the state Undefined to Bias Down to Confirmed Down. The logic is ticker-agnostic and works the same on stocks, indices, crypto, forex and commodities, provided the asset has enough liquidity for stable highs/lows.

ALERTS

The indicator publishes ten native alert conditions, all configured from TradingView's standard alert dialog by picking the event from the dropdown. Five state alerts fire when the state newly enters Confirmed Up, Confirmed Down, Bias Up, Bias Down or Undefined. Two price-vs-cloud alerts fire when the close crosses above or below the cloud. Two Cloud Flip alerts fire when Senkou A crosses above Senkou B (Cloud Flip Bull) or below it (Cloud Flip Bear). Two TK/KJ cross alerts fire when Tenkan crosses above or below Kijun. State-change alerts fire on the exact bar the new state first appears; to avoid intrabar triggers, set the alert to Once Per Bar Close.

CONFIGURATION

Ichimoku periods default to the canonical 9 (Tenkan), 26 (Kijun) and 52 (Senkou Span B), with both the forward cloud displacement and the backward Chikou displacement at 26; these match the original system and changing them is only recommended for specific studies. The Lines section toggles Tenkan-sen, Kijun-sen and Chikou Span (hidden by default) and the Kumo fill (enabled), with a Cloud Opacity from 40 to 95. The State section enables a state-colored background (on by default, opacity 70 to 98) and an optional Paint Candles by State mode. The five state colors are each customizable, and the panel can be shown or hidden, repositioned to any corner, and sized Small or Medium.

OPEN SOURCE

Edo Ichimoku State is published on TradingView as a free, open-source indicator. Any user with an active account can add it to their charts at no cost and use it on whatever timeframes and assets they consider appropriate. You are welcome to study the code and learn from how the four conditions are formalized into the five-state classification.

This indicator is a technical analysis tool for educational and informational purposes only. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading financial markets involves significant risk of capital loss. Past performance does not guarantee future results. Always use proper risk management.

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
indicator("Edo Ichimoku State", overlay=true, max_labels_count=500)

// ================== INPUTS — ICHIMOKU ==================
tenkanLen   = input.int(9,  "Tenkan-sen Length",  minval=1, group="Ichimoku")
kijunLen    = input.int(26, "Kijun-sen Length",   minval=1, group="Ichimoku")
senkouBLen  = input.int(52, "Senkou Span B Length", minval=1, group="Ichimoku")
displaceLen = input.int(26, "Cloud Displacement",  minval=0, group="Ichimoku", tooltip="Forward projection of the Kumo (cloud).")
laggingLen  = input.int(26, "Chikou Displacement", minval=0, group="Ichimoku", tooltip="Backward projection of Chikou span.")

// ================== INPUTS — LINES VISIBILITY ==================
showTenkan  = input.bool(false, "Show Tenkan-sen",  group="Lines", tooltip="Hidden by default — the panel reads the state, no visual noise.")
showKijun   = input.bool(false, "Show Kijun-sen",   group="Lines")
showChikou  = input.bool(false, "Show Chikou Span", group="Lines")
showCloud   = input.bool(true,  "Show Kumo (Cloud)", group="Lines")
cloudOpacity= input.int(80, "Cloud Opacity", minval=40, maxval=95, group="Lines")

// ================== INPUTS — STATE ==================
showBackground = input.bool(true, "Color Background by State", group="State")
bgOpacity      = input.int(90, "Background Opacity", minval=70, maxval=98, group="State")
paintCandles   = input.bool(false, "Paint Candles by State", group="State")

// ================== INPUTS — STYLE ==================
colorStrongBull = input.color(color.rgb(0, 200, 110),    "Confirmed Up",   group="Style")
colorBull       = input.color(color.rgb(120, 220, 170),  "Bias Up",        group="Style")
colorFlat       = input.color(color.rgb(150, 150, 160),  "Undefined",      group="Style")
colorBear       = input.color(color.rgb(240, 140, 140),  "Bias Down",      group="Style")
colorStrongBear = input.color(color.rgb(230, 70, 70),    "Confirmed Down", group="Style")
themeMode       = input.string("Dark", "Theme", options=["Dark", "Light"], group="Style")

// ================== INPUTS — PANEL ==================
showPanel = input.bool(true, "Show Panel", group="Panel")
panelPos  = input.string("Top Right", "Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Panel")
panelSize = input.string("Medium", "Panel Size", options=["Small", "Medium"], group="Panel")

// ================== THEME ==================
isDark        = themeMode == "Dark"
panelBg       = isDark ? color.new(#1A1A2E, 10)     : color.new(color.white, 5)
panelHeader   = isDark ? color.new(#2A2E39, 0)      : color.new(#D1D4DC, 0)
panelSubBg    = isDark ? color.new(#363A45, 0)      : color.new(#E0E3EB, 0)
panelText     = isDark ? color.new(color.white, 0)  : color.new(color.black, 0)
panelTextSub  = isDark ? color.new(color.white, 30) : color.new(color.black, 30)
panelBorder   = color.new(color.gray, 50)
panSize       = panelSize == "Small" ? size.tiny : size.small

// ================== ICHIMOKU CALCS ==================
f_donchianMid(len) =>
    (ta.highest(high, len) + ta.lowest(low, len)) / 2

tenkan   = f_donchianMid(tenkanLen)
kijun    = f_donchianMid(kijunLen)
senkouA  = (tenkan + kijun) / 2
senkouB  = f_donchianMid(senkouBLen)
chikou   = close

// Cloud values displaced forward (current bar reads the cloud projected from the past)
cloudTop = math.max(senkouA[displaceLen], senkouB[displaceLen])
cloudBot = math.min(senkouA[displaceLen], senkouB[displaceLen])
cloudUp  = senkouA[displaceLen] > senkouB[displaceLen]

// ================== STATE CLASSIFICATION (5 states) ==================
// Sub-criteria:
//   priceAbove  = close above cloudTop
//   priceBelow  = close below cloudBot
//   tkAboveKj   = tenkan > kijun
//   cloudBull   = senkouA[disp] > senkouB[disp]
//   chikouFree  = close > close[laggingLen] (Chikou above past price)
priceAbove  = na(cloudTop) ? false : close > cloudTop
priceBelow  = na(cloudBot) ? false : close < cloudBot
tkAboveKj   = na(tenkan) or na(kijun) ? false : tenkan > kijun
cloudBull   = na(senkouA[displaceLen]) or na(senkouB[displaceLen]) ? false : cloudUp
chikouFree  = na(close[laggingLen]) ? false : close > close[laggingLen]
chikouHeld  = na(close[laggingLen]) ? false : close < close[laggingLen]

// 4 = Confirmed Up   → price above cloud + bullish cloud + TK > KJ + Chikou free above
// 3 = Bias Up        → at least 2 of the bullish criteria met but not all 4
// 2 = Undefined      → price inside the cloud OR mixed signals
// 1 = Bias Down      → at least 2 bearish criteria
// 0 = Confirmed Down → price below cloud + bearish cloud + TK < KJ + Chikou below past
bullScore = (priceAbove ? 1 : 0) + (tkAboveKj ? 1 : 0) + (cloudBull ? 1 : 0) + (chikouFree ? 1 : 0)
bearScore = (priceBelow ? 1 : 0) + (not tkAboveKj ? 1 : 0) + (not cloudBull ? 1 : 0) + (chikouHeld ? 1 : 0)
insideCloud = na(cloudTop) or na(cloudBot) ? false : close <= cloudTop and close >= cloudBot

state = insideCloud ? 2 :
       bullScore == 4 ? 4 :
       bearScore == 4 ? 0 :
       bullScore >= 2 and bullScore > bearScore ? 3 :
       bearScore >= 2 and bearScore > bullScore ? 1 : 2

stateColor = state == 4 ? colorStrongBull : state == 3 ? colorBull : state == 2 ? colorFlat : state == 1 ? colorBear : colorStrongBear
stateText  = state == 4 ? "Confirmed Up" : state == 3 ? "Bias Up" : state == 2 ? "Undefined" : state == 1 ? "Bias Down" : "Confirmed Down"

// State duration in bars
var int stateBars = 0
stateBars := state != state[1] ? 1 : stateBars + 1

// ================== PLOTS — LINES (hidden by default) ==================
plot(showTenkan ? tenkan : na, "Tenkan-sen", color=color.new(#2962FF, 0), linewidth=1)
plot(showKijun  ? kijun  : na, "Kijun-sen",  color=color.new(#B71C1C, 0), linewidth=1)
plot(showChikou ? chikou : na, "Chikou Span", color=color.new(#7B1FA2, 0), linewidth=1, offset=-laggingLen)

// ================== PLOTS — CLOUD ==================
senkouAPlot = plot(showCloud ? senkouA : na, "Senkou Span A", color=color.new(#26A69A, 60), linewidth=1, offset=displaceLen)
senkouBPlot = plot(showCloud ? senkouB : na, "Senkou Span B", color=color.new(#EF5350, 60), linewidth=1, offset=displaceLen)
fill(senkouAPlot, senkouBPlot, color=showCloud ? (cloudUp ? color.new(#26A69A, cloudOpacity) : color.new(#EF5350, cloudOpacity)) : na, title="Kumo Fill")

// ================== BACKGROUND BY STATE ==================
bgcolor(showBackground ? color.new(stateColor, bgOpacity) : na, title="State Background")

// Optional candle painting
barcolor(paintCandles ? stateColor : na)

// ================== PANEL ==================
pos = panelPos == "Top Right" ? position.top_right : panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table dash = table.new(pos, 3, 8, border_width=1, border_color=panelBorder, bgcolor=panelBg, frame_color=panelBorder)

if showPanel and barstate.islast
    table.cell(dash, 0, 0, "EDO ICHIMOKU STATE", text_color=panelText, text_size=panSize, bgcolor=panelHeader)
    table.cell(dash, 1, 0, "",                   bgcolor=panelHeader)
    table.cell(dash, 2, 0, "",                   bgcolor=panelHeader)

    table.cell(dash, 0, 1, "State",     text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 1, stateText,   text_color=stateColor, text_size=panSize)
    table.cell(dash, 2, 1, str.tostring(stateBars) + "b", text_color=panelTextSub, text_size=panSize)

    table.cell(dash, 0, 2, "Price vs Cloud", text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 2, priceAbove ? "Above" : priceBelow ? "Below" : "Inside", text_color=priceAbove ? colorStrongBull : priceBelow ? colorStrongBear : colorFlat, text_size=panSize)
    table.cell(dash, 2, 2, "",          text_size=panSize)

    table.cell(dash, 0, 3, "Cloud Bias",  text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 3, cloudBull ? "Bullish" : "Bearish", text_color=cloudBull ? colorStrongBull : colorStrongBear, text_size=panSize)
    table.cell(dash, 2, 3, "",          text_size=panSize)

    table.cell(dash, 0, 4, "TK vs KJ",    text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 4, tkAboveKj ? "TK > KJ" : "TK < KJ", text_color=tkAboveKj ? colorStrongBull : colorStrongBear, text_size=panSize)
    table.cell(dash, 2, 4, "",          text_size=panSize)

    table.cell(dash, 0, 5, "Chikou Free", text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 5, chikouFree ? "Above" : chikouHeld ? "Below" : "Level", text_color=chikouFree ? colorStrongBull : chikouHeld ? colorStrongBear : colorFlat, text_size=panSize)
    table.cell(dash, 2, 5, "",          text_size=panSize)

    table.cell(dash, 0, 6, "Bull Score",  text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 6, str.tostring(bullScore) + " / 4", text_color=colorStrongBull, text_size=panSize)
    table.cell(dash, 2, 6, "",          text_size=panSize)

    table.cell(dash, 0, 7, "Bear Score",  text_color=panelText, text_size=panSize, bgcolor=panelSubBg)
    table.cell(dash, 1, 7, str.tostring(bearScore) + " / 4", text_color=colorStrongBear, text_size=panSize)
    table.cell(dash, 2, 7, "",          text_size=panSize)

// ================== ALERTS ==================
toConfirmedUp   = state == 4 and state[1] != 4
toConfirmedDown = state == 0 and state[1] != 0
toUndefined     = state == 2 and state[1] != 2
toBiasUp        = state == 3 and state[1] != 3
toBiasDown      = state == 1 and state[1] != 1
priceExitsAbove  = ta.crossover(close, cloudTop)
priceExitsBelow  = ta.crossunder(close, cloudBot)
cloudFlipBull    = ta.crossover(senkouA, senkouB)
cloudFlipBear    = ta.crossunder(senkouA, senkouB)
tkKjCrossUp      = ta.crossover(tenkan, kijun)
tkKjCrossDown    = ta.crossunder(tenkan, kijun)

alertcondition(toConfirmedUp,    "Ichimoku — Confirmed Up",   "Edo Ichimoku State entered Confirmed Up on {{ticker}} {{interval}}")
alertcondition(toConfirmedDown,  "Ichimoku — Confirmed Down", "Edo Ichimoku State entered Confirmed Down on {{ticker}} {{interval}}")
alertcondition(toBiasUp,         "Ichimoku — Bias Up",        "Edo Ichimoku State turned Bias Up on {{ticker}} {{interval}}")
alertcondition(toBiasDown,       "Ichimoku — Bias Down",      "Edo Ichimoku State turned Bias Down on {{ticker}} {{interval}}")
alertcondition(toUndefined,      "Ichimoku — Undefined",      "Edo Ichimoku State turned Undefined on {{ticker}} {{interval}}")
alertcondition(priceExitsAbove,  "Ichimoku — Price Above Cloud", "Edo Ichimoku State: price closed above the Kumo on {{ticker}} {{interval}}")
alertcondition(priceExitsBelow,  "Ichimoku — Price Below Cloud", "Edo Ichimoku State: price closed below the Kumo on {{ticker}} {{interval}}")
alertcondition(cloudFlipBull,    "Ichimoku — Cloud Flip Bull", "Edo Ichimoku State: Senkou A crossed above Senkou B on {{ticker}} {{interval}}")
alertcondition(cloudFlipBear,    "Ichimoku — Cloud Flip Bear", "Edo Ichimoku State: Senkou A crossed below Senkou B on {{ticker}} {{interval}}")
alertcondition(tkKjCrossUp,      "Ichimoku — TK/KJ Cross Up",  "Edo Ichimoku State: Tenkan crossed above Kijun on {{ticker}} {{interval}}")
alertcondition(tkKjCrossDown,    "Ichimoku — TK/KJ Cross Down","Edo Ichimoku State: Tenkan crossed below Kijun on {{ticker}} {{interval}}")
````
