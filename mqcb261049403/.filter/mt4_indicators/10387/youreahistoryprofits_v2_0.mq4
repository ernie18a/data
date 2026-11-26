//+------------------------------------------------------------------+
//|                                  YourEAhistoryProfits v2 0  .mq4 |
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
   extern string EAnameMagic1 = "";
   extern int Magic2 = 0;
   extern string EAnameMagic2 = "";
   extern int Magic3 = 0;
   extern string EAnameMagic3 = "";
   extern int Magic4 = 0;
   extern string EAnameMagic4 = "";
   extern int Magic5 = 0;
   extern string EAnameMagic5 = "";
   extern int Magic6 = 0;
   extern string EAnameMagic6 = "";
   extern int Magic7 = 0;
   extern string EAnameMagic7 = "";
   extern int Magic8 = 0;
   extern string EAnameMagic8 = "";
   extern int Magic9 = 0;
   extern string EAnameMagic9 = "";
   extern int Magic10 = 0;
   extern string EAnameMagic10 = "";   
   extern int yline = 10;
   extern int xcolom1 = 10;
   extern int xcolom2 = 150;
   extern color  TotalsUpColor = Lime;
   extern color  TotalsDnColor = Red;        
   extern color  ProfitUpColor = Green;
   extern color  ProfitDnColor = Red;
   extern color  DefaultColor = Blue;
   extern string note3 = "Font Size";
   extern int    MagicNrsSize=8;
   extern int    EAnameSize=10;
   int    ProfitsSize;
   extern int    TotalsFontSize=18;
   extern string note4 = "Font Type";
   extern string MagicNrsFontType="Arial";
   extern string EAnameFontType="Arial";
   extern string TotalsFontType="Arial";
         
   double profit1,profit2,profit3,profit4,profit5,profits;
   double profit6,profit7,profit8,profit9,profit10;   
   double oldpro1,oldpro2,oldpro3,oldpro4,oldpro5,oldpros;
   double oldpro6,oldpro7,oldpro8,oldpro9,oldpro10;   
   color Profit1Color, Profit2Color, Profit3Color, Profit4Color, Profit5Color, ProfitsColor; 
   color Profit6Color, Profit7Color, Profit8Color, Profit9Color, Profit10Color;      
   int orderpast1,orderpast2;
   int yLine1,xCol1,xCol2;
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
       yLine6a=yLine5+MagicNrsSize + 12,              //EAnumber1
       yLine6=yLine6a+EAnameSize + 0,                 //EAname1
       yLine7a=yLine6+MagicNrsSize + 12,
       yLine7=yLine7a+EAnameSize + 0, 
       yLine8a=yLine7+MagicNrsSize + 12,
       yLine8=yLine8a+EAnameSize + 0, 
       yLine9a=yLine8+MagicNrsSize + 12,
       yLine9=yLine9a+EAnameSize + 0, 
       yLine10a=yLine9+MagicNrsSize + 12,
       yLine10=yLine10a+EAnameSize + 0,     
       yLine11a=yLine10+MagicNrsSize + 12,              
       yLine11=yLine11a+EAnameSize + 0,               
       yLine12a=yLine11+MagicNrsSize + 12,
       yLine12=yLine12a+EAnameSize + 0, 
       yLine13a=yLine12+MagicNrsSize + 12,
       yLine13=yLine13a+EAnameSize + 0, 
       yLine14a=yLine13+MagicNrsSize + 12,
       yLine14=yLine14a+EAnameSize + 0, 
       yLine15a=yLine14+MagicNrsSize + 12,
       yLine15=yLine15a+EAnameSize + 0;       
       
        
   //----- On Screen Display Column Number (X-Distance) -----
   int xCol1=xcolom1;
   int xCol2=xcolom2;
   
   // On Screen Display Message texts
   //----- Display Lines -----
   
   DisplayText("IndicatName", yLine1, xCol1, "YourEAHistoryProfits v2.0", 8, "Verdana", DefaultColor);
   DisplayText("CopyrightIndi", yLine2, xCol1, "Copyright © 2011, Tjipke de Vries", 8, "Verdana", DefaultColor);   
   
   DisplayText("Profits_Label", yLine3, xCol1, "EA Profits       "+DoubleToStr(profits, 2), TotalsFontSize, TotalsFontType, ProfitsColor);   
   
   DisplayText("StartDate", yLine4, xCol1, "Start date    " + TimeToStr(firstday, TIME_DATE), 9, "Verdana", DefaultColor);
   DisplayText("EndDate", yLine5, xCol1, "Last day       " + TimeToStr(lastday, TIME_DATE), 9, "Verdana", DefaultColor);

   if(Magic1 >=1 ){DisplayText("Profit1_Label", yLine6a, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit1Color);}
   if(Magic1 >=1 ){DisplayText("Profitt1_Label", yLine6a+4,xCol1+xCol2, "", ProfitsSize, MagicNrsFontType, Profit1Color);}
   if(Magic1 >=1 ){DisplayText("NameEA1_Label", yLine6, xCol1, EAnameMagic1, EAnameSize, EAnameFontType, DefaultColor);}
   if(Magic2 >=1 ){DisplayText("Profit2_Label", yLine7a, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit2Color);}
   if(Magic2 >=1 ){DisplayText("Profitt2_Label", yLine7a+4,xCol1+xCol2, "", ProfitsSize, MagicNrsFontType, Profit2Color);}
   if(Magic2 >=1 ){DisplayText("NameEA2_Label", yLine7, xCol1, EAnameMagic2, EAnameSize, EAnameFontType, DefaultColor);}
   if(Magic3 >=1 ){DisplayText("Profit3_Label", yLine8a, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit3Color);}
   if(Magic3 >=1 ){DisplayText("Profitt3_Label", yLine8a+4, xCol1+xCol2, "", ProfitsSize, MagicNrsFontType, Profit3Color);}
   if(Magic3 >=1 ){DisplayText("NameEA3_Label", yLine8, xCol1, EAnameMagic3, EAnameSize, EAnameFontType, DefaultColor);}
   if(Magic4 >=1 ){DisplayText("Profit4_Label", yLine9a, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit4Color);}
   if(Magic4 >=1 ){DisplayText("Profitt4_Label", yLine9a+4, xCol1+xCol2, "", ProfitsSize, MagicNrsFontType, Profit4Color);}
   if(Magic4 >=1 ){DisplayText("NameEA4_Label", yLine9, xCol1, EAnameMagic4, EAnameSize, EAnameFontType, DefaultColor);}
   if(Magic5 >=1 ){DisplayText("Profit5_Label", yLine10a, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit5Color);}
   if(Magic5 >=1 ){DisplayText("Profitt5_Label", yLine10a+4, xCol1+xCol2, "", ProfitsSize, MagicNrsFontType, Profit5Color);}
   if(Magic5 >=1 ){DisplayText("NameEA5_Label", yLine10, xCol1, EAnameMagic5, EAnameSize, EAnameFontType, DefaultColor);}

   if(Magic6 >=1 ){DisplayText("Profit6_Label", yLine11a, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit6Color);}
   if(Magic6 >=1 ){DisplayText("Profitt6_Label", yLine11a+4, xCol1+xCol2, "", ProfitsSize, MagicNrsFontType, Profit6Color);}
   if(Magic6 >=1 ){DisplayText("NameEA6_Label", yLine11, xCol1, EAnameMagic6, EAnameSize, EAnameFontType, DefaultColor);}
   if(Magic7 >=1 ){DisplayText("Profit7_Label", yLine12a, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit7Color);}
   if(Magic7 >=1 ){DisplayText("Profitt7_Label", yLine12a+4, xCol1+xCol2, "", ProfitsSize, MagicNrsFontType, Profit7Color);}
   if(Magic7 >=1 ){DisplayText("NameEA7_Label", yLine12, xCol1, EAnameMagic7, EAnameSize, EAnameFontType, DefaultColor);}
   if(Magic8 >=1 ){DisplayText("Profit8_Label", yLine13a, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit8Color);}
   if(Magic8 >=1 ){DisplayText("Profitt8_Label", yLine13a+4, xCol1+xCol2, "", ProfitsSize, MagicNrsFontType, Profit8Color);}
   if(Magic8 >=1 ){DisplayText("NameEA8_Label", yLine13, xCol1, EAnameMagic8, EAnameSize, EAnameFontType, DefaultColor);}
   if(Magic9 >=1 ){DisplayText("Profit9_Label", yLine14a, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit9Color);}
   if(Magic9 >=1 ){DisplayText("Profitt9_Label", yLine14a+4, xCol1+xCol2, "", ProfitsSize, MagicNrsFontType, Profit9Color);}
   if(Magic9 >=1 ){DisplayText("NameEA9_Label", yLine14, xCol1, EAnameMagic9, EAnameSize, EAnameFontType, DefaultColor);}
   if(Magic10 >=1 ){DisplayText("Profit10_Label", yLine15a, xCol1, "", MagicNrsSize, MagicNrsFontType, Profit10Color);}
   if(Magic10 >=1 ){DisplayText("Profitt10_Label", yLine15a+4, xCol1+xCol2, "", ProfitsSize, MagicNrsFontType, Profit10Color);}
   if(Magic10 >=1 ){DisplayText("NameEA10_Label", yLine15, xCol1, EAnameMagic10, EAnameSize, EAnameFontType, DefaultColor);}



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
   ObjectDelete("Profit6_Label");   
   ObjectDelete("Profit7_Label");
   ObjectDelete("Profit8_Label");
   ObjectDelete("Profit9_Label");
   ObjectDelete("Profit10_Label");
   ObjectDelete("Profitt1_Label");   
   ObjectDelete("Profitt2_Label");
   ObjectDelete("Profitt3_Label");
   ObjectDelete("Profitt4_Label");
   ObjectDelete("Profitt5_Label");
   ObjectDelete("Profitt6_Label");   
   ObjectDelete("Profitt7_Label");
   ObjectDelete("Profitt8_Label");
   ObjectDelete("Profitt9_Label");
   ObjectDelete("Profitt10_Label");   
   ObjectDelete("NameEA1_Label");
   ObjectDelete("NameEA2_Label");
   ObjectDelete("NameEA3_Label");
   ObjectDelete("NameEA4_Label");
   ObjectDelete("NameEA5_Label");
   ObjectDelete("NameEA6_Label");
   ObjectDelete("NameEA7_Label");
   ObjectDelete("NameEA8_Label");
   ObjectDelete("NameEA9_Label");
   ObjectDelete("NameEA10_Label");
   
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
   ProfitsSize=MagicNrsSize + EAnameSize -4;

   if(orderpast1>orderpast2)
     {
      profit1=0;
      profit2=0;
      profit3=0;
      profit4=0;
      profit5=0;
      profit6=0;
      profit7=0;
      profit8=0;
      profit9=0;
      profit10=0;      
      profits=0;        
      Calculateprofit();
      orderpast2=orderpast1;
     } 
    
   ObjectSetText("Profits_Label","EA Profits   "+DoubleToStr(profits, 2), TotalsFontSize, TotalsFontType, ProfitsColor);
   if(Magic1 >=1 )
      {
       ObjectSetText("Profit1_Label", "Magic1   " + Magic1, MagicNrsSize, MagicNrsFontType, Profit1Color);
       ObjectSetText("Profitt1_Label", DoubleToStr(profit1, 2), ProfitsSize, MagicNrsFontType, Profit1Color);
      }
   if(Magic2 >=1 )
      {
       ObjectSetText("Profit2_Label", "Magic2   " + Magic2, MagicNrsSize, MagicNrsFontType, Profit2Color);
       ObjectSetText("Profitt2_Label", DoubleToStr(profit2, 2), ProfitsSize, MagicNrsFontType, Profit2Color);
      }
   if(Magic3 >=1 )
      {
       ObjectSetText("Profit3_Label", "Magic3   " + Magic3, MagicNrsSize, MagicNrsFontType, Profit3Color);
       ObjectSetText("Profitt3_Label", DoubleToStr(profit3, 2), ProfitsSize, MagicNrsFontType, Profit3Color);
      }
   if(Magic4 >=1 )
      {
       ObjectSetText("Profit4_Label", "Magic4   " + Magic4, MagicNrsSize, MagicNrsFontType, Profit4Color);
       ObjectSetText("Profitt4_Label", DoubleToStr(profit4, 2), ProfitsSize, MagicNrsFontType, Profit4Color);
      }
   if(Magic5 >= 1)
      {
       ObjectSetText("Profit5_Label", "Magic5   " + Magic5, MagicNrsSize, MagicNrsFontType, Profit5Color);
       ObjectSetText("Profitt5_Label", DoubleToStr(profit5, 2), ProfitsSize, MagicNrsFontType, Profit5Color);
      }
      
      
   if(Magic6 >=1 )
      {
       ObjectSetText("Profit6_Label", "Magic6   " + Magic6, MagicNrsSize, MagicNrsFontType, Profit6Color);
       ObjectSetText("Profitt6_Label", DoubleToStr(profit6, 2), ProfitsSize, MagicNrsFontType, Profit6Color);
      }
   if(Magic7 >=1 )
      {
       ObjectSetText("Profit7_Label", "Magic7   " + Magic7, MagicNrsSize, MagicNrsFontType, Profit7Color);
       ObjectSetText("Profitt7_Label", DoubleToStr(profit7, 2), ProfitsSize, MagicNrsFontType, Profit7Color);
      }
   if(Magic8 >=1 )
      {
       ObjectSetText("Profit8_Label", "Magic8   " + Magic8, MagicNrsSize, MagicNrsFontType, Profit8Color);
       ObjectSetText("Profitt8_Label", DoubleToStr(profit8, 2), ProfitsSize, MagicNrsFontType, Profit8Color);
      }
   if(Magic9 >=1 )
      {
       ObjectSetText("Profit9_Label", "Magic9   " + Magic9, MagicNrsSize, MagicNrsFontType, Profit9Color);
       ObjectSetText("Profitt9_Label", DoubleToStr(profit9, 2), ProfitsSize, MagicNrsFontType, Profit9Color);
      }
   if(Magic10 >= 1)
      {
       ObjectSetText("Profit10_Label", "Magic10   " + Magic10, MagicNrsSize, MagicNrsFontType, Profit10Color);
       ObjectSetText("Profitt10_Label", DoubleToStr(profit10, 2), ProfitsSize, MagicNrsFontType, Profit10Color);
      }
      

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
                if (profit5 > oldpro5) Profit5Color = ProfitUpColor;
                if (profit5 < oldpro5) Profit5Color = ProfitDnColor;
                if (profit5 == oldpro5) Profit5Color = DefaultColor;
                oldpro5=profit5; 
               }           
            }
          if ((OrderMagicNumber() == Magic6) && (Magic6 != 0))
            {
             if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               {               
                profit6 = profit6 + OrderProfit() + OrderCommission() + OrderSwap();
                profits = profits + OrderProfit() + OrderCommission() + OrderSwap();
                if (profit6 > oldpro6) Profit6Color = ProfitUpColor;
                if (profit6 < oldpro6) Profit6Color = ProfitDnColor;
                if (profit6 == oldpro6) Profit6Color = DefaultColor;
                oldpro6=profit6; 
               }
            }
          if ((OrderMagicNumber() == Magic7) && (Magic7 != 0))
            {
             if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               {
                profit7 = profit7 + OrderProfit() + OrderCommission() + OrderSwap();
                profits = profits + OrderProfit() + OrderCommission() + OrderSwap();
                if (profit7 > oldpro7) Profit7Color = ProfitUpColor;
                if (profit7 < oldpro7) Profit7Color = ProfitDnColor;
                if (profit7 == oldpro7) Profit7Color = DefaultColor;
                oldpro7=profit7; 
               }
            }
          if ((OrderMagicNumber() == Magic8) && (Magic8 != 0))
            {
             if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               {
                profit8 = profit8 + OrderProfit() + OrderCommission() + OrderSwap();
                profits = profits + OrderProfit() + OrderCommission() + OrderSwap();
                if (profit8 > oldpro8) Profit8Color = ProfitUpColor;
                if (profit8 < oldpro8) Profit8Color = ProfitDnColor;
                if (profit8 == oldpro8) Profit8Color = DefaultColor;
                oldpro8=profit8;   
               }           
            }
          if ((OrderMagicNumber() == Magic9) && (Magic9 != 0))
            {
             if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               {
                profit9 = profit9 + OrderProfit() + OrderCommission() + OrderSwap();
                profits = profits + OrderProfit() + OrderCommission() + OrderSwap();
                if (profit9 > oldpro9) Profit9Color = ProfitUpColor;
                if (profit9 < oldpro9) Profit9Color = ProfitDnColor;
                if (profit9 == oldpro9) Profit9Color = DefaultColor;
                oldpro9=profit9;   
               }
            }
          if ((OrderMagicNumber() == Magic10) && (Magic10 != 0))
            {
             if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               {
                profit10 = profit10 + OrderProfit() + OrderCommission() + OrderSwap();
                profits = profits + OrderProfit() + OrderCommission() + OrderSwap();
                if (profit10 > oldpro10) Profit10Color = ProfitUpColor;
                if (profit10 < oldpro10) Profit10Color = ProfitDnColor;
                if (profit10 == oldpro10) Profit10Color = DefaultColor;
                oldpro10=profit10; 
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




    