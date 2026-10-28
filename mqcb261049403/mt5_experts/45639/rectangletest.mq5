//+------------------------------------------------------------------+
//|                                           TrailingTakeProfit.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.3"
#property description "Update: --- Sell order problem solved.. --- "

#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
CTrade m_trade;
CSymbolInfo m_symbol;
CPositionInfo  m_position;
CHistoryOrderInfo m_history;


input group                 "---------- General ----------"
input ulong                Magic = 11111;    // Magic
input string            comentar = "Rectangle Test";
input group                 "---------- Trend double MA (EMA+SMA) ----------"
input int              EmaSmall = 45;        // EMA Small
input int                EmaBig = 200;       // SMA Big
input group                 "---------- Risk end Moneymanagement ----------"
input double               Risk = 1;         // Risk in (%)
enum my_lots {
   fixed_volume = 1,
   procent_volume = 2,
};
input my_lots  volumetype = procent_volume;  // Volume type
input double               Lots = 0.01;      // Volume
input int             SL_OF_DAY = 1;         // Stopploss of Day
input int              SLPoints = 250;       // SL Points
input int              TPPoints = 750;       // TP Points
input group                 "---------- Rectangle setting ----------"
input bool   RectangleColorFill = true;      // Rectangle Color fill?
input ENUM_TIMEFRAMES timeframe = PERIOD_H1;
input int         NumberCandles = 10;        // Rectangle Number of candles
input double      RectangleSize = 0.50;      // Rectanglesize in %
input group                "---------- Trading start and end (00:00) Filter ----------";
input string         TradeStart = "03:00";   // Trade Start
input string           TradeEnd = "22:50";   // Trade End
input bool        TimeCloseTrue = false;     // Order Closing (true/false))
input int             TimeClose = 23;        // Order is closed

static double lot = 0;
int    MA=0;
int    MA2=0;
datetime timestamp;

int OnInit() {

//--- Moving Average indicator
   MA=iMA(_Symbol,PERIOD_CURRENT,EmaSmall,0,MODE_EMA,PRICE_CLOSE);
   if(MA==INVALID_HANDLE) {
      printf("Error creating MA indicator");
      return(INIT_FAILED);
   }

//--- Moving2 Average indicator
   MA2=iMA(_Symbol,PERIOD_CURRENT,EmaBig,0,MODE_SMA,PRICE_CLOSE);
   if(MA2==INVALID_HANDLE) {
      printf("Error creating MA indicator");
      return(INIT_FAILED);
   }

//---
   if(!m_symbol.Name(_Symbol)) // sets symbol name
      return(INIT_FAILED);
//---
   m_trade.SetExpertMagicNumber(Magic);
   m_trade.SetDeviationInPoints(0);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectDelete(0,"Rectangle");

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() {
// Ask end Bid price
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);

//--- get current Moving Average
   double   mawert[1];

   if(CopyBuffer(MA,0,0,1,mawert)!=1) {
      Print("CopyBuffer from iMA failed, no data");
      return;
   }

//--- get current Moving Average
   double   mawert2[1];

   if(CopyBuffer(MA2,0,0,1,mawert2)!=1) {
      Print("CopyBuffer from iMA failed, no data");
      return;
   }

//SL of Day function
   if(Loss(0)>=SL_OF_DAY) {
      return;
   }

// Candletime

   datetime CandleTime = iTime(NULL,timeframe,0);

// Timestamp of Candles
   if(timestamp != CandleTime) {
      timestamp = CandleTime;

      int BarHigh, BarLow;

//Create Arrays for High and Low
      double High[], Low[];

//Sort array downwards drom the current candle
      ArraySetAsSeries(High,true);

//Sort array downwards drom the current candle
      ArraySetAsSeries(Low,true);

      CopyHigh(_Symbol,PERIOD_CURRENT,0,NumberCandles,High);
      CopyHigh(_Symbol,PERIOD_CURRENT,0,NumberCandles,Low);

//Calculate the highest
      BarHigh = ArrayMaximum(High,0,NumberCandles);

//Calculate the lowest
      BarLow = ArrayMinimum(Low,0,NumberCandles);

// Create an Array for prices
      MqlRates PriceInfo[];

// Sort it from current candle to oldest candle
      ArraySetAsSeries(PriceInfo,true);

// Copy price data into the array
      int Data = CopyRates(Symbol(),PERIOD_CURRENT,0,Bars(Symbol(),Period()),PriceInfo);

// Delete Object rectangle
      ObjectDelete(0,"Rectangle");

// Create Object Retangle
      ObjectCreate(0,
                   "Rectangle",
                   OBJ_RECTANGLE,
                   0,
                   PriceInfo[NumberCandles].time,
                   PriceInfo[BarHigh].high,
                   PriceInfo[0].time,
                   PriceInfo[BarLow].low
                  );

      // double RectangleRange     = NormalizeDouble((PriceInfo[BarHigh].high - PriceInfo[BarLow].low)/_Point,_Digits);
      double RangePercent = NormalizeDouble(((PriceInfo[BarHigh].high - PriceInfo[BarLow].low) / PriceInfo[BarHigh].high * 100),2);

      if(RangePercent > RectangleSize) {
         //--- Set the color of the rectangle
         ObjectSetInteger(0,"Rectangle",OBJPROP_COLOR,clrRed);
      } else {
         //--- Set the color of the rectangle
         ObjectSetInteger(0,"Rectangle",OBJPROP_COLOR,clrGreen);
      }
//--- Set the style of the rectangle lines
      ObjectSetInteger(0,"Rectangle",OBJPROP_STYLE,STYLE_SOLID);
//--- Set the line width of the rectangle
      ObjectSetInteger(0,"Rectangle",OBJPROP_WIDTH,1);
      if(RectangleColorFill == true) {
//--- enable (true) or disable (false) color fill of the rectangle
         ObjectSetInteger(0,"Rectangle",OBJPROP_FILL,true);
      } else {
         //--- enable (true) or disable (false) color fill of the rectangle
         ObjectSetInteger(0,"Rectangle",OBJPROP_FILL,false);
      }
//--- Show on foreground (false) or background (true).
      ObjectSetInteger(0,"Rectangle",OBJPROP_BACK,false);

      //Time Close Order
      if(TimeCloseTrue == true) {
         ClosePos();
      }

      static ENUM_POSITION_TYPE tipe_letzte_position=-1;
      for(int i=PositionsTotal()-1; i>=0; i--) // Returns the number of current positions
         if(m_position.SelectByIndex(i)) // selects position by index for further access to its properties
            if(m_position.Symbol()== _Symbol && m_position.Magic()==Magic) {
               tipe_letzte_position=m_position.PositionType();  // Gets the position type
               return;
            }

      datetime  localtime = TimeCurrent();
      datetime timestart = StringToTime(TradeStart);
      datetime timeend = StringToTime(TradeEnd);

      if(RangePercent <= RectangleSize && mawert[0] < PriceInfo[BarHigh].high && mawert[0] > PriceInfo[BarLow].low) {

         if(mawert2[0] < PriceInfo[BarHigh].high && mawert2[0] > PriceInfo[BarLow].low) {
            // Print("Trend sideways!");
         }


         if(localtime>timestart && localtime < timeend && RangePercent < RectangleSize && mawert[0] > mawert2[0]) {
            if(Ask > mawert[0]) {
               //  Print("Sell Order");

               double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
               double price = Bid;
               double SL = price + SLPoints * _Point;
               SL = NormalizeDouble(SL,_Digits);
               double TK = price - TPPoints * _Point;
               TK = NormalizeDouble(TK,_Digits);

               if(volumetype == procent_volume) {
                  lot = NormalizeDouble(LotsByRisk(ORDER_TYPE_SELL,Risk,(int)SLPoints),2);
               } else {
                  lot = Lots;
               }

               double volume = lot;
               volume=LotCheck(volume);
               if(volume==0)
                  return;

               m_trade.Sell(volume,NULL,price,SL,TK,comentar);

            }

         }

         if(localtime>timestart && localtime < timeend && RangePercent < RectangleSize && mawert[0] < mawert2[0]) {
            if(Bid < mawert[0]) {
               // Print("Buy Order");
               double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
               double price = Ask;
               double SL = price - SLPoints * _Point;
               SL = NormalizeDouble(SL,_Digits);
               double TK = price + TPPoints * _Point;
               TK = NormalizeDouble(TK,_Digits);

               if(volumetype == procent_volume) {
                  lot = NormalizeDouble(LotsByRisk(ORDER_TYPE_BUY,Risk,(int)SLPoints),2);
               } else {
                  lot = Lots;
               }

               double volume = lot;
               volume=LotCheck(volume);
               if(volume==0)
                  return;

               m_trade.Buy(volume,NULL,price,SL,TK,comentar);

            }
         }
      }
   }
}
//+------------------------------------------------------------------+
void ClosePos() {
   datetime      time = TimeCurrent();
   datetime time_end = StringToTime((string)TimeClose);

   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()== _Symbol && m_position.Magic()==Magic) { // Checks by symbol and magic number
            if(time >= time_end) {
               m_trade.PositionClose(m_position.Ticket());
            }
         }
}
//------------- Loss Orders Function ---------------------------
double Loss(int ai_0) {

// HistorySelect(from_data,to_data);
   HistorySelect(iTime(_Symbol,PERIOD_D1,ai_0),iTime(_Symbol,PERIOD_D1,ai_0)+60*60*24);
   double loss_trade=0.0;
   uint total=HistoryDealsTotal();
   ulong    ticket=0;

//--- for all deals
   for(uint i=0; i<total; i++) {
      //--- Searches for tickets greater than zero
      if((ticket=HistoryDealGetTicket(i))>0) {
         long entry=HistoryDealGetInteger(ticket,DEAL_ENTRY);
         if(entry==DEAL_ENTRY_IN)
            continue;

         string          symbol = HistoryDealGetString(ticket,DEAL_SYMBOL);
         long       order_magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         double deal_commission = HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double       deal_swap = HistoryDealGetDouble(ticket,DEAL_SWAP);
         double     deal_profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         double          profit = deal_commission+deal_swap+deal_profit;
         if(order_magic ==Magic) {
            //... processing of deal with some DEAL_MAGIC
            if(symbol==_Symbol) {
               if(profit<0.0)
                  loss_trade++;
            }
         }
      }
   }
   return(loss_trade);
}
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots) {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
}
//+------------------------------------------------------------------+
//| Checks if the specified filling mode is allowed                  |
//+------------------------------------------------------------------+
bool IsFillingTypeAllowed(int fill_type) {
//--- Obtain the value of the property that describes allowed filling modes
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed
   return((filling & fill_type)==fill_type);
}
//+------------------------------------------------------------------+
//+-----------------------------------------------------------------
double LotsByRisk(int op_type,double risk,int sloss) {
   double  lot_min = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double  lot_max = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double lot_step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double  lotcost = ((SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE)*_Point)/(SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)));
   lot = 0.0;
   double UsdPerPip = 0.0;

   lot = AccountInfoDouble(ACCOUNT_BALANCE)*risk/100;
   UsdPerPip = lot/sloss;
   if(UsdPerPip <= 0.0)
      return(0);
   lot = NormalizeDouble(UsdPerPip/lotcost, 2);
   if(lot <= 0.0)
      return(0);
   lot = NormalizeDouble(lot/lot_step, 0) * lot_step;
   if(lot < lot_min)
      lot = lot_min;
   if(lot > lot_max)
      lot = lot_max;
   return(lot);
}
//+------------------------------------------------------------------+
