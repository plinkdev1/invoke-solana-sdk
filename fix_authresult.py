content = """# AuthResult.gd
extends Control

@onready var wallet_label:  Label          = $Center/VBox/Card/CardVBox/WalletLabel
@onready var address_label: Label          = $Center/VBox/Card/CardVBox/AddressLabel
@onready var cache_label:   Label          = $Center/VBox/Card/CardVBox/CacheLabel
@onready var continue_btn:  Button         = $Center/VBox/ContinueBtn
@onready var card:          PanelContainer = $Center/VBox/Card

func _ready() -> void:
\tvar address := ""
\tvar from_cache := false
\tif Engine.has_singleton("InvokeMWA"):
\t\tvar plugin = Engine.get_singleton("InvokeMWA")
\t\taddress    = plugin.cacheGetAddress()
\t\tfrom_cache = plugin.cacheHasToken()
\tvar display_address := address
\tif address.length() > 12:
\t\tdisplay_address = address.substr(0, 4) + "..." + address.substr(address.length() - 4)
\twallet_label.text  = "Connected"
\taddress_label.text = display_address if display_address != "" else "No address"
\tcache_label.text   = "Session cached" if from_cache else "New session"
\tcache_label.modulate = DesignTokens.COLOR_GREEN if from_cache else DesignTokens.COLOR_YELLOW
\tawait get_tree().process_frame
\t_play_enter()

func _play_enter() -> void:
\tcard.modulate.a = 0.0
\tcard.scale = Vector2(0.95, 0.95)
\tvar t := create_tween().set_parallel(true)
\tt.tween_property(card, "modulate:a", 1.0, DesignTokens.ANIM_SLOW)
\tt.tween_property(card, "scale", Vector2(1.0, 1.0), DesignTokens.ANIM_SLOW).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_continue_pressed() -> void:
\tSceneManager.push_scene(SceneManager.SCENE_DASHBOARD)

func _on_continue_btn_button_down() -> void:
\tvar t := create_tween()
\tt.tween_property(continue_btn, "scale", Vector2(0.97, 0.97), DesignTokens.ANIM_FAST)

func _on_continue_btn_button_up() -> void:
\tvar t := create_tween()
\tt.tween_property(continue_btn, "scale", Vector2(1.0, 1.0), DesignTokens.ANIM_FAST).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
"""

with open(r'C:\PROJECTS\Invoke_Solana_App\example\invokequest\scenes\screens\AuthResult.gd', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
print('AuthResult.gd fixed.')
