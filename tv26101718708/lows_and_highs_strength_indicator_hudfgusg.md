# Lows and highs strength indicator

- url: https://www.tradingview.com/script/huDFGusG-Lows-and-highs-strength-indicator/
- type: indicator
- pine_id: PUB;a1bcc1d7afe84f8087bfc61ef1c60504
- version: 1.0

## Description

[b]Lows and highs strength indicator[/b] marks the two levels that matter most to the current market structure — the swing high sitting above price and the swing low sitting beneath it — and then answers the question most level-drawing tools leave open: [i]which one of these two is going to break, and which one is going to hold?[/i]

Every level on your chart is not equal. Some are defended and will reject price. Others are simply liquidity waiting to be collected. This indicator labels each of its two levels as either [b]strong[/b] (defended — treat it as a barrier) or [b]weak[/b] (undefended — treat it as a target), and updates those labels automatically as market structure shifts.

Two lines, two labels, one setting. Works on any market and any timeframe.


[b]THE CORE IDEA[/b]

A [b]strong high[/b] is a high that price tried to reach and failed to take out. Because it was never breached, the buy-side liquidity resting above it is still sitting there untouched, and the level has proven it can push price away. It behaves like genuine resistance.

A [b]weak high[/b] is the opposite. Structure is already trending upward into it, so rather than defending itself it is far more likely to be run through. It is not resistance — it is a magnet. Price is being drawn toward the liquidity above it.

The same logic applies in reverse to lows. A [b]strong low[/b] has held and represents real support; a [b]weak low[/b] is a downside liquidity target that the market is expected to reach for.

The crucial part is that [i]the two labels are always opposite each other[/i]. You will never see a strong high and a strong low at the same time. Market structure can only lean one way:

  [b]Strong high above + weak low below[/b]  →  structure is bearish. The high is defended, the low is the target.
  [b]Weak high above + strong low below[/b]  →  structure is bullish. The low is defended, the high is the target.

That single pairing tells you the directional bias, where price is being pulled, and where it is likely to be rejected — all from two lines.


[b]HOW TO USE IT WHEN TRADING[/b]

[b]1. As a directional bias filter.[/b]
Before taking any setup, glance at which side is strong. If the high is strong and the low is weak, the path of least resistance is down. Longs into a strong high are fighting a defended level with an untouched pool of liquidity above it. This alone filters out a large share of low-quality counter-structure entries.

[b]2. As a target.[/b]
The weak level is where the market is most likely headed, because that is where the unclaimed liquidity sits. In bearish structure, the weak low is a natural take-profit reference for shorts. In bullish structure, the weak high serves the same purpose for longs. Trading [i]toward[/i] the weak side and [i]away[/i] from the strong side is the indicator's most direct application.

[b]3. As invalidation and stop placement.[/b]
The strong level is the structural line in the sand. If price closes decisively beyond it, the premise of your trade is gone — that break is exactly what flips the bias and relabels both levels. Placing stops beyond the strong level means you are stopped out only when the structure genuinely changes, rather than on ordinary noise.

[b]4. As a reversal zone.[/b]
Approaches into a strong level are where rejections tend to occur. Combined with your own entry trigger — an engulfing candle, a lower-timeframe structure shift, a divergence — a strong level gives you a high-quality location to look for a turn, with clearly defined invalidation just beyond it.

[b]5. As a liquidity sweep watch.[/b]
Pay attention when price wicks just past a strong level and immediately closes back inside. That is often a stop run rather than a real break: the level collected the liquidity above (or below) it and rejected. This indicator deliberately ignores wicks — only a decisive [i]close[/i] through the level counts as a structural break.

[b]Example read.[/b] On the Bitcoin daily chart, structure is bearish: the indicator shows a strong high at 82,791 and a weak low at 56,018. You know three things immediately: the bias is down, the weak low is the level price is reaching for, and the strong high is where the bearish premise would be proven wrong. A short taken on a rally into the strong high has its target, its invalidation, and its directional logic all defined by two lines.

[b]Hover either label[/b] for a full plain-language explanation of why that level currently reads strong or weak, and exactly what would flip it to the other state.


[b]HOW IT WORKS[/b]

The indicator runs a four-stage pipeline on every bar.

[b]1. Swing detection.[/b]
A swing high is confirmed when a bar's high has [i]Swing length[/i] bars with lower highs on both sides of it; a swing low is the mirror image. This symmetric test means a swing point is only recognised once enough bars have passed to prove it genuinely was the extreme — no forward-looking data is used.

[b]2. Level anchoring.[/b]
When a new swing point is confirmed, it becomes the active swing high or swing low, and the corresponding line re-anchors to it.

[b]3. Trailing extremes.[/b]
Between swing points, each line ratchets outward with price — the upper line tracks the highest high of the current swing, the lower line the lowest low. This keeps both levels pinned to the true extremes of the live swing rather than to a stale historical price.

[b]4. Break of structure.[/b]
When a candle [i]closes[/i] beyond the active swing high, structure flips bullish; a close beyond the swing low flips it bearish. This bias drives the strong/weak labelling. Each swing level is consumed the moment it breaks, so a single level can only flip the bias once. And because the test is a plain closing test rather than a crossing test, the rare case where a swing point is confirmed while price already trades beyond it is registered immediately instead of being missed.

Closes are used rather than wicks deliberately — a wick through a level is a liquidity sweep, not a structural break, and treating the two the same is what causes most false structure signals.

[b]No repainting.[/b] Every calculation uses confirmed historical data with no lookahead. The lines extend in real time as the current candle makes new extremes, which is expected live behaviour, but past structure is never rewritten.


[b]SETTINGS[/b]

[b]Swing length[/b] (default 50) — how many bars are required on each side of a candidate swing point before it is confirmed. This is the one setting that meaningfully changes the indicator's character:

  [b]Lower (10–25)[/b] — faster, more reactive levels that track shorter swings. Suited to intraday and scalping, at the cost of more frequent bias flips.
  [b]Default (50)[/b] — balanced structural levels. A solid starting point on most markets and timeframes.
  [b]Higher (75–150)[/b] — only major structural turning points register. Suited to swing and position trading, where you want the levels to stay put.

[b]High color[/b] and [b]Low color[/b] — the two line and label colours, red and green by default.


[b]THINGS TO BE AWARE OF[/b]

[b]The levels lag, by design.[/b] A swing point cannot be confirmed until enough bars have passed to prove nothing exceeded it. That delay is what makes the level trustworthy rather than a guess, but it does mean this is a tool for structural context and bias, not for precise entry timing. Pair it with your own entry trigger.

[b]On very short chart histories both levels may read weak.[/b] Until the first break of structure occurs there is no bias to judge them against, and the labels default to weak. Hovering a label will tell you when this is the case. It resolves as soon as the first structural break happens.

[b]It is a context tool, not a complete system.[/b] It tells you which direction structure favours and where the liquidity sits. It does not tell you when to click the button. Use it to frame your bias, choose your targets, and place your invalidation — then let your own entry method handle the timing.

## Source Code

````pine
//@version=6
indicator('Lows and highs strength indicator', 'Lows and highs strength', overlay = true, max_lines_count = 2, max_labels_count = 2)

// ── Inputs ───────────────────────────────────────────────────────────────────
lenInput     = input.int(50, 'Swing length', minval = 5,
     tooltip = 'Bars required on each side of a candidate swing point before it is confirmed. Lower = faster, noisier levels; higher = only major structure.')
hiColorInput = input.color(#F23645, 'High color')
loColorInput = input.color(#089981, 'Low color')

// ── Structure state ──────────────────────────────────────────────────────────
// bias: +1 after a bullish break of structure, -1 after a bearish one,
// 0 until the first break happens on this chart.
var int   bias    = 0
// Last confirmed swing levels that price has not yet closed through. A level
// is consumed (set to na) the moment it breaks, so it can only fire once.
var float bosHigh = na
var float bosLow  = na
// Extremes of the running swing - the prices the two lines sit on, with the
// time of the bar that set each extreme.
var float topPrice = high
var int   topTime  = time
var float botPrice = low
var int   botTime  = time

// ── Swing detection ──────────────────────────────────────────────────────────
// Symmetric confirmation: a swing high needs lenInput bars with lower highs on
// BOTH sides of it, so it is recognised lenInput bars after it printed.
float pivotHigh = ta.pivothigh(lenInput, lenInput)
float pivotLow  = ta.pivotlow(lenInput, lenInput)

if not na(pivotHigh)
    bosHigh  := pivotHigh
    topPrice := pivotHigh
    topTime  := time[lenInput]

if not na(pivotLow)
    bosLow   := pivotLow
    botPrice := pivotLow
    botTime  := time[lenInput]

// Ratchet each line out to any fresh extreme of the live swing.
if high > topPrice
    topPrice := high
    topTime  := time
if low < botPrice
    botPrice := low
    botTime  := time

// ── Break of structure ───────────────────────────────────────────────────────
// Closing basis on purpose: a wick through a level is a liquidity sweep, not a
// structural break. Testing the plain close (rather than a crossover) also
// catches the case where a swing point confirms while price already trades
// beyond it - the break registers immediately instead of never.
if not na(bosHigh) and close > bosHigh
    bias    := 1
    bosHigh := na
if not na(bosLow) and close < bosLow
    bias    := -1
    bosLow  := na

// ── Hover text ───────────────────────────────────────────────────────────────
// Explains why each level currently reads strong or weak, and what flips it.
highTooltip() =>
    head   = str.tostring(topPrice, format.mintick) + '\n\n'
    footer = '\n\nLevel = highest high of the current swing (Swing length ' + str.tostring(lenInput) + ').'

    if bias == -1
        'Strong high · ' + head +
         'Structure is bearish - the most recent break of structure was a close below the swing low, not above this high.\n\n' +
         'Price has not managed to close above this level, so the buy-side liquidity resting above it is still untapped and the high has defended itself. Read it as genuine resistance rather than a target: rallies into it are more likely to be rejected than to break through.\n\n' +
         'Becomes a weak high as soon as a candle closes above the swing high and flips structure bullish.' + footer
    else if bias == 1
        'Weak high · ' + head +
         'Structure is bullish - the most recent break of structure was a close above the swing high.\n\n' +
         'Trend is already pushing toward this level, so it is more likely to be run through than to hold. Read it as a liquidity target price is being drawn toward, not as resistance to fade.\n\n' +
         'Becomes a strong high as soon as a candle closes below the swing low and flips structure bearish.' + footer
    else
        'Weak high · ' + head +
         'No break of structure has happened yet on this chart, so there is no trend bias to judge this high against. The label defaults to weak until the first close through either swing level.' + footer

lowTooltip() =>
    head   = str.tostring(botPrice, format.mintick) + '\n\n'
    footer = '\n\nLevel = lowest low of the current swing (Swing length ' + str.tostring(lenInput) + ').'

    if bias == 1
        'Strong low · ' + head +
         'Structure is bullish - the most recent break of structure was a close above the swing high, not below this low.\n\n' +
         'Price has not managed to close below this level, so the sell-side liquidity resting below it is still untapped and the low has defended itself. Read it as genuine support rather than a target: dips into it are more likely to be bought than to break through.\n\n' +
         'Becomes a weak low as soon as a candle closes below the swing low and flips structure bearish.' + footer
    else if bias == -1
        'Weak low · ' + head +
         'Structure is bearish - the most recent break of structure was a close below the swing low.\n\n' +
         'Trend is already pushing toward this level, so it is more likely to be run through than to hold. Read it as a liquidity target price is being drawn toward, not as support to fade.\n\n' +
         'Becomes a strong low as soon as a candle closes above the swing high and flips structure bullish.' + footer
    else
        'Weak low · ' + head +
         'No break of structure has happened yet on this chart, so there is no trend bias to judge this low against. The label defaults to weak until the first close through either swing level.' + footer

// ── Drawing ──────────────────────────────────────────────────────────────────
// Only the last bar needs the drawings; historical bars never show them.
if barstate.islast
    var line  hiLine  = line.new(na, na, na, na, xloc = xloc.bar_time, color = hiColorInput)
    var line  loLine  = line.new(na, na, na, na, xloc = xloc.bar_time, color = loColorInput)
    var label hiLabel = label.new(na, na, xloc = xloc.bar_time, style = label.style_label_lower_right, color = color(na), textcolor = hiColorInput, size = size.tiny)
    var label loLabel = label.new(na, na, xloc = xloc.bar_time, style = label.style_label_upper_right, color = color(na), textcolor = loColorInput, size = size.tiny)

    labelTime = time + 20 * (time - time[1])

    hiLine.set_first_point(  chart.point.new(topTime, na, topPrice))
    hiLine.set_second_point( chart.point.new(labelTime, na, topPrice))
    hiLabel.set_point(       chart.point.new(labelTime, na, topPrice))
    hiLabel.set_text(        bias == -1 ? 'Strong high' : 'Weak high')
    hiLabel.set_tooltip(     highTooltip())

    loLine.set_first_point(  chart.point.new(botTime, na, botPrice))
    loLine.set_second_point( chart.point.new(labelTime, na, botPrice))
    loLabel.set_point(       chart.point.new(labelTime, na, botPrice))
    loLabel.set_text(        bias == 1 ? 'Strong low' : 'Weak low')
    loLabel.set_tooltip(     lowTooltip())
````
