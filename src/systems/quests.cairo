use dojo::world::{WorldStorageTrait, WorldStorage};
use starknet::ContractAddress;

trait IQuest {
    fn initQuests(ref world: WorldStorage);
    fn claimGlobalRewards(ref world: WorldStorage, owner: ContractAddress, map: u16, mapProgressRequired: u16);
}

pub mod Quests {
    use game::models::storage::quest::{accountQuests::AccountQuests, globalQuests::GlobalQuests, rewardType::{RewardType, RewardTypeImpl}};
    use game::models::map::{MapTrait, Map};
    use dojo::world::{WorldStorageTrait, WorldStorage};
    use starknet::ContractAddress;
    use game::systems::accounts::Accounts::AccountsImpl;
    use game::models::storage::mapProgress::MapProgress;

    impl QuestsImpl of super::IQuest {
        fn initQuests(ref world: WorldStorage) {
            let map: u16 = Map::Campaign.toU16();
            world.write_model(GlobalQuests { map: map, mapProgressRequired: 1, rewardType: RewardType::Summon, rewardQuantity: 1 });
            world.write_model(GlobalQuests { map: map, mapProgressRequired: 4, rewardType: RewardType::Summon, rewardQuantity: 1 });
            world.write_model(GlobalQuests { map: map, mapProgressRequired: 6, rewardType: RewardType::Summon, rewardQuantity: 1 });
            world.write_model(GlobalQuests { map: map, mapProgressRequired: 8, rewardType: RewardType::Summon, rewardQuantity: 1 });
        }

        fn claimGlobalRewards(ref world: WorldStorage, owner: ContractAddress, map: u16, mapProgressRequired: u16) {
            let ownerMapProgress: MapProgress = world.read_model((owner, map));
            let ownerProgress = ownerMapProgress.level;
            assert(ownerProgress >= mapProgressRequired, 'progress not enough');
            let accountGlobalQuest = world.read_model((owner, map, mapProgressRequired), AccountQuests);
            assert(!accountGlobalQuest.hasClaimedRewards, 'quest already claimed');
            world.write_model(AccountQuests { owner, map, mapProgressRequired, hasClaimedRewards: true });
            let quest: GlobalQuests = world.read_model((map, mapProgressRequired));

            match quest.rewardType {
                RewardType::Summon => {
                    AccountsImpl::increaseSummonChests(world, owner, quest.rewardQuantity);
                },
                RewardType::Rune => {},
                RewardType::Crystals => {},
            }
        }

    }
}