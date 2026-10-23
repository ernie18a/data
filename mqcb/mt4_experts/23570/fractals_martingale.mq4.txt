//+------------------------------------------------------------------+
//|             Fractals Martingale                                  |
//|                   AHARON TZADIK                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright   "AHARON TZADIK"
#property link        "http://algorithmic-trading-ea-mt4.000webhostapp.com/"
#property version   "1.06"
#property strict



/*-- These variables are shown in the EA and can be changed --*/
//==============================================================
//                  HEDGE FUND PROTOCOL
//               Capital Protection
//==============================================================

input bool       USE_HEDGE_FUND_PROTOCOL = true; // HEDGE FUND PROTOCOL Draw dwon control
input double      HFP_MIN_PROFIT_PERCENT  = 0.10;  // Close basket at +0.10%
input double HFP_MAX_LOSS_PERCENT    = 0.50;  // Close basket at -0.50%
input int     HFP_SLIPPAGE            = 30;
//--------------------------------------------------------------------
extern bool   Use_TP_In_Money=false;
extern double TP_In_Money=10;

//--------------------------------------------------------------------
/////////////////////////////////////////////////////////////////////////////////
input    string               txt32                    = "------------[Money Trailing Stop]---------------";
input    bool                 Enable_Trailing           = true; //Enable_Trailing
input    double               Take_Profit_Money       = 40.0; //Take Profit In Money (in current currency)
input    double               Stop_Loss_Money         = 10; //Stop Loss In Money(in current currency)
extern   double               index=1.1;//Loss Index
input bool         UseEquityStop = true;  //Use Equity Stop
input double       TotalEquityRisk = 1.0; //Total Equity Risk
/////////////////////////////////////////////////////////////////////////////////
//---------------------------------------------------------------------------------
extern double     Multiply=2.0;             // Multiply for Martingale
extern double     Lotsize=0.01;              // Lot size
extern double     TrailingStop=30;          // TrailingStop pips distance
extern int        Stop_Loss=100;            // Stop Loss pips distance
extern int        Take_Profit=50;           // Take Profit pips distance
extern int        MA_PERIOD=1;             // Moving Average Period
extern int        MA_PERIOD1=50;             // Moving Average Period
extern int        MagicNumber=562148;       // Magic Number
extern string     Timeset="Timeset";
extern int        Start=0;                  // Start hour
extern int        End=24;                   // End hour
extern int        Maximum_loss=3;           // Maximum allowed loss
extern int        WaitTime=180;             // Wait time for loss in minutes
int count_0=0;
datetime  TimeSent;
double pips;
int           err;
int total=0;
int /*cnt,*/freeze_level;
//--- price levels for orders and positions
double priceopen,stoploss,takeprofit;
bool               FractalsUp=false;
bool               FractalsDown=false;
double             FractalsUpPrice=0;
double             FractalsDownPrice=0;
int                FractalsLimit=200;
static int         losses=0;
//--------------------------------------------------------------- 3 --
int
Period_MA_2,  Period_MA_3,       // Calculation periods of MA for other timefr.
              Period_MA_02, Period_MA_03,      // Calculation periods of supp. MAs
              K2,K3,T;
int INDEX2=0;
double AccountEquityHighAmt,PrevEquity;
double PROFIT_SUM1=0;
double PROFIT_SUM2=0;
double PROFIT_SUM3 = 0;
//---------------------
datetime prevtime;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   freeze_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL);
   if(freeze_level!=0)
     {
      PrintFormat("SYMBOL_TRADE_FREEZE_LEVEL=%d: order or position modification is not allowed,"+
                  " if there are %d points to the activation price",freeze_level,freeze_level);
     }

  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
//===========================================================
// HEDGE FUND PROTOCOL - RUN EVERY TICK
//===========================================================
   if(HedgeFundProtocol())
      return;

//===========================================================
// OTHER MONEY MANAGEMENT
//===========================================================
   if(Use_TP_In_Money)
      Take_Profit_In_Money();

   if(Enable_Trailing)
      TRAIL_PROFIT_IN_MONEY2();

 

//===========================================================
// ENTRY LOGIC - ONLY ONCE PER NEW BAR
//===========================================================
   if(prevtime == Time[0])
      return;

   prevtime = Time[0];


//===========================================================
// ORIGINAL TRADING STRATEGY STARTS HERE
//===========================================================
   int   ticket=0;
   double AveragePrice=0;
   double Count=0;
   double CurrentPairProfit=CalculateProfit();
    if(UseEquityStop)
     {
      if(CurrentPairProfit<0.0 && MathAbs(CurrentPairProfit)>TotalEquityRisk/100.0*AccountEquityHigh())
        {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");

        }
     }

 
      //--- check for history and trading
      if(Bars<100)
        {
         Print("bars less than 100");
         return;
        }
      if(IsTradeAllowed()==false)
        {
         Print("Trade IS NOT Allowed");
         return;
        }
      //----
      /*if(GetLastError()==134) return;
         if(Start>End)
            if(Hour() >= End && Hour() < Start) return;
         if(Start<End)
            if(Hour() < Start || Hour() >= End) return;*/

      //+------------------------------------------------------------------+
      //|                          Martingale 1                            |
      //+------------------------------------------------------------------+
      ///////////////////////////////////////////////////////Martingale :////////////////////////////////////////////////


      //--- check for history and trading
      if(Bars<100)
        {
         Print("bars less than 100");
         return;
        }
      if(IsTradeAllowed()==false)
        {
         Print("Trade IS NOT Allowed");
         return;
        }

      //----
      if(Start>End)
         if(Hour() >= End && Hour() < Start)
            return;
      if(Start<End)
         if(Hour() < Start || Hour() >= End)
            return;
      //----
      if(GetLastError()==134)
         return;
      double   LastLots=0;
      int OrderType_last_loss=-1,OrderType_last_win=-1;
      datetime  last_OrderCloseTime_win=-1,last_OrderCloseTime_loss=-1;

      for(int i=0; i<OrdersHistoryTotal(); i++)
        {
         LastLots=0;
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==true &&
            OrderMagicNumber()==MagicNumber)
            if(LastLots<OrderLots())
              {
               LastLots=NormalizeDouble(OrderLots(),Digits);
              }
           {
            if(OrderProfit()>0)// last order win
              {
               OrderType_last_win=OrderType();
               last_OrderCloseTime_win=OrderCloseTime();
              }
            if(OrderProfit()<0)// last order loss
              {
               OrderType_last_loss=OrderType();
               last_OrderCloseTime_loss=OrderCloseTime();
               count_0++;
              }
           }
        }
      //-----------------------------------------------------------
      if(count_0>Maximum_loss)
         Sleep(6000*WaitTime);
      if(last_OrderCloseTime_win<last_OrderCloseTime_loss)// last order win or loss ?
        {

         if(trade()==2)
           {
            Open_Order(OP_SELL,LastLots) ;
           }
         if(trade()==1)
           {
            Open_Order(OP_BUY,LastLots);
           }
        }
      if(getOpenOrders()==0)
        {
         if(Volume[0]>1)
            return;
         if(AccountFreeMargin()<(1000*Lotsize))//check for money ?
           {
            Print("We have no money. Free Margin = ",AccountFreeMargin());
            return;
           }
         // Buy order
         if(trade()==1)
           {Open_Order1(OP_BUY,Lotsize); }
         // Sell Order
         if(trade()==2)
           {Open_Order1(OP_SELL,Lotsize); }
        }

     
  }
//+------------------------------------------------------------------+
//|                           Open_Order                             |
//+------------------------------------------------------------------+

//============================ Open_Order=======================================
int Open_Order(int tip,double llots)//martingale
  {

   int ticket=-1;
//if(OrdersTotal()==0)
   if(openorderthispair(Symbol())==0)
     {
      if(tip==0)
        {
         while(ticket==-1)
           {

            if(((AccountStopoutMode()==1) &&
                (AccountFreeMarginCheck(Symbol(),OP_BUY,LotsOptimized1Mx(llots))>AccountStopoutLevel()))
               || ((AccountStopoutMode()==0) &&
                   ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,LotsOptimized1Mx(llots)))*100)>AccountStopoutLevel())))
               if(AccountFreeMarginCheck(Symbol(),OP_BUY,LotsOptimized1Mx(llots)))
                  if(CheckMoneyForTrade(Symbol(),LotsOptimized1Mx(llots*Multiply),OP_BUY))
                     if(ticket>0)
                       {
                        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                           Print("BUY order opened : ",OrderOpenPrice());
                        Alert("we just got a buy signal on the ",_Period,"M",_Symbol);
                        SendNotification("we just got a buy signal on the1 "+(string)_Period+"M"+_Symbol);
                        SendMail("Order sent successfully","we just got a buy signal on the1 "+(string)_Period+"M"+_Symbol);
                       }
            if(AccountFreeMargin()<(10000*llots))//check for money ?
              {
               Print("We have no money. Free Margin = ",AccountFreeMargin());
               break;
              }
            if(IsTradeAllowed())
               ticket=OrderSend(Symbol(),OP_BUY,LotsOptimizedMx(llots*Multiply),ND(Ask),3,NDTP(Bid-Stop_Loss*pips),NDTP(Bid+Take_Profit*pips),"Long 1",MagicNumber,0,PaleGreen);
            if(ticket>-1)
               break;

           }
        }

      if(tip==1)
        {
         ticket=-1;
         while(ticket==-1)
           {

            if(((AccountStopoutMode()==1) &&
                (AccountFreeMarginCheck(Symbol(),OP_SELL,LotsOptimized1Mx(llots))>AccountStopoutLevel()))
               || ((AccountStopoutMode()==0) &&
                   ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_SELL,LotsOptimized1Mx(llots)))*100)>AccountStopoutLevel())))
               if(AccountFreeMarginCheck(Symbol(),OP_SELL,LotsOptimized1Mx(llots)))
                  if(CheckMoneyForTrade(Symbol(),LotsOptimized1Mx(llots),OP_SELL))
                     if(ticket>0)
                       {
                        if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                           Print("SELL order opened : ",OrderOpenPrice());
                        Alert("we just got a sell signal on the ",_Period,"M",_Symbol);
                        SendMail("Order sent successfully","we just got a sell signal on the "+(string)_Period+"M"+_Symbol);
                       }
            if(AccountFreeMargin()<(10000*llots))//check for money ?
              {
               Print("We have no money. Free Margin = ",AccountFreeMargin());
               break;
              }
            if(IsTradeAllowed())
               ticket=OrderSend(Symbol(),OP_SELL,LotsOptimizedMx(llots*Multiply),ND(Bid),3,NDTP(Ask+Stop_Loss*pips),NDTP(Ask-Take_Profit*pips),"Short 1",MagicNumber,0,Red);
            if(ticket>-1)
               break;

           }
        }
     }
//-----------
   return(0);
  }
//+------------------------------------------------------------------+
//|                           Open_Order1                            |
//+------------------------------------------------------------------+
//============================ Open_Order1=======================================
int Open_Order1(int tip,double llots)
  {
   int ticket=-1;
//if(OrdersTotal()==0)
     {
      if(tip==0)
        {
         while(ticket==-1)
           {

            if(((AccountStopoutMode()==1) &&
                (AccountFreeMarginCheck(Symbol(),OP_BUY,llots)>AccountStopoutLevel()))
               || ((AccountStopoutMode()==0) &&
                   ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,llots))*100)>AccountStopoutLevel())))
               if(CheckMoneyForTrade(Symbol(),LotsOptimized1x(),OP_BUY))
                  if(ticket>0)
                    {
                     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                        Print("BUY order opened : ",OrderOpenPrice());
                     Alert("we just got a buy signal on the ",_Period,"M",_Symbol);
                     SendNotification("we just got a buy signal on the1 "+(string)_Period+"M"+_Symbol);
                     SendMail("Order sent successfully","we just got a buy signal on the1 "+(string)_Period+"M"+_Symbol);
                    }
            if(AccountFreeMargin()<(10000*llots))//check for money ?
              {
               Print("We have no money. Free Margin = ",AccountFreeMargin());
               break;
              }
            if(IsTradeAllowed())
               ticket=OrderSend(Symbol(),OP_BUY,LotsOptimizedMx(Lotsize),ND(Ask),3,NDTP(Bid-Stop_Loss*pips),NDTP(Bid+Take_Profit*pips),"Long 1",MagicNumber,0,PaleGreen);
            if(ticket>-1)
               break;

           }
        }

      if(tip==1)
        {
         ticket=-1;
         while(ticket==-1)
           {

            if(((AccountStopoutMode()==1) &&
                (AccountFreeMarginCheck(Symbol(),OP_SELL,llots)>AccountStopoutLevel()))
               || ((AccountStopoutMode()==0) &&
                   ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_SELL,llots))*100)>AccountStopoutLevel())))
               if(CheckMoneyForTrade(Symbol(),LotsOptimized1x(),OP_SELL))
                  if(ticket>0)
                    {
                     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                        Print("SELL order opened : ",OrderOpenPrice());
                     Alert("we just got a sell signal on the ",_Period,"M",_Symbol);
                     SendMail("Order sent successfully","we just got a sell signal on the "+(string)_Period+"M"+_Symbol);
                    }
            if(AccountFreeMargin()<(10000*llots))//check for money ?
              {
               Print("We have no money. Free Margin = ",AccountFreeMargin());
               break;
              }
            if(IsTradeAllowed())
               ticket=OrderSend(Symbol(),OP_SELL,LotsOptimizedMx(Lotsize),ND(Bid),3,NDTP(Ask+Stop_Loss*pips),NDTP(Ask-Take_Profit*pips),"Short 1",MagicNumber,0,Red);
            if(ticket>-1)
               break;

           }
        }
     }
//-----------
   return(0);
  }
//+------------------------------------------------------------------+
//| Trailing stop loss                                               |
//+------------------------------------------------------------------+
// --------------- ----------------------------------------------------------- ------------------------
void Trail1()
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
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|   stop                                                           |
//+------------------------------------------------------------------+
//-----------------------------------------------------------------------------+
void stop()
  {
// int cnt;
//+------------------------------------------------------------------+
   double middleBB=iBands(Symbol(),0,20, 2,0,0,MODE_MAIN,1);//middle
   double lowerBB=iBands(Symbol(),0,20, 2,0,0,MODE_LOWER,1);//lower
   double upperBB=iBands(Symbol(),0,20, 2,0,0,MODE_UPPER,1);//upper
//+------------------------------------------------------------------+
   double  MacdMAIN=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double  MacdSIGNAL=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
//+------------------------------------------------------------------+
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
//+---------------------------------------------------------------------------+
//              IfOrderDoesNotExistBuy
//+---------------------------------------------------------------------------+
int IfOrderDoesNotExistBuy()
  {
   bool exists=false;
   for(int i=OrdersTotal(); i>=0; i--)
     {

      if(OrderSelect(i,SELECT_BY_POS)==true && OrderSymbol()==Symbol())
        {
         exists = true;
         return(exists);
        }
      else
        {
         Print("OrderSelect() error - ",(GetLastError()));
        }
     }

   if(exists==false)
     {
      //BuyOrderType();
      // return(exists);
     }
   return(0);
  }
//-----------------------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------
int trade()
//trading conditions
  {
//----------------------------------------------------------------------------
   double  MacdMAIN0=iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double  MacdSIGNAL0=iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
//--------------------------------------------------------------------------------------------------
   if((MacdMAIN0>0 && MacdMAIN0>MacdSIGNAL0) || (MacdMAIN0<0 && MacdMAIN0>MacdSIGNAL0))
      if(Fractals()==1)
         return(1);
      else
         if(Fractals()==2)
            if((MacdMAIN0>0 && MacdMAIN0<MacdSIGNAL0) || (MacdMAIN0<0 && MacdMAIN0<MacdSIGNAL0))

               return(2);
   return(0);
  }
//+------------------------------------------------------------------+
//+---------------------------------------------------------------------------+
int openorderthispair(string pair)//בוחרים עסקה בצמד המטבעות הנוכחי
  {
   total=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print("eror");//בודקים אם ישנה עסקה פתוחה בצמד הנוכחי
      if(OrderSymbol()==pair)
         total++;//סופרים סך הכל עסקאות
     }
   return(total);
  }
//-----------------------------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
double ND(double val)
  {
   return(NormalizeDouble(val, Digits));
  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimizedMx(double llots)
  {
   double lots=llots;
//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lots<minlot)
     {
      lots=minlot;
      Print("Volume is less than the minimal allowed ,we use",minlot);
     }
//--- maximal allowed volume of trade operations
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lots>maxlot)
     {
      lots=maxlot;
      Print("Volume is greater than the maximal allowed,we use",maxlot);
     }
//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lots/volume_step);
   if(MathAbs(ratio*volume_step-lots)>0.0000001)
     {
      lots=ratio*volume_step;

      Print("Volume is not a multiple of the minimal step ,we use the closest correct volume ",ratio*volume_step);
     }

   return(lots);

  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimized1Mx(double llots)
  {
   double lots=llots;
//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lots<minlot)
     { lots=minlot; }
//--- maximal allowed volume of trade operations
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lots>maxlot)
     { lots=maxlot;  }
//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lots/volume_step);
   if(MathAbs(ratio*volume_step-lots)>0.0000001)
     {  lots=ratio*volume_step;}
   if(((AccountStopoutMode()==1) &&
       (AccountFreeMarginCheck(Symbol(),OP_BUY,lots)>AccountStopoutLevel()))
      || ((AccountStopoutMode()==0) &&
          ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,lots))*100)>AccountStopoutLevel())))
      return(lots);
   /* else  Print("StopOut level  Not enough money for ",OP_SELL," ",lot," ",Symbol());*/
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimized1x()
  {
   double lots=Lotsize;
   int    orders=OrdersHistoryTotal();     // history orders total
   losses=0;                  // number of losses orders without a break
//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lots<minlot)
     { lots=minlot; }
//--- maximal allowed volume of trade operations
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lots>maxlot)
     { lots=maxlot;  }
//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lots/volume_step);
   if(MathAbs(ratio*volume_step-lots)>0.0000001)
     {  lots=ratio*volume_step;}
   return(lots);
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
bool CheckMoneyForTrade(string symb,double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
//-- if there is not enough money
// else if(free_margin<0)
   if((((AccountStopoutMode()==1) &&
        (AccountFreeMarginCheck(symb,type,lots)<AccountStopoutLevel()))
       || ((AccountStopoutMode()==0) &&
           ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_SELL,lots))*100)<AccountStopoutLevel()))))
     {
      Print("StopOut level  Not enough money for ",OP_SELL," ",lots," ",Symbol());
      return(false);
     }
   else
      if(free_margin<0)
        {
         string oper=(type==OP_BUY)? "Buy":"Sell";
         Print("Not enough money for ",oper," ",lots," ",symb," Error code=",GetLastError());
         return(false);
        }
//--- checking successful
   return(true);
  }
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
//--------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Fractals()
  {
//Initialization of the variables
   FractalsUp=false;
   FractalsDown=false;
   FractalsUpPrice=0;
   FractalsDownPrice=0;
//-------------------------------------------------------------------- - -----------------------
   double TENKAN_SEN=iIchimoku(NULL,T,9,26,52,MODE_TENKANSEN,1);       //RED LINE
   double KIJUN_SEN=iIchimoku(NULL,T,9,26,52,MODE_KIJUNSEN,1);         //BLUE LINE
//----------------------------------------------------------------------------
//For loop to scan the last FractalsLimit candles starting from the oldest and finishing with the most recent
   for(int i=FractalsLimit; i>=0; i--)
     {
      //If there is a fractal on the candle the value will be greater than zero and equal to the highest or lowest price
      double fu=iFractals(NULL,0,MODE_UPPER,i);
      double fd=iFractals(NULL,0,MODE_LOWER,i);
      //If there is an upper fractal I store the value and set true the FractalsUp variable
      if(fu>0)
         if(TENKAN_SEN>KIJUN_SEN)
            if(Low[2]<fu && Open[1]>fu)
              {
               FractalsUp=true;
               FractalsDown=false;
               FractalsUpPrice++;
               Print("FractalsUpPrice",FractalsUpPrice);
               //  if((High[1]<fu || High[2]<fu || High[3]<fu) && (Ask/*Open[0]*/>=fu))
               return(1);
              }
      //If there is an lower fractal I store the value and set true the FractalsDown variable
      if(fd>0)
         if(TENKAN_SEN<KIJUN_SEN)
            if(High[2]>fd && Open[1]<fd)
              {
               FractalsUp=false;
               FractalsDown=true;
               FractalsDownPrice++;
               Print("FractalsDownPrice",FractalsDownPrice);
               //  if((Low[1]>fd || Low[2]>fd || Low[3]>fd) && (Ask/*Open[0]*/<=fd))
               return(2);
              }
      //if the candle has both upper and lower fractal the values are stored but we do not consider it as last fractal
      if(fu>0 && fd>0)
        {
         FractalsUp=false;
         FractalsDown=false;
         FractalsUpPrice=fu;
         FractalsDownPrice=fd;
         return(0);
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
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
/*double Take_Profit_In_percent()
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
  }*/
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
//+------------------------------------------------------------------+
//|           TRAIL_PROFIT_IN_MONEY2                                 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int TRAIL_PROFIT_IN_MONEY2()
  {
   PROFIT_SUM1 = 0;
   PROFIT_SUM2 = 0;
   if(CountTrades() == 0)
     {
      PROFIT_SUM3 = 0;
      return(0);
     }
   for(int j=OrdersTotal()-1; j>=0; j--)
     {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol())
           {
            if(OrderType() == OP_BUY || OrderType() == OP_SELL)
              {
               PROFIT_SUM1  = (PROFIT_SUM1 + (OrderProfit() + OrderCommission() + OrderSwap()));
              }
           }
        }
     }
//---------------PROFIT---------------------------------------------------
   if(PROFIT_SUM1< Take_Profit_Money&&PROFIT_SUM1>0)
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
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
               if(PROFIT_SUM2<= PROFIT_SUM3 -Stop_Loss_Money)
                  RemoveAllOrders();
              }
           }
        }

     }
//---------------LOSS---------------------------------------------------
   if(PROFIT_SUM1< Take_Profit_Money &&PROFIT_SUM1<0)
      if(CalculateProfit()<0.0 && MathAbs(CalculateProfit())>TotalEquityRisk/100.0*AccountEquityHigh()*index)
        {
         for(int i=OrdersTotal(); i>0; i--)
           {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderSymbol()==Symbol())
                 {

                  if(OrderType() == OP_BUY || OrderType() == OP_SELL)


                    {
                     PROFIT_SUM2  = fabs(PROFIT_SUM2) + fabs(OrderProfit() + OrderCommission() + OrderSwap());
                    }
                  if(fabs(PROFIT_SUM1)<= fabs(PROFIT_SUM3))
                    {PROFIT_SUM3=fabs(PROFIT_SUM1);}
                  if(PROFIT_SUM2>= fabs(PROFIT_SUM3 -Stop_Loss_Money))
                     RemoveAllOrders();
                 }
              }
           }

        }
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
 

//==============================================================
// HEDGE FUND PROTOCOL SMART - פרוטוקול חכם למבחני נוסטרו
// Returns TRUE when basket closing condition was activated
//==============================================================
bool HedgeFundProtocol()
  {
   if(!USE_HEDGE_FUND_PROTOCOL)
      return(false);

   double BasketProfit = 0.0;
   int    Trades       = 0;

   //--- Calculate total profit/loss of all EA trades
   for(int i = OrdersTotal()-1; i >= 0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol()) continue;
      if(OrderMagicNumber() != MagicNumber) continue;
      if(OrderType() != OP_BUY && OrderType() != OP_SELL) continue;

      BasketProfit += OrderProfit() + OrderSwap() + OrderCommission();
      Trades++;
     }

   if(Trades == 0)
      return(false);

   double ProfitTarget = AccountBalance() * HFP_MIN_PROFIT_PERCENT / 100.0;
   double LossLimit    = AccountBalance() * HFP_MAX_LOSS_PERCENT / 100.0;
   
   // --- הגנת נוסטרו קשיחה (Hard Stop) ---
   // חיתוך חירום ב-4% הפסד על הסל, כדי לא להיפסל במבחן היומי של ה-5%
   double PropFirmHardStop = AccountBalance() * 4.0 / 100.0; 

   // לוגיקת סגירה חכמה
   if(BasketProfit >= ProfitTarget)
     {
      // הגענו ליעד הרווח - נסגור
     }
   else if(BasketProfit <= -PropFirmHardStop)
     {
      Print("PROP FIRM HARD STOP REACHED! Emergency close to protect account.");
     }
   else if(BasketProfit <= -LossLimit && Trades >= 3)
     {
      // הגענו להפסד המוגדר, ויש כבר 3 עסקאות פתוחות או יותר (מרטינגייל התפתח) - חותכים
      Print("Loss limit reached with multiple trades. Closing basket.");
     }
   else
     {
      // הסל בתוך טווח בטוח, או שיש מעט עסקאות והן זקוקות לאוויר כדי לתקן
      return(false); 
     }

   //--- PROFIT TARGET OR LOSS LIMIT REACHED: סגירת כל העסקאות
   for(int j = OrdersTotal()-1; j >= 0; j--)
     {
      if(!OrderSelect(j,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol()) continue;
      if(OrderMagicNumber() != MagicNumber) continue;
      if(OrderType() != OP_BUY && OrderType() != OP_SELL) continue;

      RefreshRates();
      double ClosePrice = (OrderType() == OP_BUY) ? Bid : Ask;
      
      if(!OrderClose(OrderTicket(), OrderLots(), ClosePrice, HFP_SLIPPAGE, clrNONE))
        {
         Print("HEDGE FUND PROTOCOL Close Error: ", GetLastError());
        }
     }
     
   return(true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades()
  {
   int count=0;
   for(int trade=OrdersTotal()-1; trade>=0; trade--)
     {
      if(!OrderSelect(trade,SELECT_BY_POS,MODE_TRADES))
         Print("Error");
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         if(OrderType()==OP_SELL || OrderType()==OP_BUY)
            count++;
     }
   return (count);
  }
//+------------------------------------------------------------------+
double AccountEquityHigh()
  {
   if(CountTrades()==0)
      AccountEquityHighAmt=AccountEquity();
   if(AccountEquityHighAmt<PrevEquity)
      AccountEquityHighAmt=PrevEquity;
   else
      AccountEquityHighAmt=AccountEquity();
   PrevEquity=AccountEquity();
   return (AccountEquityHighAmt);
  }
//+------------------------------------------------------------------+
double CalculateProfit()
  {
   double Profit=0;
   for(int cnt=OrdersTotal()-1; cnt>=0; cnt--)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         Print("Error");
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
         if(OrderType()==OP_BUY || OrderType()==OP_SELL)
            Profit+=OrderProfit();
     }
   return (Profit);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseThisSymbolAll()
  {
   double CurrentPairProfit=CalculateProfit();
   for(int trade=OrdersTotal()-1; trade>=0; trade--)
     {
      if(!OrderSelect(trade,SELECT_BY_POS,MODE_TRADES))
         Print("Error");
      if(OrderSymbol()==Symbol())
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            if(OrderType() == OP_BUY)
               if(!OrderClose(OrderTicket(), OrderLots(), Bid, 3, Blue))
                  Print("Error");
            if(OrderType() == OP_SELL)
               if(!OrderClose(OrderTicket(), OrderLots(), Ask, 3, Red))
                  Print("Error");
           }
         Sleep(1000);
         if(UseEquityStop)
           {
            if(CurrentPairProfit>0.0 && MathAbs(CurrentPairProfit)>TotalEquityRisk/100.0*AccountEquityHigh())
              {
               return;

              }
           }

        }
     }
  }
//+------------------------------------------------------------------+
