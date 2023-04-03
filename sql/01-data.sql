--
-- Accounts for test server
--
-- 356a192b7913b04c54574d18c28d46e6395428ab = 1
--
INSERT INTO `accounts`
    (`id`, `name`, `email`, `password`, `type`, `coins`) 
VALUES
    (101, 'test1', '@b'  , '356a192b7913b04c54574d18c28d46e6395428ab', 1, 10000),
    (102, 'test2', '@b'  , '356a192b7913b04c54574d18c28d46e6395428ab', 1, 10000),
    (103, 'test3', '@c'  , '356a192b7913b04c54574d18c28d46e6395428ab', 1, 10000);

INSERT INTO `players`
    (`id`,`name`,`group_id`,`account_id`,`level`,
    `vocation`, `health`, `healthmax`, `experience`,
    `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`,
    `mana`, `manamax`, `town_id`, `conditions`, `cap`, `sex`) 
VALUES
    (0, 'ADM1', 6, 101, 1500, 3, 150, 150, 0, 106, 95, 78, 116, 128, 5, 5, 8, '', 400, 1),
    (0, 'ADM2', 6, 102, 1500, 3, 150, 150, 0, 106, 95, 78, 116, 128, 5, 5, 8, '', 400, 1),
    (0, 'ADM3', 6, 103, 1500, 3, 150, 150, 0, 106, 95, 78, 116, 128, 5, 5, 8, '', 400, 1);
