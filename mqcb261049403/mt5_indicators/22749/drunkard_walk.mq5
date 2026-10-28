//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Drunkard`s walk"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   4
#property indicator_label1  "filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'230,243,230',C'243,230,230'
#property indicator_label2  "Line up"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_style2  STYLE_DOT
#property indicator_color2  clrGreen,clrRed
#property indicator_label3  "Line down"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrGreen,clrRed
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Trend line"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrGreen,clrRed
#property indicator_width4  2

//
//--- input parameters
//

input int inpPeriod  = 40;  // Drunkard walk period

//
//--- buffers declarations
//

double trend[],trendc[],valu[],valuc[],vald[],valdc[],fillu[],filld[];
double ª_alpha; 
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,fillu ,INDICATOR_DATA);
         SetIndexBuffer(1,filld ,INDICATOR_DATA);
         SetIndexBuffer(2,valu  ,INDICATOR_DATA);
         SetIndexBuffer(3,valuc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,vald  ,INDICATOR_DATA);
         SetIndexBuffer(5,valdc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(6,trend ,INDICATOR_DATA);
         SetIndexBuffer(7,trendc,INDICATOR_COLOR_INDEX);

   //---
         ª_alpha = 2.0/(1.0+inpPeriod);
   //--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Drunkard\'s walk ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}

//
//---
//

void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _checkArrayReserve 500
#define _checkArraySize(_arrayName,_ratesTotal)                            \
     static bool _arrayError     = false;                                  \
   { static int  _arrayResizedTo = 0;                                      \
             if (_arrayResizedTo<_ratesTotal)                              \
             {                                                             \
                  int _res = (_ratesTotal+_checkArrayReserve);             \
                      _res -= ArrayResize(_arrayName,_res);                \
                  if (_res)                                                \
                        _arrayError     = true;                            \
                  else {_arrayResizedTo = _ratesTotal+_checkArrayReserve;} \
              }                                                            \
   }

//
//---
//

double _dwWork[][5];
#define _tr 0

//
//---
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
   _checkArraySize(_dwWork,rates_total); if (_arrayError) return(prev_calculated);
   
   //
   //---
   //
   
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      int start = (i>inpPeriod) ? i-inpPeriod+1 : 0;
         int    longMaxBar = ArrayMaximum(high,start,inpPeriod);
         int    longMinBar = ArrayMinimum(low ,start,inpPeriod);
         int    longDnRun  = i-longMaxBar;
         int    longUpRun  = i-longMinBar;
         double longHigh   = high[longMaxBar];
         double longLow    = low[longMinBar];

         //
         //---
         //
          
         _dwWork[i][_tr] = (i>0) ? (high[i]>close[i-1] ? high[i]:close[i-1]) - (low[i]<close[i-1] ? low[i]:close[i-1]) : high[i]-low[i];
         _dwWork[i][1]   = (i>1) ? _dwWork[i-2][1]+1 : 0;
         _dwWork[i][2]   = (i>1) ? _dwWork[i-1][2]   : 0;
         _dwWork[i][3]   = (i>1) ? _dwWork[i-1][3]   : 0;
         _dwWork[i][4]   = (i>1) ? _dwWork[i-1][4]   : 0;
            if (_dwWork[i][3]==0) 
            {
               _dwWork[i][1] = inpPeriod;
               _dwWork[i][2] = inpPeriod;
               _dwWork[i][3] = inpPeriod;
            }
            if (i>1 && _dwWork[i-1][4]!=_dwWork[i-2][4])
            {
               _dwWork[i][1] = 1;
               _dwWork[i][2] = _dwWork[i-1][1];
               _dwWork[i][3] = _dwWork[i-1][3]+ª_alpha*(_dwWork[i-1][2]-_dwWork[i-1][3]);
            }
                     
         //
         //---
         //
         
         valu[i]  = (i>0) ? valu[i-1] : 0;
         vald[i]  = (i>0) ? vald[i-1] : 0;
         trend[i] = (i>0) ? trend[i-1] : 0;
            if (longDnRun > 0 && longUpRun > 0)
            {
               double atr   = _dwWork[i][_tr]; int k=1; for (; k<_dwWork[i][3] && (i-k)>=0; k++) atr+=_dwWork[i-k][_tr]; atr/=(double)k; 
               double denom = (atr > 0) ? MathSqrt(_dwWork[i][3])*atr : MathSqrt(_dwWork[i][3]);
                  valu[i] = (high[i]-longLow) /denom;
                  vald[i] = (longHigh -low[i])/denom;
            }
            fillu[i] = valu[i];
            filld[i] = vald[i];
            if (valu[i]>vald[i]) { _dwWork[i][4] =  1; valuc[i] = 0; valdc[i] = 0; trend[i] = valu[i]; trendc[i] = 0; }
            if (valu[i]<vald[i]) { _dwWork[i][4] = -1; valuc[i] = 1; valdc[i] = 1; trend[i] = vald[i]; trendc[i] = 1;  }
            
   }
   return (i);
}
  
//------------------------------------------------------------------
//    custom functions
//------------------------------------------------------------------
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
