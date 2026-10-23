//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                         Trend Is Your Friend.mq4 |
//|                                                    AHARON TZADIK |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "AHARON TZADIK"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict

extern bool   Use_TP_In_Money=false;
extern double TP_In_Money=10;
extern bool   Use_TP_In_percent=false;
extern double TP_In_Percent=10;
//--------------------------------------------------------------------
//--------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////////////////
input    string               txt32                    = "------------[Money Trailing Stop]---------------"; //———————————————————————————————————————————
input    bool                 Enable_Trailing           = true; //Enable_Trailing
input    double               Take_Profit_Money       = 40.0; //Take Profit In Money (in current currency)
input    double               Stop_Loss_Money         = 10; //Stop Loss In Money(in current currency)
/////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------
//--------------------------------------------------------------------
extern bool         USEMOVETOBREAKEVEN=true;//Enable "no loss"
extern double       WHENTOMOVETOBE=10;      //When to move break even
extern double       PIPSTOMOVESL=5;         //How much pips to move sl
extern double       Lots=0.01;              //Lots size
input  double       MaximumRisk   =0.02;
input  double       DecreaseFactor=3;
//extern double       TrailingStop=40;        //TrailingStop
extern double       Stop_Loss=20;           //Stop Loss
extern int          MagicNumber=1234;       //MagicNumber
input  double       TakeProfit=50;          //TakeProfit



int           err;

int total=0;
double
Lot,Dmax,Dmin,// Amount of lots in a selected order
    Lts,                             // Amount of lots in an opened order
    Min_Lot,                         // Minimal amount of lots
    Step,                            // Step of lot size change
    Free,                            // Current free margin
    One_Lot,                         // Price of one lot
    Price,                           // Price of a selected order,
    pips,
    MA_1,MA_2,MA_3,MACD_SIGNAL;
int Type,freeze_level,Spread,L;
//--- price levels for orders and positions
double priceopen,stoploss,takeprofit;
//--- ticket of the current order
int orderticket;
//---
int INDEX2=0;
double PROFIT_SUM1=0;
double PROFIT_SUM2=0;
//--------------------------------------------------------------- 3 --
int
Period_MA_2,  Period_MA_3,       // Calculation periods of MA for other timefr.
              Period_MA_02, Period_MA_03,      // Calculation periods of supp. MAs
              K2,K3,T;
//---

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//--------------------------------------------------------------- 5 --
//---------------------------------------------------------------  --
   switch(Period())                 // Calculating coefficient for..
     {
      // .. different timeframes
      case     1:
         K2=5;
         K3=15;
         T=PERIOD_M15;
         break;// Timeframe M1
      case     5:
         K2=3;
         K3= 6;
         T=PERIOD_M30;
         break;// Timeframe M5
      case    15:
         K2=2;
         K3= 4;
         T=PERIOD_H1;
         break;// Timeframe M15
      case    30:
         K2=2;
         K3= 8;
         T=PERIOD_H4;
         break;// Timeframe M30
      case    60:
         K2=4;
         K3=24;
         T=PERIOD_D1;
         break;// Timeframe H1
      case   240:
         K2=6;
         K3=42;
         T=PERIOD_W1;
         break;// Timeframe H4
      case  1440:
         K2=7;
         K3=30;
         T=PERIOD_MN1;
         break;// Timeframe D1
      case 10080:
         K2=4;
         K3=12;
         break;// Timeframe W1
      case 43200:
         K2=3;
         K3=12;
         break;// Timeframe MN
     }

   double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(ticksize==0.00001 || ticksize==0.001)
      pips=ticksize*10;
   else
      pips=ticksize;
   return(INIT_SUCCEEDED);
//--- distance from the activation price, within which it is not allowed to modify orders and positions
   freeze_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   if(freeze_level!=0)
     {
      PrintFormat("SYMBOL_TRADE_FREEZE_LEVEL=%d: order or position modification is not allowed,"+
                  " if there are %d points to the activation price",freeze_level,freeze_level);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   if(Use_TP_In_Money)
     { Take_Profit_In_Money();}
   if(Use_TP_In_percent)
     { Take_Profit_In_percent();}
   stop();
   if(USEMOVETOBREAKEVEN)
      MOVETOBREAKEVEN();
//Trail1();
//int    ticket;
// Check for New Bar (Compatible with both MQL4 and MQL5)
   static datetime dtBarCurrent=WRONG_VALUE;
   datetime dtBarPrevious=dtBarCurrent;
   dtBarCurrent=(datetime) SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
   bool NewBarFlag=(dtBarCurrent!=dtBarPrevious);
// initial data checks
// it is important to make sure that the expert works with a normal
// chart and the user did not make any mistakes setting external
// variables (Lots, StopLoss, TakeProfit,
// TrailingStop) in our case, we check TakeProfit
// on a chart of less than 100 bars
//---
   if(Bars<100)
     {
      Print("bars less than 100");
      return;
     }
   if(TakeProfit<10)
     {
      Print("TakeProfit less than 10");
      return;
     }
//--- to simplify the coding and speed up access data are put into internal variables
//+------------------------------------------------------------------+
   double middleBB=iBands(Symbol(),0,20, 2,0,0,MODE_MAIN,1);//middle
   double lowerBB=iBands(Symbol(),0,20, 2,0,0,MODE_LOWER,1);//lower
   double upperBB=iBands(Symbol(),0,20, 2,0,0,MODE_UPPER,1);//upper
//+------------------------------------------------------------------+
   double  MacdMAIN=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double  MacdSIGNAL=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
//+------------------------------------------------------------------+
   double MA_20=iMA(NULL,0,20,0,MODE_LWMA,PRICE_TYPICAL,0); // МА_2
   double MA_8=iMA(NULL,0,8,0,MODE_EMA,PRICE_TYPICAL,0); // МА_2
//--------------------------------------------------------------------------------------------------
   double   MomLevel=MathAbs(100-iMomentum(NULL,T,14,PRICE_CLOSE,1));
   double   MomLevel1=MathAbs(100 - iMomentum(NULL,T,14,PRICE_CLOSE,2));
   double   MomLevel2=MathAbs(100 - iMomentum(NULL,T,14,PRICE_CLOSE,3));
//--------------------------------------------------------------------------------------------------
   double direction=iHigh(_Symbol,0,1)-iOpen(_Symbol,0,1);
   double direction1 = iHigh(_Symbol, 0, 1) - iClose(_Symbol,0, 1);
   double direction2 = iHigh(_Symbol,0, 1) - iLow(_Symbol, 0, 1);
   double direction3 = iOpen(_Symbol,0, 1) - iClose(_Symbol,0, 1);
   double direction4 = iOpen(_Symbol,0, 1) - iLow(_Symbol,0, 1);
   double direction5 = iClose(_Symbol,0, 1) - iLow(_Symbol, 0, 1);
   double direction6 = iClose(_Symbol,0, 3) - iOpen(_Symbol,0, 3);
   double direction7 = iClose(_Symbol,0, 4) - iOpen(_Symbol,0, 4);
   double direction8 = iClose(_Symbol,0, 5) - iOpen(_Symbol,0, 5);
   double direction9 = iHigh(_Symbol,0, 1) - iOpen(_Symbol,0, 1);
   double direction10= iOpen(_Symbol,0,2)-iClose(_Symbol,0,2);
//--------------------------------------------------------------------------------------------------
   double RSI0 =iRSI(NULL,PERIOD_MN1,14,PRICE_CLOSE,0);
   double RSI1 =iRSI(NULL,PERIOD_MN1,14,PRICE_CLOSE,1);
//----------------------------------------------------------------------------
   double  MacdMAIN0=iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double  MacdSIGNAL0=iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);

//--------------------------------------------------------------------------------------------------
   if(getOpenOrders()==0)

     {
      //--- no opened orders identified
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }
      if(NewBarFlag)
        {
         //--- check for long position (BUY) possibility
         //+------------------------------------------------------------------+
         //| BUY                      BUY                 BUY                 |
         //+------------------------------------------------------------------+)
         if(MA_8>MA_20)
            if(Low[2]<High[1])
               if(direction10>0 && direction3<0 && MathAbs(direction3)>MathAbs(direction10))
                  if((MacdMAIN0>0 && MacdMAIN0>MacdSIGNAL0) || (MacdMAIN0<0 && MacdMAIN0>MacdSIGNAL0)||RSI0>RSI1)
                     if(IsNewOrderAllowed())
                       {

                        int Ticket=OrderSend(Symbol(),OP_BUY,LotsOptimized(),ND(Ask),3,0,0,"",0,0,PaleGreen);
                        if(Ticket>-1)
                          {
                           if(OrderSelect(Ticket,SELECT_BY_TICKET))
                             {
                              if(CheckStopLoss_Takeprofit(OP_BUY,NDTP(Bid-Stop_Loss*pips),NDTP(Bid+TakeProfit*pips)))
                                 if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),NDTP(Bid-Stop_Loss*pips),NDTP(Bid+TakeProfit*pips)))
                                    if(!OrderModify(Ticket,OrderOpenPrice(),NDTP(Bid-Stop_Loss*pips),NDTP(Bid+TakeProfit*pips),0,PaleGreen))
                                       Print("error modify");
                             }
                          }

                       }
         //--- check for short position (SELL) possibility
         //+------------------------------------------------------------------+
         //| SELL             SELL                       SELL                 |
         //+------------------------------------------------------------------+
         if(MA_8<MA_20)
            if(Low[1]<High[2])
               if(direction10<0 && direction3>0 && MathAbs(direction3)<MathAbs(direction10))
                  if((MacdMAIN0>0 && MacdMAIN0<MacdSIGNAL0) || (MacdMAIN0<0 && MacdMAIN0<MacdSIGNAL0)||RSI0<RSI1)
                     if(IsNewOrderAllowed())
                       {

                        int Ticket=OrderSend(Symbol(),OP_SELL,LotsOptimized(),ND(Bid),3,0,0,"",0,0,PaleGreen);
                        if(Ticket>-1)
                          {
                           if(OrderSelect(Ticket,SELECT_BY_TICKET))
                             {
                              if(CheckStopLoss_Takeprofit(OP_BUY,NDTP(Ask+Stop_Loss*pips),NDTP(Ask+Stop_Loss*pips)))
                                 if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),NDTP(Ask+Stop_Loss*pips),NDTP(Ask+Stop_Loss*pips)))
                                    if(!OrderModify(Ticket,OrderOpenPrice(),NDTP(Ask+Stop_Loss*pips),NDTP(Ask+Stop_Loss*pips),0,PaleGreen))
                                       Print("error modify");
                             }
                          }

                        return;
                       }
        }
     }
  }
//+------------------------------------------------------------------+
//|   stop                                                           |
//+------------------------------------------------------------------+
//-----------------------------------------------------------------------------+
void stop()
  {
   int cnt;
//+------------------------------------------------------------------+
   double middleBB=iBands(Symbol(),0,20, 2,0,0,MODE_MAIN,1);//middle
   double lowerBB=iBands(Symbol(),0,20, 2,0,0,MODE_LOWER,1);//lower
   double upperBB=iBands(Symbol(),0,20, 2,0,0,MODE_UPPER,1);//upper
//+------------------------------------------------------------------+
   double  MacdMAIN=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double  MacdSIGNAL=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
//+------------------------------------------------------------------+
   for(cnt=0; cnt<total; cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderType()<=OP_SELL &&   // check for opened position
         OrderSymbol()==Symbol())  // check for symbol
        {
         //--- long position is opened
         if(OrderType()==OP_BUY)
           {
            //--- should it be closed?

            if(Close[1]==upperBB)
               exitbuys();
            //--- check for trailing stop
           }
         else // go to short position
           {
            //--- should it be closed?

            if(Close[1]==lowerBB)
               exitsells();
            //--- check for trailing stop
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Trailing stop loss                                               |
//+------------------------------------------------------------------+
// --------------- ----------------------------------------------------------- ------------------------
/*void Trail1()
  {
   total=OrdersTotal();
//--- it is important to enter the market correctly, but it is more important to exit it correctly...
   for(int cnt=0; cnt<total; cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderType()<=OP_SELL &&   // check for opened position
         OrderSymbol()==Symbol())  // check for symbol
        {
         //--- long position is opened
         if(OrderType()==OP_BUY)
           {

            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if(Bid-OrderOpenPrice()>pips*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-pips*TrailingStop)
                    {

                     RefreshRates();
                     stoploss=Bid-(pips*TrailingStop);
                     takeprofit=OrderTakeProfit()+pips*TrailingStop;
                     double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD);
                     if(stoploss<StopLevel*pips)
                        stoploss=StopLevel*pips;
                     string symbol=OrderSymbol();
                     double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
                     if(MathAbs(OrderStopLoss()-stoploss)>point)
                        if((pips*TrailingStop)>(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*pips)

                           //--- modify order and exit
                           if(CheckStopLoss_Takeprofit(OP_BUY,stoploss,takeprofit))
                              if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit))
                                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0,Green))
                                    Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
         else // go to short position
           {
            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if((OrderOpenPrice()-Ask)>(pips*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+pips*TrailingStop)) || (OrderStopLoss()==0))
                    {

                     RefreshRates();
                     stoploss=Ask+(pips*TrailingStop);
                     takeprofit=OrderTakeProfit()-pips*TrailingStop;
                     double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD);
                     if(stoploss<StopLevel*pips)
                        stoploss=StopLevel*pips;
                     if(takeprofit<StopLevel*pips)
                        takeprofit=StopLevel*pips;
                     string symbol=OrderSymbol();
                     double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
                     if(MathAbs(OrderStopLoss()-stoploss)>point)
                        if((pips*TrailingStop)>(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*pips)

                           //--- modify order and exit
                           if(CheckStopLoss_Takeprofit(OP_SELL,stoploss,takeprofit))
                              if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit))
                                 if(!OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,takeprofit,0,Red))
                                    Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
        }
     }
  }*/
//+------------------------------------------------------------------+
//+---------------------------------------------------------------------------+
//|                          MOVE TO BREAK EVEN                               |
//+---------------------------------------------------------------------------+
void MOVETOBREAKEVEN()

  {
   for(int b=OrdersTotal()-1; b>=0; b--)
     {
      if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()!=MagicNumber)
            continue;
      if(OrderSymbol()==Symbol())
         if(OrderType()==OP_BUY)
            if(Bid-OrderOpenPrice()>WHENTOMOVETOBE*pips)
               if(OrderOpenPrice()>OrderStopLoss())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(PIPSTOMOVESL*pips),OrderTakeProfit(),0,CLR_NONE))
                     Print("eror");
     }

   for(int s=OrdersTotal()-1; s>=0; s--)
     {
      if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()!=MagicNumber)
            continue;
      if(OrderSymbol()==Symbol())
         if(OrderType()==OP_SELL)
            if(OrderOpenPrice()-Ask>WHENTOMOVETOBE*pips)
               if(OrderOpenPrice()<OrderStopLoss())
                  if(!OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(PIPSTOMOVESL*pips),OrderTakeProfit(),0,CLR_NONE))
                     Print("eror");
     }
  }
//--------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   int    orders=OrdersHistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//--- select lot size
   if(MaximumRisk>0)
     {
      lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
     }
//--- calcuulate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      for(int i=orders-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
           {
            Print("Error in history!");
            break;
           }
         if(OrderSymbol()!=Symbol() /*|| OrderType()>OP_SELL*/)
            continue;
         //---
         if(OrderProfit()>0)
            break;
         if(OrderProfit()<0)
            losses++;
        }
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lot<minlot)
     { lot=minlot; }
// Print("Volume is less than the minimal allowed ,we use",minlot);}
// lot=minlot;

//--- maximal allowed volume of trade operations
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lot>maxlot)
     { lot=maxlot;  }
//  Print("Volume is greater than the maximal allowed,we use",maxlot);}
// lot=maxlot;

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lot/volume_step);
   if(MathAbs(ratio*volume_step-lot)>0.0000001)
     {  lot=ratio*volume_step;}
   return(lot);
   /* else  Print("StopOut level  Not enough money for ",OP_SELL," ",lot," ",Symbol());
      return(0);*/
  }
//+------------------------------------------------------------------+
double NDTP(double val)
  {
   RefreshRates();
   double SPREAD=MarketInfo(Symbol(),MODE_SPREAD);
   double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(val<StopLevel*pips+SPREAD*pips)
      val=StopLevel*pips+SPREAD*pips;
// double STOPLEVEL = MarketInfo(Symbol(),MODE_STOPLEVEL);
//int Stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);

//if (Stops_level*pips<val-Bid)
//val=Ask+Stops_level*pips;
   return(NormalizeDouble(val, Digits));
// return(val);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double ND(double val)
  {
   return(NormalizeDouble(val, Digits));
  }
//+------------------------------------------------------------------+

////////////////////////////////////////////////////////////////////////////////////
int getOpenOrders()
  {

   int Orders=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
        {
         continue;
        }
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
        {
         continue;
        }
      Orders++;
     }
   return(Orders);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Checking the new values of levels before order modification      |
//+------------------------------------------------------------------+
bool OrderModifyCheck(int ticket,double price,double sl,double tp)
  {
//--- select order by ticket
   if(OrderSelect(ticket,SELECT_BY_TICKET))
     {
      //--- point size and name of the symbol, for which a pending order was placed
      string symbol=OrderSymbol();
      double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
      //--- check if there are changes in the Open price
      bool PriceOpenChanged=true;
      int type=OrderType();
      if(!(type==OP_BUY || type==OP_SELL))
        {
         PriceOpenChanged=(MathAbs(OrderOpenPrice()-price)>point);
        }
      //--- check if there are changes in the StopLoss level
      bool StopLossChanged=(MathAbs(OrderStopLoss()-sl)>point);
      //--- check if there are changes in the Takeprofit level
      bool TakeProfitChanged=(MathAbs(OrderTakeProfit()-tp)>point);
      //--- if there are any changes in levels
      if(PriceOpenChanged || StopLossChanged || TakeProfitChanged)
         return(true);  // order can be modified
      //--- there are no changes in the Open, StopLoss and Takeprofit levels
      else
         //--- notify about the error
         PrintFormat("Order #%d already has levels of Open=%.5f SL=%.5f TP=%.5f",
                     ticket,OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
     }
//--- came to the end, no changes for the order
   return(false);       // no point in modifying
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool CheckStopLoss_Takeprofit(ENUM_ORDER_TYPE type,double SL,double TP)
  {
//--- get the SYMBOL_TRADE_STOPS_LEVEL level
   int stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   if(stops_level!=0)
     {
      PrintFormat("SYMBOL_TRADE_STOPS_LEVEL=%d: StopLoss and TakeProfit must"+
                  " not be nearer than %d points from the closing price",stops_level,stops_level);
     }
//---
   bool SL_check=false,TP_check=false;
//--- check only two order types
   switch(type)
     {
      //--- Buy operation
      case  ORDER_TYPE_BUY:
        {
         //--- check the StopLoss
         SL_check=(Bid-SL>stops_level*_Point);
         if(!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be less than %.5f"+
                        " (Bid=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SL,Bid-stops_level*_Point,Bid,stops_level);
         //--- check the TakeProfit
         TP_check=(TP-Bid>stops_level*_Point);
         if(!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be greater than %.5f"+
                        " (Bid=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TP,Bid+stops_level*_Point,Bid,stops_level);
         //--- return the result of checking
         return(SL_check&&TP_check);
        }
      //--- Sell operation
      case  ORDER_TYPE_SELL:
        {
         //--- check the StopLoss
         SL_check=(SL-Ask>stops_level*_Point);
         if(!SL_check)
            PrintFormat("For order %s StopLoss=%.5f must be greater than %.5f "+
                        " (Ask=%.5f + SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),SL,Ask+stops_level*_Point,Ask,stops_level);
         //--- check the TakeProfit
         TP_check=(Ask-TP>stops_level*_Point);
         if(!TP_check)
            PrintFormat("For order %s TakeProfit=%.5f must be less than %.5f "+
                        " (Ask=%.5f - SYMBOL_TRADE_STOPS_LEVEL=%d points)",
                        EnumToString(type),TP,Ask-stops_level*_Point,Ask,stops_level);
         //--- return the result of checking
         return(TP_check&&SL_check);
        }
      break;
     }
//--- a slightly different function is required for pending orders
   return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                      exitbuys()                  |
//+------------------------------------------------------------------+
void exitbuys()
  {
   double result;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
            if(result!=true)//if it did not close
              {
               err=GetLastError();
               Print("LastError = ",err);//get the reason why it didn't close
              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                    exitsells()                                   |
//+------------------------------------------------------------------+
void exitsells()
  {
   double result;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {

         if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,clrNONE);
            if(result!=true)//if it did not close
              {
               err=GetLastError();
               Print("LastError = ",err);//get the reason why it didn't close
              }

           }
        }

     }
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Check if another order can be placed                             |
//+------------------------------------------------------------------+
bool IsNewOrderAllowed()
  {
//--- get the number of pending orders allowed on the account
   int max_allowed_orders=(int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

//--- if there is no limitation, return true; you can send an order
   if(max_allowed_orders==0)
      return(true);

//--- if we passed to this line, then there is a limitation; find out how many orders are already placed
   int orders=OrdersTotal();

//--- return the result of comparing
   return(orders<max_allowed_orders);
  }
//+------------------------------------------------------------------+
//----------------------------------------- TP_In_Money -----------------------------------------------
void Take_Profit_In_Money()
  {
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if((TP_In_Money != 0))
     {
      PROFIT_SUM1 = 0;
      for(int i=OrdersTotal(); i>0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==Symbol())
              {
               if(OrderType() == OP_BUY || OrderType() == OP_SELL)
                 {
                  PROFIT_SUM1 = (PROFIT_SUM1 + OrderProfit());
                 }
              }
           }
        }
      if((PROFIT_SUM1 >= TP_In_Money))
        {
         RemoveAllOrders();
        }
     }
  }
//+------------------------------------------------------------------+
//------------------------------------------------ TP_In_Percent -------------------------------------------------
double Take_Profit_In_percent()
  {
   if((TP_In_Percent != 0))
     {
      double TP_Percent = ((TP_In_Percent * AccountBalance()) / 100);
      double  PROFIT_SUM = 0;
      for(int i=OrdersTotal(); i>0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==Symbol())
              {
               if(OrderType() == OP_BUY || OrderType() == OP_SELL)
                 {
                  PROFIT_SUM = (PROFIT_SUM + OrderProfit());
                 }
              }
           }
         if(PROFIT_SUM >= TP_Percent)
           {
            RemoveAllOrders();
           }
        }

     }
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//       CLOSE &&  Remove  All    Orders
//+------------------------------------------------------------------+
void RemoveAllOrders()
  {
   for(int i = OrdersTotal() - 1; i >= 0 ; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS))
         Print("ERROR");
      if(OrderSymbol() != Symbol())
         continue;
      double price = MarketInfo(OrderSymbol(),MODE_ASK);
      if(OrderType() == OP_BUY)
         price = MarketInfo(OrderSymbol(),MODE_BID);
      if(OrderType() == OP_BUY || OrderType() == OP_SELL)
        {
         if(!OrderClose(OrderTicket(), OrderLots(),price,5))
            Print("ERROR");
        }
      else
        {
         if(!OrderDelete(OrderTicket()))
            Print("ERROR");
        }
      Sleep(100);
      int error = GetLastError();
      // if(error > 0)
      // Print("Unanticipated error: ", ErrorDescription(error));
      RefreshRates();
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TRAIL_PROFIT_IN_MONEY2()
  {

   PROFIT_SUM1 = 0;
   PROFIT_SUM2 = 0;
   INDEX2 = 0;
   double PROFIT_SUM3 = 0;
   for(int j=OrdersTotal(); j>0; j--)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol())
           {
            if(OrderType() == OP_BUY || OrderType() == OP_SELL)
              {
               PROFIT_SUM1  = PROFIT_SUM1 + (OrderProfit() + OrderCommission() + OrderSwap());

              }
           }
        }
     }
   if(PROFIT_SUM1>= Take_Profit_Money)

     {

      for(int i=OrdersTotal(); i>0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderSymbol()==Symbol())
              {

               if(OrderType() == OP_BUY || OrderType() == OP_SELL)


                 {
                  PROFIT_SUM2  = PROFIT_SUM2 + (OrderProfit() + OrderCommission() + OrderSwap());
                 }
               if(PROFIT_SUM1>= PROFIT_SUM3)
                 {PROFIT_SUM3=PROFIT_SUM1;}
               if(PROFIT_SUM2<=PROFIT_SUM3-Stop_Loss_Money)
                  RemoveAllOrders();
              }
           }
        }

     }

   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
