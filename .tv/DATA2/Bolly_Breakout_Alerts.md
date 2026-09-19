<!-- tradingview-pine-id: PUB;8397f5a99b084804b9bbf6ca38979de7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Bolly Breakout Alerts

Source: https://www.tradingview.com/script/ct64gYMM-Bolly-Breakout-Alerts/

## Description

Bolly Breakout Alerts is a simple session-based Bollinger Band breakout indicator designed for 5-minute trading setups.

It monitors for a confirmed candle close above the upper Bollinger Band or below the lower Bollinger Band, then allows alerts to trigger only during the selected trading window. This helps filter out unnecessary notifications outside the periods you actually trade. 📈

The script uses standard Bollinger Band settings:
20-period SMA
2.0 standard deviations
Close price as the source

Included features:

5-minute candle close confirmation
Long breakout alerts above the upper band
Short breakout alerts below the lower band
Combined “Either Direction” breakout alert
Separate DAX and Dow trading windows
UK time handling using Europe/London
Visual breakout markers on the chart
Session filtering to reduce unwanted alerts

Default session windows:
DAX: 06:00–08:20 UK time
Dow: 12:30–14:50 UK time

⚙️ Important setup

After adding the indicator to your chart, open the indicator settings and select the correct market for the chart you are using:

If the indicator is on a DAX chart, select DAX
If the indicator is on a Dow chart, select DOW

This is important because the selected market determines which alert time window is used.

Adding the indicator to the chart does not automatically create a TradingView alert. An alert still needs to be created manually.

Open TradingView’s alert setup and select Bolly Breakout Alerts as the condition, then select Bolly Breakout - Either Direction if you want to be notified when a candle closes outside either the upper or lower Bollinger Band.

For best results, set the alert frequency to Once Per Bar Close. 🔔

If you change the selected market, session times, or other indicator settings after creating an alert, it is advisable to recreate the alert so TradingView uses the updated settings.

The indicator is intended as an alerting and monitoring tool rather than a complete trading system. It does not provide stop losses, profit targets, or trade management rules.

Best used on a 5-minute chart.

⚠️ Always test alerts and session behaviour before relying on them in live trading.

---

## Source Code

````pine
//@version=6
indicator("Bolly Breakout Alerts", overlay=true)

// ─────────────────────────────
// SETTINGS
// ─────────────────────────────

// Market/session selection
market = input.string("DAX", "Market", options=["DAX", "DOW"])

// Bollinger Band settings
bbLength = input.int(20, "BB Length", minval=1)
bbStdDev = input.float(2.0, "BB StdDev", step=0.1)

// Sessions - UK time
daxSession = input.session("0600-0820", "DAX Alert Window")
dowSession = input.session("1230-1450", "DOW Alert Window")

// ─────────────────────────────
// BOLLINGER BANDS
// ─────────────────────────────

basis = ta.sma(close, bbLength)
dev = bbStdDev * ta.stdev(close, bbLength)

upperBand = basis + dev
lowerBand = basis - dev

// ─────────────────────────────
// SESSION FILTER
// Uses London time and therefore adjusts for BST/GMT automatically
// ─────────────────────────────

selectedSession = market == "DAX" ? daxSession : dowSession

inSession = not na(
     time_close(
         timeframe.period,
         selectedSession,
         "Europe/London"
     )
)

// ─────────────────────────────
// ONLY ALLOW 5-MINUTE CHART
// ─────────────────────────────

isFiveMinute = timeframe.isminutes and timeframe.multiplier == 5

// ─────────────────────────────
// BREAKOUT CONDITIONS
// ─────────────────────────────

longBreakout =
     isFiveMinute and
     barstate.isconfirmed and
     inSession and
     close > upperBand

shortBreakout =
     isFiveMinute and
     barstate.isconfirmed and
     inSession and
     close < lowerBand

// ─────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────

alertcondition(
     longBreakout,
     title="Bolly LONG Breakout",
     message="LONG Bollinger breakout: 5m candle closed above the upper Bollinger Band."
)

alertcondition(
     shortBreakout,
     title="Bolly SHORT Breakout",
     message="SHORT Bollinger breakout: 5m candle closed below the lower Bollinger Band."
)

// Optional combined alert
alertcondition(
     longBreakout or shortBreakout,
     title="Bolly Breakout - Either Direction",
     message="Bollinger breakout detected on a confirmed 5m candle."
)

// ─────────────────────────────
// VISUAL MARKERS
// ─────────────────────────────

plotshape(
     longBreakout,
     title="Long Breakout",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.small,
     text="BO"
)

plotshape(
     shortBreakout,
     title="Short Breakout",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.small,
     text="BO"
)
````
