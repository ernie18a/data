# Volume Breakout

- url: https://www.tradingview.com/script/2rd7aFiU/
- type: indicator
- pine_id: PUB;b4eb537fc9754c53b4cfb0a671f438f7
- version: 1.0

## Description

[b]Volume Breakout[/b] is a dynamic volume activity indicator designed to identify abnormal volume expansion relative to current market volatility conditions.

Unlike traditional fixed-length volume indicators, this script uses an adaptive moving average model based on Daily ATR percentage conditions. The volume baseline automatically adjusts according to market volatility, allowing the indicator to remain responsive across different assets and changing market environments.

The script classifies volume activity into multiple breakout strength categories by comparing current volume against a dynamically calculated average volume threshold.

Volume conditions are divided into:
- High Volume Breakout
- Mid Volume Breakout
- Low Volume Breakout

The indicator also distinguishes bullish and bearish participation using candle direction, allowing traders to quickly identify whether aggressive volume expansion is occurring alongside bullish price movement or bearish price movement.

Because the moving average period adapts automatically using ATR-based volatility conditions, the script is capable of responding differently during:
- High volatility environments
- Low volatility consolidation
- Expansion phases
- Compression phases

This adaptive approach helps reduce the limitations of static volume smoothing methods that may become less responsive during major volatility regime changes.

[b]Key Features:[/b]
- ATR-adaptive volume baseline
- Dynamic volume breakout detection
- Multi-level breakout classification
- Bullish and bearish participation recognition
- Volatility-responsive smoothing
- Lightweight histogram visualization
- Automatic high, mid, and low breakout alerts
- Clean and simplified volume structure analysis

The indicator is designed for traders who want a cleaner method for monitoring participation spikes, momentum expansion, and abnormal transactional activity without relying on overly complex volume frameworks.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// @Saupi Project
// @version=6
indicator(title='Volume Breakout', format=format.volume)

// Kalkulasi ATR dengan proteksi nilai 0
[atr_d, close_d] = request.security(syminfo.tickerid, "D", [ta.atr(14), close])
atr = math.max(1, nz(int(atr_d / close_d * 100), 7))

vol = volume

// Input multiplier
m_hi  = input(3.0, 'High Multiple')
m_mid = input(1.5, 'Mid Multiple')
m_low = input(0.5, 'Low Multiple')

// SMA volume dinamis berdasarkan ATR
sma = ta.sma(vol, atr)

// Deteksi arah candle
is_bull = close >= open

// ─────────────────────────────────────────────────────────
//  HIGH  → Hijau Neon (bull) | Merah Crimson (bear)
//  MID   → Abu sedang
//  LOW   → Abu gelap
//  BELOW → Abu sangat gelap
// ─────────────────────────────────────────────────────────
col_bar = vol >= (m_hi  * sma) ? (is_bull ? color.rgb(0,255,0,20) : color.rgb(255, 0, 221, 10) ) : // High  : emerald neon | crimson
          vol >= (m_mid * sma) ? (is_bull ? color.rgb(0,255,0,35) : color.rgb(255, 0, 221, 25) ) :                     // Mid   : abu sedang
          vol >= (m_low * sma) ? color.new(color.yellow, 30) :                         // Low   : abu gelap
                                 color.gray                            // Below : abu sangat gelap

// Plot histogram volume
plot(vol, title='Volume Breakout', style=plot.style_columns, color=col_bar)

// Alert conditions
alertcondition(vol >= (m_hi  * sma), title='High Bar',  message='Volume HIGH Breakout pada {{ticker}}')
alertcondition(vol >= (m_mid * sma), title='Mid Bar',   message='Volume MID Breakout pada {{ticker}}')
alertcondition(vol >= (m_low * sma), title='Low Bar',   message='Volume LOW Breakout pada {{ticker}}')
````
