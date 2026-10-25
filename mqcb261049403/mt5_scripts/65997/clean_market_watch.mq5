//+------------------------------------------------------------------+
//|                                          CleanMarketWatch.mq5    |
//|                            Copyright 2025, Hieronymos Starch     |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Hieronymos- Starch - +263785974079 imessage & What'sapp"
#property link      ""
#property version   "1.00"
#property description "Script to remove all symbols from Market Watch window"
#property script_show_inputs

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   int count=0;
   bool removed=true;
   int iterations=0;
   int max_iterations=100;  // Safety limit to prevent infinite loop
   
//--- keep looping until no symbols are left
   while(removed && iterations<max_iterations)
     {
      removed=false;
      iterations++;
      int total=SymbolsTotal(true);
      
      if(total==0)
        {
         Print("No symbols left in Market Watch");
         break;
        }
      
      //--- remove symbols in reverse order to avoid index shifting issues
      for(int i=total-1; i>=0; i--)
        {
         string symbol_name=SymbolName(i,true);
         if(SymbolSelect(symbol_name,false))
           {
            Print("Removed: "+symbol_name);
            count++;
            removed=true;
           }
         else
           {
            Print("Failed to remove: "+symbol_name);
           }
        }
     }
   
//--- display results
   Print("Total symbols removed: "+IntegerToString(count));
   Print("Total iterations: "+IntegerToString(iterations));
   MessageBox("Market Watch cleaned! Removed "+IntegerToString(count)+" symbols in "+IntegerToString(iterations)+" iteration(s).",
              "Success",MB_OK|MB_ICONINFORMATION);
  }
//+------------------------------------------------------------------+