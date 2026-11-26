//+------------------------------------------------------------------+
//|                            Zone_Recovery_Area v1                 |
//|             http://algorithmic-trading-ea-mt4.000webhostapp.com/ |
//|                                                    AHARON TZADIK |
//+------------------------------------------------------------------+
#property copyright   "AHARON TZADIK"
#property link        "http://algorithmic-trading-ea-mt4.000webhostapp.com/"
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
input bool   UseEquityStop = true;  //Use Equity Stop
input double TotalEquityRisk = 1.0; //Total Equity Risk
extern   int         TakeProfit=200;    // TP value of each trade in this Martingale EA
extern   double      Zone_Recovery_Area=10;      //Zone_Recovery_Area(in pips)
extern   int         Slippage=3;    // What is the slippage ? Googling yourself ya ..
extern   double      Lots=0.01;  // The value of the initial lots , will be duplicated every step
extern   int         MaxTrade=100;   //  maximum trades that can  run
extern double        Multiply=2;
input    int         EAMagicNumber=8095;
double buyprice=0;
bool result;
bool BUTTON=0;
bool BUTTON1=0;

int           err,T;
double        pips;
//+-----------------
/*--This parameter is not displayed in EA --*/
string   EAName="W_H_O_ I_S_ Y_O_U_R_ D_A_D_Y ?"; // EA name , to be displayed on the screen
string   EAComment="AHARON_TZADIK";               // This variable will we put in each trade as a Comment
double   SetPoint=0;                            // Variable SetPoint to code 4 or 5 digit brokers
//---
int INDEX2=0;
double PROFIT_SUM1=0;
double PROFIT_SUM2=0;
double       AccountEquityHighAmt,PrevEquity;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double   buyprice=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()

//-----------------------------------------------------------------------------------------------------------
  {
   SetBroker();
   b1();
   double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(ticksize==0.00001 || Point==0.01)
      pips=ticksize*10;
   else
      pips=ticksize;

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete("BUY");
   ObjectDelete("SELL");
   ObjectDelete("CLOSE");
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(getOpenOrders()==0)
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="BUY")
         BUTTON=1;
   if(getOpenOrders()==0)
      if(id==CHARTEVENT_OBJECT_CLICK && sparam=="SELL")
         BUTTON1=1;
   if(id==CHARTEVENT_OBJECT_CLICK && sparam=="CLOSE")
     {
      exitx();  //CLOSE SELL
     }
//---

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   double CurrentPairProfit=CalculateProfit();
   if(Use_TP_In_Money)
     { Take_Profit_In_Money();}
   if(Use_TP_In_percent)
     { Take_Profit_In_percent();}
   if(Enable_Trailing==true)
     {TRAIL_PROFIT_IN_MONEY2();}
   if(UseEquityStop)
     {
      if(CurrentPairProfit<0.0 && MathAbs(CurrentPairProfit)>TotalEquityRisk/100.0*AccountEquityHigh())
        {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");

        }
     }
//------------------------------------------------------------------------------
   if(BUTTON==1)
     {
      ZONE_RECOVERY_BUY();  // lower trades
     }
   if(BUTTON1==1)
     {
      ZONE_RECOVERY_SELL();  // upper trades
     }

  }
//+---------------------------------------------------------------------------+
//|  We work only with open bar price  -        isnewcandle()                 |
//+---------------------------------------------------------------------------+
bool isnewcandle()
  {
   static int  barsonchart=0;
   if(Bars==barsonchart)
      return(false);
   barsonchart=Bars;
   return(true);
  }
//+---------------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|         ZONE_RECOVERY_BUY                                        |
//+------------------------------------------------------------------+
int ZONE_RECOVERY_BUY()
  {
   int   iTrade=0;
   Comment(EAName); // Show EA Name on screen
   if(AccountFreeMargin()<(1000*Lots))
     {
      Print("We have no money. Free Margin = ",AccountFreeMargin());
      return(0);
     }
   if(getOpenOrders()==0)
     {
        {
         buyprice=Ask;
         if(CheckVolumeValue(LotsOptimized1Mx1(Lots)))
            if(CheckMoneyForTrade(Symbol(),Lots,OP_BUY))
               if(CheckStopLoss_Takeprofit(OP_BUY,NDTP(Bid-(TakeProfit*pips+Zone_Recovery_Area*pips)),NDTP(Ask+TakeProfit*pips)))
                  if(IsTradeAllowed())
                     if(!OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(Lots),Ask,Slippage,NDTP(Bid-(TakeProfit*pips+Zone_Recovery_Area*pips)),
                                   NDTP(Ask+TakeProfit*pips),EAComment,EAMagicNumber))
                        Print("eror");
        }
     }
   /* -- This is the function zone recovery hedging--*/
   if(OrdersTotal()>=1)
     {
      ZONEBUY(buyprice);
     }
//exit();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|         ZONE_RECOVERY_SELL                                       |
//+------------------------------------------------------------------+
int ZONE_RECOVERY_SELL()
  {
   if(AccountFreeMargin()<(1000*Lots))
     {
      Print("We have no money. Free Margin = ",AccountFreeMargin());
      return(0);
     }
   int   iTrade=0;
   Comment(EAName);             // Show Name EA on screen
   if(getOpenOrders()==0)
     {
      buyprice=Ask;
      if(CheckVolumeValue(LotsOptimized1Mx1(Lots)))
         if(CheckMoneyForTrade(Symbol(),LotsOptimized1Mx1(Lots),OP_SELL))
            if(CheckStopLoss_Takeprofit(OP_SELL,NDTP(Bid+TakeProfit*pips+Zone_Recovery_Area*pips),NDTP(Bid-TakeProfit*pips)))
               if(IsTradeAllowed())
                  if(!OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,NDTP(Bid+TakeProfit*pips+Zone_Recovery_Area*pips),
                                NDTP(Bid-TakeProfit*pips),EAComment,EAMagicNumber))
                     Print("eror");
     }
   /* -- This is the function zone recovery hedging--*/
   if(OrdersTotal()>=1)
     {
      ZONESELL(buyprice);
     }
// exit();
//----
   return(0);
  }
//+------------------------------------------------------------------+
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
//|                      ZONE_RECOVERY_AREA_BUY                      |
//+------------------------------------------------------------------+
double ZONESELL(double Buyprice)
  {
   int      iCount      =  0;
   double   LastOP      =  0;
   double   LastLots    =  0;
   bool     LastIsBuy   =  FALSE;
   int      iTotalBuy   =  0;
   int      iTotalSell  =  0;
   double      Spread=0;

   Spread=MarketInfo(Symbol(),MODE_SPREAD);
   if(AccountFreeMargin()<(1000*Lots))
     {
      Print("We have no money. Free Margin = ",AccountFreeMargin());
      return(0);
     }
   for(iCount=0; iCount<OrdersTotal(); iCount++)
     {

      if(!OrderSelect(iCount,SELECT_BY_POS,MODE_TRADES))
         Print("eror");

      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
        {
         // if(LastOP==0) {LastOP=OrderOpenPrice();}
         if(LastLots<OrderLots())
           {
            LastLots=OrderLots();
           }
         LastIsBuy=TRUE;
         iTotalBuy++;

         /* When it reaches the maximum limit do not add anymore */
         if(iTotalBuy+iTotalSell>=MaxTrade)
           {
            return(0);
           }
        }

      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
        {
         //  if(LastOP==0) {LastOP=OrderOpenPrice();}
         if(LastLots<OrderLots())
           {
            LastLots=OrderLots();
           }
         LastIsBuy=FALSE;
         iTotalSell++;

         /* When it reaches the maximum limit do not add anymore */
         if(iTotalBuy+iTotalSell>=MaxTrade)
           {
            return(0);
           }
        }
     }

   /* If the Price is UP-BUY .... direction , check the Bid (*/
   if(LastIsBuy)
     {
      if(Buyprice>Bid)
        {
         if(CheckVolumeValue(LotsOptimized1Mx1(Multiply*LastLots)))
            if(CheckMoneyForTrade(Symbol(),LotsOptimized1Mx1(Multiply*LastLots),OP_SELL)==1)
               if(CheckStopLoss_Takeprofit(OP_SELL,NDTP(Buyprice+TakeProfit*pips+Zone_Recovery_Area*pips),NDTP(Buyprice-(TakeProfit*pips))))
                  if(IsTradeAllowed())
                     if(!OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(Multiply*LastLots),Bid,Slippage,NDTP(Buyprice+TakeProfit*pips+Zone_Recovery_Area*pips),
                                   NDTP(Buyprice-(TakeProfit*pips)),EAComment,EAMagicNumber))
                        Print("eror");
         // exit();
         LastIsBuy=FALSE;
         return(0);
        }
     }
   /* If the direction is SELL- DOWN .... , check the value of Ask(*/
   else
      if(!LastIsBuy)
        {
         if(Buyprice+Zone_Recovery_Area*SetPoint<Ask)
           {
            if(CheckVolumeValue(LotsOptimized1Mx1(Multiply*LastLots)))
               if(CheckMoneyForTrade(Symbol(),LotsOptimized1Mx1(Multiply*LastLots),OP_BUY)==1)
                  if(CheckStopLoss_Takeprofit(OP_BUY,NDTP(Buyprice+TakeProfit*pips+Zone_Recovery_Area*pips),NDTP(Buyprice+TakeProfit*pips+Zone_Recovery_Area*pips)))
                     if(IsTradeAllowed())
                        if(!OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(Multiply*LastLots),Ask,Slippage,NDTP(Buyprice+TakeProfit*pips+Zone_Recovery_Area*pips),
                                      NDTP(Buyprice+TakeProfit*pips+Zone_Recovery_Area*pips),EAComment,EAMagicNumber))
                           Print("eror");
            // exit();
            return(0);
           }
        }
// exit();
   return(0);
  }
//============================================================================================================================================
//+------------------------------------------------------------------+
//|                      ZONE_RECOVERY_AREA_SELL                     |
//+------------------------------------------------------------------+
int ZONEBUY(double Buyprice)
  {
   int      iCount      =  0;
   double   LastOP      =  0;
   double   LastLots    =  0;
   bool     LastIsBuy   =  FALSE;
   int      iTotalBuy   =  0;
   int      iTotalSell  =  0;
   double      Spread=0;

   Spread=MarketInfo(Symbol(),MODE_SPREAD);
   if(AccountFreeMargin()<(1000*Lots))
     {
      Print("We have no money. Free Margin = ",AccountFreeMargin());
      return(0);
     }
   for(iCount=0; iCount<OrdersTotal(); iCount++)
     {

      if(!OrderSelect(iCount,SELECT_BY_POS,MODE_TRADES))
         Print("eror");

      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
        {
         //if(LastOP==0) {LastOP=OrderOpenPrice();}
         if(LastLots<OrderLots())
           {
            LastLots=OrderLots();
           }
         LastIsBuy=TRUE;
         iTotalBuy++;

         /* When it reaches the maximum limit  do not add anymore */
         if(iTotalBuy+iTotalSell>=MaxTrade)
           {
            return(0);
           }
        }

      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==EAMagicNumber)
        {
         //if(LastOP==0) {LastOP=OrderOpenPrice();}
         if(LastLots<OrderLots())
           {
            LastLots=OrderLots();
           }
         LastIsBuy=FALSE;
         iTotalSell++;

         /* When it reaches the maximum limit  do not add anymore */
         if(iTotalBuy+iTotalSell>=MaxTrade)
           {
            return(0);
           }
        }

     }

   /* If the Price is UP BUY .... direction , check the Bid (*/
   if(LastIsBuy)
     {
      if(Buyprice-Zone_Recovery_Area*SetPoint>Bid)
        {
         if(CheckVolumeValue(LotsOptimized1Mx1(Multiply*LastLots)))
            if(CheckVolumeValue(Multiply*LastLots))
               if(CheckMoneyForTrade(Symbol(),LotsOptimized1Mx1(Multiply*LastLots),OP_SELL)==1)
                  if(CheckStopLoss_Takeprofit(OP_SELL,NDTP(Buyprice+TakeProfit*pips+Zone_Recovery_Area*pips),NDTP(Buyprice-(TakeProfit*pips+Zone_Recovery_Area*pips))))
                     if(IsTradeAllowed())
                        if(!OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(Multiply*LastLots),Bid,Slippage,NDTP(Buyprice+TakeProfit*pips),
                                      NDTP(Buyprice-(TakeProfit*pips+Zone_Recovery_Area*pips)),EAComment,EAMagicNumber))
                           Print("eror");
         // exit();
         LastIsBuy=FALSE;
         return(0);
        }
     }
   /* If the direction is Sell Price .... , check the value of Ask(*/
   else
      if(!LastIsBuy)
        {
         if(Ask>Buyprice)
           {
            if(CheckVolumeValue(LotsOptimized1Mx1(Multiply*LastLots)))
               if(CheckMoneyForTrade(Symbol(),LotsOptimized1Mx1(Multiply*LastLots),OP_BUY))
                  if(CheckStopLoss_Takeprofit(OP_BUY,NDTP(Buyprice-(TakeProfit*pips+Zone_Recovery_Area*pips)),NDTP(Buyprice+TakeProfit*pips)))
                     if(IsTradeAllowed())
                        if(!OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(Multiply*LastLots),Ask,Slippage,NDTP(Buyprice-(TakeProfit*pips+Zone_Recovery_Area*pips)),
                                      NDTP(Buyprice+TakeProfit*pips),EAComment,EAMagicNumber))
                           Print("eror");
            // exit();
            return(0);
           }
        }
// exit();
   return(0);
  }
//============================================================================================================================================
//====================================================================================================================================

//+---------------------------------------------------------------------------+
int openorderthispair(string pair)
  {
   int total=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         Print("eror");//בודקים אם ישנה עסקה פתוחה בצמד הנוכחי
      if(OrderSymbol()==pair)
         total++;
     }
   return(total);
  }
//-----------------------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,int type)
  {
   double free_margin=AccountFreeMarginCheck(symb,type,lots);
//-- if there is not enough money
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
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume/*,string &description*/)

  {
   double lot=volume;
   int    orders=OrdersHistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//--- select lot size
//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lot>max_volume)

      Print("Volume is greater than the maximal allowed ,we use",max_volume);
//  return(false);

//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lot<minlot)

      Print("Volume is less than the minimal allowed ,we use",minlot);
//  return(false);

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lot/volume_step);
   if(MathAbs(ratio*volume_step-lot)>0.0000001)
     {
      Print("Volume is not a multiple of the minimal step ,we use, the closest correct volume is %.2f",
            volume_step,ratio*volume_step);
      //   return(false);
     }
//  description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimized1Mx(double lot)
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
//+------------------------------------------------------------------+
int b1()
  {
   int chart_ID=0;
   string name="BUY";
   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,150);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,50);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,100);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,100);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,0);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,"BUY");
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,"Arial");
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,12);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clrBlue);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,clrGray);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,clrBlack);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,false);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,false);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,false);
//--- hide ( true)or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,false);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
//--- successful execution

//+------------------------------------------------------------------+
//| SELL                                                             |
//+------------------------------------------------------------------+
   string name1="SELL";
   if(!ObjectCreate(0,name1,OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name1,OBJPROP_XDISTANCE,250);
   ObjectSetInteger(chart_ID,name1,OBJPROP_YDISTANCE,50);
//--- set button size
   ObjectSetInteger(chart_ID,name1,OBJPROP_XSIZE,100);
   ObjectSetInteger(chart_ID,name1,OBJPROP_YSIZE,100);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name1,OBJPROP_CORNER,0);
//--- set the text
   ObjectSetString(chart_ID,name1,OBJPROP_TEXT,"SELL");
//--- set text font
   ObjectSetString(chart_ID,name1,OBJPROP_FONT,"Arial");
//--- set font size
   ObjectSetInteger(chart_ID,name1,OBJPROP_FONTSIZE,12);
//--- set text color
   ObjectSetInteger(chart_ID,name1,OBJPROP_COLOR,clrRed);
//--- set background color
   ObjectSetInteger(chart_ID,name1,OBJPROP_BGCOLOR,clrGray);
//--- set border color
   ObjectSetInteger(chart_ID,name1,OBJPROP_BORDER_COLOR,clrBlack);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name1,OBJPROP_BACK,false);
//--- set button state
   ObjectSetInteger(chart_ID,name1,OBJPROP_STATE,false);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name1,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name1,OBJPROP_SELECTED,false);
//--- hide ( true)or display (false) graphical object name1 in the object list
   ObjectSetInteger(chart_ID,name1,OBJPROP_HIDDEN,false);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name1,OBJPROP_ZORDER,0);
//--- successful execution

//+------------------------------------------------------------------+
//| CLOSE                                                             |
//+------------------------------------------------------------------+
   string name2="CLOSE";
   if(!ObjectCreate(0,name2,OBJ_BUTTON,0,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name2,OBJPROP_XDISTANCE,350);
   ObjectSetInteger(chart_ID,name2,OBJPROP_YDISTANCE,50);
//--- set button size
   ObjectSetInteger(chart_ID,name2,OBJPROP_XSIZE,100);
   ObjectSetInteger(chart_ID,name2,OBJPROP_YSIZE,100);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name2,OBJPROP_CORNER,0);
//--- set the text
   ObjectSetString(chart_ID,name2,OBJPROP_TEXT,"CLOSE");
//--- set text font
   ObjectSetString(chart_ID,name2,OBJPROP_FONT,"Arial");
//--- set font size
   ObjectSetInteger(chart_ID,name2,OBJPROP_FONTSIZE,12);
//--- set text color
   ObjectSetInteger(chart_ID,name2,OBJPROP_COLOR,clrRed);
//--- set background color
   ObjectSetInteger(chart_ID,name2,OBJPROP_BGCOLOR,clrGray);
//--- set border color
   ObjectSetInteger(chart_ID,name2,OBJPROP_BORDER_COLOR,clrBlack);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name2,OBJPROP_BACK,false);
//--- set button state
   ObjectSetInteger(chart_ID,name2,OBJPROP_STATE,false);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name2,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name2,OBJPROP_SELECTED,false);
//--- hide ( true)or display (false) graphical object name1 in the object list
   ObjectSetInteger(chart_ID,name2,OBJPROP_HIDDEN,false);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name2,OBJPROP_ZORDER,0);
//--- successful execution
   return(true);


  }
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                    exit()                                        |
//+------------------------------------------------------------------+
void exitx()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {

         //if(OrderType()==OP_SELL)
           {
            // if((Ask==OrderTakeProfit()) || Bid==OrderStopLoss())//If one order closed than close all
            if(OrderType()==OP_SELL)
              {
               result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Red);//actual order closing
               if(result!=true)//if it did not close
                 {
                  err=GetLastError();
                  Print("LastError = ",err);//get the reason why it didn't close
                 }
              }
            else
               if(OrderType()==OP_BUY)
                 {
                  result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Red);//actual order closing
                  if(result!=true)//if it did not close
                    {
                     err=GetLastError();
                     Print("LastError = ",err);//get the reason why it didn't close
                    }
                 }
           }

        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                    exit()                                        |
//+------------------------------------------------------------------+
void exit1()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {

         //if(OrderType()==OP_SELL)
           {
            if((Ask==OrderTakeProfit()) || Bid==OrderStopLoss())//If one order closed than close all
               if(OrderType()==OP_SELL)
                 {
                  result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Red);//actual order closing
                  if(result!=true)//if it did not close
                    {
                     err=GetLastError();
                     Print("LastError = ",err);//get the reason why it didn't close
                    }
                 }
               else
                  if(OrderType()==OP_BUY)
                    {
                     result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Red);//actual order closing
                     if(result!=true)//if it did not close
                       {
                        err=GetLastError();
                        Print("LastError = ",err);//get the reason why it didn't close
                       }
                    }
           }

        }
     }
  }
//+------------------------------------------------------------------+
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
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
/*double LotsOptimized1Mx1(double lot)
  {
   int    orders=OrdersHistoryTotal();     // history orders total
//--- minimal allowed volume for trade operations
   double minlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lot<minlot)
     {
      lot=minlot;
      Print("Volume is less than the minimal allowed ,we use",minlot);
     }
//--- maximal allowed volume of trade operations
   double maxlot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lot>maxlot)
     {
      lot=maxlot;
      Print("Volume is greater than the maximal allowed,we use",maxlot);
     }
//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(lot/volume_step);
   if(MathAbs(ratio*volume_step-lot)>0.0000001)
     {
      lot=ratio*volume_step;

      Print("Volume is not a multiple of the minimal step ,we use the closest correct volume ",ratio*volume_step);
     }
   return(NDM(lot));
  }*/
//+------------------------------------------------------------------+
double LotsOptimized1Mx1(double llots)
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
//|                    exit()                                        |
//+------------------------------------------------------------------+
void exit()
  {

   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==EAMagicNumber)
           {
            datetime    ctm=OrderCloseTime();
            if(ctm>0)
               Print("Close time for the order 10 ",ctm);
            if((TimeCurrent()-OrderCloseTime()<1) || ((Ask==OrderTakeProfit() || Ask==OrderStopLoss()) || Bid==OrderStopLoss() || Bid==OrderTakeProfit()))
               for(i=OrdersTotal()-1; i>=0; i--)
                 {
                  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                    {
                       {
                        if(OrderType()==OP_SELL)
                          {
                           result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Red);//actual order closing
                           if(result!=true)//if it did not close
                             {
                              err=GetLastError();
                              Print("LastError = ",err);//get the reason why it didn't close
                             }
                          }
                        else
                           if(OrderType()==OP_BUY)
                             {
                              result=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Red);//actual order closing
                              if(result!=true)//if it did not close
                                {
                                 err=GetLastError();
                                 Print("LastError = ",err);//get the reason why it didn't close
                                }
                             }
                       }

                    }
                 }
           }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double NDM(double val)
  {
   return(NormalizeDouble(val, Digits));
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double ND(double val)
  {
   return(NormalizeDouble(val, Digits));
  }
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TRAIL_PROFIT_IN_MONEY2()
  {
// double TP_Percent = ((TP_In_Money * AccountBalance()) / 100);
// double SL_Percent = ((SL_In_Money * AccountBalance()) / 100);
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
               // Print("PROFIT_SUM1",PROFIT_SUM1);
              }
           }
        }
     }
   if(PROFIT_SUM1>= Take_Profit_Money)
      // Print("PROFIT_SUM1",PROFIT_SUM1);
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
// if(PROFIT_SUM2<=SL_In_Money)
//  RemoveAllOrders();
   return(0);
  }
//+------------------------------------------------------------------+
