# Price Action Bands | Trend & Volatility [RadixAlgo]

- url: https://www.tradingview.com/script/EWtyylH1-Price-Action-Bands-Trend-Volatility-RadixAlgo/
- type: indicator
- pine_id: PUB;e923444898c04fe99ec97794882d0c7b
- version: 1.0

## Description

🔶[b]About the Indicator[/b]

Price action often looks simple after the move is complete, but while the market is moving, traders usually need more context to understand whether price is trending, overextended, pulling back, or simply moving inside normal volatility. This price action indicator was built to make this context easier to read directly on the chart. 

It combines a dynamic moving average baseline with upper and lower volatility bands, giving traders a structured way to follow trend direction, measure price extension, analyze volatility, and observe how price reacts around key dynamic support and resistance zones.

[image]https://www.tradingview.com/x/7x3r4N6e/[/image]

At the center of the indicator is a customizable trend baseline that can be calculated with different moving average types, including SMA, EMA, HMA, RMA, WMA, SWMA, and VWMA. The baseline changes color based on the current trend state, helping users distinguish bullish and bearish market conditions without adding unnecessary visual noise. 

Around this baseline, the indicator plots adaptive volatility bands using either ATR or Standard Deviation. The upper red bands highlight areas where price may be extended to the upside, while the lower green bands show where price may be stretched to the downside.

This isn’t one of those indicators that tries to tell you exactly when to buy or sell. It’s more like a lens that helps you see what the market is actually doing in real time. Sometimes you’ll notice price hugging the bands during a strong trend, other times it drifts back toward the baseline after stretching too far. 

That’s where the real insight comes from. You can tweak the moving average type, adjust how wide the bands are, or smooth things out depending on how fast or slow you like to read the chart. Whether you’re watching quick intraday moves or letting a swing trade develop over days, it naturally adapts to your style without forcing a rigid system on you.


🔶[b]How It Works[/b]

The logic behind Price Action Bands | Trend & Volatility [RadixAlgo] starts with a dynamic trend baseline. This baseline is the central reference point of the indicator and acts as the main structure around which price action is interpreted. 

Instead of forcing every market into one fixed moving average model, the indicator allows traders to choose between several moving average types, including SMA, EMA, HMA, RMA, WMA, SWMA, and VWMA. 

[image]https://www.tradingview.com/x/6dcLd7ko/[/image]

Each one reads the market slightly differently. SMA provides a classic and balanced view of the average price, EMA reacts faster to recent price changes, HMA is smoother while still being responsive, RMA is useful for softer trend tracking, WMA gives more importance to recent candles, SWMA creates a smoother short-term baseline, and VWMA includes volume in the calculation, making it useful when traders want the trend line to reflect both price and trading activity.

[image]https://www.tradingview.com/x/qA2Ryzoa/[/image]

After the baseline is calculated, the indicator compares it with a smoothed version of itself. This creates the trend state logic. When the baseline is positioned above its smoothed signal line, the market is treated as being in a bullish trend state, and the trend area is highlighted in blue. 

When the baseline moves below the smoothed signal line, the market is treated as being in a bearish trend state, and the trend area is highlighted in orange. This does not mean that the indicator is generating automatic buy or sell signals. Instead, it gives traders a cleaner way to understand whether the current price action is aligned with bullish pressure or bearish pressure.

The second major part of the indicator is the volatility band system. Around the trend baseline, the script builds upper and lower bands that expand and contract based on market conditions. These bands can be calculated using either ATR or Standard Deviation. ATR measures the actual range of price movement and is useful for understanding how much the market is moving from candle to candle. 

[image]https://www.tradingview.com/x/1QqsE7jo/[/image]

It is especially helpful in volatile markets, breakout phases, and fast price movements. Standard Deviation, on the other hand, measures how far the baseline or price behavior is spread from its average condition. This makes it useful for identifying statistical price extension, compression, and overextended market areas.

The indicator uses two band levels on each side of the baseline: inner bands and outer bands. The inner bands represent a moderate volatility zone, while the outer bands represent a more extreme price extension area. When price moves into the upper red bands, it shows that price is stretched above the trend baseline. 

This can happen during strong bullish continuation, aggressive breakout movement, or an overextended upside condition. When price reaches the lower green bands, it shows that price is stretched below the trend baseline. This can appear during strong bearish continuation, downside volatility expansion, or an overextended sell-side move.

[image]https://www.tradingview.com/x/LDHV6fUx/[/image]

The upper and lower bands should not be read as simple overbought and oversold levels. This is where the indicator becomes more than just a basic band framework. Price can touch an upper band and continue higher if the trend is strong, or it can leave the upper band and return toward the baseline when momentum starts to fade. 

The same logic applies to the lower bands. A move into the lower band can signal strong bearish pressure, but if price exits the band and begins moving back toward the baseline, traders may start watching for a possible reaction, correction, or mean-reversion move. The value comes from reading the relationship between price, the baseline, the trend state, and the volatility zones together.

In bullish conditions, traders usually focus on how price behaves around the blue trend baseline, the upper volatility bands, and pullbacks toward the central structure. A bullish market may show price holding above the baseline, reacting from it, or expanding toward the upper bands as volatility increases. In this environment, pullbacks toward the baseline can help traders evaluate whether the trend is still supported, while movement into the upper bands can show momentum expansion or price extension. 

[image]https://www.tradingview.com/x/lPMraZRV/[/image]

In bearish conditions, the logic is reversed. Traders watch how price behaves below the baseline, how it reacts around the orange trend state, and whether downside movement reaches the lower green bands. Pullbacks toward the baseline may act as areas where bearish pressure returns, while movement into the lower bands can show strong downside volatility or stretched price action.

[image]https://www.tradingview.com/x/fTzUHYVy/[/image]

Because the indicator does not place automatic signals on the chart, the trader remains responsible for interpreting the setup. A breakout, pullback, exit from band, or trend continuation condition is not defined by one single line touch. It is read through context: the color of the trend baseline, the position of price relative to the baseline, the distance between price and the bands, and the way candles react after entering or leaving a volatility zone. This makes the tool flexible for different strategies, including trend-following, breakout trading, pullback trading, volatility analysis, and mean-reversion analysis, while still keeping the chart visually clean.


🔶[b]Input Parameters[/b]

🔹Moving Average Type
Selects the moving average used as the main trend baseline. The available options are SMA, EMA, HMA, RMA, WMA, SWMA, and VWMA. Each moving average type reacts differently to price movement, so traders can choose the one that best matches their trading style.

🔹Moving Average Period
Defines the length of the moving average baseline. Higher values create a smoother and slower trend line, while lower values make the baseline react faster to recent price changes.

🔹Trend Smoothing Period
Controls the smoothing of the trend signal line. Lower values make the trend state more sensitive to changes, while higher values create a smoother and more stable trend reading.

🔹Band Method
Determines how the volatility bands are calculated. Traders can choose between ATR and Standard Deviation. ATR measures market range and movement, while Standard Deviation measures price dispersion around the baseline.

🔹ATR Period
Sets the lookback period for the ATR calculation. This option is active when the Band Method is set to ATR. A shorter period reacts faster to volatility changes, while a longer period creates a smoother volatility reading.

🔹Standard Deviation Period
Sets the lookback period for the Standard Deviation calculation. This option is active when the Band Method is set to Standard Deviation. It controls how price dispersion is measured for the volatility bands.

🔹Band Smoothing Period
Smooths the upper and lower bands to reduce short-term fluctuations. Higher values make the bands more stable, while lower values make them more responsive to recent market movement.

🔹Inner Band Multiplier
Controls the distance of the inner bands from the trend baseline. The inner bands represent the closer volatility zone and can help traders observe moderate price extension.

🔹Outer Band Multiplier
Controls the distance of the outer bands from the trend baseline. The outer bands represent a wider volatility zone and can help traders identify stronger price extension or more extreme market movement.


🔶[b]Summary[/b]

Price Action Bands | Trend & Volatility [RadixAlgo] brings trend direction, price action analysis, and volatility bands into one clean chart-based framework. By combining a customizable moving average baseline with adaptive upper and lower bands, the indicator helps traders understand whether price is following the current trend, pulling back toward dynamic support and resistance, expanding with volatility, or moving into an overextended area. The colored trend baseline gives a quick view of bullish or bearish market conditions, while the ATR and Standard Deviation band methods allow the volatility zones to adapt to different market structures, trading styles, and timeframes.

This indicator is not designed to replace trader judgment with automatic buy and sell signals. Instead, it gives users a practical way to interpret trend-following setups, breakout conditions, pullback opportunities, exit-from-band behavior, mean-reversion zones, and volatility expansion directly on the chart. With flexible settings for moving average type, moving average period, trend smoothing, band method, band smoothing, and inner or outer band multipliers, Price Action Bands can be adjusted for scalping, intraday trading, swing trading, and broader market analysis while keeping the chart readable and focused on real price action.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © radixalgo

//@version=6
indicator("Price Action Bands | Trend & Volatility [RadixAlgo]", "RadixAlgo | PAB", overlay = true)

//------------------------------------------------------------------------------
// INPUTS
//------------------------------------------------------------------------------

// Trend baseline settings
MAT  = input.string('HMA', 'Moving Average Type', ['SMA', 'EMA', 'HMA', 'RMA', 'WMA', 'SWMA', 'VWMA'],
     tooltip = 'Select the moving average used as the trend baseline.')
MAP  = input.int(200, 'Moving Average Period',
     tooltip = 'Higher values create a smoother and slower trend baseline.')
TSP  = input.int(21, 'Trend Smoothing Period',
     tooltip = 'Controls trend sensitivity. Lower values react faster to trend changes.')

// Volatility band settings
BM   = input.string("Standard Deviation", "Band Method", ["ATR", "Standard Deviation"],
     tooltip = 'Choose how band width is calculated.')
ATRP = input.int(21, "ATR Period", active = BM == "ATR" ? true : false,
     tooltip = 'ATR lookback period used to calculate band width.')
SDP  = input.int(200, "Standard Deviation Period", active = BM != "ATR" ? true : false,
     tooltip = 'Lookback period used to measure price dispersion.')
BSP  = input.int(200, 'Band Smoothing Period',
     tooltip = 'Smooths the bands and reduces short-term fluctuations.')
IBM  = input.float(2.5, "Inner Band Multiplier", step = 0.1,
     tooltip = 'Distance of the inner bands from the baseline.')
OBM  = input.float(3.5, "Outer Band Multiplier", step = 0.1,
     tooltip = 'Distance of the outer bands from the baseline.')


//------------------------------------------------------------------------------
// TREND BASELINE
// Select the moving average used as the core trend reference.
//------------------------------------------------------------------------------

float Base = switch MAT
    "SMA"  => ta.sma(close, MAP)
    "EMA"  => ta.ema(close, MAP)
    "HMA"  => ta.hma(close, MAP)
    "RMA"  => ta.rma(close, MAP)
    "WMA"  => ta.wma(close, MAP)
    "SWMA" => ta.swma(close)
    "VWMA" => ta.vwma(close, MAP)


//------------------------------------------------------------------------------
// VOLATILITY MEASUREMENT
// Bands can be expanded using either ATR or Standard Deviation.
//------------------------------------------------------------------------------

ATR = ta.atr(ATRP)
SD  = ta.stdev(Base, SDP)


//------------------------------------------------------------------------------
// BAND CALCULATION
// Creates two volatility zones:
//
// Inner Bands  -> moderate extension area
// Outer Bands  -> extreme extension area
//------------------------------------------------------------------------------

High_Up   = ta.ema(ta.ema(Base, MAP) + (BM == "Standard Deviation" ? SD : ATR) * OBM, BSP)
Low_Up    = ta.ema(ta.ema(Base, MAP) + (BM == "Standard Deviation" ? SD : ATR) * IBM, BSP)

High_Down = ta.ema(ta.ema(Base, MAP) - (BM == "Standard Deviation" ? SD : ATR) * OBM, BSP)
Low_Down  = ta.ema(ta.ema(Base, MAP) - (BM == "Standard Deviation" ? SD : ATR) * IBM, BSP)


//------------------------------------------------------------------------------
// PLOTS
// Trend baseline and volatility bands.
//------------------------------------------------------------------------------

BaseLine    = plot(Base, title = "Trend Baseline", color = Base >= ta.ema(Base, TSP) ? #00e5ff : #ffae00, linewidth = 2, force_overlay = true)
BaseLine_MA = plot(ta.ema(Base, TSP), title = "Trend Signal", color = Base >= ta.ema(Base, TSP) ? #00e5ff : #ffae00, linewidth = 2, force_overlay = true)

Lvl_Low_Down  = plot(Low_Down, title = "Lower Inner Band", color = #39FF14, linewidth = 2, force_overlay = true)
Lvl_High_Down = plot(High_Down, title = "Lower Outer Band", color = #39FF14, linewidth = 2, force_overlay = true)

Lvl_Low_Up    = plot(Low_Up, title = "Upper Inner Band", color = #ff0055, linewidth = 2, force_overlay = true)
Lvl_High_Up   = plot(High_Up, title = "Upper Outer Band", color = #ff0055, linewidth = 2, force_overlay = true)

Lvl_Up_Avg    = plot(math.avg(Low_Up, High_Up), title = "Upper Band Midline", color = na, force_overlay = true)
Lvl_Down_Avg  = plot(math.avg(Low_Down, High_Down), title = "Lower Band Midline", color = na, force_overlay = true)


//------------------------------------------------------------------------------
// VISUAL ZONES
// Green zone  -> lower volatility region
// Red zone    -> upper volatility region
//------------------------------------------------------------------------------

fill(Lvl_High_Down, Lvl_Down_Avg, High_Down, math.avg(Low_Down, High_Down), #37ff1449, #37ff141a, title = "Lower Outer Zone")
fill(Lvl_Low_Down , Lvl_Down_Avg, Low_Down , math.avg(Low_Down, High_Down), #37ff1449, #37ff141a,title = "Lower Inner Zone")

fill(Lvl_High_Up  , Lvl_Up_Avg, High_Up, math.avg(Low_Up, High_Up), #ff005565, #ff005518, title = "Upper Outer Zone")
fill(Lvl_Low_Up   , Lvl_Up_Avg, Low_Up , math.avg(Low_Up, High_Up), #ff005565, #ff005518, title = "Upper Inner Zone")


//------------------------------------------------------------------------------
// TREND STATE HIGHLIGHT
// Blue  -> bullish trend state
// Orange -> bearish trend state
//------------------------------------------------------------------------------

fill(BaseLine, BaseLine_MA, color = Base >= ta.ema(Base, 21) ? #00e5ff4f : #ffae0052, title = "Trend State")
````
