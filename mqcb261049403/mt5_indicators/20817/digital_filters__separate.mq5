//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Digital filters - separate"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   5
#property indicator_label1  "Channel UP 2"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_label2  "Channel UP 1"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Channel DOWN 1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepPink
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Channel DOWN 2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDeepPink
#property indicator_label5  "Digital filter"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width5  2
//--- input parameters
enum enType
{
   ftlm, // FTLM (Fast Trend Momentum)
   stlm, // STLM (Slow Trend Momentum)
   rbci, // RBCI (Range Bound Channel Index)
   pcci  // PCCI (Perfect Commodity Channel Index)}
};   
input enType             inpType           = rbci;        // Filter type
input int                inpLengthForBands = 52;          // Length for bands (when RBCI is calculated)
input ENUM_APPLIED_PRICE inpPrice          = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[],chanUu[],chanUd[],chanDd[],chanDu[],prices[],work[],filter[],filtea[];
int    filterSize;
int    filteaSize;
;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,chanUu,INDICATOR_DATA);
   SetIndexBuffer(1,chanUd,INDICATOR_DATA);
   SetIndexBuffer(2,chanDu,INDICATOR_DATA);
   SetIndexBuffer(3,chanDd,INDICATOR_DATA);
   SetIndexBuffer(4,val,INDICATOR_DATA);
   SetIndexBuffer(5,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,prices,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,work,INDICATOR_CALCULATIONS);
         switch(inpType)
         {
            case ftlm: fillFatl(filter,filterSize);
                       fillRftl(filtea,filteaSize); break;
            case stlm: fillSatl(filter,filterSize);
                       fillRstl(filtea,filteaSize); break;
            case rbci: fillFatl(filter,filterSize);
                       fillSatl(filtea,filteaSize); break;
            case pcci: fillFatl(filter,filterSize); break;
         }         
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Digital "+EnumToString(inpType));
//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      prices[i] = getPrice(inpPrice,open,close,high,low,i,rates_total);
      chanDd[i] = chanDu[i] = chanUd[i] = chanUu[i] = EMPTY_VALUE;
      val[i] = 0; 
            for(int k=0; k<filterSize && (i-k)>=0; k++)  val[i] += filter[k]*prices[i-k];
                                   if (inpType==pcci)  { val[i]  = prices[i]-val[i]; valc[i] = (i>0) ? (val[i]>val[i-1]) ? 2 : (val[i]<val[i-1]) ? 1 : valc[i-1] : 0; continue; }
            for(int k=0; k<filteaSize && (i-k)>=0; k++)  val[i] -= filtea[k]*prices[i-k];
            
            //
            //---
            //
            
            if (inpType==rbci)
            {  
               work[i] = val[i];
            
                  double rbciSum = 0;
                          for (int k=0; k<inpLengthForBands && (i-k)>=0; k++) rbciSum += work[i-k];
                  double rbciAvg  = rbciSum/inpLengthForBands;
                  double rbciSums = 0;
                          for (int k=0; k<inpLengthForBands && (i-k)>=0; k++) rbciSums += (work[i-k]-rbciAvg)*(work[i-k]-rbciAvg);
                  double temp = MathSqrt(rbciSums/(inpLengthForBands-1));
      
               val[i] =  rbciAvg+work[i];
               chanUu[i] =  2.0*temp;
               chanUd[i] =  1.0*temp;
               chanDu[i] = -1.0*temp;
               chanDd[i] = -2.0*temp;
           }

           //
           //---
           //
                       
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 2 : (val[i]<val[i-1]) ? 1 : valc[i-1] : 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
void fillFatl(double& array[], int& size)
{
   size = 39;
   ArrayResize(array,size);
      array[ 0] = +0.4360392246; array[ 1] = +0.3658678660; array[ 2] = +0.2460451052; array[ 3] = +0.1104516027; array[ 4] = -0.0054023158;
      array[ 5] = -0.0760358291; array[ 6] = -0.0933055008; array[ 7] = -0.0670117473; array[ 8] = -0.0190807171; array[ 9] = +0.0259599784;
      array[10] = +0.0502040720; array[11] = +0.0477820398; array[12] = +0.0249261523; array[13] = -0.0047695503; array[14] = -0.0272425079;
      array[15] = -0.0338916063; array[16] = -0.0244149695; array[17] = -0.0055783815; array[18] = +0.0128142457; array[19] = +0.0226517983;
      array[20] = +0.0208782158; array[21] = +0.0100306129; array[22] = -0.0036762908; array[23] = -0.0136739537; array[24] = -0.0160483888;
      array[25] = -0.0108602627; array[26] = -0.0016069184; array[27] = +0.0069474613; array[28] = +0.0110571907; array[29] = +0.0095715934;
      array[30] = +0.0040450130; array[31] = -0.0023819606; array[32] = -0.0067092445; array[33] = -0.0072000560; array[34] = -0.0047729647;
      array[35] = +0.0005556585; array[36] = +0.0007839957; array[37] = +0.0130102968; array[38] = +0.0040410425;

}
//
//---
//
void fillSatl(double& array[], int& size)
{
   size = 65;
   ArrayResize(array,size);
      array[ 0] = +0.0982914968; array[ 1] = +0.0975734782; array[ 2] = +0.0961453702; array[ 3] = +0.0940284799; array[ 4] = +0.0912491201;
      array[ 5] = +0.0878446115; array[ 6] = +0.0838599824; array[ 7] = +0.0793462193; array[ 8] = +0.0743626146; array[ 9] = +0.0689724471;
      array[10] = +0.0632438243; array[11] = +0.0572485969; array[12] = +0.0510590362; array[13] = +0.0447524857; array[14] = +0.0384014162;
      array[15] = +0.0320788522; array[16] = +0.0258588591; array[17] = +0.0198052896; array[18] = +0.0139852899; array[19] = +0.0084553106;
      array[20] = +0.0032675186; array[21] = -0.0015319201; array[22] = -0.0059034430; array[23] = -0.0098170830; array[24] = -0.0132494238;
      array[25] = -0.0161868549; array[26] = -0.0186163816; array[27] = -0.0205453419; array[28] = -0.0219751066; array[29] = -0.0229225089;
      array[30] = -0.0234106677; array[31] = -0.0234597715; array[32] = -0.0231055463; array[33] = -0.0223841389; array[34] = -0.0213348833;
      array[35] = -0.0199977823; array[36] = -0.0184183252; array[37] = -0.0166438570; array[38] = -0.0147201173; array[39] = -0.0126861210;
      array[40] = -0.0106002368; array[41] = -0.0084800087; array[42] = -0.0063906493; array[43] = -0.0043529032; array[44] = -0.0024016281;
      array[45] = -0.0005592474; array[46] = +0.0011366688; array[47] = +0.0026794401; array[48] = +0.0040424396; array[49] = +0.0052338017;
      array[50] = +0.0062156364; array[51] = +0.0070307929; array[52] = +0.0076234960; array[53] = +0.0080354940; array[54] = +0.0083018972;
      array[55] = +0.0083678562; array[56] = +0.0082888626; array[57] = +0.0080733795; array[58] = +0.0077539545; array[59] = +0.0073259318;
      array[60] = +0.0068163840; array[61] = +0.0062328194; array[62] = +0.0056082863; array[63] = +0.0049522510; array[64] = +0.0161442562;
}
//
//---
//
void fillRftl(double& array[], int& size)
{
   size = 44;
   ArrayResize(array,size);
      array[ 0] = -0.0025092021; array[ 1] = +0.0513012200; array[ 2] = +0.1142800445; array[ 3] = +0.1699338663; array[ 4] = +0.2025262073;
      array[ 5] = +0.2025262073; array[ 6] = +0.1699338663; array[ 7] = +0.1142800445; array[ 8] = +0.0513012200; array[ 9] = -0.0025092021;
      array[10] = -0.0353161991; array[11] = -0.0433374067; array[12] = -0.0311248031; array[13] = -0.0088623799; array[14] = +0.0120575757;
      array[15] = +0.0233181781; array[16] = +0.0221932220; array[17] = +0.0115773967; array[18] = -0.0022153029; array[19] = -0.0126532694;
      array[20] = -0.0157415620; array[21] = -0.0113399687; array[22] = -0.0025909790; array[23] = +0.0059518053; array[24] = +0.0105210324;
      array[25] = +0.0096972603; array[26] = +0.0046588974; array[27] = -0.0017075189; array[28] = -0.0063511121; array[29] = -0.0074539609;
      array[30] = -0.0050442430; array[31] = -0.0007463619; array[32] = +0.0032268725; array[33] = +0.0051357097; array[34] = +0.0044456975;
      array[35] = +0.0018787786; array[36] = -0.0011063441; array[37] = -0.0031162284; array[38] = -0.0033441946; array[39] = -0.0022168887;
      array[40] = +0.0002580855; array[41] = +0.0003641408; array[42] = +0.0060428648; array[43] = +0.0018769344;
}
//
//---
//
void fillRstl(double& array[], int& size)
{
   size = 91;
   ArrayResize(array,size);
      array[ 0] = -0.0074144779; array[ 1] = -0.0060689714; array[ 2] = -0.0044967689; array[ 3] = -0.0027041045; array[ 4] = -0.0007017044;
      array[ 5] = +0.0014967048; array[ 6] = +0.0038730015; array[ 7] = +0.0064060389; array[ 8] = +0.0090719218; array[ 9] = +0.0118447926;
      array[10] = +0.0146938946; array[11] = +0.0175899798; array[12] = +0.0204991221; array[13] = +0.0233878722; array[14] = +0.0262230345;
      array[15] = +0.0289691814; array[16] = +0.0315932085; array[17] = +0.0340622044; array[18] = +0.0363449720; array[19] = +0.0384125260;
      array[20] = +0.0402377072; array[21] = +0.0417971611; array[22] = +0.0430702622; array[23] = +0.0440399154; array[24] = +0.0446940681;
      array[25] = +0.0450229605; array[26] = +0.0450229605; array[27] = +0.0446940681; array[28] = +0.0440399154; array[29] = +0.0430702622;
      array[30] = +0.0417971611; array[31] = +0.0402377072; array[32] = +0.0384125260; array[33] = +0.0363449720; array[34] = +0.0340622044;
      array[35] = +0.0315932085; array[36] = +0.0289691814; array[37] = +0.0262230345; array[38] = +0.0233878722; array[39] = +0.0204991221;
      array[40] = +0.0175899798; array[41] = +0.0146938946; array[42] = +0.0118447926; array[43] = +0.0090719218; array[44] = +0.0064060389;
      array[45] = +0.0038730015; array[46] = +0.0014967048; array[47] = -0.0007017044; array[48] = -0.0027041045; array[49] = -0.0044967689;
      array[50] = -0.0060689714; array[51] = -0.0074144779; array[52] = -0.0085273360; array[53] = -0.0094109068; array[54] = -0.0100658184;
      array[55] = -0.0104997812; array[56] = -0.0107233850; array[57] = -0.0107458773; array[58] = -0.0105836225; array[59] = -0.0102531779;
      array[60] = -0.0097725606; array[61] = -0.0091600941; array[62] = -0.0084366151; array[63] = -0.0076238102; array[64] = -0.0067426306;
      array[65] = -0.0058109474; array[66] = -0.0048554967; array[67] = -0.0038843146; array[68] = -0.0029272721; array[69] = -0.0019938713;
      array[70] = -0.0011000790; array[71] = -0.0002561664; array[72] = +0.0005206574; array[73] = +0.0012273323; array[74] = +0.0018516617;
      array[75] = +0.0023973716; array[76] = +0.0028471064; array[77] = +0.0032204933; array[78] = +0.0034919843; array[79] = +0.0036807022;
      array[80] = +0.0038027296; array[81] = +0.0038329425; array[82] = +0.0037967591; array[83] = +0.0036980559; array[84] = +0.0035517415;
      array[85] = +0.0033556833; array[86] = +0.0031222822; array[87] = +0.0028549772; array[88] = +0.0025689064; array[89] = +0.0022684058;
      array[90] = +0.0073949653;
}
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+
