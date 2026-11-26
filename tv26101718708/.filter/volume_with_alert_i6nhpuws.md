# Volume with Alert

- url: https://www.tradingview.com/script/I6NhpUws/
- type: indicator
- pine_id: PUB;5c636a5cc0fd4f0193ba736e3e643203
- version: 1.0

## Description

Volume with Alert

DESCRIPTION
Volume with Alert is a lightweight volume indicator built to make abnormal volume spikes easy to spot and to trigger alerts automatically. It plots volume as colored columns, adds an optional volume moving average for visual context, and highlights any bar whose volume meets or exceeds a threshold you define — no manual line-watching required.

WHAT IT'S MADE OF
- Volume histogram: standard up/down colored volume bars.
- Threshold line: a dashed horizontal line at the volume level you set, so you can see at a glance how far current volume is from your alert level.
- Volume moving average: a simple moving average of volume, plotted purely for visual reference — it does not affect the alert.
- Highlight color: any bar with volume greater than or equal to your threshold turns yellow, instantly flagging high-volume bars on the chart.

INPUTS
- "Alert when volume is ≥ to": set your own fixed volume threshold, in the instrument's native volume units. Any bar reaching this value is highlighted and can trigger an alert.
- "Volume moving average length (visual only)": the number of bars used to calculate the moving average line. Purely visual — adjust it to smooth or tighten the average as you like.

HOW TO SET AN ALERT
1. Add the indicator to your chart and set your threshold in the settings.
2. Right-click the chart (or press Alt+A) and choose "Add alert."
3. Under "Condition," select "Vol Alert," then choose "Volume exceeds threshold."
4. Choose "Once Per Bar" to be notified in real time as the bar forms, or "Once Per Bar Close" to wait until the bar closes before alerting.
5. Customize the alert message if needed and save.

NOTES
- The threshold is a fixed value, so tune it per instrument and timeframe — volume scales vary a lot between forex, futures, and stocks.
- The moving average is informational only; it does not gate or influence the alert condition.

## Source Code

````pine
//@version=6
indicator("Volume with Alert", shorttitle="Vol Alert", format=format.volume)

// ── INPUTS ──────────────────────────────────────────────────────────
threshold = input.float(1000, title="Alert when volume is ≥ to", minval=0)
maLength  = input.int(20, title="Volume moving average length (visual only)", minval=1)

// ── CALCULATIONS ────────────────────────────────────────────────────
vol   = volume
maVol = ta.sma(vol, maLength)

isBullish = close >= open
baseColor = isBullish ? color.new(color.teal, 0) : color.new(color.red, 0)

triggered = vol >= threshold
finalColor = triggered ? color.new(color.yellow, 0) : baseColor

// ── PLOTS ───────────────────────────────────────────────────────────
plot(vol, title="Volume", style=plot.style_columns, color=finalColor)
plot(maVol, title="Volume Moving Average", color=color.new(color.blue, 0), linewidth=1)
hline(threshold, title="Threshold Line", color=color.new(color.orange, 40), linestyle=hline.style_dashed)

// ── ALERT ───────────────────────────────────────────────────────────
alertcondition(triggered, title="Volume exceeds threshold", message="High volume on {{ticker}} ({{interval}}): exceeds the configured threshold.")
````
