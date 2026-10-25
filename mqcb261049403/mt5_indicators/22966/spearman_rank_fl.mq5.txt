//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Spearman rank with floating levels"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   4
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_DOT
#property indicator_label3  "middle level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "value"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width4  2

//
//---
//

input int                inpSpearmanRank = 32;          // Spearman rank
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price
input int                inpFlPeriod     = 32;          // Floating levels period
input double             inpFlLevelUp    = 80.0;        // Up level %
input double             inpFlLevelDown  = 20.0;        // Down level %

//
//---
//

double  val[],valc[],levelUp[],levelDn[],levelMi[],prices[],data[],ª_coeff;

//------------------------------------------------------------------
// Custom indicator initialization function                         
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,levelUp,INDICATOR_DATA);
         SetIndexBuffer(1,levelDn,INDICATOR_DATA);
         SetIndexBuffer(2,levelMi,INDICATOR_DATA);
         SetIndexBuffer(3,val    ,INDICATOR_DATA);
         SetIndexBuffer(4,valc   ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,prices ,INDICATOR_CALCULATIONS);
   //
   //---
   //
         ArrayResize(data,inpSpearmanRank);
         ª_coeff = inpSpearmanRank*(inpSpearmanRank*inpSpearmanRank-1.0);
   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Spearman rank ("+(string)inpSpearmanRank+","+(string)inpFlLevelDown+","+(string)inpFlLevelUp+")");
   return(0);
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
   int i = (prev_calculated>0 ? prev_calculated-1 : 0); for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);
         int    _start = i-inpSpearmanRank+1; if (_start<0) _start=0; ArrayCopy(data,prices,0,_start,inpSpearmanRank);
         double _total = 0;
            for (int k=0; k<inpSpearmanRank; k++) { int min = ArrayMinimum(data); _total += (min-k)*(min-k); data[min] = DBL_MAX; }

         //
         //---
         //
                  
         val[i]   = 1.0-6.0*_total/ª_coeff;
         _start = i-inpFlPeriod+1; if (_start<0) _start=0;
            double _min   = val[ArrayMinimum(val,_start,inpFlPeriod)];
            double _max   = val[ArrayMaximum(val,_start,inpFlPeriod)];
            double _range = (_max-_min)/100.0;
            levelUp[i] = _min+inpFlLevelUp  *_range;
            levelDn[i] = _min+inpFlLevelDown*_range;
            levelMi[i] = _min+50.0          *_range;
         valc[i] = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
   }
   return(i);
}