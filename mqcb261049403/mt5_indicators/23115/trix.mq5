//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "TRiX"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrDodgerBlue,clrSandyBrown
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//---
//

enum enColorOn
{
   on_slope, // Change color on slope change
   on_zero   // Change color on zero cross
};
input int                inpPeriod  = 14;          // Period
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price
input enColorOn          inpColorOn = on_slope;    // Color change mode 

double val[],valc[],ª_alpha;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);

   //
   //---
   //
   
      ª_alpha = 2.0/(1.0+inpPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,"TRiX ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
// Custom indicator iteration function
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
double _workTRiX[][3];

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
   static int _workTrRiXSize = 0;
          if (_workTrRiXSize<rates_total)
          {
              _workTrRiXSize = ArrayResize(_workTRiX,rates_total+500);
              if (_workTrRiXSize<rates_total) return(prev_calculated);
          }
   
   //
   //---
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      _workTRiX[i][0] = (i>0) ? _workTRiX[i-1][0]+ª_alpha*(_price         -_workTRiX[i-1][0]) : _price;
      _workTRiX[i][1] = (i>0) ? _workTRiX[i-1][1]+ª_alpha*(_workTRiX[i][0]-_workTRiX[i-1][1]) : _price;
      _workTRiX[i][2] = (i>0) ? _workTRiX[i-1][2]+ª_alpha*(_workTRiX[i][1]-_workTRiX[i-1][2]) : _price;
         val[i]  = (i>0 && _workTRiX[i-1][2]>0) ? (_workTRiX[i][2]-_workTRiX[i-1][2])/_workTRiX[i-1][2] : 0;
         if (inpColorOn==on_slope)
               valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
         else  valc[i] = (val[i]>0) ? 1 : (val[i]<0) ? 2 : 0;
   }      
   return(i);
}