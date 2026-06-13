---
name: GrowWise Financial Learning
colors:
  surface: '#fdf7ff'
  surface-dim: '#ded8e0'
  surface-bright: '#fdf7ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f2fa'
  surface-container: '#f2ecf4'
  surface-container-high: '#ece6ee'
  surface-container-highest: '#e6e0e9'
  on-surface: '#1d1b20'
  on-surface-variant: '#494551'
  inverse-surface: '#322f35'
  inverse-on-surface: '#f5eff7'
  outline: '#7a7582'
  outline-variant: '#cbc4d2'
  surface-tint: '#6750a4'
  primary: '#4f378a'
  on-primary: '#ffffff'
  primary-container: '#6750a4'
  on-primary-container: '#e0d2ff'
  inverse-primary: '#cfbcff'
  secondary: '#63597c'
  on-secondary: '#ffffff'
  secondary-container: '#e1d4fd'
  on-secondary-container: '#645a7d'
  tertiary: '#765b00'
  on-tertiary: '#ffffff'
  tertiary-container: '#c9a74d'
  on-tertiary-container: '#503d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#cfbcff'
  on-primary-fixed: '#22005d'
  on-primary-fixed-variant: '#4f378a'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#cdc0e9'
  on-secondary-fixed: '#1f1635'
  on-secondary-fixed-variant: '#4b4263'
  tertiary-fixed: '#ffdf93'
  tertiary-fixed-dim: '#e7c365'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#594400'
  background: '#fdf7ff'
  on-background: '#1d1b20'
  surface-variant: '#e6e0e9'
typography:
  display:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.3'
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '700'
    lineHeight: '1.3'
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: '1.4'
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.4'
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: '1'
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1'
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-max: 1280px
  sidebar-width: 280px
  gutter: 24px
  margin-desktop: 40px
  margin-mobile: 20px
---

## Brand & Style

The brand personality for this design system is **Playful yet Trustworthy**. It bridges the gap between an engaging, gamified environment for children and a secure, professional financial oversight tool for parents. The UI should evoke feelings of optimism, growth, and clarity.

The design style is a blend of **Modern Corporate** and **Soft Minimalism**. It utilizes high-fidelity finishes—such as soft depth and generous roundedness—to appear approachable without sacrificing the seriousness of financial education. Large, legible typography and a spacious layout ensure the interface is accessible to younger users while maintaining the sophisticated structure required for data-heavy parental dashboards.

## Colors

The design system employs a **dual-theme palette** to distinguish between the two primary user journeys:
- **Child Theme:** Uses the Primary Green and Light Green tones to represent growth, success, and "go" actions. It is the core of the earning and learning experience.
- **Parent Theme:** Switches to Primary Indigo and Light Indigo to signal authority, security, and management.

**Accents & Neutrals:**
- **Amber & Gold:** Used for rewards, milestones, and high-value achievements.
- **Coral:** Reserved for alerts, spending limits, or urgent notifications.
- **Text:** Primary text uses a deep navy-charcoal (#1A1A2E) for high legibility against white surfaces, while secondary text (#64748B) handles metadata and labels.

## Typography

This design system uses **Plus Jakarta Sans** exclusively to leverage its soft, geometric curves which feel both modern and friendly. 

**Vietnamese Language Optimization:** 
Special attention must be paid to line heights (1.4 - 1.6) for body text to accommodate the diacritics common in Vietnamese script without overlapping.

**Usage:**
- **Display & Headline:** Used for large hero sections or account balances. Use the extra-bold weights to create a sense of fun.
- **Body:** Standardized on 16px (Medium) for maximum readability for children. 
- **Labels:** Used for navigation items, button text, and small metadata.

## Layout & Spacing

The layout follows a **Fixed Grid** model for desktop, centered within the viewport, with a persistent sidebar for primary navigation.

**Layout Model:**
- **Desktop:** 12-column grid with a 24px gutter. The sidebar is fixed to the left at 280px, while the main content area expands to a max-width of 1280px.
- **Tablet:** 8-column grid with 16px gutters. The sidebar may collapse into a drawer.
- **Mobile:** 4-column grid with 16px gutters and 20px side margins.

**Spacing Rhythm:**
All spacing is based on an **8px base unit**. Component internal padding should utilize 16px or 24px increments to maintain a spacious, uncluttered aesthetic that doesn't overwhelm younger users.

## Elevation & Depth

Visual hierarchy is primarily established through **Tonal Layers** and **Ambient Shadows**.

- **Level 0 (Background):** The canvas color is #F6F8FA, providing a soft, low-glare foundation.
- **Level 1 (Cards/Surface):** White surfaces (#FFFFFF) are used for all primary content containers. These use a "Soft Shadow" (Blur: 12px, Y: 4px, Color: rgba(0,0,0,0.05)) to lift them slightly from the background.
- **Level 2 (Interactive):** Hover states for buttons and active selections may use a slightly more pronounced shadow or a subtle 2px border in the theme's primary color to indicate focus.

Avoid heavy blacks or harsh drop shadows. The goal is a "cloud-like" lightness that feels safe and modern.

## Shapes

The shape language is defined by significant roundedness to reinforce the "friendly" brand pillar.

- **Primary Containers (Cards):** Use a 20px (1.25rem) radius. This applies to modal dialogs, main content areas, and dashboard widgets.
- **Interactive Elements (Buttons/Inputs):** Use a 14px (0.875rem) radius. This distinctive curve sits between a standard rounded corner and a pill shape, offering a unique "squircle-lite" aesthetic.
- **Icons & Avatars:** Should always be enclosed in rounded-rectangles or circles to match the overall softness.

## Components

### Buttons
- **Primary:** Solid fill (Theme Primary), white text. High-contrast and bold.
- **Secondary:** Light fill (Theme Secondary), Theme Primary text. No border.
- **Ghost:** No fill, Theme Primary border (1px). Used for secondary actions.
- *Styling:* All buttons use 14px radius and 16px/24px horizontal padding.

### Input Fields
- **Default:** White background, 1px border (#E2E8F0), 14px radius. 
- **Focus:** 2px border in Theme Primary color with a subtle outer glow.
- **Labels:** Always placed above the field in Label-MD styling for clarity.

### Cards
- White background, 20px radius, 12px blur shadow. 
- Padding should be generous (default 32px) to keep content breathable.

### Chips & Badges
- Used for categories (e.g., "Chores," "Lessons"). 
- Small 8px radius, semi-bold text, using accent colors with 10% opacity backgrounds.

### Progress Bars
- Thick (12px height), fully rounded tracks.
- Use #E2E8F0 for the track and Child-Primary Green or Gold for the fill.

### Sidebar Navigation
- Vertical stack with large touch/click targets (min-height 48px).
- Active state uses a "soft indicator": a subtle background tint and a 4px vertical pill on the left edge.