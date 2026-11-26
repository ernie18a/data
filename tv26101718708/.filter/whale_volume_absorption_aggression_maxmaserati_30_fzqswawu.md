# Whale Volume Absorption & Aggression @MaxMaserati 3.0

- url: https://www.tradingview.com/script/FZqSWAwu-Whale-Volume-Absorption-Aggression-MaxMaserati-3-0/
- type: indicator
- pine_id: PUB;74ce713c39884c76a0a2af61744ca466
- version: 1.0

## Description

Whale Volume Absorption & Aggression @MaxMaserati 3.0 

The Whale Volume Absorption & Aggression engine is a high-fidelity order flow diagnostic tool designed to decode the mechanical interaction between aggressive market participants and passive institutional liquidity. It identifies the presence of significant capital ("Whales") and determines whether that capital is driving price or being trapped by institutional walls.

Core Functionality & Logic
1. Institutional Volume Tiering
The indicator algorithmically categorizes every bar’s volume based on its deviation from the 20-period moving average. This creates a hierarchy of market participation:

Whale (Institutional): High-conviction entry or exit points where institutional money is clearly active.

Ultra (Climax): Anomalous, extreme volume prints that typically signify either trend exhaustion or major institutional ignition.

Mid-Tier & Retail: Standard daily business and low-impact passive liquidity.

2. Aggression Detection (The Hammer)
Aggression is identified when a Whale or Ultra volume tier is accompanied by a dominant Delta percentage. Mechanically, this confirms a "Sovereign" move where aggressive market orders have successfully cleared the opposing side of the order book, indicating high probability for price expansion.

3. Absorption Identification (The Wall)
Absorption occurs when Whale or Ultra volume enters the market, but the resulting Delta is neutral or low. This signals a high-intensity battle where an institutional "Wall" (Limit Orders) is absorbing the "Hammer" (Market Orders). The indicator labels these events and identifies which side is being absorbed (e.g., Buy Absorbed or Sell Absorbed).

4. Post-Absorption Verdict Tracking
The engine includes a specialized tracking module that monitors price action in a defined window following an absorption event. It issues a final verdict:

CONFIRMED: The passive Wall won the battle, and price reversed away from the absorption zone.

FAILED: The aggressive Hammer successfully chewed through the Wall, and price continued in the original direction.

Advanced Analytics Suite
Dual-Data Engine: The tool utilizes a high-resolution footprint request to extract 1:1 exchange-level Delta and Point of Control (POC). In environments where footprint data is unavailable, it switches to a Price Efficiency Proxy, modeling the relationship between candle displacement and range to maintain systematic consistency.

Normalized CVD (Cumulative Volume Delta): A rolling normalization of net aggression that tracks the broader trajectory of institutional money flow.

Delta % Line: A visual representation of net aggressive intensity, filtered through the volume tiering logic.

Delta Divergence: Visual markers that highlight instances of hidden demand or supply—where price direction moves opposite to the dominant aggressive volume.

How to Interpret the MMM Framework
Filter Noise: Focus exclusively on the Whale (Deep Green/Red) and Ultra (Cyan/Purple) histogram bars. These represent the only participants capable of shifting market structure.

Verify Execution: Use Strong Aggressive signals to confirm the health of a trend expansion. This proves the "Hammer" is in full control.

Anticipate Reversals: Monitor Absorption labels. These identify the exact price levels where institutional Walls are positioned. Use the Post-Absorption Verdict to confirm if the Wall has held before considering a counter-trend entry.

Disclaimer: This indicator is designed for professional structural analysis. It provides mechanical insights into institutional activity and should be used as part of a comprehensive trading plan.

## Source Code

````pine
//@version=6
indicator("Whale Volume Absorption & Aggression @MaxMaserati 3.0", shorttitle="Whale Volume @MaxMaserati 3.0", overlay=false, format=format.volume)

// =====================================================
// ⚙️ SETTINGS & THRESHOLDS
// =====================================================
group_settings = "Volume Thresholds"
volMaLength = input.int(20, "Volume MA Length", minval=1, group=group_settings, tooltip="The baseline average volume to compare against.")
midMult     = input.float(0.8, "Mid-Tier Multiplier", step=0.1, group=group_settings, tooltip="Volume >= this multiplier * MA is considered Mid-Tier.")
whaleMult   = input.float(2.0, "Whale Multiplier", step=0.1, group=group_settings, tooltip="Volume >= this multiplier * MA is considered Institutional Whale.")
ultraMult   = input.float(3.0, "Climax / HFT Multiplier", step=0.1, group=group_settings, tooltip="Volume >= this multiplier * MA is considered extreme climax/anomalous.")

// =====================================================
// 🎨 COLOR PALETTES
// =====================================================
group_colors = "Volume Colors"
// Sellers (Bearish Close)
col_sell_retail = input.color(color.new(#ff9800, 70), "Retail Seller (Low)", group=group_colors)
col_sell_mid    = input.color(color.new(#f44336, 30), "Mid-Tier Seller (Avg)", group=group_colors)
col_sell_whale  = input.color(color.new(#b71c1c, 0),  "Whale Seller (High)", group=group_colors)
col_sell_ultra  = input.color(color.new(#4a148c, 0),  "Ultra Seller Climax", group=group_colors)

// Buyers (Bullish Close)
col_buy_retail  = input.color(color.new(#81c784, 70), "Retail Buyer (Low)", group=group_colors)
col_buy_mid     = input.color(color.new(#4caf50, 30), "Mid-Tier Buyer (Avg)", group=group_colors)
col_buy_whale   = input.color(color.new(#1b5e20, 0),  "Whale Buyer (High)", group=group_colors)
col_buy_ultra   = input.color(color.new(#00bcd4, 0),  "Ultra Buyer Climax", group=group_colors)

// =====================================================
// 🧮 LOGIC & CALCULATIONS
// =====================================================
// Moving Average Volume Calculations
float volSma = ta.sma(volume, volMaLength)

// Determine if the candle is showing selling or buying pressure
bool isSeller = close < open
bool isBuyer  = close >= open

// Determine the Category based on multipliers
bool isUltra = volume >= (volSma * ultraMult)
bool isWhale = volume >= (volSma * whaleMult) and not isUltra
bool isMid   = volume >= (volSma * midMult) and not isWhale and not isUltra
bool isRetail= volume <  (volSma * midMult)

// Color Category Assignement 
color volColor = na

if isSeller
    if isUltra
        volColor := col_sell_ultra
    else if isWhale
        volColor := col_sell_whale
    else if isMid
        volColor := col_sell_mid
    else
        volColor := col_sell_retail
else if isBuyer
    if isUltra
        volColor := col_buy_ultra
    else if isWhale
        volColor := col_buy_whale
    else if isMid
        volColor := col_buy_mid
    else
        volColor := col_buy_retail

// =====================================================
// 📊 PLOTTING
// =====================================================
// Volume Histogram
plot(volume, title="Volume", style=plot.style_columns, color=volColor)

// Volume Moving Average line visual reference
plot(volSma, title="Volume Average", color=color.new(color.gray, 50), linewidth=1, style=plot.style_line)

// Optional: Add background highlights for Whale and Ultra prints so they stand out more
bgcolor(isSeller and isWhale ? color.new(col_sell_whale, 90) : na, title="Whale Seller Highlight")
bgcolor(isSeller and isUltra ? color.new(col_sell_ultra, 85) : na, title="Ultra Seller Highlight")
bgcolor(isBuyer and isWhale  ? color.new(col_buy_whale, 90) : na, title="Whale Buyer Highlight")
bgcolor(isBuyer and isUltra  ? color.new(col_buy_ultra, 85) : na, title="Ultra Buyer Highlight")
````
