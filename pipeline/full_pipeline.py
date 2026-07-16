#!/usr/bin/env python3
"""
Complete Remesh Pipeline — Blender + AutoRemesher combined
1. Import GLB/FBX into Blender
2. Export OBJ for AutoRemesher
3. Run AutoRemesher (quad remesh)
4. Re-import remeshed OBJ into Blender
5. Apply materials, generate LODs, create collision mesh
6. Export GLB for Godot

Usage: blender -b -P full_pipeline.py -- <name> <input.glb> [target_quads]
"""
import bpy
import sys
import os
import subprocess
from pathlib import Path

# ─── Config ──────────────────────────────────────────────────────────────
AUTOREMESHER = Path("E:/Giochini/Giuseppe/pipeline/tools/autoremesher/bin/autoremesher.exe")
OUTPUT_DIR = Path("E:/Giochini/Giuseppe/pipeline/game_ready")
MATERIAL_SLOTS = ["body", "gear", "weapon", "emissive", "eyes"]
LOD_RATIOS = [1.0, 0.5, 0.2, 0.05]

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

def to_win(path: str) -> str:
    """Convert Linux/WSL path to Windows path"""
    if path.startswith("/mnt/"):
        parts = path.split("/")
        drive = parts[2].upper()
        rest = "/".join(parts[3:])
        return f"{drive}:/{rest}"
    return path

def import_model(path: str):
    ext = Path(path).suffix.lower()
    if ext in [".glb", ".gltf"]:
        bpy.ops.import_scene.gltf(filepath=path)
    elif ext == ".obj":
        bpy.ops.wm.obj_import(filepath=path)
    elif ext == ".fbx":
        bpy.ops.import_scene.fbx(filepath=path)
    else:
        raise ValueError(f"Unsupported format: {ext}")

def get_mesh_objects():
    return [o for o in bpy.context.scene.objects if o.type == 'MESH']

def join_meshes(meshes):
    if len(meshes) <= 1:
        return meshes[0]
    bpy.context.view_layer.objects.active = meshes[0]
    for m in meshes[1:]:
        m.select_set(True)
    bpy.ops.object.join()
    return bpy.context.active_object

def decimate(obj, ratio):
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

def create_materials(obj, name):
    for slot in MATERIAL_SLOTS:
        mat = bpy.data.materials.new(name=f"{name}_{slot}")
        mat.use_nodes = True
        obj.data.materials.append(mat)

def apply_transforms(obj):
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

def generate_lods(obj, name):
    lods = [obj]
    for i, ratio in enumerate(LOD_RATIOS[1:], 1):
        lod = obj.copy()
        lod.data = obj.data.copy()
        lod.name = f"{name}_LOD{i}"
        bpy.context.collection.objects.link(lod)
        if ratio < 1.0:
            decimate(lod, ratio)
        lods.append(lod)
    return lods

def create_collision(obj, name):
    col = obj.copy()
    col.data = obj.data.copy()
    col.name = f"{name}_collision"
    bpy.context.collection.objects.link(col)
    mod = col.modifiers.new("Decimate", 'DECIMATE')
    mod.ratio = 0.02
    mod.use_collapse_triangulate = True
    bpy.context.view_layer.objects.active = col
    bpy.ops.object.modifier_apply(modifier="Decimate")
    col.display_type = 'WIRE'
    return col

def export_obj(obj, path):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.wm.obj_export(filepath=str(path), export_selected_objects=True, export_materials=False)

def export_glb(objects, path, animations=True):
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
        export_animations=animations,
        export_skins=True,
    )

# ─── AutoRemesher ───────────────────────────────────────────────────
def run_autoremesher(input_obj, output_obj, target_quads):
    cmd = ["cmd.exe", "/c", str(AUTOREMESHER),
           "--input", str(input_obj),
           "--output", str(output_obj),
           "--target-quads", str(target_quads),
           "--edge-scaling", "1.0",
           "--sharp-edge", "90.0",
           "--smooth-normal", "0.0",
           "--adaptivity", "1.0"]
    report = output_obj.with_suffix(".txt")
    cmd.extend(["--report", str(report)])
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    if result.returncode != 0:
        raise RuntimeError(f"AutoRemesher failed: {result.stderr[:500]}")
    print(f"  AutoRemesher: {target_quads} quads target")
    if report.exists():
        with open(report) as f:
            for line in f:
                if "Quads:" in line or "Vertices:" in line:
                    print(f"    {line.strip()}")

# ─── Main Pipeline ──────────────────────────────────────────────────
def process(name: str, input_path: str, target_quads: int = 12000):
    input_p = Path(input_path)
    out_dir = OUTPUT_DIR / name
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*60}")
    print(f"  PIPELINE: {name}")
    print(f"  Input: {input_p.name}")
    print(f"  Target: {target_quads} quads")
    print(f"{'='*60}")

    # Step 1: Import
    print("\n[1/6] Importing...")
    clear_scene()
    import_model(str(input_p))
    meshes = get_mesh_objects()
    if not meshes:
        print("  ERROR: No meshes found")
        return
    obj = join_meshes(meshes)
    obj.name = name
    current_tris = len(obj.data.polygons)
    print(f"  Imported: {current_tris} tris")

    # Step 2: Export OBJ for AutoRemesher
    print("\n[2/6] Exporting OBJ for AutoRemesher...")
    temp_obj = out_dir / f"temp_{name}.obj"
    export_obj(obj, temp_obj)

    # Step 3: AutoRemesher
    print("\n[3/6] Running AutoRemesher...")
    remeshed_obj = out_dir / f"{name}_remeshed.obj"
    run_autoremesher(temp_obj, remeshed_obj, target_quads)

    # Step 4: Re-import remeshed OBJ
    print("\n[4/6] Re-importing remeshed OBJ...")
    clear_scene()
    import_model(str(remeshed_obj))
    meshes = get_mesh_objects()
    obj = join_meshes(meshes)
    obj.name = name
    new_tris = len(obj.data.polygons)
    print(f"  Remeshed: {new_tris} quads ({current_tris} → {new_tris})")

    # Step 5: Post-processing
    print("\n[5/6] Post-processing...")
    smart_uv(obj)
    create_materials(obj, name)
    apply_transforms(obj)
    lods = generate_lods(obj, name)
    collision = create_collision(obj, name)

    # Step 6: Export GLB
    print("\n[6/6] Exporting GLB...")
    export_glb([obj], out_dir / f"{name}.glb")
    for i, lod in enumerate(lods[1:], 1):
        export_glb([lod], out_dir / f"{name}_LOD{i}.glb", animations=False)
    export_glb([collision], out_dir / f"{name}_collision.glb", animations=False)

    # Cleanup
    temp_obj.unlink(missing_ok=True)
    remeshed_obj.unlink(missing_ok=True)
    report = remeshed_obj.with_suffix(".txt")
    report.unlink(missing_ok=True)

    print(f"\n{'='*60}")
    print(f"  DONE: {name}")
    print(f"  Output: {out_dir}")
    print(f"{'='*60}")

# ─── Entry Point ─────────────────────────────────────────────────────
if __name__ == "__main__":
    argv = sys.argv
    if "--" in argv:
        args = argv[argv.index("--") + 1:]
    else:
        args = []

    if len(args) < 2:
        print("Usage: blender -b -P full_pipeline.py -- <name> <input.glb> [target_quads]")
        sys.exit(1)

    name = args[0]
    input_path = args[1]
    target_quads = int(args[2]) if len(args) > 2 else 12000

    process(name, input_path, target_quads)
