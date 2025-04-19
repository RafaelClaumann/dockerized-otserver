<?php

// Função para obter a profissão evoluída
function obterProfissaoEvoluida(int $level, int $vocation_id): int {
    if ($level > 20) {
        switch ($vocation_id) {
            case 1: return 5; // Master Sorcerer
            case 2: return 6; // Elder Druid
            case 3: return 7; // Royal Paladin
            case 4: return 8; // Elite Knight
            default: throw new Exception("Vocação inválida: $vocation_id");
        }
    }
    return $vocation_id;
}

function calcularAtributos(int $level, int $vocation_id): array {
    if ($level < 8) {
        throw new Exception("O level mínimo para calcular atributos corretamente é 8.");
    }

    // vocation_id => [vidaPorNivel, manaPorNivel, capPorNivel]
    $atributos = [
        1 => [5, 30, 10],  // Sorcerer
        2 => [5, 30, 10],  // Druid
        3 => [10, 15, 20], // Paladin
        4 => [15, 5, 25],  // Knight
    ];

    if (!isset($atributos[$vocation_id])) {
        throw new Exception("Vocação inválida: $vocation_id");
    }

    [$vidaPorNivel, $manaPorNivel, $capPorNivel] = $atributos[$vocation_id];
    $offset = $level - 8;

    $hp_base = 185;
    $mana_base = 90;
    $cap_base = 470;

    return [
        'hp' => $hp_base + $vidaPorNivel * $offset,
        'mana' => $mana_base + $manaPorNivel * $offset,
        'cap' => $cap_base + $capPorNivel * $offset
    ];
}

function calcularExperiencia(int $level): int {
    if ($level < 1) {
        return 0;
    } elseif ($level == 1) {
        return 0;
    } elseif ($level == 2) {
        return 100;
    } else {
        return ((50 / 3) * pow($level, 3) - 100 * pow($level, 2) + (850 / 3) * $level - 200);
    }
}
?>
