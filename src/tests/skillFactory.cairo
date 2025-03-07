// #[cfg(test)]
// pub mod skillFactoryTest {
//     use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
//     use dojo::utils::test::{spawn_test_world, deploy_contract};
//     // use game::systems::{skillFactory::{SkillFactory, SkillFactory::SkillFactoryImpl, ISkillFactoryDispatcherTrait, ISkillFactoryDispatcher}};
//     use game::systems::{skillFactory::{SkillFactory, SkillFactory::SkillFactoryImpl}};
//     use game::models::storage::skill::{skillBuff::{skill_buff, SkillBuff}, skillInfos::{skill_infos, SkillInfos}, skillNameSet::{skill_name_set, SkillNameSet}};
//     use game::models::hero::{Hero, HeroImpl, HeroTrait};
//     use game::models::battle::entity::skill::Skill;

//     fn setup_world() -> IWorldDispatcher {
//         let mut models = array![skill_buff::TEST_CLASS_HASH, skill_infos::TEST_CLASS_HASH, skill_name_set::TEST_CLASS_HASH];
 
//         let world = spawn_test_world("game", models);
//         world
//     }


//     #[test]
//     #[available_gas(900000000)]
//     fn test() {
//         let caller = starknet::contract_address_const::<0x0>();
//         let world = setup_world();
//         SkillFactoryImpl::initSkills(world);
//         SkillFactoryImpl::initSkillsBuffs(world);
//         SkillFactoryImpl::initHeroSkillNameSet(world);

//         let skill = SkillFactoryImpl::getSkill(world, 'Water Shield');
//         assert(skill.cooldown == 4, 'skill cooldown should be 4');

//         // let skillSet: Array<Skill> = SkillFactoryImpl::getSkillSet(world, 'elandor');
//         // assert(skillSet.len() == 3, 'skillSet len');

//         // let skillSets: Array<Array<Skill>> = SkillFactoryImpl::getSkillSets(world, array!['elandor', 'marella']);
//         // assert(skillSets[1].len() == 3, 'skillSets[1] len');
//     }
// }