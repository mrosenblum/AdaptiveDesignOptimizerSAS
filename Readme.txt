This software allows SAS users to run (via SAS/IML) the adaptive design optimizer code described here: http://rosenblum.jhu.edu
The user does not need to know how to use R to run this. However, the user does need to have R installed on their machine (or computer cluster).
Software overview:
The adaptive design optimizer is intended for investigators planning a confirmatory trial where it’s suspected that a subpopulation may benefit more than the overall population. The subpopulation could be defined by a risk score or biomarker measured at baseline. The subpopulation must be defined in advance, e.g., based on prior data or medical knowledge. Adaptive enrichment designs have potential to provide stronger evidence than standard designs about treatment benefits for the subpopulation, its complement, and the combined population.
Adaptive enrichment designs have a preplanned rule for changing enrollment criteria based on accrued data in an ongoing trial; for example, future enrollment may be restricted to a subpopulation if the complementary subpopulation is not benefiting. This software tool can help in planning such a trial, by
tailoring an adaptive enrichment design to the scientific goals and logistical constraints of the investigator, and
comparing performance of the adaptive design to more traditional designs.
The software searches over hundreds of candidate adaptive designs with the aim of finding one that satisfies the user’s requirements for Type I and II error at the minimum cost. This requires substantial computation and is typically completed within 24 hours, at which time a summary report is emailed to the user.

Instructions for running the trial design optimizer using SAS:
1.  First download R if it is not already installed on your machine (or computer cluster).
2.  Next, download the AdaptiveDesignOptimizer R package by and its required
    starting R and entering these two lines at the R prompt:  

       install.packages("devtools")
       devtools::install_github("mrosenblum/AdaptiveDesignOptimizer")
       q()

    You will need to note where the library was stored.
    As an example, on my Windows machine this was given as "C:/Users/uname/Documents/R/win-library/3.4".
 
3.  Change the SAS configuration file to include the two lines:

       -RLANG
       -SET R_HOME "path to R executable"

    The first of these allows SAS to pass code to R in a submit block.  The
    second gives the location of the R executible on your pc.  On my pc the R
    executable is at "C:\Program Files\R\R-3.4.0".

4.  To check that your installation worked, run each of the trial design optimizer examples 
    example1.sas
    example2.sas
    example3.sas
    after you've changed in each of these files the following 4 macro variables defined near the top of these files
    as required:
	
      %let libref      =  work;
      %let optlocation =  C:\work\OptDesignTest;
      %let pdflocation =  C:\work\OptDesignTest;
      %let rlibpath    = 'C:/Users/uname/Documents/R/win-library/3.4';

    The output library reference is set to work by default.  If you wish to
    keep the output datasets created assign a library and set libref to the
    library reference.  For example:

      library  mylib "C:\work\OptDesignTest\Example1Datasets";
      %let libref = mylib;

    The macro variable optlocation is set to the location of the
    optimize_design_setup.sas file. For example:

      %let pdflocation = C:\work\OptDesignTest;

    The pdflocation macro variable is set to the location where the output
    pdf (listing) should be stored.

    The rlibpath is set to the location where the R libraries are located.
    Note they are enclosed with single quotation marks. This is the location
    given when downloading the libraries in 2. above.

