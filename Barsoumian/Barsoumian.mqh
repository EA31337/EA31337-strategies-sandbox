//+------------------------------------------------------------------+
//|                                                      Elliott.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                                           kenorb |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property version   "1.00"
#property strict
//#include  <Convert.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


extern int MA_period=6;
extern int SignalSTRENGTH=5;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EA
  {

public:

   int               SignalBuy,SignalSell;

   void Update(int tf=PERIOD_M1)
     {
      SignalBuy=0;
      SignalSell=0;

      double Base    = iMA(NULL, 0, 1, 0, MODE_EMA, PRICE_CLOSE,0);
      double Var1    = iMA(NULL, 0, MA_period, 0, MODE_SMMA, PRICE_CLOSE, 0);
      double Var2    = iCustom(NULL,0,"QQEA",5,14,4.236, MODE_MAIN,0);
      double Var3    = iCustom(NULL,0,"QQEA",5,14,4.236, MODE_SIGNAL,0);
      double Var5    = iCustom(NULL,0,"LURCH_SRv3",9,3.5,0,0);
      double Var7    = iCustom(NULL,0,"Gann_HiLo_Activator_v2",10,0,0);
      double Var7_1=iCustom(NULL,0,"Gann_HiLo_Activator_v2",10,0,1);
      double Var18=iCustom(0,0,"Slope Direction Line",80,3,0,MODE_MAIN,0);
      double Var18_1=iCustom(0,0,"Slope Direction Line",80,3,0,MODE_MAIN,1);
      double Var19=iSAR(0,0,0.015,0.2,0);
      double Var19_1=iSAR(0,0,0.015,0.2,1);

      if(Base<Var1)
         SignalBuy++;
      if(Var1<Var7)
         SignalBuy++;
      if(Var2>Var3)
         SignalBuy++;
      if(Var7<Var7_1)
         SignalBuy++;
      if(Var18<Var18_1)
         SignalBuy++;
      if(Var19<Var19_1)
         SignalBuy++;
      if(Var7<Var18)
         SignalBuy++;

      if(Base>Var1)
         SignalSell++;
      if(Var1>Var7)
         SignalSell++;
      if(Var2>Var3)
         SignalSell++;
      if(Var7>Var7_1)
         SignalSell++;
      if(Var18>Var18_1)
         SignalSell++;
      if(Var19>Var19_1)
         SignalSell++;
      if(Var7>Var18)
         SignalSell++;
     }

   bool Signal(int cmd,int tf=PERIOD_M1,int signal_method=EMPTY,double signal_level=EMPTY)
     {

      Update(tf);


      if(SignalBuy>=SignalSTRENGTH && cmd==OP_BUY)
         return true;

      else if(SignalSell>=SignalSTRENGTH && cmd==OP_SELL)
                         return true;

      return false;

     }
  };
//+------------------------------------------------------------------+
