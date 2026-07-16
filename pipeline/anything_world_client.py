#!/usr/bin/env python3
"""
anything.world API Client for mesh generation + rigging + animations
"""
import os
import json
import time
import requests
from pathlib import Path
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, field

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

@dataclass
class GenerationRequest:
    prompt: str
    style: str = "realistic"
    polycount: int = 15000
    texture_resolution: int = 2048
    generate_rig: bool = True
    generate_animations: bool = True
    animation_types: List[str] = field(default_factory=lambda: ["idle", "walk", "run", "attack", "death", "hit"])

@dataclass
class GenerationResult:
    job_id: str
    status: str
    model_url: str = ""
    rig_url: str = ""
    animations: Dict[str, str] = field(default_factory=dict)
    error: str = ""

class AnythingWorldClient:
    def __init__(self, api_key: str = None, base_url: str = None):
        self.api_key = api_key or API_KEY
        self.base_url = base_url or BASE_URL
    
    def _params(self) -> Dict[str, str]:
        return {"key": self.api_key}
    
    def text_to_3d(self, request: GenerationRequest) -> GenerationResult:
        """Generate 3D model from text prompt"""
        url = f"{self.base_url}/text-to-3d"
        
        data = {
            "key": self.api_key,
            "text_prompt": request.prompt,
            "refine_prompt": "true",
            "can_use_for_internal_improvements": "false",
            "can_be_public": "false",
        }
        
        response = requests.post(f"{self.base_url}/text-to-3d", data=data, timeout=60)
        response.raise_for_status()
        result = response.json()
        
        return GenerationResult(
            job_id=result.get("model_id", "") or "",
            status="submitted"
        )
    
    def image_to_3d(self, image_path: Path, request: GenerationRequest) -> GenerationResult:
        """Generate 3D model from image"""
        url = f"{self.base_url}/image-to-3d"
        
        with open(image_path, "rb") as f:
            files = {"files": (image_path.name, f, "image/png")}
            data = {
                "key": self.api_key,
                "model_name": request.prompt[:100],
                "can_use_for_internal_improvements": "false",
                "can_be_public": "false",
            }
            
            response = requests.post(url, data=data, files=files, timeout=120)
            response.raise_for_status()
            result = response.json()
            
            return GenerationResult(
                job_id=result.get("model_id", "") or "",
                status="submitted"
            )
    
    def animate_model(self, model_path: Path, request: GenerationRequest) -> GenerationResult:
        """Rig and animate an existing 3D model"""
        url = f"{self.base_url}/animate"
        
        with open(model_path, "rb") as f:
            files = {"files": (model_path.name, f, "model/gltf-binary")}
            data = {
                "key": self.api_key,
                "model_name": request.prompt[:100],
                "model_type": "humanoid" if "human" in request.prompt.lower() else "creature",
                "symmetry": "true",
                "auto_classify": "true",
                "auto_rotate": "false",
                "can_use_for_internal_improvements": "false",
                "author": "ABERRATION Pipeline",
                "license": "ccby",
            }
            
            response = requests.post(url, data=data, files=files, timeout=120)
            response.raise_for_status()
            result = response.json()
            
            return GenerationResult(
                job_id=result.get("model_id", "") or "",
                status="submitted"
            )
    
    def rig_model(self, model_path: Path, request: GenerationRequest) -> GenerationResult:
        """Rig a model without animations"""
        url = f"{self.base_url}/rig"
        
        with open(model_path, "rb") as f:
            files = {"files": (model_path.name, f, "model/gltf-binary")}
            data = {
                "key": self.api_key,
                "model_name": request.prompt[:100],
                "model_type": "humanoid" if "human" in request.prompt.lower() else "creature",
                "symmetry": "true",
                "auto_classify": "true",
                "auto_rotate": "false",
            }
            
            response = requests.post(url, data=data, files=files, timeout=120)
            response.raise_for_status()
            result = response.json()
            
            return GenerationResult(
                job_id=result.get("model_id", "") or "",
                status="submitted"
            )
    
    def check_generated_status(self, model_id: str) -> GenerationResult:
        """Check status for text-to-3d / image-to-3d jobs"""
        url = f"{self.base_url}/user-generated-model"
        params = {"key": self.api_key, "id": model_id}
        
        response = requests.get(url, params=params, timeout=30)
        response.raise_for_status()
        result = response.json()
        
        return GenerationResult(
            job_id=model_id,
            status=result.get("status", "unknown"),
            model_url=result.get("model_url", ""),
            rig_url=result.get("rig_url", ""),
            animations=result.get("animations", {}),
            error=result.get("error", "")
        )
    
    def check_processed_status(self, model_id: str) -> GenerationResult:
        """Check status for animate/rig jobs"""
        url = f"{self.base_url}/user-processed-model"
        params = {"key": self.api_key, "id": model_id}
        
        response = requests.get(url, params=params, timeout=30)
        response.raise_for_status()
        result = response.json()
        
        return GenerationResult(
            job_id=model_id,
            status=result.get("status", "unknown"),
            model_url=result.get("model_url", ""),
            rig_url=result.get("rig_url", ""),
            animations=result.get("animations", {}),
            error=result.get("error", "")
        )
    
    def wait_for_generated(self, model_id: str, poll_interval: int = 30, timeout: int = 600) -> GenerationResult:
        """Wait for text-to-3d / image-to-3d job to complete"""
        start = time.time()
        while time.time() - start < timeout:
            result = self.check_generated_status(model_id)
            if result.status == "completed":
                return result
            elif result.status == "failed":
                raise RuntimeError(f"Generation failed: {result.error}")
            print(f"  Job {model_id}: {result.status}... waiting")
            time.sleep(poll_interval)
        raise TimeoutError(f"Job {model_id} timed out after {timeout}s")
    
    def wait_for_processed(self, model_id: str, poll_interval: int = 30, timeout: int = 1200) -> GenerationResult:
        """Wait for animate/rig job to complete"""
        start = time.time()
        while time.time() - start < timeout:
            result = self.check_processed_status(model_id)
            if result.status == "completed":
                return result
            elif result.status == "failed":
                raise RuntimeError(f"Processing failed: {result.error}")
            print(f"  Job {model_id}: {result.status}... waiting")
            time.sleep(poll_interval)
        raise TimeoutError(f"Job {model_id} timed out after {timeout}s")
    
    def download_asset(self, url: str, dest_path: Path) -> Path:
        """Download generated asset"""
        response = requests.get(url, stream=True, timeout=120)
        response.raise_for_status()
        dest_path.parent.mkdir(parents=True, exist_ok=True)
        with open(dest_path, "wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        return dest_path

def generate_enemy_batch(client: AnythingWorldClient, enemies: List[Dict], output_dir: Path) -> Dict[str, GenerationResult]:
    """Generate all 13 enemies in batch"""
    results = {}
    for enemy in enemies:
        print(f"\n=== Generating {enemy['name']} ===")
        request = GenerationRequest(
            prompt=enemy["prompt"],
            style=enemy.get("style", "realistic"),
            polycount=enemy.get("polycount", 15000),
            texture_resolution=enemy.get("texture_resolution", 2048),
            generate_rig=enemy.get("generate_rig", True),
            generate_animations=enemy.get("generate_animations", True),
            animation_types=enemy.get("animation_types", ["idle", "walk", "run", "attack", "death", "hit"])
        )
        
        # Submit job
        result = client.text_to_3d(request)
        print(f"  Submitted job: {result.job_id}")
        
        # Wait for completion
        try:
            final_result = client.wait_for_generated(result.job_id)
            results[enemy["name"]] = final_result
            
            # Download model
            if final_result.model_url:
                model_path = output_dir / f"{enemy['name']}.glb"
                client.download_asset(final_result.model_url, model_path)
                print(f"  Downloaded model: {model_path}")
            
            # Download rig if available
            if final_result.rig_url:
                rig_path = output_dir / f"{enemy['name']}_rig.glb"
                client.download_asset(final_result.rig_url, rig_path)
                print(f"  Downloaded rig: {rig_path}")
            
            # Download animations
            if final_result.animations:
                for anim_name, anim_url in final_result.animations.items():
                    anim_path = output_dir / f"{enemy['name']}_{anim_name}.glb"
                    client.download_asset(anim_url, anim_path)
                    print(f"  Downloaded animation {anim_name}: {anim_path}")
                    
        except Exception as e:
            print(f"  ERROR: {e}")
            results[enemy["name"]] = GenerationResult(job_id="", status="failed", error=str(e))
    
    return results

if __name__ == "__main__":
    # Test connection
    client = AnythingWorldClient()
    print(f"Connected to anything.world API")
    print(f"API Key: {API_KEY[:8]}...")