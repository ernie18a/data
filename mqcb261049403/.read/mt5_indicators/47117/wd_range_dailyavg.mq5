//+-------------------------------------------------------------------+
//|                                             wd.Range_DailyAvg.mq5 |
//|                 Copyright © 2023, Karya Prima Rajasa Mediavestama |
//|                                  Programmed by widhie75@yahoo.com |
//|                                                                   |
//|                            Basic idea: 'TSR_Ranges.mq4' by Ogeima |
//+-------------------------------------------------------------------+
#property copyright   "Copyright © 2023, Karya Prima Rajasa Mediavestama."
#property link        "https://www.mql5.com/en/code/47117"
#property version     "2.23"
#property strict
#property description "Calculate the 'Average Daily Range' based on 20 days of historical upper-lower price data, to estimate today's price movements."
#property description "When the projected trend is upward, taking profit opportunities can be measure by configuring indicator properties with 'Estimated today price zone = Room_up'."
#property description "During downward trends, selling price levels and profit target can be measure using 'Estimated today price zone = Room_down'."

#property indicator_chart_window
#property indicator_plots 0

// Define ENUM_ANCHOR before using it
enum ENUM_ANCHOR
  {
   Room_up,
   Room_down
  };

// Input parameters
input bool showAverageDaysRangeInfo = true; // Display Average Range Information
input color RectColor = clrYellow; // Today's price zone color
input ENUM_LINE_STYLE LineStyle = STYLE_DASH; //Price zone style
input int LineWidth = 2; //Price zone border width
input ENUM_ANCHOR Anchor = Room_up; // Estimated today price zone

// Declare the variables at a higher scope so that they can be accessed by both functions


double lowestPrice = 0; // Declare lowestPrice variable
double highestPrice = 0; // Declare highestPrice variable

// Rectangle object name
string rectangleObjectName = "Today Price Zone";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   int avgDayRange = 0;
   int prevDayRange = 0;
   int avgRange02 = 0;
   int avgRange05 = 0;
   int avgRange10 = 0;
   int avgRange20 = 0;

   if(showAverageDaysRangeInfo)
     {
      AverageDaysRangeInfo(avgDayRange,prevDayRange,avgRange02,avgRange05,avgRange10,avgRange20);
     }

     {
      // Calculate the average ranges over the specified periods
      int sumRange02 = 0;
      int sumRange05 = 0;
      int sumRange10 = 0;
      int sumRange20 = 0;

      for(int i = 1; i <= 20; i++)
        {
         int dailyRange = int((iHigh(NULL, PERIOD_D1, i) - iLow(NULL, PERIOD_D1, i)) / _Point);
         sumRange20 += dailyRange;

         if(i <= 2)
            sumRange02 += dailyRange;
         if(i <= 5)
            sumRange05 += dailyRange;
         if(i <= 10)
            sumRange10 += dailyRange;
        }

      int avgRange02 = sumRange02 / MathMin(20, 2);
      int avgRange05 = sumRange05 / MathMin(20, 5);
      int avgRange10 = sumRange10 / MathMin(20, 10);
      int avgRange20 = sumRange20 / 20;

      // Calculate the range for the previous day
      int prevDayRange = int((iHigh(NULL, PERIOD_D1, 1) - iLow(NULL, PERIOD_D1, 1)) / _Point);

      // Calculate the average day range as (Previous day range + 2 days range + 5 days range + 10 days range + 20 days range) / 5
      int avgDayRange = (prevDayRange + avgRange02 + avgRange05 + avgRange10 + avgRange20) / 5;

      // Structure time as today, beginning at 00:00:00 and ending at 23:59:xx.
      MqlDateTime today;
      datetime current_time = TimeCurrent();
      TimeToStruct(current_time, today);
      today.hour = 0;
      today.min = 0;
      today.sec = 0;
      datetime startday = StructToTime(today);
      datetime endday = startday + 24 * 60 * 59;

      // Condition if the anchor is set as 'Room_down'
      if(Anchor == Room_down)
        {
         // Find the highest price between startday and endday
         for(int shift = iBarShift(Symbol(), PERIOD_D1, endday, true); shift >= iBarShift(Symbol(), PERIOD_D1, startday, true); shift--)
           {
            double highPrice = iHigh(Symbol(), PERIOD_D1, shift);
            if(highPrice > highestPrice)
              {
               highestPrice = highPrice;
              }
           }

         // Calculate endPrice as lowestPrice
         double endPriceLow = highestPrice - avgDayRange * _Point;

         // Draw the rectangle. Start price from today's highest price
         if(ObjectCreate(0, "Today Price Zone", OBJ_RECTANGLE, 0, startday, highestPrice, endday, endPriceLow))
           {
            ObjectSetInteger(0, "Today Price Zone", OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, "Today Price Zone", OBJPROP_COLOR, RectColor);
            ObjectSetInteger(0, "Today Price Zone", OBJPROP_STYLE, LineStyle);
            ObjectSetInteger(0, "Today Price Zone", OBJPROP_WIDTH, LineWidth);

            // Set text in the rectangle
            ObjectSetString(0, "Today Price Zone", OBJPROP_TEXT, IntegerToString(avgDayRange, 1));
           }

         // Condition if the anchor is set as 'Room_up'
        }
      else
         if(Anchor == Room_up)
           {
            // Find the lowest price between startday and endday
            for(int shift = iBarShift(Symbol(), PERIOD_D1, endday, true); shift >= iBarShift(Symbol(), PERIOD_D1, startday, true); shift--)
              {
               double lowPrice = iLow(Symbol(), PERIOD_D1, shift);
               if(lowestPrice == 0 || lowPrice < lowestPrice)
                 {
                  lowestPrice = lowPrice;
                 }
              }

            // Calculate endPrice as highestPrice
            double endPriceHigh = lowestPrice + avgDayRange * _Point;

            // Draw the rectangle. Start price from today's lowest price
            if(ObjectCreate(0, "Today Price Zone", OBJ_RECTANGLE, 0, startday, lowestPrice, endday, endPriceHigh))
              {
               ObjectSetInteger(0, "Today Price Zone", OBJPROP_SELECTABLE, false);
               ObjectSetInteger(0, "Today Price Zone", OBJPROP_COLOR, RectColor);
               ObjectSetInteger(0, "Today Price Zone", OBJPROP_STYLE, LineStyle);
               ObjectSetInteger(0, "Today Price Zone", OBJPROP_WIDTH, LineWidth);

               // Set label text inside the rectangle. Value of "Avg ranges :"
               ObjectSetString(0, "Today Price Zone", OBJPROP_TEXT, IntegerToString(avgDayRange, 1));
              }
           }
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
// Delete the rectangle object on deinitialization
   ObjectDelete(0, rectangleObjectName);

// Delete the Average Days Range Info on deinitialization
   Comment("");
  }



//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   if(!showAverageDaysRangeInfo)  // Check if visibility is disabled
     {
      Comment(""); // Clear the chart comment
      return(rates_total);
     }

// Calculate the average ranges over the specified periods
   double sumRange02 = 0.0;
   double sumRange05 = 0.0;
   double sumRange10 = 0.0;
   double sumRange20 = 0.0;

   for(int i = 1; i <= 20; i++)
     {
      int dailyRange = int((iHigh(NULL, PERIOD_D1, i) - iLow(NULL, PERIOD_D1, i)) / _Point);
      sumRange20 += dailyRange;

      if(i <= 2)
         sumRange02 += dailyRange;
      if(i <= 5)
         sumRange05 += dailyRange;
      if(i <= 10)
         sumRange10 += dailyRange;
     }

   int avgRange02 = sumRange02 / MathMin(20, 2);
   int avgRange05 = sumRange05 / MathMin(20, 5);
   int avgRange10 = sumRange10 / MathMin(20, 10);
   int avgRange20 = sumRange20 / 20;

// Calculate the range for the previous day
   int prevDayRange = int((iHigh(NULL, PERIOD_D1, 1) - iLow(NULL, PERIOD_D1, 1)) / _Point);

// Calculate the average day range as (Previous day range + 2 days range + 5 days range + 10 days range + 20 days range) / 5
   int avgDayRange = (prevDayRange + avgRange02 + avgRange05 + avgRange10 + avgRange20) / 5;

// Call AverageDaysRangeInfo to display the information
   AverageDaysRangeInfo(avgDayRange,prevDayRange,avgRange02,avgRange05,avgRange10,avgRange20);

   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AverageDaysRangeInfo(double avgDayRange, double prevDayRange, double avgRange02, double avgRange05, double avgRange10, double avgRange20)
  {
// Display the Average ranges and the Average day range as simple comment text on the upper-left corner
   string text = "Avg ranges: " + int(avgDayRange) + "\n";
   text += "Prev01 day: " + int(prevDayRange) + "\n";
   text += "Avg 02 day: " + int(avgRange02) + "\n";
   text += "Avg 05 day: " + int(avgRange05) + "\n";
   text += "Avg 10 day: " + int(avgRange10) + "\n";
   text += "Avg 20 day: " + int(avgRange20) + "\n";

   Comment(text); // Display text in the upper-left corner of the chart
  }
//+------------------------------------------------------------------+
