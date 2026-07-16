#!/usr/bin/env python3
"""
Protagonist Rigging + Animation Pipeline
Rigify humanoid + 8 base animations for ABERRATION protagonist.

Usage: blender -b -P rig_and_animate.py -- <input.glb> <output_dir>
"""
import bpy
import sys
import os
from pathlib import Path

def to_win(path: str) -> str:
    if path.startswith("/mnt/"):
        parts = path.split("/")
        drive = parts[2].upper()
        rest = "/".join(parts[3:])
        return f"{drive}:/{rest}"
    return path

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for block in bpy.data.meshes:
        if block.users == 0:
            bpy.data.meshes.remove(block)
    for block in bpy.data.armatures:
        if block.users == 0:
            bpy.data.armatures.remove(block)
    for block in bpy.data.actions:
        if block.users == 0:
            bpy.data.actions.remove(block)

def import_glb(path: str):
    bpy.ops.import_scene.gltf(filepath=path)

def get_mesh():
    for obj in bpy.context.scene.objects:
        if obj.type == 'MESH':
            return obj
    return None

def add_metarig_human():
    # Enable Rigify addon first
    bpy.ops.preferences.addon_enable(module='rigify')
    bpy.ops.object.armature_human_metarig_add()
    return bpy.context.active_object

def position_metarig(metarig, mesh_obj):
    bbox = mesh_obj.bound_box
    min_y = min(v[2] for v in bbox)
    max_y = max(v[2] for v in bbox)
    height = max_y - min_y
    center_x = sum(v[0] for v in bbox) / 8
    center_z = sum(v[1] for v in bbox) / 8
    metarig.location = (center_x, 0, min_y)
    metarig.scale = (1, 1, height / 1.7)

def generate_rig(metarig):
    bpy.context.view_layer.objects.active = metarig
    metarig.select_set(True)
    # Enter edit mode to select bones
    bpy.ops.object.mode_set(mode='EDIT')
    for bone in metarig.data.edit_bones:
        bone.select = True
    bpy.ops.object.mode_set(mode='OBJECT')
    # Generate rig
    bpy.ops.pose.rigify_generate()

def parent_mesh_to_rig(mesh_obj, rig_obj):
    bpy.ops.object.select_all(action='DESELECT')
    mesh_obj.select_set(True)
    rig_obj.select_set(True)
    bpy.context.view_layer.objects.active = rig_obj
    bpy.ops.object.parent_set(type='ARMATURE_AUTO')

def create_action(rig, name, frame_start, frame_end):
    action = bpy.data.actions.new(name=name)
    rig.animation_data_create()
    rig.animation_data.action = action
    return action

def add_keyframe(rig, action, frame, pose_data):
    bpy.context.view_layer.objects.active = rig
    bpy.ops.object.mode_set(mode='POSE')
    for bone_name, rotation in pose_data.items():
        if bone_name in rig.pose.bones:
            bone = rig.pose.bones[bone_name]
            bone.rotation_euler = rotation
            bone.keyframe_insert(data_path="rotation_euler", frame=frame)
    bpy.ops.object.mode_set(mode='OBJECT')

# ─── Animation Definitions ─────────────────────────────────────────
ANIMATIONS = {
    "idle": {"frames": 30, "loop": True, "poses": {
        0: {"spine.003": (0, 0, 0), "upper_arm.L": (0, 0, 0.1), "upper_arm.R": (0, 0, -0.1)},
        15: {"spine.003": (0, 0, 0.02), "upper_arm.L": (0, 0, 0.12), "upper_arm.R": (0, 0, -0.08)},
        30: {"spine.003": (0, 0, 0), "upper_arm.L": (0, 0, 0.1), "upper_arm.R": (0, 0, -0.1)},
    }},
    "walk": {"frames": 24, "loop": True, "poses": {
        0: {"thigh.L": (0.3, 0, 0), "thigh.R": (-0.3, 0, 0), "foot.L": (-0.1, 0, 0), "foot.R": (0.1, 0, 0), "upper_arm.L": (-0.3, 0, 0), "upper_arm.R": (0.3, 0, 0)},
        12: {"thigh.L": (-0.3, 0, 0), "thigh.R": (0.3, 0, 0), "foot.L": (0.1, 0, 0), "foot.R": (-0.1, 0, 0), "upper_arm.L": (0.3, 0, 0), "upper_arm.R": (-0.3, 0, 0)},
        24: {"thigh.L": (0.3, 0, 0), "thigh.R": (-0.3, 0, 0), "foot.L": (-0.1, 0, 0), "foot.R": (0.1, 0, 0), "upper_arm.L": (-0.3, 0, 0), "upper_arm.R": (0.3, 0, 0)},
    }},
    "run": {"frames": 18, "loop": True, "poses": {
        0: {"thigh.L": (0.6, 0, 0), "thigh.R": (-0.6, 0, 0), "spine.003": (0.1, 0, 0)},
        9: {"thigh.L": (-0.6, 0, 0), "thigh.R": (0.6, 0, 0), "spine.003": (-0.1, 0, 0)},
        18: {"thigh.L": (0.6, 0, 0), "thigh.R": (-0.6, 0, 0), "spine.003": (0.1, 0, 0)},
    }},
    "attack_1": {"frames": 20, "loop": False, "poses": {
        0: {"upper_arm.L": (0, 0, 0), "forearm.L": (0, 0, 0)},
        5: {"upper_arm.L": (-1.5, 0, 0.5), "forearm.L": (-0.5, 0, 0)},
        10: {"upper_arm.L": (0.5, 0, -1.0), "forearm.L": (-0.3, 0, 0)},
        20: {"upper_arm.L": (0, 0, 0), "forearm.L": (0, 0, 0)},
    }},
    "attack_2": {"frames": 20, "loop": False, "poses": {
        0: {"upper_arm.R": (0, 0, 0), "forearm.R": (0, 0, 0)},
        5: {"upper_arm.R": (-1.5, 0, -0.5), "forearm.R": (-0.5, 0, 0)},
        10: {"upper_arm.R": (0.5, 0, 1.0), "forearm.R": (-0.3, 0, 0)},
        20: {"upper_arm.R": (0, 0, 0), "forearm.R": (0, 0, 0)},
    }},
    "death": {"frames": 30, "loop": False, "poses": {
        0: {"spine.003": (0, 0, 0), "thigh.L": (0, 0, 0), "thigh.R": (0, 0, 0)},
        10: {"spine.003": (0.3, 0, 0), "thigh.L": (0.2, 0, 0), "thigh.R": (0.2, 0, 0)},
        20: {"spine.003": (1.5, 0, 0), "upper_arm.L": (0.5, 0, 0.3), "upper_arm.R": (0.5, 0, -0.3)},
        30: {"spine.003": (1.57, 0, 0), "upper_arm.L": (0.5, 0, 0.3), "upper_arm.R": (0.5, 0, -0.3), "thigh.L": (0.5, 0, 0), "thigh.R": (0.5, 0, 0)},
    }},
    "hit": {"frames": 15, "loop": False, "poses": {
        0: {"spine.003": (0, 0, 0)},
        3: {"spine.003": (0.2, 0, 0.1)},
        6: {"spine.003": (0.1, 0, 0.05)},
        15: {"spine.003": (0, 0, 0)},
    }},
    "alert": {"frames": 20, "loop": False, "poses": {
        0: {"spine.003": (0, 0, 0), "head": (0, 0, 0)},
        5: {"spine.003": (0, 0, 0), "head": (0, 0, 0.3)},
        10: {"spine.003": (-0.1, 0, 0), "head": (0, 0, -0.3)},
        15: {"spine.003": (0, 0, 0), "head": (0, 0, 0.2)},
        20: {"spine.003": (0, 0, 0), "head": (0, 0, 0)},
    }},
}

def rig_and_animate(input_path: str, output_dir: str):
    input_p = Path(input_path)
    out_dir = Path(output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*60}")
    print(f"  RIG + ANIMATE: {input_p.name}")
    print(f"{'='*60}")

    # Step 1: Import retopologized mesh
    print("\n[1/6] Importing retopologized mesh...")
    clear_scene()
    import_glb(to_win(str(input_p)))
    mesh = get_mesh()
    if not mesh:
        print("  ERROR: No mesh found")
        return
    print(f"  Mesh: {mesh.name}, {len(mesh.data.polygons)} polys")

    # Step 2: Add metarig
    print("\n[2/6] Adding metarig...")
    metarig = add_metarig_human()
    position_metarig(metarig, mesh)

    # Step 3: Generate rig
    print("\n[3/6] Generating Rigify rig...")
    generate_rig(metarig)
    rig = bpy.context.active_object

    # Step 4: Parent mesh to rig
    print("\n[4/6] Parenting mesh to rig...")
    parent_mesh_to_rig(mesh, rig)

    # Step 5: Create animations
    print("\n[5/6] Creating animations...")
    for anim_name, anim_data in ANIMATIONS.items():
        action = create_action(rig, anim_name, 1, anim_data["frames"])
        for frame, pose_data in anim_data["poses"].items():
            add_keyframe(rig, action, frame, pose_data)
        print(f"  Created: {anim_name} ({anim_data['frames']} frames)")

    # Step 6: Export
    print("\n[6/6] Exporting...")
    output_path = out_dir / "chr_player_rigged.glb"
    bpy.ops.object.select_all(action='DESELECT')
    mesh.select_set(True)
    rig.select_set(True)
    bpy.context.view_layer.objects.active = rig
    bpy.ops.export_scene.gltf(
        filepath=to_win(str(output_path)),
        export_format='GLB',
        use_selection=True,
        export_apply=True,
        export_tangents=True,
        export_materials='EXPORT',
        export_extras=True,
        export_animations=True,
        export_skins=True,
    )

    print(f"\n{'='*60}")
    print(f"  DONE: {output_path}")
    print(f"  Bones: {len(rig.data.bones)}")
    print(f"  Animations: {len(ANIMATIONS)}")
    print(f"{'='*60}")

if __name__ == "__main__":
    argv = sys.argv
    if "--" in argv:
        args = argv[argv.index("--") + 1:]
    else:
        args = []
    if len(args) < 2:
        print("Usage: blender -b -P rig_and_animate.py -- <input.glb> <output_dir>")
        sys.exit(1)
    rig_and_animate(args[0], args[1])
