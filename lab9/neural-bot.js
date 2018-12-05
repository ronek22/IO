function(e) {
    
	
  var response = {};
  var enemy = e.data.enemyTank;
	var me = e.data.myTank;
   
	
	/*Simple neural network*/
	/*we want our tank only to move around the field*/
	
	/*let's take input layer with 3 neurons - extracted from game data*/
	var input  = [me.x, me.y, me.rotation];
	
	/*is it a good idea to normalize the inputs here?*/
	input  = [me.x/500.0, me.y/500.0, (me.rotation%360)/360.0];
	
	console.log("NeuNet input: "+input[0]+", "+input[1]+", "+input[2]);
	
	/*we take 3 hidden neurons*/
	/*from every input neuron there is a connection to every hidden neuron (3 connections), so we need 9 weights; and 3 for bias*/
	var weights1 = [0.5,0.32,-0.11,0.15,0.77,0.11,0.5,0.2,-0.15];
	var bias1 = [0.865,-0.321,0.5];
	
	/*we compute the output values for hidden neurons*/
	var hidden = [0,0,0];
	var i,j;
	for (i=0; i<3; i++){
		for (j=0; j<3; j++){
			hidden[i] = input[j]*weights1[i*3+j];
		}
		hidden[i] = hidden[i]+bias1[i];
		hidden[i] = 1/(1+Math.pow(Math.E, -hidden[i]));
	}
	
	console.log("NeuNet hidden: "+hidden[0]+", "+hidden[1]+", "+hidden[2]);
	
	/*we consider 4 outputs each corresponding to a control-key: turnLeft, turnRight, goForward, goBack - so we need 3*4=12 additional weights + 4 bias*/
	var weights2 = [0.4,0.4,0.2,0.51,0.5,0.8,0.1,-0.5,0.4,0.1,0.4,-0.8];
	//var bias2 = [-0.55,0.21,0.7,-0.55]; // kolka
	var bias2 = [-0.9,-0.9,0.9,0.1]; // do przodu
	
	/*we compute the output values for the  network*/
	var output = [0,0,0,0];
	for (i=0; i<4; i++){
		for (j=0; j<3; j++){
			output[i] = hidden[j]*weights2[i*3+j];
		}
		output[i] = output[i]+bias2[i];
		output[i] = 1/(1+Math.pow(Math.E, -output[i]));
		output[i] = Math.round(output[i]);
	}
	
	console.log("NeuNet output: "+output[0]+", "+output[1]+", "+output[2]+", "+output[3]);
	
	/*we return the values*/
	response.turnLeft = output[0];
	response.turnRight = output[1];
	response.goForward = output[2];
	response.goBack = output[3];
	
	self.postMessage(response);
}