# DesignTokens.gd
# Autoload singleton — all design constants for InvokeQuest.
# Reference: SOLANAQUEST_ASSET_MAP.md Sections 2, 3, 6.
# Never hardcode colors, sizes, or durations in scene scripts.
# Usage: DesignTokens.COLOR_PURPLE, DesignTokens.FONT_SIZE_LG, etc.

extends Node

# ---------------------------------------------------------------------------
# COLORS
# ---------------------------------------------------------------------------

const COLOR_BG           = Color(0.031, 0.039, 0.055, 1.0)   # #080A0F
const COLOR_SURFACE      = Color(1.0,   1.0,   1.0,   0.05)  # glass base
const COLOR_SURFACE_2    = Color(1.0,   1.0,   1.0,   0.08)  # glass brighter
const COLOR_GLASS_BORDER = Color(1.0,   1.0,   1.0,   0.10)  # card borders

const COLOR_PURPLE       = Color(0.600, 0.271, 1.000, 1.0)   # #9945FF
const COLOR_PURPLE_DIM   = Color(0.600, 0.271, 1.000, 0.15)  # #9945FF @15%
const COLOR_GREEN        = Color(0.078, 0.945, 0.596, 1.0)   # #14F195
const COLOR_GREEN_DIM    = Color(0.078, 0.945, 0.596, 0.12)  # #14F195 @12%
const COLOR_YELLOW       = Color(1.000, 0.725, 0.220, 1.0)   # #FFB938
const COLOR_RED          = Color(1.000, 0.310, 0.310, 1.0)   # #FF4F4F

const COLOR_WHITE        = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_WHITE_60     = Color(1.0, 1.0, 1.0, 0.6)
const COLOR_WHITE_30     = Color(1.0, 1.0, 1.0, 0.3)
const COLOR_WHITE_10     = Color(1.0, 1.0, 1.0, 0.1)

# ---------------------------------------------------------------------------
# FONT SIZES
# ---------------------------------------------------------------------------

const FONT_SIZE_XL  = 36  # Balance amount, screen hero titles
const FONT_SIZE_LG  = 24  # Section titles, wallet name
const FONT_SIZE_MD  = 18  # Card titles, button labels
const FONT_SIZE_SM  = 14  # Body text, descriptions
const FONT_SIZE_XS  = 12  # Labels, badges, sub-text
const FONT_SIZE_XXS = 10  # Addresses, hashes, metadata

# ---------------------------------------------------------------------------
# SPACING
# ---------------------------------------------------------------------------

const SPACE_XS  =  4
const SPACE_SM  =  8
const SPACE_MD  = 16
const SPACE_LG  = 24
const SPACE_XL  = 32
const SPACE_XXL = 48

# ---------------------------------------------------------------------------
# BORDER RADIUS
# ---------------------------------------------------------------------------

const RADIUS_SM = 8
const RADIUS_MD = 16
const RADIUS_LG = 24
const RADIUS_PILL = 999

# ---------------------------------------------------------------------------
# ANIMATION DURATIONS (seconds)
# ---------------------------------------------------------------------------

const ANIM_FAST     = 0.15  # Button press, micro-interactions
const ANIM_NORMAL   = 0.25  # Screen element entry
const ANIM_SLOW     = 0.35  # Card entry, balance card
const ANIM_XSLOW    = 0.60  # Logo entrance, splash elements

const ANIM_STAGGER_WALLET  = 0.08   # Delay between wallet cards
const ANIM_STAGGER_ACTION  = 0.05   # Delay between dashboard action buttons
const ANIM_STAGGER_TX      = 0.04   # Delay between tx list items

const ANIM_SCREEN_PUSH  = 0.25  # Push transition duration
const ANIM_SCREEN_FADE  = 0.30  # Fade transition duration

# ---------------------------------------------------------------------------
# SHADER PARAMS (defaults — can be overridden per instance)
# ---------------------------------------------------------------------------

const GLASS_BLUR_STRENGTH = 3.0
const GLASS_TINT_ALPHA    = 0.06
const GLASS_BORDER_ALPHA  = 0.10

const AURORA_TIME_SCALE   = 0.3
const GLOW_PULSE_SPEED    = 1.5

# ---------------------------------------------------------------------------
# Z-INDEX LAYERS
# ---------------------------------------------------------------------------

const Z_BACKGROUND  = -10
const Z_CONTENT     =   0
const Z_OVERLAY     =  10
const Z_BOTTOM_SHEET = 20
const Z_LOADING     =  30
const Z_TOAST       =  40
