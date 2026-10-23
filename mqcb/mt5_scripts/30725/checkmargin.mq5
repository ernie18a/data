#property copyright           "Mokara"
#property link                "https://www.mql5.com/en/users/mokara"
#property description         "Check Margin"
#property version             "1.0"
#property script_show_inputs  true

enum ORDER
{
   BUY,
   SELL
};

input string symbol = "";  //Symbol Name
input double volume = 0.1; //Volume
input ORDER order = BUY;   //Order Type

//required margin to open {or} with {vol} lots for {sym}
double RequiredMargin(string sym, double vol, ORDER or)
{
   string currencyAccount, currencyBase, currencyQuote, symTemp;
   double symbolContract, symbolBid, symbolAsk;
   int accountLeverage;
   bool symbolType;
   currencyAccount = AccountInfoString(ACCOUNT_CURRENCY);
   currencyBase = SymbolInfoString(sym, SYMBOL_CURRENCY_BASE);
   currencyQuote = SymbolInfoString(sym, SYMBOL_CURRENCY_PROFIT);
   symbolContract = SymbolInfoDouble(sym, SYMBOL_TRADE_CONTRACT_SIZE);
   symbolBid = SymbolInfoDouble(sym, SYMBOL_BID);
   symbolAsk = SymbolInfoDouble(sym, SYMBOL_ASK);
   accountLeverage = AccountInfoInteger(ACCOUNT_LEVERAGE);   
   
   if(currencyAccount == currencyBase)
   {
      return(vol * symbolContract / accountLeverage);
   }
   else if(currencyAccount == currencyQuote)
   {
      return((or==BUY?symbolAsk:symbolBid)*vol*symbolContract/accountLeverage);
   }
   else
   {      
      if(SymbolExist(currencyBase+currencyAccount, symbolType))
      {
         symTemp = currencyBase+currencyAccount;
         if(!SymbolInfoInteger(symTemp, SYMBOL_SELECT)) SymbolSelect(symTemp, true);
         Sleep(100);
         symbolBid = SymbolInfoDouble(symTemp, SYMBOL_BID);
         symbolAsk = SymbolInfoDouble(symTemp, SYMBOL_ASK);
         return((or==BUY?symbolAsk:symbolBid)*vol*symbolContract/accountLeverage); 
      }
      else if(SymbolExist(currencyAccount+currencyBase, symbolType))
      {
         symTemp = currencyAccount+currencyBase;
         if(!SymbolInfoInteger(symTemp, SYMBOL_SELECT)) SymbolSelect(symTemp, true);
         Sleep(100);
         symbolBid = SymbolInfoDouble(symTemp, SYMBOL_BID);
         symbolAsk = SymbolInfoDouble(symTemp, SYMBOL_ASK);
         return((1/(or==BUY?symbolAsk:symbolBid))*vol*symbolContract/accountLeverage); 
      }
      else
      {
         MessageBox("Unable to calculate required margin.", "ERROR", MB_ICONERROR|MB_OK);
         return(0);
      }
   }
}

//check if symbol exists or not, list on marketwatch if not
bool CheckSymbol(string sym)
{
   bool type;
   if(!SymbolExist(sym, type))
   {
      return(false);
   }
   else
   {
      if(!SymbolInfoInteger(sym, SYMBOL_SELECT)) SymbolSelect(sym, true);
      Sleep(100);
   }
   return(true);
}

//is {vol} a valid volume value for {sym}
bool CheckVolume(string sym, double vol)
{
   if(!CheckSymbol(sym))
   {
      MessageBox(sym + " doesn't exists.", "ERROR", MB_ICONERROR|MB_OK);
      return(false);
   }
   double volMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volMax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   int ratio = (int)MathRound(vol / volStep);
   if(vol < volMin) 
   {
      MessageBox("Minimum volume is " + volMin + ".", "ERROR", MB_ICONERROR|MB_OK);
      return(false);
   }
   else if(vol > volMax) 
   {
      MessageBox("Maximum volume is " + volMax + ".", "ERROR", MB_ICONERROR|MB_OK);
      return(false);
   }
   else if(MathAbs(ratio * volStep - vol) > 0.0000001) 
   {
      MessageBox("Invalid volume. Nearest is " + ratio * volStep + ".", "ERROR", MB_ICONERROR|MB_OK);
      return(false);
   }
   else return(true);
}

//maximum volume that can be traded if required margin {mar} for one lot of {sym} is known.
double GetMaxVol(string sym, double mar)
{
   double marginFree = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double volStep = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   double volOut = MathFloor((marginFree/mar)/volStep)*volStep;
   if(volOut < SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN)) volOut = 0;
   if(volOut > SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX)) volOut = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   return(volOut);
}

void OnStart()
{
   double mar;
   string msg = "";
   string symbolName = symbol;
   
   if(!CheckSymbol(symbolName))
   {      
      symbolName = _Symbol;
   }
   if(!CheckVolume(symbolName, volume))
   {
      return;
   }   
   
   //Custom Function
   //mar = RequiredMargin(symbolName, volume, order);
   
   //Built-In Function
   if(!OrderCalcMargin((order == BUY)?ORDER_TYPE_BUY:ORDER_TYPE_SELL, symbolName, volume, (order == BUY)?SymbolInfoDouble(symbolName, SYMBOL_ASK):SymbolInfoDouble(symbolName, SYMBOL_BID), mar))
   {
      Alert("ERROR: margin cannot be calculated.");
      return;
   }
   
   msg += "Free Margin: " + AccountInfoDouble(ACCOUNT_MARGIN_FREE) + " " + AccountInfoString(ACCOUNT_CURRENCY) + "\n";
   msg += "Required Margin to " + EnumToString(order) + " " + DoubleToString(volume, 2) + " Lots: " + DoubleToString(mar, 2) + " " + AccountInfoString(ACCOUNT_CURRENCY) + "\n";
   msg += "Maximum Lots Available to " + EnumToString(order) + ": " + DoubleToString(GetMaxVol(symbolName, mar/volume), 2) + "\n";  
   
   MessageBox(msg, "Check Margin (" + symbolName + ")", MB_ICONINFORMATION|MB_OK);
}