---
name: Playful Modernism
colors:
  surface: '#fff8f3'
  surface-dim: '#dfd9d4'
  surface-bright: '#fff8f3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f9f2ed'
  surface-container: '#f3ede8'
  surface-container-high: '#eee7e2'
  surface-container-highest: '#e8e1dc'
  on-surface: '#1d1b18'
  on-surface-variant: '#564334'
  inverse-surface: '#33302d'
  inverse-on-surface: '#f6efeb'
  outline: '#897362'
  outline-variant: '#ddc1ae'
  surface-tint: '#904d00'
  primary: '#904d00'
  on-primary: '#ffffff'
  primary-container: '#ff8c00'
  on-primary-container: '#623200'
  inverse-primary: '#ffb77d'
  secondary: '#006e1c'
  on-secondary: '#ffffff'
  secondary-container: '#96f592'
  on-secondary-container: '#0a7320'
  tertiary: '#6833ea'
  on-tertiary: '#ffffff'
  tertiary-container: '#b29bff'
  on-tertiary-container: '#4600bb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdcc3'
  primary-fixed-dim: '#ffb77d'
  on-primary-fixed: '#2f1500'
  on-primary-fixed-variant: '#6e3900'
  secondary-fixed: '#99f894'
  secondary-fixed-dim: '#7edb7b'
  on-secondary-fixed: '#002204'
  on-secondary-fixed-variant: '#005313'
  tertiary-fixed: '#e8deff'
  tertiary-fixed-dim: '#cdbdff'
  on-tertiary-fixed: '#20005f'
  on-tertiary-fixed-variant: '#4f00d0'
  background: '#fff8f3'
  on-background: '#1d1b18'
  surface-variant: '#e8e1dc'
typography:
  headline-xl:
    fontFamily: Nunito Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Nunito Sans
    fontSize: 24px
    fontWeight: '800'
    lineHeight: 32px
  headline-md:
    fontFamily: Nunito Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Nunito Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  body-md:
    fontFamily: Nunito Sans
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  label-lg:
    fontFamily: Nunito Sans
    fontSize: 15px
    fontWeight: '800'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Nunito Sans
    fontSize: 13px
    fontWeight: '700'
    lineHeight: 18px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  3d-offset: 4px
---

## Brand & Style

The design system is built on the philosophy of **Playful Modernism**. It transforms educational and growth-oriented tasks into an engaging, gamified experience. The brand personality is energetic, encouraging, and tactile, aiming to evoke a sense of progress and accomplishment.

The visual style blends clean, modern layouts with high-energy "skeuo-minimalist" elements. Key characteristics include:
- **Tactile Depth:** UI elements use thick bottom borders and offsets to mimic physical buttons.
- **Vibrant Energy:** A high-saturation color palette provides clear functional cues and rewards.
- **Friendly Geometry:** Soft, hyper-rounded shapes (pills and circles) reduce visual friction and make the interface feel approachable and safe for learning.

## Colors

The palette is anchored by a warm **Cream (#fff8f3)** background, which provides a softer, more inviting canvas than pure white. 

- **Primary Orange:** Used for primary actions, current unit headers, and high-energy highlights.
- **Secondary Green:** Signifies completion, success, and "Go" states.
- **Tertiary Purple:** Used for special rewards, streaks, or secondary navigation elements.
- **3D Borders:** Every interactive component uses a "shaded" version of its base color (approx. 20% darker) for the bottom border to create the 3D effect.
- **States:** Inactive or locked states transition to a desaturated gray palette to maintain clear hierarchy.

## Typography

This design system exclusively uses **Nunito Sans** to leverage its rounded terminals, which complement the soft UI shapes. 

- **Headlines:** Use Extra Bold (800) weights to create a strong, confident presence that feels like a game title.
- **Body:** Use Medium (500) to SemiBold (600) for high legibility against the cream background.
- **Uppercase Labels:** Used for navigation titles and button text to emphasize the "action-oriented" nature of the UI.

## Layout & Spacing

The layout follows a **Fluid Grid** approach with generous safe areas. 

- **Margins:** 24px (lg) on mobile, scaling to 48px on desktop.
- **Gutters:** 16px (md) standard.
- **Rhythm:** All spacing is based on a 4px baseline unit. 
- **3D Verticality:** Interactive elements occupy an extra 4px of vertical space at the bottom to account for the "thick border" 3D effect. When pressed, the element should translate 2px down and the border should shrink to 2px, simulating physical compression.

## Elevation & Depth

This design system rejects traditional soft shadows in favor of **Tonal 3D Offsets**. 

1.  **Level 0 (Surface):** The Cream background.
2.  **Level 1 (Cards):** Flat surfaces with a 2px stroke and a 4px bottom offset in a darker neutral shade.
3.  **Level 2 (Active Elements):** High-contrast colors with a 4px bottom border in a darker shade of the primary/secondary color.
4.  **Backdrop Blurs:** Used sparingly for modal overlays to keep the focus on the gamified path.

## Shapes

The shape language is hyper-rounded. 
- **Pills:** All buttons and navigation switchers use full pill rounding (100vh border-radius).
- **Cards:** Library and content cards use a consistent 24px (rounded-xl) radius.
- **Nodes:** Path elements are perfect circles. 
- **Icons:** Use a rounded icon set (e.g., Lucide or Phosphor-Rounded) to match the container geometry.

## Components

### 1. 3D 'Pill' Buttons
- **Shape:** Full pill.
- **Style:** Solid background color with a 4px bottom border (darker shade).
- **Typography:** Label-lg, centered.
- **Interaction:** On 'active/press', the button moves 2px down; the bottom border reduces to 2px.

### 2. Path Nodes (The Progress Map)
- **Active:** Circular button, primary color, 3D effect, white icon. Often wrapped in a subtle outer pulse or halo.
- **Completed:** Circular button, secondary color (Green). Displays a white checkmark or a gold crown icon.
- **Locked:** Circular button, locked_gray. Border is locked_border. Icon is a simple padlock.

### 3. Library Cards
- **Radius:** 24px.
- **Border:** 2px solid #E5E5E5 (or a darker cream).
- **3D Effect:** A 4px "shelf" border at the bottom.
- **Content:** Large imagery on top, title in headline-md below.

### 4. Pill Tab Switcher
- **Container:** Large, cream-filled pill with a thin border.
- **Active Segment:** A secondary pill shape inside that "slides" between options. 
- **Style:** High contrast (Primary or Tertiary color) for the active segment with white text.

### 5. Floating Action Bubble
- Used for tooltips or "Start" hints.
- **Shape:** Rounded rectangle with a centered triangle pointer at the bottom.
- **Animation:** Gentle vertical bobbing.