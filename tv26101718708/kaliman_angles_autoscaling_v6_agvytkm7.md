# Kaliman Angles [Auto-Scaling] v6

- url: https://www.tradingview.com/script/AgvYtKm7-Kaliman-Angles-Auto-Scaling-v6/
- type: indicator
- pine_id: PUB;8e5220714cfc41d9a26f2222cf126cc3
- version: 1.0

## Description

Angles [Auto-Scaling] v6 is a high-precision, quantitative momentum tool designed to calculate the geometrical steepness of moving average trends. By isolating shifts in market velocity, this indicator acts as a reliable mechanical trigger for identifying exhausting trends or capturing early trend reversals.

Built natively in Pine Script v6, this version introduces powerful math-based normalization and absolute visual consistency across any asset or timeframe.

Key Features
Dynamic Auto-Scaling (ATR-Normalized)
Traditional chart angles break when you switch from a high-priced asset (like Bitcoin or Gold) to a low-priced one (like penny stocks), or when you zoom in/out on your screen. This script solves that flaw by dividing price points by the Average True Range (ATR). The calculated angles are based purely on volatility math, ensuring identical behavior and consistent performance across all tickers.

Configurable Multi-MA Core
Smooth your source data using your choice of four classic moving average types: Exponential (EMA), Hull (HMA), Simple (SMA), or Weighted (WMA).

Geometrical Pivot Filtering
The indicator evaluates the rate of change between structural swing points (Pivots). If a structural pivot prints with an angle that breaches your defined High/Low threshold rules, a reverse trend signal is triggered.

🛑 Strict Non-Repainting Guarantee
Many angle and pivot indicators look flawless in hindsight because they "repaint" (shift backward in time to paint past bars). Fusion: Angles v6 is strictly non-repainting.

Because it relies on structural pivots (pRight confirmation strength), the signals plot shapes and trigger alerts at the exact moment of bar closure when the pivot is confirmed (offset=0). Once a signal arrow prints on your chart, it is locked in stone—making it completely safe and reliable for live trading, forward testing, and algorithmic alert automation.

Input Guide
Strategy Rules: Adjust the high and low angle thresholds (in degrees) to filter out weak or shallow market movements.

Pivot Strength: Fine-tune Pivot Left Strength and Pivot Right Strength to control how much historical structural data the algorithm requires to confirm a genuine peak or trough.

## Source Code

````pine
//@version=6
indicator(title='Kaliman Angles [Auto-Scaling] v6', shorttitle='F-Angles', overlay=true, max_bars_back=4999, max_labels_count=500)

// --- Constants ---
float deg2RadConst = math.pi / 180
float rad2DegConst = 180 / math.pi

// --- Inputs ---
string Group5110 = '5110 Strategy: Exit on reverse trend - RULES'
float stgyReverseTrendAngleThresholdHigh = input.float(70.0, group=Group5110, minval=0.0, maxval=180.0, step=0.1, title='High Angle °') * deg2RadConst
float stgyReverseTrendAngleThresholdLow  = input.float(70.0, group=Group5110, minval=0.0, maxval=180.0, step=0.1, title='Low Angle °') * deg2RadConst

string Group5120 = '5120 Strategy: Exit on reverse trend - SETTINGS'
float srcInput                  = input.source(hl2, group=Group5120, title='Source')
string stgyReverseTrendModeSwitch = input.string('HMA', group=Group5120, title='MA variation', options=['EMA', 'HMA', 'SMA', 'WMA'])
int stgyReverseTrendLength      = input.int(2, group=Group5120, minval=1, title='Length')
int pLeft   = input.int(1, group=Group5120, minval=1, title='Pivot Left Strength')
int pRight  = input.int(1, group=Group5120, minval=1, title='Pivot Right Strength')

// --- Auto-Scaling Logic ---
// We use ATR to normalize the Y-axis so the "Angle" doesn't change when you switch 
// from a high-priced asset (like Gold) to a low-priced one.
float scalingATR = ta.atr(14)

// --- Functions ---
hullma(s, p) =>
    ta.wma(2 * ta.wma(s, math.round(p / 2)) - ta.wma(s, p), math.round(math.sqrt(p)))

get_ma(mode, src, len) =>
    switch mode
        'EMA' => ta.ema(src, len)
        'HMA' => hullma(src, len)
        'SMA' => ta.sma(src, len)
        'WMA' => ta.wma(src, len)
        => float(na)

// Normalizing the price points by ATR allows the angle to "resize" with the chart volatility
AngleFromXY(x1, y1, x2, y2, x3, y3, scale) =>
    float num = (y2/scale) * (x1 - x3) + (y1/scale) * (x3 - x1) + (y3/scale) * (x2 - x1)
    float den = (x2 - x1) * (x1 - x3) + ((y2/scale) - (y1/scale)) * ((y1/scale) - (y3/scale))
    math.atan(math.abs(num / den))

// --- Calculations ---
float sRevTrend = stgyReverseTrendLength == 1 ? srcInput : get_ma(stgyReverseTrendModeSwitch, srcInput, stgyReverseTrendLength)

float sRTPivotHigh = ta.pivothigh(sRevTrend, pLeft, pRight)
float sRTPivotLow  = ta.pivotlow(sRevTrend, pLeft, pRight)

// Normalized Angle Calculations
float sRTPivotHighAngle = not na(sRTPivotHigh) ? AngleFromXY(float(pRight), sRevTrend[pRight], float(pRight + pLeft), sRevTrend[pRight + pLeft], 0.0, sRevTrend, scalingATR) : na
float sRTPivotLowAngle  = not na(sRTPivotLow)  ? AngleFromXY(float(pRight), sRevTrend[pRight], float(pRight + pLeft), sRevTrend[pRight + pLeft], 0.0, sRevTrend, scalingATR) : na

bool sRTPivotHighAngleTriggered = sRTPivotHighAngle <= stgyReverseTrendAngleThresholdHigh
bool sRTPivotLowAngleTriggered  = sRTPivotLowAngle  <= stgyReverseTrendAngleThresholdLow

// --- Visuals ---
color highCol = color.new(color.red, 20)
color lowCol  = color.new(color.green, 20)

// Arrows print on confirmation (offset=0) to remain Non-Repainting
plotshape(sRTPivotHighAngleTriggered, title='High Pivot', style=shape.arrowdown, location=location.abovebar, color=highCol, size=size.small)
plotshape(sRTPivotLowAngleTriggered,  title='Low Pivot',  style=shape.arrowup,   location=location.belowbar, color=lowCol,  size=size.small)

color sRevTrendColor = sRevTrend > sRevTrend[1] ? lowCol : highCol
plot(sRevTrend, color=sRevTrendColor, linewidth=2, title='Angles Source')

// --- Alerts ---
if sRTPivotHighAngleTriggered
    alert("Sharp High Pivot Angle Detected", alert.freq_once_per_bar)

if sRTPivotLowAngleTriggered
    alert("Sharp Low Pivot Angle Detected", alert.freq_once_per_bar)
````
