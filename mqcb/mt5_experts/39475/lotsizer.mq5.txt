//+------------------------------------------------------------------+
//|                                                     Lotsizer.mq5 |
//|                                   Copyright 2020, David J. Díez. |
//|                         https://www.mql5.com/es/users/davidjdiez |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, David J. Díez Munilla."
#property link      "https://www.mql5.com/en/users/davidjdiez"
#property version   "1.00"
//+--- Definitions --------------------------------------------------!
enum LSMODE
  {
   Equity=1, // Based on Equity
   Balance=2 // Based on Balance
  };
enum MONEYM {Conservative=1,Moderate=2,Medium=3,Agressive=5};
//+--- Parameters ---------------------------------------------------!
input MONEYM RiskFactor  = 2;    // Money management
input LSMODE Calculation = 1;    // Calculation mode
input bool   RoundUp     = true; // Lotsize round up
//+--- Global variables ---------------------------------------------!
double ADR[]; // Average Daily Range buffer
int ADRh=INVALID_HANDLE; // ADR indicator handle
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Comment("Initializing Lotsizer...");
   ADRh=iATR(_Symbol,PERIOD_D1,14);
   if(ADRh==INVALID_HANDLE)
     {
      Print("Error creating ADR handle for ",_Symbol);
      return(INIT_FAILED);
     }
   ArraySetAsSeries(ADR,true);
   EventSetTimer(1); // One second timer.
   Print("Initialization completed successfully.");
   return(INIT_SUCCEEDED);
  } // Initialization OK.
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("Deinitializing Lotsizer...");
   Comment(""); // Clear chart comment.
   if(ADRh!=INVALID_HANDLE)
     {
      IndicatorRelease(ADRh);
     }
   EventKillTimer(); // Stop timer.
   Alert("Lotsizer terminated.");
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(CopyBuffer(ADRh,0,0,2,ADR)<2)
     {
      Print("Error copying ADR buffer for ",_Symbol);
      return;
     } // Avoid errors and exit the function.
   double Equity=AccountInfoDouble(ACCOUNT_EQUITY);
   double Balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double minLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double lotStep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double vTick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   if(ADR[1]<=0||vTick<=0)
     {
      return;  // Invalid market data, skipping.
     }
   double Lotsize=RiskFactor*(Equity/((ADR[1]/_Point)*vTick)/100); // Raw.
   if(Calculation>1)
     {
      Lotsize=RiskFactor*(Balance/((ADR[1]/_Point)*vTick)/100);
     }
   if(!RoundUp)
     {
      Lotsize=MathFloor(Lotsize/lotStep)*lotStep;  // Round down Lotsize.
     }
   else
     {
      Lotsize=MathRound(Lotsize/lotStep)*lotStep;
     }
   Lotsize=MathMin(Lotsize,maxLot);
   if(Lotsize>=minLot)  // Lotsize is enough to trade → show comment on chart:
     {
      Comment("\nLotsize for current chart symbol: ",DoubleToString(Lotsize,2));
     }
   else
     {
      Comment("\nNot enough money to trade this symbol with the current settings.");
     }
  }
//+--------------------------------------------------------- End. ---+