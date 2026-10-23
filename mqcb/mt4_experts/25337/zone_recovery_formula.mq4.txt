//+------------------------------------------------------------------+
//|                            Zone_Recovery_Area Formula1           |
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
extern double Take_Profit=150;             //Take Profit(in pips)
extern double Zone_Recovery_Area=50;      //Zone_Recovery_Area(in pips)
extern double         Multiply=2;
extern   int      MaxTrade= 11;   // maximum Trades to run
input string  str5="Fast moving average";
input int     Period1=20;                 //Fast moving average(in pips)
input string  str6="Slow moving average";
input int     Period2=200;                //Slow moving average(in pips)
input double  ppo=0;               //PIP.PROFIT.OFSET:OPTIONAL OFSET FOR RECOVERY PROFIT
input int     MagicNumber=1111;
double buyprice;
bool result;

int    MAGICNUMBER1=MagicNumber;
int    MAGICNUMBER2=MagicNumber+1;
int    MAGICNUMBER3=MagicNumber+2;
int    MAGICNUMBER4=MagicNumber+3;
int    MAGICNUMBER5=MagicNumber+4;
int    MAGICNUMBER6=MagicNumber+5;
int    MAGICNUMBER7=MagicNumber+6;
int    MAGICNUMBER8=MagicNumber+7;
int    MAGICNUMBER9=MagicNumber+8;
int    MAGICNUMBER10=MagicNumber+9;
int    MAGICNUMBER11=MagicNumber+10;
int    MAGICNUMBER12=MagicNumber+11;
int    MAGICNUMBER13=MagicNumber+12;
int    MAGICNUMBER14=MagicNumber+13;
int    MAGICNUMBER15=MagicNumber+14;
int    MAGICNUMBER16=MagicNumber+15;
int    MAGICNUMBER17=MagicNumber+16;
int    MAGICNUMBER18=MagicNumber+17;
int    MAGICNUMBER19=MagicNumber+18;
int    MAGICNUMBER20=MagicNumber+19;

int           err,T;
double        pips;
//+-----------------
int INDEX2=0;
double PROFIT_SUM1=0;
double PROFIT_SUM2=0;
datetime prevtime;
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

   switch(Period()) // Calculating coefficient for..
     {
      // .. different timeframes
      case     1:
         T=PERIOD_M15;
         break;// Timeframe M1
      case     5:
         T=PERIOD_M30;
         break;// Timeframe M5
      case    15:
         T=PERIOD_H1;
         break;// Timeframe M15
      case    30:
         T=PERIOD_H4;
         break;// Timeframe M30
      case    60:
         T=PERIOD_D1;
         break;// Timeframe H1
      case   240:
         T=PERIOD_W1;
         break;// Timeframe H4
      case  1440:
         T=PERIOD_MN1;
         break;// Timeframe D1
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
   if(prevtime == Time[0])
      return;
   prevtime = Time[0];
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
   int Count_one_trade_f=0;
   int Count_one_trade_g=0;
   int Count_one_trade_h=0;
   int Count_one_trade_i=0;

   double TP=Take_Profit*pips;
   double RL=Zone_Recovery_Area*pips;
   double TPR1=TP-RL;
   double TPR2=TP+RL;
   double PPO=ppo*pips;
   double L1=Multiply;
   double L2=MathAbs(L1*TP)/(TPR1-PPO);
   double L3=MathAbs(L1*TP-L2*TPR2)/(TP-PPO);
   double L4=MathAbs(-L1*TP-L2*TPR1-L3*TP)/(TPR1-PPO);
   double L5=MathAbs(L1*TP-L2*TPR2+L3*TP-L4*TPR2)/(TP-PPO);
   double L6=MathAbs(-L1*TP+L2*TPR1-L3*TP+L4*TPR1-L5*TP)/(TPR1-PPO);
   double L7=MathAbs(L1*TP-L2*TPR2+L3*TP-L4*TPR2+L5*TP-L6*TPR2)/(TP-PPO);
   double L8=MathAbs(-L1*TP+L2*TPR1-L3*TP+L4*TPR1-L5*TP+L6*TPR1-L7*TP)/(TPR1-PPO);
   double L9=MathAbs(L1*TP-L2*TPR2+L3*TP-L4*TPR2+L5*TP-L6*TPR2+L7*TP-L8*TPR2)/(TP-PPO);
   double L10=MathAbs(-L1*TP+L2*TPR1-L3*TP+L4*TPR1-L5*TP+L6*TPR1-L7*TP+L8*TPR1-L9*TP)/(TPR1-PPO);

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

   if(CheckMoneyForTrade(Symbol(),Multiply*L1,OP_BUY)==1)
      if(OrdersTotal()==0)
        {
         buyprice=Ask;
         if(CheckVolumeValue(Multiply*L1)==true)
            int ticket16=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(L1)
                                   ,Ask,3,NDTP(Ask-(Take_Profit*pips+Zone_Recovery_Area*pips)),NDTP(Ask+Take_Profit*pips),"1",MAGICNUMBER1,0,Green);

        }
   if(MaxTrade<=1)
      return;
//if(Volume[0]>1) return;
   if(OrdersTotal()>=1)
     {
      if(MaxTrade==1)
         return;
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
                              if(CheckMoneyForTrade(Symbol(),Multiply*L2,OP_SELL)==1)
                                 if(CheckVolumeValue(Multiply*L2)==true)
                                    if(IsTradeAllowed())
                                       int ticket2=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(L2)
                                                             ,Bid,3,NDTP(OrderOpenPrice()+Take_Profit*pips),NDTP(OrderOpenPrice()-(Take_Profit*pips+Zone_Recovery_Area*pips)),"2",MAGICNUMBER2,0,Red);
            //buyprice=OrderOpenPrice();

            // exitbuys();  //CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_a++;
           }

         //                                       TRADE 3 ZONE RECOVERY1 1 LOT BUY ITERATION
         // =====================================================================================================================
         if(MaxTrade<=2)
            return;
         for(int buy2=OrdersTotal()-1; buy2>=0; buy2--)
           {
            if(Count_one_trade_b<1)
               if(OrderSelect(buy2,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER2)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(Ask>buyprice)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L3,OP_BUY)==1)
                                 if(CheckVolumeValue(Multiply*L3)==true)
                                    if(IsTradeAllowed())
                                       int ticket3=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(L3)
                                                             ,Ask,3,NDTP(buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),NDTP(buyprice+Take_Profit*pips),"3",MAGICNUMBER3,0,Green);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_b++;
           }
         //                                     TRADE 4 ZONE RECOVERY1 1.4 LOT SELL ITERATION
         // =====================================================================================================================
         if(MaxTrade<=3)
            return;
         for(int buy3=OrdersTotal()-1; buy3>=0; buy3--)
           {
            if(Count_one_trade_c<1)
               if(OrderSelect(buy3,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER3)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice-Zone_Recovery_Area*pips>Bid)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L4,OP_SELL)==1)
                                 if(CheckVolumeValue(Multiply*L4)==true)
                                    if(IsTradeAllowed())
                                       int ticket4=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(L4)
                                                             ,Bid,3,NDTP(buyprice+Take_Profit*pips),NDTP(buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),"4",MAGICNUMBER4,0,Red);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_c++;
           }

         //                                   TRADE 5 ZONE RECOVERY1 1.9 LOT BUY ITERATION
         // =====================================================================================================================
         if(MaxTrade<=4)
            return;
         for(int buy4=OrdersTotal()-1; buy4>=0; buy4--)
           {
            if(Count_one_trade_d<1)
               if(OrderSelect(buy4,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER4)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(Ask>buyprice)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L5,OP_BUY)==1)
                                 if(CheckVolumeValue(Multiply*L5)==true)
                                    if(IsTradeAllowed())
                                       int ticket5=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(L5)
                                                             ,Ask,3,NDTP(buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),NDTP(buyprice+Take_Profit*pips),"5",MAGICNUMBER5,0,Green);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_d++;
           }
         //                                   TRADE 6 ZONE RECOVERY1 2.5 LOT SELL ITERATION
         // =====================================================================================================================
         if(MaxTrade<=5)
            return;
         for(int buy5=OrdersTotal()-1; buy5>=0; buy5--)
           {
            if(Count_one_trade_e<1)
               if(OrderSelect(buy5,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER5)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice-Zone_Recovery_Area*pips>Bid)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L6,OP_SELL)==1)
                                 if(CheckVolumeValue(Multiply*L6)==true)
                                    if(IsTradeAllowed())
                                       int ticket6=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(L6)
                                                             ,Bid,3,NDTP(buyprice+Take_Profit*pips),NDTP(buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),"6",MAGICNUMBER6,0,Red);

            //  exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_e++;
           }
         // =====================================================================================================================
         if(MaxTrade<=6)
            return;
         for(int buy6=OrdersTotal()-1; buy6>=0; buy6--)
           {
            if(Count_one_trade_f<1)
               if(OrderSelect(buy6,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER6)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(Ask>buyprice)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L7,OP_BUY)==1)
                                 if(CheckVolumeValue(Multiply*L7)==true)
                                    if(IsTradeAllowed())
                                       int ticket3=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(L7)
                                                             ,Ask,3,NDTP(buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),NDTP(buyprice+Take_Profit*pips),"7",MAGICNUMBER7,0,Green);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_f++;
           }
         //                                     TRADE 8 ZONE RECOVERY1 1.4 LOT SELL ITERATION
         // =====================================================================================================================
         if(MaxTrade<=7)
            return;
         for(int buy7=OrdersTotal()-1; buy7>=0; buy7--)
           {
            if(Count_one_trade_g<1)
               if(OrderSelect(buy7,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER7)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice-Zone_Recovery_Area*pips>Bid)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L8,OP_SELL)==1)
                                 if(CheckVolumeValue(Multiply*L8)==true)
                                    if(IsTradeAllowed())
                                       int ticket4=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(L8)
                                                             ,Bid,3,NDTP(buyprice+Take_Profit*pips),NDTP(buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),"8",MAGICNUMBER8,0,Red);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_g++;
           }

         //                                   TRADE 5 ZONE RECOVERY1 1.9 LOT BUY ITERATION
         // =====================================================================================================================
         if(MaxTrade<=8)
            return;
         for(int buy8=OrdersTotal()-1; buy8>=0; buy8--)
           {
            if(Count_one_trade_h<1)
               if(OrderSelect(buy8,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER8)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(Ask>buyprice)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L9,OP_BUY)==1)
                                 if(CheckVolumeValue(Multiply*L9)==true)
                                    if(IsTradeAllowed())
                                       int ticket5=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(L9)
                                                             ,Ask,3,NDTP(buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),NDTP(buyprice+Take_Profit*pips),"9",MAGICNUMBER9,0,Green);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_h++;
           }
         //                                   TRADE 6 ZONE RECOVERY1 2.5 LOT SELL ITERATION
         // =====================================================================================================================
         if(MaxTrade<=9)
            return;
         for(int buy9=OrdersTotal()-1; buy9>=0; buy9--)
           {
            if(Count_one_trade_i<1)
               if(OrderSelect(buy9,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER9)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice-Zone_Recovery_Area*pips>Bid)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L10,OP_SELL)==1)
                                 if(CheckVolumeValue(Multiply*L10)==true)
                                    if(IsTradeAllowed())
                                       int ticket6=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(L10)
                                                             ,Bid,3,NDTP(buyprice+Take_Profit*pips),NDTP(buyprice-(Take_Profit*pips+Zone_Recovery_Area*pips)),"10",MAGICNUMBER10,0,Red);

            //  exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_i++;
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
   int Count_one_trade_j=0;
   int Count_one_trade_k=0;
   int Count_one_trade_l=0;
   int Count_one_trade_m=0;
   int Count_one_trade_n=0;
   int Count_one_trade_o=0;
   int Count_one_trade_p=0;
   int Count_one_trade_q=0;
   int Count_one_trade_r=0;
   int Count_one_trade_s=0;


   double TP=Take_Profit*pips;
   double RL=Zone_Recovery_Area*pips;
   double TPR1=TP-RL;
   double TPR2=TP+RL;
   double PPO=ppo*pips;
   double L1=Multiply;
   double L2=MathAbs(L1*TP)/(TPR1-PPO);
   double L3=MathAbs(L1*TP-L2*TPR2)/(TP-PPO);
   double L4=MathAbs(-L1*TP-L2*TPR1-L3*TP)/(TPR1-PPO);
   double L5=MathAbs(L1*TP-L2*TPR2+L3*TP-L4*TPR2)/(TP-PPO);
   double L6=MathAbs(-L1*TP+L2*TPR1-L3*TP+L4*TPR1-L5*TP)/(TPR1-PPO);
   double L7=MathAbs(L1*TP-L2*TPR2+L3*TP-L4*TPR2+L5*TP-L6*TPR2)/(TP-PPO);
   double L8=MathAbs(-L1*TP+L2*TPR1-L3*TP+L4*TPR1-L5*TP+L6*TPR1-L7*TP)/(TPR1-PPO);
   double L9=MathAbs(L1*TP-L2*TPR2+L3*TP-L4*TPR2+L5*TP-L6*TPR2+L7*TP-L8*TPR2)/(TP-PPO);
   double L10=MathAbs(-L1*TP+L2*TPR1-L3*TP+L4*TPR1-L5*TP+L6*TPR1-L7*TP+L8*TPR1-L9*TP)/(TPR1-PPO);
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
      if(CheckMoneyForTrade(Symbol(),Multiply*L1,OP_SELL)==1)
         if(CheckVolumeValue(Multiply*L1)==true)
            if(IsTradeAllowed())
               int ticket55=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(L1)
                                      ,Bid,3,NDTP(Bid+Take_Profit*pips+Zone_Recovery_Area*pips),NDTP(Bid-Take_Profit*pips),"11",MAGICNUMBER11,0,Red);

     }
   if(MaxTrade==1)
      return;
//if(Volume[0]>1) return;
   if(OrdersTotal()>=1)
     {
      //if ( MaxTrade==2)return;
      for(iCount=0; iCount<OrdersTotal(); iCount++)
        {
         for(int sell1=OrdersTotal()-1; sell1>=0; sell1--)
           {
            if(Count_one_trade_j<1)
               if(OrderSelect(sell1,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER11)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(OrderOpenPrice()+Zone_Recovery_Area*pips<Ask)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L2,OP_BUY)==1)
                                 if(CheckVolumeValue(Multiply*L2)==true)
                                    if(IsTradeAllowed())
                                       int ticket66=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(L2)
                                                              ,Ask,3,NDTP(OrderOpenPrice()-Take_Profit*pips),NDTP(OrderOpenPrice()+Take_Profit*pips+Zone_Recovery_Area*pips),"12",MAGICNUMBER12,0,Green);
            // buyprice=OrderOpenPrice();

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_j++;
           }
         //                                       TRADE 3 ZONE RECOVERY2 1 LOT BUY ITERATION
         // =====================================================================================================================
         if(MaxTrade<=2)
            return;
         for(int sell2=OrdersTotal()-1; sell2>=0; sell2--)
           {
            if(Count_one_trade_k<1)
               if(OrderSelect(sell2,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER12)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice>Bid)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L3,OP_SELL)==1)
                                 if(CheckVolumeValue(Multiply*L3)==true)
                                    if(IsTradeAllowed())
                                       int ticket8=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(L3)
                                                             ,Bid,3,NDTP(buyprice+Take_Profit*pips+Zone_Recovery_Area*pips),NDTP(buyprice-Take_Profit*pips),"13",MAGICNUMBER13,0,Red);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_k++;
           }
         //                                     TRADE 4 ZONE RECOVERY2 1.4 LOT SELL ITERATION
         // =====================================================================================================================
         if(MaxTrade<=3)
            return;
         for(int sell3=OrdersTotal()-1; sell3>=0; sell3--)
           {
            if(Count_one_trade_l<1)
               if(OrderSelect(sell3,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER13)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(OrderOpenPrice()+Zone_Recovery_Area*pips<Ask)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L4,OP_BUY)==1)
                                 if(CheckVolumeValue(Multiply*L4)==true)
                                    if(IsTradeAllowed())
                                       int ticket9=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(L4)
                                                             ,Ask,3,NDTP(buyprice-Take_Profit*pips),NDTP(buyprice+Take_Profit*pips+Zone_Recovery_Area*pips),"14",MAGICNUMBER14,0,Green);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_l++;
           }
         //                                   TRADE 5 ZONE RECOVERY2 1.9 LOT BUY ITERATION
         // =====================================================================================================================
         if(MaxTrade<=4)
            return;
         for(int sell4=OrdersTotal()-1; sell4>=0; sell4--)
           {
            if(Count_one_trade_m<1)
               if(OrderSelect(sell4,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER14)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice>Bid)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L5,OP_SELL)==1)
                                 if(CheckVolumeValue(Multiply*L5)==true)
                                    if(IsTradeAllowed())
                                       int ticket10=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(L5)
                                                              ,Bid,3,NDTP(buyprice+Take_Profit*pips+Zone_Recovery_Area*pips),NDTP(buyprice-Take_Profit*pips),"15",MAGICNUMBER15,0,Red);

            //  exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_m++;
           }

         //                                   TRADE 6 ZONE RECOVERY2 2.5 LOT SELL ITERATION
         // =====================================================================================================================
         if(MaxTrade<=5)
            return;
         for(int sell5=OrdersTotal()-1; sell5>=0; sell5--)
           {
            if(Count_one_trade_n<1)
               if(OrderSelect(sell5,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER15)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(OrderOpenPrice()+Zone_Recovery_Area*pips<Ask)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L6,OP_BUY)==1)
                                 if(CheckVolumeValue(Multiply*L6)==true)
                                    if(IsTradeAllowed())
                                       int ticket11=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(L6)
                                                              ,Ask,3,NDTP(buyprice-Take_Profit*pips),NDTP(buyprice+Take_Profit*pips+Zone_Recovery_Area*pips),"16",MAGICNUMBER16,0,Green);

            //exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_n++;
           }
         // =====================================================================================================================
         if(MaxTrade<=6)
            return;
         for(int sell6=OrdersTotal()-1; sell6>=0; sell6--)
           {
            if(Count_one_trade_o<1)
               if(OrderSelect(sell6,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER16)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice>Bid)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L7,OP_SELL)==1)
                                 if(CheckVolumeValue(Multiply*L7)==true)
                                    if(IsTradeAllowed())
                                       int ticket8=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(L7)
                                                             ,Bid,3,NDTP(buyprice+Take_Profit*pips+Zone_Recovery_Area*pips),NDTP(buyprice-Take_Profit*pips),"17",MAGICNUMBER17,0,Red);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_o++;
           }
         //                                     TRADE 8 ZONE RECOVERY2 1.4 LOT SELL ITERATION
         // =====================================================================================================================
         if(MaxTrade<=7)
            return;
         for(int sell7=OrdersTotal()-1; sell7>=0; sell7--)
           {
            if(Count_one_trade_p<1)
               if(OrderSelect(sell7,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER17)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(OrderOpenPrice()+Zone_Recovery_Area*pips<Ask)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L8,OP_BUY)==1)
                                 if(CheckVolumeValue(Multiply*L8)==true)
                                    if(IsTradeAllowed())
                                       int ticket9=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(L8)
                                                             ,Ask,3,NDTP(buyprice-Take_Profit*pips),NDTP(buyprice+Take_Profit*pips+Zone_Recovery_Area*pips),"18",MAGICNUMBER18,0,Green);

            // exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_p++;
           }
         //                                   TRADE 9 ZONE RECOVERY2 1.9 LOT BUY ITERATION
         // =====================================================================================================================
         if(MaxTrade<=8)
            return;
         for(int sell8=OrdersTotal()-1; sell8>=0; sell8--)
           {
            if(Count_one_trade_q<1)
               if(OrderSelect(sell8,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER18)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_BUY)
                           if(buyprice>Bid)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L9,OP_SELL)==1)
                                 if(CheckVolumeValue(Multiply*L9)==true)
                                    if(IsTradeAllowed())
                                       int ticket10=OrderSend(Symbol(),OP_SELL,LotsOptimized1Mx1(L9)
                                                              ,Bid,3,NDTP(buyprice+Take_Profit*pips+Zone_Recovery_Area*pips),NDTP(buyprice-Take_Profit*pips),"19",MAGICNUMBER19,0,Red);

            //  exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_q++;
           }

         //                                   TRADE 6 ZONE RECOVERY2 2.5 LOT SELL ITERATION
         // =====================================================================================================================
         if(MaxTrade<=9)
            return;
         for(int sell9=OrdersTotal()-1; sell9>=0; sell9--)
           {
            if(Count_one_trade_r<1)
               if(OrderSelect(sell9,SELECT_BY_POS,MODE_TRADES))
                  if(OrderMagicNumber()==MAGICNUMBER19)
                     if(OrderSymbol()==Symbol())
                        if(OrderType()==OP_SELL)
                           if(OrderOpenPrice()+Zone_Recovery_Area*pips<Ask)
                              if(CheckMoneyForTrade(Symbol(),Multiply*L10,OP_BUY)==1)
                                 if(CheckVolumeValue(Multiply*L10)==true)
                                    if(IsTradeAllowed())
                                       int ticket11=OrderSend(Symbol(),OP_BUY,LotsOptimized1Mx1(L10)
                                                              ,Ask,3,NDTP(buyprice-Take_Profit*pips),NDTP(buyprice+Take_Profit*pips+Zone_Recovery_Area*pips),"20",MAGICNUMBER20,0,Green);

            //exitbuys();//CLOSE BUY
            exit();//CLOSE SELL
            Count_one_trade_r++;
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
//----------------------------------------------------------------------------
   double  MacdMAIN0=iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double  MacdSIGNAL0=iMACD(NULL,PERIOD_MN1,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
//----------------------------------------------------------------------------
// Check for New Bar (Compatible with both MQL4 and MQL5)
   static datetime dtBarCurrent=WRONG_VALUE;
   datetime dtBarPrevious=dtBarCurrent;
   dtBarCurrent=(datetime) SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
   bool NewBarFlag=(dtBarCurrent!=dtBarPrevious);
//if(Volume[0]>1) return(0);{
   if(NewBarFlag)
     {
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
//| Calculate optimal lot size buy                                   |
//+------------------------------------------------------------------+
double LotsOptimized1Mx1(double llots)
  {
   double lots=llots*Multiply;
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
