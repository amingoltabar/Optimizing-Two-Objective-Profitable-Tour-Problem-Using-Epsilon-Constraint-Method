/*********************************************
 * OPL 12.9.0.0 Model
 * Author: Mirza
 * Creation Date: Apr 1, 2021 at 10:55:01 PM
 *********************************************/
// parameters
int numNodes=...;//n

range Nodes=1..numNodes;

int Score[Nodes]=...; //p


float cor_x[Nodes]=...;
float cor_y[Nodes]=...;

float epsilon[1..2] =...; // we need just 1 epsilon.
range Nb=1..2;
float teta[Nb]=...;
float M[1..2] =...; // we need just 1 M.



float time[Nodes][Nodes];


// preprocessing
execute{
	
	for(var i in Nodes)
		for(var j in Nodes)
			time[i][j] = Opl.sqrt(Opl.pow(cor_x[i] - cor_x[j],2) + Opl.pow(cor_y[i] - cor_y[j],2));

}

// variables
dvar boolean x[Nodes][Nodes];
dvar float+ u[Nodes]in 2..numNodes;

// expressions
 dexpr float z1 = sum(i,j in Nodes : i!=numNodes && j>1&& i!=j) (Score[i]*x[i][j]);// total score
 dexpr float z2 = sum(i,j in Nodes: i!=numNodes && j>1 && i!=j) (time[i][j]*x[i][j]); // time
 
 dexpr float objective = teta[1]*z1-teta[2]*z2;
 
 // model
 maximize objective;
 
 subject to{
 	
 	const1:
 	z2 <= epsilon[1] + M[1];
 	
 	const2:
 	sum(j in Nodes : j != 1 )x[1][j] == 1;
 	
 	const3:
 	sum(i in Nodes : i != numNodes )x[i][numNodes] ==1;
 	 
 	const4:
 	forall(k in 2..numNodes-1){
 		sum(i in 1..numNodes-1)x[i][k] == sum(j in 2..numNodes)x[k][j];
 	
 	}
 	
 	const5:
 	forall(k in 2..numNodes-1){
 	 sum(i in 1..numNodes-1)x[i][k] <= 1; 	
 	}
 		
 	 	
 	const6:
 	forall(i in Nodes , j in Nodes : i>1 && j>1 && j!=i){
 		u[i] - u[j] + 1 <=  (numNodes-1)* (1 - x[i][j]); 	
 	}
} 		 	 		
 