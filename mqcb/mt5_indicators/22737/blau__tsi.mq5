//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "True Strength Index (William Blau)"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "TSI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_width1  2

//
//--- input parameters
//

input int                inpPeriod1    = 25;           // True strength index momentum smoothing period 
input int                inpPeriod2    = 13;           // True strength index smoothing period 2
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE;  // Price

//
//--- buffers and global variables declarations
//

double val[],valc[],prices[];
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,val   ,INDICATOR_DATA);
         SetIndexBuffer(1,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
   //---
   IndicatorSetString(INDICATOR_SHORTNAME,"True strength index ("+(string)inpPeriod1+","+(string)inpPeriod2+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_price,_where,_from) { \
   switch(_price) \
   { \
      case PRICE_CLOSE:    _where = close[_from];                                           break; \
      case PRICE_OPEN:     _where = open[_from];                                            break; \
      case PRICE_HIGH:     _where = high[_from];                                            break; \
      case PRICE_LOW:      _where = low[_from];                                             break; \
      case PRICE_MEDIAN:   _where = (high[_from]+low[_from])/2.0;                           break; \
      case PRICE_TYPICAL:  _where = (high[_from]+low[_from]+close[_from])/3.0;              break; \
      case PRICE_WEIGHTED: _where = (high[_from]+low[_from]+close[_from]+close[_from])/4.0; break; \
      default : _where = 0; \
   }}

//
//---
//

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
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);
         double _momentum = (i>0) ? prices[i]-prices[i-1] : 0;
         double _momentua = (_momentum>0) ? _momentum :-_momentum;
         double avg       = iEma(iEma(_momentum,inpPeriod1,i,0),inpPeriod2,i,1);
         double ava       = iEma(iEma(_momentua,inpPeriod1,i,2),inpPeriod2,i,3);
         
         val[i]  = (ava!=0) ? 100.0*avg/ava : 0;
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
   }
   return (i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

#define _emaInstances 4
#define _emaRingSize  6
double workEma[_emaRingSize][_emaInstances];

double iEma(double price, double period, int i, int _inst=0)
{
   int _indC = (i  )%_emaRingSize;
   int _indP = (i-1)%_emaRingSize;

   if (i>0 && period>1)      
          workEma[_indC][_inst] = workEma[_indP][_inst]+(2.0/(1.0+period))*(price-workEma[_indP][_inst]);
   else   workEma[_indC][_inst] = price;
   return(workEma[_indC][_inst]);
} 
//------------------------------------------------------------------
