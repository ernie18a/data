# Uranium Volume

- url: https://www.tradingview.com/script/TcaiBjHS/
- type: indicator
- pine_id: PUB;9a600183f30b436394f80e2c4dbbeec6
- version: 5.0

## Description

Uranium Volume — PVT Momentum

Uranium Volume is an experimental momentum indicator based on price percentage changes combined with the logarithm of trading volume. Its purpose is to provide a visual representation of relative price-volume pressure, helping traders observe moments of acceleration or weakening momentum.

🔬 How It Works

The indicator calculates a simplified PVT (Price-Volume Trend) change:

PVT Change = ((Current Price − Previous Price) / Previous Price) × log(Volume)

The price source used in the calculation can be selected by the user:

Close — closing price
HLCC4 — average of High, Low, and two Close values
HL2 — average of High and Low
HLC3 — average of High, Low, and Close

The resulting value is then smoothed using an EMA (Exponential Moving Average). The default period is 9.

📊 Visual Interpretation

The columns display the smoothed indicator value, while the column color is determined by the price/volume change of the current bar:

🟢 Lime: positive price change relative to the previous bar.
🔴 Red: negative price change.
🔵 Blue background: confirmed bar with a positive or neutral change.
🟠 Orange background: confirmed bar with a negative change.

The indicator can be used as a complementary tool to observe momentum, expansion, or loss of strength, together with price action, volume, trend analysis, and other technical-analysis tools.

⚙️ Settings

Price Mode: determines which price reference is used in the calculation.

MME Reactor Core: controls the EMA period applied to the PVT Change. Lower values make the indicator more responsive, while higher values provide a smoother reading.

⚠️ Important

Uranium Volume is a technical-analysis tool, not an automated buy or sell system. The indicator's colors and values should not be interpreted in isolation as guaranteed entry or exit signals.

The indicator uses price and volume data available on the chart and should be analyzed within the context of the selected asset and timeframe. Different markets may have different volume characteristics, so results may vary depending on the instrument.

No financial results are guaranteed. Users are responsible for their own investment decisions and risk management.

🧪 Indicator Name

The name "Uranium Volume" is a visual reference to the concept of energy and momentum and does not imply that the indicator is related to the uranium market or uranium-mining assets.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Canhoto-Medium

//@version=6
indicator("Uranium Volume", shorttitle="Vol-☢️", overlay=false)

// --- Inputs ---
price_sel = input.string("close", "Price Mode?", options=["close", "hlcc4", "hl2", "hlc3"])
ema_len   = input.int(9, "MME Reactor Core", minval=1)
tf_input  = input.timeframe("", "Timeframe", tooltip="Empty = chart timeframe")

mtfMode = input.string("Triple", "Alignment Mode", options=["Dual", "Triple"], display=display.none, group="🕒 Multi-Timeframe Alerts")
tf1     = input.timeframe("60",  "Timeframe 1", group="🕒 Multi-Timeframe Alerts", display=display.none)
tf2     = input.timeframe("240", "Timeframe 2", group="🕒 Multi-Timeframe Alerts", display=display.none)
tf3     = input.timeframe("D",   "Timeframe 3", group="🕒 Multi-Timeframe Alerts", display=display.none)

// --- Price mapping ---
f_price(sel) =>
    switch sel
        "close" => close
        "hlcc4" => hlcc4
        "hl2"   => hl2
        "hlc3"  => hlc3

// --- Core logic ---
f_pvt(sel, len) =>
    price = f_price(sel)
    chg   = (price - price[1]) / price[1] * math.log(math.max(volume, 1))
    [ta.ema(chg, len), chg]

[pvt_ema, pvt_change] = request.security(syminfo.tickerid, tf_input, f_pvt(price_sel, ema_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// --- Single bull/bear definition used everywhere ---
isBull = pvt_change > 0

plot(pvt_ema, "Volume Bull / Bear", color=isBull ? color.lime : color.red, style=plot.style_columns)
bgcolor(isBull ? color.new(color.blue, 75) : color.new(color.orange, 75), title="BG Color Bull / Bear")

// --- Sound alerts ---
volume_bull_realtime  = barstate.isrealtime and isBull
volume_bear_realtime  = barstate.isrealtime and not isBull
volume_bull_confirmed = barstate.isconfirmed and isBull
volume_bear_confirmed = barstate.isconfirmed and not isBull

alertcondition(volume_bull_realtime,  "Volume Bull — Real Time",  "Volume: Bullish pressure — Real Time")
alertcondition(volume_bear_realtime,  "Volume Bear — Real Time",  "Volume: Bearish pressure — Real Time")
alertcondition(volume_bull_confirmed, "Volume Bull — Confirmed",  "Volume: Bullish pressure — Confirmed")
alertcondition(volume_bear_confirmed, "Volume Bear — Confirmed",  "Volume: Bearish pressure — Confirmed")

// --- Multi-timeframe alignment ---
[_, chg1] = request.security(syminfo.tickerid, tf1, f_pvt(price_sel, ema_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[_, chg2] = request.security(syminfo.tickerid, tf2, f_pvt(price_sel, ema_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
[_, chg3] = request.security(syminfo.tickerid, tf3, f_pvt(price_sel, ema_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

bull1 = chg1 > 0
bull2 = chg2 > 0
bull3 = chg3 > 0

alignBull = isBull and bull1 and bull2 and (mtfMode == "Dual" or bull3)
alignBear = not isBull and not bull1 and not bull2 and (mtfMode == "Dual" or not bull3)

mtfBullish = barstate.isconfirmed and alignBull
mtfBearish = barstate.isconfirmed and alignBear

alertcondition(mtfBullish and not alignBull[1], "Vol-☢️ MTF Bullish Alignment", "Uranium Volume: bullish alignment across selected timeframes.")
alertcondition(mtfBearish and not alignBear[1], "Vol-☢️ MTF Bearish Alignment", "Uranium Volume: bearish alignment across selected timeframes.")
````
