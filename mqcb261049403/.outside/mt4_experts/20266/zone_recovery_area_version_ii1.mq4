//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                  Zone Recovery Area VERSION II   |
//|                   AHARON TZADIK                                  |
//|                                https://5d3071208c5e2.site123.me/ |
//+------------------------------------------------------------------+
#property copyright "AHARON TZADIK"
#property link      "https://5d3071208c5e2.site123.me/"
#property version   "1.00"
#property strict

/*-- This parameter is shown in the EA and can be changed --*/
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
extern   int         Take_Profit=200;    // TP value of each trade in this Martingale EA
extern   double      Zone_Recovery_Area=10;      //Zone_Recovery_Area(in pips)
extern   int         Slippage=3;    // What is the slippage ? Googling yourself ya ..
extern   double      Lotsize=0.01;  // The value of the initial lots , will be duplicated every step
extern   double      Multiply=1.0;  // Multiplier value every step of new trade
extern   int         MaxTrade= 1;   //  maximum trades that can  run
input    string      str5="Fast moving average";
input    int         Period1=20;                 //Fast moving average(in pips)
input    string      str6="Slow moving average";
input    int         Period2=200;                //Slow moving average(in pips)
input    int          MagicNumber=8095;
/*--This parameter is not displayed in EA --*/
string   EAName="R_O_B_O_T"; // EA name , to be displayed on the screen
string   EAComment="AHARON_TZADIK";               // This variable will we put in each trade as a Comment
double   SetPoint=0;                            // Variable SetPoint to code 4 or 5 digit brokers
double   buyprice=0;
double K2,K3,pips;
int INDEX2=0;
double PROFIT_SUM1=0;
double PROFIT_SUM2=0;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(ticksize==0.00001 || ticksize==0.001)
      pips=ticksize*10;
   else
      pips=ticksize;
   return(INIT_SUCCEEDED);
   SetBroker();

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   if(Use_TP_In_Money)
     { Take_Profit_In_Money();}
   if(Use_TP_In_percent)
     { Take_Profit_In_percent();}
   if(Enable_Trailing==true)
     {TRAIL_PROFIT_IN_MONEY2();}
   if(trade()==1)
     {
      ZONE_RECOVERY_BUY();
     }
   exitz();

   if(trade()==2)
     {
      ZONE_RECOVERY_SELL();
     }
   exitz();
   return(0);
  }
//----
//==============================================================================================================
//  *********************************       ZONE_RECOVERY           *********************************
//==============================================================================================================
// *********************************        ZONE_RECOVERY           *********************************
//==============================================================================================================
//  *********************************       ZONE_RECOVERY          *********************************
//==============================================================================================================
//+------------------------------------------------------------------+
//|         ZONE_RECOVERY_BUY                                        |
//+------------------------------------------------------------------+
int ZONE_RECOVERY_BUY()
  {
   int   iTrade=0;
   Comment(EAName); // Show EA Name on screen
   if(AccountFreeMargin()<(100*Lotsize))
     {
      Print("We have no money. Free Margin = ",AccountFreeMargin());
      return(0);
     }
   if(getOpenOrders()==0)
     {
        {
         buyprice=Ask;
         if((CheckVolumeValue(LotsOptimized1Mx1(Lotsize)))==TRUE)
            if((CheckMoneyForTrade(Symbol(),LotsOptimized1Mx1(Lotsize),OP_BUY))==TRUE)
               if((CheckStopLoss_Takeprofit(OP_BUY,NDTP(Ask-(Take_Profit*pips+Zone_Recovery_Area*pips)),NDTP(Ask+Take_Profit*pips)))==TRUE)
                  if(IsTradeAllowed())
                     if(!OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(Lotsize),NDM(Ask),5,NDTP(Ask-(Take_Profit*pips+Zone_Recovery_Area*pips)),
                                   NDTP(Ask+Take_Profit*pips),EAComment,MagicNumber))
                        Print("eror");
        }
     }
   /* -- This is the function zone recovery hedging--*/
   if(OrdersTotal()>=1)
     {
      ZONEBUY(buyprice);
     }
// exitz();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|         ZONE_RECOVERY_SELL                                       |
//+------------------------------------------------------------------+
int ZONE_RECOVERY_SELL()
  {
   if(AccountFreeMargin()<(100*Lotsize))
     {
      Print("We have no money. Free Margin = ",AccountFreeMargin());
      return(0);
     }
   int   iTrade=0;
   Comment(EAName);             // Show Name EA on screen
   if(getOpenOrders()==0)
     {
      buyprice=Bid;
      if((CheckVolumeValue(LotsOptimized1Mx1(Lotsize)))==TRUE)
         if((CheckMoneyForTrade(Symbol(),LotsOptimized1Mx1(Lotsize),OP_SELL))==TRUE)
            if((CheckStopLoss_Takeprofit(OP_SELL,NDTP(Bid+Take_Profit*pips+Zone_Recovery_Area*pips),NDTP(Bid-Take_Profit*pips)))==TRUE)
               if(IsTradeAllowed())
                  if(!OrderSend(Symbol(),OP_SELL,Lotsize,NDM(Bid),5,NDTP(Bid+Take_Profit*pips+Zone_Recovery_Area*pips),
                                NDTP(Bid-Take_Profit*pips),EAComment,MagicNumber))
                     Print("eror");
     }
   /* -- This is the function zone recovery hedging--*/
   if(OrdersTotal()>=1)
     {
      ZONESELL(buyprice);
     }
//exitz();
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
   if(AccountFreeMargin()<(100*Lotsize))
     {
      Print("We have no money. Free Margin = ",AccountFreeMargin());
      return(0);
     }
   for(iCount=0; iCount<OrdersTotal(); iCount++)
     {

      if(!OrderSelect(iCount,SELECT_BY_POS,MODE_TRADES))
         Print("eror");

      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==MagicNumber)
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

      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==MagicNumber)
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
      //if(iTotalBuy+iTotalSell>=2)
      if(Buyprice>Bid)
        {
         if((CheckVolumeValue(LotsOptimized1Mx1(Multiply*LastLots)))==TRUE)
            if((CheckMoneyForTrade(Symbol(),LotsOptimized1Mx1(Multiply*LastLots),OP_SELL))==TRUE)
               if((CheckStopLoss_Takeprofit(OP_SELL,NDTP(Buyprice+Take_Profit*pips+Zone_Recovery_Area*pips),NDTP(Buyprice-Take_Profit*pips)))==TRUE)
                  if(IsTradeAllowed())
                     if(!OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(Multiply*LastLots),NDM(Bid),5,NDTP(Buyprice+Take_Profit*pips+Zone_Recovery_Area*pips),
                                   NDTP(Buyprice-Take_Profit*pips),EAComment,MagicNumber))
                        Print("eror");
         // exitz();
         LastIsBuy=FALSE;
         return(0);
        }
     }
   /* If the direction is SELL- DOWN .... , check the value of Ask(*/
   else
      if(!LastIsBuy)
        {
         if(Buyprice+Zone_Recovery_Area*pips<Ask)
           {
            if((CheckVolumeValue(LotsOptimized1Mx1(Multiply*LastLots)))==TRUE)
               if((CheckMoneyForTrade(Symbol(),LotsOptimized1Mx1(Multiply*LastLots),OP_BUY))==TRUE)
                  if((CheckStopLoss_Takeprofit(OP_BUY,NDTP(Buyprice-(Take_Profit*pips+Zone_Recovery_Area+pips*pips)),NDTP(Buyprice+Take_Profit*pips)))==TRUE)
                     if(IsTradeAllowed())
                        if(!OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(Multiply*LastLots),NDM(Ask),5,NDTP(Buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),
                                      NDTP(Buyprice+Take_Profit*pips),EAComment,MagicNumber))
                           Print("eror");
            // exitz();
            return(0);
           }
        }
//exitz();
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
   if(AccountFreeMargin()<(100*Lotsize))
     {
      Print("We have no money. Free Margin = ",AccountFreeMargin());
      return(0);
     }
   for(iCount=0; iCount<OrdersTotal(); iCount++)
     {

      if(!OrderSelect(iCount,SELECT_BY_POS,MODE_TRADES))
         Print("eror");

      if(OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==MagicNumber)
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

      if(OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderComment()==EAComment && OrderMagicNumber()==MagicNumber)
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
      if(Buyprice-Zone_Recovery_Area*pips>Bid)
        {
         if((CheckVolumeValue(LotsOptimized1Mx1(Multiply*LastLots)))==TRUE)
            if((CheckMoneyForTrade(Symbol(),LotsOptimized1Mx1(Multiply*LastLots),OP_SELL)==1)==TRUE)
               if((CheckStopLoss_Takeprofit(OP_SELL,NDTP(Buyprice+Take_Profit*pips+Zone_Recovery_Area*pips),NDTP(Buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips))))==TRUE)
                  if(IsTradeAllowed())
                     if(!OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(Multiply*LastLots),NDM(Bid),5,NDTP(Buyprice+Take_Profit*pips),
                                   NDTP(Buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),EAComment,MagicNumber))
                        Print("eror");
         //exitz();
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
            if((CheckVolumeValue(LotsOptimized1Mx1(Multiply*LastLots)))==TRUE)
               if((CheckMoneyForTrade(Symbol(),LotsOptimized1Mx1(Multiply*LastLots),OP_BUY))==TRUE)
                  if((CheckStopLoss_Takeprofit(OP_BUY,NDTP(Buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),NDTP(Buyprice+Take_Profit*pips)))==TRUE)
                     if(IsTradeAllowed())
                        if(!OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(Multiply*LastLots),NDM(Ask),5,NDTP(Buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),
                                      NDTP(Buyprice+Take_Profit*pips),EAComment,MagicNumber))
                           Print("eror");
            //  exitz();
            return(0);
           }
        }
// exitz();
   return(0);
  }
//============================================================================================================================================
//============================================================================================================================================
//====================================================================================================================================
//-----------------------------------------------------------------------------------------------------------
int trade()
//trading conditions
  {
// Check for New Bar (Compatible with both MQL4 and MQL5)
   static datetime dtBarCurrent=WRONG_VALUE;
   datetime dtBarPrevious=dtBarCurrent;
   dtBarCurrent=(datetime) SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
   bool NewBarFlag=(dtBarCurrent!=dtBarPrevious);
//if(Volume[0]>1) return(0);{
   if(NewBarFlag)
     {
      double  MacdMAIN0=iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
      double  MacdSIGNAL0=iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
      if(iMA(Symbol(),0,Period1,0,0,0,1)<iMA(Symbol(),0,Period2,0,0,0,1))//BUY
         if((MacdMAIN0>0 && MacdMAIN0>MacdSIGNAL0) || (MacdMAIN0<0 && MacdMAIN0>MacdSIGNAL0))
            return(1);
         else
            if(iMA(Symbol(),0,Period1,0,0,0,1)>iMA(Symbol(),0,Period2,0,0,0,1))//SELL
               if((MacdMAIN0>0 && MacdMAIN0<MacdSIGNAL0) || (MacdMAIN0<0 && MacdMAIN0<MacdSIGNAL0))
                  return(2);
     }
   return(0);
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
//| Calculate optimal lot size                                     |
//+------------------------------------------------------------------+
/*double LotsOptimized1Mx1(double llots)
  {
double lot=llots;
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

   return(NDM(lot));

  }*/
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized1Mx1(double llots)
  {
   double lot=llots;
   int    orders=OrdersHistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
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
   if(AccountEquity()>0&&(((AccountStopoutMode()==1) &&
                           (AccountFreeMarginCheck(Symbol(),OP_BUY,llots)>AccountStopoutLevel()))
                          || ((AccountStopoutMode()==0) &&((AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,llots))>0)&&
                              ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,llots))*100)>AccountStopoutLevel()))))
      return(llots);
// return(lot);
   /* else  Print("StopOut level  Not enough money for ",OP_SELL," ",lot," ",Symbol());*/
   return(0);
  }
//+------------------------------------------------------------------+
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
double NDM(double val)
  {
   return(NormalizeDouble(val, Digits));
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                    exitz()                                        |
//+------------------------------------------------------------------+
void exitz()
  {
   int result,err;
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            datetime    ctm=OrderCloseTime();
            // if(ctm>0) Print("Close time for the order 10 ",ctm);
            if((TimeCurrent()-OrderCloseTime()<5) || (TimeCurrent()==OrderCloseTime()) || ((Ask==OrderTakeProfit() || Ask==OrderStopLoss()) || Bid==OrderStopLoss() || Bid==OrderTakeProfit()))
               for(i=OrdersTotal()-1; i>=0; i--)
                 {
                  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
                    {
                       {
                        if(OrderType()==OP_SELL)
                          {
                           result=OrderClose(OrderTicket(),OrderLots(),Ask /*OrderClosePrice()*/,5,Red);//actual order closing
                           if(result!=true)//if it did not close
                             {
                              err=GetLastError();
                              Print("LastError = ",err);//get the reason why it didn't close
                             }
                          }
                        else
                           if(OrderType()==OP_BUY)
                             {
                              result=OrderClose(OrderTicket(),OrderLots(),Bid/*OrderClosePrice()*/,5,Red);//actual order closing
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
//-----------------------------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume)

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
      return(false);
     }
//  description="Correct volume value";
   return(true);
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
