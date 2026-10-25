//+------------------------------------------------------------------+
//|                                        Custom Moving Average.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Jean-François LE BAS"
#property link      "https://www.metaquotes.net/"
#property strict

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 clrAqua
#property indicator_color2 clrOrangeRed
#property indicator_color3 clrYellow

//---- indicator parameters
extern int bars = 100;

extern int length = 50;
extern bool showMA = true;
extern int sig_length = 15;//signal length


extern string s6 = "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\";//_
extern string s7 = "           Alerts Parameters";//_
extern string s8 = "////////////////////////////////";//_

extern bool AudioAlert = 0;
extern string sound = "alert2.wav";
extern bool AlertAlert = 0;//Alert
extern bool EmailAlert = false;
extern bool PushAlert = false;
//---- indicator buffers
double up1[];
double up2[];
double dn1[];
double dn2[];
double bull[];
double bear[];
double ma[];
//----

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,bull);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,bear);

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ma);

   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,up1);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,up2);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,dn1);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,dn2);



//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int dir = 0;
int last = -1;
double increment;
double bounceSpeed;
double lastPrice = -1,profit=0;
int start()
  {

   int limit = Bars - IndicatorCounted() - 1;

   if(limit > bars)
     {
      limit = bars;
     }
   if(limit > Bars - 10)
     {
      limit = Bars - 10;
     }
   if(limit > Bars - 1 - length)
     {
      limit = Bars - 1 - length;
     }
   if(limit > Bars - 1 - sig_length)
     {
      limit = Bars - 1 - sig_length;
     }


//----
   for(int i = limit; i >= 0; i--)
     {
      /*   // This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
         // © alexgrover

         //Original post : Alpaca.markets/learn/andean-oscillator-a-new-technical-indicator-based-on-an-online-algorithm-for-trend-analysis/

         //@version=5
         indicator("Andean Oscillator")
         //------------------------------------------------------------------------------
         //Settings
         //-----------------------------------------------------------------------------{
         length     = input(50)

         sig_length = input(9,'Signal Length')

         //-----------------------------------------------------------------------------}
         //Exponential Envelopes
         //-----------------------------------------------------------------------------{
         var alpha = 2/(length+1)

         var up1 = 0.,var up2 = 0.
         var dn1 = 0.,var dn2 = 0.

         C = close
         O = open
         */
      double alpha = 2.0 / (double(length +1));
      double C = iClose(NULL,0,i);
      double O = iOpen(NULL,0,i);

      /*
      up1 := nz(math.max(C, O, up1[1] - (up1[1] - C) * alpha), C)
      up2 := nz(math.max(C * C, O * O, up2[1] - (up2[1] - C * C) * alpha), C * C)

      dn1 := nz(MathMin(C, O, dn1[1] + (C - dn1[1]) * alpha), C)
      dn2 := nz(MathMin(C * C, O * O, dn2[1] + (C * C - dn2[1]) * alpha), C * C)
      */

      if(up1[i+1] == 0 || up1[i+1] == EMPTY_VALUE)
         up1[i+1] = iClose(NULL,0,i+1);
      if(up2[i+1] == 0 || up2[i+1] == EMPTY_VALUE)
         up2[i+1] = iClose(NULL,0,i+1) * iClose(NULL,0,i+1);
      up1[i] = MathMax(MathMax(C, O), up1[i+1] - (up1[i+1] - C) * alpha);
      up2[i] = MathMax(MathMax(C * C, O * O), up2[i+1] - (up2[i+1] - C * C) * alpha);
      if(up1[i] == 0)
         up1[i] = C;
      if(up2[i] == 0)
         up2[i] = C * C;;

      if(dn1[i+1] == 0 || dn1[i+1] == EMPTY_VALUE)
         dn1[i+1] = iClose(NULL,0,i+1);
      if(dn2[i+1] == 0 || dn2[i+1] == EMPTY_VALUE)
         dn2[i+1] = iClose(NULL,0,i+1) * iClose(NULL,0,i+1);
      dn1[i] = MathMin(MathMin(C, O), dn1[i+1] + (C - dn1[i+1]) * alpha);
      dn2[i] = MathMin(MathMin(C * C, O * O), dn2[i+1] + (C * C - dn2[i+1]) * alpha);
      if(dn1[i] == 0)
         dn1[i] = C;
      if(dn2[i] == 0)
         dn2[i] = C * C;;


      /*
      //Components
      bull = MathSqrt(dn2 - dn1 * dn1)
      bear = MathSqrt(up2 - up1 * up1)*/

      bull[i] = MathSqrt(dn2[i] - dn1[i] * dn1[i]);
      bear[i] = MathSqrt(up2[i] - up1[i] * up1[i]);

      if(showMA)
        {
         int _cnt = 0;
         double ma_ = 0;
         for(int j = 0; j < sig_length; j++)
           {
            ma_ += MathMax(bull[i+j],bear[i+j]);
            _cnt++;
           }
         if(_cnt > 0)
            ma[i] = ma_ / double(_cnt);
         else
            ma[i] = ma_;
        }

      static datetime tim;

      if(tim != iTime(NULL,0,i))
        {
         tim = iTime(NULL,0,i);

         if(i == 0 && (last == 0 || last == -1) && bear[i] > bull[i])
           {
            nb = true;
            if(last > -1)
               AlertSell();
            last = 1;
           }
         else
            if(i == 0 && (last == 1 || last == -1) && bear[i] < bull[i])
              {
               nb = true;
               if(last > -1)
                  AlertBuy();
               last = 0;
              }
        }


      /*

      signal = ta.ema(MathMax(bull, bear), sig_length)

      //-----------------------------------------------------------------------------}
      //Plots
      //-----------------------------------------------------------------------------{
      plot(bull, 'Bullish Component', #089981)

      plot(bear, 'Bearish Component', #f23645)

      plot(signal, 'Signal', #ff9800)

      //-----------------------------------------------------------------------------}
      */

     }
   return 0;
  }

bool nb = true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AlertBuy()
  {
   if(nb)
     {
      string text = "";

      text = "Andean Osc : Open BUY order NOW on "+Symbol()+" "+GetNameTF(TFNumber(Period()))+ " !";

      SetAlert(text);
      nb = false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AlertSell()
  {
   if(nb)
     {
      string text = "";

      text = "Andean Osc : Open SELL order NOW on "+Symbol()+" "+GetNameTF(TFNumber(Period()))+ " !";

      SetAlert(text);
      nb = false;

     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetAlert(string s)
  {
   if(AudioAlert)
     {
      PlaySound(sound);
     }
   if(AlertAlert)
     {
      Alert(s);
     }
   if(EmailAlert)
     {
      SendMail(s, "Alert from indicator : ");
     }
   if(PushAlert)
     {
      SendNotification(s);
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TFNumber(int tf)
  {
   switch(tf)
     {
      case PERIOD_M1 :
         return 0;
         break;
      case PERIOD_M5 :
         return 1;
         break;
      case PERIOD_M15 :
         return 2;
         break;
      case PERIOD_M30 :
         return 3;
         break;
      case PERIOD_H1 :
         return 4;
         break;
      case PERIOD_H4 :
         return 5;
         break;
      case PERIOD_D1 :
         return 6;
         break;
      case PERIOD_W1 :
         return 7;
         break;
      case PERIOD_MN1 :
         return 8;
         break;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetNameTF(int ctTF)
  {
   switch(ctTF)
     {
      case 0 :
         return "M1";
         break;
      case 1 :
         return "M5";
         break;
      case 2 :
         return "M15";
         break;
      case 3 :
         return "M30";
         break;
      case 4 :
         return "H1";
         break;
      case 5 :
         return "H4";
         break;
      case 6 :
         return "D1";
         break;
      case 7 :
         return "W1";
         break;
      case 8 :
         return "MN1";
         break;
     }

   return "";
  }

//+------------------------------------------------------------------+
