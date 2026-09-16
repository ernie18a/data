<!-- tradingview-pine-id: PUB;9a600183f30b436394f80e2c4dbbeec6 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Uranium Volume

Source: https://www.tradingview.com/script/TcaiBjHS/

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

---

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

// --- Mapping compact names to actual price values ---
f_price(sel) =>
    switch sel
        "close" => close
        "hlcc4" => hlcc4
        "hl2"   => hl2
        "hlc3"  => hlc3

// --- Function holding all the logic (runs on the chosen timeframe) ---
f_pvt(sel, len) =>
    price      = f_price(sel)
    price_prev = barstate.isconfirmed[1] ? price[1] : price
    vol_safe   = math.max(volume, 1)
    pvt_change = ((price - price_prev) / price_prev) * math.log(vol_safe)

    alpha = 2 / (len + 1)
    var float pvt_ema = na
    if barstate.isconfirmed
        pvt_ema := na(pvt_ema) ? pvt_change : pvt_ema + alpha * (pvt_change - pvt_ema)

    [pvt_ema, pvt_change]

// --- Call via request.security on the selected timeframe ---
[pvt_ema, pvt_change] = request.security(syminfo.tickerid, tf_input, f_pvt(price_sel, ema_len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// --- Column color logic ---
color_pvt = pvt_change > 0 ? color.lime : color.red

// --- Plot columns ---
plot(pvt_ema, style=plot.style_columns, color=color_pvt, linewidth=4, title="Volume [0-Bull / 1-Bear]")

// --- Dynamic background ---
bgcolor(barstate.isconfirmed ? (pvt_change >= 0 ? color.new(color.blue, 75) : color.new(color.orange, 75)) : na)
````
