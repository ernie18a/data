# Price Acceptance Signature [Luis Edition]

- url: https://www.tradingview.com/script/sclqyK8S/
- type: indicator
- pine_id: PUB;1b5ad7fa454b4ab28e2fdc7c06e183d5
- version: 1.0

## Description

[b]Price Acceptance Signature (PAS)[/b]

[i]Price Acceptance Signature (PAS)[/i] is a technical indicator designed to measure something most common indicators ignore: not whether price moved, but whether the market truly [i]accepted[/i] that movement inside the candle. It focuses on candle structure, closing position, wick rejection, and short-term persistence to estimate the quality of price execution rather than simple direction or volatility.

[b]What problem it solves[/b]

Most indicators answer questions like:

Is the market overbought or oversold?

Is momentum rising or falling?

Is volatility expanding or contracting?

PAS solves a different problem. It tries to detect whether a move is [i]real and accepted[/i] or just a fast, inefficient excursion that gets rejected. This is useful because many false breakouts, weak continuation candles, and trapped moves look strong at first glance but leave behind poor internal structure. PAS helps you filter those situations.

[b]Core idea[/b]

Every candle has internal behavior:

The body shows how much of the range was actually held.

The wicks show rejection.

The close location shows whether the market finished near the high, middle, or low.

A sequence of candles shows whether acceptance is persistent or unstable.

PAS combines these elements into one score. A strong positive PAS suggests that buyers have not only pushed price upward, but that the candle closed in a way that confirms acceptance. A strong negative PAS suggests the same idea for sellers. A weak or near-zero PAS suggests indecision, rejection, or low-quality movement.

[b]Formula[/b]

A simple version of the indicator can be written as:

[i]PAS = signed acceptance score + persistence bonus[/i]

Where the acceptance score is built from:

[i]bodyScore = |close - open| / (high - low)[/i]

[i]closeScore = |close - mid| / (high - low) / 2[/i]

[i]cleanScore = 1 - ((upperWick + lowerWick) / (high - low))[/i]

Then:

[i]rawPAS = bodyScore × 0.45 + closeScore × 0.35 + cleanScore × 0.20[/i]

And finally:

If the candle closes bullish, PAS is positive.

If the candle closes bearish, PAS is negative.

A small persistence bonus can be added when the current candle agrees with the previous PAS direction.

[b]Why these parts matter[/b]

[b]1. Body score[/b]
This measures how much of the candle’s range was actually controlled by one side. A large body usually means stronger conviction.

[b]2. Close score[/b]
This measures where the candle ended relative to its range. A close near the high is stronger for buyers; a close near the low is stronger for sellers.

[b]3. Clean score[/b]
This measures wick efficiency. Long wicks often mean rejection or failed attempts. A “clean” candle with smaller wicks often signals more acceptance.

[b]4. Persistence bonus[/b]
One strong candle is not always enough. If the next candle supports the same acceptance direction, the signal becomes more meaningful.

[b]Practical interpretation[/b]

You can use PAS in several ways:

[b]Breakout confirmation[/b]: wait for a breakout candle to show strong positive PAS instead of trading every break.

[b]False breakout filter[/b]: if price breaks a level but PAS stays weak, the move may be fragile.

[b]Trend continuation[/b]: in an uptrend, strong positive PAS candles can confirm that the market is still accepting higher prices.

[b]Reversal suspicion[/b]: if price makes a new high but PAS weakens, that can suggest exhaustion or rejection.

[b]Entry timing[/b]: a strong PAS candle after compression can be a cleaner trigger than a plain momentum indicator.

[b]Example[/b]

Imagine three bullish candles:

Candle A has a huge wick, a small body, and closes in the middle of the range.

Candle B breaks higher, but the close is weak and the wick is still large.

Candle C closes near the high with a strong body and small wicks.

Traditional momentum tools may already look positive on Candle B. PAS would probably still treat Candle B as weak, then give more confidence only on Candle C. That is the key advantage: it distinguishes [i]appearance of movement[/i] from [i]quality of acceptance[/i].

[b]How to read the output[/b]

A practical reading could be:

[b]Above zero[/b]: bullish acceptance.

[b]Below zero[/b]: bearish acceptance.

[b]Near zero[/b]: no clear acceptance.

[b]High positive spike[/b]: strong bullish expansion with good structure.

[b]High negative spike[/b]: strong bearish expansion with good structure.

If you smooth the line, the indicator becomes easier to read visually. If you keep it raw, it becomes more reactive but noisier.

[b]Best market conditions[/b]

PAS works best when the market is:

Breaking out of compression.

Repricing after a clean impulsive move.

Testing a key level.

Transitioning from range to trend, or trend to exhaustion.

It is less useful in:

Extremely random chop.

Very low-liquidity periods.

Markets with tiny ranges and distorted candle structure.

[b]How it differs from classic indicators[/b]

This indicator is not trying to replace RSI, MACD, ATR, or moving averages. It answers a different question.

RSI measures relative strength over time.

MACD measures trend and momentum convergence.

ATR measures volatility.

PAS measures [i]candle acceptance quality[/i].

That makes it more structural and more “micro” in its logic.

[b]How to use it in practice[/b]

A solid workflow would be:

Mark your key levels.

Wait for price to approach a level or break out of compression.

Watch whether PAS confirms the move with a strong accepted candle.

Avoid entering just because price touched the level.

Use PAS as a quality filter, not as a standalone prediction machine.

In other words, PAS should help you ask:
[i]Is the market really accepting this price, or just visiting it?[/i]

[b]Trading philosophy behind it[/b]

The philosophy is simple: strong trading moves are not just about speed, but about [i]acceptance[/i]. A market that truly accepts a price level tends to leave cleaner candles, stronger closes, and less rejection. PAS tries to measure that directly.

[b]Final note[/b]

PAS is most powerful when combined with structure, not used alone. It becomes especially interesting if you pair it with:

session highs and lows,

range compression,

liquidity sweeps,

higher timeframe context.

That turns it from a simple oscillator into a real decision filter.

## Source Code

````pine
//@version=6
indicator("Price Acceptance Signature [Luis Edition]", shorttitle="PAS", overlay=false, precision=3, max_labels_count=500)

// ===== Inputs =====
lenSmooth  = input.int(5, "Smoothing", minval=1)
lenSignal  = input.int(13, "Signal Length", minval=2)
showBars   = input.bool(true, "Color Candles")
showGlow   = input.bool(true, "Glow Style")
showMarks  = input.bool(true, "Acceptance Marks")

// ===== Core candle structure =====
rng   = math.max(high - low, syminfo.mintick)
body  = math.abs(close - open)
mid   = (high + low) * 0.5
cPos  = math.abs(close - mid) / (rng * 0.5)
uWick = high - math.max(open, close)
lWick = math.min(open, close) - low
wickFrac = (uWick + lWick) / rng

bodyScore   = body / rng
closeScore  = math.min(cPos, 1.0)
cleanScore  = 1.0 - math.min(wickFrac, 1.0)

// ===== Signed acceptance =====
rawPAS = (bodyScore * 0.45 + closeScore * 0.35 + cleanScore * 0.20)
signedPAS = close >= open ? rawPAS : -rawPAS

// ===== Persistence bonus: reward continuation of accepted auction =====
persist = math.sign(signedPAS) == math.sign(signedPAS[1]) ? math.abs(signedPAS[1]) * 0.15 : 0.0
pas = signedPAS + persist * math.sign(signedPAS)

// ===== Smoothed line and adaptive baseline =====
pasSmooth = ta.ema(pas, lenSmooth)
signal    = ta.ema(pasSmooth, lenSignal)

// ===== Impulse zones =====
extreme = math.abs(pasSmooth) > math.abs(signal) and math.abs(pasSmooth) > 0.55
bullImp = pasSmooth > 0 and extreme
bearImp = pasSmooth < 0 and extreme

// ===== Aesthetic colors =====
bull  = color.rgb(0, 214, 143)
bear  = color.rgb(255, 82, 82)
neut  = color.rgb(160, 160, 175)
gold  = color.rgb(255, 196, 61)

pasColor =
     pasSmooth > signal and pasSmooth > 0 ? bull :
     pasSmooth < signal and pasSmooth < 0 ? bear :
     neut

// ===== Plots =====
hline(0, "Zero", color=color.new(neut, 0), linestyle=hline.style_solid)
p1 = plot(pasSmooth, "PAS", color=pasColor, linewidth=3)
p2 = plot(signal, "Signal", color=color.new(#ffffff, 65), linewidth=1)

plot(showGlow ? pasSmooth : na, "Glow", color=color.new(pasColor, 78), linewidth=8)

plotshape(showMarks and bullImp, title="Bull Acceptance", style=shape.circle, location=location.bottom, color=color.new(bull, 0), size=size.tiny)
plotshape(showMarks and bearImp, title="Bear Acceptance", style=shape.circle, location=location.top, color=color.new(bear, 0), size=size.tiny)

bgcolor(bullImp ? color.new(bull, 92) : bearImp ? color.new(bear, 92) : na)

barcolor(showBars ? (bullImp ? color.new(bull, 0) : bearImp ? color.new(bear, 0) : na) : na)

// ===== Optional info label on last bar =====
if barstate.islast
    label.new(
         bar_index, pasSmooth,
         "PAS " + str.tostring(pasSmooth, "#.###"),
         style=label.style_label_left,
         textcolor=color.white,
         color=color.new(pasColor, 70))
````
