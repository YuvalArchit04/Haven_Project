extends RefCounted

static var easy_mode: bool = true
static var sound_enabled: bool = true

static var total_gems: int = 10
static var current_skin: String = "Classic Yellow"
static var unlocked_skins: Array = ["Classic Yellow"]

const SKINS = {
	"Classic Yellow": {"color": Color(1.0, 1.0, 1.0, 1.0), "cost": 0},
	"Neon Cyan": {"color": Color(0.2, 0.95, 1.0, 1.0), "cost": 2},
	"Crimson Rage": {"color": Color(1.0, 0.25, 0.25, 1.0), "cost": 3},
	"Emerald Void": {"color": Color(0.25, 1.0, 0.45, 1.0), "cost": 4},
	"Royal Violet": {"color": Color(0.8, 0.35, 1.0, 1.0), "cost": 5}
}
