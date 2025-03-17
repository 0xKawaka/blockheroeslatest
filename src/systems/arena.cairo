use starknet::ContractAddress;
use dojo::world::WorldStorage;

pub trait IArena {
    fn initAccount(ref world: WorldStorage, owner: ContractAddress, heroeIds: Array<u32>);
    fn setTeam(ref world: WorldStorage, owner: ContractAddress, heroeIds: Span<u32>);
    fn swapRanks(ref world: WorldStorage, winner: ContractAddress, looser: ContractAddress, lastClaimedRewards: u64);
    fn setEnemyRangesByRank(ref world: WorldStorage, minRank: Array<u64>, range: Array<u64>);
    fn setGemsRewards(ref world: WorldStorage, minRank: Array<u64>, gems: Array<u64>);
    fn getGemsReward(ref world: WorldStorage, owner: ContractAddress) -> u64;
    fn assertEnemyInRange(ref world: WorldStorage, owner: ContractAddress, enemyOwner: ContractAddress);
    fn getTeam(ref world: WorldStorage, owner: ContractAddress) -> Array<u32>;
    fn getRank(ref world: WorldStorage, owner: ContractAddress) -> u64;
    fn initArena(ref world: WorldStorage, minRankGems: Array<u64>, gems: Array<u64>, minRankRange: Array<u64>, range: Array<u64>);
    fn hasAccount(ref world: WorldStorage, accountAdrs: ContractAddress);
    fn hasNoAccount(ref world: WorldStorage, accountAdrs: ContractAddress);
}

pub mod Arena {
    use {starknet::ContractAddress, starknet::get_block_timestamp};
    use dojo::world::WorldStorage;
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use game::models::storage::arena::{arenaAccount::ArenaAccount, arenaConfig::ArenaConfig, arenaCurrentRankIndex::ArenaCurrentRankIndex, arenaTeam::ArenaTeam, enemyRanges::EnemyRanges, gemsRewards::GemsRewards};
    use game::models::events::{InitArena, ArenaDefense, RankChange};

    pub impl ArenaImpl of super::IArena {
        fn initAccount(ref world: WorldStorage, owner: ContractAddress, heroeIds: Array<u32>) {
            let arenaCurrentRankWrapper: ArenaCurrentRankIndex = world.read_model(0);
            let arenaCurrentRank = arenaCurrentRankWrapper.currentRankIndex;
            world.write_model(@ArenaAccount { owner: owner, rank: arenaCurrentRank, lastClaimedRewards: get_block_timestamp(), teamSize: heroeIds.len() });
            world.write_model(@ArenaCurrentRankIndex { id: 0, currentRankIndex: arenaCurrentRank + 1 });

            Self::setTeam(ref world, owner, heroeIds.span());
            world.emit_event(@InitArena { owner: owner, rank: arenaCurrentRank, heroeIds: heroeIds });
        }

        fn setTeam(ref world: WorldStorage, owner: ContractAddress, heroeIds: Span<u32>) {
            let mut i: u32 = 0;
            loop {
                if i >= heroeIds.len() {
                    break;
                }
                world.write_model(@ArenaTeam { owner: owner, index: i, heroIndex: *heroeIds[i] });
                let arenaAccount: ArenaAccount = world.read_model(owner);
                world.write_model(@ArenaAccount { owner: owner, rank: arenaAccount.rank, lastClaimedRewards: arenaAccount.lastClaimedRewards, teamSize: heroeIds.len() });
                i += 1;
            };
            world.emit_event(@ArenaDefense { owner: owner, heroeIds: heroeIds });
        }

        fn swapRanks(ref world: WorldStorage, winner: ContractAddress, looser: ContractAddress, lastClaimedRewards: u64) {
            let winnerAccountWrapper: ArenaAccount = world.read_model(winner);
            let looserAccountWrapper: ArenaAccount = world.read_model(looser);
            if(winnerAccountWrapper.rank < looserAccountWrapper.rank) {
                return;
            }
            world.write_model(@ArenaAccount { owner: winner, rank: looserAccountWrapper.rank, lastClaimedRewards: lastClaimedRewards, teamSize: winnerAccountWrapper.teamSize });
            world.write_model(@ArenaAccount { owner: looser, rank: winnerAccountWrapper.rank, lastClaimedRewards: lastClaimedRewards, teamSize: looserAccountWrapper.teamSize });
            world.emit_event(@RankChange { owner: winner, rank: looserAccountWrapper.rank });
        }

        fn setEnemyRangesByRank(ref world: WorldStorage, minRank: Array<u64>, range: Array<u64>) {
            let arenaConfigWrapper: ArenaConfig = world.read_model(0);
            world.write_model(@ArenaConfig { id: 0, gemsRewardsLength: arenaConfigWrapper.gemsRewardsLength, enemyRangesByRankLength: minRank.len()});

            let mut i: u32 = 0;
            loop {
                if i >= minRank.len() {
                    break;
                }
                world.write_model(@EnemyRanges { index: i, minRank: *minRank[i], range: *range[i] });
                i += 1;
            };

        }

        fn setGemsRewards(ref world: WorldStorage, minRank: Array<u64>, gems: Array<u64>) {
            let arenaConfigWrapper: ArenaConfig = world.read_model(0);
            world.write_model(@ArenaConfig { id: 0, gemsRewardsLength: gems.len(), enemyRangesByRankLength: arenaConfigWrapper.enemyRangesByRankLength });

            let mut i: u32 = 0;
            loop {
                if i >= gems.len() {
                    break;
                }
                world.write_model(@GemsRewards { index: i, minRank: *minRank[i], gems: *gems[i] });
                i += 1;
            };
        }

        fn getGemsReward(ref world: WorldStorage, owner: ContractAddress) -> u64 {
            let arenaAccount: ArenaAccount = world.read_model(owner);
            let ownerRank = arenaAccount.rank;
            let arenaConfigWrapper: ArenaConfig = world.read_model(0);
            let gemsRewardsLength = arenaConfigWrapper.gemsRewardsLength;
            let mut i: u32 = 0;
            let mut res: u64 = 0;

            loop {
                if i == gemsRewardsLength {
                    break;
                }
                let gemsReward: GemsRewards = world.read_model(0);
                if ownerRank <= gemsReward.minRank {
                    res = gemsReward.gems;
                    break;
                }
                i += 1;
            };
            return res;
        }

        fn assertEnemyInRange(ref world: WorldStorage, owner: ContractAddress, enemyOwner: ContractAddress) {
            let arenaAccount: ArenaAccount = world.read_model(owner);
            let ownerRank = arenaAccount.rank;
            let arenaAccount: ArenaAccount = world.read_model(enemyOwner);
            let enemyRank = arenaAccount.rank;
            assert(ownerRank > enemyRank, 'Can only fight higher ranks');
            let arenaConfigWrapper: ArenaConfig = world.read_model(0);
            let enemyRangesByRankLength = arenaConfigWrapper.enemyRangesByRankLength;

            let mut i: u32 = 0;
            let mut res = false;
            loop {
                if i == enemyRangesByRankLength {
                    break;
                }
                let enemyRanges: EnemyRanges = world.read_model(0);
                if ownerRank <= enemyRanges.minRank {
                    if enemyRank + enemyRanges.range >= ownerRank {
                        res = true;
                    }
                    break;
                }
                i += 1;
            };
            assert(res, 'Enemy rank not in range');
        }

        fn getRank(ref world: WorldStorage, owner: ContractAddress) -> u64 {
            let arenaAccount: ArenaAccount = world.read_model(owner);
            return arenaAccount.rank;
        }

        fn getTeam(ref world: WorldStorage, owner: ContractAddress) -> Array<u32> {
            let arenaAccount: ArenaAccount = world.read_model(owner);
            let mut heroIndexes: Array<u32> = Default::default();
            let mut i: u32 = 0;
            loop {
                if i == arenaAccount.teamSize {
                    break;
                }
                let arenaTeamWrapper: ArenaTeam = world.read_model(owner);
                heroIndexes.append(arenaTeamWrapper.heroIndex);
                i += 1;
            };
            return heroIndexes;
        }

        fn hasAccount(ref world: WorldStorage, accountAdrs: ContractAddress) {
            let arenaAccount: ArenaAccount = world.read_model(accountAdrs);
            assert(arenaAccount.rank != 0, 'Arenaccount not found');
        }

        fn hasNoAccount(ref world: WorldStorage, accountAdrs: ContractAddress) {
            let arenaAccount: ArenaAccount = world.read_model(accountAdrs);
            assert(arenaAccount.rank == 0, 'Arenaccount already exists');
        }

        fn initArena(ref world: WorldStorage, minRankGems: Array<u64>, gems: Array<u64>, minRankRange: Array<u64>, range: Array<u64>) {
            world.write_model(
                @ArenaConfig {
                        id: 0,
                        enemyRangesByRankLength: minRankRange.len(),
                        gemsRewardsLength: minRankGems.len()
                    }
            );
            world.write_model(@ArenaCurrentRankIndex { id: 0, currentRankIndex: 1 });

            let mut i: u32 = 0;
            loop {
                if i == minRankGems.len() {
                    break;
                }
                world.write_model(@GemsRewards { index: i, minRank: *minRankGems[i], gems: *gems[i] });
                i += 1;
            };

            i = 0;
            loop {
                if i == minRankRange.len() {
                    break;
                }
                world.write_model(@EnemyRanges { index: i, minRank: *minRankRange[i], range: *range[i] });
                i += 1;
            };
        }

    }

}