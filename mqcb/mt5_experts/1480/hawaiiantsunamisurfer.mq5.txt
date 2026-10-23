#property copyright     "Author: laplacianlab, CC Attribution-Noncommercial-No Derivate 3.0"
#property link          "https://www.mql5.com/en/forum/ea"
#property version       "1.00"
#property description   "This system, based on Momentum indicator, assumes that very strong price movements are determinant. It consists in riding the appearing tsunamis, for instance, an important US Nonfarm Payrolls release. HawaiianTsunamiSurfer works well on AUDUSD, USDJPY and EURUSD. It also works with a lower performance on USDCHF and GBPUSD."

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Var block                                                        |
//+------------------------------------------------------------------+

// MQL5 API vars

CPositionInfo PositionInfo;
CTrade trade; 
MqlTick tick;

// EA's vars

enum ENUM_STATUS_EA
  {
   BUY, 
   SELL,
   DO_NOTHING
  };

ENUM_STATUS_EA EAStatus;

// Momentum indicator vars

int iMomentumHandler;
double iMomentumBuffer[];

int momentumPeriod = 1;
ENUM_TIMEFRAMES momentumTimeframe = PERIOD_M1;
ENUM_APPLIED_PRICE momentumAppliedPrice = PRICE_CLOSE;

// Graphic bar management

static datetime previousBarTime;
datetime currentBarTime[1];
bool isNewBar = false;

// The following inputs are transparent to the user, they are optimized! 
// This EA is very sensible to inputs. Please, don't change them unless you are sure about what you do.

int stopLoss = 700; 
int takeProfit = 500; 
double tsunamiStrength = 0.24;
double size = 0.1;

int OnInit()
  {  
                 
   EAStatus = DO_NOTHING;         
   
   iMomentumHandler = iMomentum(Symbol(), momentumTimeframe, momentumPeriod, momentumAppliedPrice);
   ArraySetAsSeries(iMomentumBuffer, true);
    
   return(0);
   
  }
  
void OnDeinit(const int reason)
  {   
   IndicatorRelease(iMomentumHandler);
   ArrayFree(iMomentumBuffer);
  }
  
void OnTick()
  {
    
   // Let's first check if a new bar has come!
         
   if(CopyTime(_Symbol, _Period, 0, 1, currentBarTime) > 0) 
     {
      if(previousBarTime != currentBarTime[0])
        {
         isNewBar = true;
         previousBarTime = currentBarTime[0];
        }
     }
   else
     {
      Alert("Error copying historical data, error: ", GetLastError());
      return;
     }
     
   if(!isNewBar) return;
   
   // We run the operations below only on new bars, that is to say, once per bar.
   
   double tp;
   double sl;      
    
   SymbolInfoTick(_Symbol, tick);
         
   if(CopyBuffer(iMomentumHandler, 0, 0, 2, iMomentumBuffer) < 0) 
     { 
      Alert("Error copying buffers, error: " , GetLastError());
      return;
     }     
     
   if(!PositionInfo.Select(_Symbol))      
     {
      if (iMomentumBuffer[0] > (100 + tsunamiStrength)) 
        {
                                   
         EAStatus = SELL;
   
        }  
      else if (iMomentumBuffer[0] < (100 - tsunamiStrength)) 
        {
            
         EAStatus = BUY;
                           
        }   
     }       
   else EAStatus = DO_NOTHING;
 
   switch(EAStatus) 
     { 
      case BUY:
      
         tp = tick.ask + takeProfit * _Point;
         sl = tick.bid - stopLoss * _Point;    
      
         trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, size, tick.ask, sl, tp);
         
         break;
         
      case SELL:
      
         sl = tick.ask + stopLoss * _Point;
         tp = tick.bid - takeProfit * _Point;
        
         trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, size, tick.bid, sl, tp);
      
         break;
         
      case DO_NOTHING:
      
         // Nothing...
      
         break;
     } 
    
}