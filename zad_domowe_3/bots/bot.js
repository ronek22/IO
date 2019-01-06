function (e) {

    function angle(x) {
        return (x % 360) / 360.0;
    }

    function norm(x) {
        return (x + 15) / 30.0;
    }

    var response = {};
    var enemy = e.data.enemyTank;
    var me = e.data.myTank;
    var time = e.data.currentGameTime
    var ebx = 0
    var eby = 0
    var ebvx = 0
    var ebvy = 0
    if(enemy.bullets[0] !== undefined){
        ebx = enemy.bullets[0].x
        eby = enemy.bullets[0].y
        ebvx = enemy.bullets[0].velocityX
        ebvy = enemy.bullets[0].velocityY
    }


    /*Simple neural network*/
    /*we want our tank only to move around the field*/

    /*let's take input layer with 3 neurons - extracted from game data*/
    var input = [me.x, me.y, me.rotation, me.canoonRotation,
        me.velocityX, me.velocityY, me.shootCooldown,
        enemy.x, enemy.y, enemy.rotation,
        enemy.cannonRotation, enemy.velocityX,
        enemy.velocityY, enemy.shootCooldown,
        ebx, eby, ebvx, ebvy, time
    ];

    /*is it a good idea to normalize the inputs here?*/
    input = [me.x / 500.0, me.y / 500.0, angle(me.rotation),
        angle(me.cannonRotation), norm(me.velocityX), norm(me.velocityY),
        me.shootCooldown / 100.0,
        enemy.x / 500.0, enemy.y / 500.0, angle(enemy.rotation),
        angle(enemy.cannonRotation), norm(enemy.velocityX), norm(enemy.velocityY),
        enemy.shootCooldown / 100.0, ebx / 500.0,
        eby / 500.0, norm(ebvx),
        norm(ebvy), time / 40000.0
    ];

    console.log("NeuNet input: " + input[0] + ", " + input[1] + ", " + input[2]);

    /*we take 3 hidden neurons*/
    /*from every input neuron there is a connection to every hidden neuron (3 connections), so we need 9 weights; and 3 for bias*/
    var weights1 = [-11.4819938659255, -2.49899017313104, 0.482922773151736, 2.23425759888535, 27.3548795678712, 0.900471203266926, -6.57094072235973, -4.58937576354113, -2.65426278524139, 4.83219664451191, -2.88040169775577, 1.48423233785759, 0.356459786739721, -0.209854726424158, -0.195042594454347, 0.258510043427912, 2.46280077503692, -1.10962818552577, 0.808669482465152, 0.809045849261132, 42.4166203661838, -0.615102523777608, -5.1587093090839, -3.22185808914109, 2.99055083252761, 233.015954222692, -9.3875297690066, 15.5841585161098, -0.71553232557881, -0.536443287908999, -5.71095140949697, 8.05420311374058, 1.67810271064358, -5.86211693270203, 0.649856868657836, -11.1025333701361, -0.682654578378602, -12.0250076192186, 28.2623639351778, -20.8249830175616, -22.197006999222, 44.9979777920122, 17.1475410788833, 30.4887979031523, -4.74966030324582, -10.2625393477079, -24.4041697738848, 0.503330229409653, 2.54672481438139, -14.6402720582207, 17.2084552193731, -2490.62240671472, 17.0182418080064, -22.0477399721438, -4.2399551370682, 2.48546675267442, -4.23683713005019, -28.8884480983015, -4.90858796390884, 11.6980473087862, -15.3936102641367, 39.3956382382959, -0.713523835852998, 6.97954113297386, 5.07783346934835, 2.91879370121149, -3.64997498352835, -5.59010222867795, 11.0281289064384, 15.4439910473752, -5.54357404804572, -2.16249370162747, 9.41998549302441, -2.92290315662412, -13.757299604969, -11.9240964761497, -15.5895342643651, 82.0511301302165, 5.99830104502751, -27.4140727533374, 9.19282705013764, -8.85358811419329, 3725.55570077448, -3.5151717779085, 5.04810987988918, -8.36364714827805, 3.40141421059634, 5.9691903131779, 15.7019399477324, 25.5042099327117, 4.83153602743704, -41.9043276871181, -44.2439774134557, -11.9366065821438, -44.0499370416481, -87.5058943999045, -19.8810220793853, 0.192654174915339, 123.575402528497, 42.9618821497345, 41.9859712360542, 1.46241150568041, 18.6081653313962, -1.95885746887083, -9.67366506064183, -3.47267772106466, 11.1076348883848, -0.027342141807849, 2.28139236061718, 8.21401456909166, -3.81596153659714, 1.76109363633678, 35.4733767971693, -4.45474695517898];
    var bias1 = [-11.0653216579193, -1.94107655836876, -40.3776881553521, 6.17682318784192, 24.3262211375423, -21.14777493287];

    /*we compute the output values for hidden neurons*/
    var hidden = [0, 0, 0, 0, 0, 0];
    var i, j;
    for (i = 0; i < 6; i++) {
        for (j = 0; j < 19; j++) {
            hidden[i] = input[j] * weights1[i * 19 + j];
        }
        hidden[i] = hidden[i] + bias1[i];
        hidden[i] = 1 / (1 + Math.pow(Math.E, -hidden[i]));
    }

    console.log("NeuNet hidden: " + hidden[0] + ", " + hidden[1] + ", " + hidden[2]);

    /*we consider 4 outputs each corresponding to a control-key: turnLeft, turnRight, goForward, goBack - so we need 3*4=12 additional weights + 4 bias*/
    var weights2 = [0.0685945570187761, 1.10928453631065, -0.0570918622451491, 0.0472870622862743, -0.846068378550683, 0.0376736946124426, 0.0666766118863663, -0.927353888362604, -0.0645819468014621, -0.233192043336851, 0.240041956781834, -0.0796138324635714, 0.892183440240559, 0.132452821458162, -0.983517768454075, -0.866224115538292, -0.0844404623473201, 0.0889950449832232, -0.0225538640059182, 0.00908145333678202, 0.942405347790253, 0.0255749418166423, 0.0135521732375519, -0.856560435533574, -0.0408773472629812, 0.0234844219906714, 0.016233626094483, 0.0242144323758584, 0.0290277951855886, 0.053261098815805, -0.0276517297475534, -0.0429450006891959, 0.00125067374048894, 0.0257747167304869, 0.00641926224777135, 0.0264975310577193, -0.0500251618927821, 0.0110702347342175, -0.00739589807316004, 0.0550189939654176, 0.0100120931243831, 0.056680809274171];
    var bias2 = [-0.258060658285262, 1.04740698272128, 0.795221652935013, 0.838499922283166, -0.0773985691998281, 0.00996897221466907, -0.0766423606685972]; // do przodu

    /*we compute the output values for the  network*/
    var output = [0, 0, 0, 0, 0, 0, 0];
    for (i = 0; i < 7; i++) {
        for (j = 0; j < 6; j++) {
            output[i] = hidden[j] * weights2[i * 6 + j];
        }
        output[i] = output[i] + bias2[i];
        output[i] = 1 / (1 + Math.pow(Math.E, -output[i]));
        output[i] = Math.round(output[i]);
    }

    console.log("NeuNet output: " + output[0] + ", " + output[1] + ", " + output[2] + ", " + output[3]);

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