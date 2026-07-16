# Enemy Prompts for anything.world
# 13 enemies: 9 humans + 4 hardware
# Each entry: name, prompt, style, polycount, texture_resolution, rig, animations

enemies = [
    # === HUMANS (9) - Wave 4, 5, 6 ===
    {
        "name": "chr_enemy_infantry",
        "prompt": "Tactical infantry officer, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. Height: 1.8m, mass: 80kg. Fit human male, police/military tactical gear. Skin: realistic human tones (pale to olive), sweat, fatigue, minor combat wounds. Uniform: navy/dark blue police tactical (C.O.S. palette #141428, #1E1E3A), ballistic vest, helmet with visor up showing face. Weapon: assault rifle slung, sidearm holstered. Posture: alert but nervous, weight shifted, finger near trigger guard, breathing visible. Silhouette: recognizable police/military profile, slightly hunched defensive stance. Human elements: fear in eyes, radio chatter posture, tactical communication hand signals, fatigue. Lighting: neutral studio, subtle rim light for silhouette clarity. Color palette STRICTLY limited to 27-color Wave0 bible (C.O.S. sub-palette for enemies + blood accents). Render style: PBR-ready reference, clean topology suggestion, 2048 texture density equivalent. Negative: monster, zombie, mutated, supernatural, cartoon, low-poly retro, anime, cel-shaded, clean/heroic, symmetrical, generic zombie, cluttered background, watermark, text.",
        "style": "realistic",
        "polycount": 10000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle", "walk", "run", "attack", "death", "hit", "alert", "aim"]
    },
    {
        "name": "chr_enemy_shield",
        "prompt": "Riot shield officer, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. Height: 1.85m, mass: 105kg. Large, powerful build, riot gear specialist. Skin: realistic, flushed from exertion, sweat dripping. Armor: full riot suit (navy/black #0A0A12, #141428), heavy ballistic shield (1.8m x 0.8m, polycarbonate + aluminum frame, scratched, police markings), shin guards, extended chest plate. Helmet: full face riot helmet with reinforced visor (slightly cracked), neck protector. Weapon: compact SMG or pistol in right hand (shield left). Posture: braced behind shield, low center of gravity, advancing slowly, shield edge forward. Silhouette: rectangular shield dominates profile, unmistakable at distance. Human elements: visible breathing behind visor, shield bash readiness, radio earpiece, tactical patience. Lighting: neutral studio, rim light on shield edge. Color palette: Wave0 C.O.S. (dark navy/black) + transparent shield + realistic skin. Render style: PBR-ready, clean topology, 2048 texture density. Negative: monster, zombie, mutated, supernatural, cartoon, low-poly, anime, cel-shaded, heroic, clean, symmetrical, generic zombie, cluttered background.",
        "style": "realistic",
        "polycount": 12000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle", "walk", "run", "shield_bash", "death", "hit", "alert", "aim"]
    },
    {
        "name": "chr_enemy_flamethrower",
        "prompt": "Flamethrower operator, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. Height: 1.82m, mass: 90kg. Asbestos/NOMEX suit, dual fuel tanks on back. Skin: realistic, soot-streaked face, sweat, heat exhaustion visible. Suit: heavy fire-retardant (dark navy #141428, #1E1E3A), scorched patches, melted patches, reflective strips, cooling tubes. Tanks: pressurized nitrogen/propellant (yellow hazard labels), insulated hoses to nozzle. Nozzle: mounted on right forearm, pilot light visible (small warm emissive #D8A820 glow), safety engaged. Mask: full face respirator with voice amplifier, clear visor (fogging slightly). Posture: hunched under tank weight, nozzle pointed down/safe, slow deliberate movement. Silhouette: twin tank hump on back, nozzle arm extended, distinctive profile. Human elements: heat stress, checking gauges, radio comms, visible fear behind mask. Lighting: neutral studio, subtle pilot light glow. Color palette: Wave0 C.O.S. (dark navy) + hazard yellow labels + single warm pilot light emissive. Render style: PBR-ready. Negative: monster, zombie, mutated, burning, supernatural, cartoon, low-poly, anime, cel-shaded, clean, heroic, symmetrical, generic fire enemy.",
        "style": "realistic",
        "polycount": 11000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle", "walk", "run", "attack", "death", "hit", "alert", "fuel_check"]
    },
    {
        "name": "chr_enemy_sniper",
        "prompt": "Police sniper / precision marksman, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. Height: 1.78m, mass: 70kg. Lean, wiry, ghillie-style concealment wrap (urban: concrete/grey tones). Skin: realistic, paper-thin pale (#3A3A6E highlights), visible veins, one eye closed (shooting), other intense focus. Ghillie suit: fused to skin, foliage dead and blackened (#0A0A12, #141428), not camouflaged — parasitic. Rifle: bolt-action .308 or semi-auto DMR with suppressor, bipod deployed, high-mag scope. Scope replaces left eye (glowing #FBF2A2). Left hand: trigger finger only, other digits atrophied. Posture: prone or deep crouch, perfectly still, controlled breathing. Silhouette: rifle barrel extends, low profile, recognizable sniper shape. Human elements: extreme focus, spotter communication (hand on radio), trigger discipline, fatigue micro-tremors. Lighting: neutral studio, single catch-light in scope eye. Color palette: Wave0 C.O.S. (urban greys) + realistic skin + rifle matte black + single cool emissive for scope. Render style: PBR-ready. Negative: monster, zombie, mutated, cybernetic eye, supernatural, cartoon, low-poly, anime, cel-shaded, clean, heroic, symmetrical, generic sniper, cluttered background.",
        "style": "realistic",
        "polycount": 9000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle", "aim", "shoot", "reload", "death", "hit", "spotter_comm"]
    },
    {
        "name": "chr_enemy_engineer",
        "prompt": "Tactical engineer / drone operator, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. Height: 1.75m, mass: 75kg. Average build, tool harness, tablet/controller. Skin: realistic, oil/grease stains on hands/face, focused expression. Uniform: navy tactical (#1E1E3A) with tool pouches, knee pads, cable loops. Backpack: compact drone deployer (3x micro-turrets folded), antenna, battery pack. Tablet: ruggedized, displaying turret deployment UI, live feeds. Helmet: bump helmet with AR visor (showing data streams), or headset + cap. Tool belt: multimeter, cutters, EMP charges, zip ties, spare mags. Posture: crouched deploying turret, one hand on tablet, other ready weapon. Silhouette: backpack hump + asymmetric cybernetic arm = unique profile. Human elements: intense concentration, talking to drone ('Unit 3, deploy'), sweat, tactical urgency. Lighting: neutral studio, subtle screen glow on visor/tablet. Color palette: Wave0 C.O.S. + tactical gear + screen blue emissive (minimal). Render style: PBR-ready. Negative: monster, zombie, mutated, cybernetic arm, supernatural, cartoon, low-poly, anime, cel-shaded, clean, heroic, symmetrical, generic engineer.",
        "style": "realistic",
        "polycount": 10000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle", "walk", "run", "deploy_turret", "tablet_use", "death", "hit", "alert"]
    },
    {
        "name": "chr_enemy_medic",
        "prompt": "Tactical combat medic, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. Height: 1.75m, mass: 72kg. Fit, medical harness over armor. Skin: realistic, clean, professional, focused calm under pressure. Armor: standard tactical vest (navy #1E1E3A) with red cross patches (velcro, removable), ballistic plates. Harness: IFAK pouches, tourniquets, auto-injectors (morphine, epinephrine, combat stim), blood bags (cooling). Helmet: standard ballistic with medic cross, or bare head with headset. Weapon: compact PDW/SMG slung (self-defense only), pistol primary. Posture: crouched over casualty, hands working, scanning for threats, professional urgency. Silhouette: medical cross patches + harness + crouched treatment posture. Human elements: steady hands despite chaos, talking to patient ('Stay with me'), radio calling evac, emotional control. Lighting: neutral studio, cold clinical rim light. Color palette: Wave0 C.O.S. + medical red cross (only color accent) + realistic skin. Render style: PBR-ready. Negative: monster, zombie, mutated, supernatural, cartoon, low-poly, anime, cel-shaded, sinister, evil, generic medic.",
        "style": "realistic",
        "polycount": 9000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle", "walk", "run", "heal", "revive", "death", "hit", "alert"]
    },
    {
        "name": "chr_enemy_heavy",
        "prompt": "Heavy weapons operator / SAW gunner, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. Height: 1.9m, mass: 110kg. Large, muscular build, heavy ammo bearer. Skin: realistic, flushed, veins visible on arms/neck from load bearing. Armor: enhanced ballistic (thicker plates #141428), groin/neck protection, load-bearing frame for ammo. Weapon: M249 SAW / LMG (belt-fed), bipod, spare barrel bag, 200-round soft pouch on weapon. Ammo: linked belts across chest (bandolier), drum mags on belt, assistant gunner carries more. Helmet: ballistic with comms, cooling fan mount. Posture: braced firing position, weapon shouldered, wide stance, managing recoil. Silhouette: boxy LMG profile + ammo belts + large frame = unmistakable. Human elements: recoil management, barrel change drill, calling targets, sweat in eyes, physical strain. Lighting: neutral studio, heavy rim on weapon. Color palette: Wave0 C.O.S. (darkest navy/black) + ammo brass + realistic skin. Render style: PBR-ready, high detail on weapon. Negative: monster, zombie, mutated, supernatural, cartoon, low-poly, anime, cel-shaded, mech suit, generic heavy gunner.",
        "style": "realistic",
        "polycount": 14000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle", "walk", "run", "fire", "reload", "barrel_change", "death", "hit", "alert"]
    },
    {
        "name": "chr_enemy_elite",
        "prompt": "Elite tactical operator / Tier 1 SWAT, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. Height: 1.85m, mass: 85kg. Peak physical condition, operator build. Skin: realistic, minor scars, professional grooming, calm intensity. Armor: cutting-edge plate carrier (crye-style, navy #0A0A12), level IV plates, cummerbund, quick-release. Helmet: high-cut ballistic (ops-core style), rail mounts (light, camera, IR strobe), comms headset (peltor). Loadout: primary (MK18/CQBR + suppressor + optic + laser/IR), secondary (Glock 19 + RMR + light), breaching shotgun (slung). Kit: NVGs (stowed), IR laser/illuminator, flashbangs, breaching charges, comms (multi-band), GPS/ATAK. Exosuit: optional passive leg support (lockheed ONYX style, minimal), jump-capable boots. Posture: relaxed readiness, weapon low-ready, head on swivel, weight on balls of feet. Silhouette: operator-perfect, high-cut helmet + NVG mount + suppressed SBR = unmistakable elite. Human elements: calm professionalism, micro-adjustments, team hand signals, breathing control, thousand-yard stare. Lighting: neutral studio, subtle IR laser/illuminator glow (invisible to eye, visible to camera). Color palette: Wave0 C.O.S. (darkest navy/black) + tactical gear (realistic) + minimal IR emissive. Render style: PBR-ready, hero asset fidelity. Negative: monster, zombie, mutated, superhero, supernatural, cartoon, low-poly, anime, cel-shaded, generic soldier.",
        "style": "realistic",
        "polycount": 12000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle", "walk", "run", "tactical_move", "breach", "attack", "death", "hit", "alert", "nvg_deploy"]
    },
    {
        "name": "chr_enemy_juggernaut",
        "prompt": "Boss Juggernaut — EOD commander in powered exoskeleton, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. BOSS SCALE. Height: 2.3m (in suit), mass: 350kg (suit + man). EOD bomb suit + tactical exoskeleton hybrid. Suit: full-body Level IV+ ballistic (custom, navy/black #0A0A12, #141428), articulated joints, hydraulic assist. Helmet: full enclosure, multi-spectral visor (thermal/night/EM), HUD, voice amplifier, breather. Right arm: integrated 40mm automatic grenade launcher (drum-fed), recoil mitigation. Left arm: ballistic tower shield (deployable, 2m tall), hydraulic ram for bash. Dorsal: ammo drum (grenades), power pack (exoskeleton), cooling, comms array. Legs: hydraulic assist (sprint, jump, kick force), magnetic anchoring. Phase 2 (70% HP): suit damaged, hydraulic fluid leaking, visor cracked, movement faster but exposed. Phase 3 (40% HP): helmet off — human face visible (scarred, determined), suit failing, desperate CQC. Silhouette: massive rectangular bulk + grenade launcher + tower shield + exoskeleton frame. Human elements: commander's voice over PA ('Hold the line!'), visible face in phase 3 (fear/rage), radio traffic. Lighting: neutral studio, strong rim on scale, visor glow (phase 1-2), face light (phase 3). Color palette: Wave0 C.O.S. (darkest) + hydraulic fluid (dark) + visor emissive #FBF2A2. Render style: PBR-ready, hero boss asset. Negative: monster, mutant, supernatural, mech pilot visible (phase 1-2), cartoon, low-poly, anime, cel-shaded.",
        "style": "realistic",
        "polycount": 28000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle", "walk", "advance", "shoot_40mm", "shield_bash", "phase2_damage", "helmet_off", "phase3_cqc", "death"]
    },
    # === HARDWARE (4) - Wave 5, 6 ===
    {
        "name": "chr_enemy_drone",
        "prompt": "Tactical quadcopter UAV / recon drone, third-person action horror game, semi-realistic AA style. Full body orthographic views (front/side/back/top), T-pose equivalent (hovering). Dimensions: 0.5m diameter, mass: 3kg. Police/military tactical quadcopter. Chassis: carbon fiber matte black/dark grey (#0A0A12, #141428), ruggedized, weather-sealed. Rotors: 4x low-noise propellers (folding for transport), prop guards. Sensor turret: gimballed EO/IR (day/night camera), laser designator, spotlight. Payload: none (recon only) OR 2x 40mm less-lethal launchers (pepper/impact). Landing: skids with contact sensors. Status lights: minimal (stealth), IR strobe for friendly ID. Silhouette: distinct X-rotor + sensor ball + skids. Technical elements: clean industrial design, police/military markings, antenna array. Lighting: neutral studio, subtle rotor blur suggestion. Color palette: Wave0 C.O.S. (industrial darks) + minimal status LEDs. Render style: PBR-ready, hard surface precision. Negative: monster, organic, biological, supernatural, cartoon, low-poly, anime, cel-shaded, sci-fi fancy, Gundam, transformer, cluttered background.",
        "style": "realistic",
        "polycount": 4000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle_hover", "patrol", "detect", "strafe", "retreat", "crash", "recharge"]
    },
    {
        "name": "chr_enemy_robot",
        "prompt": "Tactical EOD / SWAT robot, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. Height: 1.2m (tracked), mass: 180kg. Tracked/wheeled hybrid, manipulator arm. Chassis: hardened steel/aluminum (dark grey #141428, #1E1E3A), blast-resistant, police markings. Tracks: rubber-padded, stair-climbing capable, low profile. Manipulator: 6-DOF arm, interchangeable gripper/disruptor/x-ray panel. Sensors: 360° camera mast, LIDAR, gas/CBRNE detectors, microphone array. Tools: breaching charge placer, door opener, window breaker, negotiator phone deployer. Control: tethered (fiber optic) or wireless, operator station remote. Silhouette: low tracked base + tall mast + articulated arm = distinct robot profile. Technical elements: industrial rugged, cable management, access panels, warning labels. Lighting: neutral studio, sensor mast lights. Color palette: Wave0 C.O.S. (industrial greys) + police blue accents + warning yellow. Render style: PBR-ready, hard surface mastery. Negative: monster, organic, humanoid, supernatural, cartoon, low-poly, anime, cel-shaded, Gundam, sci-fi, transformer, cluttered background.",
        "style": "realistic",
        "polycount": 18000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle", "drive", "manipulate", "climb_stairs", "deploy_tool", "tether_reel", "damage", "destroyed"]
    },
    {
        "name": "chr_enemy_assault_robot",
        "prompt": "Boss Assault Robot — advanced military combat prototype, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. BOSS SCALE. Height: 2.8m, mass: 2,200kg. Purpose-built combat robot, no human inside. Chassis: modular composite armor (dark grey #141428, #1E1E3A), sloped surfaces, reactive plates. Head: sensor suite (LIDAR, thermal, radar, EO/IR), twin 20mm chain guns (coaxial), laser designator. Torso: central power cell (shielded), AI core (armored), missile bay (12x JAGM-class). Arms: modular — left: 30mm autocannon, right: manipulator / laser / EMP projector (swappable). Legs: digitigrade, high-torque actuators, shock absorption, silent running mode. Shoulders: VLS cells (loitering munitions), point-defense CIWS. Phase 1 (100-60% HP): integrated, combined arms, area denial, precision fire. Phase 2 (60-30% HP): armor shedding — 5 independent parts (head drone, back turret, 2 arm crawlers, 2 leg walkers) attack simultaneously. Phase 3 (30-0% HP): core exposed (pulsing coolant leak #D8A820), all weapons free, self-destruct timer. Weak points: Sensor head (2x), Power cell rear (3x), Joint actuators (slow), Weapon mounts (disarm). Silhouette: Phase 1 = imposing digitigrade mech; Phase 2 = swarm of distinct parts; Phase 3 = blinding core. Technical elements: clean military prototype, warning labels, access panels, test markings. Lighting: neutral studio, core pulse, laser lines, missile trails. Color palette: Wave0 C.O.S. (industrial) + coolant leak emissive + laser/weapon emissive. Render style: PBR-ready, modular design clarity. Negative: monster, organic, humanoid pilot, supernatural, cartoon, low-poly, anime, cel-shaded, Gundam, transformer, cluttered background.",
        "style": "realistic",
        "polycount": 30000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle", "walk", "fire_laser", "fire_missiles", "stomp", "phase2_separate", "phase3_overload", "death_explosion"]
    },
    {
        "name": "chr_enemy_predator_heli",
        "prompt": "Boss Predator Helicopter — tactical attack gunship, third-person action horror game, semi-realistic AA style. Full body T-pose and A-pose, front/side/back orthographic views. BOSS SCALE. Height: 4.5m (rotor diameter 14m), mass: 5,200kg. Military attack helicopter (AH-64 / Mi-28 / Ka-52 class). Airframe: composite armor (dark grey/navy #0A0A12-#2A2A4E), stealthy lines, police/military markings. Rotor: 4-5 blade main (composite, low noise), 4-blade tail (or coaxial), IR-suppressed exhaust. Nose: M230 30mm chain gun (turreted, slaved to helmet sight), laser/IR tracker. Stub wings (4 stations): Hellfire/L-JAGM missiles, Hydra 70 rocket pods, AIM-92 Stinger, fuel tanks. Sensors: mast-mounted sight (MMS), FLIR, radar (Longbow), DIRCM (laser jammer). Crew: 2 (pilot + gunner) — visible in canopy, helmet-mounted displays, oxygen masks. Landing gear: retractable, crashworthy. Phase 1 (air): stand-off attacks, missile salvos, gun runs, pop-up tactics, terrain masking. Phase 2 (hover/land): deploys 8-man elite team (fast-rope), transitions to CAS, gunner engages directly. Phase 3 (desperate): weapons free, all stations, DIRCM saturated, canopy damaged, crew visible/fighting. Weak points: Rotor hub/mast (2x), Engine exhausts (3x), Sensor mast (blind), Canopy (crew), Ammo bay doors (when open). Silhouette: Phase 1 = unmistakable attack helo; Phase 2 = hovering gunship + ropes; Phase 3 = damaged, smoking. Technical elements: accurate military helo, panel lines, rivets, antennas, warning decals, weapons pylons. Lighting: neutral studio, rotor blur, engine heat shimmer, searchlight/IR illuminator. Color palette: Wave0 C.O.S. (military darks) + engine heat emissive + searchlight + warning lights. Render style: PBR-ready, accurate military vehicle fidelity. Negative: monster, organic, transforming mech, supernatural, cartoon, low-poly, anime, cel-shaded, sci-fi fancy, generic helicopter.",
        "style": "realistic",
        "polycount": 35000,
        "texture_resolution": 2048,
        "generate_rig": True,
        "generate_animations": True,
        "animation_types": ["idle_hover", "strafe", "rocket_salvo", "gun_run", "land", "deploy_troops", "takeoff", "phase3_all_out", "crash_sequence"]
    },
]