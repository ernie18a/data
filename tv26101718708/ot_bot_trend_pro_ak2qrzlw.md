# OT Bot trend Pro

- url: https://www.tradingview.com/script/ak2QRZLW/
- type: indicator
- pine_id: PUB;91aa67db605847ce983ca7a478ccb3c4
- version: 1.0

## Description

OT Bot Supertrend Pro: The Ultimate Trading Guide
The OT Bot Supertrend Pro is an advanced trend-following system. It combines momentum (OT Bot), trend direction (SMA ), and volatility-based support/resistance (Supertrend), all filtered by trend intensity (ADX).
1. The Power of the ADX Filter (Trend Intensity)
Before looking for Buy/Sell signals, the indicator checks the ADX (Average Directional Index) to ensure you aren't trading in a "dead" or "exhausted" market.
• ADX < 20 (Sideways/Weak): The market is flat. Signals are hidden to prevent "Whipsaws" (losing trades in a range).
• ADX 25–40 (The Sweet Spot): The trend is healthy and active. Signals are visible and ready for entry.
• ADX > 40 (Overextended): The trend is too strong and likely to reverse soon. Signals are hidden to prevent "Buying the Top" or "Selling the Bottom."
2. Entry Strategy (The 4-Step Checklist)
To maximize accuracy, only enter a trade when all four conditions are met.
Buy Signal (Long Entry)
1. OT Bot: A "Buy" label appears, and candles turn Blue.
2. SMA : Price must be Above the Yellow line.
3. Supertrend: The dashed line must be Green (acting as support).
4. ADX: Current value must be between 20 and 40 (indicated by the Green dashboard).
Sell Signal (Short Entry)
1. OT Bot: A "Sell" label appears, and candles turn Purple.
2. SMA : Price must be Below the Yellow line.
3. Supertrend: The dashed line must be Red (acting as resistance).
4. ADX: Current value must be between 25 and 40 (indicated by the Green dashboard).
3. Precision Stop Loss (SL) Management
Your Stop Loss is dynamic, using the Supertrend line as a shield. We add a buffer of 100–200 points to avoid being stopped out by minor price spikes.
• For Buy Positions:$$Stop Loss = \text{Supertrend Price} - (100 \text{ to } 200 \text{ points})$$
• For Sell Positions:$$Stop Loss = \text{Supertrend Price} + (100 \text{ to } 200 \text{ points})$[symbol="OMXSTO:NOTE"]OMXSTO:NOTE[/symbol] on "Points": > * Gold (XAUUSD): 1.00 USD movement = 100 points.
• Forex: The 5th decimal place (0.00001) = 1 point.
4. Exit & Take Profit (TP)
You can use two effective methods to lock in profits:
1. Fixed Risk/Reward: Target a ratio of 1:1.5 or 1:2. If your SL is 200 points, set your TP at 300–400 points.
2. Trend Transition: Close the trade if the candle color changes (e.g., Blue to Purple) or the Supertrend changes color, even if the OT Bot hasn't issued a new signal yet.
5. Pro-Tips for Success
• Recommended Timeframes: Best used on 15m, 1H, or 4H. Using very low timeframes (1m/5m) with ATR 1 may result in too many signals.
• Dashboard Check: Always look at the ADX Dashboard (Top Right). If it is Red, stay out of the market regardless of the "Buy/Sell" labels.
• Confirmation is King: Never "anticipate" a signal. Wait for the candle to Close to confirm the labels and colors before clicking buy or sell.

## Source Code

````pine
//@version=5
indicator("OT Bot Supertrend Pro", overlay=true)

// ==========================================
// ส่วนที่ 1: ADX Filter (Average Directional Index)
// ==========================================
adx_len = input.int(14, title="ADX Smoothing")
di_len = input.int(14, title="DI Length")
[plusDI, minusDI, adxValue] = ta.dmi(di_len, adx_len)

// Conditions: Show signals only when 25 <= ADX <= 40
is_trend_active = adxValue >= 25 and adxValue <= 40

// ==========================================
// ส่วนที่ 2: OT Bot Supertrend Calculation
// ==========================================
a = input.float(2.0, title="OT Bot Key Value (Sensitivity)")
c = input.int(1, title="OT Bot ATR Period")
h = input.bool(true, title="OT Bot: Signals from Heikin Ashi Candles")
sma_length = input.int(17, title="SMA 17 Length")

// Heikin Ashi Calculation
ha_ticker = ticker.heikinashi(syminfo.tickerid)
ha_close = request.security(ha_ticker, timeframe.period, close)
src_ot = h ? ha_close : close

// OT Bot Trailing Stop Calculation
xATR_ot = ta.atr(c)
nLoss_ot = a * xATR_ot
var float xATRTrailingStop = 0.0

// Fixed the typo: Changed nLoss_ut to nLoss_ot
xATRTrailingStop := src_ot > nz(xATRTrailingStop[1], 0) and src_ot[1] > nz(xATRTrailingStop[1], 0) ? math.max(nz(xATRTrailingStop[1]), src_ot - nLoss_ot) : src_ot < nz(xATRTrailingStop[1], 0) and src_ot[1] < nz(xATRTrailingStop[1], 0) ? math.min(nz(xATRTrailingStop[1]), src_ot + nLoss_ot) : src_ot > nz(xATRTrailingStop[1], 0) ? src_ot - nLoss_ot : src_ot + nLoss_ot

// SMA 17 (Yellow Line)
sma17 = ta.sma(close, sma_length)
plot(sma17, color=color.yellow, title="SMA 17", linewidth=2)

// ==========================================
// ส่วนที่ 3: Supertrend (Dashed Line)
// ==========================================
st_atr_length = input.int(10, title="Supertrend ATR Length")
st_factor = input.float(2.0, title="Supertrend Factor")
[supertrend, direction] = ta.supertrend(st_factor, st_atr_length)
plot(supertrend, title="Supertrend Line", color=direction < 0 ? color.green : color.red, linewidth=2, style=plot.style_linebr)

// ==========================================
// ส่วนที่ 4: Signal Logic with ADX Filter
// ==========================================
ema1 = ta.ema(src_ot, 1)
above = ta.crossover(ema1, xATRTrailingStop)
below = ta.crossunder(ema1, xATRTrailingStop)

buy_signal  = (src_ot > xATRTrailingStop and above) and is_trend_active
sell_signal = (src_ot < xATRTrailingStop and below) and is_trend_active

plotshape(buy_signal,  title="OT Buy",  text='Buy',  style=shape.labelup,   location=location.belowbar, color=color.blue,   textcolor=color.white, size=size.tiny)
plotshape(sell_signal, title="OT Sell", text='Sell', style=shape.labeldown, location=location.abovebar, color=color.purple, textcolor=color.white, size=size.tiny)

barcolor(src_ot > xATRTrailingStop ? color.blue : color.purple)

// ==========================================
// ส่วนที่ 5: ADX Dashboard
// ==========================================
var table adx_table = table.new(position.top_right, 1, 1)
adx_color = is_trend_active ? color.green : color.red
if barstate.islast
    table.cell(adx_table, 0, 0, "ADX: " + str.tostring(adxValue, "#.##"), bgcolor=adx_color, text_color=color.white)
````
