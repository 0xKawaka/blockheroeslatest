#[cfg(test)]
mod tests {
    use dojo_cairo_test::WorldStorageTestTrait;
    use dojo::model::{ModelStorage, ModelStorageTest};
    use dojo::world::WorldStorageTrait;
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
    };

    // use starknet::class_hash::Felt252TryIntoClassHash;
    // use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    // use dojo::utils::test::{spawn_test_world, deploy_contract};

    use game::systems::game::{Game, IGameDispatcher, IGameDispatcherTrait};
    // use game::systems::settings::{Settings, ISettingsDispatcher, ISettingsDispatcherTrait};
    use game::systems::settings::{Settings, Settings::initSettings};
    use game::models::map::{MapTrait, Map};
    use game::models::account::{heroes::{m_Heroes, Heroes}, runes::{m_Runes, Runes}};
    use game::models::account::{Account, AccountImpl, AccountTrait, m_Account};
    use game::models::storage::baseHero::{BaseHero, m_BaseHero};
    use game::models::storage::skill::{skillBuff::{SkillBuff, m_SkillBuff}, skillInfos::{SkillInfos, m_SkillInfos}, skillNameSet::{SkillNameSet, m_SkillNameSet}};
    use game::models::storage::arena::{arenaAccount::{ArenaAccount, m_ArenaAccount}, arenaConfig::{ArenaConfig, m_ArenaConfig}, arenaCurrentRankIndex::{ArenaCurrentRankIndex, m_ArenaCurrentRankIndex}, arenaTeam::{ArenaTeam, m_ArenaTeam}, enemyRanges::{EnemyRanges, m_EnemyRanges}, gemsRewards::{GemsRewards, m_GemsRewards}};
    use game::models::storage::{mapProgress::{MapProgress, m_MapProgress}};
    use game::models::storage::battles::{arenaBattleStorage::{ArenaBattleStorage, m_ArenaBattleStorage}, battleStorage::{BattleStorage, m_BattleStorage}, entityStorage::{EntityStorage, m_EntityStorage}, healthOnTurnProcStorage::{HealthOnTurnProcStorage, m_HealthOnTurnProcStorage}, turnTimelineStorage::{TurnTimelineStorage, m_TurnTimelineStorage}};
    use game::models::storage::level::{levelEnemy::{LevelEnemy, m_LevelEnemy}, levelInfos::{LevelInfos, m_LevelInfos}};
    use game::models::storage::statistics::{bonusRuneStatistics::{BonusRuneStatistics, m_BonusRuneStatistics}, runeStatistics::{RuneStatistics, m_RuneStatistics}};

    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "ns",
            resources: [
                TestResource::Model(m_BaseHero::TEST_CLASS_HASH),
                TestResource::Model(m_Heroes::TEST_CLASS_HASH),
                TestResource::Model(m_Runes::TEST_CLASS_HASH),
                TestResource::Model(m_Account::TEST_CLASS_HASH),
                TestResource::Model(m_SkillBuff::TEST_CLASS_HASH),
                TestResource::Model(m_SkillInfos::TEST_CLASS_HASH),
                TestResource::Model(m_SkillNameSet::TEST_CLASS_HASH),
                TestResource::Model(m_ArenaAccount::TEST_CLASS_HASH),
                TestResource::Model(m_ArenaConfig::TEST_CLASS_HASH),
                TestResource::Model(m_ArenaCurrentRankIndex::TEST_CLASS_HASH),
                TestResource::Model(m_ArenaTeam::TEST_CLASS_HASH),
                TestResource::Model(m_EnemyRanges::TEST_CLASS_HASH),
                TestResource::Model(m_GemsRewards::TEST_CLASS_HASH),
                TestResource::Model(m_MapProgress::TEST_CLASS_HASH),
                TestResource::Model(m_ArenaBattleStorage::TEST_CLASS_HASH),
                TestResource::Model(m_BattleStorage::TEST_CLASS_HASH),
                TestResource::Model(m_EntityStorage::TEST_CLASS_HASH),
                TestResource::Model(m_HealthOnTurnProcStorage::TEST_CLASS_HASH),
                TestResource::Model(m_TurnTimelineStorage::TEST_CLASS_HASH),
                TestResource::Model(m_LevelEnemy::TEST_CLASS_HASH),
                TestResource::Model(m_LevelInfos::TEST_CLASS_HASH),
                TestResource::Model(m_BonusRuneStatistics::TEST_CLASS_HASH),
                TestResource::Model(m_RuneStatistics::TEST_CLASS_HASH),
            ]
                .span(),
        };

        ndef
    }

    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"ns", @"Game")
                .with_writer_of([dojo::utils::bytearray_hash(@"ns")].span()),
            // ContractDefTrait::new(@"game", @"Settings")
            //     .with_writer_of([dojo::utils::bytearray_hash(@"game")].span()),
        ]
            .span()
    }

    #[test]
    fn test_world_test_set() {
        // Initialize test environment
        let caller = starknet::contract_address_const::<0x0>();
        let ndef = namespace_def();

        // Register the resources.
        let mut world = spawn_test_world([ndef].span());

        // Ensures permissions and initializations are synced.
        world.sync_perms_and_inits(contract_defs());
    }

}
