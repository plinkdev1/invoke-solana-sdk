# DesignTokens.gd
# Autoload singleton -- all design constants for InvokeQuest.
extends Node

const COLOR_BG           = Color(0.031, 0.039, 0.055, 1.0)
const COLOR_SURFACE      = Color(1.0,   1.0,   1.0,   0.05)
const COLOR_SURFACE_2    = Color(1.0,   1.0,   1.0,   0.08)
const COLOR_GLASS_BORDER = Color(1.0,   1.0,   1.0,   0.10)
const COLOR_PURPLE       = Color(0.600, 0.271, 1.000, 1.0)
const COLOR_PURPLE_DIM   = Color(0.600, 0.271, 1.000, 0.15)
const COLOR_GREEN        = Color(0.078, 0.945, 0.596, 1.0)
const COLOR_GREEN_DIM    = Color(0.078, 0.945, 0.596, 0.12)
const COLOR_YELLOW       = Color(1.000, 0.725, 0.220, 1.0)
const COLOR_RED          = Color(1.000, 0.310, 0.310, 1.0)
const COLOR_WHITE        = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_WHITE_60     = Color(1.0, 1.0, 1.0, 0.6)
const COLOR_WHITE_30     = Color(1.0, 1.0, 1.0, 0.3)
const COLOR_WHITE_10     = Color(1.0, 1.0, 1.0, 0.1)

const FONT_SIZE_XL  = 36
const FONT_SIZE_LG  = 24
const FONT_SIZE_MD  = 18
const FONT_SIZE_SM  = 14
const FONT_SIZE_XS  = 12
const FONT_SIZE_XXS = 10

const SPACE_XS  =  4
const SPACE_SM  =  8
const SPACE_MD  = 16
const SPACE_LG  = 24
const SPACE_XL  = 32
const SPACE_XXL = 48

const RADIUS_SM   = 8
const RADIUS_MD   = 16
const RADIUS_LG   = 24
const RADIUS_PILL = 999

const ANIM_FAST    = 0.15
const ANIM_NORMAL  = 0.25
const ANIM_SLOW    = 0.35
const ANIM_XSLOW   = 0.60

const ANIM_STAGGER_WALLET = 0.08
const ANIM_STAGGER_ACTION = 0.05
const ANIM_STAGGER_TX     = 0.04

const ANIM_SCREEN_PUSH = 0.25
const ANIM_SCREEN_FADE = 0.30

const GLASS_BLUR_STRENGTH = 3.0
const GLASS_TINT_ALPHA    = 0.06
const GLASS_BORDER_ALPHA  = 0.10
const AURORA_TIME_SCALE   = 0.3
const GLOW_PULSE_SPEED    = 1.5

const Z_BACKGROUND   = -10
const Z_CONTENT      =   0
const Z_OVERLAY      =  10
const Z_BOTTOM_SHEET =  20
const Z_LOADING      =  30
const Z_TOAST        =  40
