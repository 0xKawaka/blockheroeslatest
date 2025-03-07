// #[cfg(test)]
// pub mod tests {
//     use starknet::class_hash::Felt252TryIntoClassHash;
//     use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
//     use dojo::utils::test::{spawn_test_world, deploy_contract};

//     use game::systems::game::{Game, IGameDispatcher, IGameDispatcherTrait};
//     // use game::systems::settings::{Settings, ISettingsDispatcher, ISettingsDispatcherTrait};
//     use game::systems::settings::{Settings, Settings::initSettings};
//     use game::models::map::{MapTrait, Map};
//     use game::models::account::{heroes::{heroes, Heroes}, runes::{runes, Runes}};
//     use game::models::account::{Account, AccountImpl, AccountTrait, account};
//     use game::models::storage::{baseHero::base_hero};
//     use game::models::storage::skill::{skillBuff::skill_buff, skillInfos::skill_infos, skillNameSet::skill_name_set};
//     use game::models::storage::arena::{arenaAccount::arena_account, arenaConfig::arena_config, arenaCurrentRankIndex::arena_current_rank_index, arenaTeam::arena_team, enemyRanges::enemy_ranges, gemsRewards::gems_rewards};
//     use game::models::storage::{mapProgress::map_progress};
//     use game::models::storage::battles::{arenaBattleStorage::arena_battle_storage, battleStorage::battle_storage, entityStorage::entity_storage, healthOnTurnProcStorage::health_on_turn_proc_storage, turnTimelineStorage::turn_timeline_storage};
//     use game::models::storage::level::{levelEnemy::level_enemy, levelInfos::level_infos};
//     use game::models::storage::statistics::{bonusRuneStatistics::bonus_rune_statistics, runeStatistics::rune_statistics};

//     #[test]
//     #[available_gas(900000000000)]
//     fn test_game() {
//         let caller = starknet::contract_address_const::<0x0>();
//         let mut models = array![
//             base_hero::TEST_CLASS_HASH,
//             heroes::TEST_CLASS_HASH, runes::TEST_CLASS_HASH, account::TEST_CLASS_HASH,
//             skill_buff::TEST_CLASS_HASH, skill_infos::TEST_CLASS_HASH, skill_name_set::TEST_CLASS_HASH,
//             arena_account::TEST_CLASS_HASH, arena_config::TEST_CLASS_HASH, arena_current_rank_index::TEST_CLASS_HASH, arena_team::TEST_CLASS_HASH, enemy_ranges::TEST_CLASS_HASH, gems_rewards::TEST_CLASS_HASH,
//             map_progress::TEST_CLASS_HASH,
//             arena_battle_storage::TEST_CLASS_HASH, battle_storage::TEST_CLASS_HASH, entity_storage::TEST_CLASS_HASH, health_on_turn_proc_storage::TEST_CLASS_HASH, turn_timeline_storage::TEST_CLASS_HASH,
//             level_enemy::TEST_CLASS_HASH, level_infos::TEST_CLASS_HASH,
//             bonus_rune_statistics::TEST_CLASS_HASH, rune_statistics::TEST_CLASS_HASH,
//         ];
//         // let world = spawn_test_world("game", models);
//         let world = spawn_test_world!();

//         let game_contract_adrs = world.deploy_contract('salt', Game::TEST_CLASS_HASH.try_into().unwrap());
//         let game = IGameDispatcher { contract_address: game_contract_adrs };

//         let settings_contract_adrs = world.deploy_contract('salt2', Settings::TEST_CLASS_HASH.try_into().unwrap());
//         // let settings = ISettingsDispatcher { contract_address: settings_contract_adrs };

//         world.grant_writer(dojo::utils::bytearray_hash(@"game"), game_contract_adrs);
//         world.grant_writer(dojo::utils::bytearray_hash(@"game"), settings_contract_adrs);

//         // settings.initSettings();
//         initSettings(world);

//         game.createAccount('testuser');
//         let mut acc = get!(world, caller, Account);
//         assert(acc.username == 'testuser', 'Username incorrect');

//         // game.mintHero();
//         // let mut newAccState = get!(world, caller, Account);
//         // assert(newAccState.heroesCount == acc.heroesCount + 1, 'Hero not minted');

//         // game.mintRune();
//         // game.mintRune();
//         // newAccState = get!(world, caller, Account);
//         // assert(newAccState.runesCount == acc.runesCount + 2, 'Rune not minted');
//         // let rune = get!(world, (caller, 1), Runes).rune;
//         // assert(rune.id == 1, 'Rune id incorrect');

//         let initial = testing::get_available_gas();
//         gas::withdraw_gas().unwrap();
//         game.startBattle(array![12, 13], Map::Campaign.toU16(), 0);
//         println!("{}\n", initial - testing::get_available_gas());
//         // game.playTurn(Map::Campaign.toU16(), 0, 5);
//     }
// }
