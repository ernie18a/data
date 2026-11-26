//+------------------------------------------------------------------+
//|                                 Correlation Calculator Panel.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com/ru/users/kalipso1979"
#property version   "1.1"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters

/*

   Параметры:

   period - Период корреляции
   shift - Бар с котоорго начинат рассчет
   n - Количество символов в таблице
 

*/

input int      period=200;//Correlation period
// Период корреляции
input int      shift=1;//The bar from which the calculation begins
// Бар с котоорго начинат рассчет
input int      n=15;//Number of characters
// Количество символов
input int      x=10;//X coordinate
// Координата x
input int      y=15;//Y coordinate
// Координата y


//--- indicator buffers
double         Label1Buffer[];

struct Sln{
   string symb;
   string val;
};

Sln line[];
double sd[][2];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Label1Buffer);
   
//---
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int r){
   ObjectsDeleteAll(0,WindowExpertName());
   ChartRedraw(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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

   DrawTableHRow(WindowExpertName()+"_h",x,y,Symbol());

   datetime daytimes[];
   int cnt=MathMin(SymbolsTotal(true),n);
   
   if(ArraySize(line)!=cnt){
      ArrayResize(line,cnt);
      ArrayResize(sd,cnt);
   }
   
   double v=0;
   for(int i=0;i<cnt;i++){
      string val="?";
      ArrayCopySeries(daytimes,MODE_TIME,SymbolName(i,true),Period());
      if(GetLastError()!=4066){
         v=Pirson(Symbol(),SymbolName(i,true),period,shift);    
         if(v<0){
            val=DoubleToStr(v,2);
         }
         else{
            val=" "+DoubleToStr(v,2);
         }
         
      }
      line[i].symb=SymbolName(i,true);
      line[i].val=val;  
      sd[i][0]=v;   
      sd[i][1]=i;
      //DrawTableRow(WindowExpertName()+"_"+(string)i,x,y+(i+1)*23,SymbolName(i,true),val);
   }
   
   ArraySort(sd);
   
   for(int i=0;i<cnt;i++){
      DrawTableRow(WindowExpertName()+"_"+(string)i,x,y+(i+1)*23,line[(int)sd[cnt-1-i][1]].symb,line[(int)sd[cnt-1-i][1]].val);
   }
   
   
   ChartRedraw(0);

   return(rates_total);
  }
//+------------------------------------------------------------------+

double Pirson(string SymMain,string Sym2,int aPer,int aShift){

   int Shift2=iBarShift(Sym2,Period(),Time[aShift]);
   
   double aver1=0,aver2=0;
   int i1=aShift;
   int i2=Shift2;   
   for(int i=0;i<aPer;i++,i1++,i2++){
      aver1+=iClose(SymMain,Period(),i1);
      aver2+=iClose(Sym2,Period(),i2);
   }  
   aver1/=aPer;
   aver2/=aPer;              

   double cov=0;      
   double d1=0;
   double d2=0;
   double z1,z2;
   i1=aShift;
   i2=Shift2;   
   for(int i=0;i<aPer;i++,i1++,i2++){
      z1=(iClose(SymMain,Period(),i1)-aver1);
      z2=(iClose(Sym2,Period(),i2)-aver2);
      cov+=z1*z2;
      d1+=z1*z1;
      d2+=z2*z2;
   }   
   
   d1=MathSqrt(d1);
   d2=MathSqrt(d2);      
   double d=d1*d2;
   if(d==0)return(0);
   return(cov/(d1*d2));
}


void DrawTableHRow(string name,int ax,int ay,string s){
   for(int i=0;i<7;i++){
      fObjLabel(name+"_a_"+(string)i,ax+i*22,ay,CharToStr(110),0,C'181,187,193',30,0,"Wingdings",false);
   }
   fObjLabel(name+"_c_0",ax+46+1,ay+13+1,s,0,C'255,255,255',12,0,"Arial",false);
   fObjLabel(name+"_d_0",ax+46,ay+13,s,0,clrBlack,12,0,"Arial",false);  
}

void DrawTableRow(string name,int ax,int ay,string s,string v){
   for(int i=0;i<7;i++){
      fObjLabel(name+"_a_"+(string)i,ax+i*22,ay,CharToStr(110),0,C'181,187,193',30,0,"Wingdings",false);
   }
   int i;
   for(i=0;i<5;i++){
      fObjLabel(name+"_b_"+(string)i,ax+i*18+2,ay+3,CharToStr(110),0,C'255,255,255',27,0,"Wingdings",false);
   }  
   fObjLabel(name+"_b_"+(string)i,ax+i*18-5,ay+3,CharToStr(110),0,C'255,255,255',27,0,"Wingdings",false); 
   for(i=6;i<8;i++){
      fObjLabel(name+"_b_"+(string)i,ax+i*18,ay+3,CharToStr(110),0,C'255,255,255',27,0,"Wingdings",false);
   }  
   fObjLabel(name+"_b_"+(string)i,ax+i*18-11,ay+3,CharToStr(110),0,C'255,255,255',27,0,"Wingdings",false);   
   
   
   fObjLabel(name+"_c_"+(string)i,ax+9,ay+13,s,0,clrBlack,12,0,"Arial",false);
   
   fObjLabel(name+"_d_"+(string)i,ax+118,ay+13,v,0,clrBlack,12,0,"Arial",false);   
   
}


void fObjLabel(
   string aObjectName,     // 1 имя
   int aX,                 // 2 х
   int aY,                 // 3 у
   string aText,           // 4 текст
   int aCorner=0,          // 5 угол   0  1
                           //          2  3
   color aColor=Red,       // 6 цвет
   int aFontSize=8,        // 7 размер шрифта
   int aWindowNumber=0,    // 8 окно
   string aFont="Arial",   // 9 шрифт
   bool aBack=false        // 10 фон
   ){     
   
   // fLabel("",10,10,"");
   // fLabel("",10,10,"",0,Red,8,0,"Arial",false);
    
      if(ObjectFind(aObjectName)!=aWindowNumber){
         ObjectCreate(aObjectName,OBJ_LABEL,aWindowNumber,0,0);
      }      
   ObjectSet(aObjectName,OBJPROP_XDISTANCE,aX);
   ObjectSet(aObjectName,OBJPROP_YDISTANCE,aY);   
   ObjectSetText(aObjectName,aText,aFontSize,aFont,aColor);
   ObjectSet(aObjectName,OBJPROP_BACK,aBack);
   ObjectSet(aObjectName,OBJPROP_CORNER,aCorner); 
   
   ObjectSetInteger(0,aObjectName,OBJPROP_SELECTABLE,false);
}
