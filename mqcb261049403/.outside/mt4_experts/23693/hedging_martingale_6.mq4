//+------------------------------------------------------------------+
//|                     MARTINGALE VI HYBRID                         |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.01"
#property strict


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
extern    int      Take_Profit=30;   // TP value of each trade in this Martingale EA
extern    int      PipStep       = 30;   // Distance in pips which will open a new trade
extern    double   Lots          = 0.1;  // The value of the initial lots , will be duplicated every step
extern    double   Multiply      = 2.0;  // Multiplier value every step of new trade
extern    int      MaxTrade=4;   // Maximum trades that can  run
extern    bool     CLOSEMAXORDERS=true;  // Close Maximum Orders
extern    int      EAMagicNumber=8095; // Magic Number
double   SetPoint=0;               // Variable SetPoint to code 4 or 5 digit brokers
double        pips;
int T=0;
int Count_one_message=0;
int           Tp,err,ntp,result;
double priceopen,stoploss,takeprofit;
/*--These parameters are to be displayed on the screen --*/
string   EAName               = "Martingale ver 1.0"; // EA name , to be displayed on the screen
string   EAComment            = "Martingale";         // This variable will we put in each trade as a Comment
 
//+---------------------------------------------------------------
double AccountEquityHighAmt,PrevEquity;
int INDEX2=0;
double PROFIT_SUM1=0;
double PROFIT_SUM2=0;
double PROFIT_SUM3 = 0;
//+----------------------
datetime prevtime;
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(ticksize==0.00001 || ticksize==0.001)
      pips=ticksize*10;
   else
      pips=ticksize;
   ntp=Take_Profit;
   SetBroker();/*--so EA can be running at 4 Digits Broker or 5 Digits--*/
//---
   switch(Period()) // Calculating coefficient for..
     {
      // .. different timeframes
      case     1:
         T=PERIOD_M15;
         break; // Timeframe M1
      case     5:
         T=PERIOD_M30;
         break; // Timeframe M5
      case    15:
         T=PERIOD_H1;
         break; // Timeframe M15
      case    30:
         T=PERIOD_H4;
         break; // Timeframe M30
      case    60:
         T=PERIOD_D1;
         break; // Timeframe H1
      case   240:
         T=PERIOD_W1;
         break; // Timeframe H4
      case  1440:
         T=PERIOD_MN1;
         break; // Timeframe D1
     }
//---
   return(INIT_SUCCEEDED);
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
 
   int total=0;
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
   if(AccountFreeMargin()<(1000*Lots))
     {
      Print("We have no money. Free Margin = ",AccountFreeMargin());
      return;
     }
     {
      //----
      int stops_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
      int   iTrade=0;

      double   SMA18=0,EMA200=0;
      /* -- This is where you insert coding indicators to trigger a trade --*/
      double  MacdMAIN=iMACD(NULL,T,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
      double  MacdSIGNAL=iMACD(NULL,T,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
      Comment(EAName);             // Show Name EA on screen
      /* --If no OP at all , then perform the following functions --*/
      /* -- This is where you insert coding indicators to trigger OP --*/
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            Print("eror");//בודקים אם ישנה עסקה פתוחה בצמד הנוכחי
         if(OrderSymbol()==Symbol())
            total++;//סופרים סך הכל עסקאות
         if(total>MaxTrade && CLOSEMAXORDERS==true)

           {
            exitsells();
            exitbuys();
            return;
           }
        }
      // Check for New Bar (Compatible with both MQL4 and MQL5)
      static datetime dtBarCurrent=WRONG_VALUE;
      datetime dtBarPrevious=dtBarCurrent;
      dtBarCurrent=(datetime) SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
      bool NewBarFlag=(dtBarCurrent!=dtBarPrevious);
      if(NewBarFlag)
        {
         if(getOpenOrders()==0)
            // if(OrdersTotal()==0)
           {
            //+------------------------------------------------------------------+
            //|                        /*-- Order Buy --*/                       |
            //+------------------------------------------------------------------+
            Tp=Take_Profit;
            if(Take_Profit<stops_level)
               Tp=stops_level;

            /*if(((AccountStopoutMode()==1) &&
               (AccountFreeMarginCheck(Symbol(),OP_BUY,Lots)>AccountStopoutLevel()))
               || ((AccountStopoutMode()==0) &&
               ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,Lots))*100)>AccountStopoutLevel())))*/
            if(CheckMoneyForTrade(Symbol(),LotsOptimized1(Lots),OP_BUY))
               if(IsTradeAllowed())
                  if(!OrderSend(Symbol(),OP_BUY,LotsOptimized(Lots),ND(Ask),3,0,NDTP(Ask+Tp*pips),EAComment,EAMagicNumber))
                     Print("eror",GetLastError());

            //+------------------------------------------------------------------+
            //|                          /*-- Order Sell --*/                    |
            //+------------------------------------------------------------------+
              {
               Tp=Take_Profit;
               if(Take_Profit<stops_level)
                  Tp=stops_level;
               /*if(((AccountStopoutMode()==1) &&
                  (AccountFreeMarginCheck(Symbol(),OP_SELL,Lots)>AccountStopoutLevel()))
                  || ((AccountStopoutMode()==0) &&
                  ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_SELL,Lots))*100)>AccountStopoutLevel())))*/
               if(CheckMoneyForTrade(Symbol(),LotsOptimized1(Lots),OP_SELL))
                  if(IsTradeAllowed())
                     if(!OrderSend(Symbol(),OP_SELL,LotsOptimized(Lots),ND(Bid),3,0,NDTP(Bid-Tp*pips),EAComment,EAMagicNumber))
                        Print("eror",GetLastError());
              }
           }
         /* -- This is the function of Martingale . If there OP is wrong , then do martingale --*/
         if(OrdersTotal()>=1)
           {
            if(Volume[0]>1)
               return;
            GoMartingale();
           }
         //----
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
/*--so EA can be running at 4 Digits Broker or 5 Digits--*/
void SetBroker()
  {
   if(Digits==3 || Digits==5) // Command to brokers 5 Digits
     {SetPoint=Point*10;}
   else                        // Command to brokers 4 Digits
     {SetPoint=Point;}
  }
//==============================================================================================================
//+------------------------------------------------------------------+
//|                        MARTINGALE                                |
//+------------------------------------------------------------------+
int GoMartingale()
  {
   int      iCount      =  0;
   double   LastOP      =  0;
   double   LastLots    =  0;
   bool     LastIsBuy   =  FALSE;
   int      iTotalBuy   =  0;
   int      iTotalSell  =  0;
   double      Spread=0;
   if(AccountFreeMargin()<(1000*Lots))
     {
      Print("We have no money. Free Margin = ",AccountFreeMargin());
      return(0);
     }
   Spread=MarketInfo(Symbol(),MODE_SPREAD);

   for(iCount=0; iCount<OrdersTotal(); iCount++)
     {

      if(!OrderSelect(iCount,SELECT_BY_POS,MODE_TRADES))
         Print("eror");

      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
        {
         if(LastOP==0)
           {
            LastOP=OrderOpenPrice();
           }
         if(LastOP>OrderOpenPrice())
           {
            LastOP=OrderOpenPrice();
           }
         if(LastLots<OrderLots())
           {
            LastLots=OrderLots();
           }
         LastIsBuy=TRUE;
         iTotalBuy++;

         //When it reaches the maximum limit of OP , OP do not add anymore */
         if(iTotalBuy==MaxTrade) //{return(0);}
           {
            if(CLOSEMAXORDERS==1)
              {
               exitbuys();
               return(0);
              }
           }

        }

      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
        {
         if(LastOP==0)
           {
            LastOP=OrderOpenPrice();
           }
         if(LastOP<OrderOpenPrice())
           {
            LastOP=OrderOpenPrice();
           }
         if(LastLots<OrderLots())
           {
            LastLots=OrderLots();
           }
         LastIsBuy=FALSE;
         iTotalSell++;

         //When it reaches the maximum limit of OP , OP do not add anymore */
         if(iTotalSell==MaxTrade) //{return(0);}
           {
            if(CLOSEMAXORDERS==1)
              {
               exitsells();
               return(0);
              }
           }

        }

     }

   /* If the Price is downtrend .... direction , check the Bid (*/
   if(LastIsBuy)
     {

      if(Bid<=LastOP-(Spread*SetPoint)-(PipStep*SetPoint))

        {
         if(((AccountStopoutMode()==1) &&
             (AccountFreeMarginCheck(Symbol(),OP_BUY,Lots)>AccountStopoutLevel()))
            || ((AccountStopoutMode()==0) &&
                ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,Lots))*100)>AccountStopoutLevel())))
            if(CheckMoneyForTrade(Symbol(),LotsOptimized(Multiply*LastLots),OP_BUY))
               if(IsTradeAllowed())
                  if(!OrderSend(Symbol(),OP_BUY,Multiply*LastLots,ND(Ask),3,0,NDTP(Ask+Take_Profit*SetPoint),EAComment,EAMagicNumber))
                     Print("eror",GetLastError());

         ModifyTP();
         LastIsBuy=FALSE;
         return(0);
        }
     }
   /* If the direction is Sell Price .... , check the value of Ask(*/
   else
      if(!LastIsBuy)
        {

         if(Ask>=LastOP+(Spread*SetPoint)+(PipStep*SetPoint))

           {
            if(((AccountStopoutMode()==1) &&
                (AccountFreeMarginCheck(Symbol(),OP_SELL,Lots)>AccountStopoutLevel()))
               || ((AccountStopoutMode()==0) &&
                   ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_SELL,Lots))*100)>AccountStopoutLevel())))
               if(CheckMoneyForTrade(Symbol(),LotsOptimized(Multiply*LastLots),OP_SELL))
                  if(IsTradeAllowed())
                     if(!OrderSend(Symbol(),OP_SELL,Multiply*LastLots,ND(Bid),3,0,NDTP(Bid-Take_Profit*SetPoint),EAComment,EAMagicNumber))
                        Print("eror",GetLastError());

            ModifyTP();
            return(0);
           }
        }
   return(0);
  }
//============================================================================================================================================
//+------------------------------------------------------------------+
//|                         MODIFY TAKE PROFIT                       |
//+------------------------------------------------------------------+
/*-- ModifyTP function is to change all that OP TP at the same point --*/
void ModifyTP()
  {
   int      iCount=0;
   double   NewTP=0;

   /*- Take Take Profit of the last Order -*/
   for(iCount=0; iCount<OrdersTotal(); iCount++)
     {
      if(!OrderSelect(iCount,SELECT_BY_POS,MODE_TRADES))
         Print("eror");

      /*-- If it is OP - BUY , TP take the smallest value . Make TP together --*/
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
        {
         if(NewTP==0)
           {
            NewTP=OrderTakeProfit();
           }
         if(NewTP>OrderTakeProfit())
           {
            NewTP=OrderTakeProfit();
           }
        }

      /*-- If it is OP - SELL , TP take the greatest value . Make TP together --*/
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
        {
         if(NewTP==0)
           {
            NewTP=OrderTakeProfit();
           }
         if(NewTP<OrderTakeProfit())
           {
            NewTP=OrderTakeProfit();
           }
        }
     }

   /*- Change all values ​​TakeProfit with the new OP ( 2X ) -*/
   for(iCount=0; iCount<OrdersTotal(); iCount++)
     {
      if(!OrderSelect(iCount,SELECT_BY_POS,MODE_TRADES))
         Print("eror");

      /*-If all OP is BUY , change their TP -*/
      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
        {
         RefreshRates();
         //stoploss=Bid-(pips*TrailingStop);
         double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD);
         if(NewTP<StopLevel*SetPoint)
            stoploss=StopLevel*SetPoint;
         string symbol=OrderSymbol();
         double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
         if(MathAbs(OrderTakeProfit()-NewTP)>point)
            if((NewTP-Ask)>(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*SetPoint)
               if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),0,NewTP))
                  if(!OrderModify(OrderTicket(),OrderLots(),0,NewTP,0))
                     Print("eror");
        }

      /*- If all OP is SELL , then change their TP -*/
      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
        {

         RefreshRates();
         // stoploss=Ask+(pips*TrailingStop);
         double  StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD);
         if(NewTP<StopLevel*SetPoint)
            stoploss=StopLevel*SetPoint;
         string symbol=OrderSymbol();
         double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
         if(MathAbs(OrderTakeProfit()-NewTP)>point)
            if((Bid-NewTP)>(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL)*SetPoint)
               if(OrderModifyCheck(OrderTicket(),OrderOpenPrice(),0,NewTP))
                  if(!OrderModify(OrderTicket(),OrderLots(),0,NewTP,0))
                     Print("eror");
        }

     }
  }
//====================================================================================================================================

//+------------------------------------------------------------------+
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimized(double lot)
  {
//double lot=Lots;
   int    orders=OrdersHistoryTotal();     // history orders total
//int    losses=0;                  // number of losses orders without a break
//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lot<minlot)
     {
      lot=minlot;
      Print("Volume is less than the minimal allowed ,we use",minlot);
     }
// lot=minlot;

//--- maximal allowed volume of trade operations
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lot>maxlot)
     {
      lot=maxlot;
      Print("Volume is greater than the maximal allowed,we use",maxlot);
     }
// lot=maxlot;

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lot/volume_step);
   if(MathAbs(ratio*volume_step-lot)>0.0000001)
     {
      lot=ratio*volume_step;

      Print("Volume is not a multiple of the minimal step ,we use the closest correct volume ",ratio*volume_step);
     }

   return(ND(lot));
   /* else  Print("StopOut level  Not enough money for ",OP_SELL," ",lot," ",Symbol());
      return(0);*/
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
double NDTP(double val)
  {
   RefreshRates();
   double FREEZELEVEL=MarketInfo(Symbol(),MODE_FREEZELEVEL);
   double SPREAD=MarketInfo(Symbol(),MODE_SPREAD);
   double StopLevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(val<StopLevel*SetPoint+SPREAD*SetPoint+FREEZELEVEL*SetPoint)
      val=StopLevel*SetPoint+SPREAD*SetPoint+FREEZELEVEL*SetPoint;
   return(NormalizeDouble(val, Digits));
  }
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ND(double val)
  {
   return(NormalizeDouble(val, Digits));
  }
//+------------------------------------------------------------------+
//|                                      exitbuys()                  |
//+------------------------------------------------------------------+
void exitbuys()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
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
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {

         if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
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
//+---------------------------------------------------------------------------+
int openorderthispair(string pair)//בוחרים עסקה בצמד המטבעות הנוכחי
  {
   int total=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print("eror");//בודקים אם ישנה עסקה פתוחה בצמד הנוכחי
      if(OrderSymbol()==pair)
         total++;//סופרים סך הכל עסקאות
     }
   return(total);
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
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimized1(double lot)
  {
//double lot=Lots;
   int    orders=OrdersHistoryTotal();     // history orders total
// int    losses=0;                  // number of losses orders without a break
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

   return(ND(lot));

  }
//+------------------------------------------------------------------+
int getOpenOrders()
  {

   int Orders=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
        {
         continue;
        }
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=EAMagicNumber)
        {
         continue;
        }
      Orders++;
     }
   return(Orders);
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
      if(OrderMagicNumber() != EAMagicNumber) continue;
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
      if(OrderMagicNumber() != EAMagicNumber) continue;
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
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=EAMagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==EAMagicNumber)
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
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=EAMagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==EAMagicNumber)
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
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==EAMagicNumber)
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
