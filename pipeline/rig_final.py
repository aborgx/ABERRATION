#!/usr/bin/env python3
"""
ABERRATION — rig_final.py  (Blender 5.2 LTS)

Produces chr_player_rigged_anim.glb with:
  - ARMATURE type (NOT EMPTY/Rigify) — 66 bones, mesh2motion naming
  - MESH "model" (~22K verts, humanoid Z=1.87m) with valid skin weights
  - 6 procedural animations (idle, walk, run, jump, attack, death)

Approach (Option B + DataTransfer modifier):
  1. Import ProtagonistaRig_M2M.glb → UniRigArmature (66 bones) + zombie_character (with weights)
  2. Import base_basic_pbr.glb → clean mesh (humanoid, 22K verts)
  3. Align clean mesh to zombie position
  4. DataTransfer modifier: copy VGROUP_WEIGHTS from zombie → clean mesh (NEAREST_VERTEX)
  5. Apply modifier, remove zombie_character
  6. Manual Armature modifier (NO parent_set) — avoids the ARMATURE_AUTO 0-weights bug
  7. Generate procedural animations on the armature
  8. Create PBR material from source textures (basecolor, normal, RM)
  9. Export GLB (only armature + mesh, export_skins=True, export_animations=True)

CRITICAL FIXES for Blender 5.2:
  - NO bpy.ops.object.armature_deform_add  (removed in 5.2)
  - NO edit_bones.clear()                  (removed in 5.2)
  - NO parent_set(type='ARMATURE_AUTO')    (0 weights on GLB imports)
  - NO Rigify generate → export            (exports as EMPTY type)
  - NO Action.fcurves                      (.fcurves removed in 5.2)

Usage:
  blender.exe --background --python pipeline/rig_final.py
  (from Windows; WSL: blender.exe is at E:\\Applicazioni\\blender-5.2.0-windows-x64\\blender.exe)
"""

import bpy
import os
import sys

# ─── Paths ─────────────────────────────────────────────────────────────────
BASE = "E:/Giochini/Giuseppe"
M2M_PATH = f"{BASE}/Mesh/ProtagonistaRig_M2M.glb"
CLEAN_PATH = f"{BASE}/Mesh/Abberration2/base_basic_pbr.glb"
OUTPUT_PATH = f"{BASE}/scenes/player/chr_player_rigged_anim.glb"

# ─── Helpers ───────────────────────────────────────────────────────────────

def log(msg: str) -> None:
    print(f"[RIG] {msg}")


def line() -> None:
    print("=" * 60)


def clear_scene() -> None:
    """Delete all objects and orphan data blocks."""
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for coll in list(bpy.data.collections):
        if coll.users == 0:
            bpy.data.collections.remove(coll)


def import_glb(path: str) -> None:
    if not os.path.exists(path):
        log(f"ERROR: File not found: {path}")
        sys.exit(1)
    bpy.ops.import_scene.gltf(filepath=path)


def get_armature() -> bpy.types.Object | None:
    for o in bpy.context.scene.objects:
        if o.type == 'ARMATURE':
            return o
    return None


def get_mesh(exclude: list | None = None) -> bpy.types.Object | None:
    """Return the first MESH object not in the exclude list."""
    exclude = exclude or []
    for o in bpy.context.scene.objects:
        if o.type == 'MESH' and o not in exclude:
            return o
    return None


def find_bone_by_prefix(bone_names: list[str], *prefixes: str) -> str | None:
    """Find a bone by testing prefixes (case-insensitive, exact or startswith)."""
    for bn in bone_names:
        for p in prefixes:
            if bn.lower() == p.lower() or bn.lower().startswith(p.lower()):
                return bn
    return None


def verify_weights(mesh: bpy.types.Object, label: str) -> bool:
    """Print vertex group stats. Return True if any vertex has weights."""
    has_w = any(len(v.groups) > 0 for v in mesh.data.vertices)
    vg_count = len(mesh.vertex_groups)
    verts = len(mesh.data.vertices)
    log(f"  {label}: {verts} verts, VG={vg_count}, Has weights: {has_w}")
    return has_w


# ─── Bone detection ───────────────────────────────────────────────────────

def detect_bones(armature: bpy.types.Object) -> dict[str, str | None]:
    """Map semantic bone keys to actual bone names in this armature."""
    bone_names = [b.name for b in armature.data.bones]
    log(f"  Bone count: {len(bone_names)}")
    log(f"  Sample bones: {bone_names[:15]}...")

    # Pre-built mapping: Mixamo / mesh2motion naming variants
    candidate_map = {
        'hips':   ['Hips', 'Root', 'Pelvis', 'hip'],
        'spine':  ['Spine', 'spine'],
        'spine1': ['Spine1', 'Spine.001', 'spine1'],
        'spine2': ['Spine2', 'Spine.002', 'spine2'],
        'neck':   ['Neck', 'neck'],
        'head':   ['Head', 'head'],
        'larm':   ['LeftArm', 'upperarm_l', 'upper_arm.L', 'UpperArm.L'],
        'rarm':   ['RightArm', 'upperarm_r', 'upper_arm.R', 'UpperArm.R'],
        'lfore':  ['LeftForeArm', 'lowerarm_l', 'forearm.L', 'ForeArm.L'],
        'rfore':  ['RightForeArm', 'lowerarm_r', 'forearm.R', 'ForeArm.R'],
        'lhand':  ['LeftHand', 'hand_l', 'hand.L'],
        'rhand':  ['RightHand', 'hand_r', 'hand.R'],
        'lthigh': ['LeftUpLeg', 'thigh_l', 'upleg.L', 'UpLeg.L', 'thigh.L'],
        'rthigh': ['RightUpLeg', 'thigh_r', 'upleg.R', 'UpLeg.R', 'thigh.R'],
        'lleg':   ['LeftLeg', 'leg_l', 'leg.L', 'shin.L'],
        'rleg':   ['RightLeg', 'leg_r', 'leg.R', 'shin.R'],
        'lfoot':  ['LeftFoot', 'foot_l', 'foot.L'],
        'rfoot':  ['RightFoot', 'foot_r', 'foot.R'],
    }

    found = {}
    for key, prefixes in candidate_map.items():
        found[key] = find_bone_by_prefix(bone_names, *prefixes)

    log(f"  Bone mapping:")
    for k, v in found.items():
        log(f"    {k:8s} → {v}")
    return found


# ─── Weight transfer ──────────────────────────────────────────────────────

def transfer_weights_data_transfer(
    src_mesh: bpy.types.Object,
    dst_mesh: bpy.types.Object,
) -> bool:
    """Copy vertex group weights from src to dst using DataTransfer modifier.

    Works across topologies (NEAREST_VERTEX), then falls back to NEAREST_FACE.
    Handles Blender 5.2 API quirks.
    """
    log("  Transferring weights via DataTransfer modifier...")

    # 1. Ensure dst has matching vertex groups (empty)
    for vg in src_mesh.vertex_groups:
        if vg.name not in dst_mesh.vertex_groups:
            dst_mesh.vertex_groups.new(name=vg.name)

    # 2. Add DataTransfer modifier on dst, pointing to src
    mod = dst_mesh.modifiers.new(name="WeightTransfer", type='DATA_TRANSFER')
    mod.object = src_mesh
    mod.use_vert_data = True
    mod.data_types_verts = {'VGROUP_WEIGHTS'}
    mod.vert_mapping = 'NEAREST'

    # 3. Apply the modifier
    bpy.ops.object.select_all(action='DESELECT')
    dst_mesh.select_set(True)
    bpy.context.view_layer.objects.active = dst_mesh
    try:
        bpy.ops.object.modifier_apply(modifier=mod.name)
    except Exception as e:
        log(f"  Apply failed: {e}")

    # 4. Verify
    has_w = verify_weights(dst_mesh, "  clean mesh (after NEAREST_VERTEX)")
    if has_w:
        return True

    # 5. Fallback: POLY_NEAREST
    log("  NEAREST failed → trying POLY_NEAREST...")
    # Recreate vertex groups before retry
    dst_mesh.vertex_groups.clear()
    for vg in src_mesh.vertex_groups:
        dst_mesh.vertex_groups.new(name=vg.name)

    mod2 = dst_mesh.modifiers.new(name="WeightTransfer2", type='DATA_TRANSFER')
    mod2.object = src_mesh
    mod2.use_vert_data = True
    mod2.data_types_verts = {'VGROUP_WEIGHTS'}
    mod2.vert_mapping = 'POLY_NEAREST'

    try:
        bpy.ops.object.modifier_apply(modifier=mod2.name)
    except Exception as e:
        log(f"  Apply failed: {e}")

    return verify_weights(dst_mesh, "  clean mesh (after POLY_NEAREST)")


# ─── Material creation ────────────────────────────────────────────────────

def create_pbr_material(mesh: bpy.types.Object) -> None:
    """Create a PBR material from the 3 source textures and assign to mesh.

    Textures (from ProtagonistaRig_M2M source):
      - basecolor.jpg  → Principled BSDF Base Color (sRGB)
      - normal.jpg     → Normal Map node → Principled BSDF Normal (Non-Color)
      - rm.jpg         → Separate Color (RGB mode): R→Metallic, G→Roughness (Non-Color)

    Blender 5.2 compat: uses ShaderNodeSeparateColor(mode='RGB') — the modern
    replacement for the removed ShaderNodeSeparateRGB.
    """
    tex_dir = "E:/Giochini/Giuseppe/Mesh"
    tex_base = f"{tex_dir}/ProtagonistaRig_M2M_zombie_character_3d_model_basecolor.jpg"
    tex_norm = f"{tex_dir}/ProtagonistaRig_M2M_zombie_character_3d_model_normal.jpg"
    tex_rm   = f"{tex_dir}/ProtagonistaRig_M2M_zombie_character_3d_model_rm.jpg"

    log("  Loading PBR textures for clean mesh...")
    img_base = bpy.data.images.load(tex_base)
    img_norm = bpy.data.images.load(tex_norm)
    img_rm   = bpy.data.images.load(tex_rm)
    log(f"    basecolor: {img_base.size[0]}x{img_base.size[1]}")
    log(f"    normal:    {img_norm.size[0]}x{img_norm.size[1]}")
    log(f"    rm:        {img_rm.size[0]}x{img_rm.size[1]}")

    # Set Non-Color colorspace for normal and RM maps; basecolor stays sRGB.
    for img, label in [(img_norm, "normal"), (img_rm, "rm")]:
        try:
            img.colorspace_settings.name = "Non-Color"
        except Exception as e:
            log(f"    Warning: could not set colorspace on {label}: {e}")

    # Create material with node tree
    mat = bpy.data.materials.new("chr_player_mat")
    mat.use_nodes = True
    tree = mat.node_tree
    nodes = tree.nodes
    links = tree.links
    nodes.clear()

    # --- Nodes ---
    # Output
    out_node = nodes.new(type='ShaderNodeOutputMaterial')
    out_node.location = (800, 0)

    # Principled BSDF
    bsdf = nodes.new(type='ShaderNodeBsdfPrincipled')
    bsdf.location = (400, 0)

    # Base Color image texture
    img_tex_base = nodes.new(type='ShaderNodeTexImage')
    img_tex_base.image = img_base
    img_tex_base.location = (-600, 300)
    img_tex_base.label = "Base Color"

    # Normal map image texture
    img_tex_norm = nodes.new(type='ShaderNodeTexImage')
    img_tex_norm.image = img_norm
    img_tex_norm.location = (-600, 0)
    img_tex_norm.label = "Normal"

    # Normal Map shader node
    norm_map = nodes.new(type='ShaderNodeNormalMap')
    norm_map.location = (-300, 0)
    norm_map.label = "Normal Map"

    # RM image texture (R=metallic, G=roughness)
    img_tex_rm = nodes.new(type='ShaderNodeTexImage')
    img_tex_rm.image = img_rm
    img_tex_rm.location = (-600, -300)
    img_tex_rm.label = "RM (R=Metallic, G=Roughness)"

    # Separate Color node (RGB mode)
    sep_rgb = nodes.new(type='ShaderNodeSeparateColor')
    sep_rgb.location = (-300, -300)
    sep_rgb.mode = 'RGB'  # outputs: Red, Green, Blue
    sep_rgb.label = "Separate RGB"

    # --- Links ---
    # BSDF → Output
    links.new(bsdf.outputs['BSDF'], out_node.inputs['Surface'])

    # Base Color → BSDF Base Color
    links.new(img_tex_base.outputs['Color'], bsdf.inputs['Base Color'])

    # Normal → Normal Map → BSDF Normal
    links.new(img_tex_norm.outputs['Color'], norm_map.inputs['Color'])
    links.new(norm_map.outputs['Normal'], bsdf.inputs['Normal'])

    # RM → Separate RGB → BSDF Metallic + Roughness
    links.new(img_tex_rm.outputs['Color'], sep_rgb.inputs['Color'])
    links.new(sep_rgb.outputs['Red'], bsdf.inputs['Metallic'])
    links.new(sep_rgb.outputs['Green'], bsdf.inputs['Roughness'])

    # --- Assign to mesh ---
    mesh.data.materials.clear()
    mesh.data.materials.append(mat)

    # Ensure all polygons use material index 0
    for poly in mesh.data.polygons:
        poly.material_index = 0

    log(f"  ✓ Material '{mat.name}' created and assigned to '{mesh.name}'")
    log(f"     Node tree: {len(nodes)} nodes, {len(links)} links")


# ─── Animation generation ─────────────────────────────────────────────────

def create_procedural_animations(armature: bpy.types.Object, bones: dict) -> None:
    """Generate 6 animations: idle, walk, run, jump, attack, death.

    Uses pose.bones and keyframe_insert — avoids Action.fcurves (removed in 5.2).
    Each action is pushed to NLA strips for export.
    """
    if armature.animation_data is None:
        armature.animation_data_create()

    # Clear existing NLA tracks
    for track in list(armature.animation_data.nla_tracks):
        armature.animation_data.nla_tracks.remove(track)

    pb = armature.pose.bones

    def key(bone_key: str, euler: tuple[float, float, float], frame: int) -> None:
        """Set rotation Euler keyframe on a mapped bone at given frame."""
        name = bones.get(bone_key)
        if name and name in pb:
            pb[name].rotation_euler = euler
            pb[name].keyframe_insert(data_path="rotation_euler", frame=frame)

    REST = (0.0, 0.0, 0.0)

    anim_defs: list = []

    # ── idle (30f) ───────────────────────────────────────────────────────
    def anim_idle():
        for f in (0, 15, 30):
            sway = 0.02 if f == 15 else 0.0
            key('spine2', (0.0, 0.0, sway), f)
            key('larm',   (0.0, 0.0, 0.10), f)
            key('rarm',   (0.0, 0.0, -0.10), f)

    anim_defs.append(("idle", 30, anim_idle))

    # ── walk (24f) ───────────────────────────────────────────────────────
    def anim_walk():
        for f in (0, 12, 24):
            s = 1.0 if f == 0 else -1.0
            key('lthigh', (0.30 * s, 0.0, 0.0), f)
            key('rthigh', (-0.30 * s, 0.0, 0.0), f)
            key('lfoot',  (-0.10 * s, 0.0, 0.0), f)
            key('rfoot',  (0.10 * s, 0.0, 0.0), f)
            key('larm',   (-0.30 * s, 0.0, 0.0), f)
            key('rarm',   (0.30 * s, 0.0, 0.0), f)

    anim_defs.append(("walk", 24, anim_walk))

    # ── run (18f) ────────────────────────────────────────────────────────
    def anim_run():
        for f in (0, 9, 18):
            s = 1.0 if f == 0 else -1.0
            key('lthigh', (0.60 * s, 0.0, 0.0), f)
            key('rthigh', (-0.60 * s, 0.0, 0.0), f)
            key('spine2', (0.10 * s, 0.0, 0.0), f)

    anim_defs.append(("run", 18, anim_run))

    # ── jump (20f) ───────────────────────────────────────────────────────
    def anim_jump():
        for f in (0, 10, 20):
            if f == 0:
                key('lthigh', (0.20, 0.0, 0.0), f)
                key('rthigh', (-0.20, 0.0, 0.0), f)
            elif f == 10:
                key('lthigh', (-0.50, 0.0, 0.0), f)
                key('rthigh', (0.50, 0.0, 0.0), f)
                key('larm',   (-0.80, 0.0, 0.0), f)
                key('rarm',   (-0.80, 0.0, 0.0), f)
            else:
                key('lthigh', (0.20, 0.0, 0.0), f)
                key('rthigh', (-0.20, 0.0, 0.0), f)

    anim_defs.append(("jump", 20, anim_jump))

    # ── attack (20f) ─────────────────────────────────────────────────────
    def anim_attack():
        for f in (0, 5, 10, 20):
            if f == 0:
                key('larm',  (0.0, 0.0, 0.0), f)
                key('lfore', (0.0, 0.0, 0.0), f)
            elif f == 5:
                key('larm',  (-1.50, 0.0, 0.50), f)
                key('lfore', (-0.50, 0.0, 0.0), f)
            elif f == 10:
                key('larm',  (0.50, 0.0, -1.0), f)
                key('lfore', (-0.30, 0.0, 0.0), f)
            else:
                key('larm',  (0.0, 0.0, 0.0), f)
                key('lfore', (0.0, 0.0, 0.0), f)

    anim_defs.append(("attack", 20, anim_attack))

    # ── death (30f) ──────────────────────────────────────────────────────
    def anim_death():
        for f in (0, 15, 30):
            s = 0.3 if f == 15 else (0.6 if f == 30 else 0.0)
            key('spine', (s, 0.0, 0.0), f)
            key('hips',  (0.0, 0.0, s / 3.0), f)

    anim_defs.append(("death", 30, anim_death))

    # ── Execute each animation ───────────────────────────────────────────
    for name, frames, fn in anim_defs:
        action = bpy.data.actions.new(name=name)
        armature.animation_data.action = action

        bpy.context.view_layer.objects.active = armature
        bpy.ops.object.mode_set(mode='POSE')
        fn()
        bpy.ops.object.mode_set(mode='OBJECT')

        # Push to NLA
        track = armature.animation_data.nla_tracks.new()
        track.name = name
        track.strips.new(name=name, start=0, action=action)
        log(f"  ✓ {name}: {frames}f → NLA track")

    armature.animation_data.action = None


# ─── Export ───────────────────────────────────────────────────────────────

def export_glb(
    mesh: bpy.types.Object,
    armature: bpy.types.Object,
    path: str,
) -> bool:
    """Export only the mesh + armature to GLB with animations and skins."""
    bpy.ops.object.select_all(action='DESELECT')
    mesh.select_set(True)
    armature.select_set(True)
    bpy.context.view_layer.objects.active = armature

    bpy.ops.export_scene.gltf(
        filepath=path,
        export_format='GLB',
        use_selection=True,
        export_apply=True,
        export_tangents=True,
        export_materials='EXPORT',
        export_extras=True,
        export_animations=True,
        export_skins=True,
    )

    exists = os.path.exists(path)
    if exists:
        size_mb = os.path.getsize(path) / (1024 * 1024)
        log(f"  Exported: {path} ({size_mb:.1f} MB)")
    else:
        log(f"  ERROR: Export failed — file not created")
    return exists


# ─── Main ─────────────────────────────────────────────────────────────────

def main() -> int:
    line()
    log("RIG FINAL — Blender 5.2 safe skinning pipeline")
    line()

    # ── Step 1: Import M2M base rig ────────────────────────────────────
    log("[1/8] Import M2M base rig...")
    clear_scene()
    import_glb(M2M_PATH)

    arm = get_armature()
    if arm is None:
        log("FATAL: No armature found in M2M base")
        return 1
    log(f"  Armature: '{arm.name}' type={arm.type} bones={len(arm.data.bones)}")
    if arm.type != 'ARMATURE':
        log(f"FATAL: Armature type is '{arm.type}', expected 'ARMATURE'")
        return 1

    zombies = [o for o in bpy.context.scene.objects if o.type == 'MESH']
    if not zombies:
        log("FATAL: No mesh found in M2M base")
        return 1
    zombie = zombies[0]
    log(f"  Source mesh: '{zombie.name}'")
    if not verify_weights(zombie, "  Source mesh"):
        log("FATAL: Source mesh has no weights — cannot transfer")
        return 1

    # ── Step 2: Import clean mesh ───────────────────────────────────────
    log("[2/8] Import clean mesh (base_basic_pbr)...")
    import_glb(CLEAN_PATH)
    clean = get_mesh(exclude=[zombie])
    if clean is None:
        log("FATAL: No clean mesh found")
        return 1
    verify_weights(clean, "  clean mesh (before transfer)")

    # ── Step 3: Align meshes ───────────────────────────────────────────
    log("[3/8] Align clean mesh to zombie position...")
    clean.location = zombie.location.copy()
    clean.rotation_euler = zombie.rotation_euler.copy()
    clean.scale = zombie.scale.copy()
    # Force depsgraph update so data_transfer sees correct positions
    bpy.context.view_layer.update()

    # ── Step 4: Transfer weights ────────────────────────────────────────
    log("[4/8] Transfer vertex weights (DataTransfer)...")
    success = transfer_weights_data_transfer(zombie, clean)
    if not success:
        log("FATAL: All weight transfer strategies failed")
        return 1

    # ── Step 5: Clean up ───────────────────────────────────────────────
    log("[5/8] Remove zombie_character...")
    bpy.data.objects.remove(zombie, do_unlink=True)

    # ── Step 6: Manually parent clean mesh to armature ──────────────────
    log("[6/8] Parent mesh to armature (manual Armature modifier)...")
    # Method: object.parent link + manual Armature modifier
    # NOTE: parent_set(type='ARMATURE_AUTO') produces 0 weights in Blender 5.2
    #       on GLB-imported objects, so we do it manually.
    clean.parent = arm

    # Remove any existing Armature modifiers (from GLB re-import)
    for mod in list(clean.modifiers):
        if mod.type == 'ARMATURE':
            clean.modifiers.remove(mod)

    arm_mod = clean.modifiers.new(name="Armature", type='ARMATURE')
    arm_mod.object = arm
    log(f"  Armature modifier: object='{arm_mod.object.name}'")
    verify_weights(clean, "  clean mesh (after re-parent)")

    # ── Step 7: Detect bones + generate animations ─────────────────────
    log("[7/8] Detect bones & generate procedural animations...")
    bone_map = detect_bones(arm)
    create_procedural_animations(arm, bone_map)
    log(f"  NLA tracks: {len(arm.animation_data.nla_tracks) if arm.animation_data else 0}")

    # ── Step 8: Create PBR material from source textures ────────────────
    log("[8/9] Create PBR material...")
    create_pbr_material(clean)

    # ── Step 9: Export GLB ─────────────────────────────────────────────
    log("[9/9] Export GLB...")
    if not export_glb(clean, arm, OUTPUT_PATH):
        return 1

    line()
    log("SUCCESS!")
    log(f"  Output: {OUTPUT_PATH}")
    log(f"  Armature: '{arm.name}' ({arm.type}), {len(arm.data.bones)} bones")
    log(f"  Mesh: '{clean.name}', {len(clean.data.vertices)} verts")
    verify_weights(clean, "  Final weights")
    anim_count = len(arm.animation_data.nla_tracks) if arm.animation_data else 0
    log(f"  Animations: {anim_count}")
    line()
    return 0


if __name__ == "__main__":
    ret = main()
    sys.exit(ret)
