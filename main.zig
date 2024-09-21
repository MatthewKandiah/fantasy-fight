const std = @import("std");

pub fn main() void {
    const player1 = Player.init("Alfred", .DWARF_IN_CHAINMAIL_WITH_TWO_HANDED_AX);
    const player2 = Player.init("Bob", .DWARF_IN_CHAINMAIL_WITH_TWO_HANDED_AX);

    const game = GameState.init(
        player1,
        player2,
    );

    _ = game;
}

const GameState = struct {
    player1: Player,
    player2: Player,

    const Self = @This();

    fn init(player1: Player, player2: Player) Self {
        return .{
            .player1 = player1,
            .player2 = player2,
        };
    }
};

const CharacterType = enum {
    DWARF_IN_CHAINMAIL_WITH_TWO_HANDED_AX,
};

const Player = struct {
    character_booklet: CharacterBooklet,
    character_sheet: CharacterSheet,

    const Self = @This();

    fn init(name: []const u8, character_type: CharacterType) Self {
        return switch (character_type) {
            .DWARF_IN_CHAINMAIL_WITH_TWO_HANDED_AX => newDwarfInChainmailWithTwoHandedAx(name),
        };
    }
};

const CharacterBooklet = struct {
    movement_parchments: []const MovementParchment,
    picture_scrolls: []const PictureScroll,
};

const MovementParchment = struct {
    pg: i32,
    values: [32]i32,

    const Self = @This();

    fn get(self: Self, page: i32) !i32 {
        if (page <= 0) {
            return error.NegativeOrZeroMovementPage;
        }
        if (page % 2 != 0) {
            return error.OddMovementPage;
        }
        const value = self.values[(page / 2) - 1];
        if (value == -1) {
            return error.InvalidMovementPage;
        }
        return value;
    }
};

const PictureScroll = struct {
    name: []const u8,
    // TODO - implement opponent restrictions
    pg: i32,
    score: ?i32,
};

const CharacterSheet = struct {
    name: []const u8,
    height: i32,
    starting_body_points: i32,
    current_body_points: i32,
    attacks_count: i32,
    maneuvers: []const Maneuver,
};

const Maneuver = struct {
    name: []const u8,
    description: []const u8,
    pg: i32,
    x: i32,
    mod: i32,
    colour: ManeuverColour,
    extended_range: bool,
};

const ManeuverColour = enum {
    ORANGE,
    RED,
    BLUE,
    YELLOW,
    GREEN,
    WHITE,
    BLACK,
    BROWN,
};

fn newDwarfInChainmailWithTwoHandedAx(name: []const u8) Player {
    return .{
        .character_booklet = .{
            .movement_parchments = &[_]MovementParchment{
                MovementParchment{
                    .pg = 2,
                    .values = .{ 49, 0, 0, 13, 13, 0, 49, 57, 37, 31, 0, 13, 0, 13, 49, 13, 41, 13, 0, 49, 0, 0, 27, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 4,
                    .values = .{ 5, 0, 0, 33, 3, 0, 11, 57, 37, 29, 0, 15, 0, 3, 15, 9, 25, 15, 0, 5, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 6,
                    .values = .{ 53, 0, 0, 33, 3, 0, 49, 53, 13, 29, 0, 31, 0, 31, 5, 45, 13, 53, 0, 31, 0, 0, 53, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 8,
                    .values = .{ 5, 0, 0, 33, 3, 0, 21, 57, 37, 29, 0, 15, 0, 3, 3, 9, 19, 15, 0, 5, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 10,
                    .values = .{ 31, 0, 0, 53, 45, 0, 7, 57, 13, 23, 0, 45, 0, 31, 3, 53, 25, 31, 0, 53, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 12,
                    .values = .{ 31, 0, 0, 31, 53, 0, 11, 57, 13, 29, 0, 45, 0, 31, 3, 45, 25, 31, 0, 53, 0, 0, 29, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 14,
                    .values = .{ 49, 0, 0, 23, 13, 0, 13, 19, 37, 53, 0, 13, 0, 13, 5, 13, 13, 13, 0, 49, 0, 0, 53, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 16,
                    .values = .{ 51, 0, 0, 61, 51, 0, 11, 57, 61, 61, 0, 19, 0, 21, 51, 9, 41, 41, 0, 21, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 18,
                    .values = .{ 5, 0, 0, 33, 3, 0, 11, 57, 37, 29, 0, 15, 0, 3, 3, 9, 41, 15, 0, 21, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 20,
                    .values = .{ 5, 0, 0, 33, 21, 0, 11, 57, 37, 29, 0, 15, 0, 21, 3, 9, 25, 15, 0, 5, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 22,
                    .values = .{ 49, 0, 0, 23, 13, 0, 13, 19, 37, 53, 0, 15, 0, 3, 5, 31, 25, 13, 0, 49, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 24,
                    .values = .{ 53, 0, 0, 33, 45, 0, 11, 1, 53, 7, 0, 7, 0, 53, 3, 45, 53, 15, 0, 21, 0, 0, 41, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 26,
                    .values = .{ 5, 0, 0, 33, 3, 0, 11, 57, 37, 29, 0, 15, 0, 3, 3, 9, 25, 15, 0, 5, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 28,
                    .values = .{ 7, 0, 0, 53, 3, 0, 11, 23, 37, 23, 0, 53, 0, 19, 31, 9, 25, 31, 0, 41, 0, 0, 29, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 30,
                    .values = .{ 49, 0, 0, 33, 3, 0, 11, 57, 37, 29, 0, 15, 0, 3, 27, 27, 25, 15, 0, 5, 0, 0, 27, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 32,
                    .values = .{ 53, 0, 0, 33, 3, 0, 53, 19, 13, 29, 0, 45, 0, 53, 3, 31, 25, 53, 0, 31, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 34,
                    .values = .{ 5, 0, 0, 33, 3, 0, 11, 1, 37, 29, 0, 15, 0, 17, 3, 17, 25, 41, 0, 41, 0, 0, 27, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 36,
                    .values = .{ 5, 0, 0, 33, 3, 0, 63, 63, 7, 7, 0, 15, 0, 7, 27, 9, 7, 63, 0, 7, 0, 0, 7, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 38,
                    .values = .{ 31, 0, 0, 53, 45, 0, 7, 57, 13, 29, 0, 45, 0, 3, 5, 45, 25, 31, 0, 5, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 40,
                    .values = .{ 49, 0, 0, 33, 3, 0, 49, 23, 23, 53, 0, 23, 0, 3, 5, 9, 25, 41, 0, 5, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 42,
                    .values = .{ 49, 0, 0, 13, 13, 0, 49, 57, 37, 31, 0, 13, 0, 13, 5, 9, 41, 13, 0, 49, 0, 0, 27, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 44,
                    .values = .{ 5, 0, 0, 33, 45, 0, 53, 57, 7, 53, 0, 31, 0, 31, 53, 45, 13, 53, 0, 31, 0, 0, 27, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 46,
                    .values = .{ 5, 0, 0, 33, 3, 0, 11, 1, 37, 29, 0, 15, 0, 3, 15, 9, 25, 15, 0, 5, 0, 0, 43, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 48,
                    .values = .{ 5, 0, 0, 19, 45, 0, 49, 57, 19, 29, 0, 31, 0, 31, 19, 9, 25, 31, 0, 19, 0, 0, 19, 0, -1, -1, -1, -1, -1, -1, -1, -1 },
                },
                MovementParchment{
                    .pg = 50,
                    .values = .{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 45, 23, 0, 53, 41, 11, 19, 19 },
                },
                MovementParchment{
                    .pg = 52,
                    .values = .{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 21, 61, 0, 57, 5, 11, 57, 51 },
                },
                MovementParchment{
                    .pg = 54,
                    .values = .{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 53, 33, 0, 45, 35, 11, 35, 3 },
                },
                MovementParchment{
                    .pg = 56,
                    .values = .{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 39, 61, 0, 45, 51, 55, 57, 3 },
                },
                MovementParchment{
                    .pg = 58,
                    .values = .{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 39, 33, 0, 47, 5, 13, 57, 51 },
                },
                MovementParchment{
                    .pg = 60,
                    .values = .{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 13, 33, 0, 57, 5, 11, 57, 47 },
                },
                MovementParchment{
                    .pg = 62,
                    .values = .{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 39, 61, 0, 57, 51, 55, 57, 51 },
                },
                MovementParchment{
                    .pg = 64,
                    .values = .{ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 7, 59, 0, 45, 51, 55, 57, 3 },
                },
            },
            .picture_scrolls = &[_]PictureScroll{
                PictureScroll{
                    .name = "Jumping Away",
                    .pg = 1,
                    .score = null,
                },
                PictureScroll{
                    .name = "Swinging High",
                    .pg = 3,
                    .score = null,
                },
                PictureScroll{
                    .name = "Swinging Low",
                    .pg = 5,
                    .score = null,
                },
                PictureScroll{
                    .name = "Dazed",
                    .pg = 7,
                    .score = 6,
                },
                PictureScroll{
                    .name = "Hooking Shield",
                    .pg = 9,
                    .score = null,
                },
                PictureScroll{
                    .name = "Hooking Leg",
                    .pg = 11,
                    .score = null,
                },
                PictureScroll{
                    .name = "Leg Wound",
                    .pg = 13,
                    .score = 3,
                },
                PictureScroll{
                    .name = "Swinging Down",
                    .pg = 15,
                    .score = null,
                },
                PictureScroll{
                    .name = "Kicked Off Balance",
                    .pg = 17,
                    .score = 0,
                },
                PictureScroll{
                    .name = "Knocked Off Balance",
                    .pg = 19,
                    .score = 0,
                },
                PictureScroll{
                    .name = "Turned Around",
                    .pg = 21,
                    .score = 0,
                },
                PictureScroll{
                    .name = "Behind You",
                    .pg = 23,
                    .score = null,
                },
                PictureScroll{
                    .name = "Kicking",
                    .pg = 25,
                    .score = null,
                },
                PictureScroll{
                    .name = "Weapon Dislodged",
                    .pg = 27,
                    .score = null,
                },
                PictureScroll{
                    .name = "Ducking",
                    .pg = 29,
                    .score = null,
                },
                PictureScroll{
                    .name = "Arm Wound",
                    .pg = 31,
                    .score = 2,
                },
                PictureScroll{
                    .name = "Dodging",
                    .pg = 33,
                    .score = null,
                },
                PictureScroll{
                    .name = "Extended Range Body Wound",
                    .pg = 35,
                    .score = 4,
                },
                PictureScroll{
                    .name = "Jumping Up",
                    .pg = 37,
                    .score = null,
                },
                PictureScroll{
                    .name = "Charging",
                    .pg = 39,
                    .score = null,
                },
                PictureScroll{
                    .name = "Knocked Down",
                    .pg = 41,
                    .score = 0,
                },
                PictureScroll{
                    .name = "Retrieving Weapon",
                    .pg = 43,
                    .score = null,
                },
                PictureScroll{
                    .name = "Parrying High",
                    .pg = 45,
                    .score = -4,
                },
                PictureScroll{
                    .name = "Extended Range Leg Wound",
                    .pg = 47,
                    .score = 3,
                },
                PictureScroll{
                    .name = "Parrying Low",
                    .pg = 49,
                    .score = -4,
                },
                PictureScroll{
                    .name = "Extended Range Swinging",
                    .pg = 51,
                    .score = null,
                },
                PictureScroll{
                    .name = "Body Wound",
                    .pg = 53,
                    .score = 4,
                },
                PictureScroll{
                    .name = "Extended Range Hooking Leg",
                    .pg = 55,
                    .score = null,
                },
                PictureScroll{
                    .name = "Extended Range Blocking",
                    .pg = 57,
                    .score = null,
                },
                PictureScroll{
                    .name = "Extended Range Arm Wound",
                    .pg = 59,
                    .score = 2,
                },
                PictureScroll{
                    .name = "Extended Range Dodging",
                    .pg = 61,
                    .score = null,
                },
                PictureScroll{
                    .name = "Weapon Broken",
                    .pg = 63,
                    .score = null,
                },
            },
        },
        .character_sheet = .{
            .name = name,
            .height = 3,
            .starting_body_points = 14,
            .current_body_points = 14,
            .attacks_count = 1,
            .maneuvers = &[_]Maneuver{
                Maneuver{
                    .name = "Down Swing Bash",
                    .description = "placholder",
                    .pg = 36,
                    .x = 50,
                    .mod = 3,
                    .colour = .ORANGE,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Down Swing Smash",
                    .description = "placeholder",
                    .pg = 24,
                    .x = 50,
                    .mod = 2,
                    .colour = .ORANGE,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Side Swing Strong",
                    .description = "placeholder",
                    .pg = 28,
                    .x = 64,
                    .mod = 1,
                    .colour = .ORANGE,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Side Swing High",
                    .description = "placeholder",
                    .pg = 10,
                    .x = 64,
                    .mod = -1,
                    .colour = .RED,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Side Swing Low",
                    .description = "placeholder",
                    .pg = 2,
                    .x = 58,
                    .mod = -1,
                    .colour = .BLUE,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Thrust Hook Shield",
                    .description = "placeholder",
                    .pg = 32,
                    .x = 54,
                    .mod = -2,
                    .colour = .RED,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Thrust Hook Leg",
                    .description = "placeholder",
                    .pg = 14,
                    .x = 60,
                    .mod = -4,
                    .colour = .BLUE,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Special Kick",
                    .description = "placeholder",
                    .pg = 34,
                    .x = 56,
                    .mod = -1,
                    .colour = .BLUE,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Special Wild Swing",
                    .description = "placeholder",
                    .pg = 40,
                    .x = 58,
                    .mod = 3,
                    .colour = .YELLOW,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Special Dislodge Weapon",
                    .description = "placeholder",
                    .pg = 30,
                    .x = 58,
                    .mod = -4,
                    .colour = .BLUE,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Special Retrieve Weapon",
                    .description = "placeholder",
                    .pg = 46,
                    .x = 52,
                    .mod = -6,
                    .colour = .GREEN,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Jump Up",
                    .description = "placeholder",
                    .pg = 18,
                    .x = 52,
                    .mod = -6,
                    .colour = .GREEN,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Jump Dodge",
                    .description = "placeholder",
                    .pg = 8,
                    .x = 52,
                    .mod = -4,
                    .colour = .YELLOW,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Jump Duck",
                    .description = "placeholder",
                    .pg = 20,
                    .x = 52,
                    .mod = -5,
                    .colour = .GREEN,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Jump Away",
                    .description = "placeholder",
                    .pg = 16,
                    .x = 62,
                    .mod = -4,
                    .colour = .YELLOW,
                    .extended_range = false,
                },
                Maneuver{
                    .name = "Extended Range Charge",
                    .description = "placeholder",
                    .pg = 50,
                    .x = 50,
                    .mod = 5,
                    .colour = .WHITE,
                    .extended_range = true,
                },
                Maneuver{
                    .name = "Extended Range Swing High",
                    .description = "placeholder",
                    .pg = 64,
                    .x = 64,
                    .mod = 3,
                    .colour = .BLACK,
                    .extended_range = true,
                },
                Maneuver{
                    .name = "Extended Range Swing Low",
                    .description = "placeholder",
                    .pg = 58,
                    .x = 58,
                    .mod = 3,
                    .colour = .BLACK,
                    .extended_range = true,
                },
                Maneuver{
                    .name = "Extended Range Thrust Low",
                    .description = "placeholder",
                    .pg = 60,
                    .x = 60,
                    .mod = 0,
                    .colour = .WHITE,
                    .extended_range = true,
                },
                Maneuver{
                    .name = "Extended Range Block & Close",
                    .description = "placeholder",
                    .pg = 56,
                    .x = 56,
                    .mod = 0,
                    .colour = .BROWN,
                    .extended_range = true,
                },
                Maneuver{
                    .name = "Extended Range Dodge",
                    .description = "placeholder",
                    .pg = 52,
                    .x = 52,
                    .mod = -4,
                    .colour = .BROWN,
                    .extended_range = true,
                },
                Maneuver{
                    .name = "Extended Range Jump Back",
                    .description = "placeholder",
                    .pg = 62,
                    .x = 62,
                    .mod = -4,
                    .colour = .BROWN,
                    .extended_range = true,
                },
            },
        },
    };
}
