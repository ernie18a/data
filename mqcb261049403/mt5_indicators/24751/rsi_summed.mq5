//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "RSI state"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2
#property indicator_label2  "RSI state line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_width2  0

//
//
//

input string             inpPeriods   = "14;15;16;17;18;19;20;21";  // RSI periods
input double             inpLevelUp   = 55;                         // High period
input double             inpLevelDown = 45;                         // Low period
input ENUM_APPLIED_PRICE inpRsiPrice  = PRICE_CLOSE;                // RSI price

//
//
//

double val[],vall[],valc[];
int    _rsiHandles[],_rsiHandlesSize=0;
string _rsisCalculated="";

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,vall,INDICATOR_DATA);
         
         string _temp[];
         ushort _sep = StringGetCharacter(";",0); 
         int    _count = StringSplit(inpPeriods,_sep,_temp);
            for (int i=0; i<_count; i++)
            {
               int period = (int)StringToInteger(_temp[i]);
                  if (period>0) 
                  {
                     int handle = iRSI(_Symbol,_Period,period,inpRsiPrice);
                        if (handle!=INVALID_HANDLE)
                        {
                           _rsiHandlesSize++; ArrayResize(_rsiHandles,_rsiHandlesSize); _rsiHandles[_rsiHandlesSize-1] = handle;
                           _rsisCalculated += (_rsisCalculated!="" ? "," : "")+(string)period;
                        }
                  }
            }         

   //
   //
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI summed ("+(string)_rsisCalculated+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _summ = 0,_tempRsi[1];
      for (int k=0; k<_rsiHandlesSize; k++)
           if (CopyBuffer(_rsiHandles[k],0,rates_total-i-1,1,_tempRsi)==1) 
               _summ += (_tempRsi[0]>inpLevelUp) ? 1 :  (_tempRsi[0]<inpLevelDown) ? -1 : 0;
           
      //
      //
      //
                 
      val[i]  = vall[i] = (_summ ==_rsiHandlesSize) ? 1 : (_summ ==-_rsiHandlesSize) ? -1 : 0;
      valc[i] = val[i]==1 ? 1 : val[i]==-1 ? 2 : 0;
   }
   return(i);
}