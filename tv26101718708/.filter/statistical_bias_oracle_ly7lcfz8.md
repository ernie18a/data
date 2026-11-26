# Statistical Bias [Oracle]

- url: https://www.tradingview.com/script/LY7LCFz8-Statistical-Bias-Oracle/
- type: indicator
- pine_id: PUB;1ec29319b47e4eab853c5496eb2aa4af
- version: 1.0

## Description

[b]WHAT THIS INDICATOR DOES[/b]

https://www.tradingview.com/x/JI99rP7y/

Statistical Bias is a multi-asset, multi-timeframe directional bias engine that determines market direction by analysing reversal and continuation candle patterns across your entire correlated triad. Rather than reading bias from a single chart, it checks whether all three correlated assets agree on direction — and optionally requires alignment across two timeframe levels — before declaring a bias.

It then tracks whether that bias was historically correct and displays a running accuracy percentage, giving you a statistical gauge of how reliable the triad's consensus signal has been on your chosen timeframe.

This is an analysis and narrative tool. It does not generate buy or sell signals.

[b]THE CONCEPTS — WHAT EACH ONE IS AND HOW IT IS CALCULATED[/b]

[b]Candle-Based Bias Detection[/b]

The indicator determines directional bias on each asset by analysing how the previous candle interacted with the candle before it. It checks for two types of events:

[list]
[*] [b]Sweep and reclaim[/b] — The previous candle's low swept below the prior candle's low, but then closed back above it. This is a bullish sweep — price took out a low and rejected, indicating buyers stepped in. The bearish equivalent is when the previous candle's high swept above the prior high, but closed back below it.*

https://www.tradingview.com/x/rdbcgBpv/

*[*] [b]Continuation close[/b] — The previous candle closed above the prior candle's high (bullish continuation) or below the prior candle's low (bearish continuation). Price committed beyond the previous range entirely.
[/list]

https://www.tradingview.com/x/Qb8IoczD/

Either condition triggers a bias update. If a bullish sweep or bullish continuation close occurs, the asset's bias is set to bullish. If a bearish sweep or bearish continuation close occurs, it is set to bearish. The bias persists until a new opposing event occurs — it does not reset each candle.

This logic runs independently on all three assets in the triad, producing three separate bias readings.

[b]Multi-Timeframe Bias Validation[/b]

The indicator supports two validation modes for each asset's bias:

[list]
[*] [b]LTF Only[/b] — The asset's bias is determined solely from the selected bias timeframe. If the bias timeframe is set to 15m, only 15m candle patterns are analyzed.
[*] [b]LTF + HTF[/b] — The asset's bias must agree across two timeframe levels. The indicator automatically maps your bias timeframe to the next higher timeframe (1m maps to 5m, 5m to 15m, 15m to 1H, 1H to 4H, 4H to 1D, 1D to 1W, 1W to 1M). The same sweep/reclaim and continuation close logic runs on both timeframes independently. An asset's bias is only confirmed when both timeframes agree on direction. If they disagree, the asset's bias is set to neutral.
[/list]

This means in LTF + HTF mode, a single asset must show the same directional pattern on both the bias timeframe and the timeframe above before its individual bias is considered valid.

[b]Triad Bias Consensus[/b]

After each asset's individual bias is determined, the indicator applies a configurable consensus rule across the triad to produce the final triad bias:

[list]
[*] [b]Current Asset[/b] — The triad bias simply follows whichever asset you are charting. The other two assets are displayed for reference but do not affect the final bias output.
[*] [b]Majority[/b] — At least 2 out of 3 assets must agree on direction. If two are bullish and one is bearish, the triad bias is bullish. If no majority exists, the bias is neutral.
[*] [b]All 3[/b] — All three assets must show the same directional bias. If even one asset disagrees or is neutral, the triad bias is neutral. This is the strictest mode and produces the fewest signals but the highest conviction.
[/list]

The triad bias is the final output — it represents the consensus view of the entire correlated group, not just your single chart.

[b]Accuracy Tracking[/b]

When the bias timeframe matches your chart timeframe, the indicator tracks historical accuracy. On each new bias-timeframe candle, it checks whether the previous triad bias correctly predicted the subsequent candle's direction:

[list]
[*] A bullish triad bias is counted as correct if the next candle made a higher high than the previous candle.
[*] A bearish triad bias is counted as correct if the next candle made a lower low than the previous candle.
[*] Neutral bias candles are excluded from the count entirely.
[/list]

The accuracy percentage is displayed in the table as a running total across all historical bars. This gives you a statistical measure of how reliable the triad consensus has been on your specific asset and timeframe combination — not a theoretical backtest, but actual historical performance of the bias logic on your chart.

[b]Draw on Liquidity (DOL)[/b]

When the bias timeframe is different from your chart timeframe, the indicator draws a Draw on Liquidity line showing the expected target level based on the triad bias:

[list]
[*] [b]Bullish bias[/b] — A horizontal line is drawn at the previous bias-timeframe candle's high. This represents the most recent liquidity pool above that the market is expected to draw toward.
[*] [b]Bearish bias[/b] — A horizontal line is drawn at the previous bias-timeframe candle's low. This represents the liquidity pool below.
[/list]

The DOL line extends forward as long as it has not been reached. Once price trades through it, the line stops extending. This gives you a concrete price target derived from the triad's consensus direction.

[b]Bias Table Display[/b]

A table in the corner of the chart displays the current state of the entire bias system. Two display modes are available:

[list]
[*] [b]Full mode[/b] — Shows a grid with each asset across the top, LTF and HTF bias rows, the final triad bias, and the accuracy percentage. You can see at a glance which assets agree, which timeframes align, and how accurate the consensus has been historically.
[*] [b]Compact mode[/b] — Shows just the asset names colored by their individual bias direction and the final triad bias. Minimal screen space for traders who only need the bottom-line output.
[/list]

The table updates at the start of each new bias-timeframe candle.

[b]HOW THE CONCEPTS WORK TOGETHER[/b]

These are not independent readings stacked in a table. They form a hierarchical filtering system where each layer narrows the bias output:

[list=1]
[*] [b]Candle pattern detection identifies raw direction per asset.[/b] Sweep-and-reclaim and continuation close patterns are detected on each of the three triad assets independently. This is the raw signal layer — each asset reports its own directional bias based on how its candles interacted with prior ranges.

[*] [b]Multi-timeframe validation filters false signals.[/b] In LTF + HTF mode, each asset's bias must be confirmed across two timeframe levels. A 15m bullish sweep that contradicts a 1H bearish pattern gets neutralized. This eliminates bias signals that only exist on a single timeframe — the direction must be consistent across the time structure.

[*] [b]Triad consensus filters further.[/b] After individual asset biases are validated, the consensus rule determines whether the group agrees. In All 3 mode, every asset must independently arrive at the same directional conclusion through its own candle patterns on its own price data. A bullish bias on NQ means nothing if ES and YM are not also bullish. This cross-asset agreement is the strongest filter — it requires the entire correlated group to show the same directional commitment.

[*] [b]Accuracy tracking validates the system.[/b] The running accuracy percentage tells you whether this filtering process actually works on your specific asset and timeframe. Rather than trusting the logic theoretically, you can see its historical hit rate directly on your chart. This closes the feedback loop — you are not just following a bias, you know how often that bias has been correct.

[*] [b]DOL provides the target.[/b] Once the triad agrees on direction, the Draw on Liquidity line gives you a specific price level the market is expected to draw toward. This transforms a directional bias into an actionable target level.
[/list]

The workflow flows from raw candle patterns, through timeframe alignment, through cross-asset consensus, through statistical validation, to a concrete price target. Each layer increases the quality of the output.

[b]WHY IS THIS INDICATOR WORTH USING?/b]

https://www.tradingview.com/x/3RsnHNkV/

Without this indicator, building a multi-asset, multi-timeframe statistical bias requires a trader to:

[list]
[*] Open three charts and manually check whether the previous candle on each asset swept a prior low/high and reclaimed, or closed beyond the prior range
[*] Repeat this analysis on the next higher timeframe for each asset to check alignment
[*] Mentally aggregate whether the majority or all three assets agree
[*] Keep a manual tally of how often this consensus was historically correct
[*] Identify and track the DOL level based on the consensus direction
[/list]

This process is tedious and error-prone even for a single timeframe check. Doing it across three assets and two timeframes simultaneously in real time is not practical manually.

The indicator automates the full pipeline — independent bias detection on three assets across two timeframes, configurable consensus rules, historical accuracy tracking with a running percentage, and DOL visualization — into a single overlay with a clean table display.

Several features are entirely original to this script:

[list]
[*] Cross-asset sweep/reclaim and continuation close consensus with configurable agreement rules (Current, Majority, All 3)
[*] Automatic LTF + HTF alignment validation per asset before consensus is applied
[*] Built-in historical accuracy tracking that measures actual prediction performance on the current chart
[*] DOL line derived from triad consensus direction rather than single-asset analysis
[/list]

No existing TradingView indicator combines multi-asset candle pattern bias detection, multi-timeframe validation, configurable consensus rules, statistical accuracy tracking, and draw-on-liquidity targeting in a single tool. These features cannot be replicated by combining existing public scripts because they require cross-asset bias comparison logic that single-asset indicators do not have.

[b]HOW TO USE IT[/b]

https://www.tradingview.com/x/HuoJSuRm/

[list=1]
[*] Add the indicator to your chart. It will automatically detect your asset triad or use your manual configuration.
[*] Select your bias timeframe — this is the timeframe on which candle patterns are analyzed. If your chart is 5m and your bias TF is 15m, the indicator checks 15m candle patterns on all three assets.
[*] Choose your validation mode — LTF Only for single-timeframe bias, or LTF + HTF for dual-timeframe alignment per asset.
[*] Choose your consensus rule — Current Asset for single-asset bias, Majority for 2-of-3 agreement, or All 3 for unanimous consensus.
[*] Read the table: each asset shows BULL, BEAR, or neutral. The TRIAD row shows the final consensus output. The ACC row shows historical accuracy.
[*] Use the DOL line as your directional target when the triad agrees on bias.
[*] Combine with other Quarterly Theory tools — use the triad bias to frame your LTF entries. A bullish triad bias means you look for bullish SSMTs, bullish PSPs, and bullish tCISDs on lower timeframes.
[/list]

[b]AUTO TRIAD[/b]

The indicator automatically assigns the correct correlated triad based on your chart ticker:

[list]
[*] [b]Index Futures:[/b] NQ / ES / YM (+ micro variants MNQ / MES / MYM)
[*] [b]Forex:[/b] EURUSD / GBPUSD / DXY
[*] [b]Crypto:[/b] BTCUSD / ETHUSD / DXY via Kraken
[/list]

For unsupported tickers, manual configuration is available.

[b]SETTINGS OVERVIEW[/b]

[list]
[*] [b]Asset Selection[/b] — Auto triad toggle, manual ticker inputs for three assets
[*] [b]Bias Timeframes[/b] — Custom bias TF toggle, bias timeframe selector
[*] [b]Bias Logic[/b] — Asset validation mode (LTF Only / LTF + HTF), triad consensus rule (Current Asset / Majority / All 3)
[*] [b]Visual Output[/b] — Table mode (Full / Compact), DOL line toggle
[*] [b]Color Customisation[/b] — Bullish, bearish, and neutral colours
[*] [b]DOL Styling[/b] — Line colour, text colour
[/list]

INDICATOR SETTINGS/FILTERS

Here is an inside look of how the Statistical Bias [Oracle] looks:

https://www.tradingview.com/x/trEdfCpM/

[b]DISCLAIMER[/b]

[i]This indicator is for educational and informational purposes only. It does not constitute financial advice. Trading involves substantial risk of loss. Always use proper risk management and conduct your own analysis.[/i]

[b]CREDITS[/b]

[i]Developed by Danielliuks and Bucko. Conceptual framework based on ICT (Michael Huddleston)[/i]

Open Sourced For all.
Enjoy.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Danielliuks

//@version=6
indicator("Statistical Bias [Oracle]", overlay = true, max_bars_back = 5000)

use_auto_triad = input.bool(false, "Auto Triad", group="① Asset Selection")

sym1 = input.symbol("CME_MINI:NQ1!", "Asset 1", group="① Asset Selection")
sym2 = input.symbol("CME_MINI:ES1!", "Asset 2", group="① Asset Selection")
sym3 = input.symbol("CBOT_MINI:YM1!", "Asset 3", group="① Asset Selection")

// ───── ② Bias Timeframes ─────
useCustomTF = input.bool(false, "Custom Bias TF", group="② Bias Timeframes")
customTF    = input.timeframe("1D", "Bias TF", group="② Bias Timeframes")
biasTF      = useCustomTF ? customTF : timeframe.period

// ───── ③ Bias Logic ─────
assetBiasMode = input.string(
    "LTF Only",
    "Asset Bias Validation", 
    options=["LTF Only", "LTF + HTF"],
    group="③ Bias Logic"
)

biasMode = input.string(
    "All 3",
    "Triad Bias Rule",
    options=["Current Asset", "Majority", "All 3"],
    group="③ Bias Logic"
)

// ───── ④ Visual Output ─────
tableMode = input.string(
    "Full",
    "Bias Table Mode",
    options=["Full", "Compact"],
    group="④ Visual Output"
)

showDOL = input.bool(true, "Show DOL", group="④ Visual Output")

// ───── ⑤ Color Customization ─────
bullColor    = input.color(color.new(#4caf50, 0), "Bullish Color", group="⑤ Color Customization")
bearColor    = input.color(color.new(#e04f5f, 0), "Bearish Color", group="⑤ Color Customization")
neutralColor = input.color(color.new(color.gray, 65), "Neutral Color", group="⑤ Color Customization")

// ───── ⑥ DOL Styling ─────
dolLineColor = input.color(color.new(#b8b8b8, 0), "DOL Line", group="⑥ DOL Styling")
dolTextColor = input.color(color.new(#b8b8b8, 0), "DOL Text", group="⑥ DOL Styling")

// ─────────────────────────────────────────────────────────────
// SYMBOL HELPERS
// ─────────────────────────────────────────────────────────────
displayBias(b) =>
    b == "bull" ? "BULL" :
     b == "bear" ? "BEAR" :
     "—"

biasColor(b) =>
    b == "bull" ? bullColor :
     b == "bear" ? bearColor :
     neutralColor


getSymbolOnly(sym) =>
    colonPos = str.pos(sym, ":")
    result = colonPos >= 0 ? str.substring(sym, colonPos + 1, str.length(sym)) : sym
    result := str.replace_all(result, "1!", "")
    result := str.replace_all(result, "USD", "")
    result := str.replace_all(result, ".USD", "")
    result := str.replace_all(result, "PERP", "")
    result := str.replace_all(result, "_", "")
    result

// ─────────────────────────────────────────────────────────────
// AUTO TRIAD
// ─────────────────────────────────────────────────────────────
get_auto_triad() =>
    t = str.upper(getSymbolOnly(syminfo.ticker))
    a1 = "CME_MINI:NQ1!"
    a2 = "CME_MINI:ES1!"
    a3 = "CBOT_MINI:YM1!"

    if t == "RTY"
        a3 := "CME_MINI:RTY1!"
    else if t == "NQ" or t == "ES" or t == "YM"
        a1 := "CME_MINI:NQ1!"
        a2 := "CME_MINI:ES1!"
        a3 := "CBOT_MINI:YM1!"
    else if t == "MNQ" or t == "MES" or t == "MYM"
        a1 := "CME_MINI:MNQ1!"
        a2 := "CME_MINI:MES1!"
        a3 := "CBOT_MINI:MYM1!"
    else if t == "BTC" or t == "ETH"
        a1 := "KRAKEN:BTCUSD"
        a2 := "KRAKEN:ETHUSD"
        a3 := "CAPITALCOM:DXY"
    else if t == "EUR" or t == "GBP"
        a1 := "FX:EURUSD"
        a2 := "FX:GBPUSD"
        a3 := "CAPITALCOM:DXY"

    [a1, a2, a3]

[aSym1, aSym2, aSym3] = get_auto_triad()
sym1 := use_auto_triad ? aSym1 : sym1
sym2 := use_auto_triad ? aSym2 : sym2
sym3 := use_auto_triad ? aSym3 : sym3

// ─────────────────────────────────────────────────────────────
// HTF MAPPING
// ─────────────────────────────────────────────────────────────
f_htf(tf) =>
    tf == "1"   ? "5"   :
     tf == "5"   ? "15"  :
     tf == "15"  ? "60"  :
     tf == "60"  ? "240" :
     tf == "240" ? "1D"  :
     tf == "1D"  ? "1W"  :
     tf == "1W"  ? "1M"  :
     tf == "1M"  ? "3M"  :
     tf

htfTF = f_htf(biasTF)

[h1, c1, l1] = request.security(sym1, biasTF, [high, close, low])
[h2, c2, l2] = request.security(sym2, biasTF, [high, close, low])
[h3, c3, l3] = request.security(sym3, biasTF, [high, close, low])
[h4, c4, l4] = request.security(sym1, htfTF, [high, close, low])
[h5, c5, l5] = request.security(sym2, htfTF, [high, close, low])
[h6, c6, l6] = request.security(sym3, htfTF, [high, close, low])

f_bias(float h, float c, float l) =>
    bullSweep = l[1] < l[2] and c[1] > l[2]
    bearSweep = h[1] > h[2] and c[1] < h[2]
    bullClose = c[1] > h[2]
    bearClose = c[1] < l[2]

    string b = "none"
    if bullSweep or bullClose
        b := "bull"
    else if bearSweep or bearClose
        b := "bear"
    b


var bias1 = "none"
var bias2 = "none"
var bias3 = "none"
var bias4 = "none"
var bias5 = "none"
var bias6 = "none"

var asset_bias1 = "none"
var asset_bias2 = "none"
var asset_bias3 = "none"

var triadBias = "none"

bullSweep1 = l1[1] < l1[2] and c1[1] > l1[2]
bearSweep1 = h1[1] > h1[2] and c1[1] < h1[2]
bullClose1 = c1[1] > h1[2]
bearClose1 = c1[1] < l1[2]

if bullSweep1 or bullClose1
    bias1 := "bull"
else if bearSweep1 or bearClose1
    bias1 := "bear"

bullSweep2 = l2[1] < l2[2] and c2[1] > l2[2]
bearSweep2 = h2[1] > h2[2] and c2[1] < h2[2]
bullClose2 = c2[1] > h2[2]
bearClose2 = c2[1] < l2[2]

if bullSweep2 or bullClose2
    bias2 := "bull"
else if bearSweep2 or bearClose2
    bias2 := "bear"

bullSweep3 = l3[1] < l3[2] and c3[1] > l3[2]
bearSweep3 = h3[1] > h3[2] and c3[1] < h3[2]
bullClose3 = c3[1] > h3[2]
bearClose3 = c3[1] < l3[2]

if bullSweep3 or bullClose3
    bias3 := "bull"
else if bearSweep3 or bearClose3
    bias3 := "bear"

bullSweep4 = l4[1] < l4[2] and c4[1] > l4[2]
bearSweep4 = h4[1] > h4[2] and c4[1] < h4[2]
bullClose4 = c4[1] > h4[2]
bearClose4 = c4[1] < l4[2]

if bullSweep4 or bullClose4
    bias4 := "bull"
else if bearSweep4 or bearClose4
    bias4 := "bear"

bullSweep5 = l5[1] < l5[2] and c5[1] > l5[2]
bearSweep5 = h5[1] > h5[2] and c5[1] < h5[2]
bullClose5 = c5[1] > h5[2]
bearClose5 = c5[1] < l5[2]

if bullSweep5 or bullClose5
    bias5 := "bull"
else if bearSweep5 or bearClose5
    bias5 := "bear"

bullSweep6 = l6[1] < l6[2] and c6[1] > l6[2]
bearSweep6 = h6[1] > h6[2] and c6[1] < h6[2]
bullClose6 = c6[1] > h6[2]
bearClose6 = c6[1] < l6[2]

if bullSweep6 or bullClose6
    bias6 := "bull"
else if bearSweep6 or bearClose6
    bias6 := "bear"


f_bias1 = bias1// f_bias(h1,c1,l1)
f_bias2 = bias2// f_bias(h2,c2,l2)
f_bias3 = bias3// f_bias(h3,c3,l3)
f_bias4 = bias4// f_bias(h4,c4,l4)
f_bias5 = bias5// f_bias(h5,c5,l5)
f_bias6 = bias6// f_bias(h6,c6,l6)

if f_bias1 != "none"
    bias1 := f_bias1
if f_bias2 != "none"
    bias2 := f_bias2
if f_bias3 != "none"
    bias3 := f_bias3
if f_bias4 != "none"
    bias4 := f_bias4
if f_bias5 != "none"
    bias5 := f_bias5
if f_bias6 != "none"
    bias6 := f_bias6

asset_bias1 := assetBiasMode == "LTF Only" ? bias1 : bias1 == bias4 ? bias1 : "none"
asset_bias2 := assetBiasMode == "LTF Only" ? bias2 : bias2 == bias5 ? bias2 : "none"
asset_bias3 := assetBiasMode == "LTF Only" ? bias3 : bias3 == bias6 ? bias3 : "none"

bullCount = (asset_bias1 == "bull" ? 1 : 0) +
             (asset_bias2 == "bull" ? 1 : 0) +
             (asset_bias3 == "bull" ? 1 : 0)

bearCount = (asset_bias1 == "bear" ? 1 : 0) +
             (asset_bias2 == "bear" ? 1 : 0) +
             (asset_bias3 == "bear" ? 1 : 0)

triadBias :=
     biasMode == "Current Asset" ? asset_bias1 :
     biasMode == "All 3" ?
         asset_bias1 == asset_bias2 and asset_bias1 == asset_bias3 ? asset_bias1 : "none" :
     biasMode == "Majority" ?
         bullCount >= 2 ? "bull" :
         bearCount >= 2 ? "bear" :
         "none" :
     "none"

// ───── TABLE (ROWS INCREASED TO 5) ─────
newBiasTfCandle = ta.change(time(biasTF)) != 0

var table t = table.new(position.top_center, 4, 5, frame_color=color.new(color.gray, 70))

bgHeader = color.new(color.black, 75)
bgCell   = color.new(color.black, 85)
txtMain  = color.white

table.clear(t, 0, 0, 0, 0)   

if tableMode == "Full" 
    table.cell(t, 0, 0, "TF", bgcolor=bgHeader, text_color=txtMain, text_font_family=font.family_monospace)

// ───── FULL MODE ─────
if tableMode == "Full" 
    if newBiasTfCandle and timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(biasTF)
        table.cell(t, 0, 0, "TF", bgcolor=bgHeader, text_color=txtMain, text_font_family=font.family_monospace)
        table.cell(t, 1, 0, getSymbolOnly(sym1), bgcolor=bgHeader, text_color=txtMain, text_font_family=font.family_monospace)
        table.cell(t, 2, 0, getSymbolOnly(sym2), bgcolor=bgHeader, text_color=txtMain, text_font_family=font.family_monospace)
        table.cell(t, 3, 0, getSymbolOnly(sym3), bgcolor=bgHeader, text_color=txtMain, text_font_family=font.family_monospace)

        table.cell(t, 0, 1, biasTF, bgcolor=bgCell, text_color=txtMain, text_font_family=font.family_monospace)
        table.cell(t, 1, 1, displayBias(bias1), bgcolor=bgCell, text_color=biasColor(bias1), text_font_family=font.family_monospace)
        table.cell(t, 2, 1, displayBias(bias2), bgcolor=bgCell, text_color=biasColor(bias2), text_font_family=font.family_monospace)
        table.cell(t, 3, 1, displayBias(bias3), bgcolor=bgCell, text_color=biasColor(bias3), text_font_family=font.family_monospace)

        table.cell(t, 0, 2, htfTF, bgcolor=bgCell, text_color=txtMain, text_font_family=font.family_monospace)
        table.cell(t, 1, 2, displayBias(bias4), bgcolor=bgCell, text_color=biasColor(bias4), text_font_family=font.family_monospace)
        table.cell(t, 2, 2, displayBias(bias5), bgcolor=bgCell, text_color=biasColor(bias5), text_font_family=font.family_monospace)
        table.cell(t, 3, 2, displayBias(bias6), bgcolor=bgCell, text_color=biasColor(bias6), text_font_family=font.family_monospace)

        table.cell(t, 0, 3, "TRIAD", bgcolor=bgCell, text_color=txtMain, text_font_family=font.family_monospace)
        table.cell(t, 1, 3, displayBias(triadBias), bgcolor=bgCell, text_color=biasColor(triadBias), text_font_family=font.family_monospace)

// ───── COMPACT MODE ─────
else 
    if newBiasTfCandle and timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(biasTF)
        table.cell(t, 0, 0, "TF", bgcolor=bgHeader, text_color=txtMain, text_font_family=font.family_monospace)
        table.cell(t, 1, 0, getSymbolOnly(sym1), text_color=biasColor(asset_bias1), text_font_family=font.family_monospace)
        table.cell(t, 2, 0, getSymbolOnly(sym2), text_color=biasColor(asset_bias2), text_font_family=font.family_monospace)
        table.cell(t, 3, 0, getSymbolOnly(sym3), text_color=biasColor(asset_bias3), text_font_family=font.family_monospace)

// ───── ACCURACY LOGIC (UNCHANGED) ─────
[pch1, ch1, pcl1, cl1] = request.security("", biasTF, [high[1], high, low[1], low])

var int total = 0
var int right = 0

if biasTF == timeframe.period
    if triadBias != "none"
        total += 1
    if triadBias == "bull" and ch1 > pch1 or triadBias == "bear" and cl1 < pcl1
        right += 1

    accuracy = total > 0 ? (right * 100.0) / total : na
    accuracyTxt = na(accuracy) ? "—" : str.tostring(accuracy, "#.##") + "%"

    // ───── ACCURACY ROW (FULL MODE ONLY) ─────
    if tableMode == "Full"
        if newBiasTfCandle and timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(biasTF)
            table.cell(t, 0, 0, "TF", bgcolor=bgHeader, text_color=txtMain, text_font_family=font.family_monospace)
            table.cell(t, 2, 3, "ACC", bgcolor=bgCell, text_color=txtMain, text_font_family=font.family_monospace)
            table.cell(t, 3, 3, accuracyTxt, bgcolor=bgCell, text_color=txtMain, text_font_family=font.family_monospace)

else 
    if newBiasTfCandle and timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(biasTF)
        table.cell(t, 0, 0, "TF", bgcolor=bgHeader, text_color=txtMain, text_font_family=font.family_monospace)
        table.cell(t, 0, 3, "", bgcolor=bgCell, text_color=txtMain, text_font_family=font.family_monospace)
        table.cell(t, 1, 3, "TRIAD", bgcolor=bgCell, text_color=txtMain, text_font_family=font.family_monospace)
        table.cell(t, 2, 3, displayBias(triadBias), bgcolor=bgCell, text_color=biasColor(triadBias), text_font_family=font.family_monospace)
        table.cell(t, 3, 3, "", bgcolor=bgCell, text_color=txtMain, text_font_family=font.family_monospace)

var float ch = na 
var float cl = na 
var float pch = na 
var float pcl = na 

var int ch_idx = na 
var int cl_idx = na 
var int pch_idx = na 
var int pcl_idx = na 

var line dol_line = na
var label dol_label = na

if biasTF != timeframe.period
    if newBiasTfCandle // new htf candle
        pch := ch
        pcl := cl
        pch_idx := ch_idx
        pcl_idx := cl_idx

        ch_idx := bar_index
        cl_idx := bar_index
        ch := high
        cl := low

        line.delete(dol_line)
        label.delete(dol_label)
        if triadBias == "bull"
            dol_line := line.new(pch_idx, pch, bar_index, pch, xloc.bar_index, extend.none, dolLineColor)
            dol_label := label.new(bar_index-2, pch, "DOL", style=label.style_label_left, textcolor=dolTextColor, color=color.new(color.black, 100), text_font_family=font.family_monospace)
        if triadBias == "bear"
            dol_line := line.new(pcl_idx, pcl, bar_index, pcl, xloc.bar_index, extend.none, dolLineColor)
            dol_label := label.new(bar_index-2, pcl, "DOL", style=label.style_label_left, textcolor=dolTextColor, color=color.new(color.black, 100), text_font_family=font.family_monospace)



    else 
        if high > ch
            ch := high
            ch_idx := bar_index
        if low < cl
            cl := low
            cl_idx := bar_index

        if triadBias == "bull" and ch < pch
            line.set_x2(dol_line, bar_index)
            label.set_x(dol_label, bar_index)
            label.set_style(dol_label, label.style_label_left)
        else
            label.set_x(dol_label, line.get_x2(dol_line)-2) 
            label.set_style(dol_label, label.style_label_down)

        if triadBias == "bear" and cl > pcl
            line.set_x2(dol_line, bar_index)
            label.set_x(dol_label, bar_index)
            label.set_style(dol_label, label.style_label_left)
        else
            label.set_x(dol_label, line.get_x2(dol_line)-2) 
            label.set_style(dol_label, label.style_label_up)
````
