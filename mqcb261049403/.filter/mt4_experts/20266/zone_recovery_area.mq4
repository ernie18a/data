//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

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
extern double TakeProfit=150;             //Take Profit(in pips)
extern double Zone_Recovery_Area=50;      //Zone_Recovery_Area(in pips)
input string  str5="Fast moving average";
input int     Period1=20;                 //Fast moving average(in pips)
input string  str6="Slow moving average";
input int     Period2=200;                //Slow moving average(in pips)
input int     MAGICNUMBER=1111;
double buyprice;
bool result;

int    MAGICNUMBER1=MAGICNUMBER;
int    MAGICNUMBER2=MAGICNUMBER+1;
int    MAGICNUMBER3=MAGICNUMBER+2;
int    MAGICNUMBER4=MAGICNUMBER+3;
int    MAGICNUMBER5=MAGICNUMBER+4;
int    MAGICNUMBER6=MAGICNUMBER+5;
int    MAGICNUMBER7=MAGICNUMBER+6;
int    MAGICNUMBER8=MAGICNUMBER+7;
int    MAGICNUMBER9=MAGICNUMBER+8;
int    MAGICNUMBER10=MAGICNUMBER+9;
int    MAGICNUMBER11=MAGICNUMBER+10;
int    MAGICNUMBER12=MAGICNUMBER+11;

int           err,T;
double        pips;
//+-----------------
int INDEX2=0;
double PROFIT_SUM1=0;
double K2,K3,PROFIT_SUM2=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   double ticksize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(ticksize==0.00001 || Point==0.01)
      pips=ticksize*10;
   else
      pips=ticksize;

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

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Use_TP_In_Money)
     { Take_Profit_In_Money();}
   if(Use_TP_In_percent)
     { Take_Profit_In_percent();}
   if(Enable_Trailing==true)
     {TRAIL_PROFIT_IN_MONEY2();}
   if(trade()==2)
      ZONE_RECOVERY2();  //6 lower trades
   if(trade()==1)
      ZONE_RECOVERY1();  //6 upper trades

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
//|     Upper 6 trades            ZONE RECOVERY 1                    |
//+------------------------------------------------------------------+
void ZONE_RECOVERY1()
  {
//                                    TRADE 1+ 2 ZONE RECOVERY1 1 LOT-BUY ITERATION + 1.4 LOT- SELL ITERATION
// =====================================================================================================================
   int iCount=0;
   int Count_one_trade_a=0;
   int Count_one_trade_b=0;
   int Count_one_trade_c=0;
   int Count_one_trade_d=0;
   int Count_one_trade_e=0;
     {
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
     }

   if(CheckMoneyForTrade(Symbol(),0.01,OP_BUY)==1)
      if(OrdersTotal()==0)
        {
         buyprice=Ask;
         if(CheckVolumeValue(0.01)==true)
            if(IsTradeAllowed())
               int ticket16=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx(0.01),Ask,3,Ask-(TakeProfit*pips+Zone_Recovery_Area*pips),Ask+TakeProfit*pips,"1",MAGICNUMBER1,0,Green);

        }
//if(Volume[0]>1) return;
   if(OrdersTotal()>=1)
     {
      for(iCount=0; iCount<OrdersTotal(); iCount++)
        {

         for(int buy1=OrdersTotal()-1; buy1>=0; buy1--)
           {
            if(Count_one_trade_a<1)
               if(OrderSelect(buy1,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER1)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if((OrderOpenPrice()-Zone_Recovery_Area*pips>Bid) && (OrderOpenPrice()>Bid))
                              if(CheckMoneyForTrade(Symbol(),0.02,OP_SELL)==1)
                                 if(CheckVolumeValue(0.02)==true)
                                    if(IsTradeAllowed())
                                       int ticket2=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx(0.02),Bid,3,OrderOpenPrice()+TakeProfit*pips,OrderOpenPrice()-(TakeProfit*pips+Zone_Recovery_Area*pips),"2",MAGICNUMBER2,0,Red);
            //buyprice=OrderOpenPrice();

            // exitbuys();  //CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_a++;
           }

         //                                       TRADE 3 ZONE RECOVERY1 1 LOT BUY ITERATION
         // =====================================================================================================================
         for(int buy2=OrdersTotal()-1; buy2>=0; buy2--)
           {
            if(Count_one_trade_b<1)
               if(OrderSelect(buy2,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER2)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(Ask>buyprice)
                              if(CheckMoneyForTrade(Symbol(),0.04,OP_BUY)==1)
                                 if(CheckVolumeValue(0.04)==true)
                                    if(IsTradeAllowed())
                                       int ticket3=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx(0.04),Ask,3,buyprice-(TakeProfit*pips+Zone_Recovery_Area*pips),buyprice+TakeProfit*pips,"3",MAGICNUMBER3,0,Green);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_b++;
           }
         //                                     TRADE 4 ZONE RECOVERY1 1.4 LOT SELL ITERATION
         // =====================================================================================================================
         for(int buy3=OrdersTotal()-1; buy3>=0; buy3--)
           {
            if(Count_one_trade_c<1)
               if(OrderSelect(buy3,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER3)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice-Zone_Recovery_Area*pips>Bid)
                              if(CheckMoneyForTrade(Symbol(),0.08,OP_SELL)==1)
                                 if(CheckVolumeValue(0.08)==true)
                                    if(IsTradeAllowed())
                                       int ticket4=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx(0.08),Bid,3,buyprice+TakeProfit*pips,buyprice-(TakeProfit*pips+Zone_Recovery_Area*pips),"4",MAGICNUMBER4,0,Red);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_c++;
           }

         //                                   TRADE 5 ZONE RECOVERY1 1.9 LOT BUY ITERATION
         // =====================================================================================================================
         for(int buy4=OrdersTotal()-1; buy4>=0; buy4--)
           {
            if(Count_one_trade_d<1)
               if(OrderSelect(buy4,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER4)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(Ask>buyprice)
                              if(CheckMoneyForTrade(Symbol(),0.16,OP_BUY)==1)
                                 if(CheckVolumeValue(0.16)==true)
                                    if(IsTradeAllowed())
                                       int ticket5=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx(0.16),Ask,3,buyprice-(TakeProfit*pips+Zone_Recovery_Area*pips),buyprice+TakeProfit*pips,"5",MAGICNUMBER5,0,Green);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_d++;
           }
         //                                   TRADE 6 ZONE RECOVERY1 2.5 LOT SELL ITERATION
         // =====================================================================================================================
         for(int buy5=OrdersTotal()-1; buy5>=0; buy5--)
           {
            if(Count_one_trade_e<1)
               if(OrderSelect(buy5,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER5)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice-Zone_Recovery_Area*pips>Bid)
                              if(CheckMoneyForTrade(Symbol(),0.32,OP_SELL)==1)
                                 if(CheckVolumeValue(0.32)==true)
                                    if(IsTradeAllowed())
                                       int ticket6=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx(0.32),Bid,3,buyprice+TakeProfit*pips,buyprice-(TakeProfit*pips+Zone_Recovery_Area*pips),"6",MAGICNUMBER6,0,Red);

            //  exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_e++;
           }
        }
     }

  }
//
//=====================================================================================================================

//+------------------------------------------------------------------+
//|    Lower 6 trades                      ZONE RECOVERY2            |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ZONE_RECOVERY2()
  {
//                                    TRADE 1+ 2 ZONE RECOVERY2 1 LOT SELL ITERATION + 1.4 LOT- BUY ITERATION
// =====================================================================================================================
   int iCount=0;
   int Count_one_trade_f=0;
   int Count_one_trade_g=0;
   int Count_one_trade_h=0;
   int Count_one_trade_i=0;
   int Count_one_trade_j=0;
   int Count_one_trade_k=0;
     {
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
     }

   if(OrdersTotal()==0)
     {
      buyprice=Bid;
      if(CheckMoneyForTrade(Symbol(),0.01,OP_SELL)==1)
         if(CheckVolumeValue(0.01)==true)
            if(IsTradeAllowed())
               int ticket55=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx(0.01),Bid,3,Bid+TakeProfit*pips+Zone_Recovery_Area*pips,Bid-TakeProfit*pips,"7",MAGICNUMBER7,0,Red);

     }
//if(Volume[0]>1) return;
   if(OrdersTotal()>=1)
     {
      for(iCount=0; iCount<OrdersTotal(); iCount++)
        {
         for(int sell1=OrdersTotal()-1; sell1>=0; sell1--)
           {
            if(Count_one_trade_f<1)
               if(OrderSelect(sell1,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER7)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(OrderOpenPrice()+Zone_Recovery_Area*pips<Ask)
                              if(CheckMoneyForTrade(Symbol(),0.02,OP_BUY)==1)
                                 if(CheckVolumeValue(0.02)==true)
                                    if(IsTradeAllowed())
                                       int ticket66=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx(0.02),Ask,3,OrderOpenPrice()-TakeProfit*pips,OrderOpenPrice()+TakeProfit*pips+Zone_Recovery_Area*pips,"8",MAGICNUMBER8,0,Green);
            // buyprice=OrderOpenPrice();

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_f++;
           }
         //                                       TRADE 3 ZONE RECOVERY2 1 LOT BUY ITERATION
         // =====================================================================================================================
         for(int sell2=OrdersTotal()-1; sell2>=0; sell2--)
           {
            if(Count_one_trade_g<1)
               if(OrderSelect(sell2,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER8)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice>Bid)
                              if(CheckMoneyForTrade(Symbol(),0.04,OP_SELL)==1)
                                 if(CheckVolumeValue(0.04)==true)
                                    if(IsTradeAllowed())
                                       int ticket8=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx(0.04),Bid,3,buyprice+TakeProfit*pips+Zone_Recovery_Area*pips,buyprice-TakeProfit*pips,"9",MAGICNUMBER9,0,Red);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_g++;
           }
         //                                     TRADE 4 ZONE RECOVERY2 1.4 LOT SELL ITERATION
         // =====================================================================================================================
         for(int sell3=OrdersTotal()-1; sell3>=0; sell3--)
           {
            if(Count_one_trade_h<1)
               if(OrderSelect(sell3,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER9)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(OrderOpenPrice()+Zone_Recovery_Area*pips<Ask)
                              if(CheckMoneyForTrade(Symbol(),0.08,OP_BUY)==1)
                                 if(CheckVolumeValue(0.08)==true)
                                    if(IsTradeAllowed())
                                       int ticket9=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx(0.08),Ask,3,buyprice-TakeProfit*pips,buyprice+TakeProfit*pips+Zone_Recovery_Area*pips,"10",MAGICNUMBER10,0,Green);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_h++;
           }
         //                                   TRADE 5 ZONE RECOVERY2 1.9 LOT BUY ITERATION
         // =====================================================================================================================
         for(int sell4=OrdersTotal()-1; sell4>=0; sell4--)
           {
            if(Count_one_trade_i<1)
               if(OrderSelect(sell4,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER10)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice>Bid)
                              if(CheckMoneyForTrade(Symbol(),0.16,OP_SELL)==1)
                                 if(CheckVolumeValue(0.16)==true)
                                    if(IsTradeAllowed())
                                       int ticket10=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx(0.16),Bid,3,buyprice+TakeProfit*pips+Zone_Recovery_Area*pips,buyprice-TakeProfit*pips,"11",MAGICNUMBER11,0,Red);

            //  exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_i++;
           }

         //                                   TRADE 6 ZONE RECOVERY2 2.5 LOT SELL ITERATION
         // =====================================================================================================================
         for(int sell5=OrdersTotal()-1; sell5>=0; sell5--)
           {
            if(Count_one_trade_j<1)
               if(OrderSelect(sell5,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER11)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(OrderOpenPrice()+Zone_Recovery_Area*pips<Ask)
                              if(CheckMoneyForTrade(Symbol(),0.32,OP_BUY)==1)
                                 if(CheckVolumeValue(0.32)==true)
                                    if(IsTradeAllowed())
                                       int ticket11=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx(0.32),Ask,3,buyprice-TakeProfit*pips,buyprice+TakeProfit*pips+Zone_Recovery_Area*pips,"12",MAGICNUMBER12,0,Green);

            //exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_j++;
           }
        }
     }

  }
//=====================================================================================================================

//+------------------------------------------------------------------+
//|                                      exitbuys()                  |
//+------------------------------------------------------------------+
void exitbuys()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()==OP_BUY)
           {
            if((Ask==OrderTakeProfit()) || Bid==OrderStopLoss()) //If one order closed than close all
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
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                    exitsells()                                   |
//+------------------------------------------------------------------+
void exit()
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
/*double LotsOptimized1Mx(double llots)
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
   if(AccountEquity()>0&&(((AccountStopoutMode()==1) &&
      (AccountFreeMarginCheck(Symbol(),OP_BUY,lots)>AccountStopoutLevel()))
      || ((AccountStopoutMode()==0) &&((AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,lots))>0)&&
      ((AccountEquity()/(AccountEquity()-AccountFreeMarginCheck(Symbol(),OP_BUY,lots))*100)>AccountStopoutLevel()))))
      return(lots);
//else  Print("StopOut level  Not enough money for ",OP_SELL," ",lot," ",Symbol());
   return(0);
  }  */
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized1Mx(double llots)
  {
   double lot=llots;
   int    orders=OrdersHistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break
//--- select lot size
   /* if(MaximumRisk>0)
      {
       lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);
      }*/
//--- calcuulate number of losses orders without a break
   /* if(DecreaseFactor>0)
      {
       for(int i=orders-1; i>=0; i--)
         {
          if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
            {
             Print("Error in history!");
             break;
            }
          if(OrderSymbol()!=Symbol() )
             continue;
          //---
          if(OrderProfit()>0)
             break;
          if(OrderProfit()<0)
             losses++;
         }
       if(losses>1)
          lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
      }*/
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
