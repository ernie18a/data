//+------------------------------------------------------------------+

//|  DotMatrix - Painel de pontos (verde/vermelho) por indicador      |

//|                                                                  |

//|  Subjanela com uma LINHA por indicador (10 linhas).               |

//|  A cada candle FECHADO calcula a situacao de cada indicador       |

//|  (verde = comprado / vermelho = vendido) e pinta um ponto na      |

//|  barra, um embaixo do outro. O nome de cada indicador aparece     |

//|  a direita, no espaco livre antes da barra 0.                     |

//|                                                                  |

//|  Linhas (de cima para baixo):                                     |

//|   1 ATR Sylvain Vervoort        6 MACD Quant Institutional Pro    |

//|   2 Best Slope TS               7 MACD Quant Ultimate v54         |

//|   3 FXR Triple Hybrid SR        8 MITP (todos os 32 concordam)    |

//|   4 Key Trading System MASTER   9 MITP Limiares (20 / 26)         |

//|   5 Key Trading System         10 Pin-Point TrendFollowing        |

//|                                                                  |

//|  Autonomo: nao precisa dos outros .mq4 compilados.                |

//|  Nao usa iCustom (o Heiken Ashi e calculado internamente).        |

//+------------------------------------------------------------------+

#property copyright "DotMatrix"

#property version   "1.00"

#property strict

#property indicator_separate_window

#property indicator_buffers 1

#property indicator_minimum 0

#property indicator_maximum 11



#define N_ROWS  10

#define N_IND   32

#define WARMUP  250



#define ID_ALMA  0

#define ID_DEMA  1

#define ID_EMA   2

#define ID_HMA   3

#define ID_KAMA  4

#define ID_LSMA  5

#define ID_TEMA  6

#define ID_WMA   7

#define ID_MACRS 8

#define ID_AO    9

#define ID_CCI   10

#define ID_COP   11

#define ID_FISH  12

#define ID_MACD  13

#define ID_MACDH 14

#define ID_PMO   15

#define ID_PPO   16

#define ID_PPOH  17

#define ID_RCI   18

#define ID_RCIB  19

#define ID_RCIR  20

#define ID_RSI   21

#define ID_RVGI  22

#define ID_RVI   23

#define ID_SMII  24

#define ID_STMI  25

#define ID_TSI   26

#define ID_TRSI  27

#define ID_BBP   28

#define ID_CMO   29

#define ID_CHOP  30

#define ID_TECH  31



//--- INPUTS: visual

input string sepV         = "===== VISUAL =====";

input int    InpHistBars  = 250;        // Quantos candles de historico com pontos

input int    InpWarmBars  = 300;        // Candles extras de aquecimento (nao desenhados)

input int    InpDotSize   = 9;          // Tamanho do ponto

input color  InpColUp     = clrLime;    // Cor verde (comprado)

input color  InpColDn     = clrRed;     // Cor vermelha (vendido)

input color  InpColNeu    = clrDimGray; // Cor sem situacao definida

input color  InpNameCol   = clrSilver;  // Cor dos nomes

input int    InpNameSize  = 8;          // Tamanho da fonte dos nomes

input int    InpNameBars  = 2;          // Distancia dos nomes ate a barra 0 (em barras)

input int    InpShiftPct  = 22;         // Margem direita do grafico em % (0 = nao mexer)



//--- INPUTS: ATR Vervoort

input string sepA         = "===== ATR VERVOORT =====";

input int    InpAtrPer    = 9;          // Periodo do ATR

input double InpAtrFactor = 1.0;        // Fator



//--- INPUTS: MACD Quant Institutional Pro

input string sepB         = "===== MACD QUANT INSTITUTIONAL =====";

input int    InpInstAtrPer   = 14;      // Periodo do ATR

input double InpInstAtrFac   = 0.04;    // Fator de tolerancia do ATR

input int    InpInstAdxPer   = 14;      // Periodo do ADX

input int    InpInstAdxThr   = 20;      // Nivel minimo do ADX



//--- INPUTS: MACD Quant Ultimate v54

input string sepC         = "===== MACD QUANT ULTIMATE =====";

input int    InpUltVolPer = 20;         // Periodo do desvio padrao do OSMA

input double InpUltBandM  = 0.5;        // Multiplicador da banda



//--- INPUTS: MITP / MITP Limiares

input string sepD         = "===== MITP / LIMIARES =====";

input int    InpBuyMin    = 20;         // Limiares: triggers de compra para ficar comprado

input int    InpSellMin   = 26;         // Limiares: triggers de venda para ficar vendido

input double InpChopThr   = 5.0;        // Chop Zone: angulo minimo p/ azul/vermelho

input int    InpRciBlue   = 9;          // RCI Ribbon: comprimento da linha azul

input int    InpRciRed    = 26;         // RCI Ribbon: comprimento da linha vermelha



//+------------------------------------------------------------------+

//|  MOTOR DO MITP (copiado dos seus MITP, sem desenho)              |

//+------------------------------------------------------------------+

//--- CLASSES AUXILIARES

class CDir

{

public:

   double v[];

   int    d[];

   void Resize(int n){ ArrayResize(v,n); ArrayResize(d,n); }

   void Set(int i,double val)

   {

      v[i]=val;

      if(i==0){ d[i]=0; return; }

      if(val>v[i-1])      d[i]=1;

      else if(val<v[i-1]) d[i]=-1;

      else                d[i]=d[i-1];

   }

};



class CTsi

{

public:

   double m1[],m2[],a1[],a2[],val[];

   void Resize(int n)

   {

      ArrayResize(m1,n); ArrayResize(m2,n); ArrayResize(a1,n); ArrayResize(a2,n); ArrayResize(val,n);

   }

   void Upd(int i,double ch,int sLen,int lLen)

   {

      double alL=2.0/(lLen+1.0), alS=2.0/(sLen+1.0);

      double ach=MathAbs(ch);

      if(i==0){ m1[0]=ch; m2[0]=ch; a1[0]=ach; a2[0]=ach; }

      else

      {

         m1[i]=m1[i-1]+alL*(ch-m1[i-1]);

         m2[i]=m2[i-1]+alS*(m1[i]-m2[i-1]);

         a1[i]=a1[i-1]+alL*(ach-a1[i-1]);

         a2[i]=a2[i-1]+alS*(a1[i]-a2[i-1]);

      }

      val[i]=(a2[i]!=0.0)? 100.0*m2[i]/a2[i] : 0.0;

   }

};



//--- GATILHO INDIVIDUAL DE CADA INDICADOR

class CTrig

{

public:

   int    s[];    // estado confirmado: 1 comprado, -1 vendido, 0 nenhum

   double bl[];   // gatilho de compra (maxima), 0 = nenhum

   double sl[];   // gatilho de venda (minima), 0 = nenhum

   void Resize(int n){ ArrayResize(s,n); ArrayResize(bl,n); ArrayResize(sl,n); }

   void Inherit(int i)

   {

      if(i==0){ s[0]=0; bl[0]=0.0; sl[0]=0.0; return; }

      s[i]=s[i-1]; bl[i]=bl[i-1]; sl[i]=sl[i-1];

   }

   // v = voto do indicador (1 alta, -1 baixa, 0 neutro) em candle FECHADO

   void Update(int i,int v,double hi,double lo,double cl)

   {

      // 1) voto oposto invalida o gatilho pendente (neutro nao faz nada)

      if(v==-1) bl[i]=0.0;

      if(v==1)  sl[i]=0.0;

      // 2) candle fechado alem do gatilho, mantendo a condicao -> confirma

      if(v==1  && bl[i]>0.0 && cl>bl[i]){ s[i]=1;  bl[i]=0.0; }

      if(v==-1 && sl[i]>0.0 && cl<sl[i]){ s[i]=-1; sl[i]=0.0; }

      // 3) arma novo gatilho (maxima na alta, minima na baixa)

      if(v==1  && bl[i]==0.0 && s[i]!=1)  bl[i]=hi;

      if(v==-1 && sl[i]==0.0 && s[i]!=-1) sl[i]=lo;

   }

};



//--- GLOBAIS

CDir g[N_IND];

CTsi tsiSmii, tsiTrue;

CTrig tr[N_IND];

bool   en[N_IND];

string names[N_IND];

int    curW=-1;



double aO[],aH[],aL[],aC[],hl2[],chgAbs[];

double e9[],e9b[],e9c[],e12[],e26[],e13[],e34[],eT10[],eT20[],eT30[],eT50[],eT100[],eT200[];

double macdL[],macdS[],macdH[],ppoL[],ppoS[],ppoH[];

double hmaIn[],kamaA[],tpA[],cciA[],copIn[],fvA[],fishA[];

double rocA[],pmoA[],pmoB[],pmoC[],gainA[],lossA[],rmaG[],rmaL[],rsiA[];

double swN[],swD[],rvgiN[],rvgiD[],rviIn1[],rviIn2[],rviU[],rviD[];

double smRd[],smDf[],smR1[],smR2[],smD1[],smD2[];

double rawK[],tK[],tD[],momA[],wrA[],aoA[],bbpA[],techA[];

int    posA[];                 // situacao geral por barra (MITP)

double mBuyA[],mSellA[];       // gatilho geral por barra (0 = nenhum)

int    nBuyA[],nSellA[];       // numero de triggers por barra (Limiares)



//--- FUNCOES MATEMATICAS

int Sgn(double x){ return (x>0)?1:((x<0)?-1:0); }



double SmaA(const double &s[],int len,int i)

{

   if(i<len-1) return s[i];

   double sum=0; for(int k=0;k<len;k++) sum+=s[i-k];

   return sum/len;

}

double WmaA(const double &s[],int len,int i)

{

   if(i<len-1) return s[i];

   double sum=0,w=0;

   for(int k=0;k<len;k++){ double ww=len-k; sum+=s[i-k]*ww; w+=ww; }

   return sum/w;

}

void EmaA(double &dst[],const double &s[],int len,int i)

{

   if(i==0){ dst[0]=s[0]; return; }

   double a=2.0/(len+1.0);

   dst[i]=dst[i-1]+a*(s[i]-dst[i-1]);

}

void CemaA(double &dst[],const double &s[],int len,int i)

{

   if(i==0){ dst[0]=s[0]; return; }

   double a=2.0/len;

   dst[i]=a*s[i]+(1.0-a)*dst[i-1];

}

void RmaA(double &dst[],const double &s[],int len,int i)

{

   if(i==0){ dst[0]=s[0]; return; }

   dst[i]=dst[i-1]+(s[i]-dst[i-1])/len;

}

double AlmaA(const double &s[],int len,double off,double sig,int i)

{

   if(i<len-1) return s[i];

   double m=MathFloor(off*(len-1));

   double sd=len/sig;

   double sum=0,norm=0;

   for(int k=0;k<len;k++)

   {

      double w=MathExp(-((k-m)*(k-m))/(2.0*sd*sd));

      sum+=s[i-len+1+k]*w; norm+=w;

   }

   return sum/norm;

}

double LinRegA(const double &s[],int len,int i)

{

   if(i<len-1) return s[i];

   double sx=0,sy=0,sxy=0,sxx=0;

   for(int k=0;k<len;k++)

   {

      double x=k, y=s[i-len+1+k];

      sx+=x; sy+=y; sxy+=x*y; sxx+=x*x;

   }

   double den=len*sxx-sx*sx;

   if(den==0) return s[i];

   double slope=(len*sxy-sx*sy)/den;

   double icpt=(sy-slope*sx)/len;

   return icpt+slope*(len-1);

}

double CorrIdx(const double &s[],int len,int i)

{

   if(i<len-1) return 0;

   double sx=0,sy=0,sxy=0,sxx=0,syy=0;

   for(int k=0;k<len;k++)

   {

      double x=k, y=s[i-len+1+k];

      sx+=x; sy+=y; sxy+=x*y; sxx+=x*x; syy+=y*y;

   }

   double den=MathSqrt((len*sxx-sx*sx)*(len*syy-sy*sy));

   if(den==0) return 0;

   return (len*sxy-sx*sy)/den;

}

double RciA(const double &s[],int len,int i)

{

   if(len<2 || i<len-1) return 0;

   double d=0;

   for(int a=0;a<len;a++)

   {

      int pr=1;

      for(int b=0;b<len;b++) if(s[i-b]>s[i-a]) pr++;

      double df=(a+1)-pr;

      d+=df*df;

   }

   return (1.0-6.0*d/(len*(len*len-1.0)))*100.0;

}



//--- RESIZE

#define RS(a) ArrayResize(a,n)

void ResizeAll(int n)

{

   RS(aO);RS(aH);RS(aL);RS(aC);RS(hl2);RS(chgAbs);

   RS(e9);RS(e9b);RS(e9c);RS(e12);RS(e26);RS(e13);RS(e34);

   RS(eT10);RS(eT20);RS(eT30);RS(eT50);RS(eT100);RS(eT200);

   RS(macdL);RS(macdS);RS(macdH);RS(ppoL);RS(ppoS);RS(ppoH);

   RS(hmaIn);RS(kamaA);RS(tpA);RS(cciA);RS(copIn);RS(fvA);RS(fishA);

   RS(rocA);RS(pmoA);RS(pmoB);RS(pmoC);RS(gainA);RS(lossA);RS(rmaG);RS(rmaL);RS(rsiA);

   RS(swN);RS(swD);RS(rvgiN);RS(rvgiD);RS(rviIn1);RS(rviIn2);RS(rviU);RS(rviD);

   RS(smRd);RS(smDf);RS(smR1);RS(smR2);RS(smD1);RS(smD2);

   RS(rawK);RS(tK);RS(tD);RS(momA);RS(wrA);RS(aoA);RS(bbpA);RS(techA);

   RS(posA);RS(mBuyA);RS(mSellA);RS(nBuyA);RS(nSellA);

   for(int k=0;k<N_IND;k++){ g[k].Resize(n); tr[k].Resize(n); }

   tsiSmii.Resize(n); tsiTrue.Resize(n);

}



//--- CALCULO DE UMA BARRA (i = indice cronologico)

void CalcBar(int i)

{

   double ch=(i>0)? aC[i]-aC[i-1] : 0.0;

   hl2[i]=(aH[i]+aL[i])/2.0;

   chgAbs[i]=MathAbs(ch);



   //--- EMAs

   EmaA(e9,aC,9,i); EmaA(e9b,e9,9,i); EmaA(e9c,e9b,9,i);

   EmaA(e12,aC,12,i); EmaA(e26,aC,26,i); EmaA(e13,aC,13,i); EmaA(e34,aC,34,i);

   EmaA(eT10,aC,10,i); EmaA(eT20,aC,20,i); EmaA(eT30,aC,30,i);

   EmaA(eT50,aC,50,i); EmaA(eT100,aC,100,i); EmaA(eT200,aC,200,i);



   //--- MACD

   macdL[i]=e12[i]-e26[i];

   EmaA(macdS,macdL,9,i);

   macdH[i]=macdL[i]-macdS[i];



   //--- PPO

   ppoL[i]=(e26[i]!=0)? (e12[i]-e26[i])/e26[i]*100.0 : 0.0;

   EmaA(ppoS,ppoL,9,i);

   ppoH[i]=ppoL[i]-ppoS[i];



   //--- HMA 9

   hmaIn[i]=2.0*WmaA(aC,4,i)-WmaA(aC,9,i);

   double hmaV=WmaA(hmaIn,3,i);



   //--- KAMA 14/2/30

   double kmom=(i>=14)? MathAbs(aC[i]-aC[i-14]) : 0.0;

   double kvol=0;

   if(i>=14) for(int k=0;k<14;k++) kvol+=chgAbs[i-k];

   double ker=(kvol!=0)? kmom/kvol : 0.0;

   double kal=MathPow(ker*(2.0/3.0-2.0/31.0)+2.0/31.0,2);

   kamaA[i]=(i==0)? aC[0] : kal*aC[i]+(1.0-kal)*kamaA[i-1];



   //--- AO

   aoA[i]=SmaA(hl2,5,i)-SmaA(hl2,34,i);



   //--- CCI 20 + SMA 14

   tpA[i]=(aH[i]+aL[i]+aC[i])/3.0;

   double smaTp=SmaA(tpA,20,i);

   double dev=0;

   if(i>=19){ for(int k=0;k<20;k++) dev+=MathAbs(tpA[i-k]-smaTp); dev/=20.0; }

   cciA[i]=(dev!=0)? (tpA[i]-smaTp)/(0.015*dev) : 0.0;

   double cciMA=SmaA(cciA,14,i);



   //--- Coppock

   double r14=(i>=14 && aC[i-14]!=0)? 100.0*(aC[i]/aC[i-14]-1.0) : 0.0;

   double r11=(i>=11 && aC[i-11]!=0)? 100.0*(aC[i]/aC[i-11]-1.0) : 0.0;

   copIn[i]=r14+r11;

   double copV=WmaA(copIn,10,i);



   //--- Fisher 9

   int b9=(i>=8)?9:i+1;

   double fh=hl2[i], fl=hl2[i];

   for(int k=1;k<b9;k++){ if(hl2[i-k]>fh) fh=hl2[i-k]; if(hl2[i-k]<fl) fl=hl2[i-k]; }

   double raw=0.66*((hl2[i]-fl)/MathMax(fh-fl,0.001)-0.5)+0.67*((i>0)?fvA[i-1]:0.0);

   fvA[i]=(raw>0.99)?0.999:((raw<-0.99)?-0.999:raw);

   fishA[i]=0.5*MathLog((1.0+fvA[i])/MathMax(1.0-fvA[i],0.001))+0.5*((i>0)?fishA[i-1]:0.0);



   //--- PMO 35/20

   rocA[i]=(i>0 && aC[i-1]!=0)? 100.0*(aC[i]/aC[i-1]-1.0) : 0.0;

   CemaA(pmoA,rocA,35,i);

   pmoB[i]=10.0*pmoA[i];

   CemaA(pmoC,pmoB,20,i);



   //--- RSI 14 + SMA 14

   gainA[i]=(ch>0)? ch : 0.0;

   lossA[i]=(ch<0)? -ch : 0.0;

   RmaA(rmaG,gainA,14,i); RmaA(rmaL,lossA,14,i);

   rsiA[i]=(rmaL[i]==0)? 100.0 : 100.0-100.0/(1.0+rmaG[i]/rmaL[i]);

   double rsiMA=SmaA(rsiA,14,i);



   //--- RVGI 10

   swN[i]=aC[i]-aO[i];

   swD[i]=aH[i]-aL[i];

   rvgiN[i]=(i>=3)? (swN[i-3]+2.0*swN[i-2]+2.0*swN[i-1]+swN[i])/6.0 : 0.0;

   rvgiD[i]=(i>=3)? (swD[i-3]+2.0*swD[i-2]+2.0*swD[i-1]+swD[i])/6.0 : 0.0;

   double sd1=SmaA(rvgiN,10,i), sd2=SmaA(rvgiD,10,i);

   double rvgiV=(sd2!=0)? sd1/sd2 : 0.0;



   //--- Relative Volatility Index 10/14

   double sd=0;

   if(i>=9)

   {

      double m=SmaA(aC,10,i), sq=0;

      for(int k=0;k<10;k++) sq+=MathPow(aC[i-k]-m,2);

      sd=MathSqrt(sq/10.0);

   }

   rviIn1[i]=(ch>0)? sd : 0.0;

   rviIn2[i]=(ch>0)? 0.0 : sd;

   EmaA(rviU,rviIn1,14,i); EmaA(rviD,rviIn2,14,i);

   double rviV=((rviU[i]+rviD[i])!=0)? rviU[i]/(rviU[i]+rviD[i])*100.0 : 50.0;



   //--- SMI Ergodic (5/20) e True Strength Index (13/25)

   tsiSmii.Upd(i,ch,5,20);

   tsiTrue.Upd(i,ch,13,25);



   //--- Stochastic Momentum Index 10/3

   int b10=(i>=9)?10:i+1;

   double hh10=aH[i], ll10=aL[i];

   for(int k=1;k<b10;k++){ if(aH[i-k]>hh10) hh10=aH[i-k]; if(aL[i-k]<ll10) ll10=aL[i-k]; }

   smDf[i]=hh10-ll10;

   smRd[i]=aC[i]-(hh10+ll10)/2.0;

   EmaA(smR1,smRd,3,i); EmaA(smR2,smR1,3,i);

   EmaA(smD1,smDf,3,i); EmaA(smD2,smD1,3,i);

   double stmiV=(smD2[i]!=0)? smR2[i]/(smD2[i]/2.0)*100.0 : 0.0;



   //--- Trend Strength Index 14

   double trsiV=CorrIdx(aC,14,i);



   //--- BBP 13

   bbpA[i]=aH[i]+aL[i]-2.0*e13[i];



   //--- Chande Momentum 9

   double cmoV=0;

   if(i>=9)

   {

      double su=0,sdn=0;

      for(int k=0;k<9;k++)

      {

         double dl=aC[i-k]-aC[i-k-1];

         if(dl>0) su+=dl; else sdn-=dl;

      }

      cmoV=((su+sdn)!=0)? 100.0*(su-sdn)/(su+sdn) : 0.0;

   }



   //--- Chop Zone (angulo da EMA 34)

   double chopV=0;

   if(i>=34)

   {

      double hh34=aH[i], ll34=aL[i];

      for(int k=1;k<34;k++){ if(aH[i-k]>hh34) hh34=aH[i-k]; if(aL[i-k]<ll34) ll34=aL[i-k]; }

      double span=(hh34!=ll34)? 25.0/(hh34-ll34)*ll34 : 0.0;

      double ohlc=(aO[i]+aH[i]+aL[i]+aC[i])/4.0;

      double y2=(ohlc!=0)? (e34[i-1]-e34[i])/ohlc*span : 0.0;

      double cc=MathSqrt(1.0+y2*y2);

      double ang=MathRound(MathArccos(1.0/cc)*180.0/M_PI);

      chopV=(y2>0)? -ang : ang;

   }



   //--- Technicals (APROXIMACAO)

   int b14=(i>=13)?14:i+1;

   double hh14=aH[i], ll14=aL[i];

   for(int k=1;k<b14;k++){ if(aH[i-k]>hh14) hh14=aH[i-k]; if(aL[i-k]<ll14) ll14=aL[i-k]; }

   rawK[i]=(hh14!=ll14)? 100.0*(aC[i]-ll14)/(hh14-ll14) : 0.0;

   tK[i]=SmaA(rawK,3,i);

   tD[i]=SmaA(tK,3,i);

   wrA[i]=(hh14!=ll14)? -100.0*(hh14-aC[i])/(hh14-ll14) : -50.0;

   momA[i]=(i>=10)? aC[i]-aC[i-10] : 0.0;



   double maV=Sgn(aC[i]-eT10[i])+Sgn(aC[i]-SmaA(aC,10,i))

             +Sgn(aC[i]-eT20[i])+Sgn(aC[i]-SmaA(aC,20,i))

             +Sgn(aC[i]-eT30[i])+Sgn(aC[i]-SmaA(aC,30,i))

             +Sgn(aC[i]-eT50[i])+Sgn(aC[i]-SmaA(aC,50,i))

             +Sgn(aC[i]-eT100[i])+Sgn(aC[i]-SmaA(aC,100,i))

             +Sgn(aC[i]-eT200[i])+Sgn(aC[i]-SmaA(aC,200,i));

   maV/=12.0;



   int vRsi=0,vSto=0,vCci=0,vAo=0,vMom=0,vMacd=0,vWr=0,vBbp=0;

   if(i>=1)

   {

      vRsi=(rsiA[i]<30 && rsiA[i]>rsiA[i-1])?1:((rsiA[i]>70 && rsiA[i]<rsiA[i-1])?-1:0);

      vSto=(tK[i]<20 && tK[i]>tD[i])?1:((tK[i]>80 && tK[i]<tD[i])?-1:0);

      vCci=(cciA[i]<-100 && cciA[i]>cciA[i-1])?1:((cciA[i]>100 && cciA[i]<cciA[i-1])?-1:0);

      vAo =(aoA[i]>0 && aoA[i]>aoA[i-1])?1:((aoA[i]<0 && aoA[i]<aoA[i-1])?-1:0);

      vMom=(momA[i]>momA[i-1])?1:-1;

      vMacd=(macdL[i]>macdS[i])?1:((macdL[i]<macdS[i])?-1:0);

      vWr =(wrA[i]<-80 && wrA[i]>wrA[i-1])?1:((wrA[i]>-20 && wrA[i]<wrA[i-1])?-1:0);

      vBbp=(bbpA[i]>0 && bbpA[i]>bbpA[i-1])?1:((bbpA[i]<0 && bbpA[i]<bbpA[i-1])?-1:0);

   }

   double oscV=(vRsi+vSto+vCci+vAo+vMom+vMacd+vWr+vBbp)/8.0;

   techA[i]=(maV+oscV)/2.0;



   //--- ESTADOS (valor + direcao) - cada linha e um indicador independente

   g[ID_ALMA].Set(i,AlmaA(aC,9,0.85,6.0,i));

   g[ID_DEMA].Set(i,2.0*e9[i]-e9b[i]);

   g[ID_EMA].Set(i,e9[i]);

   g[ID_HMA].Set(i,hmaV);

   g[ID_KAMA].Set(i,kamaA[i]);

   g[ID_LSMA].Set(i,LinRegA(aC,25,i));

   g[ID_TEMA].Set(i,3.0*e9[i]-3.0*e9b[i]+e9c[i]);

   g[ID_WMA].Set(i,WmaA(aC,9,i));

   g[ID_MACRS].Set(i,SmaA(aC,9,i));



   g[ID_AO].Set(i,aoA[i]);

   g[ID_CCI].Set(i,cciMA);

   g[ID_COP].Set(i,copV);

   g[ID_FISH].Set(i,fishA[i]);

   g[ID_MACD].Set(i,macdL[i]);

   g[ID_MACDH].Set(i,macdH[i]);

   g[ID_PMO].Set(i,pmoC[i]);

   g[ID_PPO].Set(i,ppoL[i]);

   g[ID_PPOH].Set(i,ppoH[i]);

   g[ID_RCI].Set(i,RciA(aC,9,i));

   g[ID_RCIB].Set(i,RciA(aC,InpRciBlue,i));

   g[ID_RCIR].Set(i,RciA(aC,InpRciRed,i));

   g[ID_RSI].Set(i,rsiMA);

   g[ID_RVGI].Set(i,rvgiV);

   g[ID_RVI].Set(i,rviV);

   g[ID_SMII].Set(i,tsiSmii.val[i]);

   g[ID_STMI].Set(i,stmiV);

   g[ID_TSI].Set(i,tsiTrue.val[i]);

   g[ID_TRSI].Set(i,trsiV);



   g[ID_BBP].Set(i,bbpA[i]);

   g[ID_CMO].Set(i,cmoV);

   g[ID_CHOP].Set(i,chopV);

   g[ID_TECH].Set(i,techA[i]);

}



//--- VOTO DE UM INDICADOR NA BARRA i: 1 alta, -1 baixa, 0 neutro

int Vote(int id,int i)

{

   switch(id)

   {

      case ID_BBP:

      case ID_CMO:

      case ID_TECH: return Sgn(g[id].v[i]);

      case ID_CHOP: return (g[id].v[i]>=InpChopThr)?1:((g[id].v[i]<=-InpChopThr)?-1:0);

   }

   return g[id].d[i];

}





//+------------------------------------------------------------------+

//|  DOTMATRIX - camada propria                                      |

//+------------------------------------------------------------------+

int    posL[];                  // situacao do MITP Limiares por barra

string g_short  = "DotMatrix";

string g_rowName[N_ROWS];

double dmDummy[];

int    g_sub      = -1;

int    g_n        = 0;

datetime g_barTime  = 0;        // Time[0] da ultima passada

datetime g_lastTime = 0;        // Time[1] da ultima barra fechada processada



//--- estados que atravessam as barras (cada indicador mantem o seu)

double g_atr=0.0, g_trail=0.0;  int g_atrSit=0;  bool g_atrBegun=false;

int    g_bsSit=0;

double g_fxStd=0.0, g_fxRaw=0.0; int g_fxSit=0;

double g_haO=0.0, g_haC=0.0;    bool g_haOk=false;

int    g_kmSit=0, g_kSit=0;

int    g_instSit=0, g_ultSit=0;

int    g_ppSit=0;



void ResetCarry()

{

   g_atr=0.0; g_trail=0.0; g_atrSit=0; g_atrBegun=false;

   g_bsSit=0;

   g_fxStd=0.0; g_fxRaw=0.0; g_fxSit=0;

   g_haO=0.0; g_haC=0.0; g_haOk=false;

   g_kmSit=0; g_kSit=0;

   g_instSit=0; g_ultSit=0;

   g_ppSit=0;

}



void ResizeMine(int n)

{

   ArrayResize(posL,n);

}



//+------------------------------------------------------------------+

//|  MOTOR DO MITP - roda uma vez e alimenta as linhas 8 e 9          |

//+------------------------------------------------------------------+

void EngineRun(int n,int prev)

{

   ResizeAll(n);

   ResizeMine(n);



   int start=(prev>1)? prev-1 : 0;



   for(int i=start;i<n;i++)

   {

      int sh=n-1-i;

      aO[i]=Open[sh]; aH[i]=High[sh]; aL[i]=Low[sh]; aC[i]=Close[sh];



      CalcBar(i);



      bool closedBar=(i<n-1);



      //--- camada 1: gatilho individual de cada indicador (so candle FECHADO)

      int cnt=0, nBuy=0, nSell=0;

      for(int k=0;k<N_IND;k++)

      {

         tr[k].Inherit(i);

         cnt++;

         if(closedBar && i>=WARMUP)

            tr[k].Update(i,Vote(k,i),aH[i],aL[i],aC[i]);

         if(tr[k].s[i]==1)       nBuy++;

         else if(tr[k].s[i]==-1) nSell++;

      }

      nBuyA[i]=nBuy;

      nSellA[i]=nSell;



      //--- MITP: gatilho geral (todos os indicadores concordam + rompimento)

      int    p =(i>0)? posA[i-1]   : 0;

      double mb=(i>0)? mBuyA[i-1]  : 0.0;

      double ms=(i>0)? mSellA[i-1] : 0.0;



      if(closedBar && i>=WARMUP && cnt>0)

      {

         if(nSell==cnt) mb=0.0;

         if(nBuy==cnt)  ms=0.0;

         if(mb>0.0 && aC[i]>mb && nBuy==cnt)  { p=1;  mb=0.0; }

         if(ms>0.0 && aC[i]<ms && nSell==cnt) { p=-1; ms=0.0; }

         if(nBuy==cnt  && mb==0.0 && p!=1)  mb=aH[i];

         if(nSell==cnt && ms==0.0 && p!=-1) ms=aL[i];

      }

      posA[i]=p; mBuyA[i]=mb; mSellA[i]=ms;



      //--- MITP Limiares: contagem de triggers >= limiar

      int q=(i>0)? posL[i-1] : 0;

      if(i>=WARMUP)

      {

         bool sOn=(nSell>=InpSellMin);

         bool bOn=(nBuy>=InpBuyMin);

         bool sPrev=(i>0 && nSellA[i-1]>=InpSellMin);

         bool bPrev=(i>0 && nBuyA[i-1]>=InpBuyMin);

         bool sNew=(sOn && !sPrev);

         bool bNew=(bOn && !bPrev);



         if(sOn && bOn)

         {

            if(sNew && !bNew)      q=-1;

            else if(bNew && !sNew) q=1;

         }

         else if(sOn) q=-1;

         else if(bOn) q=1;

      }

      posL[i]=q;

   }

}



//+------------------------------------------------------------------+

//|  INDICADORES NATIVOS (um passo por barra fechada, do antigo p/ novo)

//+------------------------------------------------------------------+



//--- Heiken Ashi interno (mesma formula do indicador padrao do MT4)

void StepHA(int s)

{

   double c=(Open[s]+High[s]+Low[s]+Close[s])/4.0;

   if(!g_haOk){ g_haO=(Open[s]+Close[s])/2.0; g_haOk=true; }

   else        g_haO=(g_haO+g_haC)/2.0;

   g_haC=c;

}



//--- 0) ATR Sylvain Vervoort

int St_Atr(int s)

{

   double F=InpAtrFactor;

   double tr0=MathMax(High[s]-Low[s],MathMax(MathAbs(High[s]-Close[s+1]),MathAbs(Low[s]-Close[s+1])));

   double atrPrev=g_atr;



   if(!g_atrBegun)

   {

      double sum=0.0;

      for(int q=0;q<InpAtrPer;q++)

         sum+=MathMax(High[s+q]-Low[s+q],MathMax(MathAbs(High[s+q]-Close[s+q+1]),MathAbs(Low[s+q]-Close[s+q+1])));

      g_atr=sum/InpAtrPer;

      atrPrev=g_atr;

      g_trail=Close[s]-F*g_atr;

      g_atrSit=1;

      g_atrBegun=true;

   }

   else g_atr=(g_atr*(InpAtrPer-1)+tr0)/InpAtrPer;



   double c=Close[s], c1=Close[s+1];



   if(c>g_trail && c1>g_trail)

   {

      if(g_atrSit==1) g_trail=MathMax(g_trail,c-F*g_atr);

      else { g_trail=MathMax(c-F*g_atr,c1-F*atrPrev); g_atrSit=1; }

   }

   if(c<g_trail && c1<g_trail)

   {

      if(g_atrSit==-1) g_trail=MathMin(g_trail,c+F*g_atr);

      else { g_trail=MathMin(c+F*g_atr,c1+F*atrPrev); g_atrSit=-1; }

   }

   return(g_atrSit);

}



//--- 1) Best Slope TS (8 osciladores todos subindo / todos caindo)

int St_BestSlope(int s)

{

   int p=s+1;

   double sto =iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,s), stoPrv=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,p);

   double cci =iCCI(NULL,0,14,PRICE_TYPICAL,s),                  cciPrv=iCCI(NULL,0,14,PRICE_TYPICAL,p);

   double den =iDeMarker(NULL,0,14,s)*100.0,                     denPrv=iDeMarker(NULL,0,14,p)*100.0;

   double mfi =iMFI(NULL,0,14,s),                                mfiPrv=iMFI(NULL,0,14,p);

   double hist=iOsMA(NULL,0,12,26,9,PRICE_CLOSE,s),              histPrv=iOsMA(NULL,0,12,26,9,PRICE_CLOSE,p);

   double ac  =iAC(NULL,0,s),                                    acPrv=iAC(NULL,0,p);

   double ao  =iAO(NULL,0,s),                                    aoPrv=iAO(NULL,0,p);

   double ad  =iAD(NULL,0,s),                                    adPrv=iAD(NULL,0,p);



   if(sto>stoPrv && cci>cciPrv && den>denPrv && mfi>mfiPrv && hist>histPrv && ac>acPrv && ao>aoPrv && ad>adPrv)

      g_bsSit=1;

   else if(sto<stoPrv && cci<cciPrv && den<denPrv && mfi<mfiPrv && hist<histPrv && ac<acPrv && ao<aoPrv && ad<adPrv)

      g_bsSit=-1;

   return(g_bsSit);

}



//--- 2) FXR Triple Hybrid SR (zero repaint)

int St_Fxr(int s)

{

   double hi=High[iHighest(NULL,0,MODE_HIGH,13,s)];

   double lo=Low [iLowest (NULL,0,MODE_LOW ,13,s)];

   double mid=(High[s]+Low[s])/2.0;



   double st=0.66*((mid-lo)/MathMax(hi-lo,Point*0.1)-0.5)+0.67*g_fxStd;

   st=MathMin(MathMax(st,-0.999),0.999);

   double raw=MathLog((st+1.0)/(1.0-st))/2.0+g_fxRaw/2.0;

   g_fxStd=st;

   g_fxRaw=raw;



   if(raw>0.0)      g_fxSit=1;

   else if(raw<0.0) g_fxSit=-1;

   return(g_fxSit);

}



//--- 3) Key Trading System MASTER

int St_KeyMaster(int s)

{

   double rsi=iRSI(NULL,0,14,PRICE_CLOSE,s);

   double sto=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,s);

   double cci=iCCI(NULL,0,14,PRICE_TYPICAL,s);

   double wpr=iWPR(NULL,0,14,s);

   bool haUp=(g_haC>g_haO), haDn=(g_haC<g_haO);



   if(rsi>40 && haUp && sto>35 && cci>-50 && wpr>-65) g_kmSit=1;

   if(rsi<60 && haDn && sto<65 && cci<50 && wpr<-35)  g_kmSit=-1;

   return(g_kmSit);

}



//--- 4) Key Trading System

int St_Key(int s)

{

   double sar=iSAR(NULL,0,0.02,0.2,s);

   double rsi=iRSI(NULL,0,14,PRICE_CLOSE,s);

   double sto=iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,s);

   double cci=iCCI(NULL,0,14,PRICE_TYPICAL,s);

   double wpr=iWPR(NULL,0,14,s);

   double brs=iBearsPower(NULL,0,13,PRICE_CLOSE,s);

   double bul=iBullsPower(NULL,0,13,PRICE_CLOSE,s);

   bool haUp=(g_haC>g_haO), haDn=(g_haC<g_haO);



   if(rsi>50 && sar<Close[s] && haUp && sto>50 && cci>0 && wpr>-50 && bul>0) g_kSit=1;

   if(rsi<50 && sar>Close[s] && haDn && sto<50 && cci<0 && wpr<-50 && brs<0) g_kSit=-1;

   return(g_kSit);

}



//--- 5) MACD Quant Institutional Pro

int St_MacdInst(int s)

{

   double macd =iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,s);

   double sig  =iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,s);

   double pMacd=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,s+1);

   double pSig =iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,s+1);



   double cur=macd+(macd-sig);

   double prv=pMacd+(pMacd-pSig);



   double atr=iATR(NULL,0,InpInstAtrPer,s);

   double adx=iADX(NULL,0,InpInstAdxPer,PRICE_CLOSE,MODE_MAIN,s);

   double fac=InpInstAtrFac;

   if(adx<InpInstAdxThr) fac*=2.0;



   double thr=atr*fac;

   double delta=cur-prv;

   if(delta>thr)        g_instSit=1;

   else if(delta<=-thr) g_instSit=-1;

   return(g_instSit);

}



//--- 6) MACD Quant Ultimate v54 (filtro fractal desligado, como no original)

int St_MacdUlt(int s)

{

   double macd =iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,s);

   double sig  =iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,s);

   double pMacd=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,s+1);

   double pSig =iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,s+1);



   double cur=macd+(macd-sig);

   double prv=pMacd+(pMacd-pSig);



   double sum=0.0, sumSq=0.0;

   double vals[];

   ArrayResize(vals,InpUltVolPer);

   for(int q=0;q<InpUltVolPer;q++)

   {

      double m=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,s+q);

      double g2=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,s+q);

      vals[q]=m-g2;

      sum+=vals[q];

   }

   double mean=sum/InpUltVolPer;

   for(int q2=0;q2<InpUltVolPer;q2++) sumSq+=MathPow(vals[q2]-mean,2);

   double sd=MathSqrt(sumSq/InpUltVolPer);



   double thr=sd*InpUltBandM;

   double delta=cur-prv;

   if(delta>thr)        g_ultSit=1;

   else if(delta<-thr)  g_ultSit=-1;

   return(g_ultSit);

}



//--- 9) Pin-Point TrendFollowing System

int St_PinPoint(int s)

{

   int p=s+1;

   double hist =iOsMA(NULL,0,12,26,9,PRICE_CLOSE,s),            histPrv=iOsMA(NULL,0,12,26,9,PRICE_CLOSE,p);

   double macd =iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,s),  macdPrv=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,p);

   double ac   =iAC(NULL,0,s),                                  acPrv=iAC(NULL,0,p);

   double ao   =iAO(NULL,0,s),                                  aoPrv=iAO(NULL,0,p);

   double rvi  =iRVI(NULL,0,10,MODE_MAIN,s),                    rviPrv=iRVI(NULL,0,10,MODE_MAIN,p);



   if(rvi>rviPrv && ao>aoPrv && ac>acPrv && macd>macdPrv && hist>histPrv)       g_ppSit=1;

   else if(rvi<rviPrv && ao<aoPrv && ac<acPrv && macd<macdPrv && hist<histPrv)  g_ppSit=-1;

   return(g_ppSit);

}



//+------------------------------------------------------------------+

//|  DESENHO                                                         |

//+------------------------------------------------------------------+

double RowY(int row){ return((double)(N_ROWS-row)); }



string DotName(int row,datetime t)

{

   return("DM_D_"+IntegerToString(row)+"_"+IntegerToString((long)t));

}



void PutDot(int row,datetime t,int st)

{

   string nm=DotName(row,t);

   color  c=(st>0)? InpColUp : ((st<0)? InpColDn : InpColNeu);



   if(ObjectFind(0,nm)<0)

   {

      if(!ObjectCreate(0,nm,OBJ_TEXT,g_sub,t,RowY(row))) return;

      ObjectSetString (0,nm,OBJPROP_TEXT,"l");              // Wingdings "l" = ponto cheio

      ObjectSetString (0,nm,OBJPROP_FONT,"Wingdings");

      ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,InpDotSize);

      ObjectSetInteger(0,nm,OBJPROP_ANCHOR,ANCHOR_CENTER);

      ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);

   }

   ObjectSetInteger(0,nm,OBJPROP_COLOR,c);

}



void PutNames()

{

   datetime t=Time[0]+(datetime)(PeriodSeconds()*InpNameBars);

   for(int r=0;r<N_ROWS;r++)

   {

      string nm="DM_N_"+IntegerToString(r);

      if(ObjectFind(0,nm)<0)

      {

         if(!ObjectCreate(0,nm,OBJ_TEXT,g_sub,t,RowY(r))) continue;

         ObjectSetString (0,nm,OBJPROP_TEXT,g_rowName[r]);

         ObjectSetString (0,nm,OBJPROP_FONT,"Arial");

         ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,InpNameSize);

         ObjectSetInteger(0,nm,OBJPROP_COLOR,InpNameCol);

         ObjectSetInteger(0,nm,OBJPROP_ANCHOR,ANCHOR_LEFT);

         ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);

      }

      else ObjectMove(0,nm,0,t,RowY(r));

   }

}



void DeleteByPrefix(string prefix)

{

   for(int i=ObjectsTotal(0,-1,-1)-1;i>=0;i--)

   {

      string nm=ObjectName(0,i);

      if(StringFind(nm,prefix)==0) ObjectDelete(0,nm);

   }

}



//--- processa UMA barra fechada (shift s) e pinta os pontos

void StepBar(int s)

{

   StepHA(s);



   int st[N_ROWS];

   int ie=g_n-1-s;                 // indice cronologico do motor MITP



   st[0]=St_Atr(s);

   st[1]=St_BestSlope(s);

   st[2]=St_Fxr(s);

   st[3]=St_KeyMaster(s);

   st[4]=St_Key(s);

   st[5]=St_MacdInst(s);

   st[6]=St_MacdUlt(s);

   st[7]=(ie>=0)? posA[ie] : 0;

   st[8]=(ie>=0)? posL[ie] : 0;

   st[9]=St_PinPoint(s);



   if(s<=InpHistBars)

   {

      datetime t=Time[s];

      for(int r=0;r<N_ROWS;r++) PutDot(r,t,st[r]);

   }



   //--- mantem so InpHistBars candles de historico (apaga o mais antigo)

   if(s+InpHistBars<Bars)

   {

      datetime told=Time[s+InpHistBars];

      for(int r2=0;r2<N_ROWS;r2++) ObjectDelete(0,DotName(r2,told));

   }

}



//+------------------------------------------------------------------+

int OnInit()

{

   SetIndexBuffer(0,dmDummy);

   SetIndexStyle(0,DRAW_NONE);

   SetIndexLabel(0,NULL);

   IndicatorShortName(g_short);

   IndicatorDigits(0);



   g_rowName[0]="ATR Vervoort";

   g_rowName[1]="Best Slope TS";

   g_rowName[2]="FXR Triple Hybrid";

   g_rowName[3]="Key TS MASTER";

   g_rowName[4]="Key TS";

   g_rowName[5]="MACD Quant Inst Pro";

   g_rowName[6]="MACD Quant Ult v54";

   g_rowName[7]="MITP";

   g_rowName[8]="MITP Limiares";

   g_rowName[9]="Pin-Point TF";



   for(int k=0;k<N_IND;k++) en[k]=true;



   if(InpShiftPct>0)

   {

      ChartSetInteger(0,CHART_SHIFT,true);

      ChartSetDouble(0,CHART_SHIFT_SIZE,(double)MathMin(MathMax(InpShiftPct,10),50));

   }



   g_barTime=0; g_lastTime=0;

   ResetCarry();

   return(INIT_SUCCEEDED);

}



void OnDeinit(const int reason)

{

   DeleteByPrefix("DM_");

}



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

   if(rates_total<InpWarmBars+100 || rates_total<400) return(0);



   g_sub=WindowFind(g_short);

   if(g_sub<0) return(0);



   //--- so trabalha quando abre um candle novo (a barra anterior acabou de fechar)

   if(prev_calculated>0 && Time[0]==g_barTime) return(rates_total);



   g_n=rates_total;

   EngineRun(rates_total,prev_calculated);



   bool full=(prev_calculated==0 || g_lastTime==0);

   int  sFrom=0;

   if(!full)

   {

      int sl=iBarShift(NULL,0,g_lastTime,true);

      if(sl<0) full=true;

      else     sFrom=sl-1;

   }

   if(full)

   {

      DeleteByPrefix("DM_D_");

      ResetCarry();

      sFrom=MathMin(InpHistBars+InpWarmBars,rates_total-80);

   }



   for(int s=sFrom;s>=1;s--) StepBar(s);



   g_lastTime=Time[1];

   g_barTime =Time[0];



   PutNames();

   ChartRedraw();

   return(rates_total);

}

//+------------------------------------------------------------------+