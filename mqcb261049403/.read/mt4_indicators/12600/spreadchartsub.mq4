//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2

//---- indicator parameters

extern string SymbolSpread = "";  // Symbol B name to be compared at spreadchart
extern double SpreadFactor = 1.0;  // Spread = Symbol A price - Spreadfactor x Symbol B price
extern color ColorUp=Aqua;
extern color ColorDown=Tomato; 

//---- indicator buffers
double     BufferUp[];
double     BufferDown[];

int OnInit()
{
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,ColorUp);
   SetIndexBuffer(0,BufferUp);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2,ColorDown);
   SetIndexBuffer(1,BufferDown);
   
   IndicatorDigits(Digits+1);
   
   return (0);
}

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
      
      if (SymbolSpread=="" || SpreadFactor==0.0) return(0);
      
      int limit;
      int counted_bars=IndicatorCounted();
      //---- last counted bar will be recounted
      if(counted_bars>0) counted_bars--;
      limit=Bars-counted_bars;
      
      int i=0, iSymbolSpreadShift = 0;
      double dSpreadValue=0.0, dLastSpreadValue=0.0;
      double dSymbolPrice = 0.0, dSymbolSpreadPrice = 0.0;
      datetime dtSymbolBar = 0;
   
   
       for (i=limit-1;i>=0;i--)
      {
      
         dtSymbolBar = iTime(Symbol(),Period(),i);
      
         iSymbolSpreadShift = iBarShift(SymbolSpread,Period(),dtSymbolBar,true);
         
         if (iSymbolSpreadShift!=-1)
         {
         
            dSymbolPrice = iClose(Symbol(),Period(),i);
            dSymbolSpreadPrice = iClose(SymbolSpread,Period(),iSymbolSpreadShift);
      
            dSpreadValue = dSymbolPrice - dSymbolSpreadPrice * SpreadFactor;
            
            if (dSpreadValue*dLastSpreadValue!=0.0 && dSpreadValue>=dLastSpreadValue)
                          {  BufferUp[i] = dSpreadValue; if (dLastSpreadValue!=0.0) BufferUp[i+1] = dLastSpreadValue; } 
            if (dSpreadValue*dLastSpreadValue!=0.0 && dSpreadValue<dLastSpreadValue)
                          {  BufferDown[i] = dSpreadValue; if (dLastSpreadValue!=0.0) BufferDown[i+1] = dLastSpreadValue; }                           
         }
         
         dLastSpreadValue = dSpreadValue;
      
      }
   
  
      return(rates_total);
  }
//+------------------------------------------------------------------+
