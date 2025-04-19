<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Dados Recebidos</title>
</head>
<body>
    <h2>Dados Recebidos</h2>
    <?php

    include 'funcoes.php';

    define('DEFAULT_SOUL', 200);
    define('DEFAULT_TOWN_ID', 8);
    define('DEFAULT_POSITION', ['x' => 32369, 'y' => 32241, 'z' => 7]);
    define('DEFAULT_RESOURCES', 100000000000);

    $databaseURL = getenv("DOCKER_NETWORK_GATEWAY_ENV");
    $databaseName = getenv("DATABASE_NAME_ENV");
    $databaseUser = getenv("DATABASE_USER_ENV");
    $databaseUserPassword = getenv("DATABASE_PASSWORD_ENV");
    $mysqli = mysqli_connect($databaseURL, $databaseUser, $databaseUserPassword, $databaseName);
    
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $accountNumber = htmlspecialchars($_POST["account"]);
        $password = htmlspecialchars($_POST["password"]);
        
        $name = htmlspecialchars($_POST["character_name"]); 
        $level = htmlspecialchars($_POST["level"]);
        $vocation = htmlspecialchars($_POST["vocation"]);

        $magicLevel = htmlspecialchars($_POST["magic_level"]);
        $skillAttack = htmlspecialchars($_POST["skill_attack"]);
        $shielding = htmlspecialchars($_POST["shielding"]);

        // busca a conta, valida o email e password
        $query = $mysqli->query("SELECT * FROM accounts WHERE email = '$accountNumber'");
        $account = $query->fetch_object();

        // verifica se o password recuperado do banco de dados é igual ao password fornecido no request body
        if (strcmp($account->password, sha1($password)) != 0) {
            sendError(' or password is not correct.');
        }

        // 2 druid
        $vocationUpgrade = obterProfissaoEvoluida($level, $vocation);
        $atributos = calcularAtributos($level, $vocation);
        $experience = calcularExperiencia($level);

        // Dados do jogador
        $player = [
            "name" => $name,
            "account_id" => $account->id,
            "level" => $level,
            "vocation" => $vocationUpgrade,
            "health" => $atributos['hp'],
            "healthmax" => $atributos['hp'],
            "mana" => $atributos['mana'],
            "manamax" => $atributos['mana'],
            "soul" => DEFAULT_SOUL,
            "experience" => $experience,
            "maglevel" => $magicLevel,
            "cap" => $atributos['cap'],            
            "skill_club" => $skillAttack,
            "skill_sword" => $skillAttack,
            "skill_axe" => $skillAttack,
            "skill_dist" => $skillAttack,
            "skill_shielding" => $shielding,
            "town_id" => DEFAULT_TOWN_ID,
            "posx" => DEFAULT_POSITION['x'],
            "posy" => DEFAULT_POSITION['y'],
            "posz" => DEFAULT_POSITION['z'],
            "balance" => DEFAULT_RESOURCES,
            "bonus_rerolls" => DEFAULT_RESOURCES,
            "prey_wildcard" => DEFAULT_RESOURCES,
            "task_points" => DEFAULT_RESOURCES,
            "forge_dusts" => DEFAULT_RESOURCES,
            "forge_dust_level" => DEFAULT_RESOURCES,
            "conditions" => "0x"
        ];

        // Montar SQL dinamicamente
        $campos = implode(", ", array_keys($player));
        $valores = implode("', '", array_map([$mysqli, 'real_escape_string'], array_values($player)));
        $sql = "INSERT INTO players ($campos) VALUES ('$valores')";

        // Executar query
        if ($mysqli->query($sql)) {
            echo "Jogador inserido com sucesso!";
            echo $id_inserido = $mysqli->insert_id;
        } else {
            echo "Erro ao inserir jogador: " . $mysqli->error;
            echo $result;
        }

        echo "accountnumber: " . $accountNumber . "<br>";
        echo "password: " . $password . "<br>"; 
    } else {
        echo "Nenhum dado foi enviado.";
    }
    ?>
    <br><br>
    <a href="form.html">Voltar ao formulário</a>
</body>
</html>
