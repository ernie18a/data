//+------------------------------------------------------------------+
//|                                                      ParamUX.mqh |
//|                                     Copyright©2023. Ritz EAneha© |
//|                          https://www.mql5.com/en/users/ritzfalih |
//+------------------------------------------------------------------+
#property copyright "Copyright©2023. Ritz EAneha©"
#property link      "https://www.mql5.com/en/users/ritzfalih"

//+------------------------------------------------------------------+
//| ENUMS                                                            |
//+------------------------------------------------------------------+
enum ENUM_MM_TYPE
{
    MM_FIXED_LOT    = 0, // Use a fixed lot size
    MM_RISK_PERCENT = 1  // Calculate lot size based on risk percentage
};

enum ENUM_RISK_BASE
{
    RISK_BASE_BALANCE = 0, // Calculate risk from account balance
    RISK_BASE_EQUITY  = 1  // Calculate risk from account equity
};

enum ENUM_SESSION_MODE
{
    SESSION_ALL_DAY = 0, // Allow trading all day
    SESSION_CUSTOM  = 1  // Use custom trading sessions
};

enum ENUM_SLTP_MODE
{
    SLTP_FIXED = 0, // Use fixed SL and TP values
    SLTP_ATR   = 1  // Calculate SL and TP using ATR
};

//+------------------------------------------------------------------+
//| RISK & MONEY MANAGEMENT                                          |
//+------------------------------------------------------------------+
input group "------------------- Risk & Money Management ---"

input ulong            InpMagicNumber       = 101010;          // Unique magic number
input ENUM_MM_TYPE     InpMMType            = MM_RISK_PERCENT; // Money management mode
input double           InpFixedLot          = 0.01;            // Fixed lot size
input double           InpRiskPercent       = 1.0;             // Risk percentage per trade
input ENUM_RISK_BASE   InpRiskBase          = RISK_BASE_BALANCE; // Risk calculation base
input int              InpMaxTotalPositions = 5;               // Maximum total positions managed by the EA
input int              InpMaxPositionsPerDirection = 3;        // Maximum positions in the same direction

//+------------------------------------------------------------------+
//| EXECUTION & TARGET SETTINGS                                      |
//+------------------------------------------------------------------+
input group "------------------- Execution & Target Settings ---"

input ENUM_SLTP_MODE   InpSLTPMode          = SLTP_ATR;      // SL/TP calculation mode
input double           InpTargetPips        = 200.0;            // Take profit target in pips
input double           InpStopLossPips      = 120.0;            // Stop loss distance in pips
input double           InpMaxSpreadPips     = 200.0;             // Maximum allowed SPREAD in pips
input int              InpDeviationPoints   = 20;               // Maximum allowed price deviation
input bool             InpUseVWAPTarget     = true;             // Use VWAP as an additional target reference

//+------------------------------------------------------------------+
//| ATR ADAPTIVE SL/TP                                                |
//+------------------------------------------------------------------+
input group "------------------- ATR Adaptive SL/TP ---"

input ENUM_TIMEFRAMES  InpATRTimeframe      = PERIOD_M1;        // ATR calculation timeframe
input int              InpATRPeriod         = 14;                // ATR calculation period
input double           InpATRMultiplierSL   = 2.0;               // ATR multiplier for stop loss
input double           InpATRMultiplierTP   = 3.0;               // ATR multiplier for take profit

//+------------------------------------------------------------------+
//| BREAK EVEN & TRAILING                                             |
//+------------------------------------------------------------------+
input group "------------------- Break Even & Trailing Stop ---"

input bool             InpUseTrailing       = true;              // Enable break even and trailing stop
input double           InpBreakEvenPips     = 200.0;              // Profit required to activate break even
input double           InpTrailingStopPips  = 150.0;              // Trailing stop distance in pips
input double           InpTrailingStepPips  = 10.0;              // Minimum trailing step in pips

//+------------------------------------------------------------------+
//| SESSION & TIME FILTER                                             |
//+------------------------------------------------------------------+
input group "------------------- Session & Time Filters ---"

input ENUM_SESSION_MODE InpSessionMode      = SESSION_ALL_DAY;   // Trading session mode
input string           InpSession1_Start    = "01:00";          // First session start time
input string           InpSession1_End      = "09:00";          // First session end time
input string           InpSession2_Start    = "10:00";          // Second session start time
input string           InpSession2_End      = "21:00";          // Second session end time
input bool             InpAvoidRollover     = true;              // Avoid trading during rollover

//+------------------------------------------------------------------+
//| TICK MICROSTRUCTURE ENGINE                                        |
//+------------------------------------------------------------------+
input group "------------------- Tick Microstructure Engine ---"

input int              InpTickBufferSize    = 500;               // Number of ticks stored for analysis
input double           InpDevMultiplier     = 1.2;               // Deviation sensitivity multiplier
input ulong            InpVelocityWindowMs  = 800;               // Tick velocity analysis window in milliseconds
input double           InpSnapbackPips      = 2.5;               // Minimum snapback distance in pips
input bool             InpRequireExtraMove  = true;              // Require additional price movement
input double           InpExtraMovePips     = 0.5;               // Minimum additional movement in pips

//+------------------------------------------------------------------+
//| M1 MARKET CONDITION FILTER                                       |
//+------------------------------------------------------------------+
input group "------------------- M1 Market Condition Filter ---"

input bool             InpUseM1Filter       = true;              // Enable M1 market condition filter
input int              InpM1ATRPeriod       = 5;                // M1 ATR calculation period
input double           InpMinM1ATRPips      = 1.5;               // Minimum M1 ATR in pips
input double           InpMaxM1ATRPips      = 0.0;               // Maximum M1 ATR in pips (0 = no limit)

//+------------------------------------------------------------------+
//| M1 STRUCTURE FILTER                                               |
//+------------------------------------------------------------------+
input group "------------------- M1 Rejection Structure ---"

input bool             InpUseM1Structure    = true;              // Enable M1 candle structure filter
input double           InpMinWickRatio      = 0.35;              // Minimum wick-to-range ratio
input double           InpMinBodyRatio      = 0.17;              // Minimum body-to-range ratio
input bool             InpRequireCandleBias = true;              // Require directional candle bias
input bool             InpRequireCloseLocation = true;           // Require directional close location
input double           InpMinCloseLocation  = 0.55;              // Minimum close position inside candle range

//+------------------------------------------------------------------+
//| MULTI-TIMEFRAME TREND FILTER                                     |
//+------------------------------------------------------------------+
input group "------------------- Multi-Timeframe Trend Filter ---"

input bool             InpUseTrendFilter    = true;              // Enable multi-timeframe trend filter
input bool             InpUseH1Trend        = true;              // Use H1 major trend filter
input bool             InpUseM15Trend       = true;              // Use M15 active trend filter
input bool             InpUseM5Trend        = true;              // Use M5 setup alignment filter
input int              InpH1MAPeriod        = 100;               // H1 moving average period
input int              InpM15MAPeriod       = 20;                // M15 moving average period
input int              InpM5MAPeriod        = 9;                 // M5 moving average period
input ENUM_MA_METHOD   InpMAMethod          = MODE_EMA;          // Moving average method

//+------------------------------------------------------------------+
//| M5 SETUP FILTER                                                   |
//+------------------------------------------------------------------+
input group "------------------- M5 Setup Filter ---"

input bool             InpUseM5Setup        = true;              // Enable M5 setup filter
input bool             InpRequireM5CandleBias = false;           // Require directional bias from previous M5 candle

//+------------------------------------------------------------------+
//| ANTI OVERTRADING                                                  |
//+------------------------------------------------------------------+
input group "------------------- Anti Overtrading Protection ---"

input bool             InpUseCooldown       = true;              // Enable entry cooldown
input int              InpCooldownSeconds   = 10;                // Minimum cooldown time between entries
input int              InpMinBarsBetweenEntries = 1;             // Minimum bars between entries
input double           InpMinDistanceFromLastEntryPips = 8.0;   // Minimum distance from the last entry in pips
