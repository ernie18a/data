<!-- tradingview-pine-id: PUB;ba44e7d6aac84a59ac32db9e88cce9fc -->
<!-- tradingviewscripts-format: 1 -->
# RSI SIGNAL

Source: https://www.tradingview.com/script/GWFOYtO7-CanadianGoose-RSI/

## Description

How To Add:
- Add indicator
- Adjust your settings
**** MAKE SURE ALERTS ARE TRIGGER ONCE PER BAR IN THE NEXT STEP***
- Add both alerts(OVERBOUGHT / OVERSOLD)
- If you change anything delete alarms and remake them
- Not sure if you need to remake them everyday but I would

Logic:
Hits RSI Signal limit -> Throws alarm -> Disables until RSI Signal is 50(Middle RSI) -> Resets

---

## Source Code

````pine
//@version=6
indicator("RSI SIGNAL", overlay=false)

rsiLength = input.int(14, "RSI Length")
sigLength = input.int(14, "Signal EMA Length")
upperLevel = input.int(65, "Upper Alert Level")
lowerLevel = input.int(35, "Lower Alert Level")

var bool armed = true

rsiVal = ta.rsi(close, rsiLength)
sigLine = ta.ema(rsiVal, sigLength)

if ta.cross(sigLine, 50)
    armed := true

finalUpperSignal = ta.crossover(sigLine, upperLevel) and armed
finalLowerSignal = ta.crossunder(sigLine, lowerLevel) and armed

alertcondition(finalUpperSignal, title="RSI SIGNAL OVERBOUGHT", message=" RSI OVERBOUGHT")
alertcondition(finalLowerSignal, title="RSI SIGNAL OVERSOLD", message="RSI OVERSOLD")

if finalUpperSignal or finalLowerSignal
    armed := false

// --- Plotting: signal line only ---
plot(sigLine, "Signal", color=color.orange, linewidth=2)
hline(50, "Midline", color=color.gray, linestyle=hline.style_solid)
hline(70, "Upper Level", color=color.red, linestyle=hline.style_solid)
hline(30, "Lower Level", color=color.green, linestyle=hline.style_solid)
hline(upperLevel, "Upper Alarm", color=color.green, linestyle=hline.style_dashed)
hline(lowerLevel, "Lower Alarm", color=color.red, linestyle=hline.style_dashed)

var table statusTable = table.new(position.top_right, 1, 1)
if barstate.islast
    table.cell(statusTable, 0, 0, armed ? "GOOSE ARMED" : "GOOSE DISARMED",
      bgcolor = armed ? color.green : color.red,
      text_color = color.white,
      text_size = size.normal)
````
