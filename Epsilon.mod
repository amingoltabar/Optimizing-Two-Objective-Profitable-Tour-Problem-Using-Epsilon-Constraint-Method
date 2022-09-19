/*********************************************
 * OPL 12.9.0.0 Model
 * Author: Mirza
 * Creation Date: Apr 2, 2021 at 12:45:57 AM
 *********************************************/
main {
   thisOplModel.settings.mainEndEnabled = true;

	var BestVal = new Array();
	var NadirVal = new Array();
	var pareto1 = new Array();
	var pareto2 = new Array();
	var R=20; 
	var Teta=0;
	var maxObj2=0;
	var ofile = new IloOplOutputFile("modelRun.txt");
	while (Teta != 2) {
		Teta = Teta + 1;
	    var modelSource = new IloOplModelSource("CplexExercise.mod");
	    var modelDef = new IloOplModelDefinition(modelSource);
	    var mmodel = new IloOplModel(modelDef, cplex);
	    var dData = new IloOplDataSource("CplexExercise.dat");
	    mmodel.addDataSource(dData);
	    
	    mmodel.settings.mainEndEnabled = true;
	    dData = mmodel.dataElements;
	    dData.M[1] = 1000000;
	    
	    for ( var i in mmodel.Nb) {
	      if (Teta == i) {
	        dData.teta[i] = 1;
	      } else {
	        dData.teta[i] = 0;
	      }
	    }
		mmodel.generate();
		if (cplex.solve()) {
			if (Teta ==1) {
				BestVal[1] =cplex.getObjValue();
				maxObj2 = mmodel.z2.solutionValue;	
				writeln("Best  value of z1 = ", BestVal[1]);
				NadirVal[2] = maxObj2;
				writeln("worst (max) value of z2 = ", NadirVal[2]);		
			}else{
				BestVal[2] = (-1)*mmodel.objective.solutionValue;
				writeln("Best (min) value of z2", "=", BestVal[2]);
			}
		} else {
		  writeln("No solution for teta=", Teta);
		}
		mmodel.end();
	}
	
	
  	var baze2= NadirVal[2]-BestVal[2];

	writeln("Range of z2: ", baze2)
	var counter=0;
  	while(counter!=R+1)
	  { 
		writeln(counter);
	    var modelSource2 = new IloOplModelSource("CplexExercise.mod");
	    var modelDef2 = new IloOplModelDefinition(modelSource2);
	    var model = new IloOplModel(modelDef2, cplex);
	    var Data = new IloOplDataSource("CplexExercise.dat");
	    model.addDataSource(Data);
	    
	    model.settings.mainEndEnabled = true;
	    Data = model.dataElements;
	    Data.M[1] = 0;
	       
        Data.teta[1] = 1;
    	Data.teta[2] = 0;
    	
       	Data.epsilon[1] = NadirVal[2]-counter*baze2/R;
		      
		model.generate();
		if (cplex.solve()){
		  	pareto1[counter]=model.z1.solutionValue;
		  	pareto2[counter]=model.z2.solutionValue;
		  
	      	writeln("epsilon:", Data.epsilon[1]);
	      	writeln("pareto z1:",pareto1[counter],", pareto z2:",pareto2[counter])
	      	ofile.writeln("epsilon:", Data.epsilon[1]);
	      	ofile.writeln("pareto z1:",pareto1[counter],", pareto z2:",pareto2[counter]);
	      	ofile.writeln(model.printSolution());
	    }else{
	    	writeln("No solution for ", counter);
	    }
	    
		model.end();
		Data.end();
		counter=counter+1;
	}
	ofile.close();
}	