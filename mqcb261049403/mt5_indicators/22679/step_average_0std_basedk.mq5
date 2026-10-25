//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Step averages"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Step average"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width1  2
//
//--- input parameters
//
input int                inpMaPeriod  = 14;          // Average period (<=1 for no average calculation)
input ENUM_MA_METHOD     inpMaType    = MODE_EMA;    // Average type
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price
input int                inpStdPeriod = 0;           // Standard deviation period (<=1 for same as average period)
input double             inpStepSize  = 20;          // Standard deviation step size (in % of standard deviation)
//
//--- buffers and global variables declarations
//
double val[],valc[],average[],std[],¹_stepSize;
int ¹_hma,¹_hstd,¹_maPeriod,¹_stdPeriod;
//------------------------------------------------------------------
// Custom indicator initialization function                         
//------------------------------------------------------------------
int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,val    ,INDICATOR_DATA);
         SetIndexBuffer(1,valc   ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,std    ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,average,INDICATOR_CALCULATIONS);
   //---
         ¹_stepSize  = inpStepSize/100.0;
         ¹_maPeriod  = MathMax(inpMaPeriod,1);
         ¹_stdPeriod = (inpStdPeriod>1 ? inpStdPeriod : ¹_maPeriod);
         ¹_hma       = iMA(_Symbol,0,¹_maPeriod,0,inpMaType,inpPrice);      if (!_checkHandle(¹_hma ,"Moving average"))     return(INIT_FAILED);
         ¹_hstd      = iStdDev(_Symbol,0,¹_stdPeriod,0,inpMaType,inpPrice); if (!_checkHandle(¹_hstd,"Standard deviation")) return(INIT_FAILED);
   //---
         IndicatorSetString(INDICATOR_SHORTNAME,"Step average ("+(string)inpMaPeriod+","+(string)inpStepSize+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function                              
//------------------------------------------------------------------
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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(¹_hma ,0,0,_copyCount,average) !=_copyCount) { Comment("Error copying average");            return(prev_calculated); }
         if (CopyBuffer(¹_hstd,0,0,_copyCount,std)     !=_copyCount) { Comment("Error copying standard deviation"); return(prev_calculated); }
   
   //
   //---
   //
   
   int i = (prev_calculated>0 ? prev_calculated-1 : 0); for (; i<rates_total && !_StopFlag; i++)
   {
      if (average[i]==EMPTY_VALUE) average[i] = close[i];
      if (std[i]    ==EMPTY_VALUE) std[i]     = _Point;
         val[i]  = iStepVal(average[i],¹_stepSize*std[i],i);
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0 ;
   }
   return (i);
}

//------------------------------------------------------------------
// custom functions                                                 
//------------------------------------------------------------------
//
//---
//
#define _stepValInstances 1
#define _stepValInstancesSize 1
#define _stepValRingSize 6
double  _stepValWork[_stepValRingSize][_stepValInstances*_stepValInstancesSize];
//
//---
//
double iStepVal(double value, double stepSize, int i, int instance=0)
{
   int _indC = (i)%_stepValRingSize;
   int _inst = instance*_stepValInstancesSize;
      #define _steps _inst

   //
   //---
   //
   
   if (i>0 && stepSize>0)
   {
      int    _indP = (i-1)%_stepValRingSize;
      double _diff = value-_stepValWork[_indP][_steps];
         _stepValWork[_indC][_steps] =  _stepValWork[_indP][_steps]+((_diff<stepSize && _diff>-stepSize) ? 0 : (int)(_diff/stepSize)*stepSize); 
   }
   else   _stepValWork[_indC][_steps] = (stepSize>0) ? MathRound(value/stepSize)*stepSize : value; 
   return(_stepValWork[_indC][_steps]);
   #undef  _steps

}
//
//---
//
bool _checkHandle(int _handle, string _description)
{
   static int  _handles[];
          int  _size   = ArraySize(_handles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_handles,_size+1); _handles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_handles[i]); ArrayResize(_handles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}    
//+------------------------------------------------------------------+
