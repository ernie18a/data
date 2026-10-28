# Edo Control 

- url: https://www.tradingview.com/script/ddkywIaM-Edo-Control/
- type: indicator
- pine_id: PUB;50745cc176e74c3a9a40b53d024d5564
- version: 1.0

## Description

Edo Control — Structural Market Context from Williams %R and ADX, with State-Classified Control Candles, an Intensity Heatmap and Integrated Multi-Timeframe Reading

Williams %R, introduced by Larry Williams, measures on each bar where price closes inside its recent range and translates that into an overbought and oversold scale. ADX and the DMI directional system, developed by J. Welles Wilder in 1978, measure something different and complementary: how much strength the move has and which way it leans. Each one answers its own question well, but separately they leave gaps. Williams %R tells you whether price is stretched, not whether the trend has strength. ADX tells you whether there is strength, not where in the range price sits. And neither one, on its own, tells you whether what is happening on the current chart is consistent with the higher timeframes.

Edo Control was built to close those gaps without giving up the classic logic. Instead of reading %R and ADX as two loose oscillators, it crosses them bar by bar into a single state matrix that colors every candle, condenses them into an intensity layer, and projects the same reading onto three timeframes at once. The result is not a buy or sell signal: it is a framework of structural context that answers a question prior to any trade, the question of whether current market conditions even justify considering an entry.

It is worth saying what it is not. Edo Control does not generate entry or exit signals, does not predict direction and does not automate decisions. It describes the state of the market; the decision remains the trader's.

WHAT THE INDICATOR DOES

Edo Control organizes price information into three coordinated visual layers that share a single calculation logic. The Control Candles classify each candle into a structural state according to the interaction between Williams %R and directional strength. The Heatmap translates the intensity and health of the move into a background color layer, in three reading modes. The multi-timeframe module replicates the same state reading across three simultaneous timeframes to assess agreement or conflict between frames. The three layers are independent: each one can be turned on or off separately, so the trader has full control over the visual load of the chart.

CONCEPTUAL CALCULATION BASIS

The core of the indicator combines two classic measurements. The first is position in the range: Williams %R over a period of 40 places the close inside the recent high-low range relative to the equilibrium level at −50. The second is directional strength: the DMI/ADX system, with length 7, measures the intensity of the move and which direction dominates, comparing +DI against −DI. From there, a context score integrates both dimensions conceptually: how far price moves away from the equilibrium of the range, modulated by the strength with which it is moving. A stretched move without strength, and a contained move with growing strength, produce different readings. That same score feeds the three layers —the candle classification, the Heatmap color and the multi-timeframe values—, so everything seen on the chart comes from a single coherent source.

THE CONTROL CANDLES

Each candle is assigned a state based on three combined checks: which side of the −50 Williams %R level it sits on, the bullish or bearish zone of the range, and how far; whether %R is accelerating or decelerating versus the previous bar; and whether directional strength is rising or fading versus the previous bar. The combination of those three checks produces a map of up to twelve color states grouped into four reading families.

The impulse and continuation family gathers the states where price advances with a dominant body and growing strength in the direction of the move. The rejection and change family captures the %R crosses over the −50 level that mark a possible bias shift, bullish to bearish or the reverse. The decision and transition family groups medium strength or mixed sequences, where the move neither confirms nor exhausts clearly. And the reference and extreme family covers strong continuation states and the extreme zones of the range that serve as structural anchors.

This classification does not predict the next candle: it translates its internal structure into a color, so the trader reads at a glance whether recent activity is impulse, rejection, indecision or reference, without analyzing candle by candle. The system works only with confirmed data, so the state of a closed candle is not redrawn.

THE HEATMAP, AN INTENSITY LAYER

The Heatmap paints the chart background according to the context score, with three selectable modes. The Multicolor mode is a three-point gradient running from trend exhaustion (MIN) to stable trend (MID) and maximum acceleration (MAX); it is the richest reading, because it shows the health of the move and not just its direction. The Bicolor mode resolves four directional strength states by combining DMI direction with intensity: high or low bullish strength and high or low bearish strength. The Hybrid mode simplifies the reading to two states, healthy trend or warning and exhaustion.

The Heatmap opacity is configurable, 70% by default, so it does not cover the candles. The intensity layer is historical context of how price has been moving, never a support or resistance zone nor a prediction of future volatility.

MULTI-TIMEFRAME

The multi-timeframe module computes the same context score on three timeframes at once and displays them as three column bars with their normalized value, from 0 to 1, and labels to the right of the chart. The timeframes are assigned automatically according to the chosen trading profile, ensuring coherence between the operating horizon and the context frames: the Scalper profile works on 1m, 3m and 5m; Intraday on 5m, 15m and 1h; Swing on 1h, 4h and Daily; and Long Term on Daily, Weekly and Monthly. When the three timeframes point the same way a confluence occurs; when they diverge, the market is in transition. Confluence is context information, not an entry trigger.

INFORMATION PANEL

Edo Control includes legend panels that can be toggled independently, positionable in the four corners and with two sizes and Dark or Light mode. The Last TF Candle Monitor shows the context value of the latest candle on the three timeframes. The Candles Guide is the legend of the Control Candle states with their color and description. The Heatmap Guide describes the active Heatmap mode and updates when the mode changes. The legend is available in English and Spanish.

LEARNING MODE

An educational option displays over the historical candles the internal state numbering, from 0 to 11, and explanatory tooltips on hover, to study how each combination of %R and directional strength translates into a state. It is meant for the first familiarization sessions; it is best disabled during live trading to reduce visual load. The depth of history, from 50 to 400 bars, is configurable.

ALERTS

Although Edo Control's philosophy is to offer context rather than entry or exit signals, it includes a set of six alert conditions consistent with that nature, configurable from the standard TradingView dialog. They warn of context transitions, not of buy or sell orders. Two of them watch the Heatmap: the score entering the exhaustion zone (MIN), the first sign that the move is losing strength, and entering the maximum acceleration zone (MAX), when the move extends with strength. Another two watch the rejection candles: Williams %R crossing above the −50 level, which points to a possible bearish-to-bullish turn, and the cross below, which points to the opposite turn. The last two watch multi-timeframe confluence: when the three timeframes of the profile place %R above −50 at once, or below at once.

The multi-timeframe confluence is evaluated on the −50 axis of Williams %R, the same one that classifies the rejection candles, and not on the numeric value of the score, which measures context intensity and is directionally neutral.

HOW TO READ IT

A clean reading follows a sequence from higher to lower timeframe. Start with the macro context, the value and color of the latest candle on the higher timeframe, which sets the backdrop. Then check the intermediate context, to see whether the middle timeframe confirms or contradicts the higher frame. Then drop to the current situation: the type of recent Control Candles and the active Heatmap zone. And integrate the three layers into a synthesis.

Some reading patterns are common. In a healthy continuation, impulse candles chain together, the Heatmap stays in MID or MAX in the direction of the move and multi-timeframe confluence points the same way. In an exhaustion, the Heatmap migrates toward MIN while price still advances and decision or rejection candles appear. In a possible turn, a rejection candle coincides with a sign change in directional strength and the loss of confluence between frames. And in an indecision, decision candles dominate, the Heatmap turns neutral and the timeframes conflict: the context offers no clear structural edge.

ORIGINALITY AND JUSTIFICATION

Williams %R and ADX/DMI are classic, public-domain indicators; Edo Control neither reinvents nor renames them. What it adds is the coordination: instead of reading two oscillators in separate panes, it integrates both into a single twelve-state matrix that colors each candle directly, derives from them an intensity layer with three reading modes, and replicates that same reading across three timeframes coherent with the operating horizon. The combination answers something neither one resolves separately: reading position in the range, strength of the move and coherence between frames at a single glance and under a common logic. That integration, and not the components themselves, is the indicator's own method.

CONFIGURATION

Multi-timeframe: trading profile selection (Scalper, Intraday, Swing or Long Term) and visibility of the multi-TF bars. Core settings: enable the Control Candles, enable the Heatmap, Heatmap mode (Multicolor, Bicolor or Hybrid) and Heatmap opacity, from 10 to 100% with 70 by default. Legends: enable the Last TF Candle Monitor, the Candles Guide and the Heatmap Guide, position in any of the four corners, opacity, size and language, English or Spanish. Learning: enable learning mode, tooltips, history depth of 50, 100, 200 or 300 bars with an option to force 400, and label size and opacity. Style and visibility: colors and visibility per timeframe from the standard TradingView tabs.

OPEN SOURCE

Edo Control is published as an open source and free indicator. The full Pine Script is publicly available on TradingView for study, adaptation and integration into any workflow.

This indicator is a technical analysis tool intended exclusively for educational and informational purposes. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading in financial markets carries a significant risk of capital loss. Past results do not guarantee future results. Always use proper risk management.

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
// v1.3 — Migrated to Pine v6; added alert conditions (Heatmap MIN/MAX, %R rejection crosses, MTF confluence)
// Documentation updated v1.1 – January 2026
indicator("Edo Control v1.3", shorttitle="EdoControl", overlay=true, max_labels_count=500)

// ==========================================
// 1. INPUTS & CONFIG
// ==========================================
tradeProfile = input.string("Scalper (1m, 3m, 5m)", "Select Trading Profile", options=["Scalper (1m, 3m, 5m)", "Intraday (5m, 15m, 1h)", "Swing Trader (1h, 4h, D)", "Long Term (D, W, M)"], group="Multi Timeframe")
periodoWPR = 40
adxLen = 7

tf1_f = tradeProfile == "Scalper (1m, 3m, 5m)" ? "1" : tradeProfile == "Intraday (5m, 15m, 1h)" ? "5" : tradeProfile == "Swing Trader (1h, 4h, D)" ? "60" : "D"
tf2_f = tradeProfile == "Scalper (1m, 3m, 5m)" ? "3" : tradeProfile == "Intraday (5m, 15m, 1h)" ? "15" : tradeProfile == "Swing Trader (1h, 4h, D)" ? "240" : "W"
tf3_f = tradeProfile == "Scalper (1m, 3m, 5m)" ? "5" : tradeProfile == "Intraday (5m, 15m, 1h)" ? "60" : tradeProfile == "Swing Trader (1h, 4h, D)" ? "D" : "M"

multiTF = input.bool(true, "Show Multi-TF Bars", group="Multi Timeframe")
showEdoControl = input.bool(true, "Enable Edo Control Candles", group="Core Settings")
showHeatmap = input.bool(true, "Enable Heatmap", group="Core Settings")
heatmapMode = input.string("Multicolor", "Heatmap mode", options=["Multicolor", "Bicolor", "Hybrid"], group="Core Settings")
heatAlpha = int(str.tonumber(input.string("70", "Heatmap Opacity (%)", options=["10", "20", "30", "40", "50", "60", "70", "80", "90", "100"], group="Core Settings")))

showTFMonitor = input.bool(true, "Enable Last TF Candle Monitor", group="Legend UI")
showCandleLegend = input.bool(true, "Enable Candles Guide", group="Legend UI")
showHeatmapLegend = input.bool(true, "Enable Heatmap Guide", group="Legend UI")
legendCorner = input.string("top_right", "Legend Position", options=["top_left","top_right","bottom_left","bottom_right"], group="Legend UI")
legendOpacity = int(str.tonumber(input.string("80", "Legend Opacity (%)", options=["10", "20", "30", "40", "50", "60", "70", "80", "90", "100"], group="Legend UI")))
legendSizeInput = input.string("2. Small", "Legend Size", options=["1. Tiny", "2. Small"], group="Legend UI")
legendLang = input.string("English", "Legend Language", options=["English","Español"], group="Legend UI")

showLearning = input.bool(true, "Enable Learning mode", group="Learning")
showTooltips = input.bool(true, "Show tooltips (Hover mouse)", group="Learning")
historyRange = input.string("50", "Display History (Bars)", options=["50", "100", "200", "300"], group="Learning")
useMaxRange = input.bool(false, "Force MAX Range (400 bars)", group="Learning")
labelSizeInput = input.string("2. Small", "Label Size", options=["1. Tiny", "2. Small"], group="Learning")
labelOpacity = int(str.tonumber(input.string("80", "Label Opacity (%)", options=["10", "20", "30", "40", "50", "60", "70", "80", "90", "100"], group="Learning")))

get_sz(s) => s == "1. Tiny" ? size.tiny : size.small
sz_final = get_sz(legendSizeInput)
label_sz = get_sz(labelSizeInput)

// ==========================================
// 2. LÓGICA TÉCNICA
// ==========================================
dirmov(h, l, len) =>
    up = math.max(ta.change(h), 0.0), down = math.max(-ta.change(l), 0.0)
    tr = ta.rma(ta.tr, len), p = tr == 0 or na(tr) ? 0.0 : 100.0 * ta.rma(up, len) / tr, m = tr == 0 or na(tr) ? 0.0 : 100.0 * ta.rma(down, len) / tr
    [p, m]

adx_calc(h, l, len, adxlen) =>
    [p, m] = dirmov(h, l, len), s = p + m
    s == 0 ? 0 : 100 * ta.rma(math.abs(p - m) / s, adxlen)

get_color(c) =>
    c == 0 ? #00FF00 : c == 1 ? #78B946 : c == 2 ? #466446 : c == 3 ? #FFFA00 : c == 4 ? #FA8C00 : c == 5 ? #FF0000 : c == 6 ? #D23C82 : c == 7 ? #642832 : c == 8 ? #00FFFF : c == 9 ? #1EB4E6 : c == 10 ? #FF00FF : c == 11 ? #000096 : color.gray

score_from(w, a) =>
    dist = math.max(0, 100 - math.abs(w + 50))
    dist * (math.min(100, a) / 50)

// MODIFICACIÓN ÚNICA: Lógica de 3 puntos Azul (Min) -> Verde (Mid) -> Rojo (Max)
grad_color(score) =>
    s = math.max(0, math.min(100, nz(score)))
    s > 50 ? color.from_gradient(s, 50, 100, #00FF00, #FF0000) : color.from_gradient(s, 0, 50, #0000FF, #00FF00)

bicolor_col(score, dir) =>
    s = math.max(0, math.min(1, nz(score)/100))
    dir >= 0 ? color.rgb(int(144 - s*144), int(238 - s*138), int(144 - s*144)) : color.rgb(int(255 - s*116), int(153 - s*153), int(153 - s*153))

// ==========================================
// 3. EXECUTION
// ==========================================
_wpr = ta.wpr(periodoWPR)
_sig = adx_calc(high, low, adxLen, adxLen)
current_c = 0
wP = _wpr[1], sP = _sig[1]
wprOver50 = ta.crossover(_wpr, -50)    // extracted to global scope so ta.* runs every bar (v6 consistency)
wprUnder50 = ta.crossunder(_wpr, -50)

if wprUnder50
    current_c := 10
else if wprOver50
    current_c := 11
else
    if (_wpr < -50) and (_sig >= sP) and (_wpr > wP)
        current_c := 0
    else if (_wpr > -50 and _wpr < -27) and (_sig >= sP) and (_wpr > wP)
        current_c := 1
    else if (_wpr > -27) and (_sig >= sP) and (_wpr > wP)
        current_c := 2
    else if (_wpr > -50) and (_sig <= sP) and (_wpr < wP)
        current_c := 3
    else if (_wpr < -50) and (_sig <= sP) and (_wpr < wP)
        current_c := 4
    else if (_wpr > -50) and (_sig >= sP) and (_wpr < wP)
        current_c := 5
    else if (_wpr < -50 and _wpr > -72) and (_sig >= sP) and (_wpr < wP)
        current_c := 6
    else if (_wpr < -72) and (_sig >= sP) and (_wpr < wP)
        current_c := 7
    else if (_wpr < -50) and (_sig <= sP) and (_wpr > wP)
        current_c := 8
    else if (_wpr > -50) and (_sig <= sP) and (_wpr > wP)
        current_c := 9

var int c_hist = na
c_hist := current_c

mainScore = score_from(_wpr, _sig)
[_p, _m] = dirmov(high, low, adxLen), dir = _p >= _m ? 1 : -1

bgFinal = heatmapMode == "Multicolor" ? grad_color(mainScore) : 
          heatmapMode == "Bicolor" ? bicolor_col(mainScore, dir) : 
          (dir >= 0 ? #0AC850 : #DC1E1E)

bgcolor(showHeatmap ? color.new(bgFinal, 100 - heatAlpha) : na)
barcolor(showEdoControl ? get_color(current_c) : na)

tf_score(tfstr) =>
    [w, a] = request.security(syminfo.tickerid, tfstr, [ta.wpr(periodoWPR), adx_calc(high, low, adxLen, adxLen)])
    score_from(w, a)

v1 = multiTF ? tf_score(tf1_f) : na
v2 = multiTF ? tf_score(tf2_f) : na
v3 = multiTF ? tf_score(tf3_f) : na

plot(multiTF ? 0.96 : na, color=color.new(grad_color(v3), 0), linewidth=12, style=plot.style_columns, histbase=0.67, display=display.pane)
plot(multiTF ? 0.64 : na, color=color.new(grad_color(v2), 0), linewidth=12, style=plot.style_columns, histbase=0.35, display=display.pane)
plot(multiTF ? 0.32 : na, color=color.new(grad_color(v1), 0), linewidth=12, style=plot.style_columns, histbase=0.04, display=display.pane)

plot(multiTF ? v3/100 : na, title="Price Score TF3", color=color.new(grad_color(v3), 100), display=display.price_scale)
plot(multiTF ? v2/100 : na, title="Price Score TF2", color=color.new(grad_color(v2), 100), display=display.price_scale)
plot(multiTF ? v1/100 : na, title="Price Score TF1", color=color.new(grad_color(v1), 100), display=display.price_scale)

var label lbl3 = na, var label lbl2 = na, var label lbl1 = na
if barstate.islast and multiTF
    label.delete(lbl3), label.delete(lbl2), label.delete(lbl1)
    lbl3 := label.new(bar_index + 2, 0.82, "TF3: " + str.tostring(v3/100, "#.####"), color=#00000000, textcolor=grad_color(v3), style=label.style_label_left, size=size.small)
    lbl2 := label.new(bar_index + 2, 0.50, "TF2: " + str.tostring(v2/100, "#.####"), color=#00000000, textcolor=grad_color(v2), style=label.style_label_left, size=size.small)
    lbl1 := label.new(bar_index + 2, 0.18, "TF1: " + str.tostring(v1/100, "#.####"), color=#00000000, textcolor=grad_color(v1), style=label.style_label_left, size=size.small)

// ==========================================
// 4. LEYENDAS (RANGOS FIJOS SEGÚN CAPTURA)
// ==========================================
isEng = legendLang == "English"
var es_c = array.from("Posible Cambio: BAJISTA -> ALCISTA", "Fuerza Media (alcista)", "Continuación alcista (fuerte)", "Secuencia alcista: vela bajista", "Secuencia bajista: vela bajista", "Posible Cambio: ALCISTA -> BAJISTA", "Fuerza Media (bajista)", "Continuación bajista (fuerte)", "Secuencia bajista: vela alcista", "Secuencia alcista: vela alcista", "Tendencia ALC-BAJ (Cruce -50)", "Tendencia BAJ-ALC (Cruce -50)")
var en_c = array.from("Possible Change: BEARISH -> BULLISH", "Medium Strength (bullish)", "Bullish continuation (strong)", "Bullish sequence: bearish candle", "Bearish sequence: bearish candle", "Possible Change: BULLISH -> BEARISH", "Medium Strength (bearish)", "Bearish continuation (strong)", "Bearish sequence: bullish candle", "Bullish sequence: bullish candle", "Trend BULL-BEAR (Cross -50)", "Trend BEAR-BULL (Cross -50)")

if (showCandleLegend or showHeatmapLegend or (showTFMonitor and multiTF)) and barstate.islast
    pos = legendCorner == "top_left" ? position.top_left : legendCorner == "bottom_left" ? position.bottom_left : legendCorner == "bottom_right" ? position.bottom_right : position.top_right
    mt = table.new(pos, 2, 50, border_width=1, border_color=color.new(color.gray, 50))
    int cur = 0

    if showTFMonitor and multiTF
        table.cell(mt, 0, cur, isEng ? "LAST TF CANDLE" : "ÚLTIMA VELA TF", bgcolor=color.new(color.black, 20), text_color=color.white, text_size=sz_final), table.merge_cells(mt, 0, cur, 1, cur), cur += 1
        table.cell(mt, 0, cur, "TF3", bgcolor=color.new(grad_color(v3), 100-legendOpacity), text_size=sz_final), table.cell(mt, 1, cur, str.tostring(v3/100, "#.####"), bgcolor=color.new(grad_color(v3), 100-legendOpacity), text_size=sz_final), cur += 1
        table.cell(mt, 0, cur, "TF2", bgcolor=color.new(grad_color(v2), 100-legendOpacity), text_size=sz_final), table.cell(mt, 1, cur, str.tostring(v2/100, "#.####"), bgcolor=color.new(grad_color(v2), 100-legendOpacity), text_size=sz_final), cur += 1
        table.cell(mt, 0, cur, "TF1", bgcolor=color.new(grad_color(v1), 100-legendOpacity), text_size=sz_final), table.cell(mt, 1, cur, str.tostring(v1/100, "#.####"), bgcolor=color.new(grad_color(v1), 100-legendOpacity), text_size=sz_final), cur += 1
        table.cell(mt, 0, cur, "", bgcolor=color.new(color.black, 100)), table.merge_cells(mt, 0, cur, 1, cur), cur += 1

    if showCandleLegend
        table.cell(mt, 0, cur, isEng ? "CANDLES GUIDE" : "GUÍA DE VELAS", bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=sz_final), table.merge_cells(mt, 0, cur, 1, cur), cur += 1
        for i = 0 to 11
            c_bg = get_color(i), c_tx = (i == 2 or i >= 4 and i <= 7 or i >= 10 ? color.white : color.black)
            table.cell(mt, 0, cur, str.tostring(i), bgcolor=color.new(c_bg, 100-legendOpacity), text_color=c_tx, text_size=sz_final)
            table.cell(mt, 1, cur, array.get(isEng ? en_c : es_c, i), bgcolor=color.new(c_bg, 100-legendOpacity), text_color=c_tx, text_size=sz_final, text_halign=text.align_left), cur += 1
        table.cell(mt, 0, cur, "", bgcolor=color.new(color.black, 100)), table.merge_cells(mt, 0, cur, 1, cur), cur += 1

    if showHeatmapLegend
        table.cell(mt, 0, cur, isEng ? "HEATMAP GUIDE" : "GUÍA HEATMAP", bgcolor=color.new(color.gray, 30), text_color=color.white, text_size=sz_final), table.merge_cells(mt, 0, cur, 1, cur), cur += 1
        if heatmapMode == "Multicolor"
            table.cell(mt, 0, cur, "MAX", bgcolor=color.new(#FF0000, 100-legendOpacity), text_color=color.white, text_size=sz_final), table.cell(mt, 1, cur, isEng ? "Max Acceleration" : "Máxima Aceleración", bgcolor=color.new(#FF0000, 100-legendOpacity), text_color=color.white, text_halign=text.align_left, text_size=sz_final), cur += 1
            table.cell(mt, 0, cur, "MID", bgcolor=color.new(#00FF00, 100-legendOpacity), text_color=color.black, text_size=sz_final), table.cell(mt, 1, cur, isEng ? "Stable Trend" : "Tendencia Estable", bgcolor=color.new(#00FF00, 100-legendOpacity), text_color=color.black, text_halign=text.align_left, text_size=sz_final), cur += 1
            table.cell(mt, 0, cur, "MIN", bgcolor=color.new(#0000FF, 100-legendOpacity), text_color=color.white, text_size=sz_final), table.cell(mt, 1, cur, isEng ? "Trend Exhaustion" : "Agotamiento Tendencial", bgcolor=color.new(#0000FF, 100-legendOpacity), text_color=color.white, text_halign=text.align_left, text_size=sz_final), cur += 1
        else if heatmapMode == "Bicolor"
            table.cell(mt, 0, cur, "MAX", bgcolor=color.new(#006400, 100-legendOpacity), text_color=color.white, text_size=sz_final), table.cell(mt, 1, cur, isEng ? "High Bull Strength" : "Fuerza Alcista Alta", bgcolor=color.new(#006400, 100-legendOpacity), text_color=color.white, text_halign=text.align_left, text_size=sz_final), cur += 1
            table.cell(mt, 0, cur, "MIN", bgcolor=color.new(#90EE90, 100-legendOpacity), text_color=color.black, text_size=sz_final), table.cell(mt, 1, cur, isEng ? "Low Bull Strength" : "Fuerza Alcista Baja", bgcolor=color.new(#90EE90, 100-legendOpacity), text_color=color.black, text_halign=text.align_left, text_size=sz_final), cur += 1
            table.cell(mt, 0, cur, "MAX", bgcolor=color.new(#8B0000, 100-legendOpacity), text_color=color.white, text_size=sz_final), table.cell(mt, 1, cur, isEng ? "High Bear Strength" : "Fuerza Bajista Alta", bgcolor=color.new(#8B0000, 100-legendOpacity), text_color=color.white, text_halign=text.align_left, text_size=sz_final), cur += 1
            table.cell(mt, 0, cur, "MIN", bgcolor=color.new(#FF9999, 100-legendOpacity), text_color=color.black, text_size=sz_final), table.cell(mt, 1, cur, isEng ? "Low Bear Strength" : "Fuerza Bajista Baja", bgcolor=color.new(#FF9999, 100-legendOpacity), text_color=color.black, text_halign=text.align_left, text_size=sz_final), cur += 1
        else if heatmapMode == "Hybrid"
            table.cell(mt, 0, cur, "HEALTHY", bgcolor=color.new(#0AC850, 100-legendOpacity), text_color=color.white, text_size=sz_final), table.cell(mt, 1, cur, "Healthy Bull Trend", bgcolor=color.new(#0AC850, 100-legendOpacity), text_color=color.white, text_halign=text.align_left, text_size=sz_final), cur += 1
            table.cell(mt, 0, cur, "WARNING", bgcolor=color.new(#DC1E1E, 100-legendOpacity), text_color=color.white, text_size=sz_final), table.cell(mt, 1, cur, "Trend Alert/Warning", bgcolor=color.new(#DC1E1E, 100-legendOpacity), text_color=color.white, text_halign=text.align_left, text_size=sz_final), cur += 1

// ==========================================
// 5. LEARNING MODE
// ==========================================
if showLearning and barstate.islast
    limit = useMaxRange ? 400 : int(str.tonumber(historyRange))
    for i = 0 to limit
        int b_idx = bar_index - i
        if b_idx >= 0
            int c_val = c_hist[i]
            if not na(c_val)
                t_tip = showTooltips ? array.get(isEng ? en_c : es_c, c_val) : ""
                label.new(b_idx, high[i], str.tostring(c_val), yloc=yloc.abovebar, color=color.new(get_color(c_val), 100-labelOpacity), textcolor=color.new((c_val==2 or c_val>=4 and c_val<=7 or c_val>=10 ? color.white : color.black), 100-labelOpacity), size=label_sz, tooltip=t_tip)

// ==========================================
// 6. ALERTS
// ==========================================
// Heatmap MIN/MAX use the Multicolor score axis (MIN = exhaustion near 0, MAX = max acceleration near 100).
// MTF confluence is read on the same -50 Williams %R axis that classifies the candles (states 10/11),
// because the per-TF score measures context intensity, not direction.
scoreClamped = math.max(0, math.min(100, nz(mainScore)))
heatToMin = ta.crossunder(scoreClamped, 25)
heatToMax = ta.crossover(scoreClamped, 75)
rejectBull = wprOver50
rejectBear = wprUnder50

tf_bias(tfstr) =>
    wb = request.security(syminfo.tickerid, tfstr, ta.wpr(periodoWPR))
    wb > -50 ? 1 : wb < -50 ? -1 : 0

bias1 = multiTF ? tf_bias(tf1_f) : 0
bias2 = multiTF ? tf_bias(tf2_f) : 0
bias3 = multiTF ? tf_bias(tf3_f) : 0
confBull = bias1 > 0 and bias2 > 0 and bias3 > 0
confBear = bias1 < 0 and bias2 < 0 and bias3 < 0

alertcondition(heatToMin, title="Heatmap to MIN (Trend Exhaustion)", message="Edo Control: Heatmap shifted to MIN state - trend exhaustion")
alertcondition(heatToMax, title="Heatmap to MAX (Max Acceleration)", message="Edo Control: Heatmap shifted to MAX state - maximum acceleration")
alertcondition(rejectBull, title="Rejection Candle Bullish (WPR cross up -50)", message="Edo Control: bullish rejection - Williams %R crossed ABOVE -50")
alertcondition(rejectBear, title="Rejection Candle Bearish (WPR cross down -50)", message="Edo Control: bearish rejection - Williams %R crossed BELOW -50")
alertcondition(confBull and not confBull[1], title="MTF Confluence Bullish", message="Edo Control: bullish MTF confluence - all three timeframes above -50")
alertcondition(confBear and not confBear[1], title="MTF Confluence Bearish", message="Edo Control: bearish MTF confluence - all three timeframes below -50")
````
