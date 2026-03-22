import os

base = r"C:\PROJECTS\Invoke_Solana_App\example\invokequest"

# Fix Dashboard disconnect
dashboard = os.path.join(base, "scenes", "screens", "Dashboard.gd")
with open(dashboard, "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "SceneManager.clear_history()\n\tSceneManager.replace_scene(SceneManager.SCENE_WALLET_PICKER)",
    "SceneManager.clear_history()\n\tget_tree().change_scene_to_file(SceneManager.SCENE_WALLET_PICKER)"
)

with open(dashboard, "w", encoding="utf-8", newline="\n") as f:
    f.write(content)
print("Fixed: Dashboard.gd disconnect")

# Fix Settings danger zone
settings = os.path.join(base, "scenes", "screens", "Settings.gd")
with open(settings, "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
    "SceneManager.clear_history()\n\tSceneManager.replace_scene(SceneManager.SCENE_WALLET_PICKER)",
    "SceneManager.clear_history()\n\tget_tree().change_scene_to_file(SceneManager.SCENE_WALLET_PICKER)"
)

with open(settings, "w", encoding="utf-8", newline="\n") as f:
    f.write(content)
print("Fixed: Settings.gd danger zone")
print("Done.")
