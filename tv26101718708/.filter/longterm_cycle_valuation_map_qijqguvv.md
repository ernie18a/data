# Long-Term Cycle Valuation Map

- url: https://www.tradingview.com/script/qiJQguvV-Long-Term-Cycle-Valuation-Map/
- type: indicator
- pine_id: PUB;7f4a1b94fd134dac9654aee676a252a9
- version: 1.0

## Description

Long-Term Cycle Valuation Map is an educational indicator designed to visualize long-term crypto market valuation and cycle conditions.

The script does not generate buy or sell signals. It does not predict exact tops or bottoms. Its purpose is to help users observe whether the market is in a deeper reset, rebuild, neutral, late expansion, or exhaustion-risk environment.

The indicator combines several long-term market-regime components into one normalized Cycle Valuation Score.

[b]The model uses:[/b]

1. 365D Moving Average Multiple

This measures price relative to its 365-day moving average. It helps visualize whether price is extended above or depressed below a long-term mean.

2. RSI(100) on 2D

This measures slower momentum conditions using a long RSI setting on a 2-day timeframe.

3. Long-Term Bollinger Bandwidth

This measures long-term volatility compression and expansion using a 365-day Bollinger Bandwidth structure.

4. Market Attention Proxy

This is not Google Trends data.

It is a market-based activity proxy using volume, volatility, and range expansion. Its purpose is to estimate whether market activity is quiet, normal, elevated, or overheated from price and volume behavior.

[b]Customization:[/b]

Each component can be turned on or off.
Users can also adjust the relative strength of each component through percentage inputs.
The default public configuration is:

365D Moving Average Multiple: 30%
RSI(100) on 2D: 30%
Long-Term Bollinger Bandwidth: 30%
Market Attention Proxy: 10%

The weights do not need to add up to exactly 100. The script automatically normalizes the active components.
If a component is disabled, or if it does not have enough historical data yet, it is excluded from the active score.
The table shows how many components are active.

The final output is a normalized Cycle Valuation Score between 0 and 100.

[b]General interpretation:[/b]
Below 15:
Deep reset zone
15-90:
Broad cycle range. This can include rebuild, neutral, and late expansion conditions.
Above 90:
Exhaustion-risk zone

The score should not be used as a standalone trading system.
A low score does not mean price must immediately rise.
A high score does not mean price must immediately fall.
Markets can remain in the same regime for extended periods.

The script is intended for higher-timeframe market-structure analysis. It is best used on multi-day, weekly, and monthly charts.

On early historical bars, the score may use fewer available components until all long-term calculations have enough history. The table shows how many components are active.

This indicator combines common long-term market measures into a single normalized framework. Its usefulness comes from organizing valuation, momentum, volatility, and market-activity conditions into one cycle-regime score.

[i]Repainting:
The script does not use future data or lookahead logic.
Values on the currently open candle may update until that candle closes.
Limitations:
The script does not forecast future prices.
It does not guarantee cycle tops or bottoms.
It does not provide trade entries or exits.
It should not be used as a standalone trading decision tool.
Intended use:
Educational long-term market-structure and cycle-valuation analysis.[/i]

## Source Code

````pine
//@version=6
indicator("Long-Term Cycle Valuation Map", shorttitle="Crypto Cycle Score", overlay=false, max_labels_count=50)

//────────────────────────────────────────────────────────────────────
// Long-Term Cycle Valuation Map
//
// Open-source educational market-regime indicator.
// This script does not generate buy or sell signals.
// It is designed to visualize long-term valuation, momentum,
// volatility compression/expansion, and market attention conditions.
//
// On early historical bars, the score may use fewer available components
// until all long-term calculations have enough data.
//────────────────────────────────────────────────────────────────────

// Component toggles
groupComponents = "Components"

useMayer     = input.bool(true, "Use 365D Mayer Multiple", group=groupComponents)
useRsi       = input.bool(true, "Use RSI(100) on 2D", group=groupComponents)
useBbw       = input.bool(true, "Use Long-Term Bollinger Bandwidth", group=groupComponents)
useAttention = input.bool(true, "Use Market Attention Proxy", group=groupComponents)

// Component strength settings
groupWeights = "Component strength (%)"

mayerWeight = input.float(30.0, "Mayer Multiple strength", minval=0.0, maxval=100.0, step=5.0, group=groupWeights)
rsiWeight = input.float(30.0, "RSI Momentum strength", minval=0.0, maxval=100.0, step=5.0, group=groupWeights)
bbwWeight = input.float(30.0, "Bollinger Bandwidth strength", minval=0.0, maxval=100.0, step=5.0, group=groupWeights)
attentionWeight = input.float(10.0, "Market Attention Proxy strength", minval=0.0, maxval=100.0, step=5.0, group=groupWeights)

// Fixed parameters
rsiTf  = "2D"
rsiLen = 100

mayerTf  = "D"
mayerLen = 365

bbTf      = "D"
bbLen     = 365
bbMult    = 2.0
bbNormLen = 730

attentionTf = "D"
volumeLen   = 365
atrLen      = 14
atrAvgLen   = 365

rsiLowRef    = 35.0
rsiHighRef   = 85.0

mayerLowRef  = 0.60
mayerHighRef = 2.40

volumeLowRef  = 0.50
volumeHighRef = 3.00

rangeLowRef  = 0.50
rangeHighRef = 3.00

attentionVolumeWeight = 0.50
attentionBbwWeight    = 0.30
attentionRangeWeight  = 0.20

smoothLen = 5

// Utility functions
f_clamp(x, minValue, maxValue) =>
    math.max(minValue, math.min(maxValue, x))

f_linearScore(x, lowRef, highRef) =>
    denom = math.max(highRef - lowRef, 0.000001)
    f_clamp((x - lowRef) / denom * 100.0, 0.0, 100.0)

f_logScore(x, lowRef, highRef) =>
    safeX = math.max(x, 0.000001)
    safeLow = math.max(lowRef, 0.000001)
    safeHigh = math.max(highRef, safeLow + 0.000001)
    denom = math.max(math.log(safeHigh) - math.log(safeLow), 0.000001)
    f_clamp((math.log(safeX) - math.log(safeLow)) / denom * 100.0, 0.0, 100.0)

f_bbwRaw(_len, _mult) =>
    basis = ta.sma(close, _len)
    dev = _mult * ta.stdev(close, _len)
    basis != 0.0 ? ((basis + dev) - (basis - dev)) / basis : na

f_bbwScore(_len, _mult, _normLen) =>
    bw = f_bbwRaw(_len, _mult)
    bwLow = ta.lowest(bw, _normLen)
    bwHigh = ta.highest(bw, _normLen)
    denom = math.max(bwHigh - bwLow, 0.000001)
    not na(bw) and not na(bwLow) and not na(bwHigh) ? f_clamp((bw - bwLow) / denom * 100.0, 0.0, 100.0) : na

f_attentionScore(_volumeLen, _atrLen, _atrAvgLen, _bbLen, _bbMult, _bbNormLen, _volLow, _volHigh, _rangeLow, _rangeHigh, _volW, _bbwW, _rangeW) =>
    volAvg = ta.sma(volume, _volumeLen)
    volRatio = not na(volume) and not na(volAvg) and volAvg > 0.0 ? volume / volAvg : na
    volScore = not na(volRatio) ? f_logScore(volRatio, _volLow, _volHigh) : na

    bbwComponent = f_bbwScore(_bbLen, _bbMult, _bbNormLen)

    atrValue = ta.atr(_atrLen)
    atrAvg = ta.sma(atrValue, _atrAvgLen)
    atrRatio = not na(atrValue) and not na(atrAvg) and atrAvg > 0.0 ? atrValue / atrAvg : na
    rangeScore = not na(atrRatio) ? f_logScore(atrRatio, _rangeLow, _rangeHigh) : na

    volPart = not na(volScore) ? volScore * _volW : 0.0
    bbwPart = not na(bbwComponent) ? bbwComponent * _bbwW : 0.0
    rangePart = not na(rangeScore) ? rangeScore * _rangeW : 0.0

    activeWeight =
         (not na(volScore) ? _volW : 0.0) +
         (not na(bbwComponent) ? _bbwW : 0.0) +
         (not na(rangeScore) ? _rangeW : 0.0)

    activeWeight > 0.0 ? (volPart + bbwPart + rangePart) / activeWeight : na

f_regime(score) =>
    na(score) ? "Not enough data" :
     score < 15 ? "Deep reset" :
     score < 40 ? "Rebuild" :
     score < 70 ? "Neutral" :
     score < 90 ? "Late expansion" :
     "Exhaustion-risk"

f_scoreColor(score) =>
    na(score) ? color.gray :
     score < 15 ? color.rgb(0, 120, 80) :
     score < 40 ? color.rgb(45, 150, 90) :
     score < 70 ? color.rgb(150, 150, 150) :
     score < 90 ? color.rgb(220, 140, 40) :
     color.rgb(180, 45, 45)

// Fixed-timeframe components
rsiValue = request.security(
     syminfo.tickerid,
     rsiTf,
     ta.rsi(close, rsiLen),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

mayerMultiple = request.security(
     syminfo.tickerid,
     mayerTf,
     close / ta.sma(close, mayerLen),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

bbwValue = request.security(
     syminfo.tickerid,
     bbTf,
     f_bbwRaw(bbLen, bbMult),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

bbwScore = request.security(
     syminfo.tickerid,
     bbTf,
     f_bbwScore(bbLen, bbMult, bbNormLen),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

attentionScore = request.security(
     syminfo.tickerid,
     attentionTf,
     f_attentionScore(
          volumeLen,
          atrLen,
          atrAvgLen,
          bbLen,
          bbMult,
          bbNormLen,
          volumeLowRef,
          volumeHighRef,
          rangeLowRef,
          rangeHighRef,
          attentionVolumeWeight,
          attentionBbwWeight,
          attentionRangeWeight
     ),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

// Component scores
rsiScore = f_linearScore(rsiValue, rsiLowRef, rsiHighRef)
mayerScore = f_logScore(mayerMultiple, mayerLowRef, mayerHighRef)

// Composite score using enabled and available components
mayerPart = useMayer and not na(mayerScore) ? mayerScore * mayerWeight : 0.0
rsiPart = useRsi and not na(rsiScore) ? rsiScore * rsiWeight : 0.0
bbwPart = useBbw and not na(bbwScore) ? bbwScore * bbwWeight : 0.0
attentionPart = useAttention and not na(attentionScore) ? attentionScore * attentionWeight : 0.0

activeWeight =
     (useMayer and not na(mayerScore) ? mayerWeight : 0.0) +
     (useRsi and not na(rsiScore) ? rsiWeight : 0.0) +
     (useBbw and not na(bbwScore) ? bbwWeight : 0.0) +
     (useAttention and not na(attentionScore) ? attentionWeight : 0.0)

rawScore = activeWeight > 0.0 ? (mayerPart + rsiPart + bbwPart + attentionPart) / activeWeight : na

cycleScore = ta.ema(rawScore, smoothLen)

activeComponents =
     (useMayer and not na(mayerScore) ? 1 : 0) +
     (useRsi and not na(rsiScore) ? 1 : 0) +
     (useBbw and not na(bbwScore) ? 1 : 0) +
     (useAttention and not na(attentionScore) ? 1 : 0)

regime = f_regime(cycleScore)
scoreColor = f_scoreColor(cycleScore)

// Plot
plot(cycleScore, "Cycle Valuation Score", color=scoreColor, linewidth=2)

hline(100, "Maximum", color=color.new(color.gray, 85))
hline(90, "Exhaustion-risk", color=color.new(color.red, 35))
hline(15, "Deep reset", color=color.new(color.green, 35))
hline(0, "Minimum", color=color.new(color.gray, 85))

// Current status table
var table infoTable = table.new(position.top_right, 2, 7, border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "Cycle Score", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(infoTable, 1, 0, str.tostring(cycleScore, "#.0"), text_color=color.white, bgcolor=scoreColor, text_size=size.small)

    table.cell(infoTable, 0, 1, "Regime", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(infoTable, 1, 1, regime, text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)

    table.cell(infoTable, 0, 2, "Mayer", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(infoTable, 1, 2, useMayer ? str.tostring(mayerMultiple, "#.00") : "Off", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)

    table.cell(infoTable, 0, 3, "RSI 2D", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(infoTable, 1, 3, useRsi ? str.tostring(rsiValue, "#.0") : "Off", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)

    table.cell(infoTable, 0, 4, "BBW", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(infoTable, 1, 4, useBbw ? str.tostring(bbwValue * 100.0, "#.0") + "%" : "Off", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)

    table.cell(infoTable, 0, 5, "Attention", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(infoTable, 1, 5, useAttention ? str.tostring(attentionScore, "#.0") : "Off", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)

    table.cell(infoTable, 0, 6, "Components", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
    table.cell(infoTable, 1, 6, str.tostring(activeComponents) + "/4", text_color=color.white, bgcolor=color.new(color.black, 0), text_size=size.small)
````
