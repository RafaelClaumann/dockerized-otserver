<?php

    // $request = json_decode(file_get_contents('php://input'));
    // echo json_encode($request);

    // file_put_contents('/var/www/html/request.json', json_encode($request));

    $env_array =getenv();
    foreach ($env_array as $key=>$value){
        echo "$key => $value <br />";
    }

    $serverName = getenv("OT_SERVER_NAME");
    echo nl2br("Server Name: ". $serverName ."\n");

    $serverIP = getenv("DOCKER_NETWORK_GATEWAY");
    echo nl2br("Server IP: ". $serverIP ."\n");
 ?>
 