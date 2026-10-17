# Kalman Velocity Ribbon [NovaLens]

- url: https://www.tradingview.com/script/4xGY44PY-Kalman-Velocity-Ribbon-NovaLens/
- type: indicator
- pine_id: PUB;992bbde464444018aa31d7b4b2e0a9b2
- version: 1.0

## Description

Kalman Velocity Ribbon tracks the trend and how fast it is moving, as two separate Kalman estimates rather than one smoothed line.
It uses that speed to show how strong a trend is, to mark the closed candle where a new trend is confirmed, and to say in plain words what the last candle shows.

Trends move in legs: the pace builds and eases, and the lower pane shows that pace candle by candle, without forecasting the turn. Many Kalman scripts stop at a smoothed line or an oscillator of the gap to price. Here the speed is the core of the tool: it colours the line by strength, it decides when a trend is confirmed, and it fills the ribbon in the lower pane. You get one answer at a glance: is there a trend, which way, and is it strong or weak. It describes the trend. It never tells you to buy or sell.


════════════════════════════════════════════


◉ [b]HOW IT WORKS[/b]

[b]Two estimates, not one line.[/b] A Kalman filter is a method from engineering for tracking something you can only measure with noise; Rudolf Kalman published it in 1960. Here it keeps two estimates of the trend: its price level (the line you see on the chart) and its velocity, the filter's own estimate of how fast the trend moves per candle. Velocity is kept separately from the line, so on a surprising close the line can step one way while velocity still points the other. On every close it predicts where the trend should be, compares that with the actual close, and corrects both estimates by how surprising the close was.

[b]Calmer when the market is wild.[/b] The filter's noise settings follow volatility. When ATR rises above its own recent average, the filter trusts each single close less and follows more slowly. Big moves still move the line; it just leans less on any single close. When the market is quiet, it follows price more closely.

[b]Speed in ATR, so every chart reads the same.[/b] Velocity is divided by the previous candle's ATR(14), the usual average true range (it counts gaps too). A reading of +0.15 means the filter estimates the trend moving up by 0.15 ATR per bar. That puts BTC, SPY and EURUSD on one scale, so the same strength tests mean the same thing everywhere.

[b]What makes a trend strong.[/b] The line is bright only when all three tests pass on the candle:
[list]
[*][b]It moves clearly[/b] - velocity is beyond 0.15 ATR per bar.
[*][b]Price agrees[/b] - the close is more than 0.3 ATR past the line, on the side velocity points.
[*][b]It is not running out of steam[/b] - the speed has not shrunk three closes in a row.
[/list]
If any test fails, the line dims. The panel's tooltip names the one that failed.

[b]When a trend is confirmed.[/b] A ▲ prints on the first closed candle where velocity is above +0.15 ATR per bar and the close sits more than 0.3 ATR above the line, after the last confirmed downtrend. ▼ is the mirror. One mark per turn: no repeats while the trend holds, and nothing on the candle that is still forming.


════════════════════════════════════════════


◈ [b]HOW TO READ IT[/b]

Colour first, then the triangles, then the panel.

[b]The line on price.[/b]
[list]
[*][b]Bright teal = strong uptrend[/b] - velocity points up clearly, price is well above the line, and the speed has not shrunk three closes in a row.
[*][b]Dim teal = weak uptrend[/b] - still up, but slow, or price is not clearly above the line, or the speed keeps shrinking.
[*][b]Bright red / dim red[/b] - the same reads for a downtrend.
[*][b]Grey = no reading[/b] - warm-up, bad data, or velocity of exactly zero. Grey is not a flat trend.
[/list]
The colour follows velocity, so after a sharp surprise the line can dip for a candle or two while it is still teal. Bright is strict on purpose. On BTCUSDT 1D about one candle in nine reads bright: it marks the candles where the push is clear, and dim is the normal state of a trend.

[b]The triangles.[/b]
[list]
[*][b]▲ Uptrend Confirmed[/b] - below the candle that confirmed a new uptrend.
[*][b]▼ Downtrend Confirmed[/b] - above the candle that confirmed a new downtrend.
[*]Hover a triangle for its date, the speed at that close and why it printed.
[/list]
Triangles mark a confirmed trend, not the top or bottom: they wait until the closed-candle tests pass, so they usually print after the turn.

[b]The ribbon (lower pane).[/b] The pane plots velocity in ATR per bar. Above zero velocity points up, below zero it points down, and the distance from zero is the speed. The ribbon is the band between velocity and its 5-bar average, in the line's colour, so you see at a glance whether the pace is running ahead of its recent average or falling behind it. Values are drawn within +/-5. Area and Columns styles are in the settings.

[b]The Reading panel.[/b] Top right of the pane, always from the last closed candle:
[list]
[*][b]Kalman Velocity: Trending up / Trending down[/b] - which way velocity points, in teal or red.
[*][b]Trend strength: Strong / Weak[/b] - Strong when all three tests pass. Hover Weak to see which test failed.
[*][b]Trend age[/b] - how many closed candles in a row velocity has pointed the same way.
[/list]
The panel follows velocity's direction on every candle, while the triangles mark only confirmed turns, so the panel can read Trending up before a ▲ prints. Before there is a reading it shows Waiting, Warming up, No trend or No reading, with - in both rows.


════════════════════════════════════════════


✦ [b]HOW WE USE IT: SPEED FIRST, THEN DIRECTION[/b]

BTCUSDT on the daily chart, January to June 2026, default settings:

[list]
[*][b]14 to 17 January.[/b] Price is still above 95,000 and the line is still teal, but the pane shows the speed draining from +0.66 to +0.05 ATR per bar in four candles. The trend is losing its push before it changes direction.
[*][b]18 January: ▼ Downtrend Confirmed[/b] at a close near 93,700.
[*][b]Late January to 5 February.[/b] Apart from two teal days in late January, the line stays red down to the 5 February close near 62,900, bright on the hardest down days and dim in between. The pane reaches -1.11 ATR per bar on 5 February, its fastest fall of the move.
[*][b]6 February to 31 March.[/b] Velocity stays between about -0.48 and +0.44 ATR per bar, and the line flips between teal and red every few days, mostly dim. That is the tool saying there is no clean trend. A ▲ (2 March) and a ▼ (27 March) print in this stretch, and each time the line turned the other way within four days.
[*][b]7 April: ▲ Uptrend Confirmed[/b] at a close near 71,900, with the pane at +0.47. The line stays mostly teal as price climbs to 82,000 in May.
[*][b]22 May: ▼ Downtrend Confirmed[/b], and the line turns bright red on the early June drop below 65,000.
[/list]

Draining speed is not a turn: many fades recover and the trend carries on. The triangle is the part that tells you the other side has taken over, on a closed candle. Read the two together: the pane for the pace, the triangle for the confirmed change.


════════════════════════════════════════════


✦ [b]OTHER APPLICATIONS[/b]

[list]
[*][b]Trend context for another system[/b] - check the panel's direction and strength before you read another tool's signal, so you know whether it comes with a strong trend, a weak one or none.
[*][b]Range spotting[/b] - frequent colour flips, a mostly dim line and a ribbon hugging zero describe a market without a clean trend.
[*][b]Fading watch[/b] - a long Trend age with Weak strength and a shrinking speed describes a trend that is still running but losing its push.
[*][b]Alert-driven workflow[/b] - subscribe to the confirmed trend alerts and look at the chart only when a new trend is confirmed.
[/list]


════════════════════════════════════════════


⚙ [b]GETTING STARTED[/b]

Add it, leave Horizon on Auto, and read the colour. Auto picks the profile from your timeframe.

[b]Horizon:[/b]
[list]
[*][b]Auto[/b] (default) - Intraday below 4h, Swing from 4h through 1D, Position above 1D.
[*][b]Intraday[/b] reacts fastest, [b]Swing[/b] is balanced, [b]Position[/b] is the slowest.
[*][b]Custom[/b] - unlocks ATR Period and Volatility Sensitivity, and the Advanced noise settings.
[/list]

[b]Signals:[/b] Show qualified trend marks on price (on); Show unconfirmed crosses on price, Show marks in the velocity pane, Show legacy event marks in the pane (all off).
[b]Display:[/b] Show Reading panel, Theme (Auto, Dark, Light), Panel position (five spots; the TradingView logo can cover Bottom left), Pane style (Ribbon, Area, Columns), Glow, Show trend line on price.
[b]Advanced (Custom only):[/b] Process Noise Min and Max, Observation Noise Min and Max. More process noise usually follows price faster; more observation noise usually smooths.
[b]Appearance / Palette:[/b] Bullish strong, Bearish strong, Neutral, Unconfirmed cross, Bullish weak, Bearish weak.

[b]Unconfirmed crosses (optional).[/b] Turn them on to see a small blue triangle where price has already closed more than 0.3 ATR past the line while velocity has not turned yet (still zero or pointing the other way), inside a confirmed trend the other way. Price moved first; a confirmed trend may or may not follow. Once per swing.


════════════════════════════════════════════


△ [b]LIMITATIONS[/b]

[list]
[*][b]Descriptive, not predictive[/b] - it shows the trend's direction, speed and strength on closed candles. It makes no claim about the next candle and has no buy or sell signal.
[*][b]Confirmed-bar[/b] - the line, glow and pane can change before the candle closes; the panel, triangles and alerts wait for the close.
[*][b]Triangles lag the turn[/b] - they wait for the closed-candle tests, so they usually print after the top or bottom, and a confirmed trend can reverse within a few candles.
[*][b]Easy to miss in busy charts[/b] - in crowded candles a triangle can be slow to spot or may not clearly mark its candle; hover it for the date.
[*][b]Label limit[/b] - turning on a second mark type can drop older price triangles (TradingView's label limit); alerts stay the same.
[*][b]Panel placement[/b] - the panel can cover recent pane values; move it with Panel position.
[*][b]Warm-up[/b] - 4 x ATR length - 1 candles (55 on Swing, at least 15). A missing close ends readings from there. Heikin Ashi and Renko charts show No reading.
[*][b]Presets[/b] - picked on 2025 SPY, BTCUSDT and EURUSD data (1D and 4h).
[/list]


════════════════════════════════════════════


🔔 [b]ALERTS[/b]

Pick a condition in TradingView's alert dialog (needs a plan with indicator alerts). Each fires once on a confirmed close, never on the live candle, whether the marks are shown or hidden.
[list]
[*][b]Qualified Trend Up (Once Per Bar Close)[/b] - the ▲ rule; once per turn.
[*][b]Qualified Trend Down (Once Per Bar Close)[/b] - the ▼ rule.
[*][b]Unconfirmed Cross Up (Once Per Bar Close)[/b] - inside a confirmed downtrend, a close more than 0.3 ATR above the line while velocity is still zero or negative, after a clear close below it; once per swing.
[*][b]Unconfirmed Cross Down (Once Per Bar Close)[/b] - the mirror.
[/list]
On BINANCE:BTCUSDT 1D, 3,331 closed candles since August 2017, they fired 78, 78, 48 and 51 times, in list order. Observed there, not a promise.
Message: AK-01 | event | ticker | interval | close | bar time | confirmed on bar close.


════════════════════════════════════════════


⌁ [b]NOTES[/b]

[list]
[*]Method: a constant-velocity Kalman filter with ATR-adaptive process and observation noise. NovaLens adds the Horizon profiles, the strength colours, the confirmed trend marks, the Reading panel, the tooltips and the alerts.
[*]Reference: R. E. Kalman, [i]A New Approach to Linear Filtering and Prediction Problems[/i], Journal of Basic Engineering (1960).
[*]Repaint: Confirmed-bar. The panel, triangles and alerts use confirmed closes only; the line, glow and pane update on the live candle.
[*]Open-source under MPL 2.0. Free to use, fork, study.
[/list]

[b]NovaLens[/b]

## Source Code

````pine
// This Pine Script source code is subject to the Mozilla Public License 2.0.
// Copyright NovaLens
//@version=6
// Adaptive Kalman Velocity [NovaLens] | AK-01 | 1.0.0 | 2026-09
// Constant-velocity Kalman state [price, velocity]; the baseline recurrence is unchanged.
// Pane: velocity / previous ATR(14), display clipped to +/-5 ATR per bar; Ribbon adds a display-only 5-bar EMA of velocity.
// Price: 3 px Kalman line in a strong or weak tier colour (can be hidden), an optional soft glow around it, one qualified trend mark per event (a core triangle and a fainter ring on one centre, both carrying the hover text).
// Qualified Trend: velocity beyond 0.15 ATR per bar and close beyond 0.3 ATR on the same side, once per swing.
// Repaint: line, glow and pane update intrabar; panel, marks and alerts use confirmed closes only.
// Panel: the DC-01 info panel chrome from the last confirmed close: header Kalman Velocity with Trending up or Trending down, rows Trend strength and Trend age; detail lives in the cell tooltips.
// Auto resolves by timeframe; profile selection uses 2025 validation, not holdout.
// NA close permanently invalidates the state. No reseed or silent missing-data fill.
indicator("Adaptive Kalman Velocity [NovaLens]", shorttitle="Kalman Velocity [NovaLens]", overlay=false, precision=2, max_bars_back=300, max_labels_count=200)

string BRAND_NAME = "NovaLens"
string BRAND_ENTITY = "NovaLens Quantitative Research"
string productCode = "AK-01"
string productTier = "Free"

horizonInput = input.string("Auto", "Horizon", options=["Auto", "Intraday", "Swing", "Position", "Custom"], display=display.none, group="Parameters", tooltip="Choose how quickly the trend line reacts.\n\n• Auto: picks by timeframe. Intraday below 4h, Swing from 4h through 1D, Position above 1D.\n• Intraday reacts fastest and Position slowest. They measure volatility over 10, 14 and 20 chart bars.\n• Custom: unlocks six expert controls.\n\nOne choice sets the whole filter. The presets were picked on 2025 validation data. They are not a trading edge.")
custom = horizonInput == "Custom"
atrPeriodInput = input.int(14, "ATR Period", minval=1, maxval=200, display=display.none, group="Parameters", active=custom, tooltip="Sets how far back volatility is measured when Horizon is Custom.\n\nA longer lookback makes the volatility read slower. It is the Wilder average true range over this many chart bars.\n\nThe first reading needs 4 times this period minus 1 bars, at least 15. The pane scale stays on a fixed 14-bar range.")
alphaInput = input.float(0.10, "Volatility Sensitivity", minval=0.01, maxval=0.50, step=0.01, display=display.none, group="Parameters", active=custom, tooltip="Sets how much volatility changes the filter when Horizon is Custom.\n\nWhen volatility rises above its average, the filter trusts each close less and follows price more slowly. It is checked every bar. Higher sensitivity reacts more to volatility shifts.\n\nIt is not a strength or probability control.")
showMarkersInput = input.bool(false, "Show marks in the velocity pane", display=display.none, group="Signals", tooltip="Repeats the Qualified Trend and Unconfirmed Cross marks on the velocity line in the pane.\n\nLets you read events beside the velocity curve instead of on the candles. Off on a fresh chart. A stored v8 value resets to off once when you update, because the setting was renamed.\n\nHiding marks never changes alerts. Each kind of mark keeps its newest 100.")
showPriceMarksInput = input.bool(false, "Show unconfirmed crosses on price", display=display.none, group="Signals", tooltip="Shows a small triangle where price closes well past the line before the trend qualifies.\n\nIt shows price moving before the line turns. A Qualified Trend may or may not follow.\n\nWell past means more than 0.3 of the average bar range. On the six training charts, 18-36% were followed within 3 bars. Not an entry.")
showPanelInput = input.bool(true, "Show Reading panel", display=display.none, group="Display", tooltip="Shows the Reading panel: the trend direction, its strength and its age, from the last closed bar.\n\nThe one-glance read. Hover a cell to see what it means and which bar it reads.\n\nThe live line can differ before the close. No effect on alerts.")
themeInput = input.string("Auto", "Theme", options=["Auto", "Dark", "Light"], display=display.none, group="Display", tooltip="Matches the panel to your chart.\n\n• Auto: reads the chart background.\n• Dark, Light: override it.\n\nKeeps the panel and the weak colours readable on either background. Changes no calculation.")
panelPositionInput = input.string("Top right", "Panel position", options=["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], display=display.none, group="Display", tooltip="Places the Reading panel in the velocity pane.\n\nFive spots, all showing the last closed reading. Move it if it covers a peak. On a short pane the panel can hide behind the time axis. Drag the pane taller or turn the panel off.\n\nAt Bottom left, the TradingView logo can cover part of the panel. Use a Top spot.")
qMinInput = input.float(0.001, "Process Noise Min", minval=0.0001, maxval=0.1, step=0.0001, display=display.none, group="Advanced", active=custom, tooltip="Sets the lowest process noise when Horizon is Custom.\n\nIt is used every bar. Raising it usually makes the line follow price faster.\n\nMust not exceed Process Noise Max. Reversed bounds hide the plots and events.")
qMaxInput = input.float(0.1, "Process Noise Max", minval=0.01, maxval=1.0, step=0.01, display=display.none, group="Advanced", active=custom, tooltip="Sets the highest process noise when Horizon is Custom.\n\nIt is used every bar. Raising it usually makes the line follow price faster, most of all when volatility is below its usual level.\n\nMust be at least Process Noise Min. It is not a confidence score.")
rMinInput = input.float(0.5, "Observation Noise Min", minval=0.01, maxval=5.0, step=0.01, display=display.none, group="Advanced", active=custom, tooltip="Sets the lowest observation noise when Horizon is Custom.\n\nIt is used every bar. Raising it trusts each close less and usually smooths the line.\n\nMust not exceed Observation Noise Max.")
rMaxInput = input.float(2.0, "Observation Noise Max", minval=0.1, maxval=10.0, step=0.1, display=display.none, group="Advanced", active=custom, tooltip="Sets the highest observation noise when Horizon is Custom.\n\nIt is used every bar. Raising it calms the line more when volatility runs above its usual level.\n\nMust be at least Observation Noise Min.")

string paneStyleTip = "Choose how the velocity pane is drawn.\n\n• Ribbon: velocity and its smoothed average, with the gap shaded in the current strength-tier colour.\n• Area: velocity with three fading colour layers to zero.\n• Columns: one column per bar for comparing bar-by-bar size.\n\nVelocity is signed and uses the previous ATR(14) to express speed in ATR per bar. Both ribbon lines are clipped at +/-5 for drawing only. The style changes no engine calculation or alert."
string slowLineTip = "The thin Velocity average line is a 5-bar EMA of velocity, weighted toward newer bars with older values fading gradually.\n\nThe gap shows whether current signed velocity is above or below its recent smoothed value. This is not the price line's slope or a separate confirmation of the panel's strength reading.\n\nThe live lines can move before the bar closes; the panel reads a confirmed close. A cross is not a signal: it is not tested and fires no mark or alert."
paneStyleInput = input.string("Ribbon", "Pane style", options=["Ribbon", "Area", "Columns"], display=display.none, group="Display", tooltip=paneStyleTip + "\n\n" + slowLineTip)
showTurnsInput = input.bool(false, "Show legacy event marks in the pane", display=display.none, group="Signals", tooltip="Shows the older v8 cross mark as a small ◆ on the velocity line in the pane.\n\nOff by default. Kept for users who relied on the v8 pane read.\n\nAdds about 11-19 marks per 200 bars. Hiding marks never changes alerts.")
// Palette: a strong and a weak tier per direction; Light theme swaps untouched defaults for the light column.
bullish = input.color(#00E6B4, "Bullish strong", group="Appearance / Palette", display=display.none, tooltip="Colour for a strong rise: the line climbs clearly, price agrees and the line is not steadily slowing.\n\nIt colours the line, glow, pane, marks and panel. Bright means the up read is complete. The panel shows Trending up in this colour, or a shade of it where the background needs more contrast. Its Trend strength row says Strong or Weak.\n\nColour describes the trend. It is not a trade call.")
bearish = input.color(#FF504B, "Bearish strong", group="Appearance / Palette", display=display.none, tooltip="Colour for a strong fall: the line drops clearly, price agrees and the line is not steadily slowing.\n\nIt colours the line, glow, pane, marks and panel. Bright means the down read is complete. The panel shows Trending down in this colour, or a shade of it where the background needs more contrast. Its Trend strength row says Strong or Weak.\n\nColour describes the trend. It is not a trade call.")
neutral = input.color(#787B86, "Neutral", group="Appearance / Palette", display=display.none, tooltip="Colour for a line with exactly zero speed, warm-up and invalid data.\n\nGrey means no read, not a flat trend.\n\nFading is shown by the weak colours, not by this one.")
eventColor = input.color(#42A5F5, "Unconfirmed cross", group="Appearance / Palette", display=display.none, tooltip="Colour for Unconfirmed Cross marks and the older pane ◆.\n\nKeeps the second-grade event apart from the trend colours. Hover a mark to see its direction.\n\nNot an entry or exit signal.")
bullishMid = input.color(#006E55, "Bullish weak", group="Appearance / Palette", display=display.none, tooltip="Colour for a weak rise: up, but the line moves slowly, price disagrees or the line keeps slowing.\n\nDim means up, but the read is incomplete. The panel tooltip names why.\n\nColour describes the trend. It is not a trade call.")
bearishMid = input.color(#8C2D2B, "Bearish weak", group="Appearance / Palette", display=display.none, tooltip="Colour for a weak fall: down, but the line moves slowly, price disagrees or the line keeps slowing.\n\nDim means down, but the read is incomplete. The panel tooltip names why.\n\nColour describes the trend. It is not a trade call.")
showQualifiedInput = input.bool(true, "Show qualified trend marks on price", display=display.none, group="Signals", tooltip="Shows a triangle on the candle where the trend first qualifies up or down, with price confirming.\n\nThe signature event: where the qualified state flipped.\n\nThe mark comes after the turn, because the line follows price. Hiding marks never changes alerts.")
glowInput = input.bool(true, "Glow", display=display.none, group="Display", tooltip="Shows a soft glow around the trend line, in the line colour.\n\nIt changes the price chart only: no calculation, pane, mark or alert.")
showLineInput = input.bool(true, "Show trend line on price", display=display.none, group="Display", tooltip="Shows the Kalman trend line on the price chart.\n\nTurn it off to see only the candles, marks and panel. The glow hides with the line.\n\nThe pane, marks, panel and alerts stay the same.")

seconds = timeframe.in_seconds()
resolvedHorizon = horizonInput == "Auto" ? (seconds < 14400 ? "Intraday" : seconds <= 86400 ? "Swing" : "Position") : horizonInput
atrPeriod = custom ? atrPeriodInput : resolvedHorizon == "Intraday" ? 10 : resolvedHorizon == "Position" ? 20 : 14
smoothingAlpha = custom ? alphaInput : resolvedHorizon == "Intraday" ? 0.15 : resolvedHorizon == "Position" ? 0.05 : 0.10
qMin = custom ? qMinInput : resolvedHorizon == "Intraday" ? 0.002 : resolvedHorizon == "Position" ? 0.0005 : 0.001
qMax = custom ? qMaxInput : resolvedHorizon == "Intraday" ? 0.15 : resolvedHorizon == "Position" ? 0.05 : 0.1
rMin = custom ? rMinInput : resolvedHorizon == "Intraday" ? 0.22499999999999998 : resolvedHorizon == "Position" ? 0.75 : 0.375
rMax = custom ? rMaxInput : resolvedHorizon == "Intraday" ? 1.125 : resolvedHorizon == "Position" ? 3.0 : 1.5
boundsValid = qMin <= qMax and rMin <= rMax
supported = chart.is_standard and not na(seconds)

// Frozen baseline engine: init, prediction and covariance update are verbatim.
atrValue   = ta.atr(atrPeriod)
atrSmaPeriod = atrPeriod * 3
atrSma     = ta.sma(atrValue, atrSmaPeriod)

// State vector: [price, velocity]
// Covariance matrix P: [[p00, p01], [p10, p11]]
var float xPrice    = na
var float xVelocity = 0.0
var float p00       = 1.0
var float p01       = 0.0
var float p10       = 0.0
var float p11       = 1.0

xPrice    := barstate.isfirst ? close : xPrice
xVelocity := barstate.isfirst ? 0.0 : xVelocity
p00       := barstate.isfirst ? 1.0 : p00
p01       := barstate.isfirst ? 0.0 : p01
p10       := barstate.isfirst ? 0.0 : p10
p11       := barstate.isfirst ? 1.0 : p11

atrNorm = atrSma > 1e-10 ? atrValue / atrSma : 1.0
expFactor = 1.0 - math.exp(-smoothingAlpha * atrNorm)
qAdaptive = qMin + (qMax - qMin) * (1.0 - expFactor)
rAdaptive = rMin + (rMax - rMin) * expFactor

// F = [[1, 1], [0, 1]] (constant velocity model)
xPricePred    = xPrice + xVelocity
xVelocityPred = xVelocity

p00Pred = p00 + p01 + p10 + p11 + qAdaptive
p01Pred = p01 + p11
p10Pred = p10 + p11
p11Pred = p11 + qAdaptive

// H = [1, 0] (observe price only)
innovation = close - xPricePred
s = p00Pred + rAdaptive
k0 = p00Pred / s
k1 = p10Pred / s

xPrice    := xPricePred + k0 * innovation
xVelocity := xVelocityPred + k1 * innovation

p00 := (1.0 - k0) * p00Pred
p01 := (1.0 - k0) * p01Pred
p10 := -k1 * p00Pred + p10Pred
p11 := -k1 * p01Pred + p11Pred

// Derived states never feed back into the frozen recurrence.
atr14 = ta.atr(14)
velATR = atr14[1] > 0 ? xVelocity / atr14[1] : na
engineValid = not na(xPrice) and not na(xVelocity) and not na(qAdaptive) and not na(rAdaptive) and not na(k0)
ready = boundsValid and supported and engineValid and not na(atrSma) and not na(velATR)
eventReady = barstate.isconfirmed and ready and ready[1]
// Cross context: the prior clear side is evaluated before the current side is assigned.
var int clearSide = 0
crossWithoutTurnUp = eventReady and close > xPrice + 0.3 * atr14[1] and clearSide == -1 and xVelocity <= 0
crossWithoutTurnDown = eventReady and close < xPrice - 0.3 * atr14[1] and clearSide == 1 and xVelocity >= 0
if barstate.isconfirmed and ready
    if close > xPrice + 0.3 * atr14[1]
        clearSide := 1
    else if close < xPrice - 0.3 * atr14[1]
        clearSide := -1

// Qualified state: 0 until the first qualifying close seeds it without an event, then +1 or -1.
var int trendState = 0
var bool unconfirmedUsed = false
qualUpNow = eventReady and velATR > 0.15 and close > xPrice + 0.3 * atr14[1]
qualDownNow = eventReady and velATR < -0.15 and close < xPrice - 0.3 * atr14[1]
qualifiedUp = qualUpNow and trendState == -1
qualifiedDown = qualDownNow and trendState == 1
unconfirmedUp = crossWithoutTurnUp and trendState == -1 and not unconfirmedUsed
unconfirmedDown = crossWithoutTurnDown and trendState == 1 and not unconfirmedUsed
if qualUpNow and trendState != 1
    trendState := 1
    unconfirmedUsed := false
else if qualDownNow and trendState != -1
    trendState := -1
    unconfirmedUsed := false
if unconfirmedUp or unconfirmedDown
    unconfirmedUsed := true

// Strength tier: one boolean drives the price line, pane line, fill, qualified mark and Strength row.
signSteady = xVelocity != 0 and math.sign(xVelocity) == math.sign(xVelocity[1]) and math.sign(xVelocity[1]) == math.sign(xVelocity[2]) and math.sign(xVelocity[2]) == math.sign(xVelocity[3])
tierReady = ready and ready[1] and ready[2] and ready[3] and signSteady
fadingNow = tierReady and math.abs(velATR) < math.abs(velATR[1]) and math.abs(velATR[1]) < math.abs(velATR[2]) and math.abs(velATR[2]) < math.abs(velATR[3])
strengtheningNow = tierReady and math.abs(velATR) > math.abs(velATR[1]) and math.abs(velATR[1]) > math.abs(velATR[2]) and math.abs(velATR[2]) > math.abs(velATR[3])
var bool fadingConfirmed = false
if barstate.isconfirmed
    fadingConfirmed := fadingNow
priceAgrees = xVelocity > 0 ? close > xPrice + 0.3 * atr14[1] : xVelocity < 0 ? close < xPrice - 0.3 * atr14[1] : false
velocityLarge = ready and math.abs(velATR) > 0.15
isStrong = velocityLarge and priceAgrees and not fadingConfirmed

// Theme resolver (AP-01): Auto reads chart background brightness.
float bgR = color.r(chart.bg_color)
float bgG = color.g(chart.bg_color)
float bgB = color.b(chart.bg_color)
float bgLum = (bgR + bgG + bgB) / 3.0
bool autoIsLight = bgLum > 128.0
bool useLightTheme = themeInput == "Light" or (themeInput == "Auto" and autoIsLight)
strongUp = useLightTheme and bullish == #00E6B4 ? #00785A : bullish
strongDown = useLightTheme and bearish == #FF504B ? #A52828 : bearish
weakUp = useLightTheme and bullishMid == #006E55 ? #509D8B : bullishMid
weakDown = useLightTheme and bearishMid == #8C2D2B ? #BF7E7D : bearishMid
velocityColor = not ready or xVelocity == 0 ? neutral : xVelocity > 0 ? (isStrong ? strongUp : weakUp) : (isStrong ? strongDown : weakDown)

// Display-only EMA, evaluated every bar; no cross feeds an event or alert.
velAvg = ta.ema(velATR, 5)
shownVelocity = ready ? math.max(-5.0, math.min(5.0, velATR)) : na
shownVelAvg = ready and not na(velAvg) ? math.max(-5.0, math.min(5.0, velAvg)) : na
ribbon = paneStyleInput == "Ribbon"
area = paneStyleInput == "Area"
columns = paneStyleInput == "Columns"
p_velocity = plot(shownVelocity, "Velocity", color=velocityColor, linewidth=3, display=columns ? display.status_line : display.pane + display.status_line)
p_zero = plot(0, "Zero anchor", color=na, display=display.none, editable=false)
p_velAvg = plot(ribbon ? shownVelAvg : na, "Velocity average", color=color.new(velocityColor, 45), linewidth=2, display=ribbon ? display.pane + display.status_line + display.data_window : display.none, editable=false)
p_area1 = plot(area ? shownVelocity * 0.6 : na, "Area step 1", color=na, display=display.none, editable=false)
p_area2 = plot(area ? shownVelocity * 0.3 : na, "Area step 2", color=na, display=display.none, editable=false)
fill(p_velocity, p_velAvg, color=ribbon ? color.new(velocityColor, 75) : na, title="Ribbon", fillgaps=false)
fill(p_velocity, p_area1, color=area ? color.new(velocityColor, 55) : na, title="Area fill 1", fillgaps=false)
fill(p_area1, p_area2, color=area ? color.new(velocityColor, 72) : na, title="Area fill 2", fillgaps=false)
fill(p_area2, p_zero, color=area ? color.new(velocityColor, 93) : na, title="Area fill 3", fillgaps=false)
plot(columns ? shownVelocity : na, "Velocity columns", color=color.new(velocityColor, 40), style=plot.style_columns, histbase=0, display=display.pane, editable=false)
hline(0, "Zero line", color=color.new(neutral, 60), linestyle=hline.style_solid, linewidth=1)
// Optional soft glow as two wide translucent copies of the Kalman line under the halo, then the background halo and the 3 px line on top.
// Show trend line on price hides the line, its halo and its glow together (display only; values unchanged).
lineDisplay = showLineInput ? display.pane : display.none
glowDisplay = showLineInput and glowInput ? display.pane : display.none
plot(boundsValid ? xPrice : na, "Glow outer", color=color.new(velocityColor, useLightTheme ? 89 : 86), linewidth=18, force_overlay=true, display=glowDisplay, editable=false)
plot(boundsValid ? xPrice : na, "Glow inner", color=color.new(velocityColor, useLightTheme ? 76 : 70), linewidth=10, force_overlay=true, display=glowDisplay, editable=false)
plot(boundsValid ? xPrice : na, "Price halo", color=color.new(chart.bg_color, 40), linewidth=6, force_overlay=true, display=lineDisplay, editable=false)
plot(boundsValid ? xPrice : na, "Kalman line", color=velocityColor, linewidth=3, force_overlay=true, display=lineDisplay)
plot(boundsValid ? qAdaptive : na, "q (engine)", display=display.data_window, editable=false)
plot(boundsValid ? rAdaptive : na, "r (engine)", display=display.data_window, editable=false)
plot(boundsValid ? k0 : na, "k0 (engine)", display=display.data_window, editable=false)
plot(boundsValid ? xVelocity : na, "xVelocity (engine)", display=display.data_window, editable=false)

plot(boundsValid ? velATR : na, "Velocity (ATR/bar, unclipped)", display=display.data_window, editable=false)

f_signed(float value) =>
    magnitude = math.abs(value)
    digits = magnitude > 0 and magnitude < 0.005 ? "<0.01" : str.tostring(magnitude, "0.00")
    na(value) ? "Unavailable" : value > 0 ? "+" + digits : value < 0 ? "-" + digits : "0.00"
f_when() =>
    timeframe.isintraday ? str.format_time(time_close, "yyyy-MM-dd HH:mm", syminfo.timezone) : str.format_time(time, "yyyy-MM-dd", syminfo.timezone)
f_push(array<label> marks, label mark, int cap) =>
    if array.size(marks) >= cap
        label.delete(array.shift(marks))
    array.push(marks, mark)
f_clear(array<label> marks) =>
    while array.size(marks) > 0
        label.delete(array.shift(marks))

// Marks: a core triangle in the tier colour carrying the hover text and a fainter ring behind it.
// Core and ring sit on one price point, so they share one centre (one mark per event); the gap from the candle is display only.
// The point clears both the candle and the Kalman line on the signal bar (below the lower for an up mark, above the higher for a down mark): up marks 1.6 ATR, down marks 0.6 ATR.
// Pane marks are fainter than price marks; Unconfirmed marks stay fainter than Qualified marks. Each family keeps its newest 100 marks.
markCoreSize = 13
markRingSize = 16
markGapUp = 1.6
markGapDown = 0.6
qualRingFade = 72
unconfirmedFade = 40
unconfirmedRingFade = 85
paneQualFade = 45
paneQualRingFade = 85
paneUnconfirmedFade = 65
paneUnconfirmedRingFade = 90
f_pricePair(array<label> marks, bool up, color tone, int ringFade, string tip) =>
    glyph = up ? "▲" : "▼"
    y = up ? math.min(low, xPrice) - markGapUp * atr14 : math.max(high, xPrice) + markGapDown * atr14
    f_push(marks, label.new(bar_index, y, glyph, yloc=yloc.price, style=label.style_none, textcolor=color.new(tone, ringFade), size=markRingSize, tooltip=tip, force_overlay=true), 200)
    f_push(marks, label.new(bar_index, y, glyph, yloc=yloc.price, style=label.style_none, textcolor=tone, size=markCoreSize, tooltip=tip, force_overlay=true), 200)
f_panePair(array<label> marks, bool up, color tone, int ringFade, string tip, float y) =>
    glyph = up ? "▲" : "▼"
    f_push(marks, label.new(bar_index, y, glyph, yloc=yloc.price, style=label.style_none, textcolor=color.new(tone, ringFade), size=markRingSize, tooltip=tip), 200)
    f_push(marks, label.new(bar_index, y, glyph, yloc=yloc.price, style=label.style_none, textcolor=tone, size=markCoreSize, tooltip=tip), 200)
var array<label> qualifiedMarks = array.new<label>()
var array<label> unconfirmedMarks = array.new<label>()
var array<label> paneMarks = array.new<label>()
var array<label> legacyMarks = array.new<label>()
if qualifiedUp or qualifiedDown
    up = qualifiedUp
    tip = (up ? "Uptrend confirmed: price and the line agree." : "Downtrend confirmed: price and the line agree.") + "\n\n" + f_when() + " close. Price is well " + (up ? "above" : "below") + " the line, and the line is " + (up ? "rising" : "falling") + " clearly. Speed at this close: " + f_signed(velATR) + ", where 0 is flat."
    tip += "\n\nThe first confirmed " + (up ? "uptrend" : "downtrend") + " since the last confirmed " + (up ? "downtrend" : "uptrend") + ".\n\nThe mark comes after the turn, because the line follows price. A reading, not an entry."
    if showQualifiedInput
        f_pricePair(qualifiedMarks, up, velocityColor, qualRingFade, tip)
    if showMarkersInput
        f_panePair(paneMarks, up, color.new(velocityColor, paneQualFade), paneQualRingFade, tip, shownVelocity)
if unconfirmedUp or unconfirmedDown
    up = unconfirmedUp
    tip = (up ? "Price broke above the line before the trend confirmed." : "Price broke below the line before the trend confirmed.") + "\n\n" + f_when() + " close. Price is well " + (up ? "above" : "below") + " the line, but the line has not turned " + (up ? "up" : "down") + " yet. Speed at this close: " + f_signed(velATR) + ", where 0 is flat."
    tip += "\n\nPrice moved first. A confirmed " + (up ? "uptrend" : "downtrend") + " may or may not follow.\n\nOn the six training charts, roughly 2 to 4 in 10 were followed within three bars."
    if showPriceMarksInput
        f_pricePair(unconfirmedMarks, up, color.new(eventColor, unconfirmedFade), unconfirmedRingFade, tip)
    if showMarkersInput
        f_panePair(paneMarks, up, color.new(eventColor, paneUnconfirmedFade), paneUnconfirmedRingFade, tip, shownVelocity)
if showTurnsInput and (crossWithoutTurnUp or crossWithoutTurnDown)
    up = crossWithoutTurnUp
    tip = (up ? "Older cross mark, up: price closed well above the line while the line pointed down or flat." : "Older cross mark, down: price closed well below the line while the line pointed up or flat.") + "\n\n" + f_when() + " close, after the last clear close " + (up ? "below" : "above") + " the line. Speed at this close: " + f_signed(velATR) + ", where 0 is flat."
    tip += "\n\nKept from v8 for users who relied on it. It is not a confirmed trend mark. It marks the clear close, not always the first touch of the line. It is not a turn, an entry, or a promise of a later turn."
    f_push(legacyMarks, label.new(bar_index, shownVelocity, "◆", style=label.style_none, textcolor=eventColor, size=size.tiny, tooltip=tip), 100)
if not showQualifiedInput
    f_clear(qualifiedMarks)
if not showPriceMarksInput
    f_clear(unconfirmedMarks)
if not showMarkersInput
    f_clear(paneMarks)
if not showTurnsInput
    f_clear(legacyMarks)

// Last confirmed snapshot for the panel.
statusNow = not boundsValid ? (qMin > qMax ? "Invalid: qMin > qMax" : "Invalid: rMin > rMax") : not supported ? "Unsupported chart type" : not engineValid ? "Invalid data" : not na(atr14[1]) and atr14[1] == 0 ? "No range" : not ready ? "Warming up" : ""
warmLeft = math.max(math.max(4 * atrPeriod - 2, 14) - bar_index, 1)
directionWord = xVelocity > 0 ? "BULLISH" : xVelocity < 0 ? "BEARISH" : "NEUTRAL"
var string snapshotBadge = "WARMING UP"
var string snapshotReading = "Warming up"
var string snapshotStrength = "Unavailable"
var float snapshotVelocity = na
var int snapshotDirection = 0
var int snapshotBar = na
var string snapshotSide = ""
var string snapshotWhen = ""
var int snapshotAge = 0
if barstate.isconfirmed
    priorDirection = snapshotDirection
    snapshotBar := bar_index
    snapshotBadge := statusNow == "Warming up" ? "WARMING UP" : statusNow != "" ? statusNow : directionWord
    side = close > xPrice + 0.3 * atr14[1] ? "above" : close < xPrice - 0.3 * atr14[1] ? "below" : "at"
    motion = xVelocity > 0 ? "upward velocity " : xVelocity < 0 ? "downward velocity " : "velocity flat"
    snapshotReading := statusNow == "Warming up" ? "Warming up: " + str.tostring(warmLeft) + (warmLeft == 1 ? " bar left" : " bars left") : statusNow != "" ? statusNow : "Price " + side + " line; " + motion + (xVelocity == 0 ? "" : fadingNow ? "easing" : strengtheningNow ? "building" : "pace varies")
    snapshotStrength := statusNow != "" ? "Unavailable" : not velocityLarge ? "Weak · velocity small" : not priceAgrees ? "Weak · price disagrees" : fadingNow ? "Weak · fading" : "Strong"
    snapshotVelocity := ready ? velATR : na
    snapshotDirection := statusNow != "" ? 0 : xVelocity > 0 ? 1 : xVelocity < 0 ? -1 : 0
    snapshotSide := side
    snapshotWhen := f_when()
    snapshotAge := snapshotDirection == 0 ? 0 : snapshotDirection == priorDirection ? snapshotAge + 1 : 1

// Panel: the DC-01 info panel chrome; header Kalman Velocity with the trend state, rows Trend strength and Trend age, from the last confirmed snapshot.
// Labels left, values right, default font, one thin frame; detail lives in the cell tooltips.
tblBg = useLightTheme ? color.new(#FAFAFC, 10) : color.new(color.black, 15)
tblFrame = useLightTheme ? color.new(#AAAFBE, 30) : color.new(#787B86, 30)
tblBorder = useLightTheme ? color.new(#C8CDD7, 40) : color.new(#787B86, 50)
titleCol = useLightTheme ? #0F1423 : color.white
labelCol = useLightTheme ? #5A5F73 : #787B86
valueCol = useLightTheme ? #191E2D : color.white
panelAnchor = panelPositionInput == "Top left" ? position.top_left : panelPositionInput == "Bottom right" ? position.bottom_right : panelPositionInput == "Bottom left" ? position.bottom_left : panelPositionInput == "Middle right" ? position.middle_right : position.top_right
// Top left clears the pane legend with a transparent spacer row; the frame is dropped there so no empty framed box draws above the header.
panelSpacer = panelPositionInput == "Top left"
panelRow0 = panelSpacer ? 1 : 0
cellBg = panelSpacer ? tblBg : color(na)
var table readingPanel = table.new(panelAnchor, 2, panelSpacer ? 4 : 3, bgcolor=panelSpacer ? color(na) : tblBg, frame_color=panelSpacer ? color(na) : tblFrame, frame_width=panelSpacer ? 0 : 2, border_color=panelSpacer ? color(na) : tblBorder, border_width=1)
f_head(string state, color stateColor, string titleTip, string stateTip) =>
    table.cell(readingPanel, 0, panelRow0, "Kalman Velocity", text_color=titleCol, bgcolor=cellBg, text_size=size.normal, text_halign=text.align_left, tooltip=titleTip)
    table.cell(readingPanel, 1, panelRow0, state, text_color=stateColor, bgcolor=cellBg, text_size=size.large, text_halign=text.align_right, tooltip=stateTip)
f_row(int row, string label, string labelTip, string value, color valueColor, string valueTip) =>
    table.cell(readingPanel, 0, panelRow0 + row, label, text_color=labelCol, bgcolor=cellBg, text_size=size.normal, text_halign=text.align_left, tooltip=labelTip)
    table.cell(readingPanel, 1, panelRow0 + row, value, text_color=valueColor, bgcolor=cellBg, text_size=size.normal, text_halign=text.align_right, tooltip=valueTip)
if barstate.islast
    table.clear(readingPanel, 0, 0, 1, panelSpacer ? 3 : 2)
    if showPanelInput
        if panelSpacer
            table.cell(readingPanel, 0, 0, " \n \n ", text_color=color.new(valueCol, 100), bgcolor=na, text_size=size.small)
        up = snapshotDirection > 0
        headTone = snapshotDirection > 0 ? strongUp : snapshotDirection < 0 ? strongDown : neutral
        valueTone = snapshotDirection == 0 ? valueCol : snapshotDirection < 0 and not useLightTheme and bearish == #FF504B ? #FF6B66 : headTone
        whenText = "\n\nFrom the candle that closed " + snapshotWhen + ". The live line may move before the next close."
        causeText = str.startswith(snapshotBadge, "Invalid:") ? "A lower setting is above its matching upper setting." : snapshotBadge == "Unsupported chart type" ? "This chart type does not provide the needed prices." : snapshotBadge == "No range" ? "Recent price bars have no measured range." : "The chart data could not produce a reading."
        hasReading = snapshotDirection != 0 and not na(snapshotBar)
        statusWord = na(snapshotBar) ? "Waiting" : snapshotBadge == "WARMING UP" ? "Warming up" : snapshotBadge == "NEUTRAL" ? "No trend" : hasReading ? "" : "No reading"
        if statusWord != ""
            statusTip = na(snapshotBar) ? "The reading starts after a candle closes.\n\nThe panel uses closed candles only." : snapshotBadge == "WARMING UP" ? "The line needs more closed candles before it can read the trend.\n\nThe panel uses closed candles only." + whenText : snapshotBadge == "NEUTRAL" ? "The trend line is flat.\n\nThe panel has no up or down reading for this candle." + whenText : "The indicator cannot read this chart or these settings.\n\n" + causeText + whenText
            f_head(statusWord, valueCol, statusTip, statusTip)
            f_row(1, "Trend strength", statusTip, "-", valueCol, statusTip)
            f_row(2, "Trend age", statusTip, "-", valueCol, statusTip)
        else
            strong = snapshotStrength == "Strong"
            reasonText = snapshotStrength == "Weak · velocity small" ? "The line is moving slowly." : snapshotStrength == "Weak · price disagrees" ? (up ? "Price is not clearly above the line." : "Price is not clearly below the line.") : "The line has been slowing."
            tierTip = (strong ? "The move meets all three strength conditions.\n\nThe line moves clearly. Price is well " + (up ? "above" : "below") + " the line. The line is not steadily slowing.\n\nStrong describes the move, not a trade opportunity." : "The move does not meet every strong condition.\n\n" + reasonText + "\n\nWeak describes the move, not a trade opportunity.") + whenText
            ageWord = str.tostring(snapshotAge) + (snapshotAge == 1 ? " bar" : " bars")
            ageTip = "The trend line has moved " + (up ? "up" : "down") + " for " + ageWord + ", counting the latest closed candle.\n\nThe count starts again when the line changes direction. It describes the past, not how long the move will last." + whenText
            f_head(up ? "Trending up" : "Trending down", valueTone, "This row shows which way the trend line is moving." + whenText, "The trend line is moving " + (up ? "up" : "down") + "." + whenText)
            f_row(1, "Trend strength", "This row describes how strong the current move is.\n\nThis does not rate a trade or predict the next candle." + whenText, strong ? "Strong" : "Weak", strong ? valueTone : valueCol, tierTip)
            f_row(2, "Trend age", "This row counts the closed candles the trend line has moved in its current direction." + whenText, ageWord, valueCol, ageTip)

alertcondition(qualifiedUp, "Qualified Trend Up (Once Per Bar Close)", "AK-01 | Qualified Trend Up | {{ticker}} | {{interval}} | close {{close}} | bar {{time}} | confirmed on bar close")
alertcondition(qualifiedDown, "Qualified Trend Down (Once Per Bar Close)", "AK-01 | Qualified Trend Down | {{ticker}} | {{interval}} | close {{close}} | bar {{time}} | confirmed on bar close")
alertcondition(unconfirmedUp, "Unconfirmed Cross Up (Once Per Bar Close)", "AK-01 | Unconfirmed Cross Up | {{ticker}} | {{interval}} | close {{close}} | bar {{time}} | confirmed on bar close")
alertcondition(unconfirmedDown, "Unconfirmed Cross Down (Once Per Bar Close)", "AK-01 | Unconfirmed Cross Down | {{ticker}} | {{interval}} | close {{close}} | bar {{time}} | confirmed on bar close")
````
