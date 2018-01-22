options nodate nonumber nocenter ls=140 ps=100  papersize=letter;

libname lib1 "Lib1";

ods _all_ close;

proc iml;
  reset pagesize=5500;
  %include "optimize_design_setup.sas";

  * Define these matrices as SAS matrices;
  population_parameters_mat    = 0.08 #  { 1.0          1.0          1.0          1.0,
                                           1.0          1.0          1.0    1.3500001,
                                           1.0          1.0          1.0         2.14,
                                           1.0          1.0    1.3500001    1.3500001 };   
  population_parameters_lab    = { "lambda1_con", "lambda2_con", "lambda1_trt", "lambda2_trt"};

  desired_power_mat            = 0.8  #  {  1.0   1.0   0.0,
                                            1.0   0.0   0.0,
                                            1.0   0.0   0.0,
                                            0.0   0.0   0.0 };
  desired_power_lab            = { "Pow_H(0,1)", "Pow_H(0,2)", "Pow_Reject_H0,1_and_H0,2"};

  scenario_weights_mat         = { 0.25, 0.25, 0.25, 0.25};
  scenario_weights_lab         = {"weight"};

  rlibpath                     = '"c:/Users/amcdermo/Documents/R/win-library/3.4"';
  ropts                        = 'width=140,papersize="letter"';

  ods pdf file="pdf/sas_testit1.pdf" notoc style=journal2;
  title;
  od =  optimize_designs(
    /*  ui.n.arms                                          Num   */                           2,
    /*  ui.type.of.outcome.data                            Char  */           '"time-to-event"',
    /*  ui.time.to.event.trial.type                        Char  */         '"non-inferiority"', 
    /*  ui.time.to.event.non.inferiority.trial.margin      Num   */                        1.35,
    /*  ui.subpopulation.1.size                            Num   */                        0.33,
    /*  ui.total.alpha                                     Num   */                        0.05,
    /*  ui.max.size                                        Num   */                       10000,
    /*  ui.max.duration                                    Num   */                          10,
    /*  ui.accrual.yearly.rate                             Num   */                        1000,
    /*  ui.followup.length                                 Num   */                           0,
    /*  ui.optimization.target                             Char  */                    '"size"',
    /*  ui.time.to.event.censoring.rate                    Num   */                           0,
    /*  ui.mcid                                            Num   */                         0.1,
    /*  ui.incorporate.precision.gain                      LChar */                   '"FALSE"',
    /*  ui.relative.efficiency                             Num   */                           1,
    /*  ui.max.stages                                      Num   */                           2,
    /*  ui.include.designs.start.subpop.1                  LChar */                   '"FALSE"',
    /*  ui.population.parameters                           MChar */                            ,
    /*  population.parameters.mat                          Mat   */   population_parameters_mat,
    /*  population.parameters.lab                          Mat   */   population_parameters_lab,
    /*  ui.desired.power                                   MChar */                            ,
    /*  desired.power.mat                                  Mat   */           desired_power_mat,
    /*  desired.power.lab                                  Mat   */           desired_power_lab,
    /*  ui.scenario.weights                                MChar */                            ,
    /*  scenario.weights.mat                               Mat   */        scenario_weights_mat,
    /*  scenario.weights.lab                               Mat   */        scenario_weights_lab,
    /*  simulated.annealing.parameter.max.iterations       Num   */                           2,
    /*  simulated.annealing.parameter.function.scale       Num   */                            ,
    /*  simulated.annealing.parameter.n.scale              Num   */                            ,
    /*  simulated.annealing.parameter.period.scale         Num   */                            ,
    /*  simulated.annealing.parameter.n.simulations        Num   */                            ,
    /*  simulated.annealing.parameter.means.temperature    Num   */                            ,
    /*  simulated.annealing.parameter.survival.temperature Num   */                            ,
    /*  simulated.annealing.parameter.evals.per.temp       Num   */                            ,
    /*  simulated.annealing.parameter.report.iteration     Num   */                            ,
    /*  simulated.annealing.parameter.power.penalty        Num   */                            ,
    /*  Add to R library path                              Char  */                    rlibpath, 
    /*  R print options                                    Char  */                       ropts,
    /*  seed                                               Num   */                          22,
    /*  outlib                                            Char   */                       "lib1"
   );
   ods pdf close;
quit;

  %macro doprint( lib = WORK );
    data tablist;
       set &lib..ODTableNames end=eof nobs=nobs;
       ptr = _n_;
       if eof then do;
         call symput("NTables", put(nobs,8.));
       end;  
    run;
    %do i = 1 %to &NTables;
      data _null_;
        set tablist( where = ( ptr = &i ) );
        call symputx( "t1",  catx(" ", "L1:", put( name1, $80. )));
        call symputx( "t2",  catx(" ", "L2:", put( name2, $80. )));
        call symputx( "t3",  catx(" ", "L3:", put( name3, $80. )));
        call symputx( "tablename", put(tablename,$80.) );
      run;
      title " Table is &lib..&Tablename ";
      title2 "&t1";
      title3 "&t2";
      title4 "&t3";
      proc print data = &lib..&Tablename ( drop = name1 name2 name3 );
      run;
    %end;
  %mend;


* print out the returned SAS datasets from lib1 ;

ods listing;
%doprint( lib = lib1 );

