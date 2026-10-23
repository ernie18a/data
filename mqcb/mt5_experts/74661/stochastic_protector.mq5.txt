//+------------------------------------------------------------------+
//|                                                  WatchDog_EA.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Isaac Uriel Arenas Calderas"
#property version   "1.0"
#property description "Stochastic Protector"

#include <Trade\Trade.mqh>
CTrade Trade;

//+------------------------------------------------------------------+
//| Enumeration for position profit states                           |
//+------------------------------------------------------------------+
enum ENUM_POSITION_STATE
  {
   Loss,               // Close only losing positions
   Profit,             // Close only profitable positions
   Profit_and_Loss     // Close both profitable and losing positions
  };

//+------------------------------------------------------------------+
//| Enumeration for Stochastic signal detection mode                 |
//+------------------------------------------------------------------+
enum ENUM_STOCH_ZONE_MODE
  {
   Crossing,           // Close on %K/%D crossing
   Entering,           // Close when entering overbought/oversold
   Exiting             // Close when exiting overbought/oversold
  };

input group "STOCHASTIC PARAMETERS"
input int InpKPeriod = 14;                                   // %K Period
input int InpDPeriod = 3;                                    // %D Period
input int InpSlowing = 3;                                    // Slowing
input int InpOverSold = 20;                                  // OverSold Level
input int InpOverBought = 80;                                // OverBought Level
input ENUM_STO_PRICE Stoch_price_field = STO_CLOSECLOSE;     // Price Field

input group "EA PARAMETERS"
input ENUM_STOCH_ZONE_MODE Stoch_Zone_Mode = Crossing;       // Closing Mode
input ENUM_POSITION_STATE InpPosistionState = Loss;          // Trades Considered
input ENUM_TIMEFRAMES InpTimeframe = PERIOD_CURRENT;         // TimeFrame

input group "TEST MODE"
input bool TestMode = false;                                 // Test Mode
input int OffSet = 20;                                       // Offset

// Global Variables
int stocHandle;                 // Handle for the Stochastic indicator
double KBuffer[];               // Buffer for %K values (main line)
double DBuffer[];               // Buffer for %D values (signal line)
double KBuffer2[];              // Secondary buffer for %K (used in TestMode)
double DBuffer2[];              // Secondary buffer for %D (used in TestMode)
bool tradable = true;           // Flag to control trading permissions

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Create the Stochastic indicator handle with the input parameters
   stocHandle = iStochastic(_Symbol, (ENUM_TIMEFRAMES)InpTimeframe, InpKPeriod, InpDPeriod, InpSlowing, MODE_SMA,STO_CLOSECLOSE);
   
   //--- Display configuration summary in the Experts log
   Print("STOCHASTIC PROTECTOR ON");
   Print("-----------------------");
   Print("STOCHASTIC PARAMETERS");
   Print("%K Period = ",InpKPeriod);
   Print("%D Period = ", InpDPeriod);
   Print("Slowing = ", InpSlowing);
   Print("OverSold Level = ",20);
   Print("OverBought Level = ", 80);
   Print("Price Field = ", EnumToString(Stoch_price_field));
   Print("-----------------------");
   Print("EA PARAMETERS");
   Print("Closing Mode = ", EnumToString(Stoch_Zone_Mode));
   Print("Trades Considered = ", EnumToString(InpPosistionState));
   Print("TimeFrame = ", EnumToString(InpTimeframe));
   Print("-----------------------");
   Print("TEST MODE");
   if(TestMode)
     {
      Print("Test Mode = ON");
     }
   else
     {
      Print("Test Mode = OFF");
     }
   Print("Offset = ", OffSet);
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //--- Release the Stochastic indicator handle to free memory
   IndicatorRelease(stocHandle);
   Print("STOCHASTIC PROTECTOR OFF");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- Execute the main closing logic based on Stochastic signals
   OperatingTrade();

   //--- Handle Test Mode: open demo positions using a custom offset strategy
   if(TestMode)
     {
      //--- Copy the latest 3 values of %K and %D for test mode analysis
      CopyBuffer(stocHandle,0, 0, 3, KBuffer2);
      CopyBuffer(stocHandle,1,0,3,DBuffer2);

      //--- Retrieve the most recent and previous %D values from the buffer
      double d1 = DBuffer[ArraySize(DBuffer)-1];
      double d0 = DBuffer[ArraySize(DBuffer)-2];

      //--- Open trades only if no positions are currently active
      if(PositionsTotal() == 0)
        {
         //--- Buy signal: %D crosses above the lower offset threshold
         if(d0 <= 50 - OffSet && d1 > 50 - OffSet)
           {
            tradable = true;
            Trade.Buy(0.01, _Symbol,0,0,0, "BUY");
            tradable = false;
           }
         //--- Sell signal: %D crosses below the upper offset threshold
         if(d0 >= 50 + OffSet && d1 < 50 + OffSet)
           {
            tradable = true;
            Trade.Sell(0.01, _Symbol,0,0,0, "SELL");
            tradable = false;
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Operating trade: close positions based on Stochastic conditions  |
//+------------------------------------------------------------------+
void OperatingTrade()
  {
   //--- Copy the latest 3 values of %K and %D for signal evaluation
   CopyBuffer(stocHandle,0, 0, 3, KBuffer);
   CopyBuffer(stocHandle,1,0,3,DBuffer);

   //--- Normalize the %K and %D values to match the symbol's price precision
   double k1 = NormalizeDouble(KBuffer[ArraySize(KBuffer)-1], _Digits-1);
   double k0 = NormalizeDouble(KBuffer[ArraySize(KBuffer)-2], _Digits-1);
   double d1 = NormalizeDouble(DBuffer[ArraySize(DBuffer)-1], _Digits-1);
   double d0 = NormalizeDouble(DBuffer[ArraySize(DBuffer)-2], _Digits-1);

   //--- Select the closing strategy based on the user-defined mode
   switch(Stoch_Zone_Mode)
     {
      //--- Closing Mode: Crossings
      case Crossing:
         //--- Bearish crossover in overbought zone -> close BUY positions
         if(k0 >= d0 && k1 < d1 && d1 > InpOverBought)
           {
            int total = PositionsTotal();
            for(int i=total-1;i>=0;i--)
              {
               ulong ticket = PositionGetTicket(i);
               if(ticket > 0 && PositionSelectByTicket(ticket))
                 {
                  if(PositionGetString(POSITION_SYMBOL) != _Symbol)
                     continue;
                  double profit = PositionGetDouble(POSITION_PROFIT);
                  long type = PositionGetInteger(POSITION_TYPE);
                  switch(InpPosistionState)
                    {
                     case Loss:
                        if(profit < 0 && type == POSITION_TYPE_BUY)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit:
                        if(profit > 0 && type == POSITION_TYPE_BUY)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit_and_Loss:
                        if(type == POSITION_TYPE_BUY)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                    }
                 }
              }
           }

         //--- Bullish crossover in oversold zone -> close SELL positions
         if(k0 <= d0 && k1 > d1 && d0 < InpOverSold)
           {
            int total = PositionsTotal();
            for(int i=total-1;i>=0;i--)
              {
               ulong ticket = PositionGetTicket(i);
               if(ticket > 0 && PositionSelectByTicket(ticket))
                 {
                  if(PositionGetString(POSITION_SYMBOL) != _Symbol)
                     continue;
                  double profit = PositionGetDouble(POSITION_PROFIT);
                  long type = PositionGetInteger(POSITION_TYPE);
                  switch(InpPosistionState)
                    {
                     case Loss:
                        if(profit < 0 && type == POSITION_TYPE_SELL)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit:
                        if(profit > 0 && type == POSITION_TYPE_SELL)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit_and_Loss:
                        if(type == POSITION_TYPE_SELL)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                    }
                 }
              }
           }
         break;

      //--- Closing Mode: Entering overbought/oversold zones
      case Entering:
         //--- %D drops below oversold (entering oversold) -> close SELL positions
         if(d0 >= InpOverSold && d1 < InpOverSold)
           {
            int total = PositionsTotal();
            for(int i=total-1;i>=0;i--)
              {
               ulong ticket = PositionGetTicket(i);
               if(ticket > 0 && PositionSelectByTicket(ticket))
                 {
                  if(PositionGetString(POSITION_SYMBOL) != _Symbol)
                     continue;
                  double profit = PositionGetDouble(POSITION_PROFIT);
                  long type = PositionGetInteger(POSITION_TYPE);
                  switch(InpPosistionState)
                    {
                     case Loss:
                        if(profit < 0 && type == POSITION_TYPE_SELL)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit:
                        if(profit > 0 && type == POSITION_TYPE_SELL)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit_and_Loss:
                        if(type == POSITION_TYPE_SELL)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                    }
                 }
              }
           }
         //--- %D rises above overbought (entering overbought) -> close BUY positions
         if(d0 <= InpOverBought && d1 > InpOverBought)
           {
            int total = PositionsTotal();
            for(int i=total-1;i>=0;i--)
              {
               ulong ticket = PositionGetTicket(i);
               if(ticket > 0 && PositionSelectByTicket(ticket))
                 {
                  if(PositionGetString(POSITION_SYMBOL) != _Symbol)
                     continue;
                  double profit = PositionGetDouble(POSITION_PROFIT);
                  long type = PositionGetInteger(POSITION_TYPE);
                  switch(InpPosistionState)
                    {
                     case Loss:
                        if(profit < 0 && type == POSITION_TYPE_BUY)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit:
                        if(profit > 0 && type == POSITION_TYPE_BUY)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit_and_Loss:
                        if(type == POSITION_TYPE_BUY)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                    }
                 }
              }
           }
         break;

      //--- Closing Mode: Exiting overbought/oversold zones
      case Exiting:
         //--- %D exits oversold (crosses above) -> close SELL positions
         if(d0 <= InpOverSold && d1 > InpOverSold)
           {
            int total = PositionsTotal();
            for(int i=total-1;i>=0;i--)
              {
               ulong ticket = PositionGetTicket(i);
               if(ticket > 0 && PositionSelectByTicket(ticket))
                 {
                  if(PositionGetString(POSITION_SYMBOL) != _Symbol)
                     continue;
                  double profit = PositionGetDouble(POSITION_PROFIT);
                  long type = PositionGetInteger(POSITION_TYPE);
                  switch(InpPosistionState)
                    {
                     case Loss:
                        if(profit < 0 && type == POSITION_TYPE_SELL)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit:
                        if(profit > 0 && type == POSITION_TYPE_SELL)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit_and_Loss:
                        if(type == POSITION_TYPE_SELL)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                    }
                 }
              }
           }
         //--- %D exits overbought (crosses below) -> close BUY positions
         if(d0 >= InpOverBought && d1 < InpOverBought)
           {
            int total = PositionsTotal();
            for(int i=total-1;i>=0;i--)
              {
               ulong ticket = PositionGetTicket(i);
               if(ticket > 0 && PositionSelectByTicket(ticket))
                 {
                  if(PositionGetString(POSITION_SYMBOL) != _Symbol)
                     continue;
                  double profit = PositionGetDouble(POSITION_PROFIT);
                  long type = PositionGetInteger(POSITION_TYPE);
                  switch(InpPosistionState)
                    {
                     case Loss:
                        if(profit < 0 && type == POSITION_TYPE_BUY)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit:
                        if(profit > 0 && type == POSITION_TYPE_BUY)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                     case Profit_and_Loss:
                        if(type == POSITION_TYPE_BUY)
                          {
                           Trade.PositionClose(ticket);
                          }
                        break;
                    }
                 }
              }
           }
         break;
     }
  }

//+------------------------------------------------------------------+