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

    var input = [
        me.x / 500.0,
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


    var weights1 = [2.29058677797653, -0.08946860952126, 9.99399614495675, -1.33178326224656, 0.857900508161698, -0.516384624780032, -0.0908724742622095, 0.936819657305585, -2.03231502523353, -0.511818479829598, 0.0689213592757244, 1.0101921773496, -0.1507767338743, -0.127601630235749, -0.298544517741484, -11.1752901726276, 4.48287363153704, -51.1451060327243, -2.89509814344632, 21.9423622329138, 66.171210230618, 0.125501034632887, -27.2538901017661, 4.09341608902201, 1.42044568618771, -0.385856846278664, -3.77174067773641, -15.5658914503806, 1.57460496993323, 2.28173861591527, 1.86249852555955, 0.88778176156249, 2.23168259069072, -0.0743015837754327, -1.03827259104424, -4.54467297500306, -0.00612578742137635, 0.979123136443268, 0.679523791569655, -0.250757043269536, 0.0121716188177088, -0.498471375955463, 0.162188832207776, -0.0664587198044712, -0.996948648099086, -1.36075439032838, -3.23326675788328, -11.6390961481031, 2.58075407908106, 1.20378744570044, 3.74668366768772, -2.21382746821924, 5.46399648703615, 3.67404989519915, 0.49081588505481, -0.296637600497655, -1.28171847896868, 2.91175583587431, 0.163268695654485, 3.12665564034279, 69.3507360185658, -4.72817387617687, -1706.51048555667, 21.4451406085454, 0.569270861826502, -63.4557685601821, -1827.653970962, 19.0527510488782, -4.78605900855103, -9.17916315585989, -3.12894496320253, 6.95717928999334, 5.35042885794693, 2.95823640405605, -127.4893867454, 1.30141414901975, 1.31350320468102, -1.09290545805733, -0.0304532323886525, -1.30649430351709, -7.20360624131944, 0.180535560137334, 1.20566034397922, 1.35467885305122, 0.0855811544610928, 0.0856477640191911, -0.94485089614111, 0.511900757012525, -0.053084011344379, -0.564867259943083];
    var bias1 = [-4.32928356558853, -23.3233090892471, -2.08333517957532, -2.58547257820704, -1.23321665812728, -0.495637845408008];
    var hidden = [0, 0, 0, 0, 0, 0];

    var i, j;
    for (i = 0; i < 6; i++) {
        for (j = 0; j < 15; j++) {
            hidden[i] += input[j] * weights1[i * 15 + j];
        }
        hidden[i] = hidden[i] + bias1[i];
        hidden[i] = 1 / (1 + Math.pow(Math.E, -hidden[i]));
    }


    var weights2 = [2.19709545686779, 0.0106033667937913, 0.271637060421666, 2.00772829368151, -0.0202460925635343, 0.201210221013613, 0.320844256078875, 0.0649710400772351, -0.154195071154864, 0.202725343843732, -0.0254397102920071, 0.296952422161052, 0.417979685734683, 0.888971488702631, 4.0418128020301, 0.957693445364458, -0.0783531175030324, -2.02691804825155, 2.43324347632613, 0.0336784518238581, -3.91781315187952, 1.43613104121799, -0.00679643710683454, 3.30688357758669, -0.29953999351893, -0.0544348978096692, -0.254687646311684, -0.311374673996454, -0.0766491505041945, 0.0780440099567041, -0.167418604797906, -0.0378840786196073, -0.0351725806188765, -0.176038639069458, 1.0005437044856, -0.0435869568086044, -0.229293604826379, -0.0622065254429072, 0.124759730164146, -0.160737872630737, -0.0587831640841422, -0.166189555517421];
    var bias2 = [-2.03835146480323, -0.210490752622317, -0.888150219941015, -1.62114382509234, 0.382650753392795, 0.218689163784244, 0.242142936108119];
    var output = [0, 0, 0, 0, 0, 0, 0];

    for (i = 0; i < 7; i++) {
        for (j = 0; j < 6; j++) {
            output[i] += hidden[j] * weights2[i * 6 + j];
        }
        output[i] = output[i] + bias2[i];
        output[i] = 1 / (1 + Math.pow(Math.E, -output[i]));
        output[i] = Math.round(output[i]);
    }

    response.turnLeft = output[0];
    response.turnRight = output[1];
    response.goForward = output[2];
    response.goBack = output[3];
    response.shoot = output[4];
    response.cannonLeft = output[5];
    response.canoonRight = output[6];


    self.postMessage(response);
}