//+------------------------------------------------------------------+
//| Class CalcFrac.                                                  |
//| Purpose: Class calculate fractals by array values                |
//+------------------------------------------------------------------+
class CalcFrac
  {
public:
   int               before_period;
   int               after_period;
   double            values[];

   bool              is_lower_fr(int bar);
   bool              is_upper_fr(int bar);

protected:
   int CountMax() {return((int)MathMax(before_period,after_period));};
  };
//+------------------------------------------------------------------+
//| calculate lower fractals                                         |
//+------------------------------------------------------------------+
bool CalcFrac :: is_lower_fr(int bar)
  {
   for(int i=1;i<=CountMax();i++)
     {
      if(i<=after_period && values[bar]>values[bar+i]) return(false); //
      if(i<=before_period && values[bar]>values[bar-i]) return(false);
     }

   return(true);
  }
//+------------------------------------------------------------------+
//| calculate upper fractals                                         |
//+------------------------------------------------------------------+
bool CalcFrac :: is_upper_fr(int bar)
  {
   for(int i=1;i<=CountMax();i++)
     {
      if(i<=after_period && values[bar]<values[bar+i]) return(false); //
      if(i<=before_period && values[bar]<values[bar-i]) return(false);
     }

   return(true);
  }
//+------------------------------------------------------------------+
