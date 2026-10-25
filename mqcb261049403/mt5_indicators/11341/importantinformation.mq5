//----------------------------------------------------------------------------+
//|                                                  ImportantInformation.mq5 |
//|                                                 Copyright 2014, papaklass |
//|                                 https://login.mql5.com/ru/users/papaklass |
//----------------------------------------------------------------------------+
#property copyright "Copyright 2014, papaklass"
#property link      "https://www.mql5.com/ru/users/papaklass"
#property version   "1.00"

#property indicator_chart_window
#property indicator_plots 0

//--- input parameters
input color    FirstColor = clrWhite;
input color    SecondColor = clrAqua;
input int      FontSize = 10;
input string   Font = "Areal";
input int      Corner = 0; //Corner = 0 - LeftTop. (0 - 3)

string nameObject[4] = {"time", "account", "symbol", "symbol2"};
//----------------------------------------------------------------------------+
int OnInit()
{
//---
   return(INIT_SUCCEEDED);
}//---------------------------------------------------------------------------+

int OnCalculate (const int rates_total,      // размер массива price[]
                 const int prev_calculated,  // обработано баров на предыдущем вызове
                 const int begin,            // откуда начинаются значимые данные
                 const double& price[]       // массив для расчета
                 )
{
//---
   int size = ArraySize(nameObject);
   int distance = FontSize + (int)FontSize / 2;
   
   for(int i = 0; i < size; i++)
   {
      //--- indicator buffers mapping
      ObjectCreate(0,nameObject[i], OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,nameObject[i], OBJPROP_CORNER,Corner);
      ObjectSetInteger(0,nameObject[i], OBJPROP_XDISTANCE,280);
      ObjectSetInteger(0,nameObject[i], OBJPROP_YDISTANCE,(i+1) * distance);
   }
    
   string text = "";
   StringAdd(text,"cur: ");
   StringAdd(text,TimeToString(TimeCurrent(),TIME_SECONDS));
   StringAdd(text,"  loc: ");
   StringAdd(text,TimeToString(TimeLocal(),TIME_SECONDS));
   StringAdd(text,"  gmt: ");
   StringAdd(text,TimeToString(TimeGMT(),TIME_SECONDS));
   
//--- установим текст
   ObjectSetString(0,"time", OBJPROP_TEXT, text);
//--- установим шрифт текста
   ObjectSetString(0,"time",OBJPROP_FONT,Font);
//--- установим размер шрифта
   ObjectSetInteger(0,"time",OBJPROP_FONTSIZE,FontSize);
//--- установим цвет
   ObjectSetInteger(0,"time",OBJPROP_COLOR,FirstColor);
   
   ENUM_ACCOUNT_TRADE_MODE account_type=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
//--- теперь превратим значение перечисления в понятный вид
   string trade_mode;
   switch(account_type)
     {
      case  ACCOUNT_TRADE_MODE_DEMO:
         trade_mode="Demo";
         break;
      case  ACCOUNT_TRADE_MODE_CONTEST:
         trade_mode="Contest";
         break;
      default:
         trade_mode="Live";
         break;
     }
   string text1 = "";
   //StringAdd(text1," Account:   ");
   StringAdd(text1,trade_mode);
   StringAdd(text1,"  lev: ");
   StringAdd(text1,IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE)));
   StringAdd(text1,"  bal: ");
   StringAdd(text1,DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
   StringAdd(text1,"  equ: ");
   StringAdd(text1,DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2));
//--- установим текст
   ObjectSetString(0,"account", OBJPROP_TEXT, text1);
//--- установим шрифт текста
   ObjectSetString(0,"account",OBJPROP_FONT,Font);
//--- установим размер шрифта
   ObjectSetInteger(0,"account",OBJPROP_FONTSIZE,FontSize);
//--- установим цвет
   ObjectSetInteger(0,"account",OBJPROP_COLOR,SecondColor);
   
   string text2 = "";
   StringAdd(text2,"spread: ");
   StringAdd(text2,IntegerToString(SymbolInfoInteger(Symbol(), SYMBOL_SPREAD),2));
   StringAdd(text2,"  swapL: ");
   StringAdd(text2,DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_SWAP_LONG), 2));
   StringAdd(text2,"  swapS: ");
   StringAdd(text2,DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_SWAP_SHORT), 2));
//--- установим текст
   ObjectSetString(0,"symbol", OBJPROP_TEXT, text2);
//--- установим шрифт текста
   ObjectSetString(0,"symbol",OBJPROP_FONT,Font);
//--- установим размер шрифта
   ObjectSetInteger(0,"symbol",OBJPROP_FONTSIZE,FontSize);
//--- установим цвет
   ObjectSetInteger(0,"symbol",OBJPROP_COLOR,FirstColor);
   
   string text3 = "";
   StringAdd(text3,"tickVal: ");
   StringAdd(text3,DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE), Digits()));
   StringAdd(text3,"  minLot: ");
   StringAdd(text3,DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN), 2));
   StringAdd(text3,"  maxLot: ");
   StringAdd(text3,DoubleToString(SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX), 2));
//--- установим текст
   ObjectSetString(0,"symbol2", OBJPROP_TEXT, text3);
//--- установим шрифт текста
   ObjectSetString(0,"symbol2",OBJPROP_FONT,Font);
//--- установим размер шрифта
   ObjectSetInteger(0,"symbol2",OBJPROP_FONTSIZE,FontSize);
//--- установим цвет
   ObjectSetInteger(0,"symbol2",OBJPROP_COLOR,SecondColor);
   
   ChartRedraw(0);
      
//--- return value of prev_calculated for next call
   return(rates_total);
}//---------------------------------------------------------------------------+

void OnDeinit(const int reason)
{
   int size = ArraySize(nameObject);
      
   for(int j = 0; j < size; j++)
      if (!ObjectDelete(0, nameObject[j]))
         Alert("Объект ",nameObject[j],"не удален. Error = ",GetLastError());
//---
}//---------------------------------------------------------------------------+
