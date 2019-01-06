function(e) {
    
    function angle(x) {
        return (x%360)/360.0;
    }

    function norm(x) {
        return (x+15)/30.0;
    }
	
    var response = {};
    var enemy = e.data.enemyTank;
    var me = e.data.myTank;
    var time = e.data.currentGameTime

      
      /*Simple neural network*/
      /*we want our tank only to move around the field*/
      
      /*let's take input layer with 3 neurons - extracted from game data*/
      var input  = [me.x, me.y, me.rotation, me.canoonRotation,
                    me.velocityX, me.velocityY, me.shootCooldown,
                    enemy.x, enemy.y, enemy.rotation, 
                    enemy.cannonRotation, enemy.velocityX, 
                    enemy.velocityY, enemy.shootCooldown,time              
    ];
      
      /*is it a good idea to normalize the inputs here?*/
      input  = [me.x/500.0, me.y/500.0, angle(me.rotation),
                angle(me.cannonRotation), norm(me.velocityX), norm(me.velocityY),
                me.shootCooldown/100.0, 
                enemy.x/500.0, enemy.y/500.0, angle(enemy.rotation),
                angle(enemy.cannonRotation), norm(enemy.velocityX), norm(enemy.velocityY),
                enemy.shootCooldown/100.0, time/40000.0  
    ];
      console.log("TEST: " + enemy.rotation + ', ' + enemy.cannonRotation)
    
      console.log("NeuNet input: "+input[0]+", "+input[1]+", "+input[2]+", "+input[3]+", "
      +input[4]+", "+input[5]+", "+input[6]+", "+input[7]+", "+input[8]+", "+input[9]+", "
      +input[10]+", "+input[11]+", "+input[12]+", "+input[13]+", "+input[14]);
      
      /*we take 3 hidden neurons*/
      /*from every input neuron there is a connection to every hidden neuron (3 connections), so we need 9 weights; and 3 for bias*/
      var weights1 = [-1.19555823565216,1.80731728804907,4.24520333052586,2.71666824012631,2.26747443144873,-3.95235269933851,-0.191761909283258,0.772521093136143,0.442959078384892,-0.514188584860243,-0.318860210406349,0.443739259969642,0.197307498458335,-0.701535741609284,0.158953317521581,1.20836927629753,1.83531359108564,0.957665771002201,1.64774497051299,4.72302155950579,1.94062059367974,-1.16116797368342,-8.47259126393716,1.10801171915195,-2.94965911341137,-1.45269733267484,3.38622823444162,-2.98294022276831,-0.00283051872019084,-3.93219568199574,-0.740699636216126,-2.71385362674553,0.14230611249545,0.286621616607175,0.67549510323152,-1.22585644461145,-0.623635815887942,5.40031564458797,2.44559226556083,0.941216470238384,1.31701937113963,-2.9952087229248,0.0176237175607384,-0.280582679767359,-1.4361124323508,-3.83645690194638,0.0407808231505553,-0.764854710877729,-2.4644157300411,-1.39052394125567,0.731859072494734,0.915461403145339,1.65768699092908,0.660251137307594,-0.3433388689081,0.73635414479237,-0.714903082756454,0.329506915524302,-0.415385894071711,-1.58941287793616,1.08665118459582,0.0367702425898953,2.57959270420949,2.45002743443567,0.270604984382105,-3.62777385469512,-0.852122202550184,1.03630447324506,0.175933476464539,-0.287875279236256,-0.178795496884607,-0.141441218840442,0.184348352856042,-0.405230679334422,0.807800465711064,-2.16502832010671,1.02758177282542,0.536062689993598,1.91975212561678,-1.30470632082237,-1.65333320395103,0.439859671988793,-0.422841245978705,-1.42802142578132,-0.587146464466404,-0.168822386949246,0.778067103637241,0.75180893761242,-0.23357939333094,-0.256565589269154];
      var bias1 = [-2.43990390306578,5.12039743418545,-1.04197666679349,2.79522510864651,-2.23092678657924,-0.273493789080461];

      /*we compute the output values for hidden neurons*/
      var hidden = [0,0,0,0,0,0];
      var i,j;
      for (i=0; i<6; i++){
          for (j=0; j<15; j++){
              hidden[i] += input[j]*weights1[i*15+j];
          }
          hidden[i] = hidden[i]+bias1[i];
          hidden[i] = 1/(1+Math.pow(Math.E, -hidden[i]));
      }
      
      console.log("NeuNet hidden: "+hidden[0]+", "+hidden[1]+", "+hidden[2]+hidden[3]+", "+hidden[4]+", "+hidden[5]+", ");
      
      /*we consider 4 outputs each corresponding to a control-key: turnLeft, turnRight, goForward, goBack - so we need 3*4=12 additional weights + 4 bias*/
      var weights2 = [-0.868914715434742,0.0600918611519301,-2.25837759605737,3.13053165018821,4.94509158665147,-5.87460827139406,0.29371427691683,0.627903726525242,0.984209151253945,-0.854928958073408,-1.66612513416454,2.32950061712403,-3.89864050378755,1.85348179490083,0.278815518451631,0.401466845973598,4.1723316969634,0.0114931919322501,2.16160436590478,-1.09677522488095,0.230612663975273,-0.605901469040904,-2.69632542104321,0.61192292785645,0.0000000211526654339064,0.0000000189232880003551,0.00000000643912704108745,0.00000000565162690451748,-0.0000000267945297192855,0.0000000207322836862547,-0.000000020218998986176,-0.000000019612528253856,-0.00000000533866196583119,-0.00000000670095948633259,0.0000000244764586177018,-0.0000000181774328824316,-0.0000000117267810090892,-0.0000000167128963745355,0.000000000703771943033853,-0.0000000128185251108802,0.00000000522371943638801,-0.00000000000242440181107319];
      var bias2 = [-0.519191231929289,-0.416998541310403,-1.08903780700255,1.17378127964339,-0.0000000248373215571518,0.0000000254489612916298,0.0000000231294090990728];
      /*we compute the output values for the  network*/
      var output = [0,0,0,0,0,0,0];
      for (i=0; i<7; i++){
          for (j=0; j<6; j++){
              output[i] += hidden[j]*weights2[i*6+j];
          }
          output[i] = output[i]+bias2[i];
          output[i] = 1/(1+Math.pow(Math.E, -output[i]));
          output[i] = Math.round(output[i]);
      }
      
      console.log("NeuNet output: "+output[0]+", "+output[1]+", "+output[2]+", "+output[3]+", "
      +output[4]+", "+output[5]+", "+output[6]+", ");
      
      /*we return the values*/
      response.turnLeft = output[0];
      response.turnRight = output[1];
      response.goForward = output[2];
      response.goBack = output[3];
      response.shoot = output[4];
      response.cannonLeft = output[5];
      response.canoonRight = output[6];


      self.postMessage(response);
  }