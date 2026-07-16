#!/usr/bin/env python3
"""
Download enemy models from anything.world library
"""
import os
import requests
from pathlib import Path
from typing import Dict, List, Optional

# Load .env manually
def load_env():
    env_path = Path(__file__).parent / ".env"
    if env_path.exists():
        with open(env_path) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, value = line.split("=", 1)
                    os.environ[key] = value

load_env()

API_KEY = os.getenv("ANYTHING_WORLD_API_KEY", "")
BASE_URL = "https://api.anything.world"

# Search terms for each enemy type
SEARCH_TERMS = {
    "chr_enemy_infantry": ["soldier", "infantry", "soldier_man", "soldier_woman"],
    "chr_enemy_shield": ["riot_shield", "shield", "police_shield", "riot_police"],
    "chr_enemy_flamethrower": ["flamethrower", "firefighter", "hazmat_suit"],
    "chr_enemy_sniper": ["sniper", "marksman", "ghillie_suit"],
    "chr_enemy_engineer": ["engineer", "technician", "mechanic", "tech"],
    "chr_enemy_medic": ["medic", "doctor", "paramedic", "combat_medic"],
    "chr_enemy_heavy": ["heavy_gunner", "machine_gunner", "heavy_weapons"],
    "chr_enemy_elite": ["special_forces", "elite_soldier", "operator", "tier_one"],
    "chr_enemy_juggernaut": ["juggernaut", "heavy_armor", "exoskeleton", "bomb_suit"],
    "chr_enemy_drone": ["drone", "quadcopter", "uav", "recon_drone"],
    "chr_enemy_robot": ["robot", "android", "mech", "battle_droid"],
    "chr_enemy_assault_robot": ["combat_robot", "battle_mech", "assault_mech"],
    "chr_enemy_predator_heli": ["attack_helicopter", "gunship", "apache", "hind"],
}

def search_models(query: str) -> List[Dict]:
    """Search for models in the library"""
    try:
        response = requests.get(
            "https://api.anything.world/anything",
            params={"key": os.getenv("ANYTHING_WORLD_API_KEY", ""), "search": query},
            timeout=30
        )
        if response.status_code == 200:
            return response.json()
        elif response.status_code == 429:
            print(f"Rate limited for query: {query}")
            return []
        else:
            print(f"Error searching '{query}': {response.status_code} - {response.text[:200]}")
            return []
    except Exception as e:
        print(f"Error searching '{query}': {e}")
        return []

def download_model(model_data: Dict, output_path: Path) -> bool:
    """Download a model from the library"""
    model_url = model_data.get("model", {}).get("model")
    if not model_url:
        model_url = model_data.get("model_url") or model_data.get("download_url")
    
    if not model_url:
        print(f"  No download URL for model")
        return False
    
    try:
        response = requests.get(model_url, stream=True, timeout=120)
        response.raise_for_status()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        print(f"  Downloaded: {output_path.name}")
        return True
    except Exception as e:
        print(f"  Error downloading: {e}")
        return False

def find_best_model(enemy_name: str, search_terms: List[str]) -> Optional[Dict]:
    """Find the best matching model for an enemy"""
    best_model = None
    best_score = 0
    
    for term in search_terms:
        models = search_models(term)
        for model in models:
            name = model.get("name", "").lower()
            creature = model.get("creature", "").lower()
            tags = " ".join(model.get("tags", [])).lower()
            
            score = 0
            enemy_lower = enemy_name.lower().replace("chr_enemy_", "")
            
            if enemy_lower in name:
                score += 10
            if any(word in name for word in enemy_name.lower().split("_")):
                score += 5
            if enemy_lower in creature:
                score += 8
            
            for word in enemy_name.lower().replace("chr_enemy_", "").split("_"):
                if word in tags:
                    score += 3
            
            if score > best_score:
                best_score = score
                best_model = model
    
    return best_model

def main():
    output_dir = Path("/mnt/e/Giochini/Giuseppe/scenes/enemies")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print("=" * 60)
    print("DOWNLOADING ENEMY MODELS FROM ANYTHING.WORLD LIBRARY")
    print("=" * 60)
    
    for enemy_name, search_terms in SEARCH_TERMS.items():
        print(f"\n=== {enemy_name} ===")
        
        model = find_best_model(enemy_name, search_terms)
        if model:
            output_path = Path(f"/mnt/e/Giochini/Giuseppe/scenes/enemies/{enemy_name}.glb")
            if download_model(model, output_path):
                print(f"  ✓ Downloaded {enemy_name}")
            else:
                print(f"  ✗ Failed to download {enemy_name}")
        else:
            print(f"  ✗ No suitable model found for {enemy_name}")
    
    print("\n" + "=" * 60)
    print("DOWNLOAD COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    main()