//+------------------------------------------------------------------+
//|                                                   lot_sizing.mq4 |
//|                                 Programmed by Noé Combes-Bardoll |
//|                             https://www.mql5.com/en/users/nono86 |
//+------------------------------------------------------------------+
#property copyright "Programmed by Noé Combes-Bardoll"
#property link      "https://www.mql5.com/en/users/nono86"
#property version   "1.2"
#property strict
#property show_inputs


input int SL_pips=30;
input double perc_to_loose=5;

void OnStart(){
   Alert(Lots(SL_pips,perc_to_loose)," Lot size for ",Symbol()," with ",SL_pips," SL pips and ",perc_to_loose,"% Risk ");
   
   Print("Lot size : ",Lots(SL_pips,perc_to_loose/100));
   Print("[SL] in pips : ",SL_pips);
   Print("% risk : ",perc_to_loose);
}


double Lots(double sl,double risk){
double lot_size=0;

     
string symbol_currency_right=SymbolInfoString(Symbol(),SYMBOL_CURRENCY_PROFIT);
string symbol_currency_left=SymbolInfoString(Symbol(),SYMBOL_CURRENCY_BASE);
string acc_currency=AccountCurrency();

double money_risk=AccountBalance()*(risk/100);
double dix=Point*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_CONTRACT_SIZE)*10;


//DIRECT RATES
if(symbol_currency_right==acc_currency){//XXXGBP 
   lot_size=money_risk/(dix*sl);
   }
//INDIRECT RATES
else if(acc_currency==symbol_currency_left){//GBPXXX
   lot_size=money_risk*Ask/(dix*sl);
   }
//CROSS RATES
else if(acc_currency!=symbol_currency_left&&acc_currency!=symbol_currency_right){///XXX XXX
   string symbol_2=StringConcatenate(symbol_currency_left,acc_currency);
   SymbolSelect(symbol_2,true);
   
   double r__2=SymbolInfoDouble(symbol_2,SYMBOL_ASK);
   
   if(r__2==0){
      symbol_2=StringConcatenate(acc_currency,symbol_currency_left);
      SymbolSelect(symbol_2,true);
      r__2=SymbolInfoDouble(symbol_2,SYMBOL_ASK);
      
      }
      
   lot_size=Ask*money_risk/(dix*sl*r__2);
   }

return(NormalizeDouble(lot_size,2));
}