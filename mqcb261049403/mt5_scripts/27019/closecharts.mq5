void OnStart()
{
   int symIndex = 0;
   string symName = "";
   long pChart, cChart;
   pChart = ChartFirst();
   while(true)
   {      
      ChartClose(pChart);     
      cChart = ChartNext(pChart);
      if(cChart < 1) break;
      if(ChartSymbol(cChart) == _Symbol) cChart = ChartNext(cChart);
      pChart = cChart;
   }
   Sleep(1000);   
   for(symIndex = 0; symIndex < SymbolsTotal(false); symIndex++)
   {
      symName = SymbolName(symIndex, false);
      if(SymbolInfoInteger(symName, SYMBOL_SELECT) == true) SymbolSelect(symName, false);
   }
   
}