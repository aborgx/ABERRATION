#!/usr/bin/env python3
"""
Batch runner: Generate all 13 enemies via anything.world API
Run: python batch_generate.py
"""
import os
import sys
import time
from pathlib import Path

# Add pipeline to path
sys.path.insert(0, str(Path(__file__).parent))

from anything_world_client import AnythingWorldClient, GenerationRequest, generate_enemy_batch
from enemy_prompts import enemies

# ─── Config ──────────────────────────────────────────────────────────────
RAW_DIR = Path(os.getenv("RAW_DIR", "/mnt/e/Giochini/Giuseppe/pipeline/raw"))
RAW_DIR.mkdir(parents=True, exist_ok=True)

# ─── Main ────────────────────────────────────────────────────────────────
def main():
    print("=" * 60)
    print("ANYTHING.WORLD BATCH GENERATION — 13 ENEMIES")
    print("=" * 60)
    
    client = AnythingWorldClient()
    print(f"API Key: {os.getenv('ANYTHING_WORLD_API_KEY', '')[:8]}...")
    
    # Filter enemies that need generation (skip if already exists)
    to_generate = []
    for enemy in enemies:
        output_path = RAW_DIR / f"{enemy['name']}.glb"
        if output_path.exists():
            print(f"  ⏭  {enemy['name']} already exists, skipping")
        else:
            to_generate.append(enemy)
    
    if not to_generate:
        print("\n✓ All enemies already generated!")
        return
    
    print(f"\nGenerating {len(to_generate)} enemies...")
    print("-" * 60)
    
    results = generate_enemy_batch(client, to_generate, RAW_DIR)
    
    # Summary
    print("\n" + "=" * 60)
    print("GENERATION SUMMARY")
    print("=" * 60)
    success = 0
    failed = 0
    for name, result in results.items():
        if result.status == "completed":
            print(f"  ✓ {name}")
            success += 1
        else:
            print(f"  ✗ {name}: {result.error}")
            failed += 1
    
    print(f"\nTotal: {success} succeeded, {failed} failed")
    
    if failed > 0:
        sys.exit(1)

if __name__ == "__main__":
    main()