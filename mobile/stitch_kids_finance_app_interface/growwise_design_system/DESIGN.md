---
name: GrowWise Design System
colors:
  surface: '#fff8f3'
  surface-dim: '#e5d8c7'
  surface-bright: '#fff8f3'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fff2e1'
  surface-container: '#faecda'
  surface-container-high: '#f4e6d5'
  surface-container-highest: '#eee0cf'
  on-surface: '#211b10'
  on-surface-variant: '#564334'
  inverse-surface: '#372f24'
  inverse-on-surface: '#fdefdd'
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
  secondary-container: '#91f78e'
  on-secondary-container: '#00731e'
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
  secondary-fixed: '#94f990'
  secondary-fixed-dim: '#78dc77'
  on-secondary-fixed: '#002204'
  on-secondary-fixed-variant: '#005313'
  tertiary-fixed: '#e8deff'
  tertiary-fixed-dim: '#cdbdff'
  on-tertiary-fixed: '#20005f'
  on-tertiary-fixed-variant: '#4f00d0'
  background: '#fff8f3'
  on-background: '#211b10'
  surface-variant: '#eee0cf'
typography:
  headline-xl:
    fontFamily: Nunito Sans
    fontSize: 40px
    fontWeight: '900'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Nunito Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Nunito Sans
    fontSize: 24px
    fontWeight: '800'
    lineHeight: 32px
  body-lg:
    fontFamily: Nunito Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Nunito Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Nunito Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
  headline-lg-mobile:
    fontFamily: Nunito Sans
    fontSize: 28px
    fontWeight: '800'
    lineHeight: 36px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-padding: 24px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The visual identity of the design system is centered on **Playful Modernism**, bridging the gap between a fun, gamified environment for children and a reliable, high-utility financial tool for parents. The atmosphere is warm, encouraging, and vibrant, designed to reduce the friction of learning complex financial concepts.

The aesthetic leans into a tactile, soft-edged style that feels approachable and "squishy" without sacrificing professional clarity. It utilizes gentle depth, organic shapes, and a sun-drenched color palette to evoke feelings of growth, safety, and optimism. This design system ensures that every interaction feels like a rewarding step in a child's financial journey.

## Colors

The palette is anchored by high-energy, positive hues that signify different aspects of the experience:

- **Primary (Vibrant Orange):** Represents action, energy, and the "Ví Piggy" persona. Used for main CTAs and active states.
- **Secondary (Growth Green):** Symbolizes savings, earnings, and progress. Used for success states and wealth-building features.
- **Tertiary (Premium Purple):** Reserved for educational milestones, "Pro" features, and parental controls to provide a distinct visual shift from the kid-focused areas.
- **Background (Warm Cream):** A soft gradient is used across all main screens to reduce eye strain and provide a more "paper-like" or organic feel compared to clinical whites.

Functional neutrals are warm-toned grays to maintain harmony with the cream background, avoiding harsh blacks.

## Typography

This design system exclusively uses **Nunito Sans** for its rounded terminals and friendly architecture, which resonates with a younger audience while remaining highly legible for parents. 

Headlines are styled with extra-heavy weights (800-900) to create a clear visual hierarchy and a "bouncy" editorial feel. Body text maintains a slightly heavier-than-normal weight (min 400-600) to ensure readability against the warm background gradients. Tracking is slightly tightened on headlines to give them a modern, compact look suited for mobile interfaces.

## Layout & Spacing

The layout follows a **fluid grid** model with a focus on generous white space (or "cream space") to prevent the UI from feeling cluttered or overwhelming.

- **Margins:** A standard 24px horizontal margin is applied on mobile to give content breathing room.
- **Rhythm:** An 8px spacing system is used for component relationships, while a 4px "micro-unit" handles internal element alignment.
- **Stacking:** Content is organized in vertical stacks with clear separation. Large cards usually span the full width of the container minus margins, creating a clear vertical scroll path for easy thumb navigation.

## Elevation & Depth

To achieve a tactile, gamified feel, the design system utilizes **Ambient Tonal Shadows** rather than traditional gray dropshadows.

1.  **Low Elevation:** Surface-level cards use a very soft shadow with a subtle tint of the primary or secondary color (e.g., a faint orange glow for primary cards) to make them appear slightly raised.
2.  **Interactive Depth:** Buttons and active cards use a slightly more pronounced shadow on hover or press, simulating a physical push-down effect.
3.  **Layering:** Backgrounds use subtle linear gradients (Top-Down) to suggest a light source from the top-center, creating a natural sense of orientation.
4.  **Glassmorphism (Parental Overlays):** Modal backgrounds for parental settings use a soft backdrop blur to separate "administrative" tasks from the child's playground.

## Shapes

The shape language is defined by extreme softness. 
- **Cards:** Use a signature 24px (1.5rem) corner radius to feel safe and friendly.
- **Buttons:** Always pill-shaped (fully rounded) to invite interaction.
- **Input Fields:** Utilize a 16px radius, balancing the roundness of cards with the functional requirements of text entry.
- **Icons:** Set within circular or super-elliptical containers to maintain consistency with the rounded theme.

## Components

### Buttons
Buttons are pill-shaped and utilize high-contrast fills. The **Primary Action** button uses a subtle bottom-border (2px) of a darker shade of orange to create a "3D" tactile look.

### Cards
Cards are the primary container. They feature a 24px radius, a white or very light-cream fill, and a soft 15% opacity shadow. For "Quests" or "Tasks," cards may feature a colored left-accent border (4px) corresponding to the category (Green for earning, Purple for learning).

### Horizontal Toggles
Toggles are oversized for easy tapping. The track is a soft-neutral with a high-contrast pill-shaped thumb. When active, the track transitions to the Secondary Green color.

### Progress Bars
Used for savings goals. These are thick (12px-16px height) with fully rounded ends. The "fill" should have a subtle diagonal stripe pattern to add a sense of movement and energy.

### Chips
Small, rounded labels used for categorizing transactions or lessons. They use low-saturation versions of the primary/secondary colors with high-saturation text for readability.

### Input Fields
Inputs are large with centered or left-aligned text. They use a 1px soft-brown border that thickens and changes to Primary Orange upon focus.