<!-- tradingview-pine-id: PUB;8397f5a99b084804b9bbf6ca38979de7 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Bolly Breakout Alerts - DAX & DOW

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
indicator("Bolly Breakout Alerts - DAX & DOW", overlay=true)

// ─────────────────────────────
// BOLLINGER BAND SETTINGS
// ─────────────────────────────

bbLength = input.int(20, "BB Length", minval=1)
bbStdDev = input.float(2.0, "BB StdDev", step=0.1)

// Fixed sessions - UK time
daxSession = input.session("0600-0820", "DAX Alert Window")
dowSession = input.session("1230-1450", "DOW Alert Window")

// ─────────────────────────────
// SYMBOL DETECTION
// ─────────────────────────────

isDax = syminfo.ticker == "GER40"
isDow = syminfo.ticker == "US30"

// ─────────────────────────────
// BOLLINGER BANDS
// ─────────────────────────────

basis = ta.sma(close, bbLength)
dev = bbStdDev * ta.stdev(close, bbLength)

upperBand = basis + dev
lowerBand = basis - dev

// ─────────────────────────────
// SESSION FILTERS
// Europe/London automatically handles GMT/BST
// ─────────────────────────────

inDaxSession = not na(
     time_close(
         timeframe.period,
         daxSession,
         "Europe/London"
     )
)

inDowSession = not na(
     time_close(
         timeframe.period,
         dowSession,
         "Europe/London"
     )
)

// ─────────────────────────────
// ONLY ALLOW 5-MINUTE CHART
// ─────────────────────────────

isFiveMinute = timeframe.isminutes and timeframe.multiplier == 5

// ─────────────────────────────
// DAX BREAKOUT CONDITIONS
// ─────────────────────────────

daxLongBreakout =
     isDax and
     isFiveMinute and
     barstate.isconfirmed and
     inDaxSession and
     close > upperBand

daxShortBreakout =
     isDax and
     isFiveMinute and
     barstate.isconfirmed and
     inDaxSession and
     close < lowerBand

// ─────────────────────────────
// DOW BREAKOUT CONDITIONS
// ─────────────────────────────

dowLongBreakout =
     isDow and
     isFiveMinute and
     barstate.isconfirmed and
     inDowSession and
     close > upperBand

dowShortBreakout =
     isDow and
     isFiveMinute and
     barstate.isconfirmed and
     inDowSession and
     close < lowerBand

// ─────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────

// DAX alerts
alertcondition(
     daxLongBreakout,
     title="DAX LONG Breakout",
     message="DAX LONG Bollinger breakout: GER40 5m candle closed above the upper Bollinger Band."
)

alertcondition(
     daxShortBreakout,
     title="DAX SHORT Breakout",
     message="DAX SHORT Bollinger breakout: GER40 5m candle closed below the lower Bollinger Band."
)

alertcondition(
     daxLongBreakout or daxShortBreakout,
     title="DAX Breakout - Either Direction",
     message="DAX Bollinger breakout detected on GER40 on a confirmed 5m candle."
)

// DOW alerts
alertcondition(
     dowLongBreakout,
     title="DOW LONG Breakout",
     message="DOW LONG Bollinger breakout: US30 5m candle closed above the upper Bollinger Band."
)

alertcondition(
     dowShortBreakout,
     title="DOW SHORT Breakout",
     message="DOW SHORT Bollinger breakout: US30 5m candle closed below the lower Bollinger Band."
)

alertcondition(
     dowLongBreakout or dowShortBreakout,
     title="DOW Breakout - Either Direction",
     message="DOW Bollinger breakout detected on US30 on a confirmed 5m candle."
)

// Optional combined alert for whichever supported market is active
alertcondition(
     daxLongBreakout or daxShortBreakout or dowLongBreakout or dowShortBreakout,
     title="DAX or DOW Breakout - Either Direction",
     message="Bollinger breakout detected on a supported 5m market."
)

// ─────────────────────────────
// VISUAL MARKERS
// ─────────────────────────────

plotshape(
     daxLongBreakout or dowLongBreakout,
     title="Long Breakout",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.small,
     text="BO"
)

plotshape(
     daxShortBreakout or dowShortBreakout,
     title="Short Breakout",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.small,
     text="BO"
)
````
