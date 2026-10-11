extends Control

const SAVE_PATH := "user://spinoria_save.cfg"
const STARTING_COINS := 250
const SPIN_COST := 25

var coins: int = STARTING_COINS
var spins: int = 10
var village_level: int = 1
var total_raids: int = 0
var rng := RandomNumberGenerator.new()

var coins_label: Label
var spins_label: Label
var village_label: Label
var status_label: Label
var reel_labels: Array[Label] = []
var spin_button: Button
var upgrade_button: Button

var symbols := ["🪙", "🪙", "🛡️", "⚔️", "💎", "🎁"]

func _ready() -> void:
	rng.randomize()
	_load_game()
	_build_ui()
	_refresh_ui()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("#101b35")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 16)
	root.add_theme_constant_override("margin_left", 28)
	root.add_theme_constant_override("margin_right", 28)
	root.add_theme_constant_override("margin_top", 24)
	root.add_theme_constant_override("margin_bottom", 24)
	add_child(root)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(header)

	var logo := Label.new()
	logo.text = "✦ SPINORIA ✦"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.add_theme_font_size_override("font_size", 38)
	logo.add_theme_color_override("font_color", Color("#ffe58a"))
	header.add_child(logo)

	var subtitle := Label.new()
	subtitle.text = "SPIN • BUILD • RAID"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color("#9fc8ff"))
	root.add_child(subtitle)

	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 12)
	root.add_child(stats)
	coins_label = _stat_card(stats, "🪙 COINS", "0")
	spins_label = _stat_card(stats, "🎟️ SPINS", "0")

	var island := PanelContainer.new()
	island.size_flags_vertical = Control.SIZE_EXPAND_FILL
	island.add_theme_stylebox_override("panel", _panel_style("#244c68", 26))
	root.add_child(island)

	var island_content := VBoxContainer.new()
	island_content.alignment = BoxContainer.ALIGNMENT_CENTER
	island_content.add_theme_constant_override("separation", 10)
	island.add_child(island_content)

	var world_title := Label.new()
	world_title.text = "YOUR FIRST ISLAND"
	world_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	world_title.add_theme_font_size_override("font_size", 20)
	world_title.add_theme_color_override("font_color", Color("#fff0bd"))
	island_content.add_child(world_title)

	var island_art := Label.new()
	island_art.text = "        ☁️      ☁️\n\n   🌲  🏰  🌳\n  🏡  🏠  🏡\n🌊🌊🌊🌊🌊🌊🌊"
	island_art.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	island_art.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	island_art.add_theme_font_size_override("font_size", 34)
	island_art.size_flags_vertical = Control.SIZE_EXPAND_FILL
	island_content.add_child(island_art)

	village_label = Label.new()
	village_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	village_label.add_theme_font_size_override("font_size", 18)
	village_label.add_theme_color_override("font_color", Color("#ffffff"))
	island_content.add_child(village_label)

	var slot_panel := PanelContainer.new()
	slot_panel.add_theme_stylebox_override("panel", _panel_style("#182642", 22))
	root.add_child(slot_panel)

	var slot_content := VBoxContainer.new()
	slot_content.add_theme_constant_override("separation", 12)
	slot_panel.add_child(slot_content)

	var slot_title := Label.new()
	slot_title.text = "LUCKY SPIN"
	slot_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot_title.add_theme_font_size_override("font_size", 24)
	slot_title.add_theme_color_override("font_color", Color("#ffe58a"))
	slot_content.add_child(slot_title)

	var reels := HBoxContainer.new()
	reels.alignment = BoxContainer.ALIGNMENT_CENTER
	reels.add_theme_constant_override("separation", 10)
	slot_content.add_child(reels)

	for i in range(3):
		var reel := PanelContainer.new()
		reel.custom_minimum_size = Vector2(90, 82)
		reel.add_theme_stylebox_override("panel", _panel_style("#f6f0db", 14))
		reels.add_child(reel)
		var symbol := Label.new()
		symbol.text = ["🪙", "🛡️", "💎"][i]
		symbol.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		symbol.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		symbol.add_theme_font_size_override("font_size", 36)
		symbol.add_theme_color_override("font_color", Color("#182642"))
		reel.add_child(symbol)
		reel_labels.append(symbol)

	status_label = Label.new()
	status_label.text = "Spin to win coins and grow your island!"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color("#d7e6ff"))
	slot_content.add_child(status_label)

	spin_button = _make_button("🎰  SPIN  •  25 COINS", "#ffb82e", "#4c2d00")
	spin_button.pressed.connect(_on_spin_pressed)
	root.add_child(spin_button)

	upgrade_button = _make_button("🏗️  UPGRADE VILLAGE", "#50d89a", "#073b2a")
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	root.add_child(upgrade_button)

	var footer := Label.new()
	footer.text = "Offline prototype • Progress saves on this device"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color("#91a7ca"))
	root.add_child(footer)

func _stat_card(parent: HBoxContainer, heading: String, value: String) -> Label:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _panel_style("#243657", 16))
	parent.add_child(card)
	var label := Label.new()
	label.text = heading + "\n" + value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("#ffffff"))
	card.add_child(label)
	if heading.begins_with("🪙"):
		coins_label = label
	else:
		spins_label = label
	return label

func _make_button(caption: String, fill: String, ink: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0, 68)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color(ink))
	button.add_theme_stylebox_override("normal", _panel_style(fill, 18))
	button.add_theme_stylebox_override("hover", _panel_style(fill, 18))
	button.add_theme_stylebox_override("pressed", _panel_style("#ffffff", 18))
	button.add_theme_stylebox_override("focus", _panel_style(fill, 18))
	return button

func _panel_style(fill: String, corners: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill)
	style.corner_radius_top_left = corners
	style.corner_radius_top_right = corners
	style.corner_radius_bottom_left = corners
	style.corner_radius_bottom_right = corners
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func _on_spin_pressed() -> void:
	if spins <= 0:
		status_label.text = "No spins left! Come back later for more."
		return
	if coins < SPIN_COST:
		status_label.text = "Not enough coins. Upgrade your luck by raiding later!"
		return

	spins -= 1
	coins -= SPIN_COST
	var results: Array[String] = []
	for reel in reel_labels:
		var symbol: String = symbols[rng.randi_range(0, symbols.size() - 1)]
		reel.text = symbol
		results.append(symbol)

	var coin_count := 0
	var shields := 0
	var swords := 0
	var gems := 0
	for symbol in results:
		if symbol == "🪙":
			coin_count += 1
		elif symbol == "🛡️":
			shields += 1
		elif symbol == "⚔️":
			swords += 1
		elif symbol == "💎":
			gems += 1

	var reward := 0
	if coin_count == 3:
		reward = 250
	elif coin_count == 2:
		reward = 90
	else:
		reward = coin_count * 25
	if shields == 3:
		reward += 100
		status_label.text = "TRIPLE SHIELD! Your island is protected. +100 bonus!"
	elif swords >= 2:
		var raid_reward := 75 * village_level
		reward += raid_reward
		total_raids += 1
		status_label.text = "RAID SUCCESS! You found %d bonus coins!" % raid_reward
	elif gems >= 2:
		reward += 150
		status_label.text = "GEM JACKPOT! +150 bonus coins!"
	else:
		status_label.text = "You won %d coins. Keep spinning!" % reward

	coins += reward
	_save_game()
	_refresh_ui()

func _on_upgrade_pressed() -> void:
	var cost := village_level * 150
	if coins < cost:
		status_label.text = "Need %d coins to upgrade your village." % cost
		return
	coins -= cost
	village_level += 1
	status_label.text = "Village upgraded to level %d! Next upgrade: %d coins." % [village_level, village_level * 150]
	_save_game()
	_refresh_ui()

func _refresh_ui() -> void:
	if is_instance_valid(coins_label):
		coins_label.text = "🪙 COINS\n%d" % coins
	if is_instance_valid(spins_label):
		spins_label.text = "🎟️ SPINS\n%d" % spins
	if is_instance_valid(village_label):
		village_label.text = "Village Level %d  •  %d raids" % [village_level, total_raids]
	if is_instance_valid(spin_button):
		spin_button.disabled = spins <= 0 or coins < SPIN_COST
	if is_instance_valid(upgrade_button):
		upgrade_button.text = "🏗️  UPGRADE VILLAGE  •  %d COINS" % (village_level * 150)
		upgrade_button.disabled = coins < village_level * 150

func _save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "coins", coins)
	config.set_value("progress", "spins", spins)
	config.set_value("progress", "village_level", village_level)
	config.set_value("progress", "total_raids", total_raids)
	config.save(SAVE_PATH)

func _load_game() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	coins = int(config.get_value("progress", "coins", STARTING_COINS))
	spins = int(config.get_value("progress", "spins", 10))
	village_level = int(config.get_value("progress", "village_level", 1))
	total_raids = int(config.get_value("progress", "total_raids", 0))
