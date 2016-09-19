//+------------------------------------------------------------------+
//| DayImpuls_T3_v2.mq4.mq4
//| 
//| http://www.arkworldmarket.ru/forum/showthread.php?t=966&page=2&pp=10 
//+------------------------------------------------------------------+
// Modest добавил сглаживание по методу t3. Добавил каналы.
// Слегка изменил алгоритм, чтобы понятнее воспринимался код. На суть оригинала не влияет НИКАК.
// Убираем лишнюю графику, вводим управление режимом отображения
// DisplayMode=0 Отображаются DayImpuls и слаженная кривая
// DisplayMode=1 Отображаются только DayImpuls 
// DisplayMode=2 Отображаются только слаженная кривая
#property copyright ""
#property link      "http://www.arkworldmarket.ru/forum/showthread.php?t=966&page=2&pp=10"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Indigo
#property indicator_level1 0.0
//---- input parameters
extern int       per=14;
extern int       d=100;
extern int t3_period=8;
extern double b=0.7;
//extern  ChanPercent=70;
extern int DisplayMode=0;
//---- buffers
double  DayImp[];
double  t3[];
//double  MaxH[];
//double  MinH[];
double  MaxLine[];
double  MinLine[];
double  ChanLineMax[];
double  ChanLineMin[];
double Level[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   if(DisplayMode>2 || DisplayMode<0) DisplayMode=0;

   switch(DisplayMode)
     {
      case 0:
         SetIndexStyle(0,DRAW_LINE,EMPTY,1,Magenta);
         SetIndexBuffer(0,DayImp);
         SetIndexStyle(1,DRAW_LINE,EMPTY,2,Red);
         SetIndexBuffer(1,t3);
         break;

      case 1:
         SetIndexStyle(0,DRAW_LINE,EMPTY,1,Magenta);
         SetIndexBuffer(0,DayImp);
         SetIndexStyle(1,DRAW_NONE,EMPTY,2,Red);
         SetIndexBuffer(1,t3);
         break;
      case 2:
         SetIndexStyle(0,DRAW_NONE);
         SetIndexBuffer(0,DayImp);
         SetIndexStyle(1,DRAW_LINE,EMPTY,2,Red);
         SetIndexBuffer(1,t3);
         break;

      default:
         SetIndexStyle(0,DRAW_LINE,EMPTY,1,Magenta);
         SetIndexBuffer(0,DayImp);
         SetIndexStyle(1,DRAW_LINE,EMPTY,2,Red);
         SetIndexBuffer(1,t3);
         break;
     }
/*
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,DayImp);
   SetIndexStyle(1,DRAW_LINE,EMPTY,2,Red);
   SetIndexBuffer(1,t3);
   */
   SetIndexStyle(2,DRAW_LINE,EMPTY,2,Goldenrod);
   SetIndexBuffer(2,MaxLine);
   SetIndexStyle(3,DRAW_LINE,EMPTY,2,Goldenrod);
   SetIndexBuffer(3,MinLine);
   SetIndexLabel(0,NULL); SetIndexLabel(1,NULL);SetIndexLabel(2,NULL);SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);SetIndexLabel(5,NULL);

   SetIndexStyle(4,DRAW_LINE,EMPTY,2,DarkGreen);
   SetIndexBuffer(4,ChanLineMax);
   SetIndexStyle(5,DRAW_LINE,EMPTY,2,DarkGreen);
   SetIndexBuffer(5,ChanLineMin);
   SetIndexStyle(6,DRAW_LINE,EMPTY,1,Blue);
   SetIndexBuffer(6,Level);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();

   int  shift,i,N;
   double imp,mBar,Max,Min;
   double e1,e2,e3,e4,e5,e6,c1,c2,c3,c4,n,w1,w2,b2,b3,dpo,Prise,k;
//SetLoopCount(0);
// loop from first bar to current bar (with shift=0)


//===========================================  Это я уже наколбасил t3: ===============
//=========================================== Взят типовой код          ===============
   if(Bars<=t3_period) return(0);
//---- initial zero
   if(counted_bars<t3_period)
     {
      // for(i=1;i<=t3_period;i++) prise[Bars-i]=0.0;
      for(i=1;i<=t3_period;i++) t3[Bars-i]=0.0;
     }
//----
   b2=b*b;
   b3=b2*b;
   c1=-b3;
   c2=(3*(b2+b3));
   c3=-3*(2*b2+b+b3);
   c4=(1+3*b+b3+3*b2);
   n=t3_period;

   if(n<1) n=1;
   n=1+0.5*(n-1);
   w1 = 2 / (n + 1);
   w2 = 1 - w1;
//----
//================= Конец   ====================  Это я уже наколбасил t3: ===============

   int limit;
   counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- main loop

   for(shift=0; shift<limit; shift++)
      //for shift=Bars-1 Downto 0

     {
      DayImp[shift]=1;
      t3[shift]=0;

      //SetIndexValue(shift,0);
      //SetIndexValue2(shift,0); 
     }

   mBar=d*per;

//for shift=mBar downto per 
   for(shift=Bars-96-1; shift>=0; shift--)
     {
      imp=0;
      Level[shift]=0.0;
      for(i=shift;i<=shift+per; i++)
        {
         imp=imp+(Open[i]-Close[i]);
        }

      imp=MathRound(imp/Point);

      if(imp==0)imp=0.0001;
      if(imp!=0)
        {
         imp=-imp;
         DayImp[shift]=imp;
        }

      //for( i=shift ;i<=shift+per; i++) 

      // DayImp[shift]=iMA(NULL,0,14,0,MODE_SMMA,PRICE_HIGH,i);

      // ==================================== Это я уже наколбасил t3: ========================
      dpo=DayImp[shift];

      e1 = w1*dpo + w2*e1;
      e2 = w1*e1 + w2*e2;
      e3 = w1*e2 + w2*e3;
      e4 = w1*e3 + w2*e4;
      e5 = w1*e4 + w2*e5;
      e6 = w1*e5 + w2*e6;

      t3[shift]=c1*e6+c2*e5+c3*e4+c4*e3;
      // ==========^^^====================== Это я уже наколбасил t3: ====^^^================
      switch(Period())
        {
         case 5: N=288; break;
         case 15: N=96; break;
         case 30: N=48; break;
         case 60: N=24; break;
         default: N=0; break;
        }

      if(N==0) {Alert("Work only in M15,M30,M60 timeframes");return(0);}
      Max=DayImp[shift+N-1];
      Min=DayImp[shift+N-1];

      for(i=shift;i<=shift+N-1; i++)
        {
         if(Max<DayImp[i]) Max=DayImp[i];
         if(Min>DayImp[i]) Min=DayImp[i];
        }
      //MaxH[shift]=Max;//+(Max-Min)*(1-kChannel);
      //MinH[shift]=Min;//+(Max-Min)*(kChannel);
      MaxLine[shift]=Max;//+(Max-Min)*(1-kChannel);
      MinLine[shift]=Min;//+(Max-Min)*(kChannel);

                         //k=((100-ChanPercent)/2)/100;
      ChanLineMax[shift]=Max/2; // Min+(Max-Min)*(1-k);
      ChanLineMin[shift]=Min/2; //Min+(Max-Min)*(k);
     }

//---- 

//----
   return(0);
  }
//+------------------------------------------------------------------+
