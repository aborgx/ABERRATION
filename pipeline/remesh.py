#!/usr/bin/env python3
"""
AutoRemesher CLI Wrapper — Automatic quad remeshing for ABERRATION pipeline
Converts high-poly meshes to clean quad-based topology.

Usage: python remesh.py <input> <target_quads> [preset_name]
"""
import os
import subprocess
import sys
import time
from pathlib import Path

AUTOREMESHER_PATH = Path("E:/Giochini/Giuseppe/pipeline/tools/autoremesher/bin/autoremesher.exe")
AUTOREMESHER_PATH_LINUX = Path("/mnt/e/Giochini/Giuseppe/pipeline/tools/autoremesher/bin/autoremesher.exe")
BLENDER_PATH = Path("E:/Applicazioni/blender-5.2.0-windows-x64/blender.exe")
BLENDER_PATH_LINUX = Path("/mnt/e/Applicazioni/blender-5.2.0-windows-x64/blender.exe")

REMESH_PRESETS = {
    "chr_player": {"target_quads": 22000, "edge_scaling": 1.0, "sharp_edge": 90.0, "smooth_normal": 0.0, "adaptivity": 1.0},
    "chr_enemy_infantry": {"target_quads": 10000, "edge_scaling": 1.0, "sharp_edge": 90.0, "smooth_normal": 0.0, "adaptivity": 1.0},
    "chr_enemy_shield": {"target_quads": 12000, "edge_scaling": 1.0, "sharp_edge": 90.0, "smooth_normal": 0.0, "adaptivity": 1.0},
    "chr_enemy_flamethrower": {"target_quads": 11000, "edge_scaling": 1.0, "sharp_edge": 90.0, "smooth_normal": 0.0, "adaptivity": 1.0},
    "chr_enemy_sniper": {"target_quads": 9000, "edge_scaling": 1.0, "sharp_edge": 90.0, "smooth_normal": 0.0, "adaptivity": 1.0},
    "chr_enemy_engineer": {"target_quads": 10000, "edge_scaling": 1.0, "sharp_edge": 90.0, "smooth_normal": 0.0, "adaptivity": 1.0},
    "chr_enemy_medic": {"target_quads": 9000, "edge_scaling": 1.0, "sharp_edge": 90.0, "smooth_normal": 0.0, "adaptivity": 1.0},
    "chr_enemy_heavy": {"target_quads": 14000, "edge_scaling": 1.0, "sharp_edge": 90.0, "smooth_normal": 0.0, "adaptivity": 1.0},
    "chr_enemy_elite": {"target_quads": 12000, "edge_scaling": 1.0, "sharp_edge": 90.0, "smooth_normal": 0.0, "adaptivity": 1.0},
    "chr_enemy_juggernaut": {"target_quads": 28000, "edge_scaling": 1.0, "sharp_edge": 90.0, "smooth_normal": 0.0, "adaptivity": 1.0},
    "chr_enemy_drone": {"target_quads": 4000, "edge_scaling": 1.0, "sharp_edge": 45.0, "smooth_normal": 0.0, "adaptivity": 0.5},
    "chr_enemy_robot": {"target_quads": 18000, "edge_scaling": 1.0, "sharp_edge": 45.0, "smooth_normal": 0.0, "adaptivity": 0.5},
    "chr_enemy_assault_robot": {"target_quads": 30000, "edge_scaling": 1.0, "sharp_edge": 45.0, "smooth_normal": 0.0, "adaptivity": 0.5},
    "chr_enemy_predator_heli": {"target_quads": 35000, "edge_scaling": 1.0, "sharp_edge": 45.0, "smooth_normal": 0.0, "adaptivity": 0.5},
}

def to_win(path: Path) -> str:
    s = str(path)
    if s.startswith("/mnt/"):
        parts = s.split("/")
        drive = parts[2].upper()
        rest = "/".join(parts[3:])
        return f"{drive}:/{rest}"
    return s

def find_exe(candidates: list) -> Path:
    for p in candidates:
        if p.exists():
            return p
    raise FileNotFoundError(f"Not found: {[str(c) for c in candidates]}")

def convert_glb_to_obj(input_path: Path, output_path: Path) -> Path:
    exe = find_exe([BLENDER_PATH, BLENDER_PATH_LINUX])
    script = f"""import bpy
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=r"{to_win(input_path)}")
for obj in bpy.context.scene.objects:
    if obj.type == 'MESH':
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
bpy.ops.export_scene.obj(filepath=r"{to_win(output_path)}", use_selection=True)
"""
    script_path = output_path.with_suffix(".py")
    script_path.write_text(script)
    cmd = ["cmd.exe", "/c", to_win(exe), "-b", "-P", to_win(script_path)]
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    if result.returncode != 0:
        raise RuntimeError(f"Blender GLB→OBJ failed: {result.stderr[:500]}")
    script_path.unlink()
    return output_path

def remesh(input_path: Path, output_path: Path, target_quads: int = 12000,
           edge_scaling: float = 1.0, sharp_edge: float = 90.0,
           smooth_normal: float = 0.0, adaptivity: float = 1.0) -> Path:
    exe = find_exe([AUTOREMESHER_PATH, AUTOREMESHER_PATH_LINUX])
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # Auto-convert GLB/FBX to OBJ
    work_input = input_path
    if input_path.suffix.lower() in [".glb", ".gltf", ".fbx"]:
        print(f"  Converting {input_path.suffix} → .obj ...")
        temp_obj = output_path.parent / f"temp_{input_path.stem}.obj"
        convert_glb_to_obj(input_path, temp_obj)
        work_input = temp_obj

    cmd = ["cmd.exe", "/c", to_win(exe),
           "--input", to_win(work_input),
           "--output", to_win(output_path),
           "--target-quads", str(target_quads),
           "--edge-scaling", str(edge_scaling),
           "--sharp-edge", str(sharp_edge),
           "--smooth-normal", str(smooth_normal),
           "--adaptivity", str(adaptivity)]

    report_path = output_path.with_suffix(".txt")
    cmd.extend(["--report", to_win(report_path)])

    print(f"  AutoRemesher: {work_input.name} → {output_path.name} (target: {target_quads} quads)")
    start = time.time()
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    elapsed = time.time() - start

    if result.returncode != 0:
        raise RuntimeError(f"AutoRemesher failed: {result.stderr[:300]}")

    print(f"  Done in {elapsed:.1f}s")

    if report_path.exists():
        with open(report_path) as f:
            for line in f:
                if "Quads:" in line or "Vertices:" in line:
                    print(f"    {line.strip()}")

    if work_input != input_path and work_input.exists():
        work_input.unlink()

    return output_path

def remesh_with_preset(input_path: Path, output_path: Path, preset_name: str) -> Path:
    if preset_name not in REMESH_PRESETS:
        raise ValueError(f"Unknown preset '{preset_name}'. Available: {list(REMESH_PRESETS.keys())}")
    return remesh(input_path, output_path, **REMESH_PRESETS[preset_name])

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python remesh.py <input> <output.obj> [target_quads]")
        print("Presets:", list(REMESH_PRESETS.keys()))
        sys.exit(1)
    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])
    target_quads = int(sys.argv[3]) if len(sys.argv) > 3 else 12000
    remesh(input_path, output_path, target_quads=target_quads)
