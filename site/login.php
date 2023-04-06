<?php

// as informações do banco de dados são preenchidas automaticamente
// quando o script `start.sh` é iniciado
$databaseURL = "192.168.128.1";
$databaseUser = "otserv";
$databaseUserPassword = "noob";
$databaseName = "otservdb";
$mysqli = mysqli_connect($databaseURL,$databaseUser, $databaseUserPassword, $databaseName);

$request = json_decode(file_get_contents('php://input'));
file_put_contents('00_resquestBody.json', json_encode($request));

$current_password = sha1($request->password);
$characters = [];

// buscar conta, validar email e password
$query = $mysqli->query("SELECT * FROM accounts WHERE email = '$request->email'");
$account = $query->fetch_object();
file_put_contents('01_account.json', json_encode($account));

if (strcmp($account->password, $current_password) != 0) {
	sendError(($request->email != false ? 'Email' : 'Account name') . ' or password is not correct.');
}

// buscar characters da conta e definir o main char
$columns = 'id, name, level, sex, vocation, looktype, lookhead, lookbody, looklegs, lookfeet, lookaddons';
$query = $mysqli->query("SELECT {$columns} FROM players WHERE account_id =  '$account->id' AND deletion = 0");
if($query) {
	$players = $query->fetch_all(MYSQLI_BOTH);

	$highestLevelId = 0;
	$highestLevel = 0;
	foreach ($players as $player) {
		if ($player['level'] >= $highestLevel) {
			$highestLevel = $player['level'];
			$highestLevelId = $player['id'];
		}
	}

	foreach ($players as $player) {
		$characters[] = create_char($player, $highestLevelId);
	}
	file_put_contents('02_characters.json', json_encode($characters));
}

$worlds = [[
	'id' => 0,
	'name' => getenv("OT_SERVER_NAME"),
	'externaladdress' => getenv("DOCKER_NETWORK_GATEWAY"),
	'externalport' => 7172,
	'externaladdressprotected' => getenv("DOCKER_NETWORK_GATEWAY"),
	'externalportprotected' => 7172,
	'externaladdressunprotected' => getenv("DOCKER_NETWORK_GATEWAY"),
	'externalportunprotected' => 7172,
	'previewstate' => 0,
	'location' => 'BRA',
	'anticheatprotection' => false,
	'pvptype' => "pvp",
	'istournamentworld' => false,
	'restrictedstore' => false,
	'currenttournamentphase' => 2
]];

$session = [
	'sessionkey' => $request->email."\n".$request->password,
	'lastlogintime' => 0,
	'ispremium' => true,
	'premiumuntil' => 0,
	'status' => 'active',
	'returnernotification' => false,
	'showrewardnews' => false,
	'isreturner' => true,
	'fpstracking' => false,
	'optiontracking' => false,
	'tournamentticketpurchasestate' => 0,
	'emailcoderequest' => false
];
file_put_contents('03_session_key.json', json_encode($session));

$playdata = compact('worlds', 'characters');
$responseBody = compact('session', 'playdata');
file_put_contents('04_responseBody.json', json_encode($responseBody));
die(json_encode($responseBody));

function create_char($player, $highestLevelId) {
	$vocations = [
		"1" => "Sorcerer",
		"2" => "Druid",
		"3" => "Paladin",
		"4" => "Knight",
		"5" => "Master Sorcerer",
		"6" => "Elder Druid",
		"7" => "Royal Paladin",
		"8" => "Elite Knight"
	];

	return [
		'worldid' => 0,
		'name' => $player['name'],
		'ismale' => intval($player['sex']) === 1,
		'tutorial' => isset($player['istutorial']) && $player['istutorial'],
		'level' => intval($player['level']),
		'vocation' => ($vocations[$player['vocation']]) ?? 'No Vocation',
		'outfitid' => intval($player['looktype']),
		'headcolor' => intval($player['lookhead']),
		'torsocolor' => intval($player['lookbody']),
		'legscolor' => intval($player['looklegs']),
		'detailcolor' => intval($player['lookfeet']),
		'addonsflags' => intval($player['lookaddons']),
		'ishidden' => isset($player['deletion']) && (int)$player['deletion'] === 1,
		'istournamentparticipant' => false,
		'ismaincharacter' => $highestLevelId == $player['id'],
		'dailyrewardstate' => isset($player['isreward']) ? intval($player['isreward']) : 0,
		'remainingdailytournamentplaytime' => 0
	];
}

function sendError($message, $code = 3){
	$ret = [];
	$ret['errorCode'] = $code;
	$ret['errorMessage'] = $message;
	die(json_encode($ret));
}
