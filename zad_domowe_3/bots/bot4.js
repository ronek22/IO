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


    /*Simple neural network*/
    /*we want our tank only to move around the field*/

    /*let's take input layer with 3 neurons - extracted from game data*/
    var input = [me.x, me.y, me.rotation, me.canoonRotation,
        me.velocityX, me.velocityY, me.shootCooldown,
        enemy.x, enemy.y, enemy.rotation,
        enemy.cannonRotation, enemy.velocityX,
        enemy.velocityY, enemy.shootCooldown, time
    ];

    /*is it a good idea to normalize the inputs here?*/
    input = [me.x / 500.0,
        me.y / 500.0,
        angle(me.rotation),
        angle(me.cannonRotation),
        norm(me.velocityX),
        norm(me.velocityY),
        me.shootCooldown / 100.0,
        enemy.x / 500.0,
        enemy.y / 500.0,
        angle(enemy.rotation),
        angle(enemy.cannonRotation),
        norm(enemy.velocityX),
        norm(enemy.velocityY),
        enemy.shootCooldown / 100.0,
        time / 40000.0
    ];
    console.log("TEST: " + enemy.rotation + ', ' + enemy.cannonRotation)

    console.log("NeuNet input: " + input[0] + ", " + input[1] + ", " + input[2] + ", " + input[3] + ", " +
        input[4] + ", " + input[5] + ", " + input[6] + ", " + input[7] + ", " + input[8] + ", " + input[9] + ", " +
        input[10] + ", " + input[11] + ", " + input[12] + ", " + input[13] + ", " + input[14]);

    /*we take 3 hidden neurons*/
    /*from every input neuron there is a connection to every hidden neuron (3 connections), so we need 9 weights; and 3 for bias*/
    var weights1 = [-0.732, -0.363, 1.031, 0.011, 2.037, 1.471, -0.383, -0.321, -0.311, -0.041, -0.182, 0.122, -0.175, -0.065, 0.442, 9.042, 2.422, 0.685, -0.624, -15.5, -14.853, 1.27, 14.111, 3.067, 0.076, 1.242, 0.21, 5.909, 0.948, -4.602, 0.184, -0.151, 5.081, -1.747, 3.043, -0.315, -0.497, 1, 0.235, -1.251, -0.408, -1.252, -0.092, -0.18, 0.054, -0.454, -1.084, 4.582, 1.041, 2.438, 4.191, -2.406, 0.887, -0.714, -0.674, -0.534, 0.541, 0.448, -0.189, -0.727, -2.013, 0.071, -4.709, -1.289, 4.972, 5.667, 2.208, -3.588, -0.511, 0.776, 0.108, -0.09, -1.896, 0.151, 2.09, 41.321, 17.354, -9.108, -7.836, -5.414, -26.214, 16.284, 28.212, 36.331, -17.102, -2.708, -11.829, 8.926, 2.538, -7.171];
    var bias1 = [-1.776, -7.919, -5.478, -1.963, -2.539, -11.342];

    /*we compute the output values for hidden neurons*/
    var hidden = [0, 0, 0, 0, 0, 0];
    var i, j;
    for (i = 0; i < 6; i++) {
        for (j = 0; j < 15; j++) {
            hidden[i] += input[j] * weights1[i * 15 + j];
        }
        hidden[i] = hidden[i] + bias1[i];
        hidden[i] = 1 / (1 + Math.pow(Math.E, -hidden[i]));
    }

    console.log("NeuNet hidden: " + hidden[0] + ", " + hidden[1] + ", " + hidden[2] + hidden[3] + ", " + hidden[4] + ", " + hidden[5] + ", ");

    /*we consider 4 outputs each corresponding to a control-key: turnLeft, turnRight, goForward, goBack - so we need 3*4=12 additional weights + 4 bias*/
    var weights2 = [0.892, 0.37, -0.238, -0.171, -0.166, -0.879, 0.918, 0.229, -0.53, -0.133, -0.166, 0.247, -1.983, 0.788, 2.895, 1.78, 1.757, 0.123, 4.912, 0.627, -3.209, -1.751, -1.198, 0.243, -0.129, -0.082, 0.118, -0.192, 0.008, -0.023, -0.711, -0.191, 0.043, 0.323, -0.042, -0.038, -0.409, -0.106, 0.127, 0.125, 0.013, -0.009];
    var bias2 = [0.785, -0.352, -1.242, -0.111, 0.252, 0.138, 0.102];
    /*we compute the output values for the  network*/
    var output = [0, 0, 0, 0, 0, 0, 0];
    for (i = 0; i < 7; i++) {
        for (j = 0; j < 6; j++) {
            output[i] += hidden[j] * weights2[i * 6 + j];
        }
        output[i] = output[i] + bias2[i];
        output[i] = 1 / (1 + Math.pow(Math.E, -output[i]));
        output[i] = Math.round(output[i]);
    }

    console.log("NeuNet output: " + output[0] + ", " + output[1] + ", " + output[2] + ", " + output[3] + ", " +
        output[4] + ", " + output[5] + ", " + output[6] + ", ");

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