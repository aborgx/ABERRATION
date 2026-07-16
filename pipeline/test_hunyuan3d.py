#!/usr/bin/env python3
"""
Test Hunyuan3D-2.1 — 1-2 Immagini
Verifica che il pipeline funzioni prima del batch completo.
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

API_URL = "http://localhost:8080"

# Test: Infantry (primo nemico) + Drone (hardware, per testare entrambi i tipi)
TEST_ENEMIES = [
    {
        "input": Path(r"E:\Giochini\Giuseppe\Bible\Character design\Infantry.png"),
        "output": Path(r"E:\Giochini\Giuseppe\pipeline\raw_enemies\chr_enemy_infantry.glb"),
        "name": "Infantry (Umano)",
    },
    {
        "input": Path(r"E:\Giochini\Giuseppe\Bible\Character design\DRONE .png"),
        "output": Path(r"E:\Giochini\Giuseppe\pipeline\raw_enemies\chr_enemy_drone.glb"),
        "name": "Drone (Hardware)",
    },
]

# Generation settings (conservative for 8GB VRAM)
SETTINGS = {
    "texture": True,
    "octree_resolution": 256,
    "num_inference_steps": 5,
    "guidance_scale": 5.0,
    "remove_background": True,
    "type": "glb",
}


# ============================================================
# FUNCTIONS
# ============================================================

def check_server() -> bool:
    """Check if Hunyuan3D server is running."""
    try:
        resp = requests.get(f"{API_URL}/", timeout=5)
        return resp.status_code == 200
    except:
        return False


def encode_image(path: Path) -> str:
    """Encode image to base64."""
    with open(path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode()
    suffix = path.suffix.lower()
    mime = "image/png" if suffix == ".png" else "image/jpeg"
    return f"data:{mime};base64,{b64}"


def generate(image_path: Path) -> Optional[bytes]:
    """Generate 3D model from image."""
    image_b64 = encode_image(image_path)
    
    payload = {
        "image": image_b64,
        **SETTINGS,
    }
    
    try:
        print(f"  Invio richiesta a {API_URL}/generate...")
        resp = requests.post(
            f"{API_URL}/generate",
            json=payload,
            timeout=300,
        )
        
        if resp.status_code == 200:
            return resp.content
        else:
            print(f"  ERRORE API: {resp.status_code}")
            print(f"  Risposta: {resp.text[:500]}")
            return None
            
    except requests.exceptions.Timeout:
        print(f"  TIMEOUT: generazione troppo lenta (>5 min)")
        return None
    except Exception as e:
        print(f"  ERRORE: {e}")
        return None


def main():
    """Test pipeline with 1-2 images."""
    print("=" * 60)
    print("  Hunyuan3D-2.1 — TEST (1-2 Immagini)")
    print("=" * 60)
    print()
    
    # Check server
    print("Verifica server...")
    if not check_server():
        print("ERRORE: Server Hunyuan3D non raggiungibile!")
        print()
        print("Avvia prima il server:")
        print("  1. Vai in: E:\\Applicazioni\\Hunyuan3D2\\")
        print("  2. Esegui: RUN.bat")
        print("  3. Attendi: 'Uvicorn running on http://0.0.0.0:8080'")
        print()
        return
    
    print("Server OK!")
    print()
    
    # Create output dir
    TEST_ENEMIES[0]["output"].parent.mkdir(parents=True, exist_ok=True)
    
    # Process each test enemy
    for i, enemy in enumerate(TEST_ENEMIES, 1):
        print(f"\n[{i}/{len(TEST_ENEMIES)}] {enemy['name']}")
        print("-" * 40)
        
        # Check input
        if not enemy["input"].exists():
            print(f"  ERRORE: File non trovato: {enemy['input']}")
            continue
        
        print(f"  Input: {enemy['input'].name} ({enemy['input'].stat().st_size / 1024:.0f} KB)")
        print(f"  Output: {enemy['output'].name}")
        print()
        
        # Generate
        start = time.time()
        glb_data = generate(enemy["input"])
        elapsed = time.time() - start
        
        if glb_data is None:
            print(f"  FALLITO dopo {elapsed:.1f}s")
            continue
        
        # Save
        with open(enemy["output"], "wb") as f:
            f.write(glb_data)
        
        size_mb = len(glb_data) / (1024 * 1024)
        print(f"  COMPLETATO in {elapsed:.1f}s")
        print(f"  Dimensione: {size_mb:.1f} MB")
        print(f"  Salvato: {enemy['output']}")
    
    # Summary
    print("\n" + "=" * 60)
    print("  TEST COMPLETATO")
    print("=" * 60)
    print()
    print("Controlla i file generati in:")
    print(f"  {TEST_ENEMIES[0]['output'].parent}")
    print()
    print("Se i risultati sono buoni, esegui il batch completo:")
    print("  python pipeline/batch_hunyuan3d.py")
    print()


if __name__ == "__main__":
    main()
