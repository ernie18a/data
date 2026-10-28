//+------------------------------------------------------------------+
//|                                    YourEAHistoryProfits v1.0.mq4 |
//|                                Copyright © 2011, Tjipke de Vries |
//|           http://www.donnaforex.com/forum/index.php?topic=3938.0 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Tjipke de Vries"
#property link      "http://www.donnaforex.com/forum/index.php?topic=3938.0"

#property indicator_chart_window
//--------------------------------------------------------------------------------
/*  This Indicator looks to the closed trades in the history of your Metatrader station
    It is counting the closed trades with the same magic numbers 
          it can count all trades with same magicnumber
          or you can let it count the trades with same magicnumber and same Symbol()
    It makes also a total count of the selected closed trades
    
    More options...  
     Choose where to have display in the main CHART
     Different colors to choose for Up / Dwn / default
        The magicnumbers and the TotalProfits can have different colors and Fontsize and Fonttype
        
     Free to choose the period to start and end  of the counting profits from the trades...
     
     
   And the last option you have is 
   
             do a Free Donation to my Liberty accountnr.   U 4681166   Accountname deVries         
             or my PayPal account nr..    2665.66.472

   If You like this Indicator or my other work....
*/
//---- input parameters
   extern string datetobegin= "year1_month_day";
   extern datetime firstday=D'2011.05.01';// 1 may 2011      
   extern string finishday= "year2_month_day";
   extern datetime lastday=D'2011.08.01';
   extern string All_Pairs= "True: All Pairs    -- False: Chart Symbol()";
   extern bool All_pairs= True;
   extern int Magic1 = 0;
   extern int Magic2 = 0;
   extern int Magic3 = 0;
   extern int Magic4 = 0;
   extern int Magic5 = 0;
   extern int yline = 10;
   extern int xcolom = 10;
   extern color  TotalsUpColor = Lime;
   extern color  TotalsDnColor = Red;        
   extern color  ProfitUpColor = Lime;
   extern color  ProfitDnColor = Red;
   extern color  DefaultColor = Blue;
   extern string note3 = "Font Size";
   extern int    MagicNrsSize=10;
   extern int    TotalsFontSize=22;
   extern string note4 = "Font Type";
   extern string MagicNrsFontType="Arial";
   extern string TotalsFontType="Arial";
         
   double profit1,profit2,profit3,profit4,profit5,profits;
   double oldpro1,oldpro2,oldpro3,oldpro4,oldpro5,oldpros;
   double magiclots1,magiclots2,magiclots3,magiclots4,magiclots5;
   color Profit1Color, Profit2Color, Profit3Color, Profit4Color, Profit5Color, ProfitsColor;   
   int orderpast1,orderpast2;
   int yLine1,xCol1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   //----- On Screen Display Line Numbers ( Y-Distance) -----
   int yLine1=yline,
       yLine2=yLine1+8 + 8,     
       yLine3=yLine2+8 + 8,
       yLine4=yLine3+TotalsFontSize + 8,
       yLine5=yLine4+9 + 8,
       yLine6=yLine5+9 + 8,
       yLine7=yLine6+MagicNrsSize + 8,
       yLine8=yLine7+MagicNrsSize + 8,
       yLine9=yLine8+MagicNrsSize + 8,
       yLine10=yLine9+MagicNrsSize + 8;

   //----- On Screen Display Column Number (X-Distance) -----
   int xCol1=xcolom;
   
   // On Screen Display Message texts
   //----- Display Lines -----
   
   DisplayText("IndicatName", yLine1, xCol1, "YourEAHistoryProfits v1.0", 8, "Verdana", DefaultColor);
   DisplayText("CopyrightIndi", yLine2, xCol1, "Copyright © 2011, Tjipke de Vries", 8, "Verdana", DefaultColor);   
   
   DisplayText("Profits_Label", yLine3, xCol1, "", TotalsFontSize, TotalsFontType, ProfitsColor);   
   
   DisplayText("StartDate", yLine4, xCol1, "Start date    " + TimeToStr(firstday, TIME_DATE), 9, "Verdana", DefaultColor);
   DisplayText("EndDate", yLine5, xCol1, "Last day       " + TimeToStr(lastday, TIME_DATE), 9, "Verdana", DefaultColor);

   if(Magic1 >=1 ){DisplayText("Profit1_Label", yLine6, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit1Color);}
   if(Magic2 >=1 ){DisplayText("Profit2_Label", yLine7, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit2Color);}
   if(Magic3 >=1 ){DisplayText("Profit3_Label", yLine8, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit3Color);}
   if(Magic4 >=1 ){DisplayText("Profit4_Label", yLine9, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit4Color);}
   if(Magic5 >=1 ){DisplayText("Profit5_Label", yLine10, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit5Color);}
   


//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("IndicatName");
   ObjectDelete("CopyrightIndi");
   ObjectDelete("Profits_Label");
   ObjectDelete("StartDate");
   ObjectDelete("EndDate");
   ObjectDelete("Profit1_Label");   
   ObjectDelete("Profit2_Label");
   ObjectDelete("Profit3_Label");
   ObjectDelete("Profit4_Label");
   ObjectDelete("Profit5_Label");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
   int orderpast1=OrdersHistoryTotal();

   if(orderpast1>orderpast2)
     {
      profit1=0;
      profit2=0;
      profit3=0;
      profit4=0;
      profit5=0;
      profits=0;        
      Calculateprofit();
      orderpast2=orderpast1;
     } 
    
   ObjectSetText("Profits_Label","EA Profits   "+DoubleToStr(profits, 2), TotalsFontSize, TotalsFontType, ProfitsColor);
   if(Magic1 >=1 )ObjectSetText("Profit1_Label","Magic1    "+DoubleToStr(magiclots1, 2)+"   "+DoubleToStr(profit1, 2), MagicNrsSize, MagicNrsFontType, Profit1Color);
   if(Magic2 >=1 )ObjectSetText("Profit2_Label","Magic2    "+DoubleToStr(magiclots2, 2)+"   "+DoubleToStr(profit2, 2), MagicNrsSize, MagicNrsFontType, Profit2Color);
   if(Magic3 >=1 )ObjectSetText("Profit3_Label","Magic3    "+DoubleToStr(magiclots3, 2)+"   "+DoubleToStr(profit3, 2), MagicNrsSize, MagicNrsFontType, Profit3Color);
   if(Magic4 >=1 )ObjectSetText("Profit4_Label","Magic4    "+DoubleToStr(magiclots4, 2)+"   "+DoubleToStr(profit4, 2), MagicNrsSize, MagicNrsFontType, Profit4Color);
   if(Magic5 >= 1){ObjectSetText("Profit5_Label","Magic5    "+DoubleToStr(magiclots5, 2)+"   "+DoubleToStr(profit5, 2), MagicNrsSize, MagicNrsFontType, Profit5Color);}

//----
   return(0);
  }
//+------------------------------------------------------------------+

double Calculateprofit()
    {
     for (int ioht=OrdersHistoryTotal() -1; ioht >= 0; ioht--) 
       { 
        OrderSelect(ioht, SELECT_BY_POS, MODE_HISTORY);
        {
        if(All_pairs != True && OrderSymbol()!= Symbol()) {continue;}
        if(OrderCloseTime()< firstday){ioht=0;}
        if(OrderOpenTime()>=firstday && OrderCloseTime()<lastday)
         {
          oldpros=profits;         
          if ((OrderMagicNumber() == Magic1) && (Magic1 != 0))
            {
             if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               {               
                profit1 = profit1 + OrderProfit() + OrderCommission() + OrderSwap();
                profits = profits + OrderProfit() + OrderCommission() + OrderSwap();
                magiclots1 = magiclots1 + OrderLots();
                if (profit1 > oldpro1) Profit1Color = ProfitUpColor;
                if (profit1 < oldpro1) Profit1Color = ProfitDnColor;
                if (profit1 == oldpro1) Profit1Color = DefaultColor;
                oldpro1=profit1; 
               }
            }
          if ((OrderMagicNumber() == Magic2) && (Magic2 != 0))
            {
             if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               {
                profit2 = profit2 + OrderProfit() + OrderCommission() + OrderSwap();
                profits = profits + OrderProfit() + OrderCommission() + OrderSwap();
                magiclots2 = magiclots2 + OrderLots();
                if (profit2 > oldpro2) Profit2Color = ProfitUpColor;
                if (profit2 < oldpro2) Profit2Color = ProfitDnColor;
                if (profit2 == oldpro2) Profit2Color = DefaultColor;
                oldpro2=profit2; 
               }
            }
          if ((OrderMagicNumber() == Magic3) && (Magic3 != 0))
            {
             if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               {
                profit3 = profit3 + OrderProfit() + OrderCommission() + OrderSwap();
                profits = profits + OrderProfit() + OrderCommission() + OrderSwap();
                magiclots3 = magiclots3 + OrderLots();
                if (profit3 > oldpro3) Profit3Color = ProfitUpColor;
                if (profit3 < oldpro3) Profit3Color = ProfitDnColor;
                if (profit3 == oldpro3) Profit3Color = DefaultColor;
                oldpro3=profit3;   
               }           
            }
          if ((OrderMagicNumber() == Magic4) && (Magic4 != 0))
            {
             if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               {
                profit4 = profit4 + OrderProfit() + OrderCommission() + OrderSwap();
                profits = profits + OrderProfit() + OrderCommission() + OrderSwap();
                magiclots4 = magiclots4 + OrderLots();
                if (profit4 > oldpro4) Profit4Color = ProfitUpColor;
                if (profit4 < oldpro4) Profit4Color = ProfitDnColor;
                if (profit4 == oldpro4) Profit4Color = DefaultColor;
                oldpro4=profit4;   
               }
            }
          if ((OrderMagicNumber() == Magic5) && (Magic5 != 0))
            {
             if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               {
                profit5 = profit5 + OrderProfit() + OrderCommission() + OrderSwap();
                profits = profits + OrderProfit() + OrderCommission() + OrderSwap();
                magiclots5 = magiclots5 + OrderLots();
                if (profit5 > oldpro5) Profit5Color = ProfitUpColor;
                if (profit5 < oldpro5) Profit5Color = ProfitDnColor;
                if (profit5 == oldpro5) Profit5Color = DefaultColor;
                oldpro5=profit5; 
               }           
            }
          if (profits > oldpros) ProfitsColor = TotalsUpColor;
          if (profits < oldpros) ProfitsColor = TotalsDnColor;
          if (profits == oldpros) ProfitsColor = DefaultColor;                        
         }      
        }
    }                            
  return (profits);
 } 



//+------------------------------------------------------------------+

void DisplayText(string eName, int eYD, int eXD, string eText, int eSize, string eFont, color eColor) {
   ObjectCreate(eName, OBJ_LABEL, 0, 0, 0);
   ObjectSet(eName, OBJPROP_CORNER, 0);
   ObjectSet(eName, OBJPROP_XDISTANCE, eXD);
   ObjectSet(eName, OBJPROP_YDISTANCE, eYD);
   ObjectSetText(eName, eText, eSize, eFont, eColor);
}




    