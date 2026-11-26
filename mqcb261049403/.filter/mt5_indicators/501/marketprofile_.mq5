//+------------------------------------------------------------------+
//|                                                MarketProfile.mq5 |
//|                                  Copyright © 2010, EarnForex.com |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "EarnForex.com"
#property link      "http://www.earnforex.com"
#property version   "1.01"
#property description "Displays the Market Profile indicator for the daily trading sessions."
#property description "Should be attached to M5, M15 or M30 timeframes."
#property description "M30 is recommended."
#property description ""
#property description "Designed for standard currency pairs. May work incorrectly with very exotic pairs, CFDs or commodities."
#property description "Be careful: it will delete all rectangle objects on the chart upon deinitialization."
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1

input datetime StartFromDate=__DATETIME__;
input bool     StartFromToday=true;
input int      DaysToCount= 2; // Number of days for which to count the Market Profile
input int      ColorScheme= 0; // 0 - Blue to Red, 1 - Red to Green, 2 - Green to Blue
input color    MedianColor    = White;
input color    ValueAreaColor = White;

int DigitsM;               // Amount of digits normalized for standard 4 and 2 digits after dot
datetime StartDate;        // Will hold either StartFromDate or Time[0]
double onetick;            // One normalized pip
int SecondsInPeriod;       // Will hold calculated amount of seconds in the selected timeframe period
bool FirstRunDone = false; // If true - OnCalculate() was already executed once
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,"MarketProfile");

//---- normalizing the digits to standard 4- and 2-digit quotes
   if(_Digits==5) DigitsM=4;
   else if(_Digits==3) DigitsM=2;
   else DigitsM=_Digits;

   if(_Period == PERIOD_M30) SecondsInPeriod = 1800;
   if(_Period == PERIOD_M15) SecondsInPeriod = 900;
   if(_Period == PERIOD_M5) SecondsInPeriod = 300;

   onetick=NormalizeDouble(1/(MathPow(10,DigitsM)),DigitsM);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Delete all rectangles (it takes too much time
//--- to delete exactly those rectangles that were created by this indicator)
   ObjectsDeleteAll(0,0,OBJ_RECTANGLE);
  }
//+------------------------------------------------------------------+
//| Custom Market Profile main iteration function                    |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &open[],
                const double &High[],
                const double &Low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if((_Period!=PERIOD_M30) && (_Period!=PERIOD_M15) && (_Period!=PERIOD_M5))
     {
      Print("TimeFrame should be set to M30, M15 or M5.");
      return(-1);
     }

   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Time,true);

   if(StartFromToday) StartDate=Time[0];
   else StartDate=StartFromDate;

//---- if we calculate profiles for the past days, no need to rerun it
   if((FirstRunDone) && (StartDate!=Time[0])) return(rates_total);
//---- get start and end bar numbers of the given date
   int dayend=FindDayEndByDate(Time,StartDate,rates_total);
   int daystart=FindDayStart(Time,dayend,rates_total);

   int DayToStart=0;
//---- if all days have already been counted, jump to the current one
   if(FirstRunDone) DayToStart=DaysToCount-1;
   else
     {
      //---- move back to the oldest day to count to start from it
      for(int i=1; i<DaysToCount; i++)
        {
         dayend=daystart+1;
         daystart=FindDayStart(Time,dayend,rates_total);
        }
     }
//---- we begin from the oldest day coming to today or to StartFromDate
   for(int i=DayToStart; i<DaysToCount; i++)
     {
      double DayMax=-1,DayMin=99999999999;

      //---- find the day's high and low to 
      for(int bar=daystart; bar>=dayend; bar--)
        {
         if(High[bar]> DayMax) DayMax = High[bar];
         if(Low[bar] < DayMin) DayMin = Low[bar];
        }
      DayMax = NormalizeDouble(DayMax, DigitsM);
      DayMin = NormalizeDouble(DayMin, DigitsM);

      int TPOperPrice[];
      //---- possible price levels if multiplied to integer
      int max=(int)(round(DayMax/onetick)+2); // + 2 because further we will be possibly checking array at DayMax + 1
      ArrayResize(TPOperPrice,max);
      ArrayInitialize(TPOperPrice,0);

      int MaxRange=0;                   // Maximum distance from day start to the drawn dot
      double PriceOfMaxRange=0;         // Level of the maximum range, required to draw Median
      double DistanceToCenter=99999999; // Closest distance to center for the Median

      int TotalTPO=0; // Total amount of dots (TPO's)

      //---- going through all possible quotes from daily High to daily Low
      for(double price=DayMax; price>=DayMin; price-=onetick)
        {
         int range=0; // Distance from first bar to the current bar

         //---- going through all bars of the day to see if the price was encoutered here
         for(int bar=daystart; bar>=dayend; bar--)
           {
            //---- price is encountered in the given bar
            if((price>=Low[bar]) && (price<=High[bar]))
              {
               //---- update maximum distance from day's start to the found bar (needed for Median)
               if((MaxRange<range) || (MaxRange==range) && (MathAbs(price -(DayMin+(DayMax-DayMin)/2))<DistanceToCenter))
                 {
                  MaxRange=range;
                  PriceOfMaxRange=price;
                  DistanceToCenter=MathAbs(price -(DayMin+(DayMax-DayMin)/2));
                 }
               //---- draws rectangle
               PutDot(price,Time[daystart],range,bar-daystart);
               //---- remember the number of encountered bars for this bars
               TPOperPrice[(int)(price/onetick)]++;
               range++;
               TotalTPO++;
              }
           }
        }

      //---- calculate amount of TPO's in the Value Area
      int ValueControlTPO=(int)((double)TotalTPO*0.7);
      //---- start with the TPO's of the Median
      int TPOcount=TPOperPrice[(int)(PriceOfMaxRange/onetick)];
      //---- go through the price levels above and below median adding the biggest 
      //---- to TPO count until the 70% of TPOs are inside the Value Area
      int up_offset=1;
      int down_offset=1;
      while(TPOcount<ValueControlTPO)
        {
         double abovePrice = PriceOfMaxRange + up_offset * onetick;
         double belowPrice = PriceOfMaxRange - down_offset * onetick;
         //---- if belowPrice is out of the day's range 
         //---- then we should add only abovePrice's TPO's, and vice versa
         if(((TPOperPrice[(int)(abovePrice/onetick)]>=TPOperPrice[(int)(belowPrice/onetick)]) || (belowPrice<DayMin)) && (abovePrice<=DayMax))
           {
            TPOcount+=TPOperPrice[(int)(abovePrice/onetick)];
            up_offset++;
           }
         else
           {
            TPOcount+=TPOperPrice[(int)(belowPrice/onetick)];
            down_offset++;
           }
        }
      string LastName=" "+TimeToString(Time[daystart],TIME_DATE);
      //---- delete old Median
      if(ObjectFind(0,"Median"+LastName)>=0) ObjectDelete(0,"Median "+LastName);
      //---- draw a new one
      ObjectCreate(0,"Median"+LastName,OBJ_RECTANGLE,0,Time[daystart+16],PriceOfMaxRange,Time[(int)(MathMax(daystart-MaxRange-5,0))],PriceOfMaxRange+onetick);
      ObjectSetInteger(0,"Median"+LastName,OBJPROP_COLOR,MedianColor);
      ObjectSetInteger(0,"Median"+LastName,OBJPROP_STYLE,STYLE_SOLID);

      //---- delete old Value Area
      if(ObjectFind(0,"Value Area"+LastName)>=0) ObjectDelete(0,"Value Area "+LastName);
      //---- draw a new one
      ObjectCreate(0,"Value Area"+LastName,OBJ_RECTANGLE,0,Time[daystart],PriceOfMaxRange+up_offset*onetick,Time[daystart]+(MaxRange+1)*SecondsInPeriod,PriceOfMaxRange-down_offset*onetick);
      ObjectSetInteger(0,"Value Area"+LastName,OBJPROP_COLOR,ValueAreaColor);
      ObjectSetInteger(0,"Value Area"+LastName,OBJPROP_FILL,false);

      //---- go to the newer day only if there is one or more left
      if(DaysToCount-i>1)
        {
         daystart=dayend-1;
         dayend=FindDayEndByDate(Time,Time[daystart],rates_total);
        }
     }
   FirstRunDone=true;

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Finds the day's starting bar number for any given bar number.    |
//| n - bar number for which to find starting bar.                   |
//+------------------------------------------------------------------+
int FindDayStart(const datetime &Time[],int n,int rates_total)
  {
   MqlDateTime dt1,dt2;
   int x=n;
   TimeToStruct(Time[n],dt1);
   TimeToStruct(Time[x],dt2);
   while((dt1.day_of_year==dt2.day_of_year) && (x<rates_total))
     {
      x++;
      TimeToStruct(Time[x],dt2);
     }
   return(x-1);
  }
//+------------------------------------------------------------------+
//| Finds the day's end bar by the day's date.                       |
//+------------------------------------------------------------------+
int FindDayEndByDate(const datetime &Time[],datetime date,int rates_total)
  {
   MqlDateTime dt1,dt2;
   int x=0;
   TimeToStruct(date,dt1);
   TimeToStruct(Time[x],dt2);
   while((dt1.day_of_year<dt2.day_of_year) && (x<rates_total))
     {
      x++;
      TimeToStruct(Time[x],dt2);
     }
   return(x);
  }
//+------------------------------------------------------------------+
//| Puts a dot (rectangle) at a given position and color.            |
//| Price and time are coordinates.                                  |
//| Range is for the second coordinate.                              |
//| Bar is to determine the color of the dot.                        |
//+------------------------------------------------------------------+
void PutDot(double price,datetime time,int range,int bar)
  {
   string LastName=" "+IntegerToString(time+range*SecondsInPeriod)+" "+DoubleToString(price);
   if(ObjectFind(0,"MP"+LastName)>=0) return;

   ObjectCreate(0,"MP"+LastName,OBJ_RECTANGLE,0,time+range*SecondsInPeriod,price,time+(range+1)*SecondsInPeriod,price+onetick);

//---- color switching depending on the distance of the bar from the day's beginning
   int colour=0,offset1=0,offset2=0;
   switch(ColorScheme)
     {
      case 0:
         colour=DarkBlue;
         offset1 = 0x020000;
         offset2 = 0x000002;
         break;
      case 1:
         colour=DarkRed;
         offset1 = 0x000002;
         offset2 = 0x000200;
         break;
      case 2:
         colour=DarkGreen;
         offset1 = 0x000200;
         offset2 = 0x020000;
         break;
     }
   if(_Period==PERIOD_M30) colour+=bar*offset1;
   else if(_Period==PERIOD_M15) colour+=bar *(offset1/2);
   else colour+=(bar/3) *(offset1/2);
   if(_Period==PERIOD_M30) colour-=bar*offset2;
   else if(_Period==PERIOD_M15) colour-=bar *(offset2/2);
   else colour-=(bar/3) *(offset2/2);

   ObjectSetInteger(0,"MP"+LastName,OBJPROP_COLOR,colour);
//---- fills rectangle
   ObjectSetInteger(0,"MP"+LastName,OBJPROP_FILL,true);
  }
//+------------------------------------------------------------------+
