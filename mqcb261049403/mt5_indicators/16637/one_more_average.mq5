//+------------------------------------------------------------------+
//|                                             One more average.mq5 |
//+------------------------------------------------------------------+
#property copyright "Mladen"
#property link      "http://www.forex-tsd.com"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1

//
//
//
//
//

#property indicator_label1  "One more average"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  LimeGreen,DarkOrange,GreenYellow,Gold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//
//
//
//

input int                 inpLength       = 26;             // Averaging period
input ENUM_APPLIED_PRICE  inpPrice        = PRICE_CLOSE;    // Applied price
input float               inpSpeed        = 1.0;            // Speed
input bool                inpAdaptive     = true;           // Should it be adaptive?
input string              _1              = "";             // Multi time frame settings
input ENUM_TIMEFRAMES     inpTimeFrame    = PERIOD_CURRENT; // Time frame
input bool                inpInterpolated = true;           // Interpolated multi time frame?
input string              _2              = "";             // .
input int                 inpCalculating  = 0;              // Reserved for internal use

//
//
//
//
//

double OMABuffer[];
double OMACalculated[];
double clrBuffer[];
double prcBuffer[];
double stored[][7];

//
//
//
//
//

ENUM_TIMEFRAMES iTimeFrame;
bool   calculating;
int    priceHandle;
int    omaHandle;
int    Length;
double Speed;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define __doCalculate 155522

int OnInit()
{
   SetIndexBuffer(0,OMABuffer,INDICATOR_DATA);         ArraySetAsSeries(OMABuffer,true);
   SetIndexBuffer(1,clrBuffer,INDICATOR_COLOR_INDEX);  ArraySetAsSeries(clrBuffer,true);
   SetIndexBuffer(2,prcBuffer,INDICATOR_CALCULATIONS); ArraySetAsSeries(prcBuffer,true);

   //
   //
   //
   //
   //

   Length = (inpLength >   0) ? inpLength : 1;
   Speed  = (inpSpeed  >-1.5) ? inpSpeed : -1.5;
   
      //
      //
      //
      //
      //
   
      if (!(calculating = (inpCalculating==__doCalculate)))
      {      
         iTimeFrame = (inpTimeFrame!=PERIOD_CURRENT) ? ((inpTimeFrame>Period()) ? inpTimeFrame : Period()) : Period();
         omaHandle  = iCustom(NULL,iTimeFrame,getIndicatorName(),Length,inpPrice,Speed,inpAdaptive,"",iTimeFrame,inpInterpolated,"",__doCalculate);
      }
      else  priceHandle = iMA(NULL,inpTimeFrame,1,0,MODE_SMA,inpPrice);
      
   //
   //
   //
   //
   //
         
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   //
   //
   //
   //
   //
   
      if (!ArrayGetAsSeries(time)) ArraySetAsSeries(time,true);

         int limit = rates_total-prev_calculated;
            if (prev_calculated >  0) limit ++;
            if (prev_calculated == 0)
            {
               int last;
               if (inpAdaptive)
                     last = (int)round(Length*2.5)+1;
               else  last =            Length;
               
               //
               //
               //
               //
               //
                     
               limit -= last+1;
               for (int i=0; i<=last; i++) 
               {
                  clrBuffer[rates_total-i-1] = 0;
                  OMABuffer[rates_total-i-1] = 0;
               }
            }

   //
   //
   //
   //
   //
   
   if (!calculating)
   {
      datetime timeArray[]; ArraySetAsSeries(timeArray,true);
         
      //
      //
      //
      //
      //
         
         int copiedDates;
         for (int i=0; i<5;i++)
            if((copiedDates = CopyTime(Symbol(),iTimeFrame,time[rates_total-1],time[0],timeArray))>0) break;
            if (copiedDates <= 0)
            {
               Print("not all times copied. Will try on next tick");
               return(rates_total);
            }
            if (!checkCalculated(omaHandle,copiedDates   ,"averages")) return(rates_total);
            if (!doCopy(omaHandle,prcBuffer,0,copiedDates,"averages")) return(rates_total);
                              
      //
      //
      //
      //
      //

         int minBars = (int)round(periodToMinutes(iTimeFrame)/periodToMinutes(Period()))+1;
               limit = (limit>minBars) ? limit : minBars;

               //
               //
               //
               //
               //
               
               for (int i=limit; i>=0; i--)
               {
                  int      d = dateArrayBsearch(timeArray,time[i],copiedDates);
                  datetime t = timeArray[d];
                        OMABuffer[i] = prcBuffer[d];
                        clrBuffer[i] = clrBuffer[i+1];

                        if (OMABuffer[i]>OMABuffer[i+1]) clrBuffer[i] = 0;
                        if (OMABuffer[i]<OMABuffer[i+1]) clrBuffer[i] = 1;
                        if (iTimeFrame > Period() && d==0)
                        {
                           if (OMABuffer[i]>OMABuffer[i+1]) clrBuffer[i] = 2;
                           if (OMABuffer[i]<OMABuffer[i+1]) clrBuffer[i] = 3;
                        }

                  //
                  //
                  //
                  //
                  //

                  if (inpInterpolated)
                  {
                     if(iTimeFrame <= Period() || (i>0 && d==dateArrayBsearch(timeArray,time[i-1],copiedDates))) continue;
                  
                     //
                     //
                     //
                     //
                     //
                  
                     int n = 1;
  		                  for(; i+n < Bars(Symbol(),0) && time[i+n] >= t; n++) continue;	
         		            double factor = 1.0 / n;
                           for(int k = 1; k < n; k++)
			                     OMABuffer[i+k] = k*factor*OMABuffer[i+n] + (1.0-k*factor)*OMABuffer[i];
                  }			               
               }

      //
      //
      //
      //
      //
      
      return(rates_total);
   }
   
   //
   //
   //
   //
   //
         
   if (ArrayRange(stored,0) != rates_total) ArrayResize(stored,rates_total);
   if (!checkCalculated(priceHandle,rates_total,"prices")) return(prev_calculated);
   if (!doCopy(priceHandle,prcBuffer,0,limit   ,"prices")) return(prev_calculated);

      if (prev_calculated==0) ArrayInitialize(stored,0);
      for(int i=limit, r=rates_total-limit-1; i>=0; i--,r++)
               OMABuffer[i] = iAverage(prcBuffer[i],Length,Speed,inpAdaptive,r);
      
   return(rates_total);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define E1  0
#define E2  1
#define E3  2
#define E4  3
#define E5  4
#define E6  5
#define res 6

//
//
//
//
//

double iAverage(double price, double averagePeriod, double speed, bool adaptive, int r)
{
   double e1=stored[r-1][E1];  double e2=stored[r-1][E2];
   double e3=stored[r-1][E3];  double e4=stored[r-1][E4];
   double e5=stored[r-1][E5];  double e6=stored[r-1][E6];

   //
   //
   //
   //
   //

      if (adaptive && (averagePeriod > 1))
      {
         double minPeriod = averagePeriod/2.0;
         double maxPeriod = minPeriod*5.0;
         int    endPeriod = (int)MathCeil(maxPeriod);
         double signal    = MathAbs((price-stored[r-endPeriod][res]));
         double noise     = 0.00000000001;

            for(int k=1; k<endPeriod; k++) noise=noise+MathAbs(price-stored[r-k][res]);

         if (noise!=0) averagePeriod = ((signal/noise)*(maxPeriod-minPeriod))+minPeriod;
      }
      
      //
      //
      //
      //
      //
      
      double alpha = (2.0+speed)/(1.0+speed+averagePeriod);

      e1 = e1 + alpha*(price-e1); e2 = e2 + alpha*(e1-e2); double v1 = 1.5 * e1 - 0.5 * e2;
      e3 = e3 + alpha*(v1   -e3); e4 = e4 + alpha*(e3-e4); double v2 = 1.5 * e3 - 0.5 * e4;
      e5 = e5 + alpha*(v2   -e5); e6 = e6 + alpha*(e5-e6); double v3 = 1.5 * e5 - 0.5 * e6;

   //
   //
   //
   //
   //

   stored[r][E1]  = e1;  stored[r][E2] = e2;
   stored[r][E3]  = e3;  stored[r][E4] = e4;
   stored[r][E5]  = e5;  stored[r][E6] = e6;
   stored[r][res] = price;
   return(v3);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int dateArrayBsearch(datetime& dates[], datetime toFind, int total)
{
   int mid   = 0;
   int first = 0;
   int last  = total-1;
   
   while (last >= first)
   {
      mid = (first + last) >> 1;
      if (toFind == dates[mid] || (mid > 0 && (toFind > dates[mid]) && (toFind < dates[mid-1]))) break;
      if (toFind >  dates[mid])
            last  = mid - 1;
      else  first = mid + 1;
   }
   return (mid);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int periodToMinutes(int period)
{
   int i;
   static int _per[]={1,2,3,4,5,6,10,12,15,20,30,0x4001,0x4002,0x4003,0x4004,0x4006,0x4008,0x400c,0x4018,0x8001,0xc001};
   static int _min[]={1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200};

   if (period==PERIOD_CURRENT) 
       period = Period();   
            for(i=0;i<20;i++) if(period==_per[i]) break;
   return(_min[i]);   
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

bool checkCalculated(int bufferHandle, int total, string checkDescription)
{
   int calculated=BarsCalculated(bufferHandle);
   if (calculated<total)
   {
      Print("Not all data of "+checkDescription+" calculated (",(string)(total-calculated)," un-calculated bars )");
      return(false);
   }
   return(true);
}

//
//
//
//
//

bool doCopy(const int bufferHandle, double& buffer[], const int buffNum, const int copyCount, string copyDescription)
{
   if(CopyBuffer(bufferHandle,buffNum,0,copyCount,buffer)<=0)
   {
      Print("Getting "+copyDescription+" failed! Error",GetLastError());
      return(false);
   }
   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

string getIndicatorName()
{
   string progPath    = MQL5InfoString(MQL5_PROGRAM_PATH);
   string toFind      = "MQL5\\Indicators\\";
   int    startLength = StringFind(progPath,toFind)+StringLen(toFind);
         
         string indicatorName = StringSubstr(progPath,startLength);
                indicatorName = StringSubstr(indicatorName,0,StringLen(indicatorName)-4);
   return(indicatorName);
}