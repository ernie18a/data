//+------------------------------------------------------------------+
//|                                                     Defines.mqh  |
//|                      BGC Grid Trading EA — Shared Types          |
//|                      Based on Taranto & Khan (2020-2021)         |
//+------------------------------------------------------------------+
#property copyright "Muhammad Minhas Qamar - MMQ"
#property strict

#ifndef __DEFINES_MQH__
#define __DEFINES_MQH__

//--- Default constants
#define EA_COMMENT          "BGC_Grid"
#define DEFAULT_SLIPPAGE    10
#define STATE_PREFIX        "BGC_"
#define MAX_GRID_LEVELS     50          // hard safety cap on levels per side

//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+
enum ENUM_LOT_MODE
{
   LOT_MODE_MILD_MULTIPLIER = 0,       // Mild Multiplier: BaseLot * pow(Mult, level)
   LOT_MODE_DYNAMIC         = 1        // Dynamic: scale lot down as drawdown deepens
};

enum ENUM_PROFIT_MODE
{
   PROFIT_MODE_DOLLARS = 0,            // Fixed dollar target
   PROFIT_MODE_PERCENT = 1             // Percentage of cycle equity
};

enum ENUM_GRID_STATE
{
   GRID_STATE_IDLE    = 0,             // Halted — waiting for manual re-enable or init
   GRID_STATE_ACTIVE  = 1,             // Normal operation — grid is live
   GRID_STATE_PAUSED  = 2,             // Volatility gate paused arming
   GRID_STATE_CLOSING = 3              // In the process of closing all positions
};

enum ENUM_GRID_MODE
{
   GRID_MODE_BGT = 0,                  // Bi-directional (current default)
   GRID_MODE_TGT = 1,                  // Trending (stop orders in trend direction, variable TP)
   GRID_MODE_MGT = 2                   // Mean-reversion (limit orders only, counter-trend, fixed TP)
};

//+------------------------------------------------------------------+
//| Grid Level — represents one discrete level of the grid           |
//|   Each level has BOTH a buy and a sell side (bi-directional).     |
//+------------------------------------------------------------------+
struct GridLevel
{
   int               levelIndex;       // Signed: +1,+2.. above anchor, -1,-2.. below
   double            price;            // Exact price of this grid level
   ulong             buyTicket;        // Position ticket for buy at this level (0 = none)
   ulong             sellTicket;       // Position ticket for sell at this level (0 = none)
   ulong             buyPendingTicket; // Pending buy order ticket (0 = none)
   ulong             sellPendingTicket;// Pending sell order ticket (0 = none)
   double            lotSize;          // Computed lot for this level
   bool              buyArmed;         // true = buy pending order is placed and waiting
   bool              sellArmed;        // true = sell pending order is placed and waiting
   bool              buyOpen;          // true = buy position is currently open
   bool              sellOpen;         // true = sell position is currently open
   bool              buyFilled;        // true = a buy order was filled at this level (prevents re-arm)
   bool              sellFilled;       // true = a sell order was filled at this level (prevents re-arm)

   void Reset()
   {
      levelIndex       = 0;
      price            = 0;
      buyTicket        = 0;
      sellTicket       = 0;
      buyPendingTicket = 0;
      sellPendingTicket= 0;
      lotSize          = 0;
      buyArmed         = false;
      sellArmed        = false;
      buyOpen          = false;
      sellOpen         = false;
      buyFilled        = false;
      sellFilled       = false;
   }
};

//+------------------------------------------------------------------+
//| Grid Session — full state of one grid cycle                      |
//+------------------------------------------------------------------+
struct GridSession
{
   double            anchorPrice;      // Price at grid origin
   double            gridSpacing;      // Grid spacing in price (not points)
   double            sessionHigh;      // Highest price since cycle start
   double            sessionLow;       // Lowest price since cycle start
   double            cycleStartEquity; // Equity at cycle start (E0)
   datetime          cycleStartTime;   // Time when cycle started
   int               cycleCount;       // Number of completed cycles
   double            cumulativeProfit; // Total realised profit across all cycles
   ENUM_GRID_STATE   state;            // Current grid state
   ENUM_GRID_MODE    gridMode;         // Active algorithm for this cycle (BGT/TGT/MGT)
   int               trendDirection;   // +1 uptrend, -1 downtrend (for TGT/MGT)

   int               totalLevels;      // GridLevels input (levels per side)
   GridLevel         levels[];         // Unified: first N = above anchor (+1..+N), last N = below (-1..-N)

   int LevelCount() { return 2 * totalLevels; }

   void Init(double anchor, double spacing, int levelsPerSide)
   {
      anchorPrice     = anchor;
      gridSpacing     = spacing;
      sessionHigh     = anchor;
      sessionLow      = anchor;
      cycleStartEquity= AccountInfoDouble(ACCOUNT_EQUITY);
      cycleStartTime  = TimeCurrent();
      state           = GRID_STATE_ACTIVE;
      gridMode        = GRID_MODE_BGT;
      trendDirection  = 0;
      totalLevels     = levelsPerSide;

      int total = 2 * levelsPerSide;
      ArrayResize(levels, total);

      for(int i = 0; i < levelsPerSide; i++)
      {
         //--- Above anchor: indices 0..N-1, levelIndex +1..+N
         levels[i].Reset();
         levels[i].levelIndex = i + 1;
         levels[i].price      = anchor + (i + 1) * spacing;

         //--- Below anchor: indices N..2N-1, levelIndex -1..-N
         levels[levelsPerSide + i].Reset();
         levels[levelsPerSide + i].levelIndex = -(i + 1);
         levels[levelsPerSide + i].price      = anchor - (i + 1) * spacing;
      }
   }
};

#endif // __DEFINES_MQH__
//+------------------------------------------------------------------+
