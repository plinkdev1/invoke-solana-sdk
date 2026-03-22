content = """# Splash.gd
extends Control

const AUTO_ADVANCE_DELAY := 2.5

@onready var splash_icon: TextureRect   = $Center/VBox/SplashIcon
@onready var splash_logo: Label         = $Center/VBox/SplashLogo
@onready var splash_sub:  Label         = $Center/VBox/SplashSub
@onready var splash_dots: HBoxContainer = $Center/VBox/SplashDots

func _ready() -> void:
\tawait get_tree().process_frame
\tawait get_tree().process_frame
\t_play_enter_animations()
\tawait get_tree().create_timer(AUTO_ADVANCE_DELAY).timeout
\t_navigate()

func _play_enter_animations() -> void:
\tvar t_icon := create_tween().set_parallel(true)
\tt_icon.tween_property(splash_icon, "modulate:a", 1.0, DesignTokens.ANIM_XSLOW).set_delay(0.1)
\tt_icon.tween_property(splash_icon, "scale", Vector2(1.0, 1.0), 0.5).set_delay(0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
\tvar logo_rest_y := splash_logo.position.y
\tsplash_logo.position.y = logo_rest_y + 40.0
\tvar t_logo := create_tween().set_parallel(true)
\tt_logo.tween_property(splash_logo, "modulate:a", 1.0, 0.5).set_delay(0.2)
\tt_logo.tween_property(splash_logo, "position:y", logo_rest_y, 0.6).set_delay(0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
\tvar t_sub := create_tween()
\tt_sub.tween_interval(0.6)
\tt_sub.tween_property(splash_sub, "modulate:a", 1.0, DesignTokens.ANIM_SLOW)
\tvar t_dots := create_tween()
\tt_dots.tween_interval(0.8)
\tt_dots.tween_property(splash_dots, "modulate:a", 1.0, DesignTokens.ANIM_FAST * 2.0)

func _navigate() -> void:
\tget_tree().change_scene_to_file("res://scenes/screens/WalletPicker.tscn")
"""

with open(r'C:\PROJECTS\Invoke_Solana_App\example\invokequest\scenes\screens\Splash.gd', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
print('Splash.gd written.')
