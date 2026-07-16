#!/usr/bin/env python3
"""
Batch Image-to-3D Generator — Hunyuan3D-2.1
Processa le 13 reference images dei nemici in modelli 3D GLB.
"""

import os
import sys
import json
import time
import base64
import requests
from pathlib import Path
from typing import Optional

# ============================================================
# CONFIGURATION
# ============================================================

# Hunyuan3D API server (dopo aver avviato RUN.bat)
API_URL = "http://localhost:8080"

# Input: 13 enemy reference images
INPUT_DIR = Path(r"E:\Giochini\Giuseppe\Bible\Character design")

# Output: raw GLB files
OUTPUT_DIR = Path(r"E:\Giochini\Giuseppe\pipeline\raw_enemies")

# Enemy names (matching input filenames)
ENEMIES = [
    "Infantry",
    "Shield",
    "Flamethrower",
    "Sniper",
    "Engineer",
    "Medic",
    "Heavy",
    "Elite",
    "Juggernaut",
    "Drone",
    "Robot",
    "Assault Robot",
    "Helicopter",
]

# Internal names for Godot
INTERNAL_NAMES = {
    "Infantry": "chr_enemy_infantry",
    "Shield": "chr_enemy_shield",
    "Flamethrower": "chr_enemy_flamethrower",
    "Sniper": "chr_enemy_sniper",
    "Engineer": "chr_enemy_engineer",
    "Medic": "chr_enemy_medic",
    "Heavy": "chr_enemy_heavy",
    "Elite": "chr_enemy_elite",
    "Juggernaut": "chr_enemy_juggernaut",
    "Drone": "chr_enemy_drone",
    "Robot": "chr_enemy_robot",
    "Assault Robot": "chr_enemy_assault_robot",
    "Helicopter": "chr_enemy_predator_heli",
}

# Generation settings (optimized for 8GB VRAM)
GENERATION_SETTINGS = {
    "texture": True,
    "octree_resolution": 256,  # Safe for 8GB VRAM
    "num_inference_steps": 5,
    "guidance_scale": 5.0,
    "remove_background": True,
    "type": "glb",
}

# Retry settings
MAX_RETRIES = 3
RETRY_DELAY = 10  # seconds


# ============================================================
# FUNCTIONS
# ============================================================

def check_api_server() -> bool:
    """Check if Hunyuan3D API server is running."""
    try:
        resp = requests.get(f"{API_URL}/", timeout=5)
        return resp.status_code == 200
    except requests.exceptions.ConnectionError:
        return False


def encode_image(image_path: Path) -> str:
    """Encode image to base64 for API."""
    with open(image_path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode()
    
    # Determine MIME type
    suffix = image_path.suffix.lower()
    mime_map = {".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg"}
    mime = mime_map.get(suffix, "image/png")
    
    return f"data:{mime};base64,{b64}"


def generate_3d_model(image_path: Path, settings: dict) -> Optional[bytes]:
    """Generate 3D model from image via Hunyuan3D API."""
    image_b64 = encode_image(image_path)
    
    payload = {
        "image": image_b64,
        "texture": settings["texture"],
        "octree_resolution": settings["octree_resolution"],
        "num_inference_steps": settings["num_inference_steps"],
        "guidance_scale": settings["guidance_scale"],
        "remove_background": settings["remove_background"],
        "type": settings["type"],
    }
    
    for attempt in range(MAX_RETRIES):
        try:
            print(f"  Tentativo {attempt + 1}/{MAX_RETRIES}...")
            resp = requests.post(
                f"{API_URL}/generate",
                json=payload,
                timeout=300  # 5 minuti timeout
            )
            
            if resp.status_code == 200:
                return resp.content
            else:
                print(f"  Errore API: {resp.status_code} - {resp.text[:200]}")
                
        except requests.exceptions.Timeout:
            print(f"  Timeout (tentativo {attempt + 1})")
        except Exception as e:
            print(f"  Errore: {e}")
        
        if attempt < MAX_RETRIES - 1:
            print(f"  Riprovo tra {RETRY_DELAY} secondi...")
            time.sleep(RETRY_DELAY)
    
    return None


def process_enemy(enemy_name: str) -> bool:
    """Process a single enemy: image → 3D model."""
    # Find input image
    image_path = None
    for ext in [".png", ".jpg", ".jpeg"]:
        candidate = INPUT_DIR / f"{enemy_name}{ext}"
        if candidate.exists():
            image_path = candidate
            break
    
    if not image_path:
        print(f"  ERRORE: Immagine non trovata per {enemy_name}")
        return False
    
    # Output path
    internal_name = INTERNAL_NAMES[enemy_name]
    output_path = OUTPUT_DIR / f"{internal_name}.glb"
    
    # Skip if already exists
    if output_path.exists():
        print(f"  Saltato (già esistente): {output_path.name}")
        return True
    
    print(f"  Generazione: {enemy_name} → {internal_name}.glb")
    print(f"  Input: {image_path.name}")
    
    # Generate
    glb_data = generate_3d_model(image_path, GENERATION_SETTINGS)
    
    if glb_data is None:
        print(f"  ERRORE: Generazione fallita per {enemy_name}")
        return False
    
    # Save
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "wb") as f:
        f.write(glb_data)
    
    size_mb = len(glb_data) / (1024 * 1024)
    print(f"  OK: {output_path.name} ({size_mb:.1f} MB)")
    return True


def main():
    """Main batch processing loop."""
    print("=" * 60)
    print("  Hunyuan3D-2.1 — Batch Image-to-3D Generator")
    print("  13 Enemy Characters")
    print("=" * 60)
    print()
    
    # Check API server
    print("Verifica server Hunyuan3D...")
    if not check_api_server():
        print("ERRORE: Server Hunyuan3D non raggiungibile!")
        print()
        print("Avvia prima il server:")
        print(f"  1. Vai in: E:\\Applicazioni\\Hunyuan3D2\\")
        print(f"  2. Esegui: RUN.bat")
        print(f"  3. Attendi messaggio: 'Uvicorn running on http://0.0.0.0:8080'")
        print()
        input("Premi INVIO quando il server è avviato...")
        
        # Re-check
        if not check_api_server():
            print("ERRORE: Server ancora non raggiungibile. Esci.")
            return
    
    print("Server OK!")
    print()
    
    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Process each enemy
    results = {"success": [], "failed": []}
    
    for i, enemy_name in enumerate(ENEMIES, 1):
        print(f"\n[{i}/{len(ENEMIES)}] {enemy_name}")
        print("-" * 40)
        
        success = process_enemy(enemy_name)
        
        if success:
            results["success"].append(enemy_name)
        else:
            results["failed"].append(enemy_name)
        
        # Pause between generations (avoid overheating)
        if i < len(ENEMIES):
            print("  Pausa 5 secondi...")
            time.sleep(5)
    
    # Summary
    print("\n" + "=" * 60)
    print("  RISULTATI")
    print("=" * 60)
    print(f"\n  Completati: {len(results['success'])}/{len(ENEMIES)}")
    
    if results["failed"]:
        print(f"  Falliti: {len(results['failed'])}")
        for name in results["failed"]:
            print(f"    - {name}")
    
    print(f"\n  Output: {OUTPUT_DIR}")
    print()
    
    # Save results
    results_path = OUTPUT_DIR / "_results.json"
    with open(results_path, "w") as f:
        json.dump(results, f, indent=2)
    print(f"  Risultati salvati: {results_path.name}")
    
    print("\n" + "=" * 60)
    print("  COMPLETATO")
    print("=" * 60)


if __name__ == "__main__":
    main()
