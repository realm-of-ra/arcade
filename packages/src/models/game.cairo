// Intenral imports

use quest::models::index::Game;
use quest::constants;

// Errors

pub mod errors {
    pub const GAME_INVALID_WORLD: felt252 = 'Game: invalid world';
    pub const GAME_INVALID_NAMESPACE: felt252 = 'Game: invalid namespace';
    pub const GAME_INVALID_NAME: felt252 = 'Game: invalid name';
    pub const GAME_INVALID_DESCRIPTION: felt252 = 'Game: invalid description';
    pub const GAME_INVALID_TORII_URL: felt252 = 'Game: invalid torii url';
    pub const GAME_INVALID_POINTS: felt252 = 'Game: cannot exceed 1000';
    pub const GAME_NOT_EXIST: felt252 = 'Game: does not exist';
    pub const GAME_ALREADY_EXISTS: felt252 = 'Game: already exists';
}

#[generate_trait]
impl GameImpl of GameTrait {
    #[inline]
    fn new(
        world_address: felt252,
        namespace: felt252,
        name: ByteArray,
        description: ByteArray,
        torii_url: ByteArray,
        image_uri: ByteArray,
        owner: felt252,
    ) -> Game {
        // [Check] Inputs
        GameAssert::assert_valid_world(world_address);
        GameAssert::assert_valid_namespace(namespace);
        GameAssert::assert_valid_name(@name);
        GameAssert::assert_valid_description(@description);
        GameAssert::assert_valid_torii_url(@torii_url);
        // [Return] Game
        Game {
            world_address,
            namespace,
            whitelisted: false,
            total_points: 0,
            name,
            description,
            torii_url,
            image_uri,
            owner,
        }
    }

    #[inline]
    fn add(ref self: Game, points: u16) {
        // [Check] Inputs
        let total_points = self.total_points + points;
        GameAssert::assert_valid_points(total_points);
        // [Update] Points
        self.total_points = total_points;
    }

    #[inline]
    fn remove(ref self: Game, points: u16) {
        self.total_points -= points;
    }

    #[inline]
    fn update(
        ref self: Game,
        name: ByteArray,
        description: ByteArray,
        torii_url: ByteArray,
        image_uri: ByteArray
    ) {
        // [Check] Inputs
        GameAssert::assert_valid_name(@name);
        GameAssert::assert_valid_description(@description);
        GameAssert::assert_valid_torii_url(@torii_url);
        // [Update] Game
        self.name = name;
        self.description = description;
        self.torii_url = torii_url;
        self.image_uri = image_uri;
    }

    #[inline]
    fn whitelist(ref self: Game) {
        self.whitelisted = true;
    }

    #[inline]
    fn blacklist(ref self: Game) {
        self.whitelisted = false;
    }

    #[inline]
    fn nullify(ref self: Game) {
        self.whitelisted = false;
        self.total_points = 0;
        self.name = "";
        self.description = "";
        self.torii_url = "";
        self.image_uri = "";
    }
}

#[generate_trait]
impl GameAssert of AssertTrait {
    #[inline]
    fn assert_does_not_exist(self: @Game) {
        assert(self.name == @"", errors::GAME_ALREADY_EXISTS);
    }

    #[inline]
    fn assert_does_exist(self: @Game) {
        assert(self.name != @"", errors::GAME_NOT_EXIST);
    }

    #[inline]
    fn assert_valid_world(world: felt252) {
        assert(world != 0, errors::GAME_INVALID_WORLD);
    }

    #[inline]
    fn assert_valid_namespace(namespace: felt252) {
        assert(namespace != 0, errors::GAME_INVALID_NAMESPACE);
    }

    #[inline]
    fn assert_valid_name(name: @ByteArray) {
        assert(name.len() > 0, errors::GAME_INVALID_NAME);
    }

    #[inline]
    fn assert_valid_description(description: @ByteArray) {
        assert(description.len() > 0, errors::GAME_INVALID_DESCRIPTION);
    }

    #[inline]
    fn assert_valid_torii_url(torii_url: @ByteArray) {
        assert(torii_url.len() > 0, errors::GAME_INVALID_TORII_URL);
    }

    #[inline]
    fn assert_valid_points(points: u16) {
        assert(points <= constants::MAX_GAME_POINTS, errors::GAME_INVALID_POINTS);
    }
}

#[cfg(test)]
mod tests {
    // Core imports

    use core::byte_array::{ByteArray, ByteArrayTrait};

    // Local imports

    use super::{Game, GameTrait, GameAssert};

    // Constants

    const WORLD_ADDRESS: felt252 = 'WORLD';
    const NAMESPACE: felt252 = 'NAMESPACE';
    const OWNER: felt252 = 'OWNER';
    #[test]
    fn test_game_new() {
        let name = "NAME";
        let description = "DESCRIPTION";
        let torii_url = "TORII_URL";
        let image_uri = "IMAGE_URI";
        let game = GameTrait::new(
            WORLD_ADDRESS,
            NAMESPACE,
            name.clone(),
            description.clone(),
            torii_url.clone(),
            image_uri.clone(),
            OWNER,
        );
        assert_eq!(game.world_address, WORLD_ADDRESS);
        assert_eq!(game.namespace, NAMESPACE);
        assert_eq!(game.name, name);
        assert_eq!(game.description, description);
        assert_eq!(game.torii_url, torii_url);
        assert_eq!(game.image_uri, image_uri);
        assert_eq!(game.owner, OWNER);
    }

    #[test]
    fn test_game_add() {
        let mut game = GameTrait::new(
            WORLD_ADDRESS, NAMESPACE, "NAME", "DESCRIPTION", "TORII_URL", "IMAGE_URI", OWNER,
        );
        game.add(100);
        assert_eq!(game.total_points, 100);
    }

    #[test]
    fn test_game_remove() {
        let mut game = GameTrait::new(
            WORLD_ADDRESS, NAMESPACE, "NAME", "DESCRIPTION", "TORII_URL", "IMAGE_URI", OWNER,
        );
        game.add(100);
        assert_eq!(game.total_points, 100);
        game.remove(50);
        assert_eq!(game.total_points, 50);
    }

    #[test]
    fn test_game_update() {
        let mut game = GameTrait::new(
            WORLD_ADDRESS, NAMESPACE, "NAME", "DESCRIPTION", "TORII_URL", "IMAGE_URI", OWNER,
        );
        let new_name = "NEW_NAME";
        let new_description = "NEW_DESCRIPTION";
        let new_torii_url = "NEW_TORII_URL";
        let new_image_uri = "NEW_IMAGE_URI";
        game
            .update(
                new_name.clone(),
                new_description.clone(),
                new_torii_url.clone(),
                new_image_uri.clone()
            );
        assert_eq!(game.name, new_name);
        assert_eq!(game.description, new_description);
        assert_eq!(game.torii_url, new_torii_url);
        assert_eq!(game.image_uri, new_image_uri);
    }

    #[test]
    fn test_game_whitelist() {
        let mut game = GameTrait::new(
            WORLD_ADDRESS, NAMESPACE, "NAME", "DESCRIPTION", "TORII_URL", "IMAGE_URI", OWNER,
        );
        game.whitelist();
        assert_eq!(game.whitelisted, true);
    }

    #[test]
    fn test_game_blacklist() {
        let mut game = GameTrait::new(
            WORLD_ADDRESS, NAMESPACE, "NAME", "DESCRIPTION", "TORII_URL", "IMAGE_URI", OWNER,
        );
        game.blacklist();
        assert_eq!(game.whitelisted, false);
    }

    #[test]
    fn test_game_nullify() {
        let mut game = GameTrait::new(
            WORLD_ADDRESS, NAMESPACE, "NAME", "DESCRIPTION", "TORII_URL", "IMAGE_URI", OWNER,
        );
        game.nullify();
        assert_eq!(game.name, "");
        assert_eq!(game.description, "");
        assert_eq!(game.torii_url, "");
        assert_eq!(game.image_uri, "");
        assert_eq!(game.total_points, 0);
        assert_eq!(game.whitelisted, false);
    }

    #[test]
    #[should_panic(expected: 'Game: already exists')]
    fn test_game_assert_does_not_exist() {
        let mut game = GameTrait::new(
            WORLD_ADDRESS, NAMESPACE, "NAME", "DESCRIPTION", "TORII_URL", "IMAGE_URI", OWNER,
        );
        game.assert_does_not_exist();
    }

    #[test]
    #[should_panic(expected: 'Game: does not exist')]
    fn test_game_assert_does_exist() {
        let mut game = GameTrait::new(
            WORLD_ADDRESS, NAMESPACE, "NAME", "DESCRIPTION", "TORII_URL", "IMAGE_URI", OWNER,
        );
        game.name = "";
        game.assert_does_exist();
    }

    #[test]
    #[should_panic(expected: 'Game: invalid world')]
    fn test_game_assert_valid_world_zero() {
        GameAssert::assert_valid_world(0);
    }

    #[test]
    #[should_panic(expected: 'Game: invalid namespace')]
    fn test_game_assert_valid_namespace_zero() {
        GameAssert::assert_valid_namespace(0);
    }

    #[test]
    #[should_panic(expected: 'Game: invalid name')]
    fn test_game_assert_valid_name_empty() {
        GameAssert::assert_valid_name(@"");
    }

    #[test]
    #[should_panic(expected: 'Game: invalid description')]
    fn test_game_assert_valid_description_empty() {
        GameAssert::assert_valid_description(@"");
    }

    #[test]
    #[should_panic(expected: 'Game: invalid torii url')]
    fn test_game_assert_valid_torii_url_empty() {
        GameAssert::assert_valid_torii_url(@"");
    }

    #[test]
    #[should_panic(expected: 'Game: cannot exceed 1000')]
    fn test_game_assert_valid_points_exceeds_max() {
        GameAssert::assert_valid_points(1001);
    }
}