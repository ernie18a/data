# Market Structure: Impulses + Fibonnaci

- url: https://www.tradingview.com/script/Wd8g8R0L-Market-Structure-Impulses-Fibonnaci/
- type: indicator
- pine_id: PUB;18bed695ec424321b1d94fd7dd503eea
- version: 1.0

## Description

[b]Market Structure: Impulses + Fibonnaci[/b]
Reads complete impulses at two degrees, anchors Fibonacci to them automatically, validates each move with an intrabar volume profile and liquidity sweep detection, and fires pullback and counter-trend signals from a double MACD.


[b]WHAT IT DOES[/b]

A plain ZigZag treats every leg as a separate move, so a Fibonacci anchored to it jumps every time price breathes. This indicator groups legs into impulses: if the retracement from the extreme does not reach the threshold, the opposite leg is treated as an internal pullback and the impulse continues with the same origin. The Fib anchor stays put.

It runs two degrees at the same time:

[b]INTERNAL[/b] - the move you trade
• Retracement threshold: 0.382
• Also ends on: structure break
• Drawn as: solid box with label

[b]EXTERNAL[/b] - the context that rules
• Retracement threshold: 0.618
• Also ends on: depth only
• Drawn as: dashed grey outline

The structure rule is what stops the internal impulse from growing forever. In a bullish impulse, if a low takes out the previous low, the impulse ended there even if the percentage pullback was small. Without that rule, a stretch without deep corrections ends up anchored at the all-time high.

The extreme extends live while the current leg runs in its favour, so the Fib re-anchors itself. If price breaks the origin, that impulse is dead and the opposite one is born immediately, without waiting for a pivot to confirm.

The dotted gold line labelled 1 and 0 marks the exact two points where you would drop the Fib Retracement tool by hand.

While the recent swings are testing the same two levels rather than trending, a consolidation range box is drawn behind price. Each edge is the median of the last touches, so one wick cannot blow the box out, and the box disappears as soon as the swings stop respecting those levels.


[b]LIQUIDITY, SWEEPS AND BREAKS[/b]

A stop-loss is not an alarm, it is a market order waiting. The stop of a long is a sell order, the stop of a short is a buy order. Since everyone uses the same references, sell orders pile up under every swing low and buy orders pile up above every swing high.

That matters because size needs counterparty. To buy a lot you need someone selling a lot, otherwise your own order runs the price away from you. Guaranteed selling sits below the low. So highs and lows behave less like support and resistance and more like fuel depots.

When price crosses one of those levels there are two outcomes, and at first they look identical. That is why the indicator does not decide instantly: it waits for closes.

[b]SWEEP[/b]
• After crossing: closes back inside
• Meaning: the level was the destination
• Reading: exhaustion, reversal
• On the chart: SWEEP label

[b]BREAK[/b]
• After crossing: closes outside and holds
• Meaning: the level was the path
• Reading: real interest, continuation
• On the chart: no label, the level is consumed

Every confirmed pivot enters a watch list and moves through four states: untouched, pierced (the wick is out, the close is pending), swept, or broken. The "candles to close back" setting is the decision window between pierced and the two outcomes. Default is three candles.

Levels still untouched are drawn dotted and marked liq up or liq down. Orders are still sitting there, and price tends to go looking for them.


[b]VOLUME PROFILE AND ACCEPTANCE[/b]

The volume bars at the bottom of a chart are volume per time: how much traded in each candle. A profile is the same volume per price: how much traded at each level, regardless of when. It is the histogram turned ninety degrees.

• POC - the price where most volume traded. Acts as a magnet.
• Value area (VAH-VAL) - the band holding 70% of the volume.
• Fat zone - heavy trade, price slows down and reacts there.
• Thin zone - almost nobody traded, price crosses it fast.

The market is an auction looking for business. When price rises it is asking whether anyone trades up there. If volume trades at the new prices, the market accepts them and the move is a real repricing. If nobody trades and price returns, it was rejection: an excursion, not a change of price.

So the decisive figure is not how much volume there was, but where the POC ended up inside the impulse. The indicator gives it translated into a Fib number, the same scale as everything else: 0 is the extreme, 1 is the origin.

• POC at 0.20 - volume travelled with price. Acceptance, the pullback should hold.
• POC at 0.90 - volume stayed at the origin. No acceptance, the pullback eats the move.

The confluence worth watching: whether the POC line falls inside the shaded 0.618-0.786 zone. If it does, that zone has real support behind it. If the histogram is hollow right there, price crosses without slowing.

The profile is built from intrabar data. Each candle is split into roughly sixteen lower timeframe candles and each of those carries its own volume into its own narrow price band. The cheap alternative — spreading a candle's volume evenly between its high and its low — penalises wide candles and rewards narrow ones, so the base of an impulse concentrates its volume while the rally dilutes its own, dragging the POC towards the origin by construction. On a vertical move that is enough to invert the verdict. Where intrabar history is not available the indicator falls back to the candle itself, and the panel prints the source next to the POC.


[b]THE SIGNALS[/b]

Two MACDs drive them. The fast one runs on the chart timeframe and is the trigger. The slow one runs on a higher timeframe — four times the chart by default, read from its last closed bar — and is the permission. The slow MACD counts as bullish by its line above zero, by its line above its signal, or by both, whichever you pick.

[b]Trend (T)[/b] - a pullback inside the external impulse.
• The external impulse and the slow MACD must point the same way.
• Price must retrace into the band between the two impulse thresholds: deep enough to be a real pullback, not so deep that the external impulse is over. With the preset in charge that band is 0.382-0.618 on intraday.
• Price must have traded inside that band within the trigger window.
• The fast MACD must then be on the side of the trade.
• One signal per external impulse extreme: once it fires, that pullback is spent.

[b]Counter-trend (CT)[/b] - a sweep that fails.
• A pivot is swept: wick outside, close back inside.
• Optionally the fast MACD must diverge from the swept pivot — price takes the level out but the oscillator does not follow.
• That arms the setup for the trigger window. It dies if price pushes past the sweep wick.
• It fires when the fast MACD turns against the sweep and price closes back beyond the swept level.

Every signal carries its own levels. The stop of a trend signal sits beyond the extreme of the pullback, the stop of a counter-trend signal beyond the sweep wick, both with an ATR buffer. The target is a multiple of that risk, two R by default. Entry, stop and target are drawn as lines for the last signal, and the pullback band is shaded while a trend setup is possible.

Signals are evaluated on closed bars only. What the history shows is what the alert would have sent live.

With the webhook option on, every signal also calls alert() with a JSON payload carrying symbol, exchange, side, setup, timeframe, price, stop and target. Create the alert with the "Any alert() function call" condition and paste your webhook URL.


[b]THE PANEL[/b]

Three modes.

[b]Signals[/b] - the setup in words, six rows:

• Trend - the external impulse and the slow MACD, and whether they agree.
• Trigger - where the fast MACD is pointing right now.
• Setup - what is armed and what it is still waiting for, with the candles left on the trigger window.
• Last signal - which one fired and how long ago.
• Levels - the entry, stop and target of that signal.
• Quality - the acceptance verdict of the impulse the Fib is anchored to.

[b]Full[/b] - two data columns, INTERNAL and EXTERNAL, with every metric of both impulses. The header says which of the two the Fibonacci is anchored to.

• Direction - the way each degree is pointing. Both agreeing is a tailwind.
• Origin (fib 1) - where the impulse started. Lower Fib anchor.
• Extreme (fib 0) - the extreme reached. Upper Fib anchor.
• From - date of the origin, so you can replicate it by hand.
• Size / legs - how far it moved and how many legs were merged. Many legs means a mature impulse, closer to its end.
• Max retracement - the deepest correction from the extreme. Close to the threshold means the impulse is in danger.
• State - extending, pullback, or finished.
• Setting - the preset and the values actually in force.
• Extreme swept - whether the extreme was made by taking liquidity. If yes, distrust the whole impulse.
• Impulse POC - where it traded, in price and in Fib terms, with the data source that produced it.
• Verdict - the two above, crossed.

[b]Compact[/b] - four icons: EXT and INT direction arrows, a dot for price inside the Fib zone, and the verdict. Hovering any cell brings up the full detail.

The four verdicts:

• ACCEPTANCE - continuation. It neither swept nor lacked business. A pullback into the Fib makes sense with the trend.
• SWEPT - no acceptance. It went for the stops and nothing traded up there. A reversal is the likely outcome.
• Swept but with acceptance. It took liquidity and also built value. Often the good start, but ask for extra confirmation.
• No acceptance - weak. It swept nothing, but nothing traded at the new prices either.

The verdict is informational. It is computed on the last bar and does not feed the signals.


[b]HOW TO READ IT, STEP BY STEP[/b]

Everything you need is in the panel, read from top to bottom. Six questions, in this order.

[b]1. What is the context?[/b] The EXTERNAL degree. This is the larger move, the one that decides whether you are swimming with the current or against it.

[b]2. Which way is your move going?[/b] The INTERNAL degree. Both pointing the same way means the two degrees agree. If they disagree, whatever you are looking at is a pullback inside a bigger move running against it, which leaves less room before the larger degree takes over again.

[b]3. Did the move earn the right to continue?[/b] The Verdict row. ACCEPTANCE means the impulse actually traded at its new prices, so a retracement into the Fib is a with-trend read. SWEPT means the extreme was made by running stops and nothing traded up there, so the path back to the origin is more likely than further extension. The two mixed verdicts mean the evidence points both ways: wait for the next pivot rather than pick a side.

[b]4. Where is the retracement likely to hold?[/b] Compare the POC line against the shaded zone. POC inside the zone means that area has real volume behind it and price has a reason to react. A hollow histogram there means the opposite: price crosses thin zones quickly, and an order resting in the middle of one usually gets no reaction at all.

[b]5. What kills the read?[/b] The gold "impulse ends" line, which sits at the last internal pullback. If price closes through it, the impulse you were reading is finished and the panel will re-anchor. It is a structural level, not a round number, which is what makes it useful as a reference.

[b]6. Where could it go?[/b] The dotted liq up and liq down lines are pivots nobody has taken yet. Untaken liquidity attracts price, so they are the natural places for the next move to reach for.

[b]A worked example[/b]

The panel reads: EXTERNAL up, INTERNAL up, Verdict ACCEPTANCE, POC at fib 0.66, max retracement 41%.

Both degrees agree, the impulse built volume on its way up, and the POC sits inside the 0.618-0.786 zone. Price has already given back 41% of the move, so it is trading inside that zone right now, on volume that was actually traded there. The gold line below marks where the read stops being valid, and the nearest liq up line above is the first place price would reach for if it continues.

Now change two figures and nothing else: Verdict SWEPT, POC at fib 0.88. Same impulse, same size, same Fib levels drawn on the chart, but the high was made by running stops and all the volume stayed down at the origin. The shaded zone is still drawn, and it is worth nothing, because the move it measures was never accepted.

[b]The rule underneath all of it[/b]

Liquidity taken at the START of a move is fuel: the stops that got run financed the move and price left them behind. Liquidity taken at the END was the purpose: the move existed to reach them, and once they are taken there is no reason left to keep going.


[b]SETTINGS[/b]

There is one setting that matters. Pick the preset that matches your timeframe and leave everything else alone.

• Scalping (ATR) - ATR 10 x 1.0, internal 0.236, external 0.5. Built for 1m to 15m.
• Intraday (ATR) - ATR 14 x 1.5, internal 0.382, external 0.618. Built for 5m to 4h.
• Swing (%) - 1.5%, internal 0.382, external 0.618. Built for 4h to 1D.
• Position (%) - 4%, internal 0.5, external 0.786. Built for 1D to 1W.

The first number is how far price must reverse before a new pivot is recognised, which sets how much detail the ZigZag sees. The two thresholds are how deep a retracement has to be before an impulse is declared over at each degree: lower numbers break the move into more, smaller impulses; higher numbers merge more legs into fewer, larger ones. They also set the pullback band the trend signals use.

While a preset is selected the manual ZigZag fields and the two thresholds are ignored. Nothing is hidden: the Setting row of the panel always prints the values actually in force, so you can check which calibration is running without opening the dialog. To edit them by hand, switch the preset to Custom.

ATR mode measures that first number in real average ranges instead of a fixed percentage. A fixed percentage punishes quiet sessions with noise pivots and falls short in volatile ones, swallowing whole impulses. With ATR, one setting travels across instruments and across sessions.

One field applies even with a preset selected: "End of internal impulse". It is a reading decision rather than a calibration, so the preset does not overwrite it. Both is recommended, and it ends the impulse on whichever comes first, a deep enough retracement or a broken swing.

The rest of the inputs are grouped by what they draw: ZigZag, impulses, Fibonacci levels, projections, structure levels, sweeps and liquidity, volume profile, panel, and signals.


[b]ALERTS[/b]

Twelve conditions. Right-click the chart, choose Add alert, and select this indicator.

Structure:
• New internal impulse - a fresh impulse has been confirmed at the degree you trade.
• Internal impulse finished - the one you were following has ended, by depth or by structure.
• New external impulse - the larger context has changed direction.
• Price in Fib zone - price has just entered the shaded retracement zone.
• New ZigZag pivot - a swing high or low has been confirmed.
• Liquidity sweep - a watched level was pierced by a wick and price closed back inside.

Signals:
• Trend buy / Trend sell - a pullback inside the external impulse, with the slow MACD in agreement.
• Counter-trend buy / Counter-trend sell - a swept pivot that failed, with the fast MACD turning against it.
• Buy (any) / Sell (any) - either setup, for a single alert covering both.


[b]HOW IT BEHAVES, AND WHAT IT CANNOT DO[/b]

• Pivots are final once confirmed. A pivot confirms on a bar close and never moves afterwards, so the structure behind you does not repaint. The live extreme does keep updating in real time, which is what lets the Fib re-anchor itself while a leg is still running.

• Pivots can take one extra candle on vertical moves. A pivot is never closed by the same candle that created the extreme. Pine cannot know the order of events inside a bar, so on a bullish candle it cannot assume the low came after the high. Allowing it produced phantom impulses built out of a single candle's own body, so it is blocked deliberately, and the cost is that one extra candle.

• The volume profile is approximate where intrabar history runs out. The intrabar store keeps the most recent bars; beyond it the profile falls back to spreading each candle's volume between its high and its low, and the panel says so next to the POC. The profile is computed on the last bar only, and looks back 900 bars at most, to keep the chart responsive.

• Symbols that report no volume still work. Many FX pairs and some indices publish none at all; the bar range is then used as the effort measure and the panel prints "no-volume" beside the setting in force.

• Drawings are clipped far back. A box or line anchored thousands of bars into the past falls outside the historical buffer Pine can resolve, which would stop the script, so anchors are clamped to a reachable window. An external impulse older than that window has its box clipped on the left, while the panel still shows its true origin in price and date.

• There is no liquidation heatmap. That data does not exist in TradingView, and anything claiming to plot one is estimating it. The liquidity lines here are untaken pivots, which is hard data. A real liquidation map has to be read elsewhere and crossed against this by hand.

• Nothing here is a recommendation. The signals are a mechanical reading of structure, volume and two oscillators. Position sizing, risk and the decision to take a trade are yours.

## Source Code

````pine
//@version=6
indicator("Impulses + Fib", "Impulses+Fib", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 1000)

// =========================================================================
// 1. INPUTS
// =========================================================================
GPS = "0 - Preset"
preset     = input.string("Intraday (ATR)", "Preset", options = ["Intraday (ATR)", "Scalping (ATR)", "Swing (%)", "Position (%)", "Custom"], group = GPS, tooltip = "Sets the deviation mode, its size and both pullback thresholds at once. Unless you pick 'Custom', the group 1 fields and the group 2 thresholds are ignored (the panel always prints the values actually in force).\n\nScalping (ATR): ATR 10 x 1.0, int 0.236, ext 0.5 — 1m-15m.\nIntraday (ATR): ATR 14 x 1.5, int 0.382, ext 0.618 — 5m-4h.\nSwing (%): 1.5%, int 0.382, ext 0.618 — 4h-1D.\nPosition (%): 4%, int 0.5, ext 0.786 — 1D-1W.")

GZZ = "1 - ZigZag (manual)"
devMode    = input.string("ATR", "Deviation mode", options = ["Percent", "ATR"], group = GZZ, tooltip = "Percent: fixed % threshold. ATR: threshold adapted to volatility. Only applies with the 'Custom' preset.")
devPct     = input.float(1.5, "Deviation (%)", minval = 0.01, step = 0.1, group = GZZ)
atrLen     = input.int(14, "ATR", minval = 1, inline = "atr", group = GZZ)
atrMult    = input.float(1.5, "x", minval = 0.1, step = 0.1, inline = "atr", group = GZZ)
useWicks   = input.bool(true, "Use wicks (high/low)", group = GZZ, tooltip = "Off uses bodies only (max/min of open-close): ignores liquidity wicks.")
zzWidth    = input.int(2, "Width", minval = 1, maxval = 4, inline = "zz", group = GZZ)
maxSegs    = input.int(50, "Max legs", minval = 1, maxval = 250, inline = "zz", group = GZZ)
bullCol    = input.color(#26a69a, "Bullish", inline = "cc", group = GZZ)
bearCol    = input.color(#ef5350, "Bearish", inline = "cc", group = GZZ)
drawLive   = input.bool(true, "Draw the running leg", group = GZZ)
showStruct = input.bool(true, "HH / HL / LH / LL labels", inline = "st", group = GZZ)
structPx   = input.bool(false, "with price", inline = "st", group = GZZ)

GIM = "2 - Impulses (two degrees)"
endMode    = input.string("Both", "End of internal impulse", options = ["Depth (Fib)", "Structure (swing break)", "Both"], group = GIM, tooltip = "Depth: the impulse ends when the retracement reaches the internal threshold.\nStructure: it ends when a pullback breaks the previous pullback (a lower low in a bullish impulse, a higher high in a bearish one).\nBoth: whichever comes first. Recommended: the structure rule is what stops an impulse from growing forever up to an all-time extreme.\n\nThis selector always applies, presets included. The EXTERNAL impulse uses depth only.")
thrInt     = input.float(0.382, "Internal threshold (Fib)", minval = 0.05, maxval = 0.99, step = 0.001, group = GIM, tooltip = "Only with the 'Custom' preset.")
thrExt     = input.float(0.618, "External threshold (Fib)", minval = 0.05, maxval = 0.99, step = 0.001, group = GIM, tooltip = "Only with the 'Custom' preset.")
showBoxInt = input.bool(true, "Internal impulse box", inline = "bx", group = GIM)
showBoxExt = input.bool(true, "external one", inline = "bx", group = GIM)
showImpLbl = input.bool(true, "Impulse labels", group = GIM)
extCol     = input.color(#787b86, "External degree colour", group = GIM)
showAnchor = input.bool(true, "Anchor line 0 -> 1", group = GIM, tooltip = "Joins the origin and the extreme of the impulse the Fib is anchored to: the two points where you would drop the Fib Retracement tool.")
anchorCol  = input.color(#FFD700, "Anchor colour", group = GIM)

GFB = "3 - Fibonacci"
showFib    = input.bool(true, "Show retracements", group = GFB)
fibSrc     = input.string("Internal impulse", "Anchor on", options = ["Internal impulse", "External impulse", "Last ZigZag leg"], group = GFB)
fibRight   = input.int(30, "Extend right (bars)", minval = 0, maxval = 500, group = GFB)
fibFromO   = input.bool(true, "Start at the origin", group = GFB, tooltip = "On: lines start at the impulse origin. Off: they start at the extreme.")
fibLblOn   = input.bool(true, "Labels", inline = "fl", group = GFB)
fibPxOn    = input.bool(true, "Prices", inline = "fl", group = GFB)
fibWidth   = input.int(1, "Width", minval = 1, maxval = 3, inline = "fl", group = GFB)

r1On = input.bool(true,   "", inline = "R1", group = GFB)
r1V  = input.float(0.0,   "", inline = "R1", step = 0.001, group = GFB)
r1C  = input.color(#787b86, "", inline = "R1", group = GFB)
r2On = input.bool(true,   "", inline = "R2", group = GFB)
r2V  = input.float(0.236, "", inline = "R2", step = 0.001, group = GFB)
r2C  = input.color(#9598a1, "", inline = "R2", group = GFB)
r3On = input.bool(true,   "", inline = "R3", group = GFB)
r3V  = input.float(0.382, "", inline = "R3", step = 0.001, group = GFB)
r3C  = input.color(#2962ff, "", inline = "R3", group = GFB)
r4On = input.bool(true,   "", inline = "R4", group = GFB)
r4V  = input.float(0.5,   "", inline = "R4", step = 0.001, group = GFB)
r4C  = input.color(#089981, "", inline = "R4", group = GFB)
r5On = input.bool(true,   "", inline = "R5", group = GFB)
r5V  = input.float(0.618, "", inline = "R5", step = 0.001, group = GFB)
r5C  = input.color(#f7931a, "", inline = "R5", group = GFB)
r6On = input.bool(true,   "", inline = "R6", group = GFB)
r6V  = input.float(0.705, "", inline = "R6", step = 0.001, group = GFB)
r6C  = input.color(#f7931a, "", inline = "R6", group = GFB)
r7On = input.bool(true,   "", inline = "R7", group = GFB)
r7V  = input.float(0.786, "", inline = "R7", step = 0.001, group = GFB)
r7C  = input.color(#e91e63, "", inline = "R7", group = GFB)
r8On = input.bool(true,   "", inline = "R8", group = GFB)
r8V  = input.float(1.0,   "", inline = "R8", step = 0.001, group = GFB)
r8C  = input.color(#787b86, "", inline = "R8", group = GFB)

showZone = input.bool(true, "Entry zone", inline = "z", group = GFB)
zoneA    = input.float(0.618, "from", step = 0.001, inline = "z", group = GFB)
zoneB    = input.float(0.786, "to", step = 0.001, inline = "z", group = GFB)
zoneCol  = input.color(color.new(#f7931a, 85), "", inline = "z", group = GFB)

GPR = "4 - Projections"
showProj = input.bool(false, "Show projections", group = GPR, tooltip = "Targets beyond the extreme: price = origin + k * (extreme - origin).")
p1On = input.bool(true,   "", inline = "P1", group = GPR)
p1V  = input.float(1.272, "", inline = "P1", step = 0.001, group = GPR)
p1C  = input.color(#673ab7, "", inline = "P1", group = GPR)
p2On = input.bool(true,   "", inline = "P2", group = GPR)
p2V  = input.float(1.618, "", inline = "P2", step = 0.001, group = GPR)
p2C  = input.color(#673ab7, "", inline = "P2", group = GPR)
p3On = input.bool(false,  "", inline = "P3", group = GPR)
p3V  = input.float(2.618, "", inline = "P3", step = 0.001, group = GPR)
p3C  = input.color(#673ab7, "", inline = "P3", group = GPR)

GLV = "5 - Structure levels"
showRange = input.bool(true, "Current high/low lines", group = GLV)
showInval = input.bool(true, "Level that ends the internal impulse", group = GLV, tooltip = "Last pullback of the internal impulse: break it and the impulse is over. With no pullback of reference yet, it draws the last HL (bullish structure) or LH (bearish).")
levExtend = input.int(60, "Extend right (bars)", minval = 5, maxval = 500, group = GLV)
showRangeBox = input.bool(true, "Consolidation range box", group = GLV, tooltip = "Drawn only while the recent swings are testing the same two levels. Each edge is the median of the last touches, so a single wick cannot blow the box out.")
rangeTouches = input.int(3, "Touches per side", minval = 2, maxval = 5, inline = "rb", group = GLV)
rangeTolPct  = input.float(25, "Tolerance (% of height)", minval = 5, maxval = 60, step = 5, inline = "rb", group = GLV)
rangeBoxCol  = input.color(color.new(#2962ff, 90), "Range box fill", group = GLV)
invalCol  = input.color(#FFD700, "Invalidation", inline = "lv", group = GLV)
rangeCol  = input.color(#787b86, "Range", inline = "lv", group = GLV)
levStyleS = input.string("Dashed", "Style", options = ["Solid", "Dashed", "Dotted"], group = GLV)

GSW = "6 - Sweeps and liquidity"
showSweep  = input.bool(true, "Detect sweeps", group = GSW, tooltip = "A level counts as SWEPT when price pierces it with a wick and closes back on the other side within the given candles. If it closes outside and holds, it is a BREAK (acceptance), not a sweep.")
sweepK     = input.int(3, "Candles to close back", minval = 1, maxval = 20, group = GSW)
liqMax     = input.int(20, "Max watched levels", minval = 4, maxval = 60, group = GSW)
showLiqLn  = input.bool(true, "Draw untaken liquidity", group = GSW, tooltip = "Pivots price has not pierced yet: the stops are still sitting there.")
liqShow    = input.int(6, "How many levels to draw", minval = 1, maxval = 20, group = GSW)
sweepCol   = input.color(#e91e63, "Sweep", inline = "sw", group = GSW)
liqCol     = input.color(#607d8b, "Untouched liquidity", inline = "sw", group = GSW)

GVP = "7 - Impulse volume profile"
showVP     = input.bool(true, "Compute the impulse profile", group = GVP, tooltip = "Volume profile of the range the Fib is anchored to. The key figure is where the POC ended up: near the extreme = the move was accepted; near the origin = price passed through without trading.")
vpBins     = input.int(24, "Levels (bins)", minval = 6, maxval = 60, group = GVP)
vpDraw     = input.bool(true, "Draw histogram", inline = "vp", group = GVP)
vpWidth    = input.int(25, "Width (bars)", minval = 3, maxval = 200, inline = "vp", group = GVP)
vpCol      = input.color(color.new(#2962ff, 80), "Histogram", inline = "vc", group = GVP)
vpIntrabar = input.bool(true, "Intrabar precision", group = GVP, tooltip = "Builds the profile from lower timeframe candles instead of spreading each candle's volume evenly between its high and its low. The even spread penalises wide candles and rewards narrow ones, which drags the POC towards the origin of a vertical impulse and can flip the verdict. Bars with no intrabar data available fall back to the candle itself; the panel says which source produced the POC.")
showVA     = input.bool(true, "POC / VAH / VAL lines", group = GVP)
vaPct      = input.float(70, "Value area (%)", minval = 40, maxval = 95, step = 5, group = GVP)
pocCol     = input.color(#ff9800, "POC", inline = "vc2", group = GVP)
vaCol      = input.color(#9598a1, "VAH/VAL", inline = "vc2", group = GVP)

GTB = "8 - Panel"
showTable = input.bool(true, "Show panel", group = GTB)
tblMode   = input.string("Signals", "Mode", options = ["Signals", "Full", "Compact"], group = GTB, tooltip = "Signals: trend, trigger, what is still missing for the next signal, and the last signal with its SL/TP, in words.\nFull: every metric of both impulses.\nCompact: a grid of icons with context, impulse, zone and verdict. The detail in numbers stays available by hovering over each cell.")
tblPosS   = input.string("Top right", "Position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = GTB)
tblSizeS  = input.string("Small", "Size", options = ["Tiny", "Small", "Normal"], group = GTB)

GSG = "9 - Signals (double MACD)"
showSig  = input.bool(true, "Show signals", group = GSG, tooltip = "Triangles on the chart. T = with the trend (pullback), CT = counter-trend (liquidity sweep). They are only evaluated on closed candles, so they do not repaint.")
sigTrend = input.bool(true, "Trend (pullback)", inline = "sg", group = GSG)
sigCT    = input.bool(true, "Counter-trend (sweep)", inline = "sg", group = GSG)
fFast    = input.int(12, "Fast MACD", minval = 1, inline = "mf", group = GSG)
fSlow    = input.int(26, "", minval = 2, inline = "mf", group = GSG)
fSig     = input.int(9, "", minval = 1, inline = "mf", group = GSG)
sFast    = input.int(12, "Slow MACD", minval = 1, inline = "ms", group = GSG)
sSlow    = input.int(26, "", minval = 2, inline = "ms", group = GSG)
sSig     = input.int(9, "", minval = 1, inline = "ms", group = GSG)
slowMult = input.int(4, "Slow MACD timeframe (x chart)", minval = 1, maxval = 30, group = GSG, tooltip = "4 = four times the chart timeframe (15m -> 1h, 1h -> 4h). 1 = the same timeframe, in which case use slower parameters (48 / 104 / 36, for example).")
slowRule = input.string("Line > 0", "Slow MACD filter", options = ["Line > 0", "Line > signal", "Both"], group = GSG, tooltip = "When the slow MACD counts as bullish. 'Line > 0' is the steadier one through retracements; 'Line > signal' reacts sooner but blocks more pullback entries.")
pbAuto   = input.bool(true, "Pullback zone from the preset", group = GSG, tooltip = "Retracement of the EXTERNAL impulse where with-trend entries are looked for: from the internal threshold (a real pullback by then) out to the external one (deeper, where the trend is given up). Intraday: 0.382-0.618.")
pbMinIn  = input.float(0.382, "Manual zone: from", minval = 0.05, maxval = 0.99, step = 0.001, inline = "pb", group = GSG)
pbMaxIn  = input.float(0.618, "a", minval = 0.05, maxval = 0.99, step = 0.001, inline = "pb", group = GSG)
trigWin  = input.int(5, "Candles for the trigger", minval = 1, maxval = 30, group = GSG, tooltip = "How many candles the fast MACD has to turn within, after price touches the zone or a sweep prints. Past that window the setup expires.")
ctDiv    = input.bool(true, "CT: require divergence on the fast MACD", group = GSG, tooltip = "Price takes out the swept pivot but the fast MACD stays below the value it had at that pivot (the other way round at lows).")
slBuf    = input.float(0.25, "Stop buffer (x ATR)", minval = 0, step = 0.05, group = GSG)
rrTP     = input.float(2.0, "Target (R)", minval = 0.5, step = 0.25, group = GSG, tooltip = "TP = entry +/- R x risk, where risk is the distance from the entry to the stop.")
whOn     = input.bool(true, "JSON alert for webhook", group = GSG, tooltip = "Every signal calls alert() with a JSON payload (symbol, side, setup, price, sl, tp). Create the alert with the 'Any alert() function call' condition and paste your webhook URL.")

// =========================================================================
// 2. EFFECTIVE VALUES (preset or manual)
// =========================================================================
bool   isCustom = preset == "Custom"
bool   isPctPre = preset == "Swing (%)" or preset == "Position (%)"
string devModeE = isCustom ? devMode : isPctPre ? "Percent" : "ATR"
float  devPctE  = isCustom ? devPct  : preset == "Swing (%)" ? 1.5 : preset == "Position (%)" ? 4.0 : devPct
int    atrLenE  = isCustom ? atrLen  : preset == "Scalping (ATR)" ? 10 : 14
float  atrMultE = isCustom ? atrMult : preset == "Scalping (ATR)" ? 1.0 : 1.5
float  thrIntB  = isCustom ? thrInt  : preset == "Scalping (ATR)" ? 0.236 : preset == "Position (%)" ? 0.5 : 0.382
float  thrExtE  = isCustom ? thrExt  : preset == "Scalping (ATR)" ? 0.5 : preset == "Position (%)" ? 0.786 : 0.618

// the end-of-impulse selector is always honoured, presets included
bool   useStructE = endMode != "Depth (Fib)"
float  thrIntE    = endMode == "Structure (swing break)" ? 1.0 : thrIntB

// liquidity levels are tracked whenever something needs them: the drawing or the countertrend signals
bool   trackLiq   = showSweep or (showSig and sigCT)

// Effort source. Some symbols report no volume at all (many FX pairs, some indices).
// Feeding zeros to the profile would collapse every bin and pin the POC at the bottom
// of the range, which reads as a confident "no acceptance" on every single impulse.
// Fall back to the bar range, the standard substitute for effort when volume is absent.
bool   hasVol    = ta.cum(nz(volume)) > 0
float  effortSrc = hasVol ? nz(volume) : high - low

// Intrabar data for the profile. Spreading a candle's volume evenly between its high
// and its low penalises wide candles and rewards narrow ones: the base of an impulse
// concentrates its volume in two or three bins while the rally dilutes its own across
// twenty, which drags the POC towards the origin by construction. Roughly sixteen
// intrabars per candle is enough to converge (15m, 5m and 1m land on the same bin).
int    chartSecs = timeframe.in_seconds(timeframe.period)
int    ltfTarget = math.max(1, int(chartSecs / 16))
string ltfStr    = ltfTarget >= 86400 ? "1D" : ltfTarget >= 14400 ? "240" : ltfTarget >= 3600 ? "60" : ltfTarget >= 1800 ? "30" : ltfTarget >= 900 ? "15" : ltfTarget >= 300 ? "5" : ltfTarget >= 180 ? "3" : ltfTarget >= 60 ? "1" : ltfTarget >= 30 ? "30S" : ltfTarget >= 15 ? "15S" : ltfTarget >= 5 ? "5S" : "1S"
[ltfH, ltfL, ltfV] = request.security_lower_tf(syminfo.tickerid, ltfStr, [high, low, volume])

// Intrabar store. Array history does NOT hand back the array as it was k bars ago: it
// hands back a reference to the current object, so reaching back with ltfH[k] gives every
// past bar today's intrabars and the whole profile collapses onto today's price. Scalars
// keep proper history, collections do not. So the intrabars are copied out as they arrive.
// Each bar contributes exactly its own chart-level effort; the intrabars only decide the
// SHAPE of that contribution, which keeps intrabar bars and fallback bars commensurable.
var array<float> ibHi = array.new<float>()
var array<float> ibLo = array.new<float>()
var array<float> ibEf = array.new<float>()
var array<int>   ibB  = array.new<int>()
int ibMax = 8000

bool ibHas = false
if vpIntrabar and barstate.isconfirmed and not na(ltfH) and ltfH.size() > 0 and ltfL.size() == ltfH.size()
    bool okV = hasVol and not na(ltfV) and ltfV.size() == ltfH.size()
    float wSum = 0.0
    for j = 0 to ltfH.size() - 1
        wSum += okV ? nz(ltfV.get(j)) : math.max(ltfH.get(j) - ltfL.get(j), 0.0)
    if wSum > 0
        float barEf = nz(effortSrc)
        for j = 0 to ltfH.size() - 1
            float w = okV ? nz(ltfV.get(j)) : math.max(ltfH.get(j) - ltfL.get(j), 0.0)
            ibHi.push(ltfH.get(j))
            ibLo.push(ltfL.get(j))
            ibEf.push(barEf * w / wSum)
            ibB.push(bar_index)
        ibHas := true
        while ibB.size() > ibMax
            ibHi.shift()
            ibLo.shift()
            ibEf.shift()
            ibB.shift()

string settingTxt = (devModeE == "ATR" ? "ATR " + str.tostring(atrLenE) + "x" + str.tostring(atrMultE, "#.##") : str.tostring(devPctE, "#.##") + "%") + "  int " + str.tostring(thrIntE, "#.###") + "  ext " + str.tostring(thrExtE, "#.###") + (useStructE ? "  +structure" : "") + (hasVol ? "" : "  no-volume")

// =========================================================================
// 3. FUNCTIONS
// =========================================================================
atrVal = ta.atr(atrLenE)

//@function Formats a price with the symbol's precision.
fmt(float p) =>
    str.tostring(p, format.mintick)

//@function Clamps a drawing's bar index into a window Pine can still resolve.
//          A drawing anchored with xloc.bar_index makes Pine reach into the historical
//          buffer for that bar. The external degree merges dozens of legs, so its origin
//          can sit thousands of bars back, past the buffer, and that stops the script with
//          "the requested historical offset is beyond the historical buffer's limit".
//          Clipping the left edge of an old box is a far better outcome than no script.
int drawMaxBack = 4000
xSafe(int b) =>
    math.max(0, math.max(nz(b, bar_index), bar_index - drawMaxBack))

//@function Formats a timestamp according to the timeframe.
fmtTime(int t) =>
    na(t) ? "" : str.format_time(t, timeframe.isintraday ? "dd MMM HH:mm" : "yyyy-MM-dd", syminfo.timezone)

//@function Translates a style name into a line style.
lineStyle(string s) =>
    s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed

//@function Reversal threshold, in price, for a reference price.
thrOf(float refPrice) =>
    devModeE == "ATR" ? nz(atrVal) * atrMultE : refPrice * devPctE * 0.01

//@function Volume profile of the range [b0, b1] spread over `bins` levels.
//@param out Array that receives the volume of each level (overwritten).
//@returns [pocPrice, VAH, VAL, rangeLow, rangeHigh, maxLevelVolume, intrabarFraction]
calcProfile(int b0, int b1, int bins, float vaTarget, array<float> out) =>
    out.clear()
    for i = 0 to bins - 1
        out.push(0.0)
    float lo = na
    float hi = na
    for b = b0 to b1
        int k = bar_index - b
        lo := na(lo) ? low[k] : math.min(lo, low[k])
        hi := na(hi) ? high[k] : math.max(hi, high[k])
    float step = (hi - lo) / bins
    int nBars  = 0
    int nIntra = 0
    // the store is capped at ibMax intrabars: bars already evicted from it (and the oldest
    // one kept, which may be partial) fall back to the candle instead of adding nothing,
    // otherwise the start of a long impulse weighs zero and the POC drifts to the extreme
    int ibCut = ibB.size() > 0 ? ibB.get(0) : bar_index + 1
    if step > 0
        // bars covered by the intrabar store contribute from it; the rest from the candle
        for b = b0 to b1
            int k = bar_index - b
            bool useIb = ibHas[k] and b > ibCut
            nBars += 1
            nIntra += useIb ? 1 : 0
            if not useIb
                float bl = low[k]
                float bh = high[k]
                float v  = nz(effortSrc[k])
                int i0 = math.max(0, math.min(bins - 1, int(math.floor((bl - lo) / step))))
                int i1 = math.max(0, math.min(bins - 1, int(math.floor((bh - lo) / step))))
                float share = v / (i1 - i0 + 1)
                for i = i0 to i1
                    out.set(i, out.get(i) + share)
        // one pass over the stored intrabars that fall inside the range
        int nIb = ibB.size()
        if nIb > 0
            for j = 0 to nIb - 1
                int bb = ibB.get(j)
                if bb >= b0 and bb <= b1 and bb > ibCut
                    float bl = ibLo.get(j)
                    float bh = ibHi.get(j)
                    float v  = ibEf.get(j)
                    int i0 = math.max(0, math.min(bins - 1, int(math.floor((bl - lo) / step))))
                    int i1 = math.max(0, math.min(bins - 1, int(math.floor((bh - lo) / step))))
                    float share = v / (i1 - i0 + 1)
                    for i = i0 to i1
                        out.set(i, out.get(i) + share)
    // POC and value area
    int   poc = 0
    float mx  = 0.0
    float tot = 0.0
    for i = 0 to bins - 1
        float v = out.get(i)
        tot += v
        if v > mx
            mx  := v
            poc := i
    float acc = out.get(poc)
    float goal = tot * vaTarget / 100.0
    int up = poc
    int dn = poc
    while acc < goal and (up < bins - 1 or dn > 0)
        float vu = up < bins - 1 ? out.get(up + 1) : -1.0
        float vd = dn > 0 ? out.get(dn - 1) : -1.0
        if vu >= vd
            up  += 1
            acc += vu
        else
            dn  -= 1
            acc += vd
    [lo + (poc + 0.5) * step, lo + (up + 1) * step, lo + dn * step, lo, hi, mx, float(nIntra) / math.max(nBars, 1)]

//@function Robust edge: median of the last three touches, or a blend when there are fewer.
//          One wick then cannot drag the boundary the way a raw extreme would.
robustEdge(array<float> arr, int want) =>
    int n = arr.size()
    float r = na
    if n >= 3 and want >= 3
        float x = arr.get(n - 1)
        float y = arr.get(n - 2)
        float z = arr.get(n - 3)
        r := x + y + z - math.max(x, math.max(y, z)) - math.min(x, math.min(y, z))
    else if n >= 2
        r := (arr.get(n - 1) + arr.get(n - 2)) / 2.0
    else if n == 1
        r := arr.get(0)
    r

//@function True when the last `want` touches all sit within `tol` of the edge.
allWithin(array<float> arr, int want, float ref, float tol) =>
    int n = arr.size()
    int k = math.min(n, want)
    bool ok = k >= 2
    if k >= 2
        for i = n - k to n - 1
            if math.abs(arr.get(i) - ref) > tol
                ok := false
    ok

//@function Oldest bar among the last `want` entries.
firstBarOf(array<int> arr, int want) =>
    int n = arr.size()
    int k = math.min(n, want)
    k >= 1 ? arr.get(n - k) : int(na)

//@function State text of an impulse.
stateTxt(float rt, float thr, int impD, int zzD, bool broke) =>
    na(rt) ? "-" : rt >= 1.0 ? "Origin broken (>100%)" : broke ? "Structure broken: finished" : rt >= thr ? "Deep pullback: finished" : zzD == impD ? "Extending" : "Internal pullback: alive"

//@function MACD line and signal of the PREVIOUS bar, for a non-repainting higher-timeframe request.
macdPrev(int f, int s, int g) =>
    [m, sg, h] = ta.macd(close, f, s, g)
    [m[1], sg[1]]

// ---- double MACD ----
// The fast MACD, on the chart timeframe, is the trigger. The slow one is the trend filter
// and by default runs on a higher timeframe, read from its last CLOSED bar (offset 1 plus
// lookahead): the standard way to request higher-timeframe data without repainting.
[macdF, sigF, histF] = ta.macd(close, fFast, fSlow, fSig)
string slowTfE = slowMult <= 1 ? timeframe.period : timeframe.from_seconds(timeframe.in_seconds(timeframe.period) * slowMult)
[macdSlowH, sigSlowH] = request.security(syminfo.tickerid, slowTfE, macdPrev(sFast, sSlow, sSig), lookahead = barmerge.lookahead_on)
[macdSlowL, sigSlowL, histSlowL] = ta.macd(close, sFast, sSlow, sSig)
float macdS = slowMult <= 1 ? macdSlowL : macdSlowH
float sigS  = slowMult <= 1 ? sigSlowL  : sigSlowH

bool slowBull = slowRule == "Line > 0" ? macdS > 0 : slowRule == "Line > signal" ? macdS > sigS : macdS > 0 and macdS > sigS
bool slowBear = slowRule == "Line > 0" ? macdS < 0 : slowRule == "Line > signal" ? macdS < sigS : macdS < 0 and macdS < sigS
bool fastBull = macdF > sigF
bool fastBear = macdF < sigF

// =========================================================================
// 4. AGGREGATED IMPULSE TYPE
// =========================================================================
//@type Liquidity level (pivot) and its state against price.
//@field state 0 untouched, 1 pierced (pending), 2 swept, 3 broken with acceptance
type Liq
    float price     = na
    int   bar       = na
    bool  isHigh    = false
    int   state     = 0
    int   pierceBar = na
    int   eventBar  = na

type Imp
    int   dir      = 0     // +1 bullish, -1 bearish, 0 undefined
    float o        = na    // origin  (fib level 1)
    int   ob       = na
    int   ot       = na
    float e        = na    // extreme (fib level 0)
    int   eb       = na
    int   et       = na
    int   legs     = 0     // merged ZigZag legs
    float cx       = na    // counter-extreme reached since e
    float pb       = na    // last internal pullback (structure reference)
    int   pbb      = na
    bool  eChanged = false
    bool  isNew    = false
    bool  ended    = false

//@function Feeds the aggregator with a freshly confirmed pivot.
//@param prevP/prevB/prevT Previous pivot (origin of the leg being closed).
//@param pivP/pivB/pivT/pivHigh The pivot just confirmed.
//@param thr Retracement threshold that ends the impulse.
//@param useStruct Also apply the broken-previous-pullback rule.
method feed(Imp self, float prevP, int prevB, int prevT, float pivP, int pivB, int pivT, bool pivHigh, float thr, bool useStruct) =>
    self.isNew := false
    self.ended := false
    int d = pivHigh ? 1 : -1
    if self.dir == 0
        self.dir      := d
        self.o        := prevP
        self.ob       := prevB
        self.ot       := prevT
        self.e        := pivP
        self.eb       := pivB
        self.et       := pivT
        self.legs     := 1
        self.pb       := na
        self.pbb      := na
        self.eChanged := true
        self.isNew    := true
    else if d == self.dir
        // leg with the trend: extends the impulse only if it beats the extreme
        self.legs += 1
        if (d == 1 and pivP > self.e) or (d == -1 and pivP < self.e)
            self.e        := pivP
            self.eb       := pivB
            self.et       := pivT
            self.eChanged := true
    else
        // counter leg: decide between internal pullback and end of impulse
        float sp   = math.abs(self.e - self.o)
        float rt   = sp > 0 ? math.abs(pivP - self.e) / sp : 1.0
        bool  deep = rt >= thr
        bool  brk  = useStruct and not na(self.pb) and ((self.dir == 1 and pivP < self.pb) or (self.dir == -1 and pivP > self.pb))
        if deep or brk
            self.dir      := d
            self.o        := self.e
            self.ob       := self.eb
            self.ot       := self.et
            self.e        := pivP
            self.eb       := pivB
            self.et       := pivT
            self.legs     := 1
            self.pb       := na
            self.pbb      := na
            self.eChanged := true
            self.isNew    := true
            self.ended    := true
        else
            self.legs += 1
            self.pb   := pivP
            self.pbb  := pivB
            self.ended := false   // closes the branch as bool: every branch of an if must return the same type

//@function If the retracement passes 100% the impulse is dead: the opposite one
//          is born at once, without waiting for a pivot to confirm.
method invalidate(Imp self, int zzDir, float xP, int xB, int xT) =>
    if self.dir != 0 and zzDir == -self.dir and not na(xP) and not na(self.o)
        if self.dir == 1 ? xP < self.o : xP > self.o
            self.o        := self.e
            self.ob       := self.eb
            self.ot       := self.et
            self.e        := xP
            self.eb       := xB
            self.et       := xT
            self.dir      := -self.dir
            self.legs     := 1
            self.pb       := na
            self.pbb      := na
            self.isNew    := true
            self.ended    := true
            self.eChanged := true

//@function Extends the extreme with the running leg while it goes its way.
method live(Imp self, int zzDir, float xP, int xB, int xT) =>
    if self.dir != 0 and zzDir == self.dir and not na(xP)
        if (self.dir == 1 and xP > self.e) or (self.dir == -1 and xP < self.e)
            self.e        := xP
            self.eb       := xB
            self.et       := xT
            self.eChanged := true

//@function Accumulates the counter-extreme reached since the impulse extreme.
method track(Imp self, float sH, float sL, float seed) =>
    if self.dir == 0
        self.cx := na
    else if self.eChanged
        self.eChanged := false
        // same rule as the ZigZag: the candle that makes the extreme cannot also count as
        // the pullback, because the order of its high and its low is unknown
        self.cx := self.eb == bar_index ? self.e : self.dir == 1 ? math.min(sL, nz(seed, sL)) : math.max(sH, nz(seed, sH))
    else
        self.cx := self.dir == 1 ? math.min(nz(self.cx, sL), sL) : math.max(nz(self.cx, sH), sH)

//@function Deepest retracement reached, as a fraction of the impulse.
method retr(Imp self) =>
    float a = math.abs(self.e - self.o)
    self.dir == 0 or na(self.cx) or na(a) or a == 0 ? na : math.abs(self.e - self.cx) / a

//@function Impulse size in %.
method pct(Imp self) =>
    self.dir == 0 or na(self.o) or self.o == 0 ? na : math.abs((self.e - self.o) / self.o) * 100

//@function The impulse has valid anchors to draw.
method ok(Imp self) =>
    self.dir != 0 and not na(self.o) and not na(self.e) and not na(self.ob) and not na(self.eb) and self.o != self.e

//@function Current price has already broken the reference pullback.
method broke(Imp self) =>
    self.dir != 0 and not na(self.pb) and (self.dir == 1 ? low < self.pb : high > self.pb)

// =========================================================================
// 5. ZIGZAG ENGINE
// =========================================================================
float srcH = useWicks ? high : math.max(open, close)
float srcL = useWicks ? low  : math.min(open, close)

var int   dir  = 0        // +1 looking for a high, -1 looking for a low, 0 undefined
var float extP = na       // extreme of the running leg
var int   extB = na
var int   extT = na
var float oppP = na       // counter-extreme since extB (the low when dir = 1)
var int   oppB = na
var int   oppT = na
var float sHiP = na       // seeds: start with no directional bias
var int   sHiB = na
var int   sHiT = na
var float sLoP = na
var int   sLoB = na
var int   sLoT = na

if dir == 0
    if na(sHiP) or srcH > sHiP
        sHiP := srcH
        sHiB := bar_index
        sHiT := time
    if na(sLoP) or srcL < sLoP
        sLoP := srcL
        sLoB := bar_index
        sLoT := time
else if dir == 1
    if srcH > extP
        extP := srcH
        extB := bar_index
        extT := time
        // the counter-extreme only counts FROM THE NEXT BAR ON: inside one candle
        // we cannot know whether the low happened before or after the high
        oppP := na
        oppB := na
        oppT := na
    else if na(oppP) or srcL < oppP
        oppP := srcL
        oppB := bar_index
        oppT := time
else
    if srcL < extP
        extP := srcL
        extB := bar_index
        extT := time
        oppP := na
        oppB := na
        oppT := na
    else if na(oppP) or srcH > oppP
        oppP := srcH
        oppB := bar_index
        oppT := time

bool  pivNew  = false
float pivP    = na
int   pivB    = na
int   pivT    = na
bool  pivHigh = false

if barstate.isconfirmed
    if dir == 0
        float dnMove = sHiP - srcL
        float upMove = srcH - sLoP
        bool  goDn = sHiB < bar_index and dnMove >= thrOf(sHiP)
        bool  goUp = sLoB < bar_index and upMove >= thrOf(sLoP)
        if goDn and (not goUp or dnMove >= upMove)
            pivNew  := true
            pivP    := sHiP
            pivB    := sHiB
            pivT    := sHiT
            pivHigh := true
            dir  := -1
            extP := srcL
            extB := bar_index
            extT := time
            oppP := na
            oppB := na
            oppT := na
        else if goUp
            pivNew  := true
            pivP    := sLoP
            pivB    := sLoB
            pivT    := sLoT
            pivHigh := false
            dir  := 1
            extP := srcH
            extB := bar_index
            extT := time
            oppP := na
            oppB := na
            oppT := na
    else if dir == 1
        if not na(oppP) and extP - oppP >= thrOf(extP)
            pivNew  := true
            pivP    := extP
            pivB    := extB
            pivT    := extT
            pivHigh := true
            dir  := -1
            extP := oppP
            extB := oppB
            extT := oppT
            // if the new extreme belongs to this same bar, the counter-extreme waits for the next one
            oppP := extB == bar_index ? na : srcH
            oppB := extB == bar_index ? na : bar_index
            oppT := extB == bar_index ? na : time
    else
        if not na(oppP) and oppP - extP >= thrOf(extP)
            pivNew  := true
            pivP    := extP
            pivB    := extB
            pivT    := extT
            pivHigh := false
            dir  := 1
            extP := oppP
            extB := oppB
            extT := oppT
            oppP := extB == bar_index ? na : srcL
            oppB := extB == bar_index ? na : bar_index
            oppT := extB == bar_index ? na : time

// =========================================================================
// 6. PIVOTS, STRUCTURE AND THE TWO IMPULSE DEGREES
// =========================================================================
var array<line>  zzSeg = array.new<line>()
var array<label> stLbl = array.new<label>()

var float lpP     = na    // last confirmed pivot
var int   lpB     = na
var int   lpT     = na
var bool  havePiv = false
var float lastHiP = na
var int   lastHiB = na
var float lastLoP = na
var int   lastLoB = na
var int   structDir = 0

var Imp impInt = Imp.new()   // internal degree: the one you trade
var Imp impExt = Imp.new()   // external degree: the context
var array<Liq> liqs = array.new<Liq>()

// recent pivots per side, for the consolidation range box
var array<float> recHiP = array.new<float>()
var array<int>   recHiB = array.new<int>()
var array<float> recLoP = array.new<float>()
var array<int>   recLoB = array.new<int>()

// the flags last only for the bar they happen on
impInt.isNew := false
impInt.ended := false
impExt.isNew := false
impExt.ended := false

if pivNew
    if havePiv
        line seg = line.new(xSafe(lpB), lpP, xSafe(pivB), pivP, xloc = xloc.bar_index, color = pivHigh ? bullCol : bearCol, width = zzWidth)
        zzSeg.push(seg)
        if zzSeg.size() > maxSegs
            line.delete(zzSeg.shift())

    string tag = pivHigh ? (na(lastHiP) ? "H" : pivP > lastHiP ? "HH" : "LH") : (na(lastLoP) ? "L" : pivP < lastLoP ? "LL" : "HL")
    if tag == "HH"
        structDir := 1
    if tag == "LL"
        structDir := -1

    if showStruct
        label lb = label.new(xSafe(pivB), pivP, structPx ? tag + "\n" + fmt(pivP) : tag, xloc = xloc.bar_index, style = pivHigh ? label.style_label_down : label.style_label_up, color = pivHigh ? bearCol : bullCol, textcolor = color.white, size = size.small)
        stLbl.push(lb)
        if stLbl.size() > maxSegs + 1
            label.delete(stLbl.shift())

    if havePiv
        impInt.feed(lpP, lpB, lpT, pivP, pivB, pivT, pivHigh, thrIntE, useStructE)
        impExt.feed(lpP, lpB, lpT, pivP, pivB, pivT, pivHigh, thrExtE, false)

    if pivHigh
        lastHiP := pivP
        lastHiB := pivB
    else
        lastLoP := pivP
        lastLoB := pivB

    // keep the last touches of each side for the range box
    if pivHigh
        recHiP.push(pivP)
        recHiB.push(pivB)
        if recHiP.size() > 5
            recHiP.shift()
            recHiB.shift()
    else
        recLoP.push(pivP)
        recLoB.push(pivB)
        if recLoP.size() > 5
            recLoP.shift()
            recLoB.shift()

    // every confirmed pivot is liquidity: stops waiting on the other side
    if trackLiq
        liqs.push(Liq.new(price = pivP, bar = pivB, isHigh = pivHigh))
        if liqs.size() > liqMax
            liqs.shift()

    lpP := pivP
    lpB := pivB
    lpT := pivT
    havePiv := true

// ---- state of each liquidity level against this bar's price ----
var int   swPierceB = na    // bar that pierced the last swept level
var bool  swIsHigh  = false
var float swPrice   = na
var int   swBar     = na
var float swWick    = na    // wick extreme of the last sweep: the stop of a countertrend entry
var bool  swDiv     = false // fast MACD weaker than it was at the swept pivot (divergence)
bool sweepNow = false

if trackLiq and liqs.size() > 0
    for i = 0 to liqs.size() - 1
        Liq lq = liqs.get(i)
        if lq.state <= 1 and bar_index > lq.bar
            bool pierced = lq.isHigh ? high > lq.price : low < lq.price
            if lq.state == 0 and pierced
                lq.state     := 1
                lq.pierceBar := bar_index
            if lq.state == 1
                bool backInside = lq.isHigh ? close < lq.price : close > lq.price
                if backInside
                    lq.state    := 2                    // swept: wick outside, close back inside
                    lq.eventBar := bar_index
                    sweepNow    := true
                    swPierceB   := lq.pierceBar
                    swIsHigh    := lq.isHigh
                    swPrice     := lq.price
                    // wick and momentum since the pierce, against momentum at the swept pivot
                    float wk = lq.isHigh ? high : low
                    float mk = macdF
                    for k = 0 to bar_index - lq.pierceBar
                        wk := lq.isHigh ? math.max(wk, high[k]) : math.min(wk, low[k])
                        mk := lq.isHigh ? math.max(mk, macdF[k]) : math.min(mk, macdF[k])
                    bool dv  = false
                    int  off = bar_index - lq.bar
                    if off < 990
                        dv := lq.isHigh ? mk < macdF[off] : mk > macdF[off]
                    swWick := wk
                    swDiv  := dv
                    swBar  := bar_index
                else if bar_index - lq.pierceBar >= sweepK
                    lq.state    := 3                    // broken and accepted: not a sweep
                    lq.eventBar := bar_index

impInt.invalidate(dir, extP, extB, extT)
impExt.invalidate(dir, extP, extB, extT)
impInt.live(dir, extP, extB, extT)
impExt.live(dir, extP, extB, extT)
impInt.track(srcH, srcL, extP)
impExt.track(srcH, srcL, extP)

float retrInt = impInt.retr()
float retrExt = impExt.retr()
bool  brokeInt = useStructE and impInt.broke()

// =========================================================================
// 7. FIBONACCI ANCHORS
// =========================================================================
bool  useLeg = fibSrc == "Last ZigZag leg"
Imp   aImp   = fibSrc == "External impulse" ? impExt : impInt
float aO   = useLeg ? lpP  : aImp.o
int   aOb  = useLeg ? lpB  : aImp.ob
float aE   = useLeg ? extP : aImp.e
int   aEb  = useLeg ? extB : aImp.eb
int   aDir = useLeg ? dir  : aImp.dir
bool  aOk  = aDir != 0 and not na(aO) and not na(aE) and not na(aOb) and not na(aEb) and aO != aE
float aSpan = aOk ? aE - aO : na

//@function Price of a retracement level (0 = extreme, 1 = origin).
fibPrice(float r) =>
    aE - r * aSpan

//@function Price of a projection (k > 1 lands beyond the extreme).
projPrice(float k) =>
    aO + k * aSpan

float zPa  = aOk ? fibPrice(zoneA) : na
float zPb  = aOk ? fibPrice(zoneB) : na
float zTop = math.max(zPa, zPb)
float zBot = math.min(zPa, zPb)
bool  inZone    = aOk and not na(zTop) and low <= zTop and high >= zBot
bool  zoneEntry = inZone and not inZone[1]

// ---- volume profile of the anchored range ----
var array<float> vpArr = array.new<float>()
float pocP  = na
float vahP  = na
float valP  = na
float vpLo  = na
float vpHi  = na
float vpMax = na
int   vpB0  = na
int   vpB1  = na
float vpIntraFrac = na

if showVP and aOk and barstate.islast
    vpB0 := math.max(math.min(aOb, aEb), bar_index - 900)
    vpB1 := math.min(math.max(aOb, aEb), bar_index)
    if vpB1 > vpB0
        [p1, p2, p3, p4, p5, p6, p7] = calcProfile(vpB0, vpB1, vpBins, vaPct, vpArr)
        pocP  := p1
        vahP  := p2
        valP  := p3
        vpLo  := p4
        vpHi  := p5
        vpMax := p6
        vpIntraFrac := p7

// where the profile's numbers came from, so the POC is never read as more precise than it is
string vpSrcTxt = na(vpIntraFrac) ? "" : vpIntraFrac >= 0.99 ? ltfStr : vpIntraFrac <= 0.01 ? "candle" : ltfStr + "+candle"

// the POC spoken in the same language as the Fib: 0 = extreme, 1 = origin
float pocFib = not na(pocP) and aOk and aSpan != 0 ? (aE - pocP) / aSpan : na
// the impulse extreme was made by sweeping a previous level
bool  extIsSweep = showSweep and aOk and not na(swPierceB) and swPierceB == aEb and swIsHigh == (aDir == 1)
bool  accepted = not na(pocFib) and pocFib <= 0.5
string verdict = not aOk ? "-" : extIsSweep and not accepted ? "SWEPT - no acceptance" : extIsSweep ? "Swept but with acceptance (mixed)" : na(pocFib) ? (showVP ? "-" : "profile off") : accepted ? "ACCEPTANCE - continuation" : "No acceptance - weak"

// =========================================================================
// 8. SIGNALS: TREND AND COUNTERTREND (double MACD)
// =========================================================================
// Trend: the external impulse and the slow MACD agree, price pulls back into the band
// between the two impulse thresholds (deep enough to be a real pullback, not so deep that
// the external impulse is over) and the fast MACD turns back with the trend.
// Countertrend: a pivot is swept (wick outside, close back inside), optionally with the
// fast MACD diverging from the swept pivot, and the fast MACD turns against the sweep.
// Only confirmed bars can fire, so what history shows is what the alert sends live.
float  pbMin   = pbAuto ? thrIntB : pbMinIn
float  pbMax   = pbAuto ? thrExtE : pbMaxIn
string pbZ     = str.tostring(pbMin, "#.###") + "-" + str.tostring(pbMax, "#.###")
bool   canSig  = showSig and barstate.isconfirmed
bool   trendUp = impExt.dir == 1 and slowBull
bool   trendDn = impExt.dir == -1 and slowBear

// ---- trend: pullback inside the external impulse ----
float extSpan = impExt.ok() ? math.abs(impExt.e - impExt.o) : na
bool  pullOn  = impExt.ok() and not na(retrExt) and retrExt >= pbMin and retrExt < pbMax
float pbEdge  = pullOn ? impExt.e - impExt.dir * pbMin * extSpan : na   // shallow edge of the band
var int pullB  = na     // last bar that traded inside the band
var int sigKey = na     // extreme bar of the external impulse whose pullback already fired
if impExt.isNew
    pullB := na
if pullOn and (impExt.dir == 1 ? srcL <= pbEdge : srcH >= pbEdge)
    pullB := bar_index
bool  pullRecent = pullOn and not na(pullB) and bar_index - pullB <= trigWin
bool  pullDone   = not na(sigKey) and sigKey == impExt.eb
bool  buyTrend   = canSig and sigTrend and pullRecent and not pullDone and trendUp and fastBull
bool  sellTrend  = canSig and sigTrend and pullRecent and not pullDone and trendDn and fastBear

// ---- countertrend: sweep, then the fast MACD turns against it ----
var int   ctB   = na    // bar of the sweep that armed the setup
var int   ctDir = 0     // -1 sell after a high sweep, +1 buy after a low sweep
var float ctSL  = na    // wick extreme of the sweep
var float ctLvl = na    // level that was swept
if canSig and sigCT and sweepNow and (not ctDiv or swDiv)
    ctB   := bar_index
    ctDir := swIsHigh ? -1 : 1
    ctSL  := swWick
    ctLvl := swPrice
// the setup dies when the window runs out or price goes past the sweep wick
if ctDir != 0 and (bar_index - ctB > trigWin or (ctDir == -1 ? high > ctSL : low < ctSL))
    ctDir := 0
bool  buyCT  = canSig and ctDir == 1  and fastBull and close > ctLvl
bool  sellCT = canSig and ctDir == -1 and fastBear and close < ctLvl

// ---- one signal per bar, with its stop and target ----
bool  longSig  = buyTrend or buyCT
bool  shortSig = sellTrend or sellCT
bool  sigTr    = buyTrend or sellTrend
float sigSL    = na
float sigTP    = na
var int    lastSigB = na
var int    lastSigD = 0
var string lastSigT = ""
var float  lastEnt  = na
var float  lastSL   = na
var float  lastTP   = na
if longSig or shortSig
    float buf  = slBuf * nz(atrVal)
    float slP  = sigTr ? (longSig ? math.min(nz(impExt.cx, low), low) - buf : math.max(nz(impExt.cx, high), high) + buf) : (longSig ? ctSL - buf : ctSL + buf)
    float risk = longSig ? close - slP : slP - close
    if risk > 0
        sigSL    := slP
        sigTP    := longSig ? close + rrTP * risk : close - rrTP * risk
        lastSigB := bar_index
        lastSigD := longSig ? 1 : -1
        lastSigT := (longSig ? "BUY" : "SELL") + (sigTr ? " · trend" : " · counter-trend")
        lastEnt  := close
        lastSL   := sigSL
        lastTP   := sigTP
    // one entry per pullback and per sweep
    if (longSig and impExt.dir == 1) or (shortSig and impExt.dir == -1)
        sigKey := impExt.eb
    if (longSig and ctDir == 1) or (shortSig and ctDir == -1)
        ctDir := 0

plotshape(buyTrend,  "Trend buy", shape.triangleup,   location.belowbar, bullCol, text = "T", textcolor = bullCol, size = size.small)
plotshape(sellTrend, "Trend sell",  shape.triangledown, location.abovebar, bearCol, text = "T", textcolor = bearCol, size = size.small)
plotshape(buyCT and not buyTrend,   "Counter-trend buy", shape.triangleup,   location.belowbar, color.new(bullCol, 40), text = "CT", textcolor = bullCol, size = size.tiny)
plotshape(sellCT and not sellTrend, "Counter-trend sell",  shape.triangledown, location.abovebar, color.new(bearCol, 40), text = "CT", textcolor = bearCol, size = size.tiny)
// the MACD values, readable in the Data Window without cluttering the price scale
plot(macdF, "Fast MACD", display = display.data_window)
plot(sigF,  "Fast signal", display = display.data_window)
plot(macdS, "Slow MACD", display = display.data_window)
plot(sigS,  "Slow signal", display = display.data_window)

// band where trend entries are looked for, and the levels of the last signal
var box   sgBand = na
var line  sgEnL  = na
var line  sgSlL  = na
var line  sgTpL  = na
var label sgSlT  = na
var label sgTpT  = na
if barstate.islast
    if not na(sgBand)
        sgBand.delete()
    if not na(sgEnL)
        sgEnL.delete()
    if not na(sgSlL)
        sgSlL.delete()
    if not na(sgTpL)
        sgTpL.delete()
    if not na(sgSlT)
        sgSlT.delete()
    if not na(sgTpT)
        sgTpT.delete()
    if showSig and sigTrend and impExt.ok() and (trendUp or trendDn)
        float bA = impExt.e - impExt.dir * pbMin * extSpan
        float bB = impExt.e - impExt.dir * pbMax * extSpan
        color bC = trendUp ? bullCol : bearCol
        sgBand := box.new(impExt.eb, math.max(bA, bB), bar_index + 10, math.min(bA, bB), xloc = xloc.bar_index, bgcolor = color.new(bC, 88), border_color = color.new(bC, 60), text = "zona T " + pbZ, text_size = size.tiny, text_color = bC, text_halign = text.align_right, text_valign = text.align_top)
    if showSig and not na(lastSigB) and bar_index - lastSigB <= 300
        int sx2 = bar_index + 10
        sgEnL := line.new(lastSigB, lastEnt, sx2, lastEnt, xloc = xloc.bar_index, color = color.gray, style = line.style_dotted)
        sgSlL := line.new(lastSigB, lastSL, sx2, lastSL, xloc = xloc.bar_index, color = bearCol, style = line.style_dashed)
        sgTpL := line.new(lastSigB, lastTP, sx2, lastTP, xloc = xloc.bar_index, color = bullCol, style = line.style_dashed)
        sgSlT := label.new(sx2, lastSL, "SL " + fmt(lastSL), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bearCol, 100), textcolor = bearCol, size = size.tiny)
        sgTpT := label.new(sx2, lastTP, "TP " + fmt(lastTP), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(bullCol, 100), textcolor = bullCol, size = size.tiny)

// =========================================================================
// 9. DRAWING
// =========================================================================
var array<line>  fibL  = array.new<line>()
var array<label> fibT  = array.new<label>()
var array<box>   vpBox = array.new<box>()
var array<line>  liqLn = array.new<line>()
var array<label> liqLb = array.new<label>()
var line  pocLn = na
var line  vahLn = na
var line  valLn = na
var label pocLb = na
var box   zoneBx = na
var box   bxInt  = na
var box   bxExt  = na
var label lbInt  = na
var label lbExt  = na
var line  ancLn  = na
var label anc0   = na
var label anc1   = na
var line  liveLn = na
var line  invLn  = na
var label invLb  = na
var line  hiLn   = na
var line  loLn   = na
var box   rngBx  = na
var label rngLb  = na

//@function Draws a fib level (retracement or projection) on the current anchor.
drawFib(float r, color c, bool isProj) =>
    float p  = isProj ? projPrice(r) : fibPrice(r)
    int   x1 = xSafe(fibFromO ? math.min(aOb, aEb) : aEb)
    int   x2 = bar_index + fibRight
    fibL.push(line.new(x1, p, x2, p, xloc = xloc.bar_index, color = c, width = fibWidth, style = isProj ? line.style_dotted : line.style_solid))
    if fibLblOn
        string t = (isProj ? "P " : "") + str.tostring(r, "#.###") + (fibPxOn ? "  " + fmt(p) : "")
        fibT.push(label.new(x2, p, t, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(c, 100), textcolor = c, size = size.small))

if barstate.islast
    while fibL.size() > 0
        line.delete(fibL.shift())
    while fibT.size() > 0
        label.delete(fibT.shift())
    while vpBox.size() > 0
        box.delete(vpBox.shift())
    while liqLn.size() > 0
        line.delete(liqLn.shift())
    while liqLb.size() > 0
        label.delete(liqLb.shift())
    if not na(pocLn)
        pocLn.delete()
    if not na(vahLn)
        vahLn.delete()
    if not na(valLn)
        valLn.delete()
    if not na(pocLb)
        pocLb.delete()
    if not na(zoneBx)
        zoneBx.delete()
    if not na(bxInt)
        bxInt.delete()
    if not na(bxExt)
        bxExt.delete()
    if not na(lbInt)
        lbInt.delete()
    if not na(lbExt)
        lbExt.delete()
    if not na(ancLn)
        ancLn.delete()
    if not na(anc0)
        anc0.delete()
    if not na(anc1)
        anc1.delete()
    if not na(liveLn)
        liveLn.delete()
    if not na(invLn)
        invLn.delete()
    if not na(invLb)
        invLb.delete()
    if not na(hiLn)
        hiLn.delete()
    if not na(loLn)
        loLn.delete()
    if not na(rngBx)
        rngBx.delete()
    if not na(rngLb)
        rngLb.delete()

    // consolidation range: only while both sides keep testing the same levels
    if showRangeBox and recHiP.size() >= 2 and recLoP.size() >= 2
        float rbHi = robustEdge(recHiP, rangeTouches)
        float rbLo = robustEdge(recLoP, rangeTouches)
        if not na(rbHi) and not na(rbLo) and rbHi > rbLo
            float rbTol = (rbHi - rbLo) * rangeTolPct / 100.0
            if allWithin(recHiP, rangeTouches, rbHi, rbTol) and allWithin(recLoP, rangeTouches, rbLo, rbTol)
                int rbH0 = firstBarOf(recHiB, rangeTouches)
                int rbL0 = firstBarOf(recLoB, rangeTouches)
                int rbB  = math.min(nz(rbH0, bar_index), nz(rbL0, bar_index))
                rngBx := box.new(xSafe(rbB), rbHi, bar_index + 5, rbLo, xloc = xloc.bar_index, bgcolor = rangeBoxCol, border_color = color.new(rangeCol, 30), border_style = line.style_solid)
                rngLb := label.new(bar_index + 5, rbHi, "RANGE " + str.tostring((rbHi - rbLo) / rbLo * 100, "#.##") + "%", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(rangeCol, 100), textcolor = rangeCol, size = size.tiny)

    // the running leg (no pivot confirmed yet)
    if drawLive and havePiv and not na(extP)
        liveLn := line.new(xSafe(lpB), lpP, xSafe(extB), extP, xloc = xloc.bar_index, color = dir == 1 ? bullCol : bearCol, width = zzWidth, style = line.style_dashed)

    // external degree: outline only, for context
    if impExt.ok() and showBoxExt
        bxExt := box.new(xSafe(impExt.ob), math.max(impExt.o, impExt.e), math.max(impExt.eb, bar_index), math.min(impExt.o, impExt.e), xloc = xloc.bar_index, bgcolor = color.new(extCol, 97), border_color = color.new(extCol, 40), border_style = line.style_dashed)
    if impExt.ok() and showImpLbl
        lbExt := label.new(xSafe(impExt.eb), impExt.e, "EXT " + str.tostring(impExt.pct(), "#.##") + "%", xloc = xloc.bar_index, style = impExt.dir == 1 ? label.style_label_down : label.style_label_up, color = color.new(extCol, 20), textcolor = color.white, size = size.tiny)

    // internal degree: the working impulse
    color intCol = impInt.dir == 1 ? bullCol : bearCol
    if impInt.ok() and showBoxInt
        bxInt := box.new(xSafe(impInt.ob), math.max(impInt.o, impInt.e), math.max(impInt.eb, bar_index), math.min(impInt.o, impInt.e), xloc = xloc.bar_index, bgcolor = color.new(intCol, 90), border_color = color.new(intCol, 40))
    if impInt.ok() and showImpLbl
        string txt = (impInt.dir == 1 ? "Bullish impulse" : "Bearish impulse") + "  " + str.tostring(impInt.pct(), "#.##") + "%  |  " + str.tostring(impInt.legs) + (impInt.legs == 1 ? " leg" : " legs")
        lbInt := label.new(xSafe(impInt.eb), impInt.e, txt, xloc = xloc.bar_index, style = impInt.dir == 1 ? label.style_label_down : label.style_label_up, color = color.new(intCol, 10), textcolor = color.white, size = size.small)

    // the fib anchor
    if aOk and showAnchor
        ancLn := line.new(xSafe(aOb), aO, xSafe(aEb), aE, xloc = xloc.bar_index, color = anchorCol, width = 2, style = line.style_dotted)
        anc0  := label.new(xSafe(aEb), aE, "0", xloc = xloc.bar_index, style = label.style_label_center, color = color.new(anchorCol, 20), textcolor = color.black, size = size.tiny)
        anc1  := label.new(xSafe(aOb), aO, "1", xloc = xloc.bar_index, style = label.style_label_center, color = color.new(anchorCol, 20), textcolor = color.black, size = size.tiny)

    // fib levels
    if aOk and showFib
        if showZone
            zoneBx := box.new(xSafe(fibFromO ? math.min(aOb, aEb) : aEb), zTop, bar_index + fibRight, zBot, xloc = xloc.bar_index, bgcolor = zoneCol, border_color = color.new(zoneCol, 100))
        if r1On
            drawFib(r1V, r1C, false)
        if r2On
            drawFib(r2V, r2C, false)
        if r3On
            drawFib(r3V, r3C, false)
        if r4On
            drawFib(r4V, r4C, false)
        if r5On
            drawFib(r5V, r5C, false)
        if r6On
            drawFib(r6V, r6C, false)
        if r7On
            drawFib(r7V, r7C, false)
        if r8On
            drawFib(r8V, r8C, false)
        if showProj
            if p1On
                drawFib(p1V, p1C, true)
            if p2On
                drawFib(p2V, p2C, true)
            if p3On
                drawFib(p3V, p3C, true)

    // histogram of the impulse volume profile
    if vpDraw and not na(vpMax) and vpMax > 0 and not na(vpLo)
        float vStep = (vpHi - vpLo) / vpBins
        for i = 0 to vpBins - 1
            int w = int(math.round(vpWidth * vpArr.get(i) / vpMax))
            if w >= 1
                bool isPoc = not na(pocP) and pocP >= vpLo + i * vStep and pocP < vpLo + (i + 1) * vStep
                vpBox.push(box.new(vpB0, vpLo + (i + 1) * vStep, vpB0 + w, vpLo + i * vStep, xloc = xloc.bar_index, bgcolor = isPoc ? color.new(pocCol, 70) : vpCol, border_color = color.new(color.gray, 100)))

    // POC / VAH / VAL extended up to the Fib zone, to spot confluences
    if showVA and not na(pocP)
        int vx2 = bar_index + fibRight
        pocLn := line.new(vpB0, pocP, vx2, pocP, xloc = xloc.bar_index, color = pocCol, width = 2)
        pocLb := label.new(vx2, pocP, "POC " + fmt(pocP) + (na(pocFib) ? "" : "  (fib " + str.tostring(pocFib, "#.##") + ")"), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(pocCol, 100), textcolor = pocCol, size = size.small)
        vahLn := line.new(vpB0, vahP, vx2, vahP, xloc = xloc.bar_index, color = vaCol, style = line.style_dashed)
        valLn := line.new(vpB0, valP, vx2, valP, xloc = xloc.bar_index, color = vaCol, style = line.style_dashed)

    // confirmed sweeps and still untouched liquidity
    if showSweep and liqs.size() > 0
        int drawn = 0
        for i = liqs.size() - 1 to 0
            Liq lq = liqs.get(i)
            if lq.state == 2 and not na(lq.eventBar) and bar_index - lq.eventBar <= 300
                liqLb.push(label.new(xSafe(lq.pierceBar), lq.price, "SWEEP", xloc = xloc.bar_index, style = lq.isHigh ? label.style_label_down : label.style_label_up, color = color.new(sweepCol, 20), textcolor = color.white, size = size.tiny))
                liqLn.push(line.new(xSafe(lq.bar), lq.price, xSafe(lq.eventBar), lq.price, xloc = xloc.bar_index, color = sweepCol, style = line.style_dotted))
            else if showLiqLn and lq.state <= 1 and drawn < liqShow
                drawn += 1
                liqLn.push(line.new(xSafe(lq.bar), lq.price, bar_index + 5, lq.price, xloc = xloc.bar_index, color = color.new(liqCol, 30), style = line.style_dotted))
                liqLb.push(label.new(bar_index + 5, lq.price, lq.isHigh ? "liq ↑" : "liq ↓", xloc = xloc.bar_index, style = label.style_label_left, color = color.new(liqCol, 100), textcolor = liqCol, size = size.tiny))

    // structure levels
    if showRange and not na(lastHiP)
        hiLn := line.new(xSafe(lastHiB), lastHiP, bar_index + levExtend, lastHiP, xloc = xloc.bar_index, color = rangeCol, style = lineStyle(levStyleS))
    if showRange and not na(lastLoP)
        loLn := line.new(xSafe(lastLoB), lastLoP, bar_index + levExtend, lastLoP, xloc = xloc.bar_index, color = rangeCol, style = lineStyle(levStyleS))
    if showInval
        float ivP = na
        int   ivB = na
        bool  ivUp = impInt.dir == 1
        if impInt.dir != 0 and not na(impInt.pb)
            ivP := impInt.pb
            ivB := impInt.pbb
        else if structDir != 0
            ivUp := structDir == 1
            ivP  := structDir == 1 ? lastLoP : lastHiP
            ivB  := structDir == 1 ? lastLoB : lastHiB
        if not na(ivP)
            invLn := line.new(xSafe(ivB), ivP, bar_index + levExtend, ivP, xloc = xloc.bar_index, color = invalCol, width = 2, style = lineStyle(levStyleS))
            invLb := label.new(bar_index + levExtend, ivP, (ivUp ? "Impulse ends < " : "Impulse ends > ") + fmt(ivP), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(invalCol, 100), textcolor = invalCol, size = size.tiny)

// =========================================================================
// 10. PANEL
// =========================================================================
tblPos  = tblPosS == "Top right" ? position.top_right : tblPosS == "Top left" ? position.top_left : tblPosS == "Bottom right" ? position.bottom_right : position.bottom_left
tblSize = tblSizeS == "Tiny" ? size.tiny : tblSizeS == "Small" ? size.small : size.normal
bool compact = tblMode == "Compact"
bool sigMode = tblMode == "Signals"
var table pnl = table.new(tblPos, sigMode ? 2 : compact ? 4 : 3, sigMode ? 7 : compact ? 2 : 12, border_width = 1, frame_width = 1, frame_color = color.new(color.gray, 50), border_color = color.new(color.gray, 70))

// ---- signals panel: what the double MACD setup has, and what it is still missing ----
if showTable and sigMode and barstate.islast
    color  bgC   = color.new(#131722, 10)
    color  lbC   = #b2b5be
    color  hdC   = color.new(anchorCol, 40)
    int    sDir  = slowBull ? 1 : slowBear ? -1 : 0
    string trTxt = trendUp ? "▲ BULLISH" : trendDn ? "▼ BEARISH" : "◆ MIXED"
    color  trCol = trendUp ? bullCol : trendDn ? bearCol : color.gray
    string trTip = "External impulse " + (impExt.dir == 1 ? "bullish" : impExt.dir == -1 ? "bearish" : "undefined") + " and slow MACD (" + slowTfE + ") " + (sDir == 1 ? "bullish" : sDir == -1 ? "bearish" : "neutral") + ".\nWhen they agree, with-trend entries are looked for on pullbacks. On MIXED only counter-trend setups are left."
    string moTip = "Fast MACD (" + timeframe.period + "): this is the trigger. An entry fires when it turns the way of the trade."
    string pbTxt = pullOn ? "Pullback " + str.tostring(retrExt * 100, "#") + "% (zone " + pbZ + ")" : ""
    string ctLeft = na(ctB) ? "" : str.tostring(trigWin - (bar_index - ctB))
    string suTxt = ctDir == -1 ? "High swept at " + fmt(ctLvl) + (swDiv ? " + divergence" : "") + "\n→ CT sell if fast MACD ▼ (" + ctLeft + " candles)" : ctDir == 1 ? "Low swept at " + fmt(ctLvl) + (swDiv ? " + divergence" : "") + "\n→ CT buy if fast MACD ▲ (" + ctLeft + " candles)" : pullOn and pullDone ? pbTxt + "\nsignal already fired on this pullback" : pullOn and not (trendUp or trendDn) ? pbTxt + "\nslow MACD against: stand aside" : pullOn and not pullRecent ? pbTxt + "\nprice left the zone without a trigger" : pullOn ? pbTxt + (trendUp ? "\n→ buy if fast MACD ▲" : "\n→ sell if fast MACD ▼") : "No setup: wait"
    string suTip = "Trend (T): the external impulse retraces into the " + pbZ + " zone with the trend in favour, and the fast MACD turns within " + str.tostring(trigWin) + " candles.\nCounter-trend (CT): a wick takes out a pivot and closes back inside" + (ctDiv ? " with divergence on the fast MACD" : "") + ", and the fast MACD turns against the sweep."
    string sgTxt = na(lastSigB) ? "—" : lastSigT + "\n" + str.tostring(bar_index - lastSigB) + (bar_index - lastSigB == 1 ? " candle ago" : " candles ago")
    color  sgCol = lastSigD == 1 ? bullCol : lastSigD == -1 ? bearCol : color.gray
    string lvTxt = na(lastSigB) ? "—" : "Entry " + fmt(lastEnt) + "\nSL " + fmt(lastSL) + "   TP " + fmt(lastTP)
    string vEs   = verdict == "ACCEPTANCE - continuation" ? "✓ Acceptance: continuation" : verdict == "No acceptance - weak" ? "? No acceptance: weak" : verdict == "SWEPT - no acceptance" ? "✕ Swept, no acceptance: trap" : verdict == "Swept but with acceptance (mixed)" ? "≈ Swept with acceptance: mixed" : "—"
    color  vCol  = extIsSweep and not accepted ? sweepCol : extIsSweep ? pocCol : accepted ? bullCol : color.gray
    string vTip  = "Measured on the impulse the Fib is anchored to.\n✓ the impulse traded its volume in the half nearest the extreme (POC at fib <= 0.5): the market accepted those prices.\n✕ the extreme was made by sweeping stops and the volume stayed near the origin: a possible trap, which favours a reversal.\nInformational only: computed on the last bar, it does not feed the signals."
    table.cell(pnl, 0, 0, "SIGNALS", text_color = color.white, bgcolor = hdC, text_size = tblSize)
    table.cell(pnl, 1, 0, "MACD " + timeframe.period + " / " + slowTfE, text_color = color.white, bgcolor = hdC, text_size = tblSize)
    table.cell(pnl, 0, 1, "Trend", text_color = lbC, bgcolor = bgC, text_size = tblSize, tooltip = trTip)
    table.cell(pnl, 1, 1, trTxt, text_color = trCol, bgcolor = bgC, text_size = tblSize, text_halign = text.align_left, tooltip = trTip)
    table.cell(pnl, 0, 2, "Trigger", text_color = lbC, bgcolor = bgC, text_size = tblSize, tooltip = moTip)
    table.cell(pnl, 1, 2, fastBull ? "▲ Fast MACD bullish" : "▼ Fast MACD bearish", text_color = fastBull ? bullCol : bearCol, bgcolor = bgC, text_size = tblSize, text_halign = text.align_left, tooltip = moTip)
    table.cell(pnl, 0, 3, "Setup", text_color = lbC, bgcolor = bgC, text_size = tblSize, tooltip = suTip)
    table.cell(pnl, 1, 3, suTxt, text_color = color.white, bgcolor = bgC, text_size = tblSize, text_halign = text.align_left, tooltip = suTip)
    table.cell(pnl, 0, 4, "Last signal", text_color = lbC, bgcolor = bgC, text_size = tblSize)
    table.cell(pnl, 1, 4, sgTxt, text_color = sgCol, bgcolor = bgC, text_size = tblSize, text_halign = text.align_left)
    table.cell(pnl, 0, 5, "Levels", text_color = lbC, bgcolor = bgC, text_size = tblSize)
    table.cell(pnl, 1, 5, lvTxt, text_color = color.white, bgcolor = bgC, text_size = tblSize, text_halign = text.align_left)
    table.cell(pnl, 0, 6, "Quality", text_color = lbC, bgcolor = bgC, text_size = tblSize, tooltip = vTip)
    table.cell(pnl, 1, 6, vEs, text_color = vCol, bgcolor = bgC, text_size = tblSize, text_halign = text.align_left, tooltip = vTip)

// ---- compact panel: four icons, the detail lives in the tooltips ----
if showTable and compact and barstate.islast and impInt.dir != 0
    color  cI = impInt.dir == 1 ? bullCol : bearCol
    color  cE = impExt.dir == 1 ? bullCol : impExt.dir == -1 ? bearCol : color.gray
    string aI = impInt.dir == 1 ? "▲" : "▼"
    string aE = impExt.dir == 1 ? "▲" : impExt.dir == -1 ? "▼" : "•"
    string vIco = extIsSweep and not accepted ? "✕" : extIsSweep ? "≈" : accepted ? "✓" : "?"
    color  vCol = extIsSweep and not accepted ? sweepCol : extIsSweep ? pocCol : accepted ? bullCol : color.gray
    string zTxt = str.tostring(zoneA, "#.###") + "-" + str.tostring(zoneB, "#.###")
    string tipE = "Context (external degree): " + (impExt.dir == 1 ? "bullish" : impExt.dir == -1 ? "bearish" : "undefined") + "\n" + fmt(impExt.o) + "  ->  " + fmt(impExt.e) + "   (" + str.tostring(impExt.pct(), "#.##") + "%)"
    string tipI = (impInt.dir == 1 ? "Bullish" : "Bearish") + " internal impulse, " + str.tostring(impInt.pct(), "#.##") + "% over " + str.tostring(impInt.legs) + (impInt.legs == 1 ? " leg" : " legs") + "\n" + fmt(impInt.o) + "  ->  " + fmt(impInt.e) + "\nMax retracement " + (na(retrInt) ? "-" : str.tostring(retrInt * 100, "#.#") + "%") + "\n" + stateTxt(retrInt, thrIntE, impInt.dir, dir, brokeInt)
    string tipZ = (inZone ? "Price is INSIDE the Fib zone " : "Price is outside the Fib zone ") + zTxt
    string tipV = verdict + (na(pocFib) ? "" : "\nPOC at fib " + str.tostring(pocFib, "#.##") + " (" + fmt(pocP) + (vpSrcTxt == "" ? "" : ", from " + vpSrcTxt) + ")") + (extIsSweep ? "\nThe extreme was made by sweeping liquidity" : "")
    table.cell(pnl, 0, 0, "EXT", text_color = color.gray, text_size = size.tiny, tooltip = tipE)
    table.cell(pnl, 1, 0, "INT", text_color = color.gray, text_size = size.tiny, tooltip = tipI)
    table.cell(pnl, 2, 0, "ZONE", text_color = color.gray, text_size = size.tiny, tooltip = tipZ)
    table.cell(pnl, 3, 0, "VER", text_color = color.gray, text_size = size.tiny, tooltip = tipV)
    table.cell(pnl, 0, 1, aE, text_color = cE, text_size = tblSize, tooltip = tipE)
    table.cell(pnl, 1, 1, aI, text_color = cI, text_size = tblSize, tooltip = tipI)
    table.cell(pnl, 2, 1, inZone ? "●" : "○", text_color = inZone ? pocCol : color.new(color.gray, 40), text_size = tblSize, tooltip = tipZ)
    table.cell(pnl, 3, 1, vIco, text_color = color.white, bgcolor = color.new(vCol, 25), text_size = tblSize, tooltip = tipV)

if showTable and tblMode == "Full" and barstate.islast and impInt.dir != 0
    color  cInt = impInt.dir == 1 ? bullCol : bearCol
    string sInt = stateTxt(retrInt, thrIntE, impInt.dir, dir, brokeInt)
    string sExt = stateTxt(retrExt, thrExtE, impExt.dir, dir, false)
    table.cell(pnl, 0, 0, fibSrc == "External impulse" ? "FIB: EXT" : "FIB: INT", text_color = color.white, bgcolor = color.new(anchorCol, 40), text_size = tblSize)
    table.cell(pnl, 1, 0, "INTERNAL", text_color = color.white, bgcolor = color.new(cInt, 20), text_size = tblSize)
    table.cell(pnl, 2, 0, "EXTERNAL", text_color = color.white, bgcolor = color.new(extCol, 20), text_size = tblSize)
    table.cell(pnl, 0, 1, "Direction", text_color = color.gray, text_size = tblSize)
    table.cell(pnl, 1, 1, impInt.dir == 1 ? "BULLISH" : "BEARISH", text_color = cInt, text_size = tblSize)
    table.cell(pnl, 2, 1, impExt.dir == 0 ? "-" : impExt.dir == 1 ? "BULLISH" : "BEARISH", text_color = color.new(color.white, 20), text_size = tblSize)
    table.cell(pnl, 0, 2, "Origin (fib 1)", text_color = color.gray, text_size = tblSize)
    table.cell(pnl, 1, 2, fmt(impInt.o), text_color = color.white, text_size = tblSize)
    table.cell(pnl, 2, 2, fmt(impExt.o), text_color = color.new(color.white, 20), text_size = tblSize)
    table.cell(pnl, 0, 3, "Extreme (fib 0)", text_color = color.gray, text_size = tblSize)
    table.cell(pnl, 1, 3, fmt(impInt.e), text_color = color.white, text_size = tblSize)
    table.cell(pnl, 2, 3, fmt(impExt.e), text_color = color.new(color.white, 20), text_size = tblSize)
    table.cell(pnl, 0, 4, "From", text_color = color.gray, text_size = tblSize)
    table.cell(pnl, 1, 4, fmtTime(impInt.ot), text_color = color.white, text_size = tblSize)
    table.cell(pnl, 2, 4, fmtTime(impExt.ot), text_color = color.new(color.white, 20), text_size = tblSize)
    table.cell(pnl, 0, 5, "Size / legs", text_color = color.gray, text_size = tblSize)
    table.cell(pnl, 1, 5, str.tostring(impInt.pct(), "#.##") + "%  /  " + str.tostring(impInt.legs), text_color = color.white, text_size = tblSize)
    table.cell(pnl, 2, 5, str.tostring(impExt.pct(), "#.##") + "%  /  " + str.tostring(impExt.legs), text_color = color.new(color.white, 20), text_size = tblSize)
    table.cell(pnl, 0, 6, "Max retracement", text_color = color.gray, text_size = tblSize)
    table.cell(pnl, 1, 6, na(retrInt) ? "-" : str.tostring(retrInt * 100, "#.#") + "%", text_color = not na(retrInt) and retrInt >= thrIntE ? bearCol : color.white, text_size = tblSize)
    table.cell(pnl, 2, 6, na(retrExt) ? "-" : str.tostring(retrExt * 100, "#.#") + "%", text_color = color.new(color.white, 20), text_size = tblSize)
    table.cell(pnl, 0, 7, "State", text_color = color.gray, text_size = tblSize)
    table.cell(pnl, 1, 7, sInt, text_color = color.white, text_size = tblSize)
    table.cell(pnl, 2, 7, sExt, text_color = color.new(color.white, 20), text_size = tblSize)
    table.cell(pnl, 0, 8, "Setting", text_color = color.gray, text_size = tblSize)
    table.cell(pnl, 1, 8, settingTxt, text_color = color.new(color.white, 30), text_size = tblSize)
    table.cell(pnl, 2, 8, isCustom ? "Custom" : preset, text_color = color.new(color.white, 30), text_size = tblSize)
    // --- anchor validation: sweep vs acceptance ---
    table.cell(pnl, 0, 9, "Extreme swept", text_color = color.gray, text_size = tblSize)
    table.cell(pnl, 1, 9, not showSweep ? "off" : extIsSweep ? "YES — took liquidity" : "no", text_color = extIsSweep ? sweepCol : color.white, text_size = tblSize)
    table.cell(pnl, 2, 9, na(swPrice) ? "" : "last " + fmt(swPrice), text_color = color.new(color.white, 30), text_size = tblSize)
    table.cell(pnl, 0, 10, "Impulse POC" + (vpSrcTxt == "" ? "" : " (" + vpSrcTxt + ")"), text_color = color.gray, text_size = tblSize)
    table.cell(pnl, 1, 10, na(pocP) ? "-" : fmt(pocP), text_color = color.white, text_size = tblSize)
    table.cell(pnl, 2, 10, na(pocFib) ? "" : "fib " + str.tostring(pocFib, "#.##"), text_color = accepted ? bullCol : bearCol, text_size = tblSize)
    table.cell(pnl, 0, 11, "Verdict", text_color = color.gray, text_size = tblSize)
    table.cell(pnl, 1, 11, verdict, text_color = extIsSweep and not accepted ? sweepCol : accepted ? bullCol : color.white, text_size = tblSize)
    table.cell(pnl, 2, 11, "", text_size = tblSize)

// =========================================================================
// 11. ALERTS
// =========================================================================
bool intNew   = impInt.isNew
bool intEnded = impInt.ended
bool extNew   = impExt.isNew
alertcondition(intNew,    "New internal impulse",      "New internal impulse confirmed on {{ticker}} ({{interval}})")
alertcondition(intEnded,  "Internal impulse finished", "The internal impulse on {{ticker}} has finished")
alertcondition(extNew,    "New external impulse",      "New external impulse confirmed on {{ticker}} ({{interval}})")
alertcondition(zoneEntry, "Price in Fib zone",         "{{ticker}} has entered the Fibonacci retracement zone")
alertcondition(pivNew,    "New ZigZag pivot",          "New pivot confirmed on {{ticker}} ({{interval}})")
alertcondition(sweepNow,  "Liquidity sweep",           "{{ticker}} swept a liquidity level: wick outside and close back inside")

// ---- trade signals (double MACD) ----
alertcondition(buyTrend,  "Trend buy",              "{{ticker}} ({{interval}}): with-trend BUY (pullback + double MACD) at {{close}}")
alertcondition(sellTrend, "Trend sell",             "{{ticker}} ({{interval}}): with-trend SELL (pullback + double MACD) at {{close}}")
alertcondition(buyCT,     "Counter-trend buy",      "{{ticker}} ({{interval}}): counter-trend BUY (low swept + fast MACD) at {{close}}")
alertcondition(sellCT,    "Counter-trend sell",     "{{ticker}} ({{interval}}): counter-trend SELL (high swept + fast MACD) at {{close}}")
alertcondition(longSig,   "Buy (any)",              "{{ticker}} ({{interval}}): BUY at {{close}}")
alertcondition(shortSig,  "Sell (any)",             "{{ticker}} ({{interval}}): SELL at {{close}}")

// one JSON message per signal, for a webhook bridge (exchange bot, own server...)
if whOn and not na(sigSL)
    string js = '{"symbol":"' + syminfo.ticker + '","exchange":"' + syminfo.prefix + '","side":"' + (longSig ? "buy" : "sell") + '","setup":"' + (sigTr ? "trend" : "counter") + '","tf":"' + timeframe.period + '","price":' + fmt(close) + ',"sl":' + fmt(sigSL) + ',"tp":' + fmt(sigTP) + ',"rr":' + str.tostring(rrTP) + '}'
    alert(js, alert.freq_once_per_bar_close)
````
