#property copyright     "Author: laplacianlab, CC Attribution-Noncommercial-No Derivate 3.0"
#property link          "https://www.mql5.com/en/forum/ea"
#property version       "1.00"
#property description   "This is a basic trading system which consists in buying when MACD crosses above the waterline line and selling when crosses below it. This EA works along with a monetary management system which has a positive mathematical expectation."

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Input block                                                      |
//+------------------------------------------------------------------+

// General inputs

input string pair = "EURUSD";
input ENUM_TIMEFRAMES timeframe = PERIOD_M15;

// MACD inputs

input int fastEMAPeriod = 12;                      // Fast EMA period
input int slowEMAPeriod = 26;                      // Slow EMA period
input int signalPeriod = 9;                        // Difference period

// Monetary management strategy inputs

input int stopLoss = 300;                          // Stop loss in pips
input double size = 0.1;                           // The size of the operation
   
enum ENUM_RISK_BENEFIT                             // Let's enum some risk-benefit ratios to make the user's life easier!
  {
   ONE_FIVE,   // 1/5
   ONE_FOUR,   // 1/4
   ONE_THREE,  // 1/3
   ONE_TWO,    // 1/2
   ONE         // 1/1
  };
                            
input ENUM_RISK_BENEFIT riskBenefitRatio = ONE_TWO;   // Risk-benefit ratio


//+------------------------------------------------------------------+
//| Var block                                                        |
//+------------------------------------------------------------------+

int MACDHandle;
double MACDValues[];
int takeProfit;      // 'takeProfit' will be calculated according to 'stopLoss' and 'riskBenefitRatio'.
string flag;         // 'flag' is 'buy' when we want the robot to buy and 'sell' when we want it to sell. 

int OnInit()
  {  
   
   switch(riskBenefitRatio)
     {  
      case ONE_FIVE:
      
         takeProfit = (int)(stopLoss * 5);
      
         break;
         
      case ONE_FOUR:
      
         takeProfit = (int)(stopLoss * 4);
      
         break;
         
      case ONE_THREE:
      
         takeProfit = (int)(stopLoss * 3);
      
         break;
         
      case ONE_TWO:
      
         takeProfit = (int)(stopLoss * 2);
      
         break;
         
      case ONE:
      
         takeProfit = stopLoss;
      
         break;
     
     }
  
   SymbolSelect(pair, true);    
   MACDHandle = iMACD(Symbol(), timeframe, fastEMAPeriod, slowEMAPeriod, signalPeriod, PRICE_CLOSE);   
   ArraySetAsSeries(MACDValues, true);   
   flag = "buy";
   
   return(0);   
  }
  
void OnDeinit(const int reason)
  {
   IndicatorRelease(MACDHandle);
   ArrayFree(MACDValues);
  }

void OnTick()
  {    
 
   CTrade trade; 
   MqlTick tick;

   SymbolInfoTick(_Symbol, tick);
         
   if(CopyBuffer(MACDHandle, 1, 0, 2, MACDValues) > 0) { 
   
      if (MACDValues[0] < 0 && MACDValues[1] > 0 && flag == "sell") {   
                 
         double sl = tick.ask + stopLoss * _Point; 
         double tp = tick.bid - takeProfit * _Point;
         
         trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, size, tick.bid, sl, tp);
         
         flag = "buy";
   
      }
   
      else if (MACDValues[0] > 0 && MACDValues[1] < 0 && flag == "buy") {
            
         double tp = tick.ask + takeProfit * _Point;
         double sl = tick.bid - stopLoss * _Point;    
      
         trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, size, tick.ask, sl, tp);
         
         flag = "sell";
   
      }
   
   }

  }