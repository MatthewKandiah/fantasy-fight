const std = @import("std");

pub fn main() !void {
    var stdin_buf: [64]u8 = undefined;
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const player1 = Player.init("Alfred");
    const player2 = Player.init("Bob");

    const game = GameState.init(
        player1,
        player2,
    );

    while (game.status == .IN_PROGRESS) {
        // present player 1's maneuvers and get choice
        const input = stdin.readUntilDelimiterOrEof(&stdin_buf, '\n') catch std.process.exit(1) orelse "";
        _ = stdout.write("Input: ") catch std.process.exit(1);
        _ = stdout.write(input) catch std.process.exit(1);
        _ = stdout.write("\n") catch std.process.exit(1);
        // present player 2's maneuvers and get choice
        break;
    }
}

// TODO - allowed and forbidden maneuver type and maneuver colour for each player
const GameState = struct {
    player1: Player,
    player2: Player,
    status: GameStatus,

    const Self = @This();

    fn init(player1: Player, player2: Player) Self {
        return Self{
            .player1 = player1,
            .player2 = player2,
            .status = .IN_PROGRESS,
        };
    }

    fn update(self: *Self, player1_maneuver: Maneuver, player2_maneuver: Maneuver) void {
        _ = self;
        _ = player1_maneuver;
        _ = player2_maneuver;
    }
    // TODO - calculate available options, print them to stdout, get player choice from stdin, update game state
};

const GameStatus = enum {
    IN_PROGRESS,
    DRAW,
    PLAYER1_VICTORY,
    PLAYER2_VICTORY,
};

const Player = struct {
    character_booklet: CharacterBooklet,
    character_sheet: CharacterSheet,
    current_page: i32,
    required_maneuver_types: [ManeuverType.field_count]bool,
    forbidden_maneuver_types: [ManeuverType.field_count]bool,
    required_maneuver_colours: [ManeuverColour.field_count]bool,
    forbidden_maneuver_colours: [ManeuverColour.field_count]bool,

    const Self = @This();

    fn init(name: []const u8) Self {
        return Self{
            .character_booklet = dwarfInChainmailWithTwoHandedAxBooklet,
            .character_sheet = dwarfInChainmailWithTwoHandedAxSheet(name),
            .current_page = 57,
            .required_maneuver_types = ManeuverType.initial_required,
            .forbidden_maneuver_types = ManeuverType.initial_forbidden,
            .required_maneuver_colours = ManeuverColour.initial_required,
            .forbidden_maneuver_colours = ManeuverColour.initial_forbidden,
        };
    }

    fn isManeuverAllowed(self: Self, maneuver: Maneuver) bool {
        const candidate_type_index = @intFromEnum(maneuver.type);
        const candidate_colour_index = @intFromEnum(maneuver.colour);
        for (0..ManeuverType.field_count) |i| {
            if (i == candidate_type_index and self.forbidden_maneuver_types[i]) {
                return false;
            }
            if (i != candidate_type_index and self.required_maneuver_types[i]) {
                return false;
            }
        }
        for (0..ManeuverColour.field_count) |i| {
            if (i == candidate_colour_index and self.forbidden_maneuver_colours[i]) {
                return false;
            }
            if (i != candidate_colour_index and self.required_maneuver_colours[i]) {
                return false;
            }
        }
        return true;
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
    type: ManeuverType,
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

    const Self = @This();

    const field_count = @typeInfo(Self).Enum.fields.len;

    const initial_required = [Self.field_count]bool{ false, false, false, false, false, false, false, false };

    const initial_forbidden = [Self.field_count]bool{ false, false, false, false, false, false, false, false };
};

const ManeuverType = enum {
    EXTENDED_RANGE, // logic assumes this has value zero
    DOWN_SWING,
    SIDE_SWING,
    THRUST,
    SPECIAL,
    JUMP,

    const Self = @This();

    const field_count = @typeInfo(Self).Enum.fields.len;

    const initial_required = [Self.field_count]bool{ true, false, false, false, false, false };

    const initial_forbidden = [Self.field_count]bool{ false, false, false, false, false, false };
};

const dwarfInChainmailWithTwoHandedAxBooklet: CharacterBooklet = .{
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
};

fn dwarfInChainmailWithTwoHandedAxSheet(name: []const u8) CharacterSheet {
    return .{
        .name = name,
        .height = 3,
        .starting_body_points = 14,
        .current_body_points = 14,
        .attacks_count = 1,
        .maneuvers = &[_]Maneuver{
            Maneuver{
                .name = "Bash",
                .description = "placholder",
                .pg = 36,
                .x = 50,
                .mod = 3,
                .colour = .ORANGE,
                .type = .DOWN_SWING,
            },
            Maneuver{
                .name = "Smash",
                .description = "placeholder",
                .pg = 24,
                .x = 50,
                .mod = 2,
                .colour = .ORANGE,
                .type = .DOWN_SWING,
            },
            Maneuver{
                .name = "Strong",
                .description = "placeholder",
                .pg = 28,
                .x = 64,
                .mod = 1,
                .colour = .ORANGE,
                .type = .SIDE_SWING,
            },
            Maneuver{
                .name = "High",
                .description = "placeholder",
                .pg = 10,
                .x = 64,
                .mod = -1,
                .colour = .RED,
                .type = .SIDE_SWING,
            },
            Maneuver{
                .name = "Low",
                .description = "placeholder",
                .pg = 2,
                .x = 58,
                .mod = -1,
                .colour = .BLUE,
                .type = .SIDE_SWING,
            },
            Maneuver{
                .name = "Hook Shield",
                .description = "placeholder",
                .pg = 32,
                .x = 54,
                .mod = -2,
                .colour = .RED,
                .type = .THRUST,
            },
            Maneuver{
                .name = "Hook Leg",
                .description = "placeholder",
                .pg = 14,
                .x = 60,
                .mod = -4,
                .colour = .BLUE,
                .type = .THRUST,
            },
            Maneuver{
                .name = "Kick",
                .description = "placeholder",
                .pg = 34,
                .x = 56,
                .mod = -1,
                .colour = .BLUE,
                .type = .SPECIAL,
            },
            Maneuver{
                .name = "Wild Swing",
                .description = "placeholder",
                .pg = 40,
                .x = 58,
                .mod = 3,
                .colour = .YELLOW,
                .type = .SPECIAL,
            },
            Maneuver{
                .name = "Dislodge Weapon",
                .description = "placeholder",
                .pg = 30,
                .x = 58,
                .mod = -4,
                .colour = .BLUE,
                .type = .SPECIAL,
            },
            Maneuver{
                .name = "Retrieve Weapon",
                .description = "placeholder",
                .pg = 46,
                .x = 52,
                .mod = -6,
                .colour = .GREEN,
                .type = .SPECIAL,
            },
            Maneuver{
                .name = "Up",
                .description = "placeholder",
                .pg = 18,
                .x = 52,
                .mod = -6,
                .colour = .GREEN,
                .type = .JUMP,
            },
            Maneuver{
                .name = "Dodge",
                .description = "placeholder",
                .pg = 8,
                .x = 52,
                .mod = -4,
                .colour = .YELLOW,
                .type = .JUMP,
            },
            Maneuver{
                .name = "Duck",
                .description = "placeholder",
                .pg = 20,
                .x = 52,
                .mod = -5,
                .colour = .GREEN,
                .type = .JUMP,
            },
            Maneuver{
                .name = "Away",
                .description = "placeholder",
                .pg = 16,
                .x = 62,
                .mod = -4,
                .colour = .YELLOW,
                .type = .JUMP,
            },
            Maneuver{
                .name = "Charge",
                .description = "placeholder",
                .pg = 50,
                .x = 50,
                .mod = 5,
                .colour = .WHITE,
                .type = .EXTENDED_RANGE,
            },
            Maneuver{
                .name = "Swing High",
                .description = "placeholder",
                .pg = 64,
                .x = 64,
                .mod = 3,
                .colour = .BLACK,
                .type = .EXTENDED_RANGE,
            },
            Maneuver{
                .name = "Swing Low",
                .description = "placeholder",
                .pg = 58,
                .x = 58,
                .mod = 3,
                .colour = .BLACK,
                .type = .EXTENDED_RANGE,
            },
            Maneuver{
                .name = "Thrust Low",
                .description = "placeholder",
                .pg = 60,
                .x = 60,
                .mod = 0,
                .colour = .WHITE,
                .type = .EXTENDED_RANGE,
            },
            Maneuver{
                .name = "Block & Close",
                .description = "placeholder",
                .pg = 56,
                .x = 56,
                .mod = 0,
                .colour = .BROWN,
                .type = .EXTENDED_RANGE,
            },
            Maneuver{
                .name = "Dodge",
                .description = "placeholder",
                .pg = 52,
                .x = 52,
                .mod = -4,
                .colour = .BROWN,
                .type = .EXTENDED_RANGE,
            },
            Maneuver{
                .name = "Jump Back",
                .description = "placeholder",
                .pg = 62,
                .x = 62,
                .mod = -4,
                .colour = .BROWN,
                .type = .EXTENDED_RANGE,
            },
        },
    };
}

fn newDwarfInChainmailWithTwoHandedAx(name: []const u8) Player {
    return Player{
        .character_booklet = dwarfInChainmailWithTwoHandedAxBooklet,
        .character_sheet = dwarfInChainmailWithTwoHandedAxSheet(name),
        .current_page = 57,
        .required_maneuver_types = ManeuverType.initial_required,
        .forbidden_maneuver_types = ManeuverType.initial_forbidden,
        .required_maneuver_colours = ManeuverColour.initial_required,
        .forbidden_maneuver_colours = ManeuverColour.initial_forbidden,
    };
}
