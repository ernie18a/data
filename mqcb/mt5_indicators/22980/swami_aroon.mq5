//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "Generic Aroon"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrWhite
#property indicator_width1  3
#property indicator_minimum 0
#property indicator_maximum 100

//
//---
//
input int                   StartFrom      = 6;             // Start Aroon period
input int                   EndWith        = 48;            // End  Aroon period
input int                   BarsToDraw     = 350;           // Bars to draw on chart
input int                   BarsWidth      = 4;             // "Dots" width
input string                UniqueID       = "SwamiArron1"; // Unique ID for objects

double aroon[],step,totalSteps;
int    window, _StartFrom, _EndWith;

//------------------------------------------------------------------
//
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
      SetIndexBuffer(0,aroon,INDICATOR_DATA);
   //
   //---
   //
         
      _StartFrom  = MathMax(StartFrom, 6);
      _EndWith    = MathMin(EndWith  ,99);
      totalSteps = _EndWith-_StartFrom+1.0;
      step       = 100.0/(totalSteps-1);
   IndicatorSetString(INDICATOR_SHORTNAME,UniqueID);
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { ObjectsDeleteAll(0,UniqueID+":");  return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
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
   window = ChartWindowFind(0,UniqueID);
   for (int i=(prev_calculated>0?prev_calculated-1:0); i<rates_total && !_StopFlag; i++)
   {
            double _high = high[i]; double _highest = _high;
            double _low  = low [i]; double _lowest  = _low;
            
            //
            //
            //
            //
            //
   
            aroon[i] = 0; double AroonOs=0;  
            for (int k=1; k<_EndWith && i>=k; k++)
            {
               if (high[i-k] > _high) { _highest = k; _high = high[i-k]; }
               if (low [i-k] < _low ) { _lowest  = k; _low  = low[i-k];  }
               if ((rates_total-i-1)<BarsToDraw)
               {
                  double AroonUp = (k-_highest+1.0)/(k*1.0);
                  double AroonDn = (k-_lowest +1.0)/(k*1.0);
                         AroonOs = (AroonUp-AroonDn)/2.0;
                           plot((string)k,time,(k-_StartFrom)*step,(k-_StartFrom+1)*step,i,i,gradientColor(int(AroonOs*50.0+25.0),50,clrRed,clrLimeGreen),BarsWidth);
               }
               aroon[i] += AroonOs;
            }
            aroon[i] = MathMin(MathMax(100.0*aroon[i]/totalSteps+50.0,0),100);
   }
   return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------

void plot(string namex, const datetime& time[], double valueA, double valueB, int shiftA, int shiftB, color theColor, int width=0,int style=STYLE_SOLID)
{
   string name = UniqueID+":"+namex+(string)time[shiftA];
   //
   //
   //
   if (ObjectFind(0,name) == -1) 
   {
       ObjectCreate(0,name,OBJ_TREND,window,time[shiftA],valueA,time[shiftB],valueB);
          ObjectSetInteger(0,name,OBJPROP_RAY,false);
          ObjectSetInteger(0,name,OBJPROP_BACK,true);
          ObjectSetInteger(0,name,OBJPROP_STYLE,style);
          ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   }
   ObjectSetInteger(0,name,OBJPROP_COLOR,theColor);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,valueA);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,valueB);
}
color gradientColor(int _step, int _totalSteps, color from, color to)
{
   color newBlue  = getColor(_step,_totalSteps,(from & 0XFF0000)>>16,(to & 0XFF0000)>>16)<<16;
   color newGreen = getColor(_step,_totalSteps,(from & 0X00FF00)>> 8,(to & 0X00FF00)>> 8) <<8;
   color newRed   = getColor(_step,_totalSteps,(from & 0X0000FF)    ,(to & 0X0000FF)    )    ;
   return(newBlue+newGreen+newRed);
}
color getColor(int stepNo, int _totalSteps, color from, color to)
{
   double _step = (from-to)/(_totalSteps-1.0);
   return(color(from-_step*stepNo));
}