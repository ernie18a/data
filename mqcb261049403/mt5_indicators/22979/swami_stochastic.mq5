//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Generic stochastic"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrWhite
#property indicator_width1  3
#property indicator_minimum 0
#property indicator_maximum 100

//
//---
//
input ENUM_APPLIED_PRICE    Price          = PRICE_CLOSE;   // Price
input int                   StartFrom      = 6;             // Start stochastic period
input int                   EndWith        = 48;            // End stochastic period
input int                   BarsToDraw     = 350;           // Bars to draw on chart
input int                   BarsWidth      = 4;             // "Dots" width
input string                UniqueID       = "SwamiStoch1"; // Unique ID for objects

double stochastic[],prices[],step,totalSteps;
int    window, _StartFrom, _EndWith;

//------------------------------------------------------------------
//
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
      SetIndexBuffer(0,stochastic,INDICATOR_DATA);
      SetIndexBuffer(1,prices    ,INDICATOR_CALCULATIONS);
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

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}
//
//---
//


double avgDen[][100];
double avgNum[][100];
double avgSto[][100];
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
   #define _checkArrayReserve 500
   static int _arrayResizedTo=0;
      if (_arrayResizedTo<rates_total)
      {
         int _res  = (rates_total+_checkArrayReserve)*3; 
             _res -= ArrayResize(avgDen,rates_total+_checkArrayReserve);
             _res -= ArrayResize(avgNum,rates_total+_checkArrayReserve);
             _res -= ArrayResize(avgSto,rates_total+_checkArrayReserve);
         if (_res) return(prev_calculated);
         _arrayResizedTo=rates_total+_checkArrayReserve;             
      }            
   
   //
   //---
   //

   window = ChartWindowFind(0,UniqueID);
   for (int i=(prev_calculated>0?prev_calculated-1:0); i<rates_total && !_StopFlag; i++) _setPrice(Price,prices[i],i); 
   for (int i=(prev_calculated>0?prev_calculated-1:0); i<rates_total && !_StopFlag; i++)
   {
       double _high   = prices[i];
       double _low    = prices[i];
            
       //
       //---
       //
   
       stochastic[i] = 0;
       for (int k=1; k<_EndWith && i>=k; k++)
       {
          _high = MathMax(_high,prices[i-k]);
          _low  = MathMin(_low ,prices[i-k]);
          if (k>=_StartFrom)
          {
              avgNum[i][k] = 0.5*avgNum[i-1][k]+0.5*(prices[i]-_low);
              avgDen[i][k] = 0.5*avgDen[i-1][k]+0.5*(_high    -_low);
              avgSto[i][k] = 0;
              if (avgDen[i][k] != 0) avgSto[i][k] = 0.2*(avgNum[i][k]/avgDen[i][k])+0.8*avgSto[i-1][k];
              if ((rates_total-i-1)<BarsToDraw)
              {
                 double colorR = 255;
                 double colorG = 255;
                 double colorB = 0;
                 if (avgSto[i][k] >= 0.5)
                       colorR = 255.0*(2.0-2.0*avgSto[i][k]);
                 else  colorG = 255.0     *2.0*avgSto[i][k];
                        
                 //
                 //---
                 //
                        
                 plot((string)k,time,(k-StartFrom)*step,(k-StartFrom+1)*step,i,i,rgb((int)colorR,(int)colorG,(int)colorB),BarsWidth);
              }                        
          }
          stochastic[i] += avgSto[i][k];
       }
       stochastic[i] /= totalSteps/100.0;
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
          ObjectSetInteger(0,name,OBJPROP_FILL,true);
          ObjectSetInteger(0,name,OBJPROP_STYLE,style);
          ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   }
   ObjectSetInteger(0,name,OBJPROP_COLOR,theColor);
   ObjectSetDouble(0,name,OBJPROP_PRICE,0,valueA);
   ObjectSetDouble(0,name,OBJPROP_PRICE,1,valueB);
}
color rgb(int red,int green,int blue)
{
   red   = MathMax(MathMin(red  ,255),0);
   green = MathMax(MathMin(green,255),0);
   blue  = MathMax(MathMin(blue ,255),0);
      return(color(red+(green<<8)+(blue<<16)));
}