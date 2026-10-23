//+------------------------------------------------+
//| File        | Display_SLTP_Totals.mq4          |
//| Description | Displays open P/L.               |
//| Copyright   | TR4DEX                           |
//| Website     | http://www.tr4dex.com            | 
//+------------------------------------------------+
#property copyright "Copyright © 2017, TR4DEX"
#property link      "http://www.tr4dex.com"
#property indicator_chart_window
#property strict

input  bool  UseAlert = true;   //Send pop up alert
input  bool  UseSMS   = false;  //Send alert to phone

string total;
int    Orders=OrdersTotal();
double total_sl, total_tp;

int init()
  {
   total_sl = GetTotalSLValue();
   total_tp = GetTotalTPValue();
   Display_Info();
   return(0);
  }

void start()
{
   if(Orders!=OrdersTotal())
      {
      Orders   = OrdersTotal();
      total_sl = GetTotalSLValue();
      total_tp = GetTotalTPValue();
      if(UseAlert)
         Alert("Total SL: $"+DoubleToStr(total_sl,2)+" Total TP: $"+DoubleToStr(total_tp,2));
      if(UseSMS)
         SendNotification("Total SL: $"+DoubleToStr(total_sl,2)+" Total TP: $"+DoubleToStr(total_tp,2));
      }
   Display_Info();
}

void deinit()
{
   ObjectsDeleteAll();
   Comment("");
}

//+------------------------------------------------------------------+
//| Get Multiplier                                                   |
//+------------------------------------------------------------------+
int GetMultiplier(string s) 
{
   int m = 0;
   double digits = MarketInfo(s, MODE_DIGITS);
   if(digits==5)
      m = 10000;
   if(digits==4)
      m = 1000;
   if(digits==2 || digits==3)
      m = 100;
   return(m);
}

//+------------------------------------------------------------------+
//| Get Pips2Dbl                                                     |
//+------------------------------------------------------------------+
double GetPips2Dbl(string s) 
{
   double digits = MarketInfo(s, MODE_DIGITS), p=0;
   if (digits == 5 || digits == 3) p = MarketInfo(s, MODE_POINT)*10; 
   else p = MarketInfo(s, MODE_POINT);
   return(p);
}

//+------------------------------------------------------------------+
//| Get Total SL Value                                               |                                  
//+------------------------------------------------------------------+
double GetTotalSLValue()
{
   double sl_value = 0, total_sl_value = 0, delta;
   
   for (int v = OrdersTotal() - 1; v >= 0; v--) 
      {
         if (OrderSelect(v, SELECT_BY_POS))
            {
            if (OrderStopLoss()!=0) //&& OrderMagicNumber()==111)
               {
               delta    = (MarketInfo(OrderSymbol(),MODE_TICKVALUE)/MarketInfo(OrderSymbol(),MODE_TICKSIZE))*GetPips2Dbl(OrderSymbol());
               sl_value = ((MathAbs(OrderOpenPrice()-OrderStopLoss())*delta)*OrderLots())*GetMultiplier(OrderSymbol());
               sl_value -= (OrderCommission()+OrderSwap());
               sl_value = -(sl_value);
               total_sl_value += sl_value;
               }
           }
      } 
   return(NormalizeDouble(total_sl_value,2));
}

//+------------------------------------------------------------------+
//| Get Total TP Value                                               |                                  
//+------------------------------------------------------------------+
double GetTotalTPValue()
{
   double tp_value = 0, total_tp_value = 0, delta;
   
   for (int v = OrdersTotal() - 1; v >= 0; v--) 
      {
         if (OrderSelect(v, SELECT_BY_POS))
            {
            if (OrderTakeProfit()!=0) //&& OrderMagicNumber()==111)
               {
               delta    = (MarketInfo(OrderSymbol(),MODE_TICKVALUE)/MarketInfo(OrderSymbol(),MODE_TICKSIZE))*GetPips2Dbl(OrderSymbol());
               tp_value = ((MathAbs(OrderOpenPrice()-OrderTakeProfit())*delta)*OrderLots())*GetMultiplier(OrderSymbol());
               tp_value -= (OrderCommission()+OrderSwap());
               total_tp_value += tp_value;
               }
            }
      } 
   return(NormalizeDouble(total_tp_value,2));
}

//+------------------------------------------------------------------+
//| Display Info                                                     |
//+------------------------------------------------------------------+
void Display_Info()
{
            total = ""
            +"Total SL: $"+DoubleToStr(total_sl,2)+"\n"
            +"Total TP: $"+DoubleToStr(total_tp,2)+"\n";
            Comment("\n" + total);  
}