---
name: GrowWise
colors:
  surface: '#fff8f2'
  surface-dim: '#e5d8c6'
  surface-bright: '#fff8f2'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fff2e0'
  surface-container: '#f9ecda'
  surface-container-high: '#f3e6d4'
  surface-container-highest: '#eee1cf'
  on-surface: '#211b10'
  on-surface-variant: '#564334'
  inverse-surface: '#362f23'
  inverse-on-surface: '#fcefdd'
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
  background: '#fff8f2'
  on-background: '#211b10'
  surface-variant: '#eee1cf'
typography:
  display-lg:
    fontFamily: Nunito Sans
    fontSize: 40px
    fontWeight: '900'
    lineHeight: 48px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Nunito Sans
    fontSize: 32px
    fontWeight: '900'
    lineHeight: 38px
  headline-md:
    fontFamily: Nunito Sans
    fontSize: 24px
    fontWeight: '800'
    lineHeight: 32px
  body-lg:
    fontFamily: Nunito Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  body-md:
    fontFamily: Nunito Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-bold:
    fontFamily: Nunito Sans
    fontSize: 14px
    fontWeight: '800'
    lineHeight: 20px
  label-sm:
    fontFamily: Nunito Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 16px
  md: 24px
  lg: 32px
  xl: 48px
  container-margin: 20px
  gutter: 16px
---

## Brand & Style
The design system is built on the philosophy of "Playful Modernism." It bridges the gap between a fun, engaging environment for children and a secure, professional tool for parents. The UI evokes warmth, curiosity, and financial confidence.

The aesthetic combines **Soft Skeuomorphism** (tactile, pressable buttons) with **Modern Minimalism** (clean layouts and generous white space). It utilizes a high-contrast color palette and bold shapes to ensure the interface is accessible and delightful for younger users while maintaining a structured layout that parents trust.

## Colors
The palette is centered around a warm cream base to reduce eye strain and feel more inviting than pure white. 

- **Primary (Orange):** Used for main actions and the "Child" environment. It conveys energy and growth.
- **Secondary (Green):** Specifically reserved for "Savings" and positive financial growth indicators.
- **Tertiary (Purple):** Used to distinguish "Parental" controls and premium features, offering a sophisticated contrast to the kid-centric orange.
- **Stroke Logic:** Active elements (Buttons/Inputs) use a dark-tinted stroke (#904d00) to provide a 3D, tactile feel that invites interaction.

## Typography
The design system uses **Nunito Sans** exclusively for its friendly, rounded terminals that match the overall shape language. 

- **Hierarchy:** Headings use "Black" (900) or "ExtraBold" (800) weights to create a strong visual anchor for children.
- **Readability:** Body text stays between 400 and 600 weight. For secondary information, use the color `#564334` to maintain legibility while reducing visual weight.
- **Language Support:** All styles are optimized for Vietnamese diacritics, ensuring accents do not clash with tight line heights.

## Layout & Spacing
The layout uses a **Fluid Grid** system focused on mobile-first interaction. 

- **Safe Zones:** A standard 20px margin is maintained on the left and right of all screens.
- **Vertical Rhythm:** Spacing between sections should follow a 24px (md) or 32px (lg) rhythm to allow the UI to "breathe," making it less overwhelming for young users.
- **Touch Targets:** No interactive element (button/toggle) should be smaller than 48px in height to accommodate developing motor skills.

## Elevation & Depth
Depth is used functionally to separate the "User Layer" from the "Background Layer."

- **Ambient Shadows:** Surfaces use a very soft, diffused shadow (`y-4, blur-12, opacity-5%`) with a slight brown tint to match the warm theme.
- **Child Mode:** Cards use a light orange outer glow (`#ff8c00` at 10% opacity) instead of traditional gray shadows to feel more magical.
- **Parent Mode:** Utilizes **Glassmorphism**. Backgrounds for parent-only modals or views should use a `backdrop-filter: blur(12px)` with a semi-transparent purple tint.
- **Tactile Depth:** Interactive buttons feature a 2px bottom offset (solid border) to simulate a physical button that can be pressed down.

## Shapes
The shape language is ultra-rounded to communicate safety and playfulness.

- **Primary Containers:** Standardized at a 24px (rounded-xl) radius.
- **Input Fields:** Use a 16px radius.
- **Pill Shapes:** Reserved for Buttons and "Status" indicators to make them feel distinct from informational cards.
- **Borders:** A 1px or 2px stroke is used on primary components to give them a "sticker-like" appearance.

## Components

- **Buttons:** Must be pill-shaped. The primary button uses a 2px bottom border in `#904d00`. On hover/tap, the button should translate 1px downward to simulate a physical press.
- **Progress Bars:** Thick (16px), featuring a "candy-stripe" animated overlay. The track should be a lighter version of the fill color.
- **Navigation (Mobile):** A floating bottom bar with a 24px radius. It should contain 5 items. The active state is indicated by a bouncy animation and an icon color change to the primary brand color. 
- **Toggles:** Large, oversized "thumb" for easy swiping. The track turns Green (#006e1c) when active.
- **Inputs:** 16px corner radius with a subtle `#564334` border. On focus, the border thickens to 2px and changes to Orange (#ff8c00).
- **Mascots:** "Ví Piggy" and "Wisy" appear in empty states and completion modals. They should use "spring" animations (overshooting the final scale/position slightly before settling).
- **Chips:** Small, highly rounded labels used for categorizing transactions (e.g., "Học tập", "Quà tặng"). Use light backgrounds with high-contrast text.