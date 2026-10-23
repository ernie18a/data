//+------------------------------------------------------------------+
//|                               2_Averages_with_BollingerBands.mq4 |
//|                                Copyright 2025, Mir Mostofa Kamal |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Mir Mostofa Kamal"
#property link      "https://www.mql5.com/en/users/bokul"
#property version   "1.00"
#property description   "mkbokul@gmail.com"
#property description   "Double Moving Averages With Bollinger Bands"
#property description   "This Indicator will be work in all time frame"
#property description   "WARNING: Use this software at your own risk."
#property description   "The creator of this script cannot be held responsible for any damage or loss. "
#property strict


#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_color4 OrangeRed
#property indicator_width3 2
#property indicator_width4 2

// Inputs
input string MA1_Settings        = "=== MA1 Settings ===";
input int MA1_Period = 7;                 //1st MA Period:
input int MA1_Method = MODE_EMA;          //1st MA Method:
input int MA1_Applied_Price = PRICE_CLOSE;//1st MA Price:

input string MA2_Settings        = "=== MA2 Settings ===";
input int MA2_Period = 21;                //2nd MA Period:
input int MA2_Method = MODE_SMA;          //2nd MA Method:
input int MA2_Applied_Price = PRICE_CLOSE;//2nd MA Price:

input string Alerts_Settings        = "=== Alerts Settings ===";
input bool EnableAlerts = true;           //Alerts On/Off:
input bool EnableEmail = false;           //Email Alerts On/Off:
input bool EnableSound = true;            //Alerts Sound On/Off:



input string BB_Settings        = "--- Bollinger Bands Settings ---";
input bool   Enable_BB          = true;             // Enable/Disable BB :
input int    BB_Period          = 60;               // BB Period :
input double BB_Deviation       = 2.0;              // BB Deviation:
input int    BB_Shift           = 2;                // BB Shift :
input int    BB_Applied_Price   = PRICE_CLOSE;      // BB Applied Price :
input color  BB_Color_Upper     = Yellow;           // Upper Band Color :
input color  BB_Color_Middle    = Yellow;           // Middle Band Color :
input color  BB_Color_Lower     = Yellow;           // Lower Band Color :
input int    BB_Width           = 1;                // Band Line Width :
input ENUM_LINE_STYLE BB_Style  = STYLE_DASHDOTDOT; // Line Style :

// Buffers
double MA1_Buffer[];
double MA2_Buffer[];
double BuyArrow[];
double SellArrow[];

//For Bolinger Bands
double BB_Upper[], BB_Middle[], BB_Lower[];

datetime lastAlertTime = 0;

//+---------On in it---------------------------------------------------------+

int OnInit()
  {
   SetIndexBuffer(0, MA1_Buffer);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexLabel(0, "MA1");

   SetIndexBuffer(1, MA2_Buffer);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexLabel(1, "MA2");

   SetIndexBuffer(2, BuyArrow);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 233);
   SetIndexLabel(2, "Buy Signal");

   SetIndexBuffer(3, SellArrow);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 234);
   SetIndexLabel(3, "Sell Signal");

//For Bolinger Bands
   if(Enable_BB)
     {
      SetIndexBuffer(4, BB_Upper);
      SetIndexStyle(4, DRAW_LINE, BB_Style, BB_Width, BB_Color_Upper);
      SetIndexLabel(4, "BB Upper");

      SetIndexBuffer(5, BB_Middle);
      SetIndexStyle(5, DRAW_LINE, BB_Style, BB_Width, BB_Color_Middle);
      SetIndexLabel(5, "BB Middle");

      SetIndexBuffer(6, BB_Lower);
      SetIndexStyle(6, DRAW_LINE, BB_Style, BB_Width, BB_Color_Lower);
      SetIndexLabel(6, "BB Lower");
     }

   return(INIT_SUCCEEDED);
  }

//+-----------On Calculate ------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int limit = rates_total - 2;

   for(int i = limit; i >= 1; i--)
     {
      // MA and signal arrows
      MA1_Buffer[i] = iMA(NULL, 0, MA1_Period, 0, MA1_Method, MA1_Applied_Price, i);
      MA2_Buffer[i] = iMA(NULL, 0, MA2_Period, 0, MA2_Method, MA2_Applied_Price, i);
      BuyArrow[i] = EMPTY_VALUE;
      SellArrow[i] = EMPTY_VALUE;

      if(MA1_Buffer[i] > MA2_Buffer[i] && MA1_Buffer[i+1] <= MA2_Buffer[i+1])
        {
         BuyArrow[i] = Low[i] - 5 * Point;
         if(i == 1 && Time[0] != lastAlertTime)
           {
            TriggerAlert("BUY", Time[0]);
            lastAlertTime = Time[0];
           }
        }
      else
         if(MA1_Buffer[i] < MA2_Buffer[i] && MA1_Buffer[i+1] >= MA2_Buffer[i+1])
           {
            SellArrow[i] = High[i] + 5 * Point;
            if(i == 1 && Time[0] != lastAlertTime)
              {
               TriggerAlert("SELL", Time[0]);
               lastAlertTime = Time[0];
              }
           }

      // Bollinger Bands
      if(Enable_BB)
        {
         BB_Upper[i]  = iBands(NULL, 0, BB_Period, BB_Deviation, BB_Shift, BB_Applied_Price, MODE_UPPER, i);
         BB_Middle[i] = iBands(NULL, 0, BB_Period, BB_Deviation, BB_Shift, BB_Applied_Price, MODE_MAIN, i);
         BB_Lower[i]  = iBands(NULL, 0, BB_Period, BB_Deviation, BB_Shift, BB_Applied_Price, MODE_LOWER, i);
        }
     }

   return(rates_total);
  }

//+-------------Alert system-----------------------------------------------------+
void TriggerAlert(string type, datetime alertTime)
  {
   string msg = StringFormat("2MA_BB: %s signal on %s %s at %s", type, Symbol(), PeriodToStr(), TimeToString(alertTime, TIME_DATE | TIME_MINUTES));
   if(EnableAlerts)
      Alert(msg);
   if(EnableSound)
      PlaySound("alert.wav");
   if(EnableEmail)
      SendMail("DoubleMA Signal", msg);
  }

//+-----------Period -------------------------------------------------------+
string PeriodToStr()
  {
   switch(Period())
     {
      case PERIOD_M1:
         return "M1";
      case PERIOD_M5:
         return "M5";
      case PERIOD_M15:
         return "M15";
      case PERIOD_M30:
         return "M30";
      case PERIOD_H1:
         return "H1";
      case PERIOD_H4:
         return "H4";
      case PERIOD_D1:
         return "D1";
      case PERIOD_W1:
         return "W1";
      case PERIOD_MN1:
         return "MN1";
      default:
         return IntegerToString(Period());
     }
  }

//+-----------------Code finish by Mir Mostofa Kamal -------------------------------------------------+
