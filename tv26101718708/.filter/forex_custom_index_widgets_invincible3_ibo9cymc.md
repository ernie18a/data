# Forex: Custom Index Widgets [invincible3]

- url: https://www.tradingview.com/script/IbO9cyMc-Forex-Custom-Index-Widgets-invincible3/
- type: indicator
- pine_id: PUB;22401f434f69406199bdc6523a8bfcdd
- version: 1.0

## Description

Forex: Custom Index Widgets [invincible3]

Forex: Custom Index Widgets is a professional currency-strength dashboard designed to visualize real-time strength, weakness, momentum quality, and market rotation across the eight major forex currencies: USD, EUR, GBP, JPY, AUD, NZD, CAD, and CHF.

Unlike a simple EMA-based strength meter, this indicator builds custom currency indices from the 28 major FX crosses and displays them as compact mini index widgets directly on the chart. Each currency index is reconstructed from its related currency pairs, allowing traders to observe the independent behavior of each currency rather than relying only on the chart symbol.

The indicator combines two major components:

1. Custom Currency Index Widgets
2. Professional Composite Force Table

The custom index widgets show the short-term structure of each selected currency index using mini candles. This makes it easier to visually compare whether a currency is trending, drifting, compressing, or impulsively expanding. The widget section also includes a volatility smart layer, which adjusts candle appearance according to volatility conditions such as quiet movement, expansion, or extreme impulse.

The table section ranks currencies using a composite force model. Instead of using EMA direction alone, the table evaluates multiple strength components, including relative strength, breadth, efficiency, impulse, acceleration, and phase. This gives a more complete view of currency behavior and helps identify clean strength, weak currencies, rotation conditions, and potential strongest-versus-weakest pair opportunities.

[b]Key Features[/b]

* Builds custom indices for USD, EUR, GBP, JPY, AUD, NZD, CAD, and CHF.
* Uses 28 major forex crosses to construct currency strength.
* Displays mini custom index widgets directly on the chart.
* Optional EMA overlay on the custom index widgets.
* Volatility-aware widget candles.
* Composite force ranking table.
* Measures strength beyond simple EMA direction.
* Includes breadth, efficiency, impulse, acceleration, and phase logic.
* Highlights strongest and weakest currencies.
* Suggests the best strongest-versus-weakest pair bias.
* Professional table design for both dark and light TradingView themes.
* Theme-adaptive colors for improved readability.
* Adjustable widget layout, table position, and display options.
* Designed to remain lightweight by avoiding unnecessary multi-timeframe request overload.

[b] How the Custom Indices Work[/b]

Each currency index is calculated by combining its related FX pairs. For example, USD strength is derived from pairs such as EURUSD, GBPUSD, AUDUSD, NZDUSD, USDCAD, USDCHF, and USDJPY. When USD is the quote currency, the pair movement is inverted; when USD is the base currency, the movement is used directly.

This directional aggregation allows the indicator to estimate the independent strength of each major currency.

For example:

* If EURUSD falls, USD strength increases.
* If USDJPY rises, USD strength increases.
* If GBPUSD rises, GBP strength increases.
* If AUDJPY falls, JPY strength increases.

This approach gives a broader currency view than looking at one forex pair alone.

[b]Composite Force Table[/b]

The table is designed to act as the main decision dashboard. It ranks all currencies from strongest to weakest using a multi-factor force score.

The force model includes:

[b]Relative Strength[/b]
Measures how strongly a currency index has moved compared with others.

[b]Breadth[/b]
Checks whether the currency strength is broad-based across its related pairs or caused by only one or two pairs.

[b]Efficiency[/b]
Measures how clean the move is. A currency that trends smoothly receives a stronger quality score than one that moves in a choppy manner.

[b]Impulse[/b]
Detects whether current movement is expanding with force compared with recent movement.

[b]Acceleration[/b]
Shows whether strength is increasing or fading.

[b]Phase[/b]
Classifies the current currency condition into practical market states such as bullish expansion, bearish expansion, build-up, drift, exhaustion, or rotation.

[b]Market Phase Interpretation[/b]

The phase column helps traders understand the quality of the move:

[b]Bull Expand[/b]
The currency is strong, broad, and moving with impulse.

[b]Bear Expand[/b]
The currency is weak, broad, and moving lower with impulse.

[b]Bull Build[/b]
Strength is developing, but the move may still be in an early stage.

[b]Bear Build[/b]
Weakness is developing, but downside pressure may still be forming.

[b]Bull Drift / Bear Drift[/b]
The currency has directional bias, but the movement is not yet highly aggressive.

[b]Bull Exhaust / Bear Exhaust[/b]
The currency is still strong or weak, but acceleration is fading. This can warn of possible rotation or pullback.

**[b]Rotation[/b]**
No clear dominant force. Market conditions may be mixed or neutral.

[b]Strongest vs Weakest Logic[/b]

One of the most useful ways to apply a currency strength meter is to compare the strongest currency against the weakest currency.

For example:

* If USD is strongest and AUD is weakest, the dashboard may highlight a USD/AUD long bias where available, or an AUD/USD short bias.
* If EUR is strongest and JPY is weakest, EURJPY may become a high-priority pair to watch.
* If GBP is weakest and CHF is strongest, GBPCHF may become a short-bias candidate.

This does not mean traders should enter immediately. The table is designed to identify directional bias and currency selection. Entry timing should still be confirmed with market structure, price action, support/resistance, liquidity zones, session timing, or the trader’s own strategy.

[b]Widget Section[/b]

The mini index widgets provide a visual snapshot of each currency index. They allow traders to see whether the index is pushing higher, selling off, compressing, or moving with volatility expansion.

Widget features include:

* Mini candle visualization of selected currency indices.
* Optional EMA overlay.
* Customizable widget height and spacing.
* Volatility-based candle width and transparency.
* Labels showing index name, current movement, timeframe, and volatility state.
* Clean theme-adaptive styling for professional chart layouts.

[b]EMA Usage[/b]

EMA is included as an optional visual guide on the custom index widgets. It should be treated as a secondary confirmation tool, not the main strength engine.

The main ranking logic comes from the composite force model, while EMA helps visually confirm whether the mini index structure is trending or flattening.

[b] Suggested Usage[/b]

This indicator can be used for:

* Finding the strongest and weakest currencies.
* Selecting high-probability forex pairs.
* Confirming directional bias before entering trades.
* Avoiding weak or conflicting currency combinations.
* Detecting currency rotation.
* Monitoring whether strength is broad or narrow.
* Comparing currency behavior across all major FX groups.
* Supporting intraday, swing, and session-based trading workflows.

A common workflow is:

1. Check the table for the strongest and weakest currencies.
2. Confirm that the force gap is meaningful.
3. Check the phase column for expansion, build-up, or exhaustion.
4. Use the mini widgets to visually confirm index direction.
5. Move to the actual forex pair chart for entry confirmation.
6. Use your own price-action or risk-management rules for execution.

[b]Important Notes[/b]
This indicator is a market analysis tool, not an automatic buy/sell system. It is designed to show currency strength, weakness, rotation, and relative force. The strongest currency can remain strong for a long period, but it can also become exhausted. The weakest currency can continue falling, but it can also sharply reverse during rotation phases.

Always combine this tool with proper risk management and independent trade confirmation.

[b]Best For[/b]
[list]
[*]Forex traders
[*] Currency strength analysis
[*] Intraday trading
[*] Swing trading
[*] Strongest-versus-weakest pair selection
[*] Market rotation analysis
[*] Multi-currency dashboard workflows
[*] Traders who want more than a basic EMA strength meter
[/list]
[b]Summary[/b]
FX Custom Index Force Meter PRO is designed to give traders a complete view of major currency behavior. It combines custom-built currency index widgets with a professional multi-factor force table, allowing traders to see not only which currency is strong or weak, but also whether that strength is broad, efficient, impulsive, accelerating, or fading.

The goal is to help traders move beyond simple EMA-based analysis and toward a more structured, professional currency selection process.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator(
     "Forex: Custom Index Widgets [invincible3]",
     shorttitle = "FX",
     overlay = true,
     scale = scale.none,
     dynamic_requests = true,
     max_lines_count = 500,
     max_labels_count = 100,
     max_polylines_count = 50
)

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────
groupData = "Data Settings"
prefix  = input.string("OANDA:", "Broker Prefix", group = groupData)
reqTf   = timeframe.period
lookback = input.int(14, "ATR Lookback", minval = 1, group = groupData)

groupMode = "Index Mode"
weightMode = input.string(
     "Equal",
     "Index Weight Mode",
     options = ["Equal", "ATR Share", "Inverse ATR"],
     group = groupMode
)

groupWidget = "Widget Layout"
numberOfBars = input.int(28, "Bars Per Widget", minval = 5, maxval = 30, group = groupWidget)
hOffset      = input.int(20, "Horizontal Offset", minval = 10, maxval = 300, group = groupWidget)
widgetHeight = input.float(1.00, "Widget Height", minval = 0.50, maxval = 3.00, step = 0.10, group = groupWidget)
widgetGap    = input.float(0.30, "Gap Between Widgets", minval = 0.05, maxval = 1.00, step = 0.05, group = groupWidget)
showPanel    = input.bool(true, "Show Widget Labels", group = groupWidget)
showSep      = input.bool(true, "Show Separators", group = groupWidget)

groupVol = "Volatility Smart Layer"
useVolLayer      = input.bool(true, "Enable Volatility Smart Layer", group = groupVol)
showVolInLabel   = input.bool(true, "Show Volatility State In Label", group = groupVol)
useDynamicWidth  = input.bool(true, "Volatility Candle Width", group = groupVol)
useVolFade       = input.bool(true, "Fade Quiet Candles", group = groupVol)
volAvgBars       = input.int(14, "Volatility Average Bars", minval = 3, maxval = 38, group = groupVol)
quietThr         = input.float(0.70, "Quiet Threshold", minval = 0.10, step = 0.05, group = groupVol)
expansionThr     = input.float(1.30, "Expansion Threshold", minval = 0.50, step = 0.05, group = groupVol)
extremeThr       = input.float(2.00, "Extreme Threshold", minval = 1.00, step = 0.05, group = groupVol)

groupColor = "Widget Colors"
bullColor = input.color(color.teal, "Bull Candle", group = groupColor)
bearColor = input.color(color.red, "Bear Candle", group = groupColor)
sepColor  = input.color(color.new(color.gray, 55), "Separator Color", group = groupColor)
txtColor  = input.color(color.white, "Label Text Color", group = groupColor)

groupStyle = "Professional Theme"
themeMode = input.string("Auto", "Theme Mode", options = ["Auto", "Dark", "Light"], group = groupStyle)
tableAccent = input.string("Emerald", "Accent Color", options = ["Emerald", "Blue", "Gold", "Mono"], group = groupStyle)
useSoftTable = input.bool(true, "Soft Table Heatmap", group = groupStyle)
useThemeWidgetLabels = input.bool(true, "Theme-Aware Widget Labels", group = groupStyle)
useThemeSeparators = input.bool(true, "Theme-Aware Separators", group = groupStyle)

// Professional note: 30 bars is the safe upper range for 8 widgets because each candle uses wick/body line objects.
groupStrength = "Strength Meter"
showStrengthTable = input.bool(true, "Show Strength Meter Table", group = groupStrength)
strengthLookback  = input.int(14, "Strength Lookback Bars", minval = 1, maxval = 500, group = groupStrength)
strengthSmooth    = input.int(3, "Strength Smoothing", minval = 1, maxval = 100, group = groupStrength)
neutralThreshold  = input.float(0.05, "Neutral Threshold %", minval = 0.0, step = 0.01, group = groupStrength)
strengthTablePos  = input.string(
     "Top Right",
     "Table Position",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = groupStrength
)
tableTextSize = input.string("Small", "Table Text Size", options = ["Tiny", "Small", "Normal"], group = groupStrength)

// Composite Force Table inputs. These only change the table logic; the widget indices stay unchanged.
groupForce = "Composite Force Table"
wStrength    = input.float(30.0, "Weight: Relative Strength", minval = 0, step = 1, group = groupForce)
wBreadth     = input.float(20.0, "Weight: Breadth", minval = 0, step = 1, group = groupForce)
wEfficiency  = input.float(20.0, "Weight: Efficiency", minval = 0, step = 1, group = groupForce)
wImpulse     = input.float(10.0, "Weight: Impulse", minval = 0, step = 1, group = groupForce)
wPersistence = input.float(10.0, "Weight: Persistence", minval = 0, step = 1, group = groupForce)
wAccel       = input.float(10.0, "Weight: Acceleration", minval = 0, step = 1, group = groupForce)

effLen     = input.int(10, "Efficiency Length", minval = 2, maxval = 100, group = groupForce)
impulseLen = input.int(10, "Impulse Average Length", minval = 2, maxval = 100, group = groupForce)
persistLen = input.int(8, "Persistence Length", minval = 2, maxval = 100, group = groupForce)
accelBars  = input.int(3, "Acceleration Compare Bars", minval = 1, maxval = 50, group = groupForce)
accelCap   = input.float(0.35, "Acceleration Cap", minval = 0.05, step = 0.05, group = groupForce)
pairGap    = input.float(25.0, "Chart Pair Bias Minimum Force Gap", minval = 0, step = 1, group = groupForce)
bestPairGap = input.float(60.0, "Best Pair Minimum Force Gap", minval = 0, step = 1, group = groupForce)

groupEma = "EMA Trend"
showWidgetEma = input.bool(true, "Show EMA On Custom Indices", group = groupEma)
widgetEmaLen  = input.int(9, "Widget EMA Length", minval = 1, maxval = 100, group = groupEma)
widgetEmaColor = input.color(color.yellow, "Widget EMA Color", group = groupEma)
widgetEmaWidth = input.int(2, "Widget EMA Width", minval = 1, maxval = 5, group = groupEma)

emaTrendLen  = input.int(20, "EMA Trend Length", minval = 1, maxval = 500, group = groupEma)
emaSlopeBars = input.int(1, "EMA Slope Compare Bars", minval = 1, maxval = 100, group = groupEma)
emaFlatThreshold = input.float(0.02, "EMA Flat Threshold %", minval = 0.0, step = 0.01, group = groupEma)

groupW1 = "Widget 1"
w1Show = input.bool(true, "Show Widget 1", group = groupW1)
w1CCY  = input.string("USD", "Index", options = ["USD", "EUR", "GBP", "JPY", "AUD", "NZD", "CAD", "CHF"], group = groupW1)

groupW2 = "Widget 2"
w2Show = input.bool(true, "Show Widget 2", group = groupW2)
w2CCY  = input.string("EUR", "Index", options = ["USD", "EUR", "GBP", "JPY", "AUD", "NZD", "CAD", "CHF"], group = groupW2)

groupW3 = "Widget 3"
w3Show = input.bool(true, "Show Widget 3", group = groupW3)
w3CCY  = input.string("GBP", "Index", options = ["USD", "EUR", "GBP", "JPY", "AUD", "NZD", "CAD", "CHF"], group = groupW3)

groupW4 = "Widget 4"
w4Show = input.bool(true, "Show Widget 4", group = groupW4)
w4CCY  = input.string("JPY", "Index", options = ["USD", "EUR", "GBP", "JPY", "AUD", "NZD", "CAD", "CHF"], group = groupW4)

groupW5 = "Widget 5"
w5Show = input.bool(true, "Show Widget 5", group = groupW5)
w5CCY  = input.string("AUD", "Index", options = ["USD", "EUR", "GBP", "JPY", "AUD", "NZD", "CAD", "CHF"], group = groupW5)

groupW6 = "Widget 6"
w6Show = input.bool(true, "Show Widget 6", group = groupW6)
w6CCY  = input.string("NZD", "Index", options = ["USD", "EUR", "GBP", "JPY", "AUD", "NZD", "CAD", "CHF"], group = groupW6)

groupW7 = "Widget 7"
w7Show = input.bool(true, "Show Widget 7", group = groupW7)
w7CCY  = input.string("CAD", "Index", options = ["USD", "EUR", "GBP", "JPY", "AUD", "NZD", "CAD", "CHF"], group = groupW7)

groupW8 = "Widget 8"
w8Show = input.bool(true, "Show Widget 8", group = groupW8)
w8CCY  = input.string("CHF", "Index", options = ["USD", "EUR", "GBP", "JPY", "AUD", "NZD", "CAD", "CHF"], group = groupW8)

//──────────────────────────────────────────────────────────────────────────────
// 28 Major FX Crosses
//──────────────────────────────────────────────────────────────────────────────
var string[] pairSymbols = array.from(
     prefix + "EURUSD",
     prefix + "GBPUSD",
     prefix + "USDJPY",
     prefix + "USDCHF",
     prefix + "USDCAD",
     prefix + "AUDUSD",
     prefix + "NZDUSD",

     prefix + "EURGBP",
     prefix + "EURJPY",
     prefix + "EURCHF",
     prefix + "EURCAD",
     prefix + "EURAUD",
     prefix + "EURNZD",

     prefix + "GBPJPY",
     prefix + "GBPCHF",
     prefix + "GBPCAD",
     prefix + "GBPAUD",
     prefix + "GBPNZD",

     prefix + "CHFJPY",
     prefix + "CADJPY",
     prefix + "CADCHF",

     prefix + "AUDJPY",
     prefix + "AUDCHF",
     prefix + "AUDCAD",
     prefix + "AUDNZD",

     prefix + "NZDJPY",
     prefix + "NZDCHF",
     prefix + "NZDCAD"
)

var string[] pairBase = array.from(
     "EUR", "GBP", "USD", "USD", "USD", "AUD", "NZD",
     "EUR", "EUR", "EUR", "EUR", "EUR", "EUR",
     "GBP", "GBP", "GBP", "GBP", "GBP",
     "CHF", "CAD", "CAD",
     "AUD", "AUD", "AUD", "AUD",
     "NZD", "NZD", "NZD"
)

var string[] pairQuote = array.from(
     "USD", "USD", "JPY", "CHF", "CAD", "USD", "USD",
     "GBP", "JPY", "CHF", "CAD", "AUD", "NZD",
     "JPY", "CHF", "CAD", "AUD", "NZD",
     "JPY", "JPY", "CHF",
     "JPY", "CHF", "CAD", "NZD",
     "JPY", "CHF", "CAD"
)

pairCount = array.size(pairSymbols)

//──────────────────────────────────────────────────────────────────────────────
// Pair Data Storage
//──────────────────────────────────────────────────────────────────────────────
var float[] oArr   = array.new_float(pairCount, na)
var float[] hArr   = array.new_float(pairCount, na)
var float[] lArr   = array.new_float(pairCount, na)
var float[] cArr   = array.new_float(pairCount, na)
var float[] atrArr = array.new_float(pairCount, na)
var float[] refCloseArr = array.new_float(pairCount, na)

//──────────────────────────────────────────────────────────────────────────────
// Request Pair Data
//──────────────────────────────────────────────────────────────────────────────
for i = 0 to pairCount - 1
    string sym = array.get(pairSymbols, i)

    [o, h, l, c, atrValue] = request.security(
         sym,
         reqTf,
         [open, high, low, close, ta.atr(lookback)],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off,
         ignore_invalid_symbol = true
    )

    array.set(oArr, i, o)
    array.set(hArr, i, h)
    array.set(lArr, i, l)
    array.set(cArr, i, c)
    array.set(atrArr, i, atrValue)

    float oldRef = array.get(refCloseArr, i)
    if na(oldRef) and not na(c) and c > 0
        array.set(refCloseArr, i, c)

//──────────────────────────────────────────────────────────────────────────────
// Custom Index Engine
//──────────────────────────────────────────────────────────────────────────────
f_dir(string target, string baseCcy, string quoteCcy) =>
    target == baseCcy ? 1 : target == quoteCcy ? -1 : 0

f_rawWeight(float atrValue) =>
    switch weightMode
        "ATR Share"   => atrValue
        "Inverse ATR" => atrValue > 0 ? 1.0 / atrValue : na
        => 1.0

f_auto_index(string target) =>
    float sumW = 0.0

    for i = 0 to pairCount - 1
        string b = array.get(pairBase, i)
        string q = array.get(pairQuote, i)
        int dir = f_dir(target, b, q)

        float o   = array.get(oArr, i)
        float h   = array.get(hArr, i)
        float l   = array.get(lArr, i)
        float c   = array.get(cArr, i)
        float atr = array.get(atrArr, i)
        float ref = array.get(refCloseArr, i)

        bool validData = dir != 0 and not na(o) and not na(h) and not na(l) and not na(c) and not na(ref) and o > 0 and h > 0 and l > 0 and c > 0 and ref > 0

        if validData
            float rawW = f_rawWeight(atr)
            if not na(rawW) and rawW > 0
                sumW += rawW

    float logO = 0.0
    float logH = 0.0
    float logL = 0.0
    float logC = 0.0

    if sumW > 0
        for i = 0 to pairCount - 1
            string b = array.get(pairBase, i)
            string q = array.get(pairQuote, i)
            int dir = f_dir(target, b, q)

            float o   = array.get(oArr, i)
            float h   = array.get(hArr, i)
            float l   = array.get(lArr, i)
            float c   = array.get(cArr, i)
            float atr = array.get(atrArr, i)
            float ref = array.get(refCloseArr, i)

            bool validData = dir != 0 and not na(o) and not na(h) and not na(l) and not na(c) and not na(ref) and o > 0 and h > 0 and l > 0 and c > 0 and ref > 0

            if validData
                float rawW = f_rawWeight(atr)

                if not na(rawW) and rawW > 0
                    float w = rawW / sumW

                    float ratioO = dir == 1 ? o / ref : ref / o
                    float ratioC = dir == 1 ? c / ref : ref / c

                    float ratioH = dir == 1 ? h / ref : ref / l
                    float ratioL = dir == 1 ? l / ref : ref / h

                    if ratioO > 0 and ratioH > 0 and ratioL > 0 and ratioC > 0
                        logO += w * math.log(ratioO)
                        logH += w * math.log(ratioH)
                        logL += w * math.log(ratioL)
                        logC += w * math.log(ratioC)

    float idxO = sumW > 0 ? 100.0 * math.exp(logO) : na
    float idxHRaw = sumW > 0 ? 100.0 * math.exp(logH) : na
    float idxLRaw = sumW > 0 ? 100.0 * math.exp(logL) : na
    float idxC = sumW > 0 ? 100.0 * math.exp(logC) : na

    float idxH = not na(idxHRaw) and not na(idxO) and not na(idxC) ? math.max(idxHRaw, math.max(idxO, idxC)) : na
    float idxL = not na(idxLRaw) and not na(idxO) and not na(idxC) ? math.min(idxLRaw, math.min(idxO, idxC)) : na

    [idxO, idxH, idxL, idxC]

//──────────────────────────────────────────────────────────────────────────────
// Build 8 Currency Indexes
//──────────────────────────────────────────────────────────────────────────────
[usdO, usdH, usdL, usdC] = f_auto_index("USD")
[eurO, eurH, eurL, eurC] = f_auto_index("EUR")
[gbpO, gbpH, gbpL, gbpC] = f_auto_index("GBP")
[jpyO, jpyH, jpyL, jpyC] = f_auto_index("JPY")
[audO, audH, audL, audC] = f_auto_index("AUD")
[nzdO, nzdH, nzdL, nzdC] = f_auto_index("NZD")
[cadO, cadH, cadL, cadC] = f_auto_index("CAD")
[chfO, chfH, chfL, chfC] = f_auto_index("CHF")

//──────────────────────────────────────────────────────────────────────────────
// Strength Engine
// Strength = % change of each custom index over user-defined lookback
//──────────────────────────────────────────────────────────────────────────────
f_index_strength(float idxClose) =>
    float refValue = idxClose[strengthLookback]
    float rawStrength = not na(idxClose) and not na(refValue) and refValue != 0 ? (idxClose / refValue - 1.0) * 100.0 : na
    float emaStrength = ta.ema(rawStrength, strengthSmooth)
    strengthSmooth > 1 ? emaStrength : rawStrength

usdStr = f_index_strength(usdC)
eurStr = f_index_strength(eurC)
gbpStr = f_index_strength(gbpC)
jpyStr = f_index_strength(jpyC)
audStr = f_index_strength(audC)
nzdStr = f_index_strength(nzdC)
cadStr = f_index_strength(cadC)
chfStr = f_index_strength(chfC)

//──────────────────────────────────────────────────────────────────────────────
// EMA Trend Engine
// EMA table direction = EMA slope over user-defined compare bars
//──────────────────────────────────────────────────────────────────────────────
usdEma = ta.ema(usdC, emaTrendLen)
eurEma = ta.ema(eurC, emaTrendLen)
gbpEma = ta.ema(gbpC, emaTrendLen)
jpyEma = ta.ema(jpyC, emaTrendLen)
audEma = ta.ema(audC, emaTrendLen)
nzdEma = ta.ema(nzdC, emaTrendLen)
cadEma = ta.ema(cadC, emaTrendLen)
chfEma = ta.ema(chfC, emaTrendLen)

f_ema_delta(float emaValue) =>
    float prevValue = emaValue[emaSlopeBars]
    not na(emaValue) and not na(prevValue) and prevValue != 0 ? (emaValue / prevValue - 1.0) * 100.0 : na

usdEmaDelta = f_ema_delta(usdEma)
eurEmaDelta = f_ema_delta(eurEma)
gbpEmaDelta = f_ema_delta(gbpEma)
jpyEmaDelta = f_ema_delta(jpyEma)
audEmaDelta = f_ema_delta(audEma)
nzdEmaDelta = f_ema_delta(nzdEma)
cadEmaDelta = f_ema_delta(cadEma)
chfEmaDelta = f_ema_delta(chfEma)

var string[] rankCcyArr = array.new_string()
var float[]  rankIdxArr = array.new_float()
var float[]  rankStrArr = array.new_float()


//──────────────────────────────────────────────────────────────────────────────
// Select Index
//──────────────────────────────────────────────────────────────────────────────
f_pick_index(string ccy) =>
    switch ccy
        "USD" => [usdO, usdH, usdL, usdC]
        "EUR" => [eurO, eurH, eurL, eurC]
        "GBP" => [gbpO, gbpH, gbpL, gbpC]
        "JPY" => [jpyO, jpyH, jpyL, jpyC]
        "AUD" => [audO, audH, audL, audC]
        "NZD" => [nzdO, nzdH, nzdL, nzdC]
        "CAD" => [cadO, cadH, cadL, cadC]
        => [chfO, chfH, chfL, chfC]

f_pick_ema(string ccy) =>
    switch ccy
        "USD" => [usdEma, usdEmaDelta]
        "EUR" => [eurEma, eurEmaDelta]
        "GBP" => [gbpEma, gbpEmaDelta]
        "JPY" => [jpyEma, jpyEmaDelta]
        "AUD" => [audEma, audEmaDelta]
        "NZD" => [nzdEma, nzdEmaDelta]
        "CAD" => [cadEma, cadEmaDelta]
        => [chfEma, chfEmaDelta]

//──────────────────────────────────────────────────────────────────────────────
// Widget Type
//──────────────────────────────────────────────────────────────────────────────
type MiniWidget
    string loaded
    float[] o
    float[] h
    float[] l
    float[] c
    line[] drawings
    polyline emaPlot
    label panel
    line separator

method deleteObjects(MiniWidget w) =>
    while array.size(w.drawings) > 0
        line ln = array.pop(w.drawings)
        if not na(ln)
            line.delete(ln)

    if not na(w.emaPlot)
        polyline.delete(w.emaPlot)
        w.emaPlot := na

    if not na(w.panel)
        label.delete(w.panel)
        w.panel := na

    if not na(w.separator)
        line.delete(w.separator)
        w.separator := na

    true

method clearData(MiniWidget w) =>
    array.clear(w.o)
    array.clear(w.h)
    array.clear(w.l)
    array.clear(w.c)
    true

method updateData(MiniWidget w, bool show, string ccy, float o, float h, float l, float c, bool newReqBar, int keepBars) =>
    if not show
        w.loaded := ""
        w.clearData()
        true
    else
        if w.loaded != ccy
            w.loaded := ccy
            w.clearData()

        bool valid = not na(o) and not na(h) and not na(l) and not na(c)

        if valid
            if array.size(w.c) == 0 or newReqBar
                array.unshift(w.o, o)
                array.unshift(w.h, h)
                array.unshift(w.l, l)
                array.unshift(w.c, c)
            else
                array.set(w.o, 0, o)
                array.set(w.h, 0, h)
                array.set(w.l, 0, l)
                array.set(w.c, 0, c)

            while array.size(w.c) > keepBars
                array.pop(w.o)
                array.pop(w.h)
                array.pop(w.l)
                array.pop(w.c)

        true

//──────────────────────────────────────────────────────────────────────────────
// Helper Functions
//──────────────────────────────────────────────────────────────────────────────
f_slot_offset(int slot) =>
    1.0 + (8 - slot) * (widgetHeight + widgetGap)

f_get_full_name(string ccy) =>
    switch ccy
        "USD" => "US DOLLAR"
        "EUR" => "EURO"
        "GBP" => "BRITISH POUND"
        "JPY" => "JAPANESE YEN"
        "AUD" => "AUSTRALIAN DOLLAR"
        "CAD" => "CANADIAN DOLLAR"
        "CHF" => "SWISS FRANC"
        "NZD" => "NEW ZEALAND DOLLAR"
        => ccy

f_tf_text() =>
    timeframe.isintraday ? timeframe.period + "m" :
     timeframe.isdaily ? "D" :
     timeframe.isweekly ? "W" :
     timeframe.ismonthly ? "M" : timeframe.period

f_table_position(string posText) =>
    switch posText
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_table_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small

f_num_text(float v) =>
    na(v) ? "na" : str.tostring(v, "#.##")

f_pct_text(float v) =>
    na(v) ? "na" : (v > 0 ? "+" : "") + str.tostring(v, "#.##") + "%"

f_meter_bar(float score) =>
    int filled = not na(score) ? int(math.round(math.abs(score) / 10.0)) : 0
    filled := math.max(0, math.min(filled, 10))

    string bars = ""
    for i = 1 to 10
        bars += i <= filled ? "█" : "░"

    bars

f_strength_bg(float score) =>
    na(score) ? color.new(color.gray, 90) :
     math.abs(score) <= 5 ? color.new(color.gray, 90) :
     score >= 70 ? color.new(#089981, 75) :
     score >= 35 ? color.new(#089981, 85) :
     score > 0 ? color.new(#089981, 95) :
     score <= -70 ? color.new(#f23645, 75) :
     score <= -35 ? color.new(#f23645, 85) :
     color.new(#f23645, 95)

f_strength_text_color(float score) =>
    na(score) ? chart.fg_color :
     math.abs(score) <= 5 ? chart.fg_color :
     score > 0 ? #089981 :
     #f23645

f_strength_state(float rawStrength, float score) =>
    na(rawStrength) ? "NO DATA" :
     math.abs(rawStrength) <= neutralThreshold ? "NEUTRAL" :
     score >= 70 ? "VERY STRONG" :
     score >= 35 ? "STRONG" :
     score > 0 ? "MILD BULL" :
     score <= -70 ? "VERY WEAK" :
     score <= -35 ? "WEAK" :
     "MILD BEAR"

f_ema_state(float deltaValue) =>
    na(deltaValue) ? "NO DATA" :
     math.abs(deltaValue) <= emaFlatThreshold ? "FLAT" :
     deltaValue > 0 ? "UP" :
     "DOWN"

f_ema_arrow(float deltaValue) =>
    na(deltaValue) ? "·" :
     math.abs(deltaValue) <= emaFlatThreshold ? "→" :
     deltaValue > 0 ? "▲" :
     "▼"

f_ema_bg(float deltaValue) =>
    na(deltaValue) ? color.new(color.gray, 90) :
     math.abs(deltaValue) <= emaFlatThreshold ? color.new(color.gray, 88) :
     deltaValue > 0 ? color.new(#089981, 82) :
     color.new(#f23645, 82)

f_ema_text_color(float deltaValue) =>
    na(deltaValue) ? chart.fg_color :
     math.abs(deltaValue) <= emaFlatThreshold ? chart.fg_color :
     deltaValue > 0 ? #089981 :
     #f23645


f_vol_width(float score) =>
    int w = 3

    if useVolLayer and useDynamicWidth
        w := score >= extremeThr ? 5 :
             score >= expansionThr ? 4 :
             score <= quietThr ? 2 : 3

    w

f_vol_color(color baseColor, float score) =>
    color finalColor = baseColor

    if useVolLayer and useVolFade
        finalColor := score >= extremeThr ? color.new(baseColor, 0) :
             score >= expansionThr ? color.new(baseColor, 10) :
             score <= quietThr ? color.new(baseColor, 65) :
             color.new(baseColor, 35)

    finalColor

f_vol_text(float score) =>
    score >= extremeThr ? "VOL: EXTREME" :
     score >= expansionThr ? "VOL: EXPANSION" :
     score <= quietThr ? "VOL: QUIET" :
     "VOL: NORMAL"

f_state_text(bool bullish, float score) =>
    score <= quietThr ? "STATE: COMPRESSION" :
     score >= extremeThr and bullish ? "STATE: BULLISH IMPULSE" :
     score >= extremeThr and not bullish ? "STATE: BEARISH IMPULSE" :
     score >= expansionThr and bullish ? "STATE: BULLISH PRESSURE" :
     score >= expansionThr and not bullish ? "STATE: BEARISH PRESSURE" :
     bullish ? "STATE: BULLISH DRIFT" :
     "STATE: BEARISH DRIFT"

//──────────────────────────────────────────────────────────────────────────────
// Composite Force Table Engine
// The custom index widgets remain unchanged. This block only upgrades the table.
//──────────────────────────────────────────────────────────────────────────────
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(x, hi))

f_idx_return(float idxClose) =>
    float refValue = idxClose[strengthLookback]
    not na(idxClose) and not na(refValue) and refValue != 0 ? (idxClose / refValue - 1.0) * 100.0 : na

f_pair_return(int idx) =>
    float c = array.get(cArr, idx)
    float ref = c[strengthLookback]
    not na(c) and not na(ref) and c > 0 and ref > 0 ? (c / ref - 1.0) * 100.0 : na

f_vote(float x) =>
    na(x) ? 0.0 :
     x > neutralThreshold ? 1.0 :
     x < -neutralThreshold ? -1.0 :
     0.0

f_strength_factor(float rawStrength, float maxAbsStrength) =>
    not na(rawStrength) and maxAbsStrength != 0 ? f_clamp(rawStrength / maxAbsStrength * 100.0, -100.0, 100.0) : 0.0

f_efficiency(float x, int len) =>
    float net = x - x[len]
    float path = math.sum(math.abs(x - x[1]), len)
    not na(net) and not na(path) and path != 0 ? f_clamp(net / path * 100.0, -100.0, 100.0) : 0.0

f_impulse(float x, int len) =>
    float ch = x - x[1]
    float avgAbs = ta.sma(math.abs(x - x[1]), len)
    not na(ch) and not na(avgAbs) and avgAbs != 0 ? f_clamp(ch / avgAbs * 50.0, -100.0, 100.0) : 0.0

f_persistence(float x, int len) =>
    float up = x > x[1] ? 1.0 : 0.0
    float dn = x < x[1] ? 1.0 : 0.0
    float upSum = math.sum(up, len)
    float dnSum = math.sum(dn, len)
    f_clamp((upSum - dnSum) / len * 100.0, -100.0, 100.0)

f_acceleration(float rawStrength, int bars, float cap) =>
    float dNow = rawStrength - rawStrength[1]
    float dOld = rawStrength[bars] - rawStrength[bars + 1]
    float a = dNow - dOld
    not na(a) and cap != 0 ? f_clamp(a / cap * 100.0, -100.0, 100.0) : 0.0

f_force(float strength, float breadth, float efficiency, float impulse, float persistence, float accel) =>
    float totalW = wStrength + wBreadth + wEfficiency + wImpulse + wPersistence + wAccel
    totalW > 0 ?
         f_clamp(
             (
                 strength    * wStrength +
                 breadth     * wBreadth +
                 efficiency  * wEfficiency +
                 impulse     * wImpulse +
                 persistence * wPersistence +
                 accel       * wAccel
             ) / totalW,
             -100.0,
             100.0
         ) :
         0.0

f_phase(float score, float breadth, float impulse, float accel) =>
    math.abs(score) < 15 ? "ROTATION" :
     score >= 60 and accel < -25 ? "BULL EXHAUST" :
     score <= -60 and accel > 25 ? "BEAR EXHAUST" :
     score >= 65 and breadth >= 40 and impulse > 10 ? "BULL EXPAND" :
     score <= -65 and breadth <= -40 and impulse < -10 ? "BEAR EXPAND" :
     score >= 35 and breadth >= 20 ? "BULL BUILD" :
     score <= -35 and breadth <= -20 ? "BEAR BUILD" :
     score > 0 ? "BULL DRIFT" :
     "BEAR DRIFT"

//──────────────────────────────────────────────────────────────────────────────
// Professional theme engine — readable on both light and dark charts.
// Auto follows TradingView's chart.bg_color/chart.fg_color.
//──────────────────────────────────────────────────────────────────────────────
f_theme_bg() =>
    themeMode == "Dark" ? color.rgb(11, 14, 19) :
     themeMode == "Light" ? color.rgb(255, 255, 255) :
     chart.bg_color

f_theme_fg() =>
    themeMode == "Dark" ? color.rgb(235, 239, 245) :
     themeMode == "Light" ? color.rgb(22, 27, 34) :
     chart.fg_color

f_muted_text() =>
    themeMode == "Dark" ? color.rgb(150, 160, 174) :
     themeMode == "Light" ? color.rgb(91, 103, 120) :
     color.new(chart.fg_color, 22)

f_header_bg() =>
    themeMode == "Dark" ? color.rgb(21, 26, 35) :
     themeMode == "Light" ? color.rgb(238, 242, 247) :
     color.new(chart.fg_color, 88)

f_panel_bg() =>
    themeMode == "Dark" ? color.rgb(16, 21, 29) :
     themeMode == "Light" ? color.rgb(246, 248, 252) :
     color.new(chart.fg_color, 92)

f_cell_bg() =>
    themeMode == "Dark" ? color.rgb(13, 18, 26) :
     themeMode == "Light" ? color.rgb(250, 251, 253) :
     color.new(chart.fg_color, 96)

f_alt_row_bg() =>
    themeMode == "Dark" ? color.rgb(15, 20, 28) :
     themeMode == "Light" ? color.rgb(249, 250, 252) :
     color.new(chart.fg_color, 97)

f_grid_color() =>
    themeMode == "Dark" ? color.rgb(45, 55, 72) :
     themeMode == "Light" ? color.rgb(218, 225, 235) :
     color.new(chart.fg_color, 82)

f_pos_color() =>
    tableAccent == "Blue" ? color.rgb(38, 132, 255) :
     tableAccent == "Gold" ? color.rgb(245, 158, 11) :
     tableAccent == "Mono" ? f_theme_fg() :
     color.rgb(8, 153, 129)

f_neg_color() =>
    tableAccent == "Mono" ? f_muted_text() : color.rgb(242, 54, 69)

f_pos_bg(int t) =>
    color.new(f_pos_color(), t)

f_neg_bg(int t) =>
    color.new(f_neg_color(), t)

f_rank_bg(int rank) =>
    rank == 0 ? f_pos_bg(82) :
     rank == 7 ? f_neg_bg(82) :
     rank % 2 == 0 ? f_theme_bg() : f_alt_row_bg()

f_label_bg() =>
    themeMode == "Dark" ? color.new(color.rgb(11, 14, 19), 8) :
     themeMode == "Light" ? color.new(color.rgb(255, 255, 255), 8) :
     color.new(chart.bg_color, 8)

f_phase_bg(string p) =>
    str.contains(p, "BULL") ? f_pos_bg(84) :
     str.contains(p, "BEAR") ? f_neg_bg(84) :
     f_panel_bg()

f_factor_text_color(float v) =>
    na(v) ? f_theme_fg() :
     v > 0 ? f_pos_color() :
     v < 0 ? f_neg_color() :
     f_muted_text()

f_force_bg(float v) =>
    int strongT = useSoftTable ? 78 : 18
    int midT = useSoftTable ? 86 : 56
    int mildT = useSoftTable ? 92 : 78
    na(v) ? f_cell_bg() :
     v >= 75 ? f_pos_bg(strongT) :
     v >= 40 ? f_pos_bg(midT) :
     v > 15  ? f_pos_bg(mildT) :
     v <= -75 ? f_neg_bg(strongT) :
     v <= -40 ? f_neg_bg(midT) :
     v < -15  ? f_neg_bg(mildT) :
     f_panel_bg()

f_force_text_color(float v) =>
    na(v) ? f_theme_fg() :
     v > 15 ? f_pos_color() :
     v < -15 ? f_neg_color() :
     f_muted_text()

f_currency_color(string ccy) =>
    switch ccy
        "USD" => color.rgb(239, 83, 80)
        "EUR" => color.rgb(66, 133, 244)
        "GBP" => color.rgb(38, 166, 154)
        "JPY" => color.rgb(236, 64, 122)
        "AUD" => color.rgb(255, 167, 38)
        "NZD" => color.rgb(41, 182, 246)
        "CAD" => color.rgb(255, 193, 7)
        "CHF" => color.rgb(126, 87, 194)
        => chart.fg_color

f_bias(float diff, float gap) =>
    na(diff) ? "—" :
     math.abs(diff) < gap ? "NEUTRAL" :
     diff > 0 ? "BUY" :
     "SELL"

f_bias_bg(string b) =>
    b == "BUY" ? f_pos_bg(82) :
     b == "SELL" ? f_neg_bg(82) :
     f_panel_bg()

f_bias_text(string b) =>
    b == "BUY" ? f_pos_color() :
     b == "SELL" ? f_neg_color() :
     f_muted_text()

f_best_pair(string strong, string weak) =>
    string out = "—"

    for i = 0 to pairCount - 1
        string p = array.get(pairSymbols, i)
        string b = array.get(pairBase, i)
        string q = array.get(pairQuote, i)
        string clean = str.replace_all(p, prefix, "")

        if strong == b and weak == q
            out := "BUY " + clean

        if strong == q and weak == b
            out := "SELL " + clean

    out

// Pair returns from the already-requested pair close data. No extra request.security calls.
r_EURUSD = f_pair_return(0)
r_GBPUSD = f_pair_return(1)
r_USDJPY = f_pair_return(2)
r_USDCHF = f_pair_return(3)
r_USDCAD = f_pair_return(4)
r_AUDUSD = f_pair_return(5)
r_NZDUSD = f_pair_return(6)
r_EURGBP = f_pair_return(7)
r_EURJPY = f_pair_return(8)
r_EURCHF = f_pair_return(9)
r_EURCAD = f_pair_return(10)
r_EURAUD = f_pair_return(11)
r_EURNZD = f_pair_return(12)
r_GBPJPY = f_pair_return(13)
r_GBPCHF = f_pair_return(14)
r_GBPCAD = f_pair_return(15)
r_GBPAUD = f_pair_return(16)
r_GBPNZD = f_pair_return(17)
r_CHFJPY = f_pair_return(18)
r_CADJPY = f_pair_return(19)
r_CADCHF = f_pair_return(20)
r_AUDJPY = f_pair_return(21)
r_AUDCHF = f_pair_return(22)
r_AUDCAD = f_pair_return(23)
r_AUDNZD = f_pair_return(24)
r_NZDJPY = f_pair_return(25)
r_NZDCHF = f_pair_return(26)
r_NZDCAD = f_pair_return(27)

// Breadth: how many of the 7 related pairs confirm each currency.
eurBreadth = (f_vote(+r_EURUSD) + f_vote(+r_EURGBP) + f_vote(+r_EURJPY) + f_vote(+r_EURCHF) + f_vote(+r_EURAUD) + f_vote(+r_EURNZD) + f_vote(+r_EURCAD)) / 7.0 * 100.0
gbpBreadth = (f_vote(+r_GBPUSD) + f_vote(-r_EURGBP) + f_vote(+r_GBPJPY) + f_vote(+r_GBPCHF) + f_vote(+r_GBPCAD) + f_vote(+r_GBPAUD) + f_vote(+r_GBPNZD)) / 7.0 * 100.0
usdBreadth = (f_vote(-r_EURUSD) + f_vote(-r_GBPUSD) + f_vote(-r_AUDUSD) + f_vote(-r_NZDUSD) + f_vote(+r_USDCAD) + f_vote(+r_USDCHF) + f_vote(+r_USDJPY)) / 7.0 * 100.0
jpyBreadth = (f_vote(-r_USDJPY) + f_vote(-r_EURJPY) + f_vote(-r_GBPJPY) + f_vote(-r_AUDJPY) + f_vote(-r_NZDJPY) + f_vote(-r_CADJPY) + f_vote(-r_CHFJPY)) / 7.0 * 100.0
audBreadth = (f_vote(+r_AUDUSD) + f_vote(-r_EURAUD) + f_vote(-r_GBPAUD) + f_vote(+r_AUDJPY) + f_vote(+r_AUDCHF) + f_vote(+r_AUDCAD) + f_vote(+r_AUDNZD)) / 7.0 * 100.0
nzdBreadth = (f_vote(+r_NZDUSD) + f_vote(-r_EURNZD) + f_vote(-r_GBPNZD) + f_vote(+r_NZDJPY) + f_vote(+r_NZDCHF) + f_vote(+r_NZDCAD) + f_vote(-r_AUDNZD)) / 7.0 * 100.0
cadBreadth = (f_vote(-r_USDCAD) + f_vote(-r_EURCAD) + f_vote(-r_GBPCAD) + f_vote(-r_AUDCAD) + f_vote(-r_NZDCAD) + f_vote(+r_CADJPY) + f_vote(+r_CADCHF)) / 7.0 * 100.0
chfBreadth = (f_vote(-r_USDCHF) + f_vote(-r_EURCHF) + f_vote(-r_GBPCHF) + f_vote(-r_AUDCHF) + f_vote(-r_NZDCHF) + f_vote(-r_CADCHF) + f_vote(+r_CHFJPY)) / 7.0 * 100.0

maxAbsStrengthForce = math.max(
     math.max(math.max(math.abs(nz(usdStr)), math.abs(nz(eurStr))), math.max(math.abs(nz(gbpStr)), math.abs(nz(jpyStr)))),
     math.max(math.max(math.abs(nz(audStr)), math.abs(nz(nzdStr))), math.max(math.abs(nz(cadStr)), math.abs(nz(chfStr))))
)
maxAbsStrengthForce := na(maxAbsStrengthForce) or maxAbsStrengthForce == 0 ? 1.0 : maxAbsStrengthForce

usdSf = f_strength_factor(usdStr, maxAbsStrengthForce)
eurSf = f_strength_factor(eurStr, maxAbsStrengthForce)
gbpSf = f_strength_factor(gbpStr, maxAbsStrengthForce)
jpySf = f_strength_factor(jpyStr, maxAbsStrengthForce)
audSf = f_strength_factor(audStr, maxAbsStrengthForce)
nzdSf = f_strength_factor(nzdStr, maxAbsStrengthForce)
cadSf = f_strength_factor(cadStr, maxAbsStrengthForce)
chfSf = f_strength_factor(chfStr, maxAbsStrengthForce)

usdEff = f_efficiency(usdC, effLen)
eurEff = f_efficiency(eurC, effLen)
gbpEff = f_efficiency(gbpC, effLen)
jpyEff = f_efficiency(jpyC, effLen)
audEff = f_efficiency(audC, effLen)
nzdEff = f_efficiency(nzdC, effLen)
cadEff = f_efficiency(cadC, effLen)
chfEff = f_efficiency(chfC, effLen)

usdImp = f_impulse(usdC, impulseLen)
eurImp = f_impulse(eurC, impulseLen)
gbpImp = f_impulse(gbpC, impulseLen)
jpyImp = f_impulse(jpyC, impulseLen)
audImp = f_impulse(audC, impulseLen)
nzdImp = f_impulse(nzdC, impulseLen)
cadImp = f_impulse(cadC, impulseLen)
chfImp = f_impulse(chfC, impulseLen)

usdPer = f_persistence(usdC, persistLen)
eurPer = f_persistence(eurC, persistLen)
gbpPer = f_persistence(gbpC, persistLen)
jpyPer = f_persistence(jpyC, persistLen)
audPer = f_persistence(audC, persistLen)
nzdPer = f_persistence(nzdC, persistLen)
cadPer = f_persistence(cadC, persistLen)
chfPer = f_persistence(chfC, persistLen)

usdAcc = f_acceleration(usdStr, accelBars, accelCap)
eurAcc = f_acceleration(eurStr, accelBars, accelCap)
gbpAcc = f_acceleration(gbpStr, accelBars, accelCap)
jpyAcc = f_acceleration(jpyStr, accelBars, accelCap)
audAcc = f_acceleration(audStr, accelBars, accelCap)
nzdAcc = f_acceleration(nzdStr, accelBars, accelCap)
cadAcc = f_acceleration(cadStr, accelBars, accelCap)
chfAcc = f_acceleration(chfStr, accelBars, accelCap)

usdForce = f_force(usdSf, usdBreadth, usdEff, usdImp, usdPer, usdAcc)
eurForce = f_force(eurSf, eurBreadth, eurEff, eurImp, eurPer, eurAcc)
gbpForce = f_force(gbpSf, gbpBreadth, gbpEff, gbpImp, gbpPer, gbpAcc)
jpyForce = f_force(jpySf, jpyBreadth, jpyEff, jpyImp, jpyPer, jpyAcc)
audForce = f_force(audSf, audBreadth, audEff, audImp, audPer, audAcc)
nzdForce = f_force(nzdSf, nzdBreadth, nzdEff, nzdImp, nzdPer, nzdAcc)
cadForce = f_force(cadSf, cadBreadth, cadEff, cadImp, cadPer, cadAcc)
chfForce = f_force(chfSf, chfBreadth, chfEff, chfImp, chfPer, chfAcc)

f_pick_force(string ccy) =>
    switch ccy
        "USD" => usdForce
        "EUR" => eurForce
        "GBP" => gbpForce
        "JPY" => jpyForce
        "AUD" => audForce
        "NZD" => nzdForce
        "CAD" => cadForce
        "CHF" => chfForce
        => na

usdPhase = f_phase(usdForce, usdBreadth, usdImp, usdAcc)
eurPhase = f_phase(eurForce, eurBreadth, eurImp, eurAcc)
gbpPhase = f_phase(gbpForce, gbpBreadth, gbpImp, gbpAcc)
jpyPhase = f_phase(jpyForce, jpyBreadth, jpyImp, jpyAcc)
audPhase = f_phase(audForce, audBreadth, audImp, audAcc)
nzdPhase = f_phase(nzdForce, nzdBreadth, nzdImp, nzdAcc)
cadPhase = f_phase(cadForce, cadBreadth, cadImp, cadAcc)
chfPhase = f_phase(chfForce, chfBreadth, chfImp, chfAcc)

var table strengthTable = table.new(
     f_table_position(strengthTablePos),
     10,
     10,
     bgcolor = f_theme_bg(),
     border_color = f_grid_color(),
     border_width = 1,
     frame_color = f_grid_color(),
     frame_width = 1
)


//──────────────────────────────────────────────────────────────────────────────
// Render Widget
//──────────────────────────────────────────────────────────────────────────────
method render(MiniWidget w, bool show, string ccy, int slot) =>
    w.deleteObjects()

    if show and array.size(w.c) > 0
        int n = math.min(numberOfBars, array.size(w.c))

        float lo = na
        float hi = na

        for i = 0 to n - 1
            float lv = array.get(w.l, i)
            float hv = array.get(w.h, i)

            lo := na(lo) ? lv : math.min(lo, lv)
            hi := na(hi) ? hv : math.max(hi, hv)

        float rng = hi - lo
        rng := rng == 0 ? 0.000001 : rng

        int avgN = math.min(volAvgBars, n)
        float rangeSum = 0.0

        for k = 0 to avgN - 1
            rangeSum += math.abs(array.get(w.h, k) - array.get(w.l, k))

        float avgRange = avgN > 0 ? rangeSum / avgN : na
        avgRange := na(avgRange) or avgRange == 0 ? 0.000001 : avgRange

        float offset = f_slot_offset(slot)

        for j = 0 to n - 1
            int ai = n - 1 - j
            int x  = bar_index + hOffset + j

            float oVal = array.get(w.o, ai)
            float hVal = array.get(w.h, ai)
            float lVal = array.get(w.l, ai)
            float cVal = array.get(w.c, ai)

            float yO = offset + widgetHeight * (oVal - lo) / rng
            float yH = offset + widgetHeight * (hVal - lo) / rng
            float yL = offset + widgetHeight * (lVal - lo) / rng
            float yC = offset + widgetHeight * (cVal - lo) / rng

            float barRange = math.abs(hVal - lVal)
            float volScore = barRange / avgRange

            color baseCandleColor = cVal >= oVal ? bullColor : bearColor
            color candleColor = f_vol_color(baseCandleColor, volScore)

            int bodyWidth = f_vol_width(volScore)
            int wickWidth = useVolLayer and volScore >= extremeThr ? 2 : 1

            line wick = line.new(
                 x,
                 yH,
                 x,
                 yL,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = candleColor,
                 width = wickWidth
            )

            line body = line.new(
                 x,
                 yO,
                 x,
                 yC,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = candleColor,
                 width = bodyWidth
            )

            array.push(w.drawings, wick)
            array.push(w.drawings, body)

        if showWidgetEma and n >= 2
            array<chart.point> emaPts = array.new<chart.point>()
            float alpha = 2.0 / (widgetEmaLen + 1.0)
            float emaCalc = na

            for e = 0 to n - 1
                int aiE = n - 1 - e
                int xE = bar_index + hOffset + e
                float closeE = array.get(w.c, aiE)

                emaCalc := na(emaCalc) ? closeE : alpha * closeE + (1.0 - alpha) * emaCalc

                float yEma = offset + widgetHeight * (emaCalc - lo) / rng
                array.push(emaPts, chart.point.from_index(xE, yEma))

            w.emaPlot := polyline.new(
                 emaPts,
                 false,
                 false,
                 xloc.bar_index,
                 widgetEmaColor,
                 color.new(widgetEmaColor, 100),
                 line.style_solid,
                 widgetEmaWidth
            )

        if showPanel
            float lastClose = array.get(w.c, 0)
            float lastOpen  = array.get(w.o, 0)
            float lastHigh  = array.get(w.h, 0)
            float lastLow   = array.get(w.l, 0)

            bool bullish = lastClose >= lastOpen
            float labelY = offset + widgetHeight * 0.5
            color labelColor = bullish ? bullColor : bearColor

            float change = lastOpen != 0 ? (lastClose - lastOpen) / lastOpen * 100 : na
            string priceGoing = bullish ? "▲ +" + str.tostring(change, "#.##") + "%" : "▼ " + str.tostring(change, "#.##") + "%"

            float currentRange = math.abs(lastHigh - lastLow)
            float currentVolScore = currentRange / avgRange

            string fullName = f_get_full_name(ccy)

            string volLine = useVolLayer and showVolInLabel ? "\n" + f_vol_text(currentVolScore) + " x" + str.tostring(currentVolScore, "#.##") : ""
            string stateLine = useVolLayer and showVolInLabel ? "\n" + f_state_text(bullish, currentVolScore) : ""

            string panelText = fullName + " INDEX\n" +
                 str.tostring(lastClose, "#.##") + " " + priceGoing + "\n" +
                 f_tf_text() +
                 volLine +
                 stateLine

            color panelBgFinal = useThemeWidgetLabels ? f_label_bg() : color.new(color.black, 100)
            color panelTxtFinal = useThemeWidgetLabels ? (bullish ? f_pos_color() : f_neg_color()) : labelColor

            w.panel := label.new(
                 bar_index + hOffset + n + 3,
                 labelY,
                 panelText,
                 xloc = xloc.bar_index,
                 style = label.style_label_left,
                 color = panelBgFinal,
                 textcolor = panelTxtFinal,
                 textalign = text.align_left,
                 size = size.small
            )

        if showSep
            color sepFinal = useThemeSeparators ? f_grid_color() : sepColor
            w.separator := line.new(
                 bar_index + hOffset - 5,
                 offset - widgetGap * 0.50,
                 bar_index + hOffset + numberOfBars + 20,
                 offset - widgetGap * 0.50,
                 xloc = xloc.bar_index,
                 extend = extend.none,
                 color = sepFinal,
                 width = 1
            )

    true

//──────────────────────────────────────────────────────────────────────────────
// Create 8 Widgets
//──────────────────────────────────────────────────────────────────────────────
var MiniWidget widget1 = MiniWidget.new("", array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_line(), na, label(na), line(na))
var MiniWidget widget2 = MiniWidget.new("", array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_line(), na, label(na), line(na))
var MiniWidget widget3 = MiniWidget.new("", array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_line(), na, label(na), line(na))
var MiniWidget widget4 = MiniWidget.new("", array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_line(), na, label(na), line(na))
var MiniWidget widget5 = MiniWidget.new("", array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_line(), na, label(na), line(na))
var MiniWidget widget6 = MiniWidget.new("", array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_line(), na, label(na), line(na))
var MiniWidget widget7 = MiniWidget.new("", array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_line(), na, label(na), line(na))
var MiniWidget widget8 = MiniWidget.new("", array.new_float(), array.new_float(), array.new_float(), array.new_float(), array.new_line(), na, label(na), line(na))

//──────────────────────────────────────────────────────────────────────────────
// Update Widget Data
//──────────────────────────────────────────────────────────────────────────────
bool newReqBar = ta.change(time(reqTf)) != 0 or barstate.isfirst

[w1O, w1H, w1L, w1C] = f_pick_index(w1CCY)
[w2O, w2H, w2L, w2C] = f_pick_index(w2CCY)
[w3O, w3H, w3L, w3C] = f_pick_index(w3CCY)
[w4O, w4H, w4L, w4C] = f_pick_index(w4CCY)
[w5O, w5H, w5L, w5C] = f_pick_index(w5CCY)
[w6O, w6H, w6L, w6C] = f_pick_index(w6CCY)
[w7O, w7H, w7L, w7C] = f_pick_index(w7CCY)
[w8O, w8H, w8L, w8C] = f_pick_index(w8CCY)

widget1.updateData(w1Show, w1CCY, w1O, w1H, w1L, w1C, newReqBar, numberOfBars)
widget2.updateData(w2Show, w2CCY, w2O, w2H, w2L, w2C, newReqBar, numberOfBars)
widget3.updateData(w3Show, w3CCY, w3O, w3H, w3L, w3C, newReqBar, numberOfBars)
widget4.updateData(w4Show, w4CCY, w4O, w4H, w4L, w4C, newReqBar, numberOfBars)
widget5.updateData(w5Show, w5CCY, w5O, w5H, w5L, w5C, newReqBar, numberOfBars)
widget6.updateData(w6Show, w6CCY, w6O, w6H, w6L, w6C, newReqBar, numberOfBars)
widget7.updateData(w7Show, w7CCY, w7O, w7H, w7L, w7C, newReqBar, numberOfBars)
widget8.updateData(w8Show, w8CCY, w8O, w8H, w8L, w8C, newReqBar, numberOfBars)

//──────────────────────────────────────────────────────────────────────────────
// Draw Widgets On Last Bar Only
//──────────────────────────────────────────────────────────────────────────────
if barstate.islast
    widget1.render(w1Show, w1CCY, 1)
    widget2.render(w2Show, w2CCY, 2)
    widget3.render(w3Show, w3CCY, 3)
    widget4.render(w4Show, w4CCY, 4)
    widget5.render(w5Show, w5CCY, 5)
    widget6.render(w6Show, w6CCY, 6)
    widget7.render(w7Show, w7CCY, 7)
    widget8.render(w8Show, w8CCY, 8)

    if showStrengthTable
        table.clear(strengthTable, 0, 0, 9, 9)

        color headBg = f_header_bg()
        color panelRowBg = f_panel_bg()
        color metricBg = f_cell_bg()
        string tSize = f_table_size(tableTextSize)

        string[] codes = array.from("USD", "EUR", "GBP", "JPY", "AUD", "NZD", "CAD", "CHF")
        float[] idxVals = array.from(usdC, eurC, gbpC, jpyC, audC, nzdC, cadC, chfC)
        float[] rawStrs = array.from(usdStr, eurStr, gbpStr, jpyStr, audStr, nzdStr, cadStr, chfStr)
        float[] forces = array.from(usdForce, eurForce, gbpForce, jpyForce, audForce, nzdForce, cadForce, chfForce)
        float[] breadths = array.from(usdBreadth, eurBreadth, gbpBreadth, jpyBreadth, audBreadth, nzdBreadth, cadBreadth, chfBreadth)
        float[] effs = array.from(usdEff, eurEff, gbpEff, jpyEff, audEff, nzdEff, cadEff, chfEff)
        float[] imps = array.from(usdImp, eurImp, gbpImp, jpyImp, audImp, nzdImp, cadImp, chfImp)
        float[] accs = array.from(usdAcc, eurAcc, gbpAcc, jpyAcc, audAcc, nzdAcc, cadAcc, chfAcc)
        string[] phases = array.from(usdPhase, eurPhase, gbpPhase, jpyPhase, audPhase, nzdPhase, cadPhase, chfPhase)

        int[] sorted = array.sort_indices(forces, order.descending)

        int topIdx = array.get(sorted, 0)
        int botIdx = array.get(sorted, 7)
        string strongCcy = array.get(codes, topIdx)
        string weakCcy = array.get(codes, botIdx)
        float forceGap = array.get(forces, topIdx) - array.get(forces, botIdx)
        string bestPair = forceGap >= bestPairGap ? f_best_pair(strongCcy, weakCcy) : "WAIT"

        string baseCcy = syminfo.basecurrency
        string quoteCcy = syminfo.currency
        float baseForce = f_pick_force(baseCcy)
        float quoteForce = f_pick_force(quoteCcy)
        float pairForceDiff = baseForce - quoteForce
        string chartBias = f_bias(pairForceDiff, pairGap)

        table.cell(strengthTable, 0, 0, "PAIR", text_color = f_theme_fg(), bgcolor = panelRowBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 1, 0, baseCcy + "/" + quoteCcy, text_color = f_theme_fg(), bgcolor = panelRowBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 2, 0, chartBias, text_color = f_bias_text(chartBias), bgcolor = f_bias_bg(chartBias), text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 3, 0, "Gap " + f_num_text(pairForceDiff), text_color = f_factor_text_color(pairForceDiff), bgcolor = panelRowBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 4, 0, strongCcy + " strongest", text_color = f_theme_fg(), bgcolor = panelRowBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 5, 0, weakCcy + " weakest", text_color = f_theme_fg(), bgcolor = panelRowBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 6, 0, bestPair, text_color = f_theme_fg(), bgcolor = panelRowBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 7, 0, forceGap >= bestPairGap ? "ACTIVE" : "WAIT", text_color = forceGap >= bestPairGap ? f_pos_color() : f_muted_text(), bgcolor = panelRowBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 8, 0, "Lookback " + str.tostring(strengthLookback), text_color = f_theme_fg(), bgcolor = panelRowBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 9, 0, "Force", text_color = f_theme_fg(), bgcolor = panelRowBg, text_halign = text.align_center, text_size = tSize)

        table.cell(strengthTable, 0, 1, "Rank",  text_color = f_theme_fg(), bgcolor = headBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 1, 1, "CCY",   text_color = f_theme_fg(), bgcolor = headBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 2, 1, "Index", text_color = f_theme_fg(), bgcolor = headBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 3, 1, "Δ%",    text_color = f_theme_fg(), bgcolor = headBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 4, 1, "Force", text_color = f_theme_fg(), bgcolor = headBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 5, 1, "Meter", text_color = f_theme_fg(), bgcolor = headBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 6, 1, "Brd",   text_color = f_theme_fg(), bgcolor = headBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 7, 1, "Eff",   text_color = f_theme_fg(), bgcolor = headBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 8, 1, "Imp/Acc", text_color = f_theme_fg(), bgcolor = headBg, text_halign = text.align_center, text_size = tSize)
        table.cell(strengthTable, 9, 1, "Phase", text_color = f_theme_fg(), bgcolor = headBg, text_halign = text.align_center, text_size = tSize)

        for r = 0 to 7
            int idx = array.get(sorted, r)
            int row = r + 2

            string ccy = array.get(codes, idx)
            float idxVal = array.get(idxVals, idx)
            float rawStr = array.get(rawStrs, idx)
            float forceVal = array.get(forces, idx)
            float breadthVal = array.get(breadths, idx)
            float effVal = array.get(effs, idx)
            float impVal = array.get(imps, idx)
            float accVal = array.get(accs, idx)
            string phaseVal = array.get(phases, idx)

            color rowBg = f_rank_bg(r)
            color forceBg = f_force_bg(forceVal)
            color forceText = f_force_text_color(forceVal)

            table.cell(strengthTable, 0, row, str.tostring(r + 1), text_color = f_theme_fg(), bgcolor = rowBg, text_halign = text.align_center, text_size = tSize)
            table.cell(strengthTable, 1, row, ccy, text_color = f_theme_fg(), bgcolor = rowBg, text_halign = text.align_center, text_size = tSize)
            table.cell(strengthTable, 2, row, f_num_text(idxVal), text_color = f_theme_fg(), bgcolor = rowBg, text_halign = text.align_center, text_size = tSize)
            table.cell(strengthTable, 3, row, f_pct_text(rawStr), text_color = f_factor_text_color(rawStr), bgcolor = rowBg, text_halign = text.align_center, text_size = tSize)
            table.cell(strengthTable, 4, row, f_num_text(forceVal), text_color = forceText, bgcolor = forceBg, text_halign = text.align_center, text_size = tSize)
            table.cell(strengthTable, 5, row, f_meter_bar(forceVal), text_color = forceText, bgcolor = forceBg, text_halign = text.align_center, text_size = tSize)
            table.cell(strengthTable, 6, row, f_num_text(breadthVal), text_color = f_factor_text_color(breadthVal), bgcolor = metricBg, text_halign = text.align_center, text_size = tSize)
            table.cell(strengthTable, 7, row, f_num_text(effVal), text_color = f_factor_text_color(effVal), bgcolor = metricBg, text_halign = text.align_center, text_size = tSize)
            table.cell(strengthTable, 8, row, f_num_text(impVal) + "/" + f_num_text(accVal), text_color = f_factor_text_color(impVal + accVal), bgcolor = metricBg, text_halign = text.align_center, text_size = tSize)
            table.cell(strengthTable, 9, row, phaseVal, text_color = f_theme_fg(), bgcolor = f_phase_bg(phaseVal), text_halign = text.align_center, text_size = tSize)
    else
        table.clear(strengthTable, 0, 0, 9, 9)
````
