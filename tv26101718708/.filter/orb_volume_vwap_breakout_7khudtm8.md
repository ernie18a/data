# ORB + Volume + VWAP Breakout

- url: https://www.tradingview.com/script/7khuDtm8-ORB-Volume-VWAP-Breakout/
- type: indicator
- pine_id: PUB;2b998b8722f045869217d5efabb1eeb0
- version: 1.0

## Description

A disciplined intraday breakout indicator that combines three classic confirmations into a single signal: an **Opening Range Breakout**, a **volume surge**, and **VWAP trend alignment**. Designed to filter out low-quality breakouts and highlight only moves backed by participation and momentum.

## Concept

Opening Range Breakout (ORB) is one of the oldest and most robust intraday setups — the theory being that the first N minutes of the session establish the day's battleground, and a decisive break of that range signals directional commitment. On its own, however, ORB produces too many false signals. This indicator layers two institutional-grade filters on top:

- **Volume confirmation** — the breakout bar must print at least 1.5× the recent average volume, weeding out thin, low-conviction moves.
- **VWAP alignment** — price must be trading above VWAP, confirming that the average buyer of the day is in profit and bulls are in control.

Only when all three conditions align on the same bar does the indicator fire a signal.

## How It Works

1. At the start of each regular trading session, the indicator tracks the high and low of the first 30 minutes (configurable).
2. Once the opening range is locked, it monitors every subsequent bar for a close above the range high.
3. On each potential breakout, it checks that current volume exceeds 1.5× the 20-bar average (both configurable) and that price is above the session VWAP.
4. When all three conditions are met on the same bar, it plots a green triangle below the bar, highlights the background, and fires an alert.
5. The signal is de-duplicated so you get exactly **one alert per breakout leg**, not one per bar while price stays above the range.

## Visual Output

- **Blue line** — Opening Range High (active only during session)
- **Orange line** — Opening Range Low (active only during session)
- **Purple line** — Session VWAP
- **Green triangle + "BRK" label** — Breakout signal
- **Green background highlight** — Emphasizes the breakout bar

## Settings

- **Opening Range (minutes)** — Length of the opening range window. Default 30. Classic values: 15, 30, 60.
- **Regular Trading Session** — Session time string. Default `0930-1600` (US equities). Change for futures (`1800-1700`), crypto (`0000-0000`), or other markets.
- **Volume Multiplier** — How many times the average volume is required. Default 1.5. Use 2.0+ for stricter filtering.
- **Volume Average Length** — Lookback for the volume SMA. Default 20.
- **Show Opening Range / Show VWAP** — Toggle visual elements.

## Alerts

The indicator registers a `ORB Breakout` alert condition. To enable:

1. Right-click the chart → **Add Alert**
2. Set **Condition** to this indicator → **ORB Breakout**
3. Configure delivery (popup, email, webhook, etc.)

The alert message includes ticker and close price via TradingView placeholders.

## ⚠️ Important Usage Notes

**1. Use on intraday timeframes lower than the opening range.** This indicator is built for 1m, 5m, or 15m charts with a 30-minute opening range. Running it on a timeframe equal to or higher than the OR window (e.g. 30m or 1h chart with 30-minute OR) will produce incorrect range values because the first bar of the session already spans the entire window or more.

**Recommended pairings:**
- 30-min OR → use 1m / 5m / 15m chart
- 15-min OR → use 1m / 3m / 5m chart
- 60-min OR → use 5m / 15m / 30m chart

**2. Match the session string to your instrument.** The default `0930-1600` is US stock market hours in the exchange's native time zone. If you apply this to futures, forex, or crypto, update the session input accordingly — otherwise the opening range will never register.

**3. Extended hours display does not break the indicator.** The session detection uses day-change logic rather than session-gap logic, so it works identically whether "Extended Trading Hours" is toggled on or off in chart settings.

**4. VWAP is session-anchored.** The built-in `ta.vwap()` resets each session automatically, matching how most traders read VWAP. If you need a weekly- or monthly-anchored VWAP, the script would need modification.

**5. Signals are confirmed on bar close.** Like all close-based indicators, signals can flicker intraday before the bar closes. For live trading, wait for the bar to close before acting, or use the `alert()` function with `barstate.isconfirmed` for non-repainting alerts (requires a minor code adjustment).

## Known Limitations

- **Long-only by design.** This version fires on upside breakouts with bullish VWAP confirmation. A short-side version would invert the logic (close < ORL, close < VWAP).
- **No automatic stop or target.** This is a signal indicator, not a complete strategy. Users should pair it with their own risk management (e.g. stop below opening range low, target at prior day's high, or ATR-based exits).
- **Volume filter is market-dependent.** A 1.5× multiplier works well for liquid US equities but may be too strict for low-volume names or too loose for high-volatility small caps. Tune to your universe.
- **First trading day on a new symbol.** On the very first session visible in your chart's history, the 20-bar volume average may be based on incomplete data. Subsequent days are unaffected.
- **Not intended for swing or position trading.** The opening range concept is intraday-specific and loses meaning on daily+ timeframes.

## Ideal Use Cases

- Momentum day trading on liquid US equities (SPY, QQQ, NVDA, TSLA, AAPL, etc.)
- Index futures (ES, NQ) during RTH
- Filtering gap-and-go setups for only the ones with genuine follow-through
- As a confirmation layer on top of your existing breakout watchlist

## Credits

Opening Range Breakout concept originally popularized by Toby Crabel (*Day Trading with Short Term Price Patterns and Opening Range Breakout*, 1990). Volume and VWAP confirmation filters are standard institutional trading practice.

---

**Feedback welcome.** If you find a setup where the signals are consistently wrong (or consistently great), leave a comment with the ticker and timeframe — I'll use the data to refine future versions.

## Source Code

````pine
//@version=6
indicator("ORB + Volume + VWAP Breakout", shorttitle="ORB+Vol+VWAP", overlay=true)

// ═══ Inputs ═══
orMinutes  = input.int(30, "Opening Range (minutes)", minval=1, group="Opening Range")
sessionStr = input.session("0930-1600", "Regular Trading Session", group="Opening Range")
volMult    = input.float(1.5, "Volume Multiplier", minval=0.1, step=0.1, group="Filters")
volLen     = input.int(20, "Volume Average Length", minval=1, group="Filters")
showOR     = input.bool(true, "Show Opening Range",  group="Display")
showVWAP   = input.bool(true, "Show VWAP",           group="Display")

// ═══ Session Detection ═══
inSession  = not na(time(timeframe.period, sessionStr))
newSession = inSession and not inSession[1]

// ═══ Opening Range Tracking ═══
var float orHigh     = na
var float orLow      = na
var int   orStart    = na
var bool  orComplete = false

if newSession
    orHigh     := high
    orLow      := low
    orStart    := time
    orComplete := false

if inSession and not orComplete and not na(orStart)
    if time - orStart < orMinutes * 60 * 1000
        orHigh := math.max(orHigh, high)
        orLow  := math.min(orLow, low)
    else
        orComplete := true

// ═══ Indicators ═══
vwapVal = ta.vwap(hlc3)
volAvg  = ta.sma(volume, volLen)

// ═══ Breakout Logic ═══
priceBreak = orComplete and close > orHigh
volConfirm = volume > volMult * volAvg
aboveVWAP  = close > vwapVal

breakout      = priceBreak and volConfirm and aboveVWAP
firstBreakout = breakout and not breakout[1]   // fires once per breakout leg

// ═══ Plots ═══
plot(showOR and inSession ? orHigh : na, "OR High", color=color.new(color.blue, 0),   linewidth=2, style=plot.style_linebr)
plot(showOR and inSession ? orLow  : na, "OR Low",  color=color.new(color.orange, 0), linewidth=1, style=plot.style_linebr)
plot(showVWAP ? vwapVal : na,            "VWAP",    color=color.new(color.purple, 0), linewidth=2)

plotshape(firstBreakout, "Breakout", shape.triangleup, location.belowbar, color.new(color.lime, 0), size=size.small, text="BRK", textcolor=color.rgb(0, 0, 0))
bgcolor(firstBreakout ? color.new(color.green, 85) : na, title="Breakout Highlight")

// ═══ Alert ═══
alertcondition(firstBreakout, title="ORB Breakout",
     message="{{ticker}} broke above 30-min ORH with volume >1.5× avg and above VWAP at {{close}}")
````
