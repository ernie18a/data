<!-- tradingview-pine-id: PUB;a5d01a408d604164a5fdab0f32e0e17b -->
<!-- tradingviewscripts-format: 1 -->
# Stock Volume Spike by SPPATLE(In Lakhs - 100MA @ 10x)

Source: https://www.tradingview.com/script/9Dg4Xty8-Stock-Volume-Spike-by-SPPATLE-In-Lakhs-100MA-10x/

## Description

relative volume spike scanner to analyse unusual volume

---

## Source Code

````pine

// @author SPPATLE 
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © spp2788

//@version=6
indicator('Stock Volume Spike by SPPATLE(In Lakhs - 100MA @ 10x)', overlay = false)

// 1. User Input - Timeframe
userTf = input.timeframe('', title = 'Timeframe (Khali chhodein chart TF ke liye)', group = 'Settings')

// 2. Chart par khule hue stock ka Price aur Volume auto-fetch karna
stockPrice = request.security(syminfo.tickerid, userTf, close)
rawVolume = request.security(syminfo.tickerid, userTf, volume)

// 3. Volume ko 1,00,000 se divide karna (Lakhs me dikhane ke liye)
stockVolume = rawVolume / 100000

// 4. Volume ka 100-Period Moving Average aur uska 10x Threshold (Lakhs me)
volMa100 = ta.sma(stockVolume, 100)
targetVolMa = volMa100 * 10

// 5. Price UP/DOWN Check
isPriceUp = stockPrice >= stockPrice[1]

// 6. Color Logic (Green, Red, Yellow, Gray)
barColor = stockVolume >= targetVolMa ? isPriceUp ? color.green : color.red : isPriceUp ? color.yellow : color.gray

// 7. Indicator Plotting
plot(stockVolume, title = 'Volume (in Lakhs)', style = plot.style_columns, color = barColor)
plot(targetVolMa, title = '10x 100-Period Vol MA', color = color.orange, linewidth = 2)
````
