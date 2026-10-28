//+------------------------------------------------------------------+
//|                               Gridtrading_at_volatile_market.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
// Timeframe : 60 on 4*Atr grid or 15 on 2*Atr a grid
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
input double Tp = 0.1;
input int SlowMa = 50;
input double Multiplier = 1.5;
input ENUM_TIMEFRAMES TimeFrame = 60;
double Volatility, Support, Resistance, Lot, Fma, Sma, AroonUp, AroonDown;
double Atr, Std, Diff, SavedPrice, Rsi, Bears;
bool TrendUp, TrendDown;
bool BuySignal, SellSignal, Uptouch, Downtouch, ShortSignal, LongSignal;
int Ticket, Biggertimeframe, a;

double TotalOrderLots()
{  double cnt = 0;
   for (int i = OrdersTotal()-1 ; i >=0 ; i --)
   {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         cnt = cnt+ OrderLots();
      }
   }
   return cnt;
}

double CalcMaxLot(string symbol, double Price)
  {
   double Maxlot;
   Maxlot = AccountFreeMargin()* AccountLeverage()*MarketInfo  (symbol,MODE_TICKSIZE)/MarketInfo(symbol,MODE_TICKVALUE)/Price;
   if (MarketInfo(Symbol(),MODE_LOTSIZE) == 1)
      {  
      double Maxlot2 = Round(Maxlot,1);
      if (Maxlot2 >= Maxlot) return Maxlot2-0.1;
      else return Maxlot2;
      }                                
   else 
      {  
      double Maxlot2 = Round(Maxlot,2);
      if (Maxlot2 >= Maxlot) return Maxlot2-0.01;
      else return Maxlot2;
      }
  }
      

double Round(double value, int decimals)
   {     
      double timesten, truevalue;
      if (decimals < 0) 
         {  
            Print("Wrong decimals input parameter, paramater cant be below 0");
            return 0;
         }
      timesten = value * MathPow(10,decimals);
      timesten = MathRound(timesten);
      truevalue = timesten/MathPow(10,decimals);
      return truevalue;
   }
      
double CalcGridLot(string symbol, int layers)
  {
   double lotsize = MarketInfo(symbol,MODE_LOTSIZE);
   double Gridlot;
   if (MarketInfo(symbol,MODE_MINLOT) == 0.1)
   {
   Gridlot = Round(CalcMaxLot(symbol,Ask)/layers,1);
   if (Gridlot == 0) Gridlot = 0.1;
   return Gridlot;
   }
   else 
   {
   Gridlot = Round(CalcMaxLot(symbol,Ask)/layers,2);
   if (Gridlot == 0) Gridlot = 0.01;
   return Gridlot;
   } 
}
      
bool IsNewCandle()
  {
   static datetime saved_candle_time;
   if(Time[0] == saved_candle_time)
      return false;
   else
      saved_candle_time = Time[0];
   return true;
  }

bool Bullish_Engulfing()
{
   return(Close[1] > High[2] && Low[1] < Low[2]);
}

bool Bearish_Engulfing()
{
   return(Close[1] < Low[2] && High[1] > High[2]);
}

double TotalInvested()
{
   double Lots = TotalOrderLots();
   return Lots*OrderOpenPrice()/MarketInfo(OrderSymbol(),MODE_TICKSIZE)*MarketInfo(OrderSymbol(),MODE_TICKVALUE)/AccountLeverage();
}

int GetBiggerTimeFrame(int Timef)
{
   if(Timef == 1) return 5;
   if(Timef == 5) return 15;
   if(Timef == 15) return 30;
   if(Timef == 30) return 60;
   if(Timef == 60) return 240;
   if(Timef == 240) return 1440;
   else return 1440;
}

bool CheckVolumeValue(double volume)
  {
//--- minimal allowed volume for trade operations
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      PrintFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      PrintFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      PrintFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
         volume_step,ratio*volume_step);
      return(false);
     }
   return(true);
  }

double OpenOrderProfits()
{
   double cnt = 0;
   for (int i = OrdersTotal(); i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if (OrderType() < 3)
      cnt += OrderProfit();

   }
   return cnt;
}
      
bool CloseAllOrders()
{
   
  while (OrdersTotal() != 0) for (int i = 0;i < OrdersTotal(); a++ )
   {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if (OrderType() <= 1) if (!OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK), 5000, clrAqua)) Print("Can't close all orders" + IntegerToString(GetLastError()));
         else if (OrderType() >= 2) if (!OrderDelete(OrderTicket())) Print("Can't close all orders" + IntegerToString(GetLastError()));
      }
   }
   if (OrdersTotal() == 0) return true;
   return false;
}


int OnInit()
  {
//---
   Biggertimeframe = GetBiggerTimeFrame(TimeFrame);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   CloseAllOrders();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {      
      if (IsNewCandle())
      {
         Atr = iATR(Symbol(),Biggertimeframe,20,0);
         Sma = iMA(Symbol(),Biggertimeframe,SlowMa,0,MODE_SMA,PRICE_CLOSE,0);
         Bears = iBearsPower(Symbol(),Biggertimeframe,13,PRICE_CLOSE,0);
         Rsi = iRSI(Symbol(),TimeFrame,14,PRICE_CLOSE,0);
         Std = iStdDev(Symbol(), PERIOD_D1, 20, 0, MODE_SMA,PRICE_CLOSE,0);
         Support = iCustom(Symbol(),Biggertimeframe,"\\DonchianChannel",20, 2,2, 0);
         Resistance = iCustom(Symbol(),Biggertimeframe,"\\DonchianChannel",20, 2,0, 0);
         if (!Uptouch && !Downtouch){
            Uptouch = ((High[1] > Resistance));
            Downtouch = ((Low[1] < Support));
         }
         if (Uptouch) {
            Downtouch = ((Low[1] < Support));
            Uptouch = !Downtouch;
         }
         if (Downtouch) {
            Uptouch = ((High[1] > Resistance));
            Downtouch = !Uptouch;
         }
         TrendUp = Close[0] > Sma && Rsi < 35 ;
         TrendDown = Close[0] < Sma && Rsi > 65;
         SellSignal = Uptouch && Bearish_Engulfing();
         BuySignal = Downtouch && Bullish_Engulfing(); 
         if (BuySignal && OrdersTotal() < 1)
         {  Diff = Atr;
            SavedPrice = Ask;
            Lot = CalcGridLot(Symbol(),60);
            if (!CheckVolumeValue(Lot)) return;
            Ticket = OrderSend(Symbol(),OP_BUY,Lot,Ask,500,NULL,NULL,"This is a buy", 4200, 0, clrGreen);
            a = 1;
         }
         if (SellSignal && OrdersTotal() < 1)
         {  Diff = Atr;
            SavedPrice = Bid;
            Lot = CalcGridLot(Symbol(),60);
            if (!CheckVolumeValue(Lot)) return;
            Ticket = OrderSend(Symbol(),OP_SELL,Lot,Bid,500,NULL,NULL,"This is a sell", 4200, 0, clrGreen);
            a = 1;
         }           
      }
      if (OrdersTotal() >=1)
      {     
            if (OrderSelect(Ticket,SELECT_BY_TICKET))
            {
               if (OrderType() == OP_BUY)
                  if (Ask <= SavedPrice - a*2*Atr)
                  {  
                     if (!CheckVolumeValue(Lot*MathPow(Multiplier,a))) return;
                     if(!OrderSend(Symbol(),OP_BUY,Lot*MathPow(Multiplier,a),Ask,500,NULL,NULL,"This is a buy", 4200, 0, clrGreen))
                     Print(IntegerToString(GetLastError()));
                     a++;
                  }
               if (OrderType() == OP_SELL)
                  if (Bid >= SavedPrice + a*2*Atr)
                  {
                     if (!CheckVolumeValue(Lot*MathPow(Multiplier,a))) return;
                     if(!OrderSend(Symbol(),OP_SELL,Lot*MathPow(Multiplier,a),Bid,500,NULL,NULL,"This is a sell", 4200, 0, clrGreen))
                     Print(IntegerToString(GetLastError()));
                     a++;
                  }
            }
            if (OpenOrderProfits() > TotalInvested() * Tp)
            {
               Ticket = 0;
               CloseAllOrders();
            }
            if (OpenOrderProfits() < -AccountBalance() * 0.8)   
            { 
               Ticket = 0;
               CloseAllOrders();
            }
      }   
  }
//+------------------------------------------------------------------+
