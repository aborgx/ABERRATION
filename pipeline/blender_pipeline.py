#!/usr/bin/env python3
"""
Blender Headless Pipeline: Cleanup, Rig, LOD, Export for anything.world outputs
Run: blender -b -P blender_pipeline.py -- <enemy_name>
"""
import bpy
import os
import sys
import json
from pathlib import Path
from mathutils import Vector

# ─── Config ──────────────────────────────────────────────────────────────
RAW_DIR = Path(os.getenv("RAW_DIR", "/mnt/e/Giochini/Giuseppe/pipeline/raw"))
CLEAN_DIR = Path(os.getenv("CLEAN_DIR", "/mnt/e/Giochini/Giuseppe/pipeline/clean"))
RIGGED_DIR = Path(os.getenv("RIGGED_DIR", "/mnt/e/Giochini/Giuseppe/pipeline/rigged"))
GAME_READY_DIR = Path(os.getenv("GAME_READY_DIR", "/mnt/e/Giochini/Giuseppe/pipeline/game_ready"))

TARGET_TRIS = {
    "chr_enemy_infantry": 10000,
    "chr_enemy_shield": 12000,
    "chr_enemy_flamethrower": 11000,
    "chr_enemy_sniper": 9000,
    "chr_enemy_engineer": 10000,
    "chr_enemy_medic": 9000,
    "chr_enemy_heavy": 14000,
    "chr_enemy_elite": 12000,
    "chr_enemy_juggernaut": 28000,
    "chr_enemy_drone": 4000,
    "chr_enemy_robot": 18000,
    "chr_enemy_assault_robot": 30000,
    "chr_enemy_predator_heli": 35000,
}

MATERIAL_SLOTS = ["body", "gear", "weapon", "emissive", "eyes"]
LOD_RATIOS = [1.0, 0.5, 0.2, 0.05]  # LOD0, LOD1, LOD2, LOD3

# ─── Helpers ─────────────────────────────────────────────────────────
def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for block in bpy.data.meshes:
        if block.users == 0:
            bpy.data.meshes.remove(block)
    for block in bpy.data.materials:
        if block.users == 0:
            bpy.data.materials.remove(block)
    for block in bpy.data.armatures:
        if block.users == 0:
            bpy.data.armatures.remove(block)

def import_glb(path: Path):
    bpy.ops.import_scene.gltf(filepath=str(path))
    return [o for o in bpy.context.selected_objects if o.type == 'MESH']

def join_meshes(meshes):
    if len(meshes) <= 1:
        return meshes[0]
    bpy.context.view_layer.objects.active = meshes[0]
    for m in meshes[1:]:
        m.select_set(True)
    bpy.ops.object.join()
    return bpy.context.active_object

def decimate_to_target(obj, target_tris):
    current = sum(len(m.polygons) for m in obj.data.users_mesh)
    if current <= target_tris:
        return
    ratio = target_tris / current
    mod = obj.modifiers.new("Decimate", 'DECIMATE')
    mod.ratio = ratio
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier="Decimate")

def smart_uv(obj):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=66, island_margin=0.02)
    bpy.ops.object.mode_set(mode='OBJECT')

def create_material_slots(obj, name):
    for slot_name in MATERIAL_SLOTS:
        if slot_name not in [s.name for s in obj.material_slots]:
            mat = bpy.data.materials.new(name=f"{name}_{slot_name}")
            mat.use_nodes = True
            obj.data.materials.append(mat)

def apply_transforms(obj):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

def generate_lods(obj, name):
    lod_objects = [obj]
    for i, ratio in enumerate(LOD_RATIOS[1:], 1):
        lod = obj.copy()
        lod.data = obj.data.copy()
        lod.name = f"{name}_LOD{i}"
        bpy.context.collection.objects.link(lod)
        if ratio < 1.0:
            mod = lod.modifiers.new("Decimate", 'DECIMATE')
            mod.ratio = ratio
            bpy.context.view_layer.objects.active = lod
            bpy.ops.object.modifier_apply(modifier="Decimate")
        lod_objects.append(lod)
    return lod_objects

def create_collision_mesh(obj, name):
    col = obj.copy()
    col.data = obj.data.copy()
    col.name = f"{name}_collision"
    bpy.context.collection.objects.link(col)
    mod = col.modifiers.new("ConvexHull", 'DECIMATE')
    mod.ratio = 0.02
    mod.use_collapse_triangulate = True
    bpy.context.view_layer.objects.active = col
    bpy.ops.object.modifier_apply(modifier="ConvexHull")
    col.display_type = 'WIRE'
    return col

def export_gltf(objects, path: Path, export_animations=True):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.export_scene.gltf(
        filepath=str(path),
        export_format='GLB',
        use_selection=True,
        export_apply=True,
        export_tangents=True,
        export_materials='EXPORT',
        export_extras=True,
        export_animations=export_animations,
        export_skins=True,
        export_morph=False,
    )

# ─── Main Pipeline ───────────────────────────────────────────────────
def process_enemy(enemy_name: str):
    print(f"\n=== Processing {enemy_name} ===")
    
    raw_path = RAW_DIR / f"{enemy_name}.glb"
    if not raw_path.exists():
        print(f"  ✗ Source not found: {raw_path}")
        return False
    
    clear_scene()
    
    # Import
    meshes = import_glb(raw_path)
    if not meshes:
        print(f"  ✗ No meshes imported")
        return False
    obj = join_meshes(meshes)
    obj.name = enemy_name
    
    # Decimate to target
    target = TARGET_TRIS.get(enemy_name, 12000)
    decimate_to_target(obj, target)
    
    # UV unwrap
    smart_uv(obj)
    
    # Material slots
    create_material_slots(obj, enemy_name)
    
    # Apply transforms
    apply_transforms(obj)
    
    # Generate LODs
    lod_objects = generate_lods(obj, enemy_name)
    
    # Collision mesh
    collision = create_collision_mesh(obj, enemy_name)
    
    # Export
    out_dir = GAME_READY_DIR / enemy_name
    out_dir.mkdir(parents=True, exist_ok=True)
    
    # Main (LOD0)
    export_gltf([obj], out_dir / f"{enemy_name}.glb")
    
    # LODs
    for i, lod in enumerate(lod_objects[1:], 1):
        export_gltf([lod], out_dir / f"{enemy_name}_LOD{i}.glb", export_animations=False)
    
    # Collision
    export_gltf([collision], out_dir / f"{enemy_name}_collision.glb", export_animations=False)
    
    print(f"  ✓ Exported to {out_dir}")
    return True

# ─── Entry Point ─────────────────────────────────────────────────────
if __name__ == "__main__":
    # Get enemy name from command line args after "--"
    argv = sys.argv
    if "--" in argv:
        idx = argv.index("--")
        enemy_name = argv[idx + 1] if idx + 1 < len(argv) else None
    else:
        enemy_name = None
    
    if not enemy_name:
        print("Usage: blender -b -P blender_pipeline.py -- <enemy_name>")
        print("Available enemies:", list(TARGET_TRIS.keys()))
        sys.exit(1)
    
    if enemy_name not in TARGET_TRIS:
        print(f"Unknown enemy: {enemy_name}")
        sys.exit(1)
    
    success = process_enemy(enemy_name)
    sys.exit(0 if success else 1)