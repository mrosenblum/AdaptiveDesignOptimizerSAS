options nodate nonumber nocenter ls=140 ps=100  papersize=letter;

libname lib3 "Lib3";

ods _all_ close;

proc iml;
  reset pagesize=5500;
  %include "optimize_design_setup.sas";

  /* Example 3 */
  * Define these as SAS matrices;
  population_parameters_mat   = {  0.4  0.3  0.5  0.4,
                                   0.4  0.3  0.4  0.4,
                                   0.3  0.3  0.4  0.4 };
  population_parameters_lab   = { "p1_trt", "p1_con", "p2_trt", "p2_con" };
  desired_power_mat           = {    0   0   0.8,
                                   0.8   0     0,
                                     0   0     0 };
  desired_power_lab           = { "Pow_H(0,1)", "Pow_H(0,2)", "Pow_Reject_H0,1_and_H0,2" };
  scenario_weights_mat        = {  0.33,  0.33,  0.34 };
  scenario_weights_lab        = { "weight" };
  rlibpath                    = '"c:/Users/amcdermo/Documents/R/win-library/3.4"';
  ropts                       = 'width=140,papersize="letter"';

  ods pdf file="pdf/sas_testit3.pdf" notoc style=journal2 startpage=never;
  title;
  od =  optimize_designs(
    /*  ui.n.arms                                          Num   */                           2,
    /*  ui.type.of.outcome.data                            Char  */                  '"binary"',
    /*  ui.time.to.event.trial.type                        Char  */                        '""', 
    /*  ui.time.to.event.non.inferiority.trial.margin      Num   */                       'NULL',
    /*  ui.subpopulation.1.size                            Num   */                         0.4,
    /*  ui.total.alpha                                     Num   */                        0.05,
    /*  ui.max.size                                        Num   */                        2000,
    /*  ui.max.duration                                    Num   */                           5,
    /*  ui.accrual.yearly.rate                             Num   */                         400,
    /*  ui.followup.length                                 Num   */                           0,
    /*  ui.optimization.target                             Char  */                    '"size"',
    /*  ui.time.to.event.censoring.rate                    Num   */                           0,
    /*  ui.mcid                                            Num   */                      'NULL',
    /*  ui.incorporate.precision.gain                      LChar */                    '"TRUE"',
    /*  ui.relative.efficiency                             Num   */                         1.2,
    /*  ui.max.stages                                      Num   */                           5,
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
    /*  seed                                               Num   */                          24,
    /*  outlib                                             Char  */                       "lib3"
   );
quit;
ods pdf close;


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

* print out the returned SAS datasets from lib3 ;
ods listing;
%doprint( lib = lib3 );
