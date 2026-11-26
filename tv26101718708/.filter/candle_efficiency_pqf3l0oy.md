# Candle Efficiency

- url: https://www.tradingview.com/script/PQf3L0oY/
- type: indicator
- pine_id: PUB;184f5fb2e97440f78456e5e937d28513
- version: 1.0

## Description

Candle Efficiency

Candle Efficiency reveals the true strength behind each candle by looking inside it. Two candles can have the exact same size and color yet tell completely different stories: one may have moved in a clean, decisive push, while the other crawled there through constant back-and-forth. The standard chart hides this, because a candle is only a summary of what happened inside it. This indicator breaks each candle down into its lower-timeframe components and measures how efficient the move really was, then highlights only the candles that moved with genuine conviction.

HOW IT WORKS

For every candle on your chart, the indicator pulls all the candles from a lower timeframe that make up that candle (it "dissects" the candle). It then compares two things:

- Net movement: the absolute distance from open to close of the candle (how far price actually advanced, in clean terms).
- Total internal movement: the sum of the open-to-close moves of every lower-timeframe candle inside it (how much price moved in total, including all the back-and-forth).

Efficiency = Net movement / Total internal movement

A value close to 1 means the move was direct and strong: price went almost in a straight line, with little wasted motion. A value close to 0 means the move was choppy and weak: lots of internal movement that cancelled itself out and barely advanced. A large green candle built from one clean push is efficient; a same-sized green candle built from hesitation, pauses and reversals is inefficient, even though both look identical on the chart.

AUTO-CALIBRATION

Two things adjust automatically so the indicator works on any market and any timeframe without manual tuning:

- Inner timeframe: chosen automatically to keep a constant ratio (around 16 lower-timeframe candles inside each chart candle). On a 4h chart it uses 15m, on 1h it uses 5m, on 15m it uses 1m, and so on. You can change the target ratio or set the inner timeframe manually if you prefer.
- Strength threshold: the indicator measures the recent average efficiency of the current asset and only highlights candles whose efficiency clearly exceeds that average (by default, 1.3 times the average). This means "strong" always adapts to what is normal for that specific asset and timeframe, instead of relying on a fixed value that would only fit one market.

WHAT YOU SEE

Only strong candles are colored: bright green for strong bullish candles, bright red for strong bearish ones. Every other candle (weak or average) stays neutral gray. At a glance you only see where there was real conviction behind the move, with no noise from the ordinary candles.

HOW TO USE IT

Basic reading: the bright candles mark moves made with genuine strength. A breakout, a trend leg or an impulse confirmed by a bright candle carries real conviction behind it; the same move shown as a gray candle is weak and far more suspect. It helps separate moves that have fuel from moves that are just drifting.

Reading the shift of control (advanced): because the indicator shows which side is moving with strength, it makes changes of control visible before price fully confirms them. Watch for this sequence at the end of a trend:

- In a downtrend: while sellers are in control, the strong candles are red. When the decline starts turning gray (red candles stop being strong), the trend is losing conviction even though price is still falling. If strong green candles then begin to appear on the bounces, control is shifting to buyers, and a reversal to the upside becomes likely.
- In an uptrend: the mirror image. Strong green candles dominate the rise, then the top turns gray (green candles lose their strength), and the appearance of strong red candles signals control passing to sellers and a likely reversal down.

The gray phase is the key early warning: it shows the trend running out of strength before the actual turn, which is information you cannot get from price alone. The arrival of a strong candle of the opposite color then confirms the change of control.

NOTES

The indicator relies on lower-timeframe data, so it needs the inner timeframe to be smaller than the chart timeframe. On assets without volume data it still works, since the efficiency calculation is based on price movement, not volume. Like any tool, it describes what has already happened (it is reactive, not predictive) and works best as a reading aid alongside your own structure and levels, not as a standalone signal.

## Source Code

````pine
//@version=6
indicator("Candle Efficiency", overlay=true)

// ─── CONCEPT ──────────────────────────────────────────────────────────────────
// Efficiency = |close - open| / sum of |close-open| of the inner (lower TF) candles
// High = clean, directional, strong move; Low = choppy, back-and-forth, weak move.
// Only candles whose efficiency clearly exceeds the asset's recent average are
// highlighted as strong. The inner timeframe is auto-selected to keep a constant ratio.

// ─── INPUTS ───────────────────────────────────────────────────────────────────
targetInner = input.int(16, "Target inner candles", minval=6, maxval=48, tooltip="How many lower-timeframe candles each candle should contain. The inner timeframe is chosen automatically to keep this ratio on any chart timeframe")
autoTF      = input.bool(true, "Auto-select inner timeframe", tooltip="ON: the inner timeframe adjusts automatically to the chart timeframe. OFF: uses the manual one below")
manualTF    = input.timeframe("15", "Manual inner timeframe (if auto OFF)")
calLen      = input.int(100, "Calibration period", minval=20, tooltip="Number of candles used to compute the reference average efficiency of the asset")
strongMult  = input.float(1.3, "Strong threshold (x average)", minval=1.05, step=0.05, group="Calibration", tooltip="A candle is highlighted as strong if its efficiency exceeds the average times this factor")

colStrongBull = input.color(#00e676, "Strong bullish", group="Colors")
colStrongBear = input.color(#ff1744, "Strong bearish", group="Colors")
colNeutral    = input.color(#555555, "Neutral (not strong)", group="Colors")

// ─── AUTO-SELECT INNER TIMEFRAME ──────────────────────────────────────────────
float chartMin  = timeframe.in_seconds(timeframe.period) / 60.0
float targetMin = chartMin / targetInner

selectTF(float mins) =>
    string tf = "1"
    if mins <= 1
        tf := "1"
    else if mins <= 2
        tf := "2"
    else if mins <= 3
        tf := "3"
    else if mins <= 5
        tf := "5"
    else if mins <= 10
        tf := "10"
    else if mins <= 15
        tf := "15"
    else if mins <= 30
        tf := "30"
    else if mins <= 45
        tf := "45"
    else if mins <= 60
        tf := "60"
    else if mins <= 120
        tf := "120"
    else if mins <= 180
        tf := "180"
    else if mins <= 240
        tf := "240"
    else
        tf := "D"
    tf

string innerTF = autoTF ? selectTF(targetMin) : manualTF

// ─── BREAK DOWN THE CANDLE ────────────────────────────────────────────────────
opensLTF  = request.security_lower_tf(syminfo.tickerid, innerTF, open)
closesLTF = request.security_lower_tf(syminfo.tickerid, innerTF, close)

// ─── EFFICIENCY ───────────────────────────────────────────────────────────────
float netMove = math.abs(close - open)
float totalMove = 0.0
int   nInner = array.size(closesLTF)
if nInner > 0
    for i = 0 to nInner - 1
        totalMove += math.abs(array.get(closesLTF, i) - array.get(opensLTF, i))
float efficiency = (nInner > 0 and totalMove > 0) ? netMove / totalMove : na

// ─── AUTO-CALIBRATED THRESHOLD ────────────────────────────────────────────────
var float effMA = na
float avgEff = ta.sma(efficiency, calLen)
effMA := na(avgEff) ? effMA : avgEff
float thStrong = na(effMA) ? na : effMA * strongMult

// ─── ONLY STRONG CANDLES ARE COLORED ──────────────────────────────────────────
bool isBull   = close >= open
bool isStrong = not na(efficiency) and not na(thStrong) and efficiency >= thStrong
color candleCol = isStrong ? (isBull ? colStrongBull : colStrongBear) : colNeutral

barcolor(candleCol)
plotcandle(open, high, low, close, "Candles", color=candleCol, wickcolor=candleCol, bordercolor=candleCol)
````
