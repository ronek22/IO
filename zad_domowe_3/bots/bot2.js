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
      var weights1 = [1.25403007938212,2.65712559651255,1.85407858453114,-3.84651497192361,0.192136787461116,0.637320019226538,-1833.83135327146,6.42039651410756,2.83235845806417,0.954238128678038,0.295787444665716,0.163425858934765,-0.429963647835727,0.0241035092055244,-1.7597152378825,2.18415658766255,19.2748855663156,6.62537605409822,30.3759818009109,-21.3863605040979,-12.8676657725059,-1841.18399926248,-7.42016781254882,-6.6517729450929,-11.9858802989549,2.29349231384731,-2.88061656595565,-2.2654295368883,-0.787369720424647,5.40434407265049,9.21537497930256,-20.6869805169494,28.7823552571187,8.50240913111238,-16.2339013732746,11.9118011263149,-1.27921270207611,2.2708971829774,-6.75277696495182,-0.429179285562491,0.430533273206695,-0.143974987937844,1.37904715231826,0.467442025153638,-4.59717428544446,-0.0471033437353719,0.554558059453635,-5.34097485043373,6.84724341535842,-0.531931149668605,-0.806311081583921,-0.0752704853576074,-2.84161645111059,-1.10786834975768,-0.712873775191413,-0.0187600356528948,-0.457845014960103,-0.00571643660511207,-0.0167335068756771,1.78064966138562,-11.1088946002486,14.3936938611597,0.214369188967707,-24.673988101189,-7.26589917545048,-5.07326290721703,22.489995154403,-5.10211017269,13.7331675664729,0.398206118801626,-0.958668614713086,1.25899420386892,-2.31748200159584,2.17654163172693,3.94894601346163,12.4439208046983,3.95352005984619,-2.72124486096773,-12.3819097806053,12.6464154139167,-1.8922468557505,755.622569269434,19.752204836008,-11.8471798180141,4.36363495924339,-1.82441631507145,6.31126287801874,9.73231532277282,5.13376698000709,16.5316280510155];
      var bias1 = [-5.78558790982195,-15.411522386142,-21.7107278536005,1.34240079717244,-1.15475087981698,-18.4516960502461];

      /*we compute the output values for hidden neurons*/
      var hidden = [0,0,0,0,0,0];
      var i,j;
      for (i=0; i<6; i++){
          for (j=0; j<15; j++){
              hidden[i] = input[j]*weights1[i*15+j];
          }
          hidden[i] = hidden[i]+bias1[i];
          hidden[i] = 1/(1+Math.pow(Math.E, -hidden[i]));
      }
      
      console.log("NeuNet hidden: "+hidden[0]+", "+hidden[1]+", "+hidden[2]+hidden[3]+", "+hidden[4]+", "+hidden[5]+", ");
      
      /*we consider 4 outputs each corresponding to a control-key: turnLeft, turnRight, goForward, goBack - so we need 3*4=12 additional weights + 4 bias*/
      var weights2 = [2.1137484726479,-0.684785206037528,-0.214102248639429,3.13397283626517,-0.449203598953918,0.295541711847786,-0.211830539893392,0.228160453990733,-0.193553424837256,-0.437741401816872,-0.0791123462367131,-1.12188434589341,0.542314968972672,0.573916412836503,-0.7715577366384,-0.427663696488393,-1.08663533460984,-0.0955385718186547,0.0450145773839521,-0.0664804690172749,0.864763447092393,0.114345331710196,0.0519398784229245,-0.0443591270875654,-0.129420520073553,-0.00303086008232771,-0.00533312627972551,-0.142929329514471,0.0167266837779824,0.0111491132225039,-0.0831244628049494,-0.0101851227709464,0.0196281745737015,-0.0799680580850768,0.0760777331098913,0.00749404408299115,-0.0034714869103062,-0.000566227757246492,0.00140403100145395,-0.00245626754702345,0.0255083132340714,0.000894457623706686];
      var bias2 = [-2.28822832139502,1.47227227262172,0.676289880434613,-0.0176043300242494,0.125422335188258,0.076379733508981,0.00213424766532471];
      /*we compute the output values for the  network*/
      var output = [0,0,0,0,0,0,0];
      for (i=0; i<7; i++){
          for (j=0; j<6; j++){
              output[i] = hidden[j]*weights2[i*6+j];
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