# Buy/Sell Pressure

- url: https://www.tradingview.com/script/aNaOVtuo-Buy-Sell-Pressure/
- type: indicator
- pine_id: PUB;13cd42caba48485ab520ed5b330a3b53
- version: 4.0

## Description

# **Buy/Sell Pressure**

Buy/Sell Pressure is designed to provide insight into **who is actually controlling the market beneath the surface**. Rather than focusing exclusively on whether price is moving higher or lower, the indicator attempts to determine whether those price movements are being supported by genuine buying interest or genuine selling pressure.

Markets do not always move because one side is aggressively taking control. Sometimes prices drift higher simply because sellers temporarily step aside. Other times, prices fall because buyers become reluctant rather than because sellers are overwhelming the market. Looking at price alone can make these distinctions difficult to recognize.

Buy/Sell Pressure was developed to address that problem.

The indicator combines several different aspects of market behavior into a single, easy-to-read oscillator. By evaluating how price behaves within each bar, how volume participates in those movements, and whether underlying money flow supports the move, it attempts to provide a clearer picture of the balance of power between buyers and sellers.

The goal is not to predict the future. Instead, the goal is to answer a simpler but often more useful question:

> **Who appears to be winning the battle right now: buyers or sellers?**

---

# **What the Indicator Is Measuring**

Buy/Sell Pressure evaluates multiple dimensions of market behavior simultaneously.

It examines where price closes within the range of each bar. A market that consistently closes near the upper portion of its range often reflects persistent buying interest. Conversely, a market that repeatedly closes near the lower portion of its range may indicate sustained selling pressure.

The indicator also evaluates the relationship between opening and closing prices. Large bullish bodies suggest buyers were able to maintain control throughout the period, while large bearish bodies suggest sellers dominated the session. Smaller candle bodies generally indicate indecision or equilibrium between the two sides.

Wick behavior is another important component. Long lower shadows often suggest that sellers attempted to push prices lower but buyers stepped in aggressively enough to reject those lower levels. Long upper shadows may indicate that buyers attempted to push prices higher but encountered significant selling resistance. These subtle forms of rejection can reveal underlying pressure that may not be obvious from price alone.

Volume is then incorporated into the calculation. Price movement occurring during periods of elevated participation tends to carry greater significance than identical price movement occurring during quiet conditions. By weighting certain behaviors according to volume, the indicator attempts to emphasize moves that are supported by broader market involvement.

The indicator also considers money flow and cumulative volume behavior. This helps determine whether capital has generally been flowing into the market or out of it over recent periods. These additional layers of analysis help distinguish meaningful shifts in pressure from ordinary short-term fluctuations.

The result is a composite measure designed to identify whether **buying pressure is strengthening, selling pressure is strengthening, or neither side currently has a meaningful advantage.**

---

# **Understanding the Histogram**

The primary visual component of the indicator is the histogram.

The histogram oscillates around a central zero line. The further the histogram extends away from that centerline, the stronger the underlying pressure is considered to be.

The direction and color of the histogram provide insight into the current balance between buyers and sellers.

---

## **Green Histogram Bars**

Green histogram bars indicate that underlying buying pressure is present.

When the histogram begins printing green bars, it suggests that buyers are exerting increasing influence over market behavior. Price action is becoming increasingly supported by demand rather than simply drifting higher due to a lack of sellers.

As green bars expand in size, the strength of buying pressure is increasing. This often occurs during healthy uptrends, breakout phases, or periods of sustained accumulation.

---

## **Red Histogram Bars**

Red histogram bars indicate that underlying selling pressure is dominant.

These readings suggest that sellers are becoming increasingly aggressive and that downward price movement is being supported by genuine supply entering the market.

As red bars grow larger, selling pressure is intensifying. These conditions frequently accompany strong downtrends, breakdowns, or periods of distribution.

---

## **Gray Histogram Bars**

Gray histogram bars represent neutral conditions.

During these periods, neither buyers nor sellers possess a sufficiently strong advantage to justify a directional reading.

Neutral conditions often occur during:

* Consolidation phases.
* Sideways markets.
* Transitional periods between trends.
* Areas of temporary equilibrium.

Gray bars can serve as a reminder that not every market environment is favorable for directional decision-making.

---

## **Extreme Pressure Conditions**

The indicator also identifies periods when buying or selling pressure becomes unusually strong relative to recent history.

These conditions are represented by brighter shades of green or red.

Extreme readings indicate that conviction is significantly elevated. Buyers or sellers are demonstrating an unusual degree of control compared to what has been considered normal over the selected historical period.

It is important to understand that extreme readings should not automatically be interpreted as reversal signals.

Strong markets can remain strong for extended periods. Likewise, weak markets can continue to weaken. Extreme readings are best viewed as evidence of exceptional pressure rather than immediate exhaustion.

---

# **The Signal Line**

The orange signal line provides a smoother representation of the underlying pressure reading.

Because it is less reactive than the histogram itself, it can help traders focus on broader shifts in pressure rather than becoming distracted by every short-term fluctuation.

A rising signal line generally reflects improving conditions for buyers.

A falling signal line generally reflects strengthening conditions for sellers.

Many users find the signal line useful when assessing whether pressure is accelerating, stabilizing, or beginning to deteriorate.

---

# **Pressure Dots**

The indicator includes optional pressure dots designed to highlight important transitions in market control.

Users can choose between two different methods for generating these signals.

---

## **Zero Cross Mode**

In Zero Cross mode, a green dot appears when pressure crosses above the zero line, while a red dot appears when pressure crosses below zero.

These signals occur relatively early because they identify the point at which the balance of pressure shifts from negative to positive or vice versa.

The advantage of this approach is speed.

The disadvantage is that early signals can occasionally occur during temporary fluctuations that fail to develop into meaningful trends.

---

## **First Colored Bar Mode**

In First Colored Bar mode, dots appear only when pressure moves decisively beyond the neutral zone and the first meaningful buying or selling histogram bar is printed.

Green dots identify the first significant buying bar.

Red dots identify the first significant selling bar.

Because these signals require stronger confirmation, they tend to occur later than zero-cross signals.

However, they are often cleaner and easier to interpret.

This mode is the default setting because it focuses on identifying **meaningful pressure shifts rather than merely technical transitions around the zero line.**

---

# **Understanding the Inputs**

---

## **Confirmed Bars Only (Non-Repainting)**

When enabled, all calculations are based exclusively on completed bars.

This prevents signals from changing after a bar closes and ensures that historical signals accurately reflect what would have been visible in real time.

The tradeoff is that signals appear one bar later.

This setting is enabled by default because reliability is often more valuable than immediacy.

---

## **Show Confirmed Mode Label**

This optional label provides a visual reminder that non-repainting mode is active.

It has no impact on calculations and exists purely for convenience.

The label is disabled by default to preserve a cleaner appearance.

---

## **Pressure Lookback**

This setting controls how persistent underlying pressure must be before the indicator fully reflects it.

Lower values produce a more responsive oscillator that reacts quickly to changing conditions.

Higher values produce a smoother oscillator that emphasizes sustained pressure rather than short-term fluctuations.

The default value of **50** attempts to strike a balance between responsiveness and stability.

---

## **Score Smoothing**

Score Smoothing determines how aggressively the raw pressure calculations are filtered before reaching the final oscillator.

Increasing this value reduces noise but delays transitions.

Decreasing it improves responsiveness but increases sensitivity.

The default value of **5** provides moderate smoothing without excessively sacrificing timeliness.

---

## **Volume Baseline**

Volume Baseline establishes the historical reference used to determine whether current participation levels are unusually high or unusually low.

Higher settings create a more stable volume benchmark.

Lower settings allow the indicator to adapt more quickly to changing market environments.

---

## **Normalization Lookback**

Normalization Lookback determines how much historical information is used when establishing what constitutes "normal" pressure conditions.

Shorter values adapt rapidly but may cause thresholds to shift more frequently.

Longer values create a more stable frame of reference.

The default value of **100** was chosen to emphasize consistency and reduce sensitivity to temporary anomalies.

---

## **Signal Line Length**

This setting controls the responsiveness of the signal line.

Shorter lengths allow the signal line to track pressure more closely.

Longer lengths smooth the signal line and emphasize broader trends.

---

## **Money Flow Length**

Money Flow Length determines how much historical information is used when evaluating whether capital has generally been entering or exiting the market.

Smaller values respond quickly to recent changes.

Larger values emphasize longer-term participation trends.

---

## **OBV Pressure Length**

This setting controls how much cumulative volume history contributes to the assessment of broader buying and selling participation.

Lower values prioritize recent developments.

Higher values place greater emphasis on sustained pressure trends.

---

## **Neutral Zone**

The Neutral Zone defines the boundary separating insignificant pressure from meaningful pressure.

Histogram readings that remain inside this area are considered inconclusive and are displayed using neutral colors.

Reducing the size of the neutral zone increases sensitivity.

Expanding it requires stronger evidence before directional readings are generated.

The default setting of **35** attempts to filter out routine market noise while remaining responsive to meaningful shifts.

---

## **Extreme Level**

The Extreme Level determines when pressure becomes exceptionally strong relative to recent market conditions.

Readings beyond this threshold are highlighted using brighter colors.

These conditions often reflect unusually strong conviction but should not automatically be interpreted as reversal opportunities.

The default value of **75** identifies situations where pressure has become significantly elevated.

---

# **Practical Applications**

Buy/Sell Pressure can be used in a variety of ways.

Many traders use it as a confirmation tool during breakouts. When price breaks through an important level while buying pressure simultaneously strengthens, the move may possess greater credibility.

Others use it to evaluate pullbacks. Temporary declines occurring during periods of weak selling pressure may suggest healthy retracements within larger uptrends. Similarly, weak buying pressure during countertrend rallies may indicate that bearish conditions remain intact.

The indicator can also help identify potential exhaustion. If price continues advancing while buying pressure steadily deteriorates, the underlying trend may be losing support. Likewise, continued price declines accompanied by weakening selling pressure may suggest that bearish momentum is beginning to fade.

Finally, Buy/Sell Pressure can serve as a valuable trade filter. Traders who already possess an established strategy may use the indicator to align themselves with the prevailing side of the market.

---

# **Final Thoughts**

Buy/Sell Pressure was designed to help traders look beyond price itself and focus on the forces driving that price movement.

Rather than asking whether the market moved higher or lower, it asks whether buyers or sellers genuinely supported that move.

By combining price behavior, volume participation, money flow characteristics, and cumulative pressure analysis into a single adaptive framework, the indicator seeks to provide a clearer understanding of market conviction.

Its purpose is not to predict exactly what the market will do next.

Its purpose is to help answer a more immediate and practical question:

> **If a battle is taking place between buyers and sellers, which side currently appears to have the advantage?**

## Source Code

````pine
//@version=6
indicator("Buy/Sell Pressure", overlay=false)

// ============================================================================
// BUY/SELL PRESSURE — candle-shape (geometry) engine
//
// Pressure is read directly from each bar's ANATOMY — where it closed inside
// its range and the balance of its wicks against its body. No volume direction,
// no intrabar data: pure candle geometry, so it works on every feed and plan.
//
//   range      = high - low
//   body       = close - open                (signed; + bullish, - bearish)
//   upperWick  = high - max(open, close)      rejected highs  -> selling
//   lowerWick  = min(open, close) - low       rejected lows   -> buying
//
// Three shape formulas, each bounded to [-1, +1]:
//   • Close Location  (2*close - high - low) / range   the FULL shape read (CLV)
//   • Balance of Power (close - open) / range          the BODY half only (Livshin BoP)
//   • Wick Imbalance  (lowerWick - upperWick) / range  the TAILS half only
//
// Note the identity: Close Location = Balance of Power + Wick Imbalance.
// The full read is exactly its two halves added together — so these are three
// genuinely distinct lines: the whole, and each half on its own.
//
// The chosen shape ratio is smoothed, scaled by one Sensitivity control into
// the -100..+100 range, and drawn as a histogram. Positive = net buying shape
// (green), negative = net selling shape (red). This reads the GEOMETRY of the
// candle only — not order flow, not volume direction.
// ============================================================================

var string G_ENGINE = "Engine"
var string G_THRESH = "Thresholds"
var string G_SIGNAL = "Signal Line"
var string G_COL    = "Colors"

// ── Engine ──────────────────────────────────────────────────────────────────
shapeMethod = input.string("Close Location", "Shape Method",
     options=["Close Location", "Balance of Power", "Wick Imbalance"],
     group=G_ENGINE,
     tooltip="How pressure is read from candle geometry. Close Location (CLV) is the full shape read — where price closed within the bar's range. Balance of Power is the body half only — did the candle commit to a direction. Wick Imbalance is the tails half only — did price reject lows harder than highs. Close Location = Balance of Power + Wick Imbalance.")

weightByVol = input.bool(false, "Weight by Volume", group=G_ENGINE,
     tooltip="Off = pure candle shape. On = shape still sets direction and magnitude, but higher-volume bars carry more weight in the smoothing.")

confirmedMode = input.bool(true, "Confirmed Bars Only (Non-Repainting)", group=G_ENGINE,
     tooltip="Uses the last completed bar so a reading never changes after its bar closes. Costs one bar of lag. Turn off to read the live forming bar — its high, low and close are still moving, so it will repaint until the bar closes.")

smoothing = input.int(20, "Smoothing", minval=1, group=G_ENGINE,
     tooltip="Higher = steadier, slower readings. Lower = faster and noisier.")

sensitivity = input.float(3, "Sensitivity", minval=0.5, maxval=10, step=0.1, group=G_ENGINE,
     tooltip="Scales the smoothed shape ratio into the -100 to +100 range. Raise if the histogram stays too flat on your instrument; lower if it pins to the extremes too easily. At 1.0 the value is the smoothed shape ratio x100.")

// ── Thresholds ──────────────────────────────────────────────────────────────
neutralLevel = input.float(30, "Neutral Zone (+/-)", minval=5, maxval=50, group=G_THRESH,
     tooltip="Readings inside this band are treated as neutral / balanced (painted gray).")

extremeLevel = input.float(70, "Extreme Level (+/-)", minval=50, maxval=100, group=G_THRESH,
     tooltip="Readings beyond this are unusually one-sided buying or selling (used by the Extreme alerts).")

// ── Signal Line ─────────────────────────────────────────────────────────────
showSignalLine = input.bool(false, "Show Signal Line", group=G_SIGNAL)

sigLen = input.int(14, "Signal Smoothing", minval=1, group=G_SIGNAL,
     tooltip="Smoothing of the signal line drawn over the histogram.")

showSignalFill = input.bool(true, "Fill Signal to Zero", group=G_SIGNAL,
     tooltip="Tints the area between the signal line and zero — green above, red below — for an at-a-glance regime read.")

// ── Colors ──────────────────────────────────────────────────────────────────
buyStrong  = input.color(color.new(color.lime, 0),    "Buying — strong",  group=G_COL)
buySoft    = input.color(color.new(#1B5E20, 40),      "Buying — soft",    group=G_COL)
sellStrong = input.color(color.new(color.red, 0),     "Selling — strong", group=G_COL)
sellSoft   = input.color(color.new(color.maroon, 40), "Selling — soft",   group=G_COL)
neutralCol = input.color(color.new(color.gray, 55),   "Neutral",          group=G_COL)
signalCol  = input.color(color.orange,                "Signal Line",      group=G_COL)
sigFillUp  = input.color(color.new(color.lime, 85),   "Signal Fill — above zero", group=G_COL)
sigFillDn  = input.color(color.new(color.red, 85),    "Signal Fill — below zero", group=G_COL)
zeroCol    = input.color(color.gray,                  "Zero Line",        group=G_COL)

// ── Candle-shape (geometry) engine ──────────────────────────────────────────
// Returns a bounded [-1, +1] shape ratio for the current bar from OHLC only.
f_shapeRatio() =>
    float rng = high - low
    float r = 0.0
    if rng > 0.0
        float body = close - open
        float upW  = high - math.max(open, close)   // upper wick — selling
        float loW  = math.min(open, close) - low     // lower wick — buying
        r := shapeMethod == "Balance of Power" ? body / rng :
             shapeMethod == "Wick Imbalance"   ? (loW - upW) / rng :
             (2.0 * close - high - low) / rng         // Close Location (CLV) — full shape
    r

float rawRatio = f_shapeRatio()

// Non-repainting: lock to the last completed bar when confirmed mode is on.
float useRatio = confirmedMode ? nz(rawRatio[1]) : rawRatio
float useVol   = confirmedMode ? nz(volume[1])   : volume

// ── Smoothing: pure-shape EMA, or volume-weighted average of the shape ───────
float smoothRatio = weightByVol
     ? ta.sma(useRatio * useVol, smoothing) / math.max(ta.sma(useVol, smoothing), 1e-10)
     : ta.ema(useRatio, smoothing)

// ── Pressure: direct, sign-preserving, bounded ──────────────────────────────
float pressure   = math.max(math.min(smoothRatio * 100.0 * sensitivity, 100.0), -100.0)
float signalLine = ta.ema(pressure, sigLen)

// ── States (drive alerts) ────────────────────────────────────────────────────
buying         = pressure >  neutralLevel
selling        = pressure < -neutralLevel
extremeBuying  = pressure >=  extremeLevel
extremeSelling = pressure <= -extremeLevel
flipBuy        = ta.crossover(pressure, 0)
flipSell       = ta.crossunder(pressure, 0)

// ── Histogram color: neutral inside the band, gradient by strength outside ──
gradBuy  = color.from_gradient(pressure,  neutralLevel,  100, buySoft,    buyStrong)
gradSell = color.from_gradient(pressure, -100, -neutralLevel, sellStrong, sellSoft)
histColor = math.abs(pressure) <= neutralLevel ? neutralCol : (pressure > 0 ? gradBuy : gradSell)

// ── Plots ───────────────────────────────────────────────────────────────────
plot(pressure, "Pressure", style=plot.style_columns, color=histColor, linewidth=2, editable=false)

sigPlot = plot(showSignalLine ? signalLine : na, "Signal Line", color=signalCol, linewidth=2, editable=false)

zeroBase = plot(0, "Fill Base", color=color.new(color.black, 100), editable=false)

signalFillColor = signalLine >= 0 ? sigFillUp : sigFillDn
fill(sigPlot, zeroBase, color=(showSignalLine and showSignalFill) ? signalFillColor : na, title="Signal Fill", editable=false)

hline(0, "Zero", color=zeroCol, editable=false)

// ── Alerts ──────────────────────────────────────────────────────────────────
alertcondition(buying,         "Buying Pressure",  "Buy/Sell Pressure: net buying shape above the neutral threshold.")
alertcondition(selling,        "Selling Pressure", "Buy/Sell Pressure: net selling shape below the neutral threshold.")
alertcondition(extremeBuying,  "Extreme Buying",   "Buy/Sell Pressure: extreme net buying shape.")
alertcondition(extremeSelling, "Extreme Selling",  "Buy/Sell Pressure: extreme net selling shape.")
alertcondition(flipBuy,        "Flip to Buying",   "Buy/Sell Pressure: crossed above zero — flipped to net buying shape.")
alertcondition(flipSell,       "Flip to Selling",  "Buy/Sell Pressure: crossed below zero — flipped to net selling shape.")
````
