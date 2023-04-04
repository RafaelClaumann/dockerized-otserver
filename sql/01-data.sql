--
-- Accounts for test server
--
-- 356a192b7913b04c54574d18c28d46e6395428ab = 1
--
INSERT INTO `accounts`
    (`id`, `name`, `email`, `password`, `type`, `coins`) 
VALUES
    (100, 'test0', '@a', '356a192b7913b04c54574d18c28d46e6395428ab', 1, 100000000),
    (101, 'test1', '@b', '356a192b7913b04c54574d18c28d46e6395428ab', 1, 10000),
    (102, 'test2', '@c', '356a192b7913b04c54574d18c28d46e6395428ab', 1, 10000),
    (103, 'test3', '@d', '356a192b7913b04c54574d18c28d46e6395428ab', 1, 10000);

INSERT INTO `players`
    (`id`,`name`,`group_id`,`account_id`,`level`,
    `vocation`, `health`, `healthmax`, `experience`,
    `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`,
    `mana`, `manamax`, `town_id`, `conditions`, `cap`, `sex`) 
VALUES
    (0, 'ADM1', 6, 101, 1500, 0, 150, 150, 0, 113, 95, 78, 116, 75, 5, 5, 3, '', 400, 1),
    (0, 'ADM2', 6, 102, 1500, 0, 150, 150, 0, 113, 95, 78, 116, 75, 5, 5, 3, '', 400, 1),
    (0, 'ADM3', 6, 103, 1500, 0, 150, 150, 0, 106, 95, 78, 116, 75, 5, 5, 3, '', 400, 1);

INSERT INTO `players`
    (`id`, `name`, `group_id`, `account_id`,
    `level`, `vocation`, `health`, `healthmax`,
    `experience`,`maglevel`,`mana`, `manamax`,
    `soul`, `town_id`, `cap`, `sex`, `balance`,
    `skill_dist`, `skill_shielding`, `prey_wildcard`, `forge_dusts`,
    `forge_dust_level`, `conditions`)
VALUES
    (0, 'Paladin', 1, 100,
    800, 7, 8105, 8105,
    8469559800, 37, 11920, 11920, 
    200, 8, 16310, 1, 100000000,
    140, 106, 50, 215,
    215, '');

INSERT INTO `players`
    (`id`, `name`, `group_id`, `account_id`,
    `level`, `vocation`, `health`, `healthmax`,
    `experience`,`maglevel`,`mana`, `manamax`,
    `soul`, `town_id`, `cap`, `sex`, `balance`,
    `skill_shielding`, `prey_wildcard`, `forge_dusts`, `forge_dust_level`, `conditions`)
VALUES
    (0, 'Sorcerer', 1, 100,
    800, 5, 4145, 4145,
    8469559800, 120, 23800, 23800, 
    200, 8, 8390, 1, 100000000,
    43, 50, 215, 215, '');

INSERT INTO `players`
    (`id`, `name`, `group_id`, `account_id`,
    `level`, `vocation`, `health`, `healthmax`,
    `experience`,`maglevel`,`mana`, `manamax`,
    `soul`, `town_id`, `cap`, `sex`, `balance`,
    `skill_shielding`, `prey_wildcard`, `forge_dusts`, `forge_dust_level`, `conditions`)
VALUES
    (0, 'Druid', 1, 100,
    800, 5, 4145, 4145,
    8469559800, 120, 23800, 23800, 
    200, 8, 8390, 1, 100000000,
    43, 50, 215, 215, '');

INSERT INTO `players`
    (`id`, `name`, `group_id`, `account_id`,
    `level`, `vocation`, `health`, `healthmax`,
    `experience`,`maglevel`,`mana`, `manamax`,
    `soul`, `town_id`, `cap`, `sex`, `balance`,
    `skill_club`, `skill_sword`, `skill_axe`, `skill_shielding`,
    `prey_wildcard`, `forge_dusts`, `forge_dust_level`, `conditions`)
VALUES
    (0, 'Knight', 1, 100,
    800, 8, 12065, 12065,
    8469559800, 14, 4000, 4000, 
    200, 8, 20270, 1, 100000000,
    130, 130, 130, 112,
    50, 215, 215, '');
