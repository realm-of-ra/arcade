// Internal imports

use quest::events::index::AchievementCreation;
use quest::constants;

// Errors

pub mod errors {
    pub const ACHIEVEMENT_INVALID_WORLD: felt252 = 'Achievement: invalid world';
    pub const ACHIEVEMENT_INVALID_NAMESPACE: felt252 = 'Achievement: invalid namespace';
    pub const ACHIEVEMENT_INVALID_ACHIEVEMENT: felt252 = 'Achievement: invalid id';
    pub const ACHIEVEMENT_INVALID_POINTS: felt252 = 'Achievement: cannot exceed 100';
    pub const ACHIEVEMENT_INVALID_TITLE: felt252 = 'Achievement: invalid title';
    pub const ACHIEVEMENT_INVALID_DESCRIPTION: felt252 = 'Achievement: invalid descr';
}

// Implementations

#[generate_trait]
impl AchievementCreationImpl of AchievementCreationTrait {
    #[inline]
    fn new(
        namespace: felt252,
        id: felt252,
        points: u16,
        total: u32,
        title: ByteArray,
        description: ByteArray,
        image_uri: ByteArray,
        time: u64,
    ) -> AchievementCreation {
        // [Check] Inputs
        // [Info] We don't check points here, leave free the game to decide
        AchievementCreationAssert::assert_valid_namespace(namespace);
        AchievementCreationAssert::assert_valid_id(id);
        AchievementCreationAssert::assert_valid_title(@title);
        AchievementCreationAssert::assert_valid_description(@description);
        // [Return] Achievement
        AchievementCreation { namespace, id, points, total, title, description, image_uri, time }
    }
}

#[generate_trait]
impl AchievementCreationAssert of AssertTrait {
    #[inline]
    fn assert_valid_namespace(namespace: felt252) {
        assert(namespace != 0, errors::ACHIEVEMENT_INVALID_NAMESPACE);
    }

    #[inline]
    fn assert_valid_id(achivement_id: felt252) {
        assert(achivement_id != 0, errors::ACHIEVEMENT_INVALID_ACHIEVEMENT);
    }

    #[inline]
    fn assert_valid_title(title: @ByteArray) {
        assert(title.len() > 0, errors::ACHIEVEMENT_INVALID_TITLE);
    }

    #[inline]
    fn assert_valid_description(description: @ByteArray) {
        assert(description.len() > 0, errors::ACHIEVEMENT_INVALID_DESCRIPTION);
    }
}