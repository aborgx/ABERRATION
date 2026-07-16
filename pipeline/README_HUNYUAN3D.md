# Hunyuan3D-2.1 — Setup & Batch Processing

## Requisiti

- **GPU**: NVIDIA RTX 30+ (Compute Capability ≥ 8.0)
- **VRAM**: 8GB+ (consigliato 12GB+)
- **RAM**: 24GB+ (consigliato 32GB)
- **Disco**: 50GB liberi
- **OS**: Windows 10/11 64-bit
- **7-Zip**: Installato (per estrarre i file)

## Installazione Automatica

### Step 1: Esegui lo script di setup

```batch
cd E:\Giochini\Giuseppe\pipeline
setup_hunyuan3d.bat
```

Questo script:
1. Crea la cartella `E:\Applicazioni\Hunyuan3D2\`
2. Scarica i pacchetti WinPortable (~19GB)
3. Estrae tutto automaticamente

### Step 2: Avvia Hunyuan3D

```batch
cd E:\Applicazioni\Hunyuan3D2
RUN.bat
```

Al primo avvio:
- Scarica i modelli (~19GB) — attendi!
- Compila il rasterizer (se hai CUDA + VS Build Tools)
- Avvia la Web UI su `http://localhost:8080`

### Step 3: Test manuale (opzionale)

1. Apri browser: `http://localhost:8080`
2. Carica un'immagine da `Bible\Character design\`
3. Impostazioni per 8GB VRAM:
   - Remove Background: ✅
   - Enable Texture: ✅
   - Octree Resolution: **256**
   - Steps: **5**
   - Guidance Scale: **5.0**
4. Clicca "Generate"
5. Scarica il GLB

## Batch Processing (13 Nemici)

### Prerequisiti

1. Hunyuan3D server in esecuzione (`RUN.bat`)
2. Python 3.10+ installato
3. Requests library: `pip install requests`

### Esegui il batch

```batch
cd E:\Giochini\Giuseppe\pipeline
python batch_hunyuan3d.py
```

Lo script:
1. Verifica che il server sia attivo
2. Processa tutte e 13 le immagini
3. Salva i GLB in `pipeline\raw_enemies\`
4. Genera un report `_results.json`

### Output

```
pipeline\raw_enemies\
├── chr_enemy_infantry.glb
├── chr_enemy_shield.glb
├── chr_enemy_flamethrower.glb
├── chr_enemy_sniper.glb
├── chr_enemy_engineer.glb
├── chr_enemy_medic.glb
├── chr_enemy_heavy.glb
├── chr_enemy_elite.glb
├── chr_enemy_juggernaut.glb
├── chr_enemy_drone.glb
├── chr_enemy_robot.glb
├── chr_enemy_assault_robot.glb
├── chr_enemy_predator_heli.glb
└── _results.json
```

## Post-Processing (dopo generazione)

Dopo aver generato i 13 GLB, serve:

### 1. Retopologia (se necessario)

I modelli generati da Hunyuan3D potrebbero avere troppe facce.
Usa AutoRemesher (già installato in `pipeline\tools\autoremesher\`):

```batch
python pipeline\remesh.py pipeline\raw_enemies\*.glb
```

### 2. Rigging

Opzioni gratuite:
- **Mixamo** (Adobe): https://www.mixamo.com — rigging automatico + 500+ animazioni
- **Blender Rigify**: già configurato nel progetto

### 3. Animazioni

Per ogni nemico servono 8 animazioni base:
- idle, walk, run, attack_1, attack_2, death, hit, alert

Mixamo include preset per molte di queste.

### 4. Export per Godot

Dopo rigging + animazioni:
1. Esporta in GLB
2. Copia in `scenes\enemies\`
3. Godot importerà automaticamente

## Risoluzione Problemi

### `CUDA out of memory`
- Riduci `octree_resolution` a 192
- Chiudi altri programmi che usano GPU
- Usa `--profile 5` in RUN.bat (MMGP ultra low)

### `CUDA error: no kernel image`
- GPU troppo vecchia (RTX 20-series o GTX)
- Ricompila il rasterizer con `TORCH_CUDA_ARCH_LIST=7.5`

### Texture mancanti o bianche
- Installa CUDA Toolkit 12.9.1
- Installa Visual Studio Build Tools 2022

### Server non raggiungibile
- Verifica che RUN.bat sia in esecuzione
- Controlla `http://localhost:8080`
- Verifica firewall/antivirus

## Risorse

- [WinPortable Repository](https://github.com/YanWenKun/Hunyuan3D-2-WinPortable)
- [Hunyuan3D-2.1 Official](https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1)
- [Mixamo (rigging + animazioni)](https://www.mixamo.com)
- [AutoRemesher](https://github.com/Any وهنا نكمل)

---

*Ultimo aggiornamento: 2026-07-16*
