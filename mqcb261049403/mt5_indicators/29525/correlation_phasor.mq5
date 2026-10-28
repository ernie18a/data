//------------------------------------------------------------------
#property copyright   "copyright© mladen"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  4
#property indicator_plots    2
#property indicator_label1   "Trend"
#property indicator_type1    DRAW_FILLING
#property indicator_color1   clrLightGreen,clrOrange
#property indicator_label2   "Phasor"
#property indicator_type2    DRAW_COLOR_LINE
#property indicator_color2   clrMediumSeaGreen,clrOrangeRed
#property indicator_width2   2

//
//
//

input int  inpPeriod = 35; // Period
double val[],valc[],fillu[],filld[],tcos[],tsin[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,fillu,INDICATOR_DATA); 
   SetIndexBuffer(1,filld,INDICATOR_DATA); 
   SetIndexBuffer(2,val  ,INDICATOR_DATA); 
   SetIndexBuffer(3,valc ,INDICATOR_COLOR_INDEX); 
      
      //
      //
      //
      
      ArrayResize(tcos,inpPeriod); for (int i=0; i<inpPeriod; i++) tcos[i] =  MathCos(i*2*M_PI/(double)inpPeriod); 
      ArrayResize(tsin,inpPeriod); for (int i=0; i<inpPeriod; i++) tsin[i] = -MathSin(i*2*M_PI/(double)inpPeriod); 
      IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Correlation phasor (%i)",inpPeriod));
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {  return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int limit = prev_calculated-1; if (limit<0) limit = 0;

   //
   //
   //
   
      for (int i=limit; i<rates_total; i++)
      {
         val[i] = filld[i] = 0;
         double real = 0;
         double imag = 0;
         double cSx  = 0, sSx  = 0; 
         double cSy  = 0, sSy  = 0; 
         double cSxx = 0, sSxx = 0; 
         double cSxy = 0, sSxy = 0; 
         double cSyy = 0, sSyy = 0; 
         for (int k=0; k<inpPeriod && i>=k; k++)
         {
	         double  X = close[i-k] ; 
	         double cY = tcos[k]; 
	         double sY = tsin[k]; 
	            cSx  = cSx  +  X ; 
	            cSy  = cSy  + cY ; 
	            cSxx = cSxx +  X *  X; 
	            cSxy = cSxy +  X * cY; 
	            cSyy = cSyy + cY * cY; 
	            sSx  = sSx  +  X ; 
	            sSy  = sSy  + cY ; 
	            sSxx = sSxx +  X *  X; 
	            sSxy = sSxy +  X * sY; 
	            sSyy = sSyy + sY * sY; 
         }
         if ((inpPeriod*cSxx-cSx*cSx > 0 ) && (inpPeriod*cSyy-cSy*cSy > 0 )) real = (inpPeriod*cSxy-cSx*cSy) / MathSqrt((inpPeriod*cSxx-cSx*cSx) * (inpPeriod*cSyy-cSy*cSy)); 
         if ((inpPeriod*sSxx-sSx*sSx > 0 ) && (inpPeriod*sSyy-sSy*sSy > 0 )) imag = (inpPeriod*sSxy-sSx*sSy) / MathSqrt((inpPeriod*sSxx-sSx*sSx) * (inpPeriod*sSyy-sSy*sSy)); 
         
         if (imag!=0) val[i] = 90.0 + 90.0*MathArctan(real/imag) ; 
         if (imag >0) val[i] = val[i] - 180.0; 
         if (i>0 && (val[i-1]-val[i]<270 && val[i]<val[i-1])) val[i] = val[i-1];
         
         fillu[i] = val[i];
         valc[i] = val[i]>0 ? 0 : 1;
   }      
   return(rates_total);
}
